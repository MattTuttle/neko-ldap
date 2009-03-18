package nekoldap;

class Ldap {
	
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

	/* OpenLDAP TLS options */
	public static var LDAP_OPT_X_TLS = 0x6000;
	public static var LDAP_OPT_X_TLS_CTX = 0x6001;/* SSL CTX */
	public static var LDAP_OPT_X_TLS_CACERTFILE = 0x6002;
	public static var LDAP_OPT_X_TLS_CACERTDIR = 0x6003;
	public static var LDAP_OPT_X_TLS_CERTFILE = 0x6004;
	public static var LDAP_OPT_X_TLS_KEYFILE = 0x6005;
	public static var LDAP_OPT_X_TLS_REQUIRE_CERT = 0x6006;

	public static var LDAP_OPT_X_TLS_CIPHER_SUITE = 0x6008;
	public static var LDAP_OPT_X_TLS_RANDOM_FILE = 0x6009;
	public static var LDAP_OPT_X_TLS_SSL_CTX = 0x600a;
	public static var LDAP_OPT_X_TLS_CRLCHECK = 0x600b;
	public static var LDAP_OPT_X_TLS_CONNECT_CB = 0x600c;
	public static var LDAP_OPT_X_TLS_CONNECT_ARG = 0x600d;
	public static var LDAP_OPT_X_TLS_DHFILE =  = 0x600e;

	public static var LDAP_OPT_X_TLS_NEVER = 0;
	public static var LDAP_OPT_X_TLS_HARD = 1;
	public static var LDAP_OPT_X_TLS_DEMAND = 2;
	public static var LDAP_OPT_X_TLS_ALLOW = 3;
	public static var LDAP_OPT_X_TLS_TRY = 4;

	public static var LDAP_OPT_X_TLS_CRL_NONE = 0
	public static var LDAP_OPT_X_TLS_CRL_PEER = 1
	public static var LDAP_OPT_X_TLS_CRL_ALL = 2
	
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
	
	public function getEntries(result: Dynamic) {
		try {
			return nekoldap_get_entries(connection, result);
		} catch (e: Int) {
			throw new LdapException(e, nekoldap_err2string(e));
		}
	}

	public function modify(dn: String, modifications: Dynamic) {
		try {
			return nekoldap_modify(connection, neko.Lib.haxeToNeko(dn), neko.Lib.haxeToNeko(modifications), MOD_REPLACE);
		} catch (e: Int) {
			throw new LdapException(e, nekoldap_err2string(e));
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