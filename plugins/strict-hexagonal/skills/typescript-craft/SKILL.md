---
name: typescript-craft
description: >-
  Backend-only TypeScript guidance for Node.js services using Express or
  Fastify, with strict contracts, pure domain code, and validated
  infrastructure boundaries. Use as the fallback backend skill; defer Next.js
  and Nuxt projects to their framework skills. Use when writing or reviewing
  backend TypeScript for Node.js services.
metadata:
  version: '4.0.0'
  author: Voidlight
  applyTo: '**/*.ts'
  tags: [typescript, backend, nodejs, express, fastify, clean-architecture, type-safety]
---

## Identity

This is the backend-only TypeScript skill for Node.js services, libraries, workers, and APIs, especially projects using Express or Fastify. It is the fallback for backend TypeScript when no more specific backend skill applies. It does not govern Next.js or Nuxt projects: `nextjs-craft` takes precedence when Next.js is detected, and `nuxt-craft` takes precedence when Nuxt is detected. Production domain code uses only ECMAScript and TypeScript built-ins, with no framework, Node.js, or third-party imports. Infrastructure owns transport, persistence, runtime validation, logging, and wiring. Public contracts remain explicit and strict: no `any`, unchecked casts, or unvalidated data crossing a boundary.

## Mandatory Rules

### Rule 1: Cohesive Responsibilities
1. Give each module one cohesive purpose and split it when independent reasons to change emerge.
2. Keep business decisions in domain code and I/O orchestration in infrastructure code.
3. Make route handlers parse input, invoke one use case, and map the result to transport output.
4. Extract helpers when they clarify a repeated or independently testable policy, not to satisfy arbitrary size limits.
5. Keep persistence mapping inside repository adapters.
6. Keep framework configuration and dependency wiring at infrastructure entry points.
7. Prefer pure functions for calculations and invariant checks.
8. Make side effects visible through port calls or infrastructure functions.
9. Avoid modules that combine unrelated entities or use cases.
10. Refactor for cohesion and readability rather than fixed line counts.

### Rule 2: Intent-Revealing Naming
1. Name functions and variables by domain intent without imposing a word count.
2. Use verbs for operations and nouns for values, entities, and ports.
3. Prefix booleans with predicates such as `is`, `has`, `can`, or `should` when natural.
4. Use plural names for collections and singular names for individual values.
5. Allow established abbreviations such as `id`, `url`, `http`, and project-standard terms.
6. Avoid vague names such as `data`, `thing`, or `process` when a precise domain term exists.
7. Name ports by capability, such as `OrderRepository` or `Clock`.
8. Name adapters by mechanism and capability, such as `PostgresOrderRepository`.
9. Name error codes for stable machine consumption rather than presentation text.
10. Follow an established repository naming convention unless it weakens correctness or clarity.

### Rule 3: Strict Type Contracts
1. Enable and preserve `strict` TypeScript settings when the project controls `tsconfig.json`.
2. Declare parameter and return types on exported functions, methods, and public port contracts.
3. Let TypeScript infer obvious local variable types; do not annotate every local declaration.
4. Never introduce `any`, including generic defaults and boundary payloads.
5. Receive dynamic or framework-controlled input as `unknown` and narrow it with runtime checks.
6. Do not use unchecked `as` assertions, angle-bracket assertions, or non-null assertions.
7. Model closed alternatives with discriminated unions and handle them exhaustively.
8. Represent expected domain failure with a local `Result<T, E>` discriminated union.
9. Use `readonly` where mutation is not part of the contract.
10. Keep public DTO, port, and use-case contracts free of framework and persistence types.

### Rule 4: Two-Layer Boundary
1. Put entities, domain errors, use cases, policies, and ports under `domain/`.
2. Put HTTP handlers, runtime validation, repositories, clients, logging, and wiring under `infrastructure/`.
3. Keep production domain imports limited to other domain modules.
4. Use only ECMAScript and TypeScript built-ins in production domain code.
5. Do not import Node.js built-ins, frameworks, validators, ORMs, or utility packages into domain code.
6. Define ports in domain and implement them in infrastructure.
7. Inject port implementations into use cases through constructors or explicit function parameters.
8. Keep use cases callable without HTTP requests, replies, framework containers, or ORM sessions.
9. Prevent infrastructure models and transport DTOs from escaping into domain contracts.
10. Wire concrete adapters to use cases only in infrastructure composition roots.

### Rule 5: Domain Modeling
1. Put invariants in entity factories, entity methods, value-object factories, or domain policies.
2. Return local `Result` values for expected validation and business-rule failures.
3. Define domain errors with stable codes and domain-relevant details.
4. Do not require `fp-ts`, `ts-results`, `neverthrow`, `zod`, or any other package in domain code.
5. Keep the local `Result` implementation minimal and owned by the domain.
6. Pass time, identifiers, randomness, and external state through ports when domain behavior depends on them.
7. Use immutable domain values unless mutation expresses a deliberate entity transition.
8. Distinguish absence, expected failure, and unexpected infrastructure failure in contracts.
9. Avoid anemic entities when behavior or invariants naturally belong with the entity.
10. Keep domain error messages independent of HTTP status codes and framework response shapes.

### Rule 6: TypeScript Backend Idioms
1. Use standard TypeScript syntax only; never copy Python, Rust, Java, or framework-specific syntax into domain contracts.
2. Prefer discriminated unions for `Result`, state, commands, and closed error sets.
3. Use `interface` or `type` according to local convention; choose based on contract clarity, not dogma.
4. Use `const` by default and `let` only for deliberate reassignment.
5. Use `readonly` arrays and properties for immutable inputs and outputs.
6. Narrow `unknown` with reusable predicates that inspect every required field.
7. Treat array and object indexing as potentially absent when compiler settings require it.
8. Use exhaustive control flow for closed domain result and error unions.
9. Avoid clever generic abstractions when a concrete domain contract is clearer.
10. Keep async contracts at ports and use cases only when the underlying operation is asynchronous.

### Rule 7: Validated Infrastructure Boundaries
1. Treat request bodies, query values, path parameters, headers, environment values, and external responses as untrusted.
2. Type request bodies as `unknown` where framework generics permit it.
3. Never directly cast `req.body`, `request.body`, parsed JSON, or database rows to a trusted type.
4. Validate and transform untrusted values before invoking a use case.
5. Use built-in type guards by default when they are sufficient.
6. Use third-party validation only in infrastructure and only when that dependency is already installed or explicitly requested.
7. Convert validator-specific output into domain input types at the boundary.
8. Map domain errors to HTTP statuses and response bodies in infrastructure.
9. Keep Express and Fastify request/reply types out of domain modules.
10. Keep handlers thin without hiding boundary validation or error mapping.

### Rule 8: Error and Failure Handling
1. Use local domain `Result` values for expected domain and port failures.
2. Do not throw for expected domain outcomes such as invalid input or business-rule rejection.
3. Catch exceptions at infrastructure boundaries where libraries can throw.
4. Convert caught `unknown` values into explicit infrastructure or port errors.
5. Never swallow an error or continue as though a failed operation succeeded.
6. Preserve stable machine-readable error codes across use-case contracts.
7. Keep retry, timeout, circuit-breaker, and transport failure policy in infrastructure.
8. Avoid leaking raw database, validator, or framework errors through public responses.
9. Log unexpected failures once at the responsible infrastructure boundary when logging is configured.
10. Handle every `Result` branch before reading its value or error.

### Rule 9: Testing and Tooling
1. Read `package.json`, lockfiles, and `tsconfig.json` before choosing commands or libraries.
2. Use the test runner already declared in manifests; do not require Vitest, Jest, or Node test runner unconditionally.
3. Test domain behavior without framework fixtures.
4. Use small fake or in-memory port implementations for domain use-case tests.
5. Add infrastructure tests for boundary validation, status mapping, and adapter behavior when those surfaces change.
6. Run existing type-check, test, lint, and format scripts relevant to changed files.
7. Do not invent coverage thresholds absent an explicit project policy.
8. Do not add a bundler, linter, validator, mock library, or test framework merely to satisfy this skill.
9. Report commands that were unavailable or absent instead of claiming they passed.
10. Preserve strict compiler and lint guarantees already enforced by the project.

### Rule 10: Documentation and Observability
1. Document exported contracts when behavior, invariants, or failure semantics are not evident from types.
2. Do not require comments on self-explanatory declarations or every module.
3. Keep logs, metrics, and tracing in infrastructure.
4. Use the logger already installed and configured by the project.
5. Do not introduce Pino, Winston, OpenTelemetry, or another observability package unconditionally.
6. Avoid logging secrets, credentials, tokens, or raw sensitive request bodies.
7. Include stable error codes and useful operational context in infrastructure logs.
8. Keep domain errors deterministic and independent of logger state.
9. Update public API documentation when request, response, or error contracts change.
10. Make verification claims precise and supported by commands actually run.

## Forbidden Patterns

1. Authored `any` in production or test code.
2. Unchecked `as` assertions, angle-bracket assertions, or non-null assertions.
3. Directly casting `req.body`, `request.body`, parsed JSON, environment values, or persistence rows.
4. Framework, Node.js, ORM, validator, or other third-party imports in production domain code.
5. Express or Fastify request, response, reply, plugin, or schema types in domain contracts.
6. Throwing exceptions for expected domain validation or business-rule failures.
7. Passing unvalidated transport or external-service values into a use case.
8. Parsing JSON without validating the resulting `unknown` value.
9. Empty catches, ignored rejected promises, or failures converted to false success.
10. `TODO`, placeholders, ellipsis, or undefined symbols in delivered code.
11. Persistence adapters returning ORM records as domain entities without explicit mapping and validation.
12. Domain ports that expose HTTP statuses, framework DTOs, ORM models, or library-specific results.
13. Mixing Express and Fastify in one service path without an explicit migration requirement.
14. Adding `fp-ts`, `ts-results`, `neverthrow`, `zod`, or another dependency as an unconditional requirement.
15. Claiming type-check, lint, test, format, coverage, or runtime success without running the applicable command.

## Thinking Protocol

1. Detect whether the project is backend TypeScript; defer immediately to `nextjs-craft` or `nuxt-craft` when those frameworks are present.
2. Inspect manifests, compiler settings, folder layout, framework, dependencies, scripts, and existing conventions.
3. Surface instruction or convention conflicts explicitly, apply higher-precedence user and project requirements, and never resolve conflicts silently.
4. Classify entities, errors, use cases, and ports as domain; classify validation, transport, persistence, libraries, and wiring as infrastructure.
5. Implement domain contracts first, then validated boundaries and adapters, while checking imports, `unknown` narrowing, `Result` handling, and symbol completeness.
6. Run only manifest-supported verification commands, review the diff, and report concrete results and unresolved constraints.

## Response Rules

1. State when this backend-only skill is inapplicable and name the Next.js or Nuxt skill that takes precedence.
2. Present domain files before infrastructure files when showing a complete feature.
3. Mark examples with `// === DOMAIN LAYER ===` and `// === INFRASTRUCTURE LAYER ===` banners.
4. Put the full intended path in a `// path:` marker for every shown file.
5. Provide complete symbols and imports needed by the shown code.
6. Do not emit `TODO`, placeholders, ellipsis, unchecked casts, or directly cast request bodies.
7. Explain material contract decisions briefly and avoid repeating what types already communicate.
8. Flag conflicts, assumptions, unavailable tooling, and deviations explicitly rather than silently changing direction.
9. Report only verification commands actually run and their outcomes.
10. Keep output focused on the requested backend change and existing repository conventions.

## Context Awareness

1. Check manifests for Next.js or Nuxt first; their framework skill overrides this fallback skill.
2. Confirm the target is backend TypeScript, then detect Express, Fastify, another backend runtime, or a framework-neutral library.
3. Inspect `package.json` and lockfiles before referencing dependencies or package-manager commands.
4. Inspect `tsconfig.json` and inherited configs before relying on compiler or module behavior.
5. Extend existing `domain/` and `infrastructure/` layouts rather than creating parallel structures.
6. Follow the existing test runner, logger, validator, ORM, DI, import, and error conventions when they satisfy these rules.
7. Respect monorepo package boundaries and use the nearest relevant manifest and compiler configuration.
8. Apply explicit user instructions first, then repository instructions and local conventions, while surfacing any unresolved conflict.

## Scoring Rubric

| Category | Points |
|---|---:|
| Backend scope and skill precedence | 10 |
| Domain purity and local Result modeling | 20 |
| Boundary validation and error mapping | 20 |
| Public contract and TypeScript safety | 20 |
| Port, adapter, and wiring correctness | 15 |
| Context-sensitive tooling and convention fit | 10 |
| Completeness and verified reporting | 5 |
| **Total** | **100** |

Grade bands: 97-100 = A+, 90-96 = A, 80-89 = B, 70-79 = C, 60-69 = D, below 60 = F.

## Example 1: Express

```typescript
// === DOMAIN LAYER ===
// path: src/domain/order.ts
export type Result<T, E> =
    | { readonly ok: true; readonly value: T }
    | { readonly ok: false; readonly error: E };

export function success<T>(value: T): Result<T, never> {
    return { ok: true, value };
}

export function failure<E>(error: E): Result<never, E> {
    return { ok: false, error };
}

export class OrderError extends Error {
    public readonly code: "ORDER_ID_REQUIRED" | "AMOUNT_NOT_POSITIVE";

    public constructor(code: "ORDER_ID_REQUIRED" | "AMOUNT_NOT_POSITIVE", message: string) {
        super(message);
        this.name = "OrderError";
        this.code = code;
    }
}

export class RepositoryError extends Error {
    public readonly code = "ORDER_SAVE_FAILED";

    public constructor(message: string) {
        super(message);
        this.name = "RepositoryError";
    }
}

export class Order {
    private constructor(
        public readonly id: string,
        public readonly amountCents: number,
    ) {}

    public static create(id: string, amountCents: number): Result<Order, OrderError> {
        if (id.trim().length === 0) {
            return failure(new OrderError("ORDER_ID_REQUIRED", "Order id is required"));
        }
        if (!Number.isInteger(amountCents) || amountCents <= 0) {
            return failure(new OrderError("AMOUNT_NOT_POSITIVE", "Amount must be a positive integer"));
        }
        return success(new Order(id, amountCents));
    }
}

export interface OrderRepository {
    save(order: Order): Promise<Result<void, RepositoryError>>;
}

export interface OrderIdGenerator {
    next(): string;
}

export type CreateOrderError = OrderError | RepositoryError;

export class CreateOrderUseCase {
    public constructor(
        private readonly orders: OrderRepository,
        private readonly ids: OrderIdGenerator,
    ) {}

    public async execute(amountCents: number): Promise<Result<Order, CreateOrderError>> {
        const created = Order.create(this.ids.next(), amountCents);
        if (!created.ok) {
            return failure(created.error);
        }
        const saved = await this.orders.save(created.value);
        if (!saved.ok) {
            return failure(saved.error);
        }
        return success(created.value);
    }
}

// === INFRASTRUCTURE LAYER ===
// path: src/infrastructure/express-server.ts
import { randomUUID } from "node:crypto";
import express, { type Express, type Request, type Response } from "express";
import {
    CreateOrderUseCase,
    failure,
    type Order,
    type OrderIdGenerator,
    type OrderRepository,
    type RepositoryError,
    type Result,
    success,
} from "../domain/order.js";

type BoundaryError = {
    readonly code: "INVALID_BODY";
    readonly message: string;
};

type CreateOrderReply =
    | { readonly order: { readonly id: string; readonly amountCents: number } }
    | { readonly error: { readonly code: string; readonly message: string } };

function isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === "object" && value !== null && !Array.isArray(value);
}

function parseAmountCents(body: unknown): Result<number, BoundaryError> {
    if (!isRecord(body) || typeof body.amountCents !== "number") {
        return failure({ code: "INVALID_BODY", message: "amountCents must be a number" });
    }
    if (!Number.isInteger(body.amountCents) || body.amountCents <= 0) {
        return failure({ code: "INVALID_BODY", message: "amountCents must be a positive integer" });
    }
    return success(body.amountCents);
}

class InMemoryOrderRepository implements OrderRepository {
    private readonly orders = new Map<string, Order>();

    public async save(order: Order): Promise<Result<void, RepositoryError>> {
        this.orders.set(order.id, order);
        return success(undefined);
    }
}

class RandomOrderIdGenerator implements OrderIdGenerator {
    public next(): string {
        return randomUUID();
    }
}

const repository = new InMemoryOrderRepository();
const idGenerator = new RandomOrderIdGenerator();
const createOrder = new CreateOrderUseCase(repository, idGenerator);

async function createOrderHandler(
    request: Request<Record<string, never>, CreateOrderReply, unknown>,
    response: Response<CreateOrderReply>,
): Promise<void> {
    const parsed = parseAmountCents(request.body);
    if (!parsed.ok) {
        response.status(400).json({ error: parsed.error });
        return;
    }
    const result = await createOrder.execute(parsed.value);
    if (!result.ok) {
        const status = result.error.code === "ORDER_SAVE_FAILED" ? 500 : 422;
        response.status(status).json({
            error: { code: result.error.code, message: result.error.message },
        });
        return;
    }
    response.status(201).json({
        order: { id: result.value.id, amountCents: result.value.amountCents },
    });
}

const app: Express = express();
app.use(express.json());
app.post<Record<string, never>, CreateOrderReply, unknown>("/orders", createOrderHandler);
app.listen(3000);
```

## Example 2: Fastify

```typescript
// === DOMAIN LAYER ===
// path: src/domain/account.ts
export type Result<T, E> =
    | { readonly ok: true; readonly value: T }
    | { readonly ok: false; readonly error: E };

export function success<T>(value: T): Result<T, never> {
    return { ok: true, value };
}

export function failure<E>(error: E): Result<never, E> {
    return { ok: false, error };
}

export class AccountError extends Error {
    public readonly code: "ACCOUNT_ID_REQUIRED" | "EMAIL_INVALID";

    public constructor(code: "ACCOUNT_ID_REQUIRED" | "EMAIL_INVALID", message: string) {
        super(message);
        this.name = "AccountError";
        this.code = code;
    }
}

export class RepositoryError extends Error {
    public readonly code = "ACCOUNT_SAVE_FAILED";

    public constructor(message: string) {
        super(message);
        this.name = "RepositoryError";
    }
}

export class Account {
    private constructor(
        public readonly id: string,
        public readonly email: string,
    ) {}

    public static create(id: string, email: string): Result<Account, AccountError> {
        if (id.trim().length === 0) {
            return failure(new AccountError("ACCOUNT_ID_REQUIRED", "Account id is required"));
        }
        const normalizedEmail = email.trim().toLowerCase();
        if (!normalizedEmail.includes("@") || normalizedEmail.startsWith("@") || normalizedEmail.endsWith("@")) {
            return failure(new AccountError("EMAIL_INVALID", "Email address is invalid"));
        }
        return success(new Account(id, normalizedEmail));
    }
}

export interface AccountRepository {
    save(account: Account): Promise<Result<void, RepositoryError>>;
}

export interface AccountIdGenerator {
    next(): string;
}

export type RegisterAccountError = AccountError | RepositoryError;

export class RegisterAccountUseCase {
    public constructor(
        private readonly accounts: AccountRepository,
        private readonly ids: AccountIdGenerator,
    ) {}

    public async execute(email: string): Promise<Result<Account, RegisterAccountError>> {
        const created = Account.create(this.ids.next(), email);
        if (!created.ok) {
            return failure(created.error);
        }
        const saved = await this.accounts.save(created.value);
        if (!saved.ok) {
            return failure(saved.error);
        }
        return success(created.value);
    }
}

// === INFRASTRUCTURE LAYER ===
// path: src/infrastructure/fastify-server.ts
import { randomUUID } from "node:crypto";
import Fastify, {
    type FastifyInstance,
    type FastifyReply,
    type FastifyRequest,
} from "fastify";
import {
    type Account,
    type AccountIdGenerator,
    type AccountRepository,
    failure,
    RegisterAccountUseCase,
    type RepositoryError,
    type Result,
    success,
} from "../domain/account.js";

type BoundaryError = {
    readonly code: "INVALID_BODY";
    readonly message: string;
};

type RegisterReply =
    | { readonly account: { readonly id: string; readonly email: string } }
    | { readonly error: { readonly code: string; readonly message: string } };

type RegisterRoute = {
    readonly Body: unknown;
    readonly Reply: RegisterReply;
};

function isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === "object" && value !== null && !Array.isArray(value);
}

function parseEmail(body: unknown): Result<string, BoundaryError> {
    if (!isRecord(body) || typeof body.email !== "string") {
        return failure({ code: "INVALID_BODY", message: "email must be a string" });
    }
    if (body.email.trim().length === 0) {
        return failure({ code: "INVALID_BODY", message: "email must not be empty" });
    }
    return success(body.email);
}

class InMemoryAccountRepository implements AccountRepository {
    private readonly accounts = new Map<string, Account>();

    public async save(account: Account): Promise<Result<void, RepositoryError>> {
        this.accounts.set(account.id, account);
        return success(undefined);
    }
}

class RandomAccountIdGenerator implements AccountIdGenerator {
    public next(): string {
        return randomUUID();
    }
}

const repository = new InMemoryAccountRepository();
const idGenerator = new RandomAccountIdGenerator();
const registerAccount = new RegisterAccountUseCase(repository, idGenerator);

async function registerAccountHandler(
    request: FastifyRequest<RegisterRoute>,
    reply: FastifyReply,
): Promise<void> {
    const parsed = parseEmail(request.body);
    if (!parsed.ok) {
        await reply.code(400).send({ error: parsed.error });
        return;
    }
    const result = await registerAccount.execute(parsed.value);
    if (!result.ok) {
        const status = result.error.code === "ACCOUNT_SAVE_FAILED" ? 500 : 422;
        await reply.code(status).send({
            error: { code: result.error.code, message: result.error.message },
        });
        return;
    }
    await reply.code(201).send({
        account: { id: result.value.id, email: result.value.email },
    });
}

const app: FastifyInstance = Fastify({ logger: true });
app.post<RegisterRoute>("/accounts", registerAccountHandler);

async function start(): Promise<void> {
    await app.listen({ port: 3000 });
}

start().catch((error: unknown): void => {
    app.log.error({ error }, "Fastify startup failed");
});
```
