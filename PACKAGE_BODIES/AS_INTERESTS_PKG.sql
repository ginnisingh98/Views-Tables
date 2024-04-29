--------------------------------------------------------
--  DDL for Package Body AS_INTERESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_INTERESTS_PKG" as
/* $Header: asxininb.pls 115.10 2004/01/16 07:02:40 gbatra ship $ */

--
-- ??-???-94 J Sondergaard  Created
-- 04-JUN-95 J Sondergaard  Added Interest_Use_Code and
--              Interest_Type_Id
-- 26-DEC-96 J Kornberg     Added program who columns and lead id to
--              table handlers
-- 30-OCT-03 gbatra         Product Hierarchy uptake changes
--
--

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Interest_Id                         IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
             X_Interest_Use_Code           VARCHAR2,
                     X_Interest_Type_Id            NUMBER,
                     X_Contact_Id                          NUMBER,
                     X_Customer_Id                         NUMBER,
                     X_Address_Id                          NUMBER,
                     X_Primary_Interest_Code_Id            NUMBER DEFAULT NULL,
                     X_Secondary_Interest_Code_Id          NUMBER DEFAULT NULL,
                     X_Status_Code                         VARCHAR2 DEFAULT NULL,
                     X_Description                         VARCHAR2 DEFAULT NULL,
                     X_Attribute_Category                  VARCHAR2 DEFAULT NULL,
                     X_Attribute1                          VARCHAR2 DEFAULT NULL,
                     X_Attribute2                          VARCHAR2 DEFAULT NULL,
                     X_Attribute3                          VARCHAR2 DEFAULT NULL,
                     X_Attribute4                          VARCHAR2 DEFAULT NULL,
                     X_Attribute5                          VARCHAR2 DEFAULT NULL,
                     X_Attribute6                          VARCHAR2 DEFAULT NULL,
                     X_Attribute7                          VARCHAR2 DEFAULT NULL,
                     X_Attribute8                          VARCHAR2 DEFAULT NULL,
                     X_Attribute9                          VARCHAR2 DEFAULT NULL,
                     X_Attribute10                         VARCHAR2 DEFAULT NULL,
                     X_Attribute11                         VARCHAR2 DEFAULT NULL,
                     X_Attribute12                         VARCHAR2 DEFAULT NULL,
                     X_Attribute13                         VARCHAR2 DEFAULT NULL,
                     X_Attribute14                         VARCHAR2 DEFAULT NULL,
                     X_Attribute15                         VARCHAR2 DEFAULT NULL,
             X_Lead_Id                 NUMBER DEFAULT NULL,
             X_Request_Id                          NUMBER DEFAULT NULL,
                     X_Program_Application_Id              NUMBER DEFAULT NULL,
                     X_Program_Id                          NUMBER DEFAULT NULL,
                     X_Program_Update_Date                 DATE DEFAULT NULL,
                     X_Product_Category_Id                 NUMBER,
                     X_Product_Cat_Set_Id                  NUMBER

 ) IS
   CURSOR C IS SELECT rowid FROM as_interests
               WHERE  interest_id = X_Interest_Id;
   CURSOR C2 IS SELECT as_interests_s.nextval FROM sys.dual;

   X_User_Id    NUMBER;
   X_Login_Id   NUMBER;
   X_Date       DATE;
BEGIN
  if (X_Interest_Id is NULL) then
    OPEN C2;
    FETCH C2 INTO X_Interest_Id;
    CLOSE C2;
  end if;
  if (X_Created_By is NULL) then
    X_User_Id    := FND_GLOBAL.User_Id;
    X_Login_Id   := FND_GLOBAL.Login_Id;
    X_Date       := SYSDATE;
  else
    X_User_Id    := X_Created_By;
    X_Login_Id   := X_Last_Update_Login;
    X_Date       := X_Creation_Date;
  end if;

  INSERT INTO as_interests(
          interest_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          request_id,
      program_application_id,
      program_id,
      program_update_date,
      interest_use_code,
          interest_type_id,
          contact_id,
          customer_id,
          address_id,
          lead_id,
          primary_interest_code_id,
          secondary_interest_code_id,
          Status_Code,
          description,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          product_category_id,
          product_cat_set_id
         ) VALUES (
          X_Interest_Id,
          X_Date,
          X_User_Id,
          X_Date,
          X_User_Id,
          X_Login_Id,
      X_Request_Id,
      X_Program_Application_Id,
      X_Program_Id,
      X_Program_Update_Date,
      X_Interest_Use_Code,
          X_Interest_Type_Id,
          X_Contact_Id,
          X_Customer_Id,
          X_Address_Id,
      X_Lead_Id,
          X_Primary_Interest_Code_Id,
          X_Secondary_Interest_Code_Id,
          X_Status_Code,
          X_Description,
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
          X_Attribute15,
          X_Product_Category_Id,
          X_Product_Cat_Set_Id);

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;


PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Interest_Id                           NUMBER,
           X_Interest_Use_Code             VARCHAR2,
           X_Interest_Type_Id              NUMBER,
                   X_Contact_Id                            NUMBER,
                   X_Customer_Id                           NUMBER,
                   X_Address_Id                            NUMBER,
                   X_Primary_Interest_Code_Id              NUMBER DEFAULT NULL,
                   X_Secondary_Interest_Code_Id            NUMBER DEFAULT NULL,
                   X_Status_Code                           VARCHAR2 DEFAULT NULL,
                   X_Description                           VARCHAR2 DEFAULT NULL,
                   X_Attribute_Category                    VARCHAR2 DEFAULT NULL,
                   X_Attribute1                            VARCHAR2 DEFAULT NULL,
                   X_Attribute2                            VARCHAR2 DEFAULT NULL,
                   X_Attribute3                            VARCHAR2 DEFAULT NULL,
                   X_Attribute4                            VARCHAR2 DEFAULT NULL,
                   X_Attribute5                            VARCHAR2 DEFAULT NULL,
                   X_Attribute6                            VARCHAR2 DEFAULT NULL,
                   X_Attribute7                            VARCHAR2 DEFAULT NULL,
                   X_Attribute8                            VARCHAR2 DEFAULT NULL,
                   X_Attribute9                            VARCHAR2 DEFAULT NULL,
                   X_Attribute10                           VARCHAR2 DEFAULT NULL,
                   X_Attribute11                           VARCHAR2 DEFAULT NULL,
                   X_Attribute12                           VARCHAR2 DEFAULT NULL,
                   X_Attribute13                           VARCHAR2 DEFAULT NULL,
                   X_Attribute14                           VARCHAR2 DEFAULT NULL,
                   X_Attribute15                           VARCHAR2 DEFAULT NULL,
           X_Lead_Id                   NUMBER DEFAULT NULL,
                   X_Product_Category_Id                    NUMBER,
                   X_Product_Cat_Set_Id                        NUMBER

) IS
  CURSOR C IS
      SELECT *
      FROM   as_interests
      WHERE  rowid = X_Rowid
      FOR UPDATE of Interest_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (    (   (Recinfo.interest_id = X_Interest_Id)
           OR (    (Recinfo.interest_id IS NULL)
               AND (X_Interest_Id IS NULL)))
      AND (   (Recinfo.interest_type_id = X_Interest_Type_Id)
           OR (    (Recinfo.interest_type_id IS NULL)
               AND (X_Interest_Type_Id IS NULL)))
      AND (   (Recinfo.contact_id = X_Contact_Id)
           OR (    (Recinfo.contact_id IS NULL)
               AND (X_Contact_Id IS NULL)))
      AND (   (Recinfo.customer_id = X_Customer_Id)
           OR (    (Recinfo.customer_id IS NULL)
               AND (X_Customer_Id IS NULL)))
      AND (   (Recinfo.address_id = X_Address_Id)
           OR (    (Recinfo.address_id IS NULL)
               AND (X_Address_Id IS NULL)))
      AND (   (Recinfo.interest_use_code = X_Interest_Use_Code)
           OR (    (Recinfo.interest_use_code IS NULL)
               AND (X_Interest_Use_Code IS NULL)))
      AND (   (Recinfo.primary_interest_code_id = X_Primary_Interest_Code_Id)
           OR (    (Recinfo.primary_interest_code_id IS NULL)
               AND (X_Primary_Interest_Code_Id IS NULL)))
      AND (   (Recinfo.secondary_interest_code_id = X_Secondary_Interest_Code_Id)
           OR (    (Recinfo.secondary_interest_code_id IS NULL)
               AND (X_Secondary_Interest_Code_Id IS NULL)))
      AND (   (Recinfo.Status_Code = X_Status_Code)
           OR (    (Recinfo.Status_Code IS NULL)
               AND (X_Status_Code IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.attribute_category = X_Attribute_Category)
           OR (    (Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
      AND (   (Recinfo.lead_id = X_Lead_Id)
           OR (    (Recinfo.lead_id IS NULL)
               AND (X_Lead_Id IS NULL)))
      AND (   (Recinfo.product_category_id = X_Product_Category_Id)
           OR (    (Recinfo.product_category_id IS NULL)
               AND (X_Product_Category_Id IS NULL)))
      AND (   (Recinfo.product_cat_set_id = X_Product_Cat_Set_Id)
           OR (    (Recinfo.product_cat_set_id IS NULL)
               AND (X_Product_Cat_Set_Id IS NULL)))
      ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Interest_Id                         NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Interest_Use_Code                   VARCHAR2,
             X_Interest_Type_Id            NUMBER,
                     X_Contact_Id                          NUMBER,
                     X_Customer_Id                         NUMBER,
                     X_Address_Id                          NUMBER,
                     X_Primary_Interest_Code_Id            NUMBER DEFAULT FND_API.G_MISS_NUM,
                     X_Secondary_Interest_Code_Id          NUMBER DEFAULT FND_API.G_MISS_NUM,
                     X_Status_Code                         VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Description                         VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute_Category                  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute1                          VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute2                          VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute3                          VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute4                          VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute5                          VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute6                          VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute7                          VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute8                          VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute9                          VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute10                         VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute11                         VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute12                         VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute13                         VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute14                         VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
                     X_Attribute15                         VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
             X_Lead_Id                 NUMBER DEFAULT FND_API.G_MISS_NUM,
             X_Request_Id                          NUMBER DEFAULT NULL,
                     X_Program_Application_Id              NUMBER DEFAULT NULL,
                     X_Program_Id                          NUMBER DEFAULT NULL,
                     X_Program_Update_Date                 DATE DEFAULT NULL,
                     X_Product_Category_Id                    NUMBER,
                     X_Product_Cat_Set_Id                     NUMBER

) IS
l_description varchar2(30);
BEGIN
  UPDATE as_interests_all
  SET
    object_version_number =  nvl(object_version_number,0) + 1,
    interest_id         = decode(X_Interest_Id,FND_API.G_MISS_NUM, interest_id, X_Interest_Id),
    last_update_date    =    X_Last_Update_Date,
    last_updated_by     =    X_Last_Updated_By,
    last_update_login   =    X_Last_Update_Login,
    interest_use_code   = decode(X_Interest_Use_Code,FND_API.G_MISS_CHAR,interest_use_code,X_Interest_Use_Code),
    interest_type_id    = decode(X_Interest_Type_Id, FND_API.G_MISS_NUM,interest_type_id, X_Interest_Type_Id),
    contact_id          = decode(X_Contact_Id,FND_API.G_MISS_NUM, contact_id, X_Contact_Id),
    customer_id         = decode(X_Customer_Id,FND_API.G_MISS_NUM,customer_id,X_Customer_Id),
    address_id          = decode(X_Address_Id,FND_API.G_MISS_NUM, address_id, X_Address_Id),
    primary_interest_code_id     =decode(X_Primary_Interest_Code_Id,
                    FND_API.G_MISS_NUM, primary_interest_code_id,X_Primary_Interest_Code_Id),
    secondary_interest_code_id   = decode(X_Secondary_Interest_Code_Id,
                    FND_API.G_MISS_NUM, Secondary_interest_code_id,X_Secondary_Interest_Code_Id),
    Status_Code = decode(X_Status_Code,FND_API.G_MISS_CHAR, status_code, X_Status_Code),
    description = decode(X_Description,FND_API.G_MISS_CHAR, description, X_Description),
    attribute_category = decode(X_Attribute_Category,FND_API.G_MISS_CHAR,attribute_category,X_Attribute_Category),
    attribute1 = decode(X_Attribute1,FND_API.G_MISS_CHAR,attribute1,X_Attribute1),
    attribute2 = decode(X_Attribute2,FND_API.G_MISS_CHAR,attribute2,X_Attribute2),
    attribute3 = decode(X_Attribute3,FND_API.G_MISS_CHAR,attribute3,X_Attribute3),
    attribute4 = decode(X_Attribute4,FND_API.G_MISS_CHAR,attribute4,X_Attribute4),
    attribute5 = decode(X_Attribute5,FND_API.G_MISS_CHAR,attribute5,X_Attribute5),
    attribute6 = decode(X_Attribute6,FND_API.G_MISS_CHAR,attribute6,X_Attribute6),
    attribute7 = decode(X_Attribute7,FND_API.G_MISS_CHAR,attribute7,X_Attribute7),
    attribute8 = decode(X_Attribute8,FND_API.G_MISS_CHAR,attribute8,X_Attribute8),
    attribute9 = decode(X_Attribute9,FND_API.G_MISS_CHAR,attribute9,X_Attribute9),
    attribute10 = decode(X_Attribute10,FND_API.G_MISS_CHAR,attribute10,X_Attribute10),
    attribute11 = decode(X_Attribute11,FND_API.G_MISS_CHAR,attribute11,X_Attribute11),
    attribute12 = decode(X_Attribute12,FND_API.G_MISS_CHAR,attribute12,X_Attribute12),
    attribute13 = decode(X_Attribute13,FND_API.G_MISS_CHAR,attribute13,X_Attribute13),
    attribute14 = decode(X_Attribute14,FND_API.G_MISS_CHAR,attribute14,X_Attribute14),
    attribute15 = decode(X_Attribute15,FND_API.G_MISS_CHAR,attribute15,X_Attribute15),
    lead_id = decode(X_Lead_Id,FND_API.G_MISS_NUM, lead_id,X_Lead_Id),
    request_id                    =    X_Request_Id,
    program_application_id            =    X_Program_Application_Id,
    program_id                    =    X_Program_Id,
    program_update_date               =    X_Program_Update_Date,
    product_category_id    = decode(X_Product_Category_Id, FND_API.G_MISS_NUM,product_category_id, X_Product_Category_Id),
    product_cat_set_id     = decode(X_Product_Cat_Set_Id, FND_API.G_MISS_NUM,product_cat_set_id, X_Product_Cat_Set_Id)
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM as_interests
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

END AS_INTERESTS_PKG;

/
