--------------------------------------------------------
--  DDL for Package INV_MINMAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MINMAX_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVMMXS.pls 120.1.12010000.2 2010/02/03 13:25:25 sanjeevs ship $*/

 G_PKG_NAME   CONSTANT VARCHAR2(30) := 'INV_Minmax_PVT';

    --
    -- Added 3 default NULL parameters p_cust_site_id,p_vmi_enabled  and p_gen_report
    -- to the procedure as part of Patchset I enhancements Replenishment Consolidation
    -- and Min Max Lead Time Enhancement.
    --

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
                               , p_cust_site_id      IN  NUMBER   DEFAULT NULL
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
                               , p_gen_report        IN  VARCHAR2 DEFAULT NULL
                               , x_return_status     OUT NOCOPY VARCHAR2
                               , x_msg_data          OUT NOCOPY VARCHAR2
                               , p_osfm_batch_id     IN  NUMBER DEFAULT NULL   /* Added for Bug 6807835 */
                               );

    --Bug# 2677358
    FUNCTION get_onhand_qty( p_include_nonnet  NUMBER
                       , p_level           NUMBER
                       , p_org_id          NUMBER
                       , p_subinv          VARCHAR2
                       , p_item_id         NUMBER
                       , p_sysdate         DATE) RETURN NUMBER;

    --
    -- Added a default NULL parameters p_customer_site_id
    -- to the procedure as part of Patchset I Min Max Lead Time Enhancement.
    --
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
                        , p_customer_site_id         IN   NUMBER DEFAULT NULL
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
                        , p_osfm_batch_id            IN   NUMBER DEFAULT NULL   /* Added for Bug 6807835 */
                        );

    /* nsinghi MIN-MAX INVCONV start */
    /* Procedure do_restock overloaded as part of inventory convergence to make
    call to process parameters. */

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
                        , p_customer_site_id         IN   NUMBER DEFAULT NULL
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
                        , p_execution_enabled        IN   VARCHAR2 /* Added for process orgs */
                        , p_recipe_enabled           IN   VARCHAR2 /* Added for process orgs */
                        , p_process_enabled          IN   VARCHAR2 /* Added for process orgs */
                        , x_ret_stat                 OUT  NOCOPY VARCHAR2
                        , x_ret_mesg                 OUT  NOCOPY VARCHAR2
                        , p_osfm_batch_id            IN   NUMBER DEFAULT NULL   /* Added for Bug 6807835 */
                        );
                        /* nsinghi MIN-MAX INVCONV end */

    FUNCTION get_shipped_qty( p_organization_id    IN      NUMBER
                            , p_inventory_item_id  IN      NUMBER
                            , p_order_line_id      IN      NUMBER) RETURN NUMBER;

    PRAGMA RESTRICT_REFERENCES(get_shipped_qty, WNDS);


    FUNCTION get_staged_qty( p_org_id          NUMBER
                           , p_subinv          VARCHAR2
                           , p_item_id         NUMBER
                           , p_order_line_id   NUMBER
                           , p_include_nonnet  NUMBER) RETURN NUMBER;

    PRAGMA RESTRICT_REFERENCES(get_staged_qty, WNDS);


    FUNCTION get_pick_released_qty( p_org_id          NUMBER
                                  , p_subinv          VARCHAR2
                                  , p_item_id         NUMBER
                                  , p_order_line_id   NUMBER) RETURN NUMBER;

    PRAGMA RESTRICT_REFERENCES(get_pick_released_qty, WNDS);

    --Bug 9122329, Function added for getting the UOM_CODE.
    FUNCTION get_item_uom_code (p_uom_name   VARCHAR2) RETURN VARCHAR2;
--
END INV_Minmax_PVT;

/
