--------------------------------------------------------
--  DDL for Package Body ZX_VERTEX_TAX_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_VERTEX_TAX_SERVICE_PKG" as
/*$Header: zxvtxsrvcpkgb.pls 120.49.12010000.18 2011/01/19 13:03:55 snoothi ship $*/

/* ======================================================================*
 | FND Logging infrastructure                                           |
 * ======================================================================*/
G_PKG_NAME               CONSTANT VARCHAR2(30) := 'ZX_VERTEX_TAX_SERVICE_PKG';
G_CURRENT_RUNTIME_LEVEL  CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED       CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR            CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION        CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT            CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE        CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT        CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME            CONSTANT VARCHAR2(80) := 'ZX.PLSQL.ZX_VERTEX_TAX_SERVICE_PKG.';

/* ======================================================================*
 | Global Structure Data Types                                           |
 * ======================================================================*/

TYPE NUMBER_tbl_type       IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_1_tbl_type   IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_2_tbl_type   IS TABLE OF VARCHAR2(2)    INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_15_tbl_type  IS TABLE OF VARCHAR2(15)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_30_tbl_type  IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_80_tbl_type  IS TABLE OF VARCHAR2(80)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_50_tbl_type  IS TABLE OF VARCHAR2(50)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_240_tbl_type IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
TYPE DATE_tbl_type         IS TABLE OF DATE           INDEX BY BINARY_INTEGER;

TYPE SYNC_TAX_LINES_TBL IS RECORD(
  document_type_id           NUMBER_tbl_type,
  transaction_id             NUMBER_tbl_type,
  transaction_line_id        NUMBER_tbl_type,
  trx_level_type             VARCHAR2_30_tbl_type,
  country_code               VARCHAR2_30_tbl_type,
  tax                        VARCHAR2_30_tbl_type,
  situs                      VARCHAR2_30_tbl_type,
  tax_jurisdiction           VARCHAR2_30_tbl_type,
  tax_currency_code          VARCHAR2_15_tbl_type,
  tax_curr_tax_amount        NUMBER_tbl_type,
  tax_amount                 NUMBER_tbl_type,
  tax_rate_percentage        NUMBER_tbl_type,
  taxable_amount             NUMBER_tbl_type,
  exempt_rate_modifier       NUMBER_tbl_type,
  exempt_reason              VARCHAR2_240_tbl_type,
  tax_only_line_flag         VARCHAR2_1_tbl_type,
  inclusive_tax_line_flag    VARCHAR2_1_tbl_type,
  use_tax_flag               VARCHAR2_1_tbl_type,
  ebiz_override_flag         VARCHAR2_1_tbl_type,
  user_override_flag         VARCHAR2_1_tbl_type,
  last_manual_entry          VARCHAR2_30_tbl_type,
  manually_entered_flag      VARCHAR2_1_tbl_type,
  cancel_flag                VARCHAR2_1_tbl_type,
  delete_flag                VARCHAR2_1_tbl_type
);


/*------------------------------------------------
|         Global Variables                        |
 ------------------------------------------------*/
  C_LINES_PER_COMMIT CONSTANT NUMBER := 1000;
  I Number;
  l_line_level_action varchar2(20);
  l_document_type zx_lines_det_factors.event_class_code%type;
  l_trx_line_context_changed      BOOLEAN;
  l_state_tax_cnt        NUMBER;
  l_county_tax_cnt       NUMBER;
  l_city_tax_cnt         NUMBER;
-- PG_DEBUG varchar2(1);
-- x_return_status varchar2(2);
  g_StTaxAmt     NUMBER;
  g_CoTaxAmt     NUMBER;
  g_CiTaxAmt     NUMBER;
  g_TotalTaxAmt  NUMBER;
  cache_index    NUMBER:=0;
  g_string       VARCHAR2(200);

  g_docment_type_id  NUMBER;
  g_trasaction_id  NUMBER;
  g_tax_regime_code  varchar2(80);
  g_transaction_line_id  NUMBER;
  g_trx_level_type       varchar2(20);

  TYPE cache_record_type is record(
    internal_organization_id  NUMBER,
    document_type_id          NUMBER,
    transaction_id            NUMBER,
    transaction_line_id       NUMBER
    );

  TYPE cache_tab is table of cache_record_type index by binary_integer;
  cache_table cache_tab;

 /**** Type used in GET_GEOCODE ***/
  TYPE tab_var_type IS TABLE OF VARCHAR2(60) INDEX BY BINARY_INTEGER;

  pg_state        tab_var_type; -- Ship-To State Name(Abbriv)
  pg_county       tab_var_type; -- Ship-To County Name
  pg_city         tab_var_type; -- Ship-To City Name
  pg_postal_code  tab_var_type; -- Ship-To Postal_code
  pg_geocode      tab_var_type; -- Jurisdiction code(GeoCode)
  pg_max_index    BINARY_INTEGER := 0; -- Pointer to the no. of jurisdiction
                   -- combination in the table
/*-----------------------------------------------
 | Records for Tax Calculation Package     |
 -----------------------------------------------*/
  version_rec             ZX_TAX_VERTEX_QSU.tQSUVersionRecord;
  context_rec             ZX_TAX_VERTEX_QSU.tQSUContextRecord;
  inv_in_rec              ZX_TAX_VERTEX_QSU.tQSUInvoiceRecord;
  line_in_tab             ZX_TAX_VERTEX_QSU.tQSULineItemTable;
  inv_out_rec             ZX_TAX_VERTEX_QSU.tQSUInvoiceRecord;
  line_out_tab            ZX_TAX_VERTEX_QSU.tQSULineItemTable;

/* ======================================================================*
 | Data Type Definitions                                                 |
 * ======================================================================*/

  type char_tab is table of char           index by binary_integer;
  type num_tab  is table of NUMBER(15)     index by binary_integer;
  type num1_tab is table of NUMBER         index by binary_integer;
  type date_tab is table of DATE           index by binary_integer;
  type var1_tab is table of VARCHAR2(1)    index by binary_integer;
  type var2_tab is table of VARCHAR2(80)   index by binary_integer;
  type var3_tab is table of VARCHAR2(2000) index by binary_integer;
  type var4_tab is table of VARCHAR2(150)  index by binary_integer;
  type var5_tab is table of VARCHAR2(240)  index by binary_integer;
  type var6_tab is table of VARCHAR2(300)  index by binary_integer;

 /*-----------------------------------------------
 | Records for GeoCode Retrieval Package   |
 -----------------------------------------------*/
  search_rec              ZX_TAX_VERTEX_GEO.tGeoSearchRecord;
  result_rec              ZX_TAX_VERTEX_GEO.tGeoResultsRecord;

  TYPE location_info_rec_type IS RECORD(
   state         VARCHAR2(2),
   county        VARCHAR2(30),
   city          VARCHAR2(30),
   postal_code   VARCHAR2(30)
  );

  /*Private Procedures*/
  PROCEDURE PERFORM_VALIDATE(x_return_status OUT NOCOPY VARCHAR2) ;

  PROCEDURE PERFORM_LINE_CREATION (
    p_tax_lines_tbl IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
    p_currency_tab  IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
    x_return_status    OUT NOCOPY VARCHAR2);

  PROCEDURE PERFORM_LINE_DELETION(x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE PERFORM_UPDATE (
    p_tax_lines_tbl IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
    p_currency_tab  IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
    x_return_status    OUT NOCOPY VARCHAR2);

  PROCEDURE SET_PARAMETERS       (x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE SET_DOCUMENT_TYPE (
    p_document_type     IN OUT NOCOPY VARCHAR2,
    p_adj_doc_trx_id    IN NUMBER,
    p_line_amount       IN NUMBER,
    p_line_level_action IN VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2);

  FUNCTION GET_GEOCODE(p_location_info_rec location_info_rec_type) return VARCHAR2;

  PROCEDURE CALCULATE_TAX(x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE WRITE_TO_VERTEX_REPOSITORY(x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE TAX_RESULTS_PROCESSING (
    p_tax_lines_tbl IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
    p_currency_tab  IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
    x_return_status    OUT NOCOPY VARCHAR2);

  PROCEDURE RESET_PARAMETERS(x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE INITIALIZE;

  PROCEDURE DISPLAY_OUTPUT(p_type IN VARCHAR2);

  PROCEDURE ERROR_EXCEPTION_HANDLE(str  VARCHAR2);

  /*Structure to hold the transaction information*/
  pg_internal_org_id_tab         num1_tab;
  pg_doc_type_id_tab             num1_tab;
  pg_trx_id_tab                  num1_tab;
  pg_appli_code_tab              var2_tab;
  pg_doc_level_action_tab        var2_tab;
  pg_trx_date_tab                date_tab;
  pg_trx_curr_code_tab           var2_tab;
  /* Bug 5090593:
  pg_quote_flag_tab              var1_tab;
  */
  pg_legal_entity_num_tab        var2_tab;
  pg_esta_name_tab               var3_tab;
  pg_Trx_number_tab              var4_tab;
  pg_Trx_desc_tab                var3_tab;
  pg_doc_sequence_value_tab      var3_tab;
  pg_Trx_due_date_tab            date_tab;
  /* Bug 5090593:
  pg_Trx_Sol_Ori_tab             var2_tab;
  */
  pg_Allow_Tax_Calc_tab          var1_tab;
  pg_trx_line_id_tab             num1_tab;
  pg_trx_level_type_tab          var2_tab;
  pg_line_level_action_tab       var2_tab;
  pg_line_class_tab              var2_tab;
  pg_trx_shipping_date_tab       date_tab;
  pg_trx_receipt_date_tab        date_tab;
  pg_trx_line_type_tab           var2_tab;
  pg_trx_line_date_tab           date_tab;
  pg_trx_business_cat_tab        var3_tab;
  pg_line_intended_use_tab       var3_tab;
  pg_line_amt_incl_tax_flag_tab  var1_tab;
  pg_line_amount_tab             num1_tab;
  pg_other_incl_tax_amt_tab      num1_tab;
  pg_trx_line_qty_tab            num1_tab;
  pg_unit_price_tab              num1_tab;
  pg_cash_discount_tab           num1_tab;
  pg_volume_discount_tab         num1_tab;
  pg_trading_discount_tab        num1_tab;
  pg_trans_charge_tab            num1_tab;
  pg_ins_charge_tab              num1_tab;
  pg_other_charge_tab            num1_tab;
  pg_prod_id_tab                 num1_tab;
  pg_uom_code_tab                var2_tab;
  pg_prod_type_tab               var3_tab;
  pg_prod_code_tab               var6_tab;
  pg_fob_point_tab               var2_tab;
  pg_ship_to_pty_numr_tab        var2_tab;
  pg_ship_to_pty_name_tab        var3_tab;
  pg_ship_from_pty_num_tab       var2_tab;
  pg_ship_from_pty_name_tab      var3_tab;
  pg_ship_to_loc_id_tab          num1_tab;      -- Bug 5090593
  pg_ship_to_grphy_type1_tab     var5_tab;
  pg_ship_to_grphy_value1_tab    var5_tab;
  pg_ship_to_grphy_type2_tab     var5_tab;
  pg_ship_to_grphy_value2_tab    var5_tab;
  pg_ship_to_grphy_type3_tab     var5_tab;
  pg_ship_to_grphy_value3_tab    var5_tab;
  pg_ship_to_grphy_type4_tab     var5_tab;
  pg_ship_to_grphy_value4_tab    var5_tab;
  pg_ship_to_grphy_type5_tab     var5_tab;
  pg_ship_to_grphy_value5_tab    var5_tab;
  pg_ship_to_grphy_type6_tab     var5_tab;
  pg_ship_to_grphy_value6_tab    var5_tab;
  pg_ship_to_grphy_type7_tab     var5_tab;
  pg_ship_to_grphy_value7_tab    var5_tab;
  pg_ship_to_grphy_type8_tab     var5_tab;
  pg_ship_to_grphy_value8_tab    var5_tab;
  pg_ship_to_grphy_type9_tab     var5_tab;
  pg_ship_to_grphy_value9_tab    var5_tab;
  pg_ship_to_grphy_type10_tab    var5_tab;
  pg_ship_to_grphy_value10_tab   var5_tab;
  pg_ship_fr_loc_id_tab          num1_tab;      -- Bug 5090593
  pg_ship_fr_grphy_type1_tab     var5_tab;
  pg_ship_fr_grphy_value1_tab    var5_tab;
  pg_ship_fr_grphy_type2_tab     var5_tab;
  pg_ship_fr_grphy_value2_tab    var5_tab;
  pg_ship_fr_grphy_type3_tab     var5_tab;
  pg_ship_fr_grphy_value3_tab    var5_tab;
  pg_ship_fr_grphy_type4_tab     var5_tab;
  pg_ship_fr_grphy_value4_tab    var5_tab;
  pg_ship_fr_grphy_type5_tab     var5_tab;
  pg_ship_fr_grphy_value5_tab    var5_tab;
  pg_ship_fr_grphy_type6_tab     var5_tab;
  pg_ship_fr_grphy_value6_tab    var5_tab;
  pg_ship_fr_grphy_type7_tab     var5_tab;
  pg_ship_fr_grphy_value7_tab    var5_tab;
  pg_ship_fr_grphy_type8_tab     var5_tab;
  pg_ship_fr_grphy_value8_tab    var5_tab;
  pg_ship_fr_grphy_type9_tab     var5_tab;
  pg_ship_fr_grphy_value9_tab    var5_tab;
  pg_ship_fr_grphy_type10_tab    var5_tab;
  pg_ship_fr_grphy_value10_tab   var5_tab;
  pg_poa_loc_id_tab              num1_tab;      -- Bug 5090593
  pg_poa_grphy_type1_tab         var5_tab;
  pg_poa_grphy_value1_tab        var5_tab;
  pg_poa_grphy_type2_tab         var5_tab;
  pg_poa_grphy_value2_tab        var5_tab;
  pg_poa_grphy_type3_tab         var5_tab;
  pg_poa_grphy_value3_tab        var5_tab;
  pg_poa_grphy_type4_tab         var5_tab;
  pg_poa_grphy_value4_tab        var5_tab;
  pg_poa_grphy_type5_tab         var5_tab;
  pg_poa_grphy_value5_tab        var5_tab;
  pg_poa_grphy_type6_tab         var5_tab;
  pg_poa_grphy_value6_tab        var5_tab;
  pg_poa_grphy_type7_tab         var5_tab;
  pg_poa_grphy_value7_tab        var5_tab;
  pg_poa_grphy_type8_tab         var5_tab;
  pg_poa_grphy_value8_tab        var5_tab;
  pg_poa_grphy_type9_tab         var5_tab;
  pg_poa_grphy_value9_tab        var5_tab;
  pg_poa_grphy_type10_tab        var5_tab;
  pg_poa_grphy_value10_tab       var5_tab;
  pg_poo_loc_id_tab              num1_tab;      -- Bug 5090593
  pg_poo_grphy_type1_tab         var5_tab;
  pg_poo_grphy_value1_tab        var5_tab;
  pg_poo_grphy_type2_tab         var5_tab;
  pg_poo_grphy_value2_tab        var5_tab;
  pg_poo_grphy_type3_tab         var5_tab;
  pg_poo_grphy_value3_tab        var5_tab;
  pg_poo_grphy_type4_tab         var5_tab;
  pg_poo_grphy_value4_tab        var5_tab;
  pg_poo_grphy_type5_tab         var5_tab;
  pg_poo_grphy_value5_tab        var5_tab;
  pg_poo_grphy_type6_tab         var5_tab;
  pg_poo_grphy_value6_tab        var5_tab;
  pg_poo_grphy_type7_tab         var5_tab;
  pg_poo_grphy_value7_tab        var5_tab;
  pg_poo_grphy_type8_tab         var5_tab;
  pg_poo_grphy_value8_tab        var5_tab;
  pg_poo_grphy_type9_tab         var5_tab;
  pg_poo_grphy_value9_tab        var5_tab;
  pg_poo_grphy_type10_tab        var5_tab;
  pg_poo_grphy_value10_tab       var5_tab;
  pg_bill_to_pty_num_tab         var2_tab;
  pg_bill_to_pty_name_tab        var3_tab;
  pg_bill_from_pty_num_tab       var2_tab;
  pg_bill_from_pty_name_tab      var3_tab;
  pg_bill_to_loc_id_tab          num1_tab;      -- Bug 5090593
  pg_bill_to_grphy_type1_tab     var5_tab;
  pg_bill_to_grphy_value1_tab    var5_tab;
  pg_bill_to_grphy_type2_tab     var5_tab;
  pg_bill_to_grphy_value2_tab    var5_tab;
  pg_bill_to_grphy_type3_tab     var5_tab;
  pg_bill_to_grphy_value3_tab    var5_tab;
  pg_bill_to_grphy_type4_tab     var5_tab;
  pg_bill_to_grphy_value4_tab    var5_tab;
  pg_bill_to_grphy_type5_tab     var5_tab;
  pg_bill_to_grphy_value5_tab    var5_tab;
  pg_bill_to_grphy_type6_tab     var5_tab;
  pg_bill_to_grphy_value6_tab    var5_tab;
  pg_bill_to_grphy_type7_tab     var5_tab;
  pg_bill_to_grphy_value7_tab    var5_tab;
  pg_bill_to_grphy_type8_tab     var5_tab;
  pg_bill_to_grphy_value8_tab    var5_tab;
  pg_bill_to_grphy_type9_tab     var5_tab;
  pg_bill_to_grphy_value9_tab    var5_tab;
  pg_bill_to_grphy_type10_tab    var5_tab;
  pg_bill_to_grphy_value10_tab   var5_tab;
  pg_bill_fr_loc_id_tab          num1_tab;      -- Bug 5090593
  pg_bill_fr_grphy_type1_tab     var5_tab;
  pg_bill_fr_grphy_value1_tab    var5_tab;
  pg_bill_fr_grphy_type2_tab     var5_tab;
  pg_bill_fr_grphy_value2_tab    var5_tab;
  pg_bill_fr_grphy_type3_tab     var5_tab;
  pg_bill_fr_grphy_value3_tab    var5_tab;
  pg_bill_fr_grphy_type4_tab     var5_tab;
  pg_bill_fr_grphy_value4_tab    var5_tab;
  pg_bill_fr_grphy_type5_tab     var5_tab;
  pg_bill_fr_grphy_value5_tab    var5_tab;
  pg_bill_fr_grphy_type6_tab     var5_tab;
  pg_bill_fr_grphy_value6_tab    var5_tab;
  pg_bill_fr_grphy_type7_tab     var5_tab;
  pg_bill_fr_grphy_value7_tab    var5_tab;
  pg_bill_fr_grphy_type8_tab     var5_tab;
  pg_bill_fr_grphy_value8_tab    var5_tab;
  pg_bill_fr_grphy_type9_tab     var5_tab;
  pg_bill_fr_grphy_value9_tab    var5_tab;
  pg_bill_fr_grphy_type10_tab    var5_tab;
  pg_bill_fr_grphy_value10_tab   var5_tab;
  pg_account_ccid_tab            num1_tab;
  pg_appl_fr_doc_type_id_tab     num1_tab;
  pg_appl_from_trx_id_tab        num1_tab;
  pg_appl_from_line_id_tab       num1_tab;
  pg_appl_fr_trx_lev_type_tab    var2_tab;
  pg_appl_from_doc_num_tab       var2_tab;
  pg_adj_doc_doc_type_id_tab     num1_tab;
  pg_adj_doc_trx_id_tab          num1_tab;
  pg_adj_doc_line_id_tab         num1_tab;
  pg_adj_doc_number_tab          var2_tab;
  pg_ADJ_doc_trx_lev_type_tab    var2_tab;
  pg_adj_doc_date_tab            date_tab;
  pg_assess_value_tab            num1_tab;
  pg_trx_line_number_tab         num1_tab;
  pg_trx_line_desc_tab           var3_tab;
  pg_prod_desc_tab               var3_tab;
  pg_header_char1_tab            var4_tab;
  pg_header_char2_tab            var4_tab;
  pg_header_char3_tab            var4_tab;
  pg_header_char4_tab            var4_tab;
  pg_header_char5_tab            var4_tab;
  pg_header_char6_tab            var4_tab;
  pg_header_char7_tab            var4_tab;
  pg_header_char8_tab            var4_tab;
  pg_header_char9_tab            var4_tab;
  pg_header_char10_tab           var4_tab;
  pg_header_char11_tab           var4_tab;
  pg_header_char12_tab           var4_tab;
  pg_header_char13_tab           var4_tab;
  pg_header_char14_tab           var4_tab;
  pg_header_char15_tab           var4_tab;
  pg_header_numeric1_tab         num1_tab;
  pg_header_numeric2_tab         num1_tab;
  pg_header_numeric3_tab         num1_tab;
  pg_header_numeric4_tab         num1_tab;
  pg_header_numeric5_tab         num1_tab;
  pg_header_numeric6_tab         num1_tab;
  pg_header_numeric7_tab         num1_tab;
  pg_header_numeric8_tab         num1_tab;
  pg_header_numeric9_tab         num1_tab;
  pg_header_numeric10_tab        num1_tab;
  pg_header_date1_tab            date_tab;
  pg_header_date2_tab            date_tab;
  pg_header_date3_tab            date_tab;
  pg_header_date4_tab            date_tab;
  pg_header_date5_tab            date_tab;
  pg_line_char1_tab              var4_tab;
  pg_line_char2_tab              var4_tab;
  pg_line_char3_tab              var4_tab;
  pg_line_char4_tab              var4_tab;
  pg_line_char5_tab              var4_tab;
  pg_line_char6_tab              var4_tab;
  pg_line_char7_tab              var4_tab;
  pg_line_char8_tab              var4_tab;
  pg_line_char9_tab              var4_tab;
  pg_line_char10_tab             var4_tab;
  pg_line_char11_tab             var4_tab;
  pg_line_char12_tab             var4_tab;
  pg_line_char13_tab             var4_tab;
  pg_line_char14_tab             var4_tab;
  pg_line_char15_tab             var4_tab;
  pg_line_numeric1_tab           num1_tab;
  pg_line_numeric2_tab           num1_tab;
  pg_line_numeric3_tab           num1_tab;
  pg_line_numeric4_tab           num1_tab;
  pg_line_numeric5_tab           num1_tab;
  pg_line_numeric6_tab           num1_tab;
  pg_line_numeric7_tab           num1_tab;
  pg_line_numeric8_tab           num1_tab;
  pg_line_numeric9_tab           num1_tab;
  pg_line_numeric10_tab          num1_tab;
  pg_line_date1_tab              date_tab;
  pg_line_date2_tab              date_tab;
  pg_line_date3_tab              date_tab;
  pg_line_date4_tab              date_tab;
  pg_line_date5_tab              date_tab;
  pg_exempt_certi_numb_tab       var2_tab;
  pg_exempt_reason_tab           var3_tab;
  pg_exempt_cont_flag_tab        var2_tab;
  pg_ugraded_inv_flag_tab        var1_tab;

PROCEDURE CALCULATE_TAX_API (
  p_currency_tab     IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
  x_tax_lines_tbl       OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
  x_error_status        OUT NOCOPY VARCHAR2,
  x_messages_tbl        OUT NOCOPY ZX_TAX_PARTNER_PKG.messages_tbl_type)is

  Cursor item_lines_to_be_processed is
     SELECT
  internal_organization_id               ,
  document_type_id                       ,
  transaction_id                         ,
  application_code                       ,
  document_level_action                  ,
  trx_date                               ,
  trx_currency_code                      ,
/* Bug 5090593:
  quote_flag             ,
*/
  legal_entity_number                    ,
  establishment_number                   ,
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
  --applied_from_document_type_id          ,
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
--     WHERE transaction_id = p_trx_id;

  l_api_name             CONSTANT VARCHAR2(30) := 'CALCULATE_TAX_API';
  l_return_status        VARCHAR2(30);
  ptr                    NUMBER;
  l_cnt_of_options_gt    NUMBER;
  l_cnt_of_hdr_extns_gt  NUMBER;
  l_cnt_of_line_extns_gt NUMBER;
  l_cnt_of_loc_info_gt   NUMBER;
  l_cnt_of_ptnr_neg_line_gt NUMBER;
  l_partner_processing_flag  VARCHAR2(80);
  l_record_for_partners_flag VARCHAR2(80);
  l_line_level_action VARCHAR2(80);
  l_inclusive_tax_override_flag VARCHAR2(80);
  l_application_id  NUMBER;
  l_entity_code     VARCHAR2(80);
  l_event_class_code VARCHAR2(100);
  l_trx_level_type   VARCHAR2(100);
  l_trx_id           NUMBER;
  l_org_id           NUMBER;
  l_trx_type_id      NUMBER;
  l_trx_line_id      NUMBER;
  l_tax_code         VARCHAR2(100);
  l_tax_type         VARCHAR2(100);
  l_tax_flag         VARCHAR2(10);
  l_ship_to_location_id NUMBER;
  l_bill_to_location_id NUMBER;
  l_doc_amount       NUMBER;
  l_doc_trx_id       NUMBER;

BEGIN
  x_error_status := FND_API.G_RET_STS_SUCCESS;
  err_count      := 0;
  l_doc_trx_id   := NULL;

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        ' zx_tax_partner_pkg.G_BUSINESS_FLOW = ' || zx_tax_partner_pkg.G_BUSINESS_FLOW);
  END IF;

  IF zx_tax_partner_pkg.G_BUSINESS_FLOW = 'O2C' THEN
    --  Verify the integration with the version of Vertex Q Series product is certified.
    BEGIN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
           'Calling ZX_TAX_VERTEX_REV.GET_RELEASE Verify the integration with the version of Vertex Q Series product is certified');
      END IF;
      ZX_TAX_VERTEX_REV.GET_RELEASE(context_rec,version_rec,l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_exception >= g_current_runtime_level ) THEN
          FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
        END IF;
        x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
        g_string :='Not compaitable to VERTEX Release';
        error_exception_handle(g_string);
        x_messages_tbl:=g_messages_tbl;
        return;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF (g_level_exception >= g_current_runtime_level ) THEN
          FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
        END IF;
        x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
        g_string :='Not compaitable to VERTEX Release failed with exception';
        error_exception_handle(g_string);
        x_messages_tbl:=g_messages_tbl;
        return;
    END;

  ELSE
    --Release 12 Old tax partner integration does not support P2P products;
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         'Release 12 Old tax partner integration does not support P2P products' );
    END IF;
    x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
    g_string :='Release 12 Old tax partner integration does not support P2P products';
    error_exception_handle(g_string);
    x_messages_tbl:=g_messages_tbl;
    return;
  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    BEGIN
      SELECT count(*)
        INTO l_cnt_of_options_gt
        FROM ZX_TRX_PRE_PROC_OPTIONS_GT;
    EXCEPTION WHEN OTHERS THEN
      l_cnt_of_options_gt := 0;
    END;

    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
       'l_cnt_of_options_gt = '||l_cnt_of_options_gt);
  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN

    BEGIN
      SELECT count(*)
        INTO l_cnt_of_options_gt
        FROM ZX_TRX_PRE_PROC_OPTIONS_GT ztppo
           , ZX_LINES_DET_FACTORS zldf
       WHERE ztppo.application_id   = zldf.application_id
         AND ztppo.entity_code      = zldf.entity_code
         AND ztppo.event_class_code = zldf.event_class_code
         AND ztppo.trx_id           = zldf.trx_id;
    EXCEPTION WHEN OTHERS THEN
      l_cnt_of_options_gt := 0;
    END;

    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
       'l_cnt_of_line_det_factors = '||l_cnt_of_options_gt);
  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
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
        FROM ZX_PRVDR_LINE_EXTNS_GT;
    EXCEPTION WHEN OTHERS THEN
      l_cnt_of_line_extns_gt := 0;
    END;
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
              'l_cnt_of_line_extns_gt = '||l_cnt_of_line_extns_gt);

   END IF;
/***
       BEGIN
          SELECT
            distinct application_id,entity_code,event_class_code,
            trx_id,trx_level_type,trx_line_id
            INTO l_application_id,l_entity_code,l_event_class_code,
            l_trx_id,l_trx_level_type,l_trx_line_id
            FROM ZX_PRVDR_LINE_EXTNS_GT where rownum = 1;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'before tax code');
   END IF;
-- bug 6755603

           SELECT
           output_tax_classification_code,receivables_trx_type_id,internal_organization_id, ship_to_location_id,
           bill_to_location_id into
           l_tax_code, l_trx_type_id, l_org_id, l_ship_to_location_id, l_bill_to_location_id
            FROM zx_lines_det_factors where
            application_id = l_application_id
            and entity_code = l_entity_code
            and event_class_code = l_event_class_code
            and trx_id = l_trx_id
            and trx_line_id = l_trx_line_id
            and trx_level_type = l_trx_level_type;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_ship_to_location_id '||l_ship_to_location_id);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_bill_to_location_id '||l_bill_to_location_id);
           END IF;


            BEGIN
             select tax_type_code INTO l_tax_type -- from zx_taxes_b zx, zx_rates_b zr
               from zx_sco_taxes zx,   -- Changed from clause to use sco views not base tables
                    zx_sco_rates zr
           where zx.tax = zr.tax
             AND zx.tax_regime_code = zr.tax_regime_code
             AND zr.tax_rate_code = l_tax_code
             AND zx.live_for_processing_flag = 'Y' --Bug 7594634
             AND rownum = 1;

            EXCEPTION
              WHEN others THEN
               l_tax_type := NULL;
            END;


            IF
            zx_global_structures_pkg.tax_calc_flag_tbl.exists(to_char(l_trx_type_id)) THEN

            l_tax_flag := zx_global_structures_pkg.tax_calc_flag_tbl(to_char(l_trx_type_id));

            ELSE

            SELECT tax_calculation_flag into l_tax_flag
            FROM  ra_cust_trx_types_all rtt
            WHERE rtt.cust_trx_type_id = l_trx_type_id
            AND org_id = l_org_id;

            END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_tax_code'||l_tax_code);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_tax_type_code'||l_tax_type);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Tax calculation flag '||l_tax_flag);
   END IF;
            IF l_tax_flag = 'N' AND l_tax_code is NULL THEN
             RETURN;
            ELSIF l_tax_type NOT IN ('SALES_TAX','LOCATION') THEN
             RETURN;
            ELSIF (l_tax_type = 'SALES_TAX' AND l_tax_code <> 'STATE' and  l_tax_code <> 'COUNTY' and l_tax_code <> 'CITY' and l_tax_code not like '%_COUNTY'
and l_tax_code not like '%_CITY') THEN
             RETURN;
            END IF;


       EXCEPTION WHEN OTHERS THEN
          null;
       END;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_cnt_of_line_extns_gt = '||l_cnt_of_line_extns_gt);
   END IF;
***/

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    BEGIN
       SELECT count(*)
         INTO l_cnt_of_loc_info_gt
         FROM ZX_PTNR_LOCATION_INFO_GT;
    EXCEPTION WHEN OTHERS THEN
       l_cnt_of_loc_info_gt := 0;
    END;
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
       'l_cnt_of_loc_info_gt = '||l_cnt_of_loc_info_gt);
  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    BEGIN
        SELECT count(*)
          INTO l_cnt_of_ptnr_neg_line_gt
          FROM ZX_PTNR_NEG_LINE_GT;
     EXCEPTION WHEN OTHERS THEN
        l_cnt_of_ptnr_neg_line_gt := 0;
     END;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        'l_cnt_of_ptnr_neg_line_gt = '||l_cnt_of_ptnr_neg_line_gt);
  END IF;

  BEGIN
    select record_for_partners_flag,partner_processing_flag
     into  l_record_for_partners_flag,l_partner_processing_flag
     from ZX_TRX_PRE_PROC_OPTIONS_GT
     where rownum=1;
  EXCEPTION WHEN OTHERS THEN
    l_record_for_partners_flag := 'N';
    l_partner_processing_flag  := 'N';
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         'Exp : l_record_for_partners_flag  = '||l_record_for_partners_flag||
         'Exp : l_partner_processing_flag   = '||l_partner_processing_flag);
    END IF;
  END;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
       'l_record_for_partners_flag  = '||l_record_for_partners_flag||
       'l_partner_processing_flag   = '||l_partner_processing_flag);
  END IF;

       BEGIN
         select zldf.line_level_action,zldf.inclusive_tax_override_flag
           into l_line_level_action, l_inclusive_tax_override_flag
         FROM ZX_TRX_PRE_PROC_OPTIONS_GT ztppo
               , ZX_LINES_DET_FACTORS zldf
           WHERE ztppo.application_id   = zldf.application_id
             AND ztppo.entity_code      = zldf.entity_code
             AND ztppo.event_class_code = zldf.event_class_code
             AND ztppo.trx_id           = zldf.trx_id;
  EXCEPTION WHEN OTHERS THEN
           l_line_level_action := 'N';
           l_inclusive_tax_override_flag  := 'N';
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'Exp : l_line_level_action =' ||l_line_level_action
             ||'Exp : l_inclusive_tax_override_flag '|| l_inclusive_tax_override_flag);
   END IF;
        END;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               ' l_line_level_action =' ||l_line_level_action
             ||' l_inclusive_tax_override_flag '|| l_inclusive_tax_override_flag);
    END IF;
    --END IF;

    open item_lines_to_be_processed ;
    fetch item_lines_to_be_processed
     bulk collect into
    pg_internal_org_id_tab    ,
    pg_doc_type_id_tab    ,
    pg_trx_id_tab      ,
    pg_appli_code_tab    ,
    pg_doc_level_action_tab    ,
    pg_trx_date_tab      ,
    pg_trx_curr_code_tab    ,
/* Bug 5090593:
    pg_quote_flag_tab    ,
*/
    pg_legal_entity_num_tab    ,
    pg_esta_name_tab    ,
    pg_trx_number_tab    ,
    pg_trx_desc_tab      ,
    pg_doc_sequence_value_tab  ,
    pg_trx_due_date_tab    ,
/* Bug 5090593:
    pg_trx_sol_ori_tab    ,
*/
    pg_allow_tax_calc_tab    ,
    pg_trx_line_id_tab    ,
    pg_trx_level_type_tab    ,
    pg_line_level_action_tab  ,
    pg_line_class_tab    ,
    pg_trx_shipping_date_tab  ,
    pg_trx_receipt_date_tab    ,
    pg_trx_line_type_tab    ,
    pg_trx_line_date_tab    ,
    pg_trx_business_cat_tab    ,
    pg_line_intended_use_tab  ,
    pg_line_amt_incl_tax_flag_tab  ,
    pg_line_amount_tab    ,
    pg_other_incl_tax_amt_tab  ,
    pg_trx_line_qty_tab    ,
    pg_unit_price_tab    ,
    pg_cash_discount_tab    ,
    pg_volume_discount_tab    ,
    pg_trading_discount_tab    ,
    pg_trans_charge_tab    ,
    pg_ins_charge_tab    ,
    pg_other_charge_tab    ,
    pg_prod_id_tab      ,
    pg_uom_code_tab      ,
    pg_prod_type_tab    ,
    pg_prod_code_tab    ,
    pg_fob_point_tab    ,
    pg_ship_to_pty_numr_tab    ,
    pg_ship_to_pty_name_tab    ,
    pg_ship_from_pty_num_tab  ,
    pg_ship_from_pty_name_tab  ,
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
    pg_bill_to_pty_num_tab    ,
    pg_bill_to_pty_name_tab    ,
    pg_bill_from_pty_num_tab  ,
    pg_bill_from_pty_name_tab  ,
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
    pg_account_ccid_tab    ,
    --pg_appl_fr_doc_type_id_tab  ,
    pg_appl_from_trx_id_tab    ,
    pg_appl_from_line_id_tab  ,
    pg_appl_fr_trx_lev_type_tab  ,
    pg_appl_from_doc_num_tab  ,
    pg_adj_doc_doc_type_id_tab  ,
    pg_adj_doc_trx_id_tab    ,
    pg_adj_doc_line_id_tab    ,
    pg_adj_doc_number_tab    ,
    pg_adj_doc_trx_lev_type_tab  ,
    pg_adj_doc_date_tab    ,
    pg_assess_value_tab    ,
    pg_trx_line_number_tab    ,
    pg_trx_line_desc_tab    ,
    pg_prod_desc_tab    ,
    pg_header_char1_tab    ,
    pg_header_char2_tab    ,
    pg_header_char3_tab    ,
    pg_header_char4_tab    ,
    pg_header_char5_tab    ,
    pg_header_char6_tab    ,
    pg_header_char7_tab    ,
    pg_header_char8_tab    ,
    pg_header_char9_tab    ,
    pg_header_char10_tab    ,
    pg_header_char11_tab    ,
    pg_header_char12_tab    ,
    pg_header_char13_tab    ,
    pg_header_char14_tab    ,
    pg_header_char15_tab    ,
    pg_header_numeric1_tab    ,
    pg_header_numeric2_tab    ,
    pg_header_numeric3_tab    ,
    pg_header_numeric4_tab    ,
    pg_header_numeric5_tab    ,
    pg_header_numeric6_tab    ,
    pg_header_numeric7_tab    ,
    pg_header_numeric8_tab    ,
    pg_header_numeric9_tab    ,
    pg_header_numeric10_tab    ,
    pg_header_date1_tab    ,
    pg_header_date2_tab    ,
    pg_header_date3_tab    ,
    pg_header_date4_tab    ,
    pg_header_date5_tab    ,
    pg_line_char1_tab    ,
    pg_line_char2_tab    ,
    pg_line_char3_tab    ,
    pg_line_char4_tab    ,
    pg_line_char5_tab    ,
    pg_line_char6_tab    ,
    pg_line_char7_tab    ,
    pg_line_char8_tab    ,
    pg_line_char9_tab    ,
    pg_line_char10_tab    ,
    pg_line_char11_tab    ,
    pg_line_char12_tab    ,
    pg_line_char13_tab    ,
    pg_line_char14_tab    ,
    pg_line_char15_tab    ,
    pg_line_numeric1_tab    ,
    pg_line_numeric2_tab    ,
    pg_line_numeric3_tab    ,
    pg_line_numeric4_tab    ,
    pg_line_numeric5_tab    ,
    pg_line_numeric6_tab    ,
    pg_line_numeric7_tab    ,
    pg_line_numeric8_tab    ,
    pg_line_numeric9_tab    ,
    pg_line_numeric10_tab    ,
    pg_line_date1_tab    ,
    pg_line_date2_tab    ,
    pg_line_date3_tab    ,
    pg_line_date4_tab    ,
    pg_line_date5_tab    ,
    pg_exempt_certi_numb_tab  ,
    pg_exempt_reason_tab    ,
    pg_exempt_cont_flag_tab
   limit C_LINES_PER_COMMIT;/*Need to limit the fetch*/

    IF (nvl(pg_trx_id_tab.last,0) = 0) Then
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
     'No item lines exist to whom tax lines need to be created' );
         END IF;
          -- x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- g_string :='Not compaitable to VERTEX Release';
    -- error_exception_handle(g_string);
    -- x_messages_tbl:=g_messages_tbl;
     return;

    ELSE /*The view has returned some rows that can be processed below */

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         ' Records in ZX_O2C_CALC_TXN_INPUT_V = '||pg_trx_id_tab.last);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
  'pg_doc_type_id_tab(1) :' ||pg_doc_type_id_tab(1));
        END IF;

        IF(pg_doc_type_id_tab(1)<>0) then
           Begin
             select  event_class_code
             into    l_document_type
       from    zx_evnt_cls_mappings
       where   event_class_mapping_id = pg_doc_type_id_tab(1);
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


       For ptr in 1..nvl(pg_trx_id_tab.last, 0) loop

         I:=ptr;
       -- In case of partners, since there are two calls to get_tax_jurisdictions API
       -- we need to delete from zx_jurisdictions_gt before each of the calls to
       -- get_tax_jurisdictions API
       --  IF pg_trx_line_id_tab(i) <> g_transaction_line_id THEN
       --    delete from zx_jurisdictions_gt;
       --  END IF;
   g_transaction_line_id  :=  pg_trx_line_id_tab(i);
          g_trx_level_type  :=  pg_trx_level_type_tab(i);
   g_docment_type_id  :=  pg_doc_type_id_tab(i);
   g_trasaction_id  :=  pg_trx_id_tab(i);
   g_tax_regime_code  :=  zx_tax_partner_pkg.g_tax_regime_code;

   pg_ugraded_inv_flag_tab(I) := 'N';

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         ' Value of Variable I is :'||I);
       END IF;

/* Performing validation of passed document level,line level actions */
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         ' pg_ship_to_loc_id_tab is : '||pg_ship_to_loc_id_tab(i));
       END IF;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         ' pg_bill_to_loc_id_tab is : '||pg_bill_to_loc_id_tab(i));
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
     return;
        END IF;

    IF l_doc_trx_id IS NULL or l_doc_trx_id <> pg_trx_id_tab(I) THEN
      l_doc_trx_id := pg_trx_id_tab(I);

      SELECT SUM(ABS(line_amount))
        INTO l_doc_amount
        FROM ZX_O2C_CALC_TXN_INPUT_V
       WHERE transaction_id = l_doc_trx_id;

      SET_DOCUMENT_TYPE(l_document_type,pg_adj_doc_trx_id_tab(I),l_doc_amount,pg_line_level_action_tab(I),l_return_status);
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_exception >= g_current_runtime_level ) THEN
          FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
        END IF;
        x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
        g_string :='Failed in setting up document type';
        error_exception_handle(g_string);
        x_messages_tbl:=g_messages_tbl;
        return;
      END IF;
    END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                  ' Document Type : '||l_document_type );
   END IF;

   IF (pg_doc_level_action_tab(i) in ('CREATE', 'QUOTE')) THEN
      IF (l_document_type in ('TAX_ONLY_CREDIT_MEMO', 'TAX_ONLY_ADJUSTMENT',
                                   'TAX_ONLY_INVOICE', 'INVOICE_ADJUSTMENT')) THEN
         RETURN;
      ELSE
         Perform_line_creation(x_tax_lines_tbl,p_currency_tab,l_return_status);
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

   ELSIF (pg_doc_level_action_tab(i) = 'UPDATE') then

      IF (l_document_type in ('TAX_ONLY_CREDIT_MEMO', 'TAX_ONLY_INVOICE')) THEN
         RETURN;
      END IF;
      Perform_update(x_tax_lines_tbl,p_currency_tab,l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF (g_level_exception >= g_current_runtime_level ) THEN
            FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
         x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
         g_string :='Failed in creating update';
         error_exception_handle(g_string);
         x_messages_tbl:=g_messages_tbl;
         return;
      END IF;

      BEGIN
         DELETE FROM zx_ptnr_neg_line_gt
         WHERE  event_class_mapping_id = pg_doc_type_id_tab(I) and
                trx_id                 = pg_trx_id_tab(I) and
                trx_line_id            = pg_trx_line_id_tab(I) and
                trx_level_type         = pg_trx_level_type_tab(I);
      EXCEPTION
         WHEN no_data_found THEN
            null;
      END;
   ELSE
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                  ' Unknown header level action' );
            END IF;
       x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
       g_string :=' Unknown header  level action';
       error_exception_handle(g_string);
       x_messages_tbl:=g_messages_tbl;
       return;
         End if;
       end loop;
     end if;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;

     Exception
      when others then
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,
                          G_MODULE_NAME||l_api_name,
                           sqlerrm);
        END IF;
         x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_string :='Not compaitable to VERTEX Release';
     error_exception_handle(g_string);
     x_messages_tbl:=g_messages_tbl;
     return;


END CALCULATE_TAX_API;

PROCEDURE SET_DOCUMENT_TYPE( P_DOCUMENT_TYPE  IN OUT NOCOPY VARCHAR2,
           P_ADJ_DOC_TRX_ID IN NUMBER,
           P_LINE_AMOUNT    IN NUMBER,
           p_LINE_LEVEL_ACTION IN VARCHAR2,
           x_return_status  OUT NOCOPY VARCHAR2)IS
l_api_name           CONSTANT VARCHAR2(30) := 'SET_DOCUMENT_TYPE';
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'P_DOCUMENT_TYPE : '||P_DOCUMENT_TYPE );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'P_ADJ_DOC_TRX_ID : '||P_ADJ_DOC_TRX_ID );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'P_LINE_LEVEL_ACTION : '||p_line_level_action );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'P_LINE_AMOUNT : '||P_LINE_AMOUNT );
   END IF;

   IF (p_document_type = 'CREDIT_MEMO') THEN
      IF (p_adj_doc_trx_id is not null) THEN
         IF p_line_amount = 0 THEN
            p_document_type :='TAX_ONLY_CREDIT_MEMO';
         ELSIF p_line_level_action = 'RECORD_WITH_NO_TAX' THEN
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
      IF (p_line_amount = 0 AND p_line_level_action = 'LINE_INFO_TAX_ONLY') THEN
         p_document_type :='TAX_ONLY_INVOICE';
      END IF;
   END IF;/*INVOICE*/

   IF (p_document_type = 'INVOICE_ADJUSTMENT') THEN
      IF (p_line_amount = 0) THEN
         p_document_type := 'TAX_ONLY_ADJUSTMENT';
      END IF;
   END IF;     /*INVOICE_ADJUSTMENT*/

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

End SET_DOCUMENT_TYPE;

PROCEDURE PERFORM_VALIDATE(x_return_status OUT NOCOPY VARCHAR2) is
l_api_name           CONSTANT VARCHAR2(30) := 'PERFORM_VALIDATE';

Begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
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
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    end if;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;
End PERFORM_VALIDATE;

PROCEDURE PERFORM_LINE_CREATION(p_tax_lines_tbl  IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
        p_currency_tab   IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
        x_return_status     OUT NOCOPY VARCHAR2)is

l_api_name           CONSTANT VARCHAR2(30) := 'PERFORM_LINE_CREATION';
l_return_status               VARCHAR2(30);
Begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Value of Variable I is'|| I );
   END IF;

   reset_parameters(l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_string :='Failed in RESET_PARAMETERS procedure';
     error_exception_handle(g_string);
     return;
   END IF;

   l_line_level_action := 'CREATE';
   set_parameters(l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_string :='Failed in SET_PRAMETERS procedure';
     error_exception_handle(g_string);
     return;
   END IF;

   calculate_tax(l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_string :='Failed in CALCULATE_TAX Procedure ';
     error_exception_handle(g_string);
     return;
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME,
        'pg_line_level_action_tab(i)  : '|| pg_line_level_action_tab(i));
   END IF;

   IF (pg_line_level_action_tab(i)<>'QUOTE') THEN
      write_to_vertex_repository(l_return_status);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_string :='Failed in WRITE_TO_VERTEX_REPOSITORY Procedure ';
     error_exception_handle(g_string);
     return;
      END IF;
   END IF;

/*Vertex returned values need to be written back to zx_repository.*/
   tax_results_processing(p_tax_lines_tbl,p_currency_tab,l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_string :='Failed in TAX_RESULTS_PROCESSING procedure';
     error_exception_handle(g_string);
     return;
   END IF;


   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

End PERFORM_LINE_CREATION;

PROCEDURE PERFORM_LINE_DELETION(x_return_status OUT NOCOPY VARCHAR2) is
 l_api_name           CONSTANT VARCHAR2(30) := 'PERFORM_LINE_DELETION';
 l_return_status               VARCHAR2(30);
Begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;
       /*ZX_VTX_USER_PKG.g_line_negation := TRUE;
       ZX_VTX_USER_PKG.g_trx_line_id := pg_trx_line_id_tab(I);*/

      reset_parameters(l_return_status);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_string :='Failed in RESET_PARAMETERS Procedure';
     error_exception_handle(g_string);
     return;
   END IF;
       set_parameters(l_return_status);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_string :='Failed in SET_PARAMETERS procedure';
     error_exception_handle(g_string);
     return;
   END IF;
       calculate_tax(l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_string :='Failed in CALCULATE_TAX procedure';
     error_exception_handle(g_string);
     return;
   END IF;
    write_to_vertex_repository(l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_string :='Failed in WRITE_TO_VERTEX_REPOSITORY procedure';
     error_exception_handle(g_string);
     return;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;
End PERFORM_LINE_DELETION;


PROCEDURE PERFORM_UPDATE       (p_tax_lines_tbl  IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
        p_currency_tab   IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
        x_return_status     OUT NOCOPY VARCHAR2) is
l_api_name           CONSTANT VARCHAR2(30) := 'PERFORM_UPDATE';
l_return_status               VARCHAR2(30);
l_application_id              NUMBER;
l_ver_count                   NUMBER(10);
Begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'PG_LINE_LEVEL_ACTION_TAB(i)'||pg_line_level_action_tab(i) );
   END IF;

      if (pg_line_level_action_tab(i) in ('CREATE','QUOTE')) Then

         l_line_level_action := 'CREATE';
             perform_line_creation(p_tax_lines_tbl,p_currency_tab,l_return_status);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    g_string :='Failed in PERFORM_LINE_CREATION procedure';
    error_exception_handle(g_string);
    return;
     END IF;

  elsif(pg_line_level_action_tab(i) in ('UPDATE')) Then
           /*First make contra entry*/
    BEGIN
      SELECT APPLICATION_ID
        INTO l_application_id
        FROM ZX_PRVDR_LINE_EXTNS_GT
       WHERE ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_application_id := NULL;
    END;
    IF l_application_id IS NOT NULL THEN
      BEGIN
        SELECT Count(*)
          INTO l_ver_count
          FROM ZX_LINES
         WHERE APPLICATION_ID = l_application_id
           AND TRX_ID = pg_trx_id_tab(I)
           AND TRX_LINE_ID = pg_trx_line_id_tab(I)
           AND TAX_PROVIDER_ID IS NOT NULL;
      EXCEPTION
        WHEN OTHERS THEN
          l_ver_count := 0;
      END;
    END IF;
    IF l_ver_count <> 0 THEN
        l_line_level_action := 'NEGATE';
  perform_line_deletion(l_return_status);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    g_string :='Failed in PERFORM_LINE_DELETION procedure';
    error_exception_handle(g_string);
    return;
  END IF;
     END IF;
    /*For new line*/
     --  l_line_level_action := 'CREATE';
     perform_line_creation(p_tax_lines_tbl,p_currency_tab,l_return_status);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,SQLERRM);
  END IF;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  g_string :='Failed in PERFORM_LINE_CREATION procedure';
  error_exception_handle(g_string);
  return;
     END IF;

      elsif(pg_line_level_action_tab(i) in ('DELETE','CANCEL')) Then
          l_line_level_action := pg_line_level_action_tab(i);
          perform_line_deletion(l_return_status);
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    g_string :='Failed in PERFORM_LINE_DELETION procedure';
    error_exception_handle(g_string);
    return;
     END IF;
        else
             Null;/*Need to add for  SYNCHRONIZE */
      end if;/*Line level operation*/

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;

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
                       p_regime_code         ,
            p_inv_date                  ,
            x_tax_jurisdiction_rec         ,
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
            FROM (
            SELECT tax_jurisdiction_code
              FROM zx_jurisdictions_gt
             WHERE tax_regime_code = p_regime_code
               AND tax = p_tax
               AND substr(tax_jurisdiction_code, 4) BETWEEN '000000000' and '999999999'
               AND precedence_level = (SELECT max(precedence_level)
                                         FROM zx_jurisdictions_gt
                                        WHERE tax_regime_code = p_regime_code
                                          AND   substr(tax_jurisdiction_code, 4) BETWEEN '000000000' and '999999999'
                                          AND tax = p_tax)
            ORDER BY tax_jurisdiction_code)
            WHERE rownum = 1 ;
         END;
      END IF;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END GET_TAX_JUR_CODE;


PROCEDURE SET_PARAMETERS(x_return_status OUT NOCOPY VARCHAR2) IS

 /*Following variables used during line deletion process.*/
  arp_line_amount     ZX_PTNR_NEG_LINE_GT.line_amt%type;
  arp_quantity        ZX_PTNR_NEG_LINE_GT.trx_line_quantity%type;
  arp_trx_id      ZX_PTNR_NEG_LINE_GT.trx_id%type;
  arp_trx_number      ZX_PTNR_NEG_LINE_GT.trx_number%type;
  arp_trx_date      ZX_PTNR_NEG_LINE_GT.trx_date%type;
  arp_exemption_control_flag   ZX_PTNR_NEG_LINE_GT.exemption_control_flag%type;
  arp_ship_to_grphy_type1        VARCHAR2(30);
  arp_ship_to_grphy_value1      VARCHAR2(30);
  arp_ship_to_grphy_type2             VARCHAR2(30);
  arp_ship_to_grphy_value2            VARCHAR2(30);
  arp_ship_to_grphy_type3             VARCHAR2(30);
  arp_ship_to_grphy_value3            VARCHAR2(30);
  arp_ship_to_grphy_type4             VARCHAR2(30);
  arp_ship_to_grphy_value4            VARCHAR2(30);
  arp_ship_to_grphy_type5             VARCHAR2(30);
  arp_ship_to_grphy_value5            VARCHAR2(30);
  arp_ship_to_grphy_type6             VARCHAR2(30);
  arp_ship_to_grphy_value6            VARCHAR2(30);
  arp_ship_to_grphy_type7             VARCHAR2(30);
  arp_ship_to_grphy_value7            VARCHAR2(30);
  arp_ship_to_grphy_type8             VARCHAR2(30);
  arp_ship_to_grphy_value8            VARCHAR2(30);
  arp_ship_to_grphy_type9             VARCHAR2(30);
  arp_ship_to_grphy_value9            VARCHAR2(30);
  arp_ship_to_grphy_type10            VARCHAR2(30);
  arp_ship_to_grphy_value10           VARCHAR2(30);
  arp_ship_from_grphy_type1           VARCHAR2(30);
  arp_ship_from_grphy_value1          VARCHAR2(30);
  arp_ship_from_grphy_type2           VARCHAR2(30);
  arp_ship_from_grphy_value2          VARCHAR2(30);
  arp_ship_from_grphy_type3           VARCHAR2(30);
  arp_ship_from_grphy_value3          VARCHAR2(30);
  arp_ship_from_grphy_type4           VARCHAR2(30);
  arp_ship_from_grphy_value4          VARCHAR2(30);
  arp_ship_from_grphy_type5           VARCHAR2(30);
  arp_ship_from_grphy_value5          VARCHAR2(30);
  arp_ship_from_grphy_type6           VARCHAR2(30);
  arp_ship_from_grphy_value6          VARCHAR2(30);
  arp_ship_from_grphy_type7           VARCHAR2(30);
  arp_ship_from_grphy_value7          VARCHAR2(30);
  arp_ship_from_grphy_type8           VARCHAR2(30);
  arp_ship_from_grphy_value8          VARCHAR2(30);
  arp_ship_from_grphy_type9           VARCHAR2(30);
  arp_ship_from_grphy_value9          VARCHAR2(30);
  arp_ship_from_grphy_type10          VARCHAR2(30);
  arp_ship_from_grphy_value10         VARCHAR2(30);
  /*arp_poa_grphy_type1                 VARCHAR2(30);
  arp_poa_grphy_value1                VARCHAR2(30);
  arp_poa_grphy_type2                 VARCHAR2(30);
  arp_poa_grphy_value2                VARCHAR2(30);
  arp_poa_grphy_type3                 VARCHAR2(30);
  arp_poa_grphy_value3                VARCHAR2(30);
  arp_poa_grphy_type4                 VARCHAR2(30);
  arp_poa_grphy_value4                VARCHAR2(30);
  arp_poa_grphy_type5                 VARCHAR2(30);
  arp_poa_grphy_value5                VARCHAR2(30);
  arp_poa_grphy_type6                 VARCHAR2(30);
  arp_poa_grphy_value6                VARCHAR2(30);
  arp_poa_grphy_type7                 VARCHAR2(30);
  arp_poa_grphy_value7                VARCHAR2(30);
  arp_poa_grphy_type8                 VARCHAR2(30);
  arp_poa_grphy_value8                VARCHAR2(30);
  arp_poa_grphy_type9                 VARCHAR2(30);
  arp_poa_grphy_value9                VARCHAR2(30);
  arp_poa_grphy_type10                VARCHAR2(30);
  arp_poa_grphy_value10               VARCHAR2(30);
  arp_poo_grphy_type1                 VARCHAR2(30);
  arp_poo_grphy_value1                VARCHAR2(30);
  arp_poo_grphy_type2                 VARCHAR2(30);
  arp_poo_grphy_value2                VARCHAR2(30);
  arp_poo_grphy_type3                 VARCHAR2(30);
  arp_poo_grphy_value3                VARCHAR2(30);
  arp_poo_grphy_type4                 VARCHAR2(30);
  arp_poo_grphy_value4                VARCHAR2(30);
  arp_poo_grphy_type5                 VARCHAR2(30);
  arp_poo_grphy_value5                VARCHAR2(30);
  arp_poo_grphy_type6                 VARCHAR2(30);
  arp_poo_grphy_value6                VARCHAR2(30);
  arp_poo_grphy_type7                 VARCHAR2(30);
  arp_poo_grphy_value7                VARCHAR2(30);
  arp_poo_grphy_type8                 VARCHAR2(30);
  arp_poo_grphy_type9                 VARCHAR2(30);
  arp_poo_grphy_value9                VARCHAR2(30);
  arp_poo_grphy_type10                VARCHAR2(30);
  arp_poo_grphy_value10               VARCHAR2(30);*/
  arp_bill_to_grphy_type1             VARCHAR2(30);
  arp_bill_to_grphy_value1            VARCHAR2(30);
  arp_bill_to_grphy_type2             VARCHAR2(30);
  arp_bill_to_grphy_value2            VARCHAR2(30);
  arp_bill_to_grphy_type3             VARCHAR2(30);
  arp_bill_to_grphy_value3            VARCHAR2(30);
  arp_bill_to_grphy_type4             VARCHAR2(30);
  arp_bill_to_grphy_value4            VARCHAR2(30);
  arp_bill_to_grphy_type5             VARCHAR2(30);
  arp_bill_to_grphy_value5            VARCHAR2(30);
  arp_bill_to_grphy_type6             VARCHAR2(30);
  arp_bill_to_grphy_value6            VARCHAR2(30);
  arp_bill_to_grphy_type7             VARCHAR2(30);
  arp_bill_to_grphy_value7            VARCHAR2(30);
  arp_bill_to_grphy_type8             VARCHAR2(30);
  arp_bill_to_grphy_value8            VARCHAR2(30);
  arp_bill_to_grphy_type9             VARCHAR2(30);
  arp_bill_to_grphy_value9            VARCHAR2(30);
  arp_bill_to_grphy_type10            VARCHAR2(30);
  arp_bill_to_grphy_value10           VARCHAR2(30);
  arp_bill_from_grphy_type1           VARCHAR2(30);
  arp_bill_from_grphy_value1          VARCHAR2(30);
  arp_bill_from_grphy_type2           VARCHAR2(30);
  arp_bill_from_grphy_value2          VARCHAR2(30);
  arp_bill_from_grphy_type3           VARCHAR2(30);
  arp_bill_from_grphy_value3          VARCHAR2(30);
  arp_bill_from_grphy_type4           VARCHAR2(30);
  arp_bill_from_grphy_value4          VARCHAR2(30);
  arp_bill_from_grphy_type5           VARCHAR2(30);
  arp_bill_from_grphy_value5          VARCHAR2(30);
  arp_bill_from_grphy_type6           VARCHAR2(30);
  arp_bill_from_grphy_value6          VARCHAR2(30);
  arp_bill_from_grphy_type7           VARCHAR2(30);
  arp_bill_from_grphy_value7          VARCHAR2(30);
  arp_bill_from_grphy_type8           VARCHAR2(30);
  arp_bill_from_grphy_value8          VARCHAR2(30);
  arp_bill_from_grphy_type9           VARCHAR2(30);
  arp_bill_from_grphy_value9          VARCHAR2(30);
  arp_bill_from_grphy_type10          VARCHAR2(30);
  arp_bill_from_grphy_value10         VARCHAR2(30);
  arp_trx_line_type        VARCHAR2(30);
  arp_product_code        VARCHAR2(32);
  arp_cert_num          VARCHAR2(30);
  arp_state_exempt_reason        VARCHAR2(30);
  arp_county_exempt_reason       VARCHAR2(30);
  arp_city_exempt_reason        VARCHAR2(30);
  arp_district_exempt_rs        VARCHAR2(30);
  arp_audit_flag          VARCHAR2(30);
  arp_ship_to_add          VARCHAR2(30);
  arp_ship_from_add        VARCHAR2(30);
  arp_poa_add_code        VARCHAR2(30);
  arp_customer_code        VARCHAR2(30);
  arp_customer_class        VARCHAR2(30);
  arp_company_code        VARCHAR2(30);
  arp_division_code        VARCHAR2(30);
  arp_state_exempt_percent      NUMBER;
  arp_county_exempt_pct        NUMBER;
  arp_city_exempt_pct          NUMBER;
  arp_district_exempt_pct        NUMBER;
  arp_transaction_date        DATE;
  arp_adjusted_doc_date        DATE;

  l_location_info_rec location_info_rec_type;
  l_api_name           CONSTANT VARCHAR2(30) := 'SET_PARAMETERS';
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'L_LINE_LEVEL_ACTION :'||l_line_level_action);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Value of I is :'||I);
   END IF;

   IF (l_line_level_action IN ('CREATE','DELETE','CANCEL')) THEN
      IF substrb(nvl(pg_Line_char10_tab(I),'XXXXXXXXX'), 2,9)='XXXXXXXXX' THEN
         inv_in_rec.fJurisSFGeoCd := null;
    inv_in_rec.fJurisSFInCi  := null;
      ELSE
         inv_in_rec.fJurisSFGeoCd  := to_number(substrb(pg_Line_char10_tab(I), 2, 9));
    inv_in_rec.fJurisSFInCi        := case substrb(pg_Line_char10_tab(I), 1, 1)
                                           when 'X'  then NULL
                    when '1'  then TRUE
             when '0'  then FALSE
             else  NULL
             end ;
      END IF;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fJurisSFGeoCd : '||to_char(inv_in_rec.fJurisSFGeoCd) );
         -- FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fJurisSFInCi :'||inv_in_rec.fJurisSFInCi );
      END IF;

      IF substrb(nvl(pg_Line_char9_tab(I),'XXXXXXXXX'), 2,9)='XXXXXXXXX' THEN
         inv_in_rec.fJurisSTGeoCd := null;
      ELSE
         inv_in_rec.fJurisSTGeoCd := to_number(substrb(pg_Line_char9_tab(I), 2, 9));
      END IF;
      inv_in_rec.fJurisSTInCi  := case substrb(pg_Line_char9_tab(I), 1, 1)
                                    when 'X'  then NULL
                                    when '1'  then TRUE
                                    when '0'  then FALSE
                                    else  NULL
                                  end ;

      IF substrb(nvl(pg_Line_char11_tab(I),'XXXXXXXXX'), 2,9)='XXXXXXXXX' THEN
         inv_in_rec.fJurisOAGeoCd := null;
         inv_in_rec.fJurisOAInCi  := null;
      ELSE
  inv_in_rec.fJurisOAGeoCd  := to_number(substrb(pg_Line_char11_tab(I), 2, 9));
  inv_in_rec.fJurisOAInCi         := case substrb(pg_Line_char11_tab(I), 1, 1)
                                                  when 'X'  then NULL
              when '1'  then TRUE
              when '0'  then FALSE
              else  NULL
              end ;
      END IF;
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fJurisOAGeoCd : '||to_char(inv_in_rec.fJurisOAGeoCd ));
  -- FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fJurisOAInCi :'||inv_in_rec.fJurisOAInCi);
    END IF;

   IF (l_line_level_action IN ('CREATE', 'DELETE')) THEN
      inv_in_rec.fTDMCustCd := pg_Line_char12_tab(I);
   ELSE
      /*
      BEGIN
         SELECT pty.party_number
           INTO inv_in_rec.fTDMCustCd
           FROM hz_parties pty,
                zx_party_tax_profile ptp
          WHERE ptp.party_tax_profile_id = bill_to_party_tax_id_tab(i)
            AND ptp.party_id = pty.party_id;
      EXCEPTION WHEN OTHERS THEN
         inv_in_rec.fTDMCustCd := NULL;
      END;
      */
      null;
   END IF;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fTDMCustCd : '||inv_in_rec.fTDMCustCd );
   END IF;

   inv_in_rec.fTDMCustClassCd  := pg_Line_char13_tab(I);
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fTDMCustClassCd :'||inv_in_rec.fTDMCustClassCd );
   END IF;

   inv_in_rec.fTDMCompCd    := pg_Line_char14_tab(I);
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fTDMCompCd :'||inv_in_rec.fTDMCompCd );
   END IF;

   inv_in_rec.fInvIdNum    := pg_trx_number_tab(I);
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fInvIdNum :'||inv_in_rec.fInvIdNum );
   END IF;

   inv_in_rec.fTDMDivCd    := pg_Line_char15_tab(I);
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fTDMDivCd :'||inv_in_rec.fTDMDivCd );
   END IF;

   /*-----------------------------------------------------------
    | The transaction type identifies the type of transaction  |
    | being processed.           |
    -----------------------------------------------------------*/
   IF pg_Line_char1_tab(I) = 'PURCHASE' THEN
           line_in_tab(1).fTransType := ZX_TAX_VERTEX_QSU.cQSUTransTypePurchase;
   ELSIF pg_Line_char1_tab(I) = 'RENTAL' THEN
              line_in_tab(1).fTransType := ZX_TAX_VERTEX_QSU.cQSUTransTypeRentLease;
   ELSIF pg_Line_char1_tab(I) = 'LEASE' THEN
              line_in_tab(1).fTransType := ZX_TAX_VERTEX_QSU.cQSUTransTypeRentLease;
   ELSIF pg_Line_char1_tab(I) = 'SALE' THEN
              line_in_tab(1).fTransType := ZX_TAX_VERTEX_QSU.cQSUTransTypeSale;
   ELSIF pg_Line_char1_tab(I) = 'SERVICE' THEN
              line_in_tab(1).fTransType := ZX_TAX_VERTEX_QSU.cQSUTransTypeService;
   END IF;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'line_in_tab(1).fTransType :'||to_char(line_in_tab(1).fTransType));
   END IF;

   line_in_tab(1).fTransDate    := pg_line_date1_tab(i);
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'line_in_tab(1).fTransDate : '||to_char(line_in_tab(1).fTransDate));
   END IF;

   line_in_tab(1).fTransUserArea  := to_char(pg_Trx_id_tab(I));
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'line_in_tab(1).fTransUserArea :'||line_in_tab(1).fTransUserArea );
   END IF;

   line_in_tab(1).fTDMProdCd  := pg_Line_char2_tab(I);
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'line_in_tab(1).fTDMProdCd   :'  ||line_in_tab(1).fTDMProdCd );
   END IF;



   ELSE /*Line level action is delete*/
     SELECT line_amt,
           trx_line_quantity,
           trx_id,
           trx_number,
           ship_to_geography_type1,
           ship_to_geography_value1,
           ship_to_geography_type2,
           ship_to_geography_value2,
           ship_to_geography_type3,
           ship_to_geography_value3,
           ship_to_geography_type4,
           ship_to_geography_value4,
           ship_to_geography_type5,
           ship_to_geography_value5,
           ship_to_geography_type6,
           ship_to_geography_value6,
           ship_to_geography_type7,
           ship_to_geography_value7,
           ship_to_geography_type8,
           ship_to_geography_value8,
           ship_to_geography_type9,
           ship_to_geography_value9,
           ship_to_geography_type10,
           ship_to_geography_value10,
           ship_from_geography_type1,
           ship_from_geography_value1,
           ship_from_geography_type2,
           ship_from_geography_value2,
           ship_from_geography_type3,
           ship_from_geography_value3,
           ship_from_geography_type4,
           ship_from_geography_value4,
           ship_from_geography_type5,
           ship_from_geography_value5,
           ship_from_geography_type6,
           ship_from_geography_value6,
           ship_from_geography_type7,
           ship_from_geography_value7,
           ship_from_geography_type8,
           ship_from_geography_value8,
           ship_from_geography_type9,
           ship_from_geography_value9,
           ship_from_geography_type10,
           ship_from_geography_value10,
           /*poa_geography_type1,
           poa_geography_value1,
           poa_geography_type2,
           poa_geography_value2,
           poa_geography_type3,
           poa_geography_value3,
           poa_geography_type4,
           poa_geography_value4,
           poa_geography_type5,
           poa_geography_value5,
           poa_geography_type6,
           poa_geography_value6,
           poa_geography_type7,
           poa_geography_value7,
           poa_geography_type8,
           poa_geography_value8,
           poa_geography_type9,
           poa_geography_value9,
           poa_geography_type10,
           poa_geography_value10,
           poo_geography_type1,
           poo_geography_value1,
           poo_geography_type2,
           poo_geography_value2,
           poo_geography_type3,
           poo_geography_value3,
           poo_geography_type4,
           poo_geography_value4,
           poo_geography_type5,
           poo_geography_value5,
           poo_geography_type6,
           poo_geography_value6,
           poo_geography_type7,
           poo_geography_value7,
           poo_geography_type8,
           poo_geography_type9,
           poo_geography_value9,
           poo_geography_type10,
           poo_geography_value10,*/
           bill_to_geography_type1,
           bill_to_geography_value1,
           bill_to_geography_type2,
           bill_to_geography_value2,
           bill_to_geography_type3,
           bill_to_geography_value3,
           bill_to_geography_type4,
           bill_to_geography_value4,
           bill_to_geography_type5,
           bill_to_geography_value5,
           bill_to_geography_type6,
           bill_to_geography_value6,
           bill_to_geography_type7,
           bill_to_geography_value7,
           bill_to_geography_type8,
           bill_to_geography_value8,
           bill_to_geography_type9,
           bill_to_geography_value9,
           bill_to_geography_type10,
           bill_to_geography_value10,
           bill_from_geography_type1,
           bill_from_geography_value1,
           bill_from_geography_type2,
           bill_from_geography_value2,
           bill_from_geography_type3,
           bill_from_geography_value3,
           bill_from_geography_type4,
           bill_from_geography_value4,
           bill_from_geography_type5,
           bill_from_geography_value5,
           bill_from_geography_type6,
           bill_from_geography_value6,
           bill_from_geography_type7,
           bill_from_geography_value7,
           bill_from_geography_type8,
           bill_from_geography_value8,
           bill_from_geography_type9,
           bill_from_geography_value9,
           bill_from_geography_type10,
           bill_from_geography_value10,
           LINE_EXT_VARCHAR_ATTRIBUTE1,
           LINE_EXT_VARCHAR_ATTRIBUTE2,
           LINE_EXT_VARCHAR_ATTRIBUTE3,
           LINE_EXT_VARCHAR_ATTRIBUTE4,
           LINE_EXT_VARCHAR_ATTRIBUTE5,
           LINE_EXT_VARCHAR_ATTRIBUTE6,
           LINE_EXT_VARCHAR_ATTRIBUTE7,
           LINE_EXT_VARCHAR_ATTRIBUTE8,
           LINE_EXT_VARCHAR_ATTRIBUTE9,
           LINE_EXT_VARCHAR_ATTRIBUTE10,
           LINE_EXT_VARCHAR_ATTRIBUTE11,
           LINE_EXT_VARCHAR_ATTRIBUTE12,
           LINE_EXT_VARCHAR_ATTRIBUTE13,
           LINE_EXT_VARCHAR_ATTRIBUTE14,
           LINE_EXT_VARCHAR_ATTRIBUTE15,
           LINE_EXT_NUMBER_ATTRIBUTE1,
           LINE_EXT_NUMBER_ATTRIBUTE2,
           LINE_EXT_NUMBER_ATTRIBUTE3,
           LINE_EXT_NUMBER_ATTRIBUTE4,
           LINE_EXT_DATE_ATTRIBUTE1,
           adjusted_doc_date,
           trx_date,
           exemption_control_flag
     INTO arp_line_amount,
          arp_quantity,
          arp_trx_id,
          arp_trx_number,
          arp_ship_to_grphy_type1,
          arp_ship_to_grphy_value1,
          arp_ship_to_grphy_type2,
          arp_ship_to_grphy_value2,
          arp_ship_to_grphy_type3,
          arp_ship_to_grphy_value3,
          arp_ship_to_grphy_type4,
          arp_ship_to_grphy_value4,
          arp_ship_to_grphy_type5,
          arp_ship_to_grphy_value5,
          arp_ship_to_grphy_type6,
          arp_ship_to_grphy_value6,
          arp_ship_to_grphy_type7,
          arp_ship_to_grphy_value7,
          arp_ship_to_grphy_type8,
          arp_ship_to_grphy_value8,
          arp_ship_to_grphy_type9,
          arp_ship_to_grphy_value9,
          arp_ship_to_grphy_type10,
          arp_ship_to_grphy_value10,
          arp_ship_from_grphy_type1,
          arp_ship_from_grphy_value1,
          arp_ship_from_grphy_type2,
          arp_ship_from_grphy_value2,
          arp_ship_from_grphy_type3,
          arp_ship_from_grphy_value3,
          arp_ship_from_grphy_type4,
          arp_ship_from_grphy_value4,
          arp_ship_from_grphy_type5,
          arp_ship_from_grphy_value5,
          arp_ship_from_grphy_type6,
          arp_ship_from_grphy_value6,
          arp_ship_from_grphy_type7,
          arp_ship_from_grphy_value7,
          arp_ship_from_grphy_type8,
          arp_ship_from_grphy_value8,
          arp_ship_from_grphy_type9,
          arp_ship_from_grphy_value9,
          arp_ship_from_grphy_type10,
          arp_ship_from_grphy_value10,
          /*arp_poa_grphy_type1,
          arp_poa_grphy_value1,
          arp_poa_grphy_type2,
          arp_poa_grphy_value2,
          arp_poa_grphy_type3,
          arp_poa_grphy_value3,
          arp_poa_grphy_type4,
          arp_poa_grphy_value4,
          arp_poa_grphy_type5,
          arp_poa_grphy_value5,
          arp_poa_grphy_type6,
          arp_poa_grphy_value6,
          arp_poa_grphy_type7,
          arp_poa_grphy_value7,
          arp_poa_grphy_type8,
          arp_poa_grphy_value8,
          arp_poa_grphy_type9,
          arp_poa_grphy_value9,
          arp_poa_grphy_type10,
          arp_poa_grphy_value10,
          arp_poo_grphy_type1,
          arp_poo_grphy_value1,
          arp_poo_grphy_type2,
          arp_poo_grphy_value2,
          arp_poo_grphy_type3,
          arp_poo_grphy_value3,
          arp_poo_grphy_type4,
          arp_poo_grphy_value4,
          arp_poo_grphy_type5,
          arp_poo_grphy_value5,
          arp_poo_grphy_type6,
          arp_poo_grphy_value6,
          arp_poo_grphy_type7,
          arp_poo_grphy_value7,
          arp_poo_grphy_type8,
          arp_poo_grphy_type9,
          arp_poo_grphy_value9,
          arp_poo_grphy_type10,
          arp_poo_grphy_value10,*/
          arp_bill_to_grphy_type1,
          arp_bill_to_grphy_value1,
          arp_bill_to_grphy_type2,
          arp_bill_to_grphy_value2,
          arp_bill_to_grphy_type3,
          arp_bill_to_grphy_value3,
          arp_bill_to_grphy_type4,
          arp_bill_to_grphy_value4,
          arp_bill_to_grphy_type5,
          arp_bill_to_grphy_value5,
          arp_bill_to_grphy_type6,
          arp_bill_to_grphy_value6,
          arp_bill_to_grphy_type7,
          arp_bill_to_grphy_value7,
          arp_bill_to_grphy_type8,
          arp_bill_to_grphy_value8,
          arp_bill_to_grphy_type9,
          arp_bill_to_grphy_value9,
          arp_bill_to_grphy_type10,
          arp_bill_to_grphy_value10,
          arp_bill_from_grphy_type1,
          arp_bill_from_grphy_value1,
          arp_bill_from_grphy_type2,
          arp_bill_from_grphy_value2,
          arp_bill_from_grphy_type3,
          arp_bill_from_grphy_value3,
          arp_bill_from_grphy_type4,
          arp_bill_from_grphy_value4,
          arp_bill_from_grphy_type5,
          arp_bill_from_grphy_value5,
          arp_bill_from_grphy_type6,
          arp_bill_from_grphy_value6,
          arp_bill_from_grphy_type7,
          arp_bill_from_grphy_value7,
          arp_bill_from_grphy_type8,
          arp_bill_from_grphy_value8,
          arp_bill_from_grphy_type9,
          arp_bill_from_grphy_value9,
          arp_bill_from_grphy_type10,
          arp_bill_from_grphy_value10,
          arp_trx_line_type,
          arp_product_code,
          arp_cert_num,
          arp_state_exempt_reason,
          arp_county_exempt_reason,
          arp_city_exempt_reason,
          arp_district_exempt_rs,
          arp_audit_flag,
          arp_ship_to_add,
          arp_ship_from_add,
          arp_poa_add_code,
          arp_customer_code,
          arp_customer_class,
          arp_company_code,
          arp_division_code,
          arp_state_exempt_percent,
          arp_county_exempt_pct,
          arp_city_exempt_pct  ,
          arp_district_exempt_pct,
          arp_transaction_date,
          arp_adjusted_doc_date,
          arp_trx_date,
          arp_exemption_control_flag
     FROM  ZX_PTNR_NEG_LINE_GT
     WHERE trx_line_id= pg_trx_line_id_tab(I);


     IF substrb(nvl(arp_ship_from_add,'XXXXXXXXX'), 2,9)='XXXXXXXXX' THEN
       inv_in_rec.fJurisSFGeoCd := null;
       inv_in_rec.fJurisSFInCi  := null;
     ELSE
       inv_in_rec.fJurisSFGeoCd := to_number(substrb(arp_ship_from_add, 2, 9));
       inv_in_rec.fJurisSFInCi  := case substrb(arp_ship_from_add, 1, 1)
                                        when 'X'  then NULL
                                        when '1'  then TRUE
                                        when '0'  then FALSE
                                        else  NULL
                                   end ;
     END IF;

     IF substrb(nvl(arp_ship_to_add,'XXXXXXXXX'), 2,9)='XXXXXXXXX' THEN
       inv_in_rec.fJurisSTGeoCd := null;
       inv_in_rec.fJurisSTInCi  := null;
     ELSE
       inv_in_rec.fJurisSTGeoCd := to_number(substrb(arp_ship_to_add, 2, 9));
       inv_in_rec.fJurisSTInCi  := case substrb(arp_ship_to_add, 1, 1)
                                                 when 'X'  then NULL
                                                 when '1'  then TRUE
                                                 when '0'  then FALSE
                                                 else  NULL
                                    end ;
     END IF;

     IF substrb(nvl(arp_poa_add_code,'XXXXXXXXX'), 2,9)='XXXXXXXXX' THEN
       inv_in_rec.fJurisOAGeoCd := null;
       inv_in_rec.fJurisOAInCi  := null;
     ELSE
       inv_in_rec.fJurisOAGeoCd := to_number(substrb(arp_poa_add_code, 2, 9));
       inv_in_rec.fJurisOAInCi  := case substrb(arp_poa_add_code, 1, 1)
                                                  when 'X'  then NULL
                                                  when '1'  then TRUE
                                                  when '0'  then FALSE
                                                  else  NULL
                                    end ;
     END IF;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fJurisSFGeoCd :'||inv_in_rec.fJurisSFGeoCd );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fJurisSTGeoCd :'||inv_in_rec.fJurisSTGeoCd );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fJurisOAGeoCd :'||inv_in_rec.fJurisOAGeoCd );
     END IF;

     inv_in_rec.fTDMCustCd    :=  arp_customer_code;
     inv_in_rec.fTDMCustClassCd  :=  arp_customer_class;
     inv_in_rec.fTDMCompCd    :=  arp_company_code;     -- Bug 5007293
     inv_in_rec.fInvIdNum    :=  to_char(arp_trx_number);
     inv_in_rec.fTDMDivCd    :=  arp_division_code;
  --Bug Fix: 4950901
    /*-----------------------------------------------------------
     | The transaction type identifies the type of transaction  |
     | being processed.           |
     -----------------------------------------------------------*/
     IF arp_trx_line_type = 'PURCHASE' THEN
       line_in_tab(1).fTransType := ZX_TAX_VERTEX_QSU.cQSUTransTypePurchase;
     ELSIF arp_trx_line_type = 'RENTAL' THEN
       line_in_tab(1).fTransType := ZX_TAX_VERTEX_QSU.cQSUTransTypeRentLease;
     ELSIF arp_trx_line_type = 'LEASE' THEN
       line_in_tab(1).fTransType := ZX_TAX_VERTEX_QSU.cQSUTransTypeRentLease;
     ELSIF arp_trx_line_type = 'SALE' THEN
       line_in_tab(1).fTransType := ZX_TAX_VERTEX_QSU.cQSUTransTypeSale;
     ELSIF arp_trx_line_type = 'SERVICE' THEN
       line_in_tab(1).fTransType := ZX_TAX_VERTEX_QSU.cQSUTransTypeService;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'line_in_tab(1).fTransType :'||to_char(line_in_tab(1).fTransType));
     END IF;
--End of Bug Fix : 4950901

     line_in_tab(1).fTransDate    :=  arp_transaction_date;
     line_in_tab(1).fTransUserArea  :=  to_char(arp_trx_id);
     line_in_tab(1).fTDMProdCd  :=  arp_product_code;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fTDMCustCd      : '||inv_in_rec.fTDMCustCd );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fTDMCustClassCd : '||inv_in_rec.fTDMCustClassCd );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fTDMCompCd      : '||inv_in_rec.fTDMCompCd );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fInvIdNum       : '||inv_in_rec.fInvIdNum );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'inv_in_rec.fTDMDivCd       : '||inv_in_rec.fTDMDivCd );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'line_in_tab(1).fTransType  : '||line_in_tab(1).fTransType );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'line_in_tab(1).fTransDate  : '||line_in_tab(1).fTransDate );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'line_in_tab(1).fTDMProdCd  : '||line_in_tab(1).fTDMProdCd );
     END IF;
  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
       ' pg_ship_to_loc_id_tab before hz_locations : '||pg_ship_to_loc_id_tab(i));
  END IF;
  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
       ' pg_bill_to_loc_id_tab before hz_locations : '||pg_bill_to_loc_id_tab(i));
  END IF;

  if (inv_in_rec.fJurisSTGeoCd is null) then
    BEGIN
      SELECT loc.STATE, loc.COUNTY, loc.CITY, substrb(loc.POSTAL_CODE,1,5)
      INTO inv_in_rec.fJurisSTStAbbrv
           ,inv_in_rec.fJurisSTCoName
           ,inv_in_rec.fJurisSTCiName
           ,inv_in_rec.fJurisSTZipCd
      FROM hz_locations loc
      WHERE loc.location_id =  NVL(pg_ship_to_loc_id_tab(I),pg_bill_to_loc_id_tab(I));
    EXCEPTION
      WHEN OTHERS THEN
        inv_in_rec.fJurisSTStAbbrv := NULL;
        inv_in_rec.fJurisSTCoName := NULL;
        inv_in_rec.fJurisSTCiName := NULL;
        inv_in_rec.fJurisSTZipCd := NULL;
    END;
    l_location_info_rec.state  := inv_in_rec.fJurisSTStAbbrv;
    l_location_info_rec.county  := inv_in_rec.fJurisSTCoName;
    l_location_info_rec.city  := inv_in_rec.fJurisSTCiName;
    l_location_info_rec.postal_code  := inv_in_rec.fJurisSTZipCd;
    /*Calling GET_GEOCODE function for fetching geocode value*/
    inv_in_rec.fJurisSTGeoCd :=get_geocode(l_location_info_rec);
  end if;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'l_document_type : '||l_document_type );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'l_line_level_action :'||l_line_level_action );
  END IF;

  IF (l_document_type in ('INVOICE', 'DEBIT_MEMO', 'ON_ACCT_CREDIT_MEMO')) THEN
    IF (l_line_level_action IN ('CREATE','DELETE','CANCEL')) THEN
      inv_in_rec.fInvDate                := pg_trx_date_tab(i);
      line_in_tab(1).fTransCd            := ZX_TAX_VERTEX_QSU.cQSUTransCdNormal;

      IF l_line_level_action =  'CREATE' THEN
        line_in_tab(1).fTransExtendedAmt   := pg_line_amount_tab(I);
        line_in_tab(1).fPriStExmtAmt       := pg_line_numeric1_tab(i) * pg_line_amount_tab(I)/100;
        line_in_tab(1).fPriCoExmtAmt       := pg_line_numeric2_tab(i) * pg_line_amount_tab(I)/100;
        line_in_tab(1).fPriCiExmtAmt       := pg_line_numeric3_tab(i) * pg_line_amount_tab(I)/100;
        line_in_tab(1).fPriDiExmtAmt       := pg_line_numeric4_tab(i) * pg_line_amount_tab(I)/100;
      ELSE
        line_in_tab(1).fTransExtendedAmt   := -1 * pg_line_amount_tab(I);
        line_in_tab(1).fPriStExmtAmt       := -1 * pg_line_numeric1_tab(i) * pg_line_amount_tab(I)/100;
        line_in_tab(1).fPriCoExmtAmt       := -1 * pg_line_numeric2_tab(i) * pg_line_amount_tab(I)/100;
        line_in_tab(1).fPriCiExmtAmt       := -1 * pg_line_numeric3_tab(i) * pg_line_amount_tab(I)/100;
        line_in_tab(1).fPriDiExmtAmt       := -1 * pg_line_numeric4_tab(i) * pg_line_amount_tab(I)/100;
      END IF;

      line_in_tab(1).fTransQuantity      := abs(pg_trx_line_qty_tab(I));

      IF (pg_exempt_cont_flag_tab(I)='R') then
        line_in_tab(1).fProdTxblty      := ZX_TAX_VERTEX_QSU.cQSUTxbltyTxbl ;
        inv_in_rec.fCustTxblty          := ZX_TAX_VERTEX_QSU.cQSUTxbltyTxbl ;
      END IF;

      line_in_tab(1).fPriCustExmtCrtfNum := substrb(pg_Line_char3_tab(I), 1, 15);
      line_in_tab(1).fPriStExmtRsnCd     := SUBSTRB(pg_Line_char4_tab(I),1,1);
      line_in_tab(1).fPriCoExmtRsnCd     := SUBSTRB(pg_Line_char5_tab(I),1,1);
      line_in_tab(1).fPriCiExmtRsnCd     := SUBSTRB(pg_Line_char6_tab(I),1,1);
      line_in_tab(1).fPriDiExmtRsnCd     := SUBSTRB(pg_Line_char7_tab(I),1,1);

    ELSE
      inv_in_rec.fInvDate                := arp_trx_date;
      line_in_tab(1).fTransCd            := ZX_TAX_VERTEX_QSU.cQSUTransCdNormal;
      line_in_tab(1).fTransExtendedAmt   :=(-1*arp_line_amount);
      line_in_tab(1).fTransQuantity      := abs(arp_quantity);

      IF (arp_exemption_control_flag ='R') THEN
         line_in_tab(1).fProdTxblty      := ZX_TAX_VERTEX_QSU.cQSUTxbltyTxbl ;
         inv_in_rec.fCustTxblty          := ZX_TAX_VERTEX_QSU.cQSUTxbltyTxbl ;
      END IF;

      line_in_tab(1).fPriCustExmtCrtfNum := substrb(arp_cert_num, 1, 15);
      line_in_tab(1).fPriStExmtRsnCd     := SUBSTRB(arp_state_exempt_reason,1,1);
      line_in_tab(1).fPriStExmtAmt       := (-1 * arp_state_exempt_percent * arp_line_amount/100);

      line_in_tab(1).fPriCoExmtRsnCd     := SUBSTRB(arp_county_exempt_reason,1,1);
      line_in_tab(1).fPriCoExmtAmt       := (-1 * arp_county_exempt_pct * arp_line_amount/100);

      line_in_tab(1).fPriCiExmtRsnCd     := SUBSTRB(arp_city_exempt_reason,1,1);
      line_in_tab(1).fPriCiExmtAmt       := (-1 * arp_city_exempt_pct * arp_line_amount/100);

      line_in_tab(1).fPriDiExmtRsnCd     := SUBSTRB(arp_district_exempt_rs,1,1);
      line_in_tab(1).fPriDiExmtAmt       := (-1 * arp_district_exempt_pct * arp_line_amount/100);
    END IF;

  ELSIF (l_document_type in ('APPLIED_CREDIT_MEMO')) then
       --bug#6831713
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

    IF (l_line_level_action IN ('CREATE','DELETE','CANCEL')) THEN
      inv_in_rec.fInvDate                := pg_adj_doc_date_tab(I);
      line_in_tab(1).fTransCd            := ZX_TAX_VERTEX_QSU.cQSUTransCdNormal;
      line_in_tab(1).fTransExtendedAmt   :=pg_line_amount_tab(I);
      line_in_tab(1).fTransQuantity      := abs(pg_trx_line_qty_tab(I));

      IF (pg_exempt_cont_flag_tab(I)='R') THEN
         line_in_tab(1).fProdTxblty      := ZX_TAX_VERTEX_QSU.cQSUTxbltyTxbl ;
         inv_in_rec.fCustTxblty          := ZX_TAX_VERTEX_QSU.cQSUTxbltyTxbl ;
      END IF;

      line_in_tab(1).fPriCustExmtCrtfNum := substrb(pg_Line_char3_tab(I), 1, 15);
      line_in_tab(1).fPriStExmtRsnCd     := SUBSTRB(pg_Line_char4_tab(I),1,1);
      line_in_tab(1).fPriStExmtAmt       := pg_line_numeric1_tab(i) *
                                            pg_line_amount_tab(I)/100;

      line_in_tab(1).fPriCoExmtRsnCd     := SUBSTRB(pg_Line_char5_tab(I),1,1);
      line_in_tab(1).fPriCoExmtAmt       := pg_line_numeric2_tab(i) *
                                            pg_line_amount_tab(I)/100;
      line_in_tab(1).fPriCiExmtRsnCd     := SUBSTRB(pg_Line_char6_tab(I),1,1);
      line_in_tab(1).fPriCiExmtAmt       := pg_line_numeric3_tab(i) *
                                            pg_line_amount_tab(I)/100;
      line_in_tab(1).fPriDiExmtRsnCd     := SUBSTRB(pg_Line_char7_tab(I),1,1);
      line_in_tab(1).fPriDiExmtAmt       := pg_line_numeric4_tab(i) *
                                            pg_line_amount_tab(I)/100;
    ELSE
      inv_in_rec.fInvDate    := arp_adjusted_doc_date;
      line_in_tab(1).fTransCd  := ZX_TAX_VERTEX_QSU.cQSUTransCdNormal;
      line_in_tab(1).fTransExtendedAmt :=(-1*arp_line_amount);
      line_in_tab(1).fTransQuantity    := abs(arp_quantity);

      IF (arp_exemption_control_flag='R') THEN /*Need to check*/
         line_in_tab(1).fProdTxblty   := ZX_TAX_VERTEX_QSU.cQSUTxbltyTxbl ;
         inv_in_rec.fCustTxblty       := ZX_TAX_VERTEX_QSU.cQSUTxbltyTxbl ;
      END IF;
      line_in_tab(1).fPriCustExmtCrtfNum := substrb(arp_cert_num, 1, 15);
      line_in_tab(1).fPriStExmtRsnCd     := SUBSTRB(arp_state_exempt_reason,1,1);
      line_in_tab(1).fPriStExmtAmt       := -1 * arp_state_exempt_percent *
                                            arp_line_amount/100;

      line_in_tab(1).fPriCoExmtRsnCd     := SUBSTRB(arp_county_exempt_reason,1,1);
      line_in_tab(1).fPriCoExmtAmt       := -1 * arp_county_exempt_pct *
                                            arp_line_amount/100;

      line_in_tab(1).fPriCiExmtRsnCd     := SUBSTRB(arp_city_exempt_reason,1,1);
      line_in_tab(1).fPriCiExmtAmt       := -1 * arp_city_exempt_pct *
                                            arp_line_amount/100;
      line_in_tab(1).fPriDiExmtRsnCd     := SUBSTRB(arp_district_exempt_rs,1,1);
      line_in_tab(1).fPriDiExmtAmt       := -1 * arp_district_exempt_pct *
                                            arp_line_amount/100;
    END IF;

    ELSIF (l_document_type IN ('LINE_ONLY_CREDIT_MEMO')) THEN
      IF (l_line_level_action IN ('CREATE','DELETE','CANCEL')) THEN
        inv_in_rec.fInvDate    := pg_adj_doc_date_tab(I);
        line_in_tab(1).fTransCd  := ZX_TAX_VERTEX_QSU.cQSUTransCdDistributeTax;
        line_in_tab(1).fTransExtendedAmt :=pg_line_amount_tab(I);
        line_in_tab(1).fTransQuantity    := abs(pg_trx_line_qty_tab(I));
        line_in_tab(1).fTransTotalTaxAmt :=0;

        IF (pg_exempt_cont_flag_tab(I)='R') then
          line_in_tab(1).fProdTxblty   := ZX_TAX_VERTEX_QSU.cQSUTxbltyTxbl ;
          inv_in_rec.fCustTxblty       := ZX_TAX_VERTEX_QSU.cQSUTxbltyTxbl ;
        end if;
      ELSE
        inv_in_rec.fInvDate    := arp_adjusted_doc_date;
        line_in_tab(1).fTransCd  := ZX_TAX_VERTEX_QSU.cQSUTransCdDistributeTax;
        line_in_tab(1).fTransExtendedAmt :=(-1*arp_line_amount);
        line_in_tab(1).fTransQuantity    := abs(arp_quantity);
        line_in_tab(1).fTransTotalTaxAmt :=0;

        if(arp_exemption_control_flag='R') then /*Need to check*/
          line_in_tab(1).fProdTxblty   := ZX_TAX_VERTEX_QSU.cQSUTxbltyTxbl ;
          inv_in_rec.fCustTxblty       := ZX_TAX_VERTEX_QSU.cQSUTxbltyTxbl ;
        END IF;
      END IF;

    ELSIF l_document_type IN ('TAX_ONLY_CREDIT_MEMO') THEN
      IF (l_line_level_action IN ('CREATE','DELETE','CANCEL')) THEN
         inv_in_rec.fInvDate              := pg_adj_doc_date_tab(I);
         line_in_tab(1).fTransCd          := ZX_TAX_VERTEX_QSU.cQSUTransCdTaxOnlyCredit;
         line_in_tab(1).fTransExtendedAmt := NULL;
         line_in_tab(1).fTransQuantity    := NULL;

         IF (pg_exempt_cont_flag_tab(I)='R') THEN
            line_in_tab(1).fProdTxblty    := NULL ;
            inv_in_rec.fCustTxblty        := NULL;
         END IF;
         line_in_tab(1).fPriStTaxAmt      := g_StTaxAmt;
         line_in_tab(1).fPriCoTaxAmt      := g_CoTaxAmt;
         line_in_tab(1).fPriCiTaxAmt      := g_CiTaxAmt;
      ELSE
         inv_in_rec.fInvDate              := arp_adjusted_doc_date;
         line_in_tab(1).fTransCd          := ZX_TAX_VERTEX_QSU.cQSUTransCdTaxOnlyCredit;
        line_in_tab(1).fTransExtendedAmt  := NULL;
        line_in_tab(1).fTransQuantity     := NULL;

        IF (arp_exemption_control_flag='R') THEN /*Need to check*/
           line_in_tab(1).fProdTxblty     := NULL ;
           inv_in_rec.fCustTxblty         := NULL;
        END IF;
      END IF;
    ELSIF l_document_type in ('INVOICE_ADJUSTMENT') THEN
      inv_in_rec.fInvDate                 := pg_trx_date_tab(i);
      line_in_tab(1).fTransCd             := ZX_TAX_VERTEX_QSU.cQSUTransCdDistributeTax;
      line_in_tab(1).fTransExtendedAmt    := pg_line_amount_tab(i)-
                                                (g_StTaxAmt+g_CoTaxAmt+g_CiTaxAmt);
      line_in_tab(1).fTransQuantity       := abs(pg_trx_line_qty_tab(I));
      line_in_tab(1).fTransTotalTaxAmt    := g_StTaxAmt+g_CoTaxAmt+g_CiTaxAmt;
    ELSIF l_document_type in ('TAX_LINE_SYNC'
                             ,'TAX_ONLY_INVOICE'
                             ,'TAX_ONLY_ADJUSTMENT') THEN
      inv_in_rec.fInvDate                 := arp_trx_date;
      line_in_tab(1).fTransCd             := ZX_TAX_VERTEX_QSU.cQSUTransCdDistributeTax;
      line_in_tab(1).fTransExtendedAmt    := NULL;
      line_in_tab(1).fTransQuantity       := NULL;
      --bug#6831713
      line_in_tab(1).fTransTotalTaxAmt    := g_TotalTaxAmt;
      line_in_tab(1).fPriStTaxAmt         := g_StTaxAmt;
      line_in_tab(1).fPriCoTaxAmt         := g_CoTaxAmt;
      line_in_tab(1).fPriCiTaxAmt         := g_CiTaxAmt;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
           ' line_in_tab(1).fPriStTaxAmt  '||line_in_tab(1).fPriStTaxAmt);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
           ' line_in_tab(1).fPriCoTaxAmt  '||line_in_tab(1).fPriCoTaxAmt);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
           ' line_in_tab(1).fPriCiTaxAmt  '||line_in_tab(1).fPriCiTaxAmt);
      END IF;

    ELSIF (l_document_type in ('SALES_QUOTE')) then -- Bug5927656
      inv_in_rec.fInvDate                := pg_trx_date_tab(i);
      line_in_tab(1).fTransCd            := ZX_TAX_VERTEX_QSU.cQSUTransCdNormal;

      IF l_line_level_action =  'CREATE' THEN
         line_in_tab(1).fTransExtendedAmt   := pg_line_amount_tab(I);
       END IF;

      line_in_tab(1).fTransQuantity      := abs(pg_trx_line_qty_tab(I));

      IF (pg_exempt_cont_flag_tab(I)='R') then
         line_in_tab(1).fProdTxblty      := ZX_TAX_VERTEX_QSU.cQSUTxbltyTxbl ;
         inv_in_rec.fCustTxblty          := ZX_TAX_VERTEX_QSU.cQSUTxbltyTxbl ;
       END IF;

      line_in_tab(1).fPriCustExmtCrtfNum := substrb(pg_Line_char3_tab(I), 1, 15);
      line_in_tab(1).fPriStExmtRsnCd     := SUBSTRB(pg_Line_char4_tab(I),1,1);
      line_in_tab(1).fPriStExmtAmt       := pg_line_numeric1_tab(i) *
                                            pg_line_amount_tab(I)/100;

      line_in_tab(1).fPriCoExmtRsnCd     := SUBSTRB(pg_Line_char5_tab(I),1,1);
      line_in_tab(1).fPriCoExmtAmt       := pg_line_numeric2_tab(i) *
                                            pg_line_amount_tab(I)/100;
      line_in_tab(1).fPriCiExmtRsnCd     := SUBSTRB(pg_Line_char6_tab(I),1,1);
      line_in_tab(1).fPriCiExmtAmt       := pg_line_numeric3_tab(i) *
                                            pg_line_amount_tab(I)/100;
      line_in_tab(1).fPriDiExmtRsnCd     := SUBSTRB(pg_Line_char7_tab(I),1,1);
      line_in_tab(1).fPriDiExmtAmt       := pg_line_numeric4_tab(i) *
                                             pg_line_amount_tab(I)/100;

    END IF;

    display_output('I');

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;

END SET_PARAMETERS;


FUNCTION GET_GEOCODE(p_location_info_rec location_info_rec_type) return VARCHAR2 IS

k    INTEGER;
ptr    INTEGER;
found     BOOLEAN := FALSE;

l_state    VARCHAR2(60);
l_county  VARCHAR2(60);
l_city    VARCHAR2(60);
l_postal_code  VARCHAR2(60);
l_geocode  BINARY_INTEGER;

retval    BOOLEAN := FALSE;

l_api_name           CONSTANT VARCHAR2(30) := 'GET_GEOCODE';

BEGIN
  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'STATE    :'||p_location_info_rec.state );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'COUNTY   :'||p_location_info_rec.county );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'CITY     :'||p_location_info_rec.city );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'POSTAL CODE :'||p_location_info_rec.postal_code);
  END IF;

l_state    :=p_location_info_rec.state;
l_county  :=p_location_info_rec.county;
l_city    :=p_location_info_rec.city;
l_postal_code  :=p_location_info_rec.postal_code;


    /*---------------------------------------------------
     | Look for the conbination from cache    |
     ---------------------------------------------------*/
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Look for the combination from cache' );
    END IF;
    FOR k in 1 .. pg_max_index
    LOOP
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'-- k = '|| to_char(k) );
        END IF;
      IF (l_state = pg_state(k)) and (l_county = pg_county(k)) and
        (l_city = pg_city(k)) and
        (l_postal_code = pg_postal_code(k)) THEN
      found := TRUE;
      ptr := k;
        EXIT;
        END IF;
    END LOOP;

    IF NOT found THEN
  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Could not find the combination  in the cache.' );
        END IF;

  BEGIN
      /*-------------------------------------------------------
       | Call API to set search criteria for finding GeoCode. |
       -------------------------------------------------------*/
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Call API to set search criteria for '||
        'finding GeoCode.');
    END IF;

          ZX_TAX_VERTEX_GEO.GeoSetNameCriteria(
                        search_rec,
                        ZX_TAX_VERTEX_GEO.cGeoCodeLevelCity,
                        substrb(l_state, 1, 2),
                        FALSE,
                        '',
                        FALSE,
                        substrb(l_county, 1, 20),
                        FALSE,
                        FALSE,
                        substrb(l_city, 1, 25),
                        FALSE,
                        substrb(l_postal_code, 1, 5),
                        NULL);
      EXCEPTION
            WHEN OTHERS THEN
        IF (g_level_exception >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
     --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    g_string :='Error in VERTEX API:'||to_char(SQLCODE)||SQLERRM;
    error_exception_handle(g_string);
    --return;

        END IF;


      END;

  BEGIN
            /*---------------------------
             | Call API to get GeoCode.  |
              ---------------------------*/
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Call API to get GeoCode.' );
            END IF;
      retval := ZX_TAX_VERTEX_GEO.GeoRetrieveFirst(search_rec, result_rec);

        EXCEPTION
            WHEN OTHERS THEN
                IF (g_level_exception >= g_current_runtime_level ) THEN
                   FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
                IF (SQLCODE > -20500) OR (SQLCODE < -20599) THEN
                    --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        g_string :='Error in VERTEX API:'||to_char(SQLCODE)||SQLERRM;
        error_exception_handle(g_string);
        --return;
                END IF;
  END;

      IF retval = FALSE THEN
      /*******No jurisdiction code is found.*******/
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'No Jurisdiction code is found.' );
          END IF;
      return '';
  ElSE
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Found the combination from Vendor Table.' );
          END IF;
  END IF;

  BEGIN
      /*-----------------------------------------------------------
       | Call API to pack GeoCode(Convert state, county, and city |
       | GeoCode into one 9-digit GeoCode.      |
         -----------------------------------------------------------*/
  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Call API to pack GeoCode to convert state, '||
      'county, and city GeoCode into one 9-digit GeoCode.' );
        END IF;

          l_geocode :=ZX_TAX_VERTEX_GEO.GeoPackGeoCode( result_rec.fResGeoState,
                                   result_rec.fResGeoCounty,
                                                   result_rec.fResGeoCity);

      EXCEPTION
            WHEN OTHERS THEN
                IF (g_level_exception >= g_current_runtime_level ) THEN
                   FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
              IF (SQLCODE > -20500) OR (SQLCODE < -20599) THEN
                g_string :='Error in VERTEX API:'||to_char(SQLCODE)||SQLERRM;
    error_exception_handle(g_string);
    return' ';
              END IF;
    --RAISE;
      END;

      pg_max_index := pg_max_index + 1;
    ptr := pg_max_index;
      pg_state( ptr ) := l_state;
      pg_county( ptr ) := l_county;
      pg_city(ptr ) := l_city;
      pg_postal_code( ptr ) := l_postal_code;
      pg_geocode( ptr ) := to_char(l_geocode);

  BEGIN
      /*----------------------------------------------------------
       | Call API to find out whether there is another record or |
       | not.  If there is, then raise error later.         |
       ----------------------------------------------------------*/
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Call API to find out whether there is another '||
                                                         'record or not.  If there is, then raise error later.' );
       END IF;

          retval := ZX_TAX_VERTEX_GEO.GeoRetrieveNext(search_rec, result_rec);

        EXCEPTION
            WHEN OTHERS THEN
                IF (g_level_exception >= g_current_runtime_level ) THEN
                   FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
                IF (SQLCODE > -20500) OR (SQLCODE < -20599) THEN
                 --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    g_string :='Error in VERTEX API:'||to_char(SQLCODE)||SQLERRM;
    error_exception_handle(g_string);

                END IF;
    --RAISE;
    return '';
        END;

      IF retval = TRUE THEN
              -- Bug2609220
      /*******too_many_rows*******/
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Too Many Rows for the combination of ST,CNTY,CITY' );
           END IF;
      return '';
      END IF;

    ElSE
  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Find the combination from the cache.' );
        END IF;
    END IF; -- NOT found

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;

    RETURN(pg_geocode( ptr ));

END GET_GEOCODE;



PROCEDURE CALCULATE_TAX(x_return_status OUT NOCOPY VARCHAR2) IS
 l_api_name           CONSTANT VARCHAR2(30) := 'CALCULATE_TAX';
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    /*-----------------------------------------------------------
     | Calculate tax for a invoice line.                        |
     -----------------------------------------------------------*/
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Before calculate '||
                                                to_char(sysdate, 'DD/MON/YYYY HH:MI:SS'));
    END IF;

    BEGIN
      ZX_TAX_VERTEX_QSU.QSUCalculateTaxes(context_rec,
                                   inv_in_rec,
                                   line_in_tab,
                                   inv_out_rec,
                                   line_out_tab,
                                   FALSE);

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'After calculate '||
                                                 to_char(sysdate, 'DD/MON/YYYY HH:MI:SS'));
      END IF;

      IF line_out_tab(1).fPriStTaxType = 0 THEN
        g_string := 'Ship to/Bill To Address is Invalid. Please review the Address Setup';
        error_exception_handle(g_string);
        RAISE FND_API.G_EXC_ERROR;
      END IF;

        display_output('O');

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        g_string :='Error in VERTEX tax calulation API due to incorrect address passed :'||
                     to_char(SQLCODE)||SQLERRM;
        IF (g_level_exception >= g_current_runtime_level ) THEN
          FND_LOG.STRING(G_LEVEL_EXCEPTION,
                         G_MODULE_NAME||l_api_name,
                         g_string);
        END IF;
        RETURN;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        g_string :='Error in VERTEX tax calulation API:'||to_char(SQLCODE)||SQLERRM;
        IF (g_level_exception >= g_current_runtime_level ) THEN
          FND_LOG.STRING(G_LEVEL_EXCEPTION,
                         G_MODULE_NAME||l_api_name,
                         g_string);
        END IF;
        --error_exception_handle(g_string);
     return;
    END;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;

End CALCULATE_TAX;

Procedure WRITE_TO_VERTEX_REPOSITORY(x_return_status OUT NOCOPY VARCHAR2) is
 l_api_name           CONSTANT VARCHAR2(30) := 'WRITE_TO_VERTEX_REPOSITORY';
Begin

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    /*-----------------------------------------------------------
     | Write the transaction to register table(regprereturnstbl)|
     -----------------------------------------------------------*/

  BEGIN
         ZX_TAX_VERTEX_QSU.QSUWritePreReturnsData(context_rec,
                            inv_out_rec,
                            line_out_tab);
        EXCEPTION
             WHEN OTHERS THEN
        IF (g_level_exception >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
        END IF;

                   g_string :='Error in VERTEX API:'||to_char(SQLCODE)||SQLERRM;
       error_exception_handle(g_string);
                   x_return_status := FND_API.G_RET_STS_ERROR;
             return;
      END;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;

END WRITE_TO_VERTEX_REPOSITORY;


PROCEDURE TAX_RESULTS_PROCESSING(
  p_tax_lines_tbl  IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_lines_tbl_type,
  p_currency_tab   IN OUT NOCOPY ZX_TAX_PARTNER_PKG.tax_currencies_tbl_type,
  x_return_status     OUT NOCOPY VARCHAR2) IS

  J NUMBER;
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
  sec_county_tax_rate     NUMBER; -- secondary county tax rate
  sec_county_tax_amount   NUMBER; -- secondary county tax amount
  sec_city_tax_rate       NUMBER; -- secondary city tax rate
  sec_city_tax_amount     NUMBER; -- secondary city tax amount
  add_county_tax_rate     NUMBER; -- additional county tax rate in %
  add_county_tax_amount   NUMBER; -- additional county tax amount
  add_city_tax_rate       NUMBER; -- additional city tax rate in %
  add_city_tax_amount     NUMBER; -- additional city tax amount
  add_dist_tax_rate       NUMBER; -- additional district tax rate in %
  add_dist_tax_amount  NUMBER; -- additional district tax amount
  l_situs                 VARCHAR2(20);
  ind      NUMBER;

  l_api_name           CONSTANT VARCHAR2(30) := 'TAX_RESULTS_PROCESSING';
  l_return_status         VARCHAR2(30);

Begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
  END IF;

    l_regime_code      := zx_tax_partner_pkg.g_tax_regime_code;
    p_currency_tab(1).tax_currency_precision      := 2;   -- Bug 5288518
  /*-------------------------------------------------------------
     | Populate Tax Amounts and Rates        |
     -----------------------------------------------------------*/
    /* State tax rate */
    state_tax_rate := round(line_out_tab(1).fPriStRate * 100, 6);
    /* State tax amount */
    state_tax_amount := line_out_tab(1).fPriStTaxAmt;
    /* County tax rate */
    county_tax_rate := round(line_out_tab(1).fPriCoRate * 100, 6);
    /* County tax amount */
    county_tax_amount := line_out_tab(1).fPriCoTaxAmt;
    /* City tax Rate */
    city_tax_rate := round(line_out_tab(1).fPriCiRate * 100, 6);
    /* City tax amount */
    city_tax_amount := line_out_tab(1).fPriCiTaxAmt;
    /* District tax rate */
    dist_tax_rate := round(line_out_tab(1).fPriDiRate * 100, 6);
    /* District tax amount */
    dist_tax_amount := line_out_tab(1).fPriDiTaxAmt;

    /*-----------------------------------------------------------
     | Populate Secondary Tax Amounts and Rates      |
     -----------------------------------------------------------*/
    IF line_out_tab(1).fPriDiAppliesTo = ZX_TAX_VERTEX_QSU.cQSUDiApplyCi THEN
      sec_county_tax_rate := 0;
      sec_county_tax_amount := 0;
      sec_city_tax_rate := dist_tax_rate;
      sec_city_tax_amount := dist_tax_amount;
    ELSE
      sec_county_tax_rate := dist_tax_rate;
      sec_county_tax_amount := dist_tax_amount;
      sec_city_tax_rate := 0;
      sec_city_tax_amount := 0;
    END IF;


    /*-----------------------------------------------------------
     | Populate Additional Tax Amounts and Rates    |
     -----------------------------------------------------------*/
    /* County tax rate */
    add_county_tax_rate := line_out_tab(1).fAddCoRate * 100;
    /* County tax amount */
    add_county_tax_amount := line_out_tab(1).fAddCoTaxAmt;
    /* City tax Rate */
    add_city_tax_rate := line_out_tab(1).fAddCiRate * 100;
    /* City tax amount */
    add_city_tax_amount := line_out_tab(1).fAddCiTaxAmt;
    /* District tax rate */
    add_dist_tax_rate := line_out_tab(1).fAddDiRate * 100;
    /* District tax amount */
    add_dist_tax_amount := line_out_tab(1).fAddDiTaxAmt;

    IF line_out_tab(1).fAddDiAppliesTo = ZX_TAX_VERTEX_QSU.cQSUDiApplyCi THEN
      add_city_tax_rate := round(add_city_tax_rate + add_dist_tax_rate, 6);
      add_city_tax_amount := add_city_tax_amount + add_dist_tax_amount;
    ELSE
        add_county_tax_rate := round(add_county_tax_rate + add_dist_tax_rate, 6);
        add_county_tax_amount := add_county_tax_amount + add_dist_tax_amount;
    END IF;

  IF line_out_tab(1).fPriTaxingJuris = 0 then
       l_situs := 'SHIP_TO';
  ELSIF line_out_tab(1).fPriTaxingJuris = 1 then
       l_situs := 'SHIP_FROM';
  ELSIF line_out_tab(1).fPriTaxingJuris = 2 then
             l_situs :=  'POA';
  ELSE null;
  END IF;

  IF l_situs =  'SHIP_TO' THEN
/* Bug 5090593: Making use of the location ids passed thru view.
           select nvl(ship_to_location_id, bill_to_location_id)
           INTO    p_location_id
      From    zx_lines_det_factors
      WHERE   event_class_mapping_id =  pg_doc_type_id_tab(I) and
                   trx_id           =  pg_trx_id_tab(I) and
              trx_line_id      =  pg_trx_line_id_tab(I) and
              trx_level_type    =  pg_trx_level_type_tab(I);
*/
           p_location_id := nvl(pg_ship_to_loc_id_tab(I), pg_bill_to_loc_id_tab(I));

        ELSIF l_situs =  'SHIP_FROM' THEN
/* Bug 5090593: Making use of the location ids passed thru view.
           select nvl(ship_from_location_id, bill_from_location_id)
           INTO    p_location_id
      From    zx_lines_det_factors
      WHERE   event_class_mapping_id =  pg_doc_type_id_tab(I) and
                   trx_id           =  pg_trx_id_tab(I) and
              trx_line_id      =  pg_trx_line_id_tab(I) and
              trx_level_type    =  pg_trx_level_type_tab(I);
*/
           p_location_id := nvl(pg_ship_fr_loc_id_tab(I), pg_bill_fr_loc_id_tab(I));
  ELSE null;
        END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Displaying for the transaction line : '||I);
  End If;

   --bug#6831713
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
        p_tax_lines_tbl.State(i)                      := inv_out_rec.fJurisSTStAbbrv;
        p_tax_lines_tbl.County(i)                     := inv_out_rec.fJurisSTCoName;
        p_tax_lines_tbl.City(i)                       := inv_out_rec.fJurisSTCiName;
        p_tax_lines_tbl.tax_only_line_flag(i) := 'N';
        p_tax_lines_tbl.Tax(i)                         := 'LOCATION';
        p_tax_lines_tbl.tax_amount(i)                  := line_out_tab(1).fPriStTaxAmt
                                                          + (county_tax_amount + sec_county_tax_amount + add_county_tax_amount)
                                                          + (city_tax_amount + sec_city_tax_amount + add_city_tax_amount);
        --added them
  p_tax_lines_tbl.unrounded_tax_amount(i)      := line_out_tab(1).fPriStTaxAmt
                                                          + (county_tax_amount + sec_county_tax_amount + add_county_tax_amount)
                                                          + (city_tax_amount + sec_city_tax_amount + add_city_tax_amount);
  p_tax_lines_tbl.tax_curr_tax_amount(i)       := p_tax_lines_tbl.tax_amount(i) * p_currency_tab(1).exchange_rate;
  p_tax_lines_tbl.tax_rate_percentage(i)       := state_tax_rate
                                                  + (county_tax_rate + sec_county_tax_rate + add_county_tax_rate)
              + (city_tax_rate + sec_city_tax_rate + add_city_tax_rate);

        p_tax_lines_tbl.taxable_amount(i)              := line_out_tab(1).fPriStTaxedAmt;

  p_tax_lines_tbl.tax_jurisdiction(i) := NULL;
        -- Can alternatively call GET_TAX_JUR_CODE for tax = 'CITY'  (lowest level jurisdiction)

  p_tax_lines_tbl.global_attribute_category(i) := 'VERTEX';
        p_tax_lines_tbl.global_attribute2(i) := to_char(line_out_tab(1).fPriStTaxAmt);
        p_tax_lines_tbl.global_attribute4(i) := to_char((county_tax_amount + sec_county_tax_amount + add_county_tax_amount));
        p_tax_lines_tbl.global_attribute6(i) := to_char((city_tax_amount + sec_city_tax_amount + add_city_tax_amount));


        p_tax_lines_tbl.exempt_reason(i) :=line_out_tab(1).fPriStExmtRsnCd;

        IF (NVL(line_out_tab(1).fPriStExmtAmt, 0) + NVL(line_out_tab(1).fPriCoExmtAmt, 0)
                                                  + NVL(line_out_tab(1).fPriCiExmtAmt, 0)) <> 0 THEN
          IF (line_out_tab(1).fTransExtendedAmt <> 0) then
             p_tax_lines_tbl.exempt_rate_modifier(i) := (line_out_tab(1).fPriStExmtAmt +
                                                         line_out_tab(1).fPriCoExmtAmt +
                                                         line_out_tab(1).fPriCiExmtAmt)/
                                                         line_out_tab(1).fTransExtendedAmt;
             p_tax_lines_tbl.exempt_certificate_number(i) := line_out_tab(1).fPriCustExmtCrtfNum;
          ELSE
            p_tax_lines_tbl.exempt_rate_modifier(i) := 0;
            p_tax_lines_tbl.exempt_certificate_number(i) := NULL;
          END IF;
        ELSE
          p_tax_lines_tbl.exempt_rate_modifier(i) := 0;
          p_tax_lines_tbl.exempt_certificate_number(i) := NULL;
        END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'tax line output ');
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.document_type_id('||i||') = '|| to_char(p_tax_lines_tbl.document_type_id(i)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.transaction_id('||i||') = '|| to_char(p_tax_lines_tbl.transaction_id(i)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.transaction_line_id('||i||') = '||
                to_char(p_tax_lines_tbl.transaction_line_id(i)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.trx_level_type('||i||') = '||
                p_tax_lines_tbl.trx_level_type(i));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.country_code('||i||') = '|| p_tax_lines_tbl.country_code(i));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.Tax('||i||') = '|| p_tax_lines_tbl.Tax(i));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.situs('||i||') = '|| p_tax_lines_tbl.situs(i));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.tax_jurisdiction('||i||') = '||
    p_tax_lines_tbl.tax_jurisdiction(i));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.tax_currency_code('||i||') = '|| p_tax_lines_tbl.tax_currency_code(i));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.TAX_CURR_TAX_AMOUNT('||i||')  = '||
    to_char(p_tax_lines_tbl.TAX_CURR_TAX_AMOUNT(i)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.tax_amount('||i||') = '|| to_char(p_tax_lines_tbl.tax_amount(i)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.tax_rate_percentage('||i||') = '||
    to_char(p_tax_lines_tbl.tax_rate_percentage(i)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.taxable_amount('||i||') = '||
    to_char(p_tax_lines_tbl.taxable_amount(i)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.State('||i||') = '|| p_tax_lines_tbl.State(i));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.County('||i||') = '|| p_tax_lines_tbl.County(i));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.City('||i||') = '|| p_tax_lines_tbl.City(i));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.unrounded_tax_amount('||i||') = '||
    to_char(p_tax_lines_tbl.unrounded_tax_amount(i)));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' line_out_tab(1).fPriCustExmtCrtfNum = '||
                line_out_tab(1).fPriCustExmtCrtfNum);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.exempt_certificate_number('||i||') = '||
                p_tax_lines_tbl.exempt_certificate_number(i));

           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute_category('||i||') = '|| p_tax_lines_tbl.global_attribute_category(i));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute2('||i||') = '|| p_tax_lines_tbl.global_attribute2(i));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute4('||i||') = '|| p_tax_lines_tbl.global_attribute4(i));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute6('||i||') = '|| p_tax_lines_tbl.global_attribute6(i));

        END IF;

   ELSE
    For J in 1..3
    loop
     /*Bug fix :4941881 , As we are processing all the transaction lines in one time,we need to use index accordingly*/
      ind:=j+(3*i-3);
  p_tax_lines_tbl.document_type_id(ind)    := pg_doc_type_id_tab(I);
  p_tax_lines_tbl.transaction_id(ind)    := pg_trx_id_tab(I);
  p_tax_lines_tbl.transaction_line_id(ind)  := pg_trx_line_id_tab(I);
  p_tax_lines_tbl.trx_level_type(ind)       := pg_trx_level_type_tab(I);
  p_tax_lines_tbl.country_code(ind)          := l_regime_code ;
  p_tax_lines_tbl.situs(ind)      := l_situs;
  p_tax_lines_tbl.tax_currency_code(ind)    := p_currency_tab(1).tax_currency_code;
  p_tax_lines_tbl.Inclusive_tax_line_flag(ind)  := 'N';
  p_tax_lines_tbl.Line_amt_includes_tax_flag(ind) := 'N';
  p_tax_lines_tbl.use_tax_flag(ind)    := 'N';
  p_tax_lines_tbl.User_override_flag(ind)    := 'N'; -- Need to see if different for override_tax
  p_tax_lines_tbl.last_manual_entry(ind)    := NULL;
  p_tax_lines_tbl.manually_entered_flag(ind)  := 'N'; -- Need to see if different for override_tax
  p_tax_lines_tbl.registration_party_type(ind)    := NULL;  -- Bug 5288518
  p_tax_lines_tbl.party_tax_reg_number(ind)       := NULL;  -- Bug 5288518
  p_tax_lines_tbl.third_party_tax_reg_number(ind)  := NULL;
  p_tax_lines_tbl.threshold_indicator_flag(ind)  := Null;
  p_tax_lines_tbl.State(ind)      := inv_out_rec.fJurisSTStAbbrv;
  p_tax_lines_tbl.County(ind)      := inv_out_rec.fJurisSTCoName;
  p_tax_lines_tbl.City(ind)      := inv_out_rec.fJurisSTCiName;

  p_tax_lines_tbl.global_attribute_category(ind) := 'VERTEX';
        p_tax_lines_tbl.global_attribute2(ind) := NULL;
        p_tax_lines_tbl.global_attribute4(ind) := NULL;
        p_tax_lines_tbl.global_attribute6(ind) := NULL;

      if(l_document_type in ('TAX_ONLY_CREDIT_MEMO','TAX_ONLY_ADJUSTMENT')) then
  p_tax_lines_tbl.tax_only_line_flag(ind)  := 'Y';
      else
        p_tax_lines_tbl.tax_only_line_flag(ind)  := 'N';
      end if;

  IF J=1 then /*Case for State*/
    p_tax_lines_tbl.Tax(ind)       := 'STATE';
    p_tax_lines_tbl.tax_amount(ind)       := line_out_tab(1).fPriStTaxAmt;
    p_tax_lines_tbl.unrounded_tax_amount(ind)   := line_out_tab(1).fPriStTaxAmt;
    p_tax_lines_tbl.TAX_CURR_TAX_AMOUNT(ind)    := line_out_tab(1).fPriStTaxAmt*p_currency_tab(1).exchange_rate;
    p_tax_lines_tbl.tax_rate_percentage(ind)    := state_tax_rate;   -- Bug 5162537
    p_tax_lines_tbl.taxable_amount(ind)      := line_out_tab(1).fPriStTaxedAmt;
           IF nvl(line_out_tab(1).fPriStExmtAmt, 0) <> 0 THEN
        IF (line_out_tab(1).fTransExtendedAmt <> 0) then
                 p_tax_lines_tbl.exempt_rate_modifier(ind) := line_out_tab(1).fPriStExmtAmt/line_out_tab(1).fTransExtendedAmt;
                 p_tax_lines_tbl.exempt_certificate_number(ind)  := line_out_tab(1).fPriCustExmtCrtfNum;
              ELSE
                 p_tax_lines_tbl.exempt_rate_modifier(ind) := 0;
                 p_tax_lines_tbl.exempt_certificate_number(ind)  := NULL;
              END IF;
          ELSE
             p_tax_lines_tbl.exempt_rate_modifier(ind) := 0;
             p_tax_lines_tbl.exempt_certificate_number(ind) := NULL;
          END IF;
    p_tax_lines_tbl.exempt_reason(ind)     :=line_out_tab(1).fPriStExmtRsnCd;
  ELSIF J=2 then
             p_tax_lines_tbl.Tax(ind)       := 'COUNTY';
    p_tax_lines_tbl.tax_amount(ind)       :=(county_tax_amount +
                        sec_county_tax_amount +
                                                add_county_tax_amount);
    p_tax_lines_tbl.unrounded_tax_amount(ind)   := county_tax_amount +
                    sec_county_tax_amount +
                                                  add_county_tax_amount;
    p_tax_lines_tbl.TAX_CURR_TAX_AMOUNT(ind)    := p_tax_lines_tbl.tax_amount(ind) *p_currency_tab(1).exchange_rate;
    p_tax_lines_tbl.tax_rate_percentage(ind)    := county_tax_rate +
                                                                    sec_county_tax_rate +
                                                        add_county_tax_rate;
    p_tax_lines_tbl.taxable_amount(ind)      := line_out_tab(1).fPriCoTaxedAmt;
           IF nvl(line_out_tab(1).fPriCoExmtAmt, 0) <> 0 THEN
        IF (line_out_tab(1).fTransExtendedAmt <> 0) then
                 p_tax_lines_tbl.exempt_rate_modifier(ind) := line_out_tab(1).fPriCoExmtAmt/line_out_tab(1).fTransExtendedAmt;
                 p_tax_lines_tbl.exempt_certificate_number(ind)   := line_out_tab(1).fPriCustExmtCrtfNum;
             ELSE
                p_tax_lines_tbl.exempt_rate_modifier(ind) := 0;
                p_tax_lines_tbl.exempt_certificate_number(ind)  := NULL;
             END IF;
          ELSE
             p_tax_lines_tbl.exempt_rate_modifier(ind) := 0;
             p_tax_lines_tbl.exempt_certificate_number(ind)  := NULL;
          END IF;
    p_tax_lines_tbl.exempt_reason(ind)    :=line_out_tab(1).fPriCoExmtRsnCd;
  ELSIF J=3 then

                 p_tax_lines_tbl.Tax(ind)       := 'CITY';
    p_tax_lines_tbl.tax_amount(ind)       := (city_tax_amount +
                    sec_city_tax_amount +
                                                                    add_city_tax_amount);
    p_tax_lines_tbl.unrounded_tax_amount(ind)   := city_tax_amount +
                    sec_city_tax_amount +
                                                                    add_city_tax_amount;
    p_tax_lines_tbl.tax_curr_tax_amount(ind)    := p_tax_lines_tbl.unrounded_tax_amount(ind)*p_currency_tab(1).exchange_rate;
    p_tax_lines_tbl.tax_rate_percentage(ind)    := city_tax_rate +
                    sec_city_tax_rate +
                                                                    add_city_tax_rate;
    p_tax_lines_tbl.taxable_amount(ind)      := line_out_tab(1).fPriCiTaxedAmt;
           IF nvl(line_out_tab(1).fPriCiExmtAmt, 0) <> 0 THEN
        IF (line_out_tab(1).fTransExtendedAmt <> 0) then
                 p_tax_lines_tbl.exempt_rate_modifier(ind) := line_out_tab(1).fPriCiExmtAmt/line_out_tab(1).fTransExtendedAmt;
                 p_tax_lines_tbl.exempt_certificate_number(ind)   := line_out_tab(1).fPriCustExmtCrtfNum;
             ELSE
                p_tax_lines_tbl.exempt_rate_modifier(ind) := 0;
                p_tax_lines_tbl.exempt_certificate_number(ind)  := NULL;
             END IF;
          ELSE
             p_tax_lines_tbl.exempt_rate_modifier(ind) := 0;
             p_tax_lines_tbl.exempt_certificate_number(ind)  := NULL;
          END IF;
    p_tax_lines_tbl.exempt_reason(ind)     :=line_out_tab(1).fPriCiExmtRsnCd;
        else null;
  END IF;

        delete from zx_jurisdictions_gt;
        GET_TAX_JUR_CODE (p_location_id                 ,
               p_tax_lines_tbl.Situs(ind)    ,
                    p_tax_lines_tbl.Tax(ind)      ,
                          l_regime_code            ,
                     inv_out_rec.fInvDate     ,
               x_tax_jurisdiction_code   ,
               l_return_status
              );

  p_tax_lines_tbl.tax_jurisdiction(ind)      := x_tax_jurisdiction_code;

        delete from zx_jurisdictions_gt;

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
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' line_out_tab(1).fPriCustExmtCrtfNum = '||
                line_out_tab(1).fPriCustExmtCrtfNum);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' p_tax_lines_tbl.exempt_certificate_number('||ind||') = '||
                p_tax_lines_tbl.exempt_certificate_number(ind));

           -- bug 6831713
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute_category('||ind||') = '|| p_tax_lines_tbl.global_attribute_category(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute2('||ind||') = '|| p_tax_lines_tbl.global_attribute2(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute4('||ind||') = '|| p_tax_lines_tbl.global_attribute4(ind));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_tax_lines_tbl.global_attribute6('||ind||') = '|| p_tax_lines_tbl.global_attribute6(ind));

        END IF;
   END LOOP;
  END IF;
  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
  END IF;

END TAX_RESULTS_PROCESSING;


PROCEDURE RESET_PARAMETERS(x_return_status OUT NOCOPY VARCHAR2) IS
 l_api_name           CONSTANT VARCHAR2(30) := 'RESET_PARAMETERS';
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;


    /*------------------------------------------------------
     | Initialize context_rec, inv_in_rec, and line_in_tab.|
     ------------------------------------------------------*/
    BEGIN
      ZX_TAX_VERTEX_QSU.QSUInitializeInvoice(context_rec,
                  inv_in_rec,
                  line_in_tab);

    EXCEPTION
        WHEN OTHERS THEN
            IF (g_level_exception >= g_current_runtime_level ) THEN
               FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_string :='Error in VERTEX API:'||to_char(SQLCODE)||SQLERRM;
     error_exception_handle(g_string);
     return;
    END;


    /*-----------------------------------------------------------
     | Set default value to the ARP_TAX_VERTEX_QSU.inv_in_rec|
     | and line_in_tab.            |
     -----------------------------------------------------------*/
    /* ARP_TAX_VERTEX_QSU.tQSUInvoiceRecord Record Type */

    inv_in_rec.fJurisSTGeoCd := NULL;
    inv_in_rec.fJurisSTStAbbrv := NULL;
    inv_in_rec.fJurisSTCoName := NULL;
    inv_in_rec.fJurisSTCiName := NULL;
    inv_in_rec.fJurisSTCiCmprssd := NULL;
    inv_in_rec.fJurisSTZipCd := NULL;
    inv_in_rec.fJurisSTCiSearchCd := NULL;
    inv_in_rec.fJurisSTInCi := NULL;
    inv_in_rec.fJurisSFGeoCd := NULL;
    inv_in_rec.fJurisSFStAbbrv := NULL;
    inv_in_rec.fJurisSFCoName := NULL;
    inv_in_rec.fJurisSFCiName := NULL;
    inv_in_rec.fJurisSFCiCmprssd := NULL;
    inv_in_rec.fJurisSFZipCd := NULL;
    inv_in_rec.fJurisSFCiSearchCd := NULL;
    inv_in_rec.fJurisSFInCi := NULL;
    inv_in_rec.fJurisOAGeoCd := NULL;
    inv_in_rec.fJurisOAStAbbrv := NULL;
    inv_in_rec.fJurisOACoName := NULL;
    inv_in_rec.fJurisOACiName := NULL;
    inv_in_rec.fJurisOACiCmprssd := NULL;
    inv_in_rec.fJurisOAZipCd := NULL;
    inv_in_rec.fJurisOACiSearchCd := NULL;
    inv_in_rec.fJurisOAInCi := NULL;
    inv_in_rec.fInvIdNum := NULL;
    inv_in_rec.fInvCntrlNum := NULL;
    inv_in_rec.fInvDate := NULL;
    inv_in_rec.fInvGrossAmt := NULL;
    inv_in_rec.fInvTotalTaxAmt := NULL;
    inv_in_rec.fInvNumLineItems := NULL;
    inv_in_rec.fTDMCustCd := NULL;
    inv_in_rec.fTDMCustClassCd := NULL;
    inv_in_rec.fCustTxblty := NULL;
    inv_in_rec.fTDMCompCd := NULL;
    inv_in_rec.fTDMDivCd := NULL;
    inv_in_rec.fTDMStoreCd := NULL;

    /* ARP_TAX_VERTEX_QSU.tQSULineItemTable Record Type */
    line_in_tab(1).fTransType := NULL;
    line_in_tab(1).fTransSubType := NULL;
    line_in_tab(1).fTransCd := NULL;
    line_in_tab(1).fTransDate := NULL;
    line_in_tab(1).fTransExtendedAmt := NULL;
    line_in_tab(1).fTransQuantity := NULL;
    line_in_tab(1).fTransTotalTaxAmt := NULL;
    line_in_tab(1).fTransCombinedRate := NULL;
    line_in_tab(1).fTransUserArea := NULL;
    line_in_tab(1).fTransStatusCd := NULL;
    line_in_tab(1).fTDMProdCd := NULL;
    line_in_tab(1).fTDMProdRptngCd := NULL;
    line_in_tab(1).fProdTxblty := NULL;
    line_in_tab(1).fPriTaxingJuris := NULL;
    line_in_tab(1).fPriCustExmtCrtfNum := NULL;
    line_in_tab(1).fPriStTxblty := NULL;
    line_in_tab(1).fPriStTaxType := NULL;
    line_in_tab(1).fPriStTaxedAmt := NULL;
    line_in_tab(1).fPriStExmtAmt := NULL;
    line_in_tab(1).fPriStExmtRsnCd := NULL;
    line_in_tab(1).fPriStNonTxblAmt := NULL;
    line_in_tab(1).fPriStNonTxblRsnCd := NULL;
    line_in_tab(1).fPriStRate := NULL;
    line_in_tab(1).fPriStRateEffDate := NULL;
    line_in_tab(1).fPriStRateType := NULL;
    line_in_tab(1).fPriStTaxAmt := NULL;
    line_in_tab(1).fPriStTaxIncluded := NULL;
    line_in_tab(1).fPriCoTxblty := NULL;
    line_in_tab(1).fPriCoTaxType := NULL;
    line_in_tab(1).fPriCoTaxedAmt := NULL;
    line_in_tab(1).fPriCoExmtAmt := NULL;
    line_in_tab(1).fPriCoExmtRsnCd := NULL;
    line_in_tab(1).fPriCoNonTxblAmt := NULL;
    line_in_tab(1).fPriCoNonTxblRsnCd := NULL;
    line_in_tab(1).fPriCoRate := NULL;
    line_in_tab(1).fPriCoRateEffDate := NULL;
    line_in_tab(1).fPriCoRateType := NULL;
    line_in_tab(1).fPriCoTaxAmt := NULL;
    line_in_tab(1).fPriCoTaxIncluded := NULL;
    line_in_tab(1).fPriCoTxblty := NULL;
    line_in_tab(1).fPriCiTxblty := NULL;
    line_in_tab(1).fPriCiTaxType := NULL;
    line_in_tab(1).fPriCiTaxedAmt := NULL;
    line_in_tab(1).fPriCiExmtAmt := NULL;
    line_in_tab(1).fPriCiExmtRsnCd := NULL;
    line_in_tab(1).fPriCiNonTxblAmt := NULL;
    line_in_tab(1).fPriCiNonTxblRsnCd := NULL;
    line_in_tab(1).fPriCiRate := NULL;
    line_in_tab(1).fPriCiRateEffDate := NULL;
    line_in_tab(1).fPriCiRateType := NULL;
    line_in_tab(1).fPriCiTaxAmt := NULL;
    line_in_tab(1).fPriCiTaxIncluded := NULL;
    line_in_tab(1).fPriDiTxblty := NULL;
    line_in_tab(1).fPriDiTaxType := NULL;
    line_in_tab(1).fPriDiTaxedAmt := NULL;
    line_in_tab(1).fPriDiExmtAmt := NULL;
    line_in_tab(1).fPriDiExmtRsnCd := NULL;
    line_in_tab(1).fPriDiNonTxblAmt := NULL;
    line_in_tab(1).fPriDiNonTxblRsnCd := NULL;
    line_in_tab(1).fPriDiRate := NULL;
    line_in_tab(1).fPriDiRateEffDate := NULL;
    line_in_tab(1).fPriDiRateType := NULL;
    line_in_tab(1).fPriDiTaxAmt := NULL;
    line_in_tab(1).fPriDiTaxIncluded := NULL;
    line_in_tab(1).fPriDiAppliesTo := NULL;
    line_in_tab(1).fAddTaxingJuris := NULL;
    line_in_tab(1).fAddCustExmtCrtfNum := NULL;
    line_in_tab(1).fAddCoTxblty := NULL;
    line_in_tab(1).fAddCoTaxType := NULL;
    line_in_tab(1).fAddCoTaxedAmt := NULL;
    line_in_tab(1).fAddCoExmtAmt := NULL;
    line_in_tab(1).fAddCoExmtRsnCd := NULL;
    line_in_tab(1).fAddCoNonTxblAmt := NULL;
    line_in_tab(1).fAddCoNonTxblRsnCd := NULL;
    line_in_tab(1).fAddCoRate := NULL;
    line_in_tab(1).fAddCoRateEffDate := NULL;
    line_in_tab(1).fAddCoRateType := NULL;
    line_in_tab(1).fAddCoTaxAmt := NULL;
    line_in_tab(1).fAddCoTaxIncluded := NULL;
    line_in_tab(1).fAddCiTxblty := NULL;
    line_in_tab(1).fAddCiTaxType := NULL;
    line_in_tab(1).fAddCiTaxedAmt := NULL;
    line_in_tab(1).fAddCiExmtAmt := NULL;
    line_in_tab(1).fAddCiExmtRsnCd := NULL;
    line_in_tab(1).fAddCiNonTxblAmt := NULL;
    line_in_tab(1).fAddCiNonTxblRsnCd := NULL;
    line_in_tab(1).fAddCiRate := NULL;
    line_in_tab(1).fAddCiRateEffDate := NULL;
    line_in_tab(1).fAddCiRateType := NULL;
    line_in_tab(1).fAddCiTaxAmt := NULL;
    line_in_tab(1).fAddCiTaxIncluded := NULL;
    line_in_tab(1).fAddDiTxblty := NULL;
    line_in_tab(1).fAddDiTaxType := NULL;
    line_in_tab(1).fAddDiTaxedAmt := NULL;
    line_in_tab(1).fAddDiExmtAmt := NULL;
    line_in_tab(1).fAddDiExmtRsnCd := NULL;
    line_in_tab(1).fAddDiNonTxblAmt := NULL;
    line_in_tab(1).fAddDiNonTxblRsnCd := NULL;
    line_in_tab(1).fAddDiRate := NULL;
    line_in_tab(1).fAddDiRateEffDate := NULL;
    line_in_tab(1).fAddDiRateType := NULL;
    line_in_tab(1).fAddDiTaxAmt := NULL;
    line_in_tab(1).fAddDiTaxIncluded := NULL;
    line_in_tab(1).fAddDiAppliesTo := NULL;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;
END RESET_PARAMETERS;

PROCEDURE CREATE_TAX_LINE(
p_tax     in VARCHAR2,
p_amount  in number,
x_return_status OUT NOCOPY VARCHAR2) IS

 l_api_name           CONSTANT VARCHAR2(30) := 'CREATE_TAX_LINE';
 l_precision             number;
 l_mau                   number;
 l_rounding_rule         varchar2(30);
 l_error_buffer          varchar2(200);
 l_return_Status         VARCHAR2(30);
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
                         ,'TAX_ONLY_ADJUSTMENT'
                         ,'INVOICE_ADJUSTMENT') THEN

      l_line_level_action:='CREATE';

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
         l_line_level_action:='CREATE';
      ELSE
         l_line_level_action:='TAX_LINE_DELETE';
         l_document_type := 'TAX_LINE_SYNC';
      END IF;

      IF (p_tax='STATE') THEN
         g_TotalTaxAmt := p_amount; -- Bug 6831713
   g_StTaxAmt := p_amount;
         g_CoTaxAmt := 0;
         g_CiTaxAmt := 0;
      ELSIF (p_tax='COUNTY') THEN
         g_TotalTaxAmt := p_amount; -- Bug 6831713
   g_StTaxAmt := 0;
         g_CoTaxAmt := p_amount;
         g_CiTaxAmt := 0;
      ELSIF (p_tax='CITY') THEN
         g_TotalTaxAmt := p_amount; -- Bug 6831713
   g_StTaxAmt := 0;
         g_CoTaxAmt := 0;
         g_CiTaxAmt := p_amount;
      ELSIF (p_tax='LOCATION') THEN -- Bug 6831713
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

   RESET_PARAMETERS(l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_exception >= g_current_runtime_level ) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      g_string :='Failed in RESET_PARAMETERS procedure';
      error_exception_handle(g_string);
      return;
   END IF;

   SET_PARAMETERS(l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF (g_level_exception >= g_current_runtime_level ) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_string :='Failed in SET_PARAMETERS procedure';
     error_exception_handle(g_string);
     return;
    END IF;

  CALCULATE_TAX(l_return_status);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF (g_level_exception >= g_current_runtime_level ) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_string :='Failed in CALCULATE_TAX procedure';
     error_exception_handle(g_string);
     return;
    END IF;

    IF (l_document_type = 'TAX_ONLY_ADJUSTMENT') AND pg_Line_char8_tab(I) <> 'Y' THEN
       null;
    ELSE
       WRITE_TO_VERTEX_REPOSITORY(l_return_status);
    END IF;

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF (g_level_exception >= g_current_runtime_level ) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     g_string :='Failed in WRITE_TO_VERTEX_REPOSITORY procedure';
     error_exception_handle(g_string);
     return;
    END IF;

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

 trx_line_dist_tbl          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl%type;
 event_class_rec            ZX_API_PUB.event_class_rec_type;
 l_return_status            VARCHAR2(30);
 l_APPLICATION_ID           NUMBER;
 l_ENTITY_CODE              VARCHAR2(20);
 l_EVENT_CLASS_CODE         VARCHAR2(20);
 l_TRX_ID                   NUMBER;
 l_TRX_LINE_ID              NUMBER;
 l_TRX_LEVEL_TYPE           VARCHAR2(20);
 l_neg_line_gt_exists       NUMBER;

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

   l_neg_line_gt_exists := 0;
   BEGIN
      SELECT 1
        INTO l_neg_line_gt_exists
        FROM zx_ptnr_neg_line_gt
       WHERE event_class_mapping_id = p_evnt_cls_mapping_id
         AND trx_id                 = p_transaction_id
         AND trx_line_id            = p_transaction_line_id
         AND trx_level_type         = p_trx_level_type;
   EXCEPTION
      WHEN OTHERS THEN
         l_neg_line_gt_exists := 0;
   END;

/* For given transaction line id, record already exists in zx_ptnr_neg_line_gt, then there is no need to recreate it */

   IF l_neg_line_gt_exists <> 0 THEN
      RETURN;
   END IF;

   BEGIN
      SELECT APPLICATION_ID,
             ENTITY_CODE      ,
             EVENT_CLASS_CODE,
             TRX_ID ,
             TRX_LINE_ID,
             TRX_LEVEL_TYPE
        INTO l_APPLICATION_ID,
             l_ENTITY_CODE      ,
             l_EVENT_CLASS_CODE,
             l_TRX_ID ,
             l_TRX_LINE_ID,
             l_TRX_LEVEL_TYPE
        FROM zx_lines_det_factors
       WHERE event_class_mapping_id  = p_evnt_cls_mapping_id
         AND   trx_id      = p_transaction_id
         AND  trx_line_id    = p_transaction_line_id
         AND   trx_level_type    = p_trx_level_type;
   EXCEPTION
      WHEN no_data_found THEN
         IF (g_level_exception >= g_current_runtime_level ) THEN
            FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         g_string :='No data found in zx_lines_det_factors ';
         error_exception_handle(g_string);
         RETURN;
   END;


/* Since, we need to pass the item line information associated to the
   tax line, populate the trx_line_dist_tbl and pass specific trx_line_id */
trx_line_dist_tbl.application_id(1)  :=l_APPLICATION_ID;
trx_line_dist_tbl.TRX_LINE_ID(1)  :=l_TRX_LINE_ID;
trx_line_dist_tbl.TRX_LEVEL_TYPE(1)  :=l_TRX_LEVEL_TYPE;

event_class_rec.APPLICATION_ID    :=l_APPLICATION_ID;
event_class_rec.ENTITY_CODE    :=l_ENTITY_CODE;
event_class_rec.EVENT_CLASS_CODE  :=l_EVENT_CLASS_CODE;
event_class_rec.TRX_ID      :=l_TRX_ID;
--event_class_rec.TRX_LINE_ID             :=l_TRX_LINE_ID;


  zx_r11i_tax_partner_pkg.copy_trx_line_for_ptnr_bef_upd
     (p_trx_line_dist_tbl       => trx_line_dist_tbl,
      p_event_class_rec         => event_class_rec,
      p_update_index            => 1,
      p_trx_copy_for_tax_update => 'Y' ,
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

l_index NUMBER;
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
     cache_table(l_index).document_type_id   = P_document_type_id and
     cache_table(l_index).transaction_id   = p_transaction_id and
     cache_table(l_index).transaction_line_id   = p_transaction_line_id) then

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Found in the Cache' );
     END IF;

     Return TRUE;
  end if;
 end loop;
     cache_index    :=cache_index+1;
     cache_table(cache_index).internal_organization_id  := p_internal_organization_id;
     cache_table(cache_index).document_type_id    := P_document_type_id;
     cache_table(cache_index).transaction_id    := p_transaction_id;
     cache_table(cache_index).transaction_line_id  := p_transaction_line_id;

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
                               , x_output_sync_tax_lines IN OUT NOCOPY zx_tax_partner_pkg.output_sync_tax_lines_tbl_type
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
                         ,'TAX_ONLY_ADJUSTMENT'
                         ,'INVOICE_ADJUSTMENT') THEN
      IF (p_tax = 'STATE') THEN
         l_state_tax_cnt := p_sync_tax_cnt;
      ELSIF(p_tax = 'COUNTY') THEN
         l_county_tax_cnt := p_sync_tax_cnt;
      ELSIF(p_tax = 'CITY') THEN
         l_city_tax_cnt := p_sync_tax_cnt;
      END IF;
      IF l_trx_line_context_changed THEN
         IF l_state_tax_cnt IS NOT NULL THEN
            x_output_sync_tax_lines(l_state_tax_cnt).TAX_RATE_PERCENTAGE  := line_out_tab(1).fPriStRate*100;
            x_output_sync_tax_lines(l_state_tax_cnt).TAXABLE_AMOUNT       := line_out_tab(1).fPriStTaxedAmt;
         END IF;
         IF l_county_tax_cnt IS NOT NULL THEN
            x_output_sync_tax_lines(l_county_tax_cnt).TAX_RATE_PERCENTAGE := line_out_tab(1).fPriCoRate*100;
            x_output_sync_tax_lines(l_county_tax_cnt).TAXABLE_AMOUNT      := line_out_tab(1).fPriCoTaxedAmt;
         END IF;
         IF l_city_tax_cnt IS NOT NULL THEN
            x_output_sync_tax_lines(l_city_tax_cnt).TAX_RATE_PERCENTAGE   := line_out_tab(1).fPriCiRate*100;
            x_output_sync_tax_lines(l_city_tax_cnt).TAXABLE_AMOUNT        := line_out_tab(1).fPriCiTaxedAmt;
         END IF;
         l_state_tax_cnt := null;
         l_county_tax_cnt := null;
         l_city_tax_cnt := null;
      ELSE
         RETURN;
      END IF;
   ELSE
      IF (p_tax = 'STATE') THEN
         x_output_sync_tax_lines(p_sync_tax_cnt).TAX_RATE_PERCENTAGE    := line_out_tab(1).fPriStRate*100;
         x_output_sync_tax_lines(p_sync_tax_cnt).TAXABLE_AMOUNT         := line_out_tab(1).fPriStTaxedAmt;
      ELSIF(p_tax = 'COUNTY') THEN
         x_output_sync_tax_lines(p_sync_tax_cnt).TAX_RATE_PERCENTAGE    := line_out_tab(1).fPriCoRate*100;
         x_output_sync_tax_lines(p_sync_tax_cnt).TAXABLE_AMOUNT         := line_out_tab(1).fPriCoTaxedAmt;
      ELSIF(p_tax = 'CITY') THEN
         x_output_sync_tax_lines(p_sync_tax_cnt).TAX_RATE_PERCENTAGE    := line_out_tab(1).fPriCiRate*100;
         x_output_sync_tax_lines(p_sync_tax_cnt).TAXABLE_AMOUNT         := line_out_tab(1).fPriCiTaxedAmt;
      END IF;
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'x_output_sync_tax_lines(p_sync_tax_cnt).TAX_RATE_PERCENTAGE : '||x_output_sync_tax_lines(p_sync_tax_cnt).TAX_RATE_PERCENTAGE);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'x_output_sync_tax_lines(p_sync_tax_cnt).TAXABLE_AMOUNT : '||x_output_sync_tax_lines(p_sync_tax_cnt).TAXABLE_AMOUNT);
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END POPULATE_SYNC_TAX_AMTS;

PROCEDURE SYNCHRONIZE_VERTEX_REPOSITORY
   (x_output_sync_tax_lines OUT NOCOPY zx_tax_partner_pkg.output_sync_tax_lines_tbl_type,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_messages_tbl          OUT NOCOPY ZX_TAX_PARTNER_PKG.messages_tbl_type) IS

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
l_internal_organization_id  ZX_SYNC_HDR_INPUT_V.internal_organization_id%type;
l_document_type_id    ZX_SYNC_HDR_INPUT_V.document_type_id%type;
l_transaction_id    ZX_SYNC_HDR_INPUT_V.transaction_id%type;
l_legal_entity_number    ZX_SYNC_HDR_INPUT_V.legal_entity_number%type;
l_establishment_number    ZX_SYNC_HDR_INPUT_V.establishment_number%type;  -- Bug 5139731
l_transaction_line_id           ZX_SYNC_TAX_LINES_INPUT_V.transaction_line_id%type;
l_count NUMBER;
l_event_type VARCHAR2(20);
l_write_record boolean;
l_event_class_code      VARCHAR2(20);
l_application_id        NUMBER;
l_entity_code    VARCHAR2(20);
l_trx_level_type  VARCHAR2(20);
l_regime_code    ZX_REGIMES_B.tax_regime_code%type;
l_amount  NUMBER;
l_found boolean;
l_debug_count  NUMBER;
l_api_name           CONSTANT VARCHAR2(30) := 'SYNCHRONIZE_VERTEX_REPOSITORY';
l_return_status VARCHAR2(30);
l_tax_code      VARCHAR2(100);
l_tax_type      VARCHAR2(100);
l_tax_flag      VARCHAR2(5);
l_trx_type_id   NUMBER;
l_org_id        NUMBER;

char_ctrx_id    VARCHAR2(32);
l_trx_number    VARCHAR2(150);
l_statements    VARCHAR2(2000);
cnt             NUMBER;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   err_count       := 0;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

 -- BUG7435393
   IF ZX_API_PUB.G_PUB_SRVC <> 'SYNCHRONIZE_TAX_REPOSITORY' THEN
   -- BUG7435393

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
      BEGIN
         SELECT count(*)
           INTO l_debug_count
           FROM zx_detail_tax_lines_gt;
      END;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         ' l_debug_count = ' || l_debug_count);
   END IF;

   OPEN tax_lines_to_be_processed;

   FETCH tax_lines_to_be_processed BULK COLLECT INTO
      SYNC_TAX_LINES.document_type_id    ,
      SYNC_TAX_LINES.transaction_id    ,
      SYNC_TAX_LINES.transaction_line_id  ,
      SYNC_TAX_LINES.trx_level_type           ,
      SYNC_TAX_LINES.country_code    ,
      SYNC_TAX_LINES.tax      ,
      SYNC_TAX_LINES.situs      ,
      SYNC_TAX_LINES.tax_jurisdiction    ,
      SYNC_TAX_LINES.tax_currency_code          ,
      SYNC_TAX_LINES.tax_amount                 ,
      SYNC_TAX_LINES.tax_curr_tax_amount  ,
      SYNC_TAX_LINES.tax_rate_percentage  ,
      SYNC_TAX_LINES.taxable_amount    ,
      SYNC_TAX_LINES.exempt_rate_modifier  ,
      SYNC_TAX_LINES.exempt_reason    ,
      SYNC_TAX_LINES.tax_only_line_flag  ,
      SYNC_TAX_LINES.inclusive_tax_line_flag  ,
      SYNC_TAX_LINES.use_tax_flag    ,
      SYNC_TAX_LINES.ebiz_override_flag  ,
      SYNC_TAX_LINES.user_override_flag  ,
      SYNC_TAX_LINES.last_manual_entry  ,
      SYNC_TAX_LINES.manually_entered_flag  ,
      SYNC_TAX_LINES.cancel_flag    ,
      SYNC_TAX_LINES.delete_flag
   LIMIT C_LINES_PER_COMMIT;

   BEGIN
      SELECT event_class_code
           , application_id
           , entity_code
        INTO l_event_class_code
           , l_application_id
           , l_entity_code
        FROM zx_evnt_cls_mappings
       WHERE EVENT_CLASS_MAPPING_ID = SYNC_TAX_LINES.document_type_id(1);
   END;
/***
           SELECT output_tax_classification_code , receivables_trx_type_id,
internal_organization_id into
           l_tax_code, l_trx_type_id, l_org_id
            FROM zx_lines_det_factors where
            application_id = l_application_id
            and entity_code = l_entity_code
            and event_class_code = l_event_class_code
            and trx_id = SYNC_TAX_LINES.transaction_id(1)
            and trx_line_id = SYNC_TAX_LINES.transaction_line_id(1)
            and trx_level_type = SYNC_TAX_LINES.trx_level_type(1);

            BEGIN
             select tax_type_code INTO l_tax_type -- from zx_taxes_b zx, zx_rates_b zr
               from zx_sco_taxes zx,   -- Changed from clause to use sco views not base tables
                    zx_sco_rates zr
       where zx.tax = zr.tax
             AND zr.tax_rate_code = l_tax_code
             AND rownum = 1;
            EXCEPTION
              WHEN others THEN
               l_tax_type := NULL;
            END;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_tax_code'||l_tax_code);
   END IF;

            SELECT tax_calculation_flag into l_tax_flag
            FROM  ra_cust_trx_types_all rtt
            WHERE rtt.cust_trx_type_id = l_trx_type_id
            AND rtt.org_id = l_org_id;

            IF l_tax_flag = 'N' AND l_tax_code is NULL THEN
             RETURN;
            ELSIF l_tax_type NOT IN ('SALES_TAX','LOCATION') THEN
             RETURN;
            ELSIF (l_tax_type = 'SALES_TAX' AND l_tax_code <> 'STATE' and  l_tax_code <> 'COUNTY' and l_tax_code <> 'CITY' and l_tax_code not like '%_COUNTY'
and l_tax_code not like '%_CITY') THEN
             RETURN;
            END IF;
***/

   I := 0;

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
         x_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
         g_string := 'There were more than one tax line';

         IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,
                          G_MODULE_NAME||l_api_name,
                          g_string);
      END IF;

         -- error_exception_handle(g_string);
         RETURN;
      END IF;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' l_event_type ' || l_event_type);
      END IF;

--*  /* Check whether there exists a row in ZX_PTNR_NEG_LINES_GT table for the transaction line.
--*     If not available then populate these values by calling the
--*      zx_r11i_tax_partner_pkg.COPY_TRX_LINE_FOR_PTNR_BEF_UPD.
--*  */

--*     l_found := check_in_cache(l_internal_organization_id,
--*                        SYNC_TAX_LINES.document_type_id(sync_tax_cnt),
--*     SYNC_TAX_LINES.transaction_id(sync_tax_cnt),
--*     SYNC_TAX_LINES.transaction_line_id(sync_tax_cnt));

      IF NOT pg_trx_id_tab.exists(I) THEN
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
            pg_trx_line_id_tab(I) := SYNC_TAX_LINES.transaction_line_id(sync_tax_cnt);
      END IF;

      IF (l_event_type='TAX_LINE_UPDATE') THEN
         BEGIN
            SELECT tax_amount
             INTO l_amount
              FROM ZX_PTNR_NEG_TAX_LINE_GT
             WHERE document_type_id = SYNC_TAX_LINES.document_type_id(sync_tax_cnt)
               AND trx_id           = SYNC_TAX_LINES.transaction_id(sync_tax_cnt)
         AND trx_line_id      = SYNC_TAX_LINES.transaction_line_id(sync_tax_cnt)
         AND country_code      = SYNC_TAX_LINES.country_code(sync_tax_cnt)
         AND tax        = SYNC_TAX_LINES.tax(sync_tax_cnt)
         AND situs            = SYNC_TAX_LINES.situs(sync_tax_cnt);
         END;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               ' l_amount         ' || l_amount);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               ' SYNC_TAX_LINES.tax_amount(sync_tax_cnt)         ' || SYNC_TAX_LINES.tax_amount(sync_tax_cnt));
         END IF;

   create_tax_line(SYNC_TAX_LINES.tax(sync_tax_cnt),-1*l_amount,l_return_status);
   create_tax_line(SYNC_TAX_LINES.tax(sync_tax_cnt),SYNC_TAX_LINES.tax_amount(sync_tax_cnt),l_return_status);
   l_write_record:=true;

      ELSIF(l_event_type='TAX_LINE_DELETE')then
/*
            select tax_amount
              into l_amount
              from ZX_PTNR_NEG_TAX_LINE_GT
             where trx_id = SYNC_TAX_LINES.transaction_id(sync_tax_cnt) and
             trx_line_id  = SYNC_TAX_LINES.transaction_line_id(sync_tax_cnt);
*/

         create_tax_line(SYNC_TAX_LINES.tax(sync_tax_cnt),-1*SYNC_TAX_LINES.tax_amount(sync_tax_cnt),l_return_status);
         l_write_record:=false;

      ELSIF (l_event_type='TAX_LINE_CREATE') THEN
            create_tax_line(SYNC_TAX_LINES.tax(sync_tax_cnt),SYNC_TAX_LINES.tax_amount(sync_tax_cnt),l_return_status);
            l_write_record:=true;
      END IF;

      IF (l_write_record) THEN
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

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'x_output_sync_tax_lines(sync_tax_cnt).internal_organization_id = ' || x_output_sync_tax_lines(sync_tax_cnt).internal_organization_id);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'x_output_sync_tax_lines(sync_tax_cnt).transaction_line_id = ' || x_output_sync_tax_lines(sync_tax_cnt).transaction_line_id);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'x_output_sync_tax_lines(sync_tax_cnt).trx_level_type = ' || x_output_sync_tax_lines(sync_tax_cnt).trx_level_type);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'x_output_sync_tax_lines(sync_tax_cnt).tax = ' || x_output_sync_tax_lines(sync_tax_cnt).tax);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'x_output_sync_tax_lines(sync_tax_cnt).SITUS = ' || x_output_sync_tax_lines(sync_tax_cnt).SITUS);
    END IF;

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

     /*UPDATE ARP_TAX_VERTEX_AUDIT
     SET INVNO = (SELECT TRANSACTION_NUMBER
                  FROM ZX_SYNC_HDR_INPUT_V)
     WHERE TRANSUSERAREA = (SELECT TRANSACTION_ID
                            FROM ZX_SYNC_HDR_INPUT_V);*/

     BEGIN
       SELECT TRANSACTION_NUMBER, TO_CHAR(TRANSACTION_ID)
       INTO l_trx_number, char_ctrx_id
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
     l_statements := 'UPDATE ZX_TAX_VERTEX_AUDIT '||
                     'SET INVNO = :1' ||
                     ' WHERE TRANSUSERAREA = :2 ';
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_statements ==' || l_statements);
     END IF;
     EXECUTE IMMEDIATE l_statements using l_trx_number,char_ctrx_id ;
     cnt:= SQL%ROWCOUNT;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updated Rows in vertex table == ' || to_char(SQL%ROWCOUNT));
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'ZX_TAX_VERTEX_AUDIT is updated');
     END IF;

   END IF;


   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END SYNCHRONIZE_VERTEX_REPOSITORY;

/* Bug 5200373: Restructured the code to accomodate the header level deletions */
PROCEDURE GLOBAL_DOCUMENT_UPDATE
  (x_transaction_rec       IN         zx_tax_partner_pkg.trx_rec_type,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_messages_tbl          OUT NOCOPY ZX_TAX_PARTNER_PKG.messages_tbl_type) is

 l_cnt_of_options_gt    NUMBER;
 l_cnt_of_hdr_extns_gt  NUMBER;
 l_cnt_of_line_extns_gt NUMBER;
 l_cnt_of_loc_info_gt   NUMBER;
 l_cnt_of_neg_line_gt   NUMBER;
 l_cnt_of_det_factors   NUMBER;
 l_cnt_of_trx_hdr_gt    NUMBER; -- 9252613
 l_statements    VARCHAR2(2000); -- 9252613
 l_return_status        VARCHAR2(30);
 l_api_name             CONSTANT VARCHAR2(30) := 'GLOBAL_DOCUMENT_UPDATE';
l_application_id  NUMBER;
l_entity_code     VARCHAR2(80);
l_event_class_code VARCHAR2(100);
l_trx_level_type   VARCHAR2(100);
l_trx_id           NUMBER;
l_trx_line_id      NUMBER;
l_trx_type_id      NUMBER;
l_org_id      NUMBER;
l_tax_code         VARCHAR2(100);
l_tax_type         VARCHAR2(100);
l_tax_flag         VARCHAR2(10);
--Bug 8532463
l_doc_amount       NUMBER;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   err_count       := 0;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;


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
	   -- 9252613
	   select count(*)
	   into l_cnt_of_trx_hdr_gt
	   from ZX_TRX_HEADERS_GT
     where trx_id = x_transaction_rec.transaction_id;

     IF l_cnt_of_trx_hdr_gt > 0 THEN
      l_statements := 'DELETE FROM ZX_TAX_VERTEX_AUDIT '||
                     ' WHERE TRANSUSERAREA = :1 ';
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_statements ==' || l_statements);
      END IF;
      EXECUTE IMMEDIATE l_statements using x_transaction_rec.transaction_id ;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Deleted Rows in vertex table == ' || to_char(SQL%ROWCOUNT));
      END IF;
      RETURN;
     END IF;
     -- 9252613
/***
       BEGIN
          SELECT
            distinct application_id,entity_code,event_class_code,
            trx_id,trx_level_type,trx_line_id
            INTO l_application_id,l_entity_code,l_event_class_code,
            l_trx_id,l_trx_level_type,l_trx_line_id
            FROM ZX_PRVDR_LINE_EXTNS_GT where rownum = 1;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN

         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'before tax code');
   END IF;
-- bug 6755603

           SELECT output_tax_classification_code,receivables_trx_type_id,
internal_organization_id into
           l_tax_code,l_trx_type_id, l_org_id
            FROM zx_lines_det_factors where
            application_id = l_application_id
            and entity_code = l_entity_code
            and event_class_code = l_event_class_code
            and trx_id = l_trx_id
            and trx_line_id = l_trx_line_id
            and trx_level_type = l_trx_level_type;

            BEGIN
             select tax_type_code INTO l_tax_type -- from zx_taxes_b zx, zx_rates_b zr
               from zx_sco_taxes zx,   -- Changed from clause to use sco views not base tables
                    zx_sco_rates zr
       where zx.tax = zr.tax
             AND zr.tax_rate_code = l_tax_code
             AND rownum = 1;
            EXCEPTION
              WHEN others THEN
               l_tax_type := NULL;
            END;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_tax_code'||l_tax_code);
   END IF;

            SELECT tax_calculation_flag into l_tax_flag
            FROM  ra_cust_trx_types_all rtt
            WHERE rtt.cust_trx_type_id = l_trx_type_id
            AND rtt.org_id = l_org_id;

            IF l_tax_flag = 'N' AND l_tax_code is NULL THEN
             RETURN;
            ELSIF l_tax_type NOT IN ('SALES_TAX','LOCATION') THEN
             RETURN;
            ELSIF (l_tax_type = 'SALES_TAX' AND l_tax_code <> 'STATE' and  l_tax_code <> 'COUNTY' and l_tax_code <> 'CITY' and l_tax_code not like '%_COUNTY'
and l_tax_code not like '%_CITY') THEN
             RETURN;
            END IF;

       EXCEPTION WHEN OTHERS THEN
          null;
       END;
***/
   BEGIN
     --Bug 8532463
     SELECT trx_line_id,
            ship_to_location_id,
            bill_to_location_id,
            adjusted_doc_trx_id,
            adjusted_doc_line_id,
            adjusted_doc_trx_level_type,
            decode(adjusted_doc_application_id,
                        222,decode(adjusted_doc_event_class_code,
                                          'INVOICE', 4,
                                          'DEBIT_MEMO', 5,
                                          'CREDIT_MEMO', 6,
                                           NULL
                                  )
                        ,NULL) adjusted_doc_document_type_id
     BULK COLLECT INTO pg_trx_line_id_tab,
                       pg_ship_to_loc_id_tab,
                       pg_bill_to_loc_id_tab,
                       pg_adj_doc_trx_id_tab,
                       pg_adj_doc_line_id_tab,
                       pg_adj_doc_trx_lev_type_tab,
                       pg_adj_doc_doc_type_id_tab
       FROM ZX_PTNR_NEG_LINE_GT
      WHERE event_class_mapping_id = x_transaction_rec.document_type_id
        AND trx_id                 = x_transaction_rec.transaction_id;
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
   --Bug 8532463
   -- Call Set Document Type

   SELECT SUM(ABS(line_amt))
     INTO l_doc_amount
     FROM ZX_PTNR_NEG_LINE_GT
    WHERE event_class_mapping_id = x_transaction_rec.document_type_id
      AND trx_id                 = x_transaction_rec.transaction_id;

   SET_DOCUMENT_TYPE(l_document_type,
                     x_transaction_rec.transaction_id,
                     l_doc_amount,
                     'NEGATE',
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

   FOR cnt IN 1..nvl(pg_trx_line_id_tab.last, 0)
   LOOP
      I := cnt;
      l_line_level_action := 'NEGATE';
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
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END GLOBAL_DOCUMENT_UPDATE;


PROCEDURE DISPLAY_OUTPUT
        (p_type                   IN VARCHAR2) IS
l_api_name           CONSTANT VARCHAR2(30) := 'DISPLAY_OUTPUT';
BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        IF (p_type = 'O') THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'*** Dumping Output ***');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'*** Dumping Input ***');
        END IF;
        IF context_rec.fGetJurisNames = TRUE THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fGetJurisNames = TRUE');
        ELSIF context_rec.fGetJurisNames = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fGetJurisNames = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fGetJurisNames = NULL');
        END IF;

        IF context_rec.fCaseSensitive = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fCaseSensitive = TRUE');
        ELSIF context_rec.fCaseSensitive = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fCaseSensitive = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fCaseSensitive = NULL');
        END IF;

    IF (p_type = 'O') THEN
        /*-----------------------------------------------------------
         | Dumping ARP_TAX_VERTEX_QSU.tQSUInvoiceRecord Record Type |
         -----------------------------------------------------------*/
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'*** Dumping tQSUInvoiceRecord Record Type***');

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTGeoCd = '||to_char(inv_out_rec.fJurisSTGeoCd));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTStAbbrv = '||inv_out_rec.fJurisSTStAbbrv);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTCoName = '||inv_out_rec.fJurisSTCoName);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTCiName = '||inv_out_rec.fJurisSTCiName);

        IF inv_out_rec.fJurisSTCiCmprssd = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTCiCmprssd = TRUE');
        ELSIF inv_out_rec.fJurisSTCiCmprssd = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTCiCmprssd = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTCiCmprssd = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTZipCd = '||inv_out_rec.fJurisSTZipCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTCiSearchCd = '||inv_out_rec.fJurisSTCiSearchCd);

        IF inv_out_rec.fJurisSTInCi = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTInCi = TRUE');
        ELSIF inv_out_rec.fJurisSTInCi = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTInCi = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTInCi = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFGeoCd  = '||to_char(inv_out_rec.fJurisSFGeoCd));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFStAbbrv = '||inv_out_rec.fJurisSFStAbbrv);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFCoName = '||inv_out_rec.fJurisSFCoName);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFCiName = '||inv_out_rec.fJurisSFCiName);

        IF inv_out_rec.fJurisSFCiCmprssd = TRUE THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFCiCmprssd = TRUE');
        ELSIF inv_out_rec.fJurisSFCiCmprssd = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFCiCmprssd = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFCiCmprssd = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFZipCd = '||inv_out_rec.fJurisSFZipCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFCiSearchCd = '||inv_out_rec.fJurisSFCiSearchCd);

        IF inv_out_rec.fJurisSFInCi = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFInCi = TRUE');
        ELSIF inv_out_rec.fJurisSFInCi = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFInCi = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFInCi = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOAGeoCd = '||to_char(inv_out_rec.fJurisOAGeoCd));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOAStAbbrv = '||inv_out_rec.fJurisOAStAbbrv);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOACoName = '||inv_out_rec.fJurisOACoName);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOACiName = '||inv_out_rec.fJurisOACiName);

        IF inv_out_rec.fJurisOACiCmprssd = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOACiCmprssd = TRUE');
        ELSIF inv_out_rec.fJurisOACiCmprssd = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOACiCmprssd = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOACiCmprssd = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOAZipCd = '||inv_out_rec.fJurisOAZipCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOACiSearchCd = '||inv_out_rec.fJurisOACiSearchCd);

        IF inv_out_rec.fJurisOAInCi = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOAInCi = TRUE');
        ELSIF inv_out_rec.fJurisOAInCi = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOAInCi = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOAInCi = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fInvIdNum = '||inv_out_rec.fInvIdNum);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fInvCntrlNum = '||inv_out_rec.fInvCntrlNum);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fInvDate = '||inv_out_rec.fInvDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fInvGrossAmt = '||to_char(inv_out_rec.fInvGrossAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fInvTotalTaxAmt = '||to_char(inv_out_rec.fInvTotalTaxAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fInvNumLineItems = '||inv_out_rec.fInvNumLineItems);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTDMCustCd = '||inv_out_rec.fTDMCustCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTDMCustClassCd = '||inv_out_rec.fTDMCustClassCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fCustTxblty = '||inv_out_rec.fCustTxblty);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTDMCompCd = '||inv_out_rec.fTDMCompCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTDMDivCd = '||inv_out_rec.fTDMDivCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTDMStoreCd = '||inv_out_rec.fTDMStoreCd);

        /*------------------------------------------------------------
         | Dumping ARP_TAX_VERTEX_QSU.tQSULineItemTable Record Type  |
         ------------------------------------------------------------*/
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'***Dumping tQSULineItemTable Record Type***');
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransType = '||to_char(line_out_tab(1).fTransType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransSubType = '||to_char(line_out_tab(1).fTransSubType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransCd = '||to_char(line_out_tab(1).fTransCd));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransDate = '||line_out_tab(1).fTransDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransExtendedAmt = '||
            to_char(line_out_tab(1).fTransExtendedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransQuantity = '||
            to_char(line_out_tab(1).fTransQuantity));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransTotalTaxAmt = '||
            to_char(line_out_tab(1).fTransTotalTaxAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransCombinedRate = '||
          to_char(line_out_tab(1).fTransCombinedRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransUserArea = '||line_out_tab(1).fTransUserArea);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransStatusCd = '||
          to_char(line_out_tab(1).fTransStatusCd));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTDMProdCd = '||line_out_tab(1).fTDMProdCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTDMProdRptngCd = '||line_out_tab(1).fTDMProdRptngCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fProdTxblty = '||to_char(line_out_tab(1).fProdTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriTaxingJuris = '||
          to_char(line_out_tab(1).fPriTaxingJuris));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCustExmtCrtfNum = '||
          line_out_tab(1).fPriCustExmtCrtfNum);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStTxblty = '||to_char(line_out_tab(1).fPriStTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStTaxType = '||to_char(line_out_tab(1).fPriStTaxType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStTaxedAmt = '||
          to_char(line_out_tab(1).fPriStTaxedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStExmtAmt = '||to_char(line_out_tab(1).fPriStExmtAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStExmtRsnCd = '||line_out_tab(1).fPriStExmtRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStNonTxblAmt = '||
          to_char(line_out_tab(1).fPriStNonTxblAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStNonTxblRsnCd = '||
          line_out_tab(1).fPriStNonTxblRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStRate = '||to_char(line_out_tab(1).fPriStRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStRateEffDate = '||line_out_tab(1).fPriStRateEffDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStRateType = '||
          to_char(line_out_tab(1).fPriStRateType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStTaxAmt = '||to_char(line_out_tab(1).fPriStTaxAmt));

        IF line_out_tab(1).fPriStTaxIncluded = TRUE THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStTaxIncluded = TRUE');
        ELSIF line_out_tab(1).fPriStTaxIncluded = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStTaxIncluded = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStTaxIncluded = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoTxblty = '||to_char(line_out_tab(1).fPriCoTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoTaxType = '||to_char(line_out_tab(1).fPriCoTaxType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoTaxedAmt = '||
          to_char(line_out_tab(1).fPriCoTaxedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoExmtAmt = '||to_char(line_out_tab(1).fPriCoExmtAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoExmtRsnCd = '||line_out_tab(1).fPriCoExmtRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoNonTxblAmt = '||
          to_char(line_out_tab(1).fPriCoNonTxblAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoNonTxblRsnCd = '||
          line_out_tab(1).fPriCoNonTxblRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoRate = '||to_char(line_out_tab(1).fPriCoRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoRateEffDate = '||line_out_tab(1).fPriCoRateEffDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoRateType = '||
          to_char(line_out_tab(1).fPriCoRateType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoTaxAmt = '||to_char(line_out_tab(1).fPriCoTaxAmt));

        IF line_out_tab(1).fPriCoTaxIncluded = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoTaxIncluded = TRUE');
        ELSIF line_out_tab(1).fPriCoTaxIncluded = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoTaxIncluded = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoTaxIncluded = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiTxblty = '||to_char(line_out_tab(1).fPriCiTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiTaxType = '||to_char(line_out_tab(1).fPriCiTaxType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiTaxedAmt = '||
          to_char(line_out_tab(1).fPriCiTaxedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiExmtAmt = '||to_char(line_out_tab(1).fPriCiExmtAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiExmtRsnCd = '||line_out_tab(1).fPriCiExmtRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiNonTxblAmt = '||
          to_char(line_out_tab(1).fPriCiNonTxblAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiNonTxblRsnCd = '||
          line_out_tab(1).fPriCiNonTxblRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiRate = '||to_char(line_out_tab(1).fPriCiRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiRateEffDate = '||line_out_tab(1).fPriCiRateEffDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiRateType = '||
          to_char(line_out_tab(1).fPriCiRateType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiTaxAmt = '||to_char(line_out_tab(1).fPriCiTaxAmt));

        IF line_out_tab(1).fPriCiTaxIncluded = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiTaxIncluded = TRUE');
        ELSIF line_out_tab(1).fPriCiTaxIncluded = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiTaxIncluded = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiTaxIncluded = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiTxblty = '||to_char(line_out_tab(1).fPriDiTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiTaxType = '||to_char(line_out_tab(1).fPriDiTaxType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiTaxedAmt = '||
          to_char(line_out_tab(1).fPriDiTaxedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiExmtAmt = '||to_char(line_out_tab(1).fPriDiExmtAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiExmtRsnCd = '||line_out_tab(1).fPriDiExmtRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiNonTxblAmt = '||
          to_char(line_out_tab(1).fPriDiNonTxblAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiNonTxblRsnCd = '||
          line_out_tab(1).fPriDiNonTxblRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiRate = '||to_char(line_out_tab(1).fPriDiRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiRateEffDate = '||line_out_tab(1).fPriDiRateEffDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiRateType = '||
          to_char(line_out_tab(1).fPriDiRateType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiTaxAmt = '||to_char(line_out_tab(1).fPriDiTaxAmt));

        IF line_out_tab(1).fPriDiTaxIncluded = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiTaxIncluded = TRUE');
        ELSIF line_out_tab(1).fPriDiTaxIncluded = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiTaxIncluded = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiTaxIncluded = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiAppliesTo = '||
          to_char(line_out_tab(1).fPriDiAppliesTo));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddTaxingJuris = '||
          to_char(line_out_tab(1).fAddTaxingJuris));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCustExmtCrtfNum = '||
            line_out_tab(1).fAddCustExmtCrtfNum);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoTxblty = '||to_char(line_out_tab(1).fAddCoTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoTaxType = '||to_char(line_out_tab(1).fAddCoTaxType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoTaxedAmt = '||
          to_char(line_out_tab(1).fAddCoTaxedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoExmtAmt = '||to_char(line_out_tab(1).fAddCoExmtAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoExmtRsnCd = '||line_out_tab(1).fAddCoExmtRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoNonTxblAmt = '||
          to_char(line_out_tab(1).fAddCoNonTxblAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoNonTxblRsnCd = '||
          line_out_tab(1).fAddCoNonTxblRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoRate = '||to_char(line_out_tab(1).fAddCoRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoRateEffDate = '||line_out_tab(1).fAddCoRateEffDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoRateType = '||
          to_char(line_out_tab(1).fAddCoRateType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoTaxAmt = '||to_char(line_out_tab(1).fAddCoTaxAmt));

        IF line_out_tab(1).fAddCoTaxIncluded = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoTaxIncluded = TRUE');
        ELSIF line_out_tab(1).fAddCoTaxIncluded = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoTaxIncluded = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoTaxIncluded = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiTxblty = '||to_char(line_out_tab(1).fAddCiTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiTaxType = '||to_char(line_out_tab(1).fAddCiTaxType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiTaxedAmt = '||
          to_char(line_out_tab(1).fAddCiTaxedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiExmtAmt = '||to_char(line_out_tab(1).fAddCiExmtAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiExmtRsnCd = '||line_out_tab(1).fAddCiExmtRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiNonTxblAmt = '||
          to_char(line_out_tab(1).fAddCiNonTxblAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiNonTxblRsnCd = '||
          line_out_tab(1).fAddCiNonTxblRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiRate = '||to_char(line_out_tab(1).fAddCiRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiRateEffDate = '||line_out_tab(1).fAddCiRateEffDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiRateType = '||
          to_char(line_out_tab(1).fAddCiRateType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiTaxAmt = '||to_char(line_out_tab(1).fAddCiTaxAmt));

        IF line_out_tab(1).fAddCiTaxIncluded = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiTaxIncluded = TRUE');
        ELSIF line_out_tab(1).fAddCiTaxIncluded = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiTaxIncluded = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiTaxIncluded = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiTxblty = '||to_char(line_out_tab(1).fAddDiTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiTaxType = '||to_char(line_out_tab(1).fAddDiTaxType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiTaxedAmt = '||
          to_char(line_out_tab(1).fAddDiTaxedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiExmtAmt = '||to_char(line_out_tab(1).fAddDiExmtAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiExmtRsnCd = '||line_out_tab(1).fAddDiExmtRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiNonTxblAmt = '||
          to_char(line_out_tab(1).fAddDiNonTxblAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiNonTxblRsnCd = '||
          line_out_tab(1).fAddDiNonTxblRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiRate = '||to_char(line_out_tab(1).fAddDiRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiRateEffDate = '||line_out_tab(1).fAddDiRateEffDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiRateType = '||
          to_char(line_out_tab(1).fAddDiRateType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiTaxAmt = '||to_char(line_out_tab(1).fAddDiTaxAmt));

        IF line_out_tab(1).fAddDiTaxIncluded = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiTaxIncluded = TRUE');
        ELSIF line_out_tab(1).fAddDiTaxIncluded = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiTaxIncluded = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiTaxIncluded = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiAppliesTo = '|| to_char(line_out_tab(1).fAddDiAppliesTo));

    ELSIF (p_type = 'I') THEN

        /*-----------------------------------------------------------
         | Dumping ARP_TAX_VERTEX_QSU.tQSUInvoiceRecord Record Type |
         -----------------------------------------------------------*/
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'*** Dumping tQSUInvoiceRecord Record Type***');

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTGeoCd = '||to_char(inv_in_rec.fJurisSTGeoCd));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTStAbbrv = '||inv_in_rec.fJurisSTStAbbrv);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTCoName = '||inv_in_rec.fJurisSTCoName);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTCiName = '||inv_in_rec.fJurisSTCiName);

        IF inv_in_rec.fJurisSTCiCmprssd = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTCiCmprssd = TRUE');
        ELSIF inv_in_rec.fJurisSTCiCmprssd = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTCiCmprssd = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTCiCmprssd = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTZipCd = '||inv_in_rec.fJurisSTZipCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTCiSearchCd = '||inv_in_rec.fJurisSTCiSearchCd);

        IF inv_in_rec.fJurisSTInCi = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTInCi = TRUE');
        ELSIF inv_in_rec.fJurisSTInCi = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTInCi = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSTInCi = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFGeoCd  = '||to_char(inv_in_rec.fJurisSFGeoCd));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFStAbbrv = '||inv_in_rec.fJurisSFStAbbrv);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFCoName = '||inv_in_rec.fJurisSFCoName);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFCiName = '||inv_in_rec.fJurisSFCiName);

        IF inv_in_rec.fJurisSFCiCmprssd = TRUE THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFCiCmprssd = TRUE');
        ELSIF inv_in_rec.fJurisSFCiCmprssd = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFCiCmprssd = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFCiCmprssd = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFZipCd = '||inv_in_rec.fJurisSFZipCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFCiSearchCd = '||inv_in_rec.fJurisSFCiSearchCd);

        IF inv_in_rec.fJurisSFInCi = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFInCi = TRUE');
        ELSIF inv_in_rec.fJurisSFInCi = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFInCi = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisSFInCi = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOAGeoCd = '||to_char(inv_in_rec.fJurisOAGeoCd));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOAStAbbrv = '||inv_in_rec.fJurisOAStAbbrv);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOACoName = '||inv_in_rec.fJurisOACoName);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOACiName = '||inv_in_rec.fJurisOACiName);

        IF inv_in_rec.fJurisOACiCmprssd = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOACiCmprssd = TRUE');
        ELSIF inv_in_rec.fJurisOACiCmprssd = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOACiCmprssd = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOACiCmprssd = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOAZipCd = '||inv_in_rec.fJurisOAZipCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOACiSearchCd = '||inv_in_rec.fJurisOACiSearchCd);

        IF inv_in_rec.fJurisOAInCi = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOAInCi = TRUE');
        ELSIF inv_in_rec.fJurisOAInCi = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOAInCi = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fJurisOAInCi = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fInvIdNum = '||inv_in_rec.fInvIdNum);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fInvCntrlNum = '||inv_in_rec.fInvCntrlNum);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fInvDate = '||inv_in_rec.fInvDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fInvGrossAmt = '||to_char(inv_in_rec.fInvGrossAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fInvTotalTaxAmt = '||to_char(inv_in_rec.fInvTotalTaxAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fInvNumLineItems = '||inv_in_rec.fInvNumLineItems);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTDMCustCd = '||inv_in_rec.fTDMCustCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTDMCustClassCd = '||inv_in_rec.fTDMCustClassCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fCustTxblty = '||inv_in_rec.fCustTxblty);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTDMCompCd = '||inv_in_rec.fTDMCompCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTDMDivCd = '||inv_in_rec.fTDMDivCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTDMStoreCd = '||inv_in_rec.fTDMStoreCd);

        /*------------------------------------------------------------
         | Dumping ARP_TAX_VERTEX_QSU.tQSULineItemTable Record Type  |
         ------------------------------------------------------------*/
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'***Dumping tQSULineItemTable Record Type***');
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransType = '||to_char(line_in_tab(1).fTransType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransSubType = '||to_char(line_in_tab(1).fTransSubType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransCd = '||to_char(line_in_tab(1).fTransCd));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransDate = '||line_in_tab(1).fTransDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransExtendedAmt = '||
            to_char(line_in_tab(1).fTransExtendedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransQuantity = '||
            to_char(line_in_tab(1).fTransQuantity));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransTotalTaxAmt = '||
            to_char(line_in_tab(1).fTransTotalTaxAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransCombinedRate = '||
          to_char(line_in_tab(1).fTransCombinedRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransUserArea = '||line_in_tab(1).fTransUserArea);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTransStatusCd = '||
          to_char(line_in_tab(1).fTransStatusCd));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTDMProdCd = '||line_in_tab(1).fTDMProdCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fTDMProdRptngCd = '||line_in_tab(1).fTDMProdRptngCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fProdTxblty = '||to_char(line_in_tab(1).fProdTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriTaxingJuris = '||
          to_char(line_in_tab(1).fPriTaxingJuris));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCustExmtCrtfNum = '||
          line_in_tab(1).fPriCustExmtCrtfNum);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStTxblty = '||to_char(line_in_tab(1).fPriStTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStTaxType = '||to_char(line_in_tab(1).fPriStTaxType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStTaxedAmt = '||
          to_char(line_in_tab(1).fPriStTaxedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStExmtAmt = '||to_char(line_in_tab(1).fPriStExmtAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStExmtRsnCd = '||line_in_tab(1).fPriStExmtRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStNonTxblAmt = '||
          to_char(line_in_tab(1).fPriStNonTxblAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStNonTxblRsnCd = '||
          line_in_tab(1).fPriStNonTxblRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStRate = '||to_char(line_in_tab(1).fPriStRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStRateEffDate = '||line_in_tab(1).fPriStRateEffDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStRateType = '||
          to_char(line_in_tab(1).fPriStRateType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStTaxAmt = '||to_char(line_in_tab(1).fPriStTaxAmt));

        IF line_in_tab(1).fPriStTaxIncluded = TRUE THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStTaxIncluded = TRUE');
        ELSIF line_in_tab(1).fPriStTaxIncluded = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStTaxIncluded = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriStTaxIncluded = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoTxblty = '||to_char(line_in_tab(1).fPriCoTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoTaxType = '||to_char(line_in_tab(1).fPriCoTaxType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoTaxedAmt = '||
          to_char(line_in_tab(1).fPriCoTaxedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoExmtAmt = '||to_char(line_in_tab(1).fPriCoExmtAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoExmtRsnCd = '||line_in_tab(1).fPriCoExmtRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoNonTxblAmt = '||
          to_char(line_in_tab(1).fPriCoNonTxblAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoNonTxblRsnCd = '||
          line_in_tab(1).fPriCoNonTxblRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoRate = '||to_char(line_in_tab(1).fPriCoRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoRateEffDate = '||line_in_tab(1).fPriCoRateEffDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoRateType = '||
          to_char(line_in_tab(1).fPriCoRateType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoTaxAmt = '||to_char(line_in_tab(1).fPriCoTaxAmt));

        IF line_in_tab(1).fPriCoTaxIncluded = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoTaxIncluded = TRUE');
        ELSIF line_in_tab(1).fPriCoTaxIncluded = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoTaxIncluded = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCoTaxIncluded = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiTxblty = '||to_char(line_in_tab(1).fPriCiTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiTaxType = '||to_char(line_in_tab(1).fPriCiTaxType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiTaxedAmt = '||
          to_char(line_in_tab(1).fPriCiTaxedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiExmtAmt = '||to_char(line_in_tab(1).fPriCiExmtAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiExmtRsnCd = '||line_in_tab(1).fPriCiExmtRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiNonTxblAmt = '||
          to_char(line_in_tab(1).fPriCiNonTxblAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiNonTxblRsnCd = '||
          line_in_tab(1).fPriCiNonTxblRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiRate = '||to_char(line_in_tab(1).fPriCiRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiRateEffDate = '||line_in_tab(1).fPriCiRateEffDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiRateType = '||
          to_char(line_in_tab(1).fPriCiRateType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiTaxAmt = '||to_char(line_in_tab(1).fPriCiTaxAmt));

        IF line_in_tab(1).fPriCiTaxIncluded = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiTaxIncluded = TRUE');
        ELSIF line_in_tab(1).fPriCiTaxIncluded = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiTaxIncluded = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriCiTaxIncluded = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiTxblty = '||to_char(line_in_tab(1).fPriDiTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiTaxType = '||to_char(line_in_tab(1).fPriDiTaxType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiTaxedAmt = '||
          to_char(line_in_tab(1).fPriDiTaxedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiExmtAmt = '||to_char(line_in_tab(1).fPriDiExmtAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiExmtRsnCd = '||line_in_tab(1).fPriDiExmtRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiNonTxblAmt = '||
          to_char(line_in_tab(1).fPriDiNonTxblAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiNonTxblRsnCd = '||
          line_in_tab(1).fPriDiNonTxblRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiRate = '||to_char(line_in_tab(1).fPriDiRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiRateEffDate = '||line_in_tab(1).fPriDiRateEffDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiRateType = '||
          to_char(line_in_tab(1).fPriDiRateType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiTaxAmt = '||to_char(line_in_tab(1).fPriDiTaxAmt));

        IF line_in_tab(1).fPriDiTaxIncluded = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiTaxIncluded = TRUE');
        ELSIF line_in_tab(1).fPriDiTaxIncluded = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiTaxIncluded = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiTaxIncluded = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fPriDiAppliesTo = '||
          to_char(line_in_tab(1).fPriDiAppliesTo));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddTaxingJuris = '||
          to_char(line_in_tab(1).fAddTaxingJuris));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCustExmtCrtfNum = '||
            line_in_tab(1).fAddCustExmtCrtfNum);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoTxblty = '||to_char(line_in_tab(1).fAddCoTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoTaxType = '||to_char(line_in_tab(1).fAddCoTaxType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoTaxedAmt = '||
          to_char(line_in_tab(1).fAddCoTaxedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoExmtAmt = '||to_char(line_in_tab(1).fAddCoExmtAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoExmtRsnCd = '||line_in_tab(1).fAddCoExmtRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoNonTxblAmt = '||
          to_char(line_in_tab(1).fAddCoNonTxblAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoNonTxblRsnCd = '||
          line_in_tab(1).fAddCoNonTxblRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoRate = '||to_char(line_in_tab(1).fAddCoRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoRateEffDate = '||line_in_tab(1).fAddCoRateEffDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoRateType = '||
          to_char(line_in_tab(1).fAddCoRateType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoTaxAmt = '||to_char(line_in_tab(1).fAddCoTaxAmt));

        IF line_in_tab(1).fAddCoTaxIncluded = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoTaxIncluded = TRUE');
        ELSIF line_in_tab(1).fAddCoTaxIncluded = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoTaxIncluded = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCoTaxIncluded = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiTxblty = '||to_char(line_in_tab(1).fAddCiTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiTaxType = '||to_char(line_in_tab(1).fAddCiTaxType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiTaxedAmt = '||
          to_char(line_in_tab(1).fAddCiTaxedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiExmtAmt = '||to_char(line_in_tab(1).fAddCiExmtAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiExmtRsnCd = '||line_in_tab(1).fAddCiExmtRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiNonTxblAmt = '||
          to_char(line_in_tab(1).fAddCiNonTxblAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiNonTxblRsnCd = '||
          line_in_tab(1).fAddCiNonTxblRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiRate = '||to_char(line_in_tab(1).fAddCiRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiRateEffDate = '||line_in_tab(1).fAddCiRateEffDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiRateType = '||
          to_char(line_in_tab(1).fAddCiRateType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiTaxAmt = '||to_char(line_in_tab(1).fAddCiTaxAmt));

        IF line_in_tab(1).fAddCiTaxIncluded = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiTaxIncluded = TRUE');
        ELSIF line_in_tab(1).fAddCiTaxIncluded = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiTaxIncluded = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddCiTaxIncluded = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiTxblty = '||to_char(line_in_tab(1).fAddDiTxblty));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiTaxType = '||to_char(line_in_tab(1).fAddDiTaxType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiTaxedAmt = '||
          to_char(line_in_tab(1).fAddDiTaxedAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiExmtAmt = '||to_char(line_in_tab(1).fAddDiExmtAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiExmtRsnCd = '||line_in_tab(1).fAddDiExmtRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiNonTxblAmt = '||
          to_char(line_in_tab(1).fAddDiNonTxblAmt));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiNonTxblRsnCd = '||
          line_in_tab(1).fAddDiNonTxblRsnCd);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiRate = '||to_char(line_in_tab(1).fAddDiRate));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiRateEffDate = '||line_in_tab(1).fAddDiRateEffDate);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiRateType = '||
          to_char(line_in_tab(1).fAddDiRateType));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiTaxAmt = '||to_char(line_in_tab(1).fAddDiTaxAmt));

        IF line_in_tab(1).fAddDiTaxIncluded = TRUE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiTaxIncluded = TRUE');
        ELSIF line_in_tab(1).fAddDiTaxIncluded = FALSE THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiTaxIncluded = FALSE');
        ELSE
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiTaxIncluded = NULL');
        END IF;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'fAddDiAppliesTo = '|| to_char(line_in_tab(1).fAddDiAppliesTo));
    END IF;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

end DISPLAY_OUTPUT;

PROCEDURE ERROR_EXCEPTION_HANDLE(str  VARCHAR2) is

CURSOR error_exception_cursor IS
SELECT  EVNT_CLS_MAPPING_ID,
  TRX_ID,
  TAX_REGIME_CODE
FROM    ZX_TRX_PRE_PROC_OPTIONS_GT;

BEGIN
   IF (g_docment_type_id is null) THEN
      OPEN  error_exception_cursor;
      FETCH error_exception_cursor
       INTO g_docment_type_id,
            g_trasaction_id,
            g_tax_regime_code;
      CLOSE error_exception_cursor;
   END IF;

   err_count := nvl(err_count,0)+1;
   G_MESSAGES_TBL.DOCUMENT_TYPE_ID(err_count)     := g_docment_type_id;
   G_MESSAGES_TBL.TRANSACTION_ID(err_count)       := g_trasaction_id;
   G_MESSAGES_TBL.COUNTRY_CODE(err_count)         := g_tax_regime_code;
   G_MESSAGES_TBL.TRANSACTION_LINE_ID(err_count)  := g_transaction_line_id;
   G_MESSAGES_TBL.TRX_LEVEL_TYPE(err_count)       := g_trx_level_type;
   G_MESSAGES_TBL.ERROR_MESSAGE_TYPE(err_count)   := 'ERROR';
   G_MESSAGES_TBL.ERROR_MESSAGE_STRING(err_count) := str;

END ERROR_EXCEPTION_HANDLE;

PROCEDURE INITIALIZE is
  l_api_name           CONSTANT VARCHAR2(30) := 'INITIALIZE';
BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   context_rec.fGetJurisNames := TRUE;
   context_rec.fRoundingMethod := ZX_TAX_VERTEX_QSU.cQSURndngMethodQuantum;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;
end INITIALIZE;

begin /*Constructor*/
   initialize;
END ZX_VERTEX_TAX_SERVICE_PKG;

/
