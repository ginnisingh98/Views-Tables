--------------------------------------------------------
--  DDL for Package Body JG_RX_C_IR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_RX_C_IR_PKG" AS
/* $Header: jgrxcirb.pls 120.7.12010000.4 2009/12/01 04:59:05 gkumares ship $ */
PROCEDURE ap_rx_invoice_reg (
  errbuf		out nocopy varchar2,
  retcode		out nocopy number,
  argument1		in  varchar2,   -- Reporting Level (for MOAC change)
  argument2		in  varchar2,	-- Reporting Entity ID (for MOAC change)
  argument3		in  varchar2, 	-- Set of Books ID
  argument4		in  varchar2,	-- Supplier Name
  argument5		in  varchar2,	-- Invoice type
  argument6		in  varchar2,	-- Batch id
  argument7		in  varchar2,	-- Entry person id
  argument8		in  varchar2,	-- First entered date
  argument9		in  varchar2,	-- Last entered date
  argument10		in  varchar2, 	-- Accounting period
  argument11		in  varchar2,   -- Cancelled invoices only
  argument12		in  varchar2,   -- Unapproved Invoices only
  argument13		in  varchar2,   -- Debug
  argument14		in  varchar2,
  argument15		in  varchar2,
  argument16		in  varchar2,
  argument17		in  varchar2,
  argument18		in  varchar2,
  argument19		in  varchar2,
  argument20		in  varchar2,
  argument21		in  varchar2,
  argument22		in  varchar2,
  argument23		in  varchar2,
  argument24		in  varchar2,
  argument25		in  varchar2,
  argument26		in  varchar2,
  argument27		in  varchar2,
  argument28		in  varchar2,
  argument29		in  varchar2,
  argument30		in  varchar2,
  argument31		in  varchar2,
  argument32		in  varchar2,
  argument33		in  varchar2,
  argument34		in  varchar2,
  argument35		in  varchar2,
  argument36		in  varchar2,
  argument37		in  varchar2,
  argument38		in  varchar2,
  argument39		in  varchar2,
  argument40		in  varchar2,
  argument41		in  varchar2,
  argument42		in  varchar2,
  argument43		in  varchar2,
  argument44		in  varchar2,
  argument45		in  varchar2,
  argument46		in  varchar2,
  argument47		in  varchar2,
  argument48		in  varchar2,
  argument49		in  varchar2,
  argument50		in  varchar2,
  argument51		in  varchar2,
  argument52		in  varchar2,
  argument53		in  varchar2,
  argument54		in  varchar2,
  argument55		in  varchar2,
  argument56		in  varchar2,
  argument57		in  varchar2,
  argument58		in  varchar2,
  argument59		in  varchar2,
  argument60		in  varchar2,
  argument61		in  varchar2,
  argument62		in  varchar2,
  argument63		in  varchar2,
  argument64		in  varchar2,
  argument65		in  varchar2,
  argument66		in  varchar2,
  argument67		in  varchar2,
  argument68		in  varchar2,
  argument69		in  varchar2,
  argument70		in  varchar2,
  argument71		in  varchar2,
  argument72		in  varchar2,
  argument73		in  varchar2,
  argument74		in  varchar2,
  argument75		in  varchar2,
  argument76		in  varchar2,
  argument77		in  varchar2,
  argument78		in  varchar2,
  argument79		in  varchar2,
  argument80		in  varchar2,
  argument81		in  varchar2,
  argument82		in  varchar2,
  argument83		in  varchar2,
  argument84		in  varchar2,
  argument85		in  varchar2,
  argument86		in  varchar2,
  argument87		in  varchar2,
  argument88		in  varchar2,
  argument89		in  varchar2,
  argument90		in  varchar2,
  argument91		in  varchar2,
  argument92		in  varchar2,
  argument93		in  varchar2,
  argument94		in  varchar2,
  argument95		in  varchar2,
  argument96		in  varchar2,
  argument97		in  varchar2,
  argument98		in  varchar2,
  argument99		in  varchar2,
  argument100           in  varchar2) is

  h_request_id		NUMBER;
  h_login_id		NUMBER;
  h_debug         	BOOLEAN;

/* Added for MOAC change */
  h_reporting_level     varchar2(30);
  h_reporting_entity_id number;

  h_set_of_book_id	number;
  h_chart_of_acct_id	number;
  h_cancelled_inv	BOOLEAN;
  h_unapproved_inv	BOOLEAN;
  h_line_inv		varchar2(1);
  h_batch_id		number;
  h_entry_person_id	number;
  h_entered_date_low	date;
  h_entered_date_high	date;
  h_account_date_low	date;
  h_account_date_high	date;

begin

   /* Set debug mode */
   h_debug := Upper(argument13) LIKE 'Y%';
   IF h_debug THEN
	fa_rx_util_pkg.enable_debug;
   END IF;

   fa_rx_util_pkg.debug('argument1:' ||argument1);
   fa_rx_util_pkg.debug('argument2:' ||argument2);
   fa_rx_util_pkg.debug('argument3:' ||argument3);
   fa_rx_util_pkg.debug('argument4:' ||argument4);
   fa_rx_util_pkg.debug('argument5:' ||argument5);
   fa_rx_util_pkg.debug('argument6:' ||argument6);
   fa_rx_util_pkg.debug('argument7:' ||argument7);
   fa_rx_util_pkg.debug('argument8:' ||argument8);
   fa_rx_util_pkg.debug('argument9:' ||argument9);
   fa_rx_util_pkg.debug('argument10:' ||argument10);
   fa_rx_util_pkg.debug('argument11:' ||argument11);
   fa_rx_util_pkg.debug('argument12:' ||argument12);
   fa_rx_util_pkg.debug('argument13:' ||argument13);

   /* Set Reporting Level and Reporting Context ID */
   if argument1 is null then
     h_reporting_level := '3000'; -- Operating Units
   else
     h_reporting_level := argument1;
   end if;

   if argument2 is null then
     h_reporting_entity_id := fnd_profile.value('DEFAULT_ORG_ID'); -- Get default OU ID.
   else
     h_reporting_entity_id := to_number(argument2);
   end if;



   /* Set request id and login id */
   h_request_id := fnd_global.conc_request_id;

   -- Bug#9056057 Start
   --fnd_profile.get('LOGIN_ID',h_login_id);
   h_login_id := nvl(fnd_profile.value('USER_ID'),1);
   -- Bug#9056057 End
   /* Set boolean parameter */
   h_cancelled_inv := Upper(argument11) LIKE 'Y%';
   h_unapproved_inv :=  Upper(argument12) LIKE 'Y%';

   /* Set other pramerters */
   h_line_inv :='I';
   h_set_of_book_id := to_number(argument3);
   h_batch_id := to_number(argument6);
   h_entry_person_id := to_number(argument7);
   h_entered_date_low := to_date(argument8, 'YYYY/MM/DD HH24:MI:SS');
   h_entered_date_high := to_date(argument9, 'YYYY/MM/DD HH24:MI:SS');

   /* From Period name, get account date range */
   if argument10 is not null then
	SELECT  start_date, end_date
        INTO    h_account_date_low, h_account_date_high
        FROM    gl_period_statuses
        WHERE   period_name = argument8
        AND   	set_of_books_id = h_set_of_book_id
        AND     application_id = 200
        AND 	NVL(adjustment_period_flag, 'N') = 'N';
   end if;

   /* From Set of book id, get chart of account id */
	Select 	chart_of_accounts_id
	into	h_chart_of_acct_id
	from	GL_SETS_OF_BOOKS
	Where   SET_OF_BOOKS_ID =  h_set_of_book_id;

   JG_RX_IR_PKG.AP_RX_INVOICE_RUN (
	errbuf				=> errbuf,
	retcode				=> retcode,
	p_request_id			=> h_request_id,
	p_login_id			=> h_login_id,
        p_reporting_level               => h_reporting_level,
        p_reporting_entity_id           => h_reporting_entity_id,
	p_set_of_book_id		=> h_set_of_book_id,
	p_chart_of_acct_id		=> h_chart_of_acct_id,
	p_line_inv			=> h_line_inv,
	p_acct_date_min			=> h_account_date_low,
	p_acct_date_max			=> h_account_date_high,
	p_batch_id			=> h_batch_id,
	p_invoice_type			=> argument5,
	p_entry_person_id		=> h_entry_person_id,
	p_doc_sequence_id		=> to_number(null),
	p_doc_sequence_value_min	=> to_number(null),
	p_doc_sequence_value_max	=> to_number(null),
	p_supplier_min			=> argument4,
	p_supplier_max			=> argument4,
	p_liability_min			=> to_char(null),
	p_liability_max			=> to_char(null),
	p_dist_acct_min			=> to_char(null),
	p_dist_acct_max			=> to_char(null),
	p_inv_currency_code		=> to_char(null),
	p_dist_amount_min		=> to_number(null),
	p_dist_amount_max		=> to_number(null),
	p_entered_date_min		=> h_entered_date_low,
	p_entered_date_max		=> h_entered_date_high,
	p_cancelled_inv			=> h_cancelled_inv,
	p_unapproved_inv		=> h_unapproved_inv
   );

END ap_rx_invoice_reg;

PROCEDURE ap_rx_invoice_reg_dtl (
  errbuf		out nocopy varchar2,
  retcode		out nocopy number,
  argument1		in  varchar2,	-- Reporting Level (added for MOAC change)
  argument2		in  varchar2,	-- Reporting Entity Id (Added for MOAC change)
  argument3		in  varchar2,	-- Set of Books is
  argument4		in  varchar2,	-- Chart of Accounts id
  argument5		in  varchar2,	-- Line or Invoice
  argument6		in  varchar2,	-- Account date low
  argument7		in  varchar2, 	-- Account Date high
  argument8		in  varchar2, 	-- Batch id
  argument9		in  varchar2,	-- Invoice Type
  argument10		in  varchar2,	-- Entered person id
  argument11		in  varchar2,   -- Document sequence id
  argument12		in  varchar2,	-- Document sequence value low
  argument13		in  varchar2,	-- Document sequence value high
  argument14		in  varchar2,	-- Supplier Name low
  argument15		in  varchar2,	-- Supplier Name high
  argument16		in  varchar2,	-- Liability account low
  argument17		in  varchar2,	-- Liability account high
  argument18		in  varchar2,	-- Distribution account low
  argument19		in  varchar2,	-- Distribution account high
  argument20		in  varchar2,	-- Invoice currency code
  argument21		in  varchar2,	-- Distribution amount low
  argument22		in  varchar2,   -- Distribution amount high
  argument23		in  varchar2,   -- Debug
  argument24		in  varchar2,
  argument25		in  varchar2,
  argument26		in  varchar2,
  argument27		in  varchar2,
  argument28		in  varchar2,
  argument29		in  varchar2,
  argument30		in  varchar2,
  argument31		in  varchar2,
  argument32		in  varchar2,
  argument33		in  varchar2,
  argument34		in  varchar2,
  argument35		in  varchar2,
  argument36		in  varchar2,
  argument37		in  varchar2,
  argument38		in  varchar2,
  argument39		in  varchar2,
  argument40		in  varchar2,
  argument41		in  varchar2,
  argument42		in  varchar2,
  argument43		in  varchar2,
  argument44		in  varchar2,
  argument45		in  varchar2,
  argument46		in  varchar2,
  argument47		in  varchar2,
  argument48		in  varchar2,
  argument49		in  varchar2,
  argument50		in  varchar2,
  argument51		in  varchar2,
  argument52		in  varchar2,
  argument53		in  varchar2,
  argument54		in  varchar2,
  argument55		in  varchar2,
  argument56		in  varchar2,
  argument57		in  varchar2,
  argument58		in  varchar2,
  argument59		in  varchar2,
  argument60		in  varchar2,
  argument61		in  varchar2,
  argument62		in  varchar2,
  argument63		in  varchar2,
  argument64		in  varchar2,
  argument65		in  varchar2,
  argument66		in  varchar2,
  argument67		in  varchar2,
  argument68		in  varchar2,
  argument69		in  varchar2,
  argument70		in  varchar2,
  argument71		in  varchar2,
  argument72		in  varchar2,
  argument73		in  varchar2,
  argument74		in  varchar2,
  argument75		in  varchar2,
  argument76		in  varchar2,
  argument77		in  varchar2,
  argument78		in  varchar2,
  argument79		in  varchar2,
  argument80		in  varchar2,
  argument81		in  varchar2,
  argument82		in  varchar2,
  argument83		in  varchar2,
  argument84		in  varchar2,
  argument85		in  varchar2,
  argument86		in  varchar2,
  argument87		in  varchar2,
  argument88		in  varchar2,
  argument89		in  varchar2,
  argument90		in  varchar2,
  argument91		in  varchar2,
  argument92		in  varchar2,
  argument93		in  varchar2,
  argument94		in  varchar2,
  argument95		in  varchar2,
  argument96		in  varchar2,
  argument97		in  varchar2,
  argument98		in  varchar2,
  argument99		in  varchar2,
  argument100           in  varchar2) is

  h_request_id		NUMBER;
  h_login_id		NUMBER;
  h_debug         	BOOLEAN;

/* Added for MOAC change */
  h_reporting_level     varchar2(30);
  h_reporting_entity_id number;

  h_set_of_book_id	number;
  h_chart_of_acct_id	number;
  h_account_date_low	date;
  h_account_date_high	date;
  h_batch_id		number;
  h_entry_person_id	number;
  h_doc_sequence_id	number;
  h_doc_sequence_value_min	number;
  h_doc_sequence_value_max	number;
  h_dist_amount_min	number;
  h_dist_amount_max	number;

begin

   /* Set debug mode */
   h_debug := Upper(argument23) LIKE 'Y%';
   IF h_debug THEN
	fa_rx_util_pkg.enable_debug;
   END IF;

   fa_rx_util_pkg.debug('argument1:' ||argument1);
   fa_rx_util_pkg.debug('argument2:' ||argument2);
   fa_rx_util_pkg.debug('argument3:' ||argument3);
   fa_rx_util_pkg.debug('argument4:' ||argument4);
   fa_rx_util_pkg.debug('argument5:' ||argument5);
   fa_rx_util_pkg.debug('argument6:' ||argument6);
   fa_rx_util_pkg.debug('argument7:' ||argument7);
   fa_rx_util_pkg.debug('argument8:' ||argument8);
   fa_rx_util_pkg.debug('argument9:' ||argument9);
   fa_rx_util_pkg.debug('argument10:' ||argument10);
   fa_rx_util_pkg.debug('argument11:' ||argument11);
   fa_rx_util_pkg.debug('argument12:' ||argument12);
   fa_rx_util_pkg.debug('argument13:' ||argument13);
   fa_rx_util_pkg.debug('argument14:' ||argument14);
   fa_rx_util_pkg.debug('argument15:' ||argument15);
   fa_rx_util_pkg.debug('argument16:' ||argument16);
   fa_rx_util_pkg.debug('argument17:' ||argument17);
   fa_rx_util_pkg.debug('argument18:' ||argument18);
   fa_rx_util_pkg.debug('argument19:' ||argument19);
   fa_rx_util_pkg.debug('argument20:' ||argument20);
   fa_rx_util_pkg.debug('argument21:' ||argument21);
   fa_rx_util_pkg.debug('argument22:' ||argument22);
   fa_rx_util_pkg.debug('argument23:' ||argument23);

   /* Set Reporting Level and Reporting Context ID */
   if argument1 is null then
     h_reporting_level := '3000'; -- Operating Units
   else
     h_reporting_level := argument1;
   end if;

   if argument2 is null then
	h_reporting_entity_id := fnd_profile.value('DEFAULT_ORG_ID'); -- Get default OU ID.
   else
     h_reporting_entity_id := to_number(argument2);
   end if;


      fa_rx_util_pkg.debug('h_reporting_entity_id : ' ||h_reporting_entity_id);

   /* Set request id and login id */
   h_request_id := fnd_global.conc_request_id;
   -- Bug#9056057 Start
   --fnd_profile.get('LOGIN_ID',h_login_id);
   h_login_id := nvl(fnd_profile.value('USER_ID'),1);
   -- Bug#9056057 End


   /* Set other pramenters */
   h_set_of_book_id := to_number(argument3);
   h_chart_of_acct_id :=to_number(argument4);
   h_account_date_low := to_date(argument6, 'YYYY/MM/DD HH24:MI:SS');
   h_account_date_high := to_date(argument7, 'YYYY/MM/DD HH24:MI:SS');
   h_batch_id := to_number(argument8);
   h_entry_person_id := to_number(argument10);
   h_doc_sequence_id := to_number(argument11);
   h_doc_sequence_value_min := to_number(argument12);
   h_doc_sequence_value_max := to_number(argument13);
   h_dist_amount_min := to_number(argument21);
   h_dist_amount_max := to_number(argument22);

   JG_RX_IR_PKG.AP_RX_INVOICE_RUN (
	errbuf				=> errbuf,
	retcode				=> retcode,
	p_request_id			=> h_request_id,
	p_login_id			=> h_login_id,
        p_reporting_level               => h_reporting_level,
        p_reporting_entity_id           => h_reporting_entity_id,
	p_set_of_book_id		=> h_set_of_book_id,
	p_chart_of_acct_id		=> h_chart_of_acct_id,
	p_line_inv			=> argument5,
	p_acct_date_min			=> h_account_date_low,
	p_acct_date_max			=> h_account_date_high,
	p_batch_id			=> h_batch_id,
	p_invoice_type			=> argument9,
	p_entry_person_id		=> h_entry_person_id,
	p_doc_sequence_id		=> h_doc_sequence_id,
	p_doc_sequence_value_min	=> h_doc_sequence_value_min,
	p_doc_sequence_value_max	=> h_doc_sequence_value_max,
	p_supplier_min			=> argument14,
	p_supplier_max			=> argument15,
	p_liability_min			=> argument16,
	p_liability_max			=> argument17,
	p_dist_acct_min			=> argument18,
	p_dist_acct_max			=> argument19,
	p_inv_currency_code		=> argument20,
	p_dist_amount_min		=> h_dist_amount_min,
	p_dist_amount_max		=> h_dist_amount_max,
	p_entered_date_min		=> to_date(null),
	p_entered_date_max		=> to_date(null),
	p_cancelled_inv			=> false,
	p_unapproved_inv		=> false
   );

END ap_rx_invoice_reg_dtl;

END JG_RX_C_IR_PKG;

/
