contract Ponzi {
    address[] public investors;
    mapping(address => uint256) public balances;
    uint256 public constant MINIMUM_INVESTMENT = 1e15;

    constructor() public {
        investors.push(msg.sender);
    }

    function() public payable {
        require(msg.value >= MINIMUM_INVESTMENT);
        uint256 eachInvestorGets = msg.value / investors.length;

        for (uint256 i = 0; i < investors.length; i++) {
            balances[investors[i]] += eachInvestorGets;
        }
        investors.push(msg.sender);
    }

    function withdraw() public {
        uint256 payout = balances[msg.sender];
        balances[msg.sedner] = 0;
        msg.sender.transfer(payout);
    }
}
