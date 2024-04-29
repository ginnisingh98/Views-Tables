--------------------------------------------------------
--  DDL for Package Body JG_ZZ_JOURNAL_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_JOURNAL_AP_PKG" 
-- $Header: jgzzjournalapb.pls 120.29.12010000.18 2009/12/21 18:20:03 spasupun ship $
AS

-- +======================================================================+
-- Name: GET_START_SEQUENCE
--
-- Description: This function is private to this package. It is called to
--              get the start_sequence_num for the report JEITAPPV and JEITAPSR
--              transactions.
--
-- Parameters:   None
-- +======================================================================+

FUNCTION get_start_sequence RETURN NUMBER IS
l_start_seq NUMBER;
l_period_start_date DATE;
BEGIN
      SELECT max(vrs.period_start_date)
      INTO l_period_start_date
      FROM jg_zz_vat_final_reports vfr,
           jg_zz_vat_rep_status vrs
      WHERE vfr.report_name = p_report_name
      AND   vfr.vat_register_id = p_vat_register_id
      AND   vrs.reporting_status_id = vfr.reporting_status_id;

      SELECT start_sequence_num
      INTO l_start_seq
      FROM jg_zz_vat_final_reports vfr,
           jg_zz_vat_rep_status vrs
      WHERE vfr.report_name = p_report_name
      AND   vfr.vat_register_id = p_vat_register_id
      AND   vrs.reporting_status_id = vfr.reporting_status_id
      AND   vrs.period_start_date = l_period_start_date;

      RETURN l_start_seq;
EXCEPTION
   WHEN others THEN
     RETURN 0;
END get_start_sequence;


-- +======================================================================+
-- Name: BEFORE_REPORT
--
-- Description: This function is called as a before report trigger by the
--              data template. It populates the data in the global temporary table
--              and creates the dynamic where clause for the data template
--              queries(lexical reference).
--
-- Parameters:   None
-- +======================================================================+
--
  FUNCTION beforeReport RETURN BOOLEAN
  IS
    l_address_line_1                VARCHAR2 (240);
    l_address_line_2                VARCHAR2 (240);
    l_address_line_3                VARCHAR2 (240);
    l_address_line_4                VARCHAR2 (240);
    l_city                          VARCHAR2 (60);
    l_company_name                  VARCHAR2 (240);
    l_contact_name                  VARCHAR2 (360);
    l_country                       VARCHAR2 (60);
    l_func_curr                     VARCHAR2 (30);
    l_legal_entity_id               NUMBER;
    l_legal_entity_name             VARCHAR2 (240);
    l_period_end_date               DATE;
    l_period_start_date             DATE;
	l_to_period_end_date            DATE; -- Bug8267272
    l_to_period_start_date          DATE; -- Bug8267272
    l_phone_number                  VARCHAR2 (40);
    l_postal_code                   VARCHAR2 (60);
    -- Added for GLOB-006 ER
    l_province                      VARCHAR2(120);
    l_comm_num                      VARCHAR2(30);
    l_vat_reg_num                   VARCHAR2(50);
  -- end here
    l_registration_num              VARCHAR2 (30);
    l_reporting_status              VARCHAR2 (60);
	l_to_reporting_status           VARCHAR2 (60); -- Bug8267272
    l_tax_payer_id                  VARCHAR2 (60);
    l_tax_registration_num          VARCHAR2 (240);
	l_to_tax_registration_num       VARCHAR2 (240); -- Bug8267272
    l_tax_regime                    VARCHAR2(240);
    l_vat_register_name             VARCHAR2(240);
    l_start_seq                     NUMBER(15);


  BEGIN
      fnd_file.put_line(fnd_file.log,' ** Inside BeforeReport ** ');
      p_debug_flag := 'Y' ;
      g_precision :=0;

      IF P_REPORT_NAME IN ('JEITAPSR', 'JEITAPPV') THEN
          BEGIN
          fnd_file.put_line(fnd_file.log,'Fetching Register name...');
          SELECT register_name
          INTO   l_vat_register_name
          FROM   jg_zz_vat_registers_vl
          WHERE  vat_register_id = p_vat_register_id ;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_file.put_line(fnd_file.log,'Cannot derive VAT Register Name for Register ID:'||p_vat_register_id) ;
          l_rec_count := 0;
          RAISE ;
        END ;
      END IF ;
    IF p_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'**********************************************************');
      IF P_REPORT_NAME = 'JEITAPSR' THEN
        fnd_file.put_line(fnd_file.log,'              Italian Sales VAT Register                  ');
      ELSIF P_REPORT_NAME = 'JEITAPPV' THEN
        fnd_file.put_line(fnd_file.log,'             Italian Purchase VAT Register                ');
      ELSIF P_REPORT_NAME = 'JEBEDV08' THEN
        fnd_file.put_line(fnd_file.log,'             Belgian VAT Purchases Journal                ');
      ELSIF P_REPORT_NAME = 'JEESRVAR' THEN
        fnd_file.put_line(fnd_file.log,'          Spanish Inter-EU Invoices Journal Report        ');
      ELSIF P_REPORT_NAME = 'JEESRPVP' THEN
        fnd_file.put_line(fnd_file.log,'             Spanish Input VAT Journal Report             ');
      END IF;
        fnd_file.put_line(fnd_file.log,'**********************************************************');
      fnd_file.put_line(fnd_file.log,' ** Report Paramters ** ');
      fnd_file.put_line(fnd_file.log,'P_VAT_REP_ENTITY_ID          :'|| P_VAT_REP_ENTITY_ID          );
      fnd_file.put_line(fnd_file.log,'P_PERIOD                     :'|| P_PERIOD                     );
	  fnd_file.put_line(fnd_file.log,'P_PERIOD_TO                  :'|| P_PERIOD_TO                  ); -- Bug8267272
      fnd_file.put_line(fnd_file.log,'P_DOCUMENT_SEQUENCE_NAME_FROM:'|| P_DOCUMENT_SEQUENCE_NAME_FROM);
      fnd_file.put_line(fnd_file.log,'P_DOCUMENT_SEQUENCE_NAME_TO  :'|| P_DOCUMENT_SEQUENCE_NAME_TO  );
      fnd_file.put_line(fnd_file.log,'P_VENDOR_NAME_FROM           :'|| P_VENDOR_NAME_FROM           );
      fnd_file.put_line(fnd_file.log,'P_VENDOR_NAME_TO             :'|| P_VENDOR_NAME_TO             );
      fnd_file.put_line(fnd_file.log,'P_DETAIL_SUMMARY             :'|| P_DETAIL_SUMMARY             );
      fnd_file.put_line(fnd_file.log,'P_VAT_REGISTER_ID            :'|| P_VAT_REGISTER_ID            );
      fnd_file.put_line(fnd_file.log,'P_TAX_TYPE                   :'|| P_TAX_TYPE                   );
      fnd_file.put_line(fnd_file.log,'P_REGISTER_TYPE              :'|| P_REGISTER_TYPE              );
      fnd_file.put_line(fnd_file.log,'P_START_INV_SEQUENCE         :'|| P_START_INV_SEQUENCE         );
      fnd_file.put_line(fnd_file.log,'P_BALANCING_SEGMENT          :'|| P_BALANCING_SEGMENT          );
      fnd_file.put_line(fnd_file.log,'P_REPORT_NAME                :'|| P_REPORT_NAME                );
      fnd_file.put_line(fnd_file.log,' ');
    END IF ;

     fnd_file.put_line(fnd_file.log,'Before Report Trigger');
     jg_zz_common_pkg.funct_curr_legal(x_func_curr_code     => l_func_curr
                                    ,x_rep_entity_name      => l_legal_entity_name
                                    ,x_legal_entity_id      => l_legal_entity_id
                                    ,x_taxpayer_id          => l_tax_payer_id
                                    ,pn_vat_rep_entity_id   => p_vat_rep_entity_id
                                    ,pv_period_name         => p_period);
    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'l_func_curr         :'|| l_func_curr         );
      fnd_file.put_line(fnd_file.log,'l_legal_entity_name :'|| l_legal_entity_name );
      fnd_file.put_line(fnd_file.log,'l_legal_entity_id   :'|| l_legal_entity_id   );
      fnd_file.put_line(fnd_file.log,'l_tax_payer_id      :'|| l_tax_payer_id      );
      fnd_file.put_line(fnd_file.log,' ');
    END IF ;

    fnd_file.put_line(fnd_file.log,'Calling jg_zz_common_pkg.tax_registration');
    jg_zz_common_pkg.tax_registration(x_tax_registration    => l_tax_registration_num
                                    ,x_period_start_date    => l_period_start_date
                                    ,x_period_end_date      => l_period_end_date
                                    ,x_status               => l_reporting_status
                                    ,pn_vat_rep_entity_id   => p_vat_rep_entity_id
                                    ,pv_period_name         => p_period
                                    ,pv_source              => 'ALL');

	-- Bug8267272 Start Below code added to get end_date of TO_PERIOD
	IF nvl(P_REPORT_NAME,'ZZ') in('JEESRVAR','JEESRPVP') THEN

	fnd_file.put_line(fnd_file.log,'Getting TO_PERIOD_INFO');

	jg_zz_common_pkg.tax_registration(x_tax_registration    => l_to_tax_registration_num
                                    ,x_period_start_date    => l_to_period_start_date
                                    ,x_period_end_date      => l_to_period_end_date
                                    ,x_status               => l_to_reporting_status
                                    ,pn_vat_rep_entity_id   => p_vat_rep_entity_id
                                    ,pv_period_name         => p_period_to
                                    ,pv_source              => 'ALL');
	fnd_file.put_line(fnd_file.log,'To Period Start Date :'||l_to_period_start_date);
	fnd_file.put_line(fnd_file.log,'To Period End Date :'||l_to_period_end_date);
	END IF;
    -- Bug8267272 End

    fnd_file.put_line(fnd_file.log,'JG_ZZ_VAT_REP_UTILITY.get_period_status');
    IF P_REPORT_NAME = 'JEITAPSR' OR P_REPORT_NAME = 'JEITAPPV' THEN
        -- Get the Start Sequence Number for the Previous Finally Reported period for same report and vat register.
        l_start_seq := get_start_sequence;

	l_reporting_status := JG_ZZ_VAT_REP_UTILITY.get_period_status(pn_vat_reporting_entity_id => p_vat_rep_entity_id
                                                                ,pv_tax_calendar_period => p_period
                                                                ,pv_tax_calendar_year => null
                                                                ,pv_source => NULL
                                                                ,pv_report_name => p_report_name
                                                                ,pv_vat_register_id => p_vat_register_id);

        -- Insert the record into jg_zz_vat_trx_gt with Sequence and reporting mode info
        IF l_reporting_status = 'COPY' THEN
            SELECT last_start_sequence_num
            INTO l_start_seq
            FROM jg_zz_vat_final_reports vfr,
                 jg_zz_vat_rep_status vrs
            WHERE vfr.report_name = p_report_name
            AND   vfr.vat_register_id = p_vat_register_id
            AND   vrs.reporting_status_id = vfr.reporting_status_id
            AND   vrs.tax_calendar_period = p_period;
        END IF;

        INSERT INTO jg_zz_vat_trx_gt (jg_info_n1,
                                      jg_info_v1,
                                      jg_info_v30)
                              VALUES (l_start_seq,
                                      l_reporting_status,
                                      'SEQ');
    ELSE
        l_reporting_status := JG_ZZ_VAT_REP_UTILITY.get_period_status(pn_vat_reporting_entity_id => p_vat_rep_entity_id
                                                                ,pv_tax_calendar_period => p_period
                                                                ,pv_tax_calendar_year => null
                                                                ,pv_source => NULL
                                                                ,pv_report_name => p_report_name);
    END IF;

    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'l_tax_registration_num:'|| l_tax_registration_num  );
      fnd_file.put_line(fnd_file.log,'l_period_start_date   :'|| l_period_start_date     );
      fnd_file.put_line(fnd_file.log,'l_period_end_date     :'|| l_period_end_date       );
      fnd_file.put_line(fnd_file.log,'l_reporting_status    :'|| l_reporting_status      );
      fnd_file.put_line(fnd_file.log,' ');
    END IF ;
   fnd_file.put_line(fnd_file.log,'Calling jg_zz_common_pkg.company_detail');
   jg_zz_common_pkg.company_detail(x_company_name           => l_company_name
                                  ,x_registration_number    => l_registration_num
                                  ,x_country                => l_country
                                  ,x_address1               => l_address_line_1
                                  ,x_address2               => l_address_line_2
                                  ,x_address3               => l_address_line_3
                                  ,x_address4               => l_address_line_4
                                  ,x_city                   => l_city
                                  ,x_postal_code            => l_postal_code
                                  ,x_contact                => l_contact_name
                                  ,x_phone_number           => l_phone_number
                                  ,x_province               => l_province
                                  ,x_comm_number            => l_comm_num
                                  ,x_vat_reg_num            => l_vat_reg_num
                                  ,pn_legal_entity_id       => l_legal_entity_id
                                  ,p_vat_reporting_entity_id => P_VAT_REP_ENTITY_ID);

    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'l_company_name    :'|| l_company_name      );
      fnd_file.put_line(fnd_file.log,'l_registration_num:'|| l_registration_num  );
      fnd_file.put_line(fnd_file.log,'l_country         :'|| l_country           );
      fnd_file.put_line(fnd_file.log,'l_address_line_1  :'|| l_address_line_1    );
      fnd_file.put_line(fnd_file.log,'l_address_line_2  :'|| l_address_line_2    );
      fnd_file.put_line(fnd_file.log,'l_address_line_3  :'|| l_address_line_3    );
      fnd_file.put_line(fnd_file.log,'l_address_line_4  :'|| l_address_line_4    );
      fnd_file.put_line(fnd_file.log,'l_city            :'|| l_city              );
      fnd_file.put_line(fnd_file.log,'l_postal_code     :'|| l_postal_code       );
      fnd_file.put_line(fnd_file.log,'l_contact_name    :'|| l_contact_name      );
      fnd_file.put_line(fnd_file.log,'l_phone_number    :'|| l_phone_number      );
      fnd_file.put_line(fnd_file.log,' ');
    END IF ;

     /* Get Currency Precision */ --Bug:8201935

     	     BEGIN
     	       FND_FILE.PUT_LINE(FND_FILE.LOG,'Functional Currency Code :'||l_func_curr);

     	       SELECT  precision
     	       INTO  g_precision
     	       FROM    fnd_currencies
     	       WHERE   currency_code = l_func_curr;

     	       FND_FILE.PUT_LINE(FND_FILE.LOG,'Functional Currency Precision :'||g_precision);

     	       EXCEPTION
     	       WHEN OTHERS THEN
     	       FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in getting currency precision');
              END;

     IF P_REPORT_NAME = 'JEBEDV08' THEN
       fnd_file.put_line(fnd_file.log,'Calling JEBEDV08');
       jebedv08(p_vat_rep_entity_id           => p_vat_rep_entity_id
               ,p_period                      => p_period
               ,p_document_sequence_name_from => p_document_sequence_name_from
               ,p_document_sequence_name_to   => p_document_sequence_name_to
               ,p_vendor_name_from            => p_vendor_name_from
               ,p_vendor_name_to              => p_vendor_name_to
               ,p_detail_summary              => p_detail_summary
               ,x_err_msg                     => l_err_msg);
       fnd_file.put_line(fnd_file.log,'After Calling JEBEDV08');
      ELSIF P_REPORT_NAME = 'JEITAPSR' THEN
       fnd_file.put_line(fnd_file.log,'Calling JEITAPSR');
       jeitapsr(p_vat_rep_entity_id        => p_vat_rep_entity_id
                        ,p_period          => p_period
                        ,p_vat_register_id => p_vat_register_id
                        ,x_err_msg         => l_err_msg);
       fnd_file.put_line(fnd_file.log,'After Calling JEITAPSR');
      ELSIF P_REPORT_NAME = 'JEITAPPV' THEN
       fnd_file.put_line(fnd_file.log,'Calling JEITAPPV');
       jeitappv(p_vat_rep_entity_id       => p_vat_rep_entity_id
                        ,p_period          => p_period
                        ,p_vat_register_id => p_vat_register_id
                        ,x_err_msg         => l_err_msg);
       fnd_file.put_line(fnd_file.log,'After Calling JEITAPPV');
      ELSIF P_REPORT_NAME = 'JEESRVAR' THEN
       fnd_file.put_line(fnd_file.log,'Calling JEESRVAR');
       jeesrvar(p_vat_rep_entity_id    => p_vat_rep_entity_id
                 ,p_period              => p_period
				 ,p_period_to           => p_period_to -- Bug8267272
                 ,p_tax_type            => p_tax_type
                 ,p_balancing_segment   => p_balancing_segment
                 ,p_start_inv_sequence  => p_start_inv_sequence
                 ,x_err_msg             => l_err_msg);
      fnd_file.put_line(fnd_file.log,'After Calling JEESRVAR');
      ELSIF P_REPORT_NAME = 'JEESRPVP' THEN
        fnd_file.put_line(fnd_file.log,'Calling Procedure JEESRPVP');
        jeesrpvp(p_vat_rep_entity_id    => p_vat_rep_entity_id
                 ,p_period              => p_period
				 ,p_period_to           => p_period_to -- Bug8267272
                 ,p_tax_type            => p_tax_type
                 ,p_register_type       => p_register_type
                 ,p_balancing_segment   => p_balancing_segment
                 ,p_start_inv_sequence  => p_start_inv_sequence
                 ,x_err_msg             => l_err_msg);
      fnd_file.put_line(fnd_file.log,'After Calling JEESRPVP');
      ELSIF P_REPORT_NAME is null THEN
      fnd_file.put_line(fnd_file.log,'Calling JOURNAL_AP');
      journal_ap(p_vat_rep_entity_id    => p_vat_rep_entity_id
                 ,p_period              => p_period
                 ,x_err_msg             => l_err_msg);
      fnd_file.put_line(fnd_file.log,'After Calling JOURNAL_AP');
    END IF;

   INSERT INTO jg_zz_vat_trx_gt
    ( jg_info_n1
     ,jg_info_v1
     ,jg_info_v2
     ,jg_info_v3
     ,jg_info_v4
     ,jg_info_v5
     ,jg_info_v6
     ,jg_info_v7
     ,jg_info_v8
     ,jg_info_v9
     ,jg_info_v10
     ,jg_info_v11
     ,jg_info_v12
     ,jg_info_v13
     ,jg_info_v14
     ,jg_info_v15
     ,jg_info_v16
     ,jg_info_v17
     ,jg_info_d1
     ,jg_info_d2
     ,jg_info_n2
     ,jg_info_v30
     ,jg_info_v18
     ,jg_info_v19
     ,jg_info_v20
    )
    VALUES
    ( l_legal_entity_id
      ,l_company_name
      ,l_company_name         -- l_legal_entity_name
      ,l_tax_registration_num -- l_registration_num
      ,l_registration_num     -- l_tax_payer_id
      ,l_contact_name
      ,l_address_line_1
      ,l_address_line_2
      ,l_address_line_3
      ,l_address_line_4
      ,l_city
      ,l_country
      ,l_phone_number
      ,l_postal_code
      ,l_func_curr
      ,l_reporting_status
      ,l_tax_regime
      ,l_vat_register_name
      ,decode(nvl(P_REPORT_NAME,'ZZ'),'JEESRVAR',l_to_period_end_date,
	                                    'JEESRPVP',l_to_period_end_date,
										l_period_end_date)
      ,l_period_start_date
      ,l_rec_count
      ,'H'
      ,l_province
      ,l_comm_num
      ,l_vat_reg_num
    );

	fnd_file.put_line(fnd_file.log,'P_REPORT_NAME :'||P_REPORT_NAME);
	fnd_file.put_line(fnd_file.log,'l_to_period_end_date :'||l_to_period_end_date);


    RETURN (TRUE);
  EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error occurred in beforeReport.' || SQLERRM || SQLCODE);
     RETURN (FALSE);
  END beforeReport;

--
-- +======================================================================+
-- Name: AFTER_REPORT
--
-- Description: This function is called as a after report trigger by the
--              data template. This trigger may to used to do any post processing
--              operations required by the Extract. The JOURNAL-AR Data extract
--              does not have any implementaions with the AFTER_REPORT trigger.
--              However the Procedure is defined to allow the further customizations.
-- Parameters:   None
-- +======================================================================+
--
FUNCTION afterReport  RETURN BOOLEAN
  IS
  BEGIN
    NULL;
     RETURN (TRUE);
END afterReport;

--
-- +======================================================================+
-- Name: JEBEDV08
--
-- Description: This procedure used by the Extract when the Concurrent
--              Program 'Belgian VAT Purchases Journal' is run.
--
-- Parameters:  P_VAT_REP_ENTITY_ID            => VAT Reporting Entity ID
--              P_PERIOD                       => Tax Calendar Year
--              P_DOCUMENT_SEQUENCE_NAME_FROM  => Document Sequence Name From
--              P_DOCUMENT_SEQUENCE_NAME_TO    => Document Sequence Name To
--              P_VENDOR_NAME_FROM             => Vendor Name From
--              P_VENDOR_NAME_TO               => Vendor Name To
--              P_DETAIL_SUMMARY               => Detail Summary
-- +======================================================================+
--
 PROCEDURE jebedv08(p_vat_rep_entity_id              IN    NUMBER
                      ,p_period                      IN    VARCHAR2
                      ,p_document_sequence_name_from IN    VARCHAR2
                      ,p_document_sequence_name_to   IN    VARCHAR2
                      ,p_vendor_name_from            IN    VARCHAR2
                      ,p_vendor_name_to              IN    VARCHAR2
                      ,p_detail_summary              IN    VARCHAR2
                      ,x_err_msg                     OUT NOCOPY  VARCHAR2)
IS
CURSOR c_belgian_vat IS
SELECT JZVRS.tax_calendar_year                                             PERIOD_YEAR
      ,JZVRS.tax_calendar_period                                           PERIOD_NAME
      ,JZVTD.doc_seq_name                                                  SEQUENCE_NAME
      ,JZVTD.doc_seq_value                                                 SEQUENCE_NUMBER
      ,DECODE(JZVTD.doc_seq_id,null, JZVTD.period_name ,JZVTD.doc_seq_id)  DOCUMENT_SEQUENCE_ID
      ,JZVTD.trx_date                                                      DOCUMENT_DATE --bug7197984
      ,JZVTD.billing_tp_number                                             VENDOR_NUM
      ,JZVTD.billing_tp_name                                               VENDOR_NAME
      ,JZVTD.trx_number                                                    INVOICE_NUM
      ,ROUND(NVL(JZVTD.taxable_amt_funcl_curr,0),g_precision)* to_number
                                                      (decode
                                                         ( jzvtd.tax_recoverable_flag
                                                         , 'Y', jzvar.taxable_rec_sign_flag  /* can be '+' or '-' */
                                                         ,jzvar.taxable_non_rec_sign_flag
                                                         )||'1'
                                                       )                  INV_AMT_WITHOUT_VAT
      ,ROUND(NVL(JZVTD.tax_amt_funcl_curr,0)+NVL(JZVTD.taxable_amt_funcl_curr,0),g_precision)     * to_number
                                                      (decode
                                                         ( jzvtd.tax_recoverable_flag
                                                         , 'Y', jzvar.tax_rec_sign_flag  /* can be '+' or '-' */
                                                         ,jzvar.tax_non_rec_sign_flag
                                                         )||'1'
                                                      )                   TOT_INV_AMT_WITH_VAT
      ,ROUND( NVL(JZVTD.tax_amt_funcl_curr,0),g_precision) * to_number
                                                      (decode
                                                         ( jzvtd.tax_recoverable_flag
                                                         , 'Y', jzvar.taxable_rec_sign_flag  /* can be '+' or '-' */
                                                         ,jzvar.taxable_non_rec_sign_flag
                                                         )||'1'
                                                      )                    VAT_AMOUNT
      ,DECODE(JZVTD.tax_recoverable_flag
                       , 'Y', NVL(JZVTD.tax_amt_funcl_curr,JZVTD.tax_amt))
                         * to_number(tax_rec_sign_flag||'1')               TAX_REC_AMOUNT
      ,DECODE (JZVTD.tax_recoverable_flag
                      , 'N' , NVL(JZVTD.tax_amt_funcl_curr,JZVTD.tax_amt)
                                                )
               * to_number(tax_non_rec_sign_flag||'1')                   TAX_NREC_AMOUNT
      ,JZVTD.tax_rate_code                                                 VAT_CODE
      ,JZVTD.trx_line_number                                               LINE_NUM
      ,JZVTD.account_flexfield                                             FLEXFIELD
      ,JZVTD.trx_control_account_flexfield                                 TXBL_FLEXFIELD
      ,JZVTD.account_description                                           ACCT_DESC
      ,FA_RX_FLEX_PKG.GET_DESCRIPTION ( 101, 'GL#',
                (select chart_of_accounts_id from gl_ledgers where ledger_id = JZVTD.ledger_id),
                'ALL', JZVTD.trx_control_account_flexfield )   TXBL_ACCT_DESC
      ,NVL(JZVTD.taxable_amt_funcl_curr,JZVTD.taxable_amt) * to_number
                                                            (decode
                                                               ( jzvtd.tax_recoverable_flag
                                                               , 'Y', jzvar.taxable_rec_sign_flag  /* can be '+' or '-' */
                                                               ,jzvar.taxable_non_rec_sign_flag
                                                               )||'1'
                                                            )              ACCTD_AMOUNT
      ,NVL(JZVTD.tax_amt_funcl_curr, JZVTD.tax_amt)                        ACCTD_VAT_AMT
      --,NVL(JZVTD.taxable_amt_funcl_curr, JZVTD.taxable_amt)                ACCTD_INV_AMT
      ,DECODE(JZVTD.OFFSET_FLAG,'N',DECODE(NVL(JZVTD.taxable_amt_funcl_curr,0),0
      ,JZVTD.taxable_amt,JZVTD.taxable_amt_funcl_curr),0)                  ACCTD_INV_AMT
      ,NVL(JZVTD.tax_amt_funcl_curr, JZVTD.tax_amt)
      --    + NVL(JZVTD.taxable_amt_funcl_curr, JZVTD.taxable_amt)           ACCTD_TOT_AMT
      + DECODE(JZVTD.OFFSET_FLAG,'N',DECODE(NVL(JZVTD.taxable_amt_funcl_curr,0),0
      ,JZVTD.taxable_amt,JZVTD.taxable_amt_funcl_curr),0)                  ACCTD_TOT_AMT
      ,DECODE(JZVTD.tax_recoverable_flag, 'Y',
            NVL(JZVTD.tax_amt_funcl_curr, JZVTD.tax_amt))                  ACCTD_TAX_REC_AMT
      ,DECODE (JZVTD.tax_recoverable_flag, 'N',
            NVL(JZVTD.tax_amt_funcl_curr, JZVTD.tax_amt))                  ACCTD_TAX_NREC_AMT
      ,JZVTD.tax_rate_vat_trx_type_desc                                    VAT_TRT
      ,NVL(JZVBA.taxable_box, '99')                                        VAT_REPORT_BOX
      ,NVL(JZVBA.tax_box, '99')                                            TAX_BOX
      ,ROW_NUMBER() OVER (PARTITION BY  JZVTD.tax_line_id,JZVBA.allocation_rule_id ORDER BY JZVTD.tax_line_id DESC NULLS LAST) ROW_NUM --bug8601603
      ,ROW_NUMBER() OVER (PARTITION BY  JZVTD.tax_line_id ORDER BY JZVTD.tax_line_id DESC NULLS LAST) ROW_NUM_2
FROM   jg_zz_vat_trx_details      JZVTD
     , jg_zz_vat_rep_status       JZVRS
     , jg_zz_vat_box_allocs       JZVBA
     , jg_zz_vat_alloc_rules      jzvar
WHERE  JZVBA.PERIOD_TYPE          = 'PERIODIC'
AND    JZVRS.source               = 'AP'
/* AND  JZVTD.trx_line_class       IN ('STANDARD','CREDIT','DEBIT','EXPENSE REPORT','PREPAYMENT' ) Bug#5235824 */
AND    JZVTD.trx_line_class       IN ('STANDARD INVOICES','AP_CREDIT_MEMO','AP_DEBIT_MEMO','EXPENSE REPORTS','PREPAYMENT INVOICES')
AND    ((JZVTD.billing_tp_name    BETWEEN NVL(P_VENDOR_NAME_FROM, JZVTD.billing_tp_name)
                                  AND     NVL(P_VENDOR_NAME_TO, JZVTD.billing_tp_name)) OR P_VENDOR_NAME_FROM is null)
AND    ((JZVTD.doc_seq_name       BETWEEN NVL(P_DOCUMENT_SEQUENCE_NAME_FROM,JZVTD.doc_seq_name)
                                  AND     NVL(P_DOCUMENT_SEQUENCE_NAME_TO,JZVTD.doc_seq_name)) OR P_DOCUMENT_SEQUENCE_NAME_FROM IS NULL)
AND    JZVRS.tax_calendar_period      = P_PERIOD
AND    JZVRS.vat_reporting_entity_id  = P_VAT_REP_ENTITY_ID
AND    JZVRS.reporting_status_id      = JZVTD.reporting_status_id
AND    JZVTD.vat_transaction_id       = JZVBA.vat_transaction_id
AND    jzvar.allocation_rule_id       = jzvba.allocation_rule_id
AND    jzvtd.tax_recovery_rate <>0;

BEGIN
  FOR c_belgian_rec IN c_belgian_vat
  LOOP
         INSERT INTO jg_zz_vat_trx_gt(
                                          jg_info_n1
                                         ,jg_info_v1
                                         ,jg_info_v2
                                         ,jg_info_v11  /* jg_info_n2. Bug#5235824 */
                                         ,jg_info_n3
                                         ,jg_info_d1
                                         ,jg_info_v9
                                         ,jg_info_v3
                                         ,jg_info_v10
                                         ,jg_info_n6
                                         ,jg_info_n7
                                         ,jg_info_n8
                                         ,jg_info_n9
                                         ,jg_info_n10
                                         ,jg_info_v4
                                         ,jg_info_n11
                                         ,jg_info_v5
                                         ,jg_info_v31
                                         ,jg_info_v6
                                         ,jg_info_v32
                                         ,jg_info_n12
                                         ,jg_info_v7
                                         ,jg_info_v8
				 	 ,jg_info_v12
                                         ,jg_info_v30
                                         ,jg_info_n13
                                         ,jg_info_n14
                                         ,jg_info_n15
                                         ,jg_info_n16
                                         ,jg_info_n17
                                         ,jg_info_n29
                                         ,jg_info_n30 --bug8601603
                                       )
                               VALUES (
                                        c_belgian_rec.period_year
                                       ,c_belgian_rec.period_name
                                       ,c_belgian_rec.sequence_name
                                       ,c_belgian_rec.sequence_number
                                       ,c_belgian_rec.document_sequence_id
                                       ,c_belgian_rec.document_date
                                       ,c_belgian_rec.vendor_num
                                       ,c_belgian_rec.vendor_name
                                       ,c_belgian_rec.invoice_num
                                       ,c_belgian_rec.inv_amt_without_vat
                                       ,c_belgian_rec.tot_inv_amt_with_vat
                                       ,c_belgian_rec.vat_amount
                                       ,c_belgian_rec.tax_rec_amount
                                       ,c_belgian_rec.tax_nrec_amount
                                       ,c_belgian_rec.vat_code
                                       ,c_belgian_rec.line_num
                                       ,c_belgian_rec.flexfield
                                       ,c_belgian_rec.txbl_flexfield
                                       ,c_belgian_rec.acct_desc
                                       ,c_belgian_rec.txbl_acct_desc
                                       ,c_belgian_rec.acctd_amount
                                       ,c_belgian_rec.vat_trt
       				       ,c_belgian_rec.vat_report_box
				       ,c_belgian_rec.tax_box
                                       ,'JEBEDV08'
                                       ,c_belgian_rec.acctd_vat_amt
                                       ,c_belgian_rec.acctd_inv_amt
                                       ,c_belgian_rec.acctd_tot_amt
                                       ,c_belgian_rec.acctd_tax_rec_amt
                                       ,c_belgian_rec.acctd_tax_nrec_amt
                                       ,c_belgian_rec.row_num --bug8601603
				       ,c_belgian_rec.row_num_2 --bug8601603
                                       );
  END LOOP;
 --update table bug8601603
  --update acctd_inv_amt of the second record for same trx_line_id  having tax_recovery_rate <>= 0
   update jg_zz_vat_trx_gt
  set
  jg_info_n14 = 0 --acctd_inv_amt
   where
  jg_info_n29 =2
  ;

 --update  acctd_inv_amt for the record having tax_recovery_rate <>= 0
  update jg_zz_vat_trx_gt
  set
  jg_info_n14 = 0 --acctd_inv_amt
  ,jg_info_n16 = 0 --acctd_tax_rec_amt
  ,jg_info_n17 = 0 --acctd_tax_nrec_amt
  where
  jg_info_n29 <> jg_info_n30
  ;

  --calculate  acctd_vat_amt to displat total vat amount for invoice
  update jg_zz_vat_trx_gt
  set
  jg_info_n13 = nvl(jg_info_n16,0) + nvl(jg_info_n17,0) --acctd_vat_amt
  ;

  --calculate  acctd_tot_amt to displat total  amount for invoice
  update jg_zz_vat_trx_gt
  set
  jg_info_n15 = nvl(jg_info_n13,0) + nvl(jg_info_n14,0) --acctd_tot_amt
  ;

SELECT COUNT(*) INTO l_rec_count
FROM jg_zz_vat_trx_gt
WHERE jg_info_v30='JEBEDV08';

IF p_debug_flag = 'Y' THEN
  fnd_file.put_line(fnd_file.log,'Number of records inserted into jg_zz_vat_trx_gt table: ' || l_rec_count );
END IF ;

EXCEPTION
WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.log,'Error occurred in jebedv08 procedure.' || SQLERRM || SQLCODE);
END jebedv08;

--
-- +======================================================================+
-- Name: JEITAPSR
--
-- Description: This procedure used by the Extract when the Concurrent
--              Program 'Italian Payables Sales VAT Register(Self Invoices, EEC VAT)' is run.
--
-- Parameters:  P_VAT_REP_ENTITY_ID   => VAT Reporting Entity ID
--              P_PERIOD              => Tax Calendar Year
--              P_VAT_REGISTER_ID     => VAT Register ID
-- +======================================================================+
--
PROCEDURE jeitapsr(p_vat_rep_entity_id   IN    NUMBER
                  ,p_period              IN    VARCHAR2
                  ,p_vat_register_id     IN    VARCHAR2
                  ,x_err_msg             OUT NOCOPY  VARCHAR2)
IS
CURSOR c_italian_payables_sales_vat IS
SELECT JZVTD.doc_seq_name                                                   SEQ_NAME
       ,JZVTD.billing_tp_name                                               VNAME
       ,NVL(JZVTD.billing_tp_site_tax_reg_num,JZVTD.billing_tp_tax_reg_num) VAT_NUM
       ,JZVTD.tax_rate_code_name                                            VAT_NAME
       ,JZVTD.reporting_code                                                 TAX_TYPE
       ,JZVTD.tax_rate                                                      VAT_RATE
       ,JZVTD.tax_rate_code_description                                     VAT_DESC
       ,JZVTD.doc_seq_value                                                 SEQ_VAL
       ,JZVTD.trx_id                                                        INVOICE_ID
       ,JZVTD.trx_number                                                    INVOICE_NUM
       ,JZVTD.trx_date                                                      INVOICE_DATE
       ,JZVTD.trx_currency_code                                             CURRENCY_CODE
       ,JZVTD.tax_recovery_rate                                             RECOVERY_RATE
       ,JZVTD.tax_recoverable_flag                                          TAX_RECOVERABLE_FLAG
       ,JZVTD.gl_date                                                       ACCOUNTING_DATE
       ,NVL(JZVTD.taxable_amt,0)                                            TAXABLE_AMOUNT
       ,NVL(JZVTD.taxable_amt_funcl_curr,0)                                 TAXABLE_BASE_AMOUNT
       ,NVL(JZVTD.tax_amt,0)                                                TAX_AMOUNT
       ,NVL(JZVTD.tax_amt_funcl_curr,0)                                     TAX_BASE_AMOUNT
       ,NVL(fnd_number.canonical_to_number(JZVTD.assessable_value),0)       TAXABLE_SEL_INV
       ,JZVTD.offset_tax_rate_code                                          OFFSET_TAX_CODE_ID
       ,DECODE(JZVTD.tax_recoverable_flag ,'Y',JZVTD.taxable_amt*(JZVTD.tax_recovery_rate/100))           TAXABLE_REC_AMT
       ,DECODE(JZVTD.tax_recoverable_flag ,'N',JZVTD.taxable_amt*(JZVTD.tax_recovery_rate/100))           TAXABLE_NREC_AMT
       ,DECODE(JZVTD.tax_recoverable_flag ,'Y',JZVTD.tax_amt)               TAX_REC_AMT
       ,DECODE(JZVTD.tax_recoverable_flag ,'N',JZVTD.tax_amt)               TAX_NREC_AMT
       ,DECODE(JZVTD.tax_recoverable_flag,'Y',JZVTD.taxable_amt_funcl_curr*(JZVTD.tax_recovery_rate/100))      TAXABLE_REC_BASE_AMT
       ,DECODE(JZVTD.tax_recoverable_flag,'N',JZVTD.taxable_amt_funcl_curr*(JZVTD.tax_recovery_rate/100))      TAXABLE_NREC_BASE_AMT
       ,DECODE(JZVTD.tax_recoverable_flag,'Y',JZVTD.tax_amt_funcl_curr)          TAX_REC_BASE_AMT
       ,DECODE(JZVTD.tax_recoverable_flag,'N',JZVTD.tax_amt_funcl_curr)          TAX_NREC_BASE_AMT
       ,JZVTD.functional_currency_code                                      FUNCTIONAL_CURRENCY_CODE
       -- Bug 6238170 Start
       --,JZVTD.tax_type_code                                                 TAX_TYPE_CODE
       ,JZVTD.reporting_code                                                 TAX_TYPE_CODE
       -- Bug 6238170 End
       ,NVL(JZVTD.offset_tax_rate_code,'N')                                 OFFSET_TAX_RATE_CODE
 FROM   jg_zz_vat_trx_details    JZVTD
       ,jg_zz_vat_rep_status     JZVRS
       ,jg_zz_vat_registers_b    JZVRB
       ,jg_zz_vat_doc_sequences  JZVDS  /* Bug#5235824 */
 WHERE  JZVRS.vat_reporting_entity_id   = P_VAT_REP_ENTITY_ID
    AND JZVRS.tax_calendar_period       = P_PERIOD
    AND JZVRB.vat_register_id           = P_VAT_REGISTER_ID
    -- Bug 6238170 Start
    -- AND JZVTD.tax_type_code             NOT IN ('OFFSET')
    AND JZVTD.reporting_code             NOT IN ('OFFSET')
    -- Bug 6238170 End
    AND JZVRS.source                    = 'AP'
 /* AND JZVTD.tax_invoice_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date */
    AND JZVTD.reporting_status_id       = JZVRS.reporting_status_id
    AND JZVRS.mapping_vat_rep_entity_id = JZVRB.vat_reporting_entity_id
    AND JZVDS.vat_register_id           = JZVRB.vat_register_id
    AND JZVDS.doc_sequence_id           = JZVTD.doc_seq_id;
    -- AND JZVTD.tax_amt <> 0;
  -- BUG 7451529 : Invoices with zero tax amounts should also get picked up. For eg:
  -- the ones which use 'EXEMPT' tax-type.


 lv_start_seq        jg_zz_vat_final_reports.start_sequence_num%type;
 lv_reporting_status varchar2(15);

BEGIN

  SELECT jg_info_n1, jg_info_v1
  INTO lv_start_seq, lv_reporting_status
  FROM jg_zz_vat_trx_gt
  WHERE jg_info_v30 = 'SEQ';

  FOR c_italian_pay_sales_rec IN c_italian_payables_sales_vat
  LOOP
      INSERT into jg_zz_vat_trx_gt(jg_info_v1
                                   ,jg_info_v2
                                   ,jg_info_v3
                                   ,jg_info_v4
                                   ,jg_info_v5
                                   ,jg_info_n1
                                   ,jg_info_v6
                                   ,jg_info_n2
                                   ,jg_info_v7
                                   ,jg_info_d1
                                   ,jg_info_v8
                                   ,jg_info_v9
                                   ,jg_info_d2
                                   ,jg_info_n3
                                   ,jg_info_n4
                                   ,jg_info_n5
                                   ,jg_info_n6
                                 --,jg_info_n7,
                                   ,jg_info_n8
                                   ,jg_info_n9
                                   ,jg_info_v26 /* jg_info_n10. Bug#5235824 */
                                   ,jg_info_n20
                                   ,jg_info_n21
                                   ,jg_info_n22
                                   ,jg_info_n23
				   ,jg_info_n13
				   ,jg_info_n14
				   ,jg_info_n15
				   ,jg_info_n16
                                   ,jg_info_v20
                                   ,jg_info_v21
                                   ,jg_info_v30
                                   ,jg_info_v39
                             )
                    VALUES (
                            c_italian_pay_sales_rec.seq_name
                           ,SUBSTR(c_italian_pay_sales_rec.vname,1,150)
                           ,c_italian_pay_sales_rec.vat_num
                           ,c_italian_pay_sales_rec.vat_name
                           ,c_italian_pay_sales_rec.tax_type
                           ,c_italian_pay_sales_rec.vat_rate
                           ,c_italian_pay_sales_rec.vat_desc
                           ,c_italian_pay_sales_rec.seq_val
                           ,c_italian_pay_sales_rec.invoice_num
                           ,c_italian_pay_sales_rec.invoice_date
                           ,c_italian_pay_sales_rec.currency_code
                           ,c_italian_pay_sales_rec.tax_recoverable_flag
                           ,c_italian_pay_sales_rec.accounting_date
                           ,c_italian_pay_sales_rec.taxable_amount
                           ,c_italian_pay_sales_rec.taxable_base_amount
                           ,c_italian_pay_sales_rec.tax_amount
                           ,c_italian_pay_sales_rec.tax_base_amount
                           -- c_italian_pay_sales_rec.taxable_sel_inv, Check Sumanth
                           ,c_italian_pay_sales_rec.invoice_id
                           ,c_italian_pay_sales_rec.recovery_rate
                           ,c_italian_pay_sales_rec.offset_tax_code_id
                           ,c_italian_pay_sales_rec.taxable_rec_amt
                           ,c_italian_pay_sales_rec.taxable_nrec_amt
                           ,c_italian_pay_sales_rec.tax_rec_amt
                           ,c_italian_pay_sales_rec.tax_nrec_amt
			   ,c_italian_pay_sales_rec.taxable_rec_base_amt
			   ,c_italian_pay_sales_rec.taxable_nrec_base_amt
			   ,c_italian_pay_sales_rec.tax_rec_base_amt
			   ,c_italian_pay_sales_rec.tax_nrec_base_amt
                           ,c_italian_pay_sales_rec.functional_currency_code
                           ,c_italian_pay_sales_rec.tax_type_code
                           ,'JEITAPSR'
                           ,c_italian_pay_sales_rec.offset_tax_rate_code);
  END LOOP;

  SELECT COUNT(*)
  INTO l_rec_count
  FROM jg_zz_vat_trx_gt
  WHERE jg_info_v30='JEITAPSR';

  IF p_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Number of records inserted into jg_zz_vat_trx_gt table: ' || l_rec_count );
  END IF ;

  -- Update teh jg_zz_vat_final_reports table for print sequence numbers if lv_reporting_status = 'FINAL'
  IF lv_reporting_status = 'FINAL' THEN

    SELECT count(*)
    INTO l_rec_count
    FROM (SELECT 1
          FROM jg_zz_vat_trx_gt
          WHERE jg_info_v30 = 'JEITAPSR'
          GROUP BY jg_info_v1
                  ,jg_info_d2
                  ,jg_info_n2
                  ,jg_info_v7
                  ,jg_info_d1
                  ,jg_info_v2
                  ,jg_info_v3
                  ,jg_info_v8
                  ,jg_info_v20
          ORDER BY jg_info_v1
                  ,jg_info_d2
                  ,jg_info_n2
                  ,jg_info_v7
                  ,jg_info_d1
                  ,jg_info_v2
                  ,jg_info_v8);

     -- Update the entry in JG_ZZ_VAT_FINAL_REPORTS table
     UPDATE jg_zz_vat_final_reports
     SET start_sequence_num = lv_start_seq + l_rec_count,
         last_start_sequence_num = lv_start_seq
     WHERE report_name = p_report_name
     AND   vat_register_id = p_vat_register_id
     AND   reporting_status_id = (SELECT reporting_status_id
                                  FROM jg_zz_vat_rep_status
                                  WHERE vat_reporting_entity_id = p_vat_rep_entity_id
                                  AND   source = 'AP'
                                  AND   tax_calendar_period = p_period);

  END IF;

EXCEPTION
WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.log,'Error in procedure jeitapsr.' || SQLERRM || SQLCODE);
END jeitapsr;

--
-- +======================================================================+
-- Name: JEITAPPV
--
-- Description: This procedure used by the Extract when the Concurrent
--              Program 'Italian Purchase VAT Register' is run.
--
-- Parameters:  P_VAT_REP_ENTITY_ID   => VAT Reporting Entity ID
--              P_PERIOD              => Tax Calendar Year
--              P_VAT_REGISTER_ID     => VAT Register ID
-- +======================================================================+
--
PROCEDURE jeitappv(p_vat_rep_entity_id   IN          NUMBER
                  ,p_period              IN          VARCHAR2
                  ,p_vat_register_id     IN          VARCHAR2
                  ,x_err_msg             OUT NOCOPY  VARCHAR2)
IS

CURSOR c_italian_purchase_vat(cp_tax_tag varchar2)  IS
  SELECT  JZVTD.doc_seq_name                                                  SEQ_NAME
         ,NVL(JZVTD.merchant_party_name,JZVTD.billing_tp_name)                VNAME
         ,NVL(JZVTD.merchant_party_tax_reg_number,NVL(JZVTD.billing_tp_site_tax_reg_num,JZVTD.billing_tp_tax_reg_num)) VAT_NUM
         ,JZVTD.tax_rate_code_name                                            VAT_NAME
         ,JZVTD.reporting_code                                                 TAX_TYPE
         ,JZVTD.tax_rate                                                      VAT_RATE
         ,JZVTD.tax_rate_code_description                                     VAT_DESC
         ,JZVTD.doc_seq_value                                                 SEQ_VAL
         ,JZVTD.trx_id                                                        INVOICE_ID
         ,NVL(JZVTD.merchant_party_document_number,JZVTD.trx_number)          INVOICE_NUM
         ,NVL(JZVTD.start_expense_date,JZVTD.trx_date)                        INVOICE_DATE
         ,JZVTD.trx_currency_code                                             CURRENCY_CODE
         ,JZVTD.gl_date                                               ACCOUNTING_DATE
         ,NVL(DECODE(tax_recoverable_flag,'Y',taxable_amt_funcl_curr*(JZVTD.tax_recovery_rate/100)),0)      TAXABLE_REC_BASE_AMOUNT
         ,NVL(DECODE(tax_recoverable_flag,'Y',taxable_amt*(JZVTD.tax_recovery_rate/100)) ,0)                TAXABLE_REC_AMOUNT
         ,NVL(DECODE(tax_recoverable_flag,'Y',tax_amt_funcl_curr),0)          TAX_REC_BASE_AMOUNT
         ,NVL(DECODE(tax_recoverable_flag,'Y',tax_amt),0)                     TAX_REC_AMOUNT
         ,NVL(DECODE(tax_recoverable_flag,'N',taxable_amt_funcl_curr*(JZVTD.tax_recovery_rate/100)),0)      TAXABLE_NREC_BASE_AMOUNT
         ,NVL(DECODE(tax_recoverable_flag,'N',taxable_amt*(JZVTD.tax_recovery_rate/100)),0)                 TAXABLE_NREC_AMOUNT
         ,NVL(DECODE(tax_recoverable_flag,'N',tax_amt_funcl_curr),0)          TAX_NREC_BASE_AMOUNT
         ,NVL(DECODE(tax_recoverable_flag,'N',tax_amt) ,0)                    TAX_NREC_AMOUNT
         ,NVL(fnd_number.canonical_to_number(JZVTD.assessable_value),0)       SEL_INV_AMOUNT
         ,JZVTD.tax_recovery_rate                                             RECOVERY_RATE
         ,DECODE(JZVTD.offset_tax_rate_code, NULL,NVL(tax_amt,0) + NVL(taxable_amt,0),NVL(DECODE(TAX_RECOVERABLE_FLAG ,'Y',TAXABLE_AMT),0) + NVL(DECODE(TAX_RECOVERABLE_FLAG ,'N',TAXABLE_AMT),0)) FOREIGN_AMT
         ,JZVTD.tax_recoverable_flag                                          TAX_RECOVERABLE_FLAG
        -- ,DECODE(flv.tag, cp_tax_tag , '^', NULL)                             EXEMPT_FLAG
         ,DECODE(JZVTD.reporting_code, cp_tax_tag , '^', NULL)                 EXEMPT_FLAG
         ,DECODE(JZVTD.accounting_date, NULL, '*', NULL)                      INV_DIST_POSTED_FLAG
         ,JZVTD.functional_currency_code                                      FUNCTIONAL_CURRENCY_CODE
         ,JZVTD.reporting_code                                                 TAX_TYPE_CODE
         ,NVL(JZVTD.offset_tax_rate_code,'N')                                 OFFSET_TAX_RATE_CODE
  FROM    jg_zz_vat_trx_details   JZVTD
         ,jg_zz_vat_rep_status    JZVRS
         ,jg_zz_vat_registers_b   JZVRB
         ,jg_zz_vat_doc_sequences JZVDS   /* Bug#5235824 */
--       ,fnd_lookup_values_vl    flv     /* Bug#5235824 */


 WHERE JZVRS.vat_reporting_entity_id   = P_VAT_REP_ENTITY_ID
 AND   JZVRS.tax_calendar_period       = P_PERIOD
 AND   JZVRB.vat_register_id           = P_VAT_REGISTER_ID
 --AND   flv.lookup_type                 = 'TAX TYPE'
-- AND   JZVTD.TAX_TYPE_CODE             NOT IN ('OFFSET')
 AND   JZVTD.REPORTING_CODE             NOT IN ('OFFSET')
 AND   JZVRS.source                    = 'AP'
/*AND JZVTD.tax_invoice_date          BETWEEN JZVRS.period_start_date and JZVRS.period_end_date */
-- AND   JZVTD.tax_type_code             = flv.lookup_code
 AND   JZVTD.reporting_status_id       = JZVRS.reporting_status_id
 AND   JZVRS.mapping_vat_rep_entity_id = JZVRB.vat_reporting_entity_id
 AND   JZVRB.vat_register_id           = JZVDS.vat_register_id
 AND   JZVDS.doc_sequence_id           = JZVTD.doc_seq_id;
-- AND   JZVTD.tax_amt <> 0;
  -- BUG 7451529 : Invoices with zero tax amounts should also get picked up. For eg:
  -- the ones which use 'EXEMPT' tax-type.


-- lv_tax_tag          fnd_lookup_values_vl.tag%type ;
   lv_tax_code         VARCHAR2(60);
 lv_start_seq        jg_zz_vat_final_reports.start_sequence_num%type;
 lv_reporting_status varchar2(15);

BEGIN
-- lv_tax_tag := nvl(FND_PROFILE.VALUE('JEIT_EXEMPT_TAX_TAG'),'JEIT_NO_EXEMPT_TAX_TAG'); /* Bug#5235824 */
 lv_tax_code := nvl(FND_PROFILE.VALUE('JEIT_EXEMPT_TAX_TAG'),'JEIT_NO_EXEMPT_TAX_TAG'); /* Bug#5235824 */

 SELECT jg_info_n1, jg_info_v1
 INTO lv_start_seq, lv_reporting_status
 FROM jg_zz_vat_trx_gt
 WHERE jg_info_v30 = 'SEQ';

 FOR c_italian_purchase_vat_rec IN c_italian_purchase_vat(lv_tax_code)
 LOOP

 INSERT INTO jg_zz_vat_trx_gt (jg_info_v1
                              ,jg_info_v2
                              ,jg_info_v3
                              ,jg_info_v4
                              ,jg_info_v5
                              ,jg_info_n1
                              ,jg_info_v6
                              ,jg_info_n2
                              ,jg_info_n3
                              ,jg_info_v7
                              ,jg_info_d1
                              ,jg_info_v8
                              ,jg_info_d2
                              ,jg_info_n4
                              ,jg_info_n5
                              ,jg_info_n6
                              ,jg_info_n7
                              ,jg_info_n8
                              ,jg_info_n9
                              ,jg_info_n10
                              ,jg_info_n11
  --                            ,jg_info_n12
                              ,jg_info_n13
                              ,jg_info_n14
                              ,jg_info_v39
                              ,jg_info_v9
                              ,jg_info_v10
                              ,jg_info_v11 /* Bug#5235824 */
                              ,jg_info_n20
                              ,jg_info_n21
                              ,jg_info_n22
                              ,jg_info_n23
                              ,jg_info_v20
                              ,jg_info_v30
                              ,jg_info_v31
                               )
                      VALUES  (c_italian_purchase_vat_rec.seq_name
                               ,SUBSTR(c_italian_purchase_vat_rec.vname,1,150)
                               ,c_italian_purchase_vat_rec.vat_num
                               ,c_italian_purchase_vat_rec.vat_name
                               ,c_italian_purchase_vat_rec.tax_type
                               ,c_italian_purchase_vat_rec.vat_rate
                               ,c_italian_purchase_vat_rec.vat_desc
                               ,c_italian_purchase_vat_rec.seq_val
                               ,c_italian_purchase_vat_rec.invoice_id
                               ,c_italian_purchase_vat_rec.invoice_num
                               ,c_italian_purchase_vat_rec.invoice_date
                               ,c_italian_purchase_vat_rec.currency_code
                               ,c_italian_purchase_vat_rec.accounting_date
                               ,c_italian_purchase_vat_rec.taxable_rec_amount
                               ,c_italian_purchase_vat_rec.taxable_rec_base_amount
                               ,c_italian_purchase_vat_rec.tax_rec_amount
                               ,c_italian_purchase_vat_rec.tax_rec_base_amount
                               ,c_italian_purchase_vat_rec.taxable_nrec_amount
                               ,c_italian_purchase_vat_rec.taxable_nrec_base_amount
                               ,c_italian_purchase_vat_rec.tax_nrec_amount
                               ,c_italian_purchase_vat_rec.tax_nrec_base_amount
--                               ,c_italian_purchase_vat_rec.sel_inv_amount
                               ,c_italian_purchase_vat_rec.recovery_rate
                               ,c_italian_purchase_vat_rec.foreign_amt
                               ,c_italian_purchase_vat_rec.offset_tax_rate_code
                               ,c_italian_purchase_vat_rec.tax_recoverable_flag
                               ,c_italian_purchase_vat_rec.inv_dist_posted_flag
                               ,c_italian_purchase_vat_rec.exempt_flag
                               ,c_italian_purchase_vat_rec.taxable_rec_amount
                               ,c_italian_purchase_vat_rec.taxable_nrec_amount
                               ,c_italian_purchase_vat_rec.tax_rec_amount
                               ,c_italian_purchase_vat_rec.tax_nrec_amount
                               ,c_italian_purchase_vat_rec.functional_currency_code
                               ,'JEITAPPV'
                               ,c_italian_purchase_vat_rec.tax_type_code);
  END LOOP;

  -- Count the number of records inserted into jg_zz_vat_trx_gt table
  SELECT COUNT(*)
  INTO l_rec_count
  FROM jg_zz_vat_trx_gt
  WHERE jg_info_v30='JEITAPPV';

  IF p_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Number of records inserted into jg_zz_vat_trx_gt table: ' || l_rec_count );
  END IF ;

  -- Update teh jg_zz_vat_final_reports table for print sequence numbers if lv_reporting_status = 'FINAL'
  IF lv_reporting_status = 'FINAL' THEN

    SELECT count(*)
    INTO l_rec_count
    FROM (SELECT 1
          FROM jg_zz_vat_trx_gt
          WHERE jg_info_v30 = 'JEITAPPV'
          GROUP BY jg_info_v1
                  ,jg_info_d2
                  ,jg_info_n2
                  ,jg_info_v7
                  ,jg_info_d1
                  ,jg_info_v2
                  ,jg_info_v3
                  ,jg_info_v8
                  ,jg_info_v20
                  ,jg_info_v11
                  ,jg_info_v10
          ORDER BY jg_info_v1
                  ,jg_info_d2
                  ,jg_info_n2
                  ,jg_info_v7
                  ,jg_info_d1
                  ,jg_info_v2
                  ,jg_info_v3
                  ,jg_info_v8
                  ,jg_info_v20 );

     -- Update the entry in JG_ZZ_VAT_FINAL_REPORTS table
     UPDATE jg_zz_vat_final_reports
     SET start_sequence_num = lv_start_seq + l_rec_count,
         last_start_sequence_num = lv_start_seq
     WHERE report_name = p_report_name
     AND   vat_register_id = p_vat_register_id
     AND   reporting_status_id = (SELECT reporting_status_id
                                  FROM jg_zz_vat_rep_status
                                  WHERE vat_reporting_entity_id = p_vat_rep_entity_id
                                  AND   source = 'AP'
                                  AND   tax_calendar_period = p_period);

  END IF;

EXCEPTION
WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.log,'Error occurred in procedure jeitappv.' || SQLERRM || SQLCODE);
END jeitappv;

--
-- +======================================================================+
-- Name: JEESRVAR
--
-- Description: This procedure used by the Extract when the Concurrent
--              Program 'Spanish Inter-EU Invoices Journal Report' is run.
--
-- Parameters:  P_VAT_REP_ENTITY_ID   => VAT Reporting Entity ID
--              P_PERIOD              => Tax Calendar Year
--              P_TAX_TYPE            => Tax Type
--              P_BALANCING_SEGMENT   => Balancing Segment
--              P_START_INV_SEQUENCE  => Start Invoice Sequence
-- +======================================================================+
--
PROCEDURE jeesrvar(p_vat_rep_entity_id    IN    NUMBER
                   ,p_period              IN    VARCHAR2
				   ,p_period_to           IN    VARCHAR2 -- Bug8267272
                   ,p_tax_type            IN    VARCHAR2
                   ,p_balancing_segment   IN    VARCHAR2
                   ,p_start_inv_sequence  IN    VARCHAR2
                   ,x_err_msg             OUT NOCOPY  VARCHAR2)
IS
CURSOR c_spanish_inter_eu_invoices IS
SELECT JZVTD.accounting_date                     ACCOUNTING_DATE
      ,JZVTD.doc_seq_name||'/'||JZVTD.doc_seq_value  DOC_SEQUENCE_VALUE
      ,JZVTD.trx_date                                TRX_DATE
      ,JZVTD.trx_number                              TRX_NUMBER
      ,JZVTD.billing_tp_name                         BILLING_TP_NAME
      ,JZVTD.billing_tp_tax_reg_num                  TAX_REG_NUM
      ,(NVL(JZVTD.taxable_amt, JZVTD.taxable_amt_funcl_curr))*(NVL(TAX_RECOVERY_RATE,0)/100) NET_AMT_ORIG --Modified for Bug 7457763
       ,JZVTD.tax_rate                                TAX_RATE
      ,JZVTD.tax_rate_code                           TAX_CODE
      ,JZVTD.tax_rate_code_description               TAX_DESCR
      ,NVL(JZVTD.tax_amt, JZVTD.tax_amt_funcl_curr)  TAX_AMT_ORIG
      ,JZVTD.trx_line_class                          INVOICE_TYPE
      ,JZVTD.tax_rate_id                             TAX_CODE_ID
      ,JZVTD.offset_tax_rate_code                    OFFSET_TAX_CODE_ID
      ,JZVTD.reporting_code                          LINE_TYPE
      ,JZVTD.trx_id                                  TRX_ID
 FROM  jg_zz_vat_trx_details JZVTD
      ,jg_zz_vat_rep_status JZVRS
 WHERE JZVRS.vat_reporting_entity_id    = P_VAT_REP_ENTITY_ID
 -- Bug8267272 Start
 AND   JZVRS.tax_calendar_period        IN (SELECT RPS1.tax_calendar_period
 	               FROM JG_ZZ_VAT_REP_STATUS RPS1,
 	                    (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
 	                            min(period_start_date) period_start_date
 	                     From JG_ZZ_VAT_REP_STATUS
 	                     Where vat_reporting_entity_id = p_vat_rep_entity_id
 	                     And tax_calendar_period =p_period) RPS2,
 	                    (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
 	                           min(period_end_date) period_end_date
 	                     From JG_ZZ_VAT_REP_STATUS
 	                     Where vat_reporting_entity_id = p_vat_rep_entity_id
 	                     And tax_calendar_period = p_period_to) RPS3
 	               WHERE RPS1.vat_reporting_entity_id = p_vat_rep_entity_id
 	                 AND RPS2.vat_reporting_entity_id = RPS1.vat_reporting_entity_id
 	                 AND RPS3.vat_reporting_entity_id = RPS2.vat_reporting_entity_id
 	                 AND trunc(RPS1.period_start_date) >=
 	                                trunc(RPS2.period_start_date)
 	                 AND trunc(RPS1.period_end_date) <= trunc(RPS3.period_end_date)
 	               GROUP by RPS1.tax_calendar_period)
 -- Bug8267272 End
 AND   (JZVTD.trx_tax_balancing_segment = P_BALANCING_SEGMENT OR P_BALANCING_SEGMENT is null)
 AND   (JZVTD.reporting_code             = P_TAX_TYPE OR P_TAX_TYPE is null)
 AND   JZVRS.source                     = 'AP'
 AND   JZVTD.reporting_status_id in (SELECT DISTINCT JZRS.reporting_status_id JZRS
				     FROM jg_zz_vat_rep_status JZRS
				     WHERE JZRS.vat_reporting_entity_id = P_VAT_REP_ENTITY_ID
				     AND   JZRS.source = 'AP')
 AND   JZVTD.gl_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date;
-- AND   JZVTD.reporting_status_id        = JZVRS.reporting_status_id ;

BEGIN
  FOR c_spanish_inter_eu_inv_rec IN c_spanish_inter_eu_invoices
  LOOP
  INSERT INTO jg_zz_vat_trx_gt (jg_info_d1
                                ,jg_info_v1
                                ,jg_info_d2
                                ,jg_info_v2
                                ,jg_info_v3
                                ,jg_info_v4
                                ,jg_info_n1
                                ,jg_info_n2
                                ,jg_info_v5
                                ,jg_info_v6
                                ,jg_info_v7
                                ,jg_info_n3
                                ,jg_info_n4
                                ,jg_info_v9
                                ,jg_info_v8  --line_type
                                ,jg_info_n6
                                ,jg_info_v30
                                )
  VALUES ( c_spanish_inter_eu_inv_rec.accounting_date
           ,c_spanish_inter_eu_inv_rec.doc_sequence_value
           ,c_spanish_inter_eu_inv_rec.trx_date
           ,c_spanish_inter_eu_inv_rec.trx_number
           ,SUBSTR(c_spanish_inter_eu_inv_rec.billing_tp_name,1,150)
           ,c_spanish_inter_eu_inv_rec.tax_reg_num
           ,c_spanish_inter_eu_inv_rec.net_amt_orig
           ,c_spanish_inter_eu_inv_rec.tax_rate
           ,c_spanish_inter_eu_inv_rec.tax_code
           ,c_spanish_inter_eu_inv_rec.tax_descr
           ,c_spanish_inter_eu_inv_rec.invoice_type
           ,c_spanish_inter_eu_inv_rec.tax_amt_orig
           ,c_spanish_inter_eu_inv_rec.tax_code_id
           ,c_spanish_inter_eu_inv_rec.offset_tax_code_id
           ,c_spanish_inter_eu_inv_rec.line_type
           ,c_spanish_inter_eu_inv_rec.trx_id
           ,'JEESRVAR');
  END LOOP;

  SELECT COUNT(*)
  INTO l_rec_count
  FROM jg_zz_vat_trx_gt
  WHERE jg_info_v30='JEESRVAR';

  IF p_debug_flag = 'Y' THEN
   fnd_file.put_line(fnd_file.log,'Number of records inserted into jg_zz_vat_trx_gt table: ' || l_rec_count );
  END IF ;

EXCEPTION
WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.log,'EXCEPTION' || SQLERRM || SQLCODE);
END jeesrvar;

  --
  -- +======================================================================+
  -- Name: JEESRPVP
  --
  -- Description: This procedure used by the Extract when the Concurrent
  --              Program 'Spanish Input VAT Journal Report' is run.
  --
  -- Parameters:  P_VAT_REP_ENTITY_ID   => VAT Reporting Entity ID
  --              P_PERIOD              => Tax Calendar Year
  --              P_TAX_TYPE            => Tax Type
  --              P_BALANCING_SEGMENT   => Balancing Segment
  --              P_START_INV_SEQUENCE  => Start Invoice Sequence
  -- +======================================================================+
  --
 PROCEDURE jeesrpvp(p_vat_rep_entity_id   IN    NUMBER
                      ,p_period              IN    VARCHAR2
					  ,p_period_to           IN    VARCHAR2 -- Bug8267272
                      ,p_tax_type            IN    VARCHAR2
                      ,p_register_type       IN    VARCHAR2
                      ,p_balancing_segment   IN    VARCHAR2
                      ,p_start_inv_sequence  IN    VARCHAR2
                      ,x_err_msg             OUT NOCOPY  VARCHAR2)
  IS
  lc_customer          VARCHAR2(240);
  lc_tax_reg           VARCHAR2(80);
  lc_ae_event_type_code   VARCHAR2(80);

  CURSOR c_spanish_input_vat
    IS
      SELECT JZVTD.trx_id                                TRX_ID
           ,JZVTD.doc_seq_name||'/'||JZVTD.doc_seq_value     DOC_SEQ
           ,JZVTD.trx_date                                   TRX_DATE
           ,JZVTD.trx_number                                 TRX_NUMBER
           ,JZVTD.billing_tp_name                            BILLING_TP_NAME
           ,JZVTD.billing_tp_tax_reg_num                     BILLING_TP_TAX_REG_NUM
           ,nvl(JZVTD.taxable_amt_funcl_curr,JZVTD.taxable_amt)*JZVTD.tax_recovery_rate/100    TAXABLE_AMOUNT
           ,JZVTD.tax_rate_code                              TAX_CODE
           ,JZVTD.tax_rate                                   TAX_CODE_RATE
           ,JZVTD.tax_rate_code_description                  TAX_CODE_DESCRIPTION
           ,DECODE (JZVTD.trx_line_class,'MISC_CASH_RECEIPT',nvl(JZVTD.tax_amt_funcl_curr,JZVTD.tax_amt), DECODE(JZVTD.tax_recoverable_flag ,'Y',nvl(JZVTD.tax_amt_funcl_curr,JZVTD.tax_amt),0)) TAX1_ACCOUNTED_AMOUNT
           ,DECODE(JZVTD.tax_recoverable_flag ,'N',nvl(JZVTD.tax_amt_funcl_curr,JZVTD.tax_amt))  TAX2_ACCOUNTED_AMOUNT
           ,DECODE(P_REGISTER_TYPE,'NON RECOVERABLE TAX REGISTER'
                       ,DECODE(JZVTD.tax_recoverable_flag ,'N',nvl(JZVTD.tax_amt_funcl_curr,JZVTD.tax_amt),0)
                   ,'BOTH',NVL(DECODE(JZVTD.tax_recoverable_flag ,'N',nvl(JZVTD.tax_amt_funcl_curr,JZVTD.tax_amt)),0)+NVL(DECODE(TRX_LINE_CLASS,'MISC_CASH_RECEIPT'
                                ,nvl(JZVTD.tax_amt_funcl_curr,JZVTD.tax_amt),DECODE(JZVTD.tax_recoverable_flag ,'Y',nvl(JZVTD.tax_amt_funcl_curr,JZVTD.tax_amt))),0)
                   ,DECODE(JZVTD.tax_recoverable_flag ,'Y',nvl(JZVTD.tax_amt_funcl_curr,JZVTD.tax_amt),0)) TAX_ACCOUNTED_AMOUNT
           ,nvl(JZVTD.tax_amt_funcl_curr,JZVTD.tax_amt)  TOTAL_ACCOUNTED_AMOUNT
	   ,JZVTD.merchant_party_document_number              AP_TAXABLE_MERCHANT_DOC_NO
           ,JZVTD.merchant_party_name                         AP_TAXABLE_MERCHANT_NAME
           ,JZVTD.merchant_party_tax_reg_number               AP_TAXABLE_MERCHANT_TAX_REG_NO
           ,JZVTD.extract_source_ledger                       EXTRACT_SOURCE_LEDGER
           ,JZVTD.actg_event_type_code                        AE_EVENT_TYPE_CODE
           ,JZVTD.trx_line_class                              TRX_CLASS_CODE
           ,JZVTD.trx_line_type                               TAXABLE_LINE_TYPE_CODE
           ,JZVTD.accounting_date                             AH_ACCOUNTING_DATE
           ,JZVTD.banking_tp_taxpayer_id /* taxpayer_id */    BANKING_TP_TAXPAYER_ID /* TAXPAYER_ID. Bug#5235824 */
           ,JZVTD.bank_account_id                             BANK_ACCOUNT_ID
           ,JZVTD.offset_flag
	   ,JZVTD.tax_recoverable_flag
	   ,nvl(JZVTD.tax_amt_funcl_curr,JZVTD.tax_amt) tax_amt
    FROM    jg_zz_vat_trx_details JZVTD
           ,jg_zz_vat_rep_status JZVRS
    WHERE  JZVRS.vat_reporting_entity_id   = P_VAT_REP_ENTITY_ID
	-- Bug8267272 Start
    AND    JZVRS.tax_calendar_period       IN (SELECT RPS1.tax_calendar_period
 	               FROM JG_ZZ_VAT_REP_STATUS RPS1,
 	                    (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
 	                            min(period_start_date) period_start_date
 	                     From JG_ZZ_VAT_REP_STATUS
 	                     Where vat_reporting_entity_id = p_vat_rep_entity_id
 	                     And tax_calendar_period =p_period) RPS2,
 	                    (Select min(vat_reporting_entity_id) vat_reporting_entity_id,
 	                           min(period_end_date) period_end_date
 	                     From JG_ZZ_VAT_REP_STATUS
 	                     Where vat_reporting_entity_id = p_vat_rep_entity_id
 	                     And tax_calendar_period = p_period_to) RPS3
 	               WHERE RPS1.vat_reporting_entity_id = p_vat_rep_entity_id
 	                 AND RPS2.vat_reporting_entity_id = RPS1.vat_reporting_entity_id
 	                 AND RPS3.vat_reporting_entity_id = RPS2.vat_reporting_entity_id
 	                 AND trunc(RPS1.period_start_date) >=
 	                                trunc(RPS2.period_start_date)
 	                 AND trunc(RPS1.period_end_date) <= trunc(RPS3.period_end_date)
 	               GROUP by RPS1.tax_calendar_period)
	-- Bug8267272 Start
    AND  ( JZVTD.trx_tax_balancing_segment = P_BALANCING_SEGMENT OR P_BALANCING_SEGMENT is NULL )
--  AND    JZVTD.tax_type_code             = P_TAX_TYPE -- Bug 6238170
    AND    JZVTD.reporting_code            = P_TAX_TYPE
    AND    JZVRS.source                    = 'AP'
    AND    JZVTD.reporting_status_id in (SELECT DISTINCT JZRS.reporting_status_id JZRS
					     FROM jg_zz_vat_rep_status JZRS
					     WHERE JZRS.vat_reporting_entity_id = P_VAT_REP_ENTITY_ID
					     AND   JZRS.source = 'AP')
    AND   JZVTD.gl_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date
   -- AND   JZVTD.tax_amt <> 0
    AND  ( (P_REGISTER_TYPE = 'BOTH') or
           (P_REGISTER_TYPE='NON RECOVERABLE TAX REGISTER' AND JZVTD.tax_recoverable_flag='N')
            or
           (P_REGISTER_TYPE='TAX REGISTER' AND JZVTD.tax_recoverable_flag='Y')
         );
  --AND    JZVTD.reporting_status_id       = JZVRS.reporting_status_id ;
  --AND    JZVTD.tax_invoice_date          BETWEEN JZVRS.period_start_date and JZVRS.period_end_date ;

BEGIN

FOR c_spanish_input_vat_data_rec IN c_spanish_input_vat
LOOP
      IF  c_spanish_input_vat_data_rec.trx_class_code='MISC_CASH_RECEIPT' THEN
        lc_customer :=c_spanish_input_vat_data_rec.bank_account_id  ;
        lc_tax_reg  :=c_spanish_input_vat_data_rec.banking_tp_taxpayer_id; /* taxpayer_id; Bug#5235824 */
       ELSIF c_spanish_input_vat_data_rec.trx_class_code='EXPENSE REPORTS' THEN
        lc_customer:=c_spanish_input_vat_data_rec.ap_taxable_merchant_name;
        lc_tax_reg:=c_spanish_input_vat_data_rec.ap_taxable_merchant_tax_reg_no;
      ELSE
        lc_customer:=c_spanish_input_vat_data_rec.billing_tp_name;
        lc_tax_reg:=c_spanish_input_vat_data_rec.billing_tp_tax_reg_num;
      END IF;

     IF c_spanish_input_vat_data_rec.ae_event_type_code = 'INVOICE CANCELLATION' THEN
        lc_ae_event_type_code := c_spanish_input_vat_data_rec.ae_event_type_code;
      ELSE
        lc_ae_event_type_code := 'JE_NORMAL';
      END IF;

    IF P_register_type = 'NON RECOVERABLE TAX REGISTER' AND c_spanish_input_vat_data_rec.tax2_accounted_amount IS NULL then
      NULL;
    ELSIF  c_spanish_input_vat_data_rec.taxable_line_type_code = 'PREPAY' and c_spanish_input_vat_data_rec.taxable_amount IS NULL then
      NULL;
    ELSE
      INSERT INTO jg_zz_vat_trx_gt(jg_info_v1
                                   ,jg_info_d1
                                   ,jg_info_v2
                                   ,jg_info_v3
                                   ,jg_info_v4
                                   ,jg_info_n1
                                   ,jg_info_v5
                                   ,jg_info_n2
                                   ,jg_info_v6
                                   ,jg_info_n3
                                   ,jg_info_n4
                                   ,jg_info_n5
                                   ,jg_info_n6
                                   ,jg_info_v7
                                   ,jg_info_v8
                                   ,jg_info_d2
                                   ,jg_info_v30
                                  )
                          VALUES (
                                    c_spanish_input_vat_data_rec.doc_seq
                                   ,c_spanish_input_vat_data_rec.trx_date
                                   ,DECODE (c_spanish_input_vat_data_rec.trx_class_code,'EXPENSE_REPORT',c_spanish_input_vat_data_rec.ap_taxable_merchant_doc_no,c_spanish_input_vat_data_rec.trx_number)
                                   ,SUBSTR(lc_customer,1,150)
                                   ,lc_tax_reg
                                  ,DECODE (c_spanish_input_vat_data_rec.trx_class_code,'MISC_CASH_RECEIPT',-c_spanish_input_vat_data_rec.taxable_amount,c_spanish_input_vat_data_rec.taxable_amount)
                                  ,c_spanish_input_vat_data_rec.tax_code
                                  ,c_spanish_input_vat_data_rec.tax_code_rate
                                  ,c_spanish_input_vat_data_rec.tax_code_description
                                 -- ,DECODE (c_spanish_input_vat_data_rec.trx_class_code,'MISC_CASH_RECEIPT',-c_spanish_input_vat_data_rec.tax1_accounted_amount,c_spanish_input_vat_data_rec.tax1_accounted_amount)
                                  ,c_spanish_input_vat_data_rec.tax1_accounted_amount
                                  ,c_spanish_input_vat_data_rec.tax2_accounted_amount
                                  ,DECODE (c_spanish_input_vat_data_rec.trx_class_code,'MISC_CASH_RECEIPT',-c_spanish_input_vat_data_rec.tax_amt,c_spanish_input_vat_data_rec.tax_amt)
                                  ,DECODE (c_spanish_input_vat_data_rec.trx_class_code,'MISC_CASH_RECEIPT',-c_spanish_input_vat_data_rec.taxable_amount - c_spanish_input_vat_data_rec.tax_accounted_amount
                                --,c_spanish_input_vat_data_rec.taxable_amount + c_spanish_input_vat_data_rec.tax_accounted_amount)
				  ,c_spanish_input_vat_data_rec.taxable_amount + c_spanish_input_vat_data_rec.tax_amt)
                                  ,c_spanish_input_vat_data_rec.extract_source_ledger
                                  ,lc_ae_event_type_code
                                  ,c_spanish_input_vat_data_rec.ah_accounting_date
                                  ,'JEESRPVP'
                                 );
      END IF;
  END LOOP;

  SELECT COUNT(*)
  INTO l_rec_count
  FROM jg_zz_vat_trx_gt
  WHERE jg_info_v30='JEESRPVP';

  IF p_debug_flag = 'Y' THEN
   fnd_file.put_line(fnd_file.log,'Number of records inserted into jg_zz_vat_trx_gt table: ' || l_rec_count );
  END IF ;

EXCEPTION
WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.log,'EXCEPTION' || SQLERRM || SQLCODE);
END jeesrpvp;

  --
  -- +======================================================================+
  -- Name: JOURNAL_AP
  --
  -- Description: This procedure used by the Extract when the Concurrent
  --              Program Journal_AP  is run.
  --
  -- Parameters:  P_VAT_REP_ENTITY_ID   => VAT Reporting Entity ID
  --              P_PERIOD              => Tax Calendar Year
  -- +======================================================================+
  --
PROCEDURE journal_ap(p_vat_rep_entity_id   IN    NUMBER
                     ,p_period             IN    VARCHAR2
                     ,x_err_msg            OUT NOCOPY  VARCHAR2)
IS
   CURSOR c_journal_ap IS
   SELECT JZVRS.tax_calendar_year                                             PERIOD_YEAR
         ,JZVTD.period_name                                                     PERIOD_NAME
         ,JZVTD.doc_seq_name                                                    SEQUENCE_NAME
         ,JZVTD.doc_seq_value                                                   SEQUENCE_NUMBER
         ,DECODE(JZVTD.doc_seq_id,null, JZVTD.period_name ,JZVTD.doc_seq_id)    DOCUMENT_SEQUENCE_ID
         ,FND_DATE.DATE_TO_DISPLAYDATE(JZVTD.trx_date)                          DOCUMENT_DATE
         ,JZVTD.billing_tp_number                                               VENDOR_NUM
         ,JZVTD.billing_tp_name                                                 VENDOR_NAME
         ,JZVTD.trx_number                                                      INVOICE_NUM
         ,NVL(JZVTD.TAXABLE_AMT_FUNCL_CURR,JZVTD.TAXABLE_AMT)                   INVOICE_AMOUNT
         ,DECODE(JZVTD.TRX_LINE_TYPE,'TAX' , 0,NVL(JZVTD.TAXABLE_AMT_FUNCL_CURR, JZVTD.TAXABLE_AMT))  TAXABLE_AMOUNT
         ,DECODE(JZVTD.TRX_LINE_TYPE,'TAX',NVL(JZVTD.TAXABLE_AMT_FUNCL_CURR,JZVTD.TAXABLE_AMT))   TAX_AMOUNT
         ,JZVTD.tax_rate_code                                                   VAT_CODE
         ,JZVTD.tax_rate_vat_trx_type_desc                                      VAT_TRT
         ,JZVBA.taxable_box                                                     VAT_REPORT_BOX
         ,JZVTD.trx_line_number                                                 LINE_NUM
         ,JZVTD.account_flexfield                                               FLEXDATA
         ,NVL(TAXABLE_AMT_FUNCL_CURR,TAXABLE_AMT)                               ACCTD_AMOUNT
         ,NVL(JZVTD.billing_tp_site_tax_reg_num,JZVTD.billing_tp_tax_reg_num)   VAT_NUM
         ,JZVTD.tax_rate_code_name                                              VAT_NAME
         ,JZVTD.tax_type_code                                                   TAX_TYPE
         ,JZVTD.tax_rate                                                        VAT_RATE
         ,JZVTD.tax_rate_code_description                                       VAT_DESC
         ,JZVTD.trx_id                                                          INVOICE_ID
         ,JZVTD.trx_currency_code                                               CURRENCY_CODE
         ,JZVTD.tax_recovery_rate                                               RECOVERY_RATE
         ,JZVTD.tax_recoverable_flag                                            TAX_RECOVERABLE_FLAG
         ,JZVTD.accounting_date                                                 ACCOUNTING_DATE
         ,NVL(JZVTD.taxable_amt,0)                                              TAXABLE_BASE_AMOUNT
         ,NVL(JZVTD.tax_amt,0)                                                  TAX_BASE_AMOUNT
         ,JZVTD.offset_tax_rate_code                                            OFFSET_TAX_CODE_ID
         ,NVL(JZVTD.merchant_party_name,JZVTD.billing_tp_name)                  VNAME
         ,NVL(JZVTD.start_expense_date,JZVTD.trx_date)                          INVOICE_DATE
         ,NVL(DECODE(JZVTD.tax_recoverable_flag,'Y',taxable_amt_funcl_curr),0)  TAXABLE_REC_BASE_AMOUNT
         ,NVL(DECODE(JZVTD.tax_recoverable_flag,'Y',taxable_amt) ,0)            TAXABLE_REC_AMOUNT
         ,NVL(DECODE(JZVTD.tax_recoverable_flag,'Y',tax_amt_funcl_curr),0)      TAX_REC_BASE_AMOUNT
         ,NVL(DECODE(JZVTD.tax_recoverable_flag,'Y',tax_amt),0)                 TAX_REC_AMOUNT
         ,NVL(DECODE(JZVTD.tax_recoverable_flag,'Y',taxable_amt_funcl_curr),0)  TAXABLE_NREC_BASE_AMOUNT
         ,NVL(DECODE(JZVTD.tax_recoverable_flag,'N',taxable_amt),0)             TAXABLE_NREC_AMOUNT
         ,NVL(DECODE(JZVTD.tax_recoverable_flag,'N',tax_amt_funcl_curr),0)      TAX_NREC_BASE_AMOUNT
         ,NVL(DECODE(JZVTD.tax_recoverable_flag,'Y',tax_amt) ,0)                TAX_NREC_AMOUNT
         ,JZVTD.gl_transfer_flag                                                INV_DIST_POSTED_FLAG
         ,JZVTD.doc_seq_name||'/'||JZVTD.doc_seq_value                          DOC_SEQUENCE_VALUE
         ,NVL(JZVTD.tax_amt, JZVTD.tax_amt_funcl_curr)                          TAX_AMT_ORIG
         ,JZVTD.trx_line_class                                                  INVOICE_TYPE
         ,JZVTD.tax_rate_id                                                     TAX_CODE_ID
         ,SUBSTR(NVL(JZVTD.merchant_party_name,JZVTD.billing_tp_name),1,13)     VAT_REGISTER_NAME
         ,JZVTD.tax_rate_code                                                   TAX_CODE
         ,JZVTD.merchant_party_document_number                                  AP_TAXABLE_MERCHANT_DOC_NO
         ,JZVTD.merchant_party_name                                             AP_TAXABLE_MERCHANT_NAME
         ,JZVTD.merchant_party_tax_reg_number                                   AP_TAXABLE_MERCHANT_TAX_REG_NO
         ,JZVTD.extract_source_ledger                                           EXTRACT_SOURCE_LEDGER
         ,JZVTD.actg_event_type_code                                            AE_EVENT_TYPE_CODE
         ,JZVTD.trx_line_type                                                   TAXABLE_LINE_TYPE_CODE
   FROM   jg_zz_vat_trx_details     JZVTD
         ,jg_zz_vat_rep_status      JZVRS
         ,jg_zz_vat_box_allocs      JZVBA
   WHERE JZVRS.tax_calendar_period      = P_PERIOD
   AND   JZVRS.vat_reporting_entity_id  = P_VAT_REP_ENTITY_ID
   AND   JZVRS.source                   = 'AP'
   AND   JZVRS.reporting_status_id      = JZVTD.reporting_status_id
   AND   JZVTD.vat_transaction_id       = JZVBA.vat_transaction_id  ;

BEGIN
l_rec_count:=0;
FOR c_journal_ap_rec IN c_journal_ap
LOOP
INSERT INTO jg_zz_vat_trx_gt(
                            jg_info_n29
                            ,jg_info_v2
                            ,jg_info_v3
                            ,jg_info_v24
                            ,jg_info_n2
                            ,jg_info_d1
                            ,jg_info_v26
                            ,jg_info_v4
                            ,jg_info_v27
                            ,jg_info_n5
                            ,jg_info_n6
                            ,jg_info_n7
                            ,jg_info_v5
                            ,jg_info_v6
                            ,jg_info_v7
                            ,jg_info_n10
                            ,jg_info_n11
                            ,jg_info_v8
                            ,jg_info_n12
                            ,jg_info_n13
                            ,jg_info_v9
                            ,jg_info_v10
                            ,jg_info_n14
                            ,jg_info_v11
                            ,jg_info_n15
                            ,jg_info_v12
                            ,jg_info_v13
                            ,jg_info_v14
                            ,jg_info_d2
                            ,jg_info_n16
                            ,jg_info_n17
                            ,jg_info_v28
                            ,jg_info_d3
                            ,jg_info_n19
                            ,jg_info_n20
                            ,jg_info_n21
                            ,jg_info_n22
                            ,jg_info_n23
                            ,jg_info_n24
                            ,jg_info_n25
                            ,jg_info_n26
                            ,jg_info_v15
                            ,jg_info_v16
                            ,jg_info_n27
                            ,jg_info_v29
                            ,jg_info_v17
                            ,jg_info_v18
                            ,jg_info_v19
                            ,jg_info_v20
                            ,jg_info_v21
                            ,jg_info_v22
                            ,jg_info_v23
                            ,jg_info_v25
                            ,jg_info_v30
                            )
                             VALUES (
                            c_journal_ap_rec.period_year
                            ,c_journal_ap_rec.period_name
                            ,c_journal_ap_rec.sequence_name
                            ,c_journal_ap_rec.sequence_number
                            ,c_journal_ap_rec.document_sequence_id
                            ,c_journal_ap_rec.document_date
                            ,c_journal_ap_rec.vendor_num
                            ,c_journal_ap_rec.vendor_name
                            ,c_journal_ap_rec.invoice_num
                            ,c_journal_ap_rec.invoice_amount
                            ,c_journal_ap_rec.taxable_amount
                            ,c_journal_ap_rec.tax_amount
                            ,c_journal_ap_rec.vat_code
                            ,c_journal_ap_rec.vat_trt
                            ,c_journal_ap_rec.vat_report_box
                            ,c_journal_ap_rec.tax_nrec_amount
                            ,c_journal_ap_rec.line_num
                            ,c_journal_ap_rec.flexdata
                            ,c_journal_ap_rec.acctd_amount
                            ,c_journal_ap_rec.vat_num
                            ,c_journal_ap_rec.vat_name
                            ,c_journal_ap_rec.tax_type
                            ,c_journal_ap_rec.vat_rate
                            ,c_journal_ap_rec.vat_desc
                            ,c_journal_ap_rec.invoice_id
                            ,c_journal_ap_rec.currency_code
                            ,c_journal_ap_rec.recovery_rate
                            ,c_journal_ap_rec.tax_recoverable_flag
                            ,c_journal_ap_rec.accounting_date
                            ,c_journal_ap_rec.taxable_base_amount
                            ,c_journal_ap_rec.tax_base_amount
                            ,c_journal_ap_rec.offset_tax_code_id
                            ,c_journal_ap_rec.invoice_date
                            ,c_journal_ap_rec.taxable_rec_base_amount
                            ,c_journal_ap_rec.taxable_rec_amount
                            ,c_journal_ap_rec.tax_rec_base_amount
                            ,c_journal_ap_rec.tax_rec_amount
                            ,c_journal_ap_rec.taxable_nrec_base_amount
                            ,c_journal_ap_rec.taxable_nrec_amount
                            ,c_journal_ap_rec.tax_nrec_base_amount
                            ,c_journal_ap_rec.tax_nrec_amount
                            ,c_journal_ap_rec.inv_dist_posted_flag
                            ,c_journal_ap_rec.doc_sequence_value
                            ,c_journal_ap_rec.tax_amt_orig
                            ,c_journal_ap_rec.invoice_type
                            ,c_journal_ap_rec.vat_register_name
                            ,c_journal_ap_rec.tax_code
                            ,c_journal_ap_rec.ap_taxable_merchant_doc_no
                            ,c_journal_ap_rec.ap_taxable_merchant_name
                            ,c_journal_ap_rec.ap_taxable_merchant_tax_reg_no
                            ,c_journal_ap_rec.extract_source_ledger
                            ,c_journal_ap_rec.ae_event_type_code
                            ,c_journal_ap_rec.taxable_line_type_code
                            ,'JOURNAL_AP'
                            );
END LOOP;

  SELECT COUNT(*) INTO l_rec_count
  FROM jg_zz_vat_trx_gt
  WHERE jg_info_v30='JOURNAL_AP';

  IF p_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Number of records inserted into jg_zz_vat_trx_gt table: ' || l_rec_count );
  END IF ;
EXCEPTION
WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.log,'EXCEPTION' || SQLERRM || SQLCODE);
END journal_ap;

FUNCTION lcu_trans_line_tax_amt (P_TRX_ID IN NUMBER) RETURN NUMBER IS
ln_tax_amt_funcl_curr  NUMBER;
BEGIN
SELECT SUM(decode(JZVTD.tax_recoverable_flag, 'Y',
           nvl(JZVTD.tax_amt,JZVTD.tax_amt_funcl_curr),'N', 0 )) /* Bug#5235824 JZVTD.tax_amt_funcl_curr */
INTO   ln_tax_amt_funcl_curr
FROM    jg_zz_vat_trx_details   JZVTD
WHERE  JZVTD.TRX_ID = P_TRX_ID
AND    JZVTD.extract_source_ledger in ('AP') /* AND JZVTD.posted_flag = 'P'  Bug#5235824 */
GROUP BY JZVTD.TRX_LINE_ID;

RETURN ln_tax_amt_funcl_curr;

EXCEPTION
WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.log,'EXCEPTION' || SQLERRM || SQLCODE);
RETURN 0;
END lcu_trans_line_tax_amt;


FUNCTION lcu_trans_line_taxable_amt (p_trx_id IN NUMBER) RETURN NUMBER IS
ln_taxable_amt_funcl_curr  NUMBER;
BEGIN
SELECT SUM (decode(JZVTD.tax_recoverable_flag, 'Y',
             nvl(JZVTD.taxable_amt,JZVTD.taxable_amt_funcl_curr), 'N', 0)) /* Bug#5235824 JZVTD.taxable_amt_funcl_curr */
INTO   ln_taxable_amt_funcl_curr
FROM    jg_zz_vat_trx_details   JZVTD
WHERE  JZVTD.TRX_ID                = P_TRX_ID
AND    JZVTD.extract_source_ledger = 'AP'     /* AND JZVTD.posted_flag ='P'  Bug#5235824 */
GROUP BY JZVTD.trx_line_id;

RETURN ln_taxable_amt_funcl_curr;

EXCEPTION
WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.log,'EXCEPTION' || SQLERRM || SQLCODE);
RETURN 0;
END lcu_trans_line_taxable_amt;

FUNCTION lcu_trans_line_tax_taxable_amt (p_trx_id IN NUMBER) RETURN NUMBER IS
ln_taxable_amt_funcl_curr  NUMBER;
BEGIN
SELECT  SUM(decode(JZVTD.tax_recoverable_flag, 'Y', nvl(JZVTD.tax_amt,JZVTD.tax_amt_funcl_curr),'N', 0 ))
        + SUM (decode(JZVTD.tax_recoverable_flag, 'Y', nvl(JZVTD.taxable_amt,JZVTD.taxable_amt_funcl_curr), 'N', 0))
        /* Bug#5235824. SUM (JZVTD.tax_amt_funcl_curr)+ SUM (JZVTD.taxable_amt_funcl_curr) */
INTO   ln_taxable_amt_funcl_curr
FROM   jg_zz_vat_trx_details   JZVTD
WHERE  JZVTD.TRX_ID                = P_TRX_ID
AND    JZVTD.extract_source_ledger = 'AP'     /* AND JZVTD.posted_flag = 'P'  Bug#5235824 */
GROUP BY JZVTD.trx_line_id;

RETURN ln_taxable_amt_funcl_curr;

EXCEPTION
WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.log,'EXCEPTION' || SQLERRM || SQLCODE);
RETURN 0;
END lcu_trans_line_tax_taxable_amt;


 FUNCTION get_current_date RETURN VARCHAR2
 IS
 BEGIN
   fnd_file.put_line(fnd_file.log,'Calling Current Date Conversions');
   RETURN fnd_date.date_to_charDT(sysdate);
  END get_current_date;


FUNCTION get_sequence_number RETURN NUMBER IS
l_start_seq NUMBER;
BEGIN
    IF p_report_name = 'JEITAPPV' or p_report_name = 'JEITAPSR' THEN
      SELECT jg_info_n1
      INTO l_start_seq
      FROM jg_zz_vat_trx_gt
      WHERE jg_info_v30 = 'SEQ';

      RETURN l_start_seq;
    ELSE
      RETURN 0;
    END IF;
EXCEPTION
   WHEN others THEN
     RETURN 0;
END get_sequence_number;

END JG_ZZ_JOURNAL_AP_PKG;

/
