--------------------------------------------------------
--  DDL for Package Body INVICXRF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVICXRF" as
/* $Header: INVICXRB.pls 120.1 2005/06/30 06:43:51 appldev ship $ */

PROCEDURE Insert_Row   (X_Rowid 		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			X_Customer_Item_Id		NUMBER,
			X_Inventory_Item_Id		NUMBER,
			X_Master_Organization_Id	NUMBER,
			X_Rank 				NUMBER,
			X_Inactive_Flag			VARCHAR2,
			X_Last_Update_Date		DATE,
			X_Last_Updated_By		NUMBER,
			X_Creation_Date			DATE,
			X_Created_By			NUMBER,
			X_Last_Update_Login		NUMBER,
			X_Attribute_Category		VARCHAR2,
			X_Attribute1			VARCHAR2,
			X_Attribute2			VARCHAR2,
			X_Attribute3			VARCHAR2,
			X_Attribute4			VARCHAR2,
			X_Attribute5			VARCHAR2,
			X_Attribute6			VARCHAR2,
			X_Attribute7			VARCHAR2,
			X_Attribute8			VARCHAR2,
			X_Attribute9			VARCHAR2,
			X_Attribute10			VARCHAR2,
			X_Attribute11			VARCHAR2,
			X_Attribute12			VARCHAR2,
			X_Attribute13			VARCHAR2,
			X_Attribute14			VARCHAR2,
			X_Attribute15			VARCHAR2
			) IS

CURSOR C IS SELECT rowid FROM mtl_customer_item_xrefs
	    WHERE  customer_item_id	  = X_Customer_Item_Id
	    AND    inventory_item_id	  = X_Inventory_Item_Id
	    AND    master_organization_id = X_Master_Organization_Id;

BEGIN

	INSERT INTO mtl_customer_item_xrefs(
			Customer_Item_Id,
			Inventory_Item_Id,
			Master_Organization_Id,
			Preference_Number,
			Inactive_Flag,
			Last_Update_Date,
			Last_Updated_By,
			Creation_Date,
			Created_By,
			Last_Update_Login,
			Attribute_Category,
			Attribute1,
			Attribute2,
			Attribute3,
			Attribute4,
			Attribute5,
			Attribute6,
			Attribute7,
			Attribute8,
			Attribute9,
			Attribute10,
			Attribute11,
			Attribute12,
			Attribute13,
			Attribute14,
			Attribute15
			) VALUES (
			X_Customer_Item_Id,
			X_Inventory_Item_Id,
			X_Master_Organization_Id,
			X_Rank,
			X_Inactive_Flag,
			X_Last_Update_Date,
			X_Last_Updated_By,
			X_Creation_Date,
			X_Created_By,
			X_Last_Update_Login,
			X_Attribute_Category,
			X_Attribute1,
			X_Attribute2,
			X_Attribute3,
			X_Attribute4,
			X_Attribute5,
			X_Attribute6,
			X_Attribute7,
			X_Attribute8,
			X_Attribute9,
			X_Attribute10,
			X_Attribute11,
			X_Attribute12,
			X_Attribute13,
			X_Attribute14,
			X_Attribute15
			);

	OPEN C;
	FETCH C INTO X_Rowid;
	IF (C%NOTFOUND) THEN
	   CLOSE C;
	   RAISE NO_DATA_FOUND;
	END IF;
	CLOSE C;
END Insert_Row;


PROCEDURE Lock_Row     (X_Rowid				VARCHAR2,
			X_Customer_Item_Id		NUMBER,
			X_Inventory_Item_Id		NUMBER,
			X_Master_Organization_Id	NUMBER,
			X_Rank 				NUMBER,
			X_Inactive_Flag			VARCHAR2,
			X_Last_Update_Date		DATE,
			X_Last_Updated_By		NUMBER,
			X_Creation_Date			DATE,
			X_Created_By			NUMBER,
			X_Last_Update_Login		NUMBER,
			X_Attribute_Category		VARCHAR2,
			X_Attribute1			VARCHAR2,
			X_Attribute2			VARCHAR2,
			X_Attribute3			VARCHAR2,
			X_Attribute4			VARCHAR2,
			X_Attribute5			VARCHAR2,
			X_Attribute6			VARCHAR2,
			X_Attribute7			VARCHAR2,
			X_Attribute8			VARCHAR2,
			X_Attribute9			VARCHAR2,
			X_Attribute10			VARCHAR2,
			X_Attribute11			VARCHAR2,
			X_Attribute12			VARCHAR2,
			X_Attribute13			VARCHAR2,
			X_Attribute14			VARCHAR2,
			X_Attribute15			VARCHAR2
			) IS

CURSOR C IS

	SELECT *
	FROM   mtl_customer_item_xrefs
	WHERE  rowid = X_Rowid
	FOR UPDATE of Customer_Item_Id, Inventory_Item_Id,
		      Master_Organization_Id NOWAIT;

Recinfo C%ROWTYPE;

BEGIN
	OPEN C;
	FETCH C INTO Recinfo;

	IF (C%NOTFOUND) THEN

	    CLOSE C;
	    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
	    APP_EXCEPTION.Raise_Exception;

	END IF;

	CLOSE C;

	IF (
                (Recinfo.inventory_item_id =  X_Inventory_Item_Id)
	   AND  (Recinfo.customer_item_id  =  X_Customer_Item_Id )
	   AND  (Recinfo.master_organization_id = X_Master_Organization_Id)
	   AND  (Recinfo.preference_number = X_Rank)
	   AND  (Recinfo.last_updated_by = X_Last_Updated_By)
	   AND  (Recinfo.last_update_date = X_Last_Update_Date)
	   AND  (Recinfo.creation_date = X_Creation_Date)
	   AND  (Recinfo.created_by = X_Created_By)
	   AND  (Recinfo.inactive_flag = X_Inactive_Flag)
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))

	) THEN

		RETURN;

	ELSE

		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;

	END IF;

END Lock_Row;


PROCEDURE Update_Row   (X_Rowid				VARCHAR2,
			X_Customer_Item_Id		NUMBER,
			X_Inventory_Item_Id		NUMBER,
			X_Master_Organization_Id	NUMBER,
			X_Rank 				NUMBER,
			X_Inactive_Flag			VARCHAR2,
			X_Last_Update_Date		DATE,
			X_Last_Updated_By		NUMBER,
			X_Creation_Date			DATE,
			X_Created_By			NUMBER,
			X_Last_Update_Login		NUMBER,
			X_Attribute_Category		VARCHAR2,
			X_Attribute1			VARCHAR2,
			X_Attribute2			VARCHAR2,
			X_Attribute3			VARCHAR2,
			X_Attribute4			VARCHAR2,
			X_Attribute5			VARCHAR2,
			X_Attribute6			VARCHAR2,
			X_Attribute7			VARCHAR2,
			X_Attribute8			VARCHAR2,
			X_Attribute9			VARCHAR2,
			X_Attribute10			VARCHAR2,
			X_Attribute11			VARCHAR2,
			X_Attribute12			VARCHAR2,
			X_Attribute13			VARCHAR2,
			X_Attribute14			VARCHAR2,
			X_Attribute15			VARCHAR2
			) IS
BEGIN

UPDATE mtl_customer_item_xrefs
SET

	Customer_Item_Id	=	X_Customer_Item_Id,
	Inventory_Item_Id	=	X_Inventory_Item_Id,
	Master_Organization_Id	=	X_Master_Organization_Id,
	Preference_Number	=	X_Rank,
	Inactive_Flag		=	X_Inactive_Flag,
	Last_Update_Date	=	X_Last_Update_Date,
	Last_Updated_By		=	X_Last_Updated_By,
	Creation_Date		=	X_Creation_Date,
	Created_By		=	X_Created_By,
	Last_Update_Login	=	X_Last_Update_Login,
	Attribute_Category	=	X_Attribute_Category,
	Attribute1		=	X_Attribute1,
	Attribute2		=	X_Attribute2,
	Attribute3		=	X_Attribute3,
	Attribute4		=	X_Attribute4,
	Attribute5		=	X_Attribute5,
	Attribute6		=	X_Attribute6,
	Attribute7		=	X_Attribute7,
	Attribute8		=	X_Attribute8,
	Attribute9		=	X_Attribute9,
	Attribute10		=	X_Attribute10,
	Attribute11		=	X_Attribute11,
	Attribute12		=	X_Attribute12,
	Attribute13		=	X_Attribute13,
	Attribute14		=	X_Attribute14,
	Attribute15		=	X_Attribute15

WHERE rowid = X_Rowid;

IF (SQL%NOTFOUND) THEN

	RAISE NO_DATA_FOUND;

END IF;

END Update_Row;


PROCEDURE CHECK_UNIQUE (X_Rowid VARCHAR2,
			X_Customer_Item_Id NUMBER,
			X_Inventory_Item_Id NUMBER,
			X_Master_Organization_Id NUMBER) IS

Dummy NUMBER;

BEGIN

	SELECT COUNT(1)
	INTO   Dummy
	FROM   MTL_CUSTOMER_ITEM_XREFS
	WHERE  Customer_Item_Id = X_Customer_Item_Id
	AND    Inventory_Item_Id = X_Inventory_Item_Id
	AND    Master_Organization_Id = X_Master_Organization_Id
	AND    ((X_Rowid IS NULL) OR (ROWID <> X_Rowid));

	IF (Dummy >= 1) THEN

		FND_MESSAGE.SET_NAME('INV', 'INV_DUP_CUST_ITEM_XREF');
		APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;

END CHECK_UNIQUE;


PROCEDURE CHECK_UNIQUE_RANK (X_Rowid VARCHAR2,
			     X_Customer_Item_Id NUMBER,
			     X_Master_Organization_Id NUMBER,
			     X_Rank NUMBER ) IS

Dummy NUMBER;

BEGIN

	SELECT COUNT(1)
	INTO   Dummy
	FROM   MTL_CUSTOMER_ITEM_XREFS
	WHERE  Customer_Item_Id = X_Customer_Item_Id
	AND    Master_Organization_Id = X_Master_Organization_Id
	AND    Preference_Number = X_Rank
	AND    ((X_Rowid IS NULL) OR (ROWID <> X_Rowid));

	IF (Dummy >= 1) THEN

		FND_MESSAGE.SET_NAME('INV', 'INV_DUP_CUST_ITEM_XREF');
		APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;

END CHECK_UNIQUE_RANK;


END INVICXRF;

/
