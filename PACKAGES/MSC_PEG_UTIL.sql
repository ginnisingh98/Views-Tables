--------------------------------------------------------
--  DDL for Package MSC_PEG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_PEG_UTIL" AUTHID CURRENT_USER AS
/* $Header: MSCPEGS.pls 115.6 2004/06/10 18:20:36 cnazarma noship $ */



TYPE itemOrg_tab   IS TABLE OF msc_flp_supply_demand_v.item_org%TYPE;
TYPE pegId_tab     IS TABLE OF msc_flp_supply_demand_v.pegging_id%TYPE;
TYPE prevPegId_tab IS TABLE OF msc_flp_supply_demand_v.prev_pegging_id%TYPE;
TYPE Qty_Tab       IS TABLE OF msc_flp_supply_demand_v.demand_qty%TYPE;
TYPE Date_tab   IS TABLE OF msc_flp_supply_demand_v.demand_date%TYPE;
TYPE OrderName_tab    IS TABLE OF msc_flp_supply_demand_v.origination_name%TYPE;
TYPE demId_tab     IS TABLE OF msc_flp_supply_demand_v.demand_id%TYPE;
TYPE trxId_tab     IS TABLE OF msc_flp_supply_demand_v.transaction_id%TYPE;
TYPE itemId_tab    IS TABLE OF msc_flp_supply_demand_v.item_id%TYPE;
TYPE pegQty_tab    IS TABLE OF msc_flp_supply_demand_v.pegged_qty%TYPE;
TYPE orderNum_tab  IS TABLE OF msc_flp_supply_demand_v.end_disposition%TYPE;
TYPE orderTyp_tab  IS TABLE OF msc_flp_supply_demand_v.order_type%TYPE;
TYPE disp_tab      IS TABLE OF msc_flp_supply_demand_v.end_disposition%TYPE;
TYPE end_demClass_tab  IS TABLE of msc_flp_supply_demand_v.end_demand_class%TYPE;

TYPE itemorg_pegnode_rec is RECORD (
Item_Org           ItemOrg_tab := itemOrg_tab(),
Pegging_id         pegId_tab := pegId_tab(),
Prev_pegging_id    prevPegId_tab := prevPegId_tab(),
Qty                Qty_Tab := Qty_Tab(),
Peg_Date           Date_tab := Date_tab(),
Order_name         OrderName_tab := OrderName_tab(),
Demand_id          demId_tab := demId_tab(),
Transaction_id     trxId_tab := trxId_tab(),
Item_id            itemId_tab := itemId_tab(),
Pegged_qty         pegQty_tab := pegQty_tab(),
Order_number       orderNum_tab := orderNum_tab(),
Order_type         orderTyp_tab := orderTyp_tab(),
Disposition        disp_tab     := disp_tab(),
End_Demand_class   end_demClass_Tab := end_demClass_Tab());

/*
TYPE itemorg_sup_rec is RECORD (
Item_Org           ItemOrg_tab := itemOrg_tab(),
supply_qty         demQty_Tab := demQty_Tab(),
supply_date        demDate_tab := demDate_tab(),
order_name         origin_tab := origin_tab(),
pegging_id         pegId_tab := pegId_tab(),
prev_pegging_id    prevPegId_tab := prevPegId_tab(),
transaction_id     trxId_tab := trxId_tab(),
demand_id          demId_tab := demId_tab(),
pegged_qty         demQty_Tab := demQty_Tab(),
item_id            itemId_tab := itemId_tab(),
order_type         orderTyp_tab := orderTyp_tab(),
disposition        pegId_tab := pegId_tab());
*/
---bug #3556405 while tranfering code from MSCFTPEG.pld (115.176) to MSCPEGS.pls and MSCPEGB.pls we missed to pass V_PREV_PEGGING_ID
---variable as a part of node value instead we pass its value -111 for supply node so to take care that we created additional
---parameter in  p_prev_pegging_value in Procedure get_suptree_dem_values of MSCPEGS.pls package.
Procedure get_suptree_dem_values(p_plan_id IN NUMBER,
                      p_transaction_id     IN NUMBER,
                      x_itemorg_pegnode_rec    OUT NOCOPY  MSC_PEG_UTIL.itemorg_pegnode_rec,
                      p_item_id            IN NUMBER,
                      p_pegging_id         IN NUMBER,
                      p_instance_id        IN NUMBER,
                      p_trigger_node_type  IN NUMBER DEFAULT 2,
                      p_condense_supply_oper IN NUMBER DEFAULT 0,
                      p_hide_oper            IN NUMBER DEFAULT 0,
                      p_organization_id      IN NUMBER DEFAULT NULL,
                      p_supply_pegging        IN NUMBER DEFAULT 0);
---bug #3556405
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
                                  p_transaction_id     IN NUMBER,
                                  x_itemorg_pegnode_rec    OUT NOCOPY  MSC_PEG_UTIL.itemorg_pegnode_rec,
                                  p_instance_id        IN NUMBER,
                                  p_organization_id    IN NUMBER,
                                  p_bom_item_type      IN NUMBER);



Procedure get_suptree_sup_values(p_plan_id    IN NUMBER,
                            p_demand_id       IN NUMBER,
                            p_sr_instance_id  IN NUMBER,
                            p_organization_id IN NUMBER,
                            p_prev_peg_id     IN NUMBER,
                  x_itemorg_pegnode_rec  OUT NOCOPY MSC_PEG_UTIL.itemorg_pegnode_rec,
                            p_supply_pegging  IN NUMBER DEFAULT 0 ); -- demand pegging ( peg up)

END MSC_PEG_UTIL;

 

/
