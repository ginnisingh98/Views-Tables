--------------------------------------------------------
--  DDL for Package Body FA_CUA_EXT_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_EXT_TRANSFERS_PKG" AS
/* $Header: FACETFRMB.pls 120.5.12010000.3 2009/08/20 14:18:17 bridgway ship $ */
--
--
PROCEDURE Lock_Row(
        X_Rowid                         VARCHAR2,
        X_Mass_External_Transfer_Id     NUMBER   DEFAULT NULL,
        X_From_Asset_Id                 NUMBER   DEFAULT NULL,
        X_Transaction_Status            VARCHAR2 DEFAULT NULL,
        X_Book_Type_Code                VARCHAR2 DEFAULT NULL,
        X_Transaction_Type              VARCHAR2 DEFAULT NULL,
        X_Batch_Name                    VARCHAR2 DEFAULT NULL,
        X_Description                   VARCHAR2 DEFAULT NULL,
        X_Transaction_Date_Entered      DATE     DEFAULT NULL,
        X_External_Reference_Num        VARCHAR2 DEFAULT NULL,
        X_To_Asset_Id                   NUMBER   DEFAULT NULL,
        X_To_Location_Id                NUMBER   DEFAULT NULL,
        X_To_GL_CCID                    NUMBER   DEFAULT NULL,
        X_To_Employee_Id                NUMBER   DEFAULT NULL,
        X_Transfer_Units                NUMBER   DEFAULT NULL,
        X_Source_Line_Id                NUMBER   DEFAULT NULL,
        X_Transfer_Amount               NUMBER   DEFAULT NULL,
        X_From_Distribution_Id          NUMBER   DEFAULT NULL
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null) IS

CURSOR C_EXT_TRF IS
  SELECT BATCH_NAME,
         MASS_EXTERNAL_TRANSFER_ID,
         EXTERNAL_REFERENCE_NUM,
         TRANSACTION_TYPE,
         FROM_ASSET_ID,
         TO_ASSET_ID,
         BOOK_TYPE_CODE,
         TRANSACTION_STATUS,
         TRANSACTION_DATE_ENTERED,
         FROM_DISTRIBUTION_ID,
         TO_LOCATION_ID,
         TO_GL_CCID,
         TO_EMPLOYEE_ID,
         DESCRIPTION,
         TRANSFER_UNITS,
         TRANSFER_AMOUNT,
         SOURCE_LINE_ID,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN
  FROM fa_mass_external_transfers
  WHERE rowid = X_Rowid
  FOR UPDATE OF mass_external_transfer_id NOWAIT;

recinfo C_EXT_TRF%ROWTYPE;

BEGIN

   OPEN C_EXT_TRF;
   FETCH C_EXT_TRF INTO recinfo;
   if (C_EXT_TRF%NOTFOUND) then
      CLOSE C_EXT_TRF;
      FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
   end if;
   CLOSE C_EXT_TRF;

   if(((Recinfo.mass_external_transfer_id = X_mass_external_transfer_id)
       OR ((Recinfo.mass_external_transfer_id is NULL)
           AND (X_mass_external_transfer_id is NULL)))
  AND ((Recinfo.from_asset_id = X_from_asset_id)
       OR ((Recinfo.from_asset_id is NULL)
           AND (X_from_asset_id is NULL)))
  AND ((Recinfo.transaction_status = X_transaction_status)
       OR ((Recinfo.transaction_status IS NULL)
           AND (X_transaction_status IS NULL)))
  AND ((Recinfo.book_type_code =  X_book_type_code)
       OR ((Recinfo.book_type_code IS NULL)
           AND (X_book_type_code IS NULL)))
  AND ((Recinfo.transaction_type = X_transaction_type)
       OR ((Recinfo.transaction_type IS NULL)
           AND (X_transaction_type IS NULL)))
  -- Bug:5668514
  /*AND ((Recinfo.batch_name = X_batch_name)
       OR ((Recinfo.batch_name IS NULL)
           AND (X_batch_name IS NULL)))
  AND ((Recinfo.description =  X_description)
       OR ((Recinfo.description IS NULL)
           AND (X_description IS NULL)))
  AND ((Recinfo.transaction_date_entered = X_transaction_date_entered)
       OR ((Recinfo.transaction_date_entered IS NULL)
           AND (X_transaction_type IS NULL)))*/
  AND ((Recinfo.batch_name = X_batch_name)
       OR ((Recinfo.batch_name IS NULL)
           AND (X_batch_name IS NULL)))
  AND ((Recinfo.description =  X_description)
       OR ((Recinfo.description IS NULL)
           AND (X_description IS NULL)))
  AND ((Recinfo.transaction_date_entered = X_transaction_date_entered)
       OR ((Recinfo.transaction_date_entered IS NULL)
           AND (X_transaction_date_entered IS NULL)))
  AND ((Recinfo.external_reference_num = X_external_reference_num)
       OR ((Recinfo.external_reference_num IS NULL)
           AND (X_external_reference_num IS NULL)))
  AND ((Recinfo.to_asset_id =  X_to_asset_id)
       OR ((Recinfo.to_asset_id IS NULL)
           AND (X_to_asset_id IS NULL)))
  AND ((Recinfo.to_location_id =  X_to_location_id)
       OR ((Recinfo.to_location_id IS NULL)
           AND (X_to_location_id IS NULL)))
  AND ((Recinfo.to_gl_ccid =  X_to_gl_ccid)
       OR ((Recinfo.to_gl_ccid IS NULL)
           AND (X_to_gl_ccid IS NULL)))
  AND ((Recinfo.to_employee_id =  X_to_employee_id)
       OR ((Recinfo.to_employee_id IS NULL)
           AND (X_to_employee_id IS NULL)))
  AND ((Recinfo.transfer_units =  X_transfer_units)
       OR ((Recinfo.transfer_units IS NULL)
           AND (X_transfer_units IS NULL)))
  AND ((Recinfo.source_line_id =  X_source_line_id)
       OR ((Recinfo.source_line_id IS NULL)
           AND (X_source_line_id IS NULL)))
  AND ((Recinfo.transfer_amount =  X_transfer_amount)
       OR ((Recinfo.transfer_amount IS NULL)
           AND (X_transfer_amount IS NULL)))
  AND ((Recinfo.from_distribution_id = X_from_distribution_id)
       OR ((Recinfo.from_distribution_id IS NULL)
           AND (X_from_distribution_id IS NULL))) )THEN
      null;
   else
      FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
   end if;
END Lock_Row;
--
--
PROCEDURE Update_Row(
        X_Rowid                         VARCHAR2,
        X_Mass_External_Transfer_Id     NUMBER   DEFAULT NULL,
        X_From_Asset_Id                 NUMBER   DEFAULT NULL,
        X_Transaction_Status            VARCHAR2 DEFAULT NULL,
        X_Book_Type_Code                VARCHAR2 DEFAULT NULL,
        X_Transaction_Type              VARCHAR2 DEFAULT NULL,
        X_Batch_Name                    VARCHAR2 DEFAULT NULL,
        X_Description                   VARCHAR2 DEFAULT NULL,
        X_Transaction_Date_Entered      DATE     DEFAULT NULL,
        X_External_Reference_Num        VARCHAR2 DEFAULT NULL,
        X_To_Asset_Id                   NUMBER   DEFAULT NULL,
        X_To_Location_Id                NUMBER   DEFAULT NULL,
        X_To_GL_CCID                    NUMBER   DEFAULT NULL,
        X_To_Employee_Id                NUMBER   DEFAULT NULL,
        X_Transfer_Units                NUMBER   DEFAULT NULL,
        X_Source_Line_Id                NUMBER   DEFAULT NULL,
        X_Transfer_Amount               NUMBER   DEFAULT NULL,
        X_From_Distribution_Id          NUMBER   DEFAULT NULL
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null) IS

BEGIN
    UPDATE fa_mass_external_transfers
    SET
        mass_external_transfer_id =     X_Mass_External_Transfer_Id,
        from_asset_id =                 X_From_Asset_Id,
        transaction_status =            X_Transaction_Status,
        book_type_code  =               X_Book_Type_Code,
        transaction_type =              X_Transaction_Type,
        batch_name =                    X_Batch_Name,
        description =                   X_Description,
        transaction_date_entered =      X_Transaction_Date_Entered,
        external_reference_num =        X_External_Reference_Num,
        to_asset_id =                   X_To_Asset_Id,
        to_location_id =                X_To_Location_Id,
        to_gl_ccid =                    X_To_GL_CCID,
        to_employee_id =                X_To_Employee_Id,
        transfer_units =                X_Transfer_Units,
        source_line_id =                X_Source_Line_Id,
        transfer_amount =               X_Transfer_Amount,
        from_distribution_id =          X_From_Distribution_Id
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    end if;
END Update_Row;
--
--
END FA_CUA_EXT_TRANSFERS_PKG;

/
