package nekoldap;

class Ldap {
	
	public static var SUCCESS = 0;
	public static var MOD_OP = 7;
	public static var MOD_ADD = 0;
	public static var MOD_DELETE = 1;
	public static var MOD_REPLACE = 2;
	public static var MOD_INCREMENT = 3;
	public static var MOD_BVALUES = 128;
	
	private var connection: Dynamic;
	
	public function new(uri: String) {
		connection = ldap_connect(neko.Lib.haxeToNeko(uri));
	}
	
	public function bind(dn: String, password: String): Bool {
		return ldap_bind(connection, neko.Lib.haxeToNeko(dn), neko.Lib.haxeToNeko(password));
	}
	
	public function unbind(): Bool {
		return ldap_unbind(connection);
	}
	
	public function search(baseDN: String, scope: Int, filter: String, attributes: Array<String>): Dynamic {
		return ldap_search(
			connection, 
			neko.Lib.haxeToNeko(baseDN), 
			scope, 
			neko.Lib.haxeToNeko(filter), 
			neko.Lib.haxeToNeko(attributes), 
			0);
	}
	
	public function getEntries(result: Dynamic): Dynamic {
		return ldap_get_entries(connection, result);
	}

	public function modify(dn: String, modifications: Dynamic) {
		try {
			return ldap_modify(connection, neko.Lib.haxeToNeko(dn), neko.Lib.haxeToNeko(modifications), MOD_REPLACE);
		} catch (e: Int) {
			trace(ldap_err2string(e));
			return false;
		}
	}
	
	private static var ldap_connect = neko.Lib.load("nekoldap", "nekoldap_connect", 1);
	private static var ldap_bind = neko.Lib.load("nekoldap", "nekoldap_bind", 3);
	private static var ldap_search = neko.Lib.load("nekoldap", "nekoldap_search", -1);
	private static var ldap_unbind = neko.Lib.load("nekoldap", "nekoldap_unbind", 1);
	private static var ldap_get_entries = neko.Lib.load("nekoldap", "nekoldap_get_entries", 2);
	private static var ldap_modify = neko.Lib.load("nekoldap", "nekoldap_modify", 4);
	private static var ldap_err2string = neko.Lib.load("nekoldap", "nekoldap_err2string", 1);
}