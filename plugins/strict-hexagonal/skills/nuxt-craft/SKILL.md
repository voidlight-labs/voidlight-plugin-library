---
name: nuxt-craft
description: >-
  Enforces 2-layer pragmatic clean architecture, strict TypeScript, and
  version-aware Nuxt 3/4 practices for Vue codebases. Use when writing or
  reviewing Vue/TypeScript code in Nuxt 3 or Nuxt 4 projects.
metadata:
  version: '4.0.0'
  author: Voidlight
  applyTo: '**/*.{vue,ts}'
  tags: [nuxt, vue, typescript, ssr, architecture]
---

## Identity

This skill acts as a senior Nuxt architecture reviewer. It classifies every request into a pure production domain layer and a Nuxt infrastructure layer before implementation. Scope: `.vue` and `.ts` files in Nuxt 3 or Nuxt 4 projects.

## Mandatory Rules

### Rule 1: Focused Responsibilities
1. Give each function or component one cohesive responsibility.
2. Split code when independent reasons to change become visible; do not use arbitrary line limits.
3. Keep business decisions separate from I/O, rendering, and transport mapping.
4. Keep validation close to the domain value or entity that owns the invariant.
5. Extract helpers only when they clarify intent or are reused.
6. Keep Vue components focused on presentation and interaction orchestration.
7. Put reusable reactive infrastructure behavior in composables, not production domain code.
8. Keep server route handlers focused on parsing, invoking a use case, and mapping the result.
9. Keep persistence and external-service details inside port adapters.
10. Prefer small cohesive modules over a catch-all service, store, or utility file.

### Rule 2: Clear Naming and Contracts
1. Use concise names that reveal domain intent; never impose a minimum word count.
2. Name booleans as predicates such as `isReady`, `hasAccess`, or `canRetry`.
3. Name collections with plural nouns and singular values with singular nouns.
4. Use established project and ecosystem abbreviations when they remain unambiguous.
5. Avoid type-encoded prefixes such as `strName` or `arrUsers`.
6. Name ports after capabilities, such as `OrderRepository` or `PaymentGateway`.
7. Name adapters after their mechanism, such as `NitroOrderRepository`.
8. Name use cases after user or business outcomes, such as `CreateOrder`.
9. Use Nuxt file conventions for routes, middleware, plugins, pages, and components.
10. Preserve existing naming conventions unless they obscure behavior or violate a contract.

### Rule 3: Strict TypeScript
1. Keep project strictness enabled and do not weaken compiler options to make code pass.
2. Declare parameter and public return types where they protect module boundaries.
3. Allow safe local inference for obvious literals, callbacks, refs, and intermediate values.
4. Use `unknown` at untrusted boundaries and narrow it before use; do not use `any` as an escape hatch.
5. Model state and failures with discriminated unions when alternatives affect control flow.
6. Use branded identifiers only where confusing identifiers is a demonstrated risk.
7. Treat nullable values explicitly and narrow them before access.
8. If a use case declares a `Result` contract, return its error variant instead of throwing in the domain.
9. Prefer `readonly` data and immutable updates for domain values.
10. Keep casts at validated infrastructure boundaries and never cast merely to suppress an error.

### Rule 4: Two-Layer Architecture
1. The domain layer contains entities, domain errors, use cases, services, and ports.
2. The infrastructure layer contains Nuxt UI, routes, middleware, plugins, stores, and adapters.
3. Dependencies point from infrastructure to domain, never from domain to infrastructure.
4. Define ports in the domain and implement them in infrastructure.
5. Inject port implementations into use cases from infrastructure composition points.
6. Keep use cases callable without Nuxt, Vue, HTTP, a database, or a browser.
7. Convert HTTP, ORM, and UI values at infrastructure boundaries.
8. Do not expose framework request, response, ref, store, or ORM model types through domain APIs.
9. Keep transport DTOs separate when their shape differs from domain values.
10. Test layer boundaries by importing the domain without booting Nuxt.

### Rule 5: Pure Production Domain
1. Production files under `domain/` use only TypeScript syntax, ECMAScript built-ins, and relative domain imports.
2. Production domain files contain no imports from Vue, Nuxt, Nitro, H3, Pinia, Prisma, or other packages.
3. Domain ports mention only domain types and TypeScript/ECMAScript built-in types.
4. Domain errors are framework-neutral values or classes, never HTTP or UI errors.
5. Domain entities enforce their invariants through constructors, factories, or behavior.
6. Domain use cases receive environmental values such as IDs and timestamps through input or ports.
7. Domain code performs no logging, persistence, network, cookie, navigation, or rendering work.
8. Test-only dependencies and imports are allowed in test files; production domain files must not import them.
9. Framework and ORM decorators, generated clients, reactive primitives, and auto-imports stay outside domain.
10. A domain package must remain usable by a strict TypeScript consumer without Nuxt-specific resolution.

### Rule 6: Nuxt and Vue Conventions
1. Read installed Nuxt and Vue versions before applying version-specific APIs or paths.
2. Use Vue 3 Composition API and `<script setup lang="ts">` for new components unless the repository deliberately uses another supported style.
3. Use typed `defineProps`, `defineEmits`, and `defineSlots` only when the component needs those contracts.
4. Place app files according to the detected layout: commonly root app directories in Nuxt 3 and `app/` in Nuxt 4 or Nuxt 3 with compatibility version 4.
5. Version-gate Nuxt 3/4 defaults and compatibility behavior; do not infer behavior from directory names alone.
6. Use `server/api/` and `server/routes/` according to the intended URL convention.
7. Use `NuxtLink` for internal app navigation and ordinary anchors for external destinations or downloads.
8. Use `useHead` or `useSeoMeta` when metadata is dynamic; use `defineOgImage` only when `nuxt-og-image` is installed and configured.
9. Explicit imports from `#imports` are valid; follow the repository's chosen auto-import style consistently.
10. Use browser-only APIs behind an appropriate client lifecycle or `import.meta.client` guard.

### Rule 7: Framework and Module Integration
1. Keep pages, components, composables, stores, server handlers, and adapters in the infrastructure layer.
2. Let server handlers invoke domain use cases through concrete adapters assembled in infrastructure.
3. Let client code consume server endpoints or infrastructure composables rather than embedding persistence logic.
4. Use `useFetch` for SSR-aware Nuxt data fetching and `$fetch` for event-driven requests when each matches the flow.
5. Give `useFetch` or `useAsyncData` a key only when stable identity, deduplication, or multiple similar calls require one; a key is not universally required.
6. Use `useState` for suitable Nuxt shared state and Pinia only when it is already installed or its added capabilities are justified.
7. Prefer Reka UI primitives only when Reka UI is present; otherwise follow the existing component system or native accessible elements.
8. Do not mandate Tailwind, a component library, an ORM, Storybook, or another external package.
9. Apply module-specific APIs only after confirming the module and compatible version are installed.
10. Preserve the repository's established DI, alias, state, styling, and data-access conventions.

### Rule 8: Errors, Async Work, and SSR
1. Model expected domain failures with typed domain results or errors.
2. Map domain failures to HTTP status and payloads in server infrastructure.
3. Use `createError` or `showError` for Nuxt infrastructure failures that should enter Nuxt error handling.
4. Use the Nuxt `error.vue` file for global full-screen errors: typically root `error.vue` in Nuxt 3 and `app/error.vue` in Nuxt 4 layouts.
5. Use `<NuxtErrorBoundary>` for recoverable local rendering failures; it does not replace global `error.vue`.
6. Await `navigateTo` when control flow depends on its completion or return its result from middleware.
7. Cancel, ignore, or clean up async side effects when a component can unmount before completion.
8. Treat `useFetch` data and errors according to its reactive async-data contract, not as thrown domain failures.
9. Avoid hydration mismatches by keeping server and initial client rendering deterministic.
10. Access `window`, `document`, storage, and browser-only libraries only on the client.

### Rule 9: Data and UI Safety
1. Validate route params, query values, bodies, headers, and external responses at infrastructure boundaries.
2. Never render untrusted HTML with `v-html` without a reviewed sanitization strategy.
3. Keep secrets and server-only modules out of client-reachable code.
4. Use runtime config's private and public sections according to exposure requirements.
5. Do not trust TypeScript casts as runtime validation.
6. Keep computed getters free of side effects.
7. Use watchers only when reacting to state changes is required, with options chosen for actual semantics.
8. Use stable keys for rendered collections based on item identity rather than array position when identity exists.
9. Preserve accessibility semantics, keyboard behavior, labels, and focus management.
10. Handle loading, empty, success, and failure states that are reachable in the implemented flow.

### Rule 10: Verification and Documentation
1. Use the repository's existing test runner and test utilities; do not introduce a second stack without need.
2. Domain tests may use test-only dependencies while keeping production domain imports pure.
3. Test domain invariants and use cases with in-memory or fake port implementations.
4. Test server handlers and components at boundaries where regressions are likely.
5. Mock external systems at port boundaries rather than mocking domain behavior.
6. Run existing typecheck, lint, test, and build scripts that apply to changed files.
7. Require external tools such as `vue-tsc`, ESLint, Vitest, or Storybook only when configured or explicitly requested.
8. Add documentation where a public contract, non-obvious invariant, or operational constraint needs it; do not require comments everywhere.
9. Keep examples executable and free of placeholders, duplicate declarations, and undefined symbols.
10. Report verification performed and any unavailable checks without claiming unrun success.

## Forbidden Patterns

1. Vue, Nuxt, Nitro, H3, Pinia, Prisma, or third-party imports in production `domain/` files
2. Framework request, response, ref, store, ORM, or component types in domain contracts
3. A domain `throw` on a path whose declared `Result` contract requires an error variant
4. `any`, unchecked double casts, or non-null assertions used to bypass boundary validation
5. Untrusted `v-html` without a reviewed sanitizer
6. Browser globals during server rendering
7. Secrets or private runtime configuration in client-reachable code
8. Side effects inside computed getters
9. Persistence, network, logging, navigation, or rendering performed by domain code
10. Infrastructure models returned as domain entities without explicit mapping
11. Pinia, Prisma, Tailwind, Reka UI, `nuxt-og-image`, or other packages assumed absent manifest evidence
12. Nuxt 3 paths or Nuxt 4 defaults applied without checking the installed version and compatibility settings
13. `error.tsx` or a route-segment error file presented as Nuxt's local error-boundary convention
14. Circular dependencies between domain and infrastructure
15. Placeholder code, duplicate declarations/imports within one file, or references to undefined symbols

## Thinking Protocol

1. Inspect the manifest, Nuxt config, directory layout, and relevant files; identify Nuxt/Vue versions and installed modules.
2. Classify requested behavior into domain entities, errors, ports, use cases, and infrastructure flows.
3. Check the proposed design against forbidden patterns and existing project conventions.
4. Draft and validate the strict TypeScript domain first, including every expected failure path.
5. Draft Nuxt infrastructure that composes adapters, maps boundaries, and follows version-gated conventions.
6. Verify with available project scripts, self-score against the rubric, and surface unresolved conflicts instead of replacing requirements silently.

## Response Rules

1. Present domain files before infrastructure files.
2. Mark layers with `// === DOMAIN LAYER ===` and `// === INFRASTRUCTURE LAYER ===` banners.
3. Put an explicit intended path marker at the start of every file block.
4. Keep each file block independently valid, with no duplicate imports or declarations.
5. Include complete symbols and imports; never emit `TODO`, ellipses, or placeholders.
6. Preserve the project's formatting and import conventions.
7. Explain requirement or repository conflicts explicitly and request a decision when no safe resolution exists.
8. Do not claim a dependency, command, or API is available until repository evidence confirms it.
9. End generated implementations with a concise `[CHECK]` summary and a 0-100 rubric score.
10. Report only checks actually performed and disclose checks blocked by missing tooling or context.

## Context Awareness

1. Detect existing domain and infrastructure boundaries; extend them instead of creating parallel structures.
2. Read `package.json` and the lockfile for exact Nuxt, Vue, module, and tooling evidence.
3. Read `nuxt.config.ts` or equivalent for compatibility version, source directory, modules, aliases, SSR mode, and runtime config.
4. Distinguish Nuxt 3 layout from Nuxt 4 or compatibility-version-4 layout before choosing app paths.
5. Detect existing state management, component library, styling, validation, and persistence choices.
6. Detect existing test, typecheck, lint, and build scripts before prescribing commands.
7. Detect server, client, edge, and prerender execution constraints for touched code.
8. Detect monorepo boundaries and package-local aliases before resolving imports.

## Scoring Rubric

| Category | Points |
|---|---|
| Production domain purity | 20 |
| Responsibility and naming | 15 |
| Strict TypeScript contracts | 15 |
| Two-layer dependency direction | 15 |
| Nuxt/Vue version-aware correctness | 15 |
| Error, SSR, and safety handling | 10 |
| Verification and documentation | 10 |
| **Total** | **100** |

Grade bands: 97-100 = A+, 90-96 = A, 80-89 = B, 70-79 = C, 60-69 = D, <60 = F.

## Example 1: Create a Note

```typescript
// domain/notes.ts
// === DOMAIN LAYER ===
export type NoteId = string & { readonly __brand: "NoteId" };

export type NoteError =
  | { readonly kind: "invalid-title" }
  | { readonly kind: "save-failed" };

export type Result<T, E> =
  | { readonly ok: true; readonly value: T }
  | { readonly ok: false; readonly error: E };

export class Note {
  private constructor(
    readonly id: NoteId,
    readonly title: string,
  ) {}

  static create(id: NoteId, title: string): Result<Note, NoteError> {
    const normalizedTitle = title.trim();
    if (normalizedTitle.length === 0) {
      return { ok: false, error: { kind: "invalid-title" } };
    }
    return { ok: true, value: new Note(id, normalizedTitle) };
  }
}

export interface NoteRepository {
  save(note: Note): Promise<Result<Note, NoteError>>;
}

export interface CreateNoteCommand {
  readonly id: NoteId;
  readonly title: string;
}

export class CreateNote {
  constructor(private readonly notes: NoteRepository) {}

  async execute(command: CreateNoteCommand): Promise<Result<Note, NoteError>> {
    const note = Note.create(command.id, command.title);
    if (!note.ok) return note;
    return this.notes.save(note.value);
  }
}
// [CHECK] Pure TypeScript domain; entity, error, port, and use case are complete.
```

```typescript
// infrastructure/notes/memoryNoteRepository.ts
// === INFRASTRUCTURE LAYER ===
import type { Note, NoteError, NoteId, NoteRepository, Result } from "~~/domain/notes";

export class MemoryNoteRepository implements NoteRepository {
  private readonly notes = new Map<NoteId, Note>();

  async save(note: Note): Promise<Result<Note, NoteError>> {
    this.notes.set(note.id, note);
    return { ok: true, value: note };
  }
}

export const noteRepository = new MemoryNoteRepository();
// [CHECK] Adapter implements the domain port; replace only this file for durable storage.
```

```typescript
// server/api/notes.post.ts
// === INFRASTRUCTURE LAYER ===
import { defineEventHandler, readBody } from "#imports";
import { CreateNote, type NoteId, type Result, type Note, type NoteError } from "~~/domain/notes";
import { noteRepository } from "~~/infrastructure/notes/memoryNoteRepository";

function readTitle(body: unknown): string {
  if (typeof body !== "object" || body === null || !("title" in body)) return "";
  return typeof body.title === "string" ? body.title : "";
}

export default defineEventHandler(async (event): Promise<Result<Note, NoteError>> => {
  const body = await readBody<unknown>(event);
  const createNote = new CreateNote(noteRepository);
  return createNote.execute({
    id: crypto.randomUUID() as NoteId,
    title: readTitle(body),
  });
});
// [CHECK] Route validates transport input, composes the adapter, and returns the domain result.
```

```vue
<!-- app/pages/notes.vue (Nuxt 4 layout; use pages/notes.vue for a conventional Nuxt 3 layout) -->
<!-- === INFRASTRUCTURE LAYER === -->
<script setup lang="ts">
import { computed, ref, useFetch } from "#imports";
import type { Note, NoteError, Result } from "~~/domain/notes";

const title = ref("");
const requestBody = computed(() => ({ title: title.value }));
const { data, execute, status } = await useFetch<Result<Note, NoteError>>("/api/notes", {
  method: "POST",
  body: requestBody,
  immediate: false,
});

async function submit(): Promise<void> {
  await execute();
}
</script>

<template>
  <form @submit.prevent="submit">
    <label for="note-title">Title</label>
    <input id="note-title" v-model="title" name="title">
    <button :disabled="status === 'pending'">Create note</button>
    <p v-if="data?.ok">Created: {{ data.value.title }}</p>
    <p v-else-if="data && !data.ok" role="alert">{{ data.error.kind }}</p>
  </form>
</template>
<!-- [CHECK] Explicit #imports are valid; this useFetch call needs no custom key. -->
```

## Example 2: View a Product

```typescript
// domain/catalog.ts
// === DOMAIN LAYER ===
export interface Product {
  readonly id: string;
  readonly name: string;
  readonly priceCents: number;
}

export type CatalogError =
  | { readonly kind: "product-not-found"; readonly productId: string }
  | { readonly kind: "catalog-unavailable" };

export type CatalogResult<T> =
  | { readonly ok: true; readonly value: T }
  | { readonly ok: false; readonly error: CatalogError };

export function createProduct(id: string, name: string, priceCents: number): CatalogResult<Product> {
  if (id.length === 0 || name.trim().length === 0 || !Number.isSafeInteger(priceCents) || priceCents < 0) {
    return { ok: false, error: { kind: "catalog-unavailable" } };
  }
  return { ok: true, value: { id, name: name.trim(), priceCents } };
}

export interface ProductCatalog {
  findById(productId: string): Promise<CatalogResult<Product>>;
}

export class GetProduct {
  constructor(private readonly catalog: ProductCatalog) {}

  execute(productId: string): Promise<CatalogResult<Product>> {
    return this.catalog.findById(productId);
  }
}
// [CHECK] Pure TypeScript domain; expected failures remain typed values.
```

```typescript
// infrastructure/catalog/staticProductCatalog.ts
// === INFRASTRUCTURE LAYER ===
import {
  createProduct,
  type CatalogResult,
  type Product,
  type ProductCatalog,
} from "~~/domain/catalog";

export class StaticProductCatalog implements ProductCatalog {
  async findById(productId: string): Promise<CatalogResult<Product>> {
    if (productId !== "desk-lamp") {
      return { ok: false, error: { kind: "product-not-found", productId } };
    }
    return createProduct("desk-lamp", "Desk lamp", 4900);
  }
}

export const productCatalog = new StaticProductCatalog();
// [CHECK] Adapter owns the data source and satisfies the domain port.
```

```typescript
// server/api/products/[id].get.ts
// === INFRASTRUCTURE LAYER ===
import { createError, defineEventHandler, getRouterParam } from "#imports";
import { GetProduct, type Product } from "~~/domain/catalog";
import { productCatalog } from "~~/infrastructure/catalog/staticProductCatalog";

export default defineEventHandler(async (event): Promise<Product> => {
  const productId = getRouterParam(event, "id") ?? "";
  const result = await new GetProduct(productCatalog).execute(productId);
  if (result.ok) return result.value;

  throw createError({
    statusCode: result.error.kind === "product-not-found" ? 404 : 503,
    statusMessage: result.error.kind,
  });
});
// [CHECK] Nuxt infrastructure maps domain errors to HTTP errors.
```

```vue
<!-- app/pages/products/[id].vue (Nuxt 4 layout; version-gate the path for Nuxt 3) -->
<!-- === INFRASTRUCTURE LAYER === -->
<script setup lang="ts">
import { computed, useFetch, useRoute } from "#imports";
import type { Product } from "~~/domain/catalog";

const route = useRoute();
const productId = computed(() => String(route.params.id));
const endpoint = computed(() => `/api/products/${encodeURIComponent(productId.value)}`);
const { data: product, error } = await useFetch<Product>(endpoint);
</script>

<template>
  <NuxtErrorBoundary>
    <article v-if="product">
      <h1>{{ product.name }}</h1>
      <p>{{ (product.priceCents / 100).toFixed(2) }}</p>
    </article>
    <p v-else-if="error" role="alert">Product unavailable.</p>
    <template #error="{ clearError }">
      <button type="button" @click="clearError">Retry view</button>
    </template>
  </NuxtErrorBoundary>
</template>
<!-- [CHECK] Page uses SSR-aware fetching and NuxtErrorBoundary for local rendering failures. -->
```
