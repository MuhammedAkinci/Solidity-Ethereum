pragma solidity 0.8.0; // Solidity dilinin sürümünü belirtir. Bu durumda, 0.8.0 sürümü kullanılıyor.

contract Checks { //  "Checks" adında bir akıllı sözleşme (contract) tanımlanıyor. Bu sözleşme, "Checks" adını taşıyor.
    int number1;
    address contract_owner;

    constructor() { // "constructor" fonksiyonu, sözleşme oluşturulduğunda bir kez çalışacak olan özel bir fonksiyondur.
        contract_owner = msg.sender; //  contract_owner değişkenine, sözleşmenin yaratıcısının (msg.sender) adresi atanır.
        number1 = 100; 
    }

    function set_number1(int value) public { // "set_number1" fonksiyonu, value adında bir tamsayı parametresi alır ve genel erişime (public) sahiptir.
        require(msg.sender == contract_owner); // Eğer fonksiyonu çağıran kişi (msg.sender), sözleşme sahibi (contract_owner) değilse, fonksiyonun çalışması durdurulur.
        number1 = value; // number1 değişkenine, fonksiyona verilen value değeri atanır.
    }

    function get_number1() public view returns (int) {
        return number1; // Fonksiyon, number1 değişkeninin değerini döndürür.
        //  "get_number1" fonksiyonu, hiçbir parametre almaz ve genel erişime (public) sahiptir. 
        // Ayrıca, sadece veri okuması yapacağı için view belirteci kullanılır.

        //Bu şekilde, "Checks" adlı sözleşmeniz, "number1" adında bir değişkeni tutacak -->
        //sözleşme sahibi sadece "set_number1" fonksiyonunu kullanarak "number1" değerini güncelleyebilecek -->
        // ve herkes "get_number1" fonksiyonunu kullanarak "number1" değerini okuyabilecektir.
    }
}

/*
author: Muhammed Akıncı
*/
