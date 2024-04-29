--------------------------------------------------------
--  DDL for Package Body INV_MWB_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MWB_TREE" AS
/* $Header: INVMWBTB.pls 120.0.12000000.2 2007/10/11 21:12:28 musinha ship $ */


  -- Controlled: 0 Don't Care, 1 No, 2 Yes
  -- Add organization nodes for the given parameters


  /*procedure trace1( a in varchar2 default null, b in varchar2 default null,c number default null) is
  begin
     IF (length(b||a) < 4000) THEN
        insert into amintemp1 VALUES (b || a);
     END IF;
     COMMIT;
  end; */


  PROCEDURE add_orgs(
    p_organization_id     IN            NUMBER DEFAULT NULL
  , p_subinventory_code   IN            VARCHAR2 DEFAULT NULL
  , p_locator_id          IN            NUMBER DEFAULT NULL
  , p_inventory_item_id   IN            NUMBER DEFAULT NULL
  , p_revision            IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_from     IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_to       IN            VARCHAR2 DEFAULT NULL
  , p_lot_controlled      IN            NUMBER DEFAULT 0
  , p_serial_number_from  IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_to    IN            VARCHAR2 DEFAULT NULL
  , p_serial_controlled   IN            NUMBER DEFAULT 0
  , p_lpn_from            IN            VARCHAR2 DEFAULT NULL
  , p_lpn_to              IN            VARCHAR2 DEFAULT NULL
  , p_containerized       IN            NUMBER DEFAULT 0
  , p_prepacked           IN            NUMBER DEFAULT NULL  --Bug # 3581090
  , p_cost_group_id       IN            NUMBER DEFAULT NULL
  , p_status_id           IN            NUMBER DEFAULT NULL
  , p_lot_attr_query      IN            VARCHAR2 DEFAULT NULL
  , p_mln_context_code    IN            VARCHAR2 DEFAULT NULL
  , p_project_id          IN            NUMBER DEFAULT NULL
  , p_task_id             IN            NUMBER DEFAULT NULL
  , p_unit_number         IN            VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode     IN            NUMBER DEFAULT NULL
  , p_planning_query_mode IN            NUMBER DEFAULT NULL
  , p_owning_org          IN            NUMBER DEFAULT NULL
  , p_planning_org        IN            NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query   IN            VARCHAR2 DEFAULT NULL
  , p_node_state          IN            NUMBER
  , p_node_high_value     IN            NUMBER
  , p_node_low_value      IN            NUMBER
  , p_sub_type            IN            NUMBER DEFAULT NULL --RCVLOCATORSSUPPORT
  --ER(3338592) Changes
  , p_item_description    IN            VARCHAR2 DEFAULT NULL
  , p_qty_from            IN            NUMBER   DEFAULT NULL
  , p_qty_to              IN            NUMBER   DEFAULT NULL
  , p_detailed            IN            NUMBER   DEFAULT 0  -- Bug #3412002
  --End of ER Changes
  , p_view_by             IN            VARCHAR2 DEFAULT NULL
  , p_responsibility_id   IN            NUMBER   DEFAULT NULL
  , p_resp_application_id IN            NUMBER   DEFAULT NULL
  , x_node_value          IN OUT NOCOPY NUMBER
  , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index           IN OUT NOCOPY NUMBER
   -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL

  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  ) IS
    query_str      VARCHAR2(10000);
    query_hdl      NUMBER;
    rows_processed NUMBER;
    org_id         mtl_onhand_quantities.organization_id%TYPE;
    org_code       mtl_parameters.organization_code%TYPE;
    i              NUMBER                                       := x_tbl_index;
    j              NUMBER                                       := x_node_value;
    table_required VARCHAR2(300);
    is_grade_t     BOOLEAN DEFAULT FALSE ; -- NSRIVAST, INVCONV
    --ER(3338592) Changes
    group_str      VARCHAR2(10000) ;
    having_str     VARCHAR2(10000) := ' HAVING 1=1 ';
    --End of ER Changes

  BEGIN
    -- If attributes relating to contents of an LPN are not specified then
    -- display all the LPNs in that location with the appropriate from
    -- and to LPN criteria

   -- NSRIVAST, INVCONV, Start
      IF  (p_grade_from IS NOT NULL OR p_grade_code IS NOT NULL OR p_grade_controlled <> 0) THEN
             is_grade_t     := TRUE ;
      END IF ;
   -- NSRIVAST, INVCONV, End

    IF p_inventory_item_id IS NULL
       AND p_revision IS NULL
       AND p_lot_number_from IS NULL
       AND p_lot_number_to IS NULL
       AND p_serial_number_from IS NULL
       AND p_serial_number_to IS NULL
       AND p_serial_controlled = 0   -- Bug #3411938
       AND p_lot_controlled = 0
       AND p_cost_group_id IS NULL
       AND p_status_id IS NULL
       AND p_lot_attr_query IS NULL
       AND p_serial_attr_query IS NULL
       AND p_unit_number IS NULL
       AND p_project_id IS NULL
       AND p_task_id IS NULL
       AND p_planning_org IS NULL
       AND p_owning_org IS NULL
       AND( nvl(p_prepacked,1) <> 1
           OR p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL)
       --ER(3338592) Changes
       AND p_item_description IS NULL
       AND p_qty_from         IS NULL
       AND p_qty_to           IS NULL THEN
      --End of ER Changes
      query_str  := 'SELECT mp.organization_id, mp.organization_code  ';
      query_str  := query_str || 'from mtl_parameters mp where organization_id in ';
      query_str  := query_str || '(select organization_id ';
      query_str  := query_str || 'FROM wms_license_plate_numbers WHERE 1=1 ';

      IF p_sub_type = 2 THEN
        query_str  := query_str || ' AND lpn_context = 3 ';
      ELSIF p_prepacked IS NULL THEN
        query_str  := query_str || ' AND (lpn_context=1  or lpn_context=9 or lpn_context=11) ';
      ELSIF p_prepacked = 1 THEN
        query_str  := query_str || ' AND (lpn_context = 1) ';
      ELSIF p_prepacked <> 1
            AND p_prepacked <> 999
            AND p_prepacked IS NOT NULL THEN
        query_str  := query_str || ' AND lpn_context = :prepacked ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || ' AND locator_id = :loc_id ';
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || ' AND subinventory_code = :sub ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || ' AND organization_id = :org_id ';
      END IF;

      --bugfix#3646484
      IF ((p_lpn_from IS NOT NULL) AND (p_lpn_to IS NOT NULL) AND (p_lpn_from = p_lpn_to))  THEN
      --User is querying for single LPN so converted the range query to equality query
         query_str := query_str || 'and license_plate_number = :lpn_f ';
      ELSE
         IF p_lpn_from IS NOT NULL THEN
           query_str  := query_str || 'and license_plate_number >= :lpn_f ';
         END IF;

         IF p_lpn_to IS NOT NULL THEN
           query_str  := query_str || 'and license_plate_number <= :lpn_t ';
         END IF;
      END IF;

      query_str  := query_str || ') ORDER BY organization_code ';
    ELSE
      query_str  := ' SELECT mp.organization_id, mp.organization_code FROM mtl_parameters mp ';
      query_str  := query_str || ' WHERE exists ( ';

      -- Need to use MTL_ONHAND_TOTAL_V
      IF (
          p_serial_number_from IS NULL
          AND p_serial_number_to IS NULL
          AND p_unit_number IS NULL
          AND p_status_id IS NULL
          AND p_lpn_from IS NULL
          AND p_lpn_to IS NULL
          AND nvl(p_prepacked,1) = 1
          AND p_serial_attr_query IS NULL
         ) THEN
        IF p_sub_type = 2 THEN
          table_required  := ' mtl_rcv_mwb_onhand_v ';
        ELSIF(p_status_id IS NULL) THEN
          table_required  := ' mtl_onhand_total_mwb_v ';
             IF is_grade_t = TRUE THEN                       -- NSRIVAST, INVCONV
             table_required  := ' mtl_onhand_total_v ';  -- NSRIVAST, INVCONV
             END IF;
        ELSE
          table_required  := ' mtl_onhand_total_v ';
        END IF;

        IF p_lot_attr_query IS NULL THEN
          query_str  := query_str || 'SELECT organization_id from ' || table_required;
          query_str  := query_str || 'WHERE 1=1 ';
        ELSE
          query_str  :=
                query_str
             || ' SELECT organization_id from'
             || ' (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ' ) mln, '
             || table_required;
          query_str  := query_str || ' WHERE mln.lot_num = lot_number ';
        END IF;

        --ER(3338592) Changes (If the user gives the value for the Qty then only
        --Group by clause comes in to effect)

        IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
           group_str := ' GROUP BY  organization_id  ';
        END IF;

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || ' AND subinventory_code = :sub ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , subinventory_code  ' ;
          END IF;
        END IF;

        IF p_subinventory_code IS NULL AND p_detailed = 1 THEN   --Bug # 3412002
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , subinventory_code  ' ;
          END IF;
        END IF;

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || ' AND locator_id = :loc_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , locator_id  ' ;
          END IF;
        END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_locator_id IS NULL AND p_detailed = 1 THEN  --Bug # 3412002
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , locator_id  ' ;
          END IF;
        END IF;

        IF p_project_id IS NOT NULL THEN
          query_str  := query_str || ' AND project_id = :pr_id ';
           --ER(3338592) Changes
           IF group_str IS NOT NULL THEN
              group_str := group_str || ' , project_id  ' ;
           END IF;
        END IF;

        IF p_task_id IS NOT NULL THEN
          query_str  := query_str || ' AND task_id = :ta_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , p_task_id  ' ;
          END IF;
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || ' AND inventory_item_id = :item_id ';
        END IF;

        --Bug # 3411938
        IF (p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL)
          AND (NVL(p_view_by,' ') NOT IN ('LOT' , 'SERIAL'))  THEN
           group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
        END IF;

        --ER(3338592) Changes
        IF p_item_description IS NOT NULL THEN
           query_str := query_str || ' AND item_description LIKE :item_description ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || ' AND revision = :rev ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , revision  ' ;
          END IF;
        END IF;

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || ' AND cost_group_id = :cg_id ';
          --End of ER Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , cost_group_id  ' ;
          END IF;
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || ' AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || ' AND lot_number <= :lot_t ';
        END IF;

        IF p_lot_controlled = 2 THEN
          query_str  := query_str ||  ' AND lot_number is not null ';
        ELSIF p_lot_controlled = 1 THEN
          query_str  := query_str || ' AND lot_number is null ';
        END IF;

        IF p_status_id IS NOT NULL THEN
          query_str  := query_str || ' AND (subinventory_status_id = :st_id ';
          query_str  := query_str || ' OR locator_status_id = :st_id OR lot_status_id = :st_id) ';
        END IF;

        IF p_containerized = 1 THEN
          query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
        ELSIF p_containerized = 2 THEN
          query_str  := query_str || ' AND containerized_flag = 1 ';
        END IF;

        IF p_serial_controlled = 1 THEN
          --query_str  := query_str || 'AND serial_number_control_code not in (2,5) ';
          query_str  := query_str || ' AND item_serial_control not in (2,5) ';
        ELSIF p_serial_controlled = 2 THEN
          --query_str  := query_str || 'AND serial_number_control_code in (2,5) ';
          query_str  := query_str || ' AND item_serial_control in (2,5) ';
        END IF;

        IF (p_planning_query_mode = 4) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 2 ';
        ELSIF(p_planning_query_mode = 3) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        ELSIF(p_planning_query_mode = 2) THEN
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        END IF;

        IF (p_owning_qry_mode = 4) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 2 ';
        ELSIF(p_owning_qry_mode = 3) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        ELSIF(p_owning_qry_mode = 2) THEN
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        END IF;

        --Bug #3411938
        IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
           group_str := group_str || ' , planning_organization_id, planning_tp_type ';
           group_str := group_str || ' , owning_organization_id, owning_tp_type ';
           group_str := group_str || ' , item_lot_control, item_serial_control ';
        END IF;

        IF p_qty_from IS NOT NULL THEN
           having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
        END IF;

        IF p_qty_to IS NOT NULL THEN
           having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
        END IF;

        IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
          query_str := query_str || ' AND organization_id = mp.organization_id  ';
          query_str := query_str || group_str || having_str || ' ) ' ;
        ELSE
          query_str := query_str || ' AND organization_id = mp.organization_id ) ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'and mp.organization_id = :org_id ';
        --Bug #3411938
        ELSE
          query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
          query_str  := query_str || ' FROM org_access_view oav ' ;
          query_str  := query_str || ' WHERE oav.organization_id = mp.organization_id ' ;
          query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
          query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
        END IF;

        query_str  := query_str || ' ORDER BY organization_code ';

      --Need to use MTL_ONHAND_SERIAL_V

      ELSIF(
            (
             p_serial_number_from IS NOT NULL
             OR p_serial_number_from IS NOT NULL
             OR p_serial_attr_query IS NOT NULL
             OR p_unit_number IS NOT NULL
            )
            AND p_lpn_from IS NULL
            AND p_lpn_to IS NULL
            AND nvl(p_prepacked,1) = 1
           ) THEN
        IF p_sub_type = 2 THEN
          table_required  := ' mtl_rcv_serial_oh_v ';
        ELSIF(p_status_id IS NULL) THEN
          table_required  := ' mtl_onhand_serial_mwb_v ';
            IF is_grade_t = TRUE THEN                       -- NSRIVAST, INVCONV
               table_required  := ' mtl_onhand_serial_v ';  -- NSRIVAST, INVCONV
            END IF ;
        ELSE
          table_required  := ' mtl_onhand_serial_v ';
        END IF;

        IF p_lot_attr_query IS NULL
           AND p_serial_attr_query IS NULL THEN
          query_str  := query_str || ' SELECT organization_id from ' || table_required;
          query_str  := query_str || ' WHERE 1=1 ';
        ELSIF p_lot_attr_query IS NULL
              AND p_serial_attr_query IS NOT NULL THEN
          query_str  :=
                query_str
             || ' SELECT organization_id from'
             || ' (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
             || p_serial_attr_query
             || ') msn, '
             || table_required;
          query_str  := query_str || ' WHERE msn.serial_num = serial_number ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NULL THEN
          query_str  :=
                query_str
             || ' SELECT organization_id from'
             || ' (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ' ) mln, '
             || table_required;
          query_str  := query_str || ' WHERE mln.lot_num = lot_number ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NOT NULL THEN
          query_str  :=
                query_str
             || ' SELECT organization_id from'
             || ' (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ' ) mln, '
             || ' (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
             || p_serial_attr_query
             || ' ) msn, '
             || table_required;
          query_str  := query_str || ' WHERE mln.lot_num = lot_number ';
          query_str  := query_str || ' AND msn.serial_num = serial_number ';
        END IF;

        --ER(3338592) Changes (If the user gives the value for the Qty then only
        --Group by clause comes in to effect)

        IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
           group_str := ' GROUP BY  organization_id ';
        END IF;

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || ' AND subinventory_code = :sub ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , subinventory_code  ' ;
          END IF;
        END IF;

        IF p_subinventory_code IS NULL AND p_detailed = 1 THEN   --Bug # 3412002
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , subinventory_code  ' ;
          END IF;
        END IF;

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || ' AND locator_id = :loc_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || '  , locator_id  ' ;
          END IF;
        END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_locator_id IS NULL AND p_detailed = 1 THEN  --Bug # 3412002
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , locator_id  ' ;
          END IF;
        END IF;

        IF p_project_id IS NOT NULL THEN
          query_str  := query_str || ' AND project_id = :pr_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , project_id  ' ;
          END IF;
        END IF;

        IF p_task_id IS NOT NULL THEN
          query_str  := query_str || ' AND task_id = :ta_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , p_task_id  ' ;
          END IF;
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || ' AND inventory_item_id = :item_id ';
        END IF;

        --Bug # 3411938
        IF (p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL)
          AND (NVL(p_view_by,' ') NOT IN ('LOT' , 'SERIAL'))  THEN
           group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
        END IF;

        --ER(3338592) Changes
        IF p_item_description IS NOT NULL THEN
           query_str := query_str || ' AND item_description LIKE :item_description ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || ' AND revision = :rev ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , revision  ' ;
          END IF;
        END IF;

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || ' AND cost_group_id = :cg_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , cost_group_id  ' ;
          END IF;
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || ' AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || ' AND lot_number <= :lot_t ';
        END IF;

        IF p_serial_number_from IS NOT NULL THEN
          query_str  := query_str || ' AND serial_number >= :serial_f ';
        END IF;

        IF p_serial_number_to IS NOT NULL THEN
          query_str  := query_str || ' AND serial_number <= :serial_t ';
        END IF;

        IF p_unit_number IS NOT NULL THEN
          query_str  := query_str || ' AND unit_number=:un_id ';
        END IF;

        IF p_status_id IS NOT NULL
           AND p_sub_type <> 2 THEN
          query_str  := query_str || ' AND (subinventory_status_id = :st_id OR locator_status_id = :st_id ';
          query_str  := query_str || ' OR lot_status_id = :st_id OR serial_status_id = :st_id) ';
        END IF;

        IF p_lot_controlled = 2 THEN
          query_str  := query_str || ' AND lot_number is not null ';
        ELSIF p_lot_controlled = 1 THEN
          query_str  := query_str || ' AND lot_number is null ';
        END IF;

        IF p_containerized = 1 THEN
          query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
        ELSIF p_containerized = 2 THEN
          query_str  := query_str || ' AND containerized_flag = 1 ';
        END IF;

        /*IF p_site_id IS NOT NULL THEN
           query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND planning_organization_id = :site_id ' ;
         ELSIF p_vendor_id is NOT NULL THEN
           query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND  planning_organization_id in ';
           query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
           query_str := query_str || '  where vendor_id = :vendor_id )';
        END IF;*/

        IF (p_owning_qry_mode = 4) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 2 ';
        ELSIF(p_owning_qry_mode = 3) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        ELSIF(p_owning_qry_mode = 2) THEN
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        END IF;

        IF (p_planning_query_mode = 4) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 2 ';
        ELSIF(p_planning_query_mode = 3) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        ELSIF(p_planning_query_mode = 2) THEN
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        END IF;

        --Bug #3411938
        IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
           group_str := group_str || ' , planning_organization_id, planning_tp_type ';
           group_str := group_str || ' , owning_organization_id, owning_tp_type ';
           group_str := group_str || ' , item_lot_control, item_serial_control ';
        END IF;

        IF p_qty_from IS NOT NULL THEN
           having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
        END IF;

        IF p_qty_to IS NOT NULL THEN
           having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
        END IF;

        IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
           query_str := query_str || 'AND organization_id = mp.organization_id  ';
           query_str := query_str || group_str || having_str || ' ) ' ;
        ELSE
          query_str := query_str || 'AND organization_id = mp.organization_id ) ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'and mp.organization_id = :org_id ';
        -- Bug #3411938
        ELSE
          query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
          query_str  := query_str || ' FROM org_access_view oav ' ;
          query_str  := query_str || ' WHERE oav.organization_id = mp.organization_id ' ;
          query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
          query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
        END IF;

        query_str  := query_str || ' ORDER BY organization_code ';

      -- Need to use both MTL_ONHAND_TOTAL_V AND MTL_ONHAND_SERIAL_V
      ELSIF(
            p_serial_number_from IS NULL
            AND p_serial_number_to IS NULL
            AND p_unit_number IS NULL
            AND p_serial_attr_query IS NULL
            AND p_status_id IS NOT NULL
            AND p_lpn_from IS NULL
            AND p_lpn_to IS NULL
            AND nvl(p_prepacked,1) = 1
           ) THEN
        IF (p_status_id IS NULL) THEN
          table_required  := ' mtl_onhand_total_mwb_v ';
--         ELSIF is_grade_t = TRUE THEN                     -- NSRIVAST, INVCONV
--           table_required  := ' mtl_onhand_new_lpn_v ';   -- NSRIVAST, INVCONV
        ELSE
          table_required  := ' mtl_onhand_total_v ';
        END IF;

        IF p_lot_attr_query IS NULL THEN
          query_str  := query_str || 'SELECT organization_id from ' || table_required;
          query_str  := query_str || 'WHERE 1=1 ';
        ELSE
          query_str  :=
                query_str
             || 'SELECT organization_id from'
             || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln, '
             || table_required;
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        END IF;

        --ER(3338592) Changes (If the user gives the value for the Qty then only
        --Group by clause comes in to effect)

        IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
           group_str := ' GROUP BY  organization_id ';
        END IF;

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND subinventory_code = :sub ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , subinventory_code  ' ;
          END IF;
        END IF;

        IF p_subinventory_code IS NULL AND p_detailed = 1 THEN   --Bug # 3412002
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , subinventory_code  ' ;
          END IF;
        END IF;

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND locator_id = :loc_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , locator_id  ' ;
          END IF;
        END IF;

        IF p_locator_id IS NULL AND p_detailed = 1 THEN  --Bug # 3412002
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , locator_id  ' ;
          END IF;
        END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_project_id IS NOT NULL THEN
          query_str  := query_str || ' AND project_id = :pr_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , project_id  ' ;
          END IF;
        END IF;

        IF p_task_id IS NOT NULL THEN
          query_str  := query_str || ' AND task_id = :ta_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , p_task_id  ' ;
          END IF;
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || 'AND inventory_item_id = :item_id ';
        END IF;

        --Bug # 3411938
        IF (p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL)
          AND (NVL(p_view_by,' ') NOT IN ('LOT' , 'SERIAL'))  THEN
           group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
        END IF;

        --ER(3338592) Changes
        IF p_item_description IS NOT NULL THEN
           query_str := query_str || ' AND item_description LIKE :item_description ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || 'AND revision = :rev ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , revision  ' ;
          END IF;
        END IF;

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || 'AND cost_group_id = :cg_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , cost_group_id  ' ;
          END IF;
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number <= :lot_t ';
        END IF;

        IF p_unit_number IS NOT NULL THEN
          query_str  := query_str || ' AND unit_number=:un_id ';
        END IF;

        IF p_lot_controlled = 2 THEN
          query_str  := query_str || 'AND lot_number is not null ';
        ELSIF p_lot_controlled = 1 THEN
          query_str  := query_str || 'AND lot_number is null ';
        END IF;

        IF p_status_id IS NOT NULL THEN
          query_str  := query_str || 'AND (subinventory_status_id = :st_id ';
          query_str  := query_str || 'OR locator_status_id = :st_id OR lot_status_id = :st_id) ';
        END IF;

        IF p_containerized = 1 THEN
          query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
        ELSIF p_containerized = 2 THEN
          query_str  := query_str || 'AND containerized_flag = 1 ';
        END IF;

        IF p_serial_controlled = 1 THEN
          --query_str  := query_str || 'AND serial_number_control_code not in (2,5) ';
          query_str  := query_str || 'AND item_serial_control not in (2,5) ';
        ELSIF p_serial_controlled = 2 THEN
          --query_str  := query_str || 'AND serial_number_control_code in (2,5) ';
          query_str  := query_str || 'AND item_serial_control in (2,5) ';
        END IF;

        /*IF p_site_id IS NOT NULL THEN
           query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND planning_organization_id = :site_id ' ;
         ELSIF p_vendor_id is NOT NULL THEN
           query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND  planning_organization_idanization_id in ';
           query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
           query_str := query_str || '  where vendor_id = :vendor_id )';
        END IF;*/

        IF (p_owning_qry_mode = 4) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 2 ';
        ELSIF(p_owning_qry_mode = 3) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        ELSIF(p_owning_qry_mode = 2) THEN
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        END IF;

        IF (p_planning_query_mode = 4) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 2 ';
        ELSIF(p_planning_query_mode = 3) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        ELSIF(p_planning_query_mode = 2) THEN
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        END IF;

        --Bug #3411938
        IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
           group_str := group_str || ' , planning_organization_id, planning_tp_type ';
           group_str := group_str || ' , owning_organization_id, owning_tp_type ';
           group_str := group_str || ' , item_lot_control, item_serial_control ';
        END IF;

        IF p_qty_from IS NOT NULL THEN
           having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
        END IF;

        IF p_qty_to IS NOT NULL THEN
           having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
        END IF;

        IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
          query_str := query_str || 'AND organization_id = mp.organization_id  ';
          query_str := query_str || group_str || having_str || '  ' ;
        ELSE
          query_str := query_str || 'AND organization_id = mp.organization_id  ';
        END IF;

        query_str  := query_str || 'UNION ALL ';

        --Reinitializing the variable
        having_str := ' HAVING 1=1 ' ;

        IF (p_status_id IS NULL) THEN
          table_required  := ' mtl_onhand_serial_mwb_v ';
        ELSE
          table_required  := ' mtl_onhand_serial_v ';
        END IF;

        IF p_lot_attr_query IS NULL
           AND p_serial_attr_query IS NULL THEN
          query_str  := query_str || 'SELECT organization_id from ' || table_required;
          query_str  := query_str || 'WHERE 1=1 ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NULL THEN
          query_str  :=
                query_str
             || 'SELECT organization_id from'
             || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln, '
             || table_required;
          query_str  := query_str || ' WHERE mln.lot_num = lot_number ';
        END IF;

        --ER(3338592) Changes (If the user gives the value for the Qty then only
        --Group by clause comes in to effect)

        IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
           group_str := ' GROUP BY  organization_id ';
        END IF;

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND subinventory_code = :sub ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , subinventory_code  ' ;
          END IF;
        END IF;

        IF p_subinventory_code IS NULL AND p_detailed = 1 THEN   --Bug # 3412002
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , subinventory_code  ' ;
          END IF;
        END IF;

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND locator_id = :loc_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , locator_id  ' ;
          END IF;
        END IF;

        IF p_locator_id IS NULL AND p_detailed = 1 THEN  --Bug # 3412002
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , locator_id  ' ;
          END IF;
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || 'AND inventory_item_id = :item_id ';
        END IF;

        --Bug # 3411938
        IF (p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL)
          AND (NVL(p_view_by,' ') NOT IN ('LOT' , 'SERIAL'))  THEN
           group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
        END IF;

        --ER(3338592) Changes
        IF p_item_description IS NOT NULL THEN
           query_str := query_str || ' AND item_description LIKE :item_description ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || 'AND revision = :rev ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , revision  ' ;
          END IF;
        END IF;

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || ' AND cost_group_id = :cg_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , cost_group_id  ' ;
          END IF;
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || ' AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || ' AND lot_number <= :lot_t ';
        END IF;

        IF p_serial_number_from IS NOT NULL THEN
          query_str  := query_str || ' AND serial_number >= :serial_f ';
        END IF;

        IF p_serial_number_to IS NOT NULL THEN
          query_str  := query_str || ' AND serial_number <= :serial_t ';
        END IF;

        IF p_status_id IS NOT NULL THEN
          query_str  := query_str || 'AND (subinventory_status_id = :st_id OR locator_status_id = :st_id ';
          query_str  := query_str || 'OR lot_status_id = :st_id OR serial_status_id = :st_id) ';
        END IF;

        IF p_lot_controlled = 2 THEN
          query_str  := query_str || 'AND lot_number is not null ';
        ELSIF p_lot_controlled = 1 THEN
          query_str  := query_str || 'AND lot_number is null ';
        END IF;

        IF p_containerized = 1 THEN
          query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
        ELSIF p_containerized = 2 THEN
          query_str  := query_str || 'AND containerized_flag = 1 ';
        END IF;

        IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
           group_str := group_str || ' , planning_organization_id, planning_tp_type ';
           group_str := group_str || ' , owning_organization_id, owning_tp_type ';
           group_str := group_str || ' , item_lot_control, item_serial_control ';
        END IF;

        IF p_qty_from IS NOT NULL THEN
           having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
        END IF;

        IF p_qty_to IS NOT NULL THEN
           having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
        END IF;

        IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
           query_str := query_str || ' AND organization_id = mp.organization_id  ';
           query_str := query_str || group_str || having_str || ' ) ' ;
        ELSE
           query_str := query_str || ' AND organization_id = mp.organization_id ) ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || ' and mp.organization_id = :org_id ';
        -- Bug # 3411938
        ELSE
          query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
          query_str  := query_str || ' FROM org_access_view oav ' ;
          query_str  := query_str || ' WHERE oav.organization_id = mp.organization_id ' ;
          query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
          query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
        END IF;

        query_str  := query_str || ' ORDER BY organization_code ';

      -- Need to use MTL_ONHAND_LPN_V
      ELSIF(p_lpn_from IS NOT NULL
            OR p_lpn_to IS NOT NULL
            OR nvl(p_prepacked,1) <> 1) THEN
        IF p_sub_type = 2 THEN
          table_required  := ' mtl_onhand_lpn_mwb_v mol ';
        ELSIF(p_status_id IS NULL) THEN
          IF (p_prepacked <> 1) AND (p_prepacked <> 9) AND (p_prepacked <> 11) THEN
            table_required  := ' mtl_onhand_lpn_mwb_v mol ';
              IF is_grade_t = TRUE THEN                              -- NSRIVAST, INVCONV
                  table_required  := ' mtl_onhand_new_lpn_v mol ';   -- NSRIVAST, INVCONV
              END IF;
          ELSE
            table_required  := ' mtl_onhand_new_lpn_mwb_v mol ';
          END IF;
        ELSE
          IF (p_prepacked <> 1) AND (p_prepacked <> 9) AND (p_prepacked <> 11) THEN
            table_required  := ' mtl_onhand_lpn_v mol ';
              IF is_grade_t = TRUE THEN                              -- NSRIVAST, INVCONV
                  table_required  := ' mtl_onhand_new_lpn_v mol ';   -- NSRIVAST, INVCONV
              END IF;
          ELSE
            table_required  := ' mtl_onhand_new_lpn_v mol ';
          END IF;
        END IF;

        query_str  := query_str || ' SELECT organization_id from ' || table_required;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL THEN
          query_str  := query_str || ', (select outermost_lpn_id from wms_license_plate_numbers wlpn ';
          query_str  := query_str || ' WHERE 1=1 ';

          IF p_sub_type = 2 THEN
            query_str  := query_str || ' AND lpn_context = 3 ';
          ELSIF p_prepacked IS NULL THEN
            query_str  := query_str || ' AND (lpn_context=1  or lpn_context=9 or lpn_context=11 )';
          ELSIF p_prepacked = 1 THEN
            query_str  := query_str || ' AND lpn_context = 1 ';
          ELSIF p_prepacked <> 1
                AND p_prepacked <> 999
                AND p_prepacked IS NOT NULL THEN
            query_str  := query_str || ' AND lpn_context = :prepacked ';
          END IF;

          IF p_locator_id IS NOT NULL THEN
            query_str  := query_str || ' AND wlpn.locator_id = :loc_id ';
          END IF;

          IF p_subinventory_code IS NOT NULL THEN
            query_str  := query_str || ' AND wlpn.subinventory_code = :sub ';
          END IF;

          IF p_organization_id IS NOT NULL THEN
            query_str  := query_str || ' AND wlpn.organization_id = :org_id ';
          END IF;

          IF p_lpn_from IS NOT NULL
             OR p_lpn_to IS NOT NULL THEN
            IF p_lpn_from IS NOT NULL
               AND p_lpn_to IS NULL THEN
              query_str  := query_str || ' and license_plate_number >= :lpn_f ';
            ELSIF p_lpn_from IS NULL
                  AND p_lpn_to IS NOT NULL THEN
              query_str  := query_str || ' and license_plate_number <= :lpn_t ';
            ELSIF p_lpn_from IS NOT NULL
                  AND p_lpn_to IS NOT NULL THEN
                  --bugfix#3646484
                  IF (p_lpn_from = p_lpn_to) THEN
                   --User is querying for single LPN so converted the range query to equality query
                   query_str := query_str || 'and license_plate_number = :lpn_f ';
                  ELSE
                    query_str  := query_str || ' and license_plate_number >= :lpn_f ';
                    query_str  := query_str || ' and license_plate_number <= :lpn_t ';
                  END IF;
            END IF;
          END IF;

          query_str  := query_str || 'group by wlpn.outermost_lpn_id) X ';
        END IF;

        IF p_lot_attr_query IS NULL
           AND p_serial_attr_query IS NULL THEN
          query_str  := query_str || 'WHERE 1=1 ';
        ELSIF p_lot_attr_query IS NULL
              AND p_serial_attr_query IS NOT NULL THEN
          query_str  :=
                     query_str || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 ' || p_serial_attr_query
                     || ') msn ';
          query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NULL THEN
          query_str  := query_str || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 ' || p_lot_attr_query || ') mln ';
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NOT NULL THEN
          query_str  :=
                query_str
             || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln '
             || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
             || p_serial_attr_query
             || ') msn ';
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
          query_str  := query_str || 'AND msn.serial_num = serial_number ';
        END IF;

         --ER(3338592) Changes (If the user gives the value for the Qty then only
         --Group by clause comes in to effect)

         IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
            group_str := ' GROUP BY  organization_id  ';
         END IF;

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND subinventory_code = :sub ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , subinventory_code  ' ;
          END IF;
        END IF;

        IF p_subinventory_code IS NULL AND p_detailed = 1 THEN   --Bug # 3412002
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , subinventory_code  ' ;
          END IF;
        END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND locator_id = :loc_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , locator_id  ' ;
          END IF;
        END IF;

        IF p_locator_id IS NULL AND p_detailed = 1 THEN  --Bug # 3412002
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , locator_id  ' ;
          END IF;
        END IF;

        IF p_project_id IS NOT NULL THEN
          query_str  := query_str || ' AND project_id = :pr_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , project_id  ' ;
          END IF;
        END IF;

        IF p_task_id IS NOT NULL THEN
          query_str  := query_str || ' AND task_id = :ta_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , p_task_id  ' ;
          END IF;
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || ' AND inventory_item_id = :item_id ';
        END IF;

        --Bug # 3411938
        IF (p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL)
          AND (NVL(p_view_by,' ') NOT IN ('LOT' , 'SERIAL'))  THEN
           group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
        END IF;

        --ER(3338592) Changes
        IF p_item_description IS NOT NULL THEN
           query_str := query_str || ' AND item_description LIKE :item_description ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || ' AND revision = :rev ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , revision  ' ;
          END IF;
        END IF;

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || ' AND cost_group_id = :cg_id ';
          --ER(3338592) Changes
          IF group_str IS NOT NULL THEN
             group_str := group_str || ' , cost_group_id  ' ;
          END IF;
        END IF;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL THEN
          query_str  := query_str || ' AND MOL.outermost_lpn_id = X.outermost_lpn_id ';
        END IF;

        --ER(3338592) Changes
        IF p_lpn_from IS NOT NULL OR p_lpn_to IS NOT NULL THEN
           --ER(3338592) Changes
           IF group_str IS NOT NULL THEN
              group_str := group_str || ' , lpn ' ;
          END IF;
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || ' AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || ' AND lot_number <= :lot_t ';
        END IF;

        IF p_serial_number_from IS NOT NULL THEN
          query_str  := query_str || ' AND serial_number >= :serial_f ';
        END IF;

        IF p_serial_number_to IS NOT NULL THEN
          query_str  := query_str || ' AND serial_number <= :serial_t ';
        END IF;

        IF p_unit_number IS NOT NULL THEN
          query_str  := query_str || ' AND unit_number=:un_id ';
        END IF;

        IF p_status_id IS NOT NULL THEN
          query_str  := query_str || ' AND (subinventory_status_id = :st_id OR locator_status_id = :st_id ';
          query_str  := query_str || ' OR lot_status_id = :st_id OR serial_status_id = :st_id) ';
        END IF;

        IF p_lot_controlled = 2 THEN
          query_str  := query_str || ' AND lot_number is not null ';
        ELSIF p_lot_controlled = 1 THEN
          query_str  := query_str || ' AND lot_number is null ';
        END IF;

        IF p_serial_controlled = 1 THEN
          query_str  := query_str || ' AND serial_number is null ';
        ELSIF p_serial_controlled = 2 THEN
          query_str  := query_str || ' AND serial_number is not null ';
        END IF;

        IF p_sub_type = 2 THEN
          query_str  := query_str || ' AND lpn_context = 3 ';
        ELSIF p_prepacked IS NULL THEN
          query_str  := query_str || ' AND (lpn_context=1  or lpn_context=9 or lpn_context=11 ) ';
        ELSIF p_prepacked = 1 THEN
          query_str  := query_str || 'AND lpn_context = 1 ';
        ELSIF p_prepacked <> 1
              AND p_prepacked <> 999
              AND p_prepacked IS NOT NULL THEN
          query_str  := query_str || 'AND lpn_context = :prepacked ';
        END IF;

        /*IF p_site_id IS NOT NULL THEN
           query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND planning_organization_id = :site_id ' ;
         ELSIF p_vendor_id is NOT NULL THEN
           query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND  planning_organization_id in ';
           query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
           query_str := query_str || '  where vendor_id = :vendor_id )';
        END IF;*/

        IF (p_owning_qry_mode = 4) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 2 ';
        ELSIF(p_owning_qry_mode = 3) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        ELSIF(p_owning_qry_mode = 2) THEN
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        END IF;

        IF (p_planning_query_mode = 4) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 2 ';
        ELSIF(p_planning_query_mode = 3) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        ELSIF(p_planning_query_mode = 2) THEN
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        END IF;

        --Bug #3411938
        IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
           group_str := group_str || ' , planning_organization_id, planning_tp_type ';
           group_str := group_str || ' , owning_organization_id, owning_tp_type ';
           group_str := group_str || ' , item_lot_control, item_serial_control ';
        END IF;

        IF p_qty_from IS NOT NULL THEN
           having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
        END IF;

        IF p_qty_to IS NOT NULL THEN
           having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
        END IF;

        IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
          query_str := query_str || 'AND organization_id = mp.organization_id  ';
          query_str := query_str || group_str || having_str || ' ) ' ;
        ELSE
          query_str := query_str || 'AND organization_id = mp.organization_id ) ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'and mp.organization_id = :org_id ';
        --Bug # 3411938
        ELSE
          query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
          query_str  := query_str || ' FROM org_access_view oav ' ;
          query_str  := query_str || ' WHERE oav.organization_id = mp.organization_id ' ;
          query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
          query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
        END IF;

        query_str  := query_str || ' ORDER BY organization_code ';

      END IF;
    END IF;

       -- Enable this during debugging
       inv_trx_util_pub.trace(query_str, 'Add-Orgs - Material Workbench', 9);
       --trace1(query_str, 'add_orgs', 9);

    query_hdl       := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(query_hdl, query_str, DBMS_SQL.native);

    IF p_organization_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'org_id', p_organization_id);
    END IF;

    IF p_subinventory_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'sub', p_subinventory_code);
    END IF;

    IF p_locator_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'loc_id', p_locator_id);
    END IF;

    IF p_inventory_item_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'item_id', p_inventory_item_id);
    END IF;

    IF p_revision IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'rev', p_revision);
    END IF;

    IF p_cost_group_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'cg_id', p_cost_group_id);
    END IF;

    IF p_lot_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_f', p_lot_number_from);
    END IF;

    IF p_lot_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_t', p_lot_number_to);
    END IF;

 -- NSRIVAST, INVCONV, Start
    IF p_grade_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_f',p_grade_from );
    END IF;
    IF p_grade_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_c', p_grade_code);
    END IF;
 -- NSRIVAST, INVCONV, End
    IF p_serial_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_f', p_serial_number_from);
    END IF;

    IF p_serial_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_t', p_serial_number_to);
    END IF;

      --bugfix#3646484
      IF ((p_lpn_from IS NOT NULL) AND (p_lpn_to IS NOT NULL) AND (p_lpn_from = p_lpn_to))  THEN
      --User is querying for single LPN so converted the range query to equality query
      --So it is enought to bind the from lpn alone
         dbms_sql.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
      ELSE
          IF p_lpn_from IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
          END IF;

          IF p_lpn_to IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_t', p_lpn_to);
          END IF;
      END IF;

    IF p_status_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'st_id', p_status_id);
    END IF;

    IF p_prepacked <> 1
       AND p_prepacked <> 999
       AND p_prepacked IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'prepacked', p_prepacked);
    END IF;

    IF p_mln_context_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'mln_context', p_mln_context_code);
    END IF;

    IF p_project_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'pr_id', p_project_id);
    END IF;

    IF p_task_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'ta_id', p_task_id);
    END IF;

    IF p_unit_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'un_id', p_unit_number);
    END IF;

    IF (p_owning_qry_mode = 4)
       OR(p_owning_qry_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'own_org', p_owning_org);
    END IF;

    IF (p_planning_query_mode = 4)
       OR(p_planning_query_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'plan_org', p_planning_org);
    END IF;

    --ER(3338592) Changes
    IF p_item_description IS NOT NULL THEN
      dbms_sql.bind_variable(query_hdl, 'item_description', p_item_description);
    END IF;

    IF p_qty_from IS NOT NULL THEN
      dbms_sql.bind_variable(query_hdl, 'qty_from', p_qty_from);
    END IF;

    IF p_qty_to IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl, 'qty_to', p_qty_to);
    END IF;
    --End of ER Changes

    --Bug #3411938
    IF p_organization_id IS NULL THEN
       IF p_responsibility_id  IS NOT NULL THEN
          dbms_sql.bind_variable(query_hdl, 'responsibility_id', p_responsibility_id );
       END IF;

       IF p_resp_application_id  IS NOT NULL THEN
          dbms_sql.bind_variable(query_hdl, 'resp_application_id', p_resp_application_id );
       END IF;
    END IF;

    DBMS_SQL.define_column(query_hdl, 1, org_id);
    DBMS_SQL.define_column(query_hdl, 2, org_code, 3);
    rows_processed  := DBMS_SQL.EXECUTE(query_hdl);

    LOOP
      -- fetch a row
      IF DBMS_SQL.fetch_rows(query_hdl) > 0 THEN
        -- fetch columns from the row
        DBMS_SQL.column_value(query_hdl, 1, org_id);
        DBMS_SQL.column_value(query_hdl, 2, org_code);

        IF j >= p_node_low_value THEN
          x_node_tbl(i).state  := p_node_state;
          x_node_tbl(i).DEPTH  := 1;
          x_node_tbl(i).label  := org_code;
          x_node_tbl(i).icon   := 'inv_inor';
          x_node_tbl(i).VALUE  := TO_CHAR(org_id);
          x_node_tbl(i).TYPE   := 'ORG';
          i                    := i + 1;
        END IF;

        EXIT WHEN j >= p_node_high_value;
        j  := j + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    DBMS_SQL.close_cursor(query_hdl); -- close cursor
    x_node_value    := j;
    x_tbl_index     := i;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END add_orgs;

  -- Add status nodes for the given parameters
  PROCEDURE add_statuses(
    p_organization_id     IN            NUMBER DEFAULT NULL
  , p_subinventory_code   IN            VARCHAR2 DEFAULT NULL
  , p_locator_id          IN            NUMBER DEFAULT NULL
  , p_inventory_item_id   IN            NUMBER DEFAULT NULL
  , p_revision            IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_from     IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_to       IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_from  IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_to    IN            VARCHAR2 DEFAULT NULL
  , p_lpn_from            IN            VARCHAR2 DEFAULT NULL
  , p_lpn_to              IN            VARCHAR2 DEFAULT NULL
  , p_cost_group_id       IN            NUMBER DEFAULT NULL
  , p_status_id           IN            NUMBER DEFAULT NULL
  , p_lot_attr_query      IN            VARCHAR2 DEFAULT NULL
  , p_mln_context_code    IN            VARCHAR2 DEFAULT NULL
  , p_project_id          IN            NUMBER DEFAULT NULL
  , p_task_id             IN            NUMBER DEFAULT NULL
  , p_unit_number         IN            VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode     IN            NUMBER DEFAULT NULL
  , p_planning_query_mode IN            NUMBER DEFAULT NULL
  , p_owning_org          IN            NUMBER DEFAULT NULL
  , p_planning_org        IN            NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query   IN            VARCHAR2 DEFAULT NULL
  , p_node_state          IN            NUMBER
  , p_node_high_value     IN            NUMBER
  , p_node_low_value      IN            NUMBER
  --ER(3338592) Changes
  , p_item_description    IN            VARCHAR2 DEFAULT NULL
  , p_qty_from            IN            NUMBER   DEFAULT NULL
  , p_qty_to              IN            NUMBER   DEFAULT NULL
  --End of ER Changes
  , p_responsibility_id   IN            NUMBER   DEFAULT NULL
  , p_resp_application_id IN            NUMBER   DEFAULT NULL
  , x_node_value          IN OUT NOCOPY NUMBER
  , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index           IN OUT NOCOPY NUMBER
   -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL

  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
    ) IS
    query_str      VARCHAR2(10000);
    query_hdl      NUMBER;
    rows_processed NUMBER;
    status_id      mtl_material_statuses_vl.status_id%TYPE;
    status_code    mtl_material_statuses_vl.status_code%TYPE;
    i              NUMBER                                      := x_tbl_index;
    j              NUMBER                                      := x_node_value;
    serial_control NUMBER;
    table_required VARCHAR2(300);

    is_grade_t     BOOLEAN DEFAULT FALSE ; -- NSRIVAST, INVCONV

    --ER(3338592) Changes
    group_str      VARCHAR2(10000) ;
    having_str     VARCHAR2(10000) := ' HAVING 1=1 ';
    --End of ER Changes

  BEGIN

   -- NSRIVAST, INVCONV, Start
     IF  (p_grade_from IS NOT NULL OR  p_grade_code IS NOT NULL OR p_grade_controlled <> 0) THEN
             is_grade_t     := TRUE ;
     END IF ;
   -- NSRIVAST, INVCONV, End

    query_str       := 'SELECT mms.status_id, mms.status_code ';
    query_str       := query_str || 'FROM mtl_material_statuses_vl mms ';
    query_str       := query_str || ' WHERE exists (';

    IF p_organization_id IS NOT NULL
       AND p_inventory_item_id IS NOT NULL THEN
      SELECT serial_number_control_code
        INTO serial_control
        FROM mtl_system_items
       WHERE organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id;
    END IF;

    IF (serial_control IN(2, 5)
        OR p_serial_number_from IS NOT NULL
        OR p_serial_number_to IS NOT NULL
        OR p_serial_attr_query IS NOT NULL)
       AND p_lpn_from IS NULL
       AND p_lpn_to IS NULL THEN
      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT organization_id from mtl_onhand_serial_v mos ';
        query_str  := query_str || 'WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || 'SELECT organization_id from'
           || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn, mtl_onhand_serial_v mos ';
        query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  :=
              query_str
           || 'SELECT organization_id from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, mtl_onhand_serial_v mos ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || 'SELECT organization_id from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, '
           || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn, mtl_onhand_serial_v mos ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        query_str  := query_str || 'AND msn.serial_num = serial_number ';
      END IF;

      --ER(3338592) Changes (If the user gives the value for the Qty then only
      --Group by clause comes in to effect)

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := ' GROUP BY  organization_id  ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code <= :sub ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , subinventory_code  ' ;
        END IF;
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , locator_id  ' ;
        END IF;
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , project_id  ' ;
        END IF;
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , p_task_id  ' ;
        END IF;
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
         query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      --Bug # 3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision <= :rev ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , revision  ' ;
        END IF;
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id  ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , cost_group_id  ' ;
        END IF;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      --Bug #3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , planning_organization_id, planning_tp_type ';
         group_str := group_str || ' , owning_organization_id, owning_tp_type ';
         group_str := group_str || ' , item_lot_control, item_serial_control ';
      END IF;

      query_str  := query_str || ' AND (subinventory_status_id = mms.status_id ';
      query_str  := query_str || ' or locator_status_id = mms.status_id or ';
      query_str  := query_str || ' lot_status_id = mms.status_id or serial_status_id = mms.status_id) ';

      IF p_qty_from IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
      END IF;

      IF p_qty_to IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      ELSE
        query_str  := query_str || ' AND  EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id   = mos.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         query_str := query_str || group_str || having_str || '  ' ;
      END IF;

      query_str  := query_str || ') ';

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'and mms.status_id = :st_id ';
      END IF;

      query_str  := query_str || ' ORDER BY status_code ';

    ELSIF p_lpn_from IS NULL
          AND p_lpn_to IS NULL THEN
      IF p_lot_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT organization_id from mtl_onhand_total_v mot ';
        query_str  := query_str || 'WHERE 1=1 ';
      ELSE
        query_str  :=
              query_str
           || 'SELECT organization_id from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, mtl_onhand_total_v mot ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      END IF;

      --ER(3338592) Changes (If the user gives the value for the Qty then only
      --Group by clause comes in to effect)

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := ' GROUP BY  organization_id  ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , subinventory_code  ' ;
        END IF;
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , locator_id  ' ;
        END IF;
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , project_id  ' ;
        END IF;
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , p_task_id  ' ;
        END IF;
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
         query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      --Bug # 3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , revision  ' ;
        END IF;
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , cost_group_id  ' ;
        END IF;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , planning_organization_id , planning_tp_type ' ;
        END IF;
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , planning_organization_id , planning_tp_type ' ;
        END IF;
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , planning_tp_type ' ;
        END IF;
      END IF;

      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , owning_organization_id , owning_tp_type ' ;
        END IF;
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , owning_organization_id , owning_tp_type ' ;
        END IF;
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , owning_tp_type ' ;
        END IF;
      END IF;

      --Bug #3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , planning_organization_id, planning_tp_type ';
         group_str := group_str || ' , owning_organization_id, owning_tp_type ';
         group_str := group_str || ' , item_lot_control, item_serial_control ';
      END IF;

      query_str  := query_str || 'AND (subinventory_status_id = mms.status_id ';
      query_str  := query_str || 'or locator_status_id = mms.status_id or ';
      query_str  := query_str || 'lot_status_id = mms.status_id) ';

      IF p_qty_from IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
      END IF;

      IF p_qty_to IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      ELSE
        query_str  := query_str || ' AND  EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id   = mot.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         query_str := query_str || group_str || having_str || '  ' ;
      END IF;

      --Reinitializing
      having_str := ' HAVING 1=1 ' ;

      query_str  := query_str || 'UNION ';

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT organization_id from mtl_onhand_serial_v mos ';
        query_str  := query_str || 'WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  :=
              query_str
           || 'SELECT organization_id from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, mtl_onhand_serial_v mos  ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      END IF;

      --ER(3338592) Changes (If the user gives the value for the Qty then only
      --Group by clause comes in to effect)

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := ' GROUP BY  organization_id ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , subinventory_code  ' ;
        END IF;
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , locator_id  ' ;
        END IF;
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , project_id  ' ;
        END IF;
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , p_task_id  ' ;
        END IF;
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
         query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      --Bug # 3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , revision  ' ;
        END IF;
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , cost_group_id  ' ;
        END IF;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      --Bug #3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , planning_organization_id, planning_tp_type ';
         group_str := group_str || ' , owning_organization_id, owning_tp_type ';
         group_str := group_str || ' , item_lot_control, item_serial_control ';
      END IF;

      query_str  := query_str || 'AND (subinventory_status_id = mms.status_id ';
      query_str  := query_str || 'or locator_status_id = mms.status_id or ';
      query_str  := query_str || 'lot_status_id = mms.status_id or serial_status_id = mms.status_id) ';

      IF p_qty_from IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
      END IF;

      IF p_qty_to IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      ELSE
        query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id = mos.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         query_str := query_str || group_str || having_str || '  ' ;
      END IF;

      query_str  := query_str || ') ';

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'and mms.status_id = :st_id ';
      END IF;

      query_str  := query_str || ' ORDER BY status_code ';

    ELSIF p_lpn_from IS NOT NULL
          AND p_lpn_to IS NOT NULL THEN
          IF is_grade_t = TRUE THEN                           -- NSRIVAST, INVCONV
               table_required  := ' mtl_onhand_new_lpn_v ';   -- NSRIVAST, INVCONV
          ELSE
             table_required  := ' MTL_ONHAND_NEW_LPN_V mol ';
          END IF;
      query_str       := query_str || 'SELECT organization_id from ' || table_required;

      IF (p_lpn_from IS NOT NULL
          OR p_lpn_to IS NOT NULL) THEN
        query_str  := query_str || ', (select outermost_lpn_id from wms_license_plate_numbers wlpn ';
        query_str  := query_str || ' WHERE 1=1 ';

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.locator_id = :loc_id ';
        END IF;

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.subinventory_code = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.organization_id = :org_id ';
        END IF;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL THEN
          IF p_lpn_from IS NOT NULL
             AND p_lpn_to IS NULL THEN
            query_str  := query_str || ' and license_plate_number >= :lpn_f ';
          ELSIF p_lpn_from IS NULL
                AND p_lpn_to IS NOT NULL THEN
            query_str  := query_str || ' and license_plate_number <= :lpn_t ';
          ELSIF p_lpn_from IS NOT NULL
                AND p_lpn_to IS NOT NULL THEN
                  --bugfix#3646484
                  IF (p_lpn_from = p_lpn_to) THEN
                     --User is querying for single LPN so converted the range query to equality query
                     query_str := query_str || 'and license_plate_number = :lpn_f ';
                  ELSE
                     query_str  := query_str || ' and license_plate_number >= :lpn_f ';
                     query_str  := query_str || ' and license_plate_number <= :lpn_t ';
                  END IF;
          END IF;
        END IF;

        query_str  := query_str || 'group by wlpn.outermost_lpn_id) X ';
      END IF;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
                     query_str || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 ' || p_serial_attr_query
                     || ') msn ';
        query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 ' || p_lot_attr_query || ') mln ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln '
           || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        query_str  := query_str || 'AND msn.serial_num = serial_number ';
      END IF;

      --ER(3338592) Changes (If the user gives the value for the Qty then only
      --Group by clause comes in to effect)

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := ' GROUP BY  organization_id ';
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , subinventory_code  ' ;
        END IF;
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , locator_id  ' ;
        END IF;
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , project_id  ' ;
        END IF;
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , p_task_id  ' ;
        END IF;
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
         query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      --Bug # 3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , revision  ' ;
        END IF;
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , cost_group_id  ' ;
        END IF;
      END IF;

      IF p_lpn_from IS NOT NULL
         OR p_lpn_to IS NOT NULL THEN
        query_str  := query_str || ' AND mol.outermost_lpn_id = x.outermost_lpn_id ';
         --ER(3338592) Changes
         IF group_str IS NOT NULL THEN
            group_str := group_str || ' , lpn ' ;
         END IF;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      --Bug #3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , planning_organization_id, planning_tp_type ';
         group_str := group_str || ' , owning_organization_id, owning_tp_type ';
         group_str := group_str || ' , item_lot_control, item_serial_control ';
      END IF;

      query_str       := query_str || 'AND (subinventory_status_id = mms.status_id ';
      query_str       := query_str || 'or locator_status_id = mms.status_id or ';
      query_str       := query_str || 'lot_status_id = mms.status_id or serial_status_id = mms.status_id) ';

      IF p_qty_from IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
      END IF;

      IF p_qty_to IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      ELSE
        query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id = mol.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         query_str := query_str || group_str || having_str || '  ' ;
      END IF;

      query_str       := query_str || ') ';

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'and mms.status_id = :st_id ';
      END IF;

      query_str       := query_str || ' ORDER BY status_code ';

    END IF;

       -- Enable this during debugging
       inv_trx_util_pub.trace(query_str, 'Add-Status Material Workbench', 9);
       --trace1('Add_Statuses - ' || query_str);

    query_hdl       := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(query_hdl, query_str, DBMS_SQL.native);

    IF p_organization_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'org_id', p_organization_id);
    END IF;

    IF p_subinventory_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'sub', p_subinventory_code);
    END IF;

    IF p_locator_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'loc_id', p_locator_id);
    END IF;

    IF p_inventory_item_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'item_id', p_inventory_item_id);
    END IF;

    IF p_revision IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'rev', p_revision);
    END IF;

    IF p_cost_group_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'cg_id', p_cost_group_id);
    END IF;

    IF p_lot_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_f', p_lot_number_from);
    END IF;

    IF p_lot_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_t', p_lot_number_to);
    END IF;

-- NSRIVAST, INVCONV, Start
    IF p_grade_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_f',p_grade_from );
    END IF;
    IF p_grade_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_c', p_grade_code);
    END IF;
-- NSRIVAST, INVCONV, End

    IF p_serial_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_f', p_serial_number_from);
    END IF;

    IF p_serial_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_t', p_serial_number_to);
    END IF;

      --bugfix#3646484
      IF ((p_lpn_from IS NOT NULL) AND (p_lpn_to IS NOT NULL) AND (p_lpn_from = p_lpn_to))  THEN
      --User is querying for single LPN so converted the range query to equality query
      --So it is enought to bind the from lpn alone
         dbms_sql.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
      ELSE
          IF p_lpn_from IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
          END IF;

          IF p_lpn_to IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_t', p_lpn_to);
          END IF;
      END IF;

    IF p_status_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'st_id', p_status_id);
    END IF;

    IF p_mln_context_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'mln_context', p_mln_context_code);
    END IF;

    IF p_project_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'pr_id', p_project_id);
    END IF;

    IF p_task_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'ta_id', p_task_id);
    END IF;

    IF p_unit_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'un_id', p_unit_number);
    END IF;

    /*IF p_site_id IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'site_id', p_site_id);
     ELSIF p_vendor_id is NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'vendor_id', p_vendor_id);
    END IF;*/
    IF (p_owning_qry_mode = 4)
       OR(p_owning_qry_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'own_org', p_owning_org);
    END IF;

    IF (p_planning_query_mode = 4)
       OR(p_planning_query_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'plan_org', p_planning_org);
    END IF;

    --ER(3338592) Changes
    IF p_item_description IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl, 'item_description', p_item_description);
    END IF;

    IF p_qty_from IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl, 'qty_from', p_qty_from);
    END IF;

    IF p_qty_to IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl, 'qty_to', p_qty_to);
    END IF;
    --End of ER Changes

    -- Bug # 3411938
    IF p_organization_id IS NULL THEN
      IF p_responsibility_id  IS NOT NULL THEN
         dbms_sql.bind_variable(query_hdl, 'responsibility_id', p_responsibility_id );
      END IF;

      IF p_resp_application_id  IS NOT NULL THEN
         dbms_sql.bind_variable(query_hdl, 'resp_application_id', p_resp_application_id );
      END IF;
    END IF;

    DBMS_SQL.define_column(query_hdl, 1, status_id);
    DBMS_SQL.define_column(query_hdl, 2, status_code, 80);
    rows_processed  := DBMS_SQL.EXECUTE(query_hdl);

    LOOP
      -- fetch a row
      IF DBMS_SQL.fetch_rows(query_hdl) > 0 THEN
        -- fetch columns from the row
        DBMS_SQL.column_value(query_hdl, 1, status_id);
        DBMS_SQL.column_value(query_hdl, 2, status_code);

        IF j >= p_node_low_value THEN
          x_node_tbl(i).state  := p_node_state;
          x_node_tbl(i).DEPTH  := 1;
          x_node_tbl(i).label  := status_code;
          x_node_tbl(i).icon   := 'inv_stat';
          x_node_tbl(i).VALUE  := TO_CHAR(status_id);
          x_node_tbl(i).TYPE   := 'STATUS';
          i                    := i + 1;
        END IF;

        EXIT WHEN j >= p_node_high_value;
        j  := j + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    DBMS_SQL.close_cursor(query_hdl); -- close cursor
    x_node_value    := j;
    x_tbl_index     := i;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END add_statuses;

  PROCEDURE add_subs(
    p_organization_id          IN            NUMBER DEFAULT NULL
  , p_subinventory_code        IN            VARCHAR2 DEFAULT NULL
  , p_locator_id               IN            NUMBER DEFAULT NULL
  , p_inventory_item_id        IN            NUMBER DEFAULT NULL
  , p_revision                 IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_from          IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_to            IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_from       IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_to         IN            VARCHAR2 DEFAULT NULL
  , p_lpn_from                 IN            VARCHAR2 DEFAULT NULL
  , p_lpn_to                   IN            VARCHAR2 DEFAULT NULL
  , p_cost_group_id            IN            NUMBER DEFAULT NULL
  , p_status_id                IN            NUMBER DEFAULT NULL
  , p_lot_attr_query           IN            VARCHAR2 DEFAULT NULL
  , p_mln_context_code         IN            VARCHAR2 DEFAULT NULL
  , p_project_id               IN            NUMBER DEFAULT NULL
  , p_task_id                  IN            NUMBER DEFAULT NULL
  , p_unit_number              IN            VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode          IN            NUMBER DEFAULT NULL
  , p_planning_query_mode      IN            NUMBER DEFAULT NULL
  , p_owning_org               IN            NUMBER DEFAULT NULL
  , p_planning_org             IN            NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query        IN            VARCHAR2 DEFAULT NULL
  , p_only_subinventory_status IN            NUMBER DEFAULT 1
  , p_node_state               IN            NUMBER
  , p_node_high_value          IN            NUMBER
  , p_node_low_value           IN            NUMBER
  , p_sub_type                 IN            NUMBER DEFAULT NULL --RCVLOCATORSSUPPORT
  --ER(3338592) Changes
  , p_item_description         IN            VARCHAR2 DEFAULT NULL
  --End of ER Changes
  , x_node_value               IN OUT NOCOPY NUMBER
  , x_node_tbl                 IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index                IN OUT NOCOPY NUMBER
   -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL

  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  ) IS
    query_str      VARCHAR2(10000);
    query_hdl      NUMBER;
    rows_processed NUMBER;
    sub_code       mtl_onhand_quantities.subinventory_code%TYPE;
    i              NUMBER                                         := x_tbl_index;
    j              NUMBER                                         := x_node_value;
    table_required VARCHAR2(300);
    is_grade_t     BOOLEAN DEFAULT FALSE ; -- NSRIVAST, INVCONV
  BEGIN

 -- NSRIVAST, INVCONV, Start
     IF  (p_grade_from IS NOT NULL OR  p_grade_code IS NOT NULL OR p_grade_controlled <> 0) THEN
             is_grade_t     := TRUE ;
     END IF ;
-- NSRIVAST, INVCONV, End
    -- display all the LPNs in that location with the appropriate from
    -- and to LPN criteria, so include the subs that have them
    IF p_inventory_item_id IS NULL
       AND p_revision IS NULL
       AND p_lot_number_from IS NULL
       AND p_lot_number_to IS NULL
       AND p_serial_number_from IS NULL
       AND p_serial_number_to IS NULL
       AND p_cost_group_id IS NULL
       AND p_status_id IS NULL
       AND p_lot_attr_query IS NULL
       AND p_serial_attr_query IS NULL
       AND p_unit_number IS NULL
       AND p_project_id IS NULL
       AND p_task_id IS NULL
       AND p_planning_org IS NULL
       AND p_owning_org IS NULL
       AND(p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL)
       --ER(3338592) Changes
       AND p_item_description  IS NULL THEN
       --End of ER Changes
      query_str  := 'select subinventory_code ';
      query_str  := query_str || 'FROM wms_license_plate_numbers WHERE 1=1 ';

      --     query_str := query_str || 'AND (lpn_context = 1 or lpn_context=11 ');

      IF p_sub_type = 2 THEN
        query_str  := query_str || ' AND lpn_context = 3 ';
      ELSE
        query_str  := query_str || ' AND (lpn_context = 1 or lpn_context=9 or lpn_context=11 ) ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      --bugfix#3646484
      IF ((p_lpn_from IS NOT NULL) AND (p_lpn_to IS NOT NULL) AND (p_lpn_from = p_lpn_to))  THEN
      --User is querying for single LPN so converted the range query to equality query
         query_str := query_str || 'and license_plate_number = :lpn_f ';
      ELSE
         IF p_lpn_from IS NOT NULL THEN
           query_str  := query_str || 'and license_plate_number >= :lpn_f ';
         END IF;

         IF p_lpn_to IS NOT NULL THEN
           query_str  := query_str || 'and license_plate_number <= :lpn_t ';
         END IF;
      END IF;

      query_str  := query_str || ' GROUP BY subinventory_code ';
      query_str  := query_str || ' ORDER BY subinventory_code ';
    ELSE
      query_str  := 'SELECT msi.secondary_inventory_name subinventory_code FROM mtl_secondary_inventories msi ';
      query_str  := query_str || ' WHERE msi.secondary_inventory_name in ( ';

      -- Need to use MTL_ONHAND_TOTAL_V
      IF (
          p_serial_number_from IS NULL
          AND p_serial_number_to IS NULL
          AND p_unit_number IS NULL
          AND p_status_id IS NULL
          AND p_lpn_from IS NULL
          AND p_lpn_to IS NULL
          AND p_serial_attr_query IS NULL
         ) THEN
        IF p_sub_type = 2 THEN
          table_required  := ' mtl_rcv_mwb_onhand_v ';
        ELSIF(p_status_id IS NULL) THEN
          table_required  := ' mtl_onhand_total_mwb_v ';
             IF is_grade_t = TRUE THEN                       -- NSRIVAST, INVCONV
             table_required  := ' mtl_onhand_total_v ';  -- NSRIVAST, INVCONV
             END IF;
        ELSE
          table_required  := ' mtl_onhand_total_v ';
        END IF;

        IF p_lot_attr_query IS NULL THEN
          query_str  := query_str || ' SELECT subinventory_code from ' || table_required;
          query_str  := query_str || ' WHERE 1=1 ';
        ELSE
          query_str  :=
                query_str
             || ' SELECT subinventory_code from '
             || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln, '
             || table_required;
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        END IF;

        -- Select Only subinventory status if only subbinventory status is not 1
        IF p_status_id IS NOT NULL THEN
          IF p_only_subinventory_status = 1 THEN
            query_str  := query_str || ' AND (subinventory_status_id = :st_id or locator_status_id = :st_id ';
            query_str  := query_str || ' OR lot_status_id = :st_id or serial_status_id = :st_id) ';
          ELSE
            query_str  := query_str || ' AND subinventory_status_id = :st_id ';
          END IF;
        END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_project_id IS NOT NULL THEN
          query_str  := query_str || ' AND project_id = :pr_id ';
        END IF;

        IF p_task_id IS NOT NULL THEN
          query_str  := query_str || ' AND task_id = :ta_id ';
        END IF;

        /*IF p_site_id IS NOT NULL THEN
           query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND planning_organization_id = :site_id ' ;
         ELSIF p_vendor_id is NOT NULL THEN
           query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND  planning_organization_id in ';
           query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
           query_str := query_str || '  where vendor_id = :vendor_id )';
        END IF;*/
        IF (p_owning_qry_mode = 4) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 2 ';
        ELSIF(p_owning_qry_mode = 3) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        ELSIF(p_owning_qry_mode = 2) THEN
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        END IF;

        IF (p_planning_query_mode = 4) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 2 ';
        ELSIF(p_planning_query_mode = 3) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        ELSIF(p_planning_query_mode = 2) THEN
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number <= :lot_t ';
        END IF;

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || 'AND cost_group_id = :cg_id ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || 'AND revision = :rev ';
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || 'AND inventory_item_id = :item_id ';
        END IF;

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND locator_id = :loc_id ';
        END IF;

        --ER(3338592) Changes
        IF p_item_description IS NOT NULL THEN
           query_str := query_str || ' AND item_description LIKE :item_description ';
        END IF;
        --End of ER Changes

        query_str  := query_str || 'AND subinventory_code = msi.secondary_inventory_name ';

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND organization_id = :org_id ';
        END IF;

        query_str  := query_str || ') ';

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'and msi.secondary_inventory_name = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || ' and msi.organization_id = :org_id ';
        END IF;

        IF p_sub_type = 2 THEN
          query_str  := query_str || ' AND msi.subinventory_type = 2 ';
        END IF;

        query_str  := query_str || ' ORDER BY subinventory_code ';
      -- Need to use MTL_ONHAND_SERIAL_V
      ELSIF(
            (
             p_serial_number_from IS NOT NULL
             OR p_serial_number_to IS NOT NULL
             OR p_serial_attr_query IS NOT NULL
             OR p_unit_number IS NOT NULL
            )
            AND p_lpn_from IS NULL
            AND p_lpn_to IS NULL
           ) THEN
        IF p_sub_type = 2 THEN
          table_required  := ' mtl_rcv_serial_oh_v ';
        ELSIF(p_status_id IS NULL) THEN
          table_required  := ' mtl_onhand_serial_mwb_v ';
           IF is_grade_t = TRUE THEN                        -- NSRIVAST, INVCONV
              table_required  := ' mtl_onhand_serial_v ';   -- NSRIVAST, INVCONV
           END IF;
        ELSE
          table_required  := ' mtl_onhand_serial_v ';
        END IF;

        IF p_lot_attr_query IS NULL
           AND p_serial_attr_query IS NULL THEN
          query_str  := query_str || 'SELECT subinventory_code from ' || table_required;
          query_str  := query_str || 'WHERE 1=1 ';
        ELSIF p_lot_attr_query IS NULL
              AND p_serial_attr_query IS NOT NULL THEN
          query_str  :=
                query_str
             || 'SELECT subinventory_code from'
             || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
             || p_serial_attr_query
             || ') msn, '
             || table_required;
          query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NULL THEN
          query_str  :=
                query_str
             || 'SELECT subinventory_code from'
             || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln, '
             || table_required;
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NOT NULL THEN
          query_str  :=
                query_str
             || 'SELECT subinventory_code from'
             || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln, '
             || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
             || p_serial_attr_query
             || ') msn, '
             || table_required;
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
          query_str  := query_str || 'AND msn.serial_num = serial_number ';
        END IF;

        IF p_project_id IS NOT NULL THEN
          query_str  := query_str || ' AND project_id = :pr_id ';
        END IF;

        IF p_task_id IS NOT NULL THEN
          query_str  := query_str || ' AND task_id = :ta_id ';
        END IF;

        IF p_unit_number IS NOT NULL THEN
          query_str  := query_str || ' AND unit_number=:un_id ';
        END IF;

        /*IF p_site_id IS NOT NULL THEN
           query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND planning_organization_id = :site_id ' ;
         ELSIF p_vendor_id is NOT NULL THEN
           query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND  planning_organization_id in ';
           query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
           query_str := query_str || '  where vendor_id = :vendor_id )';
        END IF;*/
        IF (p_owning_qry_mode = 4) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 2 ';
        ELSIF(p_owning_qry_mode = 3) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        ELSIF(p_owning_qry_mode = 2) THEN
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        END IF;

        IF (p_planning_query_mode = 4) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 2 ';
        ELSIF(p_planning_query_mode = 3) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        ELSIF(p_planning_query_mode = 2) THEN
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        END IF;

        IF p_status_id IS NOT NULL
           AND p_sub_type <> 2 THEN
          IF p_only_subinventory_status = 1 THEN
            query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id ';
            query_str  := query_str || 'OR lot_status_id = :st_id or serial_status_id = :st_id) ';
          ELSE
            query_str  := query_str || ' and subinventory_status_id = :st_id ';
          END IF;
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number <= :lot_t ';
        END IF;

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || 'AND cost_group_id = :cg_id ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || 'AND revision = :rev ';
        END IF;

        IF p_serial_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND serial_number >= :serial_f ';
        END IF;

        IF p_serial_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND serial_number <= :serial_t ';
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || 'AND inventory_item_id = :item_id ';
        END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND locator_id = :loc_id ';
        END IF;

        --ER(3338592) Changes
        IF p_item_description IS NOT NULL THEN
           query_str := query_str || ' AND item_description LIKE :item_description ';
        END IF;
        --End of ER Changes

        query_str  := query_str || 'AND subinventory_code = msi.secondary_inventory_name ';

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND organization_id = :org_id ';
        END IF;

        query_str  := query_str || ') ';

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'and msi.secondary_inventory_name = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || ' and msi.organization_id = :org_id ';
        END IF;

        query_str  := query_str || ' ORDER BY subinventory_code ';
      -- Need to use both MTL_ONHAND_TOTAL_V and MTL_ONHAND_SERIAL_V
      ELSIF(
            p_serial_number_from IS NULL
            AND p_serial_number_to IS NULL
            AND p_unit_number IS NULL
            AND p_status_id IS NOT NULL
            AND p_lpn_from IS NULL
            AND p_lpn_to IS NULL
           ) THEN
        IF (p_status_id IS NULL) THEN
          table_required  := ' mtl_onhand_total_mwb_v ';
--          IF is_grade_t = TRUE THEN                         -- NSRIVAST, INVCONV
--             table_required  := ' mtl_onhand_new_lpn_v ';   -- NSRIVAST, INVCONV
--           END IF;
        ELSE
          table_required  := ' mtl_onhand_total_v ';
        END IF;

        IF p_lot_attr_query IS NULL THEN
          query_str  := query_str || 'SELECT subinventory_code from ' || table_required;
          query_str  := query_str || 'WHERE 1=1 ';
        ELSE
          query_str  :=
                query_str
             || 'SELECT subinventory_code from'
             || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln, '
             || table_required;
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        END IF;

        IF p_project_id IS NOT NULL THEN
          query_str  := query_str || ' AND project_id = :pr_id ';
        END IF;

        IF p_task_id IS NOT NULL THEN
          query_str  := query_str || ' AND task_id = :ta_id ';
        END IF;

        /*IF p_site_id IS NOT NULL THEN
           query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND planning_organization_id = :site_id ' ;
         ELSIF p_vendor_id is NOT NULL THEN
           query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND  planning_organization_id in ';
           query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
           query_str := query_str || '  where vendor_id = :vendor_id )';
        END IF;*/
        IF (p_owning_qry_mode = 4) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 2 ';
        ELSIF(p_owning_qry_mode = 3) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        ELSIF(p_owning_qry_mode = 2) THEN
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        END IF;

        IF (p_planning_query_mode = 4) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 2 ';
        ELSIF(p_planning_query_mode = 3) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        ELSIF(p_planning_query_mode = 2) THEN
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        END IF;

        -- Select Only subinventory status if status is not 1
        IF p_status_id IS NOT NULL THEN
          IF p_only_subinventory_status = 1 THEN
            query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id ';
            query_str  := query_str || 'OR lot_status_id = :st_id or serial_status_id = :st_id) ';
          ELSE
            query_str  := query_str || ' and subinventory_status_id = :st_id ';
          END IF;
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number <= :lot_t ';
        END IF;

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || 'AND cost_group_id = :cg_id ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || 'AND revision = :rev ';
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || 'AND inventory_item_id = :item_id ';
        END IF;

     -- NSRIVAST, INVCONV, Start
        IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
        END IF ;
        IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
        END IF ;
     -- NSRIVAST, INVCONV, End

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND locator_id = :loc_id ';
        END IF;

        --ER(3338592) Changes
        IF p_item_description IS NOT NULL THEN
           query_str := query_str || ' AND item_description LIKE :item_description ';
        END IF;
        --ER(3338592) Changes

        query_str  := query_str || 'AND subinventory_code = msi.secondary_inventory_name ';

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND organization_id = :org_id ';
        END IF;

        query_str  := query_str || 'UNION ALL ';

        IF (p_status_id IS NULL) THEN
          table_required  := ' mtl_onhand_serial_mwb_v ';
        ELSE
          table_required  := ' mtl_onhand_serial_v ';
        END IF;

        IF p_lot_attr_query IS NULL
           AND p_serial_attr_query IS NULL THEN
          query_str  := query_str || 'SELECT subinventory_code from ' || table_required;
          query_str  := query_str || 'WHERE 1=1 ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NULL THEN
          query_str  :=
                query_str
             || 'SELECT subinventory_code from'
             || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln, '
             || table_required;
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        END IF;

        -- Select Only subinventory status if status is not 1
        IF p_status_id IS NOT NULL THEN
          IF p_only_subinventory_status = 1 THEN
            query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id ';
            query_str  := query_str || 'OR lot_status_id = :st_id or serial_status_id = :st_id) ';
          ELSE
            query_str  := query_str || ' and subinventory_status_id = :st_id ';
          END IF;
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number <= :lot_t ';
        END IF;

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || 'AND cost_group_id = :cg_id ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || 'AND revision = :rev ';
        END IF;

        IF p_serial_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND serial_number >= :serial_f ';
        END IF;

        IF p_serial_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND serial_number <= :serial_t ';
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || 'AND inventory_item_id = :item_id ';
        END IF;

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND locator_id = :loc_id ';
        END IF;

        --ER(3338592) Changes
        IF p_item_description IS NOT NULL THEN
           query_str := query_str || ' AND item_description LIKE :item_description ';
        END IF;
        --ER(3338592) Changes

        query_str  := query_str || 'AND subinventory_code = msi.secondary_inventory_name ';

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND organization_id = :org_id ';
        END IF;

        query_str  := query_str || ') ';

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'and msi.secondary_inventory_name = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || ' and msi.organization_id = :org_id ';
        END IF;

        query_str  := query_str || ' ORDER BY subinventory_code ';
      -- Need to use MTL_ONHAND_LPN_V
      ELSIF(p_lpn_from IS NOT NULL
            OR p_lpn_to IS NOT NULL) THEN
        IF p_sub_type = 2 THEN
          table_required  := ' mtl_onhand_lpn_mwb_v mol ';
        ELSIF(p_status_id IS NULL) THEN
          table_required  := ' mtl_onhand_new_lpn_mwb_v mol ';
           IF is_grade_t = TRUE THEN                         -- NSRIVAST, INVCONV
             table_required  := ' mtl_onhand_new_lpn_v ';    -- NSRIVAST, INVCONV
           END IF;                                           -- NSRIVAST, INVCONV
        ELSE
          table_required  := ' mtl_onhand_new_lpn_v mol ';
        END IF;

        query_str  := query_str || 'SELECT subinventory_code from ' || table_required;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL THEN
          query_str  := query_str || ', (select outermost_lpn_id from wms_license_plate_numbers wlpn ';
          query_str  := query_str || ' WHERE 1=1 ';

          IF p_locator_id IS NOT NULL THEN
            query_str  := query_str || 'AND wlpn.locator_id = :loc_id ';
          END IF;

     -- NSRIVAST, INVCONV, Start
        IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
        END IF ;
        IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
        END IF ;
     -- NSRIVAST, INVCONV, End

          IF p_subinventory_code IS NOT NULL THEN
            query_str  := query_str || 'AND wlpn.subinventory_code = :sub ';
          END IF;

          IF p_organization_id IS NOT NULL THEN
            query_str  := query_str || 'AND wlpn.organization_id = :org_id ';
          END IF;

          IF p_lpn_from IS NOT NULL
             OR p_lpn_to IS NOT NULL THEN
            IF p_lpn_from IS NOT NULL
               AND p_lpn_to IS NULL THEN
              query_str  := query_str || ' and license_plate_number >= :lpn_f ';
            ELSIF p_lpn_from IS NULL
                  AND p_lpn_to IS NOT NULL THEN
              query_str  := query_str || ' and license_plate_number <= :lpn_t ';
            ELSIF p_lpn_from IS NOT NULL
                  AND p_lpn_to IS NOT NULL THEN
               --bugfix#3646484
               IF (p_lpn_from = p_lpn_to) THEN
               --User is querying for single LPN so converted the range query to equality query
                  query_str := query_str || 'and license_plate_number = :lpn_f ';
               ELSE
                 query_str  := query_str || ' and license_plate_number >= :lpn_f ';
                 query_str  := query_str || ' and license_plate_number <= :lpn_t ';
               END IF;
            END IF;
          END IF;

          query_str  := query_str || 'group by wlpn.outermost_lpn_id) X ';
        END IF;

        IF p_lot_attr_query IS NULL
           AND p_serial_attr_query IS NULL THEN
          query_str  := query_str || 'WHERE 1=1 ';
        ELSIF p_lot_attr_query IS NULL
              AND p_serial_attr_query IS NOT NULL THEN
          query_str  :=
                     query_str || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 ' || p_serial_attr_query
                     || ') msn ';
          query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NULL THEN
          query_str  := query_str || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 ' || p_lot_attr_query || ') mln ';
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NOT NULL THEN
          query_str  :=
                query_str
             || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln '
             || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
             || p_serial_attr_query
             || ') msn ';
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
          query_str  := query_str || 'AND msn.serial_num = serial_number ';
        END IF;

        IF p_project_id IS NOT NULL THEN
          query_str  := query_str || ' AND project_id = :pr_id ';
        END IF;

        IF p_task_id IS NOT NULL THEN
          query_str  := query_str || ' AND task_id = :ta_id ';
        END IF;

        IF p_unit_number IS NOT NULL THEN
          query_str  := query_str || ' AND unit_number=:un_id ';
        END IF;

        /*IF p_site_id IS NOT NULL THEN
           query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND planning_organization_id = :site_id ' ;
         ELSIF p_vendor_id is NOT NULL THEN
           query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND  planning_organization_id in ';
           query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
           query_str := query_str || '  where vendor_id = :vendor_id )';
        END IF;*/
        IF (p_owning_qry_mode = 4) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 2 ';
        ELSIF(p_owning_qry_mode = 3) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        ELSIF(p_owning_qry_mode = 2) THEN
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        END IF;

        IF (p_planning_query_mode = 4) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 2 ';
        ELSIF(p_planning_query_mode = 3) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        ELSIF(p_planning_query_mode = 2) THEN
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        END IF;

        IF p_status_id IS NOT NULL THEN
          IF p_only_subinventory_status = 1 THEN
            query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id ';
            query_str  := query_str || 'OR lot_status_id = :st_id or serial_status_id = :st_id) ';
          ELSE
            query_str  := query_str || 'AND subinventory_status_id = :st_id ';
          END IF;
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number <= :lot_t ';
        END IF;

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || 'AND cost_group_id = :cg_id ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || 'AND revision = :rev ';
        END IF;

        IF p_serial_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND serial_number >= :serial_f ';
        END IF;

        IF p_serial_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND serial_number <= :serial_t ';
        END IF;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL THEN
          query_str  := query_str || 'AND MOL.outermost_lpn_id = X.outermost_lpn_id ';
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || 'AND inventory_item_id = :item_id ';
        END IF;

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND locator_id = :loc_id ';
        END IF;

        --ER(3338592) Changes
        IF p_item_description IS NOT NULL THEN
           query_str := query_str || ' AND item_description LIKE :item_description ';
        END IF;
        --ER(3338592) Changes

        query_str  := query_str || 'AND subinventory_code = msi.secondary_inventory_name ';

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND organization_id = :org_id ';
        END IF;

        query_str  := query_str || ') ';

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'and msi.secondary_inventory_name = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || ' and msi.organization_id = :org_id ';
        END IF;

        query_str  := query_str || ' ORDER BY subinventory_code ';
      END IF;
    END IF;
    inv_trx_util_pub.trace( query_str, 'Add_subs Material Workbench', 9);
       --trace1(query_str, 'add_subs', 9);
    query_hdl       := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(query_hdl, query_str, DBMS_SQL.native);

    IF p_organization_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'org_id', p_organization_id);
    END IF;

    IF p_subinventory_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'sub', p_subinventory_code);
    END IF;

    IF p_locator_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'loc_id', p_locator_id);
    END IF;

    IF p_inventory_item_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'item_id', p_inventory_item_id);
    END IF;

    IF p_revision IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'rev', p_revision);
    END IF;

    IF p_cost_group_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'cg_id', p_cost_group_id);
    END IF;

    IF p_lot_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_f', p_lot_number_from);
    END IF;

    IF p_lot_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_t', p_lot_number_to);
    END IF;

-- NSRIVAST, INVCONV, Start
    IF p_grade_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_f',p_grade_from );
    END IF;
    IF p_grade_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_c', p_grade_code);
    END IF;
-- NSRIVAST, INVCONV, End

    IF p_serial_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_f', p_serial_number_from);
    END IF;

    IF p_serial_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_t', p_serial_number_to);
    END IF;

      --bugfix#3646484
      IF ((p_lpn_from IS NOT NULL) AND (p_lpn_to IS NOT NULL) AND (p_lpn_from = p_lpn_to))  THEN
      --User is querying for single LPN so converted the range query to equality query
      --So it is enought to bind the from lpn alone
         dbms_sql.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
      ELSE
          IF p_lpn_from IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
          END IF;

          IF p_lpn_to IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_t', p_lpn_to);
          END IF;
      END IF;

    IF p_status_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'st_id', p_status_id);
    END IF;

    IF p_mln_context_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'mln_context', p_mln_context_code);
    END IF;

    IF p_project_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'pr_id', p_project_id);
    END IF;

    IF p_task_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'ta_id', p_task_id);
    END IF;

    IF p_unit_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'un_id', p_unit_number);
    END IF;

    /*IF p_site_id IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'site_id', p_site_id);
     ELSIF p_vendor_id is NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'vendor_id', p_vendor_id);
    END IF;*/
    IF (p_owning_qry_mode = 4)
       OR(p_owning_qry_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'own_org', p_owning_org);
    END IF;

    IF (p_planning_query_mode = 4)
       OR(p_planning_query_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'plan_org', p_planning_org);
    END IF;

    --ER(3338592) Changes
    IF p_item_description IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl, 'item_description', p_item_description);
    END IF;

    DBMS_SQL.define_column(query_hdl, 1, sub_code, 10);
    rows_processed  := DBMS_SQL.EXECUTE(query_hdl);

    LOOP
      -- fetch a row
      IF DBMS_SQL.fetch_rows(query_hdl) > 0 THEN
        -- fetch columns from the row
        DBMS_SQL.column_value(query_hdl, 1, sub_code);

        IF j >= p_node_low_value
           AND sub_code IS NOT NULL THEN
          x_node_tbl(i).state  := p_node_state;
          x_node_tbl(i).DEPTH  := 1;
          x_node_tbl(i).label  := sub_code;
          x_node_tbl(i).icon   := 'inv_sbin';
          x_node_tbl(i).VALUE  := sub_code;
          x_node_tbl(i).TYPE   := 'SUB';
          i                    := i + 1;
        END IF;

        EXIT WHEN j >= p_node_high_value;
        j  := j + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    DBMS_SQL.close_cursor(query_hdl); -- close cursor
    x_node_value    := j;
    x_tbl_index     := i;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END add_subs;

  PROCEDURE add_locs(
    p_organization_id     IN            NUMBER DEFAULT NULL
  , p_subinventory_code   IN            VARCHAR2 DEFAULT NULL
  , p_locator_id          IN            NUMBER DEFAULT NULL
  , p_inventory_item_id   IN            NUMBER DEFAULT NULL
  , p_revision            IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_from     IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_to       IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_from  IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_to    IN            VARCHAR2 DEFAULT NULL
  , p_lpn_from            IN            VARCHAR2 DEFAULT NULL
  , p_lpn_to              IN            VARCHAR2 DEFAULT NULL
  , p_cost_group_id       IN            NUMBER DEFAULT NULL
  , p_status_id           IN            NUMBER DEFAULT NULL
  , p_lot_attr_query      IN            VARCHAR2 DEFAULT NULL
  , p_mln_context_code    IN            VARCHAR2 DEFAULT NULL
  , p_project_id          IN            NUMBER DEFAULT NULL
  , p_task_id             IN            NUMBER DEFAULT NULL
  , p_unit_number         IN            VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode     IN            NUMBER DEFAULT NULL
  , p_planning_query_mode IN            NUMBER DEFAULT NULL
  , p_owning_org          IN            NUMBER DEFAULT NULL
  , p_planning_org        IN            NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query   IN            VARCHAR2 DEFAULT NULL
  , p_only_locator_status IN            NUMBER DEFAULT 1
  , p_node_state          IN            NUMBER
  , p_node_high_value     IN            NUMBER
  , p_node_low_value      IN            NUMBER
  , p_sub_type            IN            NUMBER DEFAULT NULL --RCVLOCATORSSUPPORT
  --ER(3338592) Changes
  , p_item_description    IN            VARCHAR2 DEFAULT NULL
  --ER(3338592) Changes
  , x_node_value          IN OUT NOCOPY NUMBER
  , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index           IN OUT NOCOPY NUMBER
   -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL

  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  ) IS
    query_str      VARCHAR2(10000);
    query_hdl      NUMBER;
    rows_processed NUMBER;
    loc_id         mtl_item_locations_kfv.inventory_location_id%TYPE;
    loc_code       mtl_item_locations_kfv.concatenated_segments%TYPE;
    stock_loc_code mtl_parameters.stock_locator_control_code%TYPE;
    loc_type       NUMBER;
    i              NUMBER                                              := x_tbl_index;
    j              NUMBER                                              := x_node_value;
    table_required VARCHAR2(300);
    is_grade_t     BOOLEAN DEFAULT FALSE ; -- NSRIVAST, INVCONV
  BEGIN

  -- NSRIVAST, INVCONV, Start
     IF  (p_grade_from IS NOT NULL OR p_grade_code IS NOT NULL OR p_grade_controlled <> 0) THEN
             is_grade_t     := TRUE ;
     END IF ;
-- NSRIVAST, INVCONV, End

    /* 1625119 Should check at the Org parameters first for Locator control */
    IF (p_organization_id IS NOT NULL) THEN
      SELECT stock_locator_control_code
        INTO stock_loc_code
        FROM mtl_parameters
       WHERE organization_id = p_organization_id;

      IF stock_loc_code = 1 THEN
        RETURN;
      ELSIF stock_loc_code = 4 THEN  /* check in Subinventory  bug 1625119 */
        -- Exit out of the procedure if the subinventory is not locator controlled
        IF p_organization_id IS NOT NULL
           AND p_subinventory_code IS NOT NULL THEN
          SELECT locator_type
            INTO loc_type
            FROM mtl_secondary_inventories
           WHERE secondary_inventory_name = p_subinventory_code
             AND organization_id = p_organization_id;

          IF loc_type = 1 THEN
            RETURN;
          END IF;
        END IF;
      END IF;
    END IF;

    -- display all the LPNs in that location with the appropriate from
    -- and to LPN criteria, so include the locs which have them
    IF p_inventory_item_id IS NULL
       AND p_revision IS NULL
       AND p_lot_number_from IS NULL
       AND p_lot_number_to IS NULL
       AND p_serial_number_from IS NULL
       AND p_serial_number_to IS NULL
       AND p_cost_group_id IS NULL
       AND p_status_id IS NULL
       AND p_lot_attr_query IS NULL
       AND p_serial_attr_query IS NULL
       AND p_unit_number IS NULL
       AND p_project_id IS NULL
       AND p_task_id IS NULL
       AND(p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL)
       --ER(3338592) Changes
       AND p_item_description   IS NULL  THEN
       --ER(3338592) Changes
      query_str  := 'SELECT wlpn.locator_id, mil.concatenated_segments ';
      query_str  := query_str || 'FROM mtl_item_locations_kfv mil, wms_license_plate_numbers wlpn WHERE 1=1 ';
      query_str  := query_str || 'AND mil.inventory_location_id = wlpn.locator_id ';
      query_str  := query_str || 'AND mil.organization_id = wlpn.organization_id ';

      IF p_sub_type = 2 THEN
        query_str  := query_str || 'AND lpn_context = 3 ';
      ELSE
        query_str  := query_str || ' AND (lpn_context = 1 or lpn_context=9 or lpn_context=11 ) ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND wlpn.locator_id = :loc_id ';
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND wlpn.subinventory_code = :sub ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND wlpn.organization_id = :org_id ';
      END IF;

      --bugfix#3646484
      IF ((p_lpn_from IS NOT NULL) AND (p_lpn_to IS NOT NULL) AND (p_lpn_from = p_lpn_to))  THEN
      --User is querying for single LPN so converted the range query to equality query
         query_str := query_str || 'and wlpn.license_plate_number = :lpn_f ';
      ELSE
         IF p_lpn_from IS NOT NULL THEN
           query_str  := query_str || 'and wlpn.license_plate_number >= :lpn_f ';
         END IF;

         IF p_lpn_to IS NOT NULL THEN
           query_str  := query_str || 'and wlpn.license_plate_number <= :lpn_t ';
         END IF;
      END IF;

      query_str  := query_str || ' GROUP BY locator_id, concatenated_segments ';
      query_str  := query_str || ' ORDER BY concatenated_segments ';
    ELSE
      IF (
          p_serial_number_from IS NULL
          AND p_serial_number_to IS NULL
          AND p_unit_number IS NULL
          AND p_status_id IS NULL
          AND p_lpn_from IS NULL
          AND p_lpn_to IS NULL
          AND p_serial_attr_query IS NULL
         ) THEN
        IF p_sub_type = 2 THEN
          table_required  := ' mtl_rcv_mwb_onhand_v ';
        ELSIF(p_status_id IS NULL) THEN
          table_required  := ' mtl_onhand_total_mwb_v ';
             IF is_grade_t = TRUE THEN                       -- NSRIVAST, INVCONV
             table_required  := ' mtl_onhand_total_v ';  -- NSRIVAST, INVCONV
             END IF;
        ELSE
          table_required  := ' mtl_onhand_total_v ';
        END IF;

        IF p_lot_attr_query IS NULL THEN
          query_str  := query_str || 'SELECT locator_id, locator from ' || table_required;
          query_str  := query_str || 'WHERE 1=1 ';
        ELSE
          query_str  :=
                query_str
             || 'SELECT locator_id, locator from'
             || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln, '
             || table_required;
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        END IF;

        IF p_project_id IS NOT NULL THEN
          query_str  := query_str || ' AND project_id = :pr_id ';
        END IF;

        IF p_task_id IS NOT NULL THEN
          query_str  := query_str || ' AND task_id = :ta_id ';
        END IF;

        IF p_unit_number IS NOT NULL THEN
          query_str  := query_str || ' AND unit_number=:un_id ';
        END IF;

        /*IF p_site_id IS NOT NULL THEN
           query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND planning_organization_id = :site_id ' ;
         ELSIF p_vendor_id is NOT NULL THEN
           query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND  planning_organization_id in ';
           query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
           query_str := query_str || '  where vendor_id = :vendor_id )';
        END IF;*/
        IF (p_owning_qry_mode = 4) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 2 ';
        ELSIF(p_owning_qry_mode = 3) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        ELSIF(p_owning_qry_mode = 2) THEN
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        END IF;

        IF (p_planning_query_mode = 4) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 2 ';
        ELSIF(p_planning_query_mode = 3) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        ELSIF(p_planning_query_mode = 2) THEN
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        END IF;

        IF p_status_id IS NOT NULL THEN
          IF p_only_locator_status = 1 THEN
            query_str  := query_str || 'AND (subinventory_status_id = :st_id or ';
            query_str  := query_str || 'locator_status_id = :st_id or lot_status_id = :st_id) ';
          ELSE
            query_str  := query_str || 'AND locator_status_id = :st_id ';
          END IF;
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number <= :lot_t ';
        END IF;

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || 'AND cost_group_id = :cg_id ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || 'AND revision = :rev ';
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || 'AND inventory_item_id = :item_id ';
        END IF;

        query_str  := query_str || 'AND locator_id is not null ';

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND locator_id = :loc_id ';
        END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND subinventory_code = :sub ';
        END IF;

        --ER(3338592) Changes
        IF p_item_description IS NOT NULL THEN
           query_str := query_str || ' AND item_description LIKE :item_description ';
        END IF;
        --ER(3338592) Changes

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND organization_id = :org_id ';
        END IF;

        query_str  := query_str || 'GROUP BY locator_id, locator ';
        query_str  := query_str || 'ORDER BY locator ';
      ELSIF(
            (
             p_serial_number_from IS NOT NULL
             OR p_serial_number_to IS NOT NULL
             OR p_serial_attr_query IS NOT NULL
             OR p_unit_number IS NOT NULL
            )
            AND p_lpn_from IS NULL
            AND p_lpn_to IS NULL
           ) THEN
        IF p_sub_type = 2 THEN
          table_required  := ' mtl_rcv_serial_oh_v ';
        ELSIF(p_status_id IS NULL) THEN
          table_required  := ' mtl_onhand_serial_mwb_v ';
           IF is_grade_t = TRUE THEN                       -- NSRIVAST, INVCONV
             table_required  := ' mtl_onhand_serial_v ';   -- NSRIVAST, INVCONV
          END IF;                                          -- NSRIVAST, INVCONV
        ELSE
          table_required  := ' mtl_onhand_serial_v ';
        END IF;

        IF p_lot_attr_query IS NULL
           AND p_serial_attr_query IS NULL THEN
          query_str  := query_str || 'SELECT locator_id, locator from ' || table_required;
          query_str  := query_str || 'WHERE 1=1 ';
        ELSIF p_lot_attr_query IS NULL
              AND p_serial_attr_query IS NOT NULL THEN
          query_str  :=
                query_str
             || 'SELECT locator_id, locator from'
             || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
             || p_serial_attr_query
             || ') msn, '
             || table_required;
          query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NULL THEN
          query_str  :=
                query_str
             || 'SELECT locator_id, locator from'
             || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln, '
             || table_required;
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NOT NULL THEN
          query_str  :=
                query_str
             || 'SELECT locator_id, locator from'
             || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln, '
             || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
             || p_serial_attr_query
             || ') msn, '
             || table_required;
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
          query_str  := query_str || 'AND msn.serial_num = serial_number ';
        END IF;

        IF p_project_id IS NOT NULL THEN
          query_str  := query_str || ' AND project_id = :pr_id ';
        END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_task_id IS NOT NULL THEN
          query_str  := query_str || ' AND task_id = :ta_id ';
        END IF;

        IF p_unit_number IS NOT NULL THEN
          query_str  := query_str || ' AND unit_number=:un_id ';
        END IF;

        IF p_status_id IS NOT NULL THEN
          IF p_only_locator_status = 1 THEN
            query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
            query_str  := query_str || 'lot_status_id = :st_id or serial_status_id = :st_id) ';
          ELSE
            query_str  := query_str || 'AND locator_status_id = :st_id ';
          END IF;
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number <= :lot_t ';
        END IF;

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || 'AND cost_group_id = :cg_id ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || 'AND revision = :rev ';
        END IF;

        IF p_serial_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND serial_number >= :serial_f ';
        END IF;

        IF p_serial_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND serial_number <= :serial_t ';
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || 'AND inventory_item_id = :item_id ';
        END IF;

        query_str  := query_str || 'AND locator_id is not null ';

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND locator_id = :loc_id ';
        END IF;

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND subinventory_code = :sub ';
        END IF;

         --ER(3338592) Changes
         IF p_item_description IS NOT NULL THEN
            query_str := query_str || ' AND item_description LIKE :item_description ';
         END IF;
         --ER(3338592) Changes

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND organization_id = :org_id ';
        END IF;

        query_str  := query_str || 'GROUP BY locator_id, locator ';
        query_str  := query_str || 'ORDER BY locator ';
      -- Need to use both mtl_onhand_total_v and mtl_onhand_serial_v
      ELSIF(
            p_serial_number_from IS NULL
            AND p_serial_number_to IS NULL
            AND p_unit_number IS NULL
            AND p_status_id IS NOT NULL
            AND p_lpn_from IS NULL
            AND p_lpn_to IS NULL
           ) THEN
        IF (p_status_id IS NULL) THEN
          table_required  := ' mtl_onhand_total_mwb_v ';
--        ELSIF is_grade_t = TRUE THEN                       -- NSRIVAST, INVCONV
--            table_required  := ' mtl_onhand_new_lpn_v ';   -- NSRIVAST, INVCONV
        ELSE
          table_required  := ' mtl_onhand_total_v ';
        END IF;

        query_str  := 'SELECT locator_id, locator from (';

        IF p_lot_attr_query IS NULL THEN
          query_str  := query_str || 'SELECT locator_id, locator from ' || table_required;
          query_str  := query_str || 'WHERE 1=1 ';
        ELSE
          query_str  :=
                query_str
             || 'SELECT locator_id, locator from'
             || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln, '
             || table_required;
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        END IF;

        IF p_project_id IS NOT NULL THEN
          query_str  := query_str || ' AND project_id = :pr_id ';
        END IF;

        IF p_task_id IS NOT NULL THEN
          query_str  := query_str || ' AND task_id = :ta_id ';
        END IF;

        /*IF p_site_id IS NOT NULL THEN
           query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND planning_organization_id = :site_id ' ;
         ELSIF p_vendor_id is NOT NULL THEN
           query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND  planning_organization_id in ';
           query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
           query_str := query_str || '  where vendor_id = :vendor_id )';
        END IF;*/
        IF (p_owning_qry_mode = 4) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 2 ';
        ELSIF(p_owning_qry_mode = 3) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        ELSIF(p_owning_qry_mode = 2) THEN
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        END IF;

        IF (p_planning_query_mode = 4) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 2 ';
        ELSIF(p_planning_query_mode = 3) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        ELSIF(p_planning_query_mode = 2) THEN
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        END IF;

        IF p_status_id IS NOT NULL THEN
          IF p_only_locator_status = 1 THEN
            query_str  := query_str || 'AND (subinventory_status_id = :st_id or ';
            query_str  := query_str || 'locator_status_id = :st_id or lot_status_id = :st_id) ';
          ELSE
            query_str  := query_str || 'AND locator_status_id = :st_id ';
          END IF;
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number <= :lot_t ';
        END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || 'AND cost_group_id = :cg_id ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || 'AND revision = :rev ';
        END IF;

        --query_str  := query_str || 'AND serial_number_control_code in (1,6) ';
        query_str := query_str || 'AND item_serial_control in (1,6) ';

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || 'AND inventory_item_id = :item_id ';
        END IF;

        query_str  := query_str || 'AND locator_id is not null ';

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND locator_id = :loc_id ';
        END IF;

         --ER(3338592) Changes
         IF p_item_description IS NOT NULL THEN
            query_str := query_str || ' AND item_description LIKE :item_description ';
         END IF;
         --ER(3338592) Changes

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND subinventory_code = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND organization_id = :org_id ';
        END IF;

        query_str  := query_str || 'UNION ';

        IF (p_status_id IS NULL) THEN
          table_required  := ' mtl_onhand_serial_mwb_v ';
        ELSE
          table_required  := ' mtl_onhand_serial_v ';
        END IF;

        IF p_lot_attr_query IS NULL
           AND p_serial_attr_query IS NULL THEN
          query_str  := query_str || 'SELECT locator_id, locator from ' || table_required;
          query_str  := query_str || 'WHERE 1=1 ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NULL THEN
          query_str  :=
                query_str
             || 'SELECT locator_id, locator from'
             || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln, '
             || table_required;
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        END IF;

        IF p_status_id IS NOT NULL THEN
          IF p_only_locator_status = 1 THEN
            query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
            query_str  := query_str || 'lot_status_id = :st_id or serial_status_id = :st_id) ';
          ELSE
            query_str  := query_str || 'AND locator_status_id = :st_id ';
          END IF;
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number <= :lot_t ';
        END IF;

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || 'AND cost_group_id = :cg_id ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || 'AND revision = :rev ';
        END IF;

        IF p_serial_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND serial_number >= :serial_f ';
        END IF;

        IF p_serial_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND serial_number <= :serial_t ';
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || 'AND inventory_item_id = :item_id ';
        END IF;

        query_str  := query_str || 'AND locator_id is not null ';

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND locator_id = :loc_id ';
        END IF;

        --ER(3338592) Changes
        IF p_item_description IS NOT NULL THEN
           query_str := query_str || ' AND item_description LIKE :item_description ';
        END IF;
        --ER(3338592) Changes

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND subinventory_code = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND organization_id = :org_id ';
        END IF;

        query_str  := query_str || ') GROUP BY locator_id, locator ';
        query_str  := query_str || 'ORDER BY locator ';
      -- Need to use mtl_onhand_lpn_v
      ELSIF(p_lpn_from IS NOT NULL
            OR p_lpn_to IS NOT NULL) THEN
        IF p_sub_type = 2 THEN
          table_required  := ' mtl_onhand_lpn_mwb_v mol ';
        ELSIF(p_status_id IS NULL) THEN
          table_required  := ' mtl_onhand_new_lpn_mwb_v mol ';
            IF is_grade_t = TRUE THEN                            -- NSRIVAST, INVCONV
              table_required  := ' mtl_onhand_new_lpn_v mol ';   -- NSRIVAST, INVCONV
            END IF;                                              -- NSRIVAST, INVCONV
        ELSE
          table_required  := ' mtl_onhand_new_lpn_v mol ';
        END IF;

        query_str  := 'SELECT locator_id, locator from ' || table_required;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL THEN
          query_str  := query_str || ', (select outermost_lpn_id from wms_license_plate_numbers wlpn ';
          query_str  := query_str || ' WHERE 1=1 ';

          IF p_locator_id IS NOT NULL THEN
            query_str  := query_str || 'AND wlpn.locator_id = :loc_id ';
          END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

          IF p_subinventory_code IS NOT NULL THEN
            query_str  := query_str || 'AND wlpn.subinventory_code = :sub ';
          END IF;

          IF p_organization_id IS NOT NULL THEN
            query_str  := query_str || 'AND wlpn.organization_id = :org_id ';
          END IF;

          IF p_lpn_from IS NOT NULL
             OR p_lpn_to IS NOT NULL THEN
            IF p_lpn_from IS NOT NULL
               AND p_lpn_to IS NULL THEN
              query_str  := query_str || ' and license_plate_number >= :lpn_f ';
            ELSIF p_lpn_from IS NULL
                  AND p_lpn_to IS NOT NULL THEN
              query_str  := query_str || ' and license_plate_number <= :lpn_t ';
            ELSIF p_lpn_from IS NOT NULL
                  AND p_lpn_to IS NOT NULL THEN
                --bugfix#3646484
                IF (p_lpn_from = p_lpn_to)  THEN
                --User is querying for single LPN so converted the range query to equality query
                   query_str := query_str || 'and license_plate_number = :lpn_f ';
                ELSE
                 query_str  := query_str || ' and license_plate_number >= :lpn_f ';
                 query_str  := query_str || ' and license_plate_number <= :lpn_t ';
                END IF;
            END IF;
          END IF;

          query_str  := query_str || 'group by wlpn.outermost_lpn_id) X ';
        END IF;

        IF p_lot_attr_query IS NULL
           AND p_serial_attr_query IS NULL THEN
          query_str  := query_str || 'WHERE 1=1 ';
        ELSIF p_lot_attr_query IS NULL
              AND p_serial_attr_query IS NOT NULL THEN
          query_str  :=
                     query_str || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 ' || p_serial_attr_query
                     || ') msn ';
          query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NULL THEN
          query_str  := query_str || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 ' || p_lot_attr_query || ') mln ';
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NOT NULL THEN
          query_str  :=
                query_str
             || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln '
             || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
             || p_serial_attr_query
             || ') msn ';
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
          query_str  := query_str || 'AND msn.serial_num = serial_number ';
        END IF;

        IF p_project_id IS NOT NULL THEN
          query_str  := query_str || ' AND project_id = :pr_id ';
        END IF;

        IF p_task_id IS NOT NULL THEN
          query_str  := query_str || ' AND task_id = :ta_id ';
        END IF;

        IF p_unit_number IS NOT NULL THEN
          query_str  := query_str || ' AND unit_number=:un_id ';
        END IF;

        /*IF p_site_id IS NOT NULL THEN
           query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND planning_organization_id = :site_id ' ;
         ELSIF p_vendor_id is NOT NULL THEN
           query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND  planning_organization_id in ';
           query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
           query_str := query_str || '  where vendor_id = :vendor_id )';
        END IF;*/
        IF (p_owning_qry_mode = 4) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 2 ';
        ELSIF(p_owning_qry_mode = 3) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        ELSIF(p_owning_qry_mode = 2) THEN
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        END IF;

        IF (p_planning_query_mode = 4) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 2 ';
        ELSIF(p_planning_query_mode = 3) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        ELSIF(p_planning_query_mode = 2) THEN
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        END IF;

        IF p_status_id IS NOT NULL THEN
          IF p_only_locator_status = 1 THEN
            query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
            query_str  := query_str || 'lot_status_id = :st_id or serial_status_id = :st_id) ';
          ELSE
            query_str  := query_str || 'AND locator_status_id = :st_id ';
          END IF;
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number <= :lot_t ';
        END IF;

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || 'AND cost_group_id = :cg_id ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || 'AND revision = :rev ';
        END IF;

        IF p_serial_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND serial_number >= :serial_f ';
        END IF;

        IF p_serial_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND serial_number <= :serial_t ';
        END IF;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL THEN
          query_str  := query_str || 'AND mol.outermost_lpn_id = X.outermost_lpn_id ';
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || 'AND inventory_item_id = :item_id ';
        END IF;

        query_str  := query_str || 'AND locator_id is not null ';

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND locator_id = :loc_id ';
        END IF;

        --ER(3338592) Changes
        IF p_item_description IS NOT NULL THEN
           query_str := query_str || ' AND item_description LIKE :item_description ';
        END IF;
        --ER(3338592) Changes

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND subinventory_code = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND organization_id = :org_id ';
        END IF;

        query_str  := query_str || 'GROUP BY locator_id, locator ';
        query_str  := query_str || 'ORDER BY locator ';
      END IF;
    END IF;

        inv_trx_util_pub.trace(query_str, 'Add Loc :- Material Workbench', 9);
       --trace1(query_str, 'add_locs', 9);

    query_hdl       := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(query_hdl, query_str, DBMS_SQL.native);

    IF p_organization_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'org_id', p_organization_id);
    END IF;

    IF p_subinventory_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'sub', p_subinventory_code);
    END IF;

    IF p_locator_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'loc_id', p_locator_id);
    END IF;

    IF p_inventory_item_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'item_id', p_inventory_item_id);
    END IF;

    IF p_revision IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'rev', p_revision);
    END IF;

    IF p_cost_group_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'cg_id', p_cost_group_id);
    END IF;

    IF p_lot_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_f', p_lot_number_from);
    END IF;

    IF p_lot_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_t', p_lot_number_to);
    END IF;

-- NSRIVAST, INVCONV, Start
    IF p_grade_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_f',p_grade_from );
    END IF;
    IF p_grade_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_c', p_grade_code);
    END IF;
-- NSRIVAST, INVCONV, End

    IF p_serial_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_f', p_serial_number_from);
    END IF;

    IF p_serial_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_t', p_serial_number_to);
    END IF;

      --bugfix#3646484
      IF ((p_lpn_from IS NOT NULL) AND (p_lpn_to IS NOT NULL) AND (p_lpn_from = p_lpn_to))  THEN
      --User is querying for single LPN so converted the range query to equality query
      --So it is enought to bind the from lpn alone
         dbms_sql.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
      ELSE
          IF p_lpn_from IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
          END IF;

          IF p_lpn_to IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_t', p_lpn_to);
          END IF;
      END IF;

    IF p_status_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'st_id', p_status_id);
    END IF;

    IF p_project_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'pr_id', p_project_id);
    END IF;

    IF p_task_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'ta_id', p_task_id);
    END IF;

    IF p_unit_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'un_id', p_unit_number);
    END IF;

    /*IF p_site_id IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'site_id', p_site_id);
     ELSIF p_vendor_id is NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'vendor_id', p_vendor_id);
    END IF;*/
    IF (p_owning_qry_mode = 4)
       OR(p_owning_qry_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'own_org', p_owning_org);
    END IF;

    IF (p_planning_query_mode = 4)
       OR(p_planning_query_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'plan_org', p_planning_org);
    END IF;

    IF p_mln_context_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'mln_context', p_mln_context_code);
    END IF;

    --ER(3338592) Changes
    IF p_item_description IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl, 'item_description', p_item_description);
    END IF;

    DBMS_SQL.define_column(query_hdl, 1, loc_id);
    DBMS_SQL.define_column(query_hdl, 2, loc_code, 204);
    rows_processed  := DBMS_SQL.EXECUTE(query_hdl);

    LOOP
      -- fetch a row
      IF DBMS_SQL.fetch_rows(query_hdl) > 0 THEN
        -- fetch columns from the row
        DBMS_SQL.column_value(query_hdl, 1, loc_id);
        DBMS_SQL.column_value(query_hdl, 2, loc_code);

        IF j >= p_node_low_value
           AND loc_code IS NOT NULL THEN
          x_node_tbl(i).state  := p_node_state;
          x_node_tbl(i).DEPTH  := 1;
          x_node_tbl(i).label  := substr(inv_project.get_locator(loc_id,p_organization_id), 1, 80); -- Bug 6342333
          x_node_tbl(i).icon   := 'inv_stlo';
          x_node_tbl(i).VALUE  := TO_CHAR(loc_id);
          x_node_tbl(i).TYPE   := 'LOC';
          i                    := i + 1;
        END IF;

        EXIT WHEN j >= p_node_high_value;
        j  := j + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    DBMS_SQL.close_cursor(query_hdl); -- close cursor
    x_node_value    := j;
    x_tbl_index     := i;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END add_locs;

  PROCEDURE add_cgs(
    p_organization_id     IN            NUMBER DEFAULT NULL
  , p_subinventory_code   IN            VARCHAR2 DEFAULT NULL
  , p_locator_id          IN            NUMBER DEFAULT NULL
  , p_inventory_item_id   IN            NUMBER DEFAULT NULL
  , p_revision            IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_from     IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_to       IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_from  IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_to    IN            VARCHAR2 DEFAULT NULL
  , p_lpn_from            IN            VARCHAR2 DEFAULT NULL
  , p_lpn_to              IN            VARCHAR2 DEFAULT NULL
  , p_cost_group_id       IN            NUMBER DEFAULT NULL
  , p_status_id           IN            NUMBER DEFAULT NULL
  , p_lot_attr_query      IN            VARCHAR2 DEFAULT NULL
  , p_mln_context_code    IN            VARCHAR2 DEFAULT NULL
  , p_project_id          IN            NUMBER DEFAULT NULL
  , p_task_id             IN            NUMBER DEFAULT NULL
  , p_unit_number         IN            VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode     IN            NUMBER DEFAULT NULL
  , p_planning_query_mode IN            NUMBER DEFAULT NULL
  , p_owning_org          IN            NUMBER DEFAULT NULL
  , p_planning_org        IN            NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query   IN            VARCHAR2 DEFAULT NULL
  , p_node_state          IN            NUMBER
  , p_node_high_value     IN            NUMBER
  , p_node_low_value      IN            NUMBER
  --ER(3338592) Changes
  , p_item_description    IN            VARCHAR2 DEFAULT NULL
  , p_qty_from            IN            NUMBER   DEFAULT NULL
  , p_qty_to              IN            NUMBER   DEFAULT NULL
  --ER(3338592) Changes
  , p_responsibility_id   IN            NUMBER   DEFAULT NULL   -- Bug #3411938
  , p_resp_application_id IN            NUMBER   DEFAULT NULL
  , x_node_value          IN OUT NOCOPY NUMBER
  , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index           IN OUT NOCOPY NUMBER
   -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL

  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  ) IS
    query_str      VARCHAR2(10000);
    query_hdl      NUMBER;
    rows_processed NUMBER;
    cg_id          cst_cost_groups.cost_group_id%TYPE;
    cg             cst_cost_groups.cost_group%TYPE;
    i              NUMBER                               := x_tbl_index;
    j              NUMBER                               := x_node_value;
    table_required VARCHAR2(300);
    --ER(3338592) Changes
    group_str      VARCHAR2(10000) ;
    having_str     VARCHAR2(10000) := ' HAVING 1=1 ';
    --ER(3338592) Changes
    is_grade_t     BOOLEAN DEFAULT FALSE ; -- NSRIVAST, INVCONV
  BEGIN

-- NSRIVAST, INVCONV, Start
     IF  (p_grade_from IS NOT NULL OR  p_grade_code IS NOT NULL OR p_grade_controlled <> 0) THEN
             is_grade_t     := TRUE ;
     END IF ;
-- NSRIVAST, INVCONV, End

    IF (
        p_serial_number_from IS NULL
        AND p_serial_number_to IS NULL
        AND p_serial_attr_query IS NULL
        AND p_unit_number IS NULL
        AND p_status_id IS NULL
        AND p_lpn_from IS NULL
        AND p_lpn_to IS NULL
        AND p_serial_attr_query IS NULL
       ) THEN
      IF (p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_total_mwb_v mot ';
            IF is_grade_t = TRUE THEN                       -- NSRIVAST, INVCONV
               table_required  := ' mtl_onhand_total_v  mot ';  -- NSRIVAST, INVCONV
            END IF;
      ELSE
        table_required  := ' mtl_onhand_total_v mot ';
      END IF;

      IF p_lot_attr_query IS NULL THEN
        query_str  := 'SELECT DISTINCT mot.cost_group_id, ccg.cost_group ';
        query_str  := query_str || 'FROM cst_cost_groups ccg, ' || table_required;
        query_str  := query_str || 'WHERE ccg.cost_group_id = mot.cost_group_id ';
      ELSE
        query_str  :=
              query_str
           || 'SELECT mot.cost_group_id, ccg.cost_group from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, cst_cost_groups ccg, '
           || table_required;
        query_str  := query_str || 'WHERE ccg.cost_group_id = mot.cost_group_id ';
        query_str  := query_str || 'AND mln.lot_num = mot.lot_number ';
      END IF;

      query_str  := query_str || 'AND ccg.cost_group_id = mot.cost_group_id ';

      --ER(3338592) Changes (If the user gives the value for the Qty then only
      --Group by clause comes in to effect)

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := ' GROUP BY  mot.organization_id ';
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , subinventory_code  ' ;
        END IF;
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , locator_id  ' ;
        END IF;
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , project_id  ' ;
        END IF;
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , p_task_id  ' ;
        END IF;
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
         query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      --Bug # 3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , revision  ' ;
        END IF;
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND mot.cost_group_id = :cg_id ';
      END IF;

      --Bug #3405473
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , mot.cost_group_id, ccg.cost_group ' ;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'AND (mot.subinventory_status_id = :st_id or ';
        query_str  := query_str || 'mot.locator_status_id = :st_id or mot.lot_status_id = :st_id) ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      --Bug #3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , planning_organization_id, planning_tp_type ';
         group_str := group_str || ' , owning_organization_id, owning_tp_type ';
         group_str := group_str || ' , item_lot_control, item_serial_control ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND mot.organization_id = :org_id ';
      ELSE
        query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id   = mot.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
      END IF;

      IF p_qty_from IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
      END IF;

      IF p_qty_to IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         query_str := query_str || group_str || having_str || '  ' ;
      --Bug #3405473
      ELSE
        query_str := query_str || ' GROUP BY  mot.cost_group_id, ccg.cost_group ' ;
      END IF;

      query_str  := query_str || 'ORDER BY ccg.cost_group ';

    ELSIF(
          (
           p_serial_number_from IS NOT NULL
           OR p_serial_number_from IS NOT NULL
           OR p_unit_number IS NOT NULL
           OR p_serial_attr_query IS NOT NULL
          )
          AND p_lpn_from IS NULL
          AND p_lpn_to IS NULL
         ) THEN
      IF (p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_serial_mwb_v mos ';
         IF is_grade_t = TRUE THEN                            -- NSRIVAST, INVCONV
            table_required  := ' mtl_onhand_serial_v mos ';   -- NSRIVAST, INVCONV
         END IF  ;                                             -- NSRIVAST, INVCONV
      ELSE
        table_required  := ' mtl_onhand_serial_v mos ';
      END IF;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := 'SELECT DISTINCT mos.cost_group_id, ccg.cost_group ';
        query_str  := query_str || 'FROM cst_cost_groups ccg, ' || table_required;
        query_str  := query_str || 'WHERE ccg.cost_group_id = mos.cost_group_id ';
      ELSIF p_lot_attr_query IS NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || 'SELECT DISTINCT mos.cost_group_id, ccg.cost_group from'
           || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn, cst_cost_groups ccg, '
           || table_required;
        query_str  := query_str || 'WHERE ccg.cost_group_id = mos.cost_group_id ';
        query_str  := query_str || 'AND msn.serial_num = serial_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  :=
              query_str
           || 'SELECT DISTINCT mos.cost_group_id, ccg.cost_group from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, cst_cost_groups ccg, '
           || table_required;
        query_str  := query_str || 'WHERE ccg.cost_group_id = mos.cost_group_id ';
        query_str  := query_str || 'AND mln.lot_num = lot_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || 'SELECT DISTINCT mos.cost_group_id, ccg.cost_group from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, '
           || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn, cst_cost_groups ccg, '
           || table_required;
        query_str  := query_str || 'WHERE ccg.cost_group_id = mos.cost_group_id ';
        query_str  := query_str || 'AND mln.lot_num = lot_number ';
        query_str  := query_str || 'AND msn.serial_num = serial_number ';
      END IF;

      --ER(3338592) Changes (If the user gives the value for the Qty then only
      --Group by clause comes in to effect)

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := ' GROUP BY  mos.organization_id  ';
      END IF;

     IF p_subinventory_code IS NOT NULL THEN
       query_str  := query_str || 'AND subinventory_code = :sub ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , subinventory_code  ' ;
        END IF;
     END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

     IF p_locator_id IS NOT NULL THEN
       query_str  := query_str || 'AND locator_id = :loc_id ';
       --ER(3338592) Changes
       IF group_str IS NOT NULL THEN
          group_str := group_str || ' , locator_id  ' ;
       END IF;
     END IF;

     IF p_project_id IS NOT NULL THEN
       query_str  := query_str || ' AND project_id = :pr_id ';
       --ER(3338592) Changes
       IF group_str IS NOT NULL THEN
          group_str := group_str || ' , project_id  ' ;
       END IF;
     END IF;

     IF p_task_id IS NOT NULL THEN
       query_str  := query_str || ' AND task_id = :ta_id ';
       --ER(3338592) Changes
       IF group_str IS NOT NULL THEN
          group_str := group_str || ' , p_task_id  ' ;
       END IF;
     END IF;

      IF p_inventory_item_id IS NOT NULL THEN
         query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      --Bug # 3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , revision  ' ;
        END IF;
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND mos.cost_group_id = :cg_id ';
      END IF;

     --Bug #3405473
     IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
        group_str := group_str || ' , mos.cost_group_id, ccg.cost_group ' ;
     END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

     IF p_unit_number IS NOT NULL THEN
       query_str  := query_str || ' AND unit_number=:un_id ';
     END IF;

     IF p_status_id IS NOT NULL THEN
       query_str  := query_str || 'AND (mos.subinventory_status_id = :st_id or mos.locator_status_id = :st_id or ';
       query_str  := query_str || 'mos.lot_status_id = :st_id or mos.serial_status_id = :st_id) ';
     END IF;

     /*IF p_site_id IS NOT NULL THEN
        query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
        query_str := query_str || ' AND planning_organization_id = :site_id ' ;
      ELSIF p_vendor_id is NOT NULL THEN
        query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
        query_str := query_str || ' AND  planning_organization_id in ';
        query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
        query_str := query_str || '  where vendor_id = :vendor_id )';
     END IF;*/

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      --Bug #3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , planning_organization_id, planning_tp_type ';
         group_str := group_str || ' , owning_organization_id, owning_tp_type ';
         group_str := group_str || ' , item_lot_control, item_serial_control ';
      END IF;

     IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND mos.organization_id = :org_id ';
     ELSE
        query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id = mos.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
     END IF;

     IF p_qty_from IS NOT NULL THEN
        having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
     END IF;

     IF p_qty_to IS NOT NULL THEN
        having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
     END IF;

     IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
        query_str := query_str || group_str || having_str || '  ' ;
     --Bug #3405473
     ELSE
       query_str := query_str || ' GROUP BY  mos.cost_group_id, ccg.cost_group ' ;
     END IF;

     query_str  := query_str || 'ORDER BY ccg.cost_group ';

    -- Need to use both mtl_onhand_total_v and mtl_onhand_serial_v
    ELSIF(
          p_serial_number_from IS NULL
          AND p_serial_number_to IS NULL
          AND p_unit_number IS NULL
          AND p_status_id IS NOT NULL
          AND p_lpn_from IS NULL
          AND p_lpn_to IS NULL
         ) THEN
      IF (p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_total_mwb_v mot ';
--      ELSIF is_grade_t = TRUE THEN                       -- NSRIVAST, INVCONV
--          table_required  := ' mtl_onhand_new_lpn_v  ';   -- NSRIVAST, INVCONV
      ELSE
        table_required  := ' mtl_onhand_total_v mot ';
      END IF;

      query_str  := 'SELECT DISTINCT cost_group_id, cost_group from (';

      IF p_lot_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT mot.cost_group_id, ccg.cost_group ';
        query_str  := query_str || 'FROM cst_cost_groups ccg, ' || table_required;
        query_str  := query_str || 'WHERE ccg.cost_group_id = mot.cost_group_id ';
      ELSE
        query_str  :=
              query_str
           || 'SELECT mot.cost_group_id, ccg.cost_group FROM '
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, cst_cost_groups ccg, '
           || table_required;
        query_str  := query_str || 'WHERE ccg.cost_group_id = mot.cost_group_id ';
        query_str  := query_str || 'AND mln.lot_num = mot.lot_number ';
      END IF;


      --ER(3338592) Changes (If the user gives the value for the Qty then only
      --Group by clause comes in to effect)

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := ' GROUP BY  mot.organization_id ';
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , subinventory_code  ' ;
        END IF;
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , locator_id  ' ;
        END IF;
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , project_id  ' ;
        END IF;
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , p_task_id  ' ;
        END IF;
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
         query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      --Bug # 3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , revision  ' ;
        END IF;
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND mot.cost_group_id = :cg_id ';
      END IF;

      --Bug #3405473
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , mot.cost_group_id, ccg.cost_group ' ;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'AND (mot.subinventory_status_id = :st_id or ';
        query_str  := query_str || 'mot.locator_status_id = :st_id or mot.lot_status_id = :st_id) ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      --Bug #3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , planning_organization_id, planning_tp_type ';
         group_str := group_str || ' , owning_organization_id, owning_tp_type ';
         group_str := group_str || ' , item_lot_control, item_serial_control ';
      END IF;

      --query_str  := query_str || 'AND mot.serial_number_control_code in (1,6) ';
      query_str := query_str || 'AND mot.item_serial_control in (1,6) ';

      IF p_qty_from IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
      END IF;

      IF p_qty_to IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         query_str := query_str || group_str || having_str || ' ' ;
      --Bug #3405473
      ELSE
         query_str := query_str || ' GROUP BY  mot.cost_group_id, ccg.cost_group ' ;
      END IF;

      query_str  := query_str || 'UNION ';

      --Reinitializing the variable
      having_str := ' HAVING 1=1 ' ;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT mos.cost_group_id, ccg.cost_group ';
        query_str  := query_str || 'FROM cst_cost_groups ccg, mtl_onhand_serial_v mos ';
        query_str  := query_str || 'WHERE ccg.cost_group_id = mos.cost_group_id ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  :=
              query_str
           || 'SELECT mos.cost_group_id, ccg.cost_group from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, cst_cost_groups ccg, mtl_onhand_serial_v mos ';
        query_str  := query_str || 'WHERE ccg.cost_group_id = mos.cost_group_id ';
        query_str  := query_str || 'AND mln.lot_num = lot_number ';
      END IF;

      --ER(3338592) Changes (If the user gives the value for the Qty then only
      --Group by clause comes in to effect)

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := ' GROUP BY  mos.organization_id ';
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , subinventory_code  ' ;
        END IF;
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , locator_id  ' ;
        END IF;
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
         query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      --Bug # 3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , revision  ' ;
        END IF;
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND mos.cost_group_id = :cg_id ';
      END IF;

      --Bug #3405473
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , mos.cost_group_id, ccg.cost_group ' ;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND mos.organization_id = :org_id ';
      ELSE
        query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id = mos.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
      END IF;

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'AND (mos.subinventory_status_id = :st_id or mos.locator_status_id = :st_id or ';
        query_str  := query_str || 'mos.lot_status_id = :st_id or mos.serial_status_id = :st_id) ';
      END IF;

      IF p_qty_from IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
      END IF;

      IF p_qty_to IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         query_str := query_str || group_str || having_str || '  ' ;
      --Bug #3405473
      ELSE
        query_str := query_str || ' GROUP BY  mos.cost_group_id, ccg.cost_group ' ;
      END IF;
      --End of ER(3338592) Changes

      query_str  := query_str || ') GROUP BY cost_group_id, cost_group ';  -- line was commented earlier, NSRIVAST
      query_str  := query_str || 'ORDER BY cost_group ';

   ELSIF(p_lpn_from IS NOT NULL
          OR p_lpn_to IS NOT NULL) THEN
      IF (p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_new_lpn_mwb_v mol ';
          IF is_grade_t = TRUE THEN                             -- NSRIVAST, INVCONV
             table_required  := ' mtl_onhand_new_lpn_v mol ';   -- NSRIVAST, INVCONV
          END IF;                                               -- NSRIVAST, INVCONV
      ELSE
        table_required  := ' mtl_onhand_new_lpn_v mol ';
      END IF;

      query_str  := 'SELECT DISTINCT mol.cost_group_id, ccg.cost_group ';
      query_str  := query_str || 'FROM cst_cost_groups ccg, ' || table_required;

      IF (p_lpn_from IS NOT NULL
          OR p_lpn_to IS NOT NULL) THEN
        query_str  := query_str || ', (select outermost_lpn_id from wms_license_plate_numbers wlpn ';
        query_str  := query_str || ' WHERE 1=1 ';

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.locator_id = :loc_id ';
        END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.subinventory_code = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.organization_id = :org_id ';
        END IF;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL THEN
          IF p_lpn_from IS NOT NULL
             AND p_lpn_to IS NULL THEN
            query_str  := query_str || ' and license_plate_number >= :lpn_f ';
          ELSIF p_lpn_from IS NULL
                AND p_lpn_to IS NOT NULL THEN
            query_str  := query_str || ' and license_plate_number <= :lpn_t ';
          ELSIF p_lpn_from IS NOT NULL
                AND p_lpn_to IS NOT NULL THEN
             --bugfix#3646484
             IF (p_lpn_from = p_lpn_to)  THEN
             --User is querying for single LPN so converted the range query to equality query
                query_str := query_str || 'and license_plate_number = :lpn_f ';
             ELSE
               query_str  := query_str || ' and license_plate_number >= :lpn_f ';
               query_str  := query_str || ' and license_plate_number <= :lpn_t ';
             END IF;
          END IF;
        END IF;

        query_str  := query_str || 'group by wlpn.outermost_lpn_id) X ';
      END IF;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
                     query_str || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 ' || p_serial_attr_query
                     || ') msn ';
        query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 ' || p_lot_attr_query || ') mln ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln '
           || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        query_str  := query_str || 'AND msn.serial_num = serial_number ';
      END IF;

      query_str  := query_str || 'AND ccg.cost_group_id = mol.cost_group_id ';

       --ER(3338592) Changes (If the user gives the value for the Qty then only
       --Group by clause comes in to effect)

       IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
          group_str := ' GROUP BY  mol.organization_id ';
       END IF;

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , subinventory_code  ' ;
        END IF;
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , locator_id  ' ;
        END IF;
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , project_id  ' ;
        END IF;
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , p_task_id  ' ;
        END IF;
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
         query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      --Bug # 3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
        --ER(3338592) Changes
        IF group_str IS NOT NULL THEN
          group_str := group_str || ' , revision  ' ;
        END IF;
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND mol.cost_group_id = :cg_id ';
      END IF;

      --Bug #3405473
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str ||' , mol.cost_group_id, ccg.cost_group ';
      END IF;

      IF p_lpn_from IS NOT NULL
         OR p_lpn_to IS NOT NULL THEN
        query_str  := query_str || ' AND mol.outermost_lpn_id = x.outermost_lpn_id ';
      END IF;

      --ER(3338592) Changes
      IF p_lpn_from IS NOT NULL OR p_lpn_to IS NOT NULL THEN
         IF group_str IS NOT NULL THEN
            group_str := group_str || ' , lpn ' ;
         END IF;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'AND (mol.subinventory_status_id = :st_id or mol.locator_status_id = :st_id or ';
        query_str  := query_str || 'mol.lot_status_id = :st_id or mol.serial_status_id = :st_id) ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      --Bug #3411938
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , planning_organization_id, planning_tp_type ';
         group_str := group_str || ' , owning_organization_id, owning_tp_type ';
         group_str := group_str || ' , item_lot_control, item_serial_control ';
      END IF;

      IF p_qty_from IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
      END IF;

      IF p_qty_to IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         query_str := query_str || group_str || having_str || ' ' ;
      --Bug #3405473
      ELSE
        query_str := query_str || ' GROUP BY  mol.cost_group_id, ccg.cost_group ' ;
      END IF;

      --query_str  := query_str || 'GROUP BY mol.cost_group_id, ccg.cost_group ';
      query_str  := query_str || 'ORDER BY ccg.cost_group ';

    END IF;

       -- Enable this during debugging
        inv_trx_util_pub.trace(query_str, 'Add- Cgs Material Workbench', 9);
        --trace1(query_str, 'add_cgs', 9);

    query_hdl       := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(query_hdl, query_str, DBMS_SQL.native);

    IF p_organization_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'org_id', p_organization_id);
    END IF;

    IF p_subinventory_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'sub', p_subinventory_code);
    END IF;

    IF p_locator_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'loc_id', p_locator_id);
    END IF;

    IF p_inventory_item_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'item_id', p_inventory_item_id);
    END IF;

    IF p_revision IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'rev', p_revision);
    END IF;

    IF p_cost_group_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'cg_id', p_cost_group_id);
    END IF;

    IF p_lot_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_f', p_lot_number_from);
    END IF;

    IF p_lot_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_t', p_lot_number_to);
    END IF;

 -- NSRIVAST, INVCONV, Start
    IF p_grade_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_f',p_grade_from );
    END IF;
    IF p_grade_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_c', p_grade_code);
    END IF;
 -- NSRIVAST, INVCONV, End

    IF p_serial_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_f', p_serial_number_from);
    END IF;

    IF p_serial_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_t', p_serial_number_to);
    END IF;

      --bugfix#3646484
      IF ((p_lpn_from IS NOT NULL) AND (p_lpn_to IS NOT NULL) AND (p_lpn_from = p_lpn_to))  THEN
      --User is querying for single LPN so converted the range query to equality query
      --So it is enought to bind the from lpn alone
         dbms_sql.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
      ELSE
          IF p_lpn_from IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
          END IF;

          IF p_lpn_to IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_t', p_lpn_to);
          END IF;
      END IF;

    IF p_status_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'st_id', p_status_id);
    END IF;

    IF p_mln_context_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'mln_context', p_mln_context_code);
    END IF;

    IF p_project_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'pr_id', p_project_id);
    END IF;

    IF p_task_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'ta_id', p_task_id);
    END IF;

    IF p_unit_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'un_id', p_unit_number);
    END IF;

    /*IF p_site_id IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'site_id', p_site_id);
     ELSIF p_vendor_id is NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'vendor_id', p_vendor_id);
    END IF;*/
    IF (p_owning_qry_mode = 4)
       OR(p_owning_qry_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'own_org', p_owning_org);
    END IF;

    IF (p_planning_query_mode = 4)
       OR(p_planning_query_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'plan_org', p_planning_org);
    END IF;

   --ER(3338592) Changes
   IF p_item_description IS NOT NULL THEN
      dbms_sql.bind_variable(query_hdl, 'item_description', p_item_description);
   END IF;

   IF p_qty_from IS NOT NULL THEN
      dbms_sql.bind_variable(query_hdl, 'qty_from', p_qty_from);
   END IF;

   IF p_qty_to IS NOT NULL THEN
      dbms_sql.bind_variable(query_hdl, 'qty_to', p_qty_to);
   END IF;
   --End of ER(3338592) Changes

   --Bug #3411938
   IF p_organization_id IS NULL THEN
      IF p_responsibility_id  IS NOT NULL THEN
         dbms_sql.bind_variable(query_hdl, 'responsibility_id', p_responsibility_id );
      END IF;

      IF p_resp_application_id  IS NOT NULL THEN
         dbms_sql.bind_variable(query_hdl, 'resp_application_id', p_resp_application_id );
      END IF;
   END IF;


    DBMS_SQL.define_column(query_hdl, 1, cg_id);
    DBMS_SQL.define_column(query_hdl, 2, cg, 10);
    rows_processed  := DBMS_SQL.EXECUTE(query_hdl);

    LOOP
      -- fetch a row
      IF DBMS_SQL.fetch_rows(query_hdl) > 0 THEN
        -- fetch columns from the row
        DBMS_SQL.column_value(query_hdl, 1, cg_id);
        DBMS_SQL.column_value(query_hdl, 2, cg);

        IF j >= p_node_low_value THEN
          x_node_tbl(i).state  := p_node_state;
          x_node_tbl(i).DEPTH  := 1;
          x_node_tbl(i).label  := cg;
          x_node_tbl(i).icon   := 'inv_cgrp';
          x_node_tbl(i).VALUE  := TO_CHAR(cg_id);
          x_node_tbl(i).TYPE   := 'COST_GROUP';
          i                    := i + 1;
        END IF;

        EXIT WHEN j >= p_node_high_value;
        j  := j + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    DBMS_SQL.close_cursor(query_hdl); -- close cursor
    x_node_value    := j;
    x_tbl_index     := i;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END add_cgs;

  PROCEDURE add_lpns(
    p_organization_id     IN            NUMBER DEFAULT NULL
  , p_subinventory_code   IN            VARCHAR2 DEFAULT NULL
  , p_locator_id          IN            NUMBER DEFAULT NULL
  , p_locator_controlled  IN            NUMBER DEFAULT 0
  , p_inventory_item_id   IN            NUMBER DEFAULT NULL
  , p_revision            IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_from     IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_to       IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_from  IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_to    IN            VARCHAR2 DEFAULT NULL
  , p_lpn_from            IN            VARCHAR2 DEFAULT NULL
  , p_lpn_to              IN            VARCHAR2 DEFAULT NULL
  , p_parent_lpn_id       IN            VARCHAR2 DEFAULT NULL
  , p_prepacked           IN            NUMBER DEFAULT NULL
  , p_cost_group_id       IN            NUMBER DEFAULT NULL
  , p_status_id           IN            NUMBER DEFAULT NULL
  , p_lot_attr_query      IN            VARCHAR2 DEFAULT NULL
  , p_mln_context_code    IN            VARCHAR2 DEFAULT NULL
  , p_project_id          IN            NUMBER DEFAULT NULL
  , p_task_id             IN            NUMBER DEFAULT NULL
  , p_unit_number         IN            VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode     IN            NUMBER DEFAULT NULL
  , p_planning_query_mode IN            NUMBER DEFAULT NULL
  , p_owning_org          IN            NUMBER DEFAULT NULL
  , p_planning_org        IN            NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query   IN            VARCHAR2 DEFAULT NULL
  , p_node_state          IN            NUMBER
  , p_node_high_value     IN            NUMBER
  , p_node_low_value      IN            NUMBER
  , p_sub_type            IN            NUMBER DEFAULT NULL --RCVLOCATORSSUPPORT
  , p_inserted_under_org  IN            VARCHAR2 DEFAULT 'N'
  --ER(3338592) Changes
  , p_item_description    IN            VARCHAR2 DEFAULT NULL
  --ER(3338592) Changes
  , x_node_value          IN OUT NOCOPY NUMBER
  , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index           IN OUT NOCOPY NUMBER
   -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL

  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  ) IS
    query_str        VARCHAR2(10000);
    query_hdl        NUMBER;
    rows_processed   NUMBER;
    lpn              wms_license_plate_numbers.license_plate_number%TYPE;
    lpn_id           wms_license_plate_numbers.lpn_id%TYPE;
    item_id          wms_license_plate_numbers.inventory_item_id%TYPE;
    item             mtl_system_items_kfv.concatenated_segments%TYPE;
    i                NUMBER                                                := x_tbl_index;
    j                NUMBER                                                := x_node_value;
    is_bind_required BOOLEAN                                               := TRUE;
    table_required   VARCHAR2(200);
    is_grade_t     BOOLEAN DEFAULT FALSE ; -- NSRIVAST, INVCONV

  BEGIN

  -- NSRIVAST, INVCONV, Start
     IF  (p_grade_from IS NOT NULL OR  p_grade_code IS NOT NULL OR p_grade_controlled <> 0) THEN
         is_grade_t     := TRUE ;
     END IF ;
-- NSRIVAST, INVCONV, End

    -- If attributes relating to contents of an LPN are not specified then
    -- display all the LPNs in that location with the appropriate from
    -- and to LPN criteria
    IF p_inventory_item_id IS NULL
       AND p_revision IS NULL
       AND p_lot_number_from IS NULL
       AND p_lot_number_to IS NULL
       AND p_serial_number_from IS NULL
       AND p_serial_number_to IS NULL
       AND p_cost_group_id IS NULL
       AND p_status_id IS NULL
       AND p_lot_attr_query IS NULL
       AND p_serial_attr_query IS NULL
       AND p_unit_number IS NULL
       AND p_project_id IS NULL
       AND p_task_id IS NULL
       AND p_planning_org IS NULL
       AND p_owning_org IS NULL
       AND(p_planning_query_mode IS NULL
           OR p_planning_query_mode = 1)
       AND(p_owning_qry_mode IS NULL
           OR p_owning_qry_mode = 1)
       --ER(3338592) Changes
       AND p_item_description   IS NULL THEN
       --ER(3338592) Changes

      IF p_parent_lpn_id IS NULL THEN
        query_str  := 'SELECT license_plate_number lpn, lpn_id, inventory_item_id ';
        query_str  := query_str || ' from wms_license_plate_numbers wln where lpn_id in ';
        query_str  := query_str || ' (select outermost_lpn_id ';
        query_str  := query_str || ' FROM wms_license_plate_numbers mol WHERE 1=1 ';

        IF p_sub_type = 2 THEN
          --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
          IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
            query_str  := query_str || ' AND mol.subinventory_code is null AND mol.locator_id is null ';
          END IF;
          --Bug#3191526
          query_str  := query_str || ' AND lpn_context = 3 ';
        ELSIF p_prepacked IS NULL THEN
          query_str  := query_str || ' AND (mol.lpn_context=1  OR mol.lpn_context=9 OR mol.lpn_context=11 ) ';
        ELSIF p_prepacked = 1 THEN
          query_str  := query_str || 'AND mol.lpn_context = 1 ';
        ELSIF p_prepacked <> 1
              AND p_prepacked <> 999 THEN
          query_str  := query_str || 'AND mol.lpn_context = :prepacked ';
        END IF;

        IF p_locator_controlled = 2 THEN
          --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
          IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
            --don't add the below locator id not null check
            NULL;
          ELSE
            query_str  := query_str || 'AND mol.locator_id IS NOT NULL ';
          END IF;
        ELSIF p_locator_controlled = 1 THEN
          query_str  := query_str || 'AND mol.locator_id IS NULL ';
        END IF;


  -- NSRIVAST, INVCONV, Start
        IF p_grade_from IS NOT NULL THEN
          query_str := query_str || ' AND grade_code = :grade_f ' ;
        END IF ;
        IF p_grade_code  IS NOT NULL THEN
          query_str := query_str || ' AND grade_code = :grade_c ' ;
        END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND mol.locator_id = :loc_id ';
        END IF;

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND mol.subinventory_code = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND mol.organization_id = :org_id ';
        END IF;

        IF p_parent_lpn_id IS NOT NULL THEN
          --bugfix#3646484 help CBO to pick the index on parent_lpn_id
          query_str := query_str || 'and mol.parent_lpn_id is not null ';
          query_str  := query_str || 'and mol.parent_lpn_id = :plpn_id ';
        END IF;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL
              AND p_parent_lpn_id IS NULL THEN
          IF p_lpn_from IS NOT NULL
             AND p_lpn_to IS NULL THEN
            query_str  := query_str || 'and mol.license_plate_number >= :lpn_f ';
          ELSIF p_lpn_from IS NULL
                AND p_lpn_to IS NOT NULL THEN
            query_str  := query_str || 'and mol.license_plate_number <= :lpn_t ';
          ELSIF p_lpn_from IS NOT NULL
                AND p_lpn_to IS NOT NULL THEN
              --bugfix#3646484
              IF (p_lpn_from = p_lpn_to)  THEN
              --User is querying for single LPN so converted the range query to equality query
                 query_str := query_str || 'and mol.license_plate_number = :lpn_f ';
              ELSE
               query_str  := query_str || 'and mol.license_plate_number >= :lpn_f ';
               query_str  := query_str || 'and mol.license_plate_number <= :lpn_t ';
              END IF;
          END IF;
        END IF;

        query_str  := query_str || ') GROUP BY wln.license_plate_number, wln.lpn_id, wln.inventory_item_id ';
        query_str  := query_str || 'ORDER BY wln.license_plate_number ';
      ELSE -- PARENT LPN ID IS NOT NULL -- ELSE FOR IF p_parent_lpn_id IS NULL THEN
        query_str  := 'SELECT license_plate_number lpn, lpn_id, inventory_item_id ';
        query_str  := query_str || 'from wms_license_plate_numbers mol where 1=1 ';

        IF p_sub_type = 2 THEN
          --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
          IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
            query_str  := query_str || ' AND mol.subinventory_code is null AND mol.locator_id is null ';
          END IF;
          --Bug#3191526
          query_str  := query_str || ' AND lpn_context = 3 ';
        ELSIF p_prepacked IS NULL THEN
          query_str  := query_str || ' AND (mol.lpn_context=1  OR mol.lpn_context=9 OR mol.lpn_context=11 ) ';
        ELSIF p_prepacked = 1 THEN
          query_str  := query_str || ' AND mol.lpn_context = 1 ';
        ELSIF p_prepacked <> 1
              AND p_prepacked <> 999 THEN
          query_str  := query_str || ' AND mol.lpn_context = :prepacked ';
        END IF;

        IF p_locator_controlled = 2 THEN
          --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
          IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
            --don't add the below locator id not null check
            NULL;
          ELSE
            query_str  := query_str || 'AND mol.locator_id IS NOT NULL ';
          END IF;
        ELSIF p_locator_controlled = 1 THEN
          query_str  := query_str || 'AND mol.locator_id IS NULL ';
        END IF;

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND mol.locator_id = :loc_id ';
        END IF;

  -- NSRIVAST, INVCONV, Start
        IF p_grade_from IS NOT NULL THEN
          query_str := query_str || ' AND grade_code = :grade_f ' ;
        END IF ;
        IF p_grade_code  IS NOT NULL THEN
          query_str := query_str || ' AND grade_code = :grade_c ' ;
        END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND mol.subinventory_code = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND mol.organization_id = :org_id ';
        END IF;

        IF p_parent_lpn_id IS NOT NULL THEN
          --bugfix#3646484 help CBO to pick the index on parent_lpn_id
          query_str := query_str || 'and mol.parent_lpn_id is not null ';
          query_str  := query_str || 'and mol.parent_lpn_id = :plpn_id ';
        END IF;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL
              AND p_parent_lpn_id IS NULL THEN
          IF p_lpn_from IS NOT NULL
             AND p_lpn_to IS NULL THEN
            query_str  := query_str || ' and mol.license_plate_number >= :lpn_f ';
          ELSIF p_lpn_from IS NULL
                AND p_lpn_to IS NOT NULL THEN
            query_str  := query_str || ' and mol.license_plate_number <= :lpn_t ';
          ELSIF p_lpn_from IS NOT NULL
                AND p_lpn_to IS NOT NULL THEN
             --bugfix#3646484
             IF (p_lpn_from = p_lpn_to)  THEN
             --User is querying for single LPN so converted the range query to equality query
                query_str := query_str || 'and mol.license_plate_number = :lpn_f ';
             ELSE
               query_str  := query_str || ' and mol.license_plate_number >= :lpn_f ';
               query_str  := query_str || 'and mol.license_plate_number <= :lpn_t ';
             END IF;
          END IF;
        END IF;

        query_str  := query_str || ' GROUP BY mol.license_plate_number, mol.lpn_id, mol.inventory_item_id ';
        query_str  := query_str || ' ORDER BY mol.license_plate_number ';
      END IF; -- FOR  IF p_parent_lpn_id IS NULL THEN
    ELSE -- some of the query criteria like item etc are not null. Else For IF p_inventory_item_id IS NULL AND  p_revision IS NULL AND ETC.
      IF p_parent_lpn_id IS NULL THEN
        IF p_sub_type = 2 THEN
          table_required  := ' mtl_onhand_lpn_mwb_v mol ';
        ELSIF(p_status_id IS NULL) THEN
          IF (p_prepacked <> 1) AND
             (p_prepacked <> 9) AND
             (p_prepacked <> 11) THEN
            table_required  := ' mtl_onhand_lpn_mwb_v mol ';
               IF is_grade_t = TRUE THEN                          -- NSRIVAST, INVCONV
                   table_required  := ' mtl_onhand_new_lpn_v mol ';   -- NSRIVAST, INVCONV
               END IF;                                            -- NSRIVAST, INVCONV
          ELSE
            table_required  := ' mtl_onhand_new_lpn_mwb_v mol ';
            IF is_grade_t = TRUE THEN                          -- NSRIVAST, INVCONV
               table_required  := ' mtl_onhand_new_lpn_v mol ';   -- NSRIVAST, INVCONV
            END IF;                                            -- NSRIVAST, INVCONV
          END IF;
        ELSE
          IF (p_prepacked <> 1) AND
             (p_prepacked <> 9) AND
             (p_prepacked <> 11) THEN
            table_required  := ' mtl_onhand_lpn_v mol ';
               IF is_grade_t = TRUE THEN                          -- NSRIVAST, INVCONV
                   table_required  := ' mtl_onhand_new_lpn_v mol ';   -- NSRIVAST, INVCONV
               END IF;                                            -- NSRIVAST, INVCONV
          ELSE
            table_required  := ' mtl_onhand_new_lpn_v mol ';
             IF is_grade_t = TRUE THEN                          -- NSRIVAST, INVCONV
                table_required  := ' mtl_onhand_new_lpn_v mol ';   -- NSRIVAST, INVCONV
             END IF;                                            -- NSRIVAST, INVCONV
          END IF;
        END IF;

        query_str  := 'SELECT license_plate_number lpn, lpn_id, inventory_item_id ';
        query_str  := query_str || ' from wms_license_plate_numbers where lpn_id in ';
        query_str  := query_str || ' (select MOL.outermost_lpn_id ';
        query_str  := query_str || ' FROM ' || table_required;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL THEN
          query_str  := query_str || ', (select outermost_lpn_id from wms_license_plate_numbers wlpn ';
          query_str  := query_str || ' WHERE 1=1 ';

          IF p_sub_type = 2 THEN
            --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
            IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
              query_str  := query_str || ' AND wlpn.subinventory_code is null AND wlpn.locator_id is null ';
            END IF;
            --Bug#3191526
            query_str  := query_str || ' AND lpn_context = 3 ';
          ELSIF p_prepacked IS NULL THEN
            query_str  := query_str || ' AND (lpn_context=1  or lpn_context=9 or lpn_context=11 )';
          ELSIF p_prepacked = 1 THEN
            query_str  := query_str || 'AND lpn_context = 1 ';
          ELSIF p_prepacked <> 1
                AND p_prepacked <> 999 THEN
            query_str  := query_str || 'AND lpn_context = :prepacked ';
          END IF;

          IF p_locator_controlled = 2 THEN
            --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
            IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
              --don't add the below locator id not null check
              NULL;
            ELSE
              query_str  := query_str || 'AND wlpn.locator_id IS NOT NULL ';
            END IF;
          ELSIF p_locator_controlled = 1 THEN
            query_str  := query_str || 'AND wlpn.locator_id IS NULL ';
          END IF;

          IF p_locator_id IS NOT NULL THEN
            query_str  := query_str || 'AND wlpn.locator_id = :loc_id ';
          END IF;

  -- NSRIVAST, INVCONV, Start
        IF p_grade_from IS NOT NULL THEN
          query_str := query_str || ' AND grade_code = :grade_f ' ;
        END IF ;
        IF p_grade_code  IS NOT NULL THEN
          query_str := query_str || ' AND grade_code = :grade_c ' ;
        END IF ;
   -- NSRIVAST, INVCONV, End

          IF p_subinventory_code IS NOT NULL THEN
            query_str  := query_str || 'AND wlpn.subinventory_code = :sub ';
          END IF;

          IF p_organization_id IS NOT NULL THEN
            query_str  := query_str || 'AND wlpn.organization_id = :org_id ';
          END IF;

          IF p_lpn_from IS NOT NULL
             OR p_lpn_to IS NOT NULL THEN
            IF p_lpn_from IS NOT NULL
               AND p_lpn_to IS NULL THEN
              query_str  := query_str || ' and license_plate_number >= :lpn_f ';
            ELSIF p_lpn_from IS NULL
                  AND p_lpn_to IS NOT NULL THEN
              query_str  := query_str || ' and license_plate_number <= :lpn_t ';
            ELSIF p_lpn_from IS NOT NULL
                  AND p_lpn_to IS NOT NULL THEN
                --bugfix#3646484
                IF (p_lpn_from = p_lpn_to)  THEN
                --User is querying for single LPN so converted the range query to equality query
                   query_str := query_str || 'and license_plate_number = :lpn_f ';
                ELSE
                 query_str  := query_str || ' and license_plate_number >= :lpn_f ';
                 query_str  := query_str || ' and license_plate_number <= :lpn_t ';
                END IF;
            END IF;
          END IF;

          query_str  := query_str || 'group by wlpn.outermost_lpn_id) X ';
        END IF;

        IF p_lot_attr_query IS NULL
           AND p_serial_attr_query IS NULL THEN
          query_str  := query_str || 'WHERE 1=1 ';
        ELSIF p_lot_attr_query IS NULL
              AND p_serial_attr_query IS NOT NULL THEN
          query_str  :=
                     query_str || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 ' || p_serial_attr_query
                     || ') msn ';
          query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NULL THEN
          query_str  := query_str || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 ' || p_lot_attr_query || ') mln ';
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        ELSIF p_lot_attr_query IS NOT NULL
              AND p_serial_attr_query IS NOT NULL THEN
          query_str  :=
                query_str
             || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
             || p_lot_attr_query
             || ') mln '
             || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
             || p_serial_attr_query
             || ') msn ';
          query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
          query_str  := query_str || 'AND msn.serial_num = serial_number ';
        END IF;

        IF p_project_id IS NOT NULL THEN
          query_str  := query_str || ' AND project_id = :pr_id ';
        END IF;

        IF p_task_id IS NOT NULL THEN
          query_str  := query_str || ' AND task_id = :ta_id ';
        END IF;

        IF p_unit_number IS NOT NULL THEN
          query_str  := query_str || ' AND unit_number=:un_id ';
        END IF;

        /*IF p_site_id IS NOT NULL THEN
           query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND planning_organization_id = :site_id ' ;
         ELSIF p_vendor_id is NOT NULL THEN
           query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
           query_str := query_str || ' AND  planning_organization_id in ';
           query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
           query_str := query_str || '  where vendor_id = :vendor_id )';
        END IF;*/
        IF (p_owning_qry_mode = 4) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 2 ';
        ELSIF(p_owning_qry_mode = 3) THEN
          query_str  := query_str || ' AND owning_organization_id = :own_org ';
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        ELSIF(p_owning_qry_mode = 2) THEN
          query_str  := query_str || ' AND owning_tp_type = 1 ';
        END IF;

        IF (p_planning_query_mode = 4) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 2 ';
        ELSIF(p_planning_query_mode = 3) THEN
          query_str  := query_str || ' AND planning_organization_id = :plan_org ';
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        ELSIF(p_planning_query_mode = 2) THEN
          query_str  := query_str || ' AND planning_tp_type = 1 ';
        END IF;

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND mol.locator_id = :loc_id ';
        END IF;

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND mol.subinventory_code = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND mol.organization_id = :org_id ';
        END IF;

        IF p_status_id IS NOT NULL THEN
          query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
          query_str  := query_str || 'lot_status_id = :st_id or serial_status_id = :st_id) ';
        END IF;

        IF p_lot_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number >= :lot_f ';
        END IF;

        IF p_lot_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND lot_number <= :lot_t ';
        END IF;

        -- NSRIVAST, INVCONV, Start
        IF p_grade_from IS NOT NULL THEN
                query_str := query_str || ' AND grade_code = :grade_f ' ;
        END IF ;
        IF p_grade_code  IS NOT NULL THEN
                  query_str := query_str || ' AND grade_code = :grade_c ' ;
        END IF ;
        -- NSRIVAST, INVCONV, End

        IF p_cost_group_id IS NOT NULL THEN
          query_str  := query_str || 'AND cost_group_id = :cg_id ';
        END IF;

        IF p_revision IS NOT NULL THEN
          query_str  := query_str || 'AND revision = :rev ';
        END IF;

        IF p_serial_number_from IS NOT NULL THEN
          query_str  := query_str || 'AND serial_number >= :serial_f ';
        END IF;

        IF p_serial_number_to IS NOT NULL THEN
          query_str  := query_str || 'AND serial_number <= :serial_t ';
        END IF;

        IF p_sub_type = 2 THEN
          --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
          IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
            query_str  := query_str || ' AND subinventory_code is null AND locator_id is null ';
          END IF;
          --Bug#3191526
          query_str  := query_str || ' AND lpn_context = 3 ';
        ELSIF p_prepacked IS NULL THEN
          query_str  := query_str || ' AND (lpn_context=1  or lpn_context=9 or lpn_context=11 ) ';
        ELSIF p_prepacked = 1 THEN
          query_str  := query_str || 'AND lpn_context = 1 ';
        ELSIF p_prepacked <> 1
              AND p_prepacked <> 999 THEN
          query_str  := query_str || 'AND lpn_context = :prepacked ';
        END IF;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL THEN
          query_str  := query_str || 'AND MOL.outermost_lpn_id= X.outermost_lpn_id ';
        END IF;

        IF p_inventory_item_id IS NOT NULL THEN
          query_str  := query_str || 'AND mol.inventory_item_id = :item_id ';
        END IF;

        IF p_locator_controlled = 2 THEN
          --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
          IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
            --don't add the below locator id not null check
            NULL;
          ELSE
            query_str  := query_str || 'AND locator_id IS NOT NULL ';
          END IF;
        ELSIF p_locator_controlled = 1 THEN
          query_str  := query_str || 'AND locator_id IS NULL ';
        END IF;

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND locator_id = :loc_id ';
        END IF;

        --ER(3338592) Changes
        IF p_item_description IS NOT NULL THEN
           query_str := query_str || ' AND item_description LIKE :item_description ';
        END IF;
        --ER(3338592) Changes

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND subinventory_code = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND organization_id = :org_id ';
        END IF;

        IF p_parent_lpn_id IS NULL THEN
          query_str  := query_str || ') GROUP BY license_plate_number, lpn_id, inventory_item_id ';
          query_str  := query_str || 'ORDER BY license_plate_number ';
        ELSE
          query_str  := query_str || 'GROUP BY lpn, MOL.lpn_id, X.inventory_item_id ';
          query_str  := query_str || 'ORDER BY lpn ';
        END IF;
      ELSE   -- comes here if query criteria contains item serial and parent lpn is there.
           -- connect by is delibarately removed from here as it is affecting performance.
           -- For details see Material workbech performance hld doc
        query_str         := query_str || ' select license_plate_number lpn, lpn_id, inventory_item_id from wms_license_plate_numbers ';
        query_str         := query_str || ' WHERE parent_lpn_id = :plpn_id ';

        IF p_sub_type = 2 THEN
          --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
          IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
            query_str  := query_str || ' AND subinventory_code is null AND locator_id is null ';
          END IF;
          --Bug#3191526
          query_str  := query_str || ' AND lpn_context = 3 ';
        ELSIF p_prepacked IS NULL THEN
          query_str  := query_str || ' AND (lpn_context=1 or lpn_context=9 or lpn_context=11 ) ';
        ELSIF p_prepacked = 1 THEN
          query_str  := query_str || 'AND lpn_context = 1 ';
        ELSIF p_prepacked <> 1
              AND p_prepacked <> 999 THEN
          query_str  := query_str || 'AND lpn_context = :prepacked ';
        END IF;

        inv_trx_util_pub.trace(query_str, 'Material Workbench :- ADD LPNs', 9);
        --trace1('QUERY STR ' || query_str, 'add_lpns', 9);

        query_hdl         := DBMS_SQL.open_cursor;
        DBMS_SQL.parse(query_hdl, query_str, DBMS_SQL.native);
        DBMS_SQL.bind_variable(query_hdl, 'plpn_id', p_parent_lpn_id);

        IF p_prepacked <> 1
           AND p_prepacked <> 999
           AND p_prepacked IS NOT NULL THEN
          DBMS_SQL.bind_variable(query_hdl, 'prepacked', p_prepacked);
        END IF;

        is_bind_required  := FALSE;
      END IF;
    END IF;

    IF (is_bind_required = TRUE) THEN
            -- Enable this during debugging
        inv_trx_util_pub.trace(query_str, 'ADD LPNs Material Workbench :', 9);
             --trace1(query_str, 'add_lpns', 9);

      query_hdl  := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(query_hdl, query_str, DBMS_SQL.native);

      IF p_organization_id IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'org_id', p_organization_id);
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'sub', p_subinventory_code);
      END IF;

      IF p_locator_id IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'loc_id', p_locator_id);
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'item_id', p_inventory_item_id);
      END IF;

      IF p_revision IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'rev', p_revision);
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'cg_id', p_cost_group_id);
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'lot_f', p_lot_number_from);
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'lot_t', p_lot_number_to);
      END IF;

   -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'grade_f',p_grade_from );
      END IF;
      IF p_grade_code IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'grade_c', p_grade_code);
      END IF;
  -- NSRIVAST, INVCONV, End

      IF p_serial_number_from IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'serial_f', p_serial_number_from);
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'serial_t', p_serial_number_to);
      END IF;

      IF p_parent_lpn_id IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'plpn_id', p_parent_lpn_id);
      END IF;

      --bugfix#3646484
      IF ((p_lpn_from IS NOT NULL) AND (p_lpn_to IS NOT NULL) AND (p_lpn_from = p_lpn_to))  THEN
      --User is querying for single LPN so converted the range query to equality query
      --So it is enought to bind the from lpn alone
         dbms_sql.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
      ELSE
         IF p_lpn_from IS NOT NULL THEN
           DBMS_SQL.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
         END IF;

         IF p_lpn_to IS NOT NULL THEN
           DBMS_SQL.bind_variable(query_hdl, 'lpn_t', p_lpn_to);
         END IF;
      END IF;

      IF p_status_id IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'st_id', p_status_id);
      END IF;

      IF p_prepacked <> 1
         AND p_prepacked <> 999
         AND p_prepacked IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'prepacked', p_prepacked);
      END IF;

      IF p_mln_context_code IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'mln_context', p_mln_context_code);
      END IF;

      IF p_project_id IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'pr_id', p_project_id);
      END IF;

      IF p_task_id IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'ta_id', p_task_id);
      END IF;

      IF p_unit_number IS NOT NULL THEN
        DBMS_SQL.bind_variable(query_hdl, 'un_id', p_unit_number);
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         dbms_sql.bind_variable(query_hdl,'site_id', p_site_id);
       ELSIF p_vendor_id is NOT NULL THEN
         dbms_sql.bind_variable(query_hdl,'vendor_id', p_vendor_id);
      END IF;*/
      IF (p_owning_qry_mode = 4)
         OR(p_owning_qry_mode = 3) THEN
        DBMS_SQL.bind_variable(query_hdl, 'own_org', p_owning_org);
      END IF;

      IF (p_planning_query_mode = 4)
         OR(p_planning_query_mode = 3) THEN
        DBMS_SQL.bind_variable(query_hdl, 'plan_org', p_planning_org);
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         dbms_sql.bind_variable(query_hdl, 'item_description', p_item_description);
      END IF;

    END IF;

    DBMS_SQL.define_column(query_hdl, 1, lpn, 30);
    DBMS_SQL.define_column(query_hdl, 2, lpn_id);
    DBMS_SQL.define_column(query_hdl, 3, item_id);
    rows_processed  := DBMS_SQL.EXECUTE(query_hdl);

    LOOP
      -- fetch a row
      IF DBMS_SQL.fetch_rows(query_hdl) > 0 THEN
        -- fetch columns from the row
        DBMS_SQL.column_value(query_hdl, 1, lpn);
        DBMS_SQL.column_value(query_hdl, 2, lpn_id);
        DBMS_SQL.column_value(query_hdl, 3, item_id);

        IF item_id IS NOT NULL
           AND item_id <> 0 THEN
          SELECT concatenated_segments
            INTO item
            FROM mtl_system_items_kfv
           WHERE organization_id = p_organization_id
             AND inventory_item_id = item_id;

          item  := ' (' || item || ')';
        ELSE
          item  := '';
        END IF;

        IF j >= p_node_low_value THEN
          x_node_tbl(i).state  := p_node_state;
          x_node_tbl(i).DEPTH  := 1;
          x_node_tbl(i).label  := lpn || item;
          x_node_tbl(i).icon   := 'inv_licn';
          x_node_tbl(i).VALUE  := TO_CHAR(lpn_id);
          x_node_tbl(i).TYPE   := 'LPN';
          i                    := i + 1;
        END IF;

        EXIT WHEN j >= p_node_high_value;
        j  := j + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    DBMS_SQL.close_cursor(query_hdl); -- close cursor
    x_node_value    := j;
    x_tbl_index     := i;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END add_lpns;

  PROCEDURE add_items(
    p_organization_id     IN            NUMBER DEFAULT NULL
  , p_subinventory_code   IN            VARCHAR2 DEFAULT NULL
  , p_locator_id          IN            NUMBER DEFAULT NULL
  , p_locator_controlled  IN            NUMBER DEFAULT 0
  , p_inventory_item_id   IN            NUMBER DEFAULT NULL
  , p_revision            IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_from     IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_to       IN            VARCHAR2 DEFAULT NULL
  , p_lot_number          IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_from  IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_to    IN            VARCHAR2 DEFAULT NULL
  , p_serial_number       IN            VARCHAR2 DEFAULT NULL
  , p_lpn_from            IN            VARCHAR2 DEFAULT NULL
  , p_lpn_to              IN            VARCHAR2 DEFAULT NULL
  , p_parent_lpn_id       IN            VARCHAR2 DEFAULT NULL
  , p_containerized       IN            NUMBER DEFAULT 0
  , p_prepacked           IN            NUMBER DEFAULT NULL
  , p_cost_group_id       IN            NUMBER DEFAULT NULL
  , p_status_id           IN            NUMBER DEFAULT NULL
  , p_lot_attr_query      IN            VARCHAR2 DEFAULT NULL
  , p_mln_context_code    IN            VARCHAR2 DEFAULT NULL
  , p_project_id          IN            NUMBER DEFAULT NULL
  , p_task_id             IN            NUMBER DEFAULT NULL
  , p_unit_number         IN            VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode     IN            NUMBER DEFAULT NULL
  , p_planning_query_mode IN            NUMBER DEFAULT NULL
  , p_owning_org          IN            NUMBER DEFAULT NULL
  , p_planning_org        IN            NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query   IN            VARCHAR2 DEFAULT NULL
  , p_node_state          IN            NUMBER
  , p_node_high_value     IN            NUMBER
  , p_node_low_value      IN            NUMBER
  , p_sub_type            IN            NUMBER DEFAULT NULL --RCVLOCATORSSUPPORT
  , p_inserted_under_org  IN            VARCHAR2 DEFAULT 'N'
  --ER(3338592) Changes
  , p_item_description    IN            VARCHAR2 DEFAULT NULL
  --ER(3338592) Changes
  , p_responsibility_id   IN            NUMBER    DEFAULT NULL  --Bug # 3411938
  , p_resp_application_id IN            NUMBER    DEFAULT NULL
  , p_qty_from            IN            NUMBER    DEFAULT NULL  --Bug # 3539766
  , p_qty_to              IN            NUMBER    DEFAULT NULL
  , x_node_value          IN OUT NOCOPY NUMBER
  , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index           IN OUT NOCOPY NUMBER
   -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL

  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  ) IS
    query_str      VARCHAR2(10000);
    query_hdl      NUMBER;
    rows_processed NUMBER;
    item_id        mtl_system_items_kfv.inventory_item_id%TYPE;
    item           mtl_system_items_kfv.concatenated_segments%TYPE;
    i              NUMBER                                            := x_tbl_index;
    j              NUMBER                                            := x_node_value;
    table_required VARCHAR2(300);

    group_str      VARCHAR2(10000) ;
    having_str     VARCHAR2(10000) := ' HAVING 1=1 ';

    is_grade_t     BOOLEAN DEFAULT FALSE ; -- NSRIVAST, INVCONV

  BEGIN
-- NSRIVAST, INVCONV, Start
    IF  (p_grade_from IS NOT NULL OR  p_grade_code IS NOT NULL OR p_grade_controlled <> 0) THEN
             is_grade_t     := TRUE ;
    END IF ;
-- NSRIVAST, INVCONV, End
    IF (
        p_serial_number_from IS NULL
        AND p_serial_number_to IS NULL
        AND p_serial_number IS NULL
        AND p_unit_number IS NULL
        AND p_status_id IS NULL
        AND p_lpn_from IS NULL
        AND p_lpn_to IS NULL
        AND p_parent_lpn_id IS NULL
        AND(NVL(p_prepacked, 1) = 1)
        AND p_serial_attr_query IS NULL
       ) THEN
      IF p_sub_type = 2 THEN
        table_required  := ' mtl_rcv_mwb_onhand_v mot ';
      ELSIF(p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_total_mwb_v mot ';
          IF is_grade_t = TRUE THEN                           -- NSRIVAST, INVCONV
            table_required  := ' mtl_onhand_total_v mot ';   -- NSRIVAST, INVCONV
          END IF;                                             -- NSRIVAST, INVCONV
      ELSE
        table_required  := ' mtl_onhand_total_v mot ';
      END IF;

      IF p_lot_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT DISTINCT inventory_item_id, item from ' || table_required;
        query_str  := query_str || 'WHERE 1=1 ';
      ELSE
        query_str  :=
              query_str
           || 'SELECT DISTINCT inventory_item_id, item from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, '
           || table_required;
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      END IF;

      --Bug # 3539766 (Group by and having clause have been added)
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
        group_str := ' GROUP BY  organization_id  ';
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || ' AND subinventory_code = :sub ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , subinventory_code  ' ;
        END IF;
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || ' AND locator_id = :loc_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , locator_id  ' ;
        END IF;
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , project_id  ' ;
        END IF;
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , p_task_id  ' ;
        END IF;
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
         query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
        IF group_str IS NOT NULL THEN
          group_str := group_str || ' , revision  ' ;
        END IF;
       END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
        IF group_str IS NOT NULL THEN
          group_str := group_str || ' , cost_group_id  ' ;
        END IF;
      END IF;

      IF p_lot_number IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number = :lot_n ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , lot_number  ' ;
         END IF;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
       query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
        query_str  := query_str || 'locator_status_id = :st_id or lot_status_id = :st_id) ';
      END IF;

      IF p_containerized = 1 THEN
        query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
      ELSIF p_containerized = 2 THEN
        query_str  := query_str || 'AND containerized_flag = 1 ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , planning_organization_id, planning_tp_type ';
         group_str := group_str || ' , owning_organization_id, owning_tp_type ';
         group_str := group_str || ' , item_lot_control, item_serial_control ';
      END IF;

      IF (p_locator_controlled = 2) THEN
        --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
        IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
          --don't add the below locator id not null check
          NULL;
        ELSE
          query_str  := query_str || 'AND locator_id IS not NULL ';
        END IF;
      ELSIF(p_locator_controlled = 1) THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      END IF;

      IF p_sub_type = 2 THEN
        --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
        IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
          query_str  := query_str || ' AND subinventory_code is null AND locator_id is null ';
        END IF;
        --Bug#3191526
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      --Bug # 3411938
      ELSE
        query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id   = mot.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
      END IF;

      IF p_qty_from IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
      END IF;

      IF p_qty_to IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
        query_str := query_str || group_str || having_str ;
      ELSE
        query_str  := query_str || 'GROUP BY inventory_item_id, item ';
      END IF;

      query_str  := query_str || 'ORDER BY item ';

    ELSIF(
          (
           p_serial_number_from IS NOT NULL
           OR p_serial_number_to IS NOT NULL
           OR p_serial_number IS NOT NULL
           OR p_unit_number IS NOT NULL
           OR p_serial_attr_query IS NOT NULL
          )
          AND p_lpn_from IS NULL
          AND p_lpn_to IS NULL
          AND p_parent_lpn_id IS NULL
          AND(NVL(p_prepacked, 1) = 1)
         ) THEN
      IF p_sub_type = 2 THEN
        table_required  := ' mtl_rcv_serial_oh_v mos ';
      ELSIF(p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_serial_mwb_v mos ';
        IF is_grade_t = TRUE THEN                           -- NSRIVAST, INVCONV
          table_required  := ' mtl_onhand_serial_v mos ';   -- NSRIVAST, INVCONV
        END IF;                                             -- NSRIVAST, INVCONV
      ELSE
        table_required  := ' mtl_onhand_serial_v mos ';
      END IF;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT DISTINCT inventory_item_id, item from ' || table_required;
        query_str  := query_str || 'WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || 'SELECT DISTINCT inventory_item_id, item from'
           || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn, '
           || table_required;
        query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  :=
              query_str
           || 'SELECT DISTINCT inventory_item_id, item from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, '
           || table_required;
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || 'SELECT DISTINCT inventory_item_id, item from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, '
           || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn, '
           || table_required;
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        query_str  := query_str || 'AND msn.serial_num = serial_number ';
      END IF;

      --Bug # 3539766 (Group By and Having clause have been added)
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
        group_str := ' GROUP BY  organization_id  ';
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , subinventory_code  ' ;
        END IF;
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , locator_id  ' ;
        END IF;
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , project_id  ' ;
        END IF;
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , p_task_id  ' ;
        END IF;
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
         query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || ' AND revision = :rev ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , revision  ' ;
        END IF;
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || ' AND cost_group_id = :cg_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , cost_group_id  ' ;
        END IF;
      END IF;

      IF p_lot_number IS NOT NULL THEN
        query_str  := query_str || ' AND lot_number = :lot_n ';
         IF group_str IS NOT NULL THEN
            group_str := group_str || ' , lot_number  ' ;
         END IF;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || ' AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || ' AND lot_number <= :lot_t ';
      END IF;

      IF p_serial_number IS NOT NULL THEN
        query_str  := query_str || ' AND serial_number = :serial_n ';
         IF group_str IS NOT NULL THEN
            group_str := group_str || ' , serial_number  ' ;
         END IF;
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || ' AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || ' AND serial_number <= :serial_t ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number = :un_id ';
         IF group_str IS NOT NULL THEN
            group_str := group_str || ' , unit_number  ' ;
         END IF;
      END IF;

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || ' AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
        query_str  := query_str || ' lot_status_id = :st_id or serial_status_id = :st_id) ';
      END IF;

      IF p_containerized = 1 THEN
        query_str  := query_str || 'AND lpn_id IS NULL ';
      ELSIF p_containerized = 1 THEN
        query_str  := query_str || 'AND lpn_id IS NOT NULL ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , planning_organization_id, planning_tp_type ';
         group_str := group_str || ' , owning_organization_id, owning_tp_type ';
         group_str := group_str || ' , item_lot_control, item_serial_control ';
      END IF;

      IF (p_locator_controlled = 2) THEN
        --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
        IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
          --don't add the below locator id not null check
          NULL;
        ELSE
          query_str  := query_str || 'AND locator_id IS not NULL ';
        END IF;
      ELSIF(p_locator_controlled = 1) THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      END IF;

      IF p_sub_type = 2 THEN
        --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
        IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
          query_str  := query_str || ' AND subinventory_code is null AND locator_id is null ';
        END IF;
        --Bug#3191526
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      --Bug # 3411938
      ELSE
        query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id   = mos.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
      END IF;

      IF p_qty_from IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
      END IF;

      IF p_qty_to IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
        query_str := query_str || group_str || having_str ;
      ELSE
        query_str  := query_str || 'GROUP BY inventory_item_id, item ';
      END IF;

      query_str  := query_str || 'ORDER BY item ';

    -- Need to use both mtl_onhand_total_v and mtl_onhand_serial_v
    ELSIF(
          p_serial_number_from IS NULL
          AND p_serial_number_to IS NULL
          AND p_serial_number IS NULL
          AND p_status_id IS NOT NULL
          AND p_unit_number IS NULL
          AND p_lpn_from IS NULL
          AND p_lpn_to IS NULL
          AND p_parent_lpn_id IS NULL
          AND(NVL(p_prepacked, 1) = 1)
         ) THEN
      query_str  := 'SELECT DISTINCT inventory_item_id, item from( ';

      IF (p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_total_mwb_v mot ';
--      ELSIF is_grade_t = TRUE THEN                           -- NSRIVAST, INVCONV
--          table_required  := ' mtl_onhand_new_lpn_v mot ';   -- NSRIVAST, INVCONV
      ELSE
        table_required  := ' mtl_onhand_total_v mot ';
      END IF;

      IF p_lot_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT inventory_item_id, item from ' || table_required;
        query_str  := query_str || 'WHERE 1=1 ';
      ELSE
        query_str  :=
              query_str
           || 'SELECT inventory_item_id, item from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, mtl_onhand_total_v ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      END IF;

      -- Bug #3539766 (Group By and Having Clause have been added)
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
        group_str := ' GROUP BY  organization_id  ';
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , subinventory_code  ' ;
        END IF;
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , locator_id  ' ;
        END IF;
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , project_id  ' ;
        END IF;
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , p_task_id  ' ;
        END IF;
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
         query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
      END IF;

      --ER(3335892) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , revision  ' ;
        END IF;
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , cost_group_id  ' ;
        END IF;
      END IF;

      IF p_lot_number IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number = :lot_n ';
         IF group_str IS NOT NULL THEN
            group_str := group_str || ' , lot_number  ' ;
          END IF;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'AND (subinventory_status_id = :st_id or ';
        query_str  := query_str || 'locator_status_id = :st_id or lot_status_id = :st_id) ';
      END IF;

      IF p_containerized = 1 THEN
        query_str  := query_str || 'AND lpn_id IS NULL ';
      ELSIF p_containerized = 1 THEN
        query_str  := query_str || 'AND lpn_id IS NOT NULL ';
      END IF;

      /*query_str := query_str || ' AND eixsts ';
              || ' ( select null from mtl_system_items msi WHERE ';
              || ' moq.organization_id = msi.organization_id and ';
              || ' moq.inventory_item_id =  msi.inventory_item_id) and ';
              || ' serial_number_control_code in (1,6) ) ';*/

      --query_str  := query_str || 'AND serial_number_control_code in (1,6) ';
      query_str  := query_str || 'AND item_serial_control in (1,6) ';

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , planning_organization_id, planning_tp_type ';
         group_str := group_str || ' , owning_organization_id, owning_tp_type ';
         group_str := group_str || ' , item_lot_control, item_serial_control ';
      END IF;

      IF (p_locator_controlled = 2) THEN
        --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
        IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
          --don't add the below locator id not null check
          NULL;
        ELSE
          query_str  := query_str || 'AND locator_id IS not NULL ';
        END IF;
      ELSIF(p_locator_controlled = 1) THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      ELSE
        query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id   = mot.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
      END IF;

      IF p_qty_from IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
      END IF;

      IF p_qty_to IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
        query_str := query_str || group_str || having_str ;
      ELSE
        query_str  := query_str || 'GROUP BY inventory_item_id, item ';
      END IF;

      query_str  := query_str || 'UNION ';

      --Reinitializing the variable
      having_str := ' HAVING 1=1 ' ;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT inventory_item_id, item from mtl_onhand_serial_v mos ';
        query_str  := query_str || 'WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  :=
              query_str
           || 'SELECT inventory_item_id, item from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, mtl_onhand_serial_v ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      END IF;

      --Bug #3539766 (Group By and Having clause have been added)
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
        group_str := ' GROUP BY  organization_id  ';
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , subinventory_code  ' ;
        END IF;
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , locator_id  ' ;
        END IF;
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , project_id  ' ;
        END IF;
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , p_task_id  ' ;
        END IF;
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
         query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , revision  ' ;
        END IF;
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , cost_group_id  ' ;
        END IF;
      END IF;

      IF p_lot_number IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number = :lot_n ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , lot_number  ' ;
        END IF;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
        query_str  := query_str || 'lot_status_id = :st_id or serial_status_id = :st_id) ';
      END IF;

      /*IF(p_vendor_id IS NULL AND p_site_id IS NULL) THEN
        IF p_containerized = 1 THEN
          query_str := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
        ELSIF p_containerized = 2 THEN
          query_str := query_str || 'AND containerized_flag = 1 ';
        END IF;
      END IF;*/

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF (p_locator_controlled = 2) THEN
        --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
        IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
          --don't add the below locator id not null check
          NULL;
        ELSE
          query_str  := query_str || 'AND locator_id IS not NULL ';
        END IF;
      ELSIF(p_locator_controlled = 1) THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , planning_organization_id, planning_tp_type ';
         group_str := group_str || ' , owning_organization_id, owning_tp_type ';
         group_str := group_str || ' , item_lot_control, item_serial_control ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      --Bug # 3411938
      ELSE
        query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id   = mos.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
      END IF;

      IF p_qty_from IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
      END IF;

      IF p_qty_to IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
        query_str := query_str || group_str || having_str ;
      ELSE
        query_str  := query_str || ' GROUP BY inventory_item_id, item ';
      END IF;

      query_str  := query_str || ') GROUP BY inventory_item_id, item ';
      query_str  := query_str || ' ORDER BY item ';

    ELSIF(p_lpn_from IS NOT NULL
          OR p_lpn_to IS NOT NULL
          OR p_parent_lpn_id IS NOT NULL
          OR(NVL(p_prepacked, 1) <> 1)) THEN
      IF (p_status_id IS NULL) THEN
        IF p_sub_type = 2 THEN
          table_required  := ' mtl_onhand_lpn_mwb_v mol ';
        ELSIF (p_prepacked <> 1) AND (p_prepacked <> 9) AND (p_prepacked <> 11) THEN
          table_required  := ' mtl_onhand_lpn_mwb_v mol ';
          IF is_grade_t = TRUE THEN                        -- NSRIVAST, INVCONV
            table_required  := ' mtl_onhand_new_lpn_v mol ';   -- NSRIVAST, INVCONV
          END IF;                                          -- NSRIVAST, INVCONV
        ELSE
          table_required  := ' mtl_onhand_new_lpn_mwb_v mol ';
          IF is_grade_t = TRUE THEN                        -- %NSRIVAST, INVCONV
            table_required  := ' mtl_onhand_new_lpn_v mol ';   -- %NSRIVAST, INVCONV
          END IF;
        END IF;
      ELSE
        IF (p_prepacked <> 1) AND (p_prepacked <> 9) AND (p_prepacked <> 11) THEN
          table_required  := ' mtl_onhand_lpn_v mol ';
          IF is_grade_t = TRUE THEN                        -- NSRIVAST, INVCONV
            table_required  := ' mtl_onhand_new_lpn_v mol ';   -- NSRIVAST, INVCONV
          END IF;                                          -- NSRIVAST, INVCONV
        ELSE
          table_required  := ' mtl_onhand_new_lpn_v mol ';
        END IF;
      END IF;

      query_str  := 'SELECT DISTINCT inventory_item_id, item ';
      query_str  := query_str || 'FROM ' || table_required;

      IF (p_lpn_from IS NOT NULL
          OR p_lpn_to IS NOT NULL)
         AND p_parent_lpn_id IS NULL THEN
        query_str  := query_str || ', (select outermost_lpn_id from wms_license_plate_numbers wlpn ';
        query_str  := query_str || ' WHERE 1=1 ';

        IF p_sub_type = 2 THEN
          --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
          IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
            query_str  := query_str || ' AND wlpn.subinventory_code is null AND wlpn.locator_id is null ';
          END IF;
          --Bug#3191526
          query_str  := query_str || ' AND lpn_context = 3 ';
        ELSIF p_prepacked IS NULL THEN
          query_str  := query_str || ' AND (lpn_context=1 or lpn_context=9 or lpn_context=11 )';
        ELSIF p_prepacked = 1 THEN
          query_str  := query_str || 'AND lpn_context = 1 ';
        ELSIF p_prepacked <> 1
              AND p_prepacked <> 999 THEN
          query_str  := query_str || 'AND lpn_context = :prepacked ';
        END IF;

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.locator_id = :loc_id ';
        END IF;

    -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.subinventory_code = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.organization_id = :org_id ';
        END IF;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL THEN
          IF p_lpn_from IS NOT NULL
             AND p_lpn_to IS NULL THEN
            query_str  := query_str || ' and license_plate_number >= :lpn_f ';
          ELSIF p_lpn_from IS NULL
                AND p_lpn_to IS NOT NULL THEN
            query_str  := query_str || ' and license_plate_number <= :lpn_t ';
          ELSIF p_lpn_from IS NOT NULL
                AND p_lpn_to IS NOT NULL THEN
             --bugfix#3646484
             IF (p_lpn_from = p_lpn_to)  THEN
             --User is querying for single LPN so converted the range query to equality query
                query_str := query_str || 'and license_plate_number = :lpn_f ';
             ELSE
               query_str  := query_str || ' and license_plate_number >= :lpn_f ';
               query_str  := query_str || ' and license_plate_number <= :lpn_t ';
             END IF;
          END IF;
        END IF;

        query_str  := query_str || 'group by wlpn.outermost_lpn_id) X ';
      END IF;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
                     query_str || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 ' || p_serial_attr_query
                     || ') msn ';
        query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 ' || p_lot_attr_query || ') mln ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln '
           || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        query_str  := query_str || 'AND msn.serial_num = serial_number ';
      END IF;

      --Bug # 3411938 (Group By and Having clause have been added)
      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
        group_str := ' GROUP BY  organization_id  ';
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , subinventory_code  ' ;
        END IF;
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , locator_id  ' ;
        END IF;
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , project_id  ' ;
        END IF;
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , p_task_id  ' ;
        END IF;
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
         query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , inventory_item_id, item_description, item ,uom ' ;
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;

    -- %NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
     IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- %NSRIVAST, INVCONV, End

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , revision  ' ;
        END IF;
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , cost_group_id  ' ;
        END IF;
      END IF;

      IF p_lot_number IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number = :lot_n ';
        IF group_str IS NOT NULL THEN
           group_str := group_str || ' , lot_number  ' ;
        END IF;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_serial_number IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number = :serial_n ';
         IF group_str IS NOT NULL THEN
            group_str := group_str || ' , serial_number  ' ;
          END IF;
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number = :un_id ';
         IF group_str IS NOT NULL THEN
            group_str := group_str || ' , unit_number  ' ;
          END IF;
      END IF;

      IF p_parent_lpn_id IS NOT NULL THEN
        query_str  := query_str || 'AND MOL.lpn_id = :plpn_id ';
         IF group_str IS NOT NULL THEN
            group_str := group_str || ' , MOL.lpn_id ' ;
          END IF;
      END IF;

      IF p_sub_type = 2 THEN
        --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
        IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
          query_str  := query_str || ' AND mol.subinventory_code is null AND mol.locator_id is null ';
        END IF;
        --Bug#3191526
        query_str  := query_str || ' AND lpn_context = 3 ';
      ELSIF p_prepacked IS NULL THEN
        query_str  := query_str || ' AND (lpn_context=1  or lpn_context=9 or lpn_context=11 ) ';
      ELSIF p_prepacked = 1 THEN
        query_str  := query_str || 'AND lpn_context = 1 ';
      ELSIF p_prepacked <> 1
            AND p_prepacked <> 999 THEN
        query_str  := query_str || 'AND lpn_context = :prepacked ';
      END IF;

      IF p_lpn_from IS NOT NULL
         OR p_lpn_to IS NOT NULL THEN
        query_str  := query_str || 'AND MOL.outermost_lpn_id = X.outermost_lpn_id ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
        query_str  := query_str || 'lot_status_id = :st_id or serial_status_id = :st_id OR :st_id IS NULL) ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
         group_str := group_str || ' , planning_organization_id, planning_tp_type ';
         group_str := group_str || ' , owning_organization_id, owning_tp_type ';
         group_str := group_str || ' , item_lot_control, item_serial_control ';
      END IF;

      IF (p_locator_controlled = 2) THEN
        --Bug#3191526 add the LPNs which don't have any sub/loc association directly after org
        IF p_inserted_under_org = 'Y' OR p_inserted_under_org = 'y' THEN
          --don't add the below locator id not null check
          NULL;
        ELSE
          query_str  := query_str || 'AND locator_id IS not NULL ';
        END IF;
      ELSIF(p_locator_controlled = 1) THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      END IF;


      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      ELSE
        query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id   = mol.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
      END IF;

      IF p_qty_from IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) >= :qty_from ';
      END IF;

      IF p_qty_to IS NOT NULL THEN
         having_str := having_str || ' AND sum(on_hand) <= :qty_to ';
      END IF;

      IF p_qty_from IS NOT NULL OR p_qty_to IS NOT NULL THEN
        query_str := query_str || group_str || having_str ;
      ELSE
        query_str  := query_str || ' GROUP BY inventory_item_id, item ';
      END IF;

      query_str  := query_str || ' ORDER BY item ';

    END IF;

    -- Enable this during debugging
    inv_trx_util_pub.trace(query_str, 'Material Workbench - Add Items : ', 9);
    --trace1(query_str, 'add_items', 9);

    query_hdl       := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(query_hdl, query_str, DBMS_SQL.native);

    IF p_organization_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'org_id', p_organization_id);
    END IF;

    IF p_subinventory_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'sub', p_subinventory_code);
    END IF;

    IF p_locator_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'loc_id', p_locator_id);
    END IF;

    IF p_inventory_item_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'item_id', p_inventory_item_id);
    END IF;

    IF p_revision IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'rev', p_revision);
    END IF;

    IF p_cost_group_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'cg_id', p_cost_group_id);
    END IF;

    IF p_lot_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_f', p_lot_number_from);
    END IF;

    IF p_lot_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_t', p_lot_number_to);
    END IF;

    IF p_lot_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_n', p_lot_number);
    END IF;

-- NSRIVAST, INVCONV, Start
    IF p_grade_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_f',p_grade_from );
    END IF;
    IF p_grade_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_c', p_grade_code);
    END IF;
-- NSRIVAST, INVCONV, End

    IF p_serial_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_f', p_serial_number_from);
    END IF;

    IF p_serial_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_t', p_serial_number_to);
    END IF;

    IF p_serial_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_n', p_serial_number);
    END IF;

      --bugfix#3646484
      IF ((p_lpn_from IS NOT NULL) AND (p_lpn_to IS NOT NULL) AND (p_lpn_from = p_lpn_to))  THEN
      --User is querying for single LPN so converted the range query to equality query
      --So it is enought to bind the from lpn alone
         dbms_sql.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
      ELSE
          IF p_lpn_from IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
          END IF;

          IF p_lpn_to IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_t', p_lpn_to);
          END IF;
      END IF;

    IF p_parent_lpn_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'plpn_id', p_parent_lpn_id);
    END IF;

    IF p_status_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'st_id', p_status_id);
    END IF;

    IF p_prepacked <> 1
       AND p_prepacked <> 999
       AND p_prepacked IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'prepacked', p_prepacked);
    END IF;

    IF p_mln_context_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'mln_context', p_mln_context_code);
    END IF;

    IF p_project_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'pr_id', p_project_id);
    END IF;

    IF p_task_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'ta_id', p_task_id);
    END IF;

    IF p_unit_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'un_id', p_unit_number);
    END IF;

    /*IF p_site_id IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'site_id', p_site_id);
     ELSIF p_vendor_id is NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'vendor_id', p_vendor_id);
    END IF;*/
    IF (p_owning_qry_mode = 4)
       OR(p_owning_qry_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'own_org', p_owning_org);
    END IF;

    IF (p_planning_query_mode = 4)
       OR(p_planning_query_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'plan_org', p_planning_org);
    END IF;

    --ER(3338592) Changes
    IF p_item_description IS NOT NULL THEN
      dbms_sql.bind_variable(query_hdl, 'item_description', p_item_description);
    END IF;

    --Bug #3411938
    IF p_organization_id IS NULL THEN
       IF p_responsibility_id  IS NOT NULL THEN
          dbms_sql.bind_variable(query_hdl, 'responsibility_id', p_responsibility_id );
       END IF;

       IF p_resp_application_id  IS NOT NULL THEN
          dbms_sql.bind_variable(query_hdl, 'resp_application_id', p_resp_application_id );
       END IF;
    END IF;

   --Bug # 3539766
   IF p_qty_from IS NOT NULL THEN
     dbms_sql.bind_variable(query_hdl, 'qty_from', p_qty_from);
   END IF;

   IF p_qty_to IS NOT NULL THEN
      dbms_sql.bind_variable(query_hdl, 'qty_to', p_qty_to);
   END IF;


    DBMS_SQL.define_column(query_hdl, 1, item_id);
    DBMS_SQL.define_column(query_hdl, 2, item, 40);
    rows_processed  := DBMS_SQL.EXECUTE(query_hdl);

    LOOP
      -- fetch a row
      IF DBMS_SQL.fetch_rows(query_hdl) > 0 THEN
        -- fetch columns from the row
        DBMS_SQL.column_value(query_hdl, 1, item_id);
        DBMS_SQL.column_value(query_hdl, 2, item);

        IF j >= p_node_low_value THEN
          x_node_tbl(i).state  := p_node_state;
          x_node_tbl(i).DEPTH  := 1;
          x_node_tbl(i).label  := item;
          x_node_tbl(i).icon   := 'inv_item';
          x_node_tbl(i).VALUE  := TO_CHAR(item_id);
          x_node_tbl(i).TYPE   := 'ITEM';
          i                    := i + 1;
        END IF;

        EXIT WHEN j >= p_node_high_value;
        j  := j + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    DBMS_SQL.close_cursor(query_hdl); -- close cursor
    x_node_value    := j;
    x_tbl_index     := i;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END add_items;

  PROCEDURE add_revs(
    p_organization_id     IN            NUMBER DEFAULT NULL
  , p_subinventory_code   IN            VARCHAR2 DEFAULT NULL
  , p_locator_id          IN            NUMBER DEFAULT NULL
  , p_locator_controlled  IN            NUMBER DEFAULT 0
  , p_inventory_item_id   IN            NUMBER DEFAULT NULL
  , p_revision            IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_from     IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_to       IN            VARCHAR2 DEFAULT NULL
  , p_lot_number          IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_from  IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_to    IN            VARCHAR2 DEFAULT NULL
  , p_serial_number       IN            VARCHAR2 DEFAULT NULL
  , p_lpn_from            IN            VARCHAR2 DEFAULT NULL
  , p_lpn_to              IN            VARCHAR2 DEFAULT NULL
  , p_parent_lpn_id       IN            VARCHAR2 DEFAULT NULL
  , p_containerized       IN            NUMBER DEFAULT 0
  , p_prepacked           IN            NUMBER DEFAULT NULL
  , p_cost_group_id       IN            NUMBER DEFAULT NULL
  , p_status_id           IN            NUMBER DEFAULT NULL
  , p_lot_attr_query      IN            VARCHAR2 DEFAULT NULL
  , p_mln_context_code    IN            VARCHAR2 DEFAULT NULL
  , p_project_id          IN            NUMBER DEFAULT NULL
  , p_task_id             IN            NUMBER DEFAULT NULL
  , p_unit_number         IN            VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode     IN            NUMBER DEFAULT NULL
  , p_planning_query_mode IN            NUMBER DEFAULT NULL
  , p_owning_org          IN            NUMBER DEFAULT NULL
  , p_planning_org        IN            NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query   IN            VARCHAR2 DEFAULT NULL
  , p_node_state          IN            NUMBER
  , p_node_high_value     IN            NUMBER
  , p_node_low_value      IN            NUMBER
  , p_sub_type            IN            NUMBER DEFAULT NULL --RCVLOCATORSSUPPORT
  --ER(3338592) Changes
  , p_item_description    IN            VARCHAR2 DEFAULT NULL
  --ER(3338592) Changes
  , x_node_value          IN OUT NOCOPY NUMBER
  , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index           IN OUT NOCOPY NUMBER
   -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL

  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  ) IS
    query_str      VARCHAR2(10000);
    query_hdl      NUMBER;
    rows_processed NUMBER;
    item           mtl_system_items_kfv.concatenated_segments%TYPE;
    rev            mtl_onhand_quantities.revision%TYPE;
    rev_control    NUMBER;
    i              NUMBER                                            := x_tbl_index;
    j              NUMBER                                            := x_node_value;
    table_required VARCHAR2(300);
    is_grade_t     BOOLEAN DEFAULT FALSE ; -- NSRIVAST, INVCONV
  BEGIN
-- NSRIVAST, INVCONV, Start
     IF  (p_grade_from IS NOT NULL OR p_grade_code IS NOT NULL OR p_grade_controlled <> 0) THEN
          is_grade_t     := TRUE ;
     END IF ;
-- NSRIVAST, INVCONV, End

    -- Exit out of the procedure if the item is not revision controlled
    IF p_organization_id IS NOT NULL
       AND p_inventory_item_id IS NOT NULL THEN
      SELECT revision_qty_control_code
        INTO rev_control
        FROM mtl_system_items
       WHERE organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id;

      IF rev_control = 1 THEN
        RETURN;
      END IF;
    END IF;

    IF (
        p_serial_number_from IS NULL
        AND p_serial_number_to IS NULL
        AND p_serial_number IS NULL
        AND p_status_id IS NULL
        AND p_lpn_from IS NULL
        AND p_lpn_to IS NULL
        AND p_parent_lpn_id IS NULL
        AND(NVL(p_prepacked, 1) = 1)
        AND p_serial_attr_query IS NULL
       ) THEN
      IF p_sub_type = 2 THEN
        table_required  := ' mtl_rcv_mwb_onhand_v ';
      ELSIF(p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_total_mwb_v ';
           IF is_grade_t = TRUE THEN                       -- NSRIVAST, INVCONV
              table_required  := ' mtl_onhand_total_v ';  -- NSRIVAST, INVCONV
           END IF;
      ELSE
        table_required  := ' mtl_onhand_total_v ';
      END IF;

      IF p_lot_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT item, revision from ' || table_required;
        query_str  := query_str || 'WHERE 1=1 ';
      ELSE
        query_str  :=
              query_str
           || 'SELECT item, revision from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, '
           || table_required;
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'AND (subinventory_status_id = :st_id OR ';
        query_str  := query_str || 'locator_status_id = :st_id or lot_status_id = :st_id) ';
      END IF;

      IF p_lot_number IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number = :lot_n ';
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

   -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
      END IF;

      IF p_containerized = 1 THEN
        query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
      ELSIF p_containerized = 2 THEN
        query_str  := query_str || 'AND containerized_flag = 1 ';
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_locator_controlled = 1 THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      ELSIF p_locator_controlled = 2 THEN
        query_str  := query_str || 'AND locator_id IS NOT NULL ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/
      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      query_str  := query_str || 'GROUP BY item, revision ';
      query_str  := query_str || 'ORDER BY revision ';
    ELSIF(
          (
           p_serial_number_from IS NOT NULL
           OR p_serial_number_from IS NOT NULL
           OR p_serial_number IS NOT NULL
           OR p_serial_attr_query IS NOT NULL
          )
          AND p_lpn_from IS NULL
          AND p_lpn_to IS NULL
          AND p_parent_lpn_id IS NULL
          AND(NVL(p_prepacked, 1) = 1)
         ) THEN
      IF p_sub_type = 2 THEN
        table_required  := ' mtl_rcv_serial_oh_v ';
      ELSIF(p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_serial_mwb_v ';
        IF is_grade_t = TRUE THEN                       -- NSRIVAST, INVCONV
          table_required  := ' mtl_onhand_serial_v ';   -- NSRIVAST, INVCONV
        END IF;                                         -- NSRIVAST, INVCONV
      ELSE
        table_required  := ' mtl_onhand_serial_v ';
      END IF;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT item, revision from mtl_onhand_serial_v ';
        query_str  := query_str || 'WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || 'SELECT item, revision from'
           || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn, mtl_onhand_serial_v ';
        query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  :=
              query_str
           || 'SELECT item, revision from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, mtl_onhand_serial_v ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || 'SELECT item, revision from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, '
           || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn, mtl_onhand_serial_v ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        query_str  := query_str || 'AND msn.serial_num = serial_number ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
        query_str  := query_str || 'lot_status_id = :st_id or serial_status_id = :st_id) ';
      END IF;

      IF p_lot_number IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number = :lot_n ';
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
      END IF;

      IF p_serial_number IS NOT NULL THEN
        query_str  := query_str || 'AND (serial_number = :serial_n) ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      /*IF(p_vendor_id IS NULL AND p_site_id IS NULL) THEN
        IF p_containerized = 1 THEN
          query_str := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
        ELSIF p_containerized = 2 THEN
          query_str := query_str || 'AND containerized_flag = 1 ';
        END IF;
      END IF;*/
      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_locator_controlled = 1 THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      ELSIF p_locator_controlled = 2 THEN
        query_str  := query_str || 'AND locator_id IS NOT NULL ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/
      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      query_str  := query_str || 'GROUP BY item, revision ';
      query_str  := query_str || 'ORDER BY revision ';
    -- Need to query both mtl_onhand_total_v and mtl_onhand_serial_v
    ELSIF(
          p_serial_number_from IS NULL
          AND p_serial_number_to IS NULL
          AND p_serial_number IS NULL
          AND p_status_id IS NOT NULL
          AND p_lpn_from IS NULL
          AND p_lpn_to IS NULL
          AND p_parent_lpn_id IS NULL
          AND(NVL(p_prepacked, 1) = 1)
         ) THEN
      IF (p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_total_mwb_v  ';
--      ELSIF is_grade_t = TRUE THEN                       -- NSRIVAST, INVCONV
--          table_required  := ' mtl_onhand_new_lpn_v ';   -- NSRIVAST, INVCONV
      ELSE
        table_required  := ' mtl_onhand_total_v ';
      END IF;

      query_str  := 'SELECT item, revision from( ';

      IF p_lot_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT item, revision from ' || table_required;
        query_str  := query_str || 'WHERE 1=1 ';
      ELSE
        query_str  :=
              query_str
           || 'SELECT item, revision from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, '
           || table_required;
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'AND (subinventory_status_id = :st_id OR ';
        query_str  := query_str || 'locator_status_id = :st_id or lot_status_id = :st_id) ';
      END IF;

      IF p_lot_number IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number = :lot_n ';
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
      END IF;

      IF p_containerized = 1 THEN
        query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
      ELSIF p_containerized = 2 THEN
        query_str  := query_str || 'AND containerized_flag = 1 ';
      END IF;

      --query_str  := query_str || 'AND serial_number_control_code in (1,6) ';
      query_str := query_str || 'AND item_serial_control in (1,6) ';

      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_locator_controlled = 1 THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      ELSIF p_locator_controlled = 2 THEN
        query_str  := query_str || 'AND locator_id IS NOT NULL ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/
      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      query_str  := query_str || 'UNION ';

      IF (p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_serial_mwb_v  ';
      ELSE
        table_required  := ' mtl_onhand_serial_v ';
      END IF;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT item, revision from ' || table_required;
        query_str  := query_str || 'WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  :=
              query_str
           || 'SELECT item, revision from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, mtl_onhand_serial_v ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
        query_str  := query_str || 'lot_status_id = :st_id or serial_status_id = :st_id) ';
      END IF;

      IF p_lot_number IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number = :lot_n ';
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
      END IF;

      IF p_serial_number IS NOT NULL THEN
        query_str  := query_str || 'AND (serial_number = :serial_n) ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      IF p_containerized = 1 THEN
        query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
      ELSIF p_containerized = 2 THEN
        query_str  := query_str || 'AND containerized_flag = 1 ';
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_locator_controlled = 1 THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      ELSIF p_locator_controlled = 2 THEN
        query_str  := query_str || 'AND locator_id IS NOT NULL ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
      END IF;

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/
      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      query_str  := query_str || ') GROUP BY item, revision ';
      query_str  := query_str || 'ORDER BY revision ';
    ELSIF(p_lpn_from IS NOT NULL
          OR p_lpn_to IS NOT NULL
          OR p_parent_lpn_id IS NOT NULL
          OR(NVL(p_prepacked, 1) <> 1)) THEN
      IF p_sub_type = 2 THEN
        table_required  := ' mtl_onhand_lpn_mwb_v mol ';
      ELSIF(p_status_id IS NULL) THEN
        IF (p_prepacked <> 1) AND (p_prepacked <> 9) AND (p_prepacked <> 11) THEN
          table_required  := ' mtl_onhand_lpn_mwb_v mol ';
          IF is_grade_t = TRUE THEN                        -- NSRIVAST, INVCONV
            table_required  := ' mtl_onhand_new_lpn_v mol ';   -- NSRIVAST, INVCONV
          END IF;                                          -- NSRIVAST, INVCONV
        ELSE
          table_required  := ' mtl_onhand_new_lpn_mwb_v mol ';
        END IF;
      ELSE
        IF (p_prepacked <> 1) AND (p_prepacked <> 9) AND (p_prepacked <> 11) THEN
          table_required  := ' mtl_onhand_lpn_v mol  ';
          IF is_grade_t = TRUE THEN                        -- NSRIVAST, INVCONV
            table_required  := ' mtl_onhand_new_lpn_v mol ';   -- NSRIVAST, INVCONV
          END IF;                                          -- NSRIVAST, INVCONV
        ELSE
          table_required  := ' mtl_onhand_new_lpn_v mol ';
        END IF;
      END IF;

      query_str  := 'SELECT item, revision ';
      query_str  := query_str || 'FROM ' || table_required;

      IF (p_lpn_from IS NOT NULL
          OR p_lpn_to IS NOT NULL)
         AND p_parent_lpn_id IS NULL THEN
        query_str  := query_str || ', (select outermost_lpn_id from wms_license_plate_numbers wlpn ';
        query_str  := query_str || ' WHERE 1=1 ';

        IF p_sub_type = 2 THEN
          query_str  := query_str || ' AND lpn_context = 3 ';
        ELSIF p_prepacked IS NULL THEN
          query_str  := query_str || ' AND (lpn_context=1 or lpn_context=9 or lpn_context=11 )';
        ELSIF p_prepacked = 1 THEN
          query_str  := query_str || 'AND lpn_context = 1 ';
        ELSIF p_prepacked <> 1
              AND p_prepacked <> 999 THEN
          query_str  := query_str || 'AND lpn_context = :prepacked ';
        END IF;

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.locator_id = :loc_id ';
        END IF;

   -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.subinventory_code = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.organization_id = :org_id ';
        END IF;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL THEN
          IF p_lpn_from IS NOT NULL
             AND p_lpn_to IS NULL THEN
            query_str  := query_str || ' and license_plate_number >= :lpn_f ';
          ELSIF p_lpn_from IS NULL
                AND p_lpn_to IS NOT NULL THEN
            query_str  := query_str || ' and license_plate_number <= :lpn_t ';
          ELSIF p_lpn_from IS NOT NULL
                AND p_lpn_to IS NOT NULL THEN
            --bugfix#3646484
            IF (p_lpn_from = p_lpn_to)  THEN
            --User is querying for single LPN so converted the range query to equality query
               query_str := query_str || 'and license_plate_number = :lpn_f ';
            ELSE
               query_str  := query_str || ' and license_plate_number >= :lpn_f ';
               query_str  := query_str || ' and license_plate_number <= :lpn_t ';
            END IF;
          END IF;
        END IF;

        query_str  := query_str || 'group by wlpn.outermost_lpn_id) X ';
      END IF;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
                     query_str || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 ' || p_serial_attr_query
                     || ') msn ';
        query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 ' || p_lot_attr_query || ') mln ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln '
           || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        query_str  := query_str || 'AND msn.serial_num = serial_number ';
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/
      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
        query_str  := query_str || 'lot_status_id = :st_id or serial_status_id = :st_id OR :st_id IS NULL) ';
      END IF;

      IF p_lot_number IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number = :lot_n ';
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
      END IF;

      IF p_serial_number IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number = :serial_n ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      IF p_sub_type = 2 THEN
        query_str  := query_str || ' AND lpn_context = 3 ';
      ELSIF p_prepacked IS NULL THEN
        query_str  := query_str || ' AND (lpn_context=1  OR lpn_context=9 OR lpn_context=11 ) ';
      ELSIF p_prepacked = 1 THEN
        query_str  := query_str || 'AND lpn_context = 1 ';
      ELSIF p_prepacked <> 1
            AND p_prepacked <> 999 THEN
        query_str  := query_str || 'AND lpn_context = :prepacked ';
      END IF;

      IF p_parent_lpn_id IS NOT NULL THEN
        query_str  := query_str || 'AND MOL.lpn_id = :plpn_id ';
      END IF;

      IF p_lpn_from IS NOT NULL
         OR p_lpn_to IS NOT NULL THEN
        query_str  := query_str || 'AND MOL.outermost_lpn_id = X.outermost_lpn_id ';
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF (p_locator_controlled = 2) THEN
        query_str  := query_str || 'AND locator_id IS not NULL ';
      ELSIF(p_locator_controlled = 1) THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      query_str  := query_str || 'GROUP BY item, revision ';
      query_str  := query_str || 'ORDER BY revision ';
    END IF;
     inv_trx_util_pub.trace(query_str, 'Add_revs :- Material Workbench', 9);
     --trace1(query_str, 'add_revs', 9);

    query_hdl       := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(query_hdl, query_str, DBMS_SQL.native);

    IF p_organization_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'org_id', p_organization_id);
    END IF;

    IF p_subinventory_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'sub', p_subinventory_code);
    END IF;

    IF p_locator_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'loc_id', p_locator_id);
    END IF;

    IF p_inventory_item_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'item_id', p_inventory_item_id);
    END IF;

    IF p_revision IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'rev', p_revision);
    END IF;

    IF p_cost_group_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'cg_id', p_cost_group_id);
    END IF;

    IF p_lot_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_f', p_lot_number_from);
    END IF;

    IF p_lot_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_t', p_lot_number_to);
    END IF;

-- NSRIVAST, INVCONV, Start
    IF p_grade_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_f',p_grade_from );
    END IF;
    IF p_grade_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_c', p_grade_code);
    END IF;
-- NSRIVAST, INVCONV, End

    IF p_lot_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_n', p_lot_number);
    END IF;

    IF p_serial_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_f', p_serial_number_from);
    END IF;

    IF p_serial_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_t', p_serial_number_to);
    END IF;

    IF p_serial_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_n', p_serial_number);
    END IF;

      --bugfix#3646484
      IF ((p_lpn_from IS NOT NULL) AND (p_lpn_to IS NOT NULL) AND (p_lpn_from = p_lpn_to))  THEN
      --User is querying for single LPN so converted the range query to equality query
      --So it is enought to bind the from lpn alone
         dbms_sql.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
      ELSE
          IF p_lpn_from IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
          END IF;

          IF p_lpn_to IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_t', p_lpn_to);
          END IF;
      END IF;

    IF p_parent_lpn_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'plpn_id', p_parent_lpn_id);
    END IF;

    IF p_status_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'st_id', p_status_id);
    END IF;

    IF p_prepacked <> 1
       AND p_prepacked <> 999
       AND p_prepacked IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'prepacked', p_prepacked);
    END IF;

    IF p_mln_context_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'mln_context', p_mln_context_code);
    END IF;

    IF p_project_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'pr_id', p_project_id);
    END IF;

    IF p_task_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'ta_id', p_task_id);
    END IF;

    IF p_unit_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'un_id', p_unit_number);
    END IF;

    /*IF p_site_id IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'site_id', p_site_id);
     ELSIF p_vendor_id is NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'vendor_id', p_vendor_id);
    END IF;*/
    IF (p_owning_qry_mode = 4)
       OR(p_owning_qry_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'own_org', p_owning_org);
    END IF;

    IF (p_planning_query_mode = 4)
       OR(p_planning_query_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'plan_org', p_planning_org);
    END IF;

    --ER(3338592) Changes
    IF p_item_description IS NOT NULL THEN
      /* Fix for bug #3457285
         Following line has been removed.
         query_str := query_str || ' AND item_description LIKE :item_description ';
         Added the following line to bind the item_description value to WHERE clause the query*/
      DBMS_SQL.bind_variable(query_hdl,'item_description',p_item_description);
     /*End of fix 3457285 */

    END IF;
    --ER(3338592) Changes

    DBMS_SQL.define_column(query_hdl, 1, item, 40);
    DBMS_SQL.define_column(query_hdl, 2, rev, 3);
    rows_processed  := DBMS_SQL.EXECUTE(query_hdl);

    LOOP
      -- fetch a row
      IF DBMS_SQL.fetch_rows(query_hdl) > 0 THEN
        -- fetch columns from the row
        DBMS_SQL.column_value(query_hdl, 1, item);
        DBMS_SQL.column_value(query_hdl, 2, rev);

        IF j >= p_node_low_value AND
           rev IS NOT NULL THEN
          x_node_tbl(i).state  := p_node_state;
          x_node_tbl(i).DEPTH  := 1;
          x_node_tbl(i).label  := item || '-' || rev;
          x_node_tbl(i).icon   := 'inv_revi';
          x_node_tbl(i).VALUE  := rev;
          x_node_tbl(i).TYPE   := 'REV';
          i                    := i + 1;
        END IF;

        EXIT WHEN j >= p_node_high_value;
        j  := j + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    DBMS_SQL.close_cursor(query_hdl); -- close cursor
    x_node_value    := j;
    x_tbl_index     := i;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END add_revs;

  PROCEDURE add_lots(
    p_organization_id     IN            NUMBER DEFAULT NULL
  , p_subinventory_code   IN            VARCHAR2 DEFAULT NULL
  , p_locator_id          IN            NUMBER DEFAULT NULL
  , p_locator_controlled  IN            NUMBER DEFAULT 0
  , p_inventory_item_id   IN            NUMBER DEFAULT NULL
  , p_revision            IN            VARCHAR2 DEFAULT NULL
  , p_revision_controlled IN            NUMBER DEFAULT 0
  , p_lot_number_from     IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_to       IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_from  IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_to    IN            VARCHAR2 DEFAULT NULL
  , p_serial_number       IN            VARCHAR2 DEFAULT NULL
  , p_serial_controlled   IN            NUMBER DEFAULT 0
  , p_lpn_from            IN            VARCHAR2 DEFAULT NULL
  , p_lpn_to              IN            VARCHAR2 DEFAULT NULL
  , p_parent_lpn_id       IN            VARCHAR2 DEFAULT NULL
  , p_containerized       IN            NUMBER DEFAULT 0
  , p_prepacked           IN            NUMBER DEFAULT NULL  --Bug #3581090
  , p_cost_group_id       IN            NUMBER DEFAULT NULL
  , p_status_id           IN            NUMBER DEFAULT NULL
  , p_lot_attr_query      IN            VARCHAR2 DEFAULT NULL
  , p_mln_context_code    IN            VARCHAR2 DEFAULT NULL
  , p_project_id          IN            NUMBER DEFAULT NULL
  , p_task_id             IN            NUMBER DEFAULT NULL
  , p_unit_number         IN            VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode     IN            NUMBER DEFAULT NULL
  , p_planning_query_mode IN            NUMBER DEFAULT NULL
  , p_owning_org          IN            NUMBER DEFAULT NULL
  , p_planning_org        IN            NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query   IN            VARCHAR2 DEFAULT NULL
  , p_only_lot_status     IN            NUMBER DEFAULT 1
  , p_node_state          IN            NUMBER
  , p_node_high_value     IN            NUMBER
  , p_node_low_value      IN            NUMBER
  , p_sub_type            IN            NUMBER DEFAULT NULL --RCVLOCATORSSUPPORT
  --ER(3338592) Changes
  , p_item_description    IN            VARCHAR2 DEFAULT NULL
  --ER(3338592) Changes
  , x_node_value          IN OUT NOCOPY NUMBER
  , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index           IN OUT NOCOPY NUMBER
   -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL

  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  ) IS
    query_str      VARCHAR2(10000);
    query_hdl      NUMBER;
    rows_processed NUMBER;
    lot            mtl_onhand_quantities.lot_number%TYPE;
    lot_control    NUMBER;
    i              NUMBER                                  := x_tbl_index;
    j              NUMBER                                  := x_node_value;
    table_required VARCHAR2(300);
    is_grade_t     BOOLEAN DEFAULT FALSE ; -- NSRIVAST, INVCONV
  BEGIN
-- NSRIVAST, INVCONV, Start
   IF  (p_grade_from IS NOT NULL OR  p_grade_code IS NOT NULL OR p_grade_controlled <> 0) THEN
          is_grade_t     := TRUE ;
   END IF ;
-- NSRIVAST, INVCONV, End
    -- Exit out of the procedure if the item is not lot controlled
    IF p_organization_id IS NOT NULL
       AND p_inventory_item_id IS NOT NULL THEN
      SELECT lot_control_code
        INTO lot_control
        FROM mtl_system_items
       WHERE organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id;

      IF lot_control = 1 THEN
        RETURN;
      END IF;
    END IF;

    IF (
        p_serial_number_from IS NULL
        AND p_serial_number_to IS NULL
        AND p_serial_number IS NULL
        AND p_unit_number IS NULL
        AND p_status_id IS NULL
        AND p_lpn_from IS NULL
        AND p_lpn_to IS NULL
        AND p_parent_lpn_id IS NULL
        AND NVL(p_prepacked,1) = 1
        AND p_serial_attr_query IS NULL
       ) THEN
      IF p_sub_type = 2 THEN
        table_required  := ' mtl_rcv_mwb_onhand_v ';
      ELSIF(p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_total_mwb_v ';
          IF is_grade_t = TRUE THEN                       -- NSRIVAST, INVCONV
            table_required  := ' mtl_onhand_total_v ';   -- NSRIVAST, INVCONV
         END IF;                                         -- NSRIVAST, INVCONV
      ELSE
        table_required  := ' mtl_onhand_total_v ';
      END IF;

      IF p_lot_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT lot_number from ' || table_required;
        query_str  := query_str || 'WHERE 1=1 ';
      ELSE
        query_str  :=
              query_str
           || 'SELECT lot_number from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, '
           || table_required;
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/
      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        IF p_only_lot_status = 1 THEN
          query_str  := query_str || 'AND (subinventory_status_id = :st_id or ';
          query_str  := query_str || 'locator_status_id = :st_id or lot_status_id = :st_id) ';
        ELSE
          query_str  := query_str || 'AND lot_status_id = :st_id ';
        END IF;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
      END IF;

      IF p_revision_controlled = 1 THEN
        query_str  := query_str || 'AND revision IS NULL ';
      ELSIF p_revision_controlled = 2 THEN
        query_str  := query_str || 'AND revision IS NOT NULL ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
      END IF;

      IF p_serial_controlled = 1 THEN
        --query_str  := query_str || 'AND serial_number_control_code in (1,6) ';
        query_str  := query_str || 'AND item_serial_control in (1,6) ';
      ELSIF p_serial_controlled = 2 THEN
        --query_str  := query_str || 'AND serial_number_control_code in (2,5) ';
        query_str := query_str || 'AND item_serial_control in (2,5) ';
      END IF;

      IF p_containerized = 1 THEN
        query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
      ELSIF p_containerized = 2 THEN
        query_str  := query_str || 'AND containerized_flag = 1 ';
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_locator_controlled = 1 THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      ELSIF p_locator_controlled = 2 THEN
        query_str  := query_str || 'AND locator_id IS NOT NULL ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      query_str := query_str || ' AND lot_number is not null ';

      query_str  := query_str || 'GROUP BY lot_number ';
      query_str  := query_str || 'ORDER BY lot_number ';
    ELSIF(
          (
           p_serial_number_from IS NOT NULL
           OR p_serial_number_from IS NOT NULL
           OR p_serial_number IS NOT NULL
           OR p_serial_controlled = 2
           OR p_serial_attr_query IS NOT NULL
           OR p_unit_number IS NOT NULL
          )
          AND p_lpn_from IS NULL
          AND p_lpn_to IS NULL
          AND p_parent_lpn_id IS NULL
          AND nvl(p_prepacked,1) = 1
         ) THEN
      IF p_sub_type = 2 THEN
        table_required  := ' mtl_rcv_serial_oh_v ';
      ELSIF(p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_serial_mwb_v ';
         IF is_grade_t = TRUE THEN                       -- NSRIVAST, INVCONV
          table_required  := ' mtl_onhand_serial_v ';   -- NSRIVAST, INVCONV
        END IF;                                         -- NSRIVAST, INVCONV
      ELSE
        table_required  := ' mtl_onhand_serial_v ';
      END IF;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT lot_number from ' || table_required;
        query_str  := query_str || 'WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || 'SELECT lot_number from'
           || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn, '
           || table_required;
        query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  :=
              query_str
           || 'SELECT lot_number from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, '
           || table_required;
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || 'SELECT lot_number from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, '
           || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn, '
           || table_required;
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        query_str  := query_str || 'AND msn.serial_num = serial_number ';
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/
      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        IF p_only_lot_status = 1 THEN
          query_str  := query_str || ' AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
          query_str  := query_str || ' lot_status_id = :st_id or serial_status_id = :st_id) ';
        ELSE
          query_str  := query_str || ' AND (lot_status_id = :st_id or :st_id IS NULL) ';
        END IF;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
      END IF;

      IF p_revision_controlled = 1 THEN
        query_str  := query_str || 'AND revision IS NULL ';
      ELSIF p_revision_controlled = 2 THEN
        query_str  := query_str || 'AND revision IS NOT NULL ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
      END IF;

      IF p_serial_number IS NOT NULL THEN
        query_str  := query_str || 'AND (serial_number = :serial_n) ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      IF p_containerized = 1 THEN
        query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
      ELSIF p_containerized = 2 THEN
        query_str  := query_str || 'AND containerized_flag = 1 ';
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_locator_controlled = 1 THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      ELSIF p_locator_controlled = 2 THEN
        query_str  := query_str || 'AND locator_id IS NOT NULL ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      query_str := query_str || ' AND lot_number is not null ';

      query_str  := query_str || 'GROUP BY lot_number ';
      query_str  := query_str || 'ORDER BY lot_number ';
    --Need to query both mtl_onhand_total_v and mtl_onhand_serial_v
    ELSIF(
          p_serial_number_from IS NULL
          AND p_serial_number_to IS NULL
          AND p_serial_number IS NULL
          AND p_serial_attr_query IS NULL
          AND p_unit_number IS NULL
          AND p_status_id IS NOT NULL
          AND p_lpn_from IS NULL
          AND p_lpn_to IS NULL
          AND p_parent_lpn_id IS NULL
          AND nvl(p_prepacked,1) = 1
         ) THEN
      IF (p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_total_mwb_v moq ';
--      ELSIF is_grade_t = TRUE THEN                            -- NSRIVAST, INVCONV
--          table_required  := ' mtl_onhand_new_lpn_v moq ';    -- NSRIVAST, INVCONV
      ELSE
        table_required  := ' mtl_onhand_total_v moq ';
      END IF;

      query_str  := 'SELECT lot_number from( ';

      IF p_lot_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT lot_number from ' || table_required;
        query_str  := query_str || 'WHERE 1=1 ';
      ELSE
        query_str  :=
              query_str
           || 'SELECT lot_number from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, '
           || table_required;
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/
      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        IF p_only_lot_status = 1 THEN
          query_str  := query_str || 'AND (subinventory_status_id = :st_id or ';
          query_str  := query_str || 'locator_status_id = :st_id or lot_status_id = :st_id) ';
        ELSE
          query_str  := query_str || 'AND lot_status_id = :st_id ';
        END IF;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
      END IF;

      IF p_revision_controlled = 1 THEN
        query_str  := query_str || 'AND revision IS NULL ';
      ELSIF p_revision_controlled = 2 THEN
        query_str  := query_str || 'AND revision IS NOT NULL ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
      END IF;

      IF p_containerized = 1 THEN
        query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
      ELSIF p_containerized = 2 THEN
        query_str  := query_str || 'AND containerized_flag = 1 ';
      END IF;

      -- query_str := query_str || 'AND serial_number_control_code in (1,6) ';
      query_str  :=
            query_str
         || ' AND exists '
         || ' ( select null from mtl_system_items msi WHERE '
         || ' moq.organization_id = msi.organization_id and '
         || ' moq.inventory_item_id =  msi.inventory_item_id and '
         || ' item_serial_control in (1,6) ) ';

      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_locator_controlled = 1 THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      ELSIF p_locator_controlled = 2 THEN
        query_str  := query_str || 'AND locator_id IS NOT NULL ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      query_str  := query_str || 'UNION ';

      IF (p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_serial_mwb_v ';
      ELSE
        table_required  := ' mtl_onhand_serial_v ';
      END IF;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT lot_number from ' || table_required;
        query_str  := query_str || 'WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  :=
              query_str
           || 'SELECT lot_number from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, '
           || table_required;
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        IF p_only_lot_status = 1 THEN
          query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
          query_str  := query_str || 'lot_status_id = :st_id or serial_status_id = :st_id) ';
        ELSE
          query_str  := query_str || 'AND (lot_status_id = :st_id or :st_id IS NULL) ';
        END IF;
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
      END IF;

      IF p_revision_controlled = 1 THEN
        query_str  := query_str || 'AND revision IS NULL ';
      ELSIF p_revision_controlled = 2 THEN
        query_str  := query_str || 'AND revision IS NOT NULL ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
      END IF;

      IF p_containerized = 1 THEN
        query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
      ELSIF p_containerized = 2 THEN
        query_str  := query_str || 'AND containerized_flag = 1 ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_locator_controlled = 1 THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      ELSIF p_locator_controlled = 2 THEN
        query_str  := query_str || 'AND locator_id IS NOT NULL ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      query_str  := query_str || ') GROUP BY lot_number ';
      query_str  := query_str || 'ORDER BY lot_number ';
    ELSIF(p_lpn_from IS NOT NULL
          OR p_lpn_to IS NOT NULL
          OR p_parent_lpn_id IS NOT NULL
          OR p_prepacked <> 1) THEN
      IF p_sub_type = 2 THEN
        table_required  := ' mtl_onhand_lpn_mwb_v mol ';
      ELSIF(p_status_id IS NULL) THEN
        IF (p_prepacked <> 1) AND (p_prepacked <> 9) AND (p_prepacked <> 11) THEN
          table_required  := ' mtl_onhand_lpn_mwb_v mol ';
          IF is_grade_t = TRUE THEN                        -- NSRIVAST, INVCONV
            table_required  := ' mtl_onhand_new_lpn_v ';   -- NSRIVAST, INVCONV
          END IF;                                          -- NSRIVAST, INVCONV
        ELSE
          table_required  := ' mtl_onhand_new_lpn_mwb_v mol ';
          IF is_grade_t = TRUE THEN                        -- %%NSRIVAST, INVCONV
            table_required  := ' mtl_onhand_new_lpn_v mol ';   -- %%NSRIVAST, INVCONV
          END IF;
        END IF;
      ELSE
        IF (p_prepacked <> 1) AND (p_prepacked <> 9) AND (p_prepacked <> 11) THEN
          table_required  := ' mtl_onhand_lpn_v mol  ';
          IF is_grade_t = TRUE THEN                        -- NSRIVAST, INVCONV
            table_required  := ' mtl_onhand_new_lpn_v ';   -- NSRIVAST, INVCONV
          END IF;                                          -- NSRIVAST, INVCONV
        ELSE
          table_required  := ' mtl_onhand_new_lpn_v mol ';
        END IF;
      END IF;

      query_str  := 'SELECT lot_number  ';
      query_str  := query_str || 'FROM ' || table_required;

      IF (p_lpn_from IS NOT NULL
          OR p_lpn_to IS NOT NULL)
         AND p_parent_lpn_id IS NULL THEN
        query_str  := query_str || ', (select outermost_lpn_id from wms_license_plate_numbers wlpn ';
        query_str  := query_str || ' WHERE 1=1 ';

        IF p_sub_type = 2 THEN
          query_str  := query_str || ' AND lpn_context = 3 ';
        ELSIF p_prepacked IS NULL THEN
          query_str  := query_str || ' AND (lpn_context=1  or lpn_context=9 or lpn_context=11 )';
        ELSIF p_prepacked = 1 THEN
          query_str  := query_str || 'AND lpn_context = 1 ';
        ELSIF p_prepacked <> 1
              AND p_prepacked <> 999
              AND p_prepacked IS NOT NULL THEN
          query_str  := query_str || 'AND lpn_context = :prepacked ';
        END IF;

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.locator_id = :loc_id ';
        END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.subinventory_code = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.organization_id = :org_id ';
        END IF;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL THEN
          IF p_lpn_from IS NOT NULL
             AND p_lpn_to IS NULL THEN
            query_str  := query_str || ' and license_plate_number >= :lpn_f ';
          ELSIF p_lpn_from IS NULL
                AND p_lpn_to IS NOT NULL THEN
            query_str  := query_str || ' and license_plate_number <= :lpn_t ';
          ELSIF p_lpn_from IS NOT NULL
                AND p_lpn_to IS NOT NULL THEN
               --bugfix#3646484
               IF (p_lpn_from = p_lpn_to)  THEN
               --User is querying for single LPN so converted the range query to equality query
                  query_str := query_str || 'and license_plate_number = :lpn_f ';
               ELSE
                  query_str  := query_str || ' and license_plate_number >= :lpn_f ';
                  query_str  := query_str || ' and license_plate_number <= :lpn_t ';
               END IF;
          END IF;
        END IF;

        query_str  := query_str || 'group by wlpn.outermost_lpn_id) X ';
      END IF;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
                     query_str || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 ' || p_serial_attr_query
                     || ') msn ';
        query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 ' || p_lot_attr_query || ') mln ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln '
           || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        query_str  := query_str || 'AND msn.serial_num = serial_number ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        IF p_only_lot_status = 1 THEN
          query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
          query_str  := query_str || 'lot_status_id = :st_id or serial_status_id = :st_id) ';
        ELSE
          query_str  := query_str || 'AND lot_status_id = :st_id ';
        END IF;
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/

      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
      END IF;

      IF p_revision_controlled = 1 THEN
        query_str  := query_str || 'AND revision IS NULL ';
      ELSIF p_revision_controlled = 2 THEN
        query_str  := query_str || 'AND revision IS NOT NULL ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
      END IF;

      IF p_serial_number IS NOT NULL THEN
        query_str  := query_str || 'AND (serial_number = :serial_n) ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      IF p_serial_controlled = 1 THEN
        query_str  :=
              query_str
           || ' AND exists '
           || ' ( select null from mtl_system_items msi WHERE '
           || ' mol.organization_id = msi.organization_id and '
           || ' mol.inventory_item_id =  msi.inventory_item_id and '
           || ' item_serial_control in (1,6) ) ';
      ELSIF p_serial_controlled = 2 THEN
        query_str  :=
              query_str
           || ' AND exists '
           || ' ( select null from mtl_system_items msi WHERE '
           || ' mol.organization_id = msi.organization_id and '
           || ' mol.inventory_item_id =  msi.inventory_item_id and '
           || ' item_serial_control in (2,5) ) ';
      END IF;

      IF p_sub_type = 2 THEN
        query_str  := query_str || ' AND lpn_context = 3 ';
      ELSIF p_prepacked = 1 THEN
        query_str  := query_str || 'AND lpn_context = 1 ';
      ELSIF p_prepacked <> 1
            AND p_prepacked <> 999
            AND p_prepacked IS NOT NULL THEN
        query_str  := query_str || 'AND lpn_context = :prepacked ';
      END IF;

      IF p_parent_lpn_id IS NOT NULL THEN
        query_str  := query_str || 'AND MOL.lpn_id = :plpn_id ';
      ELSIF p_lpn_from IS NOT NULL
            OR p_lpn_to IS NOT NULL THEN
        query_str  := query_str || 'AND MOL.outermost_lpn_id = X.outermost_lpn_id ';
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_locator_controlled = 1 THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      ELSIF p_locator_controlled = 2 THEN
        query_str  := query_str || 'AND locator_id IS NOT NULL ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      query_str  := query_str || 'GROUP BY lot_number  ';
      query_str  := query_str || 'ORDER BY lot_number ';
    END IF;

    -- Enable this during debugging
     inv_trx_util_pub.trace(query_str, 'Add_lot :- Material Workbench', 9);
    --trace1(query_str, 'add_lots', 9);

    query_hdl       := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(query_hdl, query_str, DBMS_SQL.native);

    IF p_organization_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'org_id', p_organization_id);
    END IF;

    IF p_subinventory_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'sub', p_subinventory_code);
    END IF;

    IF p_locator_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'loc_id', p_locator_id);
    END IF;

    IF p_inventory_item_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'item_id', p_inventory_item_id);
    END IF;

    IF p_revision IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'rev', p_revision);
    END IF;

    IF p_cost_group_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'cg_id', p_cost_group_id);
    END IF;

    IF p_lot_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_f', p_lot_number_from);
    END IF;

    IF p_lot_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_t', p_lot_number_to);
    END IF;

 -- NSRIVAST, INVCONV, Start
    IF p_grade_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_f',p_grade_from );
    END IF;
    IF p_grade_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_c', p_grade_code);
    END IF;
 -- NSRIVAST, INVCONV, End

    IF p_serial_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_f', p_serial_number_from);
    END IF;

    IF p_serial_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_t', p_serial_number_to);
    END IF;

    IF p_serial_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_n', p_serial_number);
    END IF;

      --bugfix#3646484
      IF ((p_lpn_from IS NOT NULL) AND (p_lpn_to IS NOT NULL) AND (p_lpn_from = p_lpn_to))  THEN
      --User is querying for single LPN so converted the range query to equality query
      --So it is enought to bind the from lpn alone
         dbms_sql.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
      ELSE
          IF p_lpn_from IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
          END IF;

          IF p_lpn_to IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_t', p_lpn_to);
          END IF;
      END IF;

    IF p_parent_lpn_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'plpn_id', p_parent_lpn_id);
    END IF;

    IF p_status_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'st_id', p_status_id);
    END IF;

    IF p_prepacked <> 1
       AND p_prepacked <> 999
       AND p_prepacked IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'prepacked', p_prepacked);
    END IF;

    IF p_mln_context_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'mln_context', p_mln_context_code);
    END IF;

    IF p_project_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'pr_id', p_project_id);
    END IF;

    IF p_task_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'ta_id', p_task_id);
    END IF;

    IF p_unit_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'un_id', p_unit_number);
    END IF;

    /*IF p_site_id IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'site_id', p_site_id);
     ELSIF p_vendor_id is NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'vendor_id', p_vendor_id);
    END IF;*/
    IF (p_owning_qry_mode = 4)
       OR(p_owning_qry_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'own_org', p_owning_org);
    END IF;

    IF (p_planning_query_mode = 4)
       OR(p_planning_query_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'plan_org', p_planning_org);
    END IF;

    --ER(3338592) Changes
    IF p_item_description IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl, 'item_description', p_item_description);
    END IF;

    DBMS_SQL.define_column(query_hdl, 1, lot, 80);
    rows_processed  := DBMS_SQL.EXECUTE(query_hdl);

    LOOP
      -- fetch a row
      IF DBMS_SQL.fetch_rows(query_hdl) > 0 THEN
        -- fetch columns from the row
        DBMS_SQL.column_value(query_hdl, 1, lot);

        IF j >= p_node_low_value THEN
          x_node_tbl(i).state  := p_node_state;
          x_node_tbl(i).DEPTH  := 1;
          x_node_tbl(i).label  := lot;
          x_node_tbl(i).icon   := 'inv_lott';
          x_node_tbl(i).VALUE  := lot;
          x_node_tbl(i).TYPE   := 'LOT';
          i                    := i + 1;
        END IF;

        EXIT WHEN j >= p_node_high_value;
        j  := j + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    DBMS_SQL.close_cursor(query_hdl); -- close cursor
    x_node_value    := j;
    x_tbl_index     := i;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END add_lots;

  PROCEDURE add_serials(
    p_organization_id     IN            NUMBER DEFAULT NULL
  , p_subinventory_code   IN            VARCHAR2 DEFAULT NULL
  , p_locator_id          IN            NUMBER DEFAULT NULL
  , p_locator_controlled  IN            NUMBER DEFAULT 0
  , p_inventory_item_id   IN            NUMBER DEFAULT NULL
  , p_revision            IN            VARCHAR2 DEFAULT NULL
  , p_revision_controlled IN            NUMBER DEFAULT 0
  , p_lot_number_from     IN            VARCHAR2 DEFAULT NULL
  , p_lot_number_to       IN            VARCHAR2 DEFAULT NULL
  , p_lot_number          IN            VARCHAR2 DEFAULT NULL
  , p_lot_controlled      IN            NUMBER DEFAULT 0
  , p_serial_number_from  IN            VARCHAR2 DEFAULT NULL
  , p_serial_number_to    IN            VARCHAR2 DEFAULT NULL
  , p_lpn_from            IN            VARCHAR2 DEFAULT NULL
  , p_lpn_to              IN            VARCHAR2 DEFAULT NULL
  , p_parent_lpn_id       IN            VARCHAR2 DEFAULT NULL
  , p_containerized       IN            NUMBER DEFAULT 0
  , p_prepacked           IN            NUMBER DEFAULT NULL --Bug #3581090
  , p_cost_group_id       IN            NUMBER DEFAULT NULL
  , p_status_id           IN            NUMBER DEFAULT NULL
  , p_lot_attr_query      IN            VARCHAR2 DEFAULT NULL
  , p_mln_context_code    IN            VARCHAR2 DEFAULT NULL
  , p_project_id          IN            NUMBER DEFAULT NULL
  , p_task_id             IN            NUMBER DEFAULT NULL
  , p_unit_number         IN            VARCHAR2 DEFAULT NULL
  , -- consinged changes
    p_owning_qry_mode     IN            NUMBER DEFAULT NULL
  , p_planning_query_mode IN            NUMBER DEFAULT NULL
  , p_owning_org          IN            NUMBER DEFAULT NULL
  , p_planning_org        IN            NUMBER DEFAULT NULL
  , -- consigned changes
    p_serial_attr_query   IN            VARCHAR2 DEFAULT NULL
  , p_only_serial_status  IN            NUMBER DEFAULT 1
  , p_node_state          IN            NUMBER
  , p_node_high_value     IN            NUMBER
  , p_node_low_value      IN            NUMBER
  , p_sub_type            IN            NUMBER DEFAULT NULL --RCVLOCATORSSUPPORT
  --ER(3338592) Changes
  , p_item_description    IN            VARCHAR2 DEFAULT NULL
  --ER(3338592) Changes
  , x_node_value          IN OUT NOCOPY NUMBER
  , x_node_tbl            IN OUT NOCOPY fnd_apptree.node_tbl_type
  , x_tbl_index           IN OUT NOCOPY NUMBER
   -- NSRIVAST, INVCONV, Start
  , p_grade_from           IN             VARCHAR2 DEFAULT NULL

  , p_grade_code           IN             VARCHAR2 DEFAULT NULL
  , p_grade_controlled     IN             NUMBER DEFAULT 0
  -- NSRIVAST, INVCONV, End
  ) IS
    query_str      VARCHAR2(10000);
    query_hdl      NUMBER;
    rows_processed NUMBER;
    serial         mtl_serial_numbers.serial_number%TYPE;
    serial_control NUMBER;
    i              NUMBER                                  := x_tbl_index;
    j              NUMBER                                  := x_node_value;
    table_required VARCHAR2(300);
    is_grade_t     BOOLEAN DEFAULT FALSE ; -- NSRIVAST, INVCONV
  BEGIN

-- NSRIVAST, INVCONV, Start
   IF  (p_grade_from IS NOT NULL OR  p_grade_code IS NOT NULL OR p_grade_controlled <> 0) THEN
         is_grade_t     := TRUE ;
   END IF ;
-- NSRIVAST, INVCONV, End

    -- Exit out of the procedure if the item is not serial controlled
    IF p_organization_id IS NOT NULL
       AND p_inventory_item_id IS NOT NULL THEN
      SELECT serial_number_control_code
        INTO serial_control
        FROM mtl_system_items
       WHERE organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id;

      IF serial_control IN(1, 6) THEN
        RETURN;
      END IF;
    END IF;

    IF (p_lpn_from IS NULL
        AND p_lpn_to IS NULL
        AND p_parent_lpn_id IS NULL
        AND nvl(p_prepacked,1) = 1) THEN
      IF p_sub_type = 2 THEN
        table_required  := ' mtl_rcv_serial_oh_v ';
      ELSIF(p_status_id IS NULL) THEN
        table_required  := ' mtl_onhand_serial_mwb_v ';
         IF is_grade_t = TRUE THEN                       -- NSRIVAST, INVCONV
            table_required  := ' mtl_onhand_serial_v ';   -- NSRIVAST, INVCONV
         END IF;                                         -- NSRIVAST, INVCONV
      ELSE
        table_required  := ' mtl_onhand_serial_v ';
      END IF;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'SELECT serial_number from ' || table_required;
        query_str  := query_str || ' WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || 'SELECT serial_number from'
           || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn, '
           || table_required;
        query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  :=
              query_str
           || 'SELECT serial_number from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, mtl_onhand_serial_v ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || 'SELECT serial_number from'
           || '(SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln, '
           || '(SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn, mtl_onhand_serial_v ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        query_str  := query_str || 'AND msn.serial_num = serial_number ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        IF p_only_serial_status = 1 THEN
          query_str  := query_str || 'AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
          query_str  := query_str || 'lot_status_id = :st_id or serial_status_id = :st_id) ';
        ELSE
          query_str  := query_str || 'AND serial_status_id = :st_id ';
        END IF;
      END IF;

      IF p_lot_controlled = 1 THEN
        query_str  := query_str || 'AND lot_number IS NULL ';
      ELSIF p_lot_controlled = 2 THEN
        query_str  := query_str || 'AND lot_number IS NOT NULL ';
      END IF;

      IF p_lot_number IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number = :lot_n ';
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
      END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

      IF p_revision_controlled = 1 THEN
        query_str  := query_str || 'AND revision IS NULL ';
      ELSIF p_revision_controlled = 2 THEN
        query_str  := query_str || 'AND revision IS NOT NULL ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
      END IF;

      IF p_containerized = 1 THEN
        query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
      ELSIF p_containerized = 2 THEN
        query_str  := query_str || 'AND containerized_flag = 1 ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_locator_controlled = 1 THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
       /* part of bug fix 2424304 */
      --  ELSE
      ELSIF p_locator_controlled = 2 THEN
        /* end of bug fix 2424304 */
        query_str  := query_str || 'AND locator_id IS NOT NULL ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/
      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      query_str  := query_str || ' AND serial_number is NOT NULL ';
      query_str  := query_str || 'GROUP BY serial_number ';
      query_str  := query_str || 'ORDER BY serial_number ';
    ELSIF(p_lpn_from IS NOT NULL
          OR p_lpn_to IS NOT NULL
          OR p_parent_lpn_id IS NOT NULL
          OR p_prepacked <> 1) THEN
      IF p_sub_type = 2 THEN
        table_required  := ' mtl_onhand_lpn_mwb_v mol ';
      ELSIF(p_status_id IS NULL) THEN
        IF (p_prepacked <> 1) AND (p_prepacked <> 9) AND (p_prepacked <> 11) THEN
          table_required  := ' mtl_onhand_lpn_mwb_v mol ';
          IF is_grade_t = TRUE THEN                        -- NSRIVAST, INVCONV
            table_required  := ' mtl_onhand_new_lpn_v ';   -- NSRIVAST, INVCONV
          END IF;                                          -- NSRIVAST, INVCONV
        ELSE
          table_required  := ' mtl_onhand_new_lpn_mwb_v mol ';
        END IF;
      ELSE
        IF (p_prepacked <> 1) AND (p_prepacked <> 9) AND (p_prepacked <> 11) THEN
          table_required  := ' mtl_onhand_lpn_v mol  ';
          IF is_grade_t = TRUE THEN                        -- NSRIVAST, INVCONV
            table_required  := ' mtl_onhand_new_lpn_v ';   -- NSRIVAST, INVCONV
          END IF;                                          -- NSRIVAST, INVCONV
        ELSE
          table_required  := ' mtl_onhand_new_lpn_v mol ';
        END IF;
      END IF;

      query_str  := 'SELECT serial_number  ';
      query_str  := query_str || 'FROM ' || table_required;

      IF (p_lpn_from IS NOT NULL
          OR p_lpn_to IS NOT NULL)
         AND p_parent_lpn_id IS NULL THEN
        query_str  := query_str || ', (select outermost_lpn_id from wms_license_plate_numbers wlpn ';
        query_str  := query_str || ' WHERE 1=1 ';

        IF p_sub_type = 2 THEN
          query_str  := query_str || ' AND lpn_context = 3 ';
        ELSIF p_prepacked IS NULL THEN
          query_str  := query_str || ' AND (lpn_context=1 or lpn_context=9 or lpn_context=11 )';
        ELSIF nvl(p_prepacked,1) = 1 THEN
          query_str  := query_str || 'AND lpn_context = 1 ';
        ELSIF p_prepacked <> 1
              AND p_prepacked <> 999
              AND p_prepacked IS NOT NULL THEN
          query_str  := query_str || 'AND lpn_context = :prepacked ';
        END IF;

        IF p_locator_id IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.locator_id = :loc_id ';
        END IF;

  -- NSRIVAST, INVCONV, Start
      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;
      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;
   -- NSRIVAST, INVCONV, End

        IF p_subinventory_code IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.subinventory_code = :sub ';
        END IF;

        IF p_organization_id IS NOT NULL THEN
          query_str  := query_str || 'AND wlpn.organization_id = :org_id ';
        END IF;

        IF p_lpn_from IS NOT NULL
           OR p_lpn_to IS NOT NULL THEN
          IF p_lpn_from IS NOT NULL
             AND p_lpn_to IS NULL THEN
            query_str  := query_str || ' and license_plate_number >= :lpn_f ';
          ELSIF p_lpn_from IS NULL
                AND p_lpn_to IS NOT NULL THEN
            query_str  := query_str || ' and license_plate_number <= :lpn_t ';
          ELSIF p_lpn_from IS NOT NULL
                AND p_lpn_to IS NOT NULL THEN
            --bugfix#3646484
            IF (p_lpn_from = p_lpn_to)  THEN
            --User is querying for single LPN so converted the range query to equality query
               query_str := query_str || 'and license_plate_number = :lpn_f ';
            ELSE
               query_str  := query_str || ' and license_plate_number >= :lpn_f ';
               query_str  := query_str || ' and license_plate_number <= :lpn_t ';
            END IF;
          END IF;
        END IF;

        query_str  := query_str || 'group by wlpn.outermost_lpn_id) X ';
      END IF;

      IF p_lot_attr_query IS NULL
         AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || 'WHERE 1=1 ';
      ELSIF p_lot_attr_query IS NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
                     query_str || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 ' || p_serial_attr_query
                     || ') msn ';
        query_str  := query_str || 'WHERE msn.serial_num = serial_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NULL THEN
        query_str  := query_str || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 ' || p_lot_attr_query || ') mln ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
      ELSIF p_lot_attr_query IS NOT NULL
            AND p_serial_attr_query IS NOT NULL THEN
        query_str  :=
              query_str
           || ', (SELECT lot_number lot_num FROM mtl_lot_numbers WHERE 1=1 '
           || p_lot_attr_query
           || ') mln '
           || ', (SELECT serial_number serial_num FROM mtl_serial_numbers WHERE 1=1 '
           || p_serial_attr_query
           || ') msn ';
        query_str  := query_str || 'WHERE mln.lot_num = lot_number ';
        query_str  := query_str || 'AND msn.serial_num = serial_number ';
      END IF;

      IF p_status_id IS NOT NULL THEN
        IF p_only_serial_status = 1 THEN
          query_str  := query_str || ' AND (subinventory_status_id = :st_id or locator_status_id = :st_id or ';
          query_str  := query_str || ' lot_status_id = :st_id or serial_status_id = :st_id) ';
        ELSE
          query_str  := query_str || 'AND serial_status_id = :st_id ';
        END IF;
      END IF;

      IF p_lot_controlled = 1 THEN
        query_str  := query_str || 'AND lot_number IS NULL ';
      ELSIF p_lot_controlled = 2 THEN
        query_str  := query_str || 'AND lot_number IS NOT NULL ';
      END IF;

      IF p_lot_number IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number = :lot_n ';
      END IF;

      IF p_lot_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number >= :lot_f ';
      END IF;

      IF p_lot_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND lot_number <= :lot_t ';
      END IF;

      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || 'AND cost_group_id = :cg_id ';
      END IF;

      IF p_revision_controlled = 1 THEN
        query_str  := query_str || 'AND revision IS NULL ';
      ELSIF p_revision_controlled = 2 THEN
        query_str  := query_str || 'AND revision IS NOT NULL ';
      END IF;

      IF p_revision IS NOT NULL THEN
        query_str  := query_str || 'AND revision = :rev ';
      END IF;

      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number >= :serial_f ';
      END IF;

      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || 'AND serial_number <= :serial_t ';
      END IF;

      IF p_sub_type = 2 THEN
        query_str  := query_str || ' AND lpn_context = 3 ';
      ELSIF p_prepacked IS NULL THEN
         query_str := query_str || ' AND (lpn_context = 1 or lpn_context = 9 or lpn_context = 11) ';
      ELSIF p_prepacked = 1 THEN
        query_str  := query_str || 'AND lpn_context = 1 ';
      ELSIF p_prepacked <> 1
            AND p_prepacked <> 999
            AND p_prepacked IS NOT NULL THEN
        query_str  := query_str || 'AND lpn_context = :prepacked ';
      END IF;

      IF p_parent_lpn_id IS NOT NULL THEN
        query_str  := query_str || 'AND MOL.lpn_id = :plpn_id ';
      END IF;

      IF p_lpn_from IS NOT NULL
         OR p_lpn_to IS NOT NULL THEN
        query_str  := query_str || ' AND mol.outermost_lpn_id = x.outermost_lpn_id ';
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;

      IF p_locator_controlled = 1 THEN
        query_str  := query_str || 'AND locator_id IS NULL ';
      ELSIF p_locator_controlled = 2 THEN
        query_str  := query_str || 'AND locator_id IS NOT NULL ';
      END IF;

      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || 'AND locator_id = :loc_id ';
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes

      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || 'AND subinventory_code = :sub ';
      END IF;

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || 'AND organization_id = :org_id ';
      END IF;

      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
      END IF;

      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
      END IF;

      IF p_unit_number IS NOT NULL THEN
        query_str  := query_str || ' AND unit_number=:un_id ';
      END IF;

      /*IF p_site_id IS NOT NULL THEN
         query_str := query_str || ' AND PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND planning_organization_id = :site_id ' ;
       ELSIF p_vendor_id is NOT NULL THEN
         query_str := query_str || ' AND  PLANNING_TP_TYPE = 1 ';
         query_str := query_str || ' AND  planning_organization_id in ';
         query_str := query_str || ' (select vendor_site_id from po_vendor_sites_all ';
         query_str := query_str || '  where vendor_id = :vendor_id )';
      END IF;*/
      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;

      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;

      query_str  := query_str || 'GROUP BY serial_number  ';
      query_str  := query_str || 'ORDER BY serial_number ';
    END IF;

    inv_trx_util_pub.trace(query_str, 'Add Serails :- Material Workbench', 9);
    --trace1(query_str, 'add_serials', 9);


    query_hdl       := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(query_hdl, query_str, DBMS_SQL.native);

    IF p_organization_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'org_id', p_organization_id);
    END IF;

    IF p_subinventory_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'sub', p_subinventory_code);
    END IF;

    IF p_locator_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'loc_id', p_locator_id);
    END IF;

    IF p_inventory_item_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'item_id', p_inventory_item_id);
    END IF;

    IF p_revision IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'rev', p_revision);
    END IF;

    IF p_cost_group_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'cg_id', p_cost_group_id);
    END IF;

    IF p_lot_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_f', p_lot_number_from);
    END IF;

    IF p_lot_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_t', p_lot_number_to);
    END IF;

    IF p_lot_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lot_n', p_lot_number);
    END IF;

 -- NSRIVAST, INVCONV, Start
    IF p_grade_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_f',p_grade_from );
    END IF;
    IF p_grade_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_c', p_grade_code);
    END IF;
 -- NSRIVAST, INVCONV, End

    IF p_serial_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_f', p_serial_number_from);
    END IF;

    IF p_serial_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_t', p_serial_number_to);
    END IF;

      --bugfix#3646484
      IF ((p_lpn_from IS NOT NULL) AND (p_lpn_to IS NOT NULL) AND (p_lpn_from = p_lpn_to))  THEN
      --User is querying for single LPN so converted the range query to equality query
      --So it is enought to bind the from lpn alone
         dbms_sql.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
      ELSE
          IF p_lpn_from IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
          END IF;

          IF p_lpn_to IS NOT NULL THEN
            DBMS_SQL.bind_variable(query_hdl, 'lpn_t', p_lpn_to);
          END IF;
      END IF;

    IF p_parent_lpn_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'plpn_id', p_parent_lpn_id);
    END IF;

    IF p_status_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'st_id', p_status_id);
    END IF;

    IF p_prepacked <> 1
       AND p_prepacked <> 999
       AND p_prepacked IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'prepacked', p_prepacked);
    END IF;

    IF p_mln_context_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'mln_context', p_mln_context_code);
    END IF;

    IF p_project_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'pr_id', p_project_id);
    END IF;

    IF p_task_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'ta_id', p_task_id);
    END IF;

    IF p_unit_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'un_id', p_unit_number);
    END IF;

    /*IF p_site_id IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'site_id', p_site_id);
     ELSIF p_vendor_id is NOT NULL THEN
       dbms_sql.bind_variable(query_hdl,'vendor_id', p_vendor_id);
    END IF;*/
    IF (p_owning_qry_mode = 4)
       OR(p_owning_qry_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'own_org', p_owning_org);
    END IF;

    IF (p_planning_query_mode = 4)
       OR(p_planning_query_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'plan_org', p_planning_org);
    END IF;

   --ER(3338592) Changes
   IF p_item_description IS NOT NULL THEN
      dbms_sql.bind_variable(query_hdl, 'item_description', p_item_description);
   END IF;

    DBMS_SQL.define_column(query_hdl, 1, serial, 30);
    rows_processed  := DBMS_SQL.EXECUTE(query_hdl);

    LOOP
      -- fetch a row
      IF DBMS_SQL.fetch_rows(query_hdl) > 0 THEN
        -- fetch columns from the row
        DBMS_SQL.column_value(query_hdl, 1, serial);

        IF j >= p_node_low_value THEN
          x_node_tbl(i).state  := p_node_state;
          x_node_tbl(i).DEPTH  := 1;
          x_node_tbl(i).label  := serial;
          x_node_tbl(i).icon   := 'inv_seri';
          x_node_tbl(i).VALUE  := serial;
          x_node_tbl(i).TYPE   := 'SERIAL';
          i                    := i + 1;
        END IF;

        EXIT WHEN j >= p_node_high_value;
        j  := j + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    DBMS_SQL.close_cursor(query_hdl); -- close cursor
    x_node_value    := j;
    x_tbl_index     := i;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END add_serials;


-- NSRIVAST, INVCONV, Start
-- Procedure to give grade nodes for view by Grade
 PROCEDURE add_grades
 (  p_organization_id           IN             NUMBER DEFAULT NULL
  , p_subinventory_code         IN             VARCHAR2 DEFAULT NULL
  , p_locator_id                IN             NUMBER DEFAULT NULL
  , p_locator_controlled        IN             NUMBER DEFAULT 0
  , p_inventory_item_id         IN             NUMBER DEFAULT NULL
  , p_revision                  IN             VARCHAR2 DEFAULT NULL
  , p_revision_controlled       IN             NUMBER DEFAULT 0
  , p_lot_number_from           IN             VARCHAR2 DEFAULT NULL
  , p_lot_number_to             IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_from        IN             VARCHAR2 DEFAULT NULL
  , p_serial_number_to          IN             VARCHAR2 DEFAULT NULL
  , p_serial_number             IN             VARCHAR2 DEFAULT NULL
  , p_grade_from                IN             VARCHAR2 DEFAULT NULL

  , p_grade_code                IN             VARCHAR2 DEFAULT NULL
  , p_serial_controlled         IN             NUMBER DEFAULT 0
  , p_lpn_from                  IN             VARCHAR2 DEFAULT NULL
  , p_lpn_to                    IN             VARCHAR2 DEFAULT NULL
  , p_parent_lpn_id             IN             VARCHAR2 DEFAULT NULL
  , p_containerized             IN             NUMBER DEFAULT 0
  , p_prepacked                 IN             NUMBER DEFAULT 1
  , p_cost_group_id             IN             NUMBER DEFAULT NULL
  , p_status_id                 IN             NUMBER DEFAULT NULL
  , p_lot_attr_query            IN             VARCHAR2 DEFAULT NULL
  , p_mln_context_code          IN             VARCHAR2 DEFAULT NULL
  , p_project_id                IN             NUMBER DEFAULT NULL
  , p_task_id                   IN             NUMBER DEFAULT NULL
  , p_unit_number               IN             VARCHAR2 DEFAULT NULL
   -- consinged changes
  , p_owning_qry_mode           IN             NUMBER DEFAULT NULL
  , p_planning_query_mode       IN             NUMBER DEFAULT NULL
  , p_owning_org                IN             NUMBER DEFAULT NULL
  , p_planning_org              IN             NUMBER DEFAULT NULL
   , p_only_lot_status          IN             NUMBER   DEFAULT 1
   -- consinged changes
  ,  p_serial_attr_query        IN             VARCHAR2 DEFAULT NULL
  , p_node_state                IN             NUMBER
  , p_node_high_value           IN             NUMBER
  , p_node_low_value            IN             NUMBER
  , p_sub_type                  IN             NUMBER  DEFAULT NULL      --RCVLOCATORSSUPPORT
  , p_item_description          IN             VARCHAR2 DEFAULT NULL     --ER(3338592) Changes
  , p_qty_from                  IN             NUMBER   DEFAULT NULL
  , p_qty_to                    IN             NUMBER   DEFAULT NULL
  , p_responsibility_id         IN             NUMBER   DEFAULT NULL
  , p_resp_application_id       IN             NUMBER   DEFAULT NULL
  , x_node_value                IN OUT NOCOPY  NUMBER
  , x_node_tbl                  IN OUT NOCOPY  fnd_apptree.node_tbl_type
  , x_tbl_index                 IN OUT NOCOPY  NUMBER
  ) IS

    query_str      VARCHAR2(10000);
    query_hdl      NUMBER;
    rows_processed NUMBER;
    org_id         mtl_onhand_quantities.organization_id%TYPE;
    org_code       mtl_parameters.organization_code%TYPE;
    i              NUMBER                                       := x_tbl_index;
    j              NUMBER                                       := x_node_value;
    grade_control    mtl_system_items.GRADE_CONTROL_FLAG%TYPE  ;
    table_required VARCHAR2(300);
    --ER(3338592) Changes
    group_str      VARCHAR2(10000) ;
    having_str     VARCHAR2(10000) := ' HAVING 1=1 ';
    --End of ER Changes

    grade          mtl_grades.grade_code%TYPE ;

  BEGIN

     -- Exit out of the procedure if the item is not grade controlled
    IF p_organization_id IS NOT NULL
       AND p_inventory_item_id IS NOT NULL THEN
      SELECT DISTINCT grade_control_flag
        INTO grade_control
        FROM mtl_system_items
       WHERE inventory_item_id = p_inventory_item_id;
      IF ( grade_control IN ('N','n') )  THEN
        RETURN;
      END IF;
    END IF;

--       query_str  := query_str || ' SELECT grade_code from  mtl_grades ';
--       query_str  := query_str || ' WHERE 1=1 ';

   -- Check the parameters on Find window, and build the query accordingly
     IF p_serial_number_from IS NULL
      AND p_serial_number_to IS NULL
      AND p_serial_number IS NULL
      AND p_lpn_from IS NULL
      AND p_lpn_to IS NULL AND p_prepacked = 1 THEN

       IF p_sub_type = 2 THEN
         table_required := ' MTL_RCV_MWB_ONHAND_V mv ' ;
       ELSE
         table_required := ' MTL_ONHAND_TOTAL_V mv ' ;
       END IF ;

       query_str  := query_str || ' SELECT grade_code from ' || table_required;
       query_str  := query_str || ' WHERE 1=1 ';

      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || ' AND inventory_item_id = :item_id ';
      END IF;
      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
      END IF;
      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
      END IF;
     IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;
      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;
      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || ' AND cost_group_id = :cg_id ';
      END IF;
      IF p_revision_controlled = 1 THEN
        query_str  := query_str || ' AND revision IS NULL ';
      ELSIF p_revision_controlled = 2 THEN
        query_str  := query_str || ' AND revision IS NOT NULL ';
      END IF;
      IF p_revision IS NOT NULL THEN
        query_str  := query_str || ' AND revision = :rev ';
      END IF;

      IF p_containerized = 1 THEN
        query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
      ELSIF p_containerized = 2 THEN
        query_str  := query_str || ' AND containerized_flag = 1 ';
      END IF;
      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || ' AND locator_id = :loc_id ';
      END IF;
      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes
      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || ' AND subinventory_code = :sub ';
      END IF;
      IF p_serial_controlled = 1 THEN
            query_str  := query_str || ' AND item_serial_control in (1,6) ';
      ELSIF p_serial_controlled = 2 THEN
        query_str := query_str || ' AND item_serial_control in (2,5) ';
      END IF;

      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' and grade_code = :grade_f ' ;
      END IF ;

      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' and grade_code = :grade_c ' ;
      END IF ;

      query_str := query_str || ' AND grade_code is not null ';

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || ' AND organization_id = :org_id ';
      ELSE
        query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id   = mv.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
      END IF;

      query_str  := query_str || ' GROUP BY grade_code ';
 --      query_str := query_str ||  ' ) ' ;  -- new

    ELSIF ((p_serial_number_from IS NOT NULL OR p_serial_number_to IS NOT NULL
         OR p_serial_number IS NOT NULL ) AND ( p_lpn_from IS NULL AND p_lpn_to IS NULL )) THEN
       IF p_sub_type = 2 THEN
         table_required := ' MTL_RCV_SERIAL_MWB_OH_V ms ' ;
       ELSE
         table_required := ' MTL_ONHAND_SERIAL_V ms ' ;
       END IF ;

      query_str  := query_str || ' SELECT grade_code from ' || table_required;
      query_str  := query_str || ' WHERE 1=1 ';

      IF p_serial_number IS NOT NULL THEN
        query_str  := query_str || ' AND (serial_number = :serial_n) ';
      END IF;
      IF p_serial_number_from IS NOT NULL THEN
        query_str  := query_str || ' AND serial_number >= :serial_f ';
      END IF;
      IF p_serial_number_to IS NOT NULL THEN
        query_str  := query_str || ' AND serial_number <= :serial_t ';
      END IF;
      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || ' AND inventory_item_id = :item_id ';
      END IF;
      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
      END IF;
      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
      END IF;
      IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;
      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;
      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || ' AND cost_group_id = :cg_id ';
      END IF;
      IF p_revision_controlled = 1 THEN
        query_str  := query_str || ' AND revision IS NULL ';
      ELSIF p_revision_controlled = 2 THEN
        query_str  := query_str || ' AND revision IS NOT NULL ';
      END IF;
      IF p_revision IS NOT NULL THEN
        query_str  := query_str || ' AND revision = :rev ';
      END IF;
      IF p_containerized = 1 THEN
        query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
      ELSIF p_containerized = 2 THEN
        query_str  := query_str || ' AND containerized_flag = 1 ';
      END IF;
      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || ' AND locator_id = :loc_id ';
      END IF;
      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes
      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || ' AND subinventory_code = :sub ';
      END IF;
      IF p_serial_controlled = 1 THEN
            query_str  := query_str || 'AND item_serial_control in (1,6) ';
      ELSIF p_serial_controlled = 2 THEN
        query_str := query_str || ' AND item_serial_control in (2,5) ';
      END IF;

      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;

      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;

      query_str := query_str || ' AND grade_code is not null ';

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || ' AND organization_id = :org_id ';
      ELSE
        query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id   = ms.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
      END IF;

 --       query_str := query_str ||  ' ) ' ;  -- new

      query_str  := query_str || ' GROUP BY grade_code ';

    ELSIF ((p_serial_number_from IS NULL AND p_serial_number_to IS NULL AND p_serial_number IS NULL )
            AND ( p_lpn_from IS NOT NULL OR p_lpn_to IS NOT NULL ) ) THEN

       IF p_sub_type = 2 THEN
         table_required := ' MTL_ONHAND_LPN_MWB_V ml ' ;
       ELSE
         table_required := ' MTL_ONHAND_NEW_LPN_MWB_V ml ' ;
       END IF ;

      query_str  := query_str || ' SELECT grade_code from ' || table_required;
      query_str  := query_str || ' WHERE 1=1 ';

      IF p_inventory_item_id IS NOT NULL THEN
        query_str  := query_str || 'AND inventory_item_id = :item_id ';
      END IF;
      IF p_project_id IS NOT NULL THEN
        query_str  := query_str || ' AND project_id = :pr_id ';
      END IF;
      IF p_task_id IS NOT NULL THEN
        query_str  := query_str || ' AND task_id = :ta_id ';
      END IF;
     IF (p_owning_qry_mode = 4) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 2 ';
      ELSIF(p_owning_qry_mode = 3) THEN
        query_str  := query_str || ' AND owning_organization_id = :own_org ';
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      ELSIF(p_owning_qry_mode = 2) THEN
        query_str  := query_str || ' AND owning_tp_type = 1 ';
      END IF;
      IF (p_planning_query_mode = 4) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 2 ';
      ELSIF(p_planning_query_mode = 3) THEN
        query_str  := query_str || ' AND planning_organization_id = :plan_org ';
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      ELSIF(p_planning_query_mode = 2) THEN
        query_str  := query_str || ' AND planning_tp_type = 1 ';
      END IF;
      IF p_cost_group_id IS NOT NULL THEN
        query_str  := query_str || ' AND cost_group_id = :cg_id ';
      END IF;
      IF p_revision_controlled = 1 THEN
        query_str  := query_str || ' AND revision IS NULL ';
      ELSIF p_revision_controlled = 2 THEN
        query_str  := query_str || ' AND revision IS NOT NULL ';
      END IF;
      IF p_revision IS NOT NULL THEN
        query_str  := query_str || ' AND revision = :rev ';
      END IF;
      IF p_containerized = 1 THEN
        query_str  := query_str || ' AND (containerized_flag is null or containerized_flag <> 1) ';
      ELSIF p_containerized = 2 THEN
        query_str  := query_str || 'AND containerized_flag = 1 ';
      END IF;
      IF p_locator_id IS NOT NULL THEN
        query_str  := query_str || ' AND locator_id = :loc_id ';
      END IF;

      --ER(3338592) Changes
      IF p_item_description IS NOT NULL THEN
         query_str := query_str || ' AND item_description LIKE :item_description ';
      END IF;
      --ER(3338592) Changes
      IF p_subinventory_code IS NOT NULL THEN
        query_str  := query_str || ' AND subinventory_code = :sub ';
      END IF;
      IF p_serial_controlled = 1 THEN
            query_str  := query_str || ' AND item_serial_control in (1,6) ';
      ELSIF p_serial_controlled = 2 THEN
        query_str := query_str || ' AND item_serial_control in (2,5) ';
      END IF;
      IF p_lpn_from IS NOT NULL OR p_lpn_to IS NOT NULL THEN
         IF p_lpn_from IS NOT NULL AND p_lpn_to IS NULL THEN
            query_str  := query_str || ' AND license_plate_number >= :lpn_f ';
          ELSIF p_lpn_from IS NULL AND p_lpn_to IS NOT NULL THEN
            query_str  := query_str || ' AND license_plate_number <= :lpn_t ';
          ELSIF p_lpn_from IS NOT NULL  AND p_lpn_to IS NOT NULL THEN
            query_str  := query_str || ' AND license_plate_number >= :lpn_f ';
            query_str  := query_str || ' AND license_plate_number <= :lpn_t ';
          END IF;
      END IF;

      IF p_grade_from IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_f ' ;
      END IF ;

      IF p_grade_code  IS NOT NULL THEN
         query_str := query_str || ' AND grade_code = :grade_c ' ;
      END IF ;

      query_str := query_str || ' AND grade_code is not NULL ';

      IF p_organization_id IS NOT NULL THEN
        query_str  := query_str || ' AND organization_id = :org_id ';
      ELSE
        query_str  := query_str || ' and EXISTS ( SELECT 1 ' ;
        query_str  := query_str || ' FROM org_access_view oav ' ;
        query_str  := query_str || ' WHERE oav.organization_id   = ml.organization_id ' ;
        query_str  := query_str || ' AND oav.responsibility_id   = :responsibility_id ' ;
        query_str  := query_str || ' AND oav.resp_application_id = :resp_application_id ) ' ;
      END IF;

--        query_str := query_str ||  ' ) ' ;  -- new

      query_str  := query_str || ' GROUP BY grade_code ';

   END IF ;

   inv_trx_util_pub.trace( query_str, 'Add-Grades Material Workbench', 9);
   -- execute the query and populate the node table
    query_hdl       := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(query_hdl, query_str, DBMS_SQL.native);

   IF p_grade_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_f',p_grade_from );
   END IF;

   IF p_grade_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'grade_c', p_grade_code);
   END IF;
   IF p_organization_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'org_id', p_organization_id);
    END IF;
   IF p_organization_id IS NULL THEN
      IF p_responsibility_id  IS NOT NULL THEN
         dbms_sql.bind_variable(query_hdl, 'responsibility_id', p_responsibility_id );
      END IF;
      IF p_resp_application_id  IS NOT NULL THEN
         dbms_sql.bind_variable(query_hdl, 'resp_application_id', p_resp_application_id );
      END IF;
    END IF;
    IF p_subinventory_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'sub', p_subinventory_code);
    END IF;
    IF p_locator_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'loc_id', p_locator_id);
    END IF;
    IF p_inventory_item_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'item_id', p_inventory_item_id);
    END IF;
    IF p_revision IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'rev', p_revision);
    END IF;
    IF p_cost_group_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'cg_id', p_cost_group_id);
    END IF;
  --  IF p_lot_number_from IS NOT NULL THEN
  --      DBMS_SQL.bind_variable(query_hdl, 'lot_f', p_lot_number_from);
  --  END IF;
  --  IF p_lot_number_to IS NOT NULL THEN
  --    DBMS_SQL.bind_variable(query_hdl, 'lot_t', p_lot_number_to);
  --  END IF;
    IF p_serial_number_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_f', p_serial_number_from);
    END IF;
    IF p_serial_number_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_t', p_serial_number_to);
    END IF;
    IF p_serial_number IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'serial_n', p_serial_number);
    END IF;
    IF p_lpn_from IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lpn_f', p_lpn_from);
    END IF;
    IF p_lpn_to IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'lpn_t', p_lpn_to);
    END IF;
  --  IF p_parent_lpn_id IS NOT NULL THEN
  --    DBMS_SQL.bind_variable(query_hdl, 'plpn_id', p_parent_lpn_id);
  --  END IF;
--    IF p_status_id IS NOT NULL THEN
--      DBMS_SQL.bind_variable(query_hdl, 'st_id', p_status_id);
--    END IF;
--    IF p_prepacked <> 1
--       AND p_prepacked <> 999 THEN
--      DBMS_SQL.bind_variable(query_hdl, 'prepacked', p_prepacked);
--    END IF;
--  IF p_mln_context_code IS NOT NULL THEN
--      DBMS_SQL.bind_variable(query_hdl, 'mln_context', p_mln_context_code);
--    END IF;
    IF p_project_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'pr_id', p_project_id);
    END IF;
    IF p_task_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(query_hdl, 'ta_id', p_task_id);
    END IF;
--    IF p_unit_number IS NOT NULL THEN
--      DBMS_SQL.bind_variable(query_hdl, 'un_id', p_unit_number);
--    END IF;
     IF (p_owning_qry_mode = 4)
       OR(p_owning_qry_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'own_org', p_owning_org);
    END IF;
    IF (p_planning_query_mode = 4)
       OR(p_planning_query_mode = 3) THEN
      DBMS_SQL.bind_variable(query_hdl, 'plan_org', p_planning_org);
    END IF;
    --ER(3338592) Changes
    IF p_item_description IS NOT NULL THEN
       dbms_sql.bind_variable(query_hdl, 'item_description', p_item_description);
    END IF;
    DBMS_SQL.define_column(query_hdl, 1, grade, 150);
    rows_processed  := DBMS_SQL.EXECUTE(query_hdl);

    --inv_trx_util_pub.trace( 'Material Workbench rows processed  ' || rows_processed, 'Material Workbench', 9);

    LOOP
      -- fetch a row
      IF DBMS_SQL.fetch_rows(query_hdl) > 0 THEN
        -- fetch columns from the row
        DBMS_SQL.column_value(query_hdl, 1, grade);
        IF j >= p_node_low_value THEN
          x_node_tbl(i).state  := p_node_state;
          x_node_tbl(i).DEPTH  := 1;
          x_node_tbl(i).label  := substr(grade,1,80);
          x_node_tbl(i).icon   := 'grades_cctitle' ;
          x_node_tbl(i).VALUE  := grade;
          x_node_tbl(i).TYPE   := 'GRADE';
          i                    := i + 1;
        END IF;
        EXIT WHEN j >= p_node_high_value;
        j  := j + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;
    DBMS_SQL.close_cursor(query_hdl); -- close cursor
    x_node_value    := j;
    x_tbl_index     := i;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END add_grades ;
  -- NSRIVAST, INVCONV, End

  -- Procedure to get the flexfield structure of mtl_lot_numbers flexfield.
  -- This procedure appends the entries to a table that has
  -- already been populated
  PROCEDURE get_mln_attributes_structure(
    x_attributes       IN OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , x_attributes_count OUT NOCOPY    NUMBER
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    NUMBER
  , p_mln_context_code IN            VARCHAR2
  ) IS
    -- Cursor to get the segments that are enabled in the given context and
    -- IN the global context
    CURSOR mln_structure IS
      SELECT   fdfcu.form_left_prompt
             , fdfcu.application_column_name
          FROM fnd_descr_flex_col_usage_vl fdfcu, fnd_application_vl fa
         WHERE fdfcu.application_id = fa.application_id
           AND fa.application_short_name = 'INV'
           AND fdfcu.descriptive_flexfield_name = 'MTL_LOT_NUMBERS'
           AND(
               fdfcu.descriptive_flex_context_code IN(
                 SELECT fdfc.descriptive_flex_context_code
                   FROM fnd_descr_flex_contexts_vl fdfc
                  WHERE fdfc.global_flag = 'Y'
                    AND fdfc.descriptive_flexfield_name = 'MTL_LOT_NUMBERS'
                    AND fdfc.application_id = fa.application_id)
               OR fdfcu.descriptive_flex_context_code = p_mln_context_code
              )
           AND fdfcu.enabled_flag = 'Y'
      ORDER BY fdfcu.column_seq_num;
  BEGIN
    x_return_status     := fnd_api.g_ret_sts_unexp_error;
    x_attributes_count  := x_attributes.COUNT;

    FOR mln_structure_rec IN mln_structure LOOP
      x_attributes_count                            := x_attributes_count + 1;
      x_attributes(x_attributes_count).prompt       := mln_structure_rec.form_left_prompt;
      x_attributes(x_attributes_count).column_type  := 'VARCHAR2';
      x_attributes(x_attributes_count).column_name  := mln_structure_rec.application_column_name;
    END LOOP;

    x_return_status     := fnd_api.g_ret_sts_success;
  END get_mln_attributes_structure;

  -- Procedure to get the values populated in MTL_LOT_NUMBERS of the enabled segments
  -- This procedure appends the entries to a table that has
  -- already been populated
  PROCEDURE get_mln_attributes(
    x_attribute_values  IN OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , x_attribute_prompts IN OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , x_attributes_count  OUT NOCOPY    NUMBER
  , x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    NUMBER
  , p_organization_id   IN            NUMBER
  , p_inventory_item_id IN            NUMBER
  , p_lot_number        IN            VARCHAR2
  ) IS
    -- Cursor to get the segments that are enabled in the given context and
    -- IN the global context
    CURSOR mln_dff_structure(p_mln_context_code VARCHAR2) IS
      SELECT   fdfcu.form_left_prompt
             , fdfcu.application_column_name
          FROM fnd_descr_flex_col_usage_vl fdfcu, fnd_application_vl fa
         WHERE fdfcu.application_id = fa.application_id
           AND fa.application_short_name = 'INV'
           AND fdfcu.descriptive_flexfield_name = 'MTL_LOT_NUMBERS'
           AND(
               fdfcu.descriptive_flex_context_code IN(
                 SELECT fdfc.descriptive_flex_context_code
                   FROM fnd_descr_flex_contexts_vl fdfc
                  WHERE fdfc.global_flag = 'Y'
                    AND fdfc.descriptive_flexfield_name = 'MTL_LOT_NUMBERS'
                    AND fdfc.application_id = fa.application_id)
               OR fdfcu.descriptive_flex_context_code = p_mln_context_code
              )
           AND fdfcu.enabled_flag = 'Y'
      ORDER BY fdfcu.column_seq_num;

    TYPE l_attribute_type IS TABLE OF mtl_lot_numbers.attribute1%TYPE
      INDEX BY BINARY_INTEGER;

    l_attribute        l_attribute_type;
    l_mln_context_code mtl_lot_numbers.attribute_category%TYPE;
  BEGIN
    x_return_status     := fnd_api.g_ret_sts_unexp_error;

    SELECT attribute1
         , attribute2
         , attribute3
         , attribute4
         , attribute5
         , attribute6
         , attribute7
         , attribute8
         , attribute9
         , attribute10
         , attribute11
         , attribute12
         , attribute13
         , attribute14
         , attribute15
         , attribute_category
      INTO l_attribute(1)
         , l_attribute(2)
         , l_attribute(3)
         , l_attribute(4)
         , l_attribute(5)
         , l_attribute(6)
         , l_attribute(7)
         , l_attribute(8)
         , l_attribute(9)
         , l_attribute(10)
         , l_attribute(11)
         , l_attribute(12)
         , l_attribute(13)
         , l_attribute(14)
         , l_attribute(15)
         , l_mln_context_code
      FROM mtl_lot_numbers
     WHERE inventory_item_id = p_inventory_item_id
       AND organization_id = p_organization_id
       AND lot_number = p_lot_number;

    x_attributes_count  := x_attribute_values.COUNT;

    FOR mln_dff_structure_rec IN mln_dff_structure(l_mln_context_code) LOOP
      x_attributes_count                                   := x_attributes_count + 1;
      x_attribute_prompts(x_attributes_count).prompt       := mln_dff_structure_rec.form_left_prompt;
      x_attribute_prompts(x_attributes_count).column_name  := mln_dff_structure_rec.application_column_name;
      x_attribute_values(x_attributes_count).column_name   := mln_dff_structure_rec.application_column_name;
      x_attribute_values(x_attributes_count).column_value  :=
                                                       l_attribute(TO_NUMBER(SUBSTR(mln_dff_structure_rec.application_column_name, 10, 2)));
    END LOOP;

    x_return_status     := fnd_api.g_ret_sts_success;
  END get_mln_attributes;

  -- Procedure to get the flexfield structure of mtl_lot_numbers flexfield.
  -- This procedure appends the entries to a table that has
  -- already been populated
  PROCEDURE get_msn_attributes_structure(
    x_attributes       IN OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , x_attributes_count OUT NOCOPY    NUMBER
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    NUMBER
  , p_msn_context_code IN            VARCHAR2
  ) IS
    -- Cursor to get the segments that are enabled in the given context and
    -- IN the global context
    CURSOR msn_structure IS
      SELECT   fdfcu.form_left_prompt
             , fdfcu.application_column_name
          FROM fnd_descr_flex_col_usage_vl fdfcu, fnd_application_vl fa
         WHERE fdfcu.application_id = fa.application_id
           AND fa.application_short_name = 'INV'
           AND fdfcu.descriptive_flexfield_name = 'MTL_SERIAL_NUMBERS'
           AND(
               fdfcu.descriptive_flex_context_code IN(
                 SELECT fdfc.descriptive_flex_context_code
                   FROM fnd_descr_flex_contexts_vl fdfc
                  WHERE fdfc.global_flag = 'Y'
                    AND fdfc.descriptive_flexfield_name = 'MTL_SERIAL_NUMBERS'
                    AND fdfc.application_id = fa.application_id)
               OR fdfcu.descriptive_flex_context_code = p_msn_context_code
              )
           AND fdfcu.enabled_flag = 'Y'
      ORDER BY fdfcu.column_seq_num;
  BEGIN
    x_return_status     := fnd_api.g_ret_sts_unexp_error;
    x_attributes_count  := x_attributes.COUNT;

    FOR msn_structure_rec IN msn_structure LOOP
      x_attributes_count                            := x_attributes_count + 1;
      x_attributes(x_attributes_count).prompt       := msn_structure_rec.form_left_prompt;
      x_attributes(x_attributes_count).column_type  := 'VARCHAR2';
      x_attributes(x_attributes_count).column_name  := msn_structure_rec.application_column_name;
    END LOOP;

    x_return_status     := fnd_api.g_ret_sts_success;
  END get_msn_attributes_structure;

  -- Procedure to get the values populated in MTL_SERIAL_NUMBERS of the enabled segments
  -- This procedure appends the entries to a table that has
  -- already been populated
  PROCEDURE get_msn_attributes(
    x_attribute_values  IN OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , x_attribute_prompts IN OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , x_attributes_count  OUT NOCOPY    NUMBER
  , x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    NUMBER
  , p_organization_id   IN            NUMBER
  , p_inventory_item_id IN            NUMBER
  , p_serial_number     IN            VARCHAR2
  ) IS
    -- Cursor to get the segments that are enabled in the given context and
    -- IN the global context
    CURSOR msn_dff_structure(p_msn_context_code VARCHAR2) IS
      SELECT   fdfcu.form_left_prompt
             , fdfcu.application_column_name
          FROM fnd_descr_flex_col_usage_vl fdfcu, fnd_application_vl fa
         WHERE fdfcu.application_id = fa.application_id
           AND fa.application_short_name = 'INV'
           AND fdfcu.descriptive_flexfield_name = 'MTL_SERIAL_NUMBERS'
           AND(
               fdfcu.descriptive_flex_context_code IN(
                 SELECT fdfc.descriptive_flex_context_code
                   FROM fnd_descr_flex_contexts_vl fdfc
                  WHERE fdfc.global_flag = 'Y'
                    AND fdfc.descriptive_flexfield_name = 'MTL_SERIAL_NUMBERS'
                    AND fdfc.application_id = fa.application_id)
               OR fdfcu.descriptive_flex_context_code = p_msn_context_code
              )
           AND fdfcu.enabled_flag = 'Y'
      ORDER BY fdfcu.column_seq_num;

    TYPE l_attribute_type IS TABLE OF mtl_serial_numbers.attribute1%TYPE
      INDEX BY BINARY_INTEGER;

    l_attribute        l_attribute_type;
    l_msn_context_code mtl_serial_numbers.attribute_category%TYPE;
  BEGIN
    x_return_status     := fnd_api.g_ret_sts_unexp_error;

    SELECT attribute1
         , attribute2
         , attribute3
         , attribute4
         , attribute5
         , attribute6
         , attribute7
         , attribute8
         , attribute9
         , attribute10
         , attribute11
         , attribute12
         , attribute13
         , attribute14
         , attribute15
         , attribute_category
      INTO l_attribute(1)
         , l_attribute(2)
         , l_attribute(3)
         , l_attribute(4)
         , l_attribute(5)
         , l_attribute(6)
         , l_attribute(7)
         , l_attribute(8)
         , l_attribute(9)
         , l_attribute(10)
         , l_attribute(11)
         , l_attribute(12)
         , l_attribute(13)
         , l_attribute(14)
         , l_attribute(15)
         , l_msn_context_code
      FROM mtl_serial_numbers
     WHERE inventory_item_id = p_inventory_item_id
       AND current_organization_id = p_organization_id
       AND serial_number = p_serial_number;

    x_attributes_count  := x_attribute_values.COUNT;

    FOR msn_dff_structure_rec IN msn_dff_structure(l_msn_context_code) LOOP
      x_attributes_count                                   := x_attributes_count + 1;
      x_attribute_prompts(x_attributes_count).prompt       := msn_dff_structure_rec.form_left_prompt;
      x_attribute_prompts(x_attributes_count).column_name  := msn_dff_structure_rec.application_column_name;
      x_attribute_values(x_attributes_count).column_name   := msn_dff_structure_rec.application_column_name;
      x_attribute_values(x_attributes_count).column_value  :=
                                                       l_attribute(TO_NUMBER(SUBSTR(msn_dff_structure_rec.application_column_name, 10, 2)));
    END LOOP;

    x_return_status     := fnd_api.g_ret_sts_success;
  END get_msn_attributes;
END inv_mwb_tree;

/
