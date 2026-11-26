use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use Wx;
use DemoFrame;

package RoundTrip::Frame;
use parent -norequire, 'DemoFrame';

# wxGlade binds EVT_BUTTON to on_click on the actual frame object.
sub on_click {
    my ($self, $event) = @_;
    $self->{status}->SetLabel('Button clicked');
}

package RoundTrip::App;
use parent -norequire, 'Wx::App';

sub OnInit {
    my ($self) = @_;
    my $frame = RoundTrip::Frame->new();
    $self->SetTopWindow($frame);
    $frame->Show(1);
    return 1;
}

package main;
RoundTrip::App->new()->MainLoop();
