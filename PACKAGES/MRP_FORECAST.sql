--------------------------------------------------------
--  DDL for Package MRP_FORECAST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_FORECAST" AUTHID CURRENT_USER AS
/* $Header: MRFCSTBS.pls 115.2 2003/04/07 23:33:45 skanta ship $*/
  PROCEDURE BUCKET_ENTRIES
			(arg_form_mode IN NUMBER,
			 arg_org_id IN NUMBER,
			 arg_query_id IN NUMBER,
			 arg_secondary_query_id IN NUMBER,
			 arg_bucket_type IN NUMBER,
			 arg_past_due IN NUMBER,
                         arg_forecast_designator IN VARCHAR2,
			 arg_forecast_set IN VARCHAR2,
			 arg_inventory_item_id IN NUMBER,
                         arg_start_date IN DATE,
                         arg_cutoff_date IN DATE);

END MRP_FORECAST;

 

/
