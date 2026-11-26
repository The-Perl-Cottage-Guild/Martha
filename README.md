# App::Martha

Run `martha` in a wxPerl-enabled Strawberry Perl environment to open the Windows packaging helper. The existing File menu opens or saves a Martha packaging project. A wxGlade design is a separate file.

## Try a wxGlade round trip

In the selected PGDEM environment's command prompt, install the release and create a working copy in a new directory:

```bat
perl -S cpanm https://github.com/The-Perl-Cottage-Guild/Martha/releases/download/v0.003/App-Martha-0.003.tar.gz
perl -MApp::Martha -MWx -e "print qq(Perl: $^X\nMartha: $App::Martha::VERSION at $INC{'App/Martha.pm'}\nWx: $Wx::VERSION\n)"
martha --example roundtrip
cd roundtrip
perl app.pl
```

Click **Click me**. The status changes from **Ready** to **Button clicked**. Close the app before the next run.

| File | What to do with it |
| --- | --- |
| `demo.wxg` | Open it in wxGlade 1.1.1 to edit the layout and event names. |
| `DemoFrame.pm` | wxGlade writes the widgets and event bindings here each time you generate Perl. |
| `app.pl` | Run this file and edit its `RoundTrip::Frame` subclass for behavior. Its `on_click` overrides the generated stub. |

In wxGlade, select the button in the tree. Change its label to **Try it again** and its sizer border from **8** to **20**. Keep the event name `on_click`. Save the design and choose **Generate Code**. You can also generate from the saved design with `wxglade -g perl demo.wxg`. Run `perl app.pl` again. The button moves and takes its new caption. Clicking it still updates the status.

For a new event, name the handler in wxGlade and implement that method in the subclass in `app.pl`. The checked-in example includes the initial generated frame, so the first run only needs the selected Perl and Wx.
