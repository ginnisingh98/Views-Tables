--------------------------------------------------------
--  DDL for Package Body FA_FAS445_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS445_XMLP_PKG" AS
/* $Header: FAS445B.pls 120.0.12010000.1 2008/07/28 13:14:43 appldev ship $ */
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
    RP_Report_Name := 'Form 4797 - Gain from Disposition of 1250 Property Report';
    RETURN('Form 4797 - Gain from Disposition of 1250 Property Report');
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
function Period1_PCFormula return Number is
begin
DECLARE
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
BEGIN
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
  Period1_POD := l_period_POD;
  Period1_PCD := l_period_PCD;
  Period1_FY  := l_period_FY;
  return(l_period_PC);
END;
RETURN NULL; end;
function Period2_PCFormula return Number is
begin
DECLARE
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
BEGIN
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD2;
  Period2_POD := l_period_POD;
  Period2_PCD := l_period_PCD;
  Period2_FY  := l_period_FY;
  return(l_period_PC);
END;
RETURN NULL; end;
function PRECFormula return VARCHAR2 is
begin
DECLARE
  l_precision NUMBER(15);
BEGIN
  SELECT
         cur.precision
  INTO
         l_precision
  FROM   FA_BOOK_CONTROLS bc,
         GL_SETS_OF_BOOKS sob,
         FND_CURRENCIES cur
  WHERE  bc.book_type_code = P_BOOK
  AND    sob.set_of_books_id = bc.set_of_books_id
  AND    sob.currency_code   = cur.currency_code;
  Precision := l_precision;
  fnd_profile.get('PRINT_DEBUG',print_debug);
  return(l_precision);
END;
RETURN NULL; end;
function GAIN_NLSFormula return VARCHAR2 is
begin
  DECLARE
     l_meaning  VARCHAR2(80);
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
     l_meaning  VARCHAR2(80);
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
function d_excess_1962formula(book in varchar2, asset_id in number, book_class in varchar2, cost in number, nbvr in number, gla in number, cgain in number, ord_inc in number) return number is
  true_or_false number;
  ret boolean;
  h_calendar_type varchar2(30);
  h_fy_name     varchar2(30);
  h_prorate_fy  number;
  h_cur_per_num number;
  h_num_per_fy  number;
  h_cur_fy      number;
  h_prorate_start_year 	number;
  dpr_in  fa_std_types.dpr_struct;
  dpr_out fa_std_types.dpr_out_struct;
  dpr_arr fa_std_types.dpr_arr_type;
  X_BOOK 		varchar2(15);
  X_ASSET_ID		number;
  h_new_deprn_rsv    	number;
  l_dpis		date;
  l_deprn_rsv_1962 	number := 0;
  l_diff_reserve 	number;
	h_dpr_date date;  	h_current_cost number; 	h_itc_amount_id number;	h_itc_basis 	number;	h_ceiling_Type  varchar2(50);
l_new_gain_loss 		number;
l_new_ordinary_income		number;
l_new_capital_gain		number;
l_reserve_retired	number;
l_stl_method_code		fa_retirements.stl_method_code%TYPE;
l_stl_life_in_months		fa_retirements.stl_life_in_months%TYPE;
l_stl_deprn_amount	number;
l_diff_stl 		number;
l_stl_deprn_reserve_1962	number := 0;
l_excess_deprn		number;
l_recap_gain 		number;
l_sec_1231_gain 	number;
l_life			number;
l_fraction_life		number;
l_date_retired		date;
l_date_retired_year	number;
l_ttcode		varchar2(20);
call_faxcde		boolean;
zero_excess_deprn	boolean := false;
before_1962		boolean := true;
l_main_dpis		date;
l_method_code		varchar2(12);
rakn			number := 0;
previous_y_end 		number;
previous_p_cl_end	number;
previous_end_date	date;
l_rate_source_rule	varchar2(10);
cursor c_rsr is
  select rate_source_rule
  from fa_methods
  where method_code = l_method_code;
l_start_date 	date;
l_fiscal_year_name	varchar2(30);
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
		ret.stl_method_code,
		ret.stl_life_in_months,
		ret.stl_deprn_amount,
		ret.date_retired,
		to_number(to_char(ret.date_retired,'YYYY')),
		th.transaction_type_code
 FROM	fa_ceiling_types ceilt,
		fa_methods mt,
		fa_category_books cb,
		fa_books bk,
		fa_transaction_headers th,
		fa_retirements ret,
		fa_additions ad
  WHERE	cb.book_type_code = X_book
	AND	ad.asset_category_id = cb.category_id
	AND	ceilt.ceiling_name(+) = bk.ceiling_name
	AND	mt.method_code = bk.deprn_method_code
	AND	bk.book_type_code = X_book
	AND	bk.asset_id = X_asset_id
	AND	bk.transaction_header_id_out = th.transaction_header_id
	AND  	th.transaction_type_code IN ('FULL RETIREMENT','PARTIAL RETIREMENT')
	AND	th.transaction_header_id = ret.transaction_header_id_in
	AND 	ret.status = 'PROCESSED'
	AND	nvl (mt.life_in_months, -9999) =
			nvl (bk.life_in_months, -9999)
	AND	ad.asset_id = bk.asset_id;
test_stl_deprn_amount		number;
BEGIN
if print_debug = 'Y' then
      /*srw.message(9999,'Starting D_EXCESS_1962');*/null;
      /*srw.message(9999,book);*/null;
      /*srw.message(9999, asset_id);*/null;
end if;
X_BOOK := book;
x_asset_id := asset_id;
if book_class = 'TAX'  then
  dpr_in.book		:= x_book;
  dpr_in.asset_id	:= x_asset_id;
 select deprn_reserve, ytd_deprn, bk.date_placed_in_service,
		bk.deprn_method_code
  into dpr_in.deprn_rsv, dpr_in.ytd_deprn, l_main_dpis,
		l_method_code
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
	and l_rate_source_rule <> 'CALCULATED' then
    true_or_false := 1;
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
		l_stl_method_code,
		l_stl_life_in_months,
		l_stl_deprn_amount,
		l_date_retired,
		l_date_retired_year,
		l_ttcode;
  WHILE C_RET%FOUND AND BEFORE_1962 LOOP
   if print_debug = 'Y' then
	/*srw.message(9999,dpr_in.adj_cost);*/null;
	/*srw.message(9999,dpr_in.rec_cost);*/null;
	/*srw.message(9999,h_current_cost);*/null;
	/*srw.message(9999,l_dpis);*/null;
	/*srw.message(9999, dpr_in.method_code);*/null;
   end if;
   rakn := rakn + 1;
   if rakn = 1 then
      dpr_in.y_begin :=  h_prorate_start_year;
      select period_num
      into dpr_in.p_cl_begin
      from fa_calendar_periods cp,
	   fa_book_controls bc
      where calendar_type = bc.deprn_calendar
      and bc.book_type_code = x_book
      and dpr_in.prorate_date
	between cp.start_date and cp.end_date;
      if l_date_retired > to_date('19611231','YYYYMMDD') then
	dpr_in.y_end := 1961;
   	select period_num
      	into dpr_in.p_cl_end
      	from fa_calendar_periods cp,
	   fa_book_controls bc
      	where calendar_type = bc.deprn_calendar
      	and bc.book_type_code = x_book
      	and to_date('19611231','YYYYMMDD')
	between cp.start_date and cp.end_date;
	previous_end_date := to_date('19611231','YYYYMMDD');
      else
	dpr_in.y_end := l_date_retired_year;
   	select period_num
      	into dpr_in.p_cl_end
      	from fa_calendar_periods cp,
	   fa_book_controls bc
      	where calendar_type = bc.deprn_calendar
      	and bc.book_type_code = x_book
      	and l_date_retired
	between cp.start_date and cp.end_date;
	previous_end_date := l_date_retired;
      end if;
      if print_debug = 'Y' then
	/*srw.message(rakn,'y_begin: ' || to_char(dpr_in.y_begin));*/null;
	/*srw.message(rakn,'y_end: ' || to_char(dpr_in.y_end));*/null;
	/*srw.message(rakn,'p_cl_begin: ' || to_char(dpr_in.p_cl_begin));*/null;
	/*srw.message(rakn,'p_cl_end: ' || to_char(dpr_in.p_cl_end));*/null;
      end if;
   else
	open c_end;
	fetch c_end into dpr_in.p_cl_begin, l_start_date, l_fiscal_year_name;
	if c_end%FOUND then
	   fetch c_end into dpr_in.p_cl_begin, l_start_date, l_fiscal_year_name;
	end if;
	close c_end;
	select fiscal_year
	into dpr_in.y_begin
	from fa_fiscal_year
	where fiscal_year_name = l_fiscal_year_name
	and l_start_date between start_date and end_date;
      if l_date_retired >  to_date('19611231','YYYYMMDD') then
	dpr_in.y_end := 1961;
   	select period_num
      	into dpr_in.p_cl_end
      	from fa_calendar_periods cp,
	   fa_book_controls bc
      	where calendar_type = bc.deprn_calendar
      	and bc.book_type_code = x_book
      	and to_date('19611231','YYYYMMDD')
	between cp.start_date and cp.end_date;
	previous_end_date := to_date('19611231','YYYYMMDD');
      else
	dpr_in.y_end := l_date_retired_year;
   	select period_num
      	into dpr_in.p_cl_end
      	from fa_calendar_periods cp,
	   fa_book_controls bc
      	where calendar_type = bc.deprn_calendar
      	and bc.book_type_code = x_book
      	and l_date_retired
	between cp.start_date and cp.end_date;
	previous_end_date := l_date_retired;
      end if;
      if print_debug = 'Y' then
	/*srw.message(rakn,'y_begin: ' || to_char(dpr_in.y_begin));*/null;
	/*srw.message(rakn,'y_end: ' || to_char(dpr_in.y_end));*/null;
	/*srw.message(rakn,'p_cl_begin: ' || to_char(dpr_in.p_cl_begin));*/null;
	/*srw.message(rakn,'p_cl_end: ' || to_char(dpr_in.p_cl_end));*/null;
      end if;
   end if;
  dpr_in.bonus_deprn_exp         := 0;
  dpr_in.bonus_ytd_deprn	 := 0;
  dpr_in.bonus_deprn_rsv	 := 0;
  dpr_in.prior_fy_bonus_exp	 := 0;
   if not fa_cache_pkg.fazcbc(X_book => X_book) then
     true_or_false := 0;
     /*srw.message(9999,'fazcbc returned FALSE');*/null;
   end if;
   if print_debug = 'Y' then
	/*srw.message(9999,'Calling faxcde first time');*/null;
   end if;
    ret := fa_cde_pkg.faxcde (
	dpr_in => dpr_in,
	dpr_arr => dpr_arr,
	dpr_out => dpr_out,
	fmode => 1);
    if (ret = FALSE) then
      /*srw.message(9999,'faxcde-first returned FALSE');*/null;
    true_or_false := 0;
    end if;
    h_new_deprn_rsv := dpr_out.new_deprn_rsv;
    l_deprn_rsv_1962 := l_deprn_rsv_1962 + round(h_new_deprn_rsv,precision);
    if print_debug = 'Y' then
       /*srw.message(9999,dpr_out.new_deprn_rsv);*/null;
       /*srw.message(9999,dpr_out.new_adj_cost);*/null;
       /*srw.message(9991, 'deprn_rsv_1962: ' || to_char(l_deprn_rsv_1962));*/null;
    end if;
    if print_debug = 'Y' then
       /*srw.message(9991, 'stl_method_code: ' ||  l_stl_method_code );*/null;
       /*srw.message(9991, 'stl_deprn_amount ' ||  l_stl_deprn_amount);*/null;
    end if;
    if l_stl_method_code is not null and nvl(l_stl_deprn_amount,0) <> 0 then
      dpr_in.method_code := l_stl_method_code;
      dpr_in.life 	 := l_stl_life_in_months;
      l_fraction_life := months_between(to_date('19611231','YYYYMMDD'), l_dpis);
      if l_fraction_life < l_stl_life_in_months then
	call_faxcde := true;
      else
	call_faxcde := false;
      end if;
    else
      if print_debug = 'Y' then
        /*srw.message(9993,'null excess_deprn due to no fa_ret.stl_deprn_amount');*/null;
      end if;
      zero_excess_deprn := true;
      call_faxcde := false;
    end if;
    if call_faxcde then
      dpr_in.adj_cost := dpr_in.rec_cost;
      if print_debug = 'Y' then
         /*srw.message(9999,'adj_cost: ' || to_char(dpr_in.adj_cost));*/null;
         /*srw.message(9999,'rec_cost: ' || to_char(dpr_in.rec_cost));*/null;
         /*srw.message(9999,'Calling faxcde 2nd time');*/null;
      end if;
      ret := fa_cde_pkg.faxcde (
		dpr_in => dpr_in,
		dpr_arr => dpr_arr,
		dpr_out => dpr_out,
		fmode => 1);
      if (ret = FALSE) then
        /*srw.message(9999,'faxcde-second returned FALSE');*/null;
        true_or_false := 0;
      end if;
	      l_stl_deprn_reserve_1962 := l_stl_deprn_reserve_1962 + round(dpr_out.new_deprn_rsv, precision);
     else
       l_stl_deprn_reserve_1962 :=  l_stl_deprn_reserve_1962 + nvl(l_stl_deprn_amount,0);
       if print_debug = 'Y' then
         /*srw.message(9999,'faxcde 2nd not called');*/null;
       end if;
     end if;
     if print_debug = 'Y' then
         /*srw.message(9994, nvl(l_stl_deprn_reserve_1962,0));*/null;
     end if;
    if l_date_retired > to_date('19611231','YYYYMMDD') then
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
		l_stl_method_code,
		l_stl_life_in_months,
		l_stl_deprn_amount,
		l_date_retired,
		l_date_retired_year,
		l_ttcode;
    END LOOP;
    close c_ret;
    if true_or_false = 1 then         l_reserve_retired := nvl(cost,0) - nvl(nbvr,0);
        l_diff_reserve := l_reserve_retired - l_deprn_rsv_1962;
	l_diff_stl := nvl(l_stl_deprn_amount,0) - l_stl_deprn_reserve_1962;
	if print_debug = 'Y' then
           /*srw.message(9992,'cost: ' || to_char(cost));*/null;
           /*srw.message(9992,'nbvr: ' || to_char(nbvr));*/null;
           /*srw.message(9992, nvl(l_stl_deprn_reserve_1962,0));*/null;
          /*srw.message(9992, nvl(l_stl_deprn_amount,0));*/null;
           /*srw.message(9992,'reserve_retired: ' || to_char(l_reserve_retired));*/null;
           /*srw.message(9992,'diff_reserve: ' || to_char(l_diff_reserve));*/null;
           /*srw.message(9994,'diff_stl: ' || to_char(l_diff_stl));*/null;
        end if;
  	if zero_excess_deprn then
	  l_excess_deprn := 0;
	else
          l_excess_deprn := l_diff_reserve - l_diff_stl;
          if l_excess_deprn <= 0 then
		l_excess_deprn := 0;
       	  end if;
	end if;
	if print_debug = 'Y' then
           /*srw.message(9995,'excess_deprn: ' || to_char(l_excess_deprn));*/null;
        end if;
	l_recap_gain := round((l_reserve_retired - l_deprn_rsv_1962 - l_excess_deprn) * 0.2, precision);
        if print_debug = 'Y' then
           /*srw.message(9996,'excess_1969: ' || to_char(p_excess_1969_hide));*/null;
	end if;
	l_new_ordinary_income := least((nvl(gla,0) ), (p_excess_1969_hide + l_recap_gain));
	l_sec_1231_gain := gla - l_new_ordinary_income;
	if print_debug = 'Y' then
            /*srw.message(9997,'new_ordinary_income: ' || to_char(l_new_ordinary_income));*/null;
            /*srw.message(9996,'recap_gain: ' || to_char(l_recap_gain));*/null;
            /*srw.message(9998,'gain_limitation: ' || to_char(gla) );*/null;
            /*srw.message(9998,'sec_1231_gain: ' || to_char(l_sec_1231_gain));*/null;
        end if;
       	p_section_1231_gain_1962 := l_sec_1231_gain;
	p_ordinary_income_1962 := l_new_ordinary_income;
     else          p_section_1231_gain_1962 := cgain;
        p_ordinary_income_1962 := ord_inc;
     end if;
  else
    p_section_1231_gain_1962 := cgain;
    p_ordinary_income_1962 := ord_inc;
    true_or_false  := 0;
    if print_debug = 'Y' then
        /*srw.message(7777, 'Not in dpis range and not a stl-asset');*/null;
        /*srw.message(9997,l_rate_source_rule);*/null;
        /*srw.message(9997, l_main_dpis);*/null;
    end if;
  end if;
else
   p_section_1231_gain_1962 := cgain;
   p_ordinary_income_1962 := ord_inc;
   true_or_false  := 0;
   if print_debug = 'Y' then
     /*srw.message(8888, 'Not a Tax book');*/null;
   end if;
end if;
RETURN(true_or_false);
end;
--function d_excess_1969formula(book in varchar2, asset_id in number, book_class in varchar2, xcess in number) return number is
function d_excess_1969formula(book in varchar2, asset_id in number, book_class in varchar2, xcess in number, cost in number, nbvr in number) return number is
 true_or_false number;
  ret boolean;
  h_calendar_type varchar2(30);
  h_fy_name     varchar2(30);
  h_prorate_fy  number;
  h_cur_per_num number;
  h_num_per_fy  number;
  h_cur_fy      number;
  h_prorate_start_year 	number;
  dpr_in  fa_std_types.dpr_struct;
  dpr_out fa_std_types.dpr_out_struct;
  dpr_arr fa_std_types.dpr_arr_type;
  X_BOOK 		varchar2(15);
  X_ASSET_ID		number;
  h_new_deprn_rsv    	number;
  l_dpis		date;
  l_deprn_rsv_1969 	number := 0;
  l_diff_reserve 	number;
	h_dpr_date date;  	h_current_cost number; 	h_itc_amount_id number;	h_itc_basis 	number;	h_ceiling_Type  varchar2(50);
l_new_gain_loss 		number;
l_new_ordinary_income		number;
l_new_capital_gain		number;
l_reserve_retired	number;
l_stl_deprn_amount	number := 0;
l_stl_method_code	fa_retirements.stl_method_code%TYPE;
l_stl_life_in_months	fa_retirements.stl_life_in_months%TYPE;
l_diff_stl 		number;
l_stl_deprn_reserve_1969	number := 0;
l_excess_deprn		number;
l_recap_gain 		number;
l_sec_1231_gain 	number;
l_life			number;
l_fraction_life		number;
l_date_retired		date;
l_date_retired_year	number;
l_ttcode		varchar2(20);
l_main_dpis		date;
l_method_code		varchar2(12);
call_faxcde		boolean;
zero_excess_deprn	boolean := false;
BEFORE_1969		boolean := true;
rakn			number := 0;
previous_y_end 		number;
previous_p_cl_end	number;
previous_end_date 	date;
l_rate_source_rule	varchar2(10);
cursor c_rsr is
  select rate_source_rule
  from fa_methods
  where method_code = l_method_code;
l_start_date 		date;
l_fiscal_year_name	varchar2(30);
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
		ret.stl_method_code,
		ret.stl_life_in_months,
		ret.stl_deprn_amount,
		ret.date_retired,
		to_number(to_char(ret.date_retired,'YYYY')),
		th.transaction_type_code
  FROM	fa_ceiling_types ceilt,
		fa_methods mt,
		fa_category_books cb,
		fa_books bk,
		fa_transaction_headers th,
		fa_retirements ret,
		fa_additions ad
  WHERE	cb.book_type_code = X_book
	AND	ad.asset_category_id = cb.category_id
	AND	ceilt.ceiling_name(+) = bk.ceiling_name
	AND	mt.method_code = bk.deprn_method_code
	AND	bk.book_type_code = X_book
	AND	bk.asset_id = X_asset_id
	AND	bk.transaction_header_id_out = th.transaction_header_id
	AND  	th.transaction_type_code IN ('FULL RETIREMENT','PARTIAL RETIREMENT')
	AND	th.transaction_header_id = ret.transaction_header_id_in
	AND 	ret.status = 'PROCESSED'
	AND	nvl (mt.life_in_months, -9999) =
			nvl (bk.life_in_months, -9999)
	AND	ad.asset_id = bk.asset_id;
test_stl_deprn_amount 	fa_retirements.stl_deprn_amount%TYPE;
test_stl_method_code 	fa_retirements.stl_method_code%TYPE;
BEGIN
if print_debug = 'Y' then
  /*srw.message(9999,'Starting D_EXCESS_1969');*/null;
  /*srw.message(9999,book);*/null;
  /*srw.message(9999, asset_id);*/null;
end if;
  X_BOOK := book;
  x_asset_id := asset_id;
  dpr_in.book		:= x_book;
  dpr_in.asset_id	:= x_asset_id;
  select deprn_reserve, ytd_deprn, bk.date_placed_in_service,
		bk.deprn_method_code, ret.stl_deprn_amount, ret.stl_method_code
  into dpr_in.deprn_rsv, dpr_in.ytd_deprn, l_main_dpis,
		l_method_code, test_stl_deprn_amount, test_stl_method_code
  from fa_deprn_summary ds,
	fa_books bk,
	fa_retirements ret,
	fa_transaction_headers th
  where ds.book_type_code = X_book
  and   ds.asset_id = X_asset_id
  and   ds.deprn_source_code = 'BOOKS'
  and 	th.transaction_header_id = bk.transaction_header_id_in
  and   th.transaction_header_id = ret.transaction_header_id_in
  and   th.transaction_header_id in (select max(transaction_header_id)
				from fa_transaction_headers thsub
				where transaction_type_code like '%RETIREMENT'
				and   book_type_code = x_book
				and   asset_id = x_asset_id)
;
  if nvl(test_stl_deprn_amount,0)  <> 0 then
  if book_class = 'TAX'  then
  open c_rsr;
  fetch c_rsr into l_rate_source_rule;
  close c_rsr;
 if l_main_dpis < to_date('19691231','YYYYMMDD')
	and l_rate_source_rule <> 'CALCULATED' then
     true_or_false := 1;
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
		l_stl_method_code,
		l_stl_life_in_months,
		l_stl_deprn_amount,
		l_date_retired,
		l_date_retired_year,
		l_ttcode;
  WHILE C_RET%FOUND AND BEFORE_1969 LOOP
   if print_debug = 'Y' then
    /*srw.message(9999,dpr_in.adj_cost);*/null;
    /*srw.message(9999,dpr_in.rec_cost);*/null;
    /*srw.message(9999,h_current_cost);*/null;
    /*srw.message(9999,l_dpis);*/null;
    /*srw.message(9999, dpr_in.method_code);*/null;
   end if;
   rakn := rakn + 1;
   if rakn = 1 then
      dpr_in.y_begin :=  h_prorate_start_year;
      select period_num
      into dpr_in.p_cl_begin
      from fa_calendar_periods cp,
	   fa_book_controls bc
      where calendar_type = bc.deprn_calendar
      and bc.book_type_code = x_book
      and dpr_in.prorate_date
	between cp.start_date and cp.end_date;
      if l_date_retired > to_date('19691231','YYYYMMDD') then
	dpr_in.y_end := 1969;
   	select period_num
      	into dpr_in.p_cl_end
      	from fa_calendar_periods cp,
	   fa_book_controls bc
      	where calendar_type = bc.deprn_calendar
      	and bc.book_type_code = x_book
      	and to_date('19691231','YYYYMMDD')
	between cp.start_date and cp.end_date;
        previous_end_date :=   to_date('19691231','YYYYMMDD');
      else
	dpr_in.y_end := l_date_retired_year;
   	select period_num
      	into dpr_in.p_cl_end
      	from fa_calendar_periods cp,
	   fa_book_controls bc
      	where calendar_type = bc.deprn_calendar
      	and bc.book_type_code = x_book
      	and l_date_retired
	between cp.start_date and cp.end_date;
	previous_end_date :=  l_date_retired;
      end if;
   else
	open c_end;
	fetch c_end into dpr_in.p_cl_begin, l_start_date, l_fiscal_year_name;
	if c_end%FOUND then
	  fetch c_end into dpr_in.p_cl_begin, l_start_date, l_fiscal_year_name;
	end if;
	close c_end;
	select fiscal_year
	into dpr_in.y_begin
	from fa_fiscal_year
	where fiscal_year_name = l_fiscal_year_name
	and l_start_date between start_date and end_date;
      if l_date_retired >  to_date('19691231','YYYYMMDD') then
	dpr_in.y_end := 1969;
   	select period_num
      	into dpr_in.p_cl_end
      	from fa_calendar_periods cp,
	   fa_book_controls bc
      	where calendar_type = bc.deprn_calendar
      	and bc.book_type_code = x_book
      	and to_date('19691231','YYYYMMDD')
	between cp.start_date and cp.end_date;
        previous_end_date :=  to_date('19691231','YYYYMMDD');
      else
	dpr_in.y_end := l_date_retired_year;
   	select period_num
      	into dpr_in.p_cl_end
      	from fa_calendar_periods cp,
	   fa_book_controls bc
      	where calendar_type = bc.deprn_calendar
      	and bc.book_type_code = x_book
      	and l_date_retired
	between cp.start_date and cp.end_date;
        previous_end_date := l_date_retired;
      end if; 	if print_debug = 'Y' then
 	 /*srw.message(rakn,'y_begin: ' || to_char(dpr_in.y_begin));*/null;
 	 /*srw.message(rakn,'y_end: ' || to_char(dpr_in.y_end));*/null;
 	 /*srw.message(9999,'p_cl_begin: ' || to_char(dpr_in.p_cl_begin));*/null;
 	 /*srw.message(9999,'p_cl_end: ' || to_char(dpr_in.p_cl_end));*/null;
	end if;
   end if;
  dpr_in.bonus_deprn_exp         := 0;
  dpr_in.bonus_ytd_deprn	 := 0;
  dpr_in.bonus_deprn_rsv	 := 0;
  dpr_in.prior_fy_bonus_exp	 := 0;
   if not fa_cache_pkg.fazcbc(X_book => X_book) then
     true_or_false := 0;
     /*srw.message(9999,'fazcbc returned FALSE');*/null;
   end if;
   if print_debug = 'Y' then
    /*srw.message(9999,'adj_cost: ' || to_char(dpr_in.adj_cost));*/null;
    /*srw.message(9999,'rec_cost: ' || to_char(dpr_in.rec_cost));*/null;
    /*srw.message(9999,'Calling faxcde first time');*/null;
   end if;
    ret := fa_cde_pkg.faxcde (
	dpr_in => dpr_in,
	dpr_arr => dpr_arr,
	dpr_out => dpr_out,
	fmode => 1);
    if (ret = FALSE) then
      /*srw.message(9999,'faxcde-first returned FALSE');*/null;
      true_or_false := 0;
    end if;
    h_new_deprn_rsv := dpr_out.new_deprn_rsv;
    if print_debug = 'Y' then
       /*srw.message(9999,dpr_out.new_deprn_rsv);*/null;
    end if;
    l_deprn_rsv_1969 := l_deprn_rsv_1969 + round(h_new_deprn_rsv,precision);
    if print_debug = 'Y' then
       /*srw.message(9991, 'deprn_rsv_1969: ' ||  to_char(l_deprn_rsv_1969));*/null;
                         /*srw.message(9991, 'stl_method_code: ' ||  l_stl_method_code );*/null;
       /*srw.message(9991, 'stl_deprn_amount ' ||  l_stl_deprn_amount);*/null;
     end if;
    if l_stl_method_code is not null and nvl(l_stl_deprn_amount,0) <> 0 then
      dpr_in.method_code := l_stl_method_code;
      dpr_in.life 	 := l_stl_life_in_months;
      l_fraction_life := months_between(to_date('19691231','YYYYMMDD'), l_dpis);
      if l_fraction_life < l_stl_life_in_months then
        call_faxcde := true;
      else
        call_faxcde := false;
      end if;
    else
      if print_debug = 'Y' then
        /*srw.message(9993,'null excess_deprn due to no fa_ret.stl_deprn_amount');*/null;
      end if;
      zero_excess_deprn := true;
      true_or_false := 0;
      call_faxcde := false;
    end if;
    if call_faxcde then
	dpr_in.adj_rate := '';
        dpr_in.adj_cost := dpr_in.rec_cost;
	if print_debug = 'Y' then
	  /*srw.message(9999,'adj_cost: ' || to_char(dpr_in.adj_cost));*/null;
	  /*srw.message(9999,'rec_cost: ' || to_char(dpr_in.rec_cost));*/null;
	  /*srw.message(rakn,'y_begin: ' || to_char(dpr_in.y_begin));*/null;
	  /*srw.message(rakn,'y_end: ' || to_char(dpr_in.y_end));*/null;
	  /*srw.message(9999,'p_cl_begin: ' || to_char(dpr_in.p_cl_begin));*/null;
	  /*srw.message(9999,'p_cl_end: ' || to_char(dpr_in.p_cl_end));*/null;
          /*srw.message(9999,'Calling faxcde 2nd time');*/null;
	end if;
        ret := fa_cde_pkg.faxcde (
		dpr_in => dpr_in,
		dpr_arr => dpr_arr,
		dpr_out => dpr_out,
		fmode => 1);
       if (ret = FALSE) then
         /*srw.message(9999,'faxcde-second returned FALSE');*/null;
        true_or_false := 0;
       end if;
	       l_stl_deprn_reserve_1969  :=  l_stl_deprn_reserve_1969 + round(dpr_out.new_deprn_rsv,precision);
     else
       l_stl_deprn_reserve_1969  :=  l_stl_deprn_reserve_1969 + nvl(l_stl_deprn_amount,0);
	if print_debug = 'Y' then
         /*srw.message(9999,'faxcde 2nd not called');*/null;
	end if;
     end if;
     if print_debug = 'Y' then
         /*srw.message(9999, 'stl_deprn_reserve: ' || to_char(l_stl_deprn_reserve_1969));*/null;
     end if;
     if l_date_retired > to_date('19691231','YYYYMMDD') then
    	before_1969 := false;
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
		l_stl_method_code,
		l_stl_life_in_months,
		l_stl_deprn_amount,
		l_date_retired,
		l_date_retired_year,
		l_ttcode;
   END LOOP;
   close c_ret;
   if true_or_false  = 1 then
     l_reserve_retired := nvl(cost,0)  - nvl(nbvr,0);
     l_diff_reserve := l_reserve_retired - l_deprn_rsv_1969;
     if print_debug = 'Y' then
       /*srw.message(9992,'cost: ' || to_char(cost)) ;*/null;
       /*srw.message(9992,'nbvr: ' || to_char(nbvr));*/null;
       /*srw.message(9992,'reserve_retired: ' || to_char(l_reserve_retired));*/null;
       /*srw.message(9992,'diff_reserve (B): ' || to_char(l_diff_reserve));*/null;
     end if;
     l_diff_stl := nvl(l_stl_deprn_amount,0) - l_stl_deprn_reserve_1969;
     l_excess_deprn := l_diff_reserve - l_diff_stl;
     if xcess <= 0 then
        p_excess_1969 := 0;
        p_excess_1969_hide := 0;
     else
        p_excess_1969 := l_excess_deprn;
        p_excess_1969_hide := l_excess_deprn;
     end if;
     if print_debug = 'Y' then
       /*srw.message(9995,'stl_deprn_amount: ' || to_char(l_stl_deprn_amount));*/null;
       /*srw.message(9995,'diff_stl: ' || to_char(l_diff_stl));*/null;
       /*srw.message(9996,'excess_deprn: ' || to_char(l_excess_deprn));*/null;
     end if;
   else
     if zero_excess_deprn then
        p_excess_1969_hide := 0;
	p_excess_1969 := '';
     else
     if xcess <= 0 then
        p_excess_1969_hide := 0;
        p_excess_1969 := 0;
     else
        p_excess_1969_hide := xcess;
        p_excess_1969 := xcess;
     end if;
     end if;
   end if;
  else
     if print_debug = 'Y' then
       /*srw.message(9997,'Not in dpis range or a STL asset');*/null;
       /*srw.message(9997,l_rate_source_rule);*/null;
       /*srw.message(9997, l_main_dpis);*/null;
     end if;
     if xcess <= 0 then
        p_excess_1969_hide := 0;
        p_excess_1969 := 0;
     else
        p_excess_1969_hide := xcess;
        p_excess_1969 := xcess;
     end if;
     true_or_false  := 0;
  end if;
  else     p_excess_1969_hide := xcess;
    p_excess_1969 := xcess;
    if print_debug = 'Y' then
       /*srw.message(9998,'Not a taxbook');*/null;
    end if;
    true_or_false  := 0;
  end if;
  elsif test_stl_method_code is not null and test_stl_deprn_amount = 0 then
     p_excess_1969_hide := 0;
     p_excess_1969 := 0;
     if print_debug = 'Y' then
       /*srw.message(9998,'stl_deprn_amount=0 and stl_method_code entered');*/null;
     end if;
  else
     p_excess_1969_hide := 0;
     p_excess_1969 := '';
     if print_debug = 'Y' then
       /*srw.message(9998,'No stl_method_code');*/null;
     end if;
  end if;
  if print_debug = 'Y' then
     /*srw.message(9999,'Ending D_EXCESS_1969');*/null;
  end if;
RETURN(true_or_false);
end;
--Functions to refer Oracle report placeholders--
 Function PRECISION_p return number is
	Begin
	 return PRECISION;
	 END;
 Function PRINT_DEBUG_p return varchar2 is
	Begin
	 return PRINT_DEBUG;
	 END;
 Function ACCT_BAL_APROMPT_p return varchar2 is
	Begin
	 return ACCT_BAL_APROMPT;
	 END;
 Function ACCT_CC_APROMPT_p return varchar2 is
	Begin
	 return ACCT_CC_APROMPT;
	 END;
 Function CAT_MAJ_RPROMPT_p return varchar2 is
	Begin
	 return CAT_MAJ_RPROMPT;
	 END;
 Function Period1_POD_p return date is
	Begin
	 return Period1_POD;
	 END;
 Function Period1_PCD_p return date is
	Begin
	 return Period1_PCD;
	 END;
 Function Period1_FY_p return number is
	Begin
	 return Period1_FY;
	 END;
 Function Period2_POD_p return date is
	Begin
	 return Period2_POD;
	 END;
 Function Period2_PCD_p return date is
	Begin
	 return Period2_PCD;
	 END;
 Function Period2_FY_p return number is
	Begin
	 return Period2_FY;
	 END;
 Function P_SECTION_1231_GAIN_1962_p return number is
	Begin
	 return P_SECTION_1231_GAIN_1962;
	 END;
 Function P_ORDINARY_INCOME_1962_p return number is
	Begin
	 return P_ORDINARY_INCOME_1962;
	 END;
 Function P_EXCESS_1969_HIDE_p return number is
	Begin
	 return P_EXCESS_1969_HIDE;
	 END;
 Function P_EXCESS_1969_p return number is
	Begin
	 return P_EXCESS_1969;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function RP_ACCT_BAL_LPROMPT_p return varchar2 is
	Begin
	 return RP_ACCT_BAL_LPROMPT;
	 END;
END FA_FAS445_XMLP_PKG ;


/
