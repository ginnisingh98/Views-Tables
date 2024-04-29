--------------------------------------------------------
--  DDL for Package WPS_SUPPLY_DEMAND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WPS_SUPPLY_DEMAND" AUTHID CURRENT_USER AS
/* $Header: wpsmtsds.pls 120.2 2006/03/09 11:18:35 mlouie noship $  */

TYPE Supply_Demand_Record_Type     IS RECORD
  ( reservation_type            NUMBER,
    supply_demand_source_type   NUMBER,
    txn_source_type_id          NUMBER,
    supply_demand_source_id     NUMBER,
    supply_demand_type          NUMBER,
    supply_demand_quantity      NUMBER,
    supply_demand_date          NUMBER,
    inventory_item_id           NUMBER,
    organization_id             NUMBER);


TYPE Supply_Demand_Tbl_Type IS TABLE OF Supply_Demand_Record_Type
  INDEX BY BINARY_INTEGER;

TYPE Number_Tbl_Type IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;


g_supply_demand_table     SUPPLY_DEMAND_TBL_TYPE;


FUNCTION Collect_Supply_Demand_Info(p_group_id          IN NUMBER,
				    p_sys_seq_num       IN NUMBER,
				    p_mrp_status        IN NUMBER,
				    p_org_id            IN NUMBER) RETURN NUMBER;


PROCEDURE Collect_Supply_Demand_Info(p_group_id          IN NUMBER,
				     p_sys_seq_num       IN NUMBER,
				     p_mrp_status        IN NUMBER,
				     p_org_id            IN NUMBER,
				     p_sup_dem_table     IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				     ERRBUF              OUT NOCOPY VARCHAR2,
				     RETCODE             OUT NOCOPY NUMBER);

PROCEDURE Get_Supply_Demand_Info(x_supply_demand_table OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE);


PROCEDURE Get_Supply_Demand_Info(p_starting_index                  IN  NUMBER DEFAULT 1,
				 p_ending_index                    IN  NUMBER DEFAULT -1,
				 x_rows_fetched                    OUT NOCOPY NUMBER,
				 x_reservation_type_tbl            OUT NOCOPY Number_Tbl_Type,
				 x_supply_demand_src_type_tbl      OUT NOCOPY Number_Tbl_Type,
				 x_txn_source_type_id_tbl          OUT NOCOPY Number_Tbl_Type,
				 x_supply_demand_source_id_tbl     OUT NOCOPY Number_Tbl_Type,
				 x_supply_demand_type_tbl          OUT NOCOPY Number_Tbl_Type,
				 x_supply_demand_quantity_tbl      OUT NOCOPY Number_Tbl_Type,
				 x_supply_demand_date_tbl          OUT NOCOPY Number_Tbl_Type,
				 x_inventory_item_id_tbl           OUT NOCOPY Number_Tbl_Type,
				 x_organization_id_tbl             OUT NOCOPY Number_Tbl_Type);

PROCEDURE Clear_Supply_Demand_Info;


PROCEDURE Collect_Supply_Info(p_group_id          IN NUMBER,
			      p_sys_seq_num       IN NUMBER,
			      p_mrp_status        IN NUMBER,
			      p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
			      ERRBUF              OUT NOCOPY VARCHAR2,
			      RETCODE             OUT NOCOPY NUMBER);

PROCEDURE Collect_Demand_Info(p_group_id          IN NUMBER,
			      p_sys_seq_num       IN NUMBER,
			      p_mrp_status        IN NUMBER,
			      p_org_id            IN NUMBER,
			      p_demand_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
			      ERRBUF              OUT NOCOPY VARCHAR2,
			      RETCODE             OUT NOCOPY NUMBER);

PROCEDURE Collect_OnHand_Supply(p_group_id          IN NUMBER,
				p_sys_seq_num       IN NUMBER,
				p_mrp_status        IN NUMBER,
				p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				ERRBUF              OUT NOCOPY VARCHAR2,
				RETCODE             OUT NOCOPY NUMBER);

PROCEDURE Collect_User_Supply(p_group_id          IN NUMBER,
			      p_sys_seq_num       IN NUMBER,
			      p_mrp_status        IN NUMBER,
			      p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
			      ERRBUF              OUT NOCOPY VARCHAR2,
			      RETCODE             OUT NOCOPY NUMBER);

PROCEDURE Collect_MTL_Supply(p_group_id          IN NUMBER,
			     p_sys_seq_num       IN NUMBER,
			     p_mrp_status        IN NUMBER,
			     p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
			     ERRBUF              OUT NOCOPY VARCHAR2,
			     RETCODE             OUT NOCOPY NUMBER);

PROCEDURE Collect_DiscreteJob_Supply(p_group_id          IN NUMBER,
				     p_sys_seq_num       IN NUMBER,
				     p_mrp_status        IN NUMBER,
				     p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				     ERRBUF              OUT NOCOPY VARCHAR2,
				     RETCODE             OUT NOCOPY NUMBER);

PROCEDURE Collect_WipNegReq_Supply(p_group_id          IN NUMBER,
				   p_sys_seq_num       IN NUMBER,
				   p_mrp_status        IN NUMBER,
				   p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				   ERRBUF              OUT NOCOPY VARCHAR2,
				   RETCODE             OUT NOCOPY NUMBER);

PROCEDURE Collect_RepSched_Supply(p_group_id          IN NUMBER,
				  p_sys_seq_num       IN NUMBER,
				  p_mrp_status        IN NUMBER,
				  p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				  ERRBUF              OUT NOCOPY VARCHAR2,
				  RETCODE             OUT NOCOPY NUMBER);

PROCEDURE Collect_FlowSched_Supply(p_group_id          IN NUMBER,
				   p_sys_seq_num       IN NUMBER,
				   p_mrp_status        IN NUMBER,
				   p_supply_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				   ERRBUF              OUT NOCOPY VARCHAR2,
				   RETCODE             OUT NOCOPY NUMBER);

PROCEDURE Collect_DiscreteJob_Demand(p_group_id          IN NUMBER,
				     p_sys_seq_num       IN NUMBER,
				     p_mrp_status        IN NUMBER,
				     p_demand_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				     ERRBUF              OUT NOCOPY VARCHAR2,
				     RETCODE             OUT NOCOPY NUMBER);

PROCEDURE Collect_RepSched_Demand(p_group_id          IN NUMBER,
				  p_sys_seq_num       IN NUMBER,
				  p_mrp_status        IN NUMBER,
				  p_demand_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				  ERRBUF              OUT NOCOPY VARCHAR2,
				  RETCODE             OUT NOCOPY NUMBER);

PROCEDURE Collect_User_Demand(p_group_id          IN NUMBER,
			      p_sys_seq_num       IN NUMBER,
			      p_mrp_status        IN NUMBER,
			      p_demand_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
			      ERRBUF              OUT NOCOPY VARCHAR2,
			      RETCODE             OUT NOCOPY NUMBER);

PROCEDURE Collect_FlowSched_Demand(p_group_id          IN NUMBER,
				   p_sys_seq_num       IN NUMBER,
				   p_mrp_status        IN NUMBER,
				   p_demand_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				   ERRBUF              OUT NOCOPY VARCHAR2,
				   RETCODE             OUT NOCOPY NUMBER);

PROCEDURE Collect_SalesOrder_Demand(p_group_id          IN NUMBER,
				    p_sys_seq_num       IN NUMBER,
				    p_mrp_status        IN NUMBER,
				    p_org_id            IN NUMBER,
				    p_demand_table      IN OUT NOCOPY SUPPLY_DEMAND_TBL_TYPE,
				    ERRBUF              OUT NOCOPY VARCHAR2,
				    RETCODE             OUT NOCOPY NUMBER);

END WPS_SUPPLY_DEMAND;

 

/
