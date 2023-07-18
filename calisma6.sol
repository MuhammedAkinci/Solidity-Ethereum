// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./token.sol"; // burada token.sol çalışmasını buraya import ederek token.sol fonksiyonlara erişim sağlayabiliyoruz
// burada iki tane akıllı sözleşme biribiri ile uyumlu şekilde çalışacak. 
// token.sol projesinde private olan değişkenlere erişim sağlayamayız. 

contract CBRTokenMarketPlace{
    mapping (uint => address) item_id_owner; // her satışın bir id değeri olsun istiyoruz. bundan dolayı uint'i adrese bağlıyoruz. yani on_sale ürünü kimin satışa çıkardığını gösterir
    mapping (uint => uint) item_price; // buda satışa açılan item'ın id değeri ve price değerlerini birbirine bağladık
    mapping (address => mapping (uint => uint)) sale_listing; 
    mapping (uint => bool) item_stattes_status; // satın alınan ürün tekrar satın alınmamalı bunu önlemek için bu mapping'i oluşturduk
    uint sale_id_count = 0; // bu int değeri her işleme sırasıyla bir numara verilmesini sağlıyor ve işlem arttıkça sayıda otomatik olarak artıyor
    

    CBRtoken rdtoken;
    constructor(address _rd_token_address){
        rdtoken = CBRtoken(_rd_token_address); 
        // bu şekilde bir rdtoken değişkeni oluşturduk. yani set ettik ve adresi de parantez içinde verilen adres oldu
    }


    function open_sale(uint _price) public {
        item_id_owner[sale_id_count] = msg.sender; // burada item satışa açıldı yani işlem başlatıldı.
        item_price[sale_id_count] = _price; 
        item_stattes_status[sale_id_count] = true;
        sale_id_count += 1;
        
    }

    function buy(uint _sale_id) public returns(bool){ // bu fonksiyon satış id ye göre bir ürün satın alımı gerçekleştirilmesini sağlar
        bool result = rdtoken.transfer_from(msg.sender, address(this), item_price[_sale_id]); 
        // satın alan kullanıcıdan belirtilen smart contract'a item_price değeri kadar token aktar

        if (result) { // eğer token aktarımı başarılır olursa... 
            item_id_owner[_sale_id] = msg.sender; // satın alma başarılı olursa ürün id yi satın alan kişiye veriyoruz
            item_stattes_status[sale_id_count] = false; // satın alındıktan sonra tekrardan satın alma işlemi false yapılarak kaptılıyor.           
            return true; // ve sonrasında geriye "true" döndürüyoruz. Böylelikle işlem bitiyor
        }
        else{ // eğer token aktarımı başarısız olursa...
            return false; // ve sonrasında geriye "false" döndürüyoruz. Böylelikle işlem bitiyor.
        }
    }

    function get_sale_user(uint _sale_id) public view returns(address){
        return item_id_owner[_sale_id]; 
        //bu fonksiyon gelen satış id'yi bize gösteriyor
    }

    function get_sale_price(uint _sale_id) public view returns(uint){
        return item_price[_sale_id];
        // bu fonksiyon da satıştan gelen kazancı gösteriyor.
    }   
}
