--------------------------------------------------------
--  DDL for Package ZX_AR_TAX_CLASSIFICATN_DEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_AR_TAX_CLASSIFICATN_DEF_PKG" AUTHID CURRENT_USER as
/* $Header: zxartxclsdefpkgs.pls 120.8 2006/03/10 18:39:08 appradha ship $ */
-- PRAGMA RESTRICT_REFERENCES( ARP_TAX, WNDS, WNPS, RNPS );

/*-----------------------------------------------------------------------*/
/*       Constants                                                       */
/*-----------------------------------------------------------------------*/
MAX_NR_TAX_RATE CONSTANT NUMBER := 100;
MTHD_SALES CONSTANT VARCHAR2(10) := 'EBTAX';
MTHD_VAT CONSTANT VARCHAR2(10)   := 'EBTAX';
MTHD_LATIN CONSTANT VARCHAR2(10) := 'LTE';

TAX_TYPE_INACTIVE CONSTANT NUMBER := 0;
TAX_TYPE_LOCATION CONSTANT NUMBER := 1;
TAX_TYPE_SALES    CONSTANT NUMBER := 2;
TAX_TYPE_VAT 	  CONSTANT NUMBER := 3;

TAX_SUCCESS       CONSTANT VARCHAR2(1) := '0';
TAX_NO_VENDOR 	  CONSTANT VARCHAR2(1) := '1';
TAX_RC_NO_RATE    CONSTANT VARCHAR2(1) := '2';
TAX_RC_OERR       CONSTANT VARCHAR2(1) := '9';
TAX_RC_SYSERR     CONSTANT VARCHAR2(2) := '10';
--
-- Tax Defaulting level constants
--
TAX_DEFAULT_SITE      CONSTANT  VARCHAR2(30) := 'SHIP_TO_PARTY_SITE';
TAX_DEFAULT_CUSTOMER  CONSTANT  VARCHAR2(30) := 'SHIP_TO_PARTY';
TAX_DEFAULT_PRODUCT   CONSTANT  VARCHAR2(30) := 'PRODUCT';
TAX_DEFAULT_ACCOUNT   CONSTANT  VARCHAR2(30) := 'REVENUE_ACCOUNT';
TAX_DEFAULT_SYSTEM    CONSTANT  VARCHAR2(30) := 'SYSTEM_OPTIONS';
TAX_DEFAULT_PROJECT   CONSTANT  VARCHAR2(30) := 'PROJECT';
TAX_DEFAULT_EXP_EV    CONSTANT	VARCHAR2(30) := 'TYPE';
TAX_DEFAULT_EXTENSION CONSTANT	VARCHAR2(30) := 'CLIENT_EXTENSION';
TAX_DEFAULT_AR_PARAM  CONSTANT	VARCHAR2(30) := 'SYSTEM_OPTIONS';

/*-----------------------------------------------------------------------*/
/*       User Defined Exceptions                                         */
/*-----------------------------------------------------------------------*/
AR_TAX_EXCEPTION	EXCEPTION;	/* General Exception raised for all Tax errors  */
TAX_NO_RATE		EXCEPTION;	/* Could not deduce tax rate for line */
TAX_NO_CODE		EXCEPTION;	/* Could not deduce tax code for line */
TAX_NO_AMOUNT		EXCEPTION;	/* Amount in RA_INTERFACE_LINES was null */
TAX_NO_PRECISION	EXCEPTION;	/* Precision is null, no rate returned */
TAX_NO_DATA		EXCEPTION;	/* Sales Tax compounding was unable to find any data */
TAX_NEED_POSTAL		EXCEPTION;	/* Postal Code was not found, could not deduce Sales tax rate */
TAX_CODE_INACTIVE	EXCEPTION;	/* Tax code passed is Inactive for the trx date */
TAX_BAD_DATA		EXCEPTION;	/* Fatal Data Error - Sales Tax Calculation aborted */
TAX_OERR		EXCEPTION;	/* Oracle Error */

/*-----------------------------------------------------------------------*/
/*       Table/Record Types                                              */
/*-----------------------------------------------------------------------*/

TYPE VARCHAR2_30_tab_type IS TABLE OF
        VARCHAR2(30) INDEX BY BINARY_INTEGER;

TYPE system_info_rec_type IS RECORD
(
  --
  -- This record holds general information used by the Tax Entity handler
  -- and its associated functions.
  --
	sysparam		 ar_system_parameters%ROWTYPE,
	/* nipatel added for eTax uptake */
	ar_product_options_rec zx_product_options_all%ROWTYPE,
	pa_product_options_rec zx_product_options_all%ROWTYPE,
        tax_enforce_account_flag VARCHAR2(1),
	chart_of_accounts_id	 gl_sets_of_books.chart_of_accounts_id%TYPE,
	base_precision		 fnd_currencies.precision%TYPE,
	func_precision		 fnd_currencies.precision%TYPE,
	min_accountable_unit	 fnd_currencies.minimum_accountable_unit%TYPE,
	insert_tax_lines	 CHAR,	/* If 'N', no inserts or Autoaccounting calls will be made */
	call_auto_acctng	 CHAR,	/* If 'N', Autoaccounting will not be called, 'N' when called from 'C' */
	tax_view_set		 VARCHAR2(2),	/* Tax view Name space. '_A' for Taxware, '_V' for Vertex etc. NULL for Oracle Tax views */
	appl_short_name		 VARCHAR2(30),	/* AR or OE */
	func_short_name		 VARCHAR2(30),	/* GL_ACCT_FIRST, ACCT_RULES or ACCT_DIST */
	base_currency_code	 fnd_currencies.currency_code%TYPE, /* functional currency code */
	allow_multiple_inclusive CHAR, /* If 'N', multiple inclusive taxes are not allowed */
	search_hierarchy_tab     VARCHAR2_30_tab_type, /* Tax defaulting hierarchy table */
	search_pa_hierarchy_tab  VARCHAR2_30_tab_type  /* PA Tax defaulting hierarchy table */
);

sysinfo	system_info_rec_type;


TYPE profile_info_rec_type IS RECORD
(
  --
  -- This record holds profile information used by the Tax Entity Handlers
  -- and its associated functions.
  --
	application_id		BINARY_INTEGER,
	user_id			BINARY_INTEGER,
	so_organization_id	BINARY_INTEGER
);

profinfo profile_info_rec_type;


TYPE tax_info_rec_type IS RECORD
(

-- This record holds general information used by the tax engine about
-- each transaction, transaction line and tax line. Records in this
-- global can change on each row returned from any of the tax views.
--

/*-----------------------------------------------------------------------*/
/*       Transaction Header Data                                         */
/*-----------------------------------------------------------------------*/

bill_to_cust_id                  ra_customer_trx.bill_to_customer_id%TYPE,
ship_to_cust_id                  ra_customer_trx.ship_to_customer_id%TYPE,

customer_trx_id                  NUMBER,

trx_number			 ra_customer_trx.trx_number%TYPE,
bill_to_customer_number		 hz_cust_accounts.account_number%TYPE,
ship_to_customer_number		 hz_cust_accounts.account_number%TYPE,
bill_to_customer_name		 hz_parties.party_name%TYPE,
ship_to_customer_name		 hz_parties.party_name%TYPE,
previous_customer_trx_id	 ra_customer_trx_lines.previous_customer_trx_id%TYPE,
previous_trx_number		 ra_customer_trx.trx_number%TYPE,
trx_date                         ra_customer_trx.trx_date%TYPE,
gl_date				 ra_cust_trx_line_gl_dist.gl_date%TYPE,
ship_to_site_use_id              hz_cust_site_uses.site_use_id%TYPE,
bill_to_site_use_id              hz_cust_site_uses.site_use_id%TYPE,
ship_to_postal_code              hz_locations.postal_code%TYPE,
bill_to_postal_code              hz_locations.postal_code%TYPE,
ship_to_location_id              NUMBER,
bill_to_location_id              NUMBER,
invoicing_rule_id                ra_customer_trx.invoicing_rule_id%TYPE,
fob_point                        ra_customer_trx.fob_point%TYPE,
trx_currency_code                ra_customer_trx.invoice_currency_code%TYPE,
trx_exchange_rate                ra_customer_trx.exchange_rate%TYPE,
minimum_accountable_unit         fnd_currencies.minimum_accountable_unit%TYPE,
precision                        fnd_currencies.precision%TYPE,
tax_header_level_flag            hz_cust_accounts.tax_header_level_flag%TYPE,
tax_rounding_rule                hz_cust_accounts.tax_rounding_rule%TYPE,
/*-----------------------------------------------------------------------*/
/*       Release 11 Transaction header data                              */
/*-----------------------------------------------------------------------*/
trx_type_id                	 ra_cust_trx_types.cust_trx_type_id%TYPE,
ship_from_warehouse_id           NUMBER,
payment_term_id                	 ra_customer_trx.term_id%TYPE,


/*-----------------------------------------------------------------------*/
/*       Transaction Line Data                                           */
/*-----------------------------------------------------------------------*/
customer_trx_line_id             NUMBER,

previous_customer_trx_line_id    ra_customer_trx_lines.previous_customer_trx_line_id%TYPE,
link_to_cust_trx_line_id         ra_customer_trx_lines.link_to_cust_trx_line_id%TYPE,
memo_line_id                     ra_customer_trx_lines.memo_line_id%TYPE,
taxed_quantity                   ra_customer_trx_lines.quantity_invoiced%TYPE,
inventory_item_id                mtl_system_items.inventory_item_id%TYPE,
extended_amount                  ra_customer_trx_lines.extended_amount%TYPE,
entered_amount			 ra_customer_trx_lines.extended_amount%TYPE,

tax_code                         ar_vat_tax.tax_code%TYPE,
vat_tax_id                       ar_vat_tax.vat_tax_id%TYPE,
tax_exemption_id                 ra_tax_exemptions.tax_exemption_id%TYPE,
item_exception_rate_id           ra_item_exception_rates.item_exception_rate_id%TYPE,
tax_rate                         ar_vat_tax.tax_rate%TYPE,

default_ussgl_transaction_code   ra_customer_trx_lines.default_ussgl_transaction_code%TYPE,
default_ussgl_trx_code_context   ra_customer_trx_lines.default_ussgl_trx_code_context%TYPE,
/*-----------------------------------------------------------------------*/
/*       Release 11 Transaction Line data                                */
/*-----------------------------------------------------------------------*/
amount_includes_tax_flag         CHAR,           /* 'Y' if line amount includes tax */
taxable_basis         		 VARCHAR2(30),   /* Taxable basis */
tax_calculation_plsql_block      VARCHAR2(2000), /* Tax rules */
payment_terms_discount_percent   NUMBER, 	 /* Discount Percent */


/*-----------------------------------------------------------------------*/
/*       Tax Extension Parameters, these are defined specifically to     */
/*                       support AVP(tm) and Vertex(tm)                  */
/*-----------------------------------------------------------------------*/

audit_flag			 CHAR,	 	  /* 'Y' if this record should be audited */
qualifier                        VARCHAR2(30),    /* LOCATION_QUALIFIER */
ship_from_code                   VARCHAR2(30),    /* SHIP_FROM_CODE */
ship_to_code                     VARCHAR2(30),    /* SHIP_TO_CODE */
poo_code                         VARCHAR2(30),    /* Point of Order Origin */
poa_code                         VARCHAR2(30),    /* Point of Order Acceptance */

vdrctrl_exempt                   VARCHAR(30),    /* Vendor Control of Tax Exmeptions */

tax_control                      ra_customer_trx_lines.tax_exempt_flag%TYPE,
xmpt_cert_no                     ra_tax_exemptions.customer_exemption_number%TYPE,
xmpt_reason                      ra_tax_exemptions.reason_code%TYPE,
xmpt_percent                     ra_tax_exemptions.percent_exempt%TYPE,

trx_line_type			 VARCHAR2(30),   /* Sale / Service / Purchase / Rental */
part_no                          VARCHAR2(40),   /* Part Number as understood by Vendor */
division_code			 VARCHAR2(30),	 /* Organization Attributes */
company_code			 VARCHAR2(30),


/*-----------------------------------------------------------------------*/
/*       Release 11 has 5 more character and numeric attributes.         */
/*-----------------------------------------------------------------------*/
userf1                           VARCHAR2(80),    /* User Defined Strings */
userf2                           VARCHAR2(80),
userf3                           VARCHAR2(80),
userf4                           VARCHAR2(80),
userf5                           VARCHAR2(80),
userf6                           VARCHAR2(80),
userf7                           VARCHAR2(80),
userf8                           VARCHAR2(80),
userf9                           VARCHAR2(80),
userf10                          VARCHAR2(80),

usern1                           NUMBER,         /* User Defined Numbers */
usern2                           NUMBER,
usern3                           NUMBER,
usern4                           NUMBER,
usern5                           NUMBER,
usern6                           NUMBER,
usern7                           NUMBER,
usern8                           NUMBER,
usern9                           NUMBER,
usern10                          NUMBER,

calculate_tax                    CHAR,           /* if 'Y' calculate tax, else add only */
                                                 /* taxable amount                      */

/*-----------------------------------------------------------------------*/
/*       Tax Line Data                                                   */
/*-----------------------------------------------------------------------*/

status                           NUMBER,
credit_memo_flag           	 BOOLEAN, /* If TRUE, the tax engine will copy the tax rates as passed without validation for Adhoc Tax Codes */
tax_type                         NUMBER,          /* Internal flags */

sales_tax_id                     NUMBER,
location_segment_id              NUMBER,
tax_line_number                  ra_customer_trx_lines.line_number%TYPE,
tax_amount                       ra_customer_trx_lines.extended_amount%TYPE,
tax_vendor_return_code           ra_customer_trx_lines.tax_vendor_return_code%TYPE,
tax_precedence                   ra_customer_trx_lines.tax_precedence%TYPE,
compound_amount                  NUMBER,           /* Amount of Compounded Tax already held in extended_amount */
effective_tax_rate		NUMBER,		/* Effective tax rate to be used to calculate tax. */


/*-----------------------------------------------------------------------*/
/*       Global Descriptive Flexfields                                   */
/*-----------------------------------------------------------------------*/
global_attribute1		varchar2(150),
global_attribute2		varchar2(150),
global_attribute3		varchar2(150),
global_attribute4		varchar2(150),
global_attribute5		varchar2(150),
global_attribute6		varchar2(150),
global_attribute7		varchar2(150),
global_attribute8		varchar2(150),
global_attribute9		varchar2(150),
global_attribute10		varchar2(150),
global_attribute11		varchar2(150),
global_attribute12		varchar2(150),
global_attribute13		varchar2(150),
global_attribute14		varchar2(150),
global_attribute15		varchar2(150),
global_attribute16		varchar2(150),
global_attribute17		varchar2(150),
global_attribute18		varchar2(150),
global_attribute19		varchar2(150),
global_attribute20		varchar2(150),
global_attribute_category	varchar2(30),


/*---------------------------------------*/
/* added for R11.5                       */
/*---------------------------------------*/
customer_trx_charge_line_id     NUMBER(15),
poo_id                          NUMBER(15),
poa_id                          NUMBER(15),
taxable_amount			NUMBER,
override_tax_rate               NUMBER

/*---------------------------------------*/
/* CRM releated changes                  */
/*---------------------------------------*/
--crm
, party_flag                    VARCHAR2(1) -- 'Y' if address info is from party
                                            -- instead of customer
,cm_type                        VARCHAR2(20),


/*----------------------------------------*/
/* columns added for eTax integration     */
/*----------------------------------------*/
 internal_organization_id               number,
 internal_org_location_id               number,
 application_id           		number,
 entity_code 				varchar2(30),
 event_class_code                	varchar2(30),
 ledger_id                              number,
 legal_entity_id                 	number,
 rounding_ship_to_party_id              number,
 rounding_bill_to_party_id        	number,
 rndg_ship_to_party_site_id             number,
 rndg_bill_to_party_site_id             number,
 establishment_id                       number,
 default_taxation_country               varchar2(2),
 currency_conversion_date               date,
 currency_conversion_type               varchar2(30),
 currency_conversion_rate               number,
 trx_communicated_date                  date,
 batch_source_id                        number,
 batch_source_name                      varchar2(150),
 doc_seq_id                             number,
 doc_seq_name                           varchar2(150),
 doc_seq_value                          varchar2(240),
 trx_due_date                           date,
 trx_type_description                   varchar2(240),
 billing_trading_partner_name           varchar2(150),
 billing_trading_partner_number         varchar2(150),
 billing_tp_tax_reporting_flg           varchar2(1),
 billing_tp_taxpayer_id                 varchar2(80),
 document_sub_type                      varchar2(240),
 tax_invoice_date                       date,
 tax_invoice_number                     varchar2(150),
 doc_event_status                       varchar2(30),
 trx_level_type				varchar2(30),
 line_class				varchar2(30),
 trx_shipping_date			date,
 trx_receipt_date			date,
-- already present  trx_line_type				varchar2(30),
 trx_line_date				date,
 trx_business_category			varchar2(240),
 line_intended_use			varchar2(240),
 user_defined_fisc_class		varchar2(30),
 line_amt_includes_tax_flg		varchar2(1),
 unit_price				number,
 cash_discount				number,
 volume_discount			number,
 trading_discount			number,
 transfer_charge			number,
 transportation_charge			number,
 insurance_charge			number,
 other_charge				number,
 product_id				number,
 product_fisc_classification		varchar2(240),
 product_org_id				number,
 uom_code				varchar2(30),
 product_type				varchar2(240),
 product_code			        ZX_LINES_DET_FACTORS.product_code%TYPE,
 product_category			varchar2(240),
 trx_sic_code				varchar2(150),
--  already present    fob_point				varchar2(30),
 ship_to_party_id			number,
 ship_from_party_id			number,
 poa_party_id				number,
 poo_party_id				number,
 bill_to_party_id			number,
 bill_from_party_id			number,
 merchant_party_id			number,
 ship_to_party_site_id			number,
 ship_from_party_site_id		number,
 poa_party_site_id			number,
 poo_party_site_id			number,
 bill_to_party_site_id			number,
 bill_from_party_site_id		number,
--  already present   ship_to_location_id			number,
 ship_from_location_id			number,
 poa_location_id			number,
 poo_location_id			number,
--  already present   bill_to_location_id			number,
 bill_from_location_id			number,
 account_ccid				number,
 account_string				varchar2(2000),
 adjusted_doc_application_id            number,
 adjusted_doc_entity_code               varchar2(30),
 adjusted_doc_event_class_code          varchar2(30),
 adjusted_doc_trx_id                    number,
 adj_doc_hdr_trx_user_key1              varchar2(150),
 adj_doc_hdr_trx_user_key2              varchar2(150),
 adj_doc_hdr_trx_user_key3              varchar2(150),
 adj_doc_hdr_trx_user_key4              varchar2(150),
 adj_doc_hdr_trx_user_key5              varchar2(150),
 adj_doc_hdr_trx_user_key6              varchar2(150),
 adjusted_doc_line_id			number,
 adj_doc_lin_trx_user_key1		varchar2(150),
 adj_doc_lin_trx_user_key2		varchar2(150),
 adj_doc_lin_trx_user_key3		varchar2(150),
 adj_doc_lin_trx_user_key4		varchar2(150),
 adj_doc_lin_trx_user_key5		varchar2(150),
 adj_doc_lin_trx_user_key6		varchar2(150),
 adjusted_doc_number			varchar2(150),
 adjusted_doc_date			date,
 assessable_value			number,
 tax_classification_code		varchar2(30),
 trx_id_level2				number,
 trx_id_level3				number,
 trx_id_level4				number,
 trx_id_level5				number,
 trx_id_level6				number,

 trx_line_number			number,
 historical_flg				varchar2(1),
 trx_line_description			varchar2(240),
 product_description			varchar2(240),
 trx_waybill_number			varchar2(50),
--  already present   trx_line_gl_date			date,
 paying_party_id			number,
 own_hq_party_id			number,
 trading_hq_party_id			number,
 poi_party_id				number,
 pod_party_id				number,
 title_transfer_party_id		number,
 paying_party_site_id			number,
 own_hq_party_site_id			number,
 trading_hq_party_site_id		number,
 poi_party_site_id			number,
 pod_party_site_id			number,
 title_transfer_party_site_id		number,
 paying_location_id			number,
 own_hq_location_id			number,
 trading_hq_location_id			number,
 poc_location_id			number,
 poi_location_id			number,
 pod_location_id			number,
 title_transfer_location_id		number,
 banking_tp_taxpayer_id			varchar2(80),

-- Output tax line columns

 tax_regime_code           varchar2(30),
 tax                       varchar2(30),
 tax_rate_code             varchar2(30) ,
 tax_status_code           varchar2(30) ,
 tax_regime_id             number,
 tax_id			   number,
 tax_rate_id               number,
 tax_status_id             number,

-- Columns added for LTE integration with eTax
 tax_currency_code                      fnd_currencies.currency_code%TYPE,
 tax_currency_conversion_date		date,
 tax_currency_conversion_type		varchar2(30),
 tax_currency_conversion_rate		number,
 tax_apportionment_line_number		number,
 tax_base_modifier_rate			number,
 unrounded_taxable_amt			number,
 unrounded_tax_amt			number,
 tax_date				date,
 tax_determine_date			date,
 tax_point_date				date,
 tax_type_code				varchar2(30),
 rounding_level_code			varchar2(30),
 rounding_rule_code			varchar2(30),
 rounding_lvl_party_tax_prof_id		number,
 rounding_lvl_party_type		varchar2(30),
 cal_tax_amt				number,
 cancel_flag				varchar2(1),
 purge_flag				varchar2(1),
 delete_flag				varchar2(1),
 tax_amt_included_flag			varchar2(1),
 self_assessed_flag			varchar2(1),
 overridden_flag			varchar2(1),
 manually_entered_flag			varchar2(1),
 reporting_only_flag			varchar2(1),
 freeze_until_overridden_flag		varchar2(1),
 copied_from_other_doc_flag		varchar2(1),
 recalc_required_flag			varchar2(1),
 settlement_flag			varchar2(1),
 item_dist_changed_flag			varchar2(1),
 associated_child_frozen_flag		varchar2(1),
 compounding_dep_tax_flag		varchar2(1),
 legal_justification_text1		varchar2(240),
 legal_justification_text2		varchar2(240),
 legal_justification_text3		varchar2(240),
 ctrl_total_line_tx_amt			number,

 mrc_tax_line_flag                      varchar2(1),
 offset_flag                            varchar2(1),
 process_for_recovery_flag              varchar2(1),
 compounding_tax_flag                   varchar2(1),
 historical_flag                        varchar2(1),
 tax_apportionment_flag                 varchar2(1),
 tax_only_line_flag                     varchar2(1),
 enforce_from_natural_acct_flag         varchar2(1)
);


tax_info_rec tax_info_rec_type;

/*-----------------------------------------------------------------------*/
/* Table of Code Combination Ids. Used by the tax engine to get tax      */
/* information from General Ledger.                                      */

/*-----------------------------------------------------------------------*/
TYPE CCID_tab_type IS TABLE OF
        gl_code_combinations.code_combination_id%TYPE

        INDEX BY BINARY_INTEGER;

/*-----------------------------------------------------------------------*/
/* Control flags, initialised by this package once, and used on each     */
/* subsequent invocation.                                                */
/*-----------------------------------------------------------------------*/
TYPE tax_gbl_rec_type IS RECORD
(
dump_cache_stats                 BOOLEAN,     /* If true Cache Size information will be dumped to AFWRT_LOG */

called_by_order_entry            BOOLEAN,     /* TRUE if OE is the calling application */

insert_tax_lines                 BOOLEAN,     /* If False no inserts or auto-accounting */
                                              /* calls will be made when generating tax */
                                              /* lines */
/* BugFix 645089 */
get_adhoc                        BOOLEAN,     /* True if this call is for an update and */
                                              /* the adhoc tax rate/amount should be    */
                                              /* retrieved from the original tax line   */

tax_no_rate                      NUMBER,      /* Number of Transaction lines found with */
                                              /* no code or rate information */

total_tax_amount                 NUMBER,      /* Cumulated Tax amount for this call     */
                                              /* used by the "SALESTAX SUMMARY API"     */

one_err_msg_flag                 CHAR,        /* Y: means displays only one message and */
                                              /*    the message has not yet displayed   */
                                              /* D: means display only one message and  */
                                              /*    the message has been displayed      */
                                              /* N: means could display more than one   */

trx_line_id                      NUMBER,      /* Trx Line ID used for Error reporting   */
trx_line_number                  VARCHAR(40), /* Line Number usable for Error reporting */

total_taxable_amount             NUMBER,                    /* caculates the total taxable amount   */

/*-----------------------------------------------------------------------*/
/*       Data used by Calculate and its supporting functions             */
/*-----------------------------------------------------------------------*/
tax_accnt_column		VARCHAR2(50),		   /* Stores the segment column name of the Tax account qualifier */
natural_acct_column             VARCHAR2(30),              /* Stores the segment column name of the Natural account */
loc_tax_code_count		NUMBER(3) 		   /* Stores the no. of Location tax codes */
);

tax_gbl_rec tax_gbl_rec_type;

TYPE tax_rec_tbl_type is TABLE of RA_CUSTOMER_TRX_LINES%ROWTYPE index by
  binary_integer;

TYPE tax_info_rec_tbl_type is TABLE of tax_info_rec_type index by
  binary_integer;

tax_rec_tbl 		tax_rec_tbl_type;
tax_info_rec_tbl	tax_info_rec_tbl_type;
old_line_rec		ra_customer_trx_lines%rowtype;
new_line_rec		ra_customer_trx_lines%rowtype;
/*
TYPE om_tax_out_rec_type IS RECORD
(vat_tax_id             ar_vat_tax.vat_tax_id%type,
 extended_amount        ra_customer_trx_lines.extended_amount%TYPE,
 tax_rate               ar_vat_tax.tax_rate%TYPE);*/

TYPE om_tax_out_tab_type IS TABLE of tax_info_rec_type index by
  binary_integer;


om_tax_info_rec_tbl om_tax_out_tab_type;

   TYPE trx_type_tbl_type IS TABLE OF ra_cust_trx_types.type%type index by binary_integer;
   trx_type_tbl      trx_type_tbl_type;

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    get_default_tax_classification                                          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |  Returns default tax classification code based on AR defaulting hierarchy. |
 |                                                                            |
 | SCOPE: Public                                                              |
 |                                                                            |
 *----------------------------------------------------------------------------*/

 PROCEDURE  get_default_tax_classification ( p_ship_to_site_use_id     IN NUMBER
                                            ,p_bill_to_site_use_id     IN NUMBER
                                            ,p_inventory_item_id       IN NUMBER
                                            ,p_organization_id         IN NUMBER
                                            -- ,p_warehouse_id            IN NUMBER
                                            ,p_set_of_books_id         IN NUMBER
                                            ,p_trx_date                IN DATE
                                            ,p_trx_type_id             IN NUMBER
                                            ,p_tax_classification_code    OUT NOCOPY VARCHAR2
                                            -- ,p_vat_tax_id                 OUT NOCOPY NUMBER
                                            -- ,p_amt_incl_tax_flag          OUT NOCOPY VARCHAR2
                                            -- ,p_amt_incl_tax_override      OUT NOCOPY VARCHAR2
                                            ,p_cust_trx_id             IN NUMBER default null
                                            ,p_cust_trx_line_id        IN NUMBER default null
                                            ,p_customer_id             IN NUMBER default null
                                            ,p_memo_line_id            IN NUMBER default null
                                            ,APPL_SHORT_NAME           IN VARCHAR2 default NULL
                                            ,FUNC_SHORT_NAME           IN VARCHAR2 default NULL
                                            ,p_party_flag              IN VARCHAR2 default NULL
                                            ,p_party_location_id       IN VARCHAR2 default NULL
                                            ,p_entity_code             IN VARCHAR2
                                            ,p_event_class_code        IN VARCHAR2
                                            ,p_application_id          IN NUMBER
                                            ,p_internal_organization_id IN NUMBER
                                            ,p_ccid                     IN NUMBER  default null);





/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    get_pa_default_classification                                           |
 |                                                                            |
 | DESCRIPTION                                                                |
 |  Returns default tax code for Project Accounting's Draft invoice.          |
 |                                                                            |
 | SCOPE: Public                                                              |
 |                                                                            |
 | CALLED FROM:                                                               |
 |  Project Accounting's Tax Defaulting api                                   |
 |                                                                            |
 *----------------------------------------------------------------------------*/

 PROCEDURE  get_pa_default_classification
       (p_project_id              IN            NUMBER
       ,p_customer_id             IN            NUMBER
       ,p_ship_to_site_use_id     IN            NUMBER
       ,p_bill_to_site_use_id     IN            NUMBER
       ,p_set_of_books_id         IN            NUMBER
       ,p_event_id                IN            NUMBER
       ,p_expenditure_item_id     IN            NUMBER
       ,p_line_type               IN            VARCHAR2
       ,p_request_id              IN            NUMBER
       ,p_user_id                 IN            NUMBER
       ,p_trx_date                IN            DATE
       ,p_tax_classification_code    OUT NOCOPY VARCHAR2
       ,p_application_id           IN  NUMBER
       ,p_internal_organization_id IN  NUMBER);

 /* bug 2759960 Create Overloaded API for PA's support for customer account relationship.*/

 PROCEDURE  get_pa_default_classification
       (p_project_id               IN            NUMBER
       ,p_project_customer_id      IN            NUMBER
       ,p_ship_to_site_use_id      IN            NUMBER
       ,p_bill_to_site_use_id      IN            NUMBER
       ,p_set_of_books_id          IN            NUMBER
       ,p_event_id                 IN            NUMBER
       ,p_expenditure_item_id      IN            NUMBER
       ,p_line_type                IN            VARCHAR2
       ,p_request_id               IN            NUMBER
       ,p_user_id                  IN            NUMBER
       ,p_trx_date                 IN            DATE
       ,p_tax_classification_code     OUT NOCOPY VARCHAR2
       ,p_ship_to_customer_id      IN            NUMBER
       ,p_bill_to_customer_id      IN            NUMBER
       ,p_application_id           IN            NUMBER
       ,p_internal_organization_id IN            NUMBER);


PROCEDURE get_gl_tax_info (
         p_ccid                     IN NUMBER
        ,p_internal_organization_id IN NUMBER
        ,p_trx_date            	    IN DATE
        ,p_set_of_books_id          IN NUMBER
        ,p_check_override_only 	    IN CHAR
        ,p_tax_classification_code  OUT NOCOPY VARCHAR2
        ,p_override_flag            OUT NOCOPY CHAR
        ,p_validate_tax_code_flag   IN BOOLEAN default TRUE );


PROCEDURE initialize;


END ZX_AR_TAX_CLASSIFICATN_DEF_PKG;


 

/
