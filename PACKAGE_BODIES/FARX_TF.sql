--------------------------------------------------------
--  DDL for Package Body FARX_TF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_TF" as
/* $Header: farxtfb.pls 120.6.12010000.3 2009/07/19 13:33:15 glchen ship $ */

  procedure transfers (
	book		varchar2,
	begin_period	varchar2,
	end_period	varchar2,
	request_id	number,
	user_id		number,
	retcode	 out nocopy number,
	errbuf	 out nocopy varchar2) is

  h_count		number;
  h_request_id		number;
  h_login_id		number;

  h_serial_number	varchar2(35);
  h_tag_number		varchar2(25);
  h_asset_number	varchar2(25);
  h_description		varchar2(80);
  h_to_ccid 		number;
  h_from_ccid 		number;
  h_cost_acct		varchar2(25);
  h_reserve_acct	varchar2(25);
  h_ytd_deprn		number;
  h_reserve		number;
  h_thid		number;
  h_to_from_flag	varchar2(1);
  h_to_location_id		number;
  h_from_location_id		number;
  h_to_emp_name		varchar2(240);
  h_to_emp_number		varchar2(30);
  h_from_emp_name		varchar2(240);
  h_from_emp_number		varchar2(30);
  h_trx_date		date;
  h_tfr_cost		number;
  h_tfr_reserve		number;
  h_tfr_units		number;
  h_mass_ref_id		number;
  h_inventorial		varchar2(3);

  h_concat_to_loc		varchar2(500);
  h_to_loc_segs		fa_rx_shared_pkg.Seg_Array;
  h_concat_from_loc		varchar2(500);
  h_from_loc_segs		fa_rx_shared_pkg.Seg_Array;

  h_concat_to_acct		varchar2(500);
  h_to_acct_segs		fa_rx_shared_pkg.Seg_Array;
  h_concat_from_acct		varchar2(500);
  h_from_acct_segs		fa_rx_shared_pkg.Seg_Array;
  h_bal_seg		number;
  h_cc_seg		number;
  h_acct_seg		number;

  h_acct_structure	number;
  h_loc_structure	number;

  h_period1_pod		date;
  h_period2_pcd		date;
  h_book		varchar2(30);

  h_asset_type          varchar2(15);

  h_mesg_name           varchar2(50);
  h_mesg_str            varchar2(2000);
  h_flex_error          varchar2(5);
  h_ccid_error          number;
  h_distid		number;
  h_asset		varchar2(15);

cursor transfer_lines is
SELECT
	ad.asset_number, ad.description,
	ad.serial_number, ad.tag_number, ad.inventorial,
	cb.deprn_reserve_acct,
	DECODE(AH.ASSET_TYPE, 'CIP', CB.CIP_COST_ACCT,
	       CB.ASSET_COST_ACCT) ,
--	dd.ytd_deprn, dd.deprn_reserve,
	TH.TRANSACTION_HEADER_ID, th.mass_reference_id,
	tdh.distribution_id,
		tascc.code_combination_id, fascc.code_combination_id,
		tloc.location_id, floc.location_id,
		temp.full_name, temp.employee_number,
		femp.full_name, femp.employee_number,
        	TH.TRANSACTION_DATE_ENTERED,
        ad.asset_type,
	SUM(CADJ.ADJUSTMENT_AMOUNT*
		DECODE(CADJ.DEBIT_CREDIT_FLAG,'CR',-1,'DR',1)),
	SUM(TDH.UNITS_ASSIGNED)
FROM
	fa_category_books	cb,
	fa_asset_history	ah,
	FA_LOCATIONS		TLOC, FA_LOCATIONS FLOC,
	PER_ALL_PEOPLE_F  Temp,
	PER_ALL_PEOPLE_F FEMP,
	FA_ADDITIONS                           AD,
	GL_CODE_COMBINATIONS	TASCC, GL_CODE_COMBINATIONS  FASCC,
--	fa_deprn_detail		dd,
	FA_DISTRIBUTION_HISTORY   TDH, FA_DISTRIBUTION_HISTORY FDH,
	FA_TRANSACTION_HEADERS  TH,
	FA_ADJUSTMENTS          CADJ
WHERE
	AH.ASSET_ID = TH.ASSET_ID AND
	TH.DATE_EFFECTIVE >= AH.DATE_EFFECTIVE AND
	TH.DATE_EFFECTIVE < NVL(AH.DATE_INEFFECTIVE,SYSDATE)
AND
	CB.CATEGORY_ID = AH.CATEGORY_ID AND
	CB.BOOK_TYPE_CODE = TH.BOOK_TYPE_CODE
AND
	TH.BOOK_TYPE_CODE		=  h_book   AND
	TH.TRANSACTION_TYPE_CODE 	=  'TRANSFER'			AND
	TH.DATE_EFFECTIVE	 >=  H_PERIOD1_POD AND
	TH.DATE_EFFECTIVE	 <=  nvl(H_PERIOD2_PCD,sysdate)
AND
	TH.TRANSACTION_HEADER_ID	=  TDH.TRANSACTION_HEADER_ID_IN	 AND
	TH.TRANSACTION_HEADER_ID	=  FDH.TRANSACTION_HEADER_ID_OUT
AND
	AD.ASSET_ID			=  TH.ASSET_ID
--AND	dd.asset_id			= dh.asset_id   and
--	dd.book_type_code		= dh.book_type_code and
--	dd.distribution_id		= dh.distribution_id and
--	dd.period_counter = (select max(dd1.period_counter) from
--				fa_deprn_detail dd1 where
--				dd1.distribution_id = dd.distribution_id
--				and dd1.book_type_code = dd.book_type_code
--				and dd1.asset_id = dd.asset_id)
AND
	FLOC.LOCATION_ID			=  FDH.LOCATION_ID  AND
	TLOC.LOCATION_ID			=  TDH.LOCATION_ID
AND
	Temp.person_id (+)			= Tdh.assigned_to
AND     TRUNC(SYSDATE) 	BETWEEN TEMP.EFFECTIVE_START_DATE(+) AND TEMP.EFFECTIVE_END_DATE(+)
AND     FEMP.PERSON_ID (+)			= FDH.ASSIGNED_TO
AND     TRUNC(SYSDATE) 	BETWEEN FEMP.EFFECTIVE_START_DATE(+) AND FEMP.EFFECTIVE_END_DATE(+)
AND
	TASCC.CODE_COMBINATION_ID	=  TDH.CODE_COMBINATION_ID  AND
	FASCC.CODE_COMBINATION_ID	=  FDH.CODE_COMBINATION_ID
AND
	CADJ.BOOK_TYPE_CODE		= h_book  AND
	CADJ.ASSET_ID			= TH.ASSET_ID AND
	CADJ.DISTRIBUTION_ID   		= TDH.DISTRIBUTION_ID AND
	CADJ.TRANSACTION_HEADER_ID	= TH.TRANSACTION_HEADER_ID AND
	CADJ.SOURCE_TYPE_CODE		= 'TRANSFER' AND
	CADJ.ADJUSTMENT_TYPE		in ('COST','CIP COST')
GROUP BY
	ad.asset_number, ad.description,
	ad.serial_number, ad.tag_number, ad.inventorial,
	cb.deprn_reserve_acct,
	DECODE(AH.ASSET_TYPE, 'CIP', CB.CIP_COST_ACCT,
	       CB.ASSET_COST_ACCT)  ,
--	dd.ytd_deprn, dd.deprn_reserve,
	TH.TRANSACTION_HEADER_ID,th.mass_reference_id,
	TDH.DISTRIBUTION_ID,
	tascc.code_combination_id, fascc.code_combination_id,
	tloc.location_id, floc.location_id,
	temp.full_name, temp.employee_number,
	femp.full_name, femp.employee_number,
	AD.ASSET_NUMBER, ad.description, ad.serial_number, ad.tag_number,
	TH.TRANSACTION_DATE_ENTERED,
        AD.asset_type;

cursor c_reserve is
	SELECT
	ad.asset_number,
	cb.deprn_reserve_acct,
        SUM(NVL(RADJ.ADJUSTMENT_AMOUNT,0) *
                DECODE(NVL(RADJ.DEBIT_CREDIT_FLAG,'CR'),'CR',1,'DR',-1) )
	FROM
	fa_category_books	cb,
	FA_ADDITIONS                           AD,
	FA_ASSET_HISTORY	AH,
	FA_TRANSACTION_HEADERS  TH,
	FA_ADJUSTMENTS RADJ
	WHERE
	AD.ASSET_ID = TH.ASSET_ID AND
	TH.ASSET_ID = AH.ASSET_ID
	AND
	TH.DATE_EFFECTIVE >= AH.DATE_EFFECTIVE AND
	TH.DATE_EFFECTIVE < NVL(AH.DATE_INEFFECTIVE,SYSDATE)
	AND
	CB.CATEGORY_ID = AH.CATEGORY_ID AND
	CB.BOOK_TYPE_CODE = TH.BOOK_TYPE_CODE
	AND
	TH.BOOK_TYPE_CODE		=  h_book  AND
	TH.TRANSACTION_TYPE_CODE 	=  'TRANSFER'			AND
	TH.DATE_EFFECTIVE	 >=  H_PERIOD1_POD AND
	TH.DATE_EFFECTIVE	 <=  nvl(H_PERIOD2_PCD,sysdate)
	AND
	RADJ.BOOK_TYPE_CODE		= h_book  AND
	RADJ.ASSET_ID			= TH.ASSET_ID AND
	radj.distribution_id		= h_distid and
	RADJ.TRANSACTION_HEADER_ID	= TH.TRANSACTION_HEADER_ID AND
	RADJ.SOURCE_TYPE_CODE		= 'TRANSFER'  AND
	RADJ.ADJUSTMENT_TYPE		= 'RESERVE'
	GROUP BY
	ad.asset_number,
	cb.deprn_reserve_acct;


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

  h_mesg_name := 'FA_FA_LOOKUP_IN_SYSTEM_CTLS';

  select location_flex_structure
  into h_loc_structure
  from fa_system_controls;

  h_mesg_name := 'FA_REC_SQL_ACCT_FLEX';

  select accounting_flex_structure
  into h_acct_structure
  from fa_book_controls
  where book_type_code = h_book;

   h_mesg_name := 'FA_RX_SEGNUMS';

   fa_rx_shared_pkg.GET_ACCT_SEGMENT_NUMBERS (
   BOOK         => h_book,
   BALANCING_SEGNUM     => h_bal_seg,
   ACCOUNT_SEGNUM       => h_acct_seg,
   CC_SEGNUM            => h_cc_seg,
   CALLING_FN           => 'ADD_BY_PERIOD');

  h_count := 0;

  h_mesg_name := 'FA_DEPRN_SQL_DCUR';

  open transfer_lines;
  loop

    h_mesg_name := 'FA_DEPRN_SQL_FCUR';

    fetch transfer_lines into
	  h_asset_number,
	  h_description,
	  h_serial_number,
	  h_tag_number, h_inventorial,
	  h_reserve_acct,
	  h_cost_acct,
--	  h_ytd_deprn,
--	  h_reserve,
	  h_thid,
	  h_mass_ref_id,
	  h_distid,
	  h_to_ccid, h_from_ccid,
	  h_to_location_id, h_from_location_id,
	  h_to_emp_name,  h_to_emp_number,
	  h_from_emp_name,  h_from_emp_number,
	  h_trx_date,
          h_asset_type,
	  h_tfr_cost,
	  h_tfr_units;

    if (transfer_lines%NOTFOUND) then exit;  end if;
    h_count := h_count + 1;

	h_mesg_name := 'FA_RX_CONCAT_SEGS';
	h_flex_error := 'GL#';
	h_ccid_error := h_to_ccid;

        fa_rx_shared_pkg.concat_acct (
           struct_id => h_acct_structure,
           ccid => h_to_ccid,
           concat_string => h_concat_to_acct,
           segarray => h_to_acct_segs);

        h_flex_error := 'LOC#';
        h_ccid_error := h_to_location_id;

        fa_rx_shared_pkg.concat_location (
           struct_id => h_loc_structure,
           ccid => h_to_location_id,
           concat_string => h_concat_to_loc,
           segarray => h_to_loc_segs);

	h_flex_error := 'GL#';
	h_ccid_error := h_from_ccid;

        fa_rx_shared_pkg.concat_acct (
           struct_id => h_acct_structure,
           ccid => h_from_ccid,
           concat_string => h_concat_from_acct,
           segarray => h_from_acct_segs);

        h_flex_error := 'LOC#';
        h_ccid_error := h_from_location_id;

        fa_rx_shared_pkg.concat_location (
           struct_id => h_loc_structure,
           ccid => h_from_location_id,
           concat_string => h_concat_from_loc,
           segarray => h_from_loc_segs);


	open c_reserve;
	fetch c_reserve into h_asset, h_reserve_acct, 	  h_tfr_reserve;
	close c_reserve;


      insert into fa_transfer_rep_itf (
	request_id, asset_number, description, serial_number, tag_number,
	to_company, to_cost_center, to_expense_acct,
	from_company, from_cost_center, from_expense_acct,
	reserve_acct, cost_acct, inventorial,
	transaction_header_id, mass_transfer_id, to_location, from_location,
	transaction_date, to_employee_name, to_employee_number,
	from_employee_name, from_employee_number,
	cost_transferred, reserve_transferred, units_transferred,
	created_by, creation_date, last_updated_by, last_update_date,
	last_update_login, asset_type)
	values (request_id, h_asset_number, h_description, h_serial_number,
	h_tag_number,
	h_to_acct_segs(h_bal_seg), h_to_acct_segs(h_cc_seg),
	h_to_acct_segs(h_acct_seg), h_from_acct_segs(h_bal_seg),
	h_from_acct_segs(h_cc_seg), h_from_acct_segs(h_acct_seg),
	h_reserve_acct, h_cost_acct, h_inventorial, h_thid, h_mass_ref_id,
	h_concat_to_loc, h_concat_from_loc, h_trx_date,
	h_to_emp_name, h_to_emp_number, h_from_emp_name, h_from_emp_number,
	h_tfr_cost, h_tfr_reserve, h_tfr_units,
	user_id, sysdate, user_id, sysdate, h_login_id, h_asset_type);




  end loop;

  h_mesg_name := 'FA_DEPRN_SQL_CCUR';

  close transfer_lines;

exception when others then
  if SQLCODE <> 0 then
    fa_Rx_conc_mesg_pkg.log(SQLERRM);
  end if;

  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name = 'FA_SHARED_INSERT_FAIL' then
	fnd_message.set_token('TABLE','FA_TRANSFER_REP_ITF',FALSE);
  end if;
  if h_mesg_name = 'FA_RX_CONCAT_SEGS' then
        fnd_message.set_token('CCID',to_char(h_ccid_error),FALSE);
        fnd_message.set_token('FLEX_CODE',h_flex_error,FALSE);
  end if;

  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  retcode := 2;

end transfers;

END FARX_TF;

/
