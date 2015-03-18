#if neko
import neko.Lib;
#elseif cpp
import cpp.Lib;
#end

class LDAP
{

	public static var SUCCESS = 0;
	public static var MOD_OP = 7;
	public static var MOD_ADD = 0;
	public static var MOD_DELETE = 1;
	public static var MOD_REPLACE = 2;
	public static var MOD_INCREMENT = 3;
	public static var MOD_BVALUES = 128;

	public static var OPT_PROTOCOL_VERSION = 0x0011;
	public static var OPT_REFERRALS = 0x0008;
	public static var OPT_DEBUG_LEVEL = 0x5001;	/* debug level */
	public static var OPT_NETWORK_TIMEOUT = 0x5005;	/* socket level timeout */

	public static var SCOPE_BASE = 0x0000;
	public static var SCOPE_BASEOBJECT = SCOPE_BASE;
	public static var SCOPE_ONELEVEL = 0x0001;
	public static var SCOPE_ONE = SCOPE_ONELEVEL;
	public static var SCOPE_SUBTREE = 0x0002;
	public static var SCOPE_SUB = SCOPE_SUBTREE;
	public static var SCOPE_SUBORDINATE = 0x0003; /* OpenLDAP extension */
	public static var SCOPE_CHILDREN = SCOPE_SUBORDINATE;
	public static var SCOPE_DEFAULT = -1; /* OpenLDAP extension */


	public var uri(default, null):String;
	public var connected(default, null):Bool = false;

	public function new(uri:String)
	{
		connected = false;
		handle = null;
		this.uri = uri;
	}

	public function setOption(option:Int, value:Dynamic):Bool
	{
		try
		{
			return nekoldap_set_option(handle, option, value);
		}
		catch (e:Dynamic)
		{
			throw nekoldap_err2string(e);
		}
	}

	public function bind(dn:String, password:String):Bool
	{
		try
		{
			handle = nekoldap_connect(uri);
			nekoldap_bind(handle, dn, password);
			connected = true;
			return true;
		}
		catch (e:Dynamic)
		{
			connected = false;
			throw nekoldap_err2string(e);
		}
	}

	public function unbind():Bool
	{
		try
		{
			connected = false;
			return nekoldap_unbind(handle);
		}
		catch (e:Dynamic)
		{
			throw nekoldap_err2string(e);
		}
	}

	public function search(baseDN:String, scope:Int, filter:String, attributes:Array<String>):Array<Dynamic>
	{
		try
		{
			return nekoldap_search(handle, baseDN, scope, filter, attributes, 0);
		}
		catch (e:Dynamic)
		{
			throw nekoldap_err2string(e);
		}
	}

	public function modify(dn:String, modifications:Dynamic):Void
	{
		try
		{
			return nekoldap_modify(handle, dn, modifications, MOD_REPLACE);
		}
		catch (e:Dynamic)
		{
			throw nekoldap_err2string(e);
		}
	}

	private static function load(func:String, numArgs:Int):Dynamic
	{
		#if neko
		if (!moduleInit)
		{
			// initialize neko
			var init = Lib.load("ldap", "neko_init", 5);
			if (init != null)
			{
				init(function(s) return new String(s), function(len:Int) { var r = []; if (len > 0) r[len - 1] = null; return r; }, null, true, false);
			}
			else
			{
				throw("Could not find NekoAPI interface.");
			}
			moduleInit = true;
		}
		#end
		return Lib.load("ldap", func, numArgs);
	}

	private var handle:Dynamic;

	private static var nekoldap_connect = load("nekoldap_connect", 1);
	private static var nekoldap_set_option = load("nekoldap_set_option", 3);
	private static var nekoldap_bind = load("nekoldap_bind", 3);
	private static var nekoldap_search = load("nekoldap_search", -1);
	private static var nekoldap_unbind = load("nekoldap_unbind", 1);
	private static var nekoldap_modify = load("nekoldap_modify", 4);
	private static var nekoldap_err2string = load("nekoldap_err2string", 1);
	#if neko
	private static var moduleInit:Bool = false;
	#end

}
