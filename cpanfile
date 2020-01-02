requires 'perl', '5.018';

requires 'Mouse', '2.5.9';

on develop => sub {
    requires 'Data::Printer', '0.40';
};

on test => sub {
    requires 'Test::Spec', '0.54';   
};