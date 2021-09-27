pragma solidity >=0.4.22 <0.9.0;

contract BasicERC20Contract {
	mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
	
	uint8 private constant decimals = 18;
    uint256 private constant totalSupply = 250;

    string private constant name = "Ali Express Tezos";
    string private constant symbol = "AET";
	
	constructor() public {
		
	}
	
	
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);


	function getName() public pure returns (string memory){ return name; }
	function getSymbol() public pure returns (string memory){ return symbol; }
	function getDecimals() public pure returns (uint8){ return decimals; }
	function getTotalSupply() public pure returns (uint256){ return totalSupply; }
	function balanceOf(address _owner) public view returns (uint256 balance){ return balances[_owner]; }
	function transfer(address _to, uint256 _value) public returns (bool success){
		success = false;
		require(_value <= balanceOf(msg.sender));
		balances[msg.sender] = balanceOf(msg.sender) - _value;
		balances[_to] = _value;
		success = true;
		return success;
	}
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
		success = false;
		require(_value <= balances[_from]);
		require(_value <= allowances[_from][_to]);

		balances[_from] -= _value;
		balances[_to] += _value;
		allowances[_from][_to] -= _value;

		emit Transfer(_from, _to, _value);

		success = true;
		return success;
	}
	function approve(address _spender, uint256 _value) public returns (bool success){
		allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;

	}
	function allowance(address _owner, address _spender) public view returns (uint256 remaining){
		return allowances[_owner][_spender]; 
	}
  
    
}
