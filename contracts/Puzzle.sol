contract SimplePuzzle {
    bytes32 public constant salt = bytes32(541495084);
    bytes32 public commitment;
    address public owner;

    function SimplePuzzle() public payable {
        owner = msg.sender;
    }

    function createCommitment(uint256 answer) public view returns (bytes32) {
        require(msg.sender == owner);
        return keccak256(salt, answer);
    }

    function guess(uint256 answer) public {
        require(createCommitment(answer) == commitment);
        require(commitment != bytes32(0));
        msg.sender.transfer(this.balance);
    }

    function() public payable {}
}
