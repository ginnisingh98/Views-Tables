--------------------------------------------------------
--  DDL for Package Body CST_LANDEDCOSTHOOK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_LANDEDCOSTHOOK_PUB" AS
/* $Header: CSTPLHKB.pls 120.1 2005/08/17 16:50:35 nnayak noship $ */

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
return integer  IS
BEGIN
  o_err_num := 0;
  o_err_code := '';
  o_err_msg := '';

  return 0;

EXCEPTION

  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CST_LandedCostHook_PUB.landed_cost_hook:' || substrb(SQLERRM,1,150);
    return 0;

END landed_cost_hook;

END CST_LandedCostHook_PUB;

/
