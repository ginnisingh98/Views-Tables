--------------------------------------------------------
--  DDL for Package Body EGO_MASS_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_MASS_UPDATE_PVT" AS
/* $Header: EGOMUPGB.pls 120.6 2006/08/14 12:59:18 supsrini noship $ */

  --Debug Profile option used to write Error_Handler.Write_Debug
  --Profile option name = INV_DEBUG_TRACE ; User Profile Option Name = INV: Debug Trace
  --Value: 1 (True) ; 0 (False)
  G_DEBUG CONSTANT NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);



--========================================================================
-- PROCEDURE :  Item_Org_Assignment     PUBLIC
-- PARAMETERS:  p_batch_id           IN  NUMBER          Batch Id for records in Temp Tables
--              p_all_request_ids    OUT NOCOPY VARCHAR2 Concatenated Request Ids
--             ,x_return_status      OUT NOCOPY VARCHAR2 Standard OUT Parameter
--             ,x_msg_count          OUT NOCOPY NUMBER   Standard OUT Parameter
--             ,x_msg_data           OUT NOCOPY VARCHAR2 Standard OUT Parameter
--
-- DESCRIPTION   : This procedure Assigns Items to Organizations in
--		   in Mass Update flows. Items and Orgs for the assignment are
--		   obtained from temporary tables
--=========================================================================

PROCEDURE  item_org_assignment
    ( p_batch_id           IN  NUMBER
     ,p_all_request_ids    OUT NOCOPY VARCHAR2
     ,x_return_status      OUT NOCOPY VARCHAR2
     ,x_msg_count          OUT NOCOPY NUMBER
     ,x_msg_data           OUT NOCOPY VARCHAR2
    )
IS

    -- This parameter determines how many Item-Org pairs are included in one batch
     -- Commented for Bug 5464843
--    l_max_batch_size NUMBER;

    -- Set_process_id
    l_set_process_id NUMBER;

    -- set_process_id for each batch of item-org pairs
    -- Commented for Bug 5464843
--    l_batch_set_process_id NUMBER;

    -- This is the Organization In Context
    -- PUOM Query requires In-Context Org
    l_in_context_organization_id NUMBER;

    l_master_organization_id NUMBER;

    -- Concurrent request id
    l_request_id NUMBER;

    -- Concurrent request submission exception
    l_submit_failure_exc   EXCEPTION;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get the set_process_id
    -- This will be the initial set_process_id which will
    -- be changed in the update loop
    -- Can we avoid this select and directly use the seq val
    -- Using currval in the insert may perhaps give diff values if nextval is used elsewhere?
    SELECT  mtl_system_items_intf_sets_s.NEXTVAL
    INTO  l_set_process_id
    FROM  dual;

    Write_Debug('In Item Org Assignment API');

    -- Commented for Bug 5464843
/*    l_max_batch_size := NVL( TO_NUMBER (FND_PROFILE.Value('INV_CCEOI_COMMIT_POINT') )
                             , 1000
                           );
*/

    --Write_Debug('INV_CCEOI_COMMIT_POINT = '||l_max_batch_size);

    --In Context org - For primary uom defaulting
    SELECT DISTINCT organization_id
    INTO l_in_context_organization_id
    FROM ego_massupdate_item_tmp
    WHERE batch_id = p_batch_id;

    -- =====================================================================
    -- Insert all Item-Org pairs into Item Open Interface Table - MSII with
    -- the same set_process_id. This will be changed in update loop.
    -- =====================================================================

    INSERT INTO mtl_system_items_interface
		(  process_flag
           	 , set_process_id
          	 , transaction_type
          	 , inventory_item_id
          	 , item_number -- added for Item-Org assignment across master orgs
          	 , description -- added for Item-Org assignment across master orgs
          	 , organization_id
          	 , primary_uom_code
          	 , primary_unit_of_measure
          	 , cost_of_sales_account
          	 , encumbrance_account
          	 , sales_account
          	 , expense_account
          	 , last_update_date
          	 , last_updated_by
          	 , creation_date
          	 , created_by
          	 , last_update_login
          	 , request_id
          	 , program_application_id
          	 , program_id
          	 , program_update_date
          	 )
    SELECT 	1, --Process_Flag
		l_set_process_id, --SET_PROCESS_ID
		'CREATE', --TXN_TYPE
		emit.inventory_item_id, --ITEM_ID
		emit.item_number,
		emit.description,
		emot.organization_id_child, --ORG_ID
	 	NVL( (SELECT msib.primary_uom_code
	        	FROM mtl_system_items_b msib, mtl_parameters mp
			WHERE msib.organization_id = mp.master_organization_id
			AND mp.organization_id = emot.organization_id_child
			AND msib.inventory_item_id = emit.inventory_item_id),
             	      (SELECT msib2.primary_uom_code
			FROM mtl_system_items_b msib2
			WHERE msib2.organization_id = emit.organization_id
			AND msib2.inventory_item_id = emit.inventory_item_id)
			) UOM_CODE,
	 	NVL( (SELECT msib.primary_unit_of_measure -- Can We avoid this second select
	        	FROM mtl_system_items_b msib, mtl_parameters mp
			WHERE msib.organization_id = mp.master_organization_id
			AND mp.organization_id = emot.organization_id_child
			AND msib.inventory_item_id = emit.inventory_item_id),
             	     (SELECT msib2.primary_unit_of_measure
			FROM mtl_system_items_b msib2
			WHERE msib2.organization_id = emit.organization_id
			AND msib2.inventory_item_id = emit.inventory_item_id)
			), --PUOM
		mp.cost_of_sales_account,
		mp.encumbrance_account,
		mp.sales_account,
		mp.expense_account,
        	SYSDATE,
        	FND_GLOBAL.user_id,
        	SYSDATE,
        	FND_GLOBAL.user_id,
        	FND_GLOBAL.login_id,
        	FND_GLOBAL.conc_request_id,
        	FND_GLOBAL.prog_appl_id,
        	FND_GLOBAL.conc_program_id,
        	SYSDATE
    FROM ego_massupdate_item_tmp emit,
	 ego_massupdate_org_tmp emot,
	 mtl_parameters mp
    WHERE NOT EXISTS
	  (SELECT '1'
	  FROM mtl_system_items_b msib
	  WHERE msib.organization_id = emot.organization_id_child
	  AND msib.inventory_item_id = emit.inventory_item_id)
    AND emit.selected_flag = 'Y'
    AND emot.org_selected_flag = 'Y'
    AND mp.organization_id = emot.organization_id_child
    AND emot.batch_id = p_batch_id
    AND emot.batch_id = emit.batch_id;

    -- ===========================================================
    -- Now within a loop update each batch of item orgs in MSII
    -- with a particular set_process_id
    -- Also insert these records into MIRI with the starting revision
    -- ===========================================================

-- Commented for Bug 5464843
--    LOOP -- Item-Org Batch
        -- ========================================================
	-- Now updating each batch in MSII
	-- ========================================================

	-- Can we avoid this select and directly use the seq value
	-- If used directly then error 'Exact fetch return more than one row' occurs
	-- because for each row the sequence value is being incremented

/*	SELECT  mtl_system_items_intf_sets_s.NEXTVAL
	INTO  l_batch_set_process_id
	FROM  dual;

	UPDATE mtl_system_items_interface
	SET set_process_id = l_batch_set_process_id
	WHERE set_process_id = l_set_process_id
	AND ROWNUM <= l_max_batch_size;


	-- If no more rows are left to be updated then exit the loop
	IF (SQL%ROWCOUNT = 0) THEN
	  	Write_Debug('REQUEST HAS BEEN SUBMITTED FOR ALL BATCHES');
		EXIT;
	END IF;

        -- ===========================================================
        -- Insert corresponing data into Revisions interface table
	-- Item_id , org_id ... are derived from MSII
	-- These are the same item-org pairs which are included
	-- under set_process_id = l_batch_set_process_id
        -- ===========================================================

       	INSERT INTO mtl_item_revisions_interface
          	 ( inventory_item_id
          	 , item_number -- added for Item-Org assignment across master orgs
          	 , description -- added for Item-Org assignment across master orgs
          	 , organization_id
          	 , revision
          	 , implementation_date
          	 , effectivity_date
          	 , transaction_id
          	 , process_flag
          	 , transaction_type
          	 , set_process_id
          	 , last_update_date
          	 , last_updated_by
          	 , creation_date
          	 , created_by
          	 , last_update_login
          	 , request_id
          	 , program_application_id
          	 , program_id
          	 , program_update_date
          	 )
	SELECT
		   msii.inventory_item_id
          	 , msii.item_number
          	 , msii.description
          	 , msii.organization_id
		 , mp.starting_revision
		 , SYSDATE
		 , SYSDATE
		 , MTL_SYSTEM_ITEMS_INTERFACE_S.nextval --- TRANSACTION_ID
		 , 1
		 , 'CREATE'
		 , l_set_process_id   --l_batch_set_process_id
		 , SYSDATE
          	 , FND_GLOBAL.user_id
          	 , SYSDATE
          	 , FND_GLOBAL.user_id
          	 , FND_GLOBAL.login_id
          	 , FND_GLOBAL.conc_request_id
          	 , FND_GLOBAL.prog_appl_id
          	 , FND_GLOBAL.conc_program_id
          	 , SYSDATE
	FROM mtl_system_items_interface msii,
	     mtl_parameters mp
	WHERE msii.set_process_id = l_set_process_id
	AND mp.organization_id = msii.organization_id;

*/
	-- ====================================================
	-- Now submit the concurrent request for this batch
	-- ====================================================

--Commented for Bug 5464843
/*	--set the options for the request submission
	IF NOT FND_REQUEST.Set_Options
        	   	  ( implicit  => 'WARNING'
           		  , protected => 'YES'
           		  )
    	THEN
      		RAISE l_submit_failure_exc;
    	END IF;
*/
    --Commented for Bug 4719882
	--PRAGMA AUTONOMOUS_TRANSACTION;

	   -- submit the request
	   l_request_id := FND_REQUEST.Submit_Request
                              ( application => 'INV'
                              , program     => 'INCOIN'
                              , argument1   => null
                              , argument2   => 1
                              , argument3   => 1
                              , argument4   => 1
                              , argument5   => 2
      --5464843               , argument6   => l_batch_set_process_id
		              , argument6   => l_set_process_id
                              , argument7   => 1
                              );
	 --Commented for Bug  5464843
	 -- p_all_request_ids := p_all_request_ids||' '||l_request_id;
	 p_all_request_ids := ' ' || l_request_id;

	COMMIT;

--	Write_Debug('Completed processing for Batch with set_process_id = '||l_batch_set_process_id || ' and Conc Req Id = '||l_request_id);

  --  END LOOP; -- Item-Org Batch
   --Commented for Bug  5464843


    Write_Debug('Completed processing all Batches; Conc Req Ids are = '||p_all_request_ids);

EXCEPTION

    WHEN l_submit_failure_exc THEN
	Write_Debug('Exception while submitting request');
	x_return_status := FND_API.G_RET_STS_ERROR;
	x_msg_count     := 1;
	x_msg_data      := SQLERRM;

    WHEN OTHERS THEN
	Write_Debug('WHEN OTHERS Exception');
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_msg_count     := 1;
	x_msg_data      := SQLERRM;


END item_org_assignment;

--========================================================================
-- PROCEDURE :  Write_Debug
-- PARAMETERS:  p_msg  IN  VARCHAR2
--
-- DESCRIPTION   : Debug Message Logger
--=========================================================================

PROCEDURE Write_Debug (p_msg  IN  VARCHAR2) IS
BEGIN

  --If Profile set to TRUE
  IF (G_DEBUG = 1) THEN
     Error_Handler.Write_Debug(p_msg);
  END IF;

END;

PROCEDURE clear_temp_tables(  errbuf OUT NOCOPY VARCHAR2,
                              retcode OUT NOCOPY NUMBER,
                              hours NUMBER) IS
BEGIN

  IF(hours is NULL) then
     errbuf := 'Provide a valid value for hours';
     retcode :=2;
     FND_FILE.put_line(FND_FILE.log,errbuf);
     RETURN;
  END IF;

  DELETE ego_massupdate_item_tmp where to_date(to_char (creation_date,'hh24:mi:ss
  dd-mm-yyyy'),'hh24:mi:ss dd-mm-yyyy') < to_date(to_char (sysdate-hours/24,'hh24:mi:ss
  dd-mm-yyyy'),'hh24:mi:ss dd-mm-yyyy');

  DELETE ego_massupdate_org_tmp where to_date(to_char (creation_date,'hh24:mi:ss
  dd-mm-yyyy'),'hh24:mi:ss dd-mm-yyyy') < to_date(to_char (sysdate-hours/24,'hh24:mi:ss
  dd-mm-yyyy'),'hh24:mi:ss dd-mm-yyyy');

  COMMIT;

END clear_temp_tables;

END EGO_MASS_UPDATE_PVT;

/
