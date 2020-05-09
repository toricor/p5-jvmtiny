requires 'Mouse', '2.5.9';
requires 'MouseX::Types', '0.06';

on develop => sub {
    requires 'Data::Printer', '0.40';
};

on test => sub {
    requires 'Test::Spec', '0.54';
};
