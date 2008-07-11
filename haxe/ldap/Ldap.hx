package ldap;

class Ldap {
	
	public static var SUCCESS = 0;
	
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
	
	private static var ldap_connect = neko.Lib.load("nekoldap", "nekoldap_connect",1);
	private static var ldap_bind = neko.Lib.load("nekoldap", "nekoldap_bind",3);
	private static var ldap_search = neko.Lib.load("nekoldap", "nekoldap_search",-1);
	private static var ldap_unbind = neko.Lib.load("nekoldap", "nekoldap_unbind",1);
	private static var ldap_get_entries = neko.Lib.load("nekoldap", "nekoldap_get_entries",2);
}