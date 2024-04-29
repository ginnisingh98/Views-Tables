--------------------------------------------------------
--  DDL for Package Body FA_FIN_ADD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FIN_ADD_PKG" as
/* $Header: faxfaddb.pls 120.4.12010000.2 2009/07/19 13:23:44 glchen ship $ */

-- syoung: added x_return_status.
procedure gen_deprn_start_date(
		bks_date_placed_in_service	in date,
		bks_deprn_start_date		in out nocopy date,
		bks_prorate_convention_code	in varchar2,
		bks_fiscal_year_name		in varchar2,
		bks_prorate_date		in date,
		x_return_status		 out nocopy boolean,
		bks_calling_fn			in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
is
  cursor get_dwaf is
    select depr_when_acquired_flag
    from fa_convention_types ct
    where ct.prorate_convention_code = bks_prorate_convention_code
    and ct.fiscal_year_name = bks_fiscal_year_name;

  dwaf		varchar2(3) := 'NO';

begin
  open get_dwaf;
  fetch get_dwaf into dwaf;

  if (get_dwaf%notfound) then
    close get_dwaf;
    fnd_message.set_name('OFA', 'FA_FE_CALC_DEPRN_DATE');
    app_exception.raise_exception;
  end if;

  close get_dwaf;

  if (dwaf = 'YES') then
    bks_deprn_start_date := bks_date_placed_in_service;
  else
    bks_deprn_start_date := bks_prorate_date;
  end if;

  x_return_status := true;
  exception
    when others then
      if (bks_calling_fn = 'fa_books_val.dpis_val' or
	  bks_calling_fn = 'fa_books_val3.conv_code_val') then
	-- called from forms validation module
          FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_fin_add_pkg.get_deprn_start_date',
		CALLING_FN => Bks_Calling_Fn, p_log_level_rec => p_log_level_rec);
      else
          FA_SRVR_MSG.Add_SQL_Error(
		CALLING_FN => 'FA_FIN_ADD_PKG.gen_deprn_start_date',  p_log_level_rec => p_log_level_rec);
      end if;
      x_return_status := false;

end gen_deprn_start_date;
--
PROCEDURE BOOK_VAL(X_Book_Type_Code	VARCHAR2,
		X_Asset_Type		VARCHAR2,
		X_Category_Id		NUMBER,
		X_Asset_Id		NUMBER,
		X_DPIS			IN OUT NOCOPY DATE,
		X_Expense_Acct		IN OUT NOCOPY VARCHAR2,
		X_Acct_Flex_Num		IN OUT NOCOPY NUMBER,
		X_Calling_Fn		VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
IS
lv_count	number;
l_grp_count NUMBER :=0; --HH GROUP ED.
lv_mesg		varchar2(30);
h_status	boolean; -- syoung: dummy boolean.
validation_error	exception;
BEGIN

   h_status := FA_FIN_ADD_PKG.CAT_VAL(X_Book_Type_Code => X_Book_Type_Code,
			X_Asset_Type => X_Asset_Type,
			X_Category_Id => X_Category_Id,
			X_Stack_Mesg => 'NO',
			X_Calling_Fn => 'FA_FIN_ADD_PKG.BOOK_VAL', p_log_level_rec => p_log_level_rec);
   -- check that book is valid
   -- syoung: performance tuning: count(*) to count(1)
   -- and inserted rownum condition.

   select count(1)
   into lv_count
   from fa_book_controls
   where book_type_code = X_BOOK_TYPE_CODE
   and  nvl(date_ineffective, sysdate+1) > sysdate
   and rownum < 2;
   --
   if lv_count = 0 then
      lv_mesg := 'FA_BOOK_INEFFECTIVE_BOOK';
      raise validation_error;
   end if;
   /*-- HH Group ed.
   -- Check if defaulted group is enabled.  Check is needed because of the
   -- requirement not to null out the default group asset for a category when
   -- a group is disabled.  However, we can't assign an asset to a disabled group. */
   SELECT count(1)
   INTO  l_grp_count
   FROM  fa_category_book_defaults cbd, fa_books bks
   WHERE cbd.category_id =  X_Category_Id
   AND   cbd.book_type_code = X_BOOK_TYPE_CODE
   AND   cbd.book_type_code = bks.book_type_code
   AND   cbd.group_asset_id = bks.asset_id
   AND   bks.Date_Placed_In_Service between cbd.start_dpis and
                     nvl(cbd.end_dpis,bks.Date_Placed_In_Service)
   AND   bks.date_ineffective is null
   AND   NVL(bks.disabled_flag, 'N') = 'Y';
   --
   if l_grp_count > 0 then
      lv_mesg := 'FA_DISABLED_DEFAULT_GROUP';
      raise validation_error;
   end if; -- end HH.
   --
   if X_ASSET_ID is not null then
      -- check that asset is not already in this book
      -- syoung: performance tuning: count(*) to count(1)
      -- and inserted rownum condition.
      select count(1)
      into lv_count
      from fa_books
      where asset_id = X_ASSET_ID
      and book_type_code = X_BOOK_TYPE_CODE
      and date_ineffective is null
      and rownum < 2;
      --
      if lv_count > 0 then
	 lv_mesg := 'FA_QAA_ASSET_IN_BOOK';
	 raise validation_error;
      end if;
      --  check that asset has not been added to another Corp book
      -- syoung: performance tuning: count(*) to count(1)
      -- and inserted rownum condition.
      select count(1)
      into lv_count
      from fa_books bk, fa_book_controls bc
      where bk.asset_id= X_ASSET_ID
      and bk.book_type_code <> X_BOOK_TYPE_CODE
      and bk.date_ineffective is null
      and bk.book_type_code = bc.book_type_code
      and bc.book_class = 'CORPORATE'
      and rownum < 2;
      --
      if lv_count > 0 then
	 lv_mesg := 'FA_BOOK_ASSET_ALREADY_ASSIGN';
	 raise validation_error;
      end if;
   end if; /* if X_ASSET_ID is not null */
   --
   -- default date placed in service
   select greatest(dp.calendar_period_open_date,
		   least(sysdate,dp.calendar_period_close_date))
   into X_DPIS
   from fa_deprn_periods  dp
   where dp.book_type_code = X_BOOK_TYPE_CODE
   and dp.period_close_date is null;
   --
   -- get acct flex info

   select deprn_expense_acct
   into X_EXPENSE_ACCT
   from fa_category_books
   where category_id = X_CATEGORY_ID
   and book_type_code = X_BOOK_TYPE_CODE;
   --

   select accounting_flex_structure
   into X_ACCT_FLEX_NUM
   from fa_book_controls
   where book_type_code = X_BOOK_TYPE_CODE;
   --
EXCEPTION
   when validation_error then
	FA_STANDARD_PKG.RAISE_ERROR
		(Called_Fn => 'FA_FIN_ADD_PKG.BOOK_VAL',
		Calling_Fn => X_CALLING_FN,
		Name => lv_mesg, p_log_level_rec => p_log_level_rec);

   when others then
	FA_STANDARD_PKG.RAISE_ERROR
		(Called_Fn => 'FA_FIN_ADD_PKG.BOOK_VAL',
		Calling_Fn => X_CALLING_FN,
		Name => lv_mesg, p_log_level_rec => p_log_level_rec);
END BOOK_VAL;
--
PROCEDURE DPIS_VAL
	(X_DPIS				DATE,
	X_Category_Id			NUMBER,
	X_Book_Type_Code		VARCHAR2,
	X_Prorate_Convention_Code	IN OUT NOCOPY VARCHAR2,
	X_Prorate_Date			IN OUT NOCOPY DATE,
	X_Calling_Fn			VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
IS
lv_count	number;
lv_mesg		varchar2(30);
validation_error	exception;
BEGIN
-- dpis must not be in a future period
select count(*)
into lv_count
from fa_deprn_periods
where book_type_code = X_BOOK_TYPE_CODE
and period_close_date is null
and X_DPIS > calendar_period_close_date;
--
if lv_count > 0 then
   lv_mesg := 'FA_SHARED_FUTURE_DPIS';
   raise validation_error;
end if;
-- default prorate convention code
select prorate_convention_code
into X_PRORATE_CONVENTION_CODE
from fa_category_book_defaults
where book_type_code = X_BOOK_TYPE_CODE
and category_id = X_CATEGORY_ID
and X_DPIS between start_dpis and nvl(end_dpis, X_DPIS);
--
-- get prorate date
begin
   select prorate_date
   into X_PRORATE_DATE
   from fa_conventions
   where prorate_convention_code = X_PRORATE_CONVENTION_CODE
   and X_DPIS between start_date and end_date;
   --
   exception
	when no_data_found then
	   lv_mesg := 'FA_BOOK_CANT_GEN_PRORATE_DATE';
	   raise validation_error;
end;
-- check prorate date
select count(*)
into lv_count
from   fa_calendar_periods cp,
       fa_book_controls bc
where  bc.book_type_code = X_BOOK_TYPE_CODE
and    bc.prorate_calendar = cp.calendar_type
and    X_PRORATE_DATE between cp.start_date and cp.end_date;
--
if lv_count = 0 then
   lv_mesg := 'FA_QAA_INVALID_PRORATE_DATE';
   raise validation_error;
end if;
--
EXCEPTION
   when validation_error then
	FA_STANDARD_PKG.RAISE_ERROR
		(Called_Fn => 'FA_FIN_ADD_PKG.DPIS_VAL',
		Calling_Fn => X_CALLING_FN,
		Name => lv_mesg, p_log_level_rec => p_log_level_rec);
   when others then
	FA_STANDARD_PKG.RAISE_ERROR
		(Called_Fn => 'FA_FIN_ADD_PKG.DPIS_VAL',
		Calling_Fn => X_CALLING_FN, p_log_level_rec => p_log_level_rec);
END DPIS_VAL;
--
-- syoung: changed procedure to function.
FUNCTION CAT_VAL(X_Book_Type_Code	VARCHAR2,
		X_Asset_Type		VARCHAR2,
		X_Category_Id		NUMBER,
		X_Stack_Mesg		VARCHAR2 DEFAULT 'NO',
		X_Calling_Fn		VARCHAR2
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)RETURN BOOLEAN IS
lv_mesg			varchar2(50);
validation_error	exception;
lv_count		number;
BEGIN
   if X_ASSET_TYPE = 'CIP' then
      -- check that CIP accounts are set up
      -- syoung: count(*) to count(1)
      -- and inserted rownum condition.
      select count(1)
      into lv_count
      from fa_category_books
      where category_id = X_CATEGORY_ID
      and book_type_code = X_BOOK_TYPE_CODE
      and cip_cost_acct is not null
      and cip_clearing_acct is not null
      and rownum < 2;
      --
      if lv_count = 0 then
	   lv_mesg := 'FA_SHARED_NO_CIP_ACCOUNTS';
	   raise validation_error;
      end if;
   end if;

   -- check if cat is set up in this book
   -- syoung: count(*) to count(1)
   -- and inserted rownum condition.
   if (X_Stack_Mesg = 'NO') then
   -- This check is already done in the reclass validation engine
   -- for mass reclass before getting to this part.
   -- Do this check only for single reclass.
       select count(1)
       into lv_count
       from fa_category_books
       where book_type_code = X_BOOK_TYPE_CODE and
       category_id = X_CATEGORY_ID
       and rownum < 2;
       --
       if lv_count = 0 then
          lv_mesg := 'FA_BOOK_CAT_NOT_SET_UP';
          raise validation_error;
       end if;
   end if;

   return (true);

EXCEPTION
   when validation_error then
	if (X_Stack_Mesg = 'NO') then
	-- invoke client-side mesg.
	    FA_STANDARD_PKG.RAISE_ERROR
		(Called_Fn => 'FA_FIN_ADD_PKG.CAT_VAL',
		Calling_Fn => X_CALLING_FN,
		Name => lv_mesg, p_log_level_rec => p_log_level_rec);
	else
	    FA_SRVR_MSG.Add_Message(
		Calling_Fn => 'FA_FIN_ADD_PKG.CAT_VAL',
		 Name => lv_mesg,  p_log_level_rec => p_log_level_rec);
	end if;
	return (false);
   when others then
	if (X_Stack_Mesg = 'NO') then
	-- invoke client-side mesg.
	    FA_STANDARD_PKG.RAISE_ERROR
		(Called_Fn => 'FA_FIN_ADD_PKG.CAT_VAL',
		Calling_Fn => X_CALLING_FN, p_log_level_rec => p_log_level_rec);
	else
	    FA_SRVR_MSG.Add_SQL_Error(
		Calling_Fn => 'FA_FIN_ADD_PKG.CAT_VAL',  p_log_level_rec => p_log_level_rec);
	end if;
	return (false);
END Cat_Val;
--
END FA_FIN_ADD_PKG;

/
