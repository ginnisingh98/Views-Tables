--------------------------------------------------------
--  DDL for Package Body CSTPFCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPFCHK" AS
-- $Header: CSTFCHKB.pls 120.4.12010000.4 2009/12/15 01:33:50 anjha ship $
--+===========================================================================+
--|                                                                           |
--|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
--|                          All rights reserved.                             |
--+===========================================================================+
--|                                                                           |
--| File Name     : CSTFCHKB.pls                                              |
--| Description	: Cost Method specific processing extension                   |
--|                                                                           |
--| Revision                                                                  |
--|  11/12/98     Jung Ha    Creation                                         |
--|  2/5/99       DHerring   Added Content to Hooks                           |
--|  3/5/99       DHerring   1. copy_prior_info_hook (line 1109)              |
--|                             set beginning balance to 0                    |
--|                             CST_PAC_ITEM_COST.begin_item_cost = 0         |
--|                          2. calc_pac_cost_hook (line 710)                 |
--|                             set item_cost to 0. This column is            |
--|                             populated from the worker by                  |
--|                             CST_MGD_LIFO_COST_PROCESSOR.calc_lifo_cost    |
--|                          3. calc_pac_cost_hook (line 749)                 |
--|                             set layer_quantity to 0. This column is       |
--|                             populated from the worker by                  |
--|                             CST_MGD_LIFO_COST_PROCESSOR.calc_lifo_cost    |
--| 5/29/99      DHerring   Altered copy_prior_info hook. CPIC.make_quantity  |
--|                         and CPIC.buy_quantity are set to 0. This ensures  |
--|                         that the weighted average cost is only calculated |
--|                         for items bought or sold in the current period    |
--| 08/21/2001   vjavli     issue_quantity initialized to 0                   |
--|                         part of bug#1929915 fix                           |
--| 11/22/2004   vjavli     Bug#3942504 fix: Tracking bug                     |
--|                         OUT NOCOPY added as part of arcs checkin stds     |
--|                         Original bug#3775498 fix in 11.5.8                |
--|                         initializing begin_layer_quantity not required    |
--| 08/03/2005   vjavli     Added procedure periodic_cost_update_hook which is|
--|                         a copy from BOM115100 version to prevent any      |
--|                         regression.  The regression is due to cppb insert,|
--|                         update apis introduced in R12 code for PWAC method|
--| 11/27/2005   vjavli     copy_prior_info_hook: insert new column           |
--|                         unrelieved_scrap_quantity into wip_pac_period_    |
--|                         balances.  Insert new table: CST_PAC_REQ_OPER_    |
--|                         COST_DETAILS                                      |
--| 01/07/2005    vjavli    FP:11i8-12.0:Bug 4028737 fix:begin layer quantity |
--|                         initialized to total layer quantity of previous   |
--|                         period.  Base bug 3775498 fix.                    |
--| 05/24/2006   vmutyala   Bug 5239716 : Replaced Non Mergeable View         |
--|                         CST_PAC_ITEM_COSTS_V with base table              |
--|                         CST_PAC_ITEM_COST_DETAILS                         |
--| 02/07/2008    vjavli    Bug 6751847 performance fix: i_txn_category       |
--|                         parameter added to procedures compute_pac_cost_   |
--|                         hook, calc_pac_cost_hook and periodic_cost_update_|
--|                         hook.  i_txn_category added while insert into     |
--|                         MPACD;  CSTPPWAC.apply_material_ovhd definition   |
--|                         changed to add i_txn_category                     |
--+===========================================================================+

-- FUNCTION
--  compute_pac_cost_hook
--
function compute_pac_cost_hook(
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
  O_Err_Num		OUT	NOCOPY NUMBER,
  O_Err_Code		OUT	NOCOPY VARCHAR2,
  O_Err_Msg		OUT	NOCOPY VARCHAR2
)
return integer IS
  l_ret_val		NUMBER;
  l_level		NUMBER;
  l_txn_cost_exist	NUMBER;
  l_cost_details	NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
  process_error		EXCEPTION;

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_txn_cost_exist := 0;
  l_cost_details := 0;

  l_stmt_num := 10;

  select count(*)
  into l_txn_cost_exist
  from mtl_pac_txn_cost_details
  where transaction_id = i_txn_id
  and cost_group_id = i_cost_group_id
  and pac_period_id = i_pac_period_id;

  if (l_txn_cost_exist > 0) then

    l_ret_val := 1;
    l_stmt_num := 20;

    INSERT INTO mtl_pac_actual_cost_details (
	transaction_id,
	pac_period_id,
	cost_type_id,
	cost_group_id,
	cost_layer_id,
	cost_element_id,
	level_type,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	inventory_item_id,
	actual_cost,
	prior_cost,
	prior_buy_cost,
	prior_make_cost,
	new_cost,
	new_buy_cost,
	new_make_cost,
	insertion_flag,
	user_entered,
	transaction_costed_date,
	txn_category)
    SELECT
	i_txn_id,
	i_pac_period_id,
	i_cost_type_id,
	i_cost_group_id,
	i_cost_layer_id,
      	mptcd.cost_element_id,
      	mptcd.level_type,
      	sysdate,
      	i_user_id,
      	sysdate,
      	i_user_id,
      	i_login_id,
      	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
      	mptcd.inventory_item_id,
      	mptcd.transaction_cost,
      	0,
      	0,
      	0,
      	NULL,
      	NULL,
      	NULL,
      	'Y',
      	'N',
	NULL,
	i_txn_category
    FROM  mtl_pac_txn_cost_details mptcd
    WHERE transaction_id = i_txn_id
    AND   pac_period_id  = i_pac_period_id
    AND   cost_group_id  = i_cost_group_id;

  else
    l_ret_val := 0;

    /********************************************************************
     ** Create detail rows in MTL_PAC_ACTUAL_COST_DETAILS based on     **
     ** records in CST_PAC_ITEM_COST_DETAILS.  Since we are using      **
     ** current average the actual cost, prior cost and new cost are   **
     ** all the same.                                                  **
     ** If detail rows do not exist in CST_PAC_ITEM_COST_DETAILS,      **
     ** we will insert a TL material 0 cost layer.		       **
     ********************************************************************/

    l_stmt_num := 30;

    select count(*)
    into l_cost_details
    from cst_pac_item_cost_details
    where cost_layer_id = i_cost_layer_id;

    if (l_cost_details > 0) then

      l_stmt_num := 40;


      INSERT INTO mtl_pac_actual_cost_details (
	transaction_id,
	pac_period_id,
	cost_type_id,
	cost_group_id,
	cost_layer_id,
	cost_element_id,
	level_type,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	inventory_item_id,
	actual_cost,
	prior_cost,
	prior_buy_cost,
	prior_make_cost,
	new_cost,
	new_buy_cost,
	new_make_cost,
	insertion_flag,
	user_entered,
	transaction_costed_date,
	txn_category)
      SELECT
	i_txn_id,
	i_pac_period_id,
	i_cost_type_id,
	i_cost_group_id,
	i_cost_layer_id,
      	cpicd.cost_element_id,
      	cpicd.level_type,
      	sysdate,
      	i_user_id,
      	sysdate,
      	i_user_id,
      	i_login_id,
      	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
      	i_item_id,
      	cpicd.item_cost,
      	cpicd.item_cost,
	cpicd.item_buy_cost,
	cpicd.item_make_cost,
      	cpicd.item_cost,
	cpicd.item_buy_cost,
	cpicd.item_make_cost,
      	'N',
      	'N',
	NULL,
	i_txn_category
      FROM  cst_pac_item_cost_details cpicd
      WHERE cpicd.cost_layer_id = i_cost_layer_id;

    else
      l_stmt_num := 50;

      INSERT INTO mtl_pac_actual_cost_details (
	transaction_id,
	pac_period_id,
	cost_type_id,
	cost_group_id,
	cost_layer_id,
	cost_element_id,
	level_type,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	inventory_item_id,
	actual_cost,
	prior_cost,
	prior_buy_cost,
	prior_make_cost,
	new_cost,
	new_buy_cost,
	new_make_cost,
	insertion_flag,
	user_entered,
	transaction_costed_date,
	txn_category)
      VALUES(
	i_txn_id,
	i_pac_period_id,
	i_cost_type_id,
	i_cost_group_id,
	i_cost_layer_id,
	1,
      	1,
      	sysdate,
      	i_user_id,
      	sysdate,
      	i_user_id,
      	i_login_id,
      	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
      	i_item_id,
      	0,
      	NULL,
      	NULL,
      	NULL,
      	0,
      	0,
      	0,
      	'N',
      	'N',
	NULL,
	i_txn_category);
    end if;

  end if;


  -- Apply material overhead to certain txns which are asset item and
  -- asset subinventory
  if ((i_exp_flag <> 1) AND
      ((i_txn_action_id = 27 and i_txn_src_type_id = 1) or -- PO receipt
       (i_txn_action_id = 1 and i_txn_src_type_id = 1)  or -- RTV
       (i_txn_action_id = 29 and i_txn_src_type_id = 1) or -- Delivery Adj
       (i_txn_action_id = 31 and i_txn_src_type_id = 5) or -- WIP completions
       (i_txn_action_id = 32 and i_txn_src_type_id = 5) or -- Assembly return
       (i_across_cgs = 1 and i_interorg_rec = 1))  -- Across CGs and Ownership
     ) then					   -- changes

    l_level := 1;

    CSTPPWAC.apply_material_ovhd(
			i_pac_period_id,
			i_org_id,
			i_cost_group_id,
			i_cost_type_id,
			i_txn_id,
			i_cost_layer_id,
			i_pac_rates_id,
			i_item_id,
			i_txn_qty,
			l_level,
			i_user_id,
			i_login_id,
			i_req_id,
			i_prg_appl_id,
			i_prg_id,
			i_txn_category,
			l_err_num,
			l_err_code,
			l_err_msg);

    if (l_err_num <> 0) then
      -- Error occured
      raise process_error;
    end if;
    l_ret_val := 1;
  end if;

  return l_ret_val;

  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
      return l_ret_val;
    when OTHERS then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPFCHK.Compute_Pac_Cost_Hook ('|| to_char(l_stmt_num) || '): '
		|| substr(SQLERRM,1,200);
      return l_ret_val;
END compute_pac_cost_hook;



-- PROCEDURE
--  calc_pac_cost_hook
--
procedure calc_pac_cost_hook(
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
  O_Err_Num		OUT	NOCOPY NUMBER,
  O_Err_Code		OUT	NOCOPY VARCHAR2,
  O_Err_Msg		OUT	NOCOPY VARCHAR2
) IS
  l_cur_onhand		NUMBER;
  l_cur_buy_qty		NUMBER;
  l_cur_make_qty	NUMBER;
  l_new_onhand		NUMBER;
  l_new_buy_qty		NUMBER;
  l_new_make_qty	NUMBER;

  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
  process_error		EXCEPTION;

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_cur_onhand := 0;
  l_cur_buy_qty := 0;
  l_cur_make_qty := 0;
  l_new_onhand := 0;
  l_new_buy_qty := 0;
  l_new_make_qty := 0;


  /********************************************************************
   ** Update mtl_pac_actual_cost_details and update the prior cost   **
   ** to the current average for the elements that exists and insert **
   ** in to mtl_pac_actual_cost_details the current average cost for **
   ** the elements that do not exist.                                **
   ********************************************************************/

  l_stmt_num := 10;

  UPDATE mtl_pac_actual_cost_details mpacd
  SET	prior_cost = 0,
	prior_buy_cost = 0,
	prior_make_cost = 0,
	new_cost = NULL,
	new_buy_cost = NULL,
	new_make_cost = NULL
  WHERE mpacd.transaction_id = i_txn_id
  AND	mpacd.cost_group_id = i_cost_group_id
  AND   mpacd.cost_layer_id = i_cost_layer_id;

  l_stmt_num := 20;

  UPDATE mtl_pac_actual_cost_details mpacd
  SET	(prior_cost,
	 prior_buy_cost,
	 prior_make_cost,
	 insertion_flag) =
	(SELECT cpicd.item_cost,
		cpicd.item_buy_cost,
		cpicd.item_make_cost,
		'N'
	 FROM cst_pac_item_cost_details cpicd
	 WHERE cpicd.cost_layer_id = i_cost_layer_id
	 AND cpicd.cost_element_id = mpacd.cost_element_id
	 AND cpicd.level_type = mpacd.level_type)
  WHERE mpacd.transaction_id = i_txn_id
  AND	mpacd.cost_group_id = i_cost_group_id
  AND   mpacd.cost_layer_id = i_cost_layer_id
  AND EXISTS
	(SELECT 'there is details in cpicd'
	 FROM	cst_pac_item_cost_details cpicd
	 WHERE	cpicd.cost_layer_id = i_cost_layer_id
	 AND	cpicd.cost_element_id = mpacd.cost_element_id
	 AND	cpicd.level_type = mpacd.level_type);

  l_stmt_num := 30;

  INSERT INTO mtl_pac_actual_cost_details (
	transaction_id,
	pac_period_id,
	cost_type_id,
	cost_group_id,
	cost_layer_id,
	cost_element_id,
	level_type,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	inventory_item_id,
	actual_cost,
	prior_cost,
	prior_buy_cost,
	prior_make_cost,
	new_cost,
	new_buy_cost,
	new_make_cost,
	insertion_flag,
	user_entered,
	transaction_costed_date,
	txn_category)
  SELECT i_txn_id,
	i_pac_period_id,
	i_cost_type_id,
	i_cost_group_id,
	i_cost_layer_id,
	cpicd.cost_element_id,
	cpicd.level_type,
	sysdate,
      	i_user_id,
      	sysdate,
      	i_user_id,
      	i_login_id,
      	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
	i_item_id,
      	0,
      	cpicd.item_cost,
      	cpicd.item_buy_cost,
      	cpicd.item_make_cost,
	NULL,
	NULL,
	NULL,
      	'N',
      	'N',
	NULL,
	i_txn_category
  FROM	cst_pac_item_cost_details cpicd
  WHERE	cost_layer_id = i_cost_layer_id
  AND NOT EXISTS
	(SELECT	'this detail is not in mpacd already'
	 FROM	mtl_pac_actual_cost_details mpacd
	 WHERE	mpacd.transaction_id = i_txn_id
	 AND	mpacd.cost_group_id = i_cost_group_id
	 AND	mpacd.cost_layer_id = i_cost_layer_id
	 AND	mpacd.cost_element_id = cpicd.cost_element_id
	 AND	mpacd.level_type = cpicd.level_type);


  /********************************************************************
   ** Compute new average cost.					     **
   ********************************************************************/
  l_stmt_num := 40;

  SELECT total_layer_quantity,
	 buy_quantity,
	 make_quantity
  INTO   l_cur_onhand,
	 l_cur_buy_qty,
	 l_cur_make_qty
  FROM   cst_pac_item_costs
  WHERE  cost_layer_id = i_cost_layer_id;


  /********************************************************************
   ** Update Item costs and Quantity                                 **
   ********************************************************************/
  l_new_onhand := l_cur_onhand + i_txn_qty;
  l_new_buy_qty := l_cur_buy_qty + i_buy_qty;
  l_new_make_qty := l_cur_make_qty + i_make_qty;


  l_stmt_num := 50;

  UPDATE mtl_pac_actual_cost_details mpacd
  SET new_cost =
	decode(sign(l_cur_onhand),-1,
	       decode(sign(i_txn_qty), -1,
		      (mpacd.prior_cost*l_cur_onhand + mpacd.actual_cost*i_txn_qty)/l_new_onhand,
		      decode(sign(l_new_onhand),-1, mpacd.prior_cost,
			     mpacd.actual_cost)),
	       decode(sign(i_txn_qty), -1,
		      decode(sign(l_new_onhand), 1,
  		            decode(sign((mpacd.prior_cost*l_cur_onhand + mpacd.actual_cost*i_txn_qty)/l_new_onhand),1,
		                   (mpacd.prior_cost*l_cur_onhand + mpacd.actual_cost*i_txn_qty)/l_new_onhand,
		                   0)
                             ,mpacd.actual_cost),
		      (mpacd.prior_cost*l_cur_onhand + mpacd.actual_cost*i_txn_qty)/l_new_onhand)),
      new_buy_cost =
	decode(sign(l_cur_buy_qty),-1,
	       decode(sign(i_buy_qty), -1,
		      (mpacd.prior_buy_cost*l_cur_buy_qty + mpacd.actual_cost*i_buy_qty)/l_new_buy_qty,
		      decode(sign(l_new_buy_qty),-1, mpacd.prior_buy_cost,
			     mpacd.actual_cost)),
	       decode(sign(i_buy_qty), -1,
		      decode(sign(l_new_buy_qty), 1,
  		            decode(sign((mpacd.prior_buy_cost*l_cur_buy_qty + mpacd.actual_cost*i_buy_qty)/l_new_buy_qty),1,
		                   (mpacd.prior_buy_cost*l_cur_buy_qty + mpacd.actual_cost*i_buy_qty)/l_new_buy_qty,
		                   0)
                             ,mpacd.actual_cost),
		      (mpacd.prior_buy_cost*l_cur_buy_qty + mpacd.actual_cost*i_buy_qty)/decode(l_new_buy_qty,0,1,l_new_buy_qty))),
      new_make_cost =
	decode(sign(l_cur_make_qty),-1,
	       decode(sign(i_make_qty), -1,
		      (mpacd.prior_make_cost*l_cur_make_qty + mpacd.actual_cost*i_make_qty)/l_new_make_qty,
		      decode(sign(l_new_make_qty),-1, mpacd.prior_make_cost,
			     mpacd.actual_cost)),
	       decode(sign(i_make_qty), -1,
		      decode(sign(l_new_make_qty), 1,
  		            decode(sign((mpacd.prior_make_cost*l_cur_make_qty + mpacd.actual_cost*i_make_qty)/l_new_make_qty),1,
		                   (mpacd.prior_make_cost*l_cur_make_qty + mpacd.actual_cost*i_make_qty)/l_new_make_qty,
		                   0)
                             ,mpacd.actual_cost),
		      (mpacd.prior_make_cost*l_cur_make_qty + mpacd.actual_cost*i_make_qty)/decode(l_new_make_qty,0,1,l_new_make_qty)))
  WHERE  mpacd.transaction_id = i_txn_id
  AND    mpacd.cost_layer_id = i_cost_layer_id;


  l_stmt_num := 60;

  UPDATE cst_pac_item_cost_details cpicd
  SET (last_update_date,
       last_updated_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       item_cost,
       item_buy_cost,
       item_make_cost) =
     (SELECT sysdate,
	     i_user_id,
	     i_login_id,
	     i_req_id,
	     i_prg_appl_id,
	     i_prg_id,
	     sysdate,
	     new_cost,
	     new_buy_cost,
	     new_make_cost
      FROM   mtl_pac_actual_cost_details mpacd
      WHERE  mpacd.transaction_id = i_txn_id
      AND    mpacd.cost_group_id = i_cost_group_id
      AND    mpacd.cost_layer_id = i_cost_layer_id
      AND    mpacd.cost_element_id = cpicd.cost_element_id
      AND    mpacd.level_type = cpicd.level_type)
  WHERE cpicd.cost_layer_id = i_cost_layer_id;

  l_stmt_num := 70;

  INSERT INTO cst_pac_item_cost_details(
	cost_layer_id,
	cost_element_id,
	level_type,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	item_cost,
	item_buy_cost,
	item_make_cost)
  SELECT i_cost_layer_id,
	mpacd.cost_element_id,
	mpacd.level_type,
	sysdate,
      	i_user_id,
      	sysdate,
      	i_user_id,
      	i_login_id,
      	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
	mpacd.new_cost,
	mpacd.new_buy_cost,
	mpacd.new_make_cost
  FROM	mtl_pac_actual_cost_details mpacd
  WHERE	mpacd.transaction_id = i_txn_id
  AND	mpacd.cost_group_id = i_cost_group_id
  AND	mpacd.cost_layer_id = i_cost_layer_id
  AND	mpacd.insertion_flag = 'Y';


  /********************************************************************
   ** Update layer quantity and layer costs information		     **
   ********************************************************************/
  l_stmt_num := 80;

  UPDATE cst_pac_item_costs cpic
  SET (last_updated_by,
	last_update_date,
	last_update_login,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	total_layer_quantity,
	issue_quantity,
	buy_quantity,
	make_quantity,
	pl_material,
	pl_material_overhead,
	pl_resource,
	pl_outside_processing,
	pl_overhead,
	tl_material,
	tl_material_overhead,
	tl_resource,
	tl_outside_processing,
	tl_overhead,
	material_cost,
	material_overhead_cost,
	resource_cost,
	outside_processing_cost,
	overhead_cost,
	pl_item_cost,
	tl_item_cost,
	item_cost,
	item_buy_cost,
	item_make_cost,
	unburdened_cost,
	burden_cost) =
     (SELECT
        i_user_id,
        sysdate,
        i_login_id,
	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
	l_new_onhand,
	issue_quantity + i_issue_qty,
	buy_quantity + i_buy_qty,
	make_quantity + i_make_qty,
	SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,1,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,2,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,3,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,4,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,5,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,1,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,2,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,3,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,4,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,5,ITEM_COST,0),0)),
	SUM(DECODE(COST_ELEMENT_ID,1,ITEM_COST,0)),
	SUM(DECODE(COST_ELEMENT_ID,2,ITEM_COST,0)),
	SUM(DECODE(COST_ELEMENT_ID,3,ITEM_COST,0)),
	SUM(DECODE(COST_ELEMENT_ID,4,ITEM_COST,0)),
	SUM(DECODE(COST_ELEMENT_ID,5,ITEM_COST,0)),
	SUM(DECODE(LEVEL_TYPE,2,ITEM_COST,0)),
	SUM(DECODE(LEVEL_TYPE,1,ITEM_COST,0)),
        -- The following value is a change from the
        -- code for PAC. 0 is inserted into
        -- CST_PAC_ITEM_COSTS.item_cost.
	0,
	SUM(ITEM_BUY_COST),
	SUM(ITEM_MAKE_COST),
	SUM(DECODE(COST_ELEMENT_ID,2,DECODE(LEVEL_TYPE,2,ITEM_COST,0),ITEM_COST)),
	SUM(DECODE(COST_ELEMENT_ID,2,DECODE(LEVEL_TYPE,1,ITEM_COST,0),0))
      FROM  CST_PAC_ITEM_COST_DETAILS v
      WHERE v.cost_layer_id = i_cost_layer_id
      GROUP BY COST_LAYER_ID)
  WHERE cpic.cost_layer_id = i_cost_layer_id
  AND EXISTS
	(SELECT 'there is detail cost'
	 FROM   cst_pac_item_cost_details cpicd
	 WHERE  cpicd.cost_layer_id = i_cost_layer_id);


  l_stmt_num := 90;

    --===========================================================
    -- The following statement is not required in incremental
    -- lifo as layer_quantity is populated in package
    -- CST_MGD_LIFO_COST_PROCESSOR.populate_layers
    --===========================================================
    -- UPDATE cst_pac_quantity_layers cpql
    -- SET (last_updated_by,
    -- last_update_date,
    -- last_update_login,
    -- request_id,
    -- program_application_id,
    -- program_id,
    -- program_update_date,
    -- layer_quantity) =
    -- (SELECT
    --  i_user_id,
    --  sysdate,
    --  i_login_id,
    --  i_req_id,
    --	i_prg_appl_id,
    --	i_prg_id,
    --	sysdate,
    --  l_new_onhand
    --  FROM  sys.dual)
    --  WHERE cpql.quantity_layer_id = i_qty_layer_id
    --  AND EXISTS
    -- (SELECT 'there is a layer'
    --  FROM   cst_pac_quantity_layers cpql
    --  WHERE  cpql.quantity_layer_id = i_qty_layer_id);
    --===========================================================
    -- The statement has not been deleted for comparison reasons
    --===========================================================

  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when OTHERS then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPPWAC.Calc_PWAC_Cost (' || to_char(l_stmt_num) || '): '
		|| substr(SQLERRM,1,200);

END calc_pac_cost_hook;


-- PROCEDURE
--  current_pac_cost_hook
--
procedure current_pac_cost_hook(
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
  O_Err_Num		OUT	NOCOPY NUMBER,
  O_Err_Code		OUT	NOCOPY VARCHAR2,
  O_Err_Msg		OUT	NOCOPY VARCHAR2
) IS
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
  process_error		EXCEPTION;

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';


  if ((i_txn_action_id = 30) or (i_no_update_qty = 1) or (i_exp_flag = 1)) then
    return;
  else

    l_stmt_num := 10;

    UPDATE cst_pac_item_costs cpic
    SET   last_update_date = sysdate,
          last_updated_by = i_user_id,
          last_update_login = i_login_id,
          request_id = i_req_id,
          program_application_id = i_prg_appl_id,
          program_id = i_prg_id,
          program_update_date = sysdate,
	  total_layer_quantity = total_layer_quantity + i_txn_qty,
	  issue_quantity = issue_quantity + i_issue_qty,
	  buy_quantity = buy_quantity + i_buy_qty,
	  make_quantity = make_quantity + i_make_qty
    WHERE cpic.cost_layer_id = i_cost_layer_id;


    l_stmt_num := 20;

    UPDATE cst_pac_quantity_layers cpql
    SET   last_update_date = sysdate,
          last_updated_by = i_user_id,
          last_update_login = i_login_id,
          request_id = i_req_id,
          program_application_id = i_prg_appl_id,
          program_id = i_prg_id,
          program_update_date = sysdate,
          layer_quantity = layer_quantity + i_txn_qty
        WHERE cpql.quantity_layer_id = i_qty_layer_id;

  end if;

  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when OTHERS then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPFCHK.Current_Pac_Cost_Hook ('|| to_char(l_stmt_num) || '): '
		|| substr(SQLERRM,1,200);

END current_pac_cost_hook;

-- FUNCTION
--  pac_wip_issue_cost_hook
--
FUNCTION pac_wip_issue_cost_hook(
  I_PAC_PERIOD_ID	IN	NUMBER,
  I_ORG_ID		IN	NUMBER,
  I_COST_GROUP_ID	IN	NUMBER,
  I_COST_TYPE_ID	IN	NUMBER,
  I_COST_METHOD		IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  I_COST_LAYER_ID	IN	NUMBER,
  I_QTY_LAYER_ID	IN	NUMBER,
  I_PAC_RATES_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_PRI_QTY		IN	NUMBER,
  I_TXN_ACTION_ID 	IN	NUMBER,
  I_ENTITY_ID		IN	NUMBER,
  I_LINE_ID		IN	NUMBER,
  I_OP_SEQ		IN	NUMBER,
  I_EXP_FLAG		IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN	NUMBER,
  O_Err_Num		OUT	NOCOPY NUMBER,
  O_Err_Code		OUT	NOCOPY VARCHAR2,
  O_Err_Msg		OUT	NOCOPY VARCHAR2
)
return integer IS
  l_ret_val		NUMBER;
  l_level		NUMBER;
  l_txn_cost_exist	NUMBER;
  l_cost_details	NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  l_stmt_num		NUMBER;
  process_error		EXCEPTION;

BEGIN
  -- initialize local variables
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_ret_val := 0;


  return l_ret_val;


  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
      return l_ret_val;
    when OTHERS then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPFCHK.Compute_Pac_Cost_Hook ('|| to_char(l_stmt_num) || '): '
		|| substr(SQLERRM,1,200);
      return l_ret_val;
END pac_wip_issue_cost_hook;


-- PROCEDURE
--  copy_prior_info_hook
--
procedure copy_prior_info_hook(
  I_PAC_PERIOD_ID       IN      NUMBER,
  I_PRIOR_PAC_PERIOD_ID IN      NUMBER,
  I_LEGAL_ENTITY        IN      NUMBER,
  I_COST_TYPE_ID        IN      NUMBER,
  I_COST_GROUP_ID       IN      NUMBER,
  I_COST_METHOD         IN      NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQUEST_ID          IN      NUMBER,
  I_PROG_APP_ID         IN      NUMBER,
  I_PROG_ID             IN      NUMBER,
  O_Err_Num             OUT     NOCOPY NUMBER,
  O_Err_Code            OUT     NOCOPY VARCHAR2,
  O_Err_Msg             OUT     NOCOPY VARCHAR2
) IS

l_err_num		NUMBER;
l_err_code		VARCHAR2(240);
l_err_msg		VARCHAR2(240);
l_stmt_num		NUMBER;
l_count			NUMBER;
l_use_hook		NUMBER;
l_cost_layer_id         NUMBER;
l_quantity_layer_id     NUMBER;
l_cost_method_type	NUMBER;
l_current_start_date	DATE;
CURRENT_DATA_EXISTS	EXCEPTION;
PROCESS_ERROR		EXCEPTION;

CURSOR prior_period_cost_cursor IS
  SELECT cost_layer_id
  FROM cst_pac_item_costs cpic
  WHERE cpic.pac_period_id = i_prior_pac_period_id
    AND cpic.cost_group_id = i_cost_group_id;

CURSOR prior_period_quantity_cursor (P_cost_layer_id number) IS
  SELECT quantity_layer_id
  FROM cst_pac_quantity_layers cpql
  WHERE cpql.cost_layer_id = P_cost_layer_id;

CURSOR prior_period_jobs_cursor IS
  SELECT distinct(wip_entity_id)
  FROM wip_pac_period_balances wppb
  WHERE wppb.pac_period_id = i_prior_pac_period_id
    AND wppb.cost_group_id = i_cost_group_id;

l_file                  VARCHAR2(100);

BEGIN
----------------------------------------------------------------------
-- Initialize Variables
----------------------------------------------------------------------

  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';


  BIS_DEBUG_PUB.Initialize;
  l_file:=BIS_DEBUG_PUB.Set_debug_mode('FILE');
  BIS_DEBUG_PUB.Debug_on;

  BIS_DEBUG_PUB.Add('Beginning Balance Cost Hook Reached');

--------------------------------------------------------------------
-- Copy from previous period, if this is not the first run period --
--------------------------------------------------------------------
  IF (i_prior_pac_period_id <> -1) THEN

--------------------------------------------------------
-- Making sure that we have no data in current period --
--------------------------------------------------------
    l_stmt_num := 10;
    l_count := 0;
    SELECT count(*)
    INTO l_count
    FROM cst_pac_item_costs
    WHERE pac_period_id = i_pac_period_id
      AND cost_group_id = i_cost_group_id;

    IF (l_count <> 0) THEN
      raise CURRENT_DATA_EXISTS;
    END IF;

    l_stmt_num := 20;
    l_count := 0;
    SELECT count(*)
    INTO l_count
    FROM wip_pac_period_balances
    WHERE pac_period_id = i_pac_period_id
      AND cost_group_id = i_cost_group_id;

    IF (l_count <> 0) THEN
      raise CURRENT_DATA_EXISTS;
    END IF;


--------------------------------------------------------------------------------
-- Copy data from previous period to current period of the following tables : --
-- 1. cst_pac_item_costs						      --
-- 2. cst_pac_item_cost_details						      --
-- 3. cst_pac_quantity_layers						      --
-- New cost_layer_id and quantity_layer_id are generated for every rows       --
-- inserted.								      --
--------------------------------------------------------------------------------
    FOR l_prior_period_cost IN prior_period_cost_cursor LOOP

      SELECT cst_pac_item_costs_s.nextval
      INTO l_cost_layer_id
      FROM dual;

-------------------------------------------
-- Copy prior info of CST_PAC_ITEM_COSTS --
-------------------------------------------
      l_stmt_num := 30;
      INSERT INTO cst_pac_item_costs (
        cost_layer_id,
        pac_period_id,
        cost_group_id,
        inventory_item_id,
        total_layer_quantity,
        buy_quantity,
        make_quantity,
        issue_quantity,
        item_cost,
        begin_item_cost,
        item_buy_cost,
        item_make_cost,
        material_cost,
        material_overhead_cost,
        resource_cost,
        overhead_cost,
        outside_processing_cost,
        pl_material,
        pl_material_overhead,
        pl_resource,
        pl_outside_processing,
        pl_overhead,
        tl_material,
        tl_material_overhead,
        tl_resource,
        tl_outside_processing,
        tl_overhead,
        pl_item_cost,
        tl_item_cost,
        unburdened_cost,
        burden_cost,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        last_update_login)
      SELECT
        l_cost_layer_id,
        i_pac_period_id,
        cost_group_id,
        inventory_item_id,
        total_layer_quantity,
        0,
        0,
        0,
        item_cost,
        item_cost,
        item_buy_cost,
        item_make_cost,
        material_cost,
        material_overhead_cost,
        resource_cost,
        overhead_cost,
        outside_processing_cost,
        pl_material,
        pl_material_overhead,
        pl_resource,
        pl_outside_processing,
        pl_overhead,
        tl_material,
        tl_material_overhead,
        tl_resource,
        tl_outside_processing,
        tl_overhead,
        pl_item_cost,
        tl_item_cost,
        unburdened_cost,
        burden_cost,
        SYSDATE,
        i_user_id,
        SYSDATE,
        i_user_id,
        i_request_id,
        i_prog_app_id,
        i_prog_id,
        SYSDATE,
        i_login_id
      FROM cst_pac_item_costs cpic
      WHERE cpic.cost_layer_id = l_prior_period_cost.cost_layer_id;

--------------------------------------------------
-- Copy prior info of CST_PAC_ITEM_COST_DETAILS --
--------------------------------------------------
      l_stmt_num := 40;
      INSERT INTO cst_pac_item_cost_details (
        cost_layer_id,
        cost_element_id,
        level_type,
        item_cost,
        item_buy_cost,
        item_make_cost,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        last_update_login)
      SELECT
        l_cost_layer_id,
        cpicd.cost_element_id,
        cpicd.level_type,
        0,
        0,
        0,
        SYSDATE,
        i_user_id,
        SYSDATE,
        i_user_id,
        i_request_id,
        i_prog_app_id,
        i_prog_id,
        SYSDATE,
        i_login_id
      FROM cst_pac_item_cost_details cpicd
      WHERE cpicd.cost_layer_id = l_prior_period_cost.cost_layer_id;

      FOR l_prior_period_qty IN
      prior_period_quantity_cursor (l_prior_period_cost.cost_layer_id) LOOP

        SELECT cst_pac_quantity_layers_s.nextval
        INTO l_quantity_layer_id
        FROM dual;

------------------------------------------------
-- Copy prior info of CST_PAC_QUANTITY_LAYERS --
------------------------------------------------
        l_stmt_num := 50;
        INSERT INTO cst_pac_quantity_layers (
          quantity_layer_id,
          cost_layer_id,
          pac_period_id,
          cost_group_id,
          inventory_item_id,
          layer_quantity,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          last_update_login)
        SELECT
          l_quantity_layer_id,
          l_cost_layer_id,
          i_pac_period_id,
          cost_group_id,
          inventory_item_id,
          layer_quantity,
          SYSDATE,
          i_user_id,
          SYSDATE,
          i_user_id,
          i_request_id,
          i_prog_app_id,
          i_prog_id,
          SYSDATE,
          i_login_id
        FROM cst_pac_quantity_layers cpql
        WHERE cpql.quantity_layer_id = l_prior_period_qty.quantity_layer_id;

        -- =============================================================================
        -- Bug 4028737 fix:
        -- Update begin_layer_quantity with cpic.total_layer_quantity of previous period
        -- =============================================================================
        l_stmt_num := 55;
        UPDATE cst_pac_quantity_layers
           SET begin_layer_quantity = (SELECT total_layer_quantity
                                       FROM cst_pac_item_costs
                                       WHERE cost_layer_id = l_prior_period_cost.cost_layer_id)
        WHERE quantity_layer_id = l_quantity_layer_id;


      END LOOP;

    END LOOP;

---------------------------------------------------------------------------
-- Copy prior info of wip_pac_period_balances 				--
-- Only the followings are copied :       				--
-- 1. Discrete jobs that are opened or closed in the current period.	--
-- 2. Scheduled CFM that are opened or closed in the current period.    --
-- 3. Repetitive Schedules having at least line that are opened or      --
--    closed in the current period.					--
-- Thus jobs/schedules that are closed in the previous period will not  --
-- be copied to current period.
---------------------------------------------------------------------------
    l_stmt_num := 60;
    SELECT period_start_date
    INTO l_current_start_date
    FROM CST_PAC_PERIODS
    WHERE pac_period_id = i_pac_period_id;

    l_stmt_num := 70;
    INSERT INTO wip_pac_period_balances (
      pac_period_id,
      cost_group_id,
      cost_type_id,
      organization_id,
      wip_entity_id,
      line_id,
      operation_seq_num,
      operation_completed_units,
      relieved_assembly_units,
      tl_resource_in,
      tl_resource_out,
      tl_outside_processing_in,
      tl_outside_processing_out,
      tl_overhead_in,
      tl_overhead_out,
      pl_material_in,
      pl_material_out,
      pl_resource_in,
      pl_resource_out,
      pl_overhead_in,
      pl_overhead_out,
      pl_outside_processing_in,
      pl_outside_processing_out,
      pl_material_overhead_in,
      pl_material_overhead_out,
      tl_resource_temp,
      tl_outside_processing_temp,
      tl_overhead_temp,
      pl_material_temp,
      pl_material_overhead_temp,
      pl_resource_temp,
      pl_outside_processing_temp,
      pl_overhead_temp,
      tl_resource_var,
      tl_outside_processing_var,
      tl_overhead_var,
      pl_material_var,
      pl_material_overhead_var,
      pl_resource_var,
      pl_outside_processing_var,
      pl_overhead_var,
      wip_entity_type,
      unrelieved_scrap_quantity,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      last_update_login )
    SELECT
      i_pac_period_id,
      wppb.cost_group_id,
      wppb.cost_type_id,
      wppb.organization_id,
      wppb.wip_entity_id,
      wppb.line_id,
      wppb.operation_seq_num,
      wppb.operation_completed_units,
      wppb.relieved_assembly_units,
      wppb.tl_resource_in,
      wppb.tl_resource_out,
      wppb.tl_outside_processing_in,
      wppb.tl_outside_processing_out,
      wppb.tl_overhead_in,
      wppb.tl_overhead_out,
      wppb.pl_material_in,
      wppb.pl_material_out,
      wppb.pl_resource_in,
      wppb.pl_resource_out,
      wppb.pl_overhead_in,
      wppb.pl_overhead_out,
      wppb.pl_outside_processing_in,
      wppb.pl_outside_processing_out,
      wppb.pl_material_overhead_in,
      wppb.pl_material_overhead_out,
      wppb.tl_resource_temp,
      wppb.tl_outside_processing_temp,
      wppb.tl_overhead_temp,
      wppb.pl_material_temp,
      wppb.pl_material_overhead_temp,
      wppb.pl_resource_temp,
      wppb.pl_outside_processing_temp,
      wppb.pl_overhead_temp,
      wppb.tl_resource_var,
      wppb.tl_outside_processing_var,
      wppb.tl_overhead_var,
      wppb.pl_material_var,
      wppb.pl_material_overhead_var,
      wppb.pl_resource_var,
      wppb.pl_outside_processing_var,
      wppb.pl_overhead_var,
      wppb.wip_entity_type,
      wppb.unrelieved_scrap_quantity,
      SYSDATE,
      i_user_id,
      SYSDATE,
      i_user_id,
      i_request_id,
      i_prog_app_id,
      i_prog_id,
      SYSDATE,
      i_login_id
    FROM
      wip_pac_period_balances wppb, wip_entities we
    WHERE
      wppb.pac_period_id = i_prior_pac_period_id
      AND wppb.cost_group_id = i_cost_group_id
      AND wppb.wip_entity_id = we.wip_entity_id
      AND (
      ( we.entity_type IN (1,3) AND EXISTS (
        SELECT 'X'
        FROM wip_discrete_jobs wdj
        WHERE
          wdj.wip_entity_id = wppb.wip_entity_id AND
          NVL(wdj.date_closed, l_current_start_date) >= l_current_start_date))
      OR (we.entity_type = 4 AND EXISTS (
        SELECT 'X'
        FROM wip_flow_schedules wfs
        WHERE
          wfs.wip_entity_id = wppb.wip_entity_id AND
          wfs.scheduled_flag = 1 AND
          wfs.status IN (1,2) AND
          NVL(wfs.date_closed, l_current_start_date) >= l_current_start_date))
      OR (we.entity_type =2 AND EXISTS (
        SELECT 'X'
        FROM wip_repetitive_schedules wrs
        WHERE
          wrs.wip_entity_id = wppb.wip_entity_id AND
          wrs.line_id = wppb.line_id AND
          NVL(wrs.date_closed, l_current_start_date) >= l_current_start_date)));


      ---------------------------------------
      -- Added R12 PAC enhancement
      ---------------------------------------
      l_stmt_num := 75;
      INSERT INTO CST_PAC_REQ_OPER_COST_DETAILS
       (pac_period_id,
        cost_group_id,
        wip_entity_id,
        line_id,
        inventory_item_id,
        cost_element_id,
        operation_seq_num,
        applied_value,
        applied_quantity,
        relieved_value,
        relieved_quantity,
        comp_variance,
        temp_relieved_value,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        request_id ,
        program_application_id,
        program_id,
        program_update_date,
        last_update_login)
        SELECT i_pac_period_id,
               wprocd.cost_group_id,
               wprocd.wip_entity_id,
               wprocd.line_id,
               wprocd.inventory_item_id,
               wprocd.cost_element_id,
               wprocd.operation_seq_num,
               wprocd.applied_value,
               wprocd.applied_quantity,
               wprocd.relieved_value,
               wprocd.relieved_quantity,
               wprocd.comp_variance,
               0,
               SYSDATE,
               i_user_id,
               SYSDATE,
               i_user_id,
               i_request_id,
               i_prog_app_id,
               i_prog_id,
               SYSDATE,
               i_login_id
        FROM   CST_PAC_REQ_OPER_COST_DETAILS wprocd,
               WIP_ENTITIES we
        WHERE  wprocd.pac_period_id = i_prior_pac_period_id
        AND    wprocd.cost_group_id = i_cost_group_id
        AND    wprocd.wip_entity_id = we.wip_entity_id
        AND (
             ( we.entity_type IN (1,3) AND EXISTS (
                SELECT 'X'
                FROM wip_discrete_jobs wdj
                WHERE
                  wdj.wip_entity_id = wprocd.wip_entity_id AND
                  NVL(wdj.date_closed, l_current_start_date) >= l_current_start_date))
                OR (we.entity_type = 2 AND EXISTS (
                SELECT 'X'
                FROM wip_repetitive_schedules wrs
                WHERE
                  wrs.wip_entity_id = wprocd.wip_entity_id AND
                  wrs.line_id = wprocd.line_id AND
                  NVL(wrs.date_closed, l_current_start_date) >= l_current_start_date)));


  END IF;

  EXCEPTION
    when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
    when OTHERS then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPFCHK.Copy_Prior_Info_Hook ('|| to_char(l_stmt_num) || '
): '
                || substr(SQLERRM,1,200);

END copy_prior_info_hook;

-- ===================================================
-- Periodic Cost Update invoked for Incremental LIFO
-- The procedure is a copy from BOM115100 inorder to
-- prevent regression.  The regression is due to
-- cppb insert/update introduced in R12 code
-- ===================================================
PROCEDURE periodic_cost_update_hook (
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
  O_Err_Msg             OUT NOCOPY     VARCHAR2)
IS
  l_update_flag		NUMBER;
  l_stmt_num		NUMBER;
  l_onhand              NUMBER := 0;
BEGIN

  /********************************************************************
   ** Insert into mpacd, all the elemental cost :                    **
   ** - exists in cpicd, but not exists in mptcd                     **
   ** It will use the current cost in cpicd as the new cost	     **
   ********************************************************************/
  l_stmt_num := 5;
  INSERT INTO mtl_pac_actual_cost_details (
        transaction_id,
        pac_period_id,
        cost_type_id,
        cost_group_id,
        cost_layer_id,
        cost_element_id,
        level_type,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        inventory_item_id,
        actual_cost,
        prior_cost,
        prior_buy_cost,
        prior_make_cost,
        new_cost,
        new_buy_cost,
        new_make_cost,
        variance_amount,
        insertion_flag,
        user_entered,
        transaction_costed_date,
	txn_category)
  SELECT
        i_txn_id,
        i_pac_period_id,
        i_cost_type_id,
        i_cost_group_id,
        i_cost_layer_id,
        cpicd.cost_element_id,
        cpicd.level_type,
        sysdate,
        i_user_id,
        sysdate,
        i_user_id,
        i_login_id,
        i_req_id,
        i_prg_appl_id,
        i_prg_id,
        sysdate,
        i_item_id,
        nvl(cpicd.item_cost,0),
        nvl(cpicd.item_cost,0),
        nvl(cpicd.item_buy_cost,0),
        nvl(cpicd.item_make_cost,0),
        nvl(cpicd.item_cost,0),
        nvl(cpicd.item_buy_cost,0),
        nvl(cpicd.item_make_cost,0),
        0,
        'Y',
        'N',
        NULL,
	i_txn_category
  FROM  cst_pac_item_cost_details cpicd
  WHERE cpicd.cost_layer_id  = i_cost_layer_id
    AND not exists (
        SELECT 'not exists in mptcd'
        FROM mtl_pac_txn_cost_details mptcd
        WHERE mptcd.transaction_id = i_txn_id
          AND mptcd.pac_period_id  = i_pac_period_id
          AND mptcd.cost_group_id  = i_cost_group_id
          AND mptcd.cost_element_id = cpicd.cost_element_id
          AND mptcd.level_type = cpicd.level_type);

  /********************************************************************
   ** Insert into mpacd, all the elemental cost :                    **
   ** - exists in mptcd and cpicd                                    **
   ** - exists in mptcd but not exists in cpicd                      **
   ** New cost will be calculated based on current cost (if exists)  **
   ** and cost change in mptcd. 				     **
   ********************************************************************/
  l_stmt_num := 10;
  INSERT INTO mtl_pac_actual_cost_details (
	transaction_id,
	pac_period_id,
	cost_type_id,
	cost_group_id,
	cost_layer_id,
	cost_element_id,
	level_type,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	inventory_item_id,
	actual_cost,
	prior_cost,
	prior_buy_cost,
	prior_make_cost,
	new_cost,
	new_buy_cost,
	new_make_cost,
        variance_amount,
	insertion_flag,
	user_entered,
	transaction_costed_date,
	txn_category,
	onhand_variance_amount)
  SELECT
	i_txn_id,
	i_pac_period_id,
	i_cost_type_id,
	i_cost_group_id,
	i_cost_layer_id,
      	mptcd.cost_element_id,
      	mptcd.level_type,
      	sysdate,
      	i_user_id,
      	sysdate,
      	i_user_id,
      	i_login_id,
      	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
      	mptcd.inventory_item_id,
      	decode(mptcd.new_periodic_cost,NULL,
             decode(mptcd.percentage_change,NULL,
                  /* value change formula */
                 decode(sign(cpql.layer_quantity),1,
		      decode(sign(i_txn_qty),1,
		       decode(sign(cpql.layer_quantity-i_txn_qty),-1,
                           decode(sign(nvl(cpicd.item_cost,0) * cpql.layer_quantity +
			               (mptcd.value_change/i_txn_qty*cpql.layer_quantity)),-1,
			      0,
			      (nvl(cpicd.item_cost,0)*nvl(cpql.layer_quantity,0) +
			       (mptcd.value_change/i_txn_qty*cpql.layer_quantity))/nvl(cpql.layer_quantity,-1)),
		         decode(sign(nvl(cpicd.item_cost,0) * cpql.layer_quantity + mptcd.value_change),-1,
			      0,
			      (nvl(cpicd.item_cost,0)*nvl(cpql.layer_quantity,0) +
			       mptcd.value_change)/nvl(cpql.layer_quantity,-1))),
     		         decode(sign(nvl(cpicd.item_cost,0) * cpql.layer_quantity + mptcd.value_change),-1,
			      0,
			      (nvl(cpicd.item_cost,0)*nvl(cpql.layer_quantity,0) +
			       mptcd.value_change)/nvl(cpql.layer_quantity,-1))),
		         nvl(cpicd.item_cost,0)),
                   /* percentage change formula */
                   nvl(cpicd.item_cost,0)*(1+mptcd.percentage_change/100)),
             /* new average cost formula */
             mptcd.new_periodic_cost),
      	nvl(cpicd.item_cost,0),
      	nvl(cpicd.item_buy_cost,0),
      	nvl(cpicd.item_make_cost,0),
      	decode(mptcd.new_periodic_cost,NULL,
             decode(mptcd.percentage_change,NULL,
                  /* value change formula */
                 decode(sign(cpql.layer_quantity),1,
		      decode(sign(i_txn_qty),1,
		       decode(sign(cpql.layer_quantity-i_txn_qty),-1,
                           decode(sign(nvl(cpicd.item_cost,0) * cpql.layer_quantity +
			               (mptcd.value_change/i_txn_qty*cpql.layer_quantity)),-1,
			      0,
			      (nvl(cpicd.item_cost,0)*nvl(cpql.layer_quantity,0) +
			       (mptcd.value_change/i_txn_qty*cpql.layer_quantity))/nvl(cpql.layer_quantity,-1)),
		         decode(sign(nvl(cpicd.item_cost,0) * cpql.layer_quantity + mptcd.value_change),-1,
			      0,
			      (nvl(cpicd.item_cost,0)*nvl(cpql.layer_quantity,0) +
			       mptcd.value_change)/nvl(cpql.layer_quantity,-1))),
     		         decode(sign(nvl(cpicd.item_cost,0) * cpql.layer_quantity + mptcd.value_change),-1,
			      0,
			      (nvl(cpicd.item_cost,0)*nvl(cpql.layer_quantity,0) +
			       mptcd.value_change)/nvl(cpql.layer_quantity,-1))),
		         nvl(cpicd.item_cost,0)),
                   /* percentage change formula */
                   nvl(cpicd.item_cost,0)*(1+mptcd.percentage_change/100)),
             /* new average cost formula */
             mptcd.new_periodic_cost),
      	nvl(cpicd.item_buy_cost,0),
      	nvl(cpicd.item_make_cost,0),
	decode(mptcd.value_change,NULL,
	     0,
	     decode(sign(cpql.layer_quantity),1,
	        decode(sign(i_txn_qty),1,
		 decode(sign(cpql.layer_quantity-i_txn_qty),-1,
  	          decode(sign(nvl(cpicd.item_cost,0) * cpql.layer_quantity + (mptcd.value_change/i_txn_qty*cpql.layer_quantity)),-1,
		       (mptcd.value_change/i_txn_qty*cpql.layer_quantity) + nvl(cpicd.item_cost,0) * cpql.layer_quantity,
		       0),
	          decode(sign(nvl(cpicd.item_cost,0) * cpql.layer_quantity + mptcd.value_change),-1,
		       mptcd.value_change + nvl(cpicd.item_cost,0) * cpql.layer_quantity,
		       0)),
       	          decode(sign(nvl(cpicd.item_cost,0) * cpql.layer_quantity + mptcd.value_change),-1,
		       mptcd.value_change + nvl(cpicd.item_cost,0) * cpql.layer_quantity,
		       0)),
		  mptcd.value_change)),
      	'Y',
      	'N',
	NULL,
	i_txn_category,
        decode(mptcd.value_change,NULL,
               0,
	       decode(sign(i_txn_qty),1,
	              decode(sign(cpql.layer_quantity),1,
		             decode(sign(cpql.layer_quantity-i_txn_qty),-1,
			            mptcd.value_change*(1-cpql.layer_quantity/i_txn_qty),
				    0
			            ),
			     0
		             ),
		      0
	              )
               )
  FROM  mtl_pac_txn_cost_details mptcd,
        cst_pac_item_cost_details cpicd,
        cst_pac_quantity_layers cpql
  WHERE mptcd.transaction_id = i_txn_id
    AND mptcd.pac_period_id  = i_pac_period_id
    AND mptcd.cost_group_id  = i_cost_group_id
    AND cpql.cost_layer_id = i_cost_layer_id
    AND cpql.quantity_layer_id = i_qty_layer_id
    AND cpicd.cost_layer_id (+) = i_cost_layer_id
    AND cpicd.cost_element_id (+) = mptcd.cost_element_id
    AND cpicd.level_type (+) = mptcd.level_type;

  l_stmt_num := 20;
  DELETE FROM cst_pac_item_cost_details
  WHERE cost_layer_id = i_cost_layer_id;

  l_stmt_num := 30;
  INSERT INTO cst_pac_item_cost_details(
        cost_layer_id,
        cost_element_id,
        level_type,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        item_cost,
        item_buy_cost,
        item_make_cost)
  SELECT i_cost_layer_id,
        mpacd.cost_element_id,
        mpacd.level_type,
        sysdate,
        i_user_id,
        sysdate,
        i_user_id,
        i_login_id,
        i_req_id,
        i_prg_appl_id,
        i_prg_id,
        sysdate,
        mpacd.new_cost,
        mpacd.new_buy_cost,
        mpacd.new_make_cost
  FROM  mtl_pac_actual_cost_details mpacd
  WHERE mpacd.transaction_id = i_txn_id
  AND   mpacd.cost_group_id = i_cost_group_id
  AND   mpacd.cost_layer_id = i_cost_layer_id
  AND   mpacd.insertion_flag = 'Y';

  /* It's flag to indicate if we need to update begin item cost with the new item cost */
  /* If the update type is NOT value_change, set the flag to 1 to indicate updating of begin */
  /* item cost with the new cost. Otherwise set it to 0 */
  l_stmt_num := 40;
  SELECT DECODE(MAX(value_change),NULL, 1, 0)
  INTO l_update_flag
  FROM mtl_pac_txn_cost_details mptcd
  WHERE mptcd.transaction_id = i_txn_id
    AND mptcd.pac_period_id  = i_pac_period_id
    AND mptcd.cost_group_id  = i_cost_group_id;

  l_stmt_num := 50;
  UPDATE cst_pac_item_costs cpic
  SET (last_updated_by,
	last_update_date,
	last_update_login,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	pl_material,
	pl_material_overhead,
	pl_resource,
	pl_outside_processing,
	pl_overhead,
	tl_material,
	tl_material_overhead,
	tl_resource,
	tl_outside_processing,
	tl_overhead,
	material_cost,
	material_overhead_cost,
	resource_cost,
	outside_processing_cost,
	overhead_cost,
	pl_item_cost,
	tl_item_cost,
	item_cost,
        begin_item_cost,
	item_buy_cost,
	item_make_cost,
	unburdened_cost,
	burden_cost) =
     (SELECT
        i_user_id,
        sysdate,
        i_login_id,
	i_req_id,
      	i_prg_appl_id,
      	i_prg_id,
      	sysdate,
	SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,1,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,2,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,3,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,4,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,5,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,1,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,2,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,3,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,4,ITEM_COST,0),0)),
	SUM(DECODE(LEVEL_TYPE,1,DECODE(COST_ELEMENT_ID,5,ITEM_COST,0),0)),
	SUM(DECODE(COST_ELEMENT_ID,1,ITEM_COST,0)),
	SUM(DECODE(COST_ELEMENT_ID,2,ITEM_COST,0)),
	SUM(DECODE(COST_ELEMENT_ID,3,ITEM_COST,0)),
	SUM(DECODE(COST_ELEMENT_ID,4,ITEM_COST,0)),
	SUM(DECODE(COST_ELEMENT_ID,5,ITEM_COST,0)),
	SUM(DECODE(LEVEL_TYPE,2,ITEM_COST,0)),
	SUM(DECODE(LEVEL_TYPE,1,ITEM_COST,0)),
	SUM(ITEM_COST),
        DECODE(l_update_flag, 1, SUM(ITEM_COST), cpic.begin_item_cost),
	SUM(ITEM_BUY_COST),
	SUM(ITEM_MAKE_COST),
	SUM(DECODE(COST_ELEMENT_ID,2,DECODE(LEVEL_TYPE,2,ITEM_COST,0),ITEM_COST)),
	SUM(DECODE(COST_ELEMENT_ID,2,DECODE(LEVEL_TYPE,1,ITEM_COST,0),0))
      FROM  CST_PAC_ITEM_COST_DETAILS v
      WHERE v.cost_layer_id = i_cost_layer_id
      GROUP BY COST_LAYER_ID)
  WHERE cpic.cost_layer_id = i_cost_layer_id
  AND EXISTS
	(SELECT 'there is detail cost'
	 FROM   cst_pac_item_cost_details cpicd
	 WHERE  cpicd.cost_layer_id = i_cost_layer_id);

/* Fix for Bug 1970458
 * For a value change periodic update cost transaction,
 * update the primary_quantity in mmt to the layer quantity from cpql.
 * Prior to this, the quantity at the beginning of the period was being
 * used and this caused errors in the distributions.
 * The layer qty can be obtained from cst_pac_quantity_layers
 */

  l_stmt_num := 60;

    select nvl(layer_quantity,0)
    into l_onhand
    from cst_pac_quantity_layers
    where cost_group_id = i_cost_group_id and
    pac_period_id = i_pac_period_id and
    inventory_item_id = i_item_id;

    UPDATE mtl_material_transactions mmt
    SET --primary_quantity  = l_onhand,
        /* Bug 2288994. Update periodic_primary_quantity also */
        periodic_primary_quantity = l_onhand
    WHERE mmt.transaction_id = i_txn_id;
    fnd_file.put_line(fnd_file.log,'Updated MMT with primary_quantity: ' || to_char(l_onhand));


  EXCEPTION
    when OTHERS then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPPWAC.Periodic_Cost_Update (' || to_char(l_stmt_num) || '): '
		|| substr(SQLERRM,1,200);

END periodic_cost_update_hook;


END CSTPFCHK;

/
