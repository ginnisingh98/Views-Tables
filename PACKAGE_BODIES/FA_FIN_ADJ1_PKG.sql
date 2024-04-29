--------------------------------------------------------
--  DDL for Package Body FA_FIN_ADJ1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FIN_ADJ1_PKG" as
/* $Header: faxfa1b.pls 120.5.12010000.2 2009/07/19 13:35:12 glchen ship $ */

 PROCEDURE get_deprn_info(bks_asset_id		in number,
			  bks_book_type_code		in varchar2,
			  bks_depreciation_check	in out nocopy varchar2,
			  bks_current_period_flag	in out nocopy varchar2,
			  bks_calling_fn			varchar2,
			  p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
 IS

  cursor deprn_check is
    select 'Y'
    from fa_deprn_summary ds
    where ds.book_type_code = bks_book_type_code and
          ds.asset_id = bks_asset_id              and
          ds.deprn_source_code = 'DEPRN'                and
          ds.deprn_amount <> 0   and
	  rownum <2;

  -- Bug:5172007
  cursor check_current_period is
    select 'Y'
    from   fa_deprn_summary ds,
           fa_deprn_periods dp
    where  dp.book_type_code= bks_book_type_code      and
           ds.asset_id = bks_asset_id                 and
           ds.book_type_code= bks_book_type_code      and
           ds.deprn_source_code = 'BOOKS'             and
	   dp.period_close_date is null               and
           ds.period_counter = dp.period_counter - 1;

  BEGIN

    bks_depreciation_check := 'N';
    bks_current_period_flag := 'N';

    open deprn_check;
    fetch deprn_check into bks_depreciation_check;
    close deprn_check;

    open check_current_period;
    fetch check_current_period into bks_current_period_flag;
    close check_current_period;

/*  exception
    when others then
      FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_fin_adj1_pkg.get_deprn_info',
		CALLING_FN => bks_Calling_Fn,
		 p_log_level_rec => p_log_level_rec); */

  END get_deprn_info;

-- syoung: added x_return_status.
procedure cal_rec_cost(
		bks_itc_amount_id		in number,
		bks_ceiling_type		in varchar2,
		bks_ceiling_name		in varchar2,
		bks_itc_basis			in number,
		bks_cost			in number,
		bks_salvage_value		in number,
		bks_recoverable_cost		in out nocopy number,
		bks_date_placed_in_service	in date,
		x_return_status		 out nocopy boolean,
		bks_calling_fn			varchar2,
		p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
is
  cursor no_itc_yes_ceiling is
    select least(bks_cost - bks_salvage_value,
		 nvl(ce.limit, bks_cost - bks_salvage_value))
    from fa_ceilings ce
    where ce.ceiling_name = bks_ceiling_name
    and bks_date_placed_in_service
    between ce.start_date
    and nvl(ce.end_date, bks_date_placed_in_service);

  cursor yes_itc_no_ceiling is
    select bks_cost - bks_salvage_value -
	   bks_itc_basis * ir.basis_reduction_rate
    from fa_itc_rates ir
    where ir.itc_amount_id = bks_itc_amount_id;

  cursor yes_itc_yes_ceiling is
    select least(bks_cost - bks_salvage_value -
		 bks_itc_basis * ir.basis_reduction_rate,
		 nvl(ce.limit, bks_cost - bks_salvage_value -
			       bks_itc_basis * ir.basis_reduction_rate))
    from fa_ceilings ce, fa_itc_rates ir
    where ir.itc_amount_id = bks_itc_amount_id
    and ce.ceiling_name = bks_ceiling_name
    and bks_date_placed_in_service
    between ce.start_date
    and nvl(ce.end_date, bks_date_placed_in_service);

    calc_error	exception;  -- syoung: added this exception.

  begin
    if bks_itc_amount_id is null then
      if bks_ceiling_type = 'RECOVERABLE COST CEILING' then
	open no_itc_yes_ceiling;
	fetch no_itc_yes_ceiling into
	  bks_recoverable_cost;

  	if (no_itc_yes_ceiling%notfound) then
	  close no_itc_yes_ceiling;
	  -- syoung: conditional messaging.
	  if (bks_calling_fn = 'FA_BOOKS_ADD.Default_Assets' or
	      bks_calling_fn = 'FA_BOOKS_VAL.COST' or
	      bks_calling_fn = 'FA_BOOKS_VAL.SAL_VALUE_VAL' or
	      bks_calling_fn = 'FA_BOOKS_VAL.DPIS_VAL' or
	      bks_calling_fn = 'FA_BOOKS_VAL3.CONV_CODE_VAL' or
	      bks_calling_fn = 'FA_BOOKS_VAL4.CEILING_NAME') then
	      fnd_message.set_name('OFA', 'FA_SHARED_REC_COST');
	      app_exception.raise_exception;
	  else
	      raise calc_error;
          end if;
	end if;

	close no_itc_yes_ceiling;
      else
	bks_recoverable_cost := bks_cost - bks_salvage_value;
      end if;
    else
      if bks_ceiling_type = 'RECOVERABLE COST CEILING' then
	open yes_itc_yes_ceiling;
	fetch yes_itc_yes_ceiling into
	  bks_recoverable_cost;

  	if (yes_itc_yes_ceiling%notfound) then
	  close yes_itc_yes_ceiling;
	  -- syoung: conditional messaging.
	  if (bks_calling_fn = 'FA_BOOKS_ADD.Default_Assets' or
	      bks_calling_fn = 'FA_BOOKS_VAL.COST' or
	      bks_calling_fn = 'FA_BOOKS_VAL.SAL_VALUE_VAL' or
	      bks_calling_fn = 'FA_BOOKS_VAL.DPIS_VAL' or
	      bks_calling_fn = 'FA_BOOKS_VAL3.CONV_CODE_VAL' or
	      bks_calling_fn = 'FA_BOOKS_VAL4.CEILING_NAME') then
	      fnd_message.set_name('OFA', 'FA_SHARED_REC_COST');
	      app_exception.raise_exception;
	  else
	      raise calc_error;
          end if;
	end if;

	close yes_itc_yes_ceiling;
      else
	open yes_itc_no_ceiling;
	fetch yes_itc_no_ceiling into
	  bks_recoverable_cost;

  	if (yes_itc_no_ceiling%notfound) then
	  close yes_itc_no_ceiling;
	  -- syoung: conditional messaging.
	  if (bks_calling_fn = 'FA_BOOKS_ADD.Default_Assets' or
	      bks_calling_fn = 'FA_BOOKS_VAL.COST' or
	      bks_calling_fn = 'FA_BOOKS_VAL.SAL_VALUE_VAL' or
	      bks_calling_fn = 'FA_BOOKS_VAL.DPIS_VAL' or
	      bks_calling_fn = 'FA_BOOKS_VAL3.CONV_CODE_VAL' or
	      bks_calling_fn = 'FA_BOOKS_VAL4.CEILING_NAME') then
	      fnd_message.set_name('OFA', 'FA_SHARED_REC_COST');
	      app_exception.raise_exception;
	  else
	      raise calc_error;
          end if;
	end if;

	close yes_itc_no_ceiling;
      end if;
    end if;

    x_return_status := true;
/*  exception
    when others then
      FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_fin_adj1_pkg.cal_rec_cost',
		CALLING_FN => bks_Calling_Fn,
		 p_log_level_rec => p_log_level_rec);  */
 --syoung: added exceptions
  exception
  when calc_error then
      FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_FIN_ADJ1_PKG.Cal_Rec_Cost',
		NAME => 'FA_SHARED_REC_COST',
		  p_log_level_rec => p_log_level_rec);
      x_return_status := false;
  when others then
      if not (bks_calling_fn = 'FA_BOOKS_ADD.Default_Assets' or
	      bks_calling_fn = 'FA_BOOKS_VAL.COST' or
	      bks_calling_fn = 'FA_BOOKS_VAL.SAL_VALUE_VAL' or
	      bks_calling_fn = 'FA_BOOKS_VAL.DPIS_VAL' or
	      bks_calling_fn = 'FA_BOOKS_VAL3.CONV_CODE_VAL' or
	      bks_calling_fn = 'FA_BOOKS_VAL4.CEILING_NAME') then
	FA_SRVR_MSG.Add_SQL_Error(
		CALLING_FN => 'FA_FIN_ADJ1_PKG.Cal_Rec_Cost'
		,  p_log_level_rec => p_log_level_rec);
        x_return_status := false;
      end if;

  end cal_rec_cost;

 -- syoung: included x_return_status.
 procedure update_and_check_amts(
		bks_depreciation_check		in varchar2,
		bks_current_period_flag		in varchar2,
		bks_recoverable_cost		in number,
		bks_deprn_reserve		in number,
		bks_ytd_deprn			in number,
		bks_cost			in number,
		bks_salvage_value		in number,
		x_return_status		 out nocopy boolean,
		bks_calling_fn			varchar2,
		p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
is
   amt_error	exception; -- syoung.
begin
  if bks_depreciation_check <> 'Y' then
    if (bks_recoverable_cost >= 0) or
	(bks_recoverable_cost < 0 and
	bks_deprn_reserve <= 0 and
	bks_ytd_deprn <= 0) then
      if (bks_recoverable_cost <= 0) or
	  (bks_recoverable_cost > 0 and
	  bks_deprn_reserve >= 0 and
	  bks_ytd_deprn >= 0) then
	if (abs(bks_recoverable_cost) >= abs(bks_deprn_reserve)) or
	   (bks_current_period_flag = 'N') then

          /* mwoodwar 01/18/00.  CRL stub call - don't do the check for CRL. */
          if (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then
            null;
          else

	  if (bks_cost < 0 and bks_salvage_value <> 0) then
	    -- syoung: conditional error messaging.
	    -- add more conditions later when using mass reclass preview
	    -- or for other trx engine modules.
	    if (bks_calling_fn = 'FA_REC_PVT_PKG5.Set_Redef_Transaction') then
		FA_SRVR_MSG.Add_Message(
			CALLING_FN => 'FA_FIN_ADJ1.Update_And_Check_Amts',
			NAME => 'FA_BOOK_NEG_SALVAGE_VALUE',
			 p_log_level_rec => p_log_level_rec);
		raise amt_error;
	    else
	      fnd_message.set_name('OFA', 'FA_BOOK_NEG_SALVAGE_VALUE');
	      app_exception.raise_exception;
	    end if;
	  else
	    if bks_cost > 0 and bks_salvage_value < 0 then
	      -- syoung: conditional error messaging.
	      -- add more conditions later when using mass reclass preview
	      -- or for other trx engine modules.
	      if (bks_calling_fn = 'FA_REC_PVT_PKG5.Set_Redef_Transaction') then
		  FA_SRVR_MSG.Add_Message(
			CALLING_FN => 'FA_FIN_ADJ1.Update_And_Check_Amts',
			NAME => 'FA_BOOK_POS_SALVAGE_VALUE',
			 p_log_level_rec => p_log_level_rec);
	   	  raise amt_error;
	      else
	          fnd_message.set_name('OFA', 'FA_BOOK_POS_SALVAGE_VALUE');
	          app_exception.raise_exception;
	      end if;
	    end if;
	  end if;

          /* End of CRL condition. */
          end if;

	else
          -- syoung: conditional error messaging.
          -- add more conditions later when using mass reclass preview
          -- or for other trx engine modules.
          if (bks_calling_fn = 'FA_REC_PVT_PKG5.Set_Redef_Transaction') then
            FA_SRVR_MSG.Add_Message(
                        CALLING_FN => 'FA_FIN_ADJ1.Update_And_Check_Amts',
                        NAME => 'FA_BOOK_INVALID_RESERVE',
			 p_log_level_rec => p_log_level_rec);
            raise amt_error;
	  else
	    fnd_message.set_name('OFA', 'FA_BOOK_INVALID_RESERVE');
	    app_exception.raise_exception;
	  end if;
	end if;
      else
	-- syoung: conditional messaging.
	if (bks_calling_fn = 'FA_REC_PVT_PKG5.Set_Redef_Transaction') then
	    FA_SRVR_MSG.Add_Message(
			CALLING_FN => 'FA_FIN_ADJ1.Update_And_Check_Amts',
			NAME =>  'FA_BOOK_ALL_POSITIVE',
			 p_log_level_rec => p_log_level_rec);
	    raise amt_error;
	else
	    fnd_message.set_name('OFA', 'FA_BOOK_ALL_POSITIVE');
	    app_exception.raise_exception;
        end if;
      end if;
    else
      -- syoung: conditional messaging.
      if (bks_calling_fn = 'FA_REC_PVT_PKG5.Set_Redef_Transaction') then
	  FA_SRVR_MSG.Add_Message(
			CALLING_FN => 'FA_FIN_ADJ1.Update_And_Check_Amts',
                        NAME =>  'FA_BOOK_ALL_NEGATIVE',
			 p_log_level_rec => p_log_level_rec);
          raise amt_error;
      else
          fnd_message.set_name('OFA', 'FA_BOOK_ALL_NEGATIVE');
          app_exception.raise_exception;
      end if;
    end if;
  end if;

  x_return_status := true;
/*  exception
    when others then
      FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_fin_adj1_pkg.update_and_check_amts',
		CALLING_FN => bks_Calling_Fn,
		 p_log_level_rec => p_log_level_rec); */
exception
    when amt_error then
	x_return_status := false;
    when others then
        if (bks_calling_fn = 'FA_REC_PVT_PKG5.Set_Redef_Transaction') then
 	    FA_SRVR_MSG.Add_SQL_Error(
		CALLING_FN => 'FA_FIN_ADJ1.Update_And_Check_Amts'
		, p_log_level_rec => p_log_level_rec);
	    x_return_status := false;
        end if;

end update_and_check_amts;

procedure chk_val_before_commit(
		bks_cost			in number,
		bks_pc_fully_retired		in number,
		bks_pc_fully_reserved		in out nocopy number,
		bks_depreciation_check		in varchar2,
		bks_current_period_flag		in varchar2,
		bks_recoverable_cost		in number,
		bks_deprn_reserve		in number,
		bks_ytd_deprn			in number,
		bks_salvage_value		in number,
		bks_book_type_code		in varchar2,
		bks_date_placed_in_service	in date,
		bks_rate_source_rule		in varchar2,
		bks_deprn_method_code		in varchar2,
		bks_life_years			in number,
		bks_life_months			in number,
		bks_basic_rate			in number,
		bks_adjusted_rate		in number,
		bks_itc_amount_id		in number,
		bks_ceiling_type		in varchar2,
		bks_depreciate_flag		in varchar2,
		bks_calling_fn			varchar2,
		p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
is
/* BUG# 1487644
   this doesn't work when the entire fiscal year is not defined
   removing joins to deprn periods and going strictly against FY
   -- bridgway  11/14/00
 */
  cursor same_fiscal_year is
    select 'Y'
    from fa_book_controls bc,
	 fa_fiscal_year fy
    where bc.book_type_code = bks_book_type_code
    and   bc.fiscal_year_name = fy.fiscal_year_name
    and   bks_date_placed_in_service between
	  fy.start_date and fy.end_date
    and fy.fiscal_year = bc.current_fiscal_year;

  CURSOR cbachand_part_ret IS
    SELECT 'Y'
    FROM fa_transaction_headers th,
	 fa_book_controls bc,
	 fa_deprn_periods dp
    WHERE th.book_type_code = bks_book_type_code
    AND	  th.book_type_code = bc.book_type_code
    AND	  bc.book_type_code = dp.book_type_code
    AND   th.transaction_type_code = 'PARTIAL RETIREMENT'
    AND   dp.period_counter = bc.last_period_counter +1
    AND   th.transaction_date_entered between
	  dp.calendar_period_open_date and nvl(dp.calendar_period_close_date,
	  sysdate);

  cursor check_rate is
    select 'Y'
    from fa_flat_rates fr, fa_methods mth
    where mth.method_code = bks_deprn_method_code
    and   mth.life_in_months is null
    and   mth.method_id = fr.method_id
    and   fr.basic_rate = bks_basic_rate
    and   fr.adjusted_rate = bks_adjusted_rate;

  cursor check_life is
    select 'Y'
    from fa_methods mth
    where mth.method_code = bks_deprn_method_code
    and   bks_life_years * 12 + bks_life_months = mth.life_in_months;

  cursor check_deprn_flag is
    select 'Y'
    from fa_formulas f, fa_methods mth
    where mth.method_code = bks_deprn_method_code
    and   mth.method_id = f.method_id (+)
    and   ((mth.rate_source_rule = 'PRODUCTION') or
           ((mth.rate_source_rule = 'FORMULA') and
            (instr (f.formula_actual, 'CAPACITY') <> 0)))
    and   bks_depreciate_flag = 'NO';

  check_flag		varchar2(3);
  cbachand_flag		varchar2(3) := 'N';

  h_status		boolean;  -- syoung: dummy boolean.

  h_formula_actual	varchar2(4000);

  message_name		VARCHAR2(50);
  expected_exc		EXCEPTION;

begin

  /* 1. Modified to call another error message routine
     2. Added the code to check the return status of update_and_check_amts(
,p_log_level_rec => p_log_level_rec)
     3. Added the exception block which was commented out. - aling
  */

  if bks_cost is null then
    message_name := 'FA_BOOK_NO_FINANCIAL_INFO';
    raise expected_exc;
    --fnd_message.set_name('OFA', 'FA_BOOK_NO_FINANCIAL_INFO');
    --app_exception.raise_exception;
  end if;

  if bks_pc_fully_retired is not null then
    message_name := 'FA_SHARED_RETIRED_ASSET';
    raise expected_exc;
    --fnd_message.set_name('OFA', 'FA_SHARED_RETIRED_ASSET');
    --app_exception.raise_exception;
  end if;

  if bks_pc_fully_reserved is not null then
    bks_pc_fully_reserved := null;
  end if;

  update_and_check_amts(
		bks_depreciation_check,
		bks_current_period_flag,
		bks_recoverable_cost,
		bks_deprn_reserve,
		bks_ytd_deprn,
		bks_cost,
		bks_salvage_value,
		h_status,	-- syoung: added this local.
		'fa_fin_adj1_pkg.chk_val_before_commit',
		p_log_level_rec);

  if not h_status then
	message_name :=  '';
	raise expected_exc;
  end if;

  if bks_depreciation_check <> 'Y' then
    open same_fiscal_year;
    fetch same_fiscal_year into check_flag;

    if (same_fiscal_year%notfound) then
      if abs(bks_ytd_deprn) > abs(bks_deprn_reserve) then
	message_name := 'FA_BOOK_YTD_EXCEED_RSV';
	raise expected_exc;
	--fnd_message.set_name('OFA', 'FA_BOOK_YTD_EXCEED_RSV');
        --app_exception.raise_exception;
      end if;
    else
      if bks_ytd_deprn <> bks_deprn_reserve then

/* For Bug 839397. YTD deprn and deprn reserve may legitimately be different if
 a partial retirement has occured before depreciation runs. This can occur when
 the method is Following Month and the partial retirement occurs in the period
 when depreciation is set to begin. cbachand 8/12/99 */

        OPEN cbachand_part_ret;
	FETCH cbachand_part_ret INTO cbachand_flag;
	IF cbachand_flag <> 'Y' THEN
	message_name := 'FA_BOOK_RSV_EQL_YTD';
	raise expected_exc;
        END IF;
	CLOSE cbachand_part_ret;
	--fnd_message.set_name('OFA', 'FA_BOOK_RSV_EQL_YTD');
        --app_exception.raise_exception;
      end if;
    end if;

    close same_fiscal_year;
  end if;

  if bks_rate_source_rule = 'FLAT' then
    open check_rate;
    fetch check_rate into check_flag;

    if (check_rate%notfound) then
      close check_rate;
      message_name := 'FA_SHARED_INVALID_METHOD_RATE';
      raise expected_exc;
      --fnd_message.set_name('OFA', 'FA_SHARED_INVALID_METHOD_RATE');
      --app_exception.raise_exception;
    end if;

    close check_rate;
  elsif bks_rate_source_rule = 'FORMULA' then

    SELECT f.formula_actual
    INTO   h_formula_actual
    FROM   fa_formulas f, fa_methods m
    WHERE  m.method_id = f.method_id
    AND    m.method_code = bks_deprn_method_code
    AND    rownum = 1
    ORDER BY m.method_id;

    if instr (h_formula_actual, 'CAPACITY') = 0 then
      open check_life;
      fetch check_life into check_flag;

      if (check_life%notfound) then
        close check_life;
        message_name := 'FA_SHARED_INVALID_METHOD_LIFE';
        raise expected_exc;
        --fnd_message.set_name('OFA', 'FA_SHARED_INVALID_METHOD_LIFE');
        --app_exception.raise_exception;
      end if;
    end if;

  else
    if bks_rate_source_rule <> 'PRODUCTION' then
      open check_life;
      fetch check_life into check_flag;

      if (check_life%notfound) then
	close check_life;
	message_name := 'FA_SHARED_INVALID_METHOD_LIFE';
	raise expected_exc;
	--fnd_message.set_name('OFA', 'FA_SHARED_INVALID_METHOD_LIFE');
        --app_exception.raise_exception;
      end if;

      close check_life;
    end if;
  end if;

  if bks_itc_amount_id is not null and
     bks_ceiling_type = 'RECOVERABLE COST CEILING' then
    message_name := 'FA_BOOK_CANT_ITC_AND_COST_CEIL';
    raise expected_exc;
    --fnd_message.set_name('OFA', 'FA_BOOK_CANT_ITC_AND_COST_CEIL');
    --app_exception.raise_exception;
  end if;

  check_flag := 'N';

  open check_deprn_flag;
  fetch check_deprn_flag into check_flag;

  if check_flag = 'Y' then
    close check_deprn_flag;
    message_name := 'FA_BOOK_INVALID_DEPRN_FLAG';
    raise expected_exc;
    --fnd_message.set_name('OFA', 'FA_BOOK_INVALID_DEPRN_FLAG');
    --app_exception.raise_exception;
  end if;

  close check_deprn_flag;

EXCEPTION
  when expected_exc then
        FA_SRVR_MSG.Add_Message(
                CALLING_FN => 'FA_FIN_ADJ1_PKG.chk_val_before_commit',
                NAME => message_name,
		p_log_level_rec => p_log_level_rec);
        raise;
  when others then
        FA_SRVR_MSG.Add_Message(
                CALLING_FN => 'FA_FIN_ADJ1_PKG.chk_val_before_commit',
                NAME => 'FA_SHARED_INVALID_METHOD_LIFE' ,
		p_log_level_rec => p_log_level_rec);
        raise;

/*  exception
    when others then
      FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_fin_adj1_pkg.chk_val_before_commit',
		CALLING_FN => bks_Calling_Fn,
		p_log_level_rec             => p_log_level_rec, p_log_level_rec => p_log_level_rec); */

end chk_val_before_commit;


procedure check_changes_before_commit(
		bks_row_id			in varchar2,
		bks_amortize_flag		in varchar2,
		bks_prorate_convention_code	in varchar2,
		bks_orig_deprn_reserve		in number,
		bks_orig_reval_reserve		in number,
		bks_orig_ytd_deprn		in number,
		bks_cost			in number,
		bks_recoverable_cost		in number,
		bks_adjusted_rec_cost           in number,
		bks_date_placed_in_service	in date,
		bks_deprn_method_code		in varchar2,
		bks_life_years			in number,
		bks_life_months			in number,
		bks_salvage_value		in number,
		bks_basic_rate_dsp		in number,
		bks_adjusted_rate_dsp		in number,
		bks_bonus_rule			in varchar2,
		bks_ceiling_name		in varchar2,
		bks_production_capacity		in number,
		bks_deprn_reserve		in number,
		bks_ytd_deprn			in number,
		bks_reval_reserve		in number,
		bks_adjusted_cost		in number,
		bks_orig_adjusted_cost		in number,
		bks_reval_ceiling		in number,
		bks_depreciate_flag		in varchar2,
		bks_unit_of_measure		in varchar2,
                bks_global_attribute1           in varchar2,
                bks_global_attribute2           in varchar2,
                bks_global_attribute3           in varchar2,
                bks_global_attribute4           in varchar2,
                bks_global_attribute5           in varchar2,
                bks_global_attribute6           in varchar2,
                bks_global_attribute7           in varchar2,
                bks_global_attribute8           in varchar2,
                bks_global_attribute9           in varchar2,
                bks_global_attribute10          in varchar2,
                bks_global_attribute11          in varchar2,
                bks_global_attribute12          in varchar2,
                bks_global_attribute13          in varchar2,
                bks_global_attribute14          in varchar2,
                bks_global_attribute15          in varchar2,
                bks_global_attribute16          in varchar2,
                bks_global_attribute17          in varchar2,
                bks_global_attribute18          in varchar2,
                bks_global_attribute19          in varchar2,
                bks_global_attribute20          in varchar2,
                bks_global_attribute_category   in varchar2,
		bks_adjustment_required_status  in out nocopy varchar2,
		bks_calling_fn			varchar2,
		p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
is
  cursor exist_to_book_cur is
    select 'Y'
    from fa_books bk
    where bk.rowid = bks_row_id;

  cursor pro_conv_cur is
    select 'Y'
    from fa_books bk
    where bk.prorate_convention_code = bks_prorate_convention_code
    and   bk.rowid = bks_row_id;

  cursor no_changes_made is
    select 'Y'
    from fa_books bk
    where bk.rowid = bks_row_id
    and   bk.cost = bks_cost
    and   bk.recoverable_cost = bks_recoverable_cost
    and   bk.date_placed_in_service = bks_date_placed_in_service
    and   bk.deprn_method_code = bks_deprn_method_code
    and   nvl(bk.life_in_months, 99999) =
	  nvl(bks_life_years * 12 + bks_life_months, 99999)
    and   bk.prorate_convention_code = bks_prorate_convention_code
    and   bk.salvage_value = bks_salvage_value
/* BUG# 1514366
    the rates are already passes in decimal format - no need to convert
    also removing the global attributes from this statement as they have
    not financial impact.
    -- bridgway 11/26/00

    and   nvl(bk.basic_rate, 99999) = nvl(bks_basic_rate_dsp/100, 99999);
    and   nvl(bk.adjusted_rate, 99999) = nvl(bks_adjusted_rate_dsp/100, 99999);
*/
    and   nvl(bk.basic_rate, 99999) = nvl(bks_basic_rate_dsp, 99999)
    and   nvl(bk.adjusted_rate, 99999) = nvl(bks_adjusted_rate_dsp, 99999)
    and   nvl(bk.bonus_rule, 'NULL') = nvl(bks_bonus_rule, 'NULL')
    and   nvl(bk.ceiling_name, 'NULL') = nvl(bks_ceiling_name, 'NULL')
    and   nvl(bk.production_capacity, 99999) =
	  nvl(bks_production_capacity, 99999)
    and   bks_deprn_reserve = bks_orig_deprn_reserve
    and   bks_ytd_deprn = bks_orig_ytd_deprn
    and   nvl(bks_reval_reserve, 0) = nvl(bks_orig_reval_reserve, 0)
    and   bks_adjusted_cost = bks_orig_adjusted_cost
    and   nvl(bks_adjusted_rec_cost,0) = nvl(bk.adjusted_recoverable_cost,0)
    and   nvl(bk.reval_ceiling, 0) = nvl(bks_reval_ceiling, 0)
    and   nvl(bk.global_attribute1,'NULL') = nvl(bks_global_attribute1,'NULL')
    and   nvl(bk.global_attribute2,'NULL') = nvl(bks_global_attribute2,'NULL')
    and   nvl(bk.global_attribute3,'NULL') = nvl(bks_global_attribute3,'NULL')
    and   nvl(bk.global_attribute4,'NULL') = nvl(bks_global_attribute4,'NULL')
    and   nvl(bk.global_attribute5,'NULL') = nvl(bks_global_attribute5,'NULL')
    and   nvl(bk.global_attribute6,'NULL') = nvl(bks_global_attribute6,'NULL')
    and   nvl(bk.global_attribute7,'NULL') = nvl(bks_global_attribute7,'NULL')
    and   nvl(bk.global_attribute8,'NULL') = nvl(bks_global_attribute8,'NULL')
    and   nvl(bk.global_attribute9,'NULL') = nvl(bks_global_attribute9,'NULL')
    and   nvl(bk.global_attribute10,'NULL') = nvl(bks_global_attribute10,'NULL')
    and   nvl(bk.global_attribute11,'NULL') = nvl(bks_global_attribute11,'NULL')
    and   nvl(bk.global_attribute12,'NULL') = nvl(bks_global_attribute12,'NULL')
    and   nvl(bk.global_attribute13,'NULL') = nvl(bks_global_attribute13,'NULL')
    and   nvl(bk.global_attribute14,'NULL') = nvl(bks_global_attribute14,'NULL')
    and   nvl(bk.global_attribute15,'NULL') = nvl(bks_global_attribute15,'NULL')
    and   nvl(bk.global_attribute16,'NULL') = nvl(bks_global_attribute16,'NULL')
    and   nvl(bk.global_attribute17,'NULL') = nvl(bks_global_attribute17,'NULL')
    and   nvl(bk.global_attribute18,'NULL') = nvl(bks_global_attribute18,'NULL')
    and   nvl(bk.global_attribute19,'NULL') = nvl(bks_global_attribute19,'NULL')
    and   nvl(bk.global_attribute20,'NULL') = nvl(bks_global_attribute20,'NULL');

  cursor no_changes_to_dep_flag_uom is
    select 'Y'
    from fa_books bk
    where bk.rowid = bks_row_id
    and   nvl(bk.unit_of_measure, 99999) = nvl(bks_unit_of_measure, 99999);

  cursor no_changes_to_dep_flag is
    select 'Y'
    from fa_books bk
    where bk.rowid = bks_row_id
    and   bk.depreciate_flag = bks_depreciate_flag;

  cursor adjustment_reqd_flag is
    select 'Y'
    from fa_books bk,
         fa_transaction_headers th,
         fa_deprn_summary ds
    where bk.rowid = bks_row_id
    and   bks_depreciate_flag = 'YES'
    and   bk.depreciate_flag  = 'NO'
    and   bk.transaction_header_id_in = th.transaction_header_id
    and   th.transaction_type_code = 'ADDITION'
    and   th.book_type_code = bk.book_type_code
    and   ds.asset_id = bk.asset_id
    and   ds.deprn_reserve = 0
    and   ds.book_type_code = bk.book_type_code
    and   ds.deprn_source_code = 'BOOKS';


  exist_to_book_flag		varchar(2) := 'N';
  check_flag			varchar(2);
  no_changes_made_flag		varchar(2) := 'N';

begin
  open exist_to_book_cur;
  fetch exist_to_book_cur into exist_to_book_flag;
  close exist_to_book_cur;


  if exist_to_book_flag = 'Y' then
  /*  if bks_amortize_flag = 'YES' then
      open pro_conv_cur;
      fetch pro_conv_cur into check_flag;

      if (pro_conv_cur%notfound) then
        close pro_conv_cur;
	fnd_message.set_name('OFA', 'FA_CANNOT_AMORTIZE_PRORATE_CHE');
    	app_exception.raise_exception;
      end if;

      close pro_conv_cur;
    end if; */

    open no_changes_made;
    fetch no_changes_made into no_changes_made_flag;
    close no_changes_made;

    if no_changes_made_flag = 'Y' then
      open no_changes_to_dep_flag_uom;
      fetch no_changes_to_dep_flag_uom into check_flag;

      if (no_changes_to_dep_flag_uom%found) then
	close no_changes_to_dep_flag_uom;
        open no_changes_to_dep_flag;           -- fix for bug 563327
        fetch no_changes_to_dep_flag into check_flag;
        if (no_changes_to_dep_flag%found) then
           close no_changes_to_dep_flag;
           fnd_message.set_name('OFA', 'FA_SHARED_NO_CHANGES_TO_COMMIT');
           app_exception.raise_exception;
        else
           open adjustment_reqd_flag;
           fetch adjustment_reqd_flag into check_flag;
           if (adjustment_reqd_flag%found) then
               bks_adjustment_required_status := 'ADD';
           end if;
           close adjustment_reqd_flag;
        end if;

        close no_changes_to_dep_flag;
      else
        close no_changes_to_dep_flag_uom;
      end if;                                   -- fix for bug 563327
    else
      open no_changes_to_dep_flag;
      fetch no_changes_to_dep_flag into check_flag;

      if (no_changes_to_dep_flag%notfound) then
	close no_changes_to_dep_flag;
	fnd_message.set_name('OFA', 'FA_BK_NO_MULTIPLE_CHANGES');
    	app_exception.raise_exception;
      end if;

      close no_changes_to_dep_flag;
    end if;

  end if;

/*  exception
    when others then
      FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_fin_adj1_pkg.check_changes_before_commit',
		CALLING_FN => bks_Calling_Fn,
		 p_log_level_rec => p_log_level_rec); */
end check_changes_before_commit;

END FA_FIN_ADJ1_PKG;

/
