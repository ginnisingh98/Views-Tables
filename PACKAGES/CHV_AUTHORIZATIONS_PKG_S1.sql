--------------------------------------------------------
--  DDL for Package CHV_AUTHORIZATIONS_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_AUTHORIZATIONS_PKG_S1" AUTHID CURRENT_USER as
/* $Header: CHVSAUTS.pls 115.0 99/07/17 01:30:36 porting ship $ */
/*===========================================================================
  PACKAGE NAME:		CHV_AUTHORIZATIONS_PKG_S1

  DESCRIPTION:		Contains the Table handler for Supplier Scheduling
                        chv authorizations table.

  CLIENT/SERVER:	Server

  LIBRARY NAME:		NONE

  OWNER:		SRUMALLA

  PROCEDURES/FUNCTIONS:	delete_row()

===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	delete_row()

  DESCRIPTION:		Table Handler to delete rows from horizontal schedules

  PARAMETERS:	        See Below

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SRUMALLA	01/29/96     Created

===========================================================================*/
  PROCEDURE delete_row(
		       X_Schedule_Item_Id  IN   NUMBER
                      );

END CHV_AUTHORIZATIONS_PKG_S1;

 

/
