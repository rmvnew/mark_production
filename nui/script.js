

let items = null

// Abrir a NUI

$(document).ready(()=>{

    window.addEventListener('message',(event)=>{

        let current_painel = document.getElementById('container_id')
        const data = event.data

        console.log(data.dataResponse)

        if(data.hasPermission ==='open'){
            console.log("Chegou no JS")
            items = data.dataResponse.map((entry)=>{
                return {
                    quantidade: entry.quantidade,
                    item: entry.item
                }
            })
            renderItems();
            current_painel.style.display = 'block'
        }else{
            console.log("Chegou no JS")
            current_painel.style.display = 'none'
        }

    })

})


$(document).keyup((event)=>{
    if(event.key ==='Escape'){
        fetch(`https://mark_production/closeCurrentNUI`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify('ok')
        }).then(() => {
            console.log("Mensagem enviada ao client.lua");
        }).catch((error) => {
            console.error("Erro ao enviar para o cliente:", error);
        });
    }
})





const itemList = document.getElementById('item-list');

// Função para criar a lista de itens
function renderItems() {
    itemList.innerHTML = ''; // Limpa a lista antes de renderizar

    console.log(items)
    items.forEach((data, index) => {
        // Cria o elemento do item
        const itemDiv = document.createElement('div');
        itemDiv.className = 'item';

        // Cria o texto do item
        const itemText = document.createElement('div');
        itemText.innerHTML = `<span class="item-name">${data.item}</span> - <span class="item-quantity">Quantidade: ${data.quantidade}</span>`;
        itemDiv.appendChild(itemText);

        // Cria o botão de coletar
        const collectButton = document.createElement('button');
        collectButton.className = 'collect-btn';
        collectButton.textContent = 'Coletar';
        collectButton.addEventListener('click', () => {
            collectItem(index);
        });
        itemDiv.appendChild(collectButton);

        // Adiciona o item à lista
        itemList.appendChild(itemDiv);
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

    let config = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(item)
    }
    fetch(`https://${GetParentResourceName()}/getItem`, config)
    
}

// Renderiza a lista inicial
renderItems();