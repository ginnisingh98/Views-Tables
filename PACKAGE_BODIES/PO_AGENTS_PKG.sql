--------------------------------------------------------
--  DDL for Package Body PO_AGENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AGENTS_PKG" as
/* $Header: POXTIDBB.pls 115.2 2002/11/23 01:22:14 sbull ship $ */


  PROCEDURE Insert_Row(X_Rowid                  IN OUT NOCOPY VARCHAR2,
                       X_Agent_Id                	NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
		       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Location_ID		        NUMBER,
                       X_Category_ID			NUMBER,
		       X_Authorization_Limit		NUMBER,
		       X_Start_Date_Active		DATE,
		       X_End_Date_Active		DATE,
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
		       X_Attribute15			VARCHAR2)

     IS
     CURSOR C IS SELECT rowid FROM PO_AGENTS
                 WHERE agent_id = X_Agent_Id;


    BEGIN


       INSERT INTO PO_AGENTS(
			Agent_Id,
                       	Last_Update_Date,
                       	Last_Updated_By,
		       	Last_Update_Login,
                       	Creation_Date,
                       	Created_By,
                       	Location_ID,
                       	Category_ID,
		       	Authorization_Limit,
		       	Start_Date_Active,
		       	End_Date_Active,
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
		       	Attribute15)
             VALUES (	X_Agent_Id,
		       	X_Last_Update_Date,
                       	X_Last_Updated_By,
		       	X_Last_Update_Login,
                       	X_Creation_Date,
                       	X_Created_By,
                       	X_Location_ID,
                       	X_Category_ID,
		       	X_Authorization_Limit,
		       	X_Start_Date_Active,
		       	X_End_Date_Active,
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
		       	X_Attribute15);

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;



  PROCEDURE Lock_Row(	X_Rowid                    	VARCHAR2,
		     	X_Agent_ID			NUMBER,
			X_Last_Update_Login		NUMBER,
                       	X_Location_ID		        NUMBER,
                       	X_Category_ID			NUMBER,
		       	X_Authorization_Limit		NUMBER,
		       	X_Start_Date_Active		DATE,
		       	X_End_Date_Active		DATE,
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
		       	X_Attribute15			VARCHAR2)
  IS
    CURSOR C IS
        SELECT *
        FROM   PO_AGENTS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Agent_Id NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if ( (Recinfo.agent_id = X_Agent_Id)
           AND (   (Recinfo.last_update_login = X_Last_Update_Login)
                OR (    (Recinfo.last_update_login IS NULL)
                    AND (X_Last_Update_Login IS NULL)))
           AND (   (Recinfo.location_id = X_Location_ID)
                OR (    (Recinfo.location_id IS NULL)
                    AND (X_Location_ID IS NULL)))
           AND (   (Recinfo.category_id = X_Category_ID)
                OR (    (Recinfo.category_id IS NULL)
                    AND (X_Category_ID IS NULL)))
           AND (   (Recinfo.authorization_limit = X_Authorization_Limit)
                OR (    (Recinfo.authorization_limit IS NULL)
                    AND (X_Authorization_Limit IS NULL)))
           AND (   (Recinfo.start_date_active = X_Start_Date_Active)
                OR (    (Recinfo.start_date_active IS NULL)
                    AND (X_Start_Date_Active IS NULL)))
           AND (   (Recinfo.end_date_active = X_End_Date_Active)
                OR (    (Recinfo.end_date_active IS NULL)
                    AND (X_End_Date_Active IS NULL)))
	   AND (   (Recinfo.attribute_category = X_Attribute_Category)
		OR (	(Recinfo.attribute_category is NULL)
		    AND (X_Attribute_Category IS NULL)))
	   AND (   (Recinfo.attribute1 = X_Attribute1)
		OR (	(Recinfo.attribute1 IS NULL)
		    AND (X_Attribute1 IS NULL)))
	   AND (   (Recinfo.attribute2 = X_Attribute2)
		OR (    (Recinfo.attribute2 IS NULL)
		    AND (X_Attribute2 IS NULL)))
	   AND (   (Recinfo.attribute3 = X_Attribute3)
		OR (	(Recinfo.attribute3 IS NULL)
		    AND (X_Attribute3 IS NULL)))
	   AND (   (Recinfo.attribute4 = X_Attribute4)
		OR (	(Recinfo.attribute4 IS NULL)
		    AND (X_Attribute4 IS NULL)))
	   AND (   (Recinfo.attribute5 = X_Attribute5)
		OR (	(Recinfo.attribute5 IS NULL)
		    AND (X_Attribute5 IS NULL)))
	   AND (   (Recinfo.attribute6 = X_Attribute6)
		OR (	(Recinfo.attribute6 IS NULL)
		    AND (X_Attribute6 IS NULL)))
	   AND (   (Recinfo.attribute7 = X_Attribute7)
		OR (	(Recinfo.attribute7 IS NULL)
		    AND (X_Attribute7 IS NULL)))
	   AND (   (Recinfo.attribute8 = X_Attribute8)
		OR (	(Recinfo.attribute8 IS NULL)
		    AND (X_Attribute8 IS NULL)))
	   AND (   (Recinfo.attribute9 = X_Attribute9)
		OR (	(Recinfo.attribute9 IS NULL)
		    AND (X_Attribute9 IS NULL)))
	   AND (   (Recinfo.attribute10 = X_Attribute10)
		OR (	(Recinfo.attribute10 IS NULL)
		    AND (X_Attribute10 IS NULL)))
	   AND (   (Recinfo.attribute11 = X_Attribute11)
		OR (	(Recinfo.attribute11 IS NULL)
		    AND (X_Attribute11 IS NULL)))
	   AND (   (Recinfo.attribute12 = X_Attribute12)
		OR (	(Recinfo.attribute12 IS NULL)
		    AND (X_Attribute12 IS NULL)))
	   AND (   (Recinfo.attribute13 = X_Attribute13)
		OR (	(Recinfo.attribute13 IS NULL)
		    AND (X_Attribute13 IS NULL)))
	   AND (   (Recinfo.attribute14 = X_Attribute14)
		OR (	(Recinfo.attribute14 IS NULL)
		    AND (X_Attribute14 IS NULL)))
	   AND (   (Recinfo.attribute15 = X_Attribute15)
		OR (	(Recinfo.attribute15 IS NULL)
		    AND (X_Attribute15 IS NULL)))
            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Agent_Id                	NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
		       X_Last_Update_Login              NUMBER,
                       X_Location_ID		        NUMBER,
                       X_Category_ID			NUMBER,
		       X_Authorization_Limit		NUMBER,
		       X_Start_Date_Active		DATE,
		       X_End_Date_Active		DATE,
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
		       X_Attribute15			VARCHAR2)

   IS
 BEGIN
   UPDATE PO_AGENTS
   SET		agent_id		=	X_Agent_Id,
		last_update_date 	=      	X_Last_Update_Date,
              	last_updated_by		=	X_Last_Updated_By,
		last_update_login	=	X_Last_Update_Login,
                location_id		=	X_Location_ID,
		category_id		=	X_Category_ID,
		authorization_limit	=	X_Authorization_Limit,
		start_date_active	=	X_Start_Date_Active,
		end_date_active		=	X_End_Date_Active,
		attribute_category	=	X_Attribute_Category,
		attribute1		=	X_Attribute1,
		attribute2		=	X_Attribute2,
		attribute3		=	X_Attribute3,
		attribute4		=	X_Attribute4,
		attribute5		=	X_Attribute5,
		attribute6		=	X_Attribute6,
		attribute7		=	X_Attribute7,
		attribute8		=	X_Attribute8,
		attribute9		=	X_Attribute9,
		attribute10		=	X_Attribute10,
		attribute11		=	X_Attribute11,
		attribute12		=	X_Attribute12,
		attribute13		=	X_Attribute13,
		attribute14		=	X_Attribute14,
		attribute15		=	X_Attribute15
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PO_AGENTS
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END PO_AGENTS_PKG;

/
