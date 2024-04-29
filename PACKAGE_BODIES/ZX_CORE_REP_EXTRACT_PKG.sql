--------------------------------------------------------
--  DDL for Package Body ZX_CORE_REP_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_CORE_REP_EXTRACT_PKG" AS
/* $Header: zxricoreplugpvtb.pls 120.12.12010000.38 2010/04/12 11:33:57 bibeura ship $ */


-----------------------------------------
--Private Methods Declarations
-----------------------------------------

TYPE ATTRIBUTE1_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE2_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE2%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE3_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE3%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE4_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE4%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE5_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE5%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE6_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE6%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE7_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE7%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE10_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE10%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE11_TBL IS TABLE OF
  ZX_REP_TRX_JX_EXT_T.ATTRIBUTE11%TYPE INDEX BY BINARY_INTEGER;

--Bug 5251425
	TYPE TRX_CURRENCY_DESC_TBL IS TABLE OF
	ZX_REP_TRX_JX_EXT_T.ATTRIBUTE9%TYPE INDEX BY BINARY_INTEGER;

	TYPE   batch_name_tbl IS TABLE OF
	ZX_REP_TRX_JX_EXT_T.ATTRIBUTE8%TYPE INDEX BY BINARY_INTEGER;

	TYPE CCID_TBL IS TABLE OF
	ZX_REP_ACTG_EXT_T.ACTG_LINE_CCID%TYPE INDEX BY BINARY_INTEGER;

	TYPE NUMBER_TBL is table of number index by binary_integer;

	TYPE NUMERIC1_TBL IS TABLE OF
	ZX_REP_TRX_JX_EXT_T.NUMERIC1%TYPE INDEX BY BINARY_INTEGER;

	TYPE NUMERIC2_TBL IS TABLE OF
	ZX_REP_TRX_JX_EXT_T.NUMERIC2%TYPE INDEX BY BINARY_INTEGER;

  --Bug 9031051
	TYPE NUMERIC5_TBL IS TABLE OF
	ZX_REP_TRX_JX_EXT_T.NUMERIC5%TYPE INDEX BY BINARY_INTEGER;

	TYPE ACC_CCID_TBL IS TABLE OF ZX_ACCOUNTS.TAX_ACCOUNT_CCID%TYPE;

-----------------------------------------
--Private Type

----------------------------------------
--
PROCEDURE get_org_vat_num (
           --p_report_name            IN  VARCHAR2,
                            p_detail_tax_line_id_tbl IN  ZX_EXTRACT_PKG.detail_tax_line_id_tbl,
                    --        p_request_id             IN  NUMBER,
                            p_establishment_id       IN NUMBER,
                            p_org_vat_num_tbl        OUT NOCOPY ATTRIBUTE2_TBL);

PROCEDURE get_territory_info(
             --p_report_name                  IN VARCHAR2,
                              p_detail_tax_line_id_tbl       IN ZX_EXTRACT_PKG.detail_tax_line_id_tbl,
                              p_country_code_tbl             IN ZX_EXTRACT_PKG.billing_tp_country_tbl,
                              p_territory_short_name_tbl     OUT NOCOPY ATTRIBUTE2_TBL,
                              p_alternate_territory_name_tbl OUT NOCOPY ATTRIBUTE3_TBL);

PROCEDURE adjustment_tax_code(
                    p_detail_tax_line_id_tbl  IN  ZX_EXTRACT_PKG.detail_tax_line_id_tbl,
                    p_tax_rate_code_tbl       IN  ZX_EXTRACT_PKG.tax_rate_code_tbl,
                    p_adj_tax_code_tbl        OUT NOCOPY ATTRIBUTE1_TBL);

--Private Procedures Included for the Bug 5251425
PROCEDURE GET_CREATED_BY
(
	p_detail_tax_line_id_tbl       IN ZX_EXTRACT_PKG.detail_tax_line_id_tbl,
	p_trx_id_tbl			  IN ZX_EXTRACT_PKG.trx_id_tbl,
	p_created_by_tbl		  OUT NOCOPY ATTRIBUTE6_TBL
) ;

PROCEDURE GET_OU_DESC
(
	p_detail_tax_line_id_tbl       IN ZX_EXTRACT_PKG.detail_tax_line_id_tbl,
	p_internal_organization_id_tbl IN ZX_EXTRACT_PKG.internal_organization_id_tbl,
	p_ou_desc_tbl		  OUT NOCOPY ATTRIBUTE7_TBL
) ;

PROCEDURE GET_MATCH
(
	p_detail_tax_line_id_tbl ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
	p_acc_ccid_tbl ACC_CCID_TBL ,
	p_match_tbl OUT NOCOPY ATTRIBUTE5_TBL
);

PROCEDURE GET_RECEIVED_AMOUNTS
(
	p_detail_tax_line_id_tbl IN ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
	p_trx_id_tbl	         IN ZX_EXTRACT_PKG.trx_id_tbl,
	p_org_id_tbl		 IN zx_extract_pkg.INTERNAL_ORGANIZATION_ID_TBL ,
	p_amount_received_tbl	 OUT NOCOPY NUMERIC2_TBL,
	p_tax_received_tbl    OUT NOCOPY NUMERIC1_TBL
);

-- Declare global varibles for FND log messages

   g_current_runtime_level           NUMBER;
   g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
   g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
   g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
   g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
   g_error_buffer                    VARCHAR2(100);

-- Public APIs

PROCEDURE populate_core_ap(
          P_TRL_GLOBAL_VARIABLES_REC  IN  ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
          )
IS

p_request_id                    NUMBER;
p_report_name                   VARCHAR2(30);
p_legal_entity_id               NUMBER;
p_product                       VARCHAR2(30);
l_detail_tax_line_id_tbl        ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
l_trx_id_tbl                    ZX_EXTRACT_PKG.TRX_ID_TBL;
l_country_code_tbl              ZX_EXTRACT_PKG.BILLING_TP_COUNTRY_TBL;
l_country_code_reg_num_tbl      ATTRIBUTE1_TBL;
l_org_vat_num_tbl               ATTRIBUTE2_TBL;
l_territory_short_name_tbl      ATTRIBUTE2_TBL;
l_alternate_territory_name_tbl  ATTRIBUTE3_TBL;
l_establishment_id              NUMBER;
l_tax_rate_code_tbl             ZX_EXTRACT_PKG.TAX_RATE_CODE_TBL;
l_adj_tax_code_tbl              ATTRIBUTE1_TBL;

--Bug 5251425
l_trx_currency_code_tbl	zx_extract_pkg.trx_currency_code_tbl;
l_trx_currency_desc_tbl trx_currency_desc_tbl;
l_batch_name_tbl	batch_name_tbl;
l_err_msg               varchar2(120);
l_created_by_tbl attribute6_tbl;
l_ou_desc_tbl attribute7_tbl;
l_internal_organization_id_tbl zx_extract_pkg.internal_organization_id_tbl;
l_acc_ccid_tbl acc_ccid_tbl;
l_match_tbl attribute5_tbl;

   CURSOR establishment_id_csr(c_legal_entity_id number) IS
   SELECT xle_etb.establishment_id
     FROM zx_party_tax_profile ptp,
          xle_etb_profiles xle_etb
    WHERE ptp.party_id         = xle_etb.party_id
      AND ptp.party_type_code  = 'LEGAL_ESTABLISHMENT'
      AND xle_etb.legal_entity_id =  c_legal_entity_id
      AND xle_etb.main_establishment_flag = 'Y';

BEGIN

	g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
--        g_level_statement  := FND_LOG.LEVEL_STATEMENT;
--        g_level_procedure  := FND_LOG.LEVEL_PROCEDURE;

	IF (g_level_procedure >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP.BEGIN',
				      'ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP(+)');
	END IF;

    p_request_id         :=  P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;
    p_report_name        :=  P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME;
    p_legal_entity_id    :=  P_TRL_GLOBAL_VARIABLES_REC.LEGAL_ENTITY_ID;
    p_product            :=  P_TRL_GLOBAL_VARIABLES_REC.PRODUCT;

	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'p_report_name : '||P_REPORT_NAME);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'p_request_id : '||p_request_id);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'p_legal_entity_id : '||p_legal_entity_id);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'p_product : '||p_product);
	END IF;


    IF P_REPORT_NAME = 'ZXXTATAT' THEN
       BEGIN
          IF (g_level_statement >= g_current_runtime_level ) THEN
		          FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					       'Before Updating Taxable Amount for Cancelled Invoices with Zero Tax Amount');
					END IF;

          UPDATE zx_rep_trx_detail_t dtl
             SET taxable_amt_funcl_curr = 0,
                 taxable_amt = 0
           WHERE dtl.request_id =  p_request_id
             AND dtl.tax_amt = 0
             AND nvl(historical_flag,'N') = 'Y'
             AND EXISTS (SELECT 1 FROM ap_invoices_all
                         WHERE cancelled_date IS NOT NULL
                           AND invoice_id = dtl.trx_id
                           AND org_id = dtl.internal_organization_id);

          IF (g_level_statement >= g_current_runtime_level ) THEN
		          FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					       'After Updating Taxable Amount for Cancelled Invoices with Zero Tax Amount');
					    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					       'Number of invoices updated: '||to_char(SQL%ROWCOUNT));
					END IF;

          INSERT INTO zx_rep_trx_jx_ext_t
                           (detail_tax_line_ext_id,
                            detail_tax_line_id,
                            attribute1,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date,
                            last_update_login,
                            request_id)
                    (SELECT zx_rep_trx_jx_ext_t_s.nextval,
                            dtl.detail_tax_line_id,
                            'Yes', --fl.meaning,
                            dtl.created_by,
                            dtl.creation_date,
                            dtl.last_updated_by,
                            dtl.last_update_date,
                            dtl.last_update_login,
                            p_request_id
                       FROM zx_rep_trx_detail_t dtl
                         WHERE EXISTS (select distinct ah.invoice_id
                            FROM ap_holds_all ah
                            WHERE ah.invoice_id = dtl.trx_id
                              AND ah.release_lookup_code IS NULL )
                         AND dtl.request_id = p_request_id);

	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'Insertion for Hold , ext.attribute1 : '||to_char(SQL%ROWCOUNT) );
	END IF;

--Bug 5251425 : To get the C_TRX_CURRENCY_DESC ( ext.attribute9) and the C_BATCH_NAME ( ext.attribute8 ) for the Invoice .
		SELECT
			dtl.detail_tax_line_id,
			dtl.trx_id,
			dtl.trx_currency_code,
			fcv.name,
			ab.batch_name,
			acc.TAX_ACCOUNT_CCID
		BULK COLLECT INTO
			l_detail_tax_line_id_tbl,
			l_trx_id_tbl,
			l_trx_currency_code_tbl,
			l_trx_currency_desc_tbl,
			l_batch_name_tbl,
			l_acc_ccid_tbl
		FROM
			zx_rep_trx_detail_t dtl,
			fnd_currencies_vl fcv,
			ap_invoices_all ai,
			ap_batches_all ab,
			zx_rates_b rates,
			zx_accounts acc
		WHERE
			dtl.request_id = p_request_id
			AND dtl.trx_currency_code = fcv.currency_code
			AND dtl.trx_id = ai.invoice_id
			AND ai.batch_id = ab.batch_id(+)
			AND dtl.tax_rate_id = rates.tax_rate_id(+)
			AND acc.TAX_ACCOUNT_ENTITY_ID(+) = rates.tax_rate_id;

	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
	END IF;
	--Get details for C_MATCH

		GET_MATCH(
			l_detail_tax_line_id_tbl,
			l_acc_ccid_tbl,
			l_match_tbl
		);

	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'Before insertion into zx_rep_trx_jx_ext_t for report '||p_report_name  );
	END IF;

	FORALL i IN nvl(l_detail_tax_line_id_tbl.FIRST,1)..nvl(l_detail_tax_line_id_tbl.LAST,0)
		MERGE INTO zx_rep_trx_jx_ext_t ext
		      USING ( SELECT 1 FROM dual ) T
		      ON ( ext.detail_tax_line_id = l_detail_tax_line_id_tbl(i))
		WHEN MATCHED THEN UPDATE SET ext.ATTRIBUTE9 = l_trx_currency_desc_tbl(i),
					     ext.attribute8 = l_batch_name_tbl(i),
					     ext.attribute5 = l_match_tbl(i)
		WHEN NOT MATCHED THEN
			INSERT (
				detail_tax_line_ext_id,
				detail_tax_line_id,
				attribute9,
				attribute8,
				attribute5,
				created_by,
				creation_date,
				last_updated_by,
				last_update_date,
				last_update_login,
                                request_id
			)
			VALUES ( ZX_MIGRATE_UTIL.get_next_seqid('ZX_REP_TRX_JX_EXT_T_S'),
				l_detail_tax_line_id_tbl(i),
				l_trx_currency_desc_tbl(i),
				l_batch_name_tbl(i),
				l_match_tbl(i),
				fnd_global.user_id,
				sysdate,
				fnd_global.user_id,
				sysdate,
				fnd_global.login_id,
                                p_request_id
			);
	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'Update for ERV/IPV , ext.numeric1 : ' );
	END IF;

        UPDATE zx_rep_trx_jx_ext_t ext
     SET ext.numeric1 =
          (SELECT sum(nvl(lnk.UNROUNDED_accounted_DR,0)-nvl(lnk.UNROUNDED_accounted_CR,0))
             FROM zx_rep_trx_detail_t dtl,
                  zx_rep_actg_ext_t act_ext,
                  ap_invoice_distributions_all ap_dist,
                  xla_ae_headers aeh,
                  xla_ae_lines ael,
                  xla_distribution_links lnk
            WHERE dtl.ref_doc_application_id = 201
              and dtl.request_id = p_request_id
              and act_ext.detail_tax_line_id = dtl.detail_tax_line_id
              and dtl.detail_tax_line_id = ext.detail_tax_line_id
              and ap_dist.line_type_lookup_code in('IPV','ERV')
              and ap_dist.accounting_event_id = act_ext.actg_event_id
              and ap_dist.invoice_id          = dtl.trx_id
              and ap_dist.invoice_line_number = dtl.trx_line_id
              and ap_dist.related_id          = dtl.taxable_item_source_id
              and ap_dist.invoice_distribution_id <> ap_dist.related_id
              and aeh.application_id = 200
              and aeh.ae_header_id   = act_ext.actg_header_id
              and aeh.ledger_id      = P_TRL_GLOBAL_VARIABLES_REC.LEDGER_ID
              and aeh.event_id       = ap_dist.accounting_event_id
              and ael.ae_header_id    = aeh.ae_header_id
              and ael.application_id  = aeh.application_id
              and ael.accounting_class_code not in ('LIABILITY','NRTAX','RTAX')
              and lnk.application_id   = aeh.application_id
              and lnk.ae_header_id     = aeh.ae_header_id
              and lnk.event_id         = aeh.event_id
              and lnk.source_distribution_type = 'AP_INV_DIST'
              and lnk.source_distribution_id_num_1 = ap_dist.invoice_distribution_id
              and lnk.ae_line_num = ael.ae_line_num
              and actg_ext_line_id = (SELECT MIN(actg_ext_line_id)
                             FROM zx_rep_actg_ext_t acct2
                           WHERE acct2.actg_header_id= act_ext.actg_header_id
                             and acct2.actg_event_id = act_ext.actg_event_id
                             AND acct2.actg_source_id = act_ext.actg_source_id
                             AND acct2.detail_tax_line_id = act_ext.detail_tax_line_id
                             AND acct2.request_id = act_ext.request_id
                             GROUP BY acct2.actg_header_id, acct2.actg_event_id,
                                      acct2.actg_source_id,acct2.detail_tax_line_id
                             HAVING COUNT( distinct acct2.actg_ext_line_id) >=2)
              -- and rownum=1
            )
  where ext.request_id = p_request_id;
/***
        UPDATE zx_rep_trx_jx_ext_t ext
           SET ext.numeric1=(
               SELECT  sum(nvl(lnk.UNROUNDED_accounted_DR,0)-nvl(lnk.UNROUNDED_accounted_CR,0))
                 FROM zx_rep_trx_detail_t dtl,
                      zx_rep_actg_ext_t act_ext,
                      AP_INVOICE_DISTRIBUTIONS_ALL AP_DIST,
                      xla_distribution_links lnk,
                      xla_ae_headers aeh,
                      xla_ae_lines ael
                WHERE ap_dist.invoice_id=dtl.trx_id
                  and ap_dist.invoice_line_number=dtl.trx_line_id
                  and ap_dist.related_id=dtl.taxable_item_source_id
                  and ap_dist.invoice_distribution_id <> ap_dist.related_id
                  and ap_dist.line_type_lookup_code in('IPV','ERV')
                  and dtl.detail_tax_line_id=act_ext.detail_tax_line_id
                  and lnk.application_id=200
                  and lnk.source_distribution_type='AP_INV_DIST'
                  and lnk.source_distribution_id_num_1=ap_dist.invoice_distribution_id
                  and lnk.event_id=ap_dist.accounting_event_id
                  and lnk.ae_header_id=act_ext.actg_header_id --c_ae_header_id
                  and lnk.event_id=act_ext.actg_event_id --c_event_id
                  and lnk.ae_line_num=ael.ae_line_num
                  and aeh.ae_header_id=ael.ae_header_id
                  and aeh.ledger_id=P_TRL_GLOBAL_VARIABLES_REC.LEDGER_ID
                  and aeh.ae_header_id=lnk.ae_header_id
                  and aeh.application_id=lnk.application_id
                  and ael.application_id=aeh.application_id
                  and ael.accounting_class_code not in ('LIABILITY','NRTAX','RTAX')
                  and dtl.request_id = p_request_id
                  and dtl.detail_tax_line_id = ext.detail_tax_line_id
                  and rownum =1
                  )
                  where  ext.request_id = p_request_id;
***/
	EXCEPTION
	WHEN OTHERS THEN
--		NULL ;
		IF (g_level_statement >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
						      'Error Message for report '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;
        END;
    END IF;

    IF P_REPORT_NAME = 'JGVAT' THEN
       BEGIN
          IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
						      'Report Name: JGVAT ' );
					END IF;

          IF p_trl_global_variables_rec.reporting_ledger_id IS NOT NULL THEN
             IF (g_level_statement >= g_current_runtime_level ) THEN
  		         	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
  					        'Update zx_rep_trx_detail_t.taxable_amt_funcl_curr for IPV issue' );
  					    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
              	    'Reporting_ledger_id : '||to_char(p_trl_global_variables_rec.reporting_ledger_id) );
	           END IF;

              UPDATE zx_rep_trx_detail_t dtl1
                 SET dtl1.taxable_amt_funcl_curr = nvl(dtl1.taxable_amt_funcl_curr,0)
                 + NVL(( SELECT sum(nvl(lnk.UNROUNDED_accounted_DR,0)-nvl(lnk.UNROUNDED_accounted_CR,0)) *
                      decode(sign(nvl(dtl1.taxable_amt_funcl_curr,0)),0,1,sign(nvl(dtl1.taxable_amt_funcl_curr,0)))
                       FROM zx_rep_trx_detail_t dtl2,
                            zx_rep_actg_ext_t act_ext,
                            AP_INVOICE_DISTRIBUTIONS_ALL AP_DIST,
                            xla_distribution_links lnk,
                            xla_ae_headers aeh,
                            xla_ae_lines ael
                      WHERE ap_dist.invoice_id=dtl2.trx_id
                        and ap_dist.invoice_line_number=dtl2.trx_line_id
                        and ap_dist.related_id=dtl2.taxable_item_source_id
                        and ap_dist.invoice_distribution_id <> ap_dist.related_id
                        and ap_dist.line_type_lookup_code in ('IPV','ERV')
                        and dtl2.detail_tax_line_id=act_ext.detail_tax_line_id
                        and lnk.application_id=200
                        and lnk.source_distribution_type='AP_INV_DIST'
                        and lnk.source_distribution_id_num_1=ap_dist.invoice_distribution_id
                        and lnk.event_id=ap_dist.accounting_event_id
                        and lnk.ae_header_id=act_ext.actg_header_id
                        and lnk.event_id=act_ext.actg_event_id
                        and lnk.ae_line_num=ael.ae_line_num
                        and aeh.ae_header_id=ael.ae_header_id
                        and aeh.ledger_id=p_trl_global_variables_rec.reporting_ledger_id
                        and aeh.ae_header_id=lnk.ae_header_id
                        and aeh.application_id=lnk.application_id
                        and ael.application_id=aeh.application_id
                        and ael.accounting_class_code not in ('LIABILITY','NRTAX','RTAX')
                        and dtl2.request_id = p_request_id
                        and dtl2.detail_tax_line_id = dtl1.detail_tax_line_id
                     -- and rownum =1
                        ),0)
                        where dtl1.request_id = p_request_id
                          and dtl1.ref_doc_application_id = 201;
                  IF (g_level_statement >= g_current_runtime_level ) THEN
		                  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
			                'Number of rows updated : '||to_char(SQL%ROWCOUNT) );
			            END IF;
          END IF;

 -- This update added to populate recovery rate for migrated AP invoices --
         UPDATE ZX_REP_TRX_DETAIL_T DTL
           SET DTL.TAX_RECOVERY_RATE =
          ( SELECT AP_DIST.REC_NREC_RATE
              FROM AP_INVOICE_DISTRIBUTIONS_ALL AP_DIST
             WHERE AP_DIST.INVOICE_ID=DTL.TRX_ID
               AND AP_DIST.DETAIL_TAX_DIST_ID =DTL.ACTG_SOURCE_ID
               AND AP_DIST.LINE_TYPE_LOOKUP_CODE IN ('REC_TAX','NONREC_TAX')
               AND AP_DIST.HISTORICAL_FLAG = 'Y'
               AND AP_DIST.ORG_ID = DTL.INTERNAL_ORGANIZATION_ID
           )
         WHERE DTL.REQUEST_ID = P_REQUEST_ID
           AND   DTL.HISTORICAL_FLAG = 'Y'
           AND   NVL(DTL.OFFSET_FLAG,'N') = 'N'
           AND   DTL.application_id = 200;

          IF (g_level_statement >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
                 'Number of rows updated For Recovery Rate: '||to_char(SQL%ROWCOUNT) );
          END IF;



	     EXCEPTION
	     WHEN OTHERS THEN
		        IF (g_level_statement >= g_current_runtime_level ) THEN
			          FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
						         'Error Message for report '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		        END IF;
       END;
  	END IF; /* end of condition if report_name = 'JGVAT' */

    IF P_REPORT_NAME = 'ZXXTAVAR' THEN  --Bug 5251425
       BEGIN
          OPEN establishment_id_csr (p_legal_entity_id);
         FETCH establishment_id_csr INTO l_establishment_id;

	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'l_establishment_id : '||l_establishment_id);
	END IF;

         -- ------------------------------------------------ --
         -- Get filtered tax lines                           --
         -- in this case, you need to group the lines by trx --
         -- ------------------------------------------------ --

              SELECT dtl.detail_tax_line_id,
                     dtl.trx_id,
                     dtl.billing_tp_country,
		     dtl.internal_organization_id --Bug 5251425
    BULK COLLECT INTO l_detail_tax_line_id_tbl,
                      l_trx_id_tbl,
                      l_country_code_tbl,
		      l_internal_organization_id_tbl --Bug 5251425
                FROM zx_reporting_types_b rep_type,
                     zx_reporting_codes_b rep_code,
                     zx_report_codes_assoc rep_ass,
                     zx_party_tax_profile ptp,
                     xle_etb_profiles  xle_pf ,
                     zx_rep_trx_detail_t dtl
              WHERE rep_type.reporting_type_id = rep_code.reporting_type_id
                AND rep_type.reporting_type_code = 'MEMBER STATE'
                AND rep_code.reporting_code_id = rep_ass.reporting_code_id
                AND rep_ass.entity_code = 'ZX_PARTY_TAX_PROFILE'
                AND rep_ass.entity_id = ptp.party_tax_profile_id
                AND ptp.party_id = xle_pf.party_id
                AND ptp.Party_Type_Code = 'LEGAL_ESTABLISHMENT'
                AND xle_pf.establishment_id = l_establishment_id
                AND xle_pf.establishment_id = dtl.establishment_id
                AND  rep_code.reporting_code_char_value <> dtl.billing_tp_country
                AND dtl.request_id = p_request_id;

	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
	END IF;

-- Note : Need to add xle_associations_v view to the above query for establishment_id join

         -- Get territory Info  --
IF ( nvl(l_detail_tax_line_id_tbl.count,0) > 0 ) THEN

	GET_TERRITORY_INFO( l_detail_tax_line_id_tbl,
		l_country_code_tbl,
		l_territory_short_name_tbl,
		l_alternate_territory_name_tbl);

	IF (g_level_statement >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
				      'After getting the territory info.' );
	END IF;

	GET_ORG_VAT_NUM ( l_detail_tax_line_id_tbl,
	       l_establishment_id,
	       l_org_vat_num_tbl);

	IF (g_level_statement >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
				      'After getting the org_vat_num' );
	END IF;


--Bug 5251425 : To derive the C_CREATED_BY(zx_rep_trx_detail_t.attribute6)
--		and C_ATTRIBUTE3(Operating Unit Desc)  into (zx_rep_trx_detail_t.attribute7)

	GET_CREATED_BY(
		l_detail_tax_line_id_tbl,
		l_trx_id_tbl,
		l_created_by_tbl
	);

	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'After getting the created_by for invoice' );
	END IF;


	GET_OU_DESC(
		l_detail_tax_line_id_tbl,
		l_internal_organization_id_tbl,
		l_ou_desc_tbl
	);

	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'After getting the OU Description.' );
	END IF;


         FORALL i in nvl(l_detail_tax_line_id_tbl.first,1)..nvl(l_detail_tax_line_id_tbl.last,0)

                INSERT INTO zx_rep_trx_jx_ext_t
                                  (detail_tax_line_ext_id,
                                   detail_tax_line_id,
                                   attribute1,
                                   attribute2,
                                   attribute3,
				   attribute6,--Bug 5251425
				   attribute7,--Bug 5251425
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login)
                           VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                   l_detail_tax_line_id_tbl(i),
                                   l_org_vat_num_tbl(i),
                                   l_territory_short_name_tbl(i),
                                   l_alternate_territory_name_tbl(i),
				   l_created_by_tbl(i),--Bug 5251425
				   l_ou_desc_tbl(i),--Bug 5251425
                                   fnd_global.user_id,
                                   sysdate,
                                   fnd_global.user_id,
                                   sysdate,
                                   fnd_global.login_id);

	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'After insertion into zx_rep_trx_jx_ext_t for report '||p_report_name );
	END IF;

		-- Delete Unwanted lines from Detail ITF

                DELETE FROM zx_rep_trx_detail_t itf
                 WHERE itf.request_id = p_request_id
                   AND NOT EXISTS ( SELECT 1
                                      FROM zx_rep_trx_jx_ext_t ext
                                     WHERE ext.detail_tax_line_id = itf.detail_tax_line_id);

	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'After deletion from zx_rep_trx_detail_t : '||to_char(SQL%ROWCOUNT) );
	END IF;
END IF ;

    EXCEPTION
       WHEN OTHERS THEN
       NULL;
		IF (g_level_statement >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
						      'Error Message for report '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;

       END;
   END IF;

-- This plug-in call extracts adjustment tax code for Italy, Poland, Portugal countries requirement

   IF P_REPORT_NAME <> 'JGVAT' THEN

      IF p_product = 'AR' or p_product = 'ALL' THEN

	 BEGIN

               SELECT dtl.detail_tax_line_id,
                      dtl.tax_rate_code
    BULK COLLECT INTO l_detail_tax_line_id_tbl,
                      l_tax_rate_code_tbl
                 FROM zx_rep_trx_detail_t dtl
                WHERE dtl.request_id = p_request_id;

	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
	END IF;

        adjustment_tax_code(
                  l_detail_tax_line_id_tbl,
                  l_tax_rate_code_tbl,
                  l_adj_tax_code_tbl);

	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'After getting adjustment tax code for Italy, Poland, Portugal countries');
	END IF;

         FORALL i in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last
                INSERT INTO zx_rep_trx_jx_ext_t
                                  (detail_tax_line_ext_id,
                                   detail_tax_line_id,
                                   attribute1,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login)
                           VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                   l_detail_tax_line_id_tbl(i),
                                   l_adj_tax_code_tbl(i),
                                   fnd_global.user_id,
                                   sysdate,
                                   fnd_global.user_id,
                                   sysdate,
                                   fnd_global.login_id);

	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;

    EXCEPTION
       WHEN OTHERS THEN
       NULL;
		IF (g_level_statement >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
						      'Error Message for report '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;
     END;
  END IF;
  END IF;
	g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
	IF (g_level_procedure >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP.BEGIN',
				      'ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP(-)');
	END IF;
	null;

END populate_core_ap;


PROCEDURE get_territory_info
          (
--p_report_name                  IN VARCHAR2,
           p_detail_tax_line_id_tbl       IN ZX_EXTRACT_PKG.detail_tax_line_id_tbl,
           p_country_code_tbl             IN ZX_EXTRACT_PKG.billing_tp_country_tbl,
           p_territory_short_name_tbl     OUT NOCOPY ATTRIBUTE2_TBL,
           p_alternate_territory_name_tbl OUT NOCOPY ATTRIBUTE3_TBL
          )
IS

BEGIN

   FOR i in 1..nvl(p_detail_tax_line_id_tbl.last,0) LOOP
       BEGIN
          SELECT ft.territory_short_name,
                 ft.alternate_territory_code
            INTO p_territory_short_name_tbl(i),
                 p_alternate_territory_name_tbl(i)
            FROM fnd_territories_vl ft
           WHERE ft.territory_code = p_country_code_tbl(i);
	EXCEPTION
	WHEN OTHERS THEN
		p_territory_short_name_tbl(i) := NULL ;
		p_alternate_territory_name_tbl(i) := NULL ;
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
			'Error Message : '||substrb(SQLERRM,1,120) );
		END IF;
       END;
   END LOOP;

END get_territory_info;

PROCEDURE get_org_vat_num (
                    --p_report_name            IN  VARCHAR2,
                             p_detail_tax_line_id_tbl IN  ZX_EXTRACT_PKG.detail_tax_line_id_tbl,
                       --      p_request_id             IN  NUMBER,
                             p_establishment_id        IN NUMBER,
                             p_org_vat_num_tbl        OUT NOCOPY ATTRIBUTE2_TBL)
IS
BEGIN

   FOR i in 1..nvl(p_detail_tax_line_id_tbl.last,0) LOOP
      BEGIN
        SELECT rep_code.reporting_code_char_value
         INTO p_org_vat_num_tbl(i)
         FROM zx_reporting_types_b rep_type,
              zx_reporting_codes_b rep_code,
              zx_report_codes_assoc rep_ass,
              zx_party_tax_profile ptp,
              xle_etb_profiles  xle_pf
          --    zx_rep_trx_detail_t dtl
        WHERE rep_type.reporting_type_id = rep_code.reporting_type_id
          AND rep_type.reporting_type_code = 'FSO_REG_NUM'
          AND rep_code.reporting_code_id = rep_ass.reporting_code_id
          AND rep_ass.entity_code = 'ZX_PARTY_TAX_PROFILE'
          AND rep_ass.entity_id = ptp.party_tax_profile_id
          AND ptp.party_id = xle_pf.party_id
          AND ptp.Party_Type_Code = 'LEGAL_ESTABLISHMENT'
          AND xle_pf.establishment_id = p_establishment_id;
--        AND  rep_code.reporting_code_char_value <> dtl.billing_tp_country;
	EXCEPTION
	WHEN OTHERS THEN
		p_org_vat_num_tbl(i) := NULL ;
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
			'Error Message : '||substrb(SQLERRM,1,120) );
		END IF;
	END ;
      END LOOP;
END get_org_vat_num;


PROCEDURE adjustment_tax_code(
                    p_detail_tax_line_id_tbl IN  ZX_EXTRACT_PKG.detail_tax_line_id_tbl,
                    p_tax_rate_code_tbl      IN  ZX_EXTRACT_PKG.tax_rate_code_tbl,
                    p_adj_tax_code_tbl       OUT NOCOPY ATTRIBUTE1_TBL)
IS
   BEGIN
   FOR i in 1..nvl(p_detail_tax_line_id_tbl.last,0) LOOP
       BEGIN
       SELECT rep_code.reporting_code_char_value
         INTO p_adj_tax_code_tbl(i)
         FROM zx_reporting_types_b rep_type,
              zx_reporting_codes_b rep_code,
              zx_report_codes_assoc rep_ass,
              zx_rates_b zx_rate
        WHERE rep_type.reporting_type_id = rep_code.reporting_type_id
          AND rep_type.reporting_type_code = 'ZX_ADJ_TAX_CLASSIF_CODE'
          AND rep_code.reporting_code_id = rep_ass.reporting_code_id
          AND rep_ass.entity_code = 'ZX_RATES'
          AND rep_ass.entity_id = zx_rate.tax_rate_id
          AND zx_rate.tax_rate_code = p_tax_rate_code_tbl(i);
	EXCEPTION
	WHEN OTHERS THEN
		p_adj_tax_code_tbl(i) := NULL ;
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP',
			'Error Message : '||substrb(SQLERRM,1,120) );
		END IF;
	END ;
    END LOOP;
  END;

PROCEDURE RETRIEVE_GEO_VALUE( p_event_class_mapping_id IN  ZX_LINES_DET_FACTORS.event_class_mapping_id%type,
                              p_trx_id                 IN  ZX_LINES_DET_FACTORS.trx_id%type,
                              p_trx_line_id            IN  ZX_LINES_DET_FACTORS.trx_line_id%type,
                              p_trx_level_type         IN  ZX_LINES_DET_FACTORS.trx_level_type%type,
                              p_location_type          IN  VARCHAR2,
                              p_location_id            IN  ZX_LINES_DET_FACTORS.ship_to_location_id%type,
                              p_geography_type         IN  VARCHAR2,
                              x_geography_value        OUT NOCOPY VARCHAR2,
                              x_geo_val_found          OUT NOCOPY BOOLEAN) IS

   hash_string                     varchar2(1000);
   TABLE_SIZE              BINARY_INTEGER := 65636;
   TABLEIDX                        binary_integer;
   loc_info_idx                    binary_integer;
   HASH_VALUE binary_integer;

   BEGIN

      hash_string := to_char(p_event_class_mapping_id)||'|'||
                     to_char(p_trx_id)||'|'||
                     to_char(p_trx_line_id)||'|'||
                     p_trx_level_type||'|'||
                     p_location_type||'|'||
                     to_char(p_location_id)||'|'||
                     p_geography_type;

       TABLEIDX := dbms_utility.get_hash_value(hash_string,1,TABLE_SIZE);

       IF (ZX_GLOBAL_STRUCTURES_PKG.location_hash_tbl.EXISTS(TABLEIDX)) THEN
         loc_info_idx := ZX_GLOBAL_STRUCTURES_PKG.location_hash_tbl(TABLEIDX);
         x_geography_value := ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.geography_value(loc_info_idx);
         x_geo_val_found := TRUE;
       ELSE
         x_geo_val_found := FALSE;
       END IF;

end RETRIEVE_GEO_VALUE;

--Bug 5251425
PROCEDURE GET_CREATED_BY
          (
           p_detail_tax_line_id_tbl       IN ZX_EXTRACT_PKG.detail_tax_line_id_tbl,
           p_trx_id_tbl			  IN ZX_EXTRACT_PKG.trx_id_tbl,
           p_created_by_tbl		  OUT NOCOPY ATTRIBUTE6_TBL
          )
IS

BEGIN

   FOR i in 1..nvl(p_detail_tax_line_id_tbl.last,0) LOOP
       BEGIN
          SELECT fu.user_name
	     INTO p_created_by_tbl(i)
            FROM ap_invoices_all ai,
		 fnd_user fu
           WHERE ai.invoice_id = p_trx_id_tbl(i)
	   AND fu.user_id = ai.created_by ;
	EXCEPTION
		WHEN OTHERS THEN
		p_created_by_tbl(i) := NULL ;
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
			'Error Message : '||substrb(SQLERRM,1,120) );
		END IF;
       END;
   END LOOP;

END GET_CREATED_BY;

--Bug 5251425
PROCEDURE GET_OU_DESC
          (
           p_detail_tax_line_id_tbl       IN ZX_EXTRACT_PKG.detail_tax_line_id_tbl,
           p_internal_organization_id_tbl IN ZX_EXTRACT_PKG.internal_organization_id_tbl,
           p_ou_desc_tbl		  OUT NOCOPY ATTRIBUTE7_TBL
          )
IS

BEGIN

   FOR i in 1..nvl(p_detail_tax_line_id_tbl.last,0) LOOP
       BEGIN
		SELECT hou.NAME
		INTO p_ou_desc_tbl(i)
		FROM hr_operating_units hou
		WHERE hou.organization_id = p_internal_organization_id_tbl(i);
	EXCEPTION
	WHEN OTHERS THEN
		p_ou_desc_tbl(i) := NULL ;
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
			'Error Message : '||substrb(SQLERRM,1,120) );
		END IF;
       END;
   END LOOP;

END GET_OU_DESC;
--Bug 5251425
PROCEDURE GET_MATCH(
			p_detail_tax_line_id_tbl ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
			p_acc_ccid_tbl ACC_CCID_TBL ,
			p_match_tbl OUT NOCOPY ATTRIBUTE5_TBL
		    )
IS
	l_nls_no	VARCHAR(10);
BEGIN
	SELECT
		ln.meaning
		INTO     l_nls_no
	FROM
		fnd_lookups ln,  ap_lookup_codes la
	WHERE
		ln.lookup_type = 'YES_NO'
		AND   ln.lookup_code = 'N'
		AND   la.lookup_type = 'NLS REPORT PARAMETER'
		AND   la.lookup_code = 'ALL';

	FOR i in 1..nvl(p_detail_tax_line_id_tbl.last,0) LOOP
		BEGIN
			SELECT Decode(p_ACC_CCID_TBL(i), act.ACTG_LINE_CCID,NULL,l_nls_no )
			INTO p_match_tbl(i)
			FROM   ZX_REP_ACTG_EXT_T act
			WHERE act.detail_tax_line_id = p_detail_tax_line_id_tbl(i);
		EXCEPTION
		WHEN OTHERS THEN
			p_match_tbl(i) := null;
			IF ( g_level_statement>= g_current_runtime_level ) THEN
				FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
				'Error Message : '||substrb(SQLERRM,1,120) );
			END IF;
		END;
	END LOOP;
END GET_MATCH;

--To get the Received amounts for the report ZXXCDE
PROCEDURE GET_RECEIVED_AMOUNTS
(
	p_detail_tax_line_id_tbl IN ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
	p_trx_id_tbl	         IN ZX_EXTRACT_PKG.trx_id_tbl,
	p_org_id_tbl		 IN zx_extract_pkg.INTERNAL_ORGANIZATION_ID_TBL ,
	p_amount_received_tbl	 OUT NOCOPY NUMERIC2_TBL,
	p_tax_received_tbl    OUT NOCOPY NUMERIC1_TBL
)
IS

l_amount_recvd_tbl NUMERIC2_TBL;
l_tax_amount_rcvd_tbl NUMERIC1_TBL;

BEGIN

 FOR i in 1..nvl(p_detail_tax_line_id_tbl.last,0) LOOP

         IF l_amount_recvd_tbl.EXISTS(p_trx_id_tbl(i)) THEN
            null;
         ELSE
             l_amount_recvd_tbl(p_trx_id_tbl(i)) := null;
         END IF;

         IF l_tax_amount_rcvd_tbl.EXISTS(p_trx_id_tbl(i)) THEN
            null;
         ELSE
             l_tax_amount_rcvd_tbl(p_trx_id_tbl(i)) := null;
         END IF;

--get amount received for that trx without any proration done , populate the amount only once per trx_id
-- in the extension table
	 IF l_amount_recvd_tbl(p_trx_id_tbl(i)) is NULL THEN

		BEGIN
			SELECT SUM(nvl(amount_applied,0)) ,sum(nvl(tax_applied,0))
			INTO l_amount_recvd_tbl(p_trx_id_tbl(i)),l_tax_amount_rcvd_tbl(p_trx_id_tbl(i))
			FROM AR_RECEIVABLE_APPLICATIONS_ALL
			WHERE applied_customer_trx_id = p_trx_id_tbl(i)
			AND org_id = p_org_id_tbl(i)
      AND  status = 'APP'
      AND  application_type = 'CASH';
		EXCEPTION
		WHEN OTHERS THEN
			l_amount_recvd_tbl(p_trx_id_tbl(i)) := 0;
			l_tax_amount_rcvd_tbl(p_trx_id_tbl(i)) := 0;

			IF ( g_level_statement>= g_current_runtime_level ) THEN
				FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
				'Error Message : '||substrb(SQLERRM,1,120) );
			END IF;
		END ;
		p_amount_received_tbl(i) := l_amount_recvd_tbl(p_trx_id_tbl(i));
		p_tax_received_tbl(i) := l_tax_amount_rcvd_tbl(p_trx_id_tbl(i)) ;
	  ELSE
		p_amount_received_tbl(i) := 0 ;
		p_tax_received_tbl(i) := 0 ;
	 END IF ;
END LOOP ;

EXCEPTION
WHEN OTHERS THEN
NULL ;
END ;


/*======================================================================================+
 | PROCEDURE                                                                            |
 |   POPULATE_TAX_JURIS_FOR_USSTR                                                       |
 |   Type       : Private                                                               |
 |   Pre-req    : None                                                                  |
 |   Function   :                                                                       |
 |    This procedure extracts State, County, and City of taxing jurisdiction            |
 |    for each tax line into table                                                      |
 |                                                                                      |
 |    Called from XX_XX_EXTRACT_PKG.XXXXXXXX                                            |
 |                                                                                      |
 |   Parameters :                                                                       |
 |   IN         :  P_TRL_GLOBAL_VARIABLES_REC    IN   VARCHAR2                          |
 |                                                                                      |
 |   MODIFICATION HISTORY                                                               |
 |     20-Jun-05  Santosh Vaze      created                                             |
 |                                                                                      |
 +======================================================================================*/


PROCEDURE POPULATE_CORE_AR(
          P_TRL_GLOBAL_VARIABLES_REC     IN      ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
          )
IS

P_REPORT_NAME                   VARCHAR2(30);
P_POSTING_STATUS                VARCHAR2(30);
P_REQUEST_ID                    NUMBER;
l_place_of_supply               ZX_LINES.place_of_supply_type_code%type;
l_location_type_tbl             ZX_TCM_GEO_JUR_PKG.location_type_tbl_type;
l_location_id_tbl               ZX_TCM_GEO_JUR_PKG.location_id_tbl_type;
l_geo_val_found                 BOOLEAN;
x_return_status  VARCHAR2(1);
prev_event_class_mapping_id       NUMBER;

TYPE DETAIL_TAX_LINE_ID_TBL IS TABLE OF
  ZX_REP_TRX_DETAIL_T.DETAIL_TAX_LINE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE EVENT_CLASS_MAPPING_ID_TBL IS TABLE OF
  ZX_REP_TRX_DETAIL_T.EVENT_CLASS_MAPPING_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE TRX_ID_TBL IS TABLE OF
  ZX_REP_TRX_DETAIL_T.TRX_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE TRX_LINE_ID_TBL IS TABLE OF
  ZX_REP_TRX_DETAIL_T.TRX_LINE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE TRX_LEVEL_TYPE_TBL IS TABLE OF
  ZX_REP_TRX_DETAIL_T.TRX_LEVEL_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE POS_TYPE_CODE_TBL IS TABLE OF
  ZX_REP_TRX_DETAIL_T.PLACE_OF_SUPPLY_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE SHIP_TO_LOCATION_ID_TBL IS TABLE OF
  ZX_REP_TRX_DETAIL_T.SHIP_TO_LOCATION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE SHIP_FROM_LOCATION_ID_TBL IS TABLE OF
  ZX_REP_TRX_DETAIL_T.SHIP_FROM_LOCATION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE BILL_TO_LOCATION_ID_TBL IS TABLE OF
  ZX_REP_TRX_DETAIL_T.BILL_TO_LOCATION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE BILL_FROM_LOCATION_ID_TBL IS TABLE OF
  ZX_REP_TRX_DETAIL_T.BILL_FROM_LOCATION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE POA_LOCATION_ID_TBL IS TABLE OF
  ZX_REP_TRX_DETAIL_T.POA_LOCATION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE POO_LOCATION_ID_TBL IS TABLE OF
  ZX_REP_TRX_DETAIL_T.POO_LOCATION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE DEF_POS_TYPE_CODE_TBL IS TABLE OF
  ZX_REP_TRX_DETAIL_T.DEF_PLACE_OF_SUPPLY_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE GEO_VAL_TBL IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

l_detail_tax_line_id_tbl        ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
l_event_class_mapping_id_tbl    EVENT_CLASS_MAPPING_ID_TBL;
l_trx_id_tbl                    ZX_EXTRACT_PKG.TRX_ID_TBL;
l_trx_line_id_tbl               TRX_LINE_ID_TBL;
l_trx_level_type_tbl            TRX_LEVEL_TYPE_TBL;
l_pos_type_code_tbl             POS_TYPE_CODE_TBL;
l_ship_to_location_id_tbl       SHIP_TO_LOCATION_ID_TBL;
l_ship_from_location_id_tbl     SHIP_FROM_LOCATION_ID_TBL;
l_bill_to_location_id_tbl       BILL_TO_LOCATION_ID_TBL;
l_bill_from_location_id_tbl     BILL_FROM_LOCATION_ID_TBL;
l_poa_location_id_tbl           POA_LOCATION_ID_TBL;
l_poo_location_id_tbl           POO_LOCATION_ID_TBL;
l_def_pos_type_code_tbl         DEF_POS_TYPE_CODE_TBL;
l_state_tbl                     GEO_VAL_TBL;
l_county_tbl                    GEO_VAL_TBL;
l_city_tbl                      GEO_VAL_TBL;

--Bug 5251425 : Variable Declarations for the Bug.
l_ledger_id_tbl zx_extract_pkg.ledger_id_tbl;
l_period_net_dr_tbl number_tbl;
l_period_net_cr_tbl number_tbl;
l_gl_activity_tbl number_tbl;
t_gl_activity_tbl number_tbl;
l_ccid_tbl ccid_tbl ;

l_amount_received_tbl NUMERIC2_TBL;
l_tax_received_tbl NUMERIC1_TBL;

l_bal_seg_prompt_tbl ATTRIBUTE1_TBL;

l_set_of_books_id apps.gl_sets_of_books.set_of_books_id%type;
l_period_from apps.gl_period_statuses.period_name%type;
l_period_to apps.gl_period_statuses.period_name%type;

--Bug 9031051
l_reporting_code_tbl            attribute2_tbl;
l_reporting_code_char_tbl       ATTRIBUTE10_TBL;
l_adj_trx_id_tbl                ZX_EXTRACT_PKG.ADJUSTED_DOC_TRX_ID_TBL;
l_adj_trx_line_id_tbl           ZX_EXTRACT_PKG.applied_to_trx_line_id_tbl;
l_adj_application_id_tbl        ZX_EXTRACT_PKG.ADJUSTED_DOC_APPL_ID_TBL;
l_adj_event_class_code_tbl      ZX_EXTRACT_PKG.ADJUSTED_DOC_EVENT_CLS_CD_TBL;
l_event_class_code_tbl          ZX_EXTRACT_PKG.EVENT_CLASS_CODE_TBL;
l_adj_entity_code_tbl           ZX_EXTRACT_PKG.ADJUSTED_DOC_ENTITY_CODE_TBL;
l_adj_doc_date_tbl              ZX_EXTRACT_PKG.ADJUSTED_DOC_DATE_TBL;
l_out_of_period_adj_tbl         attribute5_tbl;
l_func_curr_line_amt_tbl        numeric5_tbl;
l_country_code_reg_num_tbl      attribute1_tbl;
l_country_code_tbl              ZX_EXTRACT_PKG.BILLING_TP_COUNTRY_TBL;
l_tax_reg_num_tbl               attribute6_tbl;
l_territory_short_name_tbl      ATTRIBUTE2_TBL;
l_alternate_territory_name_tbl  ATTRIBUTE3_TBL;
l_adj_tax_invoice_tbl           ZX_EXTRACT_PKG.TAX_INVOICE_DATE_TBL;
l_adj_gl_date_tbl               ZX_EXTRACT_PKG.GL_DATE_TBL;
l_adj_trx_date_tbl               ZX_EXTRACT_PKG.TRX_DATE_TBL;
l_org_id_tbl                    ZX_EXTRACT_PKG.INTERNAL_ORGANIZATION_ID_TBL;
l_bill_to_tax_reg_num_tbl       ZX_EXTRACT_PKG.BILLING_TP_TAX_REG_NUM_TBL;
l_bill_to_site_tax_reg_num_tbl  ZX_EXTRACT_PKG.BILLING_TP_SITE_TX_REG_NUM_TBL;
l_ship_to_site_tax_reg_num_tbl  ZX_EXTRACT_PKG.SHIPPING_TP_SITE_TX_RG_NUM_TBL;
l_billing_tp_name_tbl           ZX_EXTRACT_PKG.BILLING_TP_NAME_TBL;
l_shipping_tp_name_tbl          ZX_EXTRACT_PKG.SHIPPING_TP_NAME_TBL;
l_adj_trx_class_tbl             ZX_EXTRACT_PKG.TRX_CLASS_MNG_TBL;
l_adj_trx_class_mng_tbl         ZX_EXTRACT_PKG.TRX_CLASS_MNG_TBL;
l_disc_class_mng_tbl            ZX_EXTRACT_PKG.TRX_CLASS_MNG_TBL;
l_hq_estb_ptp_id_tbl            ZX_EXTRACT_PKG.SHIP_TO_PARTY_TAX_PROF_ID_TBL;
l_hq_estb_reg_num_tbl           ZX_EXTRACT_PKG.HQ_ESTB_REG_NUMBER_TBL;
l_receivable_app_id_tbl         ZX_EXTRACT_PKG.APPLIED_FROM_TRX_ID_TBL;
l_disc_apply_date_tbl           ZX_EXTRACT_PKG.TRX_DATE_TBL;

 l_description      VARCHAR2(240);
 l_meaning          VARCHAR2(80);

BEGIN

-- IF PG_DEBUG = 'Y' THEN
--
--             arp_standard.debug('ZX.plsql.ZX_XX_EXTRACT_PKG.populate_tax_juris_for_usstr(+) ');
-- END IF;
	g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

	IF (g_level_procedure >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AP.BEGIN',
				      'ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR(+)');
	END IF;


 -- Get necessary parameters from TRL Global Variables

 P_REPORT_NAME       := P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME;
 P_REQUEST_ID        := P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;
 P_POSTING_STATUS    := P_TRL_GLOBAL_VARIABLES_REC.POSTING_STATUS;

 prev_event_class_mapping_id := 0;

	IF (g_level_statement >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'p_report_name : '||P_REPORT_NAME);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'p_request_id : '||p_request_id);
	END IF;

--Bug 9031051

 IF P_REPORT_NAME = 'ZXXEUSL' THEN
 	IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
           'P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_GOODS: '||P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_GOODS );
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
           'P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_SERVICES: '||P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_SERVICES );
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
           'P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_ADDL_CODE1: '||P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_ADDL_CODE1 );
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
           'P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_ADDL_CODE2: '||P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_ADDL_CODE2 );
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
           'P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_TRX_TYPE: '||P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_TRX_TYPE);
	END IF;

    BEGIN
     -- Directly populate the tax line id from Base Doc on which application is done.
     UPDATE zx_rep_trx_detail_t dtl
     set dtl.tax_line_id = (select min (tax_line_id)
                             from zx_lines lines
                            where lines.application_id = 222
                              and lines.trx_id = dtl.ADJUSTED_DOC_TRX_ID
                              and lines.trx_line_id = dtl.APPLIED_TO_TRX_LINE_ID
                              and lines.tax_rate_id = dtl.tax_rate_id
                              and nvl(lines.hq_estb_reg_number,fnd_api.g_miss_char) =
                                  P_TRL_GLOBAL_VARIABLES_REC.FIRST_PARTY_TAX_REG_NUM
                          )
     WHERE dtl.request_id = P_REQUEST_ID
     and dtl.EXTRACT_SOURCE_LEDGER = 'AR'
     and dtl.APPLICATION_ID =222
     and dtl.APPLIED_FROM_ENTITY_CODE = 'APP';

     -- Directly populate the tax line id from Adjustment Doc
     UPDATE zx_rep_trx_detail_t dtl
     set dtl.tax_line_id = (select min (tax_line_id)
                              from zx_lines lines
                              where lines.application_id = 222
                              and lines.trx_id = dtl.ADJUSTED_DOC_TRX_ID
                              and lines.trx_line_id = dtl.APPLIED_TO_TRX_LINE_ID
                              AND lines.tax_rate_id = dtl.tax_rate_id
                              AND nvl(lines.hq_estb_reg_number,fnd_api.g_miss_char) =
                                    P_TRL_GLOBAL_VARIABLES_REC.FIRST_PARTY_TAX_REG_NUM
                           )
     WHERE dtl.request_id = P_REQUEST_ID
     and dtl.EXTRACT_SOURCE_LEDGER = 'AR'
     and dtl.APPLICATION_ID =222
     and dtl.EVENT_CLASS_CODE = 'ADJ';

/***
     UPDATE zx_rep_trx_detail_t dtl
     set tax_line_id = (select min (tax_line_id)
                        from zx_lines lines
                        where lines.application_id = 222
                        and lines.trx_id = dtl.TRX_ID
                        and lines.trx_line_id = dtl.TRX_LINE_ID)
     WHERE dtl.request_id = P_REQUEST_ID
     and dtl.EXTRACT_SOURCE_LEDGER = 'AR'
     and dtl.APPLICATION_ID =222
     and dtl.EVENT_CLASS_CODE ='ADJ';
***/
    EXCEPTION WHEN OTHERS THEN
          IF ( g_level_statement>= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
               'Error in updating tax line id zx_rep_trx_detail_t: Error Message : '||substrb(SQLERRM,1,120) );
          END IF;
    END;


    BEGIN
      SELECT dtl.detail_tax_line_id,
             dtl.trx_id,
             dtl.trx_line_id,
             dtl.event_class_code,
             --rep_code.reporting_code_name,
             --assoc.reporting_code_char_value,
             ZX_EXTRACT_PKG.get_vat_transaction_code_name(
                               dtl.tax_line_id,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_TRX_TYPE,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_GOODS,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_SERVICES,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_ADDL_CODE1,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_ADDL_CODE2,
                               'NAME'),
             ZX_EXTRACT_PKG.get_vat_transaction_code_name(
                               dtl.tax_line_id,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_TRX_TYPE,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_GOODS,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_SERVICES,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_ADDL_CODE1,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_ADDL_CODE2,
                               'CODE'),
             dtl.adjusted_doc_trx_id,
             NVL(dtl.applied_from_trx_id,NULL),
             NVL(dtl.applied_to_trx_line_id,NULL),  -- Adjusted_doc_line_id
             dtl.adjusted_doc_application_id,
             dtl.adjusted_doc_event_class_code,
             dtl.adjusted_doc_entity_code,
             dtl.adjusted_doc_date,
             decode(P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_SITE_REPORTED,'SHIP TO', dtl.shipping_tp_country,
             dtl.billing_tp_country),
             dtl.internal_organization_id,
             NVL(dtl.SHIPPING_TP_SITE_TAX_REG_NUM,NULL),
             NVL(dtl.BILLING_TP_SITE_TAX_REG_NUM,NULL),
             NVL(dtl.BILLING_TP_TAX_REG_NUM,NULL),
             dtl.billing_tp_name,
             dtl.shipping_tp_name,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL
        BULK COLLECT
        INTO l_detail_tax_line_id_tbl,
             l_trx_id_tbl,
             l_trx_line_id_tbl,
             l_event_class_code_tbl,
             l_reporting_code_tbl,
             l_reporting_code_char_tbl,
             l_adj_trx_id_tbl,
             l_receivable_app_id_tbl,
             l_adj_trx_line_id_tbl,
             l_adj_application_id_tbl,
             l_adj_event_class_code_tbl,
             l_adj_entity_code_tbl,
             l_adj_doc_date_tbl,
             l_country_code_tbl,
             l_org_id_tbl,
             l_ship_to_site_tax_reg_num_tbl,
             l_bill_to_site_tax_reg_num_tbl,
             l_bill_to_tax_reg_num_tbl,
             l_billing_tp_name_tbl,
             l_shipping_tp_name_tbl,
             l_out_of_period_adj_tbl,
             l_func_curr_line_amt_tbl,
             l_country_code_reg_num_tbl,
             l_tax_reg_num_tbl,
             l_adj_tax_invoice_tbl,
             l_adj_gl_date_tbl,
             l_adj_trx_date_tbl,
             l_adj_trx_class_mng_tbl,
             l_hq_estb_reg_num_tbl,
             l_disc_class_mng_tbl,
             l_disc_apply_date_tbl
        FROM zx_rep_trx_detail_t dtl
       WHERE dtl.request_id = P_REQUEST_ID
       and   ZX_EXTRACT_PKG.get_vat_transaction_code_name(
                               dtl.tax_line_id,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_TRX_TYPE,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_GOODS,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_SERVICES,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_ADDL_CODE1,
                               P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_ADDL_CODE2,
                               'CODE') IS NOT NULL;

    EXCEPTION
      WHEN OTHERS THEN
      IF ( g_level_statement>= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
           'Error in fetching data from zx_rep_detail_t: Error Message : '||substrb(SQLERRM,1,120) );
      END IF;
    END;

	  IF ( g_level_statement>= g_current_runtime_level ) THEN
		   FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
	  END IF;

    FOR i in 1..Nvl(l_detail_tax_line_id_tbl.last,0) LOOP

    IF ( g_level_statement>= g_current_runtime_level ) THEN
		   FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'In l_detail_tax_line_id_tbl Loop'||to_char(l_detail_tax_line_id_tbl(i)));
	  END IF;

      IF l_adj_trx_id_tbl(i) IS NOT NULL THEN

        IF ( g_level_statement>= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
            'Debug: l_trx_id_tbl(i) IS NOT NULL '||to_char(l_trx_id_tbl(i)) );
          FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
            'Debug: l_org_id_tbl(i) IS NOT NULL '||to_char(l_org_id_tbl(i)) );
     	    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
            'Debug: l_adj_trx_id_tbl(i) IS NOT NULL '||to_char(l_adj_trx_id_tbl(i)) );
     	    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
            'Debug: l_adj_trx_line_id_tbl(i) IS NOT NULL '||to_char(l_adj_trx_line_id_tbl(i)) );
     	  END IF;
         -- To avoid repopulating the data for same item line
         IF (i = 1 OR l_trx_id_tbl(i) <> l_trx_id_tbl(i-1)
            OR nvl(l_adj_trx_line_id_tbl(i),l_trx_line_id_tbl(i))
            <> nvl(l_adj_trx_line_id_tbl(i-1),l_trx_line_id_tbl(i-1))) THEN
             BEGIN
                SELECT TAX_INVOICE_DATE,
                       TRX_LINE_GL_DATE,
                       TRX_DATE,
                       LINE_CLASS,
                       HQ_ESTB_PARTY_TAX_PROF_ID
                  INTO l_adj_tax_invoice_tbl(i),
                       l_adj_gl_date_tbl(i),
                       l_adj_trx_date_tbl(i),
                       l_adj_trx_class_tbl(i),
                       l_hq_estb_ptp_id_tbl(i)
                  FROM ZX_LINES_DET_FACTORS zx_det
                 WHERE zx_det.application_id = 222
                   AND zx_det.trx_id = l_adj_trx_id_tbl(i)
                   and zx_det.trx_line_id = Nvl(l_adj_trx_line_id_tbl(i),zx_det.trx_line_id)
                   AND ROWNUM = 1;
              EXCEPTION
              WHEN OTHERS THEN
                   IF (g_level_statement>= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                      'Error in fetching data from ZX_LINES_DET_FACTORS for adjusted doc tax invoice date and gl date. Error Message : '
                      ||substrb(SQLERRM,1,120) );
                   END IF;
              END;

          IF ((l_adj_tax_invoice_tbl(i) IS NOT NULL
               AND (l_adj_tax_invoice_tbl(i) < P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_LOW
               OR l_adj_tax_invoice_tbl(i) > P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_HIGH))
             OR (P_TRL_GLOBAL_VARIABLES_REC.ESL_DEFAULT_TAX_DATE = 'GL DATE'
                 AND (l_adj_gl_date_tbl(i) < P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_LOW
                 OR l_adj_gl_date_tbl(i) > P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_HIGH))
             OR (P_TRL_GLOBAL_VARIABLES_REC.ESL_DEFAULT_TAX_DATE = 'TRX DATE'
                 AND (l_adj_doc_date_tbl(i) < P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_LOW
                 OR l_adj_doc_date_tbl(i) > P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_HIGH)))
          THEN
              l_out_of_period_adj_tbl(i) := 'OUT_PERIOD_ADJUSTMENT';
          ELSE
              l_out_of_period_adj_tbl(i) := 'IN_PERIOD_ADJUSTMENT';
          END IF;

          IF l_adj_tax_invoice_tbl(i) IS  NULL THEN
             IF P_TRL_GLOBAL_VARIABLES_REC.ESL_DEFAULT_TAX_DATE = 'GL DATE' THEN
                l_adj_tax_invoice_tbl(i) :=   l_adj_gl_date_tbl(i);
             ELSIF P_TRL_GLOBAL_VARIABLES_REC.ESL_DEFAULT_TAX_DATE = 'TRX DATE' THEN
                l_adj_tax_invoice_tbl(i) := l_adj_trx_date_tbl(i);
             END IF;
          END IF;

            IF l_hq_estb_ptp_id_tbl(i) IS NOT NULL THEN
               SELECT registration_number
                 INTO l_hq_estb_reg_num_tbl(i)
                 FROM zx_registrations
                WHERE party_tax_profile_id = l_hq_estb_ptp_id_tbl(i)
                  AND registration_number = P_TRL_GLOBAL_VARIABLES_REC.FIRST_PARTY_TAX_REG_NUM
                  AND rownum = 1 ;
            END IF;


            ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_TRL_TAXABLE_TRX_TYPE',
                             l_adj_trx_class_tbl(i),
                             l_meaning,
                             l_description);

                l_adj_trx_class_mng_tbl(i) := l_meaning;
        ELSE -- Do not repopulate the existing data
          IF ( g_level_statement>= g_current_runtime_level ) THEN
          		   FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
          					      'Debug: Not repopulating the data');
          END IF;
        IF ( g_level_statement>= g_current_runtime_level ) THEN
     		   FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                  'Debug: l_adj_trx_id_tbl(i) IS NOT NULL '||to_char(l_adj_trx_id_tbl(i))||' '||to_char(l_adj_trx_line_id_tbl(i)) );
     	  END IF;
          l_adj_tax_invoice_tbl(i) := l_adj_tax_invoice_tbl(i-1);
          l_adj_gl_date_tbl(i) := l_adj_gl_date_tbl(i-1);
          l_out_of_period_adj_tbl(i) := l_out_of_period_adj_tbl(i-1);
          l_adj_trx_class_mng_tbl(i) := l_adj_trx_class_mng_tbl(i-1);
        END IF;
      ELSE
          l_out_of_period_adj_tbl(i) := 'IN_PERIOD_ADJUSTMENT';
      END IF; --adj_trx_id is not null

      IF (i = 1 OR l_trx_id_tbl(i) <> l_trx_id_tbl(i-1)
                OR Nvl(l_adj_trx_line_id_tbl(i),l_trx_line_id_tbl(i)) <> Nvl(l_adj_trx_line_id_tbl(i-1),l_trx_line_id_tbl(i-1))) THEN
         --Code for populating the functional amount
          IF ( g_level_statement>= g_current_runtime_level ) THEN
          		   FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
          					      'Debug: Populating functional amount' );
          END IF;

          BEGIN

          IF l_event_class_code_tbl(i) = 'ADJ' THEN
              IF (g_level_statement>= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                 'Debug: Populating functional amount ADJ - l_adj_trx_line_id_tbl : '||to_char(l_adj_trx_line_id_tbl(i) ));
              END IF;

              SELECT sum(nvl(ACCTD_AMOUNT_CR,0) - nvl(ACCTD_AMOUNT_DR,0))
                INTO l_func_curr_line_amt_tbl(i)
                FROM ar_distributions_all
               WHERE source_id = l_trx_id_tbl(i)
                 AND source_table = 'ADJ'
                 AND ref_customer_trx_line_id = l_adj_trx_line_id_tbl(i)
                 AND org_id = l_org_id_tbl(i);

              IF (g_level_statement>= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                  'Debug: After Populating functional amount ADJ : '||to_char(l_func_curr_line_amt_tbl(i) ));
              END IF;
          ELSIF l_event_class_code_tbl(i) IN ('EDISC', 'UNEDISC') THEN
              IF (g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
               'Debug: Populating functional amount Discounts - l_adj_trx_line_id_tbl : '||to_char(l_adj_trx_line_id_tbl(i) ));
              END IF;

              SELECT sum(nvl(ACCTD_AMOUNT_CR,0) - nvl(ACCTD_AMOUNT_DR,0))
                INTO l_func_curr_line_amt_tbl(i)
                FROM ar_distributions_all
               WHERE source_id = l_receivable_app_id_tbl(i)
                 AND source_table = 'RA'
                 AND source_type IN ('EDISC', 'UNEDISC')
                 AND ref_customer_trx_line_id = l_adj_trx_line_id_tbl(i)
                 AND org_id = l_org_id_tbl(i);

              IF (g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                'Debug: After Populating functional amount for Discount :'||to_char(l_func_curr_line_amt_tbl(i) ));
              END IF;

              ZX_AP_POPULATE_PKG.lookup_desc_meaning(
                         'ZX_TRL_TAXABLE_TRX_TYPE',
                         'DISC',
                         l_meaning,
                         l_description);
              l_disc_class_mng_tbl(i) := l_meaning;

              IF (g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                'Debug: After Populating class meaning for Discounts :'||to_char(l_disc_class_mng_tbl(i) ));
              END IF;

               BEGIN
               SELECT apply_date
                 INTO l_disc_apply_date_tbl(i)
                 FROM ar_receivable_applications_all
                WHERE cash_receipt_id = l_trx_id_tbl(i)
                  AND status ='APP'
                  AND applied_customer_trx_id = l_adj_trx_id_tbl(i)
                  AND org_id = l_org_id_tbl(i) ;

                IF (g_level_statement>= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                   'Debug: After Populating apply date for discount :'||l_disc_apply_date_tbl(i));
                END IF;
                EXCEPTION
                   WHEN OTHERS THEN
                      l_disc_apply_date_tbl(i) := NULL;
                      IF (g_level_statement>= g_current_runtime_level ) THEN
                          FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                         'Debug: In Exception setting Apply date to NULL');
                      END IF;
                END;
          ELSE
                SELECT sum(nvl(ACCTD_AMOUNT,0))
                  INTO l_func_curr_line_amt_tbl(i)
                  FROM ra_cust_trx_line_gl_dist_all
                 WHERE customer_trx_id = l_trx_id_tbl(i)
                   AND customer_trx_line_id = l_trx_line_id_tbl(i)
                   AND org_id = l_org_id_tbl(i);

              IF (g_level_statement>= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                 'Debug: Populating functional amount for Transactions :'||to_char(l_func_curr_line_amt_tbl(i) ));
              END IF;
          END IF;

          EXCEPTION
          WHEN OTHERS THEN
              IF (g_level_statement>= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                  'Error in fetching data from ra_cust_trx_line_gl_dist_all for functional amount. Error Message : '
                   ||substrb(SQLERRM,1,120) );
              END IF;
          END;


          -- Changed code as per Amit's new document  --

         IF l_shipping_tp_name_tbl(i) = l_billing_tp_name_tbl(i) THEN
            IF l_ship_to_site_tax_reg_num_tbl(i) is not null THEN
               IF SubStr(l_ship_to_site_tax_reg_num_tbl(i),1,2) IN ('AT','BE','BG','CY','CZ','DK','EE','FI',
                                                             'FR','DE','GR','HU','IE','IT', 'LV','LT','LU',
                                                       'MT','NL','PL','PT','RO','SK','SI','ES','SE','GB')
               THEN
                  l_country_code_reg_num_tbl(i) := SubStr(l_ship_to_site_tax_reg_num_tbl(i),1,2);
                  l_tax_reg_num_tbl(i) := SubStr(l_ship_to_site_tax_reg_num_tbl(i),3);
               ELSE -- no country at ship to site reg --- print always from site reported paramater
                  /*IF SubStr(l_bill_to_site_tax_reg_num_tbl(i),1,2) IN ('AT','BE','BG','CY','CZ','DK','EE','FI',
                                                             'FR','DE','GR','HU','IE','IT', 'LV','LT','LU',
                                                       'MT','NL','PL','PT','RO','SK','SI','ES','SE','GB') THEN

                      l_country_code_reg_num_tbl(i) := SubStr(l_bill_to_site_tax_reg_num_tbl(i),1,2);*/
                  --ELSE
                      l_country_code_reg_num_tbl(i) :=  l_country_code_tbl(i);
                  --END IF;

                      l_tax_reg_num_tbl(i) := l_ship_to_site_tax_reg_num_tbl(i);

               END IF;
              -- No ship to reg num
            ELSIF  l_bill_to_site_tax_reg_num_tbl(i) is not null THEN
               IF SubStr(l_bill_to_site_tax_reg_num_tbl(i),1,2) IN ('AT','BE','BG','CY','CZ','DK','EE','FI',
                                                             'FR','DE','GR','HU','IE','IT', 'LV','LT','LU',
                                                       'MT','NL','PL','PT','RO','SK','SI','ES','SE','GB')
               THEN
                  l_country_code_reg_num_tbl(i) := SubStr(l_bill_to_site_tax_reg_num_tbl(i),1,2);
                  l_tax_reg_num_tbl(i) := SubStr(l_bill_to_site_tax_reg_num_tbl(i),3);
               ELSE
                  l_country_code_reg_num_tbl(i) :=  l_country_code_tbl(i);
                  l_tax_reg_num_tbl(i) := l_bill_to_site_tax_reg_num_tbl(i);
               END IF;
                  --l_tax_reg_num_tbl(i) := l_bill_to_site_tax_reg_num_tbl(i);
            END IF; -- End ship reg num check --
        ELSE  -- shp to pty <> bil to pty --
            IF l_bill_to_site_tax_reg_num_tbl(i) is not null THEN
               IF SubStr(l_bill_to_site_tax_reg_num_tbl(i),1,2) IN ('AT','BE','BG','CY','CZ','DK','EE','FI',
                                                             'FR','DE','GR','HU','IE','IT', 'LV','LT','LU',
                                                       'MT','NL','PL','PT','RO','SK','SI','ES','SE','GB')
               THEN
                  l_country_code_reg_num_tbl(i) := SubStr(l_bill_to_site_tax_reg_num_tbl(i),1,2);
                  l_tax_reg_num_tbl(i) := SubStr(l_bill_to_site_tax_reg_num_tbl(i),3);
               ELSE
                  l_country_code_reg_num_tbl(i) :=  l_country_code_tbl(i);
                  l_tax_reg_num_tbl(i) := l_bill_to_site_tax_reg_num_tbl(i);
               END IF;
            ELSE
                l_country_code_reg_num_tbl(i) :=  l_country_code_tbl(i);
            END IF;
        END IF; -- Party check --

            -- get reg num from bill to party --
            IF l_ship_to_site_tax_reg_num_tbl(i) is null AND l_bill_to_site_tax_reg_num_tbl(i) is null
            THEN
               IF l_bill_to_tax_reg_num_tbl(i) IS NOT NULL
               THEN
                  IF substr(l_bill_to_tax_reg_num_tbl(i),1,2) IN ('AT','BE','BG','CY','CZ','DK','EE','FI',
                                                             'FR','DE','GR','HU','IE','IT', 'LV','LT','LU',
                                                       'MT','NL','PL','PT','RO','SK','SI','ES','SE','GB')
                  THEN
                     l_tax_reg_num_tbl(i) := SubStr(l_bill_to_tax_reg_num_tbl(i),3);
                  ELSE
                     l_tax_reg_num_tbl(i) := l_bill_to_tax_reg_num_tbl(i);
                  END IF;
               END IF;
            END IF;

/*
          --Code for populating country code
          IF ( g_level_statement>= g_current_runtime_level ) THEN
          		   FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
          					      'Debug: Populating country code from tax reg num' );
          END IF;

        IF l_ship_to_site_tax_reg_num_tbl(i) is not null THEN
          IF SubStr(l_ship_to_site_tax_reg_num_tbl(i),1,2) IN ('AT','BE','BG','CY','CZ','DK','EE','FI',
                                                             'FR','DE','GR','HU','IE','IT', 'LV','LT','LU',
                                                       'MT','NL','PL','PT','RO','SK','SI','ES','SE','GB')
          THEN
               IF l_shipping_tp_name_tbl(i) = l_billing_tp_name_tbl(i) THEN
                  l_country_code_reg_num_tbl(i) := SubStr(l_ship_to_site_tax_reg_num_tbl(i),1,2);
               ELSE
                  IF SubStr(l_bill_to_site_tax_reg_num_tbl(i),1,2) IN ('AT','BE','BG','CY','CZ','DK','EE','FI',
                                                             'FR','DE','GR','HU','IE','IT', 'LV','LT','LU',
                                                       'MT','NL','PL','PT','RO','SK','SI','ES','SE','GB') THEN
                      l_country_code_reg_num_tbl(i) := SubStr(l_bill_to_site_tax_reg_num_tbl(i),1,2);
                  END IF;
               END IF;
            ELSE

                 IF SubStr(l_bill_to_site_tax_reg_num_tbl(i),1,2) IN ('AT','BE','BG','CY','CZ','DK','EE','FI',
                                                             'FR','DE','GR','HU','IE','IT', 'LV','LT','LU',
                                                       'MT','NL','PL','PT','RO','SK','SI','ES','SE','GB') THEN

                      l_country_code_reg_num_tbl(i) := SubStr(l_bill_to_site_tax_reg_num_tbl(i),1,2);
                ELSE
                      l_country_code_reg_num_tbl(i) :=  l_country_code_tbl(i);
                END IF;
            END IF;
          ELSIF  l_bill_to_site_tax_reg_num_tbl(i) is not null THEN
               IF SubStr(l_bill_to_site_tax_reg_num_tbl(i),1,2) IN ('AT','BE','BG','CY','CZ','DK','EE','FI',
                                                             'FR','DE','GR','HU','IE','IT', 'LV','LT','LU',
                                                       'MT','NL','PL','PT','RO','SK','SI','ES','SE','GB')
               THEN
               l_country_code_reg_num_tbl(i) := SubStr(l_bill_to_site_tax_reg_num_tbl(i),1,2);
              ELSE
                 l_country_code_reg_num_tbl(i) :=  l_country_code_tbl(i);
              END IF;
          ELSE */  -- New comments  --
             /*ELSIF substr(l_bill_to_tax_reg_num_tbl(i),1,2) IN ('AT','BE','BG','CY','CZ','DK','EE','FI',
                                                             'FR','DE','GR','HU','IE','IT', 'LV','LT','LU',
                                                       'MT','NL','PL','PT','RO','SK','SI','ES','SE','GB')
          THEN
               l_country_code_reg_num_tbl(i) := SubStr(l_bill_to_tax_reg_num_tbl(i),1,2);
          ELSE */
      --         l_country_code_reg_num_tbl(i) := l_country_code_tbl(i);
       --   END IF;

       /*      BEGIN
            SELECT rep_code.reporting_code_char_value
              INTO l_country_code_reg_num_tbl(i)
	            FROM zx_reporting_types_b rep_type,
	                 zx_reporting_codes_b rep_code
	           WHERE rep_type.reporting_type_id = rep_code.reporting_type_id
	             AND rep_type.reporting_type_code = 'MEMBER STATE'
               AND rep_code.reporting_code_char_value
                       = (SubStr(Nvl(Nvl(l_ship_to_site_tax_reg_num_tbl(i),
                                         l_bill_to_site_tax_reg_num_tbl(i)),
                                     l_bill_to_tax_reg_num_tbl(i)),1,2));
          EXCEPTION
            WHEN OTHERS THEN
              IF (g_level_statement>= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                  'Error in comparing the country code from the reg num. Error Message : '
                   ||substrb(SQLERRM,1,120) );
              END IF;
          END;
         */
        /*  IF l_ship_to_site_tax_reg_num_tbl(i) IS NOT NULL THEN
             IF l_shipping_tp_name_tbl(i) = l_billing_tp_name_tbl(i) THEN
                IF SubStr(l_ship_to_site_tax_reg_num_tbl(i),1,2) IN ('AT','BE','BG','CY','CZ','DK','EE','FI',
                                                             'FR','DE','GR','HU','IE','IT', 'LV','LT','LU',
                                                       'MT','NL','PL','PT','RO','SK','SI','ES','SE','GB')
                THEN
                  l_tax_reg_num_tbl(i) := SubStr(l_ship_to_site_tax_reg_num_tbl(i),3);
                ELSE
                  l_tax_reg_num_tbl(i) := l_ship_to_site_tax_reg_num_tbl(i);
                END IF;
             ELSE
                IF SubStr(l_bill_to_site_tax_reg_num_tbl(i),1,2) IN ('AT','BE','BG','CY','CZ','DK','EE','FI',
                                                             'FR','DE','GR','HU','IE','IT', 'LV','LT','LU',
                                                       'MT','NL','PL','PT','RO','SK','SI','ES','SE','GB')
                THEN
                  l_tax_reg_num_tbl(i) := SubStr(l_bill_to_site_tax_reg_num_tbl(i),3);
                ELSE
                  l_tax_reg_num_tbl(i) := l_bill_to_site_tax_reg_num_tbl(i);
                END IF;
             END IF;

            ELSIF l_bill_to_site_tax_reg_num_tbl(i) IS NOT NULL THEN
             IF SubStr(l_bill_to_site_tax_reg_num_tbl(i),1,2) IN ('AT','BE','BG','CY','CZ','DK','EE','FI',
                                                             'FR','DE','GR','HU','IE','IT', 'LV','LT','LU',
                                                       'MT','NL','PL','PT','RO','SK','SI','ES','SE','GB')
             THEN
               l_tax_reg_num_tbl(i) := SubStr(l_bill_to_site_tax_reg_num_tbl(i),3);
             ELSE
               l_tax_reg_num_tbl(i) := l_bill_to_site_tax_reg_num_tbl(i);
             END IF;

          ELSIF l_bill_to_tax_reg_num_tbl(i) IS NOT NULL THEN
             IF substr(l_bill_to_tax_reg_num_tbl(i),1,2) IN ('AT','BE','BG','CY','CZ','DK','EE','FI',
                                                             'FR','DE','GR','HU','IE','IT', 'LV','LT','LU',
                                                       'MT','NL','PL','PT','RO','SK','SI','ES','SE','GB')
             THEN
                l_tax_reg_num_tbl(i) := SubStr(l_bill_to_tax_reg_num_tbl(i),3);
             ELSE
                l_tax_reg_num_tbl(i) := l_bill_to_tax_reg_num_tbl(i);
             END IF;
          END IF; */

/*            IF l_country_code_reg_num_tbl(i) IS NOT NULL THEN
               l_tax_reg_num_tbl(i) := SubStr(Nvl(Nvl(l_ship_to_site_tax_reg_num_tbl(i),
                                                      l_bill_to_site_tax_reg_num_tbl(i)),
                                              l_bill_to_tax_reg_num_tbl(i)),3);
            END IF; */
      ELSE
             IF ( g_level_statement>= g_current_runtime_level ) THEN
          		   FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
          					      'Debug: Not repopulating country code' );
             END IF;


        IF l_event_class_code_tbl(i) <> 'ADJ' THEN
         l_func_curr_line_amt_tbl(i) := 0;
        END IF;
           l_tax_reg_num_tbl(i) := l_tax_reg_num_tbl(i-1);
           l_hq_estb_reg_num_tbl(i) := l_hq_estb_reg_num_tbl(i-1);
           l_country_code_reg_num_tbl(i) := l_country_code_reg_num_tbl(i-1);
       --  l_country_code_tbl(i) := l_country_code_tbl(i-1);


      END IF;
    END LOOP;

      IF ( g_level_statement>= g_current_runtime_level ) THEN
  		   FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
  					      ' Inserting Data into ZX_REP_TRX_JX_EXT_T ' );
  	  END IF;

         FORALL i in nvl(l_detail_tax_line_id_tbl.first,1)..nvl(l_detail_tax_line_id_tbl.last,0)
	   INSERT INTO ZX_REP_TRX_JX_EXT_T
	               (detail_tax_line_ext_id,
		              detail_tax_line_id,
                  attribute1, --County_code
                  attribute2, --Reporting Code Name
                  attribute10, --Reporting Code
                  attribute3, --Adjusted doc GL Date
                  attribute4, --Adjusted doc Tax date
                  attribute5, --Out of period adjustments
                  attribute6, --Tax reg num
                  attribute7,  -- adjusted doc trx type
                  attribute8,   -- adjustment hq estb reg num
                  attribute9,   -- Apply date for discounts
                  attribute11, -- Disc trx class
		              numeric1,   --Functional currency line amount
		              created_by,
		              creation_date,
		              last_updated_by,
		              last_update_date,
		              last_update_login,
                  request_id)
	        VALUES (zx_rep_trx_jx_ext_t_s.nextval,
		              l_detail_tax_line_id_tbl(i),
                  l_country_code_reg_num_tbl(i),
                  l_reporting_code_tbl(i),
                  l_reporting_code_char_tbl(i),
                  l_adj_gl_date_tbl(i),
                  l_adj_tax_invoice_tbl(i),
                  l_out_of_period_adj_tbl(i),
                  l_tax_reg_num_tbl(i),
                  l_adj_trx_class_mng_tbl(i),
                  l_hq_estb_reg_num_tbl(i),
                  l_disc_apply_date_tbl(i),
                  l_disc_class_mng_tbl(i),
                  l_func_curr_line_amt_tbl(i),
		              fnd_global.user_id,
		              sysdate,
		              fnd_global.user_id,
		              sysdate,
		              fnd_global.login_id,
                  P_REQUEST_ID);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;


       DELETE FROM zx_rep_trx_detail_t dtl
        WHERE dtl.request_id = p_request_id
          AND NOT EXISTS ( SELECT 1
                             FROM zx_rep_trx_jx_ext_t ext
                            WHERE ext.detail_tax_line_id = dtl.detail_tax_line_id);


  IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'After deleting data from zx_rep_trx_detail_t ' ||to_char(SQL%ROWCOUNT));
	END IF;
 END IF; -- report_name
 --End Bug 9031051
 IF P_REPORT_NAME = 'ARXSTR' THEN

    BEGIN
       SELECT  detail_tax_line_id,
               event_class_mapping_id,
               trx_id,
               trx_line_id,
               trx_level_type,
               place_of_supply_type_code,
               ship_to_location_id,
               ship_from_location_id,
               bill_to_location_id,
               bill_from_location_id,
               poa_location_id,
               poo_location_id,
               def_place_of_supply_type_code
       BULK COLLECT INTO  l_detail_tax_line_id_tbl,
                          l_event_class_mapping_id_tbl,
                          l_trx_id_tbl,
                          l_trx_line_id_tbl,
                          l_trx_level_type_tbl,
                          l_pos_type_code_tbl,
                          l_ship_to_location_id_tbl,
                          l_ship_from_location_id_tbl,
                          l_bill_to_location_id_tbl,
                          l_bill_from_location_id_tbl,
                          l_poa_location_id_tbl,
                          l_poo_location_id_tbl,
                          l_def_pos_type_code_tbl
       FROM  zx_rep_trx_detail_t itf
       WHERE  itf.request_id = P_REQUEST_ID;
    EXCEPTION
       WHEN OTHERS THEN
          null;
/*
          IF PG_DEBUG = 'Y' THEN
             l_err_msg := substrb(SQLERRM,1,120);
             arp_standard.debug('ZX_XX_EXTRACT_PKG.us_sales_tax_rep.'|| P_REPORT_NAME ||':'||l_err_msg);
          END IF;
*/
    END;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
	END IF;

    FOR i in 1..l_trx_id_tbl.last LOOP

       l_place_of_supply := nvl(l_pos_type_code_tbl(i),nvl(l_def_pos_type_code_tbl(i),'SHIP_TO'));
       IF l_place_of_supply = 'SHIP_TO' THEN
          l_location_type_tbl(1):= 'SHIP_TO';
          l_location_id_tbl(1):= l_ship_to_location_id_tbl(i);
       ELSIF l_place_of_supply = 'SHIP_FROM' THEN
          l_location_type_tbl(1):= 'SHIP_FROM';
          l_location_id_tbl(1):= l_ship_from_location_id_tbl(i);
       ELSIF l_place_of_supply = 'BILL_TO' THEN
          l_location_type_tbl(1):= 'BILL_TO';
          l_location_id_tbl(1):= l_bill_to_location_id_tbl(i);
       ELSIF l_place_of_supply = 'BILL_FROM' THEN
          l_location_type_tbl(1):= 'BILL_FROM';
          l_location_id_tbl(1):= l_bill_from_location_id_tbl(i);
       ELSIF l_place_of_supply = 'POA' THEN
          l_location_type_tbl(1):= 'POA';
          l_location_id_tbl(1):= l_poa_location_id_tbl(i);
       ELSIF l_place_of_supply = 'POO' THEN
          l_location_type_tbl(1):= 'POO';
          l_location_id_tbl(1):= l_poo_location_id_tbl(i);
       END IF;


/* Check existence of input combination in table ZX_GLOBAL_STRUCTURES_PKG.location_hash_tbl */

       RETRIEVE_GEO_VALUE(l_event_class_mapping_id_tbl(i),
                          l_trx_id_tbl(i),
                          l_trx_line_id_tbl(i),
                          l_trx_level_type_tbl(i),
                          l_location_type_tbl(1),
                          l_location_id_tbl(1),
                          'STATE',
                          l_state_tbl(i),
                          l_geo_val_found);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'l_geo_val_found : '||arp_trx_util.boolean_to_varchar2(l_geo_val_found));
	END IF;

       IF l_geo_val_found THEN
          null;
       ELSE
          IF prev_event_class_mapping_id <> l_event_class_mapping_id_tbl(i) THEN
             BEGIN
                SELECT
                   zxevntclsmap.event_class_mapping_id,
                   zxevntclsmap.ship_to_party_type,
                   zxevntclsmap.ship_from_party_type,
                   zxevntclsmap.poa_party_type,
                   zxevntclsmap.poo_party_type,
                   zxevntclsmap.bill_to_party_type,
                   zxevntclsmap.bill_from_party_type
                INTO
                   prev_event_class_mapping_id,
                   zx_valid_init_params_pkg.source_rec.ship_to_party_type,
                   zx_valid_init_params_pkg.source_rec.ship_from_party_type,
                   zx_valid_init_params_pkg.source_rec.poa_party_type,
                   zx_valid_init_params_pkg.source_rec.poo_party_type,
                   zx_valid_init_params_pkg.source_rec.bill_to_party_type,
                   zx_valid_init_params_pkg.source_rec.bill_from_party_type
                FROM  ZX_EVNT_CLS_MAPPINGS zxevntclsmap
                WHERE zxevntclsmap.event_class_mapping_id = l_event_class_mapping_id_tbl(i);

		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
						      'Rows fetched from ZX_EVNT_CLS_MAPPINGS : '||to_char(SQL%ROWCOUNT) );
		END IF;
             EXCEPTION
                WHEN OTHERS THEN
                   null;
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
			'Error Message ZX_EVNT_CLS_MAPPINGS : '||substrb(SQLERRM,1,120) );
		END IF;
/*
                   IF PG_DEBUG = 'Y' THEN
                      l_err_msg := substrb(SQLERRM,1,120);
                      arp_standard.debug('ZX_XX_EXTRACT_PKG.us_sales_tax_rep.'|| P_REPORT_NAME ||':'||l_err_msg);
                   END IF;
*/
             END;
          END IF;

          BEGIN

		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
						      'Before call to ZX_TCM_GEO_JUR_PKG.populate_loc_geography_info ');
		END IF;

             ZX_TCM_GEO_JUR_PKG.populate_loc_geography_info
                (l_event_class_mapping_id_tbl(i),
                 l_trx_id_tbl(i),
                 l_trx_line_id_tbl(i),
                 l_trx_level_type_tbl(i),
                 l_location_type_tbl,
                 l_location_id_tbl,
                 x_return_status);
          EXCEPTION
             WHEN OTHERS THEN
                null;
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
			'Error Message : ZX_TCM_GEO_JUR_PKG.populate_loc_geography_info : '||substrb(SQLERRM,1,120) );
		END IF;
/*
                IF PG_DEBUG = 'Y' THEN
                   l_err_msg := substrb(SQLERRM,1,120);
                   arp_standard.debug('ZX_XX_EXTRACT_PKG.us_sales_tax_rep.'|| P_REPORT_NAME ||':'||l_err_msg);
                END IF;
*/
          END;
          RETRIEVE_GEO_VALUE(l_event_class_mapping_id_tbl(i),
                             l_trx_id_tbl(i),
                             l_trx_line_id_tbl(i),
                             l_trx_level_type_tbl(i),
                             l_location_type_tbl(1),
                             l_location_id_tbl(1),
                             'STATE',
                             l_state_tbl(i),
                             l_geo_val_found);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'Retrieved geo_value for STATE : '||l_state_tbl(i) ||' l_geo_val_found : '||arp_trx_util.boolean_to_varchar2(l_geo_val_found));
	END IF;

       END IF;
          RETRIEVE_GEO_VALUE(l_event_class_mapping_id_tbl(i),
                             l_trx_id_tbl(i),
                             l_trx_line_id_tbl(i),
                             l_trx_level_type_tbl(i),
                             l_location_type_tbl(1),
                             l_location_id_tbl(1),
                             'COUNTY',
                             l_county_tbl(i),
                             l_geo_val_found);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'Retrieved geo_value for COUNTY : '||l_county_tbl(i) ||' l_geo_val_found : '||arp_trx_util.boolean_to_varchar2(l_geo_val_found));
	END IF;

          RETRIEVE_GEO_VALUE(l_event_class_mapping_id_tbl(i),
                             l_trx_id_tbl(i),
                             l_trx_line_id_tbl(i),
                             l_trx_level_type_tbl(i),
                             l_location_type_tbl(1),
                             l_location_id_tbl(1),
                             'CITY',
                             l_city_tbl(i),
                             l_geo_val_found);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'Retrieved geo_value for CITY : '||l_city_tbl(i) ||' l_geo_val_found : '||arp_trx_util.boolean_to_varchar2(l_geo_val_found));
	END IF;


    END LOOP;

         -- Insert lines into JX EXT Table with Calculated amount --

    FORALL i in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last

       INSERT INTO zx_rep_trx_jx_ext_t(detail_tax_line_ext_id,
                                       detail_tax_line_id,
                                       attribute1,
                                       attribute2,
                                       attribute3,
                                       created_by,
                                       creation_date,
                                       last_updated_by,
                                       last_update_date,
                                       last_update_login)
                               VALUES (zx_rep_trx_jx_ext_t_s.nextval,
                                       l_detail_tax_line_id_tbl(i),
                                       l_state_tbl(i),
                                       l_county_tbl(i),
                                       l_city_tbl(i),
                                       fnd_global.user_id,
                                       sysdate,
                                       fnd_global.user_id,
                                       sysdate,
                                       fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;

                -- Delete Unwanted lines from Detail ITF

       BEGIN
                DELETE from zx_rep_trx_detail_t itf
                 WHERE itf.request_id = p_request_id
                   AND NOT EXISTS ( SELECT 1
                                      FROM zx_rep_trx_jx_ext_t ext
                                     WHERE ext.detail_tax_line_id = itf.detail_tax_line_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'After deletion from zx_rep_trx_detail_t : '||to_char(SQL%ROWCOUNT) );
	END IF;

       EXCEPTION
          WHEN OTHERS THEN
             null;
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
			'Error Message for report '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;
/*
             IF PG_DEBUG = 'Y' THEN
                l_err_msg := substrb(SQLERRM,1,120);
                arp_standard.debug('ZX_XX_EXTRACT_PKG.populate_us_sales_tax_rep_ext.'||p_report_name || '.'||l_err_msg);
             END IF;
*/
       END;
 END IF;  -- End of P_REPORT_NAME = ..

   --Bug 5251425 : To Populate General Ledger Activity(C_GL_ACTIVITY_DISP)
   --and C_BAL_SEGMENT_PROMPT into ZX_REP_TRX_JX_EXT_T.numeric1
   --and ZX_REP_TRX_JX_EXT_T.attribute1 respectively ..

      IF ( p_report_name = 'ZXXVATRN' ) THEN
	-- get details for C_GL_ACTIVITY_DISP
	BEGIN
            /*	select  gl.set_of_books_id
		into l_set_of_books_id
		from gl_sets_of_books gl, ar_system_parameters ar
		where gl.set_of_books_id = ar.set_of_books_id;
            */

         -- Introduced for the bug#7638536 ---
            IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                'P_POSTING_STATUS: '||P_POSTING_STATUS);
            END IF;


           IF P_POSTING_STATUS  = 'POSTED' THEN
              DELETE FROM zx_rep_actg_ext_t
              WHERE NVL(gl_transfer_flag,'N') <>'Y'
              AND request_id = p_request_id;

              DELETE FROM zx_rep_trx_detail_t dtl
              WHERE NOT EXISTS (SELECT 1 FROM zx_rep_actg_ext_t act
                             WHERE act.detail_tax_line_id = dtl.detail_tax_line_id)
              AND dtl.request_id = p_request_id;
           END IF;

            IF P_POSTING_STATUS  = 'UNPOSTED' THEN
              DELETE FROM zx_rep_actg_ext_t
              WHERE NVL(gl_transfer_flag,'N') = 'Y'
              AND request_id = p_request_id;

              DELETE FROM zx_rep_trx_detail_t dtl
              WHERE NOT EXISTS (SELECT 1 FROM zx_rep_actg_ext_t act
                             WHERE act.detail_tax_line_id = dtl.detail_tax_line_id)
              AND dtl.request_id = p_request_id;
           END IF;



            IF ( g_level_statement>= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                'P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_LOW : '||P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_LOW);
                FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                'P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_HIGH : '||P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_HIGH);
           END IF;
		select gl.period_name
		into   l_period_from
		from   gl_period_statuses gl
               --, ar_system_parameters ar
		where  gl.start_date = P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_LOW
		and    gl.set_of_books_id = P_TRL_GLOBAL_VARIABLES_REC.LEDGER_ID
                --l_set_of_books_id
		and    gl.application_id = 222
		and    rownum = 1;

		select gl.period_name
		into   l_period_to
		from   gl_period_statuses gl
                --, ar_system_parameters ar
		where  gl.end_date >= P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_HIGH
		and    gl.set_of_books_id = P_TRL_GLOBAL_VARIABLES_REC.LEDGER_ID
                ---l_set_of_books_id
		and    gl.application_id = 222
		and    rownum = 1;

	  IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
		      'P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_HIGH : '||P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_HIGH);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
		      'P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_LOW : '||P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_LOW);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
				      'l_set_of_books_id : '||l_set_of_books_id);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
				      'l_period_from : '||l_period_from);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'l_period_to : '||l_period_to);
	  END IF;
	EXCEPTION WHEN OTHERS THEN
		NULL ;
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
			'Error Message for report '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;
	END ;


	DECLARE
		l_appcol_name                  varchar2(1000);
		l_seg_name                     varchar2(1000);
		l_prompt                       varchar2(1000) := '';
		l_value_set_name               varchar2(1000);
		L_SEG_NUM			NUMBER;
		L_CHART_OF_ACCOUNTS_ID		apps.gl_sets_of_books.chart_of_accounts_id%type;
		L_BALANCING_SEGMENT		varchar2(100);
		l_bool				boolean;
	BEGIN
		-- get details C_BAL_SEGMENT_PROMPT
		select to_char(chart_of_accounts_id)
		into l_CHART_OF_ACCOUNTS_ID
                from gl_ledgers where ledger_id = P_TRL_GLOBAL_VARIABLES_REC.LEDGER_ID;
	--	from   gl_sets_of_books gl, ar_system_parameters ar
	--	where  gl.set_of_books_id = ar.set_of_books_id;

             IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
			  'Before calling fa_rx_flex_pkg.flex_sql to get balancing segment ' );
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
		         'l_CHART_OF_ACCOUNTS_ID : '||l_CHART_OF_ACCOUNTS_ID);
             END IF;

		l_balancing_segment := fa_rx_flex_pkg.flex_sql
				(
					p_application_id =>101,
					p_id_flex_code => 'GL#',
					p_id_flex_num => l_CHART_OF_ACCOUNTS_ID,
					p_table_alias => '',
					p_mode => 'SELECT',
					p_qualifier => 'GL_BALANCING'
				);

		SELECT to_number(SubStr(l_balancing_segment,8)) INTO L_SEG_NUM  FROM dual;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
		     'l_balancing_segment : '||l_balancing_segment);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
		      'L_SEG_NUM : '||L_SEG_NUM);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
		      'Before calling fnd_flex_apis.get_segment_info to get the Balancing Seg prompt' );
	END IF;

		l_bool := apps.fnd_flex_apis.get_segment_info(
			x_application_id =>101,
			x_id_flex_code =>'GL#',
			x_id_flex_num =>l_CHART_OF_ACCOUNTS_ID,
			x_seg_num => L_SEG_NUM,
			x_appcol_name => l_appcol_name ,
			x_seg_name => l_seg_name ,
			x_prompt => l_prompt ,
			x_value_set_name => l_value_set_name
		);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
		      'l_prompt : '||l_prompt);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
		      'l_seg_name : '||l_seg_name);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
		      'l_value_set_name : '||l_value_set_name);
	END IF;

		SELECT
			det.detail_tax_line_id,
			det.trx_id,
			act.ACTG_LINE_CCID,
			det.ledger_id
		BULK COLLECT INTO
			l_detail_tax_line_id_tbl,
			l_trx_id_tbl,
			L_CCID_TBL,
			L_LEDGER_ID_TBL
		FROM
			zx_rep_trx_detail_t det ,
			ZX_REP_ACTG_EXT_T act
		WHERE  det.request_id = p_request_id
		AND det.DETAIL_TAX_LINE_ID = ACT.DETAIL_TAX_LINE_ID(+);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
		      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
			'Before calling ARP_STANDARD.gl_activity to get the gl_activity value.' );
	END IF;

		FOR i IN 1..nvl(l_detail_tax_line_id_tbl.COUNT,0)
		LOOP


             IF t_gl_activity_tbl.EXISTS(L_CCID_TBL(i)) THEN
                null;
             ELSE
                     t_gl_activity_tbl(L_CCID_TBL(i)) := null;
             END IF;

             IF t_gl_activity_tbl(L_CCID_TBL(i)) is NULL THEN

			ARP_STANDARD.gl_activity(
			l_period_from,
			l_period_to,
			L_CCID_TBL(i),
			L_LEDGER_ID_TBL(i),
			l_period_net_dr_tbl(i),
			l_period_net_cr_tbl(i));

		t_gl_activity_tbl(L_CCID_TBL(i)) := l_period_net_dr_tbl(i) - l_period_net_cr_tbl(i);
            IF ( g_level_statement>= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
                 'l_period_net_dr_tbl : '||to_char(l_period_net_dr_tbl(i))||'-'||to_char(l_period_net_cr_tbl(i)));
            END IF;


        	l_gl_activity_tbl(i) := t_gl_activity_tbl(L_CCID_TBL(i));
            ELSE
                l_gl_activity_tbl(i) := 0;
           END IF;
			l_bal_seg_prompt_tbl(i) := l_prompt ;
	END LOOP ;

		FORALL i in 1 .. nvl(l_detail_tax_line_id_tbl.last, 0)
			INSERT INTO ZX_REP_TRX_JX_EXT_T
			(
				detail_tax_line_ext_id,
				detail_tax_line_id,
				numeric1,
				attribute1,
				created_by,
				creation_date,
				last_updated_by,
				last_update_date,
				last_update_login
			)
			VALUES
			(
				zx_rep_trx_jx_ext_t_s.nextval,
				l_detail_tax_line_id_tbl(i),
				l_gl_activity_tbl(i),
				l_bal_seg_prompt_tbl(i),
				fnd_global.user_id,
				sysdate,
				fnd_global.user_id,
				sysdate,
				fnd_global.login_id
			);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;

	EXCEPTION WHEN OTHERS THEN
--		NULL ;
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
			'Error Message for report '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;
	END;

 END IF ;   -- ZXXVATRN  --


--Bug 5251425 : To Derive Logic for C_AMOUNT_RECEIVED and C_TAX_AMOUNT_RECEIVED
 IF ( p_report_name = 'ZXXCDE' ) THEN

	SELECT distinct dtl.detail_tax_line_id,
	       dtl.trx_id ,
	       dtl.internal_organization_id
	BULK COLLECT INTO
		l_detail_tax_line_id_tbl,
		l_trx_id_tbl,
		l_org_id_tbl
	FROM zx_rep_trx_detail_t dtl ,
	     ar_receivable_applications_all cash
 WHERE dtl.request_id = p_request_id
	 AND dtl.trx_id = cash.applied_customer_trx_id
	 AND cash.status = 'APP'
   AND cash.application_type = 'CASH';


	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'Count fetched : '||to_char(nvl(l_detail_tax_line_id_tbl.count,0)) );

		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'Before Call to GET_RECEIVED_AMOUNTS procedure ' );
	END IF;


		GET_RECEIVED_AMOUNTS
		(
			l_detail_tax_line_id_tbl,
			l_trx_id_tbl	        ,
			l_org_id_tbl		,
			l_amount_received_tbl	,
			l_tax_received_tbl
		);

	 FORALL i in 1 .. nvl(l_detail_tax_line_id_tbl.last, 0)
	   INSERT INTO ZX_REP_TRX_JX_EXT_T
	       (detail_tax_line_ext_id,
		detail_tax_line_id,
		numeric1, --C_TAX_AMOUNT_RECEIVED
		numeric2,--C_AMOUNT_RECEIVED
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login)
	   VALUES (zx_rep_trx_jx_ext_t_s.nextval,
		l_detail_tax_line_id_tbl(i),
		l_tax_received_tbl(i),
		l_amount_received_tbl(i),
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.login_id);

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'After insertion into zx_rep_trx_jx_ext_t ');
	END IF;

  DELETE FROM zx_rep_trx_detail_t dtl
        WHERE dtl.request_id = p_request_id
          AND NOT EXISTS ( SELECT 1
                             FROM zx_rep_trx_jx_ext_t ext
                            WHERE ext.detail_tax_line_id = dtl.detail_tax_line_id);

  IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
					      'After deleting data from zx_rep_trx_detail_t ' ||to_char(SQL%ROWCOUNT));
	END IF;

 END IF ;

 EXCEPTION
    WHEN OTHERS THEN
--       null;
		IF ( g_level_statement>= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR',
			'Error Message for report '||p_report_name ||' : '||substrb(SQLERRM,1,120) );
		END IF;
/*
       IF PG_DEBUG = 'Y' THEN
          l_err_msg := substrb(SQLERRM,1,120);
          arp_standard.debug('ZX_XX_EXTRACT_PKG.populate_us_sales_tax_rep_ext.'||p_report_name || '.'||l_err_msg);
       END IF;
*/
	IF (g_level_procedure >= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR.BEGIN',
					      'ZX_CORE_REP_EXTRACT_PKG.POPULATE_CORE_AR(-)');
	END IF;

 END POPULATE_CORE_AR;

END ZX_CORE_REP_EXTRACT_PKG;

/
