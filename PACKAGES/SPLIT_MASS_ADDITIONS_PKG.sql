--------------------------------------------------------
--  DDL for Package SPLIT_MASS_ADDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."SPLIT_MASS_ADDITIONS_PKG" AUTHID CURRENT_USER as
/* $Header: faxisps.pls 120.1 2005/06/24 02:02:44 lson noship $ */

  PROCEDURE Split_Mass_Additions(X_Mass_Addition_ID			NUMBER DEFAULT NULL,
				 X_book_type_Code			VARCHAR2 DEFAULT NULL,
				 X_Currency_Code			VARCHAR2 DEFAULT NULL,
				 X_Parent_Unit_Cost_fa			NUMBER DEFAULT NULL,
				 X_Parent_Unit_Cost_ap			NUMBER DEFAULT NULL,
				 X_Parent_Salvage_Value  		NUMBER DEFAULT NULL,
				 X_Parent_Prod_Capacity  		NUMBER DEFAULT NULL,
				 X_Parent_Reval_Amort_B  	NUMBER DEFAULT NULL,
				 X_Parent_Reval_Reserve     		NUMBER DEFAULT NULL,
				 X_Parent_Unrevalued_Cost   		NUMBER DEFAULT NULL,
				 X_Parent_Ytd_Rev_Dep_Exp 	NUMBER DEFAULT NULL,
				 X_Parent_Deprn_Reserve			NUMBER DEFAULT NULL,
				 X_Parent_YTD_Deprn			NUMBER DEFAULT NULL,
				 X_Parent_Beginning_NBV			NUMBER DEFAULT NULL,
				 X_Total_fa_Units			NUMBER DEFAULT NULL,
				 X_Merged_Code				VARCHAR2 DEFAULT NULL,
				 X_Split_Code				VARCHAR2 DEFAULT NULL,
				 p_log_level_rec                     IN FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE UNDO_SPLIT_MASS_ADDITIONS (X_Mass_Addition_ID	NUMBER DEFAULT NULL,
				      X_Merged_Code		Varchar2 DEFAULT NULL,
				      p_log_level_rec        IN FA_API_TYPES.log_level_rec_type default null);

  Procedure Insert_Split_Child(I_Mass_Additions_ID 		NUMBER DEFAULT NULL,
				I_New_Mass_Addition_Id 		NUMBER DEFAULT NULL,
				I_Split_Parent_MAss_Add_Id	NUMBER DEFAULT NULL,
				I_Merge_Parent_MAss_Add_ID	NUMBER DEFAULT NULL,
				I_FA_COST			NUMBER DEFAULT NULL,
			  	I_PA_COST			NUMBER DEFAULT NULL,
				I_Salvage_Value			NUMBER DEFAULT NULL,
				I_Production_Capacity  		NUMBER DEFAULT NULL,
				I_Reval_Amortization_Basis  	NUMBER DEFAULT NULL,
				I_Reval_Reserve     		NUMBER DEFAULT NULL,
				I_Unrevalued_Cost   		NUMBER DEFAULT NULL,
				I_Ytd_Reval_Deprn_Expense  	NUMBER DEFAULT NULL,
        			I_Deprn_Reserve			NUMBER DEFAULT NULL,
				I_YTD_Deprn			NUMBER DEFAULT NULL,
				I_Beginning_NBV			NUMBER DEFAULT NULL,
				I_Total_fa_Units		NUMBER DEFAULT NULL,
				I_Merge_Child_fa_Units	        NUMBER DEFAULT NULL,
	  		 	I_Sum_Units		        VARCHAR2 DEFAULT NULL,
				p_log_level_rec              IN FA_API_TYPES.log_level_rec_type default null);

END SPLIT_MASS_ADDITIONS_PKG;

 

/
