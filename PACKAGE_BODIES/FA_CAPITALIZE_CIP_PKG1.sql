--------------------------------------------------------
--  DDL for Package Body FA_CAPITALIZE_CIP_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CAPITALIZE_CIP_PKG1" as
/* $Header: faxccab1.pls 120.7.12010000.2 2009/07/19 10:43:08 glchen ship $ */

  PROCEDURE CALC_SUBCOMP_LIFE(X_book	         VARCHAR2,
			      X_cat_id 	         NUMBER,
			      X_parent_asset_id  NUMBER,
			      X_dpis 	         DATE,
			      h_deprn_method     VARCHAR2,
			      h_prorate_date     DATE,
			      X_user_id	         NUMBER,
			      X_curr_date	 DATE,
			      h_life             IN OUT NOCOPY number,
			      X_Calling_Fn       VARCHAR2,
			      p_log_level_rec    IN     FA_API_TYPES.log_level_rec_type
)IS
    CURSOR RATE_DEF IS
      SELECT DISTINCT RATE_SOURCE_RULE
      FROM FA_METHODS
      WHERE METHOD_CODE = h_deprn_method;

    h_rate_source_rule   varchar2(10);

    CURSOR LIFE_DEF IS
      select nvl(life_in_months,0), nvl(minimum_life_in_months,0),
             subcomponent_life_rule
      from fa_category_book_defaults
      where book_type_code = X_book
        and category_id = X_cat_id
        and X_dpis
            between start_dpis
            and nvl(end_dpis,add_months(sysdate,1200));

    h_cat_bk_lim              number;
    h_min_life_in_months      number;
    h_sub_life_rule           varchar2(13);

    CURSOR LIFE1_DEF IS
      select nvl(life_in_months,0), nvl(life_in_months,0),
             prorate_date
      from fa_books
      where book_type_code = X_book
        and asset_id = X_parent_asset_id
        and date_ineffective is null;

    h_lim                       number;
    h_parent_life               number;
    h_parent_prorate_date       date;

    CURSOR FY_DEF IS
       select round
              (nvl(sum
               (decode (bc.deprn_allocation_code,'E',
                1/ct.number_per_fiscal_year,
                (cp.end_date + 1 - cp.start_date) /
                (fy.end_date + 1 - fy.start_date))),0) * 12, 0)
       from fa_calendar_periods cp,
            fa_calendar_types ct,
            fa_book_controls bc,
            fa_fiscal_year fy
       where bc.book_type_code = X_book and
             bc.date_ineffective is null and
             ct.calendar_type = bc.prorate_calendar and
             ct.fiscal_year_name = bc.fiscal_year_name
         and cp.calendar_type = ct.calendar_type and
             ( (cp.start_date >= h_parent_prorate_date and
                cp.end_date <= h_prorate_date) )
         and fy.fiscal_year_name = bc.fiscal_year_name
         and fy.start_date <= cp.start_date
         and fy.end_date >= cp.end_date;


-- excluded due to bug 3872361
/*
              or
               (cp.start_date <= h_parent_prorate_date
                and cp.end_date >= h_parent_prorate_date
                and cp.start_date <= h_prorate_date
                and cp.end_date <= h_prorate_date)
*/

    h_fy                        number;
    h_new_life                  number;

  BEGIN


    OPEN RATE_DEF;
    FETCH RATE_DEF INTO
       h_rate_source_rule;

    if (RATE_DEF%NOTFOUND) then
      CLOSE RATE_DEF;

      FA_STANDARD_PKG.RAISE_ERROR(
                CALLED_FN => 'fa_capitalize_cip_pkg1.calc_subcomp_life',
                CALLING_FN => X_Calling_Fn,
		NAME => 'FA_SHARED_OBJECT_NOT_DEF',
		TOKEN1 => 'OBJECT',
		VALUE1 => 'Method',
		p_log_level_rec     => p_log_level_rec);
    end if;
    CLOSE RATE_DEF;

    if (h_rate_source_rule in ('FLAT', 'PRODUCTION')) then

      FA_STANDARD_PKG.RAISE_ERROR(
                CALLED_FN => 'fa_capitalize_cip_pkg1.calc_subcomp_life',
                CALLING_FN => X_Calling_Fn,
		NAME => 'FA_MTH_LFR_INCOMPAT',
		p_log_level_rec     => p_log_level_rec);
    end if;

-- For depreciation books that have future dated periods,
-- we use 100 years past the end_dpis if it's null for comparisions;

    OPEN LIFE_DEF;
    FETCH LIFE_DEF INTO
         h_cat_bk_lim,
	 h_min_life_in_months,
         h_sub_life_rule;

    if (LIFE_DEF%NOTFOUND) then
      CLOSE LIFE_DEF;

      FA_STANDARD_PKG.RAISE_ERROR(
                CALLED_FN => 'fa_capitalize_cip_pkg1.calc_subcomp_life',
                CALLING_FN => X_Calling_Fn,
		NAME => 'FA_SHARED_OBJECT_NOT_DEF',
		TOKEN1 => 'OBJECT',
		VALUE1 => 'Subcomponent Life Rule',
		p_log_level_rec     => p_log_level_rec);
    end if;
    CLOSE LIFE_DEF;

    OPEN LIFE1_DEF;
    FETCH LIFE1_DEF INTO
          h_lim,
	  h_parent_life,
  	  h_parent_prorate_date;

    if (LIFE1_DEF%NOTFOUND) then
      CLOSE LIFE1_DEF;

      FA_STANDARD_PKG.RAISE_ERROR(
                CALLED_FN => 'fa_capitalize_cip_pkg1.calc_subcomp_life',
                CALLING_FN => X_Calling_Fn,
		NAME => 'FA_PARENT_BKS_NOT_EXIST',
		p_log_level_rec     => p_log_level_rec);
    end if;
    CLOSE LIFE1_DEF;

    if (h_sub_life_rule = 'SAME LIFE') then
      if (h_lim  = 0) then
        h_lim := h_cat_bk_lim;
        FA_STANDARD_PKG.RAISE_ERROR(
                CALLED_FN => 'fa_capitalize_cip_pkg1.calc_subcomp_life',
                CALLING_FN => X_Calling_Fn,
		NAME => 'FA_PARENT_LIFE_NOT_SETUP',
		p_log_level_rec     => p_log_level_rec);
      end if;
    elsif (h_sub_life_rule = 'SAME END DATE') then
         if (h_parent_life = 0) then
           h_lim := h_cat_bk_lim;
  	   FA_STANDARD_PKG.RAISE_ERROR(
                CALLED_FN => 'fa_capitalize_cip_pkg1.calc_subcomp_life',
                CALLING_FN => X_Calling_Fn,
		NAME => 'FA_PARENT_LIFE_NOT_SETUP',
		p_log_level_rec     => p_log_level_rec);
         else
           h_fy := 0;

           OPEN FY_DEF;
           FETCH FY_DEF INTO
                 h_fy;

           if (FY_DEF%NOTFOUND) then
             CLOSE FY_DEF;
             FA_STANDARD_PKG.RAISE_ERROR(
                CALLED_FN => 'fa_capitalize_cip_pkg1.calc_subcomp_life',
                CALLING_FN => X_Calling_Fn,
		NAME => 'FA_SHARED_OBJECT_NOT_DEF',
		TOKEN1 => 'OBJECT',
		VALUE1 => 'Fiscal Year or Calendar Period',
		p_log_level_rec     => p_log_level_rec);
           end if;
           CLOSE FY_DEF;

-- If the parent asset is fully reserved i.e it's remaining life as
-- computed here is <= 0 then the life of the subcomponent asset
-- is one month.

         if (h_fy >= h_parent_life) then
-- If the parent asset is fully rsvd
           h_lim := 1;
         else
-- The life is the lesser of the Category's life and parent's remaining life
-- BUG# 1898874 - correcting the check to use h_cat_bk_lim instead of h_lim
-- so that this is actually what happens.  Previously, the same end date
-- was always implemented no matter how much the child's life was inflated.
--     bridgway   07/24/01

	   if ((h_parent_life - h_fy) < h_cat_bk_lim) then
             h_lim := h_parent_life - h_fy;
           else
             h_lim := h_cat_bk_lim;
           end if;

	   if (h_lim < h_min_life_in_months) then
             if (h_cat_bk_lim < h_min_life_in_months) then
                h_lim := h_min_life_in_months;
             else
                h_lim := h_cat_bk_lim;
             end if;
	   end if;

         end if;  -- If the parent asset is fully reserved


       end if;  -- If parent's life is not setup

     else

       h_lim := h_cat_bk_lim;

     end if;

--   h_new_life := 0;  -- Change to h_lim to fix bug 737503
     h_new_life := h_lim;

     CHECK_LIFE(X_book,
		X_cat_id,
	        X_dpis,
	        h_deprn_method,
		h_rate_source_rule,
	        h_cat_bk_lim,
		h_lim,
		X_user_id,
	        X_curr_date,
	        h_new_life,
		'fa_capitalize_cip_pkg1.calc_subcomp_life',
		p_log_level_rec);

     if (h_new_life <> 0) then
       h_life := h_new_life;
     end if;

  exception
     WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
        CALLING_FN => 'fa_capitalize_cip_pkg1.calc_subcomp_life',
                   p_log_level_rec => p_log_level_rec);
        raise;

  END CALC_SUBCOMP_LIFE;


  PROCEDURE CHECK_LIFE (X_book              VARCHAR2,
	                X_cat_id            NUMBER,
	                X_dpis              DATE,
		        h_deprn_method      VARCHAR2,
		        h_rate_source_rule  VARCHAR2,
		        h_life_in_months    NUMBER,
	 	        h_lim               NUMBER,
		        X_user_id	    NUMBER,
	                X_curr_date	    DATE,
		        h_new_life	    IN OUT NOCOPY NUMBER,
			X_Calling_Fn       VARCHAR2,
			p_log_level_rec     IN     FA_API_TYPES.log_level_rec_type
)IS

    CURSOR MD_DEF
        (p_deprn_method  varchar2,
         p_lim           number) IS
      select method_id,
             depreciate_lastyear_flag,
             rate_source_rule,
             deprn_basis_rule,
             stl_method_flag,
             exclude_salvage_value_flag
      from fa_methods
      where method_code = p_deprn_method
        and nvl(life_in_months,0) = p_lim;

    CURSOR CHECK_METHOD_EXISTS IS
	select method_code, life_in_months
	from fa_methods
	where method_code = h_deprn_method
	and nvl(life_in_months,0) = h_lim;

-- bug 1147151
    CURSOR methodname IS
	select name
	from fa_methods
	where method_code = h_deprn_method
	order by created_by desc;

   CURSOR C_FORMULA (p_method_id number) IS
   SELECT formula_actual,
          formula_displayed,
          formula_parsed
     FROM FA_FORMULAS
    WHERE method_id = p_method_id;

    h_method_id             number;
    h_deprn_last_year_flag  varchar2(3);
    h_rsr                   varchar2(10);
    h_deprn_basis_rule      varchar2(4);
    h_rowid 		    rowid;
    h_dummy1                varchar2(12);
    h_dummy2	            number(4);
    h_methodname	    fa_methods.name%type;

    h_method_id_old         number;
    h_stl_method_flag       varchar2(3);
    h_exclude_sal_flag      varchar2(3);

    h_formula_actual        varchar2(4000);
    h_formula_displayed     varchar2(4000);
    h_formula_parsed        varchar2(4000);

  BEGIN

  if not fa_cache_pkg.fazccmt
          (X_method                => h_deprn_method,
           X_life                  => h_lim,
	   p_log_level_rec         => p_log_level_rec) then  -- method not found

    if (h_rsr = 'TABLE') then

      if (h_life_in_months <> 0) then
        h_new_life := h_life_in_months;
      else
      	FA_STANDARD_PKG.RAISE_ERROR(
                CALLED_FN => 'fa_capitalize_cip_pkg1.check_life',
                CALLING_FN => X_Calling_Fn,
		NAME => 'FA_LIM_TDM_NOTDEF',
		p_log_level_rec => p_log_level_rec);
      end if;

    else /* if not 'TABLE' */

      select FA_METHODS_S.NEXTVAL
      into h_method_id
      from sys.dual;

      -- need to derive more values to distinguish between
      -- STL and Formula methods.  Can't use cache as life
      -- is unknown so like the function in calc engine,
      -- we'll use cursor here,  other option would be to
      -- pass the values as parameter into this function
      -- creating dependancies...

      OPEN MD_DEF(h_deprn_method, h_life_in_months);
      FETCH MD_DEF INTO
         h_method_id_old,
         h_deprn_last_year_flag,
         h_rsr,
         h_deprn_basis_rule,
         h_stl_method_flag,
         h_exclude_sal_flag;


      if (MD_DEF%NOTFOUND) then
         CLOSE MD_DEF;
         FA_STANDARD_PKG.RAISE_ERROR(
                CALLED_FN => 'fa_capitalize_cip_pkg1.check_life',
                CALLING_FN => X_Calling_Fn,
                NAME => 'FA_SHARED_OBJECT_NOT_DEF',
                TOKEN1     => 'OBJECT',
                VALUE1     => 'Method',
		p_log_level_rec  => p_log_level_rec);

      else
         CLOSE MD_DEF;
      end if;

      FA_METHODS_PKG.Insert_Row(
        X_Rowid	                   => h_rowid,
	X_Method_Id	           => h_method_id,
        X_Method_Code              => h_deprn_method,
        X_Life_In_Months           => h_lim,
        X_Depreciate_Lastyear_Flag => h_deprn_last_year_flag, -- 'YES',
  	X_STL_Method_Flag 	   => h_stl_method_flag,      -- 'YES',
  	X_Rate_Source_Rule	   => h_rsr,                  -- 'CALCULATED',
	X_Deprn_Basis_Rule	   => h_deprn_basis_rule,     -- 'COST',
	X_Prorate_Periods_Per_Year => NULL,
 	X_Name			   => h_methodname,
	X_Last_Update_Date   	   => X_curr_date,
	X_Last_Updated_By	   => X_user_id,
	X_Created_By		   => X_user_id,
	X_Creation_Date		   => X_curr_date,
	X_Last_Update_Login	   => -1,
	X_Attribute1		   => null,
	X_Attribute2		   => null,
	X_Attribute3		   => null,
	X_Attribute4		   => null,
	X_Attribute5		   => null,
	X_Attribute6		   => null,
	X_Attribute7		   => null,
	X_Attribute8		   => null,
	X_Attribute9		   => null,
	X_Attribute10		   => null,
	X_Attribute11		   => null,
	X_Attribute12		   => null,
	X_Attribute13		   => null,
	X_Attribute14		   => null,
	X_Attribute15		   => null,
	X_Attribute_Category_Code  => null,
        X_Exclude_Salvage_Value_Flag => h_exclude_sal_flag,
	X_Calling_Fn		   => 'fa_capitalize_cip_pkg1.check_life',
	p_log_level_rec            => p_log_level_rec);

      -- if formula based, we need to copy the formula too
      if (h_rate_source_rule = 'FORMULA') then
         OPEN C_FORMULA (p_method_id => h_method_id_old);
         FETCH C_FORMULA
          INTO h_formula_actual,
               h_formula_displayed,
               h_formula_parsed;

         IF C_FORMULA%NOTFOUND then
            CLOSE C_FORMULA;
            FA_STANDARD_PKG.RAISE_ERROR(
                CALLED_FN => 'fa_capitalize_cip_pkg1.check_life',
                CALLING_FN => X_Calling_Fn,
                NAME => 'FA_FORMULA_RATE_NO_DATA_FOUND',
		p_log_level_rec  => p_log_level_rec);
         else
            CLOSE C_FORMULA;
         end if;

         FA_FORMULAS_PKG.insert_row
              (X_ROWID               => h_rowid,
               X_METHOD_ID           => h_method_id,
               X_FORMULA_ACTUAL      => h_formula_actual,
               X_FORMULA_DISPLAYED   => h_formula_displayed,
               X_FORMULA_PARSED      => h_formula_parsed,
               X_CREATION_DATE       => X_curr_date,
               X_CREATED_BY          => X_user_id,
               X_LAST_UPDATE_DATE    => X_curr_date,
               X_LAST_UPDATED_BY     => X_user_id,
               X_LAST_UPDATE_LOGIN   => -1,
	       p_log_level_rec       => p_log_level_rec);

      end if;  -- formula
    end if;    -- table based

    -- Fix for bug 624113 -- default the new life in months to the remaining
    -- life in months of parent.
    if (h_lim <> 0) then
      h_new_life := h_lim;
    end if;

  end if; -- method not found

  exception
    WHEN OTHERS THEN
        FA_SRVR_MSG.Add_SQL_Error(
        CALLING_FN => 'fa_capitalize_cip_pkg1.check_life',
                   p_log_level_rec => p_log_level_rec);
        raise;
  END CHECK_LIFE;

END FA_CAPITALIZE_CIP_PKG1;

/
