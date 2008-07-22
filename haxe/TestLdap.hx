import nekoldap.Ldap;

class TestLdap {
    static function main() {
		var ldap = new Ldap("ldaps://lena.qwe.local");
//		ldap.bind("ivan@qwe.local", "~123qweasd");
		ldap.bind("kg@qwe.local", "");
		var result = ldap.search("cn=users,dc=qwe,dc=local", 2, "(&(objectclass=user)(samaccountname=ivan))", ["name", "userprincipalname", "distinguishedname", "samaccountname"]);
		var entries = ldap.getEntries(result);
		ldap.modify("CN=Иван И. Иванов,CN=Users,DC=qwe,DC=local", { unicodePwd: "\"~Password2000\"" } );
		ldap.unbind();
		
		neko.Lib.println("name = " + entries[0].name[0]);
		neko.Lib.println("userprincipalname = " + entries[0].userprincipalname[0]);
		neko.Lib.println("distinguishedname = " + entries[0].distinguishedname[0]);
		neko.Lib.println("samaccountname = " + entries[0].samaccountname[0]);
	}
}