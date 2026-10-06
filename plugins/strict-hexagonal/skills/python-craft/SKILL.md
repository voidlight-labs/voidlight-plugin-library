---
name: python-craft
description: >-
  Enforces production-grade, two-layer Python architecture with a standard-
  library-only domain and typed FastAPI and SQLAlchemy 2.x infrastructure. Use
  when writing or reviewing Python code in FastAPI projects.
metadata:
  version: '4.0.0'
  author: Voidlight
  applyTo: '**/*.py'
  tags: [python, fastapi, sqlalchemy, typesafe, architecture, testing]
---

## Identity

This skill reviews and generates Python with one dependency direction: infrastructure depends on domain. Production domain code uses only the Python standard library. FastAPI, SQLAlchemy, serialization, persistence, transport, and composition stay in infrastructure. Tests may use project-approved test-only libraries without changing the production domain dependency rule.

## Mandatory Rules

### Rule 1: Two-Layer Architecture
1. Organize production code into exactly two conceptual layers: `domain/` and `infrastructure/`.
2. Put entities, value objects, domain errors, ports, and use cases in `domain/`.
3. Put HTTP boundaries, persistence adapters, external clients, configuration, and wiring in `infrastructure/`.
4. Allow dependencies from infrastructure to domain, never from domain to infrastructure.
5. Keep use cases callable without FastAPI, SQLAlchemy, HTTP requests, or database sessions.
6. Define ports in domain and implement them in infrastructure.
7. Pass domain types and standard-library types through port contracts.
8. Convert infrastructure records and transport models at the layer boundary.
9. Wire concrete adapters to use cases in infrastructure rather than constructing adapters in domain.
10. Extend an existing equivalent two-layer layout instead of creating duplicate architectural folders.

### Rule 2: Production Domain Purity
1. Restrict production files under `domain/` to Python standard-library imports and other domain modules.
2. Keep FastAPI, Pydantic, SQLAlchemy, database drivers, logging packages, and vendor SDKs out of domain.
3. Model expected business failures with descriptive domain exception types, not generic `ValueError`.
4. Keep domain errors independent of HTTP status codes, ORM exceptions, and transport payloads.
5. Express ports with `Protocol` or `abc` using complete typed method bodies, never unfinished stubs.
6. Put business invariants and state transitions on entities or focused domain services.
7. Keep use-case orchestration focused on domain decisions and port calls.
8. Inject nondeterministic collaborators such as clocks when deterministic behavior is required.
9. Use standard-library value types such as `UUID`, `Decimal`, `datetime`, and `Enum` where they fit the model.
10. Verify domain imports independently from test imports because test-only libraries are allowed only in tests.

### Rule 3: Infrastructure Boundaries
1. Validate and deserialize transport input in the HTTP boundary before invoking a use case.
2. Convert domain results into explicit response models in infrastructure.
3. Implement each domain port with an adapter dedicated to one external concern.
4. Translate database, network, and framework failures into domain or boundary errors at the owning boundary.
5. Keep domain exceptions free of FastAPI `HTTPException` and response classes.
6. Map domain errors to HTTP responses in a dedicated exception handler or mapping function.
7. Keep happy-path route and use-case code free of duplicated error-mapping branches.
8. Create sessions, clients, and adapters through infrastructure wiring with explicit lifetimes.
9. Use `Annotated` dependency aliases for typed FastAPI dependencies.
10. Keep authentication, authorization transport, rate limiting, metrics, and tracing in infrastructure.

### Rule 4: Python Type Safety
1. Fully annotate every public function, method, constructor, return type, and port contract.
2. Fully annotate public model attributes and domain entity fields.
3. Allow local inference when the assigned expression makes the type unambiguous.
4. Add a local annotation when inference is ambiguous, a collection starts empty, or narrowing needs help.
5. Avoid `Any` in public contracts; accept `object` and narrow it when genuinely unknown input is required.
6. Represent absence with `T | None` and narrow before use.
7. Use parameterized collections and generics rather than raw `list`, `dict`, `set`, or `type` annotations.
8. Use `NewType`, immutable value objects, or distinct classes when interchangeable primitives would hide domain mistakes.
9. Preserve precise return types across adapters and boundary conversion functions.
10. Follow the Python version declared by the project before using newer annotation syntax.

### Rule 5: Naming and Responsibility
1. Choose descriptive names that communicate domain intent without enforcing an arbitrary word count.
2. Name functions with an action and the concept they affect when that improves clarity.
3. Name booleans as predicates such as `is_active`, `has_access`, or `should_retry`.
4. Name collections with plural nouns and mappings by their relationship when useful.
5. Avoid vague names such as `data`, `thing`, `process`, or `handle` when a precise domain name exists.
6. Use short conventional names such as `id`, `url`, and `db` only where their meaning is immediate.
7. Give exception variables descriptive names ending in `_error` or `_failure`, never one-letter names.
8. Give each function, class, and module one cohesive responsibility rather than enforcing blanket line limits.
9. Extract logic when it has an independent contract, needs isolated tests, or obscures the caller.
10. Prefer direct readable code over helpers that merely rename one expression.

### Rule 6: Errors and Fallibility
1. Raise descriptive domain exceptions for expected invariant and business-rule failures.
2. Use a shared domain error base only when consumers need common handling.
3. Give machine-consumed domain errors stable codes or structured attributes.
4. Preserve the original exception as the cause when an adapter translates an infrastructure failure.
5. Catch only exceptions the current boundary can translate, recover from, or enrich.
6. Never use a bare `except` or silently discard a failure.
7. Let unexpected programming failures propagate to centralized observability and failure handling.
8. Keep retry, timeout, and circuit-breaker behavior in infrastructure.
9. Separate HTTP error mapping from happy-path route logic through handlers or focused mappers.
10. Document port failure semantics when callers must make a domain decision from them.

### Rule 7: SQLAlchemy 2.x Persistence
1. Declare ORM bases by subclassing `DeclarativeBase`.
2. Declare mapped attributes with `Mapped[T]` and `mapped_column`.
3. Build reads with `select` and execute them through typed `Session` APIs.
4. Do not use legacy `declarative_base`, untyped `Column` attributes, or `Session.query`.
5. Keep ORM rows in infrastructure and map them explicitly to domain entities.
6. Type repository constructors and store a typed `Session` or `AsyncSession`.
7. Define transaction ownership explicitly in the adapter or infrastructure service boundary.
8. Roll back a failed transaction before translating or re-raising its exception.
9. Use parameterized SQLAlchemy expressions rather than interpolated SQL strings.
10. Match sync or async SQLAlchemy usage to the existing project instead of mixing both styles.

### Rule 8: Testing Discipline
1. Test domain entities and use cases without FastAPI clients, ORM sessions, database fixtures, or framework fixtures.
2. Use handwritten fakes or standard-library mocks at domain port boundaries.
3. Permit test-only libraries such as `pytest` or Hypothesis when the project already configures or requests them.
4. Keep production domain dependencies standard-library-only even when domain tests import test libraries.
5. Test business outcomes and observable state rather than private implementation details.
6. Add contract tests for each infrastructure adapter's port semantics.
7. Add HTTP tests for validation, response conversion, and centralized domain-error mapping.
8. Use real infrastructure resources only in infrastructure integration tests.
9. Cover success, domain failure, infrastructure translation, and transaction rollback where applicable.
10. Follow the repository's test layout, fixture policy, and naming conventions.

### Rule 9: Async, Resources, and Security
1. Match route, port, and adapter concurrency styles deliberately; do not call blocking I/O from async code.
2. Use `asyncio.to_thread` or an executor only as an explicit bridge for unavoidable blocking work.
3. Await owned tasks or retain and supervise deliberately detached tasks.
4. Propagate cancellation in long-running asynchronous infrastructure operations.
5. Close sessions, clients, files, and streams with context managers or dependency cleanup.
6. Keep connection pools and client lifetimes in infrastructure wiring.
7. Never evaluate untrusted input with `eval`, `exec`, or dynamic code compilation.
8. Never deserialize untrusted pickle data or invoke a shell with interpolated input.
9. Keep secrets out of source code, logs, exceptions, and response payloads.
10. Validate authorization at the appropriate infrastructure boundary while keeping domain policy framework-independent.

### Rule 10: Documentation, Observability, and Tooling
1. Document public domain contracts when names and types do not fully express invariants or failure semantics.
2. Write comments for non-obvious decisions, not line-by-line narration.
3. Keep logging, metrics, and tracing implementations in infrastructure.
4. Log at ownership boundaries with enough context to diagnose failures without exposing secrets.
5. Do not require entry and exit logs for every function or adapter.
6. Read `pyproject.toml`, lock files, and repository configuration before selecting commands or libraries.
7. Run a type checker only when the project configures one or the user requests it.
8. Run linters, formatters, security scanners, and coverage tools only when project configuration selects them.
9. Report the exact checks actually run and distinguish them from checks that were unavailable.
10. Keep generated documentation and verification claims consistent with the code shown.

## Forbidden Patterns

1. Third-party imports in production `domain/` files
2. FastAPI, Pydantic, SQLAlchemy, ORM rows, or framework exceptions in domain
3. Infrastructure importing domain through a reverse callback that makes domain depend on infrastructure
4. ORM or transport models crossing a domain port contract
5. `Any` in public contracts without a documented interoperability constraint
6. Untyped public functions, methods, constructors, entity fields, or port methods
7. Generic `ValueError` used for a domain invariant or expected business failure
8. Bare exception catches, swallowed exceptions, or one-letter exception variable names
9. Repeated HTTP error mapping mixed into every happy-path route
10. SQLAlchemy legacy `declarative_base`, untyped `Column` mappings, or `Session.query`
11. Untyped FastAPI dependencies or default-value `Depends` when an `Annotated` alias is practical
12. Mutable default arguments or hidden mutable global domain state
13. String-formatted SQL, shell commands built from input, or hardcoded secrets
14. Blocking I/O or `time.sleep` inside asynchronous code
15. Unfinished stubs, omitted implementations, or empty `Protocol` method bodies

## Thinking Protocol

1. Inspect project metadata, Python version, package layout, framework versions, and configured tools.
2. Classify each requested behavior as domain policy or infrastructure mechanism.
3. Define domain entities, explicit errors, ports, and use-case contracts before choosing adapter details.
4. Implement and inspect production domain imports for strict standard-library-only compliance.
5. Implement typed infrastructure adapters, boundary error mapping, HTTP conversion, and wiring.
6. Check every rule and forbidden pattern, fix conflicts explicitly, then report only verification actually performed.

## Response Rules

1. Present domain files before infrastructure files for each feature or example.
2. Mark every code block with an explicit intended path on its first line.
3. Mark layers with `# === DOMAIN LAYER ===` and `# === INFRASTRUCTURE LAYER ===` banners.
4. Provide complete implementations without unfinished stubs or omitted bodies.
5. Keep imports complete and consistent with the declared project Python and dependency versions.
6. Keep public contracts fully typed while allowing clear local inference.
7. State any requested rule deviation explicitly instead of applying it silently.
8. Keep examples focused on one cohesive use case unless the request requires more.
9. Report changed files and checks run without claiming unexecuted validation.
10. Run external tooling only when repository configuration or the user selects it.

## Context Awareness

1. Detect and extend the existing domain and infrastructure package layout.
2. Read the supported Python version before selecting syntax and standard-library features.
3. Detect FastAPI, Pydantic, and SQLAlchemy versions before using version-sensitive APIs.
4. Detect sync or async database and HTTP conventions before choosing adapter signatures.
5. Detect the existing dependency-injection and application-factory conventions.
6. Detect configured test libraries and keep framework or ORM fixtures out of domain unit tests.
7. Detect configured type, lint, format, security, and coverage tools before invoking them.
8. Detect package import roots, monorepo boundaries, and naming conventions before adding paths.

## Scoring Rubric

| Category | Points |
|---|---:|
| Production domain purity | 20 |
| Dependency direction and two-layer architecture | 18 |
| Public contract and ORM type safety | 15 |
| Domain errors and boundary mapping | 14 |
| FastAPI, SQLAlchemy, and wiring correctness | 13 |
| Testing discipline | 10 |
| Naming, documentation, and context fit | 10 |
| **Total** | **100** |

Grade bands: 97-100 = A+, 90-96 = A, 80-89 = B, 70-79 = C, 60-69 = D, below 60 = F.

## Example 1: Register a User

```python
# example_one/domain/users.py
# === DOMAIN LAYER ===
from __future__ import annotations

from dataclasses import dataclass
from typing import ClassVar, Protocol
from uuid import UUID, uuid4


class DomainError(Exception):
    code: ClassVar[str] = "domain_error"


class InvalidEmailError(DomainError):
    code = "invalid_email"

    def __init__(self, email: str) -> None:
        super().__init__(f"Invalid email address: {email}")


class EmailAlreadyRegisteredError(DomainError):
    code = "email_already_registered"

    def __init__(self, email: str) -> None:
        super().__init__(f"Email is already registered: {email}")


class UserPersistenceConflictError(DomainError):
    code = "user_persistence_conflict"

    def __init__(self, email: str) -> None:
        super().__init__(f"User could not be stored due to a conflict: {email}")


@dataclass(frozen=True, slots=True)
class User:
    id: UUID
    email: str

    @classmethod
    def register(cls, email: str) -> User:
        normalized_email = email.strip().lower()
        local_part, separator, domain_part = normalized_email.partition("@")
        if not separator or not local_part or "." not in domain_part:
            raise InvalidEmailError(email)
        return cls(id=uuid4(), email=normalized_email)


class UserRepository(Protocol):
    def email_exists(self, email: str) -> bool:
        raise NotImplementedError

    def add(self, user: User) -> None:
        raise NotImplementedError


class RegisterUser:
    def __init__(self, users: UserRepository) -> None:
        self._users = users

    def execute(self, email: str) -> User:
        user = User.register(email)
        if self._users.email_exists(user.email):
            raise EmailAlreadyRegisteredError(user.email)
        self._users.add(user)
        return user
```

```python
# example_one/infrastructure/user_persistence.py
# === INFRASTRUCTURE LAYER ===
from __future__ import annotations

from uuid import UUID

from sqlalchemy import String, Uuid, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import DeclarativeBase, Mapped, Session, mapped_column

from example_one.domain.users import User, UserPersistenceConflictError


class Base(DeclarativeBase):
    """Declarative base for user persistence."""


class UserRow(Base):
    __tablename__ = "users"

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True)
    email: Mapped[str] = mapped_column(String(320), unique=True, nullable=False)


class SqlAlchemyUserRepository:
    def __init__(self, session: Session) -> None:
        self._session = session

    def email_exists(self, email: str) -> bool:
        statement = select(UserRow.id).where(UserRow.email == email)
        return self._session.scalar(statement) is not None

    def add(self, user: User) -> None:
        self._session.add(UserRow(id=user.id, email=user.email))
        try:
            self._session.commit()
        except IntegrityError as integrity_error:
            self._session.rollback()
            raise UserPersistenceConflictError(user.email) from integrity_error
```

```python
# example_one/infrastructure/user_api.py
# === INFRASTRUCTURE LAYER ===
from collections.abc import Iterator
from os import environ
from typing import Annotated
from uuid import UUID

from fastapi import Depends, FastAPI, Request, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from example_one.domain.users import (
    DomainError,
    EmailAlreadyRegisteredError,
    InvalidEmailError,
    RegisterUser,
    UserPersistenceConflictError,
)
from example_one.infrastructure.user_persistence import SqlAlchemyUserRepository


DATABASE_URL = environ.get("DATABASE_URL", "sqlite:///./users.db")
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False},
)
session_factory = sessionmaker(engine, expire_on_commit=False)
app = FastAPI()


class RegisterUserRequest(BaseModel):
    email: str


class UserResponse(BaseModel):
    id: UUID
    email: str


def get_session() -> Iterator[Session]:
    with session_factory() as session:
        yield session


SessionDependency = Annotated[Session, Depends(get_session)]


def get_register_user(session: SessionDependency) -> RegisterUser:
    return RegisterUser(SqlAlchemyUserRepository(session))


RegisterUserDependency = Annotated[RegisterUser, Depends(get_register_user)]


def map_domain_error(error: DomainError) -> tuple[int, str]:
    if isinstance(error, InvalidEmailError):
        return status.HTTP_422_UNPROCESSABLE_ENTITY, str(error)
    if isinstance(
        error,
        (EmailAlreadyRegisteredError, UserPersistenceConflictError),
    ):
        return status.HTTP_409_CONFLICT, str(error)
    return status.HTTP_400_BAD_REQUEST, str(error)


@app.exception_handler(DomainError)
async def respond_to_domain_error(
    _request: Request,
    error: DomainError,
) -> JSONResponse:
    status_code, detail = map_domain_error(error)
    return JSONResponse(
        status_code=status_code,
        content={"code": error.code, "detail": detail},
    )


@app.post("/users", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register_user(
    request: RegisterUserRequest,
    use_case: RegisterUserDependency,
) -> UserResponse:
    user = use_case.execute(request.email)
    return UserResponse(id=user.id, email=user.email)
```

## Example 2: Pay an Invoice

```python
# example_two/domain/invoices.py
# === DOMAIN LAYER ===
from __future__ import annotations

from dataclasses import dataclass
from decimal import Decimal
from enum import Enum
from typing import ClassVar, Protocol
from uuid import UUID


class DomainError(Exception):
    code: ClassVar[str] = "domain_error"


class InvalidInvoiceAmountError(DomainError):
    code = "invalid_invoice_amount"

    def __init__(self, amount: Decimal) -> None:
        super().__init__(f"Invoice amount must be positive: {amount}")


class InvoiceNotFoundError(DomainError):
    code = "invoice_not_found"

    def __init__(self, invoice_id: UUID) -> None:
        super().__init__(f"Invoice was not found: {invoice_id}")


class InvoiceAlreadyPaidError(DomainError):
    code = "invoice_already_paid"

    def __init__(self, invoice_id: UUID) -> None:
        super().__init__(f"Invoice is already paid: {invoice_id}")


class InvoiceStatus(str, Enum):
    OPEN = "open"
    PAID = "paid"


@dataclass(slots=True)
class Invoice:
    id: UUID
    amount: Decimal
    status: InvoiceStatus

    def __post_init__(self) -> None:
        if self.amount <= Decimal("0"):
            raise InvalidInvoiceAmountError(self.amount)

    def mark_paid(self) -> None:
        if self.status is InvoiceStatus.PAID:
            raise InvoiceAlreadyPaidError(self.id)
        self.status = InvoiceStatus.PAID


class InvoiceRepository(Protocol):
    def find(self, invoice_id: UUID) -> Invoice | None:
        raise NotImplementedError

    def save(self, invoice: Invoice) -> None:
        raise NotImplementedError


class PayInvoice:
    def __init__(self, invoices: InvoiceRepository) -> None:
        self._invoices = invoices

    def execute(self, invoice_id: UUID) -> Invoice:
        invoice = self._invoices.find(invoice_id)
        if invoice is None:
            raise InvoiceNotFoundError(invoice_id)
        invoice.mark_paid()
        self._invoices.save(invoice)
        return invoice
```

```python
# example_two/infrastructure/invoice_persistence.py
# === INFRASTRUCTURE LAYER ===
from __future__ import annotations

from decimal import Decimal
from uuid import UUID

from sqlalchemy import Enum as SqlEnum
from sqlalchemy import Numeric, Uuid, select
from sqlalchemy.orm import DeclarativeBase, Mapped, Session, mapped_column
from sqlalchemy.orm.exc import StaleDataError

from example_two.domain.invoices import (
    Invoice,
    InvoiceNotFoundError,
    InvoiceStatus,
)


class Base(DeclarativeBase):
    """Declarative base for invoice persistence."""


class InvoiceRow(Base):
    __tablename__ = "invoices"

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True)
    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    status: Mapped[InvoiceStatus] = mapped_column(
        SqlEnum(InvoiceStatus, native_enum=False),
        nullable=False,
    )


class SqlAlchemyInvoiceRepository:
    def __init__(self, session: Session) -> None:
        self._session = session

    def find(self, invoice_id: UUID) -> Invoice | None:
        statement = select(InvoiceRow).where(InvoiceRow.id == invoice_id)
        invoice_row = self._session.scalar(statement)
        if invoice_row is None:
            return None
        return Invoice(
            id=invoice_row.id,
            amount=invoice_row.amount,
            status=invoice_row.status,
        )

    def save(self, invoice: Invoice) -> None:
        invoice_row = self._session.get(InvoiceRow, invoice.id)
        if invoice_row is None:
            raise InvoiceNotFoundError(invoice.id)
        invoice_row.amount = invoice.amount
        invoice_row.status = invoice.status
        self._commit(invoice.id)

    def _commit(self, invoice_id: UUID) -> None:
        try:
            self._session.commit()
        except StaleDataError as stale_data_error:
            self._session.rollback()
            raise InvoiceNotFoundError(invoice_id) from stale_data_error
```

```python
# example_two/infrastructure/invoice_api.py
# === INFRASTRUCTURE LAYER ===
from collections.abc import Iterator
from decimal import Decimal
from os import environ
from typing import Annotated
from uuid import UUID

from fastapi import Depends, FastAPI, Request, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from example_two.domain.invoices import (
    DomainError,
    InvalidInvoiceAmountError,
    InvoiceAlreadyPaidError,
    InvoiceNotFoundError,
    InvoiceStatus,
    PayInvoice,
)
from example_two.infrastructure.invoice_persistence import (
    SqlAlchemyInvoiceRepository,
)


DATABASE_URL = environ.get("DATABASE_URL", "sqlite:///./invoices.db")
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False},
)
session_factory = sessionmaker(engine, expire_on_commit=False)
app = FastAPI()


class InvoiceResponse(BaseModel):
    id: UUID
    amount: Decimal
    status: InvoiceStatus


def get_session() -> Iterator[Session]:
    with session_factory() as session:
        yield session


SessionDependency = Annotated[Session, Depends(get_session)]


def get_pay_invoice(session: SessionDependency) -> PayInvoice:
    return PayInvoice(SqlAlchemyInvoiceRepository(session))


PayInvoiceDependency = Annotated[PayInvoice, Depends(get_pay_invoice)]


def map_domain_error(error: DomainError) -> tuple[int, str]:
    if isinstance(error, InvoiceNotFoundError):
        return status.HTTP_404_NOT_FOUND, str(error)
    if isinstance(error, InvoiceAlreadyPaidError):
        return status.HTTP_409_CONFLICT, str(error)
    if isinstance(error, InvalidInvoiceAmountError):
        return status.HTTP_422_UNPROCESSABLE_ENTITY, str(error)
    return status.HTTP_400_BAD_REQUEST, str(error)


@app.exception_handler(DomainError)
async def respond_to_domain_error(
    _request: Request,
    error: DomainError,
) -> JSONResponse:
    status_code, detail = map_domain_error(error)
    return JSONResponse(
        status_code=status_code,
        content={"code": error.code, "detail": detail},
    )


@app.post("/invoices/{invoice_id}/pay", response_model=InvoiceResponse)
def pay_invoice(
    invoice_id: UUID,
    use_case: PayInvoiceDependency,
) -> InvoiceResponse:
    invoice = use_case.execute(invoice_id)
    return InvoiceResponse(
        id=invoice.id,
        amount=invoice.amount,
        status=invoice.status,
    )
```
