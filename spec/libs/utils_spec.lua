describe("Math Extensions", function()

  before_each(function()
    -- Reset random seed for predictable tests
    math.randomseed(12345)
  end)

  describe("math.isANumber", function()
    it("should return true for valid numbers", function()
      assert.is_true(math.isANumber(42))
      assert.is_true(math.isANumber(0))
      assert.is_true(math.isANumber(-3.14))
    end)

    it("should return false for NaN", function()
      local nan = 0/0
      assert.is_false(math.isANumber(nan))
    end)

    it("should return false for infinity", function()
      local inf = math.huge
      assert.is_false(math.isANumber(inf))
    end)
  end)

  describe("math.sign", function()
    it("should return 1 for positive numbers", function()
      assert.equals(1, math.sign(42))
      assert.equals(1, math.sign(0.1))
    end)

    it("should return -1 for negative numbers", function()
      assert.equals(-1, math.sign(-42))
      assert.equals(-1, math.sign(-0.1))
    end)

    it("should return 0 for zero", function()
      assert.equals(0, math.sign(0))
    end)
  end)

  describe("math.hypotenuse", function()
    it("should calculate 2D distance correctly", function()
      assert.equals(5, math.hypotenuse(3, 4))
      assert.equals(13, math.hypotenuse(5, 12))
    end)

    it("should calculate 3D distance correctly", function()
      local result = math.hypotenuse(1, 2, 2)
      assert.is_near(3, result, 0.01)
    end)

    it("should handle zero values", function()
      assert.equals(0, math.hypotenuse(0, 0))
      assert.equals(5, math.hypotenuse(5, 0))
    end)
  end)

  describe("math.legs", function()
    it("should calculate x and y components from angle and hypotenuse", function()
      local x, y = math.legs(0, 10)
      assert.is_near(10, x, 0.01)
      assert.is_near(0, y, 0.01)

      local x2, y2 = math.legs(90, 10)
      assert.is_near(0, x2, 0.01)
      assert.is_near(10, y2, 0.01)
    end)
  end)
end)

describe("String Extensions", function()

  describe("string:capitalize", function()
    it("should capitalize first letter", function()
      assert.equals("Hello", string.capitalize("hello"))
      assert.equals("World", string.capitalize("world"))
    end)

    it("should handle already capitalized strings", function()
      assert.equals("Hello", string.capitalize("Hello"))
    end)

    it("should handle empty strings", function()
      assert.equals("", string.capitalize(""))
    end)
  end)

  describe("string:split", function()
    it("should split by default separator ':'", function()
      local result = string.split("a:b:c")
      assert.equals(3, #result)
      assert.equals("a", result[1])
      assert.equals("b", result[2])
      assert.equals("c", result[3])
    end)

    it("should split by custom separator", function()
      local result = string.split("a,b,c", ",")
      assert.equals(3, #result)
      assert.equals("a", result[1])
      assert.equals("b", result[2])
      assert.equals("c", result[3])
    end)

    it("should handle single element", function()
      local result = string.split("hello", ",")
      assert.equals(1, #result)
      assert.equals("hello", result[1])
    end)
  end)
end)

describe("Table Utilities", function()

  describe("shuffle", function()
    it("should maintain table length", function()
      local t = {1, 2, 3, 4, 5}
      shuffle(t)
      assert.equals(5, #t)
    end)

    it("should contain all original elements", function()
      local t = {1, 2, 3, 4, 5}
      shuffle(t)
      table.sort(t)
      assert.same({1, 2, 3, 4, 5}, t)
    end)
  end)

  describe("table.bininsert", function()
    it("should insert into sorted array maintaining order", function()
      local t = {1, 3, 5, 7, 9}
      table.bininsert(t, 4)
      assert.same({1, 3, 4, 5, 7, 9}, t)
    end)

    it("should insert at beginning", function()
      local t = {2, 4, 6}
      table.bininsert(t, 1)
      assert.same({1, 2, 4, 6}, t)
    end)

    it("should insert at end", function()
      local t = {1, 3, 5}
      table.bininsert(t, 10)
      assert.same({1, 3, 5, 10}, t)
    end)

    it("should handle empty table", function()
      local t = {}
      table.bininsert(t, 5)
      assert.same({5}, t)
    end)
  end)
end)

describe("equals", function()

  it("should compare primitives correctly", function()
    assert.is_true(equals(5, 5))
    assert.is_true(equals("hello", "hello"))
    assert.is_false(equals(5, 6))
    assert.is_false(equals("hello", "world"))
  end)

  it("should compare simple tables", function()
    assert.is_true(equals({1, 2, 3}, {1, 2, 3}))
    assert.is_false(equals({1, 2, 3}, {1, 2, 4}))
  end)

  it("should compare nested tables", function()
    local t1 = {a = {b = {c = 1}}}
    local t2 = {a = {b = {c = 1}}}
    local t3 = {a = {b = {c = 2}}}
    assert.is_true(equals(t1, t2))
    assert.is_false(equals(t1, t3))
  end)

  it("should handle different types", function()
    assert.is_false(equals(5, "5"))
    assert.is_false(equals({}, "table"))
  end)
end)

describe("Text Formatting", function()

  describe("textFormat.time", function()
    it("should format seconds only", function()
      assert.equals(42, textFormat.time(42))
      assert.equals(1, textFormat.time(1))
    end)

    it("should format minutes and seconds", function()
      assert.equals("1:00", textFormat.time(60))
      assert.equals("1:30", textFormat.time(90))
      assert.equals("2:05", textFormat.time(125))
    end)

    it("should format hours, minutes and seconds", function()
      assert.equals("1:00:00", textFormat.time(3600))
      assert.equals("1:30:45", textFormat.time(5445))
    end)
  end)
end)
