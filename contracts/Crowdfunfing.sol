pragma solidity >0.7.0;

contract Crowdfunding {
    address public author;

    mapping(address => uint256) public joined;

    uint256 constant Target = 10 ether;

    uint256 public endTime;

    uint256 public price = 0.02 ether;

    bool public closed = false;

    constructor() {
        author = msg.sender;
        endTime = block.timestamp + 30 days;
    }

    function updatePrice() internal {
        uint256 rise = (address(this).balance / 1 ether) * 0.002 ether;
        price = 0.02 ether + rise;
    }

    receive() external payable {
        require(block.timestamp < endTime && !closed);
        require(joined[msg.sender] == 0);
        require(msg.value >= price);
        joined[msg.sender] = msg.value;
        updatePrice();
    }

    function withdrawFund() external {
        require(msg.sender == author);
        require(address(this).balance >= Target);
        closed = true;
        selfdestruct(payable(msg.sender));
    }

    function withdraw() external {
        require(block.timestamp > endTime);
        require(!closed);
        require(Target > address(this).balance);
        payable(msg.sender).transfer(joined[msg.sender]);
        updatePrice();
    }
}
