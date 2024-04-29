--------------------------------------------------------
--  DDL for Package Body GMP_LEAD_TIME_CALCULATOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_LEAD_TIME_CALCULATOR_PKG" AS
/* $Header: GMPLTCPB.pls 120.6.12010000.3 2009/08/14 13:48:33 vpedarla ship $ */

-- Package Global Variables
TYPE ref_cursor_typ IS REF CURSOR;

TYPE item_eff_typ IS RECORD
(
--item_id    NUMBER, --Sowmya - INVCONV
inventory_item_id  NUMBER,
--item_no     VARCHAR2(32), --Sowmya - INVCONV
item_no     VARCHAR2(40),
eff_qty      NUMBER,
--prim_um    VARCHAR2(4), --Sowmya - INVCONV
prim_um      VARCHAR2(3),
--org_code    VARCHAR2(4), --Sowmya - INVCONV
--mtl_org_id    NUMBER, --Sowmya - INVCONV
org_id            NUMBER,
daily_work_hours   NUMBER,
fmeff_id    NUMBER,
recipe_id    NUMBER,
formula_id    NUMBER,
routing_id    NUMBER,
scale_type              NUMBER,   -- Bug: 8736658
formula_ouput    NUMBER,     -- Bug: 8736658
formula_uom    VARCHAR2(3)   -- Bug: 8736658
) ;
item_eff item_eff_typ ;

-- Rtg dtl
TYPE routing_details_typ IS RECORD
(
routing_id   NUMBER,
routing_no      VARCHAR2(32),
routing_qty  NUMBER,
routing_um  VARCHAR2(4),
routingstep_id  NUMBER(16),
operation_no  VARCHAR2(32),
step_qty  NUMBER,
process_qty_um  VARCHAR2(4),
activity  VARCHAR2(16),
activity_factor NUMBER,
oprnline_id  NUMBER,
Resources  VARCHAR2(16),
process_qty  NUMBER ,
process_uom   VARCHAR2(4),
resource_cnt  NUMBER,
Resource_usage  NUMBER,
usage_um  VARCHAR2(4),
scale_type   NUMBER,
prim_rsrc_ind  NUMBER,
material_ind  NUMBER,
o_step_qty     NUMBER,  -- Bug: 8736658 Vpedarla
o_process_qty NUMBER,  -- Bug: 8736658 Vpedarla
o_resource_usage NUMBER , -- Bug: 8736658 Vpedarla
o_activity_factor  NUMBER  -- Bug: 8736658 Vpedarla
);
TYPE routing_dtl_tbl_typ  IS TABLE OF routing_details_typ
INDEX BY BINARY_INTEGER;
routing_dtl_tbl routing_dtl_tbl_typ ;

TYPE routing_steps_typ IS RECORD
(
routing_id     NUMBER ,
routingstep_id    NUMBER,
f_cum_duration    NUMBER,
v_cum_duration    NUMBER,
cum_duration    NUMBER,
start_offset     NUMBER ,
end_offset     NUMBER
);
TYPE rtg_steps_tbl_typ IS TABLE OF routing_steps_typ
INDEX BY BINARY_INTEGER;
rtg_steps_tbl rtg_steps_tbl_typ ;

UOM_CONVERSION_ERROR EXCEPTION ;
g_rtgdtl_sz     NUMBER := 0 ;
g_stepassn_sz     NUMBER := 0 ;
g_stepassn_locn   NUMBER := 0 ;
g_rtgdtl_loc     NUMBER := 1 ;
g_fmdtl_loc     NUMBER := 1 ;
g_stepassn_loc     NUMBER := 1 ;
g_prev_routing_id   NUMBER := 0;
g_cum_f_duration   NUMBER ;
g_cum_v_duration   NUMBER ;
g_cum_duration     NUMBER ;
g_item_cnt     NUMBER := 0 ;
g_non_rtg_itm_cnt   NUMBER := 0 ;
g_err_cnt     NUMBER := 0 ;
g_user_id    NUMBER := TO_NUMBER(FND_PROFILE.VALUE('USER_ID')) ;
g_curr_time     DATE := SYSDATE ;
g_uom_hr                VARCHAR2(4) := fnd_profile.VALUE('BOM:HOUR_UOM_CODE'); /* B5885931 */

/*B5146342 - to handle mulitple same activities in an oprn and overrides - starts*/
TYPE recipe_orgn_override_typ IS RECORD
(
  routing_id          NUMBER,
  org_id              NUMBER,
  routingstep_id      NUMBER,
  oprn_line_id        NUMBER,
  recipe_id           NUMBER,
  activity_factor     NUMBER,
  resources           VARCHAR2(16),
  resource_usage      NUMBER,
  process_qty         NUMBER
);
TYPE recipe_orgn_override_tbl IS TABLE OF recipe_orgn_override_typ
INDEX BY BINARY_INTEGER;
rcp_orgn_override    recipe_orgn_override_tbl;

TYPE recipe_override_typ IS RECORD
(
  routing_id          NUMBER,
  routingstep_id      NUMBER,
  recipe_id           NUMBER,
  step_qty            NUMBER
);
TYPE recipe_override_tbl IS TABLE OF recipe_override_typ
INDEX BY BINARY_INTEGER;
recipe_override      recipe_override_tbl;

TYPE gmp_routing_step_offsets_typ IS RECORD
(
plant_code      VARCHAR2(4),
fmeff_id        NUMBER,
formula_id      NUMBER,
routingstep_id  NUMBER,
start_offset    NUMBER,
end_offset      NUMBER,
formulaline_id  NUMBER
);
TYPE rtgstep_offsets_tbl IS TABLE OF gmp_routing_step_offsets_typ
INDEX BY BINARY_INTEGER ;
rstep_offsets   rtgstep_offsets_tbl;

recipe_orgn_over_size     INTEGER;  /* No. of rows in recipe orgn override */
recipe_override_size      INTEGER;  /* Number of rows in recipe override */
/*B5146342 - to handle mulitple same activities in an oprn and overrides - ends*/

/*
REM+===========================================================================+
REM|PROCEDURE NAME                                                             |
REM|     calculate_lead_times                                                  |
REM|PARAMETERS                                                                 |
REM|                                                                           |
REM|DESCRIPTION                                                                |
REM|                                                                           |
REM|HISTORY                                                                    |
REM|   06-22-2004 Nisheeth added condition to consider the status.             |
REM|                                                                           |
REM|   B5885931 Rajesh Patangya Resource Usage should be in BOM:HOUR_UOM_CODE  |
REM|                                                                           |
REM|                                                                           |
REM+===========================================================================+*/
PROCEDURE calculate_lead_times(
           errbuf               OUT  NOCOPY VARCHAR2,
           retcode              OUT  NOCOPY VARCHAR2,
           p_from_orgn          NUMBER,
           p_to_orgn            NUMBER,
           p_from_item_id       NUMBER,
           p_to_item_id         NUMBER)
IS

cur_item_eff            ref_cursor_typ ;
cur_routing_dtls        ref_cursor_typ;
c_recipe_override       ref_cursor_typ;
c_recipe_orgn           ref_cursor_typ;
cur_formula_dtls   ref_cursor_typ;
cur_step_assn      ref_cursor_typ;

rtgdtl_sz               NUMBER ;
i                       NUMBER ;
non_rtg_item            NUMBER ;
temp_var                NUMBER ;
recipe_orgn_statement   VARCHAR2(32700);  /*B5146342 */
recipe_statement        VARCHAR2(32700);
sql_stmt                VARCHAR2(32700);
fmdtl_sz           NUMBER ;
stepassn_sz          NUMBER ;
matl_assn          BOOLEAN ;

BEGIN
  -- Initialize the global vars
  g_rtgdtl_sz           := 0 ;
  g_rtgdtl_loc           := 1 ;
  recipe_orgn_over_size   := 1; /*B5146342*/
  recipe_override_size    := 1; /*B5146342*/
  non_rtg_item            := 0 ;
  temp_var                := 0 ;

  -- First Turn off the formula security
  gmd_p_fs_context.set_additional_attr ;

      log_message('===== Input Parameters ===== ');
      log_message('p_from_orgn = ' || p_from_orgn);
      log_message('p_to_orgn = ' || p_to_orgn);
      log_message('p_from_item_id = ' || p_from_item_id);
      log_message('p_to_item_id = ' || p_to_item_id);

  -- Get the routing details information
  -- If routing does not exist , just update attributes and offsets

   OPEN cur_routing_dtls FOR
   SELECT rdtl.routing_id ,
          rhdr.routing_no ,
          rhdr.routing_qty,
          rhdr.routing_uom,   /*Sowmya - Inventory convergence*/
          rdtl.routingstep_id ,
          opr.oprn_no  ,
          rdtl.step_qty     ,
          opr.process_qty_uom, /*Sowmya - Inventory convergence*/
          act.activity     ,
          act.activity_factor,
          act.oprn_line_id ,
          ores.resources  ,
          ores.process_qty    ,
          ores.resource_process_uom, /*Sowmya - Inventory convergence*/
          ores.resource_count ,
          inv_convert.inv_um_convert
             (-1,     -- Item_id
              38,  -- Precision
              ores.resource_usage,   -- Quantity
              ores.resource_usage_uom ,  -- from Unit
              g_uom_hr ,    -- To Unit
              NULL ,      -- From_name
              NULL      -- To_name
              ) resource_usage,    -- B5885931
          ores.resource_usage_uom, /*Sowmya - Inventory convergence*/
          ores.scale_type   ,
          ores.prim_rsrc_ind,
          act.material_ind ,
          -1 o_step_qy,
          -1 o_process_qty,
          -1 o_resource_usage,
          -1 o_activity_factor
   FROM   gmd_operations opr,
          gmd_operation_activities act,
          gmd_operation_resources ores,
          fm_rout_dtl rdtl,
          gmd_routings_b rhdr,
          (SELECT DISTINCT gr.routing_id
          FROM gmd_recipes_b gr,
               gmd_recipe_validity_rules grv,
               gmd_status_b gs
          WHERE gr.recipe_id = grv.recipe_id
            AND grv.validity_rule_status = gs.status_code
            AND gs.status_type IN ('700','900','400')
            AND gs.delete_mark = 0
            AND gr.delete_mark = 0
            AND grv.delete_mark = 0
          ) eff
   WHERE eff.routing_id = rhdr.routing_id
     AND rhdr.routing_id = rdtl.routing_id
     AND rdtl.oprn_id = opr.oprn_id
     AND opr.oprn_id = act.oprn_id
     AND act.oprn_line_id = ores.oprn_line_id
     AND ores.prim_rsrc_ind IN (1,2)
     AND opr.delete_mark = 0
     AND ores.delete_mark = 0
     AND rhdr.delete_mark = 0
   ORDER BY
        rdtl.routing_id, rdtl.routingstep_id,  act.oprn_line_id,  act.offset_interval,
        ores.prim_rsrc_ind, ores.resources ;

    rtgdtl_sz := 1 ;
    LOOP
       FETCH cur_routing_dtls INTO routing_dtl_tbl(rtgdtl_sz) ;
       EXIT WHEN cur_routing_dtls%NOTFOUND ;
       -- B5885931 Log message in concurrent log when uom_conversion is not proper.
       BEGIN
         IF NVL(routing_dtl_tbl(rtgdtl_sz).resource_usage, 0) < 0 THEN
           log_message('UOM Conversion setup error for routing_id '|| routing_dtl_tbl(rtgdtl_sz).routing_id );
         END IF;
         EXCEPTION
          WHEN OTHERS THEN
            NULL;
       END;
       rtgdtl_sz := rtgdtl_sz + 1;
    END LOOP;
    rtgdtl_sz := rtgdtl_sz - 1 ;
    g_rtgdtl_sz := rtgdtl_sz ;

    CLOSE cur_routing_dtls ;
    log_message('Routing Details Size is '||rtgdtl_sz);

/*   IF  rtgdtl_sz > 0 THEN
    log_message('routing_id rout_qty rout_um oprn_no step_qty proc_qty_um oprn_lin_id act act_fact res proc_qty UM Cnt Usage UM Scale_tp Prim  ');
    i:= 1 ;
    FOR i IN 1..rtgdtl_sz
    LOOP

    log_message(routing_dtl_tbl(i).routing_id ||'-'||
            routing_dtl_tbl(i).routing_qty  ||'-'||
            routing_dtl_tbl(i).routing_um  ||'-'||
            routing_dtl_tbl(i).operation_no  ||'-'||
            routing_dtl_tbl(i).step_qty  ||'-'||
            routing_dtl_tbl(i).process_qty_um  ||'-'||
            routing_dtl_tbl(i).oprnline_id  ||'-'||
            routing_dtl_tbl(i).activity  ||'-'||
            routing_dtl_tbl(i).activity_factor  ||'-'||
            routing_dtl_tbl(i).Resources  ||'-'||
            routing_dtl_tbl(i).process_qty  ||'-'||
            routing_dtl_tbl(i).process_uom  ||'-'||
            routing_dtl_tbl(i).resource_cnt  ||'-'||
            routing_dtl_tbl(i).Resource_usage  ||'-'||
            g_uom_hr  ||'-'||
            routing_dtl_tbl(i).scale_type  ||'-'||
            routing_dtl_tbl(i).prim_rsrc_ind||'=='||
            ROUND(temp_var,5)  );
    END LOOP ;
   END IF;  */

/*B5146342 - to handle mulitple same activities in an oprn and overrides - starts*/
        recipe_orgn_statement := ' SELECT '
                                ||'  grb.routing_id, gc.organization_id, '
                                ||'  gc.routingstep_id, gc.oprn_line_id, gc.recipe_id, '
                                ||'  gc.activity_factor, '
                                ||'  gc.resources, gc.resource_usage, gc.process_qty '
                                ||' FROM gmd_recipes grb, '
                                ||'      gmd_status_b gs, '
                                ||' ( '
                                ||' SELECT '
                                ||'  gor.recipe_id, '
                                ||'  gor.organization_id, '
                                ||'  gor.oprn_line_id, '
                                ||'  gor.routingstep_id, '
                                ||'  goa.activity_factor, '
                                ||'  gor.resources, '
                                ||'  inv_convert.inv_um_convert '
                                ||'   (-1, '                 -- Item_id
                                ||'    38,'                  -- Precision
                                ||'    gor.resource_usage,'  -- Quantity
                                ||'    gor.usage_uom , '     -- from Unit
                                ||'    :b_uom_hr , '          -- To Unit
                                ||'    NULL ,  '             -- From_name
                                ||'    NULL    '             -- To_name
                                ||'   ) resource_usage, '   -- B5885931
                                ||'  gor.process_qty  '
                                ||' FROM  gmd_recipe_orgn_activities goa, '
                                ||'       gmd_recipe_orgn_resources gor '
                                ||' WHERE gor.recipe_id = goa.recipe_id '
                                ||'   AND gor.organization_id = goa.organization_id '
                                ||'   AND gor.oprn_line_id = goa.oprn_line_id '
                                ||'   AND gor.routingstep_id = goa.routingstep_id '
                                ||' UNION ALL '
                                ||' SELECT goa.recipe_id, '
                                ||'  goa.organization_id, '
                                ||'  goa.oprn_line_id, '
                                ||'  goa.routingstep_id, '
                                ||'  goa.activity_factor,  '
                                ||'  NULL resources,  '
                                ||'  -1 resource_usage, '
                                ||'  -1 process_qty '
                                ||' FROM  gmd_recipe_orgn_activities goa '
                                ||' WHERE NOT EXISTS( SELECT 1 '
                                ||'       FROM gmd_recipe_orgn_resources gor '
                                ||'       WHERE gor.recipe_id = goa.recipe_id '
                                ||'         AND gor.organization_id = goa.organization_id '
                                ||'         AND gor.oprn_line_id = goa.oprn_line_id '
                                ||'         AND gor.routingstep_id = goa.routingstep_id ) '
                                ||' UNION ALL '
                                ||' SELECT gor.recipe_id, '
                                ||'  gor.organization_id, '
                                ||'  gor.oprn_line_id, '
                                ||'  gor.routingstep_id, '
                                ||'  -1 activity_factor, '
                                ||'  gor.resources, '
                                ||'  inv_convert.inv_um_convert '
                                ||'   (-1, '                 -- Item_id
                                ||'    38,'                  -- Precision
                                ||'    gor.resource_usage,'  -- Quantity
                                ||'    gor.usage_uom , '     -- from Unit
                                ||'    :b_uom_hr , '          -- To Unit
                                ||'    NULL ,  '             -- From_name
                                ||'    NULL    '             -- To_name
                                ||'   )  resource_usage, '   -- B5885931
                                ||'  gor.process_qty  '
                                ||' FROM  gmd_recipe_orgn_resources gor  '
                                ||' WHERE NOT EXISTS( SELECT 1 '
                                ||'       FROM gmd_recipe_orgn_activities goa'
                                ||'       WHERE goa.recipe_id = gor.recipe_id '
                                ||'         AND goa.organization_id = gor.organization_id '
                                ||'         AND goa.oprn_line_id = gor.oprn_line_id '
                                ||'         AND goa.routingstep_id = gor.routingstep_id ) '
                                ||' ) gc '
                                ||' WHERE grb.recipe_id = gc.recipe_id '
                                ||'   AND grb.delete_mark = 0 '
                                ||'   AND grb.recipe_status =  gs.status_code '
                                ||'   AND gs.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
                                ||'   AND gs.delete_mark = 0 '
                                ||'   AND gc.organization_id >= NVL(:orgn_id,gc.organization_id) '
                                ||'   AND gc.organization_id <= NVL(:to_orgn,gc.organization_id) '
                                ||' ORDER BY 1,2,3,4,7, 5 ' ;
   log_message(recipe_orgn_statement);
    OPEN c_recipe_orgn FOR recipe_orgn_statement USING
       g_uom_hr , g_uom_hr , p_from_orgn , p_to_orgn ;

    LOOP
      FETCH c_recipe_orgn INTO rcp_orgn_override(recipe_orgn_over_size);
      EXIT WHEN c_recipe_orgn%NOTFOUND;
      recipe_orgn_over_size := recipe_orgn_over_size + 1;
    END LOOP;
    CLOSE c_recipe_orgn;
    recipe_orgn_over_size := recipe_orgn_over_size -1 ;
    time_stamp ;
    log_message('recipe_orgn_over_size is= '|| TO_CHAR(recipe_orgn_over_size));

/*   IF recipe_orgn_over_size > 0 THEN
    log_message('routing_id organization_id routingstep_id oprn_line_id recipe_id activity_factor resources resource_usage process_qty');
    i:= 1 ;
    FOR i IN 1..recipe_orgn_over_size
    LOOP

    log_message(rcp_orgn_override(i).routing_id ||'-'||
            rcp_orgn_override(i).org_id  ||'-'||
            rcp_orgn_override(i).routingstep_id  ||'-'||
            rcp_orgn_override(i).oprn_line_id  ||'-'||
            rcp_orgn_override(i).recipe_id  ||'-'||
            rcp_orgn_override(i).activity_factor  ||'-'||
            rcp_orgn_override(i).resources  ||'-'||
            rcp_orgn_override(i).resource_usage  ||'-'||
            rcp_orgn_override(i).process_qty  ||'-'||
            ROUND(temp_var,5)  );
    END LOOP ;
   END IF;  */

    recipe_statement :=
                 ' SELECT grb.routing_id, grs.routingstep_id, grs.recipe_id, '
               ||'        grs.step_qty '
               ||' FROM gmd_recipes grb, '
               ||'      gmd_status_b gs, '
               ||'      gmd_recipe_routing_steps grs '
               ||' WHERE grb.recipe_id = grs.recipe_id '
               ||'   AND grb.delete_mark = 0 '
               ||'   AND grb.recipe_status =  gs.status_code '
               ||'   AND gs.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
               ||'   AND gs.delete_mark = 0 '
               ||' ORDER BY 1,2,3 ' ;

    OPEN c_recipe_override FOR recipe_statement ;
    LOOP
      FETCH c_recipe_override INTO recipe_override(recipe_override_size);
      EXIT WHEN c_recipe_override%NOTFOUND;
      recipe_override_size := recipe_override_size + 1;
    END LOOP;
    CLOSE c_recipe_override;
    recipe_override_size := recipe_override_size -1 ;
    time_stamp ;
    log_message('recipe Override size is = '||TO_CHAR(recipe_override_size)) ;
    /*B5146342 - to handle mulitple same activities in an oprn and overrides - ends*/

    -- Abhay / Teresa 12/16/2003 B3322282
    -- Rewrote SQL statement for 8i.

    /*Sowmya - Inventory convergence - begin - Changed the cursor for inventory convergence.*/

    -- Abhay / Teresa 12/16/2003 B3322282
    -- Rewrote SQL statement for 8i.
    sql_stmt := ' SELECT '
     ||' msi.inventory_item_id,  '
     ||' msi.segment1, ' --Added as part of inventory convergence
     ||' inv_convert.inv_um_convert '
     ||'        (eff.inventory_item_id, '
     ||'         NULL, '
     ||'         msi.organization_id, '
     ||'         NULL, '
     ||'         eff.std_qty, '
     ||'         msi.primary_uom_code , '   /* primary */
     ||'         eff.detail_uom , '   /* routing um */
     ||'         NULL , '
     ||'         NULL '
     ||'         ) eff_qty, '
     ||' msi.primary_uom_code ,  '
     ||' mp.organization_id ,  '
     ||' gmp_lead_time_calculator_pkg.get_avg_working_hours(bc.calendar_code) ,  '
     ||' eff.fmeff_id,  '
     ||' eff.recipe_id,  '
     ||' eff.formula_id,  '
     ||' eff.routing_id,  '
     ||' prvr.scale_type, '
     ||' ffm.total_output_qty, '     -- Bug: 8736658 Added code to fetch total output of the formula
     ||' ffm.yield_uom  '         -- Bug: 8736658   Added code to fetch yield uom of the formula
     ||' FROM mtl_parameters mp,  '
     ||' mtl_system_items msi,  '
     ||' bom_calendars bc,  '
     ||' fm_form_eff eff,   '
     ||' fm_form_mst ffm, '
     ||' (SELECT  DISTINCT  '
     ||'  NVL(eff.organization_id,mp.organization_id) organization_id,  '
     ||'  eff.fmeff_id pref_eff, '
     ||'  DENSE_RANK () '
     ||'        OVER  (PARTITION BY eff.inventory_item_id,NVL(eff.organization_id,mp.organization_id) '
     ||'   ORDER BY eff.preference,eff.last_update_date DESC) drank,  '
     ||'  DENSE_RANK ()  '
     ||'        OVER  (PARTITION BY fmd.inventory_item_id,fmd.organization_id  '
     ||'   ORDER BY fmd.line_no,fmd.last_update_date DESC) frank,    '
     ||'  eff.inventory_item_id  , '
     ||'  fmd.scale_type '     -- Bug: 8736658 Added code to fetch scale type of product item
     ||'  FROM   gmd_status_b gs, '
     ||'         mtl_parameters mp,  '
     ||'         hr_organization_units hr,  '
     ||'         fm_form_eff eff , '
     ||'         Fm_Matl_Dtl fmd '
     ||'  WHERE NVL(eff.organization_id,mp.organization_id) = mp.organization_id   '
     ||'  AND eff.validity_rule_status = gs.status_code   '
     ||'  AND fmd.formula_id = eff.formula_id '
     ||'  AND fmd.line_type = 1 '
     ||'  AND fmd.inventory_item_id = eff.inventory_item_id  '
     ||' AND gs.status_type IN (' ||'''700'''|| ',' ||'''900'''|| ',' ||'''400'''|| ') '
     --B3696730 niyadav 06/22/2004 code changes end.
     ||' AND mp.organization_id = hr.organization_id  '
     ||' AND mp.process_enabled_flag = '||''''||'Y'||''''
     ||' AND nvl(hr.date_to,sysdate) >= sysdate '
     --Inventory convergence. Resource whse does not exist any longer
     --'AND sy.resource_whse_code IS NOT NULL '
     ||' ) prvr  '
     ||' WHERE eff.fmeff_id = prvr.pref_eff  '
     ||' AND ffm.formula_id = eff.formula_id '
     ||' AND prvr.organization_id =  mp.organization_id  '
     ||' AND mp.calendar_code = bc.calendar_code '
     ||' AND eff.inventory_item_id = msi.inventory_item_id  '
     ||' AND msi.organization_id = mp.organization_id  '
     ||' AND msi.inventory_item_id  >= NVL(:from_item_id,msi.inventory_item_id ) '
     ||' AND msi.inventory_item_id  <= NVL(:to_item_id,msi.inventory_item_id ) '
     ||' AND msi.organization_id between NVL(:from_org_id,msi.organization_id) '
     ||'                        and NVL(:to_org_id,msi.organization_id) '
     ||' AND drank = 1   '
     ||' AND frank = 1 '
     ||' ORDER BY eff.routing_id , eff.recipe_id ' ;

    OPEN cur_item_eff FOR  sql_stmt USING p_from_item_id , p_to_item_id, p_from_orgn , p_to_orgn ;
    LOOP
     FETCH cur_item_eff INTO item_eff ;
     EXIT WHEN cur_item_eff%NOTFOUND ;
     IF item_eff.routing_id IS NULL OR item_eff.eff_qty < 0 THEN
      -- Just update the Inventory item Attribute to Zero
        non_rtg_item := non_rtg_item + 1 ;
        g_non_rtg_itm_cnt := g_non_rtg_itm_cnt + 1 ;
     ELSE -- item_eff.routing_id is NOT NULL
        log_message('item_no '||item_eff.item_no||' org_id '|| item_eff.org_id||' routing_id '||item_eff.routing_id||' recipe_id '||item_eff.recipe_id);
        calc_lead_time(item_eff.routing_id ) ;
        -- We may want to move the insert into routing_offsets and
        -- updates to the mtl_system_items into this procedure
     END IF ;
    END LOOP ;
    CLOSE cur_item_eff ;

    time_stamp ;
    retcode := '0' ;
    log_message('Total number of items updated '||g_item_cnt );
    log_message('Total number of items without Rtg '||g_non_rtg_itm_cnt );
    log_message('Total number errors '||g_err_cnt );

EXCEPTION
    WHEN OTHERS THEN
      log_message('Error in procedure calculate_lead_times '||SQLCODE||SQLERRM) ;
      retcode := '-111' ;
END calculate_lead_times ;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    calc_lead_time                                                       |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|       06-Oct-2003 Abhay Satpute Created                                 |
REM|       23-APR-2004 Abhay B3580639 Changed g_rtgdtl_loc value to i-1      |
REM|                   also added commit and corrected where cond in main SQL|
REM|       24-APR-2004 Abhay B3580768 do not divide by l_lead_time_lot_size  |
REM|                   for fixed lead time                                   |
REM+=========================================================================+
*/
PROCEDURE calc_lead_time (p_routing_id NUMBER)
IS
i        NUMBER ;
j              NUMBER ;
k              NUMBER ;
z        NUMBER ;
prev_step_id      NUMBER := 0 ;
prev_activity      VARCHAR2(64) := '__' ;
v_resource_usage     NUMBER := 0 ;
prev_v_resource_usage     NUMBER := 0 ;
f_resource_usage     NUMBER := 0 ;
prev_f_resource_usage     NUMBER := 0 ;
curr_loc       NUMBER := 0 ;
step_stored       NUMBER := 0 ;
step_loc       NUMBER := 0 ;
next_step_loc       NUMBER := 0 ;
temp_start_offset    NUMBER := TO_NUMBER(NULL);
temp_end_offset      NUMBER := TO_NUMBER(NULL);

-- Item update variables
l_item_ret     NUMBER  ;
l_inv_item_id     NUMBER := 0 ;
l_inv_org_id     NUMBER := 0 ;
l_lead_time_lot_size  NUMBER := 0 ;
l_temp_v_lead_time  NUMBER := 0 ;
l_temp_f_lead_time  NUMBER := 0 ;

temp_ret_stat     VARCHAR2(2000) ;
l_item_rec     inv_item_grp.item_rec_type ;
o_item_rec     inv_item_grp.item_rec_type ;
l_error_tbl     inv_item_grp.error_tbl_type;
found_Step              NUMBER; /*B5146342*/
orgn_Step               NUMBER; /*B5146342*/

/*B5251675 - ASQC STEP QTY CALCULATION STARTS */
m      NUMBER ;
curr_cnt    NUMBER ;
calc_step_qty_flag      NUMBER ;
l_step_tbl          gmd_auto_step_calc.step_rec_tbl;
l_msg_count             NUMBER ;
l_msg_data              VARCHAR2(2000) ;
l_return_status         VARCHAR2(30);
cur_calc_step_qty   ref_cursor_typ;
asqc_found              BOOLEAN ;

/*B5251675 - ASQC STEP QTY CALCULATION ENDS */

details_found             NUMBER;  -- Bug: 8736658
eff_routing_qty           NUMBER;  -- Bug: 8736658
c_step_qty                NUMBER;  -- Bug: 8736658
c_process_qty             NUMBER;  -- Bug: 8736658
c_resource_usage          NUMBER;  -- Bug: 8736658
c_activity_factor         NUMBER;  -- Bug: 8736658

BEGIN

found_step              := 1 ; /*B5146342*/
orgn_Step               := 1;  /*B5146342*/

-- Do not delete the existing pl/sql table for now as
-- the leadtimes etc will not change if routing remains same
-- Once we consider the overridesthis will have to be deleted

-- =============================================


-- Bug: 6441299 Kbanddyo commented the IF condition below and the routing_id assignment

--IF g_prev_routing_id <>  p_routing_id THEN
--g_prev_routing_id := p_routing_id ;

  rtg_steps_tbl.DELETE ;
  g_cum_f_duration := 0 ;
  g_cum_v_duration := 0 ;
  g_cum_duration   := 0 ;
  asqc_found := TRUE;
  j:= 0;


  -- Bug: 6441299 Kbanddyo initialization of variables
    found_step       := 1;
    orgn_step        := 1;
    details_found    := -1;
    c_step_qty       := -1;  -- Bug: 8736658
    c_process_qty    := -1; -- Bug: 8736658
    c_resource_usage := -1;  -- Bug: 8736658
    c_activity_factor := -1;  -- Bug: 8736658

OPEN cur_calc_step_qty FOR
        SELECT calculate_step_quantity
        FROM gmd_recipes
        WHERE recipe_id = item_eff.recipe_id;

FETCH cur_calc_step_qty INTO calc_step_qty_flag;
CLOSE cur_calc_step_qty;

/*
Also notice that when we compute the step times those are for total output
and the product item is part of it so the lead time lot size needs to be
discounted for that OR increase the lot size by the ratio
of total output/prod qty
*/

-- Bug: 8736658 Vpedarla
FOR i IN g_rtgdtl_loc..g_rtgdtl_sz
LOOP
routing_dtl_tbl(i).o_step_qty         := -1 ;
routing_dtl_tbl(i).o_process_qty     := -1 ;
routing_dtl_tbl(i).o_resource_usage  := -1 ;
routing_dtl_tbl(i).o_activity_factor := -1 ;
END LOOP;
-- Bug: 8736658 Vpedarla end

IF g_rtgdtl_sz > 0 THEN  -- Bug: 8736658 Vpedarla

FOR i IN g_rtgdtl_loc..g_rtgdtl_sz
LOOP

step_loc := i ;
IF g_rtgdtl_sz > 1 THEN  --  Bug: 8736658 Vpedarla
   IF i = g_rtgdtl_sz THEN
      next_step_loc := i - 1 ;
   ELSE
      next_step_loc := i + 1;
   END IF ;
ELSE
  next_step_loc := i ;
END IF;

 IF routing_dtl_tbl(i).routing_id = p_routing_id THEN

 --Kbanddyo Added this line as a part of BUG#6441299
 --The logic used for looping through all the values from g_rtgdtl_loc..g_rtgdtl_sz fails for the last one
 IF details_found = -1 THEN
   g_rtgdtl_loc  := i ;
   details_found := 1;
 END IF;
 /* ---------- B5251675 ASQC STEP QTY CALCULATION STARTS-------------------*/
log_message('calc_step_qty_flag - '|| calc_step_qty_flag);

  IF ( calc_step_qty_flag = 1 AND asqc_found ) THEN
        gmd_auto_step_calc.calc_step_qty(p_parent_id          => item_eff.recipe_id,
                                       p_step_tbl          => l_step_tbl,
                                       p_msg_count              => l_msg_count,
                                       p_msg_stack              => l_msg_data,
                                       p_return_status           => l_return_status,
                                       p_called_from_batch  => 0,
                                       p_ignore_mass_conv       => TRUE,
                                       p_ignore_vol_conv        => TRUE,
                                       p_scale_factor           => 1,
                                       p_process_loss           => 0,
                                       p_organization_id        => item_eff.org_id);

        m:= 1;
        LOOP
                FOR curr_cnt IN i..g_rtgdtl_sz
                LOOP

                        IF routing_dtl_tbl(curr_cnt).routingstep_id = l_step_tbl(m).step_id THEN
                                routing_dtl_tbl(curr_cnt).o_step_qty := l_step_tbl(m).step_qty;
                            /* log_message('Step quantities updated..');   */
                        ELSIF  routing_dtl_tbl(curr_cnt).routingstep_id > l_step_tbl(m).step_id OR
                                routing_dtl_tbl(curr_cnt).routing_id > p_routing_id THEN
                                routing_dtl_tbl(curr_cnt).o_step_qty := -1 ;
                        END IF;
                        EXIT WHEN routing_dtl_tbl(curr_cnt).routingstep_id > l_step_tbl(m).step_id OR
                                routing_dtl_tbl(curr_cnt).routing_id > p_routing_id ;
                END LOOP;
                m := m + 1;
                EXIT WHEN m > l_step_tbl.COUNT ;
        END LOOP;

        asqc_found := FALSE;
  END IF;

  /* ---------- B5251675 ASQC STEP QTY CALCULATION ENDS-------------------*/

   IF ( calc_step_qty_flag <> 1 ) THEN /*B5251675 - when ASQC is not turned on step qty override
                                         to be considered*/
            /* ---------- B5146342 STEP OVERRIDES STARTS -------------------*/
            j:= 1 ;
            FOR j IN found_step..recipe_override_size
            LOOP
             IF recipe_override(j).routing_id = routing_dtl_tbl(i).routing_id
             AND recipe_override(j).routingstep_id = routing_dtl_tbl(i).routingstep_id
             AND recipe_override(j).recipe_id = item_eff.recipe_id THEN

              -- Bug: 8736658 Vpedarla
               IF item_eff.scale_type <> 0 AND NVL(item_eff.formula_ouput,0) > 0THEN
                   eff_routing_qty :=  inv_convert.inv_um_convert
                  (item_eff.inventory_item_id,
                   NULL,
                   item_eff.org_id,
                   NULL,
                   routing_dtl_tbl(i).routing_qty,
                   routing_dtl_tbl(i).routing_um,    /* routing um */
		   item_eff.formula_uom ,    /* primary */
                   NULL ,
                   NULL );
		  /* log_message(recipe_override(j).step_qty||'**'||eff_routing_qty||'**'||item_eff.formula_ouput);   */
                   IF  eff_routing_qty > 0 THEN
                   routing_dtl_tbl(i).o_step_qty := recipe_override(j).step_qty*(eff_routing_qty/item_eff.formula_ouput);
        /* log_message('Step quantities updated..');   */
               ELSE
                  log_message('Recipe Step quantity override update failed');
               END IF;
               ELSE
                   routing_dtl_tbl(i).o_step_qty := recipe_override(j).step_qty;
        /* log_message('Step quantities updated..');   */
               END IF;
              -- routing_dtl_tbl(i).step_qty :=  recipe_override(j).step_qty ;
               found_step := j  ;
               EXIT ;
             ELSIF recipe_override(j).routing_id > routing_dtl_tbl(i).routing_id THEN
               routing_dtl_tbl(i).o_step_qty := -1 ;
               EXIT ;
             ELSE
               /* Keep on looping  */
               NULL ;
             END IF;
            END LOOP ;
            /* ---------- B5146342 STEP OVERRIDES ENDS -------------------*/
     END IF; /*B5251675*/

    /* ---------- B5146342 ORGN OVERRIDES STARTS -------------------*/
    k:= 1 ;

    FOR k IN orgn_step..recipe_orgn_over_size
    LOOP
     IF rcp_orgn_override(k).routing_id = routing_dtl_tbl(i).routing_id
        AND rcp_orgn_override(k).routingstep_id =
                     routing_dtl_tbl(i).routingstep_id
        AND rcp_orgn_override(k).recipe_id = item_eff.recipe_id
        AND rcp_orgn_override(k).org_id = item_eff.org_id
        AND rcp_orgn_override(k).oprn_line_id = routing_dtl_tbl(i).oprnline_id
     THEN
         orgn_step := k ;

      -- Activity factor override
        IF rcp_orgn_override(k).activity_factor >= 0 THEN
         routing_dtl_tbl(i).o_activity_factor := rcp_orgn_override(k).activity_factor ;
        END IF;

      -- Resource Overrides
      IF rcp_orgn_override(k).resources = routing_dtl_tbl(i).resources THEN
        IF rcp_orgn_override(k).process_qty > 0 THEN
         routing_dtl_tbl(i).o_process_qty :=  rcp_orgn_override(k).process_qty ;
        END IF;
         --  SPECIAL !!! process_qty ZERO than take final step_qty */
         IF rcp_orgn_override(k).process_qty = 0 THEN
          IF routing_dtl_tbl(i).o_step_qty > 0 THEN
             routing_dtl_tbl(i).o_process_qty := routing_dtl_tbl(i).o_step_qty ;
          ELSE
             routing_dtl_tbl(i).o_process_qty := routing_dtl_tbl(i).step_qty ;
          END IF;
         END IF ;

        IF rcp_orgn_override(k).resource_usage >= 0 THEN
         routing_dtl_tbl(i).o_resource_usage :=  rcp_orgn_override(k).resource_usage ;
        END IF;
         -- found the resource, now exit
      --   orgn_step := k ;
         EXIT;
      ELSE
         NULL ;
      END IF;

     ELSIF rcp_orgn_override(k).routing_id > routing_dtl_tbl(i).routing_id THEN
         routing_dtl_tbl(i).o_resource_usage :=    -1 ;
         routing_dtl_tbl(i).o_process_qty :=       -1 ;
         routing_dtl_tbl(i).o_activity_factor :=   -1 ;
         EXIT ;
     ELSE
         /* Keep on looping  */
         NULL ;
     END IF;
    END LOOP ;
    /* ---------- B5146342 ORGN OVERRIDES ENDS -------------------*/

      /* B5146342 - SPECIAL !!! process_qty ZERO than take step_qty */
      IF routing_dtl_tbl(i).process_qty = 0 THEN
          routing_dtl_tbl(i).process_qty := routing_dtl_tbl(i).step_qty ;
      END IF ;

      v_resource_usage := 0 ;
      f_resource_usage := 0 ;

  -- calculate rsrc_usage

  -- Bug: 8736658
  IF routing_dtl_tbl(i).o_step_qty > 0 THEN
    c_step_qty       := routing_dtl_tbl(i).o_step_qty;
  ELSE
    c_step_qty       := routing_dtl_tbl(i).step_qty;
  END IF;

  IF routing_dtl_tbl(i).o_process_qty > 0 THEN
    c_process_qty       := routing_dtl_tbl(i).o_process_qty ;
  ELSE
    c_process_qty       := routing_dtl_tbl(i).process_qty ;
  END IF;

  IF routing_dtl_tbl(i).o_resource_usage > 0 THEN
    c_resource_usage       := routing_dtl_tbl(i).o_resource_usage;
  ELSE
    c_resource_usage       := routing_dtl_tbl(i).resource_usage;
  END IF;

  IF routing_dtl_tbl(i).o_activity_factor > 0 THEN
    c_activity_factor       := routing_dtl_tbl(i).o_activity_factor;
  ELSE
    c_activity_factor       := routing_dtl_tbl(i).activity_factor;
  END IF;
   /* log_message(c_step_qty'**'||c_process_qty||'**'||c_resource_usage||'**'||c_activity_factor); */
   -- Bug: 8736658 end

  IF routing_dtl_tbl(i).scale_type > 0 THEN

  -- Bug: 8736658 Vpedarla
    v_resource_usage := ROUND(((c_step_qty/c_process_qty)*c_resource_usage * c_activity_factor ),5);
  /*  v_resource_usage := ROUND(((routing_dtl_tbl(i).step_qty/
        routing_dtl_tbl(i).process_qty)*
        routing_dtl_tbl(i).resource_usage *
        routing_dtl_tbl(i).activity_factor ),5);  */
    IF prev_v_resource_usage = 0 THEN
      prev_v_resource_usage := v_resource_usage ;
    END IF ;
  ELSE
       -- Bug: 8736658 Vpedarla
      f_resource_usage := c_resource_usage * c_activity_factor ;
   /* f_resource_usage := routing_dtl_tbl(i).resource_usage *
            routing_dtl_tbl(i).activity_factor ; */
    IF prev_f_resource_usage = 0 THEN
      prev_f_resource_usage := f_resource_usage ;
    END IF ;
  END IF ;

        -- check if step and activity is same
  IF (routing_dtl_tbl(step_loc).routingstep_id =
    routing_dtl_tbl(next_step_loc).routingstep_id ) AND
    (routing_dtl_tbl(step_loc).activity =
    routing_dtl_tbl(next_step_loc).activity) THEN

            --Find the longest resource in the activity
      IF v_resource_usage > prev_v_resource_usage THEN
                  prev_v_resource_usage := v_resource_usage ;
      END IF ;
      IF f_resource_usage > prev_f_resource_usage THEN
              prev_f_resource_usage := f_resource_usage ;
      END IF ;

            -- Last row of the whole program and multiple activities
            IF (i = g_rtgdtl_sz ) THEN

                    IF prev_f_resource_usage <> 0 THEN
                        g_cum_f_duration := g_cum_f_duration + prev_f_resource_usage ;
                    ELSE
                        g_cum_f_duration := g_cum_f_duration + f_resource_usage ;
                        prev_f_resource_usage := f_resource_usage ;
                    END IF;

                    IF prev_v_resource_usage <> 0 THEN
                        g_cum_v_duration := g_cum_v_duration + prev_v_resource_usage ;
                    ELSE
                        g_cum_v_duration := g_cum_v_duration + v_resource_usage ;
                        prev_v_resource_usage := v_resource_usage ;
                    END IF;

                    IF prev_f_resource_usage > prev_v_resource_usage THEN
                        g_cum_duration := g_cum_duration + prev_f_resource_usage ;
                    ELSE
                        g_cum_duration := g_cum_duration + prev_v_resource_usage ;
                    END IF;

                    log_message(' Last Row Route=' || routing_dtl_tbl(step_loc).routing_id
                     || ' Step=' || routing_dtl_tbl(step_loc).routingstep_id || ' oper=' ||
                      routing_dtl_tbl(step_loc).oprnline_id ||' Scaling '||
                      routing_dtl_tbl(i).scale_type  || ' fixed Usage=' ||
                      f_resource_usage || ' Prev fixed=' || prev_f_resource_usage
                      || ' Var Usage=' || v_resource_usage || ' Prev Var=' || prev_v_resource_usage );

                     prev_f_resource_usage := 0 ;
                     prev_v_resource_usage := 0 ;

            END IF;

  ELSE -- step OR activity changed

                log_message(' CALCULATE STEP=' || routing_dtl_tbl(step_loc).routingstep_id || '-' ||
                routing_dtl_tbl(next_step_loc).routingstep_id || ' oper=' ||
                routing_dtl_tbl(step_loc).oprnline_id || '-' ||
                routing_dtl_tbl(next_step_loc).oprnline_id  ||' Scaling '||
                routing_dtl_tbl(i).scale_type  || ' fixed Usage=' ||
                f_resource_usage || ' Prev fixed=' || prev_f_resource_usage
                || ' Var Usage=' || v_resource_usage || ' Prev Var=' || prev_v_resource_usage );

                IF prev_f_resource_usage <> 0 THEN
                        g_cum_f_duration := g_cum_f_duration + prev_f_resource_usage ;
                ELSE
                        g_cum_f_duration := g_cum_f_duration + f_resource_usage ;
                        prev_f_resource_usage := f_resource_usage ;
                END IF;

                IF prev_v_resource_usage <> 0 THEN
                        g_cum_v_duration := g_cum_v_duration + prev_v_resource_usage ;
                ELSE
                        g_cum_v_duration := g_cum_v_duration + v_resource_usage ;
                        prev_v_resource_usage := v_resource_usage ;
                END IF;

                IF prev_f_resource_usage > prev_v_resource_usage THEN
                        g_cum_duration := g_cum_duration + prev_f_resource_usage ;
                ELSE
                        g_cum_duration := g_cum_duration + prev_v_resource_usage ;
                END IF;

                prev_f_resource_usage := 0 ;
                prev_v_resource_usage := 0 ;

/*         g_cum_f_duration := g_cum_f_duration + prev_f_resource_usage ;
         g_cum_v_duration := g_cum_v_duration + prev_v_resource_usage ;

     IF prev_f_resource_usage > prev_v_resource_usage THEN
       g_cum_duration := g_cum_duration + prev_f_resource_usage ;
      ELSE
       g_cum_duration := g_cum_duration + prev_v_resource_usage ;
    END IF;
    prev_f_resource_usage := 0 ;
    prev_v_resource_usage := 0 ;*/
  END IF ; /* Step or activity change */

  IF (routing_dtl_tbl(step_loc).routingstep_id <>
    routing_dtl_tbl(next_step_loc).routingstep_id ) OR
    (i = g_rtgdtl_sz )
  THEN
    curr_loc := curr_loc + 1 ;
    rtg_steps_tbl(curr_loc).routing_id := routing_dtl_tbl(i).routing_id ;
    rtg_steps_tbl(curr_loc).routingstep_id := routing_dtl_tbl(i).routingstep_id ;
    rtg_steps_tbl(curr_loc).f_cum_duration := g_cum_f_duration ;
    rtg_steps_tbl(curr_loc).v_cum_duration := g_cum_v_duration ;
    rtg_steps_tbl(curr_loc).cum_duration := g_cum_duration ;
  END IF ;

   END IF;  -- check for routing_id

--Commenting the line since the looping logic was not correct ..as a part of BUG#6441299
--   g_rtgdtl_loc := i -1 ;

   EXIT WHEN routing_dtl_tbl(i).routing_id > p_routing_id ;

END LOOP ; -- loop of routing

-- Now calculate the offsets
FOR i IN 1..rtg_steps_tbl.COUNT
LOOP
        IF i = 1 THEN
                rtg_steps_tbl(i).start_offset := 0 ;
        ELSE
                -- B5102961 Rajesh Patangya
                IF g_cum_duration = 0 THEN
                        temp_start_offset := 0 ;
                ELSE
                        temp_start_offset := 100*(rtg_steps_tbl(i-1).cum_duration/g_cum_duration);
                END IF;
                rtg_steps_tbl(i).start_offset := ROUND(temp_start_offset,5);
                temp_start_offset := TO_NUMBER(NULL) ;
        END IF ;

        IF i < rtg_steps_tbl.COUNT THEN
                IF g_cum_duration = 0 THEN
                        temp_end_offset := 0 ;
                ELSE
                        temp_end_offset := 100*(rtg_steps_tbl(i).cum_duration/g_cum_duration) ;
                END IF;
                rtg_steps_tbl(i).end_offset := ROUND(temp_end_offset,5);
                temp_end_offset := TO_NUMBER(NULL );
        ELSE
                rtg_steps_tbl(i).end_offset := 100 ;
        END IF ;

    log_message( 'Route Offset ' || rtg_steps_tbl(i).routing_id
     ||' Step= ' || rtg_steps_tbl(i).routingstep_id
     ||' Fixed=' || rtg_steps_tbl(i).f_cum_duration
     ||' Variable='|| rtg_steps_tbl(i).v_cum_duration
     ||' cum Duration=' || rtg_steps_tbl(i).cum_duration
     ||' Start Off=' || rtg_steps_tbl(i).start_offset
     ||' End Off=' || rtg_steps_tbl(i).end_offset ) ;

END LOOP;

--END IF ; /* check for routing id change */
-- Bug: 6441299 Kbanddyo commented the above condition

-- Calculate the lot size always
-- Convert the rtg qty to Item Primary so that it can be used as
-- lead time lot size.

/*
l_lead_time_lot_size := GMICUOM.uom_conversion(
      item_eff.item_id,
      0,
      routing_dtl_tbl(g_rtgdtl_loc).routing_qty,
      routing_dtl_tbl(g_rtgdtl_loc).routing_um,
      item_eff.prim_um,
      0 );
*/

/*Sowmya - Inventory convergence - begin*/
l_lead_time_lot_size :=  inv_convert.inv_um_convert
                               (item_eff.inventory_item_id,
                                NULL,
                                item_eff.org_id,
                                NULL,
                                routing_dtl_tbl(g_rtgdtl_loc).routing_qty,
                                item_eff.prim_um ,    /* primary */
                                routing_dtl_tbl(g_rtgdtl_loc).routing_um,    /* routing um */
                                NULL ,
                                NULL );
/*Sowmya - Inventory convergence - end*/

IF l_lead_time_lot_size <= 0 THEN
-- UOM conversion failed, stop here
        RAISE UOM_CONVERSION_ERROR ;
END IF ;

-- This check is redundant as we stated in the design that Lead Time
-- will be calculated for only those organizations that have rsrc whse
IF item_eff.inventory_item_id > 0 AND item_eff.org_id IS NOT NULL THEN

/* Re-instate this code after Oracle Inventory Team
   takes care of the Update_item API , currently the API
   returns error for many seemingly correct data conditions

  l_item_rec.organization_id := l_inv_org_id ;
  l_item_rec.inventory_item_id  :=l_inv_item_id   ;
  l_item_rec.fixed_lead_time  := g_cum_f_duration   ;
  l_item_rec.variable_lead_time  := g_cum_v_duration  ;
  l_item_rec.lead_time_lot_size  := 1  ;
  inv_item_grp.update_item (
  fnd_api.g_TRUE,
  fnd_api.g_TRUE,
  1,
  l_item_rec ,
  o_item_rec ,
  temp_ret_stat,
  l_error_tbl
  );
log_message('ret stat is :'||temp_ret_stat);

IF temp_ret_stat = 'E' THEN
for z in 1..l_error_tbl.COUNT
LOOP
  log_message(l_error_tbl(z).MESSAGE_TEXT);
END LOOP;
END IF ;
*/

BEGIN
        l_temp_v_lead_time := (g_cum_v_duration/item_eff.daily_work_hours)
            / l_lead_time_lot_size ;
        l_temp_f_lead_time := (g_cum_f_duration/item_eff.daily_work_hours) ;

        log_message( 'FINAL-> ' || routing_dtl_tbl(g_rtgdtl_loc).routing_no
        || '('|| routing_dtl_tbl(g_rtgdtl_loc).routing_id  || ')'
        || 'Recipe=' || item_eff.recipe_id
        ||' Item =' || item_eff.inventory_item_id
        ||' Qty=' || routing_dtl_tbl(g_rtgdtl_loc).routing_qty
        ||' Fixed=' || l_temp_f_lead_time
        ||' Cum Fixed=' || g_cum_f_duration
        ||' Variable='|| l_temp_v_lead_time
        ||' Cum Variable='|| g_cum_v_duration );

        UPDATE mtl_system_items
        SET
        fixed_lead_time = l_temp_f_lead_time,
        variable_lead_time = l_temp_v_lead_time ,
        lead_time_lot_size = 1,
        last_update_date   = g_curr_time,
        last_updated_by    = g_user_id
        --WHERE organization_id = item_eff.mtl_org_id
        WHERE organization_id = item_eff.org_id
        AND inventory_item_id = item_eff.inventory_item_id;

        COMMIT;

        g_item_cnt := g_item_cnt + 1 ;
        l_lead_time_lot_size := 0 ;

EXCEPTION
WHEN OTHERS THEN
log_message('Error occurred during item attribute update '|| SQLERRM) ;

END ; -- anonymous block for item update

END IF ; -- valid item id and org id

BEGIN

        DELETE FROM gmp_routing_offsets
        WHERE fmeff_id  = item_eff.fmeff_id
        AND   organization_id = item_eff.org_id;

        EXCEPTION
                WHEN OTHERS THEN
                log_message('Error while deleting !!');
END ; -- anonymous block for rtg off delete

BEGIN

        FOR i IN 1..rtg_steps_tbl.COUNT
        LOOP

        INSERT INTO gmp_routing_offsets(
        /*Sowmya - Inventory convergence - commented plant code and included organization id*/
        --plant_code, fmeff_id, recipe_id,
        organization_id,
        fmeff_id,
        recipe_id,
        formula_id,
        routing_id,
        routingstep_id,
        start_offset,
        end_offset,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login )
        VALUES (
        /*Sowmya - Inventory convergence - commented plant code and included organization id*/
        --item_eff.org_code, item_eff.fmeff_id,item_eff.recipe_id,
        item_eff.org_id,
        item_eff.fmeff_id,
        item_eff.recipe_id,
        item_eff.formula_id,
        rtg_steps_tbl(i).routing_id,
        rtg_steps_tbl(i).routingstep_id,
        rtg_steps_tbl(i).start_offset,
        rtg_steps_tbl(i).end_offset,
        g_curr_time,
        g_user_id,
        g_curr_time,
        g_user_id,
        g_user_id)
        ;

        END LOOP;

        EXCEPTION
        WHEN OTHERS THEN
        log_message('Error in insert into gmp_routing_offsets'||SQLERRM) ;

END ; -- end of anonymous block for insert

END IF;  -- Bug: 8736658 Vpedarla

EXCEPTION
WHEN UOM_CONVERSION_ERROR THEN
 g_err_cnt := g_err_cnt + 1 ;
 log_message('UOM conversion error for item id '||item_eff.inventory_item_id ) ;
WHEN OTHERS THEN
  log_message('Error in procedure calc_lead_time'||SQLCODE||SQLERRM) ;

END calc_lead_time ;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    log_message                                                          |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|       06-Oct-2003 Abhay Satpute Created                                 |
REM+=========================================================================+
*/
PROCEDURE log_message(
  pbuff  VARCHAR2)
IS
BEGIN
     IF fnd_global.conc_request_id > 0  THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
     ELSE
         NULL;
     END IF;

  EXCEPTION
     WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.LOG, 'Error in log_message '||SQLERRM);
END log_message;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    time_stamp                                                           |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|       06-Oct-2003 Abhay Satpute Created                                 |
REM+=========================================================================+
*/
PROCEDURE time_stamp IS

cur_time VARCHAR2(25) := NULL ;

BEGIN
   SELECT TO_CHAR(SYSDATE,'DD-MON-RRRR HH24:MI:SS')
   INTO cur_time FROM sys.dual ;

log_message(cur_time);
EXCEPTION
WHEN OTHERS THEN
        log_message('Failure occured in time_stamp');
        log_message(SQLERRM);
RAISE;

END time_stamp ;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|            get_avg_working_hours                                        |
REM| DESCRIPTION                                                             |
REM|         This procedure gets the average working hours for a calendar.   |
REM| This value is used in computation of lead time of the item              |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|        01-July-2005     Abhay Satpute                                   |
REM+=========================================================================+
*/
FUNCTION get_avg_working_hours(p_calendar_code VARCHAR2)
RETURN NUMBER IS

TYPE ref_cursor_typ IS REF CURSOR;
cur_cal_work_ratio   ref_cursor_typ ;
cur_avg_work_hours   ref_cursor_typ ;
cur_tot_shft_days   ref_cursor_typ ;

l_work_hours    NUMBER ;
t_work_hours    NUMBER ;  /*B5146342*/
total_work_hours  NUMBER ;
l_tot_days    NUMBER ;
total_tot_days    NUMBER ;
l_work_ratio    NUMBER ;
l_calendar_code    VARCHAR2(10);
l_shift_num    NUMBER ;
ret_avg_work_hours  NUMBER ;
INVALID_CALENDAR  EXCEPTION ;

BEGIN
        l_work_hours    := 0 ;
        t_work_hours            := 0;
        total_work_hours  := 0 ;
        l_tot_days    := 0 ;
        total_tot_days    := 0 ;
        l_work_ratio    := 0 ;
        l_shift_num    := 0 ;
        ret_avg_work_hours  := 0 ;

        /*Computes the work ratio*/
        OPEN cur_cal_work_ratio FOR
                SELECT (SUM(days_on) + SUM(days_off) )/ SUM(days_on) work_ratio
                FROM bom_workday_patterns
                WHERE shift_num IS NULL
                AND calendar_code = p_calendar_code ;

        FETCH  cur_cal_work_ratio INTO l_work_ratio ;

        CLOSE cur_cal_work_ratio ;

        /*Computes the total work hours for the working days for all the shifts*/
        OPEN cur_avg_work_hours FOR
                SELECT
                p.calendar_code,
                p.shift_num,
                SUM(p.days_on *( (DECODE ((SIGN (st.to_time - st.from_time) ),-1,((86400-st.from_time)+st.to_time),(st.to_time-st.from_time)) ) / 3600 )) work_hrs
                FROM bom_workday_patterns p, bom_calendar_shifts s, bom_shift_times st
                WHERE p.calendar_code = s.calendar_code
                AND p.shift_num  = s.shift_num
                AND s.calendar_code = st.calendar_code
                AND s.shift_num = st.shift_num
                AND p.shift_num IS NOT NULL
                AND p.calendar_code = p_calendar_code
                GROUP BY p.calendar_code, p.shift_num;

        LOOP
                FETCH cur_avg_work_hours INTO l_calendar_code, l_shift_num, l_work_hours;
                EXIT WHEN  cur_avg_work_hours%NOTFOUND ;

                /*Computes the total days on and days off for a specific shift in the calendar */
                /*B5146342 - moved this cursor from outside to calculate appropriate work hours*/
                OPEN cur_tot_shft_days FOR
                        SELECT
                        (SUM(p.days_on) + SUM(p.days_off))  tot_days
                        FROM bom_workday_patterns p, bom_calendar_shifts s
                        WHERE p.calendar_code = s.calendar_code
                        AND p.shift_num  = l_shift_num
                        AND s.shift_num = p.shift_num
                        AND p.shift_num IS NOT NULL
                        AND p.calendar_code = l_calendar_code
                        GROUP BY p.calendar_code, p.shift_num;

                        FETCH cur_tot_shft_days INTO l_tot_days;
                        EXIT WHEN  cur_tot_shft_days%NOTFOUND ;

                CLOSE cur_tot_shft_days;

                t_work_hours := l_work_hours/l_tot_days; /*B5146342*/
                total_work_hours := total_work_hours + t_work_hours ;

        END LOOP ;

        CLOSE cur_avg_work_hours ;


        IF total_work_hours = 0 THEN
          ret_avg_work_hours := 0 ;
          RAISE INVALID_CALENDAR ;
        ELSE
          ret_avg_work_hours := total_work_hours * l_work_ratio ;  /*B5146342*/

                IF ret_avg_work_hours > 24 THEN
                   ret_avg_work_hours := 24;
                END IF;
        END IF ;

        RETURN ret_avg_work_hours ;

EXCEPTION
        WHEN INVALID_CALENDAR THEN RETURN 0 ;
        WHEN OTHERS THEN RETURN 0 ;

END get_avg_working_hours;

END gmp_lead_time_calculator_pkg ;


/
