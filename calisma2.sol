// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

// Escrow adında bir sözleşme tanımladık. Bu sözleşme, bir üçüncü taraf aracılığıyla para transferi işlemlerini gerçekleştirmek için kullanılabilir. 

contract escrow{

    mapping (address => uint) _balances; // her adres için bir uint değeri ver, balances diye bir mapping oluşturduk
    address admin;
    uint commission_percent = 1;
    uint totals_comission = 0;

    constructor(uint _commission_percent){ //admin adresi birşeye eşit değildi. deploy işlemlerini yapabilmesi için cosntructor aracılığıyla işlemleri yapacak
        admin = msg.sender; // bunu yaptıktan sonra admin in fonskiyonda set olduğunu biliyoruz artık böylelikle yetkilendirme işini de bitirdik
        commission_percent = _commission_percent;  
    }

    function depositEther() external payable  { 
    // diğer fonksiyonlarda işimize yaramayacağı için sadece kendi içinde kullanılması yeter. 
    //eğer bir fonksiyon içine ether girip çıkıyorsa orada payable olmalıdır. Yani para akışı.

        require(msg.value >= 1 ether); // gönderilen ethereum en az 1 olmalı 
        _balances[msg.sender] += msg.value; // burada ise kayıt defterine ekleme yapıyoruz, msg.sender bizim public adresimiz oluyor ve msg.value'yi msg.sender a gönderiyoruz

    }

    function transferEtherWithCommission(address receiver, uint amount) external payable { //parayı göndereceğim kişinin adressine ve hesabına ihtiyacım var ki ona göre işlem yapayım ve para transferimi gerçekleştireyim
        require(msg.sender == admin); //burada msg.sender'ı admin adresine eşitliğini kontrol ettik. Yapılacak işlemler admin adresi üzerinden yapılacak.
        require(address(this).balance >= amount); // smart contract içindeki paradan daha fazla gönderilip gönderilmediğnii kontrol et
        // require(receiver.balance > 1 ether); tanımladığımız receiver'in direk balance değerine ulaşabiliriz
        totals_comission += amount/100 * commission_percent; //burada ise komisyonu hesapladık 
        _balances[admin] += amount/100 * commission_percent; // bu da parayı tutmanın farklı bir yolu
        payable(receiver).transfer(amount - amount/100 * commission_percent); 
        
    }

    function transferEtherWithOutCommission(address receiver, uint amount) external payable { //parayı göndereceğim kişinin adressine ve hesabına ihtiyacım var ki ona göre işlem yapayım ve para transferimi gerçekleştireyim
        require(msg.sender == admin); //burada msg.sender'ı admin adresine eşitliğini kontrol ettik. Yapılacak işlemler admin adresi üzerinden yapılacak.
        require(address(this).balance >= amount); // smart contract içindeki paradan daha fazla gönderilip gönderilmediğnii kontrol et
        payable(receiver).transfer(amount); 
    }

    function CollectCommission() external  {
        require(msg.sender == admin); // çağırma işlemini adminin yapıp yapmadığını kontrol ediyoruz
        payable(admin).transfer(_balances[admin]);
        _balances[admin] = 0; //işlem bittikçe kaydı sıfırlayarak karışıklığı önlüyoruz.

    }

    function setAdmin(address newAdmin) external {
        require(msg.sender == admin);
        require(newAdmin != address(0)); // burada yeni admin değişkeni boş olmamalıdır. Boş olması işlemde sıkıntı çıkararak kötü sonuçlara yol açabilir
        admin = newAdmin;
        _balances[newAdmin] = _balances[admin];
        // Yeni yöneticinin (_balances[newAdmin]) bakiyesi, eski yöneticinin (_balances[admin]) bakiyesine eşitlenir.
        // Yani, yeni yönetici, eski yöneticinin bakiyesini devralır.
        _balances[admin] = 0;
        // Eski yöneticinin bakiyesi sıfırlanır.
        // Bu, yeni yöneticinin bakiyesinin eski yöneticinin bakiyesiyle aynı olduğunu belirtir.
        // bu kısımlar yönetici değişiminden sonra eski yöneticinin bakiyeye erişim sağlayamaması açısından önemlidir
    }

    function getCollectedCommission() external view returns(uint){
        return _balances[admin];
        // Toplanan komisyon miktarını döndüren bir fonksiyondur.
        // view kullanım amacımız bu fonksiyon içerisinde herhangi bir değer güncellenmediğinden işleme direk devam etmekte ve geriye döndürmekte.
        // yani view kullanılarak, fonksiyonun durumu değiştirmediği ve geriye dönüş yaptığı belirtilir
    }

    function getUserDeposit(address _user) external view returns(uint){
        return _balances[_user]; // Kullanıcının (_user) bakiyesini döndüren bir fonksiyondur.

    }
}

/*
Author Muhammed Akıncı
*/
