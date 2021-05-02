contract Roulette {
    enum BetType {Color, Number, Lower, Higher}

    struct Bet {
        address user;
        uint amount;
        BetType betType;
        uint block;
        int choice;
    }

    uint public constant NUM = 38;

    uint8[18] public RedNums = [
        1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 
        25, 27, 30, 32, 34, 36
    ];
    
    uint8[18] public BlackNums = [
        2, 4, 6, 8, 10, 11, 13, 15
        , 17, 20, 22, 24, 26, 28, 29, 31, 33, 35
    ];

    mapping(int => int) public COLORS;

    address public owner;
    uint public counter = 0;
    mapping(uint => Bet) public bets;

    event BetPlaced(address user, uint amount, BetType betType, uint block, int choice);
    event Spin(uint id, int landed);

    function Roulette() public {
        owner = msg.sender;
        for(uint i = 0; i < 18; i++) {
            COLORS[RedNums[i]] = 1;
        }
    }
    function bet(BetType betType, int choice) payable public {
        require(msg.value > 0);
        if(betType == BetType.Color)
            require(choice == 0 || choice == 1);
        else {
            require(choice >= -1 && choice <= 36);
        }
        counter ++;
        bets[counter] = Bet(msg.sender, msg.value, betType, block.number+3, choice);
        BetPlaced(msg.sender, msg.value, betType, block.number + 3, choice);
    }

    function spin(uint id) public {
        Bet storage bet = bets[id];

        require(msg.sender == bet.user);
        require(block.number >= bet.block);
        require(block.number < bet.block + 255);

        bytes32 random = keccak256(block.blockhash(bet.block), id);
        int landed = (uint(random) % NUM) - 1; 

        if(bet.betType == BetType.Color) {
            if(landed > 0 && COLORS[landed] == bet.choice)
                msg.sender.transfer(bet.amount * 2);
        }else if(bet.betType == BetType.Number) {
            if(landed == bet.choice) {
                msg.sender.transfer(bet.amount * 35);
            }
        }else if(bet.betType == BetType.Lower) {
            if(landed < bet.choice) {
                msg.sender.transfer(bet.amount * (38 / bet.amount));
            }
        }else {
            if(landed > bet.choice) {
                uint sub = 38 - bet.choice;
                //ne treba prover posto sam vec proverio u if statemenut
                //mislim na 0-u pri deljenju
                uint mul = 38 / sub;
                msg.sender.transfer(bet.amount * mul);
            }
        }
        delete bets[id];
        Spin(id, landed);
    }
    function fund() public payable {}

    function kill() public {
        require(msg.sedner == owner);

        selfdestruct(owner);
    }
}