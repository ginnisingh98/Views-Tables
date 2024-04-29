--------------------------------------------------------
--  DDL for Package Body FA_FAS443_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS443_XMLP_PKG" AS
/* $Header: FAS443B.pls 120.1.12010000.1 2008/07/28 13:14:38 appldev ship $ */
function BookFormula return VARCHAR2 is
begin
DECLARE
  l_book       VARCHAR2(15);
  l_book_class VARCHAR2(15);
  l_accounting_flex_structure NUMBER(15);
  l_currency_code VARCHAR2(15);
  l_distribution_source_book VARCHAR2(15);
  l_precision NUMBER(15);
BEGIN
  SELECT bc.book_type_code,
         bc.book_class,
         bc.accounting_flex_structure,
         bc.distribution_source_book,
         sob.currency_code,
         cur.precision
  INTO   l_book,
         l_book_class,
         l_accounting_flex_Structure,
         l_distribution_source_book,
         l_currency_code,
         l_precision
  FROM   FA_BOOK_CONTROLS bc,
         GL_SETS_OF_BOOKS sob,
         FND_CURRENCIES cur
  WHERE  bc.book_type_code = P_BOOK
  AND    sob.set_of_books_id = bc.set_of_books_id
  AND    sob.currency_code    = cur.currency_code;
  Book_Class := l_book_class;
  Accounting_Flex_Structure:=l_accounting_flex_structure;
  Distribution_SOurce_Book :=l_distribution_source_book;
  Currency_Code := l_currency_code;
  Precision := l_precision;
  fnd_profile.get('PRINT_DEBUG',print_debug);
  return(l_book);
END;
RETURN NULL; end;
function Period1Formula return VARCHAR2 is
begin
DECLARE
  l_period_name VARCHAR2(15);
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
BEGIN
  SELECT period_name,
         period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_name,
         l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
  Period1_PC := l_period_PC;
  Period1_POD := l_period_POD;
  Period1_PCD := l_period_PCD;
  Period1_FY  := l_period_FY;
  return(l_period_name);
END;
RETURN NULL; end;
function report_nameformula(Company_Name in varchar2) return varchar2 is
begin
DECLARE
  l_report_name VARCHAR2(80);
  l_conc_program_id NUMBER;
BEGIN
--Added during DT Fix
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
--End of DT Fix
  RP_Company_Name := Company_Name;
  SELECT cr.concurrent_program_id
  INTO l_conc_program_id
  FROM FND_CONCURRENT_REQUESTS cr
  WHERE cr.program_application_id = 140
  AND   cr.request_id = P_CONC_REQUEST_ID;
  SELECT cp.user_concurrent_program_name
  INTO   l_report_name
  FROM    FND_CONCURRENT_PROGRAMS_VL cp
  WHERE
      cp.concurrent_program_id= l_conc_program_id
  and cp.application_id = 140;
  l_report_name := substr(l_report_name,1,instr(l_report_name,' (XML)'));
  RP_Report_Name := l_report_name;
  RETURN(l_report_name);
EXCEPTION
  WHEN OTHERS THEN
    RP_Report_Name := 'Form 4797 - Gain From Disposition of 1245 Property Report';
    RETURN(RP_Report_Name);
END;
RETURN NULL; end;
function Period2Formula return VARCHAR2 is
begin
DECLARE
  l_period_name VARCHAR2(15);
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
BEGIN
  SELECT period_name,
         period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_name,
         l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD2;
  Period2_PC := l_period_PC;
  Period2_POD := l_period_POD;
  Period2_PCD := l_period_PCD;
  Period2_FY  := l_period_FY;
  return(l_period_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
         Period2_PC := Period1_PC;
         Period2_POD := Period1_POD;
         Period2_PCD := Period1_PCD;
         Period2_FY := Period1_FY;
    return(P_PERIOD1);
END;
RETURN NULL; end;
function BeforeReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWINIT');*/null;
  return (TRUE);
end;
function AfterReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
function GAIN_NLSFormula return VARCHAR2 is
begin
  DECLARE
     l_meaning	VARCHAR2(80);
  BEGIN
    select MEANING
    into   l_meaning
    from   FA_LOOKUPS
    where  LOOKUP_TYPE = 'GAINLOSS'
    and    LOOKUP_CODE = 'GAIN';
    return (l_meaning);
    EXCEPTION
      WHEN OTHERS THEN
         return (null);
  END;
RETURN NULL; end;
function LOSS_NLSFormula return VARCHAR2 is
begin
  DECLARE
     l_meaning	VARCHAR2(80);
  BEGIN
    select MEANING
    into   l_meaning
    from   FA_LOOKUPS
    where  LOOKUP_TYPE = 'GAINLOSS'
    and    LOOKUP_CODE = 'LOSS';
    return (l_meaning);
    EXCEPTION
      WHEN OTHERS THEN
         return (null);
  END;
RETURN NULL; end;
function d_gain_1962formula (book in varchar2, asset_id in number, reserve in number, gain in number, ord_income in number, cap_gain in number) return number is
  true_or_false 	number;
  ret 			boolean;
  before_1962		boolean := true;
  no_errors		boolean := true;
  h_calendar_type 	varchar2(30);
  h_fy_name     	fa_fiscal_year.fiscal_year_name%type;
  h_prorate_fy  	number;
  h_cur_per_num 	number;
  h_num_per_fy  	number;
  h_cur_fy      	number;
  h_prorate_start_year 	number;
  dpr_in  	fa_std_types.dpr_struct;
  dpr_out 	fa_std_types.dpr_out_struct;
  dpr_arr 	fa_std_types.dpr_arr_type;
  X_BOOK 		varchar2(15);
  X_ASSET_ID		number;
  h_new_deprn_rsv    	number;
  l_dpis		date;
  l_deprn_rsv_1962 	number := 0;
  l_diff_reserve 	number;
  h_dpr_date 		date;    h_current_cost 	number;   h_itc_amount_id 	number;  h_itc_basis 		number;  h_ceiling_Type  	varchar2(50);
  l_new_gain_loss 		number;
  l_new_ordinary_income		number;
  l_new_capital_gain		number;
  l_cost_retired		number;
  l_ttcode			fa_transaction_headers.transaction_type_code%TYPE;
  l_main_dpis			date;
  l_date_retired			date;
  l_date_retired_year		number;
  previous_y_end 		number;
  previous_p_cl_end 		number;
  previous_end_date		date;
  l_method_code			fa_methods.method_code%TYPE;
  l_rate_source_rule		fa_methods.rate_source_rule%TYPE;
cursor c_rsr is
  select rate_source_rule
  from fa_methods
  where method_code = l_method_code;
  l_start_date 		date;
  l_fiscal_year_name	fa_fiscal_year.fiscal_year_name%type;
cursor c_end is
   	select period_num, cp.start_date, fiscal_year_name
      	from fa_calendar_periods cp,
	   fa_book_controls bc
      	where calendar_type = bc.deprn_calendar
      	and bc.book_type_code = x_book
      	and  start_date  >=  previous_end_date
	order by start_date;
cursor c_ret is
  SELECT	decode (mt.rate_source_rule,
			'CALCULATED',	bk.prorate_date,
                        'FORMULA',      bk.prorate_date,
			'TABLE',	bk.deprn_start_date,
			'FLAT',		decode (mt.deprn_basis_rule,
						'COST',	bk.prorate_date,
						'NBV',	bk.deprn_start_date),
                        'PROD',         bk.date_placed_in_service),
                to_number (to_char (bk.prorate_date, 'J')),
		to_number (to_char (bk.date_placed_in_service, 'J')),
                to_number (to_char (bk.deprn_start_date, 'J')),
		nvl(bk.life_in_months, 0),
		bk.recoverable_cost,
		bk.adjusted_cost,
		bk.cost,
                nvl(bk.reval_amortization_basis, 0),
		bk.rate_adjustment_factor,
		nvl(bk.adjusted_rate, 0),
		bk.ceiling_name,
		bk.bonus_rule,
                nvl (bk.production_capacity, 0),
                nvl (bk.adjusted_capacity, 0),
		mt.method_code,
		ad.asset_number,
                nvl (bk.adjusted_recoverable_cost, bk.recoverable_cost),
                bk.salvage_value,
		bk.period_counter_life_complete,
		bk.annual_deprn_rounding_flag,
		bk.itc_amount_id,
		bk.itc_basis,
		ceilt.ceiling_type,
                nvl(bk.formula_factor, 1),
                nvl(bk.short_fiscal_year_flag, 'NO'),
                bk.conversion_date,
                bk.original_deprn_start_date,
                bk.prorate_date,
		to_number(to_char(bk.prorate_date,'YYYY')),
		bk.date_placed_in_service,
		ret.cost_retired,
		ret.date_retired,
		to_number(to_char(ret.date_retired,'YYYY')),
		th.transaction_type_code
  FROM	fa_ceiling_types ceilt,
		fa_methods mt,
		fa_category_books cb,
		fa_books bk,
		fa_retirements ret,
		fa_transaction_headers th,
		fa_additions ad
  WHERE	cb.book_type_code = X_book
	AND	ad.asset_category_id = cb.category_id
	AND	ceilt.ceiling_name(+) = bk.ceiling_name
	AND	mt.method_code = bk.deprn_method_code
	AND	bk.book_type_code = X_book
	AND	bk.asset_id = X_asset_id
	AND	bk.transaction_header_id_out = th.transaction_header_id
	AND 	ret.status = 'PROCESSED'
	AND  	th.transaction_type_code in ('FULL RETIREMENT','PARTIAL RETIREMENT')
	AND 	ret.transaction_header_id_in = th.transaction_header_id
	AND	nvl (mt.life_in_months, -9999) =
			nvl (bk.life_in_months, -9999)
	AND	ad.asset_id = bk.asset_id
 ORDER BY th.transaction_header_id;
  rakn 	number := 0;
BEGIN
if print_debug = 'Y' then
   /*srw.message(9999,'Starting d_gain_1962 function');*/null;
   /*srw.message(9999,book_class);*/null;
   /*srw.message(9999,book);*/null;
   /*srw.message(9999,asset_number);*/null;
   /*srw.message(9999, asset_id);*/null;
end if;
X_BOOK := book;
x_asset_id := asset_id;
if book_class = 'TAX'  then
  dpr_in.book		:= x_book;
  dpr_in.asset_id	:= x_asset_id;
  select deprn_reserve, ytd_deprn, bk.date_placed_in_service, bk.deprn_method_code
  into dpr_in.deprn_rsv, dpr_in.ytd_deprn, l_main_dpis, l_method_code
  from fa_deprn_summary ds,
	fa_books bk,
	fa_transaction_headers th
  where ds.book_type_code = X_book
  and   ds.asset_id = X_asset_id
  and   ds.deprn_source_code = 'BOOKS'
  and 	th.transaction_header_id = bk.transaction_header_id_in
  and   th.transaction_header_id in (select max(transaction_header_id)
				from fa_transaction_headers thsub
				where transaction_type_code like '%RETIREMENT'
				and   book_type_code = x_book
				and   asset_id = x_asset_id)
;
 open c_rsr;
 fetch c_rsr into l_rate_source_rule;
 close c_rsr;
 if l_main_dpis < to_date('19611231','YYYYMMDD')
	and l_rate_source_rule <> 'CALCULATED'     then
  dpr_in.reval_rsv		   	:= 0;
  dpr_in.ltd_prod		   	:= 0;
  dpr_in.old_adj_cost			:= 0;
  dpr_in.prior_fy_exp 			:= 0;
  dpr_in.reval_rsv 			:= 0;
  dpr_in.ltd_prod 			:= 0;
  select 	bc.deprn_calendar,
		bc.fiscal_year_name,
		ct.number_per_fiscal_year
  into h_calendar_type, h_fy_name, h_num_per_fy
  from fa_book_controls bc, fa_calendar_types ct
  where bc.book_type_code = X_book
  and bc.deprn_calendar = ct.calendar_type;
  dpr_in.calendar_type := h_calendar_type;
  dpr_in.jdate_retired := 0;
  dpr_in.ret_prorate_jdate := 0;
  dpr_in.rsv_known_flag := TRUE;
  dpr_in.prior_fy_exp := 0;
  dpr_in.used_by_adjustment:= FALSE;
  dpr_in.deprn_override_flag := 'N';
  OPEN C_RET;
  FETCH C_RET
  INTO	h_dpr_date,
		dpr_in.prorate_jdate,
		dpr_in.jdate_in_service,
		dpr_in.deprn_start_jdate,
		dpr_in.life,
		dpr_in.rec_cost,
		dpr_in.adj_cost,
		h_current_cost,
		dpr_in.reval_amo_basis,
		dpr_in.rate_adj_factor,
		dpr_in.adj_rate,
		dpr_in.ceil_name,
		dpr_in.bonus_rule,
		dpr_in.capacity,
		dpr_in.adj_capacity,
		dpr_in.method_code,
		dpr_in.asset_num,
		dpr_in.adj_rec_cost,
		dpr_in.salvage_value,
		dpr_in.pc_life_end,
		dpr_in.deprn_rounding_flag,
		h_itc_amount_id,
		h_itc_basis,
		h_ceiling_Type,
                dpr_in.formula_factor,
                dpr_in.short_fiscal_year_flag,
                dpr_in.conversion_date,
                dpr_in.orig_deprn_start_date,
                dpr_in.prorate_date,
		h_prorate_start_year,
		l_dpis,
		l_cost_retired,
		l_date_retired,
		l_date_retired_year,
		l_ttcode;
 WHILE C_RET%FOUND  AND BEFORE_1962 LOOP
  if print_debug = 'Y' then
    /*srw.message(9999,dpr_in.adj_cost);*/null;
    /*srw.message(9999,dpr_in.rec_cost);*/null;
    /*srw.message(9999,h_current_cost);*/null;
    /*srw.message(9999,l_dpis);*/null;
    /*srw.message(9999,h_prorate_start_year);*/null;
  end if;
   rakn := rakn + 1;
   if rakn = 1 then
        dpr_in.y_begin	    := h_prorate_start_year;
	select period_num
	into dpr_in.p_cl_begin
	from fa_calendar_periods cp,
		fa_book_controls bc
	where calendar_type = bc.deprn_calendar
	and 	bc.book_type_code = x_book
	and    dpr_in.prorate_date
		between cp.start_date and cp.end_date;
    	if l_date_retired > to_date('19611231','YYYYMMDD')  then
		dpr_in.y_end		:= 1961;
     		select max(period_num)
     		into dpr_in.p_cl_end
     		from fa_deprn_periods
     		where book_type_code = X_book;
		previous_end_date := to_date('19611231','YYYYMMDD');
        else
	        dpr_in.y_end := l_date_retired_year;
		select period_num
		into dpr_in.p_cl_end
		from 	fa_calendar_periods cp,
			fa_book_controls bc
		where calendar_type = bc.deprn_calendar
		and 	bc.book_type_code = x_book
		and    l_date_retired
			between cp.start_date and cp.end_date;
		previous_end_date := l_date_retired;
    	end if;
   else
	open c_end;
	fetch c_end into dpr_in.p_cl_begin, l_start_date, l_fiscal_year_name;
	fetch c_end into dpr_in.p_cl_begin, l_start_date, l_fiscal_year_name;
	close c_end;
	select fiscal_year
	into dpr_in.y_begin
	from fa_fiscal_year
	where fiscal_year_name = l_fiscal_year_name
	and l_start_date between start_date and end_date;
     if l_date_retired > to_date('19611231','YYYYMMDD')  then
		dpr_in.y_end		:= 1961;
		select period_num
		into dpr_in.p_cl_end
		from 	fa_calendar_periods cp,
			fa_book_controls bc
		where calendar_type = bc.deprn_calendar
		and 	bc.book_type_code = x_book
		and    to_date('19611231','YYYYMMDD')
			between cp.start_date and cp.end_date;
		previous_end_date := to_date('19611231','YYYYMMDD');
     else
	        dpr_in.y_end := l_date_retired_year;
		select period_num
		into dpr_in.p_cl_end
		from 	fa_calendar_periods cp,
			fa_book_controls bc
		where calendar_type = bc.deprn_calendar
		and 	bc.book_type_code = x_book
		and    l_date_retired
			between cp.start_date and cp.end_date;
		previous_end_date := l_date_retired;
     end if;
   end if;
   if print_debug = 'Y' then
     /*srw.message(9999,'y_begin: ' || to_char(dpr_in.y_begin));*/null;
     /*srw.message(9999,'p_cl_begin: ' || to_char(dpr_in.p_cl_begin));*/null;
     /*srw.message(9999,'y_end: ' || to_char(dpr_in.y_end));*/null;
     /*srw.message(9999,'p_cl_end: ' || to_char(dpr_in.p_cl_end));*/null;
   end if;
   dpr_in.bonus_deprn_exp         := 0;
   dpr_in.bonus_ytd_deprn	 := 0;
   dpr_in.bonus_deprn_rsv	 := 0;
   dpr_in.prior_fy_bonus_exp	 := 0;
   if not fa_cache_pkg.fazcbc(X_book => X_book) then
     no_errors := false;
     /*srw.message(9999,'fazcbc returned FALSE');*/null;
   end if;
    ret := fa_cde_pkg.faxcde (
	dpr_in => dpr_in,
	dpr_arr => dpr_arr,
	dpr_out => dpr_out,
	fmode => 1);
    if (ret = FALSE) then
      /*srw.message(9999,'faxcde returned FALSE');*/null;
      no_errors := false;
    end if;
    h_new_deprn_rsv := dpr_out.new_deprn_rsv;
    l_deprn_rsv_1962 := l_deprn_rsv_1962 + round(h_new_deprn_rsv,precision);
   if print_debug = 'Y' then
      /*srw.message(9999, 'deprn_rsv_1962: ' || to_char(l_deprn_rsv_1962) );*/null;
      /*srw.message(9999, 'New_deprn_rsv: ' || to_char(dpr_out.new_deprn_rsv) );*/null;
      /*srw.message(9999,dpr_out.new_adj_cost);*/null;
    end if;
    if l_date_retired > to_date('19611231','YYYYMMDD')  then
	before_1962 := false;
    end if;
  FETCH C_RET
  INTO	h_dpr_date,
		dpr_in.prorate_jdate,
		dpr_in.jdate_in_service,
		dpr_in.deprn_start_jdate,
		dpr_in.life,
		dpr_in.rec_cost,
		dpr_in.adj_cost,
		h_current_cost,
		dpr_in.reval_amo_basis,
		dpr_in.rate_adj_factor,
		dpr_in.adj_rate,
		dpr_in.ceil_name,
		dpr_in.bonus_rule,
		dpr_in.capacity,
		dpr_in.adj_capacity,
		dpr_in.method_code,
		dpr_in.asset_num,
		dpr_in.adj_rec_cost,
		dpr_in.salvage_value,
		dpr_in.pc_life_end,
		dpr_in.deprn_rounding_flag,
		h_itc_amount_id,
		h_itc_basis,
		h_ceiling_Type,
                dpr_in.formula_factor,
                dpr_in.short_fiscal_year_flag,
                dpr_in.conversion_date,
                dpr_in.orig_deprn_start_date,
                dpr_in.prorate_date,
		h_prorate_start_year,
		l_dpis,
		l_cost_retired,
		l_date_retired,
		l_date_retired_year,
		l_ttcode;
   END LOOP;
   close c_ret;
   if no_errors then
      l_diff_reserve := reserve - l_deprn_rsv_1962;
      l_new_gain_loss := gain - l_diff_reserve;
      if print_debug = 'Y' then
         /*srw.message(9991,'deprn_rsv_1962: ' || to_char(l_deprn_rsv_1962));*/null;
         /*srw.message(9992,'diff_reserve: ' || to_char(l_diff_reserve));*/null;
         /*srw.message(9992,'reserve_retired: ' || to_char(reserve));*/null;
         /*srw.message(99931,'new_capital_gain: '  || to_char(l_new_gain_loss));*/null;
         /*srw.message(99932,'gain_loss: ' || to_char(gain));*/null;
      end if;
      if gain < l_diff_reserve then
	l_new_ordinary_income := gain;
 	l_new_capital_gain :=   0;
      else
        l_new_ordinary_income := l_diff_reserve;
	l_new_capital_gain := l_new_gain_loss;
      end if;
      if print_debug = 'Y' then
         /*srw.message(9994,l_new_ordinary_income);*/null;
         /*srw.message(9995,l_new_capital_gain);*/null;
      end if;
      d_ord_income_1962 := l_new_ordinary_income;
      d_cap_gain_1962  := l_new_capital_gain;
      true_or_false := 1;
    else
      d_ord_income_1962 := ord_income;
      d_cap_gain_1962 := cap_gain;
      true_or_false  := 0;
      if print_debug = 'Y' then
         /*srw.message(9996,'else no_errors');*/null;
      end if;
    end if;
  else      d_ord_income_1962 := ord_income;
    d_cap_gain_1962 := cap_gain;
    true_or_false  := 0;
    if print_debug = 'Y' then
       /*srw.message(9997,'else dpis before 1962');*/null;
    end if;
  end if;
else      d_ord_income_1962 := ord_income;
    d_cap_gain_1962 := cap_gain;
    true_or_false  := 0;
    if print_debug = 'Y' then
       /*srw.message(9997,'Book class = TAX  ');*/null;
    end if;
end if;
RETURN(true_or_false);
end;
function d_ord_income_1962Formula return Number is
begin
  null;
end;
--Functions to refer Oracle report placeholders--
 Function Accounting_Flex_Structure_p return number is
	Begin
	 return Accounting_Flex_Structure;
	 END;
 Function ACCT_BAL_APROMPT_p return varchar2 is
	Begin
	 return ACCT_BAL_APROMPT;
	 END;
 Function ACCT_CC_APROMPT_p return varchar2 is
	Begin
	 return ACCT_CC_APROMPT;
	 END;
 Function CAT_MAJ_APROMPT_p return varchar2 is
	Begin
	 return CAT_MAJ_APROMPT;
	 END;
 Function Currency_Code_p return varchar2 is
	Begin
	 return Currency_Code;
	 END;
 Function PRINT_DEBUG_p return varchar2 is
	Begin
	 return PRINT_DEBUG;
	 END;
 Function PRECISION_p return number is
	Begin
	 return PRECISION;
	 END;
 Function Book_Class_p return varchar2 is
	Begin
	 return Book_Class;
	 END;
 Function Distribution_Source_Book_p return varchar2 is
	Begin
	 return Distribution_Source_Book;
	 END;
 Function Period1_PC_p return varchar2 is
	Begin
	 return Period1_PC;
	 END;
 Function Period1_PCD_p return date is
	Begin
	 return Period1_PCD;
	 END;
 Function Period1_POD_p return date is
	Begin
	 return Period1_POD;
	 END;
 Function Period1_FY_p return number is
	Begin
	 return Period1_FY;
	 END;
 Function Period2_FY_p return number is
	Begin
	 return Period2_FY;
	 END;
 Function Period2_PCD_p return date is
	Begin
	 return Period2_PCD;
	 END;
 Function Period2_POD_p return date is
	Begin
	 return Period2_POD;
	 END;
 Function Period2_PC_p return varchar2 is
	Begin
	 return Period2_PC;
	 END;
 Function d_ord_income_1962_p return number is
	Begin
	 return d_ord_income_1962;
	 END;
 Function d_cap_gain_1962_p return number is
	Begin
	 return d_cap_gain_1962;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_BAL_LPROMPT_p return varchar2 is
	Begin
	 return RP_BAL_LPROMPT;
	 END;
END FA_FAS443_XMLP_PKG ;


/
