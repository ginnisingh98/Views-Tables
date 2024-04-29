--------------------------------------------------------
--  DDL for Package MSC_X_CVMI_PLANNING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_CVMI_PLANNING" AUTHID CURRENT_USER AS
/* $Header: MSCXCVPS.pls 115.5 2004/02/11 00:13:14 jguo noship $ */


  PROCEDURE calculate_average_demand;

  PROCEDURE calculate_average_demand
  ( p_plan_id IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_organization_id IN NUMBER
  , p_sr_instance_id IN NUMBER
  , p_customer_id IN NUMBER
  , p_customer_site_id IN NUMBER
  , p_forecast_horizon IN NUMBER
  , p_vmi_forecast_type IN NUMBER
  , p_item_uom_code     IN varchar2
  , p_old_average_daily_demand IN NUMBER
  );

  FUNCTION aps_to_sce(
      p_tp_key IN NUMBER
    , p_map_type IN NUMBER
    , p_sr_instance_id IN NUMBER DEFAULT NULL
    ) RETURN NUMBER;

  -- This function is used to convert APS tp key to SCE company key
  FUNCTION sce_to_aps(
      p_company_key IN NUMBER
    , p_map_type IN NUMBER
    ) RETURN NUMBER;

  PROCEDURE print_debug_info(
    p_debug_info IN VARCHAR2
  );

  PROCEDURE print_user_info(
    p_user_info IN VARCHAR2
  );

END MSC_X_CVMI_PLANNING;


 

/
