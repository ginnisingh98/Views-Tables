--------------------------------------------------------
--  DDL for Package Body WSMPGENE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPGENE" AS
/* $Header: WSMGENEB.pls 115.9 2001/08/06 15:36:09 pkm ship   $ */

  PROCEDURE one_inv_g(
			wip_ent_id			NUMBER,
			level_no			NUMBER,
			ent_name	IN OUT	VARCHAR2,
			ent_id	IN OUT	NUMBER,
			qty		IN OUT	NUMBER,
			org_id	IN OUT	number,
			x_err_code OUT NUMBER,
			x_err_msg  OUT VARCHAR2) IS
/*
    -- Tuned statement (Ramana Mulpury, 05/14/99)
*/
    CURSOR get_wip_info IS
      SELECT
	lpad(we.wip_entity_name,length(we.wip_entity_name)+(4*level_no)),
             we.wip_entity_id,
	     dj.start_quantity,
	     dj.organization_id
      FROM wip_discrete_jobs dj,
	   wip_entities we
      WHERE we.wip_entity_id = wip_ent_id
      AND we.wip_entity_id = dj.wip_entity_id;
  BEGIN
    OPEN get_wip_info;
    FETCH get_wip_info INTO ent_name, ent_id, qty, org_id;
    CLOSE get_wip_info;

  EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.ONE_INV_G  '|| SUBSTR(SQLERRM,1,60);

END one_inv_g;


  PROCEDURE first_wip_g(wip_ent_id NUMBER,
			item_number IN OUT VARCHAR2,
			org_id IN OUT number,
			x_err_code	OUT NUMBER,
			x_err_msg	OUT VARCHAR2) IS
/*
  -- Modified (Ramana)
*/

-- commented out by abedajna, 10/11/00
--**  CURSOR get_ent_info IS
--**    SELECT /*+ ORDERED */
--**	msi.segment1,
--**	   dj.organization_id
--**    FROM wip_discrete_jobs dj,
--**	mtl_system_items msi
--**    WHERE dj.wip_entity_id = wip_ent_id
--**    AND dj.primary_item_id = msi.inventory_item_id
--**    AND dj.organization_id = msi.organization_id;


-- abedajna modification 10/11/00
  CURSOR get_ent_info IS
    SELECT /*+ ORDERED */
	msi.concatenated_segments,
	   dj.organization_id
    FROM wip_discrete_jobs dj,
	mtl_system_items_kfv msi
    WHERE dj.wip_entity_id = wip_ent_id
    AND dj.primary_item_id = msi.inventory_item_id
    AND dj.organization_id = msi.organization_id;




BEGIN
    OPEN get_ent_info;
    FETCH get_ent_info INTO item_number, org_id;
    CLOSE get_ent_info;

 EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.FIRST_WIP_G  '|| SUBSTR(SQLERRM,1,60);

END first_wip_g;


 PROCEDURE issue_to_wip_n(trans_id NUMBER,
		wip_ent_id IN OUT NUMBER,
		x_err_code 	OUT NUMBER,
		x_err_msg	OUT VARCHAR2) IS

  CURSOR get_wip_id IS
    SELECT
	 transaction_source_id
    FROM mtl_material_transactions
    WHERE transaction_id = trans_id
    AND transaction_source_type_id = 5;
  BEGIN
    OPEN get_wip_id;
    FETCH get_wip_id INTO wip_ent_id;
    CLOSE get_wip_id;

 EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.ISSUE_TO_WIP_N  '|| SUBSTR(SQLERRM,1,60);


END issue_to_wip_n;


  PROCEDURE fes_txn_n(trans_ref IN NUMBER,
		    lot_name IN VARCHAR2,
		    item_id IN NUMBER,
		    cur_trans_id IN OUT NUMBER,
		    next_trans_id IN OUT NUMBER,
		    next_indicator IN OUT VARCHAR2,
		    next_trans_ref IN OUT NUMBER,
		    tran_name IN OUT VARCHAR2,
		    inv_or_wip IN OUT VARCHAR2,
		    txn_type IN OUT VARCHAR2,
                    txn_type_id OUT NUMBER ,
		    x_err_code OUT NUMBER,
		    x_err_msg OUT VARCHAR2) IS

  mmt_tran_type_id NUMBER;

  CURSOR get_cur_trans_id IS
    SELECT
	max(transaction_id)
    FROM mtl_material_transactions
    WHERE source_line_id = trans_ref
    AND transaction_quantity < 0;

  CURSOR test_for_more IS
    SELECT
	MIN(transaction_id)
    FROM mtl_transaction_lot_numbers
    WHERE inventory_item_id = item_id
    AND lot_number = ltrim(lot_name)
    AND transaction_id > cur_trans_id
    AND transaction_quantity < 0;

  CURSOR next_details IS
    SELECT /*+ ORDERED */
	mmt.source_line_id,
	mmt.transaction_type_id,
	mmt.source_code
    FROM  mtl_material_transactions mmt
    WHERE  mmt.transaction_id = next_trans_id;

   /*  AND mmt.transaction_type_id = mtt.transaction_type_id; */

  BEGIN
    OPEN get_cur_trans_id;
    FETCH get_cur_trans_id INTO cur_trans_id;
    CLOSE get_cur_trans_id;

    OPEN test_for_more;
    FETCH test_for_more INTO next_trans_id;
    CLOSE test_for_more;

    IF next_trans_id IS NOT NULL
      THEN next_indicator := '+';
	   OPEN next_details;
	   FETCH next_details INTO next_trans_ref, mmt_tran_type_id, tran_name;
	   CLOSE next_details;

	   IF tran_name not like 'WSM%'
	     THEN txn_type := '';
	          inv_or_wip := 'INV';
		  next_trans_id := '';

-- Added 'Else' here to reslove Bug #1795523
-- The code following else was already there

           ELSE
	          wsm_inv_meaning_t(next_trans_ref,txn_type,txn_type_id,
					x_err_code, x_err_msg);
	       /* IF txn_type IN ('INVSplit','INVTrans','INVMerge') */
		  IF (txn_type_id IN (1,2,3))
	       	    THEN next_trans_id := next_trans_ref;
			 inv_or_wip := 'FES_INV';
	          ELSIF txn_type = 'Issue from Stores'
	            THEN inv_or_wip := 'INV';
			 SELECT
			 wip_entity_id
			 INTO next_trans_id
			 FROM wsm_sm_resulting_lots
			 WHERE transaction_id = next_trans_ref;

	      /*  ELSIF txn_type = 'SubXsfer'  */
		  ELSIF txn_type_id = 4
		    THEN inv_or_wip := 'INV';
			 txn_type := '';
			 next_trans_id := '';
	          END IF;
           END IF;
      ELSE next_indicator := '';
	   txn_type := '';
	   inv_or_wip := 'FES_INV';
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	X_err_code := 99999;
	X_err_msg :=  'NULL EXCEPTION ';
    WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.FES_TXN_N  '|| SUBSTR(SQLERRM,1,60);

  END fes_txn_n;


  PROCEDURE wip_to_complete_n(wip_ent_id NUMBER,org_id NUMBER,
			no_trans IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2 ) IS
  CURSOR wip_completion IS
    SELECT
	count(*)
    FROM mtl_transaction_lot_numbers mtln,
     	mtl_material_transactions mt
     WHERE mt.transaction_source_id = wip_ent_id
    AND mt.organization_id = org_id
    AND mt.transaction_action_id = 31
    AND mt.transaction_source_type_id = 5
    AND mtln.transaction_id = mt.transaction_id;

  BEGIN
    OPEN wip_completion;
    FETCH wip_completion INTO no_trans;
    CLOSE wip_completion;
  END wip_to_complete_n;


  PROCEDURE inv_n(item_id NUMBER,
	       lot_name VARCHAR2,
	       cur_trans_id NUMBER,
		 no_of_trans IN OUT NUMBER,
		x_err_code OUT NUMBER,
		x_err_msg OUT VARCHAR2) IS
  CURSOR check_for_more IS
    SELECT
	count(*)
    FROM mtl_transaction_lot_numbers
    WHERE lot_number = lot_name
    AND inventory_item_id = item_id
    AND transaction_id > cur_trans_id
    AND transaction_quantity < 0;
  BEGIN
    OPEN check_for_more;
    FETCH check_for_more INTO no_of_trans;
    CLOSE check_for_more;

  EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.INV_N  '|| SUBSTR(SQLERRM,1,60);

  END inv_n;


  PROCEDURE new_qty_n(trans_id NUMBER,wip_ent_id NUMBER,
			qty IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg  OUT VARCHAR2 ) IS
  CURSOR get_qty IS
    SELECT
	available_quantity
    FROM wsm_sm_starting_jobs
    WHERE wip_entity_id = wip_ent_id
    AND transaction_id = trans_id;
  BEGIN
    OPEN get_qty;
    FETCH get_qty INTO qty;
    CLOSE get_qty;

 EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.NEW_QTY_N  '|| SUBSTR(SQLERRM,1,60);

  END new_qty_n;


  PROCEDURE completed_qty_n(wip_ent_id NUMBER,
				qty IN OUT NUMBER,
				x_err_code OUT NUMBER,
				x_err_msg  OUT VARCHAR2) IS
  CURSOR get_qty IS
    SELECT
	quantity_completed
    FROM wip_discrete_jobs
    WHERE wip_entity_id = wip_ent_id;
  BEGIN
    OPEN get_qty;
    FETCH get_qty INTO qty;
    CLOSE get_qty;
 EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.COMPLETED_QTY_N  '|| SUBSTR(SQLERRM,1,60);

  END completed_qty_n;


  PROCEDURE first_wip_w(wip_ent_id NUMBER,
			item_number IN OUT VARCHAR2,
			org_id IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2) IS

-- commented out by abedajna, 10/11/00
/*  CURSOR get_ent_info IS
**    SELECT
**	msi.segment1,
**      dj.organization_id
**    FROM wip_discrete_jobs dj,
**	 mtl_system_items msi
**    WHERE dj.wip_entity_id = wip_ent_id
**    AND dj.primary_item_id = msi.inventory_item_id
**    AND dj.organization_id = msi.organization_id;
*/


-- modification by abedajna, 10/11/00
  CURSOR get_ent_info IS
    SELECT
	msi.concatenated_segments,
      dj.organization_id
    FROM wip_discrete_jobs dj,
	 mtl_system_items_kfv msi
    WHERE dj.wip_entity_id = wip_ent_id
    AND dj.primary_item_id = msi.inventory_item_id
    AND dj.organization_id = msi.organization_id;



  BEGIN
    OPEN get_ent_info;
    FETCH get_ent_info INTO item_number, org_id;
    CLOSE get_ent_info;
 EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.FIRST_WIP_W  '|| SUBSTR(SQLERRM,1,60);
  END first_wip_w;


  PROCEDURE one_inv_w(wip_ent_id NUMBER,
			level_no NUMBER,
			ent_name IN OUT VARCHAR2,
			ent_id IN OUT NUMBER,
			qty IN OUT NUMBER,
			item_number IN OUT VARCHAR2,
			org_id IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2) IS

-- commented out by abedajna, 10/11/00
--**    CURSOR get_wip_info IS
--**      SELECT
--**	lpad(we.wip_entity_name,length(we.wip_entity_name)+(4*level_no)),
--**             we.wip_entity_id,
--**	     dj.start_quantity,
--**	     msi.segment1,
--**	     dj.organization_id
--**      FROM wip_entities we,
--** 	   wip_discrete_jobs dj,
--**	   mtl_system_items msi
--**      WHERE we.wip_entity_id = wip_ent_id
--**      AND we.wip_entity_id = dj.wip_entity_id
--**      AND dj.primary_item_id = msi.inventory_item_id
--**      AND dj.organization_id = msi.organization_id;


-- modification by abedajna, 10/11/00

    CURSOR get_wip_info IS
      SELECT
	lpad(we.wip_entity_name,length(we.wip_entity_name)+(4*level_no)),
             we.wip_entity_id,
	     dj.start_quantity,
	     msi.concatenated_segments,
	     dj.organization_id
      FROM wip_entities we,
 	   wip_discrete_jobs dj,
	   mtl_system_items_kfv msi
      WHERE we.wip_entity_id = wip_ent_id
      AND we.wip_entity_id = dj.wip_entity_id
      AND dj.primary_item_id = msi.inventory_item_id
      AND dj.organization_id = msi.organization_id;



  BEGIN
    OPEN get_wip_info;
    FETCH get_wip_info INTO ent_name, ent_id, qty, item_number, org_id;
    CLOSE get_wip_info;

 EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.ONE_INV_W  '|| SUBSTR(SQLERRM,1,60);
  END one_inv_w;


  PROCEDURE subxsfer_refs_p(trans_id NUMBER,
		from_sub IN OUT VARCHAR2,
		to_sub IN OUT VARCHAR2,
		x_err_code OUT NUMBER,
		x_err_msg OUT VARCHAR2) IS
  CURSOR get_info IS
    SELECT
	starting.subinventory_code,
	   result.subinventory_code
    FROM wsm_sm_starting_lots starting,
	 wsm_sm_resulting_lots result
    WHERE starting.transaction_id = trans_id
    AND result.transaction_id = trans_id;
  BEGIN
    OPEN get_info;
    FETCH get_info INTO from_sub, to_sub;
    CLOSE get_info;
 EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.SUBXSFER_REFS_P  '|| SUBSTR(SQLERRM,1,60);


  END subxsfer_refs_p;

/********************************************************************************/
/* Changed procedure to function */

  FUNCTION complete_from_wip (trans_id NUMBER,
				x_err_code OUT NUMBER,
				x_err_msg OUT VARCHAR2) RETURN NUMBER IS

  x_wip_ent_id NUMBER;

  CURSOR get_wip_id IS
    SELECT
	transaction_source_id
    FROM mtl_material_transactions
    WHERE transaction_id = trans_id
    AND transaction_source_type_id = 5;
  BEGIN
    OPEN get_wip_id;
    FETCH get_wip_id INTO x_wip_ent_id;
    CLOSE get_wip_id;
    RETURN x_wip_ent_id;
 EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.COMPLETE_FROM_WIP  '|| SUBSTR(SQLERRM,1,60);

  END complete_from_wip;

/**********************************************************************************/

  PROCEDURE fes_txn_o(trans_ref IN NUMBER,
		    lot_name IN VARCHAR2,
		    item_id IN NUMBER,
		    cur_trans_id IN OUT NUMBER,
		    next_indicator IN OUT VARCHAR2,
		    inv_or_wip IN OUT VARCHAR2,
		    next_trans_id IN OUT NUMBER,
		    txn_type IN OUT VARCHAR2,
                    txn_type_id OUT NUMBER,
	            next_trans_ref IN OUT NUMBER,
                    tran_name IN OUT VARCHAR2,
	            wip_id IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2) IS

   tran_type_id         NUMBER ;

  CURSOR get_cur_trans_id IS
    SELECT
	MIN(mmt.transaction_id)
    FROM mtl_transaction_lot_numbers mtln,
	mtl_material_transactions mmt
    WHERE mtln.lot_number = lot_name
    AND mtln.transaction_id = mmt.transaction_id
    AND mmt.source_line_id = trans_ref;
  CURSOR test_for_more IS
    SELECT
	MAX(transaction_id)
    FROM mtl_transaction_lot_numbers
    WHERE lot_number = lot_name
    AND inventory_item_id = item_id
    AND transaction_id < cur_trans_id
    AND transaction_quantity > 0;
/*
  -- Tuned statement (Ramana Mulpury, 05/14/99)
*/
  CURSOR next_details IS
    SELECT mmt.source_line_id,
	   mmt.transaction_type_id,
           mmt.source_code,
	   mmt.transaction_source_id
    FROM  mtl_material_transactions mmt
    WHERE mmt.transaction_id = next_trans_id ;

 /* AND mmt.transaction_type_id = mtt.transaction_type_id; */

 BEGIN
    OPEN get_cur_trans_id;
    FETCH get_cur_trans_id INTO cur_trans_id;
    CLOSE get_cur_trans_id;

    OPEN test_for_more;
    FETCH test_for_more INTO next_trans_id;
    CLOSE test_for_more;

    IF next_trans_id IS NOT NULL
      THEN next_indicator := '+';
	   OPEN next_details;
	   FETCH next_details INTO next_trans_ref, tran_type_id, tran_name, wip_id;
	   CLOSE next_details;

	   IF tran_name like 'WSM%' THEN
		wsm_inv_meaning_t(next_trans_ref,txn_type,txn_type_id,
					x_err_code, x_err_msg);
	        /*  IF txn_type IN ('INVSplit','INVTrans','INVMerge')*/
		  IF (txn_type_id IN (1,2,3))
	       	    THEN next_trans_id := next_trans_ref;
			 inv_or_wip := 'FES_INV';
		  ELSIF txn_type_id = 4
		    THEN inv_or_wip := 'INV';
			 txn_type := '';
			 next_trans_id := '';
	          END IF;
	   ELSIF tran_type_id = 44
	    /* THEN txn_type := 'Complete';*/
	    THEN SELECT  transaction_type_name INTO txn_type
		 FROM mtl_transaction_types
                 WHERE transaction_type_id = 44 ;
		  inv_or_wip := 'INV';
		  next_trans_id := wip_id;
	   ELSE next_indicator := '+';
		txn_type := '';
		inv_or_wip := 'INV';
		next_trans_id := '';
           END IF;
      ELSE next_indicator := '';
	   txn_type := '';
	   inv_or_wip := 'FES_INV';
    END IF;

   EXCEPTION WHEN OTHERS THEN

	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.FES_TXN_O  '|| SUBSTR(SQLERRM,1,60);


  END fes_txn_o;


  PROCEDURE issue_from_inv_o(wip_ent_id NUMBER,
			org_id NUMBER,
			no_trans IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2) IS

-- commented out by abedajna on 10/13/00 for performance tuning.
/*
-- Tuned statement (Ramana Mulpury, 05/13/99)
*/
/*
**  CURSOR issues IS
**    SELECT 1
**    FROM sys.dual
**    WHERE exists (select 1
**                  from   mtl_transaction_lot_numbers mtln,
**                         mtl_material_transactions mt
**                  WHERE mtln.transaction_id = mt.transaction_id
**                  AND mt.transaction_source_id = wip_ent_id
**                  AND mt.organization_id = org_id
**                  AND mt.transaction_action_id = 1
**                  AND mt.transaction_source_type_id = 5);
**  BEGIN
**    OPEN issues;
**    FETCH issues INTO no_trans;
**    CLOSE issues;
**  EXCEPTION WHEN OTHERS THEN
**	X_err_code := SQLCODE;
**	X_err_msg :=  'WSMPGENE.ISSUE_FROM_INV_O  '|| SUBSTR(SQLERRM,1,60);
*/

-- modified by abedajna on 10/13/00 for performance tuning.

  BEGIN

    SELECT 1
    INTO no_trans
       FROM   mtl_transaction_lot_numbers mtln,
              mtl_material_transactions mt
       WHERE mtln.transaction_id = mt.transaction_id
       AND mt.transaction_source_id = wip_ent_id
       AND mt.organization_id = org_id
       AND mt.transaction_action_id = 1
       AND mt.transaction_source_type_id = 5;

  EXCEPTION

  WHEN TOO_MANY_ROWS THEN
  	no_trans := 1;

  WHEN NO_DATA_FOUND THEN
	NULL;

  WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.ISSUE_FROM_INV_O  '|| SUBSTR(SQLERRM,1,60);

-- end of modification by abedajna on 10/13/00 for performance tuning.


  END issue_from_inv_o;


  PROCEDURE wip_o(cur_trans_id IN NUMBER,
		wip_ent_id IN NUMBER,
		next_trans_id IN OUT NUMBER,
		x_err_code OUT NUMBER,
		x_err_msg OUT VARCHAR2) IS
/*
    -- Tuned statement (Ramana Mulpury, 05/14/99)
*/
    CURSOR find_next_id IS
       SELECT
	 max(rj.transaction_id)
	 FROM
	--bugfix 1796646, check status with error code '3', instead of with mfg_lookup
	   -- mfg_lookups lk,
	 wsm_split_merge_transactions tx,
	 wsm_sm_resulting_jobs rj
	 WHERE rj.wip_entity_id = wip_ent_id
	 AND rj.transaction_id < nvl(cur_trans_id,
				     rj.transaction_id + 1)
	 AND rj.transaction_id = tx.transaction_id
	 and tx.status <> 3;
	-- AND tx.status = lk.lookup_code
        -- AND lk.lookup_type = 'WIP_PROCESS_STATUS'
        -- AND lk.meaning <> 'Error';
        -- endfix1796646
  BEGIN
      OPEN find_next_id;
      FETCH find_next_id INTO next_trans_id;
      CLOSE find_next_id;
   EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.FIND_NEXT_ID  '|| SUBSTR(SQLERRM,1,60);


    END wip_o;


  PROCEDURE inv_o(item_id NUMBER,
	       lot_name VARCHAR2,
	       cur_trans_id NUMBER,
		no_of_trans IN OUT NUMBER,
		x_err_code OUT NUMBER,
		x_err_msg OUT VARCHAR2) IS
/*
  -- Tuned statement (Ramana Mulpury, 05/13/99)
*/

-- commented out by abedajna on 10/13/00 for performance tuning.

/*  CURSOR check_for_more IS
**    SELECT 1
**    FROM   sys.dual
**    WHERE EXISTS (SELECT 1
**                  FROM   mtl_transaction_lot_numbers
**                  WHERE lot_number = lot_name
**                  AND inventory_item_id = item_id
**                  AND transaction_id < cur_trans_id
**                  AND transaction_quantity > 0);
**  BEGIN
**    OPEN check_for_more;
**    FETCH check_for_more INTO no_of_trans;
**    CLOSE check_for_more;
**  EXCEPTION WHEN OTHERS THEN
**	X_err_code := SQLCODE;
**	X_err_msg :=  'WSMPGENE.INV_O  '|| SUBSTR(SQLERRM,1,60);
*/
-- modified by abedajna on 10/13/00 for performance tuning.

  BEGIN

    SELECT 1
    INTO no_of_trans
        FROM   mtl_transaction_lot_numbers
        WHERE lot_number = lot_name
        AND inventory_item_id = item_id
        AND transaction_id < nvl(cur_trans_id, transaction_id +1)     --bugfix1796646 added nvl.
        AND transaction_quantity > 0;


  EXCEPTION

  WHEN TOO_MANY_ROWS THEN
  	no_of_trans := 1;

  WHEN NO_DATA_FOUND THEN
	NULL;

  WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.INV_O  '|| SUBSTR(SQLERRM,1,60);

-- end of modification by abedajna on 10/13/00 for performance tuning.

  END inv_o;


  PROCEDURE new_qty_o(trans_id NUMBER,
		   wip_ent_id NUMBER,
		qty IN OUT NUMBER,
		x_err_code OUT NUMBER,
		x_err_msg OUT VARCHAR2) IS
  CURSOR get_qty IS
    SELECT
	start_quantity
    FROM wsm_sm_resulting_jobs
    WHERE wip_entity_id = wip_ent_id
    AND transaction_id = trans_id;
  BEGIN
    OPEN get_qty;
    FETCH get_qty INTO qty;
    CLOSE get_qty;
  EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.NEW_QTY_O  '|| SUBSTR(SQLERRM,1,60);

  END new_qty_o;


  PROCEDURE issued_qty_o(wip_ent_id NUMBER,
			qty IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2) IS
  CURSOR get_qty IS
    SELECT
	start_quantity
    FROM wip_discrete_jobs
    WHERE wip_entity_id = wip_ent_id;
  BEGIN
    OPEN get_qty;
    FETCH get_qty INTO qty;
    CLOSE get_qty;
  EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.ISSUED_QTY_O  '|| SUBSTR(SQLERRM,1,60);

  END issued_qty_o;

/************************************************************************/
/* This procedure has been modified to get values from mfg_lookups */

  PROCEDURE wsm_inv_meaning_t(txn_id NUMBER,
		tran_type  OUT VARCHAR2,
		wsm_inv_txn_type_id OUT NUMBER,
		x_err_code OUT NUMBER,
		x_err_msg OUT VARCHAR2) IS


  CURSOR get_meaning IS

      SELECT ml.meaning,sm.transaction_type_id
      FROM mfg_lookups ml, wsm_lot_split_merges sm
      WHERE ml.lookup_type = 'WSM_INV_LOT_TXN_TYPE'
      AND ml.lookup_code  = sm.transaction_type_id
      AND sm.transaction_id = txn_id;

  BEGIN

    OPEN get_meaning;
    FETCH get_meaning INTO tran_type ,wsm_inv_txn_type_id;
    IF get_meaning%NOTFOUND
       THEN tran_type := '';
    END IF;
    CLOSE get_meaning;

   EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.WSM_INV_MEANING_T  '|| SUBSTR(SQLERRM,1,60);
  END wsm_inv_meaning_t;

/*************************************************************************/

  PROCEDURE org_transfers_t(from_org_id NUMBER,
			to_org_id NUMBER,
			from_org_code IN OUT VARCHAR2,
			to_org_code IN OUT VARCHAR2,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2)  IS
  CURSOR get_org_names IS
    SELECT
	from_org.organization_code, to_org.organization_code
    FROM mtl_parameters from_org,
	 mtl_parameters to_org
    WHERE from_org.organization_id = from_org_id
    AND to_org.organization_id = to_org_id;
  BEGIN
    OPEN get_org_names;
    FETCH get_org_names INTO from_org_code, to_org_code;
    CLOSE get_org_names;
  EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.ORG_TRANSFERS_T  '|| SUBSTR(SQLERRM,1,60);

  END org_transfers_t;


  PROCEDURE get_next_type_id_t(id NUMBER,
				type_id IN OUT NUMBER,
				x_err_code OUT NUMBER,
				x_err_msg OUT VARCHAR2) IS
    CURSOR get_type_id IS
      SELECT
	transaction_type_id
      FROM wsm_split_merge_transactions
      WHERE transaction_id = id;
    BEGIN
      OPEN get_type_id;
      FETCH get_type_id INTO type_id;
      CLOSE get_type_id;

    EXCEPTION WHEN OTHERS THEN
	X_err_code := SQLCODE;
	X_err_msg :=  'WSMPGENE.GET_NEXT_TYPE_ID_T  '|| SUBSTR(SQLERRM,1,60);
  END get_next_type_id_t;
end WSMPGENE;

/
