package nekoldap;

class Ldap {
	
	public static var SUCCESS = 0;
	public static var MOD_OP = 7;
	public static var MOD_ADD = 0;
	public static var MOD_DELETE = 1;
	public static var MOD_REPLACE = 2;
	public static var MOD_INCREMENT = 3;
	public static var MOD_BVALUES = 128;
	
	public static var CONNST_NULL = 0;
	public static var CONNST_NEEDSOCKET = 1;
	public static var CONNST_CONNECTING = 2;
	public static var CONNST_CONNECTED = 3;

	public static var OPT_PROTOCOL_VERSION = 0x0011;
	public static var OPT_REFERRALS = 0x0008;
	public static var OPT_DEBUG_LEVEL = 0x5001;	/* debug level */
	public static var OPT_NETWORK_TIMEOUT = 0x5005;	/* socket level timeout */
	
	private var uri: String;
	private var connection: Dynamic;
	private var connected: Bool;
	
	public function new(uri: String) {
		connected = false;
		connection = null;
		this.uri = uri;
	}
	
	public function isConnected() {
		return connected;
	}
	
	public function setOption(option: Int, value: Dynamic): Bool {
		try {
			return nekoldap_set_option(connection, neko.Lib.haxeToNeko(option), neko.Lib.haxeToNeko(value));
		} catch (e: Int) {
			throw new LdapException(e, nekoldap_err2string(e));
			return false;
		}
	}

	public function bind(dn: String, password: String): Bool {
		try {
			connection = nekoldap_connect(neko.Lib.haxeToNeko(uri));
			nekoldap_bind(connection, neko.Lib.haxeToNeko(dn), neko.Lib.haxeToNeko(password));
			connected = true;
			return true;
		} catch (e: Int) {
			connected = false;
			throw new LdapException(e, nekoldap_err2string(e));
			return false;
		}
	}
	
	public function unbind(): Bool {
		try {
			connected = false;
			return nekoldap_unbind(connection);
		} catch (e: Int) {
			throw new LdapException(e, nekoldap_err2string(e));
			return false;
		}
	}
	

	public function search(baseDN: String, scope: Int, filter: String, attributes: Array<String>): Dynamic {
		try {
			return nekoldap_search(
				connection, 
				neko.Lib.haxeToNeko(baseDN), 
				scope, 
				neko.Lib.haxeToNeko(filter), 
				neko.Lib.haxeToNeko(attributes), 
				0);
		} catch (e: Int) {
			throw new LdapException(e, nekoldap_err2string(e));
			return false;
		}
	}
	
	public function getEntries(result: Dynamic): Dynamic {
		try {
			return nekoldap_get_entries(connection, result);
		} catch (e: Int) {
			throw new LdapException(e, nekoldap_err2string(e));
			return false;
		}
	}

	public function modify(dn: String, modifications: Dynamic) {
		try {
			return nekoldap_modify(connection, neko.Lib.haxeToNeko(dn), neko.Lib.haxeToNeko(modifications), MOD_REPLACE);
		} catch (e: Int) {
			throw new LdapException(e, nekoldap_err2string(e));
			return false;
		}
	}
	
	private static var nekoldap_connect = neko.Lib.load("nekoldap", "nekoldap_connect", 1);
	private static var nekoldap_set_option = neko.Lib.load("nekoldap", "nekoldap_set_option", 3);
	private static var nekoldap_bind = neko.Lib.load("nekoldap", "nekoldap_bind", 3);
	private static var nekoldap_search = neko.Lib.load("nekoldap", "nekoldap_search", -1);
	private static var nekoldap_unbind = neko.Lib.load("nekoldap", "nekoldap_unbind", 1);
	private static var nekoldap_get_entries = neko.Lib.load("nekoldap", "nekoldap_get_entries", 2);
	private static var nekoldap_modify = neko.Lib.load("nekoldap", "nekoldap_modify", 4);
	private static var nekoldap_err2string = neko.Lib.load("nekoldap", "nekoldap_err2string", 1);
}