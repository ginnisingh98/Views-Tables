--------------------------------------------------------
--  DDL for Package CSTPPCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPCHK" AUTHID CURRENT_USER AS
/* $Header: CSTPCHKS.pls 115.6 2002/11/09 00:27:44 awwang ship $*/

/*---------------------------------------------------------------------------*
|  FUNCTION							             |
|  actual_cost_hook							     |
|									     |
|  RETURN VALUES   							     |
|  integer             1       Hook has been used.			     |
|                      -1       Continue cost processing for this transaction |
|                              as usual.				     |
|									     |
*----------------------------------------------------------------------------*/
function actual_cost_hook(
  i_pac_period_id      	IN      NUMBER,
  i_cost_group_id      	IN      NUMBER,
  i_cost_type_id    	IN      NUMBER,
  i_cost_method   	IN      NUMBER,
  i_txn_id 		IN      NUMBER,
  i_cost_layer_id 	IN      NUMBER,
  i_qty_layer_id 	IN      NUMBER,
  i_pac_rates_id 	IN      NUMBER,
  I_USER_ID     	IN      NUMBER,
  I_LOGIN_ID    	IN      NUMBER,
  I_REQ_ID      	IN      NUMBER,
  I_PRG_APPL_ID 	IN      NUMBER,
  I_PRG_ID      	IN      NUMBER,
  O_Err_Num     	OUT NOCOPY     NUMBER,
  O_Err_Code    	OUT NOCOPY     VARCHAR2,
  O_Err_Msg     	OUT NOCOPY     VARCHAR2
)
return integer;


/*---------------------------------------------------------------------------*
|  FUNCTION							             |
|  beginning_balance_hook						     |
|									     |
|  RETURN VALUES   							     |
|  integer             1       Hook has been used.			     |
|                      -1       Continue cost processing for this transaction |
|                              as usual.				     |
|									     |
*----------------------------------------------------------------------------*/
function beginning_balance_hook(
  i_pac_period_id		IN      NUMBER,
  i_prior_pac_period_id		IN      NUMBER,
  i_legal_entity		IN      NUMBER,
  i_cost_type_id   		IN      NUMBER,
  i_cost_group_id		IN      NUMBER,
  i_cost_method  		IN      NUMBER,
  i_user_id			IN      NUMBER,
  i_login_id			IN      NUMBER,
  i_request_id			IN      NUMBER,
  i_prog_id			IN      NUMBER,
  i_prog_app_id			IN      NUMBER,
  o_err_num			OUT NOCOPY     NUMBER,
  o_err_code			OUT NOCOPY     VARCHAR2,
  o_err_msg			OUT NOCOPY     VARCHAR2
)
return integer;

END CSTPPCHK;

 

/
