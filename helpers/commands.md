# Commands and Helpers

**CAUTION** - in examples by tilde (`~`) we mean a directory where you cloned the repository.

## Invoking tests

```bash
~ $ mix test
```

## Getting familiar with the application

```bash
~ $ mix deps.tree
~ $ mix app.tree --exclude elixir --exclude logger

~ $ cd apps/kv_rest_api
apps/kv_rest_api $ mix phx.routes
```

## Building release

```bash
~ $ MIX_ENV=prod mix release
```

How to start release? Watch the guides after successful release build process.

If you want to clean persisted state, please invoke:

```bash
rm -rf _build/prod/rel/production_debugging_workshop_ex/persistence.db
```

## Development mode

```bash
~ $ iex -S mix phx.server
~ $ iex --name "server@127.0.0.1" --cookie "dev" -S mix phx.server
```

## Second node with `:observer`

```bash
~ $ iex --name "observer@127.0.0.1" --cookie "dev"
iex(1)> Node.connect(:'server@127.0.0.1')
iex(2)> Node.list()
iex(3)> :observer.start()
```

## Remote shell to the existing node

```bash
~ $ iex --name "remshy@127.0.0.1" --cookie "dev" --remsh "server@127.0.0.1"
~ $ iex --name "remshy@127.0.0.1" --cookie "dev" --remsh "production_debugging_workshop_ex@127.0.0.1"
```

## `:etop`

```elixir
iex(1)> :etop.start()
iex(2)> :etop.start(interval: 1, sort: :reductions)         # Available columns for sorting: `msg_q`, `reductions`, `memory`, `runtime`
iex(3)> :etop.stop()
```

## `:xprof`

### Starting application

```elixir
iex(1)> :xprof.start()
```

And then go to the `http://localhost:7890` (we recommend using an *incognito tab* to avoid issues with browser extensions). It will detect automatically if you are using *Elixir* or *Erlang* project and adjust syntax to it accordingly.

## `:eper`

### Facilities different than `:redbug`

- `eper` is a loose collection of Erlang Performance related tools.
  - We talked a lot about `redbug` already which is a part of that toolkit.
  - But there are other interesting tools:
    - `dtop` - Similar to UNIX `top`.
      - `:dtop.start()`
    - `ntop` - Visualizes network traffic.
      - `:ntop.start()` - and it shows ports, then you can work with e.g. `recon`.
    - `atop` - Shows various aspects of the VM allocators.
      - `:atop.help()` - and then go along the guides.

### `:redbug`

```elixir
iex(1)> :redbug.start(~C['Elixir.KV.Bucket':keys->return], print_msec: true)
iex(2)> :redbug.start(~C['Elixir.Plug.Conn':read_body->return], time: 1_000, msgs: 2)
iex(3)> :redbug.start(1000, 2, ~C['Elixir.Plug.Conn':read_body->return])
iex(4)> :redbug.start(~C[erlang:binary_to_atom->stack])
```

## `:dbg`

```elixir
iex(1)> :dbg.tracer()
iex(2)> :dbg.p(:all, :c)                      # Trace calls in all processes.
iex(3)> :dbg.p(:new, :p)                      # Trace process events only in newly spawned processes.
iex(4)> :dbg.p(:all, :m)                      # Trace all messages (incoming / outgoing) in all processes.
iex(5)> :dbg.tp(:'Elixir.Enum', :into, :x)    # Trace pattern for all arities of `Enum.into` that will show *exception trace* (function, arguments, return value and exceptions for a function).
iex(5)> :dbg.tp(:'Elixir.Enum', :into, :c)    # Trace pattern for all arities of `Enum.into` that will show *caller trace* (as above but about function that called it).
iex(5)> :dbg.tp(:'Elixir.Enum', :into, :cx)   # Trace pattern for all arities of `Enum.into` that will show data from both type of *traces*.
iex(6)> :dbg.stop()                           # Stops tracer.
iex(6)> :dbg.stop_clear()                     # Stops tracer and clears trace patterns.
```

## `:recon`

### Crash Dump Analysis

```bash
~ $ ./deps/recon/scripts/erl_crashdump_analyzer.sh erl_crash.dump
~ $ awk -v threshold=10000 -f ./deps/recon/scripts/queue_fun.awk erl_crash.dump
```

### Observability

- `:recon.scheduler_usage(1000)`
    - Polls schedulers for 1s and shows utilization in percentages.
- `:recon.port_types()`
    - Lists a summary which ports are opened in the system.
- `:recon.info(self(), work)`
    - Showing info about particular process depending on available groups (also `recon` gathers and returns only those safe metrics).
- `:recon.proc_count(memory, 3)`
    - Top 3 processes when it comes to memory.
- `:recon.bin_leak(5)`
    - Take 5 processes which released the most amount of memory after forced GC in comparison to before.
        - It is related with the mechanism of *reference counted* binaries, *Erlang* will not release those without forcing it.

### `:recon_trace`

```elixir
iex(1)> :recon_trace.calls({:erlang, :binary_to_integer, 1}, 2)            # At most 2 messages.
iex(2)> :recon_trace.calls({:queue, :in, fn(_) -> :return_trace end}, 3)
iex(3)> :recon_trace.calls({:queue, :new, :_}, 1)
iex(5)> :recon_trace.calls({KV.Registry, :handle_call, 3}, {10, 1000})     # Stop tracing if you will get more than 10 messages in 1s.
iex(6)> :recon_trace.clear()
```

## `:sys`

### `:sys.trace`

```elixir
iex(1)> :sys.trace(Process.whereis(KV.GarbageCollector), true)
iex(2)> :sys.trace(Process.whereis(KV.Registry), true)
iex(3)> :sys.trace(pid, true)
```

### Other facilities from `:sys:

- `:sys.get_state(pid_or_name)`
- `:sys.get_status(pid_or_name)`
- `:sys.get_status(pid_or_name, [ false | true | :get ])` - when flag is `:get` it will return the following statistics:
    - `{:start_time, date_time1}`
    - `{:current_time, date_time2}`
    - `{:reductions, integer() >= 0}`
    - `{:messages_in, integer() >= 0}`
    - `{:messages_out, integer() >= 0}`
- `:sys.replace_state(pid_or_name, fn(state) -> ... new_state end)`

## System Monitors

- Amazing facility for tracking down various strange situation with probes
  available on virtual machine, e.g. long schedule pauses or long GC operations.
  ```elixir
  iex(1)> :erlang.system_monitor()
  iex(2)> :erlang.system_monitor(self(), [ {:long_gc, 500} ])
  iex(3)> flush()
      Shell got {monitor,<4683.31798.0>,long_gc,
                 [{timeout,515},
                  {old_heap_block_size,0},
                  {heap_block_size,75113},
                  {mbuf_size,0},
                  {stack_size,19},
                  {old_heap_size,0},
                  {heap_size,33878}]}
  iex(4)> :erlang.system_monitor(:undefined)
  {<0.26706.4961>,[{long_gc,500}]
  iex(5)> :erlang.system_monitor()
  undefined
  ```
  - Other options:
    - `{large_heap, NumWords}`
    - `{long_schedule, Ms}`.
  - Being able to create whole module in _REPL_ is the best possible thing.
    ```elixir
    defmodule TempSysMon do
      defp printer(op) do
        receive do
          {:monitor, pid, type, info} ->
            IO.puts("---")
            IO.puts("monitor=#{type} pid=#{inspect pid} info=#{inspect info}")

            case op do
              nil -> :ok
              _   ->
                result = op.(pid, type, info)
                IO.puts("op=#{inspect result}")
            end
        end
        printer(op)
      end

      def start(monitors, op \\ nil)

      def start(monitor, op) when is_tuple(monitor) do
        start([monitor], op)
      end

      def start(monitors, op) do
        spawn_link(fn () ->
          Process.register(self(), :temp_sys_monitor)
          :erlang.system_monitor(self(), monitors)
          printer(op)
        end)
      end

      def stop() do
        temp_sys_monitor = Process.whereis(:temp_sys_monitor)

        case temp_sys_monitor do
          nil -> :no_temp_sys_monitor
          _   ->
            Process.exit(temp_sys_monitor, :kill)
            :killed
        end
      end
    end
    ```

## Core Dumps

### Enabling / disabling core dumps

```bash
# Enable.
~ $ ulimit -c unlimited

# Create in current directory with proper format.
~ $ sudo bash -c "echo "core.%e.%p" > /proc/sys/kernel/core_pattern"

# Disable.
~ $ ulimit -c 0
```

### `gdb` Cheatsheet

- `bt` - Get stack trace from current thread.
- `frame N` - Move to `N` frame.
- `i thr` - List all threads.
- `thr N` - Move to `N` thread.
- `print VAR` - Print variable `VAR`.
- `print p->off_heap` - Print off-heap pointer for *Erlang* *Process* pointer `p`.
- `etp-offheapdump PTR` - Memory dump regarding off-heap data for that *Process* `PTR`.
- `etp-process-info p` - If you have *Erlang VM* *Process* pointer called `p` you can get details from it.
- `etp VAR` or `etpf VAR` - Printing *Erlang* terms stored in `VAR`.
- `etp-stacktrace p` - Print *Erlang* stack-trace from `p`.
- `etp-stackdump p` - Print *Erlang* stack and memory for process `p`.
- `etp-help` - For more help than usual.