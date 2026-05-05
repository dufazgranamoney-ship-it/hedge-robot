// HedgeRobot - Web Simulator

class HedgeRobotSimulator {
    constructor() {
        this.positions = [];
        this.trades = [];
        this.stats = {
            totalTrades: 0,
            winningTrades: 0,
            losingTrades: 0,
            hedgesActivated: 0,
            totalProfit: 0,
            maxProfit: 0,
            maxLoss: 0
        };
        this.running = false;
        this.speed = 1;
        this.profitHistory = [];
        this.chart = null;
        this.config = {
            symbols: ['EURUSD', 'GBPUSD', 'XAUUSD', 'BTCUSD'],
            lotSize: 0.1,
            tpPercent: 10,
            hedgePercent: 10,
            forexWeight: 30,
            goldWeight: 30,
            cryptoWeight: 40
        };
        this.symbolPrices = {};
        this.initializePrices();
    }

    initializePrices() {
        const prices = {
            'EURUSD': 1.1000,
            'GBPUSD': 1.3000,
            'USDJPY': 110.00,
            'XAUUSD': 1800.00,
            'BTCUSD': 45000.00,
            'ETHUSD': 2500.00
        };
        this.symbolPrices = { ...prices };
    }

    loadConfig() {
        const symbols = document.getElementById('symbols').value;
        this.config.symbols = symbols.split(',').map(s => s.trim());
        this.config.lotSize = parseFloat(document.getElementById('lotSize').value);
        this.config.tpPercent = parseFloat(document.getElementById('tpPercent').value);
        this.config.hedgePercent = parseFloat(document.getElementById('hedgePercent').value);
        this.config.forexWeight = parseFloat(document.getElementById('forexWeight').value);
        this.config.goldWeight = parseFloat(document.getElementById('goldWeight').value);
        this.config.cryptoWeight = parseFloat(document.getElementById('cryptoWeight').value);
    }

    getAssetWeight(symbol) {
        if (['EUR', 'GBP', 'JPY'].some(s => symbol.includes(s))) {
            return this.config.forexWeight / 100;
        } else if (symbol.includes('XAU')) {
            return this.config.goldWeight / 100;
        } else {
            return this.config.cryptoWeight / 100;
        }
    }

    updatePrices() {
        for (let symbol of this.config.symbols) {
            const change = (Math.random() - 0.5) * 0.001;
            this.symbolPrices[symbol] *= (1 + change);
        }
    }

    createPosition() {
        const symbol = this.config.symbols[Math.floor(Math.random() * this.config.symbols.length)];
        const direction = Math.random() > 0.5 ? 'BUY' : 'SELL';
        const currentPrice = this.symbolPrices[symbol];
        const weight = this.getAssetWeight(symbol);
        const lotSize = this.config.lotSize * weight;

        const tp = direction === 'BUY'
            ? currentPrice * (1 + this.config.tpPercent / 100)
            : currentPrice * (1 - this.config.tpPercent / 100);

        const position = {
            id: Date.now(),
            symbol,
            direction,
            entryPrice: currentPrice,
            currentPrice,
            tp,
            lotSize,
            openTime: new Date(),
            isHedged: false,
            hedgeId: null,
            profit: 0
        };

        this.positions.push(position);
        this.log(`✓ Operação aberta: ${symbol} ${direction} | Entrada: ${currentPrice.toFixed(2)} | TP: ${tp.toFixed(2)}`, 'success');
        return position;
    }

    updatePositions() {
        this.updatePrices();

        for (let i = this.positions.length - 1; i >= 0; i--) {
            const pos = this.positions[i];
            const currentPrice = this.symbolPrices[pos.symbol];
            pos.currentPrice = currentPrice;

            // Calcular lucro
            if (pos.direction === 'BUY') {
                pos.profit = (currentPrice - pos.entryPrice) * pos.lotSize * 100;
            } else {
                pos.profit = (pos.entryPrice - currentPrice) * pos.lotSize * 100;
            }

            // Verificar TP
            if (pos.direction === 'BUY' && currentPrice >= pos.tp) {
                this.closePosition(i, 'TP Atingido');
                continue;
            }
            if (pos.direction === 'SELL' && currentPrice <= pos.tp) {
                this.closePosition(i, 'TP Atingido');
                continue;
            }

            // Verificar Hedge
            if (!pos.isHedged) {
                const drawdown = Math.abs(pos.profit) / (pos.entryPrice * pos.lotSize * 100);
                if (drawdown >= this.config.hedgePercent / 100) {
                    this.activateHedge(i);
                }
            }
        }
    }

    activateHedge(posIndex) {
        const pos = this.positions[posIndex];
        const hedgeDirection = pos.direction === 'BUY' ? 'SELL' : 'BUY';
        const currentPrice = pos.currentPrice;

        const hedgePosition = {
            id: Date.now(),
            symbol: pos.symbol,
            direction: hedgeDirection,
            entryPrice: currentPrice,
            currentPrice,
            tp: pos.entryPrice,
            lotSize: pos.lotSize,
            openTime: new Date(),
            isHedged: false,
            parentId: pos.id,
            profit: 0
        };

        this.positions.push(hedgePosition);
        pos.isHedged = true;
        this.stats.hedgesActivated++;
        this.log(`🛡️ Hedge ativado para ${pos.symbol} | Direção: ${hedgeDirection}`, 'warning');
    }

    closePosition(index, reason) {
        const pos = this.positions[index];
        this.stats.totalTrades++;

        if (pos.profit >= 0) {
            this.stats.winningTrades++;
        } else {
            this.stats.losingTrades++;
        }

        this.stats.totalProfit += pos.profit;
        this.stats.maxProfit = Math.max(this.stats.maxProfit, pos.profit);
        this.stats.maxLoss = Math.min(this.stats.maxLoss, pos.profit);

        const trade = {
            symbol: pos.symbol,
            direction: pos.direction,
            entry: pos.entryPrice,
            close: pos.currentPrice,
            profit: pos.profit,
            closeTime: new Date(),
            reason
        };
        this.trades.push(trade);

        this.log(`✓ Operação fechada: ${pos.symbol} | Motivo: ${reason} | Lucro: $${pos.profit.toFixed(2)}`, 'success');
        this.positions.splice(index, 1);
    }

    update() {
        this.updatePositions();
        this.profitHistory.push(this.stats.totalProfit);
        this.updateUI();
    }

    updateUI() {
        // Status
        document.getElementById('openPositions').textContent = this.positions.length;
        document.getElementById('totalProfit').textContent = (this.stats.totalProfit >= 0 ? '+' : '') + '$' + this.stats.totalProfit.toFixed(2);
        document.getElementById('totalProfit').className = this.stats.totalProfit >= 0 ? 'profit' : 'loss';
        const winRate = this.stats.totalTrades > 0 ? ((this.stats.winningTrades / this.stats.totalTrades) * 100).toFixed(1) : '0';
        document.getElementById('winRate').textContent = winRate + '%';

        // Estatísticas
        document.getElementById('totalTrades').textContent = this.stats.totalTrades;
        document.getElementById('winningTrades').textContent = this.stats.winningTrades;
        document.getElementById('losingTrades').textContent = this.stats.losingTrades;
        document.getElementById('hedgesActivated').textContent = this.stats.hedgesActivated;
        document.getElementById('maxProfit').textContent = '+$' + this.stats.maxProfit.toFixed(2);
        document.getElementById('maxLoss').textContent = '-$' + Math.abs(this.stats.maxLoss).toFixed(2);

        // Posições
        this.updatePositionsTable();

        // Gráfico
        this.updateChart();
    }

    updatePositionsTable() {
        const container = document.getElementById('positionsTable');
        if (this.positions.length === 0) {
            container.innerHTML = '<p style="text-align: center; color: #999;">Nenhuma posição aberta</p>';
            return;
        }

        let html = '<table class="table"><thead><tr><th>Símbolo</th><th>Direção</th><th>Entrada</th><th>Atual</th><th>Lucro</th><th>% Ganho</th></tr></thead><tbody>';
        for (let pos of this.positions) {
            const pct = ((pos.profit / (pos.entryPrice * pos.lotSize * 100)) * 100).toFixed(1);
            const badgeClass = pos.direction === 'BUY' ? 'badge-buy' : 'badge-sell';
            const profitClass = pos.profit >= 0 ? 'success' : 'danger';
            html += `<tr>
                <td><span class="symbol-badge">${pos.symbol}</span></td>
                <td><span class="symbol-badge ${badgeClass}">${pos.direction}</span></td>
                <td>${pos.entryPrice.toFixed(4)}</td>
                <td>${pos.currentPrice.toFixed(4)}</td>
                <td class="${profitClass}">$${pos.profit.toFixed(2)}</td>
                <td>${pct}%</td>
            </tr>`;
        }
        html += '</tbody></table>';
        container.innerHTML = html;
    }

    updateChart() {
        if (!this.chart) {
            const ctx = document.getElementById('profitChart').getContext('2d');
            this.chart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: Array.from({ length: this.profitHistory.length }, (_, i) => i),
                    datasets: [{
                        label: 'Lucro/Prejuízo Acumulado ($)',
                        data: this.profitHistory,
                        borderColor: '#667eea',
                        backgroundColor: 'rgba(102, 126, 234, 0.1)',
                        tension: 0.4,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    plugins: { legend: { display: true } },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function(value) {
                                    return '$' + value.toFixed(0);
                                }
                            }
                        }
                    }
                }
            });
        } else {
            this.chart.data.labels = Array.from({ length: this.profitHistory.length }, (_, i) => i);
            this.chart.data.datasets[0].data = this.profitHistory;
            this.chart.update();
        }
    }

    start() {
        this.running = true;
        this.loadConfig();
        document.getElementById('startSimulation').disabled = true;
        document.getElementById('stopSimulation').disabled = false;
        this.log('🟢 Simulação iniciada', 'success');
        this.simulationLoop();
    }

    stop() {
        this.running = false;
        document.getElementById('startSimulation').disabled = false;
        document.getElementById('stopSimulation').disabled = true;
        this.log('🔴 Simulação parada', 'warning');
    }

    reset() {
        this.positions = [];
        this.trades = [];
        this.stats = {
            totalTrades: 0,
            winningTrades: 0,
            losingTrades: 0,
            hedgesActivated: 0,
            totalProfit: 0,
            maxProfit: 0,
            maxLoss: 0
        };
        this.profitHistory = [];
        this.initializePrices();
        this.running = false;
        document.getElementById('startSimulation').disabled = false;
        document.getElementById('stopSimulation').disabled = true;
        this.updateUI();
        this.log('🔄 Simulação resetada', 'info');
    }

    log(message, type = 'info') {
        const logContainer = document.getElementById('logContainer');
        const entry = document.createElement('p');
        entry.className = `log-entry ${type}`;
        const time = new Date().toLocaleTimeString();
        entry.textContent = `[${time}] ${message}`;
        logContainer.insertBefore(entry, logContainer.firstChild);
        if (logContainer.children.length > 100) {
            logContainer.removeChild(logContainer.lastChild);
        }
    }

    simulationLoop() {
        if (!this.running) return;

        const iterations = this.speed;
        for (let i = 0; i < iterations; i++) {
            if (Math.random() > 0.7) {
                this.createPosition();
            }
            this.update();
        }

        setTimeout(() => this.simulationLoop(), 500);
    }
}

// Inicializar
let simulator;

document.addEventListener('DOMContentLoaded', function() {
    simulator = new HedgeRobotSimulator();
    simulator.initializePrices();
    simulator.updateUI();

    document.getElementById('startSimulation').addEventListener('click', () => simulator.start());
    document.getElementById('stopSimulation').addEventListener('click', () => simulator.stop());
    document.getElementById('resetSimulation').addEventListener('click', () => simulator.reset());
    document.getElementById('applyConfig').addEventListener('click', () => simulator.loadConfig());

    document.getElementById('speedSlider').addEventListener('input', function() {
        simulator.speed = parseInt(this.value);
        document.getElementById('speedValue').textContent = this.value + 'x';
    });

    document.getElementById('fastForward').addEventListener('click', () => {
        for (let i = 0; i < 50; i++) {
            if (Math.random() > 0.7) simulator.createPosition();
            simulator.update();
        }
    });
});
