defmodule VayneCenterTest do
  use ExUnit.Case
  doctest VayneCenter

  test "greets the world" do
    assert VayneCenter.hello() == :world
  end
end
