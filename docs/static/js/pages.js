document.addEventListener('DOMContentLoaded', function() {
    // Captura os botões de navegação
    var inputsButton = document.getElementById('section-inputs-button');
    var tableButton = document.getElementById('section-table-button');

    // Captura as seções
    var sectionInputs = document.getElementById('section-inputs');
    var sectionTable = document.getElementById('section-table');

    // Mostra a seção de inputs inicialmente
    sectionInputs.style.display = 'block';
    sectionTable.style.display = 'none';

    // Adiciona a classe active-button ao botão de inputs e remove do botão de tabela
    inputsButton.classList.add('active-button');
    tableButton.classList.remove('active-button');

    // Adiciona evento de clique no botão de inputs
    inputsButton.addEventListener('click', function() {
        sectionInputs.style.display = 'block';
        sectionTable.style.display = 'none';

        // Adiciona a classe active-button ao botão de inputs e remove do botão de tabela
        inputsButton.classList.add('active-button');
        tableButton.classList.remove('active-button');
    });

    // Adiciona evento de clique no botão de tabela
    tableButton.addEventListener('click', function() {
        sectionInputs.style.display = 'none';
        sectionTable.style.display = 'block';

        // Adiciona a classe active-button ao botão de tabela e remove do botão de inputs
        tableButton.classList.add('active-button');
        inputsButton.classList.remove('active-button');
    });
});