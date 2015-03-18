class TestLdap extends haxe.unit.TestCase
{
	public function testConnect()
	{
		var ldap = new Ldap("ldap.forumsys.com");
		ldap.bind("cn=read-only-admin,dc=example,dc=com", "password");
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
