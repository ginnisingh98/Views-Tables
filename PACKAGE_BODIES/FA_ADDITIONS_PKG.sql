--------------------------------------------------------
--  DDL for Package Body FA_ADDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ADDITIONS_PKG" as
/* $Header: faxiadb.pls 120.6.12010000.2 2009/07/19 13:25:43 glchen ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Asset_Id                       IN OUT NOCOPY NUMBER,
                       X_Asset_Number                   IN OUT NOCOPY VARCHAR2,
                       X_Asset_Key_Ccid                 NUMBER DEFAULT NULL,
                       X_Current_Units                  NUMBER,
                       X_Asset_Type                     VARCHAR2,
                       X_Tag_Number                     VARCHAR2 DEFAULT NULL,
                       X_Description                    VARCHAR2,
                       X_Asset_Category_Id              NUMBER,
                       X_Parent_Asset_Id                NUMBER DEFAULT NULL,
                       X_Manufacturer_Name              VARCHAR2 DEFAULT NULL,
                       X_Serial_Number                  VARCHAR2 DEFAULT NULL,
                       X_Model_Number                   VARCHAR2 DEFAULT NULL,
                       X_Property_Type_Code             VARCHAR2 DEFAULT NULL,
                       X_Property_1245_1250_Code        VARCHAR2 DEFAULT NULL,
                       X_In_Use_Flag                    VARCHAR2,
                       X_Owned_Leased                   VARCHAR2,
                       X_New_Used                       VARCHAR2,
                       X_Unit_Adjustment_Flag           VARCHAR2,
                       X_Add_Cost_Je_Flag               VARCHAR2,
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
                       X_Attribute16                    VARCHAR2 DEFAULT NULL,
                       X_Attribute17                    VARCHAR2 DEFAULT NULL,
                       X_Attribute18                    VARCHAR2 DEFAULT NULL,
                       X_Attribute19                    VARCHAR2 DEFAULT NULL,
                       X_Attribute20                    VARCHAR2 DEFAULT NULL,
                       X_Attribute21                    VARCHAR2 DEFAULT NULL,
                       X_Attribute22                    VARCHAR2 DEFAULT NULL,
                       X_Attribute23                    VARCHAR2 DEFAULT NULL,
                       X_Attribute24                    VARCHAR2 DEFAULT NULL,
                       X_Attribute25                    VARCHAR2 DEFAULT NULL,
                       X_Attribute26                    VARCHAR2 DEFAULT NULL,
                       X_Attribute27                    VARCHAR2 DEFAULT NULL,
                       X_Attribute28                    VARCHAR2 DEFAULT NULL,
                       X_Attribute29                    VARCHAR2 DEFAULT NULL,
                       X_Attribute30                    VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category_Code        VARCHAR2,
                       X_gf_Attribute1                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute2                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute3                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute4                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute5                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute6                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute7                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute8                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute9                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute10                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute11                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute12                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute13                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute14                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute15                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute16                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute17                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute18                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute19                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute20                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute_Category_Code     VARCHAR2 DEFAULT NULL,
                       X_Context                        VARCHAR2 DEFAULT NULL,
                       X_Lease_Id                       NUMBER DEFAULT NULL,
                       X_Inventorial                    VARCHAR2,
		       X_Commitment			VARCHAR2 DEFAULT NULL,
		       X_Investment_Law			VARCHAR2 DEFAULT NULL,
                       X_Status                         VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Created_By                     NUMBER DEFAULT NULL,
                       X_Creation_Date                  DATE DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Calling_Fn                     VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

    h_error_message     varchar2(255);

    CURSOR C IS SELECT rowid FROM fa_additions_B
                 WHERE asset_id = X_Asset_Id;
    CURSOR C2 IS SELECT fa_additions_s.nextval FROM sys.dual;

    l_attribute15   varchar2(150);

   BEGIN

      if (X_Asset_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Asset_Id;
        CLOSE C2;
      end if;

      X_asset_number := nvl(X_asset_number, to_char(X_asset_id));

       if (fa_cache_pkg.fa_crl_enabled) then
          l_attribute15 := X_Status;
       else
          l_attribute15 := X_attribute15;
       end if;

       INSERT INTO fa_additions_B(
              asset_id,
              asset_number,
              asset_key_ccid,
              current_units,
              asset_type,
              tag_number,
              /* description, */
              asset_category_id,
              parent_asset_id,
              manufacturer_name,
              serial_number,
              model_number,
              property_type_code,
              property_1245_1250_code,
              in_use_flag,
              owned_leased,
              new_used,
              unit_adjustment_flag,
              add_cost_je_flag,
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
              attribute16,
              attribute17,
              attribute18,
              attribute19,
              attribute20,
              attribute21,
              attribute22,
              attribute23,
              attribute24,
              attribute25,
              attribute26,
              attribute27,
              attribute28,
              attribute29,
              attribute30,
              attribute_category_code,
              global_attribute1,
              global_attribute2,
              global_attribute3,
              global_attribute4,
              global_attribute5,
              global_attribute6,
              global_attribute7,
              global_attribute8,
              global_attribute9,
              global_attribute10,
              global_attribute11,
              global_attribute12,
              global_attribute13,
              global_attribute14,
              global_attribute15,
              global_attribute16,
              global_attribute17,
              global_attribute18,
              global_attribute19,
              global_attribute20,
              global_attribute_category,
              context,
              lease_id,
              inventorial,
              commitment,
	      investment_law,
              last_update_date,
              last_updated_by,
              created_by,
              creation_date,
              last_update_login
             ) VALUES (
              X_Asset_Id,
              X_Asset_Number,
              X_Asset_Key_Ccid,
              X_Current_Units,
              X_Asset_Type,
              X_Tag_Number,
              /* X_Description, */
              X_Asset_Category_Id,
              X_Parent_Asset_Id,
              X_Manufacturer_Name,
              X_Serial_Number,
              X_Model_Number,
              X_Property_Type_Code,
              X_Property_1245_1250_Code,
              X_In_Use_Flag,
              X_Owned_Leased,
              X_New_Used,
              X_Unit_Adjustment_Flag,
              X_Add_Cost_Je_Flag,
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
              l_Attribute15,
              X_Attribute16,
              X_Attribute17,
              X_Attribute18,
              X_Attribute19,
              X_Attribute20,
              X_Attribute21,
              X_Attribute22,
              X_Attribute23,
              X_Attribute24,
              X_Attribute25,
              X_Attribute26,
              X_Attribute27,
              X_Attribute28,
              X_Attribute29,
              X_Attribute30,
              X_Attribute_Category_Code,
              X_gf_Attribute1,
              X_gf_Attribute2,
              X_gf_Attribute3,
              X_gf_Attribute4,
              X_gf_Attribute5,
              X_gf_Attribute6,
              X_gf_Attribute7,
              X_gf_Attribute8,
              X_gf_Attribute9,
              X_gf_Attribute10,
              X_gf_Attribute11,
              X_gf_Attribute12,
              X_gf_Attribute13,
              X_gf_Attribute14,
              X_gf_Attribute15,
              X_gf_Attribute16,
              X_gf_Attribute17,
              X_gf_Attribute18,
              X_gf_Attribute19,
              X_gf_Attribute20,
              X_gf_Attribute_Category_Code,
              X_Context,
              X_Lease_Id,
              X_Inventorial,
	      X_Commitment,
	      X_Investment_law,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Created_By,
              X_Creation_Date,
              X_Last_Update_Login
             );
  insert into FA_ADDITIONS_TL (
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    ASSET_ID,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATED_BY,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    X_ASSET_ID,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
      from FA_ADDITIONS_TL T
     where T.ASSET_ID = X_ASSET_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);


/* REMOVING FOR SECURITY BY BOOK
    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
*/

  exception
    when dup_val_on_index then
      h_error_message := SQLERRM;

      if instr (h_error_message, 'FA_ADDITIONS_B_U2') <> 0 then
         FA_SRVR_MSG.add_message(
              CALLING_FN => 'fa_additions_pkg.insert_row',
              NAME       => 'FA_ADD_ASSET_NUMBER_EXISTS',
              TOKEN1     => 'ASSET_NUMBER',
              VALUE1     => X_Asset_Number, p_log_level_rec => p_log_level_rec);
         FA_SRVR_MSG.ADD_SQL_ERROR (
              CALLING_FN => 'fa_additions_pkg.insert_row', p_log_level_rec => p_log_level_rec);
         raise;

      elsif instr (h_error_message, 'FA_ADDITIONS_B_U3') <> 0 then
         FA_SRVR_MSG.add_message(
              CALLING_FN => 'fa_additions_pkg.insert_row',
              NAME       => 'FA_ADD_TAG_NUMBER_EXISTS',
              TOKEN1     => 'TAG_NUMBER',
              VALUE1     => X_Tag_Number, p_log_level_rec => p_log_level_rec);
         FA_SRVR_MSG.ADD_SQL_ERROR (
              CALLING_FN => 'fa_additions_pkg.insert_row', p_log_level_rec => p_log_level_rec);
         raise;

      else
         FA_SRVR_MSG.ADD_SQL_ERROR (
              CALLING_FN => 'fa_additions_pkg.insert_row', p_log_level_rec => p_log_level_rec);
         raise;

      end if;

    when others then
      FA_SRVR_MSG.ADD_SQL_ERROR (
           CALLING_FN => 'fa_additions_pkg.insert_row',  p_log_level_rec => p_log_level_rec);
      raise;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Asset_Id                         NUMBER,
                     X_Asset_Number                     VARCHAR2,
                     X_Asset_Key_Ccid                   NUMBER DEFAULT NULL,
                     X_Current_Units                    NUMBER,
                     X_Asset_Type                       VARCHAR2,
                     X_Tag_Number                       VARCHAR2 DEFAULT NULL,
                     X_Description                      VARCHAR2,
                     X_Asset_Category_Id                NUMBER,
                     X_Parent_Asset_Id                  NUMBER DEFAULT NULL,
                     X_Manufacturer_Name                VARCHAR2 DEFAULT NULL,
                     X_Serial_Number                    VARCHAR2 DEFAULT NULL,
                     X_Model_Number                     VARCHAR2 DEFAULT NULL,
                     X_Property_Type_Code               VARCHAR2 DEFAULT NULL,
                     X_Property_1245_1250_Code          VARCHAR2 DEFAULT NULL,
                     X_In_Use_Flag                      VARCHAR2,
                     X_Owned_Leased                     VARCHAR2,
                     X_New_Used                         VARCHAR2,
                     X_Unit_Adjustment_Flag             VARCHAR2,
                     X_Add_Cost_Je_Flag                 VARCHAR2,
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
                     X_Attribute16                      VARCHAR2 DEFAULT NULL,
                     X_Attribute17                      VARCHAR2 DEFAULT NULL,
                     X_Attribute18                      VARCHAR2 DEFAULT NULL,
                     X_Attribute19                      VARCHAR2 DEFAULT NULL,
                     X_Attribute20                      VARCHAR2 DEFAULT NULL,
                     X_Attribute21                      VARCHAR2 DEFAULT NULL,
                     X_Attribute22                      VARCHAR2 DEFAULT NULL,
                     X_Attribute23                      VARCHAR2 DEFAULT NULL,
                     X_Attribute24                      VARCHAR2 DEFAULT NULL,
                     X_Attribute25                      VARCHAR2 DEFAULT NULL,
                     X_Attribute26                      VARCHAR2 DEFAULT NULL,
                     X_Attribute27                      VARCHAR2 DEFAULT NULL,
                     X_Attribute28                      VARCHAR2 DEFAULT NULL,
                     X_Attribute29                      VARCHAR2 DEFAULT NULL,
                     X_Attribute30                      VARCHAR2 DEFAULT NULL,
                     X_Attribute_Category_Code          VARCHAR2,
                     X_Context                          VARCHAR2 DEFAULT NULL,
                     X_Lease_Id                         NUMBER DEFAULT NULL,
                     X_Inventorial                      VARCHAR2,
		     X_Commitment			VARCHAR2 DEFAULT NULL,
		     X_Investment_Law			VARCHAR2 DEFAULT NULL,
                     X_Calling_Fn                       VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS
        SELECT *
        FROM   fa_additions_b
        WHERE  rowid = X_Rowid
        FOR UPDATE of Asset_Id NOWAIT;
    Recinfo C%ROWTYPE;

    cursor c1 is
        select description,decode(language,userenv('LANG'),'Y','N') BASELANG
        from fa_additions_tl
        where asset_id = x_asset_id
        and userenv('LANG') in (LANGUAGE,SOURCE_LANG)
        for update of asset_id nowait;

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
               (Recinfo.asset_id =  X_Asset_Id)
           AND (Recinfo.asset_number =  X_Asset_Number)
           AND (   (Recinfo.asset_key_ccid =  X_Asset_Key_Ccid)
                OR (    (Recinfo.asset_key_ccid IS NULL)
                    AND (X_Asset_Key_Ccid IS NULL)))
           AND (Recinfo.current_units =  X_Current_Units)
           AND (Recinfo.asset_type =  X_Asset_Type)
           AND (   (Recinfo.tag_number =  X_Tag_Number)
                OR (    (Recinfo.tag_number IS NULL)
                    AND (X_Tag_Number IS NULL)))
           /* AND (Recinfo.description =  X_Description) */
           AND (Recinfo.asset_category_id =  X_Asset_Category_Id)
           AND (   (Recinfo.parent_asset_id =  X_Parent_Asset_Id)
                OR (    (Recinfo.parent_asset_id IS NULL)
                    AND (X_Parent_Asset_Id IS NULL)))
           AND (   (Recinfo.manufacturer_name =  X_Manufacturer_Name)
                OR (    (Recinfo.manufacturer_name IS NULL)
                    AND (X_Manufacturer_Name IS NULL)))
           AND (   (Recinfo.serial_number =  X_Serial_Number)
                OR (    (Recinfo.serial_number IS NULL)
                    AND (X_Serial_Number IS NULL)))
           AND (   (Recinfo.model_number =  X_Model_Number)
                OR (    (Recinfo.model_number IS NULL)
                    AND (X_Model_Number IS NULL)))
           AND (   (Recinfo.property_type_code =  X_Property_Type_Code)
                OR (    (Recinfo.property_type_code IS NULL)
                    AND (X_Property_Type_Code IS NULL)))
           AND (   (Recinfo.property_1245_1250_code =  X_Property_1245_1250_Code
)
                OR (    (Recinfo.property_1245_1250_code IS NULL)
                    AND (X_Property_1245_1250_Code IS NULL)))
           AND (Recinfo.in_use_flag =  X_In_Use_Flag)
           AND (Recinfo.owned_leased =  X_Owned_Leased)
           AND (Recinfo.new_used =  X_New_Used)
           AND (   (Recinfo.commitment =  X_Commitment)
                OR (    (Recinfo.commitment IS NULL)
                    AND (X_Commitment IS NULL)))
           AND (   (Recinfo.investment_law =  X_Investment_law)
                OR (    (Recinfo.investment_law IS NULL)
                    AND (X_Investment_Law IS NULL)))
           AND (Recinfo.unit_adjustment_flag =  X_Unit_Adjustment_Flag)
           AND (Recinfo.add_cost_je_flag =  X_Add_Cost_Je_Flag)
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
           AND (   (Recinfo.attribute16 =  X_Attribute16)
                OR (    (Recinfo.attribute16 IS NULL)
                    AND (X_Attribute16 IS NULL)))
           AND (   (Recinfo.attribute17 =  X_Attribute17)
                OR (    (Recinfo.attribute17 IS NULL)
                    AND (X_Attribute17 IS NULL)))
           AND (   (Recinfo.attribute18 =  X_Attribute18)
                OR (    (Recinfo.attribute18 IS NULL)
                    AND (X_Attribute18 IS NULL)))
           AND (   (Recinfo.attribute19 =  X_Attribute19)
                OR (    (Recinfo.attribute19 IS NULL)
                    AND (X_Attribute19 IS NULL)))
           AND (   (Recinfo.attribute20 =  X_Attribute20)
                OR (    (Recinfo.attribute20 IS NULL)
                    AND (X_Attribute20 IS NULL)))
           AND (   (Recinfo.attribute21 =  X_Attribute21)
                OR (    (Recinfo.attribute21 IS NULL)
                    AND (X_Attribute21 IS NULL)))
           AND (   (Recinfo.attribute22 =  X_Attribute22)
                OR (    (Recinfo.attribute22 IS NULL)
                    AND (X_Attribute22 IS NULL)))
           AND (   (Recinfo.attribute23 =  X_Attribute23)
                OR (    (Recinfo.attribute23 IS NULL)
                    AND (X_Attribute23 IS NULL)))
           AND (   (Recinfo.attribute24 =  X_Attribute24)
                OR (    (Recinfo.attribute24 IS NULL)
                    AND (X_Attribute24 IS NULL)))
           AND (   (Recinfo.attribute25 =  X_Attribute25)
                OR (    (Recinfo.attribute25 IS NULL)
                    AND (X_Attribute25 IS NULL)))
           AND (   (Recinfo.attribute26 =  X_Attribute26)
                OR (    (Recinfo.attribute26 IS NULL)
                    AND (X_Attribute26 IS NULL)))
           AND (   (Recinfo.attribute27 =  X_Attribute27)
                OR (    (Recinfo.attribute27 IS NULL)
                    AND (X_Attribute27 IS NULL)))
           AND (   (Recinfo.attribute28 =  X_Attribute28)
                OR (    (Recinfo.attribute28 IS NULL)
                    AND (X_Attribute28 IS NULL)))
           AND (   (Recinfo.attribute29 =  X_Attribute29)
                OR (    (Recinfo.attribute29 IS NULL)
                    AND (X_Attribute29 IS NULL)))
           AND (   (Recinfo.attribute30 =  X_Attribute30)
                OR (    (Recinfo.attribute30 IS NULL)
                    AND (X_Attribute30 IS NULL)))
           AND (Recinfo.attribute_category_code =  X_Attribute_Category_Code)
           AND (   (Recinfo.context =  X_Context)
                OR (    (Recinfo.context IS NULL)
                    AND (X_Context IS NULL)))
           AND (   (Recinfo.lease_id =  X_Lease_Id)
                OR (    (Recinfo.lease_id IS NULL)
                    AND (X_Lease_Id IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (tlinfo.DESCRIPTION = X_DESCRIPTION) then
        return;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;

  END Lock_Row;



  -- syoung: added x_return_status.
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2 DEFAULT NULL,
                       X_Asset_Id                       NUMBER   DEFAULT NULL,
                       X_Asset_Number                   VARCHAR2 DEFAULT NULL,
                       X_Asset_Key_Ccid                 NUMBER   DEFAULT NULL,
                       X_Current_Units                  NUMBER   DEFAULT NULL,
                       X_Asset_Type                     VARCHAR2 DEFAULT NULL,
                       X_Tag_Number                     VARCHAR2 DEFAULT NULL,
                       X_Description                    VARCHAR2 DEFAULT NULL,
                       X_Asset_Category_Id              NUMBER   DEFAULT NULL,
                       X_Parent_Asset_Id                NUMBER   DEFAULT NULL,
                       X_Manufacturer_Name              VARCHAR2 DEFAULT NULL,
                       X_Serial_Number                  VARCHAR2 DEFAULT NULL,
                       X_Model_Number                   VARCHAR2 DEFAULT NULL,
                       X_Property_Type_Code             VARCHAR2 DEFAULT NULL,
                       X_Property_1245_1250_Code        VARCHAR2 DEFAULT NULL,
                       X_In_Use_Flag                    VARCHAR2 DEFAULT NULL,
                       X_Owned_Leased                   VARCHAR2 DEFAULT NULL,
                       X_New_Used                       VARCHAR2 DEFAULT NULL,
                       X_Unit_Adjustment_Flag           VARCHAR2 DEFAULT NULL,
                       X_Add_Cost_Je_Flag               VARCHAR2 DEFAULT NULL,
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
                       X_Attribute16                    VARCHAR2 DEFAULT NULL,
                       X_Attribute17                    VARCHAR2 DEFAULT NULL,
                       X_Attribute18                    VARCHAR2 DEFAULT NULL,
                       X_Attribute19                    VARCHAR2 DEFAULT NULL,
                       X_Attribute20                    VARCHAR2 DEFAULT NULL,
                       X_Attribute21                    VARCHAR2 DEFAULT NULL,
                       X_Attribute22                    VARCHAR2 DEFAULT NULL,
                       X_Attribute23                    VARCHAR2 DEFAULT NULL,
                       X_Attribute24                    VARCHAR2 DEFAULT NULL,
                       X_Attribute25                    VARCHAR2 DEFAULT NULL,
                       X_Attribute26                    VARCHAR2 DEFAULT NULL,
                       X_Attribute27                    VARCHAR2 DEFAULT NULL,
                       X_Attribute28                    VARCHAR2 DEFAULT NULL,
                       X_Attribute29                    VARCHAR2 DEFAULT NULL,
                       X_Attribute30                    VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category_Code        VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute1                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute2                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute3                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute4                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute5                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute6                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute7                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute8                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute9                  VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute10                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute11                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute12                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute13                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute14                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute15                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute16                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute17                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute18                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute19                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute20                 VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute_Category_Code     VARCHAR2 DEFAULT NULL,
                       X_Context                        VARCHAR2 DEFAULT NULL,
                       X_Lease_Id                       NUMBER   DEFAULT NULL,
                       X_Inventorial                    VARCHAR2 DEFAULT NULL,
		       X_Commitment			VARCHAR2 DEFAULT NULL,
		       X_Investment_Law			VARCHAR2 DEFAULT NULL,
                       X_Status                         VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Date               DATE     DEFAULT NULL,
                       X_Last_Updated_By                NUMBER   DEFAULT NULL,
                       X_Last_Update_Login              NUMBER   DEFAULT NULL,
                       X_Return_Status              OUT NOCOPY BOOLEAN,
                       X_Calling_Fn                     VARCHAR2

  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

    l_asset_id   number;
    l_rowid      rowid;
    l_temp_attribute15  varchar2(150);

  BEGIN
     if (X_Rowid is NULL) then
        select rowid
        into   l_rowid
        from   fa_additions_b
        where  asset_id = X_Asset_Id;
     else
        l_rowid := X_Rowid;
     end if;

     if (fa_cache_pkg.fa_crl_enabled) then
        l_temp_attribute15 := X_Status;
     else
        l_temp_attribute15 := X_attribute15;
     end if;

     UPDATE fa_additions_b
     SET
     asset_id                        =     decode(X_Asset_Id,
                                                  NULL, asset_id,
                                                  FND_API.G_MISS_NUM, NULL,
                                                  X_Asset_Id),
     asset_number                    =     decode(X_Asset_Number,
                                                  NULL, asset_number,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Asset_Number),
     asset_key_ccid                  =     decode(X_Asset_Key_Ccid,
                                                  NULL, asset_key_ccid,
                                                  FND_API.G_MISS_NUM, NULL,
                                                  X_Asset_Key_Ccid),
     current_units                   =     decode(X_Current_Units,
                                                  NULL, current_units,
                                                  FND_API.G_MISS_NUM, NULL,
                                                  X_Current_Units),
     asset_type                      =     decode(X_Asset_Type,
                                                  NULL, asset_type,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Asset_Type),
     tag_number                      =     decode(X_Tag_Number,
                                                  NULL, tag_number,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Tag_Number),
     asset_category_id               =     decode(X_Asset_Category_Id,
                                                  NULL, asset_category_id,
                                                  FND_API.G_MISS_NUM, NULL,
                                                  X_Asset_Category_Id),
     parent_asset_id                 =     decode(X_Parent_Asset_Id,
                                                  NULL, parent_asset_id,
                                                  FND_API.G_MISS_NUM, NULL,
                                                  X_Parent_Asset_Id),
     manufacturer_name               =     decode(X_Manufacturer_Name,
                                                  NULL, manufacturer_name,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Manufacturer_Name),
     serial_number                   =     decode(X_Serial_Number,
                                                  NULL, serial_number,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Serial_Number),
     model_number                    =     decode(X_Model_Number,
                                                  NULL, model_number,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Model_Number),
     property_type_code              =     decode(X_Property_Type_Code,
                                                  NULL, property_type_code,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Property_Type_Code),
     property_1245_1250_code         =     decode(X_Property_1245_1250_Code,
                                                  NULL, property_1245_1250_code,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Property_1245_1250_Code),
     in_use_flag                     =     decode(X_In_Use_Flag,
                                                  NULL, in_use_flag,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_In_Use_Flag),
     owned_leased                    =     decode(X_Owned_Leased,
                                                  NULL, owned_leased,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Owned_Leased),
     new_used                        =     decode(X_New_Used,
                                                  NULL, new_used,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_New_Used),
     unit_adjustment_flag            =     decode(X_Unit_Adjustment_Flag,
                                                  NULL, unit_adjustment_flag,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Unit_Adjustment_Flag),
     add_cost_je_flag                =     decode(X_Add_Cost_Je_Flag,
                                                  NULL, add_cost_je_flag,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Add_Cost_Je_Flag),
     attribute1                      =     decode(X_Attribute1,
                                                  NULL, attribute1,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute1),
     attribute2                      =     decode(X_Attribute2,
                                                  NULL, attribute2,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute2),
     attribute3                      =     decode(X_Attribute3,
                                                  NULL, attribute3,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute3),
     attribute4                      =     decode(X_Attribute4,
                                                  NULL, attribute4,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute4),
     attribute5                      =     decode(X_Attribute5,
                                                  NULL, attribute5,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute5),
     attribute6                      =     decode(X_Attribute6,
                                                  NULL, attribute6,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute6),
     attribute7                      =     decode(X_Attribute7,
                                                  NULL, attribute7,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute7),
     attribute8                      =     decode(X_Attribute8,
                                                  NULL, attribute8,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute8),
     attribute9                      =     decode(X_Attribute9,
                                                  NULL, attribute9,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute9),
     attribute10                     =     decode(X_Attribute10,
                                                  NULL, attribute10,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute10),
     attribute11                     =     decode(X_Attribute11,
                                                  NULL, attribute11,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute11),
     attribute12                     =     decode(X_Attribute12,
                                                  NULL, attribute12,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute12),
     attribute13                     =     decode(X_Attribute13,
                                                  NULL, attribute13,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute13),
     attribute14                     =     decode(X_Attribute14,
                                                  NULL, attribute14,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute14),
     attribute15                     =     decode(l_temp_attribute15,
                                                  NULL, attribute15,
                                                  FND_API.G_MISS_CHAR,
                                                  NULL,
                                                  l_temp_attribute15),
     attribute16                     =     decode(X_Attribute16,
                                                  NULL, attribute16,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute16),
     attribute17                     =     decode(X_Attribute17,
                                                  NULL, attribute17,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute17),
     attribute18                     =     decode(X_Attribute18,
                                                  NULL, attribute18,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute18),
     attribute19                     =     decode(X_Attribute19,
                                                  NULL, attribute19,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute19),
     attribute20                     =     decode(X_Attribute20,
                                                  NULL, attribute20,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute20),
     attribute21                     =     decode(X_Attribute21,
                                                  NULL, attribute21,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute21),
     attribute22                     =     decode(X_Attribute22,
                                                  NULL, attribute22,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute22),
     attribute23                     =     decode(X_Attribute23,
                                                  NULL, attribute23,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute23),
     attribute24                     =     decode(X_Attribute24,
                                                  NULL, attribute24,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute24),
     attribute25                     =     decode(X_Attribute25,
                                                  NULL, attribute25,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute25),
     attribute26                     =     decode(X_Attribute26,
                                                  NULL, attribute26,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute26),
     attribute27                     =     decode(X_Attribute27,
                                                  NULL, attribute27,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute27),
     attribute28                     =     decode(X_Attribute28,
                                                  NULL, attribute28,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute28),
     attribute29                     =     decode(X_Attribute29,
                                                  NULL, attribute29,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute29),
     attribute30                     =     decode(X_Attribute30,
                                                  NULL, attribute30,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute30),
     attribute_category_code         =     decode(X_Attribute_Category_Code,
                                                  NULL, attribute_category_code,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Attribute_Category_Code),
     global_attribute1               =     decode(X_gf_Attribute1,
                                                  NULL, global_attribute1,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute1),
     global_attribute2               =     decode(X_gf_Attribute2,
                                                  NULL, global_attribute2,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute2),
     global_attribute3               =     decode(X_gf_Attribute3,
                                                  NULL, global_attribute3,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute3),
     global_attribute4               =     decode(X_gf_Attribute4,
                                                  NULL, global_attribute4,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute4),
     global_attribute5               =     decode(X_gf_Attribute5,
                                                  NULL, global_attribute5,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute5),
     global_attribute6               =     decode(X_gf_Attribute6,
                                                  NULL, global_attribute6,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute6),
     global_attribute7               =     decode(X_gf_Attribute7,
                                                  NULL, global_attribute7,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute7),
     global_attribute8               =     decode(X_gf_Attribute8,
                                                  NULL, global_attribute8,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute8),
     global_attribute9               =     decode(X_gf_Attribute9,
                                                  NULL, global_attribute9,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute9),
     global_attribute10              =     decode(X_gf_Attribute10,
                                                  NULL, global_attribute10,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute10),
     global_attribute11              =     decode(X_gf_Attribute11,
                                                  NULL, global_attribute11,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute11),
     global_attribute12              =     decode(X_gf_Attribute12,
                                                  NULL, global_attribute12,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute12),
     global_attribute13              =     decode(X_gf_Attribute13,
                                                  NULL, global_attribute13,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute13),
     global_attribute14              =     decode(X_gf_Attribute14,
                                                  NULL, global_attribute14,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute14),
     global_attribute15              =     decode(X_gf_Attribute15,
                                                  NULL, global_attribute15,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute15),
     global_attribute16              =     decode(X_gf_Attribute16,
                                                  NULL, global_attribute16,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute16),
     global_attribute17              =     decode(X_gf_Attribute17,
                                                  NULL, global_attribute17,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute17),
     global_attribute18              =     decode(X_gf_Attribute18,
                                                  NULL, global_attribute18,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute18),
     global_attribute19              =     decode(X_gf_Attribute19,
                                                  NULL, global_attribute19,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute19),
     global_attribute20              =     decode(X_gf_Attribute20,
                                                  NULL, global_attribute20,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute20),
     global_attribute_category       =     decode(X_gf_Attribute_category_code,
                                                  NULL,
                                                     global_attribute_category,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_gf_Attribute_category_code),
     context                         =     decode(X_Context,
                                                  NULL, context,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Context),
     lease_id                        =     decode(X_Lease_Id,
                                                  NULL, lease_id,
                                                  FND_API.G_MISS_NUM, NULL,
                                                  X_Lease_Id),
     inventorial                     =     decode(X_Inventorial,
                                                  NULL, inventorial,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_Inventorial),
     commitment                      =     decode(X_Commitment,
                                                  NULL, commitment,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_commitment),
     investment_law                  =     decode(X_investment_law,
                                                  NULL, investment_law,
                                                  FND_API.G_MISS_CHAR, NULL,
                                                  X_investment_law),
     last_update_date                =     decode(X_Last_Update_Date,
                                                  NULL, last_update_date,
                                                  X_Last_Update_Date),
     last_updated_by                 =     decode(X_Last_Updated_By,
                                                  NULL, last_updated_by,
                                                  FND_API.G_MISS_NUM, NULL,
                                                  X_Last_Updated_By),
     last_update_login               =     decode(X_Last_Update_Login,
                                                  NULL, last_update_login,
                                                  FND_API.G_MISS_NUM, NULL,
                                                  X_Last_Update_Login)
     WHERE rowid = l_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    if (X_asset_id is NULL) then
       select asset_id
         into l_asset_id
         from fa_additions
        where rowid = X_rowid;
    else
       l_asset_id := X_asset_id;
    end if;

    update FA_ADDITIONS_TL set
               DESCRIPTION       = decode(X_DESCRIPTION,
                                          NULL, description,
                                          FND_API.G_MISS_CHAR, NULL,
                                          X_description),
               LAST_UPDATE_DATE  = decode(X_LAST_UPDATE_DATE,
                                          NULL, last_update_date,
                                          X_LAST_UPDATE_DATE),
               LAST_UPDATED_BY   = decode(X_LAST_UPDATED_BY,
                                          NULL, last_updated_by,
                                          FND_API.G_MISS_NUM, NULL,
                                          X_LAST_UPDATED_BY),
               LAST_UPDATE_LOGIN = decode(X_LAST_UPDATE_LOGIN,
                                          NULL, last_update_login,
                                          FND_API.G_MISS_NUM, NULL,
                                          X_LAST_UPDATE_LOGIN),
               SOURCE_LANG       = userenv('LANG')
    where ASSET_ID = L_ASSET_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    if (SQL%NOTFOUND) then
        raise no_data_found;
    end if;

    X_Return_Status := TRUE;

  exception
    when others then
      FA_SRVR_MSG.Add_SQL_Error(
          CALLING_FN => 'FA_ADDITIONS_PKG.Update_Row', p_log_level_rec => p_log_level_rec);
      X_Return_Status := FALSE;
      raise;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                 X_Asset_Id     number,
                 X_calling_Fn               VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

--    CURSOR C IS SELECT asset_id FROM fa_additions_B
--                 WHERE rowid = X_Rowid;
    h_asset_id    number(15);
  BEGIN

--   OPEN C;
--    FETCH C INTO h_asset_id;
--    CLOSE C;

    delete from FA_ADDITIONS_TL
    where ASSET_ID = X_asset_id;

    if (sql%notfound) then
      raise no_data_found;
    end if;

    DELETE FROM fa_additions_b
    WHERE asset_id = X_asset_id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  exception
    when others then
      FA_SRVR_MSG.ADD_SQL_ERROR (
          CALLING_FN => 'fa_additions_pkg.delete_row', p_log_level_rec => p_log_level_rec);
      raise;

  END Delete_Row;



  PROCEDURE Update_Units(X_Asset_Id     NUMBER,
                   X_Calling_Fn               VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
     UPDATE fa_additions_b
     SET current_units = (select units from fa_asset_history
               where asset_id = X_Asset_Id
               and date_ineffective is null)
     WHERE asset_id = X_Asset_Id;
     if (SQL%NOTFOUND) then
                Raise NO_DATA_FOUND;
         end if;

  exception
    when others then
      FA_SRVR_MSG.ADD_SQL_ERROR (
           CALLING_FN => 'fa_additions_pkg.update_units', p_log_level_rec => p_log_level_rec);
      raise;

  END Update_Units;

-- new procedure for mls (multi-lingual support)
-- following procedures either add new rows or
-- repair old rows in fa_addtions_tl table
-- which stores translation info.

  PROCEDURE ADD_LANGUAGE is

  BEGIN

  -- delete from tl table if same asset doesn't exist in base table
       delete from FA_ADDITIONS_TL T
       where not exists
         (select NULL
          from   FA_ADDITIONS_B B
          where  B.ASSET_ID = T.ASSET_ID
         );

  --  repair description in tl table
           update FA_ADDITIONS_TL T
              set (DESCRIPTION) =
                  (select B.DESCRIPTION
                     from FA_ADDITIONS_TL B
                    where B.ASSET_ID = T.ASSET_ID
                      and B.LANGUAGE = T.SOURCE_LANG)
            where (T.ASSET_ID, T.LANGUAGE) in
                  (select SUBT.ASSET_ID,
                          SUBT.LANGUAGE
                     from FA_ADDITIONS_TL SUBB, FA_ADDITIONS_TL SUBT
                    where SUBB.ASSET_ID = SUBT.ASSET_ID
                      and SUBB.LANGUAGE = SUBT.SOURCE_LANG
                      and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION));

-- insert new row into fa_additions_tl for new language

       insert into FA_ADDITIONS_TL (
                   LAST_UPDATED_BY,
                   CREATED_BY,
                   CREATION_DATE,
                   LAST_UPDATE_LOGIN,
                   ASSET_ID,
                   DESCRIPTION,
                   LAST_UPDATE_DATE,
                   LANGUAGE,
                   SOURCE_LANG)
           select
                   B.LAST_UPDATED_BY,
                   B.CREATED_BY,
                   B.CREATION_DATE,
                   B.LAST_UPDATE_LOGIN,
                   B.ASSET_ID,
                   B.DESCRIPTION,
                   B.LAST_UPDATE_DATE,
                   L.LANGUAGE_CODE,
                   B.SOURCE_LANG
            from FA_ADDITIONS_TL B, FND_LANGUAGES L
            where L.INSTALLED_FLAG in ('I', 'B')
            and B.LANGUAGE = userenv('LANG')
            and not exists
                   (select NULL
                    from FA_ADDITIONS_TL T
                    where T.ASSET_ID = B.ASSET_ID
                    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE LOAD_ROW(
                       X_Asset_Id                       IN NUMBER,
                       X_Asset_Number                   IN VARCHAR2,
                       X_Asset_Key_Ccid                 IN NUMBER DEFAULT NULL,
                       X_Current_Units                  IN NUMBER,
                       X_Asset_Type                     IN VARCHAR2,
                       X_Tag_Number                     IN VARCHAR2 DEFAULT NULL,
                       X_Description                    IN VARCHAR2,
                       X_Asset_Category_Id              IN NUMBER,
                       X_Parent_Asset_Id                IN NUMBER DEFAULT NULL,
                       X_Manufacturer_Name              IN VARCHAR2 DEFAULT NULL,
                       X_Serial_Number                  IN VARCHAR2 DEFAULT NULL,
                       X_Model_Number                   IN VARCHAR2 DEFAULT NULL,
                       X_Property_Type_Code             IN VARCHAR2 DEFAULT NULL,
                       X_Property_1245_1250_Code        IN VARCHAR2 DEFAULT NULL,
                       X_In_Use_Flag                    IN VARCHAR2,
                       X_Owned_Leased                   IN VARCHAR2,
                       X_New_Used                       IN VARCHAR2,
                       X_Unit_Adjustment_Flag           IN VARCHAR2,
                       X_Add_Cost_Je_Flag               IN VARCHAR2,
                       X_Attribute1                     IN VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     IN VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     IN VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     IN VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     IN VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     IN VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     IN VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     IN VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     IN VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute16                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute17                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute18                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute19                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute20                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute21                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute22                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute23                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute24                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute25                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute26                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute27                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute28                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute29                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute30                    IN VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category_Code        IN VARCHAR2,
                       X_Context                        IN VARCHAR2 DEFAULT NULL,
                       X_Lease_Id                       IN NUMBER DEFAULT NULL,
                       X_Inventorial                    IN VARCHAR2,
                       X_Commitment                     IN VARCHAR2 DEFAULT NULL,
                       X_Investment_Law                 IN VARCHAR2 DEFAULT NULL,
                       X_Status                         IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute1                  IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute2                  IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute3                  IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute4                  IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute5                  IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute6                  IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute7                  IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute8                  IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute9                  IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute10                 IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute11                 IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute12                 IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute13                 IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute14                 IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute15                 IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute16                 IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute17                 IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute18                 IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute19                 IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute20                 IN VARCHAR2 DEFAULT NULL,
                       X_gf_Attribute_Category          IN VARCHAR2 DEFAULT NULL
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

     h_asset_id     number;
     h_asset_number     varchar2(15);
     h_record_exists     number(15);

     user_id          number;
     row_id          varchar2(64);
     return_status     boolean;

   begin

     h_asset_id := X_Asset_Id;
     h_asset_number := X_Asset_Number;

     -- No SEED data.  All custom.
     user_id := 0;

     select count(*)
     into   h_record_exists
     from   fa_additions_b
     where  asset_id = X_Asset_Id;

     if (h_record_exists > 0) then

        fa_additions_pkg.Update_Row(
          X_Asset_Id                   => h_asset_id,
          X_Asset_Number               => h_asset_number,
          X_Asset_Key_Ccid             => X_Asset_Key_Ccid,
          X_Current_Units              => X_Current_Units,
          X_Asset_Type                 => X_Asset_Type,
          X_Tag_Number                 => X_Tag_Number,
          X_Description                => X_Description,
          X_Asset_Category_Id          => X_Asset_Category_Id,
          X_Parent_Asset_Id            => X_Parent_Asset_Id,
          X_Manufacturer_Name          => X_Manufacturer_Name,
          X_Serial_Number              => X_Serial_Number,
          X_Model_Number               => X_Model_Number,
          X_Property_Type_Code         => X_Property_Type_Code,
          X_Property_1245_1250_Code    => X_Property_1245_1250_Code,
          X_In_Use_Flag                => X_In_Use_Flag,
          X_Owned_Leased               => X_Owned_Leased,
          X_New_Used                   => X_New_Used,
          X_Unit_Adjustment_Flag       => X_Unit_Adjustment_Flag,
          X_Add_Cost_Je_Flag           => X_Add_Cost_Je_Flag,
          X_Attribute1                 => X_Attribute1,
          X_Attribute2                 => X_Attribute2,
          X_Attribute3                 => X_Attribute3,
          X_Attribute4                 => X_Attribute4,
          X_Attribute5                 => X_Attribute5,
          X_Attribute6                 => X_Attribute6,
          X_Attribute7                 => X_Attribute7,
          X_Attribute8                 => X_Attribute8,
          X_Attribute9                 => X_Attribute9,
          X_Attribute10                => X_Attribute10,
          X_Attribute11                => X_Attribute11,
          X_Attribute12                => X_Attribute12,
          X_Attribute13                => X_Attribute13,
          X_Attribute14                => X_Attribute14,
          X_Attribute15                => X_Attribute15,
          X_Attribute16                => X_Attribute16,
          X_Attribute17                => X_Attribute17,
          X_Attribute18                => X_Attribute18,
          X_Attribute19                => X_Attribute19,
          X_Attribute20                => X_Attribute20,
          X_Attribute21                => X_Attribute21,
          X_Attribute22                => X_Attribute22,
          X_Attribute23                => X_Attribute23,
          X_Attribute24                => X_Attribute24,
          X_Attribute25                => X_Attribute25,
          X_Attribute26                => X_Attribute26,
          X_Attribute27                => X_Attribute27,
          X_Attribute28                => X_Attribute28,
          X_Attribute29                => X_Attribute29,
          X_Attribute30                => X_Attribute30,
          X_Attribute_Category_Code    => X_Attribute_Category_Code,
          X_gf_Attribute1              => X_gf_Attribute1,
          X_gf_Attribute2              => X_gf_Attribute2,
          X_gf_Attribute3              => X_gf_Attribute3,
          X_gf_Attribute4              => X_gf_Attribute4,
          X_gf_Attribute5              => X_gf_Attribute5,
          X_gf_Attribute6              => X_gf_Attribute6,
          X_gf_Attribute7              => X_gf_Attribute7,
          X_gf_Attribute8              => X_gf_Attribute8,
          X_gf_Attribute9              => X_gf_Attribute9,
          X_gf_Attribute10             => X_gf_Attribute10,
          X_gf_Attribute11             => X_gf_Attribute11,
          X_gf_Attribute12             => X_gf_Attribute12,
          X_gf_Attribute13             => X_gf_Attribute13,
          X_gf_Attribute14             => X_gf_Attribute14,
          X_gf_Attribute15             => X_gf_Attribute15,
          X_gf_Attribute16             => X_gf_Attribute16,
          X_gf_Attribute17             => X_gf_Attribute17,
          X_gf_Attribute18             => X_gf_Attribute18,
          X_gf_Attribute19             => X_gf_Attribute19,
          X_gf_Attribute20             => X_gf_Attribute20,
          X_gf_Attribute_Category_Code => X_gf_Attribute_Category,
          X_Context                    => X_Context,
          X_Lease_Id                   => X_Lease_Id,
          X_Inventorial                => X_Inventorial,
          X_Commitment                 => X_Commitment,
          X_Investment_Law             => X_Investment_Law,
          X_Status                     => X_Status,
          X_Last_Update_Date           => sysdate,
          X_Last_Updated_By            => user_id,
          X_Last_Update_Login          => 0,
          X_Return_Status              => return_status,
          X_Calling_Fn                 => 'fa_additions_pkg.load_row'
         , p_log_level_rec => p_log_level_rec);
     else
        fa_additions_pkg.Insert_Row(
          X_Rowid                      => row_id,
          X_Asset_Id                   => h_asset_id,
          X_Asset_Number               => h_asset_number,
          X_Asset_Key_Ccid             => X_Asset_Key_Ccid,
          X_Current_Units              => X_Current_Units,
          X_Asset_Type                 => X_Asset_Type,
          X_Tag_Number                 => X_Tag_Number,
          X_Description                => X_Description,
          X_Asset_Category_Id          => X_Asset_Category_Id,
          X_Parent_Asset_Id            => X_Parent_Asset_Id,
          X_Manufacturer_Name          => X_Manufacturer_Name,
          X_Serial_Number              => X_Serial_Number,
          X_Model_Number               => X_Model_Number,
          X_Property_Type_Code         => X_Property_Type_Code,
          X_Property_1245_1250_Code    => X_Property_1245_1250_Code,
          X_In_Use_Flag                => X_In_Use_Flag,
          X_Owned_Leased               => X_Owned_Leased,
          X_New_Used                   => X_New_Used,
          X_Unit_Adjustment_Flag       => X_Unit_Adjustment_Flag,
          X_Add_Cost_Je_Flag           => X_Add_Cost_Je_Flag,
          X_Attribute1                 => X_Attribute1,
          X_Attribute2                 => X_Attribute2,
          X_Attribute3                 => X_Attribute3,
          X_Attribute4                 => X_Attribute4,
          X_Attribute5                 => X_Attribute5,
          X_Attribute6                 => X_Attribute6,
          X_Attribute7                 => X_Attribute7,
          X_Attribute8                 => X_Attribute8,
          X_Attribute9                 => X_Attribute9,
          X_Attribute10                => X_Attribute10,
          X_Attribute11                => X_Attribute11,
          X_Attribute12                => X_Attribute12,
          X_Attribute13                => X_Attribute13,
          X_Attribute14                => X_Attribute14,
          X_Attribute15                => X_Attribute15,
          X_Attribute16                => X_Attribute16,
          X_Attribute17                => X_Attribute17,
          X_Attribute18                => X_Attribute18,
          X_Attribute19                => X_Attribute19,
          X_Attribute20                => X_Attribute20,
          X_Attribute21                => X_Attribute21,
          X_Attribute22                => X_Attribute22,
          X_Attribute23                => X_Attribute23,
          X_Attribute24                => X_Attribute24,
          X_Attribute25                => X_Attribute25,
          X_Attribute26                => X_Attribute26,
          X_Attribute27                => X_Attribute27,
          X_Attribute28                => X_Attribute28,
          X_Attribute29                => X_Attribute29,
          X_Attribute30                => X_Attribute30,
          X_Attribute_Category_Code    => X_Attribute_Category_Code,
          X_gf_Attribute1              => X_gf_Attribute1,
          X_gf_Attribute2              => X_gf_Attribute2,
          X_gf_Attribute3              => X_gf_Attribute3,
          X_gf_Attribute4              => X_gf_Attribute4,
          X_gf_Attribute5              => X_gf_Attribute5,
          X_gf_Attribute6              => X_gf_Attribute6,
          X_gf_Attribute7              => X_gf_Attribute7,
          X_gf_Attribute8              => X_gf_Attribute8,
          X_gf_Attribute9              => X_gf_Attribute9,
          X_gf_Attribute10             => X_gf_Attribute10,
          X_gf_Attribute11             => X_gf_Attribute11,
          X_gf_Attribute12             => X_gf_Attribute12,
          X_gf_Attribute13             => X_gf_Attribute13,
          X_gf_Attribute14             => X_gf_Attribute14,
          X_gf_Attribute15             => X_gf_Attribute15,
          X_gf_Attribute16             => X_gf_Attribute16,
          X_gf_Attribute17             => X_gf_Attribute17,
          X_gf_Attribute18             => X_gf_Attribute18,
          X_gf_Attribute19             => X_gf_Attribute19,
          X_gf_Attribute20             => X_gf_Attribute20,
          X_gf_Attribute_Category_Code => X_gf_Attribute_Category,
          X_Context                    => X_Context,
          X_Lease_Id                   => X_Lease_Id,
          X_Inventorial                => X_Inventorial,
          X_Commitment                 => X_Commitment,
          X_Investment_Law             => X_Investment_Law,
          X_Status                     => X_Status,
          X_Last_Update_Date           => sysdate,
          X_Last_Updated_By            => user_id,
          X_Created_By                 => user_id,
          X_Creation_Date              => sysdate,
          X_Last_Update_Login          => 0,
          X_Calling_Fn                 => 'fa_additions_pkg.load_row'
         , p_log_level_rec => p_log_level_rec);
     end if;

   exception
     when others then
       FA_SRVR_MSG.ADD_SQL_ERROR (
           CALLING_FN => 'fa_additions_pkg.load_row', p_log_level_rec => p_log_level_rec);
       raise;

end LOAD_ROW;

/*Bug 8355119 overloading function for release specific signatures*/
PROCEDURE LOAD_ROW (
      X_Custom_Mode                    IN VARCHAR2,
      X_Asset_Id                       IN NUMBER,
      X_Owner                          IN VARCHAR2,
      X_Last_Update_Date               IN DATE,
      X_Asset_Number                   IN VARCHAR2,
      X_Asset_Key_Ccid                 IN NUMBER DEFAULT NULL,
      X_Current_Units                  IN NUMBER,
      X_Asset_Type                     IN VARCHAR2,
      X_Tag_Number                     IN VARCHAR2 DEFAULT NULL,
      X_Description                    IN VARCHAR2,
      X_Asset_Category_Id              IN NUMBER,
      X_Parent_Asset_Id                IN NUMBER DEFAULT NULL,
      X_Manufacturer_Name              IN VARCHAR2 DEFAULT NULL,
      X_Serial_Number                  IN VARCHAR2 DEFAULT NULL,
      X_Model_Number                   IN VARCHAR2 DEFAULT NULL,
      X_Property_Type_Code             IN VARCHAR2 DEFAULT NULL,
      X_Property_1245_1250_Code        IN VARCHAR2 DEFAULT NULL,
      X_In_Use_Flag                    IN VARCHAR2,
      X_Owned_Leased                   IN VARCHAR2,
      X_New_Used                       IN VARCHAR2,
      X_Unit_Adjustment_Flag           IN VARCHAR2,
      X_Add_Cost_Je_Flag               IN VARCHAR2,
      X_Attribute1                     IN VARCHAR2 DEFAULT NULL,
      X_Attribute2                     IN VARCHAR2 DEFAULT NULL,
      X_Attribute3                     IN VARCHAR2 DEFAULT NULL,
      X_Attribute4                     IN VARCHAR2 DEFAULT NULL,
      X_Attribute5                     IN VARCHAR2 DEFAULT NULL,
      X_Attribute6                     IN VARCHAR2 DEFAULT NULL,
      X_Attribute7                     IN VARCHAR2 DEFAULT NULL,
      X_Attribute8                     IN VARCHAR2 DEFAULT NULL,
      X_Attribute9                     IN VARCHAR2 DEFAULT NULL,
      X_Attribute10                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute11                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute12                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute13                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute14                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute15                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute16                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute17                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute18                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute19                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute20                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute21                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute22                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute23                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute24                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute25                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute26                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute27                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute28                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute29                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute30                    IN VARCHAR2 DEFAULT NULL,
      X_Attribute_Category_Code        IN VARCHAR2,
      X_Context                        IN VARCHAR2 DEFAULT NULL,
      X_Lease_Id                       IN NUMBER DEFAULT NULL,
      X_Inventorial                    IN VARCHAR2,
      X_Commitment                     IN VARCHAR2 DEFAULT NULL,
      X_Investment_Law                 IN VARCHAR2 DEFAULT NULL,
      X_Status                         IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute1                  IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute2                  IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute3                  IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute4                  IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute5                  IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute6                  IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute7                  IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute8                  IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute9                  IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute10                 IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute11                 IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute12                 IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute13                 IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute14                 IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute15                 IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute16                 IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute17                 IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute18                 IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute19                 IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute20                 IN VARCHAR2 DEFAULT NULL,
      X_gf_Attribute_Category          IN VARCHAR2 DEFAULT NULL,
      p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

     h_asset_id     number;
     h_asset_number     varchar2(15);
     h_record_exists     number(15);

     user_id             number;
     row_id              varchar2(64);
     return_status       boolean;

     db_last_updated_by  number;
     db_last_update_date date;

   begin

     h_asset_id := X_Asset_Id;
     h_asset_number := X_Asset_Number;

     user_id := fnd_load_util.owner_id (X_Owner);

     select count(*)
     into   h_record_exists
     from   fa_additions_b
     where  asset_id = X_Asset_Id;

     if (h_record_exists > 0) then

        select last_updated_by, last_update_date
        into   db_last_updated_by, db_last_update_date
        from   fa_additions_b
        where  asset_id = X_Asset_Id;

        if (fnd_load_util.upload_test(user_id, x_last_update_date,
                                      db_last_updated_by, db_last_update_date,
                                      X_CUSTOM_MODE
                                      )) then

           fa_additions_pkg.Update_Row(
             X_Asset_Id                   => h_asset_id,
             X_Asset_Number               => h_asset_number,
             X_Asset_Key_Ccid             => X_Asset_Key_Ccid,
             X_Current_Units              => X_Current_Units,
             X_Asset_Type                 => X_Asset_Type,
             X_Tag_Number                 => X_Tag_Number,
             X_Description                => X_Description,
             X_Asset_Category_Id          => X_Asset_Category_Id,
             X_Parent_Asset_Id            => X_Parent_Asset_Id,
             X_Manufacturer_Name          => X_Manufacturer_Name,
             X_Serial_Number              => X_Serial_Number,
             X_Model_Number               => X_Model_Number,
             X_Property_Type_Code         => X_Property_Type_Code,
             X_Property_1245_1250_Code    => X_Property_1245_1250_Code,
             X_In_Use_Flag                => X_In_Use_Flag,
             X_Owned_Leased               => X_Owned_Leased,
             X_New_Used                   => X_New_Used,
             X_Unit_Adjustment_Flag       => X_Unit_Adjustment_Flag,
             X_Add_Cost_Je_Flag           => X_Add_Cost_Je_Flag,
             X_Attribute1                 => X_Attribute1,
             X_Attribute2                 => X_Attribute2,
             X_Attribute3                 => X_Attribute3,
             X_Attribute4                 => X_Attribute4,
             X_Attribute5                 => X_Attribute5,
             X_Attribute6                 => X_Attribute6,
             X_Attribute7                 => X_Attribute7,
             X_Attribute8                 => X_Attribute8,
             X_Attribute9                 => X_Attribute9,
             X_Attribute10                => X_Attribute10,
             X_Attribute11                => X_Attribute11,
             X_Attribute12                => X_Attribute12,
             X_Attribute13                => X_Attribute13,
             X_Attribute14                => X_Attribute14,
             X_Attribute15                => X_Attribute15,
             X_Attribute16                => X_Attribute16,
             X_Attribute17                => X_Attribute17,
             X_Attribute18                => X_Attribute18,
             X_Attribute19                => X_Attribute19,
             X_Attribute20                => X_Attribute20,
             X_Attribute21                => X_Attribute21,
             X_Attribute22                => X_Attribute22,
             X_Attribute23                => X_Attribute23,
             X_Attribute24                => X_Attribute24,
             X_Attribute25                => X_Attribute25,
             X_Attribute26                => X_Attribute26,
             X_Attribute27                => X_Attribute27,
             X_Attribute28                => X_Attribute28,
             X_Attribute29                => X_Attribute29,
             X_Attribute30                => X_Attribute30,
             X_Attribute_Category_Code    => X_Attribute_Category_Code,
             X_gf_Attribute1              => X_gf_Attribute1,
             X_gf_Attribute2              => X_gf_Attribute2,
             X_gf_Attribute3              => X_gf_Attribute3,
             X_gf_Attribute4              => X_gf_Attribute4,
             X_gf_Attribute5              => X_gf_Attribute5,
             X_gf_Attribute6              => X_gf_Attribute6,
             X_gf_Attribute7              => X_gf_Attribute7,
             X_gf_Attribute8              => X_gf_Attribute8,
             X_gf_Attribute9              => X_gf_Attribute9,
             X_gf_Attribute10             => X_gf_Attribute10,
             X_gf_Attribute11             => X_gf_Attribute11,
             X_gf_Attribute12             => X_gf_Attribute12,
             X_gf_Attribute13             => X_gf_Attribute13,
             X_gf_Attribute14             => X_gf_Attribute14,
             X_gf_Attribute15             => X_gf_Attribute15,
             X_gf_Attribute16             => X_gf_Attribute16,
             X_gf_Attribute17             => X_gf_Attribute17,
             X_gf_Attribute18             => X_gf_Attribute18,
             X_gf_Attribute19             => X_gf_Attribute19,
             X_gf_Attribute20             => X_gf_Attribute20,
             X_gf_Attribute_Category_Code => X_gf_Attribute_Category,
             X_Context                    => X_Context,
             X_Lease_Id                   => X_Lease_Id,
             X_Inventorial                => X_Inventorial,
             X_Commitment                 => X_Commitment,
             X_Investment_Law             => X_Investment_Law,
             X_Status                     => X_Status,
             X_Last_Update_Date           => sysdate,
             X_Last_Updated_By            => user_id,
             X_Last_Update_Login          => 0,
             X_Return_Status              => return_status,
             X_Calling_Fn                 => 'fa_additions_pkg.load_row',
             p_log_level_rec => p_log_level_rec);
        end if;

     else
        fa_additions_pkg.Insert_Row(
          X_Rowid                      => row_id,
          X_Asset_Id                   => h_asset_id,
          X_Asset_Number               => h_asset_number,
          X_Asset_Key_Ccid             => X_Asset_Key_Ccid,
          X_Current_Units              => X_Current_Units,
          X_Asset_Type                 => X_Asset_Type,
          X_Tag_Number                 => X_Tag_Number,
          X_Description                => X_Description,
          X_Asset_Category_Id          => X_Asset_Category_Id,
          X_Parent_Asset_Id            => X_Parent_Asset_Id,
          X_Manufacturer_Name          => X_Manufacturer_Name,
          X_Serial_Number              => X_Serial_Number,
          X_Model_Number               => X_Model_Number,
          X_Property_Type_Code         => X_Property_Type_Code,
          X_Property_1245_1250_Code    => X_Property_1245_1250_Code,
          X_In_Use_Flag                => X_In_Use_Flag,
          X_Owned_Leased               => X_Owned_Leased,
          X_New_Used                   => X_New_Used,
          X_Unit_Adjustment_Flag       => X_Unit_Adjustment_Flag,
          X_Add_Cost_Je_Flag           => X_Add_Cost_Je_Flag,
          X_Attribute1                 => X_Attribute1,
          X_Attribute2                 => X_Attribute2,
          X_Attribute3                 => X_Attribute3,
          X_Attribute4                 => X_Attribute4,
          X_Attribute5                 => X_Attribute5,
          X_Attribute6                 => X_Attribute6,
          X_Attribute7                 => X_Attribute7,
          X_Attribute8                 => X_Attribute8,
          X_Attribute9                 => X_Attribute9,
          X_Attribute10                => X_Attribute10,
          X_Attribute11                => X_Attribute11,
          X_Attribute12                => X_Attribute12,
          X_Attribute13                => X_Attribute13,
          X_Attribute14                => X_Attribute14,
          X_Attribute15                => X_Attribute15,
          X_Attribute16                => X_Attribute16,
          X_Attribute17                => X_Attribute17,
          X_Attribute18                => X_Attribute18,
          X_Attribute19                => X_Attribute19,
          X_Attribute20                => X_Attribute20,
          X_Attribute21                => X_Attribute21,
          X_Attribute22                => X_Attribute22,
          X_Attribute23                => X_Attribute23,
          X_Attribute24                => X_Attribute24,
          X_Attribute25                => X_Attribute25,
          X_Attribute26                => X_Attribute26,
          X_Attribute27                => X_Attribute27,
          X_Attribute28                => X_Attribute28,
          X_Attribute29                => X_Attribute29,
          X_Attribute30                => X_Attribute30,
          X_Attribute_Category_Code    => X_Attribute_Category_Code,
          X_gf_Attribute1              => X_gf_Attribute1,
          X_gf_Attribute2              => X_gf_Attribute2,
          X_gf_Attribute3              => X_gf_Attribute3,
          X_gf_Attribute4              => X_gf_Attribute4,
          X_gf_Attribute5              => X_gf_Attribute5,
          X_gf_Attribute6              => X_gf_Attribute6,
          X_gf_Attribute7              => X_gf_Attribute7,
          X_gf_Attribute8              => X_gf_Attribute8,
          X_gf_Attribute9              => X_gf_Attribute9,
          X_gf_Attribute10             => X_gf_Attribute10,
          X_gf_Attribute11             => X_gf_Attribute11,
          X_gf_Attribute12             => X_gf_Attribute12,
          X_gf_Attribute13             => X_gf_Attribute13,
          X_gf_Attribute14             => X_gf_Attribute14,
          X_gf_Attribute15             => X_gf_Attribute15,
          X_gf_Attribute16             => X_gf_Attribute16,
          X_gf_Attribute17             => X_gf_Attribute17,
          X_gf_Attribute18             => X_gf_Attribute18,
          X_gf_Attribute19             => X_gf_Attribute19,
          X_gf_Attribute20             => X_gf_Attribute20,
          X_gf_Attribute_Category_Code => X_gf_Attribute_Category,
          X_Context                    => X_Context,
          X_Lease_Id                   => X_Lease_Id,
          X_Inventorial                => X_Inventorial,
	  X_Commitment		       => X_Commitment,
	  X_Investment_Law	       => X_Investment_Law,
          X_Status                     => X_Status,
          X_Last_Update_Date           => sysdate,
          X_Last_Updated_By            => user_id,
          X_Created_By                 => user_id,
          X_Creation_Date              => sysdate,
          X_Last_Update_Login          => 0,
          X_Calling_Fn                 => 'fa_additions_pkg.load_row'
          ,p_log_level_rec => p_log_level_rec);
     end if;

EXCEPTION
     when others then
       FA_SRVR_MSG.ADD_SQL_ERROR (
           CALLING_FN => 'fa_additions_pkg.load_row'
           ,p_log_level_rec => p_log_level_rec);
       raise;

end LOAD_ROW;


PROCEDURE TRANSLATE_ROW(
          X_Asset_Id                       IN NUMBER,
          X_Description                    IN VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

   begin

     update FA_ADDITIONS_TL set
        DESCRIPTION = nvl(X_Description, DESCRIPTION),
        LAST_UPDATE_DATE = sysdate,
        LAST_UPDATED_BY = 0,
        LAST_UPDATE_LOGIN = 0,
        SOURCE_LANG = userenv('LANG')
     where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
     and   ASSET_ID = X_Asset_ID;

   exception
      when no_data_found then null;

      when others then
         FA_SRVR_MSG.ADD_SQL_ERROR (
           CALLING_FN => 'fa_additions_pkg.translate_row', p_log_level_rec => p_log_level_rec);
         raise;

end TRANSLATE_ROW;

/*Bug 8355119 overloading function for release specific signatures*/
PROCEDURE TRANSLATE_ROW(
          X_Custom_Mode                    IN VARCHAR2,
          X_Asset_Id                       IN NUMBER,
          X_Owner                          IN VARCHAR2,
          X_Last_Update_Date               IN DATE,
          X_Description                    IN VARCHAR2,
          p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

  user_id              number;

  db_last_updated_by   number;
  db_last_update_date  date;

BEGIN

   select last_updated_by, last_update_date
   into   db_last_updated_by, db_last_update_date
   from   fa_additions_tl
   where  userenv('LANG') in (LANGUAGE, SOURCE_LANG)
   and    asset_id = X_Asset_ID;

   user_id := fnd_load_util.owner_id (X_Owner);

   if (fnd_load_util.upload_test(user_id, x_last_update_date,
                                 db_last_updated_by, db_last_update_date,
                                 X_CUSTOM_MODE )) then

      update FA_ADDITIONS_TL set
         DESCRIPTION = nvl(X_Description, DESCRIPTION),
         LAST_UPDATE_DATE = sysdate,
         LAST_UPDATED_BY = 0,
         LAST_UPDATE_LOGIN = 0,
         SOURCE_LANG = userenv('LANG')
      where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
      and   ASSET_ID = X_Asset_ID;

   end if;

EXCEPTION
   when no_data_found then null;

   when others then
         FA_SRVR_MSG.ADD_SQL_ERROR (
           CALLING_FN => 'fa_additions_pkg.translate_row'
           ,p_log_level_rec => p_log_level_rec);
         raise;

END TRANSLATE_ROW;

/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/

PROCEDURE LOAD_SEED_ROW (
             x_upload_mode              IN VARCHAR2,
             x_custom_mode              IN VARCHAR2,
             x_asset_id                 IN NUMBER,
             x_owner                    IN VARCHAR2,
             x_last_update_date         IN DATE,
             x_asset_number             IN VARCHAR2,
             x_asset_key_ccid           IN NUMBER,
             x_current_units            IN NUMBER,
             x_asset_type               IN VARCHAR2,
             x_tag_number               IN VARCHAR2,
             x_description              IN VARCHAR2,
             x_asset_category_id        IN NUMBER,
             x_parent_asset_id          IN NUMBER,
             x_manufacturer_name        IN VARCHAR2,
             x_serial_number            IN VARCHAR2,
             x_model_number             IN VARCHAR2,
             x_property_type_code       IN VARCHAR2,
             x_property_1245_1250_code  IN VARCHAR2,
             x_in_use_flag              IN VARCHAR2,
             x_owned_leased             IN VARCHAR2,
             x_new_used                 IN VARCHAR2,
             x_unit_adjustment_flag     IN VARCHAR2,
             x_add_cost_je_flag         IN VARCHAR2,
             x_attribute1               IN VARCHAR2,
             x_attribute2               IN VARCHAR2,
             x_attribute3               IN VARCHAR2,
             x_attribute4               IN VARCHAR2,
             x_attribute5               IN VARCHAR2,
             x_attribute6               IN VARCHAR2,
             x_attribute7               IN VARCHAR2,
             x_attribute8               IN VARCHAR2,
             x_attribute9               IN VARCHAR2,
             x_attribute10              IN VARCHAR2,
             x_attribute11              IN VARCHAR2,
             x_attribute12              IN VARCHAR2,
             x_attribute13              IN VARCHAR2,
             x_attribute14              IN VARCHAR2,
             x_attribute15              IN VARCHAR2,
             x_attribute16              IN VARCHAR2,
             x_attribute17              IN VARCHAR2,
             x_attribute18              IN VARCHAR2,
             x_attribute19              IN VARCHAR2,
             x_attribute20              IN VARCHAR2,
             x_attribute21              IN VARCHAR2,
             x_attribute22              IN VARCHAR2,
             x_attribute23              IN VARCHAR2,
             x_attribute24              IN VARCHAR2,
             x_attribute25              IN VARCHAR2,
             x_attribute26              IN VARCHAR2,
             x_attribute27              IN VARCHAR2,
             x_attribute28              IN VARCHAR2,
             x_attribute29              IN VARCHAR2,
             x_attribute30              IN VARCHAR2,
             x_attribute_category_code  IN VARCHAR2,
             x_context                  IN VARCHAR2,
             x_lease_id                 IN NUMBER,
             x_inventorial              IN VARCHAR2,
             x_commitment               IN VARCHAR2,
             x_investment_law           IN VARCHAR2,
             x_gf_attribute1            IN VARCHAR2,
             x_gf_attribute2            IN VARCHAR2,
             x_gf_attribute3            IN VARCHAR2,
             x_gf_attribute4            IN VARCHAR2,
             x_gf_attribute5            IN VARCHAR2,
             x_gf_attribute6            IN VARCHAR2,
             x_gf_attribute7            IN VARCHAR2,
             x_gf_attribute8            IN VARCHAR2,
             x_gf_attribute9            IN VARCHAR2,
             x_gf_attribute10           IN VARCHAR2,
             x_gf_attribute11           IN VARCHAR2,
             x_gf_attribute12           IN VARCHAR2,
             x_gf_attribute13           IN VARCHAR2,
             x_gf_attribute14           IN VARCHAR2,
             x_gf_attribute15           IN VARCHAR2,
             x_gf_attribute16           IN VARCHAR2,
             x_gf_attribute17           IN VARCHAR2,
             x_gf_attribute18           IN VARCHAR2,
             x_gf_attribute19           IN VARCHAR2,
             x_gf_attribute20           IN VARCHAR2,
             x_gf_attribute_category    IN VARCHAR2
             ,p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type default null) IS

BEGIN

        if (x_upload_mode = 'NLS') then
           fa_additions_pkg.TRANSLATE_ROW (
             x_custom_mode              => x_custom_mode,
             x_asset_id                 => x_asset_id,
             x_owner                    => x_owner,
             x_last_update_date         => x_last_update_date,
             x_description              => x_description
             ,p_log_level_rec => p_log_level_rec);
        else
           fa_additions_pkg.LOAD_ROW (
             x_custom_mode              => x_custom_mode,
             x_asset_id                 => x_asset_id,
             x_owner                    => x_owner,
             x_last_update_date         => x_last_update_date,
             x_asset_number             => x_asset_number,
             x_asset_key_ccid           => x_asset_key_ccid,
             x_current_units            => x_current_units,
             x_asset_type               => x_asset_type,
             x_tag_number               => x_tag_number,
             x_description              => x_description,
             x_asset_category_id        => x_asset_category_id,
             x_parent_asset_id          => x_parent_asset_id,
             x_manufacturer_name        => x_manufacturer_name,
             x_serial_number            => x_serial_number,
             x_model_number             => x_model_number,
             x_property_type_code       => x_property_type_code,
             x_property_1245_1250_code  => x_property_1245_1250_code,
             x_in_use_flag              => x_in_use_flag,
             x_owned_leased             => x_owned_leased,
             x_new_used                 => x_new_used,
             x_unit_adjustment_flag     => x_unit_adjustment_flag,
             x_add_cost_je_flag         => x_add_cost_je_flag,
             x_attribute1               => x_attribute1,
             x_attribute2               => x_attribute2,
             x_attribute3               => x_attribute3,
             x_attribute4               => x_attribute4,
             x_attribute5               => x_attribute5,
             x_attribute6               => x_attribute6,
             x_attribute7               => x_attribute7,
             x_attribute8               => x_attribute8,
             x_attribute9               => x_attribute9,
             x_attribute10              => x_attribute10,
             x_attribute11              => x_attribute11,
             x_attribute12              => x_attribute12,
             x_attribute13              => x_attribute13,
             x_attribute14              => x_attribute14,
             x_attribute15              => x_attribute15,
             x_attribute16              => x_attribute16,
             x_attribute17              => x_attribute17,
             x_attribute18              => x_attribute18,
             x_attribute19              => x_attribute19,
             x_attribute20              => x_attribute20,
             x_attribute21              => x_attribute21,
             x_attribute22              => x_attribute22,
             x_attribute23              => x_attribute23,
             x_attribute24              => x_attribute24,
             x_attribute25              => x_attribute25,
             x_attribute26              => x_attribute26,
             x_attribute27              => x_attribute27,
             x_attribute28              => x_attribute28,
             x_attribute29              => x_attribute29,
             x_attribute30              => x_attribute30,
             x_attribute_category_code  => x_attribute_category_code,
             x_context                  => x_context,
             x_lease_id                 => x_lease_id,
             x_inventorial              => x_inventorial,
             x_commitment               => x_commitment,
             x_investment_law           => x_investment_law,
             x_gf_attribute1            => x_gf_attribute1,
             x_gf_attribute2            => x_gf_attribute2,
             x_gf_attribute3            => x_gf_attribute3,
             x_gf_attribute4            => x_gf_attribute4,
             x_gf_attribute5            => x_gf_attribute5,
             x_gf_attribute6            => x_gf_attribute6,
             x_gf_attribute7            => x_gf_attribute7,
             x_gf_attribute8            => x_gf_attribute8,
             x_gf_attribute9            => x_gf_attribute9,
             x_gf_attribute10           => x_gf_attribute10,
             x_gf_attribute11           => x_gf_attribute11,
             x_gf_attribute12           => x_gf_attribute12,
             x_gf_attribute13           => x_gf_attribute13,
             x_gf_attribute14           => x_gf_attribute14,
             x_gf_attribute15           => x_gf_attribute15,
             x_gf_attribute16           => x_gf_attribute16,
             x_gf_attribute17           => x_gf_attribute17,
             x_gf_attribute18           => x_gf_attribute18,
             x_gf_attribute19           => x_gf_attribute19,
             x_gf_attribute20           => x_gf_attribute20,
             x_gf_attribute_category    => x_gf_attribute_category
             ,p_log_level_rec => p_log_level_rec);
        end if;

END LOAD_SEED_ROW;

END FA_ADDITIONS_PKG;

/
