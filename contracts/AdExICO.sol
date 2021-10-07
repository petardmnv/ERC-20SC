// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;
import {SafeMath} from "./SafeMath.sol";

contract AdExICO {
    
    using SafeMath for uint256;
    
    address private owner;
    
    string private constant name = "AdEx";
    string private constant symbol = "ADX";
	
	uint private constant decimals = 18;
    uint256 private constant totalSupply = 100000000;
    uint256 private constant hardCap = 40000;
    uint256 private startDate;
    uint256 private constant startDayEndDayDiff = 30;
    
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    
    //Different token allocations(80% sale, 2% bounty, 2% for discovery, 10% team, 6% advisors)
    uint256 private tokenSupply = 80000000;
    uint256 private bountySupply = 2000000;
    uint256 private discoverySupply = 2000000;
    uint256 private teamSupply = 10000000;
    uint256 private advisorsSupply = 6000000;

    // Allowances for different allocations
    mapping(address => uint256) tokenSupplyAllowance;
    mapping(address => uint256) bountySupplyAllowance;
    mapping(address => uint256) discoverySupplyAllowance;
    mapping(address => uint256) teamSupplyAllowance;
    mapping(address => uint256) advisorsSupplyAllowance;
	
    constructor (){
	    startDate = block.timestamp;
        owner = msg.sender;
	}
	
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	event FundraiseEnd(uint256 _collectedETH);

    modifier ownable() {
        require(owner == msg.sender);
        _;
    }

    modifier daylimit(){
        require(getDayDifference() >= startDayEndDayDiff);
        _;
    }

	function getName() public pure returns (string memory){ return name; }
	function getSymbol() public pure returns (string memory){ return symbol; }
	function getDecimals() public pure returns (uint){ return decimals; }
	function getTotalSupply() public pure returns (uint256){ return totalSupply; }
	function getHardCap() public pure returns (uint256){ return hardCap; }
	function getCurrentTime() public view returns (uint256){ return block.timestamp; }
	function getStartData() public view returns (uint256){ return startDate; }
	function getStartDayEndDayDiff() public pure returns (uint256){ return startDayEndDayDiff; }
	function ownerWeiBalance() public view returns (uint256) { return address(this).balance; }
	function ownerEtherBalance() public view returns (uint256) { return address(this).balance.div(10**decimals); }
	function balanceOf(address _owner) public view returns (uint256){ return balances[_owner]; }
	
	
	function transfer(address _to, uint256 _amount) public daylimit returns (bool){
		require(_amount <= balances[msg.sender]);
		balances[msg.sender] = balances[msg.sender].sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		emit Transfer(msg.sender, _to, _amount);
		return true;
	}
	function transferFrom(address _from, address _to, uint256 _amount) public daylimit returns (bool){
		require(_amount <= balances[_from]);
		require(_amount <= allowances[_from][_to]);

		balances[_from] = balances[_from].sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		allowances[_from][_to] = allowances[_from][_to].sub(_amount);

		emit Transfer(_from, _to, _amount);
		return true;
	}
	function approve(address _spender, uint256 _amount) public daylimit returns (bool success){
		allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;

	}
	function allowance(address _owner, address _spender) public view returns (uint256 remaining){
		return allowances[_owner][_spender]; 
	}
  
    function buyADX() public payable daylimit returns(bool){
        require(msg.value >= 10**18);
        require(address(this).balance.div(10**decimals) <= hardCap);
        uint256 receiveTokens = getBonusTokens(convertEthToAdx(msg.value)); 
        addTokenSupplyAllowance(msg.sender, receiveTokens);
        transferFromTokenSupply(msg.sender, receiveTokens);
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
    
    
    // Functions for adding adress to one of the allowance arrays(Only if msg.sender is owner)
    function addTokenSupplyAllowance(address _newAddress, uint256 _amount) public returns(bool) {
        tokenSupplyAllowance[_newAddress] = _amount;
        return true;
    }
    function addBountySupplyAllowance(address _newAddress, uint256 _amount) public ownable returns(bool) {
        bountySupplyAllowance[_newAddress] = _amount;
        return true;
    }
    function addDiscoverySupplyAllowance(address _newAddress, uint256 _amount) public ownable returns(bool) {
        discoverySupplyAllowance[_newAddress] = _amount;
        return true;
    }
    function addTeamSupplyAllowance(address _newAddress, uint256 _amount) public ownable returns(bool) {
        teamSupplyAllowance[_newAddress] = _amount;
        return true;
    }
    function addAdvisorsSupplyAllowance(address _newAddress, uint256 _amount) public ownable returns(bool) {
        advisorsSupplyAllowance[_newAddress] = _amount;
        return true;
    }
    
    
    // Spend tokens for different allocations(Only if msg.sender has allowance)
    function transferFromTokenSupply(address _to, uint256 _amount) private returns (bool){
        require(tokenSupplyAllowance[_to] >= _amount);
        require(tokenSupply >= _amount);
        tokenSupply = tokenSupply.sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		tokenSupplyAllowance[_to] = tokenSupplyAllowance[_to].sub(_amount);
		emit Transfer(address(this), _to, _amount);
		return true;
    }
    function transferFromBountySupply(address _to, uint256 _amount) public daylimit returns (bool){
        require(bountySupplyAllowance[_to] >= _amount);
        require(bountySupply >= _amount);
        bountySupply = bountySupply.sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		bountySupplyAllowance[_to] = bountySupplyAllowance[_to].sub(_amount);
		emit Transfer(address(this), _to, _amount);
		return true;
    }
    function transferFromDiscoverySupply(address _to, uint256 _amount) public daylimit returns (bool){
        require(discoverySupplyAllowance[_to] >= _amount);
        require(discoverySupply >= _amount);
        discoverySupply = discoverySupply.sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		discoverySupplyAllowance[_to] = discoverySupplyAllowance[_to].sub(_amount);
		emit Transfer(address(this), _to, _amount);
		return true;
    }
    function transferFromTeamSupply(address _to, uint256 _amount) public daylimit returns (bool){
        require(teamSupplyAllowance[_to] >= _amount);
        require(teamSupply >= _amount);
        teamSupply = teamSupply.sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		teamSupplyAllowance[_to] = teamSupplyAllowance[_to].sub(_amount);
		emit Transfer(address(this), _to, _amount);
		return true;
    }
    function transferFromAdvisorsSupply(address _to, uint256 _amount) public daylimit returns (bool){
        require(advisorsSupplyAllowance[_to] >= _amount);
        require(advisorsSupply >= _amount);
        advisorsSupply = advisorsSupply.sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		advisorsSupplyAllowance[_to] = advisorsSupplyAllowance[_to].sub(_amount);
		emit Transfer(address(this), _to, _amount);
		return true;
    }
}
