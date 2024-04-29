--------------------------------------------------------
--  DDL for Package Body BOM_COMPONENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_COMPONENT_API" AS
/* $Header: BOMOICMB.pls 115.31 2002/12/05 19:01:19 sanmani ship $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMOICMB.pls                                               |
| DESCRIPTION  : This package contains functions used to assign, validate   |
|                and transact Compoennt data in the                         |
|		 BOM_INVENTORY_COMPS_INTERFACE table.			    |
| Parameters:   org_id          organization_id                             |
|               all_org         process all orgs or just current org        |
|                               1 - all orgs                                |
|                               2 - only org_id                             |
|               prog_appid      program application_id                      |
|               prog_id         program id                                  |
|               req_id          request_id                                  |
|               user_id         user id                                     |
|               login_id        login id                                    |
| History:                                                                  |
|    03/17/97   Julie Maeyama   Created this new package		    |
+==========================================================================*/

/* --------------------------- Assign_Component -----------------------------*/
/*
NAME
    Assign_Component
DESCRIPTION
    Assign defaults and ID's to Component record in the interface table
REQUIRES
    err_text    out buffer to return error message
MODIFIES
    BOM_INVENTORY_COMPS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Assign_Component (
    org_id              NUMBER,
    all_org             NUMBER := 2,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT  NOCOPY VARCHAR2
)
    return INTEGER
IS
    stmt_num            NUMBER := 0;
    ret_code            NUMBER;
    commit_cnt          NUMBER;
    curr_org_code       VARCHAR2(3);
    default_wip_value   VARCHAR2(1);
    continue_loop       BOOLEAN := TRUE;
    X_dummy             NUMBER;
    x_bom_item_type     NUMBER;
    x_current_date	DATE;
    x_rollup_flag	VARCHAR2(1);
    x_atp_flag		VARCHAR2(1);
    x_atp_comp_flag     VARCHAR2(1);
    x_check_atp_default NUMBER;
    x_pick_components   VARCHAR2(1);
/*
** Select all INSERTS
*/
    CURSOR c1 IS
       SELECT organization_code OC, organization_id OI,
              assembly_item_id AII, assembly_item_number AIN,
              alternate_bom_designator ABD, bill_sequence_id BSI,
              component_sequence_id CSI, transaction_id TI,
              component_item_id CII, component_item_number CIN,
              location_name LN, supply_locator_id SLI,
              operation_seq_num OSN,
              to_char(effectivity_date, 'YYYY/MM/DD HH24:MI:SS') ED,
              bom_item_type BIT, transaction_type A, WIP_SUPPLY_TYPE WST,
	      supply_subinventory SS
         FROM bom_inventory_comps_interface
        WHERE process_flag = 1
          AND transaction_type = G_Insert
          AND (UPPER(interface_entity_type) = 'BILL'
	       OR interface_entity_type is null)
          AND (all_org = 1
               OR
               (all_org = 2 and organization_id = org_id))
          AND rownum < G_rows_to_commit;

/*
** Select UPDATES and DELETES
*/
    CURSOR c2 IS
       SELECT organization_code OC, organization_id OI,
              assembly_item_id AII, assembly_item_number AIN,
              alternate_bom_designator ABD, bill_sequence_id BSI,
              component_sequence_id CSI, transaction_id TI,
              component_item_id CII, component_item_number CIN,
              location_name LN, supply_locator_id SLI,
              operation_seq_num OSN, assembly_type AST,
              to_char(effectivity_date, 'YYYY/MM/DD HH24:MI:SS') ED,
              bom_item_type BIT, transaction_type A
         FROM bom_inventory_comps_interface
        WHERE process_flag = 1
          AND transaction_type in (G_UPDATE, G_DELETE)
          AND (UPPER(interface_entity_type) = 'BILL'
	       OR interface_entity_type is null)
          AND (all_org = 1
               OR
               (all_org = 2 and organization_id = org_id))
          AND rownum < G_rows_to_commit;

BEGIN
   /** G_INSERT is 'CREATE'. Update 'INSERT' to 'CREATE' **/
   stmt_num := 0.5 ;
   LOOP
      UPDATE bom_inventory_comps_interface
         SET transaction_type = G_Insert
       WHERE process_flag = 1
         AND upper(transaction_type) = 'INSERT'
         AND rownum < G_rows_to_commit;
      EXIT when SQL%NOTFOUND;
      COMMIT;
   END LOOP;

/*
** ALL RECORDS - Assign Org Id
*/
   stmt_num := 1;
   LOOP
      UPDATE bom_inventory_comps_interface ori
         SET organization_id = (SELECT organization_id
                                  FROM mtl_parameters a
                             WHERE a.organization_code = ori.organization_code)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Insert, G_Delete, G_Update)
         AND (UPPER(ori.interface_entity_type) = 'BILL'
	       OR ori.interface_entity_type is null)
         AND organization_id is null
         AND organization_code is not null
         AND exists (SELECT organization_code
                       FROM mtl_parameters b
                      WHERE b.organization_code = ori.organization_code)
         AND rownum < G_rows_to_commit;
      EXIT when SQL%NOTFOUND;
      COMMIT;
   END LOOP;

/*
** FOR INSERTS - Assign transaction ids
*/
   stmt_num := 1;
   LOOP
      UPDATE bom_inventory_comps_interface
         SET transaction_id = mtl_system_items_interface_s.nextval,
             component_sequence_id = bom_inventory_components_s.nextval,
             transaction_type = upper(transaction_type)
       WHERE transaction_id is null
         AND process_flag = 1
         AND upper(transaction_type) = G_Insert
         AND (UPPER(interface_entity_type) = 'BILL'
	       OR interface_entity_type is null)
         AND rownum < G_rows_to_commit;
      EXIT when SQL%NOTFOUND;

      stmt_num := 2;
      COMMIT;
   END LOOP;

/*
** FOR UPDATES and DELETES - Assign transaction ids
*/
   stmt_num := 1;
   LOOP
      UPDATE bom_inventory_comps_interface
         SET transaction_id = mtl_system_items_interface_s.nextval,
             transaction_type = upper(transaction_type)
       WHERE transaction_id is null
         AND process_flag = 1
         AND upper(transaction_type) in (G_UPDATE, G_DELETE)
         AND (UPPER(interface_entity_type) = 'BILL'
	       OR interface_entity_type is null)
         AND rownum < G_rows_to_commit;
      EXIT when SQL%NOTFOUND;

      stmt_num := 2;
      COMMIT;
   END LOOP;

/*
** FOR INSERTS - Assign values
*/
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c1rec IN c1 LOOP
         commit_cnt := commit_cnt + 1;
         x_bom_item_type := null;
         x_rollup_flag   := null;
	 x_atp_flag      := null;
         x_atp_comp_flag := null;
 	 x_pick_components := null;
         stmt_num := 3;
/*
** Check if Org ID null
*/
         IF (c1rec.OI is null
             AND (c1rec.BSI is null OR c1rec.CII is null)) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_ORG_ID_MISSING',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            GOTO continue_loop;
         END if;
         stmt_num := 4;

/*
** Get Assembly Id
*/
         stmt_num := 5;
         IF  (c1rec.AII is null AND c1rec.BSI is null) THEN
            ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id => c1rec.OI,
                flex_code => 'MSTK',
                flex_name => c1rec.AIN,
                flex_id => c1rec.AII,
                set_id => -1,
                err_text => err_text);
            IF (ret_code <> 0) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_ASSY_ITEM_MISSING',
                        err_text => err_text);
               UPDATE bom_inventory_comps_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop;
            END IF;
         END IF;

/*
** Get Bill Sequence Id
*/
         IF (c1rec.BSI is null) THEN
            stmt_num := 7;
            BEGIN
               SELECT bom.bill_sequence_id, msi.bom_item_type,
		      msi.atp_components_flag
                 INTO c1rec.BSI, x_bom_item_type, x_atp_comp_flag
                 FROM bom_bill_of_materials bom,
		      mtl_system_items msi
                WHERE bom.organization_id = c1rec.OI
                  AND bom.assembly_item_id = c1rec.AII
                  AND nvl(bom.alternate_bom_designator, 'NONE') =
		     nvl(c1rec.ABD, 'NONE')
		  AND msi.organization_id = bom.organization_id
		  AND msi.inventory_item_id = bom.assembly_item_id;
            EXCEPTION
	       WHEN no_data_found THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_BILL_SEQ_MISSING',
                        err_text => err_text);
                  UPDATE bom_inventory_comps_interface
                     SET process_flag = 3
                   WHERE transaction_id = c1rec.TI;

                  IF (ret_code <> 0) THEN
                     RETURN(ret_code);
                  END IF;
                  GOTO continue_loop;
            END;
/*
** Get Bill Info
*/
         ELSE                     /* Needed for verify */
            stmt_num := 8;
	    BEGIN
               SELECT bom.assembly_item_id, bom.organization_id,
		      bom.alternate_bom_designator, msi.bom_item_type,
		      msi.atp_components_flag
                 INTO c1rec.AII, c1rec.OI, c1rec.ABD, x_bom_item_type,
		      x_atp_comp_flag
                 FROM bom_bill_of_materials bom,
		      mtl_system_items msi
                WHERE bom.bill_sequence_id = c1rec.BSI
		  AND msi.organization_id = bom.organization_id
		  AND msi.inventory_item_id = bom.assembly_item_id;
            EXCEPTION
	       WHEN no_data_found THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_BILL_SEQ_MISSING',
                        err_text => err_text);
                  UPDATE bom_inventory_comps_interface
                     SET process_flag = 3
                   WHERE transaction_id = c1rec.TI;

                  IF (ret_code <> 0) THEN
                     RETURN(ret_code);
                  END IF;
                  GOTO continue_loop;
            END;
         END IF;
/*
** Get Component Id
*/
         stmt_num := 9;
         IF (c1rec.CII is null) THEN
            ret_code := INVPUOPI.mtl_pr_trans_prod_item(
                        c1rec.CIN,
                        c1rec.OI,
                        c1rec.CII,
                        err_text);
            IF (ret_code <> 0) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMP_ID_MISSING',
                        err_text => err_text);
               UPDATE bom_inventory_comps_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop;
            END IF;
         END IF;

/*
** Set WIP_SUPPLY_TYPE to 1 if Profile BOM:DEFAULT_WIP_VALUES set to YES.
*/
         stmt_num := 9.5;
         IF (c1rec.WST is null) THEN
            BOMPRFIL.bom_pr_get_profile(
             	appl_short_name => 'BOM',
		profile_name => 'BOM:DEFAULT_WIP_VALUES',
		user_id => user_id,
		resp_appl_id => prog_appid,
	    	resp_id => 702,
		profile_value => default_wip_value,
		return_code => ret_code,
		return_message => err_text);
            IF (default_wip_value = '1')
	    THEN
		BEGIN
			-- If the profile value is Yes i.e 1, then
			-- get the wip values from item master
		        SELECT wip_supply_type, wip_supply_subinventory,
			       wip_supply_locator_id
                	  INTO c1rec.wst, c1rec.SS, c1rec.SLI
                	  FROM   mtl_system_items
                	 WHERE organization_id = c1rec.OI
                	   AND inventory_item_id = c1rec.CII;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
                	ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMP_ID_MISSING',
                        err_text => err_text);

                  	UPDATE bom_inventory_comps_interface
                     	SET process_flag = 3
                  	WHERE transaction_id = c1rec.TI;
                  	IF (ret_code <> 0) THEN
                   		RETURN(ret_code);
                  	END IF;
               	  	GOTO continue_loop;
		END;
            END IF;

            IF (ret_code <> 0) THEN
                 err_text := 'Bom_Component_Api(Assign-'||stmt_num||') '||
                              err_text;
                 RETURN(ret_code);
            END IF;
         END IF;


/*
** Check if Component exists in Item Master
*/
         BEGIN
            stmt_num := 10;
            BEGIN
               SELECT bom_item_type, default_include_in_rollup_flag,
		      atp_flag, pick_components_flag
                 INTO c1rec.BIT, x_rollup_flag, x_atp_flag, x_pick_components
                 FROM mtl_system_items
                WHERE organization_id = c1rec.OI
                  AND inventory_item_id = c1rec.CII;
            EXCEPTION
               WHEN no_data_found THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMP_ID_MISSING',
                        err_text => err_text);
                  UPDATE bom_inventory_comps_interface
                     SET process_flag = 3
                   WHERE transaction_id = c1rec.TI;

                  IF (ret_code <> 0) THEN
                     RETURN(ret_code);
                  END IF;
                  GOTO continue_loop;
               WHEN others THEN
                  err_text := 'Bom_Component_Api(Assign-'||stmt_num||') '||
                              substrb(SQLERRM, 1, 60);
                  RETURN(SQLCODE);
            END;
         END;
/*
** Check if bill of Product Family
*/
         IF (x_bom_item_type = G_ProductFamily) THEN
	    GOTO update_member;
         END IF;
/*
** Check if Effective Date null
*/
         IF (c1rec.ED is null) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_EFF_DATE_MISSING',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            GOTO continue_loop;
         END IF;
/*
** Get Supply Locator Id
*/
         stmt_num := 10.1;
         IF (c1rec.SLI is null AND c1rec.LN is not null) THEN
            ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id => c1rec.OI,
                flex_code => 'MTLL',
                flex_name => c1rec.LN,
                flex_id => c1rec.SLI,
                set_id => -1,
                err_text => err_text);
            IF (ret_code <> 0) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_LOCATION_NAME_INVALID',
                        err_text => err_text);
               UPDATE bom_inventory_comps_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop;
            END IF;
         END IF;
/*
** Update Component with defaults and derived values
*/
         stmt_num := 11;

/* Bug 2243418 */
/*
         IF (x_atp_comp_flag = 'Y' AND x_atp_flag = 'Y') THEN
            x_check_atp_default := 1;
         ELSE
            x_check_atp_default := 2;
         END IF;
*/
         IF (x_atp_flag = 'N') THEN
            x_check_atp_default := 2;
         ELSE
            x_check_atp_default := 1;
         END IF;

/* end Bug 2243418 */
         UPDATE bom_inventory_comps_interface
            SET component_item_id = nvl(component_item_id, c1rec.CII),
                                        item_num = nvl(item_num, 1),
                component_quantity = nvl(component_quantity, 1),
                component_yield_factor = nvl(component_yield_factor, 1),
                implementation_date = effectivity_date,
                planning_factor = nvl(planning_factor, 100),
                quantity_related = nvl(quantity_related, 2),
                so_basis = nvl(so_basis, 2),
                optional = nvl(optional, 2),
                mutually_exclusive_options = nvl(mutually_exclusive_options,2),
                include_in_cost_rollup = nvl(include_in_cost_rollup, decode(nvl(x_rollup_flag, 'Y'),'Y', 1, 2)),
                check_atp = nvl(check_atp, x_check_atp_default),
                required_to_ship = nvl(required_to_ship, 2),
                required_for_revenue = nvl(required_for_Revenue, 2),
                include_on_ship_docs = nvl(include_on_ship_docs, 2),
                include_on_bill_docs = nvl(include_on_bill_docs, 2),
                low_quantity = nvl(low_quantity, nvl(high_quantity,null)),
                high_quantity = nvl(high_quantity,nvl(low_quantity,null)),
                bill_sequence_id = nvl(bill_Sequence_id, c1rec.BSI),
                pick_components = decode(x_pick_components, 'Y', 1, 2),
		wip_supply_type = NVL(wip_supply_type, c1rec.wst),
		supply_subinventory = NVL(supply_subinventory, c1rec.ss),
                supply_locator_id = nvl(supply_locator_id, c1rec.SLI),
                assembly_item_id = nvl(assembly_item_id, c1rec.AII),
                alternate_bom_designator = nvl(alternate_bom_designator,
			c1rec.ABD),
                organization_id = nvl(organization_id, c1rec.OI),
                creation_date = nvl(creation_date, sysdate),
                created_by = nvl(created_by, user_id),
                last_update_date = nvl(last_update_date, sysdate),
                last_updated_by = nvl(last_updated_by, user_id),
                last_update_login = nvl(last_update_login, user_id),
                request_id = nvl(request_id, req_id),
                program_application_id =nvl(program_application_id,prog_appid),
                program_id = nvl(program_id, prog_id),
                program_update_date = nvl(program_update_date, sysdate),
                process_flag = 2,
                bom_item_type = c1rec.BIT
          WHERE transaction_id = c1rec.TI;

          GOTO continue_loop;
<<update_member>>
/*
** Update Product Family Member with defaults and derived values
*/
         x_current_date := trunc(sysdate);
         IF (x_atp_comp_flag = 'Y' AND x_atp_flag = 'Y') THEN
            x_check_atp_default := 1;
         ELSE
            x_check_atp_default := 2;
         END IF;
         stmt_num := 11.1;

         UPDATE bom_inventory_comps_interface
            SET component_item_id 	 = nvl(component_item_id, c1rec.CII),
                bill_sequence_id 	 = nvl(bill_Sequence_id, c1rec.BSI),
                assembly_item_id         = nvl(assembly_item_id, c1rec.AII),
                alternate_bom_designator = nvl(alternate_bom_designator,
					       c1rec.ABD),
                organization_id 	 = nvl(organization_id, c1rec.OI),
		operation_seq_num 		= 1,
                item_num 			= 1,
                component_quantity 		= 1,
                component_yield_factor  	= 1,
                planning_factor 		= nvl(planning_factor,100),
                quantity_related 		= 2,
                so_basis 			= 2,
                optional 			= 2,
                mutually_exclusive_options 	= 2,
                required_to_ship 		= 2,
                required_for_revenue 		= 2,
                include_on_ship_docs 		= 2,
		effectivity_date 		= nvl(trunc(effectivity_date),
						  x_current_date),
                implementation_date 		= nvl(trunc(effectivity_date),
						  x_current_date),
                include_in_cost_rollup 		= decode(nvl(x_rollup_flag,
						  'Y'),'Y', 1, 2),
                check_atp 			= x_check_atp_default,
                pick_components 		= decode(x_pick_components,
						  'Y', 1, 2),
                bom_item_type 			= c1rec.BIT,
                supply_locator_id 		= null,
                low_quantity 			= null,
                high_quantity 			= null,
 		change_notice 			= null,
		shipping_allowed 		= null,
		acd_type 			= null,
		old_component_sequence_id 	= null,
		wip_supply_type 		= null,
		supply_subinventory 		= null,
		operation_lead_time_percent 	= null,
		revised_item_sequence_id 	= null,
		cost_factor 			= null,
		substitute_comp_id		= null,
		substitute_comp_number		= null,
		reference_designator		= null,
                creation_date = nvl(creation_date, sysdate),
                created_by = nvl(created_by, user_id),
                last_update_date = nvl(last_update_date, sysdate),
                last_updated_by = nvl(last_updated_by, user_id),
                last_update_login = nvl(last_update_login, user_id),
                request_id = nvl(request_id, req_id),
                program_application_id =nvl(program_application_id,prog_appid),
                program_id = nvl(program_id, prog_id),
                program_update_date = nvl(program_update_date, sysdate),
                process_flag = 2
          WHERE transaction_id = c1rec.TI;
<<continue_loop>>
         NULL;
      END LOOP;

      stmt_num := 13;
      COMMIT;
      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;

   END LOOP;

/*
** FOR UPDATES and DELETES - Assign values
*/

   continue_loop := TRUE;
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c2rec IN c2 LOOP
         commit_cnt := commit_cnt + 1;
         stmt_num := 3;
         x_bom_item_type := null;
/*
** Assign primary key info
*/
         IF (c2rec.CSI is null) THEN
            IF (c2rec.BSI is null) THEN
               -- Check if Org Id is null
               IF (c2rec.OI is null) THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_ORG_ID_MISSING',
                        err_text => err_text);
                  UPDATE bom_inventory_comps_interface
                     SET process_flag = 3
                   WHERE transaction_id = c2rec.TI;

                  IF (ret_code <> 0) THEN
                     RETURN(ret_code);
                  END IF;
                  GOTO continue_loop1;
               END IF;
/*
** Get Assembly Id
*/
               -- Get Assembly Item Id
               stmt_num := 3;
               IF (c2rec.AII is null) THEN
                  ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                     org_id => c2rec.OI,
                     flex_code => 'MSTK',
                     flex_name => c2rec.AIN,
                     flex_id => c2rec.AII,
                     set_id => -1,
                     err_text => err_text);
                  IF (ret_code <> 0) THEN
                     ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c2rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_INV_ITEM_ID_MISSING',
                        err_text => err_text);
                     UPDATE bom_inventory_comps_interface
                        SET process_flag = 3
                      WHERE transaction_id = c2rec.TI;

                     IF (ret_code <> 0) THEN
                        RETURN(ret_code);
                     END IF;
                     GOTO continue_loop1;
                  END IF;
               END IF;
/*
** Get Bill Sequence Id
*/
               stmt_num := 7;
               BEGIN
                  SELECT bom.bill_sequence_id, bom.assembly_type,
			 msi.bom_item_type
                    INTO c2rec.BSI, c2rec.AST, x_bom_item_type
                    FROM bom_bill_of_materials bom,
			 mtl_system_items msi
                   WHERE bom.organization_id = c2rec.OI
                     AND bom.assembly_item_id = c2rec.AII
                     AND nvl(bom.alternate_bom_designator, 'NONE') =
		        nvl(c2rec.ABD, 'NONE')
		     AND msi.organization_id = bom.organization_id
		     AND msi.inventory_item_id = bom.assembly_item_id;
               EXCEPTION
	          WHEN no_data_found THEN
                     ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c2rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_BILL_SEQ_MISSING',
                        err_text => err_text);
                     UPDATE bom_inventory_comps_interface
                        SET process_flag = 3
                      WHERE transaction_id = c2rec.TI;

                     IF (ret_code <> 0) THEN
                        RETURN(ret_code);
                     END IF;
                     GOTO continue_loop1;
               END;
/*
** Get Bill Info
*/
            ELSE  -- Bill Seq Id is given
               stmt_num := 8;
   	       BEGIN
                  SELECT bom.assembly_item_id, bom.organization_id,
		         bom.alternate_bom_designator, bom.assembly_type,
			 msi.bom_item_type
                    INTO c2rec.AII, c2rec.OI, c2rec.ABD, c2rec.AST,
			 x_bom_item_type
                    FROM bom_bill_of_materials bom,
			 mtl_system_items msi
                   WHERE bom.bill_sequence_id = c2rec.BSI
		     AND msi.organization_id = bom.organization_id
		     AND msi.inventory_item_id = bom.assembly_item_id;
               EXCEPTION
		  WHEN no_data_found THEN
                     ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_BILL_SEQ_MISSING',
                        err_text => err_text);
                     UPDATE bom_inventory_comps_interface
                        SET process_flag = 3
                      WHERE transaction_id = c2rec.TI;

                     IF (ret_code <> 0) THEN
                        RETURN(ret_code);
                     END IF;
                     GOTO continue_loop1;
               END;
            END IF;
/*
** Get Component Id
*/
            stmt_num := 9;
            IF (c2rec.CII is null) THEN
               ret_code := INVPUOPI.mtl_pr_trans_prod_item(
                        c2rec.CIN,
                        c2rec.OI,
                        c2rec.CII,
                        err_text);
               IF (ret_code <> 0) THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMP_ID_MISSING',
                        err_text => err_text);
                  UPDATE bom_inventory_comps_interface
                     SET process_flag = 3
                   WHERE transaction_id = c2rec.TI;

                  IF (ret_code <> 0) THEN
                     RETURN(ret_code);
                  END IF;
                  GOTO continue_loop1;
               END IF;
            END IF;
/*
** Get Component Seq Id
*/
            stmt_num := 10;
            BEGIN
               SELECT component_sequence_id
                 INTO c2rec.CSI
                 FROM bom_inventory_components
                WHERE bill_sequence_id = c2rec.BSI
                  AND component_item_id = c2rec.CII
                  AND operation_seq_num = decode(x_bom_item_type,
		      G_ProductFamily, 1, c2rec.OSN)
                  AND effectivity_date = to_date(c2rec.ED,
						 'YYYY/MM/DD HH24:MI:SS');
	    EXCEPTION
  	       WHEN no_data_found THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                      org_id => NULL,
                      user_id => user_id,
                      login_id => login_id,
                      prog_appid => prog_appid,
                      prog_id => prog_id,
                      req_id => req_id,
                      trans_id => c2rec.TI,
                      error_text => err_text,
                      tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                      msg_name => 'BOM_COMP_SEQ_MISSING',
                      err_text => err_text);
                  UPDATE bom_inventory_comps_interface
                     SET process_flag = 3
                   WHERE transaction_id = c2rec.TI;

                  IF (ret_code <> 0) THEN
                     RETURN(ret_code);
                  END IF;
                  GOTO continue_loop1;
            END;
/*
** Get Bill and Component Info
*/
         ELSE  -- Component_Sequence_Id is given
            BEGIN
               SELECT bbom.assembly_item_id, bbom.organization_id,
                      bbom.bill_sequence_id,
                      bbom.alternate_bom_designator, bbom.assembly_type,
                      bic.component_item_id, msi.bom_item_type
                 INTO c2rec.AII, c2rec.OI, c2rec.BSI, c2rec.ABD, c2rec.AST,
                      c2rec.CII, x_bom_item_type
                 FROM mtl_system_items msi,
		      bom_bill_of_materials bbom,
                      bom_inventory_components bic
                WHERE bbom.bill_sequence_id = bic.bill_sequence_id
                  AND bic.component_sequence_id = c2rec.CSI
		  AND msi.organization_id = bbom.organization_id
		  AND msi.inventory_item_id = bbom.assembly_item_id;
            EXCEPTION
               WHEN no_data_found THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                      org_id => NULL,
                      user_id => user_id,
                      login_id => login_id,
                      prog_appid => prog_appid,
                      prog_id => prog_id,
                      req_id => req_id,
                      trans_id => c2rec.TI,
                      error_text => err_text,
                      tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                      msg_name => 'BOM_COMP_SEQ_MISSING',
                      err_text => err_text);
                  UPDATE bom_inventory_comps_interface
                     SET process_flag = 3
                   WHERE transaction_id = c2rec.TI;

                  IF (ret_code <> 0) THEN
                     RETURN(ret_code);
                  END IF;
                  GOTO continue_loop1;
            END;
         END IF;
/*
** FOR UPDATES - Assign Supply Locator
*/
	IF (c2rec.A = G_UPDATE) THEN
/*
** For Product Family Members
*/
            IF (x_bom_item_type = G_ProductFamily) THEN
               stmt_num := 10.1;
               UPDATE bom_inventory_comps_interface
                  SET component_sequence_id = c2rec.CSI,
                      component_item_id = c2rec.CII,
                      bill_sequence_id = c2rec.BSI,
                      organization_id = c2rec.OI,
                      assembly_item_id = c2rec.AII,
                      alternate_bom_designator = c2rec.ABD,
                      assembly_type = c2rec.AST,
                      last_update_date = nvl(last_update_date, sysdate),
                      last_updated_by = nvl(last_updated_by, user_id),
                      last_update_login = nvl(last_update_login, user_id),
                      request_id = nvl(request_id, req_id),
                      program_application_id =nvl(program_application_id,
						  prog_appid),
                      program_id = nvl(program_id, prog_id),
                      program_update_date = nvl(program_update_date, sysdate),
                      process_flag = 2
                WHERE transaction_id = c2rec.TI;

               IF (SQL%NOTFOUND) THEN
                  err_text := 'Bom_Component_Api(' ||stmt_num|| ')'||
		    	      substrb(SQLERRM,1,60);
                  RETURN(SQLCODE);
               END IF;
               GOTO continue_loop1;
            ELSE
/*
** Get Supply Locator Id
*/
               stmt_num := 6;
               IF (c2rec.SLI is null AND c2rec.LN is not null) THEN
                  ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                     org_id => c2rec.OI,
                     flex_code => 'MTLL',
                     flex_name => c2rec.LN,
                     flex_id => c2rec.SLI,
                     set_id => -1,
                     err_text => err_text);
                  IF (ret_code <> 0) THEN
                     ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_LOCATION_NAME_INVALID',
                        err_text => err_text);
                     UPDATE bom_inventory_comps_interface
                        SET process_flag = 3
                      WHERE transaction_id = c2rec.TI;

                     IF (ret_code <> 0) THEN
                        RETURN(ret_code);
                     END IF;
                     GOTO continue_loop1;
                  END IF;
               END IF;
            END IF;
/*
** Update "Update" record
*/
            stmt_num := 11;
            UPDATE bom_inventory_comps_interface
               SET component_sequence_id = c2rec.CSI,
                   component_item_id = c2rec.CII,
                   bill_sequence_id = c2rec.BSI,
                   organization_id = c2rec.OI,
                   assembly_item_id = c2rec.AII,
                   alternate_bom_designator = c2rec.ABD,
                   assembly_type = c2rec.AST,
                   supply_locator_id = c2rec.SLI,
                   implementation_date = nvl(new_effectivity_date, NULL),
                   last_update_date = nvl(last_update_date, sysdate),
                   last_updated_by = nvl(last_updated_by, user_id),
                   last_update_login = nvl(last_update_login, user_id),
                   request_id = nvl(request_id, req_id),
                   program_application_id =nvl(program_application_id,
						  prog_appid),
                   program_id = nvl(program_id, prog_id),
                   program_update_date = nvl(program_update_date, sysdate),
                   process_flag = 2
             WHERE transaction_id = c2rec.TI;

            IF (SQL%NOTFOUND) THEN
               err_text := 'Bom_Component_Api(' ||stmt_num|| ')'||
			   substrb(SQLERRM,1,60);
               RETURN(SQLCODE);
            END IF;
         ELSIF (c2rec.A = G_DELETE) THEN
            stmt_num := 8;
            UPDATE bom_inventory_comps_interface
               SET component_sequence_id = c2rec.CSI,
                   component_item_id = c2rec.CII,
                   bill_sequence_id = c2rec.BSI,
                   organization_id = c2rec.OI,
                   assembly_item_id = c2rec.AII,
                   alternate_bom_designator = c2rec.ABD,
                   assembly_type = c2rec.AST,
                   process_flag = 2
             WHERE transaction_id = c2rec.TI;

            IF (SQL%NOTFOUND) THEN
               err_text := 'Bom_Component_Api('||stmt_num||')'||
			    substrb(SQLERRM, 1, 60);
               RETURN(SQLCODE);
            END IF;
         END IF;

<<continue_loop1>>
         NULL;
      END LOOP;

      stmt_num := 13;
      COMMIT;
      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;

   END LOOP;

/*
** INSERTS ONLY - Load rows from component interface into sub comp interface
*/
   stmt_num := 1;
   INSERT into bom_sub_comps_interface (
        SUBSTITUTE_COMPONENT_ID,
        SUBSTITUTE_COMP_NUMBER,
        ORGANIZATION_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        COMPONENT_SEQUENCE_ID,
        PROCESS_FLAG,
        TRANSACTION_TYPE,
        SUBSTITUTE_ITEM_QUANTITY)
      SELECT
             SUBSTITUTE_COMP_ID,
             SUBSTITUTE_COMP_NUMBER,
             ORGANIZATION_ID,
             NVL(LAST_UPDATE_DATE, SYSDATE),
             NVL(LAST_UPDATED_BY, user_id),
             NVL(CREATION_DATE,SYSDATE),
             NVL(CREATED_BY, user_id),
             NVL(LAST_UPDATE_LOGIN, user_id),
             NVL(REQUEST_ID, req_id),
             NVL(PROGRAM_APPLICATION_ID, prog_appid),
             NVL(PROGRAM_ID, prog_id),
             NVL(PROGRAM_UPDATE_DATE, sysdate),
             COMPONENT_SEQUENCE_ID,
             1,
	     G_Insert,
             COMPONENT_QUANTITY
        FROM bom_inventory_comps_interface
       WHERE process_flag = 2
         AND transaction_type = G_Insert
         AND (UPPER(interface_entity_type) = 'BILL'
	       OR interface_entity_type is null)
         AND (substitute_comp_id is not null
              OR
              substitute_comp_number is not null);

   COMMIT;

/*
** INSERTS ONLY - Load rows from component interface into ref desgs interface
*/
   stmt_num := 1;
   INSERT INTO bom_ref_desgs_interface (
        COMPONENT_REFERENCE_DESIGNATOR,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        COMPONENT_SEQUENCE_ID,
        TRANSACTION_TYPE,
        PROCESS_FLAG)
   SELECT
        REFERENCE_DESIGNATOR,
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, user_id),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
        NVL(REQUEST_ID, req_id),
        NVL(PROGRAM_APPLICATION_ID, prog_appid),
        NVL(PROGRAM_ID, prog_id),
        NVL(PROGRAM_UPDATE_DATE, sysdate),
        COMPONENT_SEQUENCE_ID,
	G_Insert,
        1
    FROM bom_inventory_comps_interface
   WHERE process_flag = 2
     AND transaction_type = G_Insert
     AND (UPPER(interface_entity_type) = 'BILL'
	       OR interface_entity_type is null)
     AND reference_designator is not null;

   COMMIT;

   RETURN (0);
EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Component_Api(Assign-'||stmt_num||') '||substrb(SQLERRM,1,500);
      RETURN(SQLCODE);
END Assign_Component;

/*---------------------- Verify_Component_Count ------------------------*/

/* Bug: 2372788 Component count under a bill cannot exceed 9999 */

FUNCTION Verify_Component_Count
(  bill_seq_id       IN  NUMBER,
   err_text         OUT  NOCOPY VARCHAR2
)
return NUMBER IS

  l_total               NUMBER := 0;

BEGIN

  SELECT count(*) INTO l_total FROM bom_inventory_components WHERE
  bill_sequence_id = bill_seq_id;

  IF l_total > 9999 THEN
    err_text := 'Bom_Component_Api(ComponentCount): Total number of components exceeds 9999 for this bill';
    Return 9999;
  END IF;

  err_text := NULL;
  Return 0;

  EXCEPTION WHEN others THEN
    err_text := 'Bom_Component_Api(ComponentCount) '||substrb(SQLERRM,1,60);
    RETURN(SQLCODE);

END Verify_Component_Count;


/*---------------------- Verify_Unique_Component ------------------------*/
/*
NAME
   Verify_Unique_Component
DESCRIPTION
   verifies if the given component sequence id is unique in prod and
        interface tables
REQUIRES
    cmp_seq_id  component sequence id
    exist_flag  1 - check for existence
                2 - check for uniqueness
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Verify_Unique_Component (
    cmp_seq_id          NUMBER,
    exist_flag          NUMBER,
    err_text     OUT NOCOPY  VARCHAR2
)
    return INTEGER
IS
    dummy               NUMBER;
    NOT_UNIQUE          EXCEPTION;
    stmt_num            NUMBER := 0;
BEGIN
/*
** First check in prod tables
*/
   stmt_num := 1;
   BEGIN
      SELECT 1
        INTO dummy
        FROM bom_inventory_components
       WHERE component_sequence_id = cmp_seq_id;

      IF (exist_flag = 1) THEN
         RETURN(0);
      ELSE
         RAISE not_unique;
      END IF;
   EXCEPTION
      WHEN no_data_found THEN
         IF (exist_flag = 2) THEN
            null;
         ELSE
            err_text := substrb('Bom_Component_Api(Unique): Component does not
exist '||SQLERRM,1,70);
            RETURN(9999);
         END IF;
      WHEN not_unique THEN
         RAISE not_unique;
   END;

/*
** Check in interface table
*/
   stmt_num := 2;
   SELECT count(*)
     INTO dummy
     FROM bom_inventory_comps_interface
    WHERE component_sequence_id = cmp_seq_id
      AND (UPPER(interface_entity_type) = 'BILL'
	       OR interface_entity_type is null)
      AND process_flag = 4;

   IF (dummy = 0) THEN
      IF (exist_flag = 2) THEN
         RETURN(0);
      ELSE
         RAISE no_data_found;
      END IF;
   END IF;

   IF (dummy > 0) THEN
      IF (exist_flag = 2) THEN
         RAISE not_unique;
      ELSE
         RETURN(0);
      END IF;
   END IF;

EXCEPTION
   WHEN No_Data_Found THEN
      err_text := substrb('Bom_Component_Api(Unique): Component does not exist '||SQLERRM,1,70);
      RETURN(9999);
   WHEN Not_Unique THEN
      err_text := 'Bom_Component_Api(Unique) '||'Duplicate component sequence ids';
      RETURN(9999);
   WHEN others THEN
      err_text := 'Bom_Component_Api(Unique-'||stmt_num||') '||substrb(SQLERRM,1,60);
      RETURN(SQLCODE);
END Verify_unique_component;


/*--------------------- Verify_Duplicate_Component ----------------------*/
/*
NAME
    Verify_duplicate_component - verify if there is another component
    with the same bill, effective date, and operation seq num.
DESCRIPTION
    Verifies in the production and interface tables if component with
    the same bill, effective date, and operation seq num exists.
REQUIRES
    bill_seq_id bill sequence id
    eff_date    effectivity date
    cmp_item_id component item id
    op_seq      operation seq
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    cnt  if component already exists
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Verify_Duplicate_Component(
        bill_seq_id     NUMBER,
        eff_date        VARCHAR2,
        cmp_item_id     NUMBER,
        op_seq          NUMBER,
        act             VARCHAR2,
        comp_seq_id     NUMBER,
        err_text  OUT NOCOPY  VARCHAR2
)
    return INTEGER
IS
    cnt                 NUMBER := 0;
    ALREADY_EXISTS      EXCEPTION;
    stmt_num            NUMBER := 0;
BEGIN
   stmt_num := 1;
   BEGIN
      SELECT component_sequence_id
        INTO cnt
        FROM bom_inventory_components
       WHERE bill_sequence_id = bill_seq_id
         AND effectivity_date = to_date(eff_date,'YYYY/MM/DD HH24:MI:SS')
         AND component_item_id = cmp_item_id
         AND operation_seq_num = op_seq
         AND ((act = G_UPDATE AND component_sequence_id <> comp_seq_id)
              OR
              (act = G_Insert));
      RAISE already_exists;
   EXCEPTION
      WHEN already_exists THEN
         err_text := 'Bom_Component_Api(Duplicate): Component already exists in production';
         RETURN(cnt);
      WHEN no_data_found THEN
         null;
   END;

   stmt_num := 2;
   BEGIN
      SELECT component_sequence_id
        INTO cnt
        FROM bom_inventory_comps_interface
       WHERE bill_sequence_id = bill_seq_id
         AND effectivity_date = to_date(eff_date,'YYYY/MM/DD HH24:MI:SS')
         AND component_item_id = cmp_item_id
         AND operation_seq_num = op_seq
         AND rownum = 1
         AND transaction_type in (G_Insert, G_UPDATE)
         AND (UPPER(interface_entity_type) = 'BILL'
	       OR interface_entity_type is null)
         AND process_flag = 4;

      RAISE already_exists;
   EXCEPTION
      WHEN already_exists THEN
         err_text := 'Bom_Component_Api(Duplicate): Component already exists in interface';
         RETURN(cnt);
      WHEN no_data_found THEN
         null;
   END;
   RETURN(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Component_Api(Duplicate-'||stmt_num||') '||substrb(SQLERRM,1,60);
      RETURN(SQLCODE);
END Verify_Duplicate_Component;


/* ---------------------------- Verify_Overlaps --------------------------- */
/*
NAME
    Verify_Overlaps
DESCRIPTION
    Verify the current component does not have overlapping effectivity
REQUIRES
    bom_id      bill sequence id
    op_num      operation sequence number
    cmp_id      component item id
    eff_date    effectivity date
    dis_date    disable date
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Verify_Overlaps (
    bom_id              NUMBER,
    op_num              NUMBER,
    cmp_id              NUMBER,
    eff_date            VARCHAR2,
    dis_date            VARCHAR2,
    act                 VARCHAR2,
    comp_seq_id         NUMBER,
    err_text    OUT NOCOPY   VARCHAR2
)
    return INTEGER
IS
    dummy               NUMBER;
    OVERLAP             EXCEPTION;
    stmt_num            NUMBER := 0;
BEGIN
   stmt_num := 1;
   SELECT count(*)
     INTO dummy
     FROM bom_inventory_components
    WHERE bill_sequence_id = bom_id
      AND component_item_id = cmp_id
      AND operation_seq_num = op_num
      AND implementation_date is not null
      AND ((act = G_UPDATE AND component_sequence_id <> comp_seq_id)
           OR
           (act = G_Insert))
      AND ((dis_date is null
            AND to_date(eff_date,'YYYY/MM/DD HH24:MI:SS') <
                nvl(disable_date, to_date(eff_date,'YYYY/MM/DD HH24:MI:SS') +1))
           OR
           (dis_date is not null
            AND to_date(dis_date,'YYYY/MM/DD HH24:MI:SS') > effectivity_date
            AND to_date(eff_date,'YYYY/MM/DD HH24:MI:SS') <
                nvl(disable_date,to_date(eff_date,'YYYY/MM/DD HH24:MI:SS')+1)))
     AND not exists                              -- Added for Bug 1929222
           (  SELECT null
              FROM bom_inventory_comps_interface
              WHERE bill_sequence_id = bom_id
                AND process_flag = 4
                    AND component_item_id = cmp_id
                    AND operation_seq_num = op_num
                    AND implementation_date is not null
                AND transaction_type = G_UPDATE
                AND to_date(eff_date,'YYYY/MM/DD HH24:MI:SS') >=
               nvl(disable_date,to_date(eff_date,'YYYY/MM/DD HH24:MI:SS')+1)
           );

   IF (dummy <> 0) THEN
      RAISE OVERLAP;
   END IF;

   stmt_num := 2;
   SELECT count(*)
     INTO dummy
     FROM bom_inventory_comps_interface
    WHERE bill_sequence_id = bom_id
      AND process_flag = 4
      AND transaction_type in (G_Insert, G_UPDATE)
      AND (UPPER(interface_entity_type) = 'BILL'
	       OR interface_entity_type is null)
      AND component_item_id = cmp_id
      AND operation_seq_num = op_num
      AND implementation_date is not null
      AND ((dis_date is null
            AND to_date(eff_date,'YYYY/MM/DD HH24:MI:SS') <
                nvl(disable_date, to_date(eff_date,'YYYY/MM/DD HH24:MI:SS') +1))
           OR
           (dis_date is not null
            AND to_date(dis_date,'YYYY/MM/DD HH24:MI:SS') > effectivity_date
            AND to_date(eff_date,'YYYY/MM/DD HH24:MI:SS') <
               nvl(disable_date,to_date(eff_date,'YYYY/MM/DD HH24:MI:SS') +1)));
   IF (dummy <> 0) THEN
      RAISE overlap;
   END IF;

   RETURN(0);
EXCEPTION
   WHEN Overlap THEN
      err_text := 'Component causes overlapping effectivity';
      RETURN(9999);
   WHEN others THEN
      err_text := 'Bom_Component_Api(Overlap-'||stmt_num||') '||substrb(SQLERRM,1,60);
      RETURN(SQLCODE);
END Verify_Overlaps;


/*------------------------- Verify_Item_Attributes -------------------------*/
/*
NAME
    Verify_Item_Attributes
DESCRIPTION
    Component must be bom enabled
    Component item cannot be same as assembly item
    Mfg bills must have mfg component items

                                     Component Types

Bill            PTO     ATO     PTO   ATO             ATO    PTO   Standard
Types           Model   Model   OC    OC   Planning   Item   Item  Item
-------------  ------------------------------------------------------------
PTO Model       Yes     Yes     Yes   No   No         Yes    Yes   Yes
ATO Model       No      Yes     No    Yes  No         Yes    No    Yes
PTO OC          Yes     Yes     Yes   No   No         Yes    Yes   Yes
ATO OC          No      Yes     No    Yes  No         Yes    No    Yes
Planning        Yes     Yes     Yes   Yes  Yes        Yes    Yes   Yes
ATO Item        No      No      No    No   No         Yes    No    Yes
PTO Item        No      No      No    No   No          No    Yes   Yes
Standard Item   No      No      No    No   No         Yes    No    Yes
Config Item     No      Yes     No    Yes  No         Yes    No    Yes

REQUIRES
    org_id          organization id
    cmp_id          component item id
    assy_id         assembly item id
    eng_bill        engineering bill (1=no, 2=yes)
    err_text    out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Verify_Item_Attributes (
    org_id              NUMBER,
    cmp_id              NUMBER,
    assy_id             NUMBER,
    eng_bill            NUMBER,
    err_text   OUT NOCOPY  VARCHAR2
)
    return INTEGER
IS
    ret_code          		  NUMBER;
    stmt_num            	  NUMBER := 0;
    dummy                         NUMBER;
    l_atp_comps_flag      	  VARCHAR2(1);
    l_atp_flag            	  VARCHAR2(1);
    assy_atp_components_flag      mtl_system_items.atp_components_flag%type;
    assy_wip_supply_type          mtl_system_items.wip_supply_type%type;
    assy_replenish_to_order_flag  mtl_system_items.replenish_to_order_flag%type;
    assy_pick_components_flag     mtl_system_items.pick_components_flag%type;

BEGIN
   stmt_num := 1;
   SELECT 1
     INTO dummy
     FROM mtl_system_items assy, mtl_system_items comp
    WHERE comp.organization_id = org_id
      AND assy.organization_id = org_id
      AND comp.inventory_item_id = cmp_id
      AND assy.inventory_item_id = assy_id
      AND comp.bom_enabled_flag = 'Y'
      AND comp.inventory_item_id <> assy.inventory_item_id
      AND ((eng_bill = 1 and comp.eng_item_flag = 'N')
           OR (eng_bill = 2))
      AND ((assy.bom_item_type = 1 and comp.bom_item_type <> 3)
           OR (assy.bom_item_type = 2 and comp.bom_item_type <> 3)
           OR (assy.bom_item_type = 3)
           OR (assy.bom_item_type = 4
               AND (comp.bom_item_type = 4
                    OR (comp.bom_item_type in (2,1)
                         AND comp.replenish_to_order_flag = 'Y'
                        AND assy.base_item_id is not null
                        AND assy.replenish_to_order_flag = 'Y'))))
      AND (assy.bom_item_type = 3
           OR assy.pick_components_flag = 'Y'
           OR comp.pick_components_flag = 'N')
      AND (assy.bom_item_type = 3
           OR comp.bom_item_type <> 2
           OR (comp.bom_item_type = 2
               AND ((assy.pick_components_flag = 'Y'
                     AND comp.pick_components_flag = 'Y')
                    OR (assy.replenish_to_order_flag = 'Y'
                        AND comp.replenish_to_order_flag = 'Y'))))
      AND not(assy.bom_item_type = 4
              AND assy.pick_components_flag = 'Y'
              AND comp.bom_item_type = 4
              AND comp.replenish_to_order_flag = 'Y');

RETURN(0);
     -- Starting with R11, the ATP_Flag can have additional values R and C
     -- apart from Y and N
     -- Starting with 11i, even ATP Components flag has additional values
     --which are similar to ATP flag. To incorporate these values for
     -- multi-level ATP we also release the update allowed constraint
     -- on Check_ATP


        -- ATP Components flag for an item indicates whether an item's child components should be
        -- ATP checked. A component c1 (ATP Check = Material) can be on a subassembly that does not
        -- need to do atp check for components and hence has ATP Components of subassy is set to No. In
        -- current validation c1 cannot be added onto the subassy because we restrict that.

        -- We will now release the restriction on the ATP Check and ATP Components flag. This will allow the
        -- users to control what can and cannot be structured on a bill. If the item level attribute for a
        -- component is ATP Check = Yes, BOM will allow the user to turn it off at the component level.
        -- The default value will be copied from the item.

   /*
   BEGIN

     SELECT atp_components_flag,
            wip_supply_type,
            replenish_to_order_flag,
            pick_components_flag
     INTO  assy_atp_components_flag,
           assy_wip_supply_type,
           assy_replenish_to_order_flag,
           assy_pick_components_flag
     FROM   mtl_system_items
     WHERE inventory_item_id = assy_id
           AND organization_id = org_id;

     SELECT atp_components_flag,
            atp_flag
     INTO l_atp_comps_flag,
          l_atp_flag
     FROM mtl_system_items msi
     WHERE inventory_item_id = cmp_id
        AND organization_id = org_id;

    IF((assy_atp_components_flag = 'N' AND
        ( nvl(assy_wip_supply_type,1) = 6 OR
          assy_replenish_to_order_flag = 'Y' OR
          assy_pick_components_flag = 'Y'
        )
       ) AND
       ( l_atp_comps_flag IN ('Y','C', 'R', 'N') OR
         l_atp_flag IN ('Y', 'R','C','N' )
       )
      ) OR
      assy_atp_components_flag IN ('Y','R','C')
    THEN
           -- Do nothing since this is permitted
          -- If the Assembly item is Phantom or an ATO or PTO and has ATP
          -- Components as 'N'
          -- Even then we will allow ATP components
      RETURN(0);
    ELSIF (assy_atp_components_flag = 'N' AND
             (l_atp_comps_flag = 'N' AND l_atp_flag IN ('N','Y'))
          )
      THEN
           -- Even in this case do nothing since both the flags are N and
           -- hence is a valid combination
      RETURN(0);
    END IF;
      err_text := 'Component ATP flag item attributes invalid';
      RETURN(9999);

   */

/*
      SELECT 1
        INTO dummy
        FROM mtl_system_items assy, mtl_system_items comp
       WHERE comp.organization_id = org_id
         AND assy.organization_id = org_id
         AND comp.inventory_item_id = cmp_id
         AND assy.inventory_item_id = assy_id
         AND (comp.atp_components_flag = 'Y' OR
              comp.atp_flag = 'Y')
         AND assy.atp_components_flag = 'N'
         AND (nvl(assy.wip_supply_type,1) = 6
              OR assy.replenish_to_order_flag = 'Y'
              OR assy.pick_components_flag = 'Y');
      err_text := 'Component ATP flag item attributes invalid';
      RETURN(9999);
*/
   -- END;

EXCEPTION
   WHEN No_Data_Found THEN
      err_text := 'Component and assembly item attributes invalid';
      return(9999);
   WHEN others THEN
      err_text := 'Bom_Component_Api(Attributes-'||stmt_num||') '||substrb(SQLERRM,1,60);
      return(SQLCODE);
END Verify_Item_Attributes;


/* ----------------------------- Valid_Op_Seqs ----------------------------- */
/*
NAME
    Valid_op_seqs - validate the operation seq nums
DESCRIPTION
    verify if op seq is valid.  For alternate bills, op seq can be of same
    alternate or primary if alternate does not exist
REQUIRES
    err_text    out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Valid_Op_Seqs (
    org_id              NUMBER,
    assy_id             NUMBER,
    alt_desg            VARCHAR2,
    op_seq              NUMBER,
    err_text     OUT NOCOPY  VARCHAR2
)
    return INTEGER
IS
    ret_code            NUMBER;
    stmt_num            NUMBER := 0;
    dummy               NUMBER;

BEGIN
   stmt_num := 1;
   SELECT bom_item_type
     INTO dummy
     FROM mtl_system_items
    WHERE organization_id = org_id
      AND inventory_item_id = assy_id;

   IF (dummy = 3 and op_seq <> 1) THEN
      err_text := 'Planning bom cannot have routing';
      RETURN (9999);
   END IF;

/*
Bug 1322959 :
  commented the effectivity Date < sysdate as This was causing the error
  invalid operation sequence. When the Operation sequence is defined
  as effective in a future date form BOMFDBOM was allowing to assign this
  operating sequence number for any components where as the Interface
  was giving error. Made the following fix to ensure the similar
  behaviour in both form and Interface.
  The fix allows picking the operation Sequences which are effective
  in future also.
*/

   stmt_num := 2;
   IF (op_seq <> 1) THEN
      SELECT distinct operation_seq_num
        INTO dummy
        FROM bom_operation_sequences a, bom_operational_routings b
       WHERE b.organization_id = org_id
         AND b.assembly_item_id = assy_id
         AND operation_seq_num = op_seq
--         AND a.effectivity_date < sysdate
         AND NVL(a.disable_date,sysdate+1)    > sysdate
         AND b.common_routing_sequence_id = a.routing_sequence_id
         AND ((alt_desg is null and b.alternate_routing_designator is null)
                OR
                (alt_desg is not null
                 AND
                  ((b.alternate_routing_designator = alt_desg)
                   or
                   (b.alternate_routing_designator is null
                    AND not exists
                        (SELECT 'No alt routing'
                           FROM bom_operational_routings c
                          WHERE c.organization_id = org_id
                            AND c.assembly_item_id = assy_id
                            AND c.alternate_routing_designator = alt_desg)))));
   END IF;
   RETURN(0);

EXCEPTION
   WHEN No_Data_Found THEN
      err_text := 'Invalid operation seq num';
      RETURN (9999);
   WHEN others THEN
      err_text := 'Bom_Component_Api(OpSeq-'||stmt_num||') '||substrb(SQLERRM,1,60);
      RETURN(SQLCODE);
END Valid_Op_Seqs;


/* -------------------------- Validate_Component ------------------------- */
/*
NAME
    Validate_Component
DESCRIPTION

REQUIRES
    err_text    out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Validate_Component (
    org_id              NUMBER,
    all_org             NUMBER := 2,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY VARCHAR2
)
    return INTEGER
IS
    ret_code                    NUMBER;
    ret_code_error              EXCEPTION; -- ret_code <> 0
    stmt_num                    NUMBER := 0;
    commit_cnt                  NUMBER;
    dummy                       VARCHAR2(50);
    eng_bill                    NUMBER;
    oe_install                  VARCHAR2(1);
    inv_asst                    VARCHAR2(1);
    r_subinv                    NUMBER;
    r_loc                       NUMBER;
    loc_ctl                     NUMBER;
    org_loc                     NUMBER;
    sub_loc_code                NUMBER;
    X_expense_to_asset_transfer NUMBER;
    ref_qty                     NUMBER := 0;
    int_ref_qty                 NUMBER := 0;
    go_on                       BOOLEAN;
    continue_loop               EXCEPTION;
    continue_loop2              EXCEPTION;
    write_loc_error             EXCEPTION;
    write_subinv_error          EXCEPTION;
    update_comp                 EXCEPTION;
    X_creation_date             DATE;
    X_created_by                NUMBER;
    X_operation_seq_num         NUMBER;
    X_item_num                  NUMBER;
    X_component_quantity        NUMBER;
    X_component_yield_factor    NUMBER;
    X_component_remarks         VARCHAR2(240);
    X_effectivity_date          DATE;
    X_change_notice             VARCHAR2(10);
    X_implementation_date       DATE;
    X_disable_date              DATE;
    X_attribute_category        VARCHAR2(30);
    X_attribute1                VARCHAR2(150);
    X_attribute2                VARCHAR2(150);
    X_attribute3                VARCHAR2(150);
    X_attribute4                VARCHAR2(150);
    X_attribute5                VARCHAR2(150);
    X_attribute6                VARCHAR2(150);
    X_attribute7                VARCHAR2(150);
    X_attribute8                VARCHAR2(150);
    X_attribute9                VARCHAR2(150);
    X_attribute10               VARCHAR2(150);
    X_attribute11               VARCHAR2(150);
    X_attribute12               VARCHAR2(150);
    X_attribute13               VARCHAR2(150);
    X_attribute14               VARCHAR2(150);
    X_attribute15               VARCHAR2(150);
    X_request_id                NUMBER;
    X_program_application_id    NUMBER;
    X_program_id                NUMBER;
    X_program_update_date       DATE;
    X_planning_factor           NUMBER;
    X_quantity_related          NUMBER;
    X_so_basis                  NUMBER;
    X_optional                  NUMBER;
    X_mutually_exclusive_options NUMBER;
    X_include_in_cost_rollup    NUMBER;
    X_check_atp                 NUMBER;
    X_shipping_allowed          NUMBER;
    X_required_to_ship          NUMBER;
    X_required_for_revenue      NUMBER;
    X_include_on_ship_docs      NUMBER;
    X_include_on_bill_docs      NUMBER;
    X_low_quantity              NUMBER;
    X_high_quantity             NUMBER;
    X_acd_type                  NUMBER;
    X_old_component_sequence_id NUMBER;
    X_wip_supply_type           NUMBER;
    X_pick_components           NUMBER;
    X_supply_subinventory       VARCHAR2(10);
    X_supply_locator_id         NUMBER;
    X_operation_lead_time_percent NUMBER;
    X_cost_factor               NUMBER;
    X_bom_item_type             NUMBER;
    X_revised_item_sequence_id  NUMBER;
    X_component_item_id         NUMBER;
    X_bill_sequence_id          NUMBER;
    x_bill_type			NUMBER;  -- BOM Item type of the bill
    x_assembly_item_id		NUMBER;
    x_valid_comp		NUMBER;
    l_pud                       DATE;    -- Program Update Date
/*
** Select all INSERTS
*/
    CURSOR c1 IS
       SELECT component_sequence_id CSI, bill_sequence_id BSI,
                transaction_id TI, transaction_type A,
                to_char(effectivity_date,'YYYY/MM/DD HH24:MI:SS') ED,
                effectivity_date EDD,
                to_char(disable_date,'YYYY/MM/DD HH24:MI:SS') DD,
                to_char(implementation_date,'YYYY/MM/DD HH24:MI:SS') ID,
                operation_seq_num OSN, supply_locator_id SLI,
                supply_subinventory SS,
                msic.organization_id OI, component_item_id CII,
                assembly_item_id AII, alternate_bom_designator ABD,
                planning_factor PF, optional O, check_atp CATP,
                msic.atp_flag AF, so_basis SB, required_for_revenue RFR,
                required_to_ship RTS, mutually_exclusive_options MEO,
                low_quantity LQ, high_quantity HQ,change_notice CN,
                quantity_related QR, include_in_cost_rollup ICR,
                shipping_allowed SA, include_on_ship_docs ISD,
                component_yield_factor CYF, ici.wip_supply_type WST,
                component_quantity CQ, msic.bom_item_type BITC,
                msic.pick_components_flag PCF, msia.bom_item_type BITA,
                msia.pick_components_flag PCFA,
                msia.replenish_to_order_flag RTOF,
                msic.replenish_to_order_flag RTOFC,
                msia.atp_components_flag ACF,
                msic.ato_forecast_control AFC
        FROM    mtl_system_items msic,
                mtl_system_items msia,
                bom_inventory_comps_interface ici
        WHERE process_flag = 2
          AND transaction_type = G_Insert
          AND (UPPER(ici.interface_entity_type) = 'BILL'
	       OR ici.interface_entity_type is null)
          AND msic.organization_id = ici.organization_id
          AND msia.organization_id = ici.organization_id
          AND msic.inventory_item_id = ici.component_item_id
          AND msia.inventory_item_id = ici.assembly_item_id;
/*
** Select all UPDATES and DELETES
*/
    CURSOR c2 IS
       SELECT ici.component_sequence_id CSI, ici.bill_sequence_id BSI,
                ici.transaction_id TI, ici.acd_type ACD,
                ici.transaction_type A,
                to_char(ici.effectivity_date,'YYYY/MM/DD HH24:MI:SS') ED,
                ici.effectivity_date EDD, ici.item_num INUM,
                to_char(ici.disable_date,'YYYY/MM/DD HH24:MI:SS') DD,
                ici.disable_date DDD,
                ici.implementation_date ID,
                ici.operation_seq_num OSN, ici.supply_locator_id SLI,
                ici.supply_subinventory SS, ici.creation_date CD,
                ici.created_by CB, ici.change_notice CN,
                ici.old_component_sequence_id OCSI,
                ici.new_effectivity_date NED,
                ici.include_in_cost_rollup IICR, ici.check_atp CA,
                ici.pick_components PC, ici.operation_lead_time_percent OLTP,
                ici.revised_item_sequence_id RISI, ici.bom_item_type BIT,
                ici.new_operation_seq_num NOSN, ici.component_remarks CR,
                msic.organization_id OI, ici.component_item_id CII,
                ici.assembly_item_id AII, ici.alternate_bom_designator ABD,
                ici.planning_factor PF, ici.optional O, ici.check_atp CATP,
                msic.atp_flag AF, ici.so_basis SB,
                ici.required_for_revenue RFR, ici.include_on_ship_docs IOSD,
                ici.required_to_ship RTS, ici.mutually_exclusive_options MEO,
                ici.low_quantity LQ, ici.high_quantity HQ,
                ici.quantity_related QR, ici.include_in_cost_rollup ICR,
                ici.shipping_allowed SA, ici.include_on_ship_docs ISD,
                ici.component_yield_factor CYF, ici.wip_supply_type WST,
                ici.component_quantity CQ, ici.attribute_category AC,
                ici.attribute1 A1, ici.attribute2 A2, ici.attribute3 A3,
                ici.attribute4 A4, ici.attribute5 A5, ici.attribute6 A6,
                ici.attribute7 A7, ici.attribute8 A8, ici.attribute9 A9,
                ici.attribute10 A10, ici.attribute11 A11, ici.attribute12 A12,
                ici.attribute13 A13, ici.attribute14 A14, ici.attribute15 A15,
                ici.request_id RI, ici.program_application_id PAI,
                ici.program_update_date PUD, ici.program_id PI,
                msic.bom_item_type BITC,
                msic.pick_components_flag PCF, msia.bom_item_type BITA,
                msia.pick_components_flag PCFA,
                msia.replenish_to_order_flag RTOF,
                msic.replenish_to_order_flag RTOFC,
                msia.atp_components_flag ACF,
                msic.ato_forecast_control AFC
        FROM    mtl_system_items msic,
                mtl_system_items msia,
                bom_inventory_comps_interface ici
        WHERE process_flag = 2
          AND transaction_type in (G_UPDATE, G_DELETE)
          AND (UPPER(ici.interface_entity_type) = 'BILL'
	       OR ici.interface_entity_type is null)
          AND msic.organization_id = ici.organization_id
          AND msia.organization_id = ici.organization_id
          AND msic.inventory_item_id = ici.component_item_id
          AND msia.inventory_item_id = ici.assembly_item_id;
/*
** Select all UPDATES with process_flag = 99
*/
    CURSOR c3 IS
       SELECT ici.component_sequence_id CSI, ici.bill_sequence_id BSI,
                ici.transaction_id TI, ici.transaction_type A,
                ici.implementation_date ID,
                to_char(ici.effectivity_date,'YYYY/MM/DD HH24:MI:SS') ED,
                ici.effectivity_date EDD, ici.item_num INUM,
                to_char(ici.disable_date,'YYYY/MM/DD HH24:MI:SS') DD,
                ici.operation_seq_num OSN, ici.supply_locator_id SLI,
                ici.supply_subinventory SS,
                msic.organization_id OI, ici.component_item_id CII,
                ici.assembly_item_id AII, ici.alternate_bom_designator ABD,
                ici.planning_factor PF, ici.optional O, ici.check_atp CATP,
                msic.atp_flag AF, ici.so_basis SB,
                ici.required_for_revenue RFR,
                ici.required_to_ship RTS, ici.mutually_exclusive_options MEO,
                ici.low_quantity LQ, ici.high_quantity HQ,
                ici.quantity_related QR, ici.include_in_cost_rollup ICR,
                ici.shipping_allowed SA, ici.include_on_ship_docs ISD,
                ici.component_yield_factor CYF, ici.wip_supply_type WST,
                ici.component_quantity CQ, msic.bom_item_type BITC,
                msic.pick_components_flag PCF, msia.bom_item_type BITA,
                msia.pick_components_flag PCFA,
                msia.replenish_to_order_flag RTOF,
                msic.replenish_to_order_flag RTOFC,
                msia.atp_components_flag ACF,
                msic.ato_forecast_control AFC
        FROM    mtl_system_items msic,
                mtl_system_items msia,
                bom_inventory_comps_interface ici
        WHERE ici.process_flag = 99
          AND ici.transaction_type = G_Update
          AND (UPPER(ici.interface_entity_type) = 'BILL'
	       OR ici.interface_entity_type is null)
          AND msic.organization_id = ici.organization_id
          AND msia.organization_id = ici.organization_id
          AND msic.inventory_item_id = ici.component_item_id
          AND msia.inventory_item_id = ici.assembly_item_id;

BEGIN

/*
** FOR UPDATES and DELETES
*/
   go_on := TRUE;
   WHILE go_on LOOP
      commit_cnt := 0;
      FOR c2rec IN c2 LOOP
         commit_cnt := commit_cnt + 1;
         stmt_num := 1;
/*
** Check if implemented record exists in Production
*/
         stmt_num := 2;
         BEGIN
            SELECT creation_date, created_by, operation_seq_num,item_num,
                   component_quantity, component_yield_factor,
                   component_remarks, effectivity_date, change_notice,
                   implementation_date, disable_date, component_item_id,
                   attribute_category, attribute1,
                   attribute2, attribute3, attribute4, attribute5,
                   attribute6, attribute7, attribute8, attribute9,
                   attribute10, attribute11, attribute12, attribute13,
                   attribute14, attribute15, request_id,
                   program_application_id, program_id, program_update_date,
                   planning_factor, quantity_related, so_basis, optional,
                   mutually_exclusive_options, include_in_cost_rollup,
                   check_atp, shipping_allowed, required_to_ship,
                   required_for_revenue, include_on_ship_docs,
                   include_on_bill_docs, low_quantity, high_quantity,
                   acd_type, old_component_sequence_id, wip_supply_type,
                   pick_components, supply_subinventory, supply_locator_id,
                   operation_lead_time_percent, cost_factor, bom_item_type,
                   revised_item_sequence_id, bill_sequence_id
              INTO X_creation_date, X_created_by, X_operation_seq_num,
                   X_item_num, X_component_quantity, X_component_yield_factor,
                   X_component_remarks, X_effectivity_date, X_change_notice,
                   X_implementation_date, X_disable_date, X_component_item_id,
                   X_attribute_category, X_attribute1,
                   X_attribute2, X_attribute3, X_attribute4, X_attribute5,
                   X_attribute6, X_attribute7, X_attribute8, X_attribute9,
                   X_attribute10, X_attribute11, X_attribute12, X_attribute13,
                   X_attribute14, X_attribute15, X_request_id,
                   X_program_application_id, X_program_id,
                   X_program_update_date,
                   X_planning_factor, X_quantity_related, X_so_basis,
                   X_optional, X_mutually_exclusive_options,
                   X_include_in_cost_rollup, X_check_atp, X_shipping_allowed,
                   X_required_to_ship, X_required_for_revenue,
                   X_include_on_ship_docs, X_include_on_bill_docs,
                   X_low_quantity, X_high_quantity, X_acd_type,
                   X_old_component_sequence_id, X_wip_supply_type,
                   X_pick_components, X_supply_subinventory,
                   X_supply_locator_id, X_operation_lead_time_percent,
                   X_cost_factor, X_bom_item_type,
                   X_revised_item_sequence_id, X_bill_sequence_id
              FROM bom_inventory_components
             WHERE component_sequence_id = c2rec.CSI
               AND implementation_date is NOT NULL;
         EXCEPTION
            WHEN No_Data_Found THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c2rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMP_RECORD_MISSING',
                        err_text => err_text);

               UPDATE bom_inventory_comps_interface
                  SET process_flag = 3
                WHERE transaction_id = c2rec.TI;

               IF (ret_code <> 0) THEN
                   return(ret_code);
               END IF;
               GOTO skip_loop;
         END;
/*
  Added to Fix the Bug : 11277093
   The Decode statement in UPDATE is making the time part of the
Program Update to 12 Mid Night. To correct this the decode has been
exploded into If then Else here
*/
--  decode(c2rec.PUD, G_NullDate, '',NULL,X_program_update_date,c2rec.PUD),
--
    IF (c2rec.PUD = G_NullDate) THEN
        l_pud := '';
    ELSIF (c2rec.PUD is NULL) THEN
        l_pud := X_program_update_date;
    ELSE
        l_pud := c2rec.PUD;
    END IF;
/*
  Bug No : 1279729
Added validation check for Item Number
Maximum allowed is 9999
*/
   IF (c2rec.INUM > 9999) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_ITEM_NUM_INVALID',
                        err_text => err_text);

               UPDATE bom_inventory_comps_interface
                  SET process_flag = 3
                WHERE transaction_id = c2rec.TI;

               IF (ret_code <> 0) THEN
                   return(ret_code);
               END IF;
               GOTO skip_loop;
   END IF;

/*
** ONLY for "Updates"
*/
         IF (c2rec.A = G_UPDATE) THEN
/*
** For Product Family Members
*/
            IF (c2rec.BITA = G_ProductFamily) THEN
/*
** Check if column is non-updatable and give error if user filled it in
*/
               IF (c2rec.CD is not null           -- creation date
                  OR c2rec.CB is not null         -- created by
                  OR c2rec.CN is not null         -- change notice
                  OR c2rec.SA is not null         -- shipping allowed
                  OR c2rec.OCSI is not null       -- old comp seq id
                  OR c2rec.PC is not null         -- pick components
                  OR c2rec.OLTP is not null       -- op lead time percent
                  OR c2rec.RISI is not null       -- rev item seq id
                  OR c2rec.BIT is not null        -- bom item type
                  OR c2rec.ACD is not null        -- acd type
                  OR (c2rec.OSN <> 1 AND
		      c2rec.OSN is NOT NULL)      -- operation_seq_num
                  OR c2rec.INUM is not null       --  item_num
                  OR c2rec.CQ is not null         -- component quantity
                  OR c2rec.CYF is not null        -- component yield factor
                  OR c2rec.ID is not null         -- implementation date
                  OR c2rec.QR is not null         -- quantity related
                  OR c2rec.SB is not null         -- so basis
                  OR c2rec.O is not null          -- optional
                  OR c2rec.MEO is not null        -- mutually exclusive options
                  OR c2rec.ICR is not null        -- include in cost rollup
                  OR c2rec.CA is not null         -- check atp
                  OR c2rec.RTS is not null        -- required to ship
                  OR c2rec.RFR is not null        -- required for revenue
                  OR c2rec.ISD is not null        -- include on ship docs
                  OR c2rec.LQ is not null         -- low quantity
                  OR c2rec.HQ is not null         -- high quantity
                  OR c2rec.WST is not null        -- wip supply type
                  OR c2rec.SS is not null         -- supply subinventory
                  OR c2rec.SLI is not null        -- supply locator id
					  ) THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c2rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COLUMN_NOT_UPDATABLE',
                        err_text => err_text);

                  UPDATE bom_inventory_comps_interface
                     SET process_flag = 3
                   WHERE transaction_id = c2rec.TI;

                  IF (ret_code <> 0) THEN
                      return(ret_code);
                  END IF;

	 	  GOTO skip_loop;

               END IF;
/*
** Update interface record with production record's values
*/
               stmt_num := 6;
               UPDATE bom_inventory_comps_interface
                  SET operation_seq_num = X_operation_seq_num,
                      component_item_id = X_component_item_id,
                      creation_date = X_creation_date,
                      created_by = X_created_by,
                      item_num = X_item_num,
                      component_quantity = X_component_quantity,
                      component_yield_factor = X_component_yield_factor,
                      component_remarks = decode(c2rec.CR, null,
                        X_component_remarks, G_NullChar, '', c2rec.CR),
                      effectivity_date = nvl(trunc(c2rec.NED),
				             X_effectivity_date),
                      change_notice = X_change_notice,
                      implementation_date = nvl(trunc(c2rec.NED),
				             X_effectivity_date),
                      disable_date = decode(c2rec.DDD, null,
                           X_disable_date, G_NullDate, '', c2rec.DDD),
                      planning_factor = nvl(c2rec.PF, X_planning_factor),
                      quantity_related = X_quantity_related,
                      so_basis = X_so_basis,
                      optional = X_optional,
                      mutually_exclusive_options = X_mutually_exclusive_options,
                      include_in_cost_rollup = X_include_in_cost_rollup,
                      check_atp = X_check_atp,
                      shipping_allowed = X_shipping_allowed,
                      required_to_ship = X_required_to_ship,
                      required_for_revenue = X_required_for_revenue,
                      include_on_ship_docs = X_include_on_ship_docs,
                      include_on_bill_docs = X_include_on_bill_docs,
                      low_quantity = X_low_quantity,
                      high_quantity = X_high_quantity,
                      acd_type = X_acd_type,
                      old_component_sequence_id = X_old_component_sequence_id,
                      bill_sequence_id = X_bill_sequence_id,
                      wip_supply_type = X_wip_supply_type,
                      pick_components = X_pick_components,
                      supply_subinventory = X_supply_subinventory,
                      supply_locator_id = X_supply_locator_id,
                      operation_lead_time_percent = X_operation_lead_time_percent,
                      revised_item_sequence_id = X_revised_item_sequence_id,
                      cost_factor = X_cost_factor,
                      bom_item_type = X_bom_item_type,
                      attribute_category = decode(c2rec.AC, G_NullChar, '', NULL,
                                        X_attribute_category, c2rec.AC),
                      attribute1 = decode(c2rec.A1, G_NullChar, '', NULL,
                                           X_attribute1, c2rec.A1),
                      attribute2 = decode(c2rec.A2, G_NullChar, '', NULL,
                                           X_attribute2, c2rec.A2),
                      attribute3 = decode(c2rec.A3, G_NullChar, '', NULL,
                                           X_attribute3, c2rec.A3),
                      attribute4 = decode(c2rec.A4, G_NullChar, '', NULL,
                                           X_attribute4, c2rec.A4),
                      attribute5 = decode(c2rec.A5, G_NullChar, '', NULL,
                                           X_attribute5, c2rec.A5),
                      attribute6 = decode(c2rec.A6, G_NullChar, '', NULL,
                                           X_attribute6, c2rec.A6),
                      attribute7 = decode(c2rec.A7, G_NullChar, '', NULL,
                                            X_attribute7, c2rec.A7),
                      attribute8 = decode(c2rec.A8, G_NullChar, '', NULL,
                                           X_attribute8, c2rec.A8),
                      attribute9 = decode(c2rec.A9, G_NullChar, '', NULL,
                                           X_attribute9, c2rec.A9),
                      attribute10 = decode(c2rec.A10, G_NullChar, '', NULL,
                                           X_attribute10, c2rec.A10),
                      attribute11 = decode(c2rec.A11, G_NullChar, '', NULL,
                                           X_attribute11, c2rec.A11),
                      attribute12 = decode(c2rec.A12, G_NullChar, '', NULL,
                                           X_attribute12, c2rec.A12),
                      attribute13 = decode(c2rec.A13, G_NullChar, '', NULL,
                                           X_attribute13, c2rec.A13),
                      attribute14 = decode(c2rec.A14, G_NullChar, '', NULL,
                                           X_attribute14, c2rec.A14),
                      attribute15 = decode(c2rec.A15, G_NullChar, '', NULL,
                                           X_attribute15, c2rec.A15),
                      request_id = decode(c2rec.RI, G_NullChar, '', NULL,
                                           X_request_id, c2rec.RI),
                      program_application_id = decode(c2rec.PAI, G_NullNum,
                           '', NULL, X_program_application_id, c2rec.PAI),
                      program_id = decode(c2rec.PI, G_NullNum, '', NULL,
                                           X_program_id, c2rec.PI),
                      program_update_date = l_pud,
                      process_flag = 99
                WHERE transaction_id = c2rec.TI;
            ELSE
/*
** For components
*/

/*
** Check if column is non-updatable and give error if user filled it in
*/
               IF (c2rec.CD is not null            -- creation date
                   OR c2rec.CB is not null         -- created by
                   OR c2rec.CN is not null         -- change notice
                   OR c2rec.SA is not null         -- shipping allowed
                   OR c2rec.OCSI is not null       -- old comp seq id
                   OR c2rec.PC is not null         -- pick components
                   OR c2rec.OLTP is not null       -- op lead time percent
                   OR c2rec.RISI is not null       -- rev item seq id
                   OR c2rec.BIT is not null        -- bom item type
                   OR c2rec.ACD is not null) THEN  -- acd type
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c2rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COLUMN_NOT_UPDATABLE',
                        err_text => err_text);

                  UPDATE bom_inventory_comps_interface
                     SET process_flag = 3
                   WHERE transaction_id = c2rec.TI;

                  IF (ret_code <> 0) THEN
                      return(ret_code);
                  END IF;

		  GOTO skip_loop;
               END IF;
/*
** Update interface record with production record's values
*/
               stmt_num := 6;
               UPDATE bom_inventory_comps_interface
                  SET operation_seq_num = nvl(c2rec.NOSN, X_operation_seq_num),
                      component_item_id = X_component_item_id,
                      creation_date = X_creation_date,
                      created_by = X_created_by,
                      item_num = nvl(c2rec.INUM, X_item_num),
                      component_quantity = nvl(c2rec.CQ, X_component_quantity),
                      component_yield_factor = nvl(c2rec.CYF,
                           X_component_yield_factor),
                      component_remarks = decode(c2rec.CR, null,
                        X_component_remarks, G_NullChar, '', c2rec.CR),
                      effectivity_date = nvl(c2rec.NED, X_effectivity_date),
                      change_notice = X_change_notice,
                      implementation_date = nvl(c2rec.ID, X_implementation_date),
                      disable_date = decode(c2rec.DDD, null,
                        X_disable_date, G_NullDate, '', c2rec.DDD),
                      planning_factor = nvl(c2rec.PF, X_planning_factor),
                      quantity_related = nvl(c2rec.QR, X_quantity_related),
                      so_basis = nvl(c2rec.SB, X_so_basis),
                      optional = nvl(c2rec.O, X_optional),
                      mutually_exclusive_options = nvl(c2rec.MEO,
                        X_mutually_exclusive_options),
                      include_in_cost_rollup = nvl(c2rec.IICR,
                        X_include_in_cost_rollup),
                      check_atp = nvl(c2rec.CA, X_check_atp),
                      shipping_allowed = X_shipping_allowed,
                      required_to_ship = nvl(c2rec.RTS, X_required_to_ship),
                      required_for_revenue = nvl(c2rec.RFR,
				X_required_for_revenue),
                      include_on_ship_docs = nvl(c2rec.IOSD,
	 			X_include_on_ship_docs),
                      include_on_bill_docs = X_include_on_bill_docs,
                      low_quantity = decode(c2rec.LQ, G_NullNum, '', null,
                        X_low_quantity, c2rec.LQ),
                      high_quantity = decode(c2rec.HQ, G_NullNum, '', null,
                         X_high_quantity, c2rec.HQ),
                      acd_type = X_acd_type,
                      old_component_sequence_id = X_old_component_sequence_id,
                      bill_sequence_id = X_bill_sequence_id,
                      wip_supply_type = decode(c2rec.WST, null,
                        X_wip_supply_type, G_NullNum, '', c2rec.WST),
                      pick_components = X_pick_components,
                      supply_subinventory = decode(c2rec.SS, null,
                        X_supply_subinventory, G_NullChar, '', c2rec.SS),
                      supply_locator_id = decode(c2rec.SLI, null,
                        X_supply_locator_id, G_NullNum, '', c2rec.SLI),
      --              operation_lead_time_percent = X_operation_lead_time_percent,
                      operation_lead_time_percent = NULL,   -- for bug 1804509
                      revised_item_sequence_id = X_revised_item_sequence_id,
                      cost_factor = X_cost_factor,
                      bom_item_type = X_bom_item_type,
                      attribute_category = decode(c2rec.AC, G_NullChar, '', NULL,
                                        X_attribute_category, c2rec.AC),
                      attribute1 = decode(c2rec.A1, G_NullChar, '', NULL,
                                         X_attribute1, c2rec.A1),
                      attribute2 = decode(c2rec.A2, G_NullChar, '', NULL,
                                        X_attribute2, c2rec.A2),
                      attribute3 = decode(c2rec.A3, G_NullChar, '', NULL,
                                         X_attribute3, c2rec.A3),
                      attribute4 = decode(c2rec.A4, G_NullChar, '', NULL,
                                        X_attribute4, c2rec.A4),
                      attribute5 = decode(c2rec.A5, G_NullChar, '', NULL,
                                          X_attribute5, c2rec.A5),
                      attribute6 = decode(c2rec.A6, G_NullChar, '', NULL,
                                        X_attribute6, c2rec.A6),
                      attribute7 = decode(c2rec.A7, G_NullChar, '', NULL,
                                        X_attribute7, c2rec.A7),
                      attribute8 = decode(c2rec.A8, G_NullChar, '', NULL,
                                        X_attribute8, c2rec.A8),
                      attribute9 = decode(c2rec.A9, G_NullChar, '', NULL,
                                        X_attribute9, c2rec.A9),
                      attribute10 = decode(c2rec.A10, G_NullChar, '', NULL,
                                        X_attribute10, c2rec.A10),
                      attribute11 = decode(c2rec.A11, G_NullChar, '', NULL,
                                        X_attribute11, c2rec.A11),
                      attribute12 = decode(c2rec.A12, G_NullChar, '', NULL,
                                          X_attribute12, c2rec.A12),
                      attribute13 = decode(c2rec.A13, G_NullChar, '', NULL,
                                        X_attribute13, c2rec.A13),
                      attribute14 = decode(c2rec.A14, G_NullChar, '', NULL,
                                        X_attribute14, c2rec.A14),
                      attribute15 = decode(c2rec.A15, G_NullChar, '', NULL,
                                        X_attribute15, c2rec.A15),
                      request_id = decode(c2rec.RI, G_NullChar, '', NULL,
                                        X_request_id, c2rec.RI),
                      program_application_id = decode(c2rec.PAI, G_NullNum,
                        '', NULL, X_program_application_id, c2rec.PAI),
                      program_id = decode(c2rec.PI, G_NullNum, '', NULL,
                                        X_program_id, c2rec.PI),
                      program_update_date =l_pud,
                      process_flag = 99
                WHERE transaction_id = c2rec.TI;
            END IF;  -- End checking if Member or Component
         ELSIF (c2rec.A = G_DELETE) THEN
/*
** Set Process Flag to 4 for "Deletes"
*/
            stmt_num := 10;
            UPDATE bom_inventory_comps_interface
               SET process_flag = 4
             WHERE transaction_id = c2rec.TI;
         END IF;
<<skip_loop>>
         NULL;
      END LOOP;
      stmt_num := 7;
      COMMIT;
      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         go_on := FALSE;
      END IF;

   END LOOP;

/*
** FOR UPDATES - Validate
*/
   FOR c3rec IN c3 LOOP
      BEGIN
         stmt_num := 1;
/*
** Verify uniqueness of bill seq id,effective date,op seq, and component item
*/
         ret_code := Verify_Duplicate_Component (
                bill_seq_id => c3rec.BSI,
                eff_date => c3rec.ED,
                cmp_item_id => c3rec.CII,
                op_seq => c3rec.OSN,
                act => c3rec.A,
                comp_seq_id => c3rec.CSI,
                err_text => err_text);
         IF (ret_code <> 0) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c3rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMPONENT_DUPLICATE',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c3rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop2;
         END IF;
/*
  Bug No : 1279729
Added validation check for Item Number
Maximum allowed is 9999
*/
   IF (c3rec.INUM > 9999) then
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_ITEM_NUM_INVALID',
                        err_text => err_text);

               UPDATE bom_inventory_comps_interface
                  SET process_flag = 3
                WHERE transaction_id = c3rec.TI;

               IF (ret_code <> 0) THEN
                  RAISE ret_code_error;
               END IF;
               RAISE continue_loop2;
   END IF;

/*
** Make sure there is no overlapping components
*/
         stmt_num := 4;
         IF (c3rec.ID is not null) THEN
            ret_code :=Verify_Overlaps (
                bom_id => c3rec.BSI,
                op_num => c3rec.OSN,
                cmp_id => c3rec.CII,
                eff_date => c3rec.ED,
                dis_date => c3rec.DD,
                act => c3rec.A,
                comp_seq_id => c3rec.CSI,
                err_text => err_text);
            IF (ret_code <> 0) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c3rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_IMPL_COMP_OVERLAP',
                        err_text => err_text);
               UPDATE bom_inventory_comps_interface
                  SET process_flag = 3
                WHERE transaction_id = c3rec.TI;

               IF (ret_code <> 0) THEN
                  RAISE ret_code_error;
               END IF;
               RAISE continue_loop2;
            END IF;
         END IF;
/*
** Effectivity date check
*/
         stmt_num := 5;
         IF (to_date(c3rec.ED,'YYYY/MM/DD HH24:MI:SS') >
             to_date(c3rec.DD,'YYYY/MM/DD HH24:MI:SS'))  THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c3rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_EFFECTIVE_DATE_ERR',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c3rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop2;
         END IF;

         IF (c3rec.BITA = G_ProductFamily) THEN
/*
** Planning factor cannot be zero for Members
*/
            IF (c3rec.PF = 0)  THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c3rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_PLANNING_FACTOR',
                        err_text => err_text);
               UPDATE bom_inventory_comps_interface
                  SET process_flag = 3
                WHERE transaction_id = c3rec.TI;

               IF (ret_code <> 0) THEN
                  RAISE ret_code_error;
               END IF;
               RAISE continue_loop2;
            END IF;
            RAISE Update_Comp;
         END IF; -- Check for Product Family Member

/*
** Check for validity of operation sequences
*/
         stmt_num := 9;
         ret_code := Valid_Op_Seqs (
                org_id => c3rec.OI,
                assy_id => c3rec.AII,
                alt_desg => c3rec.ABD,
                op_seq => c3rec.OSN,
                err_text => err_text);

         if(ret_code = 0 and c3rec.BITA <> G_ProductFamily) then  -- This code is for bug 1804509
           update bom_inventory_comps_interface
           set operation_lead_time_percent =
              (select  operation_lead_time_percent
               FROM bom_operation_sequences bos
               WHERE c3rec.OSN = bos.operation_seq_num
               AND bos.ROUTING_SEQUENCE_ID =
                 (select COMMON_ROUTING_SEQUENCE_ID
                  from   BOM_OPERATIONAL_ROUTINGS bor
                  where  bor.ASSEMBLY_ITEM_ID = c3rec.AII
                  and  bor.ORGANIZATION_ID = c3rec.OI
                  and  NVL(bor.ALTERNATE_ROUTING_DESIGNATOR, NVL(c3rec.ABD, 'NONE')) = NVL(c3rec.ABD, 'NONE')
                  AND (c3rec.ABD IS NULL
                       OR  (c3rec.ABD IS NOT NULL
                            AND ( bor.ALTERNATE_ROUTING_DESIGNATOR = c3rec.ABD
                                 OR NOT EXISTS
                                 (SELECT NULL
                                  FROM BOM_OPERATIONAL_ROUTINGS bor2
                                  WHERE bor2.ASSEMBLY_ITEM_ID = c3rec.AII
                                  AND bor2.ORGANIZATION_ID = c3rec.OI
                                  AND bor2.ALTERNATE_ROUTING_DESIGNATOR = c3rec.ABD)))))
              AND bos.EFFECTIVITY_DATE < sysdate
              AND NVL(TRUNC(bos.DISABLE_DATE), TRUNC(SYSDATE)+1) > TRUNC(SYSDATE))
	      WHERE transaction_id = c3rec.TI;
         end if; -- Code for bug 1804509 ends here


         IF (ret_code <> 0) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c3rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_INVALID_OP_SEQ',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c3rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop2;
         END IF;

/*
** Planning_factor can be <>100 only if a
** assembly_item bom_item_type = planning bill or
** assembly_item bom_item_type = model/OC and component is optional or
** assembly_item bom_item_type = model/OC and component is mandatory and
**     component's forecast control = Consume and derive
*/
         stmt_num := 11;
         IF (c3rec.PF <> 100) THEN
            IF (c3rec.BITA = 3 OR
                ((c3rec.BITA = 1 OR c3rec.BITA = 2) AND c3rec.O = 1) OR
                ((c3rec.BITA = 1 OR c3rec.BITA = 2) AND c3rec.O = 2 AND
                  c3rec.AFC = 2)) THEN
               null;
            ELSE
               err_text := 'Planning percentage must be 100';
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c3rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_PLANNING_FACTOR_ERR',
                        err_text => err_text);
               UPDATE bom_inventory_comps_interface
                  SET process_flag = 3
                WHERE transaction_id = c3rec.TI;

               IF (ret_code <> 0) THEN
                  RAISE ret_code_error;
               END IF;
               RAISE continue_loop2;
            END IF;
         END IF;
/*
** If component is an ATO Standard item and the bill is a PTO Model or
** PTO Option Class, then Optional must be Yes
*/
         stmt_num := 12;
         IF (c3rec.BITC = 4 AND c3rec.RTOFC = 'Y' AND c3rec.BITA in (1,2)
             AND c3rec.PCFA = 'Y' AND c3rec.O = 2) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c3rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_OPTIONAL_ERR',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c3rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop2;
         END IF;
/*
** If planning bill then
** yield must be 1 and order entry values should be defaulted
*/
         stmt_num := 13;
         IF (c3rec.BITA = 3) THEN
            UPDATE bom_inventory_comps_interface
               SET component_yield_factor = 1,
                   check_atp = 2,
                   include_on_ship_docs = 2,
                   so_basis = 2,
                   mutually_exclusive_options = 2,
                   required_to_ship = 2,
                   required_for_revenue = 2,
                   low_quantity = NULL,
                   high_quantity = NULL
             WHERE transaction_id = c3rec.TI;
         END IF;

         err_text := NULL;
/*
** Validate component details
*/
         stmt_num := 14;
         IF (c3rec.QR not in (1,2)) THEN
            err_text := 'QUANTITY_RELATED must be 1 or 2';
         END IF;

         IF (c3rec.WST is not NULL) and (c3rec.WST not in (1,2,3,4,5,6)) THEN
            err_text := 'WIP_SUPPLY_TYPE must be 1 or 2 or 3 or 4 or 5 or 6';
         END IF;

         IF (c3rec.SB not in (1,2)) THEN
            err_text := 'SO_BASIS must be 1 or 2';
         END IF;

         IF (c3rec.O not in(1,2)) THEN
            err_text := 'OPTIONAL must be 1 or 2';
         END IF;

         IF (c3rec.MEO not in(1,2)) THEN
            err_text := 'MUTUALLY_EXCLUSIVE_OPTIONS must be 1 or 2';
         END IF;

         IF (c3rec.ICR not in(1,2)) THEN
            err_text := 'INCLUDE_IN_COST_ROLLUP must be 1 or 2';
         END IF;

         IF (c3rec.CATP not in(1,2)) THEN
            err_text := 'CHECK_ATP must be 1 or 2';
         END IF;

         IF (c3rec.RTS not in(1,2)) THEN
            err_text := 'REQUIRED_TO_SHIP must be 1 or 2';
         END IF;

         IF (c3rec.RFR not in(1,2)) THEN
            err_text := 'REQUIRED_FOR_REVENUE must be 1 or 2';
         END IF;

         IF (c3rec.ISD not in(1,2)) THEN
            err_text := 'INCLUDE_ON_SHIP_DOCS must be 1 or 2';
         END IF;

/* Commented for Bug 2243418  */
/*
         IF (c3rec.CATP = 1 and not(c3rec.AF in ('Y', 'C', 'R')
	     AND c3rec.ACF = 'Y' and c3rec.CQ > 0)) THEN
            err_text := 'Component cannot have ATP check';
         END IF;
*/
         IF (c3rec.BITA <> 1 and c3rec.BITA <> 2 and c3rec.O = 1) THEN
            err_text := 'Component cannot be optional';
        END IF;

         IF (c3rec.BITC <> 2 and c3rec.SB = 1) THEN
            err_text := 'Basis must be None';
         END IF;

         IF (c3rec.RTOF = 'Y' and c3rec.RFR = 1) THEN
            err_text := 'An ATO item cannot be required for revenue';
         END IF;

         IF (c3rec.RTOF = 'Y' and c3rec.RTS = 1) THEN
            err_text := 'An ATO item cannot be required to ship';
         END IF;

         IF (c3rec.MEO = 1 and c3rec.BITC <>2) THEN
            err_text := 'Component cannot be mutually exclusive';
         END IF;

         IF (c3rec.LQ > c3rec.CQ) and (c3rec.LQ is not null) THEN
            err_text := 'Low quantity must be less than or equal to component quantity';
         END IF;

         IF (c3rec.HQ < c3rec.CQ) and (c3rec.HQ is not null) THEN
            err_text := 'High quantity must be greater than or equal to component quantity';
         END IF;

         IF (c3rec.CYF <> 1 and c3rec.BITC = 2) THEN
            err_text := 'Component yield factor must be 1';
         END IF;

         IF (c3rec.CYF <= 0) THEN
            err_text := 'Component yield factor must be greater than zero';
         END IF;
/*  Bug No : 2235454
    Description :
    BOM form is allowing the model bill as component to the assembly Item with the
    wip supply type is NULL. But the import process is erroring out.
    There is an update in the pld: BOMFMBM1.pld
    -- R11 onwards a Model/Option Class will not be forced to have
    -- a Wip_supply_type of Phantom.
    -- But the user would still see a warning.

         IF (c3rec.BITC = 1 or c3rec.BITC = 2) and (c3rec.WST <> 6) THEN
            err_text := 'WIP supply type must be Phantom';
         END IF;
*/
         IF (((c3rec.CATP = 1) or (c3rec.QR = 1) or
             (c3rec.BITC = 2 and c3rec.PCF = 'Y'))
           and c3rec.CQ < 0) THEN
            err_text := 'Component quantity cannot be negative';
         END IF;

         IF (c3rec.QR = 1) and (c3rec.CQ <> round(c3rec.CQ)) THEN
            err_text := 'Component quantity must be an integer value';
         END IF;

	IF (c3rec.QR = 1) and (c3rec.CQ <> round(c3rec.CQ) ) THEN
	    err_text := 'Component quantity must be an integer value';
        END IF;

/* Check if Order Entry is installed */

         stmt_num := 15;
         BEGIN
            SELECT distinct 'I'
              INTO oe_install
              FROM fnd_product_installations
             WHERE application_id = 300
               AND status = 'I';

            IF (oe_install = 'I') and (c3rec.CQ <> round(c3rec.CQ)) and
              (c3rec.PCFA = 'Y') THEN
               err_text := 'Component quantity must be an integer value';
            END IF;
         EXCEPTION
            WHEN no_data_found THEN
               null;
         END;

         IF (err_text is not null) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c3rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMPONENT_ERROR',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c3rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop2;
         END IF;

/*
** Validate subinventory
*/
         stmt_num := 16;
         IF (c3rec.SLI is not null and c3rec.SS is null) THEN
            RAISE write_loc_error;
         END IF;

         IF (c3rec.SLI is null and c3rec.SS is null) THEN
            GOTO check_quantity_related;
         END IF;

         SELECT inventory_asset_flag,restrict_subinventories_code,
                restrict_locators_code, location_control_code
           INTO inv_asst, r_subinv, r_loc, loc_ctl
           FROM mtl_system_items
          WHERE inventory_item_id = c3rec.CII
            AND organization_id = c3rec.OI;
/*
** If item locator control is null, set to 1 (no loc control)
*/
         IF (loc_ctl is null) THEN
            loc_ctl := 1;
         END IF;
/*
** If subinv is not restricted and locator is, then make
** locator unrestricted
*/

         IF (r_subinv = 2) and (r_loc = 1) THEN
            r_loc := 2;
         END IF;
/*
** Check if subinventory is valid
*/

/*
** Get value of profile INV:EXPENSE_TO_ASSET_TRANSFER
*/
         stmt_num := 17;
         BOMPRFIL.bom_pr_get_profile(
                appl_short_name => 'INV',
                profile_name => 'INV:EXPENSE_TO_ASSET_TRANSFER',
                user_id => user_id,
                resp_appl_id => prog_appid,
                resp_id => 401,
                profile_value => X_expense_to_asset_transfer,
                return_code => ret_code,
                return_message => err_text);

         IF (ret_code <> 0) THEN
            RETURN(ret_code);
         END IF;

         IF (r_subinv = 2) THEN    /* non-restricted subinventory */
            IF (X_expense_to_asset_transfer = 1) THEN
               stmt_num := 18;
               BEGIN
                  SELECT locator_type
                    INTO sub_loc_code
                    FROM mtl_secondary_inventories
                   WHERE secondary_inventory_name = c3rec.SS
                     AND organization_id = c3rec.OI
                     AND nvl(disable_date,TRUNC(c3rec.EDD)+1) >
                         TRUNC(c3rec.EDD)
                     AND quantity_tracked = 1;
               EXCEPTION
                  WHEN no_data_found THEN
                     RAISE write_subinv_error;
               END;
            ELSE
               stmt_num := 19;
               BEGIN
                  SELECT locator_type
                    INTO sub_loc_code
                    FROM mtl_secondary_inventories
                   WHERE secondary_inventory_name = c3rec.SS
                     AND organization_id = c3rec.OI
                     AND nvl(disable_date,TRUNC(c3rec.EDD)+1) >
                         TRUNC(c3rec.EDD)
                     AND quantity_tracked = 1
                     AND ((inv_asst = 'Y' and asset_inventory = 1)
                          or
                          (inv_asst = 'N'));
               EXCEPTION
                  WHEN no_data_found THEN
                     RAISE write_subinv_error;
               END;
            END IF;
         ELSE                           /* restricted subinventory */
            IF (X_expense_to_asset_transfer = 1) THEN
               stmt_num := 20;
               BEGIN
                  SELECT locator_type
                    INTO sub_loc_code
                    FROM mtl_secondary_inventories sub,
                         mtl_item_sub_inventories item
                   WHERE item.organization_id = sub.organization_id
                     AND item.secondary_inventory =
                         sub.secondary_inventory_name
                     AND item.inventory_item_id = c3rec.CII
                     AND sub.secondary_inventory_name = c3rec.SS
                     AND sub.organization_id = c3rec.OI
                     AND nvl(sub.disable_date,TRUNC(c3rec.EDD)+1) >
                         TRUNC(c3rec.EDD)
                     AND sub.quantity_tracked = 1;
               EXCEPTION
                  WHEN no_data_found THEN
                     RAISE write_subinv_error;
               END;
            ELSE
               stmt_num := 21;
               BEGIN
                  SELECT locator_type
                    INTO sub_loc_code
                    FROM mtl_secondary_inventories sub,
                         mtl_item_sub_inventories item
                   WHERE item.organization_id = sub.organization_id
                     AND item.secondary_inventory =
                         sub.secondary_inventory_name
                     AND item.inventory_item_id = c3rec.CII
                     AND sub.secondary_inventory_name = c3rec.SS
                     AND sub.organization_id = c3rec.OI
                     AND nvl(sub.disable_date,TRUNC(c3rec.EDD)+1) >
                         TRUNC(c3rec.EDD)
                     AND sub.quantity_tracked = 1
                     AND ((inv_asst = 'Y' and sub.asset_inventory = 1)
                          or
                          (inv_asst = 'N'));
               EXCEPTION
                  WHEN no_data_found THEN
                     RAISE write_subinv_error;
               END;
            END IF;
         END IF;
/*
** Validate locator
*/
/* Org level */

         stmt_num := 22;
         SELECT stock_locator_control_code
           INTO org_loc
           FROM mtl_parameters
          WHERE organization_id = c3rec.OI;

         IF (org_loc = 1) and (c3rec.SLI is not null) THEN
            RAISE write_loc_error;
         END IF;

         IF ((org_loc = 2) or (org_loc = 3))and (c3rec.SLI is null) THEN
            RAISE write_loc_error;
         END IF;

         IF ((org_loc = 2) or (org_loc = 3)) and (c3rec.SLI is not null) THEN
            IF (r_loc = 2) THEN    /* non-restricted locator */
               stmt_num := 23;
               BEGIN
                  SELECT 'loc exists'
                    INTO dummy
                    FROM mtl_item_locations
                   WHERE inventory_location_id = c3rec.SLI
                     AND organization_id = c3rec.OI
                     AND subinventory_code = c3rec.SS
                     AND nvl(disable_date,trunc(c3rec.EDD)+1) >
                         trunc(c3rec.EDD);
               EXCEPTION
                  WHEN no_data_found THEN
                     RAISE write_loc_error;
               END;
            ELSE                   /* restricted locator */
               stmt_num := 24;
               BEGIN
                  SELECT 'restricted loc exists'
                    INTO dummy
                    FROM mtl_item_locations loc,
                         mtl_secondary_locators item
                   WHERE loc.inventory_location_id = c3rec.SLI
                     AND loc.organization_id = c3rec.OI
                     AND loc.subinventory_code = c3rec.SS
                     AND nvl(loc.disable_date,trunc(c3rec.EDD)+1) >
                         trunc(c3rec.EDD)
                     AND loc.inventory_location_id = item.secondary_locator
                     AND loc.organization_id = item.organization_id
                     AND item.inventory_item_id = c3rec.CII;
               EXCEPTION
                  WHEN no_data_found THEN
                     RAISE write_loc_error;
               END;
            END IF;
         END IF;

         IF (org_loc not in (1,2,3,4) and c3rec.SLI is not null) THEN
            RAISE write_loc_error;
         END IF;

/* Subinv level */

         IF (org_loc = 4 and sub_loc_code = 1 and c3rec.SLI is not null) THEN
            RAISE write_loc_error;
         END IF;

         stmt_num := 25;
         IF (org_loc = 4) THEN
            IF ((sub_loc_code = 2) or (sub_loc_code = 3))
               and (c3rec.SLI is null) THEN
               RAISE write_loc_error;
            END IF;

            IF ((sub_loc_code = 2) or (sub_loc_code = 3))
               and (c3rec.SLI is not null) THEN
               /* non-restricted locator */
               IF (r_loc = 2) THEN
                  BEGIN
                     SELECT 'loc exists'
                       INTO dummy
                       FROM mtl_item_locations
                      WHERE inventory_location_id = c3rec.SLI
                        AND organization_id = c3rec.OI
                        AND subinventory_code = c3rec.SS
                        AND nvl(disable_date,trunc(c3rec.EDD)+1) >
                               trunc(c3rec.EDD);
                  EXCEPTION
                     WHEN no_data_found THEN
                        RAISE write_loc_error;
                  END;
               /* restricted locator */
               ELSE
                  stmt_num := 26;
                  BEGIN
                     SELECT 'restricted loc exists'
                       INTO dummy
                       FROM mtl_item_locations loc,
                            mtl_secondary_locators item
                      WHERE loc.inventory_location_id = c3rec.SLI
                        AND loc.organization_id = c3rec.OI
                        AND loc.subinventory_code = c3rec.SS
                        AND nvl(loc.disable_date,trunc(c3rec.EDD)+1) >
                             trunc(c3rec.EDD)
                        AND loc.inventory_location_id = item.secondary_locator
                        AND loc.organization_id = item.organization_id
                        AND item.inventory_item_id = c3rec.CII;
                  EXCEPTION
                     WHEN no_data_found THEN
                        RAISE write_loc_error;
                  END;
               END IF;
            END IF;

            IF (sub_loc_code not in (1,2,3,5) and c3rec.SLI is not null) THEN
               RAISE write_loc_error;
            END IF;
         END IF;

/*
** Item level
*/

         stmt_num := 27;
         IF (org_loc = 4 and sub_loc_code = 5 and loc_ctl = 1
          and c3rec.SLI is not null) THEN
            RAISE write_loc_error;
         END IF;

         IF (org_loc = 4 and sub_loc_code = 5) THEN
            IF ((loc_ctl = 2) or (loc_ctl = 3))
               and (c3rec.SLI is null) THEN
               RAISE write_loc_error;
            END IF;

            IF ((loc_ctl = 2) or (loc_ctl = 3))
                  and (c3rec.SLI is not null) THEN
               /* non-restricted locator */
               IF (r_loc = 2) THEN
                  BEGIN
                     SELECT 'loc exists'
                       INTO dummy
                       FROM mtl_item_locations
                      WHERE inventory_location_id = c3rec.SLI
                        AND organization_id = c3rec.OI
                        AND subinventory_code = c3rec.SS
                        AND nvl(disable_date,trunc(c3rec.EDD)+1) >
                                  trunc(c3rec.EDD);
                  EXCEPTION
                     WHEN no_data_found THEN
                        RAISE write_loc_error;
                  END;
               ELSE
                  /* restricted locator */
                  stmt_num := 28;
                  BEGIN
                     SELECT 'restricted loc exists'
                       INTO dummy
                       FROM mtl_item_locations loc,
                            mtl_secondary_locators item
                      WHERE loc.inventory_location_id = c3rec.SLI
                        AND loc.organization_id = c3rec.OI
                        AND loc.subinventory_code = c3rec.SS
                        AND nvl(loc.disable_date,trunc(c3rec.EDD)+1) >
                                trunc(c3rec.EDD)
                        AND loc.inventory_location_id = item.secondary_locator
                        AND loc.organization_id = item.organization_id
                        AND item.inventory_item_id = c3rec.CII;
                  EXCEPTION
                     WHEN no_data_found THEN
                        RAISE write_loc_error;
                  END;
               END IF;
            END IF;

            IF (loc_ctl not in (1,2,3) and c3rec.SLI is not null) THEN
               raise write_loc_error;
            END IF;
         END IF;

/*
** If Quantity Related = Yes, then the number of reference designators
** must equal the Quantity
*/

<<check_quantity_related>>
         stmt_num := 12;
         IF (c3rec.QR = 1) THEN
            stmt_num := 4;
            SELECT count(*)
              INTO ref_qty
              FROM bom_reference_designators
             WHERE component_sequence_id = c3rec.CSI;

            stmt_num := 4;
            SELECT count(*)
              INTO int_ref_qty
              FROM bom_ref_desgs_interface
             WHERE component_sequence_id = c3rec.CSI
               AND transaction_type = G_Insert
               AND process_flag = 4;

            IF (ref_qty + int_ref_qty <> c3rec.CQ) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c3rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_QUANTITY_RELATED_INVALID',
                        err_text => err_text);
               UPDATE bom_inventory_comps_interface
                  SET process_flag = 3
                WHERE transaction_id = c3rec.TI;

               IF (ret_code <> 0) THEN
                  RAISE ret_code_error;
               END IF;
               RAISE continue_loop2;
            END IF;
         END IF;
/*
** Set process flag to 4
*/
         RAISE update_comp;

         IF (mod(c3%rowcount, G_rows_to_commit) = 0) THEN
            COMMIT;
         END IF;

      EXCEPTION
         WHEN Write_Loc_Error THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_LOCATOR_INVALID',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c3rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;

         WHEN Write_Subinv_Error THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_SUBINV_INVALID',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c3rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;

         WHEN Update_Comp THEN
            stmt_num := 29;
            UPDATE bom_inventory_comps_interface
               SET process_flag = 4
             WHERE transaction_id = c3rec.TI;

         WHEN Continue_Loop2 THEN
            IF (mod(c3%rowcount, G_rows_to_commit) = 0) THEN
               COMMIT;
            END IF;
      END; -- each component

   END LOOP; -- cursor


/*
** FOR INSERTS - Validate
*/

/*
** Verify for uniqueness of component seq ID
*/
   FOR c1rec IN c1 LOOP
      BEGIN
         x_bill_type        := null;
	 x_assembly_item_id := null;
	 x_valid_comp       := null;

         stmt_num := 1;

         ret_code := Verify_Component_Count (
                bill_seq_id => c1rec.BSI,
                err_text => err_text);
         IF (ret_code <> 0) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMP_COUNT_EXCEEDS_LIMIT',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop;
         END IF;

         stmt_num := 1.5;

         ret_code := Verify_unique_component (
                cmp_seq_id => c1rec.CSI,
                exist_flag => 2,
                err_text => err_text);
         IF (ret_code <> 0) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMP_SEQ_ID_DUPLICATE',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop;
         END IF;
/*
** Verify uniqueness of bill seq id,effective date,op seq, and component item
*/
         stmt_num := 2;
         ret_code := Verify_Duplicate_Component (
                bill_seq_id => c1rec.BSI,
                eff_date => c1rec.ED,
                cmp_item_id => c1rec.CII,
                op_seq => c1rec.OSN,
                act => c1rec.A,
                comp_seq_id => 1,
                err_text => err_text);
         IF (ret_code <> 0) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMPONENT_DUPLICATE',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop;
         END IF;

/*
** Make sure there is no overlapping components
*/
         stmt_num := 4;
         IF (c1rec.ID is not null) THEN
            ret_code := Verify_Overlaps (
                bom_id => c1rec.BSI,
                op_num => c1rec.OSN,
                cmp_id => c1rec.CII,
                eff_date => c1rec.ED,
                dis_date => c1rec.DD,
                act => c1rec.A,
                comp_seq_id => 1,
                err_text => err_text);
            IF (ret_code <> 0) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_IMPL_COMP_OVERLAP',
                        err_text => err_text);
               UPDATE bom_inventory_comps_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RAISE ret_code_error;
               END IF;
               RAISE continue_loop;
            END IF;
         END IF;
/*
** Effectivity date check
*/
         stmt_num := 4.1;
         IF (to_date(c1rec.ED,'YYYY/MM/DD HH24:MI:SS') >
              to_date(c1rec.DD,'YYYY/MM/DD HH24:MI:SS'))  THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_EFFECTIVE_DATE_ERR',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop;
         END IF;
/*
** Check if Member of a Product Family
*/

	 stmt_num := 4.2;
         DECLARE
            CURSOR GetBOMItemType IS
               SELECT bom_item_type, assembly_item_id
                 FROM mtl_system_items msi,
		      bom_bill_of_materials bom
                WHERE msi.organization_id = bom.organization_id
                  AND msi.inventory_item_id = bom.assembly_item_id
		  AND bom.bill_sequence_id = c1rec.BSI;
         BEGIN
            FOR c1 IN GetBOMItemType LOOP
               x_bill_type := c1.bom_item_type;
	       x_assembly_item_id := c1.assembly_item_id;
            END LOOP;

            IF (x_bill_type is null) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_ASSY_ITEM_MISSING',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               RAISE continue_loop;
            ELSIF (x_bill_type = G_ProductFamily) THEN
/*
** Planning factor cannot be zero for Members
*/

/***************** This check is not required *****************************
* Fixed Bug: 916428
*
               IF (c1rec.PF = 0)  THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_PLANNING_FACTOR',
                        err_text => err_text);
                  UPDATE bom_inventory_comps_interface
                     SET process_flag = 3
                   WHERE transaction_id = c1rec.TI;

                  IF (ret_code <> 0) THEN
                     RAISE ret_code_error;
                  END IF;
                  RAISE continue_loop;
               END IF;
*
*****************************************************************************/

/*
** Check Member item attributes
*/
	       stmt_num := 4.3;
               DECLARE
                  CURSOR ItemIsValid IS
                     SELECT inventory_item_id
                       FROM mtl_system_items
                      WHERE organization_id = c1rec.OI
                        AND inventory_item_id = c1rec.CII
			AND bom_enabled_flag = 'Y'
			AND eng_item_flag = 'N'
			AND bom_item_type <> G_ProductFamily
			AND product_family_item_id is null
			AND c1rec.CII <> x_assembly_item_id;
               BEGIN
                  FOR c1 IN ItemIsValid LOOP
                     x_valid_comp := c1.inventory_item_id;
                  END LOOP;

                  IF (x_valid_comp is null) THEN
                     ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_INVALID_ITEM_ATTRIBUTES',
                        err_text => err_text);
                     UPDATE bom_inventory_comps_interface
                        SET process_flag = 3
                      WHERE transaction_id = c1rec.TI;

                     IF (ret_code <> 0) THEN
                        RETURN(ret_code);
                     END IF;
                     RAISE continue_loop;
                  END IF; -- Check if member is invalid
               END;
               RAISE Update_Comp;
            END IF;  -- Checking BOM Item Type of parent
         END; -- Check for Product Family Member

/*
** Verify that the bill is not a common bill.  If so it cannot have
** components
*/
         stmt_num := 5;
         BEGIN
            SELECT 'Is pointing to a common'
              INTO dummy
              FROM bom_bill_of_materials
             WHERE bill_sequence_id = c1rec.BSI
               AND common_bill_sequence_id <> c1rec.BSI;

            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMMON_COMP',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop;
         EXCEPTION
            WHEN no_data_found THEN
               null;
         END;

/*
** If bill is a Common for other bills, then make sure Component Item
** exists in those orgs
*/
         stmt_num := 6;
         BEGIN
            SELECT 1
              INTO dummy
              FROM bom_bill_of_materials bbom
             WHERE bbom.common_bill_sequence_id = c1rec.BSI
               AND bbom.organization_id <> bbom.common_organization_id
               AND not exists
                  (SELECT null
                     FROM mtl_system_items msi
                    WHERE msi.organization_id = bbom.organization_id
                      AND msi.inventory_item_id = c1rec.CII
                      AND msi.bom_enabled_flag = 'Y'
                      AND ((bbom.assembly_type = 2)
                           OR
                           (bbom.assembly_type = 1
                            AND msi.eng_item_flag = 'N')))
		AND rownum < 2;

            err_text := 'Component item does not exist in common organizations or has incorrect attributes';
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INV_COMPS_INTERFACE',
                        msg_name => 'BOM_COMP_COMMON_INVALID',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop;
         EXCEPTION
            WHEN no_data_found THEN
               null;
         END;

/*
** Verify the validity of item attributes
*/
         stmt_num := 7;
         DECLARE
            CURSOR CheckBOM IS
               SELECT assembly_type
                 FROM bom_bill_of_materials
                WHERE bill_sequence_id = c1rec.BSI;
         BEGIN
            eng_bill := null;
            FOR X_bill IN CheckBOM LOOP
               eng_bill := X_Bill.assembly_type;
            END LOOP;
         END;

         stmt_num := 8;
         ret_code := Verify_Item_Attributes (
                org_id => c1rec.OI,
                cmp_id => c1rec.CII,
                eng_bill => eng_bill,
                assy_id => c1rec.AII,
                err_text => err_text);
         IF (ret_code <> 0) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_INVALID_ITEM_ATTRIBUTES',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop;
         END IF;
/*
** Check for validity of operation sequences
*/
         stmt_num := 9;
         ret_code := Valid_Op_Seqs (
                org_id => c1rec.OI,
                assy_id => c1rec.AII,
                alt_desg => c1rec.ABD,
                op_seq => c1rec.OSN,
                err_text => err_text);
--bugFix 1851537 Begin
if (ret_code=0) then
      update bom_inventory_comps_interface
      set operation_lead_time_percent =
              (select  operation_lead_time_percent
               FROM bom_operation_sequences bos
               WHERE c1rec.OSN = bos.operation_seq_num
               AND bos.ROUTING_SEQUENCE_ID =
                 (select COMMON_ROUTING_SEQUENCE_ID
                  from   BOM_OPERATIONAL_ROUTINGS bor
                  where  bor.ASSEMBLY_ITEM_ID = c1rec.AII
                  and  bor.ORGANIZATION_ID = c1rec.OI
                  and  NVL(bor.ALTERNATE_ROUTING_DESIGNATOR, NVL(c1rec.ABD, 'NONE')) = NVL(c1rec.ABD,'NONE')
                  AND (c1rec.ABD IS NULL
                       OR  (c1rec.ABD IS NOT NULL
                            AND ( bor.ALTERNATE_ROUTING_DESIGNATOR = c1rec.ABD
                                 OR NOT EXISTS
                                 (SELECT NULL
                                  FROM BOM_OPERATIONAL_ROUTINGS bor2
                                  WHERE bor2.ASSEMBLY_ITEM_ID = c1rec.AII
                                  AND bor2.ORGANIZATION_ID = c1rec.OI
                                  AND bor2.ALTERNATE_ROUTING_DESIGNATOR = c1rec.
ABD)))))
	 AND bos.EFFECTIVITY_DATE < sysdate
         AND NVL(TRUNC(bos.DISABLE_DATE), TRUNC(SYSDATE)+1) > TRUNC(SYSDATE))
         WHERE transaction_id = c1rec.TI;
  end if;
--bugFix 1851537 End

         IF (ret_code <> 0) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_INVALID_OP_SEQ',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop;
         END IF;

/*
** Planning_factor can be <>100 only if a
** assembly_item bom_item_type = planning bill or
** assembly_item bom_item_type = model/OC and component is optional or
** assembly_item bom_item_type = model/OC and component is mandatory and
**     component's forecast control = Consume and derive
*/
         stmt_num := 11;
         IF (c1rec.PF <> 100) THEN
            IF (c1rec.BITA = 3 OR
                ((c1rec.BITA = 1 OR c1rec.BITA = 2) AND c1rec.O = 1) OR
                ((c1rec.BITA = 1 OR c1rec.BITA = 2) AND c1rec.O = 2 AND
                  c1rec.AFC = 2)) THEN
               null;
            ELSE
               err_text := 'Planning percentage must be 100';
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_PLANNING_FACTOR_ERR',
                        err_text => err_text);
               UPDATE bom_inventory_comps_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RAISE ret_code_error;
               END IF;
               RAISE continue_loop;
            END IF;
         END IF;

/*
** Verfify Change_Notice
*/
 stmt_num := 11.5;

         If (c1rec.CN is not NULL) THEN
         BEGIN
            SELECT 1
              INTO dummy
              FROM eng_engineering_changes
             WHERE organization_id = c1rec.OI
               AND change_notice = c1rec.CN;
         EXCEPTION
            WHEN no_data_found THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'ENG_PARENTECO_NOT_EXIST',
                        err_text => err_text);
               UPDATE bom_inventory_comps_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                    RAISE ret_code_error;
               END IF;
	       RAISE continue_loop;
           END;
          END IF;
/*

/*
** If component is an ATO Standard item and the bill is a PTO Model or
** PTO Option Class, then Optional must be Yes
*/
         stmt_num := 12;
         IF (c1rec.BITC = 4 AND c1rec.RTOFC = 'Y' AND c1rec.BITA in (1,2)
             AND c1rec.PCFA = 'Y' AND c1rec.O = 2) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_OPTIONAL_ERR',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop;
         END IF;
/*
** If planning bill then
** yield must be 1 and order entry values should be defaulted
*/
         stmt_num := 13;
         IF (c1rec.BITA = 3) THEN
            UPDATE bom_inventory_comps_interface
               SET component_yield_factor = 1,
                   check_atp = 2,
                   include_on_ship_docs = 2,
                   so_basis = 2,
                   mutually_exclusive_options = 2,
                   required_to_ship = 2,
                   required_for_revenue = 2,
                   low_quantity = NULL,
                   high_quantity = NULL
             WHERE transaction_id = c1rec.TI;
         END IF;

         err_text := NULL;
/*
** Validate component details
*/
         stmt_num := 14;
         IF (c1rec.QR not in (1,2)) THEN
            err_text := 'QUANTITY_RELATED must be 1 or 2';
         END IF;

         IF (c1rec.WST is not null) and (c1rec.WST not in (1,2,3,4,5,6)) THEN
            err_text := 'WIP_SUPPLY_TYPE must be 1 or 2 or 3 or 4 or 5 or 6';
         END IF;

         IF (c1rec.SB not in (1,2)) THEN
            err_text := 'SO_BASIS must be 1 or 2';
         END IF;

         IF (c1rec.O not in(1,2)) THEN
            err_text := 'OPTIONAL must be 1 or 2';
         END IF;

         IF (c1rec.MEO not in(1,2)) THEN
            err_text := 'MUTUALLY_EXCLUSIVE_OPTIONS must be 1 or 2';
         END IF;

         IF (c1rec.ICR not in(1,2)) THEN
            err_text := 'INCLUDE_IN_COST_ROLLUP must be 1 or 2';
         END IF;

         IF (c1rec.CATP not in(1,2)) THEN
            err_text := 'CHECK_ATP must be 1 or 2';
         END IF;

         IF (c1rec.RTS not in(1,2)) THEN
            err_text := 'REQUIRED_TO_SHIP must be 1 or 2';
         END IF;

         IF (c1rec.RFR not in(1,2)) THEN
            err_text := 'REQUIRED_FOR_REVENUE must be 1 or 2';
         END IF;

         IF (c1rec.ISD not in(1,2)) THEN
            err_text := 'INCLUDE_ON_SHIP_DOCS must be 1 or 2';
         END IF;
/* Commented for Bug 2243418  */
/*
         IF (c1rec.CATP = 1 and not(c1rec.AF in ( 'Y', 'C', 'R')
	     AND c1rec.ACF = 'Y' and c1rec.CQ > 0)) THEN
            err_text := 'Component cannot have ATP check';
         END IF;
*/
         IF (c1rec.BITA <> 1 and c1rec.BITA <> 2 and c1rec.O = 1) THEN
            err_text := 'Component cannot be optional';
         END IF;

         IF (c1rec.BITC <> 2 and c1rec.SB = 1) THEN
            err_text := 'Basis must be None';
         END IF;

         IF (c1rec.RTOF = 'Y' and c1rec.RFR = 1) THEN
            err_text := 'An ATO item cannot be required for revenue';
         END IF;

         IF (c1rec.RTOF = 'Y' and c1rec.RTS = 1) THEN
            err_text := 'An ATO item cannot be required to ship';
         END IF;

         IF (c1rec.MEO = 1 and c1rec.BITC <>2) THEN
            err_text := 'Component cannot be mutually exclusive';
         END IF;

         IF (c1rec.LQ > c1rec.CQ) and (c1rec.LQ is not null) THEN
            err_text :=
               'Low quantity must be less than or equal to component quantity';
         END IF;

         IF (c1rec.HQ < c1rec.CQ) and (c1rec.HQ is not null) THEN
            err_text :=
           'High quantity must be greater than or equal to component quantity';
         END IF;

         IF (c1rec.CYF <> 1 and c1rec.BITC = 2) THEN
            err_text := 'Component yield factor must be 1';
         END IF;

         IF (c1rec.CYF <= 0) THEN
            err_text := 'Component yield factor must be greater than zero';
         END IF;
/*
    Bug No : 2235454
    Description :
    BOM form is allowing the model bill as component to the assembly Item with the
    wip supply type is NULL. But the import process is erroring out.
    There is an update in the pld: BOMFMBM1.pld
    -- R11 onwards a Model/Option Class will not be forced to have
    -- a Wip_supply_type of Phantom.
    -- But the user would still see a warning.

        IF (c1rec.BITC = 1 or c1rec.BITC = 2) and (c1rec.WST <> 6) THEN
            err_text := 'WIP supply type must be Phantom';
         END IF;
*/
         IF (((c1rec.CATP = 1) or (c1rec.QR = 1) or
             (c1rec.BITC = 2 and c1rec.PCF = 'Y'))
           and c1rec.CQ < 0) THEN
            err_text := 'Component quantity cannot be negative';
         END IF;

         IF (c1rec.QR = 1) and (c1rec.CQ <> round(c1rec.CQ)) THEN
            err_text := 'Component quantity must be an integer value';
         END IF;

	IF (c1rec.QR = 1) and (c1rec.CQ <> round(c1rec.CQ) ) THEN
	    err_text := 'Component quantity must be an integer value';
        END IF;

/* Check if Order Entry is installed */

         stmt_num := 15;
         BEGIN
            SELECT distinct 'I'
              INTO oe_install
              FROM fnd_product_installations
             WHERE application_id = 300
               AND status = 'I';

            IF (oe_install = 'I') and (c1rec.CQ <> round(c1rec.CQ)) and
              (c1rec.PCFA = 'Y') THEN
               err_text := 'Component quantity must be an integer value';
            END IF;
         EXCEPTION
            WHEN no_data_found THEN
               null;
         END;

         IF (err_text is not null) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_COMPONENT_ERROR',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;
            RAISE continue_loop;
         END IF;

/*
** Validate subinventory
*/
         stmt_num := 16;
         IF (c1rec.SLI is not null and c1rec.SS is null) THEN
            RAISE write_loc_error;
         END IF;

         IF (c1rec.SLI is null and c1rec.SS is null) THEN
            RAISE update_comp;
         END IF;

         SELECT inventory_asset_flag,restrict_subinventories_code,
                restrict_locators_code, location_control_code
           INTO inv_asst, r_subinv, r_loc, loc_ctl
           FROM mtl_system_items
          WHERE inventory_item_id = c1rec.CII
            AND organization_id = c1rec.OI;
/*
** If item locator control is null, set to 1 (no loc control)
*/
         IF (loc_ctl is null) THEN
            loc_ctl := 1;
         END IF;
/*
/*
** If subinv is not restricted and locator is, then make
** locator unrestricted
*/

         IF (r_subinv = 2) and (r_loc = 1) THEN
            r_loc := 2;
         END IF;
/*
** Check if subinventory is valid
*/

/*
** Get value of profile INV:EXPENSE_TO_ASSET_TRANSFER
*/
         stmt_num := 17;
         BOMPRFIL.bom_pr_get_profile(
                appl_short_name => 'INV',
                profile_name => 'INV:EXPENSE_TO_ASSET_TRANSFER',
                user_id => user_id,
                resp_appl_id => prog_appid,
                resp_id => 401,
                profile_value => X_expense_to_asset_transfer,
                return_code => ret_code,
                return_message => err_text);
         IF (ret_code <> 0) THEN
            RETURN(ret_code);
         END IF;

         IF (r_subinv = 2) THEN    /* non-restricted subinventory */
            IF (X_expense_to_asset_transfer = 1) THEN
               stmt_num := 18;
               BEGIN
                  SELECT locator_type
                    INTO sub_loc_code
                    FROM mtl_secondary_inventories
                   WHERE secondary_inventory_name = c1rec.SS
                     AND organization_id = c1rec.OI
                     AND nvl(disable_date,TRUNC(c1rec.EDD)+1) >
			 TRUNC(c1rec.EDD)
                     AND quantity_tracked = 1;
               EXCEPTION
                  WHEN no_data_found THEN
                     RAISE write_subinv_error;
               END;
            ELSE
               stmt_num := 19;
               BEGIN
                  SELECT locator_type
                    INTO sub_loc_code
                    FROM mtl_secondary_inventories
                   WHERE secondary_inventory_name = c1rec.SS
                     AND organization_id = c1rec.OI
                     AND nvl(disable_date,TRUNC(c1rec.EDD)+1) >
			 TRUNC(c1rec.EDD)
                     AND quantity_tracked = 1
                     AND ((inv_asst = 'Y' and asset_inventory = 1)
                          or
                          (inv_asst = 'N'));
               EXCEPTION
                  WHEN no_data_found THEN
                     RAISE write_subinv_error;
               END;
            END IF;
         ELSE                           /* restricted subinventory */
            IF (X_expense_to_asset_transfer = 1) THEN
               stmt_num := 20;
               BEGIN
                  SELECT locator_type
                    INTO sub_loc_code
                    FROM mtl_secondary_inventories sub,
                         mtl_item_sub_inventories item
                   WHERE item.organization_id = sub.organization_id
                     AND item.secondary_inventory =
			 sub.secondary_inventory_name
                     AND item.inventory_item_id = c1rec.CII
                     AND sub.secondary_inventory_name = c1rec.SS
                     AND sub.organization_id = c1rec.OI
                     AND nvl(sub.disable_date,TRUNC(c1rec.EDD)+1) >
                         TRUNC(c1rec.EDD)
                     AND sub.quantity_tracked = 1;
               EXCEPTION
                  WHEN no_data_found THEN
                     RAISE write_subinv_error;
               END;
            ELSE
               stmt_num := 21;
               BEGIN
                  SELECT locator_type
                    INTO sub_loc_code
                    FROM mtl_secondary_inventories sub,
                         mtl_item_sub_inventories item
                   WHERE item.organization_id = sub.organization_id
                     AND item.secondary_inventory =
			 sub.secondary_inventory_name
                     AND item.inventory_item_id = c1rec.CII
                     AND sub.secondary_inventory_name = c1rec.SS
                     AND sub.organization_id = c1rec.OI
                     AND nvl(sub.disable_date,TRUNC(c1rec.EDD)+1) >
                         TRUNC(c1rec.EDD)
                     AND sub.quantity_tracked = 1
                     AND ((inv_asst = 'Y' and sub.asset_inventory = 1)
                          or
                          (inv_asst = 'N'));
               EXCEPTION
                  WHEN no_data_found THEN
                     RAISE write_subinv_error;
               END;
            END IF;
         END IF;
/*
** Validate locator
*/
/* Org level */
         stmt_num := 22;
         SELECT stock_locator_control_code
           INTO org_loc
           FROM mtl_parameters
          WHERE organization_id = c1rec.OI;

         IF (org_loc = 1) and (c1rec.SLI is not null) THEN
            RAISE write_loc_error;
         END IF;

         IF ((org_loc = 2) or (org_loc = 3))and (c1rec.SLI is null) THEN
            RAISE write_loc_error;
         END IF;

         IF ((org_loc = 2) or (org_loc = 3)) and (c1rec.SLI is not null) THEN
            IF (r_loc = 2) THEN    /* non-restricted locator */
               stmt_num := 23;
               BEGIN
                  SELECT 'loc exists'
                    INTO dummy
                    FROM mtl_item_locations
                   WHERE inventory_location_id = c1rec.SLI
                     AND organization_id = c1rec.OI
                     AND subinventory_code = c1rec.SS
                     AND nvl(disable_date,trunc(c1rec.EDD)+1) >
		         trunc(c1rec.EDD);
               EXCEPTION
                  WHEN no_data_found THEN
                     RAISE write_loc_error;
               END;
            ELSE                   /* restricted locator */
               stmt_num := 24;
               BEGIN
                  SELECT 'restricted loc exists'
                    INTO dummy
                    FROM mtl_item_locations loc,
                         mtl_secondary_locators item
                   WHERE loc.inventory_location_id = c1rec.SLI
                     AND loc.organization_id = c1rec.OI
                     AND loc.subinventory_code = c1rec.SS
                     AND nvl(loc.disable_date,trunc(c1rec.EDD)+1) >
                         trunc(c1rec.EDD)
                     AND loc.inventory_location_id = item.secondary_locator
                     AND loc.organization_id = item.organization_id
                     AND item.inventory_item_id = c1rec.CII;
               EXCEPTION
                  WHEN no_data_found THEN
                     RAISE write_loc_error;
               END;
            END IF;
         END IF;

         IF (org_loc not in (1,2,3,4) and c1rec.SLI is not null) THEN
            RAISE write_loc_error;
         END IF;

/* Subinv level */
         IF (org_loc = 4 and sub_loc_code = 1 and c1rec.SLI is not null) THEN
            RAISE write_loc_error;
         END IF;

         stmt_num := 25;
         IF (org_loc = 4) THEN
            IF ((sub_loc_code = 2) or (sub_loc_code = 3))
               and (c1rec.SLI is null) THEN
               RAISE write_loc_error;
            END IF;

            IF ((sub_loc_code = 2) or (sub_loc_code = 3))
               and (c1rec.SLI is not null) THEN
               /* non-restricted locator */
               IF (r_loc = 2) THEN
                  BEGIN
                     SELECT 'loc exists'
                       INTO dummy
                       FROM mtl_item_locations
                      WHERE inventory_location_id = c1rec.SLI
                        AND organization_id = c1rec.OI
                        AND subinventory_code = c1rec.SS
                        AND nvl(disable_date,trunc(c1rec.EDD)+1) >
                               trunc(c1rec.EDD);
                  EXCEPTION
                     WHEN no_data_found THEN
                        RAISE write_loc_error;
                  END;
               /* restricted locator */
               ELSE
                  stmt_num := 26;
                  BEGIN
                     SELECT 'restricted loc exists'
                       INTO dummy
                       FROM mtl_item_locations loc,
                            mtl_secondary_locators item
                      WHERE loc.inventory_location_id = c1rec.SLI
                        AND loc.organization_id = c1rec.OI
                        AND loc.subinventory_code = c1rec.SS
                        AND nvl(loc.disable_date,trunc(c1rec.EDD)+1) >
                             trunc(c1rec.EDD)
                        AND loc.inventory_location_id = item.secondary_locator
                        AND loc.organization_id = item.organization_id
                        AND item.inventory_item_id = c1rec.CII;
                  EXCEPTION
                     WHEN no_data_found THEN
                        RAISE write_loc_error;
                  END;
               END IF;
            END IF;

            IF (sub_loc_code not in (1,2,3,5) and c1rec.SLI is not null) THEN
               RAISE write_loc_error;
            END IF;
         END IF;

/*
** Item level
*/
         stmt_num := 27;
         IF (org_loc = 4 and sub_loc_code = 5 and loc_ctl = 1
          and c1rec.SLI is not null) THEN
            RAISE write_loc_error;
         END IF;

         IF (org_loc = 4 and sub_loc_code = 5) THEN
            IF ((loc_ctl = 2) or (loc_ctl = 3))
               and (c1rec.SLI is null) THEN
               RAISE write_loc_error;
            END IF;

            IF ((loc_ctl = 2) or (loc_ctl = 3))
               and (c1rec.SLI is not null) THEN
               /* non-restricted locator */
               IF (r_loc = 2) THEN
                  BEGIN
                     SELECT 'loc exists'
                       INTO dummy
                       FROM mtl_item_locations
                      WHERE inventory_location_id = c1rec.SLI
                        AND organization_id = c1rec.OI
                        AND subinventory_code = c1rec.SS
                        AND nvl(disable_date,trunc(c1rec.EDD)+1) >
                                  trunc(c1rec.EDD);
                  EXCEPTION
                     WHEN no_data_found THEN
                        RAISE write_loc_error;
                  END;
               ELSE
                  /* restricted locator */
                  stmt_num := 28;
                  BEGIN
                     SELECT 'restricted loc exists'
                       INTO dummy
                       FROM mtl_item_locations loc,
                            mtl_secondary_locators item
                      WHERE loc.inventory_location_id = c1rec.SLI
                        AND loc.organization_id = c1rec.OI
                        AND loc.subinventory_code = c1rec.SS
                        AND nvl(loc.disable_date,trunc(c1rec.EDD)+1) >
                                trunc(c1rec.EDD)
                        AND loc.inventory_location_id = item.secondary_locator
                        AND loc.organization_id = item.organization_id
                        AND item.inventory_item_id = c1rec.CII;
                  EXCEPTION
                     WHEN no_data_found THEN
                        RAISE write_loc_error;
                  END;
               END IF;
            END IF;

            IF (loc_ctl not in (1,2,3) and c1rec.SLI is not null) THEN
               RAISE write_loc_error;
            END IF;
         END IF;

         RAISE update_comp;

         IF (mod(c1%rowcount, G_rows_to_commit) = 0) THEN
            COMMIT;
         END IF;

      EXCEPTION
         WHEN Write_Loc_Error THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_LOCATOR_INVALID',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;

         WHEN Write_Subinv_Error THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_INVENTORY_COMPS_INTERFACE',
                        msg_name => 'BOM_SUBINV_INVALID',
                        err_text => err_text);
            UPDATE bom_inventory_comps_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RAISE ret_code_error;
            END IF;

         WHEN Update_Comp THEN
            stmt_num := 29;
            UPDATE bom_inventory_comps_interface
               SET process_flag = 4
             WHERE transaction_id = c1rec.TI;

         WHEN Continue_Loop THEN
            IF (mod(c1%rowcount, G_rows_to_commit) = 0) THEN
               COMMIT;
            END IF;

      END; -- each component

   END LOOP; -- cursor


   RETURN(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Component_Api(Validate-'||stmt_num||') '||substrb(SQLERRM,1,500);
      RETURN(SQLCODE);
END Validate_Component;


/* -------------------------- Transact_Component --------------------------*/
/*
NAME
     Transact_Component
DESCRIPTION
     Insert, update and delete component data from the interface
     table, BOM_INVENTORY_COMPS_INTERFACE, into the production table,
     BOM_INVENTORY_COMPONENTS.
REQUIRES
     prog_appid              Program application id
     prog_id                 Program id
     req_id                  Request id
     user_id                 User id
     login_id                Login id
MODIFIES
     BOM_INVENTORY_COMPONENTS
     BOM_INVENTORY_COMPS_INTERFACE
RETURNS
     0 if successful
     SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Transact_Component
(       user_id                 NUMBER,
        login_id                NUMBER,
	prog_appid              NUMBER,
 	prog_id                 NUMBER,
        req_id                  NUMBER,
        err_text    OUT NOCOPY  VARCHAR2)
   return integer
IS
   stmt_num                     NUMBER := 0;
   continue_loop                BOOLEAN := TRUE;
   commit_cnt                   NUMBER;
   X_comp_group_name            VARCHAR2(10);
   X_comp_group_description     VARCHAR2(240);
   X_delete_group_seq_id        NUMBER;
   X_new_group_seq_id           NUMBER;
   X_delete_type		NUMBER;
   X_error_message		VARCHAR2(240);
   l_members_still_exist	VARCHAR2(10);
/*
** Select "CREATE" product family member and component records
*/
   CURSOR c0 IS
      SELECT bic.operation_seq_num OSN, bic.component_item_id CII,
	     bic.last_update_date LUD, bic.organization_id OI,
             bic.last_updated_by LUB, bic.creation_date CD, bic.created_by CB,
	     bic.last_update_login LUL,
             bic.item_num INUM, bic.component_quantity CQ,
	     bic.component_yield_factor CYF,
             bic.component_remarks CR, bic.effectivity_date ED,
	     bic.change_notice CN,
             bic.implementation_date ID, bic.disable_date DD,
	     bic.attribute_category AC,
             bic.attribute1 A1, bic.attribute2 A2, bic.attribute3 A3,
	     bic.attribute4 A4,
	     bic.attribute5 A5,
             bic.attribute6 A6, bic.attribute7 A7, bic.attribute8 A8,
	     bic.attribute9 A9,
	     bic.attribute10 A10,
             bic.attribute11 A11, bic.attribute12 A12, bic.attribute13 A13,
	     bic.attribute14 A14, bic.attribute15 A15,
             bic.planning_factor PF, bic.quantity_related QR, bic.so_basis SB,
	     bic.optional O,
             bic.mutually_exclusive_options MEO,
	     bic.include_in_cost_rollup ICR,
	     bic.check_atp CA,
             bic.shipping_allowed SA, bic.required_to_ship RTS,
	     bic.required_for_revenue RFR,
             bic.include_on_ship_docs ISD, bic.low_quantity LQ,
	     bic.high_quantity HQ,
             bic.component_sequence_id CSI, bic.bill_sequence_id BSI,
	     bic.request_id RI,
             bic.program_application_id PAI, bic.program_id PI,
	     bic.program_update_date PUD,
             bic.wip_supply_type WST, bic.supply_locator_id SLI,
	     bic.supply_subinventory SS, bic.transaction_id TI,
             msi2.bom_item_type BIT, msi1.bom_item_type CBIT,
	     bom.assembly_item_id AII,
             bic.operation_lead_time_percent OLTP     --1851537
        FROM
	     bom_bill_of_materials bom,
 	     mtl_system_items msi1,
	     mtl_system_items msi2,
             bom_inventory_comps_interface bic
       WHERE bic.process_flag = 4
         AND bic.transaction_type = G_Insert
         AND rownum < G_rows_to_commit
          AND (UPPER(bic.interface_entity_type) = 'BILL'
	       OR bic.interface_entity_type is null)
	 AND bic.bill_sequence_id = bom.bill_sequence_id
	 AND bom.assembly_item_id = msi2.inventory_item_id
	 AND bom.organization_id = msi2.organization_id
	 AND bic.component_item_id = msi1.inventory_item_id
	 AND bom.organization_id = msi1.organization_id;
/*
** Select "Update" component records
*/
   CURSOR c1 IS
      SELECT component_sequence_id CSI, last_update_date LUD,
	     last_updated_by LUB, last_update_login LUL,
             operation_seq_num OSN,
             operation_lead_time_percent OLTP,   -- For bug 1804509
             item_num INUM, component_quantity CQ,
             component_yield_factor CYF, component_remarks CR,
             effectivity_date ED, implementation_date ID, disable_date DD,
             planning_factor PF, quantity_related QR, so_basis SB,
             optional O, mutually_exclusive_options MEO,
             include_in_cost_rollup IICR, check_atp CA, required_to_ship RTS,
             required_for_revenue RFR, include_on_ship_docs IOSD,
             low_quantity LQ, high_quantity HQ, wip_supply_type WST,
             supply_subinventory SS, supply_locator_id SLI,
             attribute_category AC, attribute1 A1, attribute2 A2,
             attribute3 A3, attribute4 A4, attribute5 A5, attribute6 A6,
             attribute7 A7, attribute8 A8, attribute9 A9, attribute10 A10,
             attribute11 A11, attribute12 A12, attribute13 A13,
             attribute14 A14, attribute15 A15, request_id RI,
             program_application_id PAI, program_id PI,
             program_update_date PUD, transaction_id TI
        FROM bom_inventory_comps_interface
       WHERE process_flag = 4
         AND transaction_type = G_UPDATE
          AND (UPPER(interface_entity_type) = 'BILL'
	       OR interface_entity_type is null)
         AND rownum < G_rows_to_commit;
/*
** Select "Delete" component records
*/
   CURSOR c2 IS
      SELECT bic.bill_sequence_id BSI, bic.assembly_type AST,
	     bic.organization_id OI,
             bic.assembly_item_id AII, bic.alternate_bom_designator ABD,
             bic.component_sequence_id CSI, bic.transaction_id TI,
	     msi.bom_item_type BIT, msic.bom_item_type BITC,
	     bic.component_item_id CII
        FROM mtl_system_items msi,
	     mtl_system_items msic,
	     bom_inventory_comps_interface bic
       WHERE bic.process_flag = 4
         AND bic.transaction_type = G_DELETE
          AND (UPPER(bic.interface_entity_type) = 'BILL'
	       OR bic.interface_entity_type is null)
	 AND msi.organization_id = bic.organization_id
	 AND msi.inventory_item_id = bic.assembly_item_id
	 AND msic.organization_id = bic.organization_id
	 AND msic.inventory_item_id = bic.component_item_id
         AND rownum < G_rows_to_commit;

BEGIN
/*
** Insert Components
*/
   stmt_num := 20;
   continue_loop := TRUE;
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c0rec IN c0 LOOP
         commit_cnt := commit_cnt + 1;
         INSERT INTO bom_inventory_components
                        (
                        OPERATION_SEQ_NUM,
                        COMPONENT_ITEM_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        ITEM_NUM,
                        COMPONENT_QUANTITY,
                        COMPONENT_YIELD_FACTOR,
                        COMPONENT_REMARKS,
                        EFFECTIVITY_DATE,
			CHANGE_NOTICE,
                        IMPLEMENTATION_DATE,
                        DISABLE_DATE,
                        ATTRIBUTE_CATEGORY,
                        OPERATION_LEAD_TIME_PERCENT,      --1851537
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        PLANNING_FACTOR,
                        QUANTITY_RELATED,
                        SO_BASIS,
                        OPTIONAL,
                        MUTUALLY_EXCLUSIVE_OPTIONS,
                        INCLUDE_IN_COST_ROLLUP,
                        CHECK_ATP,
                        SHIPPING_ALLOWED,
                        REQUIRED_TO_SHIP,
                        REQUIRED_FOR_REVENUE,
                        INCLUDE_ON_SHIP_DOCS,
                        LOW_QUANTITY,
                        HIGH_QUANTITY,
                        COMPONENT_SEQUENCE_ID,
                        BILL_SEQUENCE_ID,
                        REQUEST_ID,
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE,
                        WIP_SUPPLY_TYPE,
                        SUPPLY_LOCATOR_ID,
                        SUPPLY_SUBINVENTORY,
                        BOM_ITEM_TYPE
                        )
                 VALUES(
                        c0rec.OSN,
                        c0rec.CII,
                        c0rec.LUD,
                        c0rec.LUB,
                        c0rec.CD,
                        c0rec.CB,
                        c0rec.LUL,
                        c0rec.INUM,
                        c0rec.CQ,
                        c0rec.CYF,
                        c0rec.CR,
                        c0rec.ED,
                        c0rec.CN,
                        c0rec.ID,
                        c0rec.DD,
                        c0rec.AC,
                        c0rec.OLTP,       --1851537
                        c0rec.A1,
                        c0rec.A2,
                        c0rec.A3,
                        c0rec.A4,
                        c0rec.A5,
                        c0rec.A6,
                        c0rec.A7,
                        c0rec.A8,
                        c0rec.A9,
                        c0rec.A10,
                        c0rec.A11,
                        c0rec.A12,
                        c0rec.A13,
                        c0rec.A14,
                        c0rec.A15,
                        c0rec.PF,
                        c0rec.QR,
                        c0rec.SB,
                        c0rec.O,
                        c0rec.MEO,
                        c0rec.ICR,
                        c0rec.CA,
                        c0rec.SA,
                        c0rec.RTS,
                        c0rec.RFR,
                        c0rec.ISD,
                        c0rec.LQ,
                        c0rec.HQ,
                        c0rec.CSI,
                        c0rec.BSI,
                        c0rec.RI,
                        c0rec.PAI,
                        c0rec.PI,
                        c0rec.PUD,
                        c0rec.WST,
                        c0rec.SLI,
                        c0rec.SS,
                        c0rec.CBIT);
/*
** If product family member is added, need to update PRODUCT_FAMILY_ID
** in mtl_system_items.
*/
         IF (c0rec.BIT = G_ProductFamily) THEN
            BEGIN
               UPDATE mtl_system_items
                  SET product_family_item_id = c0rec.AII
                WHERE inventory_item_id = c0rec.CII
                  AND organization_id  = c0rec.OI;
	    END;
         END IF;

         UPDATE bom_inventory_comps_interface
            SET process_flag = 7
          WHERE transaction_id = c0rec.TI;
      END LOOP;

      stmt_num := 65;
      COMMIT;
      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;
   END LOOP;

/*
** Update Components
*/
   stmt_num := 63;
   continue_loop := TRUE;
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c1rec IN c1 LOOP
         commit_cnt := commit_cnt + 1;
         UPDATE bom_inventory_components
            SET last_update_date           = c1rec.LUD,
                last_updated_by            = c1rec.LUB,
                last_update_login          = c1rec.LUL,
                operation_seq_num          = c1rec.OSN,
                operation_lead_time_percent = c1rec.OLTP,   -- For bug 1804509
                item_num                   = c1rec.INUM,
                component_quantity         = c1rec.CQ,
                component_yield_factor     = c1rec.CYF,
                component_remarks          = c1rec.CR,
                effectivity_date           = c1rec.ED,
                implementation_date        = c1rec.ID,
                disable_date               = c1rec.DD,
                planning_factor            = c1rec.PF,
                quantity_related           = c1rec.QR,
                so_basis                   = c1rec.SB,
                optional                   = c1rec.O,
                mutually_exclusive_options = c1rec.MEO,
                include_in_cost_rollup     = c1rec.IICR,
                check_atp                  = c1rec.CA,
                required_to_ship           = c1rec.RTS,
                required_for_revenue       = c1rec.RFR,
                include_on_ship_docs       = c1rec.IOSD,
                low_quantity               = c1rec.LQ,
                high_quantity              = c1rec.HQ,
                wip_supply_type            = c1rec.WST,
                supply_subinventory        = c1rec.SS,
                supply_locator_id          = c1rec.SLI,
                attribute_category         = c1rec.AC,
                attribute1                 = c1rec.A1,
                attribute2                 = c1rec.A2,
                attribute3                 = c1rec.A3,
                attribute4                 = c1rec.A4,
                attribute5                 = c1rec.A5,
                attribute6                 = c1rec.A6,
                attribute7                 = c1rec.A7,
                attribute8                 = c1rec.A8,
                attribute9                 = c1rec.A9,
                attribute10                = c1rec.A10,
                attribute11                = c1rec.A11,
                attribute12                = c1rec.A12,
                attribute13                = c1rec.A13,
                attribute14                = c1rec.A14,
                attribute15                = c1rec.A15,
                request_id                 = c1rec.RI,
                program_application_id     = c1rec.PAI,
                program_id                 = c1rec.PI,
                program_update_date        = c1rec.PUD
          WHERE component_sequence_id = c1rec.CSI;

         stmt_num := 64;
         UPDATE bom_inventory_comps_interface
            SET process_flag = 7
          WHERE transaction_id = c1rec.TI;
      END LOOP;

      stmt_num := 65;
      COMMIT;
      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;

   END LOOP;
/*
** Delete Components
*/
   stmt_num := 33;
   continue_loop := TRUE;

   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c2rec IN c2 LOOP
         commit_cnt := commit_cnt + 1;
         IF (c2rec.BIT = G_ProductFamily) THEN
/*
** For Members, delete specific Allocation record.
** Also null out product family id in item master if
** this member has no more Allocations for this Product Family.
*/
            DELETE FROM bom_inventory_components
             WHERE component_sequence_id = c2rec.CSI;

	    BEGIN
   	       SELECT 'yes'
	         INTO l_members_still_exist
	         FROM bom_inventory_components
	        WHERE bill_sequence_id = c2rec.BSI
	          AND component_item_id = c2rec.CII
		  AND rownum = 1;
	    EXCEPTION
	       WHEN no_data_found THEN
                  UPDATE mtl_system_items
                     SET product_family_item_id = null
                   WHERE inventory_item_id = c2rec.CII
                     AND organization_id  = c2rec.OI;
	    END;

         ELSE
/*
** Get the Component Delete Group name
*/
            IF (X_comp_group_name is null) THEN
               DECLARE
                  CURSOR GetCompGroup IS
                     SELECT delete_group_name, description
                       FROM bom_interface_delete_groups
                      WHERE UPPER(entity_name) = G_DeleteEntity;
                  BEGIN
                     FOR X_compgroup IN GetCompGroup LOOP
                        X_comp_group_name := X_compgroup.delete_group_name;
                        X_comp_group_description := X_compgroup.description;
                     END LOOP;

                     IF (X_comp_group_name is null) THEN
			X_error_message := FND_MESSAGE.Get_String('BOM',
					   'BOM_COMP_DELETE_GROUP_MISSING');
                        err_text := 'Bom_Component_Api:'||to_char(stmt_num)||
                                           '- '||X_error_message;
                        RETURN(-9999);
                     END IF;
                  END;
            END IF;

            X_delete_group_seq_id := null;
            BEGIN
               SELECT delete_group_sequence_id, delete_type
                 INTO X_delete_group_seq_id, X_delete_type
                 FROM bom_delete_groups
                WHERE delete_group_name = X_comp_group_name
                  AND organization_id = c2rec.OI;

               IF (X_delete_type <> 4) THEN
                  X_error_message := FND_MESSAGE.Get_String('BOM',
				     'BOM_DELETE_GROUP_INVALID');
                  err_text := 'Bom_Component_Api('||to_char(stmt_num)||
                            ') - '||X_error_message;
                  RETURN(-9999);
               END IF;

            EXCEPTION
               WHEN no_data_found THEN
                  null;
            END;

            X_new_group_seq_id := Modal_Delete.Delete_Manager_Oi(
               new_group_seq_id => X_delete_group_seq_id,
               name => X_comp_group_name,
               group_desc => X_comp_group_description,
               org_id => c2rec.OI,
               bom_or_eng => c2rec.AST,
               del_type => 4,
               ent_bill_seq_id => c2rec.BSI,
               ent_rtg_seq_id => null,
               ent_inv_item_id => c2rec.AII,
               ent_alt_designator => c2rec.ABD,
               ent_comp_seq_id => c2rec.CSI,
               ent_op_seq_id => null,
               user_id => user_id,
      	       err_text => err_text);
         END IF; -- Check if Member or Component

         stmt_num := 34;
         UPDATE bom_inventory_comps_interface
            SET process_flag = 7
          WHERE transaction_id = c2rec.TI;
      END LOOP;

      stmt_num := 35;
      COMMIT;
      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;

   END LOOP;

   RETURN(0);

EXCEPTION
   WHEN no_data_found THEN
      RETURN(0);
   WHEN OTHERS THEN
      ROLLBACK;
      err_text := 'Bom_Component_Api(Transact-'||stmt_num||') '||substrb(SQLERRM,1,500);
      return(SQLCODE);

END Transact_Component;

/* ----------------------------- Import_Component -------------------------- */
/*
NAME
    Import_Component
DESCRIPTION
    Assign, Validate, and Transact the Component record in the
    interface table, BOM_INVENTORY_COMPS_INTERFACE.
REQUIRES
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Import_Component (
    org_id              NUMBER,
    all_org             NUMBER := 1,
    user_id             NUMBER := -1,
    login_id            NUMBER := -1,
    prog_appid          NUMBER := -1,
    prog_id             NUMBER := -1,
    req_id              NUMBER := -1,
    del_rec_flag	NUMBER := 1,
    err_text    IN OUT NOCOPY VARCHAR2
)
    return INTEGER
IS
   err_msg	VARCHAR2(2000);
   ret_code     NUMBER := 1;
   stmt_num	NUMBER := 0;
BEGIN
   stmt_num := 1;
   ret_code := Assign_Component (
      org_id => org_id,
      all_org => all_org,
      user_id => user_id,
      login_id => login_id,
      prog_appid => prog_appid,
      prog_id => prog_id,
      req_id => req_id,
      err_text => err_msg);
   IF (ret_code <> 0) THEN
      err_text := 'Assign_Component '||substrb(err_msg, 1,1500);
      ROLLBACK;
      RETURN(ret_code);
   END IF;
   COMMIT;

   stmt_num := 2;
   ret_code := Validate_Component (
      org_id => org_id,
      all_org => all_org,
      user_id => user_id,
      login_id => login_id,
      prog_appid => prog_appid,
      prog_id => prog_id,
      req_id => req_id,
      err_text => err_msg);
   IF (ret_code <> 0) THEN
      err_text := 'Validate_Component '||substrb(err_msg, 1,1500);
      ROLLBACK;
      RETURN(ret_code);
   END IF;
   COMMIT;

   stmt_num := 3;
   ret_code := Transact_Component (
      user_id => user_id,
      login_id => login_id,
      prog_appid => prog_appid,
      prog_id => prog_id,
      req_id => req_id,
      err_text => err_msg);

   IF (ret_code <> 0) THEN
      err_text := 'Transact_Component '||substrb(err_msg, 1,1500);
      ROLLBACK;
      RETURN(ret_code);
   END IF;
   COMMIT;

   stmt_num := 4;
   IF (del_rec_flag = 1) THEN
      LOOP
         DELETE from bom_inventory_comps_interface
          WHERE process_flag = 7
            AND (UPPER(interface_entity_type) = 'BILL'
	       OR interface_entity_type is null)
            AND rownum < G_rows_to_commit;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;
   END IF;

   RETURN(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Component_Api(Import-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(ret_code);
END Import_Component;


END Bom_Component_Api;

/
