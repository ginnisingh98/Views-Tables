--------------------------------------------------------
--  DDL for Package FA_RETIREMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RETIREMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: faxirts.pls 120.4.12010000.2 2009/07/19 10:15:19 glchen ship $ */


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
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

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
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);



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
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
                       X_Calling_Fn                     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_RETIREMENTS_PKG;

/
