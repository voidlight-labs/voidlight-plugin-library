---
name: rust-craft
description: >-
  Enforces idiomatic Rust, strict standard-library-only production domains,
  and pragmatic 2-layer architecture for Axum and Actix codebases. Use when
  writing or reviewing Rust code in Axum or Actix projects.
metadata:
  version: '4.0.0'
  author: Voidlight
  applyTo: '**/*.rs'
  tags: [rust, axum, actix, systems, safety, architecture]
---

## Identity

This skill reviews and generates Rust with a strict two-layer boundary. Production domain code uses only the Rust standard library; frameworks, runtimes, serialization, persistence, and other crates belong in infrastructure. Public contracts stay explicit while local code uses idiomatic inference. Scope: `.rs` files. Consult project manifests and toolchain files before requiring external crates or tools.

## Mandatory Rules

### Rule 1: Single Responsibility
1. Give each function one coherent responsibility.
2. Give each module one primary reason to change.
3. Split code when business decisions and external I/O are interleaved.
4. Extract a helper only when it names a meaningful operation or removes duplication.
5. Keep validation that enforces entity invariants in the domain entity or value type.
6. Keep transport parsing and response formatting in infrastructure.
7. Keep persistence mapping and retry policy in infrastructure.
8. Prefer pure domain calculations when no port interaction is required.
9. Keep use cases focused on one business capability.
10. Refactor by cohesion and readability, not arbitrary line limits.

### Rule 2: Rust Naming
1. Follow Rust conventions: `snake_case` items, `UpperCamelCase` types, and `SCREAMING_SNAKE_CASE` constants.
2. Choose names that communicate domain intent in their scope.
3. Permit concise names such as `id`, `tx`, or `item` when the scope makes them unambiguous.
4. Name booleans as predicates when practical, such as `is_valid` or `can_retry`.
5. Use established project and ecosystem abbreviations consistently.
6. Name types as domain nouns and operations as verbs.
7. Name collections plurally when they represent multiple values.
8. Use idiomatic constructors such as `new`, `from`, and `try_from` when their semantics fit.
9. Name traits for capabilities or roles, such as `OrderRepository` or `Clock`.
10. Never impose a word-count or minimum-length rule on identifiers.

### Rule 3: Type Safety
1. Declare parameter and return types on public functions and methods.
2. Keep public fields and associated constants explicitly typed.
3. Let the compiler infer local variable and closure types when intent remains clear.
4. Use newtypes when equal primitive representations carry distinct domain meanings.
5. Represent absence with `Option<T>` and expected failure with `Result<T, E>`.
6. Prefer exhaustive enums for closed domain states.
7. Constrain generics with the smallest meaningful trait bounds.
8. Use trait objects only when runtime polymorphism is actually required.
9. Prefer checked conversions such as `try_from` when a conversion can fail or truncate.
10. Make ownership explicit at boundaries; borrow when the callee does not need ownership.

### Rule 4: Two-Layer Architecture
1. Put entities, value types, domain errors, ports, and use cases in `domain/`.
2. Put HTTP, serialization, databases, external clients, runtime code, and wiring in `infrastructure/`.
3. Require production domain code to compile with the Rust standard library only.
4. Define dependency-inversion ports in the domain.
5. Implement domain ports in infrastructure.
6. Wire concrete adapters to use cases in infrastructure.
7. Keep use cases callable without HTTP, a runtime, or a database.
8. Prevent framework DTOs and ORM models from crossing into domain APIs.
9. Map transport and persistence data to domain inputs and outputs at the boundary.
10. Add a boundary only when it protects a real dependency or business concept.

### Rule 5: Strict Production Domain Purity
1. Import only `std`, `core`, or `alloc` from production domain modules.
2. Do not derive or import `thiserror`, `serde`, or any other external macro in production domain code.
3. Implement `Display` and `std::error::Error` manually for domain errors.
4. Keep Axum, Actix, SQLx, Tokio, and their types out of production domain signatures.
5. Keep `uuid`, `chrono`, and external clock or identifier types out of production domain code.
6. Inject identifiers and time values through use-case inputs or domain ports.
7. Define domain ports without `async_trait` or runtime-specific types.
8. Use standard-library primitives or domain newtypes in port methods.
9. Permit test-only crates only outside the production domain dependency graph.
10. Reject any production domain dependency that requires a Cargo package beyond the standard library.

### Rule 6: Idiomatic Rust Design
1. Prefer enums and pattern matching for explicit state transitions.
2. Use iterators when they improve clarity; use loops when control flow is clearer.
3. Use `#[must_use]` when silently discarding a value is likely a bug.
4. Add `#[non_exhaustive]` only when a public cross-crate enum needs forward-compatible growth.
5. Derive traits only when their semantics are valid for the type.
6. Choose `String`, borrowed strings, `Cow`, and shared pointers from actual ownership needs.
7. Choose `Arc`, `Rc`, `Box`, or no pointer from actual sharing and dispatch needs.
8. Use builders only when staged construction or many optional fields justify them.
9. Prefer standard conversion traits over ad hoc conversion method names.
10. Favor simple concrete code until abstraction has a demonstrated use.

### Rule 7: Async and Concurrency
1. Keep domain ports synchronous unless the standard-library domain contract truly models concurrency.
2. Adapt synchronous domain ports to framework execution constraints in infrastructure.
3. Never block an async executor with long-running I/O or sleeps.
4. Own connection pools, runtimes, tasks, and cancellation in infrastructure.
5. Track spawned tasks or document an intentional detached-task lifecycle.
6. Bound concurrent work when inputs or resources are unbounded.
7. Minimize lock scope and never hold a blocking lock across `.await`.
8. Propagate cancellation for long-running infrastructure operations.
9. Use the runtime and synchronization primitives already selected by the manifest.
10. Add Tokio, tracing, benchmarking, fuzzing, or property-test tools only when the manifest and task call for them.

### Rule 8: Memory and Unsafe
1. Avoid `unsafe` when a safe implementation is practical.
2. Use `unsafe` only when required by FFI, a proven performance need, or a low-level invariant.
3. Put a nearby `SAFETY:` comment on every unsafe block explaining the invariant that makes it sound.
4. Keep unsafe blocks minimal and expose a safe API around them when possible.
5. Test boundary conditions that could violate an unsafe invariant.
6. Never use `static mut` for shared mutable state.
7. Avoid lifetime fabrication such as `Box::leak` unless permanent allocation is the intended ownership model.
8. Use checked numeric conversions when truncation or sign changes are possible.
9. Validate lengths, alignment, initialization, and aliasing before low-level memory operations.
10. Review unsafe code against the Rust reference and project safety policy instead of blanket-banning it.

### Rule 9: Error Handling
1. Model expected domain failures with a domain error enum.
2. Implement domain error formatting with `std::fmt::Display`.
3. Implement `std::error::Error` for domain errors when error chaining is useful.
4. Give domain error variants stable semantic meaning rather than transport status meaning.
5. Return `Result<T, E>` from fallible domain operations.
6. Map framework, serialization, and persistence errors at infrastructure boundaries.
7. Preserve useful causes or context without leaking infrastructure types into domain errors.
8. Never swallow an error; propagate, map, log, or intentionally handle it.
9. Avoid panic, `unwrap`, and `expect` in production request and domain paths.
10. Keep retry, timeout, and user-facing error rendering in infrastructure.

### Rule 10: Testing and Documentation
1. Test entity invariants and use cases through their public APIs.
2. Use standard `#[test]` and simple fake port implementations for domain unit tests.
3. Keep framework fixtures and test-only external crates outside production domain modules.
4. Test infrastructure mappings at transport and persistence boundaries.
5. Cover both successful behavior and meaningful error variants.
6. Document public contracts whose invariants or ownership are not obvious.
7. Keep rustdoc examples complete and consistent with the current API.
8. Run `cargo test` when a Cargo manifest exists and the affected crate can be built.
9. Run formatting, Clippy, docs, coverage, fuzzing, or benchmarks only when configured or requested by the manifest, toolchain, or task.
10. Report commands not run and the concrete reason instead of claiming unverified success.

## Forbidden Patterns

1. External crate imports or derives in production domain modules
2. Axum, Actix, Tokio, SQLx, ORM, or framework types in domain APIs
3. `thiserror`, `uuid`, `chrono`, `async_trait`, or `serde` in production domain code
4. Identifier or current-time generation hidden inside domain entities
5. Framework DTOs or persistence models passed directly to use cases
6. `unwrap()` or `expect()` in production request and domain paths
7. Panics used for expected business failures
8. Errors ignored through empty matches, discarded `Result` values, or silent fallback
9. `unsafe` without a concrete requirement and a nearby `SAFETY:` invariant
10. Broad unsafe blocks that include safe operations
11. Shared mutable state through `static mut`
12. Blocking sleeps or long blocking I/O on an async executor
13. Locks held across `.await`
14. `todo!()`, `unimplemented!()`, ellipsis, or placeholder code in delivered implementations
15. Blanket requirements for `Arc`, `Cow`, builders, local annotations, or identifier length

## Thinking Protocol

1. Classify each requested behavior as domain or infrastructure.
2. Inspect module layout, `Cargo.toml`, lockfile, and toolchain files before selecting crates, runtimes, or commands.
3. Define domain entities, errors, inputs, ports, and use-case contracts using standard-library types only.
4. Surface requirement conflicts explicitly and ask when the fixed constraints do not resolve them.
5. Implement infrastructure adapters, HTTP mapping, and wiring around the domain contracts.
6. Verify anatomy, domain imports, forbidden patterns, compilation or available checks, and rubric score before responding.

## Response Rules

1. Present domain files before infrastructure files.
2. Mark examples with `// === DOMAIN LAYER ===` and `// === INFRASTRUCTURE LAYER ===` banners.
3. Put the intended file path at the start of every code block.
4. Provide complete imports and define every referenced project symbol.
5. Do not emit placeholders, ellipsis, `todo!()`, or `unimplemented!()`.
6. Keep public signatures explicitly typed and allow idiomatic local inference.
7. State deviations or unresolved conflicts explicitly; never resolve them silently.
8. Require external crates and tools only when the project manifest or request supports them.
9. Report verification performed and checks not run.
10. Keep each example focused on one use case and end with a concise rubric score when scoring is requested.

## Context Awareness

1. Detect existing `domain/` and `infrastructure/` modules and extend rather than duplicate them.
2. Read `Cargo.toml` and workspace manifests before assuming dependency versions or feature flags.
3. Detect the Rust edition and minimum supported Rust version before using edition-sensitive features.
4. Detect Axum versus Actix and do not mix their infrastructure APIs.
5. Detect the selected async runtime and follow its established cancellation and synchronization patterns.
6. Follow the repository's `mod.rs` or file-module convention.
7. Resolve imports against the correct workspace crate and visibility boundaries.
8. Preserve established infrastructure error and test patterns while keeping the production domain standard-library-only.

## Scoring Rubric

| Category | Points |
|---|---:|
| Production domain standard-library purity | 25 |
| Two-layer boundary correctness | 20 |
| Type and ownership safety | 15 |
| Error handling | 15 |
| Rust idioms and maintainability | 10 |
| Unsafe and concurrency discipline | 10 |
| Testing and documentation | 5 |
| **Total** | **100** |

Grade bands: 97-100 = A+, 90-96 = A, 80-89 = B, 70-79 = C, 60-69 = D, below 60 = F.

## Example 1: Axum

Assumes the infrastructure crate manifest already declares compatible `axum`, `serde`, and async runtime dependencies.

```rust
// examples/axum-notes/src/domain.rs
// === DOMAIN LAYER ===
use std::error::Error;
use std::fmt::{self, Display, Formatter};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Note {
    id: String,
    body: String,
    created_at_epoch_seconds: u64,
}

impl Note {
    pub fn create(
        id: String,
        body: String,
        created_at_epoch_seconds: u64,
    ) -> Result<Self, CreateNoteError> {
        if id.trim().is_empty() {
            return Err(CreateNoteError::InvalidId);
        }
        if body.trim().is_empty() {
            return Err(CreateNoteError::EmptyBody);
        }
        Ok(Self {
            id,
            body,
            created_at_epoch_seconds,
        })
    }

    pub fn id(&self) -> &str {
        &self.id
    }

    pub fn body(&self) -> &str {
        &self.body
    }

    pub fn created_at_epoch_seconds(&self) -> u64 {
        self.created_at_epoch_seconds
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum CreateNoteError {
    InvalidId,
    EmptyBody,
    IdGeneration(String),
    Clock(String),
    Storage(String),
}

impl CreateNoteError {
    pub const fn code(&self) -> &'static str {
        match self {
            Self::InvalidId => "invalid_id",
            Self::EmptyBody => "empty_body",
            Self::IdGeneration(_) => "id_generation",
            Self::Clock(_) => "clock",
            Self::Storage(_) => "storage",
        }
    }
}

impl Display for CreateNoteError {
    fn fmt(&self, formatter: &mut Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidId => formatter.write_str("note id must not be empty"),
            Self::EmptyBody => formatter.write_str("note body must not be empty"),
            Self::IdGeneration(message) => write!(formatter, "id generation failed: {message}"),
            Self::Clock(message) => write!(formatter, "clock failed: {message}"),
            Self::Storage(message) => write!(formatter, "note storage failed: {message}"),
        }
    }
}

impl Error for CreateNoteError {}

pub trait NoteRepository: Send + Sync {
    fn save(&self, note: Note) -> Result<Note, CreateNoteError>;
}

pub trait IdGenerator: Send + Sync {
    fn next_id(&self) -> Result<String, CreateNoteError>;
}

pub trait Clock: Send + Sync {
    fn now_epoch_seconds(&self) -> Result<u64, CreateNoteError>;
}

pub struct CreateNote<R, I, C> {
    repository: R,
    id_generator: I,
    clock: C,
}

impl<R, I, C> CreateNote<R, I, C>
where
    R: NoteRepository,
    I: IdGenerator,
    C: Clock,
{
    pub fn new(repository: R, id_generator: I, clock: C) -> Self {
        Self {
            repository,
            id_generator,
            clock,
        }
    }

    pub fn execute(&self, body: String) -> Result<Note, CreateNoteError> {
        let id = self.id_generator.next_id()?;
        let created_at = self.clock.now_epoch_seconds()?;
        let note = Note::create(id, body, created_at)?;
        self.repository.save(note)
    }
}
```

```rust
// examples/axum-notes/src/infrastructure.rs
// === INFRASTRUCTURE LAYER ===
use crate::domain::{
    Clock, CreateNote, CreateNoteError, IdGenerator, Note, NoteRepository,
};
use axum::{
    extract::State,
    http::StatusCode,
    response::Json,
    routing::post,
    Router,
};
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, Mutex};
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Default)]
struct MemoryNoteRepository {
    notes: Mutex<Vec<Note>>,
}

impl NoteRepository for MemoryNoteRepository {
    fn save(&self, note: Note) -> Result<Note, CreateNoteError> {
        let mut notes = self
            .notes
            .lock()
            .map_err(|error| CreateNoteError::Storage(error.to_string()))?;
        notes.push(note.clone());
        Ok(note)
    }
}

#[derive(Default)]
struct SequenceIdGenerator {
    next_value: AtomicU64,
}

impl IdGenerator for SequenceIdGenerator {
    fn next_id(&self) -> Result<String, CreateNoteError> {
        let value = self.next_value.fetch_add(1, Ordering::Relaxed);
        Ok(format!("note-{value}"))
    }
}

struct SystemClock;

impl Clock for SystemClock {
    fn now_epoch_seconds(&self) -> Result<u64, CreateNoteError> {
        SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map(|duration| duration.as_secs())
            .map_err(|error| CreateNoteError::Clock(error.to_string()))
    }
}

type CreateNoteService = CreateNote<MemoryNoteRepository, SequenceIdGenerator, SystemClock>;

#[derive(Clone)]
struct AppState {
    create_note: Arc<CreateNoteService>,
}

#[derive(Debug, Deserialize)]
struct CreateNoteRequest {
    body: String,
}

#[derive(Debug, Serialize)]
struct NoteResponse {
    id: String,
    body: String,
    created_at_epoch_seconds: u64,
}

async fn create_note_handler(
    State(state): State<AppState>,
    Json(request): Json<CreateNoteRequest>,
) -> Result<(StatusCode, Json<NoteResponse>), (StatusCode, String)> {
    state
        .create_note
        .execute(request.body)
        .map(|note| {
            let response = NoteResponse {
                id: note.id().to_owned(),
                body: note.body().to_owned(),
                created_at_epoch_seconds: note.created_at_epoch_seconds(),
            };
            (StatusCode::CREATED, Json(response))
        })
        .map_err(map_create_note_error)
}

fn map_create_note_error(error: CreateNoteError) -> (StatusCode, String) {
    let status = match &error {
        CreateNoteError::InvalidId | CreateNoteError::EmptyBody => StatusCode::BAD_REQUEST,
        CreateNoteError::IdGeneration(_)
        | CreateNoteError::Clock(_)
        | CreateNoteError::Storage(_) => StatusCode::INTERNAL_SERVER_ERROR,
    };
    (status, error.code().to_owned())
}

pub fn app() -> Router {
    let service = CreateNote::new(
        MemoryNoteRepository::default(),
        SequenceIdGenerator::default(),
        SystemClock,
    );
    let state = AppState {
        create_note: Arc::new(service),
    };
    Router::new()
        .route("/notes", post(create_note_handler))
        .with_state(state)
}
```

```rust
// examples/axum-notes/src/lib.rs
pub mod domain;
pub mod infrastructure;
```

## Example 2: Actix Web

Assumes the infrastructure crate manifest already declares compatible `actix-web` and `serde` dependencies.

```rust
// examples/actix-accounts/src/domain.rs
// === DOMAIN LAYER ===
use std::error::Error;
use std::fmt::{self, Display, Formatter};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Account {
    id: String,
    username: String,
    created_at_epoch_seconds: u64,
}

impl Account {
    pub fn register(
        id: String,
        username: String,
        created_at_epoch_seconds: u64,
    ) -> Result<Self, RegisterAccountError> {
        if id.trim().is_empty() {
            return Err(RegisterAccountError::InvalidId);
        }
        if username.trim().is_empty() {
            return Err(RegisterAccountError::InvalidUsername);
        }
        Ok(Self {
            id,
            username,
            created_at_epoch_seconds,
        })
    }

    pub fn id(&self) -> &str {
        &self.id
    }

    pub fn username(&self) -> &str {
        &self.username
    }

    pub fn created_at_epoch_seconds(&self) -> u64 {
        self.created_at_epoch_seconds
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum RegisterAccountError {
    InvalidId,
    InvalidUsername,
    Storage(String),
}

impl RegisterAccountError {
    pub const fn code(&self) -> &'static str {
        match self {
            Self::InvalidId => "invalid_id",
            Self::InvalidUsername => "invalid_username",
            Self::Storage(_) => "storage",
        }
    }
}

impl Display for RegisterAccountError {
    fn fmt(&self, formatter: &mut Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidId => formatter.write_str("account id must not be empty"),
            Self::InvalidUsername => formatter.write_str("username must not be empty"),
            Self::Storage(message) => write!(formatter, "account storage failed: {message}"),
        }
    }
}

impl Error for RegisterAccountError {}

pub trait AccountRepository: Send + Sync {
    fn save(&self, account: Account) -> Result<Account, RegisterAccountError>;
}

pub struct RegisterAccount<R> {
    repository: R,
}

impl<R> RegisterAccount<R>
where
    R: AccountRepository,
{
    pub fn new(repository: R) -> Self {
        Self { repository }
    }

    pub fn execute(
        &self,
        id: String,
        username: String,
        created_at_epoch_seconds: u64,
    ) -> Result<Account, RegisterAccountError> {
        let account = Account::register(id, username, created_at_epoch_seconds)?;
        self.repository.save(account)
    }
}
```

```rust
// examples/actix-accounts/src/infrastructure.rs
// === INFRASTRUCTURE LAYER ===
use crate::domain::{Account, AccountRepository, RegisterAccount, RegisterAccountError};
use actix_web::{web, App, HttpResponse, HttpServer};
use serde::{Deserialize, Serialize};
use std::io;
use std::net::TcpListener;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, Mutex};
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Default)]
struct MemoryAccountRepository {
    accounts: Mutex<Vec<Account>>,
}

impl AccountRepository for MemoryAccountRepository {
    fn save(&self, account: Account) -> Result<Account, RegisterAccountError> {
        let mut accounts = self
            .accounts
            .lock()
            .map_err(|error| RegisterAccountError::Storage(error.to_string()))?;
        accounts.push(account.clone());
        Ok(account)
    }
}

type RegisterAccountService = RegisterAccount<MemoryAccountRepository>;

struct AppState {
    register_account: Arc<RegisterAccountService>,
    next_id: AtomicU64,
}

impl AppState {
    fn new() -> Self {
        Self {
            register_account: Arc::new(RegisterAccount::new(
                MemoryAccountRepository::default(),
            )),
            next_id: AtomicU64::new(1),
        }
    }
}

#[derive(Debug, Deserialize)]
struct RegisterAccountRequest {
    username: String,
}

#[derive(Debug, Serialize)]
struct AccountResponse {
    id: String,
    username: String,
    created_at_epoch_seconds: u64,
}

async fn register_account_handler(
    state: web::Data<AppState>,
    request: web::Json<RegisterAccountRequest>,
) -> HttpResponse {
    let sequence = state.next_id.fetch_add(1, Ordering::Relaxed);
    let id = format!("account-{sequence}");
    let created_at = match current_epoch_seconds() {
        Ok(value) => value,
        Err(message) => return HttpResponse::InternalServerError().body(message),
    };
    match state
        .register_account
        .execute(id, request.username.clone(), created_at)
    {
        Ok(account) => HttpResponse::Created().json(AccountResponse {
            id: account.id().to_owned(),
            username: account.username().to_owned(),
            created_at_epoch_seconds: account.created_at_epoch_seconds(),
        }),
        Err(error) => map_register_account_error(error),
    }
}

fn current_epoch_seconds() -> Result<u64, String> {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|duration| duration.as_secs())
        .map_err(|error| error.to_string())
}

fn map_register_account_error(error: RegisterAccountError) -> HttpResponse {
    match &error {
        RegisterAccountError::InvalidId | RegisterAccountError::InvalidUsername => {
            HttpResponse::BadRequest().body(error.code())
        }
        RegisterAccountError::Storage(_) => {
            HttpResponse::InternalServerError().body(error.code())
        }
    }
}

pub async fn run(listener: TcpListener) -> io::Result<()> {
    let state = web::Data::new(AppState::new());
    HttpServer::new(move || {
        App::new()
            .app_data(state.clone())
            .route("/accounts", web::post().to(register_account_handler))
    })
    .listen(listener)?
    .run()
    .await
}
```

```rust
// examples/actix-accounts/src/lib.rs
pub mod domain;
pub mod infrastructure;
```
