--------------------------------------------------------
--  DDL for Package Body FARX_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_CP" as
/* $Header: farxcpb.pls 120.3.12010000.2 2009/07/19 13:48:22 glchen ship $ */

  procedure cap (
	book		varchar2,
	begin_period	varchar2,
	end_period	varchar2,
	request_id	number default null,
	user_id		number default null,
	retcode	 out nocopy number,
	errbuf	 out nocopy varchar2) is

h_count			number;
h_book			varchar2(30);
h_precision		number;
h_period1_pod		date;
h_period2_pcd		date;
h_life_year_month	varchar2(10);
h_life_yr_mo_num	number;
h_request_id		number;
h_login_id		number;

h_ccid			number;
h_cip_cost_acct		varchar2(25);
h_asset_cost_acct	varchar2(25);
h_asset_number		varchar2(15);
h_description		varchar2(80);
h_tag_number		varchar2(15);
h_serial_number		varchar2(35);
h_inventorial		varchar2(3);
h_dpis			date;
h_method		varchar2(15);
h_life_months		number;
h_prod_capacity		number;
h_adjusted_rate		number;
h_cost			number;

h_concat_acct		varchar2(500);
h_acct_segs		fa_rx_shared_pkg.Seg_Array;
h_acct_structure	number;
h_bal_seg		number;
h_cc_seg		number;
h_acct_seg		number;

  h_mesg_name		varchar2(50);
  h_mesg_str		varchar2(2000);
  h_flex_error		varchar2(5);
  h_ccid_error		number;

cursor cap_lines is
SELECT dhcc.code_combination_id,
       FACB.CIP_COST_ACCT,
       FACB.ASSET_COST_ACCT,
       FADD.ASSET_NUMBER, FADD.DESCRIPTION,
	fadd.tag_number, fadd.serial_number, fadd.inventorial,
       FABKS.DATE_PLACED_IN_SERVICE,
       FABKS.DEPRN_METHOD_CODE,
       FABKS.LIFE_IN_MONTHS,
       FABKS.PRODUCTION_CAPACITY,
       FABKS.ADJUSTED_RATE,
       ROUND(DECODE(FATRANS.TRANSACTION_TYPE_CODE,'CIP REVERSE',-1*(FABKS.COST),
       FABKS.COST)*(SUM(FADH.UNITS_ASSIGNED)/FAHIST.UNITS),h_precision)
FROM	GL_CODE_COMBINATIONS 		DHCC,
	FA_DISTRIBUTION_HISTORY 	FADH,
	FA_CATEGORY_BOOKS 		FACB,
	FA_ASSET_HISTORY 		FAHIST,
	FA_ADDITIONS 			FADD,
	FA_BOOKS 			FABKS,
	FA_TRANSACTION_HEADERS 		FATRANS
WHERE	 FATRANS.TRANSACTION_TYPE_CODE = 'ADDITION'
AND	 FATRANS.BOOK_TYPE_CODE 	= h_book
AND	 FATRANS.DATE_EFFECTIVE BETWEEN
		h_period1_pod
		AND nvl(h_period2_pcd, sysdate) -- fix for bug 2865813
AND	 EXISTS (SELECT NULL
		 FROM FA_ASSET_HISTORY AH
		 WHERE AH.ASSET_ID = FATRANS.ASSET_ID
		 AND AH.ASSET_TYPE = 'CIP')
AND 	 FATRANS.ASSET_ID 				= FADH.ASSET_ID
AND 	 FATRANS.BOOK_TYPE_CODE				= FADH.BOOK_TYPE_CODE
AND 	 FATRANS.DATE_EFFECTIVE >= FADH.DATE_EFFECTIVE
AND 	 FATRANS.DATE_EFFECTIVE < NVL(FADH.DATE_INEFFECTIVE, SYSDATE)
AND	 FADH.CODE_COMBINATION_ID 			= DHCC.CODE_COMBINATION_ID
AND	 FATRANS.TRANSACTION_HEADER_ID 			= FABKS.TRANSACTION_HEADER_ID_IN
AND	 FABKS.ASSET_ID 				= FADD.ASSET_ID
AND	 FATRANS.TRANSACTION_HEADER_ID		= FAHIST.TRANSACTION_HEADER_ID_IN
AND	 FATRANS.ASSET_ID 				= FAHIST.ASSET_ID
AND	 FAHIST.CATEGORY_ID 				= FACB.CATEGORY_ID
AND	 FACB.BOOK_TYPE_CODE				= h_book
GROUP BY dhcc.code_combination_id,
         FACB.CIP_COST_ACCT,
	 FACB.ASSET_COST_ACCT,
         FADD.ASSET_NUMBER,
         FADD.DESCRIPTION,
	fadd.tag_number, fadd.serial_number, fadd.inventorial,
         FABKS.DATE_PLACED_IN_SERVICE,
         FABKS.DEPRN_METHOD_CODE,
         FABKS.LIFE_IN_MONTHS,
         FABKS.PRODUCTION_CAPACITY,
         FABKS.ADJUSTED_RATE,
         FATRANS.TRANSACTION_TYPE_CODE,
         FABKS.COST,
         FAHIST.UNITS,
         FATRANS.ASSET_ID,
         FABKS.DATE_EFFECTIVE;


  begin

  h_book := book;
  h_request_id := request_id;

  select fcr.last_update_login into h_login_id
  from fnd_concurrent_requests fcr
  where fcr.request_id = h_request_id;

  h_mesg_name := 'FA_AMT_SEL_PERIODS';

  select period_open_date
  into h_period1_pod
  from fa_deprn_periods
  where book_type_code = h_book and period_name = begin_period;

  select count(*) into h_count
  from fa_deprn_periods where period_name = end_period
  and book_type_code = h_book;

  if (h_count > 0) then
    select period_close_date
    into h_period2_pcd
    from fa_deprn_periods
    where book_type_code = h_book and period_name = end_period;
  else
    h_period2_pcd := null;
  end if;

  h_mesg_name := 'FA_REC_SQL_ACCT_FLEX';

  select accounting_flex_structure
  into h_acct_structure
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
   CALLING_FN           => 'CAP');

  h_mesg_name := 'FA_DEPRN_SQL_DCUR';

  open cap_lines;
  loop

    h_mesg_name := 'FA_DEPRN_SQL_FCUR';

    fetch cap_lines into
	h_ccid,
	h_cip_cost_acct,
	h_asset_cost_acct,
	h_asset_number,
	h_description,
	h_tag_number,
	h_serial_number,
	h_inventorial,
	h_dpis,
	h_method,
	h_life_months,
	h_prod_capacity,
	h_adjusted_rate,
	h_cost;


    if (cap_lines%NOTFOUND) then exit;   end if;

        h_mesg_name := 'FA_RX_CONCAT_SEGS';
        h_flex_error := 'GL#';
        h_ccid_error := h_ccid;

        fa_rx_shared_pkg.concat_acct (
           struct_id => h_acct_structure,
           ccid => h_ccid,
           concat_string => h_concat_acct,
           segarray => h_acct_segs);

        select decode(h_life_months, null, null,
                to_char(floor(h_life_months/12)) || '.' ||
                        to_char(mod(h_life_months,12)))
        into h_life_year_month
        from dual;

        h_life_yr_mo_num := fnd_number.canonical_to_number(h_life_year_month);

    h_mesg_name := 'FA_SHARED_INSERT_FAILED';

    insert into fa_cap_rep_itf (
	request_id, company, cost_center, expense_acct,
	cip_cost_acct, asset_cost_acct, asset_number,
	description, date_placed_in_service, method,
	tag_number, serial_number, inventorial,
	life_year_month, capacity, adjusted_rate, cost,
	created_by, creation_date, last_updated_by,
	last_update_date, last_update_login) values (
	request_id, h_acct_segs(h_bal_seg), h_acct_segs(h_cc_seg),
	h_acct_segs(h_acct_seg), h_cip_cost_acct,
	h_asset_cost_acct, h_asset_number, h_description,
	h_dpis, h_method, h_tag_number, h_serial_number, h_inventorial,
	h_life_yr_mo_num, h_prod_capacity,
	h_adjusted_rate, h_cost, user_id,
	sysdate, user_id, sysdate, h_login_id);


  end loop;

  h_mesg_name := 'FA_DEPRN_SQL_CCUR';

  close cap_lines;

exception when others then
  if SQLCODE <> 0 then
    fa_Rx_conc_mesg_pkg.log(SQLERRM);
  end if;
  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name = 'FA_SHARED_INSERT_FAIL' then
	fnd_message.set_token('TABLE','FA_CAP_REP_ITF',FALSE);
  end if;
  if h_mesg_name = 'FA_RX_CONCAT_SEGS' then
        fnd_message.set_token('CCID',to_char(h_ccid_error),FALSE);
        fnd_message.set_token('FLEX_CODE',h_flex_error,FALSE);
  end if;

  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  retcode := 2;

  end cap;

END FARX_CP;

/
