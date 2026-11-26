import os, sys, traceback
sys.path.insert(0, os.path.abspath("wxGlade"))
project = os.path.join(os.path.abspath("roundtrip"), "demo.wxg")
revise = "revise" in sys.argv
sys.argv = [os.path.abspath("wxGlade/wxglade.py"), project]
import wxglade
options = wxglade.parse_command_line()
wxglade.init_stage1(options)
wxglade.init_stage2(True)
import wx, main, common, config
common.history = main.history.History()
app = main.wxGlade()
def exercise():
    try:
        win = app.GetTopWindow()
        assert win._open_app(project, False)
        frame = common.root.children[0]
        frame.create()
        def walk(widget):
            yield widget
            for child in getattr(widget, "children", []):
                yield from walk(child)
        button = next(w for w in walk(frame) if getattr(w,"name",None)=="button")
        print("Designer opened", project, "button:", button.label, flush=True)
        if revise:
            button.properties["label"].set("Try it again")
            button.properties["border"].set(20)
            button.properties_changed(["label", "border"])
        config.preferences.show_completion = False
        win.save_app()
        common.root.generate_code()
        print("Designer saved and regenerated", button.label, flush=True)
    except BaseException:
        traceback.print_exc()
        os._exit(1)
    app.ExitMainLoop()
wx.CallLater(350, exercise)
app.MainLoop()
