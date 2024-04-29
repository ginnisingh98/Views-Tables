--------------------------------------------------------
--  DDL for Package INV_MMX_WRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MMX_WRAPPER_PVT" AUTHID CURRENT_USER AS
/* $Header: INVMMXWS.pls 115.5 2003/09/29 22:25:11 yssingh ship $ */

   -- Package Variable Declarations.

   G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_MMX_WRAPPER_PVT';


-- PL/SQL table TYPE for set of subinventories.
TYPE SubInvTableType IS TABLE OF MTL_SECONDARY_INVENTORIES.SECONDARY_INVENTORY_NAME%TYPE INDEX BY BINARY_INTEGER;

PROCEDURE exec_min_max
( x_return_status     OUT NOCOPY VARCHAR2
, x_msg_count         OUT NOCOPY NUMBER
, x_msg_data          OUT NOCOPY VARCHAR2
, p_organization_id   IN  NUMBER
, p_user_id           IN  NUMBER
, p_subinv_tbl        IN  SubInvTableType
, p_employee_id       IN  NUMBER    DEFAULT NULL
, p_gen_report        IN  VARCHAR2  DEFAULT 'N'
, p_mo_line_grouping  IN  NUMBER    DEFAULT 1
, p_item_select       IN  VARCHAR2  DEFAULT NULL
, p_handle_rep_item   IN  NUMBER    DEFAULT 3
, p_pur_revision      IN  NUMBER    DEFAULT NULL
, p_cat_select        IN  VARCHAR2  DEFAULT NULL
, p_cat_set_id        IN  NUMBER    DEFAULT NULL
, p_mcat_struct       IN  NUMBER    DEFAULT NULL
, p_level             IN  NUMBER    DEFAULT 2
, p_restock           IN  NUMBER    DEFAULT 1
, p_include_nonnet    IN  NUMBER    DEFAULT 1
, p_include_po        IN  NUMBER    DEFAULT 1
, p_include_mo        IN  NUMBER    DEFAULT 1
, p_include_wip       IN  NUMBER    DEFAULT 2
, p_include_if        IN  NUMBER    DEFAULT 1
, p_net_rsv           IN  NUMBER    DEFAULT 1
, p_net_unrsv         IN  NUMBER    DEFAULT 1
, p_net_wip           IN  NUMBER    DEFAULT 2
, p_dd_loc_id         IN  NUMBER    DEFAULT NULL
, p_buyer_hi          IN  VARCHAR2  DEFAULT NULL
, p_buyer_lo          IN  VARCHAR2  DEFAULT NULL
, p_range_buyer       IN  VARCHAR2  DEFAULT '1 = 1'
, p_range_sql         IN  VARCHAR2  DEFAULT '1 = 1'
, p_sort              IN  VARCHAR2  DEFAULT 1
, p_selection         IN  NUMBER    DEFAULT 3
, p_sysdate           IN  DATE      DEFAULT SYSDATE
, p_s_cutoff          IN  DATE      DEFAULT NULL
, p_d_cutoff          IN  DATE      DEFAULT NULL
);

PROCEDURE do_restock
( x_return_status            OUT  NOCOPY VARCHAR2
, x_msg_count                OUT  NOCOPY NUMBER
, x_msg_data                 OUT  NOCOPY VARCHAR2
, p_item_id                  IN   NUMBER
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
, p_mo_line_grouping         IN   NUMBER DEFAULT 1
);


PROCEDURE get_move_order_info
( x_return_status         OUT  NOCOPY VARCHAR2
, x_msg_count             OUT  NOCOPY NUMBER
, x_msg_data              OUT  NOCOPY VARCHAR2
, x_move_order_header_id  OUT  NOCOPY NUMBER
, x_move_order_line_num   OUT  NOCOPY NUMBER
, p_user_id               IN   NUMBER
, p_organization_id       IN   NUMBER
, p_subinv                IN   VARCHAR2
, p_src_subinv            IN   VARCHAR2
, p_approval              IN   NUMBER
, p_need_by_date          IN   DATE
);

END INV_MMX_WRAPPER_PVT;

 

/
