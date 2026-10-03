--!strict

local CollectionClaimRules = {}

export type ClaimState = {
	Active: boolean,
	Revision: number,
}

function CollectionClaimRules.newState(): ClaimState
	return {
		Active = true,
		Revision = 0,
	}
end

function CollectionClaimRules.tryClaim(state: ClaimState): (boolean, number)
	if state.Active ~= true then
		return false, state.Revision
	end

	state.Active = false
	state.Revision += 1
	return true, state.Revision
end

function CollectionClaimRules.reactivate(state: ClaimState, revision: number): boolean
	if state.Active == true or state.Revision ~= revision then
		return false
	end

	state.Active = true
	return true
end

return table.freeze(CollectionClaimRules)
