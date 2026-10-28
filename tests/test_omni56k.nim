import unittest
import omni56k

suite "omni56k":
  test "hello returns expected greeting":
    check hello() == "hello from omni56k"

  test "version present":
    check projectVersion == "0.0.1"
