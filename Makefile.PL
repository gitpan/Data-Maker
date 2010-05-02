use ExtUtils::MakeMaker;

WriteMakefile( 
        'VERSION'   => 0.20,
        'NAME'      => 'Data::Maker',
        'PREREQ_PM' => {
          'Moose' => 0,
          'DateTime::Event::Random' => 0,
          'Text::GenderFromName' => 0,
          'Text::Lorem' => 0,
        }
);
