--------------------------------------------------------
--  DDL for Package Body JG_ZZ_VAT_PRE_REP_PROC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_VAT_PRE_REP_PROC_PKG" AS
        /* $Header: jgzzprpb.pls 120.0.12010000.4 2010/01/07 19:37:37 spasupun noship $ */
        -----------------------------------------
        --Public Variable Declarations
        -----------------------------------------
        g_current_runtime_level CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
        g_level_statement       CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
        g_level_procedure       CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
        g_level_event           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
        g_level_unexpected      CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
        g_level_error           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
        g_level_exception       CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
        g_error_buffer          VARCHAR2(100);
        g_debug_flag            VARCHAR2(1);
        g_pkg_name              CONSTANT VARCHAR2(30) := 'JG_ZZ_VAT_PRE_REP_PROC_PKG';
        g_module_name           CONSTANT VARCHAR2(30) := 'JG_ZZ_VAT_PRE_REP_PROC_PKG';

/*
REM +======================================================================+
REM Name: get_bsv
REM
REM Description: This function is called for getting the
REM              BSV for each invoice distribution.
REM
REM
REM Parameters:  p_ccid  (Code Combination ID)
REM              p_chart_of_accounts_id (Chart of account)
REM              p_ledger_id (Ledger ID)
REM +======================================================================+
*/

FUNCTION GET_BSV
        ( p_ccid                 NUMBER,
          p_chart_of_accounts_id NUMBER,
          p_ledger_id            NUMBER)
        RETURN VARCHAR2
IS
        l_segment         VARCHAR2(30);
        bal_segment_value VARCHAR2(25):= '1';
BEGIN

        SELECT  application_column_name
        INTO    l_segment
        FROM    fnd_segment_attribute_values ,
                gl_ledgers gl
        WHERE   id_flex_code            = 'GL#'
            AND attribute_value         = 'Y'
            AND segment_attribute_type  = 'GL_BALANCING'
            AND application_id          = 101
            AND id_flex_num             = gl.chart_of_accounts_id
            AND gl.chart_of_accounts_id = p_chart_of_accounts_id
            AND gl.ledger_id            = p_ledger_id;

        EXECUTE IMMEDIATE 'SELECT '||l_segment || ' FROM gl_code_combinations '
             || ' WHERE code_combination_id = '||p_ccid INTO bal_segment_value;

        RETURN (bal_segment_value);

EXCEPTION
WHEN NO_DATA_FOUND THEN
        fnd_file.put_line(fnd_file.log,' No record was returned for the GL_Balancing segment. Error : ' || SUBSTR(SQLERRM,1,200));
        RETURN NULL;
WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log,' Error in GET_BSV function : ' || SUBSTR(SQLERRM,1,200));
        RETURN NULL;
END get_bsv;

-----------------------------------------
--Public Methods
-----------------------------------------
--
/*===========================================================================+
| PROCEDURE                                                                 |
|   main()                                                                  |
|                                                                           |
| DESCRIPTION                                                               |
|									    |
|                                                                           |
| SCOPE - Public                                                            |
|                                                                           |
| NOTES                                                                     |
|                                                                           |
+===========================================================================*/
PROCEDURE main
        (  errbuf OUT NOCOPY  VARCHAR2,
           retcode OUT NOCOPY NUMBER,
           p_reporting_level         IN jg_zz_vat_rep_entities.entity_level_code%TYPE,
           p_vat_reporting_entity_id IN jg_zz_vat_rep_entities.vat_reporting_entity_id%TYPE,
           p_chart_of_account_id     IN NUMBER,
           p_bsv                     IN jg_zz_vat_rep_entities.balancing_segment_value%TYPE,
           p_period                  IN jg_zz_vat_rep_status.tax_calendar_period%TYPE
        ) IS

        l_return_status  VARCHAR2(1);
        l_return_message VARCHAR2(1000);

        CURSOR c_last_rep_period_csr (p_vat_reporting_entity_id jg_zz_vat_rep_entities.vat_reporting_entity_id%TYPE)
        IS
          SELECT  last_reported_period
          FROM    jg_zz_vat_rep_entities
          WHERE   vat_reporting_entity_id = p_vat_reporting_entity_id;

        CURSOR c_is_mgr_trx_exist(pn_vat_rep_entity_id number)
        IS
         SELECT JGTRD.trx_id
         FROM jg_zz_vat_trx_details JGTRD,
             jg_zz_vat_rep_status JGREPS,
             zx_lines ZX
        WHERE JGREPS.vat_reporting_entity_id = pn_vat_rep_entity_id
        AND JGREPS.reporting_status_id = JGTRD.reporting_status_id
        AND JGREPS.source = JGTRD.extract_source_ledger
        AND ZX.trx_id = JGTRD.trx_id
        AND JGTRD.created_by = 1
        AND ZX.record_type_code   = 'MIGRATED'
        AND ZX.application_id     = JGTRD.application_id
        AND ZX.entity_code        = JGTRD.entity_code
        AND ZX.event_class_code   = JGTRD.event_class_code
        AND rownum=1;

        l_country XLE_FIRSTPARTY_INFORMATION_V.country%TYPE;
        l_legal_entity_id JG_ZZ_VAT_REP_ENTITIES.legal_entity_id%TYPE;
        l_ledger JG_ZZ_VAT_REP_ENTITIES.ledger_id%TYPE;
        l_driving_date_code JG_ZZ_VAT_REP_ENTITIES.driving_date_code%TYPE;
        l_driving_date_code_es JG_ZZ_VAT_REP_ENTITIES.driving_date_code%TYPE;
        l_mapping_rep_entity_id JG_ZZ_VAT_REP_ENTITIES.mapping_vat_rep_entity_id%TYPE;
        l_tax_calendar_name JG_ZZ_VAT_REP_ENTITIES.tax_calendar_name%TYPE;
        l_last_reported_period JG_ZZ_VAT_REP_ENTITIES.last_reported_period%TYPE;
        l_bsv_vat_rep_entity_id JG_ZZ_VAT_REP_ENTITIES.vat_reporting_entity_id%TYPE;
        l_ledger_id JG_ZZ_VAT_REP_ENTITIES.ledger_id%TYPE;
        l_start_date DATE;
        l_end_date DATE;
        l_is_mgr_trx_exist   NUMBER(15);


    	l_update_query_ap VARCHAR2(5000);
	l_update_query_ar VARCHAR2(5000);

        l_is_upgrade_customer NUMBER := 0;

       CURSOR c_is_upgrade_customer IS
       SELECT 1
       FROM zx_lines
       WHERE record_type_code= 'MIGRATED'
       AND rownum=1;

BEGIN

fnd_file.put_line(fnd_file.log,'p_reporting_level: '
                                         ||p_reporting_level);
fnd_file.put_line(fnd_file.log,'p_vat_reporting_entity_id: '
                                         ||p_vat_reporting_entity_id);
fnd_file.put_line(fnd_file.log,'p_bsv: '
                                         ||p_bsv);
fnd_file.put_line(fnd_file.log,'p_period: '
                                         ||p_period);

  OPEN c_is_upgrade_customer;
  FETCH c_is_upgrade_customer INTO l_is_upgrade_customer;
  CLOSE c_is_upgrade_customer;

  IF l_is_upgrade_customer = 0 THEN

   FND_MESSAGE.SET_NAME('JG','JG_ZZ_VAT_PRE_REP_PROC_NREQ');
   fnd_file.put_line(fnd_file.log,FND_MESSAGE.GET);
   return;

  END IF;

        SELECT  LEGAL.driving_date_code
               ,ACCT.mapping_vat_rep_entity_id
               ,LEGAL.tax_calendar_name
               ,ACCT.ledger_id
               ,LEGAL.legal_entity_id
        INTO    l_driving_date_code
               ,l_mapping_rep_entity_id
               ,l_tax_calendar_name
               ,l_ledger_id
               ,l_legal_entity_id
        FROM    JG_ZZ_VAT_REP_ENTITIES LEGAL
               ,JG_ZZ_VAT_REP_ENTITIES ACCT
        WHERE   ACCT.VAT_REPORTING_ENTITY_ID  = p_vat_reporting_entity_id
        AND LEGAL.VAT_REPORTING_ENTITY_ID = ACCT.mapping_vat_rep_entity_id;

        -- get country code

        SELECT xle.country
        INTO  l_country
        FROM  xle_firstparty_information_v xle
        WHERE xle.legal_entity_id = l_legal_entity_id;

        IF p_reporting_level = 'LEDGER' THEN

           OPEN  c_last_rep_period_csr(p_vat_reporting_entity_id);
           FETCH c_last_rep_period_csr
           INTO  l_last_reported_period;
           CLOSE c_last_rep_period_csr;

           OPEN c_is_mgr_trx_exist(p_vat_reporting_entity_id);
           FETCH   c_is_mgr_trx_exist
           INTO    l_is_mgr_trx_exist;
           CLOSE c_is_mgr_trx_exist ;

        ELSE -- p_reporting_level = 'BSV'

          JG_ZZ_VAT_REP_UTILITY.maintain_selection_entities( pv_entity_level_code => p_reporting_level
                                                           , pn_vat_reporting_entity_id => l_mapping_rep_entity_id
                                                           , pn_ledger_id => l_ledger_id
                                                           , pv_balancing_segment_value => p_bsv
                                                           , xn_vat_reporting_entity_id => l_bsv_vat_rep_entity_id
                                                           , xv_return_status => l_return_status
                                                           , xv_return_message => l_return_message
                                                           );

             IF l_return_status  IN ( FND_API.G_RET_STS_UNEXP_ERROR, FND_API.G_RET_STS_ERROR) THEN
                 errbuf   := l_return_message;
                 retcode  := 2;
                 RETURN;
             END IF;

            OPEN c_last_rep_period_csr(l_bsv_vat_rep_entity_id);
            FETCH c_last_rep_period_csr INTO l_last_reported_period;
            CLOSE c_last_rep_period_csr;

            OPEN c_is_mgr_trx_exist(l_bsv_vat_rep_entity_id);
            FETCH c_is_mgr_trx_exist
            INTO l_is_mgr_trx_exist;
            CLOSE c_is_mgr_trx_exist ;

         END IF; --        IF p_reporting_level = 'LEDGER' THEN

         IF l_last_reported_period IS NOT NULL THEN
	    FND_MESSAGE.SET_NAME('JG','JG_ZZ_VAT_PRE_REP_PROC_RAN');
            errbuf            :=  FND_MESSAGE.GET;
            retcode           := 2;
            RETURN;

         ELSIF l_last_reported_period IS NULL AND l_is_mgr_trx_exist IS NOT NULL THEN

	    FND_MESSAGE.SET_NAME('JG','JG_ZZ_VAT_PRE_REP_PROC_NREQ');
            errbuf            :=  FND_MESSAGE.GET;
            retcode           := 2;
            RETURN;

         END IF;


    fnd_file.put_line(fnd_file.log,'Ledger ID: '
                                          ||l_ledger_id);
    fnd_file.put_line(fnd_file.log,'BSV VAT Reporting Entity ID: '
                                          ||l_bsv_vat_rep_entity_id);
    fnd_file.put_line(fnd_file.log,'Driving Date Code: '
                                          ||l_driving_date_code);
    fnd_file.put_line(fnd_file.log,'Lega VAT Reporting Entity ID: '
                                          ||l_mapping_rep_entity_id);

           SELECT  start_date ,
                   end_date
           INTO    l_start_date ,
                   l_end_date
           FROM    GL_PERIODS
           WHERE   period_set_name = l_tax_calendar_name
           AND period_name = p_period;

       IF l_driving_date_code = 'GL-TRX' THEN
          l_driving_date_code_es := l_driving_date_code;
          l_driving_date_code := 'GL';
       END IF;

 << continue_loop >>

      l_update_query_ap :=
		        'UPDATE zx_lines zxl
                 SET zxl.legal_reporting_status =''000000000000000''
                    ,LAST_UPDATED_BY            = -5
                    ,LAST_UPDATE_DATE           = sysdate
                    ,OBJECT_VERSION_NUMBER      = OBJECT_VERSION_NUMBER+1
                 WHERE zxl.legal_reporting_status = ''111111111111111''
                 AND zxl.record_type_code       = ''MIGRATED''
                 AND zxl.ledger_id              =  $l_ledger_id$
                 AND zxl.legal_entity_id        =  $l_legal_entity_id$
                 AND zxl.trx_id NOT IN
                     (SELECT stg.trx_id
  	                  FROM jg_zz_vat_trx_upg_stg stg
					  WHERE stg.application_id = zxl.application_id
		              AND stg.EVENT_CLASS_CODE = zxl.EVENT_CLASS_CODE
				      AND stg.ENTITY_CODE      = zxl.entity_code
		              )
                 AND zxl.trx_id NOT IN
                     (SELECT trxd.trx_id
                      FROM jg_zz_vat_rep_Status reps ,
                           jg_zz_vat_trx_details trxd
                      WHERE   reps.reporting_status_id  = trxd.reporting_status_id
                      AND reps.final_reporting_status_flag  IS NOT NULL
                      AND reps.final_reporting_process_id   IS NOT NULL
                      AND reps.final_reporting_process_date IS NOT NULL
                       )';

			     l_update_query_ar := l_update_query_ap;

        IF l_driving_date_code  = 'TRX' THEN

    	    l_update_query_ap := l_update_query_ap||
		    ' AND zxl.application_id  = 200
              AND zxl.trx_date        > $l_end_date$';

       	    l_update_query_ar := l_update_query_ar||
		    ' AND zxl.application_id  = 222
              AND zxl.trx_date        > $l_end_date$';


    		IF p_reporting_level = 'BSV' THEN

			  l_update_query_ap := l_update_query_ap ||
			   '  AND zxl.trx_id IN
                        (SELECT apd.invoice_id trx_id
                         FROM  ap_invoice_distributions_all apd
                              ,ap_invoices_all apinv
                         WHERE   apinv.invoice_id       = apd.invoice_id
                         AND apinv.invoice_date      > $l_end_date$
                         AND apinv.set_of_books_id   = $l_ledger_id$
                         AND apinv.legal_entity_id   = $l_legal_entity_id$
                         AND JG_ZZ_VAT_PRE_REP_PROC_PKG.get_bsv(apd.dist_code_combination_id ,$p_chart_of_account_id$ ,$l_ledger_id$) = ''$p_bsv$''
                         )';

   			  l_update_query_ar := l_update_query_ar ||
                    		   '  AND zxl.trx_id IN
                                ( SELECT  rtd.customer_trx_id
                                  FROM    ra_cust_trx_line_gl_dist_all rtd ,
                                          ra_customer_trx_all rinv
                                  WHERE   rinv.customer_trx_id     = rtd.customer_trx_id
                                    AND rinv.trx_date            > $l_end_date$
                                    AND rinv.set_of_books_id     = $l_ledger_id$
                                    AND rinv.legal_entity_id     = $l_legal_entity_id$
                                    AND JG_ZZ_VAT_PRE_REP_PROC_PKG.get_bsv(rtd.CODE_COMBINATION_ID ,$p_chart_of_account_id$ ,$l_ledger_id$) = ''$p_bsv$''
                                )';


      			END IF;	-- p_reporting_level = 'BSV'

        ELSIF l_driving_date_code = 'GL' THEN

   			l_update_query_ap := l_update_query_ap||
                           '  AND zxl.application_id = 200
                              AND zxl.trx_id  IN
                                  (SELECT invoice_id
	       	                        FROM    ap_invoices_all
 		              			    WHERE   gl_date     > $l_end_date$
        				            AND set_of_books_id = $l_ledger_id$
            					    AND legal_entity_id = $l_legal_entity_id$
	                                )';

             l_update_query_ar := l_update_query_ar||
                          ' AND zxl.application_id    = 222
                            AND zxl.trx_id IN
                                (SELECT customer_trx_id
                                FROM    ra_cust_trx_line_gl_dist_all
                                WHERE   gl_date         > $l_end_date$
                                    AND set_of_books_id = $l_ledger_id$
                                ) ';

			 IF p_reporting_level = 'BSV' THEN

    			 l_update_query_ap := l_update_query_ap||
                            '  AND zxl.trx_id IN
                                (SELECT apd.invoice_id trx_id
                                FROM    ap_invoice_distributions_all apd ,
                                        ap_invoices_all apinv
                                WHERE   apinv.invoice_id        = apd.invoice_id
                                    AND apinv.gl_date           > $l_end_date$
                                    AND apinv.set_of_books_id   = $l_ledger_id$
                                    AND apinv.legal_entity_id   = $l_legal_entity_id$
                                    AND JG_ZZ_VAT_PRE_REP_PROC_PKG.get_bsv(apd.dist_code_combination_id ,$p_chart_of_account_id$ ,$l_ledger_id$) = ''$p_bsv$''
                                ) ';

    			l_update_query_ar := l_update_query_ar||
		                      	 '   AND zxl.trx_id IN
                                (SELECT rtd.customer_trx_id
                                FROM    ra_cust_trx_line_gl_dist_all rtd ,
                                        ra_customer_trx_all rinv
                                WHERE   rinv.customer_trx_id   = rtd.customer_trx_id
                                    AND rtd.gl_date            > $l_end_date$
                                    AND rinv.set_of_books_id  =  $l_ledger_id$
                                    AND rinv.legal_entity_id  =  $l_legal_entity_id$
                                    AND JG_ZZ_VAT_PRE_REP_PROC_PKG.get_bsv(rtd.CODE_COMBINATION_ID ,$p_chart_of_account_id$ ,$l_ledger_id$) = ''$p_bsv$''
                                )';

			  END IF; --p_reporting_level = 'BSV'

        ELSIF l_driving_date_code = 'TID' THEN

		 l_update_query_ap := l_update_query_ap ||
                          ' AND zxl.application_id = 200
                            AND zxl.trx_id                IN
                                (SELECT zxd.trx_id
                                FROM    zx_lines_det_factors zxd
                                WHERE   zxd.tax_invoice_date > $l_end_date$
                                    AND zxd.application_id   = zxl.application_id
                                    AND zxd.EVENT_CLASS_CODE = zxl.EVENT_CLASS_CODE
                                    AND zxd.ENTITY_CODE      = zxl.entity_code
                                    AND zxd.legal_entity_id  = $l_legal_entity_id$
                                    AND zxd.ledger_id        = $l_ledger_id$
                                )';

   		 l_update_query_ar := l_update_query_ar ||
                          ' AND zxl.application_id  = 222
                            AND zxl.trx_id                IN
                                (SELECT zxd.trx_id
                                FROM    zx_lines_det_factors zxd
                                WHERE   zxd.tax_invoice_date > $l_end_date$
                                    AND zxd.application_id   = zxl.application_id
                                    AND zxd.EVENT_CLASS_CODE = zxl.EVENT_CLASS_CODE
                                    AND zxd.ENTITY_CODE      = zxl.entity_code
                                    AND zxd.legal_entity_id  = $l_legal_entity_id$
                                    AND zxd.ledger_id        = $l_ledger_id$
                                )';

			IF p_reporting_level = 'BSV' THEN

			 l_update_query_ap := l_update_query_ap ||
			  '  AND zxl.trx_id IN
                                (SELECT apd.invoice_id trx_id
                                FROM    ap_invoice_distributions_all apd ,
                                        ap_invoices_all apinv
                                WHERE   apinv.invoice_id          = apd.invoice_id
                                    AND apinv.set_of_books_id     = $l_ledger_id$
                                    AND apinv.legal_entity_id     = $l_legal_entity_id$
                                    AND JG_ZZ_VAT_PRE_REP_PROC_PKG.get_bsv(apd.dist_code_combination_id ,$p_chart_of_account_id$ ,$l_ledger_id$) = ''$p_bsv$''
                                )';

   			 l_update_query_ar := l_update_query_ar ||
			  '  AND zxl.trx_id IN
                                ( SELECT  rtd.customer_trx_id
                                  FROM  ra_cust_trx_line_gl_dist_all rtd ,
                                        ra_customer_trx_all rinv
                                   WHERE   rinv.customer_trx_id = rtd.customer_trx_id
                                    AND rinv.set_of_books_id = $l_ledger_id$
                                    AND rinv.legal_entity_id = $l_legal_entity_id$
                                    AND JG_ZZ_VAT_PRE_REP_PROC_PKG.get_bsv(rtd.CODE_COMBINATION_ID,$p_chart_of_account_id$,$l_ledger_id$) = ''$p_bsv$''
                                )';

    		 END IF; --p_reporting_level = 'BSV'
      END IF;


           l_update_query_ap := REPLACE( l_update_query_ap,'$l_ledger_id$',l_ledger_id);
           l_update_query_ap := REPLACE( l_update_query_ap,'$l_end_date$',''''||l_end_date||'''');
           l_update_query_ap := REPLACE( l_update_query_ap,'$l_legal_entity_id$',l_legal_entity_id);
       	   l_update_query_ap := REPLACE( l_update_query_ap,'$p_chart_of_account_id$',p_chart_of_account_id);
       	   l_update_query_ap := REPLACE( l_update_query_ap,'$p_bsv$',p_bsv);

           l_update_query_ar := REPLACE( l_update_query_ar,'$l_ledger_id$',l_ledger_id);
	   l_update_query_ar := REPLACE( l_update_query_ar,'$l_end_date$',''''||l_end_date||'''');
	   l_update_query_ar := REPLACE( l_update_query_ar,'$l_legal_entity_id$',l_legal_entity_id);
           l_update_query_ar := REPLACE( l_update_query_ar,'$p_chart_of_account_id$',p_chart_of_account_id);
           l_update_query_ar := REPLACE( l_update_query_ar,'$p_bsv$',p_bsv);

        fnd_file.put_line(fnd_file.log,'l_update_query_ap :='||l_update_query_ap);
        fnd_file.put_line(fnd_file.log,'l_update_query_ar :='||l_update_query_ar);

        EXECUTE IMMEDIATE l_update_query_ap;

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Driving Date Code :'||l_driving_date_code);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'AP Rows updated: '||To_char(SQL%RowCount));

        EXECUTE IMMEDIATE l_update_query_ar;
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Driving Date Code :'||l_driving_date_code);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'AR Rows updated: '||To_char(SQL%RowCount));

      IF l_driving_date_code_es = 'GL-TRX' THEN
         l_driving_date_code := 'TRX';
         l_driving_date_code_es := NULL;
         goto continue_loop;
      END IF;


        IF p_reporting_level = 'LEDGER' THEN

                        UPDATE JG_ZZ_VAT_REP_ENTITIES
                        SET     LAST_REPORTED_PERIOD    = p_period
                        WHERE   VAT_REPORTING_ENTITY_ID = p_vat_reporting_entity_id;

        ELSE --p_reporting_level = 'BSV'
                        UPDATE JG_ZZ_VAT_REP_ENTITIES
                        SET     LAST_REPORTED_PERIOD    = p_period
                        WHERE   VAT_REPORTING_ENTITY_ID = l_bsv_vat_rep_entity_id;
        END IF;

EXCEPTION
WHEN OTHERS THEN
        g_error_buffer := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
                FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
        FND_MSG_PUB.Add;
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_unexpected, G_MODULE_NAME, g_error_buffer);
        END IF;
        retcode           := 2;
END main;
END JG_ZZ_VAT_PRE_REP_PROC_PKG;

/
