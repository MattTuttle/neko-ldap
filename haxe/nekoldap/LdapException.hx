package nekoldap;

class LdapException {
	private var code: Int;
	private var text: String;
	
	public function new(code: Int, text: String) {
		this.code = code;
		this.text = text;
	}
	
	public function getCode() {
		return code;
	}
	
	public function getText() {
		return text;
	}
	
}
