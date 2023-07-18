/* Bu örnek projede parametre olarak alınan adımı mevcut adımın bir sonraki adımıyla karşılaştırarak işlem kabulünü veya reddini belirler. 
Eğer adım doğru sırayla gelmişse true değeri döndürülür; aksi takdirde false değeri döndürülür. */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract checkSequence{
    uint public currentStep;

    constructor(){
        currentStep = 0; // Başlangıç adımı
    }

    function checkSequenceVerify(uint step) public view returns(bool){
        if (step == currentStep + 1){
            return true; // işlem kabul edilir
        }
        else {
            return false; // işlem reddildi
        }
    }

    function updateStep() public{
        currentStep += 1; // adım güncellendi.
    }
}

/* 
Author Muhammed Akıncı
*/
