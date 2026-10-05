local tests = {
	require("../tests/concept-showcase-ui.spec"),
	require("../tests/concept-fidelity.spec"),
	require("../tests/client-source-safety.spec"),
	require("../tests/visual-polish.spec"),
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
	require("../tests/security-rules.spec"),
	require("../tests/feedback-rules.spec"),
	require("../tests/onboarding-rules.spec"),
	require("../tests/localization-rules.spec"),
	require("../tests/performance-rules.spec"),
	require("../tests/readiness-rules.spec"),
}

local passed = 0
for _, test in tests do
	test()
	passed += 1
end

print(("+1 Gravity: %d pure Luau test files passed"):format(passed))
