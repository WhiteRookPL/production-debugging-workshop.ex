defmodule KV.ServerTest do
  use ExUnit.Case

  setup do
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 4040, opts)
    {:ok, socket: socket}
  end

  test "server interaction", %{socket: socket} do
    assert send_and_recv(socket, "UNKNOWN shopping\r\n") == "UNKNOWN COMMAND\r\n"

    assert send_and_recv(socket, "GET shopping eggs\r\n") == "NOT FOUND\r\n"
    assert send_and_recv(socket, "CREATE shopping\r\n") == "OK\r\n"

    assert send_and_recv(socket, "PUT shopping another #{Base.encode64("1")}\r\n") == "OK\r\n"
    assert send_and_recv(socket, "PUT shopping eggs #{Base.encode64("3")}\r\n") == "OK\r\n"

    # GET returns two lines.
    assert send_and_recv(socket, "GET shopping eggs\r\n") == "3\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"

    # KEYS return two lines.
    assert send_and_recv(socket, "KEYS shopping\r\n") == "another,eggs\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"

    assert send_and_recv(socket, "DELETE shopping eggs\r\n") == "OK\r\n"

    # GET returns two lines.
    assert send_and_recv(socket, "GET shopping eggs\r\n") == "\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"

    assert send_and_recv(socket, "DELETE shopping\r\n") == "OK\r\n"
  end

  test "advanced server interaction", %{socket: socket} do
    send_and_recv(socket, "CREATE noop\r\n")
    send_and_recv(socket, "CREATE aggregation\r\n")

    send_and_recv(socket, "PUT aggregation one #{Base.encode64("1")}\r\n")
    send_and_recv(socket, "PUT aggregation two #{Base.encode64("2")}\r\n")
    send_and_recv(socket, "PUT noop three #{Base.encode64("ABC ABC DEF GHI")}\r\n")

    # AVG returns two lines.
    {average, _} = Integer.parse(send_and_recv(socket, "AVG aggregation\r\n"))
    send_and_recv(socket, "")

    # WORDCOUNT returns two lines.
    {word_count, _} = Integer.parse(send_and_recv(socket, "WORDCOUNT noop three\r\n"))
    send_and_recv(socket, "")

    :timer.sleep(100)

    # RESULT returns two lines.
    assert send_and_recv(socket, "RESULT #{average}\r\n") == "1.5\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"

    # RESULT returns two lines.
    assert send_and_recv(socket, "RESULT #{word_count}\r\n") == "ABC:2,DEF:1,GHI:1\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"

    # BUCKETS returns two lines.
    assert send_and_recv(socket, "BUCKETS\r\n") == "aggregation,noop\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"

    assert send_and_recv(socket, "DELETE aggregation\r\n") == "OK\r\n"
    assert send_and_recv(socket, "DELETE noop\r\n") == "OK\r\n"
  end

  defp send_and_recv(socket, command) do
    :ok = :gen_tcp.send(socket, command)
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end
end
