--------------------------------------------------------
--  DDL for Package Body FA_LEASES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_LEASES_PKG" as
/* $Header: faxilsb.pls 120.3.12010000.2 2009/07/19 10:38:48 glchen ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Lease_Id                       NUMBER,
                       X_Lease_Number                   VARCHAR2,
                       X_Lessor_Id                      NUMBER,
                       X_Description                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Created_By                     NUMBER DEFAULT NULL,
                       X_Creation_Date                  DATE DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category_Code        VARCHAR2 DEFAULT NULL,
			X_Calling_Fn			VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS SELECT rowid FROM fa_leases
                 WHERE lease_id = X_Lease_Id;

   BEGIN


       INSERT INTO fa_leases(

              lease_id,
              lease_number,
              lessor_id,
              description,
              last_update_date,
              last_updated_by,
              created_by,
              creation_date,
              last_update_login,
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
              attribute_category_code
             ) VALUES (

              X_Lease_Id,
              X_Lease_Number,
              X_Lessor_Id,
              X_Description,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Created_By,
              X_Creation_Date,
              X_Last_Update_Login,
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
              X_Attribute_Category_Code
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  EXCEPTION
	WHEN Others THEN
		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn	=> 'FA_LEASES_PKG.Insert_Row',
			Calling_Fn	=> X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Insert_Row;
  --
  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Lease_Id                         NUMBER,
                     X_Lease_Number                     VARCHAR2,
                     X_Lessor_Id                        NUMBER,
                     X_Description                      VARCHAR2,
                     X_Attribute1                       VARCHAR2 DEFAULT NULL,
                     X_Attribute2                       VARCHAR2 DEFAULT NULL,
                     X_Attribute3                       VARCHAR2 DEFAULT NULL,
                     X_Attribute4                       VARCHAR2 DEFAULT NULL,
                     X_Attribute5                       VARCHAR2 DEFAULT NULL,
                     X_Attribute6                       VARCHAR2 DEFAULT NULL,
                     X_Attribute7                       VARCHAR2 DEFAULT NULL,
                     X_Attribute8                       VARCHAR2 DEFAULT NULL,
                     X_Attribute9                       VARCHAR2 DEFAULT NULL,
                     X_Attribute10                      VARCHAR2 DEFAULT NULL,
                     X_Attribute11                      VARCHAR2 DEFAULT NULL,
                     X_Attribute12                      VARCHAR2 DEFAULT NULL,
                     X_Attribute13                      VARCHAR2 DEFAULT NULL,
                     X_Attribute14                      VARCHAR2 DEFAULT NULL,
                     X_Attribute15                      VARCHAR2 DEFAULT NULL,
                     X_Attribute_Category_Code          VARCHAR2 DEFAULT NULL,
			X_Calling_Fn			VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS
        SELECT *
        FROM   fa_leases
        WHERE  rowid = X_Rowid
        FOR UPDATE of Lease_Id NOWAIT;
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
    if (

               (Recinfo.lease_id =  X_Lease_Id)
           AND (Recinfo.lease_number =  X_Lease_Number)
           AND (Recinfo.lessor_id =  X_Lessor_Id)
           AND (Recinfo.description =  X_Description)
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
           AND ((Recinfo.attribute_category_code =  X_Attribute_Category_Code)
                OR (    (Recinfo.attribute_category_code IS NULL)
                    AND (X_Attribute_Category_Code IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  -- syoung: added X_Return_Status.
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Lease_Id                       NUMBER,
                       X_Lease_Number                   VARCHAR2,
                       X_Lessor_Id                      NUMBER,
                       X_Description                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
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
                       X_Attribute15                    VARCHAR2,
                       X_Attribute_Category_Code        VARCHAR2,
		       X_Return_Status		 OUT NOCOPY BOOLEAN,
			X_Calling_Fn			VARCHAR2

  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    UPDATE fa_leases
    SET
       lease_id                        =     X_Lease_Id,
       lease_number                    =     X_Lease_Number,
       lessor_id                       =     X_Lessor_Id,
       description                     =     X_Description,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
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
       attribute15                     =     X_Attribute15,
       attribute_category_code         =     X_Attribute_Category_Code
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    X_Return_Status := TRUE;
  EXCEPTION
	WHEN Others THEN
	 	FA_SRVR_MSG.Add_SQL_Error(
			CALLING_FN => 'FA_LEASES_PKG.Update_Row', p_log_level_rec => p_log_level_rec);
--		FA_STANDARD_PKG.RAISE_ERROR
--			(Called_Fn	=> 'FA_LEASES_PKG.Update_Row',
--			Calling_Fn	=> X_Calling_Fn, p_log_level_rec => p_log_level_rec);
		X_Return_Status := FALSE;
  END Update_Row;
  --
  PROCEDURE Delete_Row(X_Rowid 		VARCHAR2 DEFAULT NULL,
			X_Lease_Id	NUMBER DEFAULT NULL,
			X_Calling_Fn			VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    if X_Rowid is not null then
    	DELETE FROM fa_leases
    	WHERE rowid = X_Rowid;
    elsif X_Lease_Id is not null then
	DELETE FROM fa_leases
	WHERE lease_id = X_Lease_Id;
    else
	-- error
	null;
    end if;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
	WHEN Others THEN
		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn	=> 'FA_LEASES_PKG.Delete_Row',
			Calling_Fn	=> X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Delete_Row;


END FA_LEASES_PKG;

/
