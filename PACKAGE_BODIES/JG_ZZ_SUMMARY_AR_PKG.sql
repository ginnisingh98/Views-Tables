--------------------------------------------------------
--  DDL for Package Body JG_ZZ_SUMMARY_AR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_SUMMARY_AR_PKG" 
-- $Header: jgzzsummaryarb.pls 120.14.12010000.3 2010/01/03 11:37:35 pakumare ship $
AS

gv_debug constant boolean := true;

FUNCTION app_vatformula(p_applied        IN VARCHAR2
                      , p_tax_rate_id    IN NUMBER
                      , p_a_date         IN VARCHAR2
                      , p_amount_applied IN NUMBER
                      , p_amount         IN NUMBER) RETURN NUMBER
-- +======================================================================+
-- | Name :              app_vatformula                                   |
-- | Description :       This function returns the applied vat amount     |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

   DECLARE
   l_taxrate NUMBER;
   BEGIN
      IF p_applied = JG_ZZ_SUMMARY_AR_PKG.g_unapplied THEN
        RETURN(0);
      END IF;

      SELECT NVL(ZRB.percentage_rate,ZRB.quantity_rate)
      INTO l_taxrate
      FROM zx_rates_b ZRB
      WHERE ZRB.tax_rate_id = P_TAX_RATE_ID
      /* UT TEST. these effectivity dates checking is not required for Reporting
      AND p_a_date          >= NVL(ZRB.effective_from, TO_DATE('01-01-1895', 'DD-MM-YYYY'))
      AND p_a_date          <= NVL(ZRB.effective_to, TO_DATE('31-12-2195', 'DD-MM-YYYY')) */
      ;

      IF p_amount>= p_amount_applied THEN
        RETURN(ROUND(ABS(p_amount_applied)*(1-1/(1+l_taxrate/100.0)),2)*-1);
      ELSE
        RETURN(ROUND(p_amount*(1-1/(1+l_taxrate/100.0)),2)*-1);
      END IF;
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;

   RETURN NULL;
END;

FUNCTION new_receiptformula(p_r_date            IN VARCHAR2
                          , p_period_start_date IN DATE
                          , p_period_end_date   IN DATE) RETURN VARCHAR2
-- +======================================================================+
-- | Name :              new_receiptformula                               |
-- | Description :       This function returns the new receipt            |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

  DECLARE
  l_new VARCHAR2(3);
  BEGIN
    SELECT 'Yes' INTO l_new
    FROM DUAL
    WHERE p_r_date BETWEEN NVL(P_PERIOD_START_DATE,TO_DATE('01-01-1690','DD-MM-YYYY'))
    AND NVL(P_PERIOD_END_DATE,TO_DATE('31-12-2690','DD-MM-YYYY'));
    RETURN(l_new);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(l_new);
  END;

  RETURN NULL;
END;

FUNCTION new_applicationformula(p_a_date            IN VARCHAR2
                              , p_period_start_date IN DATE
                              , p_period_end_date   IN DATE) RETURN VARCHAR2
-- +======================================================================+
-- | Name :              new_applicationformula                           |
-- | Description :       This function returns the new application        |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

   DECLARE
   l_new VARCHAR2(3);
   BEGIN
      SELECT 'Yes'
      INTO l_new
      FROM DUAL
      WHERE p_a_date BETWEEN NVL(p_period_start_date,TO_DATE('01-01-1700','DD-MM-YYYY')) AND NVL(p_period_end_date,TO_DATE('31-12-4000','DD-MM-YYYY'));
      RETURN(l_new);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN(l_new);
   END;
   RETURN NULL;
END;

FUNCTION new_amountformula(p_r_date IN VARCHAR2
                         , p_amount IN NUMBER
                         , p_period_start_date IN DATE
                         , p_period_end_date IN DATE) RETURN NUMBER
-- +======================================================================+
-- | Name :              new_amountformula                                |
-- | Description :       This function returns the new amount             |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

   BEGIN
      IF p_r_date BETWEEN NVL(p_period_start_date,TO_DATE('01-01-1690','DD-MM-YYYY')) AND NVL(p_period_end_date,TO_DATE('31-12-2690','DD-MM-YYYY')) THEN
         RETURN(p_amount);
      ELSE
         RETURN(0);
      END IF;
   END;
   RETURN NULL;
END;

FUNCTION new_app_vatformula(p_a_date  IN VARCHAR2
                          , p_app_vat IN NUMBER
                          , p_period_start_date IN DATE
                          , p_period_end_date IN DATE) RETURN NUMBER
-- +======================================================================+
-- | Name :              new_app_vatformula                               |
-- | Description :       This function returns the new applied vat amount |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

   BEGIN
      IF p_a_date between NVL(p_period_start_date,TO_DATE('01-01-1700','DD-MM-YYYY')) AND NVL(p_period_end_date, to_date('31-12-4000','DD-MM-YYYY')) THEN
         RETURN (p_app_vat);
      ELSE
         RETURN(0);
      END IF;
   END;
   RETURN NULL;
END;

FUNCTION new_unapp_vatformula(p_a_date    IN VARCHAR2
                            , p_unapp_vat IN NUMBER
                            , p_period_start_date IN DATE
                            , p_period_end_date IN DATE) RETURN NUMBER
-- +======================================================================+
-- | Name :              new_unapp_vatformula                             |
-- | Description :       This function returns the new unapplied vat amount|
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

   BEGIN
      IF p_a_date BETWEEN NVL(p_period_start_date,TO_DATE('01-01-1700','DD-MM-YYYY')) AND NVL(p_period_end_date,TO_DATE('31-12-4000','DD-MM-YYYY')) THEN
         RETURN (p_unapp_vat);
      ELSE
         RETURN(0);
      END IF;
   END;
   RETURN NULL;
END;

FUNCTION unapp_vatformula(p_applied        IN VARCHAR2
                        , p_tax_rate_id    IN NUMBER
                        , p_a_date         IN VARCHAR2
                        , p_amount_applied IN NUMBER
                        , p_amount         IN NUMBER) RETURN NUMBER
-- +======================================================================+
-- | Name :              unapp_vatformula                                 |
-- | Description :       This function returns the unapplied vat amount   |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

   DECLARE
   l_taxrate number;
   BEGIN
      IF p_applied = JG_ZZ_SUMMARY_AR_PKG.g_applied THEN
        RETURN(0);
      END IF;

      SELECT NVL(ZRB.percentage_rate,ZRB.quantity_rate)
      INTO l_taxrate
      FROM zx_rates_b ZRB
      WHERE ZRB.tax_rate_id = P_TAX_RATE_ID
      AND p_a_date          >= NVL(ZRB.effective_from, TO_DATE('01-01-1895', 'DD-MM-YYYY'))
      AND p_a_date          <= NVL(ZRB.effective_to, TO_DATE('31-12-2195', 'DD-MM-YYYY'));

      IF p_amount>= p_amount_applied THEN
         RETURN(ROUND(ABS(p_amount_applied)*(1-1/(1+l_taxrate/100.0)),2));
      ELSE
         RETURN(ROUND(p_amount*(1-1/(1+l_taxrate/100.0)),2));
      END IF;
   END;
   RETURN NULL;
END;

FUNCTION new_aaformula(p_a_date         IN VARCHAR2
                     , p_applied        IN VARCHAR2
                     , p_amount_applied IN NUMBER
                     , p_period_start_date IN DATE
                     , p_period_end_date IN DATE) RETURN NUMBER
-- +======================================================================+
-- | Name :              new_aaformula                                    |
-- | Description :       This function returns the new applied amount     |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

   BEGIN
      IF p_a_date BETWEEN NVL(p_period_start_date,TO_DATE('01-01-1700','DD-MM-YYYY')) AND NVL(p_period_end_date,TO_DATE('31-12-4000','DD-MM-YYYY'))
         AND p_Applied = JG_ZZ_SUMMARY_AR_PKG.g_applied THEN
         RETURN (p_amount_applied);
      ELSE
         RETURN(0);
      END IF;
   END;
   RETURN NULL;
END;

FUNCTION new_auformula(p_a_date         IN VARCHAR2
                     , p_applied        IN VARCHAR2
                     , p_amount_applied IN NUMBER
                     , p_period_start_date IN DATE
                     , p_period_end_date IN DATE) RETURN NUMBER
-- +======================================================================+
-- | Name :              new_auformula                                    |
-- | Description :       This function returns the new applied amount     |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

   BEGIN
      IF p_a_date BETWEEN NVL(p_period_start_date,TO_DATE('01-01-1700','DD-MM-YYYY')) AND NVL(p_period_end_date,TO_DATE('31-12-4000','DD-MM-YYYY'))
         AND p_applied = JG_ZZ_SUMMARY_AR_PKG.g_unapplied THEN
         RETURN (p_amount_applied);
      ELSE
         RETURN(0);
      END IF;
   END;
   RETURN NULL;
END;

FUNCTION ZEROFormula RETURN NUMBER
-- +======================================================================+
-- | Name :              ZEROFormula                                      |
-- | Description :       This function returns the zero                   |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

   RETURN(0);
END;

FUNCTION vatformula(p_applied        IN VARCHAR2
                  , p_disp_app_vat   IN VARCHAR2
                  , p_disp_unapp_vat IN VARCHAR2) RETURN VARCHAR2
-- +======================================================================+
-- | Name :              vatformula                                       |
-- | Description :       This function returns the vat                    |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

   BEGIN
      IF p_applied = JG_ZZ_SUMMARY_AR_PKG.g_applied THEN
         RETURN (p_disp_app_vat);
      END IF;
      RETURN (p_disp_unapp_vat);
   END;
   RETURN NULL;
END;

FUNCTION rdformula(p_rev_date IN DATE
                 , p_period_start_date IN DATE
                 , p_period_end_date IN DATE) RETURN NUMBER
-- +======================================================================+
-- | Name :              rdformula                                        |
-- | Description :       This function returns the rd value               |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

   DECLARE
   l_rd NUMBER;
   BEGIN
      l_rd := 0;
      SELECT 1
      INTO l_rd
      FROM DUAL
      WHERE p_rev_date  BETWEEN NVL(p_period_start_date,TO_DATE('01-01-1890' ,'DD-MM-YYYY')) AND NVL(p_period_end_date,TO_DATE('30-12-2199','DD-MM-YYYY'));
      RETURN (l_rd);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN(l_rd);
   END;
  RETURN NULL;
END;

FUNCTION new_reversalformula(p_rev_date         IN DATE
                           , p_period_start_date IN DATE
                           , p_period_end_date   IN DATE) RETURN VARCHAR2
-- +======================================================================+
-- | Name :              new_reversalformula                              |
-- | Description :       This function returns the new reversal value     |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

   DECLARE
   l_new VARCHAR2(3);
   BEGIN
      SELECT 'Yes'
      INTO l_new
      FROM DUAL
      WHERE p_rev_date BETWEEN NVL(p_period_start_date,TO_DATE('01-01-1690','DD-MM-YYYY')) AND NVl(p_period_end_date,TO_DATE('31-12-2690','DD-MM-YYYY'));
      RETURN(l_new);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN(l_new);
   END;
   RETURN NULL;
END;

FUNCTION new_rev_amountformula(p_rd         IN NUMBER
                             , p_rev_amount IN NUMBER) RETURN NUMBER

-- +======================================================================+
-- | Name :              new_rev_amountformula                            |
-- | Description :       This function returns the new reversal amount    |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

   RETURN (p_rd * p_rev_amount);
END;

FUNCTION new_rev_taxformula(p_rd      IN NUMBER
                          , p_rev_tax IN NUMBER) RETURN NUMBER
-- +======================================================================+
-- | Name :              new_rev_taxformula                               |
-- | Description :       This function returns the new reversal tax amount|
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN
   RETURN (p_rd * p_rev_tax);
END;

FUNCTION new_r_taxformula(p_r_date            IN VARCHAR2
                        , p_r_tax             IN NUMBER
                        , p_period_start_date IN DATE
                        , p_period_end_date   IN DATE) RETURN NUMBER
-- +======================================================================+
-- | Name :              new_r_taxformula                                 |
-- | Description :       This function returns the new tax amount         |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+
IS
BEGIN

   BEGIN
      IF p_r_date BETWEEN NVL(p_period_start_date,TO_DATE('01-01-1690','DD-MM-YYYY')) AND NVL(p_period_end_date,TO_DATE('31-12-2690','DD-MM-YYYY')) THEN
         RETURN(p_r_tax);
      ELSE
         RETURN(0);
      END IF;
   END;
   RETURN NULL;
END;


/*
|| Added by Ramananda
|| The following function will consider the tax line based on the
|| arguments passed from the data template
*/
FUNCTION is_tax_status( p_tax_status      IN VARCHAR2
                       ,p_context         IN VARCHAR2
                       ,p_tax_rate        IN NUMBER   DEFAULT NULL)
RETURN BOOLEAN
IS
BEGIN

  IF p_tax_status  = 'Non-Taxable'              AND
     p_context = 'NON_TAXABLE'                  THEN
   return(TRUE) ;
  ELSIF p_tax_status = 'Exempt Exports'         AND
        p_context = 'EXEMPT_EXPORTS'            THEN
   return(TRUE) ;
  ELSIF p_tax_status  = 'Exempt Other'          AND
        p_context = 'EXEMPT_OTHER'              THEN
   return(TRUE) ;
  ELSIF p_tax_status  = 'Zero Rated'            AND
        p_tax_rate = 0                          AND
        p_context = 'ZERO_RATE'                 THEN
   return(TRUE) ;
  ELSIF p_tax_status IN ( 'Standard','Reduced') AND
        p_tax_rate <> 0                         AND
        p_context = 'NON_FINAL_CONSUMPTION'     THEN
   return(TRUE) ;
  ELSIF p_tax_status   = 'Final Consumption'    AND
        p_tax_rate <> 0                         AND
        p_context = 'FINAL_CONSUMPTION'         THEN
    return(TRUE) ;
  ELSE
    return(FALSE) ;
  END IF;

      return(TRUE) ;

END is_tax_status;

/* The tax_date_maintenance_program procedure not suppose to call here.
   We should run this procedure before the selection process run i.e Before the TRL call (as in 11i)
   Hence commenting this total procedure code.
*/

/*

PROCEDURE tax_date_maintenance_program(p_period_end_date IN DATE)
IS
-- +======================================================================+
-- | Name :              tax_date_maintenance_program                     |
-- | Description :       This procedure maintain the tax date             |
-- |                                        .                             |
-- |                                                                      |
-- +======================================================================+

CURSOR lcu_cust_trx
IS
SELECT JG.trx_id                                         CUSTOMER_TRX_ID
     , MAX(RPT.apply_date)                               APPLY_DATE
     , FND_DATE.CANONICAL_TO_DATE(JG.tax_invoice_date)   TAX_INVOICE_DATE
FROM jg_zz_vat_trx_details      JG
   , ar_receivable_applications RPT
WHERE JG.trx_id             = RPT.applied_customer_trx_id
AND JG.ledger_id            = RPT.set_of_books_id
AND RPT.status              = 'APP'
AND JG.tax_status_code      = 'CL'
AND RPT.amount_applied      >= 0
AND TRUNC(RPT.apply_date)   <= TRUNC(P_PERIOD_END_DATE)
AND RPT.apply_date          <  FND_DATE.CANONICAL_TO_DATE(JG.tax_invoice_date)
AND NOT EXISTS (SELECT 1
                FROM jg_zz_vat_trx_details      JGZZ
                WHERE JGZZ.trx_id      = JG.trx_id
                AND JGZZ.tax_invoice_date IS NOT NULL
                )
GROUP BY JG.trx_id
        ,JG.tax_invoice_date
;

BEGIN

   FOR rec_cust_trx IN lcu_cust_trx
   LOOP
      BEGIN
         UPDATE jg_zz_vat_trx_details      JG
         SET JG.tax_invoice_date =  FND_DATE.DATE_TO_CANONICAL(rec_cust_trx.apply_date )
         WHERE JG.trx_id =  rec_cust_trx.customer_trx_id;
      EXCEPTION
      WHEN OTHERS THEN
         NULL;
      END;

   END LOOP;
   COMMIT;

EXCEPTION
WHEN OTHERS THEN
   NULL;
END;   */

PROCEDURE InsertIntoGlobal (
                            p_jg_info_n1   IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n2   IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n3   IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n4   IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n5   IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n6   IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n7   IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n8   IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n9   IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n11  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n14  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n15  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n16  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n17  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n18  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n19  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n20  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n21  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n22  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n23  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n24  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n25  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n26  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_n27  IN   NUMBER     DEFAULT NULL
                          , p_jg_info_d1   IN   DATE       DEFAULT NULL
                          , p_jg_info_d2   IN   DATE       DEFAULT NULL
                          , p_jg_info_d3   IN   DATE       DEFAULT NULL
                          , p_jg_info_d4   IN   DATE       DEFAULT NULL
                          , p_jg_info_d5   IN   DATE       DEFAULT NULL
                          , p_jg_info_v1   IN   CHAR       DEFAULT NULL
                          , p_jg_info_v2   IN   CHAR       DEFAULT NULL
                          , p_jg_info_v3   IN   CHAR       DEFAULT NULL
                          , p_jg_info_v4   IN   CHAR       DEFAULT NULL
                          , p_jg_info_v5   IN   CHAR       DEFAULT NULL
                          , p_jg_info_v6   IN   CHAR       DEFAULT NULL
                          , p_jg_info_v7   IN   CHAR       DEFAULT NULL
                          , p_jg_info_v8   IN   CHAR       DEFAULT NULL
                          , p_jg_info_v9   IN   CHAR       DEFAULT NULL
                          , p_jg_info_v10  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v11  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v12  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v13  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v14  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v15  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v16  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v17  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v18  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v19  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v20  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v21  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v22  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v23  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v24  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v25  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v26  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v27  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v28  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v29  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v30  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v31  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v32  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v33  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v34  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v35  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v36  IN   CHAR       DEFAULT NULL
                          , p_jg_info_v37  IN   CHAR       DEFAULT NULL
                          )
IS
-- +======================================================================+
-- | Name :              InsertIntoGlobal                                 |
-- | Description :       This procedure inserts data into the Global Temp |
-- |                     table                                            |
-- +======================================================================+
BEGIN
   INSERT INTO JG_ZZ_VAT_TRX_GT(
                                   jg_info_n1
                                 , jg_info_n2
                                 , jg_info_n3
                                 , jg_info_n4
                                 , jg_info_n5
                                 , jg_info_n6
                                 , jg_info_n7
                                 , jg_info_n8
                                 , jg_info_n9
                                 , jg_info_n11
                                 , jg_info_n14
                                 , jg_info_n15
                                 , jg_info_n16
                                 , jg_info_n17
                                 , jg_info_n18
                                 , jg_info_n19
                                 , jg_info_n20
                                 , jg_info_n21
                                 , jg_info_n22
                                 , jg_info_n23
                                 , jg_info_n24
                                 , jg_info_n25
                                 , jg_info_n26
                                 , jg_info_n27
                                 , jg_info_d1
                                 , jg_info_d2
                                 , jg_info_d3
                                 , jg_info_d4
                                 , jg_info_d5
                                 , jg_info_v1
                                 , jg_info_v2
                                 , jg_info_v3
                                 , jg_info_v4
                                 , jg_info_v5
                                 , jg_info_v6
                                 , jg_info_v7
                                 , jg_info_v8
                                 , jg_info_v9
                                 , jg_info_v10
                                 , jg_info_v11
                                 , jg_info_v12
                                 , jg_info_v13
                                 , jg_info_v14
                                 , jg_info_v15
                                 , jg_info_v16
                                 , jg_info_v17
                                 , jg_info_v18
                                 , jg_info_v19
                                 , jg_info_v20
                                 , jg_info_v21
                                 , jg_info_v22
                                 , jg_info_v23
                                 , jg_info_v24
                                 , jg_info_v25
                                 , jg_info_v26
                                 , jg_info_v27
                                 , jg_info_v28
                                 , jg_info_v29
                                 , jg_info_v30
                                 , jg_info_v31
                                 , jg_info_v32
                                 , jg_info_v33
                                 , jg_info_v34
                                 , jg_info_v35
                                 , jg_info_v36
                                 , jg_info_v37
                                   )
                             VALUES
                                   (
                                     p_jg_info_n1
                                   , p_jg_info_n2
                                   , p_jg_info_n3
                                   , p_jg_info_n4
                                   , p_jg_info_n5
                                   , p_jg_info_n6
                                   , p_jg_info_n7
                                   , p_jg_info_n8
                                   , p_jg_info_n9
                                   , p_jg_info_n11
                                   , p_jg_info_n14
                                   , p_jg_info_n15
                                   , p_jg_info_n16
                                   , p_jg_info_n17
                                   , p_jg_info_n18
                                   , p_jg_info_n19
                                   , p_jg_info_n20
                                   , p_jg_info_n21
                                   , p_jg_info_n22
                                   , p_jg_info_n23
                                   , p_jg_info_n24
                                   , p_jg_info_n25
                                   , p_jg_info_n26
                                   , p_jg_info_n27
                                   , p_jg_info_d1
                                   , p_jg_info_d2
                                   , p_jg_info_d3
                                   , p_jg_info_d4
                                   , p_jg_info_d5
                                   , p_jg_info_v1
                                   , p_jg_info_v2
                                   , p_jg_info_v3
                                   , p_jg_info_v4
                                   , p_jg_info_v5
                                   , p_jg_info_v6
                                   , p_jg_info_v7
                                   , p_jg_info_v8
                                   , p_jg_info_v9
                                   , p_jg_info_v10
                                   , p_jg_info_v11
                                   , p_jg_info_v12
                                   , p_jg_info_v13
                                   , p_jg_info_v14
                                   , p_jg_info_v15
                                   , p_jg_info_v16
                                   , p_jg_info_v17
                                   , p_jg_info_v18
                                   , p_jg_info_v19
                                   , p_jg_info_v20
                                   , p_jg_info_v21
                                   , p_jg_info_v22
                                   , p_jg_info_v23
                                   , p_jg_info_v24
                                   , p_jg_info_v25
                                   , p_jg_info_v26
                                   , p_jg_info_v27
                                   , p_jg_info_v28
                                   , p_jg_info_v29
                                   , p_jg_info_v30
                                   , p_jg_info_v31
                                   , p_jg_info_v32
                                   , p_jg_info_v33
                                   , p_jg_info_v34
                                   , p_jg_info_v35
                                   , p_jg_info_v36
                                   , p_jg_info_v37
                                  );
EXCEPTION
WHEN OTHERS THEN
   NULL;
END InsertIntoGlobal;

/*
REM +======================================================================+
REM Name: get_bsv
REM
REM Description: This function is called in the lcu_ger_receipt cursor for getting the
REM              BSV for each receipt.
REM
REM
REM Parameters:  p_ccid  (code combination id)
REM              p_coid  (chart of account id)
REM		 p_ledger_id (Ldger ID)
REM +======================================================================+
*/

FUNCTION get_bsv(p_ccid NUMBER,p_coid NUMBER,p_ledger_id NUMBER) RETURN NUMBER IS

l_segment VARCHAR2(30);
bal_segment_value VARCHAR2(25);

BEGIN

  SELECT application_column_name
  INTO   l_segment
  FROM   fnd_segment_attribute_values ,
         gl_ledgers gl
  WHERE    id_flex_code               = 'GL#'
    AND    attribute_value            = 'Y'
    AND    segment_attribute_type     = 'GL_BALANCING'
    AND    application_id             = 101
    AND    id_flex_num                = gl.chart_of_accounts_id
    AND    gl.chart_of_accounts_id    = p_coid
    AND    gl.ledger_id               = p_ledger_id;

  EXECUTE IMMEDIATE 'SELECT '||l_segment ||
                  ' FROM gl_code_combinations '||
                  ' WHERE code_combination_id = '||p_ccid
  INTO bal_segment_value;

  RETURN (bal_segment_value);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_file.put_line(fnd_file.log,' No record was returned for the GL_Balancing segment. Error : ' || SUBSTR(SQLERRM,1,200));
      RETURN NULL;

END get_bsv;

FUNCTION beforeReport RETURN BOOLEAN
-- +======================================================================+
-- | Name :              beforeReport                                     |
-- | Description :       This procedure processes the data before the     |
-- |                     execution of report.                             |
-- |                                                                      |
-- +======================================================================+
IS
--JEDEDVOR - German VAT for On-account Receipts Report
/* Modified the below query a lot during UT TEST */
CURSOR lcu_ger_receipt ( P_VAT_REP_ENTITY_ID     IN NUMBER
                       , P_PERIOD                IN VARCHAR2
		       , P_LEGAL_ENTITY_ID	 IN NUMBER
		       , P_LEDGER_ID             IN NUMBER
		       , P_CHART_OF_ACC_ID       IN NUMBER
		       , P_COMPANY               IN NUMBER
		       , P_TAX_RATE_ID           IN NUMBER
		       , P_REPORTING_LEVEL       IN VARCHAR2
		       , P_GL_PERIOD_START_DATE IN DATE
		       , P_GL_PERIOD_END_DATE IN DATE)
IS
SELECT DISTINCT 'Receipt' RECEIPT,
       ac.receipt_number RECEIPT_NUMBER,
       ac.reversal_date  REV_DATE,
       decode(ac.status,'REV','Reversed',
                                    'NSF','Reversed',
                                    'STOP','Reversed') STATUS,
       ac.receipt_date  R_DATE ,
       nvl(ac.amount,0) AMOUNT,
       -1 * nvl(ac.amount,0)  REV_AMOUNT,
       at.tax_rate_code TAX_CODE,
       ac.currency_code CURRENCT_CODE,
       round(ac.amount * (1 - 1/(1 + at.PERCENTAGE_RATE/100.0)),2) R_TAX,
       -1 * round(ac.amount * (1 - 1/(1 + at.PERCENTAGE_RATE/100.0)),2) REV_TAX,
       aa.cash_receipt_id CASH_RECEIPT_ID
FROM   ar_cash_receipts_all ac,
       ar_receivable_applications_all aa,
       zx_rates_b at
WHERE aa.cash_receipt_id = ac.cash_receipt_id
AND   ac.org_id = aa.org_id
AND   at.tax_rate_id  = ac.vat_tax_id
AND  ( ( P_REPORTING_LEVEL = 'LE' AND ac.legal_entity_id = P_LEGAL_ENTITY_ID)
	OR ( P_REPORTING_LEVEL = 'LEDGER' AND ac.set_of_books_id = P_LEDGER_ID)
	OR ( P_REPORTING_LEVEL = 'BSV' AND JG_ZZ_SUMMARY_AR_PKG.get_bsv(aa.code_combination_id,P_CHART_OF_ACC_ID,P_LEDGER_ID)= P_COMPANY )
     )
AND   (ac.vat_tax_id = P_TAX_RATE_ID OR P_TAX_RATE_ID IS NULL)
AND  ( (aa.status = 'ACC')
            OR (aa.applied_customer_trx_id IN(
	             SELECT trx1.customer_trx_id
                	FROM ra_customer_trx_all trx1, ra_cust_trx_types_all type1
                  WHERE trx1.cust_trx_type_id = type1.cust_trx_type_id
			AND trx1.org_id = type1.org_id
                	AND type1.type ='DEP' )  ) )
AND   (ac.receipt_date between
            NVL(TO_DATE(P_GL_PERIOD_START_DATE ,'DD-MM-YYYY'),TO_DATE('01-01-1890' ,'DD-MM-YYYY'))
            AND NVL(TO_DATE(P_GL_PERIOD_END_DATE,'DD-MM-YYYY'),TO_DATE('30-12-2099','DD-MM-YYYY'))
             OR aa.cash_receipt_id IN
                ( SELECT distinct a1.cash_receipt_id
                  FROM ar_receivable_applications_all a1,
                        ar_receivable_applications_all a2,
                        hz_cust_accounts rc
                  WHERE
                  DECODE(SIGN(a1.amount_applied),-1,a1.gl_date,a1.gl_date) BETWEEN
                            NVL(TO_DATE(P_GL_PERIOD_START_DATE,'DD-MM-YYYY'),TO_DATE('01-01-1890','DD-MM-YYYY'))
                            AND nvl(TO_DATE(P_GL_PERIOD_END_DATE,'DD-MM-YYYY'), TO_DATE('30-12-2199','DD-MM-YYYY'))
                 AND a1.status = 'APP'
                 AND  ( (a2.status = 'ACC')
                        OR (a2.applied_customer_trx_id IN(
                            	SELECT trx2.customer_trx_id
                            	FROM ra_customer_trx trx2, ra_cust_trx_types type2
                            	WHERE trx2.cust_trx_type_id = type2.cust_trx_type_id
                            	AND type2.type ='DEP' )  ) )
                 AND a1.cash_receipt_id = a2.cash_receipt_id
		 AND a1.org_id	= a2.org_id))
ORDER BY ac.currency_code, at.tax_rate_code, ac.receipt_number,
SUBSTR(ac.receipt_date,1,10);

CURSOR lcu_ger_appl (P_CASH_RECEIPT_ID   IN NUMBER)
IS
SELECT
DECODE(SIGN(aa.amount_applied),-1,'Unapplied','Applied') APPLIED,
            aa.receivable_application_id RECEIVABLE_APPLICATION_ID,
           aa.applied_customer_trx_id APPLIED_CUSTOMER_TRX_ID,
           aa.gl_date A_DATE,
          -1 * aa.amount_applied AMOUNT_APPLIED,
           tr.invoice_currency_code INVOICE_CURRENCY_CODE,
           at.tax_rate_code TAX_CODE,
        --   aa.cash_receipt_id,
           SUBSTR(hzp.party_name,1,20) CUSTOMER_NAME,
           SUBSTR(csu.location,1,20) LOCATION,
	   at.tax_rate_id TAX_RATE_ID
        --   ac.RECEIPT_NUMBER
 FROM       ar_receivable_applications_all aa,
            zx_rates_b at,
            ar_cash_receipts_all ac,
            ra_customer_trx tr,
            hz_cust_accounts rc,
            hz_parties hzp,
            hz_cust_acct_sites cs,
            hz_cust_site_uses csu
WHERE  aa.applied_customer_trx_id = tr.customer_trx_id
AND aa.cash_receipt_id = P_CASH_RECEIPT_ID
AND ac.cash_receipt_id = aa.cash_receipt_id
AND ac.org_id = aa.org_id
AND aa.status = 'APP'
AND rc.cust_account_id  = tr.bill_to_customer_id
AND rc.party_id = hzp.party_id
AND rc.cust_account_id  = cs.cust_account_id
AND cs.cust_acct_site_id = csu.cust_acct_site_id
AND tr.bill_to_site_use_id = csu.site_use_id
AND at.tax_rate_id = ac.vat_tax_id
AND aa.gl_date  <= nvl(to_date(P_GL_PERIOD_END_DATE,'DD-MM-YYYY'),
    to_date('31-12-4000','DD-MM-YYYY'))
ORDER BY aa.receivable_application_id;

CURSOR get_tax_rate_code(p_tax_rate_id IN NUMBER)
IS
SELECT tax_rate_code
FROM zx_rates_b
WHERE tax_rate_id = p_tax_rate_id;

--JGZZARVR - ECE Receivables VAT Register Report

CURSOR lcu_euar_vatreg ( p_vat_rep_config_id   IN NUMBER
                       , p_period              IN VARCHAR2
                       , p_vat_trx_type        IN VARCHAR2
                       , p_ex_vat_trx_type     IN VARCHAR2)
IS
SELECT JG.doc_seq_value                    SEQ_NUM
      , JG.tax_rate                        TAX_RATE
      , (NVL(JG.tax_amt,0)
            + NVL(JG.taxable_amt,0))                    TRX_AMOUNT
      /* UT TEST change nvl(xxxamt__funcl_curr,0) to nvl(xxx_func_curr, xxx_amt) */
      , (NVL(JG.tax_amt_funcl_curr, tax_amt)
        + NVL(JG.taxable_amt_funcl_curr, taxable_amt))  FUNC_AMOUNT
      , NVL(JG.taxable_amt_funcl_curr, taxable_amt)     TAXABLE_AMOUNT
      , NVL(JG.tax_amt_funcl_curr, tax_amt)             TAX_AMOUNT
      , JG.tax_invoice_date                TAX_DATE
      , JG.trx_date                        INVOICE_DATE
      , JG.accounting_date                 GL_DATE
      , DECODE(JG.trx_line_class
              ,'ADJUSTMENT',JG.applied_to_trx_number
              , JG.trx_number)             INVOICE_NUMBER
      , JG.trx_id			   TRX_ID
      , JG.billing_tp_name                 CUST_NAME
      , JG.billing_tp_tax_reg_num          TAX_REG_NUM
      , JG.trx_currency_code               CURR
      , JG.tax_rate_code                   TAX_CODE
      , JG.tax_rate_code_name              TAX_DESC
      , JG.tax_rate_vat_trx_type_desc      VAT_DESC
      , JG.tax_rate_vat_trx_type_code      VAT_CODE
     -- , JGR.tax_calendar_period          PERIOD_NAME
      , glp.period_name 		   PERIOD_NAME
      , JG.tax_rate_code                   TAX_RATE_CODE
      , JG.tax_rate_code_vat_trx_type_mng  VAT_TYPE
      , glp.period_year                    PERIOD_YEAR
      , JG.account_flexfield               GL_ACcOUNT
      , JG.trx_line_class                  CLASS_CODE
      , JG.ledger_id                       LEDGER_ID
      , JGVRE.enable_report_sequence_flag  ENABLE_REPORT_SEQUENCE_FLAG
      , glp.period_num		           PERIOD_NUM
FROM jg_zz_vat_trx_details    JG
   , jg_zz_vat_rep_status     JGR
   , jg_zz_vat_rep_entities   JGVRE
   , gl_periods glp
WHERE JGR.vat_reporting_entity_id  = P_VAT_REP_ENTITY_ID
AND JGR.mapping_vat_rep_entity_id  = JGVRE.vat_reporting_entity_id
AND JG.reporting_status_id         = JGR.reporting_status_id
AND JGR.tax_calendar_period        = P_PERIOD
AND glp.period_set_name  = JGR.tax_calendar_name
AND JG.tax_invoice_date between glp.start_date and glp.end_date
AND JG.tax_rate_vat_trx_type_code IS NOT NULL
AND (JG.tax_rate_vat_trx_type_code <> P_EX_VAT_TRX_TYPE OR P_EX_VAT_TRX_TYPE IS NULL)
AND (JG.tax_rate_vat_trx_type_code = P_VAT_TRX_TYPE OR P_VAT_TRX_TYPE IS NULL)
AND JG.tax_rate_register_type_code = 'TAX'
AND JGR.source                   = 'AR'
/* UT CHANGE AND JG.extract_source_ledger       = 'AR'
AND JG.tax_invoice_date BETWEEN JGR.period_start_date AND JGR.period_end_date */
ORDER BY VAT_CODE
	 ,PERIOD_YEAR DESC
	 ,PERIOD_NUM DESC
	 ,TRX_ID
	 ,JG.tax_invoice_date
	 ,JG.tax_rate_code;

-- Created a temp_cur cursor for implementing the reporting sequence number logic.

CURSOR temp_cur ( p_vat_rep_config_id   IN NUMBER
                , p_period              IN VARCHAR2
                , p_vat_trx_type        IN VARCHAR2
                , p_ex_vat_trx_type     IN VARCHAR2)
IS
SELECT JG.tax_rate_vat_trx_type_code VAT_TRX_TYPE_CODE,
       JG.trx_id TRX_ID
FROM jg_zz_vat_trx_details    JG
   , jg_zz_vat_rep_status     JGR
   , jg_zz_vat_rep_entities   JGVRE
   , gl_periods glp
WHERE JGR.vat_reporting_entity_id  = P_VAT_REP_ENTITY_ID
AND JGR.mapping_vat_rep_entity_id  = JGVRE.vat_reporting_entity_id
AND JG.reporting_status_id         = JGR.reporting_status_id
AND JGR.tax_calendar_period        = P_PERIOD
AND glp.period_set_name  = JGR.tax_calendar_name
AND JG.tax_invoice_date between glp.start_date and glp.end_date
AND JG.tax_rate_vat_trx_type_code IS NOT NULL
AND (JG.tax_rate_vat_trx_type_code <> P_EX_VAT_TRX_TYPE OR P_EX_VAT_TRX_TYPE IS NULL)
AND (JG.tax_rate_vat_trx_type_code = P_VAT_TRX_TYPE OR P_VAT_TRX_TYPE IS NULL)
AND JG.tax_rate_register_type_code = 'TAX'
AND JGR.source                   = 'AR'
/* UT CHANGE AND JG.extract_source_ledger       = 'AR'
AND JG.tax_invoice_date BETWEEN JGR.period_start_date AND JGR.period_end_date */
ORDER BY VAT_TRX_TYPE_CODE
	 ,PERIOD_YEAR DESC
	 ,PERIOD_NUM DESC
	 ,JG.tax_rate_code
	 ,JG.tax_invoice_date;


 -- Generic Cursor
CURSOR C_TRX_DTLS( p_vat_rep_config_id   IN NUMBER
                 , p_period              IN VARCHAR2 )
IS
SELECT JG.doc_seq_value                   SEQ_NUM
     , JG.tax_rate                        TAX_RATE
     , (NVL(JG.tax_amt,0)
            + NVL(JG.taxable_amt,0))       TRX_AMOUNT
     , (NVL(JG.tax_amt_funcl_curr,0)
       + NVL(JG.taxable_amt_funcl_curr,0)) FUNC_AMOUNT
     , NVL(JG.taxable_amt_funcl_curr,0)   TAXABLE_AMOUNT
     , NVL(JG.tax_amt_funcl_curr,0)       TAX_AMOUNT
     , JG.tax_invoice_date                TAX_DATE
     , JG.trx_date                        INVOICE_DATE
     , JG.accounting_date                 GL_DATE
     , DECODE(JG.trx_line_class
             ,'ADJUSTMENT',JG.applied_to_trx_number
             , JG.trx_number)             INVOICE_NUMBER
     , JG.billing_tp_name                 CUST_NAME
     , JG.billing_tp_tax_reg_num          TAX_REG_NUM
     , JG.trx_currency_code               CURR
     , JG.tax_rate_code                   TAX_CODE
     , JG.tax_rate_code_name              TAX_DESC
     , JG.tax_rate_vat_trx_type_desc      VAT_DESC
     , JG.tax_rate_vat_trx_type_code      VAT_TYPE
     , JGR.tax_calendar_period            PERIOD_NAME
     , JG.tax_rate_code_vat_trx_type_mng  VAT_CODE
     , JGR.tax_calendar_year              PERIOD_YEAR
     , JG.account_flexfield               GL_ACcOUNT
     , JG.trx_line_class                  CLASS_CODE
     , JG.trx_number                      RECEIPT_NUMBER
     , JG.ar_cash_receipt_reverse_date    REV_DATE
     , JG.ar_cash_receipt_reverse_status  STATUS
FROM    jg_zz_vat_trx_details    JG
       , jg_zz_vat_rep_status    JGR
WHERE JGR.vat_reporting_entity_id    = P_VAT_REP_ENTITY_ID
AND   JG.reporting_status_id         = JGR.reporting_status_id
AND   JGR.tax_calendar_period        = P_PERIOD
AND   JG.tax_rate_register_type_code = 'TAX'
AND   JGR.source                     = 'AR'
/* UT CHANGE AND   JG.extract_source_ledger       = 'AR'
AND   JG.tax_invoice_date BETWEEN JGR.period_start_date AND JGR.period_end_date */
;

CURSOR lcu_euar_data_count ( p_ex_vat_trx_type     IN VARCHAR2)
IS
SELECT  COUNT(1) C_NO_DATA_COUNT
FROM   jg_zz_vat_trx_gt
WHERE jg_info_v14 <> P_EX_VAT_TRX_TYPE
OR P_EX_VAT_TRX_TYPE IS NULL
;

CURSOR lcu_get_acc_method
IS
SELECT  1
FROM ar_system_parameters
WHERE accounting_method = 'CASH';

CURSOR get_entity_identifier(p_vat_rep_entity_id number)
IS
SELECT entity_identifier
FROM jg_zz_vat_rep_entities
WHERE vat_reporting_entity_id=p_vat_rep_entity_id;


l_tax_document_date   DATE;
l_reporting_mode      VARCHAR2(240);
l_func_curr_code      VARCHAR2(240);
l_taxpayer_id         VARCHAR2 (100);
l_period_year         NUMBER;
l_rep_legal_entity    VARCHAR2(240);
l_trx_num             VARCHAR2(240);
l_rep_legal_entity_id NUMBER;
l_period_start_date   DATE;
l_period_end_date     DATE;
l_rd                  NUMBER;
l_new_r_tax           NUMBER;
l_new_amount          NUMBER;
l_new_rev_tax         NUMBER;
l_new_rev_amount      NUMBER;
l_new_receipt         VARCHAR2(10);
l_new_reversal        VARCHAR2(10);
l_vat                 VARCHAR2(20);
l_dummy               VARCHAR2(1);
l_new_au              NUMBER;
l_new_aa              NUMBER;
l_new_application     VARCHAR2(10);
l_app_vat             NUMBER;
l_new_app_vat         NUMBER;
l_unapp_vat           NUMBER;
l_new_unapp_vat       NUMBER;
l_zero                NUMBER;
l_company_name         xle_registrations.registered_name%TYPE;
l_registration_number  xle_registrations.registration_number%TYPE;
l_country              hz_locations.country%TYPE;
l_address1             hz_locations.address1%TYPE;
l_address2             hz_locations.address2%TYPE;
l_address3             hz_locations.address3%TYPE;
l_address4             hz_locations.address4%TYPE;
l_city                 hz_locations.city%TYPE;
l_postal_code          hz_locations.postal_code%TYPE;
l_contact              hz_parties.party_name%TYPE;
l_phone_number         hz_contact_points.phone_number%TYPE;
 -- Added for Glob-006 ER
l_province             VARCHAR2(120);
l_comm_num             VARCHAR2(30);
l_vat_reg_num          VARCHAR2(50);
-- end here
l_entity_identifier    VARCHAR2(600);
l_tax_rate_code        VARCHAR2(30);
LOG_MESSAGE            VARCHAR2(240);
INVALID_ENTRY          EXCEPTION;
errbuf		       VARCHAR2(1000);
l_functcurr	       VARCHAR2(15);
l_coaid                NUMBER;
l_ledger_name          VARCHAR2(30);
INVALID_LEDGER	       EXCEPTION;
l_receipt_application  number;
v_count		NUMBER 		:=0;
v_prev_vat_code	VARCHAR2(240)	:='';
v_is_seq_updated VARCHAR2(1) := 'N';
v_enable_report_sequence_flag VARCHAR2(1) := 'N';
l_precision            NUMBER;

BEGIN
   if gv_debug then FND_FILE.PUT_LINE(FND_FILE.LOG,'funct_curr_legal'); end if;
   jg_zz_common_pkg.funct_curr_legal( x_func_curr_code     => l_func_curr_code
                                   , x_rep_entity_name    => l_rep_legal_entity
                                   , x_legal_entity_id    => l_rep_legal_entity_id
                                   , x_taxpayer_id        => l_taxpayer_id
                                   , pn_vat_rep_entity_id => p_vat_rep_entity_id
                                   , pv_period_name       => p_period
                                   , pn_period_year       => l_period_year
                                   );

   if gv_debug then FND_FILE.PUT_LINE(FND_FILE.LOG,'2'); end if;

   jg_zz_common_pkg.tax_registration(x_tax_registration    => l_trx_num
                                   , x_period_start_date  => l_period_start_date
                                   , x_period_end_date    => l_period_end_date
                                   , x_status             => l_reporting_mode
                                   , pn_vat_rep_entity_id => p_vat_rep_entity_id
                                   , pv_period_name       => p_period
                                   , pv_source            => 'AR'
                                   );
    l_reporting_mode := jg_zz_vat_rep_utility.get_period_status
                          (
                           pn_vat_reporting_entity_id  =>  p_vat_rep_entity_id,
                           pv_tax_calendar_period      =>  p_period,
                           pv_tax_calendar_year        =>  NULL,
                           pv_source                   =>  NULL,
                           pv_report_name              =>  P_CALLINGREPORT
                          );

   if gv_debug then FND_FILE.PUT_LINE(FND_FILE.LOG,'3'); end if;

  /* jg_zz_common_pkg.company_detail(l_company_name
                                  ,l_registration_number
                                  ,l_country
                                  ,l_address1
                                  ,l_address2
                                  ,l_address3
                                  ,l_address4
                                  ,l_city
                                  ,l_postal_code
                                  ,l_contact
                                  ,l_phone_number
                                  ,nvl(l_rep_legal_entity_id,p_legal_entity_id) -- for German On Account Report - l_rep_legal_entity_id is null, p_legal_entity_id is the direct parameter to the report.
                                   );
*/

   JG_ZZ_COMMON_PKG.company_detail(x_company_name     => l_company_name
                                    ,x_registration_number    =>l_registration_number
                                    ,x_country                => l_country
                                     ,x_address1               => l_address1
                                     ,x_address2               => l_address2
                                     ,x_address3               => l_address3
                                     ,x_address4               => l_address4
                                     ,x_city                   => l_city
                                     ,x_postal_code            => l_postal_code
                                     ,x_contact                => l_contact
                                     ,x_phone_number           => l_phone_number
                                     ,x_province               => l_province
                                     ,x_comm_number            => l_comm_num
                                     ,x_vat_reg_num            => l_vat_reg_num
                                     ,pn_legal_entity_id       => nvl(l_rep_legal_entity_id,p_legal_entity_id)
                                     ,p_vat_reporting_entity_id => p_vat_rep_entity_id);

	/* Get ENTITY_IDENTIFIER */

	OPEN get_entity_identifier(p_vat_rep_entity_id);
	FETCH get_entity_identifier INTO l_entity_identifier;
	CLOSE get_entity_identifier;

	/* Get Tax Rate Code.
	   The value for German On Account Reciept Report */

	OPEN get_tax_rate_code(p_tax_rate_id);
	FETCH get_tax_rate_code INTO l_tax_rate_code;
	CLOSE get_tax_rate_code;

  /* Get Currency Precision */

       BEGIN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Functional Currency Code :'||l_func_curr_code);

             SELECT  precision
               INTO  l_precision
             FROM    fnd_currencies
             WHERE   currency_code = l_func_curr_code;

            FND_FILE.PUT_LINE(FND_FILE.LOG,'Functional Currency Precision :'||l_precision);

        EXCEPTION
           WHEN OTHERS THEN
             FND_FILE.PUT_LINE(FND_FILE.LOG,'error in getting currency precision');
       END;



     if gv_debug then FND_FILE.PUT_LINE(FND_FILE.LOG,'INSERT INTO GLOBAL'); end if;
    InsertIntoGlobal(
		      p_jg_info_v20  => l_entity_identifier   -- entity_identifier
                     ,p_jg_info_v21  => l_func_curr_code      -- curr_code
                     ,p_jg_info_v22  => l_company_name        -- l_rep_legal_entity    -- entity_name
                     ,p_jg_info_v23  => l_registration_number    -- l_taxpayer_id         -- taxpayer_id
                     ,p_jg_info_v24  => l_company_name        -- company_name
                     ,p_jg_info_v25  => l_trx_num	      -- registration_number
                     ,p_jg_info_v26  => l_country             -- country
                     ,p_jg_info_v27  => l_address1            -- address1
                     ,p_jg_info_v28  => l_address2            -- address2
                     ,p_jg_info_v29  => l_address3            -- address3
                     ,p_jg_info_v30  => l_address4            -- address4
                     ,p_jg_info_v31  => l_city                -- city
                     ,p_jg_info_v32  => l_postal_code         -- postal_code
                     ,p_jg_info_v33  => l_contact             -- contact
                     ,p_jg_info_v34  => l_phone_number        -- phone_number
                     ,p_jg_info_v35  => l_reporting_mode      -- reporting mode
                     ,p_jg_info_v37  => l_trx_num             -- trx_num
                     ,p_jg_info_d4   => l_period_start_date   -- period_start_date
                     ,p_jg_info_d5   => l_period_end_date     -- period_end_date
                     ,p_jg_info_n26  => l_rep_legal_entity_id -- legalentity_id
                     ,p_jg_info_n27  => l_period_year         -- period_year
		     ,p_jg_info_v19  => l_registration_number -- company tax Payer Id
		     ,p_jg_info_v18  => l_tax_rate_code -- tax rate code
	             ,p_jg_info_n25  => l_precision           -- currency precision
		     ,p_jg_info_v36 => 'H'                    -- Header record indicator
                   );



if gv_debug then FND_FILE.PUT_LINE(FND_FILE.LOG,'5'); end if;

   IF P_CALLINGREPORT = 'JEDEDVOR' THEN

	/* validating the parameters */

	IF ( p_reporting_level = 'LE' AND  p_legal_entity_id IS NULL) THEN

		 fnd_message.set_name('JG', 'JG_ZZ_VAT_INVALID_ENTITY');
		 fnd_message.set_token('PARAMETER', 'Legal Entity');
		 fnd_message.set_token('LEVEL',p_reporting_level);
		 LOG_MESSAGE := fnd_message.get;

		 RAISE  INVALID_ENTRY;

        ELSIF ( p_reporting_level = 'LEDGER' AND  p_ledger_id IS NULL) THEN

		 fnd_message.set_name('JG', 'JG_ZZ_VAT_INVALID_ENTITY');
		 fnd_message.set_token('PARAMETER', 'Ledger');
		 fnd_message.set_token('LEVEL',p_reporting_level);
		 LOG_MESSAGE := fnd_message.get;

		 RAISE  INVALID_ENTRY;
       ELSIF ( p_reporting_level = 'BSV' AND  p_company IS NULL) THEN

		fnd_message.set_name('JG', 'JG_ZZ_VAT_INVALID_ENTITY');
		 fnd_message.set_token('PARAMETER', 'Balancing Segment');
		 fnd_message.set_token('LEVEL',p_reporting_level);
		 LOG_MESSAGE := fnd_message.get;

		 RAISE  INVALID_ENTRY;
       END IF;

       BEGIN
	 GL_INFO.gl_get_ledger_info(P_LEDGER_ID,l_coaid,l_ledger_name,l_functcurr,errbuf);

		 IF errbuf IS NOT NULL THEN
        		RAISE INVALID_LEDGER;
		 END IF;

	 EXCEPTION
          WHEN INVALID_LEDGER THEN
          fnd_file.put_line(fnd_file.log,errbuf);
	END;

      FOR r_ger_receipt IN lcu_ger_receipt ( p_vat_rep_entity_id,
					     p_period,
					     p_legal_entity_id,
					     p_ledger_id,
					     l_coaid,
					     p_company,
					     p_tax_rate_id,
					     p_reporting_level,
					     p_gl_period_start_date,
					     p_gl_period_end_date
					     )
      LOOP

         if gv_debug then FND_FILE.PUT_LINE(FND_FILE.LOG,'6'); end if;

         l_rd             := rdformula(r_ger_receipt.rev_date,p_gl_period_start_date,p_gl_period_end_date);

         l_new_r_tax      := new_r_taxformula(r_ger_receipt.r_date , r_ger_receipt.r_tax ,p_gl_period_start_date,p_gl_period_end_date);

         l_new_amount     := new_amountformula(r_ger_receipt.r_date , r_ger_receipt.amount,p_gl_period_start_date,p_gl_period_end_date);

         l_new_rev_tax    := new_rev_taxformula(l_rd , r_ger_receipt.rev_tax );

         l_new_rev_amount := new_rev_amountformula(l_rd, r_ger_receipt.rev_amount );

         l_new_receipt    := new_receiptformula(r_ger_receipt.r_date,p_gl_period_start_date,p_gl_period_end_date);

         l_new_reversal   := new_reversalformula(r_ger_receipt.rev_date,p_gl_period_start_date,p_gl_period_end_date);

         l_zero           := zeroformula;
         if gv_debug then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'7. CrId:'||r_ger_receipt.cash_receipt_id);
         end if;

	 l_receipt_application := 0;

         FOR r_ger_appl IN lcu_ger_appl (r_ger_receipt.cash_receipt_id)
         LOOP
             if gv_debug then FND_FILE.PUT_LINE(FND_FILE.LOG,'in 2nd loop'); end if;

            l_new_au          := new_auformula(r_ger_appl.a_date , r_ger_appl.applied , r_ger_appl.amount_applied,p_gl_period_start_date,p_gl_period_end_date );

            l_new_aa          := new_aaformula(r_ger_appl.a_date , r_ger_appl.applied , r_ger_appl.amount_applied,p_gl_period_start_date,p_gl_period_end_date);

            l_new_application := new_applicationformula(r_ger_appl.a_date,p_gl_period_start_date,p_gl_period_end_date);

            l_app_vat         := app_vatformula(r_ger_appl.applied , r_ger_appl.tax_rate_id , r_ger_appl.a_date , r_ger_appl.amount_applied , r_ger_receipt.amount);

            l_new_app_vat     := new_app_vatformula(r_ger_appl.a_date, l_app_vat,p_gl_period_start_date,p_gl_period_end_date);

            l_unapp_vat       := unapp_vatformula(r_ger_appl.applied , r_ger_appl.tax_rate_id , r_ger_appl.a_date , r_ger_appl.amount_applied , r_ger_receipt.amount);

            l_new_unapp_vat   := new_unapp_vatformula(r_ger_appl.a_date , l_unapp_vat,p_gl_period_start_date,p_gl_period_end_date );

            l_vat             := vatformula(r_ger_appl.applied, l_app_vat, l_unapp_vat);
            if gv_debug then FND_FILE.PUT_LINE(FND_FILE.LOG,'insert into global'); end if;
            InsertIntoGlobal(
                              p_jg_info_v1      => r_ger_receipt.receipt
                            , p_jg_info_v2      => r_ger_receipt.status
                            , p_jg_info_v3      => r_ger_receipt.tax_code
                            , p_jg_info_v4      => r_ger_receipt.currenct_code
                            , p_jg_info_v10     => r_ger_receipt.receipt_number
                            , p_jg_info_d1      => r_ger_receipt.rev_date
                            , p_jg_info_d2      => r_ger_receipt.r_date
                            , p_jg_info_n1      => r_ger_receipt.amount
                            , p_jg_info_n2      => l_zero
                            , p_jg_info_n3      => r_ger_receipt.rev_amount
                            , p_jg_info_n4      => r_ger_receipt.r_tax
                            , p_jg_info_n5      => r_ger_receipt.rev_tax
                            , p_jg_info_n6      => r_ger_receipt.cash_receipt_id
                            , p_jg_info_n11     => l_rd
                            , p_jg_info_n14     => l_new_r_tax
                            , p_jg_info_n15     => l_new_amount
                            , p_jg_info_n16     => l_new_rev_tax
                            , p_jg_info_n17     => l_new_rev_amount
                           -- , p_jg_info_n18     => l_new_receipt
                           -- , p_jg_info_n19     => l_new_reversal
                            , p_jg_info_v15     => l_new_receipt   /* modified during UT TEST */
                            , p_jg_info_v16     => l_new_reversal  /* modified during UT TEST */
                            , p_jg_info_v5      => r_ger_appl.applied
                            , p_jg_info_v6      => r_ger_appl.invoice_currency_code
                            , p_jg_info_v7      => r_ger_appl.tax_code
                            , p_jg_info_v8      => r_ger_appl.customer_name
                            , p_jg_info_v9      => r_ger_appl.location
                            , p_jg_info_v13     => l_vat
                            , p_jg_info_v14     => l_new_application
                            , p_jg_info_n7      => r_ger_appl.receivable_application_id
                            , p_jg_info_n8      => r_ger_appl.applied_customer_trx_id
                            , p_jg_info_n9      => r_ger_appl.amount_applied
                            , p_jg_info_n20     => l_new_au
                            , p_jg_info_n21     => l_new_aa
                            , p_jg_info_n22     => l_app_vat
                            , p_jg_info_n23     => l_new_app_vat
                            , p_jg_info_n24     => l_unapp_vat
                            , p_jg_info_n25     => l_new_unapp_vat
                            , p_jg_info_d3      => r_ger_appl.a_date
			    , p_jg_info_v30     => 'JEDEDVOR'
                              );
		l_receipt_application := 1;
         END LOOP;

		/* Will insert the Onc-Account receipt details,which is not applied */

		IF l_receipt_application = 0 THEN

			InsertIntoGlobal(
                              p_jg_info_v1      => r_ger_receipt.receipt
                            , p_jg_info_v2      => r_ger_receipt.status
                            , p_jg_info_v3      => r_ger_receipt.tax_code
                            , p_jg_info_v4      => r_ger_receipt.currenct_code
                            , p_jg_info_v10     => r_ger_receipt.receipt_number
                            , p_jg_info_d1      => r_ger_receipt.rev_date
                            , p_jg_info_d2      => r_ger_receipt.r_date
                            , p_jg_info_n1      => r_ger_receipt.amount
                            , p_jg_info_n2      => l_zero
                            , p_jg_info_n3      => r_ger_receipt.rev_amount
                            , p_jg_info_n4      => r_ger_receipt.r_tax
                            , p_jg_info_n5      => r_ger_receipt.rev_tax
                            , p_jg_info_n6      => r_ger_receipt.cash_receipt_id
                            , p_jg_info_n11     => l_rd
                            , p_jg_info_n14     => l_new_r_tax
                            , p_jg_info_n15     => l_new_amount
                            , p_jg_info_n16     => l_new_rev_tax
                            , p_jg_info_n17     => l_new_rev_amount
                           -- , p_jg_info_n18     => l_new_receipt
                           -- , p_jg_info_n19     => l_new_reversal
                            , p_jg_info_v15     => l_new_receipt   /* modified during UT TEST */
                            , p_jg_info_v16     => l_new_reversal  /* modified during UT TEST */
                            , p_jg_info_v5      => NULL
                            , p_jg_info_v6      => NULL
                            , p_jg_info_v7      => NULL
                            , p_jg_info_v8      => NULL
                            , p_jg_info_v9      => NULL
                            , p_jg_info_v13     => NULL
                            , p_jg_info_v14     => NULL
                            , p_jg_info_n7      => NULL
                            , p_jg_info_n8      => NULL
                            , p_jg_info_n9      => NULL
                            , p_jg_info_n20     => NULL
                            , p_jg_info_n21     => NULL
                            , p_jg_info_n22     => NULL
                            , p_jg_info_n23     => NULL
                            , p_jg_info_n24     => NULL
                            , p_jg_info_n25     => NULL
                            , p_jg_info_d3      => NULL
			    , p_jg_info_v30     => 'JEDEDVOR'
                              );
		END IF;
      END LOOP;
   ELSIF P_CALLINGREPORT = 'JGZZARVR' THEN

   BEGIN

      if gv_debug then FND_FILE.PUT_LINE(FND_FILE.LOG,'JGZZARVR - 1'); end if;
      FOR r_euar IN lcu_euar_vatreg (p_vat_rep_entity_id,p_period,p_vat_trx_type, p_ex_vat_trx_type)
      LOOP

	if gv_debug then FND_FILE.PUT_LINE(FND_FILE.LOG,'JGZZARVR - 2'); end if;

	FND_FILE.PUT_LINE(FND_FILE.LOG,'v_count - '||v_count);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'r_euar.vat_code - '||r_euar.vat_code);
         FND_FILE.PUT_LINE(FND_FILE.LOG,'v_prev_vat_code - '||v_prev_vat_code);


         InsertIntoGlobal(
                           p_jg_info_n1      => r_euar.seq_num
                         , p_jg_info_n2      => r_euar.tax_rate
                         , p_jg_info_n3      => r_euar.trx_amount
                         , p_jg_info_n4      => r_euar.func_amount
                         , p_jg_info_n5      => r_euar.taxable_amount
                         , p_jg_info_n6      => r_euar.tax_amount
                         , p_jg_info_n7      => r_euar.period_year
                         , p_jg_info_n8      => r_euar.ledger_id
			 , p_jg_info_n9	     => r_euar.period_num
                         , p_jg_info_d1      => r_euar.tax_date
                         , p_jg_info_d2      => r_euar.invoice_date
                         , p_jg_info_d3      => r_euar.gl_date
                         , p_jg_info_v1      => r_euar.invoice_number
			 , p_jg_info_n25     => r_euar.trx_id
                         , p_jg_info_v2      => r_euar.cust_name
                         , p_jg_info_v3      => r_euar.tax_reg_num
                         , p_jg_info_v4      => r_euar.curr
                         , p_jg_info_v5      => r_euar.tax_code
                         , p_jg_info_v6      => r_euar.vat_code
                         , p_jg_info_v7      => r_euar.tax_desc
                         , p_jg_info_v8      => r_euar.vat_desc
                         , p_jg_info_v9      => r_euar.period_name
                         , p_jg_info_v10     => r_euar.gl_account
                         , p_jg_info_v14     => r_euar.vat_type
                         , p_jg_info_v15     => r_euar.enable_report_sequence_flag
                         , p_jg_info_v17     => r_euar.tax_rate_code
                         , p_jg_info_v18     => r_euar.class_code
                         );
	v_enable_report_sequence_flag := r_euar.enable_report_sequence_flag;
      END LOOP;

      if gv_debug then FND_FILE.PUT_LINE(FND_FILE.LOG,'JGZZARVR - 3'); end if;
      FOR r_euar_data_count IN lcu_euar_data_count ( p_ex_vat_trx_type)
      LOOP
          UPDATE jg_zz_vat_trx_gt
          SET jg_info_n20 = r_euar_data_count.c_no_data_count;
      END LOOP;
      if gv_debug then FND_FILE.PUT_LINE(FND_FILE.LOG,'JGZZARVR - 4'); end if;

-- Implement the report level seq number --

   IF  v_enable_report_sequence_flag = 'Y' THEN

   	FOR r_seq_impl IN temp_cur(p_vat_rep_entity_id,p_period,p_vat_trx_type, p_ex_vat_trx_type)
	LOOP

	      IF r_seq_impl.VAT_TRX_TYPE_CODE <> v_prev_vat_code  or r_seq_impl.VAT_TRX_TYPE_CODE IS NULL THEN
			v_count	:= 0;
              END IF;

		SELECT  distinct JG_INFO_V40 INTO v_is_seq_updated FROM JG_ZZ_VAT_TRX_GT T1
		WHERE   T1.jg_info_n25 = r_seq_impl.trx_id
		AND T1.jg_info_v6 = r_seq_impl.VAT_TRX_TYPE_CODE;


	       IF nvl(v_is_seq_updated,'N') <> 'Y' THEN

		      v_count := v_count+1;

			      UPDATE JG_ZZ_VAT_TRX_GT SET jg_info_n1 = v_count ,
					          jg_info_v40 = 'Y'
			      WHERE jg_info_n25 = r_seq_impl.trx_id
			      AND  jg_info_v6 = r_seq_impl.VAT_TRX_TYPE_CODE;

	        END IF;

	      v_prev_vat_code := r_seq_impl.VAT_TRX_TYPE_CODE;

	   END LOOP;

    END IF;

-- End of Implement the report level seq number --

    END;

    ELSIF P_CALLINGREPORT = 'JEILARDR' THEN
      /*
      || Israeli VAT AR Detailed Report
      || ELSIF added by Ramananda
      || Logic for this report is handled in the DataTemplate.
      */
       --IL VAT 2010 ER Start
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Report name :'||'JEILARDR');
      BEGIN
		SELECT jivl.vat_aggregate_limit_amt
		INTO g_vat_agg_limit
		FROM je_il_vat_limits jivl,
		  jg_zz_vat_rep_status jzvrs
		WHERE jzvrs.vat_reporting_entity_id = p_vat_rep_entity_id
		 AND jzvrs.tax_calendar_period = p_period
		 AND jzvrs.tax_calendar_name = jivl.period_set_name
		 AND jivl.period_name = p_period
		 AND rownum = 1;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                fnd_file.put_line(fnd_file.log,'Please declare the VAT Aggregation Limit Amount for the tax period:'||p_period ||' for Calendar in the Israel VAT Limits Setup form.');
                raise_application_error(-20010,'Please declare the VAT Aggregation Limit Amount for the tax period:'||p_period ||' in the Israel VAT Limits Setup form.');
                RETURN (FALSE);
        END;

      g_precision := l_precision;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'VAT Aggregation Limit :'||g_vat_agg_limit);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'G_PRECISION :'||g_precision);
      --IL VAT 2010 ER  End
    ELSIF P_CALLINGREPORT = 'JEHRCITR' THEN
      /*
      || Customer Invoice Tax Report, Croatia
      || ELSIF added by Ramananda
      || Logic for this report is handled in the DataTemplate.
      */
      NULL;

   ELSIF P_CALLINGREPORT = 'SUMMARY-AR' OR P_CALLINGREPORT IS NULL THEN
             -- Call Generic Cursor C_TRX_DTLS
      NULL;
   END IF;

   IF l_reporting_mode = 'PRELIMINARY' OR l_reporting_mode = 'FINAL' THEN

      -- Get accounting method --
      OPEN lcu_get_acc_method;
      FETCH lcu_get_acc_method
      INTO l_dummy;
      IF lcu_get_acc_method%FOUND THEN
         CLOSE lcu_get_acc_method;

	 /* The tax_date_maintenance_program procedure not suppose to call here.
            We should call this procedure before selection process ran i.e. Before the TRL call (as in 11i)
	    Hence commenting the call to procedure.
	 */
        -- tax_date_maintenance_program(l_period_end_date);
      ELSE
         CLOSE lcu_get_acc_method;
      END IF;
   END IF;

   RETURN (TRUE);
EXCEPTION
WHEN INVALID_ENTRY THEN
      fnd_file.put_line(fnd_file.log,LOG_MESSAGE);
      raise;
      RETURN (FALSE);
WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error in JG_ZZ_SUMMARY_AR_PKG.beforeReport. Error-' ||SUBSTR(SQLERRM,1,200));
   raise;
   RETURN (FALSE);
END beforeReport;

END JG_ZZ_SUMMARY_AR_PKG;

/
