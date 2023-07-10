// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/* 
Bu çalışma calisma3.1_escrow.sol olarak geçmektedir. Bir önceki çalışma olan calisma3_escrow.sol adlı çalışma ile aynı işlevselliği taşımaktadır.
Fakat bazı küçük farklılıklar vardır. Bu çalışmada önceki çalışmadan farklı olarak bazı fonksiyonların farklı kullanımı veya değişik kullanımları söz konusudur.
calisma3_escrow çalışmasında olan bazı satırlar burada yoktur. Bunun nedeni farklı şekilde kullanıldığını veya kullanılmadığında nasıl bir değişiklik olduğunu gösterebilmektir.
*/

contract escrow2 {
    mapping (uint => address) transaction_receivers_list;
    mapping (uint => address) transaction_owners_list;
    mapping (uint => uint) transaction_payment_list;
    mapping (uint => bool) transaction_status_list;
    uint transaction_count = 0;

    address admin;
    uint commission_percent = 1;
    uint collected_commission = 0;

    constructor(uint _commission_percent) {
        admin = msg.sender;
        commission_percent = _commission_percent;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    modifier onlyTransactionOwner(uint _transaction_id) {
        require(transaction_payment_list[_transaction_id] != 0);
        _;
    }

    modifier CheckIfTransactionNotZero(uint _transaction_id) {
        require(transaction_payment_list[_transaction_id] != 0);
        _;
    }

    modifier CheckIfTransactionActive(uint _transaction_id) {
        require(!transaction_status_list[_transaction_id]);
        _;
    }

    function createTransaction(address _transaction_receiver) external payable {
        require(msg.value >= 1 ether);
        require(_transaction_receiver != address(0));

        transaction_receivers_list[transaction_count] = _transaction_receiver;
        transaction_payment_list[transaction_count] += msg.value;
        transaction_owners_list[transaction_count] = msg.sender;
        transaction_status_list[transaction_count] = false;
        transaction_count += 1;
    }

    function addEtherToTransaction(uint _transaction_id) external payable
        onlyTransactionOwner(_transaction_id)
        CheckIfTransactionNotZero(_transaction_id)
        CheckIfTransactionActive(_transaction_id)
    {
        transaction_payment_list[_transaction_id] += msg.value;
    }

    function cancelTransaction(uint _transaction_id) external
        onlyTransactionOwner(_transaction_id)
        CheckIfTransactionNotZero(_transaction_id)
        CheckIfTransactionActive(_transaction_id)
    {
        TransferPayment(transaction_owners_list[_transaction_id], transaction_payment_list[_transaction_id]);
        transaction_payment_list[_transaction_id] = 0;
        transaction_owners_list[_transaction_id] = address(0);
        transaction_receivers_list[_transaction_id] = address(0);
    }
    
    function confirmTransaction(uint _transaction_id) external
        onlyTransactionOwner(_transaction_id)
        CheckIfTransactionNotZero(_transaction_id)
        CheckIfTransactionActive(_transaction_id)
    {
        transaction_status_list[_transaction_id] = true;
    }

    function withDrawtransaction(uint _transaction_id) external payable {
        require(transaction_receivers_list[_transaction_id] == msg.sender);
        require(transaction_status_list[_transaction_id]);

        collected_commission += transaction_payment_list[_transaction_id] / 100 * commission_percent;
        TransferPayment(msg.sender, transaction_payment_list[_transaction_id] - transaction_payment_list[_transaction_id] / 100 * commission_percent);
        transaction_payment_list[_transaction_id] = 0;
    }

    function TransferPayment(address _receiver, uint _amount) internal {
        payable(_receiver).transfer(_amount);
    }

    function setAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0));
        admin = _newAdmin;
    }
}

/*
Author Muhammed Akıncı
*/
