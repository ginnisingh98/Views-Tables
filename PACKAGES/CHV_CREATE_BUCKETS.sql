--------------------------------------------------------
--  DDL for Package CHV_CREATE_BUCKETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_CREATE_BUCKETS" AUTHID CURRENT_USER as
/* $Header: CHVCBKTS.pls 115.1 2002/11/26 19:51:21 sbull ship $ */

 TYPE bkttable is TABLE OF VARCHAR2(25)
      INDEX BY BINARY_INTEGER ;
 x_bucket_table   bkttable ;
 x_bucket_count   BINARY_INTEGER := 1 ;

/*===========================================================================
  PACKAGE NAME:  CHVCBKTS.pls

  DESCRIPTION:   This package contains the server side of Supplier Scheduling
		 APIs to create buckets.

  CLIENT/SERVER: Server

  OWNER:         Sri Rumalla

  FUNCTION/
  PROCEDURE:     create_bucket_template()
		 load_horizontal_schedules()
		 calculate_bucket_qty()

=============================================================================*/
/*=============================================================================
  PROCEDURE NAME:     create_bucket_template

  DESCRIPTION:   This procedure when executed will create horizontal bucketed
                 plan based on the horizon_start_date and applying the bucket
		 pattern.  It will create three records(Descriptor, Start Date
		 and End Date) and calls the insert_buckets procedure to do the
		 actual insert. Procedure will then return horizon end date
		 calculated.

  PARAMETERS:	      p_horizon_start_date           in        NUMBER,
		      p_include_future_release_flag  in        VARCHAR2,
                      p_bucket_pattern_id            in        NUMBER,
                      p_horizon_end_date            OUT        DATE,
                      p_bucket_descriptor_table     OUT        BKTTABLE,
                      p_bucket_start_date_table     OUT        BKTTABLE,
                      p_bucket_end_date_table       OUT        BKTTABLE


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    Created           01-NOV-1995        SRUMALLA
                     Modified to send  20-MAY-1996        SRUMALLA
                     past due in both
		     purchasing and
                     primary uoms.
=============================================================================*/
PROCEDURE create_bucket_template(
		         p_horizon_start_date           in        DATE,
		         p_include_future_release_flag  in        VARCHAR2,
		         p_bucket_pattern_id            in        NUMBER,
			 p_horizon_end_date	        out NOCOPY       DATE,
                         x_bucket_descriptor_table    in  out NOCOPY     BKTTABLE,
                         x_bucket_start_date_table    in  out NOCOPY     BKTTABLE,
                         x_bucket_end_date_table      in  out NOCOPY     BKTTABLE);

/*=============================================================================
  PROCEDURE NAME:     load_horizontal_schedules

  DESCRIPTION:

  PARAMETERS:         p_schedule_id                  in        NUMBER,
		      p_schedule_item_id             in        NUMBER,
                      p_row_select_order	     in        NUMBER,
		      p_row_type		     in        VARCHAR2,
		      p_bucket_table		     in        BKTTABLE) ;

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    Created           01-NOV-1995        SRUMALLA
=============================================================================*/
PROCEDURE load_horizontal_schedules(
                         p_schedule_id                  in        NUMBER,
		         p_schedule_item_id             in        NUMBER,
                         p_row_select_order	        in        NUMBER,
		         p_row_type		        in        VARCHAR2,
		         p_bucket_table		        in        BKTTABLE) ;

/*=============================================================================
  PROCEDURE NAME:     calculate_buckets

  DESCRIPTION:        This procedure when executed will calculate the buckted
		      quantities by selecting the quantities from
		      CHV_ITEM_ORDERS based on the due date.

  PARAMETERS:         p_schedule_id                  in        NUMBER,
		      p_schedule_item_id             in        NUMBER,
		      p_horizon_start_date	     in        DATE,
		      p_horizon_end_date	     in	       DATE,
		      p_cum_enable_flag              in        VARCHAR2,
		      p_cum_quantity_received        in        NUMBER,
		      p_bucket_descriptor_table      in        BKTTABLE,
                      p_bucket_start_date_table      in        BKTTABLE,
		      p_bucket_end_date_table        in        BKTTABLE,
                      p_past_due_qty                 out       NUMBER,
		      p_past_due_qty_primary         out       NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    Created           01-NOV-1995        SRUMALLA
=============================================================================*/
PROCEDURE calculate_buckets(p_schedule_id                in     NUMBER,
		            p_schedule_item_id           in     NUMBER,
		            p_horizon_start_date         in     DATE,
		            p_horizon_end_date	         in     DATE,
                            p_schedule_type              in     VARCHAR2,
			    p_cum_enable_flag            in     VARCHAR2,
			    p_cum_quantity_received      in     NUMBER,
		            p_bucket_descriptor_table    in     BKTTABLE,
                            p_bucket_start_date_table    in     BKTTABLE,
		            p_bucket_end_date_table      in     BKTTABLE,
                            p_past_due_qty              out NOCOPY     NUMBER,
		            p_past_due_qty_primary      out NOCOPY     NUMBER
                           ) ;

END CHV_CREATE_BUCKETS ;

 

/
