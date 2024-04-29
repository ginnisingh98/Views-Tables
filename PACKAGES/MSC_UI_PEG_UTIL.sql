--------------------------------------------------------
--  DDL for Package MSC_UI_PEG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_UI_PEG_UTIL" AUTHID CURRENT_USER AS
/* $Header: MSCPEGUS.pls 120.1 2007/10/01 19:25:16 eychen ship $ */


TYPE peg_node_rec_values is RECORD (
Item_Org           varchar2(2000),
Pegging_id         number,
Prev_pegging_id    number,
Qty                number,
Peg_Date           date,
Order_name         varchar2(2000),
Demand_id          number,
Transaction_id     number,
Item_id            number,
Pegged_qty         number,
Order_number       varchar2(2000),
Order_type         number,
Disposition        varchar2(2000),
End_Demand_class   varchar2(2000));


TYPE peg_node_rec_values_table is table of peg_node_rec_values index by binary_integer;


Procedure get_suptree_dem_values(p_plan_id     IN NUMBER,
                      p_transaction_id         IN NUMBER,
                      x_itemorg_pegnode_rec    OUT NOCOPY MSC_UI_PEG_UTIL.peg_node_rec_values_table,
                      p_item_id                IN NUMBER,
                      p_pegging_id             IN NUMBER,
                      p_instance_id            IN NUMBER,
                      p_trigger_node_type      IN NUMBER DEFAULT 2,
                      p_condense_supply_oper   IN NUMBER DEFAULT 0,
                      p_hide_oper              IN NUMBER DEFAULT 0,
                      p_organization_id        IN NUMBER DEFAULT NULL,
		      p_supply_pegging  IN NUMBER DEFAULT 0 ,
		      p_show_item_desc  IN NUMBER DEFAULT 2);

Procedure get_label_and_nodevalue(Item_org             IN VARCHAR2,
                                  Qty                  IN NUMBER,
                                  Pegged_qty           IN NUMBER,
                                  Peg_date             IN DATE,
                                  Order_name           IN VARCHAR2,
                                  end_demand_class     IN VARCHAR2,
                                  order_type           IN NUMBER,
                                  Disposition          IN NUMBER,
                                  Pegging_id           IN NUMBER,
                                  Prev_pegging_id      IN NUMBER,
                                  Demand_id            IN NUMBER,
                                  Transaction_id       IN NUMBER,
                                  Item_id              IN NUMBER,
                                  x_node_value          OUT NOCOPY varchar2,
                                  x_node_label          OUT NOCOPY varchar2,
                                  p_tmp                 IN  NUMBER,
                                  p_supply_org_id       IN  NUMBER,
                                  pvt_so_number         IN  VARCHAR2,
                                  pvt_l_node_number     IN  NUMBER,
                                  p_constr_label        IN  BOOLEAN default FALSE,
                                  p_node_type           IN  NUMBER  default 1,
                                  p_calling_module      IN  NUMBER  default 1,
				  p_prev_pegging_value  IN  NUMBER default null  );

Procedure  get_disposition_id(p_demand_id        IN  NUMBER,
                              x_disposition_id   OUT NOCOPY NUMBER,
                              x_origination_type OUT NOCOPY NUMBER,
                              p_sr_instance_id   IN  NUMBER,
                              p_organization_id  IN  NUMBER,
                              p_plan_id          IN  NUMBER);

Procedure get_demtree_dem_values( p_plan_id IN NUMBER,
                                  p_transaction_id       IN NUMBER,
                                  x_itemorg_pegnode_rec  OUT NOCOPY MSC_UI_PEG_UTIL.peg_node_rec_values_table,
                                  p_instance_id          IN NUMBER,
                                  p_organization_id      IN NUMBER,
                                  p_bom_item_type        IN NUMBER,
				  p_show_item_desc       IN NUMBER DEFAULT 2);



Procedure get_suptree_sup_values(p_plan_id    IN NUMBER,
                            p_demand_id       IN NUMBER,
                            p_sr_instance_id  IN NUMBER,
                            p_organization_id IN NUMBER,
                            p_prev_peg_id     IN NUMBER,
                            x_itemorg_pegnode_rec  OUT NOCOPY MSC_UI_PEG_UTIL.peg_node_rec_values_table,
                            p_supply_pegging  IN NUMBER DEFAULT 0 , -- demand pegging ( peg up)
			    p_show_item_desc  IN NUMBER DEFAULT 2);
Procedure get_suptree_dem_values_rep(p_plan_id	IN NUMBER,
                      p_transaction_id		IN NUMBER,
                      x_itemorg_pegnode_rec	OUT NOCOPY MSC_UI_PEG_UTIL.peg_node_rec_values_table,
                      p_instance_id		IN NUMBER,
                      p_supply_pegging  IN NUMBER DEFAULT 0 ,
		      p_show_item_desc  IN NUMBER DEFAULT 2,
		      p_show_ss_demands IN NUMBER DEFAULT 1);

END MSC_UI_PEG_UTIL;

/
