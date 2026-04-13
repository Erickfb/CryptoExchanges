# App iOS de Exchanges de Criptomoedas

Aplicação iOS profissional que exibe exchanges de criptomoedas e suas moedas usando a API do CoinMarketCap.

## Funcionalidades

### Tela de Listagem de Exchanges
- Lista de exchanges com logo, nome, volume 24h (USD) e data de lançamento
- Estados de carregamento e tratamento de erros com retry
- Navegação para detalhes da exchange

### Tela de Detalhes da Exchange
- Informações completas: logo, nome, ID, descrição, website, taxas (maker/taker), data de lançamento
- Lista de moedas com nome, símbolo e preço em USD
- Busca de moedas em tempo real
- Layout rolável com carregamento assíncrono

## Requisitos Técnicos

- **Plataforma**: iOS 15.0+
- **Linguagem**: Swift 5.9+
- **UI**: UIKit com View Code (sem Storyboards)
- **Arquitetura**: MVVM-C (Model-View-ViewModel-Coordinator)
- **Testes**: Unitários (ViewModels, Services, Models) e UI (navegação e interações)

## Como Executar

### 1. Clone o repositório
```bash
git clone <repository-url>
cd CryptoExchanges
```

### 2. Configure a API Key e gere o projeto
```bash
# Instale o XcodeGen (se necessário)
brew install xcodegen

# Execute o setup (valida .env, exige a key e roda o xcodegen)
bash ./setup.sh
```

O script `bash ./setup.sh` irá:
- Criar o arquivo `.env` caso não exista
- Bloquear e exibir instruções caso `COINMARKETCAP_API_KEY` esteja vazia
- Executar `xcodegen generate` automaticamente após validar a key

**Obter API Key:**
1. Crie uma conta em [CoinMarketCap Pro](https://pro.coinmarketcap.com/account)
2. Copie sua API key
3. Edite o arquivo `.env` na raiz do projeto:
   ```
   COINMARKETCAP_API_KEY=sua_chave_aqui
   ```
4. Execute `bash ./setup.sh` novamente

```bash
# Abra o projeto
open CryptoExchanges.xcodeproj
```

No Xcode:
1. Selecione o target "CryptoExchanges"
2. Escolha um simulador iOS
3. Pressione Cmd+R

## Estrutura do Projeto

```
CryptoExchanges/
├── Sources/
│   ├── App/              # AppDelegate e configurações
│   ├── Coordinators/     # Gerenciamento de navegação
│   ├── Models/           # Estruturas de dados
│   ├── Services/         # Integração com API
│   ├── ViewModels/       # Lógica de negócio
│   ├── Views/            # ViewControllers e Cells
│   └── Utils/            # Helpers e utilitários
└── Tests/
    ├── UnitTests/        # Testes de lógica
    └── UITests/          # Testes de interface
```

## Arquitetura MVVM-C

- **Models**: Estruturas de dados da API
- **Views**: ViewControllers com UI programática
- **ViewModels**: Lógica de negócio e gerenciamento de estado
- **Coordinators**: Controle de fluxo de navegação

## Testes

### Executar testes
```bash
swift test
```
Ou no Xcode: **Cmd+U**

### Cobertura
- ViewModels (lógica de negócio)
- Services (chamadas de API)
- Models (parsing de dados)
- Navegação e interações do usuário
- Cenários de erro

## API Integration

Usa a API Professional v1 do CoinMarketCap:
- **/exchange/map**: Lista exchanges com metadados
- **/exchange/info**: Informações detalhadas da exchange (descrição, website, taxas)
- **/exchange/assets**: Retorna moedas por exchange

## Requisitos Atendidos

### Funcionais
- ✅ Swift 5+
- ✅ View Code (sem Storyboards)
- ✅ Arquitetura MVVM-C
- ✅ Testes Unitários e UI
- ✅ Lista de exchanges com campos obrigatórios
- ✅ Detalhes da exchange com moedas

### Não Funcionais
- ✅ **UI/UX Fluída**: UIKit nativo seguindo padrões iOS (Navigation, Search, Pull-to-refresh, Auto Layout, Dark Mode)
- ✅ **Resiliência**: Tratamento completo de erros com estados (loading/error/loaded), retry automático e logs estruturados
- ✅ **Escalabilidade**: Arquitetura modular com MVVM-C, protocols para dependency injection, código testável e preparado para crescimento

### Pronto para features futuras
- ✅ Paginação (só adicionar offset/limit)
- ✅ Persistência (só injetar cache layer)
- ✅ Filtros avançados (estrutura já existe)
- ✅ Favoritos (só adicionar storage)
- ✅ Analytics (Logger já estruturado)

## Ferramentas e Dependências

- **XcodeGen**: Gerenciamento de projeto Xcode via YAML (`project.yml`)
- **Swift Package Manager**: Sem dependências externas
- Frameworks nativos: Foundation, UIKit, XCTest

## Licença

Desenvolvido para fins de avaliação técnica.
