local CollectionClaimRules = require("../src/shared/rules/CollectionClaimRules")

return function()
	local state = CollectionClaimRules.newState()
	assert(state.Active and state.Revision == 0, "fresh claim state")

	local winners = 0
	local winningRevision = 0
	for _ = 1, 100 do
		local claimed, revision = CollectionClaimRules.tryClaim(state)
		if claimed then
			winners += 1
			winningRevision = revision
		end
	end

	assert(winners == 1, "exactly one claimant may win")
	assert(winningRevision == 1 and state.Revision == 1, "first claim revision")
	assert(not state.Active, "claimed state inactive")

	local replayClaimed = CollectionClaimRules.tryClaim(state)
	assert(not replayClaimed, "replay must not double-claim")
	assert(not CollectionClaimRules.reactivate(state, 999), "stale respawn revision rejected")
	assert(CollectionClaimRules.reactivate(state, winningRevision), "winning revision may respawn")
	assert(state.Active, "reactivated state")

	local nextClaimed, nextRevision = CollectionClaimRules.tryClaim(state)
	assert(nextClaimed and nextRevision == 2, "next lifecycle receives new revision")
	assert(not CollectionClaimRules.reactivate(state, winningRevision), "old lifecycle cannot reactivate newer claim")
end
