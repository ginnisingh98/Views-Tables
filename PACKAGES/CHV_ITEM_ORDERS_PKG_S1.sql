--------------------------------------------------------
--  DDL for Package CHV_ITEM_ORDERS_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_ITEM_ORDERS_PKG_S1" AUTHID CURRENT_USER as
/* $Header: CHVSORDS.pls 115.0 99/07/17 01:31:49 porting ship $ */
/*===========================================================================
  PACKAGE NAME:		CHV_ITEM_ORDERS_PKG_S1

  DESCRIPTION:		Contains the Table handler for Supplier Scheduling
                        Horizontal schedules table.

  CLIENT/SERVER:	Server

  LIBRARY NAME:		NONE

  OWNER:		SRUMALLA

  PROCEDURES/FUNCTIONS:	delete_row()

===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	delete_row()

  DESCRIPTION:		Table Handler to delete rows for chv item orders table.

  PARAMETERS:	        See Below

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SRUMALLA	01/29/96     Created

===========================================================================*/
  PROCEDURE delete_row(
                       X_Schedule_Id       IN   NUMBER,
		       X_Schedule_Item_Id  IN   NUMBER
                      );

END CHV_ITEM_ORDERS_PKG_S1;

 

/
