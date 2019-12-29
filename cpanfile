requires 'perl', '5.026';

requires 'Data::Printer', '0.40';
requires 'List::AllUtils', '0.15';

on test => sub {
    requires 'Test::Spec', '0.54';   
}