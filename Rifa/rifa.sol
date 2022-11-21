// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Owned.sol";

contract  Rifaa  is Mortal{

    //Comprar Rifa
    //Retorna Premio atual(50%)
    //Sorteia ganhador
    //Retorna qtd Compradas por cada conta
    //Fução Sacar Premio
    //Ser reeaproveitável


    //event Withdraw(address to, uint amount);
    event RifaComprada(address comprador, uint quantidade);
    event RifaSorteada(address ganhador, uint valorGanho);
    event RifaPaga(address ganhador, uint valorPago);

    mapping(address => uint ) public tickets;
    mapping(address => uint ) public valorSacarGanhador;
    address [] public ganhadores;
    address [] public list_tickets;
    uint valores_retidos =0;
    uint valor_dono = 0;

    //destroy()
    //Comprar Rifa
    receive() external payable{
        require(msg.value > 0.1 ether, "Valor pago abaixo do minimo exigido por 1 ticket");
        require(msg.value % 0.1 ether == 0, "Valor nao compra um valor inteiro detickets");

        tickets[msg.sender] += (msg.value*10);
        for (uint i= 0; i < msg.value*10 ; i++){
            list_tickets.push(msg.sender);
        }

        emit RifaComprada(msg.sender, (msg.value*10)); //Mandando a mensagem do ticket comprado

    }

    //Retorna Premio atual(50%)
    function PremioAtual() public view returns (uint) {
        return ((address(this).balance - valores_retidos - valor_dono)/2) * 10**18 ;

    }
    //Sorteia ganhador
    function Sorteio() public onlyOwner{
        // Gerando números aleatórios entre 1 e 100:
        uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, list_tickets.length))) % list_tickets.length;


        valorSacarGanhador[list_tickets[random]] = (address(this).balance - valores_retidos - valor_dono)/2;
        valores_retidos += valorSacarGanhador[list_tickets[random]];
        valor_dono += valorSacarGanhador[list_tickets[random]];

        emit RifaSorteada(list_tickets[random], PremioAtual());
        resetar();
    }


    //Retorna qtd Compradas por cada conta
    function ticketsPorConta(address conta) public view returns (uint) {
        return tickets[conta];
    }

    //Fução Sacar Premio
    function sacarPremio() public{
        require(valorSacarGanhador[msg.sender] < 0, "Voce nao tem nada a sacar");
        //Enviar
        payable(msg.sender).transfer(valorSacarGanhador[msg.sender]);
        valores_retidos -= valorSacarGanhador[msg.sender];
        valorSacarGanhador[msg.sender] = 0;

        emit RifaPaga(msg.sender, valorSacarGanhador[msg.sender]); //Mandando uma mensagem que foi sacado

    }

    function saqueLoterica() public onlyOwner{
        payable(owner).transfer(valor_dono);
        valor_dono=0;
    }


    function resetar() private{
        for (uint i= 0; i < list_tickets.length ; i++){
            tickets[list_tickets[i]]=0;
        }
        delete list_tickets;
    }

}