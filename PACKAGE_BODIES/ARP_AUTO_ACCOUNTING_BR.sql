--------------------------------------------------------
--  DDL for Package Body ARP_AUTO_ACCOUNTING_BR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_AUTO_ACCOUNTING_BR" AS
/* $Header: ARTEAABB.pls 120.9 2005/11/14 06:58:28 apandit ship $ */

------------------------------------------------------------------------
-- Inherited from other packages
------------------------------------------------------------------------
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
g_ae_sys_rec    ae_sys_rec_type;

--
-- Linefeed character
--
CRLF            CONSTANT VARCHAR2(1) := arp_global.CRLF;

YES			CONSTANT VARCHAR2(1) := arp_global.YES;
NO			CONSTANT VARCHAR2(1) := arp_global.NO;

MSG_LEVEL_BASIC 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_BASIC;
MSG_LEVEL_TIMING 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_TIMING;
MSG_LEVEL_DEBUG 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_DEBUG;
MSG_LEVEL_DEBUG2 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_DEBUG2;
MSG_LEVEL_DEVELOP 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_DEVELOP;

MAX_CURSOR_CACHE_SIZE   CONSTANT BINARY_INTEGER := 20;
MAX_CCID_CACHE_SIZE     CONSTANT BINARY_INTEGER := 1000;
MAX_SEGMENT_CACHE_SIZE  CONSTANT BINARY_INTEGER := 1000;

G_MAX_DATE              CONSTANT DATE:= arp_global.G_MAX_DATE;
G_MIN_DATE              CONSTANT DATE:= to_date('01-01-1952','DD-MM-YYYY');

-- This record holds general information used by autoaccounting and
-- credit memo module.  Passed as argument to most functions/procs.
--
system_info arp_trx_global.system_info_rec_type :=
	arp_trx_global.system_info;

--
-- This record holds profile information used by autoaccounting and
-- credit memo module.  Passed as argument to most functions/procs.
--
profile_info arp_trx_global.profile_rec_type :=
	arp_trx_global.profile_info;

--
-- This record holds accounting flexfield information used by BR
-- autoaccounting.  Passed as argument to most functions/procs.
--
flex_info arp_trx_global.acct_flex_info_rec_type :=
	arp_trx_global.flex_info;

------------------------------------------------------------------------
-- Private types
------------------------------------------------------------------------
TYPE autoacc_rec_type IS RECORD
(
  type          ra_account_defaults.type%type,
  segment       ra_account_default_segments.segment%type,
  table_name    ra_account_default_segments.table_name%type,
  constant      ra_account_default_segments.constant%type
);

--
-- Autoaccounting definintion cache
--
REC             CONSTANT VARCHAR2(14) := 'REC';
UNPAIDREC       CONSTANT VARCHAR2(14) := 'UNPAIDREC';
FACTOR          CONSTANT VARCHAR2(14) := 'FACTOR';
REMITTANCE      CONSTANT VARCHAR2(14) := 'REMITTANCE';

--
-- Maximum of 30 enabled segments for the accounting flex
-- so the gap between offsets is sufficient
--
rec_offset        CONSTANT BINARY_INTEGER := 0;
unpaidrec_offset  CONSTANT BINARY_INTEGER := 50;
factor_offset     CONSTANT BINARY_INTEGER := 100;
remittance_offset CONSTANT BINARY_INTEGER := 150;
--
rec_count        BINARY_INTEGER := 0;
unpaidrec_count  BINARY_INTEGER := 0;
factor_count     BINARY_INTEGER := 0;
remittance_count BINARY_INTEGER := 0;
--
rev_count       BINARY_INTEGER := 0;
frt_count       BINARY_INTEGER := 0;
tax_count       BINARY_INTEGER := 0;
unbill_count    BINARY_INTEGER := 0;
unearn_count    BINARY_INTEGER := 0;
suspense_count  BINARY_INTEGER := 0;

TYPE segment_table_type IS
    TABLE OF ra_account_default_segments.segment%type
    INDEX BY BINARY_INTEGER;
--
TYPE table_table_type IS
    TABLE OF ra_account_default_segments.table_name%type
    INDEX BY BINARY_INTEGER;
--
TYPE const_table_type IS
    TABLE OF ra_account_default_segments.constant%type
    INDEX BY BINARY_INTEGER;
--
autoacc_def_segment_t segment_table_type;
autoacc_def_table_t   table_table_type;
autoacc_def_const_t   const_table_type;

--
-- trx_type cache
--
TYPE trx_type_rec_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
trx_type_rec_t trx_type_rec_table_type;

TYPE trx_type_unpaidrec_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
trx_type_unpaidrec_t trx_type_unpaidrec_table_type;

TYPE trx_type_factor_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
trx_type_factor_t trx_type_factor_table_type;

TYPE trx_type_remittance_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
trx_type_remittance_t trx_type_remittance_table_type;

--
-- site_uses cache
--
TYPE site_use_rec_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
site_use_rec_t site_use_rec_table_type;

TYPE site_use_unpaidrec_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
site_use_unpaidrec_t site_use_unpaidrec_table_type;

TYPE site_use_factor_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
site_use_factor_t site_use_factor_table_type;

TYPE site_use_remittance_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
site_use_remittance_t site_use_remittance_table_type;

--
-- payment method bank account cache
-- (pym_bact) cache by bank account
--
TYPE pym_bact_factor_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
pym_bact_factor_t pym_bact_factor_table_type;

TYPE pym_bact_remittance_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
pym_bact_remittance_t pym_bact_remittance_table_type;

--
-- code combination,segment and date caches
--
TYPE autoacc_cache_seg_type IS
     TABLE OF  varchar2(929)
     INDEX BY  BINARY_INTEGER;

TYPE autoacc_cache_id_type IS
     TABLE OF  BINARY_INTEGER
     INDEX BY  BINARY_INTEGER;

TYPE autoacc_cache_date_type IS
     TABLE OF  DATE
     INDEX BY  BINARY_INTEGER;

TYPE segment_type IS
     TABLE OF  gl_code_combinations.segment1%type
     INDEX BY  BINARY_INTEGER;

TYPE cursor_attr_tbl_type IS
     TABLE OF VARCHAR2(100)
     INDEX BY BINARY_INTEGER;

TYPE cursor_tbl_type IS
     TABLE OF BINARY_INTEGER
     INDEX BY BINARY_INTEGER;

--
-- Misc
--

-- To store segment values for binding
--
TYPE seg_table_type IS
  TABLE OF gl_code_combinations.segment1%type
  INDEX BY binary_integer;
--
TYPE ccid_rec_type IS RECORD
(
    trx_type_ccid_rec           BINARY_INTEGER := -1,
    trx_type_ccid_unpaidrec     BINARY_INTEGER := -1,
    trx_type_ccid_factor        BINARY_INTEGER := -1,
    trx_type_ccid_remittance    BINARY_INTEGER := -1,
    site_use_ccid_rec           BINARY_INTEGER := -1,
    site_use_ccid_unpaidrec     BINARY_INTEGER := -1,
    site_use_ccid_factor        BINARY_INTEGER := -1,
    site_use_ccid_remittance    BINARY_INTEGER := -1,
    pym_bact_ccid_factor        BINARY_INTEGER := -1,
    pym_bact_ccid_remittance    BINARY_INTEGER := -1
);

--
-- To hold values fetched from the Select stmt
--
TYPE select_rec_type IS RECORD
(
  customer_trx_id                     BINARY_INTEGER,
  cust_trx_type_id                    BINARY_INTEGER,
  site_use_id                         BINARY_INTEGER,
  drawee_id                           BINARY_INTEGER,
  bill_to_site_use_id                 BINARY_INTEGER,
  br_unpaid_flag                      VARCHAR2(1),
  transaction_history_id              BINARY_INTEGER,
  batch_id                            BINARY_INTEGER,
  gl_date                             VARCHAR2(12),     -- Julian format
  source_type                         VARCHAR2(20),     --source type
  amount                              NUMBER,
  acctd_amount                        NUMBER,
  currency_code                       VARCHAR2(15),
  currency_conversion_rate            NUMBER,
  currency_conversion_type            VARCHAR2(30),
  currency_conversion_date            VARCHAR2(12),     -- Julian format
  receipt_method_id                   BINARY_INTEGER,
  bank_account_id                     BINARY_INTEGER,
  concatenated_segments               VARCHAR2(240),
  code_combination_id                 BINARY_INTEGER,
  br_unpaid_ccid                      BINARY_INTEGER
);


-- set invalid segvalue to null
--
INVALID_SEGMENT CONSTANT VARCHAR2(20) := '';

--
-- Cursor handles
--

-- Cursor for finding a ccid given segment values
--
ccid_reader_c INTEGER;

--
-- CCID Validation date
--
validation_date  DATE := TRUNC(SYSDATE);


-- User-defined exceptions
--
invalid_account_class		EXCEPTION;
invalid_table_name              EXCEPTION;     -- in autoacc def
error_defaulting_gl_date	EXCEPTION;


--
-- Translated error messages
--
MSG_COMPLETE_REC_ACCOUNT 	varchar2(2000);
MSG_COMPLETE_UNP_ACCOUNT 	varchar2(2000);
MSG_COMPLETE_FAC_ACCOUNT 	varchar2(2000);
MSG_COMPLETE_REM_ACCOUNT        varchar2(2000);

MSG_FLEX_POSTING_NOT_ALLOWED	varchar2(2000);
MSG_FLEX_NO_PARENT_ALLOWED	varchar2(2000);


I               CONSTANT VARCHAR2(1) := 'I';
U               CONSTANT VARCHAR2(1) := 'U';
D               CONSTANT VARCHAR2(1) := 'D';
G               CONSTANT VARCHAR2(1) := 'G';

-- code combination segment, ID, Start and End Date caches
autoacc_rec_id_cache              autoacc_cache_id_type;
autoacc_rec_seg_cache             autoacc_cache_seg_type;
autoacc_rec_st_date_cache         autoacc_cache_date_type;
autoacc_rec_end_date_cache        autoacc_cache_date_type;

autoacc_unp_id_cache              autoacc_cache_id_type;
autoacc_unp_seg_cache             autoacc_cache_seg_type;
autoacc_unp_st_date_cache         autoacc_cache_date_type;
autoacc_unp_end_date_cache        autoacc_cache_date_type;

autoacc_factor_id_cache           autoacc_cache_id_type;
autoacc_factor_seg_cache          autoacc_cache_seg_type;
autoacc_factor_st_date_cache      autoacc_cache_date_type;
autoacc_factor_end_date_cache     autoacc_cache_date_type;

autoacc_rem_id_cache       autoacc_cache_id_type;
autoacc_rem_seg_cache      autoacc_cache_seg_type;
autoacc_rem_st_date_cache  autoacc_cache_date_type;
autoacc_rem_end_date_cache autoacc_cache_date_type;

cursor_attr_cache               cursor_attr_tbl_type;
cursor_cache                    cursor_tbl_type;

segment1_cache    segment_type;
segment2_cache    segment_type;
segment3_cache    segment_type;
segment4_cache    segment_type;
segment5_cache    segment_type;
segment6_cache    segment_type;
segment7_cache    segment_type;
segment8_cache    segment_type;
segment9_cache    segment_type;
segment10_cache   segment_type;
segment11_cache   segment_type;
segment12_cache   segment_type;
segment13_cache   segment_type;
segment14_cache   segment_type;
segment15_cache   segment_type;
segment16_cache   segment_type;
segment17_cache   segment_type;
segment18_cache   segment_type;
segment19_cache   segment_type;
segment20_cache   segment_type;
segment21_cache   segment_type;
segment22_cache   segment_type;
segment23_cache   segment_type;
segment24_cache   segment_type;
segment25_cache   segment_type;
segment26_cache   segment_type;
segment27_cache   segment_type;
segment28_cache   segment_type;
segment29_cache   segment_type;
segment30_cache   segment_type;


----------------------------------------------------------------------------
-- Covers
----------------------------------------------------------------------------
PROCEDURE debug( p_line IN VARCHAR2 ) IS
BEGIN
   arp_util.debug( p_line );
END;

PROCEDURE debug( p_str VARCHAR2, p_print_level BINARY_INTEGER ) IS
BEGIN
     arp_util.debug( p_str, p_print_level );
END;

PROCEDURE enable_debug IS
BEGIN
  arp_util.enable_debug;
END;

PROCEDURE disable_debug IS
BEGIN
  arp_util.disable_debug;
END;

PROCEDURE print_fcn_label( p_label VARCHAR2 ) IS
BEGIN
     arp_util.print_fcn_label( p_label );
END;

PROCEDURE print_fcn_label2( p_label VARCHAR2 ) IS
BEGIN
     arp_util.print_fcn_label2( p_label );
END;

PROCEDURE close_cursor( p_cursor_handle IN OUT NOCOPY INTEGER ) IS
BEGIN
    arp_util.close_cursor( p_cursor_handle );
END;



----------------------------------------------------------------------------
-- Procedures and Functions
----------------------------------------------------------------------------


PROCEDURE put_message_on_stack(
	p_message_text varchar2,
	p_invalid_value varchar2) IS

BEGIN

        FND_MESSAGE.set_name( 'AR', 'GENERIC_MESSAGE' );
        FND_MESSAGE.set_token( 'GENERIC_TEXT', p_message_text );

END put_message_on_stack;


----------------------------------------------------------------------------
PROCEDURE get_error_message_text is

    l_application_id  NUMBER := 222;
    l_msg_name	   VARCHAR2(100);

BEGIN

    print_fcn_label( 'arp_auto_accounting_br.get_error_message_text()+' );

    l_msg_name := 'AR_COMPLETE_BR_REC_ACCOUNT';
    fnd_message.set_name('AR', l_msg_name);
    MSG_COMPLETE_REC_ACCOUNT := fnd_message.get;

    ----
    l_msg_name := 'AR_COMPLETE_BR_UNPAID_ACCOUNT';
    fnd_message.set_name('AR', l_msg_name);
    MSG_COMPLETE_UNP_ACCOUNT := fnd_message.get;

    ----
    l_msg_name := 'AR_COMPLETE_BR_FACTOR';
    fnd_message.set_name('AR', l_msg_name);
    MSG_COMPLETE_FAC_ACCOUNT := fnd_message.get;

    ----
    l_msg_name := 'AR_COMPLETE_BR_REMITTANCE';
    fnd_message.set_name('AR', l_msg_name);
    MSG_COMPLETE_REM_ACCOUNT := fnd_message.get;

    ----
    l_msg_name := 'RA_POSTING_NOT_ALLOWED';
    fnd_message.set_name('AR', l_msg_name);
    MSG_FLEX_POSTING_NOT_ALLOWED := fnd_message.get;

    ----
    l_msg_name := 'FLEX-No Parent';
    fnd_message.set_name('AR', l_msg_name);
    MSG_FLEX_NO_PARENT_ALLOWED := fnd_message.get;

    -- print
    debug( '  This is a list of messages potentially used by Autoaccounting ');
    debug( '  MSG_COMPLETE_REC_ACCOUNT='||MSG_COMPLETE_REC_ACCOUNT,
	MSG_LEVEL_DEBUG );
    debug( '  MSG_COMPLETE_UNP_ACCOUNT='||MSG_COMPLETE_UNP_ACCOUNT,
	MSG_LEVEL_DEBUG );
    debug( '  MSG_COMPLETE_FAC_ACCOUNT='||MSG_COMPLETE_FAC_ACCOUNT,
	MSG_LEVEL_DEBUG );
    debug( '  MSG_COMPLETE_REM_ACCOUNT='||MSG_COMPLETE_REM_ACCOUNT,
	MSG_LEVEL_DEBUG );

    debug( '  MSG_FLEX_POSTING_NOT_ALLOWED='||MSG_FLEX_POSTING_NOT_ALLOWED,
	MSG_LEVEL_DEBUG );
    debug( '  MSG_FLEX_NO_PARENT_ALLOWED='||MSG_FLEX_NO_PARENT_ALLOWED,
	MSG_LEVEL_DEBUG );
    debug( '  End List of messages used by Autoaccounting ');

    print_fcn_label( 'arp_auto_accounting_br.get_error_message_text()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.get_error_message_text()');
        RAISE;
END get_error_message_text;

----------------------------------------------------------------------------
PROCEDURE dump_info IS
BEGIN

    -- sys info
    debug( '  coa_id='||to_char(system_info.chart_of_accounts_id),
	    MSG_LEVEL_DEBUG);
    debug( '  curr='||system_info.base_currency, MSG_LEVEL_DEBUG);
    debug( '  prec='||to_char(system_info.base_precision), MSG_LEVEL_DEBUG);
    debug( '  mau='||to_char(system_info.base_min_acc_unit), MSG_LEVEL_DEBUG);

    -- profile info
    debug( '  login_id='||profile_info.conc_login_id, MSG_LEVEL_DEBUG );
    debug( '  program_id='||profile_info.conc_program_id, MSG_LEVEL_DEBUG );
    debug( '  user_id='||profile_info.user_id, MSG_LEVEL_DEBUG );

    -- flex info
    debug( '  nsegs='||to_char(flex_info.number_segments), MSG_LEVEL_DEBUG);
    debug( '  delim='||flex_info.delim, MSG_LEVEL_DEBUG);

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.dump_info()', MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END dump_info;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  dump_ccid_record
--
-- DECSRIPTION:
--   Prints contents of the ccid record
--
-- ARGUMENTS:
--      IN:
--        ccid_record
--
--      IN/OUT:
--
--      OUT:
--
-- NOTES:
--
-- HISTORY:
--
PROCEDURE dump_ccid_record( p_ccid_record IN ccid_rec_type ) IS
BEGIN
    print_fcn_label( 'arp_auto_accounting_br.dump_ccid_record()+' );

    debug( '  Dumping CCID record:', MSG_LEVEL_DEBUG );

    debug( '  trx_type_ccid_rec=' ||
           to_char(p_ccid_record.trx_type_ccid_rec ), MSG_LEVEL_DEBUG );
    debug( '  trx_type_ccid_unpaidrec=' ||
           to_char(p_ccid_record.trx_type_ccid_unpaidrec ), MSG_LEVEL_DEBUG );
    debug( '  trx_type_ccid_factor=' ||
           to_char(p_ccid_record.trx_type_ccid_factor ), MSG_LEVEL_DEBUG );
    debug( '  trx_type_ccid_remittance=' ||
           to_char(p_ccid_record.trx_type_ccid_remittance ), MSG_LEVEL_DEBUG );
    debug( '  site_use_ccid_rec=' ||
           to_char(p_ccid_record.site_use_ccid_rec ), MSG_LEVEL_DEBUG );
    debug( '  site_use_ccid_unpaidrec=' ||
           to_char(p_ccid_record.site_use_ccid_unpaidrec ), MSG_LEVEL_DEBUG );
    debug( '  site_use_ccid_factor=' ||
           to_char(p_ccid_record.site_use_ccid_factor ), MSG_LEVEL_DEBUG );
    debug( '  site_use_ccid_remittance=' ||
           to_char(p_ccid_record.site_use_ccid_remittance ), MSG_LEVEL_DEBUG );
    debug( '  pym_bact_ccid_factor=' ||
           to_char(p_ccid_record.pym_bact_ccid_factor ), MSG_LEVEL_DEBUG );
    debug( '  pym_bact_ccid_remittance=' ||
           to_char(p_ccid_record.pym_bact_ccid_remittance ), MSG_LEVEL_DEBUG );

    print_fcn_label( 'arp_auto_accounting_br.dump_ccid_record()-' );

END dump_ccid_record;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  load_autoacc_def
--
-- DECSRIPTION:
--   Retrieves the following autoaccounting information for each
--   account class:
--     - segment column name
--     - table name
--     - constant
--   and stores them in plsql tables for future use by autoaccounting.
--   Called on package initialization.
--
-- ARGUMENTS:
--      IN:
--
--      IN/OUT:
--
--      OUT:
--
-- NOTES:
--
-- HISTORY:
--
PROCEDURE load_autoacc_def IS
    l_rec_index         BINARY_INTEGER := rec_offset;
    l_unpaidrec_index   BINARY_INTEGER := unpaidrec_offset;
    l_factor_index      BINARY_INTEGER := factor_offset;
    l_remittance_index  BINARY_INTEGER := remittance_offset;
    --begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
    i_cnt BINARY_INTEGER :=0;
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
   --end anuj

    CURSOR autoacc IS
    SELECT
      ad.type type,
      ads.segment segment,
      upper(ads.table_name) table_name,
      ads.constant constant
    FROM
      ra_account_default_segments ads,
      ra_account_defaults ad
    WHERE ad.gl_default_id = ads.gl_default_id
    AND   ad.type in
    (
     'BR_REC', 'BR_UNPAID_REC', 'BR_FACTOR', 'BR_REMITTANCE'
    )
    ORDER BY
      type,
      segment_num;


    PROCEDURE load( p_table_index 	IN OUT NOCOPY BINARY_INTEGER,
                    p_cnt 		IN OUT NOCOPY BINARY_INTEGER,
                    p_autoacc_rec 	IN autoacc%rowtype) IS
    BEGIN
        autoacc_def_segment_t(p_table_index) := p_autoacc_rec.segment;
        autoacc_def_table_t(p_table_index) := p_autoacc_rec.table_name;
        autoacc_def_const_t(p_table_index):= p_autoacc_rec.constant;
        p_table_index := p_table_index + 1;
        p_cnt := p_cnt + 1;
    END;

BEGIN
    print_fcn_label( 'arp_auto_accounting_br.load_autoacc_def()+' );
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
    rev_count      := 0;
    rec_count      := 0;
    frt_count      := 0;
    tax_count      := 0;
    unbill_count   := 0;
    unearn_count   := 0;
    suspense_count := 0;

    i_cnt := 0;
    while i_cnt <=300 LOOP

    If (autoacc_def_segment_t.exists(i_cnt)) then
        autoacc_def_segment_t.delete;
    End if;
    If (autoacc_def_table_t.exists(i_cnt) ) then
      autoacc_def_table_t.delete;
    End if;
    If (autoacc_def_const_t.exists(i_cnt) ) then
        autoacc_def_const_t.delete;
    End if;
    i_cnt := 50+i_cnt;
    End Loop;
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
--end anuj

    FOR autoacc_rec IN autoacc LOOP
        IF( autoacc_rec.type = 'BR_REC' ) then
          load(l_rec_index, rec_count, autoacc_rec);
        ELSIF( autoacc_rec.type = 'BR_UNPAID_REC' ) then
          load(l_unpaidrec_index, unpaidrec_count, autoacc_rec);
        ELSIF( autoacc_rec.type = 'BR_FACTOR' ) then
          load(l_factor_index, factor_count, autoacc_rec);
        ELSIF( autoacc_rec.type = 'BR_REMITTANCE' ) then
          load(l_remittance_index, remittance_count, autoacc_rec);
        END IF;
    END LOOP;

    print_fcn_label( 'arp_auto_accounting_br.load_autoacc_def()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.load_autoacc_def()',
	      MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END load_autoacc_def ;

----------------------------------------------------------------------------
--
-- FUNCTION NAME:  query_autoacc_def
--
-- DECSRIPTION:
--   Determines whether any of a given account class segments are based
--   on a given table. This is not used directly by Autoaccounting, however
--   has been retained and can be used for test purposes
--
-- ARGUMENTS:
--      IN:
--        account_class:
--          'REC', 'UNPREC', 'FACTOR', 'REMITTANCE'
--        table_name
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--   TRUE if account class is based on specified table
--   FALSE otherwise
--
-- NOTES:
--   check particular account class in cache
--
--
-- HISTORY:
--
FUNCTION query_autoacc_def( p_account_class 	IN VARCHAR2,
                            p_table_name 	IN VARCHAR2 )
    RETURN BOOLEAN IS

    retval BOOLEAN;
    l_account_class             VARCHAR2(20);

    FUNCTION search_table( p_offset 	IN BINARY_INTEGER,
                           p_cnt 	IN BINARY_INTEGER )
        RETURN BOOLEAN is
    BEGIN
        FOR i IN 0..p_cnt-1 LOOP
            IF( autoacc_def_table_t( p_offset + i ) = p_table_name ) THEN
                return TRUE;
            END IF;
        END LOOP;

        RETURN false;
    END;

BEGIN
    print_fcn_label( 'arp_auto_accounting_br.query_autoacc_def()+' );

    g_error_buffer := NULL;

    --
    -- Adjust account_class to proper string
    --
    l_account_class := p_account_class;

    IF l_account_class = REC THEN
       retval := search_table( rec_offset, rec_count);
    ELSIF l_account_class = UNPAIDREC THEN
          retval := search_table( unpaidrec_offset, unpaidrec_count);
    ELSIF l_account_class = FACTOR THEN
          retval := search_table( factor_offset, factor_count);
    ELSIF l_account_class = REMITTANCE THEN
          retval := search_table( remittance_offset, remittance_count);
    ELSE
          g_error_buffer := 'Invalid account class';
	  debug( 'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
          RAISE invalid_account_class;
    END IF;

    print_fcn_label( 'arp_auto_accounting_br.query_autoacc_def()-' );

    RETURN retval;


EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.query_autoacc_def('
              || p_account_class || ', '
              || p_table_name ||')', MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END query_autoacc_def;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  get_trx_type_ccids
--
-- DECSRIPTION:
--   Retrieves default ccids from the table ra_cust_trx_types
--   for a given trx type.
--
-- ARGUMENTS:
--      IN:
--        trx_type_id
--
--      IN/OUT:
--        ccid_rec
--        ccid_unpaidrec
--        ccid_factor
--        ccid_remittance
--
--      OUT:
--
-- NOTES:
--
-- HISTORY:
--
PROCEDURE get_trx_type_ccids( p_trx_type_id 	IN BINARY_INTEGER,
                              p_ccid_rec 	IN OUT NOCOPY BINARY_INTEGER,
                              p_ccid_unpaidrec 	IN OUT NOCOPY BINARY_INTEGER,
                              p_ccid_factor 	IN OUT NOCOPY BINARY_INTEGER,
                              p_ccid_remittance	IN OUT NOCOPY BINARY_INTEGER) IS
BEGIN
    print_fcn_label2( 'arp_auto_accounting_br.get_trx_type_ccids()+' );

    --
    -- initialize
    --
    p_ccid_rec := -1;
    p_ccid_unpaidrec := -1;
    p_ccid_factor := -1;
    p_ccid_remittance := -1;

    BEGIN
        -- see if available in cache
        --
        p_ccid_rec := trx_type_rec_t( p_trx_type_id );
        p_ccid_unpaidrec := trx_type_unpaidrec_t( p_trx_type_id );
        p_ccid_factor := trx_type_factor_t( p_trx_type_id );
        p_ccid_remittance := trx_type_remittance_t( p_trx_type_id );

        debug( '  cache hit: trx_type_id='||to_char(p_trx_type_id),
               MSG_LEVEL_DEBUG );

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- else, get it from the database
            --
            debug( '  cache miss: trx_type_id='||to_char(p_trx_type_id),
                   MSG_LEVEL_DEBUG );

            SELECT
              nvl(gl_id_rec,-1),
              nvl(gl_id_unpaid_rec,-1),
              nvl(gl_id_factor,-1),
              nvl(gl_id_remittance,-1)
            INTO
              p_ccid_rec,
              p_ccid_unpaidrec,
              p_ccid_factor,
              p_ccid_remittance
            FROM ra_cust_trx_types
            WHERE cust_trx_type_id = p_trx_type_id;

            -- update cache
	    trx_type_rec_t( p_trx_type_id ) := p_ccid_rec;
            trx_type_unpaidrec_t( p_trx_type_id ) := p_ccid_unpaidrec;
            trx_type_factor_t( p_trx_type_id ) := p_ccid_factor;
            trx_type_remittance_t( p_trx_type_id ) := p_ccid_remittance;

            debug( '  cached: trx_type_id='||to_char(p_trx_type_id),
                   MSG_LEVEL_DEBUG );
    END;


    print_fcn_label2( 'arp_auto_accounting_br.get_trx_type_ccids()-' );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	debug('arp_auto_accounting_br.get_trx_type_ccids(): no data found',
	      MSG_LEVEL_DEBUG);
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.get_trx_type_ccids('
              || to_char(p_trx_type_id) ||')', MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END get_trx_type_ccids;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  get_site_use_ccids
--
-- DECSRIPTION:
--   Retrieves default ccids from the table hz_cust_site_uses
--   for a given drawee to site use id.
--
-- ARGUMENTS:
--      IN:
--        site_use_id
--
--      IN/OUT:
--        ccid_rec
--        ccid_unpaidrec
--        ccid_factor
--        ccid_remittance
--
--      OUT:
--
-- NOTES:
--
-- HISTORY:
--
PROCEDURE get_site_use_ccids( p_site_use_id 	 IN BINARY_INTEGER,
                              p_ccid_rec 	 IN OUT NOCOPY BINARY_INTEGER,
                              p_ccid_unpaidrec   IN OUT NOCOPY BINARY_INTEGER,
                              p_ccid_factor      IN OUT NOCOPY BINARY_INTEGER,
                              p_ccid_remittance  IN OUT NOCOPY BINARY_INTEGER) IS
BEGIN
    print_fcn_label2( 'arp_auto_accounting_br.get_site_use_ccids()+' );

    --
    -- initialize
    --
    p_ccid_rec := -1;
    p_ccid_unpaidrec := -1;
    p_ccid_factor := -1;
    p_ccid_remittance := -1;

    BEGIN
        -- see if available in cache
        --
        p_ccid_rec := site_use_rec_t( p_site_use_id );
        p_ccid_unpaidrec := site_use_unpaidrec_t( p_site_use_id );
        p_ccid_factor := site_use_factor_t( p_site_use_id );
        p_ccid_remittance := site_use_remittance_t( p_site_use_id );

        debug( '  cache hit: site_use_id='||to_char(p_site_use_id),
               MSG_LEVEL_DEBUG );

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- else, get it from the database
            --
            debug( '  cache miss: site_use_id='||to_char(p_site_use_id),
                   MSG_LEVEL_DEBUG );

            SELECT
              nvl(gl_id_rec,-1),
              nvl(gl_id_unpaid_rec,-1),
              nvl(gl_id_factor,-1),
              nvl(gl_id_remittance,-1)
            INTO
              p_ccid_rec,
              p_ccid_unpaidrec,
              p_ccid_factor,
              p_ccid_remittance
            FROM hz_cust_site_uses
            WHERE site_use_id = p_site_use_id;

            -- update cache
	    site_use_rec_t( p_site_use_id ) := p_ccid_rec;
            site_use_unpaidrec_t( p_site_use_id ) := p_ccid_unpaidrec;
            site_use_factor_t( p_site_use_id ) := p_ccid_factor;
            site_use_remittance_t( p_site_use_id ) := p_ccid_remittance;
    END;

    debug( '  cached: site_use_id='||to_char(p_site_use_id),
              MSG_LEVEL_DEBUG );

    print_fcn_label2( 'arp_auto_accounting_br.get_site_use_ccids()-' );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	debug('arp_auto_accounting_br.get_site_use_ccids(): no data found',
	      MSG_LEVEL_DEBUG);
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.get_site_use_ccids('
              || to_char(p_site_use_id) ||')', MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END get_site_use_ccids;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  get_pym_bact_ccids
--
-- DECSRIPTION:
--   Retrieves default ccids from the table ar_receipt_method_accounts
--   for a given payment methods bank account
--
-- ARGUMENTS:
--      IN:
--        receipt_method_id
--        bank_account_id
--
--      IN/OUT:
--        ccid_factor
--        ccid_remittance
--
--      OUT:
--
-- NOTES:
--
-- HISTORY:
--
--
PROCEDURE get_pym_bact_ccids( p_receipt_method_id IN BINARY_INTEGER,
                        p_bank_account_id IN BINARY_INTEGER,
                        p_ccid_factor IN OUT NOCOPY BINARY_INTEGER,
                        p_ccid_remittance IN OUT NOCOPY BINARY_INTEGER ) IS
BEGIN

    print_fcn_label2( 'arp_auto_accounting_br.get_pym_bact_ccids()+' );

    p_ccid_factor := -1;
    p_ccid_remittance := -1;

    BEGIN
        -- see if available in cache
        --
        p_ccid_factor := pym_bact_factor_t( p_bank_account_id ) ;
        p_ccid_remittance := pym_bact_remittance_t( p_bank_account_id );

        debug( '  cache hit: bank_account_id ='||to_char(p_bank_account_id),
               MSG_LEVEL_DEBUG );

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- else, get it from the database
            --
            debug( '  cache hit: bank_account_id ='||to_char(p_bank_account_id),
                   MSG_LEVEL_DEBUG );

            SELECT
              nvl(br_factor_ccid,-1),
              nvl(br_remittance_ccid,-1)
            INTO p_ccid_factor, p_ccid_remittance
            FROM ar_receipt_method_accounts
            WHERE remit_bank_acct_use_id = p_bank_account_id
            AND   receipt_method_id = p_receipt_method_id ;

            -- update cache
	    pym_bact_factor_t( p_bank_account_id ) := p_ccid_factor;
            pym_bact_remittance_t( p_bank_account_id ) := p_ccid_remittance;

            debug( '  cached: bank_account_id ='||to_char(p_bank_account_id),
                      MSG_LEVEL_DEBUG );

    END;

    print_fcn_label2( 'arp_auto_accounting_br.get_pym_bact_ccids()-' );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	debug('arp_auto_accounting_br.get_pym_bact_ccids(): no data found',
	      MSG_LEVEL_DEBUG);
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.get_pym_bact_ccids('
              || to_char(p_receipt_method_id) || to_char(p_bank_account_id) ||')', MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END get_pym_bact_ccids;

/* ------------------------------------------------------------------------ */
/*      Finds combination_id for given segment values.                      */
/*      If validation date is NULL checks all cross-validation rules.       */
/*      Returns TRUE if combination valid, or FALSE and sets error message  */
/*      on server using FND_MESSAGE if invalid.                             */
/* ------------------------------------------------------------------------ */
FUNCTION get_combination_id(application_short_name    IN  VARCHAR2,
                           key_flex_code        IN  VARCHAR2,
                           structure_number     IN  NUMBER,
                           validation_date      IN  DATE,
                           concat_segments      IN  VARCHAR2,
                           combination_id       OUT NOCOPY NUMBER)
                                                            RETURN BOOLEAN IS
  r_value BOOLEAN := FALSE;
  BEGIN

--  Initialize messages, debugging, and number of sql strings
--
 print_fcn_label( 'arp_auto_accounting_br.get_combination_id()+' );

    r_value := FND_FLEX_KEYVAL.validate_segs('CREATE_COMBINATION',
        application_short_name, key_flex_code, structure_number,
	concat_segments, 'V',
        validation_date);
    if( r_value ) then
      combination_id := FND_FLEX_KEYVAL.combination_id;
      print_fcn_label( 'arp_auto_accounting_br.get_combination_id()-' );
      return(r_value);
    end if;

    return(r_value);

  EXCEPTION
     WHEN OTHERS THEN
         FND_MESSAGE.set_name( 'AR', 'GENERIC_MESSAGE' );
         FND_MESSAGE.set_token( 'GENERIC_TEXT', 'get_combination_id() exception: '||SQLERRM );
         return(FALSE);

END get_combination_id;

/* ------------------------------------------------------------------------ */
/*      Overloaded version of above for user with individual segments.      */
/* ------------------------------------------------------------------------ */

  FUNCTION get_combination_id(application_short_name    IN  VARCHAR2,
                           key_flex_code        IN  VARCHAR2,
                           structure_number     IN  NUMBER,
                           validation_date      IN  DATE,
                           n_segments           IN  NUMBER,
                           segments             IN  FND_FLEX_EXT.SegmentArray,
                           combination_id       OUT NOCOPY NUMBER)
                                                            RETURN BOOLEAN IS
    sepchar     VARCHAR2(1);
    catsegs     VARCHAR2(2000);

  BEGIN
    print_fcn_label( 'arp_auto_accounting_br.get_combination_id1()+' );

--  Concatenate the input segments, then send them to the other function.
--
    sepchar := fnd_flex_ext.get_delimiter(application_short_name, key_flex_code,
                             structure_number);
    if(sepchar is not null) then
      print_fcn_label( 'arp_auto_accounting_br.get_combination_id1()-' );
      return(get_combination_id(application_short_name, key_flex_code,
                         structure_number, validation_date,
                         FND_FLEX_EXT.concatenate_segments(n_segments, segments, sepchar),
                         combination_id));
    end if;
    return(FALSE);

  EXCEPTION
     WHEN OTHERS THEN
         FND_MESSAGE.set_name( 'AR', 'GENERIC_MESSAGE' );
         FND_MESSAGE.set_token( 'GENERIC_TEXT', 'get_combination_id() exception: '||SQLERRM );
         return(FALSE);

END get_combination_id;

----------------------------------------------------------------------------
PROCEDURE define_columns( p_select_c   IN INTEGER,
                          p_select_rec IN select_rec_type) IS
BEGIN
    print_fcn_label2( 'arp_auto_accounting_br.define_columns()+' );

    dbms_sql.define_column( p_select_c,  1, p_select_rec.customer_trx_id );
    dbms_sql.define_column( p_select_c,  2, p_select_rec.cust_trx_type_id);
    dbms_sql.define_column( p_select_c,  3, p_select_rec.site_use_id);
    dbms_sql.define_column( p_select_c,  4, p_select_rec.drawee_id);
    dbms_sql.define_column( p_select_c,  5, p_select_rec.bill_to_site_use_id);
    dbms_sql.define_column( p_select_c,  6, p_select_rec.br_unpaid_flag,1);
    dbms_sql.define_column( p_select_c,  7, p_select_rec.transaction_history_id);
    dbms_sql.define_column( p_select_c,  8, p_select_rec.batch_id);
    dbms_sql.define_column( p_select_c,  9, p_select_rec.gl_date,12);
    dbms_sql.define_column( p_select_c, 10, p_select_rec.source_type, 30);
    dbms_sql.define_column( p_select_c, 11, p_select_rec.amount);
    dbms_sql.define_column( p_select_c, 12, p_select_rec.acctd_amount);
    dbms_sql.define_column( p_select_c, 13, p_select_rec.currency_code,15);
    dbms_sql.define_column( p_select_c, 14, p_select_rec.currency_conversion_rate);
    dbms_sql.define_column( p_select_c, 15, p_select_rec.currency_conversion_type,30);
    dbms_sql.define_column( p_select_c, 16, p_select_rec.currency_conversion_date,12);
    dbms_sql.define_column( p_select_c, 17, p_select_rec.receipt_method_id);
    dbms_sql.define_column( p_select_c, 18, p_select_rec.bank_account_id);
    dbms_sql.define_column( p_select_c, 19, p_select_rec.concatenated_segments,240);
    dbms_sql.define_column( p_select_c, 20, p_select_rec.code_combination_id);
    dbms_sql.define_column( p_select_c, 21, p_select_rec.br_unpaid_ccid);

    print_fcn_label2( 'arp_auto_accounting_br.define_columns()-' );
EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.define_columns()',
		MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END define_columns;


----------------------------------------------------------------------------
--
-- FUNCTION NAME:  build_select_sql
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        system_info
--        profile_info
--        account_class
--        customer_trx_id
--        receivable_application_id
--        code_combination_id
--        cust_trx_type_id
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--   select statement
--
-- NOTES:
--
-- HISTORY:
--
FUNCTION build_select_sql( p_system_info 		IN
                             arp_trx_global.system_info_rec_type,
                           p_profile_info 		IN
                             arp_trx_global.profile_rec_type,
                           p_account_class 		IN VARCHAR2,
                           p_customer_trx_id 		IN BINARY_INTEGER,
                           p_receivable_application_id  IN BINARY_INTEGER,
                           p_br_unpaid_ccid             IN BINARY_INTEGER)
  RETURN VARCHAR2 IS

    l_select_stmt               VARCHAR2(32767);
    l_sel_trx_receipt_col       VARCHAR2(400);
    l_receipt_batch_col         VARCHAR2(400);
    l_ccid_col                  VARCHAR2(400);
    l_br_unpaid_ccid_col        VARCHAR2(400);
    l_ps_app_col                VARCHAR2(400);
    l_receipt_batch_table       VARCHAR2(400);
    l_receipt_app_table         VARCHAR2(400);
    l_trx_id_pred               VARCHAR2(400);
    l_receipt_batch_pred        VARCHAR2(400);
    l_receipt_app_pred          VARCHAR2(400);
    l_alias                     VARCHAR2(4);

BEGIN

    print_fcn_label( 'arp_auto_accounting_br.build_select_sql()+' );

    ------------------------------------------------------------------------
    -- Initialize building blocks columns
    ------------------------------------------------------------------------

    debug( '  Initialize fragments', MSG_LEVEL_DEVELOP );

    l_receipt_batch_col :=  'to_number(''''),' ||
                            CRLF ||'to_number(''''),';

    l_ccid_col  := 'to_char(''''),' || 'to_number(''''),';

    l_br_unpaid_ccid_col := 'to_number('''')';


    ------------------------------------------------------------------------
    -- Initialize building blocks tables
    ------------------------------------------------------------------------
    l_receipt_app_table := '';

    l_receipt_batch_table := '';

    ------------------------------------------------------------------------
    -- Initialize building blocks predicates
    ------------------------------------------------------------------------
    l_receipt_app_pred := '';

    l_receipt_batch_pred := '';

    debug( '  Construct BR Transaction document column details', MSG_LEVEL_DEVELOP );

    ------------------------------------------------------------------------
    -- Get Remmitance account and Receipt Method details from Batch
    ------------------------------------------------------------------------
    IF p_account_class IN ('REC','UNPAIDREC') THEN --Receivable or Unpaid Receivable

       l_alias := 'ps.';

    ELSIF p_account_class IN ('FACTOR','REMITTANCE') THEN

       l_alias := 'arb.';

       l_receipt_batch_col := 'arb.receipt_method_id,' ||
                              CRLF || 'arb.remit_bank_acct_use_id,';

      IF (NVL(g_ae_sys_rec.sob_type,'P') = 'P') THEN
          l_receipt_batch_table := ',' || CRLF || 'ar_batches arb';
--{BUG#4301323
--      ELSE
--          l_receipt_batch_table := ',' || CRLF || 'ar_batches_mrc_v arb';
--}
      END IF;
       l_receipt_batch_pred := CRLF || 'AND th.batch_id = arb.batch_id (+)';

    END IF;

    ------------------------------------------------------------------------
    -- Exchange rate details from Transaction or Batch
    ------------------------------------------------------------------------
    debug('  Construct exchange rate details fragment', MSG_LEVEL_DEVELOP);

    l_sel_trx_receipt_col := l_alias || 'exchange_rate,'        ||
                             CRLF || l_alias || 'exchange_rate_type,'   ||
                             CRLF || 'to_char(' || l_alias || 'exchange_date'
                                  || ',''J''),';

    ------------------------------------------------------------------------
    -- Construct Unpaid ccid fragment
    ------------------------------------------------------------------------
    debug('  Construct unpaid ccid fragment', MSG_LEVEL_DEVELOP);

    IF p_br_unpaid_ccid IS NOT NULL THEN

       l_br_unpaid_ccid_col := ':br_unpaid_ccid';

    END IF;

    ------------------------------------------------------------------------
    -- customer_trx_id fragment
    ------------------------------------------------------------------------
    debug('  Build trx id predicate', MSG_LEVEL_DEVELOP);

    IF( p_customer_trx_id IS NOT NULL ) THEN

        l_trx_id_pred := 'ct.customer_trx_id = :customer_trx_id';

    END IF;


    ----------------------------------------------------------------------------
    -- Receipt application get the receipt amounts due to reversal, as it must
    -- match the reversed application
    -----------------------------------------------------------------------------
    debug('  Construct receipt application fragment', MSG_LEVEL_DEVELOP);

    IF( p_receivable_application_id IS NOT NULL) THEN
      l_ps_app_col := 'app.amount_applied,'||
                             CRLF || 'app.acctd_amount_applied_to,';

      IF (NVL(g_ae_sys_rec.sob_type,'P') = 'P') THEN
         l_receipt_app_table := ',' || CRLF || 'ar_receivable_applications app';
--{BUG4301323
--      ELSE
--         l_receipt_app_table := ',' || CRLF || 'ar_receivable_apps_mrc_v app';
--}
      END IF;

      l_receipt_app_pred := CRLF || 'AND app.receivable_application_id = :application_id' ||
                            CRLF || 'AND app.status = ''APP''' ||
                            CRLF || 'AND nvl(app.confirmed_flag,''Y'') = ''Y''' ||
                            CRLF || 'AND app.applied_customer_trx_id = ct.customer_trx_id';
    ELSE
       l_ps_app_col := 'ps.amount_due_remaining,' ||
                       CRLF || 'ps.acctd_amount_due_remaining,';
    END IF;

    ------------------------------------------------------------------------
    -- Put it all together
    ------------------------------------------------------------------------
    debug('  Put it all together ', MSG_LEVEL_DEVELOP);

    IF (g_ae_sys_rec.sob_type = 'P') THEN
       l_select_stmt :=
            'SELECT ct.customer_trx_id,'                 ||
                CRLF || 'ct.cust_trx_type_id,'           ||
                CRLF || 'ct.drawee_site_use_id,'         ||
                CRLF || 'ct.drawee_id,'                  ||
                CRLF || 'ct.bill_to_site_use_id,'        ||
                CRLF || 'ct.br_unpaid_flag,'             ||
                CRLF || 'th.transaction_history_id,'     ||
                CRLF || 'th.batch_id,'                   ||
                CRLF || 'to_char(th.gl_date,''J''),'     ||
                CRLF || ':account_class,'                ||
                CRLF || l_ps_app_col                     ||
                CRLF || 'ps.invoice_currency_code,'      ||
                CRLF || l_sel_trx_receipt_col            ||
                CRLF || l_receipt_batch_col              ||
                CRLF || l_ccid_col                       ||
                CRLF || l_br_unpaid_ccid_col             ||
      CRLF || 'FROM '|| 'ra_customer_trx ct,'      ||
      CRLF         || 'ar_transaction_history th,' ||
      CRLF         || 'ar_payment_schedules ps'    ||
                      l_receipt_app_table          ||
                      l_receipt_batch_table        ||
      CRLF || 'WHERE '|| l_trx_id_pred                                ||
      CRLF || 'AND th.customer_trx_id = ct.customer_trx_id'           ||
      CRLF || 'AND th.postable_flag = ''Y'''                          ||
      CRLF || 'AND th.posting_control_id = -3'                        ||
      CRLF || 'AND nvl(th.current_record_flag,''N'') = ''Y'''         ||
      CRLF || 'AND nvl(th.current_accounted_flag, ''N'') = ''Y'''     ||
      CRLF || 'AND th.gl_posted_date IS NULL'                         ||
      CRLF || 'AND ps.customer_trx_id = ct.customer_trx_id'           ||
              l_receipt_app_pred                                      ||
              l_receipt_batch_pred                                    ||
      CRLF || '/* prevent duplicate records from being created */'    ||
      CRLF || 'AND not exists'                                        ||
      CRLF || '    (SELECT ''distribution exists'''                   ||
      CRLF || '     FROM   ar_distributions ard'                      ||
      CRLF || '     WHERE  ard.source_id = th.transaction_history_id' ||
      CRLF || '     AND    ard.source_table = ''TH'''                 ||
      CRLF || '     AND    ard.source_type  = :account_class)';
--{BUG#4301323
--  ELSE
--    l_select_stmt :=
--            'SELECT ct.customer_trx_id,'                 ||
--                CRLF || 'ct.cust_trx_type_id,'           ||
--                CRLF || 'ct.drawee_site_use_id,'         ||
--                CRLF || 'ct.drawee_id,'                  ||
--                CRLF || 'ct.bill_to_site_use_id,'        ||
--                CRLF || 'ct.br_unpaid_flag,'             ||
--                CRLF || 'th.transaction_history_id,'     ||
--                CRLF || 'th.batch_id,'                   ||
--                CRLF || 'to_char(th.gl_date,''J''),'     ||
--                CRLF || ':account_class,'                ||
--                CRLF || l_ps_app_col                     ||
--                CRLF || 'ps.invoice_currency_code,'      ||
--                CRLF || l_sel_trx_receipt_col            ||
--                CRLF || l_receipt_batch_col              ||
--                CRLF || l_ccid_col                       ||
--                CRLF || l_br_unpaid_ccid_col             ||
--      CRLF || 'FROM '|| 'ra_customer_trx_mrc_v ct,'      ||
--      CRLF         || 'ar_trx_history_mrc_v th,' ||
--      CRLF         || 'ar_payment_schedules_mrc_v ps'    ||
--                      l_receipt_app_table          ||
--                      l_receipt_batch_table        ||
--      CRLF || 'WHERE '|| l_trx_id_pred                                ||
--      CRLF || 'AND th.customer_trx_id = ct.customer_trx_id'           ||
--      CRLF || 'AND th.postable_flag = ''Y'''                          ||
--      CRLF || 'AND th.posting_control_id = -3'                        ||
--      CRLF || 'AND nvl(th.current_record_flag,''N'') = ''Y'''         ||
--      CRLF || 'AND nvl(th.current_accounted_flag, ''N'') = ''Y'''     ||
--      CRLF || 'AND th.gl_posted_date IS NULL'                         ||
--      CRLF || 'AND ps.customer_trx_id = ct.customer_trx_id'           ||
--              l_receipt_app_pred                                      ||
--              l_receipt_batch_pred                                    ||
--      CRLF || '/* prevent duplicate records from being created */'    ||
--      CRLF || 'AND not exists'                                        ||
--      CRLF || '    (SELECT ''distribution exists'''                   ||
--      CRLF || '     FROM   ar_mc_distributions_all ard'                ||
--      CRLF || '     WHERE  ard.source_id = th.transaction_history_id' ||
--      CRLF || '     AND    ard.set_of_books_id = ' || g_ae_sys_rec.set_of_books_id ||
--      CRLF || '     AND    ard.source_table = ''TH'''                 ||
--      CRLF || '     AND    ard.source_type  = :account_class)';
END IF;

    debug( l_select_stmt, MSG_LEVEL_DEBUG );
    debug( '  len(l_select_stmt)=' ||
                        to_char(length(l_select_stmt)), MSG_LEVEL_DEBUG );

    print_fcn_label( 'arp_auto_accounting_br.build_select_sql()-' );

    RETURN l_select_stmt;

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.build_select_sql()',
	      MSG_LEVEL_BASIC);
        debug(SQLERRM);
        RAISE;

END build_select_sql;


----------------------------------------------------------------------------
--
-- FUNCTION NAME:  add_segments_to_cache
--
-- DECSRIPTION:
--   Addes the segment values for a given ccid to the segment value caches.
--
-- ARGUMENTS:
--      IN:
--        ccid
--        segment_number (from the column name 'SEGMENTxx')
--
--      IN/OUT:
--
--      OUT:
--        p_desired_segment
--
-- RETURNS:
--      segment value.  NULL if data not found.
--
-- NOTES:
--   exception raised if no rows found
--   I did not use record to contain these table values in order to be
--   backward compatible with earlier versions of PL/SQL that did not allow
--   tables of records.
--
-- HISTORY:
--
--
PROCEDURE add_segments_to_cache( p_ccid             IN binary_integer,
                                 p_segment_number   IN binary_integer,
                                 p_desired_segment OUT NOCOPY varchar2) IS

  l_segment1    varchar2(30);
  l_segment2    varchar2(30);
  l_segment3    varchar2(30);
  l_segment4    varchar2(30);
  l_segment5    varchar2(30);
  l_segment6    varchar2(30);
  l_segment7    varchar2(30);
  l_segment8    varchar2(30);
  l_segment9    varchar2(30);
  l_segment10   varchar2(30);
  l_segment11   varchar2(30);
  l_segment12   varchar2(30);
  l_segment13   varchar2(30);
  l_segment14   varchar2(30);
  l_segment15   varchar2(30);
  l_segment16   varchar2(30);
  l_segment17   varchar2(30);
  l_segment18   varchar2(30);
  l_segment19   varchar2(30);
  l_segment20   varchar2(30);
  l_segment21   varchar2(30);
  l_segment22   varchar2(30);
  l_segment23   varchar2(30);
  l_segment24   varchar2(30);
  l_segment25   varchar2(30);
  l_segment26   varchar2(30);
  l_segment27   varchar2(30);
  l_segment28   varchar2(30);
  l_segment29   varchar2(30);
  l_segment30   varchar2(30);

BEGIN

    print_fcn_label2( 'arp_auto_accounting_br.add_segments_to_cache()+' );

    SELECT segment1,
           segment2,
           segment3,
           segment4,
           segment5,
           segment6,
           segment7,
           segment8,
           segment9,
           segment10,
           segment11,
           segment12,
           segment13,
           segment14,
           segment15,
           segment16,
           segment17,
           segment18,
           segment19,
           segment20,
           segment21,
           segment22,
           segment23,
           segment24,
           segment25,
           segment26,
           segment27,
           segment28,
           segment29,
           segment30,
    DECODE(p_segment_number,
           1, segment1,
           2, segment2,
           3, segment3,
           4, segment4,
           5, segment5,
           6, segment6,
           7, segment7,
           8, segment8,
           9, segment9,
           10, segment10,
           11, segment11,
           12, segment12,
           13, segment13,
           14, segment14,
           15, segment15,
           16, segment16,
           17, segment17,
           18, segment18,
           19, segment19,
           20, segment20,
           21, segment21,
           22, segment22,
           23, segment23,
           24, segment24,
           25, segment25,
           26, segment26,
           27, segment27,
           28, segment28,
           29, segment29,
           30, segment30, null)
    INTO   l_segment1,
           l_segment2,
           l_segment3,
           l_segment4,
           l_segment5,
           l_segment6,
           l_segment7,
           l_segment8,
           l_segment9,
           l_segment10,
           l_segment11,
           l_segment12,
           l_segment13,
           l_segment14,
           l_segment15,
           l_segment16,
           l_segment17,
           l_segment18,
           l_segment19,
           l_segment20,
           l_segment21,
           l_segment22,
           l_segment23,
           l_segment24,
           l_segment25,
           l_segment26,
           l_segment27,
           l_segment28,
           l_segment29,
           l_segment30,
           p_desired_segment
    FROM   gl_code_combinations
    WHERE  code_combination_id = p_ccid;


  /*--------------------------------------------------+
   |  Add the selected segments to the segment cache  |
   |  only if the cache is not already full.          |
   +--------------------------------------------------*/

   IF ( segment1_cache.count <= MAX_SEGMENT_CACHE_SIZE )
   THEN
         segment1_cache(p_ccid) := l_segment1;
         segment2_cache(p_ccid) := l_segment2;
         segment3_cache(p_ccid) := l_segment3;
         segment4_cache(p_ccid) := l_segment4;
         segment5_cache(p_ccid) := l_segment5;
         segment6_cache(p_ccid) := l_segment6;
         segment7_cache(p_ccid) := l_segment7;
         segment8_cache(p_ccid) := l_segment8;
         segment9_cache(p_ccid) := l_segment9;
         segment10_cache(p_ccid) := l_segment10;
         segment11_cache(p_ccid) := l_segment11;
         segment12_cache(p_ccid) := l_segment12;
         segment13_cache(p_ccid) := l_segment13;
         segment14_cache(p_ccid) := l_segment14;
         segment15_cache(p_ccid) := l_segment15;
         segment16_cache(p_ccid) := l_segment16;
         segment17_cache(p_ccid) := l_segment17;
         segment18_cache(p_ccid) := l_segment18;
         segment19_cache(p_ccid) := l_segment19;
         segment20_cache(p_ccid) := l_segment20;
         segment21_cache(p_ccid) := l_segment21;
         segment22_cache(p_ccid) := l_segment22;
         segment23_cache(p_ccid) := l_segment23;
         segment24_cache(p_ccid) := l_segment24;
         segment25_cache(p_ccid) := l_segment25;
         segment26_cache(p_ccid) := l_segment26;
         segment27_cache(p_ccid) := l_segment27;
         segment28_cache(p_ccid) := l_segment28;
         segment29_cache(p_ccid) := l_segment29;
         segment30_cache(p_ccid) := l_segment30;
   END IF;

   print_fcn_label2( 'arp_auto_accounting_br.add_segments_to_cache()-' );

   EXCEPTION
     WHEN OTHERS THEN
         debug( 'EXCEPTION: arp_auto_accounting_br.add_segments_to_cache()',
	        MSG_LEVEL_BASIC );
         debug(SQLERRM, MSG_LEVEL_BASIC);
         RAISE;

END;


----------------------------------------------------------------------------
--
-- FUNCTION NAME:  get_segment_from_glcc
--
-- DECSRIPTION:
--   Retrieves a GL code combination segment for a ccid
--
-- ARGUMENTS:
--      IN:
--        ccid
--        segment_number (from the column name 'SEGMENTxx')
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--      segment value.  NULL if data not found.
--
-- NOTES:
--   exception raised if no rows found
--
-- HISTORY:
--
--
FUNCTION get_segment_from_glcc( p_ccid 		 IN BINARY_INTEGER,
                                p_segment_number IN BINARY_INTEGER )
  RETURN VARCHAR2 IS

    l_segment_value VARCHAR2(25);
  i        BINARY_INTEGER := 0;
  l_bool   boolean;
  l_ccid   BINARY_INTEGER;

  l_desired_segment     varchar2(30);

BEGIN

     print_fcn_label2( 'arp_auto_accounting_br.get_segment_from_glcc()+' );

  BEGIN

           if (p_segment_number = 1)
           then return(segment1_cache(p_ccid));
           elsif (p_segment_number = 2)
              then return(segment2_cache(p_ccid));
           elsif (p_segment_number = 3)
              then return(segment3_cache(p_ccid));
           elsif (p_segment_number = 4)
              then return(segment4_cache(p_ccid));
           elsif (p_segment_number = 5)
              then return(segment5_cache(p_ccid));
           elsif (p_segment_number = 6)
              then return(segment6_cache(p_ccid));
           elsif (p_segment_number = 7)
              then return(segment7_cache(p_ccid));
           elsif (p_segment_number = 8)
              then return(segment8_cache(p_ccid));
           elsif (p_segment_number = 9)
              then return(segment9_cache(p_ccid));
           elsif (p_segment_number = 10)
              then return(segment10_cache(p_ccid));
           elsif (p_segment_number = 11)
              then return(segment11_cache(p_ccid));
           elsif (p_segment_number = 12)
              then return(segment12_cache(p_ccid));
           elsif (p_segment_number = 13)
              then return(segment13_cache(p_ccid));
           elsif (p_segment_number = 14)
              then return(segment14_cache(p_ccid));
           elsif (p_segment_number = 15)
              then return(segment15_cache(p_ccid));
           elsif (p_segment_number = 16)
              then return(segment16_cache(p_ccid));
           elsif (p_segment_number = 17)
              then return(segment17_cache(p_ccid));
           elsif (p_segment_number = 18)
              then return(segment18_cache(p_ccid));
           elsif (p_segment_number = 19)
              then return(segment19_cache(p_ccid));
           elsif (p_segment_number = 20)
              then return(segment20_cache(p_ccid));
           elsif (p_segment_number = 21)
              then return(segment21_cache(p_ccid));
           elsif (p_segment_number = 22)
              then return(segment22_cache(p_ccid));
           elsif (p_segment_number = 23)
              then return(segment23_cache(p_ccid));
           elsif (p_segment_number = 24)
              then return(segment24_cache(p_ccid));
           elsif (p_segment_number = 25)
              then return(segment25_cache(p_ccid));
           elsif (p_segment_number = 26)
              then return(segment26_cache(p_ccid));
           elsif (p_segment_number = 27)
              then return(segment27_cache(p_ccid));
           elsif (p_segment_number = 28)
              then return(segment28_cache(p_ccid));
           elsif (p_segment_number = 29)
              then return(segment29_cache(p_ccid));
           elsif (p_segment_number = 30)
              then return(segment30_cache(p_ccid));
           end if;


EXCEPTION
  WHEN NO_DATA_FOUND
   THEN

     /*--------------------------------------------------------------+
      |  The ccid was not in the cache.                              |
      |  Select the segments from gl_code_combinations and add them  |
      |   to the cache if it is not already full.                    |
      +--------------------------------------------------------------*/

      add_segments_to_cache(p_ccid, p_segment_number,l_desired_segment);

      debug('getting segment ' || p_segment_number ||
            'for ccid ' || p_ccid ||
            ' from gl_code_combinations', MSG_LEVEL_DEBUG);

      print_fcn_label2( 'arp_auto_accounting_br.get_segment_from_glcc()-' );
      RETURN(l_desired_segment);

   WHEN OTHERS THEN RAISE;

 END;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
	debug('arp_auto_accounting_br.get_segment_from_glcc(): no data found',
	      MSG_LEVEL_DEBUG);
        RETURN NULL;
    WHEN OTHERS THEN
/*        debug('EXCEPTION: arp_auto_accounting_br.get_segment_from_glcc('
              || to_char(p_ccid) || ', '
              || to_char(p_segment_number) || ')', MSG_LEVEL_BASIC); */
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END get_segment_from_glcc;

----------------------------------------------------------------------------
--
-- FUNCTION NAME:  Get_Ccid_From_Cache
--
-- DECSRIPTION:
--   Retrieves valid GL code combination from the cache or from the AOL
--   API routine if the value is not yet in the cache.
--
-- ARGUMENTS:
--      IN:
--        p_system_info
--        p_concat_segments
--        p_segment_table
--        p_segment_cnt
--        p_account_class
--
--      IN/OUT:
--
--      OUT:
--        p_result
--
-- RETURNS:
--        ccid
--
-- NOTES:
--
-- HISTORY:
--
--

FUNCTION Get_Ccid_From_Cache( p_system_info 	 IN
                                 arp_trx_global.system_info_rec_type,
                              p_concat_segments  IN  varchar2,
                              p_segment_table    IN  fnd_flex_ext.SegmentArray,
                              p_segment_cnt      IN  BINARY_INTEGER,
                              p_account_class    IN
                                 ra_cust_trx_line_gl_dist.account_class%type,
                              p_result           OUT NOCOPY BOOLEAN
                            ) RETURN BINARY_INTEGER IS

  i        BINARY_INTEGER := 0;
  l_bool   boolean;
  l_ccid   BINARY_INTEGER;

BEGIN

   print_fcn_label2( 'arp_auto_accounting_br.get_ccid_from_cache()+' );

  /*----------------------------------------------------------------+
   |  Search the cache for the account_class for the concatenated   |
   |   segments. Return the ccid if it is in the cache.             |
   |                                                                |
   |  After the last record in the cache PL/SQL table is accessed,  |
   |  a NO_DATA_FOUND exception will be generated if the segments   |
   |  are not found the the cache. The NO_DATA_FOUND exception      |
   |  handler then calls the flexfield api to get the ccid and puts |
   |  it in the cache if the cache is not already full.             |
   +----------------------------------------------------------------*/

   WHILE (1 = 1) LOOP
        i:= i + 1;

        IF    ( p_account_class = 'REC' )
        THEN
                 IF   (autoacc_rec_seg_cache(i) = p_concat_segments)
		 AND  (validation_date BETWEEN autoacc_rec_st_date_cache(i) AND
		       autoacc_rec_end_date_cache(i))
                 THEN
                       l_ccid := autoacc_rec_id_cache(i);
                 END IF;

        ELSIF ( p_account_class = 'UNPAIDREC' )
           THEN
                 IF   (autoacc_unp_seg_cache(i) = p_concat_segments)
		 AND  (validation_date BETWEEN autoacc_unp_st_date_cache(i) AND
		       autoacc_unp_end_date_cache(i))
                 THEN
                       l_ccid := autoacc_unp_id_cache(i);
                 END IF;

        ELSIF ( p_account_class = 'FACTOR' )
           THEN
                 IF   (autoacc_factor_seg_cache(i) = p_concat_segments)
		 AND  (validation_date BETWEEN autoacc_factor_st_date_cache(i) AND
		       autoacc_factor_end_date_cache(i))
                 THEN
                       l_ccid := autoacc_factor_id_cache(i);
                 END IF;

        ELSIF ( p_account_class = 'REMITTANCE' )
           THEN
                 IF   (autoacc_rem_seg_cache(i) = p_concat_segments)
		 AND  (validation_date BETWEEN autoacc_rem_st_date_cache(i) AND
		       autoacc_rem_end_date_cache(i))
                 THEN
                       l_ccid := autoacc_rem_id_cache(i);
                 END IF;

        END IF;

      /*-------------------------------------------------+
       |  Return the ccid if it was found in the cache.  |
       +-------------------------------------------------*/

       IF    (l_ccid IS NOT NULL )
       THEN

             debug('found ccid ' || l_ccid  || ' for concatenated segs: ' ||
                   p_concat_segments || ' in the cache', MSG_LEVEL_DEBUG);

             p_result := TRUE;

             print_fcn_label2( 'arp_auto_accounting_br.get_ccid_from_cache()-' );
             RETURN( l_ccid );
       END IF;

   END LOOP;


EXCEPTION
  WHEN NO_DATA_FOUND
   THEN

         debug('Getting concatenated segs: ' ||
                p_concat_segments || ' using the flexfield api',
                MSG_LEVEL_DEBUG);

         IF (get_combination_id(
                        'SQLGL',
                        'GL#',
                        p_system_info.chart_of_accounts_id,
                        validation_date,     -- CCID validation date
                        p_segment_cnt,
                        p_segment_table,
                        l_ccid ) )
         THEN

             /*---------------------------------------------------+
              |  Add the ccid to the cache for its account class  |
              |  if the cache is not already full.                |
              +---------------------------------------------------*/

              IF ( i <= MAX_CCID_CACHE_SIZE )
              THEN
                   IF    ( p_account_class = 'REC' )
                   THEN
                           autoacc_rec_id_cache(i)         := l_ccid;
                           autoacc_rec_seg_cache(i)        := p_concat_segments;
                           autoacc_rec_st_date_cache(i)    := NVL(FND_FLEX_KEYVAL.start_date, G_MIN_DATE);
                           autoacc_rec_end_date_cache(i)   := NVL(FND_FLEX_KEYVAL.end_date, G_MAX_DATE);
                           debug('REC CCID : ' || to_char(autoacc_rec_id_cache(i)) );
                           debug('REC st Date : ' || autoacc_rec_st_date_cache(i) );
                           debug('REC End   Date : ' || autoacc_rec_end_date_cache(i) );

                   ELSIF ( p_account_class = 'UNPAIDREC' )
                      THEN
                           autoacc_unp_id_cache(i)       := l_ccid;
                           autoacc_unp_seg_cache(i)      := p_concat_segments;
                           autoacc_unp_st_date_cache(i)  := NVL(FND_FLEX_KEYVAL.start_date, G_MIN_DATE);
                           autoacc_unp_end_date_cache(i) := NVL(FND_FLEX_KEYVAL.end_date, G_MAX_DATE);
                           debug('UNP CCID : ' || to_char(autoacc_unp_id_cache(i)) );
                           debug('unp st Date : ' || autoacc_unp_st_date_cache(i) );
                           debug('unp End   Date : ' || autoacc_unp_end_date_cache(i) );

                   ELSIF ( p_account_class = 'FACTOR' )
                      THEN
                           autoacc_factor_id_cache(i)       := l_ccid;
                           autoacc_factor_seg_cache(i)      := p_concat_segments;
                           autoacc_factor_st_date_cache(i)  := NVL(FND_FLEX_KEYVAL.start_date, G_MIN_DATE);
                           autoacc_factor_end_date_cache(i) := NVL(FND_FLEX_KEYVAL.end_date, G_MAX_DATE);
                           debug('fac CCID : ' || to_char(autoacc_factor_id_cache(i)) );
                           debug('fac st Date : ' || autoacc_factor_st_date_cache(i) );
                           debug('fac End   Date : ' || autoacc_factor_end_date_cache(i) );

                   ELSIF ( p_account_class = 'REMITTANCE' )
                      THEN
                           autoacc_rem_id_cache(i)       := l_ccid;
                           autoacc_rem_seg_cache(i)      := p_concat_segments;
                           autoacc_rem_st_date_cache(i)  := NVL(FND_FLEX_KEYVAL.start_date, G_MIN_DATE);
                           autoacc_rem_end_date_cache(i) := NVL(FND_FLEX_KEYVAL.end_date, G_MAX_DATE);
                           debug('rem CCID : ' || to_char(autoacc_rem_id_cache(i)) );
                           debug('rem st Date : ' || autoacc_rem_st_date_cache(i) );
                           debug('rem End   Date : ' || autoacc_rem_end_date_cache(i) );

                   END IF;

              END IF;

              p_result := TRUE;
              print_fcn_label2( 'arp_auto_accounting_br.get_ccid_from_cache()-' );

              RETURN(l_ccid);
         ELSE
              p_result := FALSE;
              print_fcn_label2( 'arp_auto_accounting_br.get_ccid_from_cache()-' );

              RETURN(NULL);
         END IF;

   WHEN OTHERS THEN
         debug( 'EXCEPTION: arp_auto_accounting_br.get_ccid_from_cache_cache()',
	        MSG_LEVEL_BASIC );
         debug(SQLERRM, MSG_LEVEL_BASIC);
         RAISE;
END;

----------------------------------------------------------------------------
--
-- FUNCTION NAME:  search_glcc_for_ccid
--
-- DECSRIPTION:
--   Retrieves valid GL code combination based on passed segment values.
--
-- ARGUMENTS:
--      IN:
--        p_system_info
--        p_segment_table
--        p_segment_cnt -- # enabled segments
--        p_account_class
--        p_concat_segments
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--        ccid
--
-- NOTES:
--
-- HISTORY:
--
--
FUNCTION search_glcc_for_ccid( p_system_info 	 IN
                                 arp_trx_global.system_info_rec_type,
                               p_segment_table   IN fnd_flex_ext.SegmentArray,
                               p_segment_cnt  	 IN BINARY_INTEGER,
                               p_account_class   IN
                                 ra_cust_trx_line_gl_dist.account_class%type,
                               p_concat_segments IN VARCHAR2 )

  RETURN BINARY_INTEGER  IS

    l_ignore 			INTEGER;
    l_ccid   			BINARY_INTEGER;
    l_detail_posting_flag	VARCHAR2(1);
    l_summary_flag		VARCHAR2(1);
    l_bool			BOOLEAN;

BEGIN

    print_fcn_label2( 'arp_auto_accounting_br.search_glcc_for_ccid()+' );

    --
    -- part 1:  call the ccid cache or the AOL api to validate and dynamically
    --          insert ccid
    --


   /*------------------------------------------------------------------+
    |  If the  p_concat_segments or p_account_class parameters are     |
    |  null, do not use the cache.                                     |
    |  This logic exists to maintain backward compatibility with the   |
    |  original function spec.                                         |
    |                                                                  |
    |  Otherwise, get the ccid from the caches of already validiated   |
    |  code combinations.                                              |
    +------------------------------------------------------------------*/

    IF   (
              p_concat_segments  IS NOT NULL
          AND p_account_class    IS NOT NULL)
    THEN
         l_ccid := Get_Ccid_From_Cache( p_system_info,
                                        p_concat_segments,
                                        p_segment_table,
                                        p_segment_cnt,
                                        p_account_class,
                                        l_bool);
    ELSE
         l_bool := get_combination_id(
                      'SQLGL',
                      'GL#',
                      p_system_info.chart_of_accounts_id,
                      validation_date,     -- CCID validation date
                      p_segment_cnt,
                      p_segment_table,
                      l_ccid );

    END IF;

    IF( l_bool = FALSE ) THEN
	------------------------------------------------------------------
	-- Failed to retrieve a valid ccid or
	-- unable to dynamically create a ccid
	------------------------------------------------------------------
	g_error_buffer := fnd_message.get;
        debug( g_error_buffer, MSG_LEVEL_BASIC );

        print_fcn_label2( 'arp_auto_accounting_br.search_glcc_for_ccid()-' );
        RETURN -1;

    END IF;

    --
    -- part 2: check special validation
    --         detail_posting_flag
    --         summary_flag
    --
    BEGIN

        -- loop: bind variables
        -- fetch
        dbms_sql.bind_variable( ccid_reader_c, 'ccid',
                                l_ccid );

        dbms_sql.define_column( ccid_reader_c, 1, l_detail_posting_flag, 1 );
        dbms_sql.define_column( ccid_reader_c, 2, l_summary_flag, 1 );

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'Error in binding ccid_reader', MSG_LEVEL_BASIC );
            debug(SQLERRM, MSG_LEVEL_BASIC);
            RAISE;
    END;

    BEGIN

        l_ignore := dbms_sql.execute( ccid_reader_c );

        IF dbms_sql.fetch_rows( ccid_reader_c ) > 0  THEN

            dbms_sql.column_value( ccid_reader_c, 1, l_detail_posting_flag );
            dbms_sql.column_value( ccid_reader_c, 2, l_summary_flag );

	    IF( l_detail_posting_flag = NO ) THEN

		g_error_buffer := MSG_FLEX_POSTING_NOT_ALLOWED;
		debug( MSG_FLEX_POSTING_NOT_ALLOWED, MSG_LEVEL_BASIC);
                print_fcn_label2( 'arp_auto_accounting_br.search_glcc_for_ccid()-' );
	        RETURN -1;

	    ELSIF( l_summary_flag = YES ) THEN

		g_error_buffer := MSG_FLEX_NO_PARENT_ALLOWED;
		debug( MSG_FLEX_NO_PARENT_ALLOWED, MSG_LEVEL_BASIC);
                print_fcn_label2( 'arp_auto_accounting_br.search_glcc_for_ccid()-' );
	        RETURN -1;

	    END IF;

            print_fcn_label2( 'arp_auto_accounting_br.search_glcc_for_ccid()-' );
            RETURN l_ccid;

        ELSE
            --
	    -- should not happen
            --
	    RETURN -1;

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'Error in executing/fetching ccid_reader',
                   MSG_LEVEL_BASIC );
            debug(SQLERRM, MSG_LEVEL_BASIC);
            RAISE;
    END;

    print_fcn_label2( 'arp_auto_accounting_br.search_glcc_for_ccid()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.search_glcc_for_ccid('
              || to_char(p_segment_cnt) ||')', MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END search_glcc_for_ccid;

 /*---------------------------------------------------------------------+
  |  This overloaded version of the function exists to preserve         |
  |  backward compatibility with the original function specification.   |
  +---------------------------------------------------------------------*/


FUNCTION search_glcc_for_ccid( p_system_info 	 IN
                                 arp_trx_global.system_info_rec_type,
                               p_segment_table   IN fnd_flex_ext.SegmentArray,
                               p_segment_cnt  	 IN BINARY_INTEGER )
         RETURN BINARY_INTEGER  IS

BEGIN
       RETURN(
                search_glcc_for_ccid(
                                      p_system_info,
                                      p_segment_table,
                                      p_segment_cnt,
                                      NULL,
                                      NULL
                                    )
             );

END search_glcc_for_ccid;



----------------------------------------------------------------------------
--
-- FUNCTION NAME:  Find_Cursor_In_Cache
--
-- DECSRIPTION:
--                 Searches the cursor cache for an open cursor that matches
--                 the conditions in the key.
--
-- ARGUMENTS:
--      IN:
--                 p_key
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--   Cursor number
--
-- NOTES:
--
-- HISTORY:
--

FUNCTION Find_Cursor_In_Cache ( p_key  IN VARCHAR2 ) RETURN BINARY_INTEGER IS
BEGIN

           print_fcn_label2( 'arp_auto_accounting_br.Find_Cursor_In_Cache()+' );

           FOR l_index IN 1..cursor_attr_cache.count LOOP

               IF ( cursor_attr_cache(l_index) = p_key )
               THEN
                      print_fcn_label2(
                               'arp_auto_accounting_br.Find_Cursor_In_Cache()-' );
                      RETURN( l_index );
               END IF;

           END LOOP;


            print_fcn_label2( 'arp_auto_accounting_br.Find_Cursor_In_Cache()-' );

           RETURN(NULL);

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.Find_Cursor_In_Cache()',
	      MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END;

----------------------------------------------------------------------------
--
-- FUNCTION NAME:  Get_Select_Cursor
--
-- DECSRIPTION:
--                 Returns a cursor for the select statement.
--                 Multiple cursors are maintained for different combinations
--                 of input parameters. These criteria are encoded in the
--                 key which points to the appropriate record in the cursor
--                 cache. If the cursor is not found in the cache,
--                 a select statement is built and parsed, and the new
--                 cursor is added to the cache if the cache is not full.
--
-- ARGUMENTS:
--      IN:
--              p_system_info
--              p_profile_info
--              p_account_class
--              p_customer_trx_id
--
--      IN/OUT:
--
--      OUT:
--              p_keep_cursor_open_flag   - if the cursor is in the cache or
--                                          was added to the cache, don't
--                                          close it after its first use.
--
-- RETURNS:
--   Cursor number
--
-- NOTES:
--
-- HISTORY:
--

FUNCTION Get_Select_Cursor(
                           p_system_info 		IN
                             arp_trx_global.system_info_rec_type,
                           p_profile_info 		IN
                             arp_trx_global.profile_rec_type,
                           p_account_class 		IN VARCHAR2,
                           p_customer_trx_id 		IN BINARY_INTEGER,
                           p_receivable_application_id  IN BINARY_INTEGER,
                           p_br_unpaid_ccid             IN BINARY_INTEGER,
                           p_keep_cursor_open_flag      OUT NOCOPY BOOLEAN )
          RETURN BINARY_INTEGER IS

    l_select_rec    select_rec_type;
    l_key           VARCHAR2(100);
    l_select_c      BINARY_INTEGER;
    l_cursor_index  BINARY_INTEGER;
    l_cursor        BINARY_INTEGER;
    l_ignore   	    INTEGER;

BEGIN

       print_fcn_label2( 'arp_auto_accounting_br.Get_Select_Cursor()+' );

       p_keep_cursor_open_flag := TRUE;

      /*----------------------------------+
       |  Construct the cursor cache key  |
       +----------------------------------*/

       l_key := p_account_class || '-';

       IF (p_customer_trx_id  IS NOT NULL)
       THEN l_key := l_key || 'Y-';
       ELSE l_key := l_key || 'N-';
       END IF;

       IF (p_receivable_application_id  IS NOT NULL)
       THEN l_key := l_key || 'Y-';
       ELSE l_key := l_key || 'N-';
       END IF;

       IF (g_ae_sys_rec.sob_type = 'R' ) THEN
           l_key := l_key || 'R-' || to_char(g_ae_sys_rec.set_of_books_id);
       ELSE
           l_key := l_key || 'P-';
       END IF;

      /*----------------------------------------------------+
       |  Attempt to get the cursor from the cursor cache.  |
       +----------------------------------------------------*/

       l_cursor_index := Find_Cursor_In_Cache(l_key);


      /*---------------------------------------------------+
       |  If the cursor was found, return it immediately.  |
       +---------------------------------------------------*/

       IF ( l_cursor_index IS NOT NULL )
       THEN

             print_fcn_label2( 'arp_auto_accounting_br.Get_Select_Cursor()-' );

             l_cursor := cursor_cache( l_cursor_index );

             debug('Found cursor in cache:  key ' || l_key ||
                   '  cursor index: ' || l_cursor_index ||
                   '  cursor number: ' ||
                   l_cursor, MSG_LEVEL_DEBUG);

             RETURN( l_cursor );
       END IF;


      /*----------------------------------------------+
       |  If the cursor was not found in the cache,   |
       |  construct and parse the select statement.   |
       +----------------------------------------------*/

       debug('Reparsing cursor that was not found in the cache. Key: ' ||
             l_key,
             MSG_LEVEL_DEBUG);


       DECLARE
                l_select_stmt VARCHAR2(32767);
                l_cache_index BINARY_INTEGER;

       BEGIN

                l_select_c := dbms_sql.open_cursor;

                l_cache_index :=  cursor_attr_cache.count + 1;

               /*----------------------------------------------------+
                |  Add the new cursor to the cache if the cache is   |
                |  not already full.                                 |
                +----------------------------------------------------*/

                IF ( l_cache_index <= MAX_CURSOR_CACHE_SIZE )
                THEN
                      cursor_attr_cache( l_cache_index ) := l_key;
                      cursor_cache( l_cache_index )      := l_select_c;

                      p_keep_cursor_open_flag := TRUE;

                ELSE  p_keep_cursor_open_flag := FALSE;
                END IF;


                l_select_stmt := build_select_sql( p_system_info,
                                               p_profile_info,
                                               p_account_class,
                                               p_customer_trx_id,
                                               p_receivable_application_id,
                                               p_br_unpaid_ccid );

                --Order by clause not required as only one account class processed at a time
                ------------------------------------------------------------
                -- Parse
                ------------------------------------------------------------
		debug( '  Parsing select stmt', MSG_LEVEL_DEBUG );

                dbms_sql.parse( l_select_c, l_select_stmt, dbms_sql.v7);


                ------------------------------------------------------------
                -- Define columns
                ------------------------------------------------------------
                define_columns( l_select_c, l_select_rec );


       EXCEPTION
                WHEN OTHERS THEN
                  debug( 'Error constructing/parsing select cursor',
                         MSG_LEVEL_BASIC );
                  debug(SQLERRM, MSG_LEVEL_BASIC);
                  RAISE;

       END;

       print_fcn_label2( 'arp_auto_accounting_br.Get_Select_Cursor()-' );

       RETURN( l_select_c );


EXCEPTION
    WHEN OTHERS THEN

        debug('EXCEPTION: arp_auto_accounting_br.Get_Select_Cursor()',
	      MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;

END;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  Bind_Variable
--
-- DECSRIPTION:
--                 Bind a variable into the specified cursor.
--                 Ignore the 'ORA-01006 - Bind variable doesd not exist'
--                 error.
--                 This routine is overloaded to deal with different datatypes.
--
-- ARGUMENTS:
--      IN:
--                 p_cursor
--                 p_bind_variable
--                 p_value
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--

PROCEDURE Bind_Variable( p_cursor         IN INTEGER,
                         p_bind_variable  IN VARCHAR2,
                         p_value          IN VARCHAR2
                       ) IS
BEGIN
          dbms_sql.bind_variable( p_cursor,
                                  p_bind_variable,
                                  p_value );

EXCEPTION
      WHEN OTHERS THEN
          IF (SQLCODE = -1006)
          THEN NULL;
          ELSE RAISE;
          END IF;

END;

PROCEDURE Bind_Variable( p_cursor         IN INTEGER,
                         p_bind_variable  IN VARCHAR2,
                         p_value          IN INTEGER
                       ) IS
BEGIN
          dbms_sql.bind_variable( p_cursor,
                                  p_bind_variable,
                                  p_value );

EXCEPTION
      WHEN OTHERS THEN
          IF (SQLCODE = -1006)
          THEN NULL;
          ELSE RAISE;
          END IF;

END;


PROCEDURE Bind_Variable( p_cursor         IN INTEGER,
                         p_bind_variable  IN VARCHAR2,
                         p_value          IN DATE
                       ) IS
BEGIN
          dbms_sql.bind_variable( p_cursor,
                                  p_bind_variable,
                                  p_value );

EXCEPTION
      WHEN OTHERS THEN
          IF (SQLCODE = -1006)
          THEN NULL;
          ELSE RAISE;
          END IF;

END;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  Bind_All_Variables
--
-- DECSRIPTION:
--                 Bind all possible variable into the select cursor.
--                 If the cursor is invalid, rebuild and reparse the
--                 select statement and pass the new cursor value back
--                 to the calling function.
--
-- ARGUMENTS:
--      IN:
--                 p_cursor
--                 p_system_info
--                 p_profile_info
--                 p_account_class
--                 p_customer_trx_id
--                 p_br_unpaid_ccid
--
--      IN/OUT:
--                 p_cursor
--
--      OUT:
--                 p_keep_cursor_open_flag
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--

PROCEDURE Bind_All_Variables(
                            p_cursor                    IN OUT NOCOPY BINARY_INTEGER,
                            p_system_info 		IN
                             arp_trx_global.system_info_rec_type,
                            p_profile_info 		IN
                             arp_trx_global.profile_rec_type,
                            p_account_class 		IN VARCHAR2,
                            p_customer_trx_id 		IN BINARY_INTEGER,
                            p_receivable_application_id IN BINARY_INTEGER,
                            p_br_unpaid_ccid            IN BINARY_INTEGER,
                            p_keep_cursor_open_flag IN OUT NOCOPY BOOLEAN
                            ) IS

BEGIN

        print_fcn_label2( 'arp_auto_accounting_br.Bind_All_Variables()+' );

        BEGIN
           Bind_Variable(
                          p_cursor,
                          ':customer_trx_id',
                          p_customer_trx_id
                        );

        EXCEPTION

          /*-----------------------------------------------------------+
           |  If the cursor is invalid, the first bind will fail.      |
           |  in that case, recreate and reparse the SQL statement     |
           |  and continue processing. The new cursor is passed back   |
           |  to the calling routine since it is an IN/OUT parameter.  |
   	   +-----------------------------------------------------------*/

           WHEN INVALID_CURSOR THEN

              debug('Handling INVALID_CURSOR exception by reparsing.',
                    MSG_LEVEL_DEBUG);

              p_cursor := Get_Select_Cursor(
                                             system_info,
                                             profile_info,
                                             p_account_class,
                                             p_customer_trx_id,
                                             p_receivable_application_id,
                                             p_br_unpaid_ccid,
                                             p_keep_cursor_open_flag);

              Bind_Variable(
                          p_cursor,
                          ':customer_trx_id',
                          p_customer_trx_id
                        );

           WHEN OTHERS THEN RAISE;
        END;

        Bind_Variable(
                       p_cursor,
                       ':br_unpaid_ccid',
                       p_br_unpaid_ccid
                     );

        Bind_Variable(
                       p_cursor,
                       ':application_id',
                       p_receivable_application_id
                     );

        Bind_Variable(
                       p_cursor,
                       ':account_class',
                       p_account_class
                     );

        print_fcn_label2( 'arp_auto_accounting_br.Bind_All_Variables()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.Bind_All_Variables()',
		MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  get_default_ccids
--
-- DECSRIPTION:
--   Gets default ccids for all possible tables which autoaccounting
--   may be based.
--
-- ARGUMENTS:
--      IN:
--        profile_info
--        account_class
--        trx_type_id
--        site_use_id
--        receipt_method_id
--        bank_account_id
--
--      IN/OUT:
--        ccid_record
--
--      OUT:
--
-- NOTES:
--
-- HISTORY:
--
PROCEDURE get_default_ccids( p_profile_info 	 IN
                               arp_trx_global.profile_rec_type,
                             p_account_class 	 IN VARCHAR2,
                             p_trx_type_id 	 IN BINARY_INTEGER,
                             p_site_use_id       IN BINARY_INTEGER,
                             p_receipt_method_id IN BINARY_INTEGER,
                             p_bank_account_id   IN BINARY_INTEGER,
                             p_ccid_record 	 IN OUT NOCOPY ccid_rec_type ) IS

BEGIN
    print_fcn_label2( 'arp_auto_accounting_br.get_default_ccids()+' );

    --
    -- trx type
    --
    IF( p_trx_type_id is NOT NULL ) THEN
        get_trx_type_ccids( p_trx_type_id,
                            p_ccid_record.trx_type_ccid_rec,
                            p_ccid_record.trx_type_ccid_unpaidrec,
                            p_ccid_record.trx_type_ccid_factor,
                            p_ccid_record.trx_type_ccid_remittance);

    END IF;

    --
    -- billing site ccids
    --
    IF( p_site_use_id is NOT NULL ) THEN
        get_site_use_ccids( p_site_use_id,
                            p_ccid_record.site_use_ccid_rec,
                            p_ccid_record.site_use_ccid_unpaidrec,
                            p_ccid_record.site_use_ccid_factor,
                            p_ccid_record.site_use_ccid_remittance);

    END IF;

    --
    -- payment method bank account ccids
    --
    IF (( p_receipt_method_id is NOT NULL ) AND ( p_bank_account_id is NOT NULL)) THEN
        get_pym_bact_ccids( p_receipt_method_id,
                            p_bank_account_id,
                            p_ccid_record.pym_bact_ccid_factor,
                            p_ccid_record.pym_bact_ccid_remittance );
    END IF;

    print_fcn_label2( 'arp_auto_accounting_br.get_default_ccids()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.get_default_ccids('
              || p_account_class || ', '
              || to_char(p_trx_type_id) || ', '
              || to_char(p_site_use_id) || ', '
              || to_char(p_receipt_method_id) || ', '
              || to_char(p_bank_account_id)||')', MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END get_default_ccids;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  assemble_code_combination
--
-- DECSRIPTION:
--
--
-- ARGUMENTS:
--      IN:
--        system_info
--        flex_info
--        account_class
--        ccid_record
--
--      IN/OUT:
--        ccid
--        assembled_segments
--      OUT:
--
-- NOTES:
--
--
-- HISTORY:
--
--
PROCEDURE assemble_code_combination(
                  p_system_info IN arp_trx_global.system_info_rec_type,
                  p_flex_info  IN arp_trx_global.acct_flex_info_rec_type,
                  p_account_class IN VARCHAR2,
                  p_ccid_record IN CCID_REC_TYPE,
                  p_ccid IN OUT NOCOPY BINARY_INTEGER,
                  p_concat_segments IN OUT NOCOPY VARCHAR2 ) IS

    l_table_offset        BINARY_INTEGER;
    l_cnt                 BINARY_INTEGER;
    l_concat_segments     VARCHAR2(800);
    l_seg                 ra_account_default_segments.segment%type;
    l_const               ra_account_default_segments.constant%type;
    l_tbl                 ra_account_default_segments.table_name%type;
    l_ccid                BINARY_INTEGER;
    l_seg_num             BINARY_INTEGER;
    l_seg_value           gl_code_combinations.segment1%type;
    l_delim               VARCHAR2(1);

    -- to store segment values for binding
    --
    l_seg_table fnd_flex_ext.SegmentArray;

BEGIN

    print_fcn_label2( 'arp_auto_accounting_br.assemble_code_combination()+' );

    -- get offset, count for account class (to access plsql tables)
    --
    IF( p_account_class = REC ) then
        l_table_offset := rec_offset;
        l_cnt := rec_count;
    ELSIF( p_account_class = UNPAIDREC ) then
        l_table_offset := unpaidrec_offset;
        l_cnt := unpaidrec_count;
    ELSIF( p_account_class = FACTOR ) then
        l_table_offset := factor_offset;
        l_cnt := factor_count;
    ELSIF( p_account_class = REMITTANCE ) then
        l_table_offset := remittance_offset;
        l_cnt := remittance_count;
    ELSE
	g_error_buffer := 'Invalid account class';
	debug( 'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
        RAISE invalid_account_class;
    END IF;

    -- loop for each enabled segment
    --
    FOR i IN 0..l_cnt - 1 LOOP
        l_const := autoacc_def_const_t(l_table_offset + i);
        l_tbl := autoacc_def_table_t(l_table_offset + i);
        l_seg := autoacc_def_segment_t(l_table_offset + i);
        l_ccid := -1;

        IF( i = 0 ) THEN
            l_delim := null;
        ELSE
            l_delim := p_flex_info.delim;
        END IF;

        IF( l_const is NOT NULL ) THEN
            --
            -- constant
            --
            l_concat_segments := l_concat_segments || l_delim
                               || l_const;
            l_seg_table(i+1) := l_const;

        ELSIF( l_tbl is NOT NULL ) THEN
            --
            -- table-based
            --
            IF( l_tbl = 'RA_CUST_TRX_TYPES' ) THEN
                --
                -- For all account classes except REC
                --
                IF p_account_class = REC THEN
                      l_ccid := p_ccid_record.trx_type_ccid_rec;
                ELSIF p_account_class = UNPAIDREC THEN
                      l_ccid := p_ccid_record.trx_type_ccid_unpaidrec;
                ELSIF p_account_class = FACTOR THEN
                      l_ccid := p_ccid_record.trx_type_ccid_factor;
                ELSIF p_account_class = REMITTANCE THEN
                      l_ccid := p_ccid_record.trx_type_ccid_remittance;
                END IF;

            ELSIF( l_tbl = 'RA_SITE_USES' ) THEN
                IF p_account_class = REC THEN
                      l_ccid := p_ccid_record.site_use_ccid_rec;
                ELSIF p_account_class = UNPAIDREC THEN
                      l_ccid := p_ccid_record.site_use_ccid_unpaidrec;
                ELSIF p_account_class = FACTOR THEN
                      l_ccid := p_ccid_record.site_use_ccid_factor;
                ELSIF p_account_class = REMITTANCE THEN
                      l_ccid := p_ccid_record.site_use_ccid_remittance;
                END IF;

            ELSIF( l_tbl = 'AR_RECEIPT_METHOD_ACCOUNTS' ) THEN
                IF p_account_class = FACTOR THEN
                    l_ccid := p_ccid_record.pym_bact_ccid_factor;
                ELSIF p_account_class = REMITTANCE THEN
                    l_ccid := p_ccid_record.pym_bact_ccid_remittance;
                END IF;
            ELSE
	        g_error_buffer := 'Invalid table name: '||l_tbl;
	        debug( 'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
                RAISE invalid_table_name;
            END IF;

            l_seg_num := TO_NUMBER(SUBSTRB(l_seg, LENGTHB('SEGMENT') + 1));

            -- Only get segment if have valid ccid
            --
            IF( l_ccid = -1 ) THEN
                  l_seg_value := INVALID_SEGMENT;
            ELSE
                l_seg_value := get_segment_from_glcc( l_ccid, l_seg_num );

		IF( l_seg_value IS NULL ) THEN
		    --
		    -- assign invalid segment value if no data found
		    --
		    l_seg_value := INVALID_SEGMENT;
		END IF;
            END IF;

            l_concat_segments := l_concat_segments || l_delim || l_seg_value;
            l_seg_table(i+1) := l_seg_value;

        END IF;  -- if const is not null
    END LOOP;

    debug('p_account_class   ' || p_account_class);
    debug('l_concat_segments ' || l_concat_segments);

    -- call ccid reader
    p_ccid := search_glcc_for_ccid(
                                     system_info,
                                     l_seg_table,
                                     l_cnt,
                                     p_account_class,
                                     l_concat_segments );

    -- return concat segs, and ccid
    p_concat_segments := l_concat_segments;

    print_fcn_label2( 'arp_auto_accounting_br.assemble_code_combination()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.assemble_code_combination('
              || p_account_class || ')', MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END assemble_code_combination;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  flex_manager
--
-- DECSRIPTION:
--   Entry point for flexfield assembly.
--
-- ARGUMENTS:
--      IN:
--        account_class
--        trx_type_id
--        site_use_id
--        receipt_method_id
--        bank_account_id
--
--      IN/OUT:
--        ccid
--        concat_segments
--
-- RETURNS:
--   1 if success, 0 otherwise
--
-- NOTES:
--
-- HISTORY:
--
PROCEDURE flex_manager( p_account_class IN VARCHAR2,
                        p_trx_type_id IN BINARY_INTEGER,
                        p_site_use_id IN BINARY_INTEGER,
                        p_receipt_method_id IN BINARY_INTEGER,
                        p_bank_account_id IN BINARY_INTEGER,
                        p_ccid IN OUT NOCOPY BINARY_INTEGER,
                        p_concat_segments IN OUT NOCOPY VARCHAR2 ) IS

    l_ccid_record ccid_rec_type;

    PROCEDURE print_params IS
    BEGIN
        debug('EXCEPTION: arp_auto_accounting_br.flex_manager('
              || p_account_class              || ', '
              || to_char(p_trx_type_id)       || ', '
              || to_char(p_site_use_id)       || ', '
              || to_char(p_receipt_method_id) || ', '
              || to_char(p_bank_account_id)   || ') ',
              MSG_LEVEL_DEBUG);

    END;

BEGIN

    print_fcn_label( 'arp_auto_accounting_br.flex_manager()+' );

    debug( '  account_class='||p_account_class, MSG_LEVEL_DEBUG );
    debug( '  trx_type_id='||to_char(p_trx_type_id), MSG_LEVEL_DEBUG );
    debug( '  site_use_id='||to_char(p_site_use_id), MSG_LEVEL_DEBUG );
    debug( '  receipt_method_id='||to_char(p_receipt_method_id), MSG_LEVEL_DEBUG );
    debug( '  bank_account_id='||to_char(p_bank_account_id), MSG_LEVEL_DEBUG );

    --
    -- Initialize
    --
    p_concat_segments := NULL;
    p_ccid := -1;

    --
    --
    --
    get_default_ccids( profile_info,
                       p_account_class,
                       p_trx_type_id,
                       p_site_use_id,
                       p_receipt_method_id,
                       p_bank_account_id,
                       l_ccid_record );

    -- Dump ccid record, item type
    --
    dump_ccid_record( l_ccid_record );

    --
    -- Assemble segments and get ccid
    --
    assemble_code_combination( system_info,
                               flex_info,
                               p_account_class,
                               l_ccid_record,
                               p_ccid,
                               p_concat_segments );

    debug( '  ccid= '||to_char(p_ccid), MSG_LEVEL_DEBUG );
    debug( '  concat_segs= '||p_concat_segments, MSG_LEVEL_DEBUG );

    print_fcn_label( 'arp_auto_accounting_br.flex_manager()-' );

EXCEPTION
    WHEN OTHERS THEN
        print_params;
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;

END flex_manager;


----------------------------------------------------------------------------
--
-- FUNCTION NAME:  build_delete_sql
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        system_info
--        profile_info
--        account_class
--        customer_trx_id
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--   delete sql
--
-- NOTES:
--
-- HISTORY:
--
FUNCTION build_delete_sql( p_system_info 		IN
                             arp_trx_global.system_info_rec_type,
                           p_profile_info 		IN
                             arp_trx_global.profile_rec_type,
                           p_account_class 		IN VARCHAR2,
                           p_customer_trx_id 		IN BINARY_INTEGER)
  RETURN VARCHAR2 IS

    l_delete_stmt               VARCHAR2(1000);

BEGIN
    print_fcn_label( 'arp_auto_accounting_br.build_delete_sql()+' );

    --
    -- Construct the Delete Statement
    --
    l_delete_stmt :=
      'DELETE from ar_distributions ard'                           ||
      CRLF || 'WHERE ard.source_id in'                             ||
      CRLF || '(SELECT th.transaction_history_id'                  ||
      CRLF || 'FROM ar_transaction_history th'                     ||
      CRLF || 'WHERE th.customer_trx_id = '||p_customer_trx_id     ||
      CRLF || 'AND th.postable_flag = ''Y'''                       ||
      CRLF || 'AND th.posting_control_id = -3'                     ||
      CRLF || 'AND th.gl_posted_date IS NULL'                      ||
      CRLF || 'AND nvl(th.current_record_flag,''N'') = ''Y'''      ||
      CRLF || 'AND nvl(th.current_accounted_flag, ''N'') = ''Y'')' ||
      CRLF || 'AND ard.source_table = ''TH'''                      ||
      CRLF || 'AND ard.source_type = ''' || p_account_class || '''';

    debug( l_delete_stmt, MSG_LEVEL_DEBUG );
    debug( '  len(l_delete_stmt)=' || to_char(length(l_delete_stmt)),
           MSG_LEVEL_DEBUG );

    print_fcn_label( 'arp_auto_accounting_br.build_delete_sql()-' );

    RETURN l_delete_stmt;


EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.build_delete_sql()',
	      MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END build_delete_sql;


----------------------------------------------------------------------------
PROCEDURE get_column_values( p_select_c   IN  INTEGER,
                             p_select_rec OUT NOCOPY select_rec_type ) IS
BEGIN
    print_fcn_label2( 'arp_auto_accounting_br.get_column_values()+' );

    dbms_sql.column_value( p_select_c,  1, p_select_rec.customer_trx_id );
    dbms_sql.column_value( p_select_c,  2, p_select_rec.cust_trx_type_id);
    dbms_sql.column_value( p_select_c,  3, p_select_rec.site_use_id);
    dbms_sql.column_value( p_select_c,  4, p_select_rec.drawee_id);
    dbms_sql.column_value( p_select_c,  5, p_select_rec.bill_to_site_use_id);
    dbms_sql.column_value( p_select_c,  6, p_select_rec.br_unpaid_flag);
    dbms_sql.column_value( p_select_c,  7, p_select_rec.transaction_history_id);
    dbms_sql.column_value( p_select_c,  8, p_select_rec.batch_id);
    dbms_sql.column_value( p_select_c,  9, p_select_rec.gl_date);
    dbms_sql.column_value( p_select_c, 10, p_select_rec.source_type);
    dbms_sql.column_value( p_select_c, 11, p_select_rec.amount);
    dbms_sql.column_value( p_select_c, 12, p_select_rec.acctd_amount);
    dbms_sql.column_value( p_select_c, 13, p_select_rec.currency_code);
    dbms_sql.column_value( p_select_c, 14, p_select_rec.currency_conversion_rate);
    dbms_sql.column_value( p_select_c, 15, p_select_rec.currency_conversion_type);
    dbms_sql.column_value( p_select_c, 16, p_select_rec.currency_conversion_date);
    dbms_sql.column_value( p_select_c, 17, p_select_rec.receipt_method_id);
    dbms_sql.column_value( p_select_c, 18, p_select_rec.bank_account_id);
    dbms_sql.column_value( p_select_c, 19, p_select_rec.concatenated_segments);
    dbms_sql.column_value( p_select_c, 20, p_select_rec.code_combination_id);
    dbms_sql.column_value( p_select_c, 21, p_select_rec.br_unpaid_ccid);

    print_fcn_label2( 'arp_auto_accounting_br.get_column_values()-' );
EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.get_column_values()',
		MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END get_column_values;

----------------------------------------------------------------------------
PROCEDURE insert_dist_row( p_system_info  IN
                              arp_trx_global.system_info_rec_type,
                           p_profile_info IN
                              arp_trx_global.profile_rec_type,
                           p_select_rec   IN select_rec_type,
                           p_receivable_application_id IN NUMBER )  IS
l_amount_dr NUMBER;
l_acctd_amount_dr NUMBER;

l_amount_cr NUMBER;
l_acctd_amount_cr NUMBER;

/* Added for mrc trigger replacement */
l_ae_line_rec         ar_distributions%ROWTYPE;
l_ae_line_rec_empty   ar_distributions%ROWTYPE;
l_dummy  NUMBER;

BEGIN
  print_fcn_label2( 'arp_auto_accounting_br.insert_dist_row()+' );

/*----------------------------------------------------------------------------+
 | The amounts and accounted amounts hit the same Dr or Cr buckets,           |
 | hence the OR cond is used, for all account classes other than normal       |
 | used, for all account classes other than normal receipt reversals Dr the   |
 | BR account with the payment schedule amount (if negative then CR). For     |
 | For Receipt application reversals, Dr the BR account, also handle positive |
 | applications (sign of receivable), these are CR                            |
 +----------------------------------------------------------------------------*/
  IF ((sign(p_select_rec.amount) <> -1) OR
      (sign(p_select_rec.acctd_amount) <> -1)) THEN

     IF (p_receivable_application_id IS NULL) THEN --Dr

        l_amount_dr := p_select_rec.amount;
        l_acctd_amount_dr := p_select_rec.acctd_amount;
        l_amount_cr := NULL;
        l_acctd_amount_cr := NULL;

     ELSE --Cr the BR account cond due to Receipt positive amount app

        l_amount_dr := NULL;
        l_acctd_amount_dr := NULL;
        l_amount_cr := p_select_rec.amount;
        l_acctd_amount_cr := p_select_rec.acctd_amount;

     END IF;

  ELSIF ((sign(p_select_rec.amount) = -1) OR
         (sign(p_select_rec.acctd_amount) = -1)) THEN

     IF (p_receivable_application_id IS NULL) THEN --Cr the BR account

        l_amount_dr := NULL;
        l_acctd_amount_dr := NULL;
        l_amount_cr := p_select_rec.amount;
        l_acctd_amount_cr := p_select_rec.acctd_amount;

     ELSE --Dr the Bills Rec account cond due to Receipt negative amount app
        l_amount_dr := p_select_rec.amount;
        l_acctd_amount_dr := p_select_rec.acctd_amount;
        l_amount_cr := NULL;
        l_acctd_amount_cr := NULL;

     END IF;

  END IF;

/*--------------------------------------------------------------------------------------+
 | If the unpaid flag is yes then for the unpaid bills receivable account if the account |
 | to be reclassified is the same as the account which is derived by autoaccounting, then|
 | the accounting will not be created.                                                   |
 +---------------------------------------------------------------------------------------*/
  IF ((nvl(p_select_rec.br_unpaid_flag,'N') = 'Y') AND (p_select_rec.source_type = UNPAIDREC)
     AND (p_select_rec.br_unpaid_ccid = p_select_rec.code_combination_id)) THEN

     debug('Derived Unpaid account matches existing Unpaid account ');
     NULL;

  ELSE
     debug('Creating accounting');
     -- Initialize
     l_ae_line_rec := l_ae_line_rec_empty;

     -- assign line elements
     l_ae_line_rec.source_type          :=  p_select_rec.source_type;
     l_ae_line_rec.source_id            :=  p_select_rec.transaction_history_id;
     l_ae_line_rec.source_table         := 'TH';
     l_ae_line_rec.code_combination_id  := p_select_rec.code_combination_id;
     l_ae_line_rec.amount_dr            := abs(l_amount_dr);
     l_ae_line_rec.amount_cr            := abs(l_amount_cr);
     l_ae_line_rec.acctd_amount_dr      := abs(l_acctd_amount_dr);
     l_ae_line_rec.acctd_amount_cr      := abs(l_acctd_amount_cr);
     l_ae_line_rec.currency_code        := p_select_rec.currency_code;
     l_ae_line_rec.currency_conversion_rate :=
                                p_select_rec.currency_conversion_rate;
     l_ae_line_rec.currency_conversion_type :=
                                p_select_rec.currency_conversion_type;
     l_ae_line_rec.currency_conversion_date :=
                     to_date(p_select_rec.currency_conversion_date, 'J');

     l_ae_line_rec.third_party_id           := p_select_rec.drawee_id;
     l_ae_line_rec.third_party_sub_id       := p_select_rec.site_use_id;

     IF (g_ae_sys_rec.sob_type = 'P' ) THEN

       /* caling table handler instead of direct insert */
       arp_distributions_pkg.insert_p( l_ae_line_rec, l_dummy);
 --{BUG#4301323
--     ELSE
          /* need to insert records into the MRC table.  Calling new
              mrc engine */
--         IF PG_DEBUG in ('Y', 'C') THEN
--            arp_standard.debug('insert_dist_row: ' || 'getting information for the mrc trigger');
--            arp_standard.debug('insert_dist_row: ' || 'source type = ' || l_ae_line_rec.source_type);
--            arp_standard.debug('insert_dist_row: ' || 'source table = ' || l_ae_line_rec.source_table);
--            arp_standard.debug('insert_dist_row: ' || 'source_id = ' || to_char(l_ae_line_rec.source_id));
--         END IF;

           -- before we call the ar_mrc_engine, we need the line_id of
           -- the primary row.
--         IF (l_ae_line_rec.source_type = 'EXCH_GAIN' or
--              l_ae_line_rec.source_type = 'EXCH_LOSS' or
--              l_ae_line_rec.source_type = 'CURR_ROUND' )  THEN

--              select  ar_distributions_s.nextval
--                into l_ae_line_rec.line_id
--              from dual;
--         ELSE
--           select line_id
--             into l_ae_line_rec.line_id
--            from ar_distributions
--           where source_id = l_ae_line_rec.source_id
--             and source_table = l_ae_line_rec.source_table
--             and source_type = l_ae_line_rec.source_type
--             and source_type_secondary IS NULL;
--         END IF;
--         IF PG_DEBUG in ('Y', 'C') THEN
--            arp_standard.debug('insert_dist_row: ' || 'calling arp_mrc_acct_main.insert_mrc_dis_data');
--         END IF;

--         arp_mrc_acct_main.insert_mrc_dis_data
--                        (l_ae_line_rec,
--                         g_ae_sys_rec.set_of_books_id);
    END IF;

  END IF;
  print_fcn_label2( 'arp_auto_accounting_br.insert_dist_row()-' );
EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.insert_dist_row()',
		MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END insert_dist_row;

----------------------------------------------------------------------------
PROCEDURE dump_select_rec( p_select_rec IN select_rec_type ) IS
BEGIN
    print_fcn_label2( 'arp_auto_accounting_br.dump_select_rec()+' );

    debug( '  Dumping select record: ', MSG_LEVEL_DEBUG );
    debug( '  customer_trx_id='
           || to_char( p_select_rec.customer_trx_id ), MSG_LEVEL_DEBUG );
    debug( '  cust_trx_type_id='
           || to_char( p_select_rec.cust_trx_type_id), MSG_LEVEL_DEBUG );
    debug( '  site_use_id='
          || to_char( p_select_rec.site_use_id),
          MSG_LEVEL_DEBUG );
    debug( '  drawee_id='
           || to_char( p_select_rec.drawee_id ), MSG_LEVEL_DEBUG );
    debug( '  bill_to_site_use_id='
           || to_char( p_select_rec.bill_to_site_use_id ), MSG_LEVEL_DEBUG );
    debug( '  br_unpaid_flag ='
           || p_select_rec.br_unpaid_flag, MSG_LEVEL_DEBUG );
    debug( '  transaction_history_id='
           || to_char( p_select_rec.transaction_history_id ), MSG_LEVEL_DEBUG );
    debug( '  batch_id='
           || to_char( p_select_rec.batch_id ), MSG_LEVEL_DEBUG );
    debug( '  gl_date='
           || p_select_rec.gl_date, MSG_LEVEL_DEBUG );
    debug( '  source_type='
           || p_select_rec.source_type , MSG_LEVEL_DEBUG );
    debug( '  amount=' || to_char(p_select_rec.amount), MSG_LEVEL_DEBUG );
    debug( '  acctd_amount=' || to_char(p_select_rec.acctd_amount), MSG_LEVEL_DEBUG );
    debug( '  currency_code=' || p_select_rec.currency_code,
           MSG_LEVEL_DEBUG );
    debug( '  currency_conversion_rate='
           || to_char( p_select_rec.currency_conversion_rate ), MSG_LEVEL_DEBUG );
    debug( '  currency_conversion_type=' ||
           p_select_rec.currency_conversion_type, MSG_LEVEL_DEBUG );
    debug( '  currency_conversion_date=' ||
           p_select_rec.currency_conversion_date, MSG_LEVEL_DEBUG );
    debug( '  receipt_method_id=' ||
           p_select_rec.receipt_method_id, MSG_LEVEL_DEBUG );
    debug( '  bank_account_id=' ||
           p_select_rec.bank_account_id, MSG_LEVEL_DEBUG );
    debug( '  concatenated_segments='
           || p_select_rec.concatenated_segments, MSG_LEVEL_DEBUG );
    debug( '  code_combination_id='
           || to_char( p_select_rec.code_combination_id ), MSG_LEVEL_DEBUG );
    debug( '  br_unpaid_ccid='
           || to_char( p_select_rec.br_unpaid_ccid), MSG_LEVEL_DEBUG );

    print_fcn_label2( 'arp_auto_accounting_br.dump_select_rec()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.dump_select_rec()',
		MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END dump_select_rec;


----------------------------------------------------------------------------
PROCEDURE process_line( p_system_info 		IN
                          arp_trx_global.system_info_rec_type,
                        p_select_rec  		IN OUT NOCOPY select_rec_type,
                        p_failure_count	 	IN OUT NOCOPY BINARY_INTEGER )  IS

    l_boolean  			BOOLEAN;
    l_error_message		VARCHAR2(256);


BEGIN
    --
    -- Set the CCID validation date
    --
    validation_date := TO_DATE(p_select_rec.gl_date, 'J');
    --
    -- Call Flex manager
    --
    IF( p_select_rec.code_combination_id IS NULL ) THEN

        flex_manager( p_select_rec.source_type,
                      p_select_rec.cust_trx_type_id,
                      p_select_rec.site_use_id,
                      p_select_rec.receipt_method_id,
                      p_select_rec.bank_account_id,
                      p_select_rec.code_combination_id,
                      p_select_rec.concatenated_segments);
    END IF;

    IF( p_select_rec.code_combination_id = -1 ) THEN

        -- keep track of # rows where ccid was not found
        -- if > 0, then need to call AOL dynamic insert
        -- on the client-side
        --
        p_failure_count	 := nvl(p_failure_count, 0) + 1;

        debug('process_line:  Failure count : '||to_char(p_failure_count),
              MSG_LEVEL_DEBUG);
    END IF;

END process_line;

----------------------------------------------------------------------------
PROCEDURE do_autoaccounting_internal(
			    p_mode 			IN VARCHAR2,
                            p_account_class 		IN VARCHAR2,
                            p_customer_trx_id 		IN NUMBER,
                            p_receivable_application_id IN NUMBER,
                            p_br_unpaid_ccid            IN NUMBER,
                            p_cust_trx_type_id 		IN NUMBER,
                            p_site_use_id         	IN NUMBER,
                            p_receipt_method_id 	IN NUMBER,
                            p_bank_account_id           IN NUMBER,
                            p_ccid 			IN OUT NOCOPY NUMBER,
                            p_concat_segments 		IN OUT NOCOPY VARCHAR2,
                            p_failure_count	 	IN OUT NOCOPY NUMBER )
IS


    l_select_rec select_rec_type;
    l_null_rec   CONSTANT select_rec_type := l_select_rec;

    -- Cursors
    --
    l_select_c INTEGER;
    l_delete_c INTEGER;

    l_ignore   			INTEGER;
    l_boolean  			BOOLEAN;
    l_first_fetch		BOOLEAN;
    l_temp                      BINARY_INTEGER;
    l_keep_cursor_open_flag     BOOLEAN := FALSE;

BEGIN

    print_fcn_label( 'arp_auto_accounting_br.do_autoaccounting_internal()+' );


    SAVEPOINT ar_auto_accounting;

    -- MRC Trigger Replacement: Initialize new global variable.
    g_ae_sys_rec.sob_type          := NVL(ARP_ACCT_MAIN.ae_sys_rec.sob_type,'P');
    g_ae_sys_rec.set_of_books_id   := ARP_ACCT_MAIN.ae_sys_rec.set_of_books_id;

    --------------------------------------------------------------------------
    -- Process modes
    --------------------------------------------------------------------------
    IF( p_mode = G ) THEN
        --
        -- Get mode, populate record immediately
        --
        l_select_rec := l_null_rec;     -- start with null record

        l_select_rec.customer_trx_id := p_customer_trx_id;
        l_select_rec.source_type := p_account_class;
        l_select_rec.cust_trx_type_id := p_cust_trx_type_id;
        l_select_rec.site_use_id := p_site_use_id;
        l_select_rec.receipt_method_id := p_receipt_method_id;
        l_select_rec.bank_account_id := p_bank_account_id;

	dump_select_rec( l_select_rec );

        process_line( system_info,
                      l_select_rec,
                      p_failure_count );

        --------------------------------------------------------------------
        -- Update IN OUT NOCOPY parameters for output to Form fields
        --------------------------------------------------------------------
        p_ccid := l_select_rec.code_combination_id;
        p_concat_segments := l_select_rec.concatenated_segments;

    ELSE -- I, U or D modes


        IF( p_mode in (U, D) ) THEN
    	    --
    	    -- Delete distributions in Update and Delete mode
	    --

            ----------------------------------------------------------------
            -- Construct delete stmt
            ----------------------------------------------------------------
            DECLARE
                l_delete_stmt VARCHAR2(32767);

            BEGIN

                l_delete_c := dbms_sql.open_cursor;
                l_delete_stmt := build_delete_sql( system_info,
                                               profile_info,
                                               p_account_class,
                                               p_customer_trx_id );

                dbms_sql.parse( l_delete_c, l_delete_stmt, dbms_sql.v7 );

            EXCEPTION
                WHEN OTHERS THEN
                  debug( 'Error constructing/parsing delete cursor',
                         MSG_LEVEL_BASIC );
                  debug(SQLERRM, MSG_LEVEL_BASIC);
                  RAISE;

            END;

            ----------------------------------------------------------------
            -- Delete distributions
            ----------------------------------------------------------------
            debug( '  Deleting distributions', MSG_LEVEL_DEBUG );

            BEGIN
                l_ignore := dbms_sql.execute( l_delete_c );

                debug( to_char(l_ignore) || ' row(s) deleted',
			MSG_LEVEL_DEBUG );

                close_cursor( l_delete_c );

            EXCEPTION
                WHEN OTHERS THEN
                    debug( 'Error executing delete stmt', MSG_LEVEL_BASIC );
                    debug(SQLERRM, MSG_LEVEL_BASIC);
                    RAISE;

            END;


        END IF;  -- if mode = U, D

        IF( p_mode in (I, U) ) THEN

    	    --
    	    -- Insert distributions in Insert and Update mode
	    --

            --
            -- Fetch records using select stmt
            --

            l_select_c := Get_Select_Cursor(
                                             system_info,
                                             profile_info,
                                             p_account_class,
                                             p_customer_trx_id,
                                             p_receivable_application_id,
                                             p_br_unpaid_ccid,
                                             l_keep_cursor_open_flag);


             Bind_All_Variables(
                                 l_select_c,
                                 system_info,
                                 profile_info,
                                 p_account_class,
                                 p_customer_trx_id,
                                 p_receivable_application_id,
                                 p_br_unpaid_ccid,
                                 l_keep_cursor_open_flag);

	    l_first_fetch := TRUE;

            ----------------------------------------------------------------
            -- Execute select stmt
            ----------------------------------------------------------------
            BEGIN

		debug( '  Executing select stmt', MSG_LEVEL_DEBUG );

                l_ignore := dbms_sql.execute( l_select_c );

            EXCEPTION
                WHEN OTHERS THEN
                    debug( 'Error executing select cursor', MSG_LEVEL_BASIC );
                    debug(SQLERRM, MSG_LEVEL_BASIC);
                    RAISE;
            END;

            ---------------------------------------------------------------
            -- Fetch rows
            ---------------------------------------------------------------
	    debug( '  Fetching select stmt', MSG_LEVEL_DEBUG );

            LOOP


                BEGIN

                    IF dbms_sql.fetch_rows( l_select_c ) > 0  THEN

			debug( '  Fetched a row', MSG_LEVEL_DEBUG );

			l_first_fetch := FALSE;

                        l_select_rec := l_null_rec;
                        get_column_values( l_select_c, l_select_rec );

                        dump_select_rec( l_select_rec );

                    ELSE
                        -- no more rows to fetch
                        --
			debug( '  Done fetching', MSG_LEVEL_DEBUG );

                        IF ( l_keep_cursor_open_flag = FALSE )
                        THEN  close_cursor( l_select_c );
                        END IF;

			-- No rows selected
			IF( l_first_fetch ) THEN

			    debug( '  raising NO_DATA_FOUND',
				   MSG_LEVEL_DEBUG );
			    RAISE NO_DATA_FOUND;

			END IF;

                        EXIT;
                    END IF;

                EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			RAISE;
                    WHEN OTHERS THEN
                        debug( 'Error fetching select cursor',
	                       MSG_LEVEL_BASIC );
                               debug(SQLERRM, MSG_LEVEL_BASIC);
                        RAISE;

                END;

                process_line( system_info,
                              l_select_rec,
                              p_failure_count );

                -----------------------------------------------------------
                -- Insert row
                -----------------------------------------------------------
                BEGIN
                    insert_dist_row( system_info,
                                     profile_info,
                                     l_select_rec,
                                     p_receivable_application_id );
                EXCEPTION
                   WHEN OTHERS THEN
                       debug( 'Error inserting distributions',
                              MSG_LEVEL_BASIC );
                       debug(SQLERRM, MSG_LEVEL_BASIC);
                       RAISE;
                END;

		IF( l_select_rec.code_combination_id = -1 ) THEN

                    IF( p_account_class = REC ) THEN

			put_message_on_stack(
				MSG_COMPLETE_REC_ACCOUNT,
				l_select_rec.concatenated_segments );

		    ELSIF( p_account_class = UNPAIDREC ) THEN

			put_message_on_stack(
				MSG_COMPLETE_UNP_ACCOUNT,
				l_select_rec.concatenated_segments );

		    ELSIF( p_account_class = FACTOR ) THEN

			put_message_on_stack(
				MSG_COMPLETE_FAC_ACCOUNT,
				l_select_rec.concatenated_segments );

		    ELSIF( p_account_class = REMITTANCE ) THEN

			put_message_on_stack(
				MSG_COMPLETE_REM_ACCOUNT,
				l_select_rec.concatenated_segments );

                    END IF; --end if account class

		END IF; --end if ccid is -1

            END LOOP;

        END IF;  -- IF( p_mode in (I, U) )

    END IF;  -- IF( p_mode = G )


    -- Check if failed to get any ccids
    --
    debug( '  p_failure_count='||to_char(p_failure_count) ,
		MSG_LEVEL_DEBUG);

    IF ( l_keep_cursor_open_flag = FALSE )
    THEN  close_cursor( l_select_c );
    END IF;

    close_cursor( l_delete_c );


    print_fcn_label( 'arp_auto_accounting_br.do_autoaccounting_internal()-' );


EXCEPTION
    WHEN NO_DATA_FOUND THEN

         IF ( l_keep_cursor_open_flag = FALSE )
         THEN  close_cursor( l_select_c );
         END IF;

        close_cursor( l_delete_c );

	IF( p_mode = G ) THEN
	    NULL;	-- Don't raise for Get mode, otherwise the
			-- IN/OUT vars ccid, concat_segments do not
			-- get populated.
	ELSE
	    RAISE;
	END IF;

    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_auto_accounting_br.do_autoaccounting_internal()',
	       MSG_LEVEL_BASIC );
        debug(SQLERRM, MSG_LEVEL_BASIC);

        close_cursor( l_select_c );
        close_cursor( l_delete_c );

	ROLLBACK TO ar_auto_accounting;
        RAISE;

END do_autoaccounting_internal;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  do_autoaccounting
--
-- DECSRIPTION:
--   Entry point for autoaccounting.
--
-- ARGUMENTS:
--      IN:
--        mode:  May be I(nsert), U(pdate), D(elete), or (G)et
--        account_class:  REC, UNPAIDREC, FACTOR, REMITTANCE
--        customer_trx_id:  NULL if not applicable
--        br_unpaid_ccid: Unpaid ccid for reclassification
--        cust_trx_type_id (G)
--        site_use_id (G)
--        receipt_method_id (G)
--        bank_account_id(G)
--
--      IN/OUT:
--        ccid
--        concat_segments
--        failure_count
--
--      OUT:
--
-- NOTES:
--   If mode is not (G)et, raises the exception
--   arp_auto_accounting_br.no_ccid if autoaccounting could not derive a
--   valid code combination.  The public variable g_error_buffer is
--   populated for more information.  In (G)et mode, check the value
--   assigned to p_ccid.  If it is -1, then no ccid was found.
--
--   Raises the exception NO_DATA_FOUND if no rows were selected for
--   processing.
--
--   Exception raised if Oracle error.
--   App_exception is raised for all other fatal errors and a message
--   is put on the AOL stack.  The public variable g_error_buffer is
--   populated for both types of errors.
--
-- HISTORY:
--
--
PROCEDURE do_autoaccounting( p_mode 			 IN VARCHAR2,
                             p_account_class 		 IN VARCHAR2,
                             p_customer_trx_id 		 IN NUMBER,
                             p_receivable_application_id IN NUMBER,
                             p_br_unpaid_ccid            IN NUMBER,
                             p_cust_trx_type_id 	 IN NUMBER,
                             p_site_use_id         	 IN NUMBER,
                             p_receipt_method_id 	 IN NUMBER,
                             p_bank_account_id           IN NUMBER,
                             p_ccid 			 IN OUT NOCOPY NUMBER,
                             p_concat_segments 		 IN OUT NOCOPY VARCHAR2,
                             p_failure_count	 	 IN OUT NOCOPY NUMBER )
IS


    l_select_rec select_rec_type;
    l_null_rec   CONSTANT select_rec_type := l_select_rec;

    l_ignore   			INTEGER;
    l_boolean  			BOOLEAN;
    l_temp                      BINARY_INTEGER;
    l_account_class             VARCHAR2(20);

BEGIN

    print_fcn_label( 'arp_auto_accounting_br.do_autoaccounting()+' );

    g_error_buffer := NULL;

    --
    -- Set message level for debugging
    --
    system_info.msg_level := arp_global.msg_level;

    debug( '  mode='||p_mode, MSG_LEVEL_DEBUG );
    debug( '  account_class='||p_account_class, MSG_LEVEL_DEBUG );
    debug( '  customer_trx_id='||to_char(p_customer_trx_id), MSG_LEVEL_DEBUG );
    debug( '  receivable_application_id='||to_char(p_receivable_application_id),
           MSG_LEVEL_DEBUG );
    debug( '  br_unpaid_ccid='||to_char(p_br_unpaid_ccid), MSG_LEVEL_DEBUG );
    debug( '  cust_trx_type_id='||to_char(p_cust_trx_type_id),
		MSG_LEVEL_DEBUG );
    debug( '  site_use_id='||to_char(p_site_use_id),
       MSG_LEVEL_DEBUG );
    debug( '  receipt_method_id='||to_char(p_receipt_method_id),
		MSG_LEVEL_DEBUG );
    debug( '  bank_account_id='||to_char(p_bank_account_id), MSG_LEVEL_DEBUG );
    debug( '  msg_level='||to_char(system_info.msg_level), MSG_LEVEL_DEBUG );

    --
    -- Initialize
    --
    -- p_failure_count := 0;

    l_account_class := p_account_class;

    do_autoaccounting_internal(
			p_mode,
                        l_account_class,
                        p_customer_trx_id,
                        p_receivable_application_id,
                        p_br_unpaid_ccid,
                        p_cust_trx_type_id,
                        p_site_use_id,
                        p_receipt_method_id,
                        p_bank_account_id,
                        p_ccid,
                        p_concat_segments,
                        p_failure_count );

    -- Check if failed to get any ccids
    --
   debug( '  p_failure_count='||to_char(p_failure_count) ,
		MSG_LEVEL_DEBUG);

    IF( p_failure_count > 0 ) THEN

	debug( '  raising no_ccid', MSG_LEVEL_DEBUG );
        RAISE no_ccid;

    END IF;

    print_fcn_label( 'arp_auto_accounting_br.do_autoaccounting()-' );


EXCEPTION
    WHEN no_ccid OR NO_DATA_FOUND THEN

	IF( p_mode = G ) THEN

	    NULL;	-- Don't raise for Get mode,
			-- otherwise the IN/OUT variables
			-- ccid, concat_segments and failure_count
			-- do not get populated.
	ELSE
	    RAISE;
	END IF;

    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_auto_accounting_br.do_autoaccounting()',
	       MSG_LEVEL_BASIC );
        debug(SQLERRM, MSG_LEVEL_BASIC);

	IF( sqlcode = 1 ) THEN
	    --
	    -- User-defined exception
	    --
	    FND_MESSAGE.set_name( 'AR', 'GENERIC_MESSAGE' );
	    FND_MESSAGE.set_token( 'GENERIC_TEXT', g_error_buffer );
	    APP_EXCEPTION.raise_exception;

	ELSE
	    --
	    -- Oracle error
	    --
	    g_error_buffer := SQLERRM;

	    RAISE;

	END IF;

END do_autoaccounting;

----------------------------------------------------------------------------
PROCEDURE test_build_sql IS

    select_stmt VARCHAR2(32767);
    delete_stmt VARCHAR2(32767);
    mycursor integer;

BEGIN

    print_fcn_label( 'arp_auto_accounting_br.test_build_sql()+' );

   -----Test REC account build--------------------------

    select_stmt :=
     build_select_sql(system_info, profile_info,
                      REC, 1, NULL, NULL);
    debug(select_stmt);

   -----Test UNPAIDREC Account Build--------------------------

    select_stmt :=
    build_select_sql(system_info, profile_info,
                      UNPAIDREC, 1, NULL, NULL);
    debug(select_stmt);

   -----Test UNPAIDREC Account Build for receipt application reversal-------

     select_stmt :=
     build_select_sql(system_info, profile_info,
                      UNPAIDREC, 1, 2, NULL);
     debug(select_stmt);

   -----Test UNPAIDREC Account Build for receipt application reversal with UNPAID account-------

     select_stmt :=
     build_select_sql(system_info, profile_info,
                      UNPAIDREC, 1, 2, 3333);
     debug(select_stmt);

   -----Test REMITTANCE Account Build for receipt application reversal with UNPAID account-------

     select_stmt :=
     build_select_sql(system_info, profile_info,
                      REMITTANCE, 1, NULL, NULL);
     debug(select_stmt);

   -----Test FACTOR Account Build for receipt application reversal with UNPAID account-------

     select_stmt :=
     build_select_sql(system_info, profile_info,
                      FACTOR, 1, NULL, NULL);
     debug(select_stmt);

   -----Test FACTOR Account Build for receipt application reversal with UNPAID account-------

     delete_stmt :=
     build_delete_sql(system_info, profile_info,
                      FACTOR, 1234);
     debug(select_stmt);

    print_fcn_label( 'arp_auto_accounting_br.test_build_sql()+' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.test_build_sql()');
        debug(SQLERRM);
        RAISE;

END test_build_sql;

----------------------------------------------------------------------------
-- Constructor code
----------------------------------------------------------------------------
PROCEDURE INIT IS
BEGIN
    --enable_debug;

    print_fcn_label( 'arp_auto_accounting_br.constructor()+' );

    ------------------------------------------------------------------------
    -- Load autoaccounting definition into plsql tables
    ------------------------------------------------------------------------
    load_autoacc_def;
    system_info  := arp_trx_global.system_info;

    ------------------------------------------------------------------------
    -- Construct ccid reader sql
    ------------------------------------------------------------------------
    DECLARE
        temp varchar2(2000);

    BEGIN

        BEGIN

            ccid_reader_c := dbms_sql.open_cursor;

            temp :=
'SELECT
detail_posting_allowed_flag,
summary_flag
FROM  gl_code_combinations
WHERE code_combination_id = :ccid
';

            -- debug
            debug( 'printing ccid_reader' );
            debug( 'ccid_reader='||temp );

        EXCEPTION
            WHEN OTHERS THEN
              debug('Error constructing ccid reader');
              debug( 'ccid_reader='||temp );
              RAISE;
        END;

	--------------------------------------------------------------------
	-- parse ccid reader
	--------------------------------------------------------------------
        BEGIN

            debug( 'parsing' );
            dbms_sql.parse( ccid_reader_c, temp, dbms_sql.v7);

        EXCEPTION
            WHEN OTHERS THEN
              debug('Error parsing ccid reader');
              RAISE;
        END;

    END;

    get_error_message_text;

    dump_info;

    print_fcn_label( 'arp_auto_accounting_br.constructor()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting_br.constructor');
        debug(SQLERRM);
        RAISE;
END INIT;
BEGIN
 INIT;

END ARP_AUTO_ACCOUNTING_BR;

/
