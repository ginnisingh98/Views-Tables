--------------------------------------------------------
--  DDL for Package Body ZX_JA_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_JA_EXTRACT_PKG" AS
/* $Header: zxriextrajappvtb.pls 120.34.12010000.6 2009/09/26 20:18:16 skorrapa ship $ */

-----------------------------------------
--Private Variable Declarations

-----------------------------------------
--
-----------------------------------------

--Private Methods Declarations
-----------------------------------------
l_err_msg varchar2(120);

FUNCTION GET_LOOKUP_INFO
(
P_LOOKUP_TYPE              IN VARCHAR2,
P_LOOKUP_CODE              IN VARCHAR2,
P_TRX_DATE                 IN DATE
)
return varchar2;


PROCEDURE bank_info
(
 P_TRL_GLOBAL_VARIABLES_REC     IN      ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
);

PROCEDURE GET_INVOICE_AMT
(
P_VENDOR_ID      IN NUMBER,
P_INVOICE_NUM    IN VARCHAR2,
X_INVOICE_AMT    OUT NOCOPY  ZX_REP_TRX_JX_EXT_T.NUMERIC12%TYPE,
X_BASE_AMT       OUT NOCOPY  ZX_REP_TRX_JX_EXT_T.NUMERIC13%TYPE,
X_PRINT_DATE     OUT NOCOPY  ZX_REP_TRX_JX_EXT_T.GDF_AP_INVOICES_ATT4%TYPE
);

PROCEDURE UPDATE_PRINT_DATE
(
P_INVOICE_ID     IN NUMBER
);


PROCEDURE GET_GUI_SOURCE
(
P_TRX_SOURCE_NAME IN VARCHAR2,
X_GDF_RA_BATCH_SOURCES_ATT1   OUT NOCOPY  ZX_REP_TRX_JX_EXT_T.GDF_RA_BATCH_SOURCES_ATT1%TYPE, -- reference transaction source
X_GDF_RA_BATCH_SOURCES_ATT2   OUT NOCOPY  ZX_REP_TRX_JX_EXT_T.GDF_RA_BATCH_SOURCES_ATT2%TYPE,  -- initial trx num
X_GDF_RA_BATCH_SOURCES_ATT3   OUT NOCOPY  ZX_REP_TRX_JX_EXT_T.GDF_RA_BATCH_SOURCES_ATT3%TYPE,  -- invoice word
X_GDF_RA_BATCH_SOURCES_ATT4   OUT NOCOPY  ZX_REP_TRX_JX_EXT_T.GDF_RA_BATCH_SOURCES_ATT4%TYPE   -- final trx num
);


PROCEDURE GET_ORG_TRX_NUMBER
(
P_TRX_SOURCE_ID IN NUMBER,
P_TRX_ID        IN NUMBER,
X_ORG_TRX_NUMBER   OUT NOCOPY   ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT9%TYPE   -- org trx num
);


PROCEDURE GET_EXPORT_INFO
(
P_TRX_ID IN NUMBER,
X_GDF_RA_CUST_TRX_ATT4   OUT NOCOPY   ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT4%TYPE,   -- export certificate number
X_GDF_RA_CUST_TRX_ATT5   OUT NOCOPY   ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT5%TYPE,   -- export name
X_GDF_RA_CUST_TRX_ATT6   OUT NOCOPY   ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT6%TYPE,   -- export method
X_GDF_RA_CUST_TRX_ATT7   OUT NOCOPY   ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT7%TYPE,   -- export type
X_GDF_RA_CUST_TRX_ATT8   OUT NOCOPY   ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT8%TYPE   -- export date
);

--

-----------------------------------------
--Public Variable Declarations
-----------------------------------------
--
  g_current_runtime_level           NUMBER ;
  g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
  g_error_buffer                  VARCHAR2(100);
-----------------------------------------
--Public Methods Declarations
-----------------------------------------

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   FILTER_JA_AR_TAX_LINES                                                  |
 |   Type       : Public                                                     |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure is called to filter the records of transaction tables   |
 |    by selecting only the records associated with JA specific lookup type  |
 |    all unnecessary rows in ZX_REP_TRX_DETAIL_T table are deleted          |
 |                                                                           |
 |    Called from AR_TAX_EXTRACT.EXECUTE_SQL.                                |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN   :  p_report_name   varchar2 Required                               |
 |           p_request_id    number   Required                               |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     27-Oct-03  Asako Takahashi   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/


PROCEDURE FILTER_JA_AR_TAX_LINES
(
 P_TRL_GLOBAL_VARIABLES_REC	IN	ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
)

/* Following parameters are removed since we now access global variables directly
(
P_REPORT_NAME IN varchar2,
P_REQUEST_ID  IN number,
P_EXP_CERT_DATE_FROM  IN date,
P_EXP_CERT_DATE_TO    IN date,
P_EXP_METHOD  IN  varchar2,
P_TRX_SOURCE_ID  IN number,
P_INCLUDE_REFERENCED_SOURCE  IN varchar2
)
*/

IS
  l_delete_sql_string            varchar2(3000);
  l_loc_trx_src_type             varchar2(30);
  l_referenced_trx_src_id        varchar2(150);
  lp_where_export_date_from      varchar2(100);
  lp_where_export_date_to        varchar2(100);
  lp_where_export_method         varchar2(100);
  lp_where_trx_source_id         varchar2(100);
  lp_where_inc_reference_source   varchar2(100);
  lp_count_taxable               number(15);
  l_insert_sql_string            varchar2(1000);

BEGIN
   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.TRL.ja_tax_extract.filter_ja_tax_lines.BEGIN',
                      'ja_tax_extract.filter_ja_tax_lines(+)');
    END IF;

       -- ------------------------ --
       -- Filter the SUB ITF table --
       -- ------------------------ --

if P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWRVAT' then
 IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.TRL.ja_tax_extract.filter_ja_tax_lines',
                      'P_TRL_GLOBAL_VARIABLES_REC.BATCH_SOURCE_ID'||to_char(P_TRL_GLOBAL_VARIABLES_REC.BATCH_SOURCE_ID));
    END IF;
   /*  Taiwanese Output VAT Report  */
   if P_TRL_GLOBAL_VARIABLES_REC.BATCH_SOURCE_ID is NOT NULL then
          SELECT batch_source_type, TO_NUMBER(global_attribute1)
          INTO l_loc_trx_src_type, l_referenced_trx_src_id
          FROM ra_batch_sources_all
          WHERE batch_source_Id = P_TRL_GLOBAL_VARIABLES_REC.BATCH_SOURCE_ID;


   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.TRL.ja_tax_extract.filter_ja_tax_lines',
                      'batch_source_type'||l_loc_trx_src_type);
    END IF;

      if l_loc_trx_src_type = 'INV' and
         l_referenced_trx_src_id IS NOT NULL and
         P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_REFERENCED_SOURCE = 'Y' then
      /*  l_referenced_trx_src_id :GDF_RA_BATCH_SOURCES_ATT1 is used for Reference
          Transaction Source */
         lp_where_trx_source_id:= ' DET.TRX_BATCH_SOURCE_ID = ' || P_TRL_GLOBAL_VARIABLES_REC.BATCH_SOURCE_ID;
         lp_where_inc_reference_source:= ' or DET.TRX_BATCH_SOURCE_ID = '||  l_referenced_trx_src_id;
      else
         lp_where_trx_source_id:= ' DET.TRX_BATCH_SOURCE_ID = ' || P_TRL_GLOBAL_VARIABLES_REC.BATCH_SOURCE_ID;
         lp_where_inc_reference_source:= ' and 1 = 1';
      end if;
   else
      lp_where_trx_source_id:= ' 1 = 1';
      lp_where_inc_reference_source:= ' and 1 = 1';
   end if;

 IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.TRL.ja_tax_extract.filter_ja_tax_lines',
                      'lp_where_trx_source_id:'||lp_where_trx_source_id);
      FND_LOG.STRING(g_level_statement,
                     'ZX.TRL.ja_tax_extract.filter_ja_tax_lines',
                      'lp_where_inc_reference_source::'||lp_where_inc_reference_source);
    END IF;

-- AMIt changed = to <> because there is NOT
   l_delete_sql_string:=
       'DELETE from ZX_REP_TRX_DETAIL_T DET
       WHERE DET.REQUEST_ID = '||P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID||' and NOT(
             substrb(DET.DOCUMENT_SUB_TYPE,10,2) in (''31'',''32'',''33'',''34'',''35'',''36'',''37'') and
             DET.TRX_LINE_CLASS IN (''INVOICE'', ''CREDIT_MEMO'') and
             DET.DOC_EVENT_STATUS <> ''CANCELLED''  and ( ' ||
             lp_where_trx_source_id || '' || lp_where_inc_reference_source || '))';


 IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.TRL.ja_tax_extract.filter_ja_tax_lines',
                      'l_delete_sql_string::'||l_delete_sql_string);
    END IF;

-- AMIt changed = to <> because there is NOT
   EXECUTE IMMEDIATE l_delete_sql_string;
     DELETE from ZX_REP_TRX_DETAIL_T DET
       WHERE DET.REQUEST_ID = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID and NOT(
             substrb(DET.DOCUMENT_SUB_TYPE,10,2) in ('31','32','33','34','35','36','37') and
             DET.TRX_LINE_CLASS IN ('INVOICE', 'CREDIT_MEMO') and
             DET.DOC_EVENT_STATUS <> 'CANCELLED'  and (  DET.TRX_BATCH_SOURCE_ID = P_TRL_GLOBAL_VARIABLES_REC.BATCH_SOURCE_ID and 1 = 1));

	IF (g_level_statement >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement,
		     'ZX.TRL.ja_tax_extract.filter_ja_tax_lines',
		      'l_delete_sql_string::'||l_delete_sql_string);
	END IF;

elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWRUIL' then
/* Taiwanese Receivables Government Uniform Invoice Report  */

  l_referenced_trx_src_id := null;

  if P_TRL_GLOBAL_VARIABLES_REC.BATCH_SOURCE_ID is NOT NULL then
          SELECT batch_source_type, TO_NUMBER(global_attribute1)
          INTO l_loc_trx_src_type, l_referenced_trx_src_id
          FROM ra_batch_sources
          WHERE batch_source_Id = P_TRL_GLOBAL_VARIABLES_REC.BATCH_SOURCE_ID;

     if l_loc_trx_src_type = 'INV' and
        l_referenced_trx_src_id IS NOT NULL and
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_REFERENCED_SOURCE = 'Y' then
     /*   l_referenced_trx_src_id is used for GDF_RA_BATCH_SOURCES_ATT1   */
        lp_where_trx_source_id:= ' and DET.TRX_BATCH_SOURCE_ID = ' || P_TRL_GLOBAL_VARIABLES_REC.BATCH_SOURCE_ID;
        lp_where_inc_reference_source:= ' DET.TRX_BATCH_SOURCE_ID = '|| l_referenced_trx_src_id;
     else
        lp_where_trx_source_id:= ' DET.TRX_BATCH_SOURCE_ID = ' || P_TRL_GLOBAL_VARIABLES_REC.BATCH_SOURCE_ID;
        lp_where_inc_reference_source:= ' 1 = 1';
     end if;
  else
     lp_where_trx_source_id:= ' 1 = 1';
     lp_where_inc_reference_source:= ' 1 = 1';
  end if;

   l_delete_sql_string:=
     'DELETE from  ZX_REP_TRX_DETAIL_T DET
      WHERE DET.REQUEST_ID = '||P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID||' and
         NOT EXISTS
        (
         SELECT 1 FROM ra_batch_sources_all rbs,
                        ra_customer_trx_all rct
         WHERE
             rbs.batch_source_id = DET.TRX_BATCH_SOURCE_ID and
             rct.batch_source_id = rbs.batch_source_id and
             /* selecting trx with GUI TYPE 31,32,35,36,37  */
          (
             substrb(DET.DOCUMENT_SUB_TYPE,10,2) in (''31'',''32'',''35'',''36'',''37'') and
            (';
          IF l_referenced_trx_src_id is NULL THEN
             l_delete_sql_string := l_delete_sql_string||' rbs.global_attribute_category = ''JA.TW.RAXSUMSC.BATCH_SOURCES'' and
                rbs.global_attribute3 IS NOT NULL and (' ||
                lp_where_trx_source_id || ' or ' ||
                lp_where_inc_reference_source || ')
               '; -- amit removed one bracket
          ELSE
            l_delete_sql_string := l_delete_sql_string||'rbs.global_attribute3 IS NULL and '||
                lp_where_trx_source_id || '
               )';
          END IF;
          l_delete_sql_string := l_delete_sql_string||' )
           )
             or
            /*  selecting trx with GUI TYPE 33,34   */
             (substrb(DET.DOCUMENT_SUB_TYPE,10,2) in (''33'',''34'') and (' ||
               lp_where_trx_source_id || ' or ' ||
               lp_where_inc_reference_source || ')
              )
             or
            /*  selecting trx with GUI TYPE NULL   */
              (substrb(DET.DOCUMENT_SUB_TYPE,10,2)  = ''  '' and
               rct.global_attribute_category = ''JA.TW.ARXTWMAI.RA_CUSTOMER_TRX'' and
               rct.global_attribute9 IS NOT NULL and
               DET.DOC_EVENT_STATUS <> ''CANCELLED'' and '|| -- Amit changed to <>
               lp_where_trx_source_id || '
               )
         --   )
        )';

   EXECUTE IMMEDIATE l_delete_sql_string;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.filter_ja_ar_tax_lines',
				      'Deleted Count : '||to_char(SQL%ROWCOUNT) );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.filter_ja_ar_tax_lines',
	' l_delete_sql_string : '||l_delete_sql_string );

    END IF;

elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWRZTR' then
    /* Taiwanese Receivables Zero-Rate Tax Report  */

    if P_TRL_GLOBAL_VARIABLES_REC.EXP_CERT_DATE_FROM is NOT NULL then
       lp_where_export_date_from:= ' and fnd_date.canonical_to_date(rct.global_attribute8) >= ' ||
                                         P_TRL_GLOBAL_VARIABLES_REC.exp_cert_date_from ;
    end if;

    if P_TRL_GLOBAL_VARIABLES_REC.EXP_CERT_DATE_TO is NOT NULL then
       lp_where_export_date_to:= ' and fnd_date.canonical_to_date(rct.global_attribute8) <= ' ||
                                         P_TRL_GLOBAL_VARIABLES_REC.exp_cert_date_to ;
    end if;

    if P_TRL_GLOBAL_VARIABLES_REC.EXP_METHOD is NOT NULL then
       lp_where_export_method:= ' and rct.global_attribute6 = ''' ||
                                         P_TRL_GLOBAL_VARIABLES_REC.exp_method || '''';
    end if;

    l_delete_sql_string:=
      'DELETE from ZX_REP_TRX_DETAIL_T DET
       WHERE DET.REQUEST_ID = '||P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID||' and
             NOT EXISTS
             (SELECT 1
              FROM
                   RA_CUSTOMER_TRX_ALL rct,
                   JA_LOOKUPS ja1,
                   JA_LOOKUPS ja2,
                   JA_LOOKUPS ja3
              WHERE
                    DET.REQUEST_ID = '||P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID||' and
                    DET.TRX_ID = rct.customer_trx_id and
                    substrb(DET.DOCUMENT_SUB_TYPE,10,2) IN (''31'',''32'',''33'',''34'',''35'',''36'',''37'') and
                    DET.TRX_LINE_CLASS IN (''INVOICE'',''CREDIT_MEMO'') ' ||
                    lp_where_export_date_from ||
                    lp_where_export_date_to ||
                    lp_where_export_method|| ')';

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.filter_ja_ar_tax_lines',
				      'Deleted Count : '||to_char(SQL%ROWCOUNT) );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.filter_ja_ar_tax_lines',
	' l_delete_sql_string : '||l_delete_sql_string );

    END IF;

   EXECUTE IMMEDIATE l_delete_sql_string;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.filter_ja_ar_tax_lines',
				      'Deleted Count : '||to_char(SQL%ROWCOUNT) );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.filter_ja_ar_tax_lines',
	' l_delete_sql_string : '||l_delete_sql_string );

    END IF;

   --COMMIT; Bug 8262631



elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWRSRD' then
/* Taiwanese Sales Return and Discount Report   */

        DELETE from ZX_REP_TRX_DETAIL_T DET
        WHERE DET.REQUEST_ID = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID and
              NOT (DET.TRX_LINE_CLASS = 'CREDIT_MEMO' and
                   DET.EXTRACT_SOURCE_LEDGER = 'AR' and
                   substrb(DET.DOCUMENT_SUB_TYPE,10,2) IN ('33','34'));

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.filter_ja_ar_tax_lines',
				      'Deleted Count : '||to_char(SQL%ROWCOUNT) );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.filter_ja_ar_tax_lines',
	' l_delete_sql_string : '||l_delete_sql_string );

    END IF;


  elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWSEDI' then
/*  Taiwanese EDI Government Uniform Invoice
    This report should print only the posted transaction if it's not a voided
    invoices.
 */
      /* DELETE from ZX_REP_TRX_DETAIL_T DET
       WHERE DET.REQUEST_ID = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID and
             NOT
             (
              (DET.EXTRACT_SOURCE_LEDGER = 'AR' and
               DET.TRX_LINE_CLASS in ('INVOICE', 'CREDIT_MEMO') and
               substrb(DET.DOCUMENT_SUB_TYPE,10,2) IN ('31','32','33','34','35','36','37') and

               ((DET.DOC_EVENT_STATUS = 'CANCELLED' and
                 DET.POSTED_FLAG = 'Y' ) or
                DET.DOC_EVENT_STATUS = 'VALIDATED')
              )
              or
              (DET.EXTRACT_SOURCE_LEDGER = 'AP' and
               DET.POSTED_FLAG = 'Y' and
               DET.TRX_LINE_CLASS in ('STANDARD INVOICES','AP_CREDIT_MEMO', 'AP_DEBIT_MEMO') and
               substrb(DET.DOCUMENT_SUB_TYPE, 10,2) IN ('21','22', '23','24','25','26','27','28'))
             );
*/

            DELETE
            FROM zx_rep_trx_detail_t dtl
            WHERE DTL.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
               AND DTL.EXTRACT_SOURCE_LEDGER = 'AR'
               AND EXISTS (SELECT 1 FROM ra_cust_trx_types_all types
                    WHERE types.org_id = dtl.internal_organization_id
                      AND dtl.trx_type_id = types.cust_trx_type_id
                      AND NVL(types.global_attribute1,'99') NOT IN ('31','32','33','34','35','36','37'));



    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.filter_ja_ar_tax_lines',
				      'Deleted Count : '||to_char(SQL%ROWCOUNT) );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.filter_ja_ar_tax_lines',
	' l_delete_sql_string : '||l_delete_sql_string );

    END IF;

end if;

IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.TRL.ja_tax_extract.filter_ja_tax_lines.END',
                      'ja_tax_extract.filter_ar_tax_lines(-)');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.filter_ja_ar_tax_lines',
			'Error Message  : '||substrb(SQLERRM,1,120) );
		END IF;

END filter_ja_ar_tax_lines;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |   FILTER_JA_AP_TAX_LINES                                                  |
 |   Type       : Public                                                     |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure is called to filter the records of transaction tables   |
 |    by selecting only the records associated with JA specific lookup type  |
 |    all unnecessary rows in ZX_REP_DETAIL_T table are deleted              |
 |                                                                           |
 |    Called from AR_TAX_EXTRACT.EXECUTE_SQL.                                |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN   :  p_report_name   varchar2 Required                               |
 |           p_request_id    number   Required                               |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     27-Oct-03  Asako Takahashi   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/


PROCEDURE FILTER_JA_AP_TAX_LINES
(
 P_TRL_GLOBAL_VARIABLES_REC	IN	ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
)

/* Following parameters are removed since we now access global variables directly
(
P_REPORT_NAME IN varchar2,
P_REQUEST_ID  IN number,
P_GUI_TYPE    IN  varchar2,
P_REPRINT     IN  varchar2,
-- P_APPLIED_TRX_NUMBER_LOW  in varchar2,   -- no longer required  TRL perform this filter
-- P_APPLIED_TRX_NUMBER_HIGH in varchar2,   -- DET.ADJUSTED_DOC_NUMBER >= ''' ||P_ADJUSTED_DOC_NUM_LOW
P_MRCSOBTYPE         in varchar2,
P_REPORTING_LEVEL    in varchar2,
P_REPORTING_CONTEXT  in number,
P_SET_OF_BOOKS_ID    in number
)
*/

IS
  l_delete_sql_string            varchar2(3000);
  lp_gui_type_where              varchar2(100);
  lp_reprint_where               varchar2(100);
  lp_applied_trx_num_from_where       varchar2(100);
  lp_applied_trx_num_to_where         varchar2(100);
  lp_from_payments               varchar2(30);
  lp_from_checks                 varchar2(30);
  l_vendor_name                  VARCHAR2(80);
  lp_where_org_art                varchar2(2000);
  type NumList is TABLE OF number
       INDEX BY binary_integer;
  nums NumList;

  cnt NUMBER:= 0;
  org_list VARCHAR2(32767):= NULL;

  CURSOR c_ar (p_org_id NUMBER)
    IS SELECT vat_tax_id
       FROM ar_vat_tax_all_b
       WHERE org_id = p_org_id;

  CURSOR c_ap (p_org_id NUMBER)
    IS SELECT tax_id
       FROM ap_tax_codes_all
       WHERE org_id = p_org_id;


BEGIN
	g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
	IF (g_level_procedure >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES.BEGIN',
				      'ZX_JA_EXTRACT_PKG.filter_ap_tax_lines(+)');
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES.BEGIN',
				      'P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME : '||P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME);
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES.BEGIN',
			      'P_TRL_GLOBAL_VARIABLES_REC.DOCUMENT_SUB_TYPE : '||P_TRL_GLOBAL_VARIABLES_REC.DOCUMENT_SUB_TYPE );

	END IF;

if P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWPVAT' then
/*  Taiwanese Input VAT Rerport */

        DELETE from ZX_REP_TRX_DETAIL_T DET
        WHERE DET.REQUEST_ID = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID and
              NOT (DET.EXTRACT_SOURCE_LEDGER = 'AP' and
                   DET.TRX_LINE_CLASS IN ('STANDARD INVOICES', 'AP_CREDIT_MEMO', 'AP_DEBIT_MEMO') and
                   substrb(DET.DOCUMENT_SUB_TYPE, 10, 2) in ('21','22','23','24','25','26','27','28')
                   );

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES',
					      'Deleted Count : '||to_char(SQL%ROWCOUNT) );
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES',
		'ja_tax_extract.filter_ja_tax_lines '||'l_delete_sql_string: ' || l_delete_sql_string);
	END IF;

elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWPSPC' then
/* Taiwanese Payables Sales/Purchase Return  */

      if P_TRL_GLOBAL_VARIABLES_REC.DOCUMENT_SUB_TYPE is NOT NULL then
          lp_gui_type_where:= ' and substrb(DET.DOCUMENT_SUB_TYPE,10,2) =  ''' || P_TRL_GLOBAL_VARIABLES_REC.DOCUMENT_SUB_TYPE || '''';
      end if;

/* Need to be cerified
      P_REPRINT should be available in Parameter Rec

      if nvl(P_TRL_GLOBAL_VARIABLES_REC.REPRINT, 'N') <> 'Y' then
          lp_reprint_where:= ' and ai.global_attribute4 is NULL ';
      end if;
*/
      l_delete_sql_string:=
      'DELETE from ZX_REP_TRX_DETAIL_T DET
       WHERE DET.REQUEST_ID = '||P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID||' and
            NOT EXISTS (SELECT 1 FROM AP_INVOICES ai
                WHERE DET.EXTRACT_SOURCE_LEDGER = ''AP'' and
                      DET.TRX_LINE_CLASS IN (''STANDARD INVOICES'',''AP_CREDIT_MEMO'', ''AP_DEBIT_MEMO'') and
                      (DET.APPLIED_TO_TRX_NUMBER = ai.invoice_num OR DET.TRX_NUMBER = ai.invoice_num) and
                      DET.BILLING_TRADING_PARTNER_ID = ai.vendor_id and
                      substrb(DET.DOCUMENT_SUB_TYPE,10,2) IN (''23'',''24'') '||
                      lp_gui_type_where ||
                      lp_reprint_where||')';
/*Bug 5439099 added the or condition check for trx number to accept standard invoices of type 23,24*/

   EXECUTE IMMEDIATE l_delete_sql_string;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES',
				      'Deleted Count : '||to_char(SQL%ROWCOUNT) );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES',
	' l_delete_sql_string : '||l_delete_sql_string );

    END IF;

elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWSPRF' then
/*   Taiwanese Pro Forma 401 Report   */
        DELETE from ZX_REP_TRX_DETAIL_T DET
        WHERE DET.REQUEST_ID = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID and
              NOT (
                  (DET.EXTRACT_SOURCE_LEDGER = 'AR' and
                   DET.TRX_LINE_CLASS in ('INVOICE', 'CREDIT_MEMO') and
                   DET.DOC_EVENT_STATUS <> 'CANCELLED' and
                   substrb(DET.DOCUMENT_SUB_TYPE,10,2) IN
                         ('31','32','33','34','35','36','37')) or
                  (DET.EXTRACT_SOURCE_LEDGER = 'AP' and
                   DET.TRX_LINE_CLASS IN ('STANDARD INVOICES', 'AP_CREDIT_MEMO', 'AP_DEBIT_MEMO') and
                   substrb(DET.DOCUMENT_SUB_TYPE,10,2) IN
                         ('21','22','23','24','25','26','27','28'))
              );



    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES',
				      'Deleted Count : '||to_char(SQL%ROWCOUNT) );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES',
	' l_delete_sql_string : '||l_delete_sql_string );

    END IF;


elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWPPRD' then
/* Taiwanese Purchase Return and Discount Report  */
        DELETE from ZX_REP_TRX_DETAIL_T DET
        WHERE DET.REQUEST_ID = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID and
              NOT (DET.EXTRACT_SOURCE_LEDGER = 'AP' and
                   substrb(DET.DOCUMENT_SUB_TYPE,10,2) IN ('23','24') and
                   DET.CANCEL_FLAG <> 'Y'
                   );
    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES',
	' NULL supplier '||l_delete_sql_string );

    END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES',
				      'Deleted Count : '||to_char(SQL%ROWCOUNT) );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES',
	' l_delete_sql_string : '||l_delete_sql_string );

    END IF;

elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXSGAGAL' then
/* Singaporean Input Taxes Gain/Loss Report */
        DELETE from ZX_REP_TRX_DETAIL_T DET
        WHERE DET.REQUEST_ID = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID and
          NOT (DET.EXTRACT_SOURCE_LEDGER = 'AP' and
               DET.FUNCTIONAL_CURRENCY_CODE <> DET.TRX_CURRENCY_CODE and
               DET.SUPPLIER_EXCHANGE_RATE IS NOT NULL and
               DET.CURRENCY_CONVERSION_RATE is NOT NULL);

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES',
				      'Deleted Count : '||to_char(SQL%ROWCOUNT) );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES',
	' l_delete_sql_string : '||l_delete_sql_string );

    END IF;


elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXSGGF5' then
/*  Singapore GST F5 Report */
/*  Singaporean GST F5 report assumed that tax journals in gl where populated by tax extract
    based on the reporting level and reporting context parameter provided by the user.
    However, Data in gl is not fully partitioned by org_id (only gl_je_batches is partitioned by
    org) and to support this, we use lp_where_org_art selection criteria */

   if P_TRL_GLOBAL_VARIABLES_REC.REPORTING_LEVEL = '1000' then
      lp_where_org_art:= ' and DET.LEDGER_ID = ' || P_TRL_GLOBAL_VARIABLES_REC.LEDGER_ID;

   elsif P_TRL_GLOBAL_VARIABLES_REC.REPORTING_LEVEL = '2000' then
      lp_where_org_art:= ' and legal_entity_org_id = ' || P_TRL_GLOBAL_VARIABLES_REC.REPORTING_CONTEXT;

   elsif P_TRL_GLOBAL_VARIABLES_REC.REPORTING_LEVEL = '3000' then

      for r_ar IN c_ar(P_TRL_GLOBAL_VARIABLES_REC.REPORTING_CONTEXT) LOOP
          nums(cnt):= r_ar.vat_tax_id;
          cnt:= cnt+1;
      end loop;

      for r_ap IN c_ap(P_TRL_GLOBAL_VARIABLES_REC.REPORTING_CONTEXT) LOOP
          nums(cnt):= r_ap.tax_id;
          cnt:= cnt+1;
      end loop;

      for i in nums.FIRST .. nums.LAST LOOP
          if i = nums.FIRST THEN
             org_list:= nums(i);
          else
             org_list:= org_list || ', ' || nums(i);
          end if;
      end loop;

      if org_list IS NOT NULL THEN
         lp_where_org_art:= ' and DET.TAX_RATE_ID in (' || org_list || ')';
      else
         lp_where_org_art:= NULL;
      end if;
   end if;


   l_delete_sql_string:=
      ' DELETE from ZX_REP_TRX_DETAIL_T DET
        WHERE DET.REQUEST_ID = '||P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID||' and
            NOT ((DET.EXTRACT_SOURCE_LEDGER in (''AR'',''GL'')  '||
                 lp_where_org_art ||' ) or
                 (DET.EXTRACT_SOURCE_LEDGER = ''AP''))';

--   EXECUTE IMMEDIATE l_delete_sql_string;


    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES',
				      'Deleted Count : '||to_char(SQL%ROWCOUNT) );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES',
	' l_delete_sql_string : '||l_delete_sql_string );

    END IF;

end if;

	IF (g_level_procedure >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES.END',
				      'ZX_JA_EXTRACT_PKG.filter_ap_tax_lines(-):');
	END IF;

EXCEPTION
    WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.FILTER_JA_AP_TAX_LINES',
			'Error Message for report  : '||substrb(SQLERRM,1,120) );
		END IF;

END filter_ja_ap_tax_lines;



/*===========================================================================+
 | PUBLIC PROCEDURE                                                          |
 |   POPULATE_JA_AR                                                          |
 |   Type       : Public                                                     |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure calls the API to select the JA specific data from       |
 |    JA receivables tables.                                                 |
 |                                                                           |
 |    Called from ARP_TAX_EXTRACT.POPULATE_MISSING_COLUMNS.                  |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN   :  p_zx_rep_detail_rec      zx_rep_trx_detail_t%rowtype            |
 |           p_report_name            varchar2  -- required                  |
 |                                                                           |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     27-Oct-03  Asako Takahashi   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE POPULATE_JA_AR
(
 P_TRL_GLOBAL_VARIABLES_REC	IN	ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
)

/* Following parameter is removed since we now access global variables directly
(
-- IN parameters are passed as global variables.
--   DETAIL_TAX_LINE_ID_TBL
--   TRX_STATUS_CODE_TBL
--   TRX_BUSINESS_CATEGORY_TBL
--   TRX_BATCH_SOURCE_NAME_TBL
--   TRX_BATCH_SOURCE_ID_TBL
--   DOCUMENT_SUB_TYPE_TBL
--   TRX_BATCH_SOURCE_ID_TBL
--   GDF_RA_CUST_TRX_ATT7_TBL
--   GDF_RA_CUST_TRX_ATT5_TBL
--   GDF_RA_CUST_TRX_ATT6_TBL
--   PROD_FISC_CLASSIFICATION_TBL
   P_REPORT_NAME                 IN  varchar2
)
*/

IS

P_LOOKUP_TYPE    varchar2(500);
P_LOOKUP_CODE    varchar2(1000); --Bug 5453806

TYPE GOVERNMENT_TAX_TYPE_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.TAX_STATUS_MNG%TYPE INDEX BY BINARY_INTEGER;

TYPE DEDUCTIBLE_TYPE_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.TRX_BUSINESS_CATEGORY_MNG%TYPE INDEX BY BINARY_INTEGER;

TYPE EXPORT_METHOD_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE4%TYPE INDEX BY BINARY_INTEGER;

TYPE EXPORT_CERTIFICATE_NAME_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE5%TYPE INDEX BY BINARY_INTEGER;

TYPE EXPORT_TYPE_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE6%TYPE INDEX BY BINARY_INTEGER;

TYPE INVOICE_WORD_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.GDF_RA_BATCH_SOURCES_ATT3%TYPE INDEX BY BINARY_INTEGER;

TYPE INITIAL_TRX_NUM_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.GDF_RA_BATCH_SOURCES_ATT2%TYPE INDEX BY BINARY_INTEGER;

TYPE FINAL_TRX_NUM_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.GDF_RA_BATCH_SOURCES_ATT4%TYPE INDEX BY BINARY_INTEGER;

TYPE REFERENCE_TRX_SRC_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.GDF_RA_BATCH_SOURCES_ATT1%TYPE INDEX BY BINARY_INTEGER;

TYPE ORG_TRX_NUMBER_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT9%TYPE INDEX BY BINARY_INTEGER;

TYPE GDF_RA_CUST_TRX_ATT4_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT4%TYPE INDEX BY BINARY_INTEGER;

TYPE GDF_RA_CUST_TRX_ATT5_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT5%TYPE INDEX BY BINARY_INTEGER;

TYPE GDF_RA_CUST_TRX_ATT6_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT6%TYPE INDEX BY BINARY_INTEGER;

TYPE GDF_RA_CUST_TRX_ATT7_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT7%TYPE INDEX BY BINARY_INTEGER;

TYPE GDF_RA_CUST_TRX_ATT8_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT7%TYPE INDEX BY BINARY_INTEGER;

TYPE CNT_TAXABLE_AMT_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.NUMERIC1%TYPE INDEX BY BINARY_INTEGER;

TYPE WINE_CIGARETTE_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE1_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER;


X_GOVERNMENT_TAX_TYPE_TBL 	GOVERNMENT_TAX_TYPE_TBL;
X_DEDUCTIBLE_TYPE_TBL 		DEDUCTIBLE_TYPE_TBL;
X_EXPORT_METHOD_TBL 		EXPORT_METHOD_TBL;
X_EXPORT_CERTIFICATE_NAME_TBL 	EXPORT_CERTIFICATE_NAME_TBL;
X_EXPORT_TYPE_TBL 		EXPORT_TYPE_TBL;
X_INVOICE_WORD_TBL 		INVOICE_WORD_TBL;
X_INITIAL_TRX_NUM_TBL 		INITIAL_TRX_NUM_TBL;
X_FINAL_TRX_NUM_TBL 		FINAL_TRX_NUM_TBL;
X_REFERENCE_TRX_SRC_TBL 	REFERENCE_TRX_SRC_TBL;

X_ORG_TRX_NUMBER_TBL 		ORG_TRX_NUMBER_TBL;
X_GDF_RA_CUST_TRX_ATT4_TBL 	GDF_RA_CUST_TRX_ATT4_TBL;
X_GDF_RA_CUST_TRX_ATT5_TBL 	GDF_RA_CUST_TRX_ATT5_TBL;
X_GDF_RA_CUST_TRX_ATT6_TBL 	GDF_RA_CUST_TRX_ATT6_TBL;
X_GDF_RA_CUST_TRX_ATT7_TBL 	GDF_RA_CUST_TRX_ATT7_TBL;
X_GDF_RA_CUST_TRX_ATT8_TBL 	GDF_RA_CUST_TRX_ATT8_TBL;
X_CNT_TAXABLE_AMT_TBL 		CNT_TAXABLE_AMT_TBL;
X_WINE_CIGARETTE_TBL 		WINE_CIGARETTE_TBL;

lp_count_taxable number(15);
test varchar2(200);

l_detail_tax_line_id_tbl        ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
l_trx_id_tbl                    ZX_EXTRACT_PKG.TRX_ID_TBL;
l_tax_status_code_tbl           ZX_EXTRACT_PKG.TAX_STATUS_CODE_TBL;
l_trx_business_category_tbl     ZX_EXTRACT_PKG.TRX_BUSINESS_CATEGORY_TBL;
l_trx_batch_source_name_tbl     ZX_EXTRACT_PKG.TRX_BATCH_SOURCE_NAME_TBL;
l_document_sub_type_tbl         ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL;
l_prod_fisc_classification_tbl  ZX_EXTRACT_PKG.PROD_FISC_CLASSIFICATION_TBL;

l_location_code_tbl           ATTRIBUTE1_TBL;
l_address_line_1_tbl          ATTRIBUTE1_TBL;
l_address_line_2_tbl          ATTRIBUTE1_TBL;
l_address_line_3_tbl          ATTRIBUTE1_TBL;
l_city_tbl                    ATTRIBUTE1_TBL;
l_region_1_tbl                ATTRIBUTE1_TBL;
l_region_2_tbl                ATTRIBUTE1_TBL;
l_postal_code_tbl             ATTRIBUTE1_TBL;
l_country_code_tbl            ATTRIBUTE1_TBL;
l_loc_tax_reg_num_tbl         ATTRIBUTE1_TBL;
l_taxable_person_tbl          ATTRIBUTE1_TBL;
l_ind_sub_classif_tbl         ATTRIBUTE1_TBL;
l_ind_classif_tbl             ATTRIBUTE1_TBL;

--Bug 5251425
  l_trx_date_tbl zx_extract_pkg.trx_date_tbl;
  x_trx_date_tbl zx_extract_pkg.trx_date_tbl;
  l_canonical_date  VARCHAR2(20);
  l_roc_year  NUMBER(15);
  l_roc_mmdd  VARCHAR2(5);
  l_roc_date  VARCHAR2(20);
  l_trx_date  DATE;

BEGIN

   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.TRL.ja_tax_extract.ja_tax_extract.populate_ja_ar.BEGIN',
                      'ja_tax_extract.populate_ja_ar(+)');
    END IF;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.populate_ja_ar',
					      'P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME : '||P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME );
	END IF;


SELECT  detail_tax_line_id,
        trx_id,
        tax_status_code,
        trx_business_category,
        trx_batch_source_name,
        document_sub_type,
        product_fisc_classification,
	trx_date --Bug 5251425
BULK COLLECT INTO  l_detail_tax_line_id_tbl,
        l_trx_id_tbl,
        l_tax_status_code_tbl,
        l_trx_business_category_tbl,
        l_trx_batch_source_name_tbl,
        l_document_sub_type_tbl,
        l_prod_fisc_classification_tbl,
	l_trx_date_tbl --Bug 5251425
FROM  zx_rep_trx_detail_t itf1
WHERE  itf1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.populate_ja_ar',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
	END IF;

P_LOOKUP_CODE:= NULL;

if P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = ('ZXTWRVAT') and l_detail_tax_line_id_tbl.count <> 0 then

/******  Populate the missing columns   ********/
   FOR i in 1 .. nvl(l_detail_tax_line_id_tbl.count,0) LOOP

      P_LOOKUP_TYPE:= 'JATW_GOVERNMENT_TAX_TYPE';
      P_LOOKUP_CODE:= l_tax_status_code_tbl(i);
     -- P_LOOKUP_CODE:=l_tax_status_id_tbl(i);
      X_GOVERNMENT_TAX_TYPE_TBL(i):= GET_LOOKUP_INFO(P_LOOKUP_TYPE, P_LOOKUP_CODE, l_trx_date_tbl(i));

      P_LOOKUP_TYPE:= 'JATW_DEDUCTIBLE_TYPE';
--Bug 5453806
     -- select translate(l_trx_business_category_tbl(i), '0123456789.ABCDEFGHIJKLMNOPQRSTUVWXYZ', '0123456789') into P_LOOKUP_CODE from dual;
	p_lookup_code := l_trx_business_category_tbl(i);
      X_DEDUCTIBLE_TYPE_TBL(i):= GET_LOOKUP_INFO(P_LOOKUP_TYPE, P_LOOKUP_CODE,l_trx_date_tbl(i));
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.TRL.ja_tax_extract.ja_tax_extract.populate_ja_ar',
                      'P_LOOKUP_CODE:'||P_LOOKUP_CODE||'-'||l_tax_status_code_tbl(i));
    END IF;

   END LOOP;

/******    Bulk Insert into Ext Table      *******/
 FORALL i in 1 .. nvl(l_detail_tax_line_id_tbl.last, 0)

  INSERT INTO ZX_REP_TRX_JX_EXT_T
       (detail_tax_line_ext_id,
        detail_tax_line_id,
        tax_status_mng,     -- government tax type meaning
        trx_business_category_mng,     -- deductible code meaning
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
  VALUES (zx_rep_trx_jx_ext_t_s.nextval,
        l_detail_tax_line_id_tbl(i),
        X_GOVERNMENT_TAX_TYPE_TBL(i),
        X_DEDUCTIBLE_TYPE_TBL(i),
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id);


elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWRUIL' and l_detail_tax_line_id_tbl.count <> 0 then

/******  Populate the missing columns   ********/

   FOR i in 1 .. nvl(l_detail_tax_line_id_tbl.count,0) LOOP

      P_LOOKUP_TYPE:= 'JATW_GOVERNMENT_TAX_TYPE';
      P_LOOKUP_CODE:=  l_tax_status_code_tbl(i);
      X_GOVERNMENT_TAX_TYPE_TBL(i):= GET_LOOKUP_INFO(P_LOOKUP_TYPE, P_LOOKUP_CODE,l_trx_date_tbl(i));
-- Added new trx date parameter for checking date effectivity


      -- Get GUI MISSING SEQUENCE
      -- Get GUI Source
      GET_GUI_SOURCE(l_trx_batch_source_name_tbl(i),
                     X_REFERENCE_TRX_SRC_TBL(i), X_INITIAL_TRX_NUM_TBL(i),
                     X_INVOICE_WORD_TBL(i),  X_FINAL_TRX_NUM_TBL(i));

     -- Get Original Transaction Number
     IF substrb(l_document_sub_type_tbl(i),10,2) in ('33', '34') THEN
        GET_ORG_TRX_NUMBER(l_trx_batch_source_name_tbl(i), l_trx_id_tbl(i),X_ORG_TRX_NUMBER_TBL(i));
     ELSE
       X_ORG_TRX_NUMBER_TBL(i) := NULL;
     END IF;

--Bug 5251425 : To get the taiwan specific date format.
	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.populate_ja_ar',
					      'Before call to fnd_date.date_to_canonical to get canonical date format ');
	END IF;
l_canonical_date := fnd_date.date_to_canonical(l_trx_date_tbl(i));
l_roc_year := TO_NUMBER(SUBSTRB(l_canonical_date,1,4)) - 1911;
l_roc_mmdd := SUBSTRB(l_canonical_date,6,5);
l_roc_date :=  TO_CHAR(l_roc_year) || '/' || l_roc_mmdd;
x_trx_date_tbl(i) := to_date(l_roc_date,'YYYY/MM/DD');

   END LOOP;


/******    Bulk Insert into Ext Table      *******/

 FORALL i in 1 .. nvl(l_detail_tax_line_id_tbl.last, 0)

   INSERT INTO ZX_REP_TRX_JX_EXT_T
       (detail_tax_line_ext_id,
        detail_tax_line_id,
        tax_status_mng,     -- government tax type meaning
        gdf_ra_cust_trx_att9,     -- orginal transaction number   ZXTWRUIL
        gdf_ra_batch_sources_att1,   -- reference transaction source ZXTWRUIL
        gdf_ra_batch_sources_att2,   -- initial trx num  ZXTWRUIL
        gdf_ra_batch_sources_att3,   -- invoice word ZXTWRUIL
        gdf_ra_batch_sources_att4,   -- final trx num ZXTWRUIL
	attribute15, --Bug 5251425
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
   VALUES (zx_rep_trx_jx_ext_t_s.nextval,
        l_detail_tax_line_id_tbl(i),
        X_GOVERNMENT_TAX_TYPE_TBL(i),
        X_ORG_TRX_NUMBER_TBL(i),
        X_REFERENCE_TRX_SRC_TBL(i),
        X_INITIAL_TRX_NUM_TBL(i),
        X_INVOICE_WORD_TBL(i),
        X_FINAL_TRX_NUM_TBL(i),
	x_trx_date_tbl(i), --Bug 5251425
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.populate_ja_ar',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;
elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWRZTR' and l_detail_tax_line_id_tbl.count <> 0 then

/******  Populate the missing columns   ********/

   FOR i in 1 .. nvl(l_detail_tax_line_id_tbl.count,0) LOOP

      GET_EXPORT_INFO(l_trx_id_tbl(i), X_GDF_RA_CUST_TRX_ATT4_TBL(i),
                      X_GDF_RA_CUST_TRX_ATT5_TBL(i),  X_GDF_RA_CUST_TRX_ATT6_TBL(i),
                      X_GDF_RA_CUST_TRX_ATT7_TBL(i),  X_GDF_RA_CUST_TRX_ATT8_TBL(i));

      P_LOOKUP_TYPE:= 'JATW_EXPORT_METHOD';
      P_LOOKUP_CODE:= X_GDF_RA_CUST_TRX_ATT6_TBL(i);
      X_EXPORT_METHOD_TBL(i):= GET_LOOKUP_INFO(P_LOOKUP_TYPE, P_LOOKUP_CODE,l_trx_date_tbl(i));

      P_LOOKUP_TYPE:= 'JATW_EXPORT_CERTIFICATE_NAME';
      P_LOOKUP_CODE:= X_GDF_RA_CUST_TRX_ATT5_TBL(i);
      X_EXPORT_CERTIFICATE_NAME_TBL(i):= GET_LOOKUP_INFO(P_LOOKUP_TYPE, P_LOOKUP_CODE,l_trx_date_tbl(i));

      P_LOOKUP_TYPE:= 'JATW_EXPORT_TYPE';
      P_LOOKUP_CODE:= X_GDF_RA_CUST_TRX_ATT7_TBL(i);
      X_EXPORT_TYPE_TBL(i):= GET_LOOKUP_INFO(P_LOOKUP_TYPE, P_LOOKUP_CODE,l_trx_date_tbl(i));

   END LOOP;


/******    Bulk Insert into Ext Table      *******/

FORALL i in 1 .. nvl(l_detail_tax_line_id_tbl.last, 0)

  INSERT INTO ZX_REP_TRX_JX_EXT_T
       (detail_tax_line_ext_id,
        detail_tax_line_id,
        attribute4,               -- export method
        attribute5,               -- export certificate name
        attribute6,               -- export type
        gdf_ra_cust_trx_att4,     -- export certificate number  ZXTWRZTR
        gdf_ra_cust_trx_att5,     -- export name    ZXTWRZTR
        gdf_ra_cust_trx_att6,     -- export method  ZXTWRZTR
        gdf_ra_cust_trx_att7,     -- export type    ZXTWRZTR
        gdf_ra_cust_trx_att8,     -- export date    ZXTWRZTR
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
   VALUES (zx_rep_trx_jx_ext_t_s.nextval,
        l_detail_tax_line_id_tbl(i),
        X_EXPORT_METHOD_TBL(i),
        X_EXPORT_CERTIFICATE_NAME_TBL(i),
        X_EXPORT_TYPE_TBL(i),
        X_GDF_RA_CUST_TRX_ATT4_TBL(i),
        X_GDF_RA_CUST_TRX_ATT5_TBL(i),
        X_GDF_RA_CUST_TRX_ATT6_TBL(i),
        X_GDF_RA_CUST_TRX_ATT7_TBL(i),
        X_GDF_RA_CUST_TRX_ATT8_TBL(i),
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.populate_ja_ar',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;
elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWSEDI'  and l_detail_tax_line_id_tbl.count <> 0 then
   INSERT INTO ZX_REP_TRX_JX_EXT_T(
        detail_tax_line_ext_id,
        detail_tax_line_id,
        document_sub_type_mng,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
        )
   SELECT
        zx_rep_trx_jx_ext_t_s.nextval,
        dtl.detail_tax_line_id,
        types.global_attribute1,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id
   FROM zx_rep_trx_detail_t dtl,
        ra_cust_trx_types_all types
  WHERE dtl.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
    and dtl.extract_source_ledger = 'AR'
    and types.cust_trx_type_id = dtl.trx_type_id
    and types.org_id = dtl.internal_organization_id ;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.populate_ja_ar',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;
elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'RXZXKVAT' THEN

                   SELECT loc.location_code,
                     loc.ADDRESS_LINE_1,
                     loc.ADDRESS_LINE_2,
                     loc.ADDRESS_LINE_3,
                     loc.TOWN_OR_CITY  ,
                     loc.REGION_1,
                     loc.REGION_2,
                     loc.POSTAL_CODE,
                     loc.COUNTRY,
                     loc.GLOBAL_ATTRIBUTE1,
                     loc.GLOBAL_ATTRIBUTE4,
                   --  loc.GLOBAL_ATTRIBUTE5,
                   --  loc.GLOBAL_ATTRIBUTE6,
              --       loc.GLOBAL_ATTRIBUTE11,
                     dtl.detail_tax_line_id
    BULK COLLECT INTO l_location_code_tbl,
                      l_address_line_1_tbl,
                      l_address_line_2_tbl,
                      l_address_line_3_tbl,
                      l_city_tbl,
                      l_region_1_tbl,
                      l_region_2_tbl,
                      l_postal_code_tbl,
                      l_country_code_tbl,
                      l_loc_tax_reg_num_tbl,
                      l_taxable_person_tbl,
                    --  l_ind_sub_classif_tbl,
                     -- l_ind_classif_tbl,
                      l_detail_tax_line_id_tbl
                 FROM zx_reporting_types_b rep_type,
                     zx_report_codes_assoc rep_ass,
                     hr_locations loc,
                     zx_rep_trx_detail_t dtl
              WHERE rep_type.reporting_type_code = 'KR_BUSINESS_LOCATIONS'
                AND rep_ass.reporting_type_id = rep_type.reporting_type_id
                AND rep_ass.entity_code = 'ZX_RATES'
                AND rep_ass.entity_id = dtl.tax_rate_id
                AND dtl.tax_regime_code = rep_type.tax_regime_code
                AND rep_ass.reporting_code_char_value = loc.location_code
                AND loc.global_attribute_category = 'JA.KR.PERWSLOC.WITHHOLDING'
                AND dtl.application_id in (222,101)
                AND dtl.request_id = p_trl_global_variables_rec.request_id ;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.populate_ja_ar',
					      'Reporting Type Query Count : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );

	END IF;

            FOR i in 1..nvl(l_detail_tax_line_id_tbl.last, 0)
            LOOP
                l_ind_classif_tbl(i) := NULL;
                l_ind_sub_classif_tbl(i) := NULL;
            END LOOP;

           IF p_trl_global_variables_rec.product = 'AR' THEN
              SELECT global_attribute8,
                     global_attribute3
             BULK COLLECT INTO
                     l_ind_classif_tbl,
                     l_ind_sub_classif_tbl
               FROM  hz_cust_acct_sites_all acct_site,
                     zx_rep_trx_detail_t dtl
              WHERE acct_site.cust_acct_site_id = NVL(dtl.shipping_tp_address_id, dtl.billing_tp_address_id)
                AND dtl.application_id = 222
                AND dtl.request_id = p_trl_global_variables_rec.request_id ;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.populate_ja_ar',
		      'AR Industry Class Query Count: '||to_char(nvl(l_ind_classif_tbl.count,0)) );
        END IF;
        END IF;


 FORALL i in 1 .. nvl(l_detail_tax_line_id_tbl.last, 0)

   INSERT INTO ZX_REP_TRX_JX_EXT_T
       (detail_tax_line_ext_id,
        detail_tax_line_id,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        request_id)
   VALUES (zx_rep_trx_jx_ext_t_s.nextval,
        l_detail_tax_line_id_tbl(i),
        l_location_code_tbl(i),
        l_address_line_1_tbl(i),
        l_address_line_2_tbl(i),
        l_address_line_3_tbl(i),
        l_city_tbl(i),
        l_region_1_tbl(i),
        l_region_2_tbl(i),
        l_postal_code_tbl(i),
        l_country_code_tbl(i),
        l_loc_tax_reg_num_tbl(i),
        l_taxable_person_tbl(i),
        l_ind_sub_classif_tbl(i),
        l_ind_classif_tbl(i),
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id,
         p_trl_global_variables_rec.request_id);

elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXSGGF5' THEN
      bank_info(P_TRL_GLOBAL_VARIABLES_REC);
end if;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.populate_ja_ar',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;

	IF (g_level_procedure >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG.populate_ja_ar.END',
				      'ZX_JA_EXTRACT_PKG.populate_ja_ar(-)');
	END IF;

EXCEPTION
WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.populate_ja_ar',
			'Error Message for report : '||substrb(SQLERRM,1,120) );
		END IF;

END populate_ja_ar;


/*===========================================================================+
 | PUBLIC PROCEDURE                                                          |
 |   POPULATE_JA_AP                                                          |
 |   Type       : Public                                                     |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure calls the API to select the JA specific data from       |
 |    JA payables tables. Currently only JA_LOOKUP_INFO plug-in is called    |
 |    inside.                                                                |
 |                                                                           |
 |    Called from ARP_TAX_EXTRACT.POPULATE_MISSING_COLUMNS.                  |
 |                                                                           |
 |   Parameters :                                                            |
 |                                                                           |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     27-Oct-03  Asako Takahashi   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/


PROCEDURE POPULATE_JA_AP
(
 P_TRL_GLOBAL_VARIABLES_REC	IN	ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
)

/* Following parameter is removed since we now access global variables directly
(
-- IN parameters are passed as global variables.

--   DETAIL_TAX_LINE_ID_TBL
--   TRX_STATUS_CODE_TBL
--   TRX_BUSINESS_CATEGORY_TBL
--   BILLING_TRADING_PARTNER_ID_TBL
--   ADJUSTED_DOC_NUMBER_TBL
--   TRX_ID_TBL
--   TAXABLE_AMT_TBL
--   TAX_AMT_TBL
--   CURRENCY_CONVERSION_RATE_TBL
--   PRECISION_TBL
--   REPRINT_TBL
   P_REPORT_NAME                IN  varchar2
)
*/

IS


TYPE GOVERNMENT_TAX_TYPE_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.TAX_STATUS_MNG%TYPE INDEX BY BINARY_INTEGER;

TYPE DEDUCTIBLE_TYPE_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.TRX_BUSINESS_CATEGORY_MNG%TYPE INDEX BY BINARY_INTEGER;

TYPE GUI_TYPE_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.DOCUMENT_SUB_TYPE_MNG%TYPE INDEX BY BINARY_INTEGER;

TYPE INVOICE_AMOUNT_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.NUMERIC12%TYPE INDEX BY BINARY_INTEGER;

TYPE BASE_AMOUNT_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.NUMERIC13%TYPE INDEX BY BINARY_INTEGER;

TYPE PRINT_DATE_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.GDF_AP_INVOICES_ATT4%TYPE INDEX BY BINARY_INTEGER;

TYPE INHOUSE_INV_AMT_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.NUMERIC1%TYPE INDEX BY BINARY_INTEGER;

TYPE SUPPLIER_INV_AMT_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.NUMERIC2%TYPE INDEX BY BINARY_INTEGER;

TYPE INHOUSE_TAX_AMT_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.NUMERIC3%TYPE INDEX BY BINARY_INTEGER;

TYPE SUPPLIER_TAX_AMT_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.NUMERIC4%TYPE INDEX BY BINARY_INTEGER;

TYPE TAXABLE_GAINLOSS_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.NUMERIC5%TYPE INDEX BY BINARY_INTEGER;

TYPE TAX_GAINLOSS_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.NUMERIC6%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE1_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER;

X_GOVERNMENT_TAX_TYPE_TBL 	GOVERNMENT_TAX_TYPE_TBL;
X_DEDUCTIBLE_TYPE_TBL 		DEDUCTIBLE_TYPE_TBL;
X_GUI_TYPE_TBL			GUI_TYPE_TBL;
X_INVOICE_AMOUNT_TBL 		INVOICE_AMOUNT_TBL;
X_BASE_AMOUNT_TBL 		BASE_AMOUNT_TBL;
X_PRINT_DATE_TBL 		PRINT_DATE_TBL;
X_INHOUSE_INV_AMT_TBL 		INHOUSE_INV_AMT_TBL;
X_SUPPLIER_INV_AMT_TBL 		SUPPLIER_INV_AMT_TBL;
X_INHOUSE_TAX_AMT_TBL 		INHOUSE_TAX_AMT_TBL;
X_SUPPLIER_TAX_AMT_TBL		SUPPLIER_TAX_AMT_TBL;
X_TAXABLE_GAINLOSS_TBL 		TAXABLE_GAINLOSS_TBL;
X_TAX_GAINLOSS_TBL 		TAX_GAINLOSS_TBL;

L_INHOUSE_INV_AMT_TBL 		INHOUSE_INV_AMT_TBL;
L_SUPPLIER_INV_AMT_TBL 		SUPPLIER_INV_AMT_TBL;
L_INHOUSE_TAX_AMT_TBL 		INHOUSE_TAX_AMT_TBL;
L_SUPPLIER_TAX_AMT_TBL		SUPPLIER_TAX_AMT_TBL;
L_TAXABLE_GAINLOSS_TBL 		TAXABLE_GAINLOSS_TBL;
L_TAX_GAINLOSS_TBL 		TAX_GAINLOSS_TBL;

P_LOOKUP_TYPE    varchar2(100);
P_LOOKUP_CODE    varchar2(1000);
P_VENDOR_ID      number(15);
P_INVOICE_NUM    varchar2(30);
l_trx_date_tbl zx_extract_pkg.trx_date_tbl;

l_detail_tax_line_id_tbl           ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
l_trx_id_tbl                       ZX_EXTRACT_PKG.TRX_ID_TBL;
l_trx_line_id_tbl                       ZX_EXTRACT_PKG.TRX_LINE_ID_TBL;
l_tax_status_code_tbl              ZX_EXTRACT_PKG.TAX_STATUS_CODE_TBL;
l_tax_status_id_tbl                ZX_EXTRACT_PKG.TAX_STATUS_ID_TBL;
l_trx_business_category_tbl        ZX_EXTRACT_PKG.TRX_BUSINESS_CATEGORY_TBL;
l_document_sub_type_tbl            ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL;
l_billing_tp_id_tbl   		   ZX_EXTRACT_PKG.BILLING_TRADING_PARTNER_ID_TBL;
l_adjusted_doc_number_tbl          ZX_EXTRACT_PKG.ADJUSTED_DOC_NUMBER_TBL;
l_taxable_amt_tbl                  ZX_EXTRACT_PKG.TAXABLE_AMT_TBL;
l_currency_conversion_rate_tbl     ZX_EXTRACT_PKG.CURRENCY_CONVERSION_RATE_TBL;
l_precision_tbl                    ZX_EXTRACT_PKG.PRECISION_TBL;
l_supplier_exchange_rate_tbl       ZX_EXTRACT_PKG.SUPPLIER_EXCHANGE_RATE_TBL;
l_tax_amt_tbl                      ZX_EXTRACT_PKG.TAX_AMT_TBL;
l_applied_to_trx_number_tbl        ZX_EXTRACT_PKG.APPLIED_TO_TRX_NUMBER_TBL;

    l_location_code_tbl           ATTRIBUTE1_TBL;
l_address_line_1_tbl          ATTRIBUTE1_TBL;
l_address_line_2_tbl          ATTRIBUTE1_TBL;
l_address_line_3_tbl          ATTRIBUTE1_TBL;
l_city_tbl                    ATTRIBUTE1_TBL;
l_region_1_tbl                ATTRIBUTE1_TBL;
l_region_2_tbl                ATTRIBUTE1_TBL;
l_postal_code_tbl             ATTRIBUTE1_TBL;
l_country_code_tbl            ATTRIBUTE1_TBL;
l_loc_tax_reg_num_tbl         ATTRIBUTE1_TBL;
l_taxable_person_tbl          ATTRIBUTE1_TBL;
l_ind_sub_classif_tbl         ATTRIBUTE1_TBL;
l_ind_classif_tbl             ATTRIBUTE1_TBL;
k number;


BEGIN

   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

	IF (g_level_procedure >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP.BEGIN',
				      'ZX_JA_EXTRACT_PKG.POPULATE_JA_AP(+)');
	END IF;

SELECT  detail_tax_line_id,
        trx_id,
        trx_line_id,
        tax_status_id,
        tax_status_code,
        trx_business_category,
        document_sub_type,
        billing_trading_partner_id,
        adjusted_doc_number,
        taxable_amt,
        currency_conversion_rate,
        precision,
        supplier_exchange_rate,
        tax_amt,
        applied_to_trx_number,
        trx_date
BULK COLLECT INTO  l_detail_tax_line_id_tbl,
        l_trx_id_tbl,
        l_trx_line_id_tbl,  --Bug#5673935
        l_tax_status_id_tbl,
        l_tax_status_code_tbl,
        l_trx_business_category_tbl,
        l_document_sub_type_tbl,
        l_billing_tp_id_tbl,
        l_adjusted_doc_number_tbl,
        l_taxable_amt_tbl,
        l_currency_conversion_rate_tbl,
        l_precision_tbl,
        l_supplier_exchange_rate_tbl,
        l_tax_amt_tbl,
        l_applied_to_trx_number_tbl,
        l_trx_date_tbl
FROM  zx_rep_trx_detail_t itf1
WHERE  itf1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
	END IF;

P_LOOKUP_CODE:= NULL;

if P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = ('ZXTWPVAT') and l_detail_tax_line_id_tbl.count <> 0 then
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.TRL.ja_tax_extract.populate_ja_ap',
                      'ZXTWPVAT');
    END IF;
/******  Populate the missing columns   ********/
   FOR i in 1 .. nvl(l_detail_tax_line_id_tbl.count,0) LOOP

      P_LOOKUP_TYPE:= 'JATW_GOVERNMENT_TAX_TYPE';
     P_LOOKUP_CODE:= l_tax_status_code_tbl(i); --Bug 5438409
    --  P_LOOKUP_CODE:=l_tax_status_id_tbl(i);

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.TRL.ja_tax_extract.populate_ja_ap',
                      'P_LOOKUP_CODE:'||P_LOOKUP_CODE||'-'||to_char(l_tax_status_id_tbl(i)));
    END IF;

      X_GOVERNMENT_TAX_TYPE_TBL(i):= GET_LOOKUP_INFO(P_LOOKUP_TYPE, P_LOOKUP_CODE, l_trx_date_tbl(i));

      P_LOOKUP_TYPE:= 'JATW_DEDUCTIBLE_TYPE';
      P_LOOKUP_CODE := l_trx_business_category_tbl(i); --BUG 5517615
--      select translate(l_trx_business_category_tbl(i), '0123456789.ABCDEFGHIJKLMNOPQRSTUVWXYZ', '0123456789') into P_LOOKUP_CODE from dual;
      X_DEDUCTIBLE_TYPE_TBL(i):= GET_LOOKUP_INFO(P_LOOKUP_TYPE, P_LOOKUP_CODE, l_trx_date_tbl(i));

   END LOOP;

/******    Bulk Insert into Ext Table      *******/
 FORALL i in 1 .. nvl(l_detail_tax_line_id_tbl.last, 0)

  INSERT INTO ZX_REP_TRX_JX_EXT_T
       (detail_tax_line_ext_id,
        detail_tax_line_id,
        tax_status_mng,     -- government tax type meaning
        trx_business_category_mng,     -- deductible code meaning
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
  VALUES (zx_rep_trx_jx_ext_t_s.nextval,
        l_detail_tax_line_id_tbl(i),
        X_GOVERNMENT_TAX_TYPE_TBL(i),
        X_DEDUCTIBLE_TYPE_TBL(i),
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;
elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWSPRF'  and l_detail_tax_line_id_tbl.count <> 0 then

/******  Populate the missing columns   ********/
   FOR i in 1 .. nvl(l_detail_tax_line_id_tbl.count,0) LOOP
	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'Processing detail_tax_line_id : '||l_detail_tax_line_id_tbl(i)||' trx id : '||l_trx_id_tbl(i));
	END IF;

      P_LOOKUP_TYPE:= 'JATW_GUI_TYPE';
--      select substrb(l_document_sub_type_tbl(i), 10,2) into P_LOOKUP_CODE from dual;
--Bug 5453957
       p_lookup_code := l_document_sub_type_tbl(i);
      X_GUI_TYPE_TBL(i):= GET_LOOKUP_INFO(P_LOOKUP_TYPE, P_LOOKUP_CODE, l_trx_date_tbl(i));

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'Debug 1');
	END IF;

      P_LOOKUP_TYPE:= 'JATW_GOVERNMENT_TAX_TYPE';
      P_LOOKUP_CODE:= l_tax_status_code_tbl(i);
      X_GOVERNMENT_TAX_TYPE_TBL(i):= GET_LOOKUP_INFO(P_LOOKUP_TYPE, P_LOOKUP_CODE, l_trx_date_tbl(i));

      	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'Debug 2');
	END IF;

      P_LOOKUP_TYPE:= 'JATW_DEDUCTIBLE_TYPE';
--Bug 5453957
      p_lookup_code := l_trx_business_category_tbl(i);
--      select translate(l_trx_business_category_tbl(i), '0123456789.ABCDEFGHIJKLMNOPQRSTUVWXYZ', '0123456789') into P_LOOKUP_CODE from dual;
      X_DEDUCTIBLE_TYPE_TBL(i):= GET_LOOKUP_INFO(P_LOOKUP_TYPE, P_LOOKUP_CODE, l_trx_date_tbl(i));

      	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'Debug 3');
	END IF;

   END LOOP;

/******    Bulk Insert into Ext Table      *******/

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'Before into zx_rep_trx_jx_ext_t ap ');
	END IF;

 FORALL i in 1 .. nvl(l_detail_tax_line_id_tbl.last, 0)

  INSERT INTO ZX_REP_TRX_JX_EXT_T
       (detail_tax_line_ext_id,
        detail_tax_line_id,
        tax_status_mng,     -- government tax type meaning
        trx_business_category_mng,     -- deductible code meaning
        document_sub_type_mng,       -- document subtype meaning
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
  VALUES (zx_rep_trx_jx_ext_t_s.nextval,
        l_detail_tax_line_id_tbl(i),
        X_GOVERNMENT_TAX_TYPE_TBL(i),
        X_DEDUCTIBLE_TYPE_TBL(i),
        X_GUI_TYPE_TBL(i),
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;
elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = ('ZXTWPSPC')  and l_detail_tax_line_id_tbl.count <> 0 then

/******  Populate the missing columns   ********/

   FOR i in 1 .. nvl(l_detail_tax_line_id_tbl.count,0) LOOP

   -- get print_date, document and document base amount
      P_VENDOR_ID:= l_billing_tp_id_tbl(i);
      --  P_INVOICE_NUM:= l_applied_to_trx_number_tbl(i);  --replaced with below
      P_INVOICE_NUM:= l_adjusted_doc_number_tbl(i);
      GET_INVOICE_AMT(P_VENDOR_ID, P_INVOICE_NUM, X_INVOICE_AMOUNT_TBL(i), X_BASE_AMOUNT_TBL(i), X_PRINT_DATE_TBL(i));

   -- update print date
   -- Print Date is null which means the first time this certificate is
   -- submitted.
   --
   -- Print Date is not null which means this certificate was submitted
   -- before.  In this case, if reprint = 'Y', it will update print date.
   if ((X_PRINT_DATE_TBL(i) IS NULL)
-- Need to verify       or (P_TRL_GLOBAL_VARIABLES_REC.REPRINT = 'Y' and X_PRINT_DATE_TBL(i) is not null)
      ) then
     UPDATE_PRINT_DATE(l_trx_id_tbl(i));
   end if;

   END LOOP;

/******    Bulk Insert into Ext Table      *******/
 FORALL i in 1 .. nvl(l_detail_tax_line_id_tbl.last, 0)

  INSERT INTO ZX_REP_TRX_JX_EXT_T
       (detail_tax_line_ext_id,
        detail_tax_line_id,
        gdf_ap_invoices_att4,    -- print date
        numeric12,   -- document amount
        numeric13,   -- document base amount
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
  VALUES (zx_rep_trx_jx_ext_t_s.nextval,
        l_detail_tax_line_id_tbl(i),
        X_PRINT_DATE_TBL(i),
        X_INVOICE_AMOUNT_TBL(i),
        X_BASE_AMOUNT_TBL(i),
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;
elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWPPRD'  and l_detail_tax_line_id_tbl.count <> 0 then

/******  Populate the missing columns   ********/

   FOR i in 1 .. nvl(l_detail_tax_line_id_tbl.count,0) LOOP

   -- get print_date, document and document base amount
      P_VENDOR_ID:= l_billing_tp_id_tbl(i);
      --  P_INVOICE_NUM:= l_applied_to_trx_number_tbl(i);  --replaced with below
      P_INVOICE_NUM:= l_adjusted_doc_number_tbl(i);
      GET_INVOICE_AMT(P_VENDOR_ID, P_INVOICE_NUM, X_INVOICE_AMOUNT_TBL(i), X_BASE_AMOUNT_TBL(i), X_PRINT_DATE_TBL(i));
   END LOOP;


/******    Bulk Insert into Ext Table      *******/
 FORALL i in 1 .. nvl(l_detail_tax_line_id_tbl.last, 0)

  INSERT INTO ZX_REP_TRX_JX_EXT_T
       (detail_tax_line_ext_id,
        detail_tax_line_id,
        numeric12,   -- document amount
        numeric13,   -- document base amount
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
  VALUES (zx_rep_trx_jx_ext_t_s.nextval,
        l_detail_tax_line_id_tbl(i),
        X_INVOICE_AMOUNT_TBL(i),
        X_BASE_AMOUNT_TBL(i),
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;

       ELSIF P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXTWSEDI'  AND l_detail_tax_line_id_tbl.count <> 0 then

        IF ( g_level_statement>= g_current_runtime_level ) THEN
	    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JE_AP',
	       'P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME : '||P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME);
	END IF;

	INSERT INTO zx_rep_trx_jx_ext_t (
         request_id,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         detail_tax_line_ext_id,
         detail_tax_line_id,
         document_sub_type_mng,
         numeric1,
         numeric2,
         numeric3,
         numeric4
         )
       SELECT
         p_trl_global_variables_rec.request_id,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.login_id,
         zx_rep_trx_jx_ext_t_s.NEXTVAL,
         detail_tax_line_id,
         document_sub_type,
         CASE WHEN tax_line_change= 1 OR tax_recoverable_flag = 'N' THEN taxable_amt
              ELSE 0
         END,
         CASE WHEN tax_line_change= 1 OR tax_recoverable_flag = 'N' THEN taxable_amt_funcl_curr
              ELSE 0
         END,
         tax_amt,
         tax_amt_funcl_curr
      FROM (
        SELECT itf.detail_tax_line_id,
               itf.document_sub_type,
               itf.tax_amt,
               itf.tax_amt_funcl_curr,
               itf.taxable_amt,
               itf.taxable_amt_funcl_curr,
               itf.tax_recoverable_flag,
               RANK() OVER (PARTITION BY itf.trx_id,
                                         itf.trx_line_id
                            ORDER BY NVL(itf.tax_recoverable_flag,'N'),
                                     itf.actg_source_id,
                                     itf.detail_tax_line_id
                            ) AS tax_line_change
         FROM zx_rep_trx_detail_t itf
        WHERE itf.request_id = p_trl_global_variables_rec.request_id
          AND itf.application_id = 200);
elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'ZXSGAGAL'  and l_detail_tax_line_id_tbl.count <> 0 then

/******  Populate the missing columns   ********/

   FOR i in 1 .. nvl(l_detail_tax_line_id_tbl.count,0) LOOP
       k:= to_number(to_char(l_trx_id_tbl(i))||to_char(l_trx_line_id_tbl(i)));

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'l_trx_id_tbl(i) : '||l_trx_id_tbl(i));
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'l_trx_line_id_tbl(i) : '||l_trx_line_id_tbl(i));
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'i : '||i||'  k : '||k);
	END IF;

           IF L_INHOUSE_INV_AMT_TBL.EXISTS(k) THEN
              null;
           ELSE
              L_INHOUSE_INV_AMT_TBL(k) := null;
           END IF;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'L_INHOUSE_INV_AMT_TBL(k) : '||L_INHOUSE_INV_AMT_TBL(k));
	END IF;

       IF L_INHOUSE_INV_AMT_TBL(k) is NULL THEN

   -- get inhouse and supplier invoice rated taxable/tax amount
          L_INHOUSE_INV_AMT_TBL(k):= round(l_taxable_amt_tbl(i) *
                                    to_number(nvl(l_currency_conversion_rate_tbl(i),1)), l_precision_tbl(i));
          L_SUPPLIER_INV_AMT_TBL(k):= round(l_taxable_amt_tbl(i) *
                                    to_number(nvl(l_supplier_exchange_rate_tbl(i),1)), l_precision_tbl(i));
          L_TAXABLE_GAINLOSS_TBL(k):= L_INHOUSE_INV_AMT_TBL(k) - L_SUPPLIER_INV_AMT_TBL(k);
       ELSE
          L_INHOUSE_INV_AMT_TBL(k):= 0;
          L_SUPPLIER_INV_AMT_TBL(k):=  0;
          L_TAXABLE_GAINLOSS_TBL(k):= 0;
       END IF;
          X_INHOUSE_INV_AMT_TBL(i):= L_INHOUSE_INV_AMT_TBL(k);
          X_SUPPLIER_INV_AMT_TBL(i):=L_SUPPLIER_INV_AMT_TBL(k);
          X_TAXABLE_GAINLOSS_TBL(i):= L_TAXABLE_GAINLOSS_TBL(k);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'X_INHOUSE_INV_AMT_TBL(i) : '||X_INHOUSE_INV_AMT_TBL(i));
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'X_SUPPLIER_INV_AMT_TBL(i) : '||X_SUPPLIER_INV_AMT_TBL(i));
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'X_TAXABLE_GAINLOSS_TBL(i) : '||X_TAXABLE_GAINLOSS_TBL(i));
	END IF;

      X_INHOUSE_TAX_AMT_TBL(i):= round(l_tax_amt_tbl(i) *
                                    to_number(nvl(l_currency_conversion_rate_tbl(i),1)), l_precision_tbl(i));
      X_SUPPLIER_TAX_AMT_TBL(i):= round(l_tax_amt_tbl(i) *
                                    to_number(nvl(l_supplier_exchange_rate_tbl(i),1)), l_precision_tbl(i));
      X_TAX_GAINLOSS_TBL(i):= X_INHOUSE_TAX_AMT_TBL(i) - X_SUPPLIER_TAX_AMT_TBL(i);

      	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'X_INHOUSE_TAX_AMT_TBL(i) : '||X_INHOUSE_TAX_AMT_TBL(i));
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'X_SUPPLIER_TAX_AMT_TBL(i) : '||X_SUPPLIER_TAX_AMT_TBL(i));
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'X_TAX_GAINLOSS_TBL(i) : '||X_TAX_GAINLOSS_TBL(i));
	END IF;

/*
   -- get inhouse and supplier invoice rated taxable/tax amount
      X_INHOUSE_INV_AMT_TBL(i):= round(l_taxable_amt_tbl(i) *
                                    to_number(nvl(l_currency_conversion_rate_tbl(i),1)), l_precision_tbl(i));
      X_SUPPLIER_INV_AMT_TBL(i):= round(l_taxable_amt_tbl(i) *
                                    to_number(nvl(l_supplier_exchange_rate_tbl(i),1)), l_precision_tbl(i));
      X_INHOUSE_TAX_AMT_TBL(i):= round(l_tax_amt_tbl(i) *
                                    to_number(nvl(l_currency_conversion_rate_tbl(i),1)), l_precision_tbl(i));
      X_SUPPLIER_TAX_AMT_TBL(i):= round(l_tax_amt_tbl(i) *
                                    to_number(nvl(l_supplier_exchange_rate_tbl(i),1)), l_precision_tbl(i));
      X_TAXABLE_GAINLOSS_TBL(i):= X_INHOUSE_INV_AMT_TBL(i) - X_SUPPLIER_INV_AMT_TBL(i);
      X_TAX_GAINLOSS_TBL(i):= X_INHOUSE_TAX_AMT_TBL(i) - X_SUPPLIER_TAX_AMT_TBL(i);
*/
   END LOOP;


/******    Bulk Insert into Ext Table      *******/
 FORALL i in 1 .. nvl(l_detail_tax_line_id_tbl.last, 0)

  INSERT INTO ZX_REP_TRX_JX_EXT_T
       (detail_tax_line_ext_id,
        detail_tax_line_id,
        numeric1,   -- inhouse invoice amt
        numeric2,   -- supplier invoice amt
        numeric3,   -- inhouse tax amt
        numeric4,   -- supplier tax amt
        numeric5,   -- taxable gainloss
        numeric6,   -- gainloss
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
  VALUES (zx_rep_trx_jx_ext_t_s.nextval,
        l_detail_tax_line_id_tbl(i),
        X_INHOUSE_INV_AMT_TBL(i),
        X_SUPPLIER_INV_AMT_TBL(i),
        X_INHOUSE_TAX_AMT_TBL(i),
        X_SUPPLIER_TAX_AMT_TBL(i),
        X_TAXABLE_GAINLOSS_TBL(i),
        X_TAX_GAINLOSS_TBL(i),
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;


elsif P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'RXZXKVAT' THEN

                   SELECT loc.location_code,
                     loc.ADDRESS_LINE_1,
                     loc.ADDRESS_LINE_2,
                     loc.ADDRESS_LINE_3,
                     loc.TOWN_OR_CITY  ,
                     loc.REGION_1,
                     loc.REGION_2,
                     loc.POSTAL_CODE,
                     loc.COUNTRY,
                     loc.GLOBAL_ATTRIBUTE1,
                     loc.GLOBAL_ATTRIBUTE4,
                   --  loc.GLOBAL_ATTRIBUTE5,
                   --  loc.GLOBAL_ATTRIBUTE6,
              --       loc.GLOBAL_ATTRIBUTE11,
                     dtl.detail_tax_line_id
    BULK COLLECT INTO l_location_code_tbl,
                      l_address_line_1_tbl,
                      l_address_line_2_tbl,
                      l_address_line_3_tbl,
                      l_city_tbl,
                      l_region_1_tbl,
                      l_region_2_tbl,
                      l_postal_code_tbl,
                      l_country_code_tbl,
                      l_loc_tax_reg_num_tbl,
                      l_taxable_person_tbl,
                    --  l_ind_sub_classif_tbl,
                     -- l_ind_classif_tbl,
                      l_detail_tax_line_id_tbl
                 FROM zx_reporting_types_b rep_type,
                     zx_report_codes_assoc rep_ass,
                     hr_locations loc,
                     zx_rep_trx_detail_t dtl
              WHERE rep_type.reporting_type_code = 'KR_BUSINESS_LOCATIONS'
                AND rep_ass.reporting_type_id = rep_type.reporting_type_id
                AND rep_ass.entity_code = 'ZX_RATES'
                AND rep_ass.entity_id = dtl.tax_rate_id
                AND dtl.tax_regime_code = rep_type.tax_regime_code
                AND rep_ass.reporting_code_char_value = loc.location_code
                AND loc.global_attribute_category = 'JA.KR.PERWSLOC.WITHHOLDING'
                AND dtl.application_id = 200
                AND dtl.request_id = p_trl_global_variables_rec.request_id ;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.populate_ja_ar',
			'Reporting Types Query Count : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );

	END IF;


             SELECT global_attribute4,
                     global_attribute5
             BULK COLLECT INTO
                     l_ind_classif_tbl,
                     l_ind_sub_classif_tbl
               FROM  ap_supplier_sites_all sup_site,
                     zx_rep_trx_detail_t dtl
              WHERE sup_site.vendor_site_id = NVL(dtl.shipping_tp_address_id, dtl.billing_tp_address_id)
                AND dtl.application_id = 200
                AND dtl.request_id = p_trl_global_variables_rec.request_id ;

        IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.populate_ja_ar',
                               'AP Industry Class Query Count: '||to_char(nvl(l_ind_classif_tbl.count,0)) );
        END IF;


 FORALL i in 1 .. nvl(l_detail_tax_line_id_tbl.last, 0)

   INSERT INTO ZX_REP_TRX_JX_EXT_T
       (detail_tax_line_ext_id,
        detail_tax_line_id,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        request_id)
   VALUES (zx_rep_trx_jx_ext_t_s.nextval,
        l_detail_tax_line_id_tbl(i),
        l_location_code_tbl(i),
        l_address_line_1_tbl(i),
        l_address_line_2_tbl(i),
        l_address_line_3_tbl(i),
        l_city_tbl(i),
        l_region_1_tbl(i),
        l_region_2_tbl(i),
        l_postal_code_tbl(i),
        l_country_code_tbl(i),
        l_loc_tax_reg_num_tbl(i),
        l_taxable_person_tbl(i),
        l_ind_sub_classif_tbl(i),
        l_ind_classif_tbl(i),
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id,
        p_trl_global_variables_rec.request_id);

end if;

	IF (g_level_procedure >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP.END',
				      'ZX_JA_EXTRACT_PKG.POPULATE_JA_AP(-)');
	END IF;

EXCEPTION
WHEN OTHERS THEN

		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
			'Error Message for report : '||substrb(SQLERRM,1,120) );
		END IF;
END populate_ja_ap;



/*===========================================================================+
 | FUNCTION                                                                  |
 |   GET_LOOKUP_INFO                                                         |
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This plug-in is used to fetch lookup meaning for                       |
 |    a given lookup type from JA_LOOKUPS                                    |
 |                                                                           |
 |    Called from ZX_JA_EXTRACT_PKG.POPULATE                                    |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :                                                            |
 |                 p_lookup_type IN VARCHAR2   Required                      |
 |                 p_lookup_code IN VARCHAR2                                 |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     27-Oct-03  Asako Takahashi   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

FUNCTION GET_LOOKUP_INFO
(
P_LOOKUP_TYPE              IN VARCHAR2,
P_LOOKUP_CODE              IN VARCHAR2,
P_TRX_DATE                 IN  DATE
)
return varchar2 IS

    x_lookup_meaning   VARCHAR2(80);

BEGIN
   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.TRL.ja_tax_extract.get_lookup_info',
                      'x_lookup_meaning:'||x_lookup_meaning);
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
                                      'GET_LOOKUP_INFO(+)');
   END IF;

       IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
	' P_LOOKUP_TYPE : '||P_LOOKUP_TYPE );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
	' P_LOOKUP_CODE : '||P_LOOKUP_CODE );
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
	' LANG : '||userenv('LANG') );
    END IF;

   IF P_LOOKUP_TYPE = 'JATW_GUI_TYPE' then
     BEGIN
       SELECT CLASSIFICATION_NAME
       INTO  x_lookup_meaning
       FROM ZX_FC_CODES_DENORM_B
       WHERE CLASSIFICATION_TYPE_CODE = 'DOCUMENT_SUBTYPE' and
--          CLASSIFICATION_CODE_LEVEL = 2 and --Bug5453806
            CONCAT_CLASSIF_CODE = P_LOOKUP_CODE
	    AND LANGUAGE = userenv('LANG') --Bug 5453957
            and p_trx_date >= effective_from and p_trx_date <= nvl(effective_to, p_trx_date);
     EXCEPTION
       WHEN no_data_found THEN
         x_lookup_meaning := NULL;
    END ;

   ELSIF P_LOOKUP_TYPE = 'JATW_GOVERNMENT_TAX_TYPE' then
     BEGIN
       SELECT TAX_STATUS_NAME
       INTO  x_lookup_meaning
       FROM ZX_STATUS_TL stl, zx_status_b sb
       WHERE sb.tax_status_code = P_LOOKUP_CODE
         AND sb.tax_status_id = stl.tax_status_id
         AND LANGUAGE = userenv('LANG')
        and p_trx_date >= effective_from and p_trx_date <= nvl(effective_to, p_trx_date);
     EXCEPTION
       WHEN no_data_found THEN
         x_lookup_meaning := NULL;
     END;


   ELSIF P_LOOKUP_TYPE = 'JATW_DEDUCTIBLE_TYPE' then
     BEGIN
      SELECT CLASSIFICATION_NAME
      INTO  x_lookup_meaning
      FROM ZX_FC_CODES_DENORM_B
      WHERE CLASSIFICATION_TYPE_CODE = 'TRX_BUSINESS_CATEGORY' and
--            CLASSIFICATION_CODE_LEVEL = 3 and --Bug5453806
            CONCAT_CLASSIF_CODE = P_LOOKUP_CODE
	    AND LANGUAGE = userenv('LANG') --Bug 5453957
            and p_trx_date >= effective_from and p_trx_date <= nvl(effective_to, p_trx_date);
     EXCEPTION
       WHEN no_data_found THEN
        x_lookup_meaning := NULL;
     END;
   ELSE
     BEGIN
      SELECT JA.MEANING
        INTO X_LOOKUP_MEANING
        FROM JA_LOOKUPS JA
        WHERE JA.LOOKUP_TYPE = P_LOOKUP_TYPE and
              JA.LOOKUP_CODE = P_LOOKUP_CODE
            and p_trx_date >= start_date_active and p_trx_date <= nvl(end_date_active, p_trx_date);
     EXCEPTION
       WHEN no_data_found THEN
         x_lookup_meaning := NULL;
      END;
   END IF;


   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.TRL.ja_tax_extract.get_lookup_info',
                      'x_lookup_meaning:'||x_lookup_meaning);
    END IF;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
                                      'GET_LOOKUP_INFO(-)');
   END IF;

   return (X_LOOKUP_MEANING);

   EXCEPTION

      WHEN NO_DATA_FOUND THEN
           return (NULL);

      WHEN OTHERS THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
			'Error Message : '||substrb(SQLERRM,1,120) );
		END IF;
	 return (NULL);


END get_lookup_info;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   GET_INVOICE_AMT                                                         |
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This plug-in is used to fetch invoce_amount and base amount            |
 |    from AP_INVOICES table                                                 |
 |                                                                           |
 |    Called from ZX_JA_EXTRACT_PKG.POPULATE                                    |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :                                                            |
 |                 p_vendor_id IN NUMBER   Required                          |
 |                 p_invoice_num IN VARCHAR2                                 |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     27-Oct-03  Asako Takahashi   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE GET_INVOICE_AMT
(
P_VENDOR_ID      IN NUMBER,
P_INVOICE_NUM    IN VARCHAR2,
X_INVOICE_AMT    OUT NOCOPY  ZX_REP_TRX_JX_EXT_T.NUMERIC12%TYPE,
X_BASE_AMT       OUT NOCOPY  ZX_REP_TRX_JX_EXT_T.NUMERIC13%TYPE,
X_PRINT_DATE     OUT NOCOPY  ZX_REP_TRX_JX_EXT_T.GDF_AP_INVOICES_ATT4%TYPE
)

IS
BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
                                      'GET_INVOICE_AMT(+)');
   END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
	' P_VENDOR_ID : '||P_VENDOR_ID );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
	' P_INVOICE_NUM : '||P_INVOICE_NUM );
    END IF;

   SELECT AI.GLOBAL_ATTRIBUTE4, AI.INVOICE_AMOUNT, AI.BASE_AMOUNT
     INTO X_PRINT_DATE, X_INVOICE_AMT, X_BASE_AMT
     FROM AP_INVOICES AI
     WHERE AI.VENDOR_ID = P_VENDOR_ID and
           AI.INVOICE_NUM = P_INVOICE_NUM;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
	' X_INVOICE_AMT : '||X_INVOICE_AMT );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
	' X_BASE_AMT : '||X_BASE_AMT );
    END IF;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
                                      'GET_INVOICE_AMT(-)');
   END IF;


   EXCEPTION

   WHEN NO_DATA_FOUND THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
			'Error Message : '||substrb(SQLERRM,1,120) );
		END IF;

END get_invoice_amt;


/*===========================================================================+
 | FUNCTION                                                                  |
 |   GET_GUI_SOURCE
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This plug-in is used to fetch the following values for ZXTWRUIL        |
 |          reference_transaction_source                                     |
 |          initial trx number                                               |
 |          invoice word                                                     |
 |          final trx number                                                 |
 |                                                                           |
 |    Called from ZX_JA_EXTRACT_PKG.POPULATE                                    |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :                                                            |
 |                 p_trx_source_name IN VARCHAR2  Required                   |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     27-Oct-03  Asako Takahashi   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE GET_GUI_SOURCE
(
P_TRX_SOURCE_NAME IN VARCHAR2,
X_GDF_RA_BATCH_SOURCES_ATT1   OUT NOCOPY  ZX_REP_TRX_JX_EXT_T.GDF_RA_BATCH_SOURCES_ATT1%TYPE, -- reference transaction source
X_GDF_RA_BATCH_SOURCES_ATT2   OUT NOCOPY  ZX_REP_TRX_JX_EXT_T.GDF_RA_BATCH_SOURCES_ATT2%TYPE,  -- initial trx num
X_GDF_RA_BATCH_SOURCES_ATT3   OUT NOCOPY  ZX_REP_TRX_JX_EXT_T.GDF_RA_BATCH_SOURCES_ATT3%TYPE,  -- invoice word
X_GDF_RA_BATCH_SOURCES_ATT4   OUT NOCOPY  ZX_REP_TRX_JX_EXT_T.GDF_RA_BATCH_SOURCES_ATT4%TYPE   -- final trx num

)
IS

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
                                      'GET_GUI_SOURCE(+)');
   END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' P_TRX_SOURCE_NAME : '||P_TRX_SOURCE_NAME );
    END IF;

 IF P_TRX_SOURCE_NAME is not null THEN
    SELECT decode(src.global_attribute1, NULL, src.batch_source_id,
                  src.global_attribute1)
    INTO X_GDF_RA_BATCH_SOURCES_ATT1
    FROM ra_batch_sources src
    WHERE src.name = P_TRX_SOURCE_NAME;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' X_GDF_RA_BATCH_SOURCES_ATT1 : '||X_GDF_RA_BATCH_SOURCES_ATT1 );
   END IF;

    SELECT substr(global_attribute3,1,2),
           to_number(global_attribute2),
           to_number(global_attribute4)
    INTO X_GDF_RA_BATCH_SOURCES_ATT3,
         X_GDF_RA_BATCH_SOURCES_ATT2,
         X_GDF_RA_BATCH_SOURCES_ATT4
    FROM ra_batch_sources
    WHERE batch_source_id = X_GDF_RA_BATCH_SOURCES_ATT1;

 END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' X_GDF_RA_BATCH_SOURCES_ATT2 : '||X_GDF_RA_BATCH_SOURCES_ATT2 );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' X_GDF_RA_BATCH_SOURCES_ATT3 : '||X_GDF_RA_BATCH_SOURCES_ATT3 );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' X_GDF_RA_BATCH_SOURCES_ATT4 : '||X_GDF_RA_BATCH_SOURCES_ATT4 );
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
                                      'GET_GUI_SOURCE(-)');
   END IF;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
			'Error Message : '||substrb(SQLERRM,1,120) );
		END IF;

END get_gui_source;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   UPDATE_PRINT_DATE                                                       |
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This plug-in updates print date stored in ap_invoices table for        |
 |    ZXTWPSPC                                                               |
 |                                                                           |
 |    Called from ZX_JA_EXTRACT_PKG.POPULATE                                    |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :                                                            |
 |                 p_trx_id IN NUMBER   Required                             |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     27-Oct-03  Asako Takahashi   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/


PROCEDURE UPDATE_PRINT_DATE
(
p_invoice_id   number
)
IS

  l_dummy   varchar2(150);

  CURSOR c_invoice (l_invoice_id NUMBER)
    IS SELECT ai.global_attribute4
       FROM ap_invoices ai
       WHERE ai.invoice_id = l_invoice_id
       FOR UPDATE NOWAIT;

BEGIN
  --
  -- Description:
  -- Update Print Date with Sysdate.
  --
  -- Called From:
  -- G_Vendor_NameGroupFilter
  --
  -- Note:
  -- Cannot use 'CURRENT OF' for 'SELECT FOR UPDATE NOWAIT'
  -- because of bug 219936.
  --
    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
                                      'UPDATE_PRINT_DATE(+)');
   END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' p_invoice_id : '||p_invoice_id );
    END IF;

 OPEN c_invoice(p_invoice_id);
 LOOP
    FETCH c_invoice INTO l_dummy;
    EXIT WHEN c_invoice%NOTFOUND;

    UPDATE
        ap_invoices
    SET
        global_attribute4 = fnd_date.date_to_canonical(sysdate)
    WHERE
        invoice_id = p_invoice_id;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JA_AP',
				      'Update Count : '||to_char(SQL%ROWCOUNT) );
	END IF;
 END LOOP;
 CLOSE c_invoice;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
                                      'UPDATE_PRINT_DATE(-)');
   END IF;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
			'Error Message : '||substrb(SQLERRM,1,120) );
		END IF;


END update_print_date;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |   GET_ORG_TRX_NUMBER                                                      |
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This plug-in is used to fetch the following values for ZXTWRUIL        |
 |          original transaction number                                      |
 |                                                                           |
 |    Called from ZX_JA_EXTRACT_PKG.POPULATE                                    |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :                                                            |
 |                 p_request_id IN NUMBER   Required                         |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     27-Oct-03  Asako Takahashi   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/


PROCEDURE GET_ORG_TRX_NUMBER
(
P_TRX_SOURCE_ID    IN NUMBER,
P_TRX_ID           IN NUMBER,
X_ORG_TRX_NUMBER   OUT NOCOPY   ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT9%TYPE   -- org trx num

)
IS

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
                                      'GET_ORG_TRX_NUMBER(+)');
   END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' P_TRX_SOURCE_ID : '||P_TRX_SOURCE_ID );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' P_TRX_ID : '||P_TRX_ID );
    END IF;

 IF P_TRX_SOURCE_ID is not null THEN
    SELECT rct_org.trx_number
    INTO X_ORG_TRX_NUMBER
    FROM ra_customer_trx_all rct,
         ra_customer_trx_all rct_org,
         ra_batcH_sources_all rbs
    WHERE rct_org.customer_Trx_id = rct.previous_customer_trx_id and
          rct.batch_source_id = rbs.batch_source_id and
          rbs.batch_source_id = P_TRX_SOURCE_ID and
          rct.customer_trx_id = p_trx_id;

 END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' X_ORG_TRX_NUMBER : '||X_ORG_TRX_NUMBER );
    END IF;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
                                      'GET_ORG_TRX_NUMBER(-)');
   END IF;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
			'Error Message : '||substrb(SQLERRM,1,120) );
		END IF;
END get_org_trx_number;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   GET_EXPORT_INFO                                                         |
 |   Type       : Private                                                    |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This plug-in is used to fetch the following values for ZXTWRZTR        |
 |          export certificate number                                        |
 |          export name                                                      |
 |          export method                                                    |
 |          export type                                                      |
 |          export date                                                      |
 |                                                                           |
 |    Called from ZX_JA_EXTRACT_PKG.POPULATE                                    |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN         :                                                            |
 |                 p_request_id IN NUMBER   Required                         |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     27-Oct-03  Asako Takahashi   created                                  |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/


PROCEDURE GET_EXPORT_INFO
(
P_TRX_ID IN NUMBER,
X_GDF_RA_CUST_TRX_ATT4   OUT NOCOPY   ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT4%TYPE,   -- export certificate number
X_GDF_RA_CUST_TRX_ATT5   OUT NOCOPY   ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT5%TYPE,   -- export name
X_GDF_RA_CUST_TRX_ATT6   OUT NOCOPY   ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT6%TYPE,   -- export method
X_GDF_RA_CUST_TRX_ATT7   OUT NOCOPY   ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT7%TYPE,   -- export type
X_GDF_RA_CUST_TRX_ATT8   OUT NOCOPY   ZX_REP_TRX_JX_EXT_T.GDF_RA_CUST_TRX_ATT8%TYPE   -- export date
)
IS

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
                                      'GET_EXPORT_INFO(+)');
   END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' P_TRX_ID : '||P_TRX_ID );
    END IF;

 IF P_TRX_ID is not null THEN

     SELECT
        rct.global_attribute4,
        rct.global_attribute5,
        rct.global_attribute6,
        rct.global_attribute7,
        rct.global_attribute8
    INTO
        X_GDF_RA_CUST_TRX_ATT4,
        X_GDF_RA_CUST_TRX_ATT5,
        X_GDF_RA_CUST_TRX_ATT6,
        X_GDF_RA_CUST_TRX_ATT7,
        X_GDF_RA_CUST_TRX_ATT8
    FROM
        ra_customer_trx_all rct
    WHERE
        rct.customer_trx_id = P_TRX_ID and
        rct.global_attribute_category = 'JA.TW.ARXTWMAI.RA_CUSTOMER_TRX';

    IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' X_GDF_RA_CUST_TRX_ATT4 : '||X_GDF_RA_CUST_TRX_ATT4 );
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' X_GDF_RA_CUST_TRX_ATT5 : '||X_GDF_RA_CUST_TRX_ATT5 );
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' X_GDF_RA_CUST_TRX_ATT6 : '||X_GDF_RA_CUST_TRX_ATT6 );
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' X_GDF_RA_CUST_TRX_ATT7 : '||X_GDF_RA_CUST_TRX_ATT7 );
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
	' X_GDF_RA_CUST_TRX_ATT8 : '||X_GDF_RA_CUST_TRX_ATT8 );

    END IF;

 END IF;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
                                      'GET_EXPORT_INFO(-)');
   END IF;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG',
			'Error Message : GET_EXPORT_INFO : '||substrb(SQLERRM,1,120) );
		END IF;


END get_export_info;


PROCEDURE bank_info
(
  P_TRL_GLOBAL_VARIABLES_REC     IN      ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
)
IS

l_detail_tax_line_id_tbl        ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;

CURSOR reg_bank_count_cur IS
SELECT reg.bank_id,
       reg.bank_branch_id,
       reg.account_id,
       reg.bank_account_num,
       a.bank_name ,
       a.bank_branch_name
 FROM zx_party_tax_profile ptp,
      xle_etb_profiles xlep,
      zx_registrations reg ,
      ce_bank_branches_v a
WHERE ptp.party_id         = xlep.party_id
  AND ptp.party_type_code  = 'LEGAL_ESTABLISHMENT'
  AND xlep.legal_entity_id = P_TRL_GLOBAL_VARIABLES_REC.legal_entity_id
  AND xlep.main_establishment_flag = 'Y'
  AND reg.bank_id = a.bank_party_id
  AND reg. bank_branch_id = a.branch_party_id
  AND reg.party_tax_profile_id = ptp.party_tax_profile_id;

   l_bank_id number;
   l_bank_branch_id number;
   l_account_id number;
   l_bank_account_num  VARCHAR2(30);
   l_bank_name ce_bank_branches_v.bank_name%type;
   l_branch_name ce_bank_branches_v.bank_branch_name%type;

  l_count number;
BEGIN

    OPEN reg_bank_count_cur;
    FETCH reg_bank_count_cur into l_bank_id,
                                  l_bank_branch_id,
                                  l_account_id,
                                  l_bank_account_num,
				  l_bank_name,
				  l_branch_name;
    CLOSE reg_bank_count_cur;

    SELECT dtl.detail_tax_line_id
    BULK COLLECT INTO l_detail_tax_line_id_tbl
                FROM zx_rep_trx_detail_t dtl
              WHERE dtl.request_id = P_TRL_GLOBAL_VARIABLES_REC.request_id;

  IF (l_bank_id is NOT NULL
   OR l_bank_branch_id IS NOT NULL
   OR l_account_id IS NOT NULL) THEN
    BEGIN
     FORALL i in 1 .. nvl(l_detail_tax_line_id_tbl.last, 0)

     INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                     detail_tax_line_id,
                                     attribute28,   --bank ID
                                     attribute29,   --Bracnh ID
                                     attribute30,   --Account ID
                                     created_by,
                                     creation_date,
                                     last_updated_by,
                                     last_update_date,
                                     last_update_login)
                                     VALUES ( zx_rep_trx_jx_ext_t_s.nextval,
                                              l_detail_tax_line_id_tbl(i),
                                                 l_bank_name,
                                                 l_branch_name,
                                                 l_bank_account_num,
                                                 fnd_global.user_id,
                                                 sysdate,
                                                 fnd_global.user_id,
                                                 sysdate,
                                                 fnd_global.login_id);
     END;

     ELSE

      BEGIN
        INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                     detail_tax_line_id,
                                     attribute28,
                                     attribute29,
                                     attribute30,
                                     created_by,
                                     creation_date,
                                     last_updated_by,
                                     last_update_date,
                                     last_update_login)
                                  SELECT zx_rep_trx_jx_ext_t_s.nextval,
                                                 dtl.detail_tax_line_id,
                                                 loc.global_attribute5,
                                                 loc.global_attribute6,
                                                 loc.global_attribute7,
                                                 fnd_global.user_id,
                                                 sysdate,
                                                 fnd_global.user_id,
                                                 sysdate,
                                                 fnd_global.login_id
                                            FROM hr_all_organization_units    ou,
                                                 hr_organization_information  oi,
                                                 hr_locations                 loc,
                                                 gl_sets_of_books             sob,
                                                 zx_rep_trx_detail_t dtl
                                           WHERE ou.organization_id = oi.organization_id
                                             AND ou.location_id = loc.location_id
                                             AND TO_NUMBER(oi.org_information1) = sob.set_of_books_id
                                             AND oi.org_information_context = 'Legal Entity Accounting'
                                             AND dtl.request_id = P_TRL_GLOBAL_VARIABLES_REC.request_id
                                             AND ou.organization_id = nvl(dtl.internal_organization_id,
                                                       P_TRL_GLOBAL_VARIABLES_REC.legal_entity_id);

      END;
   END IF;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
       NULL;

END bank_info;


END ZX_JA_EXTRACT_PKG;

/
