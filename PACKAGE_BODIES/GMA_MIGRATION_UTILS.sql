--------------------------------------------------------
--  DDL for Package Body GMA_MIGRATION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_MIGRATION_UTILS" AS
/* $Header: GMAUMIGB.pls 120.6.12000000.2 2007/02/26 17:39:32 acataldo ship $ */



  /*====================================================================
  --  FUNCTION:
  --   GET_REASON_ID
  --
  --  DESCRIPTION:
  --    This PL/SQL procedure returns the reason_id for a given reason_code
  --
  --  PARAMETERS:
  --    p_reason_code        IN Parameter for the reason_code
  --      --
  --  SYNOPSIS:
  --
  --    X_reason_id := GET_REASON_ID (  p_reason_code => l_reason_code);
  --
  --  HISTORY
  --    5/23/2005 - NC
  --====================================================================*/
  FUNCTION get_reason_id (p_reason_code IN VARCHAR2) RETURN NUMBER IS
    CURSOR  reason_id_cur(p_reason_code IN VARCHAR2) IS
      SELECT  reason_id
      FROM sy_reas_cds_b
      WHERE reason_code = p_reason_code;
    X_reason_Id NUMBER(15);
  BEGIN
    OPEN reason_id_cur(p_reason_code);
    FETCH reason_id_cur INTO x_reason_id;
    CLOSE reason_id_cur;
    RETURN (X_reason_id);
  END get_reason_id;
  /*====================================================================
  --  FUNCTION:
  --    get_organization_id
  --
  --  DESCRIPTION:
  --    This PL/SQL procedure is used to fetch the Organization id to
  --    a specific orgn code.
  --
  --
  --  PARAMETERS:
  --    P_orgn_code  - Organization code will be used to fetch the orgn id
  --
  --  SYNOPSIS:
  --    fetch_organization(p_orgn_code IN VARCHARE) RETURN NUMBER;
  --
  --  HISTORY
  --====================================================================*/
  FUNCTION get_organization_id (P_orgn_code IN VARCHAR2) RETURN NUMBER IS
    CURSOR Cur_get_orgn_id IS
      SELECT organization_id
      FROM   sy_orgn_mst
      WHERE  orgn_code = P_orgn_code;
    X_organization_id	NUMBER;
  BEGIN
    OPEN Cur_get_orgn_id;
    FETCH Cur_get_orgn_id INTO X_organization_id;
    CLOSE Cur_get_orgn_id;
    RETURN(X_organization_id);
  END get_organization_id;
  /*====================================================================
  --  FUNCTION:
  --    get_uom_code
  --
  --  DESCRIPTION:
  --    This PL/SQL procedure is used to fetch the 3 character uom code to
  --    OPM's 4 character UOM code.
  --
  --
  --  PARAMETERS:
  --    P_um_code  - Organization code will be used to fetch the orgn id
  --
  --  SYNOPSIS:
  --    fetch_organization(p_orgn_code IN VARCHARE) RETURN NUMBER;
  --
  --  HISTORY
  --====================================================================*/
  FUNCTION get_uom_code (P_um_code IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR Cur_get_uom_code IS
      SELECT uom_code
      FROM   sy_uoms_mst
      WHERE  um_code = P_um_code;
    X_uom_code	VARCHAR2(3);
  BEGIN
    OPEN Cur_get_uom_code;
    FETCH Cur_get_uom_code INTO X_uom_code;
    CLOSE Cur_get_uom_code;
    RETURN(X_uom_code);
  END get_uom_code;
  /*====================================================================
  --  PROCEDURE:
  --   GMA_EDIT_TEXT_MIGRATION
  --
  --  DESCRIPTION:
  --    This PL/SQL procedure is used to migration OPM Reason Codes
  --
  --  PARAMETERS:
  --    p_migration_run_id   This is used for message logging.
  --    p_commit             Commit flag.
  --    x_failure_count      count of the failed lines.An out parameter.
  --
  --  SYNOPSIS:
  --
  --    GMA_EDIT_TEXT_MIGRATION (  p_migration_run_id  IN NUMBER
  --                             , p_commit IN VARCHAR2
  --                             , x_failure_count OUT NUMBER)
  --
  --  HISTORY
  --    5/23/2005 - nchekuri
  --    2/26/2007 - acataldo  - Bug 5736539 - setup text table correctly
  --====================================================================*/
  PROCEDURE GMA_EDIT_TEXT_MIGRATION (  err_buf OUT NOCOPY varchar2
				                   ,   ret_code OUT NOCOPY number
				                   ,   migration_var IN varchar2
		                            ) IS
-- Variables defenition
    l_failure_count NUMBER := 0;
    l_success_count NUMBER := 0;
    l_table_name    VARCHAR2(30) DEFAULT NULL;
    l_opm_table_name VARCHAR2(30) DEFAULT NULL;
    p_error varchar2(3000);
    p_warning varchar2(3000);
    -- Variables used for the AD Event Registry
    l_event_owner varchar2(100);
    l_event_name varchar2(100);
    l_module_name varchar2(100);
    p_commit varchar2(10) := FND_API.G_TRUE;
    -- Variables to take care of the FND Logging
    l_dummy_cnt BINARY_INTEGER;
    i BINARY_INTEGER;
    l_count BINARY_INTEGER;
    l_msg_data varchar2(1000);
    mig_entity varchar2(20);


/* We'll define one cursor for each entity for which Edit Text needs to be migrated. */

--
--- As this prgram need to be run as a concurrent program
--- Removing all the GMA Logging
--


/* ic_item_mst */
--
--- Cursor for the item text_code migration
--


    CURSOR item_mst_cur IS
      SELECT ic.text_code,
             ic.item_no,
	     msi.inventory_item_id,
             msi.organization_id,
             msi.segment1
       FROM  mtl_system_items msi,
             mtl_parameters p,
             ic_item_mst ic
      WHERE  msi.segment1 = ic.item_no
        AND  msi.organization_id = p.master_organization_id
        AND  p.organization_id = p.master_organization_id
        AND  ic.text_code IS NOT NULL;
--
--- Cursor for the lot text_code migraiton
--
    CURSOR lot_mst_cur IS
      SELECT p.lot_number,
             itm.INVENTORY_ITEM_ID,
	     p.organization_id,
	     ic.text_code
       FROM  ic_item_mst_b_mig itm,
             mtl_lot_numbers  msi,
             IC_LOTS_MST_MIG p,
             IC_LOTS_MST ic
      WHERE  p.lot_number = msi.lot_number
             AND p.item_id = itm.item_id
	     AND p.lot_id = ic.lot_id
	     AND p.organization_id = itm.organization_id
             AND  ic.text_code IS NOT NULL;
--
--- Cursor for the grades
--
    CURSOR grd_mst_cur IS
      SELECT mgb.grade_code,
             opm.text_code
       FROM  MTL_GRADES_B MGB,
             GMD_GRADES_B opm
       WHERE  opm.qc_grade = mgb.grade_code
       AND  opm.text_code IS NOT NULL;

--
--- Cursor for the action codes
--
    CURSOR act_mst_cur IS
      SELECT mac.action_code,
             opm.text_code
       FROM  MTL_ACTIONS_B MAC,
             GMD_ACTIONS_B opm
       WHERE  opm.action_code = mac.action_code
       AND  opm.text_code IS NOT NULL;

--
--- Cursor for the Rason Codes migration
--

     CURSOR reas_mst_cur IS
         SELECT src.text_code,
                 src.reason_id,
		 src.reason_code
          FROM SY_REAS_CDS_B src
          WHERE src.text_code IS NOT NULL
	  and src.reason_id <> 0;
--
--- Cursor for the Organization Codes migration
--
     CURSOR org_mst_cur IS
         SELECT som.text_code,
                som.organization_id,
		som.orgn_code
          FROM SY_ORGN_MST som
          WHERE som.text_code IS NOT NULL
	  and som.migrate_as_ind=3;


BEGIN

--
--- Initialize the FND logging
--
FND_MSG_PUB.initialize;

--
--- Begin by logging a message that reason_code migration has started */
--

/* Put the FND logging here  for the start of the migration*/

	      FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_MIG_STARTED');
              FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',migration_var,FALSE);
              FND_MSG_PUB.ADD;
--
--- Prepare the case statement
--

IF migration_var = 'ITEM' or migration_var='ALL'  THEN

l_event_owner := 'GMA';
l_event_name := 'GMA_ITEM';
l_module_name := 'GMA_ITEM';
l_failure_count := 0;
mig_entity:='ITEM';
IF AD_EVENT_REGISTRY_PKG.Is_Event_Done (p_Owner=>l_event_owner,
                                        p_Event_Name=>l_event_name) = FALSE   THEN

    /* Edit Text Migration for Item Master */
    l_table_name := 'MTL_SYSTEM_ITEMS';
    l_opm_table_name := 'IC_ITEM_MST';

    FOR l_item_mst_rec IN item_mst_cur LOOP
    BEGIN
         /* Call the Attachment_main procedure */

         GMA_EDITEXT_ATTACH_MIG.Attachment_Main (
	                        p_text_table_tl          => 'ic_text_tbl_tl',      /* OPMs Text Table */
	                        p_text_code              => l_item_mst_rec.text_code, /* text code to be migrated */
	                        p_sy_para_cds_table_name => l_opm_table_name,      /* Table name in OPM */
	                        p_attach_form_short_name => 'INVIDITM',         /* Form name in Apps */
	                        p_attach_table_name      => l_table_name, /* Table name in Apps */
	                        p_attach_pk1_value       => l_item_mst_rec.organization_id,
	                        p_attach_pk2_value       => l_item_mst_rec.inventory_item_id,
	                        p_attach_pk3_value       =>  NULL,
	                        p_attach_pk4_value       =>  NULL,
	                        p_attach_pk5_value       =>  NULL);

      EXCEPTION
         WHEN OTHERS THEN
             /* Failure count goes up by 1 */
             l_failure_count := l_failure_count+1;
	    -- Update the CCM logs

	     FND_MESSAGE.SET_NAME('GMA', 'GMA_TEXT_CODE_FAILURE');
             FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
             FND_MSG_PUB.ADD;

             IF (FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', NULL)) THEN
                   NULL;
             END IF;
      END;
  END LOOP; /* For item_mst_rec */

  if l_failure_count = 0 then
    AD_EVENT_REGISTRY_PKG.Set_Event_As_Done (
                       p_Owner=>l_event_owner,
                       p_Event_Name=>l_event_name,
                       p_module_Name=>l_module_name);

	      FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_MIG_COMPLETED');
              FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
              FND_MSG_PUB.ADD;

   else
	      FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_ERROR');
              FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
              FND_MESSAGE.SET_TOKEN('ERROR_COUNT',l_failure_count,FALSE);
              FND_MSG_PUB.ADD;

  end if;

ELSE

 FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_ALREADY_MIGRATED');
 FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
 FND_MSG_PUB.ADD;

END IF;

END IF;

--
--- For the Lot Text Code migraiton
--

IF migration_var = 'LOT' or migration_var='ALL' then

l_event_owner := 'GMA';
l_event_name := 'GMA_LOT_TXT_CDE_MIG';
l_module_name := 'GMA_LOT_TEXT_CODE_MIGRATION';
l_failure_count := 0;
mig_entity:='LOT';
IF (AD_EVENT_REGISTRY_PKG.Is_Event_Done (
	                        p_Owner=>l_event_owner,
	                        p_Event_Name=>l_event_name) = FALSE)  THEN

   /* Edit Text Migration for Lot Master */
    l_table_name := 'MTL_LOT_NUMBERS';
    l_opm_table_name := 'IC_LOTS_MST';
    FOR l_lot_mst_rec IN lot_mst_cur LOOP
     BEGIN
         /* Call the Attachment_main procedure */
         GMA_EDITEXT_ATTACH_MIG.Attachment_Main (
	                        p_text_table_tl          => 'ic_text_tbl_tl',      /* OPMs Text Table */
	                        p_text_code              => l_lot_mst_rec.text_code, /* text code to be migrated */
	                        p_sy_para_cds_table_name => l_opm_table_name,      /* Table name in OPM */
	                        p_attach_form_short_name => 'INVIDILT',         /* Form name in Apps */
	                        p_attach_table_name      => l_table_name, /* Table name in Apps */
	                        p_attach_pk1_value       => l_lot_mst_rec.organization_id,
	                        p_attach_pk2_value       => l_lot_mst_rec.inventory_item_id,
	                        p_attach_pk3_value       => l_lot_mst_rec.lot_number,
	                        p_attach_pk4_value       =>  NULL,
	                        p_attach_pk5_value       =>  NULL
	                    );
      EXCEPTION
         WHEN OTHERS THEN
             /* Failure count goes up by 1 */
             l_failure_count := l_failure_count+1;
	     -- Update the CCM Logs
	     FND_MESSAGE.SET_NAME('GMA', 'GMA_TEXT_CODE_FAILURE');
             FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
             FND_MSG_PUB.ADD;

             IF (FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', NULL)) THEN
                   NULL;
             END IF;
      END;
  END LOOP; /* For lot_mst_rec */
  if l_failure_count = 0 then
    AD_EVENT_REGISTRY_PKG.Set_Event_As_Done (
                       p_Owner=>l_event_owner,
                       p_Event_Name=>l_event_name,
                       p_module_Name=>l_module_name);

	      FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_MIG_COMPLETED');
              FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
              FND_MSG_PUB.ADD;

   else
	      FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_ERROR');
              FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
              FND_MESSAGE.SET_TOKEN('ERROR_COUNT',l_failure_count,FALSE);
              FND_MSG_PUB.ADD;

  end if;
ELSE
 FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_ALREADY_MIGRATED');
 FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
 FND_MSG_PUB.ADD;
END IF;

END IF;
--
--- For the GRADES Text Code migraiton
--

 IF migration_var = 'GRADES' or migration_var='ALL' then

 l_event_owner := 'GMA';
 l_event_name := 'GMA_GRD_TXT_CODE_MIG';
 l_module_name := 'GMA_GRADES_TEXT_CODE_MIGRATION';
 mig_entity:='GRADES';
 l_failure_count:=0;

IF (AD_EVENT_REGISTRY_PKG.Is_Event_Done (
	                        p_Owner=>l_event_owner,
	                        p_Event_Name=>l_event_name) = FALSE)  THEN
   /* Edit Text Migration for Grades */
    l_table_name := 'MTL_GRADES_B';
    l_opm_table_name := 'GMD_GRADES';
    FOR l_grd_mst_rec IN grd_mst_cur LOOP
     BEGIN
         /* Call the Attachment_main procedure */
         GMA_EDITEXT_ATTACH_MIG.Attachment_Main (
                                p_text_table_tl          => 'qc_text_tbl_tl',      /* OPMs Text Table */
                                p_text_code              => l_grd_mst_rec.text_code, /* text code to be migrated */
	                        p_sy_para_cds_table_name => l_opm_table_name,      /* Table name in OPM */
                                p_attach_form_short_name => 'INVGRADE',         /* Form name in Apps */
	                        p_attach_table_name      => l_table_name, /* Table name in Apps */
	                        p_attach_pk1_value       => l_grd_mst_rec.grade_code,
	                        p_attach_pk2_value       => NULL,
	                        p_attach_pk3_value       => NULL,
	                        p_attach_pk4_value       =>  NULL,
	                        p_attach_pk5_value       =>  NULL
	                    );
      EXCEPTION
         WHEN OTHERS THEN
             /* Failure count goes up by 1 */
             l_failure_count := l_failure_count+1;
	     -- Update the CCM logs
	     FND_MESSAGE.SET_NAME('GMA', 'GMA_TEXT_CODE_FAILURE');
             FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
             FND_MSG_PUB.ADD;

             FND_FILE.NEW_LINE(FND_FILE.LOG,1);
             IF (FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', NULL)) THEN
                   NULL;
             END IF;
      END;
  END LOOP; /* For lot_mst_rec */
  if l_failure_count = 0 then
    AD_EVENT_REGISTRY_PKG.Set_Event_As_Done (
                       p_Owner=>l_event_owner,
                       p_Event_Name=>l_event_name,
                       p_module_Name=>l_module_name);

	      FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_MIG_COMPLETED');
              FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
              FND_MSG_PUB.ADD;

   else
	      FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_ERROR');
              FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
              FND_MESSAGE.SET_TOKEN('ERROR_COUNT',l_failure_count,FALSE);
              FND_MSG_PUB.ADD;

  end if;
ELSE
 FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_ALREADY_MIGRATED');
 FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
 FND_MSG_PUB.ADD;

END IF;
END IF;

--
--- For the ACTION codes Text Code migraiton
--

IF migration_var = 'ACTION' or migration_var='ALL' then

 l_event_owner := 'GMA';
 l_event_name := 'GMA_ACT_TXT_CODE_MIG';
 l_module_name := 'GMA_ACTION_TEXT_CODE_MIGRATION';
 mig_entity:='ACTION';
 l_failure_count:=0;

IF (AD_EVENT_REGISTRY_PKG.Is_Event_Done (
	                        p_Owner=>l_event_owner,
	                        p_Event_Name=>l_event_name) = FALSE)  THEN
   /* Edit Text Migration for Grades */
    l_table_name := 'MTL_ACTIONS_B';
    l_opm_table_name := 'QC_ACTN_MST';
    FOR l_act_mst_rec IN act_mst_cur LOOP
     BEGIN
         /* Call the Attachment_main procedure */
         GMA_EDITEXT_ATTACH_MIG.Attachment_Main (
                                p_text_table_tl          => 'qc_text_tbl_tl',      /* OPMs Text Table */
                                p_text_code              => l_act_mst_rec.text_code, /* text code to be migrated */
                                p_sy_para_cds_table_name => l_opm_table_name,      /* Table name in OPM */
                                p_attach_form_short_name => 'INVACODE',         /* Form name in Apps */
                                p_attach_table_name      => l_table_name, /* Table name in Apps */
                                p_attach_pk1_value       => l_act_mst_rec.action_code,
                                p_attach_pk2_value       => NULL,
	      p_attach_pk3_value       => NULL,
	      p_attach_pk4_value       =>  NULL,
	      p_attach_pk5_value       =>  NULL
	                    );
      EXCEPTION
         WHEN OTHERS THEN
             /* Failure count goes up by 1 */
             l_failure_count := l_failure_count+1;
	     -- Update the CCM logs
	     FND_MESSAGE.SET_NAME('GMA', 'GMA_TEXT_CODE_FAILURE');
             FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
             FND_MSG_PUB.ADD;

             FND_FILE.NEW_LINE(FND_FILE.LOG,1);
             IF (FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', NULL)) THEN
                   NULL;
             END IF;
      END;
  END LOOP; /* For act_mst_rec */
  if l_failure_count = 0 then
    AD_EVENT_REGISTRY_PKG.Set_Event_As_Done (
                       p_Owner=>l_event_owner,
                       p_Event_Name=>l_event_name,
                       p_module_Name=>l_module_name);

	      FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_MIG_COMPLETED');
              FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
              FND_MSG_PUB.ADD;

   else
	      FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_ERROR');
              FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
              FND_MESSAGE.SET_TOKEN('ERROR_COUNT',l_failure_count,FALSE);
              FND_MSG_PUB.ADD;

  end if;
ELSE
 FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_ALREADY_MIGRATED');
 FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
 FND_MSG_PUB.ADD;

END IF;
END IF;

--
--- REASONS text code migration
--
IF migration_var = 'REASON CODE' or migration_var='ALL' then

 l_event_owner := 'GMA';
 l_event_name  := 'GMA_REAS_TXT_CDE_MIG';
 l_module_name := 'GMA_REAS_TXT_CDE_MIG';
 mig_entity:='REASON CODES';
 l_failure_count:=0;

IF (AD_EVENT_REGISTRY_PKG.Is_Event_Done (
	                        p_Owner=>l_event_owner,
	                        p_Event_Name=>l_event_name) = FALSE)  THEN
   /* Edit Text Migration for Grades */
    l_table_name := 'MTL_TRANSACTION_REASONS';
    l_opm_table_name := 'SY_REAS_CDS';
    FOR l_reas_mst_rec IN reas_mst_cur LOOP
     BEGIN
         /* Call the Attachment_main procedure */
         /* Bug 5736539 setup text table to the correct sy text table */
         GMA_EDITEXT_ATTACH_MIG.Attachment_Main (
                                p_text_table_tl          => 'sy_text_tbl_tl',      /* OPMs Text Table */
                                p_text_code              => l_reas_mst_rec.text_code, /* text code to be migrated */
	                        p_sy_para_cds_table_name => l_opm_table_name,      /* Table name in OPM */
                                p_attach_form_short_name => 'INVTDTRS',         /* Form name in Apps */
	                        p_attach_table_name      => l_table_name, /* Table name in Apps */
	                        p_attach_pk1_value       => l_reas_mst_rec.REASON_ID,
	                        p_attach_pk2_value       => NULL,
	                        p_attach_pk3_value       => NULL,
	                        p_attach_pk4_value       =>  NULL,
	                        p_attach_pk5_value       =>  NULL
	                    );
      EXCEPTION
         WHEN OTHERS THEN
             /* Failure count goes up by 1 */
             l_failure_count := l_failure_count+1;
	     -- Update the CCM logs

	     FND_MESSAGE.SET_NAME('GMA', 'GMA_TEXT_CODE_FAILURE');
             FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
             FND_MSG_PUB.ADD;


             FND_FILE.NEW_LINE(FND_FILE.LOG,1);
             IF (FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', NULL)) THEN
                   NULL;
             END IF;
      END;
  END LOOP; /* For lot_mst_rec */
  if l_failure_count = 0 then
    AD_EVENT_REGISTRY_PKG.Set_Event_As_Done (
                       p_Owner=>l_event_owner,
                       p_Event_Name=>l_event_name,
                       p_module_Name=>l_module_name);

	      FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_MIG_COMPLETED');
              FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
              FND_MSG_PUB.ADD;

   else
	      FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_ERROR');
              FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
              FND_MESSAGE.SET_TOKEN('ERROR_COUNT',l_failure_count,FALSE);
              FND_MSG_PUB.ADD;

  end if;

ELSE
 FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_ALREADY_MIGRATED');
 FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
 FND_MSG_PUB.ADD;

END IF;
END IF;
--
--- Organization Text Code migration
--

IF migration_var = 'ORGANIZATION' or migration_var='ALL' then

 l_event_owner := 'GMA';
 l_event_name  := 'GMA_ORG_TXT_CDE_MIG';
 l_module_name := 'GMA_ORG_TXT_CDE_MIG';
 mig_entity:='ORGANIZATION';
 l_failure_count:=0;

IF (AD_EVENT_REGISTRY_PKG.Is_Event_Done (
	                        p_Owner=>l_event_owner,
	                        p_Event_Name=>l_event_name) = FALSE)  THEN
   /* Edit Text Migration for Grades */
    l_table_name := 'MTL_PARAMETERS';
    l_opm_table_name := 'SY_ORGN_MST';
    FOR l_org_mst_rec IN org_mst_cur LOOP
     BEGIN
         /* Call the Attachment_main procedure */
         /* Bug 5736539 setup text table to the correct sy text table */
         GMA_EDITEXT_ATTACH_MIG.Attachment_Main (
                                p_text_table_tl          => 'sy_text_tbl_tl',      /* OPMs Text Table */
                                p_text_code              => l_org_mst_rec.text_code, /* text code to be migrated */
	                        p_sy_para_cds_table_name => l_opm_table_name,      /* Table name in OPM */
                                p_attach_form_short_name => 'PERWSDOR',         /* Form name in Apps */
	                        p_attach_table_name      => l_table_name, /* Table name in Apps */
	                        p_attach_pk1_value       => l_org_mst_rec.ORGANIZATION_ID,
	                        p_attach_pk2_value       => NULL,
	                        p_attach_pk3_value       => NULL,
	                        p_attach_pk4_value       =>  NULL,
	                        p_attach_pk5_value       =>  NULL
	                    );
      EXCEPTION
         WHEN OTHERS THEN
             /* Failure count goes up by 1 */
             l_failure_count := l_failure_count+1;
	     -- Update the CCM logs

	     FND_MESSAGE.SET_NAME('GMA', 'GMA_TEXT_CODE_FAILURE');
             FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
             FND_MSG_PUB.ADD;


             FND_FILE.NEW_LINE(FND_FILE.LOG,1);
             IF (FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', NULL)) THEN
                   NULL;
             END IF;
      END;
  END LOOP; /* For lot_mst_rec */
  if l_failure_count = 0 then
    AD_EVENT_REGISTRY_PKG.Set_Event_As_Done (
                       p_Owner=>l_event_owner,
                       p_Event_Name=>l_event_name,
                       p_module_Name=>l_module_name);

	      FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_MIG_COMPLETED');
              FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
              FND_MSG_PUB.ADD;

   else
	      FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_ERROR');
              FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
              FND_MESSAGE.SET_TOKEN('ERROR_COUNT',l_failure_count,FALSE);
              FND_MSG_PUB.ADD;

  end if;

ELSE
 FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_ALREADY_MIGRATED');
 FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',mig_entity,FALSE);
 FND_MSG_PUB.ADD;

END IF;
END IF;
--
--- If commit flag is set do the commit
--
IF p_commit = FND_API.G_TRUE THEN
      COMMIT;
END IF;

--
--- Update for the Concurrent logs for the completion of update
--
 FND_MESSAGE.SET_NAME('GMA','GMA_TEXT_CODE_MIG_FINISHED');
 FND_MSG_PUB.ADD;

--
--- Log the message to the FND log
--

l_count := FND_MSG_PUB.Count_Msg;
 FOR i IN 1..l_count LOOP
     FND_MSG_PUB.Get(
         p_msg_index     => i,
         p_data          => l_msg_data,
         p_encoded       => FND_API.G_FALSE,
         p_msg_index_out => l_dummy_cnt);

     FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
     FND_FILE.NEW_LINE(FND_FILE.LOG,1);
 END LOOP;

--
--- When exception then
--

EXCEPTION
    WHEN OTHERS THEN
	     FND_MESSAGE.SET_NAME('GMA', 'GMA_TEXT_CODE_FAILURE');
             FND_MESSAGE.SET_TOKEN('MIGRATION_ENTITY',migration_var,FALSE);
             FND_MSG_PUB.ADD;



END GMA_EDIT_TEXT_MIGRATION;
END gma_migration_utils;

/
