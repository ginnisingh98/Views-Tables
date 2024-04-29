--------------------------------------------------------
--  DDL for Package WIP_LOT_NUMBER_DEFAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_LOT_NUMBER_DEFAULT" AUTHID CURRENT_USER AS
/* $Header: wiplndfs.pls 115.6 2002/12/12 15:01:41 rmahidha ship $ */

/* LOT_NUMBER

   This function returns the correct lot number for the given item and
   organization.

   If a potential lot number is already inputed, this can be passed as a
   parameter.  The function will return this value unless the item is not
   under lot control, in which case it returns NULL

   The Job Name is also entered as a parameter.  This value will be returned
   if the item is under lot control and WIP Parameters are set to Based on
   Job Name.

   If P_Default_Flag is 1, the routine will default a lot number if necessary.
   If P_Default_Flag is anything else, the routine will return NULL if
   the item is not under lot control, P_Lot_Number otherwise.
 */

   FUNCTION LOT_NUMBER(	P_Item_Id IN NUMBER,
			P_Organization_Id IN NUMBER,
			P_Lot_Number IN VARCHAR2,
			P_Job_Name IN VARCHAR2,
			P_Default_Flag IN NUMBER) return VARCHAR2;

END WIP_LOT_NUMBER_DEFAULT;

 

/
