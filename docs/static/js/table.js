document.addEventListener('DOMContentLoaded', function() {
    loadTable(1); // Load the first page on page load
    document.getElementById('searchInput').addEventListener('input', () => loadTable(1));
});

function loadTable(page) {
    const selectElement = document.querySelector('.select-tables');
    const selectedValue = selectElement.value;
    const searchQuery = document.getElementById('searchInput').value;
    const perPage = 10;

    fetch(`/get_table?table_option=${selectedValue}&page=${page}&search=${searchQuery}`)
        .then(response => response.json())
        .then(data => {
            document.getElementById('table-container').innerHTML = data.tabela_html;
            updatePagination(page, data.total_pages);
        })
        .catch(error => console.error('Error fetching table:', error));
}

function updatePagination(currentPage, totalPages) {
    const paginationContainer = document.getElementById('pagination-container');
    let paginationHTML = '';

    if (currentPage > 0) {
        paginationHTML += `<a href="#" onclick="loadTable(1)">Primeira Página</a>`;
        paginationHTML += `<a href="#" onclick="loadTable(${currentPage - 1})"><<</a>`;
    }

    const startPage = Math.max(currentPage - 2, 1);
    const endPage = Math.min(currentPage + 2, totalPages);

    for (let i = startPage; i <= endPage; i++) {
        paginationHTML += `<a href="#" onclick="loadTable(${i})" class="${i === currentPage ? 'active' : ''}">${i}</a>`;
    }

    if (currentPage < totalPages) {
        paginationHTML += `<a href="#" onclick="loadTable(${currentPage + 1})">>></a>`;
        paginationHTML += `<a href="#" onclick="loadTable(${totalPages})">Última Página</a>`;
    }

    paginationContainer.innerHTML = paginationHTML;
}

function changeTable() {
    loadTable(1); // Reset to the first page on table change
}