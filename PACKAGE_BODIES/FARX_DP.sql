--------------------------------------------------------
--  DDL for Package Body FARX_DP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_DP" AS
  /* $Header: farxdpb.pls 120.18.12010000.4 2009/10/30 11:30:00 pmadas ship $ */

  --
  -- Structure to hold values of all parameters
  --
  type param_t is record (
    from_bal         varchar2(25),
    to_bal           varchar2(25),
    from_acct        varchar2(25),
    to_acct          varchar2(25),
    from_cc          varchar2(25),
    to_cc            varchar2(25),
    from_maj_cat     varchar2(30),
    to_maj_cat       varchar2(30),
    from_min_cat     varchar2(30),
    to_min_cat       varchar2(30),
    cat_seg_num      varchar2(30),
    from_cat_seg_val varchar2(30),
    to_cat_seg_val   varchar2(30),
    prop_type        varchar2(25),
    from_asset_num   varchar2(25),
    to_asset_num     varchar2(25),
    report_style     varchar2(1),
    sob_id           number,      -- MRC
    mrcsobtype       varchar2(1)  -- MRC
                         );
  param param_t;

  mesg_name varchar2(30);
  mesg_str varchar2(2000);
  flex_error varchar2(30);
  ccid_error number;
  error_errbuf varchar2(250);
  error_retcode number;


/*
||
|| Reserve Ledger Report
||
*/

/*
 * Main Reserve Ledger RX Report Procedure
 */
--
-- Backward compatibility version
--
g_print_debug boolean := fa_cache_pkg.fa_print_debug;

PROCEDURE deprn_run (
   book             in   varchar2,
   sob_id           in   varchar2 default NULL,   -- MRC: Set of books id
   period           in   varchar2,
   from_bal         in   varchar2,
   to_bal           in   varchar2,
   from_acct        in   varchar2,
   to_acct          in   varchar2,
   from_cc          in   varchar2,
   to_cc            in   varchar2,
   major_category   in   varchar2,
   minor_category   in   varchar2,
   cat_seg_num      in   varchar2,
   cat_seg_val      in   varchar2,
   prop_type        in   varchar2,
   request_id       in   number,
   login_id         in   number,
   retcode          out nocopy  number,
   errbuf           out nocopy  varchar2
) is

l_to_major_category  varchar2(30);
l_to_minor_category  varchar2(30);
l_to_cat_seg_val     varchar2(30);

begin

  -- Fix for Bug #2709865.  Do not re-use the same variable names
  l_to_major_category := major_category;
  l_to_minor_category := minor_category;
  l_to_cat_seg_val := cat_seg_val;

  deprn_run(
        book,
        sob_id,  -- MRC: Set of books id
        period,
        from_bal,
        to_bal,
        from_acct,
        to_acct,
        from_cc,
        to_cc,
        major_category,
        l_to_major_category,
        minor_category,
        l_to_minor_category,
        cat_seg_num,
        cat_seg_val,
        l_to_cat_seg_val,
        prop_type,
        null, null, -- from/to asset number
        'S', -- For Standard Report
        request_id,
        login_id,
        retcode,
        errbuf);
end deprn_run; /* Backward compatible version */

--
-- Main version
--
procedure deprn_run (
   book             in   varchar2,
   sob_id           in   varchar2 default NULL,   -- MRC: Set of books id
   period           in   varchar2,
   from_bal         in   varchar2,
   to_bal           in   varchar2,
   from_acct        in   varchar2,
   to_acct          in   varchar2,
   from_cc          in   varchar2,
   to_cc            in   varchar2,
   from_maj_cat     in   varchar2,
   to_maj_cat       in   varchar2,
   from_min_cat     in   varchar2,
   to_min_cat       in   varchar2,
   cat_seg_num      in   varchar2,
   from_cat_seg_val in   varchar2,
   to_cat_seg_val   in   varchar2,
   prop_type        in   varchar2,
   from_asset_num   in   varchar2,
   to_asset_num     in   varchar2,
   report_style     in   varchar2,
   request_id       in   number,
   login_id         in   number,
   retcode          out nocopy  number,
   errbuf           out nocopy  varchar2
)
is
BEGIN
     IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('farx_dp.deprn_run()+');
        fa_rx_util_pkg.debug('deprn_run: ' || '********login_id:' || login_id);
        fa_rx_util_pkg.debug('deprn_run: ' || '********request_id:' || request_id);
     END IF;
   --
   -- Assign parameters to global variable
   -- These values will be used within the before_report trigger
   --
   param.from_bal := from_bal;
   param.to_bal   := to_bal;
   param.from_acct:= from_acct;
   param.to_acct  := to_acct;
   param.from_cc  := from_cc;
   param.to_cc    := to_cc;
   param.from_maj_cat := from_maj_cat;
   param.to_maj_cat   := to_maj_cat;
   param.from_min_cat := from_min_cat;
   param.to_min_cat   := to_min_cat;
   param.cat_seg_num      := cat_seg_num;
   param.from_cat_seg_val := from_cat_seg_val;
   param.to_cat_seg_val   := to_cat_seg_val;
   param.prop_type      := prop_type;
   param.from_asset_num := from_asset_num;
   param.to_asset_num   := to_asset_num;
   param.report_style   := nvl(report_style,'S');

  var.book := book;
  var.period := period;
  var.report_style := nvl(report_style,'S');

  -- MRC
  param.sob_id := to_number(sob_id);

  if param.sob_id is not null then
    begin
       select 'P'
       into param.mrcsobtype
       from fa_book_controls
       where book_type_code = book
       and set_of_books_id = param.sob_id;
    exception
       when no_data_found then
          param.mrcsobtype := 'R';
    end;
  else
    param.mrcsobtype := 'P';
  end if;
  -- End MRC

  fnd_profile.get('USER_ID',farx_dp.var.user_id);

  farx_dp.var.login_id := login_id;

  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('deprn_run: ' || 'Book = '||var.book);
        fa_rx_util_pkg.debug('deprn_run: ' || 'Period = '||var.period);
        fa_rx_util_pkg.debug('deprn_run: ' || 'Report_Style = '||var.report_style);
        -- MRC
        fa_rx_util_pkg.debug('deprn_run: ' || 'SOB ID = '||param.sob_id);
        fa_rx_util_pkg.debug('deprn_run: ' || 'MRC SOB Type = '||param.mrcsobtype);
        -- End MRC
  END IF;

  --
  -- Initialize request
  --
  fa_rx_util_pkg.init_request('farx_dp.deprn_rep', request_id, 'FA_DEPRN_REP_ITF');

  --
  -- Assign report triggers for this report.
  --
  fa_rx_util_pkg.assign_report('RESERVE LEDGER',
                true,
                'farx_dp.before_report;',
                'farx_dp.bind(:CURSOR_SELECT);',
                'farx_dp.after_fetch;',
                null);

  --
  -- Run the report
  --
  fa_rx_util_pkg.run_report('farx_dp.deprn_rep', retcode, errbuf);

  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('farx_dp.deprn_run()-');
  END IF;
exception
when others then
  fa_rx_util_pkg.log(sqlcode);
  fa_rx_util_pkg.log(sqlerrm);

  fnd_message.set_name('OFA', mesg_name);
  if mesg_name in ('FA_SHARED_DELETE_FAILED', 'FA_SHARED_INSERT_FAILED') then
        fnd_message.set_token('TABLE', 'FA_DEPRN_REP_ITF', FALSE);
  elsif mesg_name = 'FA_RX_CONCAT_SEGS' then
        fnd_message.set_token('CCID', to_char(ccid_error), FALSE);
        fnd_message.set_token('FLEX_CODE', flex_error, FALSE);
  end if;

  mesg_str := fnd_message.get;
  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('deprn_run: ' || mesg_name);
  END IF;
  fa_rx_util_pkg.log(mesg_str);

  if error_errbuf is not null then
        retcode := error_retcode;
        errbuf := error_errbuf;
  else
          retcode := 2;
          errbuf := mesg_str;
  end if;

  IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('farx_dp.deprn_run(EXCEPTION)-');
  END IF;
end deprn_run;


/*
 * This is the before report trigger
 * for the main Reserve Ledger Report.
 */
procedure before_report
is
   return_status boolean;
   period_closed varchar2(3);
   l_param_where varchar2(2000);
   maj_select_statement   varchar2(50);
   min_select_statement   varchar2(50);
   spec_select_statement  varchar2(50);

   -- Bug3499862
   calendar_period_open_date  date;
   calendar_period_close_date date;

begin
   fa_rx_util_pkg.debug('farx_dp.before_report()+');

   mesg_name := 'FA_SHARED_NO_FLEX_CHART_ACCTID';

   select category_flex_structure, location_flex_structure,
        asset_key_flex_structure
   into var.cat_flex_struct, var.loc_flex_struct, var.assetkey_flex_struct
   from fa_system_controls;

   mesg_name := 'FA_RX_SEGNUMS';


   fa_rx_shared_pkg.GET_ACCT_SEGMENT_NUMBERS (
     BOOK               => var.book,
     BALANCING_SEGNUM   => var.bal_segnum,
     ACCOUNT_SEGNUM     => var.acct_segnum,
     CC_SEGNUM          => var.cc_segnum,
     CALLING_FN         => 'DEPRN_REP');

   mesg_name := 'FA_AMT_GET_ASSET_NUM';

    select
        bc.book_class,
        bc.accounting_flex_structure,
        bc.distribution_source_book,
        substrb(sob.currency_code, 1, 15),
        cur.precision,
        bc.fiscal_year_name,
        sob.chart_of_accounts_id,
        substrb(sob.name, 1, 80),
        decode(param.mrcsobtype, 'P', sob.set_of_books_id, param.sob_id)    -- MRC
    into var.book_class,
        var.acct_flex_struct,
        var.dist_source_book,
        var.currency_code,
        var.precision,
        var.fy_name,
        var.chart_of_accounts_id,
        var.organization_name,
        var.set_of_books_id
    from fa_book_controls bc, gl_sets_of_books sob, fnd_currencies cur
    WHERE  bc.book_type_code = var.book
    AND    sob.set_of_books_id = decode(param.mrcsobtype, 'P', bc.set_of_books_id,
                                    param.sob_id)     -- MRC
    AND    sob.currency_code    = cur.currency_code;

   /* StatReq - The following statement has been added to get the natural account segment's valueset */

   return_status := FND_FLEX_APIS.GET_SEGMENT_INFO
                        (101, 'GL#', var.Acct_Flex_Struct, var.Acct_Segnum,
                         var.Acct_Appl_Col, var.Acct_Segname, var.Acct_Prompt, var.Acct_Valueset_Name);

   mesg_name := 'FA_AMT_SEL_PERIODS';

    select period_counter, period_open_date,
        nvl(period_close_date, sysdate),
        decode(period_close_date, null, 'NO','YES'),
        fiscal_year,
        trunc(calendar_period_open_date), -- Bug3499862
        trunc(calendar_period_close_date) -- Bug3499862
    into  var.period_counter,  var.period_open_date, var.period_close_date,
        period_closed, var.period_fy,
        var.calendar_period_open_date,var.calendar_period_close_date  -- Bug3499862
    from fa_deprn_periods
    where book_type_code = var.book
    and period_name = var.period;

   mesg_name := 'FA_RX_RESERVE_LEDGER';

     fa_rx_util_pkg.debug('********book:' || var.book);
     fa_rx_util_pkg.debug('******period:' || var.period);
     fa_rx_util_pkg.debug('period_close:' || period_closed);

/* Removed check of period_closed status on 24th Nov 2000
   to populate assets information of current open period. */

   -- if period_closed = 'YES' then
        fa_rx_shared_pkg.fa_rsvldg (
                book    => var.book,
                sob_id  => var.set_of_books_id,   -- MRC
                period  => var.period,
                report_style => var.report_style,
                errbuf  => error_errbuf,
                retcode => error_retcode);
   -- end if;

   --
   -- Figure out the where clause for the parameters
   --
   l_param_where := null;

   -- BALANCING --
   if param.from_bal is not null and param.to_bal is not null then

     l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(101,'GL#', var.chart_of_accounts_id,'CC',
        'SELECT', 'GL_BALANCING')||' between :from_bal and :to_bal)';

  end if;

--

   -- ACCOUNT --
   if param.from_acct is not null and param.to_acct is not null then
     l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(101,'GL#', var.chart_of_accounts_id,'CC',
        'SELECT', 'GL_ACCOUNT') || ' between :from_acct and :to_acct)';

   end if;

   -- COST CENTER --
   if param.from_cc is not null and param.to_cc is not null then
     l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(101,'GL#', var.chart_of_accounts_id,'CC',
        'SELECT', 'FA_COST_CTR') ||' between :from_cc and :to_cc)';
   end if;

     -- Major Category --
   if param.from_maj_cat is not null and param.to_maj_cat is not null then
     l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', var.cat_flex_struct,'CAT',
        'SELECT', 'BASED_CATEGORY') ||' between :from_maj_cat and :to_maj_cat)';

   end if;

   -- Minor Category --
   begin
     if param.from_min_cat is not null and param.to_min_cat is not null then
       l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', var.cat_flex_struct,'CAT',
        'SELECT', 'MINOR_CATEGORY') ||' between :from_min_cat and :to_min_cat)';

     elsif param.from_min_cat is not null  and param.to_min_cat is null then
       l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', var.cat_flex_struct,'CAT',
        'SELECT', 'MINOR_CATEGORY') ||'>= :from_min_cat)';
     elsif param.from_min_cat is null and param.to_min_cat is not null then
       l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', var.cat_flex_struct,'CAT',
        'SELECT', 'MINOR_CATEGORY') ||'<= :to_min_cat )';
     end if;
   exception
     when others then
       l_param_where := l_param_where || ' AND (:from_min_cat is NULL and :from_min_cat is NULL'||
                                         ' and :to_min_cat is NULL and :to_min_cat is NULL)';
   end;


   -- Property Type --
   if param.prop_type is not null then
     l_param_where := l_param_where || ' AND (CAT.PROPERTY_TYPE_CODE = :prop_type) ';
   end if;
   -- Asset Number --
   if param.from_asset_num is not null and param.to_asset_num is not null then
      l_param_where := l_param_where || ' AND (AD.ASSET_NUMBER between :from_asset_num and :to_asset_num)';
   elsif param.from_asset_num is not null and param.to_asset_num is null then

      l_param_where := l_param_where || ' AND (AD.ASSET_NUMBER >= :from_asset_num)';
   end if;

   -- Category Segment Number --
   IF (param.cat_seg_num IS NOT NULL) THEN
      var.cat_seg_num := param.cat_seg_num;
     if param.from_cat_seg_val is not null and param.to_cat_seg_val is not null then
        l_param_where := l_param_where || ' AND (' ||
           fa_rx_flex_pkg.flex_sql(140,'CAT#', var.cat_flex_struct,'CAT',
           'SELECT',param.cat_seg_num) ||' between from_cat_seg_val and :to_cat_seg_val)';

     end if;
   END IF;

   --
   -- Get Columns for Major_category, Minor_category and Specified_category
   --

    maj_select_statement := fa_rx_flex_pkg.flex_sql(140,'CAT#', var.cat_flex_struct,'CAT','SELECT', 'BASED_CATEGORY');

   begin
     min_select_statement := fa_rx_flex_pkg.flex_sql(140,'CAT#', var.cat_flex_struct,'CAT','SELECT', 'MINOR_CATEGORY');
   exception
     when others then
       min_select_statement := 'null';
       var.minor_category := null;
   end;

   begin
     if param.cat_seg_num <> '' then
        spec_select_statement := fa_rx_flex_pkg.flex_sql(140,'CAT#', var.cat_flex_struct,'CAT','SELECT', param.cat_seg_num);
     else
       spec_select_statement := 'null';
       var.specified_cat_seg := null;
     end if;
   exception
     when others then
       spec_select_statement := 'null';
       var.specified_cat_seg := null;
   end;


   --
   -- Assign SELECT list
   --
   -->>SELECT_START<<--
   fa_rx_util_pkg.assign_column('1','cc.code_combination_id',   null,'farx_dp.var.ccid','NUMBER');
   fa_rx_util_pkg.assign_column('2','fy.fiscal_year',           null,'farx_dp.var.fy','NUMBER');
   fa_rx_util_pkg.assign_column('3','cb.asset_cost_acct',       'asset_cost_acct','farx_dp.var.asset_cost_acct','VARCHAR2', 25);
   fa_rx_util_pkg.assign_column('4','rsv.deprn_reserve_acct',   'accum_deprn_acct','farx_dp.var.deprn_rsv_acct','VARCHAR2', 25);
   fa_rx_util_pkg.assign_column('5','ad.asset_number',          'asset_number','farx_dp.var.asset_number','VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('6','ad.description',           'description','farx_dp.var.description','VARCHAR2', 80);
   fa_rx_util_pkg.assign_column('7','ad.tag_number',            'tag_number','farx_dp.var.tag_number','VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('8','ad.serial_number',         'serial_number','farx_dp.var.serial_number','VARCHAR2', 35);
   fa_rx_util_pkg.assign_column('9','ad.inventorial',           'inventorial','farx_dp.var.inventorial','VARCHAR2', 3);
   fa_rx_util_pkg.assign_column('10','rsv.date_placed_in_service','date_placed_in_service','farx_dp.var.date_placed_in_service','DATE');
   fa_rx_util_pkg.assign_column('11','rsv.method_code',         'deprn_method','farx_dp.var.method_code', 'VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('12','rsv.life',                null,'farx_dp.var.life','NUMBER');
   fa_rx_util_pkg.assign_column('13','rsv.rate',                'adjusted_rate','farx_dp.var.rate','NUMBER');
   fa_rx_util_pkg.assign_column('14','ds.bonus_rate',           null,'farx_dp.var.bonus_rate','NUMBER');
   fa_rx_util_pkg.assign_column('15','rsv.capacity',            null,'farx_dp.var.capacity','NUMBER');
   fa_rx_util_pkg.assign_column('16','rsv.cost',                'cost','farx_dp.var.cost','NUMBER');
   fa_rx_util_pkg.assign_column('17','rsv.deprn_amount',        'deprn_amount','farx_dp.var.deprn_amount','NUMBER');
   fa_rx_util_pkg.assign_column('18','rsv.ytd_deprn',           'ytd_deprn','farx_dp.var.ytd_deprn','NUMBER');
   fa_rx_util_pkg.assign_column('19','rsv.deprn_reserve',       'ltd_deprn','farx_dp.var.reserve','NUMBER');
   fa_rx_util_pkg.assign_column('20','nvl(dh.units_assigned,0)/nvl(ah.units,1)*100','percent','farx_dp.var.percent', 'NUMBER');
   fa_rx_util_pkg.assign_column('21','rsv.transaction_type',    null,'farx_dp.var.transaction_type','VARCHAR2', 1);
   fa_rx_util_pkg.assign_column('22','dh.location_id',          null,'farx_dp.var.location_id','NUMBER');
   fa_rx_util_pkg.assign_column('23','ah.category_id',          null,'farx_dp.var.category_id','NUMBER');
   fa_rx_util_pkg.assign_column('24','ad.asset_key_ccid',       null,'farx_dp.var.asset_key_ccid','NUMBER');
   fa_rx_util_pkg.assign_column('25', null,                   'life_yr_mo','farx_dp.var.life_yr_mo','NUMBER');
   fa_rx_util_pkg.assign_column('26',null,                      'nbv','farx_dp.var.nbv','NUMBER');
   fa_rx_util_pkg.assign_column('27',null,                      'period_name','farx_dp.var.period','VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('28',null,                      'deprn_expense_acct','farx_dp.var.acct_all_segs(farx_dp.var.acct_segnum)','VARCHAR2', 25);
   fa_rx_util_pkg.assign_column('29',null,                      'account_description','farx_dp.var.account_description', 'VARCHAR2', 240);
   fa_rx_util_pkg.assign_column('30',null,                      'company','farx_dp.var.acct_all_segs(farx_dp.var.bal_segnum)','VARCHAR2', 25);
   fa_rx_util_pkg.assign_column('31',null,                      'cost_center','farx_dp.var.acct_all_segs(farx_dp.var.cc_segnum)','VARCHAR2', 25);
   fa_rx_util_pkg.assign_column('32',null,                      'book_type_code','farx_dp.var.book','VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('33',null,                      'category','farx_dp.var.concat_cat_str','VARCHAR2', 500);
   fa_rx_util_pkg.assign_column('34',null,                      'location','farx_dp.var.concat_loc_str','VARCHAR2', 500);
   fa_rx_util_pkg.assign_column('35',null,                      'asset_key','farx_dp.var.concat_key_str','VARCHAR2', 240);
   fa_rx_util_pkg.assign_column('36','cat.description',         'category_description', 'farx_dp.var.category_description','VARCHAR2',240);
   fa_rx_util_pkg.assign_column('37','substrb(emp.full_name, 1,50)',            'employee_name','farx_dp.var.emp_name','VARCHAR2',50);
   fa_rx_util_pkg.assign_column('38','substrb(emp.employee_number, 1, 15)',     'employee_number','farx_dp.var.emp_number','VARCHAR2',15);
   fa_rx_util_pkg.assign_column('39','dh.units_assigned',       'units','farx_dp.var.units','NUMBER');
   fa_rx_util_pkg.assign_column('40',null,                      'company_description',
        'farx_dp.var.company_description','VARCHAR2',240);
   fa_rx_util_pkg.assign_column('41',null,                      'expense_acct_description',
        'farx_dp.var.expense_acct_description','VARCHAR2',240);
   fa_rx_util_pkg.assign_column('42',null,                      'cost_center_description',
        'farx_dp.var.cost_center_description','VARCHAR2',240);
   fa_rx_util_pkg.assign_column('43',null,                      'organization_name','farx_dp.var.organization_name','VARCHAR2',80);
   fa_rx_util_pkg.assign_column('44',null,                      'functional_currency_code','farx_dp.var.currency_code','VARCHAR2',15);
   fa_rx_util_pkg.assign_column('45',null,                      'nbv_beginning_fy','farx_dp.var.nbv_beginning_fy','NUMBER');
   fa_rx_util_pkg.assign_column('46',null,                      'set_of_books_id','farx_dp.var.set_of_books_id','NUMBER');
   fa_rx_util_pkg.assign_column('47',maj_select_statement,      'major_category','farx_dp.var.major_category','VARCHAR2',240);
   fa_rx_util_pkg.assign_column('48',min_select_statement,      'minor_category','farx_dp.var.minor_category','VARCHAR2',240);
   fa_rx_util_pkg.assign_column('49',null,                      'major_category_description','farx_dp.var.major_category_desc','VARCHAR2',240);
   fa_rx_util_pkg.assign_column('50',null,                      'minor_category_description','farx_dp.var.minor_category_desc','VARCHAR2',240);
   fa_rx_util_pkg.assign_column('51',spec_select_statement,     'specified_category_segment','farx_dp.var.specified_cat_seg','VARCHAR2',240);
   fa_rx_util_pkg.assign_column('52',null,                      'specified_category_seg_desc','farx_dp.var.specified_cat_seg_desc','VARCHAR2',240);
   fa_rx_util_pkg.assign_column('53',null,                      'reserve_acct_desc','farx_dp.var.reserve_acct_desc','VARCHAR2',240);
   fa_rx_util_pkg.assign_column('54','decode(ad.asset_type,''GROUP'',ad.asset_number,nvl(ad1.asset_number,lu.meaning))','group_asset_number','farx_dp.var.group_asset_number','VARCHAR2',15);
   fa_rx_util_pkg.assign_column('55','books.salvage_value',     'salvage_value','farx_dp.var.salvage_value','NUMBER');
   -->>SELECT_END<<--


   --
   -- Assign From Clause
   --
   if(param.mrcsobtype <> 'R') then  -- MRC
      fa_rx_util_pkg.From_Clause := 'fa_reserve_ledger_gt rsv,
                fa_distribution_history dh,
                fa_additions ad,
                fa_additions ad1,
                fa_asset_history ah,
                fa_fiscal_year fy,
                fa_category_books cb,
                gl_code_combinations cc,
                fa_deprn_summary ds,
                fa_books                books,
                fa_categories           cat,
                fa_category_book_defaults cbd,
                per_all_people_f        emp,
                fa_deprn_detail         dd,
                fa_lookups              lu';
   -- MRC
   else
      fa_rx_util_pkg.From_Clause := 'fa_reserve_ledger_gt rsv,
                fa_distribution_history dh,
                fa_additions ad,
                fa_additions ad1,
                fa_asset_history ah,
                fa_fiscal_year fy,
                fa_category_books cb,
                gl_code_combinations cc,
                fa_mc_deprn_summary ds,
                fa_mc_books             books,
                fa_categories           cat,
                fa_category_book_defaults cbd,
                per_all_people_f        emp,
                fa_mc_deprn_detail      dd,
                fa_lookups              lu';
   end if;
   -- End MRC

   --
   -- Assign Where Clause
   --
   if(param.mrcsobtype <> 'R') then  -- MRC
      fa_rx_util_pkg.Where_Clause := '
                rsv.asset_id = ad.asset_id
        and     rsv.asset_id = dh.asset_id
        and     rsv.dh_ccid             = dh.code_combination_id
        and     rsv.distribution_id     = dh.distribution_id
        and     dh.date_effective < rsv.date_effective and
                nvl(dh.date_ineffective,sysdate) >= rsv.date_effective
        and     rsv.dh_ccid             = cc.code_combination_id
        and     cb.book_type_code       = :b_book and
                cb.category_id          = ah.category_id
        and     ah.asset_id             = ad.asset_id           and
                ah.date_effective       < rsv.date_effective    and
                nvl(ah.date_ineffective,sysdate) >= rsv.date_effective
        and     ad1.asset_id (+)        = books.group_asset_id       -- added for drill down report
        and     lu.lookup_code (+)      = ad.asset_type         and
                lu.lookup_type (+)      = ''ASSET TYPE''
        and     ds.period_counter (+)   = rsv.period_counter    and
                ds.book_type_code (+)   = :b_book                       and
                ds.asset_id (+)         = rsv.asset_id
        and     fy.fiscal_year_name =   :b_fy_name      and
                rsv.date_placed_in_service between fy.start_date and fy.end_date
        and     rsv.date_placed_in_service <= :b_period_close_date -- Added for Bug#3499862
        and     books.book_type_code    = :b_book
        and     books.asset_id          = rsv.asset_id
        and     books.date_effective    <  rsv.date_effective and
                nvl(books.date_ineffective,sysdate) >= rsv.date_effective
        and     cat.category_id         = ah.category_id
        and     cbd.category_id         = ah.category_id
        and     cbd.book_type_code      = :b_book
        and     rsv.date_placed_in_service between
                cbd.start_dpis and nvl(cbd.end_dpis,rsv.date_placed_in_service)
        and     emp.person_id(+)        = dh.assigned_to
        and     trunc(sysdate) between
                       effective_start_date(+) and effective_end_date(+)
        and     dd.book_type_code       = :b_book
        and     dd.asset_id             = rsv.asset_id
        and     dd.distribution_id      = dh.distribution_id
        and    (books.group_asset_id is null
          or (
               books.group_asset_id is not null
           and exists (select 1
                       from   fa_books oldbk
                            , fa_transaction_headers oldth
                            , fa_deprn_periods dp
                       where  oldbk.transaction_header_id_out = books.transaction_header_id_in
                       and    oldbk.transaction_header_id_out = oldth.transaction_header_id
                       and   dp.book_type_code = :b_book
                       and   dp.period_counter = dd.period_counter
                       and   oldth.date_effective between dp.period_open_date
                                                      and nvl(dp.period_close_date, oldth.date_effective)
                       and   oldbk.group_asset_id is null)
             )
          or (nvl(:b_report_style,''S'') = ''D'')
               )
        and     dd.period_counter       = rsv.period_counter ' ||  l_param_where ;
   -- MRC
   else
      fa_rx_util_pkg.Where_Clause := '
                rsv.asset_id = ad.asset_id
        and     rsv.asset_id = dh.asset_id
        and     rsv.dh_ccid             = dh.code_combination_id
        and     rsv.distribution_id     = dh.distribution_id
        and     dh.date_effective < rsv.date_effective and
                nvl(dh.date_ineffective,sysdate) >= rsv.date_effective
        and     rsv.dh_ccid             = cc.code_combination_id
        and     cb.book_type_code       = :b_book and
                cb.category_id          = ah.category_id
        and     ah.asset_id             = ad.asset_id           and
                ah.date_effective       < rsv.date_effective    and
                nvl(ah.date_ineffective,sysdate) >= rsv.date_effective
        and     ad1.asset_id (+)        = books.group_asset_id       -- added for drill down report
        and     lu.lookup_code (+)      = ad.asset_type         and
                lu.lookup_type (+)      = ''ASSET TYPE''
        and     ds.period_counter (+)   = rsv.period_counter    and
                ds.book_type_code (+)   = :b_book                       and
                ds.asset_id (+)         = rsv.asset_id
        and     fy.fiscal_year_name =   :b_fy_name      and
                rsv.date_placed_in_service between fy.start_date and fy.end_date
        and     rsv.date_placed_in_service <= :b_period_close_date -- Added for Bug#3499862
        and     books.book_type_code    = :b_book
        and     books.asset_id          = rsv.asset_id
        and     books.date_effective    <  rsv.date_effective and
                nvl(books.date_ineffective,sysdate) >= rsv.date_effective
        and     cat.category_id         = ah.category_id
        and     cbd.category_id         = ah.category_id
        and     cbd.book_type_code      = :b_book
        and     rsv.date_placed_in_service between
                cbd.start_dpis and nvl(cbd.end_dpis,rsv.date_placed_in_service)
        and     emp.person_id(+)        = dh.assigned_to
        and     trunc(sysdate) between
                       effective_start_date(+) and effective_end_date(+)
        and     dd.book_type_code       = :b_book
        and     dd.asset_id             = rsv.asset_id
        and     dd.distribution_id      = dh.distribution_id
        and    (books.group_asset_id is null
          or (
               books.group_asset_id is not null
           and exists (select 1
                       from   fa_mc_books oldbk
                            , fa_transaction_headers oldth
                            , fa_mc_deprn_periods dp
                       where  oldbk.transaction_header_id_out = books.transaction_header_id_in
                       and    oldbk.transaction_header_id_out = oldth.transaction_header_id
                       and   dp.book_type_code = :b_book
                       and   dp.period_counter = dd.period_counter
                       and   oldth.date_effective between dp.period_open_date
                                                      and nvl(dp.period_close_date, oldth.date_effective)
                       and   oldbk.group_asset_id is null
                       and   oldbk.set_of_books_id = :b_set_of_books_id
                       and   dp.set_of_books_id    = :b_set_of_books_id
                     )
             )
          or (nvl(:b_report_style,''S'') = ''D'')
               )
        and     ds.set_of_books_id      = :b_set_of_books_id
        and     dd.set_of_books_id      = :b_set_of_books_id
        and     books.set_of_books_id   = :b_set_of_books_id
        and     dd.period_counter       = rsv.period_counter ' ||  l_param_where ;
   end if;
   -- End MRC

   mesg_name := 'FA_DEPRN_SQL_DCUR';
   fa_rx_util_pkg.debug('farx_dp.before_report()-');
end before_report;


/*
 * This is the bind trigger
 * for the main Reserve Ledger Report.
 */
procedure bind(c in integer)
is
BEGIN
   --
   -- These bind variables were included in the WHERE clause.
   --

   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('farx_dp.bind()+');
   END IF;
   dbms_sql.bind_variable(c, 'b_book', var.book);
   dbms_sql.bind_variable(c, 'b_fy_name', var.fy_name);
   dbms_sql.bind_variable(c, 'b_report_style', var.report_style);
   -- MRC
   if param.mrcsobtype = 'R' then
      dbms_sql.bind_variable(c, 'b_set_of_books_id', var.set_of_books_id);
   end if;
   -- End MRC
   if (param.from_bal is not null and param.to_bal is not null) then
     dbms_sql.bind_variable(c, 'from_bal', param.from_bal);
     dbms_sql.bind_variable(c, 'to_bal', param.to_bal);
   end if;
   if param.from_acct is not null and param.to_acct is not null then
     dbms_sql.bind_variable(c, 'from_acct', param.from_acct);
     dbms_sql.bind_variable(c, 'to_acct', param.to_acct);
   end if;
   if param.from_cc is not null and param.to_cc is not null then
     dbms_sql.bind_variable(c, 'from_cc', param.from_cc);
     dbms_sql.bind_variable(c, 'to_cc', param.to_cc);
   end if;
   if param.from_maj_cat is not null and param.to_maj_cat is not null then
     dbms_sql.bind_variable(c, 'from_maj_cat', param.from_maj_cat);
     dbms_sql.bind_variable(c, 'to_maj_cat', param.to_maj_cat);
   end if;
   if param.from_min_cat is not null  then
     dbms_sql.bind_variable(c, 'from_min_cat', param.from_min_cat);
   end if;
   if param.to_min_cat is not null then
     dbms_sql.bind_variable(c, 'to_min_cat', param.to_min_cat);
   end if;
   if param.prop_type is not null then
     dbms_sql.bind_variable(c, 'prop_type', param.prop_type);
   end if;
   if param.from_asset_num is not null and param.to_asset_num is not null then
     dbms_sql.bind_variable(c, 'from_asset_num', param.from_asset_num);
     dbms_sql.bind_variable(c, 'to_asset_num', param.to_asset_num);
   elsif param.from_asset_num is not null  and param.to_asset_num is null then
     dbms_sql.bind_variable(c, 'from_asset_num', param.from_asset_num);
   end if;

   dbms_sql.bind_variable(c, 'b_period_close_date', var.calendar_period_close_date); -- Added for Bug#3499862.

   IF (param.cat_seg_num IS NOT NULL) THEN
     dbms_sql.bind_variable(c, 'from_cat_seg_val', param.from_cat_seg_val);
     dbms_sql.bind_variable(c, 'to_cat_seg_val', param.to_cat_seg_val);
   END IF;
   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('farx_dp.bind()-');
   END IF;
end bind;


/*
 * This is the after fetch trigger
 * for the main Reserve Ledger Report.
 */
procedure after_fetch
is
begin
   fa_rx_util_pkg.debug('farx_dp.after_fetch()+');
   var.account_description := fa_rx_shared_pkg.get_flex_val_meaning(
                NULL, var.acct_valueset_name, var.asset_cost_acct);

   mesg_name := 'FA_RX_CONCAT_SEGS';
   flex_error := 'GL#';
   ccid_error := var.ccid;

   fa_rx_shared_pkg.concat_acct (
      struct_id => var.acct_flex_struct,
      ccid => var.ccid,
      concat_string => var.concat_acct_str,
      segarray => var.acct_all_segs);

   flex_error := 'CAT#';
   ccid_error := var.category_id;

   fa_rx_shared_pkg.concat_category (
      struct_id => var.cat_flex_struct,
      ccid => var.category_id,
      concat_string => var.concat_cat_str,
      segarray => var.cat_segs);

   flex_error := 'LOC#';
   ccid_error := var.location_id;

   fa_rx_shared_pkg.concat_location (
      struct_id => var.loc_flex_struct,
      ccid => var.location_id,
      concat_string => var.concat_loc_str,
      segarray => var.loc_segs);

   /* StatReq - The following three statement have been added to get the
      concatenated asset key flexfield value */

   if (var.asset_key_ccid is not NULL)
   then
      DECLARE
         buf VARCHAR2(500);
      BEGIN
         flex_error := 'KEY#';
         ccid_error := var.asset_key_ccid;

         fa_rx_shared_pkg.concat_asset_key (
                                            struct_id => var.assetkey_flex_struct,
                                            ccid => var.asset_key_ccid,
                                            concat_string => buf,
                                            segarray => var.key_segs);
         var.concat_key_str := substrb(buf, 1,240);
      END;
   else
      var.concat_key_str := '';  --bug#7456179
   end if;

   var.company_description :=
     fa_rx_flex_pkg.get_description(
         p_application_id => 101,
         p_id_flex_code   => 'GL#',
         p_id_flex_num    => var.chart_of_accounts_id,
         p_qualifier      => 'GL_BALANCING',
         p_data           => var.acct_all_segs(var.bal_segnum));

   var.expense_acct_description :=
     fa_rx_flex_pkg.get_description(
         p_application_id => 101,
         p_id_flex_code   => 'GL#',
         p_id_flex_num    => var.chart_of_accounts_id,
         p_qualifier      => 'GL_ACCOUNT',
         p_data           => var.acct_all_segs(var.acct_segnum));

   var.reserve_acct_desc :=
     fa_rx_flex_pkg.get_description(
         p_application_id => 101,
         p_id_flex_code   => 'GL#',
         p_id_flex_num    => var.chart_of_accounts_id,
         p_qualifier      => 'GL_ACCOUNT',
         p_data           => var.deprn_rsv_acct);

   var.cost_center_description :=
     fa_rx_flex_pkg.get_description(
         p_application_id => 101,
         p_id_flex_code   => 'GL#',
         p_id_flex_num    => var.chart_of_accounts_id,
         p_qualifier      => 'FA_COST_CTR',
         p_data           => var.acct_all_segs(var.cc_segnum));

   begin
    var.major_category_desc :=
      fa_rx_flex_pkg.get_description(
         p_application_id => 140,
         p_id_flex_code   => 'CAT#',
         p_id_flex_num    => var.cat_flex_struct,
         p_qualifier      => 'BASED_CATEGORY',
         p_data           => var.major_category);
   exception
      when others then
        var.major_category_desc := null;
   end;

   begin
     var.minor_category_desc :=
       fa_rx_flex_pkg.get_description(
         p_application_id => 140,
         p_id_flex_code   => 'CAT#',
         p_id_flex_num    => var.cat_flex_struct,
         p_qualifier      => 'MINOR_CATEGORY',
         p_data           => var.minor_category);
   exception
      when others then
        var.minor_category_desc := null;
   end;

   begin
     var.specified_cat_seg_desc :=
       fa_rx_flex_pkg.get_description(
         p_application_id => 140,
         p_id_flex_code   => 'CAT#',
         p_id_flex_num    => var.cat_flex_struct,
         p_qualifier      => param.cat_seg_num,
         p_data           => var.specified_cat_seg);
   exception
      when others then
        var.specified_cat_seg_desc := null;
   end;

   var.nbv := var.cost - var.reserve;
   var.nbv_beginning_fy := var.nbv + var.ytd_deprn;

 IF (var.life IS NULL) THEN
    var.life_yr_mo := NULL;
 ELSE
    var.life_yr_mo :=
      fnd_number.canonical_to_number(
      to_char(floor(var.life/12))||'.'||to_char(mod(var.life,12), 'FM00'));
 END IF;
 mesg_name := 'FA_SHARED_INSERT_FAILED';
 fa_rx_util_pkg.debug('farx_dp.after_fetch()-');
end after_fetch;
END FARX_DP;

/
