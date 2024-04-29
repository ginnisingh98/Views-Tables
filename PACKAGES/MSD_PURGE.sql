--------------------------------------------------------
--  DDL for Package MSD_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_PURGE" AUTHID CURRENT_USER AS
/* $Header: msdpurgs.pls 115.8 2003/10/23 02:06:02 dkang ship $ */


procedure purge_facts(
                      errbuf                OUT NOCOPY VARCHAR2,
                      retcode               OUT NOCOPY VARCHAR2,
                      p_instance_id         IN  NUMBER,
                      p_from_date           IN  VARCHAR2,
                      p_to_date             IN  VARCHAR2,
                      p_shipment_yes_no     IN  NUMBER,
                      p_booking_yes_no      IN  NUMBER,
                      p_mfg_fcst_yes_no     IN  NUMBER,
                      p_mfg_fcst_desg       IN  VARCHAR2,
                      p_sales_opp_yes_no    IN  NUMBER,
                      p_cust_order_yes_no   IN  NUMBER,
                      p_cust_sales_yes_no   IN  NUMBER,
                      p_cs_data_yes_no      IN  NUMBER,
                      p_cs_definition_id    IN  NUMBER,
                      p_cs_designator       IN  VARCHAR2,
                      p_curr_yes_no         IN  NUMBER,
                      p_uom_yes_no          IN  NUMBER,
                      p_time_yes_no         IN  NUMBER,
                      p_calendar_code       IN  VARCHAR2,
                      p_pricing_yes_no      IN  NUMBER,
                      p_price_list          IN  VARCHAR2,
                      p_scn_ent_yes_no      IN  NUMBER,
                      p_demand_plan_id      IN  NUMBER,
                      p_scenario_id         IN  NUMBER,
                      p_revision            IN  VARCHAR2,
                      p_level_values_yes_no IN  NUMBER
                      );

END MSD_PURGE ;

 

/
