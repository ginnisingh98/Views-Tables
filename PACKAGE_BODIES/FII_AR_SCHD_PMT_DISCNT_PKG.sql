--------------------------------------------------------
--  DDL for Package Body FII_AR_SCHD_PMT_DISCNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_SCHD_PMT_DISCNT_PKG" AS
/*  $Header: FIIARDBISPDB.pls 120.6.12000000.1 2007/02/23 02:28:58 applrt ship $ */

-- This package will provide SQL statement to retrieve data for Scheduled Payments and Discounts Report

PROCEDURE get_schd_pmt_discnt ( p_page_parameter_tbl      IN BIS_PMV_PAGE_PARAMETER_TBL
                               ,p_schd_pmt_discnt_sql     OUT NOCOPY VARCHAR2
			       ,p_schd_pmt_discnt_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
			      ) IS

  l_sqlstmt                     VARCHAR2(30000);
  l_cust_trx_id			VARCHAR2(30);

BEGIN
  -- Call to reset the parameter variables

  fii_ar_util_pkg.reset_globals;

  -- Call to get all the parameters in the report

  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

-- Done for bug# 5151282
  IF fii_ar_util_pkg.g_cust_trx_id = 'All' THEN
      l_cust_trx_id := '-99999';
  ELSE
      l_cust_trx_id := ':CUST_TRX_ID';
  END IF;

-- PMV SQL to display data on Scheduled Payments and Discounts Report

l_sqlstmt :=  'SELECT pmt.terms_sequence_number		FII_AR_SCHD_PMT_NUMBER
		     ,pmt.due_date			FII_AR_DUE_DATE
		     ,pmt.amount_due_original_trx	FII_AR_AMOUNT
		     ,CASE WHEN sch.discount1_date IS NULL AND sch.discount1_days IS NOT NULL
			      THEN pmt.trx_date + sch.discount1_days
			   WHEN sch.discount1_date IS NULL AND sch.discount1_days IS NULL
			      THEN LAST_DAY(ADD_MONTHS(pmt.trx_date,sch.discount1_months_forward -1 ))
					+ sch.discount1_day_of_month
                      ELSE sch.discount1_date
                       END		FII_AR_DISCOUNT_DATE
		     ,sch.discount1_percent * pmt.amount_due_original_trx/100
						        FII_AR_DISCOUNT_AMT
		     ,CASE WHEN sch.discount2_date IS NULL AND sch.discount2_days IS NOT NULL
			      THEN pmt.trx_date + sch.discount2_days
			   WHEN sch.discount2_date IS NULL AND sch.discount2_days IS NULL
			      THEN LAST_DAY(ADD_MONTHS(pmt.trx_date,sch.discount2_months_forward -1 ))
					+ sch.discount2_day_of_month
                      ELSE sch.discount2_date
                       END		FII_AR_SECOND_DISCOUNT_DATE
		     ,sch.discount2_percent * pmt.amount_due_original_trx/100
							FII_AR_SECOND_DISCOUNT_AMT
		     ,CASE WHEN sch.discount3_date IS NULL AND sch.discount3_days IS NOT NULL
			      THEN pmt.trx_date + sch.discount3_days
			   WHEN sch.discount3_date IS NULL AND sch.discount3_days IS NULL
			      THEN LAST_DAY(ADD_MONTHS(pmt.trx_date,sch.discount3_months_forward -1 ))
					+ sch.discount3_day_of_month
                      ELSE sch.discount3_date
                       END		FII_AR_THIRD_DISCOUNT_DATE
		     ,sch.discount3_percent * pmt.amount_due_original_trx/100
						        FII_AR_THIRD_DISCOUNT_AMT
		     ,SUM(pmt.amount_due_original_trx) OVER ()
							FII_AR_GT_AMOUNT
                 FROM fii_ar_scheduled_disc_f  sch
                     ,fii_ar_pmt_schedules_f   pmt
                WHERE sch.term_id (+)= pmt.term_id
		  AND sch.sequence_num (+) = pmt.terms_sequence_number
		  AND pmt.customer_trx_id = '||l_cust_trx_id||'
	       &ORDER_BY_CLAUSE';

-- Call to UTIL package to bind the variables

   fii_ar_util_pkg.bind_variable(l_sqlstmt
                                ,p_page_parameter_tbl
				,p_schd_pmt_discnt_sql
				,p_schd_pmt_discnt_output
				);

END get_schd_pmt_discnt;

END fii_ar_schd_pmt_discnt_pkg;

/
