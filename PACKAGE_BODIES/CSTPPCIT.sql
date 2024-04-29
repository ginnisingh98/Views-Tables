--------------------------------------------------------
--  DDL for Package Body CSTPPCIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPCIT" AS
/* $Header: CSTPCITB.pls 115.4 2002/11/09 00:40:41 awwang ship $ */

PROCEDURE periodic_cost_validate (
  i_org_cost_group_id	    in number,
  i_cost_type_id            in number,
  i_transaction_date        in date,
  i_txn_interface_id        in number,
  i_org_id		    in number,
  i_item_id		    in number,
  i_new_avg_cost	    in number,
  i_per_change		    in number,
  i_val_change		    in number,
  i_mat_accnt		    in number,
  i_mat_ovhd_accnt	    in number,
  i_res_accnt		    in number,
  i_osp_accnt		    in number,
  i_ovhd_accnt		    in number,
  o_err_num                 out NOCOPY number,
  o_err_code		    out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
) IS
  l_err_num                 number;
  l_err_code                varchar2(240);
  l_err_msg                 varchar2(240);
  process_error   	    EXCEPTION;
  l_count		    number;
  l_master_org_id	    number;
  l_legal_entity	    number;
  l_sob_id		    number;
  l_chart_account_id	    number;
  l_period_set_name         varchar2(15);
  l_period_type             varchar2(15);
  l_period_id               number;
  l_open_flag               varchar2(1);
  l_num_details             number;
  l_sum_value_change        number;
  l_sum_new_cost            number;
  l_stmt_num		    number;

BEGIN
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  l_stmt_num := 10;
  /* Validate org_cost_group_id */
  l_count := 0;
  SELECT count(*)
  INTO l_count
  FROM CST_COST_GROUPS
  WHERE cost_group_id = i_org_cost_group_id
    AND TRUNC(NVL(disable_date, sysdate)) >= TRUNC(sysdate)
    AND cost_group_type = 2;

  IF (l_count = 0) THEN
    l_err_num := 999;
    l_err_code := 'CST_PAC_CG_INVALID';
    FND_MESSAGE.set_name('BOM', 'CST_PAC_CG_INVALID');
    l_err_msg := FND_MESSAGE.Get;
    raise process_error;
  END IF;

  l_stmt_num := 20;
  /* Find the master org id and legal_entity for the cost group */
  SELECT legal_entity, organization_id
  INTO l_legal_entity, l_master_org_id
  FROM CST_COST_GROUPS
  WHERE cost_group_id = i_org_cost_group_id;

  l_stmt_num := 30;
  /* Validate cost_type_id */
  l_count := 0;
  SELECT count(*)
  INTO l_count
  FROM CST_LE_COST_TYPES
  WHERE legal_entity = l_legal_entity
    AND cost_type_id = i_cost_type_id;

  IF (l_count = 0) THEN
    l_err_num := 999;
    l_err_code := 'CST_PAC_CT_INVALID';
    FND_MESSAGE.set_name('BOM', 'CST_PAC_CT_INVALID');
    l_err_msg := FND_MESSAGE.Get;
    raise process_error;
  END IF;

  l_stmt_num := 40;
  /* Get set_of_books_id ,chart_of_accounts_id,
     period_set_name and chart_of_accounts_id */
  SELECT gl.set_of_books_id, gl.chart_of_accounts_id,
         gl.period_set_name, gl.accounted_period_type
  INTO l_sob_id, l_chart_account_id,
       l_period_set_name, l_period_type
  FROM CST_LE_COST_TYPES clct, GL_SETS_OF_BOOKS gl
  WHERE clct.set_of_books_id = gl.set_of_books_id
    AND clct.legal_entity = l_legal_entity
    AND cost_type_id = i_cost_type_id;

  l_stmt_num := 50;
  /* Validate organization_id */
  l_count := 0;
  SELECT count(*)
  INTO l_count
  FROM MTL_PARAMETERS
  WHERE organization_id = i_org_id
    AND master_organization_id = i_org_id
    AND i_org_id = l_master_org_id;

  IF (l_count = 0) THEN
    l_err_num := 999;
    l_err_code := 'CST_NO_TXN_INVALID_ORG';
    FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_ORG');
    l_err_msg := FND_MESSAGE.Get;
    raise process_error;
  END IF;

  l_stmt_num := 60;
  /* Validate transaction_date */
  SELECT NVL(MAX(pac_period_id),-1)
  INTO l_period_id
  FROM CST_PAC_PERIODS
  WHERE legal_entity = l_legal_entity
    AND cost_type_id = i_cost_type_id
    AND i_transaction_date between period_start_date and period_end_date;

  IF (l_period_id <> -1) THEN
    l_stmt_num := 70;
    SELECT decode(open_flag,'Y',decode(period_close_date,NULL,'Y','N'),'N')
    INTO l_open_flag
    FROM CST_PAC_PERIODS
    WHERE pac_period_id = l_period_id;

    IF (l_open_flag = 'N') THEN
      l_err_num := 999;
      l_err_code := 'CST_PAC_CLOSE_PERIOD';
      FND_MESSAGE.set_name('BOM', 'CST_PAC_CLOSE_PERIOD');
      l_err_msg := FND_MESSAGE.Get;
      raise process_error;
    END IF;
  END IF;

  l_stmt_num := 80;
  l_count := 0;
  SELECT count(*)
  INTO l_count
  FROM GL_PERIODS
  WHERE period_set_name = l_period_set_name
    AND period_type = l_period_type
    AND i_transaction_date between start_date and end_date;

  IF (l_count = 0) THEN
    l_err_num := 999;
    l_err_code := 'CST_PAC_TXN_DATE_INVALID';
    FND_MESSAGE.set_name('BOM', 'CST_PAC_TXN_DATE_INVALID');
    l_err_msg := FND_MESSAGE.Get;
    raise process_error;
  END IF;


  l_stmt_num := 90;
  /* Validate that all accounts do exists in given chart of accounts. */
  l_count := 0;
  IF (i_mat_accnt IS NOT NULL) THEN
    l_count := l_count + validate_account(i_mat_accnt,l_chart_account_id);
  END IF;
  IF (i_mat_ovhd_accnt IS NOT NULL) THEN
    l_count := l_count + validate_account(i_mat_ovhd_accnt,l_chart_account_id);
  END IF;
  IF (i_res_accnt IS NOT NULL) THEN
    l_count := l_count + validate_account(i_res_accnt,l_chart_account_id);
  END IF;
  IF (i_osp_accnt IS NOT NULL) THEN
    l_count := l_count + validate_account(i_osp_accnt,l_chart_account_id);
  END IF;
  IF (i_ovhd_accnt IS NOT NULL) THEN
    l_count := l_count + validate_account(i_ovhd_accnt,l_chart_account_id);
  END IF;
  IF (l_count > 0) THEN
    l_err_num := 999;
    l_err_code := 'CST_NO_TXN_INVALID_ACCOUNT';
    FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_ACCOUNT');
    l_err_msg := FND_MESSAGE.Get;
    raise process_error;
  END IF;

  /* Validate the consistency of data
     The following must be true for periodic cost update :
     - Among new_cost, value change, percentage change column on the mti,
       the user can only enter it one. Also can't have null value
     - The same is true in detail.
     - The sum of new_cost in mtcdi must be the same with one in mti.
       New cost must be >= 0
     - The sum of value change in mtcdi must be the same with one in mti.
     - Percentage change >= -100
  */
  l_stmt_num := 100;
  SELECT count(*)
  INTO l_num_details
  FROM MTL_TXN_COST_DET_INTERFACE
  WHERE TRANSACTION_INTERFACE_ID = i_txn_interface_id;

  IF ( i_new_avg_cost IS NOT NULL AND i_per_change IS NULL AND i_val_change IS NULL ) THEN
    l_stmt_num := 110;
    l_count := 0;
    SELECT count(*), SUM(new_average_cost)
    INTO l_count, l_sum_new_cost
    FROM MTL_TXN_COST_DET_INTERFACE
    WHERE TRANSACTION_INTERFACE_ID = i_txn_interface_id AND NVL(new_average_cost,-1) >= 0
      AND percentage_change IS NULL AND value_change IS NULL;
    IF (l_count <> l_num_details OR l_sum_new_cost <> i_new_avg_cost) THEN
      l_err_num := 999;
      l_err_code := 'CST_NO_TXN_INVALID_COST_CHANGE';
      FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_COST_CHANGE');
      l_err_msg := FND_MESSAGE.Get;
      raise process_error;
    END IF;
  ELSIF ( i_new_avg_cost IS NULL AND i_per_change IS NOT NULL AND i_val_change IS NULL ) THEN
    l_stmt_num := 120;
    l_count := 0;
    SELECT count(*)
    INTO l_count
    FROM MTL_TXN_COST_DET_INTERFACE
    WHERE TRANSACTION_INTERFACE_ID = i_txn_interface_id AND new_average_cost IS NULL
      AND NVL(percentage_change,-999) >= -100 AND value_change IS NULL;
    IF (l_count <> l_num_details) THEN
      l_err_num := 999;
      l_err_code := 'CST_NO_TXN_INVALID_COST_CHANGE';
      FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_COST_CHANGE');
      l_err_msg := FND_MESSAGE.Get;
      raise process_error;
    END IF;
  ELSIF ( i_new_avg_cost IS NULL AND i_per_change IS NULL AND i_val_change IS NOT NULL ) THEN
    l_stmt_num := 130;
    l_count := 0;
    SELECT count(*), SUM(value_change)
    INTO l_count, l_sum_value_change
    FROM MTL_TXN_COST_DET_INTERFACE
    WHERE TRANSACTION_INTERFACE_ID = i_txn_interface_id AND new_average_cost IS NULL
      AND percentage_change IS NULL AND value_change IS NOT NULL;
    IF (l_count <> l_num_details OR l_sum_value_change <> i_val_change) THEN
      l_err_num := 999;
      l_err_code := 'CST_NO_TXN_INVALID_COST_CHANGE';
      FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_COST_CHANGE');
      l_err_msg := FND_MESSAGE.Get;
      raise process_error;
    END IF;
  ELSE
    l_err_num := 999;
    l_err_code := 'CST_NO_TXN_INVALID_COST_CHANGE';
    FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_COST_CHANGE');
    l_err_msg := FND_MESSAGE.Get;
    raise process_error;
  END IF;

  l_stmt_num := 140;
  CSTPACIT.cost_det_validate(i_txn_interface_id, i_org_id, i_item_id,
                    i_new_avg_cost,
		    i_per_change, i_val_change, i_mat_accnt, i_mat_ovhd_accnt,
                    i_res_accnt, i_osp_accnt, i_ovhd_accnt,
                    l_err_num, l_err_code, l_err_msg);
  IF (l_err_num <> 0) THEN
    raise process_error;
  END IF;

EXCEPTION
  WHEN process_error THEN
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPPCIT.PERIODIC_COST_VALIDATE:' || l_err_msg;
  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPCIT.PERIODIC_COST_VALIDATE: (' || to_char(l_stmt_num)
                || '): ' || substr(SQLERRM,1,150);

END periodic_cost_validate;




FUNCTION validate_account(
  i_accnt		in number,
  i_chart_of_accounts	in number)
RETURN number
IS
  l_count		number;
BEGIN
  l_count := 0;

  SELECT count(*)
  INTO l_count
  FROM GL_CODE_COMBINATIONS
  WHERE code_combination_id = i_accnt
    AND chart_of_accounts_id = i_chart_of_accounts;

  IF (l_count = 1) THEN
    return 0;	/* Means the account does exists and valid */
  ELSE
    return 1;	/* Means the account doesn't exists or invalid */
  END IF;


END validate_account;

PROCEDURE periodic_cost_det_move (
  i_cost_type_id	    in number,
  i_transaction_date        in date,
  i_txn_id                  in number,
  i_txn_interface_id        in number,
  i_txn_action_id	    in number,
  i_org_id	            in number,
  i_item_id		    in number,
  i_org_cost_group_id	    in number,
  i_txn_cost		    in number,
  i_new_avg_cost	    in number,
  i_per_change		    in number,
  i_val_change		    in number,
  i_mat_accnt		    in number,
  i_mat_ovhd_accnt	    in number,
  i_res_accnt		    in number,
  i_osp_accnt		    in number,
  i_ovhd_accnt		    in number,
  i_user_id                 in number,
  i_login_id                in number,
  i_request_id              in number,
  i_prog_appl_id            in number,
  i_prog_id                 in number,
  o_err_num                 out NOCOPY number,
  o_err_code		    out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
) IS
  l_err_num                 number;
  l_err_code                varchar2(240);
  l_err_msg                 varchar2(240);
  l_num_detail              number;
  l_legal_entity	    number;
  l_pac_period_id	    number;
  process_error       	    EXCEPTION;
BEGIN
  /*
  ** initialize local variables
  */
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';


  SELECT count(*)
  INTO   l_num_detail
  FROM   MTL_TXN_COST_DET_INTERFACE
  WHERE  TRANSACTION_INTERFACE_ID = i_txn_interface_id;

  SELECT legal_entity
  INTO l_legal_entity
  FROM CST_COST_GROUPS
  WHERE cost_group_id = i_org_cost_group_id;

  SELECT NVL(MAX(pac_period_id),-1)
  INTO l_pac_period_id
  FROM CST_PAC_PERIODS
  WHERE cost_type_id = i_cost_type_id
    AND legal_entity = l_legal_entity
    AND i_transaction_date between period_start_date and period_end_date;

  /*  l_num_detail = 0	: No corresponding rows in MTL_TXN_COST_DET_INTERFACE
   *			  OR i_txn_interface_id is null.
   *  In this case, call cstpacit.cost_det_new_insert.
   */

  IF (l_num_detail = 0) THEN
    cstppcit.periodic_cost_det_new_insert(l_pac_period_id, l_legal_entity,
                                 i_cost_type_id,
                                 i_txn_id, i_txn_action_id, i_org_id,
				 i_item_id, i_org_cost_group_id, i_txn_cost,
				 i_new_avg_cost, i_per_change, i_val_change,
				 i_mat_accnt, i_mat_ovhd_accnt, i_res_accnt,
				 i_osp_accnt, i_ovhd_accnt,
				 i_user_id, i_login_id, i_request_id,
				 i_prog_appl_id, i_prog_id,
				 l_err_num, l_err_code, l_err_msg);
    IF (l_err_num <> 0) THEN
	RAISE process_error;
    END IF;

  ELSE
    INSERT INTO MTL_PAC_TXN_COST_DETAILS (
      pac_period_id,
      cost_group_id,
      cost_type_id,
      transaction_id,
      inventory_item_id,
      cost_element_id,
      level_type,
      transaction_cost,
      new_periodic_cost,
      percentage_change,
      value_change,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    ) SELECT
      l_pac_period_id,
      i_org_cost_group_id,
      i_cost_type_id,
      i_txn_id,
      i_item_id,
      cost_element_id,
      level_type,
      transaction_cost,
      new_average_cost,
      percentage_change,
      value_change,
      sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_appl_id,
      i_prog_id,
      sysdate
    FROM MTL_TXN_COST_DET_INTERFACE
    WHERE TRANSACTION_INTERFACE_ID = i_txn_interface_id;

  END IF;

EXCEPTION
  WHEN process_error THEN
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPPCIT.PERIODIC_COST_DET_MOVE:' || l_err_msg;
  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPCIT.PERIODIC_COST_DET_MOVE:' || substr(SQLERRM,1,150);

END periodic_cost_det_move;




PROCEDURE periodic_cost_det_new_insert (
  i_pac_period_id           in number,
  i_legal_entity            in number,
  i_cost_type_id            in number,
  i_txn_id                  in number,
  i_txn_action_id           in number,
  i_org_id	            in number,
  i_item_id		    in number,
  i_org_cost_group_id	    in number,
  i_txn_cost		    in number,
  i_new_avg_cost	    in number,
  i_per_change		    in number,
  i_val_change		    in number,
  i_mat_accnt		    in number,
  i_mat_ovhd_accnt	    in number,
  i_res_accnt		    in number,
  i_osp_accnt		    in number,
  i_ovhd_accnt		    in number,
  i_user_id                 in number,
  i_login_id                in number,
  i_request_id              in number,
  i_prog_appl_id            in number,
  i_prog_id                 in number,
  o_err_num                 out NOCOPY number,
  o_err_code		    out NOCOPY varchar2,
  o_err_msg                 out NOCOPY varchar2
) IS
  l_err_num                 number;
  l_err_code                varchar2(240);
  l_err_msg                 varchar2(240);
  l_prior_close_period_id   number;
  l_item_cost		    number;
  cost_element_count	    number;
  l_cost_layer_id	    number;
  l_qty_layer_id	    number;
  process_error 	    EXCEPTION;


  CURSOR cost_element_cursor (l_layer_id number) IS
    SELECT cpicd.cost_element_id
    FROM   CST_PAC_ITEM_COST_DETAILS cpicd
    WHERE  cpicd.cost_layer_id = l_layer_id;


BEGIN
  /*
  ** initialize local variables
  */
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';
  l_cost_layer_id := 0;
  l_qty_layer_id  := 0;
  cost_element_count := 0;

  /* Find last close period */
  SELECT NVL(MAX(pac_period_id), -1)
  INTO l_prior_close_period_id
  FROM CST_PAC_PERIODS
  WHERE cost_type_id = i_cost_type_id AND legal_entity = i_legal_entity
    AND open_flag = 'N' AND period_close_date IS NOT NULL;

  IF (l_prior_close_period_id <> -1) THEN
    CSTPPCLM.layer_id (l_prior_close_period_id, i_legal_entity,
                       i_item_id, i_org_cost_group_id, l_cost_layer_id,
                       l_qty_layer_id, l_err_num, l_err_code, l_err_msg);
    IF (l_err_num <> 0) THEN
      raise process_error;
    END IF;
  END IF;


  /*  If layer detail exist for that item, then calculate proportional costs and
   *  insert each elements into MTL_PAC_TXN_COST_DETAILS.
   */

  IF (l_cost_layer_id <> 0) THEN

    FOR l_cost_element IN cost_element_cursor(l_cost_layer_id) LOOP

      IF ((l_cost_element.cost_element_id = 1 AND i_mat_accnt IS NULL) OR
          (l_cost_element.cost_element_id = 2 AND i_mat_ovhd_accnt IS NULL) OR
          (l_cost_element.cost_element_id = 3 AND i_res_accnt IS NULL) OR
          (l_cost_element.cost_element_id = 4 AND i_osp_accnt IS NULL) OR
          (l_cost_element.cost_element_id = 5 AND i_ovhd_accnt IS NULL)) THEN
        -- Error occured

        FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_ACCOUNT');
        l_err_num := 999;
        l_err_code := 'Invalid accounts.';
        l_err_msg := FND_MESSAGE.Get;

        RAISE process_error;
      END IF;

    END LOOP;

    SELECT item_cost
    INTO l_item_cost
    FROM CST_PAC_ITEM_COSTS
    WHERE cost_layer_id = l_cost_layer_id;

    /* for the case of item cost equal zero */
    /* split cost evenly among cost elements */

    IF (l_item_cost = 0) THEN
      SELECT count(cost_element_id)
      INTO cost_element_count
      FROM CST_PAC_ITEM_COST_DETAILS
      WHERE cost_layer_id = l_cost_layer_id;
    END IF;

    INSERT INTO MTL_PAC_TXN_COST_DETAILS (
      pac_period_id,
      cost_group_id,
      cost_type_id,
      transaction_id,
      inventory_item_id,
      cost_element_id,
      level_type,
      transaction_cost,
      new_periodic_cost,
      percentage_change,
      value_change,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
      )
    SELECT
      i_pac_period_id,
      i_org_cost_group_id,
      i_cost_type_id,
      i_txn_id,
      i_item_id,
      cost_element_id,
      level_type,
      DECODE(l_item_cost, 0, i_txn_cost/cost_element_count,
                             i_txn_cost * item_cost/l_item_cost),
      DECODE(l_item_cost, 0, i_new_avg_cost/cost_element_count,
                             i_new_avg_cost * item_cost/l_item_cost),
      i_per_change,
      DECODE(l_item_cost, 0, i_val_change/cost_element_count,
                             i_val_change * item_cost/l_item_cost),
      sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_appl_id,
      i_prog_id,
      sysdate
    FROM CST_PAC_ITEM_COST_DETAILS
    WHERE cost_layer_id = l_cost_layer_id;

  /*  If layer detail does not exist, then insert a new row
   *  as a this level material.
   */
  ELSE

    IF (i_mat_accnt is null) THEN
      FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_ACCOUNT');
      l_err_num := 999;
      l_err_code := 'Invalid accounts.';
      l_err_msg := FND_MESSAGE.Get;

      RAISE process_error;
    END IF;

    INSERT INTO MTL_PAC_TXN_COST_DETAILS (
      pac_period_id,
      cost_group_id,
      cost_type_id,
      transaction_id,
      inventory_item_id,
      cost_element_id,
      level_type,
      transaction_cost,
      new_periodic_cost,
      percentage_change,
      value_change,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
      )
    VALUES (
      i_pac_period_id,
      i_org_cost_group_id,
      i_cost_type_id,
      i_txn_id,
      i_item_id,
      1,
      1,
      i_txn_cost,
      i_new_avg_cost,
      i_per_change,
      i_val_change,
      sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_appl_id,
      i_prog_id,
      sysdate);

  END IF;

EXCEPTION
  WHEN process_error THEN
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPPCIT.PERIODIC_COST_DET_NEW_INSERT:' || l_err_msg;
  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPPCIT.PERIODIC_COST_DET_NEW_INSERT:' ||
                 substr(SQLERRM,1,150);

END periodic_cost_det_new_insert;

END cstppcit;

/
