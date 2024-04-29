--------------------------------------------------------
--  DDL for Package Body ARP_CREL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CREL_PKG" as
/* $Header: AROCRELB.pls 120.1 2005/09/13 18:08:03 mantani noship $ */
  PROCEDURE  check_unique(x_customer_id in number ,x_related_customer_id in number ) is
/*
  --
  duplicate_count number(15);
  --
  -- BUG Fix 1283492. Fix made to allow users to in-activate a relationship between
  -- two customers, and be able to create a new relationship. Without the fix, users
  -- get the message that the relationship already exists, even though it is inactive.
  -- Fix is to check for only active duplicate relationships.
*/

  begin
null;
/*
	select count(1)
        into    duplicate_count
	from   ra_customer_relationships
	where  customer_id		= x_customer_id
        and    status                   = 'A'
	and    related_customer_id	= x_related_customer_id;

	if (duplicate_count >= 1 ) then
		fnd_message.set_name('AR','AR_CUST_REL_ALREADY_EXISTS');
		app_exception.raise_exception;
	end if;
*/
  end  check_unique;
  --
  --
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Customer_Id                    NUMBER,
                       X_Customer_Reciprocal_Flag       VARCHAR2,
		       X_relationship_type		VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Related_Customer_Id            NUMBER,
                       X_Status                         VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
  ) IS
/*
    CURSOR C IS SELECT rowid FROM RA_CUSTOMER_RELATIONSHIPS
structure                 WHERE related_customer_id = X_Related_Customer_Id
                 AND   customer_id = X_Customer_Id;
   --
   l_row_id varchar2(240);
   --
*/
   BEGIN
       --
null;
/*
       check_unique(x_customer_id,x_related_customer_id);
       --
       INSERT INTO RA_CUSTOMER_RELATIONSHIPS(
              created_by,
              creation_date,
              customer_id,
              customer_reciprocal_flag,
              last_updated_by,
              last_update_date,
              related_customer_id,
              status,
              comments,
              last_update_login,
              relationship_type,
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
              attribute15
             ) VALUES (

              X_Created_By,
              X_Creation_Date,
              X_Customer_Id,
              X_Customer_Reciprocal_Flag,
              X_Last_Updated_By,
              X_Last_Update_Date,
              X_Related_Customer_Id,
              X_Status,
              X_Comments,
              X_Last_Update_Login,
              x_relationship_type,
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
    --
    if ( x_customer_reciprocal_flag = 'Y' ) then
    --
    --  Attempt to update the reciprocal relationship.
    --  	If   it exists then update it
    --          else insert a relationship
    --
    	update 	ra_customer_relationships
    	set    	customer_reciprocal_flag = 'Y'
	where 	customer_ID 		= x_related_customer_id
	and   	related_customer_id	= x_customer_id;
   --
   --
   --
   	if ( SQL%NOTFOUND ) then
   	--
   	 insert into ra_customer_relationships
   	 ( 	related_customer_id,
		last_update_date,
		last_updated_by,
		creation_date,
 		created_by,
		last_update_login,
		customer_id,
		relationship_type,
 		comments,
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
		customer_reciprocal_flag,
		status)
	   values
	   (	x_customer_id,
		x_last_update_date,
		x_last_updated_by,
		x_creation_date,
 		x_created_by,
		x_last_update_login,
		x_related_customer_id,
		x_relationship_type,
 		x_comments,
		x_attribute_category,
		x_attribute1,
		x_attribute2,
		x_attribute3,
 		x_attribute4,
		x_attribute5,
		x_attribute6,
		x_attribute7,
		x_attribute8,
 		x_attribute9,
		x_attribute10,
		x_attribute11,
		x_attribute12,
		x_attribute13,
 		x_attribute14,
		x_attribute15,
		x_customer_reciprocal_flag,
		x_status);
		--
	end if;
	--
	--
    end if;
    --
    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
*/
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Customer_Id                      NUMBER,
                     X_Customer_Reciprocal_Flag         VARCHAR2,
                     X_Related_Customer_Id              NUMBER,
                     X_Status                           VARCHAR2,
                     X_Comments                         VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2
  ) IS
/*
    CURSOR C IS
        SELECT *
        FROM   RA_CUSTOMER_RELATIONSHIPS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Related_Customer_Id NOWAIT;
    Recinfo C%ROWTYPE;
*/

  BEGIN
null;
/*
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.customer_id =  X_Customer_Id)
           AND (Recinfo.customer_reciprocal_flag =  X_Customer_Reciprocal_Flag)
           AND (Recinfo.related_customer_id =  X_Related_Customer_Id)
           AND (Recinfo.status =  X_Status)
           AND (   (Recinfo.comments =  X_Comments)
                OR (    (Recinfo.comments IS NULL)
                    AND (X_Comments IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
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
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
*/
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Customer_Id                    NUMBER,
                       X_Customer_Reciprocal_Flag       VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Related_Customer_Id            NUMBER,
                       X_Status                         VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
  ) IS
  BEGIN
null;
/*
    -- Bug fix 1283492. Check for unique relationship only if updating status to active

    if (x_status = 'A') then
        check_unique(x_customer_id,x_related_customer_id);
    end if;

    UPDATE RA_CUSTOMER_RELATIONSHIPS
    SET
       customer_id                     =     X_Customer_Id,
       customer_reciprocal_flag        =     X_Customer_Reciprocal_Flag,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_date                =     X_Last_Update_Date,
       related_customer_id             =     X_Related_Customer_Id,
       status                          =     X_Status,
       comments                        =     X_Comments,
       last_update_login               =     X_Last_Update_Login,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
	--
	-- Update the reciprocal relationship.
	-- if it exist.
	--
	update 	ra_customer_relationships
	set 	customer_reciprocal_flag = decode(x_status,
						   'I','N',
						   'A','Y'
						  )
	where 	customer_id 		 = x_related_customer_id
	and 	related_customer_id 	 = x_customer_id;
	--
	--
*/
  END Update_Row;

END arp_crel_pkg;

/
