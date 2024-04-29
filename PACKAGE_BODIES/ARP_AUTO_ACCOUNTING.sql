--------------------------------------------------------
--  DDL for Package Body ARP_AUTO_ACCOUNTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_AUTO_ACCOUNTING" AS
/* $Header: ARTEAACB.pls 120.44.12010000.15 2009/12/30 16:55:20 mraymond ship $ */

------------------------------------------------------------------------
-- Inherited from other packages
------------------------------------------------------------------------

--
-- Linefeed character
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
CRLF            CONSTANT VARCHAR2(1) := arp_global.CRLF;

YES			CONSTANT VARCHAR2(1) := arp_global.YES;
NO			CONSTANT VARCHAR2(1) := arp_global.NO;

MSG_LEVEL_BASIC 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_BASIC;
MSG_LEVEL_TIMING 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_TIMING;
MSG_LEVEL_DEBUG 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_DEBUG;
MSG_LEVEL_DEBUG2 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_DEBUG2;
MSG_LEVEL_DEVELOP 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_DEVELOP;

MAX_CURSOR_CACHE_SIZE   CONSTANT BINARY_INTEGER := 20;
MAX_SEGMENT_CACHE_SIZE  CONSTANT BINARY_INTEGER := 1000;
MAX_ARRAY_SIZE          CONSTANT BINARY_INTEGER := 1000;
STARTING_INDEX          CONSTANT BINARY_INTEGER := 1;

/* Bug 2142306 - Limits for hash and linear cache */
MAX_LINEAR_CACHE_SIZE   CONSTANT BINARY_INTEGER := 1000;
MAX_HASH_CACHE_SIZE     CONSTANT BINARY_INTEGER := 4000;
HASH_START              CONSTANT NUMBER := 16384;
HASH_MAX                CONSTANT NUMBER := 1000000;

G_MAX_DATE              CONSTANT DATE:= arp_global.G_MAX_DATE;
G_MIN_DATE              CONSTANT DATE:= to_date('01-01-1952','DD-MM-YYYY');
G_SYS_DATE              CONSTANT DATE:= TRUNC(SYSDATE);
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
-- This record holds accounting flexfield information used by
-- autoaccounting and the credit memo module.  Passed as argument to
-- most functions/procs.
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
REV             CONSTANT VARCHAR2(10) := 'REV';
REC             CONSTANT VARCHAR2(10) := 'REC';
FREIGHT         CONSTANT VARCHAR2(10) := 'FREIGHT';
TAX             CONSTANT VARCHAR2(10) := 'TAX';
UNBILL          CONSTANT VARCHAR2(10) := 'UNBILL';
UNEARN          CONSTANT VARCHAR2(10) := 'UNEARN';
SUSPENSE        CONSTANT VARCHAR2(10) := 'SUSPENSE';
CHARGES         CONSTANT VARCHAR2(10) := 'CHARGES';

/* Bug 2142306: added variables for linear search if collision occurs
                during hash checks
*/
tab_size                 NUMBER     := 0;
h_tab_size               NUMBER     := 0;

--
-- Maximum of 30 enabled segments for the accounting flex
-- so the gap between offsets is sufficient
--
rev_offset      CONSTANT BINARY_INTEGER := 0;
rec_offset      CONSTANT BINARY_INTEGER := 50;
frt_offset      CONSTANT BINARY_INTEGER := 100;
tax_offset      CONSTANT BINARY_INTEGER := 150;
unbill_offset   CONSTANT BINARY_INTEGER := 200;
unearn_offset   CONSTANT BINARY_INTEGER := 250;
suspense_offset CONSTANT BINARY_INTEGER := 300;
--
rev_count       BINARY_INTEGER := 0;
rec_count       BINARY_INTEGER := 0;
frt_count       BINARY_INTEGER := 0;
tax_count       BINARY_INTEGER := 0;
unbill_count    BINARY_INTEGER := 0;
unearn_count    BINARY_INTEGER := 0;
suspense_count  BINARY_INTEGER := 0;
--
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
TYPE trx_type_rev_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
trx_type_rev_t trx_type_rev_table_type;

TYPE trx_type_rec_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
trx_type_rec_t trx_type_rec_table_type;

TYPE trx_type_frt_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
trx_type_frt_t trx_type_frt_table_type;

TYPE trx_type_tax_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
trx_type_tax_t trx_type_tax_table_type;

TYPE trx_type_unbill_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
trx_type_unbill_t trx_type_unbill_table_type;

TYPE trx_type_unearn_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
trx_type_unearn_t trx_type_unearn_table_type;

TYPE trx_type_suspense_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
trx_type_suspense_t trx_type_suspense_table_type;

--
-- site_uses cache
--
TYPE site_use_rev_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY VARCHAR2(100);
site_use_rev_t site_use_rev_table_type;

TYPE site_use_rec_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY  VARCHAR2(100);
site_use_rec_t site_use_rec_table_type;

TYPE site_use_frt_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY  VARCHAR2(100);
site_use_frt_t site_use_frt_table_type;

TYPE site_use_tax_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY  VARCHAR2(100);
site_use_tax_t site_use_tax_table_type;

TYPE site_use_unbill_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY  VARCHAR2(100);
site_use_unbill_t site_use_unbill_table_type;

TYPE site_use_unearn_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY  VARCHAR2(100);
site_use_unearn_t site_use_unearn_table_type;

TYPE site_use_suspense_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY  VARCHAR2(100);
site_use_suspense_t site_use_suspense_table_type;

--
--
-- salesrep cache
--
TYPE salesrep_rev_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
salesrep_rev_t salesrep_rev_table_type;

TYPE salesrep_rec_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
salesrep_rec_t salesrep_rec_table_type;

TYPE salesrep_frt_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
salesrep_frt_t salesrep_frt_table_type;

--
-- inv_item cache
--
TYPE inv_item_rec_type IS RECORD (
     inventory_item_id      mtl_system_items.inventory_item_id%TYPE,
     warehouse_id           mtl_system_items.organization_id%TYPE  ,
     item_type              mtl_system_items.item_type%TYPE,
     sales_account          mtl_system_items.sales_account%TYPE
    );

TYPE inv_item_rev_table_type IS
     TABLE OF inv_item_rec_type
     INDEX BY VARCHAR2(1000);

inv_item_rev_t inv_item_rev_table_type;

g_item_ctr BINARY_INTEGER :=0;

--
-- memo_line cache
--
TYPE memo_line_rev_table_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;
memo_line_rev_t memo_line_rev_table_type;

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
    trx_type_ccid_rev           BINARY_INTEGER := -1,
    trx_type_ccid_rec           BINARY_INTEGER := -1,
    trx_type_ccid_frt           BINARY_INTEGER := -1,
    trx_type_ccid_tax           BINARY_INTEGER := -1,
    trx_type_ccid_unbill        BINARY_INTEGER := -1,
    trx_type_ccid_unearn        BINARY_INTEGER := -1,
    trx_type_ccid_suspense      BINARY_INTEGER := -1,
    salesrep_ccid_rev           BINARY_INTEGER := -1,
    salesrep_ccid_rec           BINARY_INTEGER := -1,
    salesrep_ccid_frt           BINARY_INTEGER := -1,
    lineitem_ccid_rev           BINARY_INTEGER := -1,
    tax_ccid_tax                BINARY_INTEGER := -1,
    agreecat_ccid_rev           BINARY_INTEGER := -1,
    interim_tax_ccid            BINARY_INTEGER := -1,
    site_use_ccid_rev           BINARY_INTEGER := -1,
    site_use_ccid_rec           BINARY_INTEGER := -1,
    site_use_ccid_frt           BINARY_INTEGER := -1,
    site_use_ccid_tax           BINARY_INTEGER := -1,
    site_use_ccid_unbill        BINARY_INTEGER := -1,
    site_use_ccid_unearn        BINARY_INTEGER := -1,
    site_use_ccid_suspense      BINARY_INTEGER := -1
);

--
-- To hold values fetched from the Select stmt
--
TYPE select_rec_type IS RECORD
(
  customer_trx_id                     NUMBER,
  customer_trx_line_id                NUMBER,
  cust_trx_line_salesrep_id           NUMBER,
  line_amount                         NUMBER,
  accounted_line_amount               NUMBER,
  percent                             NUMBER,
  amount                              NUMBER,
  acctd_amount                        NUMBER,
  account_class                       VARCHAR2(20),
  account_set_flag                    VARCHAR2(1),
  cust_trx_type_id                    BINARY_INTEGER,
  allow_not_open_flag                 VARCHAR2(1),
  concatenated_segments               VARCHAR2(240),
  code_combination_id                 BINARY_INTEGER,
  gl_date                             VARCHAR2(12),     -- Julian format
  original_gl_date                    VARCHAR2(12),     -- Julian format
  ussgl_trx_code                      VARCHAR2(30),
  ussgl_trx_code_context              VARCHAR2(30),
  salesrep_id                         NUMBER,
  inventory_item_id                   NUMBER,
  memo_line_id                        NUMBER,
  default_tax_ccid                    BINARY_INTEGER,
  interim_tax_ccid                    BINARY_INTEGER,
  int_concatenated_segments           VARCHAR2(240),
  int_code_combination_id             BINARY_INTEGER,
  site_use_id                         NUMBER,
  warehouse_id                        NUMBER,
  link_to_cust_trx_line_id            NUMBER  -- 1651593
);

--
-- To hold values fetched from the Select stmt
--
TYPE select_rec_tab IS RECORD
(
  customer_trx_id                     DBMS_SQL.NUMBER_TABLE,
  customer_trx_line_id                DBMS_SQL.NUMBER_TABLE,
  cust_trx_line_salesrep_id           DBMS_SQL.NUMBER_TABLE,
  line_amount                         DBMS_SQL.NUMBER_TABLE,
  accounted_line_amount               DBMS_SQL.NUMBER_TABLE,
  percent                             DBMS_SQL.NUMBER_TABLE,
  amount                              DBMS_SQL.NUMBER_TABLE,
  acctd_amount                        DBMS_SQL.NUMBER_TABLE,
  account_class                       DBMS_SQL.VARCHAR2_TABLE,
  account_set_flag                    DBMS_SQL.VARCHAR2_TABLE,
  cust_trx_type_id                    DBMS_SQL.NUMBER_TABLE,
  allow_not_open_flag                 DBMS_SQL.VARCHAR2_TABLE,
  concatenated_segments               DBMS_SQL.VARCHAR2_TABLE,
  code_combination_id                 DBMS_SQL.NUMBER_TABLE,
  gl_date                             DBMS_SQL.VARCHAR2_TABLE,     -- Julian format
  original_gl_date                    DBMS_SQL.VARCHAR2_TABLE,     -- Julian format
  ussgl_trx_code                      DBMS_SQL.VARCHAR2_TABLE,
  ussgl_trx_code_context              DBMS_SQL.VARCHAR2_TABLE,
  salesrep_id                         DBMS_SQL.NUMBER_TABLE,
  inventory_item_id                   DBMS_SQL.NUMBER_TABLE,
  memo_line_id                        DBMS_SQL.NUMBER_TABLE,
  default_tax_ccid                    DBMS_SQL.NUMBER_TABLE,
  interim_tax_ccid                    DBMS_SQL.NUMBER_TABLE,
  int_concatenated_segments           DBMS_SQL.VARCHAR2_TABLE,
  int_code_combination_id             DBMS_SQL.NUMBER_TABLE,
  site_use_id                         DBMS_SQL.NUMBER_TABLE,
  warehouse_id                        DBMS_SQL.NUMBER_TABLE,
  link_to_cust_trx_line_id            DBMS_SQL.NUMBER_TABLE -- 1651593
);

g_select_rec_tab                      select_rec_tab;
/* Bug-2178723 : Cached the values of detail_posting_allowed_flag and summary_flag
                 in pl/sql table to avoid the high execution count  */

TYPE code_comb_rec_type IS RECORD
  ( detail_posting_flag  gl_code_combinations.detail_posting_allowed_flag%TYPE,
    summary_flag         gl_code_combinations.summary_flag%TYPE);

TYPE t_ar_code_comb_table IS TABLE OF code_comb_rec_type
    INDEX BY BINARY_INTEGER;

pg_ar_code_comb_rec t_ar_code_comb_table;

-- set invalid segvalue to null
--
INVALID_SEGMENT CONSTANT VARCHAR2(20) := '';

--
-- Cursor handles
--

--
-- CCID Validation date
--
validation_date  DATE := TRUNC(SYSDATE);


-- User-defined exceptions
--
invalid_account_class		EXCEPTION;
invalid_table_name              EXCEPTION;     -- in autoacc def
item_and_memo_both_not_null     EXCEPTION;
error_defaulting_gl_date	EXCEPTION;


--
-- Translated error messages
--
MSG_COMPLETE_REV_ACCOUNT 	varchar2(2000);
MSG_COMPLETE_REC_ACCOUNT 	varchar2(2000);
MSG_COMPLETE_FRT_ACCOUNT 	varchar2(2000);
MSG_COMPLETE_TAX_ACCOUNT 	varchar2(2000);
MSG_COMPLETE_CHARGES_ACCOUNT 	varchar2(2000);
MSG_COMPLETE_OFFSET_ACCOUNT 	varchar2(2000);
MSG_COMPLETE_INT_TAX_ACCOUNT	varchar2(2000);

MSG_FLEX_POSTING_NOT_ALLOWED	varchar2(2000);
MSG_FLEX_NO_PARENT_ALLOWED	varchar2(2000);


I               CONSTANT VARCHAR2(1) := 'I';
U               CONSTANT VARCHAR2(1) := 'U';
D               CONSTANT VARCHAR2(1) := 'D';
G               CONSTANT VARCHAR2(1) := 'G';

-- code combination segment, ID, Start and End Date caches
-- bug 2142306: revised cache and linear tables for autoaccounting

autoacc_hash_id_cache           autoacc_cache_id_type;
autoacc_hash_seg_cache          autoacc_cache_seg_type;
autoacc_hash_st_date_cache      autoacc_cache_date_type;
autoacc_hash_end_date_cache     autoacc_cache_date_type;

autoacc_lin_id_cache            autoacc_cache_id_type;
autoacc_lin_seg_cache           autoacc_cache_seg_type;
autoacc_lin_st_date_cache       autoacc_cache_date_type;
autoacc_lin_end_date_cache      autoacc_cache_date_type;

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

/* Bug 2560036 - Collectibility results table and flags */
/* Table for recording collectibility results */
t_collect                ar_revenue_management_pvt.long_number_table;
/* flag that indicates if collectibility is enabled */
g_test_collectibility    boolean;
/* flag that indicates if collectibility has already
   been called in current session */
g_called_collectibility  boolean := FALSE;

----------------------------------------------------------------------------
-- Covers
----------------------------------------------------------------------------
PROCEDURE debug( p_line IN VARCHAR2 ) IS
BEGIN
    IF PG_DEBUG IN ('C','Y')
    THEN
       arp_util.debug( p_line );
    END IF;
END;

PROCEDURE debug( p_str VARCHAR2, p_print_level BINARY_INTEGER ) IS
BEGIN
    IF PG_DEBUG IN ('C','Y')
    THEN
       arp_util.debug( p_str, p_print_level );
    END IF;
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
   IF PG_DEBUG IN ('C', 'Y')
   THEN
      arp_util.print_fcn_label( p_label );
   END IF;
END;

PROCEDURE print_fcn_label2( p_label VARCHAR2 ) IS
BEGIN
   IF PG_DEBUG IN ('C', 'Y')
   THEN
     arp_util.print_fcn_label2( p_label );
   END IF;
END;

PROCEDURE close_cursor( p_cursor_handle IN OUT NOCOPY INTEGER ) IS
BEGIN
    arp_util.close_cursor( p_cursor_handle );
END;



----------------------------------------------------------------------------
-- Procedures and Functions
----------------------------------------------------------------------------


PROCEDURE insert_into_error_table(
	p_interface_line_id number,
	p_message_text varchar2,
	p_invalid_value varchar2 )  IS

BEGIN

    INSERT INTO ra_interface_errors
    (interface_line_id,
     message_text,
     invalid_value,
     org_id)
    VALUES
    (p_interface_line_id,
     p_message_text,
     p_invalid_value,
     ARP_STANDARD.sysparm.org_id);

END insert_into_error_table;

PROCEDURE put_message_on_stack(
	p_interface_line_id number,
	p_message_text varchar2,
	p_invalid_value varchar2,
        p_request_id    binary_integer )  IS

BEGIN
        IF ( p_request_id IS NOT NULL ) THEN
        IF ( p_request_id > 0)
        THEN
           IF p_interface_line_id < 0 THEN

	      -- Since, we cannot derive the receivables account for a invoice,
	      -- we insert error for each invoice line.

	      FOR c01_rec IN (select interface_line_id from ra_interface_lines_gt
			      WHERE customer_trx_id = -1 * p_interface_line_id
			      AND   request_id      = p_request_id ) LOOP
                 insert_into_error_table(
                                 c01_rec.interface_line_id,
                                 p_message_text,
                                 p_invalid_value );

              END LOOP;
	   ELSE
              insert_into_error_table(
                              p_interface_line_id,
                              p_message_text,
                              p_invalid_value );
           END IF;
	-- the following code has been added by bsarkar to log the
	-- error for Invoice API. Request_id will be always -ve
   	-- for invoice api and instead of logging into the standard
	-- error table it will log into global error table for
	-- invoice api.

        ELSIF (p_request_id < 0 )
	THEN
	     -- for Invoice API request id will be always -ve
	     -- get the details for which line autoaccounting failed.
	    FOR invRec IN ( select trx_header_id,trx_line_id
		            from ar_trx_lines_gt
			    where request_id = p_request_id
			    and   customer_trx_line_id = p_interface_line_id
			    UNION
			    select trx_header_id, -99
			    from ar_trx_header_gt
			    where request_id = p_request_id
			    and   customer_trx_id = -1 * p_interface_line_id )		   loop
            	insert into ar_trx_errors_gt
                    	(trx_header_id,
			 trx_line_id,
			 error_message,
                     	 invalid_value) values
                        ( invRec.trx_header_id,
			  decode(invRec.trx_line_id,-99,null,invRec.trx_line_id),
			  p_message_text,
                          p_invalid_value);
	   end loop;
        END IF;
        ELSE

            FND_MESSAGE.set_name( 'AR', 'GENERIC_MESSAGE' );
            FND_MESSAGE.set_token( 'GENERIC_TEXT', p_message_text );

        END IF;
END put_message_on_stack;


----------------------------------------------------------------------------
PROCEDURE get_error_message_text is

    l_application_id  NUMBER := 222;
    l_msg_name	   VARCHAR2(100);

BEGIN

    print_fcn_label( 'arp_auto_accounting.get_error_message_text()+' );

    l_msg_name := '1360';
    fnd_message.set_name('AR', l_msg_name);
    MSG_COMPLETE_REV_ACCOUNT := fnd_message.get;

    ----
    l_msg_name := '1350';
    fnd_message.set_name('AR', l_msg_name);
    MSG_COMPLETE_REC_ACCOUNT := fnd_message.get;

    ----
    l_msg_name := '1370';
    fnd_message.set_name('AR', l_msg_name);
    MSG_COMPLETE_FRT_ACCOUNT := fnd_message.get;

    ----
    l_msg_name := 'I-120';
    fnd_message.set_name('AR', l_msg_name);
    MSG_COMPLETE_TAX_ACCOUNT := fnd_message.get;

    ----
    l_msg_name := '1365';
    fnd_message.set_name('AR', l_msg_name);
    MSG_COMPLETE_CHARGES_ACCOUNT := fnd_message.get;

    ----
    l_msg_name := 'AR_AUTOACC_COMPLETE_OFFSET';
    fnd_message.set_name('AR', l_msg_name);
    MSG_COMPLETE_OFFSET_ACCOUNT := fnd_message.get;

    ----
    l_msg_name := 'RA_POSTING_NOT_ALLOWED';
    fnd_message.set_name('AR', l_msg_name);
    MSG_FLEX_POSTING_NOT_ALLOWED := fnd_message.get;

    ----
    l_msg_name := 'FLEX-No Parent';
    fnd_message.set_name('AR', l_msg_name);
    MSG_FLEX_NO_PARENT_ALLOWED := fnd_message.get;

    ----
    l_msg_name := 'AR_COMPLETE_INT_TAX_ACCOUNT';
    fnd_message.set_name('AR', l_msg_name);
    MSG_COMPLETE_INT_TAX_ACCOUNT := fnd_message.get;

    -- print
    debug( '  MSG_COMPLETE_REV_ACCOUNT='||MSG_COMPLETE_REV_ACCOUNT,
	MSG_LEVEL_DEBUG );
    debug( '  MSG_COMPLETE_REC_ACCOUNT='||MSG_COMPLETE_REC_ACCOUNT,
	MSG_LEVEL_DEBUG );
    debug( '  MSG_COMPLETE_FRT_ACCOUNT='||MSG_COMPLETE_FRT_ACCOUNT,
	MSG_LEVEL_DEBUG );
    debug( '  MSG_COMPLETE_TAX_ACCOUNT='||MSG_COMPLETE_TAX_ACCOUNT,
	MSG_LEVEL_DEBUG );
    debug( '  MSG_COMPLETE_INT_TAX_ACCOUNT='||MSG_COMPLETE_INT_TAX_ACCOUNT,
	MSG_LEVEL_DEBUG );
    debug( '  MSG_COMPLETE_OFFSET_ACCOUNT='||MSG_COMPLETE_OFFSET_ACCOUNT,
	MSG_LEVEL_DEBUG );

    debug( '  MSG_FLEX_POSTING_NOT_ALLOWED='||MSG_FLEX_POSTING_NOT_ALLOWED,
	MSG_LEVEL_DEBUG );
    debug( '  MSG_FLEX_NO_PARENT_ALLOWED='||MSG_FLEX_NO_PARENT_ALLOWED,
	MSG_LEVEL_DEBUG );

    print_fcn_label( 'arp_auto_accounting.get_error_message_text()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.get_error_message_text()');
        RAISE;
END get_error_message_text;

----------------------------------------------------------------------------
PROCEDURE expand_account_class( p_account_class IN OUT NOCOPY VARCHAR2 ) IS
BEGIN

    --
    -- Adjust account_class to proper string
    --
    IF( substrb(p_account_class, 1, 3) = 'REV' ) THEN
        p_account_class := REV;
    ELSIF( substrb(p_account_class, 1, 3) = 'REC' ) THEN
        p_account_class := REC;
    ELSIF( substrb(p_account_class, 1, 3) = 'FRE' ) THEN
        p_account_class := FREIGHT;
    ELSIF( substrb(p_account_class, 1, 3) = 'TAX' ) THEN
        p_account_class := TAX;
    ELSIF( substrb(p_account_class, 1, 3) = 'UNB' ) THEN
        p_account_class := UNBILL;
    ELSIF( substrb(p_account_class, 1, 3) = 'UNE' ) THEN
        p_account_class := UNEARN;
    ELSIF( substrb(p_account_class, 1, 3) = 'SUS' ) THEN
        p_account_class := SUSPENSE;
    ELSIF( substrb(p_account_class, 1, 3) = 'CHA' ) THEN
        p_account_class := CHARGES ;
    END IF;

END expand_account_class;

----------------------------------------------------------------------------
PROCEDURE dump_info IS
BEGIN

    -- sys info
    debug( '  coa_id='||to_char(system_info.chart_of_accounts_id),
	    MSG_LEVEL_DEBUG);
    debug( '  curr='||system_info.base_currency, MSG_LEVEL_DEBUG);
    debug( '  prec='||to_char(system_info.base_precision), MSG_LEVEL_DEBUG);
    debug( '  mau='||to_char(system_info.base_min_acc_unit), MSG_LEVEL_DEBUG);

    IF( system_info.rev_based_on_salesrep ) THEN
        debug( '  rev_based_on_salesrep=TRUE', MSG_LEVEL_DEBUG );
    ELSE
        debug( '  rev_based_on_salesrep=FALSE', MSG_LEVEL_DEBUG );
    END IF;

    IF( system_info.tax_based_on_salesrep ) THEN
        debug( '  tax_based_on_salesrep=TRUE', MSG_LEVEL_DEBUG );
    ELSE
        debug( '  tax_based_on_salesrep=FALSE', MSG_LEVEL_DEBUG );
    END IF;

    IF( system_info.unbill_based_on_salesrep ) THEN
        debug( '  unbill_based_on_salesrep=TRUE', MSG_LEVEL_DEBUG );
    ELSE
        debug( '  unbill_based_on_salesrep=FALSE', MSG_LEVEL_DEBUG );
    END IF;

    IF( system_info.unearn_based_on_salesrep ) THEN
        debug( '  unearn_based_on_salesrep=TRUE', MSG_LEVEL_DEBUG );
    ELSE
        debug( '  unearn_based_on_salesrep=FALSE', MSG_LEVEL_DEBUG );
    END IF;

    IF( system_info.suspense_based_on_salesrep ) THEN
        debug( '  suspense_based_on_salesrep=TRUE', MSG_LEVEL_DEBUG );
    ELSE
        debug( '  suspense_based_on_salesrep=FALSE', MSG_LEVEL_DEBUG );
    END IF;


    -- profile info
    debug( '  login_id='||profile_info.conc_login_id, MSG_LEVEL_DEBUG );
    debug( '  program_id='||profile_info.conc_program_id, MSG_LEVEL_DEBUG );
    debug( '  user_id='||profile_info.user_id, MSG_LEVEL_DEBUG );
    debug( '  use_inv_acct='||profile_info.use_inv_acct_for_cm_flag,
           MSG_LEVEL_DEBUG );

    /*Bug 8640674*/
    IF(arp_global.sysparam.org_id IS NOT NULL) THEN
    debug( '  org_id='||oe_profile.value('SO_ORGANIZATION_ID',arp_global.sysparam.org_id),
               MSG_LEVEL_DEBUG );
    END IF;

    -- flex info
    debug( '  nsegs='||to_char(flex_info.number_segments), MSG_LEVEL_DEBUG);
    debug( '  delim='||flex_info.delim, MSG_LEVEL_DEBUG);

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.dump_info()', MSG_LEVEL_BASIC);
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
    print_fcn_label( 'arp_auto_accounting.dump_ccid_record()+' );

    debug( '  Dumping CCID record:', MSG_LEVEL_DEBUG );

    debug( '  trx_type_ccid_rev=' ||
           to_char(p_ccid_record.trx_type_ccid_rev ), MSG_LEVEL_DEBUG );
    debug( '  trx_type_ccid_rec=' ||
           to_char(p_ccid_record.trx_type_ccid_rec ), MSG_LEVEL_DEBUG );
    debug( '  trx_type_ccid_frt=' ||
           to_char(p_ccid_record.trx_type_ccid_frt ), MSG_LEVEL_DEBUG );
    debug( '  trx_type_ccid_tax=' ||
           to_char(p_ccid_record.trx_type_ccid_tax ), MSG_LEVEL_DEBUG );
    debug( '  trx_type_ccid_unbill=' ||
           to_char(p_ccid_record.trx_type_ccid_unbill ), MSG_LEVEL_DEBUG );
    debug( '  trx_type_ccid_unearn=' ||
           to_char(p_ccid_record.trx_type_ccid_unearn ), MSG_LEVEL_DEBUG );
    debug( '  trx_type_ccid_suspense=' ||
           to_char(p_ccid_record.trx_type_ccid_suspense ), MSG_LEVEL_DEBUG );
    debug( '  site_use_ccid_rev=' ||
           to_char(p_ccid_record.site_use_ccid_rev ), MSG_LEVEL_DEBUG );
    debug( '  site_use_ccid_rec=' ||
           to_char(p_ccid_record.site_use_ccid_rec ), MSG_LEVEL_DEBUG );
    debug( '  site_use_ccid_frt=' ||
           to_char(p_ccid_record.site_use_ccid_frt ), MSG_LEVEL_DEBUG );
    debug( '  site_use_ccid_tax=' ||
           to_char(p_ccid_record.site_use_ccid_tax ), MSG_LEVEL_DEBUG );
    debug( '  site_use_ccid_unbill=' ||
           to_char(p_ccid_record.site_use_ccid_unbill ), MSG_LEVEL_DEBUG );
    debug( '  site_use_ccid_unearn=' ||
           to_char(p_ccid_record.site_use_ccid_unearn ), MSG_LEVEL_DEBUG );
    debug( '  site_use_ccid_suspense=' ||
           to_char(p_ccid_record.site_use_ccid_suspense ), MSG_LEVEL_DEBUG );
    debug( '  salesrep_ccid_rev=' ||
           to_char(p_ccid_record.salesrep_ccid_rev ), MSG_LEVEL_DEBUG );
    debug( '  salesrep_ccid_rec=' ||
           to_char(p_ccid_record.salesrep_ccid_rec ), MSG_LEVEL_DEBUG );
    debug( '  salesrep_ccid_frt=' ||
           to_char(p_ccid_record.salesrep_ccid_frt ), MSG_LEVEL_DEBUG );
    debug( '  lineitem_ccid_rev=' ||
           to_char(p_ccid_record.lineitem_ccid_rev ), MSG_LEVEL_DEBUG );
    debug( '  tax_ccid_tax=' ||
           to_char(p_ccid_record.tax_ccid_tax ), MSG_LEVEL_DEBUG );
    debug( '  agreecat_ccid_rev=' ||
           to_char(p_ccid_record.agreecat_ccid_rev ), MSG_LEVEL_DEBUG );
    debug( '  interim_tax_ccid=' ||
           to_char(p_ccid_record.interim_tax_ccid ), MSG_LEVEL_DEBUG );

    print_fcn_label( 'arp_auto_accounting.dump_ccid_record()-' );

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
    l_rev_index         BINARY_INTEGER := rev_offset;
    l_rec_index         BINARY_INTEGER := rec_offset;
    l_frt_index         BINARY_INTEGER := frt_offset;
    l_tax_index         BINARY_INTEGER := tax_offset;
    l_unbill_index      BINARY_INTEGER := unbill_offset;
    l_unearn_index      BINARY_INTEGER := unearn_offset;
    l_suspense_index    BINARY_INTEGER := suspense_offset;
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
    AND   ad.org_id = NVL(arp_global.sysparam.org_id, ad.org_id)
    AND   ad.type in
    (
     'REV', 'REC', 'FREIGHT', 'TAX', 'UNBILL', 'UNEARN', 'SUSPENSE'
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
    print_fcn_label( 'arp_auto_accounting.load_autoacc_def()+' );
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
        IF( autoacc_rec.type in (REV, CHARGES) ) then
          load(l_rev_index, rev_count, autoacc_rec);
        ELSIF( autoacc_rec.type = REC ) then
          load(l_rec_index, rec_count, autoacc_rec);
        ELSIF( autoacc_rec.type = FREIGHT ) then
          load(l_frt_index, frt_count, autoacc_rec);
        ELSIF( autoacc_rec.type = TAX ) then
          load(l_tax_index, tax_count, autoacc_rec);
        ELSIF( autoacc_rec.type = UNBILL ) then
          load(l_unbill_index, unbill_count, autoacc_rec);
        ELSIF( autoacc_rec.type = UNEARN ) then
          load(l_unearn_index, unearn_count, autoacc_rec);
        ELSIF( autoacc_rec.type = SUSPENSE ) then
          load(l_suspense_index, suspense_count, autoacc_rec);
        END IF;
    END LOOP;

    print_fcn_label( 'arp_auto_accounting.load_autoacc_def()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.load_autoacc_def()',
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
--   on a given table.
--
-- ARGUMENTS:
--      IN:
--        account_class:
--          'REV', 'REC', 'FRE', 'TAX', 'UNB', 'UNE', 'SUS'
--          'CHA'
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
--   if account_class = 'ALL', check all seven account classes in cache
--   else check particular account class in cache
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
    print_fcn_label( 'arp_auto_accounting.query_autoacc_def()+' );

    g_error_buffer := NULL;

    --
    -- Adjust account_class to proper string
    --
    l_account_class := p_account_class;
    expand_account_class( l_account_class );

    IF l_account_class = 'ALL' THEN
        retval := query_autoacc_def(REV, p_table_name) OR
                query_autoacc_def(REC, p_table_name) OR
                query_autoacc_def(FREIGHT, p_table_name) OR
                query_autoacc_def(TAX, p_table_name) OR
                query_autoacc_def(UNBILL, p_table_name) OR
                query_autoacc_def(UNEARN, p_table_name) OR
                query_autoacc_def(SUSPENSE, p_table_name);
    ELSE
        IF l_account_class in (REV, CHARGES) THEN
            retval := search_table( rev_offset, rev_count);
        ELSIF l_account_class = REC THEN
            retval := search_table( rec_offset, rec_count);
        ELSIF l_account_class = FREIGHT THEN
            retval := search_table( frt_offset, frt_count);
        ELSIF l_account_class = TAX THEN
            retval := search_table( tax_offset, tax_count);
        ELSIF l_account_class = UNBILL THEN
            retval := search_table( unbill_offset, unbill_count);
        ELSIF l_account_class = UNEARN THEN
            retval := search_table( unearn_offset, unearn_count);
        ELSIF l_account_class = SUSPENSE THEN
            retval := search_table( suspense_offset, suspense_count);
        ELSE
	    g_error_buffer := 'Invalid account class';
	    debug( 'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
            RAISE invalid_account_class;
        END IF;
    END IF;

    print_fcn_label( 'arp_auto_accounting.query_autoacc_def()-' );

    RETURN retval;


EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.query_autoacc_def('
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
--        ccid_rev
--        ccid_rec
--        ccid_frt
--        ccid_tax
--        ccid_unbill
--        ccid_unearn
--        ccid_suspense
--
--      OUT:
--
-- NOTES:
--
-- HISTORY:
--
PROCEDURE get_trx_type_ccids( p_trx_type_id 	IN BINARY_INTEGER,
                               p_ccid_rev 	IN OUT NOCOPY BINARY_INTEGER,
                               p_ccid_rec 	IN OUT NOCOPY BINARY_INTEGER,
                               p_ccid_frt 	IN OUT NOCOPY BINARY_INTEGER,
                               p_ccid_tax 	IN OUT NOCOPY BINARY_INTEGER,
                               p_ccid_unbill 	IN OUT NOCOPY BINARY_INTEGER,
                               p_ccid_unearn 	IN OUT NOCOPY BINARY_INTEGER,
                               p_ccid_suspense 	IN OUT NOCOPY BINARY_INTEGER)  IS
BEGIN
    print_fcn_label2( 'arp_auto_accounting.get_trx_type_ccids()+' );

    --
    -- initialize
    --
    p_ccid_rev := -1;
    p_ccid_rec := -1;
    p_ccid_frt := -1;
    p_ccid_tax := -1;
    p_ccid_unbill := -1;
    p_ccid_unearn := -1;
    p_ccid_suspense := -1;


    BEGIN
        -- see if available in cache
        --
        p_ccid_rev := trx_type_rev_t( p_trx_type_id );
        p_ccid_rec := trx_type_rec_t( p_trx_type_id );
        p_ccid_frt := trx_type_frt_t( p_trx_type_id );
        p_ccid_tax := trx_type_tax_t( p_trx_type_id );
        p_ccid_unbill := trx_type_unbill_t( p_trx_type_id );
        p_ccid_unearn := trx_type_unearn_t( p_trx_type_id );
        p_ccid_suspense := trx_type_suspense_t( p_trx_type_id );

        debug( '  cache hit: trx_type_id='||to_char(p_trx_type_id),
               MSG_LEVEL_DEBUG );

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- else, get it from the database
            --
            debug( '  cache miss: trx_type_id='||to_char(p_trx_type_id),
                   MSG_LEVEL_DEBUG );

            SELECT
              nvl(gl_id_rev,-1),
              nvl(gl_id_rec,-1),
              nvl(gl_id_freight,-1),
              nvl(gl_id_tax,-1),
              nvl(gl_id_unbilled,-1),
              nvl(gl_id_unearned,-1),
              nvl(gl_id_clearing,-1)
            INTO
              p_ccid_rev,
              p_ccid_rec,
              p_ccid_frt,
              p_ccid_tax,
              p_ccid_unbill,
              p_ccid_unearn,
              p_ccid_suspense
            FROM ra_cust_trx_types
            WHERE cust_trx_type_id = p_trx_type_id;

            -- update cache
	    trx_type_rev_t( p_trx_type_id ) := p_ccid_rev;
            trx_type_rec_t( p_trx_type_id ) := p_ccid_rec;
            trx_type_frt_t( p_trx_type_id ) := p_ccid_frt;
            trx_type_tax_t( p_trx_type_id ) := p_ccid_tax;
            trx_type_unbill_t( p_trx_type_id ) := p_ccid_unbill;
            trx_type_unearn_t( p_trx_type_id ) := p_ccid_unearn;
            trx_type_suspense_t( p_trx_type_id ) := p_ccid_suspense;
    END;


    print_fcn_label2( 'arp_auto_accounting.get_trx_type_ccids()-' );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	debug('arp_auto_accounting.get_trx_type_ccids(): no data found',
	      MSG_LEVEL_DEBUG);
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.get_trx_type_ccids('
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
--   for a given bill to site use id.
--
-- ARGUMENTS:
--      IN:
--        site_use_id
--
--      IN/OUT:
--        ccid_rev
--        ccid_rec
--        ccid_frt
--        ccid_tax
--        ccid_unbill
--        ccid_unearn
--        ccid_suspense
--
--      OUT:
--
-- NOTES:
--
-- HISTORY:
--
PROCEDURE get_site_use_ccids( p_site_use_id 	IN number,
                               p_ccid_rev 	IN OUT NOCOPY BINARY_INTEGER,
                               p_ccid_rec 	IN OUT NOCOPY BINARY_INTEGER,
                               p_ccid_frt 	IN OUT NOCOPY BINARY_INTEGER,
                               p_ccid_tax 	IN OUT NOCOPY BINARY_INTEGER,
                               p_ccid_unbill 	IN OUT NOCOPY BINARY_INTEGER,
                               p_ccid_unearn 	IN OUT NOCOPY BINARY_INTEGER,
                               p_ccid_suspense 	IN OUT NOCOPY BINARY_INTEGER)  IS
BEGIN
    print_fcn_label2( 'arp_auto_accounting.get_site_use_ccids()+' );

    --
    -- initialize
    --
    p_ccid_rev := -1;
    p_ccid_rec := -1;
    p_ccid_frt := -1;
    p_ccid_tax := -1;
    p_ccid_unbill := -1;
    p_ccid_unearn := -1;
    p_ccid_suspense := -1;


    BEGIN
        -- see if available in cache
        --
        p_ccid_rev := site_use_rev_t( p_site_use_id );
        p_ccid_rec := site_use_rec_t( p_site_use_id );
        p_ccid_frt := site_use_frt_t( p_site_use_id );
        p_ccid_tax := site_use_tax_t( p_site_use_id );
        p_ccid_unbill := site_use_unbill_t( p_site_use_id );
        p_ccid_unearn := site_use_unearn_t( p_site_use_id );
        p_ccid_suspense := site_use_suspense_t( p_site_use_id );

        debug( '  cache hit: site_use_id='||to_char(p_site_use_id),
               MSG_LEVEL_DEBUG );

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- else, get it from the database
            --
            debug( '  cache miss: site_use_id='||to_char(p_site_use_id),
                   MSG_LEVEL_DEBUG );

            SELECT
              nvl(gl_id_rev,-1),
              nvl(gl_id_rec,-1),
              nvl(gl_id_freight,-1),
              nvl(gl_id_tax,-1),
              nvl(gl_id_unbilled,-1),
              nvl(gl_id_unearned,-1),
              nvl(gl_id_clearing,-1)
            INTO
              p_ccid_rev,
              p_ccid_rec,
              p_ccid_frt,
              p_ccid_tax,
              p_ccid_unbill,
              p_ccid_unearn,
              p_ccid_suspense
            FROM hz_cust_site_uses
            WHERE site_use_id = p_site_use_id;

            -- update cache
	    site_use_rev_t( p_site_use_id ) := p_ccid_rev;
            site_use_rec_t( p_site_use_id ) := p_ccid_rec;
            site_use_frt_t( p_site_use_id ) := p_ccid_frt;
            site_use_tax_t( p_site_use_id ) := p_ccid_tax;
            site_use_unbill_t( p_site_use_id ) := p_ccid_unbill;
            site_use_unearn_t( p_site_use_id ) := p_ccid_unearn;
            site_use_suspense_t( p_site_use_id ) := p_ccid_suspense;
    END;


    print_fcn_label2( 'arp_auto_accounting.get_site_use_ccids()-' );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	debug('arp_auto_accounting.get_site_use_ccids(): no data found',
	      MSG_LEVEL_DEBUG);
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.get_site_use_ccids('
              || to_char(p_site_use_id) ||')', MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END get_site_use_ccids;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  get_salesrep_ccids
--
-- DECSRIPTION:
--   Retrieves default ccids from the table ra_salesreps
--   for a given salesrep_id.
--
-- ARGUMENTS:
--      IN:
--        salesrep_id
--
--      IN/OUT:
--        ccid_rev
--        ccid_rec
--        ccid_frt
--
--      OUT:
--
-- NOTES:
--
-- HISTORY:
--
--
PROCEDURE get_salesrep_ccids( p_salesrep_id 	IN BINARY_INTEGER,
                               p_ccid_rev 	IN OUT NOCOPY BINARY_INTEGER,
                               p_ccid_rec 	IN OUT NOCOPY BINARY_INTEGER,
                               p_ccid_frt 	IN OUT NOCOPY BINARY_INTEGER ) IS
BEGIN

    print_fcn_label2( 'arp_auto_accounting.get_salesrep_ccids()+' );

    p_ccid_rev := -1;
    p_ccid_rec := -1;
    p_ccid_frt := -1;

    BEGIN
        -- see if available in cache
        --
        p_ccid_rev := salesrep_rev_t( p_salesrep_id );
        p_ccid_rec := salesrep_rec_t( p_salesrep_id );
        p_ccid_frt := salesrep_frt_t( p_salesrep_id );

        debug( '  cache hit: salesrep_id='||to_char(p_salesrep_id),
               MSG_LEVEL_DEBUG );

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- else, get it from the database
            --
            debug( '  cache miss: salesrep_id='||to_char(p_salesrep_id),
                   MSG_LEVEL_DEBUG );

            SELECT
              nvl(gl_id_rev,-1),
              nvl(gl_id_rec,-1),
              nvl(gl_id_freight,-1)
            INTO p_ccid_rev, p_ccid_rec, p_ccid_frt
            FROM ra_salesreps
            WHERE salesrep_id = p_salesrep_id;

            -- update cache
	    salesrep_rev_t( p_salesrep_id ) := p_ccid_rev;
            salesrep_rec_t( p_salesrep_id ) := p_ccid_rec;
            salesrep_frt_t( p_salesrep_id ) := p_ccid_frt;

    END;

    print_fcn_label2( 'arp_auto_accounting.get_salesrep_ccids()-' );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	debug('arp_auto_accounting.get_salesrep_ccids(): no data found',
	      MSG_LEVEL_DEBUG);
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.get_salesrep_ccids('
              || to_char(p_salesrep_id) ||')', MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END get_salesrep_ccids;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  get_inv_item_ccids
--
-- DECSRIPTION:
--   Retrieves default ccids from the table mtl_system_items
--   for a given item_id.
--
-- ARGUMENTS:
--      IN:
--        profile_info
--        item_id
--
--      IN/OUT:
--        ccid_rev
--        inv_item_type
--
--      OUT:
--
-- NOTES:
--
-- HISTORY:
--
--
PROCEDURE get_inv_item_ccids( p_profile_info 	IN
	                          arp_trx_global.profile_rec_type,
                              p_inv_item_id 	IN BINARY_INTEGER,
                              p_warehouse_id    IN BINARY_INTEGER,
                              p_ccid_rev IN 	OUT NOCOPY BINARY_INTEGER,
                              p_inv_item_type 	IN OUT NOCOPY
                                  mtl_system_items.item_type%TYPE ) IS
l_ctr BINARY_INTEGER;
l_hit BOOLEAN := FALSE;
t_warehouse_id BINARY_INTEGER;

BEGIN

    print_fcn_label2( 'arp_auto_accounting.get_inv_item_ccids()+' );

    p_ccid_rev := -1;
    p_inv_item_type := NULL;
    t_warehouse_id  := nvl(p_warehouse_id,
                                         to_number(oe_profile.value('SO_ORGANIZATION_ID',arp_global.sysparam.org_id)));
    BEGIN
       --
       -- see if available in cache
       --


               IF ((inv_item_rev_t(p_inv_item_id || ':' || t_warehouse_id).inventory_item_id = p_inv_item_id)
                  AND (inv_item_rev_t(p_inv_item_id || ':' || t_warehouse_id).warehouse_id
                              = t_warehouse_id))
               THEN

                 l_hit           := TRUE;
                 p_inv_item_type := inv_item_rev_t(p_inv_item_id || ':' || t_warehouse_id).item_type;
                 p_ccid_rev      := inv_item_rev_t(p_inv_item_id || ':' || t_warehouse_id).sales_account;

                 debug( '  cache hit: Item Id='||to_char(p_inv_item_id),
                        MSG_LEVEL_DEBUG );
                 debug( '  cache hit: Warehouse_id='||
                       t_warehouse_id,
                        MSG_LEVEL_DEBUG );
                 debug('Index is: ' || p_inv_item_id || ':' || t_warehouse_id);
                 debug( '  cache hit: Item Type='|| p_inv_item_type,
                        MSG_LEVEL_DEBUG );
                 debug( '  cache hit: revenue account='||to_char(p_ccid_rev),
                        MSG_LEVEL_DEBUG );


               END IF; --end if inventory_item_id:warehouse_id key matches


       --
       --Raise explicitly exception as item warehouse id combination did not exist in
       --cache, hence get from the database
       --

        IF NOT l_hit THEN
           RAISE NO_DATA_FOUND;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- else, get it from the database
            --
            debug( '  cache miss: inv_item_id='||to_char(p_inv_item_id),
                   MSG_LEVEL_DEBUG );
            debug( '  cache miss: warehouse_id='||to_char(p_warehouse_id),
                   MSG_LEVEL_DEBUG );

            SELECT nvl(sales_account, -1), nvl(item_type, '~')
            INTO   p_ccid_rev,
                   p_inv_item_type
            FROM   mtl_system_items
            WHERE  organization_id
                       = t_warehouse_id
            AND    inventory_item_id = p_inv_item_id;

            -- update cache
            debug( 'Inserting into the cache: ');
            debug('Index is: ' || p_inv_item_id || ':' || t_warehouse_id);
            inv_item_rev_t(p_inv_item_id || ':' || t_warehouse_id).inventory_item_id := p_inv_item_id;

            inv_item_rev_t(p_inv_item_id || ':' || t_warehouse_id).warehouse_id
                        := t_warehouse_id;
            inv_item_rev_t(p_inv_item_id || ':' || t_warehouse_id).item_type := p_inv_item_type;
            --debug('Inventory Item Type is: ' || p_inv_item_type);
            inv_item_rev_t(p_inv_item_id || ':' || t_warehouse_id).sales_account := p_ccid_rev;
            --debug('Sales Account: ' || p_ccid_rev);

    END;

    print_fcn_label2( 'arp_auto_accounting.get_inv_item_ccids()-' );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	debug('arp_auto_accounting.get_inv_item_ccids(): no data found',
	      MSG_LEVEL_DEBUG);
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.get_inv_item_ccids('
              || to_char(p_inv_item_id) ||')', MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END get_inv_item_ccids;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  get_memo_line_ccids
--
-- DECSRIPTION:
--   Retrieves default ccids from the table ar_memo_lines
--   for a given memo_line_id.
--
-- ARGUMENTS:
--      IN:
--        memo_line_id
--
--      IN/OUT:
--        ccid_rev
--
--      OUT:
--
-- NOTES:
--
-- HISTORY:
--
--
PROCEDURE get_memo_line_ccids( p_memo_line_id 	IN BINARY_INTEGER,
                               p_ccid_rev 	IN OUT NOCOPY BINARY_INTEGER ) IS
BEGIN

    print_fcn_label2( 'arp_auto_accounting.get_memo_line_ccids()+' );

    p_ccid_rev := -1;

    BEGIN
        -- see if available in cache
        --
        p_ccid_rev := memo_line_rev_t( p_memo_line_id );

        debug( '  cache hit: memo_line_id='||to_char(p_memo_line_id),
               MSG_LEVEL_DEBUG );

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- else, get it from the database
            --
            debug( '  cache miss: memo_line_id='||to_char(p_memo_line_id),
                   MSG_LEVEL_DEBUG );

            SELECT nvl(gl_id_rev,-1)
            INTO p_ccid_rev
            FROM ar_memo_lines
            WHERE memo_line_id = p_memo_line_id;

            -- update cache
	    memo_line_rev_t( p_memo_line_id ) := p_ccid_rev;

    END;

    print_fcn_label2( 'arp_auto_accounting.get_memo_line_ccids()-' );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	debug('arp_auto_accounting.get_memo_line_ccids(): no data found',
	      MSG_LEVEL_DEBUG);
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.get_memo_line_ccids('
              || to_char(p_memo_line_id) ||')', MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END get_memo_line_ccids;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  get_agreecat_ccids
--
-- DECSRIPTION:
--   Retrieves default ccids for agreement/category if autoaccounting for
--   revenue is based on agreement/category
--
-- ARGUMENTS:
--      IN:
--        profile_info
--        line_id
--
--      IN/OUT:
--
--      OUT:
--        ccid_rev
--
-- NOTES:
--
-- HISTORY:
--
--
PROCEDURE get_agreecat_ccids( p_profile_info 	IN
                                  arp_trx_global.profile_rec_type,
                              p_line_id 	IN number,
			      p_warehouse_id    IN BINARY_INTEGER,       --Bug#1639334
                              p_ccid_rev 	OUT NOCOPY BINARY_INTEGER ) IS
BEGIN

    print_fcn_label2( 'arp_auto_accounting.get_agreecat_ccids()+' );

    p_ccid_rev := -1;

    SELECT nvl(c.code_combination_id,-1)
    INTO   p_ccid_rev
    FROM
      ra_customer_trx t,
      ra_customer_trx_lines l,
      mtl_item_categories i,
      so_agreements a,
      ra_account_combinations c
    WHERE  t.customer_trx_id      = l.customer_trx_id
    AND    l.customer_trx_line_id = p_line_id
    AND    t.agreement_id         = a.agreement_id(+)
    AND    l.inventory_item_id    = i.inventory_item_id(+)
    AND    i.organization_id(+)
                     = nvl(p_warehouse_id,
                           to_number(oe_profile.value('SO_ORGANIZATION_ID',arp_global.sysparam.org_id)))     --Bug#1639334
    AND    i.category_set_id(+)   = 1
    AND    to_char(nvl(i.category_id, -1)) = c.value1
    AND    nvl(a.agreement_type_code, -1) = nvl(c.value2 , -1);

    print_fcn_label2( 'arp_auto_accounting.get_agreecat_ccids()-' );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	debug('arp_auto_accounting.get_agreecat_ccids(): no data found',
	      MSG_LEVEL_DEBUG);
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.get_agreecat_ccids('
              || to_char(p_line_id) ||')', MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END get_agreecat_ccids;

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
 print_fcn_label( 'arp_auto_accounting.get_combination_id()+' );

    r_value := FND_FLEX_KEYVAL.validate_segs('CREATE_COMBINATION',
        application_short_name, key_flex_code, structure_number,
	concat_segments, 'V',
        validation_date);
    if( r_value ) then
      combination_id := FND_FLEX_KEYVAL.combination_id;
      print_fcn_label( 'arp_auto_accounting.get_combination_id()-' );
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
    print_fcn_label( 'arp_auto_accounting.get_combination_id1()+' );

--  Concatenate the input segments, then send them to the other function.
--
    sepchar := fnd_flex_ext.get_delimiter(application_short_name, key_flex_code,
                             structure_number);
    if(sepchar is not null) then
      print_fcn_label( 'arp_auto_accounting.get_combination_id1()-' );
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
    print_fcn_label2( 'arp_auto_accounting.define_columns()+' );

    dbms_sql.define_column( p_select_c, 1, p_select_rec.customer_trx_id );
    dbms_sql.define_column( p_select_c, 2, p_select_rec.customer_trx_line_id );
    dbms_sql.define_column( p_select_c, 3,
                            p_select_rec.cust_trx_line_salesrep_id );
    dbms_sql.define_column( p_select_c, 4, p_select_rec.line_amount );
    dbms_sql.define_column( p_select_c, 5,
                            p_select_rec.accounted_line_amount );
    dbms_sql.define_column( p_select_c, 6, p_select_rec.percent );
    dbms_sql.define_column( p_select_c, 7, p_select_rec.amount );
    dbms_sql.define_column( p_select_c, 8, p_select_rec.acctd_amount );
    dbms_sql.define_column( p_select_c, 9, p_select_rec.account_class, 20 );
    dbms_sql.define_column( p_select_c, 10, p_select_rec.account_set_flag, 1 );
    dbms_sql.define_column( p_select_c, 11, p_select_rec.cust_trx_type_id );
    dbms_sql.define_column( p_select_c, 12,
                            p_select_rec.allow_not_open_flag, 1 );
    dbms_sql.define_column( p_select_c, 13,
                            p_select_rec.concatenated_segments, 240 );
    dbms_sql.define_column( p_select_c, 14, p_select_rec.code_combination_id );
    dbms_sql.define_column( p_select_c, 15, p_select_rec.gl_date, 12 );
    dbms_sql.define_column( p_select_c, 16,
                            p_select_rec.original_gl_date, 12 );
    dbms_sql.define_column( p_select_c, 17, p_select_rec.ussgl_trx_code, 30 );
    dbms_sql.define_column( p_select_c, 18,
                            p_select_rec.ussgl_trx_code_context, 30 );
    dbms_sql.define_column( p_select_c, 19, p_select_rec.salesrep_id );
    dbms_sql.define_column( p_select_c, 20, p_select_rec.inventory_item_id );
    dbms_sql.define_column( p_select_c, 21, p_select_rec.memo_line_id );
    dbms_sql.define_column( p_select_c, 22, p_select_rec.default_tax_ccid );
    dbms_sql.define_column( p_select_c, 23, p_select_rec.interim_tax_ccid );
    dbms_sql.define_column( p_select_c, 24, p_select_rec.site_use_id);
    dbms_sql.define_column( p_select_c, 25, p_select_rec.warehouse_id);

    print_fcn_label2( 'arp_auto_accounting.define_columns()-' );
EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.define_columns()',
		MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END define_columns;
----------------------------------------------------------------------------

PROCEDURE define_arrays( p_select_c   IN INTEGER,
                          p_select_tab IN select_rec_tab) IS
BEGIN
    print_fcn_label2( 'arp_auto_accounting.define_arrays()+' );

    dbms_sql.define_array( p_select_c, 1, p_select_tab.customer_trx_id, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 2, p_select_tab.customer_trx_line_id, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 3,
                            p_select_tab.cust_trx_line_salesrep_id, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 4, p_select_tab.line_amount, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 5,
                            p_select_tab.accounted_line_amount, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 6, p_select_tab.percent, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 7, p_select_tab.amount, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 8, p_select_tab.acctd_amount, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 9, p_select_tab.account_class, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 10, p_select_tab.account_set_flag, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 11, p_select_tab.cust_trx_type_id, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 12,
                            p_select_tab.allow_not_open_flag, MAX_ARRAY_SIZE, STARTING_INDEX);
    dbms_sql.define_array( p_select_c, 13,
                            p_select_tab.concatenated_segments, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 14, p_select_tab.code_combination_id, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 15, p_select_tab.gl_date, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 16,
                            p_select_tab.original_gl_date, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 17, p_select_tab.ussgl_trx_code, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 18,
                            p_select_tab.ussgl_trx_code_context, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 19, p_select_tab.salesrep_id, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 20, p_select_tab.inventory_item_id, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 21, p_select_tab.memo_line_id, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 22, p_select_tab.default_tax_ccid, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 23, p_select_tab.interim_tax_ccid, MAX_ARRAY_SIZE, STARTING_INDEX );
    dbms_sql.define_array( p_select_c, 24, p_select_tab.site_use_id, MAX_ARRAY_SIZE, STARTING_INDEX);
    dbms_sql.define_array( p_select_c, 25, p_select_tab.warehouse_id, MAX_ARRAY_SIZE, STARTING_INDEX);
 -- 1651593
    dbms_sql.define_array( p_select_c, 26, p_select_tab.link_to_cust_trx_line_id, MAX_ARRAY_SIZE, STARTING_INDEX );

    print_fcn_label2( 'arp_auto_accounting.define_arrays()-' );
EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.define_arrays()',
		MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END define_arrays;


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
--        customer_trx_line_id
--        cust_trx_line_salesrep_id
--        request_id
--        gl_date
--        original_gl_date
--        total_trx_amount
--        code_combination_id
--        force_account_set_no
--        cust_trx_type_id
--        primary_salesrep_id
--        inventory_item_id
--        memo_line_id
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
--    14-FEB-97  C. Tomberg  Modified to use bind variables
--
FUNCTION build_select_sql( p_system_info 		IN
                             arp_trx_global.system_info_rec_type,
                           p_profile_info 		IN
                             arp_trx_global.profile_rec_type,
                           p_account_class 		IN VARCHAR2,
                           p_customer_trx_id 		IN BINARY_INTEGER,
                           p_customer_trx_line_id 	IN number,
                           p_cust_trx_line_salesrep_id 	IN number,
                           p_request_id 		IN BINARY_INTEGER,
                           p_gl_date 			IN DATE,
                           p_original_gl_date 		IN DATE,
                           p_total_trx_amount 		IN NUMBER,
                           p_code_combination_id 	IN BINARY_INTEGER,
                           p_force_account_set_no 	IN VARCHAR2,
                           p_cust_trx_type_id 		IN BINARY_INTEGER,
                           p_primary_salesrep_id 	IN BINARY_INTEGER,
                           p_inventory_item_id 		IN BINARY_INTEGER,
                           p_memo_line_id 		IN BINARY_INTEGER,
			   p_use_unearn_srep_dependency IN BOOLEAN DEFAULT FALSE)
  RETURN VARCHAR2 IS

    l_based_on_salesrep_flag    BOOLEAN := FALSE;

    l_select_stmt               VARCHAR2(32767);

    l_amount_fragment           VARCHAR2(200);
    l_ccid_fragment             VARCHAR2(100);
    l_decode_fragment           VARCHAR2(1000);
    l_line_type_fragment        VARCHAR2(100);
    l_rule_id_fragment          VARCHAR2(100);
    l_rule_fragment             VARCHAR2(700);
    l_tax_table_fragment        VARCHAR2(100);

    l_gl_date_attribute         VARCHAR2(1000);
    l_orig_gl_date_attribute    VARCHAR2(2000);
    l_salesrep_attributes1      VARCHAR2(10000);
    l_salesrep_attributes2      VARCHAR2(1000);
    l_tax_attribute             VARCHAR2(512);

    l_gl_dist_table             VARCHAR2(100);
    l_interface_lines_table     VARCHAR2(100);
    l_inv_gl_dist_table         VARCHAR2(100);
    l_salesreps_table           VARCHAR2(100);
    l_tax_table                 VARCHAR2(100);

    l_based_on_salesrep_pred    VARCHAR2(500);
    l_cm_module_pred            VARCHAR2(500);
    l_interface_table_pred      VARCHAR2(500);
    l_inv_rec_pred              VARCHAR2(500);
    l_line_id_pred              VARCHAR2(500);
    l_line_salesrep_id_pred     VARCHAR2(100);
    l_prevent_dup_rec_pred      VARCHAR2(2000);
    l_request_id_pred           VARCHAR2(2000);
    l_suspense_pred             VARCHAR2(100);
    l_tax_pred                  VARCHAR2(500);
    l_trx_id_pred               VARCHAR2(100);
    l_base_precision		fnd_currencies.precision%type;
    l_base_min_acc_unit         VARCHAR2(20);

BEGIN

    print_fcn_label( 'arp_auto_accounting.build_select_sql()+' );

    l_base_precision     := ARP_GLOBAL.base_precision;

    /* 9222866 - this variable used as a literal in dynamic sql.
         so the value NULL must be represented as 'NULL' and numeric
         values returned as themselves.  */
    l_base_min_acc_unit  := NVL(TO_CHAR(ARP_GLOBAL.base_min_acc_unit),
                                 'NULL');

    ------------------------------------------------------------------------
    -- Initialize building blocks
    ------------------------------------------------------------------------
    debug( '  Initialize fragments', MSG_LEVEL_DEVELOP );

    l_amount_fragment := 'nvl(ctl.revenue_amount, ctl.extended_amount)';
    l_rule_id_fragment := '= nvl(ct.invoicing_rule_id, -10)';
    l_tax_table_fragment := 'ctl';
    l_tax_attribute := CRLF ||'to_number(''''),to_number(''''),';

    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    -- Construct "building blocks" for the Select statement:
    --     string fragments
    --     attributes
    --     table names
    --     predicates
    ------------------------------------------------------------------------
    ------------------------------------------------------------------------

    ------------------------------------------------------------------------
    -- Construct fragments
    ------------------------------------------------------------------------

    -- If the force account set no flag is Y,
    -- then always treat this line as a non account set distribution
    -- otherwise, treat it normally.
    debug('  If the force account set no flag is Y', MSG_LEVEL_DEVELOP);


    l_rule_fragment :=
'decode( NVL(:force_account_set_no, ''N''),
        ''N'', ct.invoicing_rule_id,
             decode(''' ||p_account_class || ''',
                    ''UNBILL'', ct.invoicing_rule_id,
                    ''UNEARN'', ct.invoicing_rule_id,
                              decode(nvl(ctl.accounting_rule_duration, 0),
                                    1, decode(nvl(ctl.autorule_duration_processed, 0),
                                              0, ct.invoicing_rule_id,
                                                 null),
                                         ct.invoicing_rule_id
                                    )
                   )
      )';


    ------------------------------------------------------------------------
    -- Construct code_combination_id fragment
    ------------------------------------------------------------------------
    debug('  Construct code_combination_id fragment', MSG_LEVEL_DEVELOP);

    IF( p_code_combination_id IS NULL ) THEN

        -- IF   Use Invoice Accounting is Yes,
        -- AND  the account class is Receivable,
        -- AND  no CCID was passed in
        -- THEN use the invoice's receivable CCID
        IF( p_profile_info.use_inv_acct_for_cm_flag = 'Y'
            AND p_account_class = REC ) THEN

            l_ccid_fragment :=
'nvl(lgd_inv_rec.code_combination_id, to_number(''''))';

        ELSE

            l_ccid_fragment := 'to_number('''')';

        END IF;
    ELSE

        l_ccid_fragment := ' :code_combination_id ';

    END IF;


    ------------------------------------------------------------------------
    -- account_class
    ------------------------------------------------------------------------
    debug('  account_class', MSG_LEVEL_DEVELOP);

    IF( p_account_class = REV ) THEN

        IF(p_system_info.rev_based_on_salesrep
	    OR (P_use_unearn_srep_dependency
	        AND p_system_info.unearn_based_on_salesrep)) THEN
            l_based_on_salesrep_flag := TRUE;
        END IF;

        l_line_type_fragment := '= ''LINE''';
        l_decode_fragment :=
'decode(' || l_rule_fragment || ',
         null, decode(ctl.extended_amount,
                      0, 1,
                      ctl.revenue_amount / ctl.extended_amount),
         1
        ) *';

    ELSIF( p_account_class = REC ) THEN

        l_amount_fragment :=
'decode(:total_trx_amount,
       NULL, to_number(''''),
             to_char( :total_trx_amount )
      )' || CRLF;

        l_line_type_fragment := '(+) = ''~!''';


    ELSIF( p_account_class = FREIGHT ) THEN

        l_line_type_fragment := '= ''FREIGHT''';
        l_tax_table_fragment := 'ctl_line';

    ELSIF( p_account_class = TAX ) THEN

        IF( p_system_info.tax_based_on_salesrep ) THEN
            l_based_on_salesrep_flag := TRUE;
        END IF;

        l_line_type_fragment := '= ''TAX''';
        l_tax_table_fragment := 'ctl_line';

       /* 4558268 - Replaced source of tax and interim tax ccids */
        l_tax_attribute := CRLF ||
'arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                rgd.gl_date, ''TAX''),'
          || CRLF ||
'arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                rgd.gl_date, ''INTERIM''),';

    ELSIF( p_account_class = UNBILL ) THEN
        /* Bug 2354293 - Consider UNEARN/UNBILL tied to salesreps
           if REV is... This prevents multiple UNEARN lines with 100%
           for a single REV line. */
        IF( p_system_info.unbill_based_on_salesrep or
            p_system_info.rev_based_on_salesrep) THEN
            l_based_on_salesrep_flag := TRUE;
        END IF;

        l_line_type_fragment := '= ''LINE''';
        l_rule_id_fragment := '= -3';

    ELSIF( p_account_class = UNEARN ) THEN
        /* Bug 2354293 */
        IF( p_system_info.unearn_based_on_salesrep or
            p_system_info.rev_based_on_salesrep) THEN
            l_based_on_salesrep_flag := TRUE;
        END IF;

        l_line_type_fragment := '= ''LINE''';
        l_rule_id_fragment := '= -2';

    ELSIF( p_account_class = SUSPENSE ) THEN

        IF( p_system_info.suspense_based_on_salesrep ) THEN
            l_based_on_salesrep_flag := TRUE;
        END IF;

        l_line_type_fragment := '= ''LINE''';
        l_amount_fragment := '(ctl.extended_amount - ctl.revenue_amount)';
        l_decode_fragment :=
'decode(' || l_rule_fragment ||',
         null, decode( (ctl.extended_amount),
                       0, 1,
                       (ctl.extended_amount - ctl.revenue_amount) /
                         ctl.extended_amount
                     ),
         1
       ) * ';

    ELSIF( p_account_class = CHARGES ) THEN

        IF( p_system_info.rev_based_on_salesrep ) THEN
            l_based_on_salesrep_flag := TRUE;
        END IF;

        l_line_type_fragment := '= ''CHARGES''';

    END IF;

    ------------------------------------------------------------------------
    -- Construct select attribute strings
    ------------------------------------------------------------------------
    debug('  Build select attribute strings', MSG_LEVEL_DEVELOP);

    IF( l_based_on_salesrep_flag ) THEN

        debug('  l_salesrep_attributes1', MSG_LEVEL_DEBUG);
        debug('  l_rule_fragment='||l_rule_fragment, MSG_LEVEL_DEBUG);
        debug('  l_amount_fragment='||l_amount_fragment, MSG_LEVEL_DEBUG);
        debug('  l_decode_fragment='||l_decode_fragment, MSG_LEVEL_DEBUG);

        l_salesrep_attributes1 := CRLF ||
'ctls.cust_trx_line_salesrep_id,  /* cust_trx_line_salesrep_id */
decode(' || l_rule_fragment || ',
       NULL, ' || l_amount_fragment || ',
       to_number('''')),                               /* line_amount */
decode(' || l_rule_fragment || ',
       NULL, decode(' || l_base_min_acc_unit || ',
                    NULL, round( (' || l_amount_fragment || '*
                                  nvl(ct.exchange_rate, 1)),
                                 ' || l_base_precision || '),
                    round((' || l_amount_fragment || ' *
                           nvl(ct.exchange_rate, 1)) /
                           ' || l_base_min_acc_unit || ')
                                     * ' || l_base_min_acc_unit || '
                   ),
       to_number('''')),                     /* accounted_line_amount */
round(' || l_decode_fragment || '
      decode(ctls.salesrep_id,
             NULL, 100,
             nvl(ctls.revenue_percent_split, 0)),
      4),       /* percent */
decode(' || l_rule_fragment || ',
       NULL,
       decode(fc_foreign.minimum_accountable_unit,
              NULL, round ( (' || l_amount_fragment || ' *
                             decode(ctls.salesrep_id,
                                    NULL, 100,
                                    nvl(ctls.revenue_percent_split, 0))/ 100),
                           fc_foreign.precision),
              round (  (' || l_amount_fragment || ' *
                         decode(ctls.salesrep_id,
                                NULL, 100,
                                nvl(ctls.revenue_percent_split,0)) / 100) /
                         fc_foreign.minimum_accountable_unit )  *
                fc_foreign.minimum_accountable_unit ),
       to_number('''')),                                      /* amount */
decode(' || l_rule_fragment || ',
        NULL,
        decode (' || l_base_min_acc_unit || ',
                NULL,
                round (decode(fc_foreign.minimum_accountable_unit,
                              NULL,
                              round ((' || l_amount_fragment || ' *
                                       decode(ctls.salesrep_id,
                                              NULL, 100,
                                              nvl(ctls.revenue_percent_split,
                                                  0)) / 100),
                                      fc_foreign.precision),
                              round ((' || l_amount_fragment || ' *
                                      decode(ctls.salesrep_id,
                                             NULL, 100,
                                             nvl(ctls.revenue_percent_split,0))
                                              / 100) /
                                     fc_foreign.minimum_accountable_unit ) *
                                fc_foreign.minimum_accountable_unit
                             ) * nvl(ct.exchange_rate, 1),
                       ' || l_base_precision || ' ),
                round ((decode( fc_foreign.minimum_accountable_unit,
                                NULL, round((' || l_amount_fragment || ' *
                                       decode(ctls.salesrep_id,
                                              NULL, 100,
                                              nvl(ctls.revenue_percent_split,
                                                  0)) / 100),
                                            fc_foreign.precision),
                                round((' || l_amount_fragment || ' *
                                        decode(ctls.salesrep_id,
                                               NULL, 100,
                                             nvl(ctls.revenue_percent_split,0))
                                               / 100) /
                                      fc_foreign.minimum_accountable_unit )  *
                                  fc_foreign.minimum_accountable_unit
                              ) * nvl(ct.exchange_rate, 1) )
                         / ' || l_base_min_acc_unit || ' )  *
                  ' || l_base_min_acc_unit || '
               ),
        to_number('''')),                               /* acctd_amount */';


        debug('  l_salesrep_attributes2', MSG_LEVEL_DEVELOP);

        l_salesrep_attributes2 := CRLF ||
'nvl(ctl.default_ussgl_transaction_code,
    ct.default_ussgl_transaction_code),     /* ussgl_trx_code */
nvl(ctl.default_ussgl_trx_code_context,
    ct.default_ussgl_trx_code_context), /* ussgl_trx_code_cntxt*/
ctls.salesrep_id,                              /* salesrep_id */
'|| l_tax_table_fragment ||'.inventory_item_id,  /* inventory_item_id */
'|| l_tax_table_fragment ||'.memo_line_id,      /* memo_line_id */';


    ELSE  -- not based on salesreps...

        l_salesrep_attributes1 := CRLF ||
'to_number(''''),                   /* cust_trx_line_salesrep_id */
decode(' || l_rule_fragment || ',
        NULL, ' || l_amount_fragment || ',
        to_number('''')),                       /* line_amount */
decode(' || l_rule_fragment || ',
        NULL, decode(' || l_base_min_acc_unit || ',
                     NULL, round((' || l_amount_fragment || ' *
                                   nvl(ct.exchange_rate, 1)),
                                   ' || l_base_precision || '),
                     round((' || l_amount_fragment || ' *
                             nvl(ct.exchange_rate, 1)) /
                             ' || l_base_min_acc_unit || ')
                       * ' || l_base_min_acc_unit || '
                    ),
        to_number('''')),             /* accounted_line_amount */
round(' || l_decode_fragment || ' 100, 4),    /* percent */
decode(' || l_rule_fragment || ',
        NULL, ' || l_amount_fragment || ',
        to_number('''') ),                       /* amount */
decode(' || l_rule_fragment || ',
        NULL, decode( ' || l_base_min_acc_unit || ',
                      NULL, round ((' || l_amount_fragment || ' *
                                     nvl(ct.exchange_rate, 1)),
                                   ' || l_base_precision || '),
                      round((' || l_amount_fragment || ' *
                                nvl(ct.exchange_rate, 1)) /
                                ' || l_base_min_acc_unit || ' )  *
                        ' || l_base_min_acc_unit || '
                    ),
        to_number('''')),                        /* acctd_amt */';


        l_salesrep_attributes2 := CRLF ||
'nvl(ctl.default_ussgl_transaction_code,
    ct.default_ussgl_transaction_code),     /* ussgl_trx_code */
nvl(ctl.default_ussgl_trx_code_context,
    ct.default_ussgl_trx_code_context), /* ussgl_trx_code_cntxt*/
ct.primary_salesrep_id,                        /* salesrep_id */
'|| l_tax_table_fragment ||'.inventory_item_id, /* inventory_item_id */
'|| l_tax_table_fragment || '.memo_line_id,     /* memo_line_id */';

    END IF; -- if based on salesreps

    debug( '  len(l_salesrep_attributes1)=' ||
           to_char(LENGTHB(l_salesrep_attributes1)),
           MSG_LEVEL_DEBUG );
    debug( '  len(l_salesrep_attributes2)=' ||
           to_char(LENGTHB(l_salesrep_attributes2)),
           MSG_LEVEL_DEBUG );


    ------------------------------------------------------------------------
    -- Construct gl_date attribute string
    ------------------------------------------------------------------------
    debug('  Construct gl_date attribute string', MSG_LEVEL_DEVELOP);

    IF( p_gl_date IS NULL ) THEN
        /* 5590182 */
        /* 5921925 - removed request_id > 0 condition */
        IF( p_account_class = REC AND p_request_id IS NOT NULL)
        THEN

            l_gl_date_attribute := CRLF ||
'to_char(ril.gl_date, ''J''),                         /* gl_date */';

        ELSE
            IF( p_account_class = REC AND
                p_request_id IS NULL)
            THEN

                l_gl_date_attribute := CRLF ||
'to_char(rgd.gl_date, ''J''),                         /* gl_date */';

            ELSE

                l_gl_date_attribute := CRLF ||
'decode('|| l_rule_fragment ||',
       NULL, to_char(rgd.gl_date, ''J''),
       '''' ),                                 /* gl_date */';

            END IF;
        END IF;
    ELSE  -- p_gl_date NOT NULL
        IF( p_account_class = REC ) THEN

            l_gl_date_attribute := CRLF ||
'to_char(nvl(rgd.gl_date, :gl_date), ''J''), /* gl_date */';

        ELSE
            l_gl_date_attribute := CRLF ||
'decode('|| l_rule_fragment ||',
        NULL, to_char(nvl(rgd.gl_date, :gl_date), ''J''),
        '''' ),                                 /* gl_date */';

        END IF;


    END IF;

    ------------------------------------------------------------------------
    -- Construct original_gl_date attribute string
    ------------------------------------------------------------------------
    debug('  Construct original_gl_date attribute string',
          MSG_LEVEL_DEVELOP);

    l_orig_gl_date_attribute := CRLF ||
'decode( :original_gl_date,
        NULL, decode(' || l_rule_fragment || ',
                     NULL, to_char(rgd.original_gl_date, ''J''),
                            '''' ),
              decode(' || l_rule_fragment || ',
                      NULL, to_char(nvl(rgd.original_gl_date,
                              :original_gl_date), ''J''),
                            '''' )
     ),                              /* orig_gl_date */';


    ------------------------------------------------------------------------
    -- Construct table strings
    ------------------------------------------------------------------------
    debug('  tables', MSG_LEVEL_DEVELOP);

    IF( p_account_class = REC
        AND p_gl_date IS NULL
        AND p_request_id IS NOT NULL)
    THEN
        /* 5921925 - modified gl_date logic for invoice API */
        IF  p_request_id > 0
        THEN
           l_interface_lines_table := CRLF ||'ra_interface_lines_gt ril,';
        ELSE
           l_interface_lines_table := CRLF ||'ar_trx_header_gt ril,';
        END IF;
    END IF;

    IF( p_profile_info.use_inv_acct_for_cm_flag = 'Y'
        AND p_account_class = REC
        AND p_code_combination_id IS NULL ) THEN

        l_inv_gl_dist_table := CRLF ||'ra_cust_trx_line_gl_dist lgd_inv_rec,';

    END IF;

    IF( l_based_on_salesrep_flag ) THEN

        l_salesreps_table := CRLF ||'ra_cust_trx_line_salesreps ctls,';

    END IF;

    IF( p_account_class in ( TAX, FREIGHT ) )  THEN

     /* 4558268 - Removed tax tables */
        l_tax_table := CRLF ||
'ra_customer_trx_lines ctl_line,';

    END IF;

    IF( p_account_class = REC )  THEN

        l_gl_dist_table := CRLF ||'ra_cust_trx_line_gl_dist lgd,';

    END IF;

    ------------------------------------------------------------------------
    -- Construct predicates
    ------------------------------------------------------------------------

    ------------------------------------------------------------------------
    -- Prevent AutoAccounting from creating records that should
    -- be created by the credit memo module.
    ------------------------------------------------------------------------

    debug('  Prevent AutoAccounting from creating records', MSG_LEVEL_DEVELOP);

    IF( p_profile_info.use_inv_acct_for_cm_flag = 'Y'
        AND p_account_class <> REC ) THEN

        l_cm_module_pred := CRLF ||
'          /* Prevent AutoAccounting from creating records that should
             be created by the credit memo module. */
AND        (ct.previous_customer_trx_id    is null';

        IF( p_code_combination_id IS NOT NULL
            AND p_account_class = FREIGHT ) THEN

            l_cm_module_pred := l_cm_module_pred || '
            or (ct.invoicing_rule_id is null)';

        END IF;

        l_cm_module_pred := l_cm_module_pred || ')';

    END IF;

    ------------------------------------------------------------------------
    -- Prevent duplicate records from being created
    ------------------------------------------------------------------------
    debug('  Prevent duplicate records from being created', MSG_LEVEL_DEVELOP);

    IF( p_account_class = REC ) THEN

        l_prevent_dup_rec_pred := CRLF ||
'           /* prevent duplicate records from being created */
AND        ct.customer_trx_id             = lgd.customer_trx_id(+)
AND        ''REC''                          = lgd.account_class(+)
AND        decode(ct.invoicing_rule_id,
                  NULL, ''N'',
                        ''Y'' )             = lgd.account_set_flag(+)
AND        lgd.customer_trx_id            is null';

    ELSE
        l_prevent_dup_rec_pred := CRLF ||
'           /* prevent duplicate records from being created */
AND        not exists
               (SELECT ';
-- bug 7557904
IF( p_request_id IS NOT NULL ) THEN
	l_prevent_dup_rec_pred := l_prevent_dup_rec_pred || '   /*+ INDEX (lgd RA_CUST_TRX_LINE_GL_DIST_N10)*/ ';
ELSE
        l_prevent_dup_rec_pred := l_prevent_dup_rec_pred || '   /*+ INDEX (lgd RA_CUST_TRX_LINE_GL_DIST_N1)*/ ';
END IF;

l_prevent_dup_rec_pred := l_prevent_dup_rec_pred || '
                  ''distribution exists''
                FROM   ra_cust_trx_line_gl_dist lgd
                WHERE  ctl.customer_trx_id      = lgd.customer_trx_id
                AND    ctl.customer_trx_line_id = lgd.customer_trx_line_id ';


        IF( p_request_id IS NOT NULL ) THEN
            l_prevent_dup_rec_pred := l_prevent_dup_rec_pred || '
                and    lgd.request_id =
                         :request_id1 ';
        END IF;


        IF( p_cust_trx_line_salesrep_id IS NOT NULL ) THEN
            l_prevent_dup_rec_pred := l_prevent_dup_rec_pred || '
                and    lgd.cust_trx_line_salesrep_id  =
                         :cust_trx_line_salesrep_id ';
        END IF;

        l_prevent_dup_rec_pred := l_prevent_dup_rec_pred || '
                and    '''|| p_account_class ||'''    = lgd.account_class
                and    decode(ct.invoicing_rule_id,
                              NULL, ''N'',
                              ''Y'' )             = lgd.account_set_flag
               )';

    END IF;

    ------------------------------------------------------------------------
    -- Create Tax predicate
    ------------------------------------------------------------------------
    debug('  Create Tax predicate', MSG_LEVEL_DEVELOP);

    IF( p_account_class in (TAX, FREIGHT) ) THEN

        /* 4558268 - Removed joins for tax tables */

        l_tax_pred := CRLF ||
'AND        ctl.link_to_cust_trx_line_id   =
                                            ctl_line.customer_trx_line_id(+)';

    END IF;

    ------------------------------------------------------------------------
    -- Create Suspense predicate
    ------------------------------------------------------------------------
    debug('  Create suspense predicate', MSG_LEVEL_DEVELOP);

    IF( p_account_class = SUSPENSE ) THEN

        l_suspense_pred := CRLF ||
'AND        (ctl.extended_amount - ctl.revenue_amount) <> 0';


    END IF;

    ------------------------------------------------------------------------
    -- Create predicate that is based on salesrep flag
    ------------------------------------------------------------------------
    debug('  Create predicate that is based on salesrep flag',
		MSG_LEVEL_DEVELOP);

    IF( l_based_on_salesrep_flag ) THEN

        -- bug2963903 : Added condition for revenue_percent_split
        l_based_on_salesrep_pred := CRLF ||
'AND        ctl.customer_trx_id           = ctls.customer_trx_id(+)
AND        nvl(ctl.link_to_cust_trx_line_id,
               ctl.customer_trx_line_id)  = ctls.customer_trx_line_id(+)
AND        (ctls.revenue_percent_split is not null
                or ctls.customer_trx_line_id is null)' ;

    END IF;

    IF( p_account_class = REC
        AND p_gl_date IS NULL
        AND p_request_id IS NOT NULL)
    THEN
        IF p_request_id > 0
        THEN

     /* 5169215 - a cartesian join between ra_interface_lines and
          ra_customer_trx was resulting in incorrect GL_DATE on
          REC distributions.  This relates to bug 4483951, but the fix
          for that does not entirely resolve the problem */
        l_interface_table_pred := CRLF ||
'AND        ril.rowid =  (SELECT /*+ no_unnest */ min(ril2.rowid)
                         FROM   ra_interface_lines_gt ril2
                         WHERE  ril2.customer_trx_id = ct.customer_trx_id
                         AND    ril2.link_to_line_id is null)
AND        ril.customer_trx_id = ct.customer_trx_id ';

        ELSE
        /* 5921925 - invoice api gl_date issues */
        l_interface_table_pred := CRLF ||
'AND        ril.customer_trx_id =  ct.customer_trx_id';
        END IF;
    END IF;

    ------------------------------------------------------------------------
    -- request_id
    ------------------------------------------------------------------------
    IF( p_request_id IS NOT NULL ) THEN

    /* Bug 2116064 - Added 'is not null' condition */
        l_request_id_pred := CRLF ||
'AND        ct.request_id                = :request_id';

        l_request_id_pred := l_request_id_pred || CRLF ||
'AND        ctl.request_id (+) = :request_id';  -- 7039838

        l_request_id_pred := l_request_id_pred || CRLF ||
'AND        ct.request_id is not null';

    END IF;

    ------------------------------------------------------------------------
    -- customer_trx_id
    ------------------------------------------------------------------------
    IF( p_customer_trx_id IS NOT NULL ) THEN

        l_trx_id_pred := CRLF ||
'AND        ct.customer_trx_id             = :customer_trx_id';

    END IF;

    ------------------------------------------------------------------------
    -- customer_trx_line_id
    ------------------------------------------------------------------------
    IF( p_customer_trx_line_id IS NOT NULL ) THEN

        l_line_id_pred := CRLF ||
'AND        (ctl.customer_trx_line_id       =  :customer_trx_line_id
            OR
            ctl.link_to_cust_trx_line_id   = :customer_trx_line_id';

/* Bug 1793936 - Creating extra UNEARN/UNBILL rows under certain circumstances

--        IF( p_customer_trx_id IS NOT NULL
--            OR p_request_id IS NOT NULL ) THEN

--            l_line_id_pred := l_line_id_pred || '
-- OR            ctl.link_to_cust_trx_line_id   is null';
--
--        END IF;
*/
        l_line_id_pred := l_line_id_pred || ')';

    END IF;

    IF( p_cust_trx_line_salesrep_id IS NOT NULL
        AND l_based_on_salesrep_flag ) THEN

        l_line_salesrep_id_pred := CRLF ||
'AND        ctls.cust_trx_line_salesrep_id  = :cust_trx_line_salesrep_id';

    END IF;


    ------------------------------------------------------------------------
    -- IF   Use Invoice Accounting is Yes,
    -- AND  the account class is Receivable,
    -- AND  no CCID was passed in
    -- THEN join to the invoice's receivable record for credit memos
    --      to get the invoice's receivable CCID
    ------------------------------------------------------------------------
    IF( p_profile_info.use_inv_acct_for_cm_flag = 'Y'
        AND p_account_class = REC
        AND p_code_combination_id IS NULL ) THEN

        l_inv_rec_pred := CRLF ||
'        /* Join to the invoice receivable record to get the CCID */
AND        ct.previous_customer_trx_id    = lgd_inv_rec.customer_trx_id(+)
AND        lgd_inv_rec.account_class(+)   = ''REC''
AND        lgd_inv_rec.latest_rec_flag(+) = ''Y''';

    END IF;

    ------------------------------------------------------------------------
    -- Put it all together
    ------------------------------------------------------------------------
    debug('  Put it all together ', MSG_LEVEL_DEVELOP);

    /* 7039838 - changed hints for FT tuning */
    IF p_request_id IS NOT NULL
    THEN
       l_select_stmt :=
           'SELECT /*+ leading(ct) index(ct,RA_CUSTOMER_TRX_N15) index(ctl,RA_CUSTOMER_TRX_LINES_N4) use_hash(ctl) */ ' || CRLF;
    ELSE
       l_select_stmt := 'SELECT' || CRLF;
    END IF;

    l_select_stmt :=  l_select_stmt ||
'ct.customer_trx_id,                        /* customer_trx_id */
ctl.customer_trx_line_id,             /* customer_trx_line_id */'
|| l_salesrep_attributes1
|| CRLF ||
'''' || p_account_class || ''',                   /* account class */
decode('|| l_rule_fragment ||',
       NULL, ''N'',
       ''Y'' ),                       /* account_set_flag */
ct.cust_trx_type_id,                      /* cust_trx_type_id */
decode(ct.invoicing_rule_id,
       -3, ''Y'',
       ''N''),                       /* allow_not_open_flag */
to_char(''''),                         /* concatenated segments */'
|| CRLF
|| l_ccid_fragment ||',        /* code_combination_id */'
|| l_gl_date_attribute
|| l_orig_gl_date_attribute
|| l_salesrep_attributes2
|| l_tax_attribute
|| 'ct.bill_to_site_use_id, /* Billing site id */ '
|| l_tax_table_fragment ||'.warehouse_id /* Warehouse id */ '
|| ', ctl.link_to_cust_trx_line_id /* 1651593 - tax errors */'
|| CRLF
||'FROM'
|| l_interface_lines_table
|| l_inv_gl_dist_table
|| l_salesreps_table
|| l_tax_table
|| CRLF ||
'fnd_currencies fc_foreign,'
|| l_gl_dist_table
|| CRLF ||
'ra_cust_trx_line_gl_dist rgd,
ra_customer_trx_lines ctl,
ra_customer_trx ct
WHERE      ct.customer_trx_id             = ctl.customer_trx_id(+)
AND        ct.invoice_currency_code       = fc_foreign.currency_code'
|| l_cm_module_pred
|| l_prevent_dup_rec_pred
|| CRLF ||
'AND        ct.customer_trx_id             = rgd.customer_trx_id(+)
AND        ''REC''                          = rgd.account_class(+)
AND        ''N''                            = rgd.account_set_flag(+)
AND        ctl.line_type '|| l_line_type_fragment
|| l_tax_pred
|| CRLF ||
'and        nvl(ct.invoicing_rule_id,
              -10)                      '|| l_rule_id_fragment
|| l_suspense_pred
|| l_based_on_salesrep_pred
|| l_interface_table_pred
|| l_request_id_pred
|| l_trx_id_pred
|| l_line_id_pred
|| l_line_salesrep_id_pred
|| l_inv_rec_pred ;

    debug( l_select_stmt, MSG_LEVEL_DEBUG );
    debug( '  len(l_select_stmt)=' ||
                        to_char(LENGTHB(l_select_stmt)), MSG_LEVEL_DEBUG );


    print_fcn_label( 'arp_auto_accounting.build_select_sql()-' );
    RETURN l_select_stmt;



EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.build_select_sql()',
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

    print_fcn_label2( 'arp_auto_accounting.add_segments_to_cache()+' );

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

   print_fcn_label2( 'arp_auto_accounting.add_segments_to_cache()-' );

   EXCEPTION
     WHEN OTHERS THEN
         debug( 'EXCEPTION: arp_auto_accounting.add_segments_to_cache()',
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

     print_fcn_label2( 'arp_auto_accounting.get_segment_from_glcc()+' );

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

      print_fcn_label2( 'arp_auto_accounting.get_segment_from_glcc()-' );
      RETURN(l_desired_segment);

   WHEN OTHERS THEN RAISE;

 END;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
	debug('arp_auto_accounting.get_segment_from_glcc(): no data found',
	      MSG_LEVEL_DEBUG);
        RETURN NULL;
    WHEN OTHERS THEN
/*        debug('EXCEPTION: arp_auto_accounting.get_segment_from_glcc('
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
/*   21-APR-03   MRAYMOND   2142306   Rewrote this routine to use hash indexes
                                      in place of linear scans.  If a collision
                                      occurs, we will log the second (and
                                      successive colliding accounts in a linear
                                      table.

                                      Also note that this version stores all
                                      ccids (REV, REC, etc) in a single table
                                      rather than having separate tables for
                                      each.
*/

FUNCTION Get_Ccid_From_Cache( p_system_info 	 IN
                                 arp_trx_global.system_info_rec_type,
                              p_concat_segments  IN  varchar2,
                              p_segment_table    IN  fnd_flex_ext.SegmentArray,
                              p_segment_cnt      IN  BINARY_INTEGER,
                              p_account_class    IN
                                 ra_cust_trx_line_gl_dist.account_class%type,
                              p_result           OUT NOCOPY BOOLEAN
                            ) RETURN BINARY_INTEGER IS

  hash_value        NUMBER;
  tab_indx          BINARY_INTEGER := 0;
  found             BOOLEAN := FALSE;
  valid             BOOLEAN := FALSE;
  l_ccid            BINARY_INTEGER;

BEGIN

   print_fcn_label2( 'arp_auto_accounting.get_ccid_from_cache()+' );

  /*----------------------------------------------------------------+
   |  Rewritten for bug 2142306 (23-Jan-02) - performance issues    |
   |                                                                |
   |  Search the cache for the concantenated segments.              |
   |  Return the ccid if it is in the cache.                        |
   |                                                                |
   |  If not found in cache, search the linear table (where ccid's  |
   |  will go if collision on the hash table occurs).               |
   |                                                                |
   |  A NO_DATA_FOUND exception will be generated if the segments   |
   |  are not found in either table. This will result in a call to  |
   |  the flexfield api to get the ccid and puts it in the cache    |
   |  table if no collision  occurs (and the cache is not already   |
   |  full) or the linear table if the hash value already exists in |
   |  the hash table (and its not full).  The number of rows in the |
   |  linear table should be very small!                            |
   +----------------------------------------------------------------*/

   hash_value := dbms_utility.get_hash_value(p_concat_segments,
                     HASH_START, HASH_MAX);


   /* The following flow looks like this:

   IF hash exists
     IF concatenated segs at hash are same
       IF date is valid
         Use ccid from hash table
       ENDIF
     ELSE concatenated segs not same (collision)
       LOOP through linear table
         IF concatenated segs at linear are same
           IF date is valid
              Use ccid from linear table
           ENDIF
         ELSE
           make room in linear table for new ccid
         ENDIF
       END LOOP
     ENDIF
   ENDIF

   IF the hash for the segments is not found in the hash table,
   then it is a new ccid and it is added to the table.
   */


   IF autoacc_hash_seg_cache.exists(hash_value) THEN

       IF autoacc_hash_seg_cache(hash_value) = p_concat_segments THEN

            found := TRUE;

	    IF (validation_date BETWEEN autoacc_hash_st_date_cache(hash_value)
                                  and autoacc_hash_end_date_cache(hash_value))
            THEN
	        l_ccid := autoacc_hash_id_cache(hash_value);
	        valid := TRUE;
            END IF;

       ELSE     --- collision has occurred
            tab_indx := 1;  -- start at top of linear table and search for match

            WHILE ((tab_indx <= tab_size) AND (not found)) LOOP

	      IF autoacc_lin_seg_cache(tab_indx) = p_concat_segments THEN

                 found := TRUE;

	         IF (validation_date BETWEEN autoacc_lin_st_date_cache(tab_indx)
                                       and autoacc_lin_end_date_cache(tab_indx))
                 THEN
	            l_ccid := autoacc_lin_id_cache(tab_indx);
                    valid := TRUE;
	         END IF;

              ELSE

                 tab_indx := tab_indx + 1;

	      END IF;

            END LOOP;

       END IF;

   END IF;

      /*-------------------------------------------------+
       |  Return the ccid if it was found in the cache.  |
       +-------------------------------------------------*/
       IF FOUND THEN
          debug('found ccid ' || l_ccid  || ' for concatenated segs: ' ||
                     p_concat_segments || ' in the cache', MSG_LEVEL_DEBUG);
          IF VALID THEN
             p_result := TRUE;
             print_fcn_label2( 'arp_auto_accounting.get_ccid_from_cache()-' );
             RETURN( l_ccid );
          ELSE
             debug('  ccid ' || l_ccid || ' not valid for date ' ||
                                           validation_date );
             p_result := FALSE;
             print_fcn_label2('arp_auto_accounting.get_ccid_from_cache()-');
             RETURN(NULL);
          END IF;
       ELSE
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
              |  Add the ccid to the cache                        |
              |  Store in hash table if hash_value does not exist |
              |  Otherwise store in linear table.                 |
              +---------------------------------------------------*/

           IF autoacc_hash_seg_cache.exists(hash_value) then

              IF tab_size < MAX_LINEAR_CACHE_SIZE
              THEN
      	         tab_size := tab_size + 1;
	         autoacc_lin_id_cache(tab_size)       := l_ccid;
	         autoacc_lin_seg_cache(tab_size)      := p_concat_segments;
                 autoacc_lin_st_date_cache(tab_size)  :=
                     nvl(fnd_flex_keyval.start_date, g_min_date);
                 autoacc_lin_end_date_cache(tab_size) :=
                     nvl(fnd_flex_keyval.end_date, g_max_date);
              END IF;
       	   ELSE
             IF h_tab_size < MAX_HASH_CACHE_SIZE
             THEN
                h_tab_size := h_tab_size + 1;
	        autoacc_hash_id_cache(hash_value)       := l_ccid;
	        autoacc_hash_seg_cache(hash_value)      := p_concat_segments;
	        autoacc_hash_st_date_cache(hash_value)  :=
                    nvl(fnd_flex_keyval.start_date, g_min_date);
                autoacc_hash_end_date_cache(hash_value) :=
                    nvl(fnd_flex_keyval.end_date, g_max_date);
             END IF;
	   END IF;
              p_result := TRUE;
              print_fcn_label2( 'arp_auto_accounting.get_ccid_from_cache()-' );
              RETURN(l_ccid);
         ELSE
              p_result := FALSE;
              print_fcn_label2( 'arp_auto_accounting.get_ccid_from_cache()-' );
              RETURN(NULL);
         END IF;
   END IF;
   EXCEPTION
   WHEN OTHERS THEN
         debug( 'EXCEPTION: arp_auto_accounting.get_ccid_from_cache_cache()',
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
--   14-FEB-97  C. Tomberg  Added p_account_class and p_concat_segments params.
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

    print_fcn_label2( 'arp_auto_accounting.search_glcc_for_ccid()+' );

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

        print_fcn_label2( 'arp_auto_accounting.search_glcc_for_ccid()-' );
        RETURN -1;

    END IF;

    --
    -- part 2: check special validation
    --         detail_posting_flag
    --         summary_flag
    --
    BEGIN
/* Bug-2178723 : Caching the values of detail_posting_allowed_flag and summary_flag
                 in pl/sql table to avoid the high execution count  */
        IF pg_ar_code_comb_rec.EXISTS(l_ccid) THEN
              l_detail_posting_flag := pg_ar_code_comb_rec(l_ccid).detail_posting_flag;
              l_summary_flag        :=  pg_ar_code_comb_rec(l_ccid).summary_flag;

        ELSE

            SELECT detail_posting_allowed_flag,
                   summary_flag
            INTO   l_detail_posting_flag,
                   l_summary_flag
            FROM   gl_code_combinations
            WHERE  code_combination_id = l_ccid;

            pg_ar_code_comb_rec(l_ccid).detail_posting_flag := l_detail_posting_flag ;
            pg_ar_code_comb_rec(l_ccid).summary_flag := l_summary_flag ;

        END IF;

        IF( l_detail_posting_flag = NO ) THEN

                g_error_buffer := MSG_FLEX_POSTING_NOT_ALLOWED;
                debug( MSG_FLEX_POSTING_NOT_ALLOWED, MSG_LEVEL_BASIC);
                print_fcn_label2( 'arp_auto_accounting.search_glcc_for_ccid()-' );
                RETURN -1;

         ELSIF( l_summary_flag = YES ) THEN

                g_error_buffer := MSG_FLEX_NO_PARENT_ALLOWED;
                debug( MSG_FLEX_NO_PARENT_ALLOWED, MSG_LEVEL_BASIC);
                print_fcn_label2( 'arp_auto_accounting.search_glcc_for_ccid()-' );
                RETURN -1;

          END IF;

            print_fcn_label2( 'arp_auto_accounting.search_glcc_for_ccid()-' );
            RETURN l_ccid;

    EXCEPTION
	WHEN NO_DATA_FOUND  THEN
            RETURN -1;
        WHEN OTHERS THEN
            debug( 'Error in binding ccid_reader', MSG_LEVEL_BASIC );
            debug(SQLERRM, MSG_LEVEL_BASIC);
            RAISE;
    END;

    print_fcn_label2( 'arp_auto_accounting.search_glcc_for_ccid()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.search_glcc_for_ccid('
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
--    14-FEB-97  C. Tomberg  Created
--

FUNCTION Find_Cursor_In_Cache ( p_key  IN VARCHAR2 ) RETURN BINARY_INTEGER IS
BEGIN

           print_fcn_label2( 'arp_auto_accounting.Find_Cursor_In_Cache()+' );

           FOR l_index IN 1..cursor_attr_cache.count LOOP

               IF ( cursor_attr_cache(l_index) = p_key )
               THEN
                      print_fcn_label2(
                               'arp_auto_accounting.Find_Cursor_In_Cache()-' );
                      RETURN( l_index );
               END IF;

           END LOOP;


            print_fcn_label2( 'arp_auto_accounting.Find_Cursor_In_Cache()-' );

           RETURN(NULL);

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.Find_Cursor_In_Cache()',
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
--              p_customer_trx_line_id
--              p_cust_trx_line_salesrep_id
--              p_request_id
--              p_gl_date
--              p_original_gl_date
--              p_total_trx_amount
--              p_code_combination_id
--              p_force_account_set_no
--              p_cust_trx_type_id
--              p_primary_salesrep_id
--              p_inventory_item_id
--              p_memo_line_id
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
--    14-FEB-97  C. Tomberg  Created
--

FUNCTION Get_Select_Cursor(
                           p_system_info 		IN
                             arp_trx_global.system_info_rec_type,
                           p_profile_info 		IN
                             arp_trx_global.profile_rec_type,
                           p_account_class 		IN VARCHAR2,
                           p_customer_trx_id 		IN BINARY_INTEGER,
                           p_customer_trx_line_id 	IN number,
                           p_cust_trx_line_salesrep_id 	IN number,
                           p_request_id 		IN BINARY_INTEGER,
                           p_gl_date 			IN DATE,
                           p_original_gl_date 		IN DATE,
                           p_total_trx_amount 		IN NUMBER,
                           p_code_combination_id 	IN BINARY_INTEGER,
                           p_force_account_set_no 	IN VARCHAR2,
                           p_cust_trx_type_id 		IN BINARY_INTEGER,
                           p_primary_salesrep_id 	IN BINARY_INTEGER,
                           p_inventory_item_id 		IN BINARY_INTEGER,
                           p_memo_line_id 		IN BINARY_INTEGER,
			   p_use_unearn_srep_dependency IN BOOLEAN DEFAULT FALSE,
                           p_keep_cursor_open_flag     OUT NOCOPY BOOLEAN )
          RETURN BINARY_INTEGER IS

    l_select_rec    select_rec_type;
    l_select_tab    select_rec_tab;
    l_key           VARCHAR2(100);
    l_select_c      BINARY_INTEGER;
    l_cursor_index  BINARY_INTEGER;
    l_cursor        BINARY_INTEGER;
    l_ignore   	    INTEGER;

BEGIN

       print_fcn_label2( 'arp_auto_accounting.Get_Select_Cursor()+' );

       p_keep_cursor_open_flag := TRUE;

      /*----------------------------------+
       |  Construct the cursor cache key  |
       +----------------------------------*/

       l_key := p_account_class || '-';

       IF (p_code_combination_id  IS NOT NULL)
       THEN l_key := l_key || 'Y-';
       ELSE l_key := l_key || 'N-';
       END IF;

       IF (p_gl_date  IS NOT NULL)
       THEN l_key := l_key || 'Y-';
       ELSE l_key := l_key || 'N-';
       END IF;

       IF (p_request_id  IS NOT NULL)
       THEN l_key := l_key || 'Y-';
       ELSE l_key := l_key || 'N-';
       END IF;

       IF (p_cust_trx_line_salesrep_id  IS NOT NULL)
       THEN l_key := l_key || 'Y-';
       ELSE l_key := l_key || 'N-';
       END IF;

       IF (p_customer_trx_id  IS NOT NULL)
       THEN l_key := l_key || 'Y-';
       ELSE l_key := l_key || 'N-';
       END IF;

       IF (p_customer_trx_line_id  IS NOT NULL)
       THEN l_key := l_key || 'Y-';
       ELSE l_key := l_key || 'N-';
       END IF;

       /*added for cursor index 9112739*/
       IF (p_use_unearn_srep_dependency  )
       THEN l_key := l_key || 'Y-';
       ELSE l_key := l_key || 'N-';
       END IF;


      /*----------------------------------------------------+
       |  Attempt to get the cursor from the cursor cache.  |
       +----------------------------------------------------*/

       l_cursor_index := Find_Cursor_In_Cache(l_key);


      /*---------------------------------------------------+
       |  If the cursor was found, return it immediately.  |
       +---------------------------------------------------*/

       IF  (l_cursor_index IS NOT NULL)
       THEN

             print_fcn_label2( 'arp_auto_accounting.Get_Select_Cursor()-' );

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

/*Bug 9112739*/
                l_select_stmt := build_select_sql( p_system_info,
                                               p_profile_info,
                                               p_account_class,
                                               p_customer_trx_id,
                                               p_customer_trx_line_id,
                                               p_cust_trx_line_salesrep_id,
                                               p_request_id,
                                               p_gl_date,
                                               p_original_gl_date,
                                               p_total_trx_amount,
                                               p_code_combination_id,
                                               p_force_account_set_no,
                                               p_cust_trx_type_id,
                                               p_primary_salesrep_id,
                                               p_inventory_item_id,
                                               p_memo_line_id,
					       p_use_unearn_srep_dependency);

                --
                -- add Order By clause
                --

                l_select_stmt := l_select_stmt || CRLF ||
'ORDER BY  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12';

                ------------------------------------------------------------
                -- Parse
                ------------------------------------------------------------
		debug( '  Parsing select stmt', MSG_LEVEL_DEBUG );

                dbms_sql.parse( l_select_c, l_select_stmt, dbms_sql.v7);


                ------------------------------------------------------------
                -- Define Column Arrays
                ------------------------------------------------------------
                define_arrays( l_select_c, l_select_tab );


       EXCEPTION
                WHEN OTHERS THEN
                  debug( 'Error constructing/parsing select cursor',
                         MSG_LEVEL_BASIC );
                  debug(SQLERRM, MSG_LEVEL_BASIC);
                  RAISE;

       END;

       print_fcn_label2( 'arp_auto_accounting.Get_Select_Cursor()-' );

       RETURN( l_select_c );


EXCEPTION
    WHEN OTHERS THEN

        debug('EXCEPTION: arp_auto_accounting.Get_Select_Cursor()',
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
--    14-FEB-97  C. Tomberg  Created
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
--                 p_system_info
--                 p_profile_info
--                 p_account_class
--                 p_customer_trx_id
--                 p_customer_trx_line_id
--                 p_cust_trx_line_salesrep_id
--                 p_request_id
--                 p_gl_date
--                 p_original_gl_date
--                 p_total_trx_amount
--                 p_code_combination_id
--                 p_force_account_set_no
--                 p_cust_trx_type_id
--                 p_primary_salesrep_id
--                 p_inventory_item_id
--                 p_memo_line_id
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
--    14-FEB-97  C. Tomberg  Created
--

PROCEDURE Bind_All_Variables(
                            p_cursor                    IN OUT NOCOPY BINARY_INTEGER,
                            p_system_info 		IN
                             arp_trx_global.system_info_rec_type,
                            p_profile_info 		IN
                             arp_trx_global.profile_rec_type,
                            p_account_class 		IN VARCHAR2,
                            p_customer_trx_id 		IN BINARY_INTEGER,
                            p_customer_trx_line_id 	IN NUMBER,
                            p_cust_trx_line_salesrep_id IN NUMBER,
                            p_request_id 		IN BINARY_INTEGER,
                            p_gl_date 			IN DATE,
                            p_original_gl_date 		IN DATE,
                            p_total_trx_amount 		IN NUMBER,
                            p_code_combination_id 	IN BINARY_INTEGER,
                            p_force_account_set_no 	IN VARCHAR2,
                            p_cust_trx_type_id 		IN BINARY_INTEGER,
                            p_primary_salesrep_id 	IN BINARY_INTEGER,
                            p_inventory_item_id 	IN BINARY_INTEGER,
                            p_memo_line_id 		IN BINARY_INTEGER,
                            p_keep_cursor_open_flag IN OUT NOCOPY BOOLEAN
                            ) IS

BEGIN

        print_fcn_label2( 'arp_auto_accounting.Bind_All_Variables()+' );

        BEGIN
           Bind_Variable(
                          p_cursor,
                          ':force_account_set_no',
                          p_force_account_set_no
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
/*Bug9112739*/
              p_cursor := Get_Select_Cursor(
                                             system_info,
                                             profile_info,
                                             p_account_class,
                                             p_customer_trx_id,
                                             p_customer_trx_line_id,
                                             p_cust_trx_line_salesrep_id,
                                             p_request_id,
                                             p_gl_date,
                                             p_original_gl_date,
                                             p_total_trx_amount,
                                             p_code_combination_id,
                                             p_force_account_set_no,
                                             p_cust_trx_type_id,
                                             p_primary_salesrep_id,
                                             p_inventory_item_id,
                                             p_memo_line_id,
					     FALSE,
                                             p_keep_cursor_open_flag);

              Bind_Variable(
                             p_cursor,
                             ':force_account_set_no',
                             p_force_account_set_no
                           );

           WHEN OTHERS THEN RAISE;
        END;


        Bind_Variable(
                       p_cursor,
                       ':total_trx_amount',
                       p_total_trx_amount
                     );


        Bind_Variable(
                       p_cursor,
                       ':original_gl_date',
                       p_original_gl_date
                     );

        Bind_Variable(
                       p_cursor,
                       ':gl_date',
                       p_gl_date
                     );


        Bind_Variable(
                       p_cursor,
                       ':code_combination_id',
                       p_code_combination_id
                     );

        Bind_Variable(
                       p_cursor,
                       ':request_id1',
                       p_request_id
                     );


	Bind_Variable(
                       p_cursor,
                       ':cust_trx_line_salesrep_id',
                       p_cust_trx_line_salesrep_id
                     );

        Bind_Variable(
                       p_cursor,
                       ':request_id',
                       p_request_id
                     );


        Bind_Variable(
                       p_cursor,
                       ':customer_trx_id',
                       p_customer_trx_id
                     );


        Bind_Variable(
                       p_cursor,
                       ':customer_trx_line_id',
                       p_customer_trx_line_id
                     );

        Bind_Variable(
                       p_cursor,
                       ':base_currency',
                       p_system_info.base_currency
                     );


        print_fcn_label2( 'arp_auto_accounting.Bind_All_Variables()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.Bind_All_Variables()',
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
--        line_id
--        trx_type_id
--        salesrep_id
--        inv_item_id
--        memo_line_id
--
--      IN/OUT:
--        ccid_record
--        inv_item_type
--
--      OUT:
--
-- NOTES:
--
-- HISTORY:
--
PROCEDURE get_default_ccids( p_profile_info 	IN
                               arp_trx_global.profile_rec_type,
                             p_account_class 	IN VARCHAR2,
                             p_line_id 		IN NUMBER,
                             p_trx_type_id 	IN BINARY_INTEGER,
                             p_salesrep_id 	IN BINARY_INTEGER,
                             p_inv_item_id 	IN BINARY_INTEGER,
                             p_memo_line_id 	IN BINARY_INTEGER,
                             p_site_use_id      IN NUMBER,
                             p_warehouse_id     IN BINARY_INTEGER,
                             p_ccid_record 	IN OUT NOCOPY ccid_rec_type,
                             p_inv_item_type 	IN OUT NOCOPY
                               mtl_system_items.item_type%TYPE )  IS


BEGIN
    print_fcn_label2( 'arp_auto_accounting.get_default_ccids()+' );

    --
    -- trx type
    --
    IF( p_trx_type_id is NOT NULL ) THEN
        get_trx_type_ccids( p_trx_type_id,
                             p_ccid_record.trx_type_ccid_rev,
                             p_ccid_record.trx_type_ccid_rec,
                             p_ccid_record.trx_type_ccid_frt,
                             p_ccid_record.trx_type_ccid_tax,
                             p_ccid_record.trx_type_ccid_unbill,
                             p_ccid_record.trx_type_ccid_unearn,
                             p_ccid_record.trx_type_ccid_suspense );

    END IF;

    --
    -- billing site ccids
    --
    IF( p_site_use_id is NOT NULL ) THEN
        get_site_use_ccids( p_site_use_id,
                             p_ccid_record.site_use_ccid_rev,
                             p_ccid_record.site_use_ccid_rec,
                             p_ccid_record.site_use_ccid_frt,
                             p_ccid_record.site_use_ccid_tax,
                             p_ccid_record.site_use_ccid_unbill,
                             p_ccid_record.site_use_ccid_unearn,
                             p_ccid_record.site_use_ccid_suspense );

    END IF;

    --
    -- salesrep
    --
    IF( p_salesrep_id is NOT NULL ) THEN
        get_salesrep_ccids( p_salesrep_id,
                             p_ccid_record.salesrep_ccid_rev,
                             p_ccid_record.salesrep_ccid_rec,
                             p_ccid_record.salesrep_ccid_frt );
    END IF;

    --
    -- lineitem
    --
    IF( p_inv_item_id is NOT NULL ) THEN

        get_inv_item_ccids( p_profile_info,
                            p_inv_item_id,
                            p_warehouse_id,
                            p_ccid_record.lineitem_ccid_rev,
                            p_inv_item_type );

    ELSIF( p_memo_line_id is NOT NULL ) THEN

        get_memo_line_ccids( p_memo_line_id,
                             p_ccid_record.lineitem_ccid_rev );
    END IF;

    --
    -- agreement/category
    -- Only default  if type REV/CHARGES and REV autoacc def
    -- is based on table 'AGREEMENT/CATEGORY'
    --
    IF( p_account_class in (REV, CHARGES) AND
        query_autoacc_def( REV, 'AGREEMENT/CATEGORY' ) ) THEN

        get_agreecat_ccids( p_profile_info,
                            p_line_id,
			    p_warehouse_id,        --Bug#1639334
                            p_ccid_record.agreecat_ccid_rev );
    END IF;

    print_fcn_label2( 'arp_auto_accounting.get_default_ccids()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.get_default_ccids('
              || p_account_class || ', '
              || to_char(p_line_id) || ', '
              || to_char(p_trx_type_id) || ', '
              || to_char(p_salesrep_id) || ', '
              || to_char(p_inv_item_id) || ', '
              || to_char(p_memo_line_id)|| ', '
              || to_char(p_site_use_id) || ', '
              || to_char(p_warehouse_id)||')', MSG_LEVEL_BASIC);
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
--        inv_item_type
--
--      IN/OUT:
--        ccid
--        assembled_segments
--        int_ccid (interim tax account ccid)
--        int_concat_segments (interim tax concatenated segments)
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
                  p_inv_item_type IN mtl_system_items.item_type%TYPE,
                  p_ccid IN OUT NOCOPY BINARY_INTEGER,
                  p_concat_segments IN OUT NOCOPY VARCHAR2,
                  p_int_ccid IN OUT NOCOPY BINARY_INTEGER,
                  p_int_concat_segments IN OUT NOCOPY VARCHAR2 ) IS

    l_table_offset        BINARY_INTEGER;
    l_cnt                 BINARY_INTEGER;
    l_concat_segments     VARCHAR2(800);
    l_int_concat_segments VARCHAR2(800);
    l_seg                 ra_account_default_segments.segment%type;
    l_const               ra_account_default_segments.constant%type;
    l_tbl                 ra_account_default_segments.table_name%type;
    l_ccid                BINARY_INTEGER;
    l_seg_num             BINARY_INTEGER;
    l_seg_value           gl_code_combinations.segment1%type;
    l_int_seg_value       gl_code_combinations.segment1%type;
    l_delim               VARCHAR2(1);

    -- to store segment values for binding
    --
    l_seg_table fnd_flex_ext.SegmentArray;
    l_int_seg_table fnd_flex_ext.SegmentArray;

BEGIN

    print_fcn_label2( 'arp_auto_accounting.assemble_code_combination()+' );

    -- get offset, count for account class (to access plsql tables)
    --
    IF( p_account_class in (REV, CHARGES) ) then
        --
        -- Charges uses autoacc definition for Revenue
        --
        IF( p_inv_item_type = 'FRT' ) then
            --
            -- use autoacc definition for FREIGHT
            -- if inv item is of type 'FRT'
            --
            l_table_offset := frt_offset;
            l_cnt := frt_count;
        ELSE
            --
            -- use autoacc definition for REVENUE
            --
            l_table_offset := rev_offset;
            l_cnt := rev_count;
        END IF;
    ELSIF( p_account_class = REC ) then
        l_table_offset := rec_offset;
        l_cnt := rec_count;
    ELSIF( p_account_class = FREIGHT ) then
        l_table_offset := frt_offset;
        l_cnt := frt_count;
    ELSIF( p_account_class = TAX ) then
        l_table_offset := tax_offset;
        l_cnt := tax_count;
    ELSIF( p_account_class = UNBILL ) then
        l_table_offset := unbill_offset;
        l_cnt := unbill_count;
    ELSIF( p_account_class = UNEARN ) then
        l_table_offset := unearn_offset;
        l_cnt := unearn_count;
    ELSIF( p_account_class = SUSPENSE ) then
        l_table_offset := suspense_offset;
        l_cnt := suspense_count;
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

            --for deferred tax
            l_int_concat_segments := l_int_concat_segments || l_delim
                               || l_const;
            l_int_seg_table(i+1) := l_const;

        ELSIF( l_tbl is NOT NULL ) THEN
            --
            -- table-based
            --
            IF( l_tbl = 'RA_CUST_TRX_TYPES' ) THEN
                --
                -- For all account classes except REC
                --
                IF p_account_class in (REV, CHARGES) THEN

                   IF( p_inv_item_type = 'FRT' ) THEN
                       --
                       -- use autoacc definition for FREIGHT
                       -- if inv item is of type 'FRT'
                       --
                        l_ccid := p_ccid_record.trx_type_ccid_frt;
                   ELSE
                        l_ccid := p_ccid_record.trx_type_ccid_rev;
                   END IF;
                ELSIF p_account_class = REC THEN
                      l_ccid := p_ccid_record.trx_type_ccid_rec;
                ELSIF p_account_class = FREIGHT THEN
                      l_ccid := p_ccid_record.trx_type_ccid_frt;
                ELSIF p_account_class = TAX THEN
                      l_ccid := p_ccid_record.trx_type_ccid_tax;
                ELSIF p_account_class = UNBILL THEN
                      l_ccid := p_ccid_record.trx_type_ccid_unbill;
                ELSIF p_account_class = UNEARN THEN
                      l_ccid := p_ccid_record.trx_type_ccid_unearn;
                ELSIF p_account_class = SUSPENSE THEN
                      l_ccid := p_ccid_record.trx_type_ccid_suspense;
                END IF;

            ELSIF( l_tbl = 'RA_SITE_USES' ) THEN
                --
                -- For all account classes except REC
                --
                IF p_account_class in (REV, CHARGES) THEN

                   IF( p_inv_item_type = 'FRT' ) THEN
                       --
                       -- use autoacc definition for FREIGHT
                       -- if inv item is of type 'FRT'
                       --
                        l_ccid := p_ccid_record.site_use_ccid_frt;
                   ELSE
                        l_ccid := p_ccid_record.site_use_ccid_rev;
                   END IF;
                ELSIF p_account_class = REC THEN
                      l_ccid := p_ccid_record.site_use_ccid_rec;
                ELSIF p_account_class = FREIGHT THEN
                      l_ccid := p_ccid_record.site_use_ccid_frt;
                ELSIF p_account_class = TAX THEN
                      l_ccid := p_ccid_record.site_use_ccid_tax;
                ELSIF p_account_class = UNBILL THEN
                      l_ccid := p_ccid_record.site_use_ccid_unbill;
                ELSIF p_account_class = UNEARN THEN
                      l_ccid := p_ccid_record.site_use_ccid_unearn;
                ELSIF p_account_class = SUSPENSE THEN
                      l_ccid := p_ccid_record.site_use_ccid_suspense;
                END IF;

            ELSIF( l_tbl = 'RA_SALESREPS' ) THEN
                --
                -- For all account classes
                --
                IF p_account_class in (REV, CHARGES) THEN

                   IF( p_inv_item_type = 'FRT' ) THEN
                       --
                       -- use autoacc definition for FREIGHT
                       -- if inv item is of type 'FRT'
                       --
                        l_ccid := p_ccid_record.salesrep_ccid_frt;
                   ELSE
                        l_ccid := p_ccid_record.salesrep_ccid_rev;
                   END IF;

                /* Bug 2396754 - swapped salesrep_ccid_rec
                   for salesrep_ccid_rev for UNBILL - it was
                   an apparent typo */

                ELSIF p_account_class = REC THEN
                    l_ccid := p_ccid_record.salesrep_ccid_rec;
                ELSIF p_account_class = FREIGHT THEN
                    l_ccid := p_ccid_record.salesrep_ccid_frt;
                ELSIF p_account_class = TAX THEN
                    l_ccid := p_ccid_record.salesrep_ccid_rev;
                ELSIF p_account_class = UNBILL THEN
                    l_ccid := p_ccid_record.salesrep_ccid_rev;
                ELSIF p_account_class = UNEARN THEN
                    l_ccid := p_ccid_record.salesrep_ccid_rev;
                ELSIF p_account_class = SUSPENSE THEN
                    l_ccid := p_ccid_record.salesrep_ccid_rev;
                END IF;
            ELSIF( l_tbl = 'RA_STD_TRX_LINES' ) THEN
                --
                -- For all account classes except REC
                --
                IF p_account_class in (REV, CHARGES) THEN
                    l_ccid := p_ccid_record.lineitem_ccid_rev;
                ELSIF p_account_class = FREIGHT THEN
                    l_ccid := p_ccid_record.lineitem_ccid_rev;
                ELSIF p_account_class = TAX THEN
                    l_ccid := p_ccid_record.lineitem_ccid_rev;
                ELSIF p_account_class = UNBILL THEN
                    l_ccid := p_ccid_record.lineitem_ccid_rev;
                ELSIF p_account_class = UNEARN THEN
                    l_ccid := p_ccid_record.lineitem_ccid_rev;
                ELSIF p_account_class = SUSPENSE THEN
                    l_ccid := p_ccid_record.lineitem_ccid_rev;
                END IF;
            ELSIF( l_tbl = 'RA_TAXES' ) THEN
                --
                -- For TAX account class only
                --
                IF p_account_class = TAX THEN
                    l_ccid := p_ccid_record.tax_ccid_tax;
                END IF;
            ELSIF( l_tbl = 'AGREEMENT/CATEGORY' ) THEN
                --
                -- For REV, CHARGES account classes
                --
                IF p_account_class in (REV, CHARGES) THEN
                    l_ccid := p_ccid_record.agreecat_ccid_rev;
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

            --
            -- Derive the interim tax account segments for deferred tax
            --
            IF (p_account_class = 'TAX')
                   AND (p_ccid_record.interim_tax_ccid IS NOT NULL) THEN

               IF l_tbl = 'RA_TAXES' THEN
                  -- Only get segment if have valid ccid
                  --
                  IF( p_ccid_record.interim_tax_ccid = -1) THEN
                      l_int_seg_value := INVALID_SEGMENT;
                  ELSE
                     l_int_seg_value :=
                        get_segment_from_glcc( p_ccid_record.interim_tax_ccid, l_seg_num);

                     IF ( l_int_seg_value IS NULL ) THEN
                        --
                        -- assign invalid segment value if no data found
                        --
                        l_int_seg_value := INVALID_SEGMENT;
                     END IF;
                  END IF;

               ELSE
                  l_int_seg_value := l_seg_value;
               END IF;

               l_int_concat_segments := l_int_concat_segments || l_delim || l_int_seg_value;
               l_int_seg_table(i+1)  := l_int_seg_value;

            END IF; -- if account class is TAX

        END IF;  -- if const is not null
    END LOOP;

    -- call ccid reader
    p_ccid := search_glcc_for_ccid(
                                     system_info,
                                     l_seg_table,
                                     l_cnt,
                                     p_account_class,
                                     l_concat_segments );

    -- return concat segs, and ccid
    p_concat_segments := l_concat_segments;

    -- call ccid reader for interim tax account
    IF (p_account_class = 'TAX')
           AND (p_ccid_record.interim_tax_ccid IS NOT NULL) THEN
        p_int_ccid := search_glcc_for_ccid(
                                         system_info,
                                         l_int_seg_table,
                                         l_cnt,
                                         p_account_class,
                                         l_int_concat_segments );

        -- return concat segs, and ccid for interim tax account
        p_int_concat_segments := l_int_concat_segments;
    END IF;

    print_fcn_label2( 'arp_auto_accounting.assemble_code_combination()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.assemble_code_combination('
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
--        line_id
--        trx_type_id
--        salesrep_id
--        inv_item_id
--        memo_line_id
--        site_use_id
--        warehouse_id
--        ccid_tax
--
--      IN/OUT:
--        ccid
--        concat_segments
--        int_ccid (Interim tax account ccid)
--        int_concat_segments (Interim tax account concatenated segments)
--
-- RETURNS:
--   1 if success, 0 otherwise
--
-- NOTES:
--
-- HISTORY:
--
PROCEDURE flex_manager( p_account_class IN VARCHAR2,
                       p_line_id IN NUMBER,
                       p_trx_type_id IN BINARY_INTEGER,
                       p_salesrep_id IN BINARY_INTEGER,
                       p_inv_item_id IN BINARY_INTEGER,
                       p_memo_line_id IN BINARY_INTEGER,
                       p_ccid_tax IN BINARY_INTEGER,
                       p_int_ccid_tax IN BINARY_INTEGER,
                       p_site_use_id IN NUMBER,
                       p_warehouse_id IN BINARY_INTEGER,
                       p_ccid IN OUT NOCOPY BINARY_INTEGER,
                       p_concat_segments IN OUT NOCOPY VARCHAR2,
                       p_int_ccid  IN OUT NOCOPY BINARY_INTEGER,
                       p_int_concat_segments IN OUT NOCOPY VARCHAR2 )  IS

    l_ccid_record ccid_rec_type;
    l_inv_item_type   mtl_system_items.item_type%TYPE;

    PROCEDURE print_params IS
    BEGIN
        debug('EXCEPTION: arp_auto_accounting.flex_manager('
              || p_account_class         || ', '
              || to_char(p_line_id)      || ', '
              || to_char(p_trx_type_id)  || ', '
              || to_char(p_salesrep_id)  || ', '
              || to_char(p_inv_item_id)  || ', '
              || to_char(p_memo_line_id) || ', '
              || to_char(p_ccid_tax)     || ', '
              || to_char(p_int_ccid_tax) || ', '
              || to_char(p_site_use_id)  || ', '
              || to_char(p_warehouse_id) || ')',
              MSG_LEVEL_DEBUG);

    END;

BEGIN

    print_fcn_label( 'arp_auto_accounting.flex_manager()+' );

    debug( '  account_class='||p_account_class, MSG_LEVEL_DEBUG );
    debug( '  line_id='||to_char(p_line_id), MSG_LEVEL_DEBUG );
    debug( '  trx_type_id='||to_char(p_trx_type_id), MSG_LEVEL_DEBUG );
    debug( '  salesrep_id='||to_char(p_salesrep_id), MSG_LEVEL_DEBUG );
    debug( '  inv_item_id='||to_char(p_inv_item_id), MSG_LEVEL_DEBUG );
    debug( '  memo_line_id='||to_char(p_memo_line_id), MSG_LEVEL_DEBUG );
    debug( '  ccid_tax='||to_char(p_ccid_tax), MSG_LEVEL_DEBUG );
    debug( '  int_ccid_tax='||to_char(p_int_ccid_tax), MSG_LEVEL_DEBUG );
    debug( '  site_use_id='||to_char(p_site_use_id), MSG_LEVEL_DEBUG );
    debug( '  warehouse_id='||to_char(p_warehouse_id), MSG_LEVEL_DEBUG );

    --
    -- Initialize
    --
    p_concat_segments := NULL;
    p_ccid := -1;

    --
    -- deferred tax is optional so initialize interim tax to null
    --

    p_int_concat_segments := NULL;
    p_int_ccid := NULL;

    --
    -- Validate inv_item_id, memo_line_id: at least one must be NULL
    --
    IF( p_inv_item_id is NOT NULL AND p_memo_line_id is NOT NULL ) THEN
        --
        -- error condition
        g_error_buffer := 'Either item id or memo line id must be null';
	debug( 'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
        RAISE item_and_memo_both_not_null;
    END IF;

    --
    --
    --
    get_default_ccids( profile_info,
                       p_account_class,
                       p_line_id,
                       p_trx_type_id,
                       p_salesrep_id,
                       p_inv_item_id,
                       p_memo_line_id,
                       p_site_use_id,
                       p_warehouse_id,
                       l_ccid_record,
                       l_inv_item_type );

    --
    -- Add tax ccid to the ccid record
    --
    IF( p_ccid_tax is null) THEN
        l_ccid_record.tax_ccid_tax := -1;
    ELSE
        l_ccid_record.tax_ccid_tax := p_ccid_tax;
    END IF;

    --
    -- Add interim tax ccid to the ccid record values null or ccid
    --

    l_ccid_record.interim_tax_ccid := p_int_ccid_tax;

    -- Dump ccid record, item type
    --
    dump_ccid_record( l_ccid_record );

    debug( '  inv_item_type='||l_inv_item_type, MSG_LEVEL_DEBUG );

    --
    -- Assemble segments and get ccid
    --
    assemble_code_combination( system_info,
                               flex_info,
                               p_account_class,
                               l_ccid_record,
                               l_inv_item_type,
                               p_ccid,
                               p_concat_segments,
                               p_int_ccid,
                               p_int_concat_segments );


    debug( '  ccid= '||to_char(p_ccid), MSG_LEVEL_DEBUG );
    debug( '  concat_segs= '||p_concat_segments, MSG_LEVEL_DEBUG );

    debug( '  interim_tax_ccid= '||to_char(p_int_ccid), MSG_LEVEL_DEBUG );
    debug( '  interim_tax_concat_segs= '||p_int_concat_segments, MSG_LEVEL_DEBUG );

    print_fcn_label( 'arp_auto_accounting.flex_manager()-' );

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
--        customer_trx_line_id
--        cust_trx_line_salesrep_id
--        request_id
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
                           p_customer_trx_id 		IN BINARY_INTEGER,
                           p_customer_trx_line_id 	IN NUMBER,
                           p_cust_trx_line_salesrep_id 	IN NUMBER,
                           p_request_id 		IN BINARY_INTEGER )
  RETURN VARCHAR2 IS

    l_delete_stmt               VARCHAR2(1000);
    l_account_class_pred        VARCHAR2(500);
    l_request_id_pred           VARCHAR2(500);
    l_ctid_pred                 VARCHAR2(500);
    l_ctlid_pred                VARCHAR2(500);
    l_ctlsid_pred               VARCHAR2(500);

BEGIN
    print_fcn_label( 'arp_auto_accounting.build_delete_sql()+' );

    --
    -- account_class
    --
    IF( p_account_class = REV ) THEN
        l_account_class_pred := CRLF ||
'AND account_class in (''REV'', ''UNBILL'', ''UNEARN'')';
    ELSE
        l_account_class_pred := CRLF ||
'AND account_class = ''' || p_account_class || '''';
    END IF;

    --
    -- request_id
    --
    IF( p_request_id IS NOT NULL ) THEN
        l_request_id_pred := CRLF ||
'AND request_id = ' || to_char( p_request_id );
    END IF;

    --
    -- customer_trx_id
    --
    IF( p_customer_trx_id IS NOT NULL ) THEN
        l_ctid_pred := CRLF ||
'AND customer_trx_id = ' || to_char( p_customer_trx_id );

      /*9112739 Added IF clause code to prevent UNEARN deletion*/
      IF( p_account_class = UNEARN ) THEN

        l_ctid_pred := CRLF ||
'AND customer_trx_id in
(
  SELECT customer_trx_id
  FROM   ra_customer_trx ct
  WHERE  (ct.customer_trx_id  = '
            || to_char( p_customer_trx_id ) || CRLF ||
  '  AND nvl(ct.invoicing_rule_id,-10) = -2 )' || CRLF ||
')';


      END IF;

    END IF;

    --
    -- customer_trx_line_id
    --
    IF( p_customer_trx_line_id IS NOT NULL ) THEN
/*9112739 Added IF-ELSE clause code to prevent UNEARN deletion*/

      IF( p_account_class = UNEARN ) THEN

        l_ctlid_pred := CRLF ||
'AND customer_trx_line_id in
(
  SELECT customer_trx_line_id
  FROM   ra_customer_trx_lines ctl, ra_customer_trx ct
  WHERE  ct.customer_trx_id=ctl.customer_trx_id AND nvl(ct.invoicing_rule_id,-10) = -2 AND (ctl.customer_trx_line_id  = '
            || to_char( p_customer_trx_line_id ) || CRLF ||
'          or ctl.link_to_cust_trx_line_id = '
            || to_char( p_customer_trx_line_id ) || ')' || CRLF ||
')';

      ELSE

        l_ctlid_pred := CRLF ||
'AND customer_trx_line_id in
(
  SELECT customer_trx_line_id
  FROM   ra_customer_trx_lines ctl
  WHERE  (ctl.customer_trx_line_id  = '
            || to_char( p_customer_trx_line_id ) || CRLF ||
'          or ctl.link_to_cust_trx_line_id = '
            || to_char( p_customer_trx_line_id ) || ')' || CRLF ||
')';

      END IF;

    END IF;

    --
    -- salesrep_id
    --

    IF( p_cust_trx_line_salesrep_id IS NOT NULL ) THEN

    /* Bug 2524140 - When REV accounts based on salesrep,
       autoaccounting creating multiple TAX rows
       with alternating +100/-100 percentages. */

        IF ((p_account_class = 'TAX' AND
             p_system_info.tax_based_on_salesrep) OR
             p_account_class <> 'TAX') THEN

        l_ctlsid_pred := CRLF ||
'AND cust_trx_line_salesrep_id = ' || to_char(p_cust_trx_line_salesrep_id ) ;

        END IF;

    END IF;

    --
    -- Construct the Delete Statement
    --
    l_delete_stmt :=
'DELETE from ra_cust_trx_line_gl_dist gd
WHERE gl_posted_date is null'
|| l_account_class_pred
|| l_request_id_pred
|| l_ctid_pred
|| l_ctlid_pred
|| l_ctlsid_pred
|| CRLF ||
'AND account_set_flag = (SELECT decode(ct.invoicing_rule_id,
                                      NULL, ''N'',
                                      ''Y'')
                        FROM   ra_customer_trx ct
                        WHERE  ct.customer_trx_id = gd.customer_trx_id)';


    debug( l_delete_stmt, MSG_LEVEL_DEBUG );
    debug( '  len(l_delete_stmt)=' || to_char(LENGTHB(l_delete_stmt)),
           MSG_LEVEL_DEBUG );

    print_fcn_label( 'arp_auto_accounting.build_delete_sql()-' );

    RETURN l_delete_stmt;


EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.build_delete_sql()',
	      MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END build_delete_sql;


----------------------------------------------------------------------------
PROCEDURE get_column_values( p_select_c   IN  INTEGER,
                             p_select_rec OUT NOCOPY select_rec_type ) IS
BEGIN
    print_fcn_label2( 'arp_auto_accounting.get_column_values()+' );

    dbms_sql.column_value( p_select_c, 1, p_select_rec.customer_trx_id );
    dbms_sql.column_value( p_select_c, 2, p_select_rec.customer_trx_line_id );
    dbms_sql.column_value( p_select_c, 3,
                           p_select_rec.cust_trx_line_salesrep_id );
    dbms_sql.column_value( p_select_c, 4, p_select_rec.line_amount );
    dbms_sql.column_value( p_select_c, 5,
                           p_select_rec.accounted_line_amount );
    dbms_sql.column_value( p_select_c, 6, p_select_rec.percent );
    dbms_sql.column_value( p_select_c, 7, p_select_rec.amount );
    dbms_sql.column_value( p_select_c, 8, p_select_rec.acctd_amount );
    dbms_sql.column_value( p_select_c, 9, p_select_rec.account_class );
    dbms_sql.column_value( p_select_c, 10, p_select_rec.account_set_flag );
    dbms_sql.column_value( p_select_c, 11, p_select_rec.cust_trx_type_id );
    dbms_sql.column_value( p_select_c, 12,
                           p_select_rec.allow_not_open_flag );
    dbms_sql.column_value( p_select_c, 13,
                           p_select_rec.concatenated_segments );
    dbms_sql.column_value( p_select_c, 14, p_select_rec.code_combination_id );
    dbms_sql.column_value( p_select_c, 15, p_select_rec.gl_date );
    dbms_sql.column_value( p_select_c, 16, p_select_rec.original_gl_date );
    dbms_sql.column_value( p_select_c, 17, p_select_rec.ussgl_trx_code );
    dbms_sql.column_value( p_select_c, 18,
                           p_select_rec.ussgl_trx_code_context );
    dbms_sql.column_value( p_select_c, 19, p_select_rec.salesrep_id );
    dbms_sql.column_value( p_select_c, 20, p_select_rec.inventory_item_id );
    dbms_sql.column_value( p_select_c, 21, p_select_rec.memo_line_id );
    dbms_sql.column_value( p_select_c, 22, p_select_rec.default_tax_ccid );
    dbms_sql.column_value( p_select_c, 23, p_select_rec.interim_tax_ccid );
    dbms_sql.column_value( p_select_c, 24, p_select_rec.site_use_id );
    dbms_sql.column_value( p_select_c, 25, p_select_rec.warehouse_id );
    -- 1651593
    dbms_sql.column_value( p_select_c, 26, p_select_rec.link_to_cust_trx_line_id);

    /* 5148504 - return null value when interim_tax_ccid comes
         back from SELECT as -1 */
    IF p_select_rec.interim_tax_ccid = -1
    THEN
       p_select_rec.interim_tax_ccid := NULL;
    END IF;

    print_fcn_label2( 'arp_auto_accounting.get_column_values()-' );
EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.get_column_values()',
		MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END get_column_values;

----------------------------------------------------------------------------
PROCEDURE get_column_values( p_select_c   IN  INTEGER,
                             p_select_tab OUT NOCOPY select_rec_tab ) IS
BEGIN
    print_fcn_label2( 'arp_auto_accounting.get_column_values(tab)+' );

    dbms_sql.column_value( p_select_c, 1, p_select_tab.customer_trx_id );
    dbms_sql.column_value( p_select_c, 2, p_select_tab.customer_trx_line_id );
    dbms_sql.column_value( p_select_c, 3,
                           p_select_tab.cust_trx_line_salesrep_id );
    dbms_sql.column_value( p_select_c, 4, p_select_tab.line_amount );
    dbms_sql.column_value( p_select_c, 5,
                           p_select_tab.accounted_line_amount );
    dbms_sql.column_value( p_select_c, 6, p_select_tab.percent );
    dbms_sql.column_value( p_select_c, 7, p_select_tab.amount );
    dbms_sql.column_value( p_select_c, 8, p_select_tab.acctd_amount );
    dbms_sql.column_value( p_select_c, 9, p_select_tab.account_class );
    dbms_sql.column_value( p_select_c, 10, p_select_tab.account_set_flag );
    dbms_sql.column_value( p_select_c, 11, p_select_tab.cust_trx_type_id );
    dbms_sql.column_value( p_select_c, 12,
                           p_select_tab.allow_not_open_flag );
    dbms_sql.column_value( p_select_c, 13,
                           p_select_tab.concatenated_segments );
    dbms_sql.column_value( p_select_c, 14, p_select_tab.code_combination_id );
    dbms_sql.column_value( p_select_c, 15, p_select_tab.gl_date );
    dbms_sql.column_value( p_select_c, 16, p_select_tab.original_gl_date );
    dbms_sql.column_value( p_select_c, 17, p_select_tab.ussgl_trx_code );
    dbms_sql.column_value( p_select_c, 18,
                           p_select_tab.ussgl_trx_code_context );
    dbms_sql.column_value( p_select_c, 19, p_select_tab.salesrep_id );
    dbms_sql.column_value( p_select_c, 20, p_select_tab.inventory_item_id );
    dbms_sql.column_value( p_select_c, 21, p_select_tab.memo_line_id );
    dbms_sql.column_value( p_select_c, 22, p_select_tab.default_tax_ccid );
    dbms_sql.column_value( p_select_c, 23, p_select_tab.interim_tax_ccid );
    dbms_sql.column_value( p_select_c, 24, p_select_tab.site_use_id );
    dbms_sql.column_value( p_select_c, 25, p_select_tab.warehouse_id );
    -- 1651593
    dbms_sql.column_value( p_select_c, 26, p_select_tab.link_to_cust_trx_line_id);

    print_fcn_label2( 'arp_auto_accounting.get_column_values(tab)-' );
EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.get_column_values()',
		MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END get_column_values;


----------------------------------------------------------------------------
PROCEDURE correct_rounding_errors( select_record 	IN OUT NOCOPY select_rec_type,
                                   total_percent 	IN OUT NOCOPY NUMBER,
                                   total_amount 	IN OUT NOCOPY NUMBER,
                                   total_acctd_amount 	IN OUT NOCOPY NUMBER) IS
BEGIN
    print_fcn_label2( 'arp_auto_accounting.correct_rounding_errors()+' );

    -- update totals

    total_percent := total_percent + select_record.percent;
    total_amount := total_amount + select_record.amount;
    total_acctd_amount := total_acctd_amount + select_record.acctd_amount;

    -- check total percent
    IF( total_percent = 100 ) THEN

        -- entered amount
        select_record.amount := select_record.amount +
                              ( select_record.line_amount - total_amount );
        total_amount := 0;
        total_percent := 0;

        -- acctd amount
        select_record.acctd_amount :=
			select_record.acctd_amount +
                		( select_record.accounted_line_amount -
                                  total_acctd_amount );
        total_acctd_amount := 0;

    ELSIF( total_percent = 0 ) THEN

        -- entered amount
        select_record.amount := select_record.amount - total_amount;
        total_amount := 0;
        total_percent := 0;

        -- acctd amount
        select_record.acctd_amount := select_record.acctd_amount -
                                      total_acctd_amount;
        total_acctd_amount := 0;

    END IF;

    print_fcn_label2( 'arp_auto_accounting.correct_rounding_errors()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.correct_rounding_errors()',
		MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END correct_rounding_errors;


----------------------------------------------------------------------------
PROCEDURE insert_dist_row( p_system_info  IN
                              arp_trx_global.system_info_rec_type,
                            p_profile_info IN
                              arp_trx_global.profile_rec_type,
                            p_request_id   IN BINARY_INTEGER,
                            p_select_tab   IN select_rec_tab,
			    p_low  IN NUMBER,
                            p_high IN NUMBER )  IS

l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;   /* mrc */
--Bug#2750340
l_xla_event      arp_xla_events.xla_events_type;
inext            NUMBER := 0;
inow             NUMBER := 0;

BEGIN
    print_fcn_label2( 'arp_auto_accounting.insert_dist_row()+' );

   /* Bug 2560036 - modified insert to set rec_offset_flag in
      support of directly inserted UNEARN rows for RAM-C */

   FORALL i IN p_low..p_high
    INSERT into ra_cust_trx_line_gl_dist
    (
      cust_trx_line_gl_dist_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      set_of_books_id,
      request_id,
      customer_trx_id,
      customer_trx_line_id,
      cust_trx_line_salesrep_id,
      percent,
      amount,
      acctd_amount,
      account_class,
      account_set_flag,
      concatenated_segments,
      code_combination_id,
      gl_date,
      original_gl_date,
      ussgl_transaction_code,
      ussgl_transaction_code_context,
      posting_control_id,
      latest_rec_flag,
      collected_tax_concat_seg,
      collected_tax_ccid,
      rec_offset_flag
      ,org_id
    )
    VALUES
    (
      ra_cust_trx_line_gl_dist_s.nextval,
      p_profile_info.user_id,
      sysdate,
      p_profile_info.user_id,
      sysdate,
      p_system_info.system_parameters.set_of_books_id,
      p_request_id,
      p_select_tab.customer_trx_id(i),
      p_select_tab.customer_trx_line_id(i),
      p_select_tab.cust_trx_line_salesrep_id(i),
      round(nvl(p_select_tab.percent(i), 0), 4),
      decode(p_select_tab.account_set_flag(i),
	     'Y', null, p_select_tab.amount(i)),
      decode(p_select_tab.account_set_flag(i),
             'Y', null, p_select_tab.acctd_amount(i)),
      p_select_tab.account_class(i),
      p_select_tab.account_set_flag(i),
      decode(p_select_tab.int_code_combination_id(i),
             '', decode(p_select_tab.code_combination_id(i),
                        -1, p_select_tab.concatenated_segments(i),
                        NULL ),
             -1, p_select_tab.int_concatenated_segments(i),
             NULL),
      decode(p_select_tab.int_code_combination_id(i),
             '', p_select_tab.code_combination_id(i),
             p_select_tab.int_code_combination_id(i)),
      to_date(p_select_tab.gl_date(i), 'J'),
      to_date(p_select_tab.original_gl_date(i), 'J'),
      p_select_tab.ussgl_trx_code(i),
      p_select_tab.ussgl_trx_code_context(i),
      -3,
      decode( p_select_tab.account_class(i),
              'REC', 'Y',
              NULL),
      decode(p_select_tab.int_code_combination_id(i),
             '',NULL,
             decode(p_select_tab.code_combination_id(i),
                     -1, p_select_tab.concatenated_segments(i),
                    NULL)),
      decode(p_select_tab.int_code_combination_id(i),
             '',NULL,
             p_select_tab.code_combination_id(i)),
      DECODE(p_select_tab.account_set_flag(i), 'Y', NULL,
        DECODE(p_select_tab.account_class(i), 'UNEARN', 'Y', NULL))
       ,arp_standard.sysparm.org_id --anuj
    )
   RETURNING cust_trx_line_gl_dist_id
   BULK COLLECT INTO l_gl_dist_key_value_list;

   /* only insert the MRC gl_dist data if this has been called from
      forms.  For autoinv this insert is handled differently by
      request_id.
      -- Added by Bsarkar
      The g_called_from is introduced to stop the call for Invoice Creation
      API. In case AUTO_ACCOUNTING is called from Tax engine for Invoice API
      this variable
      will have different value and won't execute the MRC call. The MRC call
      for invoice creation API is handled based on request Id and this call is
      not required. */


   IF (p_request_id IS NULL AND g_called_from = 'FORMS' ) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('calling mrc engine for insertion of gl dist data');
         END IF;
      --BUG#2750340
       FOR i IN p_low .. p_high LOOP
         inext := p_select_tab.customer_trx_id(i);
         IF inext <> inow THEN
           l_xla_event.xla_from_doc_id  := p_select_tab.customer_trx_id(i);
           l_xla_event.xla_to_doc_id    := p_select_tab.customer_trx_id(i);
           l_xla_event.xla_req_id       := NULL;
           l_xla_event.xla_dist_id      := NULL;
           l_xla_event.xla_doc_table    := 'CT';
           l_xla_event.xla_doc_event    := NULL;
           l_xla_event.xla_mode         := 'O';
           l_xla_event.xla_call         := 'B';

           ARP_XLA_EVENTS.CREATE_EVENTS(p_xla_ev_rec => l_xla_event );
           inow := inext;
         END IF;
      END LOOP;
   END IF;

    print_fcn_label2( 'arp_auto_accounting.insert_dist_row()-' );
EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.insert_dist_row()',
		MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END insert_dist_row;

----------------------------------------------------------------------------
PROCEDURE dump_select_rec( p_select_rec IN select_rec_type ) IS
BEGIN
    print_fcn_label2( 'arp_auto_accounting.dump_select_rec()+' );

    debug( '  Dumping select record: ', MSG_LEVEL_DEBUG );
    debug( '  customer_trx_id='
           || to_char( p_select_rec.customer_trx_id ), MSG_LEVEL_DEBUG );
    debug( '  customer_trx_line_id='
           || to_char( p_select_rec.customer_trx_line_id ), MSG_LEVEL_DEBUG );
    debug( '  customer_trx_line_salesrep_id='
          || to_char( p_select_rec.cust_trx_line_salesrep_id ),
          MSG_LEVEL_DEBUG );
    debug( '  line_amount='
           || to_char( p_select_rec.line_amount ), MSG_LEVEL_DEBUG );
    debug( '  accounted_line_amount='
           || to_char( p_select_rec.accounted_line_amount ), MSG_LEVEL_DEBUG );
    debug( '  percent='
           || to_char( p_select_rec.percent ), MSG_LEVEL_DEBUG );
    debug( '  amount='
           || to_char( p_select_rec.amount ), MSG_LEVEL_DEBUG );
    debug( '  acctd_amount='
           || to_char( p_select_rec.acctd_amount ), MSG_LEVEL_DEBUG );
    debug( '  account_class=' || p_select_rec.account_class, MSG_LEVEL_DEBUG );
    debug( '  account_set_flag=' || p_select_rec.account_set_flag,
           MSG_LEVEL_DEBUG );
    debug( '  cust_trx_type_id='
           || to_char( p_select_rec.cust_trx_type_id ), MSG_LEVEL_DEBUG );
    debug( '  allow_not_open_flag=' ||
           p_select_rec.allow_not_open_flag, MSG_LEVEL_DEBUG );
    debug( '  concatenated_segments='
           || p_select_rec.concatenated_segments, MSG_LEVEL_DEBUG );
    debug( '  code_combination_id='
           || to_char( p_select_rec.code_combination_id ), MSG_LEVEL_DEBUG );
    debug( '  gl_date=' || p_select_rec.gl_date, MSG_LEVEL_DEBUG );
    debug( '  original_gl_date=' || p_select_rec.original_gl_date,
           MSG_LEVEL_DEBUG );
    debug( '  ussgl_trx_code=' || p_select_rec.ussgl_trx_code, MSG_LEVEL_DEBUG );
    debug( '  ussgl_trx_code_context='
           || p_select_rec.ussgl_trx_code_context, MSG_LEVEL_DEBUG );
    debug( '  salesrep_id='
           || to_char( p_select_rec.salesrep_id ), MSG_LEVEL_DEBUG );
    debug( '  inventory_item_id='
           || to_char( p_select_rec.inventory_item_id ), MSG_LEVEL_DEBUG );
    debug( '  memo_line_id='
           || to_char( p_select_rec.memo_line_id ), MSG_LEVEL_DEBUG );
    debug( '  default_tax_ccid='
           || to_char( p_select_rec.default_tax_ccid ), MSG_LEVEL_DEBUG );
    debug( '  interim_tax_ccid='
           || to_char( p_select_rec.interim_tax_ccid ), MSG_LEVEL_DEBUG );
    debug( '  site_use_id='
           || to_char( p_select_rec.site_use_id ), MSG_LEVEL_DEBUG );
    debug( '  warehouse_id='
           || to_char( p_select_rec.warehouse_id ), MSG_LEVEL_DEBUG );

    print_fcn_label2( 'arp_auto_accounting.dump_select_rec()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.dump_select_rec()',
		MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
END dump_select_rec;

----------------------------------------------------------------------------
PROCEDURE dump_select_tab( p_select_tab IN select_rec_tab, p_low IN NUMBER, p_high IN NUMBER ) IS
BEGIN
    print_fcn_label2( 'arp_auto_accounting.dump_select_tab()+' );

/* bug 1532372 - changed parameter from l_rows_fetched to l_low and l_high
                 this apparently corrects the 1000 REC row limit that
                 we encountered during benchmarking.  */

   FOR i in p_low..p_high LOOP
    debug( '  Dumping select record: [' || i ||']', MSG_LEVEL_DEBUG );
    debug( '  customer_trx_id='
           || to_char( p_select_tab.customer_trx_id(i) ), MSG_LEVEL_DEBUG );
    debug( '  customer_trx_line_id='
           || to_char( p_select_tab.customer_trx_line_id (i)), MSG_LEVEL_DEBUG );
    debug( '  customer_trx_line_salesrep_id='
          || to_char( p_select_tab.cust_trx_line_salesrep_id(i)),
          MSG_LEVEL_DEBUG );
    debug( '  line_amount='
           || to_char( p_select_tab.line_amount(i) ), MSG_LEVEL_DEBUG );
    debug( '  accounted_line_amount='
           || to_char( p_select_tab.accounted_line_amount (i)), MSG_LEVEL_DEBUG );
    debug( '  percent='
           || to_char( p_select_tab.percent(i) ), MSG_LEVEL_DEBUG );
    debug( '  amount='
           || to_char( p_select_tab.amount(i) ), MSG_LEVEL_DEBUG );
    debug( '  acctd_amount='
           || to_char( p_select_tab.acctd_amount(i) ), MSG_LEVEL_DEBUG );
    debug( '  account_class=' || p_select_tab.account_class(i), MSG_LEVEL_DEBUG );
    debug( '  account_set_flag=' || p_select_tab.account_set_flag(i),
           MSG_LEVEL_DEBUG );
    debug( '  cust_trx_type_id='
           || to_char( p_select_tab.cust_trx_type_id(i) ), MSG_LEVEL_DEBUG );
    debug( '  allow_not_open_flag=' ||
           p_select_tab.allow_not_open_flag(i), MSG_LEVEL_DEBUG );
    debug( '  concatenated_segments='
           || p_select_tab.concatenated_segments(i), MSG_LEVEL_DEBUG );
    debug( '  code_combination_id='
           || to_char( p_select_tab.code_combination_id (i)), MSG_LEVEL_DEBUG );
    debug( '  gl_date=' || p_select_tab.gl_date(i), MSG_LEVEL_DEBUG );
    debug( '  original_gl_date=' || p_select_tab.original_gl_date(i),
           MSG_LEVEL_DEBUG );
    debug( '  ussgl_trx_code=' || p_select_tab.ussgl_trx_code(i), MSG_LEVEL_DEBUG );
    debug( '  ussgl_trx_code_context='
           || p_select_tab.ussgl_trx_code_context(i), MSG_LEVEL_DEBUG );
    debug( '  salesrep_id='
           || to_char( p_select_tab.salesrep_id (i)), MSG_LEVEL_DEBUG );
    debug( '  inventory_item_id='
           || to_char( p_select_tab.inventory_item_id (i)), MSG_LEVEL_DEBUG );
    debug( '  memo_line_id='
           || to_char( p_select_tab.memo_line_id (i)), MSG_LEVEL_DEBUG );
    debug( '  default_tax_ccid='
           || to_char( p_select_tab.default_tax_ccid(i) ), MSG_LEVEL_DEBUG );
    debug( '  interim_tax_ccid='
           || to_char( p_select_tab.interim_tax_ccid(i) ), MSG_LEVEL_DEBUG );
    debug( '  site_use_id='
           || to_char( p_select_tab.site_use_id (i)), MSG_LEVEL_DEBUG );
    debug( '  warehouse_id='
           || to_char( p_select_tab.warehouse_id (i)), MSG_LEVEL_DEBUG );
   END LOOP;

    print_fcn_label2( 'arp_auto_accounting.dump_select_tab()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.dump_select_tab()',
		MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
END dump_select_tab;
----------------------------------------------------------------------------

FUNCTION get_select_rec(  p_select_tab IN select_rec_tab, p_cnt IN NUMBER )
RETURN select_rec_type AS

   p_select_rec select_rec_type;
   i INTEGER:=0;

BEGIN

   print_fcn_label2( 'arp_auto_accounting.get_select_rec(tab)+' );
    debug( '  p_cnt='
           || p_cnt, MSG_LEVEL_DEBUG );
   i := 1;
   p_select_rec.customer_trx_id                     := p_select_tab.customer_trx_id(p_cnt);
   i := i+1;
   p_select_rec.customer_trx_line_id                := p_select_tab.customer_trx_line_id(p_cnt);
   i := i+1;
   p_select_rec.cust_trx_line_salesrep_id           := p_select_tab.cust_trx_line_salesrep_id(p_cnt);
   i := i+1;
   p_select_rec.line_amount                         := p_select_tab.line_amount(p_cnt);
   i := i+1; --5
   p_select_rec.accounted_line_amount               := p_select_tab.accounted_line_amount(p_cnt);
   i := i+1;
   p_select_rec.percent                             := p_select_tab.percent(p_cnt);
   i := i+1;
   p_select_rec.amount                              := p_select_tab.amount(p_cnt);
   i := i+1;
   p_select_rec.acctd_amount                        := p_select_tab.acctd_amount(p_cnt);
   i := i+1;
   p_select_rec.account_class                       := p_select_tab.account_class(p_cnt);
   i := i+1; --10
   p_select_rec.account_set_flag                    := p_select_tab.account_set_flag(p_cnt);
   i := i+1;
   p_select_rec.cust_trx_type_id                    := p_select_tab.cust_trx_type_id(p_cnt);
   i := i+1;
   p_select_rec.allow_not_open_flag                 := p_select_tab.allow_not_open_flag(p_cnt);
   i := i+1;
   p_select_rec.concatenated_segments               := p_select_tab.concatenated_segments(p_cnt);
   i := i+1;
   p_select_rec.code_combination_id                 := p_select_tab.code_combination_id(p_cnt);
   i := i+1; --15
   p_select_rec.gl_date                             := p_select_tab.gl_date(p_cnt);
   i := i+1;
   p_select_rec.original_gl_date                    := p_select_tab.original_gl_date(p_cnt);
   i := i+1;
   p_select_rec.ussgl_trx_code                      := p_select_tab.ussgl_trx_code(p_cnt);
   i := i+1;
   p_select_rec.ussgl_trx_code_context              := p_select_tab.ussgl_trx_code_context(p_cnt);
   i := i+1;
   p_select_rec.salesrep_id                         := p_select_tab.salesrep_id(p_cnt);
   i := i+1; --20
   p_select_rec.inventory_item_id                   := p_select_tab.inventory_item_id(p_cnt);
   i := i+1;
   p_select_rec.memo_line_id                        := p_select_tab.memo_line_id(p_cnt);
   i := i+1;
   p_select_rec.default_tax_ccid                    := p_select_tab.default_tax_ccid(p_cnt);
   i := i+1;

   /* 5148504 - Insure that interim_tax_ccid returns as null
       if etax/arp_etax_util returns it as -1.  Otherwise, this
       artificially acts as if it is deferred tax. */
   IF p_select_tab.interim_tax_ccid(p_cnt) = -1
   THEN
      p_select_rec.interim_tax_ccid := NULL;
   ELSE
      p_select_rec.interim_tax_ccid := p_select_tab.interim_tax_ccid(p_cnt);
   END IF;
   i := i+1; --24
--   p_select_rec.int_concatenated_segments           := p_select_tab.int_concatenated_segments(p_cnt);
   i := i+1; --25
--   p_select_rec.int_code_combination_id             := p_select_tab.int_code_combination_id(p_cnt);
   i := i+1;
   p_select_rec.site_use_id                         := p_select_tab.site_use_id(p_cnt);
   i := i+1;
   p_select_rec.warehouse_id                        := p_select_tab.warehouse_id(p_cnt);
   -- 1651593
   i := i+1;
   p_select_rec.link_to_cust_trx_line_id            := p_select_tab.link_to_cust_trx_line_id(p_cnt);

   return(p_select_rec);

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.get_select_rec():'|| i, MSG_LEVEL_BASIC);
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;

END;

----------------------------------------------------------------------------
PROCEDURE process_line( p_system_info 		IN
                          arp_trx_global.system_info_rec_type,
                        p_select_rec  		IN OUT NOCOPY select_rec_type,
                        p_total_percent 	IN OUT NOCOPY NUMBER,
                        p_total_amount 		IN OUT NOCOPY NUMBER,
                        p_total_acctd_amount 	IN OUT NOCOPY NUMBER,
                        p_failure_count	 	IN OUT NOCOPY BINARY_INTEGER,
                        p_mode                  IN VARCHAR2,
                        p_request_id            IN BINARY_INTEGER )  IS

    l_boolean  			BOOLEAN;
    l_default_gl_date 		DATE;
    l_default_rule_used 	VARCHAR2(50);
    l_error_message		VARCHAR2(256);

BEGIN
    --
    -- Default gl date if in closed period
    --
    debug( '  Defaulting gl_date', MSG_LEVEL_DEBUG );

    IF( p_select_rec.gl_date IS NOT NULL ) THEN

        l_boolean :=
            arp_standard.validate_and_default_gl_date
                ( to_date(p_select_rec.gl_date, 'J'),
                  to_date(p_select_rec.original_gl_date, 'J'),
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  p_select_rec.allow_not_open_flag,
                  NULL,
                  p_system_info.system_parameters.set_of_books_id,
                  222,
                  l_default_gl_date,
                  l_default_rule_used,
                  l_error_message );

        p_select_rec.gl_date := to_char( l_default_gl_date, 'J' );

        IF( l_boolean ) THEN
            debug( '  Using default gl date of ' ||
                   to_char( l_default_gl_date ), MSG_LEVEL_DEBUG );
            debug( '  derived by rule ' ||
                   l_default_rule_used, MSG_LEVEL_DEBUG );

        ELSE
            --
            -- defaulting gl_date failure
            --
            g_error_buffer := l_error_message;
	    debug( 'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
            RAISE error_defaulting_gl_date;
        END IF;
    END IF;

    --
    -- Correct rounding errors
    --
    debug( '  Correcting rounding errors', MSG_LEVEL_DEBUG );

    correct_rounding_errors( p_select_rec,
                             p_total_percent,
                             p_total_amount,
                             p_total_acctd_amount );

    --
    -- Set the CCID validation date
    --
 /* Bug 2142306 - added NVL function */
    validation_date := NVL(TO_DATE(p_select_rec.gl_date, 'J'), G_SYS_DATE);


/* Bug 2560036 - Change account class to 'UNEARN' if
   the transaction fails collectibility */

    IF (p_select_rec.account_class = 'REV' AND
        p_select_rec.account_set_flag = 'N' AND
        g_test_collectibility) THEN

        /* Bug 3440172/3446698 - Conflict between autoaccounting
           and collectibility causing imported DMs and on acct
           CMs to be missing REV distributions */
        /* Bug 4693399 - manually entered transactions can also be deferred
	   by contingencies */
       /*Bug 9112739 added for run in update mode */
       IF (p_mode in ( 'I' ,'U') AND
           t_collect.EXISTS(p_select_rec.customer_trx_line_id))
       THEN
          IF (t_collect(p_select_rec.customer_trx_line_id) =
                    ar_revenue_management_pvt.defer) THEN

             p_select_rec.account_class := 'UNEARN';
             p_select_rec.code_combination_id := NULL;

          END IF;

       END IF;

/*  We originally toyed with implementing
    collectibility for when a user maintains (or changes)
    a transaction.  But it was decided that for the initial
    go of this, a user steps outside of collectibility if they
    make any changes to a collectibility-deferred transaction. */

    END IF;

/* End bug 2560036 */

    --
    -- Call Flex manager
    --
    IF( p_select_rec.code_combination_id IS NULL ) THEN

        flex_manager( p_select_rec.account_class,
                      p_select_rec.customer_trx_line_id,
                      p_select_rec.cust_trx_type_id,
                      p_select_rec.salesrep_id,
                      p_select_rec.inventory_item_id,
                      p_select_rec.memo_line_id,
                      p_select_rec.default_tax_ccid,
                      p_select_rec.interim_tax_ccid,
                      p_select_rec.site_use_id,
                      p_select_rec.warehouse_id,
                      p_select_rec.code_combination_id,
                      p_select_rec.concatenated_segments,
                      p_select_rec.int_code_combination_id,
                      p_select_rec.int_concatenated_segments );
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

    --
    --Increment failure count if invalid ccid for interim tax account
    --

    IF( p_select_rec.int_code_combination_id = -1 ) THEN

        p_failure_count	 := nvl(p_failure_count, 0) + 1;

        debug('process_line:  Failure count : '||to_char(p_failure_count),
              MSG_LEVEL_DEBUG);
    END IF;

END process_line;


--
--
-- FUNCTION NAME:  do_autoaccounting
--
-- DECSRIPTION:
--   Server-side entry point for autoaccounting.
--   This is a cover function which calls the procedure do_autoaccounting
--   and exists for backward compatibility.  New programs should use
--   the procedure instead of the function.
--
-- ARGUMENTS:
--      IN:
--        mode:  May be I(nsert), U(pdate), D(elete), or (G)et
--        account_class:  REC, REV, FREIGHT, TAX, UNBILL, UNEARN, SUSPENSE,
--                        CHARGES
--        customer_trx_id:  NULL if not applicable
--        customer_trx_line_id:  NULL if not applicable
--        cust_trx_line_salesrep_id:  NULL if not applicable
--        request_id:  NULL if not applicable
--        gl_date:  GL date of the account assignment
--        original_gl_date:  Original GL date
--        total_trx_amount:  For Receivable account only
--        passed_ccid:  Code comination ID to use if supplied
--        force_account_set_no:
--        cust_trx_type_id:
--        primary_salesrep_id
--        inventory_item_id
--        memo_line_id
--        msg_level
--
--      IN/OUT:
--        ccid
--        concat_segments
--        num_dist_rows_failed
--        errorbuf
--
--      OUT:
--
-- RETURNS:
--   1 if no errors in deriving ccids and creating distributions,
--   0 if one or more rows where ccid could not be found,
--   Exception raised if SQL error or other fatal error.
--
-- NOTES:
--
-- HISTORY:
--
FUNCTION do_autoaccounting( p_mode IN VARCHAR2,
                            p_account_class IN VARCHAR2,
                            p_customer_trx_id IN NUMBER,
                            p_customer_trx_line_id IN NUMBER,
                            p_cust_trx_line_salesrep_id IN NUMBER,
                            p_request_id IN NUMBER,
                            p_gl_date IN DATE,
                            p_original_gl_date IN DATE,
                            p_total_trx_amount IN NUMBER,
                            p_passed_ccid IN NUMBER,
                            p_force_account_set_no IN VARCHAR2,
                            p_cust_trx_type_id IN NUMBER,
                            p_primary_salesrep_id IN NUMBER,
                            p_inventory_item_id IN NUMBER,
                            p_memo_line_id IN NUMBER,
                            p_ccid IN OUT NOCOPY NUMBER,
                            p_concat_segments IN OUT NOCOPY VARCHAR2,
                            p_num_failed_dist_rows IN OUT NOCOPY NUMBER,
                            p_errorbuf IN OUT NOCOPY VARCHAR2,
                            p_msg_level IN NUMBER  )
  RETURN NUMBER IS

    l_temp                      BINARY_INTEGER;

BEGIN

    g_errorbuf := NULL;

    --------------------------------------------------------------------------
    -- Set message level for debugging
    --------------------------------------------------------------------------
    system_info.msg_level := p_msg_level;
    arp_global.msg_level := p_msg_level;

    print_fcn_label( 'arp_auto_accounting.do_autoaccounting_cover()+ ' );

    --------------------------------------------------------------------------
    -- Initialize
    --------------------------------------------------------------------------
    p_errorbuf := NULL;

    do_autoaccounting( p_mode,
                       p_account_class,
                       p_customer_trx_id,
                       p_customer_trx_line_id,
                       p_cust_trx_line_salesrep_id,
                       p_request_id,
                       p_gl_date,
                       p_original_gl_date,
                       p_total_trx_amount,
                       p_passed_ccid,
                       p_force_account_set_no,
                       p_cust_trx_type_id,
                       p_primary_salesrep_id,
                       p_inventory_item_id,
                       p_memo_line_id,
                       p_ccid,
                       p_concat_segments,
                       p_num_failed_dist_rows );


    print_fcn_label( 'arp_auto_accounting.do_autoaccounting_cover()- ' );

    IF (( p_mode = G AND p_ccid = -1 )
        OR
        ( p_request_id IS NOT NULL AND p_num_failed_dist_rows > 0)) THEN

	RETURN 0;	-- no ccid was created

    END IF;

    RETURN 1;


EXCEPTION
    WHEN no_ccid THEN
	RETURN 0;	-- could not get valid ccid, failure

    WHEN NO_DATA_FOUND THEN
  	RETURN 1;  	-- treat this as success

    WHEN OTHERS THEN
	g_errorbuf := g_error_buffer;
        debug(SQLERRM, MSG_LEVEL_BASIC);
        RAISE;
END do_autoaccounting;


----------------------------------------------------------------------------
PROCEDURE do_autoaccounting_internal(
			    p_mode 			IN VARCHAR2,
                            p_account_class 		IN VARCHAR2,
                            p_customer_trx_id 		IN NUMBER,
                            p_customer_trx_line_id 	IN NUMBER,
                            p_cust_trx_line_salesrep_id IN NUMBER,
                            p_request_id 		IN NUMBER,
                            p_gl_date 			IN DATE,
                            p_original_gl_date 		IN DATE,
                            p_total_trx_amount 		IN NUMBER,
                            p_passed_ccid 		IN NUMBER,
                            p_force_account_set_no 	IN VARCHAR2,
                            p_cust_trx_type_id 		IN NUMBER,
                            p_primary_salesrep_id 	IN NUMBER,
                            p_inventory_item_id 	IN NUMBER,
                            p_memo_line_id 		IN NUMBER,
                            p_site_use_id               IN NUMBER,
                            p_warehouse_id              IN NUMBER,
                            p_ccid 			IN OUT NOCOPY NUMBER,
                            p_concat_segments 		IN OUT NOCOPY VARCHAR2,
                            p_failure_count	 	IN OUT NOCOPY NUMBER )
IS


    l_select_rec select_rec_type;
    l_select_tab select_rec_tab;
    l_null_rec   CONSTANT select_rec_type := l_select_rec;

    -- Cursors
    --
    l_select_c INTEGER;
    l_delete_c INTEGER;

    --
    -- Running totals
    --
    l_total_percent 		NUMBER := 0;
    l_total_amount 		NUMBER := 0;
    l_total_acctd_amount 	NUMBER := 0;

    l_rows_fetched 	           NUMBER := 0;

    l_ignore   			INTEGER;
    l_boolean  			BOOLEAN;
    l_first_fetch		BOOLEAN;
    l_temp                      BINARY_INTEGER;
    l_keep_cursor_open_flag     BOOLEAN := FALSE;

    l_low                       INTEGER:=0;
    l_high                      INTEGER:=0;

    gl_dist_array               dbms_sql.number_table;    /* MRC */
    l_error_count               NUMBER := 0;
    l_use_unearn_srep_dependency BOOLEAN := FALSE;

    /*9112739*/
    l_collect                ar_revenue_management_pvt.long_number_table;
    cursor c_trx_lines(p_customer_trx_id in number) IS
    select customer_trx_line_id from ra_customer_trx_lines
    where customer_trx_id = p_customer_trx_id
    and line_type = 'LINE';

BEGIN

    print_fcn_label( 'arp_auto_accounting.do_autoaccounting_internal()+' );
   --begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
   init;
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
    --end anuj


    SAVEPOINT ar_auto_accounting;

    --------------------------------------------------------------------------
    -- Process modes
    --------------------------------------------------------------------------
    IF( p_mode = G ) THEN
        --
        -- Get mode, populate record immediately
        --
        l_select_rec := l_null_rec;     -- start with null record

        l_select_rec.customer_trx_line_id := p_customer_trx_line_id;
        l_select_rec.account_class := p_account_class;
        l_select_rec.cust_trx_type_id := p_cust_trx_type_id;
        l_select_rec.salesrep_id := p_primary_salesrep_id;
        l_select_rec.inventory_item_id := p_inventory_item_id;
        l_select_rec.memo_line_id := p_memo_line_id;
        l_select_rec.site_use_id := p_site_use_id;
        l_select_rec.warehouse_id := p_warehouse_id;

	dump_select_rec( l_select_rec );

        --------------------------------------------------------------------
        -- Default gl date if in closed period
        -- Correct rounding errors
        -- Call Flex mgr
        --------------------------------------------------------------------

        process_line( system_info,
                      l_select_rec,
                      l_total_percent,
                      l_total_amount,
                      l_total_acctd_amount,
                      p_failure_count,
                      p_mode,
                      p_request_id );

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
                                               p_customer_trx_id,
                                               p_customer_trx_line_id,
                                               p_cust_trx_line_salesrep_id,
                                               p_request_id );

              l_delete_stmt := l_delete_stmt ||
                 ' RETURNING cust_trx_line_gl_dist_id INTO :gl_dist_key_value ';

              dbms_sql.parse( l_delete_c, l_delete_stmt, dbms_sql.v7 );

             /*-----------------------+
              | bind output variable  |
              +-----------------------*/
              dbms_sql.bind_array(l_delete_c,':gl_dist_key_value',
                                  gl_dist_array);


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

                IF ( l_ignore > 0) THEN
                   /*------------------------------------------+
                    | get RETURNING COLUMN into OUT NOCOPY bind array |
                    +------------------------------------------*/

                    dbms_sql.variable_value( l_delete_c, ':gl_dist_key_value',
                                 gl_dist_array);

                    IF PG_DEBUG in ('Y', 'C') THEN
                       arp_standard.debug('do_autoaccounting: ' || 'before loop for MRC processing...');
                    END IF;
                    FOR I in gl_dist_array.FIRST .. gl_dist_array.LAST LOOP
                   /*---------------------------------------------------------+
                    | call mrc engine to delete from ra_cust_trx_line_gl_dist |
                    +---------------------------------------------------------*/
                    IF PG_DEBUG in ('Y', 'C') THEN
                       arp_standard.debug('do_autoaccounting: ' || 'before calling maintain_mrc ');
                       arp_standard.debug('do_autoaccounting: ' || 'gl dist array('||to_char(I) || ') = ' ||
                                        to_char(gl_dist_array(I)));
                    END IF;

                    ar_mrc_engine.maintain_mrc_data(
                        p_event_mode       => 'DELETE',
                        p_table_name       => 'RA_CUST_TRX_LINE_GL_DIST',
                        p_mode             => 'SINGLE',
                        p_key_value        => gl_dist_array(I));
                  END LOOP;
                END IF;

                close_cursor( l_delete_c );

            EXCEPTION
                WHEN OTHERS THEN
                    debug( 'Error executing delete stmt', MSG_LEVEL_BASIC );
                    debug(SQLERRM, MSG_LEVEL_BASIC);
                    RAISE;

            END;


        END IF;  -- if mode = U, D

        IF( p_mode in (I, U) ) THEN

            /* Bug 2560036 - Call collectibility when in INSERT mode
               only. */

            /*9112739 Added for run in update mode*/

            IF (p_mode IN ( 'I' ,'U') AND
                p_account_class in ('REV','ALL') AND
                g_test_collectibility AND
                NOT g_called_collectibility) THEN

              IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('  testing collectibility...');
              END IF;

              -- the following logic was enhanced to distinguish the
              -- call to revenue management from invoice api and others.
              -- if it is being called from invoice api then we would
              -- like to call by passing the source and not skip
              -- it if it was called before.
              --
              -- ORASHID 22-Sep-2004

              IF (g_called_from = 'AR_INVOICE_API') THEN
                t_collect := ar_revenue_management_pvt.line_collectibility(
                  p_request_id => p_request_id,
                  p_source     => g_called_from,
                  x_error_count=> l_error_count);
             /* Bug 4693399 - manually entered transactions can also be deferred
	        by contingencies */
              ELSIF (p_request_id IS NULL and p_customer_trx_line_id IS NOT NULL) THEN
                  t_collect := ar_revenue_management_pvt.line_collectibility(
                   p_request_id => p_request_id,
                   x_error_count=> l_error_count,
                   p_customer_trx_line_id=> p_customer_trx_line_id);

		   /*9112739*/
                   IF (p_mode in ( 'U') AND
                   t_collect.EXISTS(p_customer_trx_line_id))
                   THEN
                          IF (t_collect(p_customer_trx_line_id) =
                            ar_revenue_management_pvt.defer) THEN
                                 l_use_unearn_srep_dependency := TRUE;
                          END IF;
                   END IF;


              ELSIF (p_request_id is NULL and p_customer_trx_id IS NOT NULL and p_customer_trx_line_id IS NULL) THEN
                /* 9112739 Added for trx level run for each line*/
                FOR i in c_trx_lines (p_customer_trx_id)
                LOOP
                   l_collect := ar_revenue_management_pvt.line_collectibility(
                   p_request_id => p_request_id,
                   x_error_count=> l_error_count,
                   p_customer_trx_line_id=> i.customer_trx_line_id);
		   t_collect(i.customer_trx_line_id) := l_collect(i.customer_trx_line_id);

                   IF (p_mode in ( 'U') AND
                   t_collect.EXISTS(i.customer_trx_line_id))
                   THEN
                          IF (t_collect(i.customer_trx_line_id) =
                            ar_revenue_management_pvt.defer) THEN
                                 l_use_unearn_srep_dependency := TRUE;
                          END IF;
                   END IF;
                END LOOP;
              ELSE
                IF (NOT g_called_collectibility) THEN
                  g_called_collectibility := TRUE;
                  t_collect := ar_revenue_management_pvt.line_collectibility(
                   p_request_id => p_request_id,
                   x_error_count=> l_error_count);
                END IF;

              END IF;

              /* Bug 3879222 - Increase p_failure_count when
                 collectibility rejects contingency rows in autoinv */
              IF (l_error_count > 0)
              THEN

                 IF PG_DEBUG in ('Y','C')
                 THEN
                   arp_util.debug('failed contingencies = ' || l_error_count);
                 END IF;

                 p_failure_count := nvl(p_failure_count,0) +
                                    nvl(l_error_count,0);
              END IF;

            ELSE

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug('do_autoaccounting: ' || '  collectibility bypassed...');
                END IF;

            END IF;

            /* End bug 2560036 */

    	    --
    	    -- Insert distributions in Insert and Update mode
	    --

            --
            -- Fetch records using select stmt
            --
            -- Bug 853040
/*Bug 2034221:Added 'Freight' also in the clause to prevent the NULL value
              passed for ccid.
*/
            IF p_passed_ccid IS NOT NULL AND
               p_account_class in('REC','FREIGHT') THEN
                   p_ccid := p_passed_ccid;
            END IF;
            IF arp_auto_accounting.g_deposit_flag = 'Y' and
               p_account_class = 'REV' THEN
               p_ccid := p_passed_ccid;
            END IF;


            l_select_c := Get_Select_Cursor(
                                             system_info,
                                             profile_info,
                                             p_account_class,
                                             p_customer_trx_id,
                                             p_customer_trx_line_id,
                                             p_cust_trx_line_salesrep_id,
                                             p_request_id,
                                             p_gl_date,
                                             p_original_gl_date,
                                             p_total_trx_amount,
                                             p_ccid,
                                             p_force_account_set_no,
                                             p_cust_trx_type_id,
                                             p_primary_salesrep_id,
                                             p_inventory_item_id,
                                             p_memo_line_id,
					     l_use_unearn_srep_dependency,
                                             l_keep_cursor_open_flag);


             Bind_All_Variables(
                                 l_select_c,
                                 system_info,
                                 profile_info,
                                 p_account_class,
                                 p_customer_trx_id,
                                 p_customer_trx_line_id,
                                 p_cust_trx_line_salesrep_id,
                                 p_request_id,
                                 p_gl_date,
                                 p_original_gl_date,
                                 p_total_trx_amount,
                                 p_passed_ccid,
                                 p_force_account_set_no,
                                 p_cust_trx_type_id,
                                 p_primary_salesrep_id,
                                 p_inventory_item_id,
                                 p_memo_line_id,
                                 l_keep_cursor_open_flag);



 	     -- Initialize totals
         l_total_percent := 0;
         l_total_amount := 0;
         l_total_acctd_amount := 0;

         l_first_fetch := TRUE;

         ----------------------------------------------------------------
         -- Execute select stmt
         ----------------------------------------------------------------
         BEGIN

            debug( '  Executing select stmt', MSG_LEVEL_DEBUG );
            --
            -- Execute
            --
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

         LOOP  -- Main Cursor Loop

            BEGIN
               --
               -- Each call to the fetch_rows will fetch MAX_ARRAY_SIZE rows of data
               -- If no. of rows are < MAX_ARRAY_SIZE then exit loop after processing.
               --

               l_rows_fetched := dbms_sql.fetch_rows( l_select_c );

	       l_low := l_high + 1;
	       l_high:= l_high + l_rows_fetched;


               IF l_rows_fetched > 0 THEN

    		  debug( '  Fetched a row :('|| l_rows_fetched || ')', MSG_LEVEL_DEBUG );
                  debug( '  l_low  : '|| l_low , MSG_LEVEL_DEBUG );
                  debug( '  l_high : '|| l_high , MSG_LEVEL_DEBUG );


       		  l_first_fetch := FALSE;

                  l_select_rec := l_null_rec;


                  get_column_values( l_select_c, l_select_tab );

/* bug 1532372 - changed parameter from l_rows_fetched to l_low and l_high
                 this apparently corrects the 1000 REC row limit that
                 we encountered during benchmarking.  */

                  dump_select_tab( l_select_tab, l_low, l_high );

                  IF l_rows_fetched < MAX_ARRAY_SIZE THEN
                     --
                     -- no more rows to fetch
                     --
                     debug( '  Done fetching(if)', MSG_LEVEL_DEBUG );

                     IF ( l_keep_cursor_open_flag = FALSE )THEN
                        close_cursor( l_select_c );
                     END IF;

                  END IF;
               ELSE
                  --
                  -- no more rows to fetch
                  --
                  debug( '  Done fetching(else)', MSG_LEVEL_DEBUG );

                  IF ( l_keep_cursor_open_flag = FALSE )THEN
                     close_cursor( l_select_c );
                  END IF;

       		      -- No rows selected

  		          IF (l_first_fetch) THEN

    			     debug( '  raising NO_DATA_FOUND', MSG_LEVEL_DEBUG );
			         RAISE NO_DATA_FOUND;

   			      END IF;

                  EXIT;  -- Exit out NOCOPY of loop

               END IF; -- Rows Fetched

            EXCEPTION
	           WHEN NO_DATA_FOUND THEN
         	      RAISE;
               WHEN OTHERS THEN
                  debug( 'Error fetching select cursor', MSG_LEVEL_BASIC );
                  debug(SQLERRM, MSG_LEVEL_BASIC);
                  RAISE;
            END;


            -----------------------------------------------------------
            -- Default gl date if in closed period
            -- Correct rounding errors
            -- Call Flex mgr
            -----------------------------------------------------------
            FOR i IN l_low..l_high LOOP

               l_select_rec := get_select_rec (l_select_tab, i);

               process_line( system_info,
                             l_select_rec,
                             l_total_percent,
                             l_total_amount,
                             l_total_acctd_amount,
                             p_failure_count,
                             p_mode,
                             p_request_id );

               -- copy out NOCOPY parameters back to array

               l_select_tab.int_concatenated_segments(i) := l_select_rec.int_concatenated_segments;
               l_select_tab.int_code_combination_id(i)   := l_select_rec.int_code_combination_id;
               l_select_tab.code_combination_id(i)   := l_select_rec.code_combination_id;
               l_select_tab.concatenated_segments(i)   := l_select_rec.concatenated_segments;

            /* Bug 2560036 - Move account class back in case
               we overrode it inside process_line */
            l_select_tab.account_class(i) := l_select_rec.account_class;

            END LOOP;

            -----------------------------------------------------------
            -- Insert row
            -----------------------------------------------------------
            BEGIN
               insert_dist_row( system_info,
                                profile_info,
                                p_request_id,
                                l_select_tab,
                                l_low,
				l_high);
            EXCEPTION
               WHEN OTHERS THEN
                  debug( 'Error inserting distributions', MSG_LEVEL_BASIC );
                  debug(SQLERRM, MSG_LEVEL_BASIC);
                  RAISE;
            END;


            -----------------------------------------------------------
            -- Insert into error table if called from autoinvoice
  		    -- and didn't get ccid
            -----------------------------------------------------------
            FOR i IN l_low..l_high LOOP

               l_select_rec := get_select_rec (l_select_tab, i);

               -- Get CCID's from tables as get_select_rec will not copy these

               l_select_rec.int_concatenated_segments := l_select_tab.int_concatenated_segments(i);
               l_select_rec.int_code_combination_id := l_select_tab.int_code_combination_id(i);
               l_select_rec.code_combination_id := l_select_tab.code_combination_id(i);
               l_select_rec.concatenated_segments := l_select_tab.concatenated_segments(i);


  		       IF ( l_select_rec.code_combination_id = -1 ) THEN

                  IF ( p_account_class = REV ) THEN

   			         put_message_on_stack(l_select_rec.customer_trx_line_id,
                         				  MSG_COMPLETE_REV_ACCOUNT,
                        				  l_select_rec.concatenated_segments,
                                          p_request_id );

   		          ELSIF( p_account_class = REC ) THEN

                     -- Put -ve customer trx id in the errors table if
    			     -- AutoAccounting is unable to derive the REC account.
       			     -- Validation Report will report this error for the first
			         -- line of the Trx

       			     put_message_on_stack(-1 * l_select_rec.customer_trx_id,
				                           MSG_COMPLETE_REC_ACCOUNT,
				                           l_select_rec.concatenated_segments,
                                           p_request_id );

	              ELSIF( p_account_class = FREIGHT ) THEN

		             put_message_on_stack(
				                           l_select_rec.customer_trx_line_id,
				                           MSG_COMPLETE_FRT_ACCOUNT,
				                           l_select_rec.concatenated_segments,
                                           p_request_id );

	              ELSIF( p_account_class = TAX ) THEN
/* 1651593 - Point errors to parent line if one is available */
          		     put_message_on_stack(
                                   NVL(l_select_rec.link_to_cust_trx_line_id,
    			               l_select_rec.customer_trx_line_id),
                            			   MSG_COMPLETE_TAX_ACCOUNT,
                        	       l_select_rec.concatenated_segments,
                                           p_request_id );

   		          ELSIF( p_account_class = CHARGES ) THEN

       		         put_message_on_stack(
				                           l_select_rec.customer_trx_line_id,
                        				   MSG_COMPLETE_CHARGES_ACCOUNT,
                        				   l_select_rec.concatenated_segments,
                                           p_request_id );

      		      ELSIF( p_account_class in (UNBILL, UNEARN, SUSPENSE)) THEN

       		         put_message_on_stack(
                        				   l_select_rec.customer_trx_line_id,
                        				   MSG_COMPLETE_OFFSET_ACCOUNT,
                        				   l_select_rec.concatenated_segments,
                                           p_request_id );

   		          END IF;

   		       END IF;

               IF (p_account_class = 'TAX') THEN

                  --Invalid interim tax account
                  IF l_select_rec.int_code_combination_id = -1 THEN
                  /* 1651593 - Point tax lines to parent line for error */
                     put_message_on_stack(
                                     NVL(l_select_rec.link_to_cust_trx_line_id,
                                          l_select_rec.customer_trx_line_id),
                                          MSG_COMPLETE_INT_TAX_ACCOUNT,
                                          l_select_rec.int_concatenated_segments,
                                          p_request_id );

                  END IF;

               END IF;

            END LOOP; -- For all records in an array

            EXIT WHEN l_rows_fetched < MAX_ARRAY_SIZE; -- Exit from the loop if no. of rows fetched < array size

         END LOOP;

      END IF;  -- IF( p_mode in (I, U) )

   END IF;  -- IF( p_mode = G )


   -- Check if failed to get any ccids
   --
   debug( '  p_failure_count='||to_char(p_failure_count), MSG_LEVEL_DEBUG);

   IF ( l_keep_cursor_open_flag = FALSE ) THEN
      close_cursor( l_select_c );
   END IF;

   close_cursor( l_delete_c );


   print_fcn_label( 'arp_auto_accounting.do_autoaccounting_internal()-' );


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
        debug( 'EXCEPTION: arp_auto_accounting.do_autoaccounting_internal()',
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
--   Server-side entry point for autoaccounting.
--
-- ARGUMENTS:
--      IN:
--        mode:  May be I(nsert), U(pdate), D(elete), or (G)et
--        account_class:  REC, REV, FREIGHT, TAX, UNBILL, UNEARN, SUSPENSE,
--                        CHARGES
--        customer_trx_id:  NULL if not applicable
--        customer_trx_line_id:  NULL if not applicable (G)
--        cust_trx_line_salesrep_id:  NULL if not applicable
--        request_id:  NULL if not applicable
--        gl_date:  GL date of the account assignment
--        original_gl_date:  Original GL date
--        total_trx_amount:  For Receivable account only
--        passed_ccid:  Code comination ID to use if supplied
--        force_account_set_no:
--        cust_trx_type_id (G)
--        primary_salesrep_id (G)
--        inventory_item_id (G)
--        memo_line_id (G)
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
--   arp_auto_accounting.no_ccid if autoaccounting could not derive a
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
PROCEDURE do_autoaccounting( p_mode 			IN VARCHAR2,
                            p_account_class 		IN VARCHAR2,
                            p_customer_trx_id 		IN NUMBER,
                            p_customer_trx_line_id 	IN NUMBER,
                            p_cust_trx_line_salesrep_id IN NUMBER,
                            p_request_id 		IN NUMBER,
                            p_gl_date 			IN DATE,
                            p_original_gl_date 		IN DATE,
                            p_total_trx_amount 		IN NUMBER,
                            p_passed_ccid 		IN NUMBER,
                            p_force_account_set_no 	IN VARCHAR2,
                            p_cust_trx_type_id 		IN NUMBER,
                            p_primary_salesrep_id 	IN NUMBER,
                            p_inventory_item_id 	IN NUMBER,
                            p_memo_line_id 		IN NUMBER,
                            p_ccid 			IN OUT NOCOPY NUMBER,
                            p_concat_segments 		IN OUT NOCOPY VARCHAR2,
                            p_failure_count	 	IN OUT NOCOPY NUMBER )
IS


    l_select_rec select_rec_type;
    l_null_rec   CONSTANT select_rec_type := l_select_rec;

    l_ignore   			INTEGER;
    l_boolean  			BOOLEAN;
    l_temp                      BINARY_INTEGER;
    l_account_class             VARCHAR2(20);

BEGIN

    print_fcn_label( 'arp_auto_accounting.do_autoaccounting()+' );

/*
ar_transaction_pub.debug('arp_auto_accounting.do_autoaccounting()+',
      FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR);
*/
    g_error_buffer := NULL;

    --
    -- Set message level for debugging
    --
    system_info.msg_level := arp_global.msg_level;

    debug( '  mode='||p_mode, MSG_LEVEL_DEBUG );
    debug( '  account_class='||p_account_class, MSG_LEVEL_DEBUG );
    debug( '  customer_trx_id='||to_char(p_customer_trx_id), MSG_LEVEL_DEBUG );
    debug( '  customer_trx_line_id='||to_char(p_customer_trx_line_id),
           MSG_LEVEL_DEBUG );
    debug( '  cust_trx_line_salesrep_id='||
	   to_char(p_cust_trx_line_salesrep_id),
           MSG_LEVEL_DEBUG );
    debug( '  request_id='||to_char(p_request_id), MSG_LEVEL_DEBUG );
    debug( '  gl_date='||to_char(p_gl_date,'MM/DD/YYYY'), MSG_LEVEL_DEBUG );
    debug( '  original_gl_date='||to_char(p_original_gl_date,'MM/DD/YYYY'), MSG_LEVEL_DEBUG );
    debug( '  total_trx_amount='||to_char(p_total_trx_amount),
		MSG_LEVEL_DEBUG );
    debug( '  passed_ccid='||to_char(p_passed_ccid), MSG_LEVEL_DEBUG );
    debug( '  force_account_set_no='||p_force_account_set_no,
		MSG_LEVEL_DEBUG );
    debug( '  cust_trx_type_id='||to_char(p_cust_trx_type_id),
		MSG_LEVEL_DEBUG );
    debug( '  primary_salesrep_id='||to_char(p_primary_salesrep_id),
       MSG_LEVEL_DEBUG );
    debug( '  inventory_item_id='||to_char(p_inventory_item_id),
		MSG_LEVEL_DEBUG );
    debug( '  memo_line_id='||to_char(p_memo_line_id), MSG_LEVEL_DEBUG );
    debug( '  msg_level='||to_char(system_info.msg_level), MSG_LEVEL_DEBUG );

    --
    -- Initialize
    --
    -- p_failure_count := 0;

    --
    -- Adjust account_class to proper string
    --
    l_account_class := p_account_class;
    expand_account_class( l_account_class );

    IF( l_account_class = 'ALL' ) THEN

        DECLARE
            l_no_rows_rev 		BOOLEAN := FALSE;
            l_no_rows_rec 		BOOLEAN := FALSE;
            l_no_rows_freight 		BOOLEAN := FALSE;
            l_no_rows_tax 		BOOLEAN := FALSE;
            l_no_rows_unbill 		BOOLEAN := FALSE;
            l_no_rows_unearn 		BOOLEAN := FALSE;
	    l_no_rows_suspense		BOOLEAN := FALSE;
            l_no_rows_charges		BOOLEAN := FALSE;
            l_invoicing_rule_id         ra_customer_trx.invoicing_rule_id%type;
            l_create_clearing_flag  ra_batch_sources.create_clearing_flag%type;
            l_line_type                 ra_customer_trx_lines.line_type%type;
        BEGIN

            debug( '  Processing ALL mode...', MSG_LEVEL_DEBUG );

            IF ( p_customer_trx_id IS NOT NULL)
            THEN
                  SELECT invoicing_rule_id,
                         create_clearing_flag
                  INTO   l_invoicing_rule_id,
                         l_create_clearing_flag
                  FROM   ra_customer_trx  t,
                         ra_batch_sources b
                  WHERE  customer_trx_id =  p_customer_trx_id
                  AND    t.batch_source_id = b.batch_source_id;
            END IF;

            IF ( p_customer_trx_line_id IS NOT NULL )
            THEN
                 SELECT line_type
                 INTO   l_line_type
                 FROM   ra_customer_trx_lines
                 WHERE  customer_trx_line_id =  p_customer_trx_line_id;
            END IF;

	    BEGIN
	        do_autoaccounting_internal(
			p_mode,
                        REC,
                        p_customer_trx_id,
                        p_customer_trx_line_id,
                        p_cust_trx_line_salesrep_id,
                        p_request_id,
                        p_gl_date,
                        p_original_gl_date,
                        p_total_trx_amount,
                        p_passed_ccid,
                        p_force_account_set_no,
                        p_cust_trx_type_id,
                        p_primary_salesrep_id,
                        p_inventory_item_id,
                        p_memo_line_id,
                        '','',
                        p_ccid,
                        p_concat_segments,
                        p_failure_count );
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		    l_no_rows_rec := TRUE;
		WHEN OTHERS THEN
		    RAISE;
	    END;

            BEGIN
		do_autoaccounting_internal(
			p_mode,
                        REV,
                        p_customer_trx_id,
                        p_customer_trx_line_id,
                        p_cust_trx_line_salesrep_id,
                        p_request_id,
                        p_gl_date,
                        p_original_gl_date,
                        p_total_trx_amount,
                        p_passed_ccid,
                        p_force_account_set_no,
                        p_cust_trx_type_id,
                        p_primary_salesrep_id,
                        p_inventory_item_id,
                        p_memo_line_id,
                        '','',
                        p_ccid,
                        p_concat_segments,
                        p_failure_count );
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		    l_no_rows_rev := TRUE;
		WHEN OTHERS THEN
		    RAISE;
	    END;

            IF ( NVL(l_line_type, 'CHARGES') = 'CHARGES')
            THEN
                 BEGIN
                     do_autoaccounting_internal(
                             p_mode,
                             CHARGES,
                             p_customer_trx_id,
                             p_customer_trx_line_id,
                             p_cust_trx_line_salesrep_id,
                             p_request_id,
                             p_gl_date,
                             p_original_gl_date,
                             p_total_trx_amount,
                             p_passed_ccid,
                             p_force_account_set_no,
                             p_cust_trx_type_id,
                             p_primary_salesrep_id,
                             p_inventory_item_id,
                             p_memo_line_id,
                             '','',
                             p_ccid,
                             p_concat_segments,
                             p_failure_count );
                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                         l_no_rows_charges := TRUE;
                     WHEN OTHERS THEN
                         RAISE;
                 END;
            END IF;

	    BEGIN
		do_autoaccounting_internal(
			p_mode,
                        TAX,
                        p_customer_trx_id,
                        p_customer_trx_line_id,
                        p_cust_trx_line_salesrep_id,
                        p_request_id,
                        p_gl_date,
                        p_original_gl_date,
                        p_total_trx_amount,
                        p_passed_ccid,
                        p_force_account_set_no,
                        p_cust_trx_type_id,
                        p_primary_salesrep_id,
                        p_inventory_item_id,
                        p_memo_line_id,
                        '','',
                        p_ccid,
                        p_concat_segments,
                        p_failure_count );
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		    l_no_rows_tax := TRUE;
		WHEN OTHERS THEN
		    RAISE;
	    END;

	    BEGIN
                do_autoaccounting_internal(
			p_mode,
                        FREIGHT,
                        p_customer_trx_id,
                        p_customer_trx_line_id,
                        p_cust_trx_line_salesrep_id,
                        p_request_id,
                        p_gl_date,
                        p_original_gl_date,
                        p_total_trx_amount,
                        p_passed_ccid,
                        p_force_account_set_no,
                        p_cust_trx_type_id,
                        p_primary_salesrep_id,
                        p_inventory_item_id,
                        p_memo_line_id,
                        '','',
                        p_ccid,
                        p_concat_segments,
                        p_failure_count );
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		    l_no_rows_freight := TRUE;
		WHEN OTHERS THEN
		    RAISE;
	    END;

            IF (  NVL(l_create_clearing_flag, 'Y') = 'Y' )
            THEN

                 BEGIN
                     do_autoaccounting_internal(
                             p_mode,
                             SUSPENSE,
                             p_customer_trx_id,
                             p_customer_trx_line_id,
                             p_cust_trx_line_salesrep_id,
                             p_request_id,
                             p_gl_date,
                             p_original_gl_date,
                             p_total_trx_amount,
                             p_passed_ccid,
                             p_force_account_set_no,
                             p_cust_trx_type_id,
                             p_primary_salesrep_id,
                             p_inventory_item_id,
                             p_memo_line_id,
                             '','',
                             p_ccid,
                             p_concat_segments,
                             p_failure_count );
                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                         l_no_rows_suspense := TRUE;
                     WHEN OTHERS THEN
                         RAISE;
                 END;

            END IF;

            BEGIN
                do_autoaccounting_internal(
                             p_mode,
                             UNBILL,
                             p_customer_trx_id,
                             p_customer_trx_line_id,
                             p_cust_trx_line_salesrep_id,
                             p_request_id,
                             p_gl_date,
                             p_original_gl_date,
                             p_total_trx_amount,
                             p_passed_ccid,
                             p_force_account_set_no,
                             p_cust_trx_type_id,
                             p_primary_salesrep_id,
                             p_inventory_item_id,
                             p_memo_line_id,
                             '','',
                             p_ccid,
                             p_concat_segments,
                             p_failure_count );
            EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                         l_no_rows_unbill := TRUE;
                     WHEN OTHERS THEN
                         RAISE;
            END;

            BEGIN
                do_autoaccounting_internal(
                             p_mode,
                             UNEARN,
                             p_customer_trx_id,
                             p_customer_trx_line_id,
                             p_cust_trx_line_salesrep_id,
                             p_request_id,
                             p_gl_date,
                             p_original_gl_date,
                             p_total_trx_amount,
                             p_passed_ccid,
                             p_force_account_set_no,
                             p_cust_trx_type_id,
                             p_primary_salesrep_id,
                             p_inventory_item_id,
                             p_memo_line_id,
                             '','',
                             p_ccid,
                             p_concat_segments,
                             p_failure_count );
            EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                         l_no_rows_unearn := TRUE;
                     WHEN OTHERS THEN
                         RAISE;
            END;

            IF ( l_no_rows_rev
		 AND l_no_rows_rec
		 AND l_no_rows_freight
		 AND l_no_rows_tax
		 AND l_no_rows_unbill
		 AND l_no_rows_unearn
		 AND l_no_rows_suspense
		 AND l_no_rows_charges ) THEN

		debug( '  raising NO_DATA_FOUND', MSG_LEVEL_DEBUG );
	        RAISE NO_DATA_FOUND;

            END IF;

        EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		RAISE;
            WHEN OTHERS THEN
                debug( 'Error processing ALL account class',
                           MSG_LEVEL_BASIC );
                RAISE;
        END;


    ELSE	-- not ALL mode

        do_autoaccounting_internal(
			p_mode,
                        l_account_class,
                        p_customer_trx_id,
                        p_customer_trx_line_id,
                        p_cust_trx_line_salesrep_id,
                        p_request_id,
                        p_gl_date,
                        p_original_gl_date,
                        p_total_trx_amount,
                        p_passed_ccid,
                        p_force_account_set_no,
                        p_cust_trx_type_id,
                        p_primary_salesrep_id,
                        p_inventory_item_id,
                        p_memo_line_id,
                        '','',
                        p_ccid,
                        p_concat_segments,
                        p_failure_count );


    END IF;  -- ALL mode


    -- Check if failed to get any ccids
    --
    debug( '  p_failure_count='||to_char(p_failure_count) ,
		MSG_LEVEL_DEBUG);

    IF( p_failure_count > 0 ) THEN

	debug( '  raising no_ccid', MSG_LEVEL_DEBUG );
        RAISE no_ccid;

    END IF;

/*ar_transaction_pub.debug('arp_auto_accounting.do_autoaccounting()-',
      FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR);
*/
    print_fcn_label( 'arp_auto_accounting.do_autoaccounting()-' );


EXCEPTION
    WHEN no_ccid OR NO_DATA_FOUND THEN

	IF( p_mode = G OR
	    p_request_id IS NOT NULL ) THEN

	    NULL;	-- Don't raise for Get mode or Autoinvoice,
			-- otherwise the IN/OUT variables
			-- ccid, concat_segments and failure_count
			-- do not get populated.
	ELSE
	    RAISE;
	END IF;

    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_auto_accounting.do_autoaccounting()',
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
--
-- PROCEDURE NAME:  do_autoaccounting
--
-- DECSRIPTION:
--   Overloaded procedure when autoaccounting is called in G or Get mode
--   as warehouse id is required to be passed in and bill_to_site_use_id
--   is implicitly derived.
--
-- ARGUMENTS:
--      IN:
--        mode:  May be (G)et only as the routine is written for the same
--        account_class:  REC, REV, FREIGHT, TAX, UNBILL, UNEARN, SUSPENSE,
--                        CHARGES
--        customer_trx_id:  NULL if not applicable
--        customer_trx_line_id:  NULL if not applicable (G)
--        cust_trx_line_salesrep_id:  NULL if not applicable
--        request_id:  NULL if not applicable
--        gl_date:  GL date of the account assignment
--        original_gl_date:  Original GL date
--        total_trx_amount:  For Receivable account only
--        passed_ccid:  Code comination ID to use if supplied
--        force_account_set_no:
--        cust_trx_type_id (G)
--        primary_salesrep_id (G)
--        inventory_item_id (G)
--        memo_line_id (G)
--        warehouse_id (G)
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
--   arp_auto_accounting.no_ccid if autoaccounting could not derive a
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
--   Never call this routine for ALL classes as this was specifically
--   written to work in Get mode, but will also work in other modes
--   provided the account class is not ALL
-- HISTORY:
--
--
PROCEDURE do_autoaccounting( p_mode 			IN VARCHAR2,
                            p_account_class 		IN VARCHAR2,
                            p_customer_trx_id 		IN NUMBER,
                            p_customer_trx_line_id 	IN NUMBER,
                            p_cust_trx_line_salesrep_id IN NUMBER,
                            p_request_id 		IN NUMBER,
                            p_gl_date 			IN DATE,
                            p_original_gl_date 		IN DATE,
                            p_total_trx_amount 		IN NUMBER,
                            p_passed_ccid 		IN NUMBER,
                            p_force_account_set_no 	IN VARCHAR2,
                            p_cust_trx_type_id 		IN NUMBER,
                            p_primary_salesrep_id 	IN NUMBER,
                            p_inventory_item_id 	IN NUMBER,
                            p_memo_line_id 		IN NUMBER,
                            p_warehouse_id              IN NUMBER,
                            p_ccid 			IN OUT NOCOPY NUMBER,
                            p_concat_segments 		IN OUT NOCOPY VARCHAR2,
                            p_failure_count	 	IN OUT NOCOPY NUMBER )
IS

    l_account_class             VARCHAR2(20);
    l_bill_to_site_use_id       NUMBER;

BEGIN

    print_fcn_label( 'arp_auto_accounting.do_autoaccounting overloaded get mode()+' );

    g_error_buffer := NULL;

    l_bill_to_site_use_id := '';

    --
    -- Set message level for debugging
    --
    system_info.msg_level := arp_global.msg_level;

    debug( '  mode='||p_mode, MSG_LEVEL_DEBUG );
    debug( '  account_class='||p_account_class, MSG_LEVEL_DEBUG );
    debug( '  customer_trx_id='||to_char(p_customer_trx_id), MSG_LEVEL_DEBUG );
    debug( '  customer_trx_line_id='||to_char(p_customer_trx_line_id),
           MSG_LEVEL_DEBUG );
    debug( '  cust_trx_line_salesrep_id='||
	   to_char(p_cust_trx_line_salesrep_id),
           MSG_LEVEL_DEBUG );
    debug( '  request_id='||to_char(p_request_id), MSG_LEVEL_DEBUG );
    debug( '  gl_date='||to_char(p_gl_date,'MM/DD/YYYY'), MSG_LEVEL_DEBUG );
    debug( '  original_gl_date='||to_char(p_original_gl_date,'MM/DD/YYYY'), MSG_LEVEL_DEBUG );
    debug( '  total_trx_amount='||to_char(p_total_trx_amount),
		MSG_LEVEL_DEBUG );
    debug( '  passed_ccid='||to_char(p_passed_ccid), MSG_LEVEL_DEBUG );
    debug( '  force_account_set_no='||p_force_account_set_no,
		MSG_LEVEL_DEBUG );
    debug( '  cust_trx_type_id='||to_char(p_cust_trx_type_id),
		MSG_LEVEL_DEBUG );
    debug( '  primary_salesrep_id='||to_char(p_primary_salesrep_id),
       MSG_LEVEL_DEBUG );
    debug( '  inventory_item_id='||to_char(p_inventory_item_id),
		MSG_LEVEL_DEBUG );
    debug( '  memo_line_id='||to_char(p_memo_line_id), MSG_LEVEL_DEBUG );
    debug( '  warehouse_id='||to_char(p_warehouse_id), MSG_LEVEL_DEBUG );
    debug( '  msg_level='||to_char(system_info.msg_level), MSG_LEVEL_DEBUG );

   --
   -- Adjust account_class to proper string
   --
    l_account_class := p_account_class;
    expand_account_class( l_account_class );

   --
   --Get the billing site use id so this does not require to be passed
   --as a parameter to the do_autoaccounting procedure
   --
    IF ( p_customer_trx_id IS NOT NULL) THEN
          SELECT t.bill_to_site_use_id
          INTO   l_bill_to_site_use_id
          FROM   ra_customer_trx  t
          WHERE  t.customer_trx_id =  p_customer_trx_id;
    END IF;

   --
   -- Mode will always be get as this routine is specifically
   -- written for the same
   --
    do_autoaccounting_internal(
	      p_mode,
              l_account_class,
              p_customer_trx_id,
              p_customer_trx_line_id,
              p_cust_trx_line_salesrep_id,
              p_request_id,
              p_gl_date,
              p_original_gl_date,
              p_total_trx_amount,
              p_passed_ccid,
              p_force_account_set_no,
              p_cust_trx_type_id,
              p_primary_salesrep_id,
              p_inventory_item_id,
              p_memo_line_id,
              l_bill_to_site_use_id,
              p_warehouse_id,
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

    print_fcn_label( 'arp_auto_accounting.do_autoaccounting() overloaded get mode -' );


EXCEPTION
    WHEN no_ccid OR NO_DATA_FOUND THEN

	IF( p_mode = G OR
	    p_request_id IS NOT NULL ) THEN

	    NULL;	-- Don't raise for Get mode or Autoinvoice,
			-- otherwise the IN/OUT variables
			-- ccid, concat_segments and failure_count
			-- do not get populated.
	ELSE
	    RAISE;
	END IF;

    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_auto_accounting.do_autoaccounting()',
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

------------------------------------------------------------------------------
--  Test programs
------------------------------------------------------------------------------
PROCEDURE test_load IS
BEGIN
    -- enable_debug;
    --
    -- dump REV
    --
    debug('**REV**');
    FOR i IN 0..rev_count-1 LOOP
        debug(autoacc_def_segment_t( rev_offset + i ));
        debug(autoacc_def_table_t( rev_offset + i ));
        debug(autoacc_def_const_t( rev_offset + i ));
    END LOOP;
    --
    -- dump REC
    --
    debug('**REC**');
    FOR i in 0..rev_count-1 LOOP
        debug(autoacc_def_segment_t( rec_offset + i ));
        debug(autoacc_def_table_t( rec_offset + i ));
        debug(autoacc_def_const_t( rec_offset + i ));
    END LOOP;
    --
    -- dump FRT
    --
    debug('**FREIGHT**');
    FOR i in 0..rev_count-1 LOOP
        debug(autoacc_def_segment_t( frt_offset + i ));
        debug(autoacc_def_table_t( frt_offset + i ));
        debug(autoacc_def_const_t( frt_offset + i ));
    END LOOP;
    --
    -- dump TAX
    --
    debug('**TAX**');
    FOR i in 0..rev_count-1 LOOP
        debug(autoacc_def_segment_t( tax_offset + i ));
        debug(autoacc_def_table_t( tax_offset + i ));
        debug(autoacc_def_const_t( tax_offset + i ));
    END LOOP;
    --
    -- dump UNBILL
    --
    debug('**UNBILL**');
    FOR i in 0..rev_count-1 LOOP
        debug(autoacc_def_segment_t( unbill_offset + i ));
        debug(autoacc_def_table_t( unbill_offset + i ));
        debug(autoacc_def_const_t( unbill_offset + i ));
    END LOOP;
    --
    -- dump UNEARN
    --
    debug('**UNEARN**');
    FOR i in 0..rev_count-1 LOOP
        debug(autoacc_def_segment_t( unearn_offset + i ));
        debug(autoacc_def_table_t( unearn_offset + i ));
        debug(autoacc_def_const_t( unearn_offset + i ));
    END LOOP;
    --
    -- dump SUSPENSE
    --
    debug('**SUSPENSE**');
    FOR i in 0..rev_count-1 LOOP
        debug(autoacc_def_segment_t( suspense_offset + i ));
        debug(autoacc_def_table_t( suspense_offset + i ));
        debug(autoacc_def_const_t( suspense_offset + i ));
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        debug(SQLERRM);
        debug('arp_auto_accounting.test_load()');
        RAISE;
END test_load;

----------------------------------------------------------------------------
PROCEDURE test_query( p_account_class IN VARCHAR2,
                      p_table_name IN VARCHAR2 ) IS
BEGIN
    -- enable_debug;
    IF( query_autoacc_def(p_account_class, p_table_name)) THEN
        debug('YES');
    ELSE
        debug('NO');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        debug('arp_auto_accounting.test_query()');
        debug(SQLERRM);
        RAISE;
END test_query;

----------------------------------------------------------------------------
PROCEDURE test_find( p_trx_type_id IN NUMBER,
                     p_salesrep_id IN NUMBER,
                     p_inv_item_id IN NUMBER,
                     p_memo_line_id IN NUMBER) IS

  l_ccid_rev BINARY_INTEGER;
  l_ccid_rec BINARY_INTEGER;
  l_ccid_frt BINARY_INTEGER;
  l_ccid_tax BINARY_INTEGER;
  l_ccid_unbill BINARY_INTEGER;
  l_ccid_unearn BINARY_INTEGER;
  l_ccid_suspense BINARY_INTEGER;
  l_inv_item_type mtl_system_items.item_type%TYPE;

BEGIN
    -- enable_debug;

    if( p_trx_type_id <> -1 ) then
        get_trx_type_ccids(p_trx_type_id, l_ccid_rev, l_ccid_rec, l_ccid_frt,
                           l_ccid_tax, l_ccid_unbill, l_ccid_unearn,
                           l_ccid_suspense);
        debug( 'TRX_TYPE_ID='||to_char(p_trx_type_id)||
                            ' rev:'||to_char(l_ccid_rev)||
                            ' rec:'||to_char(l_ccid_rec)||
               ' frt:'||to_char(l_ccid_frt)||' tax:'||to_char(l_ccid_tax)||
               ' unbill:'||to_char(l_ccid_unbill)||
               ' unearn:'||to_char(l_ccid_unearn)||
               ' suspense:'||to_char(l_ccid_suspense) );

    end if;

    if( p_salesrep_id <> -1 ) then
        get_salesrep_ccids(p_salesrep_id, l_ccid_rev, l_ccid_rec, l_ccid_frt);
        debug( 'SALESREP_ID='||to_char(p_salesrep_id)||
                            ' rev:'||to_char(l_ccid_rev)||
                            ' rec:'||to_char(l_ccid_rec)||
                           ' frt:'||to_char(l_ccid_frt));
    end if;

    if( p_inv_item_id <> -1 ) then
        get_inv_item_ccids(profile_info,
                            p_inv_item_id,
                            '',
                            l_ccid_rev, l_inv_item_type );
        debug( 'ORG_ID='||oe_profile.value('SO_ORGANIZATION_ID',arp_global.sysparam.org_id)||
                            ' INV_ITEM_ID='||to_char(p_inv_item_id)||
                            ' rev:'||to_char(l_ccid_rev) );
    end if;

    if( p_memo_line_id <> -1 ) then
        get_memo_line_ccids(p_memo_line_id, l_ccid_rev);
        debug( ' MEMO_LINE_ID='||to_char(p_memo_line_id)||
                            ' rev:'||to_char(l_ccid_rev) );
    end if;

EXCEPTION
    WHEN OTHERS THEN
        debug('arp_auto_accounting.test_find()');
        debug(SQLERRM);
        RAISE;
END test_find;

----------------------------------------------------------------------------
PROCEDURE test_assembly IS

    l_ccid_record ccid_rec_type;
    l_concat varchar2(800);
    l_ccid  binary_integer;
    l_int_concat varchar2(800);
    l_int_ccid  binary_integer;
    l_inv_item_type mtl_system_items.item_type%TYPE;

BEGIN

    -- enable_debug;

    l_ccid_record.trx_type_ccid_rev := 1098;
    l_ccid_record.trx_type_ccid_rec := 1137;
    l_ccid_record.trx_type_ccid_frt := 1137;
    l_ccid_record.trx_type_ccid_tax := 1137;
    l_ccid_record.trx_type_ccid_unbill := 1137;
    l_ccid_record.trx_type_ccid_unearn := 1137;
    l_ccid_record.trx_type_ccid_suspense := 1137;
    l_ccid_record.salesrep_ccid_rev := 1173;
    l_ccid_record.salesrep_ccid_rec := 1137;
    l_ccid_record.salesrep_ccid_frt := 1137;
    l_ccid_record.lineitem_ccid_rev := 1232;
    l_ccid_record.tax_ccid_tax := 1137;
    l_ccid_record.agreecat_ccid_rev := 1137;

    assemble_code_combination( system_info,
                               flex_info,
                               REV,
                               l_ccid_record,
                               l_inv_item_type,
                               l_ccid,
                               l_concat,
                               l_int_ccid,
                               l_int_concat );
    debug(l_concat);
    debug(to_char(l_ccid));

    debug(l_int_concat);
    debug(to_char(l_int_ccid));

EXCEPTION
    WHEN OTHERS THEN
        debug('arp_auto_accounting.test_assembly()');
        debug(SQLERRM);
        RAISE;
END test_assembly;

----------------------------------------------------------------------------
PROCEDURE test_harness IS

    l_segs VARCHAR2(200);
    l_ccid BINARY_INTEGER;
    l_int_segs VARCHAR2(200);
    l_int_ccid BINARY_INTEGER;
    l_errorbuf VARCHAR2(512);
    l_x BINARY_INTEGER;

BEGIN

    -- enable_debug;

    -- Invalid account class
    --
    BEGIN
        flex_manager( 'REVX', '', 1011, 1000, '', '', '', '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );
    EXCEPTION
      WHEN invalid_account_class THEN
        debug('invalid account class test PASSED');
      WHEN OTHERS THEN
        debug('invalid account class test FAILED');
    END;


    -- Invalid trx_type_id
    --
    BEGIN
        flex_manager( REV, '', -1011, 1000, '', '', '', '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        debug('invalid trx_type_id test FAILED');

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        debug('invalid trx_type_id test PASSED');
      WHEN OTHERS THEN
        debug('invalid trx_type_id test FAILED');
    END;


    -- Invalid salesrep_id
    --
    BEGIN
        flex_manager( REV, '', 1011, -1000, '', '', '', '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        debug('invalid salesrep_id test FAILED');

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        debug('invalid salesrep_id test PASSED');
      WHEN OTHERS THEN
        debug('invalid salesrep_id test FAILED');
    END;


    -- Invalid inv_item_id
    --
    BEGIN
        flex_manager( REV, '', 1011, 1000, -1, '', '', '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        debug('invalid inv_item_id test FAILED');

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        debug('invalid inv_item_id test PASSED');
      WHEN OTHERS THEN
        debug('invalid inv_item_id test FAILED');
    END;


    -- Invalid memo_line_id
    --
    BEGIN
        flex_manager( REV, '', 1011, 1000, '', -1, '', '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        debug('invalid memo_line_id test FAILED');

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        debug('invalid memo_line_id test PASSED');
      WHEN OTHERS THEN
        debug('invalid memo_line_id test FAILED');
    END;


    -- Pass both inv_item_id and memo_line_id
    --
    BEGIN
        flex_manager( REV, '', 1011, 1000, -1, -1, '', '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        debug('item_and_memo_both_not_null test FAILED');

    EXCEPTION
      WHEN item_and_memo_both_not_null THEN
        debug('item_and_memo_both_not_null test PASSED');
      WHEN OTHERS THEN
        debug('item_and_memo_both_not_null test FAILED');
    END;


    -- Invalid ccid_tax
    --
    BEGIN
        flex_manager( TAX, '', 1011, 1000, '', '', 1, '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        debug('invalid ccid_tax test FAILED');

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        debug('invalid ccid_tax test PASSED');
      WHEN OTHERS THEN
        debug('invalid ccid_tax test FAILED');
    END;


    -- Test REV (ccid not found)
    --
    BEGIN
        flex_manager( REV, '', 1011, 1000, '', '', '', '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        IF( l_ccid = -1 AND l_segs = '01.100.4300.0.000.000' ) THEN
            debug('REV (ccid not found) test PASSED');
        ELSE
            debug('REV (ccid not found) test FAILED');
        END IF;

    EXCEPTION
      WHEN OTHERS THEN
        debug('REV (ccid not found) test FAILED');
    END;


    -- Test REV (ccid found)
    --
    BEGIN
        flex_manager( REV, '', 1011, 1000, 1, '', '', '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        IF( l_ccid = 1137 AND l_segs = '01.100.4300.000.000.000' ) THEN
            debug('REV (ccid found) test PASSED');
        ELSE
            debug('REV (ccid found) test FAILED');
        END IF;

    EXCEPTION
      WHEN OTHERS THEN
        debug('REV (ccid found) test FAILED');
    END;


    -- Test REV (ccid found)
    --
    BEGIN
        flex_manager( REV, '', 1011, 1000, '', 1001, '', '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        IF( l_ccid = 1137 AND l_segs = '01.100.4300.000.000.000' ) THEN
            debug('REV (ccid found) test PASSED');
        ELSE
            debug('REV (ccid found) test FAILED');
        END IF;

    EXCEPTION
      WHEN OTHERS THEN
        debug('REV (ccid found) test FAILED');
    END;


    -- Test CHARGES (ccid found)
    --
    BEGIN
        flex_manager( CHARGES, '', 1011, 1000, 1, '', '', '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        IF( l_ccid = 1137 AND l_segs = '01.100.4300.000.000.000' ) THEN
            debug('CHARGES (ccid found) test PASSED');
        ELSE
            debug('CHARGES (ccid found) test FAILED');
        END IF;

    EXCEPTION
      WHEN OTHERS THEN
        debug('CHARGES (ccid found) test FAILED');
    END;


    -- Test FREIGHT (ccid found)
    --
    BEGIN
        flex_manager( FREIGHT, '', 1011, 1000, 1, '', '', '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        IF( l_ccid = 1098 AND l_segs = '01.100.5650.000.000.000' ) THEN
            debug('FREIGHT (ccid found) test PASSED');
        ELSE
            debug('FREIGHT (ccid found) test FAILED');
        END IF;

    EXCEPTION
      WHEN OTHERS THEN
        debug('FREIGHT (ccid found) test FAILED');
    END;


    -- Test TAX (ccid found)
    --
    BEGIN
        flex_manager( TAX, '', 1011, 1001, 1, '', 1098, '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        IF( l_ccid = 1215 AND l_segs = '01.500.5650.000.000.000' ) THEN
            debug('TAX (ccid found) test PASSED');
        ELSE
            debug('TAX (ccid found) test FAILED');
        END IF;

    EXCEPTION
      WHEN OTHERS THEN
        debug('TAX (ccid found) test FAILED');
    END;


    -- Test UNBILL (ccid found)
    --
    BEGIN
        flex_manager( UNBILL, '', 1011, 1001, 1, '', '', '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        IF( l_ccid = 1213 AND l_segs = '01.500.1103.000.000.000' ) THEN
            debug('UNBILL (ccid found) test PASSED');
        ELSE
            debug('UNBILL (ccid found) test FAILED');
        END IF;

    EXCEPTION
      WHEN OTHERS THEN
        debug('UNBILL (ccid found) test FAILED');
    END;

    -- Test UNEARN (ccid found)
    --
    BEGIN
        flex_manager( UNEARN, '', 1011, 1001, 1, '', '', '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        IF( l_ccid = 1216 AND l_segs = '01.500.4400.000.000.000' ) THEN
            debug('UNEARN (ccid found) test PASSED');
        ELSE
            debug('UNEARN (ccid found) test FAILED');
        END IF;

    EXCEPTION
      WHEN OTHERS THEN
        debug('UNEARN (ccid found) test FAILED');
    END;

    -- Test SUSPENSE (ccid found)
    --
    BEGIN
        flex_manager( SUSPENSE, '', 1011, 1000, 2, '', '', '', '','',
                                  l_ccid,
                                  l_segs,
                                  l_int_ccid,
                                  l_int_segs );

        IF( l_ccid = 1111 AND l_segs = '01.100.5999.000.000.000' ) THEN
            debug('SUSPENSE (ccid found) test PASSED');
        ELSE
            debug('SUSPENSE (ccid found) test FAILED');
        END IF;

    EXCEPTION
      WHEN OTHERS THEN
        debug('SUSPENSE (ccid found) test FAILED');
    END;

EXCEPTION
    WHEN OTHERS THEN
        debug('arp_auto_accounting.test_harness()');
        debug(SQLERRM);
        RAISE;
END test_harness;

----------------------------------------------------------------------------
PROCEDURE test_wes IS

    l_segs VARCHAR2(200);
    l_ccid BINARY_INTEGER;
    l_int_segs VARCHAR2(200);
    l_int_ccid BINARY_INTEGER;
    l_errorbuf VARCHAR2(512);
    l_x BINARY_INTEGER;

BEGIN

    -- enable_debug;

    -- Invalid account class
    --

    BEGIN
        null;
        flex_manager( 'REVX', '', 1011, 1000, '', '', '', '', '','', l_ccid, l_segs, l_int_ccid, l_int_segs );

    EXCEPTION
      WHEN invalid_account_class THEN
        debug('invalid account class test PASSED');
      WHEN OTHERS THEN
        debug('invalid account class test FAILED');

    END;


EXCEPTION
    WHEN OTHERS THEN
        debug('arp_auto_accounting.test_harness()');
        debug(SQLERRM);
        RAISE;
END test_wes ;


----------------------------------------------------------------------------
PROCEDURE test_build_sql IS

    select_stmt VARCHAR2(32767);
    delete_stmt VARCHAR2(32767);
    mycursor integer;

BEGIN

    -- enable_debug;
    select_stmt :=
     build_select_sql(system_info, profile_info,
                      REV, 1, 2, 3, 12,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL );


    disable_debug;

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.test_build_sql()');
        debug(SQLERRM);
        RAISE;
END test_build_sql;

----------------------------------------------------------------------------
PROCEDURE test_do_autoacc IS

    ccid BINARY_INTEGER;
    concat_segments VARCHAR2(1000);
    x binary_integer;
    y binary_integer;
    errorbuf VARCHAR2(1000);

BEGIN

    -- enable_debug;

    debug('Insert Mode');
    do_autoaccounting('I', REV, 1072, 1511, null, null,
                       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                       ccid, concat_segments, y );

    debug('Update Mode');
    do_autoaccounting('U', REV, 1, 2, 3, 12,
                       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                       ccid, concat_segments, y );

    debug('Delete Mode');
    do_autoaccounting('D', REV, 1, 2, 3, 12,
                       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                       ccid, concat_segments, y );

    debug('Get Mode');
    do_autoaccounting('G', REV, 1, 2, 3, 12,
                       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                       ccid, concat_segments, y );

    debug('Insert Mode: ALL');
    do_autoaccounting('I', 'ALL', 1072, 1511, null, null,
                       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                       ccid, concat_segments, y );

    disable_debug;

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.test_do_autoacc()');
        debug(SQLERRM);
        RAISE;
END test_do_autoacc;




----------------------------------------------------------------------------
-- Constructor code
----------------------------------------------------------------------------
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
PROCEDURE init is
BEGIN
    print_fcn_label( 'arp_auto_accounting.constructor()+' );

    ------------------------------------------------------------------------
    -- Load autoaccounting definition into plsql tables
    ------------------------------------------------------------------------
    load_autoacc_def;
    system_info  := arp_trx_global.system_info;

    /* Bug 2560036 - determine if collectibility is enabled */
    g_test_collectibility :=
         ar_revenue_management_pvt.revenue_management_enabled;

    ------------------------------------------------------------------------
    -- Additional system info
    ------------------------------------------------------------------------
    BEGIN

        system_info.rev_based_on_salesrep :=
            query_autoacc_def( REV, 'RA_SALESREPS' );

        system_info.tax_based_on_salesrep :=
            query_autoacc_def( TAX, 'RA_SALESREPS' );

        system_info.unbill_based_on_salesrep :=
            query_autoacc_def( UNBILL, 'RA_SALESREPS' );

        system_info.unearn_based_on_salesrep :=
            query_autoacc_def( UNEARN, 'RA_SALESREPS' );

        system_info.suspense_based_on_salesrep :=
            query_autoacc_def( SUSPENSE, 'RA_SALESREPS' );


    EXCEPTION
        WHEN OTHERS THEN
            arp_util.debug('Error getting system information');
            RAISE;
    END;


    get_error_message_text;

    dump_info;

    print_fcn_label( 'arp_auto_accounting.constructor()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_auto_accounting.constructor');
        debug(SQLERRM);
        RAISE;
END init;
BEGIN
init;

END arp_auto_accounting;

/
