--------------------------------------------------------
--  DDL for Package Body POR_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_TAX_PVT" AS
/* $Header: PORVTAXB.pls 120.10.12010000.15 2014/08/01 04:25:08 jaxin ship $ */


  -- Logging Static Variables
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED	       CONSTANT NUMBER	     := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR 	       CONSTANT NUMBER	     := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION	       CONSTANT NUMBER	     := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT 	       CONSTANT NUMBER	     := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE	       CONSTANT NUMBER	     := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT	       CONSTANT NUMBER	     := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME 	       CONSTANT VARCHAR2(30) := 'PO.PLSQL.POR_TAX_PVT';

PROCEDURE calculate_tax (p_tax_head_tbl         IN  POR_TAX_HEADER_OBJ_TBL_TYPE,
                         p_tax_line_tbl         IN  POR_TAX_LINE_OBJ_TBL_TYPE,
                         p_tax_dist_tbl         IN  POR_TAX_DIST_OBJ_TBL_TYPE,
                         x_tax_dist_id_tbl      OUT NOCOPY ICX_TBL_NUMBER,
                         x_tax_recov_amt_tbl    OUT NOCOPY ICX_TBL_NUMBER,
	                 x_tax_nonrecov_amt_tbl OUT NOCOPY ICX_TBL_NUMBER,
                         x_return_status        OUT NOCOPY VARCHAR2,
                         x_msg_data             OUT NOCOPY VARCHAR2,
                         x_msg_count            OUT NOCOPY NUMBER) IS

  l_legal_entity_id      PLS_INTEGER;
  i                      PLS_INTEGER;
  tbl_sz_line            PLS_INTEGER;
  j                      PLS_INTEGER;
  tbl_sz_dist            PLS_INTEGER;
  acc_ccid		 NUMBER;
  l_msg_count            NUMBER;
  l_return_status        VARCHAR2(60);
  l_msg_data             VARCHAR2(480);
  l_dist_id              PLS_INTEGER;
  l_recov_tax            NUMBER;
  l_non_recov_tax        NUMBER;
  l_progress             PLS_INTEGER;


  -- Logging Infra
  l_procedure_name       CONSTANT VARCHAR2(30) := 'calculate_tax';
  l_log_msg              FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  --Bug 7412966 : Changed the code to calculate the rec and non-rec tax in functional currency
   CURSOR c_get_tax IS
   SELECT trx_line_dist_id,
          sum(decode(recoverable_flag, 'Y', rec_nrec_tax_amt_funcl_curr, 0)) as recov_tax,
          sum(decode(recoverable_flag, 'N', rec_nrec_tax_amt_funcl_curr, 0)) as non_recov_tax
   FROM ZX_REC_NREC_DIST_GT
   GROUP BY trx_line_dist_id;

BEGIN
  l_progress := 0;

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := '<-------------------->';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
    l_log_msg := l_procedure_name||'(+)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;

  -- delete from ZX_TRX_HEADERS_GT
  DELETE ZX_TRX_HEADERS_GT;

  l_progress := 100;

  -- Logging Infra: Statement level
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'Deleted ZX_TRX_HEADERS_GT';
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  -- get legal entity id
  l_legal_entity_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(p_tax_head_tbl(1).org_id);

  -- Logging Infra: Statement level
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'XLE Legal Entity=' || l_legal_entity_id;
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  l_progress := 200;

  -- insert into ZX Headers global temp table
  INSERT INTO ZX_TRX_HEADERS_GT (internal_organization_id,
                                 icx_session_id,
                                 application_id,
                                 entity_code,
                                 event_class_code,
                                 event_type_code,
                                 trx_id,
                                 trx_date,
                                 ledger_id,
                                 legal_entity_id,
                                 rounding_bill_to_party_id,
                                 default_taxation_country,
                                 quote_flag,
                                 document_sub_type)
                          VALUES(p_tax_head_tbl(1).org_id,
                                 p_tax_head_tbl(1).icx_session_id,
                                 201,
                                 'REQUISITION',
                                 'REQUISITION',
                                 'REQ_CREATED',
                                 p_tax_head_tbl(1).trx_id,
                                 p_tax_head_tbl(1).trx_date,
                                 p_tax_head_tbl(1).ledger_id,
                                 l_legal_entity_id,
                                 p_tax_head_tbl(1).rndg_bill_to_party_id,
                                 p_tax_head_tbl(1).taxation_country,
                                 'Y',
                                 p_tax_head_tbl(1).doc_subtype);

  l_progress := 300;

  -- Logging Infra: Statement level
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'Inserted into ZX_TRX_HEADERS_GT';
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  -- delete from ZX_TRANSACTION_LINES_GT
  DELETE ZX_TRANSACTION_LINES_GT;

  l_progress := 400;

  -- Logging Infra: Statement level
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'Deleted from ZX_TRANSACTION_LINES_GT';
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  -- insert into ZX Lines global temp table
  i := 1;
  j := 1;
  tbl_sz_line := p_tax_line_tbl.count();
  tbl_sz_dist := p_tax_dist_tbl.count();

  LOOP

	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
		l_log_msg := 'Getting the Account_CCID for the Line ID >>> '|| p_tax_line_tbl(i).trx_line_id;
	        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
	END IF;

	LOOP
		IF (p_tax_line_tbl(i).trx_line_id=p_tax_dist_tbl(j).trx_line_id) THEN --- bug 12769270 changed condition from trx_id to trx_line_id
			acc_ccid := p_tax_dist_tbl(j).account_ccid;
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
				l_log_msg := 'Account_CCID >>> '||acc_ccid||' for the Line ID >>> '|| p_tax_line_tbl(i).trx_line_id;
			        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
			END IF;
			EXIT;
		END IF;
		j := j+1;
	EXIT WHEN j > tbl_sz_dist;
	END LOOP ;

    INSERT INTO ZX_TRANSACTION_LINES_GT( application_id,
                                 entity_code,
                                 event_class_code,
                                 trx_id,
                                 trx_level_type,
                                 trx_line_id,
                                 line_class,
                                 line_level_action,
                                 trx_line_type,
                                 trx_line_date,
                                 trx_business_category,
                                 line_intended_use,
                                 user_defined_fisc_class,
                                 line_amt_includes_tax_flag,
                                 line_amt,
                                 trx_line_quantity,
                                 unit_price,
                                 product_id,
                                 product_fisc_classification,
                                 product_org_id,
                                 uom_code,
                                 product_type,
                                 product_code,
                                 product_category,
                                 ship_to_party_id,
                                 ship_from_party_id,
                                 bill_to_party_id,
                                 bill_from_party_id,
                                 ship_from_party_site_id,
                                 bill_from_party_site_id,
                                 ship_to_location_id,
				ship_from_location_id,
                                 bill_to_location_id,
                                 ship_third_pty_acct_id,
                                 ship_third_pty_acct_site_id,
                                 assessable_value,
                                 historical_flag,
                                 trx_line_currency_code,
                                 trx_line_currency_conv_date,
                                 trx_line_currency_conv_rate,
                                 trx_line_currency_conv_type,
                                 trx_line_mau,
                                 trx_line_precision,
                                 historical_tax_code_id,
                                 input_tax_classification_code,
                                 user_upd_det_factors_flag,
                                 account_ccid,
				 bill_From_location_id
                                 )
                          VALUES(201,
                                 'REQUISITION',
                                 'REQUISITION',
                                 p_tax_line_tbl(i).trx_id,
                                 'LINE',
                                 p_tax_line_tbl(i).trx_line_id,
                                 'INVOICE',
                                 'CREATE',
                                 'ITEM',
                                 p_tax_line_tbl(i).trx_line_date,
                                 p_tax_line_tbl(i).trx_business_cat,
                                 p_tax_line_tbl(i).line_intended_use,
                                 p_tax_line_tbl(i).user_fiscal_class,
                                 'N',
                                 p_tax_line_tbl(i).line_amt,
                                 p_tax_line_tbl(i).trx_line_quantity,
                                 p_tax_line_tbl(i).unit_price,
                                 p_tax_line_tbl(i).product_id,
                                 p_tax_line_tbl(i).prod_fiscal_class,
                                 p_tax_line_tbl(i).product_org_id,
                                 p_tax_line_tbl(i).uom_code,
                                 p_tax_line_tbl(i).product_type,
                                 p_tax_line_tbl(i).product_code,
                                 p_tax_line_tbl(i).product_category,
                                 p_tax_line_tbl(i).ship_to_party_id,
                                 p_tax_line_tbl(i).ship_from_party_id,
                                 p_tax_line_tbl(i).bill_to_party_id,
                                 p_tax_line_tbl(i).bill_from_party_id,
                                 p_tax_line_tbl(i).ship_from_party_site_id,
                                 p_tax_line_tbl(i).bill_from_party_site_id,
                                 p_tax_line_tbl(i).ship_to_location_id,
	       (SELECT hzps.location_id
 	              FROM hz_party_sites hzps
 	              WHERE hzps.party_site_id =p_tax_line_tbl(i).ship_from_party_site_id),
                                 p_tax_line_tbl(i).bill_to_location_id,
                                 p_tax_line_tbl(i).ship_third_pty_id,
                                 p_tax_line_tbl(i).ship_third_pty_site_id,
                                 p_tax_line_tbl(i).assessable_value,
                                 'N',
                                 p_tax_line_tbl(i).currency_code,
                                 p_tax_line_tbl(i).currency_date,
                                 p_tax_line_tbl(i).currency_rate,
                                 p_tax_line_tbl(i).currency_type,
                                 p_tax_line_tbl(i).currency_min_unit,
                                 p_tax_line_tbl(i).currency_precision,
                                 NULL, -- bug 16654091: do not pass historical_tax_id
                                 p_tax_line_tbl(i).input_tax_class,
                                 p_tax_line_tbl(i).user_override_flag,
                                 acc_ccid,
	 (SELECT hzps.location_id
 	              FROM hz_party_sites hzps
 	              WHERE hzps.party_site_id =p_tax_line_tbl(i).ship_from_party_site_id)   /* 8680577 - Passing Location Id as Bill From Location Id */
 	      );

    -- Logging Infra: Statement level
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'ROOPAL Inserted record into ZX_TRANSACTION_LINES_GT.';
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      l_log_msg := '>>> LineId=' || p_tax_line_tbl(i).trx_line_id || '; OverrideFlag=' || p_tax_line_tbl(i).user_override_flag;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;

    i := i + 1;
    EXIT WHEN (i > tbl_sz_line);
  END LOOP;

  l_progress := 500;

  -- delete from ZX_ITM_DISTRIBUTIONS_GT;
  DELETE ZX_ITM_DISTRIBUTIONS_GT;

  l_progress := 600;

  -- Logging Infra: Statement level
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'Deleted ZX_ITM_DISTRIBUTIONS_GT';
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  -- insert into ZX Distributions global temp table
  i := 1;
  tbl_sz_dist := p_tax_dist_tbl.count();

  LOOP
    INSERT INTO ZX_ITM_DISTRIBUTIONS_GT (application_id,
                                         entity_code,
                                         event_class_code,
                                         trx_id,
                                         trx_line_id,
                                         trx_level_type,
                                         trx_line_dist_id,
                                         dist_level_action,
                                         trx_line_dist_date,
                                         item_dist_number,
                                         dist_intended_use,
                                         task_id,
                                         award_id,
                                         project_id,
                                         expenditure_type,
                                         expenditure_organization_id,
                                         expenditure_item_date,
                                         trx_line_dist_amt,
                                         trx_line_dist_qty,
                                         trx_line_quantity,
                                         account_ccid,
                                         historical_flag,
                                         OVERRIDING_RECOVERY_RATE)
                                  VALUES(201,
                                         'REQUISITION',
                                         'REQUISITION',
                                         p_tax_dist_tbl(i).trx_id,
                                         p_tax_dist_tbl(i).trx_line_id,
                                         'LINE',
                                         p_tax_dist_tbl(i).trx_line_dist_id,
                                         'CREATE',
                                         p_tax_dist_tbl(i).trx_line_dist_date,
                                         p_tax_dist_tbl(i).item_dist_number,
                                         p_tax_dist_tbl(i).intended_use,
                                         p_tax_dist_tbl(i).task_id,
                                         p_tax_dist_tbl(i).award_id,
                                         p_tax_dist_tbl(i).project_id,
                                         p_tax_dist_tbl(i).expenditure_type,
                                         p_tax_dist_tbl(i).expenditure_org_id,
                                         p_tax_dist_tbl(i).expenditure_item_date,
                                         p_tax_dist_tbl(i).trx_line_dist_amt,
                                         p_tax_dist_tbl(i).trx_line_dist_quantity,
                                         p_tax_dist_tbl(i).trx_line_quantity,
                                         p_tax_dist_tbl(i).account_ccid,
                                         'N',
                                         p_tax_dist_tbl(i).recovery_rate_override);

    -- Logging Infra: Statement level
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Inserted record into ZX_ITM_DISTRIBUTIONS_GT. DistId=' || p_tax_dist_tbl(i).trx_line_dist_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;

    i := i + 1;
    EXIT WHEN (i > tbl_sz_dist);
  END LOOP;

  l_progress := 700;

  -- Logging Infra: Statement level
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'ZX calculate_tax(+)';
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  -- Now calculate the tax
  zx_api_pub.calculate_tax(p_api_version => 1.0,
                           p_init_msg_list => null,
                           p_commit => null,
                           p_validation_level => null,
                           x_return_status => l_return_status,
                           x_msg_count => l_msg_count,
                           x_msg_data => l_msg_data);

  -- Logging Infra: Statement level
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'ZX calculate_tax returned status=' || l_return_status;
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    l_log_msg := 'ZX calculate_tax(-)';
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  l_progress := 800;

  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;
  x_return_status := l_return_status;

  -- only continue if calculate_tax was successful
  IF (x_return_status = 'S') THEN

    -- Logging Infra: Statement level
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'ZX determine_recovery(+)';
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;

    -- Now determine the recovery
    zx_api_pub.determine_recovery(p_api_version => 1.0,
                                  p_init_msg_list => null,
                                  p_commit => null,
                                  p_validation_level => null,
                                  x_return_status => l_return_status,
                                  x_msg_count => l_msg_count,
                                  x_msg_data => l_msg_data);

    -- Logging Infra: Statement level
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'ZX determine_recovery returned status=' || l_return_status;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      l_log_msg := 'ZX determine_recovery(-)';
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;

    l_progress := 900;

    -- update the return error-handling variables
    x_msg_count     := x_msg_count + l_msg_count;
    x_msg_data      := x_msg_data      || ':' || l_msg_data;
    x_return_status := x_return_status || ':' || l_return_status;

    -- query resultant tax from global tables
    i := 1;
    OPEN c_get_tax;
    LOOP
      FETCH c_get_tax into l_dist_id, l_recov_tax, l_non_recov_tax;
      EXIT WHEN c_get_tax%NOTFOUND;

      IF (i=1) THEN
        -- Initialize the output tables
        x_tax_dist_id_tbl := ICX_TBL_NUMBER(null);
        x_tax_recov_amt_tbl := ICX_TBL_NUMBER(null);
        x_tax_nonrecov_amt_tbl := ICX_TBL_NUMBER(null);
      ELSE
        x_tax_dist_id_tbl.EXTEND;
        x_tax_recov_amt_tbl.EXTEND;
        x_tax_nonrecov_amt_tbl.EXTEND;
      END IF;

      x_tax_dist_id_tbl(i) := l_dist_id;
      x_tax_recov_amt_tbl(i) := l_recov_tax;
      x_tax_nonrecov_amt_tbl(i) := l_non_recov_tax;

      -- Logging Infra: Statement level
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Tax=' || l_dist_id || ':' || l_recov_tax || ':' || l_non_recov_tax;
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      END IF;

      i := i+1;
    END LOOP;
    CLOSE c_get_tax;

    l_progress := 1000;

    -- Logging Infra: Statement level
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      i := i-1;
      l_log_msg := 'Found tax for ' || i || ' distributions.';
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||'(-)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
    l_log_msg := '<-------------------->';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_TAX_PVT.calculate_tax():'
        || ' SQLERRM= ' || SQLERRM || ' Error= ' || x_msg_data
        || ' Progress= ' || l_progress);

END calculate_tax;





PROCEDURE get_default_tax_attributes (p_tax_head_tbl  IN  POR_TAX_HEADER_OBJ_TBL_TYPE,
                                      p_tax_line_tbl  IN  POR_TAX_LINE_OBJ_TBL_TYPE,
                                      x_tax_country   OUT NOCOPY VARCHAR2,
                                      x_doc_subtype   OUT NOCOPY VARCHAR2,
                                      x_tax_class_tbl OUT NOCOPY ICX_TBL_VARCHAR240,
                                      x_trx_bus_tbl   OUT NOCOPY ICX_TBL_VARCHAR240,
                                      x_prd_fisc_tbl  OUT NOCOPY ICX_TBL_VARCHAR240,
                                      x_prd_type_tbl  OUT NOCOPY ICX_TBL_VARCHAR240,
                                      x_int_use_tbl   OUT NOCOPY ICX_TBL_VARCHAR240,
                                      x_usr_fisc_tbl  OUT NOCOPY ICX_TBL_VARCHAR240,
                                      x_ass_val_tbl   OUT NOCOPY ICX_TBL_NUMBER,
                                      x_prd_cat_tbl   OUT NOCOPY ICX_TBL_VARCHAR240,
                                      x_override_tbl  OUT NOCOPY ICX_TBL_FLAG,
                                      x_line_id_tbl   OUT NOCOPY ICX_TBL_NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_data      OUT NOCOPY VARCHAR2,
                                      x_msg_count     OUT NOCOPY NUMBER) IS

  l_legal_entity_id      PLS_INTEGER;
  i                      PLS_INTEGER;
  tbl_sz                 PLS_INTEGER;
  l_msg_count            NUMBER;
  l_return_status        VARCHAR2(60);
  l_msg_data             VARCHAR2(480);
  l_tax_obj_init         POR_TAX_OBJECT_TYPE;
  l_user_override_flag   VARCHAR2(1);
  l_progress             PLS_INTEGER;

  -- Additional Tax Attributes
  l_line_id              NUMBER;
  l_tax_country          VARCHAR2(2);
  l_doc_subtype          VARCHAR2(240);
  l_tax_class_code       VARCHAR2(30);
  l_intended_use         VARCHAR2(240);
  l_trx_business_cat     VARCHAR2(240);
  l_user_fiscal_class    VARCHAR2(30);
  l_prod_fiscal_class    VARCHAR2(240);
  l_product_category     VARCHAR2(240);
  l_product_type         VARCHAR2(240);
  l_assessable_value     NUMBER;
  l_line_level_action    VARCHAR2(30);


  -- Logging Infra
  l_procedure_name       CONSTANT VARCHAR2(30) := 'get_default_tax_attributes';
  l_log_msg              FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  CURSOR c_tax_head IS
  SELECT default_taxation_country,
	 document_sub_type
  FROM ZX_TRX_HEADERS_GT;

  CURSOR c_tax_line IS
  SELECT TRX_LINE_ID,
         INPUT_TAX_CLASSIFICATION_CODE,
         TRX_BUSINESS_CATEGORY,
         PRODUCT_FISC_CLASSIFICATION,
         PRODUCT_TYPE,
         LINE_INTENDED_USE,
         USER_DEFINED_FISC_CLASS,
         ASSESSABLE_VALUE,
         PRODUCT_CATEGORY,
         USER_UPD_DET_FACTORS_FLAG
  FROM ZX_TRANSACTION_LINES_GT;

  BEGIN

  l_progress := 0;

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := '<-------------------->';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
    l_log_msg := l_procedure_name||'(+)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  -- get legal entity id
  l_legal_entity_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(p_tax_head_tbl(1).org_id);

  -- Logging Infra: Statement level
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'XLE Legal Entity=' || l_legal_entity_id;
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  l_progress := 100;

  -- delete from ZX_TRX_HEADERS_GT
  DELETE ZX_TRX_HEADERS_GT;

  l_progress := 200;

  -- delete from ZX_TRANSACTION_LINES_GT
  DELETE ZX_TRANSACTION_LINES_GT;

  l_progress := 300;

  -- insert into ZX Lines global temp table
  i := 1;
  tbl_sz := p_tax_line_tbl.count();

  -- Logging Infra: Statement level
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'Input lines table size=' || tbl_sz;
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  LOOP

    IF (i=1) THEN
      -- Logging Infra: Statement level
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Inserting into ZX_TRX_HEADERS_GT';
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      END IF;

      -- insert into ZX Headers global temp table
      INSERT INTO ZX_TRX_HEADERS_GT (internal_organization_id,
                                     icx_session_id,
                                     application_id,
                                     entity_code,
                                     event_class_code,
                                     event_type_code,
                                     trx_id,
                                     trx_date,
                                     ledger_id,
                                     legal_entity_id,
                                     rounding_bill_to_party_id,
                                     default_taxation_country,
                                     quote_flag,
                                     document_sub_type)
                          VALUES(p_tax_head_tbl(1).org_id,
                                 p_tax_head_tbl(1).icx_session_id,
                                 201,
                                 'REQUISITION',
                                 'REQUISITION',
                                 'REQ_CREATED',
                                 p_tax_head_tbl(1).trx_id,
                                 p_tax_head_tbl(1).trx_date,
                                 p_tax_head_tbl(1).ledger_id,
                                 l_legal_entity_id,
                                 p_tax_head_tbl(1).rndg_bill_to_party_id,
                                 NULL,
                                 'Y',
                                 NULL);
    END IF;


    -- Logging Infra: Statement level
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Inserting into ZX_TRANSACTION_LINES_GT';
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      l_log_msg := '--> Defaulting attribute is ship_to_loc_org_id=' || p_tax_line_tbl(i).product_org_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;

--- bug 13024005 start

    IF p_tax_line_tbl(i).tax_attribute_update_code IS NULL  THEN

    Begin

    SELECT 'UPDATE'
    INTO  l_line_level_action
    FROM ZX_LINES_DET_FACTORS
    WHERE trx_id = p_tax_line_tbl(i).trx_id
    AND trx_line_id = p_tax_line_tbl(i).trx_line_id
    AND USER_UPD_DET_FACTORS_FLAG = 'Y';

    EXCEPTION

    WHEN No_Data_Found THEN
    l_line_level_action := 'CREATE';

    END;

    ELSE

    l_line_level_action := p_tax_line_tbl(i).tax_attribute_update_code;

    END IF;

--- bug 13024005 end

    INSERT INTO ZX_TRANSACTION_LINES_GT(application_id,
                                        entity_code,
                                        event_class_code,
                                        trx_id,
                                        trx_level_type,
                                        trx_line_id,
                                        line_class,
                                        line_level_action,
                                        trx_line_type,
                                        trx_line_date,
                                        trx_business_category,
                                        line_intended_use,
                                        user_defined_fisc_class,
                                        line_amt_includes_tax_flag,
                                        line_amt,
                                        trx_line_quantity,
                                        unit_price,
                                        product_id,
                                        product_fisc_classification,
                                        product_org_id,
                                        uom_code,
                                        product_type,
                                        product_code,
                                        product_category,
                                        ship_to_party_id,
                                        ship_from_party_id,
                                        bill_to_party_id,
                                        bill_from_party_id,
                                        ship_from_party_site_id,
                                        bill_from_party_site_id,
                                        ship_to_location_id,
					ship_from_location_id,
                                        bill_to_location_id,
                                        ship_third_pty_acct_id,
                                        ship_third_pty_acct_site_id,
                                        assessable_value,
                                        historical_flag,
                                        trx_line_currency_code,
                                        trx_line_currency_conv_date,
                                        trx_line_currency_conv_rate,
                                        trx_line_currency_conv_type,
                                        trx_line_mau,
                                        trx_line_precision,
                                        historical_tax_code_id,
                                        input_tax_classification_code,
                                        user_upd_det_factors_flag,
                                        DEFAULTING_ATTRIBUTE1,
					Bill_From_location_id
)
                          VALUES(201,
                                 'REQUISITION',
                                 'REQUISITION',
                                 p_tax_line_tbl(i).trx_id,
                                 'LINE',
                                 p_tax_line_tbl(i).trx_line_id,
                                 'INVOICE',
                                 l_line_level_action,
                                 'ITEM',
                                 p_tax_line_tbl(i).trx_line_date,
                                 NULL,
                                 NULL,
                                 NULL,
                                 'N',
                                 p_tax_line_tbl(i).line_amt,
                                 p_tax_line_tbl(i).trx_line_quantity,
                                 p_tax_line_tbl(i).unit_price,
                                 p_tax_line_tbl(i).product_id,
                                 NULL,
                                 p_tax_line_tbl(i).product_org_id,
                                 p_tax_line_tbl(i).uom_code,
                                 NULL,
                                 p_tax_line_tbl(i).product_code,
                                 NULL,
                                 p_tax_line_tbl(i).ship_to_party_id,
                                 p_tax_line_tbl(i).ship_from_party_id,
                                 p_tax_line_tbl(i).bill_to_party_id,
                                 p_tax_line_tbl(i).bill_from_party_id,
                                 p_tax_line_tbl(i).ship_from_party_site_id,
                                 p_tax_line_tbl(i).bill_from_party_site_id,
                                 p_tax_line_tbl(i).ship_to_location_id,
	(SELECT hzps.location_id
 	              FROM hz_party_sites hzps
 	              WHERE hzps.party_site_id =p_tax_line_tbl(i).ship_from_party_site_id),
                                 p_tax_line_tbl(i).bill_to_location_id,
                                 p_tax_line_tbl(i).ship_third_pty_id,
                                 p_tax_line_tbl(i).ship_third_pty_site_id,
                                 NULL,
                                 'N',
                                 p_tax_line_tbl(i).currency_code,
                                 p_tax_line_tbl(i).currency_date,
                                 p_tax_line_tbl(i).currency_rate,
                                 p_tax_line_tbl(i).currency_type,
                                 p_tax_line_tbl(i).currency_min_unit,
                                 p_tax_line_tbl(i).currency_precision,
                                 NULL, -- bug 16654091: do not pass historical_tax_id
                                 NULL,
                                 NULL,
                                 p_tax_line_tbl(i).product_org_id,
	(SELECT hzps.location_id
 	              FROM hz_party_sites hzps
 	              WHERE hzps.party_site_id =p_tax_line_tbl(i).ship_from_party_site_id)
				 );
    i := i + 1;
    EXIT WHEN (i > tbl_sz);
  END LOOP;

  l_progress := 400;

  -- Logging Infra: Statement level
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'ZX get_default_tax_det_attribs(+)';
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  -- Now get the default tax attibutes
  zx_api_pub.get_default_tax_det_attribs(p_api_version => 1.0,
                                         p_init_msg_list => null,
                                         p_commit => null,
                                         p_validation_level => null,
                                         x_return_status => l_return_status,
                                         x_msg_count => l_msg_count,
                                         x_msg_data => l_msg_data);

  l_progress := 500;

  -- Logging Infra: Statement level
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'ZX get_default_tax_det_attribs returned status=' || l_return_status;
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    l_log_msg := 'ZX get_default_tax_det_attribs(-)';
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;
  x_return_status := l_return_status;

  -- Query the tax header attributes from the global temp table
  OPEN  c_tax_head;
  FETCH c_tax_head into x_tax_country, x_doc_subtype;
  CLOSE c_tax_head;

  l_progress := 600;

  -- Logging Infra: Statement level
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'DEFAULT: tax_country=' || x_tax_country;
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    l_log_msg := 'DEFAULT: doc_subtype=' || x_doc_subtype;
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  -- Query the tax line attributes from the global temp table
  i := 1;
  OPEN c_tax_line;
  LOOP
    FETCH c_tax_line into l_line_id,
                          l_tax_class_code,
                          l_trx_business_cat,
                          l_prod_fiscal_class,
                          l_product_type,
                          l_intended_use,
                          l_user_fiscal_class,
                          l_assessable_value,
                          l_product_category,
                          l_user_override_flag;

    EXIT WHEN c_tax_line%NOTFOUND;

    -- Logging Infra: Statement level
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'DEFAULT: req line id=' || l_line_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      l_log_msg := 'DEFAULT: business_cat=' || l_trx_business_cat;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      l_log_msg := 'DEFAULT: intended_use=' || l_intended_use;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      l_log_msg := 'DEFAULT: user_fisc_class=' || l_user_fiscal_class;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      l_log_msg := 'DEFAULT: prod_fisc_class=' || l_prod_fiscal_class;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      l_log_msg := 'DEFAULT: prod_category=' || l_product_category;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      l_log_msg := 'DEFAULT: prod_type=' || l_product_type;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      l_log_msg := 'DEFAULT: assessable_value=' || l_assessable_value;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      l_log_msg := 'DEFAULT: tax_classification=' || l_tax_class_code;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      l_log_msg := 'DEFAULT: override_flag=' || l_user_override_flag;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;

    IF (i=1) THEN
      -- Initialize the tables
      x_line_id_tbl   := ICX_TBL_NUMBER(null);
      x_tax_class_tbl := ICX_TBL_VARCHAR240(null);
      x_trx_bus_tbl   := ICX_TBL_VARCHAR240(null);
      x_prd_fisc_tbl  := ICX_TBL_VARCHAR240(null);
      x_prd_type_tbl  := ICX_TBL_VARCHAR240(null);
      x_int_use_tbl   := ICX_TBL_VARCHAR240(null);
      x_usr_fisc_tbl  := ICX_TBL_VARCHAR240(null);
      x_ass_val_tbl   := ICX_TBL_NUMBER(null);
      x_prd_cat_tbl   := ICX_TBL_VARCHAR240(null);
      x_override_tbl  := ICX_TBL_FLAG(null);
    ELSE
      -- extend the tables
      x_line_id_tbl.EXTEND;
      x_tax_class_tbl.EXTEND;
      x_trx_bus_tbl.EXTEND;
      x_prd_fisc_tbl.EXTEND;
      x_prd_type_tbl.EXTEND;
      x_int_use_tbl.EXTEND;
      x_usr_fisc_tbl.EXTEND;
      x_ass_val_tbl.EXTEND;
      x_prd_cat_tbl.EXTEND;
      x_override_tbl.EXTEND;
    END IF;

    x_line_id_tbl(i)   := l_line_id;
    x_tax_class_tbl(i) := l_tax_class_code;
    x_trx_bus_tbl(i)   := l_trx_business_cat;
    x_prd_fisc_tbl(i)  := l_prod_fiscal_class;
    x_prd_type_tbl(i)  := l_product_type;
    x_int_use_tbl(i)   := l_intended_use;
    x_usr_fisc_tbl(i)  := l_user_fiscal_class;
    x_ass_val_tbl(i)   := l_assessable_value;
    x_prd_cat_tbl(i)   := l_product_category;
    x_override_tbl(i)  := l_user_override_flag;

    i := i + 1;
  END LOOP;
  CLOSE c_tax_line;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||'(-)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
    l_log_msg := '<-------------------->';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_TAX_PVT.get_default_tax_attributes():'
        || ' SQLERRM= ' || SQLERRM || ' Error= ' || x_msg_data
        || ' Progress= ' || l_progress);

END get_default_tax_attributes;



PROCEDURE delete_all_tax_attr (p_org_id         IN  NUMBER,
                               p_trx_id         IN  NUMBER,
                               x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_data       OUT NOCOPY VARCHAR2,
                               x_msg_count      OUT NOCOPY NUMBER) IS

PRAGMA AUTONOMOUS_TRANSACTION;

  l_transaction_rec      ZX_API_PUB.transaction_rec_type;
  l_msg_count            NUMBER;
  l_return_status        VARCHAR2(60);
  l_msg_data             VARCHAR2(480);
  l_progress             PLS_INTEGER;

  -- Logging Infra
  l_procedure_name       CONSTANT VARCHAR2(30) := 'delete_all_tax_lines';
  l_log_msg              FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

   l_progress := 0;

   -- Logging Infra: Setting up runtime level
   G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := '<-------------------->';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
     l_log_msg := l_procedure_name||'(+)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;

   -- populate l_transaction_rec
   l_transaction_rec.internal_organization_id := p_org_id;
   l_transaction_rec.application_id := 201;
   l_transaction_rec.entity_code := 'REQUISITION';
   l_transaction_rec.event_class_code := 'REQUISITION';
   l_transaction_rec.event_type_code := 'REQ_DELETED';
   l_transaction_rec.trx_id := p_trx_id;

   -- Logging Infra: Statement level
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := 'Deleting record for trx_id=' || p_trx_id;
     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
     l_log_msg := 'ZX global_document_update(+)';
     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;

   -- this will delete all tax attribute records for this requisition
   zx_api_pub.global_document_update(p_api_version => 1.0,
                                     p_init_msg_list => null,
                                     p_commit => null,
                                     p_validation_level => null,
                                     x_return_status => l_return_status,
                                     x_msg_count => l_msg_count,
                                     x_msg_data => l_msg_data,
	                             p_transaction_rec => l_transaction_rec);

   l_progress := 100;

   -- Logging Infra: Statement level
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := 'ZX global_document_update returned status=' || l_return_status;
     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
     l_log_msg := 'ZX global_document_update(-)';
     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;

   x_msg_count     := l_msg_count;
   x_msg_data      := l_msg_data;
   x_return_status := l_return_status;

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'(-)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     l_log_msg := '<-------------------->';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
   END IF;

   COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    -- rollback
    ROLLBACK;
    -- raise exception for java layer
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_TAX_PVT.delete_all_tax_attr():'
        || ' SQLERRM= ' || SQLERRM || ' Error= ' || x_msg_data
        || ' Progress= ' || l_progress || '; ROLLBACK Complete.');

END delete_all_tax_attr;




PROCEDURE insert_line_det_attr (p_tax_info_tbl  IN  POR_INSERT_TAX_OBJ_TBL_TYPE,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_data      OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER ) IS

PRAGMA AUTONOMOUS_TRANSACTION;

  l_transaction_rec      ZX_API_PUB.transaction_rec_type;
  l_transaction_line_rec ZX_API_PUB.transaction_line_rec_type;

  l_legal_entity_id      PLS_INTEGER;
  i                      PLS_INTEGER;
  tbl_sz                 PLS_INTEGER;
  l_msg_count            NUMBER;
  l_return_status        VARCHAR2(60);
  l_msg_data             VARCHAR2(480);
  l_progress             PLS_INTEGER;

  -- Logging Infra
  l_procedure_name       CONSTANT VARCHAR2(30) := 'insert_line_det_attr';
  l_log_msg              FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

   l_progress := 0;

   -- Logging Infra: Setting up runtime level
   G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := '<-------------------->';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
     l_log_msg := l_procedure_name||'(+)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;

   -- get legal entity id
   l_legal_entity_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(p_tax_info_tbl(1).org_id);

   -- Logging Infra: Statement level
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := 'XLE Legal Entity=' || l_legal_entity_id;
     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;

   l_progress := 50;

   -- populate l_transaction_rec
   l_transaction_rec.internal_organization_id := p_tax_info_tbl(1).org_id;
   l_transaction_rec.application_id := 201;
   l_transaction_rec.entity_code := 'REQUISITION';
   l_transaction_rec.event_class_code := 'REQUISITION';
   l_transaction_rec.event_type_code := 'REQ_DELETED';
   l_transaction_rec.trx_id := p_tax_info_tbl(1).trx_id;

   -- Logging Infra: Statement level
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := 'Deleting record for trx_id=' || p_tax_info_tbl(1).trx_id;
     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
     l_log_msg := 'ZX global_document_update(+)';
     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;

   -- this will delete all tax attribute records for this requisition
   zx_api_pub.global_document_update(p_api_version => 1.0,
                                     p_init_msg_list => null,
                                     p_commit => null,
                                     p_validation_level => null,
                                     x_return_status => l_return_status,
                                     x_msg_count => l_msg_count,
                                     x_msg_data => l_msg_data,
	                             p_transaction_rec => l_transaction_rec);

   l_progress := 100;

   -- Logging Infra: Statement level
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := 'ZX global_document_update returned status=' || l_return_status;
     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
     l_log_msg := 'ZX global_document_update(-)';
     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;

   x_msg_count     := l_msg_count;
   x_msg_data      := l_msg_data;
   x_return_status := l_return_status;

   -- loop through and insert reqLine data into EBTax global plsql table
   i := 1;
   tbl_sz := p_tax_info_tbl.count();

   LOOP

             -- EBTax initialization procedure
	     ZX_GLOBAL_STRUCTURES_PKG.INIT_TRX_LINE_DIST_TBL(i);

             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(i) :=
	           p_tax_info_tbl(i).org_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(i) :=
	           201;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE(i) :=
	           'REQUISITION';
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE(i) :=
	           'REQUISITION';
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_TYPE_CODE(i) :=
	           'REQ_CREATED';
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID(i) :=
	           p_tax_info_tbl(i).trx_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DATE(i) :=
	           p_tax_info_tbl(i).trx_date;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEDGER_ID(i) :=
	           p_tax_info_tbl(i).ledger_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_CURRENCY_CODE(i) :=
	           p_tax_info_tbl(i).currency_code;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(i) :=
	           p_tax_info_tbl(i).currency_date;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(i) :=
	           p_tax_info_tbl(i).currency_rate;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(i) :=
	           p_tax_info_tbl(i).currency_type;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MINIMUM_ACCOUNTABLE_UNIT(i) :=
	           p_tax_info_tbl(i).currency_min_unit;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRECISION(i) :=
	           p_tax_info_tbl(i).currency_precision;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_PRECISION(i) :=
	           p_tax_info_tbl(i).currency_precision;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEGAL_ENTITY_ID(i) :=
	           l_legal_entity_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(i) :=
	           p_tax_info_tbl(i).doc_subtype;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID(i) :=
	           p_tax_info_tbl(i).rndg_bill_to_party_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(i) :=
	           p_tax_info_tbl(i).tax_country;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_REPORTING_FLAG(i) :=
	           'N';
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE(i) :=
	           p_tax_info_tbl(i).input_tax_class;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HISTORICAL_FLAG(i) :=
	           'N';
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LEVEL_TYPE(i) :=
	           'LINE';
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_ID(i) :=
	           p_tax_info_tbl(i).trx_line_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_CLASS(i) :=
	           'INVOICE';
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_LEVEL_ACTION(i) :=
	           'CREATE';
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_TYPE(i) :=
	           'ITEM';
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DATE(i) :=
	           p_tax_info_tbl(i).trx_line_date;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(i) :=
	           p_tax_info_tbl(i).trx_business_cat;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_INTENDED_USE(i) :=
	           p_tax_info_tbl(i).line_intended_use;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(i) :=
	           p_tax_info_tbl(i).user_fiscal_class;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_AMT_INCLUDES_TAX_FLAG(i) :=
	           'N';
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_AMT(i) :=
	           p_tax_info_tbl(i).line_amt;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_QUANTITY(i) :=
	           p_tax_info_tbl(i).trx_line_quantity;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.UNIT_PRICE(i) :=
	           p_tax_info_tbl(i).unit_price;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPTION_CONTROL_FLAG(i) :=
	           'S';
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ID(i) :=
	           p_tax_info_tbl(i).product_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(i) :=
	           p_tax_info_tbl(i).prod_fiscal_class;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ORG_ID(i) :=
	           p_tax_info_tbl(i).product_org_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.UOM_CODE(i) :=
	           p_tax_info_tbl(i).uom_code;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_TYPE(i) :=
	           p_tax_info_tbl(i).product_type;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CODE(i) :=
	           p_tax_info_tbl(i).product_code;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CATEGORY(i) :=
	           p_tax_info_tbl(i).product_category;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_PARTY_ID(i) :=
	           p_tax_info_tbl(i).ship_to_party_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_PARTY_ID(i) :=
	           p_tax_info_tbl(i).ship_from_party_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_PARTY_ID(i) :=
	           p_tax_info_tbl(i).bill_to_party_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_PARTY_ID(i) :=
	           p_tax_info_tbl(i).bill_from_party_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_PARTY_SITE_ID(i) :=
	           p_tax_info_tbl(i).ship_from_party_site_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_PARTY_SITE_ID(i) :=
	           p_tax_info_tbl(i).bill_from_party_site_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_LOCATION_ID(i) :=
	           p_tax_info_tbl(i).ship_to_location_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_LOCATION_ID(i) :=
	           p_tax_info_tbl(i).bill_to_location_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_ID(i) :=
	           p_tax_info_tbl(i).ship_third_pty_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_SITE_ID(i) :=
	           p_tax_info_tbl(i).ship_third_pty_site_id;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSESSABLE_VALUE(i) :=
	           p_tax_info_tbl(i).assessable_value;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.HISTORICAL_TAX_CODE_ID(i) :=
	           p_tax_info_tbl(i).historical_tax_id;
             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_UPD_DET_FACTORS_FLAG(i) :=
	           p_tax_info_tbl(i).user_override;
	    -- Bug 7526131: populating ship_from_location_id
if (p_tax_info_tbl(i).ship_from_party_site_id is null) then
ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_LOCATION_ID(i)  := null;
ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_LOCATION_ID(i)  := null;
Else
SELECT  hzps.location_id  INTO ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_FROM_LOCATION_ID(i)
                      FROM hz_party_sites hzps
                      WHERE hzps.party_site_id =p_tax_info_tbl(i).ship_from_party_site_id and rownum =1 ;
SELECT pvs.location_id   INTO ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_LOCATION_ID(i)
           from hz_party_sites pvs   /* - Passing Location Id as Bill From Location Id */
 	         WHERE pvs.party_site_id =p_tax_info_tbl(i).ship_from_party_site_id and rownum =1 ;


End if;
	     --  bug 19165387: pass trx_line_number & trx_line_description & product_description to ZX
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_NUMBER(i) :=
	           p_tax_info_tbl(i).trx_line_number;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DESCRIPTION(i) :=
	           p_tax_info_tbl(i).trx_line_description;
	     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_DESCRIPTION(i) :=
	           p_tax_info_tbl(i).trx_line_description;

             -- Logging Infra: Statement level
             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
               l_log_msg := 'Inserted record into ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl for trx_line_id=' || p_tax_info_tbl(1).trx_line_id;
               FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
             END IF;

     i := i + 1;
     EXIT WHEN (i > tbl_sz);
   END LOOP;

   l_progress := 200;

   -- populate l_transaction_rec as all NULLs as there are no duplicates
   l_transaction_line_rec.internal_organization_id := NULL;
   l_transaction_line_rec.application_id := NULL;
   l_transaction_line_rec.entity_code := NULL;
   l_transaction_line_rec.event_class_code := NULL;
   l_transaction_line_rec.event_type_code := NULL;
   l_transaction_line_rec.trx_id := NULL;

   -- Logging Infra: Statement level
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := 'ZX insert_line_det_factors(+)';
     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;

   -- this will insert the tax determining factors into the EBTax tables
   zx_api_pub.insert_line_det_factors(p_api_version => 1.0,
                                      p_init_msg_list => null,
                                      p_commit => null,
                                      p_validation_level => null,
                                      x_return_status => l_return_status,
                                      x_msg_count => l_msg_count,
                                      x_msg_data => l_msg_data);

   l_progress := 300;

   -- Logging Infra: Statement level
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := 'ZX insert_line_det_factors returned status=' || l_return_status;
     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
     l_log_msg := 'ZX insert_line_det_factors(-)';
     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;

   x_msg_count     := x_msg_count + l_msg_count;
   x_msg_data      := x_msg_data      || ':' || l_msg_data;
   x_return_status := x_return_status || ':' || l_return_status;

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||'(-)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
     l_log_msg := '<-------------------->';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
   END IF;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    -- rollback
    ROLLBACK;
    -- raise exception for java layer
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_TAX_PVT.insert_line_det_attr():'
        || ' SQLERRM= ' || SQLERRM || ' Error= ' || x_msg_data
        || ' Progress= ' || l_progress || '; ROLLBACK Complete.');
END insert_line_det_attr;


PROCEDURE copy_tax_attributes (p_tax_copy_tbl   IN POR_TAX_COPY_OBJ_TBL_TYPE,
                               x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_data       OUT NOCOPY VARCHAR2,
                               x_msg_count      OUT NOCOPY NUMBER) IS

PRAGMA AUTONOMOUS_TRANSACTION;

  l_legal_entity_id      PLS_INTEGER;
  i                      PLS_INTEGER;
  tbl_sz                 PLS_INTEGER;
  l_msg_count            NUMBER;
  l_return_status        VARCHAR2(60);
  l_msg_data             VARCHAR2(480);
  l_progress             PLS_INTEGER;

  -- Logging Infra
  l_procedure_name       CONSTANT VARCHAR2(30) := 'copy_tax_attributes';
  l_log_msg              FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_progress := 0;

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := '<-------------------->';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
    l_log_msg := l_procedure_name||'(+)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  -- get legal entity id
  l_legal_entity_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(p_tax_copy_tbl(1).org_id);

  -- Logging Infra: Statement level
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'XLE Legal Entity=' || l_legal_entity_id;
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
  END IF;

  l_progress := 50;

  -- loop through and insert reqLine data into EBTax global plsql table
  i := 1;
  tbl_sz := p_tax_copy_tbl.count();

  LOOP
    -- EBTax initialization procedure
    ZX_GLOBAL_STRUCTURES_PKG.INIT_TRX_LINE_DIST_TBL(i);

    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(i) :=
	           p_tax_copy_tbl(i).org_id;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(i) :=
	           201;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE(i) :=
	           'REQUISITION';
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE(i) :=
	           'REQUISITION';
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_TYPE_CODE(i) :=
	           'REQ_CREATED';
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID(i) :=
	           p_tax_copy_tbl(i).trx_id;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DATE(i) :=
	           p_tax_copy_tbl(i).trx_date;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEDGER_ID(i) :=
	           p_tax_copy_tbl(i).ledger_id;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEGAL_ENTITY_ID(i) :=
	           l_legal_entity_id;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LEVEL_TYPE(i) :=
                   'LINE';
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_LEVEL_ACTION(i) :=
                   'CREATE';
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_ID(i) :=
	           p_tax_copy_tbl(i).trx_line_id;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_AMT(i) :=
	           p_tax_copy_tbl(i).line_amt;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DATE(i) :=
	           p_tax_copy_tbl(i).trx_line_date;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_APPLICATION_ID(i) :=
	           201;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_ENTITY_CODE(i) :=
                   'REQUISITION';
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE(i) :=
                   'REQUISITION';
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_TRX_ID(i) :=
	           p_tax_copy_tbl(i).source_trx_id;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_LINE_ID(i) :=
	           p_tax_copy_tbl(i).source_line_id;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_TRX_LEVEL_TYPE(i) :=
                   'LINE';
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt_includes_tax_flag(i) :=
                   'N';

    -- Logging Infra: Procedure level
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Inserted record into ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl';
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      l_log_msg := '--> source id=' || p_tax_copy_tbl(i).source_trx_id || ':' || p_tax_copy_tbl(i).source_line_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
      l_log_msg := '--> dest id=' || p_tax_copy_tbl(i).trx_id || ':' || p_tax_copy_tbl(i).trx_line_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;

    i := i + 1;
    EXIT WHEN (i > tbl_sz);
  END LOOP;

  l_progress := 100;

  -- this will insert the tax determining factors into the EBTax tables
  zx_api_pub.copy_insert_line_det_factors(p_api_version => 1.0,
                                          p_init_msg_list => null,
                                          p_commit => null,
                                          p_validation_level => null,
                                          x_return_status => l_return_status,
                                          x_msg_count => l_msg_count,
                                          x_msg_data => l_msg_data);

  l_progress := 200;

  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;
  x_return_status := l_return_status;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||'(-)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
    l_log_msg := '<-------------------->';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    -- rollback
    ROLLBACK;
    -- raise exception for java layer
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at POR_TAX_PVT.copy_tax_attributes():'
        || ' SQLERRM= ' || SQLERRM || ' Error= ' || x_msg_data
        || ' Progress= ' || l_progress || '; ROLLBACK Complete.');

END copy_tax_attributes;


END POR_TAX_PVT;

/
