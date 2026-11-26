use strict;
use warnings;
use Test::More;
use File::Spec;
use File::Temp qw(tempdir);
use App::Martha;

my $parent = tempdir(CLEANUP => 1);
my $project = File::Spec->catdir($parent, 'GUI example');
is(App::Martha::create_example($project), $project, 'create working copy');
for my $name (qw(demo.wxg DemoFrame.pm app.pl)) {
    ok(-s File::Spec->catfile($project, $name), "copied $name");
}
my $app = File::Spec->catfile($project, 'app.pl');
open my $out, '>>', $app or die $!;
print {$out} "# developer edit\n";
close $out or die $!;
my $size = -s $app;
eval { App::Martha::create_example($project) };
like($@, qr/Cannot create new example directory/, 'refuse existing project');
is(-s $app, $size, 'preserve developer edit');
done_testing;
