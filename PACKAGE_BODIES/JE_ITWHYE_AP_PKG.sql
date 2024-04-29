--------------------------------------------------------
--  DDL for Package Body JE_ITWHYE_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_ITWHYE_AP_PKG" AS
-- $Header: JEITWHYLB.pls 120.0.12010000.17 2009/09/30 06:53:26 suresing noship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
-- JEITWHYLB.pls
--
-- DESCRIPTION
--  This script creates the package body of je_itwhye_ap_pkg Package
--  This package is used to generate Italian Withholding Yearly  extract Report
--
-- USAGE
--   To install        How to Install
--   To execute        How to Execute
--
-- DEPENDENCIES
--   None.
--
--
-- LAST UPDATE DATE  23-SEP-2009
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)         DESCRIPTION
-- ------- ----------- ---------------   ------------------------------------
-- 1.0    12-NOV-2008 SURESH SINGH M Creation
--1.1     28-JAN-2009 SURESH SINGH Removed all the functions that where being referred by the insert statement into the Global temp table.
--1.2     23-SEP-2009  SURESH SINGH Updated code for PREPAYMENT Invoices
--****************************************************************************************
-----****************************************************************************************
-----------------------------------------------------BEFORE REPORT LOGIC---------------------------------------------------------------
------****************************************************************************************
  FUNCTION beforereport
      RETURN BOOLEAN
   IS
   BEGIN
      DECLARE
	ln_coaid       NUMBER;
	lc_sobname     VARCHAR2 (30);
	lc_functcurr   VARCHAR2 (15);
	lc_errbuf      VARCHAR2 (132);
	ln_sob_id    NUMBER;
      BEGIN

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------Getting the Ledger Id Information from the Input Parameter of Legal Entity Id
-----------------------------------------------------------------------------------------------------------------------------------------------------
              BEGIN
				SELECT glev.ledger_id , glp.year_start_date, glp.end_date
				        ,glev.currency_code
				  INTO cp_set_of_books_id
				       ,cp_year_start_date
					   ,cp_year_end_date
					   ,cp_currencycode
				FROM   gl_ledger_le_v glev
				      , gl_periods glp
				 WHERE glev.legal_entity_id = p_legal_entity_id
				   AND glev.period_set_name = glp.period_set_name
				   AND glev.accounted_period_type = glp.period_type
				   AND glp.period_year = p_year
				   AND glp.adjustment_period_flag = 'Y'
				   AND glev.relationship_enabled_flag = 'Y'
				   AND glev.ledger_category_code = 'PRIMARY';
				EXCEPTION
				   WHEN NO_DATA_FOUND
				   THEN
					  fnd_file.put_line (fnd_file.LOG, SQLERRM);
				END;

/*------------------------------------------------------------------------------------------------------------------------------------------
-----------Getting the Commercial Number for the Input Parameter of Legal Entity Id
----------------------------------------------------------------------------------------------------------------------------------------------------- */
				BEGIN
					SELECT NVL (xler.registration_number, '') commercial_number
					   INTO cp_comm_num
					FROM   xle_registrations xler,
						   xle_jurisdictions_b xlej,
						   xle_entity_profiles xlee
					 WHERE xlej.jurisdiction_id = xler.jurisdiction_id
					   AND xlej.legislative_cat_code = 'COMMERCIAL_LAW'
					   AND xler.source_id = xlee.legal_entity_id
					   AND xler.source_table = 'XLE_ENTITY_PROFILES'
					   AND xlee.legal_entity_id = p_legal_entity_id;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
						cp_comm_num:=NULL;
	            END;


/*------------------------------------------------------------------------------------------------------------------------------------------
-----------Getting the Ledger Functional Currency  Information from the Input Parameter of Legal Entity Id
----------------------------------------------------------------------------------------------------------------------------------------------------- */

         GL_INFO.GL_GET_LEDGER_INFO (cp_set_of_books_id
                                     ,ln_coaid
                                     ,lc_sobname
                                     ,lc_functcurr
                                     ,lc_errbuf
                                    );
			IF (lc_errbuf IS NOT NULL)
		         THEN

		          					NULL;

		      END IF;



-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------Fetching the Precision from fnd_curriencies for the Corresponding  Functional Currency Code
-----------------------------------------------------------------------------------------------------------------------------------------------------
		BEGIN
		   SELECT PRECISION
		     INTO cp_precision
		     FROM fnd_currencies
		    WHERE currency_code = lc_functcurr;
		EXCEPTION
		   WHEN NO_DATA_FOUND
		   THEN
		      fnd_file.put_line (fnd_file.LOG, SQLERRM);
		END;


-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------Assigning the IRPEF , INPS and Currency code  to the Global Variables
-----------------------------------------------------------------------------------------------------------------------------------------------------

			BEGIN
				    g_irpef:='IRPEF';
					g_inps :='INPS';
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------Assigning the  Functional Currency Code to the global Variable
-----------------------------------------------------------------------------------------------------------------------------------------------------
					 cp_currency_code := lc_functcurr;
			END;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------Passing Lexical Parameters for the Order By Clause
-----------------------------------------------------------------------------------------------------------------------------------------------------

	IF(P_ORDER_BY ='S') THEN
		lp_order_by :='aps.vendor_name';
	ELSIF(P_ORDER_BY ='V') THEN
		lp_order_by :='apss.vat_registration_num';
	ELSIF(P_ORDER_BY ='T') THEN
		lp_order_by :='taxpayer_id';
	END IF;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------Calling the Procedure to insert data into the Gloab Temp table jg_zz_vat_trx_gt
-----------------------------------------------------------------------------------------------------------------------------------------------------


	JE_ITWHYE_AP_PKG.JE_WITHHOLDING(errbuf
                                     ,errcode
									 ,p_legal_entity_id
									 ,cp_year_start_date
									 ,cp_year_end_date
									 ,lp_order_by
									 );

		EXCEPTION
		 WHEN OTHERS
		 THEN
					NULL;
		END;




      RETURN (TRUE);
   END;

-----****************************************************************************************
-----------------------------------------------------AFTER REPORT---------------------------------------------------------------
------****************************************************************************************

   FUNCTION afterreport
      RETURN BOOLEAN
   IS
   BEGIN

      RETURN (TRUE);
   END;

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------Converting the P_Year into Year Start Date
-----------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION cp_start_date
   RETURN VARCHAR2
IS

BEGIN
     RETURN cp_year_start_date;
END;
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------Converting the P_Year into Year End Date
-----------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION cp_end_date
   RETURN VARCHAR2
IS
 BEGIN

      RETURN cp_year_end_date;

END;
-----------------------------------------------------------------------------------------------------------------------------------------------------
--Inserting the rows in the JG_ZZ_VAT_TRX_GT Global Table
-----------------------------------------------------------------------------------------------------------------------------------------------------

 PROCEDURE  je_withholding(errbuf OUT NOCOPY VARCHAR2
                           ,errcode OUT NOCOPY NUMBER
							,p_legal_entity_id  NUMBER
							,cp_year_start_date VARCHAR2
							,cp_year_end_date VARCHAR2
							,p_order_by  VARCHAR2
									 )
  IS


   CURSOR cur_withholding_extract(p_legal_entity_id NUMBER, cp_year_start_date VARCHAR2,cp_year_end_date VARCHAR2,p_order_by VARCHAR2)
	IS
	SELECT   aps.vendor_name
 		 , aps.vendor_id ,
            NVL (papf.national_identifier,
                 NVL (aps.individual_1099, aps.num_1099)
                ) taxpayer_id,
            aps.segment1
			, apss.vendor_site_code ,
            apss.vendor_site_id ,
            apss.vat_registration_num ,
            apss.address_line1 ,
            apss.address_line2 ,
            apss.address_line3 ,
               apss.address_line1
            || DECODE (apss.address_line2,
                       NULL, NULL,
                       ', ' || apss.address_line2
                      )
            || DECODE (apss.address_line3,
                       NULL, NULL,
                       ', ' || apss.address_line3
                      ) supplier_address,
            apss.city
			, apss.zip ,
            apss.province
			, apss.country ,
            inv.invoice_id ,
            NVL (inv.base_amount, inv.invoice_amount) invoice_amount,
            NVL (aip.payment_base_amount, aip.amount) amount_paid,
            inv.invoice_num
			,dist.exempt_amount
			,inv.invoice_type_lookup_code
       FROM ap_supplier_sites_all apss,
            ap_suppliers aps,
            (SELECT DISTINCT person_id, national_identifier
                        FROM per_all_people_f) papf
			,(SELECT SUM (DECODE (dist1.line_type_lookup_code,
								'ITEM', NVL (SIGN (dist1.awt_group_id) - 1, 1)
								 * NVL (dist1.base_amount, dist1.amount),
								'PREPAY', NVL (SIGN (dist1.awt_group_id) - 1, 1)
								 * NVL (dist1.base_amount, dist1.amount),
								0
							   )
								) exempt_amount
								   ,dist1.invoice_id
									FROM ap_invoice_distributions_all dist1,ap_invoices_all inv1
									WHERE dist1.invoice_id = inv1.invoice_id
									AND dist1.line_type_lookup_code = 'ITEM'
									AND dist1.awt_group_id IS NULL
									group by dist1.invoice_id)dist
            ,ap_invoices_all inv,
            ap_invoice_payments_all aip,
            ap_checks_all checks
WHERE 	 inv.legal_entity_id = p_legal_entity_id
		AND inv.invoice_id = dist.invoice_id
        AND inv.invoice_id = aip.invoice_id
        AND (   aip.posted_flag IN ('Y', 'P')
             OR aip.cash_posted_flag IN ('Y', 'P')
             OR aip.accrual_posted_flag IN ('Y', 'P')
            )
        AND inv.vendor_id = aps.vendor_id
        AND inv.vendor_site_id = apss.vendor_site_id
        AND aps.vendor_id = apss.vendor_id
        AND NVL (aps.employee_id, -99) = papf.person_id(+)
        AND aip.check_id = checks.check_id
        AND checks.void_date IS NULL
        AND aip.accounting_date BETWEEN cp_year_start_date AND cp_year_end_date
		      AND aip.invoice_payment_id =
               (SELECT   MAX (aip_sub.invoice_payment_id)
                    FROM ap_invoice_payments_all aip_sub
                   WHERE aip_sub.invoice_id = inv.invoice_id
                     AND aip_sub.accounting_date BETWEEN cp_year_start_date
                                                     AND cp_year_end_date
                GROUP BY aip_sub.invoice_id)
        AND EXISTS (
               SELECT 1
                 FROM ap_invoice_payments_all aip_sub2,
                      ap_invoice_distributions_all dist
                WHERE aip_sub2.invoice_payment_id =
                         DECODE (dist.line_type_lookup_code,
                                 'AWT', dist.awt_invoice_payment_id,
                                 aip_sub2.invoice_payment_id
                                )
                  AND aip_sub2.accounting_date BETWEEN cp_year_start_date
                                                   AND cp_year_end_date
				  )
	GROUP BY aps.vendor_name,
            aps.vendor_id,
            NVL (papf.national_identifier,
                 NVL (aps.individual_1099, aps.num_1099)
                ),
            aps.segment1,
            apss.vendor_site_code,
            apss.vendor_site_id,
            apss.vat_registration_num,
            apss.address_line1,
            apss.address_line2,
            apss.address_line3,
               apss.address_line1
            || DECODE (apss.address_line2,
                       NULL, NULL,
                       ', ' || apss.address_line2
                      )
            || DECODE (apss.address_line3,
                       NULL, NULL,
                       ', ' || apss.address_line3
                      ),
            apss.city,
            apss.zip,
            apss.province,
            apss.country,
            inv.invoice_id,
            NVL (inv.base_amount, inv.invoice_amount),
            NVL (aip.payment_base_amount, aip.amount),
            inv.invoice_num
	       ,dist.exempt_amount
		   ,inv.invoice_type_lookup_code
		ORDER BY p_order_by;

	CURSOR cur_withholding_invoice(p_invoice_id NUMBER)
	IS
	SELECT count(1)rec_count
	  FROM ap_awt_group_taxes_all awt
	 WHERE awt.GROUP_ID IN (
                   SELECT DISTINCT dist.awt_origin_group_id
                              FROM ap_invoice_distributions_all dist,
                                   ap_invoices_all inv
                             WHERE dist.invoice_id = inv.invoice_id
							   AND dist.line_type_lookup_code ='AWT'
                               AND inv.invoice_id = p_invoice_id
							   );

---Declaring  Variable
 ln_inps_wthamount 			NUMBER;
 ln_irpef_wthamount 		NUMBER;
 ln_inps_rate  			 	NUMBER;
 ln_irpef_rate				NUMBER;
 lc_inps_taxname  			VARCHAR2(100);
 lc_irpef_taxname  			VARCHAR2(100);
 ln_taxable_amount  		NUMBER;
 lc_inps_vendor_name		VARCHAR2(100);
 lc_irpef_vendor_name		VARCHAR2(100);
 ln_tax_amount_one   		NUMBER;
 ln_tax_amount_two   		NUMBER;
 ln_tax_amount       		NUMBER;
 ln_ex_amount1				NUMBER;
 ln_ex_amount2				NUMBER;
 ln_ex_amount				NUMBER;
 ln_inv_num					VARCHAR2(100);



 --Declaring   Cursors
 cur_withholding_extract_rec             cur_withholding_extract%ROWTYPE;
 cur_withholding_invoice_rec			 cur_withholding_invoice%ROWTYPE;


BEGIN

      OPEN  cur_withholding_extract(p_legal_entity_id,cp_year_start_date,cp_year_end_date,lp_order_by);
       LOOP
          FETCH cur_withholding_extract  INTO  cur_withholding_extract_rec;
          EXIT when cur_withholding_extract%NOTFOUND;

		       OPEN  cur_withholding_invoice(cur_withholding_extract_rec.invoice_id);
		       LOOP
		       FETCH cur_withholding_invoice  INTO  cur_withholding_invoice_rec;
		       EXIT when cur_withholding_invoice%NOTFOUND;



         IF(cur_withholding_invoice_rec.rec_count > 1) THEN

	--fnd_file.put_line(fnd_file.log,'Starting Invoice Id..'||cur_withholding_extract_rec.invoice_id );

		    BEGIN
				SELECT SUM (NVL (dist.base_amount, dist.amount))
				  INTO ln_ex_amount1
				  FROM ap_invoice_distributions_all dist
				 WHERE dist.invoice_id = cur_withholding_extract_rec.invoice_id
				   AND dist.line_type_lookup_code = 'ITEM'
				   AND dist.pay_awt_group_id IS NULL;

				SELECT SUM (NVL (dist.base_amount, dist.amount))
				  INTO ln_ex_amount2
				  FROM ap_invoice_distributions_all dist
				 WHERE dist.invoice_id = cur_withholding_extract_rec.invoice_id
				   AND dist.line_type_lookup_code = 'ITEM'
				   AND (dist.pay_awt_group_id) IN (
				          SELECT awgt_sub.GROUP_ID
				            FROM ap_tax_codes_all atc_sub,
				                 ap_awt_tax_rates_all awt_sub,
				                 ap_awt_group_taxes_all awgt_sub
				           WHERE awgt_sub.tax_name = awt_sub.tax_name
				             AND atc_sub.NAME = awt_sub.tax_name
				             AND awt_sub.tax_rate = 0);

			ln_ex_amount := nvl(ln_ex_amount1,0) + nvl(ln_ex_amount2,0);

			EXCEPTION
			   WHEN NO_DATA_FOUND
			   THEN
				  ln_ex_amount := 0;
			END;

			BEGIN
			   SELECT SUM (NVL (dist.base_amount, dist.amount))
				   INTO ln_tax_amount_one
					FROM ap_invoice_distributions_all dist
				   WHERE dist.invoice_id = cur_withholding_extract_rec.invoice_id
					 AND dist.line_type_lookup_code = 'ITEM'
					 AND dist.awt_group_id IS NULL;

				SELECT SUM (NVL (dist.base_amount, dist.amount))
				  INTO ln_tax_amount_two
				  FROM ap_invoice_distributions_all dist
					 , ap_awt_group_taxes_all awt
				 WHERE dist.invoice_id = invoice_id
				   AND NVL (dist.awt_group_id, dist.awt_origin_group_id) = awt.group_id
				   AND dist.org_id = awt.org_id
				   AND dist.invoice_id = cur_withholding_extract_rec.invoice_id
				   AND dist.line_type_lookup_code = 'ITEM'
				   AND NVL (dist.awt_group_id, dist.awt_origin_group_id) NOT IN (
						  SELECT awgt_sub.GROUP_ID
							FROM ap_tax_codes_all atc_sub,
								 ap_awt_tax_rates_all awt_sub,
								 ap_awt_group_taxes_all awgt_sub
						   WHERE awgt_sub.tax_name = awt_sub.tax_name
							 AND atc_sub.NAME = awt_sub.tax_name
							 AND awt_sub.tax_rate = 0);

			ln_tax_amount := NVL (ln_tax_amount_one, 0) + NVL (ln_tax_amount_two, 0);

			EXCEPTION
			   WHEN NO_DATA_FOUND
			   THEN
				  ln_tax_amount := 0;
			END;


			BEGIN
			   SELECT   awt.tax_rate, awt.tax_name,
						ROUND (SUM (NVL (dist.base_amount, dist.amount)) * (-1),
							   cp_precision
							  ) wth_amount,
						aps.vendor_name
				   INTO ln_irpef_rate, lc_irpef_taxname,
						ln_irpef_wthamount,
						lc_irpef_vendor_name
				   FROM ap_invoice_distributions_all dist,
						ap_tax_codes_all atc,
						ap_invoices_all inv1,
						ap_awt_tax_rates_all awt,
						ap_suppliers aps
				  WHERE dist.invoice_id = inv1.invoice_id
					AND inv1.invoice_id = cur_withholding_extract_rec.invoice_id
					AND dist.line_type_lookup_code = atc.tax_type
					AND dist.line_type_lookup_code = 'AWT'
					AND atc.NAME = awt.tax_name
					AND awt.tax_rate_id = dist.awt_tax_rate_id
					AND awt.vendor_id IS NULL
					AND atc.awt_vendor_id = aps.vendor_id
					AND aps.vendor_name = g_irpef
					AND aps.vendor_type_lookup_code = 'TAX AUTHORITY'
			   GROUP BY awt.tax_rate, awt.tax_name, aps.vendor_name;
			EXCEPTION
			   WHEN NO_DATA_FOUND
			   THEN
				  ln_irpef_rate := 0;
				  lc_irpef_taxname := NULL;
				  ln_irpef_wthamount := 0;
				  lc_irpef_vendor_name := NULL;
			END;

			BEGIN
			   SELECT   awt.tax_rate, awt.tax_name,
						ROUND (SUM (NVL (dist.base_amount, dist.amount)) * (-1),
							   cp_precision
							  ) wth_amount,
						aps.vendor_name
				    INTO ln_inps_rate, lc_inps_taxname,
						 ln_inps_wthamount,
						 lc_inps_vendor_name
				    FROM ap_invoice_distributions_all dist,
						ap_tax_codes_all atc,
						ap_invoices_all inv1,
						ap_awt_tax_rates_all awt,
						ap_suppliers aps
				    WHERE dist.invoice_id = inv1.invoice_id
					AND inv1.invoice_id = cur_withholding_extract_rec.invoice_id
					AND dist.line_type_lookup_code = atc.tax_type
					AND dist.line_type_lookup_code = 'AWT'
					AND atc.NAME = awt.tax_name
					AND awt.tax_rate_id = dist.awt_tax_rate_id
					AND awt.vendor_id IS NULL
					AND atc.awt_vendor_id = aps.vendor_id
					AND aps.vendor_name = g_inps
					AND aps.vendor_type_lookup_code = 'TAX AUTHORITY'
			    GROUP BY awt.tax_rate, awt.tax_name, aps.vendor_name;
			EXCEPTION
			    WHEN NO_DATA_FOUND
			    THEN
				  ln_inps_rate := 0;
				  lc_inps_taxname := NULL;
				  ln_inps_wthamount := 0;
				  lc_inps_vendor_name := NULL;
			END;

----Prepayment
--fnd_file.put_line(fnd_file.log,'Invoice Type Lookup Code...'||cur_withholding_extract_rec.invoice_type_lookup_code );

     IF(cur_withholding_extract_rec.invoice_type_lookup_code = 'PREPAYMENT' ) THEN

            BEGIN
						SELECT DISTINCT apinv_sub.invoice_num
						        INTO ln_inv_num
						        FROM ap_invoices_all apinv_sub,
						             ap_invoice_distributions_all apdist1_sub,
						             ap_invoice_distributions_all apdist2_sub
						        WHERE apdist2_sub.invoice_id = cur_withholding_extract_rec.invoice_id
						         AND apdist2_sub.invoice_distribution_id =
						                                            apdist1_sub.prepay_distribution_id
						         AND apdist1_sub.invoice_id = apinv_sub.invoice_id
						         AND apdist1_sub.reversal_flag <> 'Y';
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
			fnd_file.put_line(fnd_file.log,'No Data Found.'||SQLERRM);
              	ln_inv_num:=cur_withholding_extract_rec.invoice_num;

            WHEN TOO_MANY_ROWS THEN
 				fnd_file.put_line(fnd_file.log,'More Than One Invoice Record Found.'||SQLERRM);
				ln_inv_num:= cur_withholding_extract_rec.invoice_num;
			END;
	ELSE
	--	fnd_file.put_line(fnd_file.log,'Not a prepayment Invoice Type Lookup Code...'||cur_withholding_extract_rec.invoice_type_lookup_code );
      		ln_inv_num:= cur_withholding_extract_rec.invoice_num;

	END IF;

--Checking for the Taxable amount in accordance with the Exempt Amount
--If Exempt Amount exits then Taxable amount should be 0

    IF(ln_ex_amount > 0 ) THEN
	 ln_tax_amount := 0;
	END IF;




					BEGIN
						 INSERT INTO JG_ZZ_VAT_TRX_GT
								(jg_info_v1, jg_info_n1, jg_info_v2, jg_info_v3, jg_info_v4,
								 jg_info_n2, jg_info_v5, jg_info_v6, jg_info_v7, jg_info_v8,
								 jg_info_v9, jg_info_v10, jg_info_v11, jg_info_v12, jg_info_v13,
								 jg_info_n3, jg_info_n4, jg_info_n5, jg_info_v14, jg_info_n6,
								 jg_info_n7, jg_info_n8, jg_info_n9, jg_info_v15, jg_info_v16,
								 jg_info_n10, jg_info_n11, jg_info_n12, jg_info_n13, jg_info_n14
								 ,jg_info_n15,jg_info_v17,jg_info_v18)
								 VALUES(
								 cur_withholding_extract_rec.vendor_name
								 ,cur_withholding_extract_rec.vendor_id
								 ,cur_withholding_extract_rec.taxpayer_id
								 ,cur_withholding_extract_rec.segment1
								 ,cur_withholding_extract_rec.vendor_site_code
								 ,cur_withholding_extract_rec.vendor_site_id
								 ,cur_withholding_extract_rec.vat_registration_num
								 ,cur_withholding_extract_rec.address_line1
								 ,cur_withholding_extract_rec.address_line2
								 ,cur_withholding_extract_rec.address_line3
								 ,cur_withholding_extract_rec.supplier_address
								 ,cur_withholding_extract_rec.city
								 ,cur_withholding_extract_rec.zip
								 ,cur_withholding_extract_rec.province
								 ,cur_withholding_extract_rec.country
								 ,cur_withholding_extract_rec.invoice_id
								 ,cur_withholding_extract_rec.invoice_amount
								 ,cur_withholding_extract_rec.amount_paid
								 ,ln_inv_num
								 ,ln_inps_wthamount
								 ,ln_irpef_wthamount
								 ,ln_inps_rate
								 ,ln_irpef_rate
								 ,lc_inps_taxname
								 ,lc_irpef_taxname
								 ,cur_withholding_extract_rec.amount_paid
								 ,ROUND( (cur_withholding_extract_rec.amount_paid +ln_inps_wthamount+ln_irpef_wthamount )
									/DECODE(ln_ex_amount,0,1,cur_withholding_extract_rec.exempt_amount),10)
								 ,ROUND (ROUND( (cur_withholding_extract_rec.amount_paid +ln_inps_wthamount+ln_irpef_wthamount )
									/DECODE(ln_ex_amount,0,1,cur_withholding_extract_rec.exempt_amount),10) *
									DECODE(ln_ex_amount,0,1,cur_withholding_extract_rec.exempt_amount), cp_precision)
								 ,ln_ex_amount
								  ,ln_tax_amount
								  ,p_legal_entity_id
								  ,lc_inps_vendor_name
								  ,lc_irpef_vendor_name
								   );

					EXCEPTION
					WHEN OTHERS THEN
					fnd_file.put_line(fnd_file.log,'Unable to insert Record.'||SQLERRM);
					END;
			END IF;

		END LOOP;
        CLOSE cur_withholding_invoice;

	  END LOOP;
      CLOSE cur_withholding_extract;

 EXCEPTION
 WHEN OTHERS THEN
   ROLLBACK;

  END je_withholding;


-----------------------------------------------------------------------------------------------------------------------------------------------------
------------Functions to refer Oracle report placeholders------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
--Precision
   FUNCTION cp_precision_p
      RETURN NUMBER
   IS
   BEGIN

      RETURN cp_precision;
   END;

   FUNCTION cp_irpef_p
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_irpef;
   END;

   FUNCTION  cp_inps_p
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_inps;
   END;

END je_itwhye_ap_pkg ;

/
