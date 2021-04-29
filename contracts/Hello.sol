contract Hello {
    string public message = "hi";

    function setMessage(string memory _message) public {
        message = _message;
    }

    function sayHi() public view returns (string memory) {
        return message;
    }
}
