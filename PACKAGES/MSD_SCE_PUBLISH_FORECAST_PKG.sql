--------------------------------------------------------
--  DDL for Package MSD_SCE_PUBLISH_FORECAST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_SCE_PUBLISH_FORECAST_PKG" AUTHID CURRENT_USER AS
/* $Header: msdxpcfs.pls 115.6 2004/07/15 19:40:12 esubrama ship $ */

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

PROCEDURE publish_customer_forecast (
  p_errbuf                  out NOCOPY varchar2,
  p_retcode                 out NOCOPY varchar2,
  p_designator              in varchar2,
  p_order_type              in number,
  p_demand_plan_id          in number,
  p_scenario_id             in number,
  p_forecast_date           in varchar2,
  p_org_code                in varchar2,
  p_planner_code            in varchar2,
--  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_customer_id             in number,
  p_customer_site_id        in number,
  p_horizon_start           in varchar2,
  p_horizon_days            in number,
  p_auto_version            in number,
  p_version                 in number
);


PROCEDURE explode_dates (
  t_pub                       IN OUT NOCOPY companyNameList,
  t_pub_id                    IN OUT NOCOPY numberList,
  t_pub_site                  IN OUT NOCOPY companySiteList,
  t_pub_site_id               IN OUT NOCOPY numberList,
  t_item_id                   IN OUT NOCOPY numberList,
  t_qty                       IN OUT NOCOPY numberList,
  t_pub_ot                    IN OUT NOCOPY numberList,
  t_cust                      IN OUT NOCOPY companyNameList,
  t_cust_id                   IN OUT NOCOPY numberList,
  t_cust_site                 IN OUT NOCOPY companySiteList,
  t_cust_site_id              IN OUT NOCOPY numberList,
  t_ship_from                 IN OUT NOCOPY companyNameList,
  t_ship_from_id              IN OUT NOCOPY numberList,
  t_ship_from_site            IN OUT NOCOPY companySiteList,
  t_ship_from_site_id         IN OUT NOCOPY numberList,
  t_ship_to                   IN OUT NOCOPY companyNameList,
  t_ship_to_id                IN OUT NOCOPY numberList,
  t_ship_to_site              IN OUT NOCOPY companySiteList,
  t_ship_to_site_id           IN OUT NOCOPY numberList,
  t_bkt_type                  IN OUT NOCOPY numberList,
  t_posting_party_id          IN OUT NOCOPY numberList,
  t_item_name                 IN OUT NOCOPY itemNameList,
  t_item_desc                 IN OUT NOCOPY itemDescList,
  t_pub_ot_desc               IN OUT NOCOPY fndMeaningList,
  t_bkt_type_desc             IN OUT NOCOPY fndMeaningList,
  t_posting_party_name        IN OUT NOCOPY companyNameList,
  t_uom_code                  IN OUT NOCOPY itemUomList,
  t_planner_code              IN OUT NOCOPY plannerCodeList,
  t_end_date                  IN OUT NOCOPY dateList,
  t_ship_date                 IN OUT NOCOPY dateList,
  t_tp_ship_date              IN OUT NOCOPY dateList,
  t_receipt_date              IN OUT NOCOPY dateList,
  t_tp_receipt_date           IN OUT NOCOPY dateList,
  t_master_item_name          IN OUT NOCOPY itemNameList,
  t_master_item_desc          IN OUT NOCOPY itemDescList,
  t_cust_item_name            IN OUT NOCOPY itemNameList,
  t_cust_item_desc            IN OUT NOCOPY itemDescList,
  t_tp_uom                    IN OUT NOCOPY itemUomList,
  t_tp_qty                    IN OUT NOCOPY numberList
);

PROCEDURE get_optional_info(
  t_item_id             IN numberList,
  t_pub_id              IN numberList,
  t_cust_id             IN numberList,
  t_cust_site_id        IN numberList,
  t_tp_cust_id          IN numberList,
  t_src_cust_site_id    IN numberList,
  t_src_org_id          IN numberList,
  t_src_instance_id     IN numberList,
  t_item_name           IN itemNameList,
  t_uom_code            IN itemUomList,
  t_qty                 IN numberList,
  t_ship_date           IN dateList,
  t_receipt_date        IN dateList,
  t_tp_ship_date        IN OUT NOCOPY dateList,
  t_tp_receipt_date     IN OUT NOCOPY dateList,
  t_master_item_name    IN OUT NOCOPY itemNameList,
  t_master_item_desc    IN OUT NOCOPY itemDescList,
  t_cust_item_name      IN OUT NOCOPY itemNameList,
  t_cust_item_desc      IN OUT NOCOPY itemDescList,
  t_tp_uom              IN OUT NOCOPY itemUomList,
  t_tp_qty              IN OUT NOCOPY numberList,
  t_lead_time           IN numberList,
  p_forecast_date       IN varchar2
);

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
  t_bkt_type_desc             IN fndMeaningList,
  t_posting_party_name        IN companyNameList,
  t_uom_code                  IN itemUomList,
  t_planner_code              IN plannerCodeList,
  t_tp_ship_date              IN dateList,
  t_tp_receipt_date           IN dateList,
  t_tp_uom                    IN itemUomList,
  t_tp_qty                    IN numberList,
  p_version                   IN varchar2,
  p_designator                IN varchar2,
  t_shipping_control          IN shippingControlList
);

PROCEDURE delete_old_forecast(
  p_org_id                  in number,
  p_sr_instance_id          in number,
  p_planner_code            in varchar2,
--  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_customer_id             in number,
  p_customer_site_id        in number,
  l_horizon_start           in date,
  p_horizon_end             in date
);

END MSD_SCE_PUBLISH_FORECAST_PKG;

 

/
