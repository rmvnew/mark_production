

let items = null

// Abrir a NUI

$(document).ready(()=>{

    window.addEventListener('message',(event)=>{

        let current_painel = document.getElementById('body_id')

        const data = event.data

        if(data.hasPermission ==='open' && data.dataResponse.length > 0){
           
            items = data.dataResponse.map((entry)=>{
                return {
                    quantidade: entry.quantidade,
                    item: entry.item
                }
            })
            renderItems();
            current_painel.style.display = 'flex'

        }else if(data.hasPermission ==='unauthorized'){

             current_painel.style.display = 'none'

        }else{
            
            current_painel.style.display = 'none'
            sendDataToClient('noitems',null)
        }

    })

})



$(document).keyup((event)=>{
    if(event.key ==='Escape'){

        sendDataToClient('closeCurrentNUI',null)

    }
})



function sendDataToClient(url,data){

    let current_data 
    if(data){
        current_data = data
    } else{
        current_data = 'ok'
    }

    let config = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(current_data)
    }
    fetch(`https://${GetParentResourceName()}/${url}`, config)
    .then(() =>{
        console.log("Mensagem enviada ao client.lua");
    }).catch(error => {
        console.log('Error: ',error);
        
    })

}


// const itemList = document.getElementById('item-list');

// // Função para criar a lista de itens
// function renderItems() {
//     itemList.innerHTML = ''; // Limpa a lista antes de renderizar

//     console.log(items)
//     items.forEach((data, index) => {
//         // Cria o elemento do item
//         const itemDiv = document.createElement('div');
//         itemDiv.className = 'item';

//         // Cria o texto do item
//         const itemText = document.createElement('div');
//         itemText.innerHTML = `<span class="item-name">${data.item}</span> - <span class="item-quantity">Quantidade: ${data.quantidade}</span>`;
//         itemDiv.appendChild(itemText);

//         // Cria o botão de coletar
//         const collectButton = document.createElement('button');
//         collectButton.className = 'collect-btn';
//         collectButton.textContent = 'Coletar';
//         collectButton.addEventListener('click', () => {
//             collectItem(index);
//         });
//         itemDiv.appendChild(collectButton);

//         // Adiciona o item à lista
//         itemList.appendChild(itemDiv);
//     });
// }


const tbody = document.getElementById("my_tbody");

// Função para renderizar a tabela
function renderItems() {
    tbody.innerHTML = ''; // Limpa a tabela antes de renderizar

    items.forEach(({ item, quantidade }, index) => {
        let row = document.createElement("tr");

        row.innerHTML = `
            <td>${item}</td>
            <td>${quantidade}</td>
            <td><button class="collect-btn" data-index="${index}">Coletar</button></td>
        `;

        tbody.appendChild(row);
    });

    // Adiciona evento de clique aos botões de coletar
    document.querySelectorAll(".collect-btn").forEach(button => {
        button.addEventListener("click", function() {
            let index = this.getAttribute("data-index");
            collectItem(index);
        });
    });
}

// Função para coletar o item
function collectItem(index) {
    // console.log(`Você coletou: ${items[index].item} - ${items[index].quantidade}`);

    console.log("Botão acionado!!!")
    const item = {
        item: items[index].item,
        quantidade: items[index].quantidade
    }

    sendDataToClient('getItem',item)
    
}

// Renderiza a lista inicial
renderItems();