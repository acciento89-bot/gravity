local tests = {
	require("../tests/level-rules.spec"),
	require("../tests/attraction-rules.spec"),
	require("../tests/collection-claim-rules.spec"),
	require("../tests/object-config.spec"),
	require("../tests/orbit-rules.spec"),
	require("../tests/viewport-rules.spec"),
	require("../tests/zone-rules.spec"),
	require("../tests/daily-rules.spec"),
	require("../tests/profile-rules.spec"),
	require("../tests/balance-rules.spec"),
	require("../tests/receipt-rules.spec"),
	require("../tests/readiness-rules.spec"),
}

local passed = 0
for _, test in tests do
	test()
	passed += 1
end

print(("+1 Gravity: %d pure Luau test files passed"):format(passed))
