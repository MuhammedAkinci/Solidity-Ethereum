/* Bu çalışmamızda gönderilen ethereum miktarı kadar token üreten ve o kullanıcıya atayan bir sözleşme yazacağız. 
Aynı zamanda bir token oluşturacağız.*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CBRtoken{ // token adındaki contract tanımı
    string private _name; // burada bunların private olması ileride "CBRMarketPlaces" projesinde erişmek istediğimizde bize private olduğu için zorluk çıkarır ve erişmemize izin vermez. 
    string private _symbol; // İlk başta kullanabilir gibi gözükse de derleme kısmında hata verir.
    uint8 private _decimals;
    uint256 private _total_supply;
    mapping (address => uint256) private balances; // her adrese denk gelen bir integer değeri var. Bu mapping sayesinde kimin ne kadar token'e sahip olduğunu bilebiliyoruz. 
    address private  admin;
    mapping (address => mapping (address => uint)) allowances; // bu mapping owner ve spender adres aynı adresi verdiğimizde owner ın spender'a verdiği uint değerinin tutulduğu kayıt defteri yerine geçiyor

    constructor(string memory name_, string memory symbol_, uint8 decimals_){
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        admin = msg.sender; balances[admin] += 100;  // fonksiyonu çağıran admine msg.sender yardımı ile 100 tokeni otomotik olarak veriyoruz
        _total_supply = 100;
    }

    // oluşturacağımız tokenin adını çağırana iletir.
    function name() public view returns(string memory) {
        return _name;
        // view fonskiyon içerisinde herhangi bir değişken değiştirilmemesini ve bu fonksiyonun sadece smart contract'dan bir değişkene okuyup geri iletmek üzere kullanılacak.
        // bu da bize bu fonksiyonun kullandığı gas miktarının azalmasını sağlıyor.
    }

    function symbol() public view returns(string memory){
        return _symbol;
    }

    function decimals() public view returns(uint8){
        return _decimals;
    }

    function total_supply() public view returns(uint){
        return _total_supply;
    }

    function balancesOf(address _owner) public view returns(uint){
       return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public returns(bool) {
        require(balances[msg.sender] >= _amount); // bu fonksiyonu çağıran kişinin balances'i transfer yapacak olan kişinin _amount'a eşit veya büyük olup olmadığını sorguluyoruz.
        balances[msg.sender] -= _amount;
        balances[_to] += _amount; 
        return true;
        // bu kısımda diyelim ki adminbir kullanıcının hesabına 100 token attı, tekrardan gelip atmak isterse eğer elinde yoksa hata mesjaı olur.
        // Çünkü kod burada devreye girmiştir ve requireye bakarak gereksinimlere göre hareket etmiştir.
        
    }

    function mint(address _to, uint256 _amount) public {
        require(msg.sender == admin); 
        balances[_to] += _amount;
        _total_supply += _amount;
        // bu fonksiyonu para basma fonksiyonu gibi düşünebiliriz.
        // bu fonksiyon adminin istediği kişiye token vermesini sağlıyor. Bu yüzden bir üst satırdaki require önemlidir.
        // Çünkü sadece adminin buraya erişmesi gerekmektedir.
    }

    // burada ethereum gönderme işlemi yapacağız
    function mintFromEther() public payable{
        balances[msg.sender] += msg.value; 
    }

    function mint_by_ether() public payable returns(bool) {
        require(balances[msg.sender] > balances[msg.sender] + msg.value);
        balances[msg.sender] += msg.value;
        // bu fonksiyon, fonksiyon çağırılırken gönderilen ether miktarını kayıt defterindeki gönderen kişiye balance olarak ekliyor
        // bu işlemde msg.value transaction'a eklediğimiz ether miktarı  
        // fonksiyon çalışma amacı ether gönderilirken oluşabilecek işlem hatalarını ortadan kaldırmak 
        return true;
    }


    function transfer_from(address _owner, address _to, uint _amount) public returns(bool){
        require(balances[_owner] >= _amount);
        require(allowances[_owner][msg.sender] >= _amount); // owner bu fonksiyonu çağıran kişiye miktarı göndermiş mi amount etmiş mi ona bakıyoruz
        balances[_owner] -= _amount; //owner dan göndeirlen miktarı düşüyoruz
        allowances[_owner][msg.sender] -= _amount;
        balances[_to] += _amount;
        return true;
    }  

    function approve(address _spender, uint _amount) public returns(bool){
        allowances[msg.sender][_spender] = _amount;
        return true;
         // bu fonksiyon ise allowance de izin verilen harcamaların işlem gördüğü kısım
    }

    function allowance(address _owner, address _spender) public view returns(uint) { 
        return allowances[_owner][_spender];
        //bu fonksiyon spender a ne kadar token harcama izni verildiğini belirleyen fonksiyon
         // _owner kullanıcısının _spender kullanıcısına verdiği allowances değeri
    }
}
