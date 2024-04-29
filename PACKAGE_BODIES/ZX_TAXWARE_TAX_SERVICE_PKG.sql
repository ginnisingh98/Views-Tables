--------------------------------------------------------
--  DDL for Package Body ZX_TAXWARE_TAX_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TAXWARE_TAX_SERVICE_PKG" as
/*$Header: zxtxwsrvcpkgb.pls 120.24.12010000.11 2009/10/06 17:01:10 tsen ship $*/

/* ======================================================================*
 | FND Logging infrastructure                                           |
 * ======================================================================*/
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'ZX_TAXWARE_TAX_SERVICE_PKG';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(80) := 'ZX.PLSQL.ZX_TAXWARE_TAX_SERVICE_PKG.';

-- Service Indicator
SERVIND		CHAR;
NOSERV_IND	CONSTANT SERVIND%TYPE := ' ';
SERVICE_IND	CONSTANT SERVIND%TYPE := 'S';
RENTAL_IND	CONSTANT SERVIND%TYPE := 'R';
G_tax_selection     		ZX_TAX_TAXWARE_GEN.SELPARMTYP%TYPE;
G_STRING       VARCHAR2(200);
g_docment_type_id	number;
g_trasaction_id		number;
g_tax_regime_code	varchar2(80);
g_transaction_line_id	number;
g_trx_level_type	varchar2(20);
l_trx_line_context_changed      BOOLEAN;
g_StTaxAmt	number;
g_CoTaxAmt	number;
g_CiTaxAmt	number;
g_TotalTaxAmt   NUMBER;
cache_index    number :=0;
l_state_tax_cnt        NUMBER;
l_county_tax_cnt       NUMBER;
l_city_tax_cnt         NUMBER;
l_state_cert_no                 varchar2(150);
l_county_cert_no                varchar2(150);
l_city_cert_no                  varchar2(150);

Type cache_record_type is record(
internal_organization_id  number,
document_type_id          number,
transaction_id		  number,
transaction_line_id       number
);

type cache_tab is table of cache_record_type index by binary_integer;
cache_table cache_tab;

TYPE NUMBER_tbl_type            IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_1_tbl_type        IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_2_tbl_type        IS TABLE OF VARCHAR2(2)    INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_15_tbl_type       IS TABLE OF VARCHAR2(15)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_30_tbl_type       IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_80_tbl_type       IS TABLE OF VARCHAR2(80)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_50_tbl_type       IS TABLE OF VARCHAR2(50)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_240_tbl_type      IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
TYPE DATE_tbl_type              IS TABLE OF DATE           INDEX BY BINARY_INTEGER;


TYPE SYNC_TAX_LINES_TBL IS RECORD(
document_type_id		NUMBER_tbl_type,
transaction_id			NUMBER_tbl_type,
transaction_line_id		NUMBER_tbl_type,
trx_level_type   		VARCHAR2_30_tbl_type,
country_code			VARCHAR2_30_tbl_type,
tax				VARCHAR2_30_tbl_type,
situs				VARCHAR2_30_tbl_type,
tax_jurisdiction		VARCHAR2_30_tbl_type,
tax_currency_code		VARCHAR2_15_tbl_type,
tax_curr_tax_amount		NUMBER_tbl_type,
tax_amount			NUMBER_tbl_type,
tax_rate_percentage		NUMBER_tbl_type,
taxable_amount			NUMBER_tbl_type,
exempt_rate_modifier		NUMBER_tbl_type,
exempt_reason			VARCHAR2_240_tbl_type,
tax_only_line_flag		VARCHAR2_1_tbl_type,
inclusive_tax_line_flag		VARCHAR2_1_tbl_type,
use_tax_flag			VARCHAR2_1_tbl_type,
ebiz_override_flag		VARCHAR2_1_tbl_type,
user_override_flag		VARCHAR2_1_tbl_type,
last_manual_entry		VARCHAR2_30_tbl_type,
manually_entered_flag		VARCHAR2_1_tbl_type,
cancel_flag			VARCHAR2_1_tbl_type,
delete_flag			VARCHAR2_1_tbl_type
);

/*-----------------------------------------------------------------------*/
/* Taxware error messages - based on Completion code                     */
/*-----------------------------------------------------------------------*/
--
-- Generic Tax Calculation error messages
--
TGMSG_SUCCESS       CONSTANT VARCHAR2(80) :=
	'Tax calculation processing completed successfully.';
TGMSG_EMPTY         CONSTANT VARCHAR2(80) := ' ';
TGMSG_INVALIDZIP    CONSTANT VARCHAR2(80) := 'Zip code is not numeric.';
TGMSG_INVALIDST     CONSTANT VARCHAR2(80) := 'Invalid state code.';
TGMSG_INVALIDGRS    CONSTANT VARCHAR2(80) :=
	'CalcType = G and supplied gross amount is zero.';
TGMSG_INVALIDTAXAMT CONSTANT VARCHAR2(80) :=
	'CalcType = T and supplied tax amount is zero.';
TGMSG_GENINVZIPST   CONSTANT VARCHAR2(80) :=
	'Invalid zip code - zip code is not in range for state.';
TGMSG_INVALIDLINK  CONSTANT VARCHAR2(80) :=
	'Linkage parameters are invalid (possibly missing ENDLINK).';
TGMSG_TAXACCESSERR  CONSTANT VARCHAR2(80) := 'Error accessing Tax Master File.';
TGMSG_TAXNOTOPEN    CONSTANT VARCHAR2(80) := 'Tax file is not open.';
TGMSG_INVCALCTYP    CONSTANT VARCHAR2(80) :=
	'Calculation type is not G, T, or space.';
TGMSG_PRDACCESSERR  CONSTANT VARCHAR2(80) := 'Error accessing product file.';
TGMSG_RUNTIMEOPENERR CONSTANT VARCHAR2(80) :=
	'Error accessing TAX010 runtime files.';
TGMSG_RATEISZERO    CONSTANT VARCHAR2(80) := 'Total rate determined by TAX010 is zero.  Gross amount cannot be determined.';
TGMSG_NEGFIELDS     CONSTANT VARCHAR2(80) := 'Negative field passed to TAX010.';
TGMSG_INVALIDDTE    CONSTANT VARCHAR2(80) :=
	'Invalid date passed - defaulted to system date.';
TGMSG_APOFPO        CONSTANT VARCHAR2(80) :=
	'No taxes calculated for APO/FPO zip code.';
TGMSG_AUDACCESSERR  CONSTANT VARCHAR2(80) := 'Error accessing audit file.';
TGMSG_INVCALCERR    CONSTANT VARCHAR2(80) :=
	'Calculation error file requested but not defined in TAXSET.H';
TGMSG_CERRACCESSERR CONSTANT VARCHAR2(80) :=
	'Error accessing calculation error file.';
TGMSG_JERRACCESSERR CONSTANT VARCHAR2(80) :=
	'Error accessing jurisdiction error file.';
TGMSG_INVJURERR     CONSTANT VARCHAR2(80) :=
	'Error accessing jurisdiction error file.';
TGMSG_INVJURPROC    CONSTANT VARCHAR2(80) :=
	'Jurisdiction processing requested but not defined in TAXSET.H';
TGMSG_INVSELPARM    CONSTANT VARCHAR2(80) :=
	'Tax selection parameter was not 1, 2, 3, or space.';
TGMSG_JURISERROR    CONSTANT VARCHAR2(80) := 'A jurisdiction error has occurred.  Tax calculation will not be performed.';
TGMSG_UNKNOWN       CONSTANT VARCHAR2(80) :=
	'Unrecognized Tax Calculation general completion code: ';
TGMSG_STEPNOTOPENERR  CONSTANT VARCHAR2(80) :=
	'Error accessing STEP90 runtime files.';
TGMSG_STEPNOCUSTERR  CONSTANT VARCHAR2(80) :=
	'STEP processing requested but customer number was blank.';
TGMSG_NOSTEPPROC     CONSTANT VARCHAR2(200) := 'Either a Tax Certificate was present or CalcType = T or the transcation was a credit, NO STEP processing.';
TGMSG_STEPFILEOPENERR  CONSTANT VARCHAR2(80) :=
	'STEP OPEN was successful but the subsequent call to STEP failed.';
TGMSG_STEPPARAMERR  CONSTANT VARCHAR2(80) :=
	'One or more of STEP parameters were invalid.';
TGMSG_STEPMISCERR   CONSTANT VARCHAR2(80) :=
	'Unknown STEP Error Occurred. No further processing occurs.';
TGMSG_PRDINVALID4CU  CONSTANT VARCHAR2(80) := 'The product code passed is invalid for a Consumer Use or service transaction.';
TGMSG_NEXMERCHACCESSERR  CONSTANT VARCHAR2(80) :=
	'Company profile indexed file could not be accessed.';
TGMSG_NEXNOMERCHRECERR   CONSTANT VARCHAR2(80) :=
	'No company profile record found for Company ID passed to TAX010.';
TGMSG_NEXSTATEACCESSERR  CONSTANT VARCHAR2(80) :=
	'State nexus indexed file could not be accessed.';
TGMSG_NEXLOCALACCESSERR  CONSTANT VARCHAR2(80) :=
	'Local nexus indexed file could not be accessed.';
TGMSG_NOCOMPIDERROR      CONSTANT VARCHAR2(80) := 'No Company ID was passed.';
TGMSG_NEXPRONOTOPENERR   CONSTANT VARCHAR2(80) :=
	'Nexus data files could not be opened.';
TGMSG_NOSTATENEXRECERR   CONSTANT VARCHAR2(80) := 'No state nexus record found.';
TGMSG_NEXPRONOTCLOSEERR  CONSTANT VARCHAR2(80) :=
	'Nexus data files could not be closed.';
TGMSG_CONUSEFILEERR      CONSTANT VARCHAR2(80) :=
	'Consumer use file could not be accessed.';
TGMSG_PRDINVALID4SERV    CONSTANT VARCHAR2(80) :=
	'Product code invalid for service.';
TGMSG_CALC_E_ERROR       CONSTANT VARCHAR2(80) :=
	'Error in calculation type E processing.';
TGMSG_EXEMPTLGRGROSS     CONSTANT VARCHAR2(80) :=
	'Exempt amount larger than gross plus exempt.' ;
TGMSG_AMOUNTOVERFLOW     CONSTANT VARCHAR2(80) := 'Amount passed exceeds the maximum value that can be stored in the audit file.';
TGMSG_PRODCONVNOTOPEN    CONSTANT VARCHAR2(80) :=
	'Product conversion files could not be opened.';
TGMSG_PRODCDCONVNOTFOUND CONSTANT VARCHAR2(80) :=
	'Product conversion files could not be found.';
TGMSG_PRODCONVCLOSEERR   CONSTANT VARCHAR2(80) :=
	'Error while closing product conversion files.';

--
-- Location Specific Tax Calculation error messages
-- Note: Since all these completion codes indicate warning, These
-- 	 completion codes are not trapped. Future use.
--
TMSG_INVTAXIND 		 CONSTANT VARCHAR2(80) :=
	'Sales/use tax indicator not valid, defaulted to sales tax.';
TMSG_OVRRDERATE     CONSTANT VARCHAR2(80) :=
	'Used override rate for calculation.';
TMSG_OVRRDEAMT      CONSTANT VARCHAR2(80) :=
	'Used override amount for calculation.';
TMSG_NOTAXIND       CONSTANT VARCHAR2(80) :=
	'Used no tax indicator for calculation.';
TMSG_PRODRATE       CONSTANT VARCHAR2(80) :=
	'Used product code rate to calculate taxes.';
TMSG_PRODMAXUSE     CONSTANT VARCHAR2(80) := 'The product file rates used to calculate taxes were adjusted per max tax.';
TMSG_PRODMAXINV     CONSTANT VARCHAR2(80) :=
	'Product file rates were used to calculate taxes.';
TMSG_MAXADJUST      CONSTANT VARCHAR2(80) :=
	'Taxes adjusted per product maximum tax laws.';
TMSG_NITEM_INCOMPAT_MAX CONSTANT VARCHAR2(80) :=
	'Number of items is not compatible with maximum tax laws.';
TMSG_DEFAULT_CURRENT CONSTANT VARCHAR2(80) :=
	'Invoice date is before prior date on file - used current rate.';
TMSG_NO_TAXES     CONSTANT VARCHAR2(80) := 'Administration code is 2 - taxes not calculated for this location type.';
TMSG_STATE_TAX_ONLY CONSTANT VARCHAR2(80) := 'State administration is 3 - taxes not calculated for this location type.';
TMSG_STATE_FED_USE_ONLY CONSTANT VARCHAR2(80) := 'Administration code is 4 - use taxes not calculated for this location type';
TMSG_STATE_FED_SALES_ONLY CONSTANT VARCHAR2(80) := 'Administration code is 5 - sales taxes not calculated for this location type';
TMSG_CITY_DEFAULT    CONSTANT VARCHAR2(80) := 'Used county code/defaulted to most likely city.';
TMSG_CNLO_NO_TAXES   CONSTANT VARCHAR2(80) := 'Administration code is 2 - taxes not calculated.';
TMSG_CNLO_USE_ONLY CONSTANT VARCHAR2(80) := 'Administration code is 3 - use taxes not calculated.';
TMSG_CNLO_SALES_ONLY CONSTANT VARCHAR2(80) := 'Administration code is 4 - sales taxes not calculated.';
TMSG_CNLO_NOTAXFORZP CONSTANT VARCHAR2(80) := 'This state has city/town taxes but not for this zip. no taxes calculated';
TMSG_UNKNOWN         CONSTANT VARCHAR2(80) := 'Unrecognized location completion code: ';
--
-- Generic Jurisdiction error messages
--
JGMSG_JURSUCCESS     CONSTANT VARCHAR2(80) := 'Jurisdiction processing completed successfully.';
JGMSG_JURINVPOT   CONSTANT VARCHAR2(80) := 'Invalid POT (Not O or D).';
JGMSG_JURINVSRVIN CONSTANT VARCHAR2(80) := 'Invalid service indicator (not S, R, or space).';
JGMSG_JURERROR    CONSTANT VARCHAR2(80) := 'Jurisdiction error.';
--
-- Location Specific Jurisdiction error messages
--
JMSG_LOCCNTYDEF   CONSTANT VARCHAR2(80) := 'Defaulted to system county code.';
JMSG_LOCINVSTATE  CONSTANT VARCHAR2(80) := 'Invalid state code.';
JMSG_LOCNOZIP     CONSTANT VARCHAR2(80) := 'Zip code was not supplied.';
JMSG_LOCINVZIP    CONSTANT VARCHAR2(80) := 'Invalid zip code.';
JMSG_LOCNOGEO     CONSTANT VARCHAR2(80) := 'The city or geo code was not supplied.';
JMSG_LOCINVCITY   CONSTANT VARCHAR2(80) := 'City code is spaces or not numeric.';
JMSG_UNKNOWN      CONSTANT VARCHAR2(80) := 'Unrecognized Jurisdiction location completion code: ';

/*------------------------------------------------
|         Global Variables                        |
 ------------------------------------------------*/
 C_LINES_PER_COMMIT CONSTANT NUMBER := 1000;
 I Number;  --Index Variable.
 g_line_level_action varchar2(20);
 l_document_type zx_lines_det_factors.event_class_code%type;
-- PG_DEBUG varchar2(1);
-- x_return_status varchar2(20);

/* ======================================================================*
 | Data Type Definitions                                                 |
 * ======================================================================*/

   type char_tab is table of char       index by binary_integer;
   type num_tab  is table of number(15) index by binary_integer;
   type num1_tab is table of number     index by binary_integer;
   type date_tab is table of date       index by binary_integer;
   type var1_tab is table of varchar2(1)    index by binary_integer;
   type var2_tab is table of varchar2(80)   index by binary_integer;
   type var3_tab is table of varchar2(2000) index by binary_integer;
   type var4_tab is table of varchar2(150)  index by binary_integer;
   type var5_tab is table of varchar2(240)  index by binary_integer;


   /*Private Procedures*/
   PROCEDURE PERFORM_VALIDATE(X_RETURN_STATUS  OUT NOCOPY VARCHAR2);
   PROCEDURE PERFORM_LINE_CREATION(p_tax_lines_tbl     OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
				   p_currency_tab   IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
				   X_RETURN_STATUS  OUT NOCOPY VARCHAR2);
   PROCEDURE PERFORM_LINE_DELETION (X_RETURN_STATUS OUT NOCOPY VARCHAR2);
   PROCEDURE PERFORM_UPDATE       (p_tax_lines_tbl     OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
				   p_currency_tab   IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
				   X_RETURN_STATUS  OUT NOCOPY VARCHAR2);
   FUNCTION SET_PARAMETERS(
	l_Tax_Link 	IN OUT NOCOPY zx_tax_taxware_GEN.TaxParm,
	l_JurLink 	IN OUT NOCOPY zx_tax_taxware_GEN.JurParm,
	l_OraLink       IN OUT NOCOPY zx_tax_taxware_GEN.t_OraParm) RETURN BOOLEAN;
   FUNCTION  CALCULATE_TAX(
	l_TaxLink 	IN OUT NOCOPY zx_tax_taxware_GEN.TaxParm,
	l_JurLink 	IN OUT NOCOPY zx_tax_taxware_GEN.JurParm,
	l_OraLink       IN OUT NOCOPY zx_tax_taxware_GEN.t_OraParm) RETURN BOOLEAN;
   PROCEDURE TAX_RESULTS_PROCESSING(
	p_tax_lines_tbl    OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
	p_currency_tab  IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
	l_TaxLink 	IN OUT NOCOPY  zx_tax_taxware_GEN.TaxParm,
	l_JurLink 	IN OUT NOCOPY  zx_tax_taxware_GEN.JurParm,
	l_OraLink       IN OUT NOCOPY  zx_tax_taxware_GEN.t_OraParm,
	X_RETURN_STATUS  OUT NOCOPY VARCHAR2);

   PROCEDURE SET_DOCUMENT_TYPE( P_DOCUMENT_TYPE IN OUT NOCOPY VARCHAR2,
				P_ADJ_DOC_TRX_ID IN NUMBER,
				P_LINE_AMOUNT IN NUMBER,
				X_RETURN_STATUS  OUT NOCOPY VARCHAR2);

   PROCEDURE ERROR_EXCEPTION_HANDLE(P_ERROR_STRING VARCHAR2);
   PROCEDURE INITIALIZE;
   PROCEDURE STACK_ERROR
	(p_msgname IN    VARCHAR2,
         p_token1  IN    VARCHAR2 ,
         p_value1  IN    VARCHAR2 ,
         p_token2  IN    VARCHAR2 ,
         p_value2  IN    VARCHAR2  );
   PROCEDURE GET_VENDOR_ERROR(
	tax_selection 	IN	ZX_TAX_TAXWARE_GEN.SELPARMTYP%TYPE,
	errTaxParm	IN	ZX_TAX_TAXWARE_GEN.TaxParm,
	errJurParm	IN	ZX_TAX_TAXWARE_GEN.JurParm );

   PROCEDURE dump_vendor_rec ( dmpTaxLink  IN  	ZX_TAX_TAXWARE_GEN.TaxParm,
                               dmpJurLink  IN 	ZX_TAX_TAXWARE_GEN.JurParm,
                               dmpOraLink  IN   ZX_TAX_TAXWARE_GEN.t_OraParm,
			       input_param_flag IN  	BOOLEAN  ) ;


    /*Structure to hold the transaction information*/

pg_internal_org_id_tab			num1_tab;
pg_doc_type_id_tab     			num1_tab;
pg_trx_id_tab				num1_tab;
pg_appli_code_tab			var2_tab;
pg_doc_level_action_tab			var2_tab;
pg_trx_date_tab				date_tab;
pg_trx_curr_code_tab			var2_tab;
/* Bug 5090593:
pg_quote_flag_tab			var1_tab;
*/
pg_legal_entity_num_tab 		var2_tab;
pg_esta_name_tab			var3_tab;
pg_Trx_number_tab			var4_tab;
pg_Trx_desc_tab				var3_tab;
pg_doc_sequence_value_tab		var3_tab;
pg_Trx_due_date_tab			date_tab;
/* Bug 5090593:
pg_Trx_Sol_Ori_tab			var2_tab;
*/
pg_Allow_Tax_Calc_tab			var1_tab;
pg_trx_line_id_tab			num1_tab;
pg_trx_level_type_tab			var2_tab;
pg_line_level_action_tab		var2_tab;
pg_line_class_tab			var2_tab;
pg_trx_shipping_date_tab		date_tab;
pg_trx_receipt_date_tab			date_tab;
pg_trx_line_type_tab			var2_tab;
pg_trx_line_date_tab			date_tab;
pg_trx_business_cat_tab			var3_tab;
pg_line_intended_use_tab		var3_tab;
pg_line_amt_incl_tax_flag_tab		var1_tab;
pg_line_amount_tab			num1_tab;
pg_other_incl_tax_amt_tab		num1_tab;
pg_trx_line_qty_tab			num1_tab;
pg_unit_price_tab			num1_tab;
pg_cash_discount_tab			num1_tab;
pg_volume_discount_tab			num1_tab;
pg_trading_discount_tab			num1_tab;
pg_trans_charge_tab			num1_tab;
pg_ins_charge_tab			num1_tab;
pg_other_charge_tab			num1_tab;
pg_prod_id_tab				num1_tab;
pg_uom_code_tab				var2_tab;
pg_prod_type_tab			var3_tab;
pg_prod_code_tab			var2_tab;
pg_fob_point_tab			var2_tab;
pg_ship_to_pty_numr_tab			var2_tab;
pg_ship_to_pty_name_tab			var3_tab;
pg_ship_from_pty_num_tab		var2_tab;
pg_ship_from_pty_name_tab		var3_tab;
pg_ship_to_loc_id_tab                   num1_tab;      -- Bug 5090593
Pg_ship_to_grphy_type1_tab          	var5_tab;
pg_ship_to_grphy_value1_tab     	var5_tab;
pg_ship_to_grphy_type2_tab      	var5_tab;
pg_ship_to_grphy_value2_tab     	var5_tab;
pg_ship_to_grphy_type3_tab      	var5_tab;
pg_ship_to_grphy_value3_tab     	var5_tab;
pg_ship_to_grphy_type4_tab      	var5_tab;
pg_ship_to_grphy_value4_tab     	var5_tab;
pg_ship_to_grphy_type5_tab      	var5_tab;
pg_ship_to_grphy_value5_tab     	var5_tab;
pg_ship_to_grphy_type6_tab      	var5_tab;
pg_ship_to_grphy_value6_tab     	var5_tab;
pg_ship_to_grphy_type7_tab      	var5_tab;
pg_ship_to_grphy_value7_tab     	var5_tab;
pg_ship_to_grphy_type8_tab      	var5_tab;
pg_ship_to_grphy_value8_tab     	var5_tab;
pg_ship_to_grphy_type9_tab      	var5_tab;
pg_ship_to_grphy_value9_tab     	var5_tab;
pg_ship_to_grphy_type10_tab     	var5_tab;
pg_ship_to_grphy_value10_tab    	var5_tab;
pg_ship_fr_loc_id_tab                   num1_tab;      -- Bug 5090593
pg_ship_fr_grphy_type1_tab      	var5_tab;
pg_ship_fr_grphy_value1_tab     	var5_tab;
pg_ship_fr_grphy_type2_tab      	var5_tab;
pg_ship_fr_grphy_value2_tab     	var5_tab;
pg_ship_fr_grphy_type3_tab      	var5_tab;
pg_ship_fr_grphy_value3_tab     	var5_tab;
pg_ship_fr_grphy_type4_tab      	var5_tab;
pg_ship_fr_grphy_value4_tab     	var5_tab;
pg_ship_fr_grphy_type5_tab      	var5_tab;
pg_ship_fr_grphy_value5_tab     	var5_tab;
pg_ship_fr_grphy_type6_tab      	var5_tab;
pg_ship_fr_grphy_value6_tab     	var5_tab;
pg_ship_fr_grphy_type7_tab      	var5_tab;
pg_ship_fr_grphy_value7_tab     	var5_tab;
pg_ship_fr_grphy_type8_tab      	var5_tab;
pg_ship_fr_grphy_value8_tab     	var5_tab;
pg_ship_fr_grphy_type9_tab      	var5_tab;
pg_ship_fr_grphy_value9_tab     	var5_tab;
pg_ship_fr_grphy_type10_tab     	var5_tab;
pg_ship_fr_grphy_value10_tab    	var5_tab;
pg_poa_loc_id_tab                       num1_tab;      -- Bug 5090593
pg_poa_grphy_type1_tab          	var5_tab;
pg_poa_grphy_value1_tab         	var5_tab;
pg_poa_grphy_type2_tab          	var5_tab;
pg_poa_grphy_value2_tab         	var5_tab;
pg_poa_grphy_type3_tab          	var5_tab;
pg_poa_grphy_value3_tab         	var5_tab;
pg_poa_grphy_type4_tab          	var5_tab;
pg_poa_grphy_value4_tab         	var5_tab;
pg_poa_grphy_type5_tab          	var5_tab;
pg_poa_grphy_value5_tab         	var5_tab;
pg_poa_grphy_type6_tab          	var5_tab;
pg_poa_grphy_value6_tab         	var5_tab;
pg_poa_grphy_type7_tab          	var5_tab;
pg_poa_grphy_value7_tab         	var5_tab;
pg_poa_grphy_type8_tab          	var5_tab;
pg_poa_grphy_value8_tab         	var5_tab;
pg_poa_grphy_type9_tab          	var5_tab;
pg_poa_grphy_value9_tab         	var5_tab;
pg_poa_grphy_type10_tab         	var5_tab;
pg_poa_grphy_value10_tab        	var5_tab;
pg_poo_loc_id_tab                       num1_tab;      -- Bug 5090593
pg_poo_grphy_type1_tab          	var5_tab;
pg_poo_grphy_value1_tab         	var5_tab;
pg_poo_grphy_type2_tab          	var5_tab;
pg_poo_grphy_value2_tab         	var5_tab;
pg_poo_grphy_type3_tab          	var5_tab;
pg_poo_grphy_value3_tab         	var5_tab;
pg_poo_grphy_type4_tab          	var5_tab;
pg_poo_grphy_value4_tab         	var5_tab;
pg_poo_grphy_type5_tab          	var5_tab;
pg_poo_grphy_value5_tab         	var5_tab;
pg_poo_grphy_type6_tab          	var5_tab;
pg_poo_grphy_value6_tab         	var5_tab;
pg_poo_grphy_type7_tab          	var5_tab;
pg_poo_grphy_value7_tab         	var5_tab;
pg_poo_grphy_type8_tab          	var5_tab;
pg_poo_grphy_value8_tab         	var5_tab;
pg_poo_grphy_type9_tab          	var5_tab;
pg_poo_grphy_value9_tab         	var5_tab;
pg_poo_grphy_type10_tab         	var5_tab;
pg_poo_grphy_value10_tab        	var5_tab;
pg_bill_to_pty_num_tab			var2_tab;
pg_bill_to_pty_name_tab			var3_tab;
pg_bill_from_pty_num_tab		var2_tab;
pg_bill_from_pty_name_tab		var3_tab;
pg_bill_to_loc_id_tab                   num1_tab;      -- Bug 5090593
pg_bill_to_grphy_type1_tab      	var5_tab;
pg_bill_to_grphy_value1_tab     	var5_tab;
pg_bill_to_grphy_type2_tab      	var5_tab;
pg_bill_to_grphy_value2_tab     	var5_tab;
pg_bill_to_grphy_type3_tab      	var5_tab;
pg_bill_to_grphy_value3_tab     	var5_tab;
pg_bill_to_grphy_type4_tab      	var5_tab;
pg_bill_to_grphy_value4_tab     	var5_tab;
pg_bill_to_grphy_type5_tab      	var5_tab;
pg_bill_to_grphy_value5_tab     	var5_tab;
pg_bill_to_grphy_type6_tab      	var5_tab;
pg_bill_to_grphy_value6_tab     	var5_tab;
pg_bill_to_grphy_type7_tab      	var5_tab;
pg_bill_to_grphy_value7_tab     	var5_tab;
pg_bill_to_grphy_type8_tab      	var5_tab;
pg_bill_to_grphy_value8_tab     	var5_tab;
pg_bill_to_grphy_type9_tab      	var5_tab;
pg_bill_to_grphy_value9_tab     	var5_tab;
pg_bill_to_grphy_type10_tab     	var5_tab;
pg_bill_to_grphy_value10_tab    	var5_tab;
pg_bill_fr_loc_id_tab                   num1_tab;      -- Bug 5090593
pg_bill_fr_grphy_type1_tab      	var5_tab;
pg_bill_fr_grphy_value1_tab     	var5_tab;
pg_bill_fr_grphy_type2_tab      	var5_tab;
pg_bill_fr_grphy_value2_tab     	var5_tab;
pg_bill_fr_grphy_type3_tab      	var5_tab;
pg_bill_fr_grphy_value3_tab     	var5_tab;
pg_bill_fr_grphy_type4_tab      	var5_tab;
pg_bill_fr_grphy_value4_tab     	var5_tab;
pg_bill_fr_grphy_type5_tab      	var5_tab;
pg_bill_fr_grphy_value5_tab     	var5_tab;
pg_bill_fr_grphy_type6_tab      	var5_tab;
pg_bill_fr_grphy_value6_tab     	var5_tab;
pg_bill_fr_grphy_type7_tab      	var5_tab;
pg_bill_fr_grphy_value7_tab     	var5_tab;
pg_bill_fr_grphy_type8_tab      	var5_tab;
pg_bill_fr_grphy_value8_tab     	var5_tab;
pg_bill_fr_grphy_type9_tab      	var5_tab;
pg_bill_fr_grphy_value9_tab     	var5_tab;
pg_bill_fr_grphy_type10_tab     	var5_tab;
pg_bill_fr_grphy_value10_tab    	var5_tab;
pg_account_ccid_tab			num1_tab;
pg_appl_fr_doc_type_id_tab		num1_tab;
pg_appl_from_trx_id_tab			num1_tab;
pg_appl_from_line_id_tab		num1_tab;
pg_appl_fr_trx_lev_type_tab		var2_tab;
pg_appl_from_doc_num_tab		var2_tab;
pg_adj_doc_doc_type_id_tab		num1_tab;
pg_adj_doc_trx_id_tab			num1_tab;
pg_adj_doc_line_id_tab			num1_tab;
pg_adj_doc_number_tab			var2_tab;
pg_ADJ_doc_trx_lev_type_tab		var2_tab;
pg_adj_doc_date_tab			date_tab;
pg_assess_value_tab			num1_tab;
pg_trx_line_number_tab			num1_tab;
pg_trx_line_desc_tab			var3_tab;
pg_prod_desc_tab			var3_tab;
pg_header_char1_tab			var4_tab;
pg_header_char2_tab			var4_tab;
pg_header_char3_tab			var4_tab;
pg_header_char4_tab			var4_tab;
pg_header_char5_tab			var4_tab;
pg_header_char6_tab			var4_tab;
pg_header_char7_tab			var4_tab;
pg_header_char8_tab			var4_tab;
pg_header_char9_tab			var4_tab;
pg_header_char10_tab			var4_tab;
pg_header_char11_tab			var4_tab;
pg_header_char12_tab			var4_tab;
pg_header_char13_tab			var4_tab;
pg_header_char14_tab			var4_tab;
pg_header_char15_tab			var4_tab;
pg_header_numeric1_tab			num1_tab;
pg_header_numeric2_tab			num1_tab;
pg_header_numeric3_tab			num1_tab;
pg_header_numeric4_tab			num1_tab;
pg_header_numeric5_tab			num1_tab;
pg_header_numeric6_tab			num1_tab;
pg_header_numeric7_tab			num1_tab;
pg_header_numeric8_tab			num1_tab;
pg_header_numeric9_tab			num1_tab;
pg_header_numeric10_tab			num1_tab;
pg_header_date1_tab			date_tab;
pg_header_date2_tab			date_tab;
pg_header_date3_tab			date_tab;
pg_header_date4_tab			date_tab;
pg_header_date5_tab			date_tab;
pg_line_char1_tab			var4_tab;
pg_line_char2_tab			var4_tab;
pg_line_char3_tab			var4_tab;
pg_line_char4_tab			var4_tab;
pg_line_char5_tab			var4_tab;
pg_line_char6_tab			var4_tab;
pg_line_char7_tab			var4_tab;
pg_line_char8_tab			var4_tab;
pg_line_char9_tab			var4_tab;
pg_line_char10_tab			var4_tab;
pg_line_char11_tab			var4_tab;
pg_line_char12_tab			var4_tab;
pg_line_char13_tab			var4_tab;
pg_line_char14_tab			var4_tab;
pg_line_char15_tab			var4_tab;
pg_line_char16_tab			var4_tab;
pg_line_char17_tab			var4_tab;
pg_line_char18_tab			var4_tab;
pg_line_char19_tab			var4_tab;
pg_line_char20_tab			var4_tab;
pg_line_char21_tab			var4_tab;
pg_line_char22_tab			var4_tab;
pg_line_char23_tab			var4_tab;
pg_line_char24_tab			var4_tab;
pg_line_char25_tab			var4_tab;
pg_line_char26_tab			var4_tab;
pg_line_char27_tab			var4_tab;
pg_line_char28_tab			var4_tab;
pg_line_char29_tab			var4_tab;
pg_line_char30_tab			var4_tab;
pg_line_numeric1_tab			num1_tab;
pg_line_numeric2_tab			num1_tab;
pg_line_numeric3_tab			num1_tab;
pg_line_numeric4_tab			num1_tab;
pg_line_numeric5_tab			num1_tab;
pg_line_numeric6_tab			num1_tab;
pg_line_numeric7_tab			num1_tab;
pg_line_numeric8_tab			num1_tab;
pg_line_numeric9_tab			num1_tab;
pg_line_numeric10_tab			num1_tab;
pg_line_date1_tab			date_tab;
pg_line_date2_tab			date_tab;
pg_line_date3_tab			date_tab;
pg_line_date4_tab			date_tab;
pg_line_date5_tab			date_tab;
pg_exempt_certi_numb_tab		var2_tab;
pg_exempt_reason_tab			var3_tab;
pg_exempt_cont_flag_tab			var2_tab;
pg_ugraded_inv_flag_tab                 var1_tab;


PROCEDURE CALCULATE_TAX_API
       (p_currency_tab        IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
	x_tax_lines_tbl          OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
	x_error_status           OUT NOCOPY VARCHAR2,
	x_messages_tbl           OUT NOCOPY ZX_TAX_PARTNER_PKG.messages_tbl_type) is
    l_rel_ret_code Varchar2(20);
    Cursor item_lines_to_be_processed is
     select
	internal_organization_id               ,
	document_type_id                       ,
	transaction_id                         ,
	application_code                       ,
	document_level_action                  ,
	trx_date                               ,
	trx_currency_code                      ,
/* Bug 5090593:
	quote_flag			       ,
*/
	legal_entity_number                    ,
	establishment_number                     ,
	transaction_number                     ,
	transaction_description                ,
	document_sequence_value                ,
	transaction_due_date                   ,
/* Bug 5090593:
	transaction_solution_origin            ,
*/
	allow_tax_calculation                  ,
	transaction_line_id                    ,
	trx_level_type                         ,
	line_level_action                      ,
	line_class                             ,
	transaction_shipping_date              ,
	transaction_receipt_date               ,
	transaction_line_type                  ,
	transaction_line_date                  ,
	trx_business_category                  ,
	line_intended_use                      ,
	line_amt_includes_tax_flag             ,
	line_amount                            ,
	other_inclusive_tax_amount             ,
	transaction_line_quantity              ,
	unit_price                             ,
	cash_discount                          ,
	volume_discount                        ,
	trading_discount                       ,
	transportation_charge                  ,
	insurance_charge                       ,
	other_charge                           ,
	product_id                             ,
	uom_code                               ,
	product_type                           ,
	product_code                           ,
	fob_point                              ,
	ship_to_party_number                   ,
	ship_to_party_name                     ,
	ship_from_party_number                 ,
	ship_from_party_name                   ,
	ship_to_loc_id                         ,     -- Bug 5090593
	ship_to_geography_type1                ,
	ship_to_geography_value1               ,
	ship_to_geography_type2                ,
	ship_to_geography_value2               ,
	ship_to_geography_type3                ,
	ship_to_geography_value3               ,
	ship_to_geography_type4                ,
	ship_to_geography_value4               ,
	ship_to_geography_type5                ,
	ship_to_geography_value5               ,
	ship_to_geography_type6                ,
	ship_to_geography_value6               ,
	ship_to_geography_type7                ,
	ship_to_geography_value7               ,
	ship_to_geography_type8                ,
	ship_to_geography_value8               ,
	ship_to_geography_type9                ,
	ship_to_geography_value9               ,
	ship_to_geography_type10               ,
	ship_to_geography_value10              ,
	ship_from_loc_id                       ,     -- Bug 5090593
	ship_from_geography_type1              ,
	ship_from_geography_value1             ,
	ship_from_geography_type2              ,
	ship_from_geography_value2             ,
	ship_from_geography_type3              ,
	ship_from_geography_value3             ,
	ship_from_geography_type4              ,
	ship_from_geography_value4             ,
	ship_from_geography_type5              ,
	ship_from_geography_value5             ,
	ship_from_geography_type6              ,
	ship_from_geography_value6             ,
	ship_from_geography_type7              ,
	ship_from_geography_value7             ,
	ship_from_geography_type8              ,
	ship_from_geography_value8             ,
	ship_from_geography_type9              ,
	ship_from_geography_value9             ,
	ship_from_geography_type10             ,
	ship_from_geography_value10            ,
	poa_loc_id                             ,     -- Bug 5090593
	poa_geography_type1                    ,
	poa_geography_value1                   ,
	poa_geography_type2                    ,
	poa_geography_value2                   ,
	poa_geography_type3                    ,
	poa_geography_value3                   ,
	poa_geography_type4                    ,
	poa_geography_value4                   ,
	poa_geography_type5                    ,
	poa_geography_value5                   ,
	poa_geography_type6                    ,
	poa_geography_value6                   ,
	poa_geography_type7                    ,
	poa_geography_value7                   ,
	poa_geography_type8                    ,
	poa_geography_value8                   ,
	poa_geography_type9                    ,
	poa_geography_value9                   ,
	poa_geography_type10                   ,
	poa_geography_value10                  ,
	poo_loc_id                             ,     -- Bug 5090593
	poo_geography_type1                    ,
	poo_geography_value1                   ,
	poo_geography_type2                    ,
	poo_geography_value2                   ,
	poo_geography_type3                    ,
	poo_geography_value3                   ,
	poo_geography_type4                    ,
	poo_geography_value4                   ,
	poo_geography_type5                    ,
	poo_geography_value5                   ,
	poo_geography_type6                    ,
	poo_geography_value6                   ,
	poo_geography_type7                    ,
	poo_geography_value7                   ,
	poo_geography_type8                    ,
	poo_geography_value8                   ,
	poo_geography_type9                    ,
	poo_geography_value9                   ,
	poo_geography_type10                   ,
	poo_geography_value10                  ,
	bill_to_party_number                   ,
	bill_to_party_name                     ,
	bill_from_party_number                 ,
	bill_from_party_name                   ,
	bill_to_loc_id                         ,     -- Bug 5090593
	bill_to_geography_type1                ,
	bill_to_geography_value1               ,
	bill_to_geography_type2                ,
	bill_to_geography_value2               ,
	bill_to_geography_type3                ,
	bill_to_geography_value3               ,
	bill_to_geography_type4                ,
	bill_to_geography_value4               ,
	bill_to_geography_type5                ,
	bill_to_geography_value5               ,
	bill_to_geography_type6                ,
	bill_to_geography_value6               ,
	bill_to_geography_type7                ,
	bill_to_geography_value7               ,
	bill_to_geography_type8                ,
	bill_to_geography_value8               ,
	bill_to_geography_type9                ,
	bill_to_geography_value9               ,
	bill_to_geography_type10               ,
	bill_to_geography_value10              ,
	bill_from_loc_id                       ,     -- Bug 5090593
	bill_from_geography_type1              ,
	bill_from_geography_value1             ,
	bill_from_geography_type2              ,
	bill_from_geography_value2             ,
	bill_from_geography_type3              ,
	bill_from_geography_value3             ,
	bill_from_geography_type4              ,
	bill_from_geography_value4             ,
	bill_from_geography_type5              ,
	bill_from_geography_value5             ,
	bill_from_geography_type6              ,
	bill_from_geography_value6             ,
	bill_from_geography_type7              ,
	bill_from_geography_value7             ,
	bill_from_geography_type8              ,
	bill_from_geography_value8             ,
	bill_from_geography_type9              ,
	bill_from_geography_value9             ,
	bill_from_geography_type10             ,
	bill_from_geography_value10            ,
	account_ccid                           ,
	applied_from_document_type_id          ,
	applied_from_transaction_id            ,
	applied_from_line_id                   ,
	applied_from_trx_level_type,
	applied_from_doc_number                ,
	adjusted_doc_document_type_id          ,
	adjusted_doc_transaction_id            ,
	adjusted_doc_line_id                   ,
	adjusted_doc_number                    ,
	adjusted_doc_trx_level_type,
	adjusted_doc_date                      ,
	assessable_value                       ,
	trx_line_number                        ,
	trx_line_description                   ,
	product_description                    ,
	header_char1                           ,
	header_char2                           ,
	header_char3                           ,
	header_char4                           ,
	header_char5                           ,
	header_char6                           ,
	header_char7                           ,
	header_char8                           ,
	header_char9                           ,
	header_char10                          ,
	header_char11                          ,
	header_char12                          ,
	header_char13                          ,
	header_char14                          ,
	header_char15                          ,
	header_numeric1                        ,
	header_numeric2                        ,
	header_numeric3                        ,
	header_numeric4                        ,
	header_numeric5                        ,
	header_numeric6                        ,
	header_numeric7                        ,
	header_numeric8                        ,
	header_numeric9                        ,
	header_numeric10                       ,
	header_date1                           ,
	header_date2                           ,
	header_date3                           ,
	header_date4                           ,
	header_date5                           ,
	line_char1                             ,
	line_char2                             ,
	line_char3                             ,
	line_char4                             ,
	line_char5                             ,
	line_char6                             ,
	line_char7                             ,
	line_char8                             ,
	line_char9                             ,
	line_char10                            ,
	line_char11                            ,
	line_char12                            ,
	line_char13                            ,
	line_char14                            ,
	line_char15                            ,
	line_char16                             ,
	line_char17                            ,
	line_char18                            ,
	line_char19                            ,
	line_char20                             ,
	line_char21                             ,
	line_char22                            ,
	line_char23                            ,
	line_char24                             ,
	line_char25                            ,
	line_char26                            ,
	line_char27                            ,
	line_char28                            ,
	line_char29                            ,
	line_char30                            ,
	line_numeric1                          ,
	line_numeric2                          ,
	line_numeric3                          ,
	line_numeric4                          ,
	line_numeric5                          ,
	line_numeric6                          ,
	line_numeric7                          ,
	line_numeric8                          ,
	line_numeric9                          ,
	line_numeric10                         ,
	line_date1                             ,
	line_date2                             ,
	line_date3                             ,
	line_date4                             ,
	line_date5                             ,
	exempt_certificate_number              ,
	exempt_reason                          ,
	exemption_control_flag
     From ZX_O2C_CALC_TXN_INPUT_V;

   l_api_name           CONSTANT VARCHAR2(30) := 'CALCULATE_TAX_API';
   l_return_status varchar2(30);
   ptr number;
   cnt_end NUMBER;
   cnt            NUMBER := 1;
   l_tax_lines_tbl ZX_TAX_PARTNER_PKG.tax_lines_tbl_type;
 Begin
        IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
        END IF;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	   ' zx_tax_partner_pkg.G_BUSINESS_FLOW = ' || zx_tax_partner_pkg.G_BUSINESS_FLOW);
        END IF;
   	IF zx_tax_partner_pkg.G_BUSINESS_FLOW = 'O2C' THEN
	    --  Verify the integration with the version of Taxware product is certified.
	   Begin
	       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
		'Calling ZX_TAX_TAXWARE_REV.GET_RELEASE Verify the integration
		  with the version of Taxware product is certified' );
                END IF;
        	l_rel_ret_code := ZX_TAX_TAXWARE_REV.GET_RELEASE;
		if l_rel_ret_code = ZX_TAXWARE_TAX_SERVICE_PKG.NOT_VALID_VERSION then
			Raise VERSION_ERROR;
		end if;
	   Exception
	  	When VERSION_ERROR then
			IF (g_level_exception >= g_current_runtime_level ) THEN
			  FND_LOG.STRING(g_level_exception,
				  G_PKG_NAME||'.'||l_api_name,'Current Taxware version is imcompaitable with Oracle Apps');
			END IF;
			x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
			g_string :='Call to ZX_TAX_TAXWARE_REV.GET_RELEASE failed with exception';
			error_exception_handle(g_string);
			x_messages_tbl:=g_messages_tbl;
			return;
  	   End;

	ELSE
	    --Release 12 Old tax partner integration does not support P2P products;
	    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
		'Release 12 Old tax partner integration does not support P2P products' );
            END IF;
            x_error_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('ZX', 'ZX_FLOW_NOT_SUPPORTED_4_PTNR');
            FND_MESSAGE.SET_TOKEN('BUSINESS_FLOW',zx_tax_partner_pkg.G_BUSINESS_FLOW);
            FND_MESSAGE.SET_TOKEN('SERVICE_PROVIDER','TAXWARE');
	    Raise WRONG_BUSINESS_FLOW;
	END IF;

    open item_lines_to_be_processed;
    fetch item_lines_to_be_processed
     bulk collect into
		pg_internal_org_id_tab		,
		pg_doc_type_id_tab		,
		pg_trx_id_tab			,
		pg_appli_code_tab		,
		pg_doc_level_action_tab		,
		pg_trx_date_tab			,
		pg_trx_curr_code_tab		,
/* Bug 5090593:
		pg_quote_flag_tab		,
*/
		pg_legal_entity_num_tab		,
		pg_esta_name_tab		,
		pg_trx_number_tab		,
		pg_trx_desc_tab			,
		pg_doc_sequence_value_tab	,
		pg_trx_due_date_tab		,
/* Bug 5090593:
		pg_trx_sol_ori_tab		,
*/
		pg_allow_tax_calc_tab		,
		pg_trx_line_id_tab		,
		pg_trx_level_type_tab		,
		pg_line_level_action_tab	,
		pg_line_class_tab		,
		pg_trx_shipping_date_tab	,
		pg_trx_receipt_date_tab		,
		pg_trx_line_type_tab		,
		pg_trx_line_date_tab		,
		pg_trx_business_cat_tab		,
		pg_line_intended_use_tab	,
		pg_line_amt_incl_tax_flag_tab	,
		pg_line_amount_tab		,
		pg_other_incl_tax_amt_tab	,
		pg_trx_line_qty_tab		,
		pg_unit_price_tab		,
		pg_cash_discount_tab		,
		pg_volume_discount_tab		,
		pg_trading_discount_tab		,
		pg_trans_charge_tab		,
		pg_ins_charge_tab		,
		pg_other_charge_tab		,
		pg_prod_id_tab			,
		pg_uom_code_tab			,
		pg_prod_type_tab		,
		pg_prod_code_tab		,
		pg_fob_point_tab		,
		pg_ship_to_pty_numr_tab		,
		pg_ship_to_pty_name_tab		,
		pg_ship_from_pty_num_tab	,
		pg_ship_from_pty_name_tab	,
		pg_ship_to_loc_id_tab           ,    -- Bug 5090593
		pg_ship_to_grphy_type1_tab      ,
		pg_ship_to_grphy_value1_tab     ,
		pg_ship_to_grphy_type2_tab      ,
		pg_ship_to_grphy_value2_tab     ,
		pg_ship_to_grphy_type3_tab      ,
		pg_ship_to_grphy_value3_tab     ,
		pg_ship_to_grphy_type4_tab      ,
		pg_ship_to_grphy_value4_tab     ,
		pg_ship_to_grphy_type5_tab      ,
		pg_ship_to_grphy_value5_tab     ,
		pg_ship_to_grphy_type6_tab      ,
		pg_ship_to_grphy_value6_tab     ,
		pg_ship_to_grphy_type7_tab      ,
		pg_ship_to_grphy_value7_tab     ,
		pg_ship_to_grphy_type8_tab      ,
		pg_ship_to_grphy_value8_tab     ,
		pg_ship_to_grphy_type9_tab      ,
		pg_ship_to_grphy_value9_tab     ,
		pg_ship_to_grphy_type10_tab     ,
		pg_ship_to_grphy_value10_tab    ,
		pg_ship_fr_loc_id_tab           ,    -- Bug 5090593
		pg_ship_fr_grphy_type1_tab      ,
		pg_ship_fr_grphy_value1_tab     ,
		pg_ship_fr_grphy_type2_tab      ,
		pg_ship_fr_grphy_value2_tab     ,
		pg_ship_fr_grphy_type3_tab      ,
		pg_ship_fr_grphy_value3_tab     ,
		pg_ship_fr_grphy_type4_tab      ,
		pg_ship_fr_grphy_value4_tab     ,
		pg_ship_fr_grphy_type5_tab      ,
		pg_ship_fr_grphy_value5_tab     ,
		pg_ship_fr_grphy_type6_tab      ,
		pg_ship_fr_grphy_value6_tab     ,
		pg_ship_fr_grphy_type7_tab      ,
		pg_ship_fr_grphy_value7_tab     ,
		pg_ship_fr_grphy_type8_tab      ,
		pg_ship_fr_grphy_value8_tab     ,
		pg_ship_fr_grphy_type9_tab      ,
		pg_ship_fr_grphy_value9_tab     ,
		pg_ship_fr_grphy_type10_tab     ,
		pg_ship_fr_grphy_value10_tab    ,
		pg_poa_loc_id_tab               ,    -- Bug 5090593
		pg_poa_grphy_type1_tab          ,
		pg_poa_grphy_value1_tab         ,
		pg_poa_grphy_type2_tab          ,
		pg_poa_grphy_value2_tab         ,
		pg_poa_grphy_type3_tab          ,
		pg_poa_grphy_value3_tab         ,
		pg_poa_grphy_type4_tab          ,
		pg_poa_grphy_value4_tab         ,
		pg_poa_grphy_type5_tab          ,
		pg_poa_grphy_value5_tab         ,
		pg_poa_grphy_type6_tab          ,
		pg_poa_grphy_value6_tab         ,
		pg_poa_grphy_type7_tab          ,
		pg_poa_grphy_value7_tab         ,
		pg_poa_grphy_type8_tab          ,
		pg_poa_grphy_value8_tab         ,
		pg_poa_grphy_type9_tab          ,
		pg_poa_grphy_value9_tab         ,
		pg_poa_grphy_type10_tab         ,
		pg_poa_grphy_value10_tab        ,
		pg_poo_loc_id_tab               ,    -- Bug 5090593
		pg_poo_grphy_type1_tab          ,
		pg_poo_grphy_value1_tab         ,
		pg_poo_grphy_type2_tab          ,
		pg_poo_grphy_value2_tab         ,
		pg_poo_grphy_type3_tab          ,
		pg_poo_grphy_value3_tab         ,
		pg_poo_grphy_type4_tab          ,
		pg_poo_grphy_value4_tab         ,
		pg_poo_grphy_type5_tab          ,
		pg_poo_grphy_value5_tab         ,
		pg_poo_grphy_type6_tab          ,
		pg_poo_grphy_value6_tab         ,
		pg_poo_grphy_type7_tab          ,
		pg_poo_grphy_value7_tab         ,
		pg_poo_grphy_type8_tab          ,
		pg_poo_grphy_value8_tab         ,
		pg_poo_grphy_type9_tab          ,
		pg_poo_grphy_value9_tab         ,
		pg_poo_grphy_type10_tab         ,
		pg_poo_grphy_value10_tab        ,
		pg_bill_to_pty_num_tab		,
		pg_bill_to_pty_name_tab		,
		pg_bill_from_pty_num_tab	,
		pg_bill_from_pty_name_tab	,
		pg_bill_to_loc_id_tab           ,    -- Bug 5090593
		pg_bill_to_grphy_type1_tab      ,
		pg_bill_to_grphy_value1_tab     ,
		pg_bill_to_grphy_type2_tab      ,
		pg_bill_to_grphy_value2_tab     ,
		pg_bill_to_grphy_type3_tab      ,
		pg_bill_to_grphy_value3_tab     ,
		pg_bill_to_grphy_type4_tab      ,
		pg_bill_to_grphy_value4_tab     ,
		pg_bill_to_grphy_type5_tab      ,
		pg_bill_to_grphy_value5_tab     ,
		pg_bill_to_grphy_type6_tab      ,
		pg_bill_to_grphy_value6_tab     ,
		pg_bill_to_grphy_type7_tab      ,
		pg_bill_to_grphy_value7_tab     ,
		pg_bill_to_grphy_type8_tab      ,
		pg_bill_to_grphy_value8_tab     ,
		pg_bill_to_grphy_type9_tab      ,
		pg_bill_to_grphy_value9_tab     ,
		pg_bill_to_grphy_type10_tab     ,
		pg_bill_to_grphy_value10_tab    ,
		pg_bill_fr_loc_id_tab           ,    -- Bug 5090593
		pg_bill_fr_grphy_type1_tab      ,
		pg_bill_fr_grphy_value1_tab     ,
		pg_bill_fr_grphy_type2_tab      ,
		pg_bill_fr_grphy_value2_tab     ,
		pg_bill_fr_grphy_type3_tab      ,
		pg_bill_fr_grphy_value3_tab     ,
		pg_bill_fr_grphy_type4_tab      ,
		pg_bill_fr_grphy_value4_tab     ,
		pg_bill_fr_grphy_type5_tab      ,
		pg_bill_fr_grphy_value5_tab     ,
		pg_bill_fr_grphy_type6_tab      ,
		pg_bill_fr_grphy_value6_tab     ,
		pg_bill_fr_grphy_type7_tab      ,
		pg_bill_fr_grphy_value7_tab     ,
		pg_bill_fr_grphy_type8_tab      ,
		pg_bill_fr_grphy_value8_tab     ,
		pg_bill_fr_grphy_type9_tab      ,
		pg_bill_fr_grphy_value9_tab     ,
		pg_bill_fr_grphy_type10_tab     ,
		pg_bill_fr_grphy_value10_tab    ,
		pg_account_ccid_tab		,
		pg_appl_fr_doc_type_id_tab	,
		pg_appl_from_trx_id_tab		,
		pg_appl_from_line_id_tab	,
		pg_appl_fr_trx_lev_type_tab	,
		pg_appl_from_doc_num_tab	,
		pg_adj_doc_doc_type_id_tab	,
		pg_adj_doc_trx_id_tab		,
		pg_adj_doc_line_id_tab		,
		pg_adj_doc_number_tab		,
		pg_adj_doc_trx_lev_type_tab	,
		pg_adj_doc_date_tab		,
		pg_assess_value_tab		,
		pg_trx_line_number_tab		,
		pg_trx_line_desc_tab		,
		pg_prod_desc_tab		,
		pg_header_char1_tab		,
		pg_header_char2_tab		,
		pg_header_char3_tab		,
		pg_header_char4_tab		,
		pg_header_char5_tab		,
		pg_header_char6_tab		,
		pg_header_char7_tab		,
		pg_header_char8_tab		,
		pg_header_char9_tab		,
		pg_header_char10_tab		,
		pg_header_char11_tab		,
		pg_header_char12_tab		,
		pg_header_char13_tab		,
		pg_header_char14_tab		,
		pg_header_char15_tab		,
		pg_header_numeric1_tab		,
		pg_header_numeric2_tab		,
		pg_header_numeric3_tab		,
		pg_header_numeric4_tab		,
		pg_header_numeric5_tab		,
		pg_header_numeric6_tab		,
		pg_header_numeric7_tab		,
		pg_header_numeric8_tab		,
		pg_header_numeric9_tab		,
		pg_header_numeric10_tab		,
		pg_header_date1_tab		,
		pg_header_date2_tab		,
		pg_header_date3_tab		,
		pg_header_date4_tab		,
		pg_header_date5_tab		,
		pg_line_char1_tab		,
		pg_line_char2_tab		,
		pg_line_char3_tab		,
		pg_line_char4_tab		,
		pg_line_char5_tab		,
		pg_line_char6_tab		,
		pg_line_char7_tab		,
		pg_line_char8_tab		,
		pg_line_char9_tab		,
		pg_line_char10_tab		,
		pg_line_char11_tab		,
		pg_line_char12_tab		,
		pg_line_char13_tab		,
		pg_line_char14_tab		,
		pg_line_char15_tab		,
		pg_line_char16_tab		,
		pg_line_char17_tab		,
		pg_line_char18_tab		,
		pg_line_char19_tab		,
		pg_line_char20_tab		,
		pg_line_char21_tab		,
		pg_line_char22_tab		,
		pg_line_char23_tab		,
		pg_line_char24_tab		,
		pg_line_char25_tab		,
		pg_line_char26_tab		,
		pg_line_char27_tab		,
		pg_line_char28_tab		,
		pg_line_char29_tab		,
		pg_line_char30_tab		,
		pg_line_numeric1_tab		,
		pg_line_numeric2_tab		,
		pg_line_numeric3_tab		,
		pg_line_numeric4_tab		,
		pg_line_numeric5_tab		,
		pg_line_numeric6_tab		,
		pg_line_numeric7_tab		,
		pg_line_numeric8_tab		,
		pg_line_numeric9_tab		,
		pg_line_numeric10_tab		,
		pg_line_date1_tab		,
		pg_line_date2_tab		,
		pg_line_date3_tab		,
		pg_line_date4_tab		,
		pg_line_date5_tab		,
		pg_exempt_certi_numb_tab	,
		pg_exempt_reason_tab		,
		pg_exempt_cont_flag_tab
   limit C_LINES_PER_COMMIT;/*Need to limit the fetch*/

    delete from zx_jurisdictions_gt;

    IF (nvl(pg_trx_id_tab.last,0) = 0) Then
	IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	   'No item lines exist to whom tax lines need to be created' );
         END IF;
  	 --x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 --g_string :='No item lines exist to whom tax lines need to be created';
	 --error_exception_handle(g_string);
	 --x_messages_tbl:=g_messages_tbl;
	 RETURN;

    ELSE /*there are Some lines for processing*/
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         ' Item lines exist to whom tax lines need to be created');
      END IF;

      For ptr in 1..nvl(pg_trx_id_tab.last, 0) loop

         I:=ptr;
         g_transaction_line_id	:=  pg_trx_line_id_tab(i);
       	 g_trx_level_type	:=  pg_trx_level_type_tab(i);
	 g_docment_type_id	:=  pg_doc_type_id_tab(i);
	 g_trasaction_id	:=  pg_trx_id_tab(i);
	 g_tax_regime_code	:=  zx_tax_partner_pkg.g_tax_regime_code;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' Selecting document type for event_class_mapping id  '||pg_doc_type_id_tab(I));
         END IF;

	 pg_ugraded_inv_flag_tab(I) := 'N';

         IF(pg_doc_type_id_tab(I)<>0) then
       	    Begin
             select  event_class_code
             into    l_document_type
	     from    zx_evnt_cls_mappings
	     where   event_class_mapping_id = pg_doc_type_id_tab(I);
            Exception
	      When no_data_found then
	       IF (g_level_exception >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
	       End if;
		x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
		g_string :='No document type exist for provided event_class_mapping_id ';
		error_exception_handle(g_string);
		x_messages_tbl:=g_messages_tbl;
		return;
	    End;
           ELSE /*"Sales Transaction Quote*/
	    l_document_type := 'SALES_QUOTE';
           END IF;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               ' DOCUMENT_TYPE  '||l_document_type);
           END IF;
	 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
           ' Value of Variable I is :'||I);
         END IF;
/* Performing validation of passed document level,line level actions */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             ' Performing validation of passed document level,line level actions BY PERFORM_VALIDATE' );
         END IF;

	 Perform_validate(l_return_status);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  IF (g_level_exception >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
	  END IF;
	  x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  g_string :='Header ,line level actions are incompaitable';
	  error_exception_handle(g_string);
	  x_messages_tbl:=g_messages_tbl;
	  RETURN;
	END IF;

	 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
           ' Setting up Document type' );
         END IF;

	SET_DOCUMENT_TYPE(l_document_type,pg_adj_doc_trx_id_tab(I),pg_line_amount_tab(I),l_return_status);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  IF (g_level_exception >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
	  END IF;
	  x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  g_string :='Failed in setting up document type';
	  error_exception_handle(g_string);
	   x_messages_tbl:=g_messages_tbl;
	  RETURN;
	END IF;

	 IF(pg_doc_level_action_tab(i) in ('CREATE', 'QUOTE')) then

             	IF(l_document_type in ('TAX_ONLY_CREDIT_MEMO', 'TAX_ONLY_ADJUSTMENT')) then
                   Return;
                ELSE

		   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                     ' Calling LINE_CREATION procedure to create entry in TAXWARE' );
                   END IF;

		     Perform_line_creation(l_tax_lines_tbl,p_currency_tab,l_return_status);
		     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			  IF (g_level_exception >= g_current_runtime_level ) THEN
			     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
			  END IF;
			  x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
			  g_string :='Failed in creating tax line';
			  error_exception_handle(g_string);
			  x_messages_tbl:=g_messages_tbl;
			  return;
		     END IF;
	        END IF;


	 ELSIF(pg_doc_level_action_tab(i) = 'UPDATE') then

		IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                  ' Calling PERFORM_UPDATE procedure to update an entry in TAXWARE' );
                END IF;

		    Perform_update(l_tax_lines_tbl,p_currency_tab,l_return_status);
		    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			  IF (g_level_exception >= g_current_runtime_level ) THEN
			     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
			  END IF;
			  x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
			  g_string :='Failed in performing the update';
			  error_exception_handle(g_string);
			  x_messages_tbl:=g_messages_tbl;
			  RETURN;
		    END IF;
		Begin
		       Delete from zx_ptnr_neg_line_gt
		       WHERE  event_class_mapping_id	=  pg_doc_type_id_tab(I) and
			      trx_id       		=  pg_trx_id_tab(I) and
 			      trx_line_id  		=  pg_trx_line_id_tab(I) and
 			      trx_level_type		=  pg_trx_level_type_tab(I);
	        Exception
		      When no_data_found then null;
		End;
	 ELSE
	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                  ' Unknown header level action' );
             END IF;
             x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
	     g_string :=' Unknown header  level action';
	     error_exception_handle(g_string);
	     x_messages_tbl:=g_messages_tbl;
	     RETURN;
         END IF;

	 cnt_end := cnt + l_tax_lines_tbl.transaction_line_id.COUNT - 1;

	 FOR inner IN cnt .. cnt_end LOOP

            x_tax_lines_tbl.DOCUMENT_TYPE_ID(inner)               :=  l_tax_lines_tbl.DOCUMENT_TYPE_ID(inner);
            x_tax_lines_tbl.TRANSACTION_ID(inner)                 :=  l_tax_lines_tbl.TRANSACTION_ID(inner);
            x_tax_lines_tbl.TRANSACTION_LINE_ID(inner)            :=  l_tax_lines_tbl.TRANSACTION_LINE_ID(inner);
            x_tax_lines_tbl.TRX_LEVEL_TYPE(inner)                 :=  l_tax_lines_tbl.TRX_LEVEL_TYPE(inner);
            x_tax_lines_tbl.COUNTRY_CODE(inner)                   :=  l_tax_lines_tbl.COUNTRY_CODE(inner);
            x_tax_lines_tbl.TAX(inner)                            :=  l_tax_lines_tbl.TAX(inner);
            x_tax_lines_tbl.SITUS(inner)                          :=  l_tax_lines_tbl.SITUS(inner);
            x_tax_lines_tbl.TAX_JURISDICTION(inner)               :=  l_tax_lines_tbl.TAX_JURISDICTION(inner);
            x_tax_lines_tbl.TAX_CURRENCY_CODE(inner)              :=  l_tax_lines_tbl.TAX_CURRENCY_CODE(inner);
            x_tax_lines_tbl.TAX_AMOUNT(inner)                     :=  l_tax_lines_tbl.TAX_AMOUNT(inner);
            x_tax_lines_tbl.UNROUNDED_TAX_AMOUNT(inner)           :=  l_tax_lines_tbl.UNROUNDED_TAX_AMOUNT(inner);
            x_tax_lines_tbl.TAX_CURR_TAX_AMOUNT(inner)            :=  l_tax_lines_tbl.TAX_CURR_TAX_AMOUNT(inner);
            x_tax_lines_tbl.TAX_RATE_PERCENTAGE(inner)            :=  l_tax_lines_tbl.TAX_RATE_PERCENTAGE(inner);
            x_tax_lines_tbl.TAXABLE_AMOUNT(inner)                 :=  l_tax_lines_tbl.TAXABLE_AMOUNT(inner);
            x_tax_lines_tbl.EXEMPT_CERTIFICATE_NUMBER(inner)      :=  l_tax_lines_tbl.EXEMPT_CERTIFICATE_NUMBER(inner);
            x_tax_lines_tbl.EXEMPT_RATE_MODIFIER(inner)           :=  l_tax_lines_tbl.EXEMPT_RATE_MODIFIER(inner);
            x_tax_lines_tbl.EXEMPT_REASON(inner)                  :=  l_tax_lines_tbl.EXEMPT_REASON(inner);
            x_tax_lines_tbl.TAX_ONLY_LINE_FLAG(inner)             :=  l_tax_lines_tbl.TAX_ONLY_LINE_FLAG(inner);
            x_tax_lines_tbl.INCLUSIVE_TAX_LINE_FLAG(inner)        :=  l_tax_lines_tbl.INCLUSIVE_TAX_LINE_FLAG(inner);
            x_tax_lines_tbl.LINE_AMT_INCLUDES_TAX_FLAG(inner)     :=  l_tax_lines_tbl.LINE_AMT_INCLUDES_TAX_FLAG(inner);
            x_tax_lines_tbl.USE_TAX_FLAG(inner)                   :=  l_tax_lines_tbl.USE_TAX_FLAG(inner);
            x_tax_lines_tbl.USER_OVERRIDE_FLAG(inner)             :=  l_tax_lines_tbl.USER_OVERRIDE_FLAG(inner);
            x_tax_lines_tbl.LAST_MANUAL_ENTRY(inner)              :=  l_tax_lines_tbl.LAST_MANUAL_ENTRY(inner);
            x_tax_lines_tbl.MANUALLY_ENTERED_FLAG(inner)          :=  l_tax_lines_tbl.MANUALLY_ENTERED_FLAG(inner);
            x_tax_lines_tbl.REGISTRATION_PARTY_TYPE(inner)        :=  l_tax_lines_tbl.REGISTRATION_PARTY_TYPE(inner);
            x_tax_lines_tbl.PARTY_TAX_REG_NUMBER(inner)           :=  l_tax_lines_tbl.PARTY_TAX_REG_NUMBER(inner);
            x_tax_lines_tbl.THIRD_PARTY_TAX_REG_NUMBER(inner)     :=  l_tax_lines_tbl.THIRD_PARTY_TAX_REG_NUMBER(inner);
            x_tax_lines_tbl.THRESHOLD_INDICATOR_FLAG(inner)       :=  l_tax_lines_tbl.THRESHOLD_INDICATOR_FLAG(inner);
            x_tax_lines_tbl.STATE(inner)                          :=  l_tax_lines_tbl.STATE(inner);
            x_tax_lines_tbl.COUNTY(inner)                         :=  l_tax_lines_tbl.COUNTY(inner);
            x_tax_lines_tbl.CITY(inner)                           :=  l_tax_lines_tbl.CITY(inner);
            --bug7140895
            x_tax_lines_tbl.global_attribute_category(inner)      :=  l_tax_lines_tbl.global_attribute_category(inner);
            x_tax_lines_tbl.global_attribute2(inner)              :=  l_tax_lines_tbl.global_attribute2(inner);
            x_tax_lines_tbl.global_attribute4(inner)              :=  l_tax_lines_tbl.global_attribute4(inner);
            x_tax_lines_tbl.global_attribute6(inner)              :=  l_tax_lines_tbl.global_attribute6(inner);
          END LOOP;
          cnt := cnt + l_tax_lines_tbl.transaction_line_id.COUNT;
       END LOOP;
     END IF;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
     END IF;

     Exception
      WHEN WRONG_BUSINESS_FLOW then
	   IF (g_level_exception >= g_current_runtime_level ) THEN
		  FND_LOG.STRING(g_level_exception,G_PKG_NAME||': '||l_api_name,
			   'Failed in calculate_tax_api procedure');
	   END IF;
	   g_string :='Release 12 Old tax partner integration does not support P2P products';
	   error_exception_handle(g_string);
	   x_messages_tbl:=g_messages_tbl;
	   RAISE;

END CALCULATE_TAX_API;

PROCEDURE SET_DOCUMENT_TYPE( P_DOCUMENT_TYPE IN OUT NOCOPY VARCHAR2,
			     P_ADJ_DOC_TRX_ID IN NUMBER,
			     P_LINE_AMOUNT IN NUMBER,
			     x_return_status OUT NOCOPY VARCHAR2)IS
l_api_name           CONSTANT VARCHAR2(30) := 'SET_DOCUMENT_TYPE';

Begin
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'P_DOCUMENT_TYPE : '||P_DOCUMENT_TYPE );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'P_ADJ_DOC_TRX_ID : '||P_ADJ_DOC_TRX_ID );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'P_LINE_AMOUNT : '||P_LINE_AMOUNT );
    END IF;
   IF (p_document_type = 'CREDIT_MEMO') THEN
      IF (p_adj_doc_trx_id is not null) THEN
         IF (p_line_amount = 0) THEN
            p_document_type :='TAX_ONLY_CREDIT_MEMO';
         ELSIF pg_line_level_action_tab(I) = 'RECORD_WITH_NO_TAX' THEN
         --ELSIF (pg_allow_tax_calc_tab(I) ='N') THEN
            p_document_type :='LINE_ONLY_CREDIT_MEMO';
         ELSE
            p_document_type :='APPLIED_CREDIT_MEMO';
         END IF;     /*LINE_AMOUNT*/
      ELSE
        p_document_type :='ON_ACCT_CREDIT_MEMO';
      END IF;     /*ADJ_DOC_TRX_ID*/
   END IF;     /*'CREDIT_MEMO*/

   IF (p_document_type = 'INVOICE') THEN
      IF (p_line_amount = 0) THEN
         p_document_type :='TAX_ONLY_INVOICE';
      END IF;
   END IF;/*INVOICE*/

   IF (p_document_type = 'INVOICE_ADJUSTMENT') THEN
      IF (p_line_amount = 0) THEN
         p_document_type := 'TAX_ONLY_ADJUSTMENT';
      END IF;
   END IF;
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
End;


PROCEDURE PERFORM_VALIDATE(x_return_status OUT NOCOPY varchar2) is
l_api_name           CONSTANT VARCHAR2(30) := 'PERFORM_VALIDATE';
Begin

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'PG_DOC_LEVEL_ACTION_TAB(i)  :  '||pg_doc_level_action_tab(i));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'PG_LINE_LEVEL_ACTION_TAB(i) : '||pg_line_level_action_tab(i));
    END IF;
      if(pg_doc_level_action_tab(i) = 'CREATE') Then
         if(pg_line_level_action_tab(i) NOT IN ('CREATE', 'QUOTE','SYNCHRONIZE','RECORD_WITH_NO_TAX')) Then
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Unknown line level action');
           END IF;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         end if;
      elsif(pg_doc_level_action_tab(i) = 'QUOTE') Then
         if(pg_line_level_action_tab(i) NOT IN ('QUOTE')) Then
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Unknown line level action');
           END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         end if;
      elsif(pg_doc_level_action_tab(i) = 'UPDATE') Then
          if(pg_line_level_action_tab(i) NOT IN ('CREATE', 'UPDATE', 'QUOTE', 'CANCEL', 'DELETE', 'SYNCHRONIZE','RECORD_WITH_NO_TAX')) Then
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Unknown line level action');
             END IF;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          end if;
      else
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Unknown header level action');
       END IF;
       null;
    end if;
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
End perform_validate;


PROCEDURE PERFORM_LINE_CREATION(p_tax_lines_tbl     OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
				p_currency_tab   IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
				 x_return_status OUT NOCOPY VARCHAR2)is
l_TaxLink                    ZX_TAX_TAXWARE_GEN.TaxParm;
l_JurLink                     ZX_TAX_TAXWARE_GEN.JurParm;
l_OraLink                     ZX_TAX_TAXWARE_GEN.t_OraParm;
return_code			 boolean;
l_api_name           CONSTANT VARCHAR2(30) := 'PERFORM_LINE_CREATION';
l_return_status		VARCHAR2(30);
input_param_flag        boolean;
Begin

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Calling SET_PARAMETERS procedure' );
   END IF;

	g_line_level_action:='CREATE';
    	return_code := Set_Parameters(l_TaxLink, l_JurLink, l_OraLink);
	input_param_flag := TRUE;
	dump_vendor_rec(l_TaxLink, l_JurLink, l_OraLink,input_param_flag);

	if(return_code = TRUE) then
	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Calling CALCULATE_TAX procedure' );
	     END IF;

	     return_code := calculate_tax(l_TaxLink, l_JurLink, l_OraLink);
	     input_param_flag := FALSE;
	dump_vendor_rec(l_TaxLink, l_JurLink, l_OraLink,input_param_flag);
	     IF (return_code = FALSE) then
	         --x_return_status := FND_API.G_RET_STS_ERROR;
		 g_string :='Failed in CALCULATE_TAX procedure';
		 error_exception_handle(g_string);
 		return;
	     END IF;
        else
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     g_string :='Failed in SET_PRAMETERS procedure';
	     error_exception_handle(g_string);
	     return;
	end if;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Calling TAX_RESULTS_PROCESSING procedure' );
   END IF;

      tax_results_processing(p_tax_lines_tbl,p_currency_tab,l_TaxLink, l_JurLink, l_OraLink,l_return_status);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  IF (g_level_exception >= g_current_runtime_level ) THEN
	     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
	  END IF;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  g_string :='Failed in call to the TAX_RESULTS_PROCESSING';
	  error_exception_handle(g_string);
	  RETURN;
      END IF;

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;
Exception
	When Others then
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF (g_level_exception >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_exception,G_PKG_NAME||'.'||l_api_name,
                           'Failed in Line creation procedure');
          END IF;
End;

PROCEDURE PERFORM_LINE_DELETION(x_return_status OUT NOCOPY VARCHAR2) is
l_TaxLink                     ZX_TAX_TAXWARE_GEN.TaxParm;
l_JurLink                     ZX_TAX_TAXWARE_GEN.JurParm;
l_OraLink                     ZX_TAX_TAXWARE_GEN.t_OraParm;
l_api_name           CONSTANT VARCHAR2(30) := 'PERFORM_LINE_DELETION';
return_code		boolean;
input_param_flag        boolean;
Begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   	  /*ZX_TAXWARE_USER_PKG.g_line_negation := TRUE;
   	  ZX_TAXWARE_USER_PKG.g_trx_line_id := pg_trx_line_id_tab(I);
   	  ZX_TAXWARE_USER_PKG.Derive_Hdr_Ext_Attr;
	  ZX_TAXWARE_USER_PKG.Derive_Line_Ext_Attr;*/
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
   END IF;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Calling SET_PARAMETERS procedure' );
   END IF;
      --Bug 8576319
   	  --g_line_level_action:='DELETE';
   	  return_code := Set_Parameters(l_TaxLink, l_JurLink, l_OraLink);
    	  if(return_code = TRUE) then
	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Calling CALCULATE_TAX procedure' );
             END IF;

		input_param_flag := TRUE;
		dump_vendor_rec(l_TaxLink, l_JurLink, l_OraLink,input_param_flag);

	    	return_code := calculate_tax(l_TaxLink, l_JurLink, l_OraLink);
		input_param_flag := FALSE;
		dump_vendor_rec(l_TaxLink, l_JurLink, l_OraLink,input_param_flag);
	     IF (return_code = FALSE) then
	         --x_return_status := FND_API.G_RET_STS_ERROR;
		 g_string :='Failed in CALCULATE_TAX procedure';
		 error_exception_handle(g_string);
 		return;
	     END IF;
          else
	      x_return_status := FND_API.G_RET_STS_ERROR;
	  end if;
	/*end of line deletion process.*/
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()+');
   END IF;
Exception
	When Others then
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   IF (g_level_exception >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_exception,G_PKG_NAME||'.'||l_api_name,
                           'Failed in Line deletion procedure');
          END IF;

End;

PROCEDURE PERFORM_UPDATE       (p_tax_lines_tbl     OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
				p_currency_tab   IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
				x_return_status  OUT NOCOPY VARCHAR2) is
l_api_name           CONSTANT VARCHAR2(30) := 'PERFORM_UPDATE';
l_return_status    varchar2(30);
l_ret_code boolean;
Begin

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'PG_LINE_LEVEL_ACTION_TAB(i)'||pg_line_level_action_tab(i) );
   END IF;
    	if (pg_line_level_action_tab(i) in ('CREATE','QUOTE')) Then

               g_line_level_action := 'CREATE';

	       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Calling PERFORM_LINE_CREATION procedure' );
               END IF;

    	       Perform_line_creation(p_tax_lines_tbl,p_currency_tab,l_return_status);
	       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			  IF (g_level_exception >= g_current_runtime_level ) THEN
			     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
			  END IF;
			  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			  g_string :='Not compaitable to TAXWARE Release';
			  error_exception_handle(g_string);
			  return;
	       END IF;

    	elsif(pg_line_level_action_tab(i) in ('UPDATE')) Then
    	     /*First make contra entry*/
	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Calling PERFORM_LINE_DELETION procedure' );
             END IF;
      --Bug 8576319
      g_line_level_action := 'DELETE';
	    perform_line_deletion(l_return_status);

	    /*For new line*/
             --  g_line_level_action := 'CREATE';
	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Calling PERFORM_LINE_CREATION procedure' );
             END IF;

    	     perform_line_creation(p_tax_lines_tbl,p_currency_tab,l_return_status);
	     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			  IF (g_level_exception >= g_current_runtime_level ) THEN
			     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
			  END IF;
			  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			  g_string :='Not compaitable to TAXWARE Release';
			  error_exception_handle(g_string);
			  return;
            END IF;
    	elsif(pg_line_level_action_tab(i) in ('DELETE','CANCEL')) Then
          -- g_line_level_action := pg_line_level_action_tab(i);
	   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Calling PERFORM_LINE_DELETION procedure' );
           END IF;
           --Bug 8576319
           g_line_level_action := 'CREATE';
           perform_line_deletion(l_return_status);

        else
             Null;/*Need to add for  SYNCHRONIZE */
    	end if;/*Line level operation*/


End PERFORM_UPDATE;

PROCEDURE GET_TAX_JUR_CODE(p_location_id           IN  NUMBER,
                           p_situs                 IN  VARCHAR2,
                           p_tax                   IN  VARCHAR2,
                           p_regime_code           IN  VARCHAR2,
                           p_inv_date              IN  DATE,
                           x_tax_jurisdiction_code  OUT NOCOPY  VARCHAR2,
                           x_return_status         OUT NOCOPY  VARCHAR2) IS

l_api_name             CONSTANT VARCHAR2(30) := 'GET_TAX_JUR_CODE';
x_tax_jurisdiction_rec ZX_TCM_GEO_JUR_PKG.tax_jurisdiction_rec_type;
x_jurisdictions_found  VARCHAR2(20);
l_return_status        VARCHAR2(30);

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   ZX_TCM_GEO_JUR_PKG.get_tax_jurisdictions
	 	      (p_location_id                 ,
	 	       p_situs                       ,
	               p_tax                         ,
                       p_regime_code		     ,
	 	       p_inv_date   	             ,
	 	       x_tax_jurisdiction_rec  	     ,
	 	       x_jurisdictions_found         ,
	 	       x_return_status
	 	      );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_exception >= g_current_runtime_level ) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
	  -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      g_string :='Not able to find Jurisdiction';
      error_exception_handle(g_string);
      RETURN;
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'x_jurisdictions_found :'||x_jurisdictions_found);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'x_tax_jurisdiction_rec.tax_jurisdiction_code :'||x_tax_jurisdiction_rec.tax_jurisdiction_code);
   END IF;

   IF x_jurisdictions_found = 'Y' THEN
      IF x_tax_jurisdiction_rec.tax_jurisdiction_code IS NOT NULL THEN
         x_tax_jurisdiction_code := x_tax_jurisdiction_rec.tax_jurisdiction_code;
      ELSE
         BEGIN
            SELECT tax_jurisdiction_code
              INTO x_tax_jurisdiction_code
	      FROM
	      (SELECT tax_jurisdiction_code
	       FROM zx_jurisdictions_gt
               WHERE tax_regime_code = p_regime_code
               AND tax = p_tax
               AND precedence_level = (SELECT max(precedence_level)
                                         FROM zx_jurisdictions_gt
                                        WHERE tax_regime_code = p_regime_code
                                          AND tax = p_tax)
              ORDER BY tax_jurisdiction_code)
             WHERE ROWNUM = 1;
         END;
      END IF;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END GET_TAX_JUR_CODE;

FUNCTION SET_PARAMETERS(
l_Tax_Link 	IN OUT NOCOPY zx_tax_taxware_GEN.TaxParm,
l_JurLink 	IN OUT NOCOPY zx_tax_taxware_GEN.JurParm,
l_OraLink       IN OUT NOCOPY zx_tax_taxware_GEN.t_OraParm) RETURN BOOLEAN is

 /*Following variables used during line deletion process.*/
arp_line_amount     ZX_PTNR_NEG_LINE_GT.line_amt%type;
arp_quantity        ZX_PTNR_NEG_LINE_GT.trx_line_quantity%type;
arp_trx_id	    ZX_PTNR_NEG_LINE_GT.trx_id%type;
arp_trx_number      ZX_PTNR_NEG_LINE_GT.trx_number%type;
/*Not needed for TAXWARE
arp_ship_to_grphy_type1		    varchar2(240);
arp_ship_to_grphy_value1	    varchar2(240);
arp_ship_to_grphy_type2             varchar2(240);
arp_ship_to_grphy_value2            varchar2(240);
arp_ship_to_grphy_type3             varchar2(240);
arp_ship_to_grphy_value3            varchar2(240);
arp_ship_to_grphy_type4             varchar2(240);
arp_ship_to_grphy_value4            varchar2(240);
arp_ship_to_grphy_type5             varchar2(240);
arp_ship_to_grphy_value5            varchar2(240);
arp_ship_to_grphy_type6             varchar2(240);
arp_ship_to_grphy_value6            varchar2(240);
arp_ship_to_grphy_type7             varchar2(240);
arp_ship_to_grphy_value7            varchar2(240);
arp_ship_to_grphy_type8             varchar2(240);
arp_ship_to_grphy_value8            varchar2(240);
arp_ship_to_grphy_type9             varchar2(240);
arp_ship_to_grphy_value9            varchar2(240);
arp_ship_to_grphy_type10            varchar2(240);
arp_ship_to_grphy_value10           varchar2(240);
arp_ship_from_grphy_type1           varchar2(240);
arp_ship_from_grphy_value1          varchar2(240);
arp_ship_from_grphy_type2           varchar2(240);
arp_ship_from_grphy_value2          varchar2(240);
arp_ship_from_grphy_type3           varchar2(240);
arp_ship_from_grphy_value3          varchar2(240);
arp_ship_from_grphy_type4           varchar2(240);
arp_ship_from_grphy_value4          varchar2(240);
arp_ship_from_grphy_type5           varchar2(240);
arp_ship_from_grphy_value5          varchar2(240);
arp_ship_from_grphy_type6           varchar2(240);
arp_ship_from_grphy_value6          varchar2(240);
arp_ship_from_grphy_type7           varchar2(240);
arp_ship_from_grphy_value7          varchar2(240);
arp_ship_from_grphy_type8           varchar2(240);
arp_ship_from_grphy_value8          varchar2(240);
arp_ship_from_grphy_type9           varchar2(240);
arp_ship_from_grphy_value9          varchar2(240);
arp_ship_from_grphy_type10          varchar2(240);
arp_ship_from_grphy_value10         varchar2(240);
arp_poa_grphy_type1                 varchar2(240);
arp_poa_grphy_value1                varchar2(240);
arp_poa_grphy_type2                 varchar2(240);
arp_poa_grphy_value2                varchar2(240);
arp_poa_grphy_type3                 varchar2(240);
arp_poa_grphy_value3                varchar2(240);
arp_poa_grphy_type4                 varchar2(240);
arp_poa_grphy_value4                varchar2(240);
arp_poa_grphy_type5                 varchar2(240);
arp_poa_grphy_value5                varchar2(240);
arp_poa_grphy_type6                 varchar2(240);
arp_poa_grphy_value6                varchar2(240);
arp_poa_grphy_type7                 varchar2(240);
arp_poa_grphy_value7                varchar2(240);
arp_poa_grphy_type8                 varchar2(240);
arp_poa_grphy_value8                varchar2(240);
arp_poa_grphy_type9                 varchar2(240);
arp_poa_grphy_value9                varchar2(240);
arp_poa_grphy_type10                varchar2(240);
arp_poa_grphy_value10               varchar2(240);
arp_poo_grphy_type1                 varchar2(240);
arp_poo_grphy_value1                varchar2(240);
arp_poo_grphy_type2                 varchar2(240);
arp_poo_grphy_value2                varchar2(240);
arp_poo_grphy_type3                 varchar2(240);
arp_poo_grphy_value3                varchar2(240);
arp_poo_grphy_type4                 varchar2(240);
arp_poo_grphy_value4                varchar2(240);
arp_poo_grphy_type5                 varchar2(240);
arp_poo_grphy_value5                varchar2(240);
arp_poo_grphy_type6                 varchar2(240);
arp_poo_grphy_value6                varchar2(240);
arp_poo_grphy_type7                 varchar2(240);
arp_poo_grphy_value7                varchar2(240);
arp_poo_grphy_type8                 varchar2(240);
arp_poo_grphy_type9                 varchar2(240);
arp_poo_grphy_value9                varchar2(240);
arp_poo_grphy_type10                varchar2(240);
arp_poo_grphy_value10               varchar2(240);
arp_bill_to_grphy_type1             varchar2(240);
arp_bill_to_grphy_value1            varchar2(240);
arp_bill_to_grphy_type2             varchar2(240);
arp_bill_to_grphy_value2            varchar2(240);
arp_bill_to_grphy_type3             varchar2(240);
arp_bill_to_grphy_value3            varchar2(240);
arp_bill_to_grphy_type4             varchar2(240);
arp_bill_to_grphy_value4            varchar2(240);
arp_bill_to_grphy_type5             varchar2(240);
arp_bill_to_grphy_value5            varchar2(240);
arp_bill_to_grphy_type6             varchar2(240);
arp_bill_to_grphy_value6            varchar2(240);
arp_bill_to_grphy_type7             varchar2(240);
arp_bill_to_grphy_value7            varchar2(240);
arp_bill_to_grphy_type8             varchar2(240);
arp_bill_to_grphy_value8            varchar2(240);
arp_bill_to_grphy_type9             varchar2(240);
arp_bill_to_grphy_value9            varchar2(240);
arp_bill_to_grphy_type10            varchar2(240);
arp_bill_to_grphy_value10           varchar2(240);
arp_bill_from_grphy_type1           varchar2(240);
arp_bill_from_grphy_value1          varchar2(240);
arp_bill_from_grphy_type2           varchar2(240);
arp_bill_from_grphy_value2          varchar2(240);
arp_bill_from_grphy_type3           varchar2(240);
arp_bill_from_grphy_value3          varchar2(240);
arp_bill_from_grphy_type4           varchar2(240);
arp_bill_from_grphy_value4          varchar2(240);
arp_bill_from_grphy_type5           varchar2(240);
arp_bill_from_grphy_value5          varchar2(240);
arp_bill_from_grphy_type6           varchar2(240);
arp_bill_from_grphy_value6          varchar2(240);
arp_bill_from_grphy_type7           varchar2(240);
arp_bill_from_grphy_value7          varchar2(240);
arp_bill_from_grphy_type8           varchar2(240);
arp_bill_from_grphy_value8          varchar2(240);
arp_bill_from_grphy_type9           varchar2(240);
arp_bill_from_grphy_value9          varchar2(240);
arp_bill_from_grphy_type10          varchar2(240);
arp_bill_from_grphy_value10         varchar2(240); Not Required for TAXWARE*/
arp_tax_type			    varchar2(150);
arp_product_code		    ZX_LINES_DET_FACTORS.PRODUCT_CODE%TYPE;
use_step			    varchar2(30);
arp_state_exempt_reason		    varchar2(240);
arp_county_exempt_reason	    varchar2(240);
arp_city_exempt_reason		    varchar2(240);
step_proc_flag			    varchar2(30);
arp_audit_flag			    varchar2(30);
arp_ship_to_add			    varchar2(240);
arp_ship_from_add		    varchar2(240);
arp_poa_add_code		    varchar2(240);
arp_poo_add_code		    varchar2(240);
arp_customer_code		    varchar2(150);
arp_customer_name		    varchar2(360);
arp_company_code		    varchar2(150);
arp_division_code		    varchar2(150);
arp_vnd_ctrl_exmpt		    varchar2(150);
arp_use_nexpro			    varchar2(30);
arp_service_ind			    varchar2(150);
crit_flag			    varchar2(30);
calculation_flag		    varchar2(30);
state_cert_no			    varchar2(150);
county_cert_no			    varchar2(150);
city_cert_no			    varchar2(150);
arp_state_exempt_percent	    number;
arp_county_exempt_pct		    number;
arp_city_exempt_pct		    number;
sec_county_exempt_pct		    number;
sec_city_exempt_pct		    number;
arp_tax_sel_param		    number;
arp_transaction_date		    date;
arp_adj_doc_date		    date;
arp_trx_date                        date;
arp_fob_point   varchar2(20);
arp_exempt_control_flag varchar2(1);

/*Following variables defined for local use*/
l_tax_sel_param			number;
l_tax_type_param		varchar2(150);
l_tax_type			varchar2(150);
l_calculation_flag		varchar2(150);
l_poo_code			varchar2(150);
l_poa_code			varchar2(150);
l_ship_from_code		varchar2(150);
l_ship_to_code			varchar2(150);
l_service_indicator		varchar2(150);
l_state_exempt_reason		varchar2(150);
l_county_exempt_reason		varchar2(150);
l_city_exempt_reason		varchar2(150);
l_sec_county_exempt_reason	varchar2(150);
l_sec_city_exempt_reason	varchar2(150);
l_state_exempt_percent		number;
l_county_exempt_percent		number;
l_city_exempt_percent		number;
l_sec_county_exempt_percent	number;
l_sec_city_exempt_percent	number;
/*st_tax_amt			number;
co_tax_amt			number;
ci_tax_amt			number;	*/
l_use_step			varchar2(20);
l_step_proc_flag		varchar2(20);
l_job_no			varchar2(20);
l_criterion_flag		varchar2(20);
l_prod_ind			varchar2(20);
l_fob_point			varchar2(20);
l_api_name           CONSTANT VARCHAR2(30) := 'SET_PARAMETERS';

Begin

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'G_LINE_LEVEL_ACTION :'||g_line_level_action);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Value of I is :'||I);
   END IF;

   if(g_line_level_action='CREATE') then
	l_OraLink.oracleid          := pg_Trx_id_tab(I);
   else /*Line level action is delete*/
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	     'Selecting data from ZX_PTNR_NEG_LINE_GT');
       END IF;

   select
        line_amt,
        trx_line_quantity,
        trx_id,
        trx_number,
	adjusted_doc_date,
	trx_date,
	exemption_control_flag,
	fob_point,
	line_ext_varchar_attribute1  ,
	line_ext_varchar_attribute2  ,
	line_ext_varchar_attribute3  ,
	line_ext_varchar_attribute4  ,
	line_ext_varchar_attribute5  ,
	line_ext_varchar_attribute6  ,
	line_ext_varchar_attribute7  ,
	line_ext_varchar_attribute8  ,
	line_ext_varchar_attribute9   ,
	line_ext_varchar_attribute10  ,
	line_ext_varchar_attribute11  ,
	line_ext_varchar_attribute12  ,
	line_ext_varchar_attribute13  ,
	line_ext_varchar_attribute14  ,
	line_ext_varchar_attribute15  ,
	line_ext_varchar_attribute16  ,
	line_ext_varchar_attribute17  ,
	line_ext_varchar_attribute18  ,
	line_ext_varchar_attribute19  ,
	line_ext_varchar_attribute20  ,
	line_ext_varchar_attribute21  ,
	line_ext_varchar_attribute22  ,
	line_ext_varchar_attribute23  ,
	line_ext_varchar_attribute24  ,
	line_ext_number_attribute1    ,
	line_ext_number_attribute2    ,
	line_ext_number_attribute3    ,
	line_ext_number_attribute4    ,
	line_ext_number_attribute5    ,
	line_ext_number_attribute6    ,
	line_ext_date_attribute1
Into    arp_line_amount,
        arp_quantity,
        arp_trx_id,
	arp_trx_number,
        arp_adj_doc_date,
	arp_trx_date,
	arp_exempt_control_flag,
	arp_fob_point,
	arp_tax_type		    ,
	arp_product_code	    ,
	use_step		    ,
	arp_state_exempt_reason     ,
	arp_county_exempt_reason    ,
	arp_city_exempt_reason      ,
	step_proc_flag	     	    ,
	arp_audit_flag	     	    ,
	arp_ship_to_add             ,
	arp_ship_from_add           ,
	arp_poa_add_code            ,
	arp_customer_code	    ,
	arp_customer_name           ,
	arp_company_code            ,
	arp_division_code           ,
	arp_vnd_ctrl_exmpt          ,
	arp_use_nexpro              ,
	arp_service_ind             ,
	crit_flag                   ,
	arp_poo_add_code            ,
	calculation_flag            ,
	state_cert_no               ,
	county_cert_no              ,
	city_cert_no		    ,
	arp_state_exempt_percent    ,
	arp_county_exempt_pct       ,
	arp_city_exempt_pct  	    ,
	sec_county_exempt_pct       ,
	sec_city_exempt_pct         ,
	arp_tax_sel_param           ,
	arp_transaction_date
         from  ZX_PTNR_NEG_LINE_GT
         WHERE trx_line_id= pg_trx_line_id_tab(I);

	l_OraLink.oracleid          := arp_Trx_id;
   end if;

   l_OraLink.oracle_msg_text   := null;
   l_OraLink.oracle_msg_label  := null;
   l_OraLink.taxware_msg_text  := null;
   l_OraLink.reserved_text_1   := null;
   l_OraLink.reserved_text_2   := null;
   l_OraLink.reserved_text_3   := null;
   l_OraLink.reserved_bool_1   := null;
   l_OraLink.reserved_bool_2   := null;
   l_OraLink.reserved_bool_3   := null;
   l_OraLink.reserved_char_1   := null;
   l_OraLink.reserved_char_2   := null;
   l_OraLink.reserved_char_3   := null;
   l_OraLink.reserved_num_1    := null;
   l_OraLink.reserved_num_2    := null;
   l_OraLink.reserved_bignum_1 := null;
   l_OraLink.reserved_date_1   := null;

/*-------------------------------------------------------------+
   | Validate Taxware attributes passed                        |
   +-----------------------------------------------------------*/

   /*Here we are assigning to the variables..In subsequent changes
     we may directly use these values*/


   if(g_line_level_action = 'CREATE') then
	   l_tax_sel_param		:=	pg_line_numeric6_tab(i);
	   l_tax_type_param		:=	pg_line_char1_tab(i);
	   l_calculation_flag		:=	pg_line_char21_tab(I);
	   l_poo_code			:=	pg_line_char20_tab(i); /*assigned*/
	   l_poa_code			:=	pg_line_char11_tab(i);
	   l_ship_from_code		:=	pg_line_char10_tab(i);
	   l_ship_to_code		:=	pg_line_char9_tab(i);
	   l_service_indicator		:=	pg_line_char18_tab(i);
	   l_state_exempt_reason	:=	pg_line_char4_tab(i);
	   l_county_exempt_reason	:=	pg_line_char5_tab(i);
	   l_city_exempt_reason		:=	pg_line_char6_tab(i);
	   l_sec_county_exempt_reason	:=	pg_line_char5_tab(i);
	   l_sec_city_exempt_reason	:=	pg_line_char6_tab(i);
           l_state_cert_no              :=      pg_line_char22_tab(i);
           l_county_cert_no             :=      pg_line_char23_tab(i);
           l_city_cert_no               :=      pg_line_char24_tab(i);
	   l_state_exempt_percent	:=	pg_line_numeric1_tab(i);
	   l_county_exempt_percent	:=	pg_line_numeric2_tab(i);
	   l_city_exempt_percent	:=	pg_line_numeric3_tab(i);
	   l_sec_county_exempt_percent	:=	pg_line_numeric4_tab(i);
	   l_sec_city_exempt_percent	:=	pg_line_numeric5_tab(i);
   else
	   l_tax_sel_param		:=	arp_tax_sel_param;
	   l_tax_type_param		:=	arp_tax_type;
	   l_calculation_flag		:=	calculation_flag;
	   l_poo_code			:=	arp_poo_add_code;
	   l_poa_code			:=	arp_poa_add_code;
	   l_ship_from_code		:=	arp_ship_from_add;
	   l_ship_to_code		:=	arp_ship_to_add;
	   l_service_indicator		:=	arp_service_ind;
	   l_state_exempt_reason	:=	arp_state_exempt_reason;
	   l_county_exempt_reason	:=	arp_county_exempt_reason;
	   l_city_exempt_reason		:=	arp_city_exempt_reason;
	   l_sec_county_exempt_reason	:=	arp_county_exempt_reason;
	   l_sec_city_exempt_reason	:=	arp_city_exempt_reason;
	   l_state_exempt_percent	:=	arp_state_exempt_percent;
	   l_county_exempt_percent	:=	arp_county_exempt_pct;
	   l_city_exempt_percent	:=	arp_city_exempt_pct ;
	   l_sec_county_exempt_percent	:=	sec_county_exempt_pct;
	   l_sec_city_exempt_percent	:=	sec_city_exempt_pct;
   end if;

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Value of l_tax_sel_param is :'||to_char(l_tax_sel_param));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Value of l_tax_type_param is :'||l_tax_type_param);
       END IF;


	   IF l_tax_sel_param is NULL then
		g_tax_SELECTION := ZX_TAX_TAXWARE_GEN.SELPRM_TAX_JUR;
	   ELSIF l_tax_sel_param = 1 THEN
		g_tax_SELECTION := ZX_TAX_TAXWARE_GEN.SELPRM_JUR_ONLY;
	   ELSIF l_tax_sel_param = 2 THEN
		g_tax_SELECTION := ZX_TAX_TAXWARE_GEN.SELPRM_TAXES_ONLY;
	   ELSE
		g_tax_SELECTION := ZX_TAX_TAXWARE_GEN.SELPRM_TAX_JUR;
	   END IF;

	  IF l_tax_type_param = '1' THEN
		l_tax_type := ZX_TAX_TAXWARE_GEN.IND_SALES;
	  ELSIF l_tax_type_param = '2' THEN
		l_tax_type := ZX_TAX_TAXWARE_GEN.IND_USE;
	  ELSIF l_tax_type_param = '3' THEN
		l_tax_type := ZX_TAX_TAXWARE_GEN.IND_RENTAL;
	  ELSE
		l_tax_type := ZX_TAX_TAXWARE_GEN.IND_SALES;
	  END IF;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Value of l_poo_code is :'||l_poo_code);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Value of l_poa_code is :'||l_poa_code);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Value of l_ship_from_code is :'||l_ship_from_code);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Value of l_ship_to_code is :'||l_ship_to_code);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Value of l_calculation_flag is :'||l_calculation_flag);

     END IF;
-- Validate POO, POA and SHIP-FROM if tax selection specifies use of
  -- Jurisdictions.
  IF (g_tax_SELECTION IN
                (ZX_TAX_TAXWARE_GEN.SELPRM_JUR_ONLY, ZX_TAX_TAXWARE_GEN.SELPRM_TAX_JUR) ) THEN
     -- POO Code
     IF ( l_poo_code IS NULL ) THEN
	stack_error('GENERIC_MESSAGE', 'GENERIC_TEXT',
		'Taxware Error: Point Of Order Origin(POO) Information is not passed.',null,null);
     END IF;

     -- POA Code
     IF ( l_poa_code IS NULL ) THEN
	stack_error('GENERIC_MESSAGE', 'GENERIC_TEXT',
		'Taxware Error: Point Of Order Acceptance(POA) Information is not passed.',null,null);
		Return FALSE;
     END IF;

     -- Ship From Address
     IF ( l_ship_from_code IS NULL ) THEN
	stack_error('GENERIC_MESSAGE', 'GENERIC_TEXT',
		'Taxware Error: Ship From Address Information is not passed.',null,null);
		RETURN FALSE;
     END IF;

  END IF;		-- Tax selection uses Jurisdictions?

  -- Ship To Address
  IF ( l_ship_to_code IS NULL ) THEN
	stack_error('GENERIC_MESSAGE', 'GENERIC_TEXT',
		'Taxware Error: Ship To Address Information is not passed.',null,null);
		RETURN FALSE;
  END IF;

 /*----------------------------------------------------------------------+
   | Users could customize the tax views to totally exempt tax at any of  |
   | the jurisdiction levels using No Tax Indicators.                     |
   | No Tax Indicators for all the levels are passed in thru              |
   | calculation_flag as State||County||City||Sec County||Sec City.       |
   +----------------------------------------------------------------------*/



  -- No State Tax Indicator
  IF ( nvl(substrb(l_calculation_flag,1,1), '0') NOT IN ('0','1'))
  THEN
	stack_error('GENERIC_MESSAGE', 'GENERIC_TEXT',
		'Taxware Error: Invalid No State Tax Indicator. Must be 1 or 0.',null,null);
		RETURN FALSE;
  END IF;

  -- No County Tax Indicator
  IF ( nvl(substrb(l_calculation_flag,2,1), '0') NOT IN ('0','1'))
  THEN
	stack_error('GENERIC_MESSAGE', 'GENERIC_TEXT',
		'Taxware Error: Invalid No County Tax Indicator. Must be 1 or 0.',null,null);
		RETURN FALSE;
  END IF;

  -- No City/Town Tax Indicator
  IF ( nvl(substrb(l_calculation_flag,3,1), '0') NOT IN ('0','1'))
  THEN
	stack_error('GENERIC_MESSAGE', 'GENERIC_TEXT',
		'Taxware Error: Invalid No City/Town Tax Indicator. Must be 1 or 0.',null,null);
		RETURN FALSE;
  END IF;

  -- No Secondary County Tax Indicator
  IF ( nvl(substrb(l_calculation_flag,4,1), '0') NOT IN ('0','1'))
  THEN
	stack_error('GENERIC_MESSAGE', 'GENERIC_TEXT',
		'Taxware Error: Invalid No Secondary County Tax Indicator. Must be 1 or 0.',null,null);
		RETURN FALSE;
  END IF;

  -- No Secondary City/Town Tax Indicator
  IF ( nvl(substrb(l_calculation_flag,5,1), '0') NOT IN ('0','1'))
  THEN
	stack_error('GENERIC_MESSAGE', 'GENERIC_TEXT',
		'Taxware Error: Invalid No Secondary City/Town Tax Indicator. Must be 1 or 0.',null,null);
		RETURN FALSE;
  END IF;

 /*-------------------------------------------------------------+
   | Validation Complete. 					 |
   +-------------------------------------------------------------*/


   if(g_line_level_action = 'CREATE') then
	   l_Tax_link.CustNo		:=pg_line_char12_tab(I);
	   l_Tax_link.CustName		:=substr(pg_line_char13_tab(I),1,20);
	   l_Tax_link.InvoiceNo		:=pg_trx_number_tab(I);
	   l_Tax_link.FiscalDate	:=pg_line_date1_tab(I);
	   l_Tax_link.ProdCode		:=pg_line_char2_tab(I);
	   l_Tax_link.NumItems		:=abs(nvl(pg_trx_line_qty_tab(I),1));
	   l_Tax_link.NoTaxInd		:=FALSE;
	   l_Tax_link.ReptInd		:=nvl(pg_line_char8_tab(I),'N') = 'Y';/*Need to check whether QUOTE to be also added*/
	   l_Tax_link.DivCode		:=pg_line_char15_tab(I);
	   l_Tax_link.CompanyID		:=pg_line_char14_tab(I);

	IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Value of pg_line_amount_tab is :'||to_char(pg_line_amount_tab(I)));
        END IF;
	if(pg_line_amount_tab(I)<0) then
		l_tax_link.CreditInd :=TRUE;
	else
		l_tax_link.CreditInd :=FALSE;
	end if;

  --Bug 8576319
	--Setting the credit indicator if line_level_action = DELETE
	IF pg_line_level_action_tab(i) = 'DELETE' THEN
	   l_tax_link.CreditInd := NOT l_tax_link.CreditInd;
	END IF;
    else
	   l_Tax_link.CustNo		:=arp_customer_code;
	   l_Tax_link.CustName		:=substr(arp_customer_name,1,20);
	   l_Tax_link.InvoiceNo		:=arp_trx_number;
	   l_Tax_link.FiscalDate	:=arp_transaction_date;
	   l_Tax_link.ProdCode		:=arp_product_code;
	   l_Tax_link.NumItems		:=abs(nvl(arp_quantity,1));
	   l_Tax_link.NoTaxInd		:=FALSE;			/*This need to be checked*/
	   l_Tax_link.ReptInd		:=TRUE;
	   l_Tax_link.DivCode		:=arp_division_code;
	   l_Tax_link.CompanyID		:=arp_company_code;

	IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Value of arp_line_amount is :'||to_char(arp_line_amount));
        END IF;
	if(arp_line_amount >0) then
		l_tax_link.CreditInd :=TRUE;
	else
		l_tax_link.CreditInd :=FALSE;
	end if;
    end if;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Value of l_document_type is :'||l_document_type);
   END IF;
   if(l_document_type in ('INVOICE', 'DEBIT_MEMO', 'ON_ACCT_CREDIT_MEMO'))then
	if(g_line_level_action ='CREATE') then
	  l_Tax_link.GrossAmt	:= abs(pg_line_amount_tab(I));
	  l_Tax_link.InvoiceDate	:= pg_trx_date_tab(I);
	  l_Tax_link.CalcType	:= 'G';
	elsif(g_line_level_action ='DELETE') then
	  l_Tax_link.GrossAmt	:= abs(arp_line_amount);
  	  l_Tax_link.InvoiceDate	:= arp_trx_date;
	  l_Tax_link.CalcType	:= 'G';
	end if;

   elsif(l_document_type in ('APPLIED_CREDIT_MEMO'))then

	BEGIN
          SELECT nvl(zd.partner_migrated_flag, 'N')     -- Bug 5007293
          INTO   pg_ugraded_inv_flag_tab(I)
          FROM ZX_LINES_DET_FACTORS zd
          WHERE zd.event_class_mapping_id  = pg_adj_doc_doc_type_id_tab(i)
          AND zd.trx_id                    = pg_adj_doc_trx_id_tab(i)
          AND zd.trx_line_id               = pg_adj_doc_line_id_tab(i)
          AND zd.trx_level_type            = pg_adj_doc_trx_lev_type_tab(i)
          AND EXISTS (SELECT 'Y'
                      FROM ZX_LINES zl
                      WHERE zl.application_id = zd.application_id
                      AND zl.entity_code = zd.entity_code
                      AND zl.event_class_code = zd.event_class_code
                      AND zl.trx_id = pg_adj_doc_trx_id_tab(i)
                      AND zl.trx_line_id = pg_adj_doc_line_id_tab(i)
                      AND zl.trx_level_type = pg_adj_doc_trx_lev_type_tab(i)
                      AND zl.tax = 'LOCATION');
        EXCEPTION
          WHEN OTHERS THEN
            pg_ugraded_inv_flag_tab(I) := 'N';
        END;

	if(g_line_level_action ='CREATE') then
          l_Tax_link.GrossAmt	:= abs(pg_line_amount_tab(I));
	  l_Tax_link.InvoiceDate	:= pg_adj_doc_date_tab(I);
	  l_Tax_link.CalcType	:= 'G';
        elsif(g_line_level_action ='DELETE') then
	  l_Tax_link.GrossAmt	:= abs(arp_line_amount);
	  l_Tax_link.InvoiceDate	:= arp_adj_doc_date;
	  l_Tax_link.CalcType	:= 'G';
        end if;
   elsif(l_document_type in ('TAX_ONLY_CREDIT_MEMO'))then
	if(g_line_level_action ='CREATE') then
          l_Tax_link.GrossAmt	:= 0;
	  l_Tax_link.InvoiceDate	:= pg_adj_doc_date_tab(I);
	  l_Tax_link.CalcType	:= 'E';
	  l_Tax_link.TaxAmt	:= abs(g_StTaxAmt+g_CoTaxAmt+g_CiTaxAmt);
	  l_Tax_link.StOvAmt	:= abs(g_StTaxAmt);
	  l_Tax_link.CnOvAmt	:= abs(g_CoTaxAmt);
	  l_Tax_link.LoOvAmt	:= abs(g_CiTaxAmt);
	IF(g_StTaxAmt+g_CoTaxAmt+g_CiTaxAmt<0) then
	   l_tax_link.CreditInd :=TRUE;
	else
	   l_tax_link.CreditInd :=FALSE;
	end if;

        elsif(g_line_level_action ='DELETE') then
	  l_Tax_link.GrossAmt	:= 0;
	  l_Tax_link.InvoiceDate	:= arp_adj_doc_date;
	  l_Tax_link.CalcType	:= 'E';
	  l_Tax_link.TaxAmt	:= abs(g_StTaxAmt+g_CoTaxAmt+g_CiTaxAmt);
	  l_Tax_link.StOvAmt	:= abs(g_StTaxAmt);
	  l_Tax_link.CnOvAmt	:= abs(g_CoTaxAmt);
	  l_Tax_link.LoOvAmt	:= abs(g_CiTaxAmt);
	IF(g_StTaxAmt+g_CoTaxAmt+g_CiTaxAmt>0) then
	   l_tax_link.CreditInd :=TRUE;
	else
	   l_tax_link.CreditInd :=FALSE;
	end if;
        end if;
    elsif (l_document_type in ('ADJUSTMENT'))then
	if(g_line_level_action ='CREATE') then
	  l_Tax_link.GrossAmt	:= 0;
	  l_Tax_link.InvoiceDate	:= pg_adj_doc_date_tab(I);
	  l_Tax_link.CalcType	:= 'T';
	  l_Tax_link.TaxAmt	:= abs(g_StTaxAmt+g_CoTaxAmt+g_CiTaxAmt);
	  l_Tax_link.StOvAmt	:= abs(g_StTaxAmt);
	  l_Tax_link.CnOvAmt	:= abs(g_CoTaxAmt);
	  l_Tax_link.LoOvAmt	:= abs(g_CiTaxAmt);
	IF(g_StTaxAmt+g_CoTaxAmt+g_CiTaxAmt<0) then
	   l_tax_link.CreditInd :=TRUE;
	else
	   l_tax_link.CreditInd :=FALSE;
	end if;
        elsif(g_line_level_action ='DELETE') then
	  l_Tax_link.GrossAmt	:= 0;
	  l_Tax_link.InvoiceDate	:= arp_adj_doc_date;
	  l_Tax_link.CalcType	:= 'T';
	  l_Tax_link.TaxAmt	:= abs(g_StTaxAmt+g_CoTaxAmt+g_CiTaxAmt);
	  l_Tax_link.StOvAmt	:= abs(g_StTaxAmt);
	  l_Tax_link.CnOvAmt	:= abs(g_CoTaxAmt);
	  l_Tax_link.LoOvAmt	:= abs(g_CiTaxAmt);
	IF(g_StTaxAmt+g_CoTaxAmt+g_CiTaxAmt>0) then
	   l_tax_link.CreditInd :=TRUE;
	else
	   l_tax_link.CreditInd :=FALSE;
	end if;
        end if;
  elsif(l_document_type in ('TAX_ONLY_ADJUSTMENT'))then
	  if(g_line_level_action ='CREATE') then
            l_Tax_link.GrossAmt	:= 0;
	    l_Tax_link.InvoiceDate	:= pg_adj_doc_date_tab(I);
	    l_Tax_link.CalcType	:= 'E';
	    l_Tax_link.TaxAmt	:= abs(g_StTaxAmt+g_CoTaxAmt+g_CiTaxAmt);
	    l_Tax_link.StOvAmt	:= abs(g_StTaxAmt);
	    l_Tax_link.CnOvAmt	:= abs(g_CoTaxAmt);
	    l_Tax_link.LoOvAmt	:= abs(g_CiTaxAmt);
	    IF(g_StTaxAmt+g_CoTaxAmt+g_CiTaxAmt<0) then
	      l_tax_link.CreditInd :=TRUE;
	    else
	      l_tax_link.CreditInd :=FALSE;
	    end if;
	  elsif(g_line_level_action ='DELETE') then
	    l_Tax_link.GrossAmt	:= 0;
	    l_Tax_link.InvoiceDate	:= arp_adj_doc_date;
	    l_Tax_link.CalcType	:= 'E';
	    l_Tax_link.TaxAmt	:= abs(g_StTaxAmt+g_CoTaxAmt+g_CiTaxAmt);
	    l_Tax_link.StOvAmt	:= abs(g_StTaxAmt);
	    l_Tax_link.CnOvAmt	:= abs(g_CoTaxAmt);
	    l_Tax_link.LoOvAmt	:= abs(g_CiTaxAmt);
	    IF(g_StTaxAmt+g_CoTaxAmt+g_CiTaxAmt>0) then
	      l_tax_link.CreditInd :=TRUE;
	    else
	      l_tax_link.CreditInd :=FALSE;
	    end if;
    end if;
  elsif (l_document_type in ('SALES_QUOTE'))then --Bug5927656
      if(g_line_level_action ='CREATE') then
        l_Tax_link.GrossAmt	:= abs(pg_line_amount_tab(I));
        l_Tax_link.InvoiceDate	:= pg_trx_date_tab(I);
        l_Tax_link.CalcType	:= 'G';
      end if;
  end if;

IF (g_tax_SELECTION = ZX_TAX_TAXWARE_GEN.SELPRM_TAXES_ONLY ) THEN
-- Only (primary)Ship To information is required.
       l_Tax_link.StateCode	:= substrb(l_ship_to_code,2,2);
      l_Tax_link.PriZip		:= substrb(l_ship_to_code,4,5);
      l_Tax_link.PriGeo		:= substrb(l_ship_to_code,9,2);
      l_Tax_link.InOutCityLimits := NULL;		-- future use
   ELSE
      -- Jurisdiction information including Ship To, Ship From, POO and POA.
      -- Use Ship To for Ship From and Ship From for POO and POA if not passed!

      l_JurLink.ShipTo.State	:= substrb(l_ship_to_code,2,2);
      l_JurLink.ShipTo.Zip	:= substrb(l_ship_to_code,4,5);
      l_JurLink.ShipTo.Geo	:= substrb(l_ship_to_code,9,2);
      l_JurLink.InOutCiLimShTo	:= NULL;		-- future use

      IF (l_ship_from_code =
		arp_tax_view_taxware.USE_SHIP_TO ) THEN
        l_JurLink.ShipFr.State	:= substrb(l_ship_to_code,2,2);
        l_JurLink.ShipFr.Zip	:= substrb(l_ship_to_code,4,5);
        l_JurLink.ShipFr.Geo	:= substrb(l_ship_to_code,9,2);
        l_JurLink.InOutCiLimShFr	:= NULL;		-- future use
      ELSE
        l_JurLink.ShipFr.State	:= substrb(l_ship_from_code,2,2);
        l_JurLink.ShipFr.Zip	:= substrb(l_ship_from_code,4,5);
        l_JurLink.ShipFr.Geo	:= substrb(l_ship_from_code,9,2);
        l_JurLink.InOutCiLimShFr	:= NULL;		-- future use
      END IF;

      IF (l_poo_code  =
		arp_tax_view_taxware.USE_SHIP_TO) THEN
        l_JurLink.POO.State	:= l_JurLink.ShipFr.State;
        l_JurLink.POO.Zip	:= l_JurLink.ShipFr.Zip;
        l_JurLink.POO.Geo	:= l_JurLink.ShipFr.Geo;
        l_JurLink.InOutCiLimPOO	:= NULL;		-- future use
      ELSE
        l_JurLink.POO.State	:= substrb(l_poo_code,2,2);
        l_JurLink.POO.Zip	:= substrb(l_poo_code,4,5);
        l_JurLink.POO.Geo	:= substrb(l_poo_code,9,2);
        l_JurLink.InOutCiLimPOO	:= NULL;		-- future use
      END IF;

      IF ( l_poa_code =
		arp_tax_view_taxware.USE_SHIP_TO ) THEN
        l_JurLink.POA.State	:= l_JurLink.ShipFr.State;
        l_JurLink.POA.Zip	:= l_JurLink.ShipFr.Zip;
        l_JurLink.POA.Geo	:= l_JurLink.ShipFr.Geo;
        l_JurLink.InOutCiLimPOA	:= NULL;		-- future use
      ELSE
        l_JurLink.POA.State	:= substrb(l_poa_code,2,2);
        l_JurLink.POA.Zip		:= substrb(l_poa_code,4,5);
        l_JurLink.POA.Geo		:= substrb(l_poa_code,9,2);
        l_JurLink.InOutCiLimPOA	:= NULL;		-- future use
      END IF;

      -- Set Service Indicator , Default to 3(Non Service)
      IF l_service_indicator = 1 THEN
        l_JurLink.ServInd := SERVICE_IND;
      ELSIF l_service_indicator = 2 THEN
        l_JurLink.ServInd := RENTAL_IND;
      ELSIF l_service_indicator = 3 THEN
        l_JurLink.ServInd := NOSERV_IND;
      ELSE
        l_JurLink.ServInd := NOSERV_IND;
      END IF;

      --
      -- If FOB Point is Destination, Then the Point of Title passage(POT)
      -- will be set to POT_DEST. All other values will be set to POT_ORIG.
      --

      If(g_line_level_action = 'CREATE') then
        l_fob_point		:=pg_fob_point_tab(I);
      else
	l_fob_point		:=arp_fob_point;
      end if;

      IF ( substrb(l_fob_point,1,1) = 'D' ) THEN
            l_JurLink.POT := ZX_TAX_TAXWARE_GEN.POT_DEST;
      ELSE
            l_JurLink.POT := ZX_TAX_TAXWARE_GEN.POT_ORIG;
      END IF;

 END IF;

if(g_line_level_action='CREATE') then
	l_use_step		:=pg_line_char3_tab(i);
	l_step_proc_flag	:=pg_line_char7_tab(i);
	l_job_no		:=pg_line_char16_tab(i);
	l_criterion_flag	:=pg_line_char19_tab(i);
	l_prod_ind		:=pg_line_char17_tab(i);
else
	l_use_step		:= use_step;
	l_step_proc_flag	:= step_proc_flag;
	l_job_no		:= arp_vnd_ctrl_exmpt;
	l_criterion_flag	:= crit_flag;
	l_prod_ind		:= arp_use_nexpro;
end if;


If(g_line_level_action='CREATE') then
  if(pg_exempt_cont_flag_tab(I)='R') then
	   l_use_step:='N';
  end if;
Else
  if(arp_exempt_control_flag='R') then
	   l_use_step:='N';
  end if;
End if;
   l_Tax_link.UseStep      := l_use_step;
   l_Tax_link.StepProcFlg  := l_step_proc_flag;
   l_Tax_link.JobNo        := substrb(l_job_no, 1, 10);
   l_Tax_link.CritFlg      := l_criterion_flag;
   l_Tax_link.UseNexproInd := l_prod_ind;


  -- Exempt using No Tax Indicators?
   IF ( nvl(substrb(l_calculation_flag,1,1),'0') = '0' AND
        nvl(substrb(l_calculation_flag,2,1),'0') = '0' AND
        nvl(substrb(l_calculation_flag,3,1),'0') = '0' AND
        nvl(substrb(l_calculation_flag,4,1),'0') = '0' AND
        nvl(substrb(l_calculation_flag,5,1),'0') = '0' )
   THEN

	-- Do not exempt at the jurisdiction level
	l_Tax_link.StaExempt := FALSE;
	l_Tax_link.CnExempt := FALSE;
	l_Tax_link.LoExempt := FALSE;
	l_Tax_link.SecCnExempt := FALSE;
	l_Tax_link.SecLoExempt := FALSE;
   ELSE
	-- Exempt 100% at the appropriate level
	l_Tax_link.NoStaTax :=
		nvl(substrb(l_calculation_flag,1,1),'0') = '1';
	l_Tax_link.StaExempt :=
		nvl(substrb(l_calculation_flag,1,1),'0') = '1';
	l_Tax_link.NoCnTax  :=
		nvl(substrb(l_calculation_flag,2,1),'0') = '1';
	l_Tax_link.CnExempt :=
		nvl(substrb(l_calculation_flag,2,1),'0') = '1';
	l_Tax_link.NoLoTax  :=
		nvl(substrb(l_calculation_flag,3,1),'0') = '1';
	l_Tax_link.LoExempt :=
		nvl(substrb(l_calculation_flag,3,1),'0') = '1';
	l_Tax_link.NoSecCnTax  :=
		nvl(substrb(l_calculation_flag,4,1),'0') = '1';
	l_Tax_link.SecCnExempt :=
		nvl(substrb(l_calculation_flag,4,1),'0') = '1';
	l_Tax_link.NoSecLoTax  :=
		nvl(substrb(l_calculation_flag,5,1),'0') = '1';
	l_Tax_link.SecLoExempt :=
		nvl(substrb(l_calculation_flag,5,1),'0') = '1';
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Value of l_state_exempt_reason is :'||l_state_exempt_reason);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Value of l_county_exempt_reason is :'||l_county_exempt_reason);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Value of l_city_exempt_reason is :'||l_city_exempt_reason);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Value of l_sec_county_exempt_reason is :'||l_sec_county_exempt_reason);
   END IF;

   -- Oracle State level Exemption exists?
   IF ( l_state_exempt_reason IS NOT NULL ) THEN

      -- Pass Oracle Exemptions info to Taxware
      l_Tax_link.StReasonCode := substrb(l_state_exempt_reason,1,2);

      /**********************************************************
       * commented out, otherwise taxware treats as 100% exempt *
       **********************************************************/
      --l_Tax_link.StTaxCertNo := substrb(l_state_cert_no, 1, 25);
      l_Tax_link.StTaxCertNo := NULL;

      IF ( l_state_exempt_percent IS NOT NULL ) THEN

	    IF ( l_Tax_link.StaExempt = TRUE ) THEN
		l_Tax_link.StExemptAmt := 0;	-- Use State No Tax Indicator
	    ELSE
		l_Tax_link.StaExempt := TRUE;

	        IF ( l_state_exempt_percent = 100 ) THEN
		   l_Tax_link.StExemptAmt := l_Tax_link.GrossAmt;
		ELSE
                   l_Tax_link.StExemptAmt :=
				abs(l_Tax_link.GrossAmt*
				      	(l_state_exempt_percent/100)) ;
		END IF;		-- 100% exemption?

	    END IF;	-- l_Tax_link.Exempt = TRUE, Exempt using No Tax indicator?
      END IF;		-- % Exemption specified?
   END IF;		-- Exemption reason specified?


   -- Oracle County level Exemption exists?
   IF ( l_county_exempt_reason IS NOT NULL ) THEN

      -- Pass Oracle Exemptions info to Taxware
      l_Tax_link.CntyReasonCode := substrb(l_county_exempt_reason,1,2);

      /**********************************************************
       * commented out, otherwise taxware treats as 100% exempt *
       **********************************************************/
      --l_Tax_link.CnTaxCertNo := substrb(l_county_cert_no, 1, 25);
      l_Tax_link.CnTaxCertNo := NULL;

      IF ( l_county_exempt_percent IS NOT NULL ) THEN

	    IF ( l_Tax_link.CnExempt = TRUE ) THEN
		l_Tax_link.CntyExemptAmt := 0;	-- Use County No Tax Indicator
	    ELSE
		l_Tax_link.CnExempt := TRUE;

	        IF ( l_county_exempt_percent = 100 ) THEN
		   l_Tax_link.CntyExemptAmt := l_Tax_link.GrossAmt;
		ELSE
                   l_Tax_link.CntyExemptAmt :=
				abs(l_Tax_link.GrossAmt *
				      	(l_county_exempt_percent/100));
		END IF;		-- 100% exemption?

	    END IF;	-- l_Tax_link.Exempt = TRUE, Exempt using No Tax indicator?
      END IF;		-- % Exemption specified?
   END IF;		-- Exemption reason specified?

   -- Oracle City level Exemption exists?
   IF ( l_city_exempt_reason IS NOT NULL ) THEN

      -- Pass Oracle Exemptions info to Taxware
      l_Tax_link.CityReasonCode := substrb(l_city_exempt_reason,1,2);

      /**********************************************************
       * commented out, otherwise taxware treats as 100% exempt *
       **********************************************************/
      --l_Tax_link.LoTaxCertNo := substrb(l_city_cert_no, 1, 25);
      l_Tax_link.LoTaxCertNo := NULL;

      IF ( l_city_exempt_percent IS NOT NULL ) THEN

	    IF ( l_Tax_link.LoExempt = TRUE ) THEN
		l_Tax_link.CityExemptAmt := 0;	-- Use County No Tax Indicator
	    ELSE
		l_Tax_link.LoExempt := TRUE;

	        IF ( l_city_exempt_percent = 100 ) THEN
		   l_Tax_link.CityExemptAmt := l_Tax_link.GrossAmt;
		ELSE
                   l_Tax_link.CityExemptAmt :=
				abs(l_Tax_link.GrossAmt *
				      	(l_city_exempt_percent/100));
		END IF;		-- 100% exemption?

	    END IF;	-- l_Tax_link.Exempt = TRUE, Exempt using No Tax indicator?
      END IF;		-- % Exemption specified?
   END IF;		-- Exemption reason specified?

   -- Oracle Secondary County level Exemption exists?
   -- Secondary County exemptions do not require Reason Code and Certificate
   IF ( l_sec_county_exempt_reason IS NOT NULL OR
	l_Tax_link.SecCnExempt ) THEN

      IF ( l_sec_county_exempt_percent IS NOT NULL ) THEN

	    IF ( l_Tax_link.SecCnExempt = TRUE ) THEN
		l_Tax_link.SecCnExemptAmt := 0;	-- Use Sec County No Tax Indicator
	    ELSE
		l_Tax_link.SecCnExempt := TRUE;

	        IF ( l_sec_county_exempt_percent = 100 ) THEN
		   l_Tax_link.SecCnExemptAmt := l_Tax_link.GrossAmt;
		ELSE
                   l_Tax_link.SecCnExemptAmt :=
				abs(l_Tax_link.GrossAmt *
				      	(l_sec_county_exempt_percent/100));
		END IF;		-- 100% exemption?

	    END IF;	-- l_Tax_link.Exempt = TRUE, Exempt using No Tax indicator?
      END IF;		-- % Exemption specified?
   END IF;		-- Exemption reason specified?

   -- Oracle Secondary City level Exemption exists?
   -- Secondary City exemptions do not require Reason Code and Certificate
   IF ( l_sec_city_exempt_reason IS NOT NULL OR
	l_Tax_link.SecLoExempt ) THEN

      IF ( l_sec_city_exempt_percent IS NOT NULL ) THEN

	    IF ( l_Tax_link.SecLoExempt = TRUE ) THEN
		l_Tax_link.SecLoExemptAmt := 0;	-- Use Sec City No Tax Indicator
	    ELSE
		l_Tax_link.SecLoExempt := TRUE;

	        IF ( l_sec_city_exempt_percent = 100 ) THEN
		   l_Tax_link.SecLoExemptAmt := l_Tax_link.GrossAmt;
		ELSE
                   l_Tax_link.SecLoExemptAmt :=
				abs(l_Tax_link.GrossAmt *
				      	(l_sec_city_exempt_percent/100));
		END IF;		-- 100% exemption?

	    END IF;	-- l_Tax_link.Exempt = TRUE, Exempt using No Tax indicator?
      END IF;		-- % Exemption specified?
   END IF;		-- Exemption reason specified?
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;
     Return TRUE;
EXCEPTION
	When OTHERS then
	   IF (g_level_exception >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_exception,G_PKG_NAME||'.'||l_api_name,
                           'Failed in setting the parameters');
                  FND_LOG.STRING(g_level_exception,G_PKG_NAME||'.'||l_api_name,
                           'Error is :'||sqlcode || sqlerrm);
           END IF;
           Return FALSE;
END ;--SET_PARMETERS;

Function CALCULATE_TAX (
l_TaxLink 	IN OUT NOCOPY zx_tax_taxware_GEN.TaxParm,
l_JurLink 	IN OUT NOCOPY zx_tax_taxware_GEN.JurParm,
l_OraLink       IN OUT NOCOPY zx_tax_taxware_GEN.t_OraParm  ) return boolean is

   Tax_Success			BOOLEAN;
   Valid_Err			BOOLEAN;
   return_code			boolean;

l_api_name  CONSTANT VARCHAR2(30) := 'CALCULATE_TAX';
BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Calling Taxware ZX_TAX_TAXWARE_010.Taxfn_Tax010');
    END IF;

     BEGIN

      		Tax_Success := ZX_TAX_TAXWARE_010.Taxfn_Tax010(l_OraLink,
                                                                l_TaxLink,
   			  		                        g_tax_selection,
   			  		                        l_JurLink);
      EXCEPTION
		WHEN OTHERS THEN
		        IF (g_level_exception >= g_current_runtime_level ) THEN
                            FND_LOG.STRING(g_level_exception,G_PKG_NAME||'.'||l_api_name,
                           'Taxware raised unexpected error:'||sqlerrm);
                        END IF;
			stack_error('GENERIC_MESSAGE', 'GENERIC_TEXT',
				    'Taxware raised unexpected error:  '||
				     sqlcode||':'||sqlerrm,null,null);
			RETURN FALSE;
      END;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	            '-- calculate()... after  ZX_TAX_TAXWARE_010.Taxfn_Tax010() '||to_char(sysdate, 'DD-MON-RR HH24:MI:SS'));
      END IF;

     /*-------------------------------------------------------------+
      | If Tax Calculated in error, Handle error.                   |
      +-------------------------------------------------------------*/
      IF NOT Tax_Success THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	         '-- calculate()... Tax vendor error.');
		  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	         '-- calculate()... before ZX_TAX_TAXWARE_010.Taxfn910_ValidErr()');
           END IF;
           BEGIN
		Valid_Err := ZX_TAX_TAXWARE_010.Taxfn910_ValidErr(l_TaxLink.GenCmplCd);
	   EXCEPTION
		WHEN OTHERS THEN
		        IF (g_level_exception >= g_current_runtime_level ) THEN
                            FND_LOG.STRING(g_level_exception,G_PKG_NAME||'.'||l_api_name,
                           'Taxware raised unexpected error during error checking:'||sqlerrm);
                        END IF;
			stack_error('GENERIC_MESSAGE', 'GENERIC_TEXT',
					    'Taxware raised unexpected error during error checking:  '||
					     sqlcode||':'||sqlerrm,null,null);
			RETURN FALSE;
	   END;
	   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'Calling Get_Vendor_Error');
           END IF;

	   Get_Vendor_Error(g_tax_selection,
   				 l_TaxLink,
   				 l_JurLink);
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             'After Calling Get_Vendor_Error');
           END IF;

      	   return_code := False;

      ELSE
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             '-- calculate()... Tax vendor success.');
           END IF;

   	   return_code := TRUE;
      END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

  RETURN ( return_code );

End;

PROCEDURE TAX_RESULTS_PROCESSING(
p_tax_lines_tbl    OUT NOCOPY  ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
p_currency_tab  IN OUT NOCOPY  ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
l_TaxLink 	IN OUT NOCOPY  zx_tax_taxware_GEN.TaxParm,
l_JurLink 	IN OUT NOCOPY  zx_tax_taxware_GEN.JurParm,
l_OraLink       IN OUT NOCOPY  zx_tax_taxware_GEN.t_OraParm,
x_return_status     OUT NOCOPY VARCHAR2) IS
J number;
x_tax_jurisdiction_code ZX_JURISDICTIONS_B.tax_jurisdiction_code%type;
p_location_id           NUMBER;
l_regime_code           ZX_REGIMES_B.tax_regime_code%type;
state_tax_rate          NUMBER; -- state tax rate in %
state_tax_amount        NUMBER; -- state tax amount
county_tax_rate         NUMBER; -- county tax rate in %
county_tax_amount       NUMBER; -- county tax amount
city_tax_rate           NUMBER; -- city tax rate in %
city_tax_amount         NUMBER; -- city tax amount
dist_tax_rate           NUMBER; -- district tax rate in %
dist_tax_amount         NUMBER; -- district tax amounts
sec_state_tax_rate      NUMBER; -- secondary state tax rate in %
sec_state_tax_amount    NUMBER; -- secondary state tax amount
sec_county_tax_rate     NUMBER; -- secondary county tax rate
sec_county_tax_amount   NUMBER; -- secondary county tax amount
sec_city_tax_rate       NUMBER; -- secondary city tax rate
sec_city_tax_amount     NUMBER; -- secondary city tax amount
l_situs                 VARCHAR2(20);
sign_flag		number;
l_api_name           CONSTANT VARCHAR2(30) := 'TAX_RESULTS_PROCESSING';
l_return_status         VARCHAR2(30);
ind			NUMBER;
Begin

 x_return_status	:= FND_API.G_RET_STS_SUCCESS;

 IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
 END IF;

l_regime_code          := zx_tax_partner_pkg.g_tax_regime_code;
l_situs := 'SHIP_TO';/*need to check can we add any logic for this*/

  IF l_situs =  'SHIP_TO' THEN
/* Bug 5090593: Making use of the location ids passed thru view.
           select nvl(ship_to_location_id, bill_to_location_id)
           INTO    p_location_id
 	   From    zx_lines_det_factors
 	   WHERE
                   event_class_mapping_id =  pg_doc_type_id_tab(I) and
		   trx_id	  =  pg_trx_id_tab(I) and
 	           trx_line_id    =  pg_trx_line_id_tab(I) and
		   trx_level_type  =  pg_trx_level_type_tab(I);
*/
           p_location_id := nvl(pg_ship_to_loc_id_tab(I), pg_bill_to_loc_id_tab(I));

	ELSIF l_situs =  'SHIP_FROM' THEN
/* Bug 5090593: Making use of the location ids passed thru view.
           select nvl(ship_from_location_id, bill_from_location_id)
           INTO    p_location_id
 	   From    zx_lines_det_factors
 	   WHERE
		   event_class_mapping_id =  pg_doc_type_id_tab(I) and
                   trx_id       =  pg_trx_id_tab(I) and
 	           trx_line_id  =  pg_trx_line_id_tab(I) and
		   trx_level_type  =  pg_trx_level_type_tab(I);
*/
           p_location_id := nvl(pg_ship_fr_loc_id_tab(I), pg_bill_fr_loc_id_tab(I));
	else null;
        END IF;

	IF ( l_TaxLink.CreditInd ) THEN
	    sign_flag:=-1;
	Else sign_flag:=1;
	End if;

    p_currency_tab(1).tax_currency_precision      := 2;   -- Bug 5288518
    /*-----------------------------------------------------------
     | Populate Tax Amounts and Rates				|
     -----------------------------------------------------------*/
    /* State tax rate */
    state_tax_rate := l_TaxLink.StaTxRate * 100;
    /* State tax amount */
    state_tax_amount := sign_flag*l_TaxLink.StaTxAmt;
    /* County tax rate */
    county_tax_rate := l_TaxLink.CnTxRate * 100;
    /* County tax amount */
    county_tax_amount := sign_flag*l_TaxLink.CnTxAmt;
    /* City tax Rate */
    city_tax_rate := l_TaxLink.LoTxRate * 100;
    /* City tax amount */
    city_tax_amount := sign_flag*l_TaxLink.LoTxAmt;
    /* Secondary State tax rate */
    sec_state_tax_rate := l_TaxLink.ScStTxRate * 100;
    /* secondary state tax amount */
    sec_state_tax_amount := sign_flag*l_TaxLink.ScStTxAmt;
    /* Secondary county Rate */
    sec_county_tax_rate := l_TaxLink.ScCnTxRate * 100;
    /* Secondary County tax amount */
    sec_county_tax_amount := sign_flag*l_TaxLink.ScCnTxAmt;
    /* Secondary City tax Rate */
    sec_city_tax_rate := l_TaxLink.ScLoTxRate * 100;
    /* secondary City tax amount */
    sec_city_tax_amount := sign_flag*l_TaxLink.ScLoTxAmt;


   IF pg_ugraded_inv_flag_tab(I) = 'Y' THEN
        p_tax_lines_tbl.document_type_id(i)           := pg_doc_type_id_tab(I);
        p_tax_lines_tbl.transaction_id(i)             := pg_trx_id_tab(I);
        p_tax_lines_tbl.transaction_line_id(i)        := pg_trx_line_id_tab(I);
        p_tax_lines_tbl.trx_level_type(i)             := pg_trx_level_type_tab(I);
        p_tax_lines_tbl.country_code(i)               := l_regime_code ;
        p_tax_lines_tbl.situs(i)                      := l_situs;
        p_tax_lines_tbl.tax_currency_code(i)          := p_currency_tab(1).tax_currency_code;
        p_tax_lines_tbl.Inclusive_tax_line_flag(i)    := 'N';
        p_tax_lines_tbl.Line_amt_includes_tax_flag(i) := 'N';
        p_tax_lines_tbl.use_tax_flag(i)               := 'N';
        p_tax_lines_tbl.User_override_flag(i)         := 'N'; -- Need to see if different for override_tax
        p_tax_lines_tbl.last_manual_entry(i)          := NULL;
        p_tax_lines_tbl.manually_entered_flag(i)      := 'N'; -- Need to see if different for override_tax
        p_tax_lines_tbl.registration_party_type(i)    := NULL;  -- Bug 5288518
        p_tax_lines_tbl.party_tax_reg_number(i)       := NULL;  -- Bug 5288518
        p_tax_lines_tbl.third_party_tax_reg_number(i) := NULL;
        p_tax_lines_tbl.threshold_indicator_flag(i)   := Null;
        p_tax_lines_tbl.State(i)                      := l_JurLink.JurState;
        p_tax_lines_tbl.County(i)                     := NULL;
        p_tax_lines_tbl.City(i)                       := l_JurLink.JurCity;
        p_tax_lines_tbl.tax_only_line_flag(i)         := 'N';
        p_tax_lines_tbl.Tax(i)                        := 'LOCATION';
        p_tax_lines_tbl.tax_amount(i)                 :=  (state_tax_amount+sec_state_tax_amount)
                                                          + (county_tax_amount +sec_county_tax_amount)
                                                          + (city_tax_amount +sec_city_tax_amount);
        --added them
        p_tax_lines_tbl.unrounded_tax_amount(i)       :=  (state_tax_amount+sec_state_tax_amount)
                                                          + (county_tax_amount +sec_county_tax_amount)
                                                          + (city_tax_amount +sec_city_tax_amount);
        p_tax_lines_tbl.tax_curr_tax_amount(i)        := p_tax_lines_tbl.tax_amount(i) * p_currency_tab(1).exchange_rate;
        p_tax_lines_tbl.tax_rate_percentage(i)        :=  (state_tax_rate+sec_state_tax_rate)
                                                          + (county_tax_rate +sec_county_tax_rate)
                                                          + (city_tax_rate +sec_city_tax_rate);

        p_tax_lines_tbl.taxable_amount(i)             := sign_flag * l_TaxLink.StBasisAmt;

        p_tax_lines_tbl.tax_jurisdiction(i)           := NULL;
        -- Can alternatively call GET_TAX_JUR_CODE for tax = 'CITY'  (lowest level jurisdiction)

        p_tax_lines_tbl.global_attribute_category(i)  := 'TAXWARE';
        p_tax_lines_tbl.global_attribute2(i)          := to_char((state_tax_amount+sec_state_tax_amount));
        p_tax_lines_tbl.global_attribute4(i)          := to_char((county_tax_amount +sec_county_tax_amount));
        p_tax_lines_tbl.global_attribute6(i)          := to_char((city_tax_amount +sec_city_tax_amount));


        p_tax_lines_tbl.exempt_reason(i)              :=l_TaxLink.StReasonCode;

        IF (NVL(l_TaxLink.StExemptAmt, 0) + NVL(l_TaxLink.CntyExemptAmt, 0)
                                                  + NVL(l_TaxLink.CityExemptAmt, 0)) <> 0 THEN
          IF (l_TaxLink.GrossAmt <> 0) then
             p_tax_lines_tbl.exempt_rate_modifier(i)  := (l_TaxLink.StExemptAmt +
                                                          l_TaxLink.CntyExemptAmt +
                                                          l_TaxLink.CityExemptAmt)/
                                                         l_TaxLink.GrossAmt;
             p_tax_lines_tbl.exempt_certificate_number(i) := l_state_cert_no;
          ELSE
            p_tax_lines_tbl.exempt_rate_modifier(i)   := 0;
            p_tax_lines_tbl.exempt_certificate_number(i) := NULL;
          END IF;
        ELSE
          p_tax_lines_tbl.exempt_rate_modifier(i)     := 0;
          p_tax_lines_tbl.exempt_certificate_number(i) := NULL;
        END IF;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'tax line output ');
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.document_type_id('||ind||') = '|| to_char(p_tax_lines_tbl.document_type_id(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.transaction_id('||ind||') = '|| to_char(p_tax_lines_tbl.transaction_id(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.transaction_line_id('||ind||') = '||
                to_char(p_tax_lines_tbl.transaction_line_id(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.trx_level_type('||ind||') = '||
                p_tax_lines_tbl.trx_level_type(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.country_code('||ind||') = '|| p_tax_lines_tbl.country_code(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.Tax('||ind||') = '|| p_tax_lines_tbl.Tax(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.situs('||ind||') = '|| p_tax_lines_tbl.situs(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.tax_jurisdiction('||ind||') = '||
		p_tax_lines_tbl.tax_jurisdiction(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.tax_currency_code('||ind||') = '|| p_tax_lines_tbl.tax_currency_code(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.TAX_CURR_TAX_AMOUNT('||ind||')  = '||
		to_char(p_tax_lines_tbl.TAX_CURR_TAX_AMOUNT(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.tax_amount('||ind||') = '|| to_char(p_tax_lines_tbl.tax_amount(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.tax_rate_percentage('||ind||') = '||
		to_char(p_tax_lines_tbl.tax_rate_percentage(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.taxable_amount('||ind||') = '||
		to_char(p_tax_lines_tbl.taxable_amount(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.State('||ind||') = '|| p_tax_lines_tbl.State(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.County('||ind||') = '|| p_tax_lines_tbl.County(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.City('||ind||') = '|| p_tax_lines_tbl.City(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.unrounded_tax_amount('||ind||') = '||
		to_char(p_tax_lines_tbl.unrounded_tax_amount(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.exempt_certificate_number('||ind||') = '||
                p_tax_lines_tbl.exempt_certificate_number(ind));
           --bug7140895
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute_category('||ind||') = '|| p_tax_lines_tbl.global_attribute_category(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute2('||ind||') = '|| p_tax_lines_tbl.global_attribute2(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute4('||ind||') = '|| p_tax_lines_tbl.global_attribute4(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute6('||ind||') = '|| p_tax_lines_tbl.global_attribute6(ind));
        END IF;

   ELSE
    For J in 1..3
    loop
    ind:=j+(3*i-3);
	p_tax_lines_tbl.document_type_id(ind)      := pg_doc_type_id_tab(I);
	p_tax_lines_tbl.transaction_id(ind)		:= pg_trx_id_tab(I);
	p_tax_lines_tbl.transaction_line_id(ind)	:= pg_trx_line_id_tab(I);
	p_tax_lines_tbl.trx_level_type(ind)             := pg_trx_level_type_tab(I);
	p_tax_lines_tbl.country_code(ind)      	:= l_regime_code;
	p_tax_lines_tbl.tax_currency_code(ind)	:= p_currency_tab(1).tax_currency_code;
	p_tax_lines_tbl.situs(ind)                  := l_situs;
	p_tax_lines_tbl.State(ind)			:= l_JurLink.JurState;
	p_tax_lines_tbl.County(ind)			:= null; /*Need to check what should be the value for this*/
	p_tax_lines_tbl.City(ind)			:= l_JurLink.JurCity ;
	p_tax_lines_tbl.Inclusive_tax_line_flag(ind)  := 'N';
	p_tax_lines_tbl.Line_amt_includes_tax_flag(ind)   := 'N';
	p_tax_lines_tbl.use_tax_flag(ind)		:= 'N';
	p_tax_lines_tbl.User_override_flag(ind)	:= 'N'; -- Need to see if different for override_tax
        p_tax_lines_tbl.last_manual_entry(ind)          := NULL;
	p_tax_lines_tbl.manually_entered_flag(ind)	:= 'N'; -- Need to see if different for override_tax
	p_tax_lines_tbl.registration_party_type(ind)      := Null;   -- Bug 5288518
	p_tax_lines_tbl.party_tax_reg_number(ind)	        := Null;   -- Bug 5288518
	p_tax_lines_tbl.Third_party_tax_reg_number(ind)	:= Null;
	p_tax_lines_tbl.threshold_indicator_flag(ind)	:= Null;
     	p_tax_lines_tbl.tax_only_line_flag(ind)	:= 'N';
        --bug7140895
        p_tax_lines_tbl.global_attribute_category(ind) := 'TAXWARE';
        p_tax_lines_tbl.global_attribute2(ind) := null;
        p_tax_lines_tbl.global_attribute4(ind) := null;
        p_tax_lines_tbl.global_attribute6(ind) := null;

	IF J=1 then /*Case for State*/
		p_tax_lines_tbl.Tax(ind)				 := 'STATE';
		p_tax_lines_tbl.tax_amount(ind)			 := state_tax_amount+sec_state_tax_amount;
		p_tax_lines_tbl.unrounded_tax_amount(ind)		 := state_tax_amount+sec_state_tax_amount;
		p_tax_lines_tbl.TAX_CURR_TAX_AMOUNT(ind) 		 := p_tax_lines_tbl.tax_amount(ind)*p_currency_tab(1).exchange_rate;
		p_tax_lines_tbl.tax_rate_percentage(ind) 		 := state_tax_rate+sec_state_tax_rate;
		p_tax_lines_tbl.taxable_amount(ind) 		 := sign_flag * l_TaxLink.StBasisAmt;
	  IF (l_TaxLink.StExemptAmt<>0) THEN
	     if (l_TaxLink.GrossAmt<>0) then
                p_tax_lines_tbl.exempt_rate_modifier(ind) := l_TaxLink.StExemptAmt/l_TaxLink.GrossAmt;
                p_tax_lines_tbl.exempt_certificate_number(ind)	:= l_state_cert_no;
             end if;
          ELSE
             p_tax_lines_tbl.exempt_rate_modifier(ind) := 0;
             p_tax_lines_tbl.exempt_certificate_number(ind) := NULL;
          END IF;
		p_tax_lines_tbl.exempt_reason(ind) 			 :=l_TaxLink.StReasonCode;
	ELSIF J=2 then
           	p_tax_lines_tbl.Tax(ind)				 := 'COUNTY';
		p_tax_lines_tbl.tax_amount(ind)			 :=county_tax_amount +sec_county_tax_amount;
		p_tax_lines_tbl.unrounded_tax_amount(ind)		 := county_tax_amount +sec_county_tax_amount;
		p_tax_lines_tbl.TAX_CURR_TAX_AMOUNT(ind) 		 := p_tax_lines_tbl.tax_amount(ind) *p_currency_tab(1).exchange_rate;
		p_tax_lines_tbl.tax_rate_percentage(ind) 		 := county_tax_rate +sec_county_tax_rate ;
		p_tax_lines_tbl.taxable_amount(ind) 		 := sign_flag * l_TaxLink.CntyBasisAmt;
	  IF (l_TaxLink.CntyExemptAmt<>0) THEN
	     if (l_TaxLink.GrossAmt<>0) then
		p_tax_lines_tbl.exempt_rate_modifier(ind) := l_TaxLink.CntyExemptAmt/l_TaxLink.GrossAmt;
                p_tax_lines_tbl.exempt_certificate_number(ind)	:= l_county_cert_no;
             end if;
          ELSE
             p_tax_lines_tbl.exempt_rate_modifier(ind) := 0;
             p_tax_lines_tbl.exempt_certificate_number(ind) := NULL;
          END IF;
		p_tax_lines_tbl.exempt_reason(ind) 			 :=l_TaxLink.CntyReasonCode;
	ELSIF J=3 then

               	p_tax_lines_tbl.Tax(ind)				 := 'CITY';
		p_tax_lines_tbl.tax_amount(ind)			 := (city_tax_amount +sec_city_tax_amount);
		p_tax_lines_tbl.unrounded_tax_amount(ind)		 := city_tax_amount +sec_city_tax_amount ;
		p_tax_lines_tbl.tax_curr_tax_amount(ind) 		 := p_tax_lines_tbl.unrounded_tax_amount(ind)*p_currency_tab(1).exchange_rate;
		p_tax_lines_tbl.tax_rate_percentage(ind) 		 := city_tax_rate +sec_city_tax_rate;
		p_tax_lines_tbl.taxable_amount(ind) 		 := sign_flag * l_TaxLink.CityBasisAmt;
	  IF (l_TaxLink.CityExemptAmt<>0) THEN
	     if (l_TaxLink.GrossAmt<>0) then
		p_tax_lines_tbl.exempt_rate_modifier(ind)	:= l_TaxLink.CityExemptAmt/l_TaxLink.GrossAmt;
                p_tax_lines_tbl.exempt_certificate_number(ind)	:= l_city_cert_no;
            end if;
          ELSE
             p_tax_lines_tbl.exempt_rate_modifier(ind) := 0;
             p_tax_lines_tbl.exempt_certificate_number(ind) := NULL;
          END IF;
		p_tax_lines_tbl.exempt_reason(ind) 			 :=l_TaxLink.CityReasonCode;
        else null;
	END IF;
               GET_TAX_JUR_CODE (p_location_id          ,
	 	          p_tax_lines_tbl.Situs(ind)    ,
	                  p_tax_lines_tbl.Tax(ind)      ,
                          l_regime_code		        ,
	       	          pg_trx_date_tab(I)	   	,
	 	          x_tax_jurisdiction_code 	,
	 	          l_return_status
	 	         );

		p_tax_lines_tbl.tax_jurisdiction(ind) 		 := x_tax_jurisdiction_code;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'tax line output ');
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.document_type_id('||ind||') = '|| to_char(p_tax_lines_tbl.document_type_id(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.transaction_id('||ind||') = '|| to_char(p_tax_lines_tbl.transaction_id(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.transaction_line_id('||ind||') = '||
                to_char(p_tax_lines_tbl.transaction_line_id(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.trx_level_type('||ind||') = '||
                p_tax_lines_tbl.trx_level_type(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.country_code('||ind||') = '|| p_tax_lines_tbl.country_code(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.Tax('||ind||') = '|| p_tax_lines_tbl.Tax(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.situs('||ind||') = '|| p_tax_lines_tbl.situs(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.tax_jurisdiction('||ind||') = '||
		p_tax_lines_tbl.tax_jurisdiction(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.tax_currency_code('||ind||') = '|| p_tax_lines_tbl.tax_currency_code(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.TAX_CURR_TAX_AMOUNT('||ind||')  = '||
		to_char(p_tax_lines_tbl.TAX_CURR_TAX_AMOUNT(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.tax_amount('||ind||') = '|| to_char(p_tax_lines_tbl.tax_amount(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.tax_rate_percentage('||ind||') = '||
		to_char(p_tax_lines_tbl.tax_rate_percentage(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.taxable_amount('||ind||') = '||
		to_char(p_tax_lines_tbl.taxable_amount(ind)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.State('||ind||') = '|| p_tax_lines_tbl.State(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.County('||ind||') = '|| p_tax_lines_tbl.County(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.City('||ind||') = '|| p_tax_lines_tbl.City(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.unrounded_tax_amount('||ind||') = '||
		to_char(p_tax_lines_tbl.unrounded_tax_amount(ind)));
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.exempt_certificate_number('||ind||') = '||
                p_tax_lines_tbl.exempt_certificate_number(ind));
           --bug7140895
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute_category('||ind||') = '|| p_tax_lines_tbl.global_attribute_category(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute2('||ind||') = '|| p_tax_lines_tbl.global_attribute2(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute4('||ind||') = '|| p_tax_lines_tbl.global_attribute4(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute6('||ind||') = '|| p_tax_lines_tbl.global_attribute6(ind));
        END IF;
   END LOOP;
 END IF;

 IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()+');
 END IF;
end;

PROCEDURE stack_error (
		  p_msgname IN    VARCHAR2,
                  p_token1  IN    VARCHAR2 ,
                  p_value1  IN    VARCHAR2 ,
                  p_token2  IN    VARCHAR2 ,
                  p_value2  IN    VARCHAR2  ) IS
l_api_name     CONSTANT VARCHAR2(100) := 'STACK_ERROR';

BEGIN
  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
  END IF;
  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             '-- P_MSGNAME = '||p_msgname);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             '-- P_TOKEN1 = '||p_token1);
	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             '-- P_VALUE1 = '||p_value1);
	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             '-- P_TOKEN2 = '||p_token2);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             '-- P_VALUE2 = '||p_value2);
  END IF;

  error_exception_handle(p_value1||p_value2);


  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
  END IF;

END stack_error;

PROCEDURE Get_Vendor_Error (
	tax_selection 	IN	ZX_TAX_TAXWARE_GEN.SELPARMTYP%TYPE,
	errTaxParm	IN	ZX_TAX_TAXWARE_GEN.TaxParm,
	errJurParm	IN	ZX_TAX_TAXWARE_GEN.JurParm ) IS

  error_location 	VARCHAR2(30);
  error_mesg 		VARCHAR2(200);
  vdr_return_code	char(2);

  Jur_error		BOOLEAN := FALSE;
  Calc_error		BOOLEAN := FALSE;
  l_api_name    CONSTANT VARCHAR2(100) := 'GET_VENDOR_ERROR';
BEGIN
  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
  END IF;
  IF ( tax_selection IN
		(zx_tax_taxware_GEN.SELPRM_JUR_ONLY, zx_tax_taxware_GEN.SELPRM_TAX_JUR) ) THEN

     -- Check for Jurisdiction errors
     IF ( errJurParm.ReturnCode <> zx_tax_taxware_GEN.JURSUCCESS ) THEN

	Jur_Error := TRUE;

      	IF errJurParm.ReturnCode = zx_tax_taxware_GEN.JURINVPOT THEN
	   error_mesg := JGMSG_JURINVPOT;
	ELSIF errJurParm.ReturnCode = zx_tax_taxware_GEN.JURINVSRVIN THEN
	   error_mesg := JGMSG_JURINVSRVIN;
	ELSIF errJurParm.ReturnCode = zx_tax_taxware_GEN.JURERROR THEN

	   -- Determine Jurisdiction Error Location
	   IF errJurParm.POOJurRC <> to_char(0) THEN
		vdr_return_code := errJurParm.POOJurRC;
		error_location := 'POO';
	   ELSIF errJurParm.POAJurRC <> to_char(0) THEN
		vdr_return_code := errJurParm.POAJurRC;
		error_location := 'POA';
	   ELSIF errJurParm.ShpToJurRC <> to_char(0) THEN
		vdr_return_code := errJurParm.ShpToJurRC;
		error_location := 'SHIP-TO';
	   ELSIF errJurParm.ShpFrJurRC <> to_char(0) THEN
		vdr_return_code := errJurParm.ShpFrJurRC;
		error_location := 'SHIP-FROM';
	   ELSE
	   	error_mesg := JGMSG_JURERROR;
	   END IF;

	   -- Determine type of Jurisdiction error for Location
	   IF vdr_return_code IS NOT NULL THEN

	     -- Check vdr_return_code
	     IF vdr_return_code = to_char(zx_tax_taxware_GEN.LOCCNTYDEF) THEN
	   	error_mesg := error_location||' : '||JMSG_LOCCNTYDEF;
	     ELSIF vdr_return_code = to_char(zx_tax_taxware_GEN.LOCINVSTATE) THEN
	   	error_mesg := error_location||' : '||JMSG_LOCINVSTATE;
	     ELSIF vdr_return_code = to_char(zx_tax_taxware_GEN.LOCNOZIP) THEN
	   	error_mesg := error_location||' : '||JMSG_LOCNOZIP;
	     ELSIF vdr_return_code = to_char(zx_tax_taxware_GEN.LOCINVZIP) THEN
	   	error_mesg := error_location||' : '||JMSG_LOCINVZIP;
	     ELSIF vdr_return_code = to_char(zx_tax_taxware_GEN.LOCNOGEO) THEN
		-- Same as LOCNOCITY
	   	error_mesg := error_location||' : '||JMSG_LOCNOGEO;
	     ELSIF vdr_return_code = to_char(zx_tax_taxware_GEN.LOCINVCITY) THEN
	   	error_mesg := error_location||' : '||JMSG_LOCINVCITY;
	     ELSE
	   	error_mesg := JMSG_UNKNOWN;
	     END IF;		-- check vdr_return_code

	   END IF;		-- vdr_return_code NOT NULL?

	END IF;			-- zx_tax_taxware_GEN.JURERROR?

     END IF; 		-- Not JURSUCCESS?

  ELSIF ( NOT Jur_Error AND
	  tax_selection IN
		(zx_tax_taxware_GEN.SELPRM_TAXES_ONLY, zx_tax_taxware_GEN.SELPRM_TAX_JUR) ) THEN

     -- Check for Calculation errors
     IF ( nvl(errTaxParm.GenCmplCd,0) <> zx_tax_taxware_GEN.SUCCESSCC ) THEN

	Calc_Error := TRUE;

      	IF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.INVALIDZIP THEN
	   error_mesg := TGMSG_INVALIDZIP;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.INVALIDST THEN
	   error_mesg := TGMSG_INVALIDST;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.INVALIDGRS THEN
	   error_mesg := TGMSG_INVALIDGRS;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.INVALIDTAXAMT THEN
	   error_mesg := TGMSG_INVALIDTAXAMT;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.GENINVZIPST THEN
	   error_mesg := TGMSG_GENINVZIPST;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.INVCALCTYP THEN
	   error_mesg := TGMSG_INVCALCTYP;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.PRDACCESSERR THEN
	   error_mesg := TGMSG_PRDACCESSERR;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.RATEISZERO THEN
	   error_mesg := TGMSG_RATEISZERO;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.NEGFIELDS THEN
	   error_mesg := TGMSG_NEGFIELDS;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.AUDACCESSERR THEN
	   error_mesg := TGMSG_AUDACCESSERR;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.INVCALCERR THEN
	   error_mesg := TGMSG_INVCALCERR;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.STEPNOCUSTERR THEN
	   error_mesg := TGMSG_STEPNOCUSTERR;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.NOSTEPPROC THEN
	   error_mesg := TGMSG_NOSTEPPROC;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.STEPPARAMERR THEN
	   error_mesg := TGMSG_STEPPARAMERR;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.STEPMISCERR THEN
	   error_mesg := TGMSG_STEPMISCERR;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.CERRACCESSERR THEN
	   error_mesg := TGMSG_CERRACCESSERR;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.JERRACCESSERR THEN
	   error_mesg := TGMSG_JERRACCESSERR;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.INVJURERR THEN
	   error_mesg := TGMSG_INVJURERR;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.INVJURERR THEN
	   error_mesg := TGMSG_INVJURERR;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.INVJURPROC THEN
	   error_mesg := TGMSG_INVJURPROC;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.INVSELPARM THEN
	   error_mesg := TGMSG_INVSELPARM;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.JURISERROR THEN
	   error_mesg := TGMSG_JURISERROR;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.PRDINVALID4CU THEN
	   error_mesg := TGMSG_PRDINVALID4CU;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.CONUSEFILEERR THEN
	   error_mesg := TGMSG_CONUSEFILEERR;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.CALC_E_ERROR THEN
	   error_mesg := TGMSG_CALC_E_ERROR;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.EXEMPTLGRGROSS THEN
	   error_mesg := TGMSG_EXEMPTLGRGROSS;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.AMOUNTOVERFLOW THEN
	   error_mesg := TGMSG_AMOUNTOVERFLOW;
      	ELSIF errTaxParm.GenCmplCd = zx_tax_taxware_GEN.PRODCDCONVNOTFOUND THEN
	   error_mesg := TGMSG_PRODCDCONVNOTFOUND;
	ELSE
	   error_mesg := TGMSG_UNKNOWN||' Return Code = '||errTaxParm.GenCmplCd;
	END IF;

     END IF;		-- GenCmplCd <> SUCESSSCC?

  END IF;		-- Tax Selection type

  IF ( Jur_Error OR Calc_Error ) THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	   '-- ERROR MESSAGE = '||error_mesg);
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	   'CALLING STACK_ERROR');
        END IF;

  	stack_error('GENERIC_MESSAGE', 'GENERIC_TEXT',
					'Taxware Error : '||error_mesg,null,null);
  ELSE
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	   'CALLING STACK_ERROR');
        END IF;
  	stack_error('GENERIC_MESSAGE', 'GENERIC_TEXT',
					'Taxware Errror: Taxfn_Tax010 returned FALSE and GenCmplCd = '||
                                        errTaxParm.GenCmplCd,null,null);
  END IF;

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()+');
  END IF;
END Get_Vendor_Error;


PROCEDURE ERROR_EXCEPTION_HANDLE(P_ERROR_STRING  varchar2) is

cursor error_exception_cursor is
select	EVNT_CLS_MAPPING_ID,
	TRX_ID,
	TAX_REGIME_CODE
from ZX_TRX_PRE_PROC_OPTIONS_GT;

Begin
If (g_docment_type_id is null) then
	open error_exception_cursor;
	fetch error_exception_cursor
	into g_docment_type_id,
	     g_trasaction_id,
	     g_tax_regime_code;

close error_exception_cursor;

end if;


G_MESSAGES_TBL.DOCUMENT_TYPE_ID(err_count)		:= g_docment_type_id;
G_MESSAGES_TBL.TRANSACTION_ID(err_count)		:= g_trasaction_id;
G_MESSAGES_TBL.COUNTRY_CODE(err_count)			:= g_tax_regime_code;
G_MESSAGES_TBL.TRANSACTION_LINE_ID(err_count)		:= g_transaction_line_id;
G_MESSAGES_TBL.TRX_LEVEL_TYPE(err_count)	        := g_trx_level_type;
G_MESSAGES_TBL.ERROR_MESSAGE_TYPE(err_count)		:= 'ERROR';
G_MESSAGES_TBL.ERROR_MESSAGE_STRING(err_count)		:= p_error_string;

err_count :=err_count+1;

End ERROR_EXCEPTION_HANDLE;

PROCEDURE initialize IS
l_synonym_name user_synonyms.synonym_name%TYPE;
l_table_owner		varchar2(20);
l_table_name		varchar2(20);
l_column_name		varchar2(20);
l_column_position 	number;
l_no_index		boolean;

CURSOR taxware_index(p_table_name in VARCHAR2, p_table_owner in VARCHAR2) is
  select column_name, column_position
  from   all_ind_columns
  where  table_name = p_table_name and table_owner = p_table_owner;

l_api_name  CONSTANT VARCHAR2(100) := 'INITIALIZE';
BEGIN


 l_synonym_name := 'ZX_TAX_TAXWARE_AUDIT_HEADER';


  BEGIN
     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
     END IF;
     SELECT table_owner, table_name into l_table_owner, l_table_name
     FROM   user_synonyms
     WHERE  synonym_name = l_synonym_name;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	   'table_owner :'|| l_table_owner);
	    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	   'table_name  :'|| l_table_name);
     END IF;

     open taxware_index(l_table_name, l_table_owner);
     LOOP
        fetch taxware_index into l_column_name, l_column_position;

        if taxware_index%notfound then
	   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	     'No index on ZX_TAX_TAXWARE_AUDIT_HEADER.ORACLEID.');
	   END IF;
           l_no_index := TRUE;
           exit;
        end if;

        if upper(l_column_name) = 'ORACLEID' and nvl(l_column_position, 1) = 1 then
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	     'Indexed on ZX_TAX_TAXWARE_AUDIT_HEADER.ORACLEID.');
	   END IF;
	   l_no_index := FALSE;
           exit;
        end if;
     END LOOP;
     close taxware_index;

     EXCEPTION
  	WHEN NO_DATA_FOUND then
	  IF (g_level_exception >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_exception,G_PKG_NAME||'.'||l_api_name,
                          'ZX_TAX_TAXWARE.INITIALIZE: NO_DATA_FOUND');
          END IF;
    	  l_no_index := TRUE;

	WHEN OTHERS then
	  IF (g_level_exception >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_exception,G_PKG_NAME||'.'||l_api_name,
                          'ZX_TAX_TAXWARE.INITIALIZE: OTHERS');
          END IF;

	  l_no_index := TRUE;
     END;


     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()+');
     END IF;

EXCEPTION
  when OTHERS then
      IF (g_level_exception >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_exception,G_PKG_NAME||'.'||l_api_name,
                          'EXCEPTION(OTHERS): ZX_TAX_TAXWARE.initialize()');
      END IF;
      RAISE;
END initialize;

PROCEDURE CREATE_TAX_LINE(
p_tax     in varchar2,
p_amount  in number,
x_return_status OUT NOCOPY VARCHAR2) IS

 l_api_name           CONSTANT VARCHAR2(30) := 'CREATE_TAX_LINE';
 l_return_Status               VARCHAR2(30);
 return_code			 boolean;
 l_TaxLink                     ZX_TAX_TAXWARE_GEN.TaxParm;
 l_JurLink                     ZX_TAX_TAXWARE_GEN.JurParm;
 l_OraLink                     ZX_TAX_TAXWARE_GEN.t_OraParm;
 input_param_flag	       boolean;
 l_precision             number;
 l_mau                   number;
 l_rounding_rule         varchar2(30);
 l_error_buffer          varchar2(200);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

/* For Tax only Credit Memo and Tax only adjustment, user does not enter the
   tax lines manually. Instead, the tax lines are calculated/prorated by eBTax.
   The number of tax lines for the trx line can be known.
   Hence, we can consoliate all the tax lines and make 1 call to Vertex engine.
   The ELSE clause of this IF statement handles the manually entered tax lines.
*/
   IF l_document_type in ('TAX_ONLY_CREDIT_MEMO'
                         ,'TAX_ONLY_ADJUSTMENT') THEN

      g_line_level_action:='CREATE';

      IF (p_tax='STATE') THEN
         g_StTaxAmt := p_amount;
      ELSIF (p_tax='COUNTY') THEN
         g_CoTaxAmt := p_amount;
      ELSIF (p_tax='CITY') THEN
         g_CiTaxAmt := p_amount;
      ELSIF (p_tax='LOCATION') THEN
         BEGIN
          SELECT global_attribute2, global_attribute4, global_attribute6, tax_amt,
                 precision, minimum_accountable_unit, rounding_rule_code
          INTO g_StTaxAmt, g_CoTaxAmt, g_CiTaxAmt, g_TotalTaxAmt,
               l_precision, l_mau, l_rounding_rule
          FROM zx_lines
          WHERE application_id = NVL2(pg_adj_doc_doc_type_id_tab(I),222, NULL)
          AND entity_code = NVL2(pg_adj_doc_doc_type_id_tab(I),'TRANSACTIONS',NULL)
          AND event_class_code = decode(pg_adj_doc_doc_type_id_tab(I), 4, 'INVOICE',
                                                                       5, 'DEBIT_MEMO',
                                                                       6, 'CREDIT_MEMO', null)
          AND trx_id = NVL2(pg_adj_doc_doc_type_id_tab(I),pg_adj_doc_trx_id_tab(I), NULL)
          AND trx_line_id = NVL2(pg_adj_doc_doc_type_id_tab(I),pg_adj_doc_line_id_tab(I), NULL)
          AND trx_level_type = NVL2(pg_adj_doc_doc_type_id_tab(I),pg_adj_doc_trx_lev_type_tab(I), NULL);
        EXCEPTION
          WHEN OTHERS THEN
            g_StTaxAmt := 0;
            g_CoTaxAmt := 0;
            g_CiTaxAmt := 0;
        END;
        g_StTaxAmt := g_StTaxAmt * (p_amount/ g_TotalTaxAmt);
        g_CoTaxAmt := g_CoTaxAmt * (p_amount/ g_TotalTaxAmt);
        g_CiTaxAmt := g_CiTaxAmt * (p_amount/ g_TotalTaxAmt);
        g_TotalTaxAmt := p_amount;
        g_StTaxAmt := ZX_TDS_TAX_ROUNDING_PKG.round_tax(g_StTaxAmt,
                                                        l_rounding_rule,
                                                        l_mau,
                                                        l_precision,
                                                        x_return_status,
                                                        l_error_buffer
                                                        );
        g_CoTaxAmt := ZX_TDS_TAX_ROUNDING_PKG.round_tax(g_CoTaxAmt,
                                                        l_rounding_rule,
                                                        l_mau,
                                                        l_precision,
                                                        x_return_status,
                                                        l_error_buffer
                                                        );
        g_CiTaxAmt := p_amount - (g_StTaxAmt + g_CoTaxAmt);
      END IF;

      IF NOT l_trx_line_context_changed THEN
         RETURN;
      END IF;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                        'Encountered the last tax line for the trx line.');
      END IF;

   ELSE

      IF l_document_type IN ('TAX_ONLY_INVOICE') THEN
         g_line_level_action:='CREATE';
      ELSE
         g_line_level_action:='DELETE';
         l_document_type := 'TAX_LINE_SYNC';
      END IF;

      IF (p_tax='STATE') THEN
         g_TotalTaxAmt := p_amount;
	 g_StTaxAmt := p_amount;
         g_CoTaxAmt := 0;
         g_CiTaxAmt := 0;
      ELSIF (p_tax='COUNTY') THEN
         g_TotalTaxAmt := p_amount;
	 g_StTaxAmt := 0;
         g_CoTaxAmt := p_amount;
         g_CiTaxAmt := 0;
      ELSIF (p_tax='CITY') THEN
         g_TotalTaxAmt := p_amount;
	 g_StTaxAmt := 0;
         g_CoTaxAmt := 0;
         g_CiTaxAmt := p_amount;
      ELSIF (p_tax='LOCATION') THEN
         g_TotalTaxAmt := p_amount;
         g_StTaxAmt := 0;
         g_CoTaxAmt := 0;
         g_CiTaxAmt := 0;
         /* Ideally, we should implement g_StTaxAmt := p_amount * GA_2 / (GA_2 + GA_4 + GA_6)
                                         g_CoTaxAmt := p_amount * GA_4 / (GA_2 + GA_4 + GA_6)
                                         g_CiTaxAmt := p_amount * GA_6 / (GA_2 + GA_4 + GA_6)
            With above implementation we are relying on Vertex to distribute amounts */
      END IF;

   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax : '||p_tax );
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_amount : '||p_amount);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'g_StTaxAmt : '||g_StTaxAmt);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'g_CoTaxAmt : '||g_CoTaxAmt);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'g_CiTaxAmt : '||g_CiTaxAmt);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'g_TotalTaxAmt : '||g_TotalTaxAmt);
   END IF;


   return_code := Set_Parameters(l_TaxLink, l_JurLink, l_OraLink);
   input_param_flag := TRUE;
   dump_vendor_rec(l_TaxLink, l_JurLink, l_OraLink,input_param_flag);
   if(return_code = TRUE) then
		     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Calling CALCULATE_TAX procedure' );
		     END IF;

		     return_code := calculate_tax(l_TaxLink, l_JurLink, l_OraLink);
		     input_param_flag := FALSE;
		     dump_vendor_rec(l_TaxLink, l_JurLink, l_OraLink,input_param_flag);
		     IF (return_code = FALSE) then
		         --x_return_status := FND_API.G_RET_STS_ERROR;
			 g_string :='Failed in CALCULATE_TAX procedure';
			 error_exception_handle(g_string);
	 		return;
		     END IF;
   else
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     g_string :='Failed in SET_PRAMETERS procedure';
		     error_exception_handle(g_string);
		     return;
   end if;


        g_StTaxAmt:= 0;
        g_CoTaxAmt:= 0;
        g_CiTaxAmt:= 0;
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END CREATE_TAX_LINE;

Procedure get_doc_and_ext_att_info(p_evnt_cls_mapping_id IN  ZX_EVNT_CLS_MAPPINGS.event_class_mapping_id%type,
                                   p_transaction_id      IN  ZX_LINES.trx_id%type,
                                   p_transaction_line_id IN  ZX_LINES.trx_line_id%type,
                                   p_trx_level_type      IN  ZX_LINES.trx_level_type%type,
                                   p_regime_code         IN  ZX_LINES.tax_regime_code%type,
                                   p_tax_provider_id     IN  ZX_LINES.tax_provider_id%type,
                                   x_return_status   OUT NOCOPY VARCHAR2 ) is

 trx_line_dist_tbl       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl%type;
 event_class_rec         ZX_API_PUB.event_class_rec_type;
 l_return_status         varchar2(30);
 l_APPLICATION_ID        number;
 l_ENTITY_CODE          varchar2(20);
 l_EVENT_CLASS_CODE     varchar2(20);
 l_TRX_ID               number;
 l_TRX_LINE_ID          number;
 l_TRX_LEVEL_TYPE       varchar2(20);

 l_api_name           CONSTANT VARCHAR2(30) := 'GET_DOC_AND_EXT_ATT_INFO';
Begin
 x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_transaction_id : '||p_transaction_id );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_transaction_line_id : '||p_transaction_line_id);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_regime_code : '||p_regime_code);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_provider_id : '||p_tax_provider_id);
   END IF;

Begin
  select
        APPLICATION_ID,
        ENTITY_CODE      ,
        EVENT_CLASS_CODE,
        TRX_ID ,
        TRX_LINE_ID,
        TRX_LEVEL_TYPE
  into
        l_APPLICATION_ID,
        l_ENTITY_CODE      ,
        l_EVENT_CLASS_CODE,
        l_TRX_ID ,
        l_TRX_LINE_ID,
        l_TRX_LEVEL_TYPE
  From  zx_lines_det_factors
 where
                event_class_mapping_id  = p_evnt_cls_mapping_id
      AND       trx_id                  = p_transaction_id
      AND       trx_line_id             = p_transaction_line_id
      AND       trx_level_type          = p_trx_level_type;

Exception
  When no_data_found then
            IF (g_level_exception >= g_current_runtime_level ) THEN
               FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
            End if;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            g_string :='No data found in zx_lines_det_factors ';
            error_exception_handle(g_string);
            return;
 End;


trx_line_dist_tbl.application_id(1)     :=l_APPLICATION_ID;
trx_line_dist_tbl.TRX_LINE_ID(1)        :=l_TRX_LINE_ID;
trx_line_dist_tbl.TRX_LEVEL_TYPE(1)     :=l_TRX_LEVEL_TYPE;

event_class_rec.APPLICATION_ID          :=l_APPLICATION_ID;
event_class_rec.ENTITY_CODE             :=l_ENTITY_CODE;
event_class_rec.EVENT_CLASS_CODE        :=l_EVENT_CLASS_CODE;
event_class_rec.TRX_ID                  :=l_TRX_ID;
--event_class_rec.TRX_LINE_ID             :=l_TRX_LINE_ID;


  zx_r11i_tax_partner_pkg.copy_trx_line_for_ptnr_bef_upd
     (p_trx_line_dist_tbl       => trx_line_dist_tbl,
      p_event_class_rec         => event_class_rec,
      p_update_index            => 1,
      p_trx_copy_for_tax_update => 'N' ,
      p_regime_code             => p_regime_code,
      p_tax_provider_id         => p_tax_provider_id,
      x_return_status           => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF (g_level_exception >= g_current_runtime_level ) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           g_string :='Not able to copy the line information :Failed with an exception';
           error_exception_handle(g_string);
           return;
      END IF;
 IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END get_doc_and_ext_att_info;

Function CHECK_IN_CACHE(p_internal_organization_id number,
                        P_document_type_id number,
                        p_transaction_id number,
                        p_transaction_line_id number) return boolean is

l_index number;
l_api_name           CONSTANT VARCHAR2(30) := 'CHECK_IN_CACHE';
Begin

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'P_INTERNAL_ORGANIZATION_ID : ' || p_internal_organization_id );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'P_DOCUMENT_TYPE_ID : '|| P_document_type_id);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'P_TRANSACTION_ID : '|| p_transaction_id);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'P_TRANSACTION_LINE_ID : '|| p_transaction_line_id);
   END IF;

For l_index in 1 .. cache_index loop
  if(cache_table(l_index).internal_organization_id = p_internal_organization_id and
     cache_table(l_index).document_type_id       = P_document_type_id and
     cache_table(l_index).transaction_id         = p_transaction_id and
     cache_table(l_index).transaction_line_id    = p_transaction_line_id) then

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Found in the Cache' );
     END IF;

     Return TRUE;
  end if;
 end loop;
     cache_index                :=cache_index+1;
     cache_table(cache_index).internal_organization_id  := p_internal_organization_id;
     cache_table(cache_index).document_type_id          := P_document_type_id;
     cache_table(cache_index).transaction_id            := p_transaction_id;
     cache_table(cache_index).transaction_line_id       := p_transaction_line_id;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Not Found in the Cache' );
     END IF;

     return FALSE;

IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;
End Check_in_cache;

PROCEDURE POPULATE_SYNC_TAX_AMTS(p_sync_tax_cnt          IN  NUMBER
                               , p_tax                   IN  zx_lines.tax%type
                               , x_output_sync_tax_lines OUT NOCOPY zx_tax_partner_pkg.output_sync_tax_lines_tbl_type
                               , x_return_status         OUT NOCOPY VARCHAR2) IS

 l_api_name             CONSTANT VARCHAR2(30) := 'POPULATE_SYNC_TAX_AMTS';

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_sync_tax_cnt : '||p_sync_tax_cnt);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax : '||p_tax);
   END IF;

/* For Tax only Credit Memo and Tax only adjustment, we consoliate all the tax lines and make 1 call to Vertex engine.
   The output is available at the end of the processing of the last tax line.
   l_trx_line_context_changed indicates that the tax line being processed is the last tax line for the trx line.
*/
   IF l_document_type in ('TAX_ONLY_CREDIT_MEMO'
                         ,'TAX_ONLY_ADJUSTMENT') THEN
      IF (p_tax = 'STATE') THEN
         l_state_tax_cnt := p_sync_tax_cnt;
      ELSIF(p_tax = 'COUNTY') THEN
         l_county_tax_cnt := p_sync_tax_cnt;
      ELSIF(p_tax = 'CITY') THEN
         l_city_tax_cnt := p_sync_tax_cnt;
      END IF;
      IF l_trx_line_context_changed THEN
         IF l_state_tax_cnt IS NOT NULL THEN
--          x_output_sync_tax_lines(l_state_tax_cnt).TAX_RATE_PERCENTAGE  := l_TaxLink.StaTxRate*100;
--          x_output_sync_tax_lines(l_state_tax_cnt).TAXABLE_AMOUNT       := l_TaxLink.StBasisAmt;
          null;
         END IF;
         IF l_county_tax_cnt IS NOT NULL THEN
    --        x_output_sync_tax_lines(l_county_tax_cnt).TAX_RATE_PERCENTAGE := l_TaxLink.CnTxRate *100;
      --      x_output_sync_tax_lines(l_county_tax_cnt).TAXABLE_AMOUNT      := l_TaxLink.CntyBasisAmt;
	    null;
         END IF;
         IF l_city_tax_cnt IS NOT NULL THEN
  --          x_output_sync_tax_lines(l_city_tax_cnt).TAX_RATE_PERCENTAGE   := l_TaxLink.LoTxRate*100;
--            x_output_sync_tax_lines(l_city_tax_cnt).TAXABLE_AMOUNT        := l_TaxLink.CityBasisAmt;
	    null;
         END IF;
         l_state_tax_cnt := null;
         l_county_tax_cnt := null;
         l_city_tax_cnt := null;
      ELSE
         RETURN;
      END IF;
   ELSE
      IF (p_tax = 'STATE') THEN
       --  x_output_sync_tax_lines(p_sync_tax_cnt).TAX_RATE_PERCENTAGE    := l_TaxLink.StaTxRate*100;
         --x_output_sync_tax_lines(p_sync_tax_cnt).TAXABLE_AMOUNT         := l_TaxLink.StBasisAmt;
	 null;
      ELSIF(p_tax = 'COUNTY') THEN
--         x_output_sync_tax_lines(p_sync_tax_cnt).TAX_RATE_PERCENTAGE    := l_TaxLink.CnTxRate *100;
--         x_output_sync_tax_lines(p_sync_tax_cnt).TAXABLE_AMOUNT         := l_TaxLink.CntyBasisAmt;
         null;
      ELSIF(p_tax = 'CITY') THEN
--         x_output_sync_tax_lines(p_sync_tax_cnt).TAX_RATE_PERCENTAGE    := l_TaxLink.LoTxRate*100;
--         x_output_sync_tax_lines(p_sync_tax_cnt).TAXABLE_AMOUNT         := l_TaxLink.CityBasisAmt;
         null;
      END IF;
   END IF;

END POPULATE_SYNC_TAX_AMTS;


Procedure SYNCHRONIZE_TAXWARE_REPOSITORY
	(x_output_sync_tax_lines OUT NOCOPY zx_tax_partner_pkg.output_sync_tax_lines_tbl_type,
   	 x_return_status         OUT NOCOPY varchar2,
   	 x_messages_tbl          OUT NOCOPY ZX_TAX_PARTNER_PKG.messages_tbl_type) is
	 l_api_name     CONSTANT VARCHAR2(100) := 'SYNCHRONIZE_TAXWARE_REPOSITORY';
CURSOR TAX_LINES_TO_BE_PROCESSED is
   SELECT
         DOCUMENT_TYPE_ID           ,
         TRANSACTION_ID             ,
         TRANSACTION_LINE_ID        ,
         TRX_LEVEL_TYPE             ,
         COUNTRY_CODE               ,
         TAX                        ,
         SITUS                      ,
         TAX_JURISDICTION           ,
         TAX_CURRENCY_CODE          ,
         TAX_AMOUNT                 ,
         TAX_CURR_TAX_AMT           ,
         TAX_RATE_PERCENTAGE        ,
         TAXABLE_AMOUNT             ,
         EXEMPT_RATE_MODIFIER       ,
         EXEMPT_REASON              ,
         TAX_ONLY_LINE_FLAG         ,
         INCLUSIVE_TAX_LINE_FLAG    ,
         USE_TAX_FLAG               ,
         EBIZ_OVERRIDE_FLAG         ,
         USER_OVERRIDE_FLAG         ,
         LAST_MANUAL_ENTRY          ,
         MANUALLY_ENTERED_FLAG      ,
         CANCEL_FLAG                ,
         DELETE_FLAG
    FROM ZX_SYNC_TAX_LINES_INPUT_V
    ORDER BY DOCUMENT_TYPE_ID,
             TRANSACTION_ID,
             TRANSACTION_LINE_ID,
             TRX_LEVEL_TYPE;


SYNC_TAX_LINES SYNC_TAX_LINES_TBL;
l_internal_organization_id      ZX_SYNC_HDR_INPUT_V.internal_organization_id%type;
l_document_type_id              ZX_SYNC_HDR_INPUT_V.document_type_id%type;
l_transaction_id                ZX_SYNC_HDR_INPUT_V.transaction_id%type;
l_legal_entity_number           ZX_SYNC_HDR_INPUT_V.legal_entity_number%type;
l_establishment_number          ZX_SYNC_HDR_INPUT_V.establishment_number%type;  -- Bug 5139731
l_transaction_line_id           ZX_SYNC_TAX_LINES_INPUT_V.transaction_line_id%type;
l_count number;
l_event_type varchar2(20);
l_write_record boolean;
l_event_class_code      varchar2(20);
l_application_id        number;
l_entity_code           varchar2(20);
l_trx_level_type        varchar2(20);
l_regime_code           ZX_REGIMES_B.tax_regime_code%type;
l_amount  number;
l_found boolean;
l_return_status varchar2(30);
ctrx_id NUMBER;
l_trx_number    VARCHAR2(150);
l_statements    VARCHAR2(2000);

BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

  IF ZX_API_PUB.G_PUB_SRVC <> 'SYNCHRONIZE_TAX_REPOSITORY' THEN

    BEGIN
      SELECT internal_organization_id,
             document_type_id,
             transaction_id,
             legal_entity_number,
             establishment_number
        INTO l_internal_organization_id,
             l_document_type_id,
             l_transaction_id,
             l_legal_entity_number,
             l_establishment_number    -- Bug 5139731
        FROM ZX_SYNC_HDR_INPUT_V;
   EXCEPTION
      WHEN TOO_MANY_ROWS THEN
         IF (g_level_exception >= g_current_runtime_level ) THEN
            FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
         End if;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         g_string :='More than one row exist at header level';
         error_exception_handle(g_string);
         RETURN;
   END;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         ' l_transaction_id = ' || l_transaction_id);
   END IF;

   OPEN tax_lines_to_be_processed;

   FETCH tax_lines_to_be_processed BULK COLLECT INTO
      SYNC_TAX_LINES.document_type_id           ,
      SYNC_TAX_LINES.transaction_id             ,
      SYNC_TAX_LINES.transaction_line_id        ,
      SYNC_TAX_LINES.trx_level_type           ,
      SYNC_TAX_LINES.country_code               ,
      SYNC_TAX_LINES.tax                        ,
      SYNC_TAX_LINES.situs                      ,
      SYNC_TAX_LINES.tax_jurisdiction           ,
      SYNC_TAX_LINES.tax_currency_code  ,
      SYNC_TAX_LINES.tax_curr_tax_amount        ,
      SYNC_TAX_LINES.tax_amount         ,
      SYNC_TAX_LINES.tax_rate_percentage        ,
      SYNC_TAX_LINES.taxable_amount             ,
      SYNC_TAX_LINES.exempt_rate_modifier       ,
      SYNC_TAX_LINES.exempt_reason              ,
      SYNC_TAX_LINES.tax_only_line_flag ,
      SYNC_TAX_LINES.inclusive_tax_line_flag    ,
      SYNC_TAX_LINES.use_tax_flag               ,
      SYNC_TAX_LINES.ebiz_override_flag ,
      SYNC_TAX_LINES.user_override_flag ,
      SYNC_TAX_LINES.last_manual_entry  ,
      SYNC_TAX_LINES.manually_entered_flag      ,
      SYNC_TAX_LINES.cancel_flag                ,
      SYNC_TAX_LINES.delete_flag
   LIMIT C_LINES_PER_COMMIT;

   I := 0;
   BEGIN
      SELECT event_class_code
           , application_id
           , entity_code
        INTO l_event_class_code
           , l_application_id
           , l_entity_code
        FROM zx_evnt_cls_mappings
       WHERE EVENT_CLASS_MAPPING_ID = SYNC_TAX_LINES.document_type_id(1);
    EXCEPTION
     WHEN OTHERS THEN
       l_event_class_code := NULL;
       l_application_id := NULL;
       l_entity_code := NULL;

   END;

   FOR sync_tax_cnt IN 1..sync_tax_lines.document_type_id.last LOOP

/* Maintain the trx line counter. The tax lines are fetched together for a transaction_line_id.
   For Tax only documents, we need to know the last tax line being fetch so that all the tax lines can be consolidated and passed as one record */

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' SYNC_TAX_LINES.transaction_line_id(' || sync_tax_cnt || ') = ' || SYNC_TAX_LINES.transaction_line_id(sync_tax_cnt));
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' SYNC_TAX_LINES.tax(' || sync_tax_cnt || ') = ' || SYNC_TAX_LINES.tax(sync_tax_cnt));
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' SYNC_TAX_LINES.tax_amount(' || sync_tax_cnt || ') = ' || SYNC_TAX_LINES.tax_amount(sync_tax_cnt));
      END IF;

      IF nvl(l_transaction_line_id, -999) <> SYNC_TAX_LINES.transaction_line_id(sync_tax_cnt) THEN
         I := I+1;
         l_transaction_line_id := SYNC_TAX_LINES.transaction_line_id(sync_tax_cnt);
      END IF;
      IF sync_tax_cnt = sync_tax_lines.document_type_id.last THEN
         l_trx_line_context_changed := TRUE;
      ELSE
         IF l_transaction_line_id = SYNC_TAX_LINES.transaction_line_id(sync_tax_cnt+1) THEN
            l_trx_line_context_changed := FALSE;
         ELSE
            l_trx_line_context_changed := TRUE;
         END IF;
      END IF;
      /* Identify Tax event type -Start*/
      BEGIN
         SELECT count(*)
           INTO l_count
           FROM ZX_PTNR_NEG_TAX_LINE_GT
          WHERE document_type_id = SYNC_TAX_LINES.document_type_id(sync_tax_cnt)
            AND trx_id           = SYNC_TAX_LINES.transaction_id(sync_tax_cnt)
            AND trx_line_id      = SYNC_TAX_LINES.transaction_line_id(sync_tax_cnt)
            AND country_code     = SYNC_TAX_LINES.country_code(sync_tax_cnt)
            AND tax              = SYNC_TAX_LINES.tax(sync_tax_cnt)
            AND situs            = SYNC_TAX_LINES.situs(sync_tax_cnt);
      EXCEPTION
         WHEN OTHERS THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                  ' Error while accessing ZX_PTNR_NEG_TAX_LINE_GT');
            END IF;
      END;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' No of records in ZX_PTNR_NEG_TAX_LINE_GT = ' || l_count);
      END IF;

/* Check if the Line is present in ZX_PTNR_NEG_TAX_LINE_GT table.
   Deleted line is passed thru zx_sync_tax_lines_input_v and there is
   no corresponding line in ZX_PTNR_NEG_TAX_LINE_GT */

      IF (l_count=1) THEN /*Line is present. Hence, it is an UPDATE action */
         l_event_type  :='TAX_LINE_UPDATE';
      ELSIF (l_count=0) THEN
         IF (SYNC_TAX_LINES.delete_flag(sync_tax_cnt) ='Y') THEN /* Delete action */
            l_event_type :='TAX_LINE_DELETE';
         ELSE
            l_event_type:='TAX_LINE_CREATE';
         END IF;
      ELSE
         x_return_status :=FND_API.G_RET_STS_ERROR;
         g_string := 'There were more than one tax line';
         error_exception_handle(g_string);
         RETURN;
      END IF;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' l_event_type ' || l_event_type);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' pg_trx_id_tab(I) ' || pg_trx_id_tab(I));
      END IF;
	    get_doc_and_ext_att_info(SYNC_TAX_LINES.document_type_id(sync_tax_cnt),
                                     SYNC_TAX_LINES.transaction_id(sync_tax_cnt),
                                     SYNC_TAX_LINES.transaction_line_id(sync_tax_cnt),
                                     SYNC_TAX_LINES.trx_level_type(sync_tax_cnt),
                                     SYNC_TAX_LINES.country_code(sync_tax_cnt),
                                     1,l_return_status);
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF (g_level_exception >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
               END IF;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               g_string :='Failed in GET_DOC_AND_EXT_ATT_INFO procedure';
               error_exception_handle(g_string);
               RETURN;
            END IF;
      --END IF;

      IF (l_event_type='TAX_LINE_UPDATE') THEN
      /*Taxware does not have this feature*/
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      g_string :='Unable to perform with Taxware';
      error_exception_handle(g_string);

      ELSIF(l_event_type='TAX_LINE_DELETE')then
            select tax_amount
              into l_amount
              from ZX_PTNR_NEG_TAX_LINE_GT
             where trx_id = SYNC_TAX_LINES.transaction_id(sync_tax_cnt) and
                   trx_line_id  = SYNC_TAX_LINES.transaction_line_id(sync_tax_cnt);

         create_tax_line(SYNC_TAX_LINES.tax(sync_tax_cnt),-1*l_amount,l_return_status);
         l_write_record:=false;

      ELSIF (l_event_type='TAX_LINE_CREATE') THEN
            create_tax_line(SYNC_TAX_LINES.tax(sync_tax_cnt),SYNC_TAX_LINES.tax_amount(sync_tax_cnt),l_return_status);
            l_write_record:=true;
      END IF;

      IF (l_write_record and l_trx_line_context_changed) THEN
         x_output_sync_tax_lines(sync_tax_cnt).INTERNAL_ORGANIZATION_ID  :=  l_internal_organization_id;
         x_output_sync_tax_lines(sync_tax_cnt).LEGAL_ENTITY_NUMBER       := l_legal_entity_number;
         x_output_sync_tax_lines(sync_tax_cnt).ESTABLISHMENT_NUMBER      := l_establishment_number;  -- Bug 5139731
         x_output_sync_tax_lines(sync_tax_cnt).DOCUMENT_TYPE_ID          := SYNC_TAX_LINES.document_type_id(sync_tax_cnt);
         x_output_sync_tax_lines(sync_tax_cnt).APPLICATION_ID            := l_application_id;
         x_output_sync_tax_lines(sync_tax_cnt).ENTITY_CODE               := l_entity_code;
	  x_output_sync_tax_lines(sync_tax_cnt).EVENT_CLASS_CODE          := l_event_class_code;
         x_output_sync_tax_lines(sync_tax_cnt).TRANSACTION_ID            := sync_tax_lines.transaction_id(sync_tax_cnt);
         x_output_sync_tax_lines(sync_tax_cnt).TRANSACTION_LINE_ID       := sync_tax_lines.transaction_line_id(sync_tax_cnt);
         x_output_sync_tax_lines(sync_tax_cnt).TRX_LEVEL_TYPE            := sync_tax_lines.trx_level_type(sync_tax_cnt);
         x_output_sync_tax_lines(sync_tax_cnt).COUNTRY_CODE              := sync_tax_lines.country_code(sync_tax_cnt);
         x_output_sync_tax_lines(sync_tax_cnt).TAX                       := sync_tax_lines.tax(sync_tax_cnt);
         x_output_sync_tax_lines(sync_tax_cnt).SITUS                     := sync_tax_lines.situs(sync_tax_cnt);

         populate_sync_tax_amts(sync_tax_cnt
                              , sync_tax_lines.tax(sync_tax_cnt)
                              , x_output_sync_tax_lines
                              , x_return_status);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_exception >= g_current_runtime_level ) THEN
               FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            g_string :='Failed in populate_sync_tax_amts procedure';
            error_exception_handle(g_string);
            RETURN;
         END IF;

         l_write_record := FALSE;
      END IF;

   END LOOP;
  ELSE
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' in the update part ');
    END IF;

     BEGIN
       SELECT TRANSACTION_NUMBER, TRANSACTION_ID
       INTO l_trx_number, ctrx_id
       FROM ZX_SYNC_HDR_INPUT_V;
     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         IF (g_level_exception >= g_current_runtime_level ) THEN
            FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
         End if;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         g_string :='More than one row exist at header level';
         error_exception_handle(g_string);
         RETURN;
       WHEN OTHERS THEN
         NULL;
     END;
     l_statements := 'UPDATE ZX_TAX_TAXWARE_AUDIT_HEADER '||
                     'SET INVNUM = :1' ||
                     ' WHERE ORACLEID = :2 ';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_statements ==' || l_statements);
     END IF;
     EXECUTE IMMEDIATE l_statements using l_trx_number,ctrx_id ;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updated Rows in taxware table == ' || to_char(SQL%ROWCOUNT));
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'ZX_TAX_TAXWARE_AUDIT_HEADER is updated');
     END IF;

   END IF;


   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;


End SYNCHRONIZE_TAXWARE_REPOSITORY;

Procedure GLOBAL_DOCUMENT_UPDATE
	(x_transaction_rec       IN         zx_tax_partner_pkg.trx_rec_type,
   	 x_return_status         OUT NOCOPY varchar2,
   	 x_messages_tbl          OUT NOCOPY ZX_TAX_PARTNER_PKG.messages_tbl_type) is
 l_cnt_of_options_gt    NUMBER;
 l_cnt_of_hdr_extns_gt  NUMBER;
 l_cnt_of_line_extns_gt NUMBER;
 l_cnt_of_loc_info_gt   NUMBER;
 l_cnt_of_neg_line_gt   NUMBER;
 l_cnt_of_det_factors   NUMBER;
 l_return_status        VARCHAR2(30);
 l_api_name     CONSTANT VARCHAR2(100) := 'GLOBAL_DOCUMENT_UPDATE';
 --Bug 8576319
 l_doc_amount       NUMBER;
BEGIN
  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
  END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      BEGIN
         SELECT count(*)
           INTO l_cnt_of_det_factors
           FROM ZX_LINES_DET_FACTORS
          WHERE event_class_mapping_id = x_transaction_rec.document_type_id
            AND trx_id                 = x_transaction_rec.transaction_id;
      EXCEPTION WHEN OTHERS THEN
         l_cnt_of_det_factors := 0;
      END;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
              'l_cnt_of_det_factors = '||l_cnt_of_det_factors);
      BEGIN
         SELECT count(*)
           INTO l_cnt_of_options_gt
           FROM ZX_TRX_PRE_PROC_OPTIONS_GT;
      EXCEPTION WHEN OTHERS THEN
         l_cnt_of_options_gt := 0;
      END;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             'l_cnt_of_options_gt = '||l_cnt_of_options_gt);
      BEGIN
         SELECT count(*)
           INTO l_cnt_of_hdr_extns_gt
           FROM ZX_PRVDR_HDR_EXTNS_GT;
      EXCEPTION WHEN OTHERS THEN
         l_cnt_of_hdr_extns_gt := 0;
      END;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             'l_cnt_of_hdr_extns_gt = '||l_cnt_of_hdr_extns_gt);
      BEGIN
         SELECT count(*)
           INTO l_cnt_of_line_extns_gt
           FROM ZX_PRVDR_HDR_EXTNS_GT;
      EXCEPTION WHEN OTHERS THEN
         l_cnt_of_line_extns_gt := 0;
      END;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             'l_cnt_of_line_extns_gt = '||l_cnt_of_line_extns_gt);
      BEGIN
         SELECT count(*)
           INTO l_cnt_of_loc_info_gt
           FROM ZX_PTNR_LOCATION_INFO_GT;
      EXCEPTION WHEN OTHERS THEN
         l_cnt_of_loc_info_gt := 0;
      END;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             'l_cnt_of_loc_info_gt = '||l_cnt_of_loc_info_gt);
      BEGIN
         SELECT count(*)
           INTO l_cnt_of_neg_line_gt
           FROM ZX_PTNR_NEG_LINE_GT;
      EXCEPTION WHEN OTHERS THEN
         l_cnt_of_neg_line_gt := 0;
      END;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                'l_cnt_of_neg_line_gt = '||l_cnt_of_neg_line_gt);
      END IF;
   END IF;

   BEGIN
     SELECT trx_line_id,
            decode(adjusted_doc_application_id,
                        222,decode(adjusted_doc_event_class_code,
                                          'INVOICE', 4,
                                          'DEBIT_MEMO', 5,
                                          'CREDIT_MEMO', 6,
                                           NULL
                                  )
                        ,NULL) adjusted_doc_document_type_id,
            adjusted_doc_trx_id,
            adjusted_doc_line_id,
            adjusted_doc_trx_level_type
       BULK COLLECT
       INTO pg_trx_line_id_tab,
            pg_adj_doc_doc_type_id_tab,
            pg_adj_doc_trx_id_tab,
            pg_adj_doc_line_id_tab,
            pg_adj_doc_trx_lev_type_tab
       FROM ZX_PTNR_NEG_LINE_GT
      WHERE event_class_mapping_id = x_transaction_rec.document_type_id
        AND trx_id                 = x_transaction_rec.transaction_id;
    EXCEPTION
        WHEN no_data_found THEN
	   IF (g_level_exception >= g_current_runtime_level ) THEN
              FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
	   End if;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           g_string        := 'No document type exist for provided event_class_mapping_id ';
           error_exception_handle(g_string);
           x_messages_tbl  :=  g_messages_tbl;
           RETURN;
   END;

 BEGIN
      SELECT event_class_code
        INTO l_document_type
        FROM zx_evnt_cls_mappings
       WHERE event_class_mapping_id = x_transaction_rec.document_type_id;
   EXCEPTION
        WHEN no_data_found THEN
	   IF (g_level_exception >= g_current_runtime_level ) THEN
              FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
	   End if;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           g_string        := 'No document type exist for provided event_class_mapping_id ';
           error_exception_handle(g_string);
           x_messages_tbl  :=  g_messages_tbl;
           RETURN;
   END;
   --Bug 8576319
   --Call Set Document Type

   SELECT SUM(ABS(line_amt))
     INTO l_doc_amount
     FROM ZX_PTNR_NEG_LINE_GT
    WHERE event_class_mapping_id = x_transaction_rec.document_type_id
      AND trx_id                 = x_transaction_rec.transaction_id;

   SET_DOCUMENT_TYPE(l_document_type,
                     x_transaction_rec.transaction_id,
                     l_doc_amount,
                     l_return_status);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_exception >= g_current_runtime_level ) THEN
        FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      g_string :='Failed in setting up document type';
      error_exception_handle(g_string);
      x_messages_tbl:=g_messages_tbl;
      return;
   END IF;
   -- End Bug 8576319
   FOR cnt IN 1..nvl(pg_trx_line_id_tab.last, 0)
   LOOP
      I := cnt;
      perform_line_deletion(l_return_status);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         g_string :='Failed in PERFORM_LINE_DELETION procedure';
         error_exception_handle(g_string);
         RETURN;
      END IF;
   END LOOP;


  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()+');
  END IF;

End GLOBAL_DOCUMENT_UPDATE;

PROCEDURE dump_vendor_rec ( dmpTaxLink      	ZX_TAX_TAXWARE_GEN.TaxParm,
                            dmpJurLink      	ZX_TAX_TAXWARE_GEN.JurParm,
                            dmpOraLink          ZX_TAX_TAXWARE_GEN.t_OraParm,
			    input_param_flag  	BOOLEAN  ) IS

  l_temp_reserved_bool VARCHAR2(10) := null;
  l_api_name           CONSTANT VARCHAR2(30) := 'DUMP_VENDOR_REC';
BEGIN

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
  END IF;

  IF input_param_flag THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'====================================');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'----- OraLink Input Parameters -----');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'====================================');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'OracleId = ['||dmpOraLink.OracleId||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Oracle_Msg_Text = ['||dmpOraLink.oracle_msg_text||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Oracle_Msg_Label = ['||dmpOraLink.oracle_msg_label||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Taxware_Msg_Text = ['||dmpOraLink.taxware_msg_text||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_Text_1 = ['||dmpOraLink.reserved_text_1||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_Text_2 = ['||dmpOraLink.reserved_text_2||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_Text_3 = ['||dmpOraLink.reserved_text_3||']');
     END IF;
     if dmpOraLink.reserved_bool_1 is null then
       l_temp_reserved_bool := '';
     elsif dmpOraLink.reserved_bool_1 then
       l_temp_reserved_bool := 'TRUE';
     else
       l_temp_reserved_bool := 'FALSE';
     end if;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_BOOL_1 = ['||l_temp_reserved_bool||']');
     END IF;
     if dmpOraLink.reserved_bool_2 is null then
       l_temp_reserved_bool := '';
     elsif dmpOraLink.reserved_bool_2 then
       l_temp_reserved_bool := 'TRUE';
     else
       l_temp_reserved_bool := 'FALSE';
     end if;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_BOOL_2 = ['||l_temp_reserved_bool||']');
     END IF;
     if dmpOraLink.reserved_bool_3 is null then
       l_temp_reserved_bool := '';
     elsif dmpOraLink.reserved_bool_3 then
       l_temp_reserved_bool := 'TRUE';
     else
       l_temp_reserved_bool := 'FALSE';
     end if;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_BOOL_3 = ['||l_temp_reserved_bool||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_CHAR_1 = ['||dmpOraLink.reserved_char_1||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_CHAR_2 = ['||dmpOraLink.reserved_char_2||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_CHAR_3 = ['||dmpOraLink.reserved_char_3||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_NUM_1 = ['||to_char(dmpOraLink.reserved_num_1)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_NUM_2 = ['||to_char(dmpOraLink.reserved_num_2)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_BIGNUM_1 = ['||to_char(dmpOraLink.reserved_bignum_1)||']');

        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_DATE_1 = ['||to_char(dmpOraLink.reserved_date_1,'DD-MON-RR')||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'====================================');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'----- TaxLink Input Parameters -----');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'====================================');
     	--FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'vendor_param.tax_selection = ['||vendor_param.tax_selection||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CalcType = ['||dmpTaxLink.CalcType||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CnSlsUse = ['||dmpTaxLink.CnSlsUse||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CustNo = ['||dmpTaxLink.CustNo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CustName = ['||dmpTaxLink.CustName||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CompanyID = ['||dmpTaxLink.CompanyID||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.DivCode = ['||dmpTaxLink.DivCode||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.GrossAmt = ['||to_char(dmpTaxLink.GrossAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.TaxAmt = ['||to_char(dmpTaxLink.TaxAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CreditInd = ['||
   		arp_trx_util.boolean_to_varchar2(dmpTaxLink.CreditInd)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.InvoiceDate = ['||to_char(dmpTaxLink.InvoiceDate)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.InvoiceNo = ['||dmpTaxLink.InvoiceNo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.LoSlsUse = ['||dmpTaxLink.LoSlsUse||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.NoCnTax = ['||
   		arp_trx_util.boolean_to_varchar2(dmpTaxLink.NoCnTax)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.NoLoTax = ['||
   		arp_trx_util.boolean_to_varchar2(dmpTaxLink.NoLoTax)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.NoSecCnTax = ['||
   		arp_trx_util.boolean_to_varchar2(dmpTaxLink.NoSecCnTax)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.NoSecLoTax = ['||
   		arp_trx_util.boolean_to_varchar2(dmpTaxLink.NoSecLoTax)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.NoStaTax = ['||
   		arp_trx_util.boolean_to_varchar2(dmpTaxLink.NoStaTax)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.NoTaxInd = ['||
   		arp_trx_util.boolean_to_varchar2(dmpTaxLink.NoTaxInd)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.NumItems = ['||to_char(dmpTaxLink.NumItems)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.PriGeo = ['||dmpTaxLink.PriGeo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.PriZip = ['||dmpTaxLink.PriZip||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.InOutCityLimits = ['||dmpTaxLink.InOutCityLimits||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.ProdCode = ['||dmpTaxLink.ProdCode||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.ReptInd = ['||
   		arp_trx_util.boolean_to_varchar2(dmpTaxLink.ReptInd)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.SecStSlsUse = ['||dmpTaxLink.SecStSlsUse||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StaSlsUse = ['||dmpTaxLink.StaSlsUse||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StateCode = ['||dmpTaxLink.StateCode||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StaExempt = ['||
   		arp_trx_util.boolean_to_varchar2(dmpTaxLink.StaExempt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StExemptAmt = ['||to_char(dmpTaxLink.StExemptAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StReasonCode = ['||dmpTaxLink.StReasonCode||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StTaxCertNo = ['||dmpTaxLink.StTaxCertNo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CnExempt = ['||
   		arp_trx_util.boolean_to_varchar2(dmpTaxLink.CnExempt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CntyExemptAmt = ['||to_char(dmpTaxLink.CntyExemptAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CntyReasonCode = ['||dmpTaxLink.CntyReasonCode||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CnTaxCertNo = ['||dmpTaxLink.CnTaxCertNo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.LoExempt = ['||
   		arp_trx_util.boolean_to_varchar2(dmpTaxLink.LoExempt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CityExemptAmt = ['||to_char(dmpTaxLink.CityExemptAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CityReasonCode = ['||dmpTaxLink.CityReasonCode||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.LoTaxCertNo = ['||dmpTaxLink.LoTaxCertNo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.SecCnExempt = ['||
   		arp_trx_util.boolean_to_varchar2(dmpTaxLink.SecCnExempt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.SecCnExemptAmt = ['||to_char(dmpTaxLink.SecCnExemptAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.SecLoExempt = ['||
   		arp_trx_util.boolean_to_varchar2(dmpTaxLink.SecLoExempt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.SecLoExemptAmt = ['||to_char(dmpTaxLink.SecLoExemptAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'----- STEP/NEXPRO Input Parameters -----');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.UseStep = ['||dmpTaxLink.UseStep||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StepProcFlg = ['||dmpTaxLink.StepProcFlg||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.JobNo = ['||dmpTaxLink.JobNo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CritFlg = ['||dmpTaxLink.CritFlg||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.UseNexproInd = ['||dmpTaxLink.UseNexproInd||']');

    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'3232492 StOvAmt =='|| dmpTaxLink.StOvAmt);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'3232492 CnOvAmt =='|| dmpTaxLink.CnOvAmt);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'3232492 LoOvAmt =='|| dmpTaxLink.LoOvAmt);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'3232492 ScStOvAmt =='|| dmpTaxLink.ScStOvAmt);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'3232492 ScCnOvAmt =='|| dmpTaxLink.ScCnOvAmt);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'3232492 ScLoOvAmt =='|| dmpTaxLink.ScLoOvAmt);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'3232492 DistOvAmt =='|| dmpTaxLink.DistOvAmt);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'3232492 FedOvAmt =='|| dmpTaxLink.FedOvAmt);

     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'====================================');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'----- JurLink Input Parameters -----');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'====================================');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.POA.Geo = ['||dmpJurLink.POA.Geo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.POA.State = ['||dmpJurLink.POA.State||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.POA.Zip = ['||dmpJurLink.POA.Zip||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.InOutCiLimPOA = ['||dmpJurLink.InOutCiLimPOA||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.POO.Geo = ['||dmpJurLink.POO.Geo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.POO.State = ['||dmpJurLink.POO.State||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.POO.Zip = ['||dmpJurLink.POO.Zip||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.InOutCiLimPOO = ['||dmpJurLink.InOutCiLimPOO||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.ShipFr.Geo = ['||dmpJurLink.ShipFr.Geo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.ShipFr.State = ['||dmpJurLink.ShipFr.State||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.ShipFr.Zip = ['||dmpJurLink.ShipFr.Zip||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.InOutCiLimShFr = ['||dmpJurLink.InOutCiLimShFr||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.ShipTo.Geo = ['||dmpJurLink.ShipTo.Geo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.ShipTo.State = ['||dmpJurLink.ShipTo.State||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.ShipTo.Zip = ['||dmpJurLink.ShipTo.Zip||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.InOutCiLimShTo = ['||dmpJurLink.InOutCiLimShTo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.POT = ['||dmpJurLink.POT||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.ServInd = ['||dmpJurLink.ServInd||']');
     END IF;

  ELSE
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'====================================');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'----- OraLink Output Parameters ----');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'====================================');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'OracleId = ['||dmpOraLink.OracleId||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Oracle_Msg_Text = ['||dmpOraLink.oracle_msg_text||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Oracle_Msg_Label = ['||dmpOraLink.oracle_msg_label||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Taxware_Msg_Text = ['||dmpOraLink.taxware_msg_text||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_Text_1 = ['||dmpOraLink.reserved_text_1||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_Text_2 = ['||dmpOraLink.reserved_text_2||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_Text_3 = ['||dmpOraLink.reserved_text_3||']');
     END IF;
     if dmpOraLink.reserved_bool_1 is null then
       l_temp_reserved_bool := '';
     elsif dmpOraLink.reserved_bool_1 then
       l_temp_reserved_bool := 'TRUE';
     else
       l_temp_reserved_bool := 'FALSE';
     end if;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_BOOL_1 = ['||l_temp_reserved_bool||']');
     END IF;
     if dmpOraLink.reserved_bool_2 is null then
       l_temp_reserved_bool := '';
     elsif dmpOraLink.reserved_bool_2 then
       l_temp_reserved_bool := 'TRUE';
     else
       l_temp_reserved_bool := 'FALSE';
     end if;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_BOOL_2 = ['||l_temp_reserved_bool||']');
     END IF;
     if dmpOraLink.reserved_bool_3 is null then
       l_temp_reserved_bool := '';
     elsif dmpOraLink.reserved_bool_3 then
       l_temp_reserved_bool := 'TRUE';
     else
       l_temp_reserved_bool := 'FALSE';
     end if;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_BOOL_3 = ['||l_temp_reserved_bool||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_CHAR_1 = ['||dmpOraLink.reserved_char_1||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_CHAR_2 = ['||dmpOraLink.reserved_char_2||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_CHAR_3 = ['||dmpOraLink.reserved_char_3||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_NUM_1 = ['||to_char(dmpOraLink.reserved_num_1)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_NUM_2 = ['||to_char(dmpOraLink.reserved_num_2)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_BIGNUM_1 = ['||to_char(dmpOraLink.reserved_bignum_1)||']');
	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Reserved_DATE_1 = ['||to_char(dmpOraLink.reserved_date_1,'DD-MON-RR')||']');
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'====================================');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'----- TaxLink Output Parameters ----');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'====================================');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.GenCmplCd = ['||dmpTaxLink.GenCmplCd||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StaCmplCd = ['||dmpTaxLink.StaCmplCd||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CnCmplCd = ['||dmpTaxLink.CnCmplCd||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.LoCmplCd = ['||dmpTaxLink.LoCmplCd||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CreditInd = ['||
	   		arp_trx_util.boolean_to_varchar2(dmpTaxLink.CreditInd)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.ScCnCmplCd = ['||dmpTaxLink.ScCnCmplCd||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.ScLoCmplCd = ['||dmpTaxLink.ScLoCmplCd||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.DistCmplCd = ['||dmpTaxLink.DistCmplCd||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.GrossAmt = ['||to_char(dmpTaxLink.GrossAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.TaxAmt = ['||to_char(dmpTaxLink.TaxAmt)||']');

	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StaTxRate = ['||
			to_char(dmpTaxLink.StaTxRate*100)||']');
	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CnTxRate = ['||
			to_char(dmpTaxLink.CnTxRate*100)||']');
	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.LoTxRate = ['||
			to_char(dmpTaxLink.LoTxRate*100)||']');
	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.ScCnTxRate = ['||
			to_char(dmpTaxLink.ScCnTxRate*100)||']');
	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.ScLoTxRate = ['||
			to_char(dmpTaxLink.ScLoTxRate*100)||']');
     END IF;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StaTxAmt = ['||to_char(dmpTaxLink.StaTxAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CnTxAmt = ['||to_char(dmpTaxLink.CnTxAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.LoTxAmt = ['||to_char(dmpTaxLink.LoTxAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.ScCnTxAmt = ['||to_char(dmpTaxLink.ScCnTxAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.ScLoTxAmt = ['||to_char(dmpTaxLink.ScLoTxAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.FedBasisAmt = ['||to_char(dmpTaxLink.FedBasisAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StBasisAmt = ['||to_char(dmpTaxLink.StBasisAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CntyBasisAmt = ['||to_char(dmpTaxLink.CntyBasisAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CityBasisAmt = ['||to_char(dmpTaxLink.CityBasisAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.ScStBasisAmt = ['||to_char(dmpTaxLink.ScStBasisAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.ScCntyBasisAmt = ['||to_char(dmpTaxLink.ScCntyBasisAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.ScCityBasisAmt = ['||to_char(dmpTaxLink.ScCityBasisAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.DistBasisAmt = ['||to_char(dmpTaxLink.DistBasisAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'----- STEP/NEXPRO Output Parameters -----');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StaStatus = ['||dmpTaxLink.StaStatus||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CnStatus = ['||dmpTaxLink.CnStatus||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.LoStatus = ['||dmpTaxLink.LoStatus||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StComment = ['||dmpTaxLink.StComment||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CnComment = ['||dmpTaxLink.CnComment||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.LoComment = ['||dmpTaxLink.LoComment||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StExemptAmt = ['||to_char(dmpTaxLink.StExemptAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CntyExemptAmt = ['||to_char(dmpTaxLink.CntyExemptAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CityExemptAmt = ['||to_char(dmpTaxLink.CityExemptAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.SecCnExemptAmt = ['||to_char(dmpTaxLink.SecCnExemptAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.SecLoExemptAmt = ['||to_char(dmpTaxLink.SecLoExemptAmt)||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StReasonCode = ['||dmpTaxLink.StReasonCode||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CntyReasonCode = ['||dmpTaxLink.CntyReasonCode||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CityReasonCode = ['||dmpTaxLink.CityReasonCode||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.StTaxCertNo = ['||dmpTaxLink.StTaxCertNo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.CnTaxCertNo = ['||dmpTaxLink.CnTaxCertNo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'TaxLink.LoTaxCertNo = ['||dmpTaxLink.LoTaxCertNo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'====================================');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'----- JurLink Output Parameters ----');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'====================================');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.ReturnCode = ['||dmpJurLink.ReturnCode||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.POOJurRC = ['||dmpJurLink.POOJurRC||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.POAJurRC = ['||dmpJurLink.POAJurRC||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.ShpToJurRC = ['||dmpJurLink.ShpToJurRC||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.ShpFrJurRC = ['||dmpJurLink.ShpFrJurRC||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.JurLocType = ['||dmpJurLink.JurLocType||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.JurState = ['||dmpJurLink.JurState||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.JurCity = ['||dmpJurLink.JurCity||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.JurZip = ['||dmpJurLink.JurZip||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.JurGeo = ['||dmpJurLink.JurGeo||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.TypState = ['||dmpJurLink.TypState||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.TypCnty = ['||dmpJurLink.TypCnty||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.TypCity = ['||dmpJurLink.TypCity||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.TypSecState = ['||dmpJurLink.TypSecState||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.TypSecCnty = ['||dmpJurLink.TypSecCnty||']');
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'JurLink.TypSecCity = ['||dmpJurLink.TypSecCity||']');
     /*Bug 3257088
        arp_tax.tax_info_rec.global_attribute16 :=  dmpJurLink.JurLocType ;*/
     	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'3257078:JurLink.JurLocType = ['||dmpJurLink.JurLocType||']');
     END IF;
  END IF;		-- input_param_flag?

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;

END dump_vendor_rec;

Begin /*Constructor*/
   initialize;
END ZX_TAXWARE_TAX_SERVICE_PKG;

/
