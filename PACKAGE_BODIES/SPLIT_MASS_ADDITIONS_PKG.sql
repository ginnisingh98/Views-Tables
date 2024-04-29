--------------------------------------------------------
--  DDL for Package Body SPLIT_MASS_ADDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SPLIT_MASS_ADDITIONS_PKG" as
/* $Header: faxispb.pls 120.4 2005/07/25 10:03:46 yyoon ship $ */

  PROCEDURE Split_Mass_additions(X_Mass_Addition_ID	NUMBER DEFAULT NULL,
				 X_book_type_Code	VARCHAR2 DEFAULT NULL,
				 X_Currency_Code	VARCHAR2 DEFAULT NULL,
				 X_Parent_Unit_Cost_fa	NUMBER Default NULL,
				 X_Parent_Unit_Cost_ap	NUMBER Default NULL,
				 X_Parent_Salvage_Value   NUMBER Default NULL,
				 X_Parent_Prod_Capacity  NUMBER Default NULL,
				 X_Parent_Reval_Amort_B  NUMBER DEFAULT NULL,
				 X_Parent_Reval_Reserve     NUMBER DEFAULT NULL,
				 X_Parent_Unrevalued_Cost   NUMBER DEFAULT NULL,
				 X_Parent_Ytd_Rev_Dep_Exp NUMBER DEFAULT NULL,
				 X_Parent_Deprn_Reserve	NUMBER DEFAULT NULL,
				 X_Parent_YTD_Deprn	NUMBER DEFAULT NULL,
				 X_Parent_Beginning_NBV	NUMBER DEFAULT NULL,
				 X_Total_fa_Units	NUMBER Default NULL,
				 X_Merged_Code		VARCHAR2 DEFAULT NULL,
				 X_Split_Code		VARCHAR2 DEFAULT NULL,
				p_log_level_rec      IN FA_API_TYPES.log_level_rec_type default null) Is
	Child_Unit_cost_fa			NUMBER DEFAULT NULL;
	Child_Unit_cost_ap			NUMBER DEFAULT NULL;
	Child_Salvage_Value			NUMBER DEFAULT NULL;
	Child_Prod_Cap				NUMBER DEFAULT NULL;
	Child_Rev_Amort_B			NUMBER DEFAULT NULL;
	Child_Reval_Reserve			NUMBER DEFAULT NULL;
	Child_Unrev_Cost			NUMBER DEFAULT NULL;
	Child_Ytd_RDE				NUMBER DEFAULT NULL;
	Child_Deprn_Reserve			NUMBER DEFAULT NULL;
	Child_YTD_Deprn				NUMBER DEFAULT NULL;
	Child_Beginning_NBV			NUMBER DEFAULT NULL;
	Child_Total_fa_Units       		NUMBER DEFAULT NULL;
	Child_Merged_Code			VARCHAR2(3) DEFAULT NULL;
	merge_parent_mass_add_id		NUMBER DEFAULT NULL;
	Child_Mass_Add_ID			NUMBER DEFAULT NULL;
	precision				NUMBER DEFAULT NULL;
	ext_precision				NUMBER DEFAULT NULL;
	min_acct_unit				NUMBER DEFAULT NULL;
	Total_Child_Records 			NUMBER DEFAULT NULL;
	Total_Merged_Children_Cost_fa		NUMBER DEFAULT NULL;
	Total_Merged_Children_cost_ap		NUMBER DEFAULT NULL;
	Total_Merged_Salvage_Value		NUMBER DEFAULT NULL;
	Total_Merged_Prod_Cap			NUMBER DEFAULT NULL;
	Total_Merged_Rev_Amort_B		NUMBER DEFAULT NULL;
	Total_Merged_Reval_Reserve		NUMBER DEFAULT NULL;
	Total_Merged_Unrev_Cost			NUMBER DEFAULT NULL;
	Total_Merged_Ytd_RDE			NUMBER DEFAULT NULL;
	Total_Merged_Deprn_Reserve		NUMBER DEFAULT NULL;
	Total_Merged_YTD_Deprn			NUMBER DEFAULT NULL;
	Total_Merged_Beginning_NBV		NUMBER DEFAULT NULL;
	Total_Asset_Cost_Fa			NUMBER DEFAULT NULL;
	Total_Asset_Cost_ap			NUMBER DEFAULT NULL;
	Total_Asset_Salvage_Value		NUMBER DEFAULT NULL;
	Total_Asset_Prod_Cap			NUMBER DEFAULT NULL;
	Total_Asset_Rev_Amort_B			NUMBER DEFAULT NULL;
	Total_Asset_Reval_Reserve		NUMBER DEFAULT NULL;
	Total_Asset_Unrev_Cost			NUMBER DEFAULT NULL;
	Total_Asset_Ytd_RDE			NUMBER DEFAULT NULL;
	Total_Asset_Deprn_Reserve		NUMBER DEFAULT NULL;
	Total_Asset_YTD_Deprn			NUMBER DEFAULT NULL;
	Total_Asset_Beginning_NBV		NUMBER DEFAULT NULL;
	Total_Split_Unit_Cost_Fa		NUMBER DEFAULT NULL;
	Total_Split_Unit_Cost_ap		NUMBER DEFAULT NULL;
	Total_Split_Salvage_Value		NUMBER DEFAULT NULL;
	Total_Split_Prod_Cap			NUMBER DEFAULT NULL;
	Total_Split_Rev_Amort_B			NUMBER DEFAULT NULL;
	Total_Split_Reval_Reserve		NUMBER DEFAULT NULL;
	Total_Split_Unrev_Cost			NUMBER DEFAULT NULL;
	Total_Split_Ytd_RDE			NUMBER DEFAULT NULL;
	Total_Split_Deprn_Reserve		NUMBER DEFAULT NULL;
	Total_Split_YTD_Deprn			NUMBER DEFAULT NULL;
	Total_Split_Beginning_NBV		NUMBER DEFAULT NULL;
	Last_Total_Split_Unit_Cost_fa		NUMBER DEFAULT NULL;
	Last_Total_Split_Unit_Cost_ap		NUMBER DEFAULT NULL;
	Last_Total_Split_Salvage_Val		NUMBER DEFAULT NULL;
	Last_Total_Split_Prod_Cap		NUMBER DEFAULT NULL;
	Last_Total_Split_Rev_Amort_B		NUMBER DEFAULT NULL;
	Last_Total_Split_Reval_Res		NUMBER DEFAULT NULL;
	Last_Total_Split_Unrev_Cost		NUMBER DEFAULT NULL;
	Last_Total_Split_Ytd_RDE		NUMBER DEFAULT NULL;
	Last_Total_Split_Deprn_Reserve		NUMBER DEFAULT NULL;
	Last_Total_Split_YTD_Deprn		NUMBER DEFAULT NULL;
	Last_Total_Split_Beginning_NBV		NUMBER DEFAULT NULL;
	Split_Unit_Cost_fa			NUMBER DEFAULT NULL;
	Split_Unit_cost_ap			NUMBER DEFAULT NULL;
	Split_Salvage_Value			NUMBER DEFAULT NULL;
	Split_Prod_Cap				NUMBER DEFAULT NULL;
	Split_Rev_Amort_B			NUMBER DEFAULT NULL;
	Split_Reval_Reserve			NUMBER DEFAULT NULL;
	Split_Unrev_Cost			NUMBER DEFAULT NULL;
	Split_Ytd_RDE				NUMBER DEFAULT NULL;
	Split_Deprn_Reserve			NUMBER DEFAULT NULL;
	Split_YTD_Deprn				NUMBER DEFAULT NULL;
	Split_Beginning_NBV			NUMBER DEFAULT NULL;
	Record_Num				NUMBER DEFAULT NULL;
	Temp_Split_Unit_Cost_fa			NUMBER DEFAULT NULL;
	Temp_Split_Unit_cost_ap			NUMBER DEFAULT NULL;
	Temp_Split_Salvage_Value		NUMBER DEFAULT NULL;
	Temp_Split_Prod_Cap			NUMBER DEFAULT NULL;
	Temp_Split_Rev_Amort_B			NUMBER DEFAULT NULL;
	Temp_Split_Reval_Reserve		NUMBER DEFAULT NULL;
	Temp_Split_Unrev_Cost			NUMBER DEFAULT NULL;
	Temp_Split_Ytd_RDE			NUMBER DEFAULT NULL;
	Temp_Split_Deprn_Reserve		NUMBER DEFAULT NULL;
	Temp_Split_YTD_Deprn			NUMBER DEFAULT NULL;
	Temp_Split_Beginning_NBV		NUMBER DEFAULT NULL;
	Last_Split_Unit_Cost_fa			NUMBER DEFAULT NULL;
	Last_Split_Unit_Cost_ap			NUMBER DEFAULT NULL;
	Last_Split_Salvage_Value		NUMBER DEFAULT NULL;
	Last_Split_Prod_Cap			NUMBER DEFAULT NULL;
	Last_Split_Rev_Amort_B			NUMBER DEFAULT NULL;
	Last_Split_Reval_Reserve		NUMBER DEFAULT NULL;
	Last_Split_Unrev_Cost			NUMBER DEFAULT NULL;
	Last_Split_Ytd_RDE			NUMBER DEFAULT NULL;
	Last_Split_Deprn_Reserve		NUMBER DEFAULT NULL;
	Last_Split_YTD_Deprn			NUMBER DEFAULT NULL;
	Last_Split_Beginning_NBV		NUMBER DEFAULT NULL;
	Child_Rec_Num				NUMBER DEFAULT NULL;
	New_Parent_Mass_Addition_Id		NUMBER DEFAULT NULL;
	New_Child_Mass_Addition_Id		NUMBER DEFAULT NULL;
	Child_Split_Unit_Cost_Fa		NUMBER DEFAULT NULL;
	Child_Split_Unit_Cost_Ap		NUMBER DEFAULT NULL;
	Child_Split_Salvage_Value		NUMBER DEFAULT NULL;
	Child_Split_Prod_Cap			NUMBER DEFAULT NULL;
	Child_Split_Rev_Amort_B			NUMBER DEFAULT NULL;
	Child_Split_Reval_Reserve		NUMBER DEFAULT NULL;
	Child_Split_Unrev_Cost			NUMBER DEFAULT NULL;
	Child_Split_Ytd_RDE			NUMBER DEFAULT NULL;
	Child_Split_Deprn_Reserve		NUMBER DEFAULT NULL;
	Child_Split_YTD_Deprn			NUMBER DEFAULT NULL;
	Child_Split_Beginning_NBV		NUMBER DEFAULT NULL;


	Message_Number				Number ;
	message_text				Varchar2(80);

	Y_Merged_Child_FA_Units     Number;
	Y_zero                      Number;
	Y_Sum_Units                 Varchar2(3);


	 CURSOR SPLIT_CHILDREN_CR IS
			SELECT nvl(FIXED_ASSETS_COST, 0),
			nvl(PAYABLES_COST, 0),
			nvl(SALVAGE_VALUE, 0),
			nvl(PRODUCTION_CAPACITY, 0),
			nvl(REVAL_AMORTIZATION_BASIS, 0),
			nvl(REVAL_RESERVE, 0),
			nvl(UNREVALUED_COST, 0),
			nvl(YTD_REVAL_DEPRN_EXPENSE, 0),
			nvl(DEPRN_RESERVE, 0),
			nvl(YTD_DEPRN, 0),
			nvl(BEGINNING_NBV, 0),
			nvl(FIXED_ASSETS_UNITS, 0),
			Merged_Code,
			merge_parent_mass_additions_id,
			Mass_Addition_ID
		FROM	FA_MASS_ADDITIONS
		WHERE 	Merge_Parent_MASS_ADDITIONs_ID 	= X_mass_addition_id
			and Book_Type_Code = X_Book_Type_Code
			and  MERGED_CODE  = 'MC'
			For UPDATE ;


	CURSOR C2 is Select Fa_MAss_Additions_S.nextval From sys.dual;

	FA_NO_MERGED_CHILDREN	Exception;

  Begin


	---- Check if the Mass_Addition is a Merged_Parent


	If (X_Merged_Code = 'MP') then
		-- Get the total number of child records
		Select count(*) into Total_Child_Records
		From FA_MASS_ADDITIONS
		Where  Merge_Parent_MASS_ADDITIONS_ID = x_mass_addition_id
		and  MERGED_CODE  = 'MC';

		if Total_Child_Records = 0 then
			Raise FA_NO_MERGED_CHILDREN;
		end if;

	End IF;

	---- Check if the Mass_Addition is a Merged_Parent and SUM_UNITS
	---- We need to know what the parents original FA_UNITS are

	If (X_Merged_Code = 'MP') then

		SELECT sum_units into Y_Sum_Units
        FROM   fa_mass_additions
		WHERE  mass_addition_id = x_mass_addition_id;

		if (Y_Sum_Units = 'YES') then

            SELECT sum(fixed_assets_units) into Y_Merged_Child_FA_Units
            FROM   fa_mass_additions
            WHERE  merge_parent_mass_additions_id = x_mass_addition_id
            AND    merged_code  = 'MC';

		else
            Y_Merged_Child_FA_Units := 0;
		end if;
	end if;


	-- Get the min. currency info. using the AOL API
	-- FND_CURRENCY.GET_INFO(X_Currency_Code, precision, ext_precision, min_acct_unit);
	Select Precision, Extended_precision, MINIMUM_ACCOUNTABLE_UNIT
	 Into precision, ext_precision, min_acct_unit
	from fnd_Currencies
	Where Currency_code = X_Currency_Code;



	-- Calculate the total cost of the Mass Addition, which could be different
	-- from the mass addition if MERGED_CODE = 'MP'

	if (X_Merged_Code = 'MP') then
		Select SUM(Round(ma.fixed_assets_Cost, precision)),
		       Sum(Round(ma.payables_Cost, precision)),
			Sum(Round(ma.salvage_value, precision)),
			sum(round(ma.production_capacity, precision)),
			sum(round(ma.reval_amortization_basis, precision)),
			sum(round(ma.reval_reserve, precision)),
			sum(round(ma.unrevalued_cost, precision)),
			sum(round(ma.ytd_reval_deprn_expense, precision)),
			sum(round(ma.deprn_reserve, precision)),
			sum(round(ma.ytd_deprn, precision)),
			sum(round(ma.beginning_nbv, precision))		        Into Total_Merged_Children_Cost_fa,
			     Total_Merged_Children_cost_ap,
				Total_Merged_Salvage_Value, Total_Merged_Prod_Cap,
				Total_Merged_Rev_Amort_B, Total_Merged_Reval_Reserve,
				Total_Merged_Unrev_Cost, Total_Merged_Ytd_RDE,
				Total_Merged_Deprn_Reserve, Total_Merged_YTD_Deprn,
				Total_Merged_Beginning_NBV
		From FA_MAss_Additions ma
		where ma.merge_parent_mass_additions_id = x_mass_addition_id;

		Total_Asset_Cost_Fa := Total_Merged_Children_Cost_fa + X_Parent_Unit_Cost_Fa;
		Total_Asset_Cost_Ap := Total_Merged_Children_cost_ap + X_Parent_Unit_Cost_Ap;
		Total_Asset_Salvage_Value := Total_Merged_Salvage_Value + X_Parent_Salvage_Value;
		Total_Asset_Prod_Cap := Total_Merged_Prod_Cap + X_Parent_Prod_Capacity;
		Total_Asset_Rev_Amort_B := Total_Merged_Rev_Amort_B + X_Parent_Reval_Amort_B;
		Total_Asset_Reval_Reserve := Total_Merged_Reval_Reserve + X_Parent_Reval_Reserve;
		Total_Asset_Unrev_Cost := Total_Merged_Unrev_Cost + X_Parent_Unrevalued_Cost;
		Total_Asset_Ytd_RDE := Total_Merged_Ytd_RDE + X_Parent_Ytd_Rev_Dep_Exp;
		Total_Asset_Deprn_Reserve := Total_Merged_Deprn_Reserve + X_Parent_Deprn_Reserve;
		Total_Asset_YTD_Deprn := Total_Merged_YTD_Deprn + X_Parent_YTD_Deprn;
		Total_Asset_Beginning_NBV := Total_Merged_Beginning_NBV + X_Parent_Beginning_NBV;


	else
		Total_asset_Cost_Fa := X_PArent_Unit_Cost_Fa;
		Total_Asset_Cost_Ap := X_PArent_Unit_Cost_Ap;
		Total_Asset_Salvage_Value := X_Parent_Salvage_Value;
		Total_Asset_Prod_Cap := X_Parent_Prod_Capacity;
		Total_Asset_Rev_Amort_B := X_Parent_Reval_Amort_B;
		Total_Asset_Reval_Reserve := X_Parent_Reval_Reserve;
		Total_Asset_Unrev_Cost := X_Parent_Unrevalued_Cost;
		Total_Asset_Ytd_RDE := X_Parent_Ytd_Rev_Dep_Exp;
		Total_Asset_Deprn_Reserve := X_Parent_Deprn_Reserve;
		Total_Asset_YTD_Deprn := X_Parent_YTD_Deprn;
		Total_Asset_Beginning_NBV := X_Parent_Beginning_NBV;
	end if;

	-- Calculate the Asset cost which will be posted for each individual
	-- asset line.


	Total_Split_Unit_Cost_Fa  := Round((Total_Asset_Cost_fa / X_Total_fa_Units), precision);
	Total_Split_Unit_Cost_Ap  := Round((Total_Asset_Cost_ap / X_Total_fa_Units), precision);
	Total_Split_Salvage_Value := Round((Total_Asset_Salvage_Value / X_Total_fa_Units), precision);
	Total_Split_Prod_Cap := Round((Total_Asset_Prod_Cap / X_Total_fa_Units), precision);
	Total_Split_Rev_Amort_B := Round((Total_Asset_Rev_Amort_B / X_Total_fa_Units), precision);
	Total_Split_Reval_Reserve := Round((Total_Asset_Reval_Reserve / X_Total_fa_Units), precision);
	Total_Split_Unrev_Cost := Round((Total_Asset_Unrev_Cost / X_Total_fa_Units), precision);
	Total_Split_Ytd_RDE := Round((Total_Asset_Ytd_RDE / X_Total_fa_Units), precision);
	Total_Split_Deprn_Reserve := Round((Total_Asset_Deprn_Reserve / X_Total_fa_Units), precision);
	Total_Split_YTD_Deprn := Round((Total_Asset_YTD_Deprn / X_Total_fa_Units), precision);
	Total_Split_Beginning_NBV := Round((Total_Asset_Beginning_NBV / X_Total_fa_Units), precision);


	-- To take care of the rounding problem
	Last_Total_Split_Unit_Cost_fa := Total_Asset_Cost_fa - Total_Split_Unit_Cost_Fa*(X_Total_fa_Units-1);
	Last_Total_Split_Unit_Cost_ap := Total_Asset_cost_ap - Total_Split_Unit_Cost_Ap*(X_Total_fa_Units-1);
	Last_Total_Split_Salvage_Val := Total_Asset_Salvage_Value - Total_Split_Salvage_Value*(X_Total_fa_Units-1);
	Last_Total_Split_Prod_Cap := Total_Asset_Prod_Cap - Total_Split_Prod_Cap*(X_Total_fa_Units-1);
	Last_Total_Split_Rev_Amort_B := Total_Asset_Rev_Amort_B - Total_Split_Rev_Amort_B*(X_Total_fa_Units-1);
	Last_Total_Split_Reval_Res := Total_Asset_Reval_Reserve - Total_Split_Reval_Reserve*(X_Total_fa_Units-1);
	Last_Total_Split_Unrev_Cost := Total_Asset_Unrev_Cost - Total_Split_Unrev_Cost*(X_Total_fa_Units-1);
	Last_Total_Split_Ytd_RDE := Total_Asset_Ytd_RDE - Total_Split_Ytd_RDE*(X_Total_fa_Units-1);
   /* BUG# 1349099 - correcting initialization of the YTD and NBV variables
         -- bridgway   07/07/00
   */
	Last_Total_Split_Deprn_Reserve := Total_Asset_Deprn_Reserve - Total_Split_Deprn_Reserve*(x_Total_fa_units-1);
	Last_Total_Split_YTD_Deprn := Total_Asset_YTD_Deprn - Total_Split_YTD_Deprn*(x_Total_fa_units-1);
	Last_Total_Split_Beginning_NBV := Total_Asset_Beginning_NBV - Total_Split_Beginning_NBV*(x_Total_fa_units-1);



	-- Calculate the split cost for each invoice line
	-- 1.  For the Parent line
	Split_Unit_Cost_fa := Round((X_Parent_Unit_Cost_fa/X_Total_fa_Units), precision);
	Split_Unit_cost_ap := Round((X_Parent_Unit_cost_ap/X_Total_fa_Units), precision);
	Split_Salvage_Value := round((X_Parent_Salvage_Value/X_Total_fa_Units), precision);
	Split_Prod_Cap := round((X_Parent_Prod_Capacity/X_Total_fa_Units), precision);
	Split_Rev_Amort_B :=round((X_Parent_Reval_Amort_B/X_Total_fa_Units),precision);
	Split_Reval_Reserve := round((X_Parent_Reval_Reserve/X_Total_fa_Units), precision);
	Split_Unrev_Cost := round((X_Parent_Unrevalued_Cost/X_Total_fa_Units), precision);
	Split_Ytd_RDE := round((X_Parent_Ytd_Rev_Dep_Exp/X_Total_fa_Units), precision);
	Split_Deprn_Reserve := round((X_Parent_Deprn_Reserve/X_Total_fa_Units), precision);
	Split_YTD_Deprn := round((X_Parent_YTD_Deprn/X_Total_fa_Units), precision);
	Split_Beginning_NBV := round((X_Parent_Beginning_NBV/X_Total_fa_Units), precision);


	-- Loop through to insert child records equal in number to the X_Total_fa_Units

	For record_num In 1 .. X_Total_fa_Units  Loop
		-- Create the split children.

		Temp_Split_Unit_Cost_fa  := Split_Unit_cost_fa;
	   	Temp_Split_Unit_cost_ap  := Split_Unit_cost_ap;
		Temp_Split_Salvage_Value := Split_Salvage_Value;
		Temp_Split_Prod_Cap := Split_Prod_Cap;
		Temp_Split_Rev_Amort_B := Split_Rev_Amort_B;
		Temp_Split_Reval_Reserve := Split_Reval_Reserve;
		Temp_Split_Unrev_Cost := Split_Unrev_Cost;
		Temp_Split_Ytd_RDE := Split_Ytd_RDE;
		Temp_Split_Deprn_reserve := Split_Deprn_Reserve;
		Temp_Split_YTD_Deprn := Split_YTD_Deprn;
		Temp_Split_Beginning_NBV := Split_Beginning_NBV;


		New_Parent_Mass_addition_Id := NULL;
		Open C2;
		Fetch C2 Into new_parent_mass_addition_id;
		Close C2;


		-- When the last child is being inserted check for the rounding problem
		if (record_num = X_Total_fa_Units) then
			Last_Split_Unit_Cost_fa := X_Parent_Unit_Cost_fa - Split_Unit_Cost_fa * (X_Total_fa_Units -1);
			Last_Split_Unit_cost_ap := X_Parent_Unit_cost_ap - Split_Unit_Cost_ap * (X_Total_fa_Units -1);
			Last_Split_Salvage_Value := X_Parent_Salvage_Value - Split_Salvage_Value * (X_Total_fa_Units - 1);
			Last_Split_Prod_Cap := X_Parent_Prod_Capacity - Split_Prod_Cap * (X_Total_fa_Units - 1);
			Last_Split_Rev_Amort_B := X_Parent_Reval_Amort_B - Split_Rev_Amort_B * (X_Total_fa_Units - 1);
			Last_Split_Reval_Reserve := X_Parent_Reval_Reserve - Split_Reval_Reserve * (X_Total_fa_Units - 1);
			Last_Split_Unrev_Cost := X_Parent_Unrevalued_Cost - Split_Unrev_Cost * (X_Total_fa_Units - 1);
			Last_Split_Ytd_RDE := X_Parent_Ytd_Rev_Dep_Exp - Split_Ytd_RDE * (X_Total_fa_Units - 1);
			Last_Split_Deprn_Reserve := X_Parent_Deprn_Reserve - Split_Deprn_Reserve * (X_total_fa_Units - 1);
			Last_Split_YTD_Deprn := X_Parent_YTD_Deprn - Split_YTD_Deprn * (X_total_fa_Units - 1);
			Last_Split_Beginning_NBV := X_Parent_Beginning_NBV - Split_Beginning_NBV * (X_total_fa_Units - 1);



			Temp_Split_Unit_cost_fa := Last_Split_Unit_Cost_fa;
			Temp_Split_Unit_cost_ap := Last_Split_Unit_Cost_ap;
			Temp_Split_Salvage_Value := Last_Split_Salvage_Value;
			Temp_Split_Prod_Cap := Last_Split_Prod_Cap;
			Temp_Split_Rev_Amort_B := Last_Split_Rev_Amort_B;
			Temp_Split_Reval_Reserve := Last_Split_Reval_Reserve;
			Temp_Split_Unrev_Cost := Last_Split_Unrev_Cost;
			Temp_Split_Ytd_RDE := Last_Split_Ytd_RDE;
			Temp_Split_Deprn_Reserve := Last_Split_Deprn_Reserve;
			Temp_Split_YTD_Deprn := Last_Split_YTD_Deprn;
			Temp_Split_Beginning_NBV := Last_Split_Beginning_NBV;

			 Insert_Split_Child(I_Mass_Additions_ID => X_Mass_Addition_Id,
					   I_New_Mass_Addition_Id => New_Parent_Mass_Addition_Id,
					   I_Split_Parent_MAss_Add_Id => X_Mass_Addition_Id,
					   I_Merge_Parent_MAss_Add_ID => NULL,
					   I_Fa_Cost => Last_Split_Unit_Cost_fa,
					   I_Pa_Cost => Last_Split_Unit_cost_ap,
					I_Salvage_Value => Last_Split_Salvage_Value,
					I_Production_Capacity => Last_Split_Prod_Cap,
					I_Reval_Amortization_Basis => Last_Split_Rev_Amort_B,
					I_Reval_Reserve => Last_Split_Reval_Reserve,
					I_Unrevalued_Cost => Last_Split_Unrev_Cost,
					I_Ytd_Reval_Deprn_Expense => Last_Split_Ytd_RDE,
					I_Deprn_Reserve => Last_Split_Deprn_Reserve,
					I_YTD_Deprn => Last_Split_YTD_Deprn,
					I_Beginning_NBV => Last_Split_Beginning_NBV,
	    				I_Total_fa_Units => X_Total_fa_Units,
				    I_Merge_Child_fa_Units => Y_Merged_Child_FA_Units,
				    I_Sum_Units   => Y_Sum_Units
				    ,p_log_level_rec => p_log_level_rec);

			-- Make the Total_split_Unit_cost for the last set of records being inserted as
			-- Last_Total_Split_Unit_Cost_Fa so that when the last merged child row is selected
			-- it will take into account the roundng problem

			Total_Split_Unit_Cost_Fa := Last_Total_Split_Unit_Cost_Fa;
			Total_Split_Unit_Cost_Ap := Last_Total_Split_Unit_Cost_Ap;
			Total_Split_Salvage_Value := Last_Total_Split_Salvage_Val;
			Total_Split_Prod_Cap := Last_Total_Split_Prod_Cap;
			Total_Split_Rev_Amort_B := Last_Total_Split_Rev_Amort_B;
			Total_Split_Reval_Reserve := Last_Total_Split_Reval_Res;
			Total_Split_Unrev_Cost := Last_Total_Split_Unrev_Cost;
			Total_Split_Ytd_RDE := Last_Total_Split_Ytd_RDE;
			Total_Split_Deprn_Reserve := Last_Total_Split_Deprn_Reserve;
			Total_Split_YTD_Deprn := Last_Total_Split_YTD_Deprn;
			Total_Split_Beginning_NBV := Last_Total_Split_Beginning_NBV;


		else
			-- Insert the single row.


			Insert_Split_Child(I_Mass_Additions_ID => X_Mass_Addition_Id,
					   I_New_Mass_Addition_Id => New_Parent_Mass_Addition_Id,
					   I_Split_Parent_MAss_Add_Id => X_Mass_Addition_Id,
					   I_Merge_Parent_MAss_Add_ID => NULL,
					   I_Fa_Cost => Split_Unit_Cost_fa,
					   I_Pa_Cost => Split_Unit_cost_ap,
					I_Salvage_Value => Split_Salvage_Value,
					I_Production_Capacity => Split_Prod_Cap,
					I_Reval_Amortization_Basis => Split_Rev_Amort_B,
					I_Reval_Reserve => Split_Reval_Reserve,
					I_Unrevalued_Cost => Split_Unrev_Cost,
					I_Ytd_Reval_Deprn_Expense => Split_Ytd_RDE,
    						I_Deprn_Reserve => Split_Deprn_Reserve,
					I_Ytd_Deprn => Split_Ytd_Deprn,
					I_Beginning_NBV => Split_Beginning_NBV,
				    I_Total_fa_Units => X_Total_fa_Units,
				    I_Merge_Child_fa_Units => Y_Merged_Child_FA_Units,
				    I_Sum_Units   => Y_Sum_Units
				    ,p_log_level_rec => p_log_level_rec);

		end if;

		if X_MErged_Code = 'MP' then

	        Y_zero := 0;

			OPEN SPLIT_CHILDREN_CR;
			For Child_rec_num  In 1 .. Total_Child_Records Loop
				Fetch SPLIT_CHILDREN_CR Into
					Child_Unit_Cost_fa,
					Child_Unit_Cost_ap,
					Child_Salvage_Value,
					Child_Prod_Cap,
					Child_Rev_Amort_B,
					Child_Reval_Reserve,
					Child_Unrev_Cost,
					Child_Ytd_RDE,
					Child_Deprn_Reserve,
					Child_YTD_Deprn,
					Child_Beginning_NBV,					Child_Total_fa_Units,
					Child_Merged_Code,
					Merge_Parent_Mass_Add_ID,
					Child_Mass_Add_Id;



				-- Fetch the Merged Child record and insert
				-- their corresponding	SPLIT Children
				Open C2;
				Fetch C2 Into new_Child_mass_addition_id;
				Close C2;

				Child_Split_Unit_Cost_Fa := Round((Child_Unit_Cost_fa/X_Total_fa_Units), precision);
				Child_Split_Unit_Cost_Ap := Round((Child_Unit_Cost_Ap/X_Total_fa_Units), precision);
				Child_Split_Salvage_Value := Round((Child_Salvage_Value/X_Total_fa_Units), precision);
				Child_Split_Prod_Cap := Round((Child_Prod_Cap/X_Total_fa_Units), precision);
				Child_Split_Rev_Amort_B := Round((Child_Rev_Amort_B/X_Total_fa_Units), precision);
				Child_Split_Reval_Reserve := Round((Child_Reval_Reserve/X_Total_fa_Units), precision);
				Child_Split_Unrev_Cost := Round((Child_Unrev_Cost/X_Total_fa_Units), precision);
				Child_Split_Ytd_RDE := Round((Child_Ytd_RDE/X_Total_fa_Units), precision);
				Child_Split_Deprn_Reserve := Round((Child_Deprn_Reserve/X_Total_fa_Units), precision);
				Child_Split_YTD_Deprn := Round((Child_YTD_Deprn/X_Total_fa_Units), precision);
				Child_Split_Beginning_NBV := Round((Child_Beginning_NBV/X_Total_fa_Units), precision);

				-- If the last set of records are being inserted then calculate
				-- the Last_Child_Split_Unit_Cost_fa
				if (record_num = X_Total_fa_Units) then
					Child_Split_Unit_Cost_Fa := Child_Unit_Cost_fa - Child_Split_Unit_Cost_Fa * (X_Total_fa_Units - 1);
					Child_Split_Unit_Cost_Ap := Child_Unit_Cost_Ap - Child_Split_Unit_Cost_Ap * (X_Total_fa_Units - 1);
				  Child_Split_Salvage_Value := Child_Salvage_Value - Child_Split_Salvage_Value * (X_Total_fa_Units - 1);
				  Child_Split_Prod_Cap := Child_Prod_Cap - Child_Split_Prod_Cap * (X_Total_fa_Units - 1);
				  Child_Split_Rev_Amort_B := Child_Rev_Amort_B - Child_Split_Rev_Amort_B * (X_Total_fa_Units - 1);
				  Child_Split_Reval_Reserve := Child_Reval_Reserve - Child_Split_Reval_Reserve * (X_Total_fa_Units - 1);
				  Child_Split_Unrev_Cost := Child_Unrev_Cost - Child_Split_Unrev_Cost * (X_Total_fa_Units - 1);
				  Child_Split_Ytd_RDE := Child_Ytd_RDE - Child_Split_Ytd_RDE * (X_Total_fa_Units - 1);
				  Child_Split_Deprn_Reserve := Child_Deprn_Reserve - Child_Split_Deprn_Reserve * (X_Total_fa_Units - 1);
				  Child_Split_YTD_Deprn := Child_YTD_Deprn - Child_Split_YTD_Deprn * (X_Total_fa_Units - 1);
				  Child_Split_Beginning_NBV := Child_Beginning_NBV - Child_Split_Beginning_NBV * (X_Total_fa_Units - 1);
				end if;


				If Child_rec_num = Total_Child_Records then
					Child_Split_Unit_Cost_Fa := Total_Split_Unit_Cost_Fa - Temp_Split_Unit_Cost_FA;
					Child_Split_Unit_cost_ap := Total_Split_Unit_cost_ap - Temp_Split_Unit_cost_ap;
					Child_Split_Salvage_Value := Total_Split_Salvage_Value - Temp_Split_Salvage_Value;
					Child_Split_Prod_Cap := Total_Split_Prod_Cap - Temp_Split_Prod_Cap;
					Child_Split_Rev_Amort_B := Total_Split_Rev_Amort_B - Temp_Split_Rev_Amort_B;
					Child_Split_Reval_Reserve := Total_Split_Reval_Reserve - Temp_Split_Reval_Reserve;
					Child_Split_Unrev_Cost := Total_Split_Unrev_Cost - Temp_Split_Unrev_Cost;
					Child_Split_Ytd_RDE := Total_Split_Ytd_RDE - Temp_Split_Ytd_RDE;
					Child_Split_Deprn_Reserve := Total_Split_Deprn_Reserve - Temp_Split_Deprn_Reserve;
					Child_Split_Ytd_Deprn := Total_Split_Ytd_Deprn - Temp_Split_Ytd_Deprn;
					Child_Split_Beginning_NBV := Total_Split_Beginning_NBV - Temp_Split_Beginning_NBV;


					 Insert_Split_Child(I_Mass_Additions_ID => Child_Mass_Add_Id,
					   		   I_New_Mass_Addition_Id => New_Child_Mass_Addition_Id,
					   		   I_Split_Parent_MAss_Add_Id => Child_Mass_Add_Id,
					   		   I_Merge_Parent_MAss_Add_ID => New_Parent_Mass_Addition_Id,
					   		   I_Fa_Cost => Child_Split_Unit_Cost_fa,
					   		   I_Pa_Cost => Child_Split_Unit_cost_ap,
							I_Salvage_Value => Child_Split_Salvage_Value,
							I_Production_Capacity => Child_Split_Prod_Cap,
							I_Reval_Amortization_Basis => Child_Split_Rev_Amort_B,
							I_Reval_Reserve => Child_Split_Reval_Reserve,
							I_Unrevalued_Cost => Child_Split_Unrev_Cost,
							I_Ytd_Reval_Deprn_Expense => Child_Split_Ytd_RDE,
							I_Deprn_Reserve => Child_Split_Deprn_Reserve,
							I_Ytd_Deprn => Child_Split_Ytd_Deprn,
							I_Beginning_NBV => Child_Split_Beginning_NBV,
					    I_Total_fa_Units => X_Total_fa_Units,
				            I_Merge_Child_fa_Units => Y_zero,
				            I_Sum_Units   => Y_Sum_Units
				            ,p_log_level_rec => p_log_level_rec);

					Close SPLIT_CHILDREN_CR;
				Else
					Temp_Split_Unit_Cost_fa  := Temp_Split_Unit_Cost_fa + Child_Split_Unit_Cost_fa;
	             			Temp_Split_Unit_cost_ap  := Temp_Split_Unit_cost_ap + Child_Split_Unit_cost_ap;
					Temp_Split_Salvage_Value := Temp_Split_Salvage_Value + Child_Split_Salvage_Value;
					Temp_Split_Prod_Cap := Temp_Split_Prod_Cap + Child_Split_Prod_Cap;
					Temp_Split_Rev_Amort_B := Temp_Split_Rev_Amort_B + Child_Split_Rev_Amort_B;
					Temp_Split_Reval_Reserve := Temp_Split_Reval_Reserve + Child_Split_Reval_Reserve;
					Temp_Split_Unrev_Cost := Temp_Split_Unrev_Cost + Child_Split_Unrev_Cost;
					Temp_Split_Ytd_RDE := Temp_Split_Ytd_RDE + Child_Split_Ytd_RDE;
					Temp_Split_Deprn_Reserve := Temp_Split_Deprn_Reserve + Child_Split_Deprn_Reserve;
					Temp_Split_YTD_Deprn := Temp_Split_Ytd_Deprn + Child_Split_Ytd_Deprn;
					Temp_Split_Beginning_NBV := Temp_Split_Beginning_NBV + Child_Split_Beginning_NBV;



					Insert_Split_Child(I_Mass_Additions_ID => Child_Mass_Add_Id,
					   		   I_New_Mass_Addition_Id => New_Child_Mass_Addition_Id,
					   		   I_Split_Parent_MAss_Add_Id => Child_Mass_Add_Id,
					   		   I_Merge_Parent_MAss_Add_ID => New_Parent_Mass_Addition_Id,
					   		   I_Fa_Cost => Child_Split_Unit_Cost_fa,
					   		   I_Pa_Cost => Child_Split_Unit_cost_ap,
							I_Salvage_Value => Child_Split_Salvage_Value,
							I_Production_Capacity => Child_Split_Prod_Cap,
							I_Reval_Amortization_Basis => Child_Split_Rev_Amort_B,
							I_Reval_Reserve => Child_Split_Reval_Reserve,
							I_Unrevalued_Cost => Child_Split_Unrev_Cost,
							I_Ytd_Reval_Deprn_Expense => Child_Split_Ytd_RDE,
							I_Deprn_Reserve => Child_Split_Deprn_Reserve,
							I_Ytd_Deprn => Child_Split_Ytd_Deprn,
							I_Beginning_NBV => Child_Split_Beginning_NBV,
						    I_Total_fa_Units => X_Total_fa_Units,
				            I_Merge_Child_fa_Units => Y_zero,
				            I_Sum_Units   => Y_Sum_Units
				            ,p_log_level_rec => p_log_level_rec);
				end if;
			End Loop;
		end if;
	End Loop;


	-- Update the Parent Mass Addition

	UPDATE FA_MASS_ADDITIONS
	SET
		SPLIT_CODE	= 'SP',
		SPLIT_MERGED_CODE = NVL(MERGED_CODE, 'SP'),
		POSTING_STATUS	= 'SPLIT'
	WHERE
		MASS_ADDITION_ID = X_mass_addition_id;

	-- Check if it is a MErge-Split case
	if (X_Merged_Code = 'MP') then
		UPDATE FA_MASS_ADDITIONS
		SET
			SPLIT_CODE	= 'SP',
			SPLIT_MERGED_CODE = NVL(MERGED_CODE, 'SP'),
			POSTING_STATUS	= 'SPLIT'
		WHERE
			Merge_Parent_MASS_ADDITIONs_ID = X_mass_addition_id;
	end if;

	-- Set the Split Code for the Parent to be 'SP'
	--X_SPLIT_CODE := 'SP';

	Commit;
	return;



   Exception
	WHEN FA_NO_MERGED_CHILDREN then
		FND_MESSAGE.Set_Name('OFA', 'FA_NO_MERGED_CHILDREN');
		APP_EXCEPTION.Raise_Exception;

	WHEN NO_DATA_FOUND Then
		FND_Message.Set_Name('OFA', 'FA_SQL_ERROR') ;
		FND_Message.Set_Token('PROCEDURE_NAME', 'SPLIT_MASS_ADDITIONS');
		APP_EXCEPTION.Raise_Exception;

	WHEN OTHERS Then
		--Message_number := SQlCODE;
		--Message_Text := Sqlerrm(Message_number);
		--Insert Into temp_sv Values(Message_Number, 'App_exception',Message_Text);
		--Commit;
		APP_EXCEPTION.Raise_Exception;
		-- return;


   End Split_Mass_Additions;


---
-- Enhancement 1478067 for Future Transactions:  msiddiqu 30-oct-2000
-- Added new columns in the Insert/select

   Procedure Insert_Split_Child(I_Mass_Additions_ID 		NUMBER DEFAULT NULL,
				I_New_Mass_Addition_Id 		NUMBER DEFAULT NULL,
				I_Split_Parent_MAss_Add_Id	NUMBER DEFAULT NULL,
				I_Merge_Parent_MAss_Add_ID	NUMBER DEFAULT NULL,
				I_FA_COST			NUMBER DEFAULT NULL,
			  	I_PA_COST			NUMBER DEFAULT NULL,
				I_Salvage_Value			NUMBER DEFAULT NULL,
				I_Production_Capacity		NUMBER DEFAULT NULL,
				I_Reval_Amortization_Basis	NUMBER DEFAULT NULL,
				I_Reval_Reserve			NUMBER DEFAULT NULL,
				I_Unrevalued_Cost		NUMBER DEFAULT NULL,
				I_Ytd_Reval_Deprn_Expense	NUMBER DEFAULT NULL,
				I_Deprn_Reserve			NUMBER DEFAULT NULL,
				I_YTD_Deprn			NUMBER DEFAULT NULL,
				I_Beginning_NBV			NUMBER DEFAULT NULL,
 				I_Total_fa_Units	NUMBER DEFAULT NULL,
				I_Merge_Child_fa_Units	NUMBER DEFAULT NULL,
				I_Sum_Units             VARCHAR2 DEFAULT NULL,
				p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS


  h_total_units    number;
  h_divisor_units  number;
  h_dist_id        number;

  h_parent_dist_units     number;
  h_child_dist_units      number;
  h_child_total_units     number;
  h_ccid           number;
  h_location       number;
  h_employee       number;

  h_num_dists      number;
  h_iter           number;
  h_child_units_so_far  number;

  cursor split_dists is
    select units, deprn_expense_ccid, location_id, employee_id
    from fa_massadd_distributions
    where mass_addition_id = I_Split_Parent_Mass_Add_Id;


   Begin

	INSERT INTO FA_MASS_ADDITIONS
                (MASS_ADDITION_ID,
                ASSET_NUMBER, TAG_NUMBER,
                DESCRIPTION, ASSET_CATEGORY_ID,
                MANUFACTURER_NAME, SERIAL_NUMBER,
                MODEL_NUMBER, BOOK_TYPE_CODE,
                DATE_PLACED_IN_SERVICE, FIXED_ASSETS_COST,
                PAYABLES_UNITS, FIXED_ASSETS_UNITS,
                PAYABLES_CODE_COMBINATION_ID, EXPENSE_CODE_COMBINATION_ID,
                LOCATION_ID, ASSIGNED_TO,
                FEEDER_SYSTEM_NAME, CREATE_BATCH_DATE,
                CREATE_BATCH_ID, LAST_UPDATE_DATE,
                LAST_UPDATED_BY, REVIEWER_COMMENTS,
                INVOICE_NUMBER, VENDOR_NUMBER,
                MERGE_INVOICE_NUMBER, MERGE_VENDOR_NUMBER,
                PO_VENDOR_ID, PO_NUMBER,
                POSTING_STATUS, QUEUE_NAME,
                INVOICE_DATE, INVOICE_CREATED_BY,
                INVOICE_UPDATED_BY, PAYABLES_COST,
                INVOICE_ID, PAYABLES_BATCH_NAME,
                DEPRECIATE_FLAG, PARENT_MASS_ADDITION_ID,
                PARENT_ASSET_ID, SPLIT_MERGED_CODE,
                AP_DISTRIBUTION_LINE_NUMBER, POST_BATCH_ID,
                ADD_TO_ASSET_ID, AMORTIZE_FLAG,amortization_start_date,-- added this for bug 2972724
                NEW_MASTER_FLAG, ASSET_KEY_CCID,
                ASSET_TYPE, DEPRN_RESERVE,
                YTD_DEPRN, BEGINNING_NBV,
                CREATED_BY, CREATION_DATE,
                LAST_UPDATE_LOGIN,
		SALVAGE_VALUE,
		ACCOUNTING_DATE,
		ATTRIBUTE_CATEGORY_CODE,
		FULLY_RSVD_REVALS_COUNTER,
		PRODUCTION_CAPACITY,
		REVAL_AMORTIZATION_BASIS,
		REVAL_RESERVE,
		UNIT_OF_MEASURE,
		UNREVALUED_COST,
		YTD_REVAL_DEPRN_EXPENSE,
		SPLIT_PARENT_MASS_ADDITIONS_ID,
		MERGE_PARENT_MASS_ADDITIONS_ID,
		SPLIT_CODE, MERGED_CODE,
		SUM_UNITS,
		ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6,
		ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
		ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18,
		ATTRIBUTE19, ATTRIBUTE20, ATTRIBUTE21, ATTRIBUTE22, ATTRIBUTE23, ATTRIBUTE24,
		ATTRIBUTE25, ATTRIBUTE26, ATTRIBUTE27, ATTRIBUTE28, ATTRIBUTE29, ATTRIBUTE30,
        GLOBAL_ATTRIBUTE1, GLOBAL_ATTRIBUTE2, GLOBAL_ATTRIBUTE3,
        GLOBAL_ATTRIBUTE4, GLOBAL_ATTRIBUTE5, GLOBAL_ATTRIBUTE6,
        GLOBAL_ATTRIBUTE7, GLOBAL_ATTRIBUTE8, GLOBAL_ATTRIBUTE9,
        GLOBAL_ATTRIBUTE10, GLOBAL_ATTRIBUTE11, GLOBAL_ATTRIBUTE12,
        GLOBAL_ATTRIBUTE13, GLOBAL_ATTRIBUTE14, GLOBAL_ATTRIBUTE15,
        GLOBAL_ATTRIBUTE16, GLOBAL_ATTRIBUTE17, GLOBAL_ATTRIBUTE18,
        GLOBAL_ATTRIBUTE19, GLOBAL_ATTRIBUTE20, GLOBAL_ATTRIBUTE_CATEGORY,
		  CONTEXT, INVENTORIAL,
        TRANSACTION_TYPE_CODE,TRANSACTION_DATE, WARRANTY_ID, LEASE_ID,
        LESSOR_ID, PROPERTY_TYPE_CODE, PROPERTY_1245_1250_CODE,
        IN_USE_FLAG,OWNED_LEASED, NEW_USED, ASSET_ID
        -- bugfix 1839692
        , project_id, task_id, project_asset_line_id,
        invoice_distribution_id,
        invoice_line_number,
        po_distribution_id,
        warranty_number)
      Select
		I_New_MASS_ADDITION_ID,
		NULL, NULL,
		DESCRIPTION, ASSET_CATEGORY_ID,
		MANUFACTURER_NAME, NULL,
		MODEL_NUMBER, BOOK_TYPE_CODE,
		DATE_PLACED_IN_SERVICE, I_FA_COST, 1,
		decode(MERGED_CODE,
		'MP', 1,
		'MC', decode(NVL(I_Sum_Units, 'NO'),
                    'YES', round((FIXED_ASSETS_UNITS-I_Merge_Child_fa_Units)/I_Total_fa_Units,2),
			         1),
		1),
		PAYABLES_CODE_COMBINATION_ID, EXPENSE_CODE_COMBINATION_ID,
		LOCATION_ID, ASSIGNED_TO,
		FEEDER_SYSTEM_NAME, CREATE_BATCH_DATE,
		CREATE_BATCH_ID, LAST_UPDATE_DATE,
		LAST_UPDATED_BY, REVIEWER_COMMENTS,
		INVOICE_NUMBER, VENDOR_NUMBER,
                NVL(MERGE_INVOICE_NUMBER, INVOICE_NUMBER),
                NVL(MERGE_VENDOR_NUMBER, VENDOR_NUMBER),
		PO_VENDOR_ID, PO_NUMBER,
     -- BUG# 1294559: Parents in 'NEW' queue should create children in 'ON HOLD'
     --   bridgway 07/05/00
                decode(POSTING_STATUS, 'NEW', 'ON HOLD', POSTING_STATUS),
                decode(QUEUE_NAME,     'NEW', 'ON HOLD', QUEUE_NAME),
		INVOICE_DATE, INVOICE_CREATED_BY,
		INVOICE_UPDATED_BY, I_PA_COST,
		INVOICE_ID, PAYABLES_BATCH_NAME,
		DEPRECIATE_FLAG, decode(NVL(MERGED_CODE, 'SC'), 'SC', I_Mass_Additions_ID, NULL),
		PARENT_ASSET_ID, NVL(MERGED_CODE, 'SC'),
		AP_DISTRIBUTION_LINE_NUMBER, POST_BATCH_ID,
		ADD_TO_ASSET_ID, AMORTIZE_FLAG,amortization_start_date,-- added this for bug 2972724
		NEW_MASTER_FLAG, ASSET_KEY_CCID,
		ASSET_TYPE,
		I_Deprn_Reserve,
		I_YTD_Deprn,
		I_Beginning_NBV,
		CREATED_BY, CREATION_DATE,
		LAST_UPDATE_LOGIN,
		I_Salvage_Value,
		ACCOUNTING_DATE,
		ATTRIBUTE_CATEGORY_CODE,
		FULLY_RSVD_REVALS_COUNTER,
		I_Production_Capacity,
		I_Reval_Amortization_Basis,
		I_Reval_Reserve,
		UNIT_OF_MEASURE,
	-- fix for 1461477 set back to null if no unrevalued cost
        -- as this creates problem in mass add post
                decode(I_Unrevalued_Cost,0,NULL,I_Unrevalued_Cost),
		I_Ytd_Reval_Deprn_Expense,
		I_Split_Parent_Mass_Add_id,
		I_Merge_Parent_Mass_Add_Id,
		'SC', MERGED_CODE,
		NVL(I_Sum_Units, 'NO'),
		ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6,
		ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
		ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18,
		ATTRIBUTE19, ATTRIBUTE20, ATTRIBUTE21, ATTRIBUTE22, ATTRIBUTE23, ATTRIBUTE24,
		ATTRIBUTE25, ATTRIBUTE26, ATTRIBUTE27, ATTRIBUTE28, ATTRIBUTE29, ATTRIBUTE30,
        GLOBAL_ATTRIBUTE1, GLOBAL_ATTRIBUTE2, GLOBAL_ATTRIBUTE3,
        GLOBAL_ATTRIBUTE4, GLOBAL_ATTRIBUTE5, GLOBAL_ATTRIBUTE6,
        GLOBAL_ATTRIBUTE7, GLOBAL_ATTRIBUTE8, GLOBAL_ATTRIBUTE9,
        GLOBAL_ATTRIBUTE10, GLOBAL_ATTRIBUTE11, GLOBAL_ATTRIBUTE12,
        GLOBAL_ATTRIBUTE13, GLOBAL_ATTRIBUTE14, GLOBAL_ATTRIBUTE15,
        GLOBAL_ATTRIBUTE16, GLOBAL_ATTRIBUTE17, GLOBAL_ATTRIBUTE18,
        GLOBAL_ATTRIBUTE19, GLOBAL_ATTRIBUTE20, GLOBAL_ATTRIBUTE_CATEGORY,
		CONTEXT, INVENTORIAL,
        TRANSACTION_TYPE_CODE,TRANSACTION_DATE, WARRANTY_ID, LEASE_ID,
        LESSOR_ID, PROPERTY_TYPE_CODE, PROPERTY_1245_1250_CODE,
        IN_USE_FLAG,OWNED_LEASED, NEW_USED, NULL
        -- bugfix 1839692 msiddiqu
        , project_id, task_id, project_asset_line_id,
        invoice_distribution_id,
        invoice_line_number,
        po_distribution_id,
        warranty_number
        FROM
	        FA_MASS_ADDITIONS
        WHERE   MASS_ADDITION_ID = I_Mass_Additions_ID;

    select fixed_assets_units into h_total_units from fa_mass_additions
	where mass_addition_id = I_Split_Parent_Mass_Add_Id;

	select count(*) into h_num_dists from fa_massadd_distributions
	where mass_addition_id = I_Split_Parent_Mass_Add_Id;

	if (I_Sum_Units = 'YES') then
        select round((FIXED_ASSETS_UNITS-I_Merge_Child_fa_Units)/I_Total_fa_Units,2)
    	into h_child_total_units from fa_mass_additions
        WHERE   MASS_ADDITION_ID = I_Mass_Additions_ID;
	else
        select fixed_assets_units into h_child_total_units from fa_mass_additions
	    where mass_addition_id = I_New_MASS_ADDITION_ID;

	end if;


	h_child_units_so_far := 0;

	if (I_Sum_Units = 'YES') then
		h_divisor_units :=  I_Total_fa_Units;
	else
		h_divisor_units :=  h_total_units;
	end if;

        open split_dists;

	for h_iter in 1 .. h_num_dists loop
	  fetch split_dists into h_parent_dist_units, h_ccid, h_location, h_employee;

	  if (split_dists%NOTFOUND) then return;  end if;

	  select fa_massadd_distributions_s.nextval into h_dist_id from dual;

      if (h_iter = h_num_dists) then
	    h_child_dist_units := h_child_total_units - h_child_units_so_far;
      else
  	    h_child_dist_units := round( h_parent_dist_units/h_divisor_units, 2 );
        h_child_units_so_far := h_child_units_so_far + h_child_dist_units;
      end if;

	  insert into fa_massadd_distributions (massadd_dist_id, mass_addition_id,
		units, deprn_expense_ccid, location_id, employee_id) values (
		h_dist_id, I_New_Mass_Addition_Id,
		h_child_dist_units, h_ccid, h_location, h_employee);

	end loop;

	Exception
		When No_Data_Found then
			FND_Message.Set_Name('OFA', 'FA_SQL_ERROR') ;
			FND_Message.Set_Token('PROCEDURE_NAME', 'Insert_Row');
			APP_EXCEPTION.Raise_Exception;

   End Insert_Split_Child;


----

   Procedure UNDO_SPLIT_MASS_ADDITIONS (X_Mass_Addition_ID 		NUMBER DEFAULT NULL,
					X_Merged_Code			Varchar2 Default NULL,
					p_log_level_rec    IN FA_API_TYPES.log_level_rec_type default null) Is
   	Child_records_Num 		Number Default 0;
	FA_MASSADD_POSTED_CHILD		Exception;
        h_units                         Number Default 0;

   Begin
	-- Check if ay of the child records have been posted
	--FND_Message.Set_Name('OFA', 'FA_MASSADD_POSTED_CHILD') ;
			-- FND_Message.Error;
			-- APP_EXCEPTION.Raise_Exception;
	Select Count(*) Into Child_records_Num
	From Fa_Mass_Additions
	Where POSTING_STATUS = 'POSTED'
   	And Split_parent_MAss_Additions_ID = X_Mass_Addition_ID
   	And Split_Code = 'SC';

	If Child_Records_Num > 0 then
		Raise FA_MASSADD_POSTED_CHILD;
	end if;

           -- BUG# 1346455
           -- adding to prevent unspitting in cases where children
           -- have been posted but also purged

       Select Count(*) Into Child_records_Num
         From Fa_Mass_Additions
        Where Split_parent_MAss_Additions_ID = X_Mass_Addition_ID
          And Split_Code = 'SC';

       Select nvl(fixed_assets_units, 0) into h_units  -- new variable
         from fa_mass_additions
        where mass_addition_id = X_Mass_Addition_ID;

       If Child_Records_Num <> h_units then
          Raise FA_MASSADD_POSTED_CHILD;
       end if;

	-- Delete all the split Children which also happen to be Merged records.
	-- The ones with Split_Code = 'SC' and Merged_Code = 'MC'

	If (X_MERGED_CODE = 'MP') then
		Delete from FA_MAss_Additions
     		Where Merge_Parent_Mass_Additions_Id In (Select Mass_Addition_ID
					  from FA_MAss_Additions
					  Where Split_Parent_Mass_Additions_Id = X_Mass_Addition_Id);
	   if (SQL%Notfound) then
		Raise NO_DATA_FOUND;
	   end if;

	End if;

	-- Delete all the records which are split parents

	Delete from FA_MAss_Additions
     	Where Split_Parent_Mass_Additions_Id = X_Mass_Addition_Id;

	if (SQL%Notfound) then
		Raise NO_DATA_FOUND;
	end if;

	-- Update the Split_code of the Parent record


		Update FA_MAss_Additions
     		Set Split_Code = NULL,
		Split_Merged_Code = NVL(MERGED_CODE, NULL),
		POSTING_STATUS = decode	(QUEUE_NAME, 'NEW',          'NEW',
                          		'POST',         'POST',
                          		'DELETE',       'DELETE',
                          		'POST',         'POST',
                          		'ADD TO ASSET', 'POST', 'ON HOLD')
     		Where Mass_addition_ID = X_Mass_Addition_ID;

		if (X_Merged_Code = 'MP') then
		   Update FA_MAss_Additions
     		   Set Split_Code = NULL,
		   Split_Merged_Code = NVL(MERGED_CODE, NULL),
		   POSTING_STATUS = 'MERGED'
     		   Where merge_parent_Mass_additions_ID = X_Mass_Addition_ID;
		end if;

	if (SQL%Notfound) then
		Raise NO_DATA_FOUND;
	end if;

	commit;

        Exception
		When FA_MASSADD_POSTED_CHILD Then
			FND_Message.Set_Name('OFA', 'FA_MASSADD_POSTED_CHILD') ;
			-- FND_Message.Error;
			APP_EXCEPTION.Raise_Exception;

		When NO_DATA_FOUND then
			APP_EXCEPTION.Raise_Exception;
		When Others then
			-- Fnd_Message.Error;
			APP_EXCEPTION.Raise_Exception;




   End UNDO_SPLIT_MASS_ADDITIONS;

END SPLIT_MASS_ADDITIONS_PKG;

/
