--------------------------------------------------------
--  DDL for Package Body JG_ZZ_JOURNAL_AR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_JOURNAL_AR_PKG" 
/*  $Header: jgzzjournalarb.pls 120.22.12010000.5 2009/12/18 10:27:34 rahulkum ship $ */
AS
--

-- +======================================================================+
-- Name: GET_START_SEQUENCE
--
-- Description: This function is private to this package. It is called to
--              get the start_sequence_num for the report JEITARSV and JEITRDVR
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


/*  +======================================================================+
 Name: BEFORE_REPORT

 Description: This function is called as a before report trigger by the
              data template. It populates the data in the global_tmp table
              and creates the dynamic where clause for the data template
              queries(lexical reference).

 Parameters:   None
 +======================================================================+
*/

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
   l_registration_num              VARCHAR2 (30);
   l_reporting_status              VARCHAR2 (60);
   l_to_reporting_status           VARCHAR2 (60); -- Bug8267272
   l_tax_payer_id                  VARCHAR2 (60);
   l_tax_registration_num          VARCHAR2 (240);
   l_to_tax_registration_num       VARCHAR2 (240);-- Bug8267272
   l_tax_regime                    VARCHAR2(240);
   l_vat_register_name             VARCHAR2(500);
   l_sequence_start		   NUMBER;
   l_start_seq                     NUMBER;
 -- Added for Glob-006 ER
   l_province                      VARCHAR2(120);
   l_comm_num                      VARCHAR2(30);
   l_vat_reg_num                   VARCHAR2(50);

 BEGIN

     IF p_report_name = 'JEITARSV' THEN
       fnd_file.put_line(fnd_file.log,'**********************************************************');
       fnd_file.put_line(fnd_file.log,'Italian Receivables Sales VAT Register');
       fnd_file.put_line(fnd_file.log,'**********************************************************');
       fnd_file.put_line(fnd_file.log,'');
       fnd_file.put_line(fnd_file.log,'Report Parameters');
       fnd_file.put_line(fnd_file.log,'Tax Registraion Number  : '||p_vat_rep_entity_id);
       fnd_file.put_line(fnd_file.log,'Tax Calendar Year       : '||p_period);
       fnd_file.put_line(fnd_file.log,'VAT Register Id         : '||p_vat_register_id);
       fnd_file.put_line(fnd_file.log,'**********************************************************');
       fnd_file.put_line(fnd_file.log,'');
       fnd_file.put_line(fnd_file.log,'');

      BEGIN

         SELECT register_name
         INTO   l_vat_register_name
         FROM   jg_zz_vat_registers_vl jzvr
               ,jg_zz_vat_rep_entities   jzvre
         WHERE  ((jzvre.vat_reporting_entity_id   = P_VAT_REP_ENTITY_ID
                   and
                   jzvre.entity_type_code          = 'ACCOUNTING'
                   and
                   jzvre.mapping_vat_rep_entity_id = jzvr.vat_reporting_entity_id
                   )
                   OR
                   (jzvre.vat_reporting_entity_id   = P_VAT_REP_ENTITY_ID
                   and
                   jzvre.entity_type_code          = 'LEGAL'
                   and
                   jzvre.vat_reporting_entity_id  = jzvr.vat_reporting_entity_id
                ))  --OR P_VAT_REP_ENTITY_ID is null
		AND jzvr.vat_register_id = p_vat_register_id
                AND jzvr.register_type = 'SALES_VAT' ;
       EXCEPTION
         WHEN OTHERS THEN
         fnd_file.put_line(fnd_file.log,'An error occured in the before report trigger, while fetching the VAT Register name. Exception : ' || SUBSTR(SQLERRM,1,200) || SQLCODE);
         raise;
         RETURN(FALSE);
       END;

     END IF;

     IF p_report_name = 'JEITRDVR' THEN
       fnd_file.put_line(fnd_file.log,'**********************************************************');
       fnd_file.put_line(fnd_file.log,'Italian Receivables Deferred VAT Register');
       fnd_file.put_line(fnd_file.log,'**********************************************************');
       fnd_file.put_line(fnd_file.log,'');
       fnd_file.put_line(fnd_file.log,'Report Parameters');
       fnd_file.put_line(fnd_file.log,'Tax Registraion Number  : '||p_vat_rep_entity_id);
       fnd_file.put_line(fnd_file.log,'Tax Calendar Year       : '||p_period);
       fnd_file.put_line(fnd_file.log,'VAT Register Id         : '||p_vat_register_id);
       fnd_file.put_line(fnd_file.log,'**********************************************************');
       fnd_file.put_line(fnd_file.log,'');
       fnd_file.put_line(fnd_file.log,'');

       BEGIN

         SELECT register_name
         INTO   l_vat_register_name
         FROM   jg_zz_vat_registers_vl jzvr
               ,jg_zz_vat_rep_entities   jzvre
         WHERE  ((jzvre.vat_reporting_entity_id   = P_VAT_REP_ENTITY_ID
                   and
                   jzvre.entity_type_code          = 'ACCOUNTING'
                   and
                   jzvre.mapping_vat_rep_entity_id = jzvr.vat_reporting_entity_id
                   )
                   OR
                   (jzvre.vat_reporting_entity_id   = P_VAT_REP_ENTITY_ID
                   and
                   jzvre.entity_type_code          = 'LEGAL'
                   and
                   jzvre.vat_reporting_entity_id  = jzvr.vat_reporting_entity_id
                   )) --OR P_VAT_REP_ENTITY_ID is null
		   AND  jzvr.vat_register_id = p_vat_register_id
                   AND  jzvr.register_type = 'DEFERRED_VAT';

         EXCEPTION
         WHEN OTHERS THEN
         fnd_file.put_line(fnd_file.log,'An error occured in the before report trigger, while fetching the VAT Register name. Exception : ' || SUBSTR(SQLERRM,1,200) || SQLCODE);
         raise;
         RETURN(FALSE);
       END;

    END IF;

    fnd_file.put_line(fnd_file.log,'before Report Trigger');
    jg_zz_common_pkg.funct_curr_legal(x_func_curr_code       => l_func_curr
                                    ,x_rep_entity_name      => l_legal_entity_name
                                    ,x_legal_entity_id      => l_legal_entity_id
                                    ,x_taxpayer_id          => l_tax_payer_id
                                    ,pn_vat_rep_entity_id   => p_vat_rep_entity_id
                                    ,pv_period_name         => p_period);

	fnd_file.put_line(fnd_file.log,'Calling jg_zz_common_pkg.tax_registration');
	-- Bug8267272 Start
	IF P_REPORT_NAME = 'JEESRRVR' THEN
    jg_zz_common_pkg.tax_registration(x_tax_registration     => l_tax_registration_num
                                    ,x_period_start_date    => l_period_start_date
                                    ,x_period_end_date      => l_period_end_date
                                    ,x_status               => l_reporting_status
                                    ,pn_vat_rep_entity_id   => p_vat_rep_entity_id
                                    ,pv_period_name         => p_period
                                    ,pv_source              => 'ALL');
	jg_zz_common_pkg.tax_registration(x_tax_registration     => l_to_tax_registration_num
                                    ,x_period_start_date    => l_to_period_start_date
                                    ,x_period_end_date      => l_to_period_end_date
                                    ,x_status               => l_to_reporting_status
                                    ,pn_vat_rep_entity_id   => p_vat_rep_entity_id
                                    ,pv_period_name         => p_period_to
                                    ,pv_source              => 'ALL');
	ELSE
    jg_zz_common_pkg.tax_registration(x_tax_registration     => l_tax_registration_num
                                    ,x_period_start_date    => l_period_start_date
                                    ,x_period_end_date      => l_period_end_date
                                    ,x_status               => l_reporting_status
                                    ,pn_vat_rep_entity_id   => p_vat_rep_entity_id
                                    ,pv_period_name         => p_period
                                    ,pv_source              => 'ALL');
	end if;
	-- Bug8267272 End

   fnd_file.put_line(fnd_file.log,'Calling jg_zz_common_pkg.company_detail');
  jg_zz_common_pkg.company_detail(x_company_name            => l_company_name
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

    IF P_REPORT_NAME = 'JEITARSV' OR P_REPORT_NAME = 'JEITRDVR' THEN
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

	fnd_file.put_line(fnd_file.log,'P_REPORT_NAME    :'||P_REPORT_NAME);
	fnd_file.put_line(fnd_file.log,'P_SEQUENCE    :'||P_SEQUENCE);
	fnd_file.put_line(fnd_file.log,'l_period_start_date    :'||l_period_start_date);
	fnd_file.put_line(fnd_file.log,'l_period_end_date    :'||l_period_end_date);

	IF P_REPORT_NAME = 'JEESRRVR' THEN
		IF P_SEQUENCE = 'Y' THEN
		BEGIN
		/*select	count ( distinct ctl.customer_trx_id )
				into 	l_sequence_start
			from	ra_customer_trx_lines	ctl,
			        ra_customer_trx  		ct,
				zx_rates_b			zxb,
			        zx_taxes_b		    ztb,
				zx_report_codes_assoc          zxass
			where	ctl.vat_tax_id = zxb.tax_rate_id
			and     zxb.tax = ztb.tax
			and	zxb.tax_regime_code = ztb.tax_regime_code
			and	zxb.content_owner_id = ztb.content_owner_id
			and     zxb.tax_rate_id      = zxass.entity_id
			and     zxass.entity_code = 'ZX_RATES'
			and	 DECODE(ztb.offset_tax_flag,'Y','OFFSET',
                                          Decode(zxb.def_rec_settlement_option_code,
                                                'DEFERRED','DEFERRED',
                                                 zxass.REPORTING_CODE_CHAR_VALUE))= P_TAX_TYPE
			and     ct.customer_trx_id = ctl.customer_trx_id
			and	not exists (select 'x'
						from 	ra_cust_trx_line_gl_dist 	gld
						where 	gld.customer_trx_line_id = ctl.customer_trx_line_id
						and 	gld.gl_posted_date is null)
			and 	l_period_start_date >all
					(select trx_date
						from ra_customer_trx ct
						where 	ct.customer_trx_id = ctl.customer_trx_id )
			and	trunc(l_period_start_date,'YYYY') <= all
					(select trx_date
					from ra_customer_trx ct
					where 	ct.customer_trx_id = ctl.customer_trx_id );
                    */

		    SELECT count ( distinct JZVTD.trx_id )
		            INTO l_sequence_start
                            FROM    jg_zz_vat_trx_details       JZVTD
                                    ,jg_zz_vat_rep_status        JZVRS

                            WHERE   JZVTD.reporting_status_id in (SELECT DISTINCT JZRS.reporting_status_id JZRS
			                        		     FROM jg_zz_vat_rep_status JZRS
					                             WHERE JZRS.vat_reporting_entity_id = P_VAT_REP_ENTITY_ID
					                                   AND   JZRS.source = 'AR')
                            AND     JZVTD.gl_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date
                            AND     JZVRS.source                        = 'AR'
                            AND     ((JZVTD.tax_rate_register_type_code = 'TAX' AND P_TAX_REGISTER_TYPE = 'TAX')
                            OR  (JZVTD.tax_rate_register_type_code = 'INTERIM' AND P_TAX_REGISTER_TYPE = 'INTERIM')
                            OR  (JZVTD.tax_rate_register_type_code = 'NON-RECOVERABLE' AND P_TAX_REGISTER_TYPE = 'NON-RECOVERABLE'))
                            AND     ( JZVTD.trx_tax_balancing_segment = P_BALANCING_SEGMENT OR P_BALANCING_SEGMENT is NULL )
                            AND     JZVRS.vat_reporting_entity_id       = P_VAT_REP_ENTITY_ID
                            AND     JZVRS.reporting_status_id in ( SELECT reporting_status_id FROM jg_zz_vat_rep_status
                                            WHERE period_start_date < l_period_start_date
                                            AND vat_reporting_entity_id = P_VAT_REP_ENTITY_ID
                                            AND source='AR')
                            AND     trunc(l_period_start_date,'YYYY') <= all
                                        (select trx_date from jg_zz_vat_trx_details A
				                     where A.trx_id = JZVTD.trx_id );

			fnd_file.put_line(fnd_file.log,'l_sequence_start    :'||l_sequence_start);

		EXCEPTION
		  WHEN NO_DATA_FOUND THEN
		   l_sequence_start := 0;
		   WHEN OTHERS THEN
		   fnd_file.put_line(fnd_file.log,'An error occured while calculating the l_sequence_start. Exception : ' || SUBSTR(SQLERRM,1,200) || SQLCODE);
		END;
		ELSE
		   l_sequence_start := 0;
		END IF;
	END IF;
    INSERT INTO jg_zz_vat_trx_gt
     (
      jg_info_n1
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
    (
       l_legal_entity_id
      ,l_company_name
      ,l_company_name         --l_legal_entity_name
      ,l_tax_registration_num --l_registration_num
      ,l_registration_num     --l_tax_payer_id
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
      ,decode(nvl(P_REPORT_NAME,'ZZ'),'JEESRRVR',l_to_period_end_date,l_period_end_date)
      ,l_period_start_date
      ,l_sequence_start
      ,'H'
      ,l_province
      ,l_comm_num
      ,l_vat_reg_num
  );

    IF P_REPORT_NAME = 'JEBEDV07' THEN
      fnd_file.put_line(fnd_file.log,'Calling jebedv07');
      jebedv07(p_vat_rep_entity_id            => p_vat_rep_entity_id
               ,p_period                      => p_period
               ,p_document_sequence_name_from => p_document_sequence_name_from
               ,p_document_sequence_name_to   => p_document_sequence_name_to
               ,p_customer_name_from          => p_customer_name_from
               ,p_customer_name_to            => p_customer_name_to
               ,p_detail_summary              => p_detail_summary
               ,x_err_msg                     => l_err_msg);
      fnd_file.put_line(fnd_file.log,'After Calling jebedv07');
    ELSIF P_REPORT_NAME = 'JEITARSV' THEN
      fnd_file.put_line(fnd_file.log,'Calling jeitarsv');
      jeitarsv(p_vat_rep_entity_id  => p_vat_rep_entity_id
               ,p_period            => p_period
               ,p_vat_register_id   => p_vat_register_id
               ,x_err_msg           => l_err_msg);
      fnd_file.put_line(fnd_file.log,'After Calling jeitarsv');
    ELSIF P_REPORT_NAME = 'JEITRDVR' THEN
      fnd_file.put_line(fnd_file.log,'Calling jeitrdvr');
      jeitrdvr(p_vat_rep_entity_id  => p_vat_rep_entity_id
               ,p_period            => p_period
               ,p_vat_register_id   => p_vat_register_id
               ,x_err_msg           => l_err_msg);
      fnd_file.put_line(fnd_file.log,'After Calling jeitrdvr');
    ELSIF P_REPORT_NAME = 'JEESRRVR' THEN
      fnd_file.put_line(fnd_file.log,'Calling jeesrrvr');
      fnd_file.put_line(fnd_file.log,'--PARAMETERS--');
      fnd_file.put_line(fnd_file.log,'P_VAT_REP_ENTITY_ID     :'||P_VAT_REP_ENTITY_ID);
      fnd_file.put_line(fnd_file.log,'P_PERIOD                :'||P_PERIOD);
      fnd_file.put_line(fnd_file.log,'P_TAX_TYPE              :'||P_TAX_TYPE);
      fnd_file.put_line(fnd_file.log,'P_TAX_REGISTER_TYPE     :'||P_TAX_REGISTER_TYPE );
      fnd_file.put_line(fnd_file.log,'P_CHART_OF_ACCOUNT_ID   :'||P_CHART_OF_ACCOUNT_ID);
      fnd_file.put_line(fnd_file.log,'P_BALANCING_SEGMENT     :'||P_BALANCING_SEGMENT );
      fnd_file.put_line(fnd_file.log,'P_SEQUENCE              :'||P_SEQUENCE);

      jeesrrvr(p_vat_rep_entity_id  => p_vat_rep_entity_id
               ,p_period            => p_period
			   ,p_period_to         => p_period_to -- Bug8267272
               ,p_tax_type          => p_tax_type
               ,p_tax_register_type => p_tax_register_type
               ,p_sequence          => p_sequence
               ,x_err_msg           => l_err_msg);
      fnd_file.put_line(fnd_file.log,'After Calling jeesrrvr');
    ELSIF (P_REPORT_NAME = 'JOURNAL-AR' OR P_REPORT_NAME IS NOT NULL) THEN
      fnd_file.put_line(fnd_file.log,'Calling journal_ar');
      NULL;
      fnd_file.put_line(fnd_file.log,'After Calling journal_ar');
    END IF;
    RETURN (TRUE);
  EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'An error occured in the before report trigger. Exception : ' || SUBSTR(SQLERRM,1,200) || SQLCODE);
    raise;
    RETURN(FALSE);
  END beforeReport;

  --
  -- +======================================================================+
  -- Name: JEBEDV07
  --
  -- Description: This procedure used by the Extract when the Concurrent
  --              Program 'Belgian VAT Sales Journal Report' is run.
  --
  -- Parameters:  P_VAT_REP_ENTITY_ID            => VAT Reporting Entity ID
  --              P_PERIOD                       => Tax Calendar Year
  --              P_DOCUMENT_SEQUENCE_NAME_FROM  => Document Sequence Name From
  --              P_DOCUMENT_SEQUENCE_NAME_TO    => Document Sequence Name To
  --              P_CUSTOMER_NAME_FROM           => Customer Name From
  --              P_CUSTOMER_NAME_TO             => Customer Name To
  --              P_DETAIL_SUMMARY               => Detail Summary
  -- +======================================================================+
  --
  PROCEDURE jebedv07(p_vat_rep_entity_id            IN    NUMBER
                     ,p_period                      IN    VARCHAR2
                     ,p_document_sequence_name_from IN    NUMBER
                     ,p_document_sequence_name_to   IN    NUMBER
                     ,p_customer_name_from          IN    VARCHAR2
                     ,p_customer_name_to            IN    VARCHAR2
                     ,p_detail_summary              IN    VARCHAR2
                     ,x_err_msg                     OUT   NOCOPY VARCHAR2)
  IS
    CURSOR c_invoice IS
      SELECT  JZVRS.tax_calendar_year                           PERIOD_YEAR
             ,JZVRS.tax_calendar_period                         PERIOD_NAME
             ,JZVTD.doc_seq_name                                DOCUMENT_SEQUENCE_NAME
             ,JZVTD.doc_seq_value                               DOCUMENT_SEQUENCE_NUMBER
             ,JZVTD.trx_date                                    INVOICE_DATE
             ,SUBSTR(JZVTD.billing_tp_number,1,11)              CUSTOMER_NUMBER
             ,SUBSTR(JZVTD.billing_tp_name,1,18)                CUSTOMER_NAME
             ,JZVTD.trx_number                                  INVOICE_NUMBER
             ,NVL(JZVTD.tax_amt_funcl_curr,0) * to_number
                                                      (decode
                                                         ( jzvtd.tax_recoverable_flag
                                                         , 'Y', jzvar.tax_rec_sign_flag  /* can be '+' or '-' */
                                                         ,jzvar.tax_non_rec_sign_flag
                                                         )||'1'
                                                      )         VAT_AMOUNT_FUNCL_CURR
             ,NVL(JZVTD.taxable_amt_funcl_curr,0) * to_number
                                                      (decode
                                                         ( jzvtd.tax_recoverable_flag
                                                         , 'Y', jzvar.taxable_rec_sign_flag /* can be '+' or '-' */
                                                         ,jzvar.taxable_non_rec_sign_flag
                                                         )||'1'
                                                      )        INV_AMT_WO_VAT_FUN_CURR
             ,(
                NVL(JZVTD.tax_amt_funcl_curr,0) * to_number
                                                      (decode
                                                         ( jzvtd.tax_recoverable_flag
                                                         , 'Y', jzvar.tax_rec_sign_flag  /* can be '+' or '-' */
                                                         ,jzvar.tax_non_rec_sign_flag
                                                         )||'1'
                                                      )
	            + NVL(JZVTD.taxable_amt_funcl_curr,0) * to_number
                                                      (decode
                                                         ( jzvtd.tax_recoverable_flag
                                                         , 'Y', jzvar.taxable_rec_sign_flag /* can be '+' or '-' */
                                                         ,jzvar.taxable_non_rec_sign_flag
                                                         )||'1'
                                                      )
               )                                                TOT_INV_AMT_W_VAT_FUN_CURR
             ,JZVTD.trx_line_type                               LINE_TYPE
             ,JZVTD.trx_line_number                             LINE_NUMBER
             ,JZVTD.account_flexfield                           ACCOUNT_FLEXFIELD
             ,JZVTD.trx_control_account_flexfield               TAXABLE_ACCT_FLEXFIELD
             ,JZVTD.account_description                         ACCOUNT_DESCRIPTION
             ,FA_RX_FLEX_PKG.GET_DESCRIPTION ( 101, 'GL#',
                   (select chart_of_accounts_id from gl_ledgers where ledger_id = JZVTD.ledger_id),
                   'ALL', JZVTD.trx_control_account_flexfield )   TXBL_ACCT_DESCRIPTION
             ,NVL(JZVTD.trx_line_amt,0)                         ACCTD_AMOUNT
             ,NVL(JZVTD.tax_amt_funcl_curr,0)                   ACCTD_VAT_AMT
             ,NVL(JZVTD.taxable_amt_funcl_curr,0)               ACCTD_INV_AMT
             ,NVL(JZVTD.tax_amt_funcl_curr,0)
                + NVL(JZVTD.taxable_amt_funcl_curr,0)           ACCTD_TOT_AMT
             ,JZVTD.tax_rate_code                               VAT_CODE
             ,JZVTD.tax_rate_vat_trx_type_desc                  VAT_TRX_TYPE
             ,NVL(JZVBA.taxable_box, '99')                      VAT_TAXABLE_BOX
             ,NVL(JZVBA.tax_box, '99')                          VAT_TAX_BOX
             ,NVL(JZVTD.tax_amt_funcl_curr,0)    * to_number
                                                      (decode
                                                         ( jzvtd.tax_recoverable_flag
                                                         , 'Y', jzvar.tax_rec_sign_flag  /* can be '+' or '-' */
                                                         ,jzvar.tax_non_rec_sign_flag
                                                         )||'1'
                                                      )         TAX_AMOUNT
             ,NVL(JZVTD.taxable_amt_funcl_curr,0) * to_number
                                                      (decode
                                                         ( jzvtd.tax_recoverable_flag
                                                         , 'Y', jzvar.taxable_rec_sign_flag /* can be '+' or '-' */
                                                         ,jzvar.taxable_non_rec_sign_flag
                                                         )||'1'
                                                      )         TAXABLE_AMOUNT
             ,NVL(JZVTD.taxable_amt_funcl_curr,0) * to_number
                                                      (decode
                                                         ( jzvtd.tax_recoverable_flag
                                                         , 'Y', jzvar.taxable_rec_sign_flag /* can be '+' or '-' */
                                                         ,jzvar.taxable_non_rec_sign_flag
                                                         )||'1'
                                                      )         TAXABLE_AMT_FUN_CURR
             ,NVL(JZVTD.tax_amt_funcl_curr,0)    * to_number
                                                      (decode
                                                         ( jzvtd.tax_recoverable_flag
                                                         , 'Y', jzvar.tax_rec_sign_flag  /* can be '+' or '-' */
                                                         ,jzvar.tax_non_rec_sign_flag
                                                         )||'1'
                                                      )        TAX_AMT_FUN_CURR
      FROM   jg_zz_vat_trx_details       JZVTD
            ,jg_zz_vat_rep_status        JZVRS
            ,jg_zz_vat_box_allocs        JZVBA
            ,ra_cust_trx_types           RCTT
            ,jg_zz_vat_alloc_rules       jzvar
      WHERE JZVTD.reporting_status_id     = JZVRS.reporting_status_id
      AND   RCTT.cust_trx_type_id         = JZVTD.trx_type_id
      AND   JZVTD.vat_transaction_id      = JZVBA.vat_transaction_id
      AND   JZVBA.period_type             = 'PERIODIC'
      AND   JZVRS.source                  = 'AR'
      AND   JZVAR.ALLOCATION_RULE_ID      = JZVBA.ALLOCATION_RULE_ID
      AND   RCTT.type IN ('INV','CM','DM','CB','DEP','GUAR')
      AND   (JZVTD.billing_tp_name BETWEEN NVL(P_customer_name_from, JZVTD.billing_tp_name)
                                   AND     NVL(P_customer_name_to, JZVTD.billing_tp_name))
      AND    (  (P_document_sequence_name_from is null and P_document_sequence_name_to is null)
               or (P_document_sequence_name_from is not null and JZVTD.doc_seq_name >= P_document_sequence_name_from)
               or (P_document_sequence_name_to is not null and JZVTD.doc_seq_name <= P_document_sequence_name_to)
             )
      AND    JZVRS.tax_calendar_period     = P_PERIOD
      AND    JZVRS.vat_reporting_entity_id = P_VAT_REP_ENTITY_ID;

      l_invoice      c_invoice%ROWTYPE;

   BEGIN
     OPEN c_invoice;
     LOOP
       FETCH c_invoice INTO l_invoice;
       EXIT WHEN c_invoice%NOTFOUND;
       INSERT INTO jg_zz_vat_trx_gt
             (
                jg_info_n1
                , jg_info_v1
                , jg_info_v2
                , jg_info_v3
                , jg_info_d1
                , jg_info_v4
                , jg_info_v5
                , jg_info_v6
                , jg_info_n2
                , jg_info_n3
                , jg_info_n4
                , jg_info_v7
                , jg_info_n5 --line_number
                , jg_info_v8
                , jg_info_v14
                , jg_info_v9
                , jg_info_v15
                , jg_info_n6
                , jg_info_n11
                , jg_info_n12
                , jg_info_n13
                , jg_info_v10
                , jg_info_v11
                , jg_info_v12 -- vat_taxable_box
		, jg_info_v13 -- vat_tax_box
                , jg_info_n7
                , jg_info_n8
                , jg_info_n9
                , jg_info_n10
              )
       VALUES(
                  l_invoice.period_year
                , l_invoice.period_name
                , l_invoice.document_sequence_name
                , l_invoice.document_sequence_number
                , l_invoice.invoice_date
                , l_invoice.customer_number
                , l_invoice.customer_name
                , l_invoice.invoice_number
                , l_invoice.vat_amount_funcl_curr
                , l_invoice.inv_amt_wo_vat_fun_curr
                , l_invoice.tot_inv_amt_w_vat_fun_curr
                , l_invoice.line_type
                , l_invoice.line_number
                , l_invoice.account_flexfield
                , l_invoice.taxable_acct_flexfield
                , l_invoice.account_description
                , l_invoice.txbl_acct_description
                , l_invoice.acctd_amount
                , l_invoice.acctd_vat_amt
                , l_invoice.acctd_inv_amt
                , l_invoice.acctd_tot_amt
                , l_invoice.vat_code
                , l_invoice.vat_trx_type
                , l_invoice.vat_taxable_box
                , l_invoice.vat_tax_box
                , l_invoice.tax_amount
                , l_invoice.taxable_amount
                , l_invoice.taxable_amt_fun_curr
                , l_invoice.tax_amt_fun_curr
              );

     END LOOP;

    EXCEPTION
    WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'An error occured in the Procedure JEBEDV07. Exception : ' || SUBSTR(SQLERRM,1,200) || SQLCODE);
   END jebedv07;

  --
  -- +======================================================================+
  -- Name: JEITARSV
  --
  -- Description: This procedure used by the Extract when the Concurrent
  --              Program 'Italian Receivables Sales VAT Register' is run.
  --
  -- Parameters:  P_VAT_REP_ENTITY_ID   => VAT Reporting Entity ID
  --              P_PERIOD              => Tax Calendar Year
  --              P_VAT_REGISTER_ID     => VAT Register ID
  -- +======================================================================+
  --
  PROCEDURE jeitarsv(p_vat_rep_entity_id   IN    NUMBER
                     ,p_period             IN    VARCHAR2
                     ,p_vat_register_id    IN    NUMBER
                     ,x_err_msg            OUT   NOCOPY VARCHAR2)
  IS
   CURSOR c_get_std_invoice IS
     SELECT
        JZVTD.doc_seq_name                      DOCUMENT_SEQ_NAME
       ,JZVTD.trx_number                        PRINT_SEQ
       ,JZVTD.gl_date                           GL_DATE
       ,JZVTD.doc_seq_value                     DOCUMENT_SEQ_NUMBER
       ,JZVTD.billing_tp_name                   CUSTOMER_NAME
       ,JZVTD.billing_tp_number                 CUSTOMER_NUMBER
       ,JZVTD.billing_tp_site_name              CUSTOMER_SITE_NAME
       ,NVL(NVL(NVL(JZVTD.billing_tp_site_tax_reg_num,JZVTD.shipping_tp_site_tax_reg_num)
       ,JZVTD.billing_tp_tax_reg_num), JZVTD.shipping_tp_tax_reg_num)             TAX_REFERENCE
       ,JZVTD.trx_number                        INVOICE_NUMBER
       ,JZVTD.trx_date                          INVOICE_DATE
       ,JZVTD.tax_rate_code                     TAX_CODE
       ,NVL(JZVTD.taxable_amt_funcl_curr,0)     TAXABLE_AMT_FUNCL_CURR
       ,NVL(JZVTD.tax_amt_funcl_curr,0)         TAX_AMT_FUNCL_CURR
       ,JZVTD.tax_rate                          TAX_RATE
       ,JZVTD.tax_rate_code_description         DESCRIPTION
       ,JZVRV.effective_to_date                 JEITARSV_PREL_ALERT
       ,JZVTD.trx_line_id                       TRX_LINE_ID
       ,SUBSTR(JZVTD.billing_tp_name,1,90)      PARTY_NAME
       ,SUBSTR(JZVTD.billing_tp_name, 1 , 22)   VAT_REGISTER_NAME
       ,JZVTD.posted_flag                       POSTED_FLAG
       ,JZVTD.trx_currency_code                 TRX_CURRENCY_CODE
       ,JZVTD.TRX_DUE_DATE                      TRX_DUE_DATE
       ,JZVTD.ACCOUNTING_DATE			ACCOUNTING_DATE
     FROM    jg_zz_vat_trx_details      JZVTD
            ,jg_zz_vat_registers_vl     JZVRV
            ,jg_zz_vat_rep_status       JZVRS
            ,jg_zz_vat_doc_sequences    JZVDS
     WHERE   JZVTD.reporting_status_id         = JZVRS.reporting_status_id
     AND     JZVRV.vat_reporting_entity_id     = JZVRS.mapping_vat_rep_entity_id
     AND     JZVDS.doc_sequence_id             = JZVTD.doc_seq_id
     AND     JZVDS.vat_register_id             = JZVRV.vat_register_id
     AND     JZVRS.source                      = 'AR'
     AND     NVL(JZVTD.offset_flag,'N')        <> 'Y'
     AND     JZVRS.tax_calendar_period         = P_PERIOD
     AND     JZVRS.vat_reporting_entity_id     = P_VAT_REP_ENTITY_ID
     AND     JZVRV.vat_register_id             = P_VAT_REGISTER_ID;

   l_get_std_invoice    c_get_std_invoice%ROWTYPE;
   lv_start_seq         jg_zz_vat_final_reports.start_sequence_num%type;
   lv_reporting_status  varchar2(15);
   l_rec_count          number(15);

  BEGIN

    SELECT jg_info_n1, jg_info_v1
    INTO lv_start_seq, lv_reporting_status
    FROM jg_zz_vat_trx_gt
    WHERE jg_info_v30 = 'SEQ';

    OPEN c_get_std_invoice;
    LOOP
      FETCH c_get_std_invoice INTO l_get_std_invoice;

      EXIT WHEN c_get_std_invoice%NOTFOUND;
      INSERT INTO jg_zz_vat_trx_gt
            (
               jg_info_v2
             , jg_info_v1
             , jg_info_d1
             , jg_info_n2
             , jg_info_v3
             , jg_info_v4
             , jg_info_v5
             , jg_info_d2
             , jg_info_v6
             , jg_info_n3
             , jg_info_n4
             , jg_info_n5 --tax_rate
             , jg_info_v7
             , jg_info_d3
             , jg_info_v8
             , jg_info_v9
	     , jg_info_v10 --posted_flag
	     , jg_info_v11 --customer_number
	     , jg_info_v12 --trx_currency_code
	     , jg_info_v13 --customer_site_name
	     , jg_info_d4 --trx_due_date
	     , jg_info_d5 --accounting_date
             , jg_info_v30
	     )
      VALUES(
               l_get_std_invoice.document_seq_name
             , l_get_std_invoice.print_seq
             , l_get_std_invoice.gl_date
             , l_get_std_invoice.document_seq_number
             , l_get_std_invoice.customer_name
             , l_get_std_invoice.tax_reference
             , l_get_std_invoice.invoice_number
             , l_get_std_invoice.invoice_date
             , l_get_std_invoice.tax_code
             , l_get_std_invoice.taxable_amt_funcl_curr
             , l_get_std_invoice.tax_amt_funcl_curr
             , l_get_std_invoice.tax_rate
             , l_get_std_invoice.description
             , l_get_std_invoice.jeitarsv_prel_alert
             , l_get_std_invoice.party_name
             , l_get_std_invoice.vat_register_name
	     , l_get_std_invoice.posted_flag
	     , l_get_std_invoice.customer_number
	     , l_get_std_invoice.trx_currency_code
	     , l_get_std_invoice.customer_site_name
	     , l_get_std_invoice.trx_due_date
	     , l_get_std_invoice.accounting_date
             , 'JEITARSV'
	     );

    END LOOP;

    CLOSE c_get_std_invoice;

  -- Update teh jg_zz_vat_final_reports table for print sequence numbers if lv_reporting_status = 'FINAL'
  IF lv_reporting_status = 'FINAL' THEN

    SELECT count(*)
    INTO l_rec_count
    FROM (SELECT 1
          FROM jg_zz_vat_trx_gt
          WHERE jg_info_v30 = 'JEITARSV'
          GROUP BY jg_info_v2
                 , jg_info_n2
                 , jg_info_v1
                 , jg_info_d1
                 , jg_info_v3
                 , jg_info_v11
                 , jg_info_v13
                 , jg_info_v4
                 , jg_info_v5
                 , jg_info_d2
                 , jg_info_d4
                 , jg_info_v12
                 , jg_info_v10
                 , jg_info_d5);

     -- Update the entry in JG_ZZ_VAT_FINAL_REPORTS table
     UPDATE jg_zz_vat_final_reports
     SET start_sequence_num = lv_start_seq + l_rec_count,
         last_start_sequence_num = lv_start_seq
     WHERE report_name = p_report_name
     AND   vat_register_id = p_vat_register_id
     AND   reporting_status_id = (SELECT reporting_status_id
                                  FROM jg_zz_vat_rep_status
                                  WHERE vat_reporting_entity_id = p_vat_rep_entity_id
                                  AND   source = 'AR'
                                  AND   tax_calendar_period = p_period);

  END IF;

   EXCEPTION
   WHEN OTHERS THEN
   fnd_file.put_line(fnd_file.log,'An error occured in the Procedure JEITARSV. Exception : ' || SUBSTR(SQLERRM,1,200) || SQLCODE);
 END jeitarsv;


  --
  -- +======================================================================+
  -- Name: JEITRDVR
  --
  -- Description: This procedure used by the Extract when the Concurrent
  --              Program 'Italian Receivables Deferred VAT Register' is run.
  --
  -- Parameters:  P_VAT_REP_ENTITY_ID   => VAT Reporting Entity ID
  --              P_PERIOD              => Tax Calendar Year
  --              P_VAT_REGISTER_ID     => VAT Register ID
  -- +======================================================================+
  --
  PROCEDURE jeitrdvr(p_vat_rep_entity_id   IN    NUMBER
                     ,p_period             IN    VARCHAR2
                     ,p_vat_register_id    IN    NUMBER
                     ,x_err_msg            OUT   NOCOPY VARCHAR2)
  IS
   CURSOR c_get_std_invoice IS
   SELECT
        JZVTD.doc_seq_name                                    DOCUMENT_SEQ_NAME
       ,JZVTD.trx_number                                      PRINT_SEQ_INV_NUM
       ,JZVTD.gl_date                                         GL_DATE
       ,JZVTD.doc_seq_value                                   DOCUMENT_SEQ_NUM
       ,JZVTD.billing_tp_name                                 CUSTOMER_NAME
       ,NVL(NVL(NVL(JZVTD.billing_tp_site_tax_reg_num,
                     JZVTD.shipping_tp_site_tax_reg_num)
                     ,JZVTD.billing_tp_tax_reg_num),
                       JZVTD.shipping_tp_tax_reg_num)         TAX_REFERENCE
       ,JZVTD.trx_number                                      INVOICE_NUMBER
       ,JZVTD.trx_date                                        INVOICE_DATE
       ,JZVTD.trx_id					      INVOICE_ID
       ,JZVTD.tax_rate_code                                   TAX_CODE
       ,NVL(JZVTD.taxable_amt_funcl_curr,0)                   TAXABLE_AMOUNT
       ,NVL(JZVTD.tax_amt_funcl_curr,0)                       TAX_AMOUNT
       ,NVL(JZVTD.tax_amt_funcl_curr,0) +
        NVL(JZVTD.taxable_amt_funcl_curr,0)                   TOTAL_AMOUNT_FUNC_CURR
       ,NVL(JZVTD.taxable_amt_funcl_curr,0)                   INV_AMT_WITHOUT_VAT_FUNC_CURR
       ,NVL(JZVTD.tax_amt_funcl_curr,0)                       VAT_AMOUNT_FUNC_CURR
       ,JZVTD.applied_to_trx_number                           NOTE
       ,JZVTD.applied_to_trx_id				      APPLIED_TO_TRX_ID
       ,JZVTD.tax_rate                                        TAX_RATE
       ,JZVTD.tax_rate_code_description                       DESCRIPTION
       ,JZVRV.effective_to_date                               JEITRDVR_PREL_ALERT
       ,JZVTD.trx_line_id                                     TRX_LINE_ID
       ,SUBSTR(JZVTD.billing_tp_name,1,90)                    PARTY_NAME
       ,SUBSTR(JZVTD.billing_tp_name,1,22)                    VAT_REGISTER_NAME
       ,JZVTD.posted_flag POSTED_FLAG
     FROM    jg_zz_vat_trx_details      JZVTD
            ,jg_zz_vat_registers_vl     JZVRV
            ,jg_zz_vat_rep_status       JZVRS
            ,ar_lookups                 LK
            ,jg_zz_vat_doc_sequences    JZVDS
     WHERE   JZVRS.vat_reporting_entity_id     = P_VAT_REP_ENTITY_ID
     AND    JZVRS.tax_calendar_period         =  P_PERIOD
     AND    JZVRV.vat_register_id             =  P_VAT_REGISTER_ID
     AND    JZVRS.source                      = 'AR'
     AND    JZVTD.reporting_status_id         = JZVRS.reporting_status_id
     AND    JZVRV.vat_reporting_entity_id     = JZVRS.mapping_vat_rep_entity_id
     AND    JZVRV.vat_register_id             = JZVDS.vat_register_id
     AND    JZVDS.doc_sequence_id             = JZVTD.doc_seq_id
     -- Bug 6238170 Start
     --AND    JZVTD.tax_type_code               = LK.lookup_code
     AND    JZVTD.reporting_code              = LK.lookup_code
     -- Bug 6238170 End
     AND    LK.lookup_type                    = 'JE_DEFERRED_TAX_TYPE'
     AND    JZVTD.tax_rate_register_type_code = 'INTERIM'
     AND    nvl(JZVTD.offset_flag,'N')        <> 'Y';


   l_get_std_invoice   c_get_std_invoice%ROWTYPE;
   lv_start_seq        jg_zz_vat_final_reports.start_sequence_num%type;
   lv_reporting_status varchar2(15);
   l_rec_count         number;

  BEGIN

    SELECT jg_info_n1, jg_info_v1
    INTO lv_start_seq, lv_reporting_status
    FROM jg_zz_vat_trx_gt
    WHERE jg_info_v30 = 'SEQ';

    OPEN c_get_std_invoice;
    LOOP
      FETCH c_get_std_invoice INTO l_get_std_invoice;
      EXIT WHEN c_get_std_invoice%NOTFOUND;
      INSERT INTO jg_zz_vat_trx_gt
            (
               jg_info_v1
             , jg_info_v2
             , jg_info_d1
             , jg_info_v3
             , jg_info_v4
             , jg_info_v5
             , jg_info_v6
             , jg_info_d2
             , jg_info_v7
             , jg_info_n1
             , jg_info_n2
             , jg_info_n3
             , jg_info_n4
             , jg_info_n5
             , jg_info_v8
             , jg_info_n6
             , jg_info_v9
             , jg_info_d3
             , jg_info_n7
             , jg_info_v10
             , jg_info_v11
	     , jg_info_n8
	     , jg_info_v12  --posted_flag
	     , jg_info_n9 --APPLIED_TO_TRX_ID
             , jg_info_v30
            )
      VALUES(
               l_get_std_invoice.document_seq_name
             , l_get_std_invoice.print_seq_inv_num
             , l_get_std_invoice.gl_date
             , l_get_std_invoice.document_seq_num
             , l_get_std_invoice.customer_name
             , l_get_std_invoice.tax_reference
             , l_get_std_invoice.invoice_number
             , l_get_std_invoice.invoice_date
             , l_get_std_invoice.tax_code
             , l_get_std_invoice.taxable_amount
             , l_get_std_invoice.tax_amount
             , l_get_std_invoice.total_amount_func_curr
             , l_get_std_invoice.inv_amt_without_vat_func_curr
             , l_get_std_invoice.vat_amount_func_curr
             , l_get_std_invoice.note
             , l_get_std_invoice.tax_rate
             , l_get_std_invoice.description
             , l_get_std_invoice.jeitrdvr_prel_alert
             , l_get_std_invoice.trx_line_id
             , l_get_std_invoice.party_name
             , l_get_std_invoice.vat_register_name
	     , l_get_std_invoice.invoice_id
     	     , l_get_std_invoice.posted_flag
	     , l_get_std_invoice.applied_to_trx_id
             , 'JEITRDVR'
            );
    END LOOP;

  -- Update teh jg_zz_vat_final_reports table for print sequence numbers if lv_reporting_status = 'FINAL'
  IF lv_reporting_status = 'FINAL' THEN

    SELECT count(*)
    INTO l_rec_count
    FROM (SELECT 1
          FROM jg_zz_vat_trx_gt
          WHERE jg_info_v30  = 'JEITRDVR'
          GROUP BY jg_info_v1
                  ,jg_info_v2
                  ,jg_info_d1
                  ,jg_info_v3
                  ,jg_info_v4
                  ,jg_info_v5
                  ,jg_info_v6
                  ,jg_info_d2);

     -- Update the entry in JG_ZZ_VAT_FINAL_REPORTS table
     UPDATE jg_zz_vat_final_reports
     SET start_sequence_num = lv_start_seq + l_rec_count,
         last_start_sequence_num = lv_start_seq
     WHERE report_name = p_report_name
     AND   vat_register_id = p_vat_register_id
     AND   reporting_status_id = (SELECT reporting_status_id
                                  FROM jg_zz_vat_rep_status
                                  WHERE vat_reporting_entity_id = p_vat_rep_entity_id
                                  AND   source = 'AR'
                                  AND   tax_calendar_period = p_period);

  END IF;

   EXCEPTION
   WHEN OTHERS THEN
   fnd_file.put_line(fnd_file.log,'An error occured in the Procedure JEITRDVR. Exception : ' || SUBSTR(SQLERRM,1,200) || SQLCODE);
  END jeitrdvr;


  --
  -- +======================================================================+
  -- Name: JEESRRVR
  --
  -- Description: This procedure used by the Extract when the Concurrent
  --              Program 'Spanish Output VAT Journal Report' is run.
  --
  -- Parameters:  P_VAT_REP_ENTITY_ID   => VAT Reporting Entity ID
  --              P_PERIOD              => Tax Calendar Year
  --              P_TAX_TYPE            => Tax Type
  --              P_TAX_REGISTER_TYPE   => Tax Register Type
  --              P_SEQUENCE            => Sequence
  -- +======================================================================+
  --
  PROCEDURE jeesrrvr(p_vat_rep_entity_id  IN    NUMBER
                    ,p_period             IN    VARCHAR2
					,p_period_to          IN    VARCHAR2 -- Bug8267272 Start
                    ,p_tax_type           IN    VARCHAR2
                    ,p_tax_register_type  IN    VARCHAR2
                    ,p_sequence           IN    VARCHAR2
                    ,x_err_msg            OUT   NOCOPY VARCHAR2)
  IS
   CURSOR C_INV_LINES IS
     SELECT
             JZVTD.trx_id                                   SEQ_NUM
            ,JZVTD.doc_seq_name ||'/'|| JZVTD.doc_seq_value DOC_SEQ_NUM
            ,JZVTD.trx_date                                 INVOICE_DATE
            ,DECODE(JZVTD.trx_line_class,'APP'
                   ,JZVTD.applied_to_trx_number
                     ,JZVTD.trx_number)                     INVOICE_NUMBER
            ,SUBSTR(JZVTD.billing_tp_name,1,150)||' '||
                      JZVTD.billing_tp_tax_reg_num          CUSTOMER_NAME
            ,NVL(JZVTD.taxable_amt_funcl_curr,0)            NET_AMOUNT
            ,JZVTD.tax_rate_code                            TAX_CODE
            ,JZVTD.tax_rate                                 TAX_RATE
            ,NVL(JZVTD.tax_amt_funcl_curr,0)                TAX_AMOUNT
            ,JZVTD.tax_rate_vat_trx_type_desc               TAX_DESCRIPTION
            ,JZVTD.REPORTING_CODE                           REPORTING_CODE
            ,TAX_RATE_REGISTER_TYPE_CODE                    REGISTER_TYPE
            ,JZVTD.trx_line_id                              TRX_LINE_ID
     FROM    jg_zz_vat_trx_details       JZVTD
            ,jg_zz_vat_rep_status        JZVRS
          --  ,fnd_lookup_values           LK
     WHERE   JZVTD.reporting_status_id in (SELECT DISTINCT JZRS.reporting_status_id JZRS
					     FROM jg_zz_vat_rep_status JZRS
					     WHERE JZRS.vat_reporting_entity_id = P_VAT_REP_ENTITY_ID
					     AND   JZRS.source = 'AR')
     AND     JZVTD.gl_date BETWEEN JZVRS.period_start_date and JZVRS.period_end_date
 --  JZVTD.reporting_status_id           = JZVRS.reporting_status_id
 --  AND     JZVTD.tax_type_code		 = LK.lookup_code
 --  AND     LK.lookup_type                      = 'ZX_TRL_REGISTER_TYPE'
 --  AND     LK.source_lang                      = USERENV('LANG')
     AND     JZVRS.source                        = 'AR'
     AND     ((JZVTD.tax_rate_register_type_code = 'TAX' AND P_TAX_REGISTER_TYPE = 'TAX')
             OR  (JZVTD.tax_rate_register_type_code = 'INTERIM' AND P_TAX_REGISTER_TYPE = 'INTERIM')
             OR  (JZVTD.tax_rate_register_type_code = 'NON-RECOVERABLE' AND P_TAX_REGISTER_TYPE = 'NON-RECOVERABLE'))
     AND     JZVTD.reporting_code                 = P_TAX_TYPE --BUG:9223611
  -- Bug8267272 Start
     AND     JZVRS.tax_calendar_period           IN (SELECT RPS1.tax_calendar_period
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

     AND     ( JZVTD.trx_tax_balancing_segment = P_BALANCING_SEGMENT OR P_BALANCING_SEGMENT is NULL )
     AND     JZVRS.vat_reporting_entity_id       = P_VAT_REP_ENTITY_ID;
  -- AND     LK.lookup_code                      = P_TAX_REGISTER_TYPE;

     l_inv_lines  c_inv_lines%ROWTYPE;

 BEGIN

    OPEN c_inv_lines;
    LOOP
      FETCH c_inv_lines INTO l_inv_lines;
      EXIT WHEN c_inv_lines%NOTFOUND;

      INSERT INTO jg_zz_vat_trx_gt
            (
               jg_info_n1
             , jg_info_v1
             , jg_info_d1
             , jg_info_v2
             , jg_info_v3
             , jg_info_n2
             , jg_info_v4
             , jg_info_n3
             , jg_info_n4
             , jg_info_v5
             , jg_info_v6
             , jg_info_v7
             , jg_info_n5
            )
      VALUES(
                l_inv_lines.seq_num
              , l_inv_lines.doc_seq_num
              , l_inv_lines.invoice_date
              , l_inv_lines.invoice_number
              , l_inv_lines.customer_name
              , l_inv_lines.net_amount
              , l_inv_lines.tax_code
              , l_inv_lines.tax_rate
              , l_inv_lines.tax_amount
              , l_inv_lines.tax_description
              , l_inv_lines.reporting_code
              , l_inv_lines.register_type
              , l_inv_lines.trx_line_id
            );

    END LOOP;


   EXCEPTION
   WHEN OTHERS THEN
   fnd_file.put_line(fnd_file.log,'An error occured in the Procedure JEESRRVR. Exception : ' || SUBSTR(SQLERRM,1,200) || SQLCODE);
 END jeesrrvr;

FUNCTION get_sequence_number RETURN NUMBER IS
l_start_seq NUMBER;
BEGIN
    IF p_report_name = 'JEITARSV' or p_report_name = 'JEITRDVR' THEN
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

END JG_ZZ_JOURNAL_AR_PKG;

/
