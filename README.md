# 🤖 HEDGE ROBOT v1.0
## Robô de Hedge Multiativos para MetaTrader 5 (MQL5)

**Desenvolvido por:** DufazGrana Money  
**Plataforma:** MetaTrader 5 (MT5)  
**Linguagem:** MQL5  
**Versão:** 1.0

---

## 📋 Descrição

Robô automático de trading que trabalha com:
- ✅ **Forex** (EURUSD, GBPUSD, USDJPY, etc)
- ✅ **Ouro** (XAUUSD)
- ✅ **Criptomoedas** (BTCUSD, ETHUSD, etc)

### Funcionalidades Principais:
1. **Hedge Automático**: Abre operação contrária em 10% de drawdown
2. **Take Profit Inteligente**: 10% de lucro sobre o total da operação
3. **Múltiplos Ativos**: Controla vários símbolos simultaneamente
4. **Ajuste de Spread**: Personalização por ativo
5. **Pesos/Percentuais**: Configure % de entrada para cada ativo
6. **Análise de Tendência**: Apenas entra com a tendência
7. **Reabrir Posições**: Fecha com lucro e abre nova automaticamente

---

## 🚀 Instalação Rápida

### Opção 1: MetaTrader 5 Desktop (Windows)

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/dufazgranamoney-ship-it/hedge-robot.git
   ```

2. **Copie os arquivos:**
   - Vá até: `C:\Users\[SeuUsuário]\AppData\Roaming\MetaQuotes\Terminal\[ID]\MQL5\Experts`
   - Cole a pasta `hedge-robot`

3. **Abra MetaTrader 5:**
   - Menu: `View > Navigator > Expert Advisors`
   - Clique com botão direito > `Refresh`
   - Arraste `HedgeRobot.mq5` para um gráfico
   - Configure os parâmetros
   - Clique em `Start`

### Opção 2: MetaTrader 5 Mobile (Android/iOS)

**Método Recomendado: VPS + Monitoramento Mobile**

1. **Contrate um VPS:**
   - Recomendado: Contato da sua corretora
   - Custo: ~R$30-50/mês

2. **Configure no VPS:**
   - Instale MT5 no VPS
   - Coloque o EA na pasta de Expert Advisors
   - Deixe rodando 24/7

3. **Monitore via Celular:**
   - Baixe MT5 para Android/iOS
   - Faça login na conta de trading
   - Veja operações abertas em tempo real
   - Feche operações manualmente se necessário

---

## ⚙️ Configuração de Parâmetros

### Parâmetros Principais

```
📊 Símbolos: EURUSD,GBPUSD,USDJPY,XAUUSD,BTCUSD,ETHUSD
   (Separados por vírgula)

💰 Lote Padrão: 0.1
   (Tamanho inicial de cada operação)

📈 TP (Take Profit): 10%
   (Lucro que fecha a operação automaticamente)

🛡️ Hedge: 10%
   (Ativa operação contrária em 10% de drawdown)

📊 Média Móvel: 20 períodos
   (Para confirmar tendência)
```

### Pesos por Ativo (Distribuição de Capital)

```
💱 Forex Weight: 30%
   (EUR, GBP, USD, JPY)

🏆 Gold Weight: 30%
   (Ouro - XAU)

₿ Crypto Weight: 40%
   (Bitcoin, Ethereum)
```

---

## 📱 Teste em Tempo Real via Web

**Acesse:** [Clique aqui para acessar o Dashboard](./web-test/index.html)

Ou abra o arquivo `web-test/index.html` em seu navegador.

### Dashboard Web Inclui:
- ✅ Simulação de operações em tempo real
- ✅ Gráfico de lucro/prejuízo
- ✅ Estatísticas de hedge
- ✅ Visualização de posições abertas
- ✅ Funciona em qualquer celular/PC

---

## 📊 Estrutura do Projeto

```
hedge-robot/
├── HedgeRobot.mq5          # EA Principal
├── Config/
│   └── Settings.mqh        # Configurações e Enums
├── Classes/
│   ├── TrendAnalyzer.mqh   # Análise de Tendência
│   ├── TradeManager.mqh    # Gerenciamento de Trades
│   └── HedgeManager.mqh    # Gerenciamento de Hedges
├── web-test/
│   ├── index.html          # Dashboard de Teste
│   ├── style.css           # Estilo
│   └── script.js           # Lógica de Simulação
└── README.md               # Este arquivo
```

---

## 🎯 Como Funciona

### Fluxo de Operação:

```
1️⃣ ENTRADA
   └─ Analisa tendência (Média Móvel 20)
   └─ Se tendência UP: Compra
   └─ Se tendência DOWN: Vende
   └─ TP = Preço ± 10%

2️⃣ MONITORAMENTO
   └─ Acompanha cada operação
   └─ Se lucro = 10%, FECHA e abre nova
   └─ Se prejuízo = 10%, ativa HEDGE

3️⃣ HEDGE (Proteção)
   └─ Abre operação contrária
   └─ Mesmo tamanho de lote
   └─ TP no ponto de entrada (breakeven)
   └─ Trava a posição

4️⃣ SEGUIR TENDÊNCIA
   └─ Se continuar contra, abre outra operação
   └─ A cada 10% de piora, nova operação
   └─ Até ganhar e fechar tudo
```

---

## 💡 Exemplo Prático

### Cenário: EURUSD

```
📍 Preço: 1.1000 (Tendência UP)
💰 Lote: 0.1
🎯 TP: 1.1100 (10% acima)
🛡️ Hedge em: 0.9900 (10% abaixo)

─── CENÁRIO 1: Sucesso ───
Preço vai para 1.1100 → TP atingido → Fechado com lucro ✓
Nova operação abre automaticamente

─── CENÁRIO 2: Drawdown ───
Preço cai para 0.9900 → Ativa Hedge
Abre VENDA de 0.1 em 0.9900
Trata a posição e segue
```

---

## ⚠️ Avisos Importantes

⚡ **Risco de Trading:**
- Trading com alavancagem envolve risco de perda total
- Comece com valores pequenos
- Não invista dinheiro que não pode perder
- Faça backtesting antes de usar com dinheiro real

🔒 **Segurança:**
- Nunca compartilhe sua senha da conta
- Use VPS confiável
- Monitore regularmente as operações
- Tenha suporte 24/7 da corretora

📈 **Recomendações:**
- Teste em conta Demo por 1 mês
- Comece com lotes pequenos (0.01-0.05)
- Ajuste parâmetros conforme sua experiência
- Mantenha controle sobre o capital

---

## 🛠️ Suporte e Customização

### Problemas Comuns?

**EA não aparece em MT5:**
- Salve o arquivo na pasta correta
- Reinicie MT5
- Verifique se MQL5 não tem erros de compilação

**Operações não abrem:**
- Verifique se conta tem saldo suficiente
- Confirme se símbolos existem na corretora
- Cheque se trading está habilitado

**Hedge não ativa:**
- Verifique limite de posições abertas
- Aumente o DrawDown trigger se necessário
- Teste com valores maiores

---

## 📞 Informações de Contato

**GitHub:** [@dufazgranamoney-ship-it](https://github.com/dufazgranamoney-ship-it)  
**Email:** dufazgranamoney@gmail.com

---

## 📄 Licença

MIT License - Sinta-se livre para usar e modificar

---

**Versão:** 1.0  
**Data:** 2026-05-05  
**Status:** ✅ Pronto para Produção
