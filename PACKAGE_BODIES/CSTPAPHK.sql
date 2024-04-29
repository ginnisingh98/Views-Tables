--------------------------------------------------------
--  DDL for Package Body CSTPAPHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPAPHK" AS
/* $Header: CSTAPHKB.pls 115.3 2002/11/08 02:34:46 awwang ship $ */


-- FUNCTION
--  get_account_id		Cover routine to allow users the flexbility
--				in determining the account they want to
--				post the inventory transaction to.
--
--
-- RETURN VALUES
--  integer		>0	User selected account number
--			-1  	Use the default account for distribution.
--
function get_account_id(
  I_TXN_ID		IN 	NUMBER,
  I_LEGAL_ENTITY	IN	NUMBER,
  I_COST_TYPE_ID	IN	NUMBER,
  I_COST_GROUP_ID	IN	NUMBER,
  I_DR_FLAG		IN	BOOLEAN,
  I_ACCT_LINE_TYPE	IN	NUMBER,
  I_COST_ELEMENT_ID	IN	NUMBER,
  I_RESOURCE_ID		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_EXP			IN	BOOLEAN,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
)
return integer  IS
BEGIN
  o_err_num := 0;
  o_err_code := '';
  o_err_msg := '';

  return -1;

EXCEPTION

  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPAPHK.GET_ACCOUNT_ID:' || substrb(SQLERRM,1,150);
    return -1;

END get_account_id;

END CSTPAPHK;


/
