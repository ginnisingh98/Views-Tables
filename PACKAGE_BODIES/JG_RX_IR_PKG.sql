--------------------------------------------------------
--  DDL for Package Body JG_RX_IR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_RX_IR_PKG" as
/* $Header: jgrxpirb.pls 120.13.12010000.4 2009/12/01 05:00:38 gkumares ship $ */
procedure ap_rx_invoice_run (
 	errbuf			out nocopy	varchar2,
  	retcode			out nocopy	number,
	p_request_id		in	number,
	p_login_id		in	number,
        p_reporting_level       in      varchar2,
        p_reporting_entity_id   in      number,
	p_set_of_book_id	in	number,
	p_chart_of_acct_id	in	number,
	p_line_inv		in	varchar2,
	p_acct_date_min		in	date,
	p_acct_date_max		in	date,
	p_batch_id		in	number,
	p_invoice_type		in	varchar2,
	p_entry_person_id	in	number,
	p_doc_sequence_id	in	number,
	p_doc_sequence_value_min	in	number,
	p_doc_sequence_value_max	in	number,
	p_supplier_min		in	varchar2,
	p_supplier_max		in	varchar2,
	p_liability_min		in	varchar2,
	p_liability_max		in	varchar2,
	p_dist_acct_min		in	varchar2,
	p_dist_acct_max		in	varchar2,
	p_inv_currency_code	in	varchar2,
	p_dist_amount_min	in	number,
	p_dist_amount_max	in	number,
	p_entered_date_min	in	date,
	p_entered_date_max	in	date,
	p_cancelled_inv		in	varchar2,
	p_unapproved_inv	in	varchar2
) is

	/* Dummy parameters */
	h_cancelled_inv         BOOLEAN;
        h_unapproved_inv        BOOLEAN;
begin

  h_cancelled_inv := FALSE;
  h_unapproved_inv := FALSE;

  if nvl(p_cancelled_inv,'N') = 'Y' then
     h_cancelled_inv := TRUE;
  end if;

  if nvl(p_unapproved_inv,'N') = 'Y' then
     h_unapproved_inv := TRUE;
  end if;

  -- Call main procedure
   JG_RX_IR_PKG.AP_RX_INVOICE_RUN (
	errbuf				=> errbuf,
	retcode				=> retcode,
	p_request_id			=> p_request_id,
	p_login_id			=> p_login_id,
        p_reporting_level               => p_reporting_level,
        p_reporting_entity_id           => p_reporting_entity_id,
	p_set_of_book_id		=> p_set_of_book_id,
	p_chart_of_acct_id		=> p_chart_of_acct_id,
	p_line_inv			=> p_line_inv,
	p_acct_date_min			=> p_acct_date_min,
	p_acct_date_max			=> p_acct_date_max,
	p_batch_id			=> p_batch_id,
	p_invoice_type			=> p_invoice_type,
	p_entry_person_id		=> p_entry_person_id,
	p_doc_sequence_id		=> p_doc_sequence_id,
	p_doc_sequence_value_min	=> p_doc_sequence_value_min,
	p_doc_sequence_value_max	=> p_doc_sequence_value_max,
	p_supplier_min			=> p_supplier_min,
	p_supplier_max			=> p_supplier_max,
	p_liability_min			=> p_liability_min,
	p_liability_max			=> p_liability_max,
	p_dist_acct_min			=> p_dist_acct_min,
	p_dist_acct_max			=> p_dist_acct_max,
	p_inv_currency_code		=> p_inv_currency_code,
	p_dist_amount_min		=> p_dist_amount_min,
	p_dist_amount_max		=> p_dist_amount_max,
	p_entered_date_min		=> p_entered_date_min,
	p_entered_date_max		=> p_entered_date_max,
	p_cancelled_inv			=> h_cancelled_inv,
	p_unapproved_inv		=> h_unapproved_inv
   );


end;

procedure ap_rx_invoice_run (
 	errbuf			out nocopy	varchar2,
  	retcode			out nocopy	number,
	p_request_id		in	number,
	p_login_id		in	number,
        p_reporting_level       in      varchar2,
        p_reporting_entity_id   in      number,
	p_set_of_book_id	in	number,
	p_chart_of_acct_id	in	number,
	p_line_inv		in	varchar2,
	p_acct_date_min		in	date,
	p_acct_date_max		in	date,
	p_batch_id		in	number,
	p_invoice_type		in	varchar2,
	p_entry_person_id	in	number,
	p_doc_sequence_id	in	number,
	p_doc_sequence_value_min	in	number,
	p_doc_sequence_value_max	in	number,
	p_supplier_min		in	varchar2,
	p_supplier_max		in	varchar2,
	p_liability_min		in	varchar2,
	p_liability_max		in	varchar2,
	p_dist_acct_min		in	varchar2,
	p_dist_acct_max		in	varchar2,
	p_inv_currency_code	in	varchar2,
	p_dist_amount_min	in	number,
	p_dist_amount_max	in	number,
	p_entered_date_min	in	date,
	p_entered_date_max	in	date,
	p_cancelled_inv		in	boolean,
	p_unapproved_inv	in	boolean
) is

	/* Dummy parameters */
	l_start_date			date;
	l_end_date			date;


	/*Dynamic SQL */
	v_MainCursor			number;
	v_MainReturn			number;
	v_MainFetch			number;

	l_main_sql			varchar2(10000);
	l_acct_date_where		varchar2(100);
	l_entry_person_where		varchar2(100);
	l_inv_type_where		varchar2(100);
	l_batch_id_where		varchar2(100);
	l_doc_seq_id_where		varchar2(100);
	l_doc_seq_value_where		varchar2(100);
	l_supplier_where		varchar2(300);
	l_liability_range_where		varchar2(1000);
	l_dist_acct_range_where		varchar2(1000);
	l_inv_currency_code_where	varchar2(100);
	l_dist_amount_range_where	varchar2(100);
	l_entered_date_where		varchar2(100);
	l_cancelled_where		varchar2(100);
	l_unapproved_inv_where		varchar2(100);
	l_line_inv_where		varchar2(30000);

	/* Fetched Variables */
	h_invoice_id			number;
	h_liability_ccid		number;
	h_invoice_type			varchar2(25);
	h_inv_dist_id			number;
	h_line_number			number;
	h_line_type			varchar2(25);
	h_dist_ccid			number;

	/* Added for AP Invoice Line project */
	h_dist_number			number;
	h_dist_type			varchar2(25);
	h_dist_acct_date		date;

	h_liability_acct		varchar2(2000);
	h_liability_desc		varchar2(2000);
	h_liability_natacct		varchar2(2000);
	h_liability_natdesc		varchar2(2000);
	h_dist_acct			varchar2(2000);
	h_dist_desc			varchar2(2000);
	h_dist_natacct			varchar2(2000);
	h_dist_natdesc			varchar2(2000);

	h_currency_code			varchar2(15);
	h_book_short_name		varchar2(20);
        /* R11.5.10 - MRC schema drop support */
        h_mrc_sob_type_code             varchar2(30);
        l_main_from                     varchar2(500);

	/* Sort Option */
	h_sort_by_alternate             VARCHAR2(1);

        /* Added for MOAC change */
        h_reporting_level               VARCHAR2(30);
        h_reporting_entity_id           NUMBER;

        p_inv_org_where                 VARCHAR2(2000);
        p_dist_org_where                VARCHAR2(2000);
        p_line_org_where                VARCHAR2(2000);

begin

	fa_rx_util_pkg.enable_debug;


	fa_rx_util_pkg.log('***** START JG_RX_IR_PKG.AP_RX_INVOICE_RUN *****');

	/* Print debug parameters */
	fa_rx_util_pkg.log('p_reporting_level :'||p_reporting_level);
	fa_rx_util_pkg.log('p_reporting_entity_id :'||p_reporting_entity_id);
	fa_rx_util_pkg.log('p_request_id :'||p_request_id);
	fa_rx_util_pkg.log('p_login_id :'||p_login_id);
	fa_rx_util_pkg.log('p_set_of_book_id :'||p_set_of_book_id);
	fa_rx_util_pkg.log('p_chart_of_acct_id :'||p_chart_of_acct_id);
	fa_rx_util_pkg.log('p_line_inv :'||p_line_inv);
	fa_rx_util_pkg.log('p_acct_date_min :'||p_acct_date_min);
	fa_rx_util_pkg.log('p_acct_date_max :'||p_acct_date_max);
	fa_rx_util_pkg.log('p_batch_id :'||p_batch_id);
	fa_rx_util_pkg.log('p_invoice_type :'||p_invoice_type);
	fa_rx_util_pkg.log('p_entry_person :'||p_entry_person_id);
	fa_rx_util_pkg.log('p_doc_sequence_name :'||p_doc_sequence_id);
	fa_rx_util_pkg.log('p_doc_sequence_value_min :'||p_doc_sequence_value_min);
	fa_rx_util_pkg.log('p_doc_sequence_value_max :'||p_doc_sequence_value_max);
	fa_rx_util_pkg.log('p_supplier_min :'||p_supplier_min);
	fa_rx_util_pkg.log('p_supplier_max :'||p_supplier_max);
	fa_rx_util_pkg.log('p_liability_min :'||p_liability_min);
	fa_rx_util_pkg.log('p_liability_max :'||p_liability_max);
	fa_rx_util_pkg.log('p_dist_acct_min :'||p_dist_acct_min);
	fa_rx_util_pkg.log('p_dist_acct_max :'||p_dist_acct_max);
	fa_rx_util_pkg.log('p_dist_amount_min :'||p_dist_amount_min);
	fa_rx_util_pkg.log('p_dist_amount_max :'||p_dist_amount_max);
	fa_rx_util_pkg.log('p_entered_date_min :'||p_entered_date_min);
	fa_rx_util_pkg.log('p_entered_date_max :'||p_entered_date_max);

        /* Added for MOAC change */
        if p_reporting_level is null then
          h_reporting_level := '3000'; -- OU level
--Bug 5591940
--          h_reporting_entity_id := fnd_profile.value('DEFAULT_ORG_ID'); -- Set default OU.
	    h_reporting_entity_id := MO_GLOBAL.get_current_org_id;

        else
          h_reporting_level := p_reporting_level;
          if p_reporting_entity_id is null then
            h_reporting_level := '3000';
--Bug 5591940
--            h_reporting_entity_id := fnd_profile.value('DEFAULT_ORG_ID'); -- Set default OU
	      h_reporting_entity_id := MO_GLOBAL.get_current_org_id;
          else
            h_reporting_entity_id := p_reporting_entity_id;
          end if;
        end if;

        --* Call XLA_MO_REPORTING_API
        --* Initialize
        XLA_MO_REPORTING_API.INITIALIZE(p_reporting_level     => h_reporting_level,
                                        p_reporting_entity_id => h_reporting_entity_id);

        --* Get Precidcate for following tables.
        --* AP_INVOICES_ALL (Alias = INV)
        p_inv_org_where := XLA_MO_REPORTING_API.GET_PREDICATE(p_alias => 'AP_INV');
        --* AP_INVOICE_DISTRIBUTIONS_ALL (Alias = DIST)
        p_dist_org_where := XLA_MO_REPORTING_API.GET_PREDICATE(p_alias => 'DIST');
        --* AP_INVOICE_LINES_ALL (Alias = INV_LINE)
        p_line_org_where := XLA_MO_REPORTING_API.GET_PREDICATE(p_alias => 'INV_LINE');

	fa_rx_util_pkg.debug('p_inv_org_where :'||p_inv_org_where);
	fa_rx_util_pkg.debug('p_dist_org_where :'||p_dist_org_where);
	fa_rx_util_pkg.debug('p_line_org_where :'||p_line_org_where);

	/*Get Functoinal currncy code */
	Select 	currency_code,
		short_name,
                alc_ledger_type_code
	into	h_currency_code,
		h_book_short_name,
                h_mrc_sob_type_code
	From	GL_LEDGERS
	where	ledger_id = p_set_of_book_id;

	fa_rx_util_pkg.debug('h_currency_code :'||h_currency_code);
	fa_rx_util_pkg.debug('h_book_short_name :'||h_book_short_name);
	fa_rx_util_pkg.debug('h_mrc_sob_type_code :'||h_mrc_sob_type_code);

        /* Switch User Context */
        if h_mrc_sob_type_code = 'R' then
           fnd_client_info.set_currency_context(p_set_of_book_id);
        end if;
        /* End Switch User Context */

	/* Get Sort By Alternate Option - Now this profile is moved to AP_SYSTEM_PARAMETERS table
	if (nvl(fnd_profile.value('AP_SORT_BY_ALTERNATE'), 'N')= 'Y') then
	  h_sort_by_alternate :='Y';
	ELSE
	  h_sort_by_alternate :='N';
	END IF;
	*/

	begin
          SELECT nvl(sort_by_alternate_field,'N') --Bug 5591940
          INTO   h_sort_by_alternate
          FROM   AP_SYSTEM_PARAMETERS;

        exception when others then
            h_sort_by_alternate := 'N';
        end;

	fa_rx_util_pkg.debug('h_sort_by_alternate :'||h_sort_by_alternate);

	/* ==================================================
	Create sql statement:
	From parameters, create sql statment
	================================================== */


	/* Accounting Date range*/
	if p_acct_date_min is null and p_acct_date_max is null then
		l_acct_date_where := to_char(null);
	elsif p_acct_date_min is not null and p_acct_date_max is null then
		l_acct_date_where := ' and DIST.ACCOUNTING_DATE >= :c_acct_date_min ';
	elsif p_acct_date_min is null and p_acct_date_max is not null then
		l_acct_date_where := ' and DIST.ACCOUNTING_DATE >= :c_acct_date_max ';
	else
		l_acct_date_where :=
			' and DIST.ACCOUNTING_DATE between :c_acct_date_min and :c_acct_date_max ';
	end if;

	fa_rx_util_pkg.debug('l_acct_date_where :'||l_acct_date_where);

	/* Entered by */
	if p_entry_person_id is null then
		l_entry_person_where := to_char(null);
	else
		l_entry_person_where := 'and AP_INV.CREATED_BY = :c_entry_person_id '; -- ||p_entry_person_id;
	end if;

	fa_rx_util_pkg.debug('l_entry_person_where :'||l_entry_person_where);

	/*Invoice Type */
	if p_invoice_type is null then
		l_inv_type_where := to_char(null);
	else
		l_inv_type_where :=
			' and AP_INV.INVOICE_TYPE_LOOKUP_CODE= :c_invoice_type '; -- '''||p_invoice_type||'''

	end if;

	fa_rx_util_pkg.debug('l_inv_type_where :'||l_inv_type_where);

	/* Batch ID */
	if p_batch_id is null then
		l_batch_id_where := to_char(null);
	else
		l_batch_id_where := ' and AP_INV.BATCH_ID = :c_batch_id '; -- '''||p_batch_id||'''

	end if;

	fa_rx_util_pkg.debug('l_batch_id_where :'||l_batch_id_where);

	/* Document Sequence Id */
	if p_doc_sequence_id is null then
		l_doc_seq_id_where := to_char(null);
	else
		l_doc_seq_id_where := ' and AP_INV.DOC_SEQUENCE_ID= :c_doc_sequence_id '; --||p_doc_sequence_id;
	end if;

	fa_rx_util_pkg.debug('l_doc_seq_id_where :'||l_doc_seq_id_where);

	/* Document Sequence value range */
	if p_doc_sequence_value_min is null and p_doc_sequence_value_max is null then
		l_doc_seq_value_where := to_char(null);
	elsif p_doc_sequence_value_min is not null and p_doc_sequence_value_max is null then
		l_doc_seq_value_where := ' and AP_INV.DOC_SEQUENCE_VALUE >= :c_doc_sequence_value_min ';
                                                                            -- '||p_doc_sequence_value_min;
	elsif p_doc_sequence_value_min is null and p_doc_sequence_value_max is not null then
		l_doc_seq_value_where := ' and AP_INV.DOC_SEQUENCE_VALUE <= :c_doc_sequence_value_max ';
                                                                            --'||p_doc_sequence_value_max;
	else
		l_doc_seq_value_where :=
			' and AP_INV.DOC_SEQUENCE_VALUE between :c_doc_sequence_value_min and :c_doc_sequence_value_max ';
                                            -- || p_doc_sequence_value_min||' and '||p_doc_sequence_value_max;
	end if;

	fa_rx_util_pkg.debug('l_doc_seq_value_where :'||l_doc_seq_value_where);

	/* Supplier name range */
	if p_supplier_min is null and p_supplier_max is null then
		l_supplier_where := to_char(null);
	elsif p_supplier_min is not null and p_supplier_max is null then
		l_supplier_where :=' and  PO_PV.VENDOR_NAME >= :c_supplier_min '; -- '''||p_supplier_min||''' ';
	elsif p_supplier_min is null and p_supplier_max is not null then
		l_supplier_where :=' and  PO_PV.VENDOR_NAME <= :c_supplier_max '; -- '''||p_supplier_max||''' ';
	else
		l_supplier_where :=
			' and  PO_PV.VENDOR_NAME between :c_supplier_min and  :c_supplier_max ';
                                           -- '''||p_supplier_min||''' and '''||p_supplier_max||''' ';
	end if;

	fa_rx_util_pkg.debug('l_supplier_where :'||l_supplier_where);

	/* Liability account range */
	if p_liability_min is null or p_liability_max is null then
		l_liability_range_where := to_char(null);
	else
		l_liability_range_where :=' and '||
			fa_rx_flex_pkg.flex_sql(101,'GL#', p_chart_of_acct_id,
			'GC2','WHERE', 'ALL', 'BETWEEN',p_liability_min,p_liability_max)||' ';
	end if;

	fa_rx_util_pkg.debug('l_liability_range_where :'||l_liability_range_where);

	/* Distribution account range */

	if p_dist_acct_min is null or p_dist_acct_max is null then
		l_dist_acct_range_where :=to_char(null);
	else
		l_dist_acct_range_where :=' and '||
			fa_rx_flex_pkg.flex_sql(101,'GL#', p_chart_of_acct_id,
			'GC1','WHERE', 'ALL', 'BETWEEN',p_dist_acct_min, p_dist_acct_max) ||' ';
	end if;

	fa_rx_util_pkg.debug('l_dist_acct_range_where :'||l_dist_acct_range_where);

	/* Invoice Currency Code */
	if p_inv_currency_code is null then
		l_inv_currency_code_where := to_char(null);
	else
		l_inv_currency_code_where :=
			' and AP_INV.INVOICE_CURRENCY_CODE = :c_inv_currency_code '; -- '''||p_inv_currency_code||''
	end if;

	fa_rx_util_pkg.debug('l_inv_currency_code_where :'||l_inv_currency_code_where);

	/* Distribution mount range */
	if p_dist_amount_min is null and p_dist_amount_max is null then
		l_dist_amount_range_where := to_char(null);
	elsif p_dist_amount_min is not null and p_dist_amount_max is null then
		l_dist_amount_range_where :=
			' and DIST.AMOUNT >= :c_dist_amount_min '; -- '||p_dist_amount_min;
	elsif p_dist_amount_min is null and p_dist_amount_max is not null then
		l_dist_amount_range_where :=
			' and DIST.AMOUNT <= :c_dist_amount_max '; -- '||p_dist_amount_max;
	else
		l_dist_amount_range_where :=
			' and DIST.AMOUNT between :c_dist_amount_min and :c_dist_amount_max ';
                                           --  '||p_dist_amount_min||' and '||p_dist_amount_max;
	end if;

	fa_rx_util_pkg.debug('l_dist_amount_range_where :'||l_dist_amount_range_where);

	/* Entered date range */
	if p_entered_date_min is null and p_entered_date_max is null then
		l_entered_date_where := to_char(null);
	elsif p_entered_date_min is not null and p_entered_date_max is null then
		l_entered_date_where := ' and trunc(AP_INV.CREATION_DATE) >= :c_entered_date_min ';
	elsif p_entered_date_min is null and p_entered_date_max is not null then
		l_entered_date_where := ' and trunc(AP_INV.CREATION_DATE) <= :c_entered_date_max ';
	elsif p_entered_date_min is not null and p_entered_date_max is not null then
		l_entered_date_where := ' and trunc(AP_INV.CREATION_DATE) between 	:c_entered_date_min  and :c_entered_date_max ';
	end if;

	fa_rx_util_pkg.debug('l_entered_date_where :'||l_entered_date_where);

	/* Cancelled Invoice only */
	if p_cancelled_inv = true then
		l_cancelled_where := ' and AP_INV.CANCELLED_DATE is not null ';
	else
		l_cancelled_where := to_char(null);
	end if;

	fa_rx_util_pkg.debug('l_cancelled_where :'||l_cancelled_where);

	/* Unapproved Invoice only */
	if p_unapproved_inv = true then
		l_unapproved_inv_where :=
			' and (DIST.MATCH_STATUS_FLAG =''N'' or DIST.MATCH_STATUS_FLAG is null) ';
	else
		l_unapproved_inv_where :=to_char(null);
	end if;

	fa_rx_util_pkg.debug('l_unapproved_inv_where :'||l_unapproved_inv_where);

	/* Parameter 'Line or INVOICE', WHERE PHASE */

	if	p_line_inv ='I' then	/* 'Line or INVOICE' = Invoice */

		if 	l_dist_acct_range_where is null
			and l_dist_amount_range_where is null
			and l_acct_date_where is null
			and l_unapproved_inv_where is null	then

			l_line_inv_where := to_char(null);
		else
                   if h_mrc_sob_type_code = 'R' then
			l_line_inv_where :=
			' and exists
			(Select DIST.INVOICE_ID
			from	AP_INVOICE_DISTS_MRC_V DIST,
				GL_CODE_COMBINATIONS GC1
			where	AP_INV.INVOICE_ID  =DIST.INVOICE_ID
			and DIST.DIST_CODE_COMBINATION_ID = GC1.CODE_COMBINATION_ID (+)'
			||l_dist_acct_range_where||'
		       '||l_dist_amount_range_where||'
		       '||l_acct_date_where||'
		       '||l_unapproved_inv_where||'
                       '||p_dist_org_where||'
		       '||')';
                   else
			l_line_inv_where :=
			' and exists
			(Select DIST.INVOICE_ID
			from	AP_INVOICE_DISTRIBUTIONS_ALL DIST,
				GL_CODE_COMBINATIONS GC1
			where	AP_INV.INVOICE_ID  =DIST.INVOICE_ID
			and DIST.DIST_CODE_COMBINATION_ID = GC1.CODE_COMBINATION_ID (+)'
			||l_dist_acct_range_where||'
		       '||l_dist_amount_range_where||'
		       '||l_acct_date_where||'
		       '||l_unapproved_inv_where||'
                       '||p_dist_org_where||'
		       '||')';
                   end if;
		end if;

	else	/* p_line_inv ='L' ('Line or INVOICE' = LINE) */

		l_line_inv_where := l_dist_acct_range_where || l_dist_amount_range_where
				||l_acct_date_where||l_unapproved_inv_where;
	end if;

	fa_rx_util_pkg.debug('l_line_inv_where :'||l_line_inv_where);

        if h_mrc_sob_type_code = 'R' then
           l_main_from := 'AP_INVOICES_MRC_V	AP_INV,
			   AP_INVOICE_LINES_MRC_V	INV_LINE, -- Added for AP Invoice Line Project
		           PO_VENDORS	PO_PV,
		           AP_INVOICE_DISTS_MRC_V DIST,
		           GL_CODE_COMBINATIONS GC1,
		           GL_CODE_COMBINATIONS GC2 ';

        else
           l_main_from := 'AP_INVOICES_ALL	AP_INV,
			   AP_INVOICE_LINES_ALL	INV_LINE, -- Added for AP Invoice Line Project
		           PO_VENDORS	PO_PV,
		           AP_INVOICE_DISTRIBUTIONS_ALL DIST,
		           GL_CODE_COMBINATIONS GC1,
		           GL_CODE_COMBINATIONS GC2 ';
        end if;


	l_main_sql :=
	'Select	AP_INV.INVOICE_ID			INVOICE_ID,
		AP_INV.ACCTS_PAY_CODE_COMBINATION_ID	LIABILITY_CCID,
		AP_INV.INVOICE_TYPE_LOOKUP_CODE		INVOICE_TYPE,
		DIST.INVOICE_DISTRIBUTION_ID		INVOICE_DISTRIBUTION_ID,
		DIST.DISTRIBUTION_LINE_NUMBER		DIST_NUMBER,
		DIST.LINE_TYPE_LOOKUP_CODE		DIST_TYPE, 	-- Originally LINE_TYPE,
		DIST.DIST_CODE_COMBINATION_ID		DISTRIBUTION_CCID,
		-- Added for AP Invoice Line Project
		DIST.ACCOUNTING_DATE			DIST_ACCT_DATE, -- If necessary will join XLA tables
		INV_LINE.LINE_NUMBER			LINE_NUMBER,
		INV_LINE.LINE_TYPE_LOOKUP_CODE		LINE_TYPE
	From	'|| l_main_from ||'
	Where	AP_INV.VENDOR_ID = PO_PV.VENDOR_ID
--	and	AP_INV.INVOICE_ID  = DIST.INVOICE_ID (+) -- This condition is removed
	-- Added for AP Invoice Line Project
	AND	AP_INV.INVOICE_ID = INV_LINE.INVOICE_ID (+)
	AND	INV_LINE.INVOICE_ID = DIST.INVOICE_ID (+)
	AND	INV_LINE.LINE_NUMBER = DIST.INVOICE_LINE_NUMBER (+)
	-- End of addition
	and	GC1.CODE_COMBINATION_ID (+) = DIST.DIST_CODE_COMBINATION_ID
	and	GC2.CODE_COMBINATION_ID (+) = AP_INV.ACCTS_PAY_CODE_COMBINATION_ID
	'||l_inv_type_where||'
       ' ||l_batch_id_where||'
       ' ||l_entry_person_where||'
       ' ||l_inv_type_where||'
       ' ||l_batch_id_where||'
       ' ||l_doc_seq_id_where||'
       ' ||l_doc_seq_value_where||'
       ' ||l_inv_currency_code_where||'
       ' ||l_supplier_where||'
       ' ||l_liability_range_where||'
       ' ||l_entered_date_where||'
       ' ||l_cancelled_where||'
       ' ||l_line_inv_where||'
       ' ||p_inv_org_where||'
       ' ||p_line_org_where||'
       ' ||p_dist_org_where||'
         ORDER BY  ap_inv.invoice_currency_code,
                   ap_inv.batch_id,
                   decode(:c_sort_by_alternate, ''Y'', upper(po_pv.vendor_name_alt), upper(po_pv.vendor_name)),
                   ap_inv.invoice_num,
                   dist.distribution_line_number';

	fa_rx_util_pkg.debug('Main SQL:');
	fa_rx_util_pkg.debug(l_main_sql);

	/* Open v_MainCursor */
	v_MainCursor :=DBMS_SQL.OPEN_CURSOR;
	fa_rx_util_pkg.debug('***** OPEN CURSOR: v_MainCursor *****');
	fa_rx_util_pkg.debug('v_MainCursor :'||v_MainCursor);

	/* PARSE v_MainCursor */
	DBMS_SQL.PARSE (v_MainCursor,l_main_sql,DBMS_SQL.V7);
	fa_rx_util_pkg.debug('***** PARSE: v_MainCursor *****');

	/* DEFINE COLUMN v_MainCursor */
	DBMS_SQL.DEFINE_COLUMN(v_MainCursor,1,h_invoice_id);
	DBMS_SQL.DEFINE_COLUMN(v_MainCursor,2,h_liability_ccid);
	DBMS_SQL.DEFINE_COLUMN(v_MainCursor,3,h_invoice_type,25);
	DBMS_SQL.DEFINE_COLUMN(v_MainCursor,4,h_inv_dist_id);
	DBMS_SQL.DEFINE_COLUMN(v_MainCursor,5,h_dist_number); -- Originally line_number);
	DBMS_SQL.DEFINE_COLUMN(v_MainCursor,6,h_dist_type,25); -- Originally line_type,25);
	DBMS_SQL.DEFINE_COLUMN(v_MainCursor,7,h_dist_ccid);
	DBMS_SQL.DEFINE_COLUMN(v_MainCursor,8,h_dist_acct_date); -- Newly Added
	DBMS_SQL.DEFINE_COLUMN(v_MainCursor,9,h_line_number);	-- Newly Added
	DBMS_SQL.DEFINE_COLUMN(v_MainCursor,10,h_line_type,25);	-- Newly Added

	fa_rx_util_pkg.debug('***** DEFINE COLUMN: v_MainCursor  *****');

	/* BIND BARIABLE v_MainCursor */
	if p_acct_date_min is not null then
		DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_acct_date_min',p_acct_date_min);
	end if;

	if p_acct_date_max is not null then
		DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_acct_date_max',p_acct_date_max);
	end if;

	if p_entered_date_min is not null then
		DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_entered_date_min',p_entered_date_min);
	end if;

	if p_entered_date_max is not null then
		DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_entered_date_max',p_entered_date_max);
	end if;

	DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_sort_by_alternate', h_sort_by_alternate);

	/* Entered by */
	if p_entry_person_id is not null then
     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_entry_person_id', p_entry_person_id);
	end if;

	/*Invoice Type */
	if p_invoice_type is not null then
     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_invoice_type', p_invoice_type);
	end if;

	/* Batch ID */
	if p_batch_id is not null then
     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_batch_id', p_batch_id);
	end if;

	/* Document Sequence Id */
	if p_doc_sequence_id is not null then
     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_doc_sequence_id', p_doc_sequence_id);
	end if;

	/* Document Sequence value range */
	if p_doc_sequence_value_min is not null then
     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_doc_sequence_value_min', p_doc_sequence_value_min);
        end if;

	if p_doc_sequence_value_max is not null then
     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_doc_sequence_value_max', p_doc_sequence_value_max);
	end if;

	/* Supplier name range */
	if p_supplier_min is not null then
     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_supplier_min', p_supplier_min);
        end if;

	if p_supplier_max is not null then
     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_supplier_max', p_supplier_max);
        end if;

	/* Liability account range */
--	if p_liability_min is not null and p_liability_max is not null then
--   	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_liability_min', p_liability_min);
--     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_liability_max', p_liability_max);
--	end if;

	/* Distribution account range */
--	if p_dist_acct_min is not null and p_dist_acct_max is not null then
--   	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_dist_acct_min', p_dist_acct_min);
--     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_dist_acct_max', p_dist_acct_max);
--	end if;

	/* Invoice Currency Code */
	if p_inv_currency_code is not null then
     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_inv_currency_code', p_inv_currency_code);
	end if;

	/* Distribution mount range */
        if p_dist_amount_min is not null then
     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_dist_amount_min', p_dist_amount_min);
        end if;

	if p_dist_amount_max is not null then
     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_dist_amount_max', p_dist_amount_max);
	end if;

	/* Entered date range */
        if p_entered_date_min is not null then
     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_entered_date_min', p_entered_date_min);
        end if;

	if p_entered_date_max is not null then
     	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':c_entered_date_max', p_entered_date_max);
	end if;

        /* MOAC Change - bind p_reporting_entity_id */
        if p_reporting_level = '3000' then
      	  DBMS_SQL.BIND_VARIABLE(v_MainCursor,':p_reporting_entity_id', h_reporting_entity_id);
  	  fa_rx_util_pkg.debug('h_reporting_entity_id :'||h_reporting_entity_id);
        end if;

	fa_rx_util_pkg.debug('***** BIND VARIABLE: v_MainCursor *****');


	v_MainReturn := DBMS_SQL.EXECUTE(v_MainCursor);
	fa_rx_util_pkg.debug('***** EXECUTE: v_MainCursor *****');
	fa_rx_util_pkg.debug('v_MainReturn :'||v_MainReturn);

	/* Loop and Fetch v_MainCursor */
	Loop

		v_MainFetch := DBMS_SQL.FETCH_ROWS(v_MainCursor);
		fa_rx_util_pkg.debug('***** FETCH ROWS: v_MainCursor *****');
 		fa_rx_util_pkg.debug('v_MainFetch :'||v_MainFetch);

 		If v_MainFetch =0 then
			Exit;
 		end if;

		DBMS_SQL.COLUMN_VALUE(v_MainCursor,1,h_invoice_id);
		DBMS_SQL.COLUMN_VALUE(v_MainCursor,2,h_liability_ccid);
		DBMS_SQL.COLUMN_VALUE(v_MainCursor,3,h_invoice_type);
		DBMS_SQL.COLUMN_VALUE(v_MainCursor,4,h_inv_dist_id);
		DBMS_SQL.COLUMN_VALUE(v_MainCursor,5,h_dist_number);  	-- Originally line_number);
		DBMS_SQL.COLUMN_VALUE(v_MainCursor,6,h_dist_type); 	-- Originally line_type);
		DBMS_SQL.COLUMN_VALUE(v_MainCursor,7,h_dist_ccid);
		DBMS_SQL.COLUMN_VALUE(v_MainCursor,8,h_dist_acct_date); -- Newly Added
		DBMS_SQL.COLUMN_VALUE(v_MainCursor,9,h_line_number);	-- Newly Added
		DBMS_SQL.COLUMN_VALUE(v_MainCursor,10,h_line_type);	-- Newly Added

		fa_rx_util_pkg.debug('h_invoice_id: '||h_invoice_id);
		fa_rx_util_pkg.debug('h_liability_ccid: '||h_liability_ccid);
		fa_rx_util_pkg.debug('h_invoice_type: '||h_invoice_type);
		fa_rx_util_pkg.debug('h_inv_dist_id :'||h_inv_dist_id);
		fa_rx_util_pkg.debug('h_dist_number :'||h_dist_number);		-- Changed to DIST NUMBER
		fa_rx_util_pkg.debug('h_dist_type :'||h_dist_type);		-- Changed to DIST Type
		fa_rx_util_pkg.debug('h_dist_ccid :'||h_inv_dist_id);
		fa_rx_util_pkg.debug('h_line_number :'||h_line_number);		-- Newly Added
		fa_rx_util_pkg.debug('h_line_type :'||h_line_type);		-- Newly Added
		fa_rx_util_pkg.debug('h_dist_acct_date :'|| h_dist_acct_date);	-- Newly Added

		/* Get Liability account and description, natural account and description */

		if h_liability_ccid is not null then

			h_liability_acct :=  fa_rx_flex_pkg.get_value(
					p_application_id => 101,
					p_id_flex_code   => 'GL#',
					p_id_flex_num    => p_chart_of_acct_id,
					p_qualifier      => 'ALL',
					p_ccid 		 => h_liability_ccid);

			h_liability_desc := fa_rx_flex_pkg.get_description(
					p_application_id => 101,
					p_id_flex_code   => 'GL#',
					p_id_flex_num    => p_chart_of_acct_id,
					p_qualifier      => 'ALL',
	        			p_data		  => h_liability_acct);

			h_liability_natacct :=  fa_rx_flex_pkg.get_value(
					p_application_id => 101,
					p_id_flex_code   => 'GL#',
					p_id_flex_num    => p_chart_of_acct_id,
					p_qualifier      => 'GL_ACCOUNT',
					p_ccid 		 => h_liability_ccid);

			h_liability_natdesc := fa_rx_flex_pkg.get_description(
					p_application_id => 101,
					p_id_flex_code   => 'GL#',
					p_id_flex_num    => p_chart_of_acct_id,
					p_qualifier      => 'GL_ACCOUNT',
	        			p_data		  => h_liability_natacct);

		else
			h_liability_acct := to_char(null);
			h_liability_desc := to_char(null);
			h_liability_natacct := to_char(null);
			h_liability_natdesc := to_char(null);
		end if;

		fa_rx_util_pkg.debug('h_liability_acct : '||h_liability_acct);
		fa_rx_util_pkg.debug('h_liability_desc : '||h_liability_desc);
		fa_rx_util_pkg.debug('h_liability_natacct : '||h_liability_natacct);
		fa_rx_util_pkg.debug('h_liability_natdesc : '||h_liability_natdesc);

		/*Get Distribution account and description, natural account and description */

		if h_dist_ccid is not null then

			h_dist_acct :=  fa_rx_flex_pkg.get_value(
					p_application_id => 101,
					p_id_flex_code   => 'GL#',
					p_id_flex_num    => p_chart_of_acct_id,
					p_qualifier      => 'ALL',
					p_ccid 		 => h_dist_ccid);

			h_dist_desc := fa_rx_flex_pkg.get_description(
					p_application_id => 101,
					p_id_flex_code   => 'GL#',
					p_id_flex_num    => p_chart_of_acct_id,
					p_qualifier      => 'ALL',
	        			p_data		  => h_dist_acct);

			h_dist_natacct :=  fa_rx_flex_pkg.get_value(
					p_application_id => 101,
					p_id_flex_code   => 'GL#',
					p_id_flex_num    => p_chart_of_acct_id,
					p_qualifier      => 'GL_ACCOUNT',
					p_ccid 		 => h_dist_ccid);

			h_dist_natdesc := fa_rx_flex_pkg.get_description(
					p_application_id => 101,
					p_id_flex_code   => 'GL#',
					p_id_flex_num    => p_chart_of_acct_id,
					p_qualifier      => 'GL_ACCOUNT',
	        			p_data		  => h_dist_natacct);

		else
			h_dist_acct := to_char(null);
			h_dist_desc := to_char(null);
			h_dist_natacct := to_char(null);
			h_dist_natdesc := to_char(null);
		end if;

		fa_rx_util_pkg.debug('h_dist_acct : '||h_dist_acct);
		fa_rx_util_pkg.debug('h_dist_desc : '||h_dist_desc);
		fa_rx_util_pkg.debug('h_dist_natacct : '||h_dist_natacct);
		fa_rx_util_pkg.debug('h_dist_natdesc : '||h_dist_natdesc);


		/* Insert to JG_ZZ_AP_IR_REP_ITF */
		Insert into JG_ZZ_AP_IR_REP_ITF (
				REQUEST_ID,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				FUNCTIONAL_CURRENCY_CODE,
				ORGANIZATION_NAME,
				INVOICE_ID,
				LIABILITY_CCID,
				LIABILITY_ACCOUNT,
				LIABILITY_DESC,
				LIABILITY_NATACC,
				LIABILITY_NATACC_DESC,
				INVOICE_TYPE,
				INVOICE_DISTRIBUTION_ID,
				LINE_NUMBER,
				LINE_TYPE,
				DIST_NUMBER,		-- Newly Added
				DIST_TYPE,		-- Newly Added
				ACCOUNTING_DATE,	-- Newly Added
				DISTRIBUTION_CCID,
				DISTRIBUTION_ACCOUNT,
				DISTRIBUTION_ACCOUNT_DESC,
				DISTRIBUTION_NATACC,
				DISTRIBUTION_NATACC_DESC
		)
		values (
				p_request_id,
				p_login_id,
				sysdate,
				sysdate,
				p_login_id,
				1,
				h_currency_code,
				h_book_short_name,
				h_invoice_id,
				h_liability_ccid,
				h_liability_acct,
				h_liability_desc,
				h_liability_natacct,
				h_liability_natdesc,
				h_invoice_type,
				h_inv_dist_id,
				h_line_number,
				h_line_type,
				h_dist_number,		-- Newly Added
				h_dist_type,		-- Newly Added
				h_dist_acct_date,	-- Newly Added
				h_dist_ccid,
				h_dist_acct,
				h_dist_desc,
				h_dist_natacct,
				h_dist_natdesc
			);

		fa_rx_util_pkg.debug('Inserted invoice_id: '||h_invoice_id||' inv_dist_id : '||h_inv_dist_id);

	End Loop;

	DBMS_SQL.CLOSE_CURSOR(v_MainCursor);

	fa_rx_util_pkg.debug('***** Close Cursor v_MainCursor *****');

	commit;

	Exception
	when others then
		retcode :=2;
		errbuf := sqlerrm;
		FND_FILE.PUT_LINE(fnd_file.log,errbuf);
		return;

end ap_rx_invoice_run;

end JG_RX_IR_PKG;

/
