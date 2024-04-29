--------------------------------------------------------
--  DDL for Package CSTPAPHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPAPHK" AUTHID CURRENT_USER AS
/* $Header: CSTAPHKS.pls 115.3 2002/11/08 02:35:01 awwang ship $ */


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
return integer ;

END CSTPAPHK;


 

/
