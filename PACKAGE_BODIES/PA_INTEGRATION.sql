--------------------------------------------------------
--  DDL for Package Body PA_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_INTEGRATION" AS
--$Header: PAXPINTB.pls 120.6 2006/08/22 23:36:56 skannoji noship $

l_invoice_id    NUMBER;
l_invoice_status Varchar2(30);
l_status_type    Varchar2(30);

G_PrevPeriodName pa_cost_distribution_lines_all.gl_period_name%TYPE;
G_PrevPdStDate   DATE;
G_PrevPdEdDate   DATE;
G_PrevSOBId      NUMBER;

-- FUNCTION get_period_name /*2835063*/
    FUNCTION get_period_name RETURN  pa_cost_distribution_lines_all.pa_period_name%TYPE is
    BEGIN
         /* Please note that this function should be used only after ensuring that
	    get_raw_cdl_pa_date() is called, so that the returned variable's value has a
	    non-NULL value */
      return  g_prvdr_pa_period_name;
    end get_period_name;

FUNCTION pending_vi_adjustments_exists( P_invoice_id IN NUMBER )
                                        RETURN varchar2 IS
--
-- CDL's that are not yet transfered to AP
--
CURSOR pending_transfer IS
SELECT 'AP_PROJ_TASK_EXIST_PA'
FROM
    PA_COST_DISTRIBUTION_LINES  CDL,
    PA_EXPENDITURE_ITEMS   EI
  WHERE
   EI.EXPENDITURE_ITEM_ID = CDL.EXPENDITURE_ITEM_ID
  AND CDL.TRANSFER_STATUS_CODE IN ('P','R','X')
  AND EI.SYSTEM_LINKAGE_FUNCTION in ( 'VI','ER')
  AND CDL.LINE_TYPE  = 'R'
  AND CDL.system_reference2 = to_char(P_invoice_id);
--
-- Expenditure items that are
-- split/transfered but not cost distributed.
--
CURSOR pending_ei IS
SELECT 'AP_SPLIT_EXIST_PA'
FROM
    PA_COST_DISTRIBUTION_LINES  CDL
  WHERE
      CDL.system_reference2 = to_char(P_invoice_id)
  AND CDL.transfer_status_code||'' IN ('V','A')
  AND CDL.line_type = 'R'
  AND EXISTS
    ( SELECT ' There are Splits/Transfers on EI'
        FROM PA_EXPENDITURE_ITEMS   EI
       WHERE EI.SYSTEM_LINKAGE_FUNCTION in ( 'VI', 'ER' )
         AND EI.TRANSFERRED_FROM_EXP_ITEM_ID = CDL.EXPENDITURE_ITEM_ID
         AND EI.ADJUSTED_EXPENDITURE_ITEM_ID IS NULL
         AND EI.COST_DISTRIBUTED_FLAG||'' = 'N'
     );
--
-- Expenditure items that are marked for recalc
--

CURSOR pending_recalc IS
SELECT 'AP_RECALC_COST_PA'
FROM
    PA_COST_DISTRIBUTION_LINES CDL
WHERE
    CDL.system_reference2 = to_char(P_invoice_id)
  AND CDL.transfer_status_code||'' IN ( 'V', 'A' )
  AND CDL.line_type = 'R'
  AND EXISTS
    ( SELECT 'Marked for recalc'
        FROM PA_EXPENDITURE_ITEMS EI
       WHERE EI.SYSTEM_LINKAGE_FUNCTION in ( 'VI','ER')
         AND EI.EXPENDITURE_ITEM_ID = CDL.EXPENDITURE_ITEM_ID
         AND EI.COST_DISTRIBUTED_FLAG = 'N'
     );
--
-- Checking for reversals
--

CURSOR pending_reversed IS
SELECT 'AP_ADJ_EXIST_PA'
FROM
    PA_COST_DISTRIBUTION_LINES  CDL
  WHERE
      CDL.system_reference2 = to_char(P_invoice_id)
  AND CDL.transfer_status_code ||'' IN ('V','A')
  AND CDL.line_type = 'R'
  AND EXISTS
    ( SELECT ' Reversed EI '
        FROM PA_EXPENDITURE_ITEMS   EI
       WHERE EI.SYSTEM_LINKAGE_FUNCTION in ( 'VI','ER')
         AND EI.ADJUSTED_EXPENDITURE_ITEM_ID = CDL.EXPENDITURE_ITEM_ID
         AND EI.COST_DISTRIBUTED_FLAG||'' = 'N'
     );

v_error_code  varchar2(30) := 'Y';

BEGIN
  OPEN pending_transfer;
  FETCH pending_transfer INTO v_error_code;
  IF ( v_error_code <> 'Y' ) THEN
    CLOSE pending_transfer;
    RETURN v_error_code;
  END IF;
  CLOSE pending_transfer;                        -- Added for Bug#5381711

  OPEN pending_ei;
  FETCH pending_ei INTO v_error_code;
  IF ( v_error_code <> 'Y' ) THEN
    CLOSE pending_ei;
    RETURN v_error_code;
  END IF;
  CLOSE pending_ei;                              -- Added for Bug#5381711

  OPEN pending_recalc;
  FETCH pending_recalc INTO v_error_code;
  IF ( v_error_code <> 'Y' ) THEN
    CLOSE pending_recalc;
    RETURN v_error_code;
  END IF;
  CLOSE pending_recalc;                          -- Added for Bug#5381711

  OPEN pending_reversed;
  FETCH pending_reversed INTO v_error_code;
  IF ( v_error_code <> 'Y' ) THEN
    CLOSE pending_reversed;                      -- Modified for Bug#5381711
    RETURN v_error_code;
  END IF;
  CLOSE pending_reversed;                        -- Added for Bug#5381711

-- If you can get here, then there are no pending adjustments in PA
--
  v_error_code := 'N';
  RETURN v_error_code;

EXCEPTION WHEN others THEN
  RAISE;
END pending_vi_adjustments_exists;

FUNCTION check_ap_invoices(p_invoice_id IN NUMBER,
                           p_status_type IN VARCHAR2) RETURN VARCHAR2 IS
v_error_code      VARCHAR2(30) :='';
v_cancelled_date  DATE;
v_cancelled_by    NUMBER;
BEGIN
   -- v_error_code := AP_PA_API_PKG.get_invoice_status(p_invoice_id,p_status_type); /* bug#5010877 */

   -- Added this section to replace the above function call.
    IF p_status_type = 'ADJUSTMENTS' THEN

	SELECT CANCELLED_DATE,
	       CANCELLED_BY
	INTO   v_cancelled_date,
	       v_cancelled_by
	FROM   ap_invoices_all
	WHERE  invoice_id = p_invoice_id;

      	If    (v_cancelled_date IS NOT NULL AND v_cancelled_by IS NOT NULL) THEN
              v_error_code := 'PA_INV_CANCELLED';
        else
              v_error_code := 'N';
        End if;

    END IF;

   RETURN(v_error_code);

EXCEPTION WHEN OTHERS THEN
  RAISE;
END check_ap_invoices;

PROCEDURE init_ap_invoices IS
BEGIN
   l_invoice_id := -1;
   l_invoice_status := '';
   l_status_type :='';
END init_ap_invoices;

FUNCTION ap_invoice_status( p_invoice_id IN NUMBER,
                            p_status_type In VARCHAR2) RETURN VARCHAR2 IS
pa_check_status VARCHAR2(30);  /* For Bug 1969501 */
BEGIN
   IF (( l_invoice_id = p_invoice_id ) and (l_status_type = p_status_type)) THEN
      RETURN l_invoice_status;
   ELSE
      l_invoice_id := p_invoice_id;
      l_status_type := p_status_type;

      pa_check_status := pa_integration.check_ap_invoices(p_invoice_id,p_status_type);

      IF pa_check_status = 'N' THEN
         l_invoice_status := 'N';
      ELSIF pa_check_status = 'PA_INV_CANCELLED' THEN
         l_invoice_status := 'C';
      ELSE
         l_invoice_status := 'Y';
      END IF;
      RETURN l_invoice_status;
   END IF;
END ap_invoice_status;

---------------------------------------------------------------------------
--This Procedure refresh_pa_cache() is used by get_raw_cdl_date and get_raw_cdl_recvr_pa_date
--for caching purposes. Global variables defined in PAXPINTS.pls are used for caching.
---------------------------------------------------------------------------
PROCEDURE refresh_pa_cache ( p_org_id   IN NUMBER ,
                             p_expenditure_item_date  IN DATE ,
                             p_accounting_date IN DATE,
                             p_caller_flag     IN VARCHAR2
                           )
IS
-- local variables
  l_earliest_start_date  DATE ;
  l_earliest_end_date  DATE ;
  l_earliest_period_name pa_cost_distribution_lines_all.pa_period_name%TYPE;
  l_pa_date           DATE ;
  l_start_date        DATE ;               -- start date for the l_pa_date.
  l_end_date          DATE ;               -- end date for the l_pa_date ( equals l_pa_date ).
  l_period_name pa_cost_distribution_lines_all.pa_period_name%TYPE;

  l_prof_new_gldate_derivation VARCHAR2(1) := 'N' ;

BEGIN
  /* Changed from value_specific to value for bug 5472333 */
  l_prof_new_gldate_derivation := NVL(fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION'), 'N') ;

  IF( l_prof_new_gldate_derivation = 'Y' )
  THEN
/*
 *SQL to select the earliest open PA_DATE.
 *Select the earliest open date ONLY if the global earliest date is NOT yet populated.
 *Because , earliest pa_date will remain the same for a run.
 */

 IF ( p_caller_flag = 'R' AND g_r_earliest_pa_start_date IS NULL ) OR
    ( p_caller_flag = 'P' AND g_p_earliest_pa_start_date IS NULL ) THEN

-- Note : This SQL uses the p_accounting_date filter criteria.

      SELECT pap1.start_date
            ,pap1.end_date
            ,pap1.period_name
        INTO l_earliest_start_date
            ,l_earliest_end_date
            ,l_earliest_period_name
        FROM pa_periods_all pap1
       WHERE pap1.status IN ('O','F')
         AND NVL(pap1.org_id, -99) = NVL(p_org_id, -99)
         AND pap1.start_date = ( SELECT MIN(pap.start_date)
                                   FROM pa_periods_all pap
                                  WHERE status IN ('O','F')
                                    AND NVL( org_id, -99 ) = NVL( p_org_id, -99 )
                               );
 END IF ;

-- SQL to select the PA_DATE for the current EI.
/* Code fix for Bug 1657231...
   Added Begin... Exception...END to Handle No_Data_Found Exception */

/*
 * EPP.
 * Modified the following sql to get p_accounting_date as l_pa_date
 * rather then end_date.
 */
BEGIN  /* Added for Bug 1657231 */
      SELECT pap.start_date
            ,pap.end_date
            ,p_accounting_date
            ,pap.period_name
        INTO l_start_date
            ,l_end_date
            ,l_pa_date
            ,l_period_name
        FROM pa_periods_all pap
       WHERE pap.status in ('O','F')
         AND pap.end_date >= TRUNC(p_expenditure_item_date)
         AND p_accounting_date BETWEEN pap.start_date and pap.end_date
         AND NVL(org_id, -99) = NVL(p_org_id, -99) ;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
   l_pa_date := NULL;
   l_period_name := NULL;
END; /* Added for Bug 1657231 */

/*If the l_pa_date obtained is NULL, try to find a pa_date without the accounting-date
 *check. This approach was used even previously.
 *This SQL will FAIL - if there are more than one row in pa_periods_all - with the same end_date.
 */

      IF ( l_pa_date IS NULL )
      THEN
        SELECT pap1.start_date
              ,pap1.end_date
              ,pap1.start_date
              ,pap1.period_name
          INTO l_start_date
              ,l_end_date
              ,l_pa_date
              ,l_period_name
          FROM pa_periods_all pap1
         WHERE NVL(pap1.org_id, -99) = NVL(p_org_id, -99) /*Added While  fixing bug 1657231*/
           AND pap1.start_date = ( SELECT MIN(pap.start_date)
                                     FROM pa_periods_all pap
                                    WHERE status IN ('O','F')
                                      AND pap.start_date >= TRUNC(p_expenditure_item_date)
                                      AND NVL(org_id, -99) = NVL(p_org_id, -99)
                                 );
      END IF; -- l_pa_date IS NULL

  ELSE -- profile option is not set.
    /*
     *SQL to select the earliest open PA_DATE.
     *Select the earliest open date ONLY if the global earliest date is NOT yet populated.
     *Because , earliest pa_date will remain the same for a run.
     */

     IF ( p_caller_flag = 'R' AND g_r_earliest_pa_start_date IS NULL ) OR
        ( p_caller_flag = 'P' AND g_p_earliest_pa_start_date IS NULL ) THEN

    -- Note : This SQL uses the p_accounting_date filter criteria.

          SELECT pap1.start_date
                ,pap1.end_date
                ,pap1.period_name
            INTO l_earliest_start_date
                ,l_earliest_end_date
                ,l_earliest_period_name
            FROM pa_periods_all pap1
           WHERE pap1.status IN ('O', 'F')
             AND NVL( pap1.org_id, -99 ) = NVL( p_org_id, -99 )
             AND pap1.end_date = ( SELECT MIN(pap.end_date)
                                     FROM pa_periods_all pap
                                    WHERE pap.status IN ('O','F')
     --                               AND p_accounting_date BETWEEN pap.start_date AND pap.end_date /* commented for bug 1982225 */
                                      AND NVL( pap.org_id, -99 ) = NVL( p_org_id, -99 )
                                 );
     END IF ;

    -- SQL to select the PA_DATE for the current EI.
    /* Code fix for Bug 1657231...
       Added Begin... Exception...END to Handle No_Data_Found Exception */

    BEGIN  /* Added for Bug 1657231 */
          SELECT pap.start_date
                ,pap.end_date
                ,pap.end_date
                ,pap.period_name
            INTO l_start_date
                ,l_end_date
                ,l_pa_date
                ,l_period_name
            FROM pa_periods_all pap
           WHERE status in ('O','F')
             AND pap.end_date >= TRUNC(p_expenditure_item_date)
             AND p_accounting_date BETWEEN pap.start_date and pap.end_date
             AND NVL(org_id, -99) = NVL(p_org_id, -99) ;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
       l_pa_date := NULL;
       l_period_name := NULL;
    END; /* Added for Bug 1657231 */

    /*If the l_pa_date obtained is NULL, try to find a pa_date without the accounting-date
     *check. This approach was used even previously.
     *This SQL will FAIL - if there are more than one row in pa_periods_all - with the same end_date.
     */

          IF ( l_pa_date IS NULL )
          THEN
            SELECT pap1.start_date
                  ,pap1.end_date
                  ,pap1.end_date
                  ,pap1.period_name
              INTO l_start_date
                  ,l_end_date
                  ,l_pa_date
                  ,l_period_name
              FROM pa_periods_all pap1
             WHERE pap1.end_date = ( SELECT MIN(pap.end_date)
                                      FROM pa_periods_all pap
                                     WHERE pap.status IN ('O','F')
                                       AND pap.end_date >= TRUNC(p_expenditure_item_date)
                                       AND NVL(pap.org_id, -99) = NVL(p_org_id, -99)
                                   )
               AND NVL(pap1.org_id, -99) = NVL(p_org_id, -99); /* Added While  fixing bug 1657231
                                                             Although not related to the bug */
          END IF;
  END IF; -- profile check

      /*
       * Populate global variables.
       */
      IF ( p_caller_flag = 'R' ) THEN
        -- Populate receiver cache.
        g_r_earliest_pa_start_date   := l_earliest_start_date ;
        g_r_earliest_pa_end_date     := l_earliest_end_date ;
        g_r_earliest_pa_period_name  := l_earliest_period_name ;
        g_recvr_org_id            := p_org_id ;
        g_recvr_pa_start_date     := l_start_date ;
        g_recvr_pa_end_date       := l_end_date ;
        g_recvr_pa_date           := l_pa_date ;
        g_recvr_pa_period_name     := l_period_name ;
      ELSIF ( p_caller_flag = 'P' ) THEN
        -- Populate provider cache
        g_p_earliest_pa_start_date  := l_earliest_start_date ;
        g_p_earliest_pa_end_date    := l_earliest_end_date ;
        g_p_earliest_pa_period_name := l_earliest_period_name ;
        g_prvdr_org_id           := p_org_id ;
        g_prvdr_pa_start_date    := l_start_date ;
        g_prvdr_pa_end_date      := l_end_date ;
        g_prvdr_pa_date          := l_pa_date ;
        g_prvdr_pa_period_name    := l_period_name ;
      END IF; -- caller flag

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*
     * Earliest dates are NULLed to ensure that the cache gets
     * refreshed the next time.
     */
      IF ( p_caller_flag = 'R' ) THEN
        -- Populate receiver cache.
        g_r_earliest_pa_start_date   := NULL ;
        g_r_earliest_pa_end_date     := NULL ;
        g_r_earliest_pa_period_name  := NULL ;
        g_recvr_pa_start_date     := NULL ;
        g_recvr_pa_end_date       := NULL ;
        g_recvr_pa_date           := NULL ;
        g_recvr_pa_period_name     := NULL ;
      ELSIF ( p_caller_flag = 'P' ) THEN
        -- Populate provider cache
        g_p_earliest_pa_start_date  := NULL ;
        g_p_earliest_pa_end_date    := NULL ;
        g_p_earliest_pa_period_name := NULL ;
        g_prvdr_pa_start_date    := NULL ;
        g_prvdr_pa_end_date      := NULL ;
        g_prvdr_pa_date          := NULL ;
        g_recvr_pa_period_name    := NULL ;
      END IF; -- caller flag
  WHEN OTHERS THEN
     RAISE ;

END refresh_pa_cache ;
-------------------------------------------------------------------------------
-- Function - get_raw_cdl_pa_date
-- Comments are at Package specification level.
-- This function is created for Bug No : 1103257. Function will be called from
-- PAVVIT process ( Suppllier invoice interface from payables module ). This
-- function will ensure that PA_DATE populated for Raw CDLs will be always
-- Greater than Payables Accounting date for Raw CDLs.
--------------------------------------------------------------------------
--This function was modified to use caching. The actual DB access happens in
-- pa_integration.refresh_pa_cache().
--This is to get the pa_date for the provider part. The receiver part is done
-- by get_raw_cdl_recvr_pa_date().
--------------------------------------------------------------------------
FUNCTION get_raw_cdl_pa_date ( p_expenditure_item_date  IN DATE,
                               p_accounting_date        IN DATE,
                               p_org_id                 IN NUMBER
                             )
RETURN DATE
IS
  l_prof_new_gldate_derivation VARCHAR2(1);
BEGIN
  /* Changed from value_specific to value for bug 5472333 */
  l_prof_new_gldate_derivation := NVL(fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION'), 'N') ;


  IF ( g_p_earliest_pa_start_date IS NOT NULL
       and nvl(p_org_id,-99) = nvl(g_prvdr_org_id,-99) ) /* 1982225. cache should be referred only if orgs are same */

  THEN
    -- values are already available in the provider_cache.
    -- so, check the provider_cache and return pa_date accordingly.

    IF ( l_prof_new_gldate_derivation = 'Y')
    THEN
        IF ( p_accounting_date BETWEEN g_prvdr_pa_start_date AND g_prvdr_pa_end_date AND
             p_expenditure_item_date  <= g_prvdr_pa_start_date )
        THEN
          return ( p_accounting_date ) ;
        ELSIF ( p_accounting_date <= g_p_earliest_pa_start_date AND
                p_expenditure_item_date  <= g_p_earliest_pa_start_date )
        THEN
          g_prvdr_pa_start_date  := g_p_earliest_pa_start_date;
          g_prvdr_pa_end_date    := g_p_earliest_pa_end_date;
          g_prvdr_pa_period_name := g_p_earliest_pa_period_name;
          return ( g_prvdr_pa_start_date ) ;
        END IF ; -- p_accounting_date
    ELSE
      IF ( p_accounting_date BETWEEN g_prvdr_pa_start_date AND g_prvdr_pa_end_date AND
            p_expenditure_item_date <= g_prvdr_pa_end_date )
      THEN
        return ( g_prvdr_pa_end_date );
      ELSIF ( p_accounting_date <= g_p_earliest_pa_end_date AND
              p_expenditure_item_date  <= g_p_earliest_pa_end_date )
      THEN
        g_prvdr_pa_start_date  := g_p_earliest_pa_start_date;
        g_prvdr_pa_end_date    := g_p_earliest_pa_end_date;
        g_prvdr_pa_period_name := g_p_earliest_pa_period_name;
        return ( g_prvdr_pa_end_date ) ;
      END IF; -- p_accounting_date
    END IF ; -- profile
  END IF ; -- g_p_earliest_pa_start_date

  /* If control comes here, it means that EITHER the cache is empty OR
   * the provider Cache is NOT reusable.
   * Access the DB and refresh cache and return pa_date.
   */

    pa_integration.refresh_pa_cache( p_org_id , p_expenditure_item_date, p_accounting_date, 'P' );
    RETURN ( g_prvdr_pa_date ) ;
EXCEPTION
  WHEN OTHERS THEN
    RAISE ;

END get_raw_cdl_pa_date;
-------------------------------------------------------------------------------------------------------
--This is to get the pa_date for the receiver part. The provider part is done
-- by get_raw_cdl_pa_date().
--------------------------------------------------------------------------

/**This is to get the pa_date for the receiver part **/
FUNCTION get_raw_cdl_recvr_pa_date ( p_expenditure_item_date  IN DATE,
                                     p_accounting_date        IN DATE ,
                                     p_org_id                 IN NUMBER
                                   )
RETURN DATE
IS
  l_prof_new_gldate_derivation VARCHAR2(1);
BEGIN
  /* Changed from value_specific to value for bug 5472333 */
  l_prof_new_gldate_derivation := NVL(fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION'), 'N') ;

  IF ( g_r_earliest_pa_start_date IS NOT NULL
       and nvl(p_org_id,-99) = nvl(g_recvr_org_id,-99) )  /* 1982225. cache should be referred only if orgs are same */
  THEN
     -- receiver cache IS available.
     -- Hence, try to re-use the receiver cache.

    IF ( l_prof_new_gldate_derivation = 'Y' )
    THEN
      IF ( p_accounting_date BETWEEN g_recvr_pa_start_date AND g_recvr_pa_end_date AND
           p_expenditure_item_date <= g_recvr_pa_start_date )
      THEN
        return ( p_accounting_date ) ;
      ELSIF ( p_accounting_date <= g_r_earliest_pa_start_date AND
              p_expenditure_item_date <= g_r_earliest_pa_start_date )
      THEN
        g_recvr_pa_start_date  := g_p_earliest_pa_start_date;
        g_recvr_pa_end_date    := g_p_earliest_pa_end_date;
        g_recvr_pa_period_name := g_p_earliest_pa_period_name;
        return ( g_recvr_pa_start_date ) ;
      END IF ;
    ELSE
      IF ( p_accounting_date BETWEEN g_recvr_pa_start_date AND g_recvr_pa_end_date AND
           p_expenditure_item_date <= g_recvr_pa_end_date )
      THEN
        return ( p_accounting_date ) ;
      ELSIF ( p_accounting_date <= g_r_earliest_pa_end_date AND
              p_expenditure_item_date <= g_r_earliest_pa_end_date )
      THEN
        g_recvr_pa_start_date  := g_p_earliest_pa_start_date;
        g_recvr_pa_end_date    := g_p_earliest_pa_end_date;
        g_recvr_pa_period_name := g_p_earliest_pa_period_name;
        return ( g_recvr_pa_end_date ) ;
      END IF ;
    END IF; -- profile

    -- receiver cache is EMPTY.
    -- Try to use the provider cache.

  ELSIF ( g_p_earliest_pa_start_date IS NOT NULL    /* 1982225 . we should check if prvdr cache is available or not. */
          and NVL( g_prvdr_org_id, -99 ) = NVL( p_org_id, -99 ) )
  THEN
    IF ( l_prof_new_gldate_derivation = 'Y' )
    THEN
      IF ( p_accounting_date BETWEEN g_prvdr_pa_start_date AND g_prvdr_pa_end_date AND
           p_expenditure_item_date <= g_prvdr_pa_start_date )
      THEN
         -- copy provider cache to receiver cache.
         g_recvr_org_id               := g_prvdr_org_id ;
         g_r_earliest_pa_start_date   := g_p_earliest_pa_start_date  ;
         g_r_earliest_pa_end_date     := g_p_earliest_pa_end_date  ;
         g_r_earliest_pa_period_name  := g_p_earliest_pa_period_name  ;
         g_recvr_pa_start_date        := g_prvdr_pa_start_date ;
         g_recvr_pa_end_date          := g_prvdr_pa_end_date ;
         g_recvr_pa_period_name       := g_prvdr_pa_period_name ;
         g_recvr_pa_date              := g_prvdr_pa_date ;
         return ( p_accounting_date ) ;
      ELSIF ( p_accounting_date <= g_p_earliest_pa_start_date AND
              p_expenditure_item_date <= g_p_earliest_pa_start_date )
      THEN
         -- copy provider cache to receiver cache.
         g_recvr_org_id               := g_prvdr_org_id ;
         g_r_earliest_pa_start_date   := g_p_earliest_pa_start_date  ;
         g_r_earliest_pa_end_date     := g_p_earliest_pa_end_date  ;
         g_r_earliest_pa_period_name  := g_p_earliest_pa_period_name  ;
         g_recvr_pa_start_date        := g_p_earliest_pa_start_date ;
         g_recvr_pa_end_date          := g_p_earliest_pa_end_date ;
         g_recvr_pa_period_name       := g_p_earliest_pa_period_name ;
         g_recvr_pa_date              := g_prvdr_pa_date ;
         return ( g_recvr_pa_start_date ) ;
      END IF; --p_accounting_date
    ELSE -- profile not set
      IF ( p_accounting_date BETWEEN g_prvdr_pa_start_date AND g_prvdr_pa_end_date AND
           p_expenditure_item_date <= g_prvdr_pa_end_date )
      THEN
         -- copy provider cache to receiver cache.
         g_recvr_org_id               := g_prvdr_org_id ;
         g_r_earliest_pa_start_date   := g_p_earliest_pa_start_date  ;
         g_r_earliest_pa_end_date     := g_p_earliest_pa_end_date  ;
         g_r_earliest_pa_period_name  := g_p_earliest_pa_period_name  ;
         g_recvr_pa_start_date        := g_prvdr_pa_start_date ;
         g_recvr_pa_end_date          := g_prvdr_pa_end_date ;
         g_recvr_pa_period_name       := g_prvdr_pa_period_name ;
         g_recvr_pa_date              := g_prvdr_pa_date ;
         return ( g_recvr_pa_end_date ) ;
      ELSIF ( p_accounting_date <= g_p_earliest_pa_end_date AND
              p_expenditure_item_date <= g_p_earliest_pa_end_date )
      THEN
         -- copy provider cache to receiver cache.
         g_recvr_org_id               := g_prvdr_org_id ;
         g_r_earliest_pa_start_date   := g_p_earliest_pa_start_date  ;
         g_r_earliest_pa_end_date     := g_p_earliest_pa_end_date  ;
         g_r_earliest_pa_period_name  := g_p_earliest_pa_period_name  ;
         g_recvr_pa_start_date        := g_p_earliest_pa_start_date ;
         g_recvr_pa_end_date          := g_p_earliest_pa_end_date ;
         g_recvr_pa_period_name       := g_p_earliest_pa_period_name ;
         g_recvr_pa_date              := g_prvdr_pa_date ;
         return ( g_p_earliest_pa_end_date ) ;
      END IF; --p_accounting_date
    END IF ;  -- profile
  END IF ; -- recvr cache check
 /*
  *If control comes here,
  *EITHER receiver cache is EMPTY or ( Both provider AND receiver caches are NOT reusable )
  *hence hit the DB and populate/refresh receiver cache.
  *then return g_recvr_pa_date.
  */

    pa_integration.refresh_pa_cache ( p_org_id , p_expenditure_item_date , p_accounting_date, 'R' );
    RETURN ( g_recvr_pa_date ) ;
EXCEPTION
    WHEN OTHERS THEN
      RAISE ;
END get_raw_cdl_recvr_pa_date ;
-------------------------------------------------------------------------------------------------------

-- FUnction get_burden_cdl_pa_date
-- This function is created for Bug no : 1103257. FUnction will be called by
-- PACODTBC process (Distribute total burden cost). FUnction will ruturn the
-- Date to be populated as PA_DATE for Burden CDLs. FUnction will be called
-- only when the C and D types of the rows will be created for Supplier
-- Invoices.
---------------------------------------------------------------------------
/*
 * EPP.
 * This function is NOT used anymore. Instead pa_utils2.get_pa_date is used
 * since the functionality is same in both the procedures. Only the parameter
 * is different.
 */
FUNCTION get_burden_cdl_pa_date ( p_raw_cdl_date  IN DATE )
    RETURN DATE
IS
    l_pa_period_end_date  DATE;
BEGIN
   SELECT     MIN(pap.end_date)
     INTO     l_pa_period_end_date
     FROM     pa_periods pap
    WHERE     pap.status in ( 'O', 'F')
      AND     pap.end_date >= p_raw_cdl_date;

   RETURN     l_pa_period_end_date;
END get_burden_cdl_pa_date;
---------------------------------------------------------------------------
--End FUnction get_burden_cdl_pa_date
---------------------------------------------------------------------------
/*
 * EPP.
 * This function can be called for both Provider and Receiver gl dates
 * by passing the appropriate parameters.
 */
FUNCTION get_gl_period_name ( p_gl_date         IN pa_cost_distribution_lines_all.gl_date%TYPE
                             ,p_set_of_books_id IN pa_implementations_all.set_of_books_id%TYPE
                            )
RETURN pa_cost_distribution_lines_all.gl_period_name%TYPE
IS
    l_gl_period_name pa_cost_distribution_lines_all.gl_period_name%TYPE;
    l_gl_start_date  DATE;
    l_gl_end_date    DATE;
BEGIN

    If (trunc(p_gl_date) between trunc(G_PrevPdStDate) and trunc(G_PrevPdEdDate)) AND
       G_PrevSOBId = p_set_of_books_id Then

       l_gl_period_name := G_PrevPeriodName;

    Else
          SELECT PERIOD.period_name, PERIOD.start_date, PERIOD.end_date
            INTO l_gl_period_name, l_gl_start_date, l_gl_end_date
            FROM GL_PERIOD_STATUSES PERIOD
           WHERE PERIOD.set_of_books_id = p_set_of_books_id
             AND PERIOD.application_id = Pa_Period_Process_Pkg.Application_Id
             AND PERIOD.adjustment_period_flag = 'N'
             AND p_gl_date BETWEEN PERIOD.start_date AND PERIOD.end_date
         ;

        G_PrevPeriodName := l_gl_period_name;
        G_PrevPdStDate   := l_gl_start_date;
        G_PrevPdEdDate   := l_gl_end_date;
        G_PrevSOBId      := p_set_of_books_id;

     End If;

     RETURN     l_gl_period_name;
EXCEPTION
WHEN NO_DATA_FOUND
THEN
  l_gl_period_name := NULL;
  RETURN l_gl_period_name;
END get_gl_period_name;
---------------------------------------------------------------------------

/*
 * The period information calculation is same for all transactions coming
 * into PA thro transaction import. The following procedure does not distinguish
 * between system linkages.
 */
PROCEDURE get_period_information ( p_expenditure_item_date IN pa_expenditure_items_all.expenditure_item_date%TYPE
                                  ,p_prvdr_gl_date IN pa_cost_distribution_lines_all.gl_date%TYPE
                                  ,p_line_type IN pa_cost_distribution_lines_all.line_type%TYPE
                                  ,p_prvdr_org_id IN pa_expenditure_items_all.org_id%TYPE
                                  ,p_recvr_org_id IN pa_expenditure_items_all.org_id%TYPE
                                  ,p_prvdr_sob_id IN pa_implementations_all.set_of_books_id%TYPE
                                  ,p_recvr_sob_id IN pa_implementations_all.set_of_books_id%TYPE
                                  ,x_prvdr_pa_date OUT NOCOPY pa_cost_distribution_lines_all.pa_date%TYPE
                                  ,x_prvdr_pa_period_name OUT NOCOPY pa_cost_distribution_lines_all.pa_period_name%TYPE
                                  ,x_prvdr_gl_period_name OUT NOCOPY pa_cost_distribution_lines_all.gl_period_name%TYPE
                                  ,x_recvr_pa_date OUT NOCOPY pa_cost_distribution_lines_all.recvr_pa_date%TYPE
                                  ,x_recvr_pa_period_name OUT NOCOPY pa_cost_distribution_lines_all.recvr_pa_period_name%TYPE
                                  ,x_recvr_gl_date OUT NOCOPY pa_cost_distribution_lines_all.recvr_gl_date%TYPE
                                  ,x_recvr_gl_period_name OUT NOCOPY pa_cost_distribution_lines_all.recvr_gl_period_name%TYPE
                                  ,x_return_status OUT NOCOPY NUMBER
                                  ,x_error_code OUT NOCOPY VARCHAR2
                                  ,x_error_stage OUT NOCOPY NUMBER
                                 )
IS
    l_prvdr_pa_date        pa_cost_distribution_lines_all.pa_date%TYPE;
    l_prvdr_pa_period_name pa_periods.period_name%TYPE;
    l_prvdr_gl_period_name gl_periods.period_name%TYPE;

    l_recvr_pa_date        pa_cost_distribution_lines_all.pa_date%TYPE;
    l_recvr_pa_period_name pa_periods.period_name%TYPE;
    l_recvr_gl_date        pa_cost_distribution_lines_all.gl_date%TYPE;
    l_recvr_gl_period_name gl_periods.period_name%TYPE;

    l_pa_gl_app_id NUMBER := 8721;
    l_gl_app_id NUMBER := 101;

  /*
   * Processing related variables.
   */
  l_return_status              VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  l_error_code                 VARCHAR2(30);
  l_error_stage                VARCHAR2(30);
  l_debug_mode                 VARCHAR2(1);
  l_stage                      NUMBER ;

  l_prof_new_gldate_derivation VARCHAR2(1) := 'N';
  l_use_same_pa_gl_period_prvdr VARCHAR2(1) := 'N';
  l_use_same_pa_gl_period_recvr VARCHAR2(1) := 'N';
BEGIN
  pa_debug.init_err_stack('pa_integration.get_period_information');

  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'N');

  pa_debug.set_process('PLSQL','LOG',l_debug_mode);

  l_stage := 100;
  IF l_debug_mode = 'Y' THEN
   pa_debug.g_err_stage := TO_CHAR(l_stage) || ':From get_period_information';
   pa_debug.write_file(pa_debug.g_err_stage);
  END IF;

  /*
   * Populating setup related variables.
   */
  /* Changed from value_specific to value for bug 5472333 */
  l_prof_new_gldate_derivation := NVL(fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION'), 'N') ;
  l_use_same_pa_gl_period_prvdr := NVL(PA_PERIOD_PROCESS_PKG.Use_Same_PA_GL_Period(p_prvdr_org_id), 'N');
  l_use_same_pa_gl_period_recvr := NVL(PA_PERIOD_PROCESS_PKG.Use_Same_PA_GL_Period(p_recvr_org_id), 'N');

    IF ( l_prof_new_gldate_derivation = 'Y' )
    THEN
      l_stage := 200;
            /*
             * Get Gl periods based on ei date.
             */
            l_prvdr_gl_period_name := pa_integration.get_gl_period_name( p_gl_date => p_prvdr_gl_date
                                                                        ,p_set_of_books_id => p_prvdr_sob_id
                                                                       );

            -- Bug 2248543 Added provider and receiver org_id check
            if (nvl(p_prvdr_org_id,-99) <> nvl(p_recvr_org_id,-99)) then
                l_recvr_gl_date := pa_utils2.get_recvr_gl_date( p_reference_date => p_expenditure_item_date
                                                           ,p_application_id => l_pa_gl_app_id
                                                           ,p_set_of_books_id => p_recvr_sob_id
                                                          );
                l_recvr_gl_period_name := pa_utils2.g_recvr_gl_period_name;
            else
                l_recvr_gl_date := p_prvdr_gl_date;
                l_recvr_gl_period_name := l_prvdr_gl_period_name;
            end if;

            /*
             * Deriving PA period information for Provider.
             */
            IF ( l_use_same_pa_gl_period_prvdr = 'Y' )
            THEN
              l_stage := 300;
              /*
               * Copy Gl period information to Pa periods.
               */
              l_prvdr_pa_date := p_prvdr_gl_date;
              l_prvdr_pa_period_name := l_prvdr_gl_period_name;
            ELSE -- implementation option is not set
              l_stage := 400;
              /*
               * Get Pa periods based on ei date.
               */

              l_prvdr_pa_date := pa_utils2.get_pa_date
                                                      ( p_ei_date  => p_expenditure_item_date
                                                       ,p_gl_date  => SYSDATE
                                                       ,p_org_id   => p_prvdr_org_id
                                                      );
              l_prvdr_pa_period_name := pa_utils2.g_prvdr_pa_period_name;

            END IF; -- implementations option
            /*
             * Deriving PA period information for Receiver.
             */
            IF ( l_use_same_pa_gl_period_recvr = 'Y' )
            THEN
              l_stage := 425;
              /*
               * Copy Gl period information to Pa periods.
               */
              l_recvr_pa_date := l_recvr_gl_date;
              l_recvr_pa_period_name := l_recvr_gl_period_name;
            ELSE -- implementation option is not set
              l_stage := 450;
              /*
               * Get Pa periods based on ei date.
               */

              -- Bug 2248543 Added provider and receiver org_id check
              if (nvl(p_prvdr_org_id,-99) <> nvl(p_recvr_org_id,-99)) then
                 l_recvr_pa_date := pa_utils2.get_recvr_pa_date
                                                      ( p_ei_date  => p_expenditure_item_date
                                                       ,p_gl_date  => SYSDATE
                                                       ,p_org_id   => p_recvr_org_id
                                                      );
                 l_recvr_pa_period_name := pa_utils2.g_recvr_pa_period_name;
              else
                 l_recvr_pa_date := l_prvdr_pa_date;
                 l_recvr_pa_period_name := l_prvdr_pa_period_name;
              end if;

            END IF; -- implementations option
    ELSE -- profile option is not set.
      l_stage := 500;
      /*
       * Get Pa periods based on ei date.
       */
         l_prvdr_pa_date := pa_integration.get_raw_cdl_pa_date
                                                      ( p_expenditure_item_date => p_expenditure_item_date
                                                       ,p_accounting_date => p_prvdr_gl_date
                                                       ,p_org_id => p_prvdr_org_id
                                                      );
         l_prvdr_pa_period_name := g_prvdr_pa_period_name;

         /*
          * recvr_gl_date is not available from txn import.
          * should find a way out.
          */
         -- Bug 2248543 Added provider and receiver org_id check
         if (nvl(p_prvdr_org_id,-99) <> nvl(p_recvr_org_id,-99)) then
            l_recvr_pa_date := pa_utils2.get_recvr_pa_date
                                                      ( p_ei_date => p_expenditure_item_date
                                                       ,p_gl_date => SYSDATE
                                                       ,p_org_id => p_recvr_org_id
                                                      );
            l_recvr_pa_period_name := pa_utils2.g_recvr_pa_period_name;
         else
            l_recvr_pa_date := l_prvdr_pa_date;
            l_recvr_pa_period_name := l_prvdr_pa_period_name;
         end if;

      /*
       * Get Gl periods based on above derived Pa date.
       */
         l_prvdr_gl_period_name := get_gl_period_name( p_gl_date => p_prvdr_gl_date
                                                      ,p_set_of_books_id => p_prvdr_sob_id
                                                     );

         -- Bug 2248543 Added provider and receiver org_id check
         if (nvl(p_prvdr_org_id,-99) <> nvl(p_recvr_org_id,-99)) then
             l_recvr_gl_date := pa_utils2.get_recvr_gl_date( p_reference_date => l_recvr_pa_date
                                                        ,p_application_id => l_gl_app_id
                                                        ,p_set_of_books_id => p_recvr_sob_id
                                                       );
             l_recvr_gl_period_name := pa_utils2.g_recvr_gl_period_name;
         else
             l_recvr_gl_date := p_prvdr_gl_date;
             l_recvr_gl_period_name := l_prvdr_gl_period_name;
         end if;

    END IF; -- profile option
    l_stage := 600;

    /*
     * Populate the out variables.
     */
    x_prvdr_pa_date := l_prvdr_pa_date;
    x_prvdr_pa_period_name := l_prvdr_pa_period_name;
    x_prvdr_gl_period_name := l_prvdr_gl_period_name;

    x_recvr_pa_date := l_recvr_pa_date;
    x_recvr_pa_period_name := l_recvr_pa_period_name;
    x_recvr_gl_date := l_recvr_gl_date;
    x_recvr_gl_period_name := l_recvr_gl_period_name;

    x_return_status := 0;

    -- reset the error stack
    PA_DEBUG.reset_err_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_prvdr_pa_date := NULL;
    x_prvdr_pa_period_name := NULL;
    x_prvdr_gl_period_name := NULL;

    x_recvr_pa_date := NULL;
    x_recvr_pa_period_name := NULL;
    x_recvr_gl_date := NULL;
    x_recvr_gl_period_name := NULL;
  WHEN OTHERS THEN
     RAISE ;
END; -- get_period_information


END pa_integration;

/
