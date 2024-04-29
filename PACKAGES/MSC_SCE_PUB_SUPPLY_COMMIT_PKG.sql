--------------------------------------------------------
--  DDL for Package MSC_SCE_PUB_SUPPLY_COMMIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SCE_PUB_SUPPLY_COMMIT_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCXPSCS.pls 115.15 2004/08/13 18:36:28 yptang ship $ */

  /* PL/SQL table types */
TYPE companyNameList        IS TABLE OF msc_companies.company_name%TYPE;
TYPE companySiteList        IS TABLE OF msc_company_sites.company_site_name%TYPE;
TYPE itemNameList           IS TABLE OF msc_system_items.item_name%TYPE;
TYPE itemDescList           IS TABLE OF msc_system_items.description%TYPE;
TYPE itemUomList            IS TABLE OF msc_system_items.uom_code%TYPE;
TYPE fndMeaningList         IS TABLE OF fnd_lookup_values.meaning%TYPE;
TYPE plannerCodeList        IS TABLE OF msc_system_items.planner_code%TYPE;
TYPE planningGroupList      IS TABLE OF msc_demands.planning_group%TYPE;
TYPE shippingControlList    IS TABLE OF msc_trading_partner_sites.shipping_control%TYPE;
TYPE numberList             IS TABLE OF Number;
TYPE dateList               IS TABLE OF Date;

PROCEDURE publish_supply_commits (
  p_errbuf                  out nocopy varchar2,
  p_retcode                 out nocopy varchar2,
  p_plan_id                 in number,
  p_org_code                in varchar2 default null,
  p_planner_code            in varchar2 default null,
  p_abc_class               in varchar2 default null,
  p_item_id                 in number   default null,
  p_planning_gp             in varchar2 default null,
  p_project_id              in number   default null,
  p_task_id                 in number   default null,
  p_source_customer_id      in number   default null,
  p_source_customer_site_id in number   default null,
  p_horizon_start           in varchar2,
  p_horizon_end             in varchar2,
  p_auto_version            in number default 1,
  p_version                 in number   default null,
  p_include_so_flag         in number default 2,
  p_overwrite		    in number default 1
);

/*
PROCEDURE get_optional_info(
  t_item_id         	IN numberList,
  t_pub_id          	IN numberList,
  t_cust_id             IN numberList,
  t_cust_site_id        IN numberList,
  t_src_cust_id         IN numberList,
  t_src_cust_site_id    IN numberList,
  t_src_org_id          IN numberList,
  t_src_instance_id     IN numberList,
  t_item_name       	IN itemNameList,
  t_uom_code        	IN itemUomList,
  t_qty             	IN numberList,
  t_receipt_date    	IN dateList,
  t_tp_receipt_date 	IN OUT NOCOPY dateList,
  t_tp_item_name    	IN OUT NOCOPY itemNameList,
  t_tp_uom          	IN OUT NOCOPY itemUomList,
  t_tp_qty          	IN OUT NOCOPY numberList
) ;
*/

PROCEDURE get_optional_info(
  t_item_id         	IN numberList,
  t_pub_id          	IN numberList,
  t_cust_id             IN numberList,
  t_cust_site_id        IN numberList,
  t_src_cust_id         IN numberList,
  t_src_cust_site_id    IN numberList,
  t_src_org_id          IN numberList,
  t_src_instance_id     IN numberList,
  t_item_name       	IN OUT NOCOPY itemNameList,
  t_uom_code        	IN itemUomList,
  t_qty             	IN numberList,
  t_receipt_date    	IN dateList,
  t_tp_receipt_date 	IN OUT NOCOPY dateList,
  --t_tp_item_name    	IN OUT NOCOPY itemNameList,
  t_master_item_name    IN OUT NOCOPY itemNameList,
  t_master_item_desc    IN OUT NOCOPY itemDescList,
  t_cust_item_name      IN OUT NOCOPY itemNameList,
  t_cust_item_desc      IN OUT NOCOPY itemDescList,
  t_tp_uom          	IN OUT NOCOPY itemUomList,
  t_tp_qty          	IN OUT NOCOPY numberList,
  t_item_desc		IN OUT NOCOPY itemDescList
);
/*
PROCEDURE insert_into_sup_dem (
  t_pub                       IN companyNameList,
  t_pub_id                    IN numberList,
  t_pub_site                  IN companySiteList,
  t_pub_site_id               IN numberList,
  t_item_id                   IN numberList,
  t_qty                       IN numberList,
  t_pub_ot                    IN numberList,
  t_cust                      IN companyNameList,
  t_cust_id                   IN numberList,
  t_cust_site                 IN companySiteList,
  t_cust_site_id              IN numberList,
  t_ship_from                 IN companyNameList,
  t_ship_from_id              IN numberList,
  t_ship_from_site            IN companySiteList,
  t_ship_from_site_id         IN numberList,
  t_ship_to                   IN companyNameList,
  t_ship_to_id                IN numberList,
  t_ship_to_site              IN companySiteList,
  t_ship_to_site_id           IN numberList,
  t_bkt_type                  IN numberList,
  t_posting_party_id          IN numberList,
  t_item_name                 IN itemNameList,
  t_item_desc                 IN itemDescList,
  t_pub_ot_desc               IN fndMeaningList,
  t_proj_number               IN numberList,
  t_task_number               IN numberList,
  t_planning_gp               IN planningGroupList,
  t_bkt_type_desc             IN fndMeaningList,
  t_posting_party_name        IN companyNameList,
  t_uom_code                  IN itemUomList,
  t_planner_code              IN plannerCodeList,
  t_ship_date                 IN dateList,
  t_tp_receipt_date           IN dateList,
  t_tp_item_name              IN itemNameList,
  t_tp_uom                    IN itemUomList,
  t_tp_qty                    IN numberList,
  p_version                   IN varchar2,
  p_designator                IN varchar2
);
*/

PROCEDURE insert_into_sup_dem (
  t_pub                       IN companyNameList,
  t_pub_id                    IN numberList,
  t_pub_site                  IN companySiteList,
  t_pub_site_id               IN numberList,
  t_item_id                   IN numberList,
  t_qty                       IN numberList,
  t_pub_ot                    IN numberList,
  t_cust                      IN companyNameList,
  t_cust_id                   IN numberList,
  t_cust_site                 IN companySiteList,
  t_cust_site_id              IN numberList,
  t_ship_from                 IN companyNameList,
  t_ship_from_id              IN numberList,
  t_ship_from_site            IN companySiteList,
  t_ship_from_site_id         IN numberList,
  t_ship_to                   IN companyNameList,
  t_ship_to_id                IN numberList,
  t_ship_to_site              IN companySiteList,
  t_ship_to_site_id           IN numberList,
  t_bkt_type                  IN numberList,
  t_posting_party_id          IN numberList,
  t_item_name                 IN itemNameList,
  t_item_desc                 IN itemDescList,
  t_master_item_name          IN itemNameList,
  t_master_item_desc          IN itemDescList,
  t_cust_item_name            IN itemNameList,
  t_cust_item_desc            IN itemDescList,
  t_pub_ot_desc               IN fndMeaningList,
  t_proj_number               IN numberList,
  t_task_number               IN numberList,
  t_planning_gp               IN planningGroupList,
  t_bkt_type_desc             IN fndMeaningList,
  t_posting_party_name        IN companyNameList,
  t_uom_code                  IN itemUomList,
  t_planner_code              IN plannerCodeList,
  t_ship_date                 IN dateList,
  t_receipt_date           IN dateList,
  t_tp_item_name              IN itemNameList,
  t_tp_uom                    IN itemUomList,
  t_tp_qty                    IN numberList,
  p_version                   IN varchar2,
  p_designator                IN VARCHAR2,
  p_user_id                   IN number,
  t_shipping_control          IN shippingControlList,
  t_key_date                  IN dateList
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
  p_source_customer_id      in number,
  p_source_customer_site_id in number,
  p_horizon_start           in date,
  p_horizon_end             in date,
  p_overwrite		    in number
);

PROCEDURE log_message(
  p_string IN VARCHAR2
);

FUNCTION get_message (
  p_app  IN VARCHAR2,
  p_name IN VARCHAR2,
  p_lang IN VARCHAR2
) RETURN VARCHAR2;

  -- This procesure prints out debug information
  PROCEDURE print_debug_info(
    p_debug_info IN VARCHAR2
  );

  -- This procesure prints out message to user
  PROCEDURE print_user_info(
    p_user_info IN VARCHAR2
  );

END msc_sce_pub_supply_commit_pkg;

 

/
