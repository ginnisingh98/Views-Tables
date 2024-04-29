--------------------------------------------------------
--  DDL for Package Body OKI_UTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_UTL_PVT" as
/* $Header: OKIRUTLB.pls 115.28 2003/11/24 08:25:15 kbajaj ship $ */

--------------------------------------------------------------------------------
-- Modification History
-- 25-Aug-2001  mezra     Removed uppercase from defaulting logic for
--                        period set, period name and period type
--                        due to release  JTF 11.5.5.1.1.A
-- 05-Sep-2001  mezra     Change length of l_message in get_rfh_date.
-- 20-Sep-2001  mezra     Added get_aging_label function.
-- 27-Sep-2001  mezra     Fixed get_aging_label to return the correct header
--                        labels
--                        Change get_period_set, get_period_type,
--                        get_period_name to take a parameter value
--                        that is defaulted to to null.
-- 01-Oct-2001  mezra     Added function to determine the start and
--                        end value of the age grouping.
--                        Added function to get the bin title for the
--                        aging detail bin.
-- 19-Oct-2001 rpotnuru   Commented dbms_output statements
-- 18-Dec-2001 mezra      Removed dbms_output statements.
--                        Changed get_rfh_date function to support parameters
--                        as defined by DCF.
-- 19-Dec-2001 mezra      Added function get_aging_label1, get_aging_label2,
--                        get_aging_label3, get_aging_label4 to get the aging
--                        label for column.
-- 26-Dec-2001 mezra      Added cursors that are used across packages:
--                        g_tactk_all_csr, g_tactk_by_org_csr,
--                        g_rnwl_oppty_all_csr, g_rnwl_oppty_by_org_csr,
--                        g_k_exp_in_qtr_all_csr, g_k_exp_in_qtr_by_org_csr,
--                        g_org_csr.
--                        Added get_bin_title2 to retrieve the title for the
--                        drilldown bins.
-- 26-Dec-2001 mezra      Added function to default the build summary date.
-- 04-Jan-2002 mezra      Remove all functions and procedures for the bin.
-- 20-Mar-2002 mezra      Added logic to set the previous year summary
--                        build date.
-- 27-MAR-2002 mezra      Changed total active contracts cursor to retrieve
--                        data at the covered product line level
-- 02-APR-2002 mezra      Changed total active contracts cursor logic to
--                        include contracts that are expiring on the
--                        same day as the summary build date.
-- 08-Apr-2002 mezra      Added g_bin_disp_lkup_csr cursor to retrieve bin
--                        display lookup details.
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--
-- 28-Oct-2003 axraghav    populated null for Organization name in g_org_csr  as
--                         this name is tobe resolved in the views
--------------------------------------------------------------------------------

  -- Global cursor declaration

  -- Cursor to get the gl_periods based on period_set_name,
  -- period_type and p_summary_build_date between the start_date
  -- and end_date
  CURSOR g_glpr_csr
  (
      p_period_set_name    IN VARCHAR2
    , p_period_type        IN vARCHAR2
    , p_summary_build_date IN DATE
  ) RETURN gl_periods%ROWTYPE IS
  SELECT   *
  FROM     gl_periods glpr
  WHERE    glpr.adjustment_period_flag = 'N'
  AND      p_summary_build_date BETWEEN glpr.start_date AND glpr.end_date
  AND      glpr.period_set_name LIKE NVL(p_period_set_name, '%')
  AND      glpr.period_type LIKE NVL(p_period_type, '%')
  ;

  -- Retrieve the total active contracts
  CURSOR g_tactk_all_csr
  (
     p_start_date IN DATE
  ) RETURN g_tactk_all_csr_row IS
    SELECT  NVL(SUM(cpl.base_price_negotiated), 0) value
          , COUNT(DISTINCT(shd.chr_id)) contract_count
    FROM   oki_sales_k_hdrs shd
         , oki_cov_prd_lines cpl
    WHERE  shd.chr_id = cpl.chr_id
    AND    cpl.sts_code = 'ACTIVE'
    AND    shd.date_signed   <= p_start_date
    AND    shd.date_approved <= p_start_date
    AND    shd.start_date    <= p_start_date
    AND    shd.end_date      >= p_start_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated  > p_start_date )
    AND    shd.base_contract_amount BETWEEN 0
                                        AND oki_utl_pub.g_contract_limit
    ;

  -- Retrieve the total active contracts by organization
  CURSOR g_tactk_by_org_csr
  (
     p_start_date       IN DATE
   , p_authoring_org_id IN NUMBER
  ) RETURN g_tactk_by_org_csr_row IS
    SELECT  NVL(SUM(cpl.base_price_negotiated), 0) value
          , COUNT(DISTINCT cpl.chr_id) contract_count
          , shd.authoring_org_id authoring_org_id
    FROM   oki_sales_k_hdrs shd
         , oki_cov_prd_lines cpl
    WHERE  shd.chr_id = cpl.chr_id
    AND    cpl.sts_code = 'ACTIVE'
    AND    shd.date_signed   <= p_start_date
    AND    shd.date_approved <= p_start_date
    AND    shd.start_date    <= p_start_date
    AND    shd.end_date      >= p_start_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated  > p_start_date )
    AND    shd.base_contract_amount BETWEEN 0
                                        AND oki_utl_pub.g_contract_limit
    AND    shd.authoring_org_id = p_authoring_org_id
    GROUP BY shd.authoring_org_id
    ORDER BY value
    ;

  -- Retrieve the renewal opportunity
  CURSOR g_rnwl_oppty_all_csr
  (
     p_qtr_end_date IN DATE
  ) RETURN g_rnwl_oppty_all_csr_row IS
    SELECT NVL(SUM(shd.base_contract_amount), 0) value
         , COUNT(shd.chr_id) contract_count
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.start_date    <= p_qtr_end_date
    AND    shd.is_new_yn     IS NULL
    AND    shd.date_signed   IS NULL
    AND    shd.date_canceled IS NULL
    AND    shd.contract_amount BETWEEN 0
                                   AND oki_utl_pub.g_contract_limit
  ;


  -- Retrieve the renewal opportunity by organization
  CURSOR g_rnwl_oppty_by_org_csr
  (
     p_qtr_end_date     IN DATE
   , p_authoring_org_id IN NUMBER
  ) RETURN g_rnwl_oppty_by_org_csr_row IS
    SELECT NVL(SUM(shd.base_contract_amount), 0) value
         , COUNT(shd.chr_id) contract_count
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.start_date    <= p_qtr_end_date
    AND    shd.is_new_yn     IS NULL
    AND    shd.date_signed   IS NULL
    AND    shd.date_canceled IS NULL
    AND    shd.contract_amount BETWEEN 0
                                   AND oki_utl_pub.g_contract_limit
    AND    shd.authoring_org_id = p_authoring_org_id
    GROUP BY shd.authoring_org_id
    ORDER BY value
    ;

  -- Retrieve contracts that are expiring in the quarter
  CURSOR g_k_exp_in_qtr_all_csr
  (
     p_qtr_start_date  IN DATE
   , p_qtr_end_date    IN DATE
  ) RETURN g_k_exp_in_qtr_all_csr_row IS
   SELECT NVL(SUM(base_contract_amount), 0) value
        , COUNT(shd.chr_id) contract_count
   FROM   oki_sales_k_hdrs shd
   WHERE  shd.date_signed   <= p_qtr_start_date
   AND    shd.date_approved <= p_qtr_end_date
   AND    shd.end_date BETWEEN p_qtr_start_date AND p_qtr_end_date
   AND    shd.date_terminated IS NULL
   AND    shd.base_contract_amount BETWEEN 0
                                       AND oki_utl_pub.g_contract_limit
   ;

  -- Retrieve contracts that are expiring in the quarter
  CURSOR g_k_exp_in_qtr_by_org_csr
  (
     p_qtr_start_date   IN DATE
   , p_qtr_end_date     IN DATE
   , p_authoring_org_id IN NUMBER
  ) RETURN g_k_exp_in_qtr_by_org_csr_row IS
   SELECT NVL(SUM(base_contract_amount), 0) value
        , COUNT(shd.chr_id) contract_count
   FROM   oki_sales_k_hdrs shd
   WHERE  shd.date_signed   <= p_qtr_start_date
   AND    shd.date_approved <= p_qtr_end_date
   AND    shd.end_date BETWEEN p_qtr_start_date AND p_qtr_end_date
   AND    shd.date_terminated IS NULL
   AND    shd.base_contract_amount BETWEEN 0
                                       AND oki_utl_pub.g_contract_limit
    AND    shd.authoring_org_id = p_authoring_org_id
   ;
/*
  -- Contracts that have been renewed in the quarter
  CURSOR g_k_rnwed_csr
  (
     p_qtr_start_date   IN DATE
   , p_qtr_end_date     IN DATE
   , p_authoring_org_id IN NUMBER

  ) IS
    SELECT NVL(SUM(base_contract_amount), 0) value
         , COUNT(shd.chr_id) contract_count
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.is_new_yn       IS NULL
    AND    shd.date_signed     IS NOT NULL
    AND    shd.start_date BETWEEN p_qtr_start_date AND p_qtr_end_date
    AND    GREATEST(shd.date_signed, shd.date_approved) <= p_qtr_end_date
    AND    shd.base_contract_amount BETWEEN 0
                                       AND oki_utl_pub.g_contract_limit
    AND    shd.authoring_org_id = p_authoring_org_id
    ;
*/

  -- Retrieve the organization

/*11510 Change Null the Organization name as this resolved in the views*/

  CURSOR g_org_csr RETURN g_org_csr_row IS
    SELECT DISTINCT shd.authoring_org_id authoring_org_id
                  , NULL organization_name
    FROM   oki_sales_k_hdrs shd
    ;

  -- Retrieve the bin metadata
  CURSOR g_bin_disp_lkup_csr
  (  p_bin_id   IN VARCHAR2
   , p_bin_code IN VARCHAR2
  ) RETURN g_bin_disp_lkup_csr_row IS
    SELECT  bdl.bin_code_meaning bin_code_meaning
          , bdl.bin_code_seq bin_code_seq
    FROM oki_bin_disp_lkup bdl
    WHERE bdl.bin_id   = p_bin_id
    AND   bdl.bin_code = p_bin_code
    ;


--------------------------------------------------------------------------------
  -- Procedure to get the GL period start and end dates.
--------------------------------------------------------------------------------
  PROCEDURE get_gl_period_date
  (
     x_retcode OUT NOCOPY VARCHAR2
  ) IS

  -- Cursor to set the GL period start and end dates
  CURSOR l_gl_period_csr IS
    SELECT glpr.*
    FROM
         gl_periods glpr
       , gl_sets_of_books sob
       , hr_organization_information oin
    WHERE
         oki_utl_pub.g_summary_build_date BETWEEN glpr.start_date
                                              AND glpr.end_date
    AND  glpr.period_set_name         = sob.period_set_name
    AND  glpr.period_type             = sob.accounted_period_type
    AND  glpr.adjustment_period_flag  = 'N'
    AND  sob.set_of_books_id          = oin.org_information3
    AND  oin.org_information_context  = 'Operating Unit Information'
    AND  oin.organization_id          = fnd_profile.value('OKI_BASE_ORG_ID')
    ;
  rec_l_gl_period_csr l_gl_period_csr%ROWTYPE ;

  BEGIN
    OPEN l_gl_period_csr ;
    FETCH l_gl_period_csr INTO rec_l_gl_period_csr ;
      IF l_gl_period_csr%FOUND THEN
        -- Set current year start / end information
        oki_utl_pub.g_glpr_start_date      := rec_l_gl_period_csr.start_date ;
        oki_utl_pub.g_glpr_end_date        := rec_l_gl_period_csr.end_date ;
        oki_utl_pub.g_glpr_qtr_start_date  := rec_l_gl_period_csr.quarter_start_date ;
        oki_utl_pub.g_glpr_qtr_end_date    :=
            ADD_MONTHS(oki_utl_pub.g_glpr_qtr_start_date, 3 ) - 1 ;
        oki_utl_pub.g_glpr_qtr_num         := rec_l_gl_period_csr.quarter_num ;
        oki_utl_pub.g_glpr_year_start_date := rec_l_gl_period_csr.year_start_date ;
        oki_utl_pub.g_glpr_year_end_date   :=
            ADD_MONTHS(TRUNC(oki_utl_pub.g_glpr_year_start_date,'YYYY' ), 12 ) -1 ;
        oki_utl_pub.g_period_year          := rec_l_gl_period_csr.period_year ;
        oki_utl_pub.g_week_start_date      := ( oki_utl_pub.g_summary_build_date -
            TO_NUMBER(TO_CHAR(oki_utl_pub.g_summary_build_date,'D' )) -1) ;

        -- Set prior year start / end information
        oki_utl_pub.g_py_summary_build_date
                      := ADD_MONTHS(oki_utl_pub.g_summary_build_date, -12) ;
        oki_utl_pub.g_py_glpr_start_date
                      := ADD_MONTHS(oki_utl_pub.g_glpr_start_date, -12 ) ;
        oki_utl_pub.g_py_glpr_end_date
                      := ADD_MONTHS(oki_utl_pub.g_glpr_end_date, -12) ;
        oki_utl_pub.g_py_glpr_qtr_start_date
                      := ADD_MONTHS(oki_utl_pub.g_glpr_qtr_start_date, -12 ) ;
        oki_utl_pub.g_py_glpr_qtr_end_date
                      := ADD_MONTHS(oki_utl_pub.g_glpr_qtr_end_date, -12 ) ;
        oki_utl_pub.g_py_glpr_qtr_num
                      := oki_utl_pub.g_glpr_qtr_num ;
        oki_utl_pub.g_py_glpr_year_start_date
                      := ADD_MONTHS(oki_utl_pub.g_glpr_year_start_date, -12 ) ;
        oki_utl_pub.g_py_glpr_year_end_date
                      := ADD_MONTHS(oki_utl_pub.g_glpr_year_end_date, -12 ) ;
        oki_utl_pub.g_py_period_year
                      := oki_utl_pub.g_period_year -1 ;
        oki_utl_pub.g_py_week_start_date
                      := ADD_MONTHS(oki_utl_pub.g_week_start_date, -12 ) ;
      END IF ;
    CLOSE l_gl_period_csr ;
  END get_gl_period_date ;

END oki_utl_pvt ;

/
