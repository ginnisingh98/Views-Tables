--------------------------------------------------------
--  DDL for Package Body CSTPLMWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPLMWI" AS
/* $Header: CSTLMWIB.pls 115.6 2004/02/17 20:12:04 lsoo ship $ */




----------------------------------------------------------------
-- wip_layer_create
--   This function takes a LayerQtyRecTable containing the INV
--   layer IDs and quantities, and creates corresponding WIP
--   layers using the given INV layer costs.
----------------------------------------------------------------
FUNCTION wip_layer_create (
  i_wip_entity_id       IN      NUMBER,
  i_op_seq_num          IN      NUMBER,
  i_inv_item_id         IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_layer_qty_table     IN      LayerQtyRecTable,
  i_user_id             IN      NUMBER,
  i_login_id            IN      NUMBER,
  i_request_id          IN      NUMBER,
  i_prog_id             IN      NUMBER,
  i_prog_appl_id        IN      NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_msg             OUT NOCOPY     VARCHAR2
) RETURN NUMBER
IS

  l_stmt_num       NUMBER(15) := 0;

  l_wip_layer_id   NUMBER(15) := 0;
  i                NUMBER(15) := 0;

  invalid_qty_table_exception   EXCEPTION;
  invalid_inv_layer_exception   EXCEPTION;
  no_inv_cost_details_exception EXCEPTION;

  l_org_id		NUMBER;
  l_subinv		VARCHAR2(50);
  l_exp_sub_flag	NUMBER;
  l_exp_item_flag	NUMBER;
  /* EAM Acct Enh Project */
  l_debug			VARCHAR2(80);
  l_zero_cost_flag	NUMBER := -1;
  l_return_status	VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count		NUMBER := 0;
  l_msg_data            VARCHAR2(8000) := '';
  l_api_message		VARCHAR2(8000);

BEGIN

  l_stmt_num := 10;
  IF i_layer_qty_table IS NULL THEN
    RAISE invalid_qty_table_exception;
  END IF;

  l_stmt_num := 15;
  select organization_id,
    subinventory_code
  into l_org_id,
    l_subinv
  from mtl_material_transactions
  where transaction_id = i_txn_id;

  select decode(inventory_asset_flag,'Y', 0, 1)
  into l_exp_item_flag
  from mtl_system_items
  where inventory_item_id = i_inv_item_id
    and organization_id = l_org_id;

  begin
    select decode(asset_inventory, 1, 0, 1)
    into l_exp_sub_flag
    from mtl_secondary_inventories
    where secondary_inventory_name = l_subinv
      and organization_id = l_org_id;
  exception
    when no_data_found then
      l_exp_sub_flag := -1;
  end;

  l_stmt_num := 20;
  select cst_wip_layers_s.nextval
  into   l_wip_layer_id
  from   dual;

  l_stmt_num := 25;
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

  l_stmt_num := 30;
  i := i_layer_qty_table.FIRST;

  if (l_exp_item_flag <> 1) then
    WHILE i IS NOT NULL LOOP

      IF ( i_layer_qty_table.EXISTS(i) AND
           i_layer_qty_table(i).layer_id IS NOT NULL ) THEN

	l_stmt_num := 40;
	insert into cst_wip_layers
	(
	  wip_layer_id,
          wip_entity_id,
          operation_seq_num,
          inventory_item_id,
          repetitive_schedule_id,
          inv_layer_id,
          inv_layer_date,
          create_txn_id,
          applied_matl_qty,
          relieved_matl_comp_qty,
          relieved_matl_scrap_qty,
          relieved_matl_final_comp_qty,
          temp_relieved_qty,
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
        select
          l_wip_layer_id,                 -- wip_layer_id
          i_wip_entity_id,                -- wip_entity_id
          i_op_seq_num,                   -- operation_seq_num
          CIL.inventory_item_id,          -- inventory_item_id
          null,                           -- repetitive_schedule_id
          decode(l_exp_sub_flag, 1, -1, CIL.inv_layer_id),
	  				  -- inv_layer_id
          CIL.creation_date,		  -- inv_layer_date
          i_txn_id,                       -- create_txn_id
          NVL( i_layer_qty_table(i).layer_qty, 0 ),
					  -- applied_matl_qty
          0,                              -- relieved_matl_comp_qty
          0,                              -- relieved_matl_scrap_qty
          0,                              -- relieved_matl_final_comp_qty
          0,                              -- temp_relieved_qty
          sysdate,                        -- LAST_UPDATE_DATE
          i_user_id,                      -- LAST_UPDATED_BY
          sysdate,                        -- CREATION_DATE
          i_user_id,                      -- CREATED_BY
          i_login_id,                     -- LAST_UPDATE_LOGIN
          i_request_id,                   -- REQUEST_ID
          i_prog_appl_id,                 -- PROGRAM_APPLICATION_ID
          i_prog_id,                      -- PROGRAM_ID
          sysdate                         -- PROGRAM_UPDATE_DATE
        from
          cst_inv_layers CIL
        where
          CIL.inv_layer_id = i_layer_qty_table(i).layer_id and
          CIL.inventory_item_id = i_inv_item_id;

        IF SQL%ROWCOUNT = 0 THEN
          RAISE invalid_inv_layer_exception;
        END IF;


        l_stmt_num := 50;
        insert into cst_wip_layer_cost_details
        (
          wip_layer_id,
          inv_layer_id,
          cost_element_id,
          level_type,
          layer_cost,
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
        select
          l_wip_layer_id,           -- wip_layer_id
          decode(l_exp_sub_flag, 1, -1, CILCD.inv_layer_id),
				    -- inv_layer_id
          CILCD.cost_element_id,    -- cost_element_id
          CILCD.level_type,         -- level_type
          sum(decode(l_zero_cost_flag, 1, 0, CILCD.layer_cost)),
	 			    -- layer_cost
          sysdate,                  -- LAST_UPDATE_DATE
          i_user_id,                -- LAST_UPDATED_BY
          sysdate,                  -- CREATION_DATE
          i_user_id,                -- CREATED_BY
          i_login_id,               -- LAST_UPDATE_LOGIN
          i_request_id,             -- REQUEST_ID
          i_prog_appl_id,           -- PROGRAM_APPLICATION_ID
          i_prog_id,                -- PROGRAM_ID
          sysdate                   -- PROGRAM_UPDATE_DATE
        from
          cst_inv_layer_cost_details CILCD
        where
          CILCD.inv_layer_id = i_layer_qty_table(i).layer_id
        group by
          CILCD.inv_layer_id,
          CILCD.cost_element_id,
          CILCD.level_type;


        IF SQL%ROWCOUNT = 0 THEN
          RAISE no_inv_cost_details_exception;
        END IF;

      END IF;

      i := i_layer_qty_table.NEXT( i );

    END LOOP;

  else
  /* Expense items */
    IF ( i_layer_qty_table.EXISTS(i) AND
         i_layer_qty_table(i).layer_id IS NOT NULL ) THEN

      l_stmt_num := 60;
      insert into cst_wip_layers
      (
	wip_layer_id,
        wip_entity_id,
        operation_seq_num,
        inventory_item_id,
        repetitive_schedule_id,
        inv_layer_id,
        inv_layer_date,
        create_txn_id,
        applied_matl_qty,
        relieved_matl_comp_qty,
        relieved_matl_scrap_qty,
        relieved_matl_final_comp_qty,
        temp_relieved_qty,
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
      select
        l_wip_layer_id,                 -- wip_layer_id
        i_wip_entity_id,                -- wip_entity_id
        i_op_seq_num,                   -- operation_seq_num
        i_inv_item_id,          		-- inventory_item_id
        null,                           -- repetitive_schedule_id
        -1,			 	-- inv_layer_id
        sysdate,			-- inv_layer_date
        i_txn_id,                       -- create_txn_id
        NVL( i_layer_qty_table(i).layer_qty, 0 ),
					-- applied_matl_qty
        0,                              -- relieved_matl_comp_qty
        0,                              -- relieved_matl_scrap_qty
        0,                              -- relieved_matl_final_comp_qty
        0,                              -- temp_relieved_qty
        sysdate,                        -- LAST_UPDATE_DATE
        i_user_id,                      -- LAST_UPDATED_BY
        sysdate,                        -- CREATION_DATE
        i_user_id,                      -- CREATED_BY
        i_login_id,                     -- LAST_UPDATE_LOGIN
        i_request_id,                   -- REQUEST_ID
        i_prog_appl_id,                 -- PROGRAM_APPLICATION_ID
        i_prog_id,                      -- PROGRAM_ID
        sysdate                         -- PROGRAM_UPDATE_DATE
      from
        dual;

      l_stmt_num := 70;
      insert into cst_wip_layer_cost_details
      (
        wip_layer_id,
        inv_layer_id,
        cost_element_id,
        level_type,
        layer_cost,
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
      select
        l_wip_layer_id,           -- wip_layer_id
        -1,			    -- inv_layer_id
        1,			    -- cost_element_id
        1,        		    -- level_type
        0,			    -- layer_cost
        sysdate,                  -- LAST_UPDATE_DATE
        i_user_id,                -- LAST_UPDATED_BY
        sysdate,                  -- CREATION_DATE
        i_user_id,                -- CREATED_BY
        i_login_id,               -- LAST_UPDATE_LOGIN
        i_request_id,             -- REQUEST_ID
        i_prog_appl_id,           -- PROGRAM_APPLICATION_ID
        i_prog_id,                -- PROGRAM_ID
        sysdate                   -- PROGRAM_UPDATE_DATE
      from
        dual;
    end if;
  end if;



  RETURN l_wip_layer_id;





EXCEPTION
  WHEN invalid_qty_table_exception THEN
    o_err_num := 1001;
    o_err_msg := 'CSTPLMWI.wip_layer_create():' ||
                 to_char(l_stmt_num) || ':' ||
                 'i_layer_qty_table IS NULL';
    RETURN 0;

  WHEN invalid_inv_layer_exception THEN
    o_err_num := 1002;
    o_err_msg := 'CSTPLMWI.wip_layer_create():' ||
                 to_char(l_stmt_num) || ':' ||
                 'Inventory returned invalid layer ' ||
                 to_char( i_layer_qty_table(i).layer_id );
    RETURN 0;

  WHEN no_inv_cost_details_exception THEN
    o_err_num := 1003;
    o_err_msg := 'CSTPLMWI.wip_layer_create():' ||
                 to_char(l_stmt_num) || ':' ||
                 'Inventory missing layer cost details ' ||
                 i_layer_qty_table(i).layer_id;
    RETURN 0;

  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPLMWI.wip_layer_create():' ||
                 to_char(l_stmt_num) || ':' ||
                 to_char( i_layer_qty_table(i).layer_id ) || ':' ||
                 substr(SQLERRM,1,150);
    RETURN 0;

END wip_layer_create;




----------------------------------------------------------------
-- wip_layer_consume_sql
--   This function returns the dynamic SQL statement for
--   consuming the WIP layers using the provided WHERE clause,
--   as well as the order mode (FIFO or LIFO).
----------------------------------------------------------------
FUNCTION wip_layer_consume_sql (
  i_where_clause   IN VARCHAR2,
  i_cost_method_id IN NUMBER,
  i_direction_mode IN NUMBER
) RETURN VARCHAR2
IS
  l_optional_and varchar2(10);
  l_sql_order_by varchar2(400);
BEGIN

  IF i_where_clause IS NULL THEN
    l_optional_and := to_char( null );
  ELSE
    l_optional_and := ' and ';
  END IF;

  IF ( i_cost_method_id = FIFO and i_direction_mode = NORMAL  ) OR
     ( i_cost_method_id = LIFO and i_direction_mode = REVERSE ) THEN
    l_sql_order_by :=
      ' CWL.wip_entity_id     asc, ' ||
      ' CWL.operation_seq_num asc, ' ||
      ' CWL.inventory_item_id asc, ' ||
/*
Removed since EAM Acct Enh project has layers with inv_layer_id = -1
      ' CWL.inv_layer_date    asc, ' ||
      ' CWL.inv_layer_id      asc, ' ||
*/
      ' CWL.creation_date     asc, ' ||
      ' CWL.wip_layer_id      asc  ';

  ELSIF ( i_cost_method_id = LIFO and i_direction_mode = NORMAL  ) OR
        ( i_cost_method_id = FIFO and i_direction_mode = REVERSE ) THEN
    l_sql_order_by :=
      ' CWL.wip_entity_id     desc, ' ||
      ' CWL.operation_seq_num desc, ' ||
      ' CWL.inventory_item_id desc, ' ||
/*
Removed since EAM Acct Enh project has layers with inv_layer_id = -1
      ' CWL.inv_layer_date    desc, ' ||
      ' CWL.inv_layer_id      desc, ' ||
*/
      ' CWL.creation_date     desc, ' ||
      ' CWL.wip_layer_id      desc  ';

  ELSE
    RETURN to_char( NULL );

  END IF;


  RETURN
    ' select *                  ' ||
    ' from   cst_wip_layers CWL ' ||
    ' where                     ' ||
    '   CWL.wip_entity_id     = :wip_entity_id and ' ||
    '   CWL.operation_seq_num = :op_seq_num    and ' ||
    '   CWL.inventory_item_id = :inv_item_id ' || l_optional_and ||
        i_where_clause ||
    ' order by '                                     ||
        l_sql_order_by;

END wip_layer_consume_sql;




-----------------------------------------------------------------
-- get_last_layer
--   This function returns the last (most recent) WIP layer for
--   a particular WIP entity/op/item combination.
-----------------------------------------------------------------
FUNCTION get_last_layer (
  i_wip_entity_id IN  NUMBER,
  i_op_seq_num    IN  NUMBER,
  i_inv_item_id   IN  NUMBER,
  o_err_num       OUT NOCOPY NUMBER,
  o_err_msg       OUT NOCOPY VARCHAR2
) RETURN cst_wip_layers%ROWTYPE
IS
  l_layer_cursor CSTPLMWI.REF_CURSOR_TYPE;
  l_layer        cst_wip_layers%ROWTYPE;
  l_sql_stmt     VARCHAR2(8000);
  l_stmt_num     NUMBER(15);
BEGIN

  l_stmt_num := 10;
  l_sql_stmt := CSTPLMWI.wip_layer_consume_sql
                (
                  to_char( NULL ),
                  CSTPLMWI.LIFO,
                  CSTPLMWI.NORMAL
                );

  l_stmt_num := 20;
  open l_layer_cursor for l_sql_stmt
  using i_wip_entity_id, i_op_seq_num, i_inv_item_id;

  l_stmt_num := 30;
  fetch l_layer_cursor into l_layer;

  l_stmt_num := 40;
  close l_layer_cursor;

  l_stmt_num := 50;
  return l_layer;


EXCEPTION
  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPLMWI.get_last_layer():' ||
                 to_char(l_stmt_num) || ':' ||
                 substr(SQLERRM,1,150);

END get_last_layer;





---------------------------------------------------------------
-- init_wip_layers
--   This function initializes WROCD, CWL, and CWLCD for
--   a particular WIP entity/op/Item combination.  It will
--   create default rows in these tables if they don't exist.
---------------------------------------------------------------
PROCEDURE init_wip_layers (
  i_wip_entity_id       IN      NUMBER,
  i_op_seq_num          IN      NUMBER,
  i_inv_item_id         IN      NUMBER,
  i_org_id              IN      NUMBER,
  i_txn_id              IN      NUMBER,
  i_layer_id            IN      NUMBER,
  i_user_id             IN      NUMBER,
  i_login_id            IN      NUMBER,
  i_request_id          IN      NUMBER,
  i_prog_id             IN      NUMBER,
  i_prog_appl_id        IN      NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_msg             OUT NOCOPY     VARCHAR2
)
IS
  l_stmt_num        NUMBER;

  l_inv_layer_id    NUMBER;
  l_layer_qty_table CSTPLMWI.LayerQtyRecTable;
  l_wip_layer_id    NUMBER;

  l_err_code        VARCHAR2(2000);

  l_item_layer_id   NUMBER;
  l_cost_group_id   NUMBER;

  invalid_inv_layer_exception EXCEPTION;

  l_item_id         NUMBER;
  l_org_id          NUMBER;
  l_exp_item_flag   NUMBER;

BEGIN

  l_stmt_num := 5;
  select mmt.inventory_item_id,
    mmt.organization_id
  into l_item_id,
    l_org_id
  from mtl_material_transactions mmt
    where mmt.transaction_id = i_txn_id;

  select decode(inventory_asset_flag,'Y', 0, 1)
  into l_exp_item_flag
  from mtl_system_items
  where inventory_item_id = l_item_id
    and organization_id = l_org_id;

  -- clear the temp_relieved_value column
  l_stmt_num := 10;
  update wip_req_operation_cost_details
  set    temp_relieved_value = 0
  where  wip_entity_id     = i_wip_entity_id and
         operation_seq_num = i_op_seq_num and
         inventory_item_id = i_inv_item_id;

  if l_exp_item_flag <> 1 then
    -- don't insert into WROCD for expense item
    -- insert into WROCD if not already there
    l_stmt_num := 20;
    INSERT INTO WIP_REQ_OPERATION_COST_DETAILS WROCD
    (
      WIP_ENTITY_ID,
      OPERATION_SEQ_NUM,
      ORGANIZATION_ID,
      INVENTORY_ITEM_ID,
      COST_ELEMENT_ID,
      APPLIED_MATL_VALUE,
      RELIEVED_MATL_COMPLETION_VALUE,
      RELIEVED_MATL_SCRAP_VALUE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE
    )
    SELECT
      i_wip_entity_id,       -- WIP_ENTITY_ID,
      i_op_seq_num,          -- OPERATION_SEQ_NUM,
      i_org_id,              -- ORGANIZATION_ID,
      i_inv_item_id,         -- INVENTORY_ITEM_ID,
      CCE.cost_element_id,   -- COST_ELEMENT_ID,
      0,                     -- APPLIED_MATL_VALUE,
      0,                     -- RELIEVED_MATL_COMPLETION_VALUE,
      0,                     -- RELIEVED_MATL_SCRAP_VALUE,
      i_user_id,             -- LAST_UPDATED_BY,
      sysdate,               -- LAST_UPDATE_DATE,
      sysdate,               -- CREATION_DATE,
      i_user_id,             -- CREATED_BY,
      i_login_id,            -- LAST_UPDATE_LOGIN,
      i_request_id,          -- REQUEST_ID,
      i_prog_appl_id,        -- PROGRAM_APPLICATION_ID,
      i_prog_id,             -- PROGRAM_ID,
      sysdate                -- PROGRAM_UPDATE_DATE
    from
      cst_cost_elements CCE
    where
      NOT EXISTS
      (
	SELECT 'X'
	FROM   WIP_REQ_OPERATION_COST_DETAILS WROCD2
	WHERE
	  WROCD2.WIP_ENTITY_ID     = i_wip_entity_id       AND
	  WROCD2.OPERATION_SEQ_NUM = i_op_seq_num          AND
	  WROCD2.INVENTORY_ITEM_ID = i_inv_item_id         AND
	  WROCD2.COST_ELEMENT_ID   = CCE.cost_element_id
      ) AND
      EXISTS
      (
	select 'x'
	from   wip_requirement_operations WRO
	where  WRO.wip_entity_id     = i_wip_entity_id  and
           WRO.operation_seq_num = i_op_seq_num     and
           WRO.inventory_item_id = i_inv_item_id    and
           WRO.wip_supply_type not in (4, 5, 6)
      )
    group by
      CCE.cost_element_id;
  end if;


  -- check for WIP layers
  l_stmt_num := 30;
  update cst_wip_layers CWL
  set    temp_relieved_qty = 0
  where
    CWL.wip_entity_id     = i_wip_entity_id and
    CWL.operation_seq_num = i_op_seq_num    and
    CWL.inventory_item_id = i_inv_item_id;


  -- if no WIP layer found, create new one using current INV layer cost
  l_stmt_num := 40;
  IF SQL%ROWCOUNT <= 0 THEN

    	/*
       	Fix for BUG 1359047:
       	The CQL i_layer_id may belong to the assembly whereas
       	i_inv_item_id belongs to the component.  Will look up
       	the correct CQL layer_id for the component through the
       	Cost Group ID.

       	CQL must have only one row per item/org/CG combination;
       	otherwise this statement will fail (purposefully).
    	*/

    if (l_exp_item_flag <> 1) then
      l_stmt_num := 45;
      SELECT	cost_group_id
      INTO	l_cost_group_id
      FROM	cst_quantity_layers
      WHERE	layer_id = i_layer_id;

      l_stmt_num := 48;
      SELECT	NVL(MIN(CQL.layer_id),-1)
      INTO	l_item_layer_id
      FROM	cst_quantity_layers CQL
      WHERE	CQL.inventory_item_id = i_inv_item_id
      AND	CQL.organization_id   = i_org_id
      AND	CQL.cost_group_id     = l_cost_group_id;

      IF (l_item_layer_id = -1) THEN
		l_item_layer_id := CSTPACLM.create_layer(
			i_org_id 	=> i_org_id,
			i_item_id 	=> i_inv_item_id,
			i_cost_group_id => l_cost_group_id,
			i_user_id 	=> i_user_id,
			i_request_id 	=> i_request_id,
			i_prog_id 	=> i_prog_id,
			i_prog_appl_id 	=> i_prog_appl_id,
			i_txn_id  	=> i_txn_id,
			o_err_num 	=> o_err_num,
			o_err_code 	=> l_err_code,
			o_err_msg 	=> o_err_msg);
      END IF;


      l_stmt_num := 50;
      l_inv_layer_id := CSTPLENG.get_current_layer
                      (
                        I_ORG_ID          => i_org_id,
                        I_TXN_ID          => i_txn_id,
                        I_LAYER_ID        => l_item_layer_id,
                        I_ITEM_ID         => i_inv_item_id,
                        I_USER_ID         => i_user_id,
                        I_LOGIN_ID        => i_login_id,
                        I_REQ_ID          => i_request_id,
                        I_PRG_APPL_ID     => i_prog_appl_id,
                        I_PRG_ID          => i_prog_id,
                        I_TXN_SRC_TYPE_ID => 5,
                        I_TXN_SRC_ID      => i_wip_entity_id,
                        O_Err_Num         => o_err_num,
                        O_Err_Code        => l_err_code,
                        O_Err_Msg         => o_err_msg
                      );
      IF o_err_num <> 0 THEN
        RETURN;
      END IF;
    end if; /* l_exp_item_flag <> 1 */

    l_layer_qty_table := CSTPLMWI.LayerQtyRecTable();
    l_layer_qty_table.EXTEND;
    if (l_exp_item_flag <> 1) then
      l_layer_qty_table( l_layer_qty_table.LAST ).layer_id  := l_inv_layer_id;
    else
      l_layer_qty_table( l_layer_qty_table.LAST ).layer_id  := -1;
    end if;
    l_layer_qty_table( l_layer_qty_table.LAST ).layer_qty := 0;


    l_stmt_num := 60;
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

    IF (l_wip_layer_id <= 0 and l_exp_item_flag <> 1) THEN
      RAISE invalid_inv_layer_exception;
    END IF;

  END IF; -- l_layer_count <= 0




EXCEPTION
  WHEN invalid_inv_layer_exception THEN
    o_err_num := 1005;
    o_err_msg := 'CSTPLMWI.init_wip_layers():' ||
                 to_char(l_stmt_num) || ':' ||
                 'FIFO Inventory returned invalid current inv layer';
    RETURN;

  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPLMWI.init_wip_layers():' ||
                 to_char(l_stmt_num) || ':' ||
                 substr(SQLERRM,1,150);

END init_wip_layers;




-----------------------------------------------------------------
-- reset_temp_columns
--   This function resets the temp_relieve_value/qty
--   columns in WROCD, WOO, WOR, and CWL.
-----------------------------------------------------------------
PROCEDURE reset_temp_columns (
  i_wip_entity_id       IN      NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_msg             OUT NOCOPY     VARCHAR2
)
IS
  l_stmt_num NUMBER := 0;
BEGIN

  l_stmt_num := 10;

  UPDATE WIP_REQ_OPERATION_COST_DETAILS
  SET    temp_relieved_value = 0
  where  WIP_ENTITY_ID = i_wip_entity_id;

  l_stmt_num := 20;

  UPDATE WIP_OPERATION_RESOURCES
  SET    temp_relieved_value = 0
  where  WIP_ENTITY_ID = i_wip_entity_id;

  l_stmt_num := 30;

  UPDATE WIP_OPERATION_OVERHEADS
  SET temp_relieved_value = 0
  where WIP_ENTITY_ID = i_wip_entity_id;

  l_stmt_num := 40;

  update cst_wip_layers
  set    temp_relieved_qty = 0
  where  wip_entity_id = i_wip_entity_id;

EXCEPTION
  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPLMWI.reset_temp_values():' ||
                 to_char(l_stmt_num) || ':' ||
                 substr(SQLERRM,1,150);

END reset_temp_columns;





END CSTPLMWI;

/
