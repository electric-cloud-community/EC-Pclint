@::gMatchers = (
    #invalid option
    {
        id =>       "lnt-invalid-option",
        pattern =>          q{Bad option (.*)},
        action =>           q{addSimpleError("lnt-invalid-option", "Invalid option: $1");updateSummary();},
    },
    #warning found
    {
        id =>       "lnt-warnings",
        pattern =>          q{Warning (\d+): (.*)},
        action =>           q{addSimpleError("lnt-warnings", "Warning $1: $2");updateSummary();},
    },
    #warning counter
    {
        id =>       "lnt-warnings-count",
        pattern =>          q{Warning (\d+): (.*)},
        action =>           q{incValueWithString("lnt-warnings-count", "0 warnings found");updateSummary();},
    },
    #Information messages
    {
        id =>       "lnt-information",
        pattern =>          q{Info (\d+): (.*)},
        action =>           q{addSimpleError("lnt-information", "Info $1: $2");updateSummary();},
    },
    #errors
    {
        id =>       "lnt-error",
        pattern =>          q{Error (\d+): (.*)},
        action =>           q{addSimpleError("lnt-error", "Error $1: $2");updateSummary();},
    },
);

sub addSimpleError {
    my ($name, $customError) = @_;
    if(!defined $::gProperties{$name}){
        setProperty($name, $customError);
    }
}

sub incValueWithString {
    my ($name, $patternString, $increment) = @_;

    $increment = 1 unless defined($increment);

    my $localString =
    (defined $::gProperties{$name})
    ? $::gProperties{$name}
    :$patternString;

    $localString =~ /([^\d]*)(\d+)(.*)/;
    my $leading = $1;
    my $numeric = $2;
    my $trailing = $3;

    $numeric += $increment;
    $localString = $leading . $numeric . $trailing;
    diagnostic($localString, "warning", backTo("Tagging "));
    setProperty($name, $localString);
}

sub updateSummary {

    my $summary = (defined $::gProperties{"lnt-invalid-option"}) ? $::gProperties{"lnt-invalid-option"} . "\n" : "";
    $summary .= (defined $::gProperties{"lnt-error"}) ? $::gProperties{"lnt-error"} . "\n" : "";
    $summary .= (defined $::gProperties{"lnt-warnings"}) ? $::gProperties{"lnt-warnings"} . "\n" : "";
    $summary .= (defined $::gProperties{"lnt-warnings-count"}) ? $::gProperties{"lnt-warnings-count"} . "\n" : "";
    $summary .= (defined $::gProperties{"lnt-information"}) ? $::gProperties{"lnt-information"} . "\n" : "";
    setProperty("summary", $summary);
}
