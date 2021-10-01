pragma solidity >=0.7.0 <0.9.0;

contract AdExICO {
    
    using SafeMath for uint256;
    
    string private constant name = "AdEx";
    string private constant symbol = "ADX";
	
	uint8 private constant decimals = 18;
    uint256 private constant totalSupply = 100000000;
    uint256 private constant hardCap = 40000;
    uint256 private startDate;
    uint256 private constant startDayEndDayDiff = 30;
    
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    
    //Different token allocations(80% sale, 2% bounty, 2% for discovery, 10% team, 6% advisors)
    uint256 private tokenSupply = 100;
    uint256 private bountySupply = 2000000;
    uint256 private discoverySupply = 2000000;
    uint256 private teamSupply = 10000000;
    uint256 private advisorsSupply = 6000000;

    // Allowances for different allocations
    address[] tokenSupplyAllowance;
    address[] bountySupplyAllowance;
    address[] discoverySupplyAllowance;
    address[] teamSupplyAllowance;
    address[] advisorsSupplyAllowance;
	
    constructor (){
	    startDate = block.timestamp;
	}
	
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	event FundraiseEnd(uint256 _collectedETH);

	function getName() public pure returns (string memory){ return name; }
	function getSymbol() public pure returns (string memory){ return symbol; }
	function getDecimals() public pure returns (uint8){ return decimals; }
	function getTotalSupply() public pure returns (uint256){ return totalSupply; }
	function getHardCap() public pure returns (uint256){ return hardCap; }
	function getCurrentTime() public view returns (uint256){ return block.timestamp; }
	function getStartData() public view returns (uint256){ return startDate; }
	function getStartDayEndDayDiff() public pure returns (uint256){ return startDayEndDayDiff; }
	function ownerWeiBalance() public view returns (uint256) { return address(this).balance; }
	function ownerEtherBalance() public view returns (uint256) { return address(this).balance.div(10**18); }
	function balanceOf(address _owner) public view returns (uint256){ return balances[_owner]; }

	
	function transfer(address _to, uint256 _amount) public returns (bool){
		require(_amount <= balances[msg.sender]);
		balances[msg.sender] = balances[msg.sender].sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		emit Transfer(msg.sender, _to, _amount);
		return true;
	}
	function transferFrom(address _from, address _to, uint256 _amount) public returns (bool){
		require(_amount <= balances[_from]);
		require(_amount <= allowances[_from][_to]);

		balances[_from] = balances[_from].sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		allowances[_from][_to] = allowances[_from][_to].sub(_amount);

		emit Transfer(_from, _to, _amount);
		return true;
	}
	function approve(address _spender, uint256 _amount) public  returns (bool success){
		allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;

	}
	function allowance(address _owner, address _spender) public view returns (uint256 remaining){
		return allowances[_owner][_spender]; 
	}
  
    function buyADX() public payable returns(bool){
        require(getDayDifference() < getStartDayEndDayDiff);
        require(msg.value >= 1);
        require(hardCap >= msg.value);
        uint256 receiveTokens = getBonusTokens(convertEthToAdx(msg.value)); 
        transferTokensFromGenesisBlock(msg.sender, receiveTokens);
        return true;
    }
    
    function getDayDifference() public view returns (uint256){
        return (getCurrentTime().sub(startDate)).div(60).div(60).div(24);
    }
    
   function getBonusTokens(uint256 _amount) public view returns (uint256){
        uint256 diff = getDayDifference();
        uint256 bonus = _amount;
        if (diff == 0){
            return bonus.mul(130).div(100);
        }else if(diff >= 1 && diff < 7){
            return bonus.mul(115).div(100);
        }
        return bonus;
    }
    
    function convertEthToAdx(uint256 _amount)public pure returns (uint256){
        return _amount.div(10 ** 18).mul(900);
    }
    
    function transferTokensFromGenesisBlock(address _to, uint256 _amount) private returns (bool){
        tokenSupply = tokenSupply.sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		emit Transfer(address(this), _to, _amount);
		return true;
    }
    
    // After fundraise end we have to approve all token holders.
}


library SafeMath{
    function add(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) public pure returns (uint c ) {
        c = a * b; 
        require(a == 0 || c / a == b);
    } 
    function div(uint a, uint b) public pure returns (uint c ) {
        require(b > 0);
        c = a / b;
    
    }
}
