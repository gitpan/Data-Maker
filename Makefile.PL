use ExtUtils::MakeMaker;

WriteMakefile( 
        'VERSION'   => 0.01,
        'NAME'      => 'Data::Maker',
        'PREREQ_PM' => {
          'Moose' => 0,
          'Text::GenderFromName' => 0,
        }
);
