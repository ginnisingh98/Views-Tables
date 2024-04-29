--------------------------------------------------------
--  DDL for Package CSTPPINV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPINV" AUTHID CURRENT_USER AS
/* $Header: CSTPINVS.pls 120.4.12010000.2 2008/08/08 12:31:59 smsasidh ship $ */

PROCEDURE cost_inv_txn (
  i_pac_period_id           IN  NUMBER,
  i_legal_entity            IN  NUMBER,
  i_cost_type_id            IN  NUMBER,
  i_cost_group_id           IN  NUMBER,
  i_cost_method             IN  NUMBER,
  i_txn_id                  IN  NUMBER,
  i_txn_action_id           IN  NUMBER,
  i_txn_src_type_id         IN  NUMBER,
  i_item_id                 IN  NUMBER,
  i_txn_qty                 IN  NUMBER,
  i_txn_org_id              IN  NUMBER,
  i_txfr_org_id             IN  NUMBER,
  i_subinventory_code       IN  VARCHAR2,
  i_exp_flag                IN  NUMBER,
  i_exp_item                IN  NUMBER,
  i_pac_rates_id            IN  NUMBER,
  i_process_group           IN  NUMBER,
  i_master_org_id           IN  NUMBER,
  i_uom_control             IN  NUMBER,
  i_user_id                 IN  NUMBER,
  i_login_id                IN  NUMBER,
  i_request_id              IN  NUMBER,
  i_prog_id                 IN  NUMBER,
  i_prog_appl_id            IN  NUMBER,
  i_txn_category            IN  NUMBER,
  i_transfer_price_pd       IN  NUMBER := 0, -- INVCONV for process-discrete txfer
  o_err_num                 OUT NOCOPY NUMBER,
  o_err_code                OUT NOCOPY VARCHAR2,
  o_err_msg                 OUT NOCOPY VARCHAR2
);

PROCEDURE get_interorg_cost(
  i_legal_entity       IN       NUMBER,
  i_pac_period_id      IN       NUMBER,
  i_cost_type_id       IN       NUMBER,
  i_cost_group_id      IN       NUMBER,
  i_txn_cost_group_id  IN       NUMBER,
  i_txfr_cost_group_id IN       NUMBER,
  i_txn_id             IN       NUMBER,
  i_txn_action_id      IN       NUMBER,
  i_item_id            IN       NUMBER,
  i_txn_qty            IN       NUMBER,
  i_txn_org_id         IN       NUMBER,
  i_txfr_org_id        IN       NUMBER,
  i_user_id            IN       NUMBER,
  i_login_id           IN       NUMBER,
  i_request_id         IN       NUMBER,
  i_prog_id            IN       NUMBER,
  i_prog_appl_id       IN       NUMBER,
  i_transfer_price_pd  IN       NUMBER := 0, -- INVCONV for process-discrete txfer
  o_err_num            OUT NOCOPY       NUMBER,
  o_err_code           OUT NOCOPY       VARCHAR2,
  o_err_msg            OUT NOCOPY       VARCHAR2
);

PROCEDURE get_txfr_trp_cost(
  i_source_txn_id   IN   NUMBER,
  i_source_cost     IN   NUMBER,
  x_txfr_credit        OUT NOCOPY      NUMBER,
  x_trp_cost           OUT NOCOPY      NUMBER,
  o_err_num            OUT NOCOPY      NUMBER,
  o_err_code           OUT NOCOPY      VARCHAR2,
  o_err_msg            OUT NOCOPY      VARCHAR2
);

PROCEDURE add_elemental_cost(
            i_pac_period_id      IN       NUMBER,
            i_cost_type_id       IN       NUMBER,
            i_cost_group_id      IN       NUMBER,
            i_txn_id             IN       NUMBER,
            i_item_id            IN       NUMBER,
            i_cost_element_id    IN       NUMBER,
            i_level_type         IN       NUMBER,
            i_incr_cost          IN       NUMBER,
            i_user_id            IN       NUMBER,
            i_login_id           IN       NUMBER,
            i_request_id         IN       NUMBER,
            i_prog_id            IN       NUMBER,
            i_prog_appl_id       IN       NUMBER,
            o_err_num            OUT NOCOPY      NUMBER,
            o_err_code           OUT NOCOPY      VARCHAR2,
            o_err_msg            OUT NOCOPY      VARCHAR2
);

PROCEDURE insert_elemental_cost(
            i_pac_period_id     IN   NUMBER,
            i_cost_type_id       IN       NUMBER,
            i_cost_group_id      IN       NUMBER,
            i_txn_id             IN       NUMBER,
            i_item_id            IN       NUMBER,
            i_cost_element_id    IN       NUMBER,
            i_level_type         IN       NUMBER,
            i_cost               IN       NUMBER,
            i_user_id            IN       NUMBER,
            i_login_id           IN       NUMBER,
            i_request_id         IN       NUMBER,
            i_prog_id            IN       NUMBER,
            i_prog_appl_id       IN       NUMBER,
            o_err_num            OUT NOCOPY      NUMBER,
            o_err_code           OUT NOCOPY      VARCHAR2,
            o_err_msg            OUT NOCOPY      VARCHAR2
);

PROCEDURE get_pacp_cost(
            i_cost_source_cost_group     IN     NUMBER,
            i_pac_period_id      IN       NUMBER,
            i_cost_type_id       IN       NUMBER,
            i_cost_group_id      IN       NUMBER,
            i_txn_id             IN       NUMBER,
            i_item_id            IN       NUMBER,
            i_conv_rate          IN       NUMBER,
            i_user_id            IN       NUMBER,
            i_login_id           IN       NUMBER,
            i_request_id         IN       NUMBER,
            i_prog_id            IN       NUMBER,
            i_prog_appl_id       IN       NUMBER,
            x_pacp_used          OUT NOCOPY      NUMBER,
            x_pacp_cost          OUT NOCOPY      NUMBER,
            o_err_num            OUT NOCOPY      NUMBER,
            o_err_code           OUT NOCOPY      VARCHAR2,
            o_err_msg            OUT NOCOPY      VARCHAR2
);

PROCEDURE get_perp_ship_cost(
            i_pac_period_id      IN       NUMBER,
            i_cost_type_id       IN       NUMBER,
            i_cost_group_id      IN       NUMBER,
            i_txn_id             IN       NUMBER,
            i_mta_txn_id         IN       NUMBER,
            i_item_id            IN       NUMBER,
            i_from_org           IN       NUMBER,
            i_conv_rate          IN       NUMBER,
            i_user_id            IN       NUMBER,
            i_login_id           IN       NUMBER,
            i_request_id         IN       NUMBER,
            i_prog_id            IN       NUMBER,
            i_prog_appl_id       IN       NUMBER,
            x_perp_ship_cost     OUT NOCOPY      NUMBER,
            o_err_num            OUT NOCOPY      NUMBER,
            o_err_code           OUT NOCOPY      VARCHAR2,
            o_err_msg            OUT NOCOPY      VARCHAR2
);

PROCEDURE get_prev_period_cost(
            i_legal_entity       IN       NUMBER,
            i_cost_source_cost_group     IN     NUMBER,
            i_pac_period_id      IN       NUMBER,
            i_cost_type_id       IN       NUMBER,
            i_cost_group_id      IN       NUMBER,
            i_txn_id             IN       NUMBER,
            i_item_id            IN       NUMBER,
            i_conv_rate          IN       NUMBER,
            i_user_id            IN       NUMBER,
            i_login_id           IN       NUMBER,
            i_request_id         IN       NUMBER,
            i_prog_id            IN       NUMBER,
            i_prog_appl_id       IN       NUMBER,
            x_prev_period_id     OUT NOCOPY      NUMBER,
            x_prev_period_cost   OUT NOCOPY      NUMBER,
            o_err_num            OUT NOCOPY      NUMBER,
            o_err_code           OUT NOCOPY      VARCHAR2,
            o_err_msg            OUT NOCOPY      VARCHAR2
);

PROCEDURE get_snd_rcv_rate(
  i_txn_id      IN      NUMBER,
  i_from_org    IN      NUMBER,
  i_to_org      IN      NUMBER,
  o_conv_rate   OUT NOCOPY      NUMBER,
  o_err_num     OUT NOCOPY      NUMBER,
  o_err_code    OUT NOCOPY      VARCHAR2,
  o_err_msg     OUT NOCOPY      VARCHAR2
);

PROCEDURE get_from_to_uom(
  i_item_id     IN      NUMBER,
  i_from_org    IN      NUMBER,
  i_to_org      IN      NUMBER,
  o_from_uom    OUT NOCOPY     VARCHAR2,
  o_to_uom      OUT NOCOPY     VARCHAR2,
  o_err_num     OUT NOCOPY      NUMBER,
  o_err_code    OUT NOCOPY      VARCHAR2,
  o_err_msg     OUT NOCOPY      VARCHAR2
);


PROCEDURE get_um_rate(
  i_txn_org_id         IN       NUMBER,
  i_master_org_id      IN       NUMBER,
  i_txn_cost_group_id  IN       NUMBER,
  i_txfr_cost_group_id IN       NUMBER,
  i_txn_action_id      IN       NUMBER,
  i_item_id            IN       NUMBER,
  i_uom_control        IN       NUMBER,
  i_user_id            IN       NUMBER,
  i_login_id           IN       NUMBER,
  i_request_id         IN       NUMBER,
  i_prog_id            IN       NUMBER,
  i_prog_appl_id       IN       NUMBER,
  o_um_rate            OUT NOCOPY      NUMBER,
  o_err_num            OUT NOCOPY      NUMBER,
  o_err_code           OUT NOCOPY      VARCHAR2,
  o_err_msg            OUT NOCOPY      VARCHAR2
);

PROCEDURE cost_acct_events(
  i_pac_period_id           IN  NUMBER,
  i_legal_entity            IN  NUMBER,
  i_cost_type_id            IN  NUMBER,
  i_cost_group_id           IN  NUMBER,
  i_cost_method             IN  NUMBER,
  i_txn_id                  IN  NUMBER,
  i_item_id                 IN  NUMBER,
  i_txn_qty                 IN  NUMBER,
  i_txn_org_id              IN  NUMBER,
  i_master_org_id           IN  NUMBER,
  i_uom_control             IN  NUMBER,
  i_user_id                 IN  NUMBER,
  i_login_id                IN  NUMBER,
  i_request_id              IN  NUMBER,
  i_prog_id                 IN  NUMBER,
  i_prog_appl_id            IN  NUMBER,
  o_err_num                 OUT NOCOPY NUMBER,
  o_err_code                OUT NOCOPY VARCHAR2,
  o_err_msg                 OUT NOCOPY VARCHAR2
);

PROCEDURE get_exp_flag(
  i_item_id                 IN  NUMBER,
  i_txn_org_id              IN  NUMBER,
  i_subinventory_code       IN  VARCHAR2,
  o_exp_item    OUT NOCOPY	NUMBER,
  o_exp_flag    OUT NOCOPY	NUMBER,
   o_err_num     OUT NOCOPY      NUMBER,
  o_err_code    OUT NOCOPY     VARCHAR2,
  o_err_msg     OUT NOCOPY     VARCHAR2
  );

PROCEDURE cost_interorg_txn_grp1 (
  i_pac_period_id           IN  NUMBER,
  i_legal_entity            IN  NUMBER,
  i_cost_type_id            IN  NUMBER,
  i_cost_group_id           IN  NUMBER,
  i_cost_method             IN  NUMBER,
  i_start_date              IN  VARCHAR2,
  i_end_date                IN  VARCHAR2,
  i_pac_rates_id	    IN  NUMBER,
  i_process_group           IN  NUMBER,
  i_master_org_id           IN  NUMBER,
  i_uom_control             IN  NUMBER,
  i_user_id                 IN  NUMBER,
  i_login_id                IN  NUMBER,
  i_request_id              IN  NUMBER,
  i_prog_id                 IN  NUMBER,
  i_prog_appl_id            IN  NUMBER,
  o_err_num                 OUT NOCOPY NUMBER,
  o_err_code                OUT NOCOPY VARCHAR2,
  o_err_msg                 OUT NOCOPY VARCHAR2
);

 PROCEDURE cost_interorg_txn_grp2 (
  i_pac_period_id           IN  NUMBER,
  i_legal_entity            IN  NUMBER,
  i_cost_type_id            IN  NUMBER,
  i_cost_group_id           IN  NUMBER,
  i_cost_method             IN  NUMBER,
  i_start_date              IN  VARCHAR2,
  i_end_date                IN  VARCHAR2,
  i_pac_rates_id	    IN  NUMBER,
  i_process_group           IN  NUMBER,
  i_master_org_id           IN  NUMBER,
  i_uom_control             IN  NUMBER,
  i_user_id                 IN  NUMBER,
  i_login_id                IN  NUMBER,
  i_request_id              IN  NUMBER,
  i_prog_id                 IN  NUMBER,
  i_prog_appl_id            IN  NUMBER,
  o_err_num                 OUT NOCOPY NUMBER,
  o_err_code                OUT NOCOPY VARCHAR2,
  o_err_msg                 OUT NOCOPY VARCHAR2
);

PROCEDURE cost_txn_grp2 (
  i_pac_period_id           IN  NUMBER,
  i_legal_entity            IN  NUMBER,
  i_cost_type_id            IN  NUMBER,
  i_cost_group_id           IN  NUMBER,
  i_cost_method             IN  NUMBER,
  i_start_date              IN  VARCHAR2,
  i_end_date                IN  VARCHAR2,
  i_pac_rates_id	    IN  NUMBER,
  i_process_group           IN  NUMBER,
  i_master_org_id           IN  NUMBER,
  i_uom_control             IN  NUMBER,
  i_mat_relief_algo         IN  NUMBER,
  i_user_id                 IN  NUMBER,
  i_login_id                IN  NUMBER,
  i_request_id              IN  NUMBER,
  i_prog_id                 IN  NUMBER,
  i_prog_appl_id            IN  NUMBER,
  o_err_num                 OUT NOCOPY NUMBER,
  o_err_code                OUT NOCOPY VARCHAR2,
  o_err_msg                 OUT NOCOPY VARCHAR2
);

  TYPE t_item_id_tbl		IS TABLE OF MTL_SYSTEM_ITEMS.inventory_item_id%TYPE 	INDEX BY BINARY_INTEGER;
  TYPE t_cost_layer_id_tbl	IS TABLE OF CST_PAC_ITEM_COSTS.cost_layer_id%TYPE	INDEX BY BINARY_INTEGER;
  TYPE t_qty_layer_id_tbl	IS TABLE OF CST_PAC_QUANTITY_LAYERS.quantity_layer_id%TYPE	INDEX BY BINARY_INTEGER;
  TYPE t_cost_element_id_tbl    IS TABLE OF CST_COST_ELEMENTS.cost_element_id%TYPE	INDEX BY BINARY_INTEGER;
  TYPE t_level_type_tbl 	IS TABLE OF MTL_PAC_ACTUAL_COST_DETAILS.level_type%TYPE	INDEX BY BINARY_INTEGER;
  TYPE t_txn_category_tbl 	IS TABLE OF CST_PAC_PERIOD_BALANCES.txn_category%TYPE INDEX BY BINARY_INTEGER;
  TYPE t_item_balance_tbl	IS TABLE OF CST_PAC_ITEM_COST_DETAILS.item_balance%TYPE INDEX BY BINARY_INTEGER;
  TYPE t_make_balance_tbl	IS TABLE OF CST_PAC_ITEM_COST_DETAILS.make_balance%TYPE INDEX BY BINARY_INTEGER;
  TYPE t_buy_balance_tbl	IS TABLE OF CST_PAC_ITEM_COST_DETAILS.buy_balance%TYPE INDEX BY BINARY_INTEGER;

  TYPE t_item_index_tbl         IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  TYPE t_item_quantity_tbl	IS TABLE OF CST_PAC_ITEM_COSTS.total_layer_quantity%TYPE INDEX BY BINARY_INTEGER;
  TYPE t_make_quantity_tbl	IS TABLE OF CST_PAC_ITEM_COSTS.make_quantity%TYPE 	INDEX BY BINARY_INTEGER;
  TYPE t_buy_quantity_tbl	IS TABLE OF CST_PAC_ITEM_COSTS.buy_quantity%TYPE 	INDEX BY BINARY_INTEGER;
  TYPE t_issue_quantity_tbl	IS TABLE OF CST_PAC_ITEM_COSTS.issue_quantity%TYPE	INDEX BY BINARY_INTEGER;

  l_item_id_tbl		  t_item_id_tbl;
  l_cost_layer_id_tbl	  t_cost_layer_id_tbl;
  l_qty_layer_id_tbl	  t_qty_layer_id_tbl;

  l_cost_element_id_tbl   t_cost_element_id_tbl;
  l_level_type_tbl 	  t_level_type_tbl;
  l_txn_category_tbl      t_txn_category_tbl;

  l_item_balance_tbl	  t_item_balance_tbl;
  l_make_balance_tbl	  t_make_balance_tbl;
  l_buy_balance_tbl	  t_buy_balance_tbl;

  l_item_quantity_tbl	  t_item_quantity_tbl;
  l_make_quantity_tbl	  t_make_quantity_tbl;
  l_buy_quantity_tbl	  t_buy_quantity_tbl;
  l_issue_quantity_tbl	  t_issue_quantity_tbl;

  l_item_start_index_tbl  t_item_index_tbl;
  l_item_end_index_tbl    t_item_index_tbl;

END CSTPPINV;

/
