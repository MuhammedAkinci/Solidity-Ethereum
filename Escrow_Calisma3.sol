// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract escrow2{
    mapping (uint => address) transaction_receivers_list; // kullanıcının yaptığı transaction(işlem) yaptığında bu işlemler satıcı(reveicer) gider. Yani paranın kime gideceği
    mapping (uint => address) transaction_owners_list; // burası ise transaction yapan kişinin adresi
    mapping (uint => uint) transaction_payment_list; // transaction(işlem) boyutunun ne kadar olacağı 
    mapping (uint => bool) transaction_status_list; // işlemin durumunun ne olduğunu gösteren adres
    uint transaction_count = 0; // işlem sayısının kayıt ediyoruz

    address admin;
    uint commission_percent = 1;
    uint collected_commission = 0;

    constructor(uint _commission_percent){
        admin = msg.sender;
        commission_percent = _commission_percent;
    }

    modifier onlyAdmin(){
        require(msg.sender == admin);
        _; // alt tire ve noktalı virgül, require'yi kontrol et ve işlemlere olduğu gibi devam et anlamına gelir

    }

    modifier onlyTransactionOwner(uint _transaction_id){
        require(transaction_payment_list[_transaction_id] != 0);
        _; // alt tire ve noktalı virgül, require'yi kontrol et ve işlemlere olduğu gibi devam et anlamına gelir

    }

    modifier CheckIfTransactionNotZero(uint _transaction_id){
        require(transaction_payment_list[_transaction_id] != 0);
        _; // alt tire ve noktalı virgül, require'yi kontrol et ve işlemlere olduğu gibi devam et anlamına gelir

    }

    modifier CheckIfTransactionActive(uint _transaction_id){
        require(transaction_status_list[_transaction_id] == false);
        _; // alt tire ve noktalı virgül, require'yi kontrol et ve işlemlere olduğu gibi devam et anlamına gelir

    }

    // user(buyur) kullanacağı fonksiyonlar
    function createTransaction(address _transaction_receiver) external payable{ // bu kısımda kullanıcı bir işlem oluşturmakta
        require(msg.value >= 1 ether); // göndeirlen ether en az 1 olmalı
        require(_transaction_receiver != address(0)); // işlemi göndereceğimiz kişinin adresi boş olmamalı ki işlem gönderilsin
        // solidity'de eğer bir kullanıcı adres tipinde paramaetre alan bir fonksiyon varsa ve kullanıcı onu set etmeden fonksiyonu çağırırsa adres otomotik olarak 0 a eşitlenir. bu da çeşitli sıkıntılara yol açabiliyordu

        transaction_receivers_list[transaction_count] = _transaction_receiver; //  gerekli eşitlemeleri yapıyoruz
        transaction_payment_list[transaction_count] += msg.value; //  burada payment_list gönderilen value'ye eşitleniyor. Yani gönderilen ether değeri
        transaction_owners_list[transaction_count] = msg.sender;// owner_list bu transaction'u kim çağırıyorsa ona eşitleniyor
        transaction_status_list[transaction_count] = false; //  
        transaction_count += 1; // her işlemde 1 artıyoruz
    }

    //bu fonksiyonun amacı önceden oluşturulmuş bir transaction'a sonradan ether eklemek. Fakat sadece transaction'u oluşturan kullanıcı ekleme yapabiliyor
    function addEtherToTransaction(uint _transaction_id) external payable onlyTransactionOwner(_transaction_id) CheckIfTransactionNotZero(_transaction_id) CheckIfTransactionActive(_transaction_id){
        transaction_payment_list[_transaction_id] += msg.value;
        // burada payment_list gönderilen value'ye eşitleniyor. Yani gönderilen ether değeri
        // burada ekleme işlemini sadece işlemi oluşturan kişi yapabiliyor dedik lakin bunun bir require durumu yok
        // bunun için ise modifier kullandık. mesela burada onlyTransactionOwner modifier'i var ve o modifer'de, _transaction_id gönderir.
        // onlyTransactionOwner da ise işlemi yapan kişinin olup olmadığı gerekliliği göz önünde bulundurularak işlem yapılıyor.
        // yani burada dışarıdan gönderilen transaction(işlem)'ın, owner'a eşit olup olmadığını kontrol ediyoruz.
    }

    function cancelTransaction(uint _transaction_id) external onlyTransactionOwner(_transaction_id) CheckIfTransactionNotZero(_transaction_id) CheckIfTransactionActive(_transaction_id){
        TransferPayment(transaction_owners_list[_transaction_id], transaction_payment_list[_transaction_id]);
        transaction_payment_list[_transaction_id] = 0;
        transaction_owners_list[_transaction_id] = address(0);
        transaction_receivers_list[_transaction_id] = address(0);
    }
    
    function confirmTransaction(uint _transaction_id) external onlyTransactionOwner(_transaction_id) CheckIfTransactionNotZero(_transaction_id) CheckIfTransactionActive(_transaction_id){
        transaction_status_list[_transaction_id] = true;  //burada da transaction doğrulanıyor. Ama bunu fonksiyon her döndüğünde ayrı ayrı yapıyor
        // confirm edildiğinde satıcı parayı çekebiliyor.
    }


    // User(seller) kullanacağı fonksiyonlar
    // burada satıcı kendisi için oluşturulmul transaction parasını çekebiliyor. Tabi kontrol edilmiş ve onaylanmış ise
    function withDrawtransaction(uint _transaction_id) external payable{ //  fonksiyonu, satıcının hesabından ödeme çekmesini sağlar. İşlemi onaylamış olan satıcı, ödeme miktarını alırken belirli bir komisyon yüzdesi (commission_percent) hesabına aktarılır.
        require(transaction_receivers_list[_transaction_id] == msg.sender); // _transaction_id'deki receiver'in doğru gönderen kişi olup olmadığı kontrol edilir
        require(transaction_status_list[_transaction_id] == true);

        collected_commission += transaction_payment_list[_transaction_id] / 100 * commission_percent;
        TransferPayment(msg.sender, transaction_payment_list[_transaction_id] - transaction_payment_list[_transaction_id] / 100 * commission_percent);
        transaction_payment_list[_transaction_id] = 0;
    }

    function TransferPayment(address _receiver, uint _amount) internal{
        payable(_receiver).transfer(_amount);
    }


    // Admin kullanacağını fonksiyonlar
    function setAdmin(address _newAdmin) external onlyAdmin{
        require (_newAdmin != address(0));
        admin = _newAdmin;
        // fonksiyonu, sözleşmenin yönetici adresini değiştirmek için kullanılır. 
        //Bu işlemi sadece mevcut yönetici yapabilir.
    }

    function collectedCommission() external payable onlyAdmin{ //fonksiyonu, hesapta biriken komisyonu yöneticiye aktarır.
        TransferPayment(admin, collected_commission);
        collected_commission = 0;
    }

    function forceCancelTransaction(uint _transaction_id) external payable onlyAdmin{
        TransferPayment(transaction_owners_list[_transaction_id], transaction_payment_list[_transaction_id]);
        transaction_payment_list[_transaction_id];
        transaction_owners_list[_transaction_id] = address(0);
        transaction_receivers_list[_transaction_id] = address(0);
    //  fonksiyon, yöneticinin bir işlemi zorla iptal etmesini sağlar. İşlemi iptal eden kullanıcıya ödeme iade edilir ve ilgili işlem kayıtları sıfırlanır.
    }

    function forceConfirmTransaction(uint _transaction_id) external payable onlyAdmin{
        transaction_status_list[_transaction_id] = true;
    // fonksiyonu, yöneticinin bir işlemi zorla onaylamasını sağlar.
    }

    //Getter kullanacağı fonksiyonlar
    // Bu fonksiyonlar, işlemlerin durumunu ve ilgili bilgileri almak için kullanılabilir.
    function getTransactionStatus(uint _transaction_id) external view returns(bool){
        return transaction_status_list[_transaction_id];
    }
    
    function getTransactionReceiver(uint _transaction_id) external view returns(address){
        return transaction_receivers_list[_transaction_id];
    }

    function getTransactionOwner(uint _transaction_id) external view returns(address){
        return transaction_owners_list[_transaction_id];
    }    

    function getTransactionPaymnetAmount(uint _transaction_id) external view returns(uint){
        return transaction_payment_list[_transaction_id];
    }

    function getCollectedCommission() external view returns(uint){
        return collected_commission;   
    }
}

/*
Author Muhammed Akıncı
*/
