using GLib;
using Gtk;
using ValaPanel;

namespace LaunchBar
{
    private const string BOOTSTRAP = "launchbar-bootstrap";
    public enum ButtonType
    {
        NONE,
        DESKTOP,
        EXECUTABLE,
        URI,
        BOOTSTRAP
    }
    private class Button: FlowBoxChild
    {
        public string id {get; private set construct;}
        public string uri {private get; construct;}
        internal int icon_size {get; set;}
        public string content_type {private get; construct;}
        public AppInfo info {private get; construct;}
        public ButtonType button_type {private get; public construct;}
        internal Button(AppInfo? info, string? uri, ButtonType type)
        {
            Object(info: info, uri: uri, button_type: type);
        }
        internal Button.with_content_type(AppInfo? info, string? uri, ButtonType type, string content_type)
        {
            Object(info: info, uri: uri, button_type: type, content_type: content_type);
        }
        construct
        {
            var commit = false;
            var ebox = new EventBox();
            Icon? icon;
            get_style_context().remove_class("grid-child");
            PanelCSS.apply_from_resource(this,"/org/vala-panel/lib/style.css","-panel-launch-button");
            if (uri != null)
                id = uri;
            if (content_type != null && button_type != ButtonType.DESKTOP)
                icon = ContentType.get_icon(content_type);
            else if (info != null)
            {
                id = info.get_id();
                icon = info.get_icon();
            }
            else if (button_type == ButtonType.BOOTSTRAP)
            {
                id = BOOTSTRAP;
                icon = new ThemedIcon.with_default_fallbacks("list-add-symbolic");
            }
            Image img = new Image();
            if (icon == null)
                icon = info.get_icon();
            setup_icon(img,icon,null,24);
            this.bind_property("icon-size",img,"pixel-size",BindingFlags.DEFAULT|BindingFlags.SYNC_CREATE);
            ebox.enter_notify_event.connect((e)=>{
                this.get_style_context().add_class("-panel-launch-button-selected");
            });
            ebox.leave_notify_event.connect((e)=>{
                this.get_style_context().remove_class("-panel-launch-button-selected");
            });
            ebox.show();
            drag_source_set(this,Gdk.ModifierType.BUTTON2_MASK,MenuMaker.menu_targets,Gdk.DragAction.MOVE);
            drag_source_set_icon_gicon(this,icon);
            this.drag_begin.connect((context)=>{
                this.get_launchbar().request_remove_id(id);
            });
            this.drag_data_get.connect((context,data,type,time)=>{
                var uri_list = new string[1];
                uri_list[0]=id;
                data.set_uris(uri_list);
            });
            this.drag_data_delete.connect((context)=>{
                commit = true;
            });
            this.drag_failed.connect((context,result)=>{
                if (!(result == Gtk.DragResult.USER_CANCELLED))
                    commit = true;
            });
            this.drag_end.connect((context)=>{
                if (commit)
                    this.get_launchbar().commit_ids();
                else
                    this.get_launchbar().undo_removal_request();
            });
            ebox.add(img);
            this.add(ebox);
        }
        internal void launch()
        {
            if (button_type == ButtonType.BOOTSTRAP)
            {
                this.get_launchbar().show_applet_dlg("desktop");
                return;
            }
            var context = this.get_toplevel().get_display().get_app_launch_context();
            try
            {
                if (uri != null && button_type == ButtonType.URI)
                {
                    List<string> uri_l = new List<string>();
                    uri_l.append(uri);
                    info.launch_uris(uri_l,context);
                }
                else
                    info.launch(null,context);
            } catch (GLib.Error e) {stderr.printf("%s",e.message);}
        }
        private Launchbar get_launchbar()
        {
            return this.get_parent().get_parent() as Launchbar;
        }
    }
}
