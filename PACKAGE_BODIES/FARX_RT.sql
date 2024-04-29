--------------------------------------------------------
--  DDL for Package Body FARX_RT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_RT" as
/* $Header: farxrtb.pls 120.6.12010000.3 2009/07/19 13:31:49 glchen ship $ */

  -- g_print_debug boolean := fa_cache_pkg.fa_print_debug;
  g_print_debug boolean := TRUE;

procedure ret (
	book		 in	varchar2,
	begin_period	 in	varchar2,
	end_period	 in	varchar2,
	from_maj_cat	 in	varchar2,
	to_maj_cat	 in	varchar2,
	from_min_cat	 in	varchar2,
	to_min_cat	 in	varchar2,
	from_cc		 in	varchar2,
	to_cc		 in	varchar2,
	cat_seg_num	 in	varchar2,
	from_cat_seg_val in	varchar2,
	to_cat_seg_val	 in	varchar2,
	from_asset_num	 in	varchar2,
	to_asset_num	 in	varchar2,
	request_id	 in	number,
	user_id		 in	number,
	retcode	 out nocopy number,
	errbuf	 out nocopy varchar2) is


  h_count		number;
  h_book		varchar2(30);
  h_period1_pod		varchar2(60);
  h_period2_pcd		varchar2(60);
  h_period1_pod_char    varchar2(60);
  h_period2		varchar2(60);
  h_precision		number;
  h_dist_source_book	varchar2(30);
  h_request_id		number;
  h_login_id		number;

  h_acct_segs		fa_rx_shared_pkg.Seg_Array;
  h_loc_segs		fa_rx_shared_pkg.Seg_Array;
  h_cat_segs		fa_rx_shared_pkg.Seg_Array;
  h_concat_acct		varchar2(500);
  h_concat_loc		varchar2(500);
  h_concat_cat		varchar2(500);
  h_acct_struct		number;
  h_loc_struct		number;
  h_cat_struct		number;
  h_bal_seg		number;
  h_cc_seg		number;
  h_acct_seg		number;

  h_ccid		number;
  h_emp_name		varchar2(240);
  h_emp_number		varchar2(30);
  h_location_id		number;
  h_category_id		number;
  h_cost_acct		varchar2(25);
  h_reserve_acct	varchar2(25);
  h_asset_number	varchar2(15);
  h_description		varchar2(80);
  h_serial_number	varchar2(35);
  h_tag_number		varchar2(15);
  h_date_retired	date;
  h_units		number;
  h_trx_id		number;
  h_cost_retired	number;
  h_nbv_retired		number;
  h_proceeds_of_sale	number;
  h_gain_loss_amount	number;
  h_removal_cost	number;
  h_itc_captured	number;
  h_flag		varchar2(1);
  h_dpis		date;
  h_inventorial		varchar2(3);
  h_set_of_books_id	number;
  h_currency_code	varchar2(15);
  h_organization_name	varchar2(80);

  h_period_name		varchar2(25);
  h_period_name_to	varchar2(25);
  h_cat_seg_num		varchar2(25);
  h_account_desc	varchar2(240);
  h_cost_center_desc	varchar2(240);
  h_deprn_reserve	number;
  h_maj_cat		varchar2(240);
  h_maj_cat_desc	varchar2(240);
  h_min_cat		varchar2(240);
  h_min_cat_desc	varchar2(240);
  h_specified_cat	varchar2(240);
  h_specified_cat_desc	varchar2(240);
  h_tran_header_id	number;

  h_mesg_name		varchar2(50);
  h_mesg_str		varchar2(2000);
  h_flex_error		varchar2(5);
  h_ccid_error		number;

  h_assetkey_flex_structure	number;
  h_chart_of_accounts_id	number;

  maj_select_statement	varchar2(50);
  min_select_statement  varchar2(50);
  spec_select_statement varchar2(50);

  l_param_where		varchar2(1000);
  from_clause		varchar2(1000);
  where_clause		varchar2(3000);
  select_statement	varchar2(15000);

  type var_cur is ref cursor;
  ret_lines	var_cur;

begin
    IF (g_print_debug) THEN
    	fa_rx_util_pkg.debug('farx_rt.ret()+');
    END IF;

  h_book := book;
  h_request_id := request_id;
  h_period_name := begin_period;
  h_period_name_to := end_period;
  h_cat_seg_num := cat_seg_num;

  select fcr.last_update_login into h_login_id
  from fnd_concurrent_requests fcr
  where fcr.request_id = h_request_id;

     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('ret: ' || '********login_id:' || h_login_id);
     	fa_rx_util_pkg.debug('ret: ' || '********login_id:' || h_login_id);
     END IF;

  h_mesg_name := 'FA_FA_LOOKUP_IN_SYSTEM_CTLS';

   select category_flex_structure, location_flex_structure,asset_key_flex_structure
   into h_cat_struct, h_loc_struct, h_assetkey_flex_structure
   from fa_system_controls;

  h_mesg_name := 'FA_AMT_SEL_PERIODS';

  select to_char(period_open_date,'dd-mm-yyyy hh24:mi:ss')
  into h_period1_pod
  from fa_deprn_periods
  where book_type_code = h_book and period_name = begin_period;

/* BUG# 2939771

  h_period1_pod_char := 'to_date(''' || h_period1_pod || ''',''dd-mm-yyyy hh24:mi:ss'')';
*/

  select count(*) into h_count
  from fa_deprn_periods where period_name = end_period
  and book_type_code = h_book;

  if (h_count > 0) then
    select to_char(period_close_date,'dd-mm-yyyy hh24:mi:ss')
    into h_period2_pcd
    from fa_deprn_periods
    where book_type_code = h_book and period_name = end_period;
  end if;

/* BUG# 2939771
  if (h_period2_pcd is NULL) then
    h_period2 := ' <= SYSDATE ';
  else
    h_period2 := ' <= to_date(''' || h_period2_pcd || ''',''dd-mm-yyyy hh24:mi:ss'')';
  end if;
*/

       IF (g_print_debug) THEN
       	fa_rx_util_pkg.debug('ret: ' || 'h_period2:' || h_period2);
       END IF;

  h_mesg_name := 'FA_REC_SQL_ACCT_FLEX';

  select accounting_flex_structure, distribution_source_book
  into h_acct_struct, h_dist_source_book
  from fa_book_controls
  where book_type_code = h_book;

  h_mesg_name := 'FA_DYN_CURRENCY';


  select cur.precision into h_precision
  from fa_book_controls bc, gl_sets_of_books sob, fnd_currencies cur
  where bc.book_type_code = h_book
  and sob.set_of_books_id = bc.set_of_books_id
  and sob.currency_code = cur.currency_code;

   h_mesg_name := 'FA_RX_SEGNUMS';

   fa_rx_shared_pkg.GET_ACCT_SEGMENT_NUMBERS (
   BOOK         => h_book,
   BALANCING_SEGNUM     => h_bal_seg,
   ACCOUNT_SEGNUM       => h_acct_seg,
   CC_SEGNUM            => h_cc_seg,
   CALLING_FN           => 'RET');

   h_mesg_name := 'FA_DEPRN_SQL_DCUR';

   select sob.chart_of_accounts_id,
	  sob.set_of_books_id,
	  substr(sob.currency_code,1,15),
	  substr(sob.name,1 ,80)
   into	  h_chart_of_accounts_id,
	  h_set_of_books_id,
	  h_currency_code,
	  h_organization_name
   from   fa_book_controls bc, gl_sets_of_books sob, fnd_currencies cur
   WHERE  bc.book_type_code = h_book
   AND    sob.set_of_books_id = bc.set_of_books_id
   AND	  sob.currency_code = cur.currency_code; -- Added set_of_books_id and currency_code to display those on report



     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('ret: ' || 'chart of account ID:' || h_chart_of_accounts_id);
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
   -- Figure out the from and where clause for the parameters
   --

   -- default from clause

    from_clause := '
        fa_additions                ad,
        gl_code_combinations        dhcc,
        fa_asset_history            ah,
        fa_category_books           cb,
        per_all_people_f            emp,
        fa_locations                loc,
        fa_distribution_history     dh,
	fa_books		    books,
        fa_retirements              ret,
	fa_transaction_headers      th,
	fa_deprn_detail		    dd,
	fa_deprn_periods	    dp,
	fa_categories		    cat';

 -- parameter where clause --


   l_param_where := null;

   -- Major Category --
   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
        'SELECT', 'BASED_CATEGORY') ||' >= :from_maj_cat or :from_maj_cat is NULL)';

   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
        'SELECT', 'BASED_CATEGORY') ||' <= :to_maj_cat or :to_maj_cat is NULL)';

   -- Minor Category --
   /*
   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
        'SELECT', 'MINOR_CATEGORY') ||' >= :from_min_cat or :from_min_cat is NULL)';

   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(140,'CAT#', h_assetkey_flex_structure,'CAT',
        'SELECT', 'MINOR_CATEGORY') ||' <= :to_min_cat or :to_min_cat is NULL)';
   */

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
      from_clause := from_clause || ',
	   		fa_categories		    cat';
      l_param_where := l_param_where || ' AND CB.CATEGORY_ID = CAT.CATEGORY_ID';
   END IF;
*/

   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(101,'GL#', h_chart_of_accounts_id,'DHCC',
        'SELECT', 'FA_COST_CTR') ||' >= :from_cc or :from_cc is NULL)';

   l_param_where := l_param_where || ' AND (' ||
        fa_rx_flex_pkg.flex_sql(101,'GL#', h_chart_of_accounts_id,'DHCC',
        'SELECT', 'FA_COST_CTR') ||' <= :to_cc or :to_cc is NULL)';


/* BUG# 2939771
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
     	fa_rx_util_pkg.debug('ret: ' || 'l_param_where:' || l_param_where);
     END IF;


   where_clause := 'th.date_effective     >= to_date(:h_period1_pod,''dd-mm-yyyy hh24:mi:ss'') AND
        th.date_effective    <= decode(:h_period2_pcd,NULL,SYSDATE,to_date(:h_period2_pcd,''dd-mm-yyyy hh24:mi:ss''))   	AND
        th.book_type_code 	= :h_book 	                AND
        th.transaction_key 	= ''R''
AND	BOOKS.TRANSACTION_HEADER_ID_OUT	= TH.TRANSACTION_HEADER_ID 	 	AND
	BOOKS.BOOK_TYPE_CODE		= :h_book 		 	AND
	books.asset_id			= th.asset_id
AND
        th.transaction_header_id 	= decode(th.transaction_type_code,''REINSTATEMENT'',
					 ret.transaction_header_id_out, ret.transaction_header_id_in)
AND
        ad.asset_id 			= th.asset_id
AND
        cb.category_id 			= ah.category_id   			AND
        cb.book_type_code 		= :h_book
AND
        ah.asset_id 			= ad.asset_id            		AND
        ah.date_effective 		<= th.date_effective 			AND
        nvl(ah.date_ineffective, th.date_effective+1) >  th.date_effective
AND
        dh.asset_id 			= th.asset_id                		AND
        dh.book_type_code 		= :h_dist_source_book  	AND
	( dh.retirement_id 	= ret.retirement_id
		or
	  (ret.date_effective >= dh.date_effective  			and
    	   ret.date_effective <= nvl(dh.date_ineffective,sysdate)	and
	   ret.units is null) )
AND
        dhcc.code_combination_id 	= dh.code_combination_id
AND
        dh.location_id 			= loc.location_id
AND
        dh.assigned_to 			= emp.person_id(+)
AND
	trunc(sysdate)	between emp.effective_start_date(+) and emp.effective_end_date(+)
AND
	dd.book_type_code		= :h_book			AND
	dd.asset_id			= ad.asset_id				AND
	dd.period_counter		= dp.period_counter			AND
	dd.distribution_id		= dh.distribution_id			AND
	dp.book_type_code		= dd.book_type_code			AND
	ret.asset_id			= dd.asset_id				AND
	ret.date_effective		>= dp.period_open_date			AND
	ret.date_effective		<= nvl(dp.period_close_date,sysdate)
AND 	CB.CATEGORY_ID = CAT.CATEGORY_ID';

   IF (l_param_where is not NULL) THEN
       where_clause := where_clause || l_param_where;
   END IF;

   h_mesg_name := 'FA_RETIREMENTS_SQL_DCUR';

     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('ret: ' || 'where_clause:' || where_clause);
     	fa_rx_util_pkg.debug('ret: ' || 'from_clause:' || from_clause);
     END IF;

    select_statement := '
SELECT  /*+ leading(th ad) use_nl(ad) index(FA_ADDITIONS_B_U1 )*/ --Bug# 7587861
        dhcc.code_combination_id,
        emp.full_name,
	emp.employee_number,
        loc.location_id,
	cb.category_id,
        decode(ah.asset_type,''CIP'',cb.cip_cost_acct,cb.asset_cost_acct),
	cb.deprn_reserve_acct,
	ad.inventorial,
        ad.asset_number,
	ad.description,
	ad.serial_number,
	ad.tag_number,
        ret.date_retired,
	decode(sign(dh.transaction_units),-1,-dh.transaction_units,dh.transaction_units),
	th.transaction_header_id,
	ROUND(decode(ret.units, NULL,
        	(decode(th.transaction_type_code, ''REINSTATEMENT'',
          	  -ret.cost_retired,  ret.cost_retired)
					* (dh.units_assigned /ah.units)),
       	 	(decode(th.transaction_type_code, ''REINSTATEMENT'',
         	  -ret.cost_retired,  ret.cost_retired)
					* -dh.transaction_units / ret.units)) ,:h_precision),
	ROUND(decode(ret.units, NULL,
        	(decode(th.transaction_type_code, ''REINSTATEMENT'',
          	  -ret.nbv_retired,  ret.nbv_retired)
 					* (dh.units_assigned /ah.units)),
        	(decode(th.transaction_type_code, ''REINSTATEMENT'',
         	   -ret.nbv_retired,  ret.nbv_retired)
           				* -dh.transaction_units / ret.units)),:h_precision),
	ROUND(decode(ret.units, NULL,
        	(decode(th.transaction_type_code, ''REINSTATEMENT'',
          	  -ret.proceeds_of_sale,  ret.proceeds_of_sale)
	 				* (dh.units_assigned /ah.units)),
        	(decode(th.transaction_type_code, ''REINSTATEMENT'',
          	  -ret.proceeds_of_sale,  ret.proceeds_of_sale)
           				* -dh.transaction_units / ret.units)),:h_precision),
	ROUND(decode(ret.units, NULL,
        	(decode(th.transaction_type_code, ''REINSTATEMENT'',
          	  -ret.gain_loss_amount,  ret.gain_loss_amount)
	 				* (dh.units_assigned /ah.units)),
        	(decode(th.transaction_type_code, ''REINSTATEMENT'',
          	  -ret.gain_loss_amount,  ret.gain_loss_amount)
           				* -dh.transaction_units / ret.units)),:h_precision),
	round(decode(ret.units, NULL,
		(decode(th.transaction_type_code,''REINSTATEMENT'',
	  	  -ret.cost_of_removal, ret.cost_of_removal)
  					* (dh.units_assigned / ah.units)),
		(decode(th.transaction_type_code, ''REINSTATEMENT'',
	  	  -ret.cost_of_removal, ret.cost_of_removal)
	  				* -dh.transaction_units / ret.units)),:h_precision),
	round(decode(ret.units, NULL,
		(decode(th.transaction_type_code,''REINSTATEMENT'',
	  	  -ret.itc_recaptured, ret.itc_recaptured)
  					* (dh.units_assigned / ah.units)),
		(decode(th.transaction_type_code, ''REINSTATEMENT'',
	  	  -ret.itc_recaptured, ret.itc_recaptured)
	  				* -dh.transaction_units / ret.units)),:h_precision),
	decode(th.transaction_type_code, ''REINSTATEMENT'', ''*'', ''PARTIAL RETIREMENT'',''P'',NULL),
	books.date_placed_in_service,
	dd.ytd_deprn,'||
	maj_select_statement ||','||
	min_select_statement ||','||
	spec_select_statement ||'
FROM    ' || from_clause || '
WHERE   ' || where_clause;

       IF (g_print_debug) THEN
       	fa_rx_util_pkg.debug('ret: ' || 'select_statement:' || select_statement);
       END IF;

  /* BUG# 2939771
  open ret_lines for select_statement ;
  */
  open ret_lines for select_statement using
          h_precision, -- select
          h_precision,
          h_precision,
          h_precision,
          h_precision,
          h_precision,
          h_period1_pod, -- where_clause
          h_period2_pcd,
          h_period2_pcd,
          h_book,
          h_book,
          h_book,
          h_dist_source_book,
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
     	fa_rx_util_pkg.debug('ret: ' || 'after_open');
     END IF;

  loop

    h_mesg_name := 'FA_DEPRN_SQL_FCUR';

    fetch ret_lines into
	h_ccid,
	h_emp_name,
	h_emp_number,
	h_location_id,
	h_category_id,
	h_cost_acct,
	h_reserve_acct,
	h_inventorial,
	h_asset_number,
	h_description,
	h_serial_number,
	h_tag_number,
	h_date_retired,
	h_units,
	h_trx_id,
	h_cost_retired,
	h_nbv_retired,
	h_proceeds_of_sale,
	h_gain_loss_amount,
	h_removal_cost,
	h_itc_captured,
	h_flag,
	h_dpis,
	h_deprn_reserve,
	h_maj_cat,
	h_min_cat,
	h_specified_cat;



    if (ret_lines%NOTFOUND) then exit;   end if;

     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('ret_lines:');
     END IF;

   h_mesg_name := 'FA_RX_CONCAT_SEGS';
   h_flex_error := 'GL#';
   h_ccid_error := h_ccid;

        fa_rx_shared_pkg.concat_acct (
           struct_id => h_acct_struct,
           ccid => h_ccid,
           concat_string => h_concat_acct,
           segarray => h_acct_segs);

   h_flex_error := 'CAT#';
   h_ccid_error := h_category_id;

        fa_rx_shared_pkg.concat_category (
           struct_id => h_cat_struct,
           ccid => h_category_id,
           concat_string => h_concat_cat,
           segarray => h_cat_segs);

   h_flex_error := 'LOC#';
   h_ccid_error := h_location_id;

        fa_rx_shared_pkg.concat_location (
           struct_id => h_loc_struct,
           ccid => h_location_id,
           concat_string => h_concat_loc,
           segarray => h_loc_segs);

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
         p_data		  => h_acct_segs(h_cc_seg));


  IF (g_print_debug) THEN
  	fa_rx_util_pkg.debug('ret: ' || '** assetkey_flex_struct:' || h_assetkey_flex_structure);
  	fa_rx_util_pkg.debug('ret: ' || '** category_id:' ||  h_category_id);
  	fa_rx_util_pkg.debug('ret: ' || '** specified_cat:' || h_cat_seg_num);
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

    insert into fa_retire_rep_itf (
	request_id, company, cost_Center, expense_acct,
	location, category, cost_acct, reserve_acct,
	asset_number, description, serial_number, tag_number,
	date_retired, units_retired, cost_retired, nbv_retired,
	proceeds_of_sale, gain_loss_amount, removal_cost,
	itc_captured, flag, date_placed_in_service, inventorial,
	employee_name, employee_number, transaction_header_id,
	created_by, creation_date, last_updated_by,
	last_update_date, last_update_login,
	set_of_books_id, functional_currency_code,organization_name,
	book_type_code,period_name,period_name_to,account_description,
	cost_center_description,
	deprn_reserve,
	major_category,
	major_category_desc,minor_category,minor_category_desc,
	specified_category_seg,specified_cat_seg_desc) values (
	request_id, h_acct_segs(h_bal_seg),
	h_acct_segs(h_cc_seg), h_acct_segs(h_acct_seg),
	h_concat_loc, h_concat_cat, h_cost_acct, h_reserve_acct,
	h_asset_number, h_description, h_serial_number,
	h_tag_number, 	h_date_retired, h_units,
	h_cost_retired, h_nbv_retired, h_proceeds_of_sale,
	h_gain_loss_amount, h_removal_cost, h_itc_captured,
	h_flag, h_dpis, h_inventorial, h_emp_name, h_emp_number, h_trx_id,
	user_id, sysdate, user_id, sysdate, h_login_id,
	h_set_of_books_id, h_currency_code, h_organization_name,
	h_book,h_period_name,h_period_name_to,h_account_desc,
	h_cost_center_desc,
	h_deprn_reserve,
	h_maj_cat,h_maj_cat_desc,h_min_cat,
	h_min_cat_desc,h_specified_cat,h_specified_cat_desc);



     IF (g_print_debug) THEN
     	fa_rx_util_pkg.debug('ret: ' || 'During loop');
     END IF;

  end loop;

  h_mesg_name := 'FA_DEPRN_SQL_CCUR';
  close ret_lines;


exception when others then
  if SQLCODE <> 0 then
    fa_Rx_conc_mesg_pkg.log(SQLERRM);
  end if;
  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name = 'FA_SHARED_INSERT_FAIL' then
	fnd_message.set_token('TABLE','FA_RETIRE_REP_ITF',FALSE);
  end if;
  if h_mesg_name = 'FA_RX_CONCAT_SEGS' then
        fnd_message.set_token('CCID',to_char(h_ccid_error),FALSE);
        fnd_message.set_token('FLEX_CODE',h_flex_error,FALSE);
  end if;

  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  retcode := 2;

end ret;

END FARX_RT;

/
