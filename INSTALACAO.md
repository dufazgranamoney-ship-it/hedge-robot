# 📦 Guia Completo de Instalação

## 1️⃣ INSTALAÇÃO NO WINDOWS (Desktop)

### Passo 1: Download e Clone
```bash
git clone https://github.com/dufazgranamoney-ship-it/hedge-robot.git
cd hedge-robot
```

### Passo 2: Localizar Pasta de Expert Advisors

**Caminho padrão:**
```
C:\Users\[SEU_USUARIO]\AppData\Roaming\MetaQuotes\Terminal\[TERMINAL_ID]\MQL5\Experts
```

**Como encontrar:**
1. Abra MetaTrader 5
2. Menu: `File > Open Data Folder`
3. Navegue até: `MQL5 > Experts`

### Passo 3: Copiar Arquivos

1. Copie a pasta `hedge-robot` para a pasta `Experts`
2. Estrutura final:
```
Experts/
└── hedge-robot/
    ├── HedgeRobot.mq5
    ├── Config/
    │   └── Settings.mqh
    └── Classes/
        ├── TrendAnalyzer.mqh
        ├── TradeManager.mqh
        └── HedgeManager.mqh
```

### Passo 4: Recarregar no MetaTrader 5

1. Abra MetaTrader 5
2. Menu: `View > Navigator` (Ctrl+N)
3. Clique com botão direito em `Expert Advisors`
4. Selecione `Refresh`
5. Procure por `HedgeRobot`

### Passo 5: Ativar o EA

1. Abra um gráfico (Ex: EURUSD)
2. Arraste `HedgeRobot` do Navigator para o gráfico
3. Janela de configuração abrirá
4. Configure os parâmetros (veja abaixo)
5. Clique em `Start`
6. Você verá "Expert Advisor loaded successfully"

---

## 2️⃣ CONFIGURAÇÃO DE PARÂMETROS

### Parâmetros Básicos

| Parâmetro | Valor Padrão | Descrição |
|-----------|--------------|----------|
| **Symbols** | EURUSD,GBPUSD,USDJPY,XAUUSD,BTCUSD,ETHUSD | Símbolos separados por vírgula |
| **LotSize** | 0.1 | Tamanho do lote padrão |
| **SpreadAdjustment** | 1.5 | Ajuste de spread em % |
| **TakeProfitPercent** | 10.0 | TP em % do preço de entrada |
| **HedgeActivationPercent** | 10.0 | Ativa hedge em % de drawdown |
| **MAPeriod** | 20 | Período da Média Móvel |

### Exemplo de Configuração Conservadora

```
Symbols: EURUSD,GBPUSD,XAUUSD
LotSize: 0.05
TakeProfitPercent: 10.0
HedgeActivationPercent: 10.0
ForexWeight: 50%
GoldWeight: 50%
```

### Exemplo de Configuração Agressiva

```
Symbols: EURUSD,GBPUSD,USDJPY,XAUUSD,BTCUSD,ETHUSD
LotSize: 0.5
TakeProfitPercent: 15.0
HedgeActivationPercent: 15.0
ForexWeight: 30%
GoldWeight: 20%
CryptoWeight: 50%
```

---

## 3️⃣ INSTALAÇÃO EM VPS (Para Rodar 24/7)

### Opção Recomendada: VPS Windows

**Corretoras que oferecem VPS:**
- XM
- Pepperstone
- IC Markets
- FXOPEN

### Passo 1: Contratar VPS

1. Entre na corretora
2. Menu: `Account > Tools > VPS`
3. Selecione o plano (geralmente 1º mês grátis)
4. Ative o VPS

### Passo 2: Conectar ao VPS

**Windows:**
1. Abra `Conexão de Área de Trabalho Remota`
2. Endereço: [IP fornecido pela corretora]
3. Usuário: [Fornecido]
4. Senha: [Fornecida]
5. Conecte

**Mac/Linux:**
```bash
rdesktop -u [usuario] -p [senha] [IP_VPS]
```

### Passo 3: Instalar MT5 no VPS

1. Download MT5: https://www.metatrader5.com/pt/download
2. Instale normalmente
3. Faça login com sua conta
4. Copie os arquivos do EA (mesmo processo do Windows)

### Passo 4: Deixar Rodando

1. Abra MT5
2. Ative o EA
3. **NÃO desligue o VPS**
4. Feche a conexão RDP (EA continua rodando)

---

## 4️⃣ MONITORAMENTO VIA CELULAR

### Baixar MetaTrader 5 Mobile

**Android:**
- Play Store > MetaTrader 5
- Download: https://play.google.com/store/apps/details?id=com.metaquotes.metatrader5

**iOS:**
- App Store > MetaTrader 5
- Download: https://apps.apple.com/br/app/metatrader-5/id413251529

### Conectar à Conta

1. Abra o app MT5
2. Menu: `Account > Login`
3. Digite seu servidor (Ex: XM-Demo, XM-Real)
4. Usuário e Senha
5. Conecte

### Visualizar Operações

1. Menu: `Trade`
2. Você verá todas as posições abertas
3. Deslize para ver detalhes
4. Toque em uma posição para fechar (se necessário)

---

## 5️⃣ TESTE EM CONTA DEMO

### ⚠️ SEMPRE teste primeiro em DEMO!

1. Abra MT5
2. Menu: `File > Login`
3. Selecione uma corretora (Ex: MetaQuotes Demo)
4. Escolha `Demo Account`
5. Crie uma conta
6. Ative o EA no Demo
7. Deixe rodar por 1-2 semanas
8. Acompanhe os resultados

---

## 6️⃣ MUDAR PARA CONTA REAL

### Checklist Final:

- [ ] Testou 2+ semanas em Demo
- [ ] Teve retorno positivo consistente
- [ ] Configurou parâmetros conservadores
- [ ] Tem saldo suficiente na conta
- [ ] Compreendeu os riscos
- [ ] Tem backup dos arquivos

### Ativar em Conta Real:

1. Faça login com conta real em MT5
2. Copie os mesmos arquivos
3. Ative o EA (comece com lotes pequenos)
4. Monitore diariamente
5. Ajuste se necessário

---

## ⚠️ CHECKLIST DE SEGURANÇA

- [ ] Antivírus atualizado
- [ ] Firewall ativado
- [ ] Senha forte na conta MT5
- [ ] VPS com senha forte (se usar)
- [ ] Backup dos arquivos em outro local
- [ ] Não compartilhe arquivos da conta
- [ ] Atualize MT5 regularmente
- [ ] Mantenha PC/VPS seguro

---

## 🐛 SOLUÇÃO DE PROBLEMAS

### Erro: "Expert Advisor not found"
- Verifique caminho da pasta
- Reinicie MT5
- Recompile o EA

### Erro: "Cannot open position"
- Verifique saldo suficiente
- Símbolos existem na corretora?
- Spread muito alto?
- Trading habilitado?

### EA não abre operações
- Verifique se EA está realmente ativo
- Confira os símbolos
- Aumente período da MA
- Teste com mais ativos

### Hedge não funciona
- Verifique limite de posições
- Aumente valor de drawdown
- Teste com valores maiores

---

**Pronto! Seu EA está instalado e pronto para usar! 🚀**
