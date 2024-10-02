document.addEventListener('DOMContentLoaded', function () {
    const barChartCtx = document.getElementById('barChart').getContext('2d');
    const lineChartCtx = document.getElementById('lineChart').getContext('2d');
    const pieChartCtx = document.getElementById('pieChart').getContext('2d');

    const barChartMineTestCtx = document.getElementById('barChartMineTest').getContext('2d');
    const lineChartMineTestCtx = document.getElementById('lineChartMineTest').getContext('2d');
    const pieChartMineTestCtx = document.getElementById('pieChartMineTest').getContext('2d');

    const chartOptions = {
        responsive: true,
        plugins: {
            legend: {
                display: false // Desativa a legenda padrão do gráfico
            }
        }
    };

    function generateColors(count, border = false) {
        const colors = [];
        for (let i = 0; i < count; i++) {
            const r = Math.floor(Math.random() * 255);
            const g = Math.floor(Math.random() * 255);
            const b = Math.floor(Math.random() * 255);
            const color = `rgba(${r}, ${g}, ${b}, ${border ? 1 : 0.2})`;
            colors.push(color);
        }
        return colors;
    }

    let barChart = new Chart(barChartCtx, {
        type: 'bar',
        data: { labels: [], datasets: [] },
        options: chartOptions
    });

    let lineChart = new Chart(lineChartCtx, {
        type: 'line',
        data: { labels: [], datasets: [] },
        options: chartOptions
    });

    let pieChart = new Chart(pieChartCtx, {
        type: 'pie',
        data: { labels: [], datasets: [] },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: false // Desativa a legenda interna do gráfico de pizza
                }
            }
        }
    });

    let barChartMineTest = new Chart(barChartMineTestCtx, {
        type: 'bar',
        data: { labels: [], datasets: [] },
        options: chartOptions
    });

    let lineChartMineTest = new Chart(lineChartMineTestCtx, {
        type: 'line',
        data: { labels: [], datasets: [] },
        options: chartOptions
    });

    let pieChartMineTest = new Chart(pieChartMineTestCtx, {
        type: 'pie',
        data: { labels: [], datasets: [] },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: false // Desativa a legenda interna do gráfico de pizza
                }
            }
        }
    });

    function updateCharts(column) {
        fetch(`/get_chart_data?column=${column}`)
            .then(response => response.json())
            .then(data => {
                const labels = data.map(item => item.label);
                const values = data.map(item => item.value);
                const colors = generateColors(labels.length);
                const borderColors = generateColors(labels.length, true);

                barChart.data.labels = labels;
                barChart.data.datasets = [{
                    label: 'Bar Chart',
                    data: values,
                    backgroundColor: colors,
                    borderColor: borderColors,
                    borderWidth: 1
                }];
                barChart.update();

                lineChart.data.labels = labels;
                lineChart.data.datasets = [{
                    label: 'Line Chart',
                    data: values,
                    backgroundColor: colors,
                    borderColor: borderColors,
                    borderWidth: 1
                }];
                lineChart.update();

                const pieColors = generateColors(labels.length);
                const pieBorderColors = generateColors(labels.length, true);

                pieChart.data.labels = labels;
                pieChart.data.datasets = [{
                    label: 'Pie Chart',
                    data: values,
                    backgroundColor: pieColors,
                    borderColor: pieBorderColors,
                    borderWidth: 1
                }];
                pieChart.update();

                updateLegend(data, pieBorderColors, 'legend');
            });
    }

    function updateMineTestCharts(column) {
        fetch(`/get_chart_data?column=${column}&table_option=MineTestLines`)
            .then(response => response.json())
            .then(data => {
                const labels = data.map(item => item.label);
                const values = data.map(item => item.value);
                const colors = generateColors(labels.length);
                const borderColors = generateColors(labels.length, true);

                barChartMineTest.data.labels = labels;
                barChartMineTest.data.datasets = [{
                    label: 'Bar Chart',
                    data: values,
                    backgroundColor: colors,
                    borderColor: borderColors,
                    borderWidth: 1
                }];
                barChartMineTest.update();

                lineChartMineTest.data.labels = labels;
                lineChartMineTest.data.datasets = [{
                    label: 'Line Chart',
                    data: values,
                    backgroundColor: colors,
                    borderColor: borderColors,
                    borderWidth: 1
                }];
                lineChartMineTest.update();

                const pieColors = generateColors(labels.length);
                const pieBorderColors = generateColors(labels.length, true);

                pieChartMineTest.data.labels = labels;
                pieChartMineTest.data.datasets = [{
                    label: 'Pie Chart',
                    data: values,
                    backgroundColor: pieColors,
                    borderColor: pieBorderColors,
                    borderWidth: 1
                }];
                pieChartMineTest.update();

                updateLegend(data, pieBorderColors, 'legendMineTest');
            });
    }

    function updateLegend(data, colors, legendId) {
        const legend = document.getElementById(legendId);
        legend.innerHTML = ''; // Limpa a legenda atual

        data.forEach((item, index) => {
            const legendItem = document.createElement('li');
            legendItem.innerHTML = `<span class="legend-color" style="background-color: ${colors[index]};"></span>${item.label} (${item.value})`;
            legend.appendChild(legendItem);
        });
    }

    document.getElementById('columnSelect').addEventListener('change', function () {
        updateCharts(this.value);
    });

    document.getElementById('columnSelectMineTestLines').addEventListener('change', function () {
        updateMineTestCharts(this.value);
    });

    document.querySelector('.select-tables').addEventListener('change', function () {
        const selectedTable = this.value;
        const sectionGraficos = document.getElementById('section-graficos');
        const sectionMineTestLines = document.getElementById('section-minetestlines');

        if (selectedTable === 'MineTestLines') {
            sectionGraficos.style.display = 'none';
            sectionMineTestLines.style.display = 'block';
        } else {
            sectionGraficos.style.display = 'block';
            sectionMineTestLines.style.display = 'none';
        }
    });

    // Inicializa os gráficos com a coluna padrão
    const defaultColumn = document.getElementById('columnSelect').value;
    const defaultMineTestColumn = document.getElementById('columnSelectMineTestLines').value;
    updateCharts(defaultColumn);
    updateMineTestCharts(defaultMineTestColumn);

    // Ajusta a visibilidade das seções de gráficos com base na tabela selecionada inicialmente
    const initialSelectedTable = document.querySelector('.select-tables').value;
    if (initialSelectedTable === 'MineTestLines') {
        document.getElementById('section-graficos').style.display = 'none';
        document.getElementById('section-minetestlines').style.display = 'block';
    } else {
        document.getElementById('section-graficos').style.display = 'block';
        document.getElementById('section-minetestlines').style.display = 'none';
    }
});
