/* Bu projede kullancıların bir işlemi belirli bir zaman aralığında yapabilmelerini sağlayan "Check Clock Time Verify" kavramı ele alınmıştır */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CheckTime{
    function check_clock_time_verify() public view returns(bool) {
        uint currentHour = (block.timestamp / 3600) % 24; // geçerli saat bilgisi
        uint startHour = 8; // başlangıç saati 08.00
        uint endHour = 20; // bitiş saati 20.00

        if (currentHour >= startHour && currentHour < endHour) { // işlem 8-20 arasında yapıldıysa
            return true; // işlem kabul edilir.
        }
        else {
            return false; // işlem reddilir.
        }
    }
}

/* 
Author Muhammed Akıncı
*/
