--------------------------------------------------------
--  DDL for Package Body CSTPACIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPACIT" as
/* $Header: CSTACITB.pls 120.3.12000000.2 2007/09/17 11:12:04 rgangara ship $ */

procedure cost_det_validate (
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
)
is
  l_err_num                 number;
  l_err_code                varchar2(240);
  l_err_msg                 varchar2(240);

  l_stmt_num		    number;
  l_layer_id		    number;
  l_num_detail		    number;
  l_inv_asset_flag	    varchar2(1);
  l_cost_elmt_id	    number;
  cost_det_validate_error   EXCEPTION;

  cursor cost_elmt_ids is
    SELECT COST_ELEMENT_ID
    FROM   MTL_TXN_COST_DET_INTERFACE
    WHERE  TRANSACTION_INTERFACE_ID = i_txn_interface_id;

begin
  /*
  ** initialize local variables
  */
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';


  /*
   *  If it is an expense item, then exit without any processes.
   */

  SELECT INVENTORY_ASSET_FLAG
  INTO   l_inv_asset_flag
  FROM   MTL_SYSTEM_ITEMS
  WHERE  INVENTORY_ITEM_ID = i_item_id
  AND    ORGANIZATION_ID = i_org_id;

  if (l_inv_asset_flag = 'N') then
    -- Error occured

    FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_EXP_ITEM');
    l_err_msg := 'Expense Item.';
    l_err_msg := FND_MESSAGE.Get;

    raise cost_det_validate_error;
  end if;


  SELECT count(*)
  INTO   l_num_detail
  FROM   MTL_TXN_COST_DET_INTERFACE
  WHERE  TRANSACTION_INTERFACE_ID = i_txn_interface_id;

  l_stmt_num := 10;


  /*  l_num_detail = 0	: No corresponding rows in MTL_TXN_COST_DET_INTERFACE
   *			  OR i_txn_interface_id is null.
   *  In this case, skip the validation of row in MTL_TXN_COST_DET_INTERFACE.
   */


  if (l_num_detail = 0) then

    /*
     *  Validate one and only one type of cost change is requested.
     *    1) change through new_averge_cost - new_avg_cost >= 0.
     *    2) change through percentage - per_change >= -100.
     */

    if not (( NVL(i_new_avg_cost, -999) >= 0 AND
	i_per_change is null AND i_val_change is null) OR
	( NVL(i_per_change, -999) >= -100 AND
	i_new_avg_cost is null AND i_val_change is null) OR
	(i_val_change is not null AND
	i_new_avg_cost is null AND i_per_change is null)) then
      -- Error occured

      FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_COST_CHANGE');
      l_err_msg := 'Invalid cost changes.';
      l_err_msg := FND_MESSAGE.Get;

      raise cost_det_validate_error;
    end if;



  elsif (l_num_detail > 0) then
  /*  Matching row does exist in MTL_TXN_COST_DET_INTERFACE so
   *  validate the values.
   */

    l_stmt_num := 15;

    SELECT count(*)
    INTO   l_err_num
    FROM   mtl_parameters mp,
           hr_all_organization_units_tl haout,
           mtl_txn_cost_det_interface mtcdi
    WHERE  mp.organization_id = i_org_id
    AND    haout.organization_id = mp.organization_id
    AND    haout.LANGUAGE = userenv('LANG')
    AND    mtcdi.transaction_interface_id = i_txn_interface_id
    AND    NVL(mtcdi.organization_id, mp.organization_id) = mp.organization_id
    AND    NVL(mtcdi.organization_code, mp.organization_code) = mp.organization_code
    AND    NVL(mtcdi.organization_name, haout.name) = haout.name
    AND    (  mtcdi.organization_id IS NOT NULL
           OR mtcdi.organization_code IS NOT NULL
           OR mtcdi.organization_name IS NOT NULL);

    if (l_err_num <> l_num_detail) then
      -- Error occured
      FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_ORG');
      l_err_msg := 'Invalid Organization.';
      l_err_msg := FND_MESSAGE.Get;

      raise cost_det_validate_error;
    end if;

    l_stmt_num := 20;

    SELECT count(*)
    INTO   l_err_num
    FROM   CST_COST_ELEMENTS CCE,
           MTL_TXN_COST_DET_INTERFACE MTCDI
    WHERE  MTCDI.TRANSACTION_INTERFACE_ID = i_txn_interface_id
    AND    CCE.COST_ELEMENT_ID = NVL(MTCDI.COST_ELEMENT_ID, CCE.COST_ELEMENT_ID)
    AND    CCE.COST_ELEMENT = NVL(MTCDI.COST_ELEMENT, CCE.COST_ELEMENT)
    AND    (MTCDI.COST_ELEMENT_ID IS NOT NULL OR
            MTCDI.COST_ELEMENT IS NOT NULL);

    if (l_err_num = 0) then
      -- Error occured

      FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_COST_ELEMENT');
      l_err_msg := 'Invalid Cost Element.';
      l_err_msg := FND_MESSAGE.Get;

      raise cost_det_validate_error;
    end if;



    l_stmt_num := 30;

    SELECT count(*)
    INTO   l_err_num
    FROM   MFG_LOOKUPS ML,
           MTL_TXN_COST_DET_INTERFACE MTCDI
    WHERE  MTCDI.TRANSACTION_INTERFACE_ID = i_txn_interface_id
    AND    ML.LOOKUP_TYPE = 'CST_LEVEL'
    AND    ML.LOOKUP_CODE = NVL(MTCDI.LEVEL_TYPE, ML.LOOKUP_CODE)
    AND    ML.MEANING = NVL(MTCDI.LEVEL_NAME, ML.MEANING)
    AND    (MTCDI.LEVEL_TYPE IS NOT NULL OR
            MTCDI.LEVEL_NAME IS NOT NULL);

    if (l_err_num = 0) then
      -- Error occured

      FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_COST_LEVEL');
      l_err_msg := 'Invalid Level.';
      l_err_msg := FND_MESSAGE.Get;

      raise cost_det_validate_error;
    end if;



    l_stmt_num := 40;

    SELECT count(*)
    INTO   l_err_num
    FROM   MTL_TXN_COST_DET_INTERFACE
    WHERE  TRANSACTION_INTERFACE_ID = i_txn_interface_id
    AND  NOT  ((NEW_AVERAGE_COST >= 0 AND  -- Bug 4759820
            (PERCENTAGE_CHANGE IS NULL AND VALUE_CHANGE IS NULL)) OR
            (PERCENTAGE_CHANGE >= -100 AND
            (NEW_AVERAGE_COST IS NULL AND  VALUE_CHANGE IS NULL)) OR
            (VALUE_CHANGE IS NOT NULL AND
            (NEW_AVERAGE_COST IS NULL AND PERCENTAGE_CHANGE IS NULL)));

    if (l_err_num <> 0) then  -- modified for bug#4759820 from = to <> so that even if 1 error rec
 	                              -- exists it should through exception.
    -- Error occured

      FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_COST_CHANGE');
      l_err_msg := 'Invalid Cost changes.';
      l_err_msg := FND_MESSAGE.Get;

      raise cost_det_validate_error;
    end if;



    l_stmt_num := 50;

    UPDATE MTL_TXN_COST_DET_INTERFACE MTCDI
    SET ORGANIZATION_ID = i_org_id
    WHERE TRANSACTION_INTERFACE_ID = i_txn_interface_id
    AND   ORGANIZATION_ID IS NULL;


    UPDATE MTL_TXN_COST_DET_INTERFACE MTCDI
    SET COST_ELEMENT_ID =
        (SELECT CCE.COST_ELEMENT_ID
         FROM   CST_COST_ELEMENTS CCE
         WHERE  CCE.COST_ELEMENT = NVL(MTCDI.COST_ELEMENT, CCE.COST_ELEMENT))
    WHERE TRANSACTION_INTERFACE_ID = i_txn_interface_id
    AND   COST_ELEMENT_ID IS NULL;


    UPDATE MTL_TXN_COST_DET_INTERFACE MTCDI
    SET LEVEL_TYPE =
        (SELECT ML.LOOKUP_CODE
         FROM   MFG_LOOKUPS ML
         WHERE  ML.LOOKUP_TYPE = 'CST_LEVEL'
         AND    ML.MEANING = NVL(MTCDI.LEVEL_NAME, ML.MEANING))
    WHERE TRANSACTION_INTERFACE_ID = i_txn_interface_id
    AND   LEVEL_TYPE IS NULL;



    l_stmt_num := 60;

    SELECT count(*)
    INTO   l_err_num
    FROM   MTL_TXN_COST_DET_INTERFACE
    WHERE  TRANSACTION_INTERFACE_ID = i_txn_interface_id
    AND    ORGANIZATION_ID = i_org_id;

    if (l_err_num = 0) then
      -- Error occured

      FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_ORG');
      l_err_msg := 'Organization_id does not match.';
      l_err_msg := FND_MESSAGE.Get;

      raise cost_det_validate_error;
    end if;


    l_stmt_num := 70;


    open cost_elmt_ids;

    loop
      fetch cost_elmt_ids into l_cost_elmt_id;
      exit when cost_elmt_ids%NOTFOUND;

      if ((l_cost_elmt_id = 1 and i_mat_accnt is null) or
	  (l_cost_elmt_id = 2 and i_mat_ovhd_accnt is null) or
	  (l_cost_elmt_id = 3 and i_res_accnt is null) or
          (l_cost_elmt_id = 4 and i_osp_accnt is null) or
	  (l_cost_elmt_id = 5 and i_ovhd_accnt is null)) then
        -- Error occured

        FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_ACCOUNT');
        l_err_code := 'Invalid accounts.';
        l_err_msg := FND_MESSAGE.Get;
        l_err_num := 999;

        raise cost_det_validate_error;
      end if;

    end loop;


  end if;  -- END if for detail rows exist in MTL_TXN_COST_DET_INTERFACE


EXCEPTION
  when cost_det_validate_error then
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPACIT.COST_DET_VALIDATE:' || l_err_msg;
  when OTHERS then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPACIT.COST_DET_VALIDATE: (' || to_char(l_stmt_num) || '): '
		|| substr(SQLERRM,1,150);

end cost_det_validate;




procedure cost_det_move (
  i_txn_id                  in number,
  i_txn_interface_id        in number,
  i_txn_action_id	    in number,
  i_org_id	            in number,
  i_item_id		    in number,
  i_cost_group_id	    in number,
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
)
is
  l_err_num                 number;
  l_err_code                varchar2(240);
  l_err_msg                 varchar2(240);
  l_num_detail              number;
  l_layer_id                number;
  cost_det_move_error       EXCEPTION;
  cost_no_layer_error       EXCEPTION;

begin
  /*
  ** initialize local variables
  */
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';

  o_err_num := 0;
  o_err_code := '';
  o_err_msg := '';

  SELECT count(*)
  INTO   l_num_detail
  FROM   MTL_TXN_COST_DET_INTERFACE
  WHERE  TRANSACTION_INTERFACE_ID = i_txn_interface_id;

  /*  l_num_detail = 0	: No corresponding rows in MTL_TXN_COST_DET_INTERFACE
   *			  OR i_txn_interface_id is null.
   *  In this case, call cstpacit.cost_det_new_insert.
   */

  if (l_num_detail = 0) then
    cstpacit.cost_det_new_insert(i_txn_id, i_txn_action_id, i_org_id,
				 i_item_id, i_cost_group_id, i_txn_cost,
				 i_new_avg_cost, i_per_change, i_val_change,
				 i_mat_accnt, i_mat_ovhd_accnt, i_res_accnt,
				 i_osp_accnt, i_ovhd_accnt,
				 i_user_id, i_login_id, i_request_id,
				 i_prog_appl_id, i_prog_id,
				 l_err_num, l_err_code, l_err_msg);
  if (l_err_num <> 0) then
	raise cost_det_move_error;
  end if;

  else

 l_layer_id := cstpaclm.layer_det_exist(i_org_id, i_item_id, i_cost_group_id,
                                         l_err_num, l_err_code, l_err_msg);

  if (l_err_num <> 0) then
        raise cost_no_layer_error;
  end if;

  if (l_layer_id <> 0) then

    INSERT INTO MTL_CST_TXN_COST_DETAILS (
      TRANSACTION_ID,
      ORGANIZATION_ID,
      INVENTORY_ITEM_ID,
      COST_ELEMENT_ID,
      LEVEL_TYPE,
      TRANSACTION_COST,
      NEW_AVERAGE_COST,
      PERCENTAGE_CHANGE,
      VALUE_CHANGE,
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
      i_txn_id,
      i_org_id,
      i_item_id,
      COST_ELEMENT_ID,
      LEVEL_TYPE,
      ITEM_COST,

      NULL, /*changed from item_cost to NULL for bug 6404902 as for CL/LE not in
MTCDI, new avg cost should be taken as NULL*/

      NULL,
      0, /* changed from NULL to o for but 6404902 so that for CL/LE combination
not in MTCDI, it would not have any effect*/
      sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_appl_id,
      i_prog_id,
      sysdate
    FROM CST_LAYER_COST_DETAILS CLCD
    WHERE CLCD.LAYER_ID = l_layer_id;

UPDATE MTL_CST_TXN_COST_DETAILS mctcd
set (VALUE_CHANGE,
    PERCENTAGE_CHANGE,
    NEW_AVERAGE_COST)
=
(select
 mtcdi.VALUE_CHANGE,
 mtcdi.PERCENTAGE_CHANGE,
 mtcdi.NEW_AVERAGE_COST
 from MTL_TXN_COST_DET_INTERFACE mtcdi
 where mtcdi.TRANSACTION_INTERFACE_ID = i_txn_interface_id
 and mctcd.transaction_id = i_txn_id
 and mtcdi.level_type = mctcd.level_type
 and mtcdi.cost_element_id = mctcd.cost_element_id
)
where
mctcd.transaction_id = i_txn_id
and exists (select 1
            from MTL_TXN_COST_DET_INTERFACE mtcdi
            where mtcdi.TRANSACTION_INTERFACE_ID = i_txn_interface_id
            and mtcdi.level_type = mctcd.level_type
            and mtcdi.cost_element_id = mctcd.cost_element_id);
/*Added for Bug#2509196*/

 INSERT INTO MTL_CST_TXN_COST_DETAILS (
      TRANSACTION_ID,
      ORGANIZATION_ID,
      INVENTORY_ITEM_ID,
      COST_ELEMENT_ID,
      LEVEL_TYPE,
      TRANSACTION_COST,
      NEW_AVERAGE_COST,
      PERCENTAGE_CHANGE,
      VALUE_CHANGE,
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
      i_txn_id,
      i_org_id,
      i_item_id,
      mtcdi.COST_ELEMENT_ID,
      mtcdi.LEVEL_TYPE,
      mtcdi.TRANSACTION_COST,
      mtcdi.NEW_AVERAGE_COST,
      mtcdi.PERCENTAGE_CHANGE,
      mtcdi.VALUE_CHANGE,
      sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_appl_id,
      i_prog_id,
      sysdate
    FROM MTL_TXN_COST_DET_INTERFACE MTCDI
    WHERE mtcdi.TRANSACTION_INTERFACE_ID = i_txn_interface_id
    and   (  (MTCDI.cost_element_id, MTCDI.level_type) not in
              (select mctcd1.cost_element_id,mctcd1.level_type
               from mtl_cst_txn_cost_details mctcd1
               where mctcd1.transaction_id=i_txn_id
               )
        );
/*End of Addition for Bug#2509196*/
else
/* Changed the following for Bug#2509196 as follows so as to
take the elemental details from mtcdi*/
/* No layer exists , hence use THIS level MATERIAL row */

/*INSERT INTO MTL_CST_TXN_COST_DETAILS (
      TRANSACTION_ID,
      ORGANIZATION_ID,
      INVENTORY_ITEM_ID,
      COST_ELEMENT_ID,
      LEVEL_TYPE,
      TRANSACTION_COST,
      NEW_AVERAGE_COST,
      PERCENTAGE_CHANGE,
      VALUE_CHANGE,
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
    values (
      i_txn_id,
      i_org_id,
      i_item_id,
      1,                        -- Hard coded to This level Material
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
      sysdate);*/
INSERT INTO MTL_CST_TXN_COST_DETAILS (
      TRANSACTION_ID,
      ORGANIZATION_ID,
      INVENTORY_ITEM_ID,
      COST_ELEMENT_ID,
      LEVEL_TYPE,
      TRANSACTION_COST,
      NEW_AVERAGE_COST,
      PERCENTAGE_CHANGE,
      VALUE_CHANGE,
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
      i_txn_id,
      i_org_id,
      i_item_id,
      mtcdi.COST_ELEMENT_ID,
      mtcdi.LEVEL_TYPE,
      mtcdi.TRANSACTION_COST,
      mtcdi.NEW_AVERAGE_COST,
      mtcdi.PERCENTAGE_CHANGE,
      mtcdi.VALUE_CHANGE,
      sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_appl_id,
      i_prog_id,
      sysdate
 FROM MTL_TXN_COST_DET_INTERFACE MTCDI
 WHERE mtcdi.TRANSACTION_INTERFACE_ID = i_txn_interface_id;

  end if; /* if layer exists */

end if; /* if l_num_detail = 0 */

EXCEPTION
  when cost_det_move_error then
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPACIT.COST_DET_MOVE:' || l_err_msg;
  when cost_no_layer_error then
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPACIT.COST_DET_MOVE: No layer exists' || l_err_msg;
  when OTHERS then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPACIT.COST_DET_MOVE:' || substr(SQLERRM,1,150);

end cost_det_move;



procedure cost_det_new_insert (
  i_txn_id                  in number,
  i_txn_action_id           in number,
  i_org_id	            in number,
  i_item_id		    in number,
  i_cost_group_id	    in number,
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
)
is
  l_err_num                 number;
  l_err_code                varchar2(240);
  l_err_msg                 varchar2(240);

  cl_item_cost		    number;
  cost_element_count	    number;

  l_cost_elmt_id            number;
  l_layer_id		    number;
  cost_det_new_insert_error EXCEPTION;


  cursor cost_elmt_ids is
    SELECT CLCD.COST_ELEMENT_ID
    FROM   CST_QUANTITY_LAYERS CL,
           CST_LAYER_COST_DETAILS CLCD
    WHERE  CL.LAYER_ID = l_layer_id
    AND    CLCD.LAYER_ID = l_layer_id;


begin
  /*
  ** initialize local variables
  */
  l_err_num := 0;
  l_err_code := '';
  l_err_msg := '';


  l_layer_id := cstpaclm.layer_det_exist(i_org_id, i_item_id, i_cost_group_id,
					 l_err_num, l_err_code, l_err_msg);

  if (l_err_num <> 0) then
	raise cost_det_new_insert_error;
  end if;

  /*  If layer detail exist, then calculate proportional costs and
   *  insert each elements into MTL_CST_TXN_COST_DETAILS.
   */

  if (l_layer_id <> 0) then

    if (i_txn_action_id = 24) then
      -- checking the existence of accounts for average cost update case
      open cost_elmt_ids;

      loop
        fetch cost_elmt_ids into l_cost_elmt_id;
        exit when cost_elmt_ids%NOTFOUND;

        if ((l_cost_elmt_id = 1 and i_mat_accnt is null) or
            (l_cost_elmt_id = 2 and i_mat_ovhd_accnt is null) or
            (l_cost_elmt_id = 3 and i_res_accnt is null) or
            (l_cost_elmt_id = 4 and i_osp_accnt is null) or
            (l_cost_elmt_id = 5 and i_ovhd_accnt is null)) then
          -- Error occured

          FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_ACCOUNT');
          l_err_code := 'Invalid accounts.';
          l_err_msg := FND_MESSAGE.Get;
          l_err_num := 999;

          raise cost_det_new_insert_error;
        end if;

      end loop;
    end if;

    SELECT ITEM_COST
    INTO cl_item_cost
    FROM CST_QUANTITY_LAYERS
    WHERE LAYER_ID = l_layer_id;

    /* for the case of item cost equal zero */
    /* split cost evenly among cost elements */

    if (cl_item_cost = 0) then
      SELECT count(COST_ELEMENT_ID)
      INTO cost_element_count
      FROM CST_LAYER_COST_DETAILS
      WHERE LAYER_ID = l_layer_id;
    end if;

      INSERT INTO MTL_CST_TXN_COST_DETAILS (
      TRANSACTION_ID,
      ORGANIZATION_ID,
      INVENTORY_ITEM_ID,
      COST_ELEMENT_ID,
      LEVEL_TYPE,
      TRANSACTION_COST,
      NEW_AVERAGE_COST,
      PERCENTAGE_CHANGE,
      VALUE_CHANGE,
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
      i_txn_id,
      i_org_id,
      i_item_id,
      CLCD.COST_ELEMENT_ID,
      CLCD.LEVEL_TYPE,
      DECODE(CL.ITEM_COST, 0, i_txn_cost / cost_element_count,
      i_txn_cost * CLCD.ITEM_COST / CL.ITEM_COST),
      DECODE(CL.ITEM_COST, 0, i_new_avg_cost / cost_element_count,
      i_new_avg_cost * CLCD.ITEM_COST / CL.ITEM_COST),
      i_per_change,
      DECODE(CL.ITEM_COST, 0, i_val_change / cost_element_count,
      i_val_change * CLCD.ITEM_COST / CL.ITEM_COST),
      sysdate,
      i_user_id,
      sysdate,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_appl_id,
      i_prog_id,
      sysdate
      FROM  CST_QUANTITY_LAYERS CL, CST_LAYER_COST_DETAILS CLCD
      WHERE CL.LAYER_ID = l_layer_id
      AND CLCD.LAYER_ID = l_layer_id;

  /*  If layer detail does not exist, then insert a new row
   *  as a this level material.
   */
  else

    if (i_txn_action_id = 24 and i_mat_accnt is null) then
      -- Error occured only for average cost update

      FND_MESSAGE.set_name('BOM', 'CST_NO_TXN_INVALID_ACCOUNT');
      l_err_code := 'Invalid accounts.';
      l_err_msg := FND_MESSAGE.Get;
      l_err_num := 999;

      raise cost_det_new_insert_error;
    end if;


    INSERT INTO MTL_CST_TXN_COST_DETAILS (
      TRANSACTION_ID,
      ORGANIZATION_ID,
      INVENTORY_ITEM_ID,
      COST_ELEMENT_ID,
      LEVEL_TYPE,
      TRANSACTION_COST,
      NEW_AVERAGE_COST,
      PERCENTAGE_CHANGE,
      VALUE_CHANGE,
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
    values (
      i_txn_id,
      i_org_id,
      i_item_id,
      1,			/* Hard coded to This level Material */
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

  end if;

EXCEPTION
  when cost_det_new_insert_error then
    o_err_num := l_err_num;
    o_err_code := l_err_code;
    o_err_msg := 'CSTPACIT.COST_DET_NEW_INSERT:' || l_err_msg;
  when OTHERS then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPACIT.COST_DET_NEW_INSERT:' || substr(SQLERRM,1,150);

end cost_det_new_insert;

end cstpacit;

/
