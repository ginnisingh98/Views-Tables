--------------------------------------------------------
--  DDL for Package Body ZX_TAXWARE_USER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TAXWARE_USER_PKG" AS
/* $Header: zxtxwuserpkgb.pls 120.34.12010000.10 2009/11/10 13:26:24 ssanka ship $ */

/* ======================================================================*
 | Global Data Types                                                     |
 * ======================================================================*/

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'ZX_TAXWARE_USER_PKG';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(30) := 'ZX.PLSQL.ZX_TAXWARE_USER_PKG.';

g_usenexpro	VARCHAR2(100);
g_taxselparam   NUMBER;
--g_taxtype	NUMBER;
g_serviceind	NUMBER;

   g_string                 VARCHAR2(80);
   l_view_name              VARCHAR2(200);
   i                        PLS_INTEGER;
   g_in_out_flag            VARCHAR2(1);     -- Bug 5506031
   g_ship_from_party_id      ZX_PARTY_TAX_PROFILE.PARTY_ID%TYPE;
   g_org_id                  RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE;
   g_sales_repid             RA_CUSTOMER_TRX_ALL.primary_salesrep_id%TYPE;

   TYPE party_id_tbl_type is table of NUMBER index by VARCHAR2(100);
   p_party_id_tbl  party_id_tbl_type;

   TYPE party_number_tbl_type is TABLE OF VARCHAR2(150) index by VARCHAR2(100);
   p_party_number_tbl    party_number_tbl_type;

   TYPE poa_add_code_tbl_type is TABLE OF VARCHAR2(150) index by VARCHAR2(100);
   poa_add_code_cache_tbl    poa_add_code_tbl_type;


    /***********Declaration of private procedures*************/
   PROCEDURE POPULATE_EXEMPTION_DETAILS
   (
	p_bill_to_site_use          IN ZX_LINES_DET_FACTORS.BILL_TO_CUST_ACCT_SITE_USE_ID%TYPE,
	p_bill_to_location_id       IN ZX_LINES_DET_FACTORS.BILL_TO_LOCATION_ID%TYPE,
	p_bill_to_party_tax_id      IN ZX_LINES_DET_FACTORS.BILL_TO_PARTY_TAX_PROF_ID%TYPE,
	p_bill_to_site_tax_prof     IN ZX_LINES_DET_FACTORS.TRADING_HQ_SITE_TAX_PROF_ID%TYPE,
	p_hq_site_tax_prof_id       IN ZX_LINES_DET_FACTORS.TRADING_HQ_SITE_TAX_PROF_ID%TYPE,
	p_hq_party_tax_prof_id_tab  IN ZX_LINES_DET_FACTORS.TRADING_HQ_PARTY_TAX_PROF_ID%TYPE,
	p_bill_third_pty_acct_id    IN ZX_LINES_DET_FACTORS.BILL_THIRD_PTY_ACCT_ID%TYPE,
	p_product_org_id            IN ZX_LINES_DET_FACTORS.PRODUCT_ORG_ID%TYPE,
	p_product_id                IN ZX_LINES_DET_FACTORS.product_id%TYPE,
	p_cert_num                  IN ZX_LINES_DET_FACTORS.exempt_certificate_number%TYPE,
	p_exmpt_rsn_code            IN ZX_LINES_DET_FACTORS.exempt_reason_code%TYPE,
	p_exemption_control_flag    IN ZX_LINES_DET_FACTORS.Exemption_Control_Flag%TYPE,
	p_tax_regime_code           IN ZX_TRX_PRE_PROC_OPTIONS_GT.Tax_Regime_Code%TYPE,
	p_position                  IN NUMBER,
	p_error_status              OUT NOCOPY VARCHAR2
   );

   PROCEDURE derive_view_name
   (
	p_application_id      IN ZX_LINES_DET_FACTORS.APPLICATION_ID%TYPE,
	p_event_class_code    IN ZX_LINES_DET_FACTORS.EVENT_CLASS_CODE%TYPE,
	p_api_name            IN VARCHAR2,
	p_adjusted_doc_trx_id IN ZX_LINES_DET_FACTORS.ADJUSTED_DOC_TRX_ID%TYPE,
	p_line_level_action   IN ZX_LINES_DET_FACTORS.LINE_LEVEL_ACTION%TYPE,
	x_view_name           OUT NOCOPY VARCHAR2
    );
   PROCEDURE Initialize_Nested_Tables ;
   PROCEDURE Initialize_Exemption_Tables;
/* Bug 4668932 */
   FUNCTION CHECK_GEOCODE(p_geocode IN VARCHAR2) RETURN BOOLEAN;
/* Bug 4668932 */

   PROCEDURE derive_trx_level_attr;
   PROCEDURE derive_product_code;
   PROCEDURE derive_audit_flag;
   PROCEDURE derive_ship_to_address_code;
   PROCEDURE derive_ship_from_address_code;
   PROCEDURE derive_poa_address_code;
   PROCEDURE derive_poo_address_code;
   PROCEDURE derive_customer_code;
   PROCEDURE derive_customer_name;
   PROCEDURE derive_division_code;
   PROCEDURE derive_transaction_date;
   PROCEDURE derive_company_code;
   PROCEDURE derive_vnd_ctrl_exmpt;
   PROCEDURE derive_use_nexpro;
   PROCEDURE derive_service_ind;
   PROCEDURE derive_tax_sel_param;
   PROCEDURE derive_calculation_flag;

 PROCEDURE ERROR_EXCEPTION_HANDLE(str  varchar2);

   /*PUBLIC PROCEDURE DEFINITIONS START HERE*/
   /*===========================================================================+
    | PROCEDURE
    |    Derive_Hdr_Ext_Attr
    | IN
    |
    | OUT NOCOPY
    |
    | DESCRIPTION
    |     This routine contains the necessary logic to populate header_level user extensible
    |     attributes into ZX_PRVDR_HDR_EXTNS_GT.
    |
    | SCOPE - PUBLIC
    |
    | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
    |
    | CALLED FROM
    |
    |
    | MODIFICATION HISTORY
    | 08/13/2004   Arnab Sengupta   Created.
    |
    +==========================================================================*/
   PROCEDURE Derive_Hdr_Ext_Attr( x_error_status OUT NOCOPY VARCHAR2
                                , x_messages_tbl OUT NOCOPY ZX_TAX_PARTNER_PKG.messages_tbl_type) IS

      l_header_ext_attr1    ZX_PRVDR_HDR_EXTNS_GT.HEADER_EXT_VARCHAR_ATTRIBUTE1%TYPE ;
      l_event_class_code    ZX_LINES_DET_FACTORS.Event_Class_Code%TYPE;
      l_application_id      ZX_LINES_DET_FACTORS.Application_Id%TYPE;
      l_entity_code         ZX_LINES_DET_FACTORS.Entity_Code%TYPE;
      l_trx_id              ZX_LINES_DET_FACTORS.Trx_Id%TYPE;
      l_tax_provider_id     ZX_TRX_PRE_PROC_OPTIONS_GT.Tax_Provider_Id%TYPE;
      l_tax_regime_code     ZX_TRX_PRE_PROC_OPTIONS_GT.Tax_Regime_Code%TYPE;
      l_api_name            CONSTANT VARCHAR2(30) := 'DERIVE_HDR_EXT_ATTR';
      l_exists_in_hdrs_gt   NUMBER;


   BEGIN

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    /*Set the return status to Success */
    x_error_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
      SELECT
		 ZX_DET_FACT.EVENT_CLASS_CODE	      ,
		 ZX_DET_FACT.APPLICATION_ID           ,
		 ZX_DET_FACT.ENTITY_CODE              ,
		 ZX_DET_FACT.TRX_ID                   ,
		 ZX_PRE_REC_OPT.TAX_PROVIDER_ID       ,
		 ZX_PRE_REC_OPT.TAX_REGIME_CODE       ,
		 ZX_DET_FACT.TRX_DATE                 ,
		 ZX_DET_FACT.RECEIVABLES_TRX_TYPE_ID
	 INTO
		   l_event_class_code,
		   l_application_id,
		   l_entity_code,
		   l_trx_id,
		   l_tax_provider_id,
		   l_tax_regime_code,
		   g_trx_date,
		   g_trx_type_id
	 FROM
		 ZX_LINES_DET_FACTORS     ZX_DET_FACT  ,
		 ZX_USER_PROC_INPUT_V     ZX_PRE_REC_OPT
	 WHERE
		 ZX_DET_FACT.INTERNAL_ORGANIZATION_ID = ZX_PRE_REC_OPT.INTERNAL_ORGANIZATION_ID
	 AND     ZX_DET_FACT.APPLICATION_ID           = ZX_PRE_REC_OPT.APPLICATION_ID
	 AND     ZX_DET_FACT.EVENT_CLASS_CODE         = ZX_PRE_REC_OPT.EVENT_CLASS_CODE
	 AND     ZX_DET_FACT.ENTITY_CODE              = ZX_PRE_REC_OPT.ENTITY_CODE
	 AND     ZX_DET_FACT.TRX_ID                   = ZX_PRE_REC_OPT.TRX_ID
         AND     ROWNUM				      = 1;
    EXCEPTION WHEN OTHERS THEN
         IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
	 x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 g_string :='No Header information present';
	 error_exception_handle(g_string);
	 x_messages_tbl:=g_messages_tbl;
	 return;
    END;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' Event Class code = ' || l_event_class_code);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' Application Id = ' || to_char(l_application_id));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' Entity code = ' || l_entity_code);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' l_trx_id = ' || to_char(l_trx_id));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' l_tax_provider_id = ' || to_char(l_tax_provider_id));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' Tax Regime code = ' || l_tax_regime_code);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' g_trx_date = ' || to_char(g_trx_date));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' g_trx_type_id = ' || to_char(g_trx_type_id));
    END IF;

    l_exists_in_hdrs_gt := 0;
    BEGIN
       SELECT 1
         INTO l_exists_in_hdrs_gt
         FROM ZX_PRVDR_HDR_EXTNS_GT
        WHERE event_class_code = l_event_class_code
          AND application_id = l_application_id
          AND entity_code = l_entity_code
          AND trx_id = l_trx_id
          AND provider_id = l_tax_provider_id
          AND tax_regime_code = l_tax_regime_code
          AND rownum = 1;
    EXCEPTION WHEN OTHERS THEN
       l_exists_in_hdrs_gt := 0;
    END;

    IF l_exists_in_hdrs_gt = 0 THEN
    BEGIN
            INSERT INTO
                ZX_PRVDR_HDR_EXTNS_GT
                (
                EVENT_CLASS_CODE,
                APPLICATION_ID,
                ENTITY_CODE,
                TRX_ID     ,
                PROVIDER_ID ,
                TAX_REGIME_CODE,
                HEADER_EXT_VARCHAR_ATTRIBUTE1,
                CREATION_DATE ,
                CREATED_BY    ,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY  ,
                LAST_UPDATE_LOGIN
                )

            VALUES(
                 l_Event_Class_Code,
                 l_Application_Id,
                 l_Entity_Code,
                 l_Trx_Id,
                 l_Tax_Provider_Id ,
                 l_Tax_Regime_Code,
                 l_header_ext_attr1,
                 SYSDATE,
                 fnd_global.user_id      ,
                 SYSDATE                 ,
                 fnd_global.user_id      ,
                 fnd_global.conc_login_id);
         EXCEPTION
             WHEN OTHERS THEN
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                END IF;
		x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
		g_string :='Not able to insert in to ZX_PRVDR_HDR_EXTNS_GT table ';
		x_messages_tbl:=g_messages_tbl;
		error_exception_handle(g_string);
		return;
         END;
    END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 ' RETURN_STATUS = ' || x_error_status);
   END IF;
  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME ||':'||l_api_name||'()-');
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
          IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||':'||l_api_name,SQLERRM);
           END IF;
	 x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 g_string :='Failed in DERIVE_HDR_EXT_ATTR procedure';
	 error_exception_handle(g_string);
	 x_messages_tbl:=g_messages_tbl;
	 return;

   END Derive_Hdr_Ext_Attr;



   /*===========================================================================+
    | PROCEDURE
    |    Derive_Line_Ext_Attr
    | IN
    |
    | OUT NOCOPY
    |
    | DESCRIPTION
    |     This routine contains the necessary logic to populate header_level user extensible
    |     attributes into ZX_PRVDR_LINE_EXTNS_GT.
    |
    | SCOPE - PUBLIC
    |
    | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED/PRIVATE PROCEDURES ACCESSED
    | POPULATE_EXEMPTION_DETAILS --Private Procedure
    | DERIVE_VIEW_NAME           --Private Procedure
    |
    | CALLED FROM
    |
    |
    | MODIFICATION HISTORY
    | 08/13/2004   Arnab Sengupta   Created.
    |
    +==========================================================================*/

   PROCEDURE Derive_Line_Ext_Attr( x_error_status OUT NOCOPY VARCHAR2
                                 , x_messages_tbl OUT NOCOPY ZX_TAX_PARTNER_PKG.messages_tbl_type) IS


   --This is the main driver cursor for fetching all records from the ZX_LINES_DET_FACTORS
   --to populate into the ZX_PRVDR_LINE_EXTNS_GT table


CURSOR PROC_LINE_CSR IS
SELECT
	ZX_LINE_DET_FACT.INTERNAL_ORGANIZATION_ID	,
	ZX_LINE_DET_FACT.APPLICATION_ID			,
	ZX_LINE_DET_FACT.ENTITY_CODE			,
	ZX_LINE_DET_FACT.EVENT_CLASS_CODE		,
	ZX_LINE_DET_FACT.TRX_ID				,
	ZUPI.TAX_PROVIDER_ID			        ,
	ZUPI.TAX_REGIME_CODE		        	,
	ZX_LINE_DET_FACT.TRX_LEVEL_TYPE			,
	ZX_LINE_DET_FACT.TRX_LINE_ID			,
	ZX_LINE_DET_FACT.PRODUCT_ID			,
	ZX_LINE_DET_FACT.PRODUCT_ORG_ID			,
	ZX_LINE_DET_FACT.SHIP_To_PARTY_TAX_PROF_ID	,
	ZX_LINE_DET_FACT.SHIP_FROM_PARTY_TAX_PROF_ID	,
	ZX_LINE_DET_FACT.EXEMPT_CERTIFICATE_NUMBER	,
	ZX_LINE_DET_FACT.EXEMPT_REASON			,
	ZX_LINE_DET_FACT.EXEMPTION_CONTROL_FLAG		,
	ZX_LINE_DET_FACT.SHIP_TO_SITE_TAX_PROF_ID	,
	ZX_LINE_DET_FACT.SHIP_TO_LOCATION_ID		,
	ZX_LINE_DET_FACT.SHIP_TO_CUST_ACCT_SITE_USE_ID	,
	ZX_LINE_DET_FACT.BILL_TO_CUST_ACCT_SITE_USE_ID	,
	ZX_LINE_DET_FACT.BILL_TO_SITE_TAX_PROF_ID	,
	ZX_LINE_DET_FACT.BILL_TO_PARTY_TAX_PROF_ID	,
	ZX_LINE_DET_FACT.BILL_TO_LOCATION_ID		,
	ZX_LINE_DET_FACT.TRADING_HQ_SITE_TAX_PROF_ID	,
	ZX_LINE_DET_FACT.TRADING_HQ_PARTY_TAX_PROF_ID	,
	ZX_LINE_DET_FACT.BILL_THIRD_PTY_ACCT_ID		,
	ZX_LINE_DET_FACT.LINE_LEVEL_ACTION		,
	ZX_LINE_DET_FACT.ADJUSTED_DOC_TRX_ID		,
	ZX_LINE_DET_FACT.LINE_AMT			,
	ZX_LINE_DET_FACT.ADJUSTED_DOC_APPLICATION_ID	,
	ZX_LINE_DET_FACT.ADJUSTED_DOC_ENTITY_CODE	,
	ZX_LINE_DET_FACT.ADJUSTED_DOC_EVENT_CLASS_CODE	,
	ZX_LINE_DET_FACT.ADJUSTED_DOC_LINE_ID		,
	ZX_LINE_DET_FACT.RECEIVABLES_TRX_TYPE_ID	,
        ZX_LINE_DET_FACT.ADJUSTED_DOC_TRX_LEVEL_TYPE	,
	ZX_LINE_DET_FACT.SHIP_THIRD_PTY_ACCT_SITE_ID	,
	ZX_LINE_DET_FACT.BILL_THIRD_PTY_ACCT_SITE_ID
FROM
        ZX_LINES_DET_FACTORS         ZX_LINE_DET_FACT    ,
	ZX_USER_PROC_INPUT_V         ZUPI    ,
	ZX_TRX_PRE_PROC_OPTIONS_GT   ZTPPO
WHERE
		ZX_LINE_DET_FACT.INTERNAL_ORGANIZATION_ID  = ZUPI.INTERNAL_ORGANIZATION_ID
	AND     ZX_LINE_DET_FACT.APPLICATION_ID            = ZUPI.APPLICATION_ID
	AND     ZX_LINE_DET_FACT.EVENT_CLASS_CODE          = ZUPI.EVENT_CLASS_CODE
	AND     ZX_LINE_DET_FACT.ENTITY_CODE               = ZUPI.ENTITY_CODE
	AND     ZX_LINE_DET_FACT.TRX_ID                    = ZUPI.TRX_ID
        AND     ZX_LINE_DET_FACT.INTERNAL_ORGANIZATION_ID  = ZTPPO.INTERNAL_ORGANIZATION_ID
	AND     ZX_LINE_DET_FACT.APPLICATION_ID            = ZTPPO.APPLICATION_ID
	AND     ZX_LINE_DET_FACT.EVENT_CLASS_CODE          = ZTPPO.EVENT_CLASS_CODE
	AND     ZX_LINE_DET_FACT.ENTITY_CODE               = ZTPPO.ENTITY_CODE
	AND     ZX_LINE_DET_FACT.TRX_ID                    = ZTPPO.TRX_ID
        AND     ((ZX_LINE_DET_FACT.EVENT_ID                = ZTPPO.EVENT_ID)
                OR (ZX_LINE_DET_FACT.LINE_LEVEL_ACTION = 'DELETE'));


   --This is the cursor for fetching all records from the ZX_USR_PROC_NEG_LINE_V.
   --The specific purpose of this view is to retain old data from zx_lines_det_factors
   --to populate into the ZX_PRVDR_LINE_EXTNS_GT table

      CURSOR PROC_NEG_LINE_CSR IS
	    SELECT
	       Internal_Organization_Id ,
	       Application_Id,
	       Entity_Code,
	       Event_Class_Code,
	       Trx_Id,
	       Tax_Provider_Id,
	       Tax_Regime_Code,
	       Trx_Line_Type,
	       Trx_Line_Id,
	       Product_Id,
	       Product_Org_Id,
	       Ship_To_Party_Tax_Profile_Id,
	       Ship_From_Party_Tax_Profile_Id,
	       Exempt_Certificate_Number,
	       Exempt_Reason_Code,
	       Exemption_Control_Flag,
	       Ship_To_Site_Tax_Prof_Id,
	       Ship_To_Location_Id,
       	       Ship_To_Cust_Acct_Site_Use_Id,
	       Bill_To_Cust_Acct_Site_Use_Id,
	       Bill_To_Site_Tax_Prof_Id,
	       Bill_To_Party_Tax_Prof_Id,
	       Bill_To_Location_Id,
	       Trading_Hq_Site_Tax_Prof_Id,
	       Trading_Hq_Party_Tax_Prof_Id,
	       Bill_Third_Pty_Acct_Id,
	       Line_Level_Action,
	       Adjusted_Doc_Trx_Id,
	       Line_Amt,
	       adjusted_doc_application_id,
	       adjusted_doc_entity_code,
	       adjusted_doc_event_class_code,
	       adjusted_doc_trx_line_id,
	       Receivables_Trx_Type_Id,
	       Adjusted_Doc_Trx_Level_Type,
	       Ship_Third_Pty_Acct_Site_Id,
	       Bill_Third_Pty_Acct_Site_Id
	    FROM
	       ZX_USR_PROC_NEG_LINE_V zxproc
	     WHERE
	       zxproc.trx_line_id = g_trx_line_id;




         --Other local variable declarations

         x_exemption_record        ZX_TCM_GET_EXEMPT_PKG.exemption_rec_type;
         x_ret_status              VARCHAR2(30);
         l_errors                  PLS_INTEGER;
         l_product_id              ZX_LINES_DET_FACTORS.product_id%TYPE;
	 l_memo_line_id            NUMBER;
	 l_is_view_name_derived    VARCHAR2(1);
 --l_view_name               VARCHAR2(200); --Commented for the bug#6723111
	 l_srv_name                VARCHAR2(100);
	 l_is_sales_repid_derived  VARCHAR2(1);
	 l_ship_from_party_id      ZX_PARTY_TAX_PROFILE.PARTY_ID%TYPE;
	 --i                         PLS_INTEGER;
         j                         PLS_INTEGER;

         l_master_org_id           oe_system_parameters_all.master_organization_id%type;
/* Bug 4668932 */
         l_tax_jurisdiction_rec    ZX_TCM_GEO_JUR_PKG.tax_jurisdiction_rec_type;
         l_jurisdictions_found     VARCHAR2(1);
         l_ship_to_geocode         VARCHAR2(30);
	 row_count number;
/* Bug 4668932 */

	l_api_name            CONSTANT VARCHAR2(30) := 'DERIVE_LINE_EXT_ATTR';
   BEGIN
	IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
        END IF;

       /*Set the return status to Success */
       x_error_status := FND_API.G_RET_STS_SUCCESS;

       --Initialiaze all the nested tables
       Initialize_Nested_Tables;


        --Open the cursor and fetch all records into the nested tables
        --Doing a bulk fetch here

       l_is_view_name_derived   := 'N'; --Initializing the flag
       l_is_sales_repid_derived := 'N'; --Initializing the flag
       l_srv_name             := ZX_API_PUB.G_PUB_SRVC;

       IF g_line_negation
       THEN
       OPEN PROC_NEG_LINE_CSR;

	 FETCH PROC_NEG_LINE_CSR
            BULK COLLECT INTO
               internal_org_id_tab,
               application_id_tab,
               entity_code_tab,
               event_class_code_tab,
               trx_id_tab,
               tax_provider_id_tab,
               tax_regime_code_tab,
               trx_line_type_tab,
               trx_line_id_tab,
               product_id_tab,
               Product_Org_Id_tab,
               ship_to_tx_id_tab,
               ship_from_tx_id_tab,
               cert_num_tab,
               exmpt_rsn_code_tab,
               exemption_control_flag_tab,
               ship_to_site_tax_prof_tab,
               ship_to_loc_id_tab ,
               ship_to_site_use_tab,
               bill_to_site_use_tab,
               bill_to_site_tax_prof_tab,
               bill_to_party_tax_id_tab,
               bill_to_location_id_tab,
               trad_hq_site_tax_prof_id_tab,
               trad_hq_party_tax_prof_id_tab,
	       bill_third_pty_acct_id_tab,
               line_level_action_tab,
	       adjusted_doc_trx_id_tab,
	       line_amount_tab,
	       adj_doc_appl_id_tab,
	       adj_doc_entity_code_tab,
               adj_evnt_cls_code_tab,
               adj_doc_line_id_tab,
	       trx_type_id_tab,
	       adj_doc_trx_level_type_tab,
	       ship_third_pty_site_tab,
	       bill_third_pty_site_tab;

           CLOSE PROC_NEG_LINE_CSR;



       ELSE
         OPEN PROC_LINE_CSR;

          FETCH PROC_LINE_CSR
             BULK COLLECT INTO
               internal_org_id_tab,
               application_id_tab,
               entity_code_tab,
               event_class_code_tab,
               trx_id_tab,
               tax_provider_id_tab,
               tax_regime_code_tab,
               trx_line_type_tab,
               trx_line_id_tab,
               product_id_tab,
               Product_Org_Id_tab,
               ship_to_tx_id_tab,
               ship_from_tx_id_tab,
               cert_num_tab,
               exmpt_rsn_code_tab,
               exemption_control_flag_tab,
               ship_to_site_tax_prof_tab,
               ship_to_loc_id_tab ,
               ship_to_site_use_tab,
               bill_to_site_use_tab,
               bill_to_site_tax_prof_tab,
               bill_to_party_tax_id_tab,
               bill_to_location_id_tab,
               trad_hq_site_tax_prof_id_tab,
               trad_hq_party_tax_prof_id_tab,
	       bill_third_pty_acct_id_tab,
               line_level_action_tab,
	       adjusted_doc_trx_id_tab,
	       line_amount_tab,
	       adj_doc_appl_id_tab,
	       adj_doc_entity_code_tab,
               adj_evnt_cls_code_tab,
               adj_doc_line_id_tab,
	       trx_type_id_tab,
	       adj_doc_trx_level_type_tab,
	       ship_third_pty_site_tab,
	       bill_third_pty_site_tab;

	       row_count:=PROC_LINE_CSR%rowcount;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         ' row_count := '||row_count);
      END IF;

        CLOSE PROC_LINE_CSR;



	   END IF;

	   Initialize_Exemption_Tables;


         /*This call is exclusively used to determine the exemption_id for the given
         set of values fetched via the cursor.The exemption_id is collected into
         a variable x_exemption_record from which the exemption_id is obtained*/

        FOR line_cntr in 1..nvl(internal_org_id_tab.last,0)  --Loop 1
        LOOP

           i := line_cntr;

	   BEGIN
	      IF ship_from_tx_id_tab(i) IS NOT NULL
	      THEN
		   SELECT party_id INTO l_ship_from_party_id
		   FROM   ZX_PARTY_TAX_PROFILE
		   WHERE  party_tax_profile_id = ship_from_tx_id_tab(i);
	       END IF;

	   EXCEPTION WHEN NO_DATA_FOUND
	     THEN
	           l_ship_from_party_id := NULL;
	   END;

	    IF event_class_code_tab(i)  <> 'INVOICE_ADJUSTMENT' AND  line_amount_tab(i)  <> 0
	    THEN

	   /* Bug Number: 6328797 - According to 11i , The exemptions should work at
	        -> Ship_To For Customer Site level.
		-> Bill_to For Customer Level
	      So we need to pass ship_to_loc_id_tab for finding the exemptions.
	      But previously we were passing bill_to_location_id_tab to find the exemptions.
	      So, chaged passing variable to ship_to_loc_id_tab.

	      But to avoid the structure changes, we are not changing the Naming Convention.
	      If we change the Structure Chages we need to do in lot of packages.
	      So we are keeping the name as bill_to only but changing the passing value.
	   */

		   POPULATE_EXEMPTION_DETAILS
		    (
		       p_bill_to_site_use         => NVL(ship_to_site_use_tab(i),bill_to_site_use_tab(i)),
		       p_bill_to_location_id      => NVL(ship_to_loc_id_tab(i),bill_to_location_id_tab(i)),
		       p_bill_to_party_tax_id     => bill_to_party_tax_id_tab(i),
		       p_bill_to_site_tax_prof    => NVL(ship_to_site_tax_prof_tab(i),bill_to_site_tax_prof_tab(i)),
		       p_hq_site_tax_prof_id      => trad_hq_site_tax_prof_id_tab(i),
		       p_hq_party_tax_prof_id_tab => trad_hq_party_tax_prof_id_tab(i),
		       p_bill_third_pty_acct_id   => bill_third_pty_acct_id_tab(i),
		       p_product_org_id           => product_org_id_tab(i),
		       p_product_id               => product_id_tab(i),
		       p_cert_num                 => cert_num_tab(i),
		       p_exmpt_rsn_code           => exmpt_rsn_code_tab(i),
		       p_exemption_control_flag   => exemption_control_flag_tab(i),
		       p_tax_regime_code          => tax_regime_code_tab(i),
		       p_position                 => i,
		       p_error_status		  => x_ret_status
		    ) ;
		    NULL;
	      END IF;

	 IF x_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF (g_level_exception >= g_current_runtime_level ) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
	   x_error_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   g_string :='Failed with error in procedure POPULATE_EXEMPTION_DETAILS';
	   error_exception_handle(g_string);
	   x_messages_tbl:=g_messages_tbl;
	   return;
         END IF;

	  /*The next portion of the code deals with the view name derivation based on
           application_id , event_class_code and api name .This procedure returns
	   the view name as an out parameter which is used successively .This needs
	   to be called just once as view name is a document level property association.*/


	 /**NOTE**  The usage of the flag l_is_view_derived is purely to execute the derive_view_name
	            procedure just once as view name is a Document level attribute and hence need not
		    be derived for every line */

	    IF l_is_view_name_derived = 'N' THEN   --Initially the flag is set to 'N'
		 DERIVE_VIEW_NAME
			(p_application_id      => application_id_tab(i),
			 p_event_class_code    => event_class_code_tab(i),
			 p_api_name            => l_srv_name,
			 p_adjusted_doc_trx_id => adjusted_doc_trx_id_tab(i),
			 p_line_level_action   => line_level_action_tab(i),
			 x_view_name           => l_view_name);
		l_is_view_name_derived := 'Y';    --Once first execution is complete set flag to 'Y' to
						  --prevent re-execution of DERIVE_VIEW_NAME for successive lines
		derive_trx_level_attr;
	     END IF;


         /*This portion of the code is used to collect the values from the user extensible
         procedures into nested tables based on the inputs we have collected into nested
         tables so far (such as transaction ids, product ids,org ids etc) .This step
         is necessary as we want to bulk insert all values into ZX_PRVDR_LINE_EXTNS_GT
         through nested tables only.Doing this in a separate loop only for clarity*/

	   derive_product_code;
           derive_audit_flag;
           derive_ship_to_address_code;
           derive_ship_from_address_code;
           derive_poa_address_code;
	   derive_poo_address_code;
           derive_customer_code;
           derive_customer_name;
           derive_division_code;
           derive_transaction_date;
           derive_company_code;
	   derive_vnd_ctrl_exmpt;
	   derive_use_nexpro;
	   derive_service_ind;
	   derive_tax_sel_param;
	   derive_calculation_flag;

       END LOOP;

        /*This portion of the code performs a bulk insert into the ZX_PRVDR_LINE_EXTNS_GT
          through all the pl/sql tables populated above*/
       IF g_line_negation THEN
          null;
       ELSE
             BEGIN
             FORALL j in 1..NVL(trx_id_tab.last,0)
               INSERT  INTO
               ZX_PRVDR_LINE_EXTNS_GT
                (
                     EVENT_CLASS_CODE,
                     APPLICATION_ID  ,
                     ENTITY_CODE     ,
                     TRX_ID          ,
                     TRX_LINE_ID     ,
		     TRX_LEVEL_TYPE  ,
                     PROVIDER_ID     ,
                     TAX_REGIME_CODE ,
                  -- LINE_EXT_VARCHAR_ATTRIBUTE1,
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
                     LINE_EXT_VARCHAR_ATTRIBUTE16,
                     LINE_EXT_VARCHAR_ATTRIBUTE17,
                     LINE_EXT_VARCHAR_ATTRIBUTE18,
                     LINE_EXT_VARCHAR_ATTRIBUTE19,
                     LINE_EXT_VARCHAR_ATTRIBUTE20,
                     LINE_EXT_VARCHAR_ATTRIBUTE21,
                     LINE_EXT_VARCHAR_ATTRIBUTE22,
                     LINE_EXT_VARCHAR_ATTRIBUTE23,
                     LINE_EXT_VARCHAR_ATTRIBUTE24,
                     LINE_EXT_NUMBER_ATTRIBUTE1,
                     LINE_EXT_NUMBER_ATTRIBUTE2,
                     LINE_EXT_NUMBER_ATTRIBUTE3,
                     LINE_EXT_NUMBER_ATTRIBUTE4,
                     LINE_EXT_NUMBER_ATTRIBUTE5,
                     LINE_EXT_NUMBER_ATTRIBUTE6,
                     LINE_EXT_DATE_ATTRIBUTE1,
		     CREATION_DATE,
		     CREATED_BY,
		     LAST_UPDATE_DATE,
		     LAST_UPDATED_BY
                )
            values
            (
                     event_class_code_tab(j),        --EVENT_CLASS_CODE
                     application_id_tab(j),          --APPLICATION_ID
                     entity_code_tab(j),             --ENTITY_CODE
                     trx_id_tab(j),                  --TRX_ID
                     trx_line_id_tab(j),             --TRX_LINE_ID
		     trx_line_type_tab(j),           --TRX_LEVEL_TYPE
                     tax_provider_id_tab(j),         --PROVIDER_ID
                     tax_regime_code_tab(j),         --TAX_REGIME_CODE
                   --arp_tax_type_tab(j),            --LINE_EXT_VARCHAR_ATTRIBUTE1
                     arp_product_code_tab(j),	     --LINE_EXT_VARCHAR_ATTRIBUTE2
		     use_step_tab(j),		     --LINE_EXT_VARCHAR_ATTRIBUTE3
                     arp_state_exempt_reason_tab(j), --LINE_EXT_VARCHAR_ATTRIBUTE4
                     arp_county_exempt_reason_tab(j),--LINE_EXT_VARCHAR_ATTRIBUTE5
                     arp_city_exempt_reason_tab(j),  --LINE_EXT_VARCHAR_ATTRIBUTE6
		     step_proc_flag_tab(j),	     --LINE_EXT_VARCHAR_ATTRIBUTE7
                     arp_audit_flag_tab(j),	     --LINE_EXT_VARCHAR_ATTRIBUTE8
                     arp_ship_to_add_tab(j),         --LINE_EXT_VARCHAR_ATTRIBUTE9
                     arp_ship_from_add_tab(j),       --LINE_EXT_VARCHAR_ATTRIBUTE10
                     arp_poa_add_code_tab(j),        --LINE_EXT_VARCHAR_ATTRIBUTE11
                     arp_customer_code_tab(j),	     --LINE_EXT_VARCHAR_ATTRIBUTE12
                     arp_customer_name_tab(j),       --LINE_EXT_VARCHAR_ATTRIBUTE13
                     arp_company_code_tab(j),        --LINE_EXT_VARCHAR_ATTRIBUTE14
                     arp_division_code_tab(j),       --LINE_EXT_VARCHAR_ATTRIBUTE15
		     arp_vnd_ctrl_exmpt_tab(j),      --LINE_EXT_VARCHAR_ATTRIBUTE16
		     arp_use_nexpro_tab(j),          --LINE_EXT_VARCHAR_ATTRIBUTE17
  		     arp_service_ind_tab(j),         --LINE_EXT_VARCHAR_ATTRIBUTE18
		     crit_flag_tab(j),               --LINE_EXT_VARCHAR_ATTRIBUTE19
                     arp_poo_add_code_tab(j),        --LINE_EXT_VARCHAR_ATTRIBUTE20
		     calculation_flag_tab(j),        --LINE_EXT_VARCHAR_ATTRIBUTE21
		     state_cert_no_tab(j),           --LINE_EXT_VARCHAR_ATTRIBUTE22
		     county_cert_no_tab(j),          --LINE_EXT_VARCHAR_ATTRIBUTE23
		     city_cert_no_tab(j),            --LINE_EXT_VARCHAR_ATTRIBUTE24
		     arp_state_exempt_percent_tab(j),--LINE_EXT_NUMBER_ATTRIBUTE1
                     arp_county_exempt_pct_tab(j),   --LINE_EXT_NUMBER_ATTRIBUTE2
                     arp_city_exempt_pct_tab(j)  ,   --LINE_EXT_NUMBER_ATTRIBUTE3
		     sec_county_exempt_pct_tab(j),   --LINE_EXT_NUMBER_ATTRIBUTE4
		     sec_city_exempt_pct_tab(j),     --LINE_EXT_NUMBER_ATTRIBUTE5
		     arp_tax_sel_param_tab(j),       --LINE_EXT_NUMBER_ATTRIBUTE6
                     arp_transaction_date_tab(j),    --LINE_EXT_DATE_ATTRIBUTE1
		     SYSDATE,
		     FND_GLOBAL.USER_ID,
		     SYSDATE,
		     FND_GLOBAL.USER_ID
             );

         EXCEPTION
              WHEN OTHERS THEN
                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                 END IF;
		x_error_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		g_string :='Not able to insert in to ZX_PRVDR_LINE_EXTNS_GT ';
		error_exception_handle(g_string);
		x_messages_tbl:=g_messages_tbl;
		return;
         END;

       END IF;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                       ' RETURN_STATUS = ' || x_error_status);
         END IF;

       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME ||l_api_name||'()-');
       END IF;

    END Derive_Line_Ext_Attr;


   /*===========================================================================+
    | PROCEDURE
    |    Derive_View_Name
    | IN
    |
    | OUT NOCOPY
    |
    | DESCRIPTION
    |           This procedureis used to derive the view name for a given combination
    |           of application_id,event_class_code,api name , adjusted doc trx id
    |           and line level action.
    |
    |
    | SCOPE - PRIVATE
    |
    | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
    |
    | CALLED FROM
    |
    |
    | MODIFICATION HISTORY
    | 08/13/2004   Arnab Sengupta   Created.
    |
    +==========================================================================*/
PROCEDURE DERIVE_VIEW_NAME(
 p_application_id      IN ZX_LINES_DET_FACTORS.APPLICATION_ID%TYPE,
 p_event_class_code    IN ZX_LINES_DET_FACTORS.EVENT_CLASS_CODE%TYPE,
 p_api_name            IN VARCHAR2,
 p_adjusted_doc_trx_id IN ZX_LINES_DET_FACTORS.ADJUSTED_DOC_TRX_ID%TYPE,
 p_line_level_action   IN ZX_LINES_DET_FACTORS.LINE_LEVEL_ACTION%TYPE,
 x_view_name           OUT NOCOPY VARCHAR2
)
IS
l_api_name            CONSTANT VARCHAR2(30) := 'DERIVE_VIEW_NAME';
BEGIN
       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
       END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' p_api_name = ' || p_api_name);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' p_line_level_action = ' || p_line_level_action);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' p_adjusted_doc_trx_id = ' || p_adjusted_doc_trx_id);
   END IF;

   /*The next portion of the code deals with the view name derivation based on
	   application_id , event_class_code and api name and adjusted doc trx id*/

    IF p_application_id = 222 THEN     -- Receivables
	 IF p_api_name = 'IMPORT_DOCUMENT_WITH_TAX' THEN  -- Auto invoice
	    IF p_event_class_code in ('INVOICE','DEBIT_MEMO') THEN
		    x_view_name := 'TAX_LINES_INVOICE_IMPORT_V_A INVOICE';

 	    ELSIF p_event_class_code in ('CREDIT_MEMO') THEN
		 IF p_adjusted_doc_trx_id IS NOT NULL THEN    -- Applied Credit Memo
		    x_view_name := 'TAX_LINES_RMA_IMPORT_V_A CREDITMEMO';

		 ELSE    -- On Account Credit Memo
		    x_view_name := 'TAX_LINES_INVOICE_IMPORT_V_A INVOICE';
		 END IF;
	    END IF;

         ELSIF p_api_name = 'CALCULATE_TAX' THEN  -- Manual invoice
            IF p_event_class_code in ('INVOICE') THEN
 		        IF p_line_level_action = 'COPY_AND_CREATE' THEN   -- Recurring Invoice
				x_view_name := 'TAX_LINES_RECURR_INVOICE_V_A';
			ELSE
			        x_view_name := 'TAX_LINES_CREATE_V_A INVOICE';
		        END IF;

            ELSIF p_event_class_code in ('DEBIT_MEMO') THEN
	      x_view_name := 'TAX_LINES_CREATE_V_A INVOICE';

            ELSIF p_event_class_code in ('CREDIT_MEMO') THEN

		     IF p_adjusted_doc_trx_id IS NOT NULL THEN   -- Applied Credit Memo
			  x_view_name := 'TAX_LINES_CM_V_A CREDITMEMO';
		     ELSE                                        -- On Account CM
			  x_view_name := 'TAX_LINES_CREATE_V_A INVOICE';
		     END IF;
	    ELSIF p_event_class_code in ('INVOICE_ADJUSTMENT') THEN
		          x_view_name := 'TAX_ADJUSTMENTS_V_A';
	    END IF;

	 ELSIF p_api_name = 'UPDATE_DET_FACTORS_HDR' THEN  -- Line negation
            IF p_event_class_code in ('INVOICE','DEBIT_MEMO') THEN
                   x_view_name := 'TAX_LINES_CREATE_V_A INVOICE';
            ELSIF p_event_class_code in ('CREDIT_MEMO') THEN
		IF p_adjusted_doc_trx_id IS NOT NULL THEN   -- Applied Credit Memo
                   x_view_name := 'TAX_LINES_CM_V_A CREDITMEMO';
                ELSE                                        -- On Account CM
		   x_view_name := 'TAX_LINES_CREATE_V_A INVOICE';
                END IF;
            END IF;
         END IF;

    ELSIF p_application_id in (660, 300) THEN
		   x_view_name := 'OE_TAX_LINES_SUMMARY_V_A';
    ELSE
		  x_view_name := 'ASO_TAX_LINES_SUMMARY_V_A'; ---Default View Name Assignment
    END IF;

IF ( g_level_statement >= g_current_runtime_level) THEN
               FND_LOG.STRING(g_level_statement,'ZX_TAXWARE_USER_PKG.DERIVE_VIEW_NAME',
               'x_view_name == '||x_view_name);
End if;


    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
       END IF;


END DERIVE_VIEW_NAME;


   /*===========================================================================+
    | PROCEDURE
    |    POPULATE_EXEMPTION_DETAILS
    | IN
    |
    | OUT NOCOPY
    |
    | DESCRIPTION
    |         This procedure is used to return a record containing the exemption_id
    |         which needs to be used to fetch the other related exemption related attributes.
    |
    |
    | SCOPE - PRIVATE
    |
    | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
    |
    | CALLED FROM
    |
    |
    | MODIFICATION HISTORY
    | 08/13/2004   Arnab Sengupta   Created.
    |
    +==========================================================================*/

   PROCEDURE POPULATE_EXEMPTION_DETAILS
   (
      p_bill_to_site_use          IN ZX_LINES_DET_FACTORS.BILL_TO_CUST_ACCT_SITE_USE_ID%TYPE,
      p_bill_to_location_id       IN ZX_LINES_DET_FACTORS.BILL_TO_LOCATION_ID%TYPE,
      p_bill_to_party_tax_id      IN ZX_LINES_DET_FACTORS.BILL_TO_PARTY_TAX_PROF_ID%TYPE,
      p_bill_to_site_tax_prof     IN ZX_LINES_DET_FACTORS.TRADING_HQ_SITE_TAX_PROF_ID%TYPE,
      p_hq_site_tax_prof_id       IN ZX_LINES_DET_FACTORS.TRADING_HQ_SITE_TAX_PROF_ID%TYPE,
      p_hq_party_tax_prof_id_tab  IN ZX_LINES_DET_FACTORS.TRADING_HQ_PARTY_TAX_PROF_ID%TYPE,
      p_bill_third_pty_acct_id    IN ZX_LINES_DET_FACTORS.BILL_THIRD_PTY_ACCT_ID%TYPE,
      p_product_org_id            IN ZX_LINES_DET_FACTORS.PRODUCT_ORG_ID%TYPE,
      p_product_id                IN ZX_LINES_DET_FACTORS.product_id%TYPE,
      p_cert_num                  IN ZX_LINES_DET_FACTORS.exempt_certificate_number%TYPE,
      p_exmpt_rsn_code            IN ZX_LINES_DET_FACTORS.exempt_reason_code%TYPE,
      p_exemption_control_flag    IN ZX_LINES_DET_FACTORS.Exemption_Control_Flag%TYPE,
      p_tax_regime_code           IN ZX_TRX_PRE_PROC_OPTIONS_GT.Tax_Regime_Code%TYPE,
      p_position                  IN NUMBER,
      p_error_status              OUT NOCOPY VARCHAR2
   ) IS

   x_ret_status    VARCHAR2(30);
   x_exempt_record ZX_TCM_GET_EXEMPT_PKG.EXEMPTION_REC_TYPE;

   TYPE tax_identifier_table IS TABLE OF VARCHAR2(100)
	INDEX BY BINARY_INTEGER;
   tax_identifier_tab tax_identifier_table;

   l_api_name            CONSTANT VARCHAR2(80) := 'POPULATE_EXEMPTION_DETAILS';
   l_location_type       VARCHAR2(100);
   l_exempt_percent ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_NUMBER_ATTRIBUTE1%TYPE;
   l_exempt_reason ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE4%TYPE;
   l_certificate_number ZX_PRVDR_LINE_EXTNS_GT.LINE_EXT_VARCHAR_ATTRIBUTE3%TYPE;
   l_tax_account_source_tax  VARCHAR2(50);
   l_jurisdiction_rec ZX_TCM_GEO_JUR_PKG.tax_jurisdiction_rec_type;
   l_jurisdictions_found VARCHAR2(5);
   l_multiple_jurisdictions_flag VARCHAR2(5);
   l_ptnr_exemption_indx            VARCHAR2(4000);

   BEGIN

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;

      /*Set the return status to Success */
      x_ret_status := FND_API.G_RET_STS_SUCCESS;

      x_exempt_record := null;

      tax_identifier_tab(1):= 'STATE';
      tax_identifier_tab(2):= 'COUNTY';
      tax_identifier_tab(3):= 'CITY';

     /* Call the get_tax_exemptions procedure from the TCM Exemptions package to collect the
        exemption_id , default percentage rate into the x_exemption_record.Do this for each
        location specific tax ie call this procedure identically for the p_tax value of
        STATE,COUNTY,CITY */

      FOR i IN tax_identifier_tab.first .. tax_identifier_tab.last

      LOOP

	IF event_class_code_tab(p_position) = 'CREDIT_MEMO'
	   AND adjusted_doc_trx_id_tab(p_position) IS NOT NULL THEN
		l_tax_account_source_tax := NULL;
		IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING(G_LEVEL_STATEMENT,'Tax Account Source Tax Inside Credit: ',l_tax_account_source_tax);
		END IF;
	ELSE
	   BEGIN
		SELECT NVL(TAX_EXMPT_SOURCE_TAX, TAX_ACCOUNT_SOURCE_TAX) --Bug 8724051
		INTO l_tax_account_source_tax
		FROM ZX_SCO_TAXES_B_V
		WHERE tax_regime_code = p_tax_regime_code AND
		      tax = tax_identifier_tab(i) AND
		      ( g_trx_date >= effective_from AND
		       (g_trx_date <= effective_to OR effective_to IS NULL));
           EXCEPTION
	      WHEN OTHERS THEN
                IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
		     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||L_API_NAME,SQLERRM);
                END IF;
		NULL;
           END;
	END IF;

	IF l_tax_account_source_tax IS NOT NULL THEN
		IF l_tax_account_source_tax = 'STATE' THEN
			l_exempt_percent     := arp_state_exempt_percent_tab(p_position);
			l_exempt_reason      := arp_state_exempt_reason_tab(p_position);
		ELSIF l_tax_account_source_tax = 'COUNTY' THEN
			l_exempt_percent     := arp_county_exempt_pct_tab(p_position);
			l_exempt_reason      := arp_county_exempt_reason_tab(p_position);
		ELSIF l_tax_account_source_tax = 'CITY' THEN
			l_exempt_percent     := arp_city_exempt_pct_tab(p_position);
			l_exempt_reason      := arp_city_exempt_reason_tab(p_position);
		END IF;
		l_certificate_number := cert_num_tab(p_position);

		IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING(G_LEVEL_STATEMENT,'Percent: ',to_char(l_exempt_percent));
			FND_LOG.STRING(G_LEVEL_STATEMENT,'Reason: ',to_char(l_exempt_reason));
			FND_LOG.STRING(G_LEVEL_STATEMENT,'Certificate: ',to_char(l_certificate_number));
		END IF;

		IF tax_identifier_tab(i) = 'STATE' THEN
		      arp_state_exempt_percent_tab(p_position) := l_exempt_percent;
		      arp_state_exempt_reason_tab(p_position) := l_exempt_reason;
		ELSIF tax_identifier_tab(i) = 'COUNTY' THEN
		      arp_county_exempt_pct_tab(p_position) := l_exempt_percent;
		      sec_county_exempt_pct_tab(p_position) := l_exempt_percent;
		      arp_county_exempt_reason_tab(p_position) := l_exempt_reason;
		ELSIF tax_identifier_tab(i) = 'CITY' THEN
		      arp_city_exempt_pct_tab(p_position) := l_exempt_percent;
		      sec_city_exempt_pct_tab(p_position) := l_exempt_percent;
		      arp_city_exempt_reason_tab(p_position) := l_exempt_reason;
		END IF;
		cert_num_tab(p_position) := l_certificate_number;
      -- adding code to populate exemption details in partner calculated tax lines
     l_ptnr_exemption_indx := to_char(trx_id_tab(p_position)) || '$' ||
                              to_char(trx_line_id_tab(p_position)) || '$' ||
                              l_tax_account_source_tax || '$' ||
                              p_tax_regime_code || '$' ||
                              to_char(tax_provider_id_tab(p_position));
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' l_ptnr_exemption_indx = ' || l_ptnr_exemption_indx );
    END IF;
    IF ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl.EXISTS(l_ptnr_exemption_indx)
       AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).trx_id
           = trx_id_tab(p_position)
       AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).trx_line_id
           = trx_line_id_tab(p_position)
       AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).tax
           = l_tax_account_source_tax
       AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).tax_regime_code
           = p_tax_regime_code
       AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).tax_provider_id
           = tax_provider_id_tab(p_position)
    THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' exemption info found in cache.' );
      END IF;
      IF tax_identifier_tab(i) = 'COUNTY' THEN
        ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).co_exempt_reason_code :=
                  arp_county_exempt_reason_tab(p_position);
        ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).co_exempt_reason :=
                  arp_county_exempt_reason_tab(p_position);
      ELSIF tax_identifier_tab(i) = 'CITY' THEN
        ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).ci_exempt_reason_code :=
                  arp_city_exempt_pct_tab(p_position);
        ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).ci_exempt_reason :=
                  arp_city_exempt_pct_tab(p_position);
      END IF;
    END IF;

	ELSE  /* There is No Source Tax */
	    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(G_LEVEL_STATEMENT,'Inside Else','No Source Tax');
	    END IF;
	    IF event_class_code_tab(p_position) = 'CREDIT_MEMO'
	       AND adjusted_doc_trx_id_tab(p_position) IS NOT NULL THEN

               /* Special processing is required here and we must NOT fetch the
	           exemption id from the tcm api. The geo level field here is
		   used to know what level of geography we are dealing with
		   to approprirately insert into the relevant nested tables */

               BEGIN
                  SELECT TAX_EXEMPTION_ID,
                         NVL(EXEMPT_RATE_MODIFIER ,0) * 100,
 	                       EXEMPT_REASON_CODE,
 	                       EXEMPT_CERTIFICATE_NUMBER
                    INTO x_exempt_record.exemption_id,
                         x_exempt_record.percent_exempt,
                         x_exempt_record.exempt_reason_code,
                         x_exempt_record.exempt_certificate_number
                    FROM ZX_LINES
                   WHERE application_id = adj_doc_appl_id_tab(p_position)
                     AND entity_code = adj_doc_entity_code_tab(p_position)
                     AND event_class_code = adj_evnt_cls_code_tab(p_position)
                     AND trx_id = adjusted_doc_trx_id_tab(p_position)
                     AND trx_line_id = adj_doc_line_id_tab(p_position)
                     AND trx_level_type = adj_doc_trx_level_type_tab(p_position)
                     AND tax_regime_code = p_tax_regime_code
                     AND tax = tax_identifier_tab(i);
               EXCEPTION WHEN NO_DATA_FOUND THEN
                     BEGIN
 	                     SELECT TAX_EXEMPTION_ID,
 	                            NVL(EXEMPT_RATE_MODIFIER ,0) * 100,
 	                            EXEMPT_REASON_CODE,
 	                            EXEMPT_CERTIFICATE_NUMBER
 	                     INTO x_exempt_record.exemption_id,
 	                          x_exempt_record.percent_exempt,
 	                          x_exempt_record.exempt_reason_code,
 	                          x_exempt_record.exempt_certificate_number
 	                     FROM ZX_LINES
 	                    WHERE application_id = adj_doc_appl_id_tab(p_position)
 	                      AND entity_code = adj_doc_entity_code_tab(p_position)
 	                      AND event_class_code = adj_evnt_cls_code_tab(p_position)
 	                      AND trx_id = adjusted_doc_trx_id_tab(p_position)
 	                      AND trx_line_id = adj_doc_line_id_tab(p_position)
 	                      AND trx_level_type = adj_doc_trx_level_type_tab(p_position)
 	                      AND tax_regime_code = p_tax_regime_code
 	                      AND tax = 'LOCATION';
 	                   EXCEPTION WHEN NO_DATA_FOUND THEN
                         x_exempt_record.exemption_id:= NULL;
                         x_exempt_record.exemption_id:= NULL;
 	                       x_exempt_record.percent_exempt:= NULL;
 	                       x_exempt_record.exempt_reason_code:= NULL;
 	                       x_exempt_record.exempt_certificate_number:= NULL;
 	                   END;
               END;

               IF x_exempt_record.exemption_id is NOT NULL THEN
			/*Proceed further only if the exemption id fetched is not null*/
                  BEGIN
                     SELECT rate_modifier
                       INTO   x_exempt_record.percent_exempt
                       FROM   ZX_EXEMPTIONS EXMP
                      WHERE  tax_exemption_id = x_exempt_record.exemption_id;
                  EXCEPTION WHEN NO_DATA_FOUND THEN
                     IF (g_level_exception >= g_current_runtime_level ) THEN
                        FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
                     END IF;
                     x_ret_status := FND_API.G_RET_STS_UNEXP_ERROR;
                     g_string :='No Data found from ZX_EXEMPTIONS for provided id';
                     error_exception_handle(g_string);
                       --x_messages_tbl:=g_messages_tbl;
                     RETURN;
                  END;
               END IF;

	    ELSE      /*       Beginning of regular processing     */

	    /* Adding the Code for exemptions to work as in 11i*/

		IF ship_to_loc_id_tab(p_position) IS NOT NULL THEN
			l_location_type := 'SHIP_TO';
		ELSIF bill_to_location_id_tab(p_position) IS NOT NULL THEN
			l_location_type := 'BILL_TO';
		ELSE
			l_location_type := NULL;
		END IF;

		IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING(G_LEVEL_STATEMENT,'Location Type: ',l_location_type);
			FND_LOG.STRING(G_LEVEL_STATEMENT,'Location ID: ',to_char(p_bill_to_location_id));
		END IF;

		IF p_bill_to_location_id IS NOT NULL THEN
			ZX_TCM_GEO_JUR_PKG.get_tax_jurisdictions (
		                    p_location_id      =>  p_bill_to_location_id,
		                    p_location_type    =>  l_location_type,
				    p_tax              =>  tax_identifier_tab(i),
				    p_tax_regime_code  =>  p_tax_regime_code,
				    p_trx_date         =>  g_trx_date,
				    x_tax_jurisdiction_rec =>  l_jurisdiction_rec,
				    x_jurisdictions_found => l_jurisdictions_found,
				    x_return_status    =>  x_ret_status);
		END IF;

		IF (x_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN
			/*FND_LOG.STRING(g_level_statement,
				       'In Populate Exemption Details',
				       'After calling get_tax_jurisdictions, x_return_status = '|| x_ret_status);*/
			RETURN;
		ELSE
			IF l_jurisdiction_rec.tax_jurisdiction_id IS NOT NULL THEN
				l_multiple_jurisdictions_flag := 'N';
				/*FND_LOG.STRING(g_level_statement,
						'Jurisdiction ID: ',
						l_jurisdiction_rec.tax_jurisdiction_id);*/
			ELSE
				IF l_jurisdictions_found = 'Y' THEN
					l_multiple_jurisdictions_flag := 'Y';
				ELSE
					l_multiple_jurisdictions_flag := 'N';
				END IF;
				l_jurisdiction_rec.tax_jurisdiction_id := NULL;
			END IF;
		END IF;

	    /* End of changes */

               ZX_TCM_GET_EXEMPT_PKG.get_tax_exemptions(
			       p_bill_to_cust_site_use_id	=>    p_bill_to_site_use,
			       p_bill_to_cust_acct_id		=>    p_bill_third_pty_acct_id,
			       p_bill_to_party_site_ptp_id	=>    p_bill_to_site_tax_prof , -- fixed for 7610995
			       p_bill_to_party_ptp_id		=>    p_bill_to_party_tax_id,
			       p_sold_to_party_site_ptp_id	=>    p_hq_site_tax_prof_id,
			       p_sold_to_party_ptp_id		=>    p_hq_party_tax_prof_id_tab,
			       p_inventory_org_id		=>    p_product_org_id,
			       p_inventory_item_id		=>    p_product_id,
			       p_exempt_certificate_number	=>    p_cert_num,
			       p_reason_code			=>    p_exmpt_rsn_code,
			       p_exempt_control_flag		=>    p_exemption_control_flag,
			       p_tax_date			=>    g_trx_date,
			       p_tax_regime_code		=>    p_tax_regime_code,
			       p_tax				=>    tax_identifier_tab(i),
			       p_tax_status_code		=>    'STANDARD',
			       p_tax_rate_code			=>    'STANDARD',
			       p_tax_jurisdiction_id		=>    l_jurisdiction_rec.tax_jurisdiction_id,
			       p_multiple_jurisdictions_flag	=>    l_multiple_jurisdictions_flag,
			       p_event_class_rec		=>    NULL,
			       x_return_status			=>    x_ret_status,
			       x_exemption_rec			=>    x_exempt_record
			       );

            END IF;

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' tax_identifier_tab(i) = ' || tax_identifier_tab(i));
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' x_exempt_record.exemption_id = ' || x_exempt_record.exemption_id);
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' x_exempt_record.exempt_certificate_number = ' || x_exempt_record.exempt_certificate_number);
            END IF;

            IF x_exempt_record.exemption_id is NULL THEN
                use_step_tab(p_position) := 'Y';
		            step_proc_flag_tab(p_position) := '1';
		            crit_flag_tab(p_position) := 'R';

          		IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' use_step_tab(p_position) = ' || use_step_tab(p_position));
          		       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' step_proc_flag_tab(p_position) = ' || step_proc_flag_tab(p_position));
          	               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' crit_flag_tab(p_position) = ' || crit_flag_tab(p_position));
          		END IF;
            ELSIF x_exempt_record.exemption_id is NOT NULL OR
 	                (x_exempt_record.percent_exempt IS NOT NULL
                   AND event_class_code_tab(p_position) = 'CREDIT_MEMO') THEN
               /* This condition check is necessary because we have to cater to the
		  condition that if the special processing code logic returned a null
		  exemption id then we have to skip the iteration all together.Also
	  	  this possibility(exemption id being null)
		  is only there for the special processing code logic .So we can safely
		  use this condition without in any way harming the regular processing.

                  The overall logic here is like this:
			  Initially populate the exemption id into a nested table at the same index .Meaning if a exemption
			  id of 2000 gets derived for a state level tax then for the exemptions nested table store this
			  value of 2000 at the 2000th location in the table.Also use the derived exemption id to
			  call the ARP_TAX_VIEW_TAXWARE.GET_EXEMPTIONS in order to populate the exemption records table
			  at the same location ie 2000.

			  ****NOTE**** Here p_position is the position in the linear table (in the main loop)
				       into which the derived values are ultimately getting inserted .
               */
              IF NOT exemptions_info_tab.EXISTS(NVL(x_exempt_record.exemption_id, -99)) THEN
 	              IF x_exempt_record.exemption_id IS NOT NULL THEN
                 ARP_TAX_VIEW_TAXWARE.GET_EXEMPTIONS(
					       X_EXEMPT_RECORD.EXEMPTION_ID,  --This is the input parameter for this call
					       exemptions_info_tab(x_exempt_record.exemption_id).state_exempt_pct,
					       exemptions_info_tab(x_exempt_record.exemption_id).state_exempt_reason,
					       exemptions_info_tab(x_exempt_record.exemption_id).state_cert_no,
					       exemptions_info_tab(x_exempt_record.exemption_id).county_exempt_pct,
					       exemptions_info_tab(x_exempt_record.exemption_id).county_exempt_reason,
					       exemptions_info_tab(x_exempt_record.exemption_id).county_cert_no,
					       exemptions_info_tab(x_exempt_record.exemption_id).city_exempt_pct  ,
					       exemptions_info_tab(x_exempt_record.exemption_id).city_exempt_reason,
					       exemptions_info_tab(x_exempt_record.exemption_id).city_cert_no,
					       exemptions_info_tab(x_exempt_record.exemption_id).sec_county_exempt_percent,
					       exemptions_info_tab(x_exempt_record.exemption_id).sec_city_exempt_percent,
					       exemptions_info_tab(x_exempt_record.exemption_id).use_step,
					       exemptions_info_tab(x_exempt_record.exemption_id).Step_Proc_Flag,
					       exemptions_info_tab(x_exempt_record.exemption_id).Crit_Flag
					       );

                  IF exemptions_info_tab(x_exempt_record.exemption_id).state_exempt_pct IS NULL THEN
                     /* If the user extensible procedure returned a null then use the default percentage
                        rate extracted into the exemptions record*/
                     exemptions_info_tab(x_exempt_record.exemption_id).state_exempt_pct := x_exempt_record.percent_exempt;
                  END IF;

                  IF exemptions_info_tab(x_exempt_record.exemption_id).state_exempt_reason IS NULL THEN
                     /* If the user extensible procedure returned a null then use the default exempt
                        reason extracted into the exemptions record*/
                     exemptions_info_tab(x_exempt_record.exemption_id).state_exempt_reason := SUBSTRB(x_exempt_record.exempt_reason_code,1,1);
                  END IF;

                  IF exemptions_info_tab(x_exempt_record.exemption_id).state_cert_no IS NULL THEN
                     /* If the user extensible procedure returned a null then use the default exempt
                        certificate number extracted into the exemptions record*/
                     exemptions_info_tab(x_exempt_record.exemption_id).state_cert_no := SUBSTRB(x_exempt_record.exempt_certificate_number,1,15);
                  END IF;

                  IF exemptions_info_tab(x_exempt_record.exemption_id).county_exempt_pct IS NULL THEN
                     exemptions_info_tab(x_exempt_record.exemption_id).county_exempt_pct:= x_exempt_record.percent_exempt;
                  END IF;

                  IF exemptions_info_tab(x_exempt_record.exemption_id).county_exempt_reason IS NULL THEN
                     exemptions_info_tab(x_exempt_record.exemption_id).county_exempt_reason := SUBSTRB(x_exempt_record.exempt_reason_code,1,1);
                  END IF;

                  IF exemptions_info_tab(x_exempt_record.exemption_id).city_exempt_pct IS NULL THEN
                     exemptions_info_tab(x_exempt_record.exemption_id).city_exempt_pct := x_exempt_record.percent_exempt;
                  END IF;

                  IF exemptions_info_tab(x_exempt_record.exemption_id).city_exempt_reason IS NULL THEN
                     exemptions_info_tab(x_exempt_record.exemption_id).city_exempt_reason := SUBSTRB(x_exempt_record.exempt_reason_code,1,1);
                  END IF;

                  IF exemptions_info_tab(x_exempt_record.exemption_id).Sec_County_Exempt_Percent IS NULL THEN
                     exemptions_info_tab(x_exempt_record.exemption_id).Sec_County_Exempt_Percent := x_exempt_record.percent_exempt;
                  END IF;

                  IF exemptions_info_tab(x_exempt_record.exemption_id).Sec_City_Exempt_Percent IS NULL THEN
                     exemptions_info_tab(x_exempt_record.exemption_id).Sec_City_Exempt_Percent := x_exempt_record.percent_exempt;
                  END IF;

               END IF;
              END IF;
 	             IF x_exempt_record.exemption_id IS NOT NULL THEN
               IF tax_identifier_tab(i) = 'STATE' THEN
                  arp_state_exempt_percent_tab(p_position) := exemptions_info_tab(x_exempt_record.exemption_id).state_exempt_pct;
                  arp_state_exempt_reason_tab(p_position) := exemptions_info_tab(x_exempt_record.exemption_id).state_exempt_reason;

	             ELSIF tax_identifier_tab(i) = 'COUNTY' THEN
                  arp_county_exempt_pct_tab(p_position) := exemptions_info_tab(x_exempt_record.exemption_id).county_exempt_pct;
                  arp_county_exempt_reason_tab(p_position) := exemptions_info_tab(x_exempt_record.exemption_id).county_exempt_reason;
		              county_cert_no_tab(p_position) := exemptions_info_tab(x_exempt_record.exemption_id).county_cert_no;
		              sec_county_exempt_pct_tab(p_position) :=exemptions_info_tab(x_exempt_record.exemption_id).Sec_County_Exempt_Percent;

	             ELSIF tax_identifier_tab(i) = 'CITY' THEN
                  arp_city_exempt_pct_tab(p_position) := exemptions_info_tab(x_exempt_record.exemption_id).city_exempt_pct;
                  arp_city_exempt_reason_tab(p_position) := exemptions_info_tab(x_exempt_record.exemption_id).city_exempt_reason;
                  city_cert_no_tab(p_position) :=exemptions_info_tab(x_exempt_record.exemption_id).city_cert_no;
   		            sec_city_exempt_pct_tab(p_position) := exemptions_info_tab(x_exempt_record.exemption_id).Sec_City_Exempt_Percent;

	             END IF;
               cert_num_tab(p_position) := nvl(p_cert_num,exemptions_info_tab(x_exempt_record.exemption_id).state_cert_no);
                              ELSIF (x_exempt_record.percent_exempt IS NOT NULL AND event_class_code_tab(p_position) = 'CREDIT_MEMO') THEN
 	                  IF tax_identifier_tab(i) = 'STATE' THEN
 	                    arp_state_exempt_percent_tab(p_position) := x_exempt_record.percent_exempt;
 	                    arp_state_exempt_reason_tab(p_position) := SUBSTRB(x_exempt_record.exempt_reason_code,1,1);
 	                  ELSIF tax_identifier_tab(i) = 'COUNTY' THEN
 	                    arp_county_exempt_pct_tab(p_position) := x_exempt_record.percent_exempt;
 	                    arp_county_exempt_reason_tab(p_position) := SUBSTRB(x_exempt_record.exempt_reason_code,1,1);
 	                  ELSIF tax_identifier_tab(i) = 'CITY' THEN
 	                    arp_city_exempt_pct_tab(p_position) := x_exempt_record.percent_exempt;
 	                    arp_city_exempt_reason_tab(p_position) := SUBSTRB(x_exempt_record.exempt_reason_code,1,1);
 	                  END IF;
 	                  cert_num_tab(p_position) := nvl(p_cert_num, x_exempt_record.exempt_certificate_number);
 	                END IF;

 	                -- adding code to populate exemption details in partner calculated tax lines
 	                l_ptnr_exemption_indx := to_char(trx_id_tab(p_position)) || '$' ||
 	                                         to_char(trx_line_id_tab(p_position)) || '$' ||
 	                                         tax_identifier_tab(i) || '$' ||
 	                                         p_tax_regime_code || '$' ||
 	                                         to_char(tax_provider_id_tab(p_position));
 	                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
 	                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' l_ptnr_exemption_indx = ' || l_ptnr_exemption_indx );
 	                END IF;
 	                IF ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl.EXISTS(l_ptnr_exemption_indx)
 	                   AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).trx_id
 	                       = trx_id_tab(p_position)
 	                   AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).trx_line_id
 	                       = trx_line_id_tab(p_position)
 	                   AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).tax
 	                       = tax_identifier_tab(i)
 	                   AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).tax_regime_code
 	                       = p_tax_regime_code
 	                   AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).tax_provider_id
 	                       = tax_provider_id_tab(p_position)
 	                THEN
 	                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
 	                    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' exemption info found in cache.' );
 	                  END IF;
 	                  --NULL;
 	                ELSE
 	                  ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).trx_id := trx_id_tab(p_position);
 	                  ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).trx_line_id := trx_line_id_tab(p_position);
 	                  ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).tax := tax_identifier_tab(i);
 	                  ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).tax_regime_code := p_tax_regime_code;
 	                  ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).tax_provider_id := tax_provider_id_tab(p_position);
 	                  ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).tax_exemption_id := x_exempt_record.exemption_id;
 	                  ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).exempt_certificate_number := cert_num_tab(p_position);

 	                  IF x_exempt_record.exemption_id IS NOT NULL THEN
 	                    ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).st_exempt_reason_code :=
 	                                NVL(exemptions_info_tab(x_exempt_record.exemption_id).state_exempt_reason,x_exempt_record.exempt_reason_code);
 	                    ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).co_exempt_reason_code :=
 	                                NVL(exemptions_info_tab(x_exempt_record.exemption_id).county_exempt_reason,x_exempt_record.exempt_reason_code);
 	                    ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).ci_exempt_reason_code :=
 	                                NVL(exemptions_info_tab(x_exempt_record.exemption_id).city_exempt_reason,x_exempt_record.exempt_reason_code);
 	                    ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).st_exempt_reason :=
 	                                NVL(exemptions_info_tab(x_exempt_record.exemption_id).state_exempt_reason,x_exempt_record.exempt_reason_code);
 	                    ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).co_exempt_reason :=
 	                                NVL(exemptions_info_tab(x_exempt_record.exemption_id).county_exempt_reason,x_exempt_record.exempt_reason_code);
 	                    ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).ci_exempt_reason :=
 	                                NVL(exemptions_info_tab(x_exempt_record.exemption_id).city_exempt_reason,x_exempt_record.exempt_reason_code);
 	                  ELSIF (x_exempt_record.percent_exempt IS NOT NULL AND event_class_code_tab(p_position) = 'CREDIT_MEMO') THEN
 	                    ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).st_exempt_reason_code := x_exempt_record.exempt_reason_code;
 	                    ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).co_exempt_reason_code := x_exempt_record.exempt_reason_code;
 	                    ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).ci_exempt_reason_code := x_exempt_record.exempt_reason_code;
 	                    ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).st_exempt_reason := x_exempt_record.exempt_reason_code;
 	                    ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).co_exempt_reason := x_exempt_record.exempt_reason_code;
 	                    ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).ci_exempt_reason := x_exempt_record.exempt_reason_code;
 	                  END IF;
 	                END IF;
            END IF; /* Tax Account Source Tax */
	  END IF;   /*End of special processing if*/

      END LOOP;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' arp_state_exempt_percent_tab(p_position) = ' || arp_state_exempt_percent_tab(p_position));
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' arp_county_exempt_pct_tab(p_position) = ' || arp_county_exempt_pct_tab(p_position));
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' arp_city_exempt_pct_tab(p_position) = ' || arp_city_exempt_pct_tab(p_position));
        -- FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' arp_district_exempt_pct_tab(p_position) = ' || arp_district_exempt_pct_tab(p_position));
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' p_cert_num = ' || p_cert_num);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, ' cert_num_tab(p_position) = ' || cert_num_tab(p_position));
      END IF;

      p_error_status := x_ret_status;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                ' RETURN_STATUS = ' || p_error_status);
      END IF;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

EXCEPTION
      WHEN OTHERS THEN
         IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
	 p_error_status := FND_API.G_RET_STS_UNEXP_ERROR;

END POPULATE_EXEMPTION_DETAILS;

   /*===========================================================================+
    | PROCEDURE
    |    Initialize_Nested_Tables
    | IN
    |
    | OUT NOCOPY
    |
    | DESCRIPTION
    |         This is a start up procedure that deletes any existing data from the nested
    |         tables
    |
    |
    | SCOPE - PRIVATE
    |
    | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
    |
    | CALLED FROM
    |
    |
    | MODIFICATION HISTORY
    | 08/13/2004   Arnab Sengupta   Created.
    |
    +==========================================================================*/

    PROCEDURE Initialize_Nested_Tables
    IS
	l_api_name            CONSTANT VARCHAR2(80) := 'INITIALIZE_NESTED_TABLES';
    BEGIN
        IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
        END IF;

	internal_org_id_tab.DELETE;
	application_id_tab.DELETE;
	entity_code_tab.DELETE;
	event_class_code_tab.DELETE;
	trx_id_tab.DELETE;
	tax_provider_id_tab.DELETE;
	tax_regime_code_tab.DELETE;
	trx_line_type_tab.DELETE;
	trx_line_id_tab.DELETE;
	product_id_tab.DELETE;
	Product_Org_Id_tab.DELETE;
	ship_to_tx_id_tab.DELETE;
	ship_from_tx_id_tab.DELETE;
	cert_num_tab.DELETE;
	exmpt_rsn_code_tab.DELETE;
	exemption_control_flag_tab.DELETE;
	ship_to_site_tax_prof_tab.DELETE;
	ship_to_loc_id_tab.DELETE;
	exmpt_control_flg_tab.DELETE;
	arp_tax_type_tab.DELETE;
	arp_product_code_tab.DELETE;
	use_step_tab.DELETE;
	arp_audit_flag_tab.DELETE;
	arp_ship_to_add_tab.DELETE;
	arp_ship_from_add_tab.DELETE;
	arp_poa_add_code_tab.DELETE;
	arp_customer_code_tab.DELETE;
	arp_customer_name_tab.DELETE;
	arp_company_code_tab.DELETE;
	arp_division_code_tab.DELETE;
	arp_vnd_ctrl_exmpt_tab.DELETE;
	arp_use_nexpro_tab.DELETE;
	arp_service_ind_tab.DELETE;
	arp_tax_sel_param_tab.DELETE;
	arp_transaction_date_tab.DELETE;
	ship_to_address_id_tab.DELETE;
	ship_to_party_id_tab.DELETE;
	arp_state_exempt_reason_tab.DELETE;
	arp_county_exempt_reason_tab.DELETE;
	arp_city_exempt_reason_tab.DELETE;
	step_proc_flag_tab.DELETE;
	arp_state_exempt_percent_tab.DELETE;
	arp_county_exempt_pct_tab.DELETE;
	arp_city_exempt_pct_tab.DELETE;
	ship_to_site_use_tab.DELETE;
	bill_to_site_use_tab.DELETE;
	bill_to_site_tax_prof_tab.DELETE;
	bill_to_party_tax_id_tab.DELETE;
	bill_to_location_id_tab.DELETE;
	trad_hq_site_tax_prof_id_tab.DELETE;
	trad_hq_party_tax_prof_id_tab.DELETE;
	bill_third_pty_acct_id_tab.DELETE;
	line_level_action_tab.DELETE;
	adjusted_doc_trx_id_tab.DELETE;
	line_amount_tab.DELETE;
	exemptions_info_tab.DELETE;
	trx_type_id_tab.DELETE;
	state_cert_no_tab.DELETE;
	county_cert_no_tab.DELETE;
	city_cert_no_tab.DELETE;
	crit_flag_tab.DELETE;
	sec_county_exempt_pct_tab.DELETE;
	sec_city_exempt_pct_tab.DELETE;
        adj_doc_appl_id_tab.DELETE;
	adj_doc_entity_code_tab.DELETE;
	adj_evnt_cls_code_tab.DELETE;
	adj_doc_line_id_tab.DELETE;
	adj_doc_trx_level_type_tab.DELETE;
	ship_third_pty_site_tab.DELETE;
	bill_third_pty_site_tab.DELETE;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME ||l_api_name||'()-');
        END IF;

   EXCEPTION WHEN COLLECTION_IS_NULL THEN
	NULL;

END Initialize_Nested_Tables;

    PROCEDURE  Initialize_Exemption_Tables IS

    l_api_name            CONSTANT VARCHAR2(80) := 'INITIALIZE_EXEMPTION_TABLES';
    BEGIN
	   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
           END IF;

	     FOR i in 1..nvl(internal_org_id_tab.last,0)  --Loop 1
		LOOP


			arp_state_exempt_reason_tab(i):= NULL;
			arp_state_exempt_percent_tab(i):= NULL;
			state_cert_no_tab(i):= NULL;
			use_step_tab(i):= NULL;
			step_proc_flag_tab(i):= NULL;
			crit_flag_tab(i):= NULL;
			arp_county_exempt_reason_tab(i):= NULL;
			arp_county_exempt_pct_tab(i):= NULL;
			county_cert_no_tab(i):= NULL;
			sec_county_exempt_pct_tab(i):= NULL;
			arp_city_exempt_reason_tab(i):= NULL;
			arp_city_exempt_pct_tab(i):= NULL;
			city_cert_no_tab(i):= NULL;
			sec_city_exempt_pct_tab(i):= NULL;

		END LOOP;
	   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME ||l_api_name||'()-');
           END IF;


    END Initialize_Exemption_Tables;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    CHECK_GEOCODE                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns TRUE if the GEOCODE seems to be valid                          |
 |    (in the format SSZZZZZGG)                                              |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     01-NOV-05    Santosh Vaze      Created for Bug 4668932                |
 |                                                                           |
 +===========================================================================*/


FUNCTION CHECK_GEOCODE(p_geocode IN VARCHAR2)
RETURN BOOLEAN
IS
l_api_name            CONSTANT VARCHAR2(80) := 'CHECK_GEOCODE';
BEGIN
  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
  END IF;
  if substrb(p_geocode, 1, 2) between 'AA' and 'ZZ' and
     substrb(p_geocode, 3, 5) between '00000' and '99999' and
     substrb(p_geocode, 8, 2) between '00' and '99' then
    return TRUE;
  end if;

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME ||l_api_name||'()-');
  END IF;

  return FALSE;
END CHECK_GEOCODE;

PROCEDURE DERIVE_TRX_LEVEL_ATTR
IS

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_TRX_LEVEL_ATTR';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   g_org_id      := NULL;
   g_sales_repid := NULL;
   IF event_class_code_tab(i) = 'INVOICE_ADJUSTMENT' THEN
      IF adjusted_doc_trx_id_tab(i) IS NOT NULL THEN
         BEGIN
            SELECT org_id
                 , primary_salesrep_id
              INTO g_org_id
                 , g_sales_repid
              FROM ra_customer_trx_all
             WHERE customer_trx_id = adjusted_doc_trx_id_tab(i);
         EXCEPTION
            WHEN OTHERS THEN
               g_org_id      := internal_org_id_tab(i);
               g_sales_repid := NULL;
         END;
      END IF;
   ELSE
      IF trx_id_tab(i) IS NOT NULL THEN
         BEGIN
            SELECT org_id
                 , primary_salesrep_id
              INTO g_org_id
                 , g_sales_repid
              FROM ra_customer_trx_all
             WHERE customer_trx_id = trx_id_tab(i);
         EXCEPTION
            WHEN OTHERS THEN
               g_org_id      := internal_org_id_tab(i);
               g_sales_repid := NULL;
         END;
      END IF;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_TRX_LEVEL_ATTR;

PROCEDURE DERIVE_AUDIT_FLAG
IS

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_AUDIT_FLAG';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   IF l_view_name = 'TAX_ADJUSTMENTS_V_A' THEN
      BEGIN
         arp_audit_flag_tab(i)  := ARP_TAX_VIEW_TAXWARE.AUDIT_FLAG
                                      (l_view_name,
                                       trx_id_tab(i),
                                       trx_line_id_tab(i));
      EXCEPTION WHEN OTHERS THEN
                 arp_audit_flag_tab(i):= NULL;
      END;

      IF arp_audit_flag_tab(i) IS NULL THEN
         BEGIN
            SELECT nvl(substrb(act.attribute15, 1, 1), 'Y')
              INTO arp_audit_flag_tab(i)
              FROM ar_receivables_trx act
             WHERE act.receivables_trx_id IN
                       (SELECT adj.receivables_trx_id
                          FROM ar_adjustments adj
                         WHERE adj.adjustment_id = trx_id_tab(i))
	       AND act.org_id = internal_org_id_tab(i);
         EXCEPTION WHEN OTHERS THEN
            arp_audit_flag_tab(i)  := 'Y';
         END;
      END IF;
   ELSE
      arp_audit_flag_tab(i)  := 'Y';
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
			'Quote Flag from ZX_GLOBAL_STRUCTURE'||ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.quote_flag);
   END IF;

   IF ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.quote_flag = 'Y' THEN
	arp_audit_flag_tab(i)  := 'N';
   END IF;
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Audit Flag :'||arp_audit_flag_tab(i));
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_AUDIT_FLAG;

PROCEDURE DERIVE_PRODUCT_CODE
IS

   l_product_id              ZX_LINES_DET_FACTORS.product_id%TYPE;
   l_memo_line_id            NUMBER;
   l_master_org_id           oe_system_parameters_all.master_organization_id%type;

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_PRODUCT_CODE';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||' ',G_PKG_NAME||': '
             ||l_api_name||'l_view_name :'||l_view_name);
   END IF;

   /* The product code function is not attached only to this view hence the if condition reads like this*/

   IF l_view_name <> 'TAX_ADJUSTMENTS_V_A' THEN

      /* Derive the product_id depending on the null or not null value of product_org_id*/
      IF product_org_id_tab(i) IS NOT NULL THEN
         l_product_id   := product_id_tab(i);
         l_memo_line_id := NULL;
      ELSE
         l_product_id := NULL;
         l_memo_line_id := product_id_tab(i);
      END IF;

      BEGIN
         arp_product_code_tab(i) := ARP_TAX_VIEW_TAXWARE.PRODUCT_CODE(l_view_name
                                                                     , trx_id_tab(i)
                                                                     , trx_line_id_tab(i)
                                                                     , l_product_id
                                                                     , l_memo_line_id);
      EXCEPTION WHEN OTHERS THEN
         arp_product_code_tab(i) := NULL;
      END;

      IF  arp_product_code_tab(i) IS NULL THEN
      BEGIN
         SELECT org_id
           INTO g_org_id
           FROM ra_customer_trx_lines_all
          WHERE customer_trx_id		= trx_id_tab(i)
            AND customer_trx_line_id	= trx_line_id_tab(i);
      EXCEPTION
         WHEN OTHERS THEN
            g_org_id := internal_org_id_tab(i);
      END;


/* Bug 5612024
      IF MO_GLOBAL.get_current_org_id <> nvl(g_org_id, -1) THEN
	 MO_GLOBAL.Set_Policy_Context('S', g_org_id);
      END IF;
*/
      l_master_org_id := oe_sys_parameters.value('MASTER_ORGANIZATION_ID', g_org_id);

      BEGIN
                 SELECT segment1
                   INTO arp_product_code_tab(i)
                   FROM mtl_system_items
                  WHERE inventory_item_id = l_product_id
                    AND organization_id   = l_master_org_id;
      EXCEPTION
                 WHEN OTHERS THEN
                    arp_product_code_tab(i) := NULL;
      END;
    END IF;
   ELSE
      arp_product_code_tab(i) := NULL;
   END IF;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         ' arp_product_code_tab(i) = ' || arp_product_code_tab(i));
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_PRODUCT_CODE;

PROCEDURE DERIVE_SHIP_TO_ADDRESS_CODE
IS
   l_tax_jurisdiction_rec    ZX_TCM_GEO_JUR_PKG.tax_jurisdiction_rec_type;
   x_ret_status              VARCHAR2(30);
   l_jurisdictions_found     VARCHAR2(1);
   l_ship_to_geocode   varchar2(30);
   l_state_code               VARCHAR2(60);
   l_postal_code              VARCHAR2(60);

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_SHIP_TO_ADDRESS_CODE';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   ship_to_address_id_tab(i) := NULL;
   IF ship_to_site_use_tab(i) is NOT NULL THEN
      BEGIN
                SELECT cust_site_uses.cust_acct_site_id
                INTO   ship_to_address_id_tab(i)
                FROM   HZ_CUST_SITE_USES_ALL cust_site_uses
                WHERE  cust_site_uses.site_use_id = ship_to_site_use_tab(i);
              EXCEPTION WHEN OTHERS THEN
                ship_to_address_id_tab(i) := NULL;
      END;
   END IF;

   IF ship_to_address_id_tab(i) is NULL THEN
      BEGIN
                SELECT cust_acct_site_id
                INTO   ship_to_address_id_tab(i)
                FROM   HZ_CUST_SITE_USES_ALL
                WHERE  site_use_id  = bill_to_site_use_tab(i);
              EXCEPTION WHEN NO_DATA_FOUND THEN
                ship_to_address_id_tab(i) := NULL;
      END;
   END IF;

   BEGIN
	  arp_ship_to_add_tab(i) :=  ARP_TAX_VIEW_TAXWARE.SHIP_TO_ADDRESS_CODE
						(l_view_name,
						trx_id_tab(i),
						trx_line_id_tab(i),
						ship_to_address_id_tab(i),
						ship_to_loc_id_tab(i),
						g_trx_date,
						NULL,--p_ship_to_state
						NULL--p_postal_code
						);
   EXCEPTION WHEN OTHERS THEN
	    arp_ship_to_add_tab(i):= NULL;
   END;

/* Bug 4668932 */
   IF arp_ship_to_add_tab(i) IS NULL
	    THEN
	       BEGIN
                 SELECT decode(nvl(loc.sales_tax_inside_city_limits,'1'),'0','0','1') || loc.sales_tax_geocode
                INTO   arp_ship_to_add_tab(i)
                FROM   hz_locations loc
                WHERE  loc.location_id = nvl(ship_to_loc_id_tab(i), bill_to_location_id_tab(i));
	       EXCEPTION WHEN OTHERS THEN
	         arp_ship_to_add_tab(i) := NULL;
	       END;
	       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            		FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME,'GeoCode Override: '||arp_ship_to_add_tab(i));
	       END IF;

               IF NOT check_geocode(substrb(nvl(arp_ship_to_add_tab(i),'XXXXXXXXXX'),2,9)) THEN
                  ZX_TCM_GEO_JUR_PKG.get_tax_jurisdictions(
                          p_location_id          => nvl(ship_to_loc_id_tab(i), bill_to_location_id_tab(i)),
                          p_location_type        => 'SHIP_TO',
                          p_tax                  => 'CITY',
		          p_tax_regime_code      => tax_regime_code_tab(i),
                          p_trx_date             => g_trx_date,
                          x_tax_jurisdiction_rec => l_tax_jurisdiction_rec,
                          x_jurisdictions_found  => l_jurisdictions_found,
                          x_return_status        => x_ret_status);

                  IF x_ret_status = FND_API.G_RET_STS_SUCCESS THEN
                     IF l_jurisdictions_found = 'Y' THEN
                        IF l_tax_jurisdiction_rec.tax_jurisdiction_code IS NOT NULL THEN
                           l_ship_to_geocode := l_tax_jurisdiction_rec.tax_jurisdiction_code;

			   arp_ship_to_add_tab(i) := '1' || substr(l_ship_to_geocode,4,2);
			   arp_ship_to_add_tab(i) := arp_ship_to_add_tab(i) || substr(l_ship_to_geocode,-8,5);
			   --arp_ship_to_add_tab(i) := arp_ship_to_add_tab(i) || substr(l_ship_to_geocode,-5,5);
			   arp_ship_to_add_tab(i) := arp_ship_to_add_tab(i) ||substr(l_ship_to_geocode,-2);
			   --arp_ship_to_add_tab(i) := arp_ship_to_add_tab(i) || '00';
                        END IF;
		      END IF;
		      IF l_jurisdictions_found = 'N' OR (l_jurisdictions_found = 'Y' AND l_tax_jurisdiction_rec.tax_jurisdiction_code IS NULL) THEN
		        BEGIN
			 SELECT state, substr(postal_code,1,5)
			 INTO l_state_code, l_postal_code
			 FROM HZ_LOCATIONS
			 WHERE location_id = NVL(ship_to_loc_id_tab(i), bill_to_location_id_tab(i));
                        EXCEPTION
		         WHEN OTHERS THEN
                           IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                             FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
			          'No data found for this location_id : '||NVL(ship_to_loc_id_tab(i), bill_to_location_id_tab(i)));
                           END IF;
                        END;
                        arp_ship_to_add_tab(i) := '1' || NVL(l_state_code,'CA') || l_postal_code || '00';
                      END IF;
                  END IF;
               END IF;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_SHIP_TO_ADDRESS_CODE;

PROCEDURE DERIVE_SHIP_FROM_ADDRESS_CODE
IS
   l_sfr_geocode             VARCHAR2(10);
   l_sfr_in_out_flag         VARCHAR2(1);
   l_flag                    BOOLEAN;
   l_inventory_item_id       NUMBER;
   l_master_org_id           oe_system_parameters_all.master_organization_id%type;
   l_ship_from_party_id      ZX_PARTY_TAX_PROFILE.PARTY_ID%TYPE;
   l_ship_from_location_id   ZX_LINES_DET_FACTORS.SHIP_FROM_LOCATION_ID%TYPE;

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_SHIP_FROM_ADDRESS_CODE';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   BEGIN
      SELECT SHIP_FROM_LOCATION_ID
      INTO l_ship_from_location_id
      FROM ZX_LINES_DET_FACTORS
      WHERE APPLICATION_ID = application_id_tab(i)
      AND ENTITY_CODE = entity_code_tab(i)
      AND EVENT_CLASS_CODE = event_class_code_tab(i)
      AND TRX_ID = trx_id_tab(i)
      AND TRX_LINE_ID = trx_line_id_tab(i);
   EXCEPTION
    WHEN OTHERS THEN
      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Error : ' || SQLERRM);
      END IF;
      l_ship_from_location_id := NULL;
   END;

   BEGIN
      IF ship_from_tx_id_tab(i) IS NOT NULL THEN
         IF p_party_id_tbl.EXISTS(ship_from_tx_id_tab(i)) THEN
            l_ship_from_party_id := p_party_id_tbl(ship_from_tx_id_tab(i));
         ELSE
            SELECT party_id
              INTO l_ship_from_party_id
              FROM ZX_PARTY_TAX_PROFILE
             WHERE party_tax_profile_id = ship_from_tx_id_tab(i);

            p_party_id_tbl(ship_from_tx_id_tab(i)) := l_ship_from_party_id;
         END IF;
      END IF;
   EXCEPTION WHEN NO_DATA_FOUND THEN
      l_ship_from_party_id := NULL;
   END;

   arp_ship_from_add_tab(i) :=  ARP_TAX_VIEW_TAXWARE.SHIP_FROM_ADDRESS_CODE
                                   (l_view_name,
                                    trx_id_tab(i),
                                    trx_line_id_tab(i),
                                    l_ship_from_party_id);

   IF arp_ship_from_add_tab(i) is NULL THEN
    BEGIN
      SELECT lc.loc_information13
      INTO arp_ship_from_add_tab(i)
      FROM hr_locations_all lc, hr_organization_units hr
      WHERE hr.organization_id = l_ship_from_party_id
      AND hr.location_id = lc.location_id;

      IF arp_ship_from_add_tab(i) IS NOT NULL THEN
        arp_ship_from_add_tab(i) := '1'||arp_ship_from_add_tab(i);
      ELSE
        arp_ship_from_add_tab(i):= arp_tax_view_taxware.USE_SHIP_TO;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      BEGIN
        SELECT lc.loc_information13
          INTO arp_ship_from_add_tab(i)
          FROM hr_locations_all lc
         WHERE lc.location_id = l_ship_from_location_id;

        IF arp_ship_from_add_tab(i) IS NOT NULL THEN
          arp_ship_from_add_tab(i) := '1'||arp_ship_from_add_tab(i);
        ELSE
          arp_ship_from_add_tab(i):= arp_tax_view_taxware.USE_SHIP_TO;
        END IF;
      EXCEPTION WHEN OTHERS THEN
        arp_ship_from_add_tab(i):= arp_tax_view_taxware.USE_SHIP_TO;
      END;
    END;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_SHIP_FROM_ADDRESS_CODE;

PROCEDURE DERIVE_POA_ADDRESS_CODE
IS
   l_poa_geocode             VARCHAR2(10);
   l_poa_in_out_flag         VARCHAR2(1);

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_POA_ADDRESS_CODE';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   BEGIN
	arp_poa_add_code_tab(i)  := ARP_TAX_VIEW_TAXWARE.POA_ADDRESS_CODE
                                                            (l_view_name,
                                                             trx_id_tab(i),
                                                             trx_line_id_tab(i));
   Exception When Others then
	    arp_poa_add_code_tab(i)  := NULL;
   End;

	IF arp_poa_add_code_tab(i) is NULL then
	   BEGIN
		SELECT zxprdopt.SALES_TAX_GEOCODE
		INTO   arp_poa_add_code_tab(i)
		FROM   ZX_PRODUCT_OPTIONS_ALL zxprdopt
		WHERE  zxprdopt.application_id = application_id_tab(i)
		AND    zxprdopt.org_id = internal_org_id_tab(i)
		AND    (zxprdopt.event_class_mapping_id IS NULL
             	  OR zxprdopt.event_class_mapping_id = (SELECT EVENT_CLASS_MAPPING_ID
							  FROM   ZX_EVNT_CLS_MAPPINGS
							  WHERE  EVENT_CLASS_CODE = event_class_code_tab(i)
							  AND    APPLICATION_ID   = application_id_tab(i)
							  AND    ENTITY_CODE      = entity_code_tab(i)));
		IF arp_poa_add_code_tab(i) IS NULL THEN
		  arp_poa_add_code_tab(i) := arp_tax_view_taxware.USE_SHIP_TO;
    ELSE
      IF NOT check_geocode(arp_poa_add_code_tab(i)) THEN
        arp_poa_add_code_tab(i) := arp_tax_view_taxware.USE_SHIP_TO;
      ELSE
        arp_poa_add_code_tab(i) := '1'||arp_poa_add_code_tab(i);
	    END IF;
    END IF;
     EXCEPTION WHEN OTHERS THEN
		arp_poa_add_code_tab(i) := arp_tax_view_taxware.USE_SHIP_TO;
           END;
        END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         ' arp_poa_add_code_tab(i) = ' || arp_poa_add_code_tab(i));
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_POA_ADDRESS_CODE;

PROCEDURE DERIVE_POO_ADDRESS_CODE
IS
   l_poa_geocode             VARCHAR2(10);
   l_poa_in_out_flag         VARCHAR2(1);

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_POO_ADDRESS_CODE';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   BEGIN
	arp_poo_add_code_tab(i)  := ARP_TAX_VIEW_TAXWARE.POO_ADDRESS_CODE
                                                            (l_view_name,
                                                             trx_id_tab(i),
                                                             trx_line_id_tab(i),
							     g_sales_repid);
   Exception When Others then
	    arp_poo_add_code_tab(i)  := NULL;
   End;

	    IF arp_poo_add_code_tab(i) is NULL then
	      BEGIN
		select sales_tax_geocode
		into arp_poo_add_code_tab(i)
		from ra_salesreps
		where salesrep_id = g_sales_repid;
    IF arp_poo_add_code_tab(i) IS NULL THEN
      arp_poo_add_code_tab(i) := arp_tax_view_taxware.USE_SHIP_TO;
    ELSE
      IF NOT check_geocode(arp_poo_add_code_tab(i)) THEN
        arp_poo_add_code_tab(i) := arp_tax_view_taxware.USE_SHIP_TO;
      ELSE
		    arp_poo_add_code_tab(i) := '1'||arp_poo_add_code_tab(i);
		  END IF;
    END IF;
	      EXCEPTION WHEN OTHERS THEN
		arp_poo_add_code_tab(i) := arp_tax_view_taxware.USE_SHIP_TO;
              END;
            END IF;


   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         ' arp_poo_add_code_tab(i) = ' || arp_poo_add_code_tab(i));
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_POO_ADDRESS_CODE;

PROCEDURE DERIVE_CUSTOMER_CODE
IS

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_CUSTOMER_CODE';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   arp_customer_code_tab(i) := ARP_TAX_VIEW_TAXWARE.CUSTOMER_CODE
                                  (l_view_name,
                                   trx_id_tab(i),
                                   trx_line_id_tab(i));
   IF arp_customer_code_tab(i) IS NULL THEN
/* Bug 5007293: During negation: ZX_PTNR_LOCATION_INFO_GT is not yet populated */

    BEGIN

       SELECT account_number
       INTO arp_customer_code_tab(i)
       FROM HZ_CUST_ACCOUNTS
       WHERE cust_account_id = bill_third_pty_acct_id_tab(i);

    EXCEPTION
       WHEN OTHERS THEN
         arp_customer_code_tab(i) := NULL;
    END;

   IF arp_customer_code_tab(i) IS NULL THEN
      IF g_line_negation  THEN
         IF p_party_number_tbl.EXISTS(bill_to_party_tax_id_tab(i)) THEN
            arp_customer_code_tab(i) := p_party_number_tbl(bill_to_party_tax_id_tab(i));
         ELSE
            BEGIN
               SELECT pty.party_number
                 INTO arp_customer_code_tab(i)
                 FROM hz_parties pty,
                      zx_party_tax_profile ptp
                WHERE ptp.party_tax_profile_id = bill_to_party_tax_id_tab(i)
                  AND ptp.party_id = pty.party_id;
            EXCEPTION WHEN OTHERS THEN
               arp_customer_code_tab(i) := NULL;
            END;
            p_party_number_tbl(bill_to_party_tax_id_tab(i)) := arp_customer_code_tab(i);
         END IF;
      ELSE
         BEGIN
            SELECT zpli.bill_to_party_number
              INTO arp_customer_code_tab(i)
              FROM ZX_PTNR_LOCATION_INFO_GT zpli
                 , ZX_EVNT_CLS_MAPPINGS     zecm
             WHERE zpli.EVENT_CLASS_MAPPING_ID =  zecm.EVENT_CLASS_MAPPING_ID
               AND zecm.EVENT_CLASS_CODE       = event_class_code_tab(i)
               AND zecm.APPLICATION_ID         = application_id_tab(i)
               AND zecm.ENTITY_CODE            = entity_code_tab(i)
               AND zpli.TRX_ID                 = trx_id_tab(i)
               AND zpli.TRX_LINE_ID            = trx_line_id_tab(i);
         EXCEPTION WHEN OTHERS THEN
            arp_customer_code_tab(i) := NULL;
         END;

         IF arp_customer_code_tab(i) IS NULL THEN
            IF p_party_number_tbl.EXISTS(bill_to_party_tax_id_tab(i)) THEN
               arp_customer_code_tab(i) := p_party_number_tbl(bill_to_party_tax_id_tab(i));
            ELSE
               BEGIN
                  SELECT pty.party_number
                    INTO arp_customer_code_tab(i)
                    FROM hz_parties pty,
                         zx_party_tax_profile ptp
                   WHERE ptp.party_tax_profile_id = bill_to_party_tax_id_tab(i)
                     AND ptp.party_id = pty.party_id;
               EXCEPTION WHEN OTHERS THEN
                  arp_customer_code_tab(i) := NULL;
               END;
               p_party_number_tbl(bill_to_party_tax_id_tab(i)) := arp_customer_code_tab(i);
            END IF;
         END IF;
      END IF;
    END IF;
   END IF;
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

EXCEPTION WHEN OTHERS THEN
   arp_customer_code_tab(i):= NULL;
END DERIVE_CUSTOMER_CODE;

PROCEDURE DERIVE_CUSTOMER_NAME
IS

   l_party_id                ZX_PARTY_TAX_PROFILE.PARTY_ID%TYPE;
   l_ptp_id                  ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE;
   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_CUSTOMER_NAME';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;


   BEGIN
      arp_customer_name_tab(i) :=  ARP_TAX_VIEW_TAXWARE.CUSTOMER_NAME
                                                 (l_view_name,
                                                  trx_id_tab(i),
                                                  trx_line_id_tab(i));

      IF arp_customer_name_tab(i) IS NULL
              THEN
/* Bug 5007293: During negation: ZX_PTNR_LOCATION_INFO_GT is not yet populated */
                 IF g_line_negation  THEN
                    BEGIN
                       SELECT pty.party_name
                       INTO   arp_customer_name_tab(i)
                       FROM   hz_parties pty,
                              zx_party_tax_profile ptp
                       WHERE  ptp.party_tax_profile_id = bill_to_party_tax_id_tab(i)
                       AND    ptp.party_id = pty.party_id;
                    EXCEPTION WHEN OTHERS THEN
                       arp_customer_name_tab(i) := NULL;
                    END;
                 ELSE
                    BEGIN
                       SELECT zpli.BILL_TO_PARTY_NAME
                       INTO   arp_customer_name_tab(i)
                       FROM   ZX_PTNR_LOCATION_INFO_GT zpli
                            , ZX_EVNT_CLS_MAPPINGS     zecm
                       WHERE  zpli.EVENT_CLASS_MAPPING_ID =  zecm.EVENT_CLASS_MAPPING_ID
                       AND    zecm.EVENT_CLASS_CODE       = event_class_code_tab(i)
                       AND    zecm.APPLICATION_ID         = application_id_tab(i)
                       AND    zecm.ENTITY_CODE            = entity_code_tab(i)
                       AND    zpli.TRX_ID                 = trx_id_tab(i)
                       AND    zpli.TRX_LINE_ID            = trx_line_id_tab(i);
                    EXCEPTION WHEN OTHERS THEN
                       arp_customer_name_tab(i) := NULL;
                    END;

                    IF arp_customer_name_tab(i) IS NULL
                    THEN
                       BEGIN
                          SELECT pty.party_name
                          INTO   arp_customer_name_tab(i)
                          FROM   hz_parties pty,
                                 zx_party_tax_profile ptp
                          WHERE  ptp.party_tax_profile_id = bill_to_party_tax_id_tab(i)
                          AND    ptp.party_id = pty.party_id;
                       EXCEPTION WHEN OTHERS THEN
                          arp_customer_name_tab(i) := NULL;
                       END;
                    END IF;
                 END IF;
	      END IF;
   EXCEPTION WHEN OTHERS THEN
	arp_customer_name_tab(i):= NULL;
   END;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_CUSTOMER_NAME;

PROCEDURE DERIVE_DIVISION_CODE
IS

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_DIVISION_CODE';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   arp_division_code_tab(i)  := ARP_TAX_VIEW_TAXWARE.DIVISION_CODE
                                                              (l_view_name,
                                                              trx_id_tab(i),
                                                              trx_line_id_tab(i));
   if(arp_division_code_tab(i) is NULL) then
       arp_division_code_tab(i):='01';
   end if;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_DIVISION_CODE;

PROCEDURE DERIVE_TRANSACTION_DATE
IS

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_TRANSACTION_DATE';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   arp_transaction_date_tab(i) :=  ARP_TAX_VIEW_TAXWARE.TRANSACTION_DATE
                                                              (l_view_name,
                                                              trx_id_tab(i),
                                                              trx_line_id_tab(i));
   IF arp_transaction_date_tab(i) IS NULL THEN
      BEGIN
      		    SELECT trx_line_gl_date
		    INTO   arp_transaction_date_tab(i)
		    FROM   zx_lines_det_factors
		    WHERE  internal_organization_id = internal_org_id_tab(i)
		    AND    application_id           = application_id_tab(i)
		    AND	   Entity_Code              = entity_code_tab(i)
	            AND	   Event_Class_Code         = event_class_code_tab(i)
	            AND	   trx_id                   = trx_id_tab(i)
		    AND	   trx_line_id              = trx_line_id_tab(i);

		 EXCEPTION WHEN OTHERS THEN
		    arp_transaction_date_tab(i) := NULL;
      END;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

EXCEPTION WHEN OTHERS THEN
   arp_transaction_date_tab(i) :=  NULL;
END DERIVE_TRANSACTION_DATE;

PROCEDURE DERIVE_COMPANY_CODE
IS

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_COMPANY_CODE';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   arp_company_code_tab(i)  := ARP_TAX_VIEW_TAXWARE.COMPANY_CODE
                                   (l_view_name,
                                    trx_id_tab(i),
                                    trx_line_id_tab(i));
   IF (arp_company_code_tab(i) is NULL) THEN
      arp_company_code_tab(i) := '01';
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_COMPANY_CODE;

PROCEDURE DERIVE_VND_CTRL_EXMPT
IS

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_VND_CTRL_EXMPT';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   arp_vnd_ctrl_exmpt_tab(i):= ARP_TAX_VIEW_TAXWARE.VENDOR_CONTROL_EXEMPTIONS
                                                             (l_view_name,
                                                              trx_id_tab(i),
                                                              trx_line_id_tab(i),
							      trx_type_id_tab(i));
   if(arp_vnd_ctrl_exmpt_tab(i)) is NULL then
	      BEGIN

		  select attribute1
			into arp_vnd_ctrl_exmpt_tab(i)
			from ra_cust_trx_types
			where cust_trx_type_id = trx_type_id_tab(i)
			  and org_id = internal_org_id_tab(i);

	      EXCEPTION
		when no_data_found then
	        arp_vnd_ctrl_exmpt_tab(i):=NULL;

              END;
   End if;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_VND_CTRL_EXMPT;

PROCEDURE DERIVE_USE_NEXPRO
IS

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_USE_NEXPRO';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   arp_use_nexpro_tab(i)    := ARP_TAX_VIEW_TAXWARE.USE_NEXPRO
                                                              (l_view_name,
                                                              trx_id_tab(i),
                                                              trx_line_id_tab(i));
   if(arp_use_nexpro_tab(i) is NULL) then
      arp_use_nexpro_tab(i) := g_usenexpro;
   end if;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_USE_NEXPRO;

PROCEDURE DERIVE_SERVICE_IND
IS

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_SERVICE_IND';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   arp_service_ind_tab(i)    := ARP_TAX_VIEW_TAXWARE.SERVICE_INDICATOR
							       (l_view_name,
                                                              trx_id_tab(i),
                                                              trx_line_id_tab(i));
	   if(arp_service_ind_tab(i) is NULL) then
	      arp_service_ind_tab(i) := g_serviceind;
           end if;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_SERVICE_IND;

PROCEDURE DERIVE_TAX_SEL_PARAM
IS

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_TAX_SEL_PARAM';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   arp_tax_sel_param_tab(i)   := ARP_TAX_VIEW_TAXWARE.TAX_SEL_PARM
  							       (l_view_name,
                                                               trx_id_tab(i),
                                                               trx_line_id_tab(i));
           if(arp_tax_sel_param_tab(i) is NULL) then
	      arp_tax_sel_param_tab(i) := g_taxselparam;
           end if;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_TAX_SEL_PARAM;

PROCEDURE DERIVE_CALCULATION_FLAG
IS

   l_api_name                CONSTANT VARCHAR2(30) := 'DERIVE_CALCULATION_FLAG';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   calculation_flag_tab(i)    := ARP_TAX_VIEW_TAXWARE.Calculation_Flag
  							       (l_view_name,
                                                               trx_id_tab(i),
                                                               trx_line_id_tab(i));
	   if(calculation_flag_tab(i) is NULL) then
	      calculation_flag_tab(i) := '00000';
           end if;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

END DERIVE_CALCULATION_FLAG;


PROCEDURE ERROR_EXCEPTION_HANDLE(str  varchar2) is

cursor error_exception_cursor is
select	EVNT_CLS_MAPPING_ID,
	TRX_ID,
	TAX_REGIME_CODE
from ZX_TRX_PRE_PROC_OPTIONS_GT;

l_docment_type_id number;
l_trasaction_id   number;
l_tax_regime_code varchar2(80);

Begin
open error_exception_cursor;
fetch error_exception_cursor into l_docment_type_id,l_trasaction_id,l_tax_regime_code;

G_MESSAGES_TBL.DOCUMENT_TYPE_ID(err_count)		:= l_docment_type_id;
G_MESSAGES_TBL.TRANSACTION_ID(err_count)		:= l_trasaction_id;
G_MESSAGES_TBL.COUNTRY_CODE(err_count)			:= l_tax_regime_code;
G_MESSAGES_TBL.ERROR_MESSAGE_TYPE(err_count)		:= 'ERROR';
G_MESSAGES_TBL.ERROR_MESSAGE_STRING(err_count)		:= str;

err_count :=err_count+1;

close error_exception_cursor;

End ERROR_EXCEPTION_HANDLE;

PROCEDURE INITIALIZE IS
BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_TAXWARE.INITIALIZE',
                                        'ZX.PARTNER.ARP_TAX_VIEW_TAXWARE.INITIALIZE(+)');
  END IF;

     g_usenexpro := fnd_profile.value('ZX_TAXVDR_USENEXPRO');
     g_taxselparam := TO_NUMBER(fnd_profile.value('ZX_TAXVDR_TAXSELPARAM'));
--   g_taxtype := TO_NUMBER(fnd_profile.value('ZX_TAXVDR_TAXTYPE'));
     g_serviceind := TO_NUMBER(fnd_profile.value('ZX_TAXVDR_SERVICEIND'));
  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_TAXWARE.INITIALIZE',
                                        'ZX.PARTNER.ARP_TAX_VIEW_TAXWARE.INITIALIZE(-)');
  END IF;

END INITIALIZE;

Begin
initialize;

END ZX_TAXWARE_USER_PKG;

/
