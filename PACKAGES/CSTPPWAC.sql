--------------------------------------------------------
--  DDL for Package CSTPPWAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPWAC" AUTHID CURRENT_USER AS
/* $Header: CSTPWACS.pls 120.4.12010000.3 2008/11/10 13:35:14 anjha ship $ */

-- PROCEDURE
--  cost_processor	Costs inventory transactions
--
procedure cost_processor(
  I_LEGAL_ENTITY	IN	NUMBER,
  I_PAC_PERIOD_ID	IN	NUMBER,
  I_ORG_ID		IN	NUMBER,
  I_COST_GROUP_ID	IN	NUMBER,
  I_TXN_COST_GROUP_ID	IN	NUMBER,
  I_TXFR_COST_GROUP_ID	IN	NUMBER,
  I_COST_TYPE_ID	IN	NUMBER,
  I_COST_METHOD		IN	NUMBER,
  I_PROCESS_GROUP	IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  I_QTY_LAYER_ID	IN	NUMBER,
  I_COST_LAYER_ID	IN	NUMBER,
  I_PAC_RATES_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_QTY		IN	NUMBER,
  I_TXN_ACTION_ID 	IN	NUMBER,
  I_TXN_SRC_TYPE_ID 	IN	NUMBER,
  I_FOB_POINT		IN	NUMBER,
  I_EXP_ITEM		IN	NUMBER,
  I_EXP_FLAG		IN	NUMBER,
  I_COST_HOOK_USED	IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN	NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
);



-- PROCEDURE
--  sub_transfer
--
procedure sub_transfer(
  I_PAC_PERIOD_ID	IN	NUMBER,
  I_ORG_ID		IN	NUMBER,
  I_COST_GROUP_ID	IN	NUMBER,
  I_COST_TYPE_ID	IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  I_COST_LAYER_ID	IN	NUMBER,
  I_QTY_LAYER_ID	IN	NUMBER,
  I_PAC_RATES_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_QTY		IN	NUMBER,
  I_TXN_ACTION_ID 	IN	NUMBER,
  I_TXN_SRC_TYPE_ID	IN	NUMBER,
  I_EXP_FLAG		IN	NUMBER,
  I_NO_UPDATE_QTY 	IN	NUMBER,
  I_COST_METHOD		IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID		IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID 	IN	NUMBER,
  I_PRG_ID		IN	NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
);



-- PROCEDURE
--  interorg
--
procedure interorg(
  I_PAC_PERIOD_ID	IN	NUMBER,
  I_ORG_ID		IN	NUMBER,
  I_COST_GROUP_ID	IN	NUMBER,
  I_TXFR_COST_GROUP_ID	IN	NUMBER,
  I_COST_TYPE_ID	IN	NUMBER,
  I_COST_METHOD		IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  I_COST_LAYER_ID	IN	NUMBER,
  I_QTY_LAYER_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_QTY		IN	NUMBER,
  I_ISSUE_QTY		IN	NUMBER,
  I_BUY_QTY		IN	NUMBER,
  I_MAKE_QTY		IN	NUMBER,
  I_TXN_ACTION_ID 	IN	NUMBER,
  I_TXN_SRC_TYPE_ID	IN	NUMBER,
  I_EXP_FLAG		IN	NUMBER,
  I_INTERORG_REC 	IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID		IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID 	IN	NUMBER,
  I_PRG_ID		IN	NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
);



-- PROCEDURE
--  cost_owned_txns
--
procedure cost_owned_txns(
  I_PAC_PERIOD_ID	IN	NUMBER,
  I_COST_GROUP_ID	IN	NUMBER,
  I_COST_TYPE_ID	IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  I_COST_LAYER_ID	IN	NUMBER,
  I_QTY_LAYER_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_QTY		IN	NUMBER,
  I_ISSUE_QTY		IN	NUMBER,
  I_BUY_QTY		IN	NUMBER,
  I_MAKE_QTY		IN	NUMBER,
  I_TXN_ACTION_ID 	IN	NUMBER,
  I_COST_METHOD		IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID		IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID 	IN	NUMBER,
  I_PRG_ID		IN	NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
);



-- PROCEDURE
--  cost_derived_txns
--
procedure cost_derived_txns(
  I_PAC_PERIOD_ID	IN	NUMBER,
  I_COST_GROUP_ID	IN	NUMBER,
  I_COST_TYPE_ID	IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  I_COST_LAYER_ID	IN	NUMBER,
  I_QTY_LAYER_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_QTY		IN	NUMBER,
  I_ISSUE_QTY		IN	NUMBER,
  I_BUY_QTY		IN	NUMBER,
  I_MAKE_QTY		IN	NUMBER,
  I_TXN_ACTION_ID 	IN	NUMBER,
  I_TXN_SRC_TYPE_ID	IN	NUMBER,
  I_EXP_FLAG		IN	NUMBER,
  I_NO_UPDATE_QTY 	IN	NUMBER,
  I_COST_METHOD		IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID		IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID 	IN	NUMBER,
  I_PRG_ID		IN	NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
);



-- FUNCTION
--  compute_pwac_cost
--
function compute_pwac_cost(
  I_PAC_PERIOD_ID	IN	NUMBER,
  I_ORG_ID		IN	NUMBER,
  I_COST_GROUP_ID	IN	NUMBER,
  I_COST_TYPE_ID	IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  I_COST_LAYER_ID	IN	NUMBER,
  I_PAC_RATES_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_QTY		IN	NUMBER,
  I_TXN_ACTION_ID 	IN	NUMBER,
  I_TXN_SRC_TYPE_ID 	IN	NUMBER,
  I_INTERORG_REC	IN	NUMBER,
  I_ACROSS_CGS		IN	NUMBER,
  I_EXP_FLAG		IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN	NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
)
return integer;



-- PROCEDURE
--  apply_material_ovhd		Applying this level material overhead based
-- 				on the pre-defined rates in the material
--
procedure apply_material_ovhd(
  I_PAC_PERIOD_ID	IN	NUMBER,
  I_ORG_ID		IN	NUMBER,
  I_COST_GROUP_ID	IN	NUMBER,
  I_COST_TYPE_ID	IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  I_COST_LAYER_ID	IN	NUMBER,
  I_PAC_RATES_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_QTY		IN	NUMBER,
  I_LEVEL		IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN	NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
);



-- PROCEDURE
--  current_pwac_cost
--
procedure current_pwac_cost(
  I_COST_LAYER_ID	IN	NUMBER,
  I_QTY_LAYER_ID	IN	NUMBER,
  I_TXN_QTY		IN	NUMBER,
  I_ISSUE_QTY		IN	NUMBER,
  I_BUY_QTY		IN	NUMBER,
  I_MAKE_QTY		IN	NUMBER,
  I_TXN_ACTION_ID 	IN	NUMBER,
  I_EXP_FLAG		IN	NUMBER,
  I_NO_UPDATE_QTY 	IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID		IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID 	IN	NUMBER,
  I_PRG_ID		IN	NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  I_TXN_ID              IN      NUMBER,
  I_ITEM_ID             IN      NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
);



-- PROCEDURE
--  calc_pwac_cost
--
procedure calc_pwac_cost(
  I_PAC_PERIOD_ID	IN	NUMBER,
  I_COST_GROUP_ID	IN	NUMBER,
  I_COST_TYPE_ID	IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  I_COST_LAYER_ID	IN	NUMBER,
  I_QTY_LAYER_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_QTY		IN	NUMBER,
  I_ISSUE_QTY		IN	NUMBER,
  I_BUY_QTY		IN	NUMBER,
  I_MAKE_QTY		IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID		IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID 	IN	NUMBER,
  I_PRG_ID		IN	NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
);

PROCEDURE periodic_cost_update (
  I_PAC_PERIOD_ID       IN      NUMBER,
  I_COST_GROUP_ID       IN      NUMBER,
  I_COST_TYPE_ID        IN      NUMBER,
  I_TXN_ID              IN      NUMBER,
  I_COST_LAYER_ID       IN      NUMBER,
  I_QTY_LAYER_ID        IN      NUMBER,
  I_ITEM_ID             IN      NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  I_TXN_QTY             IN      NUMBER,
  O_Err_Num             OUT NOCOPY     NUMBER,
  O_Err_Code            OUT NOCOPY     VARCHAR2,
  O_Err_Msg             OUT NOCOPY     VARCHAR2
);

/*
PROCEDURE insert_txn_history (
  I_PAC_PERIOD_ID       IN      NUMBER,
  I_COST_GROUP_ID       IN      NUMBER,
  I_TXN_ID              IN      NUMBER,
  I_PROCESS_GROUP       IN      NUMBER,
  I_ITEM_ID             IN      NUMBER,
  I_QTY_LAYER_ID        IN      NUMBER,
  I_TXN_QTY             IN      NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  I_TXN_CATEGORY        IN      NUMBER,
  O_Err_Num             OUT NOCOPY     NUMBER,
  O_Err_Code            OUT NOCOPY     VARCHAR2,
  O_Err_Msg             OUT NOCOPY     VARCHAR2
);
*/

/*
PROCEDURE update_txn_history (
  I_PAC_PERIOD_ID       IN      NUMBER,
  I_COST_GROUP_ID       IN      NUMBER,
  I_TXN_ID              IN      NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  O_Err_Num             OUT NOCOPY     NUMBER,
  O_Err_Code            OUT NOCOPY     VARCHAR2,
  O_Err_Msg             OUT NOCOPY     VARCHAR2
);
*/

PROCEDURE calculate_periodic_cost
 (i_pac_period_id       IN      NUMBER,
 i_cost_group_id        IN      NUMBER,
 i_cost_type_id         IN      NUMBER,
 i_low_level_code       IN      NUMBER,
 i_item_id              IN      NUMBER,
 i_user_id              IN      NUMBER,
 i_login_id             IN      NUMBER,
 i_request_id           IN      NUMBER,
 i_prog_id              IN      NUMBER,
 i_prog_appl_id         IN      NUMBER,
 o_err_num              OUT NOCOPY     NUMBER,
 o_err_code             OUT NOCOPY     VARCHAR2,
 o_err_msg              OUT NOCOPY     VARCHAR2);

PROCEDURE insert_into_cppb
 (i_pac_period_id       IN      NUMBER,
 i_cost_group_id        IN      NUMBER,
 i_txn_category         IN      NUMBER,
 i_user_id              IN      NUMBER,
 i_login_id             IN      NUMBER,
 i_request_id           IN      NUMBER,
 i_prog_id              IN      NUMBER,
 i_prog_appl_id         IN      NUMBER,
 o_err_num              OUT NOCOPY     NUMBER,
 o_err_code             OUT NOCOPY     VARCHAR2,
 o_err_msg              OUT NOCOPY     VARCHAR2);

PROCEDURE update_cppb
 (i_pac_period_id       IN      NUMBER,
 i_cost_group_id        IN      NUMBER,
 i_txn_category         IN      NUMBER,
 i_low_level_code       IN      NUMBER,
 i_user_id              IN      NUMBER,
 i_login_id             IN      NUMBER,
 i_request_id           IN      NUMBER,
 i_prog_id              IN      NUMBER,
 i_prog_appl_id         IN      NUMBER,
 o_err_num              OUT NOCOPY      NUMBER,
 o_err_code             OUT NOCOPY      VARCHAR2,
 o_err_msg              OUT NOCOPY      VARCHAR2);

PROCEDURE update_item_cppb
 (i_pac_period_id       IN      NUMBER,
 i_cost_group_id        IN      NUMBER,
 i_txn_category         IN      NUMBER,
 i_item_id              IN      NUMBER,
 i_user_id              IN      NUMBER,
 i_login_id             IN      NUMBER,
 i_request_id           IN      NUMBER,
 i_prog_id              IN      NUMBER,
 i_prog_appl_id         IN      NUMBER,
 o_err_num              OUT NOCOPY      NUMBER,
 o_err_code             OUT NOCOPY      VARCHAR2,
 o_err_msg              OUT NOCOPY      VARCHAR2);

PROCEDURE insert_ending_balance
  (i_pac_period_id IN  NUMBER,
  i_cost_group_id IN  NUMBER,
  i_user_id       IN  NUMBER,
  i_login_id      IN  NUMBER,
  i_request_id    IN  NUMBER,
  i_prog_id       IN  NUMBER,
  i_prog_appl_id  IN  NUMBER,
  o_err_num       OUT NOCOPY NUMBER,
  o_err_code      OUT NOCOPY VARCHAR2,
  o_err_msg       OUT NOCOPY VARCHAR2);

END CSTPPWAC;

/
