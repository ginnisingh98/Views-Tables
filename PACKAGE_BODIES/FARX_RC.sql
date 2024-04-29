--------------------------------------------------------
--  DDL for Package Body FARX_RC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_RC" as
/* $Header: farxrcb.pls 120.2.12010000.2 2009/07/19 13:43:31 glchen ship $ */

  procedure reclass (
	book		varchar2,
	begin_period	varchar2,
	end_period	varchar2,
	request_id	number,
	user_id		number,
	retcode	 out nocopy number,
	errbuf	 out nocopy varchar2) is


  h_count		number;
  h_book		varchar2(30);
  h_dist_source_book    varchar2(30);
  h_request_id		number;
  h_login_id		number;

  h_acct_segs		fa_rx_shared_pkg.Seg_Array;
  h_fcat_segs		fa_rx_shared_pkg.Seg_Array;
  h_tcat_segs		fa_rx_shared_pkg.Seg_Array;
  h_concat_acct		varchar2(500);
  h_concat_fcat		varchar2(500);
  h_concat_tcat		varchar2(500);
  h_cat_struct		number;
  h_acct_struct		number;
  h_bal_seg		number;
  h_cc_seg		number;
  h_acct_seg		number;

  h_ccid		number;
  h_period_name		varchar2(15);
  h_to_cost_acct	varchar2(25);
  h_to_reserve_acct	varchar2(25);
  h_from_cost_acct	varchar2(25);
  h_from_reserve_acct	varchar2(25);
  h_asset_number	varchar2(15);
  h_description		varchar2(80);
  h_tag_number		varchar2(15);
  h_serial_number	varchar2(35);
  h_cost		number;
  h_reserve		number;
  h_thid		number;
  h_to_category_id	number;
  h_from_category_id	number;
  h_inventorial		varchar2(3);

  h_mesg_name           varchar2(50);
  h_mesg_str            varchar2(2000);
  h_flex_error          varchar2(5);
  h_ccid_error          number;

cursor reclass_lines is
SELECT
	dhcc.code_combination_id,
 dp.period_name,
	decode(FAH.ASSET_TYPE,
	       	'CIP', FCB.CIP_COST_ACCT,
		FCB.ASSET_COST_ACCT),
	decode(FAH.ASSET_TYPE,
		'CIP', ' ',
		FCB.DEPRN_RESERVE_ACCT),
        	fcb.category_id,
	decode(TAH.ASSET_TYPE, 'CIP', TCB.CIP_COST_ACCT,
		TCB.ASSET_COST_ACCT),
	decode(TAH.ASSET_TYPE,
		'CIP', ' ',
		TCB.DEPRN_RESERVE_ACCT),
        	tcb.category_id,
	AD.ASSET_NUMBER, ad.description, ad.tag_number, ad.serial_number,
	ad.inventorial,
	sum (DECODE(COST_ADJ.DEBIT_CREDIT_FLAG, 'DR', 1, 'CR', -1) *
		COST_ADJ.ADJUSTMENT_AMOUNT),
	sum (DECODE(RES_ADJ.DEBIT_CREDIT_FLAG, 'DR', -1, 'CR', 1) *
		NVL(RES_ADJ.ADJUSTMENT_AMOUNT, 0)),
	TH.TRANSACTION_HEADER_ID
FROM
	FA_DEPRN_PERIODS		DP,
	FA_DEPRN_PERIODS		START_DP,
	FA_DEPRN_PERIODS		END_DP,
	FA_ADDITIONS			AD,
	GL_CODE_COMBINATIONS		DHCC,
	FA_CATEGORIES			FCAT,
	FA_CATEGORIES			TCAT,
	FA_CATEGORY_BOOKS		FCB,
	FA_CATEGORY_BOOKS		TCB,
	FA_TRANSACTION_HEADERS  	TH,
	FA_ADJUSTMENTS			COST_ADJ,
	FA_ADJUSTMENTS			RES_ADJ,
	FA_ASSET_HISTORY		FAH,
	FA_ASSET_HISTORY		TAH,
--	FA_DISTRIBUTION_HISTORY		fDH,
	fa_distribution_history		tdh
WHERE
	START_DP.PERIOD_NAME		=  begin_period              AND
	END_DP.PERIOD_NAME  		=  end_period 		AND
	START_DP.BOOK_TYPE_CODE		=  UPPER (h_book)              AND
	END_DP.BOOK_TYPE_CODE		=  START_DP.BOOK_TYPE_CODE
AND
	DP.BOOK_TYPE_CODE		=  START_DP.BOOK_TYPE_CODE	AND
	DP.PERIOD_COUNTER	       >=  START_DP.PERIOD_COUNTER	AND
	DP.PERIOD_COUNTER	       <=  NVL (END_DP.PERIOD_COUNTER,
					   DP.PERIOD_COUNTER)
AND
	TH.BOOK_TYPE_CODE		=  upper(h_book)  AND
	TH.TRANSACTION_TYPE_CODE 	=  'RECLASS'			AND
	TH.DATE_EFFECTIVE		>= DP.PERIOD_OPEN_DATE		AND
	TH.DATE_EFFECTIVE		<= NVL (DP.PERIOD_CLOSE_DATE, SYSDATE)
AND
	AD.ASSET_ID			=  TH.ASSET_ID
AND
	FAH.ASSET_ID			=  TH.ASSET_ID			AND
        FAH.DATE_INEFFECTIVE 		=  TH.DATE_EFFECTIVE
AND
	TAH.ASSET_ID			=  TH.ASSET_ID			AND
	TAH.DATE_EFFECTIVE 		=  TH.DATE_EFFECTIVE
AND
	TCAT.CATEGORY_ID		=  TAH.CATEGORY_ID
AND
	FCAT.CATEGORY_ID		=  FAH.CATEGORY_ID
AND
	TCB.BOOK_TYPE_CODE		=  UPPER (h_book)              AND
	TCB.CATEGORY_ID			=  TAH.CATEGORY_ID
AND
	FCB.BOOK_TYPE_CODE		=  UPPER (h_book)              AND
	FCB.CATEGORY_ID			=  FAH.CATEGORY_ID
AND
	COST_ADJ.TRANSACTION_HEADER_ID	=  TH.TRANSACTION_HEADER_ID	AND
	COST_ADJ.BOOK_TYPE_CODE		=  upper(h_book)		AND
	COST_ADJ.SOURCE_TYPE_CODE	=  'RECLASS'			AND
	COST_ADJ.ADJUSTMENT_TYPE	in ('COST', 'CIP COST')		AND
	COST_ADJ.PERIOD_COUNTER_CREATED >= START_DP.PERIOD_COUNTER	AND
	COST_ADJ.PERIOD_COUNTER_CREATED  <=  NVL (END_DP.PERIOD_COUNTER,
					 DP.PERIOD_COUNTER)
AND
	RES_ADJ.TRANSACTION_HEADER_ID (+) =  COST_ADJ.TRANSACTION_HEADER_ID AND
	RES_ADJ.ASSET_ID (+)		= COST_ADJ.ASSET_ID AND
	RES_ADJ.DISTRIBUTION_ID (+)	= COST_ADJ.DISTRIBUTION_ID AND
	RES_ADJ.BOOK_TYPE_CODE (+)        =  UPPER(h_book)       AND
	RES_ADJ.SOURCE_TYPE_CODE (+)	=  'RECLASS'			AND
	RES_ADJ.ADJUSTMENT_TYPE	(+)	=  'RESERVE'			AND
	RES_ADJ.PERIOD_COUNTER_CREATED  =
		COST_ADJ.PERIOD_COUNTER_CREATED
AND
	tDH.BOOK_TYPE_CODE = h_dist_source_book  AND
	tDH.ASSET_ID = TH.ASSET_ID AND
	tDH.TRANSACTION_HEADER_ID_IN = NVL(TH.SOURCE_TRANSACTION_HEADER_ID, TH.TRANSACTION_HEADER_ID) AND
	tDH.DISTRIBUTION_ID		=  COST_ADJ.DISTRIBUTION_ID
AND
	DHCC.CODE_COMBINATION_ID	=  tDH.CODE_COMBINATION_ID
--AND
--	fdh.book_type_code = h_dist_source_book  AND
--	fdh.asset_id = th.asset_id  AND
--	fdh.transaction_header_id_out = th.transaction_header_id
group by
	dhcc.code_combination_id,
  dp.period_name,
	decode(FAH.ASSET_TYPE,
	       	'CIP', FCB.CIP_COST_ACCT,
		FCB.ASSET_COST_ACCT),
	decode(FAH.ASSET_TYPE,
		'CIP', ' ',
		FCB.DEPRN_RESERVE_ACCT),
	fcb.category_id,
	decode(TAH.ASSET_TYPE,
	       	'CIP', TCB.CIP_COST_ACCT,
		TCB.ASSET_COST_ACCT),
	decode(TAH.ASSET_TYPE,
		'CIP', ' ',
		TCB.DEPRN_RESERVE_ACCT),
        	tcb.category_id,
	ad.asset_number, ad.description, ad.tag_number, ad.serial_number,
	ad.inventorial,
	th.transaction_header_id;


begin
  h_book := book;
  h_request_id := request_id;

  select fcr.last_update_login into h_login_id
  from fnd_concurrent_requests fcr
  where fcr.request_id = h_request_id;

  h_mesg_name := 'FA_REC_SQL_ACCT_FLEX';

  select accounting_flex_structure, distribution_source_book
  into h_acct_struct, h_dist_source_book
  from fa_book_controls
  where book_type_code = h_book;

  h_mesg_name := 'FA_FA_LOOKUP_IN_SYSTEM_CTLS';

  select category_flex_structure
  into h_cat_struct from fa_system_controls;

  h_mesg_name := 'FA_RX_SEGNUMS';

   fa_rx_shared_pkg.GET_ACCT_SEGMENT_NUMBERS (
   BOOK         => h_book,
   BALANCING_SEGNUM     => h_bal_seg,
   ACCOUNT_SEGNUM       => h_acct_seg,
   CC_SEGNUM            => h_cc_seg,
   CALLING_FN           => 'RECLASS');


  h_mesg_name := 'FA_DEPRN_SQL_DCUR';

  open reclass_lines;
  loop

    h_mesg_name := 'FA_DEPRN_SQL_FCUR';

    fetch reclass_lines into
	h_ccid,
	h_period_name,
	h_from_cost_acct,
	h_from_reserve_acct,
	h_from_category_id,
	h_to_cost_acct,
	h_to_reserve_acct,
	h_to_category_id,
	h_asset_number,
	h_description,
	h_tag_number,
	h_serial_number, h_inventorial,
	h_cost,
	h_reserve,
	h_thid;


    if (reclass_lines%NOTFOUND) then exit;  end if;

	h_mesg_name  := 'FA_RX_CONCAT_SEGS';
	h_flex_error := 'GL#';
	h_ccid_error := h_ccid;

        fa_rx_shared_pkg.concat_acct (
           struct_id => h_acct_struct,
           ccid => h_ccid,
           concat_string => h_concat_acct,
           segarray => h_acct_segs);

	h_flex_error := 'CAT#';
	h_ccid_error := h_to_category_id;

        fa_rx_shared_pkg.concat_category (
           struct_id => h_cat_struct,
           ccid => h_to_category_id,
           concat_string => h_concat_tcat,
           segarray => h_tcat_segs);

	h_flex_error := 'CAT#';
	h_ccid_error := h_from_category_id;

        fa_rx_shared_pkg.concat_category (
           struct_id => h_cat_struct,
           ccid => h_from_category_id,
           concat_string => h_concat_fcat,
           segarray => h_fcat_segs);

    h_mesg_name := 'FA_SHARED_INSERT_FAILED';

    insert into fa_reclass_rep_itf (
	request_id, company, cost_center, expense_acct,
	period_name, from_cost_acct, to_cost_acct, inventorial,
	from_reserve_acct, to_reserve_acct, from_category,
	to_category, asset_number, description, tag_number,
	serial_number, cost, reserve, transaction_header_id,
	created_by, creation_date, last_updated_by,
	last_update_date, last_update_login) values (
	request_id, h_acct_segs(h_bal_seg), h_acct_segs(h_cc_seg),
	h_acct_segs(h_acct_seg),
	h_period_name, h_from_cost_acct, h_to_cost_acct, h_inventorial,
	h_from_reserve_acct, h_to_reserve_acct, h_concat_fcat,
	h_concat_tcat, h_asset_number, h_description, h_tag_number,
	h_serial_number, h_cost, h_reserve, h_thid,
	user_id, sysdate, user_id, sysdate, h_login_id);

  end loop;

  h_mesg_name := 'FA_DEPRN_SQL_CCUR';

  close reclass_lines;

exception when others then
  if SQLCODE <> 0 then
    fa_Rx_conc_mesg_pkg.log(SQLERRM);
  end if;
  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name = 'FA_SHARED_INSERT_FAIL' then
	fnd_message.set_token('TABLE','FA_RECLASS_REP_ITF',FALSE);
  end if;
  if h_mesg_name = 'FA_RX_CONCAT_SEGS' then
        fnd_message.set_token('CCID',to_char(h_ccid_error),FALSE);
        fnd_message.set_token('FLEX_CODE',h_flex_error,FALSE);
  end if;

  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  retcode := 2;

end reclass;

END FARX_RC;

/
