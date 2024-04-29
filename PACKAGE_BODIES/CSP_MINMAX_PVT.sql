--------------------------------------------------------
--  DDL for Package Body CSP_MINMAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_MINMAX_PVT" AS
/* $Header: cspvmmxb.pls 115.0 2003/04/25 18:51:59 phegde noship $ */

    -- user ID for logging trace
    G_USER_NAME fnd_user.user_name%TYPE := NULL;
    G_TRACE_ON  BOOLEAN := FALSE;

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
    , pick_components            mtl_system_items.pick_components_flag%TYPE
    );

    --
    -- Start of forward declarations
    --

    FUNCTION get_item_segments( p_org_id   NUMBER
                              , p_item_id  NUMBER) RETURN VARCHAR2;

    FUNCTION get_catg_disp( p_category_id  NUMBER
                          , p_struct_id    NUMBER) RETURN VARCHAR2;

    --Bug# 2766358
    /*
    FUNCTION get_onhand_qty( p_include_nonnet  NUMBER
                           , p_level           NUMBER
                           , p_org_id          NUMBER
                           , p_subinv          VARCHAR2
                           , p_item_id         NUMBER
                           , p_sysdate         DATE) RETURN NUMBER;
    */

    FUNCTION get_supply_qty( p_org_id          NUMBER
                           , p_subinv          VARCHAR2
                           , p_item_id         NUMBER
                           , p_postp_lead_time NUMBER
                           , p_cal_code        VARCHAR2
                           , p_except_id       NUMBER
                           , p_level           NUMBER
                           , p_s_cutoff        DATE
                           , p_include_po      NUMBER
                           , p_vmi_enabled     VARCHAR2
                           , p_include_nonnet  NUMBER
                           , p_include_wip     NUMBER
                           , p_include_if      NUMBER) RETURN NUMBER;

    FUNCTION get_demand_qty( p_org_id          NUMBER
                           , p_subinv          VARCHAR2
                           , p_level           NUMBER
                           , p_item_id         NUMBER
                           , p_d_cutoff        DATE
                           , p_include_nonnet  NUMBER
                           , p_net_rsv         NUMBER
                           , p_net_unrsv       NUMBER
                           , p_net_wip         NUMBER) RETURN NUMBER;

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
                           , p_cal_code          VARCHAR2
                           , p_exception_set_id  NUMBER
                           , p_dd_loc_id         NUMBER
                           , p_po_org_id         NUMBER
                           , p_pur_revision      NUMBER
                           , p_item_rec          minmax_items_rectype) RETURN VARCHAR2;

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
                    , x_ret_mesg         OUT  NOCOPY VARCHAR2);

    --
    -- End of forward declarations
    --


    PROCEDURE init_debug (p_user_id  IN  NUMBER) IS

        l_inv_debug  VARCHAR2(1);

    BEGIN

        --
        -- Find the user name, INV debug profile setting
        --
        SELECT user_name
          INTO G_USER_NAME
          FROM fnd_user
         WHERE user_id = p_user_id;

        SELECT NVL(fnd_profile.value('INV_DEBUG_TRACE'),'2')
          INTO l_inv_debug
          FROM dual;

        IF l_inv_debug = 1 THEN
            G_TRACE_ON := TRUE;
        ELSE
            G_TRACE_ON := FALSE;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
             -- dbms_output.put_line(sqlcode || ', ' || l_err_msg);
             G_TRACE_ON := FALSE;
    END init_debug;



    PROCEDURE print_debug
    (
        p_message  IN  VARCHAR2
      , p_module   IN  VARCHAR2
      , p_level    IN  NUMBER
    ) IS
    BEGIN
        -- dbms_output.put_line(p_message);

        IF G_TRACE_ON THEN
            inv_log_util.trace( G_USER_NAME || ':  ' || p_message
                              , G_PKG_NAME  || '.'   || p_module
                              , p_level
                              );
        END IF;

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
                               , x_return_status     OUT NOCOPY VARCHAR2
                               , x_msg_data          OUT NOCOPY VARCHAR2
                               ) IS

        TYPE c_items_curtype IS REF CURSOR;
        c_items_to_plan c_items_curtype;

        item_rec minmax_items_rectype;

        sql_stmt1    VARCHAR2(8000) :=
            ' SELECT ' || p_item_select || '            item,
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
                     pick_components_flag               pick_components
                FROM mtl_categories       b,
                     mtl_item_categories  a,
                     mtl_system_items     c,
                     mtl_parameters       p
               WHERE b.category_id             = a.category_id
                 AND b.structure_id            = :mcat_struct_id
                 AND c.inventory_item_flag     = ''Y''
                 AND p.organization_id         = :org_id
                 AND a.organization_id         = c.organization_id
                 AND c.organization_id         = :org_id
                 AND c.inventory_planning_code = 2
                 AND a.category_set_id         = :cat_set_id
                 AND a.inventory_item_id       = c.inventory_item_id
                 AND ( ' || p_range_sql || ' ) ';

        sql_stmt2    VARCHAR2(8000) :=
            ' SELECT ' || p_item_select || '            item,
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
                     pick_components_flag
                FROM mtl_categories             b,
                     mtl_item_categories        a,
                     mtl_system_items           c,
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

        sql_stmt3    VARCHAR2(8000) :=
            ' SELECT ' || p_item_select || ',
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
                     pick_components_flag
                FROM mtl_categories       b,
                     mtl_item_categories  a,
                     mtl_system_items     c,
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

        sql_stmt4    VARCHAR2(8000) :=
            ' SELECT ' || p_item_select || ',
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
                     pick_components_flag
                FROM mtl_categories             b,
                     mtl_item_categories        a,
                     mtl_system_items           c,
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
                 AND ( ' || p_range_buyer || ' ) ';


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
        l_vmi_enabled     VARCHAR2(1);

    BEGIN

        --
        -- Query debug settings, set global variables
        --
        init_debug(p_user_id);

        IF G_TRACE_ON THEN
            print_debug('Starting Min-max planning with the following parameters: ' ||
                        'p_item_select: '        || p_item_select              ||
                        ', p_handle_rep_item: '  || to_char(p_handle_rep_item) ||
                        ', p_pur_revision: '     || to_char(p_pur_revision)    ||
                        ', p_cat_select: '       || p_cat_select               ||
                        ', p_cat_set_id: '       || to_char(p_cat_set_id)      ||
                        ', p_mcat_struct: '      || to_char(p_mcat_struct)     ||
                        ', p_level: '            || to_char(p_level)           ||
                        ', p_restock: '          || to_char(p_restock)         ||
                        ', p_include_nonnet: '   || to_char(p_include_nonnet)  ||
                        ', p_include_po: '       || to_char(p_include_po)      ||
                        ', p_include_wip: '      || to_char(p_include_wip)     ||
                        ', p_include_if: '       || to_char(p_include_if)
                        , 'run_min_max_plan'
                        , 5);

            print_debug('Parameters contd..: '   ||
                        'p_net_rsv: '            || to_char(p_net_rsv)         ||
                        ', p_net_unrsv: '        || to_char(p_net_unrsv)       ||
                        ', p_net_wip: '          || to_char(p_net_wip)         ||
                        ', p_org_id: '           || to_char(p_org_id)          ||
                        ', p_user_id: '          || to_char(p_user_id)         ||
                        ', p_employee_id: '      || to_char(p_employee_id)     ||
                        ', p_subinv: '           || p_subinv                   ||
                        ', p_dd_loc_id: '        || to_char(p_dd_loc_id)       ||
                        ', p_wip_batch_id: '     || to_char(p_wip_batch_id)    ||
                        ', p_approval: '         || to_char(p_approval)        ||
                        ', p_buyer_hi: '         || p_buyer_hi                 ||
                        ', p_buyer_lo: '         || p_buyer_lo                 ||
                        ', p_range_buyer: '      || p_range_buyer
                        , 'run_min_max_plan'
                        , 5);

            print_debug('Parameters contd..: '   ||
                        'p_cust_id: '            || to_char(p_cust_id)         ||
                        ', p_po_org_id: '        || to_char(p_po_org_id)       ||
                        ', p_range_sql: '        || p_range_sql                ||
                        ', p_sort: '             || p_sort                     ||
                        ', p_selection: '        || to_char(p_selection)       ||
                        ', p_sysdate: '          || to_char(p_sysdate,  'DD-MON-YYYY HH24:MI:SS') ||
                        ', p_s_cutoff: '         || to_char(p_s_cutoff, 'DD-MON-YYYY HH24:MI:SS') ||
                        ', p_d_cutoff: '         || to_char(p_d_cutoff, 'DD-MON-YYYY HH24:MI:SS') ||
                        ', p_order_by: '         || p_order_by                 ||
                        ', p_encum_flag: '       || p_encum_flag               ||
                        ', p_cal_code: '         || p_cal_code                 ||
                        ', p_exception_set_id: ' || to_char(p_exception_set_id)
                        , 'run_min_max_plan'
                        , 5);
        END IF;


        --
        -- Determine if we need to account for VMI
        --
        BEGIN
            SELECT NVL(fnd_profile.value('PO_VMI_ENABLED'),'N')
              INTO l_vmi_enabled
              FROM dual;

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

            l_onhand_qty := get_onhand_qty( p_include_nonnet  => p_include_nonnet
                                          , p_level           => p_level
                                          , p_org_id          => p_org_id
                                          , p_subinv          => p_subinv
                                          , p_item_id         => item_rec.item_id
                                          , p_sysdate         => p_sysdate);

            l_supply_qty :=  get_supply_qty( p_org_id          => p_org_id
                                           , p_subinv          => p_subinv
                                           , p_item_id         => item_rec.item_id
                                           , p_postp_lead_time => item_rec.postprocessing_lead_time
                                           , p_cal_code        => p_cal_code
                                           , p_except_id       => p_exception_set_id
                                           , p_level           => p_level
                                           , p_s_cutoff        => p_s_cutoff
                                           , p_include_po      => p_include_po
                                           , p_vmi_enabled     => l_vmi_enabled
                                           , p_include_nonnet  => p_include_nonnet
                                           , p_include_wip     => p_include_wip
                                           , p_include_if      => p_include_if);

            l_demand_qty := get_demand_qty( p_org_id          => p_org_id
                                          , p_subinv          => p_subinv
                                          , p_level           => p_level
                                          , p_item_id         => item_rec.item_id
                                          , p_d_cutoff        => p_d_cutoff
                                          , p_include_nonnet  => p_include_nonnet
                                          , p_net_rsv         => p_net_rsv
                                          , p_net_unrsv       => p_net_unrsv
                                          , p_net_wip         => p_net_wip);

            l_tot_avail_qty := NVL(l_onhand_qty,0) + NVL(l_supply_qty,0) - NVL(l_demand_qty,0);

            print_debug('Item ID: '  || to_char(item_rec.item_id) ||
                        ', Onhand: ' || to_char(l_onhand_qty) ||
                        ', Supply: ' || to_char(l_supply_qty) ||
                        ', Demand: ' || to_char(l_demand_qty) ||
                        ', Avail: '  || to_char(l_tot_avail_qty)
                        , 'run_min_max_plan'
                        , 7);

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
                l_item_segments := get_item_segments(p_org_id, item_rec.item_id);

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
                                        , p_cal_code          =>  p_cal_code
                                        , p_exception_set_id  =>  p_exception_set_id
                                        , p_dd_loc_id         =>  p_dd_loc_id
                                        , p_po_org_id         =>  p_po_org_id
                                        , p_pur_revision      =>  p_pur_revision
                                        , p_item_rec          =>  item_rec);

                print_debug('Item ID: '           || to_char(item_rec.item_id) ||
                            ', Item Num: '        || l_item_segments           ||
                            ', Reord qty: '       || to_char(l_reord_qty)      ||
                            ', Reorder status: '  || l_stat
                            , 'run_min_max_plan'
                            , 7);

                --
                -- Insert into the global temp table INV_MIN_MAX_TEMP (defined
                -- in patch/115/sql/invmmxtb.sql).
                --
                INSERT INTO INV_MIN_MAX_TEMP (
                                      ITEM_SEGMENTS
                                    , DESCRIPTION
                                    , ERROR
                                    , SORTEE
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
        END LOOP;
        CLOSE c_items_to_plan;

        x_return_status := 'S';

    EXCEPTION
        WHEN OTHERS THEN
            IF c_items_to_plan%ISOPEN  THEN
                CLOSE c_items_to_plan;
            END IF;

            l_err_msg := sqlerrm;
            print_debug(sqlcode || ', ' || l_err_msg, 'run_min_max_plan', 1);
            x_return_status := 'E';
            x_msg_data := l_err_msg;

    END run_min_max_plan;



    FUNCTION get_item_segments (  p_org_id   NUMBER
                                , p_item_id  NUMBER ) RETURN VARCHAR2 IS

        CURSOR c_item_segments IS
        SELECT concatenated_segments
          FROM mtl_system_items_kfv
         WHERE organization_id    = p_org_id
           AND inventory_item_id = p_item_id;

        c_item_seg_rec c_item_segments%ROWTYPE;

    BEGIN
        OPEN c_item_segments;
        FETCH c_item_segments INTO c_item_seg_rec;
        CLOSE c_item_segments;

        RETURN c_item_seg_rec.concatenated_segments;
    END get_item_segments;



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

        x_return_status      VARCHAR2(30);

        --Bug# 2677358
        /*
        x_msg_count          NUMBER;
        x_msg_data           VARCHAR2(1000);
        l_onhand_source      NUMBER := 3;
        l_subinventory_code  VARCHAR2(30) := NULL;
        l_qoh                NUMBER := 0;
        x_qoh                NUMBER;
        x_voh                NUMBER;
        x_rqoh               NUMBER;
        x_qr                 NUMBER;
        x_qs                 NUMBER;
        x_att                NUMBER;
        x_vatt               NUMBER;
        x_atr                NUMBER;

        l_onhand_exception   EXCEPTION;
        */
        l_moq_qty1                NUMBER := 0;
        l_mmtt_qty1               NUMBER := 0;
        l_mmtt_qty2               NUMBER := 0;
        l_qoh                   NUMBER := 0;

    BEGIN

        IF G_TRACE_ON THEN
            print_debug('p_include_nonnet: ' || to_char(p_include_nonnet)   ||
                        ', p_level: '        || to_char(p_level)            ||
                        ', p_org_id: '       || to_char(p_org_id)           ||
                        ', p_subinv: '       || p_subinv                    ||
                        ', p_item_id: '      || to_char(p_item_id)          ||
                        ', p_sysdate: '      || to_char(p_sysdate, 'DD-MON-YYYY HH24:MI:SS')
                        , 'get_onhand_qty'
                        , 9);
        END IF;

        --Bug# 2677358
        /*
        IF (p_include_nonnet = 2)
        THEN
            l_onhand_source := 2;
        END IF;

        IF (p_level = 2)
        THEN
            l_subinventory_code := p_subinv;
        END IF;
        */

        IF (p_level = 1)   -- Org Level
        THEN

            SELECT SUM(moqd.transaction_quantity)
            INTO   l_moq_qty1
            FROM   mtl_onhand_quantities_detail moqd
            WHERE  moqd.organization_id = p_org_id
            AND    moqd.inventory_item_id = p_item_id
            AND    EXISTS (select 'x' from mtl_secondary_inventories msi
            WHERE  msi.organization_id = moqd.organization_id and
                   msi.secondary_inventory_name = moqd.subinventory_code
            AND    msi.availability_type = decode(p_include_nonnet,1,msi.availability_type,1))
            AND    nvl(moqd.planning_tp_type,2) = 2;

             print_debug('Total moqd quantity Org Level : ' || to_char(l_moq_qty1), 'get_onhand_qty', 9);

            SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
                   Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
            INTO   l_mmtt_qty1
            FROM   mtl_material_transactions_temp mmtt
            WHERE  mmtt.organization_id = p_org_id
            AND    mmtt.inventory_item_id = p_item_id
            AND    mmtt.posting_flag = 'Y'
            AND    mmtt.subinventory_code IS NOT NULL
            AND    Nvl(mmtt.transaction_status,0) <> 2
            AND    mmtt.transaction_action_id NOT IN (24,30)
            AND    EXISTS (select 'x' from mtl_secondary_inventories msi
                   WHERE msi.organization_id = mmtt.organization_id
                   AND   msi.secondary_inventory_name = mmtt.subinventory_code
           AND     msi.availability_type = decode(p_include_nonnet,1,msi.availability_type,1))
           AND    nvl(mmtt.planning_tp_type,2) = 2;

            print_debug('Total MMTT Trx quantity Source Org : ' || to_char(l_mmtt_qty1), 'get_onhand_qty', 9);

           SELECT SUM(Abs(mmtt.primary_quantity))
           INTO   l_mmtt_qty2
           FROM   mtl_material_transactions_temp mmtt
           WHERE  decode(mmtt.transaction_action_id,3,
                  mmtt.transfer_organization,mmtt.organization_id) = p_org_id
           AND    mmtt.inventory_item_id = p_item_id
           AND    mmtt.posting_flag = 'Y'
           AND    Nvl(mmtt.transaction_status,0) <> 2
           AND    mmtt.transaction_action_id  in (2,28,3)
           AND    ((mmtt.transfer_subinventory IS NULL) OR
                  (mmtt.transfer_subinventory IS NOT NULL
                   AND    EXISTS (select 'x' from mtl_secondary_inventories msi
                          WHERE msi.organization_id = decode(mmtt.transaction_action_id,
                                                       3, mmtt.transfer_organization,mmtt.organization_id)
                   AND   msi.secondary_inventory_name = mmtt.transfer_subinventory
                   AND   msi.availability_type = decode(p_include_nonnet,1,msi.availability_type,1))))
           AND    nvl(mmtt.planning_tp_type,2) = 2;

            print_debug('Total MMTT Trx quantity Dest Org : ' || to_char(l_mmtt_qty2), 'get_onhand_qty', 9);

        ELSIF (p_level = 2)      --Sub Level
        THEN

           SELECT SUM(moqd.transaction_quantity)
           INTO   l_moq_qty1
           FROM   mtl_onhand_quantities_detail moqd
           WHERE  moqd.organization_id = p_org_id
           AND    moqd.inventory_item_id = p_item_id
           --AND    moqd.planning_tp_type = 2
           AND    moqd.subinventory_code = p_subinv;

            print_debug('Total moqd quantity Sub Level : ' || to_char(l_moq_qty1), 'get_onhand_qty', 9);

            SELECT SUM(Decode(mmtt.transaction_action_id, 1, -1, 2, -1, 28, -1, 3, -1,
                       Sign(mmtt.primary_quantity)) * Abs( mmtt.primary_quantity ))
            INTO   l_mmtt_qty1
            FROM   mtl_material_transactions_temp mmtt
            WHERE  mmtt.organization_id = p_org_id
            AND    mmtt.inventory_item_id = p_item_id
            AND    mmtt.subinventory_code = p_subinv
            --AND    mmtt.planning_tp_type = 2
            AND    mmtt.posting_flag = 'Y'
            AND    mmtt.subinventory_code IS NOT NULL
            AND    Nvl(mmtt.transaction_status,0) <> 2
            AND    mmtt.transaction_action_id NOT IN (24,30);

            print_debug('Total MMTT Trx quantity Source Org Sub : ' || to_char(l_mmtt_qty1), 'get_onhand_qty', 9);

           SELECT SUM(Abs(mmtt.primary_quantity))
           INTO   l_mmtt_qty2
           FROM   mtl_material_transactions_temp mmtt
           WHERE  decode(mmtt.transaction_action_id,3,
                  mmtt.transfer_organization,mmtt.organization_id) = p_org_id
           AND    mmtt.inventory_item_id = p_item_id
           AND    mmtt.transfer_subinventory = p_subinv
           --AND    mmtt.planning_tp_type = 2
           AND    mmtt.posting_flag = 'Y'
           AND    Nvl(mmtt.transaction_status,0) <> 2
           AND    mmtt.transaction_action_id  in (2,28,3);

            print_debug('Total MMTT Trx quantity Dest Org Sub : ' || to_char(l_mmtt_qty2), 'get_onhand_qty', 9);

        END IF;

        l_qoh :=  nvl(l_moq_qty1,0) + nvl(l_mmtt_qty1,0) + nvl(l_mmtt_qty2,0);

        print_debug('Total quantity on-hand: ' || to_char(l_qoh), 'get_onhand_qty', 9);
        return (l_qoh);

        --Bug# 2677358
        /*
        -- Clear the quantity tree cache
        inv_quantity_tree_grp.clear_quantity_cache;

        inv_vmi_validations.get_available_vmi_quantity
        ( x_return_status        => x_return_status
        , x_return_msg           => x_msg_data
        , p_tree_mode            => 2
        , p_organization_id      => p_org_id
        , p_owning_org_id        => NULL
        , p_planning_org_id      => NULL
        , p_inventory_item_id    => p_item_id
        , p_is_revision_control  => 'FALSE'
        , p_is_lot_control       => 'FALSE'
        , p_is_serial_control    => 'FALSE'
        , p_revision             => NULL
        , p_lot_number           => NULL
        , p_lot_expiration_date  => p_sysdate
        , p_subinventory_code    => l_subinventory_code
        , p_locator_id           => NULL
        , p_onhand_source        => l_onhand_source
        , p_cost_group_id        => NULL
        , x_qoh                  => x_qoh
        , x_att                  => x_att
        , x_voh                  => x_voh
        , x_vatt                 => x_vatt
        );


        IF G_TRACE_ON THEN
            print_debug('After call to inv_vmi_validations.get_available_vmi_quantity:' ||
                        '  x_return_status: ' || x_return_status      ||
                        ', x_msg_data: '      || x_msg_data           ||
                        ', x_qoh: '           || to_char(x_qoh)       ||
                        ', x_att: '           || to_char(x_att)       ||
                        ', x_voh: '           || to_char(x_voh)       ||
                        ', x_vatt: '          || to_char(x_vatt)
                        , 'get_onhand_qty'
                        , 9);
        END IF;


        IF x_return_status = 'S' THEN
            l_qoh := NVL(x_qoh,0) - NVL(x_voh,0);
        ELSE
            RAISE l_onhand_exception;
        END IF;
        */

    EXCEPTION
        WHEN OTHERS THEN
            print_debug(sqlcode || ', ' || sqlerrm, 'get_onhand_qty', 1);
            RAISE;

    END get_onhand_qty;



    FUNCTION get_supply_qty( p_org_id          NUMBER
                           , p_subinv          VARCHAR2
                           , p_item_id         NUMBER
                           , p_postp_lead_time NUMBER
                           , p_cal_code        VARCHAR2
                           , p_except_id       NUMBER
                           , p_level           NUMBER
                           , p_s_cutoff        DATE
                           , p_include_po      NUMBER
                           , p_vmi_enabled     VARCHAR2
                           , p_include_nonnet  NUMBER
                           , p_include_wip     NUMBER
                           , p_include_if      NUMBER) RETURN NUMBER IS

        l_qty          NUMBER;
        l_total        NUMBER;


        l_stmt         VARCHAR2(4000) :=
            ' SELECT NVL(sum(to_org_primary_quantity), 0)
                FROM mtl_supply sup, bom_calendar_dates c1, bom_calendar_dates c
               WHERE sup.supply_type_code IN (''PO'',''REQ'',''SHIPMENT'',''RECEIVING'')
                 AND sup.destination_type_code  = ''INVENTORY''
                 AND sup.to_organization_id     = :l_org_id
                 AND sup.item_id                = :l_item_id
                 AND c1.calendar_code           = c.calendar_code
                 AND c1.exception_set_id        = c.exception_set_id
                 AND c1.seq_num                 = (c.next_seq_num + trunc(:l_postp_lead_time))
                 AND c.calendar_code            = :l_cal_code
                 AND c.exception_set_id         = :l_except_id
	         AND c.calendar_date            = trunc(sup.need_by_date)
                 AND trunc(c1.calendar_date)   <= :l_s_cutoff
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
                 AND (:l_level = 1 OR to_subinventory = :l_subinv) ';



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
        IF G_TRACE_ON THEN
            print_debug('p_org_id: '           || to_char(p_org_id)         ||
                        ', p_subinv: '         || p_subinv                  ||
                        ', p_item_id: '        || to_char(p_item_id)        ||
                        ', p_postp_lead_time: ' || to_char(p_postp_lead_time) ||
                        ', p_cal_code: '       || p_cal_code               ||
                        ', p_except_id: '      || to_char(p_except_id)     ||
                        ', p_level: '          || to_char(p_level)          ||
                        ', p_s_cutoff: '       || to_char(p_s_cutoff, 'DD-MON-YYYY HH24:MI:SS') ||
                        ', p_include_po: '     || to_char(p_include_po)     ||
                        ', p_include_nonnet: ' || to_char(p_include_nonnet) ||
                        ', p_include_wip: '    || to_char(p_include_wip)    ||
                        ', p_include_if: '     || to_char(p_include_if)
                        , 'get_supply_qty'
                        , 9);
        END IF;

        l_total := 0;

        --
        -- MTL_SUPPLY
        --
        IF p_include_po = 1 THEN

            IF (p_vmi_enabled = 'Y') AND (p_level= 1) THEN
                OPEN c_po_qty FOR l_stmt || l_vmi_stmt
                USING
                    p_org_id, p_item_id, p_postp_lead_time, p_cal_code, p_except_id, p_s_cutoff, p_org_id,
		    p_org_id, p_include_nonnet, p_level, p_include_nonnet, p_level, p_level, p_subinv;
            ELSE
                OPEN c_po_qty FOR l_stmt
                USING
                    p_org_id, p_item_id, p_postp_lead_time, p_cal_code, p_except_id, p_s_cutoff, p_org_id,
	            p_org_id, p_include_nonnet, p_level, p_include_nonnet, p_level, p_level, p_subinv;
            END IF;

            FETCH c_po_qty INTO l_qty;
            CLOSE c_po_qty;
            print_debug('Supply from mtl_supply: ' || to_char(l_qty)
                        , 'get_supply_qty'
                        , 9);

            l_total := l_total + l_qty;

        END IF;

        --
        -- Take into account the quantity for which a move order
        -- has already been created assuming that the move order
        -- can be created only within the same org
        --
        IF p_level = 2  THEN
            -- kkoothan Part of Bug Fix: 2875583
            -- Converting the quantities to the primary uom as the quantity
            -- and quantity delivered in mtl_txn_request_lines
            -- are in transaction uom.

            /*SELECT NVL(sum(mtrl.quantity - NVL(mtrl.quantity_delivered,0)),0)
              INTO l_qty
              FROM mtl_transaction_types  mtt,
                   mtl_txn_request_lines  mtrl
             WHERE mtt.transaction_action_id IN (2,28)
               AND mtt.transaction_type_id   = mtrl.transaction_type_id
               AND mtrl.organization_id      = p_org_id
               AND mtrl.inventory_item_id    = p_item_id
               AND mtrl.to_subinventory_code = p_subinv
               AND mtrl.line_status NOT IN (5,6)
               AND mtrl.date_required       <= p_s_cutoff;    */

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
                AND mtrl.line_status NOT IN (5,6)
                AND mtrl.date_required       <= p_s_cutoff;

            print_debug('Supply from move orders: ' || to_char(l_qty)
                        , 'get_supply_qty'
                        , 9);
            l_total := l_total + l_qty;
        END IF;

        --
        -- Supply FROM WIP discrete job is to be included at Org Level Planning Only
        --
        IF p_level = 1 AND p_include_wip = 1
        THEN
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
               AND trunc(scheduled_completion_date) <= p_s_cutoff

               AND (NVL(start_quantity,0) - NVL(quantity_completed,0)
                                          - NVL(quantity_scrapped,0)) > 0;

            print_debug('Supply from WIP discrete jobs: ' || to_char(l_qty)
                        , 'get_supply_qty'
                        , 9);
            l_total := l_total + NVL(l_qty,0);

            --
            -- WIP REPETITIVE JOBS to be included at Org Level Planning Only
            --
            SELECT SUM(daily_production_rate *
                       GREATEST(0, LEAST(processing_work_days,
                                         p_s_cutoff - first_unit_completion_date))
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
                                      p_s_cutoff - first_unit_completion_date))
                    - quantity_completed) > 0;


            print_debug('Supply from WIP repetitive jobs: ' || to_char(l_qty)
                        , 'get_supply_qty'
                        , 9);
            l_total := l_total + NVL(l_qty,0);
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
        -- 2866966 added nvl to condition checking
        -- for error process flag
        SELECT NVL(SUM(quantity),0)
          INTO l_qty
          FROM po_requisitions_interface_all
         WHERE destination_organization_id = p_org_id
           AND item_id                     = p_item_id
           AND p_include_po                = 1
           AND (p_level = 1 or destination_subinventory = p_subinv)
           AND need_by_date               <= p_s_cutoff
           AND nvl(process_flag,'@@@')               <> 'ERROR'
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

        print_debug('Supply from po_requisitions_interface_all: ' || to_char(l_qty)
                    , 'get_supply_qty'
                    , 9);
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
	         --Bug 2647862
               AND trunc(scheduled_completion_date) <= p_s_cutoff
               AND (NVL(planned_quantity,0)
                    - NVL(quantity_completed,0)) > 0;

            print_debug('Supply from WIP flow schedules: ' || to_char(l_qty)
                        , 'get_supply_qty'
                        , 9);
            l_total := l_total + NVL(l_qty,0);
        END IF;

        RETURN(l_total);

    EXCEPTION
        WHEN others THEN
            IF c_po_qty%ISOPEN  THEN
               CLOSE c_po_qty;
            END IF;

            print_debug(sqlcode || ', ' || sqlerrm, 'get_supply_qty', 1);
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
                           , p_net_wip         NUMBER) RETURN NUMBER IS

        qty                  NUMBER := 0;
        total                NUMBER := 0;
        l_total_demand_qty   NUMBER := 0;
        l_demand_qty         NUMBER := 0;
        l_total_reserve_qty  NUMBER := 0;
        l_pick_released_qty  NUMBER := 0;
        l_staged_qty         NUMBER := 0;

    BEGIN
        IF G_TRACE_ON THEN
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
               and REQUIREMENT_DATE    <= p_d_cutoff
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
                                                                       1)));

            print_debug('Demand from mtl_demand: ' || to_char(qty), 'get_demand_qty', 9);
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
               and REQUIREMENT_DATE <= p_d_cutoff
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
                                                                1)));

            print_debug('Demand (reserved qty) for non OE rows in mtl_reservations: ' || to_char(qty)
                        , 'get_demand_qty'
                        , 9);
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
               and schedule_ship_date <= p_d_cutoff
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

            print_debug('Demand from sales orders: ' ||
                        ' Ordered: '        || to_char(l_total_demand_qty)  ||
                        ', Pick released: ' || to_char(l_pick_released_qty) ||
                        ', Staged: '        || to_char(l_staged_qty)
                        , 'get_demand_qty'
                        , 9);
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
               and REQUIREMENT_DATE <= p_d_cutoff
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
                                                                1)));

           print_debug('Reserved demand (sales orders): ' || to_char(l_total_reserve_qty)
                       , 'get_demand_qty'
                       , 9);
        END IF;

        --
        -- total demand is calculated as follows:
        -- if we have to consider both unreserved matl and reserved matl. then the
        --    demand is simply the total demand = ordered qty - shipped qty.
        --    Bug 2333526: Deduct staged qty for sub level.  (l_staged_qty
        --    is always set to 0 for org level planning).
        -- elsif we have to take into account only reserved matl. then the
        --    demand is simply the reservations from mtl_reservations for the matl.
        -- elsif we have to take into account just the unreserved matl. then the
        --    demand is total demand - the reservations for the material.
        --
        IF p_net_unrsv = 1 AND p_net_rsv = 1 THEN
           l_demand_qty := NVL(l_total_demand_qty,0)
                           - NVL(l_staged_qty,0)
                           - NVL(l_pick_released_qty,0);

        ELSIF p_net_rsv = 1 THEN
           l_demand_qty := NVL(l_total_reserve_qty,0);

        ELSIF p_net_unrsv = 1 THEN
           l_demand_qty := NVL(l_total_demand_qty,0) - NVL(l_total_reserve_qty,0);

        END IF;

        print_debug('Demand from shippable orders: ' || to_char(l_demand_qty)
                    , 'get_demand_qty'
                    , 9);
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
                         pol.DESTINATION_TYPE_CODE = 'EXPENSE')
                       )
                   and so.ship_from_org_ID = p_org_id
                   and so.open_flag = 'Y'
                   AND so.visible_demand_flag = 'Y'
                   AND shipped_quantity is null
                   and so.INVENTORY_ITEM_ID = p_item_id
                   and schedule_ship_date <= p_d_cutoff
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

                print_debug('Total demand (internal orders): ' || to_char(l_total_demand_qty)
                            , 'get_demand_qty'
                            , 9);
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
                      po_req_distributions_all pod,
                      po_requisition_lines_all pol
                where md.DEMAND_SOURCE_LINE_ID = so.LINE_ID
                  and so.ORIG_SYS_LINE_REF     = to_char(pod.DISTRIBUTION_ID)
                  and pod.REQUISITION_LINE_ID  = pol.REQUISITION_LINE_ID
                  and (pol.DESTINATION_ORGANIZATION_ID <> p_org_id or
                       (pol.DESTINATION_ORGANIZATION_ID = p_org_id
                        and  -- Added code Bug#1012179
                        pol.DESTINATION_TYPE_CODE = 'EXPENSE')
                      )
                  and ORGANIZATION_ID = p_org_id
                  and md.INVENTORY_ITEM_ID = p_item_id
                  and REQUIREMENT_DATE <= p_d_cutoff
                  and demand_source_type_id = 8
                  and (SUBINVENTORY_CODE is null or
                       EXISTS (SELECT 1
                                 FROM MTL_SECONDARY_INVENTORIES S
                                WHERE S.ORGANIZATION_ID = p_org_id
                                  AND S.SECONDARY_INVENTORY_NAME = SUBINVENTORY_CODE
                                  AND S.availability_type = DECODE(p_include_nonnet,
                                                                   1,
                                                                   S.availability_type,
                                                                   1)));

               print_debug('Reserved demand (internal orders): ' || to_char(l_total_reserve_qty)
                           , 'get_demand_qty'
                           , 9);
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

            print_debug('Demand from internal orders: ' || to_char(l_demand_qty)
                        , 'get_demand_qty'
                        , 9);
            total := total + NVL(l_demand_qty,0);

        end if; -- end if level=1

        --
        -- WIP Reservations from mtl_demand
        --
        IF p_level = 1 THEN
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

            print_debug('WIP Reservations from mtl_demand: ' || to_char(qty)
                        , 'get_demand_qty'
                        , 9);
            total := total + NVL(qty,0);
        END IF;

        --
        -- Wip Components are to be included at the Org Level Planning only.
        -- Qty Issued Substracted from the Qty Required
        --
        if (p_net_wip = 1 and p_level = 1)
        then
            select sum(o.required_quantity - o.quantity_issued)
              into qty
              from wip_discrete_jobs d, wip_requirement_operations o
             where o.wip_entity_id     = d.wip_entity_id
               and o.organization_id   = d.organization_id
               and d.organization_id   = p_org_id
               and o.inventory_item_id = p_item_id
               and o.date_required    <= p_d_cutoff
               and o.required_quantity > 0
               and o.required_quantity > o.quantity_issued
               and o.operation_seq_num > 0
               and d.status_type in (1,3,4,6) -- Excluded 5 from selection Bug#1016495
               and o.wip_supply_type <> 6;

            print_debug('WIP component requirements for discrete jobs: ' || to_char(qty)
                        , 'get_demand_qty'
                        , 9);
            total := total + NVL(qty,0);

            --
            -- Demand Qty to be added for a released repetitive schedule
            -- Bug#691471
            --
            select sum(o.required_quantity - o.quantity_issued)
              into qty
              from wip_repetitive_schedules r, wip_requirement_operations o
             where o.wip_entity_id          = r.wip_entity_id
               and o.repetitive_schedule_id = r.repetitive_schedule_id
               and o.organization_id        = r.organization_id
               and r.organization_id        = p_org_id
               and o.inventory_item_id      = p_item_id
               and o.date_required         <= p_d_cutoff
               and o.required_quantity      > 0
               and o.required_quantity      > o.quantity_issued
               and o.operation_seq_num      > 0
               and r.status_type in (1,3,4,6) -- Excluded 5 from selection Bug#1016495
               and o.wip_supply_type       <> 6;

            print_debug('WIP component requirements for repetitve schedules: ' || to_char(qty)
                        , 'get_demand_qty'
                        , 9);
            total := total + NVL(qty,0);
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

        -- kkoothan Part of Bug Fix: 2875583
        -- Converting the quantities to the primary uom as the quantity
        -- and quantity delivered in mtl_txn_request_lines
        -- are in transaction uom.
        --

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
           AND MTRL.DATE_REQUIRED <= p_d_cutoff; */

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
           AND    MTRL.LINE_STATUS NOT IN (5,6)
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
           AND MTRL.DATE_REQUIRED <= p_d_cutoff;

        print_debug('Demand from open move orders: ' || to_char(qty), 'get_demand_qty', 9);

        total := total + NVL(qty,0);

        --
        -- Include the sub transfer and the staging transfer move orders
        -- for sub level planning
        --
        IF p_level = 2 THEN
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
              AND mtrl.line_status NOT IN (5,6)
              AND mtrl.date_required         <= p_d_cutoff;

            print_debug('Qty pending out due to sub transfers and the staging transfer move orders: '
                         || to_char(qty)
                        , 'get_demand_qty'
                        , 9);
            total := total + NVL(qty,0);
        END IF;

        return(total);

    exception
        when others then
            print_debug(sqlcode || ', ' || sqlerrm, 'get_demand_qty', 1);
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
               AND (subinventory_code     = p_subinv
                    OR
                    EXISTS (SELECT 1
                              FROM mtl_secondary_inventories s
                             WHERE s.organization_id           = p_org_id
                               AND s.secondary_inventory_name  = subinventory_code
                               AND s.availability_type         = DECODE(p_include_nonnet,
                                                                        1,
                                                                        S.availability_type,
                                                                        1)));
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
            --
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
               AND mtrl.transaction_source_type_id = 2
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
        reorder             NUMBER;
        min_restock_qty     NUMBER;
        qty_for_last_order  NUMBER;
        round_reord_qty     VARCHAR2(1);

    BEGIN
        IF G_TRACE_ON THEN
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
        l_fix_mult    := NVL(p_fix_mult, 0);

        IF p_tot_avail_qty >= l_min_qty
        THEN
           RETURN 0;
        END if;

        reorder := l_max_qty - p_tot_avail_qty;

        print_debug('Initial estimated reorder qty: ' || to_char(reorder)
                    , 'get_reord_qty'
                    , 9);

        IF l_min_ord_qty >= reorder
        THEN
            RETURN l_min_ord_qty;
        END if;

        IF l_fix_mult > 0
        THEN
            round_reord_qty := NVL(FND_PROFILE.VALUE('INV_ROUND_REORDER_QTY'), 'Y');
            print_debug('round_reord_qty: ' || round_reord_qty, 'get_reord_qty', 9);

            IF round_reord_qty = 'N'
            THEN
                reorder := floor(reorder/l_fix_mult) * l_fix_mult;
            ELSE
                reorder := ceil(reorder/l_fix_mult) * l_fix_mult;
            END if;

            print_debug('Reorder qty after applying fix lot multiple: '
                        || to_char(reorder)
                        , 'get_reord_qty'
                        , 9);
        END if;

        IF p_max_ord_qty IS NULL OR reorder <= p_max_ord_qty
        THEN
            RETURN reorder;
        ELSIF p_max_ord_qty > 0
        THEN
            min_restock_qty := floor(reorder/p_max_ord_qty) * p_max_ord_qty;
            qty_for_last_order := reorder - min_restock_qty;
            print_debug('Min reord qty that is a multiple of max ord qty: '
                        || to_char(min_restock_qty)
                        , 'get_reord_qty'
                        , 9);

            IF p_min_ord_qty IS NULL OR qty_for_last_order >= p_min_ord_qty
            THEN
                RETURN reorder;
            ELSE
                RETURN min_restock_qty;
            END IF;
        END if;

        RETURN reorder;

    EXCEPTION
    WHEN OTHERS THEN
            print_debug(sqlcode || ', ' || sqlerrm, 'get_reord_qty', 1);
            RAISE;
    END get_reord_qty;



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
                            , p_cal_code          VARCHAR2
                            , p_exception_set_id  NUMBER
                            , p_dd_loc_id         NUMBER
                            , p_po_org_id         NUMBER
                            , p_pur_revision      NUMBER
                            , p_item_rec          minmax_items_rectype) RETURN VARCHAR2 IS

        v_make_buy_flag   NUMBER;
        l_error_message   VARCHAR2(100);
        l_ret_stat        VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
        need_by_date      DATE;
        reorder_qty       NUMBER;
        move_ord_qty      NUMBER;
        counter           INTEGER;
        no_of_iterations  NUMBER;
    BEGIN
        IF G_TRACE_ON THEN
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
                        ', p_cal_code: '         || p_cal_code                  ||
                        ', p_exception_set_id: ' || to_char(p_exception_set_id) ||
                        ', p_dd_loc_id: '        || to_char(p_dd_loc_id)        ||
                        ', p_po_org_id: '        || to_char(p_po_org_id)        ||
                        ', p_pur_revision: '     || to_char(p_pur_revision)     ||
                        ', p_item_rec: '         || to_char(p_item_rec.item_id)
                        , 'get_reord_stat'
                        , 9);
        END IF;

        --
        -- If the item is a repetitive item and the user chose not to restock
        -- repetitive items, or if the planning level is "Org" and source type
        -- is subinventory (3) do not restock - simply return a null.
        --
        -- Restocking with source type sub will result in a move order and this
        -- only makes sense for sub level planning.
        --
        -- For sub level planning, always set the make_or_buy flag to "buy",
        -- i.e., do not create a work order for sub level planning.
        --
        IF p_restock = 1 THEN
            IF (p_item_rec.repetitive_planned_item = 'Y' AND p_handle_rep_item = 3)
               OR
               (p_level = 1 and p_item_rec.src_type = 3)
            THEN
                RETURN('');
            ELSE
                IF p_level = 2
                THEN
                    v_make_buy_flag := 2;
                ELSE
                    v_make_buy_flag := p_item_rec.mbf;
                END IF;
            END IF;
        ELSE
            RETURN ('');
        END IF;

        reorder_qty := NVL(p_reord_qty,0);

        WHILE (reorder_qty > 0)
        LOOP
            IF NVL(p_item_rec.max_ord_qty,0) = 0
            THEN
                move_ord_qty := reorder_qty;
            ELSIF (reorder_qty > p_item_rec.max_ord_qty)
            THEN
                move_ord_qty := p_item_rec.max_ord_qty;
            ELSE
                move_ord_qty := reorder_qty;
            END IF;

            do_restock( p_item_id                  => p_item_rec.item_id
                      , p_mbf                      => v_make_buy_flag
                      , p_handle_repetitive_item   => p_handle_rep_item
                      , p_repetitive_planned_item  => p_item_rec.repetitive_planned_item
                      , p_qty                      => move_ord_qty
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
                      , x_ret_stat                 => l_ret_stat
                      , x_ret_mesg                 => l_error_message
                      );

            IF l_ret_stat <> FND_API.G_RET_STS_SUCCESS
            THEN
                print_debug('do_restock returned message: ' || l_error_message
                            , 'get_reord_stat'
                            , 9);
                RETURN(l_error_message);
            END IF;

            reorder_qty := reorder_qty - move_ord_qty;
        END LOOP;

        RETURN('');   /*bug2838809*/

    EXCEPTION
    WHEN others THEN
        print_debug(sqlcode || ', ' || sqlerrm, 'get_reord_stat', 1);
        RAISE;
    end get_reord_stat;



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
                        , x_ret_mesg                 OUT  NOCOPY VARCHAR2) IS

        l_need_by_date  DATE;
        l_ret_value     VARCHAR2(200);
        move_ord_exc    EXCEPTION;
        l_ret_stat      VARCHAR2(1);

    BEGIN
        x_ret_stat := FND_API.G_RET_STS_SUCCESS;
        x_ret_mesg := '';

        --
        -- Query debug settings, set global variables.
        -- This is done since MRP will call do_restock directly
        -- from Reorder Point report (MRPRPROP, bug 2442596).
        --
        IF G_USER_NAME IS NULL THEN
            init_debug(p_user_id);
        END IF;

        IF G_TRACE_ON THEN
            print_debug('p_item_id '                    || to_char(p_item_id)                ||
                        ', p_mbf: '                     || to_char(p_mbf)                    ||
                        ', p_handle_repetitive_item: '  || to_char(p_handle_repetitive_item) ||
                        ', p_repetitive_planned_item: ' || p_repetitive_planned_item         ||
                        ', p_qty: '                     || to_char(p_qty)                    ||
                        ', p_fixed_lead_time: '         || to_char(p_fixed_lead_time)        ||
                        ', p_variable_lead_time: '      || to_char(p_variable_lead_time)     ||
                        ', p_buying_lead_time: '        || to_char(p_buying_lead_time)       ||
                        ', p_uom: '                     || p_uom                             ||
                        ', p_accru_acct: '              || to_char(p_accru_acct)             ||
                        ', p_ipv_acct: '                || to_char(p_ipv_acct)               ||
                        ', p_budget_acct: '             || to_char(p_budget_acct)
                        , 'do_restock'
                        , 9);

            print_debug('p_charge_acct: '               || to_char(p_charge_acct)            ||
                        ', p_purch_flag: '              || p_purch_flag                      ||
                        ', p_order_flag: '              || p_order_flag                      ||
                        ', p_transact_flag: '           || p_transact_flag                   ||
                        ', p_unit_price: '              || to_char(p_unit_price)             ||
                        ', p_wip_id: '                  || to_char(p_wip_id)                 ||
                        ', p_user_id: '                 || to_char(p_user_id)                ||
                        ', p_sysd: '                    || to_char(p_sysd, 'DD-MON-YYYY HH24:MI:SS') ||
                        ', p_organization_id: '         || to_char(p_organization_id)        ||
                        ', p_approval: '                || to_char(p_approval)               ||
                        ', p_build_in_wip: '            || p_build_in_wip                    ||
                        ', p_pick_components: '         || p_pick_components                 ||
                        ', p_src_type: '                || to_char(p_src_type)
                        , 'do_restock'
                        , 9);

            print_debug('p_encum_flag: '                || p_encum_flag                      ||
                        ', p_customer_id: '             || to_char(p_customer_id)            ||
                        ', p_cal_code: '                || p_cal_code                        ||
                        ', p_except_id: '               || to_char(p_except_id)              ||
                        ', p_employee_id: '             || to_char(p_employee_id)            ||
                        ', p_description: '             || p_description                     ||
                        ', p_src_org: '                 || to_char(p_src_org)                ||
                        ', p_src_subinv: '              || p_src_subinv                      ||
                        ', p_subinv: '                  || p_subinv                          ||
                        ', p_location_id: '             || to_char(p_location_id)            ||
                        ', p_po_org_id: '               || to_char(p_po_org_id)              ||
                        ', p_pur_revision: '            || to_char(p_pur_revision)
                        , 'do_restock'
                        , 9);
        END IF;

        IF p_qty <= 0
        THEN
            RETURN;
        END IF;

        IF (p_repetitive_planned_item = 'Y' AND p_handle_repetitive_item = 1) OR
           (p_repetitive_planned_item = 'N' AND p_mbf = 2)
        THEN
            --
            -- Lead time for buy items is sum of POSTPROCESSING_LEAD_TIME,
            -- PREPROCESSING_LEAD_TIME AND PROCESSING_LEAD_TIME (sub level)
            -- OR POSTPROCESSING_LEAD_TIME, PREPROCESSING_LEAD_TIME
            -- AND FULL_LEAD_TIME (item level)
            --
            -- Here, total lead time is the total buying Lead time
            --

            SELECT c1.calendar_date
              INTO l_need_by_date
              FROM bom_calendar_dates c1,
                   bom_calendar_dates c
             WHERE  c1.calendar_code    = c.calendar_code
               AND  c1.exception_set_id = c.exception_set_id
               AND  c1.seq_num          = (c.next_seq_num + trunc(p_buying_lead_time))
               AND  c.calendar_code     = p_cal_code
               AND  c.exception_set_id  = p_except_id
               AND  c.calendar_date     = trunc(sysdate);

            print_debug('Need by date: ' || to_char(l_need_by_date,'DD-MON-YYYY HH24:MI:SS')
                        , 'do_restock'
                        , 9);

            IF p_src_type = 3
            THEN
                IF p_transact_flag = 'Y'
                THEN
                    print_debug('Calling INV_Create_Move_Order_PVT.Create_Move_Orders'
                                , 'do_restock'
                                , 9);
                    BEGIN
                        l_ret_value :=
                            INV_Create_Move_Order_PVT.Create_Move_Orders
                                ( p_item_id          => p_item_id
                                , p_quantity         => p_qty
                                , p_need_by_date     => l_need_by_date
                                , p_primary_uom_code => p_uom
                                , p_user_id          => p_user_id
                                , p_organization_id  => p_organization_id
                                , p_src_type         => p_src_type
                                , p_src_subinv       => p_src_subinv
                                , p_subinv           => p_subinv
                                );

                        IF l_ret_value <> FND_API.G_RET_STS_SUCCESS
                        THEN
                            RAISE move_ord_exc;
                        END IF;

                    EXCEPTION
                        WHEN OTHERS THEN
                             print_debug('Error creating move order: ' || sqlcode || ', ' || sqlerrm
                                         , 'do_restock'
                                         , 1);
                             RAISE move_ord_exc;
                    END;
                ELSE
                    print_debug('Src type is sub, item not transactable.', 'do_restock', 9);
                    RAISE move_ord_exc;
                END IF;

            ELSE

                re_po( p_item_id          => p_item_id
                     , p_qty              => p_qty
                     , p_nb_time          => l_need_by_date
                     , p_uom              => p_uom
                     , p_accru_acct       => p_accru_acct
                     , p_ipv_acct         => p_ipv_acct
                     , p_budget_acct      => p_budget_acct
                     , p_charge_acct      => p_charge_acct
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
                     , p_location_id      => p_location_id
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

            print_debug('Calling wip_calendar.estimate_leadtime to calculate need_by_date'
                        , 'do_restock'
                        , 9);

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
                  , x_ret_mesg         => x_ret_mesg);

            x_ret_stat := l_ret_stat;

        END IF;

    EXCEPTION
        WHEN move_ord_exc THEN
             SELECT meaning
               INTO x_ret_mesg
               FROM mfg_lookups
              WHERE lookup_type = 'INV_MMX_RPT_MSGS'
                AND lookup_code = 5;

             x_ret_stat := FND_API.G_RET_STS_ERROR;

        WHEN others THEN
             print_debug(sqlcode || ', ' || sqlerrm, 'do_restock', 1);
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

        po_exc           EXCEPTION;

    BEGIN
        IF G_TRACE_ON THEN
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
            print_debug('Null src type or invalid transact_flag, order_flag or purch_flag'
                        , 're_po', 9);
            RAISE po_exc;
        END IF;

        IF (p_charge_acct IS NULL)
            OR (p_accru_acct IS NULL)
            OR (p_ipv_acct IS NULL)
            OR ((p_encum_flag <> 'N') AND (p_budget_acct is NULL))
        THEN
            print_debug('Charge/accrual/IPV/budget accts not setup correctly.', 're_po', 9);
            RAISE po_exc;
        END IF;

        IF NVL(p_customer_id,0) < 0
        THEN
            print_debug('Invalid customer ID: ' || to_char(p_customer_id), 're_po', 9);
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

            print_debug('Rev ctl: ' || to_char(l_item_rev_ctl), 're_po', 9);

            IF l_item_rev_ctl = 2
            THEN
                SELECT MAX(revision)
                  INTO l_item_revision
                  FROM mtl_item_revisions mir
                 WHERE inventory_item_id = p_item_id
                   AND organization_id   = l_orgn_id
                   AND effectivity_date  < SYSDATE
                   AND effectivity_date  =
                       (
                        SELECT MAX(effectivity_date)
                          FROM mtl_item_revisions mir1
                         WHERE mir1.inventory_item_id = mir.inventory_item_id
                           AND mir1.organization_id   = mir.organization_id
                           AND effectivity_date       < SYSDATE
                       );
            END IF;

            print_debug('Item rev: ' || l_item_revision, 're_po', 9);
        END IF ;


        print_debug('Inserting into PO_REQUISITIONS_INTERFACE_ALL', 're_po', 9);

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
            DECODE(p_approval, 1, 'INCOMPLETE', 2,'APPROVED'),
            DECODE(p_src_type, 1, 'INVENTORY',  'VENDOR'),
            p_src_org,
            p_src_subinv,
            p_organization_id,
            p_subinv,
            p_employee_id,
            'INVENTORY',
            p_uom,
            p_location_id,
            p_item_id,
            DECODE(l_item_revision,'@@@',NULL,l_item_revision),
            p_qty,
            trunc(p_nb_time),
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
            print_debug(sqlcode || ', ' || sqlerrm, 're_po', 1);

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
                    , x_ret_mesg         OUT  NOCOPY VARCHAR2) IS

        wip_exc  EXCEPTION;

    BEGIN
        IF G_TRACE_ON THEN
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
                        ', p_pick_components: ' || p_pick_components
                        , 're_wip'
                        , 9);
        END IF;

        IF p_build_in_wip <> 'Y' OR p_pick_components <> 'N'
        THEN
            print_debug('Item either not build_in_wip or has pick components flag checked'
                        , 're_wip', 9);
            RAISE wip_exc;
        ELSE
            print_debug('Inserting into WIP_JOB_SCHEDULE_INTERFACE', 're_wip', 9);
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
               DECODE(p_approval,1,1,2,3));
        END IF;

        x_ret_stat := FND_API.G_RET_STS_SUCCESS;
        x_ret_mesg := '';

    EXCEPTION
        WHEN OTHERS THEN
            print_debug(sqlcode || ', ' || sqlerrm, 're_wip', 1);

            SELECT meaning
              INTO x_ret_mesg
              FROM mfg_lookups
             WHERE lookup_type = 'INV_MMX_RPT_MSGS'
               AND lookup_code = 2;

            x_ret_stat := FND_API.G_RET_STS_ERROR;
    END re_wip;
--
END CSP_Minmax_PVT;

/
