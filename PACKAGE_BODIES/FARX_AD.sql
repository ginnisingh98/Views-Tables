--------------------------------------------------------
--  DDL for Package Body FARX_AD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_AD" as
/* $Header: farxadb.pls 120.21.12010000.8 2009/11/26 11:14:00 bmaddine ship $ */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

procedure ADD_BY_PERIOD (
   book		in	varchar2,
   begin_period in	varchar2,
   end_period	in	varchar2,
   from_maj_cat in	varchar2,
   to_maj_cat	in	varchar2,
   from_min_cat in	varchar2,
   to_min_cat 	in	varchar2,
   from_cc 	in	varchar2,
   to_cc	in	varchar2,
   cat_seg_num	in	varchar2,
   from_cat_seg_val in	varchar2,
   to_cat_seg_val   in	varchar2,
   from_asset_num   in	varchar2,
   to_asset_num     in	varchar2,
   request_id   in	number,
   user_id	in	number,
   retcode out nocopy number,
   errbuf out nocopy varchar2) is

  mesg			varchar2(200);
  ctr			number;

  h_login_id		number;
  h_request_id		number;

  h_book		varchar2(15);
  h_period1_pc		varchar2(15);
  h_period2_pc		varchar2(15);

  h_bonus_rate		number;
  h_reserve_acct	varchar2(25);
  h_adjusted_Rate	number;
  h_prod_capacity	number;
  h_life_months		number;
  h_life_year_month	varchar2(10);
  h_life_year_month_num number;
  h_method		varchar2(15);
  h_dpis		date;
  h_invoice_flag	varchar2(1);
  h_cost_to_clear	number;
  h_invoice_cost	number;
  h_invoice_orig_cost	number;
  h_invoice_descr	varchar2(80);
  h_line_number		number;
  h_invoice_number	varchar2(50);
  h_tag_number		varchar2(15);
  h_serial_number	varchar2(35);
  h_inventorial		varchar2(3);
  h_vendor_number	varchar2(30);
  h_description		varchar2(80);
  h_asset_number	varchar2(15);
  h_asset_type		varchar2(15);
  h_cost_acct		varchar2(25);
  h_asset_type_mean	varchar2(80);
  h_ccid		number;
  h_source		varchar2(20);
  h_set_of_books_id     number;
  h_currency_code	varchar2(15);
  h_organization_name	varchar2(80);

  h_period_name		varchar2(25);
  h_period_name_to	varchar2(25);
  h_account_desc	varchar2(240);
  h_cost_center_desc	varchar2(240);
  h_ytd_deprn		number;
  h_deprn_reserve	number;
  h_tran_header_id	number;

  h_maj_cat		varchar2(240);
  h_maj_cat_desc	varchar2(240);
  h_min_cat		varchar2(240);
  h_min_cat_desc	varchar2(240);
  h_specified_cat	varchar2(240);
  h_specified_cat_desc	varchar2(240);

  h_category_id		number;
  h_location_id		number;
  h_asset_key_ccid	number;
  h_cat_seg_num		varchar2(15);

  h_concat_acct		varchar2(200);
  h_concat_cat		varchar2(200);
  h_concat_loc		varchar2(200);
  h_concat_key		varchar2(200);
  h_acct_segs		fa_rx_shared_pkg.Seg_Array;
  h_cat_segs		fa_rx_shared_pkg.Seg_Array;
  h_loc_segs		fa_rx_shared_pkg.Seg_Array;
  h_key_segs		fa_rx_shared_pkg.Seg_Array;

  h_acct_seg		number;
  h_cost_seg		number;
  h_bal_seg		number;

  h_dist_source_book 	varchar2(15);

  h_acct_flex_struct	number;
  h_cat_flex_struct	number;
  h_loc_flex_struct	number;
  h_assetkey_flex_structure	number;
  h_chart_of_accounts_id	number;

  h_count		number;

  h_mesg_name		varchar2(50);
  h_mesg_str		varchar2(2000);
  h_flex_error		varchar2(5);
  h_ccid_error		number;

  maj_select_statement	varchar2(50);
  min_select_statement   varchar2(50);
  spec_select_statement  varchar2(50);

  l_param_where		varchar2(1000);
  where_clause1		varchar2(4000);
  where_clause2		varchar2(4000);
  where_clause3		varchar2(4000);
  where_clause4		varchar2(4000);
  select_statement	varchar2(25000);

  type var_cur is ref cursor;
  additions var_cur;

  h_sort  varchar2(3);
  h_group_asset_number varchar2(15);

begin
     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('farx_ad.add_by_period()+');
     END IF;

  h_book := book;
  h_period_name := begin_period;
  h_period_name_to := end_period;
  h_cat_seg_num := cat_seg_num;
  ctr := 0;
  h_request_id := request_id;

  select fcr.last_update_login into h_login_id
  from fnd_concurrent_requests fcr
  where fcr.request_id = h_request_id;

     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || '********login_id:' || h_login_id);
     	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || '********login_id:' || h_login_id);
     END IF;

  h_mesg_name := 'FA_AMT_SEL_PERIODS';

  select period_counter
  into h_period1_pc
  from fa_deprn_periods
  where book_type_code = h_book and period_name = begin_period;

  select count(*) into h_count
  from fa_deprn_periods where period_name = end_period
  and book_type_code = h_book;

  if (h_count > 0) then
    select period_counter
    into h_period2_pc
    from fa_deprn_periods
    where book_type_code = h_book and period_name = end_period;
  else
    h_period2_pc := null;
  end if;

     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || 'begin_period,h_period1_pc:' || begin_period || ',' || h_period1_pc);
     	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || 'end_period,h_period2_pc:' || end_period || ',' || h_period2_pc);
     END IF;

  h_mesg_name := 'FA_REC_SQL_ACCT_FLEX';

  select nvl(distribution_source_book, book_type_code), accounting_flex_structure
  into h_dist_source_book, h_acct_flex_struct
  from fa_book_controls
  where book_type_code = h_book;

  h_mesg_name := 'FA_FA_LOOKUP_IN_SYSTEM_CTLS';

  select location_flex_structure, category_flex_structure,asset_key_flex_structure
  into h_loc_flex_struct, h_cat_flex_struct, h_assetkey_flex_structure
  from fa_system_controls;

   h_mesg_name := 'FA_RX_SEGNUMS';

   fa_rx_shared_pkg.GET_ACCT_SEGMENT_NUMBERS (
   BOOK         => h_book,
   BALANCING_SEGNUM     => h_bal_seg,
   ACCOUNT_SEGNUM       => h_acct_seg,
   CC_SEGNUM            => h_cost_seg,
   CALLING_FN           => 'ADD_BY_PERIOD');

   select sob.chart_of_accounts_id,
	  sob.set_of_books_id,
	  substr(sob.currency_code,1,15),
	  substr(sob.name,1,80)
   into	  h_chart_of_accounts_id,
	  h_set_of_books_id,
	  h_currency_code,
	  h_organization_name
   from   fa_book_controls bc, gl_sets_of_books sob, fnd_currencies cur
   WHERE  bc.book_type_code = h_book
   AND    sob.set_of_books_id = bc.set_of_books_id
   AND	  sob.currency_code = cur.currency_code; -- Added set_of_books_id and currency_code to display those on report


     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || 'chart of account ID:' || h_chart_of_accounts_id);
     END IF;

   --
   -- Get Columns for Major_category, Minor_category and Specified_category
   --
    maj_select_statement := fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT','SELECT', 'BASED_CATEGORY');

   begin
    min_select_statement := fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT','SELECT', 'MINOR_CATEGORY');
   exception
     when others then
       min_select_statement := 'null';
   end;

   begin
     spec_select_statement := fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT','SELECT', cat_seg_num);
   exception
     when others then
       spec_select_statement := 'null';
   end;

   --
   -- Figure out the where clause for the parameters
   --

 -- parameter where clause --


   l_param_where := null;

/* BUG# 2939771
     -- Major Category --
   IF(from_maj_cat = to_maj_cat) THEN
      l_param_where := l_param_where || ' AND ' ||
	fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
	'WHERE', 'BASED_CATEGORY','=', from_maj_cat);
   elsif (from_maj_cat is not NULL) and (to_maj_cat is not NULL) THEN
      l_param_where := l_param_where || ' AND ' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
        'WHERE', 'BASED_CATEGORY','BETWEEN', from_maj_cat, to_maj_cat);
   elsif (from_maj_cat is not NULL) THEN
      l_param_where := l_param_where || ' AND ' ||
	fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
	'WHERE', 'BASED_CATEGORY','>=', from_maj_cat);
   elsif (to_maj_cat is not NULL) THEN
      l_param_where := l_param_where || ' AND ' ||
	fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
	'WHERE', 'BASED_CATEGORY','<=', to_maj_cat);
   END IF;
*/

   -- Major Category --
   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
        'SELECT', 'BASED_CATEGORY') ||' >= :from_maj_cat or :from_maj_cat is NULL)';

   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
        'SELECT', 'BASED_CATEGORY') ||' <= :to_maj_cat or :to_maj_cat is NULL)';


/* BUG# 2939771
   -- Minor Category --
   IF (from_min_cat = to_min_cat) THEN
      l_param_where := l_param_where || ' AND ' ||
	fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
	'WHERE', 'MINOR_CATEGORY','=', from_min_cat);
   elsif (from_min_cat is not NULL) and (to_min_cat is not NULL) THEN
      l_param_where := l_param_where || ' AND ' ||
	fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
	'WHERE', 'MINOR_CATEGORY','BETWEEN', from_min_cat, to_min_cat);
   elsif (from_min_cat is not NULL) THEN
      l_param_where := l_param_where || ' AND ' ||
	fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
	'WHERE', 'MINOR_CATEGORY','>=', from_min_cat);
   elsif (to_min_cat is not NULL) THEN
      l_param_where := l_param_where || ' AND ' ||
	fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
	'WHERE', 'MINOR_CATEGORY','<=', to_min_cat);
   END IF;
*/

   -- Minor Category --
   /* Fix for Bug# 2973255: Added expection handling to proceed
                            in case that flex_sql fails when from_min_cat or to_min_cat are null
   */
   begin
     l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
        'SELECT', 'MINOR_CATEGORY') ||' >= :from_min_cat or :from_min_cat is NULL)';
   exception
     when others then
       l_param_where := l_param_where || ' AND (:from_min_cat is NULL and :from_min_cat is NULL)';
   end;

   begin
     l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
        'SELECT', 'MINOR_CATEGORY') ||' <= :to_min_cat or :to_min_cat is NULL)';
   exception
     when others then
       l_param_where := l_param_where || ' AND (:to_min_cat is NULL and :to_min_cat is NULL)';
   end;


/* BUG# 2939771
   -- Category Segment Number --
   IF (cat_seg_num IS NOT NULL) THEN
      h_cat_seg_num := cat_seg_num;
      IF (from_cat_seg_val = to_cat_seg_val) THEN
         l_param_where := l_param_where || ' AND ' ||
	   fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
	   'WHERE',cat_seg_num ,'=', from_cat_seg_val);
      elsif (from_cat_seg_val is not NULL) and (to_cat_seg_val is not NULL) THEN
         l_param_where := l_param_where || ' AND ' ||
	   fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
	   'WHERE',cat_seg_num ,'BETWEEN', from_cat_seg_val, to_cat_seg_val);
      elsif (from_cat_seg_val is not NULL) THEN
         l_param_where := l_param_where || ' AND ' ||
	   fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
	   'WHERE',cat_seg_num ,'>=', from_cat_seg_val);
      elsif (to_cat_seg_val is not NULL) THEN
         l_param_where := l_param_where || ' AND ' ||
	   fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
	   'WHERE',cat_seg_num ,'<=', to_cat_seg_val);
      END IF;
   END IF;
*/

   -- Category Segment Number --
   IF (cat_seg_num IS NOT NULL) THEN
     h_cat_seg_num := cat_seg_num;
     l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
        'SELECT', cat_seg_num) ||' >= :from_cat_seg_val or :from_cat_seg_val is NULL)';

     l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
        'SELECT', cat_seg_num) ||' <= :to_cat_seg_val or :to_cat_seg_val is NULL)';
   ELSE
     l_param_where := l_param_where || ' AND ( nvl(:from_cat_seg_val,-999) = -999 or :from_cat_seg_val is null)';
     l_param_where := l_param_where || ' AND ( nvl(:to_cat_seg_val,-999) = -999 or :to_cat_seg_val is null)';
   END IF;


/*
   -- Category Conditions --
   IF (l_param_where is not NULL) THEN
      l_param_where := l_param_where || ' AND CB.CATEGORY_ID = CAT.CATEGORY_ID';
   END IF;
*/

/* BUG# 2939771
   -- COST CENTER --
   If (from_cc = to_cc) THEN
      l_param_where := l_param_where || ' AND ' ||
	fa_rx_flex_pkg.flex_sql(101,'GL#', h_chart_of_accounts_id,'DHCC',
	'WHERE', 'FA_COST_CTR','=', from_cc);
   elsif (from_cc is not NULL) and (to_cc is not NULL) THEN
      l_param_where := l_param_where || ' AND ' ||
	fa_rx_flex_pkg.flex_sql(101,'GL#', h_chart_of_accounts_id,'DHCC',
	'WHERE', 'FA_COST_CTR','BETWEEN', from_cc, to_cc);
   elsif (from_cc is not NULL) THEN
      l_param_where := l_param_where || ' AND ' ||
	fa_rx_flex_pkg.flex_sql(101,'GL#', h_chart_of_accounts_id,'DHCC',
	'WHERE', 'FA_COST_CTR','>=', from_cc);
   elsif (to_cc is not NULL) THEN
      l_param_where := l_param_where || ' AND ' ||
	fa_rx_flex_pkg.flex_sql(101,'GL#', h_chart_of_accounts_id,'DHCC',
	'WHERE', 'FA_COST_CTR','<=', to_cc);
   end if;
*/

   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(101,'GL#', h_chart_of_accounts_id,'DHCC',
        'SELECT', 'FA_COST_CTR') ||' >= :from_cc or :from_cc is NULL)';

   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(101,'GL#', h_chart_of_accounts_id,'DHCC',
        'SELECT', 'FA_COST_CTR') ||' <= :to_cc or :to_cc is NULL)';

/* BUG # 2939771
   -- Asset Number --
   IF (from_asset_num = to_asset_num) THEN
      l_param_where := l_param_where || ' AND AD.ASSET_NUMBER = '''
        || from_asset_num || '''';
   elsif (from_asset_num is not NULL) and (to_asset_num is not NULL) THEN
      l_param_where := l_param_where || ' AND AD.ASSET_NUMBER BETWEEN '''
        || from_asset_num || '''' || ' AND  ''' || to_asset_num || '''';
   elsif (from_asset_num is not NULL) THEN
      l_param_where := l_param_where || ' AND AD.ASSET_NUMBER >= '''
        || from_asset_num || '''';
   elsif (to_asset_num is not NULL) THEN
      l_param_where := l_param_where || ' AND AD.ASSET_NUMBER <= '''
        || to_asset_num || '''';
   END IF;
*/
   -- Asset Number --
   l_param_where := l_param_where || ' AND (AD.ASSET_NUMBER >= :from_asset_num OR :from_asset_num is NULL)';
   l_param_where := l_param_where || ' AND (AD.ASSET_NUMBER <= :to_asset_num   OR :to_asset_num is NULL)';

     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || 'l_param_where:' || l_param_where);
     END IF;

   where_clause1 := 'DS.BOOK_TYPE_CODE (+) =  :h_book	AND
	DS.ASSET_ID (+)			=  DD.ASSET_ID			AND
	DS.DEPRN_SOURCE_CODE (+)	=  ''DEPRN'' 			AND
	DS.PERIOD_COUNTER (+)		= DD.PERIOD_COUNTER + 1	AND
	DH.ASSET_ID 			= DD.ASSET_ID			AND
	DD.DISTRIBUTION_ID		=  DH.DISTRIBUTION_ID
AND	DH.BOOK_TYPE_CODE 		= :h_dist_source_book AND
	DHCC.CODE_COMBINATION_ID	=  DH.CODE_COMBINATION_ID
AND	AD.ASSET_ID			=  DD.ASSET_ID
AND	DP.BOOK_TYPE_CODE		= :h_book AND
	DP.PERIOD_COUNTER		= dd.period_counter+1
AND     DP1.BOOK_TYPE_CODE               = :h_book AND
        DP1.PERIOD_COUNTER              >= :h_period1_pc AND
        DP1.PERIOD_COUNTER              <=  nvl(:h_period2_pc ,
                                               DP1.PERIOD_COUNTER)
AND	DD.BOOK_TYPE_CODE		=  :h_book 	AND
	DD.DEPRN_SOURCE_CODE		=  ''B''			AND
	DD.PERIOD_COUNTER        >= :h_period1_pc - 1 and
		dd.period_counter <= :h_period2_pc - 1
AND 	bk.transaction_header_id_in = th.transaction_header_id
AND	AH.ASSET_ID			=  th.ASSET_ID			AND
	AH.DATE_EFFECTIVE <=  NVL(DP.PERIOD_CLOSE_DATE, SYSDATE)	AND
	NVL(AH.DATE_INEFFECTIVE, SYSDATE+1) >
		NVL(DP.PERIOD_CLOSE_DATE, SYSDATE)
AND	CB.CATEGORY_ID			=  AH.CATEGORY_ID		AND
	CB.BOOK_TYPE_CODE		=  :h_book
AND	AH.ASSET_TYPE			=  FALU.LOOKUP_CODE	AND
	FALU.LOOKUP_TYPE		= ''ASSET TYPE''
AND	TH.ASSET_ID			= DD.ASSET_ID			AND
        TH.DATE_EFFECTIVE 	       >=  DP.PERIOD_OPEN_DATE		AND
	TH.DATE_EFFECTIVE	<  nvl(DP.PERIOD_CLOSE_DATE,th.date_effective+1) AND
	TH.BOOK_TYPE_CODE		= :h_book    AND
	TH.TRANSACTION_TYPE_CODE 	in (''CIP ADDITION'',''ADDITION'')
AND
        IT.INVOICE_TRANSACTION_ID = AI_IN.INVOICE_TRANSACTION_ID_IN
AND     AI_IN.ASSET_ID (+) = TH.ASSET_ID
AND     AI_IN.DATE_EFFECTIVE            >=  DP.PERIOD_OPEN_DATE          AND  -- modified
        AI_IN.DATE_EFFECTIVE       <  nvl(DP.PERIOD_CLOSE_DATE,sysdate+1)  -- modified
AND  nvl(AI_IN.DATE_INEFFECTIVE,sysdate) not between  			-- modified
        dp.period_open_date and  nvl(DP.PERIOD_CLOSE_DATE,sysdate -1) -- modified
AND	AI_IN.DELETED_FLAG (+) = ''NO''
AND     PO_VEND.VENDOR_ID(+) = AI_IN.PO_VENDOR_ID
AND 	CB.CATEGORY_ID = CAT.CATEGORY_ID
AND     GAD.ASSET_ID(+) = BK.GROUP_ASSET_ID';

   where_clause2 := '
	DS.BOOK_TYPE_CODE 		= :h_book		AND
	DS.ASSET_ID 	 		=  th.asset_id   and
	DS.DEPRN_SOURCE_CODE	 	=  ''DEPRN''		AND
	DS.PERIOD_COUNTER 		= DD.PERIOD_COUNTER
AND	DH.BOOK_TYPE_CODE 		= :h_dist_source_book AND
	DH.ASSET_ID			= dd.ASSET_ID			AND
	DH.DISTRIBUTION_ID		=
	decode(th.asset_id, null,DD.DISTRIBUTION_ID, DD.DISTRIBUTION_ID)	AND
	DH.CODE_COMBINATION_ID		= DHCC.CODE_COMBINATION_ID
AND	DD.BOOK_TYPE_CODE		= :h_book		AND
	DD.ASSET_ID 			= TH.ASSET_ID			AND
        DD.PERIOD_COUNTER =
        ( select max(DD1.PERIOD_COUNTER)
            from FA_DEPRN_DETAIL DD1
           where dd1.period_counter <= dp1.period_counter
	     and DD1.ASSET_ID        = DD.ASSET_ID
             and DD1.BOOK_TYPE_CODE  = DD.BOOK_TYPE_CODE)
AND     DP1.BOOK_TYPE_CODE               =  :h_book    AND
        DP1.PERIOD_COUNTER              >=  :h_period1_pc AND
        DP1.PERIOD_COUNTER              <=  nvl(:h_period2_pc,
                                               DP1.PERIOD_COUNTER)
AND  	TH.DATE_EFFECTIVE 	       >=  DP.PERIOD_OPEN_DATE		AND
	TH.DATE_EFFECTIVE	<  nvl(DP.PERIOD_CLOSE_DATE,th.date_effective+1) AND
	TH.BOOK_TYPE_CODE		= :h_book AND
	th.asset_id			= dd.asset_id   and
	TH.TRANSACTION_TYPE_CODE 	in ( ''ADDITION'' ,  ''CIP ADJUSTMENT'' )
and thadd.book_type_code =th.book_type_code
and thadd.asset_id = th.asset_id
and thadd.transaction_type_code = ''ADDITION''
and thadd.date_effective between dp2.period_open_date and nvl(dp2.period_close_date,sysdate)
and dp2.book_type_code = th.book_type_code
and dp2.period_counter >= :h_period1_pc
and dp2.period_counter <= nvl(:h_period2_pc, dp2.period_counter)
AND     THDIS.TRANSACTION_TYPE_CODE	= ''TRANSFER IN'' AND
	THDIS.BOOK_TYPE_CODE		= :h_book	AND
	THDIS.ASSET_ID			= TH.ASSET_ID		AND
	THDIS.DATE_EFFECTIVE 		< DP.PERIOD_OPEN_DATE
AND	BK.TRANSACTION_HEADER_ID_IN	= TH.TRANSACTION_HEADER_ID
AND	DP.BOOK_TYPE_CODE		=
	 decode(th.asset_id, null,dd.BOOK_TYPE_CODE,dd.BOOK_TYPE_CODE	)
and	DP.PERIOD_COUNTER	        =  dd.PERIOD_COUNTER
AND	AH.ASSET_ID			=  dd.ASSET_ID			AND
	AH.DATE_EFFECTIVE	<=  NVL(DP.PERIOD_CLOSE_DATE, ah.date_effective+1) AND
	NVL(AH.DATE_INEFFECTIVE,SYSDATE+1) >
		NVL(DP.PERIOD_CLOSE_DATE,SYSDATE)
AND	AD.ASSET_ID			=  ah.ASSET_ID
AND	CB.CATEGORY_ID			=  AH.CATEGORY_ID		AND
	CB.BOOK_TYPE_CODE		= :h_book
AND	AH.ASSET_TYPE			=  FALU.LOOKUP_CODE	AND
	FALU.LOOKUP_TYPE		= ''ASSET TYPE''
AND
        IT.INVOICE_TRANSACTION_ID = AI_IN.INVOICE_TRANSACTION_ID_IN
AND     AI_IN.ASSET_ID (+) = TH.ASSET_ID
AND     AI_IN.DATE_EFFECTIVE            >=  DP1.PERIOD_OPEN_DATE          AND
        AI_IN.DATE_EFFECTIVE       <  nvl(DP1.PERIOD_CLOSE_DATE,ai_in.date_effective+1)
and     ai_in.date_ineffective is null
AND     AI_IN.DELETED_FLAG (+) = ''NO''
AND     PO_VEND.VENDOR_ID(+) = AI_IN.PO_VENDOR_ID
AND 	CB.CATEGORY_ID = CAT.CATEGORY_ID
AND     GAD.ASSET_ID(+) = BK.GROUP_ASSET_ID';

  where_clause3 := '
	DS.BOOK_TYPE_CODE (+)           = :h_book                      AND
        DS.ASSET_ID (+)                 =  DD.ASSET_ID                  AND
        DS.DEPRN_SOURCE_CODE (+)        =  ''DEPRN''                      AND
        DS.PERIOD_COUNTER (+)           = DD.PERIOD_COUNTER + 1 AND
        DH.ASSET_ID                     = DD.ASSET_ID                   AND
        DD.DISTRIBUTION_ID              =  DH.DISTRIBUTION_ID
AND	DH.BOOK_TYPE_CODE 		= :h_dist_source_book AND
        DHCC.CODE_COMBINATION_ID        =  DH.CODE_COMBINATION_ID
AND     AD.ASSET_ID                     =  DD.ASSET_ID
AND     DP.BOOK_TYPE_CODE               = :h_book     AND
        DP.PERIOD_COUNTER       = dd.period_counter+1
AND     DD.BOOK_TYPE_CODE               = :h_book                AND
        DD.DEPRN_SOURCE_CODE            =  ''B''                          AND
        DD.PERIOD_COUNTER        >= :h_period1_pc - 1 and
                dd.period_counter <= :h_period2_pc - 1
AND bk.transaction_header_id_in = th.transaction_header_id
AND     AH.ASSET_ID                     =  th.ASSET_ID                  AND
        AH.DATE_EFFECTIVE <=  NVL(DP.PERIOD_CLOSE_DATE,SYSDATE)        AND
        NVL(AH.DATE_INEFFECTIVE, SYSDATE+1) >
                NVL(DP.PERIOD_CLOSE_DATE, SYSDATE)
AND     CB.CATEGORY_ID                  =  AH.CATEGORY_ID               AND
        CB.BOOK_TYPE_CODE               = :h_book
AND     AH.ASSET_TYPE                   =  FALU.LOOKUP_CODE     AND
        FALU.LOOKUP_TYPE                = ''ASSET TYPE''
AND     TH.ASSET_ID                     = DD.ASSET_ID                   AND
        TH.DATE_EFFECTIVE              >=  DP.PERIOD_OPEN_DATE          AND
        TH.DATE_EFFECTIVE       <  nvl(DP.PERIOD_CLOSE_DATE,th.date_effective+1) AND
        TH.TRANSACTION_TYPE_CODE        in (''CIP ADDITION'',''ADDITION'')	AND
        TH.BOOK_TYPE_CODE               = :h_book
AND 	CB.CATEGORY_ID = CAT.CATEGORY_ID
AND     GAD.ASSET_ID(+) = BK.GROUP_ASSET_ID';


   -- Bug 5222214 Added OR condition on DP.PERIOD_COUNTER so that
   -- capitalized assets in the current open period are selected from deprn_periods.

   where_clause4 := '
	DS.BOOK_TYPE_CODE               = :h_book                      AND
        DS.ASSET_ID             =  th.asset_id   and
        DS.DEPRN_SOURCE_CODE    =  ''DEPRN''              AND
        DS.PERIOD_COUNTER               = DD.PERIOD_COUNTER
AND	DH.BOOK_TYPE_CODE 		= :h_dist_source_book AND
        DH.ASSET_ID                     = dd.ASSET_ID                   AND
        DH.DISTRIBUTION_ID              =
        decode(th.asset_id, null,DD.DISTRIBUTION_ID, DD.DISTRIBUTION_ID)        AND
        DH.CODE_COMBINATION_ID          = DHCC.CODE_COMBINATION_ID
AND     DD.BOOK_TYPE_CODE               = :h_book               AND
        DD.ASSET_ID                     = TH.ASSET_ID                   AND
        DD.PERIOD_COUNTER =
        ( select max(DD1.PERIOD_COUNTER)
            from FA_DEPRN_DETAIL DD1, FA_DEPRN_PERIODS DP2
           where dd1.period_counter <= dp2.period_counter
	     and DD1.ASSET_ID        = DD.ASSET_ID
             and DD1.BOOK_TYPE_CODE  = DD.BOOK_TYPE_CODE
	     and DP2.BOOK_TYPE_CODE  = DD1.BOOK_TYPE_CODE
             and DD1.PERIOD_COUNTER >= :h_period1_pc
             and DP2.PERIOD_COUNTER >= :h_period1_pc
             and DP2.PERIOD_COUNTER <= :h_period2_pc )
AND     TH.DATE_EFFECTIVE              >=  DP.PERIOD_OPEN_DATE          AND
        TH.DATE_EFFECTIVE       <  nvl(DP.PERIOD_CLOSE_DATE,th.date_effective+1) AND
        TH.BOOK_TYPE_CODE               = :h_book    AND
        th.asset_id                     = dd.asset_id   and
        TH.TRANSACTION_TYPE_CODE        = ''ADDITION''
AND     THDIS.TRANSACTION_TYPE_CODE     = ''TRANSFER IN'' AND
        THDIS.BOOK_TYPE_CODE            = :h_book     AND
        THDIS.ASSET_ID                  = TH.ASSET_ID           AND
        THDIS.DATE_EFFECTIVE            < DP.PERIOD_OPEN_DATE
AND     BK.TRANSACTION_HEADER_ID_IN     = TH.TRANSACTION_HEADER_ID
AND     DP.BOOK_TYPE_CODE               =
         decode(th.asset_id, null,dd.BOOK_TYPE_CODE,dd.BOOK_TYPE_CODE   )
and     ( (DP.PERIOD_COUNTER            =  dd.PERIOD_COUNTER) OR
          (DP.PERIOD_COUNTER            >= :h_period1_pc AND
	   DP.PERIOD_COUNTER            <= :h_period2_pc AND
	   DP.PERIOD_CLOSE_DATE 	IS NULL          AND
           DP.DEPRN_RUN		        IS NULL))
AND     AH.ASSET_ID                     =  dd.ASSET_ID                  AND
        AH.DATE_EFFECTIVE       <=  NVL(DP.PERIOD_CLOSE_DATE, ah.date_effective+1) AND
        NVL(AH.DATE_INEFFECTIVE, SYSDATE+1) >
                NVL(DP.PERIOD_CLOSE_DATE, SYSDATE)
AND     AD.ASSET_ID                     =  ah.ASSET_ID
AND     CB.CATEGORY_ID                  =  AH.CATEGORY_ID               AND
        CB.BOOK_TYPE_CODE               = :h_book
AND     FALU.LOOKUP_TYPE                = ''ASSET TYPE''
AND     AH.ASSET_TYPE                   =  FALU.LOOKUP_CODE
AND 	CB.CATEGORY_ID = CAT.CATEGORY_ID
AND     GAD.ASSET_ID(+) = BK.GROUP_ASSET_ID';

   IF (l_param_where is not NULL) THEN
       where_clause1 := where_clause1 || l_param_where;
       where_clause2 := where_clause2 || l_param_where;
       where_clause3 := where_clause3 || l_param_where;
       where_clause4 := where_clause4 || l_param_where;
   END IF;

   h_mesg_name := 'FA_ADDITION_SQL_DCUR';

     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || 'where_clause1:' || where_clause1);
     	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || 'where_clause2:' || where_clause2);
     	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || 'where_clause3:' || where_clause3);
     	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || 'where_clause4:' || where_clause4);
     END IF;

--  open additions for

    select_statement := '
SELECT  DISTINCT
        DECODE(TH.MASS_REFERENCE_ID,NULL,''Manual Addition'',''Mass Addition''),
        dhcc.code_combination_id,
        FALU.MEANING,
        AH.ASSET_TYPE,
        DECODE(AH.ASSET_TYPE, ''CIP'', CB.CIP_COST_ACCT,CB.ASSET_COST_ACCT),
        AD.ASSET_NUMBER,
        AD.description,
        ad.tag_number, ad.serial_number, ad.inventorial,
	ad.asset_key_ccid,
        PO_VEND.segment1,
        AI_IN.INVOICE_NUMBER    ,
        AI_IN.AP_DISTRIBUTION_LINE_NUMBER,
        AI_IN.DESCRIPTION,
        AI_IN.PAYABLES_COST,
        DH.UNITS_ASSIGNED/AH.UNITS * AI_IN.FIXED_ASSETS_COST,
        TO_NUMBER (NULL),          -- cost to clear
        DECODE(IT.TRANSACTION_TYPE,''INVOICE ADDITION'',''M'',
                                   ''INVOICE ADJUSTMENT'',''A'',
                                   ''INVOICE TRANSFER'',''T'',
                                   ''INVOICE REINSTATE'',''R'',NULL),
        bk.date_placed_in_service,
        bk.deprn_method_code,
        bk.life_in_months,
        bk.production_capacity,
        bk.adjusted_rate,
        cb.deprn_reserve_acct,
        ds.bonus_Rate,
        cb.category_id,  dh.location_id,
	     TO_NUMBER (NULL), --DD.YTD_DEPRN, Bug 7675486/9148511. For invoice lines it is null.
	     TO_NUMBER (NULL), --DD.DEPRN_RESERVE, Bug 7675486/9148511. For invoice lines it is null.
	     TH.TRANSACTION_HEADER_ID,'||
	     maj_select_statement ||','||
	     min_select_statement ||','||
	     spec_select_statement  ||' ,
        gad.asset_number
FROM
	PO_VENDORS			PO_VEND,
	FA_INVOICE_TRANSACTIONS		IT,
	FA_ASSET_INVOICES               AI_IN,
	FA_DEPRN_SUMMARY		DS,
   FA_ADDITIONS 			AD,
   GL_CODE_COMBINATIONS 		DHCC,
   FA_DISTRIBUTION_HISTORY 		DH,
   FA_LOOKUPS 			FALU,
   FA_CATEGORY_BOOKS 		CB,
   FA_ASSET_HISTORY 		AH,
	FA_BOOKS			BK,
   FA_TRANSACTION_HEADERS 		TH,
   FA_DEPRN_PERIODS                DP1,
   FA_DEPRN_PERIODS		DP,
	FA_DEPRN_DETAIL			DD,
   FA_CATEGORIES                   CAT,
   FA_ADDITIONS_B                  GAD
WHERE	' || where_clause1 || '
UNION ALL
SELECT  DISTINCT
        DECODE(TH.MASS_REFERENCE_ID,NULL,''Manual Addition'',''Mass Addition''),
        dhcc.code_combination_id,
        FALU.MEANING,
        AH.ASSET_TYPE   ,
        DECODE(AH.ASSET_TYPE, ''CIP'', CB.CIP_COST_ACCT,
                CB.ASSET_COST_ACCT),
        AD.ASSET_NUMBER,
        AD.description,
        ad.tag_number, ad.serial_number, ad.inventorial,
	ad.asset_key_ccid,
        PO_VEND.segment1,
        AI_IN.INVOICE_NUMBER    ,
        AI_IN.AP_DISTRIBUTION_LINE_NUMBER,
        AI_IN.DESCRIPTION       ,
        AI_IN.PAYABLES_COST,
        DH.UNITS_ASSIGNED/AH.UNITS * AI_IN.FIXED_ASSETS_COST,
        TO_NUMBER (NULL),          -- cost to clear
        DECODE(IT.TRANSACTION_TYPE,''INVOICE ADDITION'',''M'',
                                   ''INVOICE ADJUSTMENT'',''A'',
                                   ''INVOICE TRANSFER'',''T'',
                                   ''INVOICE REINSTATE'',''R'',NULL),
        bk.date_placed_in_service,
        bk.deprn_method_code,
        bk.life_in_months,
        bk.production_capacity,
        bk.adjusted_rate,
        cb.deprn_reserve_acct,
        ds.bonus_Rate,
        cb.category_id,  dh.location_id,
        DD.YTD_DEPRN,
	     DD.DEPRN_RESERVE,
        TH.TRANSACTION_HEADER_ID,'||
        maj_select_statement ||','||
        min_select_statement ||','||
        spec_select_statement  ||' ,
        gad.asset_number
FROM
      PO_VENDORS                      PO_VEND,
      FA_INVOICE_TRANSACTIONS         IT,
      FA_ASSET_INVOICES               AI_IN,
     	FA_DISTRIBUTION_HISTORY 		DH,
     	GL_CODE_COMBINATIONS 		DHCC,
	   fa_deprn_summary		ds,
     	FA_TRANSACTION_HEADERS 		THDIS,
	   fa_books			bk,
     	FA_ADDITIONS 			AD,
     	FA_CATEGORY_BOOKS 		CB,
     	FA_LOOKUPS 			FALU,
     	FA_ASSET_HISTORY 		AH,
	   FA_TRANSACTION_HEADERS		THADD,
	   FA_DEPRN_PERIODS		DP2,
      FA_DEPRN_PERIODS                DP1,
	   FA_DEPRN_PERIODS		DP,
     	FA_TRANSACTION_HEADERS 		TH,
	   fa_deprn_detail			dd,
      fa_categories                   cat,
      fa_additions_b                  GAD
WHERE  ' || where_clause2 || '
UNION ALL
SELECT  DISTINCT
        DECODE(TH.MASS_REFERENCE_ID,NULL,''Manual Addition'',''Mass Addition''),
        dhcc.code_combination_id,
        FALU.MEANING,
        AH.ASSET_TYPE   ,
        DECODE(AH.ASSET_TYPE, ''CIP'', CB.CIP_COST_ACCT,
                CB.ASSET_COST_ACCT),
        AD.ASSET_NUMBER,
        AD.description,
        ad.tag_number, ad.serial_number, ad.inventorial,
	ad.asset_key_ccid,
        NULL,                      -- vendor number
        NULL,                      -- invoice number
        TO_NUMBER(NULL),           -- line number
        NULL,                      -- invoice description
        TO_NUMBER(NULL),           -- invoice original cost
        TO_NUMBER(NULL),           -- invoice cost
        NVL(DD.ADDITION_COST_TO_CLEAR, 0),
        NULL,                      -- invoice flag
        bk.date_placed_in_service,
        bk.deprn_method_code,
        bk.life_in_months,
        bk.production_capacity,
        bk.adjusted_rate,
        cb.deprn_reserve_acct,
        ds.bonus_Rate,
        cb.category_id,  dh.location_id,
	     DD.YTD_DEPRN,
	     DD.DEPRN_RESERVE,
	     TH.TRANSACTION_HEADER_ID,'||
	     maj_select_statement ||','||
	     min_select_statement ||','||
        spec_select_statement  ||' ,
        gad.asset_number
FROM
        FA_DEPRN_SUMMARY                DS,
        FA_ADDITIONS                    AD,
        GL_CODE_COMBINATIONS            DHCC,
        FA_DISTRIBUTION_HISTORY                 DH,
        FA_LOOKUPS                      FALU,
        FA_CATEGORY_BOOKS               CB,
        FA_ASSET_HISTORY                AH,
        FA_BOOKS                        BK,
        FA_TRANSACTION_HEADERS          TH,
        FA_DEPRN_PERIODS                DP,
        FA_DEPRN_DETAIL                 DD,
        fa_categories                   cat,
        fa_additions_b                  GAD
WHERE   ' || where_clause3 || '
UNION ALL
SELECT  DISTINCT
        DECODE(TH.MASS_REFERENCE_ID,NULL,''Manual Addition'',''Mass Addition''),
        dhcc.code_combination_id,
        FALU.MEANING,
        AH.ASSET_TYPE   ,
        DECODE(AH.ASSET_TYPE, ''CIP'', CB.CIP_COST_ACCT,
                CB.ASSET_COST_ACCT),
        AD.ASSET_NUMBER,
        AD.description,
        ad.tag_number, ad.serial_number, ad.inventorial,
	ad.asset_key_ccid,
        NULL,                      -- vendor number
        NULL,                      -- invoice number
        TO_NUMBER(NULL),           -- line number
        NULL,                      -- invoice description
        TO_NUMBER(NULL),           -- invoice original cost
        TO_NUMBER(NULL),           -- invoice cost
        bk.cost,
        NULL,                      -- invoice flag
	bk.date_placed_in_service,
        bk.deprn_method_code,
        bk.life_in_months,
        bk.production_capacity,
        bk.adjusted_rate,
        cb.deprn_reserve_acct,
        ds.bonus_Rate,
        cb.category_id,  dh.location_id,
	     DD.YTD_DEPRN,
	     DD.DEPRN_RESERVE,
	     TH.TRANSACTION_HEADER_ID,'||
	     maj_select_statement ||','||
	     min_select_statement ||','||
        spec_select_statement  ||' ,
        gad.asset_number
FROM
        FA_DISTRIBUTION_HISTORY                 DH,
        GL_CODE_COMBINATIONS            DHCC,
        fa_deprn_summary                ds,
        FA_TRANSACTION_HEADERS          THDIS,
        fa_books                        bk,
        FA_ADDITIONS                    AD,
        FA_CATEGORY_BOOKS               CB,
        FA_LOOKUPS                      FALU,
        FA_ASSET_HISTORY                AH,
        FA_DEPRN_PERIODS                DP,
        FA_TRANSACTION_HEADERS          TH,
        fa_deprn_detail                 dd,
        fa_categories                   cat,
        FA_ADDITIONS_B                  GAD
WHERE   ' || where_clause4 ;

     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || 'select_statement:='|| select_statement);
     END IF;

/* BUG# 2939771
open additions for select_statement;
-- USING  where_clause1,where_clause2,where_clause3,where_clause4;
*/
open additions for select_statement using
          h_book, -- where_clause1
          h_dist_source_book,
          h_book,
          h_book,
          h_period1_pc,
          h_period2_pc,
          h_book,
          h_period1_pc,
          h_period2_pc,
          h_book,
          h_book,
          from_maj_cat, -- l_param_where
          from_maj_cat,
          to_maj_cat,
          to_maj_cat,
          from_min_cat,
          from_min_cat,
          to_min_cat,
          to_min_cat,
          from_cat_seg_val,
          from_cat_seg_val,
          to_cat_seg_val,
          to_cat_seg_val,
          from_cc,
          from_cc,
          to_cc,
          to_cc,
          from_asset_num,
          from_asset_num,
          to_asset_num,
          to_asset_num,
          h_book, -- where_clause2
          h_dist_source_book,
          h_book,
          h_book,
          h_period1_pc,
          h_period2_pc,
          h_book,
          h_period1_pc,
          h_period2_pc,
          h_book,
          h_book,
          from_maj_cat, -- l_param_where
          from_maj_cat,
          to_maj_cat,
          to_maj_cat,
          from_min_cat,
          from_min_cat,
          to_min_cat,
          to_min_cat,
          from_cat_seg_val,
          from_cat_seg_val,
          to_cat_seg_val,
          to_cat_seg_val,
          from_cc,
          from_cc,
          to_cc,
          to_cc,
          from_asset_num,
          from_asset_num,
          to_asset_num,
          to_asset_num,
          h_book, -- where_clause3
          h_dist_source_book,
          h_book,
          h_book,
          h_period1_pc,
          h_period2_pc,
          h_book,
          h_book,
          from_maj_cat, -- l_param_where
          from_maj_cat,
          to_maj_cat,
          to_maj_cat,
          from_min_cat,
          from_min_cat,
          to_min_cat,
          to_min_cat,
          from_cat_seg_val,
          from_cat_seg_val,
          to_cat_seg_val,
          to_cat_seg_val,
          from_cc,
          from_cc,
          to_cc,
          to_cc,
          from_asset_num,
          from_asset_num,
          to_asset_num,
          to_asset_num,
          h_book, -- where_clause4
          h_dist_source_book,
          h_book,
          h_period1_pc,
          h_period1_pc,
          h_period2_pc,
          h_book,
          h_book,
          h_period1_pc, -- Bug 5222214
          h_period2_pc, -- Bug 5222214
          h_book,
          from_maj_cat, -- l_param_where
          from_maj_cat,
          to_maj_cat,
          to_maj_cat,
          from_min_cat,
          from_min_cat,
          to_min_cat,
          to_min_cat,
          from_cat_seg_val,
          from_cat_seg_val,
          to_cat_seg_val,
          to_cat_seg_val,
          from_cc,
          from_cc,
          to_cc,
          to_cc,
          from_asset_num,
          from_asset_num,
          to_asset_num,
          to_asset_num;


     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || 'Before Loop');
     END IF;

  loop

    h_mesg_name := 'FA_DEPRN_SQL_FCUR';

    fetch additions into
  	h_source,
  	h_ccid,
  	h_asset_type_mean,
	h_asset_type,
	h_cost_acct,
	h_asset_number,
  	h_description,
	h_tag_number, h_serial_number, h_inventorial,
	h_asset_key_ccid,
  	h_vendor_number,
  	h_invoice_number,
  	h_line_number,
  	h_invoice_descr,
  	h_invoice_orig_cost,
  	h_invoice_cost,
  	h_cost_to_clear,
  	h_invoice_flag,
  	h_dpis,
  	h_method,
  	h_life_months,
  	h_prod_capacity,
  	h_adjusted_Rate,
  	h_reserve_acct,
  	h_bonus_rate,
	h_category_id,
	h_location_id,
	h_ytd_deprn,
	h_deprn_reserve,
	h_tran_header_id,
	h_maj_cat,
	h_min_cat,
        h_specified_cat,
        h_group_asset_number;

  if (additions%NOTFOUND) then exit; end if;
  ctr := ctr + 1;

  mesg := 'concat_account';

	h_mesg_name := 'FA_RX_CONCAT_SEGS';
        h_flex_error := 'GL#';
	h_ccid_error := h_ccid;

        fa_rx_shared_pkg.concat_acct (
           struct_id => h_acct_flex_struct,
           ccid => h_ccid,
           concat_string => h_concat_acct,
           segarray => h_acct_segs);

  mesg := 'concat_category';

        h_flex_error := 'CAT#';
        h_ccid_error := h_category_id;

        fa_rx_shared_pkg.concat_category (
           struct_id => h_cat_flex_struct,
           ccid => h_category_id,
           concat_string => h_concat_cat,
           segarray => h_cat_segs);

  mesg := 'concat_location';

        h_flex_error := 'LOC#';
        h_ccid_error := h_location_id;

        fa_rx_shared_pkg.concat_location (
           struct_id => h_loc_flex_struct,
           ccid => h_location_id,
           concat_string => h_concat_loc,
           segarray => h_loc_segs);



        if h_asset_key_ccid is not null then
           mesg := 'concat_asset_key';

           h_flex_error := 'KEY#';
           h_ccid_error := h_asset_key_ccid;

           fa_rx_shared_pkg.concat_asset_key (
              struct_id => h_assetkey_flex_structure,
              ccid => h_asset_key_ccid,
              concat_string => h_concat_key,
              segarray => h_key_segs);
	else
	    h_concat_key := '';

	end if;

	select decode(h_life_months, null, null,
		to_char(floor(h_life_months/12)) || '.' ||
			to_char(mod(h_life_months,12)))
	into h_life_year_month
	from dual;

        h_life_year_month_num := fnd_number.canonical_to_number(h_life_year_month);

/*   h_account_desc :=
     fa_rx_flex_pkg.get_description(
	 p_application_id => 101,
	 p_id_flex_code   => 'GL#',
	 p_id_flex_num    => h_chart_of_accounts_id,
	 p_qualifier      => 'GL_ACCOUNT',
         p_data		  => h_acct_segs(h_acct_seg));
*/

   h_account_desc :=
     fa_rx_flex_pkg.get_description(
	 p_application_id => 101,
	 p_id_flex_code   => 'GL#',
	 p_id_flex_num    => h_chart_of_accounts_id,
	 p_qualifier      => 'GL_ACCOUNT',
         p_data		  => h_cost_acct);

   h_cost_center_desc :=
     fa_rx_flex_pkg.get_description(
	 p_application_id => 101,
	 p_id_flex_code   => 'GL#',
	 p_id_flex_num    => h_chart_of_accounts_id,
	 p_qualifier      => 'FA_COST_CTR',
         p_data		  => h_acct_segs(h_cost_seg));


  IF (g_print_debug) THEN
  	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || '** assetkey_flex_struct:' || h_assetkey_flex_structure);
  	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || '** category_id:' ||  h_category_id);
  	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || '** specified_cat:' || h_cat_seg_num);
  END IF;

/*
   h_maj_cat :=
     fa_rx_flex_pkg.get_value(
         p_application_id => 140,
         p_id_flex_code   => 'CAT#',
         p_id_flex_num    => h_assetkey_flex_structure,
         p_qualifier      => 'BASED_CATEGORY',
         p_ccid           => h_category_id);
*/
   begin
   h_maj_cat_desc :=
     fa_rx_flex_pkg.get_description(
	 p_application_id => 140,
	 p_id_flex_code   => 'CAT#',
	 p_id_flex_num    => h_assetkey_flex_structure,
	 p_qualifier      => 'BASED_CATEGORY',
         p_data		  => h_maj_cat);
   exception
      when others then
        h_maj_cat_desc := null;
   end;

/*
    BEGIN
    h_min_cat :=
     fa_rx_flex_pkg.get_value(
         p_application_id => 140,
         p_id_flex_code   => 'CAT#',
         p_id_flex_num    => h_assetkey_flex_structure,
         p_qualifier      => 'MINOR_CATEGORY',
         p_ccid           => h_category_id);
    EXCEPTION
       WHEN OTHERS THEN
	 h_min_cat := null;
    end;
*/
    begin
    h_min_cat_desc :=
     fa_rx_flex_pkg.get_description(
	 p_application_id => 140,
	 p_id_flex_code   => 'CAT#',
	 p_id_flex_num    => h_assetkey_flex_structure,
	 p_qualifier      => 'MINOR_CATEGORY',
         p_data		  => h_min_cat);
    EXCEPTION
       WHEN OTHERS THEN
         h_min_cat_desc := null;
    end;
/*
    BEGIN
    h_specified_cat :=
     fa_rx_flex_pkg.get_value(
         p_application_id => 140,
         p_id_flex_code   => 'CAT#',
         p_id_flex_num    => h_assetkey_flex_structure,
         p_qualifier      => h_cat_seg_num,
         p_ccid           => h_category_id);
    EXCEPTION
       WHEN OTHERS THEN
	 h_specified_cat := null;
    end;
*/
    begin
    h_specified_cat_desc :=
     fa_rx_flex_pkg.get_description(
	 p_application_id => 140,
	 p_id_flex_code   => 'CAT#',
	 p_id_flex_num    => h_assetkey_flex_structure,
	 p_qualifier      => h_cat_seg_num,
         p_data		  => h_specified_cat);
    EXCEPTION
       WHEN OTHERS THEN
         h_specified_cat_desc := null;
    end;

    h_mesg_name := 'FA_SHARED_INSERT_FAILED';

    insert into fa_addition_rep_itf (
	request_id, source, company, cost_Center, expense_acct,
	asset_type, asset_number,
	tag_number, serial_number, inventorial, description, vendor_number,
	invoice_number, line_number, invoice_descr,
	invoice_orig_cost, invoice_cost, cost_to_clear,
	invoice_flag, date_placed_in_service, method,
	life_year_month, prod_capacity, adjusted_rate,
	reserve_acct, cost_acct, category, location,
	last_update_date, creation_date, last_updated_by,
	last_update_login, created_by,
	reserve, set_of_books_id, functional_currency_code,organization_name,
	book_type_code, period_name, period_name_to,
	account_description, cost_center_description, ytd_depreciation,
	transaction_header_id, major_category, major_category_desc,
	minor_category, minor_category_desc,specified_category_seg,
        specified_cat_seg_desc, group_asset_number, asset_key ) values (
	request_id, h_source, h_acct_segs(h_bal_seg),
	h_acct_segs(h_cost_seg), h_acct_segs(h_acct_seg),
	h_asset_type_mean, h_asset_number,
	h_tag_number, h_serial_number, h_inventorial, h_description,
	h_vendor_number, h_invoice_number, h_line_number,
	h_invoice_descr, h_invoice_orig_cost, h_invoice_cost,
	h_cost_to_clear, h_invoice_flag, h_dpis,
	h_method, h_life_year_month_num, h_prod_capacity,
	h_adjusted_rate, h_reserve_acct, h_cost_acct,
	h_concat_cat, h_concat_loc, sysdate, sysdate,
	user_id, h_login_id, user_id,
	h_deprn_reserve, h_set_of_books_id, h_currency_code,h_organization_name,
	h_book, h_period_name, h_period_name_to, h_account_desc,
	h_cost_center_desc, h_ytd_deprn, h_tran_header_id,
	h_maj_cat, h_maj_cat_desc, h_min_cat, h_min_cat_desc, h_specified_cat,
        h_specified_cat_desc, h_group_asset_number, h_concat_key);


  end loop;

  h_mesg_name := 'FA_DEPRN_SQL_CCUR';

  close additions;

     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('ADD_BY_PERIOD: ' || 'loop counter:' || ctr);
     END IF;

exception when others then
    fa_Rx_conc_mesg_pkg.log('Error occurred');
    fa_Rx_conc_mesg_pkg.log(h_mesg_name);
  if SQLCODE <> 0 then
    fa_Rx_conc_mesg_pkg.log(SQLERRM);
  end if;
  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name = 'FA_SHARED_INSERT_FAIL' then
	fnd_message.set_token('TABLE','FA_ADDITION_REP_ITF',FALSE);
  end if;
  if h_mesg_name = 'FA_RX_CONCAT_SEGS' then
        fnd_message.set_token('CCID',to_char(h_ccid_error),FALSE);
        fnd_message.set_token('FLEX_CODE',h_flex_error,FALSE);
  end if;

  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  retcode := 2;

end add_by_period;


procedure add_by_date (
   book		in	varchar2,
   begin_dpis 	in	date,
   end_dpis	in	date,
   request_id   in	number,
   user_id	in	number,
   retcode out nocopy number,
   errbuf out nocopy varchar2) is

  mesg			varchar2(200);
  ctr			number;

  h_book		varchar2(15);
  h_request_id		number;
  h_login_id		number;

  h_bonus_rate		number;
  h_reserve_acct	varchar2(25);
  h_adjusted_Rate	number;
  h_prod_capacity	number;
  h_life_months		number;
  h_life_year_month	varchar2(10);
  h_life_year_month_num number;
  h_method		varchar2(15);
  h_dpis		date;
  h_invoice_flag	varchar2(1);
  h_cost_to_clear	number;
  h_invoice_cost	number;
  h_invoice_orig_cost	number;
  h_invoice_descr	varchar2(80);
  h_line_number		number;
  h_invoice_number	varchar2(50);
  h_tag_number		varchar2(15);
  h_serial_number	varchar2(35);
  h_inventorial		varchar2(3);
  h_vendor_number	varchar2(30);
  h_description		varchar2(80);
  h_asset_number	varchar2(15);
  h_asset_type		varchar2(15);
  h_cost_acct		varchar2(25);
  h_asset_type_mean	varchar2(80);
  h_ccid		number;
  h_source		varchar2(20);

  h_category_id		number;
  h_location_id		number;

  h_concat_acct		varchar2(200);
  h_concat_cat		varchar2(200);
  h_concat_loc		varchar2(200);
  h_acct_segs		fa_rx_shared_pkg.Seg_Array;
  h_cat_segs		fa_rx_shared_pkg.Seg_Array;
  h_loc_segs		fa_rx_shared_pkg.Seg_Array;

  h_acct_seg		number;
  h_cost_seg		number;
  h_bal_seg		number;

  h_dist_source_book 	varchar2(15);

  h_acct_flex_struct	number;
  h_cat_flex_struct	number;
  h_loc_flex_struct	number;

  h_count		number;

  h_mesg_name		varchar2(50);
  h_mesg_str		varchar2(2000);
  h_flex_error		varchar2(5);
  h_ccid_error		number;

cursor additions is
  SELECT	DECODE(TH.MASS_REFERENCE_ID,NULL,'Manual Addition','Mass Addition'),   -- source
	dh.code_combination_id,   -- expense account
	FALU.MEANING,	-- translated asset type
	AH.ASSET_TYPE,
	DECODE(AH.ASSET_TYPE, 'CIP', CB.CIP_COST_ACCT,
		CB.ASSET_COST_ACCT),
	AD.ASSET_NUMBER,
	AD.description,
	ad.tag_number, ad.serial_number, ad.inventorial,
	NULL,      -- vendor number
 	NULL,      -- invoice number
	TO_NUMBER(NULL),	-- line number
	NULL,  -- invoice description
	TO_NUMBER(NULL)	,   -- invoice original cost
	TO_NUMBER(NULL),    -- invoice cost

---bug fix 4275433
	decode( (decode(adj.debit_credit_flag,'DR',1,-1) * nvl(adj.adjustment_amount,0)),0,dd.addition_cost_to_clear,(decode(adj.debit_credit_flag,'DR',1,-1) * nvl(adj.adjustment_amount,0)))  ,

--	NVL(DD.ADDITION_COST_TO_CLEAR, 0), -- cost-to-clear
	NULL,   -- flag
	bk.date_placed_in_service,
	bk.deprn_method_code,
	bk.life_in_months,
	bk.production_capacity,
	bk.adjusted_rate,
	cb.deprn_reserve_acct,
	ds.bonus_Rate,
	cb.category_id,  dh.location_id
FROM
     	FA_DISTRIBUTION_HISTORY 		DH,
     	FA_ASSET_HISTORY 		AH,
     	FA_CATEGORY_BOOKS 		CB,
     	FA_LOOKUPS 			FALU,
     	FA_ADDITIONS 			AD,
     	--GL_CODE_COMBINATIONS 		DHCC,
	FA_BOOKS			BK,
	FA_DEPRN_SUMMARY		DS,
    	FA_TRANSACTION_HEADERS 		TH,
	FA_DEPRN_DETAIL			DD,
	fa_adjustments adj

WHERE
	bk.book_type_code		= th.book_type_code  AND
	bk.asset_id			= th.asset_id AND
	bk.transaction_header_id_in	= th.transaction_header_id AND
	bk.date_placed_in_service  >= begin_dpis	AND
	bk.date_placed_in_service  <=  end_dpis
AND
	ds.book_type_code		= dd.book_type_code  AND
	ds.asset_id			= dd.asset_id  AND
	ds.period_counter		= dd.period_counter
AND
	th.asset_id			= dd.asset_id AND
	th.transaction_type_code	= 'ADDITION' AND
-- bug fix 3807732
         th.book_type_code               = h_book
AND
	DH.BOOK_TYPE_CODE 		= h_dist_source_book	AND
	DH.ASSET_ID 			= DD.ASSET_ID			AND
	--DHCC.CODE_COMBINATION_ID	=  DH.CODE_COMBINATION_ID
--AND
	DD.BOOK_TYPE_CODE		=  h_book 			AND
	DD.DEPRN_SOURCE_CODE		=  'B'				AND
	DD.DISTRIBUTION_ID		=  DH.DISTRIBUTION_ID
AND
	ADJ.book_type_code(+) 	= h_book		AND
	ADJ.asset_id(+)		= dh.ASSET_ID		AND
	ADJ.source_type_code(+) 	like '%ADDITION'	AND
        adj.adjustment_type(+) like 'COST' and
	ADJ.distribution_id(+)	= DH.DISTRIBUTION_ID
AND
	CB.CATEGORY_ID			=  AH.CATEGORY_ID		AND
	CB.BOOK_TYPE_CODE		=  h_book
AND
	AD.ASSET_ID			=  DD.ASSET_ID
AND
	AH.ASSET_ID			=  AD.ASSET_ID			AND
	AH.DATE_EFFECTIVE	       <=  th.date_effective	AND
	NVL(AH.DATE_INEFFECTIVE,SYSDATE+1) >  th.date_effective
AND
	AH.ASSET_TYPE			=  FALU.LOOKUP_CODE	AND
	FALU.LOOKUP_TYPE		= 'ASSET TYPE'
--GROUP BY
--	DECODE(TH.MASS_REFERENCE_ID,NULL,'Manual Addition','Mass Addition'),
--	dh.code_combination_id,
--	FALU.MEANING,
--	AH.ASSET_TYPE,
--	DECODE(AH.ASSET_TYPE, 'CIP', CB.CIP_COST_ACCT,
--		CB.ASSET_COST_ACCT),
--	AD.ASSET_NUMBER,
--	AD.description,
--	bk.date_placed_in_service,
--	bk.deprn_method_code,
--	bk.life_in_months,
--	bk.production_capacity,
--	bk.adjusted_rate,
--	cb.deprn_reserve_acct,
--	ds.bonus_Rate,
--	cb.category_id,  dh.location_id
UNION ALL
SELECT	DECODE(TH.MASS_REFERENCE_ID,NULL,'Manual Addition','Mass Addition'),
	dh.code_combination_id,
	FALU.MEANING,
	AH.ASSET_TYPE,
	DECODE(AH.ASSET_TYPE, 'CIP', CB.CIP_COST_ACCT,
		CB.ASSET_COST_ACCT),
	AD.ASSET_NUMBER,
	AD.description,
	ad.tag_number, ad.serial_number, ad.inventorial,
	NULL,
 	NULL,
	TO_NUMBER(NULL),
	NULL,
	TO_NUMBER(NULL),
	TO_NUMBER(NULL),
	DECODE(ADJ.DEBIT_CREDIT_FLAG, 'DR',1,-1) *
		ADJ.ADJUSTMENT_AMOUNT,
	NULL,
	bk.date_placed_in_service,
	bk.deprn_method_code,
	bk.life_in_months,
	bk.production_capacity,
	bk.adjusted_rate,
	cb.deprn_reserve_acct,
	ds.bonus_Rate,
	cb.category_id,  dh.location_id
FROM
	fa_books bk,
	fa_deprn_summary ds,
	FA_TRANSACTION_HEADERS TH,
	FA_TRANSACTION_HEADERS	THDIS,
	FA_ADDITIONS           	AD,
	FA_ASSET_HISTORY	AH,
	FA_CATEGORY_BOOKS	CB,
	FA_DISTRIBUTION_HISTORY 	DH,
	--GL_CODE_COMBINATIONS	DHCC,
	--GL_CODE_COMBINATIONS	AJCC,
	FA_LOOKUPS		FALU,
	FA_ADJUSTMENTS		ADJ,
	fa_deprn_periods	dp
WHERE
	DP.BOOK_TYPE_CODE		=  h_book    AND
	DP.period_open_date		>= bk.date_effective --AND
--	dp.period_close_date		<= nvl(bk.date_ineffective,sysdate)
AND
	ds.asset_id			= bk.asset_id  and
	ds.book_type_code		= bk.book_type_code  and
-- bugfix 3807732
        ds.deprn_source_code            = 'BOOKS' and
	(ds.period_counter + 1)		= dp.period_counter
AND
	bk.asset_id			= th.asset_id  and
	bk.book_type_code		= th.book_type_code and
	bk.transaction_header_id_in	= th.transaction_header_id  AND
	bk.date_placed_in_service	>= begin_dpis AND
	bk.date_placed_in_service	<= end_dpis
AND
	TH.BOOK_TYPE_CODE		=  h_book	AND
	TH.TRANSACTION_TYPE_CODE 	= 'ADDITION'
AND

	THDIS.TRANSACTION_TYPE_CODE	= 'TRANSFER IN'		AND
	THDIS.BOOK_TYPE_CODE		= h_book		AND
	THDIS.ASSET_ID			= TH.ASSET_ID		AND
	THDIS.DATE_EFFECTIVE 		< th.date_effective
AND
	ADJ.BOOK_TYPE_CODE		= h_book			AND
	ADJ.ASSET_ID 			= TH.ASSET_ID			AND
	ADJ.SOURCE_TYPE_CODE 		= 'ADDITION'			AND
	ADJ.ADJUSTMENT_TYPE 		= 'COST'				AND
	ADJ.PERIOD_COUNTER_CREATED 	= DP.PERIOD_COUNTER		AND
	--ADJ.CODE_COMBINATION_ID		= AJCC.CODE_COMBINATION_ID
--AND
	DH.BOOK_TYPE_CODE		= h_book			AND
	DH.ASSET_ID			= TH.ASSET_ID			AND
	DH.DISTRIBUTION_ID		= ADJ.DISTRIBUTION_ID		AND
	--DH.CODE_COMBINATION_ID		= DHCC.CODE_COMBINATION_ID
--AND
	CB.CATEGORY_ID			=  AH.CATEGORY_ID		AND
	CB.BOOK_TYPE_CODE		=  h_book
AND
	AD.ASSET_ID			=  TH.ASSET_ID
AND
	AH.ASSET_ID			=  TH.ASSET_ID			AND
	AH.DATE_EFFECTIVE	       <=  TH.DATE_EFFECTIVE	AND
	NVL(AH.DATE_INEFFECTIVE,SYSDATE+1) >  TH.DATE_EFFECTIVE
AND
	AH.ASSET_TYPE			=  FALU.LOOKUP_CODE	AND
	FALU.LOOKUP_TYPE		= 'ASSET TYPE'
--GROUP BY
--	DECODE(TH.MASS_REFERENCE_ID,NULL,'Manual Addition','Mass Addition'),
--	dh.code_combination_id,
--	FALU.MEANING,
--	AH.ASSET_TYPE,
--	DECODE(AH.ASSET_TYPE, 'CIP', CB.CIP_COST_ACCT,
--		CB.ASSET_COST_ACCT),
--	AD.ASSET_NUMBER,
--	AD.description,
--	bk.date_placed_in_service,
--	bk.deprn_method_code,
--	bk.life_in_months,
--	bk.production_capacity,
--	bk.adjusted_rate,
--	cb.deprn_reserve_acct,
--	ds.bonus_Rate,
--	cb.category_id,  dh.location_id
UNION ALL
SELECT	DECODE(TH.MASS_REFERENCE_ID,NULL,'Manual Addition','Mass Addition'),
	dh.code_combination_id,
	FALU.MEANING,
	AH.ASSET_TYPE,
	DECODE(AH.ASSET_TYPE, 'CIP', CB.CIP_COST_ACCT,
		CB.ASSET_COST_ACCT),
	AD.ASSET_NUMBER,
	AD.description,
	ad.tag_number, ad.serial_number, ad.inventorial,
	PO_VEND.segment1,
 	AI_IN.INVOICE_NUMBER,
        AI_IN.AP_DISTRIBUTION_LINE_NUMBER,
	AI_IN.DESCRIPTION,
	AI_IN.PAYABLES_COST,
	DH.UNITS_ASSIGNED/AH.UNITS * AI_IN.FIXED_ASSETS_COST,
	TO_NUMBER(NULL),
	DECODE(IT.TRANSACTION_TYPE,'INVOICE ADDITION','M',
				   'INVOICE ADJUSTMENT','A',
				   'INVOICE TRANSFER','T',
				   'INVOICE REINSTATE','R',NULL),
	bk.date_placed_in_service,
	bk.deprn_method_code,
	bk.life_in_months,
	bk.production_capacity,
	bk.adjusted_rate,
	cb.deprn_reserve_acct,
	ds.bonus_Rate,
	cb.category_id,  dh.location_id
FROM
	FA_ASSET_INVOICES 		AI_IN,
     	FA_INVOICE_TRANSACTIONS    	IT,
	FA_BOOKS			BK,
	FA_DEPRN_SUMMARY		DS,
     	FA_TRANSACTION_HEADERS 		TH,
     	FA_DISTRIBUTION_HISTORY 		DH,
     	FA_ASSET_HISTORY 		AH,
     	FA_CATEGORY_BOOKS 		CB,
     	FA_LOOKUPS 			FALU,
     	PO_VENDORS 			PO_VEND,
     	FA_ADDITIONS 			AD,
     	--GL_CODE_COMBINATIONS 		DHCC,
	FA_DEPRN_DETAIL			DD
WHERE
	bk.book_type_code		= th.book_type_code  AND
	bk.asset_id			= th.asset_id AND
	bk.date_placed_in_service	>= begin_dpis AND
	bk.date_placed_in_service	<= end_dpis AND
	bk.transaction_header_id_in	= th.transaction_header_id
AND
	th.asset_id			= dd.asset_id  AND
	th.book_type_code		= h_book  AND
	th.transaction_type_code	= 'ADDITION'
AND
	ds.book_type_code		= dd.book_type_code  AND
	ds.asset_id			= dd.asset_id  AND
	ds.period_counter		= dd.period_counter
AND
	DH.BOOK_TYPE_CODE 		= h_dist_source_book	AND
	DH.ASSET_ID 			= DD.ASSET_ID			AND
	--DHCC.CODE_COMBINATION_ID	=  DH.CODE_COMBINATION_ID
--AND
	DD.BOOK_TYPE_CODE		=  h_book 			AND
	DD.DEPRN_SOURCE_CODE		=  'B'				AND
	DD.DISTRIBUTION_ID		=  DH.DISTRIBUTION_ID
AND
	CB.CATEGORY_ID			=  AH.CATEGORY_ID		AND
	CB.BOOK_TYPE_CODE		=  h_book
AND
	AD.ASSET_ID			=  DD.ASSET_ID
AND
	AH.ASSET_ID			=  AD.ASSET_ID			AND
	AH.DATE_EFFECTIVE	       <=  th.date_effective AND
	NVL(AH.DATE_INEFFECTIVE,SYSDATE+1) >  th.date_effective
AND
	AH.ASSET_TYPE			=  FALU.LOOKUP_CODE	AND
	FALU.LOOKUP_TYPE		= 'ASSET TYPE'
AND
	IT.INVOICE_TRANSACTION_ID = AI_IN.INVOICE_TRANSACTION_ID_IN
AND
	AI_IN.ASSET_ID = TH.ASSET_ID				AND
	AI_IN.DATE_EFFECTIVE <=  th.date_effective		AND
	NVL(AI_IN.DATE_INEFFECTIVE, SYSDATE+1) > th.date_effective	AND
	AI_IN.DELETED_FLAG = 'NO'
AND
	PO_VEND.VENDOR_ID(+) = AI_IN.PO_VENDOR_ID
--GROUP BY
--	DECODE(TH.MASS_REFERENCE_ID,NULL,'Manual Addition','Mass Addition'),
--	dh.code_combination_id,
--	FALU.MEANING,
--	AH.ASSET_TYPE,
--	DECODE(AH.ASSET_TYPE, 'CIP', CB.CIP_COST_ACCT,
--		CB.ASSET_COST_ACCT),
--	AD.ASSET_NUMBER,
--	AD.description,
--	PO_VEND.segment1,
--	AI_IN.INVOICE_NUMBER,
--	AI_IN.AP_DISTRIBUTION_LINE_NUMBER,
--	AI_IN.DESCRIPTION,
--	AI_IN.PAYABLES_COST ,
--	DECODE(IT.TRANSACTION_TYPE,'INVOICE ADDITION','M',
--				   'INVOICE ADJUSTMENT','A',
--				   'INVOICE TRANSFER','T',
--				   'INVOICE REINSTATE','R',NULL),
--	bk.date_placed_in_service,
--	bk.deprn_method_code,
--	bk.life_in_months,
--	bk.production_capacity,
--	bk.adjusted_rate,
--	cb.deprn_reserve_acct,
--	ds.bonus_Rate,
--	cb.category_id,  dh.location_id
UNION ALL
SELECT	DECODE(TH.MASS_REFERENCE_ID,NULL,'Manual Addition','Mass Addition'),
	dh.code_combination_id,
	FALU.MEANING,
	AH.ASSET_TYPE	,
	DECODE(AH.ASSET_TYPE, 'CIP', CB.CIP_COST_ACCT,
		CB.ASSET_COST_ACCT),
	AD.ASSET_NUMBER,
	AD.description,
	ad.tag_number, ad.serial_number, ad.inventorial,
	PO_VEND.segment1,
 	AI_IN.INVOICE_NUMBER	,
        AI_IN.AP_DISTRIBUTION_LINE_NUMBER,
	AI_IN.DESCRIPTION	,
	AI_IN.PAYABLES_COST,
	DH.UNITS_ASSIGNED/AH.UNITS * AI_IN.FIXED_ASSETS_COST,
	TO_NUMBER(NULL),
	DECODE(IT.TRANSACTION_TYPE,'INVOICE ADDITION','M',
				   'INVOICE ADJUSTMENT','A',
				   'INVOICE TRANSFER','T',
				   'INVOICE REINSTATE','R',NULL),
	bk.date_placed_in_service,
	bk.deprn_method_code,
	bk.life_in_months,
	bk.production_capacity,
	bk.adjusted_rate,
	cb.deprn_reserve_acct,
	ds.bonus_Rate,
	cb.category_id,  dh.location_id
FROM
	fa_books			bk,
	fa_deprn_summary		ds,
	FA_ASSET_INVOICES 		AI_IN,
     	FA_INVOICE_TRANSACTIONS    	IT,
     	FA_TRANSACTION_HEADERS 		THDIS,
     	FA_DISTRIBUTION_HISTORY 		DH,
     	FA_ASSET_HISTORY 		AH,
     	FA_CATEGORY_BOOKS 		CB,
     	FA_LOOKUPS 			FALU,
     	PO_VENDORS 			PO_VEND,
     	FA_ADDITIONS 			AD,
     	--GL_CODE_COMBINATIONS 		DHCC,
   	FA_TRANSACTION_HEADERS 		TH,
	FA_DEPRN_PERIODS		DP
WHERE
	DP.BOOK_TYPE_CODE		=  h_book    AND
	dp.period_open_date		>= bk.date_effective --AND
--	dp.period_close_date		<= nvl(bk.date_ineffective,sysdate)
AND
	ds.asset_id			= bk.asset_id  and
	ds.book_type_code		= bk.book_type_code  and
 -- bug fix 3807732
        ds.deprn_source_code            = 'BOOKS' and
	(ds.period_counter + 1)		= dp.period_counter
AND
	bk.asset_id			= th.asset_id  and
	bk.book_type_code		= th.book_type_code and
	bk.date_placed_in_service	>= begin_dpis AND
	bk.date_placed_in_service	<= end_dpis AND
	bk.transaction_header_id_in	= th.transaction_header_id
AND
	TH.BOOK_TYPE_CODE		=  h_book	AND
	TH.TRANSACTION_TYPE_CODE 	= 'ADDITION'
AND
	THDIS.TRANSACTION_TYPE_CODE	= 'TRANSFER IN'		AND
	THDIS.BOOK_TYPE_CODE		= h_book		AND
	THDIS.ASSET_ID			= TH.ASSET_ID		AND
	THDIS.DATE_EFFECTIVE 		< th.date_effective
AND
	DH.BOOK_TYPE_CODE		= h_book			AND
	DH.ASSET_ID			= TH.ASSET_ID			AND
	--DH.CODE_COMBINATION_ID		= DHCC.CODE_COMBINATION_ID	AND
	DH.DATE_EFFECTIVE		<= TH.DATE_EFFECTIVE 		AND
	NVL(DH.DATE_INEFFECTIVE, SYSDATE)	> TH.DATE_EFFECTIVE
AND
	CB.CATEGORY_ID			=  AH.CATEGORY_ID		AND
	CB.BOOK_TYPE_CODE		=  h_book
AND
	AD.ASSET_ID			=  TH.ASSET_ID
AND
	AH.ASSET_ID			=  TH.ASSET_ID			AND
	AH.DATE_EFFECTIVE	       <=  TH.DATE_EFFECTIVE	AND
	NVL(AH.DATE_INEFFECTIVE,SYSDATE+1) >  TH.DATE_EFFECTIVE
AND
	AH.ASSET_TYPE			=  FALU.LOOKUP_CODE	AND
	FALU.LOOKUP_TYPE		= 'ASSET TYPE'
AND
	IT.INVOICE_TRANSACTION_ID = AI_IN.INVOICE_TRANSACTION_ID_IN
AND
	AI_IN.ASSET_ID = TH.ASSET_ID				AND
	AI_IN.DATE_EFFECTIVE <=  th.date_effective  AND
	NVL(AI_IN.DATE_INEFFECTIVE, SYSDATE+1) > th.date_effective  AND
	AI_IN.DELETED_FLAG = 'NO'
AND
	PO_VEND.VENDOR_ID(+) = AI_IN.PO_VENDOR_ID;
--GROUP BY
--	DECODE(TH.MASS_REFERENCE_ID,NULL,'Manual Addition','Mass Addition'),
--	dh.code_combination_id,
--	FALU.MEANING,
--	AH.ASSET_TYPE,
--	DECODE(AH.ASSET_TYPE, 'CIP', CB.CIP_COST_ACCT,
--		CB.ASSET_COST_ACCT),
--	AD.ASSET_NUMBER,
--	AD.description,
--	PO_VEND.segment1,
--	AI_IN.INVOICE_NUMBER,
--	AI_IN.AP_DISTRIBUTION_LINE_NUMBER,
--	AI_IN.DESCRIPTION,
--	AI_IN.PAYABLES_COST ,
--	DECODE(IT.TRANSACTION_TYPE,'INVOICE ADDITION','M',
--				   'INVOICE ADJUSTMENT','A',
--				   'INVOICE TRANSFER','T',
--				   'INVOICE REINSTATE','R',NULL),
--	bk.date_placed_in_service,
--	bk.deprn_method_code,
--	bk.life_in_months,
--	bk.production_capacity,
--	bk.adjusted_rate,
--	cb.deprn_reserve_acct,
--	ds.bonus_Rate,
--	cb.category_id,  dh.location_id;



begin

  h_book := book;
  ctr := 0;
  h_request_id := request_id;

  select fcr.last_update_login into h_login_id
  from fnd_concurrent_requests fcr
  where fcr.request_id = h_request_id;

  h_mesg_name := 'FA_REC_SQL_ACCT_FLEX';

  select nvl(distribution_source_book, book_type_code), accounting_flex_structure
  into h_dist_source_book, h_acct_flex_struct
  from fa_book_controls
  where book_type_code = h_book;

  h_mesg_name := 'FA_FA_LOOKUP_IN_SYSTEM_CTLS';

  select location_flex_structure, category_flex_structure
  into h_loc_flex_struct, h_cat_flex_struct
  from fa_system_controls;

   h_mesg_name := 'FA_RX_SEGNUMS';

   fa_rx_shared_pkg.GET_ACCT_SEGMENT_NUMBERS (
   BOOK         => h_book,
   BALANCING_SEGNUM     => h_bal_seg,
   ACCOUNT_SEGNUM       => h_acct_seg,
   CC_SEGNUM            => h_cost_seg,
   CALLING_FN           => 'ADD_BY_PERIOD');


  h_mesg_name := 'FA_DEPRN_SQL_DCUR';

  open additions;
  loop
    h_mesg_name := 'FA_DEPRN_SQL_FCUR';

    fetch additions into
  	h_source,
  	h_ccid,
  	h_asset_type_mean,
	h_asset_type,
	h_cost_acct,
	h_asset_number,
  	h_description,
	h_tag_number, h_serial_number, h_inventorial,
  	h_vendor_number,
  	h_invoice_number,
  	h_line_number,
  	h_invoice_descr,
  	h_invoice_orig_cost,
  	h_invoice_cost,
  	h_cost_to_clear,
  	h_invoice_flag,
  	h_dpis,
  	h_method,
  	h_life_months,
  	h_prod_capacity,
  	h_adjusted_Rate,
  	h_reserve_acct,
  	h_bonus_rate,
	h_category_id,
	h_location_id;


  if (additions%NOTFOUND) then exit; end if;
  ctr := ctr + 1;

  mesg := 'concat_account';

        h_mesg_name := 'FA_RX_CONCAT_SEGS';
        h_flex_error := 'GL#';
        h_ccid_error := h_ccid;

        fa_rx_shared_pkg.concat_acct (
           struct_id => h_acct_flex_struct,
           ccid => h_ccid,
           concat_string => h_concat_acct,
           segarray => h_acct_segs);

  mesg := 'concat_category';

        h_flex_error := 'CAT#';
        h_ccid_error := h_category_id;

        fa_rx_shared_pkg.concat_category (
           struct_id => h_cat_flex_struct,
           ccid => h_category_id,
           concat_string => h_concat_cat,
           segarray => h_cat_segs);

  mesg := 'concat_location';

        h_flex_error := 'LOC#';
        h_ccid_error := h_location_id;

        fa_rx_shared_pkg.concat_location (
           struct_id => h_loc_flex_struct,
           ccid => h_location_id,
           concat_string => h_concat_loc,
           segarray => h_loc_segs);

	select decode(h_life_months, null, null,
		to_char(floor(h_life_months/12)) || '.' ||
			to_char(mod(h_life_months,12)))
	into h_life_year_month
	from dual;

        h_life_year_month_num := fnd_number.canonical_to_number(h_life_year_month);

    h_mesg_name := 'FA_SHARED_INSERT_FAILED';

    insert into fa_addition_rep_itf (
	request_id, source, company, cost_Center, expense_acct,
	asset_type, asset_number, description,
	tag_number, serial_number, inventorial, vendor_number,
	invoice_number, line_number, invoice_descr,
	invoice_orig_cost, invoice_cost, cost_to_clear,
	invoice_flag, date_placed_in_service, method,
	life_year_month, prod_capacity, adjusted_rate,
	reserve_acct, cost_acct, category, location,
	last_update_date, creation_date, last_updated_by,
	last_update_login, created_by) values (
	request_id, h_source, h_acct_segs(h_bal_seg),
	h_acct_segs(h_cost_seg), h_acct_segs(h_acct_seg),
	h_asset_type_mean, h_asset_number, h_description,
	h_tag_number, h_serial_number, h_inventorial,
	h_vendor_number, h_invoice_number, h_line_number,
	h_invoice_descr, h_invoice_orig_cost, h_invoice_cost,
	h_cost_to_clear, h_invoice_flag, h_dpis,
	h_method, h_life_year_month_num, h_prod_capacity,
	h_adjusted_rate, h_reserve_acct, h_cost_acct,
	h_concat_cat, h_concat_loc, sysdate, sysdate,
	user_id, h_login_id, user_id);




  end loop;

  h_mesg_name := 'FA_DEPRN_SQL_CCUR';

  close additions;

exception when others then
  if SQLCODE <> 0 then
    fa_Rx_conc_mesg_pkg.log(SQLERRM);
  end if;
  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name = 'FA_SHARED_INSERT_FAIL' then
	fnd_message.set_token('TABLE','FA_ADDITION_REP_ITF',FALSE);
  end if;
  if h_mesg_name = 'FA_RX_CONCAT_SEGS' then
        fnd_message.set_token('CCID',to_char(h_ccid_error),FALSE);
        fnd_message.set_token('FLEX_CODE',h_flex_error,FALSE);
  end if;

  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  retcode := 2;

end add_by_date;



procedure add_by_resp (
   book		in	varchar2,
   period	in	varchar2,
   begin_cc	in	varchar2,
   end_cc	in	varchar2,
   request_id   in	number,
   user_id	in	number,
   retcode out nocopy number,
   errbuf out nocopy varchar2) is

  mesg			varchar2(200);
  ctr			number;

  h_book		varchar2(15);
  h_request_id		number;
  h_login_id		number;

  h_period1_pc		number;
  h_period2_pc		number;
  h_period1_pod		date;
  h_period2_pcd		date;

  h_bonus_rate		number;
  h_reserve_acct	varchar2(25);
  h_adjusted_Rate	number;
  h_prod_capacity	number;
  h_life_months		number;
  h_life_year_month	varchar2(10);
  h_life_year_month_num number;
  h_method		varchar2(15);
  h_dpis		date;
  h_invoice_flag	varchar2(1);
  h_cost_to_clear	number;
  h_invoice_cost	number;
  h_invoice_orig_cost	number;
  h_invoice_descr	varchar2(80);
  h_line_number		number;
  h_invoice_number	varchar2(50);
  h_vendor_number	varchar2(30);
  h_description		varchar2(80);
  h_tag_number		varchar2(15);
  h_serial_number	varchar2(35);
  h_inventorial		varchar2(3);
  h_asset_number	varchar2(15);
  h_asset_type		varchar2(15);
  h_cost_acct		varchar2(25);
  h_asset_type_mean	varchar2(80);
  h_ccid		number;
  h_source		varchar2(20);
  h_emp_name		varchar2(240);
  h_emp_number		varchar2(30);
  h_units		number;
  h_period_name		varchar2(15);
  h_reserve		number;

  h_category_id		number;
  h_location_id		number;

  h_concat_acct		varchar2(200);
  h_concat_cat		varchar2(200);
  h_concat_loc		varchar2(200);
  h_acct_segs		fa_rx_shared_pkg.Seg_Array;
  h_cat_segs		fa_rx_shared_pkg.Seg_Array;
  h_loc_segs		fa_rx_shared_pkg.Seg_Array;

  h_acct_seg		number;
  h_cost_seg		number;
  h_bal_seg		number;

  h_dist_source_book 	varchar2(15);

  h_acct_flex_struct	number;
  h_cat_flex_struct	number;
  h_loc_flex_struct	number;


  h_major_category 	varchar2(50);
  h_minor_category	varchar2(50);

  maj_select_column 	varchar2(50);
  min_select_column	varchar2(50);
  sql_stmt		varchar2(1000);

    TYPE cur IS ref cursor;
   category_segments 		cur;

  h_major_cat_desc 	varchar2(200);
  h_minor_cat_desc	varchar2(200);

  h_count		number;

  h_mesg_name		varchar2(50);
  h_mesg_str		varchar2(2000);
  h_flex_error		varchar2(5);
  h_ccid_error		number;

-- added NVL for all h_period2_pcd in the cursor resp_additions
-- SLA
cursor resp_additions is SELECT
	cc.code_combination_id,
        EMP.FULL_NAME, emp.employee_number,
	loc.location_id,
	ah.category_id,
        AD.ASSET_NUMBER,
        AD.DESCRIPTION,
        DH.UNITS_ASSIGNED,
        AD.SERIAL_NUMBER,
        AD.TAG_NUMBER, ad.inventorial,
        BOOKS.LIFE_IN_MONTHS,
        BOOKS.ADJUSTED_RATE,
        BOOKS.PRODUCTION_CAPACITY	,
        NVL(DS.BONUS_RATE,0),
        nvl(DD.ADDITION_COST_TO_CLEAR, 0),
        nvl(DD.DEPRN_RESERVE,0),
        NULL,
	period --dp.period_name
FROM
        FA_TRANSACTION_HEADERS  TH,
	PER_ALL_PEOPLE_F 	EMP,
        FA_LOCATIONS            LOC,
        GL_CODE_COMBINATIONS    CC,
        FA_ADDITIONS            AD,
	FA_ASSET_HISTORY	AH,
        FA_DISTRIBUTION_HISTORY DH,
        FA_BOOKS                BOOKS,
        FA_DEPRN_SUMMARY        DS,
        FA_DEPRN_DETAIL         DD
	--FA_DEPRN_PERIODS	DP
WHERE
        TH.DATE_EFFECTIVE              >= h_period1_pod                    AND
        TH.DATE_EFFECTIVE              <= nvl(h_period2_pcd ,sysdate)      AND
        TH.BOOK_TYPE_CODE               = h_book                           AND
        TH.TRANSACTION_TYPE_CODE = 'TRANSFER IN'
AND
        DH.TRANSACTION_HEADER_ID_IN     =  TH.TRANSACTION_HEADER_ID       AND
        --nvl(DH.DATE_INEFFECTIVE, nvl(h_period2_pcd ,sysdate)+1)  >  nvl(h_period2_pcd ,sysdate)           AND /* SLA */
        DH.BOOK_TYPE_CODE               =  h_book                          AND
        DH.ASSET_ID                     =  TH.ASSET_ID
AND
	TH.ASSET_ID			= AH.ASSET_ID	AND
	TH.date_effective	between ah.date_effective and nvl(ah.date_ineffective,sysdate)
AND
        BOOKS.DATE_EFFECTIVE           <=  TH.DATE_EFFECTIVE              AND
        nvl(BOOKS.DATE_INEFFECTIVE,SYSDATE)         >  TH.DATE_EFFECTIVE              AND
        BOOKS.ASSET_ID                  =  TH.ASSET_ID                    AND
        BOOKS.BOOK_TYPE_CODE            =  h_book
AND
        DD.BOOK_TYPE_CODE               =  h_book                          AND
        DD.ASSET_ID                     =  TH.ASSET_ID                    AND
        DD.DISTRIBUTION_ID              =  DH.DISTRIBUTION_ID             AND
        DD.DEPRN_SOURCE_CODE            =  'B'		AND
	DD.PERIOD_COUNTER >= h_period1_pc - 1 AND
	dd.period_counter <= h_period2_pc - 1
AND
        CC.CODE_COMBINATION_ID          =  DH.CODE_COMBINATION_ID
AND
        AD.ASSET_ID                     =  TH.ASSET_ID
AND
        EMP.PERSON_ID(+)              =  DH.ASSIGNED_TO
AND
	TRUNC(SYSDATE) BETWEEN EFFECTIVE_START_DATE(+) AND EFFECTIVE_END_DATE(+)
AND
        LOC.LOCATION_ID                 =  DH.LOCATION_ID
/* AND
	dp.period_counter		= ds.period_counter  and
	dp.book_type_code		= ds.book_type_code */ --SLA
AND
        DS.ASSET_ID  (+)        =  BOOKS.ASSET_ID                 AND
        DS.BOOK_TYPE_CODE   (+)            =  h_book                          AND
        DS.PERIOD_COUNTER    (+)           >= h_period1_pc  AND
	DS.period_counter(+)		<= h_period2_pc

UNION
SELECT
	cc.code_combination_id,
        EMP.FULL_NAME, emp.employee_number,
	loc.location_id,
	ah.category_id,
        AD.ASSET_NUMBER ,
        AD.DESCRIPTION ,
        DH.UNITS_ASSIGNED	,
        AD.SERIAL_NUMBER,
        AD.TAG_NUMBER , ad.inventorial,
        BOOKS.LIFE_IN_MONTHS,
        BOOKS.ADJUSTED_RATE,
        BOOKS.PRODUCTION_CAPACITY,
        NVL(DS.BONUS_RATE,0),
        sum(CADJ.ADJUSTMENT_AMOUNT	*
	DECODE(CADJ.DEBIT_CREDIT_FLAG,'CR',-1,'DR',1)),
        0 , 				-- RESERVE,
        'T',
	period --dp.period_name
FROM
        FA_TRANSACTION_HEADERS  TH,
        PER_ALL_PEOPLE_F            EMP,
        FA_LOCATIONS            LOC,
        GL_CODE_COMBINATIONS    CC,
        FA_ADDITIONS          AD,
	FA_ASSET_HISTORY 	AH,
        FA_DISTRIBUTION_HISTORY DH,
        FA_BOOKS                BOOKS,
	FA_DEPRN_SUMMARY        DS,
       	FA_ADJUSTMENTS 		CADJ
	--fa_deprn_periods	dp
WHERE
        TH.DATE_EFFECTIVE              >= h_period1_pod                    AND
        TH.DATE_EFFECTIVE              <= nvl(h_period2_pcd ,sysdate)                    AND
        TH.BOOK_TYPE_CODE               = h_book                           AND
        TH.TRANSACTION_TYPE_CODE = 'TRANSFER'
AND
        DH.TRANSACTION_HEADER_ID_IN     =  TH.TRANSACTION_HEADER_ID       AND
        --nvl(DH.DATE_INEFFECTIVE, nvl(h_period2_pcd ,sysdate)+1)  >  nvl(h_period2_pcd ,sysdate)           AND
        DH.BOOK_TYPE_CODE               =  h_book                          AND
        DH.ASSET_ID                     =  TH.ASSET_ID
AND
	TH.ASSET_ID			= AH.ASSET_ID	AND
	TH.date_effective	between ah.date_effective and nvl(ah.date_ineffective,sysdate)
AND
        BOOKS.DATE_EFFECTIVE           <=  TH.DATE_EFFECTIVE              AND
        nvl(BOOKS.DATE_INEFFECTIVE, SYSDATE)   >  TH.DATE_EFFECTIVE              AND
        BOOKS.ASSET_ID                  =  TH.ASSET_ID                    AND
        BOOKS.BOOK_TYPE_CODE            =  h_book
AND
        CC.CODE_COMBINATION_ID          =  DH.CODE_COMBINATION_ID         AND
	CADJ.BOOK_TYPE_CODE		= H_BOOK  AND
	CADJ.ASSET_ID			= TH.ASSET_ID AND
	CADJ.DISTRIBUTION_ID                            	= DH.DISTRIBUTION_ID AND
	CADJ.TRANSACTION_HEADER_ID	= TH.TRANSACTION_HEADER_ID AND
	CADJ.SOURCE_TYPE_CODE		= 'TRANSFER' AND
	CADJ.PERIOD_COUNTER_CREATED >= h_period1_pc  AND
	cadj.period_counter_created <= h_period2_pc  and
	CADJ.ADJUSTMENT_TYPE		in ('COST','CIP COST')
AND
        AD.ASSET_ID                     =  TH.ASSET_ID
AND
        EMP.PERSON_ID(+)              =  DH.ASSIGNED_TO
AND
       TRUNC(SYSDATE) BETWEEN EMP.EFFECTIVE_START_DATE(+) AND EMP.EFFECTIVE_END_DATE(+)
AND
        LOC.LOCATION_ID                 =  DH.LOCATION_ID
/*AND
	dp.period_counter		= ds.period_counter  and
	dp.book_type_code		= ds.book_type_code*/
AND
        DS.ASSET_ID  (+)                   =  BOOKS.ASSET_ID                 AND
        DS.BOOK_TYPE_CODE (+)              =  h_book                          AND
        DS.PERIOD_COUNTER   (+)            >=  h_period1_pc  and
	ds.period_counter(+)		<= h_period2_pc
GROUP BY
	cc.code_combination_id,
        EMP.FULL_NAME, emp.employee_number,
	loc.location_id,
	ah.category_id,
        AD.DESCRIPTION,
        DH.UNITS_ASSIGNED,
        AD.SERIAL_NUMBER,
        AD.TAG_NUMBER, ad.inventorial,
        AD.ASSET_NUMBER,
        BOOKS.LIFE_IN_MONTHS,
        BOOKS.ADJUSTED_RATE,
        BOOKS.PRODUCTION_CAPACITY,
        DS.BONUS_RATE,
	period --dp.period_name
UNION
SELECT
	cc.code_combination_id,
        EMP.FULL_NAME, emp.employee_number,
	loc.location_id,
	ah.category_id,
        AD.ASSET_NUMBER,
        AD.DESCRIPTION ,
        DH.UNITS_ASSIGNED,
        AD.SERIAL_NUMBER,
        AD.TAG_NUMBER , ad.inventorial,
        BOOKS.LIFE_IN_MONTHS,
        BOOKS.ADJUSTED_RATE,
        BOOKS.PRODUCTION_CAPACITY,
        NVL(DS.BONUS_RATE,0),
        0,				-- COST,
        sum(RADJ.ADJUSTMENT_AMOUNT *
	DECODE(RADJ.DEBIT_CREDIT_FLAG,'CR',1,'DR',-1)),
        'T',
	period --dp.period_name
FROM
        FA_TRANSACTION_HEADERS  TH,
        PER_ALL_PEOPLE_F 	 EMP,
        FA_LOCATIONS            LOC,
        GL_CODE_COMBINATIONS    CC,
        FA_ADDITIONS          AD,
	FA_ASSET_HISTORY	AH,
        FA_DISTRIBUTION_HISTORY DH,
        FA_DEPRN_SUMMARY        DS,
        FA_BOOKS                BOOKS,
	FA_ADJUSTMENTS RADJ
	--fa_deprn_periods	dp
WHERE
        TH.DATE_EFFECTIVE              >= h_period1_pod                    AND
        TH.DATE_EFFECTIVE              <= nvl(h_period2_pcd ,sysdate)                   AND
        TH.BOOK_TYPE_CODE               = h_book                           AND
        TH.TRANSACTION_TYPE_CODE = 'TRANSFER'
AND
        DH.TRANSACTION_HEADER_ID_IN     =  TH.TRANSACTION_HEADER_ID       AND
        --nvl(DH.DATE_INEFFECTIVE, nvl(h_period2_pcd ,sysdate)+1)  >  nvl(h_period2_pcd ,sysdate)           AND
        DH.BOOK_TYPE_CODE               =  h_book                          AND
        DH.ASSET_ID                     =  TH.ASSET_ID
AND
	TH.ASSET_ID			= AH.ASSET_ID	AND
	TH.date_effective	between ah.date_effective and nvl(ah.date_ineffective,sysdate)
AND
        BOOKS.DATE_EFFECTIVE           <=  TH.DATE_EFFECTIVE              AND
        nvl(BOOKS.DATE_INEFFECTIVE, SYSDATE)   >  TH.DATE_EFFECTIVE              AND
        BOOKS.ASSET_ID                  =  TH.ASSET_ID                    AND
        BOOKS.BOOK_TYPE_CODE            =  h_book
AND
        CC.CODE_COMBINATION_ID          =  DH.CODE_COMBINATION_ID         AND
	RADJ.BOOK_TYPE_CODE		= H_BOOK  AND
	RADJ.ASSET_ID			= TH.ASSET_ID AND
	RADJ.DISTRIBUTION_ID                            	= DH.DISTRIBUTION_ID AND
	RADJ.TRANSACTION_HEADER_ID	= TH.TRANSACTION_HEADER_ID AND
	RADJ.SOURCE_TYPE_CODE		= 'TRANSFER' AND
	RADJ.PERIOD_COUNTER_CREATED >= h_period1_pc AND
	radj.period_counter_created <= h_period2_pc  and
	RADJ.ADJUSTMENT_TYPE		= 'RESERVE'
AND
        AD.ASSET_ID                     =  TH.ASSET_ID
AND
        EMP.PERSON_ID(+)              =  DH.ASSIGNED_TO
AND
       TRUNC(SYSDATE) BETWEEN EMP.EFFECTIVE_START_DATE(+) AND EMP.EFFECTIVE_END_DATE(+)
AND
        LOC.LOCATION_ID                 =  DH.LOCATION_ID
/*AND
	dp.period_counter		= ds.period_counter  and
	dp.book_type_code		= ds.book_type_code*/
AND
        DS.ASSET_ID  (+)                   =  BOOKS.ASSET_ID                 AND
        DS.BOOK_TYPE_CODE (+)              =  h_book                          AND
        DS.PERIOD_COUNTER   (+)            >= h_period1_pc  and
	ds.period_counter(+)		<= h_period2_pc
GROUP BY
	cc.code_combination_id,
        EMP.FULL_NAME, emp.employee_number,
	loc.location_id,
	ah.category_id,
        AD.DESCRIPTION,
        DH.UNITS_ASSIGNED,
        AD.SERIAL_NUMBER,
        AD.TAG_NUMBER, ad.inventorial,
        AD.ASSET_NUMBER,
        BOOKS.LIFE_IN_MONTHS,
        BOOKS.ADJUSTED_RATE,
        BOOKS.PRODUCTION_CAPACITY,
        DS.BONUS_RATE,
	period; --dp.period_name;

  begin

  h_book := book;
  h_request_id := request_id;
  ctr := 0;

  select fcr.last_update_login into h_login_id
  from fnd_concurrent_requests fcr
  where fcr.request_id = h_request_id;

  h_mesg_name := 'FA_REC_SQL_ACCT_FLEX';

  select nvl(distribution_source_book, book_type_code), accounting_flex_structure
  into h_dist_source_book, h_acct_flex_struct
  from fa_book_controls
  where book_type_code = h_book;

  h_mesg_name := 'FA_FA_LOOKUP_IN_SYSTEM_CTLS';

  select location_flex_structure, category_flex_structure
  into h_loc_flex_struct, h_cat_flex_struct
  from fa_system_controls;

   h_mesg_name := 'FA_RX_SEGNUMS';

   fa_rx_shared_pkg.GET_ACCT_SEGMENT_NUMBERS (
   BOOK         => h_book,
   BALANCING_SEGNUM     => h_bal_seg,
   ACCOUNT_SEGNUM       => h_acct_seg,
   CC_SEGNUM            => h_cost_seg,
   CALLING_FN           => 'ADD_BY_PERIOD');

  h_mesg_name := 'FA_AMT_SEL_PERIODS';

  select period_counter, period_open_date
  into h_period1_pc, h_period1_pod
  from fa_deprn_periods
  where book_type_code = h_book and period_name = period;

  select count(*) into h_count
  from fa_deprn_periods where period_name = period
  and book_type_code = h_book;

  if (h_count > 0) then
    select period_counter, nvl(period_close_date,sysdate)
    into h_period2_pc, h_period2_pcd
    from fa_deprn_periods
    where book_type_code = h_book and period_name = period;
  else
    h_period2_pc := null;
    h_period2_pcd := null;
  end if;


  h_mesg_name := 'FA_DEPRN_SQL_DCUR';

  open resp_additions;
  loop

    h_mesg_name := 'FA_DEPRN_SQL_FCUR';

--SLA

--dev_debug(h_book);
--dev_debug(to_char(h_period1_pc));
--dev_debug(to_char(h_period2_pc));
--dev_debug(to_char(h_period1_pod));
--dev_debug(to_char(h_period2_pcd));

    fetch resp_additions into
	h_ccid,
 	h_emp_name, h_emp_number,
	h_location_id,
	h_category_id,
	h_asset_number,
  	h_description,
	h_units,
	h_serial_number, h_tag_number, h_inventorial,
	h_life_months,
	h_adjusted_rate,
	h_prod_capacity,
	h_bonus_rate,
	h_cost_to_clear,
	h_reserve,
	h_invoice_flag,
	h_period_name;


    if (resp_additions%NOTFOUND) then
    --dev_debug('test1');
    exit;  end if;
--dev_debug('test2');
  ctr := ctr + 1;

  mesg := 'concat_account';

        h_mesg_name := 'FA_RX_CONCAT_SEGS';
        h_flex_error := 'GL#';
        h_ccid_error := h_ccid;
--dev_debug('test3');
        fa_rx_shared_pkg.concat_acct (
           struct_id => h_acct_flex_struct,
           ccid => h_ccid,
           concat_string => h_concat_acct,
           segarray => h_acct_segs);
--dev_debug('test4');
--dev_debug(to_char(h_cost_seg));
--dev_debug(to_char(begin_cc));
--dev_debug(to_char(end_cc));
   if (h_acct_segs(h_cost_seg) >= begin_cc
	and h_acct_segs(h_cost_seg) <= end_cc) then

    mesg := 'concat_location';
--dev_debug('test5');
        h_flex_error := 'LOC#';
        h_ccid_error := h_location_id;

        fa_rx_shared_pkg.concat_location (
           struct_id => h_loc_flex_struct,
           ccid => h_location_id,
           concat_string => h_concat_loc,
           segarray => h_loc_segs);
--dev_debug('test6');
	select decode(h_life_months, null, null,
		to_char(floor(h_life_months/12)) || '.' ||
			to_char(mod(h_life_months,12)))
	into h_life_year_month
	from dual;

        h_life_year_month_num := fnd_number.canonical_to_number(h_life_year_month);



  mesg := 'concat_category';

        h_flex_error := 'CAT#';
        h_ccid_error := h_category_id;

        fa_rx_shared_pkg.concat_category (
           struct_id => h_cat_flex_struct,
           ccid => h_category_id,
           concat_string => h_concat_cat,
           segarray => h_cat_segs);



-- dynamic sql for major and minor category.

   maj_select_column := null;
   min_select_column := null;

   maj_select_column := fa_rx_flex_pkg.flex_sql(140,'CAT#',h_cat_flex_struct,'CAT','SELECT','BASED_CATEGORY');
   maj_select_column := maj_select_column || '     MAJOR_CATEGORY';

   begin
     min_select_column := fa_rx_flex_pkg.flex_sql(140,'CAT#',h_cat_flex_struct,'CAT','SELECT','MINOR_CATEGORY');
     min_select_column := min_select_column || '      MINOR_CATEGORY';
    exception
      when others then
        min_select_column := 'NULL';
   end;

   sql_stmt := 'select ' || 		maj_select_column || ' , ' || min_select_column ||
		' from fa_categories cat where category_id = ' || h_category_id ;


    OPEN category_segments FOR sql_stmt;
    FETCH category_segments INTO
	h_major_category,
	h_minor_category;
    CLOSE category_segments;

--

 mesg := 'getting_major_category_desc';

    h_major_cat_desc :=
      fa_rx_flex_pkg.get_description(
	 p_application_id => 140,
	 p_id_flex_code   => 'CAT#',
	 p_id_flex_num    => h_cat_flex_struct,
	 p_qualifier      => 'BASED_CATEGORY',
         p_data		  => h_major_category);


 mesg := 'getting_minor_category_desc';
     h_minor_cat_desc :=
       fa_rx_flex_pkg.get_description(
	 p_application_id => 140,
	 p_id_flex_code   => 'CAT#',
	 p_id_flex_num    => h_cat_flex_struct,
	 p_qualifier      => 'MINOR_CATEGORY',
         p_data		  => h_minor_category);



    h_mesg_name := 'FA_SHARED_INSERT_FAILED';
--dev_debug('test7');
--dev_debug(to_char(request_id));
    insert into fa_addition_rep_itf (
	request_id, company, cost_Center, expense_acct,
	asset_number, description, reserve,
	cost_to_clear,	invoice_flag,
	life_year_month, prod_capacity, adjusted_rate,
	employee_name, employee_number, location,
	serial_number, tag_number, inventorial, period_name,
	last_update_date, creation_date, last_updated_by,
	last_update_login, created_by,
	category,
	major_category,
	minor_category,
	major_category_desc,
	minor_category_desc
	) values (
	request_id, h_acct_segs(h_bal_seg),
	h_acct_segs(h_cost_seg), h_acct_segs(h_acct_seg),
	h_asset_number, h_description,	h_reserve, h_cost_to_clear,
	h_invoice_flag, h_life_year_month_num, h_prod_capacity,
	h_adjusted_rate, h_emp_name, h_emp_number,
	h_concat_loc, h_serial_number, h_tag_number, h_inventorial,
	h_period_name, sysdate, sysdate,
	user_id, h_login_id, user_id,
	h_concat_cat,
	h_major_category,
	h_minor_category,
	h_major_cat_desc,
	h_minor_cat_desc);

    end if;   -- if cc between...

  end loop;


  h_mesg_name := 'FA_DEPRN_SQL_CCUR';

  close resp_additions;

exception when others then
  if SQLCODE <> 0 then
    fa_Rx_conc_mesg_pkg.log(SQLERRM);
  end if;
  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name = 'FA_SHARED_INSERT_FAIL' then
	fnd_message.set_token('TABLE','FA_ADDITION_REP_ITF',FALSE);
  end if;
  if h_mesg_name = 'FA_RX_CONCAT_SEGS' then
        fnd_message.set_token('CCID',to_char(h_ccid_error),FALSE);
        fnd_message.set_token('FLEX_CODE',h_flex_error,FALSE);
  end if;

  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  retcode := 2;

  end add_by_resp;


END FARX_AD;

/
