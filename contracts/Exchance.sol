interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mint(address account, uint256 amount) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Banka {
    IERC20 public token;
    address public  owner;
    uint fee_numerator = 10;
    uint fee_denumerator = 10;

    uint rate = 1;
    
    mapping(address => uint) balances;

    constructor(address adresa) public {
        owner = msg.sender;
        token = IERC20(adresa);
    }

    function buy(address buyer) public payable {
        require(msg.value > 0);
        uint amountInWei = msg.value;
        //uint amount = calculateAmount(amountInWei);
        token.mint(buyer, amountInWei);
        payable(address(token)).transfer(msg.value);
        balances[buyer] = amountInWei;
    }
    function calculateAmount(uint amountInWei) public view returns(uint) {
        uint amount = amountInWei * rate;
        uint feeAmount = amount * (fee_numerator/fee_denumerator); 
        amount -= feeAmount;
        balances[owner] += feeAmount;
        return amount;
    }
    fallback () external payable {
        buy(msg.sender);
    }

    function withdraw(uint amount) public {
        require(msg.sender == owner);
        require(amount <= balances[owner]);
        payable(owner).transfer(amount);
    }
}