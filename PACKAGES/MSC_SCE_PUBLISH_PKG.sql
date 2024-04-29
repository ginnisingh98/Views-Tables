--------------------------------------------------------
--  DDL for Package MSC_SCE_PUBLISH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SCE_PUBLISH_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCXPUBS.pls 120.0.12010000.3 2008/10/07 09:02:37 hbinjola ship $ */

G_MSC_CP_DEBUG           VARCHAR2(10) := NVL(FND_PROFILE.VALUE('MSC_CP_DEBUG'), '0');
G_NULL_STRING   CONSTANT VARCHAR2(10) := '-234567' ; -- bug#7310179

  /* PL/SQL table types */
TYPE companyNameList        IS TABLE OF msc_companies.company_name%TYPE;
TYPE companySiteList        IS TABLE OF msc_company_sites.company_site_name%TYPE;
TYPE itemNameList           IS TABLE OF msc_system_items.item_name%TYPE;
TYPE itemDescList           IS TABLE OF msc_system_items.description%TYPE;
TYPE itemUomList            IS TABLE OF msc_system_items.uom_code%TYPE;
TYPE fndMeaningList         IS TABLE OF fnd_lookup_values.meaning%TYPE;
TYPE plannerCodeList        IS TABLE OF msc_system_items.planner_code%TYPE;
TYPE planningGroupList      IS TABLE OF msc_supplies.planning_group%TYPE;
TYPE numberList             IS TABLE OF Number;
TYPE dateList               IS TABLE OF Date;
TYPE orderNumList           IS TABLE OF msc_sup_dem_entries.order_number%TYPE; -- bug#7310179
TYPE lineNumList            IS TABLE OF msc_sup_dem_entries.line_number%TYPE;-- bug#7310179



ORDER_FORECAST		             number := 2;
PLANNED_ORDER		               number := 5;
PURCHASE_ORDER		             number := 1;
REQUISITION		                 number := 2;
CP_PURCHASE_ORDER_FROM_PLAN    number := 22;
CP_RELEASED_PLANNED_ORDER      number := 23;
CP_PLANNED_ORDER	             number := 24;
EXPECTED_INBOUND_SHIPMENT      number := 51;
CP_PLANNED_INBOUND_SHIPMENT    number := 46;
CP_RELEASED_INBOUND_SHIPMENT   number := 47;
-- bug#6893383 CP-SPP Integration
SPP_PLAN                      constant number := 8;
PLANNED_NEW_BUY_ORDER         constant number := 76;
PLANNED_EXTERNAL_REPAIR_ORDER constant number := 78;
EXTERNAL_REPAIR_ORDER         constant number := 74;
RETURNS_FORECAST              constant number := 50;
DEFECTIVE_OUTBOUND_SHIPMENT   constant number := 51;
SALES_ORDER                   constant number := 30;
INTRANSIT_SHIPMENT            constant number := 11; --bug#7443302
INTRANSIT_RECEIPT            constant number  := 12; --bug#7443302
-- dummy order type used only in this package
PLANNED_TRANSFER_DEF          constant number := 501;
ISO_DEF                       constant number := 502;
INTRANSIT_SHIPMENT_DEF        constant number := 503; --bug#7443302
INTRANSIT_RECEIPT_DEF         constant number := 504; --bug#7443302


PROCEDURE publish_plan_orders (
  p_errbuf                  out nocopy varchar2,
  p_retcode                 out nocopy varchar2,
  p_plan_id                 in number,
  p_org_code                in varchar2 default null,
  p_planner_code            in varchar2 default null,
  p_abc_class               in varchar2 default null,
  p_item_id                 in number   default null,
  p_item_list		            in varchar2  default null,
  p_planning_gp             in varchar2 default null,
  p_project_id              in number   default null,
  p_task_id                 in number   default null,
  p_supplier_id             in number   default null,
  p_supplier_site_id        in number   default null,
  p_horizon_start           in varchar2,
  p_horizon_end             in varchar2,
  p_auto_version            in number   default 1,
  p_version                 in number   default null,
  p_purchase_order          in number   default 2,
  p_requisition             in number   default 2,
  p_overwrite		            in number   default 1,
  p_publish_dos             in number default 1   -- bug#6893383 **SPP-Publish dos for defective supplier**
);



PROCEDURE get_optional_info(
  t_item_id             IN numberList,
  t_org_id              IN numberList,
  t_sr_instance_id      IN numberList,
  t_source_supp_id      IN numberList,
  t_source_supp_site_id IN numberList,
  t_uom_code            IN itemUomList,
  t_qty                 IN numberList,
  t_planned_order_qty 	IN numberList,
  t_released_qty	      IN numberList,
  t_base_item_id	      IN numberList,
  t_base_item_name	    IN OUT NOCOPY itemNameList,
  t_base_item_desc	    IN OUT NOCOPY itemDescList,
  t_master_item_name 	  IN OUT NOCOPY itemNameList,
  t_master_item_desc 	  IN OUT NOCOPY itemDescList,
  t_supp_item_name   	  IN OUT NOCOPY itemNameList,
  t_supp_item_desc   	  IN OUT NOCOPY itemDescList,
  t_tp_uom           	  IN OUT NOCOPY itemUomList,
  t_tp_qty           	  IN OUT NOCOPY numberList,
  t_tp_planned_order_qty IN OUT NOCOPY numberList,
  t_tp_released_qty	    IN OUT NOCOPY numberList,
  t_ship_date        	  IN OUT NOCOPY dateList,
  t_receipt_date       	IN dateList,
  t_pub_id           	  IN OUT NOCOPY numberList,
  t_pub              	  IN OUT NOCOPY companyNameList,
  t_pub_site_id      	  IN OUT NOCOPY numberList,
  t_pub_site         	  IN OUT NOCOPY companySiteList,
  t_supp_id          	  IN OUT NOCOPY numberList,
  t_supp             	  IN OUT NOCOPY companyNameList,
  t_supp_site_id     	  IN OUT NOCOPY numberList,
  t_supp_site        	  IN OUT NOCOPY companySiteList
);


PROCEDURE insert_into_sup_dem (
  t_pub                       IN companyNameList,
  t_pub_id                    IN numberList,
  t_pub_site                  IN companySiteList,
  t_pub_site_id               IN numberList,
  t_item_id                   IN numberList,
  t_order_type		            IN numberList,
  t_qty                       IN numberList,
  t_planned_order_qty	        IN numberList,
  t_released_qty	            IN numberList,
  t_supp                      IN companyNameList,
  t_supp_id                   IN numberList,
  t_supp_site                 IN companySiteList,
  t_supp_site_id              IN numberList,
  t_owner_item_name           IN itemNameList,
  t_owner_item_desc           IN itemDescList,
  t_base_item_id	            IN numberList,
  t_base_item_name	          IN itemNameList,
  t_base_item_desc	          IN itemDescList,
  t_proj_number               IN numberList,
  t_task_number               IN numberList,
  t_planning_gp               IN planningGroupList,
  t_uom_code                  IN itemUomList,
  t_planner_code              IN plannerCodeList,
  t_bucket_type               IN numberList,
  t_key_date                  IN dateList,
  t_ship_date                 IN dateList,
  t_receipt_date              IN dateList,
  t_master_item_name          IN itemNameList,
  t_master_item_desc          IN itemDescList,
  t_supp_item_name            IN itemNameList,
  t_supp_item_desc            IN itemDescList,
  t_tp_uom                    IN itemUomList,
  t_tp_qty                    IN numberList,
  t_tp_planned_order_qty      IN numberList,
  t_tp_released_qty	          IN numberList,
  p_version                   IN varchar2,
  p_designator                IN varchar2,
  p_user_id                   IN number,
  p_language_code             IN varchar2
  );


PROCEDURE delete_old_forecast(
  p_plan_id                 in number,
  p_org_id                  in number,
  p_sr_instance_id          in number,
  p_planner_code            in varchar2,
  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_planning_gp             in varchar2,
  p_project_id              in number,
  p_task_id                 in number,
  p_supplier_id      	      in number,
  p_supplier_site_id 	      in number,
  p_horizon_start	          in date,
  p_horizon_end		          in date,
  p_overwrite		            in number
);

--============CP-SPP Integration START bug#6893383================
-- Added this procedure exclusively for inserting returns forecast and Dos order types only
PROCEDURE insert_into_sup_dem_rf_dos (
  t_pub                       IN companyNameList,
  t_pub_id                    IN numberList,
  t_pub_site                  IN companySiteList,
  t_pub_site_id               IN numberList,
  t_item_id                   IN numberList,
  t_order_type	      	      IN numberList,
  t_qty                       IN numberList,
  t_planned_order_qty	        IN numberList,
  t_released_qty	            IN numberList,
  t_supp                      IN companyNameList,
  t_supp_id                   IN numberList,
  t_supp_site                 IN companySiteList,
  t_supp_site_id              IN numberList,
  t_owner_item_name           IN itemNameList,
  t_owner_item_desc           IN itemDescList,
  t_base_item_id	            IN numberList,
  t_base_item_name	          IN itemNameList,
  t_base_item_desc	          IN itemDescList,
  t_proj_number               IN numberList,
  t_task_number               IN numberList,
  t_planning_gp               IN planningGroupList,
  t_uom_code                  IN itemUomList,
  t_planner_code              IN plannerCodeList,
  t_bucket_type               IN numberList,
  t_key_date                  IN dateList,
  t_ship_date                 IN dateList,
  t_receipt_date              IN dateList,
  t_order_num                 IN orderNumList, -- bug#7310179
  t_line_num                  IN lineNumList,  -- bug#7310179
  t_master_item_name          IN itemNameList,
  t_master_item_desc          IN itemDescList,
  t_supp_item_name            IN itemNameList,
  t_supp_item_desc            IN itemDescList,
  t_tp_uom                    IN itemUomList,
  t_tp_qty                    IN numberList,
  t_tp_planned_order_qty      IN numberList,
  t_tp_released_qty	          IN numberList,
  p_version                   IN varchar2,
  p_designator                IN varchar2,
  p_user_id                   IN number,
  p_language_code             IN varchar2,
  p_publish_dos               IN number
  );

--===============CP-SPP Integration END==========================

PROCEDURE LOG_MESSAGE(
  p_string IN VARCHAR2
);

FUNCTION get_message (
  p_app  IN VARCHAR2,
  p_name IN VARCHAR2,
  p_lang IN VARCHAR2
) RETURN VARCHAR2;


END msc_sce_publish_pkg;

/
