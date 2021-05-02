contract SatoshiDice {
    struct Bet {
        address user;
        uint amount;
        uint cap;
        uint blockNum;
    }
    uint public constant fee_numerator = 1;
    uint public constant fee_denominator = 100;

    uint public constant maximumCap = 100000;
    uint public constant maximumBet = 1e18;

    address public owner;
    uint public counter = 0;
    mapping(uint => Bet) public bets;
    event BetPlaced(address user, uint amount, uint id, uint cap);
    event Roll(address user, uint number, uint payout);

    function SatoshiDice() public {
        owner = msg.sender;
    }

    function bet(uint cap) public payable {
        require(cap <= maximumCap);
        require(msg.value <= maximumBet);
        require(msg.value > 0);
        counter++;
        bets[counter] = Bet(msg.sender, msg.value, cap, counter);
        BetPlaced(msg.sender, msg.value, block.number + 3, cap);
    } 
    function roll(uint id) public {
        Bet storage bet = bets[id];
        require(msg.sender == bet.user);
        require(block.number >= bet.blockNum);
        require(block.number <= bet.blockNum + 255);

        bytes32 random = keccak256(block.blockhash(bet.blockNum), id);
        uint rolled = uint(random) % maximumCap;

        if(rolled < bet.cap) {
            uint payout = bet.amount * (maximumCap / bet.cap);
            uint fee = payout * (fee_numerator / fee_denominator);
            payout -= fee;
            owner.transfer(fee);
            msg.sender.transfer(payout);
        }
        Roll(msg.sender, cap, payout);
        delete best[id];
    }
    function () external payable {}

    function kill() public {
        require(msg.sender == owner);

        selfdestruct(owner);
    }
}
