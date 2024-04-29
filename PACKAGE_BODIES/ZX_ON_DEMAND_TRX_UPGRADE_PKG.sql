--------------------------------------------------------
--  DDL for Package Body ZX_ON_DEMAND_TRX_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_ON_DEMAND_TRX_UPGRADE_PKG" AS
/* $Header: zxmigtrxdemdpkgb.pls 120.34.12010000.6 2009/08/26 14:18:16 tsen ship $ */

g_current_runtime_level           NUMBER;
g_level_statement       CONSTANT  NUMBER := FND_LOG.LEVEL_STATEMENT;
g_level_procedure       CONSTANT  NUMBER := FND_LOG.LEVEL_PROCEDURE;
g_level_unexpected      CONSTANT  NUMBER := FND_LOG.LEVEL_UNEXPECTED;

CONC_SUCCESS   CONSTANT NUMBER := 0;
CONC_WARNING   CONSTANT NUMBER := 1;
CONC_FAIL      CONSTANT NUMBER := 2;

WORKER_FAIL     EXCEPTION;

PROCEDURE zx_ar_trx_mig(
		   x_errbuf         OUT NOCOPY VARCHAR2,
		   x_retcode        OUT NOCOPY VARCHAR2,
		   p_start_rowid    IN	ROWID,
		   p_end_rowid      IN	ROWID,
		   p_org_id         IN	NUMBER,
		   p_multi_org_flag IN	VARCHAR2,
		   p_inv_installed  IN  VARCHAR2,
                   p_worker_id      IN  NUMBER,
		   x_rows_processed OUT	NOCOPY NUMBER);

PROCEDURE zx_ap_trx_mig (
                   x_errbuf         OUT NOCOPY VARCHAR2,
                   x_retcode        OUT NOCOPY VARCHAR2,
                   p_start_rowid    IN	ROWID,
                   p_end_rowid      IN	ROWID,
                   p_org_id         IN	NUMBER,
                   p_multi_org_flag IN	VARCHAR2,
                   p_worker_id      IN  NUMBER,
                   x_rows_processed OUT	NOCOPY NUMBER);

PROCEDURE zx_po_trx_mig (
                   x_errbuf         OUT NOCOPY VARCHAR2,
                   x_retcode        OUT NOCOPY VARCHAR2,
                   p_start_rowid    IN	ROWID,
                   p_end_rowid      IN	ROWID,
                   p_org_id         IN	NUMBER,
                   p_multi_org_flag IN	VARCHAR2,
                   p_worker_id      IN  NUMBER,
                   x_rows_processed OUT	NOCOPY NUMBER);


 /**************************************************************/
   -- Main Procedure

PROCEDURE ZX_TRX_UPDATE_MGR(
               X_errbuf     			 out NOCOPY varchar2,
               X_retcode    			 out NOCOPY varchar2,
               X_batch_size  		in number,
               X_Num_Workers 		in number,
               p_application_id in fnd_application.application_id%type,
               p_ledger_id      in xla_upgrade_dates.ledger_id%type,
               p_period_name    in varchar2)
IS
  l_update_name  varchar2(30);

  -- bug fix 5483850 begin
  req_status     number;
  req_data       varchar2(10);
  strt_wrkr      number;
  submit_req     boolean;
  L_SUB_REQTAB   fnd_concurrent.requests_tab_type;

  TYPE WorkerList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_worker                    WorkerList;

  l_result                    BOOLEAN;
  l_phase                     VARCHAR2(500);
  l_req_status                VARCHAR2(500);
  l_dev_phase                  VARCHAR2(500);
  l_dev_status                 VARCHAR2(500);
  l_message                   VARCHAR2(500);
  l_worker_not_complete         BOOLEAN;
  l_worker_success             VARCHAR2(1);
  l_res         BOOLEAN;
  -- bug fix 5483850 end

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  --
  -- Manager processing
  --

  IF g_level_procedure >= g_current_runtime_level THEN
    FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_MGR','ZX_TRX_UPDATE_MGR(+)');
    FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_MGR',' p_application_id: '||p_application_id);
  END IF;

  X_retcode := CONC_SUCCESS;

  IF p_application_id = 222 then
         l_update_name :='zxar_'||to_char(p_ledger_id)||p_period_name;
  ELSIF p_application_id = 200 then
         l_update_name :='zxap_'||to_char(p_ledger_id)||p_period_name;
  ELSIF p_application_id = 201 then
         l_update_name :='zxpo_'||to_char(p_ledger_id)||p_period_name;
  END IF;


  /* -- rewrote for bug fix 5483850

        AD_CONC_UTILS_PKG.submit_subrequests(
               X_errbuf=>X_errbuf,
               X_retcode=>X_retcode,
               X_WORKERCONC_APP_SHORTNAME=>'ZX',
               X_WORKERCONC_PROGNAME=>'ZXONDEMANDWKR',
               X_batch_size=>X_batch_size,
               X_Num_Workers=>X_Num_Workers,
               X_ARGUMENT4=>p_application_id,
	       X_argument5=>l_update_name);

        IF g_level_statement >= g_current_runtime_level THEN
                 FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_MGR','ZX_TRX_UPDATE_MGR(-)');
        END IF;
  */

  -- rewrote the process to submit worker request for bug fix 5483850
  -- When the program is run in on demand upgrade mode it is submitted from
  -- the concurrent program and hence we need to spawn multiple child
  -- workers

  FOR i in 1..X_Num_Workers
  LOOP

    IF g_level_statement >= g_current_runtime_level THEN
       FND_LOG.STRING(g_level_statement,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_MGR',
                      'Submitting concurrent request for worker '||i);
    END IF;

    l_worker(i) := fnd_request.submit_request(
                  APPLICATION=>'ZX',
                  PROGRAM=>'ZXONDEMANDWKR',
                  DESCRIPTION=> 'WRKR('||lpad(i, 2, '0')||')',
                  SUB_REQUEST=>FALSE,
                  --SUB_REQUEST=>TRUE, -- submit as child request of XLA
                  ARGUMENT1=>X_batch_size,
                  ARGUMENT2=>i,
                  ARGUMENT3=>X_Num_Workers,
                  ARGUMENT4=>p_application_id,
                  ARGUMENT5=>l_update_name );

    IF l_worker(i) = 0 THEN
      IF g_level_statement >= g_current_runtime_level THEN
         FND_LOG.STRING(g_level_statement,
           'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_MGR',
           'Error submitting request #'||i);
         FND_LOG.STRING(g_level_statement,
           'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_MGR',
           fnd_message.get);
      END IF;
      COMMIT;
    ELSE
      IF g_level_statement >= g_current_runtime_level THEN
         FND_LOG.STRING(g_level_statement,
           'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_MGR',
           'Submitted request #'||i);
         FND_LOG.STRING(g_level_statement,
           'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_MGR',
           'Request ID: ' ||l_worker(i));
      END IF;
      COMMIT;
    END IF;

  END LOOP;

  COMMIT;


  l_worker_not_complete   := TRUE;
  WHILE l_worker_not_complete LOOP
    --dbms_lock.sleep(10);
    IF g_level_statement >= g_current_runtime_level THEN
       FND_LOG.STRING(g_level_statement,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_MGR',
                      'Inside Loop for checking the child request status');
    END IF;

    l_worker_not_complete := FALSE;
    FOR i in 1..X_Num_Workers LOOP
        l_res := FND_CONCURRENT.GET_REQUEST_STATUS
                                (l_worker(i),
                                 NULL,
                                 NULL,
                                 l_phase,
                                 l_req_status,
                                 l_dev_phase,
                                 l_dev_status,
                                 l_message);

        IF g_level_statement >= g_current_runtime_level THEN
           FND_LOG.STRING(g_level_statement,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_MGR',
                        'l_dev_phase: '||l_dev_phase);
        END IF;

      IF l_dev_phase = 'COMPLETE'  Then
        --NULL;
        IF l_dev_status NOT IN ('NORMAL', 'WARNING') THEN
          l_worker_success := 'N';
        END IF;
      ELSE
        IF g_level_statement >= g_current_runtime_level THEN
           FND_LOG.STRING(g_level_statement,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_MGR',
                        'Loop once again');
        END IF;
        l_worker_not_complete := TRUE;
      END IF;

      --IF l_dev_status IN ('ERROR', 'TERMINATED', 'TERMINATING') THEN
      --   l_worker_success := 'N';
      --END IF;
    END LOOP;
  END LOOP;

  /* If any subworkers have failed then raise an error */
  IF l_worker_success = 'N' THEN
     RAISE WORKER_FAIL;
  END IF;

  COMMIT;

  IF g_level_procedure >= g_current_runtime_level THEN
           FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_MGR','ZX_TRX_UPDATE_MGR(-)');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    X_retcode := CONC_FAIL;
    IF g_level_unexpected >= g_current_runtime_level THEN
      FND_LOG.STRING(g_level_unexpected,
        'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_MGR',
         sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80) );
    END IF;
    raise;

END ZX_TRX_UPDATE_MGR;

-- Sub Worker

   PROCEDURE ZX_TRX_UPDATE_WKR(
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Worker_Id   in number,
                  X_Num_Workers in number,
                  p_application_id in fnd_application.application_id%type,
		  p_script_name in varchar2)
   IS

      l_worker_id  number;
      l_product     varchar2(30) ;
      l_table_name  varchar2(30) := 'dual';
      l_status      varchar2(30);
      l_industry    varchar2(30);
      l_retstatus   boolean;
      l_table_owner          varchar2(30);
      l_any_rows_to_process  boolean;

      l_start_rowid     rowid;
      l_end_rowid       rowid;
      l_rows_processed  number;  -- for IN parameter
      x_rows_processed  number;  -- for OUT parameter

      l_multi_org_flag            VARCHAR2(1);
      l_org_id                    NUMBER;
      l_inv_installed             VARCHAR2(1);
      l_inv_flag                  VARCHAR2(1);
      l_fnd_return                BOOLEAN;
      l_temp                      BOOLEAN;

   BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

     --
     -- get schema name of the table for ROWID range processing
     --
        IF g_level_procedure >= g_current_runtime_level then
                 FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_WKR','ZX_TRX_UPDATE_WKR(+)');
        END IF;

    X_retcode := CONC_SUCCESS;

        SELECT NVL(multi_org_flag, 'N')
          INTO l_multi_org_flag
          FROM fnd_product_groups;

        -- for single org environment, get value of org_id from profile
        IF l_multi_org_flag = 'N' THEN
          fnd_profile.get('ORG_ID',l_org_id);
          IF l_org_id is NULL THEN
            l_org_id := -99;
          END IF;
        END IF;


	IF g_level_statement >= g_current_runtime_level THEN
                FND_LOG.STRING(g_level_statement,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_WKR','Worker: '||X_Worker_Id||' l_multi_org_flag is ' || l_multi_org_flag);
		FND_LOG.STRING(g_level_statement,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_WKR','Worker: '||X_Worker_Id||' l_org_id is ' || l_org_id );

        END IF;

        l_fnd_return := FND_INSTALLATION.GET(401,401, l_inv_flag, l_industry);

        IF (l_inv_flag = 'I') THEN
            l_inv_installed := 'Y';
        ELSE
            l_inv_installed := 'N';
        END IF;

        SELECT application_short_name
          INTO l_product
          FROM fnd_application
         WHERE application_id = p_application_id;

     l_retstatus := fnd_installation.get_app_info(
                        l_product, l_status, l_industry, l_table_owner);

     IF ((l_retstatus = FALSE)
         OR
         (l_table_owner is null))
     THEN
        RAISE_APPLICATION_ERROR(-20001,
           'Cannot get schema name for product : '||l_product);
     END IF;


     IF g_level_statement >= g_current_runtime_level then
        FND_LOG.STRING(g_level_statement,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_WKR','Worker: '||X_Worker_Id||' X_Worker_Id is ' ||  X_Worker_Id);
        FND_LOG.STRING(g_level_statement,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_WKR','Worker: '||X_Worker_Id||' X_Num_Workers is ' || X_Num_Workers );
     END IF;

     BEGIN

	IF p_application_id = 222 then
		l_table_name :='RA_CUSTOMER_TRX_ALL';
	ELSIF p_application_id = 200 then
		l_table_name :='AP_INVOICES_ALL';
	ELSIF p_application_id = 201 then
		l_table_name :='PO_HEADERS_ALL';
	END IF;

           ad_parallel_updates_pkg.initialize_rowid_range(
                    ad_parallel_updates_pkg.ROWID_RANGE,
                    l_table_owner,
                    l_table_name,
                    p_script_name,
                    X_worker_id,
                    X_num_workers,
                    X_batch_size, 0);

           ad_parallel_updates_pkg.get_rowid_range(
                    l_start_rowid,
                    l_end_rowid,
                    l_any_rows_to_process,
                    X_batch_size,
                    TRUE);

           WHILE (l_any_rows_to_process = TRUE)
           LOOP

              IF p_application_id = 222 THEN

                zx_ar_trx_mig(
                           x_errbuf,
                           x_retcode,
                           l_start_rowid,
                           l_end_rowid,
                           l_org_id,
                           l_multi_org_flag,
                           l_inv_installed,
                           X_Worker_Id,
                           x_rows_processed);

              ELSIF p_application_id = 200 THEN

                zx_ap_trx_mig(
                           x_errbuf,
                           x_retcode,
                           l_start_rowid,
                           l_end_rowid,
                           l_org_id,
                           l_multi_org_flag,
                           X_Worker_Id,
                           x_rows_processed);

             ELSIF p_application_id = 201 THEN

                zx_po_trx_mig(
                           x_errbuf,
                           x_retcode,
                           l_start_rowid,
                           l_end_rowid,
                           l_org_id,
                           l_multi_org_flag,
                           X_Worker_Id,
                           x_rows_processed);
              END IF;


              l_rows_processed := x_rows_processed ;

              ad_parallel_updates_pkg.processed_rowid_range(
                  l_rows_processed,
                  l_end_rowid);

              COMMIT;

              ad_parallel_updates_pkg.get_rowid_range(
                 l_start_rowid,
                 l_end_rowid,
                 l_any_rows_to_process,
                 X_batch_size,
                 FALSE);

           END LOOP;

/*           X_retcode := CONC_SUCCESS;
           l_temp := fnd_concurrent.set_completion_status
  	             (status    => 'NORMAL'
  	             ,message   => NULL);
*/
     EXCEPTION
          WHEN OTHERS THEN
            X_retcode := CONC_FAIL;
            raise;
     END;

     IF g_level_procedure >= g_current_runtime_level then
       FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_WKR','ZX_TRX_UPDATE_WKR(-)');
     END IF;

EXCEPTION
  WHEN OTHERS THEN
    X_retcode := CONC_FAIL;
    IF g_level_unexpected >= g_current_runtime_level THEN
      FND_LOG.STRING(g_level_unexpected,
        'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_TRX_UPDATE_WKR',
         sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80) );
    END IF;
    raise;

   END ZX_TRX_UPDATE_WKR;

/**************************************************************/

  PROCEDURE zx_ar_trx_mig (x_errbuf         OUT NOCOPY VARCHAR2,
                           x_retcode        OUT NOCOPY VARCHAR2,
                           p_start_rowid    IN	ROWID,
                           p_end_rowid      IN	ROWID,
                           p_org_id         IN	NUMBER,
                           p_multi_org_flag IN	VARCHAR2,
                           p_inv_installed  IN VARCHAR2,
                           p_worker_id      IN NUMBER,
                           x_rows_processed OUT	NOCOPY NUMBER)

  IS
	  l_multi_org_flag            VARCHAR2(1);
	  l_org_id                    NUMBER;
	  l_inv_installed             VARCHAR2(1);
  BEGIN
	  l_multi_org_flag            := p_multi_org_flag;
	  l_org_id                    := p_org_id;
	  l_inv_installed             := p_inv_installed;


 	IF g_level_procedure >= g_current_runtime_level then
                FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AR_TRX_MIG','Worker: '||p_worker_id||' zx_ar_trx_mig (+)' );
                FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AR_TRX_MIG','Worker: '||p_worker_id||' p_start_rowid is ' || p_start_rowid );
  		FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AR_TRX_MIG','Worker: '||p_worker_id||' p_end_rowid is ' || p_end_rowid );
  		FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AR_TRX_MIG','Worker: '||p_worker_id||' p_org_id is ' || p_org_id );
  		FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AR_TRX_MIG','Worker: '||p_worker_id||' p_multi_org_flag is  ' || p_multi_org_flag );
  		FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AR_TRX_MIG','Worker: '||p_worker_id||' p_inv_installed is ' || p_inv_installed );
        END IF;

  x_retcode := CONC_SUCCESS;

    /* Insert All Taxable Lines into ZX_LINES_DET_FACTORS. Incase there are No taxable lines,
     (link_to_cust_trx_line_id is null, hence insert dummy lines in ZX_LINES_DET_FACTORS with
     trx_line_id = -9999) */

    INSERT ALL
      WHEN trx_line_type IN ('LINE' ,'CB') THEN
    INTO ZX_LINES_DET_FACTORS(
            INTERNAL_ORGANIZATION_ID
           ,APPLICATION_ID
           ,ENTITY_CODE
           ,EVENT_CLASS_CODE
           ,EVENT_CLASS_MAPPING_ID
           ,EVENT_TYPE_CODE
           ,DOC_EVENT_STATUS
           ,LINE_LEVEL_ACTION
           ,TRX_ID
           ,TRX_LINE_ID
           ,TRX_LEVEL_TYPE
           ,TRX_DATE
           --,TRX_DOC_REVISION
           ,LEDGER_ID
           ,TRX_CURRENCY_CODE
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_RATE
           ,CURRENCY_CONVERSION_TYPE
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,PRECISION
           ,LEGAL_ENTITY_ID
           --,ESTABLISHMENT_ID
           ,RECEIVABLES_TRX_TYPE_ID
           ,DEFAULT_TAXATION_COUNTRY
           ,TRX_NUMBER
           ,TRX_LINE_NUMBER
           ,TRX_LINE_DESCRIPTION
           --,TRX_DESCRIPTION
           --,TRX_COMMUNICATED_DATE
           ,BATCH_SOURCE_ID
           ,BATCH_SOURCE_NAME
           ,DOC_SEQ_ID
           ,DOC_SEQ_NAME
           ,DOC_SEQ_VALUE
           ,TRX_DUE_DATE
           ,TRX_TYPE_DESCRIPTION
           ,DOCUMENT_SUB_TYPE
           --,SUPPLIER_TAX_INVOICE_NUMBER
           --,SUPPLIER_TAX_INVOICE_DATE
           --,SUPPLIER_EXCHANGE_RATE
           ,TAX_INVOICE_DATE
           ,TAX_INVOICE_NUMBER
           ,FIRST_PTY_ORG_ID
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           --,LINE_INTENDED_USE
           ,TRX_LINE_TYPE
           --,TRX_SHIPPING_DATE
           --,TRX_RECEIPT_DATE
           --,TRX_SIC_CODE
           ,FOB_POINT
           ,TRX_WAYBILL_NUMBER
           ,PRODUCT_ID
           ,PRODUCT_FISC_CLASSIFICATION
           ,PRODUCT_ORG_ID
           ,UOM_CODE
           --,PRODUCT_TYPE
           --,PRODUCT_CODE
           ,PRODUCT_CATEGORY
           ,PRODUCT_DESCRIPTION
           ,USER_DEFINED_FISC_CLASS
           ,LINE_AMT
           ,TRX_LINE_QUANTITY
           --,CASH_DISCOUNT
           --,VOLUME_DISCOUNT
           --,TRADING_DISCOUNT
           --,TRANSFER_CHARGE
           --,TRANSPORTATION_CHARGE
           --,INSURANCE_CHARGE
           --,OTHER_CHARGE
           --,ASSESSABLE_VALUE
           --,ASSET_FLAG
           --,ASSET_NUMBER
           ,ASSET_ACCUM_DEPRECIATION
           --,ASSET_TYPE
           ,ASSET_COST
           ,RELATED_DOC_APPLICATION_ID
           --,RELATED_DOC_ENTITY_CODE
           --,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_TRX_ID
           --,RELATED_DOC_NUMBER
           --,RELATED_DOC_DATE
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_ENTITY_CODE
           ,ADJUSTED_DOC_EVENT_CLASS_CODE
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           --,REF_DOC_APPLICATION_ID
           --,REF_DOC_ENTITY_CODE
           --,REF_DOC_EVENT_CLASS_CODE
           --,REF_DOC_TRX_ID
           --,REF_DOC_LINE_ID
           --,REF_DOC_LINE_QUANTITY
           --,REF_DOC_TRX_LEVEL_TYPE
           ,TRX_BUSINESS_CATEGORY
           ,EXEMPT_CERTIFICATE_NUMBER
           --,EXEMPT_REASON
           ,EXEMPTION_CONTROL_FLAG
           ,EXEMPT_REASON_CODE
           ,HISTORICAL_FLAG
           ,TRX_LINE_GL_DATE
           ,LINE_AMT_INCLUDES_TAX_FLAG
           --,ACCOUNT_CCID
           --,ACCOUNT_STRING
           --,SHIP_TO_LOCATION_ID
           --,SHIP_FROM_LOCATION_ID
           --,POA_LOCATION_ID
           --,POO_LOCATION_ID
           --,BILL_TO_LOCATION_ID
           --,BILL_FROM_LOCATION_ID
           --,PAYING_LOCATION_ID
           --,OWN_HQ_LOCATION_ID
           --,TRADING_HQ_LOCATION_ID
           --,POC_LOCATION_ID
           --,POI_LOCATION_ID
           --,POD_LOCATION_ID
           --,TITLE_TRANSFER_LOCATION_ID
           ,CTRL_HDR_TX_APPL_FLAG
           --,CTRL_TOTAL_LINE_TX_AMT
           --,CTRL_TOTAL_HDR_TX_AMT
           ,LINE_CLASS
           ,TRX_LINE_DATE
           --,INPUT_TAX_CLASSIFICATION_CODE
           ,OUTPUT_TAX_CLASSIFICATION_CODE
           --,INTERNAL_ORG_LOCATION_ID
           --,PORT_OF_ENTRY_CODE
           ,TAX_REPORTING_FLAG
           ,TAX_AMT_INCLUDED_FLAG
           ,COMPOUNDING_TAX_FLAG
           --,EVENT_ID
           ,THRESHOLD_INDICATOR_FLAG
           --,PROVNL_TAX_DETERMINATION_DATE
           ,UNIT_PRICE
           ,SHIP_TO_CUST_ACCT_SITE_USE_ID
           ,BILL_TO_CUST_ACCT_SITE_USE_ID
           ,TRX_BATCH_ID
           --,START_EXPENSE_DATE
           --,SOURCE_APPLICATION_ID
           --,SOURCE_ENTITY_CODE
           --,SOURCE_EVENT_CLASS_CODE
           --,SOURCE_TRX_ID
           --,SOURCE_LINE_ID
           --,SOURCE_TRX_LEVEL_TYPE
           ,RECORD_TYPE_CODE
           ,INCLUSIVE_TAX_OVERRIDE_FLAG
           ,TAX_PROCESSING_COMPLETED_FLAG
           ,OBJECT_VERSION_NUMBER
           ,APPLICATION_DOC_STATUS
           ,USER_UPD_DET_FACTORS_FLAG
           --,SOURCE_TAX_LINE_ID
           --,REVERSED_APPLN_ID
           --,REVERSED_ENTITY_CODE
           --,REVERSED_EVNT_CLS_CODE
           --,REVERSED_TRX_ID
           --,REVERSED_TRX_LEVEL_TYPE
           --,REVERSED_TRX_LINE_ID
           --,TAX_CALCULATION_DONE_FLAG
           ,PARTNER_MIGRATED_FLAG
           ,SHIP_THIRD_PTY_ACCT_SITE_ID
           ,BILL_THIRD_PTY_ACCT_SITE_ID
           ,SHIP_THIRD_PTY_ACCT_ID
           ,BILL_THIRD_PTY_ACCT_ID
           --,INTERFACE_ENTITY_CODE
           --,INTERFACE_LINE_ID
           --,HISTORICAL_TAX_CODE_ID
           --,ICX_SESSION_ID
           --,TRX_LINE_CURRENCY_CODE
           --,TRX_LINE_CURRENCY_CONV_RATE
           --,TRX_LINE_CURRENCY_CONV_DATE
           --,TRX_LINE_PRECISION
           --,TRX_LINE_MAU
           --,TRX_LINE_CURRENCY_CONV_TYPE
           ,CREATION_DATE
           ,CREATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
         )
         VALUES (
            INTERNAL_ORGANIZATION_ID
           ,APPLICATION_ID
           ,ENTITY_CODE
           ,EVENT_CLASS_CODE
           ,EVENT_CLASS_MAPPING_ID
           ,EVENT_TYPE_CODE
           ,DOC_EVENT_STATUS
           ,LINE_LEVEL_ACTION
           ,TRX_ID
           ,TRX_LINE_ID
           ,TRX_LEVEL_TYPE
           ,TRX_DATE
           --,TRX_DOC_REVISION
           ,LEDGER_ID
           ,TRX_CURRENCY_CODE
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_RATE
           ,CURRENCY_CONVERSION_TYPE
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,PRECISION
           ,LEGAL_ENTITY_ID
           --,ESTABLISHMENT_ID
           ,RECEIVABLES_TRX_TYPE_ID
           ,DEFAULT_TAXATION_COUNTRY
           ,TRX_NUMBER
           ,TRX_LINE_NUMBER
           ,TRX_LINE_DESCRIPTION
           --,TRX_DESCRIPTION
           --,TRX_COMMUNICATED_DATE
           ,BATCH_SOURCE_ID
           ,BATCH_SOURCE_NAME
           ,DOC_SEQ_ID
           ,DOC_SEQ_NAME
           ,DOC_SEQ_VALUE
           ,TRX_DUE_DATE
           ,TRX_TYPE_DESCRIPTION
           ,DOCUMENT_SUB_TYPE
           --,SUPPLIER_TAX_INVOICE_NUMBER
           --,SUPPLIER_TAX_INVOICE_DATE
           --,SUPPLIER_EXCHANGE_RATE
           ,TAX_INVOICE_DATE
           ,TAX_INVOICE_NUMBER
           ,FIRST_PTY_ORG_ID
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           --,LINE_INTENDED_USE
           ,TRX_LINE_TYPE
           --,TRX_SHIPPING_DATE
           --,TRX_RECEIPT_DATE
           --,TRX_SIC_CODE
           ,FOB_POINT
           ,TRX_WAYBILL_NUMBER
           ,PRODUCT_ID
           ,PRODUCT_FISC_CLASSIFICATION
           ,PRODUCT_ORG_ID
           ,UOM_CODE
           --,PRODUCT_TYPE
           --,PRODUCT_CODE
           ,PRODUCT_CATEGORY
           ,PRODUCT_DESCRIPTION
           ,USER_DEFINED_FISC_CLASS
           ,LINE_AMT
           ,TRX_LINE_QUANTITY
           --,CASH_DISCOUNT
           --,VOLUME_DISCOUNT
           --,TRADING_DISCOUNT
           --,TRANSFER_CHARGE
           --,TRANSPORTATION_CHARGE
           --,INSURANCE_CHARGE
           --,OTHER_CHARGE
           --,ASSESSABLE_VALUE
           --,ASSET_FLAG
           --,ASSET_NUMBER
           ,ASSET_ACCUM_DEPRECIATION
           --,ASSET_TYPE
           ,ASSET_COST
           ,RELATED_DOC_APPLICATION_ID
           --,RELATED_DOC_ENTITY_CODE
           --,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_TRX_ID
           --,RELATED_DOC_NUMBER
           --,RELATED_DOC_DATE
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_ENTITY_CODE
           ,ADJUSTED_DOC_EVENT_CLASS_CODE
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           --,REF_DOC_APPLICATION_ID
           --,REF_DOC_ENTITY_CODE
           --,REF_DOC_EVENT_CLASS_CODE
           --,REF_DOC_TRX_ID
           --,REF_DOC_LINE_ID
           --,REF_DOC_LINE_QUANTITY
           --,REF_DOC_TRX_LEVEL_TYPE
           ,TRX_BUSINESS_CATEGORY
           ,EXEMPT_CERTIFICATE_NUMBER
           --,EXEMPT_REASON
           ,EXEMPTION_CONTROL_FLAG
           ,EXEMPT_REASON_CODE
           ,'Y'    --HISTORICAL_FLAG
           ,TRX_LINE_GL_DATE
           ,'N'    --LINE_AMT_INCLUDES_TAX_FLAG
           --,ACCOUNT_CCID
           --,ACCOUNT_STRING
           --,SHIP_TO_LOCATION_ID
           --,SHIP_FROM_LOCATION_ID
           --,POA_LOCATION_ID
           --,POO_LOCATION_ID
           --,BILL_TO_LOCATION_ID
           --,BILL_FROM_LOCATION_ID
           --,PAYING_LOCATION_ID
           --,OWN_HQ_LOCATION_ID
           --,TRADING_HQ_LOCATION_ID
           --,POC_LOCATION_ID
           --,POI_LOCATION_ID
           --,POD_LOCATION_ID
           --,TITLE_TRANSFER_LOCATION_ID
           ,'N'   --CTRL_HDR_TX_APPL_FLAG
           --,CTRL_TOTAL_LINE_TX_AMT
           --,CTRL_TOTAL_HDR_TX_AMT
           ,LINE_CLASS
           ,TRX_LINE_DATE
           --,INPUT_TAX_CLASSIFICATION_CODE
           ,OUTPUT_TAX_CLASSIFICATION_CODE
           --,INTERNAL_ORG_LOCATION_ID
           --,PORT_OF_ENTRY_CODE
           ,'Y'   --TAX_REPORTING_FLAG
           ,'N'   --TAX_AMT_INCLUDED_FLAG
           ,'N'   --COMPOUNDING_TAX_FLAG
           --,EVENT_ID
           ,'N'   --THRESHOLD_INDICATOR_FLAG
           --,PROVNL_TAX_DETERMINATION_DATE
           ,UNIT_PRICE
           ,SHIP_TO_CUST_ACCT_SITE_USE_ID
           ,BILL_TO_CUST_ACCT_SITE_USE_ID
           ,TRX_BATCH_ID
           --,START_EXPENSE_DATE
           --,SOURCE_APPLICATION_ID
           --,SOURCE_ENTITY_CODE
           --,SOURCE_EVENT_CLASS_CODE
           --,SOURCE_TRX_ID
           --,SOURCE_LINE_ID
           --,SOURCE_TRX_LEVEL_TYPE
           ,'MIGRATED'     --RECORD_TYPE_CODE
           ,'N'     --INCLUSIVE_TAX_OVERRIDE_FLAG
           ,'N'     --TAX_PROCESSING_COMPLETED_FLAG
           ,OBJECT_VERSION_NUMBER
           ,APPLICATION_DOC_STATUS
           ,'N'     --USER_UPD_DET_FACTORS_FLAG
           --,SOURCE_TAX_LINE_ID
           --,REVERSED_APPLN_ID
           --,REVERSED_ENTITY_CODE
           --,REVERSED_EVNT_CLS_CODE
           --,REVERSED_TRX_ID
           --,REVERSED_TRX_LEVEL_TYPE
           --,REVERSED_TRX_LINE_ID
           --,TAX_CALCULATION_DONE_FLAG
           ,PARTNER_MIGRATED_FLAG
           ,SHIP_THIRD_PTY_ACCT_SITE_ID
           ,BILL_THIRD_PTY_ACCT_SITE_ID
           ,SHIP_THIRD_PTY_ACCT_ID
           ,BILL_THIRD_PTY_ACCT_ID
           --,INTERFACE_ENTITY_CODE
           --,INTERFACE_LINE_ID
           --,HISTORICAL_TAX_CODE_ID
           --,ICX_SESSION_ID
           --,TRX_LINE_CURRENCY_CODE
           --,TRX_LINE_CURRENCY_CONV_RATE
           --,TRX_LINE_CURRENCY_CONV_DATE
           --,TRX_LINE_PRECISION
           --,TRX_LINE_MAU
           --,TRX_LINE_CURRENCY_CONV_TYPE
           ,CREATION_DATE
           ,CREATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
         )
      WHEN (trx_line_type = 'TAX') THEN
    INTO ZX_LINES (
            TAX_LINE_ID
           ,INTERNAL_ORGANIZATION_ID
           ,APPLICATION_ID
           ,ENTITY_CODE
           ,EVENT_CLASS_CODE
           ,EVENT_TYPE_CODE
           ,TRX_ID
           ,TRX_LINE_ID
           ,TRX_LEVEL_TYPE
           ,TRX_LINE_NUMBER
           ,DOC_EVENT_STATUS
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           ,TAX_LINE_NUMBER
           ,CONTENT_OWNER_ID
           ,TAX_REGIME_ID
           ,TAX_REGIME_CODE
           ,TAX_ID
           ,TAX
           ,TAX_STATUS_ID
           ,TAX_STATUS_CODE
           ,TAX_RATE_ID
           ,TAX_RATE_CODE
           ,TAX_RATE
           ,TAX_RATE_TYPE
           ,TAX_APPORTIONMENT_LINE_NUMBER
           ,MRC_TAX_LINE_FLAG
           ,LEDGER_ID
           --,ESTABLISHMENT_ID
           ,LEGAL_ENTITY_ID
           --,LEGAL_ENTITY_TAX_REG_NUMBER
           --,HQ_ESTB_REG_NUMBER
           --,HQ_ESTB_PARTY_TAX_PROF_ID
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_TYPE
           ,CURRENCY_CONVERSION_RATE
           --,TAX_CURRENCY_CONVERSION_DATE
           --,TAX_CURRENCY_CONVERSION_TYPE
           --,TAX_CURRENCY_CONVERSION_RATE
           ,TRX_CURRENCY_CODE
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,PRECISION
           ,TRX_NUMBER
           ,TRX_DATE
           ,UNIT_PRICE
           ,LINE_AMT
           ,TRX_LINE_QUANTITY
           ,TAX_BASE_MODIFIER_RATE
           --,REF_DOC_APPLICATION_ID
           --,REF_DOC_ENTITY_CODE
           --,REF_DOC_EVENT_CLASS_CODE
           --,REF_DOC_TRX_ID
           --,REF_DOC_LINE_ID
           --,REF_DOC_LINE_QUANTITY
           --,REF_DOC_TRX_LEVEL_TYPE
           --,OTHER_DOC_LINE_AMT
           --,OTHER_DOC_LINE_TAX_AMT
           --,OTHER_DOC_LINE_TAXABLE_AMT
           ,UNROUNDED_TAXABLE_AMT
           ,UNROUNDED_TAX_AMT
           ,RELATED_DOC_APPLICATION_ID
           --,RELATED_DOC_ENTITY_CODE
           --,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_TRX_ID
           --,RELATED_DOC_NUMBER
           --,RELATED_DOC_DATE
           --,RELATED_DOC_TRX_LEVEL_TYPE
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_ENTITY_CODE
           ,ADJUSTED_DOC_EVENT_CLASS_CODE
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           --,SUMMARY_TAX_LINE_ID
           --,OFFSET_LINK_TO_TAX_LINE_ID
           ,OFFSET_FLAG
           ,PROCESS_FOR_RECOVERY_FLAG
           --,TAX_JURISDICTION_ID
           --,TAX_JURISDICTION_CODE
           --,PLACE_OF_SUPPLY
           ,PLACE_OF_SUPPLY_TYPE_CODE
           --,PLACE_OF_SUPPLY_RESULT_ID
           --,TAX_DATE_RULE_ID
           ,TAX_DATE
           ,TAX_DETERMINE_DATE
           ,TAX_POINT_DATE
           ,TRX_LINE_DATE
           ,TAX_TYPE_CODE
           --,TAX_CODE
           --,TAX_REGISTRATION_ID
           --,TAX_REGISTRATION_NUMBER
           --,REGISTRATION_PARTY_TYPE
           ,ROUNDING_LEVEL_CODE
           ,ROUNDING_RULE_CODE
           --,ROUNDING_LVL_PARTY_TAX_PROF_ID
           --,ROUNDING_LVL_PARTY_TYPE
           ,COMPOUNDING_TAX_FLAG
           --,ORIG_TAX_STATUS_ID
           --,ORIG_TAX_STATUS_CODE
           --,ORIG_TAX_RATE_ID
           --,ORIG_TAX_RATE_CODE
           --,ORIG_TAX_RATE
           --,ORIG_TAX_JURISDICTION_ID
           --,ORIG_TAX_JURISDICTION_CODE
           --,ORIG_TAX_AMT_INCLUDED_FLAG
           --,ORIG_SELF_ASSESSED_FLAG
           ,TAX_CURRENCY_CODE
           ,TAX_AMT
           ,TAX_AMT_TAX_CURR
           ,TAX_AMT_FUNCL_CURR
           ,TAXABLE_AMT
           ,TAXABLE_AMT_TAX_CURR
           ,TAXABLE_AMT_FUNCL_CURR
           --,ORIG_TAXABLE_AMT
           --,ORIG_TAXABLE_AMT_TAX_CURR
           ,CAL_TAX_AMT
           ,CAL_TAX_AMT_TAX_CURR
           ,CAL_TAX_AMT_FUNCL_CURR
           --,ORIG_TAX_AMT
           --,ORIG_TAX_AMT_TAX_CURR
           --,REC_TAX_AMT
           --,REC_TAX_AMT_TAX_CURR
           --,REC_TAX_AMT_FUNCL_CURR
           --,NREC_TAX_AMT
           --,NREC_TAX_AMT_TAX_CURR
           --,NREC_TAX_AMT_FUNCL_CURR
           ,TAX_EXEMPTION_ID
           --,TAX_RATE_BEFORE_EXEMPTION
           --,TAX_RATE_NAME_BEFORE_EXEMPTION
           --,EXEMPT_RATE_MODIFIER
           ,EXEMPT_CERTIFICATE_NUMBER
           --,EXEMPT_REASON
           ,EXEMPT_REASON_CODE
           ,TAX_EXCEPTION_ID
           ,TAX_RATE_BEFORE_EXCEPTION
           --,TAX_RATE_NAME_BEFORE_EXCEPTION
           --,EXCEPTION_RATE
           ,TAX_APPORTIONMENT_FLAG
           ,HISTORICAL_FLAG
           ,TAXABLE_BASIS_FORMULA
           ,TAX_CALCULATION_FORMULA
           ,CANCEL_FLAG
           ,PURGE_FLAG
           ,DELETE_FLAG
           ,TAX_AMT_INCLUDED_FLAG
           ,SELF_ASSESSED_FLAG
           ,OVERRIDDEN_FLAG
           ,MANUALLY_ENTERED_FLAG
           ,REPORTING_ONLY_FLAG
           ,FREEZE_UNTIL_OVERRIDDEN_FLAG
           ,COPIED_FROM_OTHER_DOC_FLAG
           ,RECALC_REQUIRED_FLAG
           ,SETTLEMENT_FLAG
           ,ITEM_DIST_CHANGED_FLAG
           ,ASSOCIATED_CHILD_FROZEN_FLAG
           ,TAX_ONLY_LINE_FLAG
           ,COMPOUNDING_DEP_TAX_FLAG
           ,ENFORCE_FROM_NATURAL_ACCT_FLAG
           ,COMPOUNDING_TAX_MISS_FLAG
           ,SYNC_WITH_PRVDR_FLAG
           --,LAST_MANUAL_ENTRY
           ,TAX_PROVIDER_ID
           ,RECORD_TYPE_CODE
           --,REPORTING_PERIOD_ID
           --,LEGAL_MESSAGE_APPL_2
           --,LEGAL_MESSAGE_STATUS
           --,LEGAL_MESSAGE_RATE
           --,LEGAL_MESSAGE_BASIS
           --,LEGAL_MESSAGE_CALC
           --,LEGAL_MESSAGE_THRESHOLD
           --,LEGAL_MESSAGE_POS
           --,LEGAL_MESSAGE_TRN
           --,LEGAL_MESSAGE_EXMPT
           --,LEGAL_MESSAGE_EXCPT
           --,TAX_REGIME_TEMPLATE_ID
           --,TAX_APPLICABILITY_RESULT_ID
           --,DIRECT_RATE_RESULT_ID
           --,STATUS_RESULT_ID
           --,RATE_RESULT_ID
           --,BASIS_RESULT_ID
           --,THRESH_RESULT_ID
           --,CALC_RESULT_ID
           --,TAX_REG_NUM_DET_RESULT_ID
           --,EVAL_EXMPT_RESULT_ID
           --,EVAL_EXCPT_RESULT_ID
           --,TAX_HOLD_CODE
           --,TAX_HOLD_RELEASED_CODE
           --,PRD_TOTAL_TAX_AMT
           --,PRD_TOTAL_TAX_AMT_TAX_CURR
           --,PRD_TOTAL_TAX_AMT_FUNCL_CURR
           --,INTERNAL_ORG_LOCATION_ID
           ,ATTRIBUTE_CATEGORY
           ,ATTRIBUTE1
           ,ATTRIBUTE2
           ,ATTRIBUTE3
           ,ATTRIBUTE4
           ,ATTRIBUTE5
           ,ATTRIBUTE6
           ,ATTRIBUTE7
           ,ATTRIBUTE8
           ,ATTRIBUTE9
           ,ATTRIBUTE10
           ,ATTRIBUTE11
           ,ATTRIBUTE12
           ,ATTRIBUTE13
           ,ATTRIBUTE14
           ,ATTRIBUTE15
           ,GLOBAL_ATTRIBUTE_CATEGORY
           ,GLOBAL_ATTRIBUTE1
           ,GLOBAL_ATTRIBUTE2
           ,GLOBAL_ATTRIBUTE3
           ,GLOBAL_ATTRIBUTE4
           ,GLOBAL_ATTRIBUTE5
           ,GLOBAL_ATTRIBUTE6
           ,GLOBAL_ATTRIBUTE7
           ,GLOBAL_ATTRIBUTE8
           ,GLOBAL_ATTRIBUTE9
           ,GLOBAL_ATTRIBUTE10
           ,GLOBAL_ATTRIBUTE11
           ,GLOBAL_ATTRIBUTE12
           ,GLOBAL_ATTRIBUTE13
           ,GLOBAL_ATTRIBUTE14
           ,GLOBAL_ATTRIBUTE15
           ,GLOBAL_ATTRIBUTE16
           ,GLOBAL_ATTRIBUTE17
           ,GLOBAL_ATTRIBUTE18
           ,GLOBAL_ATTRIBUTE19
           ,GLOBAL_ATTRIBUTE20
           ,LEGAL_JUSTIFICATION_TEXT1
           ,LEGAL_JUSTIFICATION_TEXT2
           ,LEGAL_JUSTIFICATION_TEXT3
           --,REPORTING_CURRENCY_CODE
           --,LINE_ASSESSABLE_VALUE
           --,TRX_LINE_INDEX
           --,OFFSET_TAX_RATE_CODE
           --,PRORATION_CODE
           --,OTHER_DOC_SOURCE
           --,CTRL_TOTAL_LINE_TX_AMT
           --,MRC_LINK_TO_TAX_LINE_ID
           --,APPLIED_TO_TRX_NUMBER
           --,INTERFACE_ENTITY_CODE
           --,INTERFACE_TAX_LINE_ID
           --,TAXING_JURIS_GEOGRAPHY_ID
 	   ,NUMERIC1
           ,NUMERIC2
           ,NUMERIC3
           ,NUMERIC4
           ,ADJUSTED_DOC_TAX_LINE_ID
           ,OBJECT_VERSION_NUMBER
           ,MULTIPLE_JURISDICTIONS_FLAG
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,LEGAL_REPORTING_STATUS
           ,ACCOUNT_SOURCE_TAX_RATE_ID
         )
         VALUES(
            TAX_LINE_ID
           ,INTERNAL_ORGANIZATION_ID
           ,APPLICATION_ID
           ,ENTITY_CODE
           ,EVENT_CLASS_CODE
           ,EVENT_TYPE_CODE
           ,TRX_ID
           ,TRX_LINE_ID
           ,TRX_LEVEL_TYPE
           ,TRX_LINE_NUMBER
           ,DOC_EVENT_STATUS
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           ,TAX_LINE_NUMBER
           ,CONTENT_OWNER_ID
           ,TAX_REGIME_ID
           ,TAX_REGIME_CODE
           ,TAX_ID
           ,TAX
           ,TAX_STATUS_ID
           ,TAX_STATUS_CODE
           ,TAX_RATE_ID
           ,TAX_RATE_CODE
           ,TAX_RATE
           ,TAX_RATE_TYPE
           ,TAX_APPORTIONMENT_LINE_NUMBER
           ,'N'    --MRC_TAX_LINE_FLAG
           ,LEDGER_ID
           --,ESTABLISHMENT_ID
           ,LEGAL_ENTITY_ID
           --,LEGAL_ENTITY_TAX_REG_NUMBER
           --,HQ_ESTB_REG_NUMBER
           --,HQ_ESTB_PARTY_TAX_PROF_ID
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_TYPE
           ,CURRENCY_CONVERSION_RATE
           --,TAX_CURRENCY_CONVERSION_DATE
           --,TAX_CURRENCY_CONVERSION_TYPE
           --,TAX_CURRENCY_CONVERSION_RATE
           ,TRX_CURRENCY_CODE
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,PRECISION
           ,TRX_NUMBER
           ,TRX_DATE
           ,UNIT_PRICE
           ,LINE_AMT
           ,TRX_LINE_QUANTITY
           ,TAX_BASE_MODIFIER_RATE
           --,REF_DOC_APPLICATION_ID
           --,REF_DOC_ENTITY_CODE
           --,REF_DOC_EVENT_CLASS_CODE
           --,REF_DOC_TRX_ID
           --,REF_DOC_LINE_ID
           --,REF_DOC_LINE_QUANTITY
           --,REF_DOC_TRX_LEVEL_TYPE
           --,OTHER_DOC_LINE_AMT
           --,OTHER_DOC_LINE_TAX_AMT
           --,OTHER_DOC_LINE_TAXABLE_AMT
           ,UNROUNDED_TAXABLE_AMT
           ,UNROUNDED_TAX_AMT
           ,RELATED_DOC_APPLICATION_ID
           --,RELATED_DOC_ENTITY_CODE
           --,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_TRX_ID
           --,RELATED_DOC_NUMBER
           --,RELATED_DOC_DATE
           --,RELATED_DOC_TRX_LEVEL_TYPE
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_ENTITY_CODE
           ,ADJUSTED_DOC_EVENT_CLASS_CODE
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           --,SUMMARY_TAX_LINE_ID
           --,OFFSET_LINK_TO_TAX_LINE_ID
           ,'N'   --OFFSET_FLAG
           ,'N'   --PROCESS_FOR_RECOVERY_FLAG
           --,TAX_JURISDICTION_ID
           --,TAX_JURISDICTION_CODE
           --,PLACE_OF_SUPPLY
           ,PLACE_OF_SUPPLY_TYPE_CODE
           --,PLACE_OF_SUPPLY_RESULT_ID
           --,TAX_DATE_RULE_ID
           ,TAX_DATE
           ,TAX_DETERMINE_DATE
           ,TAX_POINT_DATE
           ,TRX_LINE_DATE
           ,TAX_TYPE_CODE
           --,TAX_CODE
           --,TAX_REGISTRATION_ID
           --,TAX_REGISTRATION_NUMBER
           --,REGISTRATION_PARTY_TYPE
           ,ROUNDING_LEVEL_CODE
           ,ROUNDING_RULE_CODE
           --,ROUNDING_LVL_PARTY_TAX_PROF_ID
           --,ROUNDING_LVL_PARTY_TYPE
           ,'N'   --COMPOUNDING_TAX_FLAG
           --,ORIG_TAX_STATUS_ID
           --,ORIG_TAX_STATUS_CODE
           --,ORIG_TAX_RATE_ID
           --,ORIG_TAX_RATE_CODE
           --,ORIG_TAX_RATE
           --,ORIG_TAX_JURISDICTION_ID
           --,ORIG_TAX_JURISDICTION_CODE
           --,ORIG_TAX_AMT_INCLUDED_FLAG
           --,ORIG_SELF_ASSESSED_FLAG
           ,TAX_CURRENCY_CODE
           ,TAX_AMT
           ,TAX_AMT_TAX_CURR
           ,TAX_AMT_FUNCL_CURR
           ,TAXABLE_AMT
           ,TAXABLE_AMT_TAX_CURR
           ,TAXABLE_AMT_FUNCL_CURR
           --,ORIG_TAXABLE_AMT
           --,ORIG_TAXABLE_AMT_TAX_CURR
           ,CAL_TAX_AMT
           ,CAL_TAX_AMT_TAX_CURR
           ,CAL_TAX_AMT_FUNCL_CURR
           --,ORIG_TAX_AMT
           --,ORIG_TAX_AMT_TAX_CURR
           --,REC_TAX_AMT
           --,REC_TAX_AMT_TAX_CURR
           --,REC_TAX_AMT_FUNCL_CURR
           --,NREC_TAX_AMT
           --,NREC_TAX_AMT_TAX_CURR
           --,NREC_TAX_AMT_FUNCL_CURR
           ,TAX_EXEMPTION_ID
           --,TAX_RATE_BEFORE_EXEMPTION
           --,TAX_RATE_NAME_BEFORE_EXEMPTION
           --,EXEMPT_RATE_MODIFIER
           ,EXEMPT_CERTIFICATE_NUMBER
           --,EXEMPT_REASON
           ,EXEMPT_REASON_CODE
           ,TAX_EXCEPTION_ID
           ,TAX_RATE_BEFORE_EXCEPTION
           --,TAX_RATE_NAME_BEFORE_EXCEPTION
           --,EXCEPTION_RATE
           ,'N'    --TAX_APPORTIONMENT_FLAG
           ,'Y'    --HISTORICAL_FLAG
           ,TAXABLE_BASIS_FORMULA
           ,TAX_CALCULATION_FORMULA
           ,'N'    --CANCEL_FLAG
           ,'N'    --PURGE_FLAG
           ,'N'    --DELETE_FLAG
           ,'N'    --TAX_AMT_INCLUDED_FLAG
           ,'N'    --SELF_ASSESSED_FLAG
           ,'N'    --OVERRIDDEN_FLAG
           ,'N'    --MANUALLY_ENTERED_FLAG
           ,'N'    --REPORTING_ONLY_FLAG
           ,'N'    --FREEZE_UNTIL_OVERRIDDEN_FLAG
           ,'N'    --COPIED_FROM_OTHER_DOC_FLAG
           ,'N'    --RECALC_REQUIRED_FLAG
           ,'N'    --SETTLEMENT_FLAG
           ,'N'    --ITEM_DIST_CHANGED_FLAG
           ,'N'    --ASSOCIATED_CHILD_FROZEN_FLAG
           ,TAX_ONLY_LINE_FLAG
           ,'N'    --COMPOUNDING_DEP_TAX_FLAG
           ,'N'    --ENFORCE_FROM_NATURAL_ACCT_FLAG
           ,'N'    --COMPOUNDING_TAX_MISS_FLAG
           ,'N'    --SYNC_WITH_PRVDR_FLAG
           --,LAST_MANUAL_ENTRY
           ,TAX_PROVIDER_ID
           ,'MIGRATED'    --RECORD_TYPE_CODE
           --,REPORTING_PERIOD_ID
           --,LEGAL_MESSAGE_APPL_2
           --,LEGAL_MESSAGE_STATUS
           --,LEGAL_MESSAGE_RATE
           --,LEGAL_MESSAGE_BASIS
           --,LEGAL_MESSAGE_CALC
           --,LEGAL_MESSAGE_THRESHOLD
           --,LEGAL_MESSAGE_POS
           --,LEGAL_MESSAGE_TRN
           --,LEGAL_MESSAGE_EXMPT
           --,LEGAL_MESSAGE_EXCPT
           --,TAX_REGIME_TEMPLATE_ID
           --,TAX_APPLICABILITY_RESULT_ID
           --,DIRECT_RATE_RESULT_ID
           --,STATUS_RESULT_ID
           --,RATE_RESULT_ID
           --,BASIS_RESULT_ID
           --,THRESH_RESULT_ID
           --,CALC_RESULT_ID
           --,TAX_REG_NUM_DET_RESULT_ID
           --,EVAL_EXMPT_RESULT_ID
           --,EVAL_EXCPT_RESULT_ID
           --,TAX_HOLD_CODE
           --,TAX_HOLD_RELEASED_CODE
           --,PRD_TOTAL_TAX_AMT
           --,PRD_TOTAL_TAX_AMT_TAX_CURR
           --,PRD_TOTAL_TAX_AMT_FUNCL_CURR
           --,INTERNAL_ORG_LOCATION_ID
           ,ATTRIBUTE_CATEGORY
           ,ATTRIBUTE1
           ,ATTRIBUTE2
           ,ATTRIBUTE3
           ,ATTRIBUTE4
           ,ATTRIBUTE5
           ,ATTRIBUTE6
           ,ATTRIBUTE7
           ,ATTRIBUTE8
           ,ATTRIBUTE9
           ,ATTRIBUTE10
           ,ATTRIBUTE11
           ,ATTRIBUTE12
           ,ATTRIBUTE13
           ,ATTRIBUTE14
           ,ATTRIBUTE15
           ,GLOBAL_ATTRIBUTE_CATEGORY
           ,GLOBAL_ATTRIBUTE1
           ,GLOBAL_ATTRIBUTE2
           ,GLOBAL_ATTRIBUTE3
           ,GLOBAL_ATTRIBUTE4
           ,GLOBAL_ATTRIBUTE5
           ,GLOBAL_ATTRIBUTE6
           ,GLOBAL_ATTRIBUTE7
           ,GLOBAL_ATTRIBUTE8
           ,GLOBAL_ATTRIBUTE9
           ,GLOBAL_ATTRIBUTE10
           ,GLOBAL_ATTRIBUTE11
           ,GLOBAL_ATTRIBUTE12
           ,GLOBAL_ATTRIBUTE13
           ,GLOBAL_ATTRIBUTE14
           ,GLOBAL_ATTRIBUTE15
           ,GLOBAL_ATTRIBUTE16
           ,GLOBAL_ATTRIBUTE17
           ,GLOBAL_ATTRIBUTE18
           ,GLOBAL_ATTRIBUTE19
           ,GLOBAL_ATTRIBUTE20
           ,LEGAL_JUSTIFICATION_TEXT1
           ,LEGAL_JUSTIFICATION_TEXT2
           ,LEGAL_JUSTIFICATION_TEXT3
           --,REPORTING_CURRENCY_CODE
           --,LINE_ASSESSABLE_VALUE
           --,TRX_LINE_INDEX
           --,OFFSET_TAX_RATE_CODE
           --,PRORATION_CODE
           --,OTHER_DOC_SOURCE
           --,CTRL_TOTAL_LINE_TX_AMT
           --,MRC_LINK_TO_TAX_LINE_ID
           --,APPLIED_TO_TRX_NUMBER
           --,INTERFACE_ENTITY_CODE
           --,INTERFACE_TAX_LINE_ID
           --,TAXING_JURIS_GEOGRAPHY_ID
	   ,NUMERIC1
           ,NUMERIC2
           ,NUMERIC3
           ,NUMERIC4
           ,ADJUSTED_DOC_TAX_LINE_ID
           ,OBJECT_VERSION_NUMBER
           ,'N'     --MULTIPLE_JURISDICTIONS_FLAG
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,LEGAL_REPORTING_STATUS
           ,ACCOUNT_SOURCE_TAX_RATE_ID
          )
    SELECT /*+ ROWID(custtrx) ORDERED use_hash(arsysparam) swap_join_inputs(arsysparam) swap_join_inputs(upd)
              use_nl(types,fndcurr,fds,ptp,rbs,custtrx_prev,custtrxl,vat,rates,custtrxll,memoline) */
      NVL(custtrx.org_id, l_org_id)                   INTERNAL_ORGANIZATION_ID,
      222                                             APPLICATION_ID,
      'TRANSACTIONS'                                  ENTITY_CODE,
      DECODE(types.type,
        'INV','INVOICE',
        'CM', 'CREDIT_MEMO',
        'DM', 'DEBIT_MEMO',
        'NONE')                                       EVENT_CLASS_CODE,
      DECODE(types.type,
        'INV',4,
        'DM', 5,
        'CM', 6, NULL )                               EVENT_CLASS_MAPPING_ID,
--      DECODE(types.type,
--        'INV', 'INV_CREATE',
--        'CM', 'CM_CREATE',
--        'DM', 'DM_CREATE',
--        'CREATE')                                     EVENT_TYPE_CODE,
      DECODE(types.type,
        'INV',DECODE(NVL(SIGN(custtrx.printing_count), 0),
                1, 'INV_PRINT',
                DECODE(custtrx.complete_flag,
                     'Y', 'INV_COMPLETE',
                     'INV_CREATE')),
        'CM',DECODE(NVL(SIGN(custtrx.printing_count), 0),
                1, 'CM_PRINT',
                DECODE(custtrx.complete_flag,
                     'Y', 'CM_COMPLETE',
                     'CM_CREATE')),
        'DM',DECODE(NVL(SIGN(custtrx.printing_count), 0),
                1, 'DM_PRINT',
                DECODE(custtrx.complete_flag,
                     'Y', 'DM_COMPLETE',
                     'DM_CREATE')),
        'CREATE')                                     EVENT_TYPE_CODE,
      'CREATED'                                       DOC_EVENT_STATUS,
      'CREATE'                                        LINE_LEVEL_ACTION,
      custtrx.customer_trx_id                         TRX_ID,
      DECODE(custtrxl.line_type,
        'TAX', custtrxl.link_to_cust_trx_line_id,
        custtrxl.customer_trx_line_id)                TRX_LINE_ID,
      'LINE'                                          TRX_LEVEL_TYPE,
      NVL(custtrx.trx_date,sysdate)                   TRX_DATE,

      --NULL                                            TRX_DOC_REVISION,
      NVL(custtrx.invoice_currency_code,'USD')        TRX_CURRENCY_CODE,
      custtrx.exchange_date                           CURRENCY_CONVERSION_DATE,
      custtrx.exchange_rate                           CURRENCY_CONVERSION_RATE,
      custtrx.exchange_rate_type                      CURRENCY_CONVERSION_TYPE,
      fndcurr.minimum_accountable_unit                MINIMUM_ACCOUNTABLE_UNIT,
      NVL(fndcurr.precision,0)                        PRECISION,
      NVL(custtrx.legal_entity_id, -99 )              LEGAL_ENTITY_ID,
      --NULL                                            ESTABLISHMENT_ID,
      custtrx.cust_trx_type_id                        RECEIVABLES_TRX_TYPE_ID,
      arsysparam.default_country                      DEFAULT_TAXATION_COUNTRY,
      custtrx.trx_number                              TRX_NUMBER,
      DECODE(custtrxl.line_type,
        'TAX', custtrxll.line_number,
        custtrxl.line_number)                         TRX_LINE_NUMBER,
      SUBSTRB(custtrxl.description,1,240)             TRX_LINE_DESCRIPTION,
      --NULL                                            TRX_DESCRIPTION,
      --NULL                                            TRX_COMMUNICATED_DATE,
      custtrx.batch_source_id                         BATCH_SOURCE_ID,
      rbs.name                                        BATCH_SOURCE_NAME,
      custtrx.doc_sequence_id                         DOC_SEQ_ID,
      fds.name                                        DOC_SEQ_NAME,
      custtrx.doc_sequence_value                      DOC_SEQ_VALUE,
      custtrx.term_due_date                           TRX_DUE_DATE,
      types.description                               TRX_TYPE_DESCRIPTION,
      (CASE
       WHEN (custtrx.global_attribute_category = 'JA.TW.ARXTWMAI.RA_CUSTOMER_TRX' AND
           custtrx.global_attribute1 is NOT NULL) THEN
         'GUI TYPE/' || custtrx.global_attribute1
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO347' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y', 'MOD340/'||'E')
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO347PR' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y', 'MOD340/'||'E')
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO415' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y', 'MOD340/'||'F')
       WHEN custtrx.global_attribute_category ='JE.ES.ARXTWMAI.MODELO415_347' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y',
	        decode(custtrx.global_attribute7, 'E', 'MOD340/'||'E', 'F', 'MOD340/'||'F'))
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO415_347PR' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y',
	        decode(custtrx.global_attribute7, 'E', 'MOD340/'||'E', 'F', 'MOD340/'||'F'))
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO349' THEN
         DECODE(nvl(custtrx.global_attribute6,'N'),'N','MOD340_EXCL',  'Y',
                decode(custtrx.global_attribute7,'E','MOD340/E',  'U',
		       decode(custtrx.global_attribute9,NULL,'MOD340/U','A','MOD340/UA','B','MOD340/UB')))
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO340' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y',
	        decode(custtrx.global_attribute9, NULL, 'MOD340/U', 'A', 'MOD340/UA', 'B', 'MOD340/UB'))
       END)                                           DOCUMENT_SUB_TYPE,
      --NULL                                            SUPPLIER_TAX_INVOICE_NUMBER,
      --NULL                                            SUPPLIER_TAX_INVOICE_DATE,
      --NULL                                            SUPPLIER_EXCHANGE_RATE,
     (CASE
      WHEN custtrx.global_attribute_category
        IN ('JE.HU.ARXTWMAI.TAX_DATE',
            'JE.SK.ARXTWMAI.TAX_DATE',
            'JE.PL.ARXTWMAI.TAX_DATE',
            'JE.CZ.ARXTWMAI.TAX_DATE')
      THEN
        TO_DATE(custtrx.global_attribute1, 'YYYY/MM/DD HH24:MI:SS')
      WHEN custtrx.global_attribute_category
        = 'JL.AR.ARXTWMAI.TGW_HEADER' THEN
        TO_DATE(custtrx.global_attribute18, 'YYYY/MM/DD HH24:MI:SS')
      END)                                            TAX_INVOICE_DATE,

     (CASE
      WHEN custtrx.global_attribute_category
        = 'JL.AR.ARXTWMAI.TGW_HEADER' THEN
        custtrx.global_attribute17
      END)                                            TAX_INVOICE_NUMBER,
      ptp.party_tax_profile_id                        FIRST_PTY_ORG_ID,
      'SALES_TRANSACTION'                             TAX_EVENT_CLASS_CODE,
--      'CREATE'                                        TAX_EVENT_TYPE_CODE,
      DECODE(NVL(SIGN(custtrx.printing_count), 0),
        1, 'FREEZE_FOR_TAX',
        DECODE(custtrx.complete_flag,
             'Y', 'VALIDATE_FOR_TAX',
             'CREATE') )                              TAX_EVENT_TYPE_CODE,

      --NULL                                            LINE_INTENDED_USE,
      custtrxl.line_type                              TRX_LINE_TYPE,
      --NULL                                            TRX_SHIPPING_DATE,
      --NULL                                            TRX_RECEIPT_DATE,
      --NULL                                            TRX_SIC_CODE,
      custtrx.fob_point                               FOB_POINT,
      custtrx.waybill_number                          TRX_WAYBILL_NUMBER,
      custtrxl.inventory_item_id                      PRODUCT_ID,
     (CASE
      WHEN custtrx.global_attribute_category
          = 'JA.TW.ARXTWMAI.RA_CUSTOMER_TRX'
        AND  l_inv_installed = 'Y'
      THEN
        DECODE(custtrxl.global_attribute2,
               'Y', 'WINE CIGARRETE',
               'N', NULL)

      WHEN custtrxl.global_attribute_category
          IN ('JL.AR.ARXTWMAI.LINES',
              'JL.BR.ARXTWMAI.Additional Info',
              'JL.CO.ARXTWMAI.LINES' )
        AND  l_inv_installed = 'Y'
      THEN
        custtrxl.global_attribute2
      END)                                            PRODUCT_FISC_CLASSIFICATION,
      custtrxl.warehouse_id                           PRODUCT_ORG_ID,
      custtrxl.uom_code                               UOM_CODE,
      --NULL                                            PRODUCT_TYPE,
      --NULL                                            PRODUCT_CODE,
     (CASE
      WHEN custtrx.global_attribute_category
          = 'JA.TW.ARXTWMAI.RA_CUSTOMER_TRX'
        AND  l_inv_installed = 'N'
      THEN
        DECODE(custtrxl.global_attribute2,
               'Y', 'WINE CIGARRETE',
               'N', NULL)

      WHEN custtrxl.global_attribute_category
          IN ('JL.AR.ARXTWMAI.LINES',
              'JL.BR.ARXTWMAI.Additional Info',
              'JL.CO.ARXTWMAI.LINES')
        AND  l_inv_installed = 'N'
      THEN
        custtrxl.global_attribute2
      END)                                            PRODUCT_CATEGORY,

      DECODE( custtrxl.inventory_item_id,
              NULL,NULL,
              SUBSTRB(custtrxl.description,1,240) )   PRODUCT_DESCRIPTION,
     (CASE
      WHEN custtrxl.global_attribute_category
          = 'JL.BR.ARXTWMAI.Additional Info'
      THEN
        custtrxl.global_attribute1
      WHEN custtrxl.interface_line_context
          IN ('OKL_CONTRACTS',
              'OKL_INVESTOR',
              'OKL_MANUAL')
      THEN
        custtrxl.interface_line_attribute12
      WHEN custtrx.global_attribute_category IN (
                    'JE.ES.ARXTWMAI.MODELO347'
                   ,'JE.ES.ARXTWMAI.MODELO347PR'
                   ,'JE.ES.ARXTWMAI.MODELO349'
                   ,'JE.ES.ARXTWMAI.MODELO415'
                   ,'JE.ES.ARXTWMAI.MODELO415_347'
                   ,'JE.ES.ARXTWMAI.MODELO415_347PR'
                   ,'JE.ES.ARXTWMAI.MODELO340') THEN
        nvl(custtrx.global_attribute8, 'MOD340NONE')
      END)                                            USER_DEFINED_FISC_CLASS,

      DECODE( custtrxl.line_type,
        'TAX', nvl(custtrxll.extended_amount,0),
        nvl(custtrxl.extended_amount,0))              LINE_AMT,

      DECODE(custtrxl.line_type,
          'TAX', custtrxll.quantity_invoiced,
          custtrxl.quantity_invoiced )                TRX_LINE_QUANTITY,

      --NULL                                            CASH_DISCOUNT,
      --NULL                                            VOLUME_DISCOUNT,
      --NULL                                            TRADING_DISCOUNT,
      --NULL                                            TRANSFER_CHARGE,
      --NULL                                            TRANSPORTATION_CHARGE,
      --NULL                                            INSURANCE_CHARGE,
      --NULL                                            OTHER_CHARGE,
      --NULL                                            ASSESSABLE_VALUE,
      --NULL                                            ASSET_FLAG,
      --NULL                                            ASSET_NUMBER,
      1                                               ASSET_ACCUM_DEPRECIATION,
      --NULL                                            ASSET_TYPE,
      1                                               ASSET_COST,

      DECODE( custtrx.related_customer_trx_id,
        NULL, NULL,
        222)                                          RELATED_DOC_APPLICATION_ID,
      --NULL                                            RELATED_DOC_ENTITY_CODE,
      --NULL                                            RELATED_DOC_EVENT_CLASS_CODE,
      custtrx.related_customer_trx_id                 RELATED_DOC_TRX_ID,
      --NULL                                            RELATED_DOC_NUMBER,
      --NULL                                            RELATED_DOC_DATE,

      DECODE(custtrxl.previous_customer_trx_id,
        NULL, NULL,
        222 )                                         ADJUSTED_DOC_APPLICATION_ID,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, NULL,
        'TRANSACTIONS' )                              ADJUSTED_DOC_ENTITY_CODE,
      --NULL                                            ADJUSTED_DOC_EVENT_CLASS_CODE,
      DECODE(types.type,
        'CM', 'INVOICE',
        'DM', 'INVOICE',
        NULL)                                         ADJUSTED_DOC_EVENT_CLASS_CODE,
      custtrxl.previous_customer_trx_id               ADJUSTED_DOC_TRX_ID,

      DECODE(custtrxl.line_type,
        'TAX', custtrxll.previous_customer_trx_line_id,
        custtrxl.previous_customer_trx_line_id)       ADJUSTED_DOC_LINE_ID,

      custtrx_prev.trx_number                         ADJUSTED_DOC_NUMBER,
      custtrx_prev.trx_Date                           ADJUSTED_DOC_DATE,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, NULL,
        'LINE' )                                      ADJUSTED_DOC_TRX_LEVEL_TYPE,

      --NULL                                            REF_DOC_APPLICATION_ID,
      --NULL                                            REF_DOC_ENTITY_CODE,
      --NULL                                            REF_DOC_EVENT_CLASS_CODE,
      --NULL                                            REF_DOC_TRX_ID,
      --NULL                                            REF_DOC_LINE_ID,
      --NULL                                            REF_DOC_LINE_QUANTITY,
      --NULL                                            REF_DOC_TRX_LEVEL_TYPE,

      (CASE
       WHEN custtrx.global_attribute_category
           = 'JA.TW.ARXTWMAI.RA_CUSTOMER_TRX'
       THEN
         'SALES_TRANSACTION/' ||custtrx.global_attribute3

       WHEN custtrx.global_attribute_category IN
              ('JE.ES.ARXTWMAI.INVOICE_INFO'
              ,'JE.ES.ARXTWMAI.MODELO347'
              ,'JE.ES.ARXTWMAI.MODELO347PR'
              ,'JE.ES.ARXTWMAI.MODELO349'
              ,'JE.ES.ARXTWMAI.MODELO415'
              ,'JE.ES.ARXTWMAI.MODELO415_347'
              ,'JE.ES.ARXTWMAI.MODELO415_347PR'
              ,'JE.ES.ARXTWMAI.OTHER')
       THEN
         'SALES_TRANSACTION/INVOICE TYPE/'||custtrx.global_attribute1

       WHEN custtrxl.global_attribute_category IN
              ('JL.AR.ARXTWMAI.LINES'
              ,'JL.BR.ARXTWMAI.Additional Info'
              ,'JL.CO.ARXTWMAI.LINES')
       THEN
         'SALES_TRANSACTION/' ||custtrxl.global_attribute3

       WHEN custtrx.global_attribute_category IN
             ('JE.ES.ARXTWMAI.INVOICE_INFO'
             ,'JE.ES.ARXTWMAI.OTHER')
       THEN
         'SALES_TRANSACTION/INVOICE TYPE/'||custtrx.global_attribute1

       WHEN custtrx.global_attribute_category IN
             ('JE.ES.ARXTWMAI.MODELO347'
             ,'JE.ES.ARXTWMAI.MODELO347PR'
             ,'JE.ES.ARXTWMAI.MODELO349'
             ,'JE.ES.ARXTWMAI.MODELO415'
             ,'JE.ES.ARXTWMAI.MODELO415_347'
             ,'JE.ES.ARXTWMAI.MODELO415_347PR')
       THEN
         'SALES_TRANSACTION/INVOICE TYPE/'||custtrx.global_attribute1||'/'||nvl(custtrx.GLOBAL_ATTRIBUTE11,'B')

       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO340'
       THEN
         'SALES_TRANSACTION/INVOICE TYPE/'||custtrx.global_attribute1||'/'||nvl(custtrx.GLOBAL_ATTRIBUTE8,'B')
       END )                                          TRX_BUSINESS_CATEGORY,

      custtrxl.tax_exempt_number                      EXEMPT_CERTIFICATE_NUMBER,
      --NULL                                            EXEMPT_REASON,
      custtrxl.tax_exempt_flag                        EXEMPTION_CONTROL_FLAG,
      custtrxl.tax_exempt_reason_code                 EXEMPT_REASON_CODE,
      --'Y'                                             HISTORICAL_FLAG,
      NVL(custtrx.trx_date,sysdate)                   TRX_LINE_GL_DATE,
      --'N'                                             LINE_AMT_INCLUDES_TAX_FLAG,
      --NULL                                            ACCOUNT_CCID,
      --NULL                                            ACCOUNT_STRING,
      --NULL                                            SHIP_TO_LOCATION_ID,
      --NULL                                            SHIP_FROM_LOCATION_ID,
      --NULL                                            POA_LOCATION_ID,
      --NULL                                            POO_LOCATION_ID,
      --NULL                                            BILL_TO_LOCATION_ID,
      --NULL                                            BILL_FROM_LOCATION_ID,
      --NULL                                            PAYING_LOCATION_ID,
      --NULL                                            OWN_HQ_LOCATION_ID,
      --NULL                                            TRADING_HQ_LOCATION_ID,
      --NULL                                            POC_LOCATION_ID,
      --NULL                                            POI_LOCATION_ID,
      --NULL                                            POD_LOCATION_ID,
      --NULL                                            TITLE_TRANSFER_LOCATION_ID,
      --'N'                                             CTRL_HDR_TX_APPL_FLAG,
      --NULL                                            CTRL_TOTAL_LINE_TX_AMT,
      --NULL                                            CTRL_TOTAL_HDR_TX_AMT,

      DECODE(types.type,
        'INV','INVOICE',
        'CM', 'CREDIT_MEMO',
        'DM', 'DEBIT_MEMO',
        types.type)                                   LINE_CLASS,
      NVL(custtrx.trx_date,sysdate)                   TRX_LINE_DATE,
      --NULL                                            INPUT_TAX_CLASSIFICATION_CODE,
      vat.tax_code                                    OUTPUT_TAX_CLASSIFICATION_CODE,
      --NULL                                            INTERNAL_ORG_LOCATION_ID,
      --NULL                                            PORT_OF_ENTRY_CODE,
      --'Y'                                             TAX_REPORTING_FLAG,
      --'N'                                             TAX_AMT_INCLUDED_FLAG,
      --'N'                                             COMPOUNDING_TAX_FLAG,
      --NULL                                            EVENT_ID,
      --'N'                                             THRESHOLD_INDICATOR_FLAG,
      --NULL                                            PROVNL_TAX_DETERMINATION_DATE,
      DECODE(custtrxl.line_type,
        'TAX', custtrxll.unit_selling_price,
        custtrxl.unit_selling_price )                 UNIT_PRICE,
      custtrx.ship_to_site_use_id                     SHIP_TO_CUST_ACCT_SITE_USE_ID,
      custtrx.bill_to_site_use_id                     BILL_TO_CUST_ACCT_SITE_USE_ID,
      custtrx.batch_id                                TRX_BATCH_ID,

      --NULL                                            START_EXPENSE_DATE,
      --NULL                                            SOURCE_APPLICATION_ID,
      --NULL                                            SOURCE_ENTITY_CODE,
      --NULL                                            SOURCE_EVENT_CLASS_CODE,
      --NULL                                            SOURCE_TRX_ID,
      --NULL                                            SOURCE_LINE_ID,
      --NULL                                            SOURCE_TRX_LEVEL_TYPE,
      --'MIGRATED'                                      RECORD_TYPE_CODE,
      --'N'                                             INCLUSIVE_TAX_OVERRIDE_FLAG,
      --'N'                                             TAX_PROCESSING_COMPLETED_FLAG,
      1                                               OBJECT_VERSION_NUMBER,
      DECODE(types.default_status,
        'VD', 'VD',
        NULL)                                         APPLICATION_DOC_STATUS,
      --'N'                                             USER_UPD_DET_FACTORS_FLAG,
      --NULL                                            SOURCE_TAX_LINE_ID,
      --NULL                                            REVERSED_APPLN_ID,
      --NULL                                            REVERSED_ENTITY_CODE,
      --NULL                                            REVERSED_EVNT_CLS_CODE,
      --NULL                                            REVERSED_TRX_ID,
      --NULL                                            REVERSED_TRX_LEVEL_TYPE,
      --NULL                                            REVERSED_TRX_LINE_ID,
      --NULL                                            TAX_CALCULATION_DONE_FLAG,
      decode(arsysparam.tax_database_view_set,'_A','Y','_V','Y',NULL)
						      PARTNER_MIGRATED_FLAG,
      custtrx.ship_to_address_id                      SHIP_THIRD_PTY_ACCT_SITE_ID,
      custtrx.bill_to_address_id                      BILL_THIRD_PTY_ACCT_SITE_ID,
      custtrx.ship_to_customer_id                     SHIP_THIRD_PTY_ACCT_ID,
      custtrx.bill_to_customer_id                     BILL_THIRD_PTY_ACCT_ID,

      --NULL                                            INTERFACE_ENTITY_CODE,
      --NULL                                            INTERFACE_LINE_ID,
      --NULL                                            HISTORICAL_TAX_CODE_ID,
      --NULL                                            ICX_SESSION_ID,
      --NULL                                            TRX_LINE_CURRENCY_CODE,
      --NULL                                            TRX_LINE_CURRENCY_CONV_RATE,
      --NULL                                            TRX_LINE_CURRENCY_CONV_DATE,
      --NULL                                            TRX_LINE_PRECISION,
      --NULL                                            TRX_LINE_MAU,
      --NULL                                            TRX_LINE_CURRENCY_CONV_TYPE,

      -- zx_lines columns start from here

      custtrxl.tax_line_id                            TAX_LINE_ID,
      DECODE(custtrxl.line_type,
        'TAX', RANK() OVER (
                 PARTITION BY
                   custtrxl.link_to_cust_trx_line_id,
                   custtrxl.customer_trx_id
                 ORDER BY
                   custtrxl.line_number,
                   custtrxl.customer_trx_line_id
                 ),
        NULL)                                         TAX_LINE_NUMBER,
      ptp.party_tax_profile_id                        CONTENT_OWNER_ID,
      regimes.tax_regime_id                           TAX_REGIME_ID,
      rates.TAX_REGIME_CODE                           TAX_REGIME_CODE,
      taxes.tax_id                                    TAX_ID,
      rates.tax                                       TAX,
      status.tax_status_id                            TAX_STATUS_ID,
      rates.TAX_STATUS_CODE                           TAX_STATUS_CODE,
      custtrxl.vat_tax_id                             TAX_RATE_ID,
      rates.TAX_RATE_CODE                             TAX_RATE_CODE,
      custtrxl.tax_rate                               TAX_RATE,
      rates.rate_type_code                            TAX_RATE_TYPE,

      DECODE(custtrxl.line_type,
        'TAX', RANK() OVER (
                 PARTITION BY
                   rates.tax_regime_code,
                   rates.tax,
                   custtrxl.link_to_cust_trx_line_id,
                   custtrxl.customer_trx_id
                 ORDER BY
                   custtrxl.line_number,
                   custtrxl.customer_trx_line_id
               ),
        NULL)                                         TAX_APPORTIONMENT_LINE_NUMBER,

      --'N'                                             MRC_TAX_LINE_FLAG,
      custtrx.set_of_books_id                         LEDGER_ID,
      --NULL                                            LEGAL_ENTITY_TAX_REG_NUMBER,
      --NULL                                            HQ_ESTB_REG_NUMBER,
      --NULL                                            HQ_ESTB_PARTY_TAX_PROF_ID,
      --NULL                                            TAX_CURRENCY_CONVERSION_DATE,
      --NULL                                            TAX_CURRENCY_CONVERSION_TYPE,
      --NULL                                            TAX_CURRENCY_CONVERSION_RATE,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ('JL.BR.ARXTWMAI.Additional Info',
               'JL.CO.ARXTWMAI.LINES',
               'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute12,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute12),
           NULL)
      END)                                            TAX_BASE_MODIFIER_RATE,

      --NULL                                            OTHER_DOC_LINE_AMT,
      --NULL                                            OTHER_DOC_LINE_TAX_AMT,
      --NULL                                            OTHER_DOC_LINE_TAXABLE_AMT,
      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute11,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute11),
           NULL)
       ELSE
         custtrxl.taxable_amount
       END)                                           UNROUNDED_TAXABLE_AMT,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN( 'JL.BR.ARXTWMAI.Additional Info',
               'JL.CO.ARXTWMAI.LINES',
               'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute19,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute19),
           NULL)
       ELSE
         custtrxl.extended_amount
       END)                                           UNROUNDED_TAX_AMT,
      --NULL                                            RELATED_DOC_TRX_LEVEL_TYPE,
      --NULL                                            SUMMARY_TAX_LINE_ID,
      --NULL                                            OFFSET_LINK_TO_TAX_LINE_ID,
      --'N'                                             OFFSET_FLAG,
      --'N'                                             PROCESS_FOR_RECOVERY_FLAG,
      --NULL                                            TAX_JURISDICTION_ID,
      --NULL                                            TAX_JURISDICTION_CODE,
      --NULL                                            PLACE_OF_SUPPLY,
--      decode(custtrx.ship_to_site_use_id,null,'BILL_TO','SHIP_TO')       PLACE_OF_SUPPLY_TYPE_CODE,
      'SHIP_TO_BILL_TO'                               PLACE_OF_SUPPLY_TYPE_CODE,
      --NULL                                            PLACE_OF_SUPPLY_RESULT_ID,
      --NULL                                            TAX_DATE_RULE_ID,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, custtrx.trx_date,
        custtrx_prev.trx_date )                       TAX_DATE,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, custtrx.trx_date,
        custtrx_prev.trx_date )                       TAX_DETERMINE_DATE,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, custtrx.trx_date,
        custtrx_prev.trx_date )                       TAX_POINT_DATE,
      taxes.tax_type_code                             TAX_TYPE_CODE,
      --NULL                                            TAX_CODE,
      --NULL                                            TAX_REGISTRATION_ID,
      --NULL                                            TAX_REGISTRATION_NUMBER,
      --NULL                                            REGISTRATION_PARTY_TYPE,
      decode (arsysparam.TRX_HEADER_LEVEL_ROUNDING,
              'Y', 'HEADER',
              'LINE')                                 ROUNDING_LEVEL_CODE,
      arsysparam.TAX_ROUNDING_RULE                    ROUNDING_RULE_CODE,
      --NULL                                            ROUNDING_LVL_PARTY_TAX_PROF_ID,
      --NULL                                            ROUNDING_LVL_PARTY_TYPE,
      --NULL                                            ORIG_TAX_STATUS_ID,
      --NULL                                            ORIG_TAX_STATUS_CODE,
      --NULL                                            ORIG_TAX_RATE_ID,
      --NULL                                            ORIG_TAX_RATE_CODE,
      --NULL                                            ORIG_TAX_RATE,
      --NULL                                            ORIG_TAX_JURISDICTION_ID,
      --NULL                                            ORIG_TAX_JURISDICTION_CODE,
      --NULL                                            ORIG_TAX_AMT_INCLUDED_FLAG,
      --NULL                                            ORIG_SELF_ASSESSED_FLAG,
      taxes.tax_currency_code                         TAX_CURRENCY_CODE,
      custtrxl.extended_amount                        TAX_AMT,
      (CASE
       WHEN custtrxl.global_attribute_category
           IN( 'JL.BR.ARXTWMAI.Additional Info',
               'JL.CO.ARXTWMAI.LINES',
               'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute19,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute19)*
                  NVL(custtrx.exchange_rate,1),
           NULL)
       ELSE
         custtrxl.extended_amount *
           NVL(custtrx.exchange_rate,1)
       END)                                           TAX_AMT_TAX_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN( 'JL.BR.ARXTWMAI.Additional Info',
               'JL.CO.ARXTWMAI.LINES',
               'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute19,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute19)*
                  NVL(custtrx.exchange_rate,1),
           NULL)
       ELSE
         custtrxl.extended_amount *
           NVL(custtrx.exchange_rate,1)
       END)                                           TAX_AMT_FUNCL_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute11,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute11),
           NULL)
       ELSE
         custtrxl.taxable_amount
       END)                                           TAXABLE_AMT,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute11,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute11)*
                  NVL(custtrx.exchange_rate,1),
           NULL)
       ELSE
         custtrxl.taxable_amount*
           NVL(custtrx.exchange_rate,1)
       END)                                           TAXABLE_AMT_TAX_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute11,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute11)*
                  NVL(custtrx.exchange_rate,1),
           NULL)
       ELSE
         custtrxl.taxable_amount*
           NVL(custtrx.exchange_rate,1)
       END)                                           TAXABLE_AMT_FUNCL_CURR,

      --NULL                                            ORIG_TAXABLE_AMT,
      --NULL                                            ORIG_TAXABLE_AMT_TAX_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute20,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute20),
           NULL)
      END)                                            CAL_TAX_AMT,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute20,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute20)*
                  NVL(custtrx.EXCHANGE_RATE,1),
           NULL)
      END)                                            CAL_TAX_AMT_TAX_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute20,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute20)*
                  NVL(custtrx.EXCHANGE_RATE,1),
           NULL)
      END)                                            CAL_TAX_AMT_FUNCL_CURR,

      --NULL                                            ORIG_TAX_AMT,
      --NULL                                            ORIG_TAX_AMT_TAX_CURR,
      --NULL                                            REC_TAX_AMT,
      --NULL                                            REC_TAX_AMT_TAX_CURR,
      --NULL                                            REC_TAX_AMT_FUNCL_CURR,
      --NULL                                            NREC_TAX_AMT,
      --NULL                                            NREC_TAX_AMT_TAX_CURR,
      --NULL                                            NREC_TAX_AMT_FUNCL_CURR,
      custtrxl.TAX_EXEMPTION_ID                       TAX_EXEMPTION_ID,
      --NULL                                            TAX_RATE_BEFORE_EXEMPTION,
      --NULL                                            TAX_RATE_NAME_BEFORE_EXEMPTION,
      --NULL                                            EXEMPT_RATE_MODIFIER,
      custtrxl.item_exception_rate_id                 TAX_EXCEPTION_ID,
      DECODE(rates.rate_type_code,
        'PERCENTAGE', rates.percentage_rate,
        'QUANTITY', rates.quantity_rate,
        NULL)                                         TAX_RATE_BEFORE_EXCEPTION,
      --NULL                                            TAX_RATE_NAME_BEFORE_EXCEPTION,
      --NULL                                            EXCEPTION_RATE,
      --'N'                                             TAX_APPORTIONMENT_FLAG,
--      DECODE(vat.taxable_basis,
--        'AFTER_EPD', 'STANDARD_TB_DISCOUNT',
--        'QUANTITY', 'STANDARD_QUANTITY',
--        'STANDARD_TB')                                TAXABLE_BASIS_FORMULA,
--      'STANDARD_TC'                                   TAX_CALCULATION_FORMULA,
      NVL(rates.taxable_basis_formula_code,
        taxes.def_taxable_basis_formula)              TAXABLE_BASIS_FORMULA,
      NVL(taxes.def_tax_calc_formula,
        'STANDARD_TC')                                TAX_CALCULATION_FORMULA,
      --'N'                                             CANCEL_FLAG,
      --'N'                                             PURGE_FLAG,
      --'N'                                             DELETE_FLAG,
      --'N'                                             SELF_ASSESSED_FLAG,
      --'N'                                             OVERRIDDEN_FLAG,
      --'N'                                             MANUALLY_ENTERED_FLAG,
      --'N'                                             REPORTING_ONLY_FLAG,
      --'N'                                             FREEZE_UNTIL_OVERRIDDEN_FLAG,
      --'N'                                             COPIED_FROM_OTHER_DOC_FLAG,
      --'N'                                             RECALC_REQUIRED_FLAG,
      --'N'                                             SETTLEMENT_FLAG,
      --'N'                                             ITEM_DIST_CHANGED_FLAG,
      --'N'                                             ASSOCIATED_CHILD_FROZEN_FLAG,
      DECODE(memoline.line_type, 'TAX', 'Y', 'N')     TAX_ONLY_LINE_FLAG,
      --'N'                                             COMPOUNDING_DEP_TAX_FLAG,
      --'N'                                             ENFORCE_FROM_NATURAL_ACCT_FLAG,
      --'N'                                             COMPOUNDING_TAX_MISS_FLAG,
      --'N'                                             SYNC_WITH_PRVDR_FLAG,
      --NULL                                            LAST_MANUAL_ENTRY,
      decode(arsysparam.tax_database_view_set,'_A',2,'_V',1, NULL)
						      TAX_PROVIDER_ID,
      --NULL                                            REPORTING_PERIOD_ID,
      --NULL                                            LEGAL_MESSAGE_APPL_2,
      --NULL                                            LEGAL_MESSAGE_STATUS,
      --NULL                                            LEGAL_MESSAGE_RATE,
      --NULL                                            LEGAL_MESSAGE_BASIS,
      --NULL                                            LEGAL_MESSAGE_CALC,
      --NULL                                            LEGAL_MESSAGE_THRESHOLD,
      --NULL                                            LEGAL_MESSAGE_POS,
      --NULL                                            LEGAL_MESSAGE_TRN,
      --NULL                                            LEGAL_MESSAGE_EXMPT,
      --NULL                                            LEGAL_MESSAGE_EXCPT,
      --NULL                                            TAX_REGIME_TEMPLATE_ID,
      --NULL                                            TAX_APPLICABILITY_RESULT_ID,
      --NULL                                            DIRECT_RATE_RESULT_ID,
      --NULL                                            STATUS_RESULT_ID,
      --NULL                                            RATE_RESULT_ID,
      --NULL                                            BASIS_RESULT_ID,
      --NULL                                            THRESH_RESULT_ID,
      --NULL                                            CALC_RESULT_ID,
      --NULL                                            TAX_REG_NUM_DET_RESULT_ID,
      --NULL                                            EVAL_EXMPT_RESULT_ID,
      --NULL                                            EVAL_EXCPT_RESULT_ID,
      --NULL                                            TAX_HOLD_CODE,
      --NULL                                            TAX_HOLD_RELEASED_CODE,
      --NULL                                            PRD_TOTAL_TAX_AMT,
      --NULL                                            PRD_TOTAL_TAX_AMT_TAX_CURR,
      --NULL                                            PRD_TOTAL_TAX_AMT_FUNCL_CURR,
      custtrxl.GLOBAL_ATTRIBUTE8                      LEGAL_JUSTIFICATION_TEXT1,
      custtrxl.GLOBAL_ATTRIBUTE9                      LEGAL_JUSTIFICATION_TEXT2,
      custtrxl.GLOBAL_ATTRIBUTE10                     LEGAL_JUSTIFICATION_TEXT3,
      --NULL                                            REPORTING_CURRENCY_CODE,
      --NULL                                            LINE_ASSESSABLE_VALUE,
      --NULL                                            TRX_LINE_INDEX,
      --NULL                                            OFFSET_TAX_RATE_CODE,
      --NULL                                            PRORATION_CODE,
      --NULL                                            OTHER_DOC_SOURCE,
      --NULL                                            MRC_LINK_TO_TAX_LINE_ID,
      --NULL                                            APPLIED_TO_TRX_NUMBER,
      --NULL                                            INTERFACE_TAX_LINE_ID,
      --NULL                                            TAXING_JURIS_GEOGRAPHY_ID,
      decode(arsysparam.tax_database_view_Set ,
                        '_A',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute2,null),
                        '_V',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute2,null),
                        NULL)                               numeric1,
                decode(arsysparam.tax_database_view_Set ,
                        '_A',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute4,null),
                        '_V',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute4,null),
                        NULL)                               numeric2,
                decode(arsysparam.tax_database_view_Set ,
                        '_A',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute6,null),
                        '_V',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute6,null),
                        NULL)                               numeric3,
     decode(arsysparam.tax_database_view_Set,
                        '_A',
                decode(custtrxl.global_attribute1,'ALL',
			     to_number(substrb(custtrxl.global_Attribute12,1,
                             instrb(custtrxl.global_Attribute12,'|',1,1)-1)),
                        'STATE',
                             to_number(substrb(custtrxl.global_Attribute12,1,
                             instrb(custtrxl.global_Attribute12,'|',1,1)-1)),
                                        NULL),
                        '_V',
                decode(custtrxl.global_attribute1,'ALL',
			     to_number(substrb(custtrxl.global_Attribute12,1,
                             instrb(custtrxl.global_Attribute12,'|',1,1)-1)),
                       'STATE',
                             to_number(substrb(custtrxl.global_Attribute12,1,
                             instrb(custtrxl.global_Attribute12,'|',1,1)-1)),
                                        NULL)
                      ,NULL) numeric4,

      --DECODE(custtrxl.line_type,
      --  'TAX', custtrxl.previous_customer_trx_line_id,
      --  NULL)                                         ADJUSTED_DOC_TAX_LINE_ID,
      decode(custtrxl_prev.line_type, 'TAX', custtrxl_prev.tax_line_id, null) ADJUSTED_DOC_TAX_LINE_ID,
      custtrxl.ATTRIBUTE_CATEGORY                     ATTRIBUTE_CATEGORY,
      custtrxl.ATTRIBUTE1                             ATTRIBUTE1,
      custtrxl.ATTRIBUTE2                             ATTRIBUTE2,
      custtrxl.ATTRIBUTE3                             ATTRIBUTE3,
      custtrxl.ATTRIBUTE4                             ATTRIBUTE4,
      custtrxl.ATTRIBUTE5                             ATTRIBUTE5,
      custtrxl.ATTRIBUTE6                             ATTRIBUTE6,
      custtrxl.ATTRIBUTE7                             ATTRIBUTE7,
      custtrxl.ATTRIBUTE8                             ATTRIBUTE8,
      custtrxl.ATTRIBUTE9                             ATTRIBUTE9,
      custtrxl.ATTRIBUTE10                            ATTRIBUTE10,
      custtrxl.ATTRIBUTE11                            ATTRIBUTE11,
      custtrxl.ATTRIBUTE12                            ATTRIBUTE12,
      custtrxl.ATTRIBUTE13                            ATTRIBUTE13,
      custtrxl.ATTRIBUTE14                            ATTRIBUTE14,
      custtrxl.ATTRIBUTE15                            ATTRIBUTE15,
      custtrxl.GLOBAL_ATTRIBUTE_CATEGORY              GLOBAL_ATTRIBUTE_CATEGORY,
      custtrxl.GLOBAL_ATTRIBUTE1                      GLOBAL_ATTRIBUTE1,
      custtrxl.GLOBAL_ATTRIBUTE2                      GLOBAL_ATTRIBUTE2,
      custtrxl.GLOBAL_ATTRIBUTE3                      GLOBAL_ATTRIBUTE3,
      custtrxl.GLOBAL_ATTRIBUTE4                      GLOBAL_ATTRIBUTE4,
      custtrxl.GLOBAL_ATTRIBUTE5                      GLOBAL_ATTRIBUTE5,
      custtrxl.GLOBAL_ATTRIBUTE6                      GLOBAL_ATTRIBUTE6,
      custtrxl.GLOBAL_ATTRIBUTE7                      GLOBAL_ATTRIBUTE7,
      custtrxl.GLOBAL_ATTRIBUTE8                      GLOBAL_ATTRIBUTE8,
      custtrxl.GLOBAL_ATTRIBUTE9                      GLOBAL_ATTRIBUTE9,
      custtrxl.GLOBAL_ATTRIBUTE10                     GLOBAL_ATTRIBUTE10,
      custtrxl.GLOBAL_ATTRIBUTE11                     GLOBAL_ATTRIBUTE11,
      custtrxl.GLOBAL_ATTRIBUTE12                     GLOBAL_ATTRIBUTE12,
      custtrxl.GLOBAL_ATTRIBUTE13                     GLOBAL_ATTRIBUTE13,
      custtrxl.GLOBAL_ATTRIBUTE14                     GLOBAL_ATTRIBUTE14,
      custtrxl.GLOBAL_ATTRIBUTE15                     GLOBAL_ATTRIBUTE15,
      custtrxl.GLOBAL_ATTRIBUTE16                     GLOBAL_ATTRIBUTE16,
      custtrxl.GLOBAL_ATTRIBUTE17                     GLOBAL_ATTRIBUTE17,
      custtrxl.GLOBAL_ATTRIBUTE18                     GLOBAL_ATTRIBUTE18,
      custtrxl.GLOBAL_ATTRIBUTE19                     GLOBAL_ATTRIBUTE19,
      custtrxl.GLOBAL_ATTRIBUTE20                     GLOBAL_ATTRIBUTE20,
      --'N'                                             MULTIPLE_JURISDICTIONS_FLAG,
      SYSDATE                                         CREATION_DATE,
      1                                               CREATED_BY,
      SYSDATE                                         LAST_UPDATE_DATE,
      1                                               LAST_UPDATED_BY,
      0                                               LAST_UPDATE_LOGIN,
      DECODE(custtrx.complete_flag,
          'Y', '111111111111111',
               '000000000000000')                     LEGAL_REPORTING_STATUS,
      DECODE(vat.tax_type,
             'LOCATION', NULL,
             custtrxl.vat_tax_id)                     ACCOUNT_SOURCE_TAX_RATE_ID

  FROM      RA_CUSTOMER_TRX_ALL        custtrx,
            XLA_UPGRADE_DATES           upd,
            AR_SYSTEM_PARAMETERS_ALL   arsysparam,
            RA_CUST_TRX_TYPES_ALL      types,
            FND_CURRENCIES             fndcurr,
            FND_DOCUMENT_SEQUENCES     fds,
            ZX_PARTY_TAX_PROFILE       ptp,
            RA_BATCH_SOURCES_ALL       rbs,
            RA_CUSTOMER_TRX_ALL        custtrx_prev,
            RA_CUSTOMER_TRX_LINES_ALL  custtrxl_prev,
            RA_CUSTOMER_TRX_LINES_ALL  custtrxl,
            AR_VAT_TAX_ALL_B           vat,
            ZX_RATES_B                 rates ,
            RA_CUSTOMER_TRX_LINES_ALL  custtrxll,  -- retrieve the trx line for tax lines
            AR_MEMO_LINES_ALL_B        memoline,
            ZX_REGIMES_B               regimes,
            ZX_TAXES_B                 taxes,
            ZX_STATUS_B                status
    WHERE custtrx.rowid BETWEEN p_start_rowid AND p_end_rowid
      AND custtrx.customer_trx_id = custtrxl.customer_trx_id
      AND custtrx.previous_customer_trx_id = custtrx_prev.customer_trx_id(+)
      AND custtrxl.previous_customer_trx_line_id = custtrxl_prev.customer_trx_line_id(+)
      AND upd.ledger_id = custtrx.set_of_books_id
      AND (custtrx.trx_date between upd.start_date and upd.end_date )
      AND (case when (custtrxl.line_type IN ('LINE' ,'CB')) then custtrxl.customer_trx_line_id
 	        when (custtrxl.line_type = 'TAX') then custtrxl.link_to_cust_trx_line_id
 	   end ) = custtrxll.customer_trx_line_id
      AND ((custtrxl.line_type = 'TAX' AND custtrxll.line_type = 'LINE')
             OR
   	   (custtrxl.line_type <> 'TAX'))

      AND custtrx.cust_trx_type_id = types.cust_trx_type_id
      AND types.type in ('INV','CM', 'DM')
      AND decode(l_multi_org_flag,'N',l_org_id, custtrx.org_id) =
            decode(l_multi_org_flag,'N',l_org_id, types.org_id)
      AND custtrx.invoice_currency_code = fndcurr.currency_code
      AND custtrx.doc_sequence_id = fds.doc_sequence_id (+)
      AND ptp.party_id = decode(l_multi_org_flag,'N',l_org_id, custtrx.org_id)
      AND ptp.party_type_code = 'OU'
      AND custtrx.batch_source_id = rbs.batch_source_id(+)
      AND decode(l_multi_org_flag,'N',l_org_id, custtrx.org_id) =
            decode(l_multi_org_flag,'N',l_org_id, rbs.org_id(+))
      AND custtrxl.vat_tax_id = vat.vat_tax_id(+)
      AND custtrx.org_id = arsysparam.org_id
      AND custtrxl.vat_Tax_id = rates.tax_rate_id(+)
      AND custtrxll.memo_line_id = memoline.memo_line_id(+)
      AND decode(l_multi_org_flag,'N',l_org_id, custtrxll.org_id) = decode(l_multi_org_flag,'N',l_org_id, memoline.org_id(+))
      AND rates.tax_regime_code = regimes.tax_regime_code(+)
      AND rates.tax_regime_code = taxes.tax_regime_code(+)
      AND rates.tax = taxes.tax(+)
      AND rates.content_owner_id = taxes.content_owner_id(+)
      AND rates.tax_regime_code = status.tax_regime_code(+)
      AND rates.tax = status.tax(+)
      AND rates.tax_status_code = status.tax_status_code(+)
      AND rates.content_owner_id = status.content_owner_id(+)
      AND NVL(arsysparam.tax_code, '!') <> 'Localization'
      AND NOT EXISTS
          (SELECT 1 FROM zx_lines_det_factors zxl
            WHERE zxl.APPLICATION_ID   = 222
              AND zxl.EVENT_CLASS_CODE = DECODE(types.type,
                                           'INV','INVOICE',
                                           'CM', 'CREDIT_MEMO',
                                           'DM', 'DEBIT_MEMO',
                                           'NONE')
              AND zxl.ENTITY_CODE      = 'TRANSACTIONS'
              AND zxl.TRX_ID           = custtrx.customer_trx_id
           );

    x_rows_processed := SQL%ROWCOUNT;

     IF g_level_procedure >= g_current_runtime_level THEN
       FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AR_TRX_MIG','Worker: '||p_worker_id||' x_rows_processed is  ' || x_rows_processed );
       FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AR_TRX_MIG','Worker: '||p_worker_id||' zx_ar_trx_mig (-)' );
     END IF;

EXCEPTION
  WHEN OTHERS THEN
    X_retcode := CONC_FAIL;
    IF g_level_unexpected >= g_current_runtime_level THEN
      FND_LOG.STRING(g_level_unexpected,
        'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AR_TRX_MIG',
        'Worker: '||p_worker_id||'Raised exceptions: '||
         sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80) );
    END IF;
    raise;

  END zx_ar_trx_mig;

/**************************************************************/

  PROCEDURE zx_ap_trx_mig (x_errbuf         OUT NOCOPY VARCHAR2,
                           x_retcode        OUT NOCOPY VARCHAR2,
                           p_start_rowid    IN	ROWID,
                           p_end_rowid      IN	ROWID,
                           p_org_id         IN	NUMBER,
                           p_multi_org_flag IN	VARCHAR2,
                           p_worker_id      IN  NUMBER,
                           x_rows_processed OUT	NOCOPY NUMBER)
  IS
	  l_multi_org_flag            VARCHAR2(1);
	  l_org_id                    NUMBER;
  BEGIN
	  l_multi_org_flag            := p_multi_org_flag;
	  l_org_id                    := p_org_id;


 	IF g_level_procedure >= g_current_runtime_level THEN
                FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AP_TRX_MIG','Worker: '||p_worker_id||' zx_ap_trx_mig (+)' );
                FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AP_TRX_MIG','Worker: '||p_worker_id||' p_start_rowid is ' || p_start_rowid );
  		FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AP_TRX_MIG','Worker: '||p_worker_id||'p_end_rowid is ' || p_end_rowid );
  		FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AP_TRX_MIG','Worker: '||p_worker_id||'p_org_id is ' || p_org_id );
  		FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AP_TRX_MIG','Worker: '||p_worker_id||'p_multi_org_flag is  ' || p_multi_org_flag );
        END IF;

  x_retcode := CONC_SUCCESS;

  -- Insert data into zx_lines_det_factors and zx_lines_summary
  --
  INSERT ALL
    WHEN AP_LINE_LOOKUP_CODE IN ('ITEM', 'PREPAY','FREIGHT','MISCELLANEOUS') OR
	 TAX_ONLY_LINE_FLAG = 'Y'
    THEN
      INTO ZX_LINES_DET_FACTORS (
		--EVENT_ID
		OBJECT_VERSION_NUMBER
		,INTERNAL_ORGANIZATION_ID
		,APPLICATION_ID
		,ENTITY_CODE
		,EVENT_CLASS_CODE
		,EVENT_TYPE_CODE
		,TAX_EVENT_CLASS_CODE
		,TAX_EVENT_TYPE_CODE
		,LINE_LEVEL_ACTION
		,LINE_CLASS
		,TRX_ID
		,TRX_LINE_ID
		,TRX_LEVEL_TYPE
		,TRX_DATE
		,LEDGER_ID
		,TRX_CURRENCY_CODE
		,CURRENCY_CONVERSION_DATE
		,CURRENCY_CONVERSION_RATE
		,CURRENCY_CONVERSION_TYPE
		,MINIMUM_ACCOUNTABLE_UNIT
		,PRECISION
		,LEGAL_ENTITY_ID
		,DEFAULT_TAXATION_COUNTRY
		,TRX_NUMBER
		,TRX_LINE_NUMBER
		,TRX_LINE_DESCRIPTION
		,TRX_DESCRIPTION
		,TRX_COMMUNICATED_DATE
		,TRX_LINE_GL_DATE
		,BATCH_SOURCE_ID
		,DOC_SEQ_ID
		,DOC_SEQ_NAME
		,DOC_SEQ_VALUE
		,TRX_DUE_DATE
		,TRX_LINE_TYPE
		,TRX_LINE_DATE
		,LINE_AMT
		,TRX_LINE_QUANTITY
		,UNIT_PRICE
		,PRODUCT_ID
		,UOM_CODE
		,PRODUCT_TYPE
		,PRODUCT_DESCRIPTION
		,FIRST_PTY_ORG_ID
		,ACCOUNT_CCID
		,APPLIED_FROM_APPLICATION_ID
		,APPLIED_FROM_ENTITY_CODE
		,APPLIED_FROM_EVENT_CLASS_CODE
		,APPLIED_FROM_TRX_ID
		,APPLIED_FROM_LINE_ID
		,ADJUSTED_DOC_APPLICATION_ID
		,ADJUSTED_DOC_ENTITY_CODE
		,ADJUSTED_DOC_EVENT_CLASS_CODE
		,ADJUSTED_DOC_TRX_ID
		,ADJUSTED_DOC_LINE_ID
		,APPLIED_TO_APPLICATION_ID
		,APPLIED_TO_ENTITY_CODE
		,APPLIED_TO_EVENT_CLASS_CODE
		,APPLIED_TO_TRX_ID
		,APPLIED_TO_TRX_LINE_ID
		,REF_DOC_TRX_LEVEL_TYPE
		,REF_DOC_APPLICATION_ID
		,REF_DOC_ENTITY_CODE
		,REF_DOC_EVENT_CLASS_CODE
		,REF_DOC_TRX_ID
		,REF_DOC_LINE_ID
		,APPLIED_TO_TRX_LEVEL_TYPE
		,APPLIED_FROM_TRX_LEVEL_TYPE
		,ADJUSTED_DOC_TRX_LEVEL_TYPE
		,MERCHANT_PARTY_NAME
		,MERCHANT_PARTY_DOCUMENT_NUMBER
		,MERCHANT_PARTY_REFERENCE
		,MERCHANT_PARTY_TAXPAYER_ID
		,MERCHANT_PARTY_TAX_REG_NUMBER
		,MERCHANT_PARTY_COUNTRY
		,START_EXPENSE_DATE
		,SHIP_TO_LOCATION_ID
		,RECORD_TYPE_CODE
		,PRODUCT_FISC_CLASSIFICATION
		,PRODUCT_CATEGORY
		,USER_DEFINED_FISC_CLASS
		,ASSESSABLE_VALUE
		,TRX_BUSINESS_CATEGORY
		,SUPPLIER_TAX_INVOICE_NUMBER
		,SUPPLIER_TAX_INVOICE_DATE
		,SUPPLIER_EXCHANGE_RATE
		,TAX_INVOICE_DATE
		,TAX_INVOICE_NUMBER
		,DOCUMENT_SUB_TYPE
		,LINE_INTENDED_USE
		,PORT_OF_ENTRY_CODE
		,HISTORICAL_FLAG
		,LINE_AMT_INCLUDES_TAX_FLAG
		,CTRL_HDR_TX_APPL_FLAG
		,TAX_REPORTING_FLAG
		,TAX_AMT_INCLUDED_FLAG
		,COMPOUNDING_TAX_FLAG
		,INCLUSIVE_TAX_OVERRIDE_FLAG
		,THRESHOLD_INDICATOR_FLAG
		,USER_UPD_DET_FACTORS_FLAG
		,TAX_PROCESSING_COMPLETED_FLAG
		,ASSET_FLAG
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,EVENT_CLASS_MAPPING_ID
		,SHIP_THIRD_PTY_ACCT_ID
		,SHIP_THIRD_PTY_ACCT_SITE_ID
		,GLOBAL_ATTRIBUTE_CATEGORY
		,GLOBAL_ATTRIBUTE1
		,BILL_THIRD_PTY_ACCT_ID
		,BILL_THIRD_PTY_ACCT_SITE_ID
		)
	VALUES(
		-- -9999
		1
		,INTERNAL_ORGANIZATION_ID
		,200
		,'AP_INVOICES'
		,EVENT_CLASS_CODE
		,EVENT_TYPE_CODE
		,TAX_EVENT_CLASS_CODE
		,'VALIDATE'
		,'CREATE'
		,LINE_CLASS
		,TRX_ID
		,TRX_LINE_ID
		,'LINE'
		,TRX_DATE
		,LEDGER_ID
		,TRX_CURRENCY_CODE
		,CURRENCY_CONVERSION_DATE
		,CURRENCY_CONVERSION_RATE
		,CURRENCY_CONVERSION_TYPE
		,MINIMUM_ACCOUNTABLE_UNIT
		,PRECISION
		,LEGAL_ENTITY_ID
		,DEFAULT_TAXATION_COUNTRY
		,TRX_NUMBER
		,TRX_LINE_NUMBER
		,TRX_LINE_DESCRIPTION
		,TRX_DESCRIPTION
		,TRX_COMMUNICATED_DATE
		,TRX_LINE_GL_DATE
		,BATCH_SOURCE_ID
		,DOC_SEQ_ID
		,DOC_SEQ_NAME
		,DOC_SEQ_VALUE
		,TRX_DUE_DATE
		,TRX_LINE_TYPE
		,TRX_LINE_DATE
		,LINE_AMT
		,TRX_LINE_QUANTITY
		,UNIT_PRICE
		,PRODUCT_ID
		,UOM_CODE
		,PRODUCT_TYPE
		,PRODUCT_DESCRIPTION
		,FIRST_PTY_ORG_ID
		,ACCOUNT_CCID
		,APPLIED_FROM_APPLICATION_ID
		,APPLIED_FROM_ENTITY_CODE
		,APPLIED_FROM_EVENT_CLASS_CODE
		,APPLIED_FROM_TRX_ID
		,APPLIED_FROM_LINE_ID
		,ADJUSTED_DOC_APPLICATION_ID
		,ADJUSTED_DOC_ENTITY_CODE
		,ADJUSTED_DOC_EVENT_CLASS_CODE
		,ADJUSTED_DOC_TRX_ID
		,ADJUSTED_DOC_LINE_ID
		,APPLIED_TO_APPLICATION_ID
		,APPLIED_TO_ENTITY_CODE
		,APPLIED_TO_EVENT_CLASS_CODE
		,APPLIED_TO_TRX_ID
		,APPLIED_TO_TRX_LINE_ID
		,REF_DOC_TRX_LEVEL_TYPE
		,REF_DOC_APPLICATION_ID
		,REF_DOC_ENTITY_CODE
		,REF_DOC_EVENT_CLASS_CODE
		,REF_DOC_TRX_ID
		,REF_DOC_LINE_ID
		,APPLIED_TO_TRX_LEVEL_TYPE
		,APPLIED_FROM_TRX_LEVEL_TYPE
		,ADJUSTED_DOC_TRX_LEVEL_TYPE
		,MERCHANT_PARTY_NAME
		,MERCHANT_PARTY_DOCUMENT_NUMBER
		,MERCHANT_PARTY_REFERENCE
		,MERCHANT_PARTY_TAXPAYER_ID
		,MERCHANT_PARTY_TAX_REG_NUMBER
		,MERCHANT_PARTY_COUNTRY
		,START_EXPENSE_DATE
		,SHIP_TO_LOCATION_ID
		,'MIGRATED'
		,PRODUCT_FISC_CLASSIFICATION
		,PRODUCT_CATEGORY
		,USER_DEFINED_FISC_CLASS
		,ASSESSABLE_VALUE
		,TRX_BUSINESS_CATEGORY
		,SUPPLIER_TAX_INVOICE_NUMBER
		,SUPPLIER_TAX_INVOICE_DATE
		,SUPPLIER_EXCHANGE_RATE
		,TAX_INVOICE_DATE
		,TAX_INVOICE_NUMBER
		,DOCUMENT_SUB_TYPE
		,LINE_INTENDED_USE
		,PORT_OF_ENTRY_CODE
		,'Y'
		,'N'
		,'N'
		,'Y'
		,'N'
		,'N'
		,'N'
		,'N'
		,'N'
		,'N'
		,ASSET_FLAG
		,sysdate
		,1
		,sysdate
		,1
		,1
		,EVENT_CLASS_MAPPING_ID
		,SHIP_THIRD_PTY_ACCT_ID
		,SHIP_THIRD_PTY_ACCT_SITE_ID
		,GLOBAL_ATTRIBUTE_CATEGORY
		,GLOBAL_ATTRIBUTE1
		,BILL_THIRD_PTY_ACCT_ID
		,BILL_THIRD_PTY_ACCT_SITE_ID
		)
    WHEN AP_LINE_LOOKUP_CODE = 'TAX' THEN
      INTO ZX_LINES_SUMMARY (
		SUMMARY_TAX_LINE_ID
		,INTERNAL_ORGANIZATION_ID
		,APPLICATION_ID
		,ENTITY_CODE
		,EVENT_CLASS_CODE
		,TRX_ID
		,TRX_NUMBER
		,APPLIED_FROM_APPLICATION_ID
		,APPLIED_FROM_EVENT_CLASS_CODE
		,APPLIED_FROM_ENTITY_CODE
		,APPLIED_FROM_TRX_ID
		,ADJUSTED_DOC_APPLICATION_ID
		,ADJUSTED_DOC_ENTITY_CODE
		,ADJUSTED_DOC_EVENT_CLASS_CODE
		,ADJUSTED_DOC_TRX_ID
		,SUMMARY_TAX_LINE_NUMBER
		,CONTENT_OWNER_ID
		,TAX_REGIME_CODE
		,TAX
		,TAX_STATUS_CODE
		,TAX_RATE_ID
		,TAX_RATE_CODE
		,TAX_RATE
		,TAX_AMT
		,TAX_AMT_TAX_CURR
		,TAX_AMT_FUNCL_CURR
		,TAX_JURISDICTION_CODE
		,TOTAL_REC_TAX_AMT
		,TOTAL_REC_TAX_AMT_FUNCL_CURR
		,TOTAL_NREC_TAX_AMT
		,TOTAL_NREC_TAX_AMT_FUNCL_CURR
		,LEDGER_ID
		,LEGAL_ENTITY_ID
		,CURRENCY_CONVERSION_DATE
		,CURRENCY_CONVERSION_TYPE
		,CURRENCY_CONVERSION_RATE
		,TAXABLE_BASIS_FORMULA
		,TAX_CALCULATION_FORMULA
		,HISTORICAL_FLAG
		,CANCEL_FLAG
		,DELETE_FLAG
		,TAX_AMT_INCLUDED_FLAG
		,COMPOUNDING_TAX_FLAG
		,SELF_ASSESSED_FLAG
		,OVERRIDDEN_FLAG
		,REPORTING_ONLY_FLAG
		,ASSOCIATED_CHILD_FROZEN_FLAG
		,COPIED_FROM_OTHER_DOC_FLAG
		,MANUALLY_ENTERED_FLAG
		,LAST_MANUAL_ENTRY   --BUG7146063
		,RECORD_TYPE_CODE
		,TAX_ONLY_LINE_FLAG
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN
		,ATTRIBUTE_CATEGORY
		,ATTRIBUTE1
		,ATTRIBUTE2
		,ATTRIBUTE3
		,ATTRIBUTE4
		,ATTRIBUTE5
		,ATTRIBUTE6
		,ATTRIBUTE7
		,ATTRIBUTE8
		,ATTRIBUTE9
		,ATTRIBUTE10
		,ATTRIBUTE11
		,ATTRIBUTE12
		,ATTRIBUTE13
		,ATTRIBUTE14
		,ATTRIBUTE15
		,APPLIED_FROM_LINE_ID
		,APPLIED_TO_APPLICATION_ID
		,APPLIED_TO_EVENT_CLASS_CODE
		,APPLIED_TO_ENTITY_CODE
		,APPLIED_TO_TRX_ID
		,APPLIED_TO_LINE_ID
		,TOTAL_REC_TAX_AMT_TAX_CURR
		,TOTAL_NREC_TAX_AMT_TAX_CURR
		,MRC_TAX_LINE_FLAG
		,GLOBAL_ATTRIBUTE_CATEGORY
		,GLOBAL_ATTRIBUTE1
		,GLOBAL_ATTRIBUTE2
		,GLOBAL_ATTRIBUTE3
		,GLOBAL_ATTRIBUTE4
		,GLOBAL_ATTRIBUTE5
		,GLOBAL_ATTRIBUTE6
		,GLOBAL_ATTRIBUTE7
		,GLOBAL_ATTRIBUTE8
		,GLOBAL_ATTRIBUTE9
		,GLOBAL_ATTRIBUTE10
		,GLOBAL_ATTRIBUTE11
		,GLOBAL_ATTRIBUTE12
		,GLOBAL_ATTRIBUTE13
		,GLOBAL_ATTRIBUTE14
		,GLOBAL_ATTRIBUTE15
		,GLOBAL_ATTRIBUTE16
		,GLOBAL_ATTRIBUTE17
		,GLOBAL_ATTRIBUTE18
		,GLOBAL_ATTRIBUTE19
		,GLOBAL_ATTRIBUTE20
		,APPLIED_FROM_TRX_LEVEL_TYPE
		,ADJUSTED_DOC_TRX_LEVEL_TYPE
		,APPLIED_TO_TRX_LEVEL_TYPE
		,TRX_LEVEL_TYPE
		,OBJECT_VERSION_NUMBER)
	VALUES(
		SUMMARY_TAX_LINE_ID
		,INTERNAL_ORGANIZATION_ID
		,200
		,'AP_INVOICES'
		,EVENT_CLASS_CODE
		,TRX_ID
		,TRX_NUMBER
		,APPLIED_FROM_APPLICATION_ID
		,APPLIED_FROM_EVENT_CLASS_CODE
		,APPLIED_FROM_ENTITY_CODE
		,APPLIED_FROM_TRX_ID
		,ADJUSTED_DOC_APPLICATION_ID
		,ADJUSTED_DOC_ENTITY_CODE
		,ADJUSTED_DOC_EVENT_CLASS_CODE
		,ADJUSTED_DOC_TRX_ID
		,SUMMARY_TAX_LINE_NUMBER
		,CONTENT_OWNER_ID
		,TAX_REGIME_CODE
		,TAX
		,TAX_STATUS_CODE
		,TAX_RATE_ID
		,TAX_RATE_CODE
		,TAX_RATE
		,TAX_AMT
		,TAX_AMT_TAX_CURR
		,TAX_AMT_FUNCL_CURR
		,TAX_JURISDICTION_CODE
		,TOTAL_REC_TAX_AMT
		,TOTAL_REC_TAX_AMT_FUNCL_CURR
		,TOTAL_NREC_TAX_AMT
		,TOTAL_NREC_TAX_AMT_FUNCL_CURR
		,LEDGER_ID
		,LEGAL_ENTITY_ID
		,CURRENCY_CONVERSION_DATE
		,CURRENCY_CONVERSION_TYPE
		,CURRENCY_CONVERSION_RATE
		,'STANDARD_TB'
		,'STANDARD_TC'
		,'Y'
		,CANCEL_FLAG
		,'N'
		,'N'
		,'N'
		,'N'
		,'N'
		,'N'
		,'N'
		,'N'
		,MANUALLY_ENTERED_FLAG
		,LAST_MANUAL_ENTRY   --BUG7146063
		,'MIGRATED'
		,TAX_ONLY_LINE_FLAG
		,1
		,sysdate
		,1
		,sysdate
		,1
		,ATTRIBUTE_CATEGORY
		,ATTRIBUTE1
		,ATTRIBUTE2
		,ATTRIBUTE3
		,ATTRIBUTE4
		,ATTRIBUTE5
		,ATTRIBUTE6
		,ATTRIBUTE7
		,ATTRIBUTE8
		,ATTRIBUTE9
		,ATTRIBUTE10
		,ATTRIBUTE11
		,ATTRIBUTE12
		,ATTRIBUTE13
		,ATTRIBUTE14
		,ATTRIBUTE15
		,APPLIED_FROM_LINE_ID
		,APPLIED_TO_APPLICATION_ID
		,APPLIED_TO_EVENT_CLASS_CODE
		,APPLIED_TO_ENTITY_CODE
		,APPLIED_TO_TRX_ID
		,APPLIED_TO_TRX_LINE_ID
		,TOTAL_REC_TAX_AMT_FUNCL_CURR
		,TOTAL_NREC_TAX_AMT_FUNCL_CURR
		,'N'
		,GLOBAL_ATTRIBUTE_CATEGORY
		,GLOBAL_ATTRIBUTE1
		,GLOBAL_ATTRIBUTE2
		,GLOBAL_ATTRIBUTE3
		,GLOBAL_ATTRIBUTE4
		,GLOBAL_ATTRIBUTE5
		,GLOBAL_ATTRIBUTE6
		,GLOBAL_ATTRIBUTE7
		,GLOBAL_ATTRIBUTE8
		,GLOBAL_ATTRIBUTE9
		,GLOBAL_ATTRIBUTE10
		,GLOBAL_ATTRIBUTE11
		,GLOBAL_ATTRIBUTE12
		,GLOBAL_ATTRIBUTE13
		,GLOBAL_ATTRIBUTE14
		,GLOBAL_ATTRIBUTE15
		,GLOBAL_ATTRIBUTE16
		,GLOBAL_ATTRIBUTE17
		,GLOBAL_ATTRIBUTE18
		,GLOBAL_ATTRIBUTE19
		,GLOBAL_ATTRIBUTE20
		,APPLIED_FROM_TRX_LEVEL_TYPE
		,ADJUSTED_DOC_TRX_LEVEL_TYPE
		,APPLIED_TO_TRX_LEVEL_TYPE
		,'LINE'
		,1
		)
       SELECT  /*+ ROWID(inv) NO_EXPAND ORDERED swap_join_inputs(upd) use_nl(fnd_curr,fds,poll)
		   use_nl_with_index(lines AP_INVOICE_LINES_U1)
		   use_nl_with_index(PTP ZX_PARTY_TAX_PROFILE_U2) */
		 NVL(lines.org_id,-99)                                INTERNAL_ORGANIZATION_ID
		,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE,
                  'STANDARD', 'STANDARD INVOICES',   --Bug 5859937
		  'CREDIT'  , 'STANDARD INVOICES',   --Bug 5859937
		  'DEBIT'   , 'STANDARD INVOICES',   --Bug 5859937
		  'MIXED'   , 'STANDARD INVOICES',   --Bug 5859937
		  'ADJUSTMENT','STANDARD INVOICES',  --Bug 5859937
		  'PO PRICE ADJUST','STANDARD INVOICES', --Bug 5859937
		  'INVOICE REQUEST','STANDARD INVOICES', --Bug 5859937
		  'CREDIT MEMO REQUEST','STANDARD INVOICES',--Bug 5859937
 	          'RETAINAGE RELEASE'  ,'STANDARD INVOICES',--Bug 5859937
                  'PREPAYMENT', 'PREPAYMENT INVOICES',
                  'EXPENSE REPORT', 'EXPENSE REPORTS',
                  'INTEREST INVOICE', 'INTEREST INVOICES','NA')       EVENT_CLASS_CODE
		,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE, 'STANDARD', 1,
		  'PREPAYMENT', 7, 'EXPENSE REPORT', 2, NULL)         EVENT_CLASS_MAPPING_ID
		,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE,
		  'STANDARD','STANDARD INVOICE CREATED',
		  'PREPAYMENT','PREPAYMENT INVOICE CREATED',
		  'EXPENSE REPORT','EXPENSE REPORT CREATED',
		  'INTEREST INVOICE','INTEREST INVOICE CREATED','NA') EVENT_TYPE_CODE
	       ,(CASE
		 WHEN inv.invoice_type_lookup_code in
		   ('ADJUSTMENT','CREDIT','DEBIT','INTEREST',
		    'MIXED','QUICKDEFAULT','PO PRICE ADJUST',
		    'QUICKMATCH','STANDARD','AWT')
		  THEN 'PURCHASE_TRANSACTION'
		 WHEN inv.invoice_type_lookup_code = 'PREPAYMENT'
		  THEN 'PURCHASE_PREPAYMENTTRANSACTION'
		 WHEN inv.invoice_type_lookup_code='EXPENSE REPORT'
		  THEN  'EXPENSE_REPORT'
		 ELSE   NULL
		END)                                                  TAX_EVENT_CLASS_CODE
		,DECODE(lines.po_line_location_id,
		  NULL, DECODE(lines.line_type_lookup_code,
			 'PREPAY', 'PREPAY_APPLICATION',
			  DECODE(inv.invoice_type_lookup_code,
				'STANDARD', 'STANDARD INVOICES',
				'CREDIT','AP_CREDIT_MEMO',
				'CREDIT MEMO REQUEST', 'AP_CREDIT_MEMO',
				'DEBIT','AP_DEBIT_MEMO',
				'PREPAYMENT','PREPAYMENT INVOICES',
				'EXPENSE REPORT','EXPENSE REPORTS',
				'STANDARD INVOICES'
				)
			       ),
			DECODE(poll.shipment_type,
			 'PREPAYMENT', DECODE(poll.payment_type,
					 'ADVANCE', 'ADVANCE',
					 'MILESTONE', 'FINANCING',
					 'RATE', 'FINANCING',
					 'LUMPSUM', 'FINANCING',
					 DECODE(poll.matching_basis,
					   'AMOUNT','AMOUNT_MATCHED',
					   'STANDARD INVOICES')
					      ),
				       DECODE(poll.matching_basis,
					'AMOUNT','AMOUNT_MATCHED',
					'STANDARD INVOICES')
			       )
		      )                                               LINE_CLASS
		,lines.line_type_lookup_code                          AP_LINE_LOOKUP_CODE
		,lines.invoice_id                                     TRX_ID
		,NVL(inv.invoice_date,sysdate)                        TRX_DATE
		,lines.set_of_books_id                                LEDGER_ID
		,inv.invoice_currency_code                            TRX_CURRENCY_CODE
		,NVL(inv.legal_entity_id, -99)                        LEGAL_ENTITY_ID
		,inv.taxation_country                                 DEFAULT_TAXATION_COUNTRY
		,inv.invoice_num                                      TRX_NUMBER
		,lines.description                                    TRX_LINE_DESCRIPTION
		,inv.description                                      TRX_DESCRIPTION
		,inv.invoice_received_date                            TRX_COMMUNICATED_DATE
		,NVL(lines.accounting_date,sysdate)                   TRX_LINE_GL_DATE
		,inv.batch_id                                         BATCH_SOURCE_ID
		,inv.doc_sequence_id                                  DOC_SEQ_ID
		,fds.name                                             DOC_SEQ_NAME
		,inv.doc_sequence_value                               DOC_SEQ_VALUE
		,inv.terms_date                                       TRX_DUE_DATE
		,lines.line_type_lookup_code                          TRX_LINE_TYPE
		,lines.accounting_date                                TRX_LINE_DATE
		,NVL(lines.amount,0)                                  LINE_AMT
		,lines.quantity_invoiced                              TRX_LINE_QUANTITY
		,lines.unit_price
		,lines.inventory_item_id                              PRODUCT_ID
		,lines.unit_meas_lookup_code                          UOM_CODE
		,lines.product_type
		,lines.item_description                               PRODUCT_DESCRIPTION
		,ptp.party_tax_profile_id                             FIRST_PTY_ORG_ID
		,DECODE(lines.prepay_invoice_id, NULL, NULL, 200)     APPLIED_FROM_APPLICATION_ID
		,DECODE(lines.prepay_invoice_id, NULL, NULL,
			'AP_INVOICES')                                APPLIED_FROM_ENTITY_CODE
		,DECODE(lines.prepay_invoice_id, NULL, NULL,
			'PREPAYMENT INVOICES')                        APPLIED_FROM_EVENT_CLASS_CODE
		,lines.prepay_invoice_id                              APPLIED_FROM_TRX_ID
		,lines.prepay_line_number                             APPLIED_FROM_LINE_ID
		,DECODE(lines.corrected_inv_id, NULL, NULL, 200)      ADJUSTED_DOC_APPLICATION_ID
		,DECODE(lines.corrected_inv_id, NULL, NULL,
			'AP_INVOICES')                                ADJUSTED_DOC_ENTITY_CODE
		,DECODE(lines.corrected_inv_id, NULL, NULL,
			'STANDARD INVOICES')                          ADJUSTED_DOC_EVENT_CLASS_CODE
		,lines.corrected_inv_id                               ADJUSTED_DOC_TRX_ID
		,lines.corrected_line_number                          ADJUSTED_DOC_LINE_ID
		,DECODE(lines.rcv_transaction_id, NULL, NULL, 707)    APPLIED_TO_APPLICATION_ID
		,DECODE(lines.rcv_transaction_id, NULL, NULL,
		       'RCV_ACCOUNTING_EVENTS')                       APPLIED_TO_ENTITY_CODE
		,DECODE(lines.rcv_transaction_id, NULL, NULL,
			'RCPT_REC_INSP')                              APPLIED_TO_EVENT_CLASS_CODE
		,lines.rcv_transaction_id                             APPLIED_TO_TRX_ID
		,lines.rcv_shipment_line_id                           APPLIED_TO_TRX_LINE_ID
		,DECODE(NVL(lines.po_release_id, lines.po_header_id),
			NULL, NULL, 'SHIPMENT')                       REF_DOC_TRX_LEVEL_TYPE
		,NVL(lines.po_release_id, lines.po_header_id)         REF_DOC_TRX_ID
		,lines.po_line_location_id                            REF_DOC_LINE_ID
		,DECODE(lines.rcv_transaction_id, NULL, NULL,
			'LINE')                                       APPLIED_TO_TRX_LEVEL_TYPE
		,DECODE(lines.prepay_invoice_id, NULL, NULL,
			'LINE')                                       APPLIED_FROM_TRX_LEVEL_TYPE
		,DECODE(lines.corrected_inv_id, NULL, NULL,
			'LINE')                                       ADJUSTED_DOC_TRX_LEVEL_TYPE
		,lines.merchant_name                                  MERCHANT_PARTY_NAME
		,lines.merchant_document_number                       MERCHANT_PARTY_DOCUMENT_NUMBER
		,lines.merchant_reference                             MERCHANT_PARTY_REFERENCE
		,lines.merchant_taxpayer_id                           MERCHANT_PARTY_TAXPAYER_ID
		,lines.merchant_tax_reg_number                        MERCHANT_PARTY_TAX_REG_NUMBER
		,lines.country_of_supply                              MERCHANT_PARTY_COUNTRY
		,lines.start_expense_date
		,lines.ship_to_location_id
		,lines.product_fisc_classification
		,lines.product_category
		,lines.user_defined_fisc_class
		,lines.assessable_value
		,lines.trx_business_category
		,inv.supplier_tax_invoice_number
		,inv.supplier_tax_invoice_date
		,inv.supplier_tax_exchange_rate                       SUPPLIER_EXCHANGE_RATE
		,inv.tax_invoice_recording_date                       TAX_INVOICE_DATE
		,inv.tax_invoice_internal_seq                         TAX_INVOICE_NUMBER
		,inv.document_sub_type
		,lines.primary_intended_use                           LINE_INTENDED_USE
		,inv.port_of_entry_code
		,lines.assets_tracking_flag                           ASSET_FLAG
		,ptp.party_tax_profile_id                             CONTENT_OWNER_ID
		,inv.exchange_date                                    CURRENCY_CONVERSION_DATE
		,inv.exchange_rate                                    CURRENCY_CONVERSION_RATE
		,inv.exchange_rate_type                               CURRENCY_CONVERSION_TYPE
		,fnd_curr.minimum_accountable_unit                    MINIMUM_ACCOUNTABLE_UNIT
		,NVL(fnd_curr.precision,0)                            PRECISION
		,DECODE(NVL(lines.po_release_id, lines.po_header_id),
			NULL, NULL, 201)                              REF_DOC_APPLICATION_ID
		,DECODE(lines.po_release_id, NULL,
		   DECODE(lines.po_header_id, NULL, NULL,
			  'PURCHASE_ORDER'), 'RELEASE')               REF_DOC_ENTITY_CODE
		,DECODE(lines.po_release_id, NULL,
		   DECODE(lines.po_header_id, NULL, NULL,
			   'PO_PA'), 'RELEASE')                       REF_DOC_EVENT_CLASS_CODE
		,lines.SUMMARY_TAX_LINE_ID 			      SUMMARY_TAX_LINE_ID
		,lines.TAX                                            TAX
		,DECODE(lines.line_type_lookup_code, 'TAX',
		  RANK() OVER (PARTITION BY inv.invoice_id,
				lines.line_type_lookup_code
				ORDER BY lines.line_number), NULL)    SUMMARY_TAX_LINE_NUMBER
		,lines.tax_rate
		,lines.tax_rate_code
		,lines.tax_rate_id
		,lines.tax_regime_code
		,lines.tax_status_code
		,lines.tax_jurisdiction_code
		,lines.line_number                                    TRX_LINE_ID
		,lines.line_number                                    TRX_LINE_NUMBER
		,lines.default_dist_ccid                              ACCOUNT_CCID
		,lines.amount                                         TAX_AMT
		,lines.base_amount                                    TAX_AMT_TAX_CURR
		,lines.base_amount                                    TAX_AMT_FUNCL_CURR
		,lines.attribute_category
		,lines.attribute1
		,lines.attribute2
		,lines.attribute3
		,lines.attribute4
		,lines.attribute5
		,lines.attribute6
		,lines.attribute7
		,lines.attribute8
		,lines.attribute9
		,lines.attribute10
		,lines.attribute11
		,lines.attribute12
		,lines.attribute13
		,lines.attribute14
		,lines.attribute15
		,lines.global_attribute_category
		,lines.global_attribute1
		,lines.global_attribute2
		,lines.global_attribute3
		,lines.global_attribute4
		,lines.global_attribute5
		,lines.global_attribute6
		,lines.global_attribute7
		,lines.global_attribute8
		,lines.global_attribute9
		,lines.global_attribute10
		,lines.global_attribute11
		,lines.global_attribute12
		,lines.global_attribute13
		,lines.global_attribute14
		,lines.global_attribute15
		,lines.global_attribute16
		,lines.global_attribute17
		,lines.global_attribute18
		,lines.global_attribute19
		,lines.global_attribute20
		,CASE
		  WHEN lines.line_type_lookup_code <> 'TAX'
		   THEN NULL
		  WHEN NOT EXISTS
		    (SELECT /*+ index(dists AP_INVOICE_DISTRIBUTIONS_U1) */ 1
		       FROM AP_INV_DISTS_TARGET dists
		      WHERE dists.invoice_id = lines.invoice_id
			AND dists.invoice_line_number = lines.line_number
			AND dists.charge_applicable_to_dist_id IS NOT NULL
		     )
		   THEN 'Y'
		  ELSE  'N'
		END                                                   TAX_ONLY_LINE_FLAG
		,lines.total_rec_tax_amount                           TOTAL_REC_TAX_AMT
		,lines.total_nrec_tax_amount                          TOTAL_NREC_TAX_AMT
		,lines.total_rec_tax_amt_funcl_curr
		,lines.total_nrec_tax_amt_funcl_curr
		,inv.vendor_id 					      SHIP_THIRD_PTY_ACCT_ID
		,inv.vendor_site_id				      SHIP_THIRD_PTY_ACCT_SITE_ID
		,inv.vendor_id 					      BILL_THIRD_PTY_ACCT_ID
		,inv.vendor_site_id				      BILL_THIRD_PTY_ACCT_SITE_ID
		,DECODE(lines.discarded_flag, 'Y', 'Y', 'N')          CANCEL_FLAG
		,DECODE(lines.line_source,'MANUAL LINE ENTRY','Y','N')    MANUALLY_ENTERED_FLAG  --BUG7146063
		,DECODE(lines.line_source,'MANUAL LINE ENTRY','TAX_AMOUNT',NULL)    LAST_MANUAL_ENTRY  --BUG7146063
	   FROM ap_invoices_all          inv,
		xla_upgrade_dates        upd,
		fnd_currencies           fnd_curr,
		fnd_document_sequences   fds,
		ap_invoice_lines_all     lines,
		po_line_locations_all    poll,
		zx_party_tax_profile     ptp
          WHERE inv.rowid BETWEEN p_start_rowid AND p_end_rowid
            AND upd.ledger_id = inv.set_of_books_id
            AND (TRUNC(inv.invoice_date) between upd.start_date and upd.end_date)
            AND fnd_curr.currency_code = inv.invoice_currency_code
            AND inv.doc_sequence_id = fds.doc_sequence_id(+)
            AND lines.invoice_id = inv.invoice_id
            AND poll.line_location_id(+) = lines.po_line_location_id
            AND ptp.party_type_code = 'OU'
            AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,lines.org_id)
            AND NVL(inv.historical_flag, 'N') = 'Y'
            AND NOT EXISTS
               (SELECT 1 FROM zx_lines_Det_Factors zxdet
		WHERE zxdet.APPLICATION_ID   = 200
		  AND zxdet.ENTITY_CODE	     = 'AP_INVOICES'
		  AND zxdet.event_class_code   = DECODE(inv.INVOICE_TYPE_LOOKUP_CODE,
                                              'STANDARD', 'STANDARD INVOICES',
					      'CREDIT'  , 'STANDARD INVOICES',
				              'DEBIT'   , 'STANDARD INVOICES',
			                      'MIXED'   , 'STANDARD INVOICES',
			                      'ADJUSTMENT','STANDARD INVOICES',
					      'PO PRICE ADJUST','STANDARD INVOICES',
				 	      'INVOICE REQUEST','STANDARD INVOICES',
					      'CREDIT MEMO REQUEST','STANDARD INVOICES',
				              'RETAINAGE RELEASE'  ,'STANDARD INVOICES',
				              'PREPAYMENT', 'PREPAYMENT INVOICES',
				              'EXPENSE REPORT', 'EXPENSE REPORTS',
				              'INTEREST INVOICE', 'INTEREST INVOICES','NA')
		  AND zxdet.TRX_ID	     = inv.invoice_id);


 -- Insert data into zx_lines and zx_rec_nrec_dist
 --
  INSERT ALL
      INTO ZX_REC_NREC_DIST(
		  TAX_LINE_ID
		  ,REC_NREC_TAX_DIST_ID
		  ,REC_NREC_TAX_DIST_NUMBER
		  ,APPLICATION_ID
		  ,CONTENT_OWNER_ID
		  ,CURRENCY_CONVERSION_DATE
		  ,CURRENCY_CONVERSION_RATE
		  ,CURRENCY_CONVERSION_TYPE
		  ,ENTITY_CODE
		  ,EVENT_CLASS_CODE
		  ,EVENT_TYPE_CODE
		  ,LEDGER_ID
		  ,MINIMUM_ACCOUNTABLE_UNIT
		  ,PRECISION
		  ,RECORD_TYPE_CODE
		  ,REF_DOC_APPLICATION_ID
		  ,REF_DOC_ENTITY_CODE
		  ,REF_DOC_EVENT_CLASS_CODE
		  ,REF_DOC_LINE_ID
		  ,REF_DOC_TRX_ID
		  ,REF_DOC_TRX_LEVEL_TYPE
		  ,SUMMARY_TAX_LINE_ID
		  ,TAX
		  ,TAX_APPORTIONMENT_LINE_NUMBER
		  ,TAX_CURRENCY_CODE
		  ,TAX_CURRENCY_CONVERSION_DATE
		  ,TAX_CURRENCY_CONVERSION_RATE
		  ,TAX_CURRENCY_CONVERSION_TYPE
		  ,TAX_EVENT_CLASS_CODE
		  ,TAX_EVENT_TYPE_CODE
		  ,TAX_ID
		  ,TAX_LINE_NUMBER
		  ,TAX_RATE
		  ,TAX_RATE_CODE
		  ,TAX_RATE_ID
		  ,TAX_REGIME_CODE
		  ,TAX_REGIME_ID
		  ,TAX_STATUS_CODE
		  ,TAX_STATUS_ID
		  ,TRX_CURRENCY_CODE
		  ,TRX_ID
		  ,TRX_LEVEL_TYPE
		  ,TRX_LINE_ID
		  ,TRX_LINE_NUMBER
		  ,TRX_NUMBER
		  ,UNIT_PRICE
		  ,ACCOUNT_CCID
		  ,AWARD_ID
		  ,EXPENDITURE_ITEM_DATE
		  ,EXPENDITURE_ORGANIZATION_ID
		  ,EXPENDITURE_TYPE
		  ,GL_DATE
		  ,INTENDED_USE
		  ,ITEM_DIST_NUMBER
		  ,PROJECT_ID
		  ,REC_NREC_RATE
		  ,REC_NREC_TAX_AMT
		  ,REC_NREC_TAX_AMT_FUNCL_CURR
		  ,REC_NREC_TAX_AMT_TAX_CURR
		  ,RECOVERY_RATE_CODE
		  ,RECOVERY_TYPE_CODE
		  ,REF_DOC_DIST_ID
		  ,REVERSED_TAX_DIST_ID
		  ,TASK_ID
		  ,TAXABLE_AMT_FUNCL_CURR
		  ,TAXABLE_AMT_TAX_CURR
		  ,TRX_LINE_DIST_AMT
		  ,TRX_LINE_DIST_ID
		  ,TRX_LINE_DIST_QTY
		  ,TRX_LINE_DIST_TAX_AMT
		  ,TAXABLE_AMT
		  ,ATTRIBUTE_CATEGORY
		  ,ATTRIBUTE1
		  ,ATTRIBUTE2
		  ,ATTRIBUTE3
		  ,ATTRIBUTE4
		  ,ATTRIBUTE5
		  ,ATTRIBUTE6
		  ,ATTRIBUTE7
		  ,ATTRIBUTE8
		  ,ATTRIBUTE9
		  ,ATTRIBUTE10
		  ,ATTRIBUTE11
		  ,ATTRIBUTE12
		  ,ATTRIBUTE13
		  ,ATTRIBUTE14
		  ,ATTRIBUTE15
		  ,GLOBAL_ATTRIBUTE_CATEGORY
		  ,GLOBAL_ATTRIBUTE1
		  ,GLOBAL_ATTRIBUTE2
		  ,GLOBAL_ATTRIBUTE3
		  ,GLOBAL_ATTRIBUTE4
		  ,GLOBAL_ATTRIBUTE5
		  ,GLOBAL_ATTRIBUTE6
		  ,GLOBAL_ATTRIBUTE7
		  ,GLOBAL_ATTRIBUTE8
		  ,GLOBAL_ATTRIBUTE9
		  ,GLOBAL_ATTRIBUTE10
		  ,GLOBAL_ATTRIBUTE11
		  ,GLOBAL_ATTRIBUTE12
		  ,GLOBAL_ATTRIBUTE13
		  ,GLOBAL_ATTRIBUTE14
		  ,GLOBAL_ATTRIBUTE15
		  ,GLOBAL_ATTRIBUTE16
		  ,GLOBAL_ATTRIBUTE17
		  ,GLOBAL_ATTRIBUTE18
		  ,GLOBAL_ATTRIBUTE19
		  ,GLOBAL_ATTRIBUTE20
		  ,HISTORICAL_FLAG
		  ,OVERRIDDEN_FLAG
		  ,SELF_ASSESSED_FLAG
		  ,TAX_APPORTIONMENT_FLAG
		  ,TAX_ONLY_LINE_FLAG
		  ,INCLUSIVE_FLAG
		  ,MRC_TAX_DIST_FLAG
		  ,REC_TYPE_RULE_FLAG
		  ,NEW_REC_RATE_CODE_FLAG
		  ,RECOVERABLE_FLAG
		  ,REVERSE_FLAG
		  ,REC_RATE_DET_RULE_FLAG
		  ,BACKWARD_COMPATIBILITY_FLAG
		  ,FREEZE_FLAG
		  ,POSTING_FLAG
		  ,LEGAL_ENTITY_ID
		  ,CREATED_BY
		  ,CREATION_DATE
		  ,LAST_UPDATE_DATE
		  ,LAST_UPDATE_LOGIN
		  ,LAST_UPDATED_BY
		  ,OBJECT_VERSION_NUMBER
		  ,ORIG_AP_CHRG_DIST_NUM
		  ,ORIG_AP_CHRG_DIST_ID
		  ,ORIG_AP_TAX_DIST_NUM
		  ,ORIG_AP_TAX_DIST_ID
		  ,INTERNAL_ORGANIZATION_ID
		  ,DEF_REC_SETTLEMENT_OPTION_CODE
		  ,ACCOUNT_SOURCE_TAX_RATE_ID
		  ,RECOVERY_RATE_ID
		)
	 VALUES(
		 ZX_LINES_S.NEXTVAL
		 ,REC_NREC_TAX_DIST_ID
		 ,REC_NREC_TAX_DIST_NUMBER
		 ,200
		 ,CONTENT_OWNER_ID
		 ,CURRENCY_CONVERSION_DATE
		 ,CURRENCY_CONVERSION_RATE
		 ,CURRENCY_CONVERSION_TYPE
		 ,'AP_INVOICES'
		 ,EVENT_CLASS_CODE
		 ,EVENT_TYPE_CODE
		 ,AP_LEDGER_ID
		 ,MINIMUM_ACCOUNTABLE_UNIT
		 ,PRECISION
		 ,'MIGRATED'
		 ,REF_DOC_APPLICATION_ID
		 ,REF_DOC_ENTITY_CODE
		 ,REF_DOC_EVENT_CLASS_CODE
		 ,REF_DOC_LINE_ID
		 ,REF_DOC_TRX_ID
		 ,REF_DOC_TRX_LEVEL_TYPE
		 ,SUMMARY_TAX_LINE_ID
		 ,TAX
		 ,TAX_APPORTIONMENT_LINE_NUMBER
		 ,TAX_CURRENCY_CODE
		 ,TAX_CURRENCY_CONVERSION_DATE
		 ,TAX_CURRENCY_CONVERSION_RATE
		 ,TAX_CURRENCY_CONVERSION_TYPE
		 ,TAX_EVENT_CLASS_CODE
		 ,'VALIDATE'
		 ,TAX_ID
		 ,TAX_LINE_NUMBER
		 ,TAX_RATE
		 ,TAX_RATE_CODE
		 ,TAX_RATE_ID
		 ,TAX_REGIME_CODE
		 ,TAX_REGIME_ID
		 ,TAX_STATUS_CODE
		 ,TAX_STATUS_ID
		 ,TRX_CURRENCY_CODE
		 ,TRX_ID
		 ,'LINE'
		 ,TRX_LINE_ID
		 ,TRX_LINE_NUMBER
		 ,TRX_NUMBER
		 ,UNIT_PRICE
		 ,ACCOUNT_CCID
		 ,AWARD_ID
		 ,EXPENDITURE_ITEM_DATE
		 ,EXPENDITURE_ORGANIZATION_ID
		 ,EXPENDITURE_TYPE
		 ,GL_DATE
		 ,INTENDED_USE
		 ,ITEM_DIST_NUMBER
		 ,PROJECT_ID
		 ,100
		 ,REC_NREC_TAX_AMT
		 ,REC_NREC_TAX_AMT_FUNCL_CURR
		 ,REC_NREC_TAX_AMT_TAX_CURR
		 ,RECOVERY_RATE_CODE
		 ,RECOVERY_TYPE_CODE
		 ,REF_DOC_DIST_ID
		 ,REVERSED_TAX_DIST_ID
		 ,TASK_ID
		 ,TAXABLE_AMT_FUNCL_CURR
		 ,TAXABLE_AMT_TAX_CURR
		 ,TRX_LINE_DIST_AMT
		 ,TRX_LINE_DIST_ID
		 ,TRX_LINE_DIST_QTY
		 ,TRX_LINE_DIST_TAX_AMT
		 ,TAXABLE_AMT
		 ,ATTRIBUTE_CATEGORY
		 ,ATTRIBUTE1
		 ,ATTRIBUTE2
		 ,ATTRIBUTE3
		 ,ATTRIBUTE4
		 ,ATTRIBUTE5
		 ,ATTRIBUTE6
		 ,ATTRIBUTE7
		 ,ATTRIBUTE8
		 ,ATTRIBUTE9
		 ,ATTRIBUTE10
		 ,ATTRIBUTE11
		 ,ATTRIBUTE12
		 ,ATTRIBUTE13
		 ,ATTRIBUTE14
		 ,ATTRIBUTE15
		 ,GLOBAL_ATTRIBUTE_CATEGORY
		 ,GLOBAL_ATTRIBUTE1
		 ,GLOBAL_ATTRIBUTE2
		 ,GLOBAL_ATTRIBUTE3
		 ,GLOBAL_ATTRIBUTE4
		 ,GLOBAL_ATTRIBUTE5
		 ,GLOBAL_ATTRIBUTE6
		 ,GLOBAL_ATTRIBUTE7
		 ,GLOBAL_ATTRIBUTE8
		 ,GLOBAL_ATTRIBUTE9
		 ,GLOBAL_ATTRIBUTE10
		 ,GLOBAL_ATTRIBUTE11
		 ,GLOBAL_ATTRIBUTE12
		 ,GLOBAL_ATTRIBUTE13
		 ,GLOBAL_ATTRIBUTE14
		 ,GLOBAL_ATTRIBUTE15
		 ,GLOBAL_ATTRIBUTE16
		 ,GLOBAL_ATTRIBUTE17
		 ,GLOBAL_ATTRIBUTE18
		 ,GLOBAL_ATTRIBUTE19
		 ,GLOBAL_ATTRIBUTE20
		 ,'Y'
		 ,'N'
		 ,'N'
		 ,'Y'
		 ,TAX_ONLY_LINE_FLAG
		 ,'N'
		 ,'N'
		 ,'N'
		 ,'N'
		 ,RECOVERABLE_FLAG
		 ,REVERSE_FLAG
		 ,'N'
		 ,'N'
		 ,'N'
		 ,POSTING_FLAG
		 ,LEGAL_ENTITY_ID
		 ,1
		 ,sysdate
		 ,sysdate
		 ,1
		 ,1
		 ,1
		 ,ORIG_AP_CHRG_DIST_NUM
		 ,ORIG_AP_CHRG_DIST_ID
		 ,ORIG_AP_TAX_DIST_NUM
		 ,ORIG_AP_TAX_DIST_ID
		 ,INTERNAL_ORGANIZATION_ID
		 ,DEF_REC_SETTLEMENT_OPTION_CODE
		 ,ACCOUNT_SOURCE_TAX_RATE_ID
		 ,RECOVERY_RATE_ID
		 )
   INTO ZX_LINES(
		  TAX_LINE_ID
		  ,TAX_LINE_NUMBER
		  ,APPLICATION_ID
		  ,CONTENT_OWNER_ID
		  ,CURRENCY_CONVERSION_DATE
		  ,CURRENCY_CONVERSION_RATE
		  ,CURRENCY_CONVERSION_TYPE
		  ,ENTITY_CODE
		  ,EVENT_CLASS_CODE
		  ,EVENT_TYPE_CODE
		  ,LEDGER_ID
		  ,MINIMUM_ACCOUNTABLE_UNIT
		  ,PRECISION
		  ,RECORD_TYPE_CODE
		  ,REF_DOC_APPLICATION_ID
		  ,REF_DOC_ENTITY_CODE
		  ,REF_DOC_EVENT_CLASS_CODE
		  ,REF_DOC_LINE_ID
		  ,REF_DOC_TRX_ID
		  ,REF_DOC_TRX_LEVEL_TYPE
		  ,SUMMARY_TAX_LINE_ID
		  ,TAX
		  ,TAX_APPORTIONMENT_LINE_NUMBER
		  ,TAX_CURRENCY_CODE
		  ,TAX_CURRENCY_CONVERSION_DATE
		  ,TAX_CURRENCY_CONVERSION_RATE
		  ,TAX_CURRENCY_CONVERSION_TYPE
		  ,TAX_EVENT_CLASS_CODE
		  ,TAX_EVENT_TYPE_CODE
		  ,TAX_ID
		  ,TAX_RATE
		  ,TAX_RATE_CODE
		  ,TAX_RATE_ID
		  ,TAX_REGIME_CODE
		  ,TAX_REGIME_ID
		  ,TAX_STATUS_CODE
		  ,TAX_STATUS_ID
		  ,TRX_CURRENCY_CODE
		  ,TRX_ID
		  ,TRX_LEVEL_TYPE
		  ,TRX_LINE_ID
		  ,TRX_LINE_NUMBER
		  ,TRX_NUMBER
		  ,UNIT_PRICE
		  ,TAX_RATE_TYPE
		  ,ADJUSTED_DOC_APPLICATION_ID
		  ,ADJUSTED_DOC_ENTITY_CODE
		  ,ADJUSTED_DOC_EVENT_CLASS_CODE
		  ,ADJUSTED_DOC_LINE_ID
		  ,ADJUSTED_DOC_TRX_ID
		  ,ADJUSTED_DOC_TRX_LEVEL_TYPE
		  ,APPLIED_FROM_APPLICATION_ID
		  ,APPLIED_FROM_ENTITY_CODE
		  ,APPLIED_FROM_EVENT_CLASS_CODE
		  ,APPLIED_FROM_LINE_ID
		  ,APPLIED_FROM_TRX_ID
		  ,APPLIED_FROM_TRX_LEVEL_TYPE
		  ,APPLIED_TO_APPLICATION_ID
		  ,APPLIED_TO_ENTITY_CODE
		  ,APPLIED_TO_EVENT_CLASS_CODE
		  ,APPLIED_TO_LINE_ID
		  ,APPLIED_TO_TRX_ID
		  ,APPLIED_TO_TRX_LEVEL_TYPE
		  ,INTERNAL_ORGANIZATION_ID
		  ,LINE_AMT
		  ,LINE_ASSESSABLE_VALUE
		  ,NREC_TAX_AMT
		  ,NREC_TAX_AMT_FUNCL_CURR
		  ,NREC_TAX_AMT_TAX_CURR
		  ,REC_TAX_AMT
		  ,REC_TAX_AMT_FUNCL_CURR
		  ,REC_TAX_AMT_TAX_CURR
		  ,TAX_AMT
		  ,TAX_AMT_FUNCL_CURR
		  ,TAX_AMT_TAX_CURR
		  ,TAX_CALCULATION_FORMULA
		  ,TAX_DATE
		  ,TAX_DETERMINE_DATE
		  ,TAX_POINT_DATE
		  ,TAXABLE_AMT
		  ,TAXABLE_AMT_FUNCL_CURR
		  ,TAXABLE_AMT_TAX_CURR
		  ,TAXABLE_BASIS_FORMULA
		  ,TRX_DATE
		  ,TRX_LINE_DATE
		  ,TRX_LINE_QUANTITY
		  ,HISTORICAL_FLAG
		  ,OVERRIDDEN_FLAG
		  ,SELF_ASSESSED_FLAG
		  ,TAX_APPORTIONMENT_FLAG
		  ,TAX_ONLY_LINE_FLAG
		  ,TAX_AMT_INCLUDED_FLAG
		  ,MRC_TAX_LINE_FLAG
		  ,OFFSET_FLAG
		  ,PROCESS_FOR_RECOVERY_FLAG
		  ,COMPOUNDING_TAX_FLAG
		  ,ORIG_TAX_AMT_INCLUDED_FLAG
		  ,ORIG_SELF_ASSESSED_FLAG
		  ,CANCEL_FLAG
		  ,PURGE_FLAG
		  ,DELETE_FLAG
		  ,MANUALLY_ENTERED_FLAG
		  ,LAST_MANUAL_ENTRY  --BUG7146063
		  ,REPORTING_ONLY_FLAG
		  ,FREEZE_UNTIL_OVERRIDDEN_FLAG
		  ,COPIED_FROM_OTHER_DOC_FLAG
		  ,RECALC_REQUIRED_FLAG
		  ,SETTLEMENT_FLAG
		  ,ITEM_DIST_CHANGED_FLAG
		  ,ASSOCIATED_CHILD_FROZEN_FLAG
		  ,COMPOUNDING_DEP_TAX_FLAG
		  ,ENFORCE_FROM_NATURAL_ACCT_FLAG
		  ,ATTRIBUTE_CATEGORY
		  ,ATTRIBUTE1
		  ,ATTRIBUTE2
		  ,ATTRIBUTE3
		  ,ATTRIBUTE4
		  ,ATTRIBUTE5
		  ,ATTRIBUTE6
		  ,ATTRIBUTE7
		  ,ATTRIBUTE8
		  ,ATTRIBUTE9
		  ,ATTRIBUTE10
		  ,ATTRIBUTE11
		  ,ATTRIBUTE12
		  ,ATTRIBUTE13
		  ,ATTRIBUTE14
		  ,ATTRIBUTE15
		  ,GLOBAL_ATTRIBUTE_CATEGORY
		  ,GLOBAL_ATTRIBUTE1
		  ,GLOBAL_ATTRIBUTE2
		  ,GLOBAL_ATTRIBUTE3
		  ,GLOBAL_ATTRIBUTE4
		  ,GLOBAL_ATTRIBUTE5
		  ,GLOBAL_ATTRIBUTE6
		  ,GLOBAL_ATTRIBUTE7
		  ,GLOBAL_ATTRIBUTE8
		  ,GLOBAL_ATTRIBUTE9
		  ,GLOBAL_ATTRIBUTE10
		  ,GLOBAL_ATTRIBUTE11
		  ,GLOBAL_ATTRIBUTE12
		  ,GLOBAL_ATTRIBUTE13
		  ,GLOBAL_ATTRIBUTE14
		  ,GLOBAL_ATTRIBUTE15
		  ,LEGAL_ENTITY_ID
		  ,CREATED_BY
		  ,CREATION_DATE
		  ,LAST_UPDATE_DATE
		  ,LAST_UPDATE_LOGIN
		  ,LAST_UPDATED_BY
		  ,OBJECT_VERSION_NUMBER
		  ,MULTIPLE_JURISDICTIONS_FLAG
		  ,LEGAL_REPORTING_STATUS
		  ,ACCOUNT_SOURCE_TAX_RATE_ID
		  )
	  VALUES (
		  ZX_LINES_S.NEXTVAL
		  ,TAX_LINE_NUMBER
		  ,200
		  ,CONTENT_OWNER_ID
		  ,CURRENCY_CONVERSION_DATE
		  ,CURRENCY_CONVERSION_RATE
		  ,CURRENCY_CONVERSION_TYPE
		  ,'AP_INVOICES'
		  ,EVENT_CLASS_CODE
		  ,EVENT_TYPE_CODE
		  ,AP_LEDGER_ID
		  ,MINIMUM_ACCOUNTABLE_UNIT
		  ,PRECISION
		  ,'MIGRATED'
		  ,REF_DOC_APPLICATION_ID
		  ,REF_DOC_ENTITY_CODE
		  ,REF_DOC_EVENT_CLASS_CODE
		  ,REF_DOC_LINE_ID
		  ,REF_DOC_TRX_ID
		  ,REF_DOC_TRX_LEVEL_TYPE
		  ,SUMMARY_TAX_LINE_ID
		  ,TAX
		  ,TAX_APPORTIONMENT_LINE_NUMBER
		  ,TAX_CURRENCY_CODE
		  ,TAX_CURRENCY_CONVERSION_DATE
		  ,TAX_CURRENCY_CONVERSION_RATE
		  ,TAX_CURRENCY_CONVERSION_TYPE
		  ,TAX_EVENT_CLASS_CODE
		  ,'VALIDATE'
		  ,TAX_ID
		  ,TAX_RATE
		  ,TAX_RATE_CODE
		  ,TAX_RATE_ID
		  ,TAX_REGIME_CODE
		  ,TAX_REGIME_ID
		  ,TAX_STATUS_CODE
		  ,TAX_STATUS_ID
		  ,TRX_CURRENCY_CODE
		  ,TRX_ID
		  ,'LINE'
		  ,TRX_LINE_ID
		  ,TRX_LINE_NUMBER
		  ,TRX_NUMBER
		  ,UNIT_PRICE
		  ,NULL
		  ,ADJUSTED_DOC_APPLICATION_ID
		  ,ADJUSTED_DOC_ENTITY_CODE
		  ,ADJUSTED_DOC_EVENT_CLASS_CODE
		  ,ADJUSTED_DOC_LINE_ID
		  ,ADJUSTED_DOC_TRX_ID
		  ,ADJUSTED_DOC_TRX_LEVEL_TYPE
		  ,APPLIED_FROM_APPLICATION_ID
		  ,APPLIED_FROM_ENTITY_CODE
		  ,APPLIED_FROM_EVENT_CLASS_CODE
		  ,APPLIED_FROM_LINE_ID
		  ,APPLIED_FROM_TRX_ID
		  ,APPLIED_FROM_TRX_LEVEL_TYPE
		  ,APPLIED_TO_APPLICATION_ID
		  ,APPLIED_TO_ENTITY_CODE
		  ,APPLIED_TO_EVENT_CLASS_CODE
		  ,APPLIED_TO_LINE_ID
		  ,APPLIED_TO_TRX_ID
		  ,APPLIED_TO_TRX_LEVEL_TYPE
		  ,INTERNAL_ORGANIZATION_ID
		  ,LINE_AMT
		  ,ASSESSABLE_VALUE
		  ,DECODE(AP_DIST_LOOKUP_CODE,
		     'NONREC_TAX', REC_NREC_TAX_AMT, NULL)
		  ,DECODE(AP_DIST_LOOKUP_CODE,
		     'NONREC_TAX', REC_NREC_TAX_AMT_FUNCL_CURR, NULL)
		  ,DECODE(AP_DIST_LOOKUP_CODE,
		     'NONREC_TAX', REC_NREC_TAX_AMT_TAX_CURR, NULL)
		  ,DECODE(AP_DIST_LOOKUP_CODE,
		     'REC_TAX', REC_NREC_TAX_AMT, NULL)
		  ,DECODE(AP_DIST_LOOKUP_CODE,
		     'REC_TAX', REC_NREC_TAX_AMT_FUNCL_CURR, NULL)
		  ,DECODE(AP_DIST_LOOKUP_CODE,
		     'REC_TAX', REC_NREC_TAX_AMT_TAX_CURR, NULL)
		  ,TAX_AMT
		  ,TAX_AMT_FUNCL_CURR
		  ,TAX_AMT_TAX_CURR
		  ,'STANDARD_TC'
		  ,TAX_DATE
		  ,TAX_DETERMINE_DATE
		  ,TAX_POINT_DATE
		  ,TAXABLE_AMT
		  ,TAXABLE_AMT_FUNCL_CURR
		  ,TAXABLE_AMT_TAX_CURR
		  ,'STANDARD_TB'
		  ,TRX_DATE
		  ,TRX_LINE_DATE
		  ,TRX_LINE_QUANTITY
		  ,'Y'
		  ,'N'
		  ,'N'
		  ,'Y'
		  ,TAX_ONLY_LINE_FLAG
		  ,'N'
		  ,'N'
		  ,OFFSET_FLAG
		  ,'N'
		  ,'N'
		  ,'N'
		  ,'N'
		  ,CANCEL_FLAG
		  ,'N'
		  ,'N'
		  ,MANUALLY_ENTERED_FLAG
		  ,LAST_MANUAL_ENTRY  --BUG7146063
		  ,'N'
		  ,'N'
		  ,'N'
		  ,'N'
		  ,'N'
		  ,'N'
		  ,'N'
		  ,'N'
		  ,'N'
		  ,ATTRIBUTE_CATEGORY
		  ,ATTRIBUTE1
		  ,ATTRIBUTE2
		  ,ATTRIBUTE3
		  ,ATTRIBUTE4
		  ,ATTRIBUTE5
		  ,ATTRIBUTE6
		  ,ATTRIBUTE7
		  ,ATTRIBUTE8
		  ,ATTRIBUTE9
		  ,ATTRIBUTE10
		  ,ATTRIBUTE11
		  ,ATTRIBUTE12
		  ,ATTRIBUTE13
		  ,ATTRIBUTE14
		  ,ATTRIBUTE15
		  ,GLOBAL_ATTRIBUTE_CATEGORY
		  ,GLOBAL_ATTRIBUTE1
		  ,GLOBAL_ATTRIBUTE2
		  ,GLOBAL_ATTRIBUTE3
		  ,GLOBAL_ATTRIBUTE4
		  ,GLOBAL_ATTRIBUTE5
		  ,GLOBAL_ATTRIBUTE6
		  ,GLOBAL_ATTRIBUTE7
		  ,GLOBAL_ATTRIBUTE8
		  ,GLOBAL_ATTRIBUTE9
		  ,GLOBAL_ATTRIBUTE10
		  ,GLOBAL_ATTRIBUTE11
		  ,GLOBAL_ATTRIBUTE12
		  ,GLOBAL_ATTRIBUTE13
		  ,GLOBAL_ATTRIBUTE14
		  ,GLOBAL_ATTRIBUTE15
		  ,LEGAL_ENTITY_ID
		  ,1
		  ,sysdate
		  ,sysdate
		  ,1
		  ,1
		  ,1
		  ,'N'
		  ,LEGAL_REPORTING_STATUS
		  ,ACCOUNT_SOURCE_TAX_RATE_ID
	  )
 SELECT /*+ ORDERED NO_EXPAND ROWID(inv) swap_join_inputs(upd) use_nl(fnd_curr)
	    use_nl_with_index(ap_dists AP_INVOICE_DISTRIBUTIONS_N27)
	    use_nl_with_index(ap_dists1 AP_INVOICE_DISTRIBUTIONS_U2)
	    use_nl_with_index(lines1 AP_INVOICE_LINES_U1)
	    use_nl_with_index(taxes ZX_TAXES_B_U2)
	    use_nl_with_index(rates ZX_RATES_B_N2)
	    use_nl_with_index(regimes ZX_REGIMES_B_U2)
	    use_nl_with_index(status ZX_STATUS_B_U2)
	    use_nl_with_index(ptp ZX_PARTY_TAX_PROFILE_U2) */
	NVL(lines1.org_id,-99)                                        INTERNAL_ORGANIZATION_ID
	,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE,
                  'STANDARD', 'STANDARD INVOICES',   --Bug 5859937
		  'CREDIT'  , 'STANDARD INVOICES',   --Bug 5859937
		  'DEBIT'   , 'STANDARD INVOICES',   --Bug 5859937
		  'MIXED'   , 'STANDARD INVOICES',   --Bug 5859937
		  'ADJUSTMENT','STANDARD INVOICES',  --Bug 5859937
		  'PO PRICE ADJUST','STANDARD INVOICES', --Bug 5859937
		  'INVOICE REQUEST','STANDARD INVOICES', --Bug 5859937
		  'CREDIT MEMO REQUEST','STANDARD INVOICES',--Bug 5859937
 	          'RETAINAGE RELEASE'  ,'STANDARD INVOICES',--Bug 5859937
                  'PREPAYMENT', 'PREPAYMENT INVOICES',
                  'EXPENSE REPORT', 'EXPENSE REPORTS',
                  'INTEREST INVOICE', 'INTEREST INVOICES','NA')       EVENT_CLASS_CODE
	,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE,
		'STANDARD','STANDARD INVOICE CREATED',
		'PREPAYMENT','PREPAYMENT INVOICE CREATED',
		'EXPENSE REPORT','EXPENSE REPORT CREATED',
		'INTEREST INVOICE','INTEREST INVOICE CREATED','NA')   EVENT_TYPE_CODE
	,(CASE WHEN inv.invoice_type_lookup_code in
		   ('ADJUSTMENT','CREDIT','DEBIT','INTEREST',
			'MIXED','QUICKDEFAULT','PO PRICE ADJUST',
			'QUICKMATCH','STANDARD','AWT')
			  THEN 'PURCHASE_TRANSACTION'
			  WHEN (inv.invoice_type_lookup_code =
					'PREPAYMENT')
			  THEN  'PURCHASE_PREPAYMENTTRANSACTION'
			  WHEN  (inv.invoice_type_lookup_code =
					'EXPENSE REPORT')
			  THEN  'EXPENSE_REPORT'
			  ELSE   NULL
	  END)                      				      TAX_EVENT_CLASS_CODE
	,lines1.invoice_id 				              TRX_ID
	,NVL(inv.invoice_date,sysdate)			   	      TRX_DATE
	,inv.invoice_currency_code                    	              TRX_CURRENCY_CODE
	,NVL(inv.legal_entity_id, -99)               	              LEGAL_ENTITY_ID
	,inv.invoice_num                              	              TRX_NUMBER
	,(RANK() OVER (PARTITION BY inv.invoice_id ORDER BY
		     ap_dists1.invoice_line_number,
		     ap_dists.invoice_distribution_id))	              TAX_LINE_NUMBER
	,lines1.accounting_date                        	              TRX_LINE_DATE
	,NVL(lines1.amount,0)                                 	      LINE_AMT
	,NVL(lines1.quantity_invoiced, 0)                     	      TRX_LINE_QUANTITY
	,lines1.UNIT_PRICE                             	              UNIT_PRICE
	,DECODE(lines1.prepay_invoice_id, NULL, NULL, 200)            APPLIED_FROM_APPLICATION_ID
	,DECODE(lines1.prepay_invoice_id, NULL, NULL,
		'AP_INVOICES')                                        APPLIED_FROM_ENTITY_CODE
	,DECODE(lines1.prepay_invoice_id, NULL, NULL,
		'PREPAYMENT INVOICES')                                APPLIED_FROM_EVENT_CLASS_CODE
	,lines1.prepay_invoice_id                      	              APPLIED_FROM_TRX_ID
	,lines1.prepay_line_number                    	              APPLIED_FROM_LINE_ID
	,DECODE(lines1.corrected_inv_id, NULL, NULL, 200)             ADJUSTED_DOC_APPLICATION_ID
	,DECODE(lines1.corrected_inv_id, NULL, NULL,
		'AP_INVOICES')                                        ADJUSTED_DOC_ENTITY_CODE
	,DECODE(lines1.corrected_inv_id, NULL, NULL,
		'STANDARD INVOICES')                                  ADJUSTED_DOC_EVENT_CLASS_CODE
	,lines1.corrected_inv_id                       	              ADJUSTED_DOC_TRX_ID
	,lines1.Corrected_Line_Number                  	              ADJUSTED_DOC_LINE_ID
	,DECODE(lines1.rcv_transaction_id, NULL, NULL, 707) 	      APPLIED_TO_APPLICATION_ID
	,DECODE(lines1.rcv_transaction_id, NULL, NULL,
		'RCV_ACCOUNTING_EVENTS')                              APPLIED_TO_ENTITY_CODE
	,DECODE(lines1.rcv_transaction_id, NULL, NULL,
		'RCPT_REC_INSP')                      	              APPLIED_TO_EVENT_CLASS_CODE
	,lines1.rcv_transaction_id                           	      APPLIED_TO_TRX_ID
	,lines1.rcv_shipment_line_id                         	      APPLIED_TO_LINE_ID
	,DECODE(NVL(lines1.po_release_id,lines1.po_header_id),
		 NULL, NULL, 'SHIPMENT')                     	      REF_DOC_TRX_LEVEL_TYPE
	,NVL(lines1.po_release_id, lines1.po_header_id)  	      REF_DOC_TRX_ID
	,lines1.po_line_location_id                    	              REF_DOC_LINE_ID
	,DECODE(lines1.rcv_transaction_id, NULL, NULL,
		'LINE')                                     	      APPLIED_TO_TRX_LEVEL_TYPE
	,DECODE(lines1.prepay_invoice_id, NULL, NULL,
		'LINE')                                     	      APPLIED_FROM_TRX_LEVEL_TYPE
	,DECODE(lines1.corrected_inv_id, NULL, NULL,
		'LINE')                                	              ADJUSTED_DOC_TRX_LEVEL_TYPE
	,lines1.ASSESSABLE_VALUE
	,ap_dists.DETAIL_TAX_DIST_ID   			              REC_NREC_TAX_DIST_ID
	,ap_dists.line_type_lookup_code                	              AP_DIST_LOOKUP_CODE
	,RANK() OVER (PARTITION BY inv.invoice_id,
		      ap_dists.charge_applicable_to_dist_id
		      ORDER BY
		      ap_dists.line_type_lookup_code desc,
		      ap_dists.invoice_distribution_id)               REC_NREC_TAX_DIST_NUMBER
	,ptp.party_tax_profile_id                                     CONTENT_OWNER_ID
	,inv.exchange_date 				            CURRENCY_CONVERSION_DATE
	,inv.exchange_rate     				        CURRENCY_CONVERSION_RATE
	,inv.exchange_rate_type  				      CURRENCY_CONVERSION_TYPE
	,ap_dists.set_of_books_id 				      AP_LEDGER_ID
	,fnd_curr.minimum_accountable_unit   			      MINIMUM_ACCOUNTABLE_UNIT
	,NVL(fnd_curr.precision, 0)                  		      PRECISION
	,DECODE(NVL(lines1.po_release_id, lines1.po_header_id),
		 NULL, NULL, 201)		                      REF_DOC_APPLICATION_ID
	,DECODE(lines1.po_release_id, NULL,
		 DECODE(lines1.po_header_id, NULL, NULL,
			'PURCHASE_ORDER'), 'RELEASE')                 REF_DOC_ENTITY_CODE
	,DECODE(lines1.po_release_id, NULL,
		 DECODE(lines1.po_header_id, NULL, NULL,
			'PO_PA'), 'RELEASE')                          REF_DOC_EVENT_CLASS_CODE
	,ap_dists.summary_tax_line_id 				      SUMMARY_TAX_LINE_ID
	,rates.TAX 						      TAX
	,RANK() OVER (PARTITION BY inv.invoice_id,
		       ap_dists1.invoice_line_number,
		       rates.tax_regime_code, rates.tax
		       ORDER BY
		       ap_dists.invoice_distribution_id)	      TAX_APPORTIONMENT_LINE_NUMBER
	,taxes.tax_currency_code
	,inv.exchange_date             			      TAX_CURRENCY_CONVERSION_DATE
	,inv.exchange_rate             			      TAX_CURRENCY_CONVERSION_RATE
	,inv.exchange_rate_type        			      TAX_CURRENCY_CONVERSION_TYPE
	,taxes.tax_id
	,rates.percentage_rate 				              TAX_RATE
	,rates.tax_rate_code
	,rates.tax_rate_id
	,rates.tax_regime_code
	,regimes.tax_regime_id
	,rates.tax_status_code
	,status.tax_status_id
	,lines1.line_number                                           TRX_LINE_ID
	,lines1.line_number                                           TRX_LINE_NUMBER
	,ap_dists.dist_code_combination_id  			      ACCOUNT_CCID
	,ap_dists.award_id
	,ap_dists.expenditure_item_date
	,ap_dists.expenditure_organization_id
	,ap_dists.expenditure_type
	,ap_dists.ACCOUNTING_DATE 				      GL_DATE
	,ap_dists.intended_use
	,ap_dists1.distribution_line_number                           ITEM_DIST_NUMBER
	,ap_dists.project_id
	,NVL(ap_dists.amount,0)             			      REC_NREC_TAX_AMT
	,ap_dists.base_amount        				      REC_NREC_TAX_AMT_FUNCL_CURR
	,ap_dists.base_amount        				      REC_NREC_TAX_AMT_TAX_CURR
	,DECODE(ap_dists.line_type_lookup_code,
	       'REC_TAX', 'AD_HOC_RECOVERY', NULL)                    RECOVERY_RATE_CODE
	,DECODE(ap_dists.line_type_lookup_code,
	       'REC_TAX', 'STANDARD', NULL)                           RECOVERY_TYPE_CODE
	,NVL(ap_dists.amount,0)             			      TAX_AMT
	,ap_dists.base_amount        				      TAX_AMT_FUNCL_CURR
	,ap_dists.base_amount        				      TAX_AMT_TAX_CURR
	,ap_dists1.po_distribution_id                                 REF_DOC_DIST_ID
	,ap_dists.parent_reversal_id				      REVERSED_TAX_DIST_ID
	,ap_dists.task_id
	,ap_dists.taxable_base_amount 			              TAXABLE_AMT_FUNCL_CURR
	,ap_dists.taxable_base_amount 			              TAXABLE_AMT_TAX_CURR
	,ap_dists1.amount					      TRX_LINE_DIST_AMT
	,ap_dists1.invoice_distribution_id 			      TRX_LINE_DIST_ID
	,NVL(ap_dists1.quantity_invoiced, 0)			      TRX_LINE_DIST_QTY
	,DECODE(ap_dists.charge_applicable_to_dist_id, NULL,
		ap_dists.amount,
		SUM (ap_dists.amount) OVER
		    (PARTITION BY ap_dists.invoice_id,
		     ap_dists.charge_applicable_to_dist_id))	      TRX_LINE_DIST_TAX_AMT
	,ap_dists.TAXABLE_AMOUNT 				      TAXABLE_AMT
	,ap_dists.ATTRIBUTE_CATEGORY
	,ap_dists.ATTRIBUTE1
	,ap_dists.ATTRIBUTE2
	,ap_dists.ATTRIBUTE3
	,ap_dists.ATTRIBUTE4
	,ap_dists.ATTRIBUTE5
	,ap_dists.ATTRIBUTE6
	,ap_dists.ATTRIBUTE7
	,ap_dists.ATTRIBUTE8
	,ap_dists.ATTRIBUTE9
	,ap_dists.ATTRIBUTE10
	,ap_dists.ATTRIBUTE11
	,ap_dists.ATTRIBUTE12
	,ap_dists.ATTRIBUTE13
	,ap_dists.ATTRIBUTE14
	,ap_dists.ATTRIBUTE15
	,ap_dists.GLOBAL_ATTRIBUTE_CATEGORY
	,ap_dists.GLOBAL_ATTRIBUTE1
	,ap_dists.GLOBAL_ATTRIBUTE2
	,ap_dists.GLOBAL_ATTRIBUTE3
	,ap_dists.GLOBAL_ATTRIBUTE4
	,ap_dists.GLOBAL_ATTRIBUTE5
	,ap_dists.GLOBAL_ATTRIBUTE6
	,ap_dists.GLOBAL_ATTRIBUTE7
	,ap_dists.GLOBAL_ATTRIBUTE8
	,ap_dists.GLOBAL_ATTRIBUTE9
	,ap_dists.GLOBAL_ATTRIBUTE10
	,ap_dists.GLOBAL_ATTRIBUTE11
	,ap_dists.GLOBAL_ATTRIBUTE12
	,ap_dists.GLOBAL_ATTRIBUTE13
	,ap_dists.GLOBAL_ATTRIBUTE14
	,ap_dists.GLOBAL_ATTRIBUTE15
	,ap_dists.GLOBAL_ATTRIBUTE16
	,ap_dists.GLOBAL_ATTRIBUTE17
	,ap_dists.GLOBAL_ATTRIBUTE18
	,ap_dists.GLOBAL_ATTRIBUTE19
	,ap_dists.GLOBAL_ATTRIBUTE20
	,DECODE(ap_dists.charge_applicable_to_dist_id,
		 NULL, 'Y', 'N')				      TAX_ONLY_LINE_FLAG
	,NVL(ap_dists.tax_recoverable_flag, 'N')      		      RECOVERABLE_FLAG
	,ap_dists.reversal_flag				              REVERSE_FLAG
	,DECODE(ap_dists.posted_flag, 'Y', 'A', NULL)  	              POSTING_FLAG
	,NVL(lines1.accounting_date,
	      NVL(inv.invoice_date, sysdate))                         TAX_DATE
	,NVL(lines1.accounting_date,
	      NVL(inv.invoice_date, sysdate))                         TAX_DETERMINE_DATE
	,NVL(lines1.accounting_date,
	      NVL(inv.invoice_date, sysdate))                         TAX_POINT_DATE
	,ap_dists1.old_dist_line_number                               ORIG_AP_CHRG_DIST_NUM
	,ap_dists1.old_distribution_id                                ORIG_AP_CHRG_DIST_ID
	,ap_dists.old_dist_line_number                                ORIG_AP_TAX_DIST_NUM
	,ap_dists.old_distribution_id                                 ORIG_AP_TAX_DIST_ID
	,DECODE(ap_dists.posted_flag, 'Y', '111111111111111',
				      'P', '111111111111111',
					   '000000000000000')         LEGAL_REPORTING_STATUS
	,DECODE(lines.discarded_flag, 'Y', 'Y', 'N')                 CANCEL_FLAG
	,DECODE(taxes.tax_type_code,'OFFSET','Y','N')                OFFSET_FLAG
	,NVL(rates.def_rec_settlement_option_code,
	     taxes.def_rec_settlement_option_code)                    DEF_REC_SETTLEMENT_OPTION_CODE
	,rates.tax_rate_id                                            ACCOUNT_SOURCE_TAX_RATE_ID
	,(SELECT tax_rate_id FROM zx_rates_b
          WHERE tax_rate_code = 'AD_HOC_RECOVERY'
          AND rate_type_code = 'RECOVERY'
          AND tax_regime_code = rates.tax_regime_code
          AND tax = rates.tax
          AND content_owner_id = ptp.party_tax_profile_id
	  AND record_type_code = 'MIGRATED'
	  AND tax_class = 'INPUT')                          RECOVERY_RATE_ID
	 ,DECODE(lines.line_source,'MANUAL LINE ENTRY','Y','N')   MANUALLY_ENTERED_FLAG   --BUG7146063
         ,DECODE(lines.line_source,'MANUAL LINE ENTRY','TAX_AMOUNT',NULL)   LAST_MANUAL_ENTRY   --BUG7146063
   FROM ap_invoices_all inv,
	xla_upgrade_dates upd,
	fnd_currencies fnd_curr,
	ap_inv_dists_target ap_dists,
	ap_inv_dists_target ap_dists1,
	ap_invoice_lines_all lines1,
        ap_invoice_lines_all lines,
	zx_rates_b rates,
	zx_regimes_b regimes,
	zx_taxes_b taxes,
	zx_status_b status,
	zx_party_tax_profile ptp
  WHERE inv.rowid BETWEEN p_start_rowid AND p_end_rowid
    AND upd.ledger_id  = inv.set_of_books_id
    AND (TRUNC(inv.invoice_date) between upd.start_date and upd.end_date)
    AND fnd_curr.currency_code = inv.invoice_currency_code
    --  AND inv.doc_sequence_id = fds.doc_sequence_id(+)
    AND ap_dists.invoice_id = inv.invoice_id
    AND ap_dists.line_type_lookup_code IN ('REC_TAX','NONREC_TAX')
    AND ap_dists1.invoice_distribution_id = NVL(ap_dists.charge_applicable_to_dist_id,
                                                ap_dists.invoice_distribution_id)
    AND lines1.invoice_id = ap_dists1.invoice_id
    AND lines1.line_number = ap_dists1.invoice_line_number
    AND lines.invoice_id = ap_dists.invoice_id
    AND lines.line_number = ap_dists.invoice_line_number
    AND rates.source_id(+) = ap_dists.tax_code_id
    AND regimes.tax_regime_code(+) = rates.tax_regime_code
    AND taxes.tax_regime_code(+) = rates.tax_regime_code
    AND taxes.tax(+) = rates.tax
    AND taxes.content_owner_id(+) = rates.content_owner_id
    AND status.tax_regime_code(+) = rates.tax_regime_code
    AND status.tax(+) = rates.tax
    AND status.tax_status_code(+) = rates.tax_status_code
    AND status.content_owner_id(+) = rates.content_owner_id
    AND ptp.party_type_code = 'OU'
    AND ptp.party_id = DECODE(l_multi_org_flag,'N', l_org_id, ap_dists.org_id)
    AND NVL(inv.historical_flag, 'N') = 'Y'
    AND NOT EXISTS
         (SELECT 1 FROM zx_lines zxl
                 WHERE zxl.application_id   = 200
                     AND zxl.event_class_code = DECODE(inv.INVOICE_TYPE_LOOKUP_CODE,
                                              'STANDARD', 'STANDARD INVOICES',
					      'CREDIT'  , 'STANDARD INVOICES',
				              'DEBIT'   , 'STANDARD INVOICES',
			                      'MIXED'   , 'STANDARD INVOICES',
			                      'ADJUSTMENT','STANDARD INVOICES',
					      'PO PRICE ADJUST','STANDARD INVOICES',
				 	      'INVOICE REQUEST','STANDARD INVOICES',
					      'CREDIT MEMO REQUEST','STANDARD INVOICES',
				              'RETAINAGE RELEASE'  ,'STANDARD INVOICES',
				              'PREPAYMENT', 'PREPAYMENT INVOICES',
				              'EXPENSE REPORT', 'EXPENSE REPORTS',
				              'INTEREST INVOICE', 'INTEREST INVOICES','NA')
                   AND zxl.trx_id	    = inv.invoice_id
                   AND zxl.entity_code	    = 'AP_INVOICES');

    x_rows_processed := SQL%ROWCOUNT;

     IF g_level_procedure >= g_current_runtime_level THEN
       FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AP_TRX_MIG','Worker: '||p_worker_id||' x_rows_processed is  ' || x_rows_processed );
       FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AP_TRX_MIG','Worker: '||p_worker_id||' zx_ap_trx_mig (-)' );
     END IF;

EXCEPTION
  WHEN OTHERS THEN
    X_retcode := CONC_FAIL;
    IF g_level_unexpected >= g_current_runtime_level THEN
      FND_LOG.STRING(g_level_unexpected,
        'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_AP_TRX_MIG',
        'Worker: '||p_worker_id||'Raised exceptions: '||
         sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80) );
    END IF;
    raise;

  END zx_ap_trx_mig;

/**************************************************************/

  PROCEDURE zx_po_trx_mig (x_errbuf         OUT NOCOPY VARCHAR2,
                           x_retcode        OUT NOCOPY VARCHAR2,
                           p_start_rowid    IN	ROWID,
                           p_end_rowid      IN	ROWID,
                           p_org_id         IN	NUMBER,
                           p_multi_org_flag IN	VARCHAR2,
                           p_worker_id      IN  NUMBER,
                           x_rows_processed OUT	NOCOPY NUMBER)
  IS
	  l_multi_org_flag            VARCHAR2(1);
	  l_org_id                    NUMBER;
  BEGIN
	  l_multi_org_flag            := p_multi_org_flag;
	  l_org_id                    := p_org_id;


    IF g_level_procedure >= g_current_runtime_level THEN
      FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_PO_TRX_MIG','Worker: '||p_worker_id||' zx_po_trx_mig (+)' );
      FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_PO_TRX_MIG','Worker: '||p_worker_id||'p_start_rowid is ' || p_start_rowid );
      FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_PO_TRX_MIG','Worker: '||p_worker_id||'p_end_rowid is ' || p_end_rowid );
      FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_PO_TRX_MIG','Worker: '||p_worker_id||'p_org_id is ' || p_org_id );
      FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_PO_TRX_MIG','Worker: '||p_worker_id||'p_multi_org_flag is  ' || p_multi_org_flag );
    END IF;

  x_retcode := CONC_SUCCESS;

    ZX_PO_REC_PKG.get_rec_info(
          p_start_rowid   =>  p_start_rowid,
          p_end_rowid     =>  p_end_rowid);

 INSERT INTO ZX_LINES_DET_FACTORS (
           -- ,EVENT_ID
           -- ,ACCOUNT_CCID
           -- ,ACCOUNT_STRING
           -- ,ADJUSTED_DOC_APPLICATION_ID
           -- ,ADJUSTED_DOC_DATE
           -- ,ADJUSTED_DOC_ENTITY_CODE
           -- ,ADJUSTED_DOC_EVENT_CLASS_CODE
           -- ,ADJUSTED_DOC_LINE_ID
           -- ,ADJUSTED_DOC_NUMBER
           -- ,ADJUSTED_DOC_TRX_ID
           -- ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           -- ,APPLICATION_DOC_STATUS
           APPLICATION_ID
           -- ,APPLIED_FROM_APPLICATION_ID
           -- ,APPLIED_FROM_ENTITY_CODE
           -- ,APPLIED_FROM_EVENT_CLASS_CODE
           -- ,APPLIED_FROM_LINE_ID
           -- ,APPLIED_FROM_TRX_ID
           -- ,APPLIED_FROM_TRX_LEVEL_TYPE
           -- ,APPLIED_TO_APPLICATION_ID
           -- ,APPLIED_TO_ENTITY_CODE
           -- ,APPLIED_TO_EVENT_CLASS_CODE
           -- ,APPLIED_TO_TRX_ID
           -- ,APPLIED_TO_TRX_LEVEL_TYPE
           -- ,APPLIED_TO_TRX_LINE_ID
           -- ,APPLIED_TO_TRX_NUMBER
           -- ,ASSESSABLE_VALUE
           -- ,ASSET_ACCUM_DEPRECIATION
           -- ,ASSET_COST
           -- ,ASSET_FLAG
           -- ,ASSET_NUMBER
           -- ,ASSET_TYPE
           -- ,BATCH_SOURCE_ID
           -- ,BATCH_SOURCE_NAME
           -- ,BILL_FROM_LOCATION_ID
           -- ,BILL_FROM_PARTY_TAX_PROF_ID
           -- ,BILL_FROM_SITE_TAX_PROF_ID
           -- ,BILL_TO_LOCATION_ID
           -- ,BILL_TO_PARTY_TAX_PROF_ID
           -- ,BILL_TO_SITE_TAX_PROF_ID
           ,COMPOUNDING_TAX_FLAG
           ,CREATED_BY
           ,CREATION_DATE
           ,CTRL_HDR_TX_APPL_FLAG
           -- ,CTRL_TOTAL_HDR_TX_AMT
           -- ,CTRL_TOTAL_LINE_TX_AMT
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_RATE
           ,CURRENCY_CONVERSION_TYPE
           -- ,DEFAULT_TAXATION_COUNTRY
           -- ,DOC_EVENT_STATUS
           -- ,DOC_SEQ_ID
           -- ,DOC_SEQ_NAME
           -- ,DOC_SEQ_VALUE
           -- ,DOCUMENT_SUB_TYPE
           ,ENTITY_CODE
           -- ,ESTABLISHMENT_ID
           ,EVENT_CLASS_CODE
           ,EVENT_TYPE_CODE
           ,FIRST_PTY_ORG_ID
           ,HISTORICAL_FLAG
           -- ,HQ_ESTB_PARTY_TAX_PROF_ID
           ,INCLUSIVE_TAX_OVERRIDE_FLAG
           ,INPUT_TAX_CLASSIFICATION_CODE
           -- ,INTERNAL_ORG_LOCATION_ID
           ,INTERNAL_ORGANIZATION_ID
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
           ,LEDGER_ID
           ,LEGAL_ENTITY_ID
           ,LINE_AMT
           ,LINE_AMT_INCLUDES_TAX_FLAG
           ,LINE_CLASS
           -- ,LINE_INTENDED_USE
           ,LINE_LEVEL_ACTION
           -- ,MERCHANT_PARTY_COUNTRY
           -- ,MERCHANT_PARTY_DOCUMENT_NUMBER
           -- ,MERCHANT_PARTY_ID
           -- ,MERCHANT_PARTY_NAME
           -- ,MERCHANT_PARTY_REFERENCE
           -- ,MERCHANT_PARTY_TAX_PROF_ID
           -- ,MERCHANT_PARTY_TAX_REG_NUMBER
           -- ,MERCHANT_PARTY_TAXPAYER_ID
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,OBJECT_VERSION_NUMBER
           -- ,OUTPUT_TAX_CLASSIFICATION_CODE
           -- ,PORT_OF_ENTRY_CODE
           ,PRECISION
           -- ,PRODUCT_CATEGORY
           -- ,PRODUCT_CODE
           -- ,PRODUCT_DESCRIPTION
           -- ,PRODUCT_FISC_CLASSIFICATION
           ,PRODUCT_ID
           ,PRODUCT_ORG_ID
           ,PRODUCT_TYPE
           ,RECORD_TYPE_CODE
           -- ,REF_DOC_APPLICATION_ID
           -- ,REF_DOC_ENTITY_CODE
           -- ,REF_DOC_EVENT_CLASS_CODE
           -- ,REF_DOC_LINE_ID
           -- ,REF_DOC_LINE_QUANTITY
           -- ,REF_DOC_TRX_ID
           -- ,REF_DOC_TRX_LEVEL_TYPE
           -- ,RELATED_DOC_APPLICATION_ID
           -- ,RELATED_DOC_DATE
           -- ,RELATED_DOC_ENTITY_CODE
           -- ,RELATED_DOC_EVENT_CLASS_CODE
           -- ,RELATED_DOC_NUMBER
           -- ,RELATED_DOC_TRX_ID
           -- ,SHIP_FROM_LOCATION_ID
           -- ,SHIP_FROM_PARTY_TAX_PROF_ID
           -- ,SHIP_FROM_SITE_TAX_PROF_ID
           ,SHIP_TO_LOCATION_ID
           -- ,SHIP_TO_PARTY_TAX_PROF_ID
           -- ,SHIP_TO_SITE_TAX_PROF_ID
           -- ,SOURCE_APPLICATION_ID
           -- ,SOURCE_ENTITY_CODE
           -- ,SOURCE_EVENT_CLASS_CODE
           -- ,SOURCE_LINE_ID
           -- ,SOURCE_TRX_ID
           -- ,SOURCE_TRX_LEVEL_TYPE
           -- ,START_EXPENSE_DATE
           -- ,SUPPLIER_EXCHANGE_RATE
           -- ,SUPPLIER_TAX_INVOICE_DATE
           -- ,SUPPLIER_TAX_INVOICE_NUMBER
           ,TAX_AMT_INCLUDED_FLAG
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           -- ,TAX_INVOICE_DATE
           -- ,TAX_INVOICE_NUMBER
           ,TAX_PROCESSING_COMPLETED_FLAG
           ,TAX_REPORTING_FLAG
           ,THRESHOLD_INDICATOR_FLAG
           -- ,TRX_BUSINESS_CATEGORY
           -- ,TRX_COMMUNICATED_DATE
           ,TRX_CURRENCY_CODE
           ,TRX_DATE
           -- ,TRX_DESCRIPTION
           -- ,TRX_DUE_DATE
           ,TRX_ID
           ,TRX_LEVEL_TYPE
           ,TRX_LINE_DATE
           -- ,TRX_LINE_DESCRIPTION
           ,TRX_LINE_GL_DATE
           ,TRX_LINE_ID
           ,TRX_LINE_NUMBER
           ,TRX_LINE_QUANTITY
           ,TRX_LINE_TYPE
           ,TRX_NUMBER
           --- ,TRX_RECEIPT_DATE
           --- ,TRX_SHIPPING_DATE
           --- ,TRX_TYPE_DESCRIPTION
           ,UNIT_PRICE
           -- ,UOM_CODE
           -- ,USER_DEFINED_FISC_CLASS
           ,USER_UPD_DET_FACTORS_FLAG
           ,EVENT_CLASS_MAPPING_ID
           ,GLOBAL_ATTRIBUTE_CATEGORY
           ,GLOBAL_ATTRIBUTE1
           -- ,ICX_SESSION_ID
           -- ,TRX_LINE_CURRENCY_CODE
           -- ,TRX_LINE_CURRENCY_CONV_RATE
           -- ,TRX_LINE_CURRENCY_CONV_DATE
           -- ,TRX_LINE_PRECISION
           -- ,TRX_LINE_MAU
           -- ,TRX_LINE_CURRENCY_CONV_TYPE
           -- ,INTERFACE_ENTITY_CODE
           -- ,INTERFACE_LINE_ID
           -- ,SOURCE_TAX_LINE_ID
           ,TAX_CALCULATION_DONE_FLAG
           ,LINE_TRX_USER_KEY1
           ,LINE_TRX_USER_KEY2
           ,LINE_TRX_USER_KEY3
         )
          SELECT /*+ ORDERED NO_EXPAND use_nl(fc, oi, pol, poll, ptp, hr) */
           -- NULL 			  EVENT_ID,
           -- NULL 			  ACCOUNT_CCID,
           -- NULL 			  ACCOUNT_STRING,
           -- NULL 			  ADJUSTED_DOC_APPLICATION_ID,
           -- NULL 			  ADJUSTED_DOC_DATE,
           -- NULL 			  ADJUSTED_DOC_ENTITY_CODE,
           -- NULL 			  ADJUSTED_DOC_EVENT_CLASS_CODE,
           -- NULL 			  ADJUSTED_DOC_LINE_ID,
           -- NULL 			  ADJUSTED_DOC_NUMBER,
           -- NULL 			  ADJUSTED_DOC_TRX_ID,
           -- NULL 			  ADJUSTED_DOC_TRX_LEVEL_TYPE,
           -- NULL 			  APPLICATION_DOC_STATUS,
           201 			          APPLICATION_ID,
           -- NULL 			  APPLIED_FROM_APPLICATION_ID,
           -- NULL 			  APPLIED_FROM_ENTITY_CODE,
           -- NULL 			  APPLIED_FROM_EVENT_CLASS_CODE,
           -- NULL 			  APPLIED_FROM_LINE_ID,
           -- NULL 			  APPLIED_FROM_TRX_ID,
           -- NULL 			  APPLIED_FROM_TRX_LEVEL_TYPE,
           -- NULL 			  APPLIED_TO_APPLICATION_ID,
           -- NULL 			  APPLIED_TO_ENTITY_CODE,
           -- NULL 			  APPLIED_TO_EVENT_CLASS_CODE,
           -- NULL 			  APPLIED_TO_TRX_ID,
           -- NULL 			  APPLIED_TO_TRX_LEVEL_TYPE,
           -- NULL 			  APPLIED_TO_TRX_LINE_ID,
           -- NULL 			  APPLIED_TO_TRX_NUMBER,
           -- NULL 			  ASSESSABLE_VALUE,
           -- NULL 			  ASSET_ACCUM_DEPRECIATION,
           -- NULL 			  ASSET_COST,
           -- NULL 			  ASSET_FLAG,
           -- NULL 			  ASSET_NUMBER,
           -- NULL 			  ASSET_TYPE,
           -- NULL 			  BATCH_SOURCE_ID,
           -- NULL 			  BATCH_SOURCE_NAME,
           -- NULL 			  BILL_FROM_LOCATION_ID,
           -- NULL 			  BILL_FROM_PARTY_TAX_PROF_ID,
           -- NULL 			  BILL_FROM_SITE_TAX_PROF_ID,
           -- NULL 			  BILL_TO_LOCATION_ID,
           -- NULL 			  BILL_TO_PARTY_TAX_PROF_ID,
           -- NULL 			  BILL_TO_SITE_TAX_PROF_ID,
           'N' 			          COMPOUNDING_TAX_FLAG,
           1   			          CREATED_BY,
           SYSDATE 		          CREATION_DATE,
           'N' 			          CTRL_HDR_TX_APPL_FLAG,
           -- NULL			  CTRL_TOTAL_HDR_TX_AMT,
           -- NULL	 		  CTRL_TOTAL_LINE_TX_AMT,
           poh.rate_date 		  CURRENCY_CONVERSION_DATE,
           poh.rate 		          CURRENCY_CONVERSION_RATE,
           poh.rate_type 		  CURRENCY_CONVERSION_TYPE,
           -- NULL 			  DEFAULT_TAXATION_COUNTRY,
           -- NULL 			  DOC_EVENT_STATUS,
           -- NULL 			  DOC_SEQ_ID,
           -- NULL 			  DOC_SEQ_NAME,
           -- NULL 			  DOC_SEQ_VALUE,
           -- NULL 			  DOCUMENT_SUB_TYPE,
           -- 'PURCHASE_ORDER' 	          ENTITY_CODE,
           NVL2(poll.po_release_id,
                'RELEASE',
                'PURCHASE_ORDER')         ENTITY_CODE,
           -- NULL 			  ESTABLISHMENT_ID,
           -- 'PO_PA' 	                  EVENT_CLASS_CODE,
           NVL2(poll.po_release_id,
                'RELEASE', 'PO_PA')       EVENT_CLASS_CODE,
           'PURCHASE ORDER CREATED'       EVENT_TYPE_CODE,
           ptp.party_tax_profile_id	  FIRST_PTY_ORG_ID,
           'Y' 			          HISTORICAL_FLAG,
           -- NULL	 		  HQ_ESTB_PARTY_TAX_PROF_ID,
           'N' 			          INCLUSIVE_TAX_OVERRIDE_FLAG,
           (select name
	          from ap_tax_codes_all
	          where tax_id = poll.tax_code_id) INPUT_TAX_CLASSIFICATION_CODE,
           -- NULL 			  INTERNAL_ORG_LOCATION_ID,
           nvl(poh.org_id,-99) 	          INTERNAL_ORGANIZATION_ID,
           SYSDATE 		          LAST_UPDATE_DATE,
           1 			          LAST_UPDATE_LOGIN,
           1 			          LAST_UPDATED_BY,
           poh.set_of_books_id 	          LEDGER_ID,
           NVL(oi.org_information2, -99)  LEGAL_ENTITY_ID,
           DECODE(pol.purchase_basis,
            'TEMP LABOR', NVL(POLL.amount,0),
            'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                               NVL(poll.quantity,0) *
                               NVL(poll.price_override,NVL(pol.unit_price,0))),
             NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                          LINE_AMT,
           'N' 			          LINE_AMT_INCLUDES_TAX_FLAG,
           'INVOICE' 		          LINE_CLASS,
           -- NULL 			  LINE_INTENDED_USE,
           'CREATE' 		          LINE_LEVEL_ACTION,
           -- NULL 			  MERCHANT_PARTY_COUNTRY,
           -- NULL 			  MERCHANT_PARTY_DOCUMENT_NUMBER,
           -- NULL 			  MERCHANT_PARTY_ID,
           -- NULL 			  MERCHANT_PARTY_NAME,
           -- NULL 			  MERCHANT_PARTY_REFERENCE,
           -- NULL 			  MERCHANT_PARTY_TAX_PROF_ID,
           -- NULL 			  MERCHANT_PARTY_TAX_REG_NUMBER,
           -- NULL 			  MERCHANT_PARTY_TAXPAYER_ID,
           fc.minimum_accountable_unit,   -- MINIMUM_ACCOUNTABLE_UNIT,
           1 			          OBJECT_VERSION_NUMBER,
           -- NULL 			  OUTPUT_TAX_CLASSIFICATION_CODE,
           -- NULL 			  PORT_OF_ENTRY_CODE,
           NVL(fc.precision, 0)           PRECISION,
           -- fc.precision 		  PRECISION,
           -- NULL 			  PRODUCT_CATEGORY,
           -- NULL 			  PRODUCT_CODE,
           -- NULL 			  PRODUCT_DESCRIPTION,
           -- NULL 			  PRODUCT_FISC_CLASSIFICATION,
           pol.item_id		          PRODUCT_ID,
           poll.ship_to_organization_id	  PRODUCT_ORG_ID,
           DECODE(UPPER(pol.purchase_basis),
                  'GOODS', 'GOODS',
                  'SERVICES', 'SERVICES',
                  'TEMP LABOR','SERVICES',
                  'GOODS') 		  PRODUCT_TYPE,
           'MIGRATED' 		          RECORD_TYPE_CODE,
           -- NULL 			  REF_DOC_APPLICATION_ID,
           -- NULL 			  REF_DOC_ENTITY_CODE,
           -- NULL 			  REF_DOC_EVENT_CLASS_CODE,
           -- NULL 			  REF_DOC_LINE_ID,
           -- NULL 			  REF_DOC_LINE_QUANTITY,
           -- NULL 			  REF_DOC_TRX_ID,
           -- NULL 			  REF_DOC_TRX_LEVEL_TYPE,
           -- NULL 			  RELATED_DOC_APPLICATION_ID,
           -- NULL 			  RELATED_DOC_DATE,
           -- NULL 			  RELATED_DOC_ENTITY_CODE,
           -- NULL 			  RELATED_DOC_EVENT_CLASS_CODE,
           -- NULL 			  RELATED_DOC_NUMBER,
           -- NULL 			  RELATED_DOC_TRX_ID,
           -- NULL 			  SHIP_FROM_LOCATION_ID,
           -- NULL 			  SHIP_FROM_PARTY_TAX_PROF_ID,
           -- NULL 			  SHIP_FROM_SITE_TAX_PROF_ID,
           poll.ship_to_location_id,	  -- SHIP_TO_LOCATION_ID,
           -- NULL 			  SHIP_TO_PARTY_TAX_PROF_ID,
           -- NULL 			  SHIP_TO_SITE_TAX_PROF_ID,
           -- NULL 			  SOURCE_APPLICATION_ID,
           -- NULL 			  SOURCE_ENTITY_CODE,
           -- NULL 			  SOURCE_EVENT_CLASS_CODE,
           -- NULL 			  SOURCE_LINE_ID,
           -- NULL 			  SOURCE_TRX_ID,
           -- NULL 			  SOURCE_TRX_LEVEL_TYPE,
           -- NULL 			  START_EXPENSE_DATE,
           -- NULL 			  SUPPLIER_EXCHANGE_RATE,
           -- NULL 			  SUPPLIER_TAX_INVOICE_DATE,
           -- NULL 			  SUPPLIER_TAX_INVOICE_NUMBER,
           'N' 			          TAX_AMT_INCLUDED_FLAG,
           'PURCHASE_TRANSACTION' 	  TAX_EVENT_CLASS_CODE,
           'VALIDATE'  		          TAX_EVENT_TYPE_CODE,
           -- NULL 			  TAX_INVOICE_DATE,
           -- NULL 			  TAX_INVOICE_NUMBER,
           'Y'			          TAX_PROCESSING_COMPLETED_FLAG,
           'N'			          TAX_REPORTING_FLAG,
           'N' 			          THRESHOLD_INDICATOR_FLAG,
           -- NULL 			  TRX_BUSINESS_CATEGORY,
           -- NULL 			  TRX_COMMUNICATED_DATE,
           NVL(poh.currency_code,
              poh.base_currency_code)     TRX_CURRENCY_CODE,
           -- NVL(poh.currency_code 	  TRX_CURRENCY_CODE,
           poh.last_update_date 	  TRX_DATE,
           -- NULL 			  TRX_DESCRIPTION,
           -- NULL 			  TRX_DUE_DATE,
           -- poh.po_header_id 	          TRX_ID,
           NVL(poll.po_release_id,
               poh.po_header_id)          TRX_ID,
           'SHIPMENT' 		          TRX_LEVEL_TYPE,
           poll.LAST_UPDATE_DATE  	  TRX_LINE_DATE,
           -- NULL 			  TRX_LINE_DESCRIPTION,
           poll.LAST_UPDATE_DATE 	  TRX_LINE_GL_DATE,
           poll.line_location_id 	  TRX_LINE_ID,
           poll.SHIPMENT_NUM 	          TRX_LINE_NUMBER,
           poll.quantity 		  TRX_LINE_QUANTITY,
           'ITEM' 			  TRX_LINE_TYPE,
           poh.segment1 		  TRX_NUMBER,
           --- NULL 			  TRX_RECEIPT_DATE,
           --- NULL 			  TRX_SHIPPING_DATE,
           --- NULL 			  TRX_TYPE_DESCRIPTION,
           NVL(poll.price_override,
               pol.unit_price)            UNIT_PRICE,
           -- pol.unit_price 		  UNIT_PRICE,
           -- NULL 			  UOM_CODE,
           -- NULL 			  USER_DEFINED_FISC_CLASS,
           'N' 			          USER_UPD_DET_FACTORS_FLAG,
           -- 3			          EVENT_CLASS_MAPPING_ID,
           NVL2(poll.po_release_id,12, 3) EVENT_CLASS_MAPPING_ID,
           poll.GLOBAL_ATTRIBUTE_CATEGORY,-- GLOBAL_ATTRIBUTE_CATEGORY,
           poll.GLOBAL_ATTRIBUTE1,  	  -- GLOBAL_ATTRIBUTE1
           -- NULL                        ICX_SESSION_ID,
           -- NULL                        TRX_LINE_CURRENCY_CODE,
           -- NULL                        TRX_LINE_CURRENCY_CONV_RATE,
           -- NULL                        TRX_LINE_CURRENCY_CONV_DATE,
           -- NULL                        TRX_LINE_PRECISION,
           -- NULL                        TRX_LINE_MAU,
           -- NULL                        TRX_LINE_CURRENCY_CONV_TYPE,
           -- NULL                        INTERFACE_ENTITY_CODE,
           -- NULL                        INTERFACE_LINE_ID,
           -- NULL                        SOURCE_TAX_LINE_ID
           'Y'                            TAX_CALCULATION_DONE_FLAG,
           pol.line_num                   LINE_TRX_USER_KEY1,
           hr.location_code               LINE_TRX_USER_KEY2,
           DECODE(poll.payment_type,
                   NULL, 0, 'DELIVERY',
                   1,'ADVANCE', 2, 3)     LINE_TRX_USER_KEY3
      FROM (SELECT /*+ NO_MERGE NO_EXPAND ROWID(poh) swap_join_inputs(fsp) swap_join_inputs(upd)
                       swap_join_inputs(aps) */
                    poh.*,
                    fsp.set_of_books_id,
                    aps.base_currency_code
       	       FROM po_headers_all poh,
                    financials_system_params_all fsp,
                    xla_upgrade_dates upd,
                    ap_system_parameters_all aps
      	      WHERE poh.rowid BETWEEN p_start_rowid AND p_end_rowid
                AND NVL(poh.closed_code, 'X') <> 'FINALLY CLOSED'
                AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
                AND upd.ledger_id = fsp.set_of_books_id
                AND aps.set_of_books_id = fsp.set_of_books_id
                AND NVL(aps.org_id, -99) = NVL(fsp.org_id, -99)
                AND (poh.last_update_date between upd.start_date and upd.end_date)
              ) poh,
            fnd_currencies fc,
            hr_organization_information oi,
            po_lines_all pol,
            po_line_locations_all poll,
            zx_party_tax_profile ptp,
            hr_locations_all hr
      WHERE NVL(poh.currency_code, poh.base_currency_code) = fc.currency_code(+)
        AND oi.organization_id(+) = poh.org_id
        AND oi.org_information_context(+) = 'Operating Unit Information'
        AND pol.po_header_id = poh.po_header_id
        AND poll.po_header_id = pol.po_header_id
        AND poll.po_line_id = pol.po_line_id
        AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
        AND ptp.party_type_code = 'OU'
        AND hr.location_id(+) = poll.ship_to_location_id
        AND NOT EXISTS
           (SELECT 1 FROM zx_lines_Det_Factors zxdet
             WHERE zxdet.APPLICATION_ID   = 201
               AND zxdet.ENTITY_CODE      = NVL2(poll.po_release_id, 'RELEASE', 'PURCHASE_ORDER')
               AND zxdet.EVENT_CLASS_CODE = NVL2(poll.po_release_id, 'RELEASE', 'PO_PA')
               AND zxdet.TRX_ID           = NVL(poll.po_release_id,poh.po_header_id)
           );

 -- insert into zx_lines for tax code
 --
 INSERT INTO ZX_LINES(
              --  ,ADJUSTED_DOC_APPLICATION_ID
              --  ,ADJUSTED_DOC_DATE
              --  ,ADJUSTED_DOC_ENTITY_CODE
              --  ,ADJUSTED_DOC_EVENT_CLASS_CODE
              --  ,ADJUSTED_DOC_LINE_ID
              --  ,ADJUSTED_DOC_NUMBER
              --  ,ADJUSTED_DOC_TAX_LINE_ID
              --  ,ADJUSTED_DOC_TRX_ID
              --  ,ADJUSTED_DOC_TRX_LEVEL_TYPE
              APPLICATION_ID
              --  ,APPLIED_FROM_APPLICATION_ID
              --  ,APPLIED_FROM_ENTITY_CODE
              --  ,APPLIED_FROM_EVENT_CLASS_CODE
              --  ,APPLIED_FROM_LINE_ID
              --  ,APPLIED_FROM_TRX_ID
              --  ,APPLIED_FROM_TRX_LEVEL_TYPE
              --  ,APPLIED_FROM_TRX_NUMBER
              --  ,APPLIED_TO_APPLICATION_ID
              --  ,APPLIED_TO_ENTITY_CODE
              --  ,APPLIED_TO_EVENT_CLASS_CODE
              --  ,APPLIED_TO_LINE_ID
              --  ,APPLIED_TO_TRX_ID
              --  ,APPLIED_TO_TRX_LEVEL_TYPE
              --  ,APPLIED_TO_TRX_NUMBER
              ,ASSOCIATED_CHILD_FROZEN_FLAG
              ,ATTRIBUTE_CATEGORY
              ,ATTRIBUTE1
              ,ATTRIBUTE10
              ,ATTRIBUTE11
              ,ATTRIBUTE12
              ,ATTRIBUTE13
              ,ATTRIBUTE14
              ,ATTRIBUTE15
              ,ATTRIBUTE2
              ,ATTRIBUTE3
              ,ATTRIBUTE4
              ,ATTRIBUTE5
              ,ATTRIBUTE6
              ,ATTRIBUTE7
              ,ATTRIBUTE8
              ,ATTRIBUTE9
              -- ,BASIS_RESULT_ID
              -- ,CAL_TAX_AMT
              -- ,CAL_TAX_AMT_FUNCL_CURR
              -- ,CAL_TAX_AMT_TAX_CURR
              -- ,CALC_RESULT_ID
              ,CANCEL_FLAG
              -- ,CHAR1
              -- ,CHAR10
              -- ,CHAR2
              -- ,CHAR3
              -- ,CHAR4
              -- ,CHAR5
              -- ,CHAR6
              -- ,CHAR7
              -- ,CHAR8
              -- ,CHAR9
              ,COMPOUNDING_DEP_TAX_FLAG
              ,COMPOUNDING_TAX_FLAG
              ,COMPOUNDING_TAX_MISS_FLAG
              ,CONTENT_OWNER_ID
              ,COPIED_FROM_OTHER_DOC_FLAG
              ,CREATED_BY
              ,CREATION_DATE
              ,CTRL_TOTAL_LINE_TX_AMT
              ,CURRENCY_CONVERSION_DATE
              ,CURRENCY_CONVERSION_RATE
              ,CURRENCY_CONVERSION_TYPE
              -- ,DATE1
              -- ,DATE10
              -- ,DATE2
              -- ,DATE3
              -- ,DATE4
              -- ,DATE5
              -- ,DATE6
              -- ,DATE7
              -- ,DATE8
              -- ,DATE9
              ,DELETE_FLAG
              -- ,DIRECT_RATE_RESULT_ID
              -- ,DOC_EVENT_STATUS
              ,ENFORCE_FROM_NATURAL_ACCT_FLAG
              ,ENTITY_CODE
              --- ,ESTABLISHMENT_ID
              --- ,EVAL_EXCPT_RESULT_ID
              --- ,EVAL_EXMPT_RESULT_ID,
              ,EVENT_CLASS_CODE
              ,EVENT_TYPE_CODE
              -- ,EXCEPTION_RATE
              -- ,EXEMPT_CERTIFICATE_NUMBER
              -- ,EXEMPT_RATE_MODIFIER
              -- ,EXEMPT_REASON
              -- ,EXEMPT_REASON_CODE
              ,FREEZE_UNTIL_OVERRIDDEN_FLAG
              ,GLOBAL_ATTRIBUTE_CATEGORY
              ,GLOBAL_ATTRIBUTE1
              ,GLOBAL_ATTRIBUTE10
              ,GLOBAL_ATTRIBUTE11
              ,GLOBAL_ATTRIBUTE12
              ,GLOBAL_ATTRIBUTE13
              ,GLOBAL_ATTRIBUTE14
              ,GLOBAL_ATTRIBUTE15
              ,GLOBAL_ATTRIBUTE2
              ,GLOBAL_ATTRIBUTE3
              ,GLOBAL_ATTRIBUTE4
              ,GLOBAL_ATTRIBUTE5
              ,GLOBAL_ATTRIBUTE6
              ,GLOBAL_ATTRIBUTE7
              ,GLOBAL_ATTRIBUTE8
              ,GLOBAL_ATTRIBUTE9
              ,HISTORICAL_FLAG
              -- ,HQ_ESTB_PARTY_TAX_PROF_ID
              -- ,HQ_ESTB_REG_NUMBER
              -- ,INTERFACE_ENTITY_CODE
              -- ,INTERFACE_TAX_LINE_ID
              -- ,INTERNAL_ORG_LOCATION_ID
              ,INTERNAL_ORGANIZATION_ID
              ,ITEM_DIST_CHANGED_FLAG
              -- ,LAST_MANUAL_ENTRY
              ,LAST_UPDATE_DATE
              ,LAST_UPDATE_LOGIN
              ,LAST_UPDATED_BY
              ,LEDGER_ID
              ,LEGAL_ENTITY_ID
              -- ,LEGAL_ENTITY_TAX_REG_NUMBER
              -- ,LEGAL_JUSTIFICATION_TEXT1
              -- ,LEGAL_JUSTIFICATION_TEXT2
              -- ,LEGAL_JUSTIFICATION_TEXT3
              -- ,LEGAL_MESSAGE_APPL_2
              -- ,LEGAL_MESSAGE_BASIS
              -- ,LEGAL_MESSAGE_CALC
              -- ,LEGAL_MESSAGE_EXCPT
              -- ,LEGAL_MESSAGE_EXMPT
              -- ,LEGAL_MESSAGE_POS
              -- ,LEGAL_MESSAGE_RATE
              -- ,LEGAL_MESSAGE_STATUS
              -- ,LEGAL_MESSAGE_THRESHOLD
              -- ,LEGAL_MESSAGE_TRN
              ,LINE_AMT
              -- ,LINE_ASSESSABLE_VALUE
              ,MANUALLY_ENTERED_FLAG
              ,MINIMUM_ACCOUNTABLE_UNIT
              -- ,MRC_LINK_TO_TAX_LINE_ID
              ,MRC_TAX_LINE_FLAG
              -- ,NREC_TAX_AMT
              -- ,NREC_TAX_AMT_FUNCL_CURR
              -- ,NREC_TAX_AMT_TAX_CURR
              -- ,NUMERIC1
              -- ,NUMERIC10
              -- ,NUMERIC2
              -- ,NUMERIC3
              -- ,NUMERIC4
              -- ,NUMERIC5
              -- ,NUMERIC6
              -- ,NUMERIC7
              -- ,NUMERIC8
              -- ,NUMERIC9
              ,OBJECT_VERSION_NUMBER
              ,OFFSET_FLAG
              -- ,OFFSET_LINK_TO_TAX_LINE_ID
              -- ,OFFSET_TAX_RATE_CODE
              ,ORIG_SELF_ASSESSED_FLAG
              -- ,ORIG_TAX_AMT
              -- ,ORIG_TAX_AMT_INCLUDED_FLAG
              -- ,ORIG_TAX_AMT_TAX_CURR
              -- ,ORIG_TAX_JURISDICTION_CODE
              -- ,ORIG_TAX_JURISDICTION_ID
              -- ,ORIG_TAX_RATE
              -- ,ORIG_TAX_RATE_CODE
              -- ,ORIG_TAX_RATE_ID
              -- ,ORIG_TAX_STATUS_CODE
              -- ,ORIG_TAX_STATUS_ID
              -- ,ORIG_TAXABLE_AMT
              -- ,ORIG_TAXABLE_AMT_TAX_CURR
              -- ,OTHER_DOC_LINE_AMT
              -- ,OTHER_DOC_LINE_TAX_AMT
              -- ,OTHER_DOC_LINE_TAXABLE_AMT
              -- ,OTHER_DOC_SOURCE
              ,OVERRIDDEN_FLAG
              -- ,PLACE_OF_SUPPLY
              -- ,PLACE_OF_SUPPLY_RESULT_ID
              -- ,PLACE_OF_SUPPLY_TYPE_CODE
              -- ,PRD_TOTAL_TAX_AMT
              -- ,PRD_TOTAL_TAX_AMT_FUNCL_CURR
              -- ,PRD_TOTAL_TAX_AMT_TAX_CURR
             ,PRECISION
             ,PROCESS_FOR_RECOVERY_FLAG
             ,PRORATION_CODE
             ,PURGE_FLAG
              -- ,RATE_RESULT_ID
              -- ,REC_TAX_AMT
              -- ,REC_TAX_AMT_FUNCL_CURR
              -- ,REC_TAX_AMT_TAX_CURR
              ,RECALC_REQUIRED_FLAG
              ,RECORD_TYPE_CODE
              -- ,REF_DOC_APPLICATION_ID
              -- ,REF_DOC_ENTITY_CODE
              -- ,REF_DOC_EVENT_CLASS_CODE
              -- ,REF_DOC_LINE_ID
              -- ,REF_DOC_LINE_QUANTITY
              -- ,REF_DOC_TRX_ID
              -- ,REF_DOC_TRX_LEVEL_TYPE
              -- ,REGISTRATION_PARTY_TYPE
              -- ,RELATED_DOC_APPLICATION_ID
              -- ,RELATED_DOC_DATE
              -- ,RELATED_DOC_ENTITY_CODE
              -- ,RELATED_DOC_EVENT_CLASS_CODE
              -- ,RELATED_DOC_NUMBER
              -- ,RELATED_DOC_TRX_ID
              -- ,RELATED_DOC_TRX_LEVEL_TYPE
              -- ,REPORTING_CURRENCY_CODE
              ,REPORTING_ONLY_FLAG
              -- ,REPORTING_PERIOD_ID
              -- ,ROUNDING_LEVEL_CODE
              -- ,ROUNDING_LVL_PARTY_TAX_PROF_ID
              -- ,ROUNDING_LVL_PARTY_TYPE
              -- ,ROUNDING_RULE_CODE
              ,SELF_ASSESSED_FLAG
              ,SETTLEMENT_FLAG
              -- ,STATUS_RESULT_ID
              -- ,SUMMARY_TAX_LINE_ID
              -- ,SYNC_WITH_PRVDR_FLAG
              ,TAX
              ,TAX_AMT
              ,TAX_AMT_FUNCL_CURR
              ,TAX_AMT_INCLUDED_FLAG
              ,TAX_AMT_TAX_CURR
              -- ,TAX_APPLICABILITY_RESULT_ID
              ,TAX_APPORTIONMENT_FLAG
              ,TAX_APPORTIONMENT_LINE_NUMBER
              -- ,TAX_BASE_MODIFIER_RATE
              ,TAX_CALCULATION_FORMULA
              -- ,TAX_CODE
              ,TAX_CURRENCY_CODE
              ,TAX_CURRENCY_CONVERSION_DATE
              ,TAX_CURRENCY_CONVERSION_RATE
              ,TAX_CURRENCY_CONVERSION_TYPE
              ,TAX_DATE
              -- ,TAX_DATE_RULE_ID
              ,TAX_DETERMINE_DATE
              ,TAX_EVENT_CLASS_CODE
              ,TAX_EVENT_TYPE_CODE
              -- ,TAX_EXCEPTION_ID
              -- ,TAX_EXEMPTION_ID
              -- ,TAX_HOLD_CODE
              -- ,TAX_HOLD_RELEASED_CODE
              ,TAX_ID
              -- ,TAX_JURISDICTION_CODE
              -- ,TAX_JURISDICTION_ID
              ,TAX_LINE_ID
              ,TAX_LINE_NUMBER
              ,TAX_ONLY_LINE_FLAG
              ,TAX_POINT_DATE
              -- ,TAX_PROVIDER_ID
              ,TAX_RATE
              -- ,TAX_RATE_BEFORE_EXCEPTION
              -- ,TAX_RATE_BEFORE_EXEMPTION
              ,TAX_RATE_CODE
              ,TAX_RATE_ID
              -- ,TAX_RATE_NAME_BEFORE_EXCEPTION
              -- ,TAX_RATE_NAME_BEFORE_EXEMPTION,
              -- ,TAX_RATE_TYPE
              -- ,TAX_REG_NUM_DET_RESULT_ID
              ,TAX_REGIME_CODE
              ,TAX_REGIME_ID
              -- ,TAX_REGIME_TEMPLATE_ID
              -- ,TAX_REGISTRATION_ID
              -- ,TAX_REGISTRATION_NUMBER
              ,TAX_STATUS_CODE
              ,TAX_STATUS_ID
              -- ,TAX_TYPE_CODE
              -- ,TAXABLE_AMT
              -- ,TAXABLE_AMT_FUNCL_CURR
              -- ,TAXABLE_AMT_TAX_CURR
              ,TAXABLE_BASIS_FORMULA
              -- ,TAXING_JURIS_GEOGRAPHY_ID
              -- ,THRESH_RESULT_ID
              ,TRX_CURRENCY_CODE
              ,TRX_DATE
              ,TRX_ID
              -- ,TRX_ID_LEVEL2
              -- ,TRX_ID_LEVEL3
              -- ,TRX_ID_LEVEL4
              -- ,TRX_ID_LEVEL5
              -- ,TRX_ID_LEVEL6
              ,TRX_LEVEL_TYPE
              ,TRX_LINE_DATE
              ,TRX_LINE_ID
              -- ,TRX_LINE_INDEX
              ,TRX_LINE_NUMBER
              ,TRX_LINE_QUANTITY
              ,TRX_NUMBER
              -- ,TRX_USER_KEY_LEVEL1
              -- ,TRX_USER_KEY_LEVEL2
              -- ,TRX_USER_KEY_LEVEL3
              -- ,TRX_USER_KEY_LEVEL4
              -- ,TRX_USER_KEY_LEVEL5
              -- ,TRX_USER_KEY_LEVEL6
              ,UNIT_PRICE
              -- ,UNROUNDED_TAX_AMT
              -- ,UNROUNDED_TAXABLE_AMT
              ,MULTIPLE_JURISDICTIONS_FLAG
            )
             SELECT /*+ leading(poh) NO_EXPAND use_nl(fc,pol,poll,ptp,atc,rates,regimes,taxes,status) */
              -- NULL                     DJUSTED_DOC_APPLICATION_ID,
              -- NULL                     DJUSTED_DOC_DATE,
              -- NULL                     ADJUSTED_DOC_ENTITY_CODE,
              -- NULL                     ADJUSTED_DOC_EVENT_CLASS_CODE,
              -- NULL                     ADJUSTED_DOC_LINE_ID,
              -- NULL                     ADJUSTED_DOC_NUMBER,
              -- NULL                     ADJUSTED_DOC_TAX_LINE_ID,
              -- NULL                     AADJUSTED_DOC_TRX_ID,
              -- NULL                     AADJUSTED_DOC_TRX_LEVEL_TYPE,
              201                         APPLICATION_ID,
              -- NULL                     APPLIED_FROM_APPLICATION_ID,
              -- NULL                     APPLIED_FROM_ENTITY_CODE,
              -- NULL                     APPLIED_FROM_EVENT_CLASS_CODE,
              -- NULL                     APPLIED_FROM_LINE_ID,
              -- NULL                     APPLIED_FROM_TRX_ID,
              -- NULL                     APPLIED_FROM_TRX_LEVEL_TYPE,
              -- NULL	                  APPLIED_FROM_TRX_NUMBER,
              -- NULL	                  APPLIED_TO_APPLICATION_ID,
              -- NULL	                  APPLIED_TO_ENTITY_CODE,
              -- NULL	                  APPLIED_TO_EVENT_CLASS_CODE,
              -- NULL	                  APPLIED_TO_LINE_ID,
              -- NULL	                  APPLIED_TO_TRX_ID,
              -- NULL	                  APPLIED_TO_TRX_LEVEL_TYPE,
              -- NULL	                  APPLIED_TO_TRX_NUMBER,
              'N' 	                  ASSOCIATED_CHILD_FROZEN_FLAG,
              poll.ATTRIBUTE_CATEGORY     ATTRIBUTE_CATEGORY,
              poll.ATTRIBUTE1 	          ATTRIBUTE1,
              poll.ATTRIBUTE10	          ATTRIBUTE10,
              poll.ATTRIBUTE11	          ATTRIBUTE11,
              poll.ATTRIBUTE12	          ATTRIBUTE12,
              poll.ATTRIBUTE13	          ATTRIBUTE13,
              poll.ATTRIBUTE14	          ATTRIBUTE14,
              poll.ATTRIBUTE15	          ATTRIBUTE15,
              poll.ATTRIBUTE2 	          ATTRIBUTE2,
              poll.ATTRIBUTE3 	          ATTRIBUTE3,
              poll.ATTRIBUTE4 	          ATTRIBUTE4,
              poll.ATTRIBUTE5 	          ATTRIBUTE5,
              poll.ATTRIBUTE6 	          ATTRIBUTE6,
              poll.ATTRIBUTE7 	          ATTRIBUTE7,
              poll.ATTRIBUTE8 	          ATTRIBUTE8,
              poll.ATTRIBUTE9 	          ATTRIBUTE9,
              -- NULL		          BASIS_RESULT_ID,
              -- NULL	                  CAL_TAX_AMT,
              -- NULL	                  CAL_TAX_AMT_FUNCL_CURR,
              -- NULL	                  CAL_TAX_AMT_TAX_CURR,
              -- NULL	                  CALC_RESULT_ID,
              'N'	                  CANCEL_FLAG,
              -- NULL	                  CHAR1,
              -- NULL	                  CHAR10,
              -- NULL	                  CHAR2,
              -- NULL	                  CHAR3,
              -- NULL	                  CHAR4,
              -- NULL	                  CHAR5,
              -- NULL	                  CHAR6,
              -- NULL	                  CHAR7,
              -- NULL	                  CHAR8,
              -- NULL	                  CHAR9,
              'N'	                  COMPOUNDING_DEP_TAX_FLAG,
              'N'	                  COMPOUNDING_TAX_FLAG,
              'N'	                  COMPOUNDING_TAX_MISS_FLAG,
              -- nvl(poh.org_id,-99)	  CONTENT_OWNER_ID,
              ptp.party_tax_profile_id	  CONTENT_OWNER_ID,
              'N'	                  COPIED_FROM_OTHER_DOC_FLAG,
              1	                          CREATED_BY,
              SYSDATE	                  CREATION_DATE,
              NULL		          CTRL_TOTAL_LINE_TX_AMT,
              poh.rate_date 	          CURRENCY_CONVERSION_DATE,
              poh.rate 	                  CURRENCY_CONVERSION_RATE,
              poh.rate_type 	          CURRENCY_CONVERSION_TYPE,
              -- NULL	                  DATE1,
              -- NULL	                  DATE10,
              --  NULL	                  DATE2,
              --  NULL	                  DATE3,
              --  NULL	                  DATE4,
              --  NULL	                  DATE5,
              --  NULL	                  DATE6,
              --  NULL	                  DATE7,
              --  NULL	                  DATE8,
              --  NULL	                  DATE9,
              'N'	                  DELETE_FLAG,
              -- NULL	                  DIRECT_RATE_RESULT_ID,
              -- NULL	                  DOC_EVENT_STATUS,
              'N'	                  ENFORCE_FROM_NATURAL_ACCT_FLAG,
              -- 'PURCHASE_ORDER' 	  ENTITY_CODE,
              NVL2(poll.po_release_id,
              'RELEASE','PURCHASE_ORDER') ENTITY_CODE,
              -- NULL	                  ESTABLISHMENT_ID,
              -- NULL	                  EVAL_EXCPT_RESULT_ID,
              -- NULL	                  EVAL_EXMPT_RESULT_ID,
              -- 'PO_PA' 		  EVENT_CLASS_CODE,
              NVL2(poll.po_release_id,
                   'RELEASE', 'PO_PA')    EVENT_CLASS_CODE,
              'PURCHASE ORDER CREATED'	  EVENT_TYPE_CODE,
              -- NULL                     EXCEPTION_RATE,
              -- NULL	                  EXEMPT_CERTIFICATE_NUMBER,
              -- NULL	                  EXEMPT_RATE_MODIFIER,
              -- NULL	                  EXEMPT_REASON,
              -- NULL	                  EXEMPT_REASON_CODE,
              'N'	                  FREEZE_UNTIL_OVERRIDDEN_FLAG,
              poll.GLOBAL_ATTRIBUTE_CATEGORY,   -- GLOBAL_ATTRIBUTE_CATEGORY,
              poll.GLOBAL_ATTRIBUTE1, 	  -- GLOBAL_ATTRIBUTE1,
              poll.GLOBAL_ATTRIBUTE10,	  -- GLOBAL_ATTRIBUTE10,
              poll.GLOBAL_ATTRIBUTE11,	  -- GLOBAL_ATTRIBUTE11,
              poll.GLOBAL_ATTRIBUTE12,	  -- GLOBAL_ATTRIBUTE12,
              poll.GLOBAL_ATTRIBUTE13,	  -- GLOBAL_ATTRIBUTE13,
              poll.GLOBAL_ATTRIBUTE14,	  -- GLOBAL_ATTRIBUTE14,
              poll.GLOBAL_ATTRIBUTE15,	  -- GLOBAL_ATTRIBUTE15,
              poll.GLOBAL_ATTRIBUTE2,     -- GLOBAL_ATTRIBUTE2,
              poll.GLOBAL_ATTRIBUTE3,     -- GLOBAL_ATTRIBUTE3,
              poll.GLOBAL_ATTRIBUTE4,     -- GLOBAL_ATTRIBUTE4,
              poll.GLOBAL_ATTRIBUTE5,     -- GLOBAL_ATTRIBUTE5,
              poll.GLOBAL_ATTRIBUTE6,     -- GLOBAL_ATTRIBUTE6,
              poll.GLOBAL_ATTRIBUTE7,     -- GLOBAL_ATTRIBUTE7,
              poll.GLOBAL_ATTRIBUTE8,     -- GLOBAL_ATTRIBUTE8,
              poll.GLOBAL_ATTRIBUTE9,     -- GLOBAL_ATTRIBUTE9,
              'Y'	                  HISTORICAL_FLAG,
              -- NULL                     HQ_ESTB_PARTY_TAX_PROF_ID,
              -- NULL	                  HQ_ESTB_REG_NUMBER,
              -- NULL	                  INTERFACE_ENTITY_CODE,
              -- NULL                     INTERFACE_TAX_LINE_ID,
              -- NULL                     NAL_ORG_LOCATION_ID,
              nvl(poh.org_id,-99)         INTERNAL_ORGANIZATION_ID,
              'N'                         ITEM_DIST_CHANGED_FLAG,
              -- NULL	                  LAST_MANUAL_ENTRY,
              SYSDATE	                  LAST_UPDATE_DATE,
              1	                          LAST_UPDATE_LOGIN,
              1	                          LAST_UPDATED_BY,
              poh.set_of_books_id 	  LEDGER_ID,
              NVL(poh.org_information2,-99) LEGAL_ENTITY_ID,
              -- NULL                     LEGAL_ENTITY_TAX_REG_NUMBER ,
              -- NULL                     LEGAL_JUSTIFICATION_TEXT1,
              -- NULL	                  LEGAL_JUSTIFICATION_TEXT2,
              -- NULL	                  LEGAL_JUSTIFICATION_TEXT3,
              -- NULL                     LEGAL_MESSAGE_APPL_2,
              -- NULL	                  LEGAL_MESSAGE_BASIS,
              -- NULL	                  LEGAL_MESSAGE_CALC,
              -- NULL	                  LEGAL_MESSAGE_EXCPT,
              -- NULL	                  LEGAL_MESSAGE_EXMPT,
              -- NULL	                  LEGAL_MESSAGE_POS,
              -- NULL	                  LEGAL_MESSAGE_RATE,
              --  NULL                    LEGAL_MESSAGE_STATUS,
              -- NULL	                  LEGAL_MESSAGE_THRESHOLD,
              -- NULL	                  LEGAL_MESSAGE_TRN,
            DECODE(pol.purchase_basis,
             'TEMP LABOR', NVL(POLL.amount,0),
             'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                                NVL(poll.quantity,0) *
                                NVL(poll.price_override,NVL(pol.unit_price,0))),
              NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                          LINE_AMT,
              -- NULL	                  LINE_ASSESSABLE_VALUE,
              'N'	                  MANUALLY_ENTERED_FLAG,
              fc.minimum_accountable_unit MINIMUM_ACCOUNTABLE_UNIT,
              -- NULL	                  MRC_LINK_TO_TAX_LINE_ID,
              'N'	                  MRC_TAX_LINE_FLAG,
              -- NULL	                  NREC_TAX_AMT,
              -- NULL	                  NREC_TAX_AMT_FUNCL_CURR,
              -- NULL	                  NREC_TAX_AMT_TAX_CURR,
              -- NULL	                  NUMERIC1,
              -- NULL	                  NUMERIC10,
              -- NULL	                  NUMERIC2,
              -- NULL	                  NUMERIC3,
              -- NULL	                  NUMERIC4,
              -- NULL	                  NUMERIC5,
              -- NULL	                  NUMERIC6,
              -- NULL	                  NUMERIC7,
              -- NULL	                  NUMERIC8,
              -- NULL	                  NUMERIC9,
              1	                          OBJECT_VERSION_NUMBER,
              'N'	                  OFFSET_FLAG,
              -- NULL	                  OFFSET_LINK_TO_TAX_LINE_ID,
              -- NULL	                  OFFSET_TAX_RATE_CODE,
              'N'	                  ORIG_SELF_ASSESSED_FLAG,
              -- NULL	                  ORIG_TAX_AMT,
              -- NULL	                  ORIG_TAX_AMT_INCLUDED_FLAG,
              -- NULL	                  ORIG_TAX_AMT_TAX_CURR,
              -- NULL	                  ORIG_TAX_JURISDICTION_CODE,
              -- NULL	                  ORIG_TAX_JURISDICTION_ID,
              -- NULL	                  ORIG_TAX_RATE,
              -- NULL	                  ORIG_TAX_RATE_CODE,
              -- NULL	                  ORIG_TAX_RATE_ID,
              -- NULL	                  ORIG_TAX_STATUS_CODE,
              -- NULL	                  ORIG_TAX_STATUS_ID,
              -- NULL	                  ORIG_TAXABLE_AMT,
              -- NULL	                  ORIG_TAXABLE_AMT_TAX_CURR,
              -- NULL	                  OTHER_DOC_LINE_AMT,
              -- NULL	                  OTHER_DOC_LINE_TAX_AMT,
              -- NULL	                  OTHER_DOC_LINE_TAXABLE_AMT,
              -- NULL	                  OTHER_DOC_SOURCE,
              'N'	                  OVERRIDDEN_FLAG,
              -- NULL	                  PLACE_OF_SUPPLY,
              -- NULL	                  PLACE_OF_SUPPLY_RESULT_ID ,
              -- NULL                     PLACE_OF_SUPPLY_TYPE_CODE,
              -- NULL	                  PRD_TOTAL_TAX_AMT,
              -- NULL	                  PRD_TOTAL_TAX_AMT_FUNCL_CURR,
              -- NULL	                  PRD_TOTAL_TAX_AMT_TAX_CURR  ,
              NVL(fc.precision, 0)        PRECISION,
              -- fc.precision 	          PRECISION,
              'N'	                  PROCESS_FOR_RECOVERY_FLAG,
              NULL	                  PRORATION_CODE,
              'N'	                  PURGE_FLAG,
              -- NULL	                  RATE_RESULT_ID,
              -- NULL	                  REC_TAX_AMT,
              -- NULL	                  REC_TAX_AMT_FUNCL_CURR,
              -- NULL	                  REC_TAX_AMT_TAX_CURR,
              'N'	                  RECALC_REQUIRED_FLAG,
              'MIGRATED'                  RECORD_TYPE_CODE,
              -- NULL	                  REF_DOC_APPLICATION_ID,
              -- NULL	                  REF_DOC_ENTITY_CODE,
              -- NULL	                  REF_DOC_EVENT_CLASS_CODE,
              -- NULL	                  REF_DOC_LINE_ID,
              -- NULL	                  REF_DOC_LINE_QUANTITY,
              -- NULL	                  REF_DOC_TRX_ID,
              -- NULL	                  REF_DOC_TRX_LEVEL_TYPE,
              -- NULL	                  REGISTRATION_PARTY_TYPE,
              -- NULL	                  RELATED_DOC_APPLICATION_ID,
              -- NULL	                  RELATED_DOC_DATE,
              -- NULL	                  RELATED_DOC_ENTITY_CODE,
              -- NULL	                  RELATED_DOC_EVENT_CLASS_CODE,
              -- NULL	                  RELATED_DOC_NUMBER,
              -- NULL	                  RELATED_DOC_TRX_ID,
              -- NULL	                  RELATED_DOC_TRX_LEVEL_TYPE,
              -- NULL	                  REPORTING_CURRENCY_CODE,
             'N'	                  REPORTING_ONLY_FLAG,
              -- NULL	                  REPORTING_PERIOD_ID,
              -- NULL	                  ROUNDING_LEVEL_CODE,
              -- NULL	                  ROUNDING_LVL_PARTY_TAX_PROF_ID,
              -- NULL	                  ROUNDING_LVL_PARTY_TYPE,
              -- NULL	                  ROUNDING_RULE_CODE,
               'N'	                  SELF_ASSESSED_FLAG,
               'N'                        SETTLEMENT_FLAG,
              -- NULL                     STATUS_RESULT_ID,
              -- NULL                     SUMMARY_TAX_LINE_ID,
              -- NULL                     SYNC_WITH_PRVDR_FLAG,
              rates.tax                   TAX ,
              decode(FC.Minimum_Accountable_Unit, NULL,
               ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
               ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                * FC.Minimum_Accountable_Unit)
                                          TAX_AMT,
              decode(FC.Minimum_Accountable_Unit, NULL,
               ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
               ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                * FC.Minimum_Accountable_Unit)
                                          TAX_AMT_FUNCL_CURR,
              'N'                         TAX_AMT_INCLUDED_FLAG,
              decode(FC.Minimum_Accountable_Unit, NULL,
                ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
                ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                 * FC.Minimum_Accountable_Unit)
                                          TAX_AMT_TAX_CURR,
              -- NULL                     TAX_APPLICABILITY_RESULT_ID,
              'Y'                         TAX_APPORTIONMENT_FLAG,
              1                           TAX_APPORTIONMENT_LINE_NUMBER,
              -- NULL                     TAX_BASE_MODIFIER_RATE,
              'STANDARD_TC'               TAX_CALCULATION_FORMULA,
              -- NULL                     TAX_CODE,
              taxes.tax_currency_code     TAX_CURRENCY_CODE,
              poh.rate_date 		  TAX_CURRENCY_CONVERSION_DATE,
              poh.rate 		          TAX_CURRENCY_CONVERSION_RATE,
              poh.rate_type 		  TAX_CURRENCY_CONVERSION_TYPE,
              poll.last_update_date       TAX_DATE,
              -- NULL                     TAX_DATE_RULE_ID,
              poll.last_update_date       TAX_DETERMINE_DATE,
              'PURCHASE_TRANSACTION' 	  TAX_EVENT_CLASS_CODE,
              'VALIDATE'  		  TAX_EVENT_TYPE_CODE,
              -- NULL                     TAX_EXCEPTION_ID,
              -- NULL                     TAX_EXEMPTION_ID,
              -- NULL                     TAX_HOLD_CODE,
              -- NULL                     TAX_HOLD_RELEASED_CODE,
              taxes.tax_id                TAX_ID,
              -- NULL                     TAX_JURISDICTION_CODE,
              -- NULL                     TAX_JURISDICTION_ID,
              zx_lines_s.nextval          TAX_LINE_ID,
              RANK() OVER
               (PARTITION BY
                 NVL(poll.po_release_id,
                     poh.po_header_id)
                ORDER BY
                 poll.line_location_id,
                 atc.tax_id)             TAX_LINE_NUMBER,
              'N'                        TAX_ONLY_LINE_FLAG,
               poll.last_update_date     TAX_POINT_DATE,
              -- NULL                    TAX_PROVIDER_ID,
              rates.percentage_rate  	 TAX_RATE,
              -- NULL	                 TAX_RATE_BEFORE_EXCEPTION,
              -- NULL                    TAX_RATE_BEFORE_EXEMPTION,
              rates.tax_rate_code        TAX_RATE_CODE,
              rates.tax_rate_id          TAX_RATE_ID,
              -- NULL                    TAX_RATE_NAME_BEFORE_EXCEPTION,
              -- NULL                    TAX_RATE_NAME_BEFORE_EXEMPTION,
              -- NULL                    TAX_RATE_TYPE,
              -- NULL                    TAX_REG_NUM_DET_RESULT_ID,
              rates.tax_regime_code      TAX_REGIME_CODE,
              regimes.tax_regime_id      TAX_REGIME_ID,
              -- NULL                    TAX_REGIME_TEMPLATE_ID,
              -- NULL                    TAX_REGISTRATION_ID,
              -- NULL                    TAX_REGISTRATION_NUMBER,
              rates.tax_status_code      TAX_STATUS_CODE,
              status.tax_status_id       TAX_STATUS_ID,
              -- NULL                    TAX_TYPE_CODE,
              -- NULL                    TAXABLE_AMT,
              -- NULL                    TAXABLE_AMT_FUNCL_CURR,
              -- NULL                    TAXABLE_AMT_TAX_CURR,
              'STANDARD_TB'              TAXABLE_BASIS_FORMULA ,
              -- NULL                    TAXING_JURIS_GEOGRAPHY_ID ,
              -- NULL                    THRESH_RESULT_ID,
              NVL(poh.currency_code,
                 poh.base_currency_code) TRX_CURRENCY_CODE,
              poh.last_update_date       TRX_DATE,
              -- poh.po_header_id        TRX_ID,
              NVL(poll.po_release_id,
                   poh.po_header_id)     TRX_ID,
              -- NULL                    TRX_ID_LEVEL2,
              -- NULL                    TRX_ID_LEVEL3,
              -- NULL                    TRX_ID_LEVEL4,
              -- NULL                    TRX_ID_LEVEL5,
              -- NULL                    TRX_ID_LEVEL6,
              'SHIPMENT'                 TRX_LEVEL_TYPE,
              poll.LAST_UPDATE_DATE      TRX_LINE_DATE ,
              poll.line_location_id      TRX_LINE_ID,
              -- NULL                    TRX_LINE_INDEX,
              poll.SHIPMENT_NUM          TRX_LINE_NUMBER,
              poll.quantity 		 TRX_LINE_QUANTITY ,
              poh.segment1               TRX_NUMBER,
              -- NULL                    TRX_USER_KEY_LEVEL1,
              -- NULL                    TRX_USER_KEY_LEVEL2,
              -- NULL                    TRX_USER_KEY_LEVEL3,
              -- NULL                    TRX_USER_KEY_LEVEL4,
              -- NULL                    TRX_USER_KEY_LEVEL5,
              -- NULL                    TRX_USER_KEY_LEVEL6,
              NVL(poll.price_override,
                   pol.unit_price)       UNIT_PRICE,
              -- pol.unit_price          UNIT_PRICE,
              -- NULL                    UNROUNDED_TAX_AMT,
              -- NULL                    UNROUNDED_TAXABLE_AMT,
              'N'                        MULTIPLE_JURISDICTIONS_FLAG
         FROM
             (SELECT /*+ NO_MERGE NO_EXPAND ROWID(poh) use_hash(fsp) use_hash(aps)
                         swap_join_inputs(fsp) swap_join_inputs(upd)
                         swap_join_inputs(aps) swap_join_inputs(oi)*/
              	     poh.* , fsp.org_id fsp_org_id, fsp.set_of_books_id,
              	     aps.base_currency_code, oi.org_information2
                FROM po_headers_all poh,
              	     financials_system_params_all fsp,
              	     xla_upgrade_dates upd,
           	     ap_system_parameters_all aps,
           	     hr_organization_information oi
               WHERE poh.rowid BETWEEN p_start_rowid AND p_end_rowid
                 AND NVL(poh.closed_code, 'X') <> 'FINALLY CLOSED'
                 AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
                 AND upd.ledger_id = fsp.set_of_books_id
                 AND NVL(aps.org_id, -99) = NVL(fsp.org_id,-99)
                 AND aps.set_of_books_id = fsp.set_of_books_id
                 AND (poh.last_update_date between upd.start_date and upd.end_date)
                 AND oi.organization_id(+) = poh.org_id
                 AND oi.org_information_context(+) = 'Operating Unit Information'
             )  poh,
                fnd_currencies fc,
                po_lines_all pol,
                po_line_locations_all poll,
                zx_party_tax_profile ptp,
                ap_tax_codes_all atc,
                zx_rates_b rates,
                zx_regimes_b regimes,
                zx_taxes_b taxes,
                zx_status_b status
          WHERE NVL(poh.currency_code, poh.base_currency_code) = fc.currency_code(+)
            AND poh.po_header_id = pol.po_header_id
            AND pol.po_header_id = poll.po_header_id
            AND pol.po_line_id = poll.po_line_id
            AND nvl(atc.org_id,-99)=nvl(poh.fsp_org_id,-99)
            AND poll.tax_code_id = atc.tax_id
            AND atc.tax_type NOT IN ('TAX_GROUP','USE')
            AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
            AND ptp.party_type_code = 'OU'
            AND rates.source_id = atc.tax_id
            AND regimes.tax_regime_code(+) = rates.tax_regime_code
            AND taxes.tax_regime_code(+) = rates.tax_regime_code
            AND taxes.tax(+) = rates.tax
            AND taxes.content_owner_id(+) = rates.content_owner_id
            AND status.tax_regime_code(+) = rates.tax_regime_code
            AND status.tax(+) = rates.tax
            AND status.content_owner_id(+) = rates.content_owner_id
            AND status.tax_status_code(+) = rates.tax_status_code
            AND NOT EXISTS
                (SELECT 1 FROM zx_lines zxl
                  WHERE zxl.APPLICATION_ID   = 201
                    AND zxl.EVENT_CLASS_CODE = NVL2(poll.po_release_id, 'RELEASE', 'PO_PA')
                    AND zxl.TRX_ID           = NVL(poll.po_release_id, poh.po_header_id)
                    AND zxl.ENTITY_CODE	     = NVL2(poll.po_release_id, 'RELEASE','PURCHASE_ORDER'));

 -- insert into zx_lines tax group
 --
INSERT INTO ZX_LINES(
              --  ,ADJUSTED_DOC_APPLICATION_ID
              --  ,ADJUSTED_DOC_DATE
              --  ,ADJUSTED_DOC_ENTITY_CODE
              --  ,ADJUSTED_DOC_EVENT_CLASS_CODE
              --  ,ADJUSTED_DOC_LINE_ID
              --  ,ADJUSTED_DOC_NUMBER
              --  ,ADJUSTED_DOC_TAX_LINE_ID
              --  ,ADJUSTED_DOC_TRX_ID
              --  ,ADJUSTED_DOC_TRX_LEVEL_TYPE
              APPLICATION_ID
              --  ,APPLIED_FROM_APPLICATION_ID
              --  ,APPLIED_FROM_ENTITY_CODE
              --  ,APPLIED_FROM_EVENT_CLASS_CODE
              --  ,APPLIED_FROM_LINE_ID
              --  ,APPLIED_FROM_TRX_ID
              --  ,APPLIED_FROM_TRX_LEVEL_TYPE
              --  ,APPLIED_FROM_TRX_NUMBER
              --  ,APPLIED_TO_APPLICATION_ID
              --  ,APPLIED_TO_ENTITY_CODE
              --  ,APPLIED_TO_EVENT_CLASS_CODE
              --  ,APPLIED_TO_LINE_ID
              --  ,APPLIED_TO_TRX_ID
              --  ,APPLIED_TO_TRX_LEVEL_TYPE
              --  ,APPLIED_TO_TRX_NUMBER
              ,ASSOCIATED_CHILD_FROZEN_FLAG
              ,ATTRIBUTE_CATEGORY
              ,ATTRIBUTE1
              ,ATTRIBUTE10
              ,ATTRIBUTE11
              ,ATTRIBUTE12
              ,ATTRIBUTE13
              ,ATTRIBUTE14
              ,ATTRIBUTE15
              ,ATTRIBUTE2
              ,ATTRIBUTE3
              ,ATTRIBUTE4
              ,ATTRIBUTE5
              ,ATTRIBUTE6
              ,ATTRIBUTE7
              ,ATTRIBUTE8
              ,ATTRIBUTE9
              -- ,BASIS_RESULT_ID
              -- ,CAL_TAX_AMT
              -- ,CAL_TAX_AMT_FUNCL_CURR
              -- ,CAL_TAX_AMT_TAX_CURR
              -- ,CALC_RESULT_ID
              ,CANCEL_FLAG
              -- ,CHAR1
              -- ,CHAR10
              -- ,CHAR2
              -- ,CHAR3
              -- ,CHAR4
              -- ,CHAR5
              -- ,CHAR6
              -- ,CHAR7
              -- ,CHAR8
              -- ,CHAR9
              ,COMPOUNDING_DEP_TAX_FLAG
              ,COMPOUNDING_TAX_FLAG
              ,COMPOUNDING_TAX_MISS_FLAG
              ,CONTENT_OWNER_ID
              ,COPIED_FROM_OTHER_DOC_FLAG
              ,CREATED_BY
              ,CREATION_DATE
              ,CTRL_TOTAL_LINE_TX_AMT
              ,CURRENCY_CONVERSION_DATE
              ,CURRENCY_CONVERSION_RATE
              ,CURRENCY_CONVERSION_TYPE
              -- ,DATE1
              -- ,DATE10
              -- ,DATE2
              -- ,DATE3
              -- ,DATE4
              -- ,DATE5
              -- ,DATE6
              -- ,DATE7
              -- ,DATE8
              -- ,DATE9
              ,DELETE_FLAG
              -- ,DIRECT_RATE_RESULT_ID
              -- ,DOC_EVENT_STATUS
              ,ENFORCE_FROM_NATURAL_ACCT_FLAG
              ,ENTITY_CODE
              --- ,ESTABLISHMENT_ID
              --- ,EVAL_EXCPT_RESULT_ID
              --- ,EVAL_EXMPT_RESULT_ID,
              ,EVENT_CLASS_CODE
              ,EVENT_TYPE_CODE
              -- ,EXCEPTION_RATE
              -- ,EXEMPT_CERTIFICATE_NUMBER
              -- ,EXEMPT_RATE_MODIFIER
              -- ,EXEMPT_REASON
              -- ,EXEMPT_REASON_CODE
              ,FREEZE_UNTIL_OVERRIDDEN_FLAG
              ,GLOBAL_ATTRIBUTE_CATEGORY
              ,GLOBAL_ATTRIBUTE1
              ,GLOBAL_ATTRIBUTE10
              ,GLOBAL_ATTRIBUTE11
              ,GLOBAL_ATTRIBUTE12
              ,GLOBAL_ATTRIBUTE13
              ,GLOBAL_ATTRIBUTE14
              ,GLOBAL_ATTRIBUTE15
              ,GLOBAL_ATTRIBUTE2
              ,GLOBAL_ATTRIBUTE3
              ,GLOBAL_ATTRIBUTE4
              ,GLOBAL_ATTRIBUTE5
              ,GLOBAL_ATTRIBUTE6
              ,GLOBAL_ATTRIBUTE7
              ,GLOBAL_ATTRIBUTE8
              ,GLOBAL_ATTRIBUTE9
              ,HISTORICAL_FLAG
              -- ,HQ_ESTB_PARTY_TAX_PROF_ID
              -- ,HQ_ESTB_REG_NUMBER
              -- ,INTERFACE_ENTITY_CODE
              -- ,INTERFACE_TAX_LINE_ID
              -- ,INTERNAL_ORG_LOCATION_ID
              ,INTERNAL_ORGANIZATION_ID
              ,ITEM_DIST_CHANGED_FLAG
              -- ,LAST_MANUAL_ENTRY
              ,LAST_UPDATE_DATE
              ,LAST_UPDATE_LOGIN
              ,LAST_UPDATED_BY
              ,LEDGER_ID
              ,LEGAL_ENTITY_ID
              -- ,LEGAL_ENTITY_TAX_REG_NUMBER
              -- ,LEGAL_JUSTIFICATION_TEXT1
              -- ,LEGAL_JUSTIFICATION_TEXT2
              -- ,LEGAL_JUSTIFICATION_TEXT3
              -- ,LEGAL_MESSAGE_APPL_2
              -- ,LEGAL_MESSAGE_BASIS
              -- ,LEGAL_MESSAGE_CALC
              -- ,LEGAL_MESSAGE_EXCPT
              -- ,LEGAL_MESSAGE_EXMPT
              -- ,LEGAL_MESSAGE_POS
              -- ,LEGAL_MESSAGE_RATE
              -- ,LEGAL_MESSAGE_STATUS
              -- ,LEGAL_MESSAGE_THRESHOLD
              -- ,LEGAL_MESSAGE_TRN
              ,LINE_AMT
              -- ,LINE_ASSESSABLE_VALUE
              ,MANUALLY_ENTERED_FLAG
              ,MINIMUM_ACCOUNTABLE_UNIT
              -- ,MRC_LINK_TO_TAX_LINE_ID
              ,MRC_TAX_LINE_FLAG
              -- ,NREC_TAX_AMT
              -- ,NREC_TAX_AMT_FUNCL_CURR
              -- ,NREC_TAX_AMT_TAX_CURR
              -- ,NUMERIC1
              -- ,NUMERIC10
              -- ,NUMERIC2
              -- ,NUMERIC3
              -- ,NUMERIC4
              -- ,NUMERIC5
              -- ,NUMERIC6
              -- ,NUMERIC7
              -- ,NUMERIC8
              -- ,NUMERIC9
              ,OBJECT_VERSION_NUMBER
              ,OFFSET_FLAG
              -- ,OFFSET_LINK_TO_TAX_LINE_ID
              -- ,OFFSET_TAX_RATE_CODE
              ,ORIG_SELF_ASSESSED_FLAG
              -- ,ORIG_TAX_AMT
              -- ,ORIG_TAX_AMT_INCLUDED_FLAG
              -- ,ORIG_TAX_AMT_TAX_CURR
              -- ,ORIG_TAX_JURISDICTION_CODE
              -- ,ORIG_TAX_JURISDICTION_ID
              -- ,ORIG_TAX_RATE
              -- ,ORIG_TAX_RATE_CODE
              -- ,ORIG_TAX_RATE_ID
              -- ,ORIG_TAX_STATUS_CODE
              -- ,ORIG_TAX_STATUS_ID
              -- ,ORIG_TAXABLE_AMT
              -- ,ORIG_TAXABLE_AMT_TAX_CURR
              -- ,OTHER_DOC_LINE_AMT
              -- ,OTHER_DOC_LINE_TAX_AMT
              -- ,OTHER_DOC_LINE_TAXABLE_AMT
              -- ,OTHER_DOC_SOURCE
              ,OVERRIDDEN_FLAG
              -- ,PLACE_OF_SUPPLY
              -- ,PLACE_OF_SUPPLY_RESULT_ID
              -- ,PLACE_OF_SUPPLY_TYPE_CODE
              -- ,PRD_TOTAL_TAX_AMT
              -- ,PRD_TOTAL_TAX_AMT_FUNCL_CURR
              -- ,PRD_TOTAL_TAX_AMT_TAX_CURR
             ,PRECISION
             ,PROCESS_FOR_RECOVERY_FLAG
             ,PRORATION_CODE
             ,PURGE_FLAG
              -- ,RATE_RESULT_ID
              -- ,REC_TAX_AMT
              -- ,REC_TAX_AMT_FUNCL_CURR
              -- ,REC_TAX_AMT_TAX_CURR
              ,RECALC_REQUIRED_FLAG
              ,RECORD_TYPE_CODE
              -- ,REF_DOC_APPLICATION_ID
              -- ,REF_DOC_ENTITY_CODE
              -- ,REF_DOC_EVENT_CLASS_CODE
              -- ,REF_DOC_LINE_ID
              -- ,REF_DOC_LINE_QUANTITY
              -- ,REF_DOC_TRX_ID
              -- ,REF_DOC_TRX_LEVEL_TYPE
              -- ,REGISTRATION_PARTY_TYPE
              -- ,RELATED_DOC_APPLICATION_ID
              -- ,RELATED_DOC_DATE
              -- ,RELATED_DOC_ENTITY_CODE
              -- ,RELATED_DOC_EVENT_CLASS_CODE
              -- ,RELATED_DOC_NUMBER
              -- ,RELATED_DOC_TRX_ID
              -- ,RELATED_DOC_TRX_LEVEL_TYPE
              -- ,REPORTING_CURRENCY_CODE
              ,REPORTING_ONLY_FLAG
              -- ,REPORTING_PERIOD_ID
              -- ,ROUNDING_LEVEL_CODE
              -- ,ROUNDING_LVL_PARTY_TAX_PROF_ID
              -- ,ROUNDING_LVL_PARTY_TYPE
              -- ,ROUNDING_RULE_CODE
              ,SELF_ASSESSED_FLAG
              ,SETTLEMENT_FLAG
              -- ,STATUS_RESULT_ID
              -- ,SUMMARY_TAX_LINE_ID
              -- ,SYNC_WITH_PRVDR_FLAG
              ,TAX
              ,TAX_AMT
              ,TAX_AMT_FUNCL_CURR
              ,TAX_AMT_INCLUDED_FLAG
              ,TAX_AMT_TAX_CURR
              -- ,TAX_APPLICABILITY_RESULT_ID
              ,TAX_APPORTIONMENT_FLAG
              ,TAX_APPORTIONMENT_LINE_NUMBER
              -- ,TAX_BASE_MODIFIER_RATE
              ,TAX_CALCULATION_FORMULA
              -- ,TAX_CODE
              ,TAX_CURRENCY_CODE
              ,TAX_CURRENCY_CONVERSION_DATE
              ,TAX_CURRENCY_CONVERSION_RATE
              ,TAX_CURRENCY_CONVERSION_TYPE
              ,TAX_DATE
              -- ,TAX_DATE_RULE_ID
              ,TAX_DETERMINE_DATE
              ,TAX_EVENT_CLASS_CODE
              ,TAX_EVENT_TYPE_CODE
              -- ,TAX_EXCEPTION_ID
              -- ,TAX_EXEMPTION_ID
              -- ,TAX_HOLD_CODE
              -- ,TAX_HOLD_RELEASED_CODE
              ,TAX_ID
              -- ,TAX_JURISDICTION_CODE
              -- ,TAX_JURISDICTION_ID
              ,TAX_LINE_ID
              ,TAX_LINE_NUMBER
              ,TAX_ONLY_LINE_FLAG
              ,TAX_POINT_DATE
              -- ,TAX_PROVIDER_ID
              ,TAX_RATE
              -- ,TAX_RATE_BEFORE_EXCEPTION
              -- ,TAX_RATE_BEFORE_EXEMPTION
              ,TAX_RATE_CODE
              ,TAX_RATE_ID
              -- ,TAX_RATE_NAME_BEFORE_EXCEPTION
              -- ,TAX_RATE_NAME_BEFORE_EXEMPTION,
              -- ,TAX_RATE_TYPE
              -- ,TAX_REG_NUM_DET_RESULT_ID
              ,TAX_REGIME_CODE
              ,TAX_REGIME_ID
              -- ,TAX_REGIME_TEMPLATE_ID
              -- ,TAX_REGISTRATION_ID
              -- ,TAX_REGISTRATION_NUMBER
              ,TAX_STATUS_CODE
              ,TAX_STATUS_ID
              -- ,TAX_TYPE_CODE
              -- ,TAXABLE_AMT
              -- ,TAXABLE_AMT_FUNCL_CURR
              -- ,TAXABLE_AMT_TAX_CURR
              ,TAXABLE_BASIS_FORMULA
              -- ,TAXING_JURIS_GEOGRAPHY_ID
              -- ,THRESH_RESULT_ID
              ,TRX_CURRENCY_CODE
              ,TRX_DATE
              ,TRX_ID
              -- ,TRX_ID_LEVEL2
              -- ,TRX_ID_LEVEL3
              -- ,TRX_ID_LEVEL4
              -- ,TRX_ID_LEVEL5
              -- ,TRX_ID_LEVEL6
              ,TRX_LEVEL_TYPE
              ,TRX_LINE_DATE
              ,TRX_LINE_ID
              -- ,TRX_LINE_INDEX
              ,TRX_LINE_NUMBER
              ,TRX_LINE_QUANTITY
              ,TRX_NUMBER
              -- ,TRX_USER_KEY_LEVEL1
              -- ,TRX_USER_KEY_LEVEL2
              -- ,TRX_USER_KEY_LEVEL3
              -- ,TRX_USER_KEY_LEVEL4
              -- ,TRX_USER_KEY_LEVEL5
              -- ,TRX_USER_KEY_LEVEL6
              ,UNIT_PRICE
              -- ,UNROUNDED_TAX_AMT
              -- ,UNROUNDED_TAXABLE_AMT
              ,MULTIPLE_JURISDICTIONS_FLAG
            )
             SELECT /*+ leading(poh) NO_EXPAND use_nl(fc,pol,poll,ptp,atc,atg,atc1,rates,regimes,taxes,status) */
              -- NULL                     DJUSTED_DOC_APPLICATION_ID,
              -- NULL                     DJUSTED_DOC_DATE,
              -- NULL                     ADJUSTED_DOC_ENTITY_CODE,
              -- NULL                     ADJUSTED_DOC_EVENT_CLASS_CODE,
              -- NULL                     ADJUSTED_DOC_LINE_ID,
              -- NULL                     ADJUSTED_DOC_NUMBER,
              -- NULL                     ADJUSTED_DOC_TAX_LINE_ID,
              -- NULL                     AADJUSTED_DOC_TRX_ID,
              -- NULL                     AADJUSTED_DOC_TRX_LEVEL_TYPE,
              201                         APPLICATION_ID,
              -- NULL                     APPLIED_FROM_APPLICATION_ID,
              -- NULL                     APPLIED_FROM_ENTITY_CODE,
              -- NULL                     APPLIED_FROM_EVENT_CLASS_CODE,
              -- NULL                     APPLIED_FROM_LINE_ID,
              -- NULL                     APPLIED_FROM_TRX_ID,
              -- NULL                     APPLIED_FROM_TRX_LEVEL_TYPE,
              -- NULL	                  APPLIED_FROM_TRX_NUMBER,
              -- NULL	                  APPLIED_TO_APPLICATION_ID,
              -- NULL	                  APPLIED_TO_ENTITY_CODE,
              -- NULL	                  APPLIED_TO_EVENT_CLASS_CODE,
              -- NULL	                  APPLIED_TO_LINE_ID,
              -- NULL	                  APPLIED_TO_TRX_ID,
              -- NULL	                  APPLIED_TO_TRX_LEVEL_TYPE,
              -- NULL	                  APPLIED_TO_TRX_NUMBER,
              'N' 	                  ASSOCIATED_CHILD_FROZEN_FLAG,
              poll.ATTRIBUTE_CATEGORY     ATTRIBUTE_CATEGORY,
              poll.ATTRIBUTE1 	          ATTRIBUTE1,
              poll.ATTRIBUTE10	          ATTRIBUTE10,
              poll.ATTRIBUTE11	          ATTRIBUTE11,
              poll.ATTRIBUTE12	          ATTRIBUTE12,
              poll.ATTRIBUTE13	          ATTRIBUTE13,
              poll.ATTRIBUTE14	          ATTRIBUTE14,
              poll.ATTRIBUTE15	          ATTRIBUTE15,
              poll.ATTRIBUTE2 	          ATTRIBUTE2,
              poll.ATTRIBUTE3 	          ATTRIBUTE3,
              poll.ATTRIBUTE4 	          ATTRIBUTE4,
              poll.ATTRIBUTE5 	          ATTRIBUTE5,
              poll.ATTRIBUTE6 	          ATTRIBUTE6,
              poll.ATTRIBUTE7 	          ATTRIBUTE7,
              poll.ATTRIBUTE8 	          ATTRIBUTE8,
              poll.ATTRIBUTE9 	          ATTRIBUTE9,
              -- NULL		          BASIS_RESULT_ID,
              -- NULL	                  CAL_TAX_AMT,
              -- NULL	                  CAL_TAX_AMT_FUNCL_CURR,
              -- NULL	                  CAL_TAX_AMT_TAX_CURR,
              -- NULL	                  CALC_RESULT_ID,
              'N'	                  CANCEL_FLAG,
              -- NULL	                  CHAR1,
              -- NULL	                  CHAR10,
              -- NULL	                  CHAR2,
              -- NULL	                  CHAR3,
              -- NULL	                  CHAR4,
              -- NULL	                  CHAR5,
              -- NULL	                  CHAR6,
              -- NULL	                  CHAR7,
              -- NULL	                  CHAR8,
              -- NULL	                  CHAR9,
              'N'	                  COMPOUNDING_DEP_TAX_FLAG,
              'N'	                  COMPOUNDING_TAX_FLAG,
              'N'	                  COMPOUNDING_TAX_MISS_FLAG,
              -- nvl(poh.org_id,-99)	  CONTENT_OWNER_ID,
              ptp.party_tax_profile_id	  CONTENT_OWNER_ID,
              'N'	                  COPIED_FROM_OTHER_DOC_FLAG,
              1	                          CREATED_BY,
              SYSDATE	                  CREATION_DATE,
              NULL		          CTRL_TOTAL_LINE_TX_AMT,
              poh.rate_date 	          CURRENCY_CONVERSION_DATE,
              poh.rate 	                  CURRENCY_CONVERSION_RATE,
              poh.rate_type 	          CURRENCY_CONVERSION_TYPE,
              -- NULL	                  DATE1,
              -- NULL	                  DATE10,
              --  NULL	                  DATE2,
              --  NULL	                  DATE3,
              --  NULL	                  DATE4,
              --  NULL	                  DATE5,
              --  NULL	                  DATE6,
              --  NULL	                  DATE7,
              --  NULL	                  DATE8,
              --  NULL	                  DATE9,
              'N'	                  DELETE_FLAG,
              -- NULL	                  DIRECT_RATE_RESULT_ID,
              -- NULL	                  DOC_EVENT_STATUS,
              'N'	                  ENFORCE_FROM_NATURAL_ACCT_FLAG,
              -- 'PURCHASE_ORDER' 	  ENTITY_CODE,
              NVL2(poll.po_release_id,
              'RELEASE','PURCHASE_ORDER') ENTITY_CODE,
              -- NULL	                  ESTABLISHMENT_ID,
              -- NULL	                  EVAL_EXCPT_RESULT_ID,
              -- NULL	                  EVAL_EXMPT_RESULT_ID,
              -- 'PO_PA' 		  EVENT_CLASS_CODE,
              NVL2(poll.po_release_id,
                   'RELEASE', 'PO_PA')    EVENT_CLASS_CODE,
              'PURCHASE ORDER CREATED'	  EVENT_TYPE_CODE,
              -- NULL                     EXCEPTION_RATE,
              -- NULL	                  EXEMPT_CERTIFICATE_NUMBER,
              -- NULL	                  EXEMPT_RATE_MODIFIER,
              -- NULL	                  EXEMPT_REASON,
              -- NULL	                  EXEMPT_REASON_CODE,
              'N'	                  FREEZE_UNTIL_OVERRIDDEN_FLAG,
              poll.GLOBAL_ATTRIBUTE_CATEGORY,   -- GLOBAL_ATTRIBUTE_CATEGORY,
              poll.GLOBAL_ATTRIBUTE1, 	  -- GLOBAL_ATTRIBUTE1,
              poll.GLOBAL_ATTRIBUTE10,	  -- GLOBAL_ATTRIBUTE10,
              poll.GLOBAL_ATTRIBUTE11,	  -- GLOBAL_ATTRIBUTE11,
              poll.GLOBAL_ATTRIBUTE12,	  -- GLOBAL_ATTRIBUTE12,
              poll.GLOBAL_ATTRIBUTE13,	  -- GLOBAL_ATTRIBUTE13,
              poll.GLOBAL_ATTRIBUTE14,	  -- GLOBAL_ATTRIBUTE14,
              poll.GLOBAL_ATTRIBUTE15,	  -- GLOBAL_ATTRIBUTE15,
              poll.GLOBAL_ATTRIBUTE2,     -- GLOBAL_ATTRIBUTE2,
              poll.GLOBAL_ATTRIBUTE3,     -- GLOBAL_ATTRIBUTE3,
              poll.GLOBAL_ATTRIBUTE4,     -- GLOBAL_ATTRIBUTE4,
              poll.GLOBAL_ATTRIBUTE5,     -- GLOBAL_ATTRIBUTE5,
              poll.GLOBAL_ATTRIBUTE6,     -- GLOBAL_ATTRIBUTE6,
              poll.GLOBAL_ATTRIBUTE7,     -- GLOBAL_ATTRIBUTE7,
              poll.GLOBAL_ATTRIBUTE8,     -- GLOBAL_ATTRIBUTE8,
              poll.GLOBAL_ATTRIBUTE9,     -- GLOBAL_ATTRIBUTE9,
              'Y'	                  HISTORICAL_FLAG,
              -- NULL                     HQ_ESTB_PARTY_TAX_PROF_ID,
              -- NULL	                  HQ_ESTB_REG_NUMBER,
              -- NULL	                  INTERFACE_ENTITY_CODE,
              -- NULL                     INTERFACE_TAX_LINE_ID,
              -- NULL                     NAL_ORG_LOCATION_ID,
              nvl(poh.org_id,-99)         INTERNAL_ORGANIZATION_ID,
              'N'                         ITEM_DIST_CHANGED_FLAG,
              -- NULL	                  LAST_MANUAL_ENTRY,
              SYSDATE	                  LAST_UPDATE_DATE,
              1	                          LAST_UPDATE_LOGIN,
              1	                          LAST_UPDATED_BY,
              poh.set_of_books_id 	  LEDGER_ID,
              NVL(poh.org_information2,-99) LEGAL_ENTITY_ID,
              -- NULL                     LEGAL_ENTITY_TAX_REG_NUMBER ,
              -- NULL                     LEGAL_JUSTIFICATION_TEXT1,
              -- NULL	                  LEGAL_JUSTIFICATION_TEXT2,
              -- NULL	                  LEGAL_JUSTIFICATION_TEXT3,
              -- NULL                     LEGAL_MESSAGE_APPL_2,
              -- NULL	                  LEGAL_MESSAGE_BASIS,
              -- NULL	                  LEGAL_MESSAGE_CALC,
              -- NULL	                  LEGAL_MESSAGE_EXCPT,
              -- NULL	                  LEGAL_MESSAGE_EXMPT,
              -- NULL	                  LEGAL_MESSAGE_POS,
              -- NULL	                  LEGAL_MESSAGE_RATE,
              --  NULL                    LEGAL_MESSAGE_STATUS,
              -- NULL	                  LEGAL_MESSAGE_THRESHOLD,
              -- NULL	                  LEGAL_MESSAGE_TRN,
            DECODE(pol.purchase_basis,
             'TEMP LABOR', NVL(POLL.amount,0),
             'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                                NVL(poll.quantity,0) *
                                NVL(poll.price_override,NVL(pol.unit_price,0))),
              NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                          LINE_AMT,
              -- NULL	                  LINE_ASSESSABLE_VALUE,
              'N'	                  MANUALLY_ENTERED_FLAG,
              fc.minimum_accountable_unit MINIMUM_ACCOUNTABLE_UNIT,
              -- NULL	                  MRC_LINK_TO_TAX_LINE_ID,
              'N'	                  MRC_TAX_LINE_FLAG,
              -- NULL	                  NREC_TAX_AMT,
              -- NULL	                  NREC_TAX_AMT_FUNCL_CURR,
              -- NULL	                  NREC_TAX_AMT_TAX_CURR,
              -- NULL	                  NUMERIC1,
              -- NULL	                  NUMERIC10,
              -- NULL	                  NUMERIC2,
              -- NULL	                  NUMERIC3,
              -- NULL	                  NUMERIC4,
              -- NULL	                  NUMERIC5,
              -- NULL	                  NUMERIC6,
              -- NULL	                  NUMERIC7,
              -- NULL	                  NUMERIC8,
              -- NULL	                  NUMERIC9,
              1	                          OBJECT_VERSION_NUMBER,
              'N'	                  OFFSET_FLAG,
              -- NULL	                  OFFSET_LINK_TO_TAX_LINE_ID,
              -- NULL	                  OFFSET_TAX_RATE_CODE,
              'N'	                  ORIG_SELF_ASSESSED_FLAG,
              -- NULL	                  ORIG_TAX_AMT,
              -- NULL	                  ORIG_TAX_AMT_INCLUDED_FLAG,
              -- NULL	                  ORIG_TAX_AMT_TAX_CURR,
              -- NULL	                  ORIG_TAX_JURISDICTION_CODE,
              -- NULL	                  ORIG_TAX_JURISDICTION_ID,
              -- NULL	                  ORIG_TAX_RATE,
              -- NULL	                  ORIG_TAX_RATE_CODE,
              -- NULL	                  ORIG_TAX_RATE_ID,
              -- NULL	                  ORIG_TAX_STATUS_CODE,
              -- NULL	                  ORIG_TAX_STATUS_ID,
              -- NULL	                  ORIG_TAXABLE_AMT,
              -- NULL	                  ORIG_TAXABLE_AMT_TAX_CURR,
              -- NULL	                  OTHER_DOC_LINE_AMT,
              -- NULL	                  OTHER_DOC_LINE_TAX_AMT,
              -- NULL	                  OTHER_DOC_LINE_TAXABLE_AMT,
              -- NULL	                  OTHER_DOC_SOURCE,
              'N'	                  OVERRIDDEN_FLAG,
              -- NULL	                  PLACE_OF_SUPPLY,
              -- NULL	                  PLACE_OF_SUPPLY_RESULT_ID ,
              -- NULL                     PLACE_OF_SUPPLY_TYPE_CODE,
              -- NULL	                  PRD_TOTAL_TAX_AMT,
              -- NULL	                  PRD_TOTAL_TAX_AMT_FUNCL_CURR,
              -- NULL	                  PRD_TOTAL_TAX_AMT_TAX_CURR  ,
              NVL(fc.precision, 0)        PRECISION,
              -- fc.precision 	          PRECISION,
              'N'	                  PROCESS_FOR_RECOVERY_FLAG,
              NULL	                  PRORATION_CODE,
              'N'	                  PURGE_FLAG,
              -- NULL	                  RATE_RESULT_ID,
              -- NULL	                  REC_TAX_AMT,
              -- NULL	                  REC_TAX_AMT_FUNCL_CURR,
              -- NULL	                  REC_TAX_AMT_TAX_CURR,
              'N'	                  RECALC_REQUIRED_FLAG,
              'MIGRATED'                  RECORD_TYPE_CODE,
              -- NULL	                  REF_DOC_APPLICATION_ID,
              -- NULL	                  REF_DOC_ENTITY_CODE,
              -- NULL	                  REF_DOC_EVENT_CLASS_CODE,
              -- NULL	                  REF_DOC_LINE_ID,
              -- NULL	                  REF_DOC_LINE_QUANTITY,
              -- NULL	                  REF_DOC_TRX_ID,
              -- NULL	                  REF_DOC_TRX_LEVEL_TYPE,
              -- NULL	                  REGISTRATION_PARTY_TYPE,
              -- NULL	                  RELATED_DOC_APPLICATION_ID,
              -- NULL	                  RELATED_DOC_DATE,
              -- NULL	                  RELATED_DOC_ENTITY_CODE,
              -- NULL	                  RELATED_DOC_EVENT_CLASS_CODE,
              -- NULL	                  RELATED_DOC_NUMBER,
              -- NULL	                  RELATED_DOC_TRX_ID,
              -- NULL	                  RELATED_DOC_TRX_LEVEL_TYPE,
              -- NULL	                  REPORTING_CURRENCY_CODE,
             'N'	                  REPORTING_ONLY_FLAG,
              -- NULL	                  REPORTING_PERIOD_ID,
              -- NULL	                  ROUNDING_LEVEL_CODE,
              -- NULL	                  ROUNDING_LVL_PARTY_TAX_PROF_ID,
              -- NULL	                  ROUNDING_LVL_PARTY_TYPE,
              -- NULL	                  ROUNDING_RULE_CODE,
               'N'	                  SELF_ASSESSED_FLAG,
               'N'                        SETTLEMENT_FLAG,
              -- NULL                     STATUS_RESULT_ID,
              -- NULL                     SUMMARY_TAX_LINE_ID,
              -- NULL                     SYNC_WITH_PRVDR_FLAG,
              rates.tax                   TAX ,
              decode(FC.Minimum_Accountable_Unit, NULL,
               ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
               ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                * FC.Minimum_Accountable_Unit)
                                          TAX_AMT,
              decode(FC.Minimum_Accountable_Unit, NULL,
               ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
               ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                * FC.Minimum_Accountable_Unit)
                                          TAX_AMT_FUNCL_CURR,
              'N'                         TAX_AMT_INCLUDED_FLAG,
              decode(FC.Minimum_Accountable_Unit, NULL,
                ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
                ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                 * FC.Minimum_Accountable_Unit)
                                          TAX_AMT_TAX_CURR,
              -- NULL                     TAX_APPLICABILITY_RESULT_ID,
              'Y'                         TAX_APPORTIONMENT_FLAG,
               RANK() OVER
               (PARTITION BY
                 NVL(poll.po_release_id,
                     poh.po_header_id),
                 poll.line_location_id,
                 rates.tax_regime_code,
                 rates.tax
                ORDER BY atg.tax_code_id) TAX_APPORTIONMENT_LINE_NUMBER,
              -- NULL                     TAX_BASE_MODIFIER_RATE,
              'STANDARD_TC'               TAX_CALCULATION_FORMULA,
              -- NULL                     TAX_CODE,
              taxes.tax_currency_code     TAX_CURRENCY_CODE,
              poh.rate_date 		  TAX_CURRENCY_CONVERSION_DATE,
              poh.rate 		          TAX_CURRENCY_CONVERSION_RATE,
              poh.rate_type 		  TAX_CURRENCY_CONVERSION_TYPE,
              poll.last_update_date       TAX_DATE,
              -- NULL                     TAX_DATE_RULE_ID,
              poll.last_update_date       TAX_DETERMINE_DATE,
              'PURCHASE_TRANSACTION' 	  TAX_EVENT_CLASS_CODE,
              'VALIDATE'  		  TAX_EVENT_TYPE_CODE,
              -- NULL                     TAX_EXCEPTION_ID,
              -- NULL                     TAX_EXEMPTION_ID,
              -- NULL                     TAX_HOLD_CODE,
              -- NULL                     TAX_HOLD_RELEASED_CODE,
              taxes.tax_id                TAX_ID,
              -- NULL                     TAX_JURISDICTION_CODE,
              -- NULL                     TAX_JURISDICTION_ID,
              zx_lines_s.nextval          TAX_LINE_ID,
              RANK() OVER
               (PARTITION BY
                 NVL(poll.po_release_id,
                     poh.po_header_id)
                ORDER BY
                 poll.line_location_id,
                 atg.tax_code_id,
                 atc.tax_id)             TAX_LINE_NUMBER,
              'N'                        TAX_ONLY_LINE_FLAG,
               poll.last_update_date     TAX_POINT_DATE,
              -- NULL                    TAX_PROVIDER_ID,
              rates.percentage_rate  	 TAX_RATE,
              -- NULL	                 TAX_RATE_BEFORE_EXCEPTION,
              -- NULL                    TAX_RATE_BEFORE_EXEMPTION,
              rates.tax_rate_code        TAX_RATE_CODE,
              rates.tax_rate_id          TAX_RATE_ID,
              -- NULL                    TAX_RATE_NAME_BEFORE_EXCEPTION,
              -- NULL                    TAX_RATE_NAME_BEFORE_EXEMPTION,
              -- NULL                    TAX_RATE_TYPE,
              -- NULL                    TAX_REG_NUM_DET_RESULT_ID,
              rates.tax_regime_code      TAX_REGIME_CODE,
              regimes.tax_regime_id      TAX_REGIME_ID,
              -- NULL                    TAX_REGIME_TEMPLATE_ID,
              -- NULL                    TAX_REGISTRATION_ID,
              -- NULL                    TAX_REGISTRATION_NUMBER,
              rates.tax_status_code      TAX_STATUS_CODE,
              status.tax_status_id       TAX_STATUS_ID,
              -- NULL                    TAX_TYPE_CODE,
              -- NULL                    TAXABLE_AMT,
              -- NULL                    TAXABLE_AMT_FUNCL_CURR,
              -- NULL                    TAXABLE_AMT_TAX_CURR,
              'STANDARD_TB'              TAXABLE_BASIS_FORMULA ,
              -- NULL                    TAXING_JURIS_GEOGRAPHY_ID ,
              -- NULL                    THRESH_RESULT_ID,
              NVL(poh.currency_code,
                 poh.base_currency_code) TRX_CURRENCY_CODE,
              poh.last_update_date       TRX_DATE,
              -- poh.po_header_id        TRX_ID,
              NVL(poll.po_release_id,
                   poh.po_header_id)     TRX_ID,
              -- NULL                    TRX_ID_LEVEL2,
              -- NULL                    TRX_ID_LEVEL3,
              -- NULL                    TRX_ID_LEVEL4,
              -- NULL                    TRX_ID_LEVEL5,
              -- NULL                    TRX_ID_LEVEL6,
              'SHIPMENT'                 TRX_LEVEL_TYPE,
              poll.LAST_UPDATE_DATE      TRX_LINE_DATE ,
              poll.line_location_id      TRX_LINE_ID,
              -- NULL                    TRX_LINE_INDEX,
              poll.SHIPMENT_NUM          TRX_LINE_NUMBER,
              poll.quantity 		 TRX_LINE_QUANTITY ,
              poh.segment1               TRX_NUMBER,
              -- NULL                    TRX_USER_KEY_LEVEL1,
              -- NULL                    TRX_USER_KEY_LEVEL2,
              -- NULL                    TRX_USER_KEY_LEVEL3,
              -- NULL                    TRX_USER_KEY_LEVEL4,
              -- NULL                    TRX_USER_KEY_LEVEL5,
              -- NULL                    TRX_USER_KEY_LEVEL6,
              NVL(poll.price_override,
                   pol.unit_price)       UNIT_PRICE,
              -- pol.unit_price          UNIT_PRICE,
              -- NULL                    UNROUNDED_TAX_AMT,
              -- NULL                    UNROUNDED_TAXABLE_AMT,
              'N'                        MULTIPLE_JURISDICTIONS_FLAG
         FROM
             (SELECT /*+ NO_MERGE NO_EXPAND ROWID(poh) use_hash(fsp) use_hash(aps)
                         swap_join_inputs(fsp) swap_join_inputs(upd)
                         swap_join_inputs(aps) swap_join_inputs(oi)*/
              	     poh.* , fsp.org_id fsp_org_id, fsp.set_of_books_id,
              	     aps.base_currency_code, oi.org_information2
                FROM po_headers_all poh,
              	     financials_system_params_all fsp,
              	     xla_upgrade_dates upd,
           	     ap_system_parameters_all aps,
           	     hr_organization_information oi
               WHERE poh.rowid BETWEEN p_start_rowid AND p_end_rowid
                 AND NVL(poh.closed_code, 'X') <> 'FINALLY CLOSED'
                 AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
                 AND upd.ledger_id = fsp.set_of_books_id
                 AND NVL(aps.org_id, -99) = NVL(fsp.org_id,-99)
                 AND aps.set_of_books_id = fsp.set_of_books_id
                 AND (poh.last_update_date between upd.start_date and upd.end_date)
                 AND oi.organization_id(+) = poh.org_id
                 AND oi.org_information_context(+) = 'Operating Unit Information'
             )  poh,
                fnd_currencies fc,
                po_lines_all pol,
                po_line_locations_all poll,
                zx_party_tax_profile ptp,
                ap_tax_codes_all atc,
                ar_tax_group_codes_all atg,
                ap_tax_codes_all atc1,
                zx_rates_b rates,
                zx_regimes_b regimes,
                zx_taxes_b taxes,
                zx_status_b status
          WHERE NVL(poh.currency_code, poh.base_currency_code) = fc.currency_code(+)
            AND poh.po_header_id = pol.po_header_id
            AND pol.po_header_id = poll.po_header_id
            AND pol.po_line_id = poll.po_line_id
            AND nvl(atc.org_id,-99)=nvl(poh.fsp_org_id,-99)
            AND poll.tax_code_id = atc.tax_id
            AND atc.tax_type = 'TAX_GROUP'
            AND poll.tax_code_id = atg.tax_group_id
            AND atg.start_date <= poll.last_update_date
            AND (atg.end_date >= poll.last_update_date OR atg.end_date IS NULL)
            AND atc1.tax_id = atg.tax_code_id
            AND atc1.start_date <= poll.last_update_date
            AND(atc1.inactive_date >= poll.last_update_date OR atc1.inactive_date IS NULL)
            AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
            AND ptp.party_type_code = 'OU'
            AND rates.source_id = atg.tax_code_id
            AND regimes.tax_regime_code(+) = rates.tax_regime_code
            AND taxes.tax_regime_code(+) = rates.tax_regime_code
            AND taxes.tax(+) = rates.tax
            AND taxes.content_owner_id(+) = rates.content_owner_id
            AND status.tax_regime_code(+) = rates.tax_regime_code
            AND status.tax(+) = rates.tax
            AND status.content_owner_id(+) = rates.content_owner_id
            AND status.tax_status_code(+) = rates.tax_status_code
            AND NOT EXISTS
                (SELECT 1 FROM zx_lines zxl
                  WHERE zxl.APPLICATION_ID   = 201
                    AND zxl.EVENT_CLASS_CODE = NVL2(poll.po_release_id, 'RELEASE', 'PO_PA')
                    AND zxl.TRX_ID           = NVL(poll.po_release_id, poh.po_header_id)
                    AND zxl.ENTITY_CODE	     = NVL2(poll.po_release_id, 'RELEASE','PURCHASE_ORDER'));

    -- COMMIT;

 INSERT INTO ZX_REC_NREC_DIST
             (TAX_LINE_ID
              ,REC_NREC_TAX_DIST_ID
              ,REC_NREC_TAX_DIST_NUMBER
              ,APPLICATION_ID
              ,CONTENT_OWNER_ID
              ,CURRENCY_CONVERSION_DATE
              ,CURRENCY_CONVERSION_RATE
              ,CURRENCY_CONVERSION_TYPE
              ,ENTITY_CODE
              ,EVENT_CLASS_CODE
              ,EVENT_TYPE_CODE
              ,LEDGER_ID
              ,MINIMUM_ACCOUNTABLE_UNIT
              ,PRECISION
              ,RECORD_TYPE_CODE
              -- ,REF_DOC_APPLICATION_ID
              -- ,REF_DOC_ENTITY_CODE
              -- ,REF_DOC_EVENT_CLASS_CODE
              -- ,REF_DOC_LINE_ID
              -- ,REF_DOC_TRX_ID
              -- ,REF_DOC_TRX_LEVEL_TYPE
              -- ,SUMMARY_TAX_LINE_ID
              ,TAX
              ,TAX_APPORTIONMENT_LINE_NUMBER
              ,TAX_CURRENCY_CODE
              ,TAX_CURRENCY_CONVERSION_DATE
              ,TAX_CURRENCY_CONVERSION_RATE
              ,TAX_CURRENCY_CONVERSION_TYPE
              ,TAX_EVENT_CLASS_CODE
              ,TAX_EVENT_TYPE_CODE
              ,TAX_ID
              ,TAX_LINE_NUMBER
              ,TAX_RATE
              ,TAX_RATE_CODE
              ,TAX_RATE_ID
              ,TAX_REGIME_CODE
              ,TAX_REGIME_ID
              ,TAX_STATUS_CODE
              ,TAX_STATUS_ID
              ,TRX_CURRENCY_CODE
              ,TRX_ID
              ,TRX_LEVEL_TYPE
              ,TRX_LINE_ID
              ,TRX_LINE_NUMBER
              ,TRX_NUMBER
              ,UNIT_PRICE
              -- ,ACCOUNT_CCID
              -- ,ACCOUNT_STRING
              -- ,ADJUSTED_DOC_TAX_DIST_ID
              -- ,APPLIED_FROM_TAX_DIST_ID
              -- ,APPLIED_TO_DOC_CURR_CONV_RATE
              -- ,AWARD_ID
              ,EXPENDITURE_ITEM_DATE
              ,EXPENDITURE_ORGANIZATION_ID
              ,EXPENDITURE_TYPE
              -- ,FUNC_CURR_ROUNDING_ADJUSTMENT
              -- ,GL_DATE
              -- ,INTENDED_USE
              -- ,ITEM_DIST_NUMBER
              -- ,MRC_LINK_TO_TAX_DIST_ID
              -- ,ORIG_REC_NREC_RATE
              -- ,ORIG_REC_NREC_TAX_AMT
              -- ,ORIG_REC_NREC_TAX_AMT_TAX_CURR
              -- ,ORIG_REC_RATE_CODE
              -- ,PER_TRX_CURR_UNIT_NR_AMT
              -- ,PER_UNIT_NREC_TAX_AMT
              -- ,PRD_TAX_AMT
              -- ,PRICE_DIFF
              ,PROJECT_ID
              -- ,QTY_DIFF
              -- ,RATE_TAX_FACTOR
              ,REC_NREC_RATE
              ,REC_NREC_TAX_AMT
              ,REC_NREC_TAX_AMT_FUNCL_CURR
              ,REC_NREC_TAX_AMT_TAX_CURR
              ,RECOVERY_RATE_CODE
              ,RECOVERY_RATE_ID
              ,RECOVERY_TYPE_CODE
              -- ,RECOVERY_TYPE_ID
              -- ,REF_DOC_CURR_CONV_RATE
              -- ,REF_DOC_DIST_ID
              -- ,REF_DOC_PER_UNIT_NREC_TAX_AMT
              -- ,REF_DOC_TAX_DIST_ID
              -- ,REF_DOC_TRX_LINE_DIST_QTY
              -- ,REF_DOC_UNIT_PRICE
              -- ,REF_PER_TRX_CURR_UNIT_NR_AMT
              -- ,REVERSED_TAX_DIST_ID
              -- ,ROUNDING_RULE_CODE
              ,TASK_ID
              -- ,TAXABLE_AMT_FUNCL_CURR
              -- ,TAXABLE_AMT_TAX_CURR
              -- ,TRX_LINE_DIST_AMT
              ,TRX_LINE_DIST_ID
              -- ,TRX_LINE_DIST_QTY
              -- ,TRX_LINE_DIST_TAX_AMT
              -- ,UNROUNDED_REC_NREC_TAX_AMT
              -- ,UNROUNDED_TAXABLE_AMT
              -- ,TAXABLE_AMT
              ,ATTRIBUTE_CATEGORY
              ,ATTRIBUTE1
              ,ATTRIBUTE2
              ,ATTRIBUTE3
              ,ATTRIBUTE4
              ,ATTRIBUTE5
              ,ATTRIBUTE6
              ,ATTRIBUTE7
              ,ATTRIBUTE8
              ,ATTRIBUTE9
              ,ATTRIBUTE10
              ,ATTRIBUTE11
              ,ATTRIBUTE12
              ,ATTRIBUTE13
              ,ATTRIBUTE14
              ,ATTRIBUTE15
              ,HISTORICAL_FLAG
              ,OVERRIDDEN_FLAG
              ,SELF_ASSESSED_FLAG
              ,TAX_APPORTIONMENT_FLAG
              ,TAX_ONLY_LINE_FLAG
              ,INCLUSIVE_FLAG
              ,MRC_TAX_DIST_FLAG
              ,REC_TYPE_RULE_FLAG
              ,NEW_REC_RATE_CODE_FLAG
              ,RECOVERABLE_FLAG
              ,REVERSE_FLAG
              ,REC_RATE_DET_RULE_FLAG
              ,BACKWARD_COMPATIBILITY_FLAG
              ,FREEZE_FLAG
              ,POSTING_FLAG
              ,LEGAL_ENTITY_ID
              ,CREATED_BY
              ,CREATION_DATE
              ,LAST_MANUAL_ENTRY
              ,LAST_UPDATE_DATE
              ,LAST_UPDATE_LOGIN
              ,LAST_UPDATED_BY
              ,OBJECT_VERSION_NUMBER
             )
    SELECT /*+ NO_EXPAND leading(pohzd) use_nl(fc, rates)*/
           pohzd.tax_line_id		  TAX_LINE_ID,
           zx_rec_nrec_dist_s.nextval     REC_NREC_TAX_DIST_ID,
           RANK() OVER
           (PARTITION BY pohzd.trx_id,
             pohzd.p_po_distribution_id
            ORDER BY pohzd.tax_rate_id,
                     tmp.rec_flag)        REC_NREC_TAX_DIST_NUMBER,
           201 				  APPLICATION_ID,
           pohzd.content_owner_id,        -- CONTENT_OWNER_ID
           pohzd.CURRENCY_CONVERSION_DATE,
           pohzd.CURRENCY_CONVERSION_RATE,
           pohzd.CURRENCY_CONVERSION_TYPE,
           pohzd.ENTITY_CODE,             -- ENTITY_CODE,
           pohzd.EVENT_CLASS_CODE,        -- EVENT_CLASS_CODE,
           'PURCHASE ORDER CREATED'	  EVENT_TYPE_CODE,
           pohzd.ledger_id,		  -- LEDGER_ID,
           pohzd.MINIMUM_ACCOUNTABLE_UNIT,
           pohzd.PRECISION,		  -- PRECISION,
           'MIGRATED' 			  RECORD_TYPE_CODE,
           -- NULL 			  REF_DOC_APPLICATION_ID,
           -- NULL 			  REF_DOC_ENTITY_CODE,
           -- NULL			  REF_DOC_EVENT_CLASS_CODE,
           -- NULL			  REF_DOC_LINE_ID,
           -- NULL			  REF_DOC_TRX_ID,
           -- NULL			  REF_DOC_TRX_LEVEL_TYPE,
           -- NULL 			  SUMMARY_TAX_LINE_ID,
           pohzd.tax			  TAX,
           pohzd.TAX_APPORTIONMENT_LINE_NUMBER,
           pohzd.TAX_CURRENCY_CODE,       -- TAX_CURRENCY_CODE,
           pohzd.TAX_CURRENCY_CONVERSION_DATE, -- TAX_CURRENCY_CONVERSION_DATE,
           pohzd.TAX_CURRENCY_CONVERSION_RATE, -- TAX_CURRENCY_CONVERSION_RATE,
           pohzd.TAX_CURRENCY_CONVERSION_TYPE, -- TAX_CURRENCY_CONVERSION_TYPE,
           'PURCHASE_TRANSACTION' 	  TAX_EVENT_CLASS_CODE,
           'VALIDATE'			  TAX_EVENT_TYPE_CODE,
           pohzd.tax_id,                  -- TAX_ID,
           pohzd.tax_line_number,         -- TAX_LINE_NUMBER,
           pohzd.tax_rate,                -- TAX_RATE,
           pohzd.tax_rate_code,           -- TAX_RATE_CODE,
           pohzd.tax_rate_id,             -- TAX_RATE_ID,
           pohzd.tax_regime_code,         -- TAX_REGIME_CODE,
           pohzd.tax_regime_id ,          -- TAX_REGIME_ID,
           pohzd.tax_status_code,         -- TAX_STATUS_CODE,
           pohzd.tax_status_id,           -- TAX_STATUS_ID,
           pohzd.trx_currency_code,       -- TRX_CURRENCY_CODE,
           pohzd.trx_id,                  -- TRX_ID,
           'SHIPMENT' 			  TRX_LEVEL_TYPE,
           pohzd.trx_line_id,             -- TRX_LINE_ID,
           pohzd.trx_line_number,         -- TRX_LINE_NUMBER,
           pohzd.trx_number,              -- TRX_NUMBER,
           pohzd.unit_price,              -- UNIT_PRICE,
           -- NULL			  ACCOUNT_CCID,
           -- NULL			  ACCOUNT_STRING,
           -- NULL			  ADJUSTED_DOC_TAX_DIST_ID,
           -- NULL			  APPLIED_FROM_TAX_DIST_ID,
           -- NULL			  APPLIED_TO_DOC_CURR_CONV_RATE,
           -- NULL			  AWARD_ID,
           pohzd.p_expenditure_item_date  EXPENDITURE_ITEM_DATE,
           pohzd.p_expenditure_organization_id EXPENDITURE_ORGANIZATION_ID,
           pohzd.p_expenditure_type	  EXPENDITURE_TYPE              ,
           -- NULL			  FUNC_CURR_ROUNDING_ADJUSTMENT,
           -- NULL			  GL_DATE,
           -- NULL			  INTENDED_USE,
           -- NULL			  ITEM_DIST_NUMBER,
           -- NULL			  MRC_LINK_TO_TAX_DIST_ID,
           -- NULL			  ORIG_REC_NREC_RATE,
           -- NULL			  ORIG_REC_NREC_TAX_AMT,
           -- NULL			  ORIG_REC_NREC_TAX_AMT_TAX_CURR,
           -- NULL			  ORIG_REC_RATE_CODE,
           -- NULL			  PER_TRX_CURR_UNIT_NR_AMT,
           -- NULL			  PER_UNIT_NREC_TAX_AMT,
           -- NULL			  PRD_TAX_AMT,
           -- NULL			  PRICE_DIFF,
           pohzd.p_project_id	          PROJECT_ID,
           -- NULL			  QTY_DIFF,
           -- NULL			  RATE_TAX_FACTOR,
           DECODE(tmp.rec_flag,
            'Y', NVL(NVL(pohzd.p_recovery_rate, pohzd.d_rec_rate), 0),
            'N', 100 - NVL(NVL(pohzd.p_recovery_rate, pohzd.d_rec_rate), 0))
                                          REC_NREC_RATE,
           DECODE(tmp.rec_flag,
              'N',
               DECODE(fc.Minimum_Accountable_Unit,null,
                 ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                      (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                 ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                        NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                           (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
              'Y',
               DECODE(fc.Minimum_Accountable_Unit,null,
                (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                  ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                        (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                  ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                         NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                            (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                 )                        REC_NREC_TAX_AMT,
           DECODE(tmp.rec_flag,
              'N',
               DECODE(fc.Minimum_Accountable_Unit,null,
                 ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                      (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                 ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                        nvl(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                           (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
              'Y',
               DECODE(fc.Minimum_Accountable_Unit,null,
                (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                  ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                        (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                  ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                         NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                            (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                 )                        REC_NREC_TAX_AMT_FUNCL_CURR,
           DECODE(tmp.rec_flag,
              'N',
               DECODE(fc.Minimum_Accountable_Unit,null,
                 ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                      (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                 ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                        nvl(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                           (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
              'Y',
               DECODE(fc.Minimum_Accountable_Unit,null,
                (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                  ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                        (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                  ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                         NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                            (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                 )                        REC_NREC_TAX_AMT_TAX_CURR,
           NVL(rates.tax_rate_code,
               'AD_HOC_RECOVERY')         RECOVERY_RATE_CODE,
           rates.tax_rate_id              RECOVERY_RATE_ID,
           DECODE(tmp.rec_flag,'N', NULL,
            NVL(rates.recovery_type_code,
                            'STANDARD'))  RECOVERY_TYPE_CODE,
           -- NULL			  RECOVERY_TYPE_ID,
           -- NULL			  REF_DOC_CURR_CONV_RATE,
           -- NULL			  REF_DOC_DIST_ID,
           -- NULL			  REF_DOC_PER_UNIT_NREC_TAX_AMT,
           -- NULL			  REF_DOC_TAX_DIST_ID,
           -- NULL			  REF_DOC_TRX_LINE_DIST_QTY,
           -- NULL			  REF_DOC_UNIT_PRICE,
           -- NULL			  REF_PER_TRX_CURR_UNIT_NR_AMT,
           -- NULL			  REVERSED_TAX_DIST_ID,
           -- NULL			  ROUNDING_RULE_CODE,
           pohzd.p_task_id		  TASK_ID,
           -- null			  TAXABLE_AMT_FUNCL_CURR,
           -- NULL			  TAXABLE_AMT_TAX_CURR,
           -- NULL			  TRX_LINE_DIST_AMT,
           pohzd.p_po_distribution_id	  TRX_LINE_DIST_ID,
           -- NULL			  TRX_LINE_DIST_QTY,
           -- NULL			  TRX_LINE_DIST_TAX_AMT,
           -- NULL			  UNROUNDED_REC_NREC_TAX_AMT,
           -- NULL			  UNROUNDED_TAXABLE_AMT,
           -- NULL			  TAXABLE_AMT,
           pohzd.p_ATTRIBUTE_CATEGORY     ATTRIBUTE_CATEGORY,
           pohzd.p_ATTRIBUTE1             ATTRIBUTE1,
           pohzd.p_ATTRIBUTE2             ATTRIBUTE2,
           pohzd.p_ATTRIBUTE3             ATTRIBUTE3,
           pohzd.p_ATTRIBUTE4             ATTRIBUTE4,
           pohzd.p_ATTRIBUTE5             ATTRIBUTE5,
           pohzd.p_ATTRIBUTE6             ATTRIBUTE6,
           pohzd.p_ATTRIBUTE7             ATTRIBUTE7,
           pohzd.p_ATTRIBUTE8             ATTRIBUTE8,
           pohzd.p_ATTRIBUTE9             ATTRIBUTE9,
           pohzd.p_ATTRIBUTE10            ATTRIBUTE10,
           pohzd.p_ATTRIBUTE11            ATTRIBUTE11,
           pohzd.p_ATTRIBUTE12            ATTRIBUTE12,
           pohzd.p_ATTRIBUTE13            ATTRIBUTE13,
           pohzd.p_ATTRIBUTE14            ATTRIBUTE14,
           pohzd.p_ATTRIBUTE15            ATTRIBUTE15,
           'Y'			          HISTORICAL_FLAG,
           'N'			          OVERRIDDEN_FLAG,
           'N'			          SELF_ASSESSED_FLAG,
           'Y'			          TAX_APPORTIONMENT_FLAG,
           'N'			          TAX_ONLY_LINE_FLAG,
           'N'			          INCLUSIVE_FLAG,
           'N'			          MRC_TAX_DIST_FLAG,
           'N'			          REC_TYPE_RULE_FLAG,
           'N'			          NEW_REC_RATE_CODE_FLAG,
           tmp.rec_flag                   RECOVERABLE_FLAG,
           'N'			          REVERSE_FLAG,
           'N'			          REC_RATE_DET_RULE_FLAG,
           'Y'			          BACKWARD_COMPATIBILITY_FLAG,
           'N'			          FREEZE_FLAG,
           'N'			          POSTING_FLAG,
           NVL(pohzd.legal_entity_id,-99) LEGAL_ENTITY_ID,
           1			          CREATED_BY,
           SYSDATE		          CREATION_DATE,
           NULL		                  LAST_MANUAL_ENTRY,
           SYSDATE		          LAST_UPDATE_DATE,
           1			          LAST_UPDATE_LOGIN,
           1			          LAST_UPDATED_BY,
           1			          OBJECT_VERSION_NUMBER
     FROM (SELECT /*+ use_nl_with_index(recdist ZX_PO_REC_DIST_N1) */
                  pohzd.*,
                  recdist.rec_rate     d_rec_rate
            FROM (SELECT /*+ NO_EXPAND leading(poh) ordered use_nl_with_index(zxl, ZX_LINES_U1) use_nl(pod) */
                        poh.po_header_id,
                        poh.set_of_books_id,
                        poh.last_update_date poh_last_update_date,
                        zxl.tax_line_id,
			                  zxl.trx_id,
			                  zxl.tax_rate_id,
			                  zxl.content_owner_id,
			                  zxl.CURRENCY_CONVERSION_DATE,
			                  zxl.CURRENCY_CONVERSION_RATE,
			                  zxl.CURRENCY_CONVERSION_TYPE,
			                  zxl.ENTITY_CODE,
			                  zxl.EVENT_CLASS_CODE,
			                  zxl.ledger_id,
			                  zxl.MINIMUM_ACCOUNTABLE_UNIT,
			                  zxl.PRECISION,
			                  zxl.tax,
			                  zxl.TAX_APPORTIONMENT_LINE_NUMBER,
			                  zxl.TAX_CURRENCY_CODE,
			                  zxl.TAX_CURRENCY_CONVERSION_DATE,
			                  zxl.TAX_CURRENCY_CONVERSION_RATE,
			                  zxl.TAX_CURRENCY_CONVERSION_TYPE,
			                  zxl.tax_id,
			                  zxl.tax_line_number,
			                  zxl.tax_rate,
			                  zxl.tax_rate_code,
			                  zxl.tax_regime_code,
			                  zxl.tax_regime_id ,
			                  zxl.tax_status_code,
			                  zxl.tax_status_id,
			                  zxl.trx_currency_code,
			                  zxl.trx_line_id,
			                  zxl.trx_line_number,
			                  zxl.trx_number,
			                  zxl.unit_price,
			                  zxl.legal_entity_id,
                        pod.po_distribution_id                  p_po_distribution_id,
                        pod.expenditure_item_date               p_expenditure_item_date,
                        pod.expenditure_organization_id         p_expenditure_organization_id,
                        pod.expenditure_type                    p_expenditure_type,
                        pod.project_id                          p_project_id,
                        pod.task_id                             p_task_id,
                        pod.recovery_rate                       p_recovery_rate,
                        pod.quantity_ordered                    p_quantity_ordered,
                        pod.attribute_category                  p_attribute_category ,
                        pod.attribute1                          p_attribute1,
                        pod.attribute2                          p_attribute2,
                        pod.attribute3                          p_attribute3,
                        pod.attribute4                          p_attribute4,
                        pod.attribute5                          p_attribute5,
                        pod.attribute6                          p_attribute6,
                        pod.attribute7                          p_attribute7,
                        pod.attribute8                          p_attribute8,
                        pod.attribute9                          p_attribute9,
                        pod.attribute10                         p_attribute10,
                        pod.attribute11                         p_attribute11,
                        pod.attribute12                         p_attribute12,
                        pod.attribute13                         p_attribute13,
                        pod.attribute14                         p_attribute14,
                        pod.attribute15                         p_attribute15
                   FROM (SELECT /*+  NO_EXPAND leading(upd,fsp,poh) ROWID(poh) use_hash(fsp) swap_join_inputs(fsp)
                                    use_hash(upd) swap_join_inputs(upd) use_nl(poll)*/
                                poh.po_header_id,
                                fsp.set_of_books_id,
                                poh.last_update_date,
                                poll.line_location_id,
                                poll.po_release_id,
                                NVL2(poll.po_release_id, 'RELEASE', 'PURCHASE_ORDER') entity_code,
                                NVL2(poll.po_release_id, 'RELEASE', 'PO_PA') event_class_code,
                                NVL(poll.po_release_id, poh.po_header_id) trx_id
                        FROM	po_headers_all poh,
                       	        financials_system_params_all fsp,
                 	        xla_upgrade_dates upd,
                                po_line_locations_all poll
                          WHERE poh.rowid BETWEEN p_start_rowid AND p_end_rowid
                            AND NVL(poh.closed_code, 'X') <> 'FINALLY CLOSED'
                            AND NVL(poh.org_id, -99) = NVL(fsp.org_id, -99)
                            AND upd.ledger_id = fsp.set_of_books_id
                            AND (poh.last_update_date between upd.start_date and upd.end_date)
                            AND poll.po_header_id = poh.po_header_id
                      ) poh,
                        zx_lines zxl,
                        po_distributions_all pod
                  WHERE zxl.application_id = 201
                    AND zxl.entity_code = poh.entity_code
                    AND zxl.event_class_code = poh.event_class_code
                    AND zxl.trx_id = poh.trx_id
                    AND zxl.trx_line_id = poh.line_location_id
                    AND pod.po_header_id = poh.po_header_id
                    AND pod.line_location_id = poh.line_location_id
                 ) pohzd,
                   zx_po_rec_dist recdist
             WHERE recdist.po_header_id(+) = pohzd.trx_id
               AND recdist.po_line_location_id(+) = pohzd.trx_line_id
               AND recdist.po_distribution_id(+) = pohzd.p_po_distribution_id
               AND recdist.tax_rate_id(+) = pohzd.tax_rate_id
          ) pohzd,
          fnd_currencies fc,
          zx_rates_b rates,
          (SELECT 'Y' rec_flag FROM dual UNION ALL SELECT 'N' rec_flag FROM dual) tmp
    WHERE pohzd.trx_currency_code = fc.currency_code(+)
      AND rates.tax_regime_code(+) = pohzd.tax_regime_code
      AND rates.tax(+) = pohzd.tax
      AND rates.content_owner_id(+) = pohzd.content_owner_id
      AND rates.rate_type_code(+) = 'RECOVERY'
      AND rates.recovery_type_code(+) = 'STANDARD'
      AND rates.active_flag(+) = 'Y'
      AND rates.effective_from(+) <= sysdate
      AND pohzd.poh_last_update_date BETWEEN rates.effective_from AND NVL(rates.effective_to, pohzd.poh_last_update_date)
      AND rates.record_type_code(+) = 'MIGRATED'
      AND rates.percentage_rate(+) = NVL(NVL(pohzd.p_recovery_rate, pohzd.d_rec_rate),0)
      AND rates.tax_rate_code(+) NOT LIKE 'AD_HOC_RECOVERY%'
      AND NOT EXISTS
         (SELECT 1 FROM zx_rec_nrec_dist zxdist
           WHERE zxdist.APPLICATION_ID   = 201
             AND zxdist.ENTITY_CODE	 = pohzd.ENTITY_CODE
             AND zxdist.EVENT_CLASS_CODE = pohzd.EVENT_CLASS_CODE
             AND zxdist.TRX_ID		 = pohzd.trx_id );

    x_rows_processed := SQL%ROWCOUNT;

    IF g_level_procedure >= g_current_runtime_level THEN
      FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_PO_TRX_MIG','Worker: '||p_worker_id||' x_rows_processed is  ' || x_rows_processed );
      FND_LOG.STRING(g_level_procedure,'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_PO_TRX_MIG','Worker: '||p_worker_id||' zx_po_trx_mig (-)' );
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    X_retcode := CONC_FAIL;
    IF g_level_unexpected >= g_current_runtime_level THEN
      FND_LOG.STRING(g_level_unexpected,
        'ZX_ON_DEMAND_TRX_UPGRADE_PKG.ZX_PO_TRX_MIG',
        'Worker: '||p_worker_id||'Raised exceptions: '||
         sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80) );
    END IF;
    raise;

  END zx_po_trx_mig;

END ZX_ON_DEMAND_TRX_UPGRADE_PKG;

/
