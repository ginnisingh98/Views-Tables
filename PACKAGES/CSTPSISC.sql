--------------------------------------------------------
--  DDL for Package CSTPSISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPSISC" AUTHID CURRENT_USER AS
/* $Header: CSTSISCS.pls 115.4 2002/11/11 22:57:43 awwang ship $ */

-- PROCEDURE
--  ins_std_cost                This function inserts standard cost in mcacd,
--                              transaction cost in mctcd and sub-elemental
--                              costs in macs.
--
-- INPUT PARAMETERS
--  I_ORG_ID
--  I_INV_ITEM_ID
--  I_TXN_ID
--  I_TXN_ACTION_ID
--  I_TXN_SOURCE_TYPE_ID
--  I_EXP_ITEM                 1 is for expense item and 0 is for asset item.
--  I_EXP_SUB		       1 is for expense sub and 0 is for asset sub.
--  I_TXN_COST
--  I_ACTUAL_COST
--  I_PRIOR_COST
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Err_Num
--  O_Err_Code
--  O_Err_Msg
--

procedure ins_std_cost(
  I_ORG_ID		IN	NUMBER,
  I_INV_ITEM_ID         IN      NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_TXN_ACTION_ID       IN      NUMBER,
  I_TXN_SOURCE_TYPE_ID  IN      NUMBER,
  I_EXP_ITEM            IN      NUMBER,
  I_EXP_SUB		IN	NUMBER,
  I_TXN_COST            IN      NUMBER,
  I_ACTUAL_COST		IN	NUMBER,
  I_PRIOR_COST		IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQUEST_ID		IN	NUMBER,
  I_PROG_APPL_ID		IN	NUMBER,
  I_PROG_ID		IN 	NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
);

END CSTPSISC;

 

/
