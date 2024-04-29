--------------------------------------------------------
--  DDL for Package FA_BOOKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_BOOKS_PKG" AUTHID CURRENT_USER as
/* $Header: faxibks.pls 120.12.12010000.2 2009/07/19 13:31:19 glchen ship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Id                       NUMBER,
                       X_Date_Placed_In_Service         DATE,
                       X_Date_Effective                 DATE,
                       X_Deprn_Start_Date               DATE,
                       X_Deprn_Method_Code              VARCHAR2,
                       X_Life_In_Months                 NUMBER DEFAULT NULL,
                       X_Rate_Adjustment_Factor         NUMBER,
                       X_Adjusted_Cost                  NUMBER,
                       X_Cost                           NUMBER,
                       X_Original_Cost                  NUMBER,
                       X_Salvage_Value                  NUMBER,
                       X_Prorate_Convention_Code        VARCHAR2,
                       X_Prorate_Date                   DATE,
                       X_Cost_Change_Flag               VARCHAR2,
                       X_Adjustment_Required_Status     VARCHAR2,
                       X_Capitalize_Flag                VARCHAR2,
                       X_Retirement_Pending_Flag        VARCHAR2,
                       X_Depreciate_Flag                VARCHAR2,
                       X_Disabled_Flag                  VARCHAR2 DEFAULT NULL, --HH ed
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Date_Ineffective               DATE DEFAULT NULL,
                       X_Transaction_Header_Id_In       NUMBER,
                       X_Transaction_Header_Id_Out      NUMBER DEFAULT NULL,
                       X_Itc_Amount_Id                  NUMBER DEFAULT NULL,
                       X_Itc_Amount                     NUMBER DEFAULT NULL,
                       X_Retirement_Id                  NUMBER DEFAULT NULL,
                       X_Tax_Request_Id                 NUMBER DEFAULT NULL,
                       X_Itc_Basis                      NUMBER DEFAULT NULL,
                       X_Basic_Rate                     NUMBER DEFAULT NULL,
                       X_Adjusted_Rate                  NUMBER DEFAULT NULL,
                       X_Bonus_Rule                     VARCHAR2 DEFAULT NULL,
                       X_Ceiling_Name                   VARCHAR2 DEFAULT NULL,
                       X_Recoverable_Cost               NUMBER,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Adjusted_Capacity              NUMBER DEFAULT NULL,
                       X_Fully_Rsvd_Revals_Counter      NUMBER DEFAULT NULL,
                       X_Idled_Flag                     VARCHAR2 DEFAULT NULL,
                       X_Period_Counter_Capitalized     NUMBER DEFAULT NULL,
                       X_PC_Fully_Reserved              NUMBER DEFAULT NULL,
                       X_Period_Counter_Fully_Retired   NUMBER DEFAULT NULL,
                       X_Production_Capacity            NUMBER DEFAULT NULL,
                       X_Reval_Amortization_Basis       NUMBER DEFAULT NULL,
                       X_Reval_Ceiling                  NUMBER DEFAULT NULL,
                       X_Unit_Of_Measure                VARCHAR2 DEFAULT NULL,
                       X_Unrevalued_Cost                NUMBER,
                       X_Annual_Deprn_Rounding_Flag     VARCHAR2 DEFAULT NULL,
                       X_Percent_Salvage_Value          NUMBER DEFAULT NULL,
                       X_Allowed_Deprn_Limit            NUMBER DEFAULT NULL,
                       X_Allowed_Deprn_Limit_Amount     NUMBER DEFAULT NULL,
                       X_Period_Counter_Life_Complete   NUMBER DEFAULT NULL,
                       X_Adjusted_Recoverable_Cost      NUMBER DEFAULT NULL,
/* syoung: next new columns for short tax years */
                       X_Short_Fiscal_Year_Flag         VARCHAR2 DEFAULT NULL,
                       X_Conversion_Date                DATE DEFAULT NULL,
                       X_Orig_Deprn_Start_Date          DATE DEFAULT NULL,
                       X_Remaining_Life1                NUMBER DEFAULT NULL,
                       X_Remaining_Life2                NUMBER DEFAULT NULL,
                       X_Old_Adj_Cost                   NUMBER DEFAULT NULL,
                       X_Formula_Factor                 NUMBER DEFAULT NULL,
/* syoung: up to here */
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
                       X_global_attribute_category      VARCHAR2 DEFAULT NULL,
                       X_group_asset_id                 NUMBER   DEFAULT NULL,
-- new group fields
                       X_salvage_type                   VARCHAR2 DEFAULT NULL,
                       X_deprn_limit_type               VARCHAR2 DEFAULT NULL,
                       X_over_depreciate_option         VARCHAR2 DEFAULT NULL,
                       X_super_group_id                 NUMBER   DEFAULT NULL,
                       X_reduction_rate                 NUMBER   DEFAULT NULL,
                       X_reduce_addition_flag           VARCHAR2 DEFAULT NULL,
                       X_reduce_adjustment_flag         VARCHAR2 DEFAULT NULL,
                       X_reduce_retirement_flag         VARCHAR2 DEFAULT NULL,
                       X_recognize_gain_loss            VARCHAR2 DEFAULT NULL,
                       X_recapture_reserve_flag         VARCHAR2 DEFAULT NULL,
                       X_limit_proceeds_flag            VARCHAR2 DEFAULT NULL,
                       X_terminal_gain_loss             VARCHAR2 DEFAULT NULL,
                       X_tracking_method                VARCHAR2 DEFAULT NULL,
                       X_allocate_to_fully_rsv_flag     VARCHAR2 DEFAULT NULL,
                       X_allocate_to_fully_ret_flag     VARCHAR2 DEFAULT NULL,
                       X_exclude_fully_rsv_flag         VARCHAR2 DEFAULT NULL,
                       X_excess_allocation_option       VARCHAR2 DEFAULT NULL,
                       X_depreciation_option            VARCHAR2 DEFAULT NULL,
                       X_member_rollup_flag             VARCHAR2 DEFAULT NULL,
                       X_ytd_proceeds                   NUMBER   DEFAULT NULL,
                       X_ltd_proceeds                   NUMBER   DEFAULT NULL,
                       X_eofy_reserve                   NUMBER   DEFAULT NULL,
                       X_cip_cost                       NUMBER   DEFAULT NULL,
                       X_terminal_gain_loss_amount      NUMBER   DEFAULT NULL,
                       X_ltd_cost_of_removal            NUMBER   DEFAULT NULL,
                       X_exclude_proceeds_from_basis    VARCHAR2 DEFAULT NULL,
                       X_retirement_deprn_option        VARCHAR2 DEFAULT NULL,
                       X_terminal_gain_loss_flag        VARCHAR2 DEFAULT NULL,
                       X_contract_id                    NUMBER   DEFAULT NULL, -- Bug:8240522
                       X_cash_generating_unit_id        NUMBER   DEFAULT NULL,
		       X_extended_deprn_flag            VARCHAR2 DEFAULT NULL, -- Japan Tax Phase3
		       X_extended_depreciation_period   NUMBER   DEFAULT NULL, -- Japan Tax Phase3
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER,
                       X_Return_Status              OUT NOCOPY BOOLEAN,
                       X_Calling_Fn                     VARCHAR2,
		     X_nbv_at_switch                   NUMBER   DEFAULT NULL,  -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
		     X_prior_deprn_limit_type        VARCHAR2 DEFAULT NULL,
		     X_prior_deprn_limit_amount      NUMBER   DEFAULT NULL,
		     X_prior_deprn_limit             NUMBER   DEFAULT NULL,
		     X_period_counter_fully_rsrved    NUMBER   DEFAULT NULL,
		     --X_extended_depreciation_period   NUMBER   DEFAULT NULL,
		     X_prior_deprn_method            VARCHAR2 DEFAULT NULL,
		     X_prior_life_in_months          NUMBER   DEFAULT NULL,
		     X_prior_basic_rate              NUMBER   DEFAULT NULL,
		     X_prior_adjusted_rate           NUMBER   DEFAULT NULL, -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End
		     X_period_counter_fully_extend   NUMBER   DEFAULT NULL  -- Bug 7576755
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Book_Type_Code                   VARCHAR2,
                     X_Asset_Id                         NUMBER,
                     X_Date_Placed_In_Service           DATE,
                     X_Date_Effective                   DATE,
                     X_Deprn_Start_Date                 DATE,
                     X_Deprn_Method_Code                VARCHAR2,
                     X_Life_In_Months                   NUMBER DEFAULT NULL,
                     X_Rate_Adjustment_Factor           NUMBER,
                     X_Adjusted_Cost                    NUMBER,
                     X_Cost                             NUMBER,
                     X_Original_Cost                    NUMBER,
                     X_Salvage_Value                    NUMBER,
                     X_Prorate_Convention_Code          VARCHAR2,
                     X_Prorate_Date                     DATE,
                     X_Cost_Change_Flag                 VARCHAR2,
                     X_Adjustment_Required_Status       VARCHAR2,
                     X_Capitalize_Flag                  VARCHAR2,
                     X_Retirement_Pending_Flag          VARCHAR2,
                     X_Depreciate_Flag                  VARCHAR2,
                     X_Disabled_Flag                    VARCHAR2 DEFAULT NULL, -- HH
                     X_Date_Ineffective                 DATE DEFAULT NULL,
                     X_Transaction_Header_Id_In         NUMBER,
                     X_Transaction_Header_Id_Out        NUMBER DEFAULT NULL,
                     X_Itc_Amount_Id                    NUMBER DEFAULT NULL,
                     X_Itc_Amount                       NUMBER DEFAULT NULL,
                     X_Retirement_Id                    NUMBER DEFAULT NULL,
                     X_Tax_Request_Id                   NUMBER DEFAULT NULL,
                     X_Itc_Basis                        NUMBER DEFAULT NULL,
                     X_Basic_Rate                       NUMBER DEFAULT NULL,
                     X_Adjusted_Rate                    NUMBER DEFAULT NULL,
                     X_Bonus_Rule                       VARCHAR2 DEFAULT NULL,
                     X_Ceiling_Name                     VARCHAR2 DEFAULT NULL,
                     X_Recoverable_Cost                 NUMBER,
                     X_Adjusted_Capacity                NUMBER DEFAULT NULL,
                     X_Fully_Rsvd_Revals_Counter        NUMBER DEFAULT NULL,
                     X_Idled_Flag                       VARCHAR2 DEFAULT NULL,
                     X_Period_Counter_Capitalized       NUMBER DEFAULT NULL,
                     X_PC_Fully_Reserved                NUMBER DEFAULT NULL,
                     X_Period_Counter_Fully_Retired     NUMBER DEFAULT NULL,
                     X_Production_Capacity              NUMBER DEFAULT NULL,
                     X_Reval_Amortization_Basis         NUMBER DEFAULT NULL,
                     X_Reval_Ceiling                    NUMBER DEFAULT NULL,
                     X_Unit_Of_Measure                  VARCHAR2 DEFAULT NULL,
                     X_Unrevalued_Cost                  NUMBER,
                     X_Annual_Deprn_Rounding_Flag       VARCHAR2 DEFAULT NULL,
                     X_Percent_Salvage_Value            NUMBER DEFAULT NULL,
                     X_Allowed_Deprn_Limit              NUMBER DEFAULT NULL,
                     X_Allowed_Deprn_Limit_Amount       NUMBER DEFAULT NULL,
                     X_Period_Counter_Life_Complete     NUMBER DEFAULT NULL,
                     X_Adjusted_Recoverable_Cost        NUMBER DEFAULT NULL,
                     X_Cash_Generating_Unit_Id          NUMBER DEFAULT NULL,
                     X_Calling_Fn                       VARCHAR2
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2 DEFAULT NULL,
                       X_Book_Type_Code                 VARCHAR2 DEFAULT NULL,
                       X_Asset_Id                       NUMBER   DEFAULT NULL,
                       X_Date_Placed_In_Service         DATE     DEFAULT NULL,
                       X_Date_Effective                 DATE     DEFAULT NULL,
                       X_Deprn_Start_Date               DATE     DEFAULT NULL,
                       X_Deprn_Method_Code              VARCHAR2 DEFAULT NULL,
                       X_Life_In_Months                 NUMBER   DEFAULT NULL,
                       X_Rate_Adjustment_Factor         NUMBER   DEFAULT NULL,
                       X_Adjusted_Cost                  NUMBER   DEFAULT NULL,
                       X_Cost                           NUMBER   DEFAULT NULL,
                       X_Original_Cost                  NUMBER   DEFAULT NULL,
                       X_Salvage_Value                  NUMBER   DEFAULT NULL,
                       X_Prorate_Convention_Code        VARCHAR2 DEFAULT NULL,
                       X_Prorate_Date                   DATE     DEFAULT NULL,
                       X_Cost_Change_Flag               VARCHAR2 DEFAULT NULL,
                       X_Adjustment_Required_Status     VARCHAR2 DEFAULT NULL,
                       X_Capitalize_Flag                VARCHAR2 DEFAULT NULL,
                       X_Retirement_Pending_Flag        VARCHAR2 DEFAULT NULL,
                       X_Depreciate_Flag                VARCHAR2 DEFAULT NULL,
                       X_Disabled_Flag                  VARCHAR2 DEFAULT NULL, --HH ed.
                       X_Last_Update_Date               DATE     DEFAULT NULL,
                       X_Last_Updated_By                NUMBER   DEFAULT NULL,
                       X_Date_Ineffective               DATE     DEFAULT NULL,
                       X_Transaction_Header_Id_In       NUMBER   DEFAULT NULL,
                       X_Transaction_Header_Id_Out      NUMBER   DEFAULT NULL,
                       X_Itc_Amount_Id                  NUMBER   DEFAULT NULL,
                       X_Itc_Amount                     NUMBER   DEFAULT NULL,
                       X_Retirement_Id                  NUMBER   DEFAULT NULL,
                       X_Tax_Request_Id                 NUMBER   DEFAULT NULL,
                       X_Itc_Basis                      NUMBER   DEFAULT NULL,
                       X_Basic_Rate                     NUMBER   DEFAULT NULL,
                       X_Adjusted_Rate                  NUMBER   DEFAULT NULL,
                       X_Bonus_Rule                     VARCHAR2 DEFAULT NULL,
                       X_Ceiling_Name                   VARCHAR2 DEFAULT NULL,
                       X_Recoverable_Cost               NUMBER   DEFAULT NULL,
                       X_Last_Update_Login              NUMBER   DEFAULT NULL,
                       X_Adjusted_Capacity              NUMBER   DEFAULT NULL,
                       X_Fully_Rsvd_Revals_Counter      NUMBER   DEFAULT NULL,
                       X_Idled_Flag                     VARCHAR2 DEFAULT NULL,
                       X_Period_Counter_Capitalized     NUMBER   DEFAULT NULL,
                       X_PC_Fully_Reserved              NUMBER   DEFAULT NULL,
                       X_Period_Counter_Fully_Retired   NUMBER   DEFAULT NULL,
                       X_Production_Capacity            NUMBER   DEFAULT NULL,
                       X_Reval_Amortization_Basis       NUMBER   DEFAULT NULL,
                       X_Reval_Ceiling                  NUMBER   DEFAULT NULL,
                       X_Unit_Of_Measure                VARCHAR2 DEFAULT NULL,
                       X_Unrevalued_Cost                NUMBER   DEFAULT NULL,
                       X_Annual_Deprn_Rounding_Flag     VARCHAR2 DEFAULT NULL,
                       X_Percent_Salvage_Value          NUMBER   DEFAULT NULL,
                       X_Allowed_Deprn_Limit            NUMBER   DEFAULT NULL,
                       X_Allowed_Deprn_Limit_Amount     NUMBER   DEFAULT NULL,
                       X_Period_Counter_Life_Complete   NUMBER   DEFAULT NULL,
                       X_Adjusted_Recoverable_Cost      NUMBER   DEFAULT NULL,
                       X_Group_Asset_Id                 NUMBER   DEFAULT NULL,
-- new group fields
                       X_salvage_type                   VARCHAR2 DEFAULT NULL,
                       X_deprn_limit_type               VARCHAR2 DEFAULT NULL,
                       X_over_depreciate_option         VARCHAR2 DEFAULT NULL,
                       X_super_group_id                 NUMBER DEFAULT NULL,
                       X_reduction_rate                 NUMBER DEFAULT NULL,
                       X_reduce_addition_flag           VARCHAR2 DEFAULT NULL,
                       X_reduce_adjustment_flag         VARCHAR2 DEFAULT NULL,
                       X_reduce_retirement_flag         VARCHAR2 DEFAULT NULL,
                       X_recognize_gain_loss            VARCHAR2 DEFAULT NULL,
                       X_recapture_reserve_flag         VARCHAR2 DEFAULT NULL,
                       X_limit_proceeds_flag            VARCHAR2 DEFAULT NULL,
                       X_terminal_gain_loss             VARCHAR2 DEFAULT NULL,
                       X_tracking_method                VARCHAR2 DEFAULT NULL,
                       X_allocate_to_fully_rsv_flag     VARCHAR2 DEFAULT NULL,
                       X_allocate_to_fully_ret_flag     VARCHAR2 DEFAULT NULL,
                       X_exclude_fully_rsv_flag         VARCHAR2 DEFAULT NULL,
                       X_excess_allocation_option       VARCHAR2 DEFAULT NULL,
                       X_depreciation_option            VARCHAR2 DEFAULT NULL,
                       X_member_rollup_flag             VARCHAR2 DEFAULT NULL,
                       X_ytd_proceeds                   NUMBER   DEFAULT NULL,
                       X_ltd_proceeds                   NUMBER   DEFAULT NULL,
                       X_eofy_reserve                   NUMBER   DEFAULT NULL,
                       X_cip_cost                       NUMBER   DEFAULT NULL,
                       X_terminal_gain_loss_amount      NUMBER   DEFAULT NULL,
                       X_ltd_cost_of_removal            NUMBER   DEFAULT NULL,
                       X_exclude_proceeds_from_basis    VARCHAR2 DEFAULT NULL,
                       X_retirement_deprn_option        VARCHAR2 DEFAULT NULL,
                       X_terminal_gain_loss_flag        VARCHAR2 DEFAULT NULL,
                       X_Formula_Factor                 NUMBER   DEFAULT NULL,
                       X_cash_generating_unit_id        NUMBER   DEFAULT NULL,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER,
                       X_Calling_Fn                     VARCHAR2,
		     X_nbv_at_switch                   NUMBER   DEFAULT NULL,   -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
		     X_prior_deprn_limit_type        VARCHAR2 DEFAULT NULL,
		     X_prior_deprn_limit_amount      NUMBER   DEFAULT NULL,
		     X_prior_deprn_limit             NUMBER   DEFAULT NULL,
		     X_period_counter_fully_rsrved    NUMBER   DEFAULT NULL,
		     X_extended_depreciation_period   NUMBER   DEFAULT NULL,
		     X_prior_deprn_method            VARCHAR2 DEFAULT NULL,
		     X_prior_life_in_months          NUMBER   DEFAULT NULL,
		     X_prior_basic_rate              NUMBER   DEFAULT NULL,
		     X_prior_adjusted_rate           NUMBER   DEFAULT NULL  -- -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Delete_Row(X_Rowid                          VARCHAR2 DEFAULT NULL,
                       X_Transaction_Header_Id_In       NUMBER DEFAULT NULL,
                       X_Asset_Id                       NUMBER DEFAULT NULL,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
                       X_Calling_Fn                     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Reactivate_Row(X_Transaction_Header_Id_Out  NUMBER,
                           X_mrc_sob_type_code          VARCHAR2 DEFAULT 'P',
                           X_set_of_books_id                NUMBER ,
                           X_Calling_Fn                 VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Deactivate_Row(X_asset_id                   NUMBER,
                           X_book_type_code             VARCHAR2,
                           X_transaction_header_id_out  NUMBER,
                           X_date_ineffective           DATE DEFAULT SYSDATE,
                           X_mrc_sob_type_code          VARCHAR2 DEFAULT 'P',
                           X_set_of_books_id                NUMBER ,
                           X_Calling_Fn                 VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_BOOKS_PKG;

/
