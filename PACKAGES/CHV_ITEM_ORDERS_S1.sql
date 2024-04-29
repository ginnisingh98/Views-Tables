--------------------------------------------------------
--  DDL for Package CHV_ITEM_ORDERS_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_ITEM_ORDERS_S1" AUTHID CURRENT_USER as
/* $Header: CHVPRIOS.pls 115.1 2002/11/26 23:55:49 sbull ship $ */

/*===========================================================================
  PACKAGE NAME:  CHV_ITEM_ORDERS_S1
  DESCRIPTION:   This package contains the server side of Supplier Scheduling
		 APIs to select past due quantities and get authorization
                 quantity.

  CLIENT/SERVER: Server

  OWNER:         Shawna Liu

  FUNCTION/
		 get_past_due_qty()
                 get_auth_qty()

============================================================================*/

/*===========================================================================
  PROCEDURE NAME      :  get_past_due_qty

  DESCRIPTION         :  GET_PAST_DUE_QTY is a procedure to select all the past
                         due quantities from CHV_ITEM_ORDERS table based on the
                         start date.

  PARAMETERS          :  x_schedule_id                 in      NUMBER,
			 x_schedule_item_id            in      NUMBER,
			 x_horizon_start_date          in      DATE,
                         x_past_due_qty_primary        in out  NUMBER,
                         x_past_due_qty_purch          in out  NUMBER

  DESIGN REFERENCES   :

  ALGORITHM           :  Select sum(order_quantity), sum(order_quantity_primary)
                         based on the schedule_id, schedule_item_id from
                         CHV_ITEM_ORDERS where supply_document_type is 'RELEASE'
                         and the due_date is less than x_horizon_start_date
                         and return both the quantities to the calling procedure.

  NOTES               :  1. The reason that x_past_due_qty_primary and
                            x_past_due_qty_purch are in out rather than out
                            parameters is that the select into statement
                            requires this setup based on PO coding standards.

  OPEN ISSUES         :  1. The exception handler seems to be redundant, since
                            it is a select sum statement. Should it be kept?
                         2. Order_quantity column of chv_item_orders table
                            seems to be in purchasing UOM. Need to change the
                            lable to order_quantity_purch if it is true.
                            Ask Sri.
                         3. Is column document_approval_status needed here?
                            Ask Sri.

  CLOSED ISSUES       :

  CHANGE HISTORY      :  Created            26-MAR-1995     SXLIU
==========================================================================*/
PROCEDURE get_past_due_qty(x_schedule_id                 IN      NUMBER,
                           x_schedule_item_id            IN      NUMBER,
                           x_horizon_start_date          IN      DATE,
                           x_past_due_qty_primary        IN OUT NOCOPY  NUMBER,
                           x_past_due_qty_purch          IN OUT NOCOPY  NUMBER);

/*===========================================================================
  PROCEDURE NAME      :  get_auth_qty

  DESCRIPTION         :  GET_AUTH_QTY is a procedure to retrieve authorization
                         quantities from CHV_ITEM_ORDERS table based on both
                         purchasing and primary UOM's.

  PARAMETERS          : x_schedule_id                 IN      NUMBER,
                        x_schedule_item_id            IN      NUMBER,
                        x_authorization_end_date      IN      DATE,
                        x_authorization_qty           IN OUT  NUMBER,
                        x_authorization_qty_primary   IN OUT  NUMBER

  DESIGN REFERENCES   :

  ALGORITHM           :   Select sum(order_quantity), sum(order_quantity_primary)
                          from CHV_ITEM_ORDERS based on the x_schedule_id and
                          x_schedule_item_id and document due_date must be less
                          than the authorization end date.

  NOTES               :  1. The reason that x_authorization_qty_primary and
                            x_authorization_qty are in out rather than out
                            parameters is that the select into statement
                            requires this setup based on PO coding standards.

  OPEN ISSUES         :  1. (Refer to OPEN ISSUES 1 and 2 for procedure
                            get_past_due_qty above).
                         2. Ask Sri about the second business rule in the
                            scheduling processing design doc - "Return 0 if
                            no records are found'.

  CLOSED ISSUES       :

  CHANGE HISTORY      :  Created            1-APR-1995     SXLIU
==========================================================================*/
PROCEDURE get_auth_qty (x_schedule_id                 IN      NUMBER,
                        x_schedule_item_id            IN      NUMBER,
                        x_authorization_end_date      IN      DATE,
                        x_authorization_qty           IN OUT NOCOPY  NUMBER,
                        x_authorization_qty_primary   IN OUT NOCOPY  NUMBER);

END CHV_ITEM_ORDERS_S1;

 

/
