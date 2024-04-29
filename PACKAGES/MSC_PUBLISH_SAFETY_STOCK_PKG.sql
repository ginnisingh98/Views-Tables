--------------------------------------------------------
--  DDL for Package MSC_PUBLISH_SAFETY_STOCK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_PUBLISH_SAFETY_STOCK_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCXPSSS.pls 120.1 2005/09/09 00:21:31 shwmathu noship $ */

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


PURCHASE_ORDER      CONSTANT INTEGER := 1;   /* order type lookup - lookup_type = MRP_ORDER_TYPE  */
PURCH_REQ           CONSTANT INTEGER := 2;
WORK_ORDER          CONSTANT INTEGER := 3;
REPETITIVE_SCHEDULE CONSTANT INTEGER := 4;
PLANNED_ORDER       CONSTANT INTEGER := 5;
MATERIAL_TRANSFER   CONSTANT INTEGER := 6;
NONSTD_JOB          CONSTANT INTEGER := 7;
RECEIPT_PURCH_ORDER CONSTANT INTEGER := 8;
REQUIREMENT         CONSTANT INTEGER := 9;
FPO_SUPPLY          CONSTANT INTEGER := 10;
SHIPMENT            CONSTANT INTEGER := 11;
RECEIPT_SHIPMENT    CONSTANT INTEGER := 12;
AGG_REP_SCHEDULE    CONSTANT INTEGER := 13;
DIS_JOB_BY          CONSTANT INTEGER := 14;
NON_ST_JOB_BY       CONSTANT INTEGER := 15;
REP_SCHED_BY        CONSTANT INTEGER := 16;
PLANNED_BY          CONSTANT INTEGER := 17;
ON_HAND_QTY         CONSTANT INTEGER := 18;
FLOW_SCHED          CONSTANT INTEGER := 27;
FLOW_SCHED_BY	    CONSTANT INTEGER := 28;
PAYBACK_SUPPLY      CONSTANT INTEGER :=29;


DEMAND_PAYBACK	    	CONSTANT INTEGER := 27;	/* lookup_type = 'MSC_DEMAND_ORIGINATION' */
/*in the package body, the query to the msc_demands will be
using the lookup_type = 'MSC_DEMAND_ORIGINATION' for the origination_type*/


PAB_SUPPLY 		CONSTANT INTEGER := 1;
PAB_DEMAND		CONSTANT INTEGER := 2;
PAB_SCRAP_DEMAND	CONSTANT INTEGER := 3;
PAB_EXP_LOT		CONSTANT INTEGER := 4;
PAB_ONHAND		CONSTANT INTEGER := 5;

SAFETY_STOCK		CONSTANT INTEGER := 7;
PROJECTED_AVAILABLE_BALANCE CONSTANT INTEGER := 27;

PROCEDURE publish_safety_stocks (
  p_errbuf                  out nocopy varchar2,
  p_retcode                 out nocopy number,
  p_plan_id                 in number,
  p_org_code                in varchar2,
  p_planner_code            in varchar2,
  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_planning_gp             in varchar2,
  p_project_id              in number,
  p_task_id                 in number,
  p_supplier_id             in number,
  p_supplier_site_id        in number,
  p_horizon_start           in varchar2,
  p_horizon_end             in varchar2,
  p_overwrite		    in number
);


PROCEDURE get_optional_info(
  p_err               OUT nocopy varchar2,
  p_ret               OUT nocopy number,
  p_plan_id		IN number,
  p_supp_id		IN number,
  p_supp_site_id	IN number,
  t_base_item_id	IN NumberList,
  t_item_id             IN numberList,
  t_org_id              IN numberList,
  t_sr_instance_id      IN numberList,
  t_uom_code            IN itemUomList,
  t_qty                 IN numberList,
  t_master_item_name 	IN OUT NOCOPY itemNameList,
  t_master_item_desc 	IN OUT NOCOPY itemDescList,
  t_pub_id           	IN OUT NOCOPY numberList,
  t_pub              	IN OUT NOCOPY companyNameList,
  t_pub_site_id      	IN OUT NOCOPY numberList,
  t_pub_site         	IN OUT NOCOPY companySiteList,
  t_supp_id          	IN OUT NOCOPY numberList,
  t_supp             	IN OUT NOCOPY companyNameList,
  t_supp_site_id     	IN OUT NOCOPY numberList,
  t_supp_site        	IN OUT NOCOPY companySiteList,
  t_item_name		IN OUT NOCOPY itemNameList,
  t_item_desc		IN OUT NOCOPY itemDescList,
  t_base_item_name	IN OUT NOCOPY itemNameList,
  t_bucket_index	IN OUT NOCOPY numberList
);

PROCEDURE get_total_qty (
  p_err               OUT nocopy varchar2,
  p_ret               OUT nocopy number,
  t_item_id             IN numberList,
  t_org_id              IN numberList,
  t_sr_instance_id      IN numberList,
  t_pab_type		IN numberList,
  t_key_date		IN dateList,
  t_qty			IN numberList,
  t_total_qty           IN OUT NOCOPY numberList,
  t_temp_qty		IN OUT NOCOPY numberList
  );


PROCEDURE insert_into_sup_dem (
  p_err               OUT nocopy varchar2,
  p_ret               OUT nocopy number,
  p_plan_id		      IN number,
  p_horizon_start	      IN date,
  p_horizon_end		      IN date,
  p_type		      IN number,
  t_sr_instance_id	      IN numberList,
  t_org_id		      IN numberList,
  t_pub                       IN companyNameList,
  t_pub_id                    IN numberList,
  t_pub_site                  IN companySiteList,
  t_pub_site_id               IN numberList,
  t_base_item_id	      IN numberList,
  t_item_id                   IN numberList,
  t_bucket_type		      IN numberList,
  t_bucket_start	      IN dateList,
  t_bucket_end 		      IN dateList,
  t_bucket_index	      IN numberList,
  t_qty                       IN numberList,
  t_total_qty		      IN numberList,
  t_temp_qty		      IN numberList,
  t_item_name                 IN itemNameList,
  t_item_desc                 IN itemDescList,
  t_base_item_name	      IN itemNameList,
  t_proj_number               IN numberList,
  t_task_number               IN numberList,
  t_planning_gp               IN planningGroupList,
  t_uom_code                  IN itemUomList,
  t_planner_code              IN plannerCodeList,
  t_key_date                  IN dateList,
  t_master_item_name          IN itemNameList,
  t_master_item_desc          IN itemDescList,
  p_version                   IN varchar2,
  p_designator                IN varchar2,
  p_user_id                   IN number,
  p_language_code             IN varchar2
  );


PROCEDURE delete_old_safety_stock(
  p_plan_id                 in number,
  p_org_id                  in number,
  p_sr_instance_id          in number,
  p_planner_code            in varchar2,
  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_planning_gp             in varchar2,
  p_project_id              in number,
  p_task_id                 in number,
    p_horizon_start	    in date,
  p_horizon_end		    in date,
  p_overwrite		    in number
);

PROCEDURE LOG_MESSAGE(
  p_string IN VARCHAR2
);

FUNCTION get_message (
  p_app  IN VARCHAR2,
  p_name IN VARCHAR2,
  p_lang IN VARCHAR2
) RETURN VARCHAR2;


FUNCTION GET_ORDER_TYPE(p_order_type_code in Number) RETURN Varchar2;

END msc_publish_safety_stock_pkg;

 

/
