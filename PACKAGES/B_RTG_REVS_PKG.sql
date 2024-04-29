--------------------------------------------------------
--  DDL for Package B_RTG_REVS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."B_RTG_REVS_PKG" AUTHID CURRENT_USER AS
/* $Header: bompirrs.pls 115.1 99/07/16 05:48:40 porting ship $ */

  PROCEDURE Check_Order (X_Effectivity_Date		DATE,
			 X_Inventory_Item_Id		NUMBER,
			 X_Organization_Id		NUMBER,
			 X_Process_Revision		VARCHAR2);

  PROCEDURE Check_Unique(X_Organization_Id              NUMBER,
			 X_Inventory_Item_Id		NUMBER,
			 X_Process_Revision		VARCHAR2);

END B_RTG_REVS_PKG;

 

/
