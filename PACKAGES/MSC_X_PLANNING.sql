--------------------------------------------------------
--  DDL for Package MSC_X_PLANNING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_PLANNING" AUTHID CURRENT_USER AS
/* $Header: MSCXSVPS.pls 115.5 2003/10/30 20:56:37 jguo noship $ */


  PROCEDURE calculate_average_demand;

  PROCEDURE calculate_average_demand_api
  ( p_plan_id IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_organization_id IN NUMBER
  , p_sr_instance_id IN NUMBER
  , p_supplier_id IN NUMBER
  , p_supplier_site_id IN NUMBER
  , p_using_organization_id IN NUMBER
  , p_update_flag IN NUMBER DEFAULT 1
  , p_horizon_start_date IN DATE DEFAULT SYSDATE
  , p_average_daily_demand OUT NOCOPY NUMBER
  );


  PROCEDURE print_debug_info(
    p_debug_info IN VARCHAR2
  );

  PROCEDURE print_user_info(
    p_user_info IN VARCHAR2
  );

END MSC_X_PLANNING;


 

/
