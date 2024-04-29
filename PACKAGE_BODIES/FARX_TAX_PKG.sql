--------------------------------------------------------
--  DDL for Package Body FARX_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_TAX_PKG" as
/* $Header: farxptb.pls 120.5.12010000.2 2009/07/19 13:42:36 glchen ship $ */

  procedure property_tax(
	book		in 	varchar2,
	end_date	in 	date,
        segment1	in      varchar2,
        segment2	in      varchar2,
        segment3	in      varchar2,
        segment4	in      varchar2,
        segment5	in      varchar2,
        segment6	in      varchar2,
        segment7	in      varchar2,
        property_type	in      varchar2,
        company		in      varchar2,
        cost_center	in      varchar2,
        cost_account	in      varchar2,
	request_id	in 	number,
	user_id		in 	number,
 	retcode	 out nocopy varchar2,
	errbuf	 out nocopy varchar2) is

  h_login_id		number;
  h_asset_number	varchar2(25);
  h_serial_number	varchar2(35);
  h_tag_number		varchar2(15);
  h_description		varchar2(80);
  h_inventorial		varchar2(3);

  h_concat_loc		varchar2(500);
  h_concat_cat          varchar2(500);
  h_concat_key		varchar2(500);
  h_loc_segs		fa_rx_shared_pkg.Seg_Array;
  h_cat_segs            fa_rx_shared_pkg.Seg_Array;
  h_key_segs		fa_rx_shared_pkg.Seg_Array;

  h_state_loc		varchar2(50);

  h_state_seg	        number;

  h_concat_acct		varchar2(500);
  h_acct_segs		fa_rx_shared_pkg.Seg_Array;

  h_bal_seg		number;
  h_cc_seg		number;
  h_acct_seg		number;

  h_acct_structure	number;
  h_loc_structure	number;
  h_cat_structure       number;
  h_key_structure	number;

  h_book		varchar2(30);
  h_state		varchar2(30);
  h_end_date		date;
  h_segment1		varchar2(30);
  h_segment2		varchar2(30);
  h_segment3		varchar2(30);
  h_segment4		varchar2(30);
  h_segment5		varchar2(30);
  h_segment6		varchar2(30);
  h_segment7		varchar2(30);
  h_property_type	varchar2(10);
  h_cost_center		varchar2(30);
  h_company		varchar2(30);
  h_cost_account	varchar2(25);

  h_period_ctr		number;
  h_request_id 		number;
  h_segment_num		number;

Cursor c1 is
     SELECT bc.book_type_code,
            bc.accounting_flex_structure,
            sob.currency_code,
            cur.precision,
	    dp.period_counter
       FROM fa_book_controls bc,
            gl_sets_of_books sob,
            fnd_currencies cur,
	    fa_deprn_periods dp
      WHERE bc.book_type_code = h_book
        AND bc.date_ineffective is null
        AND sob.set_of_books_id = bc.set_of_books_id
        AND sob.currency_code = cur.currency_code
	AND dp.book_Type_code = h_book
	AND h_end_Date between dp.period_open_date and
		nvl(dp.period_close_date,h_end_date+1);
c1rec c1%rowtype;

Cursor c_main is
    SELECT lo.location_id,
	   comcc.code_combination_id,  /* comcc.segment1 company, */
	   bk.book_type_code,
	   cb.asset_cost_acct,
 	   to_char(bk.date_placed_in_service, 'YYYY') year,
 	   ad.asset_number,
 	   ad.tag_number, ad.serial_number,
 	   ad.description, ad.inventorial,
 	   lpad(to_char(sum(di.units_assigned)),6)  units,
 	   bk.date_placed_in_service ,
 	   round(sum(bk.cost *
 	   (di.units_assigned/ah.units/*ad.current_units bugfix 3591282*/)),c1rec.precision) cost,
           lo.segment1,
           lo.segment2,
           lo.segment3,
           lo.segment4,
           lo.segment5,
           lo.segment6,
           lo.segment7,
           fc.category_id,
	   ad.property_type_code,
	   ad.asset_key_ccid
      FROM fa_system_controls sc,
           fa_locations lo,
           fa_books     bk,
           fa_asset_history ah,
           fa_additions ad,
           fa_distribution_history  di,
           gl_Code_combinations   comcc,
           fa_category_books        cb,
           fa_book_controls         bc,
           fa_categories	      fc
     WHERE
       bk.book_type_code = h_book
       AND bk.asset_id = ad.asset_id
       AND ah.asset_id = ad.asset_id
       AND ah.category_id = cb.category_id
       AND cb.book_type_code= bk.book_type_code
       AND bc.book_type_code = bk.book_type_code
       and di.book_type_code = bc.distribution_source_book
       AND di.location_id = lo.location_id
       AND di.asset_id = bk.asset_id
       AND di.code_combination_id= comcc.code_combination_id
       AND ad.asset_category_id = fc.category_id
       AND cb.asset_cost_acct= nvl(h_cost_account, cb.asset_cost_acct)
       AND nvl(bk.period_counter_fully_retired, c1rec.period_counter+1) >=                                                  c1rec.period_counter
       AND nvl(lo.segment1,0) = nvl(h_segment1, nvl(lo.segment1, 0))
       AND nvl(lo.segment2,0) = nvl(h_segment2, nvl(lo.segment2, 0))
       AND nvl(lo.segment3,0) = nvl(h_segment3, nvl(lo.segment3, 0))
       AND nvl(lo.segment4,0) = nvl(h_segment4, nvl(lo.segment4, 0))
       AND nvl(lo.segment5,0) = nvl(h_segment5, nvl(lo.segment5, 0))
       AND nvl(lo.segment6,0) = nvl(h_segment6, nvl(lo.segment6, 0))
       AND nvl(lo.segment7,0) = nvl(h_segment7, nvl(lo.segment7, 0))
       AND ad.property_type_code = nvl(h_property_type, ad.property_type_code)
       AND ad.owned_leased = 'OWNED'
       AND h_end_date between bk.date_effective and nvl(bk.date_ineffective,sysdate)
       AND h_end_date between ah.date_effective and nvl(ah.date_ineffective,sysdate)
       AND di.transaction_header_id_in <=
                           (select max(th.transaction_header_id)
                             from fa_transaction_headers  th
                            where th.asset_id  =  di.asset_id
                             AND th.book_type_code = di.book_type_code
                             AND th.date_effective <= h_end_date)
       AND (di.transaction_header_id_out >=
                           (select min(th.transaction_header_id)
                             from fa_transaction_headers  th
                            where th.asset_id = di.asset_id
                             AND th.book_type_code = di.book_type_code
                             AND th.date_effective > h_end_date)
               OR di.transaction_header_id_out is null)
     GROUP BY
	bk.book_type_code,
	comcc.code_combination_id,
	lo.location_id,
	lo.segment1,
	lo.segment2,
	lo.segment3,
	lo.segment4,
	lo.segment5,
	lo.segment6,
	lo.segment7,
	to_char(bk.date_placed_in_service, 'YYYY'),
	ad.property_type_code,
	cb.asset_cost_acct,
	fc.category_id,
	ad.asset_number, ad.tag_number, ad.serial_number,
	ad.description, ad.inventorial, ad.asset_key_ccid,
	bk.date_placed_in_service
     ORDER BY
	comcc.code_combination_id,
	lo.location_id,
	cb.asset_cost_acct,
	to_char(bk.date_placed_in_service, 'YYYY'),
	asset_number;
c_mainrec c_main%rowtype;


begin

  h_book		:= book;
  h_end_date		:= end_date;
  h_request_id		:= request_id;
  h_segment1		:= segment1;
  h_segment2		:= segment2;
  h_segment3		:= segment3;
  h_segment4		:= segment4;
  h_segment5		:= segment5;
  h_segment6		:= segment6;
  h_segment7		:= segment7;
  h_property_type	:= property_type;
  h_company		:= company;
  h_cost_center		:= cost_center;
  h_cost_account	:= cost_account;


  --dbms_output.enable (50000);

  select accounting_flex_structure, location_flex_structure, category_flex_structure, asset_key_flex_structure
  into h_acct_structure, h_loc_structure, h_cat_structure, h_key_structure
  from fa_book_controls bc, fa_system_controls
  where book_type_code = h_book;


  select fcr.last_update_login
  into   h_login_id
  from fnd_concurrent_requests fcr
  where fcr.request_id = h_request_id;

   fa_rx_shared_pkg.GET_ACCT_SEGMENT_NUMBERS (
   BOOK                 => h_book,
   BALANCING_SEGNUM     => h_bal_seg,
   ACCOUNT_SEGNUM       => h_acct_seg,
   CC_SEGNUM            => h_cc_seg,
   CALLING_FN           => 'PROPERTY_TAX');


   SELECT s.segment_num
     INTO h_segment_num
     FROM fnd_id_flex_segments s,
          fnd_segment_attribute_values sav,
          fnd_segment_attribute_types sat
    WHERE s.application_id = 140
      AND s.id_flex_code = 'LOC#'
      AND s.id_flex_num = h_loc_structure
      AND s.enabled_flag = 'Y'
      AND s.application_column_name = sav.application_column_name
      AND sav.application_id = 140
      AND sav.id_flex_code = 'LOC#'
      AND sav.id_flex_num = h_loc_structure
      AND sav.attribute_value = 'Y'
      AND sav.segment_attribute_type = sat.segment_attribute_type
      AND sat.application_id = 140
      AND sat.id_flex_code = 'LOC#'
      AND sat.unique_flag = 'Y'
      AND sat.segment_attribute_type = 'LOC_STATE';

   SELECT count(segment_num)
     INTO h_state_seg
     FROM fnd_id_flex_segments
    WHERE application_id = 140
      AND id_flex_code = 'LOC#'
      AND id_flex_num = 101
      AND enabled_flag = 'Y'
      AND segment_num <= h_segment_num;


  open c1;
  fetch c1 into c1rec;

  open c_main;
  loop
    fetch c_main into c_mainrec;

    if (c_main%NOTFOUND) then exit;  end if;

        fa_rx_shared_pkg.concat_acct (
           struct_id => h_acct_structure,
           ccid => c_mainrec.code_combination_id,
           concat_string => h_concat_acct,
           segarray => h_acct_segs);

        fa_rx_shared_pkg.concat_location (
           struct_id => h_loc_structure,
           ccid => c_mainrec.location_id,
           concat_string => h_concat_loc,
           segarray => h_loc_segs);

        fa_rx_shared_pkg.concat_category (
           struct_id => h_cat_structure,
           ccid => c_mainrec.category_id,
           concat_string => h_concat_cat,
           segarray => h_cat_segs);


        if c_mainrec.asset_key_ccid is not null then
           fa_rx_shared_pkg.concat_asset_key (
              struct_id => h_key_structure,
              ccid => c_mainrec.asset_key_ccid,
              concat_string => h_concat_key,
              segarray => h_key_segs);
	else
	   h_concat_key := '';
	end if;

  -- This restriction should really be in the mainselects where-clause,
  -- but due to historical limited functionality in pl/sql
  -- it has to be done like this.
  -- If you want to improve performance, remove this where
  -- and define a row that looks like this in the main query:
  -- lo.segment? = h_state
  -- The columnname segment? depends on what the qualifying statesegment
  -- has been defined to (usually segment1).

--dbms_output.put_line('cost account ' || h_acct_segs(h_acct_seg));


    if	h_acct_segs(h_bal_seg)  = nvl(h_company, h_acct_segs(h_bal_seg)) AND
        h_acct_segs(h_cc_seg)   = nvl(h_cost_center, h_acct_segs(h_cc_seg)) then

	insert into fa_proptax_rep_itf  (
 	request_id,
 	book_type_code,
 	location,
 	state  ,
 	company,
 	asset_cost_acct,
 	year,
 	date_placed_in_service,
 	asset_number, tag_number, serial_number,
 	description, inventorial,
 	units      ,
 	original_cost,
        cost_center,
        asset_category,
	asset_key,
        property_type,
        segment1,
        segment2,
        segment3,
        segment4,
        segment5,
        segment6,
        segment7,
 	created_by, creation_date, last_updated_by, last_update_date,
 	last_update_login)
 	values (
 	h_request_id,
 	c_mainrec.book_type_code,
 	h_concat_loc,
 	h_loc_segs(h_state_seg),
 	h_acct_segs(h_bal_seg),
 	c_mainrec.asset_cost_acct,
 	c_mainrec.year,
 	c_mainrec.date_placed_in_service ,
 	c_mainrec.asset_number,
	c_mainrec.tag_number,
	c_mainrec.serial_number,
 	c_mainrec.description, c_mainrec.inventorial,
 	c_mainrec.units,
 	c_mainrec.cost,
        h_acct_segs(h_cc_seg),
        h_concat_cat,
	h_concat_key,
        c_mainrec.property_type_code,
        c_mainrec.segment1,
        c_mainrec.segment2,
        c_mainrec.segment3,
        c_mainrec.segment4,
        c_mainrec.segment5,
        c_mainrec.segment6,
        c_mainrec.segment7,
	user_id, sysdate, user_id , sysdate, h_login_id);

    end if;

  end loop;
  close c_main;
close c1;

	errbuf := '';

end property_tax;

END FARX_TAX_PKG;

/
