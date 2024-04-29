--------------------------------------------------------
--  DDL for Package Body GMP_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_UTILITY" as
/* $Header: GMPUTILB.pls 120.0.12010000.2 2009/02/23 17:12:20 rpatangy ship $ */

PROCEDURE generate_opm_acct
(
 V_DESTINATION_TYPE    IN      VARCHAR2 ,
 V_INV_ITEM_TYPE       IN      VARCHAR2 ,
 V_SUBINV_TYPE         IN      VARCHAR2,
 V_DEST_ORG_ID         IN      NUMBER ,
 V_APPS_ITEM_ID        IN      NUMBER,
 V_VENDOR_SITE_ID      IN      NUMBER,
 V_CC_ID               IN OUT NOCOPY NUMBER
) IS

 P_DESTINATION_TYPE    VARCHAR2(20) := NULL ;
 P_INV_ITEM_TYPE       VARCHAR2(20) := NULL ;
 P_SUBINV_TYPE         VARCHAR2(20) := NULL ;
 P_DEST_ORG_ID         NUMBER   := 0 ;
 P_APPS_ITEM_ID        NUMBER   := 0 ;
 P_VENDOR_SITE_ID      NUMBER   := 0 ;
 P_CC_ID               NUMBER   := 0 ;

BEGIN
     P_DESTINATION_TYPE := V_DESTINATION_TYPE ;
     P_INV_ITEM_TYPE    := V_INV_ITEM_TYPE ;
     P_SUBINV_TYPE      := V_SUBINV_TYPE ;
     P_DEST_ORG_ID      := V_DEST_ORG_ID ;
     P_APPS_ITEM_ID     := V_APPS_ITEM_ID ;
     P_VENDOR_SITE_ID   := V_VENDOR_SITE_ID ;

     /* Actual call to routine to return the account Id's */

     GML_ACCT_GENERATE.generate_opm_acct(P_DESTINATION_TYPE,
                                         P_INV_ITEM_TYPE,
                                         P_SUBINV_TYPE,
                                         P_DEST_ORG_ID,
                                         P_APPS_ITEM_ID,
                                         P_VENDOR_SITE_ID,
                                         P_CC_ID ) ;

     V_CC_ID := P_CC_ID ;

END generate_opm_acct ;

FUNCTION populate_eff
( org_string           IN      VARCHAR2
) RETURN BOOLEAN IS
 SQL_STMT       VARCHAR2(32000) := NULL ;
 RESULT BOOLEAN := TRUE;
 PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
SQL_STMT := 'INSERT INTO gmp_form_eff( aps_fmeff_id, fmeff_id, '
   ||' organization_id,  formula_id, routing_id, '
   ||' creation_date, created_by, last_update_date,  last_updated_by) '
   ||' ( SELECT (rownum + gmp.aps_id) aps_fmeff_id, '
   ||' eff.recipe_validity_rule_id, eff.organization_id, '
   ||' eff.formula_id, '
   ||' eff.routing_id , sysdate , -2 , sysdate , -2 '
   ||'FROM ( '
   ||' SELECT ffe.recipe_validity_rule_id, ffe.inventory_item_id, '
   ||' grb.formula_id, ffe.organization_id, '
   ||' ffe.start_date, ffe.end_date, ffe.inv_min_qty, '
   ||' ffe.inv_max_qty, ffe.preference, msi.primary_uom_code, '
   ||' mp.organization_code wcode , grb.routing_id, '
   ||' frh.routing_no, frh.routing_vers, frh.routing_desc, '
   ||'  frh.routing_uom, frh.routing_qty, '
   ||' DECODE(frh.routing_uom,msi.primary_uom_code ,1, '
   ||'        inv_convert.inv_um_convert '
   ||'                 ( ffe.inventory_item_id, '
   ||'                   NULL, '
   ||'                   ffe.organization_id, '
   ||'                   5   , '
   ||'                   1, '
   ||'                   msi.primary_uom_code ,  '  /* primary */
   ||'                   frh.routing_uom , '   /* routing um */
   ||'                   NULL , '
   ||'                   NULL '
   ||'                 ) '
   ||'         ) prd_fct, -1 prd_ind, '
   ||' grb.recipe_id, grb.recipe_no, grb.recipe_version , '
   ||' 0 rhdr_loc, '
   ||' grb.calculate_step_quantity '
   ||' FROM  gmd_recipes_b grb, '
   ||'       gmd_recipe_validity_rules ffe,  '
   ||'       fm_form_mst ffm, '
   ||'       fm_rout_hdr frh, '
   ||'       mtl_parameters mp, '
   ||'       mtl_system_items msi, '
   ||'       hr_organization_units hou, '
   ||'       gmd_status_b gs1,'
   ||'       gmd_status_b gs2, '
   ||'       gmd_status_b gs3, '
   ||'       gmd_status_b gs4 '
   ||' WHERE grb.delete_mark = 0 '
   ||'   AND grb.recipe_id = ffe.recipe_id '
   ||'   AND grb.recipe_status = gs1.status_code '
   ||'   AND gs1.status_type IN (''700'' ,''900'' ,''400'' ) '
   ||'   AND gs1.delete_mark = 0 '
   ||'   AND ffe.delete_mark = 0 '
   ||'   AND ffe.validity_rule_status = gs2.status_code '
   ||'   AND gs2.status_type IN (''700'' ,''900'' ,''400'' ) '
   ||'   AND gs2.delete_mark = 0 '
   ||'   AND frh.delete_mark = 0 '
   ||'   AND ffm.delete_mark = 0 '
   ||'   AND nvl(hou.date_to,SYSDATE) >= SYSDATE '
   ||'   AND hou.organization_id = mp.organization_id '
   ||'   AND frh.inactive_ind = 0 '
   ||'   AND ffm.inactive_ind = 0 '
   ||'   AND grb.routing_id IS NOT NULL '
   ||'   AND ffe.organization_id IS NOT NULL '
   ||'   AND ffe.recipe_use IN (0,1) '
   ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
   ||'   AND ffe.organization_id = mp.organization_id  '
   ||'   AND grb.formula_id = ffm.formula_id '
   ||'   AND ffm.formula_status = gs3.status_code '
   ||'   AND gs3.status_type IN (''700'' ,''900'' ,''400'' ) '
   ||'   AND gs3.delete_mark = 0 '
   ||'   AND grb.routing_id =  frh.routing_id '
   ||'   AND frh.routing_status =  gs4.status_code '
   ||'   AND gs4.status_type IN (''700'' ,''900'' ,''400'' ) '
   ||'   AND gs4.delete_mark = 0 '
   ||'   AND msi.organization_id =  ffe.organization_id '
   ||'   AND msi.inventory_item_id =  ffe.inventory_item_id '
   ||'   AND msi.recipe_enabled_flag = ''Y'' '
   ||'   AND msi.process_execution_enabled_flag = ''Y'' '
   ||'   AND mp.process_enabled_flag = ''Y'' '
   ||'   AND EXISTS ( SELECT 1 '
   ||'          FROM  fm_matl_dtl '
   ||'          WHERE formula_id = grb.formula_id '
   ||'          AND line_type = 1 '
   ||'          AND inventory_item_id = msi.inventory_item_id '
   ||'          AND msi.organization_id = ffe.organization_id '
   ||'          AND inventory_item_id = ffe.inventory_item_id ) '
   ||' UNION ALL '
   ||' SELECT ffe.recipe_validity_rule_id, ffe.inventory_item_id, '
   ||' grb.formula_id, ffe.organization_id, '
   ||' ffe.start_date, ffe.end_date, ffe.inv_min_qty, '
   ||' ffe.inv_max_qty, ffe.preference, msi.primary_uom_code, '
   ||' mp.organization_code wcode , to_number(null) , '
   ||' NULL, to_number(null), NULL, '
   ||' NULL, to_number(null), to_number(null) prd_fct, -1 prd_ind, '
   ||' grb.recipe_id, grb.recipe_no, grb.recipe_version , '
   ||' 0 rhdr_loc, '
   ||' 0 calculate_step_quantity '
   ||' FROM  gmd_recipes_b grb, '
   ||'       gmd_recipe_validity_rules ffe, '
    ||'      fm_form_mst ffm, '
   ||'       mtl_parameters mp, '
   ||'       mtl_system_items msi, '
   ||'       hr_organization_units hou, '
   ||'       gmd_status_b gs1, '
   ||'       gmd_status_b gs2, '
   ||'       gmd_status_b gs3 '
   ||' WHERE  grb.delete_mark = 0 '
   ||'   AND grb.recipe_id = ffe.recipe_id '
   ||'   AND grb.recipe_status = gs1.status_code '
   ||'   AND gs1.status_type IN (''700'' ,''900'' ,''400'' ) '
   ||'   AND gs1.delete_mark = 0'
   ||'   AND ffe.delete_mark = 0 '
   ||'   AND ffe.validity_rule_status = gs2.status_code '
   ||'   AND gs2.status_type IN (''700'' ,''900'' ,''400'' ) '
   ||'   AND gs2.delete_mark = 0 '
   ||'   AND ffm.delete_mark = 0 '
   ||'   AND nvl(hou.date_to,SYSDATE) >= SYSDATE '
   ||'   AND hou.organization_id = mp.organization_id '
   ||'   AND ffm.inactive_ind = 0 '
   ||'   AND grb.routing_id IS NULL '
   ||'   AND ffe.organization_id IS NOT NULL '
   ||'   AND ffe.organization_id = mp.organization_id '
   ||'   AND ffe.recipe_use IN (0,1) '
   ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
   ||'   AND grb.formula_id = ffm.formula_id '
   ||'   AND ffm.formula_status = gs3.status_code '
   ||'   AND gs3.status_type IN (''700'' ,''900'' ,''400'' ) '
   ||'   AND gs3.delete_mark = 0  '
   ||'   AND msi.organization_id =  ffe.organization_id '
   ||'   AND msi.inventory_item_id =  ffe.inventory_item_id '
   ||'   AND msi.recipe_enabled_flag = ''Y'' '
   ||'   AND msi.process_execution_enabled_flag = ''Y'' '
   ||'   AND mp.process_enabled_flag = ''Y'' '
   ||'   AND EXISTS ( SELECT 1 '
   ||'          FROM  fm_matl_dtl  '
   ||'          WHERE formula_id = grb.formula_id '
   ||'          AND line_type = 1 '
   ||'          AND inventory_item_id = msi.inventory_item_id '
   ||'          AND msi.organization_id = ffe.organization_id '
   ||'          AND inventory_item_id = ffe.inventory_item_id ) '
   ||' UNION ALL '
   ||' SELECT ffe.recipe_validity_rule_id, ffe.inventory_item_id, '
   ||' grb.formula_id, msi.organization_id, '
   ||' ffe.start_date, ffe.end_date, ffe.inv_min_qty, '
   ||' ffe.inv_max_qty, ffe.preference, msi.primary_uom_code, '
   ||' mp.organization_code wcode , grb.routing_id, '
   ||' frh.routing_no, frh.routing_vers, frh.routing_desc, '
   ||' frh.routing_uom, frh.routing_qty, ' /*B2870041*/
   ||' DECODE(frh.routing_uom,msi.primary_uom_code ,1, '
   ||'        inv_convert.inv_um_convert '
   ||'                 (ffe.inventory_item_id, '
   ||'                  NULL, '
   ||'                  msi.organization_id, '
   ||'                   5  , '
   ||'                  1, '
   ||'                  msi.primary_uom_code , '   /* primary */
   ||'                  frh.routing_uom , '   /* routing um */
   ||'                  NULL , '
   ||'                  NULL '
   ||'                 ) '
   ||'         ) prd_fct, -1 prd_ind, '
   ||' grb.recipe_id, grb.recipe_no, grb.recipe_version , '
   ||' 0 rhdr_loc,  '
   ||' grb.calculate_step_quantity '
   ||' FROM  gmd_recipes_b grb, '
   ||'       gmd_recipe_validity_rules ffe, '
   ||'       fm_form_mst ffm, '
   ||'       fm_rout_hdr frh, '
   ||'       mtl_parameters mp, '
   ||'       mtl_system_items msi, '
   ||'       hr_organization_units hou, '
   ||'       gmd_status_b gs1, '
   ||'       gmd_status_b gs2, '
    ||'      gmd_status_b gs3, '
   ||'       gmd_status_b gs4 '
   ||' WHERE grb.delete_mark = 0 '
   ||'   AND grb.recipe_id = ffe.recipe_id '
   ||'   AND grb.recipe_status = gs1.status_code '
   ||'   AND gs1.status_type IN (''700'' ,''900'' ,''400'' ) '
   ||'   AND gs1.delete_mark = 0 '
   ||'   AND ffe.delete_mark = 0 '
   ||'   AND ffe.validity_rule_status = gs2.status_code '
    ||'  AND gs2.status_type IN (''700'' ,''900'' ,''400'' ) '
   ||'   AND gs2.delete_mark = 0 '
   ||'   AND frh.delete_mark = 0 '
   ||'   AND ffm.delete_mark = 0 '
   ||'   AND nvl(hou.date_to,SYSDATE) >= SYSDATE '
   ||'   AND hou.organization_id = mp.organization_id '
   ||'   AND frh.inactive_ind = 0 '
   ||'   AND ffm.inactive_ind = 0 '
   ||'   AND grb.routing_id IS NOT NULL '
   ||'   AND ffe.organization_id IS NULL '
   ||'   AND ffe.recipe_use IN (0,1) '
   ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
   ||'   AND grb.formula_id = ffm.formula_id '
   ||'   AND ffm.formula_status = gs3.status_code '
   ||'   AND gs3.status_type IN (''700'' ,''900'' ,''400'' ) '
   ||'   AND gs3.delete_mark = 0 '
   ||'   AND grb.routing_id =  frh.routing_id '
   ||'   AND frh.routing_status =  gs4.status_code '
   ||'   AND gs4.status_type IN (''700'' ,''900'' ,''400'' ) '
   ||'   AND gs4.delete_mark = 0 '
   ||'   AND mp.organization_id = msi.organization_id '
   ||'   AND mp.process_enabled_flag = ''Y'' '
   ||'   AND msi.inventory_item_id =  ffe.inventory_item_id '
   ||'   AND msi.recipe_enabled_flag = ''Y'' '
   ||'   AND msi.process_execution_enabled_flag = ''Y'' '
   ||'   AND EXISTS ( SELECT 1 '
   ||'          FROM  fm_matl_dtl '
   ||'          WHERE formula_id = grb.formula_id '
   ||'          AND line_type = 1 '
   ||'          AND inventory_item_id = msi.inventory_item_id '
   ||'          AND msi.organization_id = nvl(ffe.organization_id,msi.organization_id) '
   ||'          AND inventory_item_id = ffe.inventory_item_id ) '
   ||' UNION ALL '
   ||' SELECT ffe.recipe_validity_rule_id, ffe.inventory_item_id, '
   ||' grb.formula_id, msi.organization_id, '
   ||' ffe.start_date, ffe.end_date, ffe.inv_min_qty, '
   ||' ffe.inv_max_qty, ffe.preference, msi.primary_uom_code, '
   ||' mp.organization_code wcode , to_number(null) , '
   ||' NULL, to_number(null), NULL, '
   ||' NULL, to_number(null), to_number(null) prd_fct, -1 prd_ind, '
   ||' grb.recipe_id, grb.recipe_no, grb.recipe_version , '
   ||' 0 rhdr_loc, '
   ||' 0 calculate_step_quantity '
   ||' FROM  gmd_recipes_b grb, '
   ||'       gmd_recipe_validity_rules ffe, '
   ||'       mtl_parameters mp, '
   ||'       fm_form_mst ffm, '
   ||'       mtl_system_items msi, '
   ||'       hr_organization_units hou, '
   ||'       gmd_status_b gs1, '
   ||'       gmd_status_b gs2, '
   ||'       gmd_status_b gs3 '
   ||' WHERE grb.delete_mark = 0 '
   ||'   AND grb.recipe_id = ffe.recipe_id '
   ||'   AND grb.recipe_status = gs1.status_code '
   ||'   AND gs1.status_type IN (''700'' ,''900'' ,''400'' ) '
   ||'   AND gs1.delete_mark = 0 '
   ||'   AND ffe.delete_mark = 0 '
   ||'   AND ffe.validity_rule_status = gs2.status_code '
   ||'   AND gs2.status_type IN (''700'' ,''900'' ,''400'' ) '
   ||'   AND gs2.delete_mark = 0 '
   ||'   AND ffm.delete_mark = 0 '
   ||'   AND nvl(hou.date_to,SYSDATE) >= SYSDATE '
   ||'   AND hou.organization_id = mp.organization_id '
   ||'   AND ffm.inactive_ind = 0 '
   ||'   AND grb.routing_id IS NULL '
   ||'   AND ffe.organization_id IS NULL  '
   ||'   AND ffe.recipe_use IN (0,1) '
   ||'   AND nvl(ffe.end_date,(SYSDATE + 1)) > SYSDATE '
   ||'   AND grb.formula_id = ffm.formula_id '
    ||'  AND ffm.formula_status = gs3.status_code '
    ||'  AND gs3.status_type IN (''700'' ,''900'' ,''400'' ) '
    ||'  AND gs3.delete_mark = 0 '
    ||'  AND msi.organization_id = mp.organization_id '
   ||'   AND mp.process_enabled_flag = ''Y'' '
   ||'   AND msi.inventory_item_id = ffe.inventory_item_id '
   ||'   AND msi.recipe_enabled_flag = ''Y'' '
   ||'   AND msi.process_execution_enabled_flag = ''Y'' '
   ||'   AND EXISTS ( SELECT 1 '
   ||'          FROM  fm_matl_dtl  '
   ||'          WHERE formula_id = grb.formula_id  '
   ||'          AND line_type = 1  '
   ||'          AND inventory_item_id = msi.inventory_item_id  '
   ||'          AND msi.organization_id = nvl(ffe.organization_id,msi.organization_id)  '
   ||'          AND inventory_item_id = ffe.inventory_item_id )  ) eff ,  '
   ||'          ( select max(aps_fmeff_id) aps_id from gmp_form_eff)  gmp '
   ||'   WHERE NOT EXISTS ( SELECT 1 FROM gmp_form_eff gfe '
   ||'      WHERE organization_id is NOT NULL '
   ||'         AND eff.organization_id = gfe.organization_id '
   ||'         AND eff.recipe_validity_rule_id = gfe.fmeff_id  ) ' ;

IF org_string IS NOT NULL THEN
  SQL_STMT := SQL_STMT
     ||'    and eff.ORGANIZATION_ID '|| org_string ||' ) ';
ELSE
     SQL_STMT := SQL_STMT ||'   ) ' ;
END IF;
  EXECUTE IMMEDIATE SQL_STMT ;
  COMMIT;
  RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
	RETURN FALSE;
END populate_eff ;

end gmp_utility;

/
