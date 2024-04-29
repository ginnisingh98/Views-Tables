--------------------------------------------------------
--  DDL for Package Body MTL_CUSTOMER_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CUSTOMER_ITEMS_PKG" as
/* $Header: INVICITB.pls 120.1 2005/07/01 12:23:34 appldev ship $ */

PROCEDURE CHECK_UNIQUE (X_Rowid VARCHAR2,
			X_Customer_Id NUMBER,
                        X_Customer_Category_Code VARCHAR2,
			X_Address_Id NUMBER,
			X_Customer_Item_Number VARCHAR2,
			X_Item_Definition_Level VARCHAR2) IS

Dummy NUMBER;

BEGIN

	SELECT COUNT(1)
	INTO   Dummy
	FROM   MTL_CUSTOMER_ITEMS
	WHERE  Customer_Id = X_Customer_Id
	AND    NVL(Customer_Category_Code,'JUNK') = NVL(X_Customer_Category_Code,'JUNK')
	AND    NVL(Address_Id,-1000) = NVL(X_Address_Id,-1000)
        AND    Customer_Item_Number = X_Customer_Item_Number
        AND    Item_Definition_Level = X_Item_Definition_Level
	AND    ((X_Rowid IS NULL) OR (ROWID <> X_Rowid));

	IF (Dummy >= 1) THEN

		FND_MESSAGE.SET_NAME('INV', 'INV_DUP_CUST_ITEM');
		APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;

END CHECK_UNIQUE;


END MTL_CUSTOMER_ITEMS_PKG;

/
