pragma solidity ^0.4.24;

contract Logistics
{
    // DECLARATION //
    address Owner; 
    struct package
    {
      bool isUIDgenerated; /* everytime when a customer places an order using this contract it will generate a UID specific to that order. 
                               Hence for confirming that the order is placed by this contract itself we make use of it */
      uint itemid;          // we are using itemid and itemname so that it will be easier for the logisitcs company to identify product which is to be delivered
      string itemname;
      string transitstatus; // transit_status is used for confirming everytime a product is delivered from one node to other 
      uint orderstatus;     /*Here it is used to determine the status of the order i.e, 
                               1 = ordered placed
                               2 = in-transit
                               3 = delivered
                               4 = order is cancelled
                             */
       
      address customer;     
      uint order_time;
      // Now i will be adding the details of the nodes who are going to trandfer product from sender to receiver. Here I am considering 3 nodes.
      address carrier1;  
      uint carrier1_time;
      
      address carrier2;
      uint carrier2_time;
      
      address carrier3;
      uint carrier3_time;
      
    }
    
    mapping(address => package) public packagemapping;
    mapping(address => bool) public carriers; // using this we can authorise that only registered nodes are involved in delivering process
    // DECLARATION END //
    
    
    // MODIFIERS //
    constructor()
    {
        Owner= msg.sender;
    }
    modifier onlyOwner()
    {
        require ( Owner == msg.sender);
        _;
    }
    // END OF THE MODIFIER //
    
    
    // FUNCTION  TO MANAGE THE NODES //
    
    function ManageCarriers(address _carrierAddress) onlyOwner public returns(string)
    {
       if(!carriers[_carrierAddress])
           carriers[_carrierAddress] = true;
       else
           carriers[_carrierAddress] = false;
           
        return "Carrier is updated" ; 
    }  
    // END FUNCTION //
    
    
    // FUNCTION TO PLACE AN ORDER ITEM USING THIS CONTRACT //
    function OrderItem(uint _itemid, string _itemname) public returns(address)
    {
        address uniqueId = address(sha256(msg.sender,now)); // It will create a SHA256 of the customer adddress at current timestamp to avoid any error.
        packagemapping[uniqueId].isUIDgenerated = true;
        packagemapping[uniqueId].itemid = _itemid;
        packagemapping[uniqueId].itemname = _itemname;
        packagemapping[uniqueId].transitstatus = "Your order has been placed and is under process";
        packagemapping[uniqueId].orderstatus = 1;
        packagemapping[uniqueId].customer = msg.sender;
        packagemapping[uniqueId].order_time = now; 
        
        return uniqueId;
    }
    // END OF THE FUNCTION //
    
    // FuUNCTION TO CANCEL ORDER //
    
    function CancelOrder (address _uniqueId) public returns(string)
    {
        require(packagemapping[_uniqueId].isUIDgenerated);
        require(packagemapping[_uniqueId].customer == msg.sender);
        packagemapping[_uniqueId].orderstatus = 4;
        packagemapping[_uniqueId].transitstatus = "Your order has been cancelled";
        
        return "Your order has been cancelled";
    }
    // END OF THE FUNCTION //
    
    // FUNCTION FOR NODES CONFIRMATION ON PRODUCT DELIVERY TO THE SUCCESSIVE NODE IN THE CHAIN
    function CarrierReport1(address _uniqueId, string _transitstatus)
    {
        require(packagemapping[_uniqueId].isUIDgenerated);
        require(carriers[msg.sender]);
        require(packagemapping[_uniqueId].orderstatus == 1);
        
        packagemapping[_uniqueId].transitstatus = _transitstatus;
        packagemapping[_uniqueId].carrier1 = msg.sender;
        packagemapping[_uniqueId].carrier1_time = now;
        packagemapping[_uniqueId].orderstatus =2;
        
    }
    
     function CarrierReport2(address _uniqueId, string _transitstatus)
    {
        require(packagemapping[_uniqueId].isUIDgenerated);
        require(carriers[msg.sender]);
        require(packagemapping[_uniqueId].orderstatus == 2);
        
        packagemapping[_uniqueId].transitstatus = _transitstatus;
        packagemapping[_uniqueId].carrier2= msg.sender;
        packagemapping[_uniqueId].carrier2_time = now;
        
    }
    
     function CarrierReport3(address _uniqueId, string _transitstatus)
    {
        require(packagemapping[_uniqueId].isUIDgenerated);
        require(carriers[msg.sender]);
        require(packagemapping[_uniqueId].orderstatus == 2);
        
        packagemapping[_uniqueId].transitstatus = _transitstatus;
        packagemapping[_uniqueId].carrier3=msg.sender;
        packagemapping[_uniqueId].carrier3_time = now;
        packagemapping[_uniqueId].orderstatus =3;
        
    }
    
}