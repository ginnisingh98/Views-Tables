--------------------------------------------------------
--  DDL for Package Body INV_MINMAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MINMAX_PVT" AS
/* $Header: INVVMMXB.pls 120.12.12010000.5 2010/02/03 13:17:19 sanjeevs ship $ */

   --
   -- Replenishment Move Order Consolidation
   -- Initialize the Global variables to the values set in INV_MMX_WRAPPER_PVT.
   --
   G_USER_NAME fnd_user.user_name%TYPE := FND_GLOBAL.USER_NAME;
   G_TRACE_ON NUMBER                   := NVL(fnd_profile.value('INV_DEBUG_TRACE'),2);



    TYPE minmax_items_rectype IS RECORD
    ( item                       VARCHAR2(1000)
    , description                mtl_system_items.description%TYPE
    , fix_mult                   mtl_system_items.fixed_lot_multiplier%TYPE
    , min_qty                    mtl_system_items.min_minmax_quantity%TYPE
    , max_qty                    mtl_system_items.max_minmax_quantity%TYPE
    , min_ord_qty                mtl_system_items.minimum_order_quantity%TYPE
    , max_ord_qty                mtl_system_items.maximum_order_quantity%TYPE
    , fixed_lead_time            mtl_system_items.fixed_lead_time%TYPE
    , variable_lead_time         mtl_system_items.variable_lead_time%TYPE
    , postprocessing_lead_time   mtl_system_items.postprocessing_lead_time%TYPE
    , buying_lead_time           mtl_system_items.full_lead_time%TYPE
    , planner                    mtl_system_items.planner_code%TYPE
    , buyer                      per_all_people_f.full_name%TYPE
    , category                   VARCHAR2(800)
    , category_id                mtl_categories.category_id%TYPE
    , item_id                    mtl_system_items.inventory_item_id%TYPE
    , lot_ctl                    mtl_system_items.lot_control_code%TYPE
    , repetitive_planned_item    mtl_system_items.repetitive_planning_flag%TYPE
    , primary_uom                mtl_system_items.primary_uom_code%TYPE
    , accru_acct                 mtl_parameters.ap_accrual_account%TYPE
    , ipv_acct                   mtl_parameters.invoice_price_var_account%TYPE
    , budget_acct                mtl_system_items.encumbrance_account%TYPE
    , charge_acct                mtl_system_items.expense_account%TYPE
    , src_type                   mtl_system_items.source_type%TYPE
    , src_org                    mtl_system_items.source_organization_id%TYPE
    , src_subinv                 mtl_system_items.source_subinventory%TYPE
    , purch_flag                 mtl_system_items.purchasing_enabled_flag%TYPE
    , order_flag                 mtl_system_items.internal_order_enabled_flag%TYPE
    , transact_flag              mtl_system_items.mtl_transactions_enabled_flag%TYPE
    , unit_price                 mtl_system_items.list_price_per_unit%TYPE
    , mbf                        mtl_system_items.planning_make_buy_code%TYPE
    , build_in_wip               mtl_system_items.build_in_wip_flag%TYPE
/* nsinghi MIN-MAX INVCONV start */
    , process_enabled           mtl_parameters.process_enabled_flag%TYPE
    , recipe_enabled            mtl_system_items.recipe_enabled_flag%TYPE
    , execution_enabled         mtl_system_items.process_execution_enabled_flag%TYPE
/* nsinghi MIN-MAX INVCONV end */
    , pick_components            mtl_system_items.pick_components_flag%TYPE
    );

    --
    -- Start of forward declarations
    --

    FUNCTION get_catg_disp( p_category_id  NUMBER
                          , p_struct_id    NUMBER) RETURN VARCHAR2;

    /*
    FUNCTION get_onhand_qty( p_include_nonnet  NUMBER
                           , p_level           NUMBER
                           , p_org_id          NUMBER
                           , p_subinv          VARCHAR2
                           , p_item_id         NUMBER
                           , p_sysdate         DATE) RETURN NUMBER;
   */

    FUNCTION get_supply_qty( p_org_id              NUMBER
                           , p_subinv              VARCHAR2
                           , p_item_id             NUMBER
                           , p_postproc_lead_time  NUMBER
                           , p_cal_code            VARCHAR2
                           , p_except_id           NUMBER
                           , p_level               NUMBER
                           , p_s_cutoff            DATE
			   , p_include_po          NUMBER
                           , p_include_mo          NUMBER
			   , p_vmi_enabled         VARCHAR2
                           , p_include_nonnet      NUMBER
                           , p_include_wip         NUMBER
                           , p_include_if          NUMBER
                           /* nsinghi MIN-MAX INVCONV start */
                           , p_process_org         VARCHAR2
                           /* nsinghi MIN-MAX INVCONV end */
                           ) RETURN NUMBER;

    FUNCTION get_demand_qty( p_org_id          NUMBER
                           , p_subinv          VARCHAR2
                           , p_level           NUMBER
                           , p_item_id         NUMBER
                           , p_d_cutoff        DATE
                           , p_include_nonnet  NUMBER
                           , p_net_rsv         NUMBER
                           , p_net_unrsv       NUMBER
                           , p_net_wip         NUMBER
                           /* nsinghi MIN-MAX INVCONV start */
                           , p_process_org     VARCHAR2
                           /* nsinghi MIN-MAX INVCONV end */
                           ) RETURN NUMBER;

    FUNCTION get_reord_qty( p_min_qty        NUMBER
                          , p_max_qty        NUMBER
                          , p_min_ord_qty    NUMBER
                          , p_max_ord_qty    NUMBER
                          , p_tot_avail_qty  NUMBER
                          , p_fix_mult       NUMBER) RETURN NUMBER;

    FUNCTION get_reord_stat( p_restock           NUMBER
                           , p_handle_rep_item   NUMBER
                           , p_level             NUMBER
                           , p_reord_qty         NUMBER
                           , p_wip_batch_id      NUMBER
                           , p_org_id            NUMBER
                           , p_subinv            VARCHAR2
                           , p_user_id           NUMBER
                           , p_employee_id       NUMBER
                           , p_sysdate           DATE
                           , p_approval          NUMBER
                           , p_encum_flag        VARCHAR2
                           , p_cust_id           NUMBER
                           , p_cust_site_id      NUMBER
                           , p_cal_code          VARCHAR2
                           , p_exception_set_id  NUMBER
                           , p_dd_loc_id         NUMBER
                           , p_po_org_id         NUMBER
                           , p_pur_revision      NUMBER
                           , p_item_rec          minmax_items_rectype
                           , p_osfm_batch_id     NUMBER DEFAULT NULL	/* Added for Bug 6807835 */
                           ) RETURN VARCHAR2;

    PROCEDURE re_po( p_item_id          IN   NUMBER
                   , p_qty              IN   NUMBER
                   , p_nb_time          IN   DATE
                   , p_uom              IN   VARCHAR2
                   , p_accru_acct       IN   NUMBER
                   , p_ipv_acct         IN   NUMBER
                   , p_budget_acct      IN   NUMBER
                   , p_charge_acct      IN   NUMBER
                   , p_purch_flag       IN   VARCHAR2
                   , p_order_flag       IN   VARCHAR2
                   , p_transact_flag    IN   VARCHAR2
                   , p_unit_price       IN   NUMBER
                   , p_user_id          IN   NUMBER
                   , p_sysd             IN   DATE
                   , p_organization_id  IN   NUMBER
                   , p_approval         IN   NUMBER
                   , p_src_type         IN   NUMBER
                   , p_encum_flag       IN   VARCHAR2
                   , p_customer_id      IN   NUMBER
                   , p_employee_id      IN   NUMBER
                   , p_description      IN   VARCHAR2
                   , p_src_org          IN   NUMBER
                   , p_src_subinv       IN   VARCHAR2
                   , p_subinv           IN   VARCHAR2
                   , p_location_id      IN   NUMBER
                   , p_po_org_id        IN   NUMBER
                   , p_pur_revision     IN   NUMBER
                   , x_ret_stat         OUT  NOCOPY VARCHAR2
                   , x_ret_mesg         OUT  NOCOPY VARCHAR2);

    PROCEDURE re_wip( p_item_id          IN   NUMBER
                    , p_qty              IN   NUMBER
                    , p_nb_time          IN   DATE
                    , p_uom              IN   VARCHAR2
                    , p_wip_id           IN   NUMBER
                    , p_user_id          IN   NUMBER
                    , p_sysd             IN   DATE
                    , p_organization_id  IN   NUMBER
                    , p_approval         IN   NUMBER
                    , p_build_in_wip     IN   VARCHAR2
                    , p_pick_components  IN   VARCHAR2
                    , x_ret_stat         OUT  NOCOPY VARCHAR2
                    , x_ret_mesg         OUT  NOCOPY VARCHAR2
                    , p_osfm_batch_id    IN   NUMBER DEFAULT NULL    /* Added for Bug 6807835 */
                    );
/* Bug 6240025. Added the Procedure*/
    FUNCTION get_loaded_qty(p_org_id NUMBER
                    , p_subinv           VARCHAR2
                    , p_level            NUMBER
                    , p_item_id          NUMBER
		    , p_net_rsv		 NUMBER
		   , p_net_unrsv	 NUMBER) RETURN NUMBER;
/* nsinghi MIN-MAX INVCONV start */

    PROCEDURE re_batch( p_item_id        IN   NUMBER
                    , p_qty              IN   NUMBER
                    , p_nb_time          IN   DATE
                    , p_uom              IN   VARCHAR2
                    , p_organization_id  IN   NUMBER
                    , p_execution_enabled IN VARCHAR2
                    , p_recipe_enabled   IN VARCHAR2
                    , p_user_id          IN   NUMBER
                    , x_ret_stat         OUT  NOCOPY VARCHAR2
                    , x_ret_mesg         OUT  NOCOPY VARCHAR2);

/* nsinghi MIN-MAX INVCONV end */

    --
    -- End of forward declarations
    --


    PROCEDURE print_debug
    ( p_message  IN  VARCHAR2
    , p_module   IN  VARCHAR2
    , p_level    IN  NUMBER
    ) IS
    BEGIN
        inv_log_util.trace( G_USER_NAME || ':  ' || p_message
                              , G_PKG_NAME  || '.'   || p_module
                              , p_level
                              );

    EXCEPTION
        WHEN OTHERS THEN
             -- dbms_output.put_line(sqlcode || ', ' || l_err_msg);
             NULL;
    END print_debug;



    PROCEDURE run_min_max_plan ( p_item_select       IN  VARCHAR2
                               , p_handle_rep_item   IN  NUMBER
                               , p_pur_revision      IN  NUMBER
                               , p_cat_select        IN  VARCHAR2
                               , p_cat_set_id        IN  NUMBER
                               , p_mcat_struct       IN  NUMBER
                               , p_level             IN  NUMBER
                               , p_restock           IN  NUMBER
                               , p_include_nonnet    IN  NUMBER
                               , p_include_po        IN  NUMBER
                               , p_include_mo        IN  NUMBER DEFAULT 1
                               , p_include_wip       IN  NUMBER
                               , p_include_if        IN  NUMBER
                               , p_net_rsv           IN  NUMBER
                               , p_net_unrsv         IN  NUMBER
                               , p_net_wip           IN  NUMBER
                               , p_org_id            IN  NUMBER
                               , p_user_id           IN  NUMBER
                               , p_employee_id       IN  NUMBER
                               , p_subinv            IN  VARCHAR2
                               , p_dd_loc_id         IN  NUMBER
                               , p_wip_batch_id      IN  NUMBER
                               , p_approval          IN  NUMBER
                               , p_buyer_hi          IN  VARCHAR2
                               , p_buyer_lo          IN  VARCHAR2
                               , p_range_buyer       IN  VARCHAR2
                               , p_cust_id           IN  NUMBER
                               , p_cust_site_id      IN  NUMBER
                               , p_po_org_id         IN  NUMBER
                               , p_range_sql         IN  VARCHAR2
                               , p_sort              IN  VARCHAR2
                               , p_selection         IN  NUMBER
                               , p_sysdate           IN  DATE
                               , p_s_cutoff          IN  DATE
                               , p_d_cutoff          IN  DATE
                               , p_order_by          IN  VARCHAR2
                               , p_encum_flag        IN  VARCHAR2
                               , p_cal_code          IN  VARCHAR2
                               , p_exception_set_id  IN  NUMBER
                               , p_gen_report        IN  VARCHAR2
                               , x_return_status     OUT NOCOPY VARCHAR2
                               , x_msg_data          OUT NOCOPY VARCHAR2
                               , p_osfm_batch_id     IN  NUMBER  DEFAULT NULL    /* Added for Bug 6807835 */
                               ) IS

        TYPE c_items_curtype IS REF CURSOR;
        c_items_to_plan c_items_curtype;

        item_rec minmax_items_rectype;
/*bug3146742,changed p_item_select to concatenated segmentsto pick the segments with delimiters and table mtl_sytem_items to view mtl_sytem_items_v inorder to get the concatenated segments column*/
/* bug no 6009682 added parallel hints */
	sql_stmt1    VARCHAR2(8000) :=
               ' SELECT  /*+ parallel(b) parallel(a) */
	             c.concatenated_segments            item,
                     c.description                      description,
                     c.fixed_lot_multiplier             fix_mult,
                     c.min_minmax_quantity              min_qty,
                     c.max_minmax_quantity              max_qty,
                     c.minimum_order_quantity           min_ord_qty,
                     c.maximum_order_quantity           max_ord_qty,
                     c.fixed_lead_time,
                     c.variable_lead_time,
                     NVL(c.postprocessing_lead_time, 0) postprocessing_lead_time,
                     NVL(c.preprocessing_lead_time, 0) +
                       NVL(c.full_lead_time, 0)         buying_lead_time,
                     c.planner_code                     planner,
                     NULL                               buyer,
                     ' || p_cat_select || '             category,
                     b.category_id                      category_id,
                     c.inventory_item_id                item_id,
                     c.lot_control_code                 lot_ctl,
                     c.repetitive_planning_flag         repetitive_planned_item,
                     c.primary_uom_code                 primary_uom,
                     p.ap_accrual_account               accru_acct,
                     p.invoice_price_var_account        ipv_acct,
                     NVL(c.encumbrance_account, p.encumbrance_account)  budget_acct,
                     DECODE(c.inventory_asset_flag,
                            ''Y'', p.material_account,
                              NVL(c.expense_account, p.expense_account))  charge_acct,
                     NVL(c.source_type, p.source_type)  src_type,
                     DECODE(c.source_type,
                            NULL, DECODE(p.source_type, NULL, NULL, p.source_organization_id),
                            c.source_organization_id)   src_org,
                     DECODE(c.source_type,
                            NULL, DECODE(p.source_type, NULL, NULL, p.source_subinventory),
                            c.source_subinventory)      src_subinv,
                     c.purchasing_enabled_flag          purch_flag,
                     c.internal_order_enabled_flag      order_flag,
                     c.mtl_transactions_enabled_flag    transact_flag,
                     c.list_price_per_unit              unit_price,
                     c.planning_make_buy_code           mbf,
                     build_in_wip_flag                  build_in_wip,

/* nsinghi MIN-MAX INVCONV start */
                     NVL(p.process_enabled_flag,''N'')    process_enabled,
                     NVL(c.recipe_enabled_flag,''N'')     recipe_enabled,
                     NVL(c.process_execution_enabled_flag,''N'')   execution_enabled,
/* nsinghi MIN-MAX INVCONV end */
                     pick_components_flag               pick_components
                FROM mtl_categories       b,
                     mtl_item_categories  a,
                     mtl_system_items_vl   c,
                     mtl_parameters       p
               WHERE b.category_id             = a.category_id
                 AND b.structure_id            = :mcat_struct_id
                 AND c.inventory_item_flag     = ''Y''
                 AND p.organization_id         = :org_id
                 AND a.organization_id         = c.organization_id
                 AND a.organization_id         = :org_id            /* bug no 6009682 */
                 AND c.inventory_planning_code = 2
                 AND a.category_set_id         = :cat_set_id
                 AND a.inventory_item_id       = c.inventory_item_id
                 AND ( ' || p_range_sql || ' ) ';
/*bug3146742,changed p_item_select to concatenated segmentsto pick the segments with delimiters and table mtl_sytem_items to view mtl_sytem_items_v inorder to get the concatenated segments column*/
        sql_stmt2    VARCHAR2(8000) :=
            ' SELECT  c.concatenated_segments            item,
                     c.description                      description,
                     s.fixed_lot_multiple               fix_mult,
                     s.min_minmax_quantity              min_qty,
                     s.max_minmax_quantity              max_qty,
                     s.minimum_order_quantity           min_ord_qty,
                     s.maximum_order_quantity           max_ord_qty,
                     c.fixed_lead_time,
                     c.variable_lead_time,
                     NVL(c.postprocessing_lead_time, 0) postprocessing_lead_time,
                     NVL(s.preprocessing_lead_time,
                         NVL(m.preprocessing_lead_time,
                             NVL(c.preprocessing_lead_time, 0))) +
                     NVL(s.processing_lead_time,
                         NVL(m.processing_lead_time,
                             NVL(c.full_lead_time, 0))) buying_lead_time,
                     c.planner_code                     planner,
                     NULL,
                     ' || p_cat_select || ',
                     b.category_id                      category_id,
                     c.inventory_item_id                item_id,
                     c.lot_control_code,
                     c.repetitive_planning_flag         repetitive_planned_item,
                     c.primary_uom_code,
                     p.ap_accrual_account,
                     p.invoice_price_var_account,
                     NVL(s.encumbrance_account,
                         NVL(m.encumbrance_account,
                             NVL(c.encumbrance_account, p.encumbrance_account))),
                     DECODE(c.inventory_asset_flag,
                            ''Y'', m.material_account,
                            NVL(m.expense_account,
                                NVL(c.expense_account, p.expense_account))),
                     NVL(s.source_type,
                         NVL(m.source_type,
                             NVL(c.source_type, p.source_type))),
                     DECODE(s.source_type,
                            NULL, DECODE(m.source_type,
                                         NULL, DECODE(c.source_type,
                                                      NULL, DECODE(p.source_type,
                                                                   NULL, NULL,
                                                                   p.source_organization_id),
                                                      c.source_organization_id),
                                         m.source_organization_id),
                            s.source_organization_id),
                     DECODE(s.source_type,
                            NULL, DECODE(m.source_type,
                                         NULL, DECODE(c.source_type,
                                                      NULL, DECODE(p.source_type,
                                                                   NULL, NULL,
                                                                   p.source_subinventory),
                                                      c.source_subinventory),
                                         m.source_subinventory),
                            s.source_subinventory),
                     c.purchasing_enabled_flag,
                     c.internal_order_enabled_flag,
                     c.mtl_transactions_enabled_flag,
                     c.list_price_per_unit,
                     c.planning_make_buy_code,
                     build_in_wip_flag,
/* nsinghi MIN-MAX INVCONV start */
                     NVL(p.process_enabled_flag,''N'')    process_enabled,
                     NVL(c.recipe_enabled_flag,''N'')     recipe_enabled,
                     NVL(c.process_execution_enabled_flag,''N'')   execution_enabled,
/* nsinghi MIN-MAX INVCONV end */
                     pick_components_flag
                FROM mtl_categories             b,
                     mtl_item_categories        a,
                     mtl_system_items_vl        c,
                     mtl_parameters             p,
                     mtl_secondary_inventories  m,
                     mtl_item_sub_inventories   s
               WHERE b.category_id              = a.category_id
                 AND b.structure_id             = :mcat_struct_id
                 AND c.inventory_item_flag      = ''Y''
                 AND p.organization_id          = :org_id
                 AND a.organization_id          = c.organization_id
                 AND c.organization_id          = :org_id
                 AND c.inventory_item_id        = s.inventory_item_id
                 AND a.category_set_id          = :cat_set_id
                 AND a.inventory_item_id        = s.inventory_item_id
                 AND s.organization_id          = :org_id
                 AND s.inventory_planning_code  = 2
                 AND s.secondary_inventory      = :sub
                 AND m.organization_id          = :org_id
                 AND m.secondary_inventory_name = :sub
                 AND ( ' || p_range_sql || ' ) ';
/*bug3146742,changed p_item_select to concatenated segmentsto pick the segments with delimiters and table mtl_sytem_items to view mtl_sytem_items_v inorder to get the concatenated segments column*/
        sql_stmt3    VARCHAR2(8000) :=
            ' SELECT  c.concatenated_segments,
                     c.description,
                     c.fixed_lot_multiplier,
                     c.min_minmax_quantity,
                     c.max_minmax_quantity,
                     c.minimum_order_quantity,
                     c.maximum_order_quantity,
                     c.fixed_lead_time,
                     c.variable_lead_time,
                     NVL(c.postprocessing_lead_time, 0) postprocessing_lead_time,
                     NVL(c.preprocessing_lead_time, 0) +
                         NVL(c.full_lead_time, 0)       buying_lead_time,
                     c.planner_code                     planner,
                     SUBSTR(v.full_name, 1, 10),
                     ' || p_cat_select || ',
                     b.category_id                      category_id,
                     c.inventory_item_id,
                     c.lot_control_code,
                     c.repetitive_planning_flag         repetitive_planned_item,
                     c.primary_uom_code,
                     p.ap_accrual_account,
                     p.invoice_price_var_account,
                     NVL(c.encumbrance_account, p.encumbrance_account),
                     decode(c.inventory_asset_flag,
                            ''Y'', p.material_account,
                            NVL(c.expense_account, p.expense_account)),
                     NVL(c.source_type, p.source_type),
                     decode(c.source_type, NULL, decode(p.source_type, NULL, NULL,
                            p.source_organization_id), c.source_organization_id),
                     decode(c.source_type, NULL, decode(p.source_type, NULL, NULL,
                            p.source_subinventory), c.source_subinventory),
                     c.purchasing_enabled_flag,
                     c.internal_order_enabled_flag,
                     c.mtl_transactions_enabled_flag,
                     c.list_price_per_unit,
                     c.planning_make_buy_code,
                     build_in_wip_flag,
/* nsinghi MIN-MAX INVCONV start */
                     NVL(p.process_enabled_flag,''N'')    process_enabled,
                     NVL(c.recipe_enabled_flag,''N'')     recipe_enabled,
                     NVL(c.process_execution_enabled_flag,''N'')   execution_enabled,
/* nsinghi MIN-MAX INVCONV end */
                     pick_components_flag
                FROM mtl_categories       b,
                     mtl_item_categories  a,
                     mtl_system_items_vl  c,
                     mtl_parameters       p,
                     per_all_people_f     v
               WHERE b.category_id             = a.category_id
                 AND b.structure_id            = :mcat_struct_id
                 AND c.inventory_item_flag     = ''Y''
                 AND p.organization_id         = :org_id
                 AND a.organization_id         = c.organization_id
                 AND c.organization_id         = :org_id
                 AND c.inventory_planning_code = 2
                 AND a.category_set_id         = :cat_set_id
                 AND a.inventory_item_id       = c.inventory_item_id
                 AND v.person_id (+)           = c.buyer_id
                 AND (
                      (:l_sysdate between v.effective_start_date and v.effective_end_date)
                      OR
                      (v.effective_start_date IS NULL AND v.effective_end_date IS NULL)
                     )
                 AND ( ' || p_range_sql || ' )
                 AND ( ' || p_range_buyer || ' ) ';

/*bug3146742,changed p_item_select to concatenated segmentsto pick the segments with delimiters and table mtl_sytem_items to view mtl_sytem_items_v inorder to get the concatenated segments column*/
        sql_stmt4    VARCHAR2(8000) :=
            ' SELECT  c.concatenated_segments,
                     c.description,
                     s.fixed_lot_multiple,
                     s.min_minmax_quantity,
                     s.max_minmax_quantity,
                     s.minimum_order_quantity,
                     s.maximum_order_quantity,
                     c.fixed_lead_time,
                     c.variable_lead_time,
                     NVL(c.postprocessing_lead_time, 0) postprocessing_lead_time,
                     NVL(s.preprocessing_lead_time,
                         NVL(m.preprocessing_lead_time,
                             NVL(c.preprocessing_lead_time, 0))) +
                     NVL(s.processing_lead_time,
                         NVL(m.processing_lead_time,
                             NVL(c.full_lead_time, 0))) buying_lead_time,
                     c.planner_code                     planner,
                     SUBSTR(v.full_name, 1, 10),
                     ' || p_cat_select || ',
                     b.category_id                      category_id,
                     c.inventory_item_id,
                     c.lot_control_code,
                     c.repetitive_planning_flag         repetitive_planned_item,
                     c.primary_uom_code,
                     p.ap_accrual_account,
                     p.invoice_price_var_account,
                     NVL(s.encumbrance_account,
                         NVL(m.encumbrance_account,
                             NVL(c.encumbrance_account, p.encumbrance_account))),
                     DECODE(c.inventory_asset_flag,
                            ''Y'', m.material_account,
                            NVL(m.expense_account,
                                NVL(c.expense_account, p.expense_account))),
                     NVL(s.source_type,
                         NVL(m.source_type,
                             NVL(c.source_type, p.source_type))),
                     DECODE(s.source_type,
                            NULL, DECODE(m.source_type,
                                         NULL, DECODE(c.source_type,
                                                      NULL, DECODE(p.source_type,
                                                                   NULL, NULL,
                                                                   p.source_organization_id),
                                                      c.source_organization_id),
                                         m.source_organization_id),
                            s.source_organization_id),
                     DECODE(s.source_type,
                            NULL, DECODE(m.source_type,
                                         NULL, DECODE(c.source_type,
                                                      NULL, DECODE(p.source_type,
                                                                   NULL, NULL,
                                                                   p.source_subinventory),
                                                      c.source_subinventory),
                                         m.source_subinventory),
                            s.source_subinventory),
                     c.purchasing_enabled_flag,
                     c.internal_order_enabled_flag,
                     c.mtl_transactions_enabled_flag,
                     c.list_price_per_unit,
                     c.planning_make_buy_code,
                     build_in_wip_flag,
/* nsinghi MIN-MAX INVCONV start */
                     NVL(p.process_enabled_flag,''N'')    process_enabled,
                     NVL(c.recipe_enabled_flag,''N'')     recipe_enabled,
                     NVL(c.process_execution_enabled_flag,''N'')   execution_enabled,
/* nsinghi MIN-MAX INVCONV end */
                     pick_components_flag
                FROM mtl_categories             b,
                     mtl_item_categories        a,
                     mtl_system_items_vl        c,
                     mtl_parameters             p,
                     mtl_secondary_inventories  m,
                     mtl_item_sub_inventories   s,
                     per_all_people_f           v
               WHERE b.category_id              = a.category_id
                 AND b.structure_id             = :mcat_struct_id
                 AND c.inventory_item_flag      = ''Y''
                 AND p.organization_id          = :org_id
                 AND a.organization_id          = c.organization_id
                 AND c.organization_id          = :org_id
                 AND c.inventory_item_id        = s.inventory_item_id
                 AND a.category_set_id          = :cat_set_id
                 AND a.inventory_item_id        = s.inventory_item_id
                 AND s.organization_id          = :org_id
                 AND s.inventory_planning_code  = 2
                 AND s.secondary_inventory      = :sub
                 AND m.organization_id          = :org_id
                 AND m.secondary_inventory_name = :sub
                 AND v.person_id (+)            = c.buyer_id
                 AND (
                      (:l_sysdate between v.effective_start_date and v.effective_end_date)
                      OR
                      (v.effective_start_date IS NULL AND v.effective_end_date IS NULL)
                     )
                 AND ( ' || p_range_sql || ' )
                 AND ( ' || p_range_buyer || ' ) ' ;


        l_proc_name       CONSTANT VARCHAR2(30) := 'RUN_MIN_MAX_PLAN';

        -- Report columns
        l_item_segments   INV_MIN_MAX_TEMP.item_segments%TYPE;
        l_catg_disp       VARCHAR2(300);
        l_sortee          INV_MIN_MAX_TEMP.sortee%TYPE;
        l_onhand_qty      INV_MIN_MAX_TEMP.onhand_qty%TYPE;

        l_stat            INV_MIN_MAX_TEMP.error%TYPE;
        l_supply_qty      INV_MIN_MAX_TEMP.supply_qty%TYPE;
        l_demand_qty      INV_MIN_MAX_TEMP.demand_qty%TYPE;
        l_tot_avail_qty   INV_MIN_MAX_TEMP.tot_avail_qty%TYPE;
        l_reord_qty       INV_MIN_MAX_TEMP.reord_qty%TYPE;

        l_err_msg         VARCHAR2(2000);
	l_vmi_enabled     VARCHAR2(1) := 'N';
    BEGIN

        --
        -- Query debug settings, set global variables
        --
       IF G_TRACE_ON = 1 THEN
            print_debug
            ('Starting Min-max planning with the following parameters: ' || fnd_global.local_chr(10) ||
             '  p_item_select: '      || p_item_select              || fnd_global.local_chr(10) ||
             ', p_handle_rep_item: '  || to_char(p_handle_rep_item) || fnd_global.local_chr(10) ||
             ', p_pur_revision: '     || to_char(p_pur_revision)    || fnd_global.local_chr(10) ||
             ', p_cat_select: '       || p_cat_select               || fnd_global.local_chr(10) ||
             ', p_cat_set_id: '       || to_char(p_cat_set_id)      || fnd_global.local_chr(10) ||
             ', p_mcat_struct: '      || to_char(p_mcat_struct)     || fnd_global.local_chr(10) ||
             ', p_level: '            || to_char(p_level)           || fnd_global.local_chr(10) ||
             ', p_restock: '          || to_char(p_restock)         || fnd_global.local_chr(10) ||
             ', p_include_nonnet: '   || to_char(p_include_nonnet)  || fnd_global.local_chr(10) ||
             ', p_include_po: '       || to_char(p_include_po)      || fnd_global.local_chr(10) ||
             ', p_include_mo: '       || to_char(p_include_mo)      || fnd_global.local_chr(10) ||
             ', p_include_wip: '      || to_char(p_include_wip)     || fnd_global.local_chr(10) ||
             ', p_include_if: '       || to_char(p_include_if)      || fnd_global.local_chr(10)
             ,  l_proc_name
             ,  5
            );

            print_debug
            ('Parameters contd..: '   || fnd_global.local_chr(10)   ||
             '  p_net_rsv: '          || to_char(p_net_rsv)         || fnd_global.local_chr(10) ||
             ', p_net_unrsv: '        || to_char(p_net_unrsv)       || fnd_global.local_chr(10) ||
             ', p_net_wip: '          || to_char(p_net_wip)         || fnd_global.local_chr(10) ||
             ', p_org_id: '           || to_char(p_org_id)          || fnd_global.local_chr(10) ||
             ', p_user_id: '          || to_char(p_user_id)         || fnd_global.local_chr(10) ||
             ', p_employee_id: '      || to_char(p_employee_id)     || fnd_global.local_chr(10) ||
             ', p_subinv: '           || p_subinv                   || fnd_global.local_chr(10) ||
             ', p_dd_loc_id: '        || to_char(p_dd_loc_id)       || fnd_global.local_chr(10) ||
             ', p_approval: '         || to_char(p_approval)        || fnd_global.local_chr(10) ||
             ', p_wip_batch_id: '     || to_char(p_wip_batch_id)    || fnd_global.local_chr(10) ||
             ', p_buyer_hi: '         || p_buyer_hi                 || fnd_global.local_chr(10) ||
             ', p_buyer_lo: '         || p_buyer_lo                 || fnd_global.local_chr(10) ||
             ', p_range_buyer: '      || p_range_buyer              || fnd_global.local_chr(10)
             ,  l_proc_name
             ,  5
            );

            print_debug
            ('Parameters contd..: '   || fnd_global.local_chr(10)   ||
             '  p_cust_id: '          || to_char(p_cust_id)         || fnd_global.local_chr(10) ||
             ', p_cust_site_id: '     || to_char(p_cust_site_id)    || fnd_global.local_chr(10) ||
             ', p_po_org_id: '        || to_char(p_po_org_id)       || fnd_global.local_chr(10) ||
             ', p_range_sql: '        || p_range_sql                || fnd_global.local_chr(10) ||
             ', p_sort: '             || p_sort                     || fnd_global.local_chr(10) ||
             ', p_selection: '        || to_char(p_selection)       || fnd_global.local_chr(10) ||
             ', p_sysdate: '          || to_char(p_sysdate,  'DD-MON-YYYY HH24:MI:SS') ||
                                         fnd_global.local_chr(10)                      ||
             ', p_s_cutoff: '         || to_char(p_s_cutoff, 'DD-MON-YYYY HH24:MI:SS') ||
                                         fnd_global.local_chr(10)                      ||
             ', p_d_cutoff: '         || to_char(p_d_cutoff, 'DD-MON-YYYY HH24:MI:SS') ||
                                         fnd_global.local_chr(10)                      ||
             ', p_order_by: '         || p_order_by                 || fnd_global.local_chr(10) ||
             ', p_encum_flag: '       || p_encum_flag               || fnd_global.local_chr(10) ||
             ', p_cal_code: '         || p_cal_code                 || fnd_global.local_chr(10) ||
             ', p_exception_set_id: ' || to_char(p_exception_set_id)|| fnd_global.local_chr(10) ||
             ', p_gen_report: '       || p_gen_report               || fnd_global.local_chr(10) ||
             ', p_osfm_batch_id: '    || p_osfm_batch_id            || fnd_global.local_chr(10)
             ,  l_proc_name
             ,  5
            );
       END IF;

	--
        -- Determine if we need to account for VMI
        --
        BEGIN
	   IF p_level = 1 THEN --only for org level; default is 'N'

	      SELECT NVL(fnd_profile.value('PO_VMI_ENABLED'),'N')
		INTO l_vmi_enabled
		FROM dual;
	   END IF;

        EXCEPTION
            WHEN OTHERS THEN
                 l_vmi_enabled := 'N';
        END;

        print_debug('Profile PO_VMI_ENABLED is: ' || l_vmi_enabled
                    , 'run_min_max_plan'
                    , 5);

        --
        -- Decide which SQL statement to execute based on
        -- planning level, sort options and whether or not
        -- buyers are specified
        --
        IF p_level = 1
        THEN
            IF (p_sort = '1' OR p_sort = '2' OR p_sort = '3')
               AND
               (p_buyer_hi IS NULL AND p_buyer_lo IS NULL)
            THEN
                OPEN c_items_to_plan FOR sql_stmt1 || p_order_by
                USING
                    p_mcat_struct, p_org_id, p_org_id, p_cat_set_id;
            ELSE
                OPEN c_items_to_plan FOR sql_stmt3 || p_order_by
                USING
                    p_mcat_struct, p_org_id, p_org_id, p_cat_set_id, p_sysdate;
            END IF;
        ELSE
        --
        -- Planning at subinventory level (p_level = 2)
        --
            IF (p_sort = '1' OR p_sort = '2' OR p_sort = '3')
               AND
               (p_buyer_hi IS NULL AND p_buyer_lo IS NULL)
            THEN
                OPEN c_items_to_plan FOR sql_stmt2 || p_order_by
                USING
                    p_mcat_struct, p_org_id, p_org_id, p_cat_set_id,
                    p_org_id, p_subinv, p_org_id, p_subinv;
            ELSE
                OPEN c_items_to_plan FOR sql_stmt4 || p_order_by
                USING
                    p_mcat_struct, p_org_id, p_org_id, p_cat_set_id,
                    p_org_id, p_subinv, p_org_id, p_subinv, p_sysdate;
            END IF;
        END IF;

        --
        --
        LOOP
            FETCH c_items_to_plan INTO item_rec;
            EXIT WHEN c_items_to_plan%NOTFOUND;

            IF G_TRACE_ON = 1 THEN
               print_debug('  Item #: '   || item_rec.item             ||
                           ', Item ID: '  || to_char(item_rec.item_id)
                           ,  l_proc_name
                           , 7);
            END IF;

            l_onhand_qty := get_onhand_qty( p_include_nonnet  => p_include_nonnet
                                          , p_level           => p_level
                                          , p_org_id          => p_org_id
                                          , p_subinv          => p_subinv
                                          , p_item_id         => item_rec.item_id
                                          , p_sysdate         => p_sysdate);

            l_supply_qty :=  get_supply_qty( p_org_id             => p_org_id
                                           , p_subinv             => p_subinv
                                           , p_item_id            => item_rec.item_id
                                           , p_postproc_lead_time => item_rec.postprocessing_lead_time
                                           , p_cal_code           => p_cal_code
                                           , p_except_id          => p_exception_set_id
                                           , p_level              => p_level
                                           , p_s_cutoff           => p_s_cutoff
					                            , p_include_po         => p_include_po
                                           , p_include_mo         => p_include_mo
					                            , p_vmi_enabled        => l_vmi_enabled
                                           , p_include_nonnet     => p_include_nonnet
                                           , p_include_wip        => p_include_wip
                                           , p_include_if         => p_include_if
                                             /* nsinghi MIN-MAX INVCONV start */
                                           , p_process_org        => item_rec.process_enabled
                                             /* nsinghi MIN-MAX INVCONV end */
                                           );

            l_demand_qty := get_demand_qty( p_org_id          => p_org_id
                                          , p_subinv          => p_subinv
                                          , p_level           => p_level
                                          , p_item_id         => item_rec.item_id
                                          , p_d_cutoff        => p_d_cutoff
                                          , p_include_nonnet  => p_include_nonnet
                                          , p_net_rsv         => p_net_rsv
                                          , p_net_unrsv       => p_net_unrsv
                                          , p_net_wip         => p_net_wip
                                             /* nsinghi MIN-MAX INVCONV start */
                                          , p_process_org     => item_rec.process_enabled
                                             /* nsinghi MIN-MAX INVCONV end */
                                          );

            l_tot_avail_qty := NVL(l_onhand_qty,0) + NVL(l_supply_qty,0) - NVL(l_demand_qty,0);

            IF G_TRACE_ON = 1 THEN
               print_debug('  Onhand: '     || to_char(l_onhand_qty)     ||
                           ', Supply: '     || to_char(l_supply_qty)     ||
                           ', Demand: '     || to_char(l_demand_qty)     ||
                           ', Available: '  || to_char(l_tot_avail_qty)
                           ,  l_proc_name
                           , 7);
            END IF;

            --
            -- Only need to display this item if:
            --  1. User chose "Items under min qty" and avail qty < min
            --  2. User chose "Items over max qty" and avail > max qty   or
            --  3. User chose "All min-max planned items"
            --
            IF (p_selection = 1 AND l_tot_avail_qty < NVL(item_rec.min_qty, 0))
               OR
               (p_selection = 2 AND l_tot_avail_qty > NVL(item_rec.max_qty, 0))
               OR
               (p_selection = 3)
            THEN
            --
            --
                l_item_segments := SUBSTR(item_rec.item,1,800);

                IF item_rec.category IS NOT NULL THEN
                    l_catg_disp := get_catg_disp(item_rec.category_id, p_mcat_struct);
                ELSE
                    l_catg_disp := NULL;
                END IF;

                IF p_sort = '3'
                THEN
                    l_sortee := substr(item_rec.planner,1,10);
                ELSIF p_sort = '4'
                THEN
                    l_sortee := substr(item_rec.buyer,1,10);
                ELSE
                    l_sortee := l_catg_disp;
                END IF;

                l_reord_qty := get_reord_qty( p_min_qty        =>  item_rec.min_qty
                                            , p_max_qty        =>  item_rec.max_qty
                                            , p_min_ord_qty    =>  item_rec.min_ord_qty
                                            , p_max_ord_qty    =>  item_rec.max_ord_qty
                                            , p_tot_avail_qty  =>  l_tot_avail_qty
                                            , p_fix_mult       =>  item_rec.fix_mult);

                l_stat := get_reord_stat( p_restock           =>  p_restock
                                        , p_handle_rep_item   =>  p_handle_rep_item
                                        , p_level             =>  p_level
                                        , p_reord_qty         =>  l_reord_qty
                                        , p_wip_batch_id      =>  p_wip_batch_id
                                        , p_org_id            =>  p_org_id
                                        , p_subinv            =>  p_subinv
                                        , p_user_id           =>  p_user_id
                                        , p_employee_id       =>  p_employee_id
                                        , p_sysdate           =>  p_sysdate
                                        , p_approval          =>  p_approval
                                        , p_encum_flag        =>  p_encum_flag
                                        , p_cust_id           =>  p_cust_id
                                        , p_cust_site_id      =>  p_cust_site_id
                                        , p_cal_code          =>  p_cal_code
                                        , p_exception_set_id  =>  p_exception_set_id
                                        , p_dd_loc_id         =>  p_dd_loc_id
                                        , p_po_org_id         =>  p_po_org_id
                                        , p_pur_revision      =>  p_pur_revision
                                        , p_item_rec          =>  item_rec
                                        , p_osfm_batch_id     =>  p_osfm_batch_id  /* Added for Bug 6807835 */
                                        );

                IF G_TRACE_ON = 1 THEN
                   print_debug('  Reord qty: '       || to_char(l_reord_qty) ||
                               ', Reorder status: '  || l_stat               ||
                               ', l_sortee: '        || l_sortee
                               ,  l_proc_name
                               , 7);
                END IF;

                --
                -- Insert into the global temp table INV_MIN_MAX_TEMP (defined
                -- in patch/115/sql/invmmxtb.sql).
                --
                -- Replenishment Move Order Consolidation
                -- only INSERT if the value of the new report parameter p_gen_report is 'Y'
                --
                --
                -- kkoothan Bug Fix:2748471
                -- Populated the value for the newly added column Subinventory_Code.
                --
                IF p_gen_report = 'Y' THEN
                     INSERT INTO INV_MIN_MAX_TEMP (
                                      ITEM_SEGMENTS
                                    , DESCRIPTION
                                    , ERROR
                                    , SORTEE
                                    , SUBINVENTORY_CODE
                                    , MIN_QTY
                                    , MAX_QTY
                                    , ONHAND_QTY
                                    , SUPPLY_QTY
                                    , DEMAND_QTY
                                    , TOT_AVAIL_QTY
                                    , MIN_ORD_QTY
                                    , MAX_ORD_QTY
                                    , FIX_MULT
                                    , REORD_QTY)
                             VALUES ( l_item_segments
                                    , item_rec.description
                                    , l_stat
                                    , l_sortee
                                    , p_subinv
                                    , item_rec.min_qty
                                    , item_rec.max_qty
                                    , l_onhand_qty
                                    , l_supply_qty
                                    , l_demand_qty
                                    , l_tot_avail_qty
                                    , item_rec.min_ord_qty
                                    , item_rec.max_ord_qty
                                    , item_rec.fix_mult
                                    , l_reord_qty);
                END IF;
            END IF;
        END LOOP;
        CLOSE c_items_to_plan;

        x_return_status := 'S';

    EXCEPTION
        WHEN OTHERS THEN
            IF c_items_to_plan%ISOPEN  THEN
                CLOSE c_items_to_plan;
            END IF;

            l_err_msg := sqlerrm;
            IF G_TRACE_ON = 1 THEN
            print_debug(sqlcode || ', ' || l_err_msg,  l_proc_name, 1);
            END IF;
            x_return_status := 'E';
            x_msg_data := l_err_msg;
    END run_min_max_plan;



    FUNCTION get_catg_disp (  p_category_id  NUMBER
                            , p_struct_id    NUMBER) RETURN VARCHAR2 IS

        CURSOR c_catg_disp IS
        SELECT concatenated_segments
          FROM mtl_categories_kfv
         WHERE category_id  = p_category_id
           AND structure_id = p_struct_id;

    c_catg_rec c_catg_disp%ROWTYPE;

    BEGIN
        OPEN c_catg_disp;
        FETCH c_catg_disp INTO c_catg_rec;
        CLOSE c_catg_disp;

        RETURN c_catg_rec.concatenated_segments;
    END get_catg_disp;



  FUNCTION get_onhand_qty( p_include_nonnet  NUMBER
			     , p_level           NUMBER
			     , p_org_id          NUMBER
			     , p_subinv          VARCHAR2
			     , p_item_id         NUMBER
              , p_sysdate         DATE) RETURN NUMBER IS


      --Bug# 2677358
      l_moq_qty1                NUMBER := 0;
      l_mmtt_qty1               NUMBER := 0;
      l_mmtt_qty2               NUMBER := 0;
      l_qoh                     NUMBER := 0;

    BEGIN

       IF g_trace_on = 1  THEN
	  print_debug('p_include_nonnet: ' || to_char(p_include_nonnet)   ||
		      ', p_level: '        || to_char(p_level)            ||
		      ', p_org_id: '       || to_char(p_org_id)           ||
		      ', p_subinv: '       || p_subinv                    ||
		      ', p_item_id: '      || to_char(p_item_id)          ||
		      ', p_sysdate: '      || to_char(p_sysdate, 'DD-MON-YYYY HH24:MI:SS')
		      , 'get_onhand_qty'
		      , 9);
       END IF;


       --distinction at Org/sub level is made in this API
       l_qoh := INV_CONSIGNED_VALIDATIONS.get_planning_quantity
	 (p_include_nonnet  => p_include_nonnet
	  , P_LEVEL         => p_level
	  , P_ORG_ID        => p_org_id
	  , P_SUBINV        => p_subinv
	  , P_ITEM_ID       => p_item_id
	  );


       IF g_trace_on = 1  THEN
	  print_debug('Total quantity on-hand: ' || to_char(l_qoh), 'get_onhand_qty', 9);
       END IF;

       return (l_qoh);

    EXCEPTION
       WHEN OTHERS THEN
          IF G_TRACE_ON = 1 THEN
             print_debug(sqlcode || ', ' || sqlerrm, 'get_onhand_qty', 1);
          END IF;
          RAISE;
    END get_onhand_qty;



    FUNCTION get_supply_qty( p_org_id              NUMBER
                           , p_subinv              VARCHAR2
                           , p_item_id             NUMBER
                           , p_postproc_lead_time  NUMBER
                           , p_cal_code            VARCHAR2
                           , p_except_id           NUMBER
                           , p_level               NUMBER
                           , p_s_cutoff            DATE
			                  , p_include_po          NUMBER
                           , p_include_mo          NUMBER
			                  , p_vmi_enabled         VARCHAR2
                           , p_include_nonnet      NUMBER
                           , p_include_wip         NUMBER
                           , p_include_if          NUMBER
                           /* nsinghi MIN-MAX INVCONV start */
                           , p_process_org         VARCHAR2
                           /* nsinghi MIN-MAX INVCONV end */
                           ) RETURN NUMBER IS

        l_qty          NUMBER;
        l_total        NUMBER;
        l_puom         VARCHAR2(3); --Bug3894347

   -- Bug 3005403 Min-Max was not showing correct supply quantity for some
   -- supply records. Modified the query to consider receipt_date for
   -- records with supply type code 'SHIPMENT' and 'RECEIVING'

        l_stmt         VARCHAR2(4000) :=
            ' SELECT NVL(sum(to_org_primary_quantity), 0)
                FROM mtl_supply         sup
                   , bom_calendar_dates c
                   , bom_calendar_dates c1
               WHERE sup.supply_type_code IN (''PO'',''REQ'',''SHIPMENT'',''RECEIVING'')
                 AND sup.destination_type_code  = ''INVENTORY''
                 AND sup.to_organization_id     = :l_org_id
                 AND sup.item_id                = :l_item_id
                 AND c.calendar_code            = :l_cal_code
                 AND c.exception_set_id         = :l_except_id
                 AND c.calendar_date            = trunc(decode(sup.supply_type_code, ''SHIPMENT'', sup.receipt_date, ''RECEIVING'', sup.receipt_date,nvl(sup.need_by_date, sup.receipt_date)))
                 AND c1.calendar_code           = c.calendar_code
                 AND c1.exception_set_id        = c.exception_set_id
                 AND c1.seq_num                 = (c.next_seq_num + trunc(:l_postproc_lead_time))
                 AND c1.calendar_date   <= :l_s_cutoff + 0.99999  /* bug no 6009682 */
                 AND (NVL(sup.from_organization_id,-1) <> :l_org_id
                      OR (sup.from_organization_id      = :l_org_id
                          AND ((:l_include_nonnet       = 2
                                AND
                                EXISTS (SELECT ''x''
                                          FROM mtl_secondary_inventories sub1
                                         WHERE sub1.organization_id          = sup.from_organization_id
                                           AND sub1.secondary_inventory_name = sup.from_subinventory
                                           AND sub1.availability_type       <> 1
                                       )
                               )
                               OR :l_level = 2
                              )
                         )
                     )
                 AND (sup.to_subinventory IS NULL
                      OR
                      (EXISTS (SELECT ''x''
                                 FROM mtl_secondary_inventories sub2
                                WHERE sub2.secondary_inventory_name = sup.to_subinventory
                                  AND sub2.organization_id          = sup.to_organization_id
                                  AND sub2.availability_type        = decode(:l_include_nonnet,
                                                                             1,sub2.availability_type,
                                                                             1)
                              )
                      )
                      OR :l_level = 2
                     )
                 AND (:l_level = 1 OR to_subinventory = :l_subinv)
-- Bug 5041763 Not considering supply from drop ship orders
                    AND NOT EXISTS (SELECT ''X'' FROM OE_DROP_SHIP_SOURCES ODSS
                            WHERE   DECODE(sup.PO_HEADER_ID, NULL, sup.REQ_LINE_ID, sup.PO_LINE_LOCATION_ID) =
                                    DECODE(sup.PO_HEADER_ID,NULL, ODSS.REQUISITION_LINE_ID, ODSS.LINE_LOCATION_ID)) ';



      l_vmi_stmt     VARCHAR2(2000) :=
            ' AND (sup.po_line_location_id IS NULL
                   OR EXISTS (SELECT ''x''
                                FROM po_line_locations_all lilo
                               WHERE lilo.line_location_id    = sup.po_line_location_id
                                 AND NVL(lilo.vmi_flag,''N'') = ''N''
                             )
                  )
              AND (sup.req_line_id IS NULL
                   OR EXISTS (SELECT ''x''
                                FROM po_requisition_lines_all prl
                               WHERE prl.requisition_line_id = sup.req_line_id
                                 AND NVL(prl.vmi_flag,''N'') = ''N''
                             )
                  )';


        TYPE c_po_sup_curtype IS REF CURSOR;
        c_po_qty c_po_sup_curtype;

    BEGIN
        IF G_TRACE_ON = 1 THEN
            print_debug('sbitrap_org_id: '               || to_char(p_org_id)         ||
                        ', p_subinv: '             || p_subinv                  ||
                        ', p_item_id: '            || to_char(p_item_id)        ||
                        ', p_postproc_lead_time: ' || to_char(p_postproc_lead_time) ||
                        ', p_cal_code: '           || p_cal_code                ||
                        ', p_except_id: '          || to_char(p_except_id)      ||
                        ', p_level: '              || to_char(p_level)          ||
                        ', p_s_cutoff: '           || to_char(p_s_cutoff, 'DD-MON-YYYY HH24:MI:SS') ||
                        ', p_include_po: '         || to_char(p_include_po)     ||
                        ', p_include_mo: '         || to_char(p_include_mo)     ||
                        ', p_include_nonnet: '     || to_char(p_include_nonnet) ||
                        ', p_include_wip: '        || to_char(p_include_wip)    ||
                        ', p_include_if: '         || to_char(p_include_if)
                        , 'get_supply_qty'
                        , 9);
        END IF;

        l_total := 0;

        --
        -- MTL_SUPPLY
        --
        IF p_include_po = 1 THEN
	   IF (p_vmi_enabled = 'Y') and (p_level= 1) then
	      OPEN c_po_qty FOR l_stmt || l_vmi_stmt
		USING
                p_org_id, p_item_id, p_cal_code, p_except_id, p_postproc_lead_time,
                p_s_cutoff, p_org_id, p_org_id, p_include_nonnet,
                p_level, p_include_nonnet, p_level, p_level, p_subinv;
	    else
	      OPEN c_po_qty FOR l_stmt
		USING
                p_org_id, p_item_id, p_cal_code, p_except_id, p_postproc_lead_time,
                p_s_cutoff, p_org_id, p_org_id, p_include_nonnet,
                p_level, p_include_nonnet, p_level, p_level, p_subinv;
	   END IF;

            FETCH c_po_qty INTO l_qty;
            CLOSE c_po_qty;
            IF G_TRACE_ON = 1 THEN
            print_debug('Supply from mtl_supply: ' || to_char(l_qty)
                        , 'get_supply_qty'
                        , 9);
            END IF;

            l_total := l_total + l_qty;

        END IF;
        --
        -- Take into account the quantity for which a move order
        -- has already been created assuming that the move order
        -- can be created only within the same org
        -- Bug 3057273, Added new parameter p_include_mo check.

        IF (p_level = 2 and p_include_mo = 1) THEN
          -- kkoothan Part of Bug Fix: 2875583
          -- Converting the quantities to the primary uom as the quantity
          -- and quantity delivered in mtl_txn_request_lines
          -- are in transaction uom.

          /* SELECT NVL(sum(mtrl.quantity - NVL(mtrl.quantity_delivered,0)),0)
              INTO l_qty
              FROM mtl_transaction_types  mtt,
                   mtl_txn_request_lines  mtrl
             WHERE mtt.transaction_action_id IN (2,28)
               AND mtt.transaction_type_id   = mtrl.transaction_type_id
               AND mtrl.organization_id      = p_org_id
               AND mtrl.inventory_item_id    = p_item_id
               AND mtrl.to_subinventory_code = p_subinv
               AND mtrl.line_status NOT IN (5,6)
               AND mtrl.date_required       <= p_s_cutoff;*/

           /*4518296*/
            SELECT NVL(SUM(inv_decimals_pub.get_primary_quantity( p_org_id
                                                             ,p_item_id
                                                             , mtrl.uom_code
                                                             , mtrl.quantity - NVL(mtrl.quantity_delivered,0))
                                                             ),0)
            INTO l_qty
            FROM mtl_transaction_types  mtt,
                 mtl_txn_request_lines  mtrl
            WHERE mtt.transaction_action_id IN (2,28)
                AND mtt.transaction_type_id   = mtrl.transaction_type_id
                AND mtrl.organization_id      = p_org_id
                AND mtrl.inventory_item_id    = p_item_id
                AND mtrl.to_subinventory_code = p_subinv
                AND mtrl.line_status IN (3,7) --Changed for Bug 5330189: 3 = Approved 7 = Pre-Approved
                AND mtrl.date_required      <= p_s_cutoff + 0.99999;    /* bug no 6009682 */

            IF G_TRACE_ON = 1 THEN
            print_debug('Supply from move orders: ' || to_char(l_qty)
                        , 'get_supply_qty'
                        , 9);
            END IF;
            l_total := l_total + l_qty;
        END IF;

        --
        -- Supply FROM WIP discrete job is to be included at Org Level Planning Only
        --
        IF p_level = 1 AND p_include_wip = 1
        THEN

/* nsinghi MIN-MAX INVCONV start */

/* Here check will need to be made if the org is Process org or Discrete org. */

           IF p_process_org = 'Y' THEN
              SELECT
                 SUM ( NVL((NVL(d.wip_plan_qty, d.plan_qty) - d.actual_qty), 0) *
                     (original_primary_qty/original_qty))
              INTO l_qty
              FROM   gme_material_details d
               ,      gme_batch_header     h
               WHERE  h.batch_type IN (0,10)
               AND    h.batch_status IN (1,2)
               AND    h.batch_id = d.batch_id
               AND    d.inventory_item_id = p_item_id
               AND    d.organization_id = p_org_id
               AND    NVL(d.original_qty, 0) <> 0
               AND    d.material_requirement_date <= p_s_cutoff
               AND    d.line_type > 0;

              IF G_TRACE_ON = 1 THEN
              print_debug('Supply from OPM Batches : ' || to_char(l_qty)
                          , 'get_supply_qty'
                          , 9);
              END IF;
              l_total := l_total + NVL(l_qty,0);

           ELSE
/* nsinghi MIN-MAX INVCONV end */

              SELECT sum(NVL(start_quantity,0)
                         - NVL(quantity_completed,0)
                         - NVL(quantity_scrapped,0))
                INTO l_qty
                FROM wip_discrete_jobs
               WHERE organization_id = p_org_id
                 AND primary_item_id = p_item_id
                 AND job_type in (1,3)
                 AND status_type IN (1,3,4,6)
                 --Bug 2647862
                 AND scheduled_completion_date <= p_s_cutoff + 0.99999 /* bug no 6009682 */
                 AND (NVL(start_quantity,0) - NVL(quantity_completed,0)
                                            - NVL(quantity_scrapped,0)) > 0;

              IF G_TRACE_ON = 1 THEN
              print_debug('Supply from WIP discrete jobs: ' || to_char(l_qty)
                          , 'get_supply_qty'
                          , 9);
              END IF;
              l_total := l_total + NVL(l_qty,0);

              --
              -- WIP REPETITIVE JOBS to be included at Org Level Planning Only
              --
              SELECT SUM(daily_production_rate *
                         GREATEST(0, LEAST(processing_work_days,
                                           p_s_cutoff - first_unit_completion_date
                                          )
                                 )
                         - quantity_completed)
                INTO l_qty
                FROM wip_repetitive_schedules wrs,
                     wip_repetitive_items wri
               WHERE wrs.organization_id = p_org_id
                 AND wrs.status_type IN (1,3,4,6)
                 AND wri.organization_id = p_org_id
                 AND wri.primary_item_id = p_item_id
                 AND wri.wip_entity_id   = wrs.wip_entity_id
                 AND wri.line_id         = wrs.line_id
                 AND (daily_production_rate *
                      GREATEST(0, LEAST(processing_work_days,
                                        p_s_cutoff - first_unit_completion_date
                                       )
                              )
                      - quantity_completed) > 0;

              IF G_TRACE_ON = 1 THEN
                 print_debug('Supply from WIP repetitive schedules: ' || to_char(l_qty)
                             , 'get_supply_qty'
                             , 9);
              END IF;

              l_total := l_total + NVL(l_qty,0);

           END IF; /* p_process_org = 'Y' */

        END IF;

        IF (p_include_if = 2)
        THEN
            RETURN(l_total);
        END IF;

        --
        -- po_requisitions_interface_all
        --
        -- Bug: 2320752
        -- Do not include records in error status
        -- kkoothan Bug Fix 2891818
        -- Used NVL function for the condition involving process_flag
        -- so that the interface records with NULL value for process_flag
        -- are considered as Interface Supply.
        --
        /* Bug 3894347 -- Added the following section of code to consider conversion
           of quantities in po_requisitions_interface_all if uom_code is different than
           primary uom code */

        SELECT uom_code
          INTO l_puom
        FROM mtl_system_items_vl msiv , mtl_units_of_measure_vl muom
        WHERE msiv.inventory_item_id = p_item_id
          AND msiv.organization_id = p_org_id
          AND muom.unit_of_measure = msiv.primary_unit_of_measure;

        --Bug9122329, calling the function get_item_uom_code in case when uom_code is null
        --in the po_requisitions_interface_all table.

        SELECT NVL(SUM(DECODE(NVL(uom_code,get_item_uom_code(unit_of_measure)),
                                l_puom,quantity,
                                INV_CONVERT.INV_UM_CONVERT(p_item_id,null,quantity,NVL(uom_code,get_item_uom_code(unit_of_measure)),l_puom,null,null)
                              )),0)
          INTO l_qty
          FROM po_requisitions_interface_all
         WHERE destination_organization_id = p_org_id
           AND item_id                     = p_item_id
           AND p_include_po                = 1
           AND (p_level = 1 or destination_subinventory = p_subinv)
           AND need_by_date               <= (trunc(p_s_cutoff) + 1 - (1/(24*60*60)))
           AND NVL(process_flag,'@@@') <> 'ERROR'
           AND (NVL(source_organization_id,-1) <> p_org_id OR
                (source_organization_id         = p_org_id AND
                 (( p_include_nonnet            = 2 AND
                   EXISTS (SELECT 'x'
                             FROM mtl_secondary_inventories sub1
                            WHERE sub1.organization_id          = source_organization_id
                              AND sub1.secondary_inventory_name = source_subinventory
                              AND sub1.availability_type       <> 1)) OR
                 p_level = 2)
               ))
           AND (destination_subinventory IS NULL OR
                EXISTS (SELECT 1
                          FROM mtl_secondary_inventories sub2
                         WHERE secondary_inventory_name = destination_subinventory
                           AND destination_subinventory = NVL(p_subinv,
                                                          destination_subinventory)
                           AND sub2.organization_id     = p_org_id
                           AND sub2.availability_type   = decode(p_include_nonnet,
                                                                 1,sub2.availability_type,1)) OR
                p_level = 2);

        IF G_TRACE_ON = 1 THEN
        print_debug('Supply from po_requisitions_interface_all: ' || to_char(l_qty)
                    , 'get_supply_qty'
                    , 9);
        END IF;
        l_total := l_total + NVL(l_qty,0);

        --
        -- WIP_JOB_SCHEDULE_INTERFACE, processed immediately, hence not included
        --
        -- Supply FROM Flow to be included in org level only
        --
        IF p_level = 1
        THEN
            SELECT SUM(NVL(planned_quantity,0)
                       - NVL(quantity_completed,0))
              INTO l_qty
              FROM wip_flow_schedules
             WHERE organization_id = p_org_id
               AND primary_item_id = p_item_id
               AND status          = 1
               AND scheduled_flag  = 1   -- Bug 3151797
                     --Bug 2647862
               AND scheduled_completion_date <= p_s_cutoff + 0.99999 /* bug no 6009682 */
               AND (NVL(planned_quantity,0)
                    - NVL(quantity_completed,0)) > 0;

            IF G_TRACE_ON = 1 THEN
            print_debug('Supply from WIP flow schedules: ' || to_char(l_qty)
                        , 'get_supply_qty'
                        , 9);
            END IF;
            l_total := l_total + NVL(l_qty,0);
        END IF;

        RETURN(l_total);

    EXCEPTION
        WHEN others THEN
            IF c_po_qty%ISOPEN  THEN
               CLOSE c_po_qty;
            END IF;
            IF G_TRACE_ON = 1 THEN
            print_debug(sqlcode || ', ' || sqlerrm, 'get_supply_qty', 1);
            END IF;
            RAISE;
    END get_supply_qty;



    FUNCTION get_demand_qty( p_org_id          NUMBER
                           , p_subinv          VARCHAR2
                           , p_level           NUMBER
                           , p_item_id         NUMBER
                           , p_d_cutoff        DATE
                           , p_include_nonnet  NUMBER
                           , p_net_rsv         NUMBER
                           , p_net_unrsv       NUMBER
                           , p_net_wip         NUMBER
                           /* nsinghi MIN-MAX INVCONV start */
                           , p_process_org     VARCHAR2
                           /* nsinghi MIN-MAX INVCONV end */
                           ) RETURN NUMBER IS

        qty                  NUMBER := 0;
        total                NUMBER := 0;
        l_total_demand_qty   NUMBER := 0;
        l_demand_qty         NUMBER := 0;
        l_total_reserve_qty  NUMBER := 0;
        l_pick_released_qty  NUMBER := 0;
        l_staged_qty         NUMBER := 0;
        l_sub_reserve_qty    NUMBER := 0;
        l_allocated_qty      NUMBER := 0;
	l_loaded_qty	     NUMBER := 0; /*Bug 6240025 */

    BEGIN
        IF G_TRACE_ON = 1 THEN
            print_debug('p_org_id: '           || to_char(p_org_id)         ||
                        ', p_subinv: '         || p_subinv                  ||
                        ', p_level: '          || to_char(p_level)          ||
                        ', p_item_id: '        || to_char(p_item_id)        ||
                        ', p_d_cutoff: '       || to_char(p_d_cutoff, 'DD-MON-YYYY HH24:MI:SS') ||
                        ', p_include_nonnet: ' || to_char(p_include_nonnet) ||
                        ', p_net_rsv: '        || to_char(p_net_rsv)        ||
                        ', p_net_unrsv: '      || to_char(p_net_unrsv)      ||
                        ', p_net_wip: '        || to_char(p_net_wip)
                        , 'get_demand_qty'
                        , 9);
        END IF;

        --
        -- select unreserved qty from mtl_demand for non oe rows.
        --
        IF p_net_unrsv = 1 THEN
           /*4518296*/
            select sum(PRIMARY_UOM_QUANTITY - GREATEST(NVL(RESERVATION_QUANTITY,0),
                                              NVL(COMPLETED_QUANTITY,0)))
              into qty
              from mtl_demand
             WHERE RESERVATION_TYPE     = 1
               AND parent_demand_id    IS NULL
               AND ORGANIZATION_ID      = p_org_id
               and PRIMARY_UOM_QUANTITY > GREATEST(NVL(RESERVATION_QUANTITY,0),
                                                   NVL(COMPLETED_QUANTITY,0))
               and INVENTORY_ITEM_ID    = p_item_id
               and REQUIREMENT_DATE      <= p_d_cutoff + 0.99999 /* bug no 6009682 */
               and demand_source_type not in (2,8,12)
               and (p_level      = 1 or
                    SUBINVENTORY = p_subinv)   -- Included later for ORG Level
               and (SUBINVENTORY is null or
                    p_level = 2 or
                    EXISTS (SELECT 1
                              FROM MTL_SECONDARY_INVENTORIES S
                             WHERE S.ORGANIZATION_ID          = p_org_id
                               AND S.SECONDARY_INVENTORY_NAME = SUBINVENTORY
                               AND S.availability_type        = DECODE(p_include_nonnet,
                                                                       1,
                                                                       S.availability_type,
                                                                       1)))
/* nsinghi MIN-MAX INVCONV start */
               AND (locator_id IS NULL OR
                    p_level = 2 OR
                     EXISTS (SELECT 1 FROM mtl_item_locations mil
                            WHERE mil.organization_id = p_org_id
                            AND   mil.inventory_location_id = locator_id
                            AND   mil.subinventory_code = NVL(subinventory, mil.subinventory_code)
                            AND   mil.availability_type = decode(p_include_nonnet,1,mil.availability_type,1)))
               AND (lot_number IS NULL OR
                    p_level = 2 OR
                     EXISTS (SELECT 1 FROM mtl_lot_numbers mln
                            WHERE mln.organization_id = p_org_id
                            AND   mln.lot_number = lot_number
                            AND   mln.inventory_item_id = p_item_id
                            AND   mln.availability_type = decode(p_include_nonnet,1,mln.availability_type,1)));
/* nsinghi MIN-MAX INVCONV end */

            IF G_TRACE_ON = 1 THEN
            print_debug('Demand from mtl_demand: ' || to_char(qty), 'get_demand_qty', 9);
            END IF;
            total := total + NVL(qty,0);
        END IF;

        --
        -- select the reserved quantity from mtl_reservations for non OE rows
        --
        IF p_net_rsv = 1 THEN
            select sum(PRIMARY_RESERVATION_QUANTITY)
              into qty
              from mtl_reservations
             where ORGANIZATION_ID = p_org_id
               and INVENTORY_ITEM_ID = p_item_id
               and REQUIREMENT_DATE <= p_d_cutoff + 0.99999 /* bug no 6009682 */
               and demand_source_type_id not in (2,8,12)
               and (p_level = 1  or
                    SUBINVENTORY_CODE = p_subinv) -- Included later for ORG Level
               and (SUBINVENTORY_CODE is null or
                    p_level = 2 or
                    EXISTS (SELECT 1
                              FROM MTL_SECONDARY_INVENTORIES S
                             WHERE S.ORGANIZATION_ID = p_org_id
                               AND S.SECONDARY_INVENTORY_NAME = SUBINVENTORY_CODE
                               AND S.availability_type = DECODE(p_include_nonnet,
                                                                1,
                                                                S.availability_type,
                                                                1)))
/* nsinghi MIN-MAX INVCONV start */
               AND (locator_id IS NULL OR
                    p_level = 2 OR
                     EXISTS (SELECT 1 FROM mtl_item_locations mil
                            WHERE mil.organization_id = p_org_id
                            AND   mil.inventory_location_id = locator_id
                            AND   mil.subinventory_code = NVL(subinventory_code, mil.subinventory_code)
                            AND   mil.availability_type = decode(p_include_nonnet,1,mil.availability_type,1)))
               AND (lot_number IS NULL OR
                    p_level = 2 OR
                     EXISTS (SELECT 1 FROM mtl_lot_numbers mln
                            WHERE mln.organization_id = p_org_id
                            AND   mln.lot_number = lot_number
                            AND   mln.inventory_item_id = p_item_id
                            AND   mln.availability_type = decode(p_include_nonnet,1,mln.availability_type,1)));
/* nsinghi MIN-MAX INVCONV end */

            IF G_TRACE_ON = 1 THEN
            print_debug('Demand (reserved qty) for non OE rows in mtl_reservations: ' || to_char(qty)
                        , 'get_demand_qty'
                        , 9);
            END IF;
            total := total + NVL(qty,0);
        END IF;

        --
        -- get the total demand which is the difference between the
        -- ordered qty. and the shipped qty.
        -- This gives the total demand including the reserved
        -- and the unreserved material.
        --
        -- Bug 2333526: For sub level planning we need to compute
        -- the staged qty.  The existing WHERE clause makes sure
        -- we only do this when the order is sourced from the
        -- planning sub: level = 1... or SUBINVENTORY = p_subinv
        --
        -- Bug 2350243: For sub level, calculate pick released
        -- (move order) qty
        --

        -- Bug 3480523, from patch I onwards schedule_ship_date is being populated
        -- with time component, hence truncating it to get the same day demand. These
        -- changes are also in mtl_reservation queries.
        if p_net_unrsv = 1 then
            select SUM(inv_decimals_pub.get_primary_quantity( ship_from_org_id
                                                            , inventory_item_id
                                                            , order_quantity_uom
                                                            , NVL(ordered_quantity,0)) -
                       get_shipped_qty(p_org_id, p_item_id, ool.line_id)),
                   SUM(DECODE(p_level,
                              2, get_staged_qty( p_org_id
                                               , p_subinv
                                               , p_item_id
                                               , ool.line_id
                                               , p_include_nonnet),
                              0)
                      ),
                   SUM(DECODE(p_level,
                              2, get_pick_released_qty( p_org_id
                                                      , p_subinv
                                                      , p_item_id
                                                      , ool.line_id),
                              0)
                      )
              into l_total_demand_qty, l_staged_qty, l_pick_released_qty
              from oe_order_lines_all ool
             where ship_from_org_id = p_org_id
               and open_flag = 'Y'
               AND visible_demand_flag = 'Y'
               AND shipped_quantity is null
               and INVENTORY_ITEM_ID = p_item_id
               and schedule_ship_date <= p_d_cutoff + 0.99999 /* bug no 6009682 */
               AND DECODE( OOL.SOURCE_DOCUMENT_TYPE_ID
                         , 10, 8
                         , DECODE(OOL.LINE_CATEGORY_CODE, 'ORDER',2,12)) IN (2,8,12)
               and ((p_level = 1
                      AND DECODE( OOL.SOURCE_DOCUMENT_TYPE_ID
                               , 10, 8
                               , DECODE(OOL.LINE_CATEGORY_CODE, 'ORDER',2,12)) <> 8)
                    OR SUBINVENTORY = p_subinv)  -- Included later for ORG Level
               and (SUBINVENTORY is null or
                        p_level = 2 or
                    EXISTS (SELECT 1
                              FROM MTL_SECONDARY_INVENTORIES S
                             WHERE S.ORGANIZATION_ID = p_org_id
                               AND S.SECONDARY_INVENTORY_NAME = SUBINVENTORY
                               AND S.availability_type = DECODE(p_include_nonnet,
                                                                1,
                                                                S.availability_type,
                                                                1)));
            IF G_TRACE_ON = 1 THEN
            print_debug('Demand from sales orders: ' ||
                        ' Ordered: '        || to_char(l_total_demand_qty)  ||
                        ', Pick released: ' || to_char(l_pick_released_qty) ||
                        ', Staged: '        || to_char(l_staged_qty)
                        , 'get_demand_qty'
                        , 9);
            END IF;
        end if;

        --
        -- Find out the reserved qty for the material from mtl_reservations
        --
        -- Since total demand = reserved + unreserved, and we know total
        -- demand from oe_order_lines_all (above) we only need to query
        -- mtl_reservations if the user wants one of the following:
        --
        --  1) Only reserved: (p_net_rsv = 1 and p_net_unrsv = 2)
        --
        --  OR
        --
        --  2) Only unreserved: (p_net_rsv = 2 and p_net_unrsv = 1)
        --

        IF ((p_net_rsv = 1 and p_net_unrsv = 2)
            OR
            (p_net_rsv = 2 and p_net_unrsv = 1))
        THEN
            select sum(PRIMARY_RESERVATION_QUANTITY)
              into l_total_reserve_qty
              from mtl_reservations
             WHERE ORGANIZATION_ID = p_org_id
               and INVENTORY_ITEM_ID = p_item_id
               and REQUIREMENT_DATE <= p_d_cutoff + 0.99999 /* bug no 6009682 */
               and demand_source_type_id in (2,8,12)
               and ((p_level = 1 AND demand_source_type_id <> 8) OR
                     SUBINVENTORY_CODE = p_subinv)  -- Included later for ORG Level
               and (SUBINVENTORY_CODE is null or
                    p_level = 2 or
                    EXISTS (SELECT 1
                              FROM MTL_SECONDARY_INVENTORIES S
                             WHERE S.ORGANIZATION_ID = p_org_id
                               AND S.SECONDARY_INVENTORY_NAME = SUBINVENTORY_CODE
                               AND S.availability_type = DECODE(p_include_nonnet,
                                                                1,
                                                                S.availability_type,
                                                                1)))
/* nsinghi MIN-MAX INVCONV start */
               AND (locator_id IS NULL OR
                    p_level = 2 OR
                     EXISTS (SELECT 1 FROM mtl_item_locations mil
                            WHERE mil.organization_id = p_org_id
                            AND   mil.inventory_location_id = locator_id
                            AND   mil.subinventory_code = NVL(subinventory_code, mil.subinventory_code)
                            AND   mil.availability_type = decode(p_include_nonnet,1,mil.availability_type,1)))
               AND (lot_number IS NULL OR
                    p_level = 2 OR
                     EXISTS (SELECT 1 FROM mtl_lot_numbers mln
                            WHERE mln.organization_id = p_org_id
                            AND   mln.lot_number = lot_number
                            AND   mln.inventory_item_id = p_item_id
                            AND   mln.availability_type = decode(p_include_nonnet,1,mln.availability_type,1)))
              -- Bug 5041763 excluding drop ship demand
                  and  NOT EXISTS (SELECT 1
                                    FROM OE_DROP_SHIP_SOURCES ODSS
                                  WHERE  ODSS.LINE_ID = DEMAND_SOURCE_LINE_ID);

/* nsinghi MIN-MAX INVCONV end */

           IF G_TRACE_ON = 1 THEN
           print_debug('Reserved demand (sales orders): ' || to_char(l_total_reserve_qty)
                       , 'get_demand_qty'
                       , 9);
           END IF;
        END IF;


        --
        -- Bug 3238390, we need to take care of reservations with sub but sales order
        -- with no sub for sub level planning. Adding the below query
        --
        IF (p_level = 2 and (p_net_rsv = 1 or p_net_unrsv = 1)) THEN

                select sum(mr.PRIMARY_RESERVATION_QUANTITY) into l_sub_reserve_qty
                from mtl_reservations mr, oe_order_lines_all ool
                where mr.organization_id        = p_org_id
                AND   mr.inventory_item_id      = p_item_id
                AND   mr.demand_source_line_id  = ool.line_id
                AND   mr.demand_source_type_id in (2,8,12)
                AND   ool.subinventory is NULL
                AND   ool.open_flag = 'Y'
                AND   ool.visible_demand_flag = 'Y'
                AND   ool.shipped_quantity is null
                AND   mr.REQUIREMENT_DATE <= p_d_cutoff + 0.99999 /* bug no 6009682 */
                AND   mr.subinventory_code IS NOT NULL
                AND   mr.subinventory_code     = p_subinv;

         print_debug('Reserved demand (sales orders with no sub and reservations with sub): ' || to_char(l_sub_reserve_qty)
                       , 'get_demand_qty'
                       , 9);

         END IF;

         IF (p_level = 2 and p_net_rsv = 1) THEN

           BEGIN

            SELECT NVL(SUM(primary_quantity),0)
              INTO l_allocated_qty
              FROM mtl_material_transactions_temp mmtt
             WHERE inventory_item_id          = p_item_id
               AND organization_id            = p_org_id
               AND subinventory_code          = p_subinv
               AND transfer_subinventory     <> p_subinv
               AND NVL(transaction_status, 1) = 2
               AND transaction_source_type_id in (2,8)
               AND not exists (SELECT 1 from mtl_reservations
                                WHERE reservation_id = mmtt.reservation_id
                                  AND nvl(subinventory_code, '@@@') = p_subinv)
               AND exists (SELECT 1 from mtl_txn_request_lines
                            WHERE line_id = mmtt.move_order_line_id
                              AND from_subinventory_code is null
                              AND line_status NOT IN (5,6)
                              AND date_required <= p_d_cutoff + 0.99999); /* bug no 6009682 */

            EXCEPTION
                WHEN OTHERS THEN
                   l_allocated_qty  := 0;
            END;
          END IF;

         print_debug('Allocated demand for subinventory: ' || to_char(l_allocated_qty)
                       , 'get_demand_qty'
                       , 9);

        --
        -- total demand is calculated as follows:
        -- if we have to consider both unreserved matl and reserved matl. then the
        --    demand is simply the total demand = ordered qty - shipped qty.
        --    Bug 2333526: Deduct staged qty for sub level.  (l_staged_qty
        --    is always set to 0 for org level planning).
        --    Bug 3238390, add reserved qty for sales orders with no sub
        --    and reservation with sub for sub level planning.
        -- elsif we have to take into account only reserved matl. then the
        --    demand is simply the reservations from mtl_reservations for the matl.
        -- elsif we have to take into account just the unreserved matl. then the
        --    demand is total demand - the reservations for the material.
        --    Bug 3238390, add reserved qty for sales orders with no sub
        --    and reservation with sub for sub level planning, so that demand doesn't go -ve.
        IF p_net_unrsv = 1 AND p_net_rsv = 1 THEN
           l_demand_qty := NVL(l_total_demand_qty,0)
                           - NVL(l_staged_qty,0)
                           - NVL(l_pick_released_qty,0)
                           + NVL(l_sub_reserve_qty,0)
                           + NVL(l_allocated_qty,0);

        ELSIF p_net_rsv = 1 THEN
           l_demand_qty := NVL(l_total_reserve_qty,0) + NVL(l_allocated_qty,0);

        ELSIF p_net_unrsv = 1 THEN
           l_demand_qty := NVL(l_total_demand_qty,0) - NVL(l_total_reserve_qty,0) + NVL(l_sub_reserve_qty,0);

        END IF;
        IF G_TRACE_ON = 1 THEN
        print_debug('Demand from shippable orders: ' || to_char(l_demand_qty)
                    , 'get_demand_qty'
                    , 9);
        END IF;
        total := total + NVL(l_demand_qty,0);

        --
        -- Take care of internal orders for org level planning
        --
        if p_level = 1 then
            l_total_demand_qty := 0;
            l_demand_qty := 0;
            l_total_reserve_qty := 0;

            --
            -- get the total demand which is the difference between the
            -- ordered qty. and the shipped qty.
            -- This gives the total demand including the reserved
            -- and the unreserved material.
            --
  -- Bug 2820011. Modified the where clause to make use of source_document_id
  -- and source_document_line_id of oe_order_lines_all instead of
  -- orig_sys_document_ref and orig_sys_line_ref to identify requisitions
  -- and requisition lines uniquely.

            if p_net_unrsv = 1 then
                select SUM(INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY( SHIP_FROM_ORG_ID
                                                                , INVENTORY_ITEM_ID
                                                                , ORDER_QUANTITY_UOM
                                                                , NVL(ordered_quantity,0)) -
                           get_shipped_qty(p_org_id, p_item_id, so.line_id))
                  into l_total_demand_qty
                  from oe_order_lines_all so,
--                     po_requisition_headers_all poh,
                       po_requisition_lines_all pol
                 where so.SOURCE_DOCUMENT_ID  = pol.requisition_header_id
--                 and poh.requisition_header_id = pol.requisition_header_id
                   and so.source_document_line_id = pol.requisition_line_id
                   and (pol.DESTINATION_ORGANIZATION_ID <> p_org_id or
                        (pol.DESTINATION_ORGANIZATION_ID = p_org_id and  -- Added code Bug#1012179
                          ( pol.DESTINATION_TYPE_CODE = 'EXPENSE' OR  --Bug#3619239 started
-- Bug 3619239 The functionality is added so that demand from Internal Sales Requisitions are taken
-- into consideration if Destination Type is Inventory and Destination Subinventory is Non Quantity Tracked
			   (  pol.DESTINATION_TYPE_CODE = 'INVENTORY'
			      AND pol.DESTINATION_SUBINVENTORY IS NOT NULL
			      AND EXISTS (select 1 from
			                  MTL_SECONDARY_INVENTORIES
                                          where SECONDARY_INVENTORY_NAME = pol.DESTINATION_SUBINVENTORY
                                          and ORGANIZATION_ID = pol.DESTINATION_ORGANIZATION_ID
                                          and QUANTITY_TRACKED = 2)
			    )
			   )-- Bug#3619239 ended
			  )
                        )
                   and so.ship_from_org_ID = p_org_id
                   and so.open_flag = 'Y'
                   AND so.visible_demand_flag = 'Y'
                   AND shipped_quantity is null
                   and so.INVENTORY_ITEM_ID = p_item_id
                   and schedule_ship_date <= p_d_cutoff + 0.99999 /* bug no 6009682 */
                   and DECODE(so.SOURCE_DOCUMENT_TYPE_ID, 10, 8,DECODE(so.LINE_CATEGORY_CODE, 'ORDER',2,12)) = 8
                   and (SUBINVENTORY is null or
                        EXISTS (SELECT 1
                                  FROM MTL_SECONDARY_INVENTORIES S
                                 WHERE S.ORGANIZATION_ID = p_org_id
                                   AND S.SECONDARY_INVENTORY_NAME = SUBINVENTORY
                                   AND S.availability_type = DECODE(p_include_nonnet,
                                                                    1,
                                                                    S.availability_type,
                                                                    1)));

                IF G_TRACE_ON = 1 THEN
                print_debug('Total demand (internal orders): ' || to_char(l_total_demand_qty)
                            , 'get_demand_qty'
                            , 9);
                END IF;
            end if;

            --
            -- Find out the reserved qty for the material from mtl_reservations
            --
            IF ((p_net_rsv = 1 and p_net_unrsv = 2)
                OR
                (p_net_rsv = 2 and p_net_unrsv = 1))
            THEN
               --
               -- Include the reserved demand from mtl_reservations
               --
               select sum(PRIMARY_RESERVATION_QUANTITY)
                 into l_total_reserve_qty
                 from mtl_reservations md, oe_order_lines_all so,
--                      po_req_distributions_all pod,    Bug 5934651
                      po_requisition_lines_all pol
                where md.DEMAND_SOURCE_LINE_ID = so.LINE_ID
--                  and to_number(so.ORIG_SYS_LINE_REF)     = pod.DISTRIBUTION_ID --Bug#2883172
                    and so.SOURCE_DOCUMENT_ID  = pol.requisition_header_id         -- Bug 5934651
                    and so.source_document_line_id = pol.requisition_line_id
--                  and pod.REQUISITION_LINE_ID  = pol.REQUISITION_LINE_ID
                  and (pol.DESTINATION_ORGANIZATION_ID <> p_org_id or
                       (pol.DESTINATION_ORGANIZATION_ID = p_org_id
                        and  -- Added code Bug#1012179
                        ( pol.DESTINATION_TYPE_CODE = 'EXPENSE' OR  -- Bug#3619239 started
-- Bug 3619239 The functionality is added so that demand from Internal Sales Requisitions are taken
-- into consideration if Destination Type is Inventory and Destination Subinventory is Non Quantity Tracked
			  (  pol.DESTINATION_TYPE_CODE = 'INVENTORY'
			     AND pol.DESTINATION_SUBINVENTORY IS NOT NULL
			     AND EXISTS (select 1 from
			                 MTL_SECONDARY_INVENTORIES
                                         where SECONDARY_INVENTORY_NAME = pol.DESTINATION_SUBINVENTORY
                                         and ORGANIZATION_ID = pol.DESTINATION_ORGANIZATION_ID
                                         and QUANTITY_TRACKED = 2)
			   )
			 )-- Bug#3619239 ended
			)
                      )
                  and ORGANIZATION_ID = p_org_id
                  and md.INVENTORY_ITEM_ID = p_item_id
                  and REQUIREMENT_DATE <= p_d_cutoff + 0.99999 /* bug no 6009682 */
                  and demand_source_type_id = 8
                  and (SUBINVENTORY_CODE is null or
                       EXISTS (SELECT 1
                                 FROM MTL_SECONDARY_INVENTORIES S
                                WHERE S.ORGANIZATION_ID = p_org_id
                                  AND S.SECONDARY_INVENTORY_NAME = SUBINVENTORY_CODE
                                  AND S.availability_type = DECODE(p_include_nonnet,
                                                                   1,
                                                                   S.availability_type,
                                                                   1)))
/* nsinghi MIN-MAX INVCONV start */
                  AND (md.locator_id IS NULL OR
                       p_level = 2 OR
                        EXISTS (SELECT 1 FROM mtl_item_locations mil
                               WHERE mil.organization_id = p_org_id
                               AND   mil.inventory_location_id = md.locator_id
                               AND   mil.subinventory_code = NVL(md.subinventory_code, mil.subinventory_code)
                               AND   mil.availability_type = decode(p_include_nonnet,1,mil.availability_type,1)))
                  AND (md.lot_number IS NULL OR
                       p_level = 2 OR
                        EXISTS (SELECT 1 FROM mtl_lot_numbers mln
                               WHERE mln.organization_id = p_org_id
                               AND   mln.lot_number = md.lot_number
                               AND   mln.inventory_item_id = p_item_id
                               AND   mln.availability_type = decode(p_include_nonnet,1,mln.availability_type,1)));
/* nsinghi MIN-MAX INVCONV end */

               IF G_TRACE_ON = 1 THEN
               print_debug('Reserved demand (internal orders): ' || to_char(l_total_reserve_qty)
                           , 'get_demand_qty'
                           , 9);
               END IF;
            END IF;

            --
            -- total demand is calculated as follows:
            -- if we have to consider both unreserved matl and reserved matl. then the
            --    demand is simply the total demand = ordered qty - shipped qty.
            -- elsif we have to take into account only reserved matl. then the
            --    demand is simply the reservations from mtl_reservations for the matl.
            -- elsif we have to take into account just the unreserved matl. then the
            --    demand is total demand - the reservations for the material.
            --
            if p_net_unrsv = 1 and p_net_rsv = 1 then
               l_demand_qty := NVL(l_total_demand_qty,0);

            elsif p_net_rsv = 1 then
               l_demand_qty := NVL(l_total_reserve_qty,0);

            elsif p_net_unrsv = 1 then
               l_demand_qty := NVL(l_total_demand_qty,0) - NVL(l_total_reserve_qty,0);
            end if;
            IF G_TRACE_ON = 1 THEN
            print_debug('Demand from internal orders: ' || to_char(l_demand_qty)
                        , 'get_demand_qty'
                        , 9);
            END IF;
            total := total + NVL(l_demand_qty,0);

        end if; -- end if level=1

        --
     /* Bug 3364512. Demand is double for back-to-back sales orders after
	auto-create requisition and for sales orders with ATO items after
	auto-create WIP job. Commenting the below code which fetches duplicate
	demand */

        -- WIP Reservations from mtl_demand
        --
     /*   IF p_level = 1 THEN
            --
            -- SUBINVENTORY IS Always expected to be Null when Reservation_type is 3.
            --
            select sum(PRIMARY_UOM_QUANTITY - GREATEST(NVL(RESERVATION_QUANTITY,0),
                   NVL(COMPLETED_QUANTITY,0)))
              into qty
              from mtl_demand
             where RESERVATION_TYPE = 3
               and ORGANIZATION_ID = p_org_id
               and PRIMARY_UOM_QUANTITY >
                    GREATEST(NVL(RESERVATION_QUANTITY,0), NVL(COMPLETED_QUANTITY,0))
               and INVENTORY_ITEM_ID = p_item_id
               and REQUIREMENT_DATE <= p_d_cutoff
               and p_net_rsv = 1;

            IF G_TRACE_ON = 1 THEN
            print_debug('WIP Reservations from mtl_demand: ' || to_char(qty)
                        , 'get_demand_qty'
                        , 9);
            END IF;
            total := total + NVL(qty,0);
        END IF; */

        --
        -- Wip Components are to be included at the Org Level Planning only.
        -- Qty Issued Substracted from the Qty Required
        --
        if (p_net_wip = 1 and p_level = 1)
        then

/* nsinghi MIN-MAX INVCONV start */

           IF p_process_org = 'Y' THEN

/*      Here we need include the query to include OPM as source of demand.
Since GME will always give the complete demand (including reserved demand)
so subtracting the reserved demand as reserved demand will be considered
above from mtl_reservations query. */


              SELECT
                 SUM (INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY( p_org_id
                                                                ,  p_item_id
                                                                , d.dtl_um
                    , NVL(NVL(d.wip_plan_qty, d.plan_qty) - d.actual_qty, 0))-
                       NVL(mtr.primary_reservation_quantity,0))
              INTO qty
              FROM   gme_material_details d
              ,      gme_batch_header     h
              ,      mtl_reservations     mtr
              WHERE  h.batch_type IN (0,10)
              AND    h.batch_status IN (1,2)
              AND    h.batch_id = d.batch_id
              AND    d.line_type = -1
--              AND    NVL(d.original_qty, 0) <> 0       --commented as part of bug 8434499
              AND    d.organization_id = p_org_id
              AND    d.inventory_item_id = p_item_id
              AND    d.batch_id = mtr.demand_source_header_id (+)
              AND    d.material_detail_id = mtr.demand_source_line_id (+)
              AND    d.inventory_item_id = mtr.inventory_item_id (+)
              AND    d.organization_id = mtr.organization_id (+)
              AND    (INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY( p_org_id
                                                                ,  p_item_id
                                                                , d.dtl_um
                    , NVL(NVL(d.wip_plan_qty, d.plan_qty) - d.actual_qty, 0))-
                       NVL(mtr.primary_reservation_quantity,0)) > 0
              AND    NVL(mtr.demand_source_type_id, 5) = 5
              AND    d.material_requirement_date <= p_d_cutoff
              AND    (mtr.subinventory_code IS NULL OR
                      EXISTS (SELECT 1
                                FROM mtl_secondary_inventories s
                               WHERE s.organization_id = p_org_id
                                 AND s.secondary_inventory_name = mtr.subinventory_code
                                 AND s.availability_type = DECODE(p_include_nonnet,1,s.availability_type,1)))
              AND    (mtr.locator_id IS NULL OR
                       EXISTS (SELECT 1 FROM mtl_item_locations mil
                              WHERE mil.organization_id = p_org_id
                              AND   mil.inventory_location_id = mtr.locator_id
                              AND   mil.subinventory_code = NVL(mtr.subinventory_code, mil.subinventory_code)
                              AND   mil.availability_type = DECODE(p_include_nonnet,1,mil.availability_type,1)))
              AND    (mtr.lot_number IS NULL OR
                       EXISTS (SELECT 1 FROM mtl_lot_numbers mln
                              WHERE mln.organization_id = p_org_id
                              AND   mln.lot_number = mtr.lot_number
                              AND   mln.inventory_item_id = p_item_id
                              AND   mln.availability_type = DECODE(p_include_nonnet,1,mln.availability_type,1)));

              IF G_TRACE_ON = 1 THEN
              print_debug('Batch Material requirements for OPM Batches : ' || to_char(qty)
                          , 'get_demand_qty'
                          , 9);
              END IF;
              total := total + NVL(qty,0);

           ELSE
/* nsinghi MIN-MAX INVCONV end */
              /*4518296*/

              select sum(o.required_quantity - o.quantity_issued)
                into qty
                from wip_discrete_jobs d, wip_requirement_operations o
               where o.wip_entity_id     = d.wip_entity_id
                 and o.organization_id   = d.organization_id
                 and d.organization_id   = p_org_id
                 and o.inventory_item_id = p_item_id
                 and o.date_required    <= p_d_cutoff + 0.99999 /* bug no 6009682 */
                 and o.required_quantity > 0
                 and o.required_quantity > o.quantity_issued
                 and o.operation_seq_num > 0
                 and d.status_type in (1,3,4,6) -- Excluded 5 from selection Bug#1016495
                 and o.wip_supply_type not in (5,6); -- Included 5 from the selection Bug#4488415

              IF G_TRACE_ON = 1 THEN
              print_debug('WIP component requirements for discrete jobs: ' || to_char(qty)
                          , 'get_demand_qty'
                          , 9);
              END IF;
              total := total + NVL(qty,0);

              --
              -- Demand Qty to be added for a released repetitive schedule
              -- Bug#691471
              --
              /*4518296*/
              select sum(o.required_quantity - o.quantity_issued)
                into qty
                from wip_repetitive_schedules r, wip_requirement_operations o
               where o.wip_entity_id          = r.wip_entity_id
                 and o.repetitive_schedule_id = r.repetitive_schedule_id
                 and o.organization_id        = r.organization_id
                 and r.organization_id        = p_org_id
                 and o.inventory_item_id      = p_item_id
                 and o.date_required          <= p_d_cutoff + 0.99999 /* bug no 6009682 */
                 and o.required_quantity      > 0
                 and o.required_quantity      > o.quantity_issued
                 and o.operation_seq_num      > 0
                 and r.status_type in (1,3,4,6) -- Excluded 5 from selection Bug#1016495
                 and o.wip_supply_type not in (5,6); -- Included 5 from the selection Bug#4488415
              IF G_TRACE_ON = 1 THEN
              print_debug('WIP component requirements for repetitive schedules: ' || to_char(qty)
                          , 'get_demand_qty'
                          , 9);
              END IF;
              total := total + NVL(qty,0);

           END IF; /* p_process_org = 'Y' */

        end if;

        --
        -- Include move orders:
        -- Leave out the closed or cancelled lines
        -- Select only Issue from Stores for org level planning
        -- Also select those lines for sub level planning.
        --
        -- Exclude move orders created for WIP Issue transaction
        -- (txn type = 35, INV_Globals.G_TYPE_XFER_ORDER_WIP_ISSUE)
        -- since these are already taken into account (above) by
        -- directly querying the WIP tables for open component requirements
        --

        -- kkoothan Part of Bug Fix: 2875583
        -- Converting the quantities to the primary uom as the quantity
        -- and quantity delivered in mtl_txn_request_lines
        -- are in transaction uom.

--Bug 3057273, Move order demand should be excluded if net unreserved demand is No.
  if p_net_unrsv = 1 then

        /*SELECT SUM(MTRL.QUANTITY - NVL(MTRL.QUANTITY_DELIVERED,0))
          INTO qty
          FROM MTL_TXN_REQUEST_LINES MTRL,
               MTL_TRANSACTION_TYPES MTT
         WHERE MTT.TRANSACTION_TYPE_ID = MTRL.TRANSACTION_TYPE_ID
           AND MTRL.TRANSACTION_TYPE_ID <> INV_Globals.G_TYPE_XFER_ORDER_WIP_ISSUE
           AND MTRL.ORGANIZATION_ID = p_org_id
           AND MTRL.INVENTORY_ITEM_ID = p_item_id
           AND MTRL.LINE_STATUS NOT IN (5,6)
           AND MTT.TRANSACTION_ACTION_ID = 1
           AND (p_level = 1  OR
                MTRL.FROM_SUBINVENTORY_CODE = p_subinv)
           AND (MTRL.FROM_SUBINVENTORY_CODE IS NULL OR
                p_level = 2  OR
                EXISTS (SELECT 1
                          FROM MTL_SECONDARY_INVENTORIES S
                         WHERE S.ORGANIZATION_ID = p_org_id
                           AND S.SECONDARY_INVENTORY_NAME = MTRL.FROM_SUBINVENTORY_CODE
                           AND S.AVAILABILITY_TYPE = DECODE(p_include_nonnet,
                                                            1,S.AVAILABILITY_TYPE,1)))
           AND MTRL.DATE_REQUIRED <= p_d_cutoff;*/

           SELECT NVL(SUM(inv_decimals_pub.get_primary_quantity( p_org_id
                                                             ,p_item_id
                                                             , mtrl.uom_code
                                                             , mtrl.quantity - NVL(mtrl.quantity_delivered,0))
                                                             ),0)
           INTO  qty
           FROM  MTL_TXN_REQUEST_LINES MTRL,
                 MTL_TRANSACTION_TYPES MTT
           WHERE  MTT.TRANSACTION_TYPE_ID = MTRL.TRANSACTION_TYPE_ID
           AND    MTRL.TRANSACTION_TYPE_ID <> INV_Globals.G_TYPE_XFER_ORDER_WIP_ISSUE
           AND    MTRL.ORGANIZATION_ID = p_org_id
           AND    MTRL.INVENTORY_ITEM_ID = p_item_id
           AND    MTRL.LINE_STATUS  IN (3,7)--Changed for Bug 5330189: 3 = Approved 7 = Pre-Approved
           AND    MTT.TRANSACTION_ACTION_ID = 1
           AND    (p_level = 1  OR
                   MTRL.FROM_SUBINVENTORY_CODE = p_subinv)
           AND    (MTRL.FROM_SUBINVENTORY_CODE IS NULL OR
                  p_level = 2  OR
                  EXISTS (SELECT 1
                          FROM MTL_SECONDARY_INVENTORIES S
                          WHERE   S.ORGANIZATION_ID = p_org_id
                          AND     S.SECONDARY_INVENTORY_NAME = MTRL.FROM_SUBINVENTORY_CODE
                          AND     S.AVAILABILITY_TYPE = DECODE(p_include_nonnet,
                                                        1,S.AVAILABILITY_TYPE,1)))
           AND mtrl.date_required <= p_d_cutoff + 0.99999 /* bug no 6009682 */
/* nsinghi MIN-MAX INVCONV start */
           AND (mtrl.from_locator_id IS NULL OR
                p_level = 2 OR
                 EXISTS (SELECT 1 FROM mtl_item_locations mil
                        WHERE mil.organization_id = p_org_id
                        AND   mil.inventory_location_id = mtrl.from_locator_id
                        AND   mil.subinventory_code = NVL(mtrl.from_subinventory_code, mil.subinventory_code)
                        AND   mil.availability_type = decode(p_include_nonnet,1,mil.availability_type,1)))
           AND (mtrl.lot_number IS NULL OR
                p_level = 2 OR
                 EXISTS (SELECT 1 FROM mtl_lot_numbers mln
                        WHERE mln.organization_id = p_org_id
                        AND   mln.lot_number = mtrl.lot_number
                        AND   mln.inventory_item_id = p_item_id
                        AND   mln.availability_type = decode(p_include_nonnet,1,mln.availability_type,1)));
/* nsinghi MIN-MAX INVCONV end */

        IF G_TRACE_ON = 1 THEN
        print_debug('Demand from open move orders: ' || to_char(qty), 'get_demand_qty', 9);
        END IF;

        total := total + NVL(qty,0);

  end if;

        --
        -- Include the sub transfer and the staging transfer move orders
        -- for sub level planning
        -- Bug 3057273, Move order demand should be excluded if net unreserved demand is No.

        IF (p_level = 2 and p_net_unrsv = 1) THEN
            -- kkoothan Part of Bug Fix: 2875583
            -- Converting the quantities to the primary uom as the quantity
            -- and quantity delivered in mtl_txn_request_lines
            -- are in transaction uom.

            /*SELECT NVL(sum(mtrl.quantity - NVL(mtrl.quantity_delivered,0)),0)
              INTO qty
              FROM mtl_transaction_types  mtt,
                   mtl_txn_request_lines  mtrl
             WHERE mtt.transaction_action_id IN (2,28)
               AND mtt.transaction_type_id     = mtrl.transaction_type_id
               AND mtrl.organization_id        = p_org_id
               AND mtrl.inventory_item_id      = p_item_id
               AND mtrl.from_subinventory_code = p_subinv
               AND mtrl.line_status NOT IN (5,6)
               AND mtrl.date_required         <= p_d_cutoff;*/

            SELECT NVL(SUM(inv_decimals_pub.get_primary_quantity( p_org_id
                                                             ,p_item_id
                                                             ,mtrl.uom_code
                                                             , mtrl.quantity - NVL(mtrl.quantity_delivered,0))
                                                             ),0)
            INTO qty
            FROM mtl_transaction_types  mtt,
                 mtl_txn_request_lines  mtrl
            WHERE mtt.transaction_action_id IN (2,28)
              AND mtt.transaction_type_id     = mtrl.transaction_type_id
              AND mtrl.organization_id        = p_org_id
              AND mtrl.inventory_item_id      = p_item_id
              AND mtrl.from_subinventory_code = p_subinv
              AND MTRL.LINE_STATUS  IN (3,7) --Changed for Bug 5330189: 3 = Approved 7 = Pre-Approved
              AND mtrl.date_required <= p_d_cutoff + 0.99999; /* bug no 6009682 */

            IF G_TRACE_ON = 1 THEN
            print_debug('Qty pending out due to sub transfers and the staging transfer move orders: '
                         || to_char(qty)
                        , 'get_demand_qty'
                        , 9);
            END IF;
            total := total + NVL(qty,0);
        END IF;

         -- Bug 5041763 need to exclude drop ship reservation from on-hand qty to get correct availability
           select sum(PRIMARY_RESERVATION_QUANTITY)
           into   qty
           from   mtl_reservations
           WHERE  ORGANIZATION_ID = p_org_id
           and    INVENTORY_ITEM_ID = p_item_id
           and    demand_source_type_id  = 2
           and    supply_source_type_id = 13
           and    REQUIREMENT_DATE <= p_d_cutoff + 0.99999 /* bug no 6009682 */
           and    ((p_level = 1 ) OR
                  SUBINVENTORY_CODE = p_subinv)
           and ( SUBINVENTORY_CODE is null or
                 p_level = 2 or
                 EXISTS (SELECT 1
                        FROM MTL_SECONDARY_INVENTORIES S
                        WHERE S.ORGANIZATION_ID = p_org_id
                        AND S.SECONDARY_INVENTORY_NAME = SUBINVENTORY_CODE
                        AND S.availability_type = DECODE(p_include_nonnet,
                                                         1,
                                                         S.availability_type,
                                                         1)))
           and    EXISTS (SELECT 1
                            FROM OE_DROP_SHIP_SOURCES ODSS
                            WHERE  ODSS.LINE_ID = DEMAND_SOURCE_LINE_ID);
           total := total + NVL(qty,0);
	--Bug 6240025 BEGIN
	l_loaded_qty := get_loaded_qty(p_org_id
				      , p_subinv
				      , p_level
				      , p_item_id
				      , p_net_rsv
				      , p_net_unrsv);
	total := total+NVL(l_loaded_qty,0);
	--Bug 6240025 END
        return(total);

    exception
        when others then
            IF G_TRACE_ON = 1 THEN
            print_debug(sqlcode || ', ' || sqlerrm, 'get_demand_qty', 1);
            END IF;
            RAISE;
    end get_demand_qty;



    FUNCTION get_shipped_qty( p_organization_id    IN      NUMBER
                            , p_inventory_item_id  IN      NUMBER
                            , p_order_line_id      IN      NUMBER) RETURN NUMBER IS

        l_shipped_qty NUMBER := 0;

    BEGIN

        --
        -- Only look at source types 2 and 8 (sales orders, internal orders)
        --
        SELECT SUM(primary_quantity)
          INTO l_shipped_qty
          FROM mtl_material_transactions
         WHERE transaction_action_id = 1
           AND source_line_id        = p_order_line_id
           AND organization_id       = p_organization_id
           AND inventory_item_id     = p_inventory_item_id
           AND transaction_source_type_id in (2,8);

        IF l_shipped_qty IS NULL THEN
           l_shipped_qty := 0;
        ELSE
           l_shipped_qty := -1 * l_shipped_qty;
        END IF;

        RETURN l_shipped_qty;

    END get_shipped_qty;



    FUNCTION get_staged_qty( p_org_id          NUMBER
                           , p_subinv          VARCHAR2
                           , p_item_id         NUMBER
                           , p_order_line_id   NUMBER
                           , p_include_nonnet  NUMBER) RETURN NUMBER IS

        l_staged_qty  NUMBER := 0;

    BEGIN

        BEGIN
            --
            -- Bugfix 2333526: Need to calculate staged quantity
            -- for sub level planning.  If passed-in (planning)
            -- sub is the also the staging sub, then ignore
            -- p_include_nonnet
            --
            SELECT NVL(SUM(primary_reservation_quantity),0)
              INTO l_staged_qty
              FROM mtl_reservations
             WHERE organization_id        = p_org_id
               AND inventory_item_id      = p_item_id
               AND demand_source_line_id  = p_order_line_id
               AND demand_source_type_id  IN (2,8,12)
               AND NVL(staged_flag, 'X')  = 'Y'
               AND subinventory_code      IS NOT NULL
               AND subinventory_code     <> p_subinv; -- Bug 4313204

        EXCEPTION
            WHEN OTHERS THEN
                 l_staged_qty  := 0;
        END;

        RETURN l_staged_qty;

    END get_staged_qty;



    FUNCTION get_pick_released_qty( p_org_id          NUMBER
                                  , p_subinv          VARCHAR2
                                  , p_item_id         NUMBER
                                  , p_order_line_id   NUMBER) RETURN NUMBER IS

        l_pick_released_qty  NUMBER := 0;

    BEGIN

        BEGIN
            --
            -- Move order type 3 is pick wave, source type 2 is sales order
            -- Bug 3181367 added transaction_source_type_id 8 too.
            SELECT NVL(sum(mtrl.quantity - NVL(mtrl.quantity_delivered,0)),0)
              INTO l_pick_released_qty
              FROM mtl_txn_request_headers  mtrh,
                   mtl_txn_request_lines    mtrl
             WHERE mtrh.move_order_type            = 3
               AND mtrh.header_id                  = mtrl.header_id
               AND mtrl.organization_id            = p_org_id
               AND mtrl.inventory_item_id          = p_item_id
               AND mtrl.from_subinventory_code     = p_subinv
               AND mtrl.txn_source_line_id         = p_order_line_id
               AND mtrl.transaction_source_type_id in (2,8)
               AND mtrl.line_status NOT IN (5,6);

        EXCEPTION
            WHEN OTHERS THEN
                 l_pick_released_qty  := 0;
        END;

        RETURN l_pick_released_qty;

    END get_pick_released_qty;

    FUNCTION get_reord_qty( p_min_qty        NUMBER
                          , p_max_qty        NUMBER
                          , p_min_ord_qty    NUMBER
                          , p_max_ord_qty    NUMBER
                          , p_tot_avail_qty  NUMBER
                          , p_fix_mult       NUMBER) RETURN NUMBER IS

        l_min_qty           NUMBER;
        l_max_qty           NUMBER;
        l_min_ord_qty       NUMBER;
        l_fix_mult          NUMBER;

        l_reorder             NUMBER;
        l_min_restock_qty     NUMBER;
        l_qty_for_last_order  NUMBER;
        l_round_reord_qty     VARCHAR2(1);

    BEGIN
        IF G_TRACE_ON = 1 THEN
           print_debug('p_min_qty: '         || to_char(p_min_qty)       ||
                       ', p_max_qty: '       || to_char(p_max_qty)       ||
                       ', p_min_ord_qty: '   || to_char(p_min_ord_qty)   ||
                       ', p_max_ord_qty: '   || to_char(p_max_ord_qty)   ||
                       ', p_tot_avail_qty: ' || to_char(p_tot_avail_qty) ||
                       ', p_fix_mult: '      || to_char(p_fix_mult)
                       , 'get_reord_qty'
                       , 9);
        END IF;


     /* GENERAL ALGORITHM:

        When to order?
          When total available < minimum for item

        How much to order?
          reorder qty = max stockable qty - total available

          If reorder qty < min ord qty, increase reorder qty to min ord qty

          If a fixed lot multiple is defined
             Round the reorder up or down based on profile INV_ROUND_REORDER_QTY

          If a max ord qty is not specified
             or if reorder qty < max ord qty, no changes required

          If max ord qty is specified
             and reorder qty exceeds max ord qty:

             We need to make sure that after creating one or more orders
             for max order qty, the remaining quantity exceeds min ord qty

             For e.g.:
                 reorder qty = 34
                 max ord qty = 10
                 min ord qty = 5

             Then restocking code will create 3 orders (move orders, requisitions
             or work orders) for 10 each, which is 30.  The left over qty is
             34 - 30 = 4.  Since the min ord qty is 5, we should discard the
             remaining qty of 4.  If the remaining qty was say 8, then the last
             move order/requisition/work order would be for qty 8, and so on.

             If no min ord qty is specified (or if it is 0) then this downward
             adjustment is not required.
          end if;
      */



        l_min_qty     := NVL(p_min_qty,0);
        l_max_qty     := NVL(p_max_qty,0);
        l_min_ord_qty := NVL(p_min_ord_qty,0);
        l_fix_mult    := NVL(p_fix_mult,0);

        IF p_tot_avail_qty >= l_min_qty
        THEN
           RETURN 0;
        END if;

        l_reorder := l_max_qty - p_tot_avail_qty;

        IF G_TRACE_ON = 1 THEN
           print_debug('Initial estimated reorder qty: ' || to_char(l_reorder)
                       , 'get_reord_qty'
                       , 9);
        END IF;

        IF l_min_ord_qty >= l_reorder
        THEN
            RETURN l_min_ord_qty;
        END if;

        IF l_fix_mult > 0
        THEN
            l_round_reord_qty := NVL(FND_PROFILE.VALUE('INV_ROUND_REORDER_QTY'), 'Y');

            IF G_TRACE_ON = 1 THEN
               print_debug('l_round_reord_qty: ' || l_round_reord_qty, 'get_reord_qty', 9);
            END IF;

            IF l_round_reord_qty = 'N'
            THEN
                l_reorder := floor(l_reorder/l_fix_mult) * l_fix_mult;
            ELSE
                l_reorder := ceil(l_reorder/l_fix_mult) * l_fix_mult;
            END if;

            IF G_TRACE_ON = 1 THEN
               print_debug('Reorder qty after applying fix lot multiple: '
                           || to_char(l_reorder)
                           , 'get_reord_qty'
                           , 9);
            END IF;
        END if;

        IF p_max_ord_qty IS NULL OR l_reorder <= p_max_ord_qty
        THEN
            RETURN l_reorder;
        ELSIF p_max_ord_qty > 0
        THEN
            l_min_restock_qty := floor(l_reorder/p_max_ord_qty) * p_max_ord_qty;
            l_qty_for_last_order := l_reorder - l_min_restock_qty;

            IF G_TRACE_ON = 1 THEN
               print_debug('Min reord qty that is a multiple of max ord qty: '
                           || to_char(l_min_restock_qty)
                           , 'get_reord_qty'
                           , 9);
            END IF;

            IF l_qty_for_last_order >= l_min_ord_qty
            THEN
                RETURN l_reorder;
            ELSE
                RETURN l_min_restock_qty;
            END IF;
        END if;

        RETURN l_reorder;

    EXCEPTION
        WHEN OTHERS THEN
            IF G_TRACE_ON = 1 THEN
               print_debug(sqlcode || ', ' || sqlerrm, 'get_reord_qty', 1);
            END IF;
            RAISE;
    END get_reord_qty;


    --
    -- Added a new parameter p_cust_site_id for Patchset I Enhancement
    -- Min Max Leadtime Enhancement.
    --
    FUNCTION get_reord_stat ( p_restock           NUMBER
                            , p_handle_rep_item   NUMBER
                            , p_level             NUMBER
                            , p_reord_qty         NUMBER
                            , p_wip_batch_id      NUMBER
                            , p_org_id            NUMBER
                            , p_subinv            VARCHAR2
                            , p_user_id           NUMBER
                            , p_employee_id       NUMBER
                            , p_sysdate           DATE
                            , p_approval          NUMBER
                            , p_encum_flag        VARCHAR2
                            , p_cust_id           NUMBER
                            , p_cust_site_id      NUMBER
                            , p_cal_code          VARCHAR2
                            , p_exception_set_id  NUMBER
                            , p_dd_loc_id         NUMBER
                            , p_po_org_id         NUMBER
                            , p_pur_revision      NUMBER
                            , p_item_rec          minmax_items_rectype
                            , p_osfm_batch_id     NUMBER DEFAULT NULL   /* Added for Bug 6807835 */
                            ) RETURN VARCHAR2 IS

        v_make_buy_flag   NUMBER;
        l_error_message   VARCHAR2(100);
        l_ret_stat        VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
        l_reorder_qty     NUMBER;
        l_move_ord_qty    NUMBER;

    BEGIN
        IF G_TRACE_ON = 1 THEN
            print_debug('p_restock: '            || to_char(p_restock)          ||
                        ', p_handle_rep_item: '  || to_char(p_handle_rep_item)  ||
                        ', p_level; '            || to_char(p_level)            ||
                        ', p_reord_qty: '        || to_char(p_reord_qty)        ||
                        ', p_wip_batch_id: '     || to_char(p_wip_batch_id)     ||
                        ', p_org_id: '           || to_char(p_org_id)           ||
                        ', p_subinv: '           || p_subinv                    ||
                        ', p_user_id: '          || to_char(p_user_id)          ||
                        ', p_employee_id: '      || to_char(p_employee_id)      ||
                        ', p_sysdate: '          || to_char(p_sysdate, 'DD-MON-YYYY HH24:MI:SS')
                        , 'get_reord_stat'
                        , 9);

            print_debug('p_approval: '           || to_char(p_approval)         ||
                        ', p_encum_flag: '       || p_encum_flag                ||
                        ', p_cust_id: '          || to_char(p_cust_id)          ||
                        ', p_cust_site_id: '     || to_char(p_cust_site_id)     ||
                        ', p_cal_code: '         || p_cal_code                  ||
                        ', p_exception_set_id: ' || to_char(p_exception_set_id) ||
                        ', p_dd_loc_id: '        || to_char(p_dd_loc_id)        ||
                        ', p_po_org_id: '        || to_char(p_po_org_id)        ||
                        ', p_pur_revision: '     || to_char(p_pur_revision)     ||
                        ', p_item_rec: '         || to_char(p_item_rec.item_id) ||
                        ', p_osfm_batch_id: '    || to_char(p_osfm_batch_id)
                        , 'get_reord_stat'
                        , 9);
        END IF;

        -- kkoothan fix for Bug 2661176,3020869
        -- If the item is a repetitive item and the user chose not to restock
        -- repetitive items, or if the planning level is "Org" and source type
        -- is subinventory (3) do not restock - but pass some meaningful messages
        -- which would be printed on the report output as :
        -- "Cannot create move orders for organization level planning"
        -- or "Repetitive Planning with Do Not Restock Option Chosen" respectively.
        --
        -- Restocking with source type sub will result in a move order and this
        -- only makes sense for sub level planning.
        --
        -- For sub level planning, always set the make_or_buy flag to "buy",
        -- i.e., do not create a work order for sub level planning.
        --
        IF p_restock = 1 THEN
              BEGIN
                IF G_TRACE_ON = 1 THEN
                    print_debug('Item Source Type and Make or Buy Flag value: '|| p_item_rec.src_type ||' and '|| p_item_rec.mbf
                                , 'get_reord_stat'
                                , 9);
                END IF;
                IF (p_item_rec.repetitive_planned_item = 'Y' AND p_handle_rep_item = 3) THEN
                    IF G_TRACE_ON = 1 THEN
                     print_debug('For a repetitive item, Handle Repetitive Item parameter in the report has been chosen as Do Not Restock(Report Only)'
                                 , 'get_reord_stat'
                                 , 9);
                    END IF;
                    SELECT meaning
                    INTO  l_error_message
                    FROM  mfg_lookups
                    WHERE lookup_type = 'INV_MMX_RPT_MSGS'
                    AND   lookup_code = 7;
                    RETURN(l_error_message);
                ELSIF (p_level = 1 AND p_item_rec.src_type = 3 AND p_item_rec.mbf = 2) THEN
                    IF G_TRACE_ON = 1 THEN
                     print_debug('In Organization level planning, Source type for this min max item has been set up as ''Subinventory'''
                                 , 'get_reord_stat'
                                 , 9);
                    END IF;
                    SELECT meaning
                    INTO  l_error_message
                    FROM  mfg_lookups
                    WHERE lookup_type = 'INV_MMX_RPT_MSGS'
                    AND   lookup_code = 6;
                    RETURN(l_error_message);
                ELSE
                  IF p_level = 2 THEN
                    v_make_buy_flag := 2;
                  ELSE
                    v_make_buy_flag := p_item_rec.mbf;
                  END IF;
                END IF;
              EXCEPTION
                WHEN no_data_found THEN
                   RETURN('');
              END;

        ELSE
            RETURN ('');
        END IF;

        l_reorder_qty := NVL(p_reord_qty,0);

        WHILE (l_reorder_qty > 0)
        LOOP
            IF NVL(p_item_rec.max_ord_qty,0) = 0
            THEN
                l_move_ord_qty := l_reorder_qty;
            ELSIF (l_reorder_qty > p_item_rec.max_ord_qty)
            THEN
                l_move_ord_qty := p_item_rec.max_ord_qty;
            ELSE
                l_move_ord_qty := l_reorder_qty;
            END IF;

            do_restock( p_item_id                  => p_item_rec.item_id
                      , p_mbf                      => v_make_buy_flag
                      , p_handle_repetitive_item   => p_handle_rep_item
                      , p_repetitive_planned_item  => p_item_rec.repetitive_planned_item
                      , p_qty                      => l_move_ord_qty
                      , p_fixed_lead_time          => p_item_rec.fixed_lead_time
                      , p_variable_lead_time       => p_item_rec.variable_lead_time
                      , p_buying_lead_time         => p_item_rec.buying_lead_time
                      , p_uom                      => p_item_rec.primary_uom
                      , p_accru_acct               => p_item_rec.accru_acct
                      , p_ipv_acct                 => p_item_rec.ipv_acct
                      , p_budget_acct              => p_item_rec.budget_acct
                      , p_charge_acct              => p_item_rec.charge_acct
                      , p_purch_flag               => p_item_rec.purch_flag
                      , p_order_flag               => p_item_rec.order_flag
                      , p_transact_flag            => p_item_rec.transact_flag
                      , p_unit_price               => p_item_rec.unit_price
                      , p_wip_id                   => p_wip_batch_id
                      , p_user_id                  => p_user_id
                      , p_sysd                     => p_sysdate
                      , p_organization_id          => p_org_id
                      , p_approval                 => p_approval
                      , p_build_in_wip             => p_item_rec.build_in_wip
                      , p_pick_components          => p_item_rec.pick_components
                      , p_src_type                 => p_item_rec.src_type
                      , p_encum_flag               => p_encum_flag
                      , p_customer_id              => p_cust_id
                      , p_customer_site_id         => p_cust_site_id
                      , p_cal_code                 => p_cal_code
                      , p_except_id                => p_exception_set_id
                      , p_employee_id              => p_employee_id
                      , p_description              => p_item_rec.description
                      , p_src_org                  => TO_NUMBER(p_item_rec.src_org)
                      , p_src_subinv               => p_item_rec.src_subinv
                      , p_subinv                   => p_subinv
                      , p_location_id              => p_dd_loc_id
                      , p_po_org_id                => p_po_org_id
                      , p_pur_revision             => p_pur_revision
/* nsinghi MIN-MAX INVCONV start */
                      , p_execution_enabled        => p_item_rec.execution_enabled
                      , p_recipe_enabled           => p_item_rec.recipe_enabled
                      , p_process_enabled          => p_item_rec.process_enabled
/* nsinghi MIN-MAX INVCONV end */
                      , x_ret_stat                 => l_ret_stat
                      , x_ret_mesg                 => l_error_message
                      , p_osfm_batch_id            => p_osfm_batch_id       /* Added for Bug 6807835 */
                      );

            IF l_ret_stat <> FND_API.G_RET_STS_SUCCESS
            THEN
                IF G_TRACE_ON = 1 THEN
                print_debug('do_restock returned message: ' || l_error_message
                            , 'get_reord_stat'
                            , 9);
                END IF;
                RETURN(l_error_message);
            END IF;

            l_reorder_qty := l_reorder_qty - l_move_ord_qty;
        END LOOP;

        RETURN(''); /*bug2838809*/

    EXCEPTION
    WHEN others THEN
        IF G_TRACE_ON = 1 THEN
        print_debug(sqlcode || ', ' || sqlerrm, 'get_reord_stat', 1);
        END IF;
        RAISE;
    end get_reord_stat;


    --
    -- Min Max Lead time Enhancement.
    --

    PROCEDURE get_intransit_time(
        x_return_status        OUT  NOCOPY VARCHAR2
      , x_msg_count            OUT  NOCOPY NUMBER
      , x_msg_data             OUT  NOCOPY VARCHAR2
      , x_intransit_time       OUT  NOCOPY NUMBER
      , x_scheduled_ship_date  OUT  NOCOPY DATE
      , p_organization_id      IN   NUMBER
      , p_subinv               IN   VARCHAR2
      , p_to_customer_site_id  IN   NUMBER
      , p_src_org              IN   NUMBER
      , p_src_subinv           IN   VARCHAR2
      , p_item_id              IN   NUMBER
      , p_sourcing_date        IN   DATE
         ) IS
    l_proc_name           CONSTANT  VARCHAR2(30) := 'GET_INTRANSIT_TIME';
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(240);
    l_return              BOOLEAN;
    l_session_id          NUMBER;
    l_src_org             NUMBER;
    l_src_subinv          VARCHAR2(10);
    l_ship_method         VARCHAR2(30);
    l_src_rule_id         NUMBER;
    l_ven_site_id         NUMBER;
    l_ven_id              NUMBER;
    l_mode                VARCHAR2(20) := 'INVENTORY';
    l_from_location_id    NUMBER;
    l_intransit_time      NUMBER;
    l_so_cal_code         VARCHAR2(10);
    l_so_exception_set_id NUMBER;

    BEGIN
       SAVEPOINT  sp_get_intransit_time;
       l_return_status := FND_API.G_RET_STS_SUCCESS;
       IF G_TRACE_ON = 1 THEN
       print_debug('Executing get_intransit_time with the following parameters:'  || fnd_global.local_chr(10) ||
                        '  p_organization_id: '  || to_char(p_organization_id)    || fnd_global.local_chr(10) ||
                        ', p_subinv: '           || p_subinv                      || fnd_global.local_chr(10) ||
                        ', p_customer_site_id: ' || to_char(p_to_customer_site_id)|| fnd_global.local_chr(10) ||
                        ', p_src_org: '          || to_char(p_src_org)            || fnd_global.local_chr(10) ||
                        ', p_src_subinv: '       || p_src_subinv                  || fnd_global.local_chr(10) ||
                        ', p_item_id: '          || to_char(p_item_id)            || fnd_global.local_chr(10) ||
                        ', p_sourcing_date   : ' || to_char(p_sourcing_date)      || fnd_global.local_chr(10)
                        ,  l_proc_name
                        ,  9);
       END IF;

      -- Include intransit time also along with pre-processing and processing lead times for Sourcing date
      -- while determining the need-by date for internal requisitions.
      -- IF (any one of (src_org,src_subinv) is null)
      --    1. Call MRP API to find src org and src sub, passing in p_sourcing_date as arg_autosource_date
      -- END IF;
      -- Calculate intransit time by calling Planning API passing in ship-from location ID
      -- and ship-to location ID (p_location_id).
      --
      l_src_org     := p_src_org;
      l_src_subinv  := p_src_subinv;

      IF (p_src_org IS NULL OR p_src_subinv IS NULL) THEN
         IF G_TRACE_ON = 1 THEN
         print_debug('Calling MRP_SOURCING_API_PK.mrp_sourcing'
                    , l_proc_name
                    , 9);
         END IF;
         l_return := MRP_SOURCING_API_PK.mrp_sourcing
                                 ( arg_mode                  => l_mode
                                 , arg_item_id               => p_item_id
                                 , arg_commodity_id          => NULL
                                 , arg_dest_organization_id  => p_organization_id
                                 , arg_dest_subinventory     => p_subinv
                                 , arg_autosource_date       => p_sourcing_date
                                 , arg_vendor_id             => l_ven_id
                                 , arg_vendor_site_id        => l_ven_site_id
                                 , arg_source_organization_id=> l_src_org
                                 , arg_source_subinventory   => l_src_subinv
                                 , arg_sourcing_rule_id      => l_src_rule_id
                                 , arg_error_message         => l_msg_data
                                  ) ;
         IF NOT l_return THEN
            IF G_TRACE_ON = 1 THEN
            print_debug('MRP_SOURCING_API_PK.mrp_sourcing failed with error '|| l_msg_data
                        , l_proc_name
                        , 9);
            END IF;
            RAISE  fnd_api.g_exc_error;
         ELSE
            IF G_TRACE_ON = 1 THEN
            print_debug('MRP_SOURCING_API_PK.mrp_sourcing returned success with Source Sub and Source Org  '|| fnd_global.local_chr(10) || l_src_subinv || ' and '|| l_src_org
                       , l_proc_name
                       , 9);
            END IF;
         END IF;
      END IF; -- any one of (src_org,src_subinv) is null

      --
      -- Calculate the Schedlued Ship Date based on Shipping Org's Calendar.
      --

      BEGIN
        SELECT p.calendar_code, p.calendar_exception_set_id
        INTO l_so_cal_code, l_so_exception_set_id
        FROM mtl_parameters p
        WHERE p.organization_id = l_src_org;

        SELECT c1.calendar_date
        INTO x_scheduled_ship_date
        FROM bom_calendar_dates c1,
           bom_calendar_dates c
        WHERE c1.calendar_code   = c.calendar_code
         AND c1.exception_set_id = c.exception_set_id
         AND c1.seq_num          = c.next_seq_num
         AND c.calendar_code     = l_so_cal_code
         AND c.exception_set_id  = l_so_exception_set_id
         AND c.calendar_date     = trunc(p_sourcing_date);
      EXCEPTION
         WHEN no_data_found THEN
          IF G_TRACE_ON = 1 THEN
            print_debug('Exception: Organization '||l_src_org ||' is not defined'
                    , l_proc_name
                    , 9);
          END IF;
          RAISE  fnd_api.g_exc_error;
      END;

      --
      -- Get the Location associated with the Source Subinventory.
      --
      IF l_src_subinv IS NOT NULL THEN
      BEGIN
           SELECT LOCATION_ID
           INTO   l_from_location_id
           FROM   MTL_SECONDARY_INVENTORIES
           WHERE  SECONDARY_INVENTORY_NAME  =  l_src_subinv
           AND    ORGANIZATION_ID =  l_src_org ;
      EXCEPTION
          WHEN no_data_found THEN
            IF G_TRACE_ON = 1 THEN
            print_debug('Exception: Subinventory '|| l_src_subinv || ' does not exist in the Organization '|| l_src_org
                     , l_proc_name
                     , 9);
            END IF;
            RAISE  fnd_api.g_exc_error;
      END;
      END IF;

      --
      -- Get the Default value for Delivery To Location for the Souce Org .
      -- If a source subinventory is specified and has a location ID associated,
      -- use the source subinventory's location ID instead of the source organization's location ID.
      --
      IF l_from_location_id IS NULL THEN
      BEGIN
          SELECT LOC.LOCATION_ID
          INTO   l_from_location_id
          FROM   HR_ORGANIZATION_UNITS ORG,HR_LOCATIONS LOC
          WHERE  ORG.ORGANIZATION_ID = l_src_org
          AND    ORG.LOCATION_ID = LOC.LOCATION_ID;
      EXCEPTION
         WHEN no_data_found THEN
           IF G_TRACE_ON = 1 THEN
           print_debug('Exception: No Source Location Exists for the Organization '|| l_src_org
                       , l_proc_name
                       , 9);
           END IF;
           RAISE  fnd_api.g_exc_error;
      END;
      END IF;
      IF G_TRACE_ON = 1 THEN
      print_debug('From Location Id is: ' || l_from_location_id
                     , l_proc_name
                     , 9);
      END IF;


      BEGIN
        SELECT MRP_ATP_SCHEDULE_TEMP_S.NEXTVAL
        INTO l_session_id
        FROM SYS.DUAL;
      EXCEPTION
       WHEN no_data_found  THEN
          IF G_TRACE_ON = 1 THEN
          print_debug('Exception: MRP_ATP_SCHEDULE_TEMP_S.NEXTVAL is not defined'
                    , l_proc_name
                    , 9);
          END IF;
          RAISE  fnd_api.g_exc_error;
      END;
      IF G_TRACE_ON = 1 THEN
      print_debug('Calling MSC_ATP_PROC.ATP_Shipping_Lead_Time with session Id:'||l_session_id
                       , l_proc_name
                       , 9);
      END IF;

      MSC_SCH_WB.set_session_id(l_session_id);
      MSC_ATP_PROC.ATP_Shipping_Lead_Time (p_from_loc_id         => l_from_location_id
                                          ,p_to_customer_site_id => p_to_customer_site_id
                                          ,p_session_id          => l_session_id
                                          ,x_ship_method         => l_ship_method
                                          ,x_intransit_time      => l_intransit_time
                                          ,x_return_status       => l_return_status
                                          );
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF G_TRACE_ON = 1 THEN
           print_debug('MSC_ATP_PROC.ATP_Shipping_Lead_Time failed with unexpected error returning message: ' || l_msg_data
                       , l_proc_name
                       , 9);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF G_TRACE_ON = 1 THEN
           print_debug('MSC_ATP_PROC.ATP_Shipping_Lead_Time failed with expected error returning message: ' || l_msg_data
                       , l_proc_name
                       , 9);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
      ELSE
           x_intransit_time := NVL(l_intransit_time,0) ;
           IF G_TRACE_ON = 1 THEN
           print_debug('MSC_ATP_PROC.ATP_Shipping_Lead_Time returned success with Intransit Time '|| l_intransit_time
                       , l_proc_name
                       , 9);
           END IF;
      END IF;
    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO sp_get_intransit_time;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get
                              ( p_count => x_msg_count,
                                p_data  => x_msg_data
                              );

      WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO sp_get_intransit_time;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        fnd_msg_pub.count_and_get
                              ( p_count => x_msg_count,
                                p_data  => x_msg_data
                              );

      WHEN OTHERS THEN
        ROLLBACK TO sp_get_intransit_time;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)THEN
           fnd_msg_pub.add_exc_msg
                               ( G_PKG_NAME
                                ,l_proc_name
                               );
        END IF;
        fnd_msg_pub.count_and_get
                             ( p_count => x_msg_count,
                               p_data  => x_msg_data
                             );
    END get_intransit_time;

/* nsinghi MIN-MAX INVCONV start */
/* overloaded do_restock procedure. For process orgs , the overloaded procedure will be called
directly, whereas, the exiting code can make call to original do_restock procedure. */

    PROCEDURE do_restock( p_item_id                  IN   NUMBER
                        , p_mbf                      IN   NUMBER
                        , p_handle_repetitive_item   IN   NUMBER
                        , p_repetitive_planned_item  IN   VARCHAR2
                        , p_qty                      IN   NUMBER
                        , p_fixed_lead_time          IN   NUMBER
                        , p_variable_lead_time       IN   NUMBER
                        , p_buying_lead_time         IN   NUMBER
                        , p_uom                      IN   VARCHAR2
                        , p_accru_acct               IN   NUMBER
                        , p_ipv_acct                 IN   NUMBER
                        , p_budget_acct              IN   NUMBER
                        , p_charge_acct              IN   NUMBER
                        , p_purch_flag               IN   VARCHAR2
                        , p_order_flag               IN   VARCHAR2
                        , p_transact_flag            IN   VARCHAR2
                        , p_unit_price               IN   NUMBER
                        , p_wip_id                   IN   NUMBER
                        , p_user_id                  IN   NUMBER
                        , p_sysd                     IN   DATE
                        , p_organization_id          IN   NUMBER
                        , p_approval                 IN   NUMBER
                        , p_build_in_wip             IN   VARCHAR2
                        , p_pick_components          IN   VARCHAR2
                        , p_src_type                 IN   NUMBER
                        , p_encum_flag               IN   VARCHAR2
                        , p_customer_id              IN   NUMBER
                        , p_customer_site_id         IN   NUMBER
                        , p_cal_code                 IN   VARCHAR2
                        , p_except_id                IN   NUMBER
                        , p_employee_id              IN   NUMBER
                        , p_description              IN   VARCHAR2
                        , p_src_org                  IN   NUMBER
                        , p_src_subinv               IN   VARCHAR2
                        , p_subinv                   IN   VARCHAR2
                        , p_location_id              IN   NUMBER
                        , p_po_org_id                IN   NUMBER
                        , p_pur_revision             IN   NUMBER
                        , x_ret_stat                 OUT  NOCOPY VARCHAR2
                        , x_ret_mesg                 OUT  NOCOPY VARCHAR2
                        , p_osfm_batch_id            IN   NUMBER DEFAULT NULL  /* Added for Bug 6807835 */
                        ) IS

    l_recipe_enabled            mtl_system_items.recipe_enabled_flag%TYPE;
    l_execution_enabled         mtl_system_items.process_execution_enabled_flag%TYPE;
    l_process_enabled           mtl_parameters.process_enabled_flag%TYPE;

    BEGIN

       l_recipe_enabled            := 'N';
       l_execution_enabled         := 'N';
       l_process_enabled           := 'N';

       SELECT NVL(process_enabled_flag,'N') INTO l_process_enabled
       FROM mtl_parameters
       WHERE organization_id = p_organization_id;

       IF l_process_enabled = 'Y' THEN
         SELECT NVL(recipe_enabled_flag, 'N'), NVL(process_execution_enabled_flag, 'N')
         INTO l_recipe_enabled, l_execution_enabled
         FROM mtl_system_items
         WHERE organization_id = p_organization_id
         AND inventory_item_id = p_item_id;
      END IF;

       do_restock( p_item_id                  => p_item_id
                 , p_mbf                      => p_mbf
                 , p_handle_repetitive_item   => p_handle_repetitive_item
                 , p_repetitive_planned_item  => p_repetitive_planned_item
                 , p_qty                      => p_qty
                 , p_fixed_lead_time          => p_fixed_lead_time
                 , p_variable_lead_time       => p_variable_lead_time
                 , p_buying_lead_time         => p_buying_lead_time
                 , p_uom                      => p_uom
                 , p_accru_acct               => p_accru_acct
                 , p_ipv_acct                 => p_ipv_acct
                 , p_budget_acct              => p_budget_acct
                 , p_charge_acct              => p_charge_acct
                 , p_purch_flag               => p_purch_flag
                 , p_order_flag               => p_order_flag
                 , p_transact_flag            => p_transact_flag
                 , p_unit_price               => p_unit_price
                 , p_wip_id                   => p_wip_id
                 , p_user_id                  => p_user_id
                 , p_sysd                     => p_sysd
                 , p_organization_id          => p_organization_id
                 , p_approval                 => p_approval
                 , p_build_in_wip             => p_build_in_wip
                 , p_pick_components          => p_pick_components
                 , p_src_type                 => p_src_type
                 , p_encum_flag               => p_encum_flag
                 , p_customer_id              => p_customer_id
                 , p_customer_site_id         => p_customer_site_id
                 , p_cal_code                 => p_cal_code
                 , p_except_id                => p_except_id
                 , p_employee_id              => p_employee_id
                 , p_description              => p_description
                 , p_src_org                  => p_src_org
                 , p_src_subinv               => p_src_subinv
                 , p_subinv                   => p_subinv
                 , p_location_id              => p_location_id
                 , p_po_org_id                => p_po_org_id
                 , p_pur_revision             => p_pur_revision
                   /* calling the overloaded procedure call with 'No' for process parameters. */
                 , p_execution_enabled        => l_execution_enabled
                 , p_recipe_enabled           => l_recipe_enabled
                 , p_process_enabled          => l_process_enabled
                 , x_ret_stat                 => x_ret_stat
                 , x_ret_mesg                 => x_ret_mesg
                 , p_osfm_batch_id            => p_osfm_batch_id   /* Added for Bug 6807835 */
                 );

    END do_restock;
    /* nsinghi MIN-MAX INVCONV end */

    PROCEDURE do_restock( p_item_id                  IN   NUMBER
                        , p_mbf                      IN   NUMBER
                        , p_handle_repetitive_item   IN   NUMBER
                        , p_repetitive_planned_item  IN   VARCHAR2
                        , p_qty                      IN   NUMBER
                        , p_fixed_lead_time          IN   NUMBER
                        , p_variable_lead_time       IN   NUMBER
                        , p_buying_lead_time         IN   NUMBER
                        , p_uom                      IN   VARCHAR2
                        , p_accru_acct               IN   NUMBER
                        , p_ipv_acct                 IN   NUMBER
                        , p_budget_acct              IN   NUMBER
                        , p_charge_acct              IN   NUMBER
                        , p_purch_flag               IN   VARCHAR2
                        , p_order_flag               IN   VARCHAR2
                        , p_transact_flag            IN   VARCHAR2
                        , p_unit_price               IN   NUMBER
                        , p_wip_id                   IN   NUMBER
                        , p_user_id                  IN   NUMBER
                        , p_sysd                     IN   DATE
                        , p_organization_id          IN   NUMBER
                        , p_approval                 IN   NUMBER
                        , p_build_in_wip             IN   VARCHAR2
                        , p_pick_components          IN   VARCHAR2
                        , p_src_type                 IN   NUMBER
                        , p_encum_flag               IN   VARCHAR2
                        , p_customer_id              IN   NUMBER
                        , p_customer_site_id         IN   NUMBER
                        , p_cal_code                 IN   VARCHAR2
                        , p_except_id                IN   NUMBER
                        , p_employee_id              IN   NUMBER
                        , p_description              IN   VARCHAR2
                        , p_src_org                  IN   NUMBER
                        , p_src_subinv               IN   VARCHAR2
                        , p_subinv                   IN   VARCHAR2
                        , p_location_id              IN   NUMBER
                        , p_po_org_id                IN   NUMBER
                        , p_pur_revision             IN   NUMBER
/* nsinghi MIN-MAX INVCONV start */
                        , p_execution_enabled        IN   VARCHAR2
                        , p_recipe_enabled           IN   VARCHAR2
                        , p_process_enabled          IN   VARCHAR2
/* nsinghi MIN-MAX INVCONV end */
                        , x_ret_stat                 OUT  NOCOPY VARCHAR2
                        , x_ret_mesg                 OUT  NOCOPY VARCHAR2
                        , p_osfm_batch_id            IN   NUMBER DEFAULT NULL  /* Added for Bug 6807835 */
                        ) IS
        l_proc_name        CONSTANT VARCHAR2(30) := 'DO_RESTOCK';
        l_msg              VARCHAR2(1000);
        l_need_by_date     DATE;
        l_ret_value        VARCHAR2(200);
        move_ord_exc       EXCEPTION;
        requisition_exc    EXCEPTION;
        l_ret_stat         VARCHAR2(1);
        l_msg_count        NUMBER;
        l_msg_data         VARCHAR2(1000);
        l_mo_header_id     NUMBER;
        l_trolin_tbl       INV_Move_Order_PUB.Trolin_Tbl_Type;
        l_trolin_val_tbl   INV_Move_Order_PUB.Trolin_Val_Tbl_Type;
        l_trohdr_tbl       INV_Move_Order_PUB.Trolin_Tbl_Type;
        l_trohdr_val_tbl   INV_Move_Order_PUB.Trolin_Val_Tbl_Type;
        l_x_trolin_tbl     INV_Move_Order_PUB.Trolin_Tbl_Type;
        l_x_trohdr_val_tbl INV_Move_Order_PUB.Trolin_Val_Tbl_Type;
        l_x_trohdr_tbl     INV_Move_Order_PUB.Trolin_Tbl_Type;
        l_x_trolin_val_tbl INV_Move_Order_PUB.Trolin_Val_Tbl_Type;
        l_commit           VARCHAR2(1) := FND_API.G_TRUE;
        l_mo_line_num      NUMBER;
        l_order_count      NUMBER := 1; /* total number of lines */
        l_intransit_time   NUMBER := 0;
        l_approval         NUMBER;
        l_sourcing_date    DATE; -- This is the Date Required for MOs and Sourcing Date for Internal Requisitions.
        l_scheduled_ship_date DATE;
        l_sub_loc_id    NUMBER;
        l_location_id   NUMBER;
        l_asset_flag   NUMBER :=1 ;  -- Bug 4178417
	l_exp_acct NUMBER ;  -- Bug 4178417
	l_charge_acct NUMBER ; -- Bug 4178417
	l_dual_uom_control 	NUMBER ;
	l_secondary_qty 	NUMBER ;
	l_secondary_uom 	VARCHAR2(3) ;
    BEGIN
        SAVEPOINT sp_do_restock;
        x_ret_stat := FND_API.G_RET_STS_SUCCESS;
        x_ret_mesg := '';

        --
        -- Query debug settings, set global variables.
        -- This is done since MRP will call do_restock directly
        -- from Reorder Point report (MRPRPROP, bug 2442596).
        --

        --
        -- Bug 3174141, if Sub's location is defined use that instead of Org's.
        --

        l_location_id := p_location_id;
        If p_subinv is not null then
            begin
               select nvl(location_id,0) into l_sub_loc_id from mtl_secondary_inventories
               where secondary_inventory_name = p_subinv and organization_id = p_organization_id;
            exception
               when others then
                 print_debug('Error getting Subinventory location_id', 'do_restock', 9);
                 l_sub_loc_id := 0;
            end;

            If l_sub_loc_id <> 0 then
               l_location_id := l_sub_loc_id;
               print_debug('Subinventory location_id = ' ||to_char(l_location_id), 'do_restock', 9);
            End if;
        End if;

       -- Bug 4178417 Min Max was not calculating charge account on basis of the Subinventory to be sourced
       -- from , i.e for expense subinventories the charge account should be the expense account of the subinventory
       l_charge_acct := p_charge_acct ;

       If p_subinv is not null then
           begin
             SELECT asset_inventory,expense_account INTO l_asset_flag, l_exp_acct FROM mtl_secondary_inventories
	     WHERE secondary_inventory_name = p_subinv and organization_id = p_organization_id;
	     IF l_asset_flag = 2 AND l_exp_acct IS NOT NULL then
	        l_charge_acct := l_exp_acct ;
	     END IF;
	   exception
               when others then
                 print_debug('Error getting Subinventory Asset Information', 'do_restock', 9);
           end;
        End If ;
	-- Bug 4178417

        IF G_TRACE_ON = 1 THEN
            print_debug('Executing Do_restock with the following parameters'                 || fnd_global.local_chr(10) ||
                        '  p_item_id '                  || to_char(p_item_id)                || fnd_global.local_chr(10) ||
                        ', p_mbf: '                     || to_char(p_mbf)                    || fnd_global.local_chr(10) ||
                        ', p_handle_repetitive_item: '  || to_char(p_handle_repetitive_item) || fnd_global.local_chr(10) ||
                        ', p_repetitive_planned_item: ' || p_repetitive_planned_item         || fnd_global.local_chr(10) ||
                        ', p_qty: '                     || to_char(p_qty)                    || fnd_global.local_chr(10) ||
                        ', p_fixed_lead_time: '         || to_char(p_fixed_lead_time)        || fnd_global.local_chr(10) ||
                        ', p_variable_lead_time: '      || to_char(p_variable_lead_time)     || fnd_global.local_chr(10) ||
                        ', p_buying_lead_time: '        || to_char(p_buying_lead_time)       || fnd_global.local_chr(10) ||
                        ', p_uom: '                     || p_uom                             || fnd_global.local_chr(10) ||
                        ', p_accru_acct: '              || to_char(p_accru_acct)             || fnd_global.local_chr(10) ||
                        ', p_ipv_acct: '                || to_char(p_ipv_acct)               || fnd_global.local_chr(10) ||
                        ', p_budget_acct: '             || to_char(p_budget_acct)            || fnd_global.local_chr(10)
                        ,  l_proc_name
                        , 9);

            print_debug('p_charge_acct: '               || to_char(l_charge_acct)            || fnd_global.local_chr(10) ||
                        ', p_purch_flag: '              || p_purch_flag                      || fnd_global.local_chr(10) ||
                        ', p_order_flag: '              || p_order_flag                      || fnd_global.local_chr(10) ||
                        ', p_transact_flag: '           || p_transact_flag                   || fnd_global.local_chr(10) ||
                        ', p_unit_price: '              || to_char(p_unit_price)             || fnd_global.local_chr(10) ||
                        ', p_wip_id: '                  || to_char(p_wip_id)                 || fnd_global.local_chr(10) ||
                        ', p_user_id: '                 || to_char(p_user_id)                || fnd_global.local_chr(10) ||
                        ', p_sysd: '                    || to_char(p_sysd, 'DD-MON-YYYY HH24:MI:SS') || fnd_global.local_chr(10) ||
                        ', p_organization_id: '         || to_char(p_organization_id)        || fnd_global.local_chr(10) ||
                        ', p_approval: '                || to_char(p_approval)               || fnd_global.local_chr(10) ||
                        ', p_build_in_wip: '            || p_build_in_wip                    || fnd_global.local_chr(10) ||
                        ', p_pick_components: '         || p_pick_components                 || fnd_global.local_chr(10) ||
                        ', p_src_type: '                || to_char(p_src_type)               || fnd_global.local_chr(10)
                        ,  l_proc_name
                        , 9);

            print_debug('p_encum_flag: '                || p_encum_flag                      || fnd_global.local_chr(10) ||
                        ', p_customer_id: '             || to_char(p_customer_id)            || fnd_global.local_chr(10) ||
                        ', p_customer_site_id: '        || to_char(p_customer_site_id)       || fnd_global.local_chr(10) ||
                        ', p_cal_code: '                || p_cal_code                        || fnd_global.local_chr(10) ||
                        ', p_except_id: '               || to_char(p_except_id)              || fnd_global.local_chr(10) ||
                        ', p_employee_id: '             || to_char(p_employee_id)            || fnd_global.local_chr(10) ||
                        ', p_description: '             || p_description                     || fnd_global.local_chr(10) ||
                        ', p_src_org: '                 || to_char(p_src_org)                || fnd_global.local_chr(10) ||
                        ', p_src_subinv: '              || p_src_subinv                      || fnd_global.local_chr(10) ||
                        ', p_subinv: '                  || p_subinv                          || fnd_global.local_chr(10) ||
                        ', l_location_id: '             || to_char(l_location_id)            || fnd_global.local_chr(10) ||
                        ', p_po_org_id: '               || to_char(p_po_org_id)              || fnd_global.local_chr(10) ||
                        ', p_pur_revision: '            || to_char(p_pur_revision)           || fnd_global.local_chr(10) ||
                        ', p_osfm_batch_id: '           || to_char(p_osfm_batch_id)          || fnd_global.local_chr(10)
                        ,  l_proc_name
                        , 9);
        END IF;

        IF p_qty <= 0 THEN
            RETURN;
        END IF;

        IF (p_repetitive_planned_item = 'Y' AND p_handle_repetitive_item = 1) OR
           (p_repetitive_planned_item = 'N' AND p_mbf = 2)THEN
            --
            -- Lead time for buy items is sum of PREPROCESSING_LEAD_TIME
            -- AND PROCESSING_LEAD_TIME (sub level) OR PREPROCESSING_LEAD_TIME
            -- AND FULL_LEAD_TIME (org level)
            --
            -- Here, total lead time is the total buying Lead time
            --
            SELECT c1.calendar_date
            INTO l_sourcing_date
            FROM bom_calendar_dates c1,
                   bom_calendar_dates c
            WHERE  c1.calendar_code    = c.calendar_code
            AND  c1.exception_set_id = c.exception_set_id
            AND  c1.seq_num          = (c.next_seq_num + trunc(p_buying_lead_time))
            AND  c.calendar_code     = p_cal_code
            AND  c.exception_set_id  = p_except_id
            AND  c.calendar_date     = trunc(sysdate);

            IF G_TRACE_ON = 1 THEN
              print_debug('Sourcing Date is:'|| l_sourcing_date
                          ,  l_proc_name
                          , 9);
            END IF;
            l_need_by_date := l_sourcing_date;
            --
            -- Min Max Lead time Enhancement.
            -- If source type is Inventory then
            --   Call the newly added private procedure to calculate the intransit time.
            --   Add intransit time to p_buying_lead_time to calculate l_needby_date
            -- End if;
            --
            IF p_src_type =1 THEN
                IF G_TRACE_ON = 1 THEN
                   print_debug('Calling get_intransit_time '
                               ,  l_proc_name
                               , 9);
                END IF;
                get_intransit_time ( x_return_status      => l_ret_stat
                               , x_msg_count           => l_msg_count
                               , x_msg_data            => l_msg_data
                               , x_intransit_time      => l_intransit_time
                               , x_scheduled_ship_date => l_scheduled_ship_date
                               , p_organization_id     => p_organization_id
                               , p_subinv              => p_subinv
                               , p_to_customer_site_id => p_customer_site_id
                               , p_src_org             => p_src_org
                               , p_src_subinv          => p_src_subinv
                               , p_item_id             => p_item_id
                               , p_sourcing_date       => l_sourcing_date);


                IF l_ret_stat = FND_API.G_RET_STS_ERROR  THEN
                   IF G_TRACE_ON = 1 THEN
                      print_debug('INV_Minmax_PVT.get_lead_time failed with unexpected error returning message: ' || l_msg_data
                             , l_proc_name
                             , 9);
                    END IF;
                    RAISE requisition_exc;
                ELSIF l_ret_stat = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                    IF G_TRACE_ON = 1 THEN
                       print_debug('INV_Minmax_PVT.get_lead_time failed with expected error returning message: ' || l_msg_data
                            , l_proc_name
                            , 9);
                    END IF;
                    RAISE requisition_exc;
                ELSE
                    IF G_TRACE_ON = 1 THEN
                       print_debug('INV_Minmax_PVT.get_lead_time returned success with Intransit Time and Scheduled Ship Date '|| l_intransit_time ||' and  '||l_scheduled_ship_date
                            , l_proc_name
                            , 9);
                    END IF;
                    --
                    -- Add the intransit Time to Scheduled Ship Date toarrive at Need By Date.
                    -- and find the next calendar date corresponding to this Need By Date.
                    --
                    l_need_by_date := l_scheduled_ship_date + l_intransit_time;

                    IF G_TRACE_ON = 1 THEN
                           print_debug('Need by date after adding intransit Time : ' || to_char(l_need_by_date,'DD-MON-YYYY HH24:MI:SS')
                          ,  l_proc_name
                          , 9);
                    END IF;

                    --
                    -- kkoothan Fix for Bug 2795828.
                    -- Passed appropriate message to the Report if BOM calender returns exception.
                    --
                    BEGIN
                      SELECT c1.calendar_date
                      INTO l_need_by_date
                      FROM bom_calendar_dates c1,
                           bom_calendar_dates c
                      WHERE  c1.calendar_code  = c.calendar_code
                      AND  c1.exception_set_id = c.exception_set_id
                      AND  c1.seq_num          = (c.next_seq_num)
                      AND  c.calendar_code     = p_cal_code
                      AND  c.exception_set_id  = p_except_id
                      AND  c.calendar_date     = trunc(l_need_by_date);
                    EXCEPTION
                     WHEN others THEN
                        IF G_TRACE_ON = 1 THEN
                        print_debug('Exception occured in BOM Calendar'
                                    , l_proc_name
                                    , 9);
                        END IF;
                        x_ret_mesg := 'Exception occured in BOM Calendar';
                        x_ret_stat := fnd_api.g_ret_sts_error;
                        RETURN;
                    END;

                    IF G_TRACE_ON = 1 THEN
                       print_debug('Final Need by date: ' || to_char(l_need_by_date,'DD-MON-YYYY HH24:MI:SS')
                             ,  l_proc_name
                           , 9);
                    END IF;
                END IF;
            END IF; -- Source Type is 'Inventory'


            IF p_src_type = 3 THEN
                IF p_transact_flag = 'Y' THEN
                    BEGIN
                       --
                       -- Replenishment Move Order Consolidation
                       -- Replace the call to INV_Create_Move_Order_PVT.Create_Move_Orders with
                       -- a call to INV_MMX_WRAPPER_PVT.get_move_order_info to get the correct header ID
                       -- and Line Number.
                       -- Then call INV_Move_Order_PUB.Create_Move_Order_Lines to create a single move order line
                       -- for the current item. For the input record p_trolin_tbl, use the header ID returned by
                       -- get_move_order_header_id.
                       --
                       -- the profile value set at the  profile "INV: Minmax Reorder Approval"
                       -- This profile can have 3 values:
                       -- (Lookup Type 'MTL_REQUISITION_APPROVAL' defined in MFG_LOOKUPS)
                       --  1- Pre-approve d
                       --  2- Pre-approve move orders only
                       --  3- Approval Required
                       -- Converting these codes to the ones defined in MFG_LOOKUPS under the
                       -- lookup type'MTL_TXN_REQUEST_STATUS'.
                       --  IF  l_approval = 3  THEN
                       --    l_approval := 1; -- Incomplete
                       --  ELSE
                       --    l_approval := 7; -- Pre-approved
                       --  END IF;
                       --

                       IF  p_approval = 3  THEN
                         l_approval := 1; -- Incomplete
                       ELSE
                         l_approval := 7; -- Pre Approved
                       END IF;


                       IF G_TRACE_ON = 1 THEN
                       print_debug('Approval Status is: '||l_approval
                                ,  l_proc_name
                                , 9);
                       print_debug('Calling INV_MMX_WRAPPER_PVT.get_move_order_info'
                                ,  l_proc_name
                                , 9);
                       END IF;

                       INV_MMX_WRAPPER_PVT.get_move_order_info(x_return_status        => l_ret_stat
                                                             , x_msg_count            => l_msg_count
                                                             , x_msg_data             => l_msg_data
                                                             , x_move_order_header_ID => l_mo_header_id
                                                             , x_move_order_line_num  => l_mo_line_num
                                                             , p_user_id              => p_user_id
                                                             , p_organization_id      => p_organization_id
                                                             , p_subinv               => p_subinv
                                                             , p_src_subinv           => p_src_subinv
                                                             , p_approval             => l_approval
                                                             , p_need_by_date         => l_need_by_date
                                                              );
                       IF l_ret_stat = FND_API.G_RET_STS_ERROR  THEN
                         IF G_TRACE_ON = 1 THEN
                         print_debug('INV_MMX_WRAPPER_PVT.get_move_order_info failed with unexpected error returning message: ' || l_msg_data
                                      , l_proc_name
                                      , 9);
                         END IF;
                         RAISE fnd_api.g_exc_unexpected_error;
                       ELSIF l_ret_stat = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                         IF G_TRACE_ON = 1 THEN
                         print_debug('INV_MMX_WRAPPER_PVT.get_move_order_info failed with expected error returning message: ' || l_msg_data
                                     , l_proc_name
                                     , 9);
                         END IF;
                         RAISE fnd_api.g_exc_error;
                       ELSE
                         IF G_TRACE_ON = 1 THEN
                         print_debug('INV_MMX_WRAPPER_PVT.get_move_order_info returned success with MO Header Id and MO Line Number '|| fnd_global.local_chr(10) || l_mo_header_id ||' and '|| l_mo_line_num
                                     , l_proc_name
                                     , 9);
                         END IF;
                       END IF;
/* --------INVCONV changes------------------------------ */
		       /* 4004567 Instead of checking whether the item is dual uom controlled by checking if the item is defined to the org which is process enabled or not. Made change to check if the item has secondary_uom */

		       IF inv_cache.set_item_rec(p_organization_id =>p_organization_id,p_item_id => p_item_id) THEN
			  l_secondary_uom := inv_cache.item_rec.secondary_uom_code;
		       END IF;



		       IF l_secondary_uom IS NOT NULL THEN
			  l_secondary_qty := inv_convert.inv_um_convert
			    (item_id            => p_item_id
			     ,precision          => 5
			     ,from_quantity      => p_qty
			     ,from_unit          => p_uom
			     ,to_unit            => l_secondary_uom
			     ,from_name          => NULL
			     ,to_name            => NULL);
	  /* UOM conversion failure check */
	    IF l_secondary_qty < 0 THEN

		IF G_TRACE_ON = 1 THEN
		   print_debug('UOM Conversion failed in creating move order: ' || p_item_id || ', ' || p_organization_id ,  l_proc_name , 9);
		END IF;

	      RAISE move_ord_exc;
	    END IF ; /* if l_secondary_qty < 0 */


	ELSE
		l_secondary_qty := NULL ;
	END IF ;

/* ---------INVCONV Changes end-------------------------- */

                      l_trolin_tbl(l_order_count).header_id           := l_mo_header_id;
                      l_trolin_tbl(l_order_count).created_by          := p_user_id;
                      l_trolin_tbl(l_order_count).creation_date       := sysdate;
                      /* Bug# 3437350 */
                      -- l_trolin_tbl(l_order_count).date_required       := TRUNC(sysdate);
                      l_trolin_tbl(l_order_count).date_required       := l_need_by_date;
                      /* End of Bug# 3437350 */
                      l_trolin_tbl(l_order_count).from_subinventory_code     := p_src_subinv;
                      l_trolin_tbl(l_order_count).inventory_item_id  := p_item_id;
                      l_trolin_tbl(l_order_count).last_updated_by    := p_user_id;
                      l_trolin_tbl(l_order_count).last_update_date   := sysdate;
                      l_trolin_tbl(l_order_count).last_update_login  := p_user_id;
                      l_trolin_tbl(l_order_count).line_number        := l_mo_line_num;
                      l_trolin_tbl(l_order_count).line_status        := l_approval;
                      l_trolin_tbl(l_order_count).organization_id    := p_organization_id;
                      l_trolin_tbl(l_order_count).quantity           := p_qty;
                      l_trolin_tbl(l_order_count).status_date        := sysdate;
                      l_trolin_tbl(l_order_count).to_subinventory_code   := p_subinv;
                      l_trolin_tbl(l_order_count).uom_code     := p_uom;
                      l_trolin_tbl(l_order_count).transaction_type_id := INV_GLOBALS.G_TYPE_TRANSFER_ORDER_SUBXFR;
                      l_trolin_tbl(l_order_count).reference_type_code := INV_Transfer_Order_PVT.G_REF_TYPE_MINMAX;-- kkoothan For Bug Fix:2756930
                      l_trolin_tbl(l_order_count).db_flag      := FND_API.G_TRUE;
                      l_trolin_tbl(l_order_count).operation    := INV_GLOBALS.G_OPR_CREATE;
		/* ------INVCONV Change Added secondary qty and uom------ */
                      l_trolin_tbl(l_order_count).secondary_quantity  := l_secondary_qty;
                      l_trolin_tbl(l_order_count).secondary_uom       := l_secondary_uom;
		/* ------INVCONV Change Added secondary qty and uom------ */

                      IF G_TRACE_ON = 1 THEN
                      print_debug('Calling INV_Move_Order_PUB.Create_Move_Order_Lines'
                                  ,  l_proc_name
                                  , 9);
                      END IF;
                      INV_Move_Order_PUB.Create_Move_Order_Lines
                               (  p_api_version_number       => 1.0 ,
                                  p_init_msg_list            => FND_API.G_TRUE,
                                  p_commit                   => l_commit,
                                  x_return_status            => l_ret_stat,
                                  x_msg_count                => l_msg_count,
                                  x_msg_data                 => l_msg_data,
                                  p_trolin_tbl               => l_trolin_tbl,
                                  p_trolin_val_tbl           => l_trolin_val_tbl,
                                  x_trolin_tbl               => l_x_trolin_tbl,
                                  x_trolin_val_tbl           => l_x_trolin_val_tbl
                               );

                      IF l_ret_stat = FND_API.G_RET_STS_ERROR  THEN
                        IF G_TRACE_ON = 1 THEN
                        print_debug('INV_Move_Order_PUB.Create_Move_Order_Lines failed with expected error returning message: ' || l_msg_data|| l_msg_count
                                     , l_proc_name
                                     , 9);
                        END IF;
                        IF l_msg_count > 0 THEN
                                    FOR i in 1..l_msg_count
                                    LOOP
                                      l_msg := fnd_msg_pub.get(i,'F');
                                      print_debug(l_msg
                                              , l_proc_name
                                              , 9);
                                      fnd_msg_pub.delete_msg(i);
                                    END LOOP;
                        END IF;
                        RAISE fnd_api.g_exc_unexpected_error;
                      ELSIF l_ret_stat = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                        IF G_TRACE_ON = 1 THEN
                        print_debug('INV_Move_Order_PUB.Create_Move_Order_Lines failed with unexpected error returning message: ' || l_msg_data
                                    , l_proc_name
                                    , 9);
                        END IF;
                                   RAISE fnd_api.g_exc_error;
                      ELSE
                        IF G_TRACE_ON = 1 THEN
                        print_debug('INV_Move_Order_PUB.Create_Move_Order_Lines returned success'
                                    , l_proc_name
                                    , 9);
                        END IF;
                      END IF;

                      EXCEPTION
                        WHEN OTHERS THEN
                             IF G_TRACE_ON = 1 THEN
                             print_debug('Error creating move order: ' || sqlcode || ', ' || sqlerrm
                                         ,  l_proc_name
                                         , 1);
                             END IF;
                             RAISE move_ord_exc;
                      END;
                ELSE
                    IF G_TRACE_ON = 1 THEN
                      print_debug('Src type is sub, item not transactable.',  l_proc_name, 9);
                    END IF;
                    RAISE move_ord_exc;
                END IF; -- Transact Flag is 'N'

            ELSE

                re_po( p_item_id          => p_item_id
                     , p_qty              => p_qty
                     , p_nb_time          => l_need_by_date
                     , p_uom              => p_uom
                     , p_accru_acct       => p_accru_acct
                     , p_ipv_acct         => p_ipv_acct
                     , p_budget_acct      => p_budget_acct
                     , p_charge_acct      => l_charge_acct      -- Bug 4178417
                     , p_purch_flag       => p_purch_flag
                     , p_order_flag       => p_order_flag
                     , p_transact_flag    => p_transact_flag
                     , p_unit_price       => p_unit_price
                     , p_user_id          => p_user_id
                     , p_sysd             => p_sysd
                     , p_organization_id  => p_organization_id
                     , p_approval         => p_approval
                     , p_src_type         => p_src_type
                     , p_encum_flag       => p_encum_flag
                     , p_customer_id      => p_customer_id
                     , p_employee_id      => p_employee_id
                     , p_description      => p_description
                     , p_src_org          => p_src_org
                     , p_src_subinv       => p_src_subinv
                     , p_subinv           => p_subinv
                     , p_location_id      => l_location_id   -- 3174141
                     , p_po_org_id        => p_po_org_id
                     , p_pur_revision     => p_pur_revision
                     , x_ret_stat         => l_ret_stat
                     , x_ret_mesg         => x_ret_mesg);

                x_ret_stat := l_ret_stat;

            END IF;

        ELSE

            --
            -- Either a make item, or repetitive item and the user chose
            -- "Create Discrete Job"
            --
            IF G_TRACE_ON = 1 THEN
            print_debug('Calling wip_calendar.estimate_leadtime to calculate need_by_date'
                        ,  l_proc_name
                        , 9);
            END IF;

            wip_calendar.estimate_leadtime(x_org_id       => p_organization_id,
                                           x_fixed_lead   => p_fixed_lead_time,
                                           x_var_lead     => p_variable_lead_time,
                                           x_quantity     => p_qty,
                                           x_proc_days    => 0,
                                           x_entity_type  => 1,
                                           x_fusd         => p_sysd,
                                           x_fucd         => NULL,
                                           x_lusd         => NULL,
                                           x_lucd         => NULL,
                                           x_sched_dir    => 1,
                                           x_est_date     => l_need_by_date);
/* nsinghi MIN-MAX INVCONV start */
/* For process org, call needs to be made against to the GME batch API.
We need to retain the above estimate_leadtime call for both Process
and discrete as the leadtime would require to be calculated for the mtl_system_items in
the converged model. The leadtime calculated by wip_calendar.estimate_leadtime is
fixed_lead_time + (variable_lead_time * qty) which is common to process too. */


            IF p_process_enabled = 'Y' THEN

               re_batch( p_item_id     => p_item_id
                  , p_qty              => p_qty
                  , p_nb_time          => l_need_by_date
                  , p_uom              => p_uom
                  , p_organization_id  => p_organization_id
                  , p_execution_enabled => p_execution_enabled
                  , p_recipe_enabled   => p_recipe_enabled
                  , p_user_id          => p_user_id
                  , x_ret_stat         => l_ret_stat
                  , x_ret_mesg         => x_ret_mesg);

            ELSE
/* nsinghi MIN-MAX INVCONV end */

               re_wip( p_item_id          => p_item_id
                     , p_qty              => p_qty
                     , p_nb_time          => l_need_by_date
                     , p_uom              => p_uom
                     , p_wip_id           => p_wip_id
                     , p_user_id          => p_user_id
                     , p_sysd             => p_sysd
                     , p_organization_id  => p_organization_id
                     , p_approval         => p_approval
                     , p_build_in_wip     => p_build_in_wip
                     , p_pick_components  => p_pick_components
                     , x_ret_stat         => l_ret_stat
                     , x_ret_mesg         => x_ret_mesg
                     , p_osfm_batch_id    => p_osfm_batch_id   /* Added for Bug 6807835 */
                     );

            END IF;

            x_ret_stat := l_ret_stat;
        END IF;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO sp_do_restock;
         x_ret_stat := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get
                          ( p_count =>l_msg_count ,
                            p_data  => x_ret_mesg
                          );
        WHEN fnd_api.g_exc_unexpected_error THEN
          ROLLBACK TO sp_do_restock;
          x_ret_stat := fnd_api.g_ret_sts_unexp_error;
          fnd_msg_pub.count_and_get
                           ( p_count =>l_msg_count ,
                             p_data  => x_ret_mesg
                           );

        WHEN requisition_exc THEN
             ROLLBACK TO sp_do_restock;
             SELECT meaning
               INTO x_ret_mesg
               FROM mfg_lookups
              WHERE lookup_type = 'INV_MMX_RPT_MSGS'
                AND lookup_code = 1;

             x_ret_stat := FND_API.G_RET_STS_ERROR;

        WHEN move_ord_exc THEN
             ROLLBACK TO sp_do_restock;
             SELECT meaning
               INTO x_ret_mesg
               FROM mfg_lookups
              WHERE lookup_type = 'INV_MMX_RPT_MSGS'
                AND lookup_code = 5;

             x_ret_stat := FND_API.G_RET_STS_ERROR;

        WHEN others THEN
             IF G_TRACE_ON = 1 THEN
             print_debug(sqlcode || ', ' || sqlerrm,  l_proc_name, 1);
             END IF;
             RAISE;

    END do_restock;



    PROCEDURE re_po( p_item_id          IN   NUMBER
                   , p_qty              IN   NUMBER
                   , p_nb_time          IN   DATE
                   , p_uom              IN   VARCHAR2
                   , p_accru_acct       IN   NUMBER
                   , p_ipv_acct         IN   NUMBER
                   , p_budget_acct      IN   NUMBER
                   , p_charge_acct      IN   NUMBER
                   , p_purch_flag       IN   VARCHAR2
                   , p_order_flag       IN   VARCHAR2
                   , p_transact_flag    IN   VARCHAR2
                   , p_unit_price       IN   NUMBER
                   , p_user_id          IN   NUMBER
                   , p_sysd             IN   DATE
                   , p_organization_id  IN   NUMBER
                   , p_approval         IN   NUMBER
                   , p_src_type         IN   NUMBER
                   , p_encum_flag       IN   VARCHAR2
                   , p_customer_id      IN   NUMBER
                   , p_employee_id      IN   NUMBER
                   , p_description      IN   VARCHAR2
                   , p_src_org          IN   NUMBER
                   , p_src_subinv       IN   VARCHAR2
                   , p_subinv           IN   VARCHAR2
                   , p_location_id      IN   NUMBER
                   , p_po_org_id        IN   NUMBER
                   , p_pur_revision     IN   NUMBER
                   , x_ret_stat         OUT  NOCOPY VARCHAR2
                   , x_ret_mesg         OUT  NOCOPY VARCHAR2) IS

        l_item_rev_ctl   NUMBER := 0;
        l_item_revision  VARCHAR2(4) := '@@@';
        l_orgn_id        NUMBER := p_organization_id;

	l_unit_of_issue  VARCHAR2(3); -- For Bug 3894347
	l_check_uom	 NUMBER;      -- For Bug 3894347
	l_qty_conv       NUMBER;      -- For Bug 3894347

        po_exc           EXCEPTION;

    BEGIN
        IF G_TRACE_ON = 1 THEN
            print_debug('p_item_id: '           || to_char(p_item_id)         ||
                        ', p_qty: '             || to_char(p_qty)             ||
                        ', p_nb_time:'          || to_char(p_nb_time, 'DD-MON-YYYY HH24:MI:SS') ||
                        ', p_uom: '             || p_uom                      ||
                        ', p_accru_acct: '      || to_char(p_accru_acct)      ||
                        ', p_ipv_acct: '        || to_char(p_ipv_acct)        ||
                        ', p_budget_acct: '     || to_char(p_budget_acct)     ||
                        ', p_charge_acct: '     || to_char(p_charge_acct)     ||
                        ', p_purch_flag: '      || p_purch_flag               ||
                        ', p_order_flag: '      || p_order_flag               ||
                        ', p_transact_flag: '   || p_transact_flag            ||
                        ', p_unit_price: '      || to_char(p_unit_price)      ||
                        ', p_user_id: '         || to_char(p_user_id)         ||
                        ', p_sysd: '            || to_char(p_sysd, 'DD-MON-YYYY HH24:MI:SS')
                        , 're_po'
                        , 9);

            print_debug('p_organization_id:   ' || to_char(p_organization_id) ||
                        ', p_approval: '        || to_char(p_approval)        ||
                        ', p_src_type: '        || to_char(p_src_type)        ||
                        ', p_encum_flag: '      || p_encum_flag               ||
                        ', p_customer_id: '     || to_char(p_customer_id)     ||
                        ', p_employee_id: '     || to_char(p_employee_id)     ||
                        ', p_description: '     || p_description              ||
                        ', p_src_org: '         || to_char(p_src_org)         ||
                        ', p_src_subinv: '      || p_src_subinv               ||
                        ', p_subinv: '          || p_subinv                   ||
                        ', p_location_id: '     || to_char(p_location_id)     ||
                        ', p_po_org_id: '       || to_char(p_po_org_id)       ||
                        ', p_pur_revision: '    || to_char(p_pur_revision)
                        , 're_po'
                        , 9);
        END IF;

        --
        -- Do not create a requisition if any of the following apply:
        -- 1. Source type (Inventory/Supplier/Subinventory) is not specified
        -- 2. Item is not transactable
        -- 3. Source type is Inventory (1) but "Internal Orders Enabled"
        --    is not checked
        -- 4. Source type is Supplier (2) but "Purchasable" flag unchecked
        --
        IF (p_src_type IS NULL)
           OR
           (p_transact_flag <> 'Y')
           OR
           (p_src_type = 1 AND p_order_flag <> 'Y')
           OR
           (p_src_type = 2 AND p_purch_flag <> 'Y')
        THEN
            IF G_TRACE_ON = 1 THEN
            print_debug('Null src type or invalid transact_flag, order_flag or purch_flag'
                        , 're_po', 9);
            END IF;
            RAISE po_exc;
        END IF;

        IF (p_charge_acct IS NULL)
            OR (p_accru_acct IS NULL)
            OR (p_ipv_acct IS NULL)
            OR ((p_encum_flag <> 'N') AND (p_budget_acct is NULL))
        THEN
            IF G_TRACE_ON = 1 THEN
            print_debug('Charge/accrual/IPV/budget accts not setup correctly.', 're_po', 9);
            END IF;
            RAISE po_exc;
        END IF;

        IF NVL(p_customer_id,0) < 0
        THEN
            IF G_TRACE_ON = 1 THEN
            print_debug('Invalid customer ID: ' || to_char(p_customer_id), 're_po', 9);
            END IF;
            RAISE po_exc;
        END IF;


        /* Fix for bug 774532. To get the item revisions, IF profile is Yes
           OR IF profile is NULL AND item is revision controlled */

        --
        -- Bug 2323099:
        -- We should only specify a revision if the item is revision-controlled
        -- and the profile "INV:Purchasing By Revision" is set to yes
        --
        -- p_pur_revision will never be NULL - this is handled in the
        -- BEFORE-REPORT trigger of INVISMMX.
        --

        IF p_pur_revision = 1
        THEN
            SELECT revision_qty_control_code
              INTO l_item_rev_ctl
              FROM mtl_system_items msi
             WHERE msi.organization_id   = l_orgn_id
               AND msi.inventory_item_id = p_item_id;

            IF G_TRACE_ON = 1 THEN
            print_debug('Rev ctl: ' || to_char(l_item_rev_ctl), 're_po', 9);
            END IF;

	/*    Commented for ER 6698138
		  IF l_item_rev_ctl = 2 THEN
	*/
                SELECT MAX(revision)
                  INTO l_item_revision
                  FROM mtl_item_revisions mir
                 WHERE inventory_item_id = p_item_id
                   AND organization_id   = l_orgn_id
                   AND effectivity_date  < SYSDATE
                   AND implementation_date is not null        /* Added for Bug 7110794 */
                   AND effectivity_date  =
                       (
                        SELECT MAX(effectivity_date)
                          FROM mtl_item_revisions mir1
                         WHERE mir1.inventory_item_id = mir.inventory_item_id
                           AND mir1.organization_id   = mir.organization_id
                           AND implementation_date is not null        /* Added for Bug 7110794 */
                           AND effectivity_date       < SYSDATE
                       );
	/*    Commented for ER 6698138
		    END IF;
	*/

            IF G_TRACE_ON = 1 THEN
            print_debug('Item rev: ' || l_item_revision, 're_po', 9);
            END IF;
        END IF ;

/* Changes for Bug 3894347 */
	l_check_uom := 0;

	select uom_code
	into l_unit_of_issue
	from mtl_system_items_vl msiv , mtl_units_of_measure_vl muom
	where msiv.inventory_item_id = p_item_id
	and msiv.organization_id = p_organization_id
	and muom.unit_of_measure = NVL(msiv.unit_of_issue,msiv.primary_unit_of_measure);

        IF G_TRACE_ON = 1 THEN
	print_debug('l_unit_of_issue: '||l_unit_of_issue, 're_po', 9);
        END IF;

	IF ( l_unit_of_issue <> p_uom) THEN

	  IF G_TRACE_ON = 1 THEN
	    print_debug('p_item_id: '           	  || to_char(p_item_id)         ||
                        ', p_qty: '              	  || to_char(p_qty)             ||
                        ', p_organization_id: '           || to_char(p_organization_id) ||
                        ', p_uom: '             	  || p_uom                      ||
              		', l_unit_of_issue: '             || l_unit_of_issue
			, 're_po'
                        , 9);
          END IF;

	   l_qty_conv := INV_CONVERT.INV_UM_CONVERT(
	            item_id => p_item_id,
	            precision => null,
	            from_quantity => p_qty,
	            from_unit => p_uom,
	            to_unit => l_unit_of_issue,
	            from_name => null,
	            to_name => null);

        IF G_TRACE_ON = 1 THEN
	print_debug('l_qty_conv = ' || to_char(l_qty_conv), 're_po', 9);
        END IF;

	l_check_uom := 1;

	END IF;
/* End of Changes for Bug 3894347 */

        IF G_TRACE_ON = 1 THEN
        print_debug('Inserting into PO_REQUISITIONS_INTERFACE_ALL', 're_po', 9);
        END IF;

        INSERT INTO po_requisitions_interface_all(
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            ITEM_DESCRIPTION,
            CREATION_DATE,
            CREATED_BY,
            PREPARER_ID,
            INTERFACE_SOURCE_CODE,
            REQUISITION_TYPE,
            AUTHORIZATION_STATUS,
            SOURCE_TYPE_CODE,
            SOURCE_ORGANIZATION_ID,
            SOURCE_SUBINVENTORY,
            DESTINATION_ORGANIZATION_ID,
            DESTINATION_SUBINVENTORY,
            DELIVER_TO_REQUESTOR_ID,
            DESTINATION_TYPE_CODE,
            UOM_CODE,
            DELIVER_TO_LOCATION_ID,
            ITEM_ID,
            ITEM_REVISION,
            QUANTITY,
            NEED_BY_DATE,
            GL_DATE,
            CHARGE_ACCOUNT_ID,
            ACCRUAL_ACCOUNT_ID,
            VARIANCE_ACCOUNT_ID,
            BUDGET_ACCOUNT_ID,
            AUTOSOURCE_FLAG,
            ORG_ID)
        VALUES (
            sysdate,
            p_user_id,
            p_description,
            sysdate,
            p_user_id,
            p_employee_id,
            'INV',
            DECODE(p_src_type, 1, 'INTERNAL',  'PURCHASE'),
            DECODE(p_approval, 1, 'APPROVED','INCOMPLETE'),
            DECODE(p_src_type, 1, 'INVENTORY',  'VENDOR'),
            p_src_org,
            p_src_subinv,
            p_organization_id,
            p_subinv,
            p_employee_id,
            'INVENTORY',
            DECODE(l_check_uom,1,l_unit_of_issue,p_uom), --  Bug 3894347
            p_location_id,
            p_item_id,
            DECODE(l_item_revision,'@@@',NULL,l_item_revision),
            DECODE(l_check_uom,1,l_qty_conv,p_qty),	 --  Bug 3894347
            (trunc(p_nb_time) + 1 - (1/(24*60*60))),
            SYSDATE,
            p_charge_acct,
            p_accru_acct,
            p_ipv_acct,
            p_budget_acct,
            'P',
            p_po_org_id);

        x_ret_stat := FND_API.G_RET_STS_SUCCESS;
        x_ret_mesg := '';

    EXCEPTION
        WHEN OTHERS THEN
            IF G_TRACE_ON = 1 THEN
            print_debug(sqlcode || ', ' || sqlerrm, 're_po', 1);
            END IF;

            SELECT meaning
              INTO x_ret_mesg
              FROM mfg_lookups
             WHERE lookup_type = 'INV_MMX_RPT_MSGS'
               AND lookup_code = 1;

            x_ret_stat := FND_API.G_RET_STS_ERROR;
    END re_po;



    PROCEDURE re_wip( p_item_id          IN   NUMBER
                    , p_qty              IN   NUMBER
                    , p_nb_time          IN   DATE
                    , p_uom              IN   VARCHAR2
                    , p_wip_id           IN   NUMBER
                    , p_user_id          IN   NUMBER
                    , p_sysd             IN   DATE
                    , p_organization_id  IN   NUMBER
                    , p_approval         IN   NUMBER
                    , p_build_in_wip     IN   VARCHAR2
                    , p_pick_components  IN   VARCHAR2
                    , x_ret_stat         OUT  NOCOPY VARCHAR2
                    , x_ret_mesg         OUT  NOCOPY VARCHAR2
                    , p_osfm_batch_id    IN   NUMBER DEFAULT NULL    /* Added for Bug 6807835 */
                    ) IS

        wip_exc  EXCEPTION;
        /* Added for Bug 6807835 */

        l_header_id                                  NUMBER := NULL;
        l_mode_flag                                 NUMBER := NULL;
        l_job_name                                  VARCHAR2(255);
        l_first_unit_start_date                DATE;
        l_last_unit_completion_date    DATE;
        l_scheduling_method                NUMBER := 2;
        l_cfm_flag                                     NUMBER;
        l_osfm_batch_id                         NUMBER;
        l_is_lot_control                            VARCHAR2(1) := NULL;

        /* End of changes for Bug 6807835 */


    BEGIN
        IF G_TRACE_ON = 1 THEN
            print_debug('p_item_id: '           || to_char(p_item_id)         ||
                        ', p_qty: '             || to_char(p_qty)             ||
                        ', p_nb_time: '         || to_char(p_nb_time, 'DD-MON-YYYY HH24:MI:SS') ||
                        ', p_uom: '             || p_uom                      ||
                        ', p_wip_id: '          || to_char(p_wip_id)          ||
                        ', p_user_id: '         || to_char(p_user_id)         ||
                        ', p_sysd: '            || to_char(p_sysd, 'DD-MON-YYYY HH24:MI:SS')    ||
                        ', p_organization_id: ' || to_char(p_organization_id) ||
                        ', p_approval: '        || to_char(p_approval)        ||
                        ', p_build_in_wip: '    || p_build_in_wip             ||
                        ', p_pick_components: ' || p_pick_components          ||
                        ', p_osfm_batch_id: '   || p_osfm_batch_id
                        , 're_wip'
                        , 9);
        END IF;

        /* Added for Bug 6807835 */

        IF(to_number(NVL(FND_PROFILE.VALUE('WSM_CREATE_LBJ_COPY_ROUTING'),0)) = 1 ) THEN
           l_scheduling_method := 1;
        ELSE
           l_scheduling_method := 2;
        END IF;
        select wsm_lot_sm_ifc_header_s.nextval
        into l_header_id
        from dual;

        l_mode_flag := 1;

        select FND_Profile.value('WIP_JOB_PREFIX')||wip_job_number_s.nextval
        INTO l_job_name
        from dual;

        print_debug('OSFM Job Name '||l_job_name
                        , 're_wip', 9);

        IF p_nb_time IS NOT NULL THEN
           l_first_unit_start_date := NULL;
           l_last_unit_completion_date := p_nb_time;

        ELSE
           l_first_unit_start_date :=  SYSDATE;
           l_last_unit_completion_date := NULL;
        END IF;

        BEGIN
           select nvl(cfm_routing_flag,0) into l_cfm_flag
           from BOM_OPERATIONAL_ROUTINGS
           where assembly_item_id = p_item_id
           AND organization_id  = p_organization_id
           AND alternate_routing_designator is NULL;
        EXCEPTION
           when NO_DATA_FOUND then
              l_cfm_flag := 2;
           when others then
              RAISE wip_exc;
        END;

        /* End of changes for Bug 6807835 */

        IF p_build_in_wip <> 'Y' OR p_pick_components <> 'N'
        THEN
            IF G_TRACE_ON = 1 THEN
            print_debug('Item either not build_in_wip or has pick components flag checked'
                        , 're_wip', 9);
            END IF;
            RAISE wip_exc;
        /* Added for Bug 6807835 */
        ELSIF (l_cfm_flag = 3) AND (wsmpvers.get_osfm_release_version > '110509')
         THEN
           BEGIN
              SELECT 'Y' INTO l_is_lot_control
              FROM dual
              WHERE exists
                 (SELECT 1 FROM mtl_system_items
                   WHERE organization_id = p_organization_id
                   AND inventory_item_id = p_item_id
                   AND lot_control_code = 2);
           EXCEPTION
              WHEN OTHERS THEN
                l_is_lot_control := 'N';
           END;

           IF (p_osfm_batch_id is null) THEN

             --
             --  Set L_OSFM_BATCH_ID to the next Sequence of WSM_LOT_JOB_INTERFACE_S.
             --

             BEGIN
                 SELECT WSM_LOT_JOB_INTERFACE_S.NEXTVAL
                   INTO l_osfm_batch_id
                   FROM SYS.DUAL;
             EXCEPTION
                  WHEN no_data_found  THEN
                    IF G_TRACE_ON = 1 THEN
                      print_debug('Exception: WSM_LOT_JOB_INTERFACE_S.NEXTVAL is not defined'
                          , 're_wip'
                          , 9);
                    END IF;
                    RAISE  wip_exc;
             END;
           ELSE
                l_osfm_batch_id := p_osfm_batch_id;
           END IF;

           IF G_TRACE_ON = 1 THEN
              print_debug('OSFM Batch Id is: ' || l_osfm_batch_id
               , 're_wip'
                , 9);
           END IF;


           IF l_is_lot_control = 'Y' THEN
              INSERT INTO WSM_LOT_JOB_INTERFACE (
                       mode_flag,
                       last_update_date,
                       last_updated_by,
                       creation_date,
                       created_by,
                       last_update_login,
                       group_id,
                       source_line_id,
                       organization_id,
                       load_type,
                       status_type,
                       primary_item_id,
                       job_name,
                       start_Quantity,
                       process_Status,
                       first_unit_start_date,
                       last_unit_completion_date,
                       scheduling_method,
                       completion_subinventory,
                       completion_locator_id,
                       class_code,
                       description,
                       bom_revision_date,
                       routing_revision_date,
                       header_id)
              VALUES  (
                        1,
                        sysdate,
                        fnd_global.user_id,
                        sysdate,
                        fnd_global.user_id,
                        fnd_global.login_id,
                        l_osfm_batch_id,
                        Decode(l_mode_flag, 1,null,l_header_id),
                        p_organization_id,
                        5, --job creation
                        3, --1:unreleased, 3: released
                        p_item_id,
                        l_job_name,
                        p_qty,
                        1,
                        l_first_unit_start_date,
                        l_last_unit_completion_date,
                        l_scheduling_method,
                        null,
                        null,
                        '',
                        null,
                        '',
                        '',
                        l_header_id);

          ELSE     -- l_is_lot_control = 'Y'
             IF G_TRACE_ON = 1 THEN
               print_debug('Inserting into WIP_JOB_SCHEDULE_INTERFACE', 're_wip', 9);
             END IF;
              INSERT INTO WIP_JOB_SCHEDULE_INTERFACE(
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        GROUP_ID,
                        PROCESS_PHASE,
                        PROCESS_STATUS,
                        ORGANIZATION_ID,
                        LOAD_TYPE,
                        LAST_UNIT_COMPLETION_DATE,
                        PRIMARY_ITEM_ID,
                        START_QUANTITY,STATUS_TYPE)
              VALUES(
                        p_sysd,
                        p_user_id,
                        p_sysd,
                        p_user_id,
                        p_wip_id,
                        2,
                        1,
                        p_organization_id,
                        1,
                        p_nb_time,
                        p_item_id,
                        p_qty,
                        DECODE(p_approval,1,3,1));

           END IF;   --  end of  l_is_lot_control = 'Y'

           /* End of changes for 6807835 */

        ELSE
            IF G_TRACE_ON = 1 THEN
            print_debug('Inserting into WIP_JOB_SCHEDULE_INTERFACE', 're_wip', 9);
            END IF;
            INSERT INTO WIP_JOB_SCHEDULE_INTERFACE(
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                GROUP_ID,
                PROCESS_PHASE,
                PROCESS_STATUS,
                ORGANIZATION_ID,
                LOAD_TYPE,
                LAST_UNIT_COMPLETION_DATE,
                PRIMARY_ITEM_ID,
                START_QUANTITY,STATUS_TYPE)
            VALUES(
               p_sysd,
               p_user_id,
               p_sysd,
               p_user_id,
               p_wip_id,
               2,
               1,
               p_organization_id,
               1,
               p_nb_time,
               p_item_id,
               p_qty,
               DECODE(p_approval,1,3,1));
        END IF;

        x_ret_stat := FND_API.G_RET_STS_SUCCESS;
        x_ret_mesg := '';

    EXCEPTION
        WHEN OTHERS THEN
            IF G_TRACE_ON = 1 THEN
            print_debug(sqlcode || ', ' || sqlerrm, 're_wip', 1);
            END IF;

            SELECT meaning
              INTO x_ret_mesg
              FROM mfg_lookups
             WHERE lookup_type = 'INV_MMX_RPT_MSGS'
               AND lookup_code = 2;

            x_ret_stat := FND_API.G_RET_STS_ERROR;
    END re_wip;
--
/* nsinghi MIN-MAX INVCONV start */

    PROCEDURE re_batch( p_item_id          IN   NUMBER
                    , p_qty              IN   NUMBER
                    , p_nb_time          IN   DATE
                    , p_uom              IN   VARCHAR2
                    , p_organization_id  IN   NUMBER
                    , p_execution_enabled IN VARCHAR2
                    , p_recipe_enabled   IN VARCHAR2
                    , p_user_id          IN NUMBER
                    , x_ret_stat         OUT  NOCOPY VARCHAR2
                    , x_ret_mesg         OUT  NOCOPY VARCHAR2) IS


        l_gme_batch_header GME_BATCH_HEADER%ROWTYPE;
        l_eff_id        NUMBER(15);
        batch_exc       EXCEPTION;
        x_message_count NUMBER;
        x_message_list  VARCHAR2(1000);
        return_status   VARCHAR2(1000);
        x_gme_batch_header gme_batch_header%ROWTYPE;
        x_exception_material_tbl gmp_batch_wrapper_pkg.exceptions_tab;

    BEGIN

        IF G_TRACE_ON = 1 THEN
            print_debug('p_item_id: '           || to_char(p_item_id)         ||
                        ', p_qty: '             || to_char(p_qty)             ||
                        ', p_nb_time: '         || to_char(p_nb_time, 'DD-MON-YYYY HH24:MI:SS') ||
                        ', p_uom: '             || p_uom                      ||
                        ', p_organization_id: ' || to_char(p_organization_id)
                        , 're_wip'
                        , 9);
        END IF;

        IF p_execution_enabled <> 'Y' OR p_recipe_enabled <> 'Y'
        THEN
            IF G_TRACE_ON = 1 THEN
            print_debug('Item either not Execution Enabled or not Recipe Enabled'
                        , 're_batch', 9);
            END IF;
            RAISE batch_exc;
        ELSE
              fnd_profile.initialize(p_user_id);

              l_gme_batch_header.organization_id := p_organization_id;
              l_gme_batch_header.plan_cmplt_date := p_nb_time;
              l_gme_batch_header.due_date := p_nb_time;
              l_gme_batch_header.batch_type := 0; /* 0 for batches, 10 for FPOs */
              l_gme_batch_header.update_inventory_ind := 'Y' ;
--              l_gme_batch_header.RECIPE_VALIDITY_RULE_ID := l_eff_id ;

              IF G_TRACE_ON = 1 THEN
                 print_debug('Calling the GMP Create_Batch Wrapper API', 're_batch', 9);
              END IF;

              gmp_batch_wrapper_pkg.create_batch(
                  p_api_version           =>  2.0
                  ,p_validation_level      =>  100
                  ,p_init_msg_list         => FND_API.G_TRUE
                  ,p_commit                => FND_API.G_TRUE
                  ,x_message_count         => x_message_count
                  ,x_message_list          => x_message_list
                  ,x_return_status         => return_status
                  ,p_org_code              => NULL
                  ,p_batch_header_rec      => l_gme_batch_header
                  ,x_batch_header_rec      => x_gme_batch_header
                  ,p_batch_size            => p_qty
                  ,p_batch_size_uom        => p_uom
                  ,p_creation_mode         => 'PRODUCT'
                  ,p_recipe_id             => NULL
                  ,p_recipe_no             => NULL
                  ,p_recipe_version        => NULL
                  ,p_product_no            => NULL
                  ,p_item_revision         => NULL
                  ,p_product_id            => p_item_id
                  ,p_ignore_qty_below_cap  => FND_API.G_TRUE
                  ,p_use_workday_cal       => NULL
                  ,p_contiguity_override   => NULL
                  ,p_use_least_cost_validity_rule => FND_API.G_FALSE
                  ,x_exception_material_tbl => x_exception_material_tbl
                  );

--               IF (return_status <> 'S') THEN -- nsinghi bug 5931402
               IF (return_status NOT IN ('S', 'V')) THEN
                  IF G_TRACE_ON = 1 THEN
                     print_debug('Could not create batch. gmp_batch_wrapper_pkg.create_batch returned with status '||return_status
                              , 're_batch', 9);
                     print_debug('x_message_count '||to_char(x_message_count)||', x_message_list '||x_message_list
                              , 're_batch', 9);
                  END IF;
                  RAISE batch_exc;
               ELSE
                  IF G_TRACE_ON = 1 THEN
                     print_debug('Created batch with batch_id '||to_char(x_gme_batch_header.batch_id)
                              , 're_batch', 9);
                  END IF;
               END IF;

--           END IF;  /* For l_eff_id <> NULL */

        END IF; /* For p_execution_enabled <> 'Y' AND p_recipe_enabled <> 'Y' */

        x_ret_stat := FND_API.G_RET_STS_SUCCESS;
        x_ret_mesg := '';

    EXCEPTION
        WHEN OTHERS THEN
            IF G_TRACE_ON = 1 THEN
            print_debug(sqlcode || ', ' || sqlerrm, 're_batch', 1);
            END IF;

            SELECT meaning
              INTO x_ret_mesg
              FROM mfg_lookups
             WHERE lookup_type = 'INV_MMX_RPT_MSGS'
               AND lookup_code = 2;

            x_ret_stat := FND_API.G_RET_STS_ERROR;
    END re_batch;


   --This procedure is to copmpute the loaded quantities for a WMS enabled org.
   --This is the qty loaded using Pick load and not yet Pick dropped.
   FUNCTION get_loaded_qty(    p_org_id          NUMBER
                              , p_subinv          VARCHAR2
                              , p_level           NUMBER
                              , p_item_id         NUMBER
                              , p_net_rsv         NUMBER
                              , p_net_unrsv       NUMBER ) RETURN NUMBER IS

      CURSOR c_loaded_quantities_v IS
           SELECT SUM(quantity) FROM wms_loaded_quantities_v
           WHERE  inventory_item_id = p_item_id
           AND subinventory_code = nvl(p_subinv , subinventory_code )
           AND organization_id = p_org_id;

      l_loaded_qty NUMBER := 0 ;

   BEGIN
     --The loaded quantity will be calculated only if the report is ran with
     --parameters "reserved demand=>No , unreserved demand=>No".
     --If the parameters are "yes", the MTL_RESERVATIONS or MMTT will be accounted for this qty.

     IF ( p_net_rsv = 2 and  p_net_unrsv = 2 )THEN

      OPEN c_loaded_quantities_v ;
      FETCH c_loaded_quantities_v INTO l_loaded_qty;
      CLOSE c_loaded_quantities_v;
     END IF;

     IF g_trace_on = 1  THEN
        print_debug('(WMS only) Total quantity loaded : ' ||
to_char(l_loaded_qty), 'get_loaded_qty', 9);
     END IF;

     return ( l_loaded_qty ) ;
   EXCEPTION
     WHEN OTHERS THEN
             IF G_TRACE_ON = 1 THEN
                print_debug(sqlcode || ', ' || sqlerrm, 'get_loaded_qty', 1);
             END IF;
             RAISE;
   END get_loaded_qty;

    -- Bug9122329, get_item_uom_code function added to fetch the uom_code from
    -- MUOM table based on unit_of_measure info from the po_requisitions_interface_all.

FUNCTION get_item_uom_code (p_uom_name   VARCHAR2) RETURN VARCHAR2 IS

    l_uom_code MTL_UNITS_OF_MEASURE.UOM_CODE%type := NULL;

BEGIN

    SELECT uom_code
    INTO l_uom_code
    FROM mtl_units_of_measure_vl
    WHERE unit_of_measure = p_uom_name;

    RETURN (l_uom_code);

    EXCEPTION
        WHEN OTHERS THEN
            IF G_TRACE_ON = 1 THEN
            print_debug('Error in  get_item_uom_code function', 'get_item_uom_code', 9);
            END IF;
    RAISE;

END get_item_uom_code;

/* nsinghi MIN-MAX INVCONV end */

END INV_Minmax_PVT;

/
