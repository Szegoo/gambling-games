contract RNGLottery {
    uint256 public constant TICKET_PRICE = 1e16;

    address[] public tickets;
    address public winner;
    bytes32 public seed;
    mapping(address => bytes32) public commitments;

    uint256 public ticketDeadline;
    uint256 public revealDeadline;
    uint256 public drawBlock;

    uint256 public countingBlock;

    constructor(uint256 duration, uint256 revealDuration) public {
        ticketDeadline = block.number + duration;
        revealDeadline = ticketDeadline + revealDuration;
        drawBlock = revealDeadline + 5;
        countingBlock = block.number;
    }

    function createCommitment(address user, uint256 N)
        public
        pure
        returns (bytes32)
    {
        return keccak256(user, N);
    }

    function buy(bytes32 commitment) public payable {
        require(msg.value == TICKET_PRICE);
        require(block.number <= ticketDeadline);

        commitments[msg.sender] = commitment;
    }

    function reveal(uint256 N) public {
        require(block.number > ticketDeadline);
        require(block.number <= revealDeadline);

        bytes32 hash = createCommitment(msg.sender, N);
        require(hash == commitments[msg.sender]);

        seed = keccak256(seed, N);
        tickets.push(msg.sender);
    }

    function drawWinner() public {
        require(block.number > drawBlock);
        require(winner == address(0));

        uint256 randIndex = uint256(seed) % tickets.length;
        winner = tickets[randIndex];
    }

    function withdraw() public {
        require(msg.sender == winner);
        msg.sender.transfer(this.balance);
    }

    function blocksLeft() public view returns (uint256) {
        if (ticketDeadline + countingBlock <= block.number) {
            return block.number - (ticketDeadline + countingBlock);
        } else {
            return (ticketDeadline + countingBlock) - block.number;
        }
    }
}
