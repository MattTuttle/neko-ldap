class TestLdap extends haxe.unit.TestCase
{
	public function testConnect()
	{
		var ldap = new LDAP("ldap://whitepages.gatech.edu");
		ldap.bind("", "");
		assertTrue(ldap.connected);
	}

	public function testSearch()
	{
		var ldap = new LDAP("ldap://whitepages.gatech.edu");
		ldap.bind("", "");
		var result = ldap.search("dc=whitepages,dc=gatech,dc=edu", LDAP.SCOPE_SUB, "mail=jim.oconnor@oit.gatech.edu", []);
		assertEquals("0700", result[0].postalAddress[0]);
	}

}

class TestMain
{

	static public function main()
	{
		var test = new haxe.unit.TestRunner();
		test.add(new TestLdap());
		test.run();
	}

}
