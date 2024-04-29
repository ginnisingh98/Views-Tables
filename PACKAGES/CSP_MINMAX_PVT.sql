--------------------------------------------------------
--  DDL for Package CSP_MINMAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_MINMAX_PVT" AUTHID CURRENT_USER AS
/* $Header: cspvmmxs.pls 115.0 2003/04/25 18:49:49 phegde noship $*/

G_PKG_NAME   CONSTANT VARCHAR2(30) := 'CSP_Minmax_PVT';

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
                               );

    --Bug# 2677358
    FUNCTION get_onhand_qty( p_include_nonnet  NUMBER
                       , p_level           NUMBER
                       , p_org_id          NUMBER
                       , p_subinv          VARCHAR2
                       , p_item_id         NUMBER
                       , p_sysdate         DATE) RETURN NUMBER;

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
                        , x_ret_mesg                 OUT  NOCOPY VARCHAR2);


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

--
END CSP_Minmax_PVT;

 

/
