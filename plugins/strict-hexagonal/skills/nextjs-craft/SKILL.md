---
name: nextjs-craft
description: >-
  Enforces strict TypeScript, version-aware Next.js App Router practices, and
  a pure domain/infrastructure architecture for production code. Use when
  writing or reviewing TSX/TypeScript code in Next.js App Router projects.
metadata:
  version: '4.0.0'
  author: Voidlight
  applyTo: '**/*.{tsx,ts}'
  tags: [nextjs, react, typescript, app-router, architecture]
---

## Identity

This skill reviews and generates production Next.js App Router code. It keeps domain code dependency-free and moves React, Next.js, persistence, transport, and UI concerns into infrastructure. It verifies installed Next.js and React versions and relevant configuration before applying version-sensitive guidance.

## Mandatory Rules

### Rule 1: Cohesive Responsibilities
1. Give each function, class, component, and module one cohesive reason to change.
2. Separate business decisions from I/O, rendering, persistence, and transport concerns.
3. Keep each use case focused on one business outcome.
4. Keep repository adapters focused on translating between storage and domain contracts.
5. Keep Server Actions and Route Handlers as thin transport adapters around use cases.
6. Extract logic when it has an independent concept, contract, or reason to change.
7. Do not split cohesive code merely to satisfy arbitrary line or function counts.
8. Reject god modules that own unrelated workflows, persistence, validation, and presentation.
9. Put business validation and state transitions on domain entities or domain services.
10. Put request parsing, response mapping, redirects, and cache invalidation in infrastructure.

### Rule 2: Intent-Revealing Naming
1. Name symbols for domain intent and behavior rather than implementation mechanics.
2. Use concise names when they are unambiguous; never require an arbitrary word count.
3. Name booleans as predicates such as `isPaid`, `hasAccess`, or `canRetry`.
4. Use plural names for collections and singular names for individual values.
5. Avoid vague names such as `data`, `thing`, `stuff`, or `process` when a precise name exists.
6. Use established project and domain terminology consistently across both layers.
7. Use standard abbreviations such as `id`, `url`, `http`, and `json` where clearer.
8. Name errors by the failed operation or violated invariant.
9. Name ports by capability, such as `OrderRepository` or `PaymentGateway`.
10. Follow existing file and route naming conventions unless they obscure domain intent.

### Rule 3: Strict TypeScript
1. Compile production code with `strict: true` and preserve stricter existing compiler options.
2. Domain source may use only TypeScript syntax and ECMAScript built-ins available at runtime.
3. Do not use `any`; accept `unknown` at untrusted boundaries and narrow it explicitly.
4. Declare parameter and return types at exported, public, port, action, and route boundaries.
5. Allow TypeScript to infer obvious local variable and callback types.
6. Model fallible operations with discriminated unions when callers must handle failure.
7. Use branded or opaque primitives only when they prevent a real category error.
8. Prefer `readonly` data and immutable transitions for domain state.
9. Avoid unchecked assertions and non-null assertions unless an invariant is locally proven.
10. Keep generics constrained by meaningful capabilities; do not add generic abstractions speculatively.

### Rule 4: Two-Layer Architecture
1. The domain layer contains entities, value objects, domain errors, use cases, services, and ports.
2. The infrastructure layer contains Next.js, React, persistence, HTTP, UI, configuration, and wiring.
3. Domain code MUST have zero imports from React, Next.js, Prisma, ORMs, SDKs, or other packages.
4. Domain code MUST remain executable with TypeScript output and ECMAScript built-ins only.
5. Domain ports MUST expose only domain or ECMAScript types.
6. Infrastructure adapters MUST implement ports declared by the domain.
7. Construct concrete adapters and inject them into use cases at infrastructure composition roots.
8. Never expose ORM records, `Request`, `Response`, `FormData`, React props, or framework errors to domain APIs.
9. Dependencies may point from infrastructure to domain, never from domain to infrastructure.
10. Keep use cases callable in isolation without an HTTP request, React render, or Next.js runtime.

### Rule 5: Production Domain Contracts
1. Treat domain code as production code, not as pseudocode or a simplified DTO layer.
2. Make entities enforce invariants at creation and during state transitions.
3. Define domain-specific error unions or classes without framework status codes.
4. If a domain API promises `Result`, return failures and do not throw across that contract.
5. If a project uses domain exceptions instead, document and test that contract consistently.
6. Keep time, IDs, randomness, storage, and external services injectable when behavior depends on them.
7. Avoid decorators, metadata APIs, environment reads, and global framework state in domain code.
8. Preserve domain meaning when mapping persistence and transport failures.
9. Test domain behavior through public APIs with in-memory or handwritten port fakes.
10. Test dependencies are allowed in test files and do not violate production domain purity.

### Rule 6: Version-Gated Next.js and React
1. Read installed Next.js and React versions plus relevant configuration before choosing APIs.
2. Use the App Router for new routes unless the existing project explicitly remains on Pages Router.
3. Prefer Server Components; add `'use client'` only for browser APIs, state, effects, or event handlers.
4. On React 19, use `useActionState`; do not generate the deprecated `useFormState` API.
5. On Next.js 16, use `use cache` only when Cache Components is enabled and the boundary is appropriate.
6. On Next.js 14 or 15, `unstable_cache` may be used when supported and appropriate for the data source.
7. Import `cookies` from `next/headers`; in Next.js 15 and later, call it asynchronously with `await cookies()`.
8. App Router `router.push()` returns `void`; invoke it without `await`.
9. Treat `fetch` caching as version- and configuration-dependent; never require cache options blanketly.
10. Match `revalidatePath`, `revalidateTag`, `updateTag`, or no invalidation to the actual caching model.

### Rule 7: Framework Integration
1. Fetch server-owned data in Server Components, use cases, or server-side adapters rather than client mount effects.
2. Use Server Actions for trusted mutation flows when their deployment and security model fits.
3. Use Route Handlers for public HTTP contracts, webhooks, streaming, or non-React clients.
4. Parse and validate `FormData`, JSON, headers, cookies, and route parameters in infrastructure.
5. Authorize every mutation on the server even when the UI hides unauthorized controls.
6. Map domain failures explicitly to action state, HTTP responses, `notFound`, redirects, or error boundaries.
7. Keep redirects and navigation outside domain use cases.
8. Use `next/image`, `next/link`, metadata APIs, and Suspense when they fit the concrete UI requirement.
9. Adopt component libraries, styling libraries, state libraries, and validators only when requested or already established.
10. Adopt logging, tracing, linting, formatting, and build tooling conditionally from the repository's conventions.

### Rule 8: Errors, Security, and Runtime Boundaries
1. Narrow caught values from `unknown` before logging or mapping them.
2. Do not leak stack traces, database messages, secrets, or internal identifiers to clients.
3. Validate and normalize all untrusted transport input before invoking a use case.
4. Keep authentication and authorization checks close to the server entry point or an injected policy port.
5. Avoid `dangerouslySetInnerHTML` for untrusted content; sanitize through an established infrastructure dependency if required.
6. Access `window`, `document`, storage, and browser-only APIs only in Client Components or guarded client code.
7. Do not fetch Server Component data through `useEffect` merely to move server work to the browser.
8. Define explicit action and Route Handler response types at their boundaries.
9. Handle expected domain failures without turning them into generic 500 responses.
10. Let unexpected infrastructure failures reach established observability and error-boundary handling after safe mapping.

### Rule 9: Testing Discipline
1. Test entity invariants and use cases without importing React, Next.js, Prisma, or other production dependencies.
2. Test port adapters against their domain contracts and mapping behavior.
3. Test Server Actions and Route Handlers at transport boundaries for parsing, authorization, and failure mapping.
4. Test Client Components by observable behavior rather than implementation details.
5. Reuse the repository's existing test runner and testing libraries.
6. Test-only dependencies such as Vitest, Jest, Testing Library, and test database tools are allowed.
7. Do not introduce a second test stack without an explicit migration requirement.
8. Mock at external boundaries; prefer real domain entities and use cases in infrastructure tests.
9. Cover version-gated behavior when supporting more than one Next.js or React major version.
10. Run the available typecheck, lint, targeted tests, and production build before claiming completion.

### Rule 10: Delivery Quality
1. Provide complete code with no `TODO`, ellipsis, placeholder body, or undefined symbol.
2. Include every import and declaration needed by each shown file exactly once.
3. Mark every code sample file with its intended path.
4. Keep domain and infrastructure files visibly separated.
5. Preserve established aliases, module syntax, formatting, and naming conventions.
6. Explain version assumptions when manifest or configuration evidence is unavailable.
7. State conflicts between requested behavior and repository constraints instead of silently replacing either.
8. Document only non-obvious contracts, invariants, compatibility gates, and operational behavior.
9. Do not require JSDoc, stories, or annotations for every local symbol without a project rule.
10. Report verification actually performed and identify checks that could not run.

## Forbidden Patterns

1. React, Next.js, Prisma, ORM, validator, SDK, or other package imports in production domain code
2. Framework request, response, cookie, form, component, or persistence types in domain contracts
3. `any`, unchecked boundary casts, or unvalidated `unknown` input
4. Throwing from a domain operation whose declared `Result` contract requires returned failure
5. Deprecated React 19 `useFormState` instead of `useActionState`
6. `use cache` on Next.js 16 without Cache Components enabled
7. Blanket `unstable_cache` guidance without a Next.js 14/15 compatibility and suitability check
8. Importing `cookies` from anywhere except `next/headers`, or treating it as synchronous on Next.js 15+
9. Awaiting App Router `router.push()`
10. Requiring every `fetch` call to specify `cache` or `next.revalidate`
11. Client mount-effect fetching for data that belongs in a Server Component
12. Untrusted HTML passed to `dangerouslySetInnerHTML` without established sanitization
13. ORM records or transport DTOs passed through domain entities and ports
14. Placeholder code, duplicate declarations/imports in one file, or undefined symbols
15. Mandatory libraries, polyglot rules, or arbitrary naming, size, annotation, and documentation quotas

## Thinking Protocol

1. Inspect manifests, Next.js configuration, folder layout, TypeScript options, and established dependencies.
2. Classify requirements into pure domain behavior and infrastructure concerns.
3. Define entities, errors, ports, use cases, transport contracts, and composition roots.
4. Check version gates and forbidden patterns; surface unresolved conflicts explicitly.
5. Draft and verify the domain first, then implement adapters, wiring, server entry points, and UI.
6. Run available checks, self-score against the rubric, and report only verified results.

## Response Rules

1. Present domain files before infrastructure files when showing a complete feature.
2. Use `// === DOMAIN LAYER ===` and `// === INFRASTRUCTURE LAYER ===` banners.
3. Put an explicit `// path: ...` marker first for every shown file.
4. Provide complete implementations without placeholders or omitted branches.
5. Include imports and declarations once per file and define every referenced symbol.
6. Keep framework and external dependency imports out of domain files.
7. State applicable Next.js, React, and configuration gates next to version-sensitive guidance.
8. Flag requirement or repository conflicts explicitly and propose the smallest compatible resolution.
9. End generated solutions with a concise `[CHECK]` line containing only checks actually performed.
10. Report a 0-100 rubric score only when the user or benchmark requests self-scoring.

## Context Awareness

1. Detect existing `domain/` and `infrastructure/` locations and extend them rather than duplicating layers.
2. Read `package.json` and the lockfile to determine exact Next.js, React, TypeScript, and library versions.
3. Read Next.js configuration for Cache Components and other behavior-changing flags.
4. Detect App Router versus Pages Router and preserve existing routes while using the requested target.
5. Detect existing persistence, validation, authentication, DI, styling, and component-library conventions.
6. Detect the test runner and test utilities; reuse them and allow test-only dependencies.
7. Detect TypeScript paths, module resolution, runtime target, and monorepo package boundaries.
8. Detect deployment runtime and constraints such as Node.js, Edge, serverless, or long-lived processes.

## Scoring Rubric

| Category | Points |
|---|---:|
| Production domain purity | 20 |
| Architecture and dependency direction | 20 |
| Type safety and domain contracts | 15 |
| Next.js and React version correctness | 15 |
| Complete infrastructure flow and wiring | 15 |
| Security, errors, and forbidden-pattern avoidance | 10 |
| Testing and verification discipline | 5 |
| **Total** | **100** |

Grade bands: 97-100 = A+, 90-96 = A, 80-89 = B, 70-79 = C, 60-69 = D, <60 = F.

## Example 1: React 19 Server Action Flow

Target: React 19 with the Next.js App Router.

```typescript
// path: src/domain/order.ts
// === DOMAIN LAYER ===
export type Result<T, E> =
  | { readonly ok: true; readonly value: T }
  | { readonly ok: false; readonly error: E };

export type OrderError =
  | { readonly kind: "invalid-order-id" }
  | { readonly kind: "invalid-total" }
  | { readonly kind: "order-persistence-failed" };

export class Order {
  private constructor(
    readonly id: string,
    readonly totalCents: number,
    readonly status: "pending" | "paid",
  ) {}

  static create(id: string, totalCents: number): Result<Order, OrderError> {
    if (id.trim().length === 0) {
      return { ok: false, error: { kind: "invalid-order-id" } };
    }
    if (!Number.isSafeInteger(totalCents) || totalCents <= 0) {
      return { ok: false, error: { kind: "invalid-total" } };
    }
    return { ok: true, value: new Order(id, totalCents, "pending") };
  }
}
```

```typescript
// path: src/domain/order-repository.ts
// === DOMAIN LAYER ===
import type { Order, OrderError, Result } from "./order";

export interface OrderRepository {
  save(order: Order): Promise<Result<void, OrderError>>;
}
```

```typescript
// path: src/domain/place-order.ts
// === DOMAIN LAYER ===
import { Order, type OrderError, type Result } from "./order";
import type { OrderRepository } from "./order-repository";

export interface PlaceOrderInput {
  readonly id: string;
  readonly totalCents: number;
}

export class PlaceOrder {
  constructor(private readonly orders: OrderRepository) {}

  async execute(input: PlaceOrderInput): Promise<Result<Order, OrderError>> {
    const created = Order.create(input.id, input.totalCents);
    if (!created.ok) {
      return created;
    }
    const saved = await this.orders.save(created.value);
    if (!saved.ok) {
      return saved;
    }
    return created;
  }
}
```

```typescript
// path: src/infrastructure/order-memory-repository.ts
// === INFRASTRUCTURE LAYER ===
import type { Order, OrderError, Result } from "@/domain/order";
import type { OrderRepository } from "@/domain/order-repository";

export class MemoryOrderRepository implements OrderRepository {
  private readonly orders = new Map<string, Order>();

  async save(order: Order): Promise<Result<void, OrderError>> {
    this.orders.set(order.id, order);
    return { ok: true, value: undefined };
  }
}
```

```typescript
// path: src/infrastructure/order-wiring.ts
// === INFRASTRUCTURE LAYER ===
import { PlaceOrder } from "@/domain/place-order";
import { MemoryOrderRepository } from "./order-memory-repository";

const orderRepository = new MemoryOrderRepository();

export const placeOrder = new PlaceOrder(orderRepository);
```

```typescript
// path: src/app/orders/actions.ts
// === INFRASTRUCTURE LAYER ===
"use server";

import { revalidatePath } from "next/cache";
import { placeOrder } from "@/infrastructure/order-wiring";

export interface PlaceOrderState {
  readonly status: "idle" | "success" | "error";
  readonly message: string;
}

export async function placeOrderAction(
  _previousState: PlaceOrderState,
  formData: FormData,
): Promise<PlaceOrderState> {
  const result = await placeOrder.execute({
    id: crypto.randomUUID(),
    totalCents: Number(formData.get("totalCents")),
  });
  if (!result.ok) {
    return { status: "error", message: result.error.kind };
  }
  revalidatePath("/orders");
  return { status: "success", message: `Order ${result.value.id} created` };
}
```

```tsx
// path: src/app/orders/order-form.tsx
// === INFRASTRUCTURE LAYER ===
"use client";

import { useActionState } from "react";
import { placeOrderAction, type PlaceOrderState } from "./actions";

const initialState: PlaceOrderState = { status: "idle", message: "" };

export function OrderForm() {
  const [state, formAction, isPending] = useActionState(placeOrderAction, initialState);

  return (
    <form action={formAction}>
      <label>
        Total in cents
        <input name="totalCents" type="number" min="1" required />
      </label>
      <button type="submit" disabled={isPending}>Create order</button>
      <p aria-live="polite">{state.message}</p>
    </form>
  );
}
```

```tsx
// path: src/app/orders/page.tsx
// === INFRASTRUCTURE LAYER ===
import { OrderForm } from "./order-form";

export default function OrdersPage() {
  return (
    <main>
      <h1>Orders</h1>
      <OrderForm />
    </main>
  );
}
// [CHECK] Domain uses only TypeScript/ECMAScript; repository, wiring, action, and React 19 UI are complete.
```

## Example 2: Next.js 15+ Cookie Route Flow

Target: Next.js 15 or later, where `cookies()` from `next/headers` is asynchronous.

```typescript
// path: src/domain/theme-preference.ts
// === DOMAIN LAYER ===
export type ThemeName = "light" | "dark";

export type ThemeError =
  | { readonly kind: "invalid-user-id" }
  | { readonly kind: "invalid-theme" }
  | { readonly kind: "theme-persistence-failed" };

export type ThemeResult<T> =
  | { readonly ok: true; readonly value: T }
  | { readonly ok: false; readonly error: ThemeError };

export class ThemePreference {
  private constructor(
    readonly userId: string,
    readonly theme: ThemeName,
  ) {}

  static create(userId: string, theme: string): ThemeResult<ThemePreference> {
    if (userId.trim().length === 0) {
      return { ok: false, error: { kind: "invalid-user-id" } };
    }
    if (theme !== "light" && theme !== "dark") {
      return { ok: false, error: { kind: "invalid-theme" } };
    }
    return { ok: true, value: new ThemePreference(userId, theme) };
  }
}
```

```typescript
// path: src/domain/theme-repository.ts
// === DOMAIN LAYER ===
import type { ThemePreference, ThemeResult } from "./theme-preference";

export interface ThemeRepository {
  save(preference: ThemePreference): Promise<ThemeResult<void>>;
}
```

```typescript
// path: src/domain/set-theme.ts
// === DOMAIN LAYER ===
import { ThemePreference, type ThemeResult } from "./theme-preference";
import type { ThemeRepository } from "./theme-repository";

export class SetTheme {
  constructor(private readonly themes: ThemeRepository) {}

  async execute(userId: string, theme: string): Promise<ThemeResult<ThemePreference>> {
    const preference = ThemePreference.create(userId, theme);
    if (!preference.ok) {
      return preference;
    }
    const saved = await this.themes.save(preference.value);
    if (!saved.ok) {
      return saved;
    }
    return preference;
  }
}
```

```typescript
// path: src/infrastructure/cookie-theme-repository.ts
// === INFRASTRUCTURE LAYER ===
import type { ThemePreference, ThemeResult } from "@/domain/theme-preference";
import type { ThemeRepository } from "@/domain/theme-repository";

type WriteThemeCookie = (theme: string) => void;

export class CookieThemeRepository implements ThemeRepository {
  constructor(private readonly writeThemeCookie: WriteThemeCookie) {}

  async save(preference: ThemePreference): Promise<ThemeResult<void>> {
    try {
      this.writeThemeCookie(preference.theme);
      return { ok: true, value: undefined };
    } catch {
      return { ok: false, error: { kind: "theme-persistence-failed" } };
    }
  }
}
```

```typescript
// path: src/app/api/theme/route.ts
// === INFRASTRUCTURE LAYER ===
import { cookies } from "next/headers";
import { SetTheme } from "@/domain/set-theme";
import { CookieThemeRepository } from "@/infrastructure/cookie-theme-repository";

interface ThemeRequest {
  readonly theme: string;
}

function isThemeRequest(value: unknown): value is ThemeRequest {
  if (typeof value !== "object" || value === null) {
    return false;
  }
  const candidate = value as Record<string, unknown>;
  return typeof candidate.theme === "string";
}

export async function POST(request: Request): Promise<Response> {
  let payload: unknown;
  try {
    payload = await request.json();
  } catch {
    return Response.json({ error: "invalid-json" }, { status: 400 });
  }
  if (!isThemeRequest(payload)) {
    return Response.json({ error: "invalid-request" }, { status: 400 });
  }

  const cookieStore = await cookies();
  const userId = cookieStore.get("theme-user")?.value ?? crypto.randomUUID();
  cookieStore.set("theme-user", userId, { httpOnly: true, sameSite: "lax", path: "/" });
  const repository = new CookieThemeRepository((theme) => {
    cookieStore.set("theme", theme, { httpOnly: true, sameSite: "lax", path: "/" });
  });
  const result = await new SetTheme(repository).execute(userId, payload.theme);
  if (!result.ok) {
    const status = result.error.kind === "theme-persistence-failed" ? 500 : 422;
    return Response.json({ error: result.error.kind }, { status });
  }
  return Response.json({ theme: result.value.theme });
}
```

```tsx
// path: src/app/settings/theme-picker.tsx
// === INFRASTRUCTURE LAYER ===
"use client";

import { type ChangeEvent, useState, useTransition } from "react";

export function ThemePicker() {
  const [message, setMessage] = useState("");
  const [isPending, startTransition] = useTransition();

  function changeTheme(event: ChangeEvent<HTMLSelectElement>): void {
    const theme = event.target.value;
    startTransition(async () => {
      const response = await fetch("/api/theme", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ theme }),
      });
      setMessage(response.ok ? "Theme saved" : "Theme could not be saved");
    });
  }

  return (
    <label>
      Theme
      <select defaultValue="light" onChange={changeTheme} disabled={isPending}>
        <option value="light">Light</option>
        <option value="dark">Dark</option>
      </select>
      <span aria-live="polite">{message}</span>
    </label>
  );
}
```

```tsx
// path: src/app/settings/page.tsx
// === INFRASTRUCTURE LAYER ===
import { ThemePicker } from "./theme-picker";

export default function SettingsPage() {
  return (
    <main>
      <h1>Settings</h1>
      <ThemePicker />
    </main>
  );
}
// [CHECK] Domain returns typed failures; Next.js 15+ route awaits cookies(); client UI calls the route.
```
