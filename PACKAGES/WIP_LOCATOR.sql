--------------------------------------------------------
--  DDL for Package WIP_LOCATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_LOCATOR" AUTHID CURRENT_USER AS
/* $Header: wiplocvs.pls 120.0 2005/05/25 08:08:54 appldev noship $ */

/*
   VALIDATE

   This procedure does validation on a given locator based on an assortment
   of input parameters.  It can validate eiter a locator_id or
   concatenated segments (P_Locator_Segments).  If both an id and segments
   are passed, the routine ignores the Segments and uses the Id for
   validation.

   First it uses the input parameters for Org, Sub, and Item level
   locator control to determine the correct locator control settings.

   If we have No Locator Control, the routine will null out nocopy P_Locator_Id
   and P_Locator_Segments and return P_Success_Flag = TRUE.

   If we have Prespecified Locator Control, the routine will check if
   the Locator is valid based on the P_Item_Id, the P_Subinventory_Code
   and P_Restrict_Flag (MTL_SYSTEM_ITEMS.RESTRICT_LOCATORS_CODE).
   P_Success_Flag will be set to TRUE or FALSE depending on whether
   the Locator is valid.

   If we have Dynamic Locator control, the routine will check if the
   Locator is valid if that locator already exists.  If the locator does
   not exist, it will create a new one, and assign it to the proper
   subinventory.
   P_Success_Flag will be set to TRUE or FALSE depending on whether
   the Locator is valid.

   P_Success_Flag will be set to FALSE if you are under locator control
   and both the Locator_Id and Locator_Segments are NULL
*/

PROCEDURE Validate(P_Organization_Id IN NUMBER DEFAULT NULL,
		   P_Item_Id IN NUMBER DEFAULT NULL,
		   P_Subinventory_Code IN VARCHAR2 DEFAULT NULL,
		   P_Org_Loc_Control IN NUMBER DEFAULT NULL,
		   P_Sub_Loc_Control IN NUMBER DEFAULT NULL,
		   P_Item_Loc_Control IN NUMBER DEFAULT NULL,
		   P_Restrict_Flag IN NUMBER DEFAULT NULL,
		   P_Neg_Flag IN NUMBER DEFAULT NULL,
		   P_Action IN NUMBER DEFAULT NULL,
		   P_Project_Id IN NUMBER DEFAULT NULL,
           P_Task_Id IN NUMBER DEFAULT NULL,
		   P_Locator_Id IN OUT NOCOPY NUMBER,
		   P_Locator_Segments IN OUT NOCOPY VARCHAR2,
		   P_Success_Flag OUT NOCOPY BOOLEAN);

END WIP_LOCATOR;

 

/
