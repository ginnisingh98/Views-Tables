--------------------------------------------------------
--  DDL for Package Body FARX_MAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_MAD" as
-- $Header: farxmdb.pls 120.6.12010000.3 2009/07/19 13:40:41 glchen ship $


procedure mass_additions
    (Book		in	varchar2
    ,Queue_Name		in	varchar2
    ,Request_id		in	number
    ,User_id		in	number
    ,retcode	 out nocopy varchar2
    ,errbuf	 out nocopy varchar2)
  is
    h_loc_structure		number;
    h_concat_loc		varchar2(500);
    h_loc_segs			fa_rx_shared_pkg.Seg_Array;
    h_bal_structure		number;
    h_concat_bal		varchar2(500);
    h_bal_segs			fa_rx_shared_pkg.Seg_Array;
    h_acct_structure		number;
    h_concat_acct		varchar2(500);
    h_acct_segs			fa_rx_shared_pkg.Seg_Array;
    h_cat_structure		number;
    h_concat_cat		varchar2(500);
    h_cat_segs			fa_rx_shared_pkg.Seg_Array;
    h_key_structure		number;
    h_concat_key		varchar2(500);
    h_key_segs			fa_rx_shared_pkg.Seg_Array;

    h_bal_seg			number;
    h_cc_seg			number;
    h_acct_seg			number;

    h_bal_seg_val               varchar2(25);
    h_cc_seg_val                varchar2(25);
    h_acct_seg_val              varchar2(25);

    h_login_id			number;
    h_request_id		number;
    h_book			    varchar2(15);
    h_queue_name		varchar2(30);
    h_posting_status		varchar2(30);

    h_currency			varchar2(15);
    h_precision			number;
    h_valid_vendor_id   number:=0;
    h_vendor_name		varchar2(240);

    h_mesg_name			varchar2(50);
    h_mesg_str			varchar2(2000);
    h_flex_error		varchar2(5);
    h_ccid_error		number;

cursor c_madd is
	select	fama.book_type_code,
	--	fama.queue_name,
                lkt1.meaning queue_name,   --for bug no.4091456
		fama.mass_addition_id,
	--	fama.posting_status,
                lkt2.meaning posting_status, -- for bug no.4091456
		fama.post_batch_id,
		fama.asset_number,
		fama.tag_number,
		fama.description,
		fama.asset_category_id,
		fama.location_id,
		fama.vendor_number,
		fama.po_vendor_id,
		fama.invoice_number,
		fama.invoice_date,
		fama.po_number,
		fama.ap_distribution_line_number,
		fama.expense_code_combination_id,
		fama.payables_batch_name,
		fama.payables_code_combination_id,
		fama.payables_cost,
		fama.payables_units,
		fama.fixed_assets_cost,
		fama.unit_of_measure,
		fama.reviewer_comments,
		fama.asset_key_ccid,
		facb.asset_clearing_acct,
		facb.asset_cost_acct,
		facb.asset_cost_account_ccid,
		facb.asset_clearing_account_ccid,
		facb.deprn_expense_acct,
		facb.deprn_reserve_acct,
		facd.deprn_method,
		facd.life_in_months,
		facd.basic_rate,
		facd.adjusted_rate,
		facd.production_capacity,
		facd.prorate_convention_code,
		apid.period_name,
		apin.invoice_currency_code,
		apin.payment_currency_code,
		apin.invoice_amount,
		apin.amount_paid,
		fama.feeder_system_name,
		--apin.source Bug 2345016
	      fama.asset_type,
	      gad.asset_number group_asset_number,
	      fama.invoice_distribution_id,
	      fama.invoice_line_number,
	      fama.po_distribution_id
	from	fa_mass_additions 	     	fama,
		fa_category_books 	     	facb,
		fa_category_book_defaults 	facd,
		fa_lookups_tl		        lkt1,
         	fa_lookups_tl             	lkt2,
		ap_invoices 		        apin,
		ap_invoice_distributions  	apid,
         	fa_additions_b            	gad
	where	fama.book_type_code	= h_book
	and	fama.queue_name		= lkt1.lookup_code
	and   lkt1.lookup_code like nvl(h_queue_name,'%') -- bug 2146763
	and   lkt1.lookup_type        = 'QUEUE NAME'
	and   userenv('lang')         = lkt1.language
	and   fama.posting_status     = lkt2.lookup_code
	and   lkt2.lookup_code like nvl(h_posting_status,'%')
	and   lkt2.lookup_type        = 'QUEUE NAME'
	and   userenv('lang')         = lkt2.language
	and   fama.invoice_id		= apin.invoice_id(+)
	and   fama.invoice_id         = apid.invoice_id(+)
	and   fama.invoice_distribution_id
              = apid.invoice_distribution_id (+) -- Bug 7524566
	and   fama.invoice_line_number
              = apid.invoice_line_number (+) -- Bug 7524566
	and   fama.asset_category_id	= facb.category_id(+)
	and   fama.book_type_code 	= facb.book_type_code(+)
	and   fama.asset_category_id	= facd.category_id(+)
	and   fama.book_type_code	= facd.book_type_code(+)
   	and   fama.group_asset_id     = gad.asset_id(+)
	ORDER BY fama.posting_status;
c_maddrec c_madd%rowtype;


BEGIN


  h_book 	:= book;
  h_request_id	:= request_id;

    --
  if queue_name is not null then

          If queue_name IN ('POSTED','DELETE','MERGED','SPLIT') Then
		 h_queue_name := '';
		 h_posting_status := queue_name;
          elsif queue_name IN ('NEW','POST','ON HOLD') then
		 h_queue_name := queue_name;
		 h_posting_status := queue_name;
	  else
		 h_queue_name := queue_name;
		 h_posting_status := '';
          end if;
  else
	  h_queue_name  	:= '';
	  h_posting_status  	:= '';

  end if;


--
	SELECT	last_update_login
	INTO	h_login_id
	FROM	FND_CONCURRENT_REQUESTS
	WHERE	request_id = h_request_id;

        h_mesg_name := 'FA_DYN_CURRENCY';

	SELECT	SOB.currency_code,
		CUR.precision
	INTO	h_currency,
		h_precision
	FROM	FA_BOOK_CONTROLS	BKC,
		GL_SETS_OF_BOOKS	SOB,
		FND_CURRENCIES		CUR
	WHERE	BKC.book_type_code = h_book
	AND	BKC.date_ineffective is null
	AND	SOB.set_of_books_id = BKC.set_of_books_id
	AND	SOB.currency_code = CUR.currency_code;

        h_mesg_name := 'FA_REC_SQL_ACCT_FLEX';

    	SELECT	SC.location_flex_structure,
		SC.category_flex_structure,
	 	SC.asset_key_flex_structure,
		BC.accounting_flex_structure
	INTO	h_loc_structure,
		h_cat_structure,
		h_key_structure,
		h_acct_structure
	FROM	FA_BOOK_CONTROLS BC,
		FA_SYSTEM_CONTROLS SC
	WHERE 	BC.book_type_code = h_book;

   h_mesg_name := 'FA_RX_SEGNUMS';

   fa_rx_shared_pkg.GET_ACCT_SEGMENT_NUMBERS (
     BOOK                 => h_book,
     BALANCING_SEGNUM     => h_bal_seg,
     ACCOUNT_SEGNUM       => h_acct_seg,
     CC_SEGNUM            => h_cc_seg,
     CALLING_FN           => 'MASS_ADDITION');

  h_mesg_name := 'FA_DEPRN_SQL_DCUR';

  open c_madd;
  loop

    h_mesg_name := 'FA_DEPRN_SQL_FCUR';

    fetch c_madd into c_maddrec;

    if (c_madd%NOTFOUND) then
       exit;
    end if;

    h_mesg_name := 'FA_RX_CONCAT_SEGS';
    h_concat_cat := '';--bug 3460689 fix
    if (c_maddrec.payables_code_combination_id is not null) then
      h_flex_error := 'GL#';
      h_ccid_error := c_maddrec.payables_code_combination_id;

      fa_rx_shared_pkg.concat_acct (
	struct_id => h_acct_structure,
	ccid => c_maddrec.payables_code_combination_id,
	concat_string => h_concat_acct,
	segarray => h_acct_segs);

      h_bal_seg_val  := h_acct_segs(h_bal_seg);
      h_cc_seg_val   := h_acct_segs(h_cc_seg);
      h_acct_seg_val := h_acct_segs(h_acct_seg);
    else
      h_bal_seg_val  := null;
      h_cc_seg_val   := null;
      h_acct_seg_val := null;
    end if;

    if (c_maddrec.location_id is not null) then
      h_flex_error := 'LOC#';
      h_ccid_error := c_maddrec.location_id;

      fa_rx_shared_pkg.concat_location (
	struct_id => h_loc_structure,
	ccid => c_maddrec.location_id,
	concat_string => h_concat_loc,
	segarray => h_loc_segs);
    end if;


    if (c_maddrec.asset_category_id is not null) then
      h_flex_error := 'CAT#';
      h_ccid_error := c_maddrec.asset_category_id;

      fa_rx_shared_pkg.concat_category (
	struct_id => h_cat_structure,
	ccid => c_maddrec.asset_category_id,
	concat_string => h_concat_cat,
	segarray => h_cat_segs);
    end if;


    if (c_maddrec.asset_key_ccid is not null) then
      h_flex_error := 'KEY#';
      h_ccid_error := c_maddrec.asset_key_ccid;

      fa_rx_shared_pkg.concat_asset_key (
	struct_id => h_key_structure,
	ccid => c_maddrec.asset_key_ccid,
	concat_string => h_concat_key,
	segarray => h_key_segs);
    end if;


    if (c_maddrec.po_vendor_id is not null) then

	   h_mesg_name := 'FA_FE_LOOKUP_IN_PO_VENDORS';
     /* -- To avoid issues such as 3189133.  Need to check if
        -- po_vendor_id is not an invalid value; i.e., in the case of legacy data. */
       SELECT count(1)
       INTO   h_valid_vendor_id
       from	  PO_VENDORS
       where  vendor_id = c_maddrec.po_vendor_id;

       if h_valid_vendor_id > 0 then
	      SELECT	vendor_name
	      into	h_vendor_name
	      from	PO_VENDORS
	      where	vendor_id = c_maddrec.po_vendor_id;
       end if;

    end if;

    h_mesg_name := 'FA_SHARED_INSERT_FAILED';

    INSERT INTO FA_MASSADD_REP_ITF
	(REQUEST_ID
	,BOOK_TYPE_CODE
	,QUEUE_NAME
	,INVOICE_CURRENCY_CODE
	,PERIOD_NAME
	,ENTITY_NAME
	,TRANSACTION_TYPE
	,REPORT_DATE
	,MASS_ADDITION_ID
	,STATUS
	,POSTING_STATUS
	,POST_BATCH_ID
	,ASSET_NUMBER
	,TAG_NUMBER
	,DESCRIPTION
	,ASSET_CATEGORY_ID
	,CATEGORY
	,AP_COMPANY
	,COMPANY_NAME
	,ASSET_CLEARING_ACCT
	,ASSET_COST_ACCOUNT
	,ASSET_COST_ACCOUNT_CCID
	,ASSET_CLEARING_ACCT_CCID
	,DEPRN_EXPENSE_ACCT
	,DEPRN_RESERVE_ACCT
	,COST_CENTER
	,EXPENSE_ACCT
	,LOCATION_ID
	,LOCATION
	,VENDOR_NUMBER
	,VENDOR_NAME
	,INVOICE_NUMBER
	,INVOICE_DATE
	,SOURCE_SYSTEMS
	,PO_NUMBER
	,AP_DISTRIBUTION_LINE_NUMBER
	,PAYABLES_BATCH_NAME
	,PAYABLES_CODE_COMBINATION_ID
	,PAYABLES_COST
	,PAYABLES_UNITS
	,FIXED_ASSETS_COST
	,FOREIGN_CURRENCY_CODE
	,FOREIGN_CURRENCY_AMOUNT
	,REVIEWER_COMMENTS
	,DEPRN_METHOD
	,LIFE_IN_MONTHS
	,BASIC_RATE
	,ADJUSTED_RATE
	,PRODUCTION_CAPACITY
	,UNIT_OF_MEASURE
	,PRORATE_CONVENTION
	,LAST_UPDATED_BY
	,LAST_UPDATE_LOGIN
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATE_DATE
   ,ASSET_TYPE
   ,GROUP_ASSET_NUMBER
   ,INVOICE_DISTRIBUTION_ID
   ,INVOICE_LINE_NUMBER
   ,PO_DISTRIBUTION_ID )
    VALUES
	(h_request_id
	,c_maddrec.book_type_code
	,c_maddrec.queue_name
	,c_maddrec.invoice_currency_code
	,c_maddrec.period_name
	,'ENTITY_NAME'
	,'TRANSACTION_TYPE'
	,sysdate
	,c_maddrec.mass_addition_id
	,c_maddrec.posting_status
	,c_maddrec.posting_status
	,c_maddrec.post_batch_id
	,c_maddrec.asset_number
	,c_maddrec.tag_number
	,c_maddrec.description
	,c_maddrec.asset_category_id
	,h_concat_cat
	,h_bal_seg_val
	,h_bal_seg_val
	,c_maddrec.asset_clearing_acct
	,c_maddrec.asset_cost_acct
	,c_maddrec.asset_cost_account_ccid
	,c_maddrec.asset_clearing_account_ccid
	,c_maddrec.deprn_expense_acct
	,c_maddrec.deprn_reserve_acct
	,h_cc_seg_val
	,h_acct_seg_val
	,c_maddrec.location_id
	,h_concat_loc
	,c_maddrec.vendor_number
	,h_vendor_name
	,c_maddrec.invoice_number
	,c_maddrec.invoice_date
	,c_maddrec.feeder_system_name
	,c_maddrec.po_number
	,c_maddrec.ap_distribution_line_number
	,c_maddrec.payables_batch_name
	,c_maddrec.payables_code_combination_id
	,c_maddrec.payables_cost
	,c_maddrec.payables_units
	,c_maddrec.fixed_assets_cost
	,c_maddrec.payment_currency_code
	,c_maddrec.amount_paid
	,c_maddrec.reviewer_comments
	,c_maddrec.deprn_method
	,c_maddrec.life_in_months
	,c_maddrec.basic_rate
	,c_maddrec.adjusted_rate
	,c_maddrec.production_capacity
	,c_maddrec.unit_of_measure
	,c_maddrec.prorate_convention_code
	,user_id
	,h_login_id
	,user_id
	,sysdate
	,sysdate
   ,c_maddrec.asset_type
   ,c_maddrec.group_asset_number
   ,c_maddrec.invoice_distribution_id
   ,c_maddrec.invoice_line_number
   ,c_maddrec.po_distribution_id );

  end loop;

  h_mesg_name := 'FA_DEPRN_SQL_CCUR';

  close c_madd;

exception when others then
  if SQLCODE <> 0 then
    fa_Rx_conc_mesg_pkg.log(SQLERRM);
  end if;
  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name = 'FA_SHARED_INSERT_FAIL' then
	fnd_message.set_token('TABLE','FA_MASSADD_REP_ITF',FALSE);
  end if;
  if h_mesg_name = 'FA_RX_CONCAT_SEGS' then
        fnd_message.set_token('CCID',to_char(h_ccid_error),FALSE);
        fnd_message.set_token('FLEX_CODE',h_flex_error,FALSE);
  end if;

  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  retcode := 2;

end mass_additions;

END FARX_MAD;

/
