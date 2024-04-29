--------------------------------------------------------
--  DDL for Package Body CSTPSISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPSISC" AS
/* $Header: CSTSISCB.pls 120.3.12010000.3 2010/01/29 00:38:04 jkwac ship $ */

-- PROCEDURE
--  ins_std_cost                This function inserts standard cost in mcacd,
--                              transaction cost in mctcd and sub-elemental
--                              costs in macs.
--
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
)
is
  l_err_num                 number;
  l_err_code                varchar2(240);
  l_err_msg                 varchar2(240);
  l_profile_option	    number;

  l_org_id		    number;
  l_txfr_org_id		    number;
  l_txn_qty		    number;
  l_fob_point		    number;
  l_stmt_num		    number;
  ins_std_cost_error	    EXCEPTION;

  /* EAM Acct Enh Project */
  l_zero_cost_flag	NUMBER := -1;
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER := 0;
  l_msg_data		VARCHAR2(8000);
  l_api_message		VARCHAR2(8000);
  l_debug           VARCHAR2(100);
  l_earn_moh            NUMBER; /* Added for bug6157916 */
  moh_rules_error       EXCEPTION; /* Added for bug6157916 */

BEGIN
  l_return_status	:= fnd_api.g_ret_sts_success;
  l_msg_data := '';
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  o_err_num := l_err_num;
  o_err_code := l_err_code;
  o_err_msg := l_err_msg;


  -- we break down into two major cases
  -- 1. PO delivery, RTV, PO delivery adjustment are exception cases
  --    so we group them together. within this group, asset item in
  --    asset sub is the only case that use standard cost. otherwise,
  --    we're using po price.
  -- 2. all other asset item transactions are another group
  --    wip scrap uses actual cost, and the others use standard cost.

  l_stmt_num := 10;

  if (i_txn_source_type_id = 1) then
  -- PO delivery, RTV, PO delivery adjustment

    l_stmt_num := 20;

  /*
    gwu@us: This profile option is obsolete.  Forcing the
    profile option to 2 (INV/WIP) for all 11i installs.

    -- Check the profile option. If profile option is 2 (INV/WIP), then
    -- no need to insert into mctcd. This insertion has been done by
    -- transaction manager (in inltpu module). It fixes bug 837911
    l_profile_option := fnd_profile.value('CST_AVG_COSTING_OPTION');
  */
    l_profile_option := 2;

    if (l_profile_option <> 2) then

      INSERT INTO MTL_CST_TXN_COST_DETAILS (
        transaction_id,
        organization_id,
        inventory_item_id,
        cost_element_id,
        level_type,
        transaction_cost,
        new_average_cost,
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
      VALUES(
        i_txn_id,
        i_org_id,
        i_inv_item_id,
        1,		-- material
        1,		-- this level
        i_txn_cost,
        NULL,
        NULL,
        NULL,
        sysdate,
        i_user_id,
        sysdate,
        i_user_id,
        i_login_id,
        i_request_id,
        i_prog_appl_id,
        i_prog_id,
        sysdate);

    end if;

    l_stmt_num := 30;

    if (i_exp_item = 0 and i_exp_sub = 0) then
    -- asset item in asset sub is an exception case, use standard cost

      l_stmt_num := 40;

      INSERT INTO MTL_CST_ACTUAL_COST_DETAILS (
	transaction_id,
	organization_id,
	layer_id,
	cost_element_id,
	level_type,
	transaction_action_id,
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
	new_cost,
	insertion_flag,
	variance_amount,
	user_entered)
      SELECT
	i_txn_id,
	i_org_id,
	-1,		-- layer_id = -1 for std.
	cost_element_id,
	level_type,
	i_txn_action_id,
	sysdate,
	i_user_id,
	sysdate,
	i_user_id,
	i_login_id,
	i_request_id,
	i_prog_appl_id,
	i_prog_id,
	sysdate,
	i_inv_item_id,
	SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,1,ITEM_COST,
							2,ITEM_COST,
							3,ITEM_COST,
							4,ITEM_COST,
							5,ITEM_COST),
			      1,DECODE(COST_ELEMENT_ID,1,ITEM_COST,
							2,ITEM_COST,
							3,ITEM_COST,
							4,ITEM_COST,
							5,ITEM_COST))),
	NULL,
	NULL,
	'N',
	NULL,
	'N'
      FROM  CST_ITEM_COST_DETAILS CICD,
            MTL_PARAMETERS MP
      WHERE MP.organization_id = i_org_id
      AND   CICD.organization_id = MP.cost_organization_id
      AND   CICD.inventory_item_id = i_inv_item_id
      AND   CICD.cost_type_id = 1
      GROUP BY CICD.level_type, CICD.cost_element_id;

      l_stmt_num := 45;
      /* Bug6157916 : Check if MOH Absorption rule has been defined
         and if the MOH absorption rule is not overridden then
         only insert into MACS
      */
      l_earn_moh := 1;
      cst_mohRules_pub.apply_moh(
                              1.0,
                              p_organization_id => i_org_id,
                              p_earn_moh =>l_earn_moh,
                              p_txn_id => i_txn_id,
                              p_item_id => i_inv_item_id,
                              x_return_status => l_return_status,
                              x_msg_count => l_msg_count,
                              x_msg_data => l_msg_data);
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         FND_FILE.put_line(FND_FILE.log, l_msg_data);
         raise moh_rules_error;
      END IF;
     IF(l_earn_moh = 0) THEN
       IF l_debug = 'Y' THEN
         fnd_file.put_line(fnd_file.log, '---Material Overhead Absorption Overridden--');
       END IF;
     ELSE
      l_stmt_num := 46;

      INSERT INTO mtl_actual_cost_subelement(
	transaction_id,
	organization_id,
	layer_id,
	cost_element_id,
	level_type,
	resource_id,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	actual_cost,
	user_entered)
      SELECT i_txn_id,
	i_org_id,
	-1,		-- layer_id = -1 for std.
	cost_element_id,
	level_type,
	resource_id,
	sysdate,
        i_user_id,
	sysdate,
	i_user_id,
   	i_login_id,
      	i_request_id,
      	i_prog_appl_id,
      	i_prog_id,
      	sysdate,
	item_cost,
	'N'
      FROM  CST_ITEM_COST_DETAILS CICD,
            MTL_PARAMETERS MP
      WHERE MP.organization_id = i_org_id
      AND   CICD.organization_id = MP.cost_organization_id
      AND   CICD.inventory_item_id = i_inv_item_id
      AND   CICD.cost_type_id = 1
      AND   CICD.level_type = 1
      AND   CICD.cost_element_id = 2;
     END IF ; /* l_earn_moh = 0 */

    else
    -- for all others, use transaction_cost which is po price
    -- as a this level material cost

      l_stmt_num := 50;

	INSERT INTO MTL_CST_ACTUAL_COST_DETAILS (
	  transaction_id,
	  organization_id,
	  layer_id,
	  cost_element_id,
	  level_type,
	  transaction_action_id,
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
	  new_cost,
	  insertion_flag,
	  variance_amount,
	  user_entered
	)
	VALUES(
	  i_txn_id,
	  i_org_id,
	  -1,		-- layer_id = -1 for std.
	  1,		-- material
	  1,		-- this level
	  i_txn_action_id,
	  sysdate,
	  i_user_id,
	  sysdate,
	  i_user_id,
	  i_login_id,
	  i_request_id,
	  i_prog_appl_id,
	  i_prog_id,
	  sysdate,
	  i_inv_item_id,
	  i_txn_cost,
	  NULL,
	  NULL,
	  'N',
	  NULL,
	  'N');

    end if;

  elsif (i_exp_item = 0) then

    l_stmt_num := 60;

    if (i_txn_action_id = 30) then
    -- WIP scrap for asset item

	INSERT INTO MTL_CST_ACTUAL_COST_DETAILS (
	  transaction_id,
	  organization_id,
	  layer_id,
	  cost_element_id,
	  level_type,
	  transaction_action_id,
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
	  new_cost,
	  insertion_flag,
	  variance_amount,
	  user_entered
	)
	VALUES(
	  i_txn_id,
	  i_org_id,
	  -1,		-- layer_id = -1 for std.
	  1,		-- material
	  1,		-- this level
	  i_txn_action_id,
	  sysdate,
	  i_user_id,
	  sysdate,
	  i_user_id,
	  i_login_id,
	  i_request_id,
	  i_prog_appl_id,
	  i_prog_id,
	  sysdate,
	  i_inv_item_id,
	  i_actual_cost,
	  NULL,
	  NULL,
	  'N',
	  NULL,
	  'N');

    else
    -- all other cases for asset items
      l_stmt_num := 70;
      SELECT primary_quantity, organization_id, transfer_organization_id
      INTO l_txn_qty, l_org_id, l_txfr_org_id
      FROM mtl_material_transactions
      WHERE transaction_id = i_txn_id;

      /* For intransit shipments, FOB shipment, this function is called twice -
	 once for the  sending org and once for the receiving org.
	 For the receiving org we need to only make entries for MOH that gets absorbed. */
       /* Bug 2695063 to facilitate AX translation needs rows in MCACD for
          sending org and receiving org. This is applicable for  both FOB shipment and
          FOB receipt. Commented IF condition for bug2695063.
      IF(i_txn_action_id <> 21 OR l_org_id = i_org_id) THEN */

      l_stmt_num := 73;
      /* EAM Acct Enh Project */
      CST_Utility_PUB.get_zeroCostIssue_flag (
	p_api_version		=>	1.0,
	x_return_status		=>	l_return_status,
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

      l_debug := FND_PROFILE.VALUE('MRP_DEBUG');

      /*if (l_debug = 'Y') then
	FND_FILE.PUT_LINE(FND_FILE.LOG,'zero_cost_flag:'|| to_char(l_zero_cost_flag));
      end if;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inserting into MCACD... ');*/

      if (l_zero_cost_flag <> 1) then

        l_stmt_num := 75;
	INSERT INTO MTL_CST_ACTUAL_COST_DETAILS (
	  transaction_id,
	  organization_id,
	  layer_id,
	  cost_element_id,
	  level_type,
	  transaction_action_id,
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
	  new_cost,
	  insertion_flag,
	  variance_amount,
	  user_entered)
	SELECT
	  i_txn_id,
	  i_org_id,
	  -1,		-- layer_id = -1 for std.
	  cost_element_id,
	  level_type,
	  i_txn_action_id,
	  sysdate,
	  i_user_id,
	  sysdate,
	  i_user_id,
	  i_login_id,
	  i_request_id,
	  i_prog_appl_id,
	  i_prog_id,
	  sysdate,
	  i_inv_item_id,
	  SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,1,ITEM_COST,
							 2,ITEM_COST,
							 3,ITEM_COST,
							 4,ITEM_COST,
							 5,ITEM_COST),
				1,DECODE(COST_ELEMENT_ID,1,ITEM_COST,
							 2,ITEM_COST,
							 3,ITEM_COST,
							 4,ITEM_COST,
							 5,ITEM_COST))),
	  NULL,
	  NULL,
	  'N',
	  NULL,
	  'N'
	FROM  CST_ITEM_COST_DETAILS CICD,
              MTL_PARAMETERS MP
	WHERE MP.organization_id = i_org_id
	AND   CICD.organization_id = MP.cost_organization_id
        AND   CICD.inventory_item_id = i_inv_item_id
	AND   CICD.cost_type_id = 1
	GROUP BY CICD.level_type, CICD.cost_element_id;

	if (SQL%NOTFOUND) then
	INSERT INTO MTL_CST_ACTUAL_COST_DETAILS (
			transaction_id,
			organization_id,
			layer_id,
			cost_element_id,
			level_type,
			transaction_action_id,
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
			new_cost,
			insertion_flag,
			variance_amount,
			user_entered)
			SELECT
			i_txn_id,
			i_org_id,
			-1,  -- layer_id = -1 for std.
			1,   -- hard coded to 1 for items having no cicd
			1,   -- hard coded to 1 for items having no cicd
			i_txn_action_id,
			sysdate,
			i_user_id,
			sysdate,
			i_user_id,
			i_login_id,
			i_request_id,
			i_prog_appl_id,
			i_prog_id,
			sysdate,
			i_inv_item_id,
			0,
			NULL,
			NULL,
			'N',
			NULL,
			'N'
			FROM  dual;
	end if;

      else

	l_stmt_num := 77;
	/* l_zero_cost_flag = 1*/
	INSERT INTO MTL_CST_ACTUAL_COST_DETAILS (
	  transaction_id,
	  organization_id,
	  layer_id,
	  cost_element_id,
	  level_type,
	  transaction_action_id,
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
	  new_cost,
	  insertion_flag,
	  variance_amount,
	  user_entered)
	SELECT
	  i_txn_id,
	  i_org_id,
	  -1,		-- layer_id = -1 for std.
	  cost_element_id,
	  level_type,
	  i_txn_action_id,
	  sysdate,
	  i_user_id,
	  sysdate,
	  i_user_id,
	  i_login_id,
	  i_request_id,
	  i_prog_appl_id,
	  i_prog_id,
	  sysdate,
	  i_inv_item_id,
	  0,
   	  NULL,
	  NULL,
	  'N',
	  NULL,
	  'N'
	FROM  CST_ITEM_COST_DETAILS CICD,
              MTL_PARAMETERS MP
	WHERE MP.organization_id = i_org_id
	AND   CICD.organization_id = MP.cost_organization_id
        AND   CICD.inventory_item_id = i_inv_item_id
	AND   CICD.cost_type_id = 1
	GROUP BY CICD.level_type, CICD.cost_element_id;

      end if; /* l_zero_cost_flag <> 1 */

       /* Bug 2695063 to facilitate AX translation needs rows in MCACD for
          sending org and receiving org. This is applicable for  both FOB shipment and
          FOB receipt. Commented ELSE condition for bug2695063.
    ELSE
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inserting into MCACD for receiving org... ');
        l_stmt_num := 76;

        INSERT INTO MTL_CST_ACTUAL_COST_DETAILS (
          transaction_id,
          organization_id,
          layer_id,
          cost_element_id,
          level_type,
          transaction_action_id,
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
          new_cost,
          insertion_flag,
          variance_amount,
          user_entered)
        SELECT
          i_txn_id,
          i_org_id,
          -1,           -- layer_id = -1 for std.
          cost_element_id,
          level_type,
          i_txn_action_id,
          sysdate,
          i_user_id,
          sysdate,
          i_user_id,
          i_login_id,
          i_request_id,
          i_prog_appl_id,
          i_prog_id,
          sysdate,
          i_inv_item_id,
          SUM(DECODE(LEVEL_TYPE,2,DECODE(COST_ELEMENT_ID,1,ITEM_COST,
                                                         2,ITEM_COST,
                                                         3,ITEM_COST,
                                                         4,ITEM_COST,
                                                         5,ITEM_COST),
                                1,DECODE(COST_ELEMENT_ID,1,ITEM_COST,
                                                         2,ITEM_COST,
                                                         3,ITEM_COST,
                                                         4,ITEM_COST,
                                                         5,ITEM_COST))),
          NULL,
          NULL,
          'N',
          NULL,
          'N'
        FROM  CST_ITEM_COST_DETAILS CICD,
              MTL_PARAMETERS MP
        WHERE MP.organization_id = i_org_id
        AND   CICD.organization_id = MP.cost_organization_id
        AND   CICD.inventory_item_id = i_inv_item_id
        AND   CICD.cost_type_id = 1
	AND   CICD.cost_element_id = 2
        GROUP BY CICD.level_type, CICD.cost_element_id;

    END IF; */

    l_stmt_num := 80;

    -- Modified for fob stamping project
    if (i_txn_action_id = 21) THEN
          SELECT nvl(MMT.fob_point, MIP.fob_point)
          INTO l_fob_point
          FROM MTL_INTERORG_PARAMETERS MIP, MTL_MATERIAL_TRANSACTIONS MMT
          WHERE MIP.from_organization_id = l_org_id
          AND MIP.to_organization_id = l_txfr_org_id
          AND MMT.transaction_id = i_txn_id;

    elsif (i_txn_action_id = 12) THEN
          SELECT nvl(MMT.fob_point, MIP.fob_point)
          INTO l_fob_point
          FROM MTL_INTERORG_PARAMETERS MIP, MTL_MATERIAL_TRANSACTIONS MMT
          WHERE MIP.from_organization_id = l_txfr_org_id
          AND MIP.to_organization_id = l_org_id
          AND MMT.transaction_id = i_txn_id;

    end if;

    l_stmt_num := 90;

    if ((i_txn_action_id = 31 and i_txn_source_type_id = 5) /* WIP completion */
        OR
        (i_txn_action_id = 32 and i_txn_source_type_id = 5) /* Assembly return */
        OR
        (i_txn_action_id = 3 and l_txn_qty >0) /* Direct interorg receipt */
        OR
	(i_txn_action_id = 21 and l_fob_point = 1 and l_org_id <> i_org_id)
        OR
        /* commented following line and added a line below for
           bug 2695063
        (i_txn_action_id = 12 and l_fob_point = 2 ) */
         (i_txn_action_id = 12 and l_fob_point = 2 and l_org_id = i_org_id) /* Intransit Receipt */
        OR
        /* OPM INVCONV umoogala */
        (i_txn_action_id = 15)
        OR
        /* OPM INVCONV umoogala */
        (i_txn_action_id = 22)
       ) then

        /* Bug6157916 : Check if MOH Absorption rule has been defined
         and if the MOH absorption rule is not overridden then
         only insert into MACS
        */
       l_earn_moh := 1;
       cst_mohRules_pub.apply_moh(
                                1.0,
                                p_organization_id => i_org_id,
                                p_earn_moh =>l_earn_moh,
                                p_txn_id => i_txn_id,
                                p_item_id => i_inv_item_id,
                                x_return_status => l_return_status,
                                x_msg_count => l_msg_count,
                                x_msg_data => l_msg_data);
       IF l_return_status <> FND_API.g_ret_sts_success THEN
          FND_FILE.put_line(FND_FILE.log, l_msg_data);
          raise moh_rules_error;
       END IF;
      IF(l_earn_moh = 0) THEN
       IF l_debug = 'Y' THEN
         fnd_file.put_line(fnd_file.log, '---Material Overhead Absorption Overridden--');
       END IF;
      ELSE
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inserting into MACS... ');
       l_stmt_num := 100;

    	INSERT INTO mtl_actual_cost_subelement(
           transaction_id,
	   organization_id,
	   layer_id,
      	   cost_element_id,
	   level_type,
	   resource_id,
	   last_update_date,
	   last_updated_by,
	   creation_date,
	   created_by,
	   last_update_login,
	   request_id,
	   program_application_id,
	   program_id,
	   program_update_date,
	   actual_cost,
	   user_entered)
       SELECT i_txn_id,
	   i_org_id,
	   -1,		-- layer_id = -1 for std.
	   cost_element_id,
	   level_type,
	   resource_id,
	   sysdate,
           i_user_id,
	   sysdate,
	   i_user_id,
   	   i_login_id,
      	   i_request_id,
      	   i_prog_appl_id,
      	   i_prog_id,
      	   sysdate,
	   item_cost,
	   'N'
       FROM  CST_ITEM_COST_DETAILS CICD,
             MTL_PARAMETERS MP
       WHERE MP.organization_id = i_org_id
       AND   CICD.organization_id = MP.cost_organization_id
       AND   CICD.inventory_item_id = i_inv_item_id
       AND   CICD.cost_type_id = 1
       AND   CICD.level_type = 1
       AND   CICD.cost_element_id = 2;
      END IF; /*l_earn_moh = 0*/
      end if;
    end if;
  end if;


EXCEPTION
  when ins_std_cost_error then
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPSISC.INS_STD_COST:' || l_err_msg;
  when moh_rules_error THEN
    o_err_num := 9999;
    o_err_code := 'CST_RULES_ERROR';
    FND_MESSAGE.set_name('BOM', 'CST_RULES_ERROR');
    o_err_msg := 'CSTPSISC.INS_STD_COST:'||FND_MESSAGE.Get;
  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPSISC.INS_STD_COST (' || to_char(l_stmt_num) || '): '
			|| substrb(SQLERRM,1,150);

END ins_std_cost;

END CSTPSISC;


/
