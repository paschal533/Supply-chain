pragma solidity ^0.6.0;

contract Ownable {
  address payable _owner;

  constructor() public {
    _owner = msg.sender;
  }

  modifier onlyOwner() {
    require(IsOwner(), "You are not the owner");
    _;
  }

  function IsOwner() view returns(bool) {
    return (msg.sender == _owner);
  }
}

contract Item {
  uint public priceInWei;
  uint public pricePaid;
  uint public index;

  ItemManager parentContract;

  constructor(ItemManager _parentContract, uint _priceInWei, uint _index) public {
    priceInWei = _priceInWei;
    index = _index;
    parentContract = _parentContract;
  }

  receive() external payable {
    require(pricePaid == 0, "item is paid already");
    require(priceInWei == msg.value, "Only full payments allowed");
    pricePaid = msg.value;
    (bool success) = address(parentContract).call.value(msg.value)(abi.encodeWithSignature("triggerPayment(uint256)", index));
    require(success, "the transaction wasn't successful, canceling");
  }

  fallback() external {

  }
}

contract ItemManager is Ownable {
  enum SupplyChainState {Created, Paid, Delivered};
  struct S_item {
    Item _item;
    string _identifier,
    uint _itemPrice,
    ItemManager.SupplyChainState _state;
  }
  mapping(uint => S_item) public items;
  uint itemIdex;

  event SupplyChainStep(uint _itemIdex, uint _step, address _itemAddress);

  function createItem(string memory _identifier, uint _itemPrice) public onlyOwner {
    Item item = new item(this, _itemPrice, itemIdex);
    items[itemIdex]._item = item;
    items[itemIdex]._identifier = _identifier;
    items[itemIdex]._itemPrice = _itemPrice;
    items[itemIdex]._state = SupplyChainState.Created;
    emit SupplyChainStep(itemIdex, uint(items[itemIdex]._state), address(item));
    itemIdex++;
  }

  function triggerPayment(uint _itemIdex) public payable {
    require(items[_itemIdex]._itemPrice == msg.value, "Only full payment accepted");
    require(items[_itemIdex]._state == SupplyChainState.Created, "item is not found in tha chain");
    emit SupplyChainStep(itemIdex, uint(items[itemIdex]._state), address[items[_itemIndex]._item]);

    items[_itemIdex]._state = SupplyChainState.Paid;
  }

  function triggerDelivery(uint _itemIdex) public onlyOwner {
    require(items[_itemIdex]._state == SupplyChainState.Paid, "item is not paid in tha chain");
    items[_itemIdex]._state = SupplyChainState_Deliverd

    emit SupplyChainStep(itemIdex, uint(items[itemIdex]._state), address[items[_itemIndex]._item]);

  }
}
