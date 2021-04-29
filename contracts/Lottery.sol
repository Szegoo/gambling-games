contract SimpleLottery {
    uint256 public constant TICKET_PRICE = 1e16;

    address[] public tickets;
    address public winner;
    uint256 public ticketingCloses;

    function SimpleLottery(uint256 duration) public {
        ticketingCloses = now + duration;
    }

    function buy() public payable {
        require(msg.value == TICKET_PRICE);
        require(now < ticketingCloses);

        tickets.push(msg.sender);
    }

    function drawWinner() public {
        require(now > ticketingCloses + 1 minutes);
        require(winner == address(0));

        bytes32 rand = keccak256(block.blockhash(block.number - 1));
        winner = tickets[uint256(rand) % tickets.length];
    }

    function withdraw() public {
        require(msg.sender == winner);
        msg.sender.transfer(this.balance);
    }

    function() external payable {
        buy();
    }
}

contract Lottery {
    struct Round {
        uint256 endBlock;
        uint256 drawBlock;
        Entry[] entries;
        uint256 totalQuantity;
        address winner;
    }
    struct Entry {
        address buyer;
        uint256 quantity;
    }
    uint256 constant TICKET_PRICE = 1e16;
    mapping(uint256 => Round) public rounds;
    uint256 public round;
    uint256 public duration;
    mapping(address => uint256) public balances;

    function Lottery(uint256 _duration) public {
        duration = _duration;
        round = 1;
        rounds[round].endBlock = block.number + duration;
        rounds[round].drawBlock = block.number + duration + 5;
    }

    function buy() public payable {
        require(msg.value % TICKET_PRICE == 0);
        if (block.number > rounds[round].endBlock) {
            round += 1;
            rounds[round].endBlock = block.number + duration;
            rounds[round].drawBlock = block.number + duration + 5;
        }
        uint256 quantity = msg.value / TICKET_PRICE;
        Entry memory entry = Entry(msg.sender, quantity);
        rounds[round].entries.push(entry);
        rounds[round].totalQuantity += quantity;
    }

    function drawWinner(uint256 roundNumber) public {
        Round storage drawing = rounds[roundNumber];
        require(drawing.winner == address(0));
        require(block.number > drawing.drawBlock);
        require(drawing.entries.length > 0);

        bytes32 rand = keccak256(block.blockhash(drawing.drawBlock));
        uint256 counter = uint256(rand) % drawing.totalQuantity;
        for (uint256 i = 0; i < drawing.entries.length; i++) {
            uint256 quantity = drawing.entries[i].quantity;
            if (quantity > counter) {
                drawing.winner = drawing.entries[i].buyer;
                break;
            } else {
                counter -= quantity;
            }
        }
        balances[drawing.winner] += TICKET_PRICE * drawing.totalQuantity;
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function deleteRound(uint256 _round) public {
        require(block.number > rounds[_round].drawBlock + 100);
        require(rounds[_round].winner != address(0));
        delete rounds[_round];
    }

    function() external payable {
        buy();
    }
}
