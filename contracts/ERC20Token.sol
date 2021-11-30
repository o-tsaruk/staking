//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract ERC20Token {

    string private _name;
    string private _symbol;

    uint256 private _totalSupply;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    constructor(string memory name_, string memory symbol_, uint256 total) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = total;
        balances[msg.sender] = _totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 6;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowances[owner][delegate];
    }

    function transfer(address receiver, uint256 amount) public returns (bool) {
        require(receiver != address(0), "transfer to the zero address");
        _transfer(msg.sender, receiver, amount);
        return true;
    }

    function transferFrom(address sender, address receiver, uint256 amount) public returns (bool) {
        require(sender != address(0), "transfer from the zero address");
        require(receiver != address(0), "transfer to the zero address");
        uint256 currentAllowance = allowances[sender][msg.sender];
        require(currentAllowance >= amount, "transfer amount exceeds allowance");

        _transfer(sender, receiver, amount);
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function _transfer(address sender, address receiver, uint256 amount) internal virtual {
        require(balances[sender] >= amount, "transfer amount exceeds sender's balance");

        balances[sender] -= amount;
        balances[receiver] += amount;

        emit Transfer(sender, receiver, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        allowances[owner][spender] = amount;
    }

    // functions for change allowance

    function increaseAllowance(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, allowances[msg.sender][spender] + amount);
        return true;
    }

    function decreaseAllowance(address spender, uint256 amount) public returns (bool) {
        uint256 currentAllowance = allowances[msg.sender][spender];
        require(currentAllowance >= amount, "subtracted amount exceeds current allowance");

        _approve(msg.sender, spender, currentAllowance - amount);

        return true;
    }

    // functions for change balance

    function mint(address account, uint256 amount) internal {
        require(account != address(0), "mint to the zero address");

        _totalSupply += amount;
        balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) internal {
        require(account != address(0), "burn from the zero address");

        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "burn amount exceeds balance");
        balances[account] -= amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }
}
