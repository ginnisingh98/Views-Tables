--------------------------------------------------------
--  DDL for Package MTL_CUSTOMER_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CUSTOMER_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: INVICITS.pls 120.0 2005/05/27 09:56:27 appldev noship $ */

PROCEDURE CHECK_UNIQUE (X_Rowid VARCHAR2,
			X_Customer_Id NUMBER,
			X_Customer_Category_Code VARCHAR2,
			X_Address_Id NUMBER,
                        X_Customer_Item_Number VARCHAR2,
			X_Item_Definition_Level VARCHAR2);


END MTL_CUSTOMER_ITEMS_PKG;

 

/
