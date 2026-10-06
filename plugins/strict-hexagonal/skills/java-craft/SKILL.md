---
name: java-craft
description: >-
  Enforces pragmatic 2-layer architecture, domain purity, type safety, and
  modern Spring Boot or Quarkus integration for Java codebases. Value Objects
  own invariant behavior; external capabilities are declared as Ports. Use
  when writing or reviewing Java code in Spring Boot or Quarkus projects.
metadata:
  version: '4.0.0'
  author: Voidlight
  applyTo: '**/*.java'
  tags: [java, spring, quarkus, jvm, typesafe, architecture]
---

## Identity

This skill acts as a senior Java implementation and review guide for 2-layer architecture. Production domain code uses only the Java standard library; infrastructure owns frameworks, transports, persistence, configuration, and observability. Value Objects carry invariant behavior; external capabilities (hashing, payment, messaging) are declared as Ports in the domain and implemented as Adapters in infrastructure. Test source may use libraries declared with test-only scope, but domain unit tests never use Spring or Quarkus fixtures. Scope: Java source files. Inspect project manifests before selecting Java features, frameworks, libraries, or tooling.

## Mandatory Rules

### Rule 1: Single Responsibility Principle
1. Give each method one cohesive purpose; split it when independent behavior can be named and tested separately.
2. Give each class one primary reason to change while allowing tightly related state and invariant enforcement to remain together.
3. Keep methods and classes small enough to understand locally; use project limits when configured rather than arbitrary universal line caps.
4. Extract helpers only when they clarify intent, remove duplication, or isolate a meaningful policy.
5. Keep transport, persistence, and external I/O out of domain behavior.
6. Keep boundary parsing and representation conversion in infrastructure; enforce business invariants in domain.
7. Keep normal control flow readable and map expected errors at the boundary that owns the target representation.
8. Make domain calculations deterministic when possible and inject ports for required side effects.
9. Name methods for observable intent rather than implementation mechanics.
10. Prefer cohesive code over fragmented one-line helpers or speculative abstractions.

### Rule 2: Descriptive Naming
1. Use concise, descriptive names; never impose an arbitrary word-count minimum.
2. Name variables by role and meaning, such as `requestedTitle` or `savedOrder`, not vague containers such as `data` or `temp`.
3. Name booleans as predicates when practical, such as `isValid`, `hasAccess`, or `shouldRetry`.
4. Use plural names for collections and singular names for individual values.
5. Use domain terminology consistently and reserve abbreviations for established project or Java conventions.
6. Do not use Hungarian notation or redundant type prefixes.
7. Name constants with `UPPER_SNAKE_CASE` and packages with lowercase segments.
8. Let framework callbacks, interface implementations, overrides, constructors, accessors, and standard factory conventions retain their required or idiomatic names.
9. Name exception types for the failed domain condition and expose stable machine-readable error codes where consumers need them.
10. Rename misleading symbols before output; do not inflate clear names merely to satisfy a naming formula.

### Rule 3: Java Type Safety
1. Declare parameter, field, and method return types explicitly as required by Java.
2. Use local `var` only when the inferred type is unambiguous from the initializer and does not hide important semantics.
3. Never use raw generic types; provide type arguments and meaningful bounds where constraints are required.
4. Prefer domain value types, records, enums, or dedicated classes over interchangeable primitive or string identifiers when mix-ups are plausible.
5. Use `Optional<T>` for intentionally absent return values, not for fields, parameters, or every nullable boundary value.
6. Never return `null` from domain APIs; validate required inputs and represent legitimate absence explicitly.
7. Make fields `final` unless mutation is part of the type's explicit behavior.
8. Use sealed types only for genuinely closed hierarchies and only when the configured Java version supports them.
9. Avoid unchecked casts and wildcard-heavy APIs; isolate unavoidable framework casts in infrastructure and verify them.
10. Model expected domain failures with typed domain exceptions or explicit result types according to the existing project convention.

### Rule 4: 2-Layer Architecture
1. The domain layer contains entities, value objects, use cases, domain services, domain errors, and port interfaces.
2. The infrastructure layer contains HTTP boundaries, persistence adapters, external clients, framework configuration, DI wiring, and observability.
3. Production domain source MUST compile with the configured Java standard library alone.
4. Production domain source MUST have zero Spring, Quarkus, Jakarta framework, persistence, logging, or other third-party imports.
5. Domain ports use only domain and Java standard-library types.
6. Infrastructure adapters implement domain ports and translate infrastructure representations at their boundaries.
7. Infrastructure wiring constructs use cases and supplies port implementations through constructors.
8. Use cases remain callable without HTTP, persistence frameworks, containers, or test fixtures.
9. Entities own meaningful invariants and behavior rather than acting as framework-shaped data bags.
10. Framework DTOs, ORM entities, responses, configuration objects, and exceptions never leak into domain APIs.

### Rule 5: Domain Purity
1. Place production domain code under the project's domain package and keep it independent of infrastructure packages.
2. Import only `java.*` and other production domain types from production domain source.
3. Do not annotate domain types with dependency injection, HTTP, serialization, validation, ORM, or logging annotations.
4. Express domain errors without HTTP status codes, framework exception bases, or persistence exception types.
5. Accept domain values or standard-library values at use-case and port boundaries, never request, response, entity-manager, or framework context objects.
6. Pass clocks, identifiers, persistence, messaging, and external capabilities through explicit values or domain ports when determinism matters.
7. Keep use cases as plain Java classes with constructor-supplied dependencies.
8. Keep controllers, resources, presenters, mappers, adapters, and framework configuration in infrastructure.
9. Prevent dependency cycles: infrastructure may depend on domain, while domain never depends on infrastructure.
10. Permit declared test-only libraries in test source, but keep domain unit tests free of Spring and Quarkus fixtures.

### Rule 6: Value Objects Own Invariants
1. Value objects are immutable, compared by value, and have no business identity.
2. Value objects MAY contain behavior: invariant enforcement, validation rules, and pure calculations that need no external dependency.
3. Value objects MUST NOT perform side effects, randomness, or I/O; those belong to ports.
4. Value object constructors and factory methods MUST reject invalid state and throw domain exceptions.
5. Primitive or string identifiers that carry rules (email format, password strength, money scale) MUST be modeled as value objects.
6. Value objects MUST NOT import framework or third-party libraries; they compile with `java.*` and domain types only.
7. A value object that needs an external capability (hashing, payment, messaging) MUST delegate to a port, never embed the implementation.
8. Value object validation that requires external data (e.g., uniqueness check) MUST happen in the use case or port, not in the value object.
9. Prefer records for immutable data carriers when supported and when record semantics fit; use classes for identity, behavior, or controlled mutation.
10. Return value objects from port methods when the result is a domain concept, not a primitive.

### Rule 7: Ports for External Capabilities
1. A port is a domain-defined interface that declares a capability the domain needs but does not implement.
2. Repositories are ports; so are hashers, token generators, payment gateways, email senders, and clock providers.
3. Ports reside in the domain layer and use only domain and Java standard-library types.
4. Ports MUST NOT leak framework types such as `Page<T>`, `Sort`, `Pageable`, `EntityManager`, or `HttpResponse`.
5. Infrastructure adapters implement ports and own all framework-specific code.
6. A port that produces randomness or side effects (hashing, token generation) MUST return a domain value object, not a raw primitive, when the result carries domain meaning.
7. Use cases receive ports through constructor injection and remain agnostic of the adapter implementation.
8. Domain services are stateless pure logic; if a domain service needs an external capability, it becomes a port or receives a port.
9. Do not create a port for logic that can be expressed as a pure function inside a value object or entity.
10. Name ports for the capability they provide: `UserRepository`, `PasswordHasher`, `TokenGenerator`, `PaymentGateway`.

### Rule 8: Java Idioms
1. Use records for immutable data carriers when supported and when record semantics fit; use classes for identity, behavior, or controlled mutation.
2. Use `Objects.requireNonNull` or explicit checks for required constructor and method inputs.
3. Use `BigDecimal` for decimal money and define scale and rounding rules at the owning boundary or domain policy.
4. Use `Instant`, `LocalDate`, `OffsetDateTime`, or `ZonedDateTime` according to semantics; avoid legacy `Date` and `Calendar` in new code.
5. Return immutable snapshots with `List.copyOf`, `Set.copyOf`, or `Map.copyOf` when exposing collections.
6. Prefer clear loops or streams according to readability; do not force streams for stateful or exception-heavy logic.
7. Use try-with-resources for owned `AutoCloseable` resources.
8. Preserve interrupt status when handling `InterruptedException`, unless the method deliberately propagates it.
9. Use checked or unchecked exceptions consistently with the existing codebase and make recovery expectations explicit.
10. Gate records, sealed types, pattern matching, virtual threads, and other language features on the Java version declared by the project.

### Rule 9: Spring Boot and Quarkus Integration
1. Use constructor injection only; injected dependencies are `final`, with no Spring or Quarkus field injection.
2. Keep framework annotations in infrastructure, including `@RestController`, `@Path`, `@Repository`, `@ApplicationScoped`, and transaction annotations.
3. In Spring Boot, bind grouped configuration with type-safe `@ConfigurationProperties` infrastructure types rather than scattered `@Value` fields.
4. In Spring Boot, use `@RestControllerAdvice` for REST response-body error mapping; use `@ControllerAdvice` when MVC views, binders, or shared controller behavior are intended.
5. In Quarkus, use an `ExceptionMapper` for JAX-RS error responses and constructor injection for resources and adapters.
6. Keep JPA, Hibernate, Panache, JDBC, and framework persistence models in infrastructure and map them to domain types.
7. Put Spring `@Bean` methods or Quarkus CDI producer methods in infrastructure wiring when a plain domain class needs container construction.
8. Apply transaction boundaries in infrastructure around use-case execution or adapter operations, never in domain.
9. Use Spring, Quarkus, MicroProfile, Jakarta, or extension-specific APIs only when the corresponding dependency and version are present in project manifests.
10. Follow the selected framework's supported configuration and serialization conventions without mixing Spring and Quarkus APIs in one application path.

### Rule 10: Errors and Boundaries
1. Give expected domain failures dedicated types or a shared domain error base with stable codes when callers branch on them.
2. Throw domain errors for violated business rules without embedding HTTP, database, or framework details.
3. Map domain errors to HTTP responses in the inbound infrastructure boundary.
4. Translate persistence or client failures only when the domain port contract defines a meaningful domain outcome; otherwise retain an infrastructure failure and handle it at the application boundary.
5. Do not impose blanket exception translation across unrelated layers or erase diagnostic causes.
6. Never swallow exceptions; propagate, map, or log them once at the boundary responsible for recovery or reporting.
7. Catch specific exceptions whenever recovery or mapping is type-specific; use a final broad boundary handler only for safe generic responses and diagnostics.
8. Keep retries, timeouts, circuit breakers, and transport status policies in infrastructure.
9. Never expose stack traces, internal exception messages, SQL details, or secrets in public responses.
10. Preserve causes when translating exceptions and avoid duplicate logging at every stack frame.

### Rule 11: Testing Discipline
1. Domain unit tests may use test-only libraries declared in Maven or Gradle, including the project's existing JUnit version and assertion library.
2. Domain unit tests MUST NOT use Spring Test, `@SpringBootTest`, Quarkus Test, `@QuarkusTest`, CDI containers, or framework fixtures.
3. Test use cases with small hand-written port fakes or the project's declared mocking library at port boundaries.
4. Test entity invariants, use-case outcomes, value object validation, and expected domain errors through public APIs.
5. Add parameterized or property-based tests only when the required test dependency exists and the input space benefits from them.
6. Test infrastructure adapters with focused contract or integration tests using the framework facilities already declared by the project.
7. Do not test private methods directly or mock domain entities and value objects.
8. Make tests deterministic by controlling time, identifiers, randomness, and external effects through explicit inputs or ports.
9. Follow the repository's test source layout, naming convention, and coverage policy rather than inventing universal thresholds.
10. Every behavior change includes targeted tests when the repository contains a runnable test setup; disclose when verification cannot run.

### Rule 12: Documentation, Observability, and Tooling
1. Document public domain contracts when invariants, side effects, idempotency, absence, or failure behavior are not obvious from types and names.
2. Keep comments focused on rationale and constraints, not line-by-line narration.
3. Keep logging, metrics, tracing, correlation IDs, and framework health checks in infrastructure.
4. Never import a logging facade or telemetry API into production domain source.
5. Use the logging API already declared by the project and avoid `System.out`, `System.err`, and stack-trace printing in production paths.
6. Log failures at the boundary that handles or terminates them; avoid duplicate logs for the same propagated failure.
7. Run Maven or Gradle checks using the wrapper and tasks present in the repository.
8. Recommend or invoke Checkstyle, SpotBugs, Error Prone, ArchUnit, coverage, or formatting tools only when configured in project manifests or explicitly requested.
9. Match existing package documentation and Javadoc conventions instead of generating ceremonial documentation.
10. Keep configuration examples, commands, and dependency advice compatible with the versions found in `pom.xml`, Gradle files, version catalogs, and wrapper metadata.

## Forbidden Patterns

1. Framework or third-party imports in production domain source
2. Spring `@Autowired` or Quarkus/Jakarta `@Inject` on fields
3. Infrastructure DTOs, ORM entities, configuration types, or exceptions in domain APIs
4. Raw generic types or unchecked casts without isolated justification
5. `null` returns from domain methods
6. `float` or `double` for decimal money
7. New uses of `java.util.Date` or `Calendar` when `java.time` expresses the semantics
8. `System.out`, `System.err`, or `printStackTrace()` in production paths
9. Empty catch blocks or silently swallowed failures
10. HTTP status codes or transport response types in domain errors
11. Persistence queries, transactions, retries, or timeouts embedded in domain entities or use cases
12. Mutable public fields or externally mutable collection exposure
13. Reflection-driven business logic when normal polymorphism or explicit mapping suffices
14. Spring or Quarkus test fixtures in domain unit tests
15. Undeclared third-party libraries, plugins, framework features, or tooling assumptions
16. Value objects that perform side effects, randomness, or I/O instead of delegating to ports
17. Ports that leak framework types into domain signatures

## Thinking Protocol

1. Classify requested behavior into domain concepts and infrastructure concerns.
2. Determine whether a behavior is a pure invariant (value object), a cross-entity calculation (domain service), or an external capability (port).
3. Inspect Java version, framework, dependencies, test libraries, package layout, and configured tooling in project manifests.
4. Define the minimum entities, value objects, errors, use cases, and ports needed for the behavior.
5. Draft and verify the production domain with standard-library-only imports and no infrastructure references.
6. Draft infrastructure adapters, HTTP boundaries, error mapping, configuration, and constructor-based wiring against the domain contracts.
7. Replace violations before output, run available targeted checks, self-score, and disclose any unavoidable deviation or unverified assumption.

## Response Rules

1. Present production domain files before infrastructure files for a new vertical slice.
2. Mark layer transitions with `// === DOMAIN LAYER ===` and `// === INFRASTRUCTURE LAYER ===` banners.
3. Put the full intended file path in a first-line comment for every generated Java file.
4. Provide complete code for requested behavior without `TODO`, omitted bodies, ellipses, or placeholder symbols.
5. Keep imports explicit enough to identify layer dependencies and avoid wildcard imports in generated code.
6. Use descriptive naming while preserving required framework, interface, override, constructor, accessor, and conventional method names.
7. Use explicit Java types except for unambiguous local inference where `var` improves readability without hiding semantics.
8. Replace detected rule violations before output rather than rejecting them silently.
9. Disclose unavoidable deviations, missing manifest evidence, and checks that could not run.
10. End generated-code responses with a concise `[CHECK]` summary and a 0-100 rubric score.

## Context Awareness

1. Detect existing domain and infrastructure packages and extend them instead of creating parallel layouts.
2. Detect Maven or Gradle, wrapper usage, multi-module boundaries, source sets, and package conventions.
3. Detect the configured Java release before using version-gated language or runtime features.
4. Detect Spring Boot or Quarkus and their versions from manifests and imports; never mix their APIs accidentally.
5. Detect existing constructor-injection and bean-wiring patterns while replacing field injection in changed code.
6. Detect existing test frameworks and test-only dependencies; do not introduce another stack without a requirement.
7. Detect configured persistence, serialization, validation, logging, static-analysis, formatting, and coverage tools before using them.
8. Detect local changes and neighboring conventions so edits remain scoped and do not overwrite unrelated work.

## Scoring Rubric

| Category | Points |
|---|---:|
| Domain purity | 20 |
| Responsibility and cohesion | 15 |
| Naming and Java type safety | 15 |
| Layering and port correctness | 15 |
| Framework boundary correctness | 15 |
| Forbidden-pattern avoidance | 10 |
| Testing, documentation, and verification | 10 |
| **Total** | **100** |

Grade bands: 97-100 = A+, 90-96 = A, 80-89 = B, 70-79 = C, 60-69 = D, below 60 = F.

## Examples

Each example is a complete vertical slice. Framework and serialization dependencies shown in infrastructure are conditional on the corresponding project manifest.

### Spring Boot Example

```java
// src/main/java/com/example/tasks/domain/Task.java
// === DOMAIN LAYER ===
package com.example.tasks.domain;

import java.util.Objects;
import java.util.UUID;

public final class Task {
    private final UUID id;
    private final String title;

    private Task(UUID id, String title) {
        this.id = id;
        this.title = title;
    }

    public static Task create(UUID id, String title) {
        UUID requiredId = Objects.requireNonNull(id, "id");
        String normalizedTitle = normalizeTitle(title);
        if (normalizedTitle.isEmpty()) {
            throw new DomainException("INVALID_TASK_TITLE", "Task title must not be blank");
        }
        return new Task(requiredId, normalizedTitle);
    }

    private static String normalizeTitle(String title) {
        return Objects.requireNonNull(title, "title").strip();
    }

    public UUID id() {
        return id;
    }

    public String title() {
        return title;
    }
}
```

```java
// src/main/java/com/example/tasks/domain/DomainException.java
// === DOMAIN LAYER ===
package com.example.tasks.domain;

import java.util.Objects;

public final class DomainException extends RuntimeException {
    private final String code;

    public DomainException(String code, String message) {
        super(Objects.requireNonNull(message, "message"));
        this.code = Objects.requireNonNull(code, "code");
    }

    public String code() {
        return code;
    }
}
```

```java
// src/main/java/com/example/tasks/domain/TaskRepository.java
// === DOMAIN LAYER ===
package com.example.tasks.domain;

public interface TaskRepository {
    Task save(Task task);
}
```

```java
// src/main/java/com/example/tasks/domain/CreateTask.java
// === DOMAIN LAYER ===
package com.example.tasks.domain;

import java.util.Objects;
import java.util.UUID;

public final class CreateTask {
    private final TaskRepository taskRepository;

    public CreateTask(TaskRepository taskRepository) {
        this.taskRepository = Objects.requireNonNull(taskRepository, "taskRepository");
    }

    public Task execute(UUID taskId, String title) {
        Task task = Task.create(taskId, title);
        return taskRepository.save(task);
    }
}
```

```java
// src/main/java/com/example/tasks/infrastructure/InMemoryTaskRepository.java
// === INFRASTRUCTURE LAYER ===
package com.example.tasks.infrastructure;

import com.example.tasks.domain.Task;
import com.example.tasks.domain.TaskRepository;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import org.springframework.stereotype.Repository;

@Repository
public final class InMemoryTaskRepository implements TaskRepository {
    private final ConcurrentMap<UUID, Task> tasks = new ConcurrentHashMap<>();

    @Override
    public Task save(Task task) {
        tasks.put(task.id(), task);
        return task;
    }
}
```

```java
// src/main/java/com/example/tasks/infrastructure/TaskProperties.java
// === INFRASTRUCTURE LAYER ===
package com.example.tasks.infrastructure;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "tasks")
public record TaskProperties(String defaultTitle) {
    public TaskProperties {
        defaultTitle = defaultTitle == null || defaultTitle.isBlank()
                ? "Untitled task"
                : defaultTitle.strip();
    }
}
```

```java
// src/main/java/com/example/tasks/infrastructure/TaskConfiguration.java
// === INFRASTRUCTURE LAYER ===
package com.example.tasks.infrastructure;

import com.example.tasks.domain.CreateTask;
import com.example.tasks.domain.TaskRepository;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties(TaskProperties.class)
public class TaskConfiguration {
    @Bean
    CreateTask createTask(TaskRepository taskRepository) {
        return new CreateTask(taskRepository);
    }
}
```

```java
// src/main/java/com/example/tasks/infrastructure/CreateTaskRequest.java
// === INFRASTRUCTURE LAYER ===
package com.example.tasks.infrastructure;

public record CreateTaskRequest(String title) {
}
```

```java
// src/main/java/com/example/tasks/infrastructure/TaskResponse.java
// === INFRASTRUCTURE LAYER ===
package com.example.tasks.infrastructure;

import com.example.tasks.domain.Task;
import java.util.UUID;

public record TaskResponse(UUID id, String title) {
    static TaskResponse from(Task task) {
        return new TaskResponse(task.id(), task.title());
    }
}
```

```java
// src/main/java/com/example/tasks/infrastructure/TaskController.java
// === INFRASTRUCTURE LAYER ===
package com.example.tasks.infrastructure;

import com.example.tasks.domain.CreateTask;
import com.example.tasks.domain.Task;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/tasks")
public final class TaskController {
    private final CreateTask createTask;
    private final TaskProperties taskProperties;

    public TaskController(CreateTask createTask, TaskProperties taskProperties) {
        this.createTask = createTask;
        this.taskProperties = taskProperties;
    }

    @PostMapping
    public ResponseEntity<TaskResponse> create(@RequestBody CreateTaskRequest request) {
        String requestedTitle = request.title();
        String title = requestedTitle == null || requestedTitle.isBlank()
                ? taskProperties.defaultTitle()
                : requestedTitle;
        Task task = createTask.execute(UUID.randomUUID(), title);
        return ResponseEntity.status(HttpStatus.CREATED).body(TaskResponse.from(task));
    }
}
```

```java
// src/main/java/com/example/tasks/infrastructure/ErrorResponse.java
// === INFRASTRUCTURE LAYER ===
package com.example.tasks.infrastructure;

public record ErrorResponse(String code, String message) {
}
```

```java
// src/main/java/com/example/tasks/infrastructure/TaskErrorAdvice.java
// === INFRASTRUCTURE LAYER ===
package com.example.tasks.infrastructure;

import com.example.tasks.domain.DomainException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public final class TaskErrorAdvice {
    @ExceptionHandler(DomainException.class)
    public ResponseEntity<ErrorResponse> handleDomainError(DomainException error) {
        ErrorResponse response = new ErrorResponse(error.code(), error.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }
}
```

`[CHECK] Spring flow: request -> controller -> plain use case -> domain entity -> repository port -> Spring adapter; domain imports only `java.*`; type-safe configuration, constructor injection, and REST error advice stay in infrastructure.`

### Quarkus Example

```java
// src/main/java/com/example/greetings/domain/Greeting.java
// === DOMAIN LAYER ===
package com.example.greetings.domain;

import java.util.Objects;
import java.util.UUID;

public final class Greeting {
    private final UUID id;
    private final String message;

    private Greeting(UUID id, String message) {
        this.id = id;
        this.message = message;
    }

    public static Greeting create(UUID id, String message) {
        UUID requiredId = Objects.requireNonNull(id, "id");
        String normalizedMessage = normalizeMessage(message);
        if (normalizedMessage.isEmpty()) {
            throw new DomainException("INVALID_GREETING", "Greeting message must not be blank");
        }
        return new Greeting(requiredId, normalizedMessage);
    }

    private static String normalizeMessage(String message) {
        return Objects.requireNonNull(message, "message").strip();
    }

    public UUID id() {
        return id;
    }

    public String message() {
        return message;
    }
}
```

```java
// src/main/java/com/example/greetings/domain/DomainException.java
// === DOMAIN LAYER ===
package com.example.greetings.domain;

import java.util.Objects;

public final class DomainException extends RuntimeException {
    private final String code;

    public DomainException(String code, String message) {
        super(Objects.requireNonNull(message, "message"));
        this.code = Objects.requireNonNull(code, "code");
    }

    public String code() {
        return code;
    }
}
```

```java
// src/main/java/com/example/greetings/domain/GreetingStore.java
// === DOMAIN LAYER ===
package com.example.greetings.domain;

public interface GreetingStore {
    Greeting save(Greeting greeting);
}
```

```java
// src/main/java/com/example/greetings/domain/CreateGreeting.java
// === DOMAIN LAYER ===
package com.example.greetings.domain;

import java.util.Objects;
import java.util.UUID;

public final class CreateGreeting {
    private final GreetingStore greetingStore;

    public CreateGreeting(GreetingStore greetingStore) {
        this.greetingStore = Objects.requireNonNull(greetingStore, "greetingStore");
    }

    public Greeting execute(UUID greetingId, String message) {
        Greeting greeting = Greeting.create(greetingId, message);
        return greetingStore.save(greeting);
    }
}
```

```java
// src/main/java/com/example/greetings/infrastructure/InMemoryGreetingStore.java
// === INFRASTRUCTURE LAYER ===
package com.example.greetings.infrastructure;

import com.example.greetings.domain.Greeting;
import com.example.greetings.domain.GreetingStore;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

@ApplicationScoped
public final class InMemoryGreetingStore implements GreetingStore {
    private final ConcurrentMap<UUID, Greeting> greetings = new ConcurrentHashMap<>();

    @Override
    public Greeting save(Greeting greeting) {
        greetings.put(greeting.id(), greeting);
        return greeting;
    }
}
```

```java
// src/main/java/com/example/greetings/infrastructure/GreetingConfig.java
// === INFRASTRUCTURE LAYER ===
package com.example.greetings.infrastructure;

import io.smallrye.config.ConfigMapping;
import io.smallrye.config.WithDefault;

@ConfigMapping(prefix = "greetings")
public interface GreetingConfig {
    @WithDefault("Hello")
    String defaultMessage();
}
```

```java
// src/main/java/com/example/greetings/infrastructure/GreetingWiring.java
// === INFRASTRUCTURE LAYER ===
package com.example.greetings.infrastructure;

import com.example.greetings.domain.CreateGreeting;
import com.example.greetings.domain.GreetingStore;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.inject.Produces;

@ApplicationScoped
public final class GreetingWiring {
    @Produces
    @ApplicationScoped
    CreateGreeting createGreeting(GreetingStore greetingStore) {
        return new CreateGreeting(greetingStore);
    }
}
```

```java
// src/main/java/com/example/greetings/infrastructure/CreateGreetingRequest.java
// === INFRASTRUCTURE LAYER ===
package com.example.greetings.infrastructure;

public record CreateGreetingRequest(String message) {
}
```

```java
// src/main/java/com/example/greetings/infrastructure/GreetingResponse.java
// === INFRASTRUCTURE LAYER ===
package com.example.greetings.infrastructure;

import com.example.greetings.domain.Greeting;
import java.util.UUID;

public record GreetingResponse(UUID id, String message) {
    static GreetingResponse from(Greeting greeting) {
        return new GreetingResponse(greeting.id(), greeting.message());
    }
}
```

```java
// src/main/java/com/example/greetings/infrastructure/GreetingResource.java
// === INFRASTRUCTURE LAYER ===
package com.example.greetings.infrastructure;

import com.example.greetings.domain.CreateGreeting;
import com.example.greetings.domain.Greeting;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.net.URI;
import java.util.UUID;

@Path("/greetings")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public final class GreetingResource {
    private final CreateGreeting createGreeting;
    private final GreetingConfig greetingConfig;

    @Inject
    public GreetingResource(CreateGreeting createGreeting, GreetingConfig greetingConfig) {
        this.createGreeting = createGreeting;
        this.greetingConfig = greetingConfig;
    }

    @POST
    public Response create(CreateGreetingRequest request) {
        String requestedMessage = request.message();
        String message = requestedMessage == null || requestedMessage.isBlank()
                ? greetingConfig.defaultMessage()
                : requestedMessage;
        Greeting greeting = createGreeting.execute(UUID.randomUUID(), message);
        URI location = URI.create("/greetings/" + greeting.id());
        return Response.created(location).entity(GreetingResponse.from(greeting)).build();
    }
}
```

```java
// src/main/java/com/example/greetings/infrastructure/ErrorResponse.java
// === INFRASTRUCTURE LAYER ===
package com.example.greetings.infrastructure;

public record ErrorResponse(String code, String message) {
}
```

```java
// src/main/java/com/example/greetings/infrastructure/DomainExceptionMapper.java
// === INFRASTRUCTURE LAYER ===
package com.example.greetings.infrastructure;

import com.example.greetings.domain.DomainException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

@Provider
public final class DomainExceptionMapper implements ExceptionMapper<DomainException> {
    @Override
    public Response toResponse(DomainException error) {
        ErrorResponse response = new ErrorResponse(error.code(), error.getMessage());
        return Response.status(Response.Status.BAD_REQUEST).entity(response).build();
    }
}
```

`[CHECK] Quarkus flow: request -> resource -> CDI-produced plain use case -> domain entity -> store port -> Quarkus adapter; domain imports only `java.*`; config mapping, constructor injection, producer wiring, and `ExceptionMapper` stay in infrastructure.`

### Value Object with Invariant Example

```java
// src/main/java/com/example/auth/domain/Password.java
// === DOMAIN LAYER ===
package com.example.auth.domain;

public record Password(String hash) {
    private static final int MIN_LENGTH = 8;

    public Password {
        if (hash == null || hash.isBlank()) {
            throw new DomainException("INVALID_PASSWORD", "Password hash must not be blank");
        }
    }

    public static void validateRaw(String raw) {
        if (raw == null || raw.length() < MIN_LENGTH) {
            throw new DomainException("WEAK_PASSWORD",
                "Password must be at least " + MIN_LENGTH + " characters");
        }
        if (!raw.matches(".*[A-Z].*")) {
            throw new DomainException("WEAK_PASSWORD",
                "Password must contain an uppercase letter");
        }
        if (!raw.matches(".*[a-z].*")) {
            throw new DomainException("WEAK_PASSWORD",
                "Password must contain a lowercase letter");
        }
        if (!raw.matches(".*\d.*")) {
            throw new DomainException("WEAK_PASSWORD",
                "Password must contain a digit");
        }
    }

    public boolean isValid() {
        return hash != null && !hash.isBlank();
    }
}
```

### Port for External Capability Example

```java
// src/main/java/com/example/auth/domain/PasswordHasher.java
// === DOMAIN LAYER ===
package com.example.auth.domain;

public interface PasswordHasher {
    Password hash(String rawPassword);
    boolean verify(String rawPassword, Password stored);
}
```

```java
// src/main/java/com/example/auth/infrastructure/BcryptPasswordHasher.java
// === INFRASTRUCTURE LAYER ===
package com.example.auth.infrastructure;

import com.example.auth.domain.Password;
import com.example.auth.domain.PasswordHasher;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public final class BcryptPasswordHasher implements PasswordHasher {
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    @Override
    public Password hash(String rawPassword) {
        return new Password(encoder.encode(rawPassword));
    }

    @Override
    public boolean verify(String rawPassword, Password stored) {
        return encoder.matches(rawPassword, stored.hash());
    }
}
```

### Use Case with Value Object and Port Example

```java
// src/main/java/com/example/auth/domain/RegisterUser.java
// === DOMAIN LAYER ===
package com.example.auth.domain;

import java.util.Objects;
import java.util.UUID;

public final class RegisterUser {
    private final UserRepository userRepository;
    private final PasswordHasher passwordHasher;

    public RegisterUser(UserRepository userRepository, PasswordHasher passwordHasher) {
        this.userRepository = Objects.requireNonNull(userRepository, "userRepository");
        this.passwordHasher = Objects.requireNonNull(passwordHasher, "passwordHasher");
    }

    public User execute(UUID id, Email email, String rawPassword) {
        Password.validateRaw(rawPassword);

        if (userRepository.existsByEmail(email)) {
            throw new DomainException("EMAIL_EXISTS", "Email already registered: " + email.value());
        }

        Password password = passwordHasher.hash(rawPassword);
        User user = User.register(id, email, password);
        return userRepository.save(user);
    }
}
```