my %runPclint = (
    label       => "Pclint - Code Analysis",
    procedure   => "runPclint",
    description => "Integrates Pclint code analysis into Electric Commander.",
    category    => "Code Analysis"
);

$batch->deleteProperty("/server/ec_customEditors/pickerStep/EC-Pclint - runPclint");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Pclint - Code Analysis");

@::createStepPickerSteps = (\%runPclint);
