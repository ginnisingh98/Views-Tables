--------------------------------------------------------
--  DDL for Package Body CSTPLCIR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPLCIR" AS
/* $Header: CSTLCIRB.pls 115.9 2004/06/18 17:04:13 rzhu ship $ */



PROCEDURE component_issue (
  i_cost_method_id      IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_layer_id            IN      NUMBER,
  i_inv_item_id         IN      NUMBER,
  i_org_id              IN      NUMBER,
  i_wip_entity_id       IN      NUMBER,
  i_txn_qty             IN      NUMBER,
  i_op_seq_num          IN      NUMBER,
  i_cost_type_id        IN      NUMBER,
  i_exp_flag            IN      NUMBER,
  i_user_id             IN      NUMBER,
  i_login_id            IN      NUMBER,
  i_request_id          IN      NUMBER,
  i_prog_id             IN      NUMBER,
  i_prog_appl_id        IN      NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_msg             OUT NOCOPY     VARCHAR2
)
IS

  l_stmt_num        NUMBER := 0;

  CURSOR layer_qty_cursor IS
    select
      MCLACD.inv_layer_id          inv_layer_id,
      min( MCLACD.layer_quantity ) layer_quantity
    from
      mtl_cst_layer_act_cost_details MCLACD
    where
      MCLACD.transaction_id = i_txn_id
    group by
      MCLACD.inv_layer_id;


  l_layer_qty_table CSTPLMWI.LayerQtyRecTable;

  l_wip_layer_id    NUMBER;

  l_err_code        VARCHAR2(2000);
  l_cost_hook_used  NUMBER(15);
  l_total_txn_qty NUMBER;

  bad_inv_consume_exception EXCEPTION;

  l_item_exp_flag   NUMBER;

BEGIN

  /* i_txn_qty < 0 for regular component issues */

  l_stmt_num := 5;
  select decode(inventory_asset_flag,'Y', 0, 1)
  into l_item_exp_flag
  from mtl_system_items
  where inventory_item_id = i_inv_item_id
    and organization_id = i_org_id;

  l_stmt_num := 10;

  -- This is a weird place to call the Actual Cost Hook.
  -- But, INV's consume_create_layers() functions expects
  -- it to be called first, so need to call it here.

  l_cost_hook_used := CSTPACHK.actual_cost_hook
  (
    I_ORG_ID      => i_org_id,
    I_TXN_ID      => i_txn_id,
    I_LAYER_ID    => i_layer_id,
    I_COST_TYPE   => i_cost_type_id,
    I_COST_METHOD => i_cost_method_id,
    I_USER_ID     => i_user_id,
    I_LOGIN_ID    => i_login_id,
    I_REQ_ID      => i_request_id,
    I_PRG_APPL_ID => i_prog_appl_id,
    I_PRG_ID      => i_prog_id,
    O_Err_Num     => o_err_num,
    O_Err_Code    => l_err_code,
    O_Err_Msg     => o_err_msg
  );


  IF o_err_num <> 0 THEN
    RETURN;
  END IF;


  l_stmt_num := 20;

  -- Consume INV layers
  CSTPLENG.consume_create_layers
  (
    i_org_id                => i_org_id,
    i_txn_id                => i_txn_id,
    i_layer_id              => i_layer_id,
    i_cost_hook             => l_cost_hook_used,
    i_item_id               => i_inv_item_id,
    i_txn_qty               => i_txn_qty,
    i_cost_method           => i_cost_method_id,
    i_txn_src_type          => 5,
    i_txn_action_id         => 1,
    i_interorg_rec          => null,
    i_cost_type             => i_cost_type_id,
    i_mat_ct_id             => null,
    i_avg_rates_id          => null,
    i_exp_flag              => i_exp_flag,
    i_user_id               => i_user_id,
    i_login_id              => i_login_id,
    i_req_id                => i_request_id,
    i_prg_appl_id           => i_prog_appl_id,
    i_prg_id                => i_prog_id,
    o_err_num               => o_err_num,
    o_err_code              => l_err_code,
    o_err_msg               => o_err_msg
  );

  IF o_err_num <> 0 THEN
    RETURN;
  END if;


  IF(l_item_exp_flag = 1) THEN
  /* Expense Item */

    l_stmt_num := 25;
    l_layer_qty_table := CSTPLMWI.LayerQtyRecTable();
    l_layer_qty_table.EXTEND;
    l_layer_qty_table( l_layer_qty_table.FIRST ).layer_id := -1;
    l_layer_qty_table( l_layer_qty_table.FIRST ).layer_qty := -1 * i_txn_qty;
/*
Need to create WIP layers to match WRO; used -1 for INV layer ID
   update wip_req_operation_cost_details WROCD
   set    applied_matl_value = 0
   where
     WROCD.wip_entity_id     = i_wip_entity_id and
     WROCD.operation_seq_num = i_op_seq_num and
     WROCD.inventory_item_id = i_inv_item_id;
   return;
*/
  ELSE
  /* Asset Item */
  -- populate the layer_qty_table from MCLACD

    l_stmt_num := 30;
    l_total_txn_qty := 0;
    l_layer_qty_table := CSTPLMWI.LayerQtyRecTable();
    FOR l_layer_qty_rec in layer_qty_cursor LOOP
      l_layer_qty_table.EXTEND;

      l_layer_qty_table( l_layer_qty_table.LAST ).layer_id  :=
        l_layer_qty_rec.inv_layer_id;

      -- this needs sign reversal because INV is now storing
      -- consumed quantities as negative
      l_layer_qty_table( l_layer_qty_table.LAST ).layer_qty :=
        -l_layer_qty_rec.layer_quantity;

      l_total_txn_qty := l_total_txn_qty + l_layer_qty_rec.layer_quantity;
    END LOOP;

    IF l_total_txn_qty <> i_txn_qty THEN
      RAISE bad_inv_consume_exception;
    END IF;

  end if; /* l_exp_item_flag */


  l_stmt_num := 40;

  l_wip_layer_id := CSTPLMWI.wip_layer_create
  (
    i_wip_entity_id,
    i_op_seq_num,
    i_inv_item_id,
    i_txn_id,
    l_layer_qty_table,
    i_user_id,
    i_login_id,
    i_request_id,
    i_prog_id,
    i_prog_appl_id,
    o_err_num,
    o_err_msg
  );

  IF o_err_num <> 0 THEN
    RETURN;
  END if;

  if (l_item_exp_flag <> 1) then

    -- insert into WROCD if not already there
    l_stmt_num := 50;

    CSTPLMWI.init_wip_layers
    (
      i_wip_entity_id,
      i_op_seq_num,
      i_inv_item_id,
      i_org_id,
      i_txn_id,
      i_layer_id,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_id,
      i_prog_appl_id,
      o_err_num,
      o_err_msg
    );
    IF o_err_num <> 0 THEN
      RETURN;
    END IF;


    -- update WROCD.applied_matl_value
    l_stmt_num := 60;

    update wip_req_operation_cost_details WROCD
    set    applied_matl_value
    =
    (
      select
        WROCD.applied_matl_value +
          sum( CWL.applied_matl_qty * CWLCD.layer_cost )
      from
        cst_wip_layers CWL,
        cst_wip_layer_cost_details CWLCD
      where
        CWL.wip_layer_id      = l_wip_layer_id        and
        CWLCD.wip_layer_id    = CWL.wip_layer_id      and
        CWLCD.inv_layer_id    = CWL.inv_layer_id      and
        CWLCD.cost_element_id = WROCD.cost_element_id and
        CWLCD.level_type in (1, 2)
    )
    where
      WROCD.wip_entity_id     = i_wip_entity_id and
      WROCD.operation_seq_num = i_op_seq_num and
      WROCD.inventory_item_id = i_inv_item_id;

  end if;


EXCEPTION
  WHEN bad_inv_consume_exception THEN
    o_err_num := 1007;
    o_err_msg := 'CSTPLCIR.component_issue():' ||
                 to_char(l_stmt_num) || ':' ||
                 'Inventory total txn qty was ' || l_total_txn_qty || '; ' ||
                 ' expected ' || i_txn_qty;

  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPLCIR.component_issue():' ||
                 to_char(l_stmt_num) || ':' ||
                 substr(SQLERRM,1,150);

END component_issue;






PROCEDURE component_return (
  i_cost_method_id      IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_layer_id            IN      NUMBER,
  i_inv_item_id         IN      NUMBER,
  i_org_id              IN      NUMBER,
  i_wip_entity_id       IN      NUMBER,
  i_txn_qty             IN      NUMBER,
  i_op_seq_num          IN      NUMBER,
  i_user_id             IN      NUMBER,
  i_login_id            IN      NUMBER,
  i_request_id          IN      NUMBER,
  i_prog_id             IN      NUMBER,
  i_prog_appl_id        IN      NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_msg             OUT NOCOPY     VARCHAR2
)
IS

  l_stmt_num          NUMBER := 0;

  l_sql_stmt          VARCHAR2(8000);
  l_layer_cursor      CSTPLMWI.REF_CURSOR_TYPE;
  l_layer             cst_wip_layers%ROWTYPE;

  l_txn_qty_remaining NUMBER;
  l_consumed_qty      NUMBER;

  /* EAM Acct Enh Project */
  l_debug           VARCHAR2(80);
  l_zero_cost_flag	NUMBER := -1;
  l_return_status	VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count		NUMBER := 0;
  l_msg_data            VARCHAR2(8000) := '';
  l_api_message		VARCHAR2(8000);

BEGIN

  l_stmt_num := 20;
  CSTPLMWI.init_wip_layers
  (
    i_wip_entity_id,
    i_op_seq_num,
    i_inv_item_id,
    i_org_id,
    i_txn_id,
    i_layer_id,
    i_user_id,
    i_login_id,
    i_request_id,
    i_prog_id,
    i_prog_appl_id,
    o_err_num,
    o_err_msg
  );
  IF o_err_num <> 0 THEN
    RETURN;
  END IF;



  -- component returns consume WIP layer(s) in reverse
  l_stmt_num := 30;
  l_sql_stmt := CSTPLMWI.wip_layer_consume_sql
                (
                  ' ( CWL.applied_matl_qty -                 ' ||
                  '   CWL.relieved_matl_comp_qty -           ' ||
                  '   CWL.relieved_matl_scrap_qty -          ' ||
                  '   CWL.relieved_matl_final_comp_qty ) > 0 ',
                  i_cost_method_id,
                  CSTPLMWI.REVERSE
                );

  l_stmt_num := 40;
  open l_layer_cursor for l_sql_stmt
  using i_wip_entity_id, i_op_seq_num, i_inv_item_id;

  l_txn_qty_remaining := nvl( i_txn_qty, 0 );

  l_stmt_num := 50;
  LOOP
    exit when l_txn_qty_remaining = 0;

    l_stmt_num := 60;
    fetch l_layer_cursor into l_layer;

    l_stmt_num := 70;
    IF l_layer_cursor%NOTFOUND THEN

      l_layer := CSTPLMWI.get_last_layer
                 (
                   i_wip_entity_id,
                   i_op_seq_num,
                   i_inv_item_id,
                   o_err_num,
                   o_err_msg
                 );
      IF o_err_num <> 0 THEN
        RETURN;
      END IF;

      l_consumed_qty := l_txn_qty_remaining;

    ELSE
      l_consumed_qty := least( ( l_layer.applied_matl_qty -
                                 l_layer.relieved_matl_comp_qty -
                                 l_layer.relieved_matl_scrap_qty -
                                 l_layer.relieved_matl_final_comp_qty ),
                               l_txn_qty_remaining );
    END IF;


    l_stmt_num := 80;
    update cst_wip_layers CWL
    set
      applied_matl_qty  = applied_matl_qty  - l_consumed_qty,
      temp_relieved_qty = temp_relieved_qty + l_consumed_qty
    where
      wip_layer_id = l_layer.wip_layer_id and
      inv_layer_id = l_layer.inv_layer_id;

    l_txn_qty_remaining := l_txn_qty_remaining - l_consumed_qty;

  END LOOP;

  l_stmt_num := 90;
  close l_layer_cursor;

  l_stmt_num := 95;
  /* EAM Acct Enh Project */
  CST_Utility_PUB.get_zeroCostIssue_flag (
    p_api_version	=>	1.0,
    x_return_status	=>	l_return_status,
    x_msg_count		=>	l_msg_count,
    x_msg_data		=>	l_msg_data,
    p_txn_id		=>	i_txn_id,
    x_zero_cost_flag	=>	l_zero_cost_flag
    );

  if (l_return_status <> fnd_api.g_ret_sts_success) then
    FND_FILE.put_line(FND_FILE.log, l_msg_data);
    l_api_message := 'get_zeroCostIssue_flag returned unexpected error';
    FND_MESSAGE.set_name('BOM','CST_API_MESSAGE');
    FND_MESSAGE.set_token('TEXT', l_api_message);
    FND_MSG_pub.add;
    raise fnd_api.g_exc_unexpected_error;
  end if;

  if (l_debug = 'Y') then
    FND_FILE.PUT_LINE(FND_FILE.LOG,'zero_cost_flag: '|| to_char(l_zero_cost_flag));
  end if;

  -- update WROCD
  l_stmt_num := 100;
  update wip_req_operation_cost_details WROCD
  set
  (
    WROCD.applied_matl_value,
    WROCD.temp_relieved_value
  )
  =
  (
    select
      NVL( WROCD.applied_matl_value, 0 ) -
        sum( CWL.temp_relieved_qty *
	     decode( l_zero_cost_flag, 1, 0, CWLCD.layer_cost ) ),
      sum( CWL.temp_relieved_qty *
	   decode( l_zero_cost_flag, 1, 0, CWLCD.layer_cost ) )
    from
      cst_wip_layers CWL,
      cst_wip_layer_cost_details CWLCD
    where
      CWL.wip_entity_id     =  WROCD.wip_entity_id     and
      CWL.operation_seq_num =  WROCD.operation_seq_num and
      CWL.inventory_item_id =  WROCD.inventory_item_id and
      CWL.temp_relieved_qty <> 0                     and
      CWLCD.wip_layer_id    =  CWL.wip_layer_id      and
      CWLCD.inv_layer_id    =  CWL.inv_layer_id      and
      CWLCD.cost_element_id =  WROCD.cost_element_id and
      CWLCD.level_type in (1, 2)
  )
  where
    WROCD.wip_entity_id     = i_wip_entity_id and
    WROCD.operation_seq_num = i_op_seq_num and
    WROCD.inventory_item_id = i_inv_item_id;




  l_stmt_num := 110;
  INSERT INTO mtl_cst_txn_cost_details
  (
    TRANSACTION_ID,
    ORGANIZATION_ID,
    INVENTORY_ITEM_ID,
    COST_ELEMENT_ID,
    LEVEL_TYPE,
    TRANSACTION_COST,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE
  )
  SELECT
    i_txn_id,               -- TRANSACTION_ID,
    i_org_id,               -- ORGANIZATION_ID,
    i_inv_item_id,          -- INVENTORY_ITEM_ID,
    CWLCD.cost_element_id,  -- COST_ELEMENT_ID,
    CWLCD.level_type,       -- LEVEL_TYPE,
    sum( decode( l_zero_cost_flag, 1, 0, CWLCD.layer_cost ) *
	 CWL.temp_relieved_qty ) / i_txn_qty,
                            -- TRANSACTION_COST,
    sysdate,        -- LAST_UPDATE_DATE,
    i_user_id,      -- LAST_UPDATED_BY,
    sysdate,        -- CREATION_DATE,
    i_user_id,      -- CREATED_BY,
    i_login_id,     -- LAST_UPDATE_LOGIN,
    i_request_id,   -- REQUEST_ID,
    i_prog_appl_id, -- PROGRAM_APPLICATION_ID,
    i_prog_id,      -- PROGRAM_ID,
    sysdate         -- PROGRAM_UPDATE_DATE
  from
    cst_wip_layers CWL,
    cst_wip_layer_cost_details CWLCD
  where
    CWL.wip_entity_id     =  i_wip_entity_id  and
    CWL.operation_seq_num =  i_op_seq_num     and
    CWL.inventory_item_id =  i_inv_item_id    and
    CWL.temp_relieved_qty <> 0                and
    CWLCD.wip_layer_id    =  CWL.wip_layer_id and
    CWLCD.inv_layer_id    =  CWL.inv_layer_id and
    CWLCD.level_type in (1,2)
  group by
    CWLCD.cost_element_id,
    CWLCD.level_type;




EXCEPTION
  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPLCIR.component_return():' ||
                 to_char(l_stmt_num) || ':' ||
                 substr(SQLERRM,1,150);

END component_return;





END CSTPLCIR;

/
