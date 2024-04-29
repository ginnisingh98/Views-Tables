--------------------------------------------------------
--  DDL for Package Body FA_RETIREMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RETIREMENTS_PKG" as
/* $Header: faxirtb.pls 120.6.12010000.2 2009/07/19 10:14:42 glchen ship $ */
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Retirement_Id           IN OUT NOCOPY NUMBER,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Id                       NUMBER,
                       X_Transaction_Header_Id_In       NUMBER,
                       X_Date_Retired                   DATE,
                       X_Date_Effective                 DATE,
                       X_Cost_Retired                   NUMBER,
                       X_Status                         VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Ret_Prorate_Convention         VARCHAR2,
                       X_Transaction_Header_Id_Out      NUMBER DEFAULT NULL,
                       X_Units                          NUMBER DEFAULT NULL,
                       X_Cost_Of_Removal                NUMBER DEFAULT NULL,
                       X_Nbv_Retired                    NUMBER DEFAULT NULL,
                       X_Gain_Loss_Amount               NUMBER DEFAULT NULL,
                       X_Proceeds_Of_Sale               NUMBER DEFAULT NULL,
                       X_Gain_Loss_Type_Code            VARCHAR2 DEFAULT NULL,
                       X_Retirement_Type_Code           VARCHAR2 DEFAULT NULL,
                       X_Itc_Recaptured                 NUMBER DEFAULT NULL,
                       X_Itc_Recapture_Id               NUMBER DEFAULT NULL,
                       X_Reference_Num                  VARCHAR2 DEFAULT NULL,
                       X_Sold_To                        VARCHAR2 DEFAULT NULL,
                       X_Trade_In_Asset_Id              NUMBER DEFAULT NULL,
                       X_Stl_Method_Code                VARCHAR2 DEFAULT NULL,
                       X_Stl_Life_In_Months             NUMBER DEFAULT NULL,
                       X_Stl_Deprn_Amount               NUMBER DEFAULT NULL,
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
                       X_Reval_Reserve_Retired          NUMBER DEFAULT NULL,
                       X_Unrevalued_Cost_Retired        NUMBER DEFAULT NULL,
                       X_Recognize_Gain_Loss            VARCHAR2 DEFAULT NULL,
                       X_Recapture_Reserve_Flag         VARCHAR2 DEFAULT NULL,
                       X_Limit_Proceeds_Flag            VARCHAR2 DEFAULT NULL,
                       X_Terminal_Gain_Loss             VARCHAR2 DEFAULT NULL,
                       X_Reserve_Retired                NUMBER DEFAULT NULL,
                       X_Eofy_Reserve                   NUMBER DEFAULT NULL,
                       X_Reduction_Rate                 NUMBER DEFAULT NULL,
                       X_Recapture_Amount               NUMBER DEFAULT NULL,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
                       X_Calling_Fn                     VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
      CURSOR C_ret IS SELECT rowid FROM fa_retirements
                 WHERE retirement_id = X_Retirement_Id;
      CURSOR C_ret_mc IS SELECT rowid FROM fa_mc_retirements
                 WHERE retirement_id = X_Retirement_Id
                 AND set_of_books_id = X_set_of_books_id;

      CURSOR C2 IS SELECT fa_retirements_s.nextval FROM sys.dual;

   BEGIN

       if (X_mrc_sob_type_code = 'R') then

          INSERT INTO fa_mc_retirements(
              set_of_books_id,
              retirement_id,
              book_type_code,
              asset_id,
              transaction_header_id_in,
              date_retired,
              date_effective,
              cost_retired,
              status,
              last_update_date,
              last_updated_by,
              retirement_prorate_convention,
              transaction_header_id_out,
              units,
              cost_of_removal,
              nbv_retired,
              gain_loss_amount,
              proceeds_of_sale,
              gain_loss_type_code,
              retirement_type_code,
              itc_recaptured,
              itc_recapture_id,
              reference_num,
              sold_to,
              trade_in_asset_id,
              stl_method_code,
              stl_life_in_months,
              stl_deprn_amount,
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
              attribute_category_code,
              reval_reserve_retired,
              unrevalued_cost_retired,
              recognize_gain_loss,
              recapture_reserve_flag,
              limit_proceeds_flag,
              terminal_gain_loss,
              reserve_retired,
              eofy_reserve,
              reduction_rate,
              recapture_amount
             ) VALUES (
              X_set_of_books_id,
              X_Retirement_Id,
              X_Book_Type_Code,
              X_Asset_Id,
              X_Transaction_Header_Id_In,
              X_Date_Retired,
              X_Date_Effective,
              X_Cost_Retired,
              X_Status,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Ret_Prorate_Convention,
              X_Transaction_Header_Id_Out,
              X_Units,
              X_Cost_Of_Removal,
              X_Nbv_Retired,
              X_Gain_Loss_Amount,
              X_Proceeds_Of_Sale,
              X_Gain_Loss_Type_Code,
              X_Retirement_Type_Code,
              X_Itc_Recaptured,
              X_Itc_Recapture_Id,
              X_Reference_Num,
              X_Sold_To,
              X_Trade_In_Asset_Id,
              X_Stl_Method_Code,
              X_Stl_Life_In_Months,
              X_Stl_Deprn_Amount,
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
              X_Attribute_Category_Code,
              X_Reval_Reserve_Retired,
              X_Unrevalued_Cost_Retired,
              X_Recognize_Gain_Loss,
              X_Recapture_Reserve_Flag,
              X_Limit_Proceeds_Flag,
              X_Terminal_Gain_Loss,
              X_Reserve_Retired,
              X_Eofy_Reserve,
              X_Reduction_Rate,
              X_Recapture_Amount
             );

          OPEN C_ret_mc;
          FETCH C_ret_mc INTO X_Rowid;
          if (C_ret_mc%NOTFOUND) then
             CLOSE C_ret_mc;
             Raise NO_DATA_FOUND;
          end if;
          CLOSE C_ret_mc;

       else

          if (X_Retirement_Id is NULL) then
            OPEN C2;
             FETCH C2 INTO X_Retirement_Id;
            CLOSE C2;
          end if;

          INSERT INTO fa_retirements(
              retirement_id,
              book_type_code,
              asset_id,
              transaction_header_id_in,
              date_retired,
              date_effective,
              cost_retired,
              status,
              last_update_date,
              last_updated_by,
              retirement_prorate_convention,
              transaction_header_id_out,
              units,
              cost_of_removal,
              nbv_retired,
              gain_loss_amount,
              proceeds_of_sale,
              gain_loss_type_code,
              retirement_type_code,
              itc_recaptured,
              itc_recapture_id,
              reference_num,
              sold_to,
              trade_in_asset_id,
              stl_method_code,
              stl_life_in_months,
              stl_deprn_amount,
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
              attribute_category_code,
              reval_reserve_retired,
              unrevalued_cost_retired,
              recognize_gain_loss,
              recapture_reserve_flag,
              limit_proceeds_flag,
              terminal_gain_loss,
              reserve_retired,
              eofy_reserve,
              reduction_rate,
              recapture_amount
             ) VALUES (
              X_Retirement_Id,
              X_Book_Type_Code,
              X_Asset_Id,
              X_Transaction_Header_Id_In,
              X_Date_Retired,
              X_Date_Effective,
              X_Cost_Retired,
              X_Status,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Ret_Prorate_Convention,
              X_Transaction_Header_Id_Out,
              X_Units,
              X_Cost_Of_Removal,
              X_Nbv_Retired,
              X_Gain_Loss_Amount,
              X_Proceeds_Of_Sale,
              X_Gain_Loss_Type_Code,
              X_Retirement_Type_Code,
              X_Itc_Recaptured,
              X_Itc_Recapture_Id,
              X_Reference_Num,
              X_Sold_To,
              X_Trade_In_Asset_Id,
              X_Stl_Method_Code,
              X_Stl_Life_In_Months,
              X_Stl_Deprn_Amount,
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
              X_Attribute_Category_Code,
              X_Reval_Reserve_Retired,
              X_Unrevalued_Cost_Retired,
              X_Recognize_Gain_Loss,
              X_Recapture_Reserve_Flag,
              X_Limit_Proceeds_Flag,
              X_Terminal_Gain_Loss,
              X_Reserve_Retired,
              X_Eofy_Reserve,
              X_Reduction_Rate,
              X_Recapture_Amount
             );

          OPEN C_ret;
          FETCH C_ret INTO X_Rowid;
          if (C_ret%NOTFOUND) then
              CLOSE C_ret;
              Raise NO_DATA_FOUND;
          end if;
          CLOSE C_ret;

       end if;  -- end mrc

  EXCEPTION
     WHEN Others THEN
          fa_srvr_msg.add_sql_error(
                CALLING_FN  => 'FA_RETIREMENTS_PKG.insert_row', p_log_level_rec => p_log_level_rec);
          raise;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Retirement_Id                    NUMBER,
                     X_Book_Type_Code                   VARCHAR2,
                     X_Asset_Id                         NUMBER,
                     X_Transaction_Header_Id_In         NUMBER,
                     X_Date_Retired                     DATE,
                     X_Date_Effective                   DATE,
                     X_Cost_Retired                     NUMBER,
                     X_Status                           VARCHAR2,
                     X_Ret_Prorate_Convention           VARCHAR2,
                     X_Transaction_Header_Id_Out        NUMBER DEFAULT NULL,
                     X_Units                            NUMBER DEFAULT NULL,
                     X_Cost_Of_Removal                  NUMBER DEFAULT NULL,
                     X_Nbv_Retired                      NUMBER DEFAULT NULL,
                     X_Gain_Loss_Amount                 NUMBER DEFAULT NULL,
                     X_Proceeds_Of_Sale                 NUMBER DEFAULT NULL,
                     X_Gain_Loss_Type_Code              VARCHAR2 DEFAULT NULL,
                     X_Retirement_Type_Code             VARCHAR2 DEFAULT NULL,
                     X_Itc_Recaptured                   NUMBER DEFAULT NULL,
                     X_Itc_Recapture_Id                 NUMBER DEFAULT NULL,
                     X_Reference_Num                    VARCHAR2 DEFAULT NULL,
                     X_Sold_To                          VARCHAR2 DEFAULT NULL,
                     X_Trade_In_Asset_Id                NUMBER DEFAULT NULL,
                     X_Stl_Method_Code                  VARCHAR2 DEFAULT NULL,
                     X_Stl_Life_In_Months               NUMBER DEFAULT NULL,
                     X_Stl_Deprn_Amount                 NUMBER DEFAULT NULL,
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
                     X_Reval_Reserve_Retired            NUMBER DEFAULT NULL,
                     X_Unrevalued_Cost_Retired          NUMBER DEFAULT NULL,
                     X_Recognize_Gain_Loss              VARCHAR2 DEFAULT NULL,
                     X_Recapture_Reserve_Flag           VARCHAR2 DEFAULT NULL,
                     X_Limit_Proceeds_Flag              VARCHAR2 DEFAULT NULL,
                     X_Terminal_Gain_Loss               VARCHAR2 DEFAULT NULL,
                     X_Reserve_Retired                  NUMBER DEFAULT NULL,
                     X_Eofy_Reserve                     NUMBER DEFAULT NULL,
                     X_Reduction_Rate                   NUMBER DEFAULT NULL,
                     X_Recapture_Amount                 NUMBER DEFAULT NULL,
                     X_Calling_Fn                       VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS
        SELECT     retirement_id,
          book_type_code,
          asset_id,
          transaction_header_id_in,
          date_retired,
          date_effective,
          cost_retired,
          status,
          last_update_date,
          last_updated_by,
          retirement_prorate_convention,
          transaction_header_id_out,
          units,
          cost_of_removal,
          nbv_retired,
          gain_loss_amount,
          proceeds_of_sale,
          gain_loss_type_code,
          retirement_type_code,
          itc_recaptured,
          itc_recapture_id,
          reference_num,
          sold_to,
          trade_in_asset_id,
          stl_method_code,
          stl_life_in_months,
          stl_deprn_amount,
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
          attribute_category_code,
          reval_reserve_retired,
          unrevalued_cost_retired,
          recognize_gain_loss,
          recapture_reserve_flag,
          limit_proceeds_flag,
          terminal_gain_loss,
          reserve_retired,
          eofy_reserve,
          reduction_rate,
          recapture_amount
        FROM   fa_retirements
        WHERE  rowid = X_Rowid
        FOR UPDATE of Retirement_Id NOWAIT;
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
    if ((Recinfo.retirement_id =  X_Retirement_Id)
           AND (Recinfo.book_type_code =  X_Book_Type_Code)
           AND (Recinfo.asset_id =  X_Asset_Id)
           AND (Recinfo.transaction_header_id_in =  X_Transaction_Header_Id_In)
           AND (Recinfo.date_retired =  X_Date_Retired)
           AND (Recinfo.date_effective =  X_Date_Effective)
           AND (Recinfo.cost_retired =  X_Cost_Retired)
           AND (Recinfo.status =  X_Status)
           AND (Recinfo.retirement_prorate_convention =
                         X_Ret_Prorate_Convention)
           AND (   (Recinfo.transaction_header_id_out =
                         X_Transaction_Header_Id_Out)
                OR (    (Recinfo.transaction_header_id_out IS NULL)
                    AND (X_Transaction_Header_Id_Out IS NULL)))
           AND (   (Recinfo.units =  X_Units)
                OR (    (Recinfo.units IS NULL)
                    AND (X_Units IS NULL)))
           AND (   (Recinfo.cost_of_removal =  X_Cost_Of_Removal)
                OR (    (Recinfo.cost_of_removal IS NULL)
                    AND (X_Cost_Of_Removal IS NULL)))
           AND (   (Recinfo.nbv_retired =  X_Nbv_Retired)
                OR (    (Recinfo.nbv_retired IS NULL)
                    AND (X_Nbv_Retired IS NULL)))
           AND (   (Recinfo.gain_loss_amount =  X_Gain_Loss_Amount)
                OR (    (Recinfo.gain_loss_amount IS NULL)
                    AND (X_Gain_Loss_Amount IS NULL)))
           AND (   (Recinfo.proceeds_of_sale =  X_Proceeds_Of_Sale)
                OR (    (Recinfo.proceeds_of_sale IS NULL)
                    AND (X_Proceeds_Of_Sale IS NULL)))
           AND (   (Recinfo.gain_loss_type_code =  X_Gain_Loss_Type_Code)
                OR (    (Recinfo.gain_loss_type_code IS NULL)
                    AND (X_Gain_Loss_Type_Code IS NULL)))
           AND (   (Recinfo.retirement_type_code =  X_Retirement_Type_Code)
                OR (    (Recinfo.retirement_type_code IS NULL)
                    AND (X_Retirement_Type_Code IS NULL)))
           AND (   (Recinfo.itc_recaptured =  X_Itc_Recaptured)
                OR (    (Recinfo.itc_recaptured IS NULL)
                    AND (X_Itc_Recaptured IS NULL)))
           AND (   (Recinfo.itc_recapture_id =  X_Itc_Recapture_Id)
                OR (    (Recinfo.itc_recapture_id IS NULL)
                    AND (X_Itc_Recapture_Id IS NULL)))
           AND (   (Recinfo.reference_num =  X_Reference_Num)
                OR (    (Recinfo.reference_num IS NULL)
                    AND (X_Reference_Num IS NULL)))
           AND (   (Recinfo.sold_to =  X_Sold_To)
                OR (    (Recinfo.sold_to IS NULL)
                    AND (X_Sold_To IS NULL)))
           AND (   (Recinfo.trade_in_asset_id =  X_Trade_In_Asset_Id)
                OR (    (Recinfo.trade_in_asset_id IS NULL)
                    AND (X_Trade_In_Asset_Id IS NULL)))
           AND (   (Recinfo.stl_method_code =  X_Stl_Method_Code)
                OR (    (Recinfo.stl_method_code IS NULL)
                    AND (X_Stl_Method_Code IS NULL)))
           AND (   (Recinfo.stl_life_in_months =  X_Stl_Life_In_Months)
                OR (    (Recinfo.stl_life_in_months IS NULL)
                    AND (X_Stl_Life_In_Months IS NULL)))
           AND (   (Recinfo.stl_deprn_amount =  X_Stl_Deprn_Amount)
                OR (    (Recinfo.stl_deprn_amount IS NULL)
                    AND (X_Stl_Deprn_Amount IS NULL)))
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
           AND (   (Recinfo.attribute_category_code=X_Attribute_Category_Code)
                OR (    (Recinfo.attribute_category_code IS NULL)
                    AND (X_Attribute_Category_Code IS NULL)))
           AND (   (Recinfo.reval_reserve_retired =  X_Reval_Reserve_Retired)
                OR (    (Recinfo.reval_reserve_retired IS NULL)
                    AND (X_Reval_Reserve_Retired IS NULL)))
           AND (   (Recinfo.unrevalued_cost_retired =
                    X_Unrevalued_Cost_Retired)
                OR (    (Recinfo.unrevalued_cost_retired IS NULL)
                    AND (X_Unrevalued_Cost_Retired IS NULL)))
           AND (   (Recinfo.recognize_gain_loss =
                    X_Recognize_Gain_Loss)
                OR (    (Recinfo.recognize_gain_loss IS NULL)
                    AND (X_Recognize_Gain_Loss IS NULL)))
           AND (   (Recinfo.recapture_reserve_flag =
                    X_Recapture_Reserve_Flag)
                OR (    (Recinfo.recapture_reserve_flag IS NULL)
                    AND (X_Recapture_Reserve_Flag IS NULL)))
           AND (   (Recinfo.limit_proceeds_flag =
                    X_Limit_Proceeds_Flag)
                OR (    (Recinfo.limit_proceeds_flag IS NULL)
                    AND (X_Limit_Proceeds_Flag IS NULL)))
           AND (   (Recinfo.terminal_gain_loss =
                    X_Terminal_Gain_Loss)
                OR (    (Recinfo.terminal_gain_loss IS NULL)
                    AND (X_Terminal_Gain_Loss IS NULL)))
           AND (   (Recinfo.reserve_retired =
                    X_Reserve_Retired)
                OR (    (Recinfo.reserve_retired IS NULL)
                    AND (X_Reserve_Retired IS NULL)))
           AND (   (Recinfo.reduction_rate =
                    X_Reduction_Rate)
                OR (    (Recinfo.reduction_rate IS NULL)
                    AND (X_Reduction_Rate IS NULL)))
           AND (   (Recinfo.eofy_reserve =
                    X_Eofy_Reserve)
                OR (    (Recinfo.eofy_reserve IS NULL)
                    AND (X_Eofy_Reserve IS NULL)))
           AND (   (Recinfo.recapture_amount =
                    X_Recapture_Amount)
                OR (    (Recinfo.recapture_amount IS NULL)
                    AND (X_Recapture_Amount IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Retirement_Id                  NUMBER   DEFAULT NULL,
                       X_Book_Type_Code                 VARCHAR2 DEFAULT NULL,
                       X_Asset_Id                       NUMBER   DEFAULT NULL,
                       X_Transaction_Header_Id_In       NUMBER   DEFAULT NULL,
                       X_Date_Retired                   DATE     DEFAULT NULL,
                       X_Date_Effective                 DATE     DEFAULT NULL,
                       X_Cost_Retired                   NUMBER   DEFAULT NULL,
                       X_Status                         VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Date               DATE     DEFAULT NULL,
                       X_Last_Updated_By                NUMBER   DEFAULT NULL,
                       X_Ret_Prorate_Convention         VARCHAR2 DEFAULT NULL,
                       X_Transaction_Header_Id_Out      NUMBER   DEFAULT NULL,
                       X_Units                          NUMBER   DEFAULT NULL,
                       X_Cost_Of_Removal                NUMBER   DEFAULT NULL,
                       X_Nbv_Retired                    NUMBER   DEFAULT NULL,
                       X_Gain_Loss_Amount               NUMBER   DEFAULT NULL,
                       X_Proceeds_Of_Sale               NUMBER   DEFAULT NULL,
                       X_Gain_Loss_Type_Code            VARCHAR2 DEFAULT NULL,
                       X_Retirement_Type_Code           VARCHAR2 DEFAULT NULL,
                       X_Itc_Recaptured                 NUMBER   DEFAULT NULL,
                       X_Itc_Recapture_Id               NUMBER   DEFAULT NULL,
                       X_Reference_Num                  VARCHAR2 DEFAULT NULL,
                       X_Sold_To                        VARCHAR2 DEFAULT NULL,
                       X_Trade_In_Asset_Id              NUMBER   DEFAULT NULL,
                       X_Stl_Method_Code                VARCHAR2 DEFAULT NULL,
                       X_Stl_Life_In_Months             NUMBER   DEFAULT NULL,
                       X_Stl_Deprn_Amount               NUMBER   DEFAULT NULL,
                       X_Last_Update_Login              NUMBER   DEFAULT NULL,
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
                       X_Reval_Reserve_Retired          NUMBER   DEFAULT NULL,
                       X_Unrevalued_Cost_Retired        NUMBER   DEFAULT NULL,
                       X_Recognize_Gain_Loss            VARCHAR2 DEFAULT NULL,
                       X_Recapture_Reserve_Flag         VARCHAR2 DEFAULT NULL,
                       X_Limit_Proceeds_Flag            VARCHAR2 DEFAULT NULL,
                       X_Terminal_Gain_Loss             VARCHAR2 DEFAULT NULL,
                       X_Reserve_Retired                NUMBER   DEFAULT NULL,
                       X_Eofy_Reserve                   NUMBER   DEFAULT NULL,
                       X_Reduction_Rate                 NUMBER   DEFAULT NULL,
                       X_Recapture_Amount               NUMBER   DEFAULT NULL,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
                       X_Calling_Fn                     VARCHAR2

  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

    l_rowid        ROWID;

  BEGIN

    if (X_mrc_sob_type_code = 'R') then

       if (X_Rowid is null) then
          select rowid
          into   l_rowid
          from   fa_mc_retirements
          where  retirement_id = X_Retirement_Id
          and    set_of_books_id = X_set_of_books_id;
       else
          l_rowid := X_Rowid;
       end if;

       UPDATE fa_mc_retirements
       SET
          retirement_id                   =     decode(X_Retirement_Id,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       retirement_id,
                                                       X_retirement_id),
          book_type_code                  =     decode(X_Book_Type_Code,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       book_type_code,
                                                       X_book_type_code),
          asset_id                        =     decode(X_Asset_Id,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       asset_id,
                                                       X_asset_id),
          transaction_header_id_in        =     decode(X_Transaction_Header_Id_In,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       transaction_header_id_in,
                                                       X_transaction_header_id_in),
          /* removed G_MISS_DATE comparison */
          date_retired                    =     decode(X_Date_Retired,
                                                       NULL,       date_retired,
                                                       X_date_retired),
          date_effective                  =     decode(X_Date_Effective,
                                                       NULL,       date_effective,
                                                       X_date_effective),

          cost_retired                    =     decode(X_Cost_Retired,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       cost_retired,
                                                       X_cost_retired),
          status                          =     decode(X_Status,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       status,
                                                       X_status),
          /* removed G_MISS_DATE comparison */
          last_update_date                =     decode(X_Last_Update_Date,
                                                       NULL,       last_update_date,
                                                       X_last_update_date),
          last_updated_by                 =     decode(X_Last_Updated_By,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       last_updated_by,
                                                       X_last_updated_by),
          retirement_prorate_convention   =     decode(X_Ret_Prorate_Convention,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       retirement_prorate_convention,
                                                       X_ret_prorate_convention),
          transaction_header_id_out       =     decode(X_Transaction_Header_Id_Out,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       transaction_header_id_out,
                                                       X_transaction_header_id_out),
          units                           =     decode(X_Units,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       units,
                                                       X_units),
          cost_of_removal                 =     decode(X_Cost_Of_Removal,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       cost_of_removal,
                                                       X_cost_of_removal),
          nbv_retired                     =     decode(X_Nbv_Retired,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       nbv_retired,
                                                       X_nbv_retired),
          gain_loss_amount                =     decode(X_Gain_Loss_Amount,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       gain_loss_amount,
                                                       X_gain_loss_amount),
          proceeds_of_sale                =     decode(X_Proceeds_Of_Sale,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       proceeds_of_sale,
                                                       X_proceeds_of_sale),
          gain_loss_type_code             =     decode(X_Gain_Loss_Type_Code,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       gain_loss_type_code,
                                                       X_gain_loss_type_code),
          retirement_type_code            =     decode(X_Retirement_Type_Code,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       retirement_type_code,
                                                       X_retirement_type_code),
          itc_recaptured                  =     decode(X_Itc_Recaptured,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       itc_recaptured,
                                                       X_itc_recaptured),
          itc_recapture_id                =     decode(X_Itc_Recapture_Id,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       itc_recapture_id,
                                                       X_itc_recapture_id),
          reference_num                   =     decode(X_Reference_Num,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       reference_num,
                                                       X_reference_num),
          sold_to                         =     decode(X_Sold_To,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       sold_to,
                                                       X_sold_to),
          trade_in_asset_id               =     decode(X_Trade_In_Asset_Id,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       trade_in_asset_id,
                                                       X_trade_in_asset_id),
          stl_method_code                 =     decode(X_Stl_Method_Code,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       stl_method_code,
                                                       X_stl_method_code),
          stl_life_in_months              =     decode(X_Stl_Life_In_Months,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       stl_life_in_months,
                                                       X_stl_life_in_months),
          stl_deprn_amount                =     decode(X_Stl_Deprn_Amount,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       stl_deprn_amount,
                                                       X_stl_deprn_amount),
          last_update_login               =     decode(X_Last_Update_Login,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       last_update_login,
                                                       X_last_update_login),
          attribute1                      =     decode(X_Attribute1,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute1,
                                                       X_attribute1),
          attribute2                      =     decode(X_Attribute2,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute2,
                                                       X_attribute2),
          attribute3                      =     decode(X_Attribute3,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute3,
                                                       X_attribute3),
          attribute4                      =     decode(X_Attribute4,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute4,
                                                       X_attribute4),
          attribute5                      =     decode(X_Attribute5,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute5,
                                                       X_attribute5),
          attribute6                      =     decode(X_Attribute6,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute6,
                                                       X_attribute6),
          attribute7                      =     decode(X_Attribute7,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute7,
                                                       X_attribute7),
          attribute8                      =     decode(X_Attribute8,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute8,
                                                       X_attribute8),
          attribute9                      =     decode(X_Attribute9,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute9,
                                                       X_attribute9),
          attribute10                     =     decode(X_Attribute10,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute10,
                                                       X_attribute10),
          attribute11                     =     decode(X_Attribute11,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute11,
                                                       X_attribute11),
          attribute12                     =     decode(X_Attribute12,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute12,
                                                       X_attribute12),
          attribute13                     =     decode(X_Attribute13,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute13,
                                                       X_attribute13),
          attribute14                     =     decode(X_Attribute14,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute14,
                                                       X_attribute14),
          attribute15                     =     decode(X_Attribute15,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute15,
                                                       X_attribute15),
          attribute_category_code         =     decode(X_Attribute_Category_Code,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute_category_code,
                                                       X_attribute_category_code),
          reval_reserve_retired           =     decode(X_Reval_Reserve_Retired,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       reval_reserve_retired,
                                                       X_reval_reserve_retired),
          unrevalued_cost_retired         =     decode(X_Unrevalued_Cost_Retired,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       unrevalued_cost_retired,
                                                       X_unrevalued_cost_retired),
          recognize_gain_loss             =     decode(X_Recognize_Gain_Loss,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       recognize_gain_loss,
                                                       X_Recognize_Gain_Loss),
          recapture_reserve_flag          =     decode(X_Recapture_Reserve_Flag,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       recapture_reserve_flag,
                                                       X_Recapture_Reserve_Flag),
          limit_proceeds_flag             =     decode(X_Limit_Proceeds_Flag,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       limit_proceeds_flag,
                                                       X_Limit_Proceeds_Flag),
          terminal_gain_loss              =     decode(X_Terminal_Gain_Loss,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       terminal_gain_loss,
                                                       X_Terminal_Gain_Loss),
          reserve_retired                 =     decode(X_Reserve_Retired,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       reserve_retired,
                                                       X_Reserve_Retired),
          reduction_rate                  =     decode(X_Reduction_Rate,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       reduction_rate,
                                                       X_Reduction_Rate),
          eofy_reserve                    =     decode(X_Eofy_Reserve,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       eofy_reserve,
                                                       X_Eofy_Reserve),
          recapture_amount                =     decode(X_Recapture_Amount,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       recapture_amount,
                                                       X_Recapture_Amount)
       WHERE rowid = l_rowid;
    else

       if (X_Rowid is null) then
          select rowid
          into   l_rowid
          from   fa_retirements
          where  retirement_id = X_Retirement_Id;
       else
          l_rowid := X_Rowid;
       end if;

       UPDATE fa_retirements
       SET
          retirement_id                   =     decode(X_Retirement_Id,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       retirement_id,
                                                       X_retirement_id),
          book_type_code                  =     decode(X_Book_Type_Code,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       book_type_code,
                                                       X_book_type_code),
          asset_id                        =     decode(X_Asset_Id,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       asset_id,
                                                       X_asset_id),
          transaction_header_id_in        =     decode(X_Transaction_Header_Id_In,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       transaction_header_id_in,
                                                       X_transaction_header_id_in),
          /* removed G_MISS_DATE comparison */
          date_retired                    =     decode(X_Date_Retired,
                                                       NULL,       date_retired,
                                                       X_date_retired),
          /* removed G_MISS_DATE comparison */
          date_effective                  =     decode(X_Date_Effective,
                                                       NULL, date_effective,
                                                       X_Date_Effective),
          cost_retired                    =     decode(X_Cost_Retired,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       cost_retired,
                                                       X_cost_retired),
          status                          =     decode(X_Status,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       status,
                                                       X_status),
          /* removed G_MISS_DATE comparison */
          last_update_date                =     decode(X_Last_Update_Date,
                                                       NULL,       last_update_date,
                                                       X_last_update_date),
          last_updated_by                 =     decode(X_Last_Updated_By,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       last_updated_by,
                                                       X_last_updated_by),
          retirement_prorate_convention   =     decode(X_Ret_Prorate_Convention,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       retirement_prorate_convention,
                                                       X_ret_prorate_convention),
          transaction_header_id_out       =     decode(X_Transaction_Header_Id_Out,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       transaction_header_id_out,
                                                       X_transaction_header_id_out),
          units                           =     decode(X_Units,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       units,
                                                       X_units),
          cost_of_removal                 =     decode(X_Cost_Of_Removal,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       cost_of_removal,
                                                       X_cost_of_removal),
          nbv_retired                     =     decode(X_Nbv_Retired,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       nbv_retired,
                                                       X_nbv_retired),
          gain_loss_amount                =     decode(X_Gain_Loss_Amount,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       gain_loss_amount,
                                                       X_gain_loss_amount),
          proceeds_of_sale                =     decode(X_Proceeds_Of_Sale,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       proceeds_of_sale,
                                                       X_proceeds_of_sale),
          gain_loss_type_code             =     decode(X_Gain_Loss_Type_Code,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       gain_loss_type_code,
                                                       X_gain_loss_type_code),
          retirement_type_code            =     decode(X_Retirement_Type_Code,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       retirement_type_code,
                                                       X_retirement_type_code),
          itc_recaptured                  =     decode(X_Itc_Recaptured,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       itc_recaptured,
                                                       X_itc_recaptured),
          itc_recapture_id                =     decode(X_Itc_Recapture_Id,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       itc_recapture_id,
                                                       X_itc_recapture_id),
          reference_num                   =     decode(X_Reference_Num,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       reference_num,
                                                       X_reference_num),
          sold_to                         =     decode(X_Sold_To,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       sold_to,
                                                       X_sold_to),
          trade_in_asset_id               =     decode(X_Trade_In_Asset_Id,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       trade_in_asset_id,
                                                       X_trade_in_asset_id),
          stl_method_code                 =     decode(X_Stl_Method_Code,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       stl_method_code,
                                                       X_stl_method_code),
          stl_life_in_months              =     decode(X_Stl_Life_In_Months,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       stl_life_in_months,
                                                       X_stl_life_in_months),
          stl_deprn_amount                =     decode(X_Stl_Deprn_Amount,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       stl_deprn_amount,
                                                       X_stl_deprn_amount),
          last_update_login               =     decode(X_Last_Update_Login,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       last_update_login,
                                                       X_last_update_login),
          attribute1                      =     decode(X_Attribute1,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute1,
                                                       X_attribute1),
          attribute2                      =     decode(X_Attribute2,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute2,
                                                       X_attribute2),
          attribute3                      =     decode(X_Attribute3,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute3,
                                                       X_attribute3),
          attribute4                      =     decode(X_Attribute4,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute4,
                                                       X_attribute4),
          attribute5                      =     decode(X_Attribute5,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute5,
                                                       X_attribute5),
          attribute6                      =     decode(X_Attribute6,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute6,
                                                       X_attribute6),
          attribute7                      =     decode(X_Attribute7,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute7,
                                                       X_attribute7),
          attribute8                      =     decode(X_Attribute8,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute8,
                                                       X_attribute8),
          attribute9                      =     decode(X_Attribute9,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute9,
                                                       X_attribute9),
          attribute10                     =     decode(X_Attribute10,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute10,
                                                       X_attribute10),
          attribute11                     =     decode(X_Attribute11,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute11,
                                                       X_attribute11),
          attribute12                     =     decode(X_Attribute12,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute12,
                                                       X_attribute12),
          attribute13                     =     decode(X_Attribute13,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute13,
                                                       X_attribute13),
          attribute14                     =     decode(X_Attribute14,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute14,
                                                       X_attribute14),
          attribute15                     =     decode(X_Attribute15,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute15,
                                                       X_attribute15),
          attribute_category_code         =     decode(X_Attribute_Category_Code,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       attribute_category_code,
                                                       X_attribute_category_code),
          reval_reserve_retired           =     decode(X_Reval_Reserve_Retired,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       reval_reserve_retired,
                                                       X_reval_reserve_retired),
          unrevalued_cost_retired         =     decode(X_Unrevalued_Cost_Retired,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       unrevalued_cost_retired,
                                                       X_unrevalued_cost_retired),
          recognize_gain_loss             =     decode(X_Recognize_Gain_Loss,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       recognize_gain_loss,
                                                       X_Recognize_Gain_Loss),
          recapture_reserve_flag          =     decode(X_Recapture_Reserve_Flag,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       recapture_reserve_flag,
                                                       X_Recapture_Reserve_Flag),
          limit_proceeds_flag             =     decode(X_Limit_Proceeds_Flag,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       limit_proceeds_flag,
                                                       X_Limit_Proceeds_Flag),
          terminal_gain_loss              =     decode(X_Terminal_Gain_Loss,
                                                       FND_API.G_MISS_CHAR, NULL,
                                                       NULL,       terminal_gain_loss,
                                                       X_Terminal_Gain_Loss),
          reserve_retired                 =     decode(X_Reserve_Retired,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       reserve_retired,
                                                       X_Reserve_Retired),
          reduction_rate                  =     decode(X_Reduction_Rate,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       reduction_rate,
                                                       X_Reduction_Rate),
          eofy_reserve                    =     decode(X_Eofy_Reserve,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       eofy_reserve,
                                                       X_Eofy_Reserve),
          recapture_amount                =     decode(X_Recapture_Amount,
                                                       FND_API.G_MISS_NUM, NULL,
                                                       NULL,       recapture_amount,
                                                       X_Recapture_Amount)
       WHERE rowid = l_rowid;
    end if;


    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
    WHEN Others THEN
         fa_srvr_msg.add_sql_error(
                CALLING_FN  => 'FA_RETIREMENTS_PKG.UPDATE_ROW', p_log_level_rec => p_log_level_rec);
         raise;
  END Update_Row;

  --

  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                       X_mrc_sob_type_code  VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
                       X_Calling_Fn     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  BEGIN

    if (X_mrc_sob_type_code = 'R') then
       DELETE FROM fa_mc_retirements
       WHERE rowid = X_Rowid;
    else
       DELETE FROM fa_retirements
       WHERE rowid = X_Rowid;
    end if;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
      WHEN Others THEN
           fa_srvr_msg.add_sql_error(
                CALLING_FN  => 'FA_RETIREMENTS_PKG.DELETE_ROW', p_log_level_rec => p_log_level_rec);
           raise;
  END Delete_Row;
--
END FA_RETIREMENTS_PKG;

/
