--------------------------------------------------------
--  DDL for Package MSD_SCE_RECEIVE_FORECAST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_SCE_RECEIVE_FORECAST_PKG" AUTHID CURRENT_USER AS
/* $Header: msdxrcfs.pls 120.1.12000000.1 2007/01/16 18:32:54 appldev ship $ */

  /* PL/SQL table types */
TYPE srInstIdList           IS TABLE OF msc_trading_partners.sr_instance_id%TYPE;
TYPE srLevelPkList          IS TABLE OF msd_level_values.sr_level_pk%TYPE;
TYPE levelPkList            IS TABLE OF msd_level_values.level_pk%TYPE;
TYPE levelIdList            IS TABLE OF msd_level_values.level_id%TYPE;
TYPE levelValList           IS TABLE OF msd_level_values.level_value%TYPE;
TYPE itemUomList            IS TABLE OF msc_system_items.uom_code%TYPE;
TYPE fndMeaningList         IS TABLE OF fnd_lookup_values.meaning%TYPE;
TYPE plannerCodeList        IS TABLE OF msc_system_items.planner_code%TYPE;
TYPE numberList             IS TABLE OF Number;
TYPE dateList               IS TABLE OF Date;

PROCEDURE receive_customer_forecast (
  p_errbuf                  out NOCOPY varchar2,
  p_retcode                 out NOCOPY varchar2,
  p_designator              in varchar2,
  p_order_type              in number,
  p_org_code                in varchar2,
  p_planner_code            in varchar2,
--  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_customer_id             in number,
  p_customer_site_id        in number default null,
  p_horizon_start           in varchar2,
  p_horizon_days            in number
);

PROCEDURE delete_old_forecast (
  p_sr_instance_id          in number,
  p_cs_definition_id        in number,
  p_designator              in varchar2,
  p_org_id                  in number,
  p_item_id                 in number, --Bug 4710643
  p_customer_id             in number, --Bug 4710643
  p_customer_site_id        in number, --Bug 4710643
  l_horizon_start           in date,
  l_horizon_end             in date,
  p_new_fresh_num           in number
);

FUNCTION get_sr_tp_site_id(
                             p_customer_site_id in number,
                             p_sr_instance_id in number
                           ) return number;

FUNCTION get_intrasit_lead_time(
                             p_from_instance_id in number,
                             p_from_organization_id in number,
                             p_to_location_id in number
                           ) return number;


END MSD_SCE_RECEIVE_FORECAST_PKG;

 

/
