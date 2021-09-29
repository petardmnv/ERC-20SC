pragma solidity >=0.7.0 <0.9.0;

contract AdExICO {
	mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
	
	uint8 private constant decimals = 18;
    uint256 private constant totalSupply = 100000000;

    string private constant name = AdEx;
    string private constant symbol = ADX;
    
    uint256 private remainingETH;
    uint256 private startDate;
    uint256 private constant startDayEndDayDiff = 30;
	
    constructor (){
	    balances[msg.sender] = totalSupply;
	    remainingETH = 40000;
	    startDate = block.timestamp;
	}
	
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	event FundraiseEnd(uint256 _collectedETH);


	function getName() public pure returns (string memory){ return name; }
	function getCurrentTime() public view returns (uint256){ return block.timestamp; }
	function getStartData() public view returns (uint256){ return startDate; }
	function getSymbol() public pure returns (string memory){ return symbol; }
	function getDecimals() public pure returns (uint8){ return decimals; }
	function getTotalSupply() public pure returns (uint256){ return totalSupply; }
	function balanceOf(address _owner) public view returns (uint256){ return balances[_owner]; }
	function transfer(address _to, uint256 _amount) public returns (bool){
		require(_amount <= balances[msg.sender]);
		require(getDayDifference() < startDayEndDayDiff);
		remainingETH -= _amount;
		require(remainingETH > 0);
		balances[msg.sender] = balances[msg.sender] - _amount;
		balances[_to] += _amount;
		emit Transfer(msg.sender, _to, _amount);
		return true;
	}
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
		require(_value <= balances[_from]);
		require(_value <= allowances[_from][_to]);

		balances[_from] -= _value;
		balances[_to] += _value;
		allowances[_from][_to] -= _value;

		emit Transfer(_from, _to, _value);
		return true;
	}
	function approve(address _spender, uint256 _value) public  returns (bool success){
		allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;

	}
	function allowance(address _owner, address _spender) public view returns (uint256 remaining){
		return allowances[_owner][_spender]; 
	}
  
    function buyADX(address _from, uint256 _value) public payable returns(bool status){
        // from where people got their ETH's to us. 
        uint256 receiveTokens = getBonusTokens(convertEthToAdx(_value)); 
        transfer(_from, receiveTokens);
        return true;
    }
    
    function getDayDifference() public view returns (uint256){
        uint256 diff = (getCurrentTime() - startDate) / 60 / 60 / 24;
        return diff;
    }
    
   function getBonusTokens(uint256 _tokenAmount) public view returns (uint256){
        uint256 diff = getDayDifference();
        uint256 bonus = _tokenAmount;
        if (diff == 0){
            return bonus * 130 / 100;
        }else if(diff >=1 && diff < 7){
            return bonus * 115 / 100;
        }else {
            return bonus;
        }
    }
    
    function convertEthToAdx(uint256 _amount)public pure returns (uint256){
        return _amount * 900;
    }
    
    
    /*function fundraise() public{
        while (getDayDifference() < startDayEndDayDiff || remainingETH > 0){
            
        }
    }*/
    
    // After fundraise end we have to approve all token holders.
}
