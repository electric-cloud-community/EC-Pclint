    # -------------------------------------------------------------------------
    # Package
    #    PclintDriver.pl
    #
    # Dependencies
    #    None
    #
    # Purpose
    #    Template for Single Command-line Plug-ins
    #
    # Template Version
    #    1.0
    #
    # Date
    #    07/13/2011
    #
    # Engineer
    #    Carlos Rojas
    #
    # Copyright (c) 2010 Electric Cloud, Inc.
    # All rights reserved
    # -------------------------------------------------------------------------

    # -------------------------------------------------------------------------
    # Includes
    # -------------------------------------------------------------------------
    use ElectricCommander;
    use warnings;
    use strict;
    use Cwd;
    use utf8;
    $|=1;

    
    my $ec = ElectricCommander->new();
    $ec->abortOnError(0);
    
    # -------------------------------------------------------------------------
    # Variables
    # -------------------------------------------------------------------------
    $::gPclintPath          = ($ec->getProperty( "PclintPath" ))->findvalue('//value')->string_value;
    $::gWarningLevel        = ($ec->getProperty( "WarningLevel" ))->findvalue('//value')->string_value;
    $::gIgnoreWarnings      = ($ec->getProperty( "IgnoreWarnings" ))->findvalue('//value')->string_value;
    $::gReportFormat        = ($ec->getProperty( "ReportFormat" ))->findvalue('//value')->string_value;
    $::gAdditionalCommands  = ($ec->getProperty( "AdditionalCommands" ))->findvalue('//value')->string_value;
    $::gSourceCodeFiles     = ($ec->getProperty( "SourceCodeFiles" ))->findvalue('//value')->string_value;
    $::gReportName          = ($ec->getProperty( "ReportName" ))->findvalue('//value')->string_value;
    $::gWorkingDir          = ($ec->getProperty( "WorkingDir" ))->findvalue('//value')->string_value;
    $::gLintProjectName     = ($ec->getProperty( "LintProjectName" ))->findvalue('//value')->string_value;
    $::gProjectPath         = ($ec->getProperty( "ProjectPath" ))->findvalue('//value')->string_value;

    # -------------------------------------------------------------------------
    # Main functions
    # -------------------------------------------------------------------------

    ########################################################################
    # main - contains the whole process to be done by the plugin, it builds
    #        the command line, sets the properties and the working directory
    #
    # Arguments:
    #   none
    #
    # Returns:
    #   none
    #
    ########################################################################
    sub main {

        # create args array
        my @args = ();
        my @prjtArgs = ();

        #properties' map
        my %props;

        #setting the executable file
        my $copyReportCommand = '';
        my $reportPathToCopy;

        if($::gWorkingDir eq ""){
            $::gWorkingDir = cwd;
        }
        else{

            my $fileIndex = rindex($::gPclintPath, '/');

            if($fileIndex == -1){

                $fileIndex = (rindex($::gPclintPath, '\\'));

            }

            if($fileIndex != -1){
                $reportPathToCopy = substr($::gPclintPath, 0, $fileIndex-1);
            }

            $copyReportCommand = "cp \"$::gReportName\" \"$reportPathToCopy\"";

        }

        #argument passing to the args array
        push(@args, '"' . $::gPclintPath . '"');
        if($::gProjectPath && $::gProjectPath ne "")
        {
            push(@prjtArgs, '"' . $::gPclintPath . '"');
            push(@prjtArgs, '"' . $::gProjectPath . '"');
            if($::gLintProjectName && $::gLintProjectName ne "")
            {
                if(!($::gLintProjectName =~ m/.lnt/))
                {
                    $::gLintProjectName .= ".lnt";
                }
                else
                {
                    $::gLintProjectName = "project.lnt";
                }
                push(@prjtArgs,">" . '"' . $::gLintProjectName . '"');
            }
        }
        
        if($::gWarningLevel && $::gWarningLevel ne "")
        {
            push(@args, "-w".$::gWarningLevel);
        }
        
        if($::gIgnoreWarnings  && $::gIgnoreWarnings  ne "") {
            foreach my $command (split(' +', $::gIgnoreWarnings)) {
                push(@args, "-e$command");
            }
        }
        
        if($::gReportFormat && $::gReportFormat ne "" && $::gReportFormat ne "txt")
        {
            if($::gReportFormat eq 'xml'){
                $::gReportFormat .= '(doc)';
            }
            push(@args, "+".$::gReportFormat);
        }
        
        if($::gAdditionalCommands  && $::gAdditionalCommands  ne "") {
            foreach my $command (split(' +', $::gAdditionalCommands)) {
                push(@args, "$command");
            }
        }
        
        if($::gSourceCodeFiles && $::gSourceCodeFiles ne "")
        {
            push(@args,$::gSourceCodeFiles);
        }
        
        if($::gReportName && $::gReportName ne "")
        {
            push(@args, '> "' . $::gWorkingDir . '/' .$::gReportName . '"');
        }

        #generate the command to execute in console
        $props{"copyReportCommand"} = $copyReportCommand;
        $props{"commandLine"} = join(" ", @args);
        #in order to work properly the @prjtArgs must have at least 3 values in it.
        if(@prjtArgs >= 3)
        {
            $props{"projectCommandLine"} = join(" ", @prjtArgs);
        }
        else
        {
            $props{"projectCommandLine"} = "";
        }
        $props{"workingdir"} = $::gWorkingDir;

        registerReports();

        setProperties(\%props);

    }

    ########################################################################
    # setProperties - set a group of properties into the Electric Commander
    #
    # Arguments:
    #   -propHash: hash containing the ID and the value of the properties
    #              to be written into the Electric Commander
    #
    # Returns:
    #   -nothing
    #
    ########################################################################
    sub setProperties {

        my ($propHash) = @_;

        # get an EC object
        my $ec = new ElectricCommander();
        $ec->abortOnError(0);
        
        my $pluginKey = 'EC-Pclint';
        my $xpath = $ec->getPlugin($pluginKey);
        my $pluginName = $xpath->findvalue('//pluginVersion')->value;
        print "Using plugin $pluginKey version $pluginName\n";
        
        foreach my $key (keys %$propHash) {
            my $val = $propHash->{$key};
            $ec->setProperty("/myCall/$key", $val);
        }

    }

    ########################################################################
    # registerReports - creates a link for registering the generated report
    # in the job step detail
    #
    # Arguments:
    #   -none
    #
    # Returns:
    #   -nothing
    #
    ########################################################################
    sub registerReports{

        # get an EC object
        my $ec = new ElectricCommander();
        $ec->abortOnError(0);

        $ec->setProperty("/myJob/artifactsDirectory", "");

        #mkdir('artifacts-dir');
        #registerArtifactsDirectory($ec, "$[jobId]", 'artifacts-dir');

        if($::gReportName ne ""){
            $ec->setProperty("/myJob/report-urls/Pclint Report","jobSteps/$[jobStepId]/" . $::gReportName);
        }
    }

    main();
