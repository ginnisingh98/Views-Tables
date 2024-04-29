--------------------------------------------------------
--  DDL for Package Body FA_TRANSACTION_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TRANSACTION_HEADERS_PKG" as
/* $Header: faxithb.pls 120.5.12010000.2 2009/07/19 10:18:40 glchen ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Transaction_Header_Id          IN OUT NOCOPY NUMBER,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Id                       NUMBER,
                       X_Transaction_Type_Code          VARCHAR2,
                       X_Transaction_Date_Entered       DATE,
                       X_Date_Effective                 DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Transaction_Name               VARCHAR2 DEFAULT NULL,
                       X_Invoice_Transaction_Id         NUMBER DEFAULT NULL,
                       X_Source_Transaction_Header_Id   NUMBER DEFAULT NULL,
                       X_Mass_Reference_Id              NUMBER DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Transaction_Subtype            VARCHAR2 DEFAULT NULL,
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
                       X_Transaction_Key                VARCHAR2 DEFAULT NULL,
                       X_Amortization_Start_Date        DATE     DEFAULT NULL,
                       X_Calling_Interface              VARCHAR2 DEFAULT NULL,
                       X_Mass_Transaction_ID            NUMBER   DEFAULT NULL,
                       X_Member_Transaction_Header_Id   NUMBER   DEFAULT NULL,
                       X_Trx_Reference_Id               NUMBER   DEFAULT NULL,
                       X_Event_Id                       NUMBER   DEFAULT NULL,
		       X_Return_Status		 OUT NOCOPY BOOLEAN,
		         X_Calling_Fn			VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

    CURSOR C IS SELECT rowid FROM fa_transaction_headers
                 WHERE transaction_header_id = X_Transaction_Header_Id;

    CURSOR C2 IS SELECT fa_transaction_headers_s.nextval FROM dual;

  BEGIN
      if (X_Transaction_Header_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Transaction_Header_Id;
        CLOSE C2;
      end if;

      INSERT INTO fa_transaction_headers(
              transaction_header_id,
              book_type_code,
              asset_id,
              transaction_type_code,
              transaction_date_entered,
              date_effective,
              last_update_date,
              last_updated_by,
              transaction_name,
              invoice_transaction_id,
              source_transaction_header_id,
              mass_reference_id,
              last_update_login,
              transaction_subtype,
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
              attribute_category_code,
              transaction_key,
              amortization_start_date,
              calling_interface,
              mass_transaction_id,
              member_transaction_header_id,
              trx_reference_id,
              event_id
      ) VALUES (
              X_Transaction_Header_Id,
              X_Book_Type_Code,
              X_Asset_Id,
              X_Transaction_Type_Code,
              X_Transaction_Date_Entered,
              X_Date_Effective,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Transaction_Name,
              X_Invoice_Transaction_Id,
              X_Source_Transaction_Header_Id,
              X_Mass_Reference_Id,
              X_Last_Update_Login,
              X_Transaction_Subtype,
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
              X_Attribute_Category_Code,
              X_Transaction_Key,
              X_Amortization_Start_Date,
              X_Calling_Interface,
              X_Mass_Transaction_ID,
              X_Member_Transaction_Header_Id,
              X_Trx_Reference_Id,
              X_Event_Id
      );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

    X_Return_Status := TRUE;

  exception
    when others then
      if (X_Calling_Fn = 'fa_unp_dep_pkg.on_insert') then
        -- Unplanned depreciation is called from form, not from
        -- transaction engine.
        FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_transaction_headers_pkg.insert_row',
		CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
	X_Return_Status := FALSE;
      else
	FA_SRVR_MSG.Add_SQL_Error(
		CALLING_FN => 'FA_TRANSACTION_HEADERS_PKG.Insert_Row', p_log_level_rec => p_log_level_rec);
	X_Return_Status := FALSE;
        raise; -- BUG# 2020254
      end if;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Transaction_Header_Id            NUMBER,
                     X_Book_Type_Code                   VARCHAR2,
                     X_Asset_Id                         NUMBER,
                     X_Transaction_Type_Code            VARCHAR2,
                     X_Transaction_Date_Entered         DATE,
                     X_Date_Effective                   DATE,
                     X_Transaction_Name                 VARCHAR2 DEFAULT NULL,
                     X_Invoice_Transaction_Id           NUMBER DEFAULT NULL,
                     X_Source_Transaction_Header_Id     NUMBER DEFAULT NULL,
                     X_Mass_Reference_Id                NUMBER DEFAULT NULL,
                     X_Transaction_Subtype              VARCHAR2 DEFAULT NULL,
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
                     X_Transaction_Key                  VARCHAR2 DEFAULT NULL,
                     X_Amortization_Start_Date          DATE     DEFAULT NULL,
                     X_Calling_Interface                VARCHAR2 DEFAULT NULL,
                     X_Mass_Transaction_ID              NUMBER   DEFAULT NULL,
                     X_Member_Transaction_Header_Id     NUMBER   DEFAULT NULL,
                     X_Trx_Reference_Id                 NUMBER   DEFAULT NULL,
                       X_Event_Id                       NUMBER   DEFAULT NULL,
		         X_Calling_Fn			VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS
        SELECT	transaction_header_id,
		book_type_code,
		asset_id,
		transaction_type_code,
		transaction_date_entered,
		date_effective,
		last_update_date,
		last_updated_by,
		transaction_name,
		invoice_transaction_id,
		source_transaction_header_id,
		mass_reference_id,
		last_update_login,
		transaction_subtype,
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
		attribute_category_code,
		transaction_key,
                amortization_start_date,
                calling_interface,
                mass_transaction_id,
                member_transaction_header_id,
                trx_reference_id,
                event_id
        FROM   fa_transaction_headers
        WHERE  rowid = X_Rowid
        FOR UPDATE of Transaction_Header_Id NOWAIT;
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

               (Recinfo.transaction_header_id =  X_Transaction_Header_Id)
           AND (Recinfo.book_type_code =  X_Book_Type_Code)
           AND (Recinfo.asset_id =  X_Asset_Id)
           AND (Recinfo.transaction_type_code =  X_Transaction_Type_Code)
           AND (Recinfo.transaction_date_entered =  X_Transaction_Date_Entered)
           AND (Recinfo.date_effective =  X_Date_Effective)
           AND (   (Recinfo.transaction_name =  X_Transaction_Name)
                OR (    (Recinfo.transaction_name IS NULL)
                    AND (X_Transaction_Name IS NULL)))
           AND (   (Recinfo.invoice_transaction_id =  X_Invoice_Transaction_Id)
                OR (    (Recinfo.invoice_transaction_id IS NULL)
                    AND (X_Invoice_Transaction_Id IS NULL)))
           AND (   (Recinfo.source_transaction_header_id =
					X_Source_Transaction_Header_Id)
                OR (    (Recinfo.source_transaction_header_id IS NULL)
                    AND (X_Source_Transaction_Header_Id IS NULL)))
           AND (   (Recinfo.mass_reference_id =  X_Mass_Reference_Id)
                OR (    (Recinfo.mass_reference_id IS NULL)
                    AND (X_Mass_Reference_Id IS NULL)))
           AND (   (Recinfo.transaction_subtype =  X_Transaction_Subtype)
                OR (    (Recinfo.transaction_subtype IS NULL)
                    AND (X_Transaction_Subtype IS NULL)))
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
           AND (   (Recinfo.attribute_category_code = X_Attribute_Category_Code)
                OR (    (Recinfo.attribute_category_code IS NULL)
                    AND (X_Attribute_Category_Code IS NULL)))
           AND (   (Recinfo.transaction_key =  X_Transaction_Key)
                OR (    (Recinfo.transaction_key IS NULL)
                    AND (X_Transaction_Key IS NULL)))
           AND (   (Recinfo.amortization_start_date = X_Amortization_Start_Date)
                OR (    (Recinfo.amortization_start_date IS NULL)
                    AND (X_Amortization_Start_Date IS NULL)))
           AND (   (Recinfo.calling_interface =  X_Calling_Interface)
                OR (    (Recinfo.calling_interface IS NULL)
                    AND (X_Calling_Interface IS NULL)))
           AND (   (Recinfo.mass_transaction_id =  X_mass_transaction_id)
                OR (    (Recinfo.mass_transaction_id IS NULL)
                    AND(x_mass_transaction_id IS NULL)))
           AND (   (Recinfo.member_transaction_header_id =  X_Member_Transaction_Header_Id)
                OR (    (Recinfo.member_transaction_header_id IS NULL)
                    AND(X_Member_Transaction_Header_Id IS NULL)))
           AND (   (Recinfo.trx_reference_id =  X_Trx_Reference_Id)
                OR (    (Recinfo.trx_reference_id IS NULL)
                    AND(X_Trx_Reference_Id IS NULL)))
           AND (   (Recinfo.event_id =  X_Event_Id)
                OR (    (Recinfo.event_id IS NULL)
                    AND(X_Event_Id IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(
          X_Rowid                          VARCHAR2,
          X_Transaction_Header_Id          NUMBER   DEFAULT NULL,
          X_Book_Type_Code                 VARCHAR2 DEFAULT NULL,
          X_Asset_Id                       NUMBER   DEFAULT NULL,
          X_Transaction_Type_Code          VARCHAR2 DEFAULT NULL,
          X_Transaction_Date_Entered       DATE     DEFAULT NULL,
          X_Date_Effective                 DATE     DEFAULT NULL,
          X_Last_Update_Date               DATE     DEFAULT NULL,
          X_Last_Updated_By                NUMBER   DEFAULT NULL,
          X_Transaction_Name               VARCHAR2 DEFAULT NULL,
          X_Invoice_Transaction_Id         NUMBER   DEFAULT NULL,
          X_Source_Transaction_Header_Id   NUMBER   DEFAULT NULL,
          X_Mass_Reference_Id              NUMBER   DEFAULT NULL,
          X_Last_Update_Login              NUMBER   DEFAULT NULL,
          X_Transaction_Subtype            VARCHAR2 DEFAULT NULL,
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
          X_Transaction_Key                VARCHAR2 DEFAULT NULL,
          X_Amortization_Start_Date        DATE     DEFAULT NULL,
          X_Calling_Interface              VARCHAR2 DEFAULT NULL,
          X_Mass_Transaction_Id            NUMBER   DEFAULT NULL,
          X_Member_Transaction_Header_Id   NUMBER   DEFAULT NULL,
          X_Trx_Reference_Id               NUMBER   DEFAULT NULL,
          X_Event_Id                       NUMBER   DEFAULT NULL,
          X_Calling_Fn                     VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    UPDATE fa_transaction_headers
    SET
    transaction_header_id
                      = decode(X_Transaction_Header_Id,
                               NULL, transaction_header_id,
                               FND_API.G_MISS_NUM, null,
                               X_Transaction_Header_Id),
    book_type_code    = decode(X_Book_Type_Code,
                               NULL, book_type_code,
                               FND_API.G_MISS_CHAR, null,
                               X_Book_Type_Code),
    asset_id          = decode(X_Asset_Id,
                               NULL, asset_id,
                               FND_API.G_MISS_NUM, null,
                               X_Asset_Id),
    transaction_type_code
                      = decode(X_Transaction_Type_Code,
                               NULL, transaction_type_code,
                               FND_API.G_MISS_CHAR, null,
                               X_Transaction_Type_Code),
    transaction_date_entered
                      = decode(X_Transaction_Date_Entered,
                               NULL, transaction_date_entered,
                               X_Transaction_Date_Entered),
    date_effective    = decode(X_Date_Effective,
                               NULL, date_effective,
                               X_Date_Effective),
    last_update_date  = decode(X_Last_Update_Date,
                               NULL, last_update_date,
                               X_Last_Update_Date),
    last_updated_by   = decode(X_Last_Updated_By,
                               NULL, last_updated_by,
                               FND_API.G_MISS_NUM, null,
                               X_Last_Updated_By),
    transaction_name  = decode(X_Transaction_Name,
                               NULL, transaction_name,
                               FND_API.G_MISS_CHAR, null,
                               X_Transaction_Name),
    invoice_transaction_id
                      = decode(X_Invoice_Transaction_Id,
                               NULL, invoice_transaction_id,
                               FND_API.G_MISS_NUM, null,
                               X_Invoice_Transaction_Id),
    source_transaction_header_id
                      = decode(X_Source_Transaction_Header_Id,
                               NULL, source_transaction_header_id,
                               FND_API.G_MISS_NUM, null,
                               X_Source_Transaction_Header_Id),
    mass_reference_id = decode(X_Mass_Reference_Id,
                               NULL, mass_reference_id,
                               FND_API.G_MISS_NUM, null,
                               X_Mass_Reference_Id),
    last_update_login = decode(X_Last_Update_Login,
                               NULL, last_update_login,
                               FND_API.G_MISS_NUM, null,
                               X_Last_Update_Login),
    transaction_subtype
                      = decode(X_Transaction_Subtype,
                               NULL, transaction_subtype,
                               FND_API.G_MISS_CHAR, null,
                               X_Transaction_Subtype),
    attribute1        = decode(X_Attribute1,
                               NULL, attribute1,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute1),
    attribute2        = decode(X_Attribute2,
                               NULL, attribute2,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute2),
    attribute3        = decode(X_Attribute3,
                               NULL, attribute3,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute3),
    attribute4        = decode(X_Attribute4,
                               NULL, attribute4,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute4),
    attribute5        = decode(X_Attribute5,
                               NULL, attribute5,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute5),
    attribute6        = decode(X_Attribute6,
                               NULL, attribute6,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute6),
    attribute7        = decode(X_Attribute7,
                               NULL, attribute7,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute7),
    attribute8        = decode(X_Attribute8,
                               NULL, attribute8,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute8),
    attribute9        = decode(X_Attribute9,
                               NULL, attribute9,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute9),
    attribute10       = decode(X_Attribute10,
                               NULL, attribute10,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute10),
    attribute11       = decode(X_Attribute11,
                               NULL, attribute11,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute11),
    attribute12       = decode(X_Attribute12,
                               NULL, attribute12,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute12),
    attribute13       = decode(X_Attribute13,
                               NULL, attribute13,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute13),
    attribute14       = decode(X_Attribute14,
                               NULL, attribute14,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute14),
    attribute15       = decode(X_Attribute15,
                               NULL, attribute15,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute15),
    attribute_category_code
                      = decode(X_Attribute_Category_Code,
                               NULL, attribute_category_code,
                               FND_API.G_MISS_CHAR, null,
                               X_Attribute_Category_Code),
    transaction_key   = decode(X_Transaction_Key,
                               NULL, transaction_key,
                               FND_API.G_MISS_CHAR, null,
                               X_Transaction_Key),
    amortization_start_date
                      = decode(X_Amortization_Start_Date,
                               NULL, amortization_start_date,
                               X_Amortization_Start_Date),
    calling_interface = decode(X_Calling_Interface,
                               NULL, calling_interface,
                               FND_API.G_MISS_CHAR, null,
                               X_Calling_Interface),
    mass_transaction_id = decode(X_mass_transaction_id,
                               NULL, mass_transaction_id,
                               FND_API.G_MISS_NUM, null,
                               X_Mass_transaction_id),
    member_transaction_header_id = decode(X_Member_Transaction_Header_Id,
                               NULL, member_transaction_header_id,
                               FND_API.G_MISS_NUM, null,
                               X_Member_Transaction_Header_Id),
    trx_reference_id = decode(X_Trx_Reference_Id,
                               NULL, trx_reference_id,
                               FND_API.G_MISS_NUM, null,
                               X_Trx_Reference_Id),
    event_id = decode(X_event_id,
                              NULL, event_id,
                              FND_API.G_MISS_NUM, null,
                              X_event_id)
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  exception
    when others then
      FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_transaction_headers_pkg.update_row',
		CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Update_Row;

  -- syoung: added x_return_status.
  PROCEDURE Update_Trx_Type(X_Book_Type_Code		VARCHAR2,
			X_Asset_Id			NUMBER,
			X_Transaction_Type_Code		VARCHAR2,
			X_New_Transaction_Type		VARCHAR2,
			X_Return_Status		 OUT NOCOPY BOOLEAN,
		         X_Calling_Fn			VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
	Update fa_transaction_headers
	set transaction_type_code = X_New_Transaction_Type
	where asset_id = X_Asset_Id
	and book_type_code = X_Book_Type_Code
	and transaction_type_code = X_Transaction_Type_Code;
    X_Return_Status := TRUE;
  exception
    when others then
      FA_SRVR_MSG.Add_SQL_Error(
		CALLING_FN => 'FA_TRANSACTION_HEADERS_PKG.Update_Trx_Type', p_log_level_rec => p_log_level_rec);
--      FA_STANDARD_PKG.RAISE_ERROR(
--		CALLED_FN => 'fa_transaction_headers_pkg.update_trx_type',
--		CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
    X_Return_Status := FALSE;
  END Update_Trx_Type;
  --
  PROCEDURE Delete_Row(X_Rowid 			VARCHAR2 DEFAULT NULL,
			X_Transaction_Header_Id NUMBER DEFAULT NULL,
			X_Asset_Id		NUMBER DEFAULT NULL,
			X_Transaction_Type_Code VARCHAR2 DEFAULT NULL,
		         X_Calling_Fn			VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    if X_Rowid is not null then
    	DELETE FROM fa_transaction_headers
    	WHERE rowid = X_Rowid;
    elsif X_Transaction_Header_Id is not null then
	DELETE FROM fa_transaction_headers
    	WHERE transaction_header_id = X_Transaction_Header_Id;
    elsif X_Asset_Id is not null then
	DELETE FROM fa_transaction_headers
	WHERE asset_id = X_Asset_Id
	and transaction_type_code =
		nvl(X_Transaction_Type_Code, transaction_type_code);
    else
	-- error message if inadequate parameters sent
	null;
    end if;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  exception
    when others then
      FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_transaction_headers_pkg.delete_row',
		CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Delete_Row;


END FA_TRANSACTION_HEADERS_PKG;

/
