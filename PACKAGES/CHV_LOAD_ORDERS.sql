--------------------------------------------------------
--  DDL for Package CHV_LOAD_ORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_LOAD_ORDERS" AUTHID CURRENT_USER as
/* $Header: CHVPRLOS.pls 115.0 99/07/17 01:30:13 porting ship $ */
/*===========================================================================

  PACKAGE NAME:  CHVLORDS.pls

  DESCRIPTION:   This package contains the server side of Supplier Scheduling
		 APIs to load discrete item orders.

  CLIENT/SERVER: Server

  OWNER:         Sri Rumalla

  FUNCTION/
  PROCEDURE:     load_item_orders()
		 load_planned_orders()
		 load_approved_requisitions()
		 load_approved_releases()

=============================================================================*/
/*=============================================================================
  PROCEDURE NAME:     load_item_orders

  DESCRIPTION:        Procedure when executed will evaluate the schedule_type
		      and subtype and execute the procedures load_planned_orders
		      load_approved_requisitions and load_approved_releases
		      accordingly.

  PARAMETERS:         x_organization_id              in        NUMBER,
                      x_schedule_id                  in        NUMBER,
		      x_schedule_item_id             in        NUMBER,
		      x_vendor_id	             in        NUMBER,
		      x_vendor_site_id	             in        NUMBER,
                      x_item_id		             in        NUMBER,
		      x_purchasing_unit_of_measure   in        VARCHAR2,
		      x_primary_unit_of_measure      in        VARCHAR2,
		      x_horizon_start_date	     in        DATE,
		      x_horizon_end_date	     in	       DATE,
		      x_include_future_rel_flag      in	       VARCHAR2,
                      x_schedule_type	             in        VARCHAR2,
		      x_schedule_subtype	     in        VARCHAR2,
		      x_plan_designator		     in	       VARCHAR2);

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    Created           01-NOV-1995        SRUMALLA

============================================================================*/

PROCEDURE load_item_orders(x_organization_id            in        NUMBER,
		           x_schedule_id                in        NUMBER,
		           x_schedule_item_id           in        NUMBER,
		           x_vendor_id	                in        NUMBER,
		           x_vendor_site_id	        in        NUMBER,
                      	   x_item_id		        in        NUMBER,
		           x_purchasing_unit_of_measure in        VARCHAR2,
		           x_primary_unit_of_measure    in        VARCHAR2,
			   x_conversion_rate            in        NUMBER,
		           x_horizon_start_date	        in        DATE,
		           x_horizon_end_date	        in	  DATE,
			   x_include_future_rel_flag    in	  VARCHAR2,
                           x_schedule_type	        in        VARCHAR2,
		           x_schedule_subtype	        in        VARCHAR2,
		           x_plan_designator		in 	  VARCHAR2);

/*=============================================================================
  PROCEDURE NAME:     load_planned_orders

  DESCRIPTION:        Loads unimplemented orders from mrp_recommendations based
		      on the horizon_end_date and inserts into chv_item_orders.


  PARAMETERS:         x_organization_id              in        NUMBER,
                      x_schedule_id                  in        NUMBER,
		      x_schedule_item_id             in        NUMBER,
		      x_vendor_id	             in        NUMBER,
		      x_vendor_site_id	             in        NUMBER,
                      x_item_id		             in        NUMBER,
		      x_purchasing_unit_of_measure   in        VARCHAR2,
		      x_primary_unit_of_measure      in        VARCHAR2,
		      x_horizon_start_date	     in        DATE,
		      x_horizon_end_date	     in	       DATE,
                      x_schedule_type	             in        VARCHAR2,
		      x_schedule_subtype	     in        VARCHAR2,
		      x_plan_designator		     in	       VARCHAR2);

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    Created           01-NOV-1995        SRUMALLA

============================================================================*/

PROCEDURE load_planned_orders(x_organization_id            in        NUMBER,
		              x_schedule_id                in        NUMBER,
		              x_schedule_item_id           in        NUMBER,
		              x_vendor_id	           in        NUMBER,
		              x_vendor_site_id	           in        NUMBER,
                      	      x_item_id		           in        NUMBER,
		              x_purchasing_unit_of_measure in        VARCHAR2,
		              x_primary_unit_of_measure    in        VARCHAR2,
			      x_conversion_rate            in        NUMBER,
		              x_horizon_start_date	   in        DATE,
		              x_horizon_end_date	   in	     DATE,
                              x_schedule_type	           in        VARCHAR2,
		              x_schedule_subtype	   in        VARCHAR2,
		              x_plan_designator		   in	     VARCHAR2);

/*=============================================================================
  PROCEDURE NAME:     load_approved_requisitions

  DESCRIPTION:        Loads approved requisitions from po tables based
		      on the horizon_end_date and inserts into chv_item_orders.

  PARAMETERS:         x_organization_id              in        NUMBER,
		      x_schedule_id                  in        NUMBER,
		      x_schedule_item_id             in        NUMBER,
		      x_vendor_id	             in        NUMBER,
		      x_vendor_site_id	             in        NUMBER,
                      x_item_id		             in        NUMBER,
		      x_purchasing_unit_of_measure   in        VARCHAR2,
		      x_primary_unit_of_measure      in        VARCHAR2,
		      x_horizon_start_date	     in        DATE,
		      x_horizon_end_date	     in        DATE,
                      x_schedule_type	             in        VARCHAR2,
		      x_schedule_subtype	     in        VARCHAR2);

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    Created           01-NOV-1995        SRUMALLA

============================================================================*/

PROCEDURE load_approved_requisitions(x_organization_id            in  NUMBER,
		                     x_schedule_id                in  NUMBER,
		                     x_schedule_item_id           in  NUMBER,
		                     x_vendor_id	          in  NUMBER,
		                     x_vendor_site_id	          in  NUMBER,
                      	             x_item_id		          in  NUMBER,
		                     x_purchasing_unit_of_measure in  VARCHAR2,
		                     x_primary_unit_of_measure    in  VARCHAR2,
				     x_conversion_rate            in  NUMBER,
		                     x_horizon_start_date	  in  DATE,
		                     x_horizon_end_date	          in  DATE,
                                     x_schedule_type	          in  VARCHAR2,
		                     x_schedule_subtype	          in  VARCHAR2);

/*=============================================================================
  PROCEDURE NAME:     load_approved_releases

  DESCRIPTION:        Loads approved releases from po tables based
		      on the horizon_end_date and inserts into chv_item_orders.

  PARAMETERS:         x_organization_id              in        NUMBER,
                      x_schedule_id                  in        NUMBER,
		      x_schedule_item_id             in        NUMBER,
		      x_vendor_id	             in        NUMBER,
		      x_vendor_site_id	             in        NUMBER,
                      x_item_id		             in        NUMBER,
		      x_purchasing_unit_of_measure   in        VARCHAR2,
		      x_primary_unit_of_measure      in        VARCHAR2,
		      x_horizon_start_date	     in        DATE,
		      x_horizon_end_date	     in	       DATE,

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    Created           01-NOV-1995        SRUMALLA

============================================================================*/
PROCEDURE load_approved_releases(x_organization_id            in    NUMBER,
		                 x_schedule_id                in    NUMBER,
		                 x_schedule_item_id           in    NUMBER,
		                 x_vendor_id	              in    NUMBER,
		                 x_vendor_site_id	      in    NUMBER,
                      	         x_item_id		      in    NUMBER,
		                 x_purchasing_unit_of_measure in    VARCHAR2,
		                 x_primary_unit_of_measure    in    VARCHAR2,
				 x_conversion_rate            in    NUMBER,
		                 x_horizon_start_date	      in    DATE,
		                 x_horizon_end_date	      in    DATE,
				 x_only_past_due_flag         in    VARCHAR2,
				 x_include_future_rel_flag    in    VARCHAR2
                                );


END CHV_LOAD_ORDERS;

 

/
