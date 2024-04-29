--------------------------------------------------------
--  DDL for Package Body MRP_FLOW_DEMAND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_FLOW_DEMAND" AS
/* $Header: MRPFLOWB.pls 120.2 2005/06/30 05:14:04 gkooruve noship $ */

g_organization_id                    NUMBER;
g_planned_quantity                   NUMBER;
g_primary_item_id                    NUMBER;
g_quantity_completed                 NUMBER;
g_scheduled_completion_date          DATE;
g_scheduled_start_date               DATE;
g_wip_entity_id                      NUMBER;
g_RN                                 NUMBER;

g_wip_entity_id_arr                  NUMBER_ARR;

PROCEDURE Main_Flow_Demand( i_RN             IN NUMBER,
                            o_return_code    OUT NOCOPY NUMBER,
                            o_error_message  OUT NOCOPY VARCHAR2)
IS
sqls varchar2(100);
l_retval                        BOOLEAN;
l_applsys_schema                VARCHAR2(10);
dummy1                          VARCHAR2(10);
dummy2                          VARCHAR2(10);


lv_changed_job  		NUMBER;
lv_temp_sql_stmt   	VARCHAR2(2000);

BEGIN

     /* -----------------------------------------------
         Cleanup MRP_FLOW_DEMANDS data
     -------------------------------------------------*/

     l_retval := FND_INSTALLATION.GET_APP_INFO('MRP', dummy1, dummy2, l_applsys_schema);

     IF (i_RN = -1)  THEN
        -- complete refresh
        sqls := 'TRUNCATE TABLE '||l_applsys_schema||'.MRP_FLOW_DEMANDS';
        execute immediate sqls;
     ELSE
        DELETE FROM MRP_FLOW_DEMANDS
         WHERE wip_entity_id IN ( SELECT wip_entity_id
                                    FROM MRP_AD_FLOW_SCHDS
                                   WHERE RN= i_RN);
     END IF;

     COMMIT;

     /* -----------------------------------------------
         Execute bill and flow jobs changes
     -------------------------------------------------*/

     -- execute bill change for old jobs

     Get_Bill_Change( i_RN,
                      o_return_code,
                      o_error_message);

     -- performance fix for Bug 3550414.
     IF (i_RN <> -1)  THEN

       -- if jobs are affected by current bill changes
       IF (g_wip_entity_id_arr.COUNT <> 0 ) THEN

            lv_temp_sql_stmt :=   ' DELETE  /*+ parallel(mfd) */ '
                                ||' FROM MRP_FLOW_DEMANDS MFD '
                                ||' WHERE EXISTS (SELECT 1 '
                                ||' FROM MRP_SN_INV_COMPS MSIC '
                                ||' WHERE MSIC.RN = :i_RN'
                                ||' AND MSIC.BILL_SEQUENCE_ID = MFD.BILL_SEQUENCE_ID) ';

            EXECUTE IMMEDIATE lv_temp_sql_stmt USING  i_RN;

       END IF;

       -- if any of the existing jobs have changed
      lv_temp_sql_stmt := ' SELECT count(*)  '
                        ||' FROM MRP_SN_FLOW_SCHDS '
                        ||' WHERE RN >= :i_RN '
                        ||' AND PLANNED_QUANTITY > QUANTITY_COMPLETED ';


      EXECUTE IMMEDIATE lv_temp_sql_stmt
		  INTO lv_changed_job USING  i_RN;

       IF (lv_changed_job > 0 ) THEN

       			lv_temp_sql_stmt :=   ' DELETE FROM MRP_FLOW_DEMANDS MFD '
                                    ||' WHERE EXISTS (SELECT 1 FROM MRP_SN_FLOW_SCHDS MFS '
                                    ||' WHERE MFS.RN >= :i_RN '
                                    ||' AND MFS.PLANNED_QUANTITY > MFS.QUANTITY_COMPLETED '
                                    ||' AND MFS.WIP_ENTITY_ID = MFD.WIP_ENTITY_ID) ';

            EXECUTE IMMEDIATE lv_temp_sql_stmt USING  i_RN;

       END IF;

     END IF;

     COMMIT;

     -- updatinge old flow jobs and inserting new flow jobs
     Execute_Flow_Demand( i_RN,
                          o_return_code,
                          o_error_message);

     -- Execute Remained Bill Change JOBs

     Execute_Remained_JOBS(i_RN,
                          o_return_code,
                          o_error_message);

     g_wip_entity_id_arr.DELETE;


END Main_Flow_Demand;



PROCEDURE Get_Bill_Change( i_RN             IN NUMBER,
                           o_return_code    OUT NOCOPY NUMBER,
                           o_error_message  OUT NOCOPY VARCHAR2)
IS
/* THis is being commented for New Patching Strategy wherin this will be a dynamic clause
  CURSOR Bill_Change(i_RN_index IN NUMBER) IS
    SELECT DISTINCT
          BILL_SEQUENCE_ID
    FROM MRP_SN_INV_COMPS
    WHERE RN = i_RN_index
    ;
*/

  CURSOR WIP_FLOW_JOBS_AFFECTED(i_RN_index IN NUMBER, i_bill_sequence_id IN NUMBER) IS
    SELECT DISTINCT  -- for performance we can remove distinct
          wip_entity_id
    FROM MRP_FLOW_DEMANDS
    WHERE BILL_SEQUENCE_ID = i_bill_sequence_id;

 l_bill_sequence_id   NUMBER;
 l_wip_entity_id      NUMBER;
 l_index              NUMBER;
lv_cursor_stmt  VARCHAR2(5000);
TYPE CurTyp IS REF CURSOR;
 Bill_Change              CurTyp;




BEGIN

   IF (i_RN = -1) THEN
     -- we need not to perform bill on complete refresh mode.
     RETURN;
   END IF;

lv_cursor_stmt :=
'    SELECT /*+ index(bic bom_inv_comps_sn_n1) */ DISTINCT'
||'          BILL_SEQUENCE_ID '
||'    FROM MRP_SN_INV_COMPS bic'
||'    WHERE RN = '||i_RN;

  OPEN Bill_Change for lv_cursor_stmt;

  LOOP
    FETCH Bill_Change INTO
           l_bill_sequence_id;
    EXIT WHEN Bill_Change%NOTFOUND;

    OPEN WIP_FLOW_JOBS_AFFECTED(i_RN, l_bill_sequence_id);

    LOOP

        FETCH WIP_FLOW_JOBS_AFFECTED INTO
           l_wip_entity_id;
        EXIT WHEN WIP_FLOW_JOBS_AFFECTED%NOTFOUND;

        g_wip_entity_id_arr(l_wip_entity_id) := 1;

    END LOOP;

    CLOSE WIP_FLOW_JOBS_AFFECTED;

  END LOOP;

  CLOSE Bill_Change;

END;

PROCEDURE Execute_Remained_JOBS(i_RN        IN  NUMBER,
                           o_return_code    OUT NOCOPY NUMBER,
                           o_error_message  OUT NOCOPY VARCHAR2)

IS

l_index NUMBER;
lv_cursor_stmt varchar2(5000);

BEGIN


  IF (g_wip_entity_id_arr.COUNT = 0 ) THEN
      -- no old bills been affected by current bill changes
      RETURN;
  END IF;

  l_index := g_wip_entity_id_arr.FIRST;

  LOOP

      IF (g_wip_entity_id_arr(l_index) = 1) THEN

      -- get top flow job information

         BEGIN
/* THis is being commented for New Patching Strategy wherin this will be a dynamic clause
           SELECT
                ORGANIZATION_ID,
                PLANNED_QUANTITY,
                PRIMARY_ITEM_ID,
                QUANTITY_COMPLETED,
                SCHEDULED_COMPLETION_DATE,
                SCHEDULED_START_DATE,
                WIP_ENTITY_ID,
                i_RN
           INTO
                g_organization_id,
                g_planned_quantity,
                g_primary_item_id,
                g_quantity_completed,
                g_scheduled_completion_date,
                g_scheduled_start_date,
                g_wip_entity_id,
                g_RN
           FROM MRP_SN_FLOW_SCHDS
           WHERE wip_entity_id = l_index
             AND PLANNED_QUANTITY > QUANTITY_COMPLETED;
*/

lv_cursor_stmt :=
'            SELECT'
||'                 ORGANIZATION_ID,'
||'                 PLANNED_QUANTITY,'
||'                 PRIMARY_ITEM_ID,'
||'                 QUANTITY_COMPLETED,'
||'                 SCHEDULED_COMPLETION_DATE,'
||'                 SCHEDULED_START_DATE,'
||'                 WIP_ENTITY_ID,'
||                 i_RN
||'            FROM MRP_SN_FLOW_SCHDS'
||'            WHERE wip_entity_id = '||l_index
||'              AND PLANNED_QUANTITY > QUANTITY_COMPLETED';

        EXECUTE IMMEDIATE lv_cursor_stmt
           INTO
                g_organization_id,
                g_planned_quantity,
                g_primary_item_id,
                g_quantity_completed,
                g_scheduled_completion_date,
                g_scheduled_start_date,
                g_wip_entity_id,
                g_RN;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
           WHEN OTHERS THEN RAISE;
        END;

        IF SQL%ROWCOUNT > 0 THEN

           ReExplode_Flow_Demands(o_return_code,
                                  o_error_message);
        END IF;

       END IF;

       EXIT WHEN l_index = g_wip_entity_id_arr.LAST;
       l_index := g_wip_entity_id_arr.NEXT(l_index);

  END LOOP;


END;

PROCEDURE Execute_Flow_Demand( i_RN             IN NUMBER,
                               o_return_code    OUT NOCOPY NUMBER,
                               o_error_message  OUT NOCOPY VARCHAR2)  IS
/*
  CURSOR FLOW_SCHDS(i_RN_index IN NUMBER) IS
    SELECT
           ORGANIZATION_ID,
           PLANNED_QUANTITY,
           PRIMARY_ITEM_ID,
           QUANTITY_COMPLETED,
           SCHEDULED_COMPLETION_DATE,
           SCHEDULED_START_DATE,
           WIP_ENTITY_ID,
           RN
      FROM MRP_SN_FLOW_SCHDS
     WHERE RN >= i_RN_index
       AND PLANNED_QUANTITY > QUANTITY_COMPLETED;
*/
    lv_cursor_stmt varchar2(5000);
    l_job_status    NUMBER;
TYPE CurTyp IS REF CURSOR;
FLOW_SCHDS              CurTyp;

BEGIN
lv_cursor_stmt :=
'  SELECT'
||'           ORGANIZATION_ID,'
||'           PLANNED_QUANTITY,'
||'           PRIMARY_ITEM_ID,'
||'           QUANTITY_COMPLETED,'
||'           SCHEDULED_COMPLETION_DATE,'
||'           SCHEDULED_START_DATE,'
||'           WIP_ENTITY_ID,'
||'           RN'
||'      FROM MRP_SN_FLOW_SCHDS'
||'     WHERE RN >= '||i_RN
||'       AND PLANNED_QUANTITY > QUANTITY_COMPLETED';

  OPEN FLOW_SCHDS for lv_cursor_stmt;

  LOOP
    FETCH FLOW_SCHDS INTO
           g_organization_id,
           g_planned_quantity,
           g_primary_item_id,
           g_quantity_completed,
           g_scheduled_completion_date,
           g_scheduled_start_date,
           g_wip_entity_id,
           g_RN;

    EXIT WHEN FLOW_SCHDS%NOTFOUND;

             IF (i_RN = -1) THEN
                Explode_Flow_Demands(    o_return_code,
                                         o_error_message);
             ELSE
                ReExplode_Flow_Demands(  o_return_code,
                                         o_error_message);

             /* remove the IF clause, if the g_wip_entity_id is not
                in the array, it will cause ORA-1403 error.

                  IF g_wip_entity_id_arr(g_wip_entity_id) = 1 THEN
                     g_wip_entity_id_arr(g_wip_entity_id) := 0;
                  END IF; */

               g_wip_entity_id_arr(g_wip_entity_id) := 0;

             END IF;

    END LOOP;

    CLOSE FLOW_SCHDS;

END Execute_Flow_Demand;


PROCEDURE Explode_Flow_Demands(    o_return_code    OUT NOCOPY NUMBER,
                                   o_error_message  OUT NOCOPY VARCHAR2)  IS

  parent_item       parent_item_type;
  o_phantom_items   parent_item_type;
  l_level           NUMBER   := 0;    -- top item level = 0

BEGIN

  parent_item.inventory_item_id(1) := g_primary_item_id;
  parent_item.quantity_completed(1) := g_quantity_completed;
  parent_item.planned_quantity(1) := g_planned_quantity;

  LOOP
     Insert_Demands(parent_item,
                    l_level,
                    o_return_code,
                    o_error_message);
     IF (o_return_code = 0) THEN
        RETURN;
     END IF;
     Get_Phantoms(parent_item,
                  o_phantom_items,
                  o_return_code,
                  o_error_message);

     IF (o_return_code = 0) THEN
        RETURN;
     END IF;


     EXIT WHEN o_phantom_items.inventory_item_id.COUNT <= 0;

     parent_item := o_phantom_items;
     l_level := l_level + 1;

  END LOOP;

END Explode_Flow_Demands;


PROCEDURE  ReExplode_Flow_Demands(o_return_code   OUT NOCOPY NUMBER,
                                  o_error_message    OUT NOCOPY VARCHAR2)
IS

BEGIN

      -- delete old demand
      -- performance fix for Bug 3550414.
      -- DELETE MRP_FLOW_DEMANDS
      -- WHERE wip_entity_id = g_wip_entity_id;


      -- insert demand for new bill

      Explode_Flow_Demands(    o_return_code,
                               o_error_message);


END;


PROCEDURE Get_Phantoms(i_parent_items       IN parent_item_type,
                       o_phantom_items      OUT NOCOPY parent_item_type,
                       o_return_code        OUT NOCOPY NUMBER,
                       o_error_message      OUT NOCOPY VARCHAR2)
IS
TYPE CurTyp IS REF CURSOR;
get_phantom_items CurTyp;
/* THis will be a dynamic clause in New Patching Strategy
   CURSOR get_phantom_items(i_parent_item IN NUMBER) IS
   SELECT
      bic.component_item_id,
      bic.component_quantity
   FROM
      MRP_SN_BOMS bom,
      MRP_SN_INV_COMPS bic
   WHERE
          bom.assembly_item_id = i_parent_item
   AND    bom.organization_id = g_organization_id
   AND    bom.alternate_bom_designator IS NULL    --- primary bill
   AND    bic.bill_sequence_id = bom.common_bill_sequence_id
   AND    bic.effectivity_date < g_scheduled_completion_date
   AND    NVL(bic.disable_date, g_scheduled_completion_date + 1)
                              > g_scheduled_completion_date
   AND    bic.WIP_SUPPLY_TYPE = 6;
*/

  l_j                  NUMBER;
  l_out_index          NUMBER;
  l_inventory_item_id  NUMBER;
  l_component_qty      NUMBER;
  l_phantom_items      parent_item_type;
  lv_cursor_stmt varchar2(5000);
   lv_date varchar2(20);

BEGIN

  l_j := i_parent_items.inventory_item_id.FIRST;
  l_out_index := 1;
  lv_date := g_scheduled_completion_date;

       lv_cursor_stmt :=
'   SELECT'
||'      bic.component_item_id,'
||'      bic.component_quantity'
||'   FROM'
||'      MRP_SN_BOMS bom,'
||'      MRP_SN_INV_COMPS bic,'
||'      MTL_SYSTEM_ITEMS msi1,'
||'      MTL_SYSTEM_ITEMS msi2'
||'   WHERE'
||'          bom.assembly_item_id = :inventory_item_id'
||'   AND    bom.organization_id = :organization_id'
||'   AND    msi1.inventory_item_id = bom.assembly_item_id'
||'   AND    msi1.organization_id = bom.organization_id'
||'   AND    bom.alternate_bom_designator IS NULL '
||'   AND    bic.bill_sequence_id = bom.common_bill_sequence_id'
||'   AND    bic.effectivity_date < :g_scheduled_completion_date '
||'   AND    NVL(bic.disable_date, :g_scheduled_completion_date + 1) '
||'                              > :g_scheduled_completion_date '
||'   AND    bic.WIP_SUPPLY_TYPE = 6'
||'   AND    msi2.inventory_item_id = bic.component_item_id'
||'   AND    msi2.organization_id = msi1.organization_id'
||'   AND NOT (msi1.AUTO_CREATED_CONFIG_FLAG=''Y'' and msi1.base_item_id is NOT NULL'
||'             and (msi2.BOM_ITEM_TYPE = 1 OR msi2.BOM_ITEM_TYPE = 2))';

  LOOP

       OPEN get_phantom_items for lv_cursor_stmt USING
                                    i_parent_items.inventory_item_id(l_j),
                                    g_organization_id,
                                    g_scheduled_completion_date,
                                    g_scheduled_completion_date,
                                    g_scheduled_completion_date;

       LOOP
          FETCH get_phantom_items INTO
             l_inventory_item_id,
             l_component_qty;
          EXIT WHEN get_phantom_items%NOTFOUND;

          l_phantom_items.inventory_item_id(l_out_index)
                 := l_inventory_item_id;
          l_phantom_items.planned_quantity(l_out_index)
                 := l_component_qty * i_parent_items.planned_quantity(l_j);
          l_phantom_items.quantity_completed(l_out_index)
                 := l_component_qty * i_parent_items.quantity_completed(l_j);

          l_out_index:= l_out_index+1;

       END LOOP;

       CLOSE get_phantom_items;

       EXIT WHEN l_j = i_parent_items.inventory_item_id.LAST;
       l_j:= i_parent_items.inventory_item_id.NEXT(l_j);

  END LOOP;

  o_phantom_items := l_phantom_items;

END;



PROCEDURE Insert_Demands(i_parent_items     IN  PARENT_ITEM_TYPE,
                         i_level            IN  NUMBER,
                       o_return_code        OUT NOCOPY NUMBER,
                       o_error_message      OUT NOCOPY VARCHAR2)  IS

TYPE CurTyp IS REF CURSOR;
lv_ins CurTyp;
  l_index  NUMBER;
   lv_cursor_stmt varchar2(5000);
       lv_organization_id mrp_flow_demands.organization_id%TYPE;
       lv_planned_quantity mrp_flow_demands.planned_quantity%TYPE;
       lv_primary_item_id mrp_flow_demands.primary_item_id%TYPE;
       lv_quantity_completed mrp_flow_demands.quantity_completed%TYPE;
       lv_scheduled_comp_date mrp_flow_demands.scheduled_completion_date%TYPE;
       lv_scheduled_start_date mrp_flow_demands.scheduled_start_date%TYPE;
       lv_wip_entity_id mrp_flow_demands.wip_entity_id%TYPE;
       lv_plan_level mrp_flow_demands.plan_level%TYPE;
       lv_wip_supply_type  mrp_flow_demands.wip_supply_type%TYPE;
       lv_bill_sequence_id   mrp_flow_demands.bill_sequence_id%TYPE;
       lv_RN mrp_flow_demands.rn%TYPE;

TYPE NumTblTyp        IS TABLE OF NUMBER;
TYPE DateTblTyp       IS TABLE OF DATE;

lv_organization_id_tab              NumTblTyp := NumTblTyp();
lv_planned_quantity_tab             NumTblTyp := NumTblTyp();
lv_primary_item_id_tab              NumTblTyp := NumTblTyp();
lv_quantity_completed_tab           NumTblTyp := NumTblTyp();
lv_scheduled_comp_date_tab          DateTblTyp := DateTblTyp();
lv_scheduled_start_date_tab         DateTblTyp := DateTblTyp();
lv_wip_entity_id_tab                NumTblTyp := NumTblTyp();
lv_plan_level_tab                   NumTblTyp := NumTblTyp();
lv_wip_supply_type_tab              NumTblTyp := NumTblTyp();
lv_bill_sequence_id_tab             NumTblTyp := NumTblTyp();
l_count                             PLS_INTEGER;

BEGIN

  l_index := i_parent_items.inventory_item_id.FIRST;


  LOOP
l_count := 0;

lv_cursor_stmt :=
'     SELECT :g_organization_id '
||'       ,bic.component_quantity * :parent_planned_quantity,'
||'       bic.Component_Item_ID,  '
||'       bic.component_quantity * :parent_quantity_completed,'
||'      :g_scheduled_completion_date,'
||'      :g_scheduled_start_date,'
||'      :g_wip_entity_id,'
||'      :i_level,'
||'       bic.WIP_SUPPLY_TYPE, '
||'       bom.bill_sequence_id,'
||'       :g_RN '
||'     FROM'
||'        MRP_SN_BOMS bom,'
||'        MRP_SN_INV_COMPS bic'
||'     WHERE'
||'            bom.assembly_item_id = :parent_inventory_item_id'
||'     AND    bom.organization_id = :g_organization_id'
||'     AND    bom.alternate_bom_designator IS NULL'
||'     AND    bic.bill_sequence_id = bom.common_bill_sequence_id'
||'     AND    bic.effectivity_date < :g_scheduled_completion_date'
||'     AND    NVL(bic.disable_date, :g_scheduled_completion_date + 1) '
||'                                > :g_scheduled_completion_date '
||'     AND    bic.wip_supply_type <> 6';

       OPEN lv_ins for lv_cursor_stmt USING
                                            g_organization_id,
                                            i_parent_items.planned_quantity(l_index),
                                            i_parent_items.quantity_completed(l_index),
                                            g_scheduled_completion_date,
                                            g_scheduled_start_date,
                                            g_wip_entity_id,
                                            i_level,
                                            g_RN,
                                            i_parent_items.inventory_item_id(l_index),
                                            g_organization_id,
                                            g_scheduled_completion_date,
                                            g_scheduled_completion_date,
                                            g_scheduled_completion_date;
       LOOP

     FETCH lv_ins INTO
      lv_organization_id,
      lv_planned_quantity,
      lv_primary_item_id,
      lv_quantity_completed,
      lv_scheduled_comp_date,
      lv_scheduled_start_date,
      lv_wip_entity_id,
      lv_plan_level,
      lv_wip_supply_type,
      lv_bill_sequence_id,
      lv_RN;

      EXIT WHEN lv_ins%NOTFOUND;

      l_count := l_count+1;

        lv_organization_id_tab.EXTEND(1);
        lv_planned_quantity_tab.EXTEND(1);
        lv_primary_item_id_tab.EXTEND(1);
        lv_quantity_completed_tab.EXTEND(1);
        lv_scheduled_comp_date_tab.EXTEND(1);
        lv_scheduled_start_date_tab.EXTEND(1);
        lv_wip_entity_id_tab.EXTEND(1);
        lv_plan_level_tab.EXTEND(1);
        lv_wip_supply_type_tab.EXTEND(1);
        lv_bill_sequence_id_tab.EXTEND(1);


        lv_organization_id_tab(l_count)                     := lv_organization_id;
        lv_planned_quantity_tab(l_count)                    := lv_planned_quantity;
        lv_primary_item_id_tab(l_count)                     := lv_primary_item_id;
        lv_quantity_completed_tab(l_count)                  := lv_quantity_completed;
        lv_scheduled_comp_date_tab(l_count)                 := lv_scheduled_comp_date;
        lv_scheduled_start_date_tab(l_count)                := lv_scheduled_start_date;
        lv_wip_entity_id_tab(l_count)                       := lv_wip_entity_id;
        lv_plan_level_tab(l_count)                          := lv_plan_level;
        lv_wip_supply_type_tab(l_count)                     := lv_wip_supply_type;
        lv_bill_sequence_id_tab(l_count)                    := lv_bill_sequence_id;




        END LOOP;

        FORALL k IN 1..lv_organization_id_tab.count
        INSERT INTO MRP_FLOW_DEMANDS(
            organization_id,
            planned_quantity,
            primary_item_id,
            quantity_completed,
            scheduled_completion_date,
            scheduled_start_date,
            wip_entity_id,
            plan_level,
            wip_supply_type,
            bill_sequence_id,  -- bill identifier
            RN)
        VALUES(
            lv_organization_id_tab(k),
            lv_planned_quantity_tab(k),
            lv_primary_item_id_tab(k),
            lv_quantity_completed_tab(k),
            lv_scheduled_comp_date_tab(k),
            lv_scheduled_start_date_tab(k),
            lv_wip_entity_id_tab(k),
            lv_plan_level_tab(k),
            lv_wip_supply_type_tab(k),
            lv_bill_sequence_id_tab(k),
            lv_RN);

       EXIT WHEN l_index = i_parent_items.inventory_item_id.LAST;
       l_index := i_parent_items.inventory_item_id.NEXT(l_index);

  END LOOP;





/* This is to be made a dynamic query for New Patching Strategy
     INSERT INTO MRP_FLOW_DEMANDS(
       organization_id,
       planned_quantity,
       primary_item_id,
       quantity_completed,
       scheduled_completion_date,
       scheduled_start_date,
       wip_entity_id,
       plan_level,
       wip_supply_type,
       bill_sequence_id,  -- bill identifier
       RN)
     SELECT
       g_organization_id,
       bic.component_quantity * i_parent_items.planned_quantity(l_index),
       bic.Component_Item_ID,  -- i_parent_items.inventory_item_id(l_index)
       bic.component_quantity * i_parent_items.quantity_completed(l_index),
       g_scheduled_completion_date,
       g_scheduled_start_date,
       g_wip_entity_id,
       i_level,
       bic.WIP_SUPPLY_TYPE,
       bom.bill_sequence_id,
       g_RN
     FROM
        MRP_SN_BOMS bom,
        MRP_SN_INV_COMPS bic
     WHERE
            bom.assembly_item_id = i_parent_items.inventory_item_id(l_index)
     AND    bom.organization_id = g_organization_id
     AND    bom.alternate_bom_designator IS NULL
     AND    bic.bill_sequence_id = bom.common_bill_sequence_id
     AND    bic.effectivity_date < g_scheduled_completion_date
     AND    NVL(bic.disable_date, g_scheduled_completion_date + 1)
                                > g_scheduled_completion_date
     AND    bic.wip_supply_type <> 6;
 */




END Insert_Demands;


END MRP_FLOW_DEMAND;

/
