--------------------------------------------------------
--  DDL for Package WMS_RULES_WORKBENCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RULES_WORKBENCH_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSRLWBS.pls 120.2.12010000.2 2009/08/21 08:31:43 kjujjuru ship $ */

-- File        : WMSRLWBS.pls
-- Content     : WMS_RULES_WORKBENCH_PVT package spec
-- Description : This API is created  to handle all the procedures, function variables to be used by Rules WorkBench

-- Notes       :
-- List of  Pl/SQL Tables,Functions and  Procedures

-- 8809951 start
TYPE tbl_num          IS TABLE OF NUMBER        INDEX BY PLS_INTEGER;
g_item_cat_table        tbl_num;
g_uom_class_tbl            tbl_num;
g_hash_base           NUMBER        := 1;
g_hash_size           NUMBER        := POWER(2, 25);
-- 8809951 end

l_debug_mode  BOOLEAN := inv_pp_debug.is_debug_mode;

Function get_return_type_name(p_org_id number ,p_rule_type_code in number, p_return_type_code in varchar2, p_return_type_id in number) return varchar2;
Function get_customer_name(p_customer_id in number) return  varchar2;
Function get_organization_code(p_organization_id in number) return varchar2;
Function get_freight_code_name(p_org_id in number ,p_freight_code in varchar2 ) return varchar2;
Function get_item(p_org_id in number , p_inventory_item_id in number) return varchar2;
Function get_abc_group_class(p_org_id in number , p_assignment_group_id in number, p_class_id in number ) return varchar2;
Function get_category_set_name(p_org_id in number , p_category_set_id in number, p_category_id in number) return varchar2;
Function get_order_type_name(p_transaction_type_id in number) return varchar2;
Function get_project_name(p_project_id in number) return varchar2;
Function get_task_name(p_project_id in number , p_task_id in number) return varchar2;
Function get_vendor_name(p_org_id in number, p_vendor_id in number) return varchar2;
Function get_user_name(p_user_id in number) return varchar2;
Function get_transaction_action_name(p_transaction_action_id in number) return varchar2;
Function get_reason_name(p_reason_id in number) return varchar2;
Function get_transaction_source_name(p_transaction_source_type_id in number) return varchar2;
Function get_transaction_type_name(p_transaction_type_id in number ) return varchar2;
Function get_unit_of_measure(p_uom_code in varchar2) return varchar2;
Function get_uom_class_name(p_uom_class in varchar2) return varchar2;
Function get_item_type_name(p_item_type_code in varchar2) return varchar2;

---
Procedure Search
  ( p_api_version          IN   	NUMBER
   ,p_init_msg_list        IN   	VARCHAR2
   ,p_validation_level     IN   	NUMBER
   ,x_return_status        OUT  NOCOPY  VARCHAR2
   ,x_msg_count            OUT  NOCOPY	NUMBER
   ,x_msg_data             OUT  NOCOPY  VARCHAR2
   ,p_transaction_temp_id  IN   	NUMBER
   ,p_type_code            IN   	NUMBER
   ,x_return_type          OUT  NOCOPY  VARCHAR2
   ,x_return_type_id       OUT  NOCOPY  NUMBER
   ,p_organization_id      IN   	NUMBER
   ,x_sequence_number      OUT  NOCOPY  NUMBER
   );

  Procedure cg_mmtt_search
  ( p_api_version            IN   	NUMBER
     ,p_init_msg_list        IN   	VARCHAR2
     ,p_validation_level     IN   	NUMBER
     ,x_return_status        OUT NOCOPY VARCHAR2
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
     ,p_transaction_temp_id  IN   	NUMBER
     ,p_type_code            IN   	NUMBER
     ,x_return_type          OUT NOCOPY VARCHAR2
     ,x_return_type_id       OUT NOCOPY NUMBER
     ,p_organization_id      IN   	NUMBER
     ,x_sequence_number      OUT NOCOPY NUMBER
   );
  Function get_item_type( p_org_id IN NUMBER,p_inventory_item_id IN NUMBER )  	 return VARCHAR2;

  Function get_uom_class( p_uom_code IN VARCHAR2) 				 return VARCHAR2;
  Function get_vendor_id( p_reference IN VARCHAR2, p_reference_id  IN NUMBER)    return NUMBER;
  Function get_order_type_id( p_move_order_line_id IN NUMBER) return NUMBER;

  Function get_item_cat( p_org_id IN NUMBER,
                        p_inventory_item_id     IN NUMBER ,
                        p_category_set_id   	IN NUMBER,
                        p_category_id       	IN NUMBER) return VARCHAR2;

  Function get_group_class( p_inventory_item_id   IN NUMBER,
                            p_assignment_group_id IN NUMBER,
                            p_class_id 		  IN NUMBER ) return VARCHAR2;


  Procedure get_customer_freight_details(p_transaction_temp_id IN NUMBER,
                                         x_customer_id        OUT NOCOPY NUMBER,
                                         x_freight_code       OUT NOCOPY VARCHAR2);

 Function  get_location_name(p_location_id   IN NUMBER) Return VARCHAR2 ;

 Procedure cross_dock_search(
	p_rule_type_code         IN NUMBER,
	p_organization_id	 IN NUMBER,
	p_customer_id		 IN NUMBER,
	p_inventory_item_id	 IN NUMBER,
	p_item_type		 IN VARCHAR,
	p_vendor_id		 IN NUMBER,
	p_location_id		 IN NUMBER,
	p_project_id		 IN NUMBER,
	p_task_id		 IN NUMBER,
	p_user_id		 IN NUMBER,
	p_uom_code		 IN VARCHAR,
	p_uom_class		 IN VARCHAR,
	x_return_type		 OUT  NOCOPY VARCHAR2,
	x_return_type_id	 OUT  NOCOPY NUMBER, --criterion_id
	x_sequence_number	 OUT  NOCOPY NUMBER,
	x_return_status		 OUT  NOCOPY VARCHAR2);


End WMS_RULES_WORKBENCH_PVT;

/
