--------------------------------------------------------
--  DDL for Package JTF_HA_STATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_HA_STATE_PKG" AUTHID CURRENT_USER as
/* $Header: JTFHASS.pls 120.2 2005/11/15 00:49:01 psanyal ship $ */

-- *****************************************************************************


-- Start of Comments
--
--      API name        : GET_CURRENT_STATE
--      Type            : Public
--      Function        : Get the current HA system state
--
--      Parameters      :
--      OUT     :
--              X_CURRENT_STATE         OUT NUMBER
--              X_RETURN_STATUS         OUT VARCHAR2
--
--      Version :Current version        1.0
--               Initial version        1.0
--
--	NOTES:
--	X_RETURN_STATUS holds the status of the procedure call, its value is
--        FND_API.G_RET_STS_SUCCESS when the API completes successfully,
--		in this case, X_CURRENT_STATE holds the current HA state
--        FND_API.G_RET_STS_UNEXP_ERROR when the API reaches an unexpected
--		state, in which case X_CURRENT_STATE is undefined.
--        FND_API.G_RET_STS_ERROR when the API hits an error, in which case
--		X_CURRENT_STATE is undefined.
--	X_CURRENT_STATE	holds the state index value:
--		0	FULL OPERATION
--		1	WARNING
--		2	TRANSITION TO MAINTENANCE
--		3	MAINTENANCE
--		4	TRANSITION TO FULL OPERATION
--		5	FUZZY LIVE
--
-- *****************************************************************************

procedure GET_CURRENT_STATE (
  X_CURRENT_STATE out NOCOPY NUMBER,
  X_RETURN_STATUS out NOCOPY VARCHAR2
);

-- Start of Comments
--
--      API name        : SET_CURRENT_STATE
--      Type            : Public
--      Function        : Set the current HA system state
--
--      Parameters      :
--      IN        P_CURRENT_STATE         IN NUMBER
--      OUT       X_RETURN_STATUS         OUT VARCHAR2
--
--      Version :Current version        1.0
--               Initial version        1.0
--
--	NOTES:
--	X_RETURN_STATUS holds the status of the procedure call, its value is
--        FND_API.G_RET_STS_SUCCESS when the API completes successfully
--        FND_API.G_RET_STS_UNEXP_ERROR when the API reaches an unexpected
--		state
--        FND_API.G_RET_STS_ERROR when the API hits an error
--	P_CURRENT_STATE	the state to be set:
--		0	FULL OPERATION
--		1	WARNING
--		2	TRANSITION TO MAINTENANCE
--		3	MAINTENANCE
--		4	TRANSITION TO FULL OPERATION
--		5	FUZZY LIVE
--
-- *****************************************************************************

procedure SET_CURRENT_STATE (
  P_CURRENT_STATE in NUMBER,
  X_RETURN_STATUS out NOCOPY VARCHAR2
);

end JTF_HA_STATE_PKG;

 

/
