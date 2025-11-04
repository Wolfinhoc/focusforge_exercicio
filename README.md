# focusforge
Aluno: Bruno Rocco Wolfardt

## PRD — FocusForge: Primeira Execução, Consentimento e Identidade
**Versão**: v1.0

### 1) Visão Geral
**Resumo**: FocusForge é um app de gestão de foco baseado em ciclos Pomodoro com metas de sessão. Na primeira execução, guia o usuário pelo onboarding, apresentação do ciclo padrão (25/5), leitura das políticas e opt-in de notificações.
**Problemas que ataca**: Desorientação na primeira execução, falta de persistência de consentimentos, sobrecarga de decisões antes do usuário entender o fluxo.
**Resultado desejado**: Experiência inicial curta, guiada e memorável; consentimentos persistidos e editáveis; usuário pronto para iniciar o primeiro ciclo.

---

## PRD — FocusForge: Persistência Local + CRUD com Repository
**Versão**: v2.0

### 1) Visão Geral
**Resumo**: Esta fase introduz a persistência local para os ciclos de foco do usuário, permitindo que os dados sejam salvos no dispositivo. A funcionalidade é construída sobre o Padrão Repository para garantir uma arquitetura limpa e escalável, com uma experiência de usuário offline-first.

**Problemas que ataca**:
- Perda de dados do usuário ao fechar o aplicativo.
- Falta de uma camada de abstração de dados, acoplando a UI à implementação de armazenamento.
- Experiência de usuário lenta ou dependente de conexão de rede.

**Resultado desejado**:
- CRUD completo (Criar, Ler, Atualizar, Deletar) para a entidade `Cycle`.
- Dados persistidos localmente usando `SharedPreferences`.
- UI responsiva que carrega dados instantaneamente do cache local (UI Otimista).
- Base para sincronização incremental com um backend.

### 2) Requisitos Funcionais (RF)
- **RF-9**: Implementar o CRUD completo para a entidade `Cycle` através da interface `CycleRepository`.
- **RF-10**: A UI deve refletir as alterações do CRUD instantaneamente (UI Otimista), atualizando o estado local antes da conclusão da operação de persistência.
- **RF-11**: Implementar um mecanismo de sincronização incremental (`syncIncremental`) que compara o `updatedAt` dos registros para mesclar dados de uma fonte remota com o cache local.
- **RF-12**: Ao abrir o aplicativo, os dados devem ser carregados do cache local imediatamente, enquanto uma sincronização em segundo plano é disparada para buscar atualizações.

### 3) Arquitetura e Padrões
- **Repository Pattern**: A lógica de acesso aos dados é abstraída pela interface `CycleRepository`. A `SharedPreferencesCycleRepository` é a implementação concreta para persistência local.
- **Entity/DTO/Mapper**:
    - `Cycle`: Entidade de domínio com tipagem forte e regras de negócio.
    - `CycleDTO`: Objeto de Transferência de Dados para serialização/desserialização.
    - `CycleMapper`: Converte os dados entre `Entity` e `DTO`.
- **Offline-First**: A aplicação prioriza o carregamento de dados do cache local para uma experiência de usuário rápida e funcional, mesmo sem conexão de rede.

### 4) Dados & Persistência (chaves)
- **focus_cycles_v1**: `string` (JSON contendo a lista de todos os ciclos do usuário).
- **last_sync**: `string` (Data no formato ISO8601 da última sincronização bem-sucedida).
