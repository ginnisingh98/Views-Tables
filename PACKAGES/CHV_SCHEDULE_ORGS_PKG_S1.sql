--------------------------------------------------------
--  DDL for Package CHV_SCHEDULE_ORGS_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_SCHEDULE_ORGS_PKG_S1" AUTHID CURRENT_USER as
/* $Header: CHVSORGS.pls 115.0 99/07/17 01:31:58 porting ship $ */
/*===========================================================================
  PACKAGE NAME:		CHV_SCHEDULE_ORGS_PKG_S1

  DESCRIPTION:		Contains the Table handler for Supplier Scheduling
                        chv schedule organizations table.

  CLIENT/SERVER:	Server

  LIBRARY NAME:		NONE

  OWNER:		SRUMALLA

  PROCEDURES/FUNCTIONS:	insert_row()

===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	insert_row()

  DESCRIPTION:		Table Handler to delete rows for schedule organizations
			table.

  PARAMETERS:	        See Below

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SRUMALLA	01/29/96     Created

===========================================================================*/
  PROCEDURE Insert_row(
		       X_Batch_Id  IN   NUMBER,
		       X_Organization_Id    IN   NUMBER
                      );

END CHV_SCHEDULE_ORGS_PKG_S1;

 

/
