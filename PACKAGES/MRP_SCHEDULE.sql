--------------------------------------------------------
--  DDL for Package MRP_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SCHEDULE" AUTHID CURRENT_USER AS
/* $Header: MRSCHDBS.pls 120.1 2005/06/16 14:01:53 ichoudhu noship $*/

PROCEDURE BUCKET_ENTRIES
		       ( arg_query_id1 			IN NUMBER,
			 arg_query_id2 			IN NUMBER,
	 	         arg_org_id 			IN NUMBER,
                         arg_schedule_designator 	IN VARCHAR2,
		         arg_inventory_item_id 		IN NUMBER,
		         arg_bucket_type 		IN NUMBER,
		         arg_quantity_type 		IN NUMBER,
		         arg_version_type 		IN NUMBER,
		         arg_past_due 			IN NUMBER,
                         arg_start_date 		IN DATE,
                         arg_cutoff_date 		IN DATE );


PROCEDURE Get_Nextval( X_query_id1      IN OUT  NOCOPY NUMBER,
		       X_query_id2      IN OUT  NOCOPY NUMBER );


PROCEDURE Get_Cost( X_org_id     	IN      NUMBER,
		    X_inventory_item_id IN      NUMBER,
		    X_cost		IN OUT  NOCOPY NUMBER );

PROCEDURE Get_Max_BOM_Level( X_organization_id  		NUMBER,
                  	     X_mps_explosion_level      IN OUT  NOCOPY NUMBER);


END MRP_SCHEDULE;

 

/
