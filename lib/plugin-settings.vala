using GLib;

namespace ValaPanel
{
	private static const string PLUGIN_SCHEMA = "org.simple.panel.toplevel.plugin";
	private static const string PANEL_SCHEMA = "org.simple.panel.toplevel";
	private static const string PANEL_PATH = "/org/simple/panel/toplevel/";
	private static const string ROOT_NAME = "toplevel-settings";

	namespace Key
	{
		private static const string NAME = "plugin-type";
		private static const string SCHEMA = "has-schema";
		internal static const string EXPAND = "is-expanded";
		private static const string CAN_EXPAND = "can-expand";
		internal static const string PADDING = "padding";
		internal static const string BORDER = "border";
		internal static const string POSITION = "position";
	}
	
	internal class PluginSettings : GLib.Object
	{
		internal string path_append;
		internal GLib.Settings default_settings;
		internal GLib.Settings config_settings;
		internal uint number;

		internal PluginSettings(ToplevelSettings settings, string name, uint num)
		{
			this.number = num;
			this.path_append = name;
			var path = "%s%u/".printf(settings.root_path,this.number); 
			this.default_settings = new GLib.Settings.with_backend_and_path(
				                                PLUGIN_SCHEMA, settings.backend, path);
		}
		internal void init_configuration(ToplevelSettings settings, bool has_config)
		{
			default_settings.set_boolean(Key.SCHEMA,has_config);
			if (has_config)
			{
				var id = "%s.%s".printf(settings.root_name, this.path_append);
				var path = "%s%u/".printf(settings.root_path,this.number);
				this.config_settings = new GLib.Settings.with_backend_and_path(
				                                id, settings.backend, path);
			}
		}
	}

	internal class ToplevelSettings : GLib.Object
	{
		private GLib.SList<PluginSettings> _plugins;
		private GLib.Settings _settings;
		private string _filename;
		private GLib.SettingsBackend _backend;
		private string _root_name;
		private string _root_path;
		internal GLib.SList<PluginSettings> plugins {
			get {return _plugins;}
		}
		internal GLib.Settings settings {
			get {return _settings;}
		}
		internal GLib.SettingsBackend backend {
			get {return _backend;}
		}
		internal string filename {
			get {return _filename;}
		}
		internal string root_name {
			get {return _root_name;}
		}		
		internal string root_path {
			get {return _root_path;}
		}
		
		internal ToplevelSettings.full(string file, string schema, string path, string? root)
		{
			this._filename = file;
			this._root_name = root;
			this._root_path = path;
			_backend = GLib.keyfile_settings_backend_new(file,path,root);
			_settings = new GLib.Settings.with_backend_and_path (schema,backend,path);
		}

		internal ToplevelSettings (string file)
		{
			ToplevelSettings.full(file,PANEL_SCHEMA,PANEL_PATH,ROOT_NAME);
		}

		internal uint find_free_num()
		{
			var f = new GLib.KeyFile();
			try{
			f.load_from_file(this._filename,GLib.KeyFileFlags.KEEP_COMMENTS);
			} catch (GLib.KeyFileError e) {} catch (GLib.FileError e) {}
			var numlist = new GLib.SList<uint>();
			var len = f.get_groups().length;
			foreach (var grp in f.get_groups())
			{
				if (grp == this._root_name)
					continue;
				CompareFunc<uint> intcmp = (a, b) => {
					return (int) (a > b) - (int) (a < b);
				};
				numlist.insert_sorted(int.parse(grp),intcmp);
			}
			for (var i = 0; i < len; i++)
				if (i > numlist.nth_data(i))
					return i;
			return len;
		}
		
		internal PluginSettings add_plugin_settings_full(string name, uint num)
		{
			var settings = new PluginSettings(this,name,num);
			_plugins.append(settings);
			return settings;
		}

		internal PluginSettings add_plugin_settings(string name)
		{
			var num = find_free_num ();
			var settings = new PluginSettings(this,name,num);
			_plugins.append(settings);
			return settings;
		}
		
		internal void remove_plugin_settings(uint num)
		{
			foreach (var tmp in _plugins)
			{
				if (tmp.number == num)
				{
					_plugins.remove(tmp);
					var f = new GLib.KeyFile();
					try
					{
						f.load_from_file(this._filename,GLib.KeyFileFlags.KEEP_COMMENTS);
						if (f.has_group(num.to_string()))
						{
							f.remove_group(num.to_string());
							f.save_to_file(this._filename);
						}
					}
					catch (GLib.KeyFileError e) {} catch (GLib.FileError e) {}
				}
			}
		}
		internal bool init_plugin_list()
		{
			if (_plugins != null)
				return false;
			var f = new GLib.KeyFile();
			try {
				f.load_from_file(this._filename,GLib.KeyFileFlags.KEEP_COMMENTS);
			}
			catch (GLib.KeyFileError e) {} catch (GLib.FileError e) {}
			var groups = f.get_groups();
			foreach (var group in groups)
			{
				try 
				{
					var name = f.get_string(group,Key.NAME);
					name.strip();
					name.delimit("'",' ');
					var config = f.get_boolean(group,Key.SCHEMA);
					var s = add_plugin_settings_full(name,int.parse(name));
					s.init_configuration(this,config);
				}
				catch (GLib.KeyFileError e)
				{
					try{
						f.remove_group(group);
					} catch (GLib.KeyFileError e) {}
				}
			}
			return true;
		}
		internal PluginSettings? get_settings_by_num(uint num)
		{
			foreach (var pl in _plugins)
				if (pl.number == num)
					return pl;
			return null;
		}
	}
}