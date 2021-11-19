pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

struct Order {
    uint32 id;
    string name;
    uint32 qty;
    uint64 createdAt;
    uint32 price;
    bool isDone;
}

struct Stats {
    uint32 complCount;
    uint32 uncomlCount;
    uint32 totalPrice;
}

contract shopping {


    modifier owner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        tvm.accept();
        _;
    }

    uint32 ord_count=0;

    

    mapping(uint32 => Order) ordLst;

    uint256 m_ownerPubkey;

    constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    function newOrder(string name, uint32 qty) public owner {
        ord_count++;
        ordLst[ord_count] = Order(ord_count, name, qty, now, 0, false);
    }

    function delOrder(uint32 id) public owner {
        require(ordLst.exists(id), 102);
        delete ordLst[id];
    }

    function updateOrder(uint32 id, uint32 price, bool done) public owner {
        optional(Order) order = ordLst.fetch(id);
        require(order.hasValue(), 101);
        Order _Order = order.get();
        _Order.isDone = done;
        _Order.price = price;
        ordLst[id] = _Order;
    }

    function getStat() public view returns (Stats stat) {
        uint32 complCount;
        uint32 uncomplCount;
        uint32 totalPrice;

        for((, Order order) : ordLst) {
            if  (order.isDone) {
                complCount += order.id;
                totalPrice += order.price;
            } else {
                uncomplCount += order.id;
            }
        }
        stat = Stats( complCount, uncomplCount, totalPrice );
    }


    function getListOrders() public view returns (Order[] orders) {
        string name;
        uint32 qty;
        uint64 createdAt;
        uint32 price;
        bool isDone;


        for((uint32 id, Order order) : ordLst) {
            name = order.name;
            qty = order.qty;
            isDone = order.isDone;
            createdAt = order.createdAt;
            price = order.price;
            orders.push(Order(id, name, qty, createdAt, price, isDone ));
       }
    }


}
