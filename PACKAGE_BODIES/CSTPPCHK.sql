--------------------------------------------------------
--  DDL for Package Body CSTPPCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPCHK" AS
/* $Header: CSTPCHKB.pls 115.6 2002/11/09 00:27:26 awwang ship $*/

/*---------------------------------------------------------------------------*
|  FUNCTION							             |
|  actual_cost_hook							     |
|									     |
|  RETURN VALUES   							     |
|  integer             1       Hook has been used.			     |
|                      -1      Continue cost processing for this transaction |
|                              as usual.				     |
|									     |
*----------------------------------------------------------------------------*/
function actual_cost_hook(
  i_pac_period_id       IN      NUMBER,
  i_cost_group_id       IN      NUMBER,
  i_cost_type_id        IN      NUMBER,
  i_cost_method         IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_cost_layer_id       IN      NUMBER,
  i_qty_layer_id        IN      NUMBER,
  i_pac_rates_id        IN      NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  O_Err_Num             OUT NOCOPY     NUMBER,
  O_Err_Code            OUT NOCOPY     VARCHAR2,
  O_Err_Msg             OUT NOCOPY     VARCHAR2
)
return integer IS
BEGIN
  o_err_num := 0;
  o_err_code := '';
  o_err_msg := '';

  return -1;

EXCEPTION

  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPCHK.ACTUAL_COST_HOOK:' || substrb(SQLERRM,1,150);
    return -1;

END actual_cost_hook;

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
  i_pac_period_id               IN      NUMBER,
  i_prior_pac_period_id         IN      NUMBER,
  i_legal_entity                IN      NUMBER,
  i_cost_type_id                IN      NUMBER,
  i_cost_group_id               IN      NUMBER,
  i_cost_method                 IN      NUMBER,
  i_user_id                     IN      NUMBER,
  i_login_id                    IN      NUMBER,
  i_request_id                  IN      NUMBER,
  i_prog_id                     IN      NUMBER,
  i_prog_app_id                 IN      NUMBER,
  o_err_num                     OUT NOCOPY     NUMBER,
  o_err_code                    OUT NOCOPY     VARCHAR2,
  o_err_msg                     OUT NOCOPY     VARCHAR2
)
return integer IS
BEGIN
  o_err_num := 0;
  o_err_code := '';
  o_err_msg := '';

  return -1;

EXCEPTION

  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPCHK.BEGINNING_BALANCE_HOOK:' || substrb(SQLERRM,1,150);
    o_err_num := SQLCODE;
    return -1;

END beginning_balance_hook;


END CSTPPCHK;

/
