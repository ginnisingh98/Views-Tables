--------------------------------------------------------
--  DDL for Package CST_LANDEDCOSTHOOK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_LANDEDCOSTHOOK_PUB" AUTHID CURRENT_USER AS
/* $Header: CSTPLHKS.pls 120.1 2005/08/17 16:49:38 nnayak noship $ */

-- FUNCTION
--  landed_cost_hook	Cover routine to get acquisition cost from
--                      Landed Cost Management. This function
--				is called by both CSTPPACQ.
--
--
-- RETURN VALUES
--  integer		1	Hook has been used.
--			0  	Hook has not been used.
--

function landed_cost_hook(
  I_PERIOD_ID		IN	NUMBER,
  I_START_DATE          IN      DATE,
  I_END_DATE            IN      DATE,
  I_COST_TYPE_ID	IN 	NUMBER,
  I_COST_GROUP_ID	IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PROG_ID		IN 	NUMBER,
  I_PROG_APPL_ID	IN	NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
)
return integer;

END CST_LandedCostHook_PUB;

 

/
