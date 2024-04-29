--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_SGR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_SGR_PVT" AS
/* $Header: OKIRSGRB.pls 115.8 2002/06/06 11:35:21 pkm ship        $ */

--------------------------------------------------------------------------------
-- Modification History
-- 11-Nov-2001  mezra        Corrected logic for ending active contracts.
--                           Expired in quarter, cancelled renewals and
--                           terminated contracts are subtracted from the
--                           running total for ending active contracts.
-- 11-Nov-2001  mezra        Added restriction to retrieve contracts that are
--                           within a particular threshold.  Fixed contracts
--                           terminated cursor to sum the contracts.
-- 17-Oct-2001  mezra        Removed the trunc function from all date columns
--                           since the truncated date is placed into
--                           oki_sales_k_hdrs.  This program no longer needs
--                           to truncate the dates.
-- 10-Oct-2001  mezra        Initial version
--
--------------------------------------------------------------------------------

  -- Global exception declaration

  -- Generic exception to immediately exit the procedure
  g_excp_exit_immediate   EXCEPTION ;


  -- Global constant delcaration

  -- Constants for the all organization and caetgory record
  g_all_org_id       CONSTANT NUMBER       := -1 ;
  g_all_org_name     CONSTANT VARCHAR2(60) := 'All Organizations' ;
  g_all_cst_id       CONSTANT NUMBER       := -1 ;
  g_all_cst_name     CONSTANT VARCHAR2(30) := 'All Customers' ;
  g_all_scs_code     CONSTANT VARCHAR2(30) := '-1' ;
  g_all_pct_code     CONSTANT VARCHAR2(30) := '-1' ;

  g_active_k_code     CONSTANT VARCHAR2(30) := 'BACTK' ;
  g_exp_in_qtr_code   CONSTANT VARCHAR2(30) := 'EXPINQTR' ;
  g_qtr_k_rnw_code    CONSTANT VARCHAR2(30) := 'QTRKRNW' ;
  g_bklg_k_rnw_code   CONSTANT VARCHAR2(30) := 'BKLGKRNW' ;
  g_new_bsn_code      CONSTANT VARCHAR2(30) := 'NEWBUS' ;
  g_cncl_rnwl_code    CONSTANT VARCHAR2(30) := 'CNCLRNWL' ;
  g_end_active_k_code CONSTANT VARCHAR2(30) := 'ENDACTK' ;
  g_seq_grw_rate_code CONSTANT VARCHAR2(30) := 'SEQGWRT' ;
  g_seq_trmn_k_code   CONSTANT VARCHAR2(30) := 'TRMNK' ;
  g_problem_k_threshold CONSTANT NUMBER       :=
                                fnd_profile.value('OKI_PROBLEM_K_THRESHOLD') ;

  -- Global cursor declaration

  -- Cusror to retrieve the rowid for the selected record
  CURSOR g_sgr_csr
  (   p_period_set_name       IN  VARCHAR2
    , p_period_name           IN  VARCHAR2
    , p_authoring_org_id      IN  NUMBER
    , p_seq_grw_rate_code     IN  VARCHAR2
    , p_scs_code              IN  VARCHAR2
    , p_customer_party_id     IN  NUMBER
    , p_product_category_code IN  VARCHAR2
    , p_summary_build_date    IN  DATE
    , p_period_type           IN  VARCHAR2
  ) IS
    SELECT rowid
    FROM   oki_seq_growth_rate sgr
    WHERE  sgr.period_set_name       = p_period_set_name
    AND    sgr.period_name           = p_period_name
    AND    sgr.authoring_org_id      = p_authoring_org_id
    AND    sgr.seq_grw_rate_code     = p_seq_grw_rate_code
    AND    sgr.scs_code              = p_scs_code
    AND    sgr.customer_party_id     = p_customer_party_id
    AND    sgr.product_category_code = p_product_category_code
    AND    sgr.summary_build_date    = p_summary_build_date
    AND    sgr.period_type           = p_period_type
    ;
  rec_g_sgr_csr g_sgr_csr%ROWTYPE ;



  -- Cusor declaration

  -- Cursor that calculates the contract amount for all
  -- the active contracts
  CURSOR g_active_k_csr
  (   p_summary_build_date IN DATE
  ) IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.date_signed   <= p_summary_build_date
    AND    shd.date_approved <= p_summary_build_date
    AND    shd.start_date    <= p_summary_build_date
    AND    shd.end_date       > p_summary_build_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated  > p_summary_build_date)
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_g_active_k_csr g_active_k_csr%ROWTYPE ;

  -- Cursor that calculates contract amounts for all contracts
  -- expiring this quarter
  CURSOR g_expire_in_qtr_csr
  (   p_glpr_qtr_start_date  IN DATE
    , p_glpr_qtr_end_date    IN DATE
    , p_summary_build_date   IN DATE
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.date_signed   <= p_glpr_qtr_end_date
    AND    shd.date_approved <= p_glpr_qtr_end_date
    AND    shd.end_date BETWEEN p_glpr_qtr_start_date
                            AND p_glpr_qtr_end_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated  > p_summary_build_date)
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_g_expire_in_qtr_csr g_expire_in_qtr_csr%ROWTYPE ;

  -- Cursor that calculates contract amounts for contracts that
  -- have been renewed in this quarter
  CURSOR g_qtr_k_rnw_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.is_new_yn       IS NULL
    AND    shd.date_signed     IS NOT NULL
    AND    shd.date_approved   IS NOT NULL
    AND    shd.start_date BETWEEN p_glpr_qtr_start_date
                                     AND p_summary_build_date
    AND    GREATEST(shd.date_signed, shd.date_approved)
              BETWEEN p_glpr_qtr_start_date
                  AND p_summary_build_date
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_g_qtr_k_rnw_csr g_qtr_k_rnw_csr%ROWTYPE ;

  -- Contracts that were renewed in this quarter but should
  -- have been renewed before this quarter
  CURSOR g_bklg_k_rnw_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.is_new_yn     IS NULL
    AND    shd.date_signed   IS NOT NULL
    AND    shd.date_approved IS NOT NULL
    AND    shd.start_date     < p_glpr_qtr_start_date
    AND    GREATEST(shd.date_signed, shd.date_approved)
              BETWEEN p_glpr_qtr_start_date
                  AND p_summary_build_date
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_g_bklg_k_rnw_csr g_bklg_k_rnw_csr%ROWTYPE ;

  -- Contracts that are active in the current quarter that are not the
  -- result of renewal or renewal consolidation
  CURSOR g_new_bsn_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.date_signed   <= p_summary_build_date
    AND    shd.date_approved <= p_summary_build_date
    AND    shd.is_new_yn             = 'Y'
    AND    shd.start_date  BETWEEN p_glpr_qtr_start_date
                               AND p_summary_build_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated > p_summary_build_date)
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_g_new_bsn_csr g_new_bsn_csr%ROWTYPE ;

  -- Renewal or renewal consolidate contracts that have been cancelled
  CURSOR g_cncl_rnwl_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.ste_code      = 'CANCELLED'
    AND    shd.is_new_yn    IS NULL
    AND    shd.is_latest_yn IS NULL
    AND    shd.start_date BETWEEN p_glpr_qtr_start_date
                              AND p_summary_build_date
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_g_cncl_rnwl_csr g_cncl_rnwl_csr%ROWTYPE ;

  -- Contracts that have been termined in this quarter
  CURSOR g_trmn_rnwl_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
  )
  IS
    SELECT  NVL(SUM((((shd.end_date - shd.date_terminated) /
            (shd.end_date - shd.start_date)) *
            base_contract_amount)), 0) base_contract_amount
          , NVL(SUM((((shd.end_date - shd.date_terminated) /
            (shd.end_date - shd.start_date)) *
            sob_contract_amount)), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  date_terminated BETWEEN p_glpr_qtr_start_date
                                      AND p_summary_build_date
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_g_trmn_rnwl_csr g_trmn_rnwl_csr%ROWTYPE ;

--------------------------------------------------------------------------------
  -- Procedure to insert records into the oki_seq_growth_rate table.

--------------------------------------------------------------------------------
  PROCEDURE ins_seq_grw_rate
  (   p_period_set_name           IN  VARCHAR2
    , p_period_name               IN  VARCHAR2
    , p_period_type               IN  VARCHAR2
    , p_summary_build_date        IN  DATE
    , p_authoring_org_id          IN  NUMBER
    , p_authoring_org_name        IN  VARCHAR2
    , p_customer_party_id         IN  NUMBER
    , p_customer_name             IN  VARCHAR2
    , p_seq_grw_rate_code         IN  VARCHAR2
    , p_scs_code                  IN  VARCHAR2
    , p_product_category_code     IN  VARCHAR2
    , p_curr_base_contract_amount IN  NUMBER
    , p_prev_base_contract_amount IN  NUMBER
    , p_curr_sob_contract_amount  IN  NUMBER
    , p_prev_sob_contract_amount  IN  NUMBER
    , x_retcode                   OUT VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  BEGIN

    -- initialize return code to success
    x_retcode := '0';
    INSERT INTO oki_seq_growth_rate
    (        period_set_name
           , period_name
           , period_type
           , summary_build_date
           , authoring_org_id
           , authoring_org_name
           , customer_party_id
           , customer_name
           , seq_grw_rate_code
           , scs_code
           , product_category_code
           , curr_base_contract_amount
           , prev_base_contract_amount
           , curr_sob_contract_amount
           , prev_sob_contract_amount
           , request_id
           , program_application_id
           , program_id
           , program_update_date )
    VALUES ( p_period_set_name
           , p_period_name
           , p_period_type
           , p_summary_build_date
           , p_authoring_org_id
           , p_authoring_org_name
           , p_customer_party_id
           , p_customer_name
           , p_seq_grw_rate_code
           , p_scs_code
           , p_product_category_code
           , p_curr_base_contract_amount
           , p_prev_base_contract_amount
           , p_curr_sob_contract_amount
           , p_prev_sob_contract_amount
           , oki_load_sgr_pvt.g_request_id
           , oki_load_sgr_pvt.g_program_application_id
           , oki_load_sgr_pvt.g_program_id
           , oki_load_sgr_pvt.g_program_update_date ) ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_TABLE_LOAD_FAILURE' );

      fnd_message.set_token(  token => 'TABLE_NAME'
                            , value => 'OKI_SEQ_GROWTH_RATE' );

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get );

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '|| l_sqlerrm );

  END ins_seq_grw_rate ;

--------------------------------------------------------------------------------
  -- Procedure to update records in the oki_seq_growth_rate table.

--------------------------------------------------------------------------------
  PROCEDURE upd_seq_grw_rate
  (   p_curr_base_contract_amount  IN  NUMBER
    , p_prev_base_contract_amount  IN  NUMBER
    , p_curr_sob_contract_amount   IN  NUMBER
    , p_prev_sob_contract_amount   IN  NUMBER
    , p_sgr_rowid                  IN  ROWID
    , x_retcode                    OUT VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;


  BEGIN

    -- initialize return code to success
    x_retcode := '0';

    UPDATE oki_seq_growth_rate SET
        curr_base_contract_amount = p_curr_base_contract_amount
      , prev_base_contract_amount = p_prev_base_contract_amount
      , curr_sob_contract_amount  = p_curr_sob_contract_amount
      , prev_sob_contract_amount  = p_prev_sob_contract_amount
      , request_id                = oki_load_sgr_pvt.g_request_id
      , program_application_id    = oki_load_sgr_pvt.g_program_application_id
      , program_id                = oki_load_sgr_pvt.g_program_id
      , program_update_date       = oki_load_sgr_pvt.g_program_update_date
    WHERE ROWID =  p_sgr_rowid ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE' );

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_SGR_PVT.UPD_SEQ_GRW_RATE' );

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get );

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '|| l_sqlerrm );
  END upd_seq_grw_rate ;

--------------------------------------------------------------------------------
  -- Procedure to calcuate the contract amount for the current and previous
  -- year.

--------------------------------------------------------------------------------

  PROCEDURE calc_sgr_dtl1
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , x_retcode            OUT VARCHAR2
  ) IS

  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode          VARCHAR2(100)  := NULL ;
  l_sqlerrm          VARCHAR2(1000) := NULL ;

  -- Holds the contract amount for the current and previous
  -- beginning active contracts
  l_curr_active_k       NUMBER   := 0 ;
  l_prev_active_k       NUMBER   := 0 ;
  l_curr_sob_active_k   NUMBER   := 0 ;
  l_prev_sob_active_k   NUMBER   := 0 ;
  -- Holds the contract amount for the current and previous
  -- ending active contracts
  l_curr_end_active_k     NUMBER   := 0 ;
  l_prev_end_active_k     NUMBER   := 0 ;
  l_curr_sob_end_active_k NUMBER   := 0 ;
  l_prev_sob_end_active_k NUMBER   := 0 ;
  -- Holds the sequetial growth rate %
  l_curr_seq_grw_rate     NUMBER   := 0 ;
  l_prev_seq_grw_rate     NUMBER   := 0 ;
  l_curr_sob_seq_grw_rate NUMBER   := 0 ;
  l_prev_sob_seq_grw_rate NUMBER   := 0 ;
  -- Holds the contract amount current and previous
  -- sequential growth rate records
  l_curr_k_amount       NUMBER   := 0 ;
  l_prev_k_amount       NUMBER   := 0 ;
  l_curr_sob_k_amount   NUMBER   := 0 ;
  l_prev_sob_k_amount   NUMBER   := 0 ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(200) ;

  -- Holds the truncated start and end dates from gl_periods
  -- Holds the quarter start and end dates
  l_glpr_qtr_start_date      DATE ;
  l_glpr_qtr_end_date        DATE ;
  -- Holds the prior year summary build date
  l_py_summary_build_date    DATE ;
  -- Holds the start and end dates for the same quarter in the previous year
  l_sqpy_glpr_qtr_start_date DATE ;
  l_sqpy_glpr_qtr_end_date   DATE ;

  -- Cusor declaration

  -- Cursor that calculates the contract amount for all
  -- the active contracts
  CURSOR l_active_k_csr
  (   p_summary_build_date IN DATE
    , p_customer_party_id  IN NUMBER
  ) IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.date_signed   <= p_summary_build_date
    AND    shd.date_approved <= p_summary_build_date
    AND    shd.start_date    <= p_summary_build_date
    AND    shd.end_date       > p_summary_build_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated > p_summary_build_date)
    AND    shd.customer_party_id          = p_customer_party_id
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_l_active_k_csr l_active_k_csr%ROWTYPE ;

  -- Cursor that calculates contract amounts for all contracts
  -- expiring this quarter
  CURSOR l_expire_in_qtr_csr
  (   p_glpr_qtr_start_date  IN DATE
    , p_glpr_qtr_end_date    IN DATE
    , p_summary_build_date   IN DATE
    , p_customer_party_id    IN NUMBER
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.date_signed   <= p_glpr_qtr_end_date
    AND    shd.date_approved <= p_glpr_qtr_end_date
    AND    shd.end_date BETWEEN p_glpr_qtr_start_date
                            AND p_glpr_qtr_end_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated  > p_summary_build_date)
    AND    shd.customer_party_id    = p_customer_party_id
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_l_expire_in_qtr_csr l_expire_in_qtr_csr%ROWTYPE ;

  -- Cursor that calculates contract amounts for contracts that
  -- have been renewed in this quarter
  CURSOR l_qtr_k_rnw_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
    , p_customer_party_id   IN NUMBER
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.is_new_yn       IS NULL
    AND    shd.date_signed     IS NOT NULL
    AND    shd.date_approved   IS NOT NULL
    AND    shd.start_date BETWEEN p_glpr_qtr_start_date
                              AND p_summary_build_date
    AND    GREATEST(shd.date_signed, shd.date_approved)
              BETWEEN p_glpr_qtr_start_date
                  AND p_summary_build_date
    AND    shd.customer_party_id = p_customer_party_id
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_l_qtr_k_rnw_csr l_qtr_k_rnw_csr%ROWTYPE ;

  -- Contracts that were renewed in this quarter but should
  -- have been renewed before this quarter
  CURSOR l_bklg_k_rnw_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
    , p_customer_party_id   IN NUMBER
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.is_new_yn     IS NULL
    AND    shd.date_signed   IS NOT NULL
    AND    shd.date_approved IS NOT NULL
    AND    shd.start_date     < p_glpr_qtr_start_date
    AND    GREATEST(shd.date_signed, shd.date_approved)
              BETWEEN p_glpr_qtr_start_date
                  AND p_summary_build_date
    AND    shd.customer_party_id = p_customer_party_id
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_l_bklg_k_rnw_csr l_bklg_k_rnw_csr%ROWTYPE ;

  -- Contracts that are active in the current quarter that are not the
  -- result of renewal or renewal consolidation
  CURSOR l_new_bsn_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
    , p_customer_party_id   IN NUMBER
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.date_signed   <= p_summary_build_date
    AND    shd.date_approved <= p_summary_build_date
    AND    shd.is_new_yn      = 'Y'
    AND    shd.start_date BETWEEN p_glpr_qtr_start_date
                              AND p_summary_build_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated  > p_summary_build_date)
    AND    shd.customer_party_id    = p_customer_party_id
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_l_new_bsn_csr l_new_bsn_csr%ROWTYPE ;

  -- Renewal or renewal consolidate contracts that have been cancelled
  CURSOR l_cncl_rnwl_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
    , p_customer_party_id   IN NUMBER
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.ste_code     = 'CANCELLED'
    AND    shd.is_new_yn    IS NULL
    AND    shd.is_latest_yn IS NULL
    AND    shd.start_date BETWEEN p_glpr_qtr_start_date
                              AND p_summary_build_date
    AND    shd.customer_party_id = p_customer_party_id
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_l_cncl_rnwl_csr l_cncl_rnwl_csr%ROWTYPE ;

  -- Contracts that have been termined in this quarter
  CURSOR l_trmn_rnwl_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
    , p_customer_party_id   IN NUMBER
  )
  IS
    SELECT NVL(SUM((((shd.end_date - shd.date_terminated) /
            (shd.end_date - shd.start_date)) *
            base_contract_amount)), 0) base_contract_amount
         , NVL(SUM((((shd.end_date - shd.date_terminated) /
            (shd.end_date - shd.start_date)) *
            sob_contract_amount)), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  date_terminated BETWEEN p_glpr_qtr_start_date
                                      AND p_summary_build_date
    AND    shd.customer_party_id = p_customer_party_id
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_l_trmn_rnwl_csr l_trmn_rnwl_csr%ROWTYPE ;

  -- Cursor to retrieve the distinct organizations
  CURSOR l_cst_csr IS
    SELECT   DISTINCT shd.customer_party_id customer_party_id
           , shd.customer_name customer_name
    FROM     oki_sales_k_hdrs shd
    ;


  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    l_loc := 'Looping through valid organizations.' ;
    << l_cst_csr_loop >>
    -- Loop through all the organizations to calcuate the
    -- appropriate amounts
    FOR rec_l_cst_csr IN l_cst_csr LOOP

      l_loc := 'Looping through valid periods.' ;
      << g_glpr_csr_loop >>
      -- Loop through all the periods
      FOR rec_g_glpr_csr IN oki_utl_pvt.g_glpr_csr(
          p_period_set_name, p_period_type, p_summary_build_date ) LOOP

        -- Get the truncated gl_periods start and end dates
        l_glpr_qtr_start_date := trunc(rec_g_glpr_csr.quarter_start_date) ;
        l_glpr_qtr_end_date   := ADD_MONTHS(l_glpr_qtr_start_date, 3) - 1 ;

        -- Set the prior year summary build date
        l_py_summary_build_date  := ADD_MONTHS(p_summary_build_date, - 12) ;
        -- Set the quarter start and end dates for the same quarter
        -- in the previous  year
        l_sqpy_glpr_qtr_start_date := ADD_MONTHS(l_glpr_qtr_start_date, -12) ;
        l_sqpy_glpr_qtr_end_date   := ADD_MONTHS(l_glpr_qtr_end_date, -12) ;

        -- Re-initialize the amounts before calculating
        l_curr_active_k         := 0 ;
        l_prev_active_k         := 0 ;
        l_curr_sob_active_k     := 0 ;
        l_prev_sob_active_k     := 0 ;
        l_curr_end_active_k     := 0 ;
        l_prev_end_active_k     := 0 ;
        l_curr_sob_end_active_k := 0 ;
        l_prev_sob_end_active_k := 0 ;
        l_curr_seq_grw_rate     := 0 ;
        l_prev_seq_grw_rate     := 0 ;
        l_curr_sob_seq_grw_rate := 0 ;
        l_prev_sob_seq_grw_rate := 0 ;
        l_curr_k_amount         := 0 ;
        l_prev_k_amount         := 0 ;
        l_curr_sob_k_amount     := 0 ;
        l_prev_sob_k_amount     := 0 ;

        l_loc := 'Opening cursor to determine the current beginning ' ;
        l_loc := l_loc || 'active contracts.' ;
        OPEN l_active_k_csr ( p_summary_build_date,
             rec_l_cst_csr.customer_party_id ) ;
        FETCH l_active_k_csr INTO rec_l_active_k_csr ;
          IF l_active_k_csr%FOUND THEN
            l_curr_k_amount     := rec_l_active_k_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_l_active_k_csr.sob_contract_amount ;
            -- keep the beginning active amount to determine the sequential
            -- growth rate later
            l_curr_active_k     := l_curr_k_amount ;
            l_curr_sob_active_k := l_curr_sob_k_amount ;
          END IF;
        CLOSE l_active_k_csr ;

        l_loc := 'Opening cursor to determine the previous beginning ' ;
        l_loc := l_loc || 'active contracts.' ;
        OPEN l_active_k_csr ( l_py_summary_build_date,
             rec_l_cst_csr.customer_party_id ) ;
        FETCH l_active_k_csr INTO rec_l_active_k_csr ;
          IF l_active_k_csr%FOUND THEN
            l_prev_k_amount     := rec_l_active_k_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_l_active_k_csr.sob_contract_amount ;
            -- keep the beginning active amount to determine the sequential
            -- growth rate later
            l_prev_active_k     := l_prev_k_amount ;
            l_prev_sob_active_k := l_prev_sob_k_amount ;
          END IF ;
        CLOSE l_active_k_csr ;

        -- Determine running total for ending active contracts
        -- Add beginning active contract amount
        l_curr_end_active_k     := l_curr_k_amount ;
        l_prev_end_active_k     := l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous beginning active contracts' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_active_k_code, oki_load_sgr_pvt.g_all_scs_code,
             rec_l_cst_csr.customer_party_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous beginning active contracts' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => rec_l_cst_csr.customer_party_id
              , p_customer_name         => rec_l_cst_csr.customer_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_active_k_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , x_retcode                   => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous beginning active contracts' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_active_k
              , p_prev_base_contract_amount => l_prev_active_k
              , p_curr_sob_contract_amount  => l_curr_sob_active_k
              , p_prev_sob_contract_amount  => l_prev_sob_active_k
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current expiring ' ;
        l_loc := l_loc || 'during this quarter.'  ;
        OPEN l_expire_in_qtr_csr ( l_glpr_qtr_start_date,
             l_glpr_qtr_end_date, p_summary_build_date,
             rec_l_cst_csr.customer_party_id ) ;
        FETCH l_expire_in_qtr_csr INTO rec_l_expire_in_qtr_csr ;
          IF l_expire_in_qtr_csr%FOUND THEN
            l_curr_k_amount     := rec_l_expire_in_qtr_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_l_expire_in_qtr_csr.sob_contract_amount ;
          END IF;
        CLOSE l_expire_in_qtr_csr ;

        l_loc := 'Opening cursor to determine the previous expiring ' ;
        l_loc := l_loc || 'during this quarter.' ;
        OPEN l_expire_in_qtr_csr ( l_sqpy_glpr_qtr_start_date,
             l_sqpy_glpr_qtr_end_date, l_py_summary_build_date,
             rec_l_cst_csr.customer_party_id ) ;
        FETCH l_expire_in_qtr_csr INTO rec_l_expire_in_qtr_csr ;
          IF l_expire_in_qtr_csr%FOUND THEN
            l_prev_k_amount     := rec_l_expire_in_qtr_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_l_expire_in_qtr_csr.sob_contract_amount ;
          END IF ;
        CLOSE l_expire_in_qtr_csr ;

        -- Determine running total for ending active contracts
        -- Subtract expiring during contract amount
        l_curr_end_active_k     := l_curr_end_active_k + (l_curr_k_amount * -1) ;
        l_prev_end_active_k     := l_prev_end_active_k + (l_prev_k_amount * -1)  ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + (l_curr_sob_k_amount * -1)  ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + (l_prev_sob_k_amount * -1)  ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous expiring during quarter' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_exp_in_qtr_code, oki_load_sgr_pvt.g_all_scs_code,
             rec_l_cst_csr.customer_party_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN

            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous expiring during quarter' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => rec_l_cst_csr.customer_party_id
              , p_customer_name         => rec_l_cst_csr.customer_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_exp_in_qtr_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous expiring during quarter' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current quarter ' ;
        l_loc := l_loc || 'contracts renewed.'  ;
        OPEN l_qtr_k_rnw_csr ( l_glpr_qtr_start_date,
             p_summary_build_date, rec_l_cst_csr.customer_party_id ) ;
        FETCH l_qtr_k_rnw_csr INTO rec_l_qtr_k_rnw_csr ;
          IF l_qtr_k_rnw_csr%FOUND THEN
            l_curr_k_amount     := rec_l_qtr_k_rnw_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_l_qtr_k_rnw_csr.sob_contract_amount ;
          END IF;
        CLOSE l_qtr_k_rnw_csr ;

        l_loc := 'Opening cursor to determine the previous quarter ' ;
        l_loc := l_loc || 'contracts renewed.' ;
        OPEN l_qtr_k_rnw_csr ( l_sqpy_glpr_qtr_start_date,
             l_py_summary_build_date, rec_l_cst_csr.customer_party_id ) ;
        FETCH l_qtr_k_rnw_csr INTO rec_l_qtr_k_rnw_csr ;
          IF l_qtr_k_rnw_csr%FOUND THEN
            l_prev_k_amount     := rec_l_qtr_k_rnw_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_l_qtr_k_rnw_csr.sob_contract_amount ;
          END IF ;
        CLOSE l_qtr_k_rnw_csr ;

        -- Determine running total for ending active contracts
        -- Add quarter contracts renewed amount
        l_curr_end_active_k     := l_curr_end_active_k + l_curr_k_amount ;
        l_prev_end_active_k     := l_prev_end_active_k + l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous quarter contracts renewed' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_qtr_k_rnw_code, oki_load_sgr_pvt.g_all_scs_code,
             rec_l_cst_csr.customer_party_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous quarter contracts renewed' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => rec_l_cst_csr.customer_party_id
              , p_customer_name         => rec_l_cst_csr.customer_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_qtr_k_rnw_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous quarter contracts renewed' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current backlog' ;
        l_loc := l_loc || 'contracts renewed.'  ;
        OPEN l_bklg_k_rnw_csr ( l_glpr_qtr_start_date,
             p_summary_build_date, rec_l_cst_csr.customer_party_id ) ;
        FETCH l_bklg_k_rnw_csr INTO rec_l_bklg_k_rnw_csr ;
          IF l_bklg_k_rnw_csr%FOUND THEN
            l_curr_k_amount     := rec_l_bklg_k_rnw_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_l_bklg_k_rnw_csr.sob_contract_amount ;
          END IF;
        CLOSE l_bklg_k_rnw_csr ;

        l_loc := 'Opening cursor to determine the previous backlog' ;
        l_loc := l_loc || 'contracts renewed.'  ;
        OPEN l_bklg_k_rnw_csr ( l_sqpy_glpr_qtr_start_date,
             l_py_summary_build_date, rec_l_cst_csr.customer_party_id ) ;
        FETCH l_bklg_k_rnw_csr INTO rec_l_bklg_k_rnw_csr ;
          IF l_bklg_k_rnw_csr%FOUND THEN
            l_prev_k_amount     := rec_l_bklg_k_rnw_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_l_bklg_k_rnw_csr.sob_contract_amount ;
          END IF;
        CLOSE l_bklg_k_rnw_csr ;

        -- Determine running total for ending active contracts
        -- Add backlog contracts renewed amount
        l_curr_end_active_k     := l_curr_end_active_k + l_curr_k_amount ;
        l_prev_end_active_k     := l_prev_end_active_k + l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous backlog contracts renewed' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_bklg_k_rnw_code, oki_load_sgr_pvt.g_all_scs_code,
             rec_l_cst_csr.customer_party_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous backlog contracts renewed' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => rec_l_cst_csr.customer_party_id
              , p_customer_name         => rec_l_cst_csr.customer_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_bklg_k_rnw_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous backlog contracts renewed' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current new business.' ;
        OPEN l_new_bsn_csr ( l_glpr_qtr_start_date,
             p_summary_build_date, rec_l_cst_csr.customer_party_id ) ;
        FETCH l_new_bsn_csr INTO rec_l_new_bsn_csr ;
          IF l_new_bsn_csr%FOUND THEN
            l_curr_k_amount     := rec_l_new_bsn_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_l_new_bsn_csr.sob_contract_amount ;
          END IF;
        CLOSE l_new_bsn_csr ;

        l_loc := 'Opening cursor to determine the previous new business.' ;
        OPEN l_new_bsn_csr ( l_sqpy_glpr_qtr_start_date,
             l_py_summary_build_date, rec_l_cst_csr.customer_party_id ) ;
        FETCH l_new_bsn_csr INTO rec_l_new_bsn_csr ;
          IF l_new_bsn_csr%FOUND THEN
            l_prev_k_amount     := rec_l_new_bsn_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_l_new_bsn_csr.sob_contract_amount ;
          END IF ;
        CLOSE l_new_bsn_csr ;

        -- Determine running total for ending active contracts
        -- Add new business amount
        l_curr_end_active_k     := l_curr_end_active_k + l_curr_k_amount ;
        l_prev_end_active_k     := l_prev_end_active_k + l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous new business' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_new_bsn_code, oki_load_sgr_pvt.g_all_scs_code,
             rec_l_cst_csr.customer_party_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous new business' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => rec_l_cst_csr.customer_party_id
              , p_customer_name         => rec_l_cst_csr.customer_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_new_bsn_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous new business' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current cancelled renewals.' ;
        OPEN l_cncl_rnwl_csr( l_glpr_qtr_start_date,
             p_summary_build_date, rec_l_cst_csr.customer_party_id ) ;
        FETCH l_cncl_rnwl_csr INTO rec_l_cncl_rnwl_csr ;
          IF l_cncl_rnwl_csr%FOUND THEN
            l_curr_k_amount     := rec_l_cncl_rnwl_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_l_cncl_rnwl_csr.sob_contract_amount ;
          END IF;
        CLOSE l_cncl_rnwl_csr ;

        l_loc := 'Opening cursor to determine the previous cancelled renewals.' ;
        OPEN l_cncl_rnwl_csr( l_sqpy_glpr_qtr_start_date,
             l_py_summary_build_date, rec_l_cst_csr.customer_party_id ) ;
        FETCH l_cncl_rnwl_csr INTO rec_l_cncl_rnwl_csr ;
          IF l_cncl_rnwl_csr%FOUND THEN
            l_prev_k_amount     := rec_l_cncl_rnwl_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_l_cncl_rnwl_csr.sob_contract_amount ;
          END IF ;
        CLOSE l_cncl_rnwl_csr ;

        -- Determine running total for ending active contracts
        -- Subtract cancelled contract amount
        l_curr_end_active_k     := l_curr_end_active_k + (l_curr_k_amount * -1)  ;
        l_prev_end_active_k     := l_prev_end_active_k + (l_prev_k_amount * -1)  ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + (l_curr_sob_k_amount * -1)  ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + (l_prev_sob_k_amount * -1)  ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous cancelled contract' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_cncl_rnwl_code, oki_load_sgr_pvt.g_all_scs_code,
             rec_l_cst_csr.customer_party_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous cancelled renewals' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => rec_l_cst_csr.customer_party_id
              , p_customer_name         => rec_l_cst_csr.customer_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_cncl_rnwl_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous cancelled renewals' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Looping through all the current contracts terminated in the period.';
        << l_trmn_rnwl_csr_loop >>
        -- Loop through all the contracts terminated in the period
        FOR rec_l_trmn_rnwl_csr IN l_trmn_rnwl_csr ( l_glpr_qtr_start_date,
            p_summary_build_date, rec_l_cst_csr.customer_party_id ) LOOP
          l_curr_k_amount := l_curr_k_amount +
                            rec_l_trmn_rnwl_csr.base_contract_amount ;
          l_curr_sob_k_amount := l_curr_sob_k_amount +
                            rec_l_trmn_rnwl_csr.sob_contract_amount ;
        END LOOP l_trmn_rnwl_csr_loop ;
        l_curr_k_amount     := ROUND(l_curr_k_amount, 2) ;
        l_curr_sob_k_amount := ROUND(l_curr_sob_k_amount, 2) ;

        l_loc := 'Looping through all the previous contracts terminated in the period.';
        << l_trmn_rnwl_csr_loop >>
        -- Loop through all the contracts terminated in the period
        FOR rec_l_trmn_rnwl_csr IN l_trmn_rnwl_csr ( l_sqpy_glpr_qtr_start_date,
             l_py_summary_build_date, rec_l_cst_csr.customer_party_id ) LOOP
          l_prev_k_amount := l_prev_k_amount +
                            rec_l_trmn_rnwl_csr.base_contract_amount ;
          l_prev_sob_k_amount := l_prev_sob_k_amount +
                            rec_l_trmn_rnwl_csr.sob_contract_amount ;
        END LOOP l_trmn_rnwl_csr_loop ;
        l_prev_k_amount     := ROUND(l_prev_k_amount, 2) ;
        l_prev_sob_k_amount := ROUND(l_prev_sob_k_amount, 2) ;

        -- Determine running total for ending active contracts
        -- Subtract terminated contract amount
        l_curr_end_active_k     := l_curr_end_active_k + (l_curr_k_amount * -1) ;
        l_prev_end_active_k     := l_prev_end_active_k + (l_prev_k_amount * -1)  ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + (l_curr_sob_k_amount * -1)  ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + (l_prev_sob_k_amount * -1)  ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous terminated renewals' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_seq_trmn_k_code, oki_load_sgr_pvt.g_all_scs_code,
             rec_l_cst_csr.customer_party_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous terminated renewals' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => rec_l_cst_csr.customer_party_id
              , p_customer_name         => rec_l_cst_csr.customer_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_seq_trmn_k_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous terminated renewals' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous ending active contracts' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_end_active_k_code, oki_load_sgr_pvt.g_all_scs_code,
             rec_l_cst_csr.customer_party_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous ending active contracts' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => rec_l_cst_csr.customer_party_id
              , p_customer_name         => rec_l_cst_csr.customer_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_end_active_k_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_end_active_k
              , p_prev_base_contract_amount  => l_prev_end_active_k
              , p_curr_sob_contract_amount   => l_curr_sob_end_active_k
              , p_prev_sob_contract_amount   => l_prev_sob_end_active_k
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous ending active contracts' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_end_active_k
              , p_prev_base_contract_amount => l_prev_end_active_k
              , p_curr_sob_contract_amount  => l_curr_sob_end_active_k
              , p_prev_sob_contract_amount  => l_prev_sob_end_active_k
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        IF l_curr_active_k = 0 THEN
          l_curr_seq_grw_rate     := 0 ;
        ELSE
          l_curr_seq_grw_rate := ROUND(((l_curr_end_active_k -
                 l_curr_active_k ) / l_curr_active_k  ) * 100, 2) ;
        END IF ;

        IF l_curr_sob_active_k = 0 THEN
          l_curr_sob_seq_grw_rate := 0 ;
        ELSE
          l_curr_sob_seq_grw_rate := ROUND(((l_curr_sob_end_active_k -
                 l_curr_sob_active_k ) / l_curr_sob_active_k  ) * 100, 2) ;
        END IF ;

        IF l_prev_active_k = 0 THEN
          l_prev_seq_grw_rate := 0 ;
        ELSE
          l_prev_seq_grw_rate := ROUND(((l_prev_end_active_k -
                 l_prev_active_k ) / l_prev_active_k ) * 100, 2) ;
        END IF ;

        IF l_prev_sob_active_k = 0 THEN
          l_prev_sob_seq_grw_rate := 0 ;
        ELSE
          l_prev_sob_seq_grw_rate := ROUND(((l_prev_sob_end_active_k -
                 l_prev_sob_active_k ) / l_prev_sob_active_k ) * 100, 2) ;
        END IF ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous sequential growth rate' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_seq_grw_rate_code, oki_load_sgr_pvt.g_all_scs_code,
             rec_l_cst_csr.customer_party_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous sequential growth rate' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => rec_l_cst_csr.customer_party_id
              , p_customer_name         => rec_l_cst_csr.customer_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_seq_grw_rate_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_seq_grw_rate
              , p_prev_base_contract_amount  => l_prev_seq_grw_rate
              , p_curr_sob_contract_amount   => l_curr_sob_seq_grw_rate
              , p_prev_sob_contract_amount   => l_prev_sob_seq_grw_rate
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous sequential growth rate' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_seq_grw_rate
              , p_prev_base_contract_amount => l_prev_seq_grw_rate
              , p_curr_sob_contract_amount  => l_curr_sob_seq_grw_rate
              , p_prev_sob_contract_amount  => l_prev_sob_seq_grw_rate
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

      END LOOP g_glpr_csr_loop ;
    END LOOP l_cst_csr_loop ;

  EXCEPTION
    WHEN oki_load_sgr_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;


    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2' ;

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_SGR_PVT.CALC_SGR_DTL1');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      -- Log the location within the procedure where the error occurred
      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_LOC_IN_PROG_FAILURE');

      fnd_message.set_token(  token => 'LOCATION'
                            , value => l_loc);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END calc_sgr_dtl1 ;

--------------------------------------------------------------------------------
  -- Procedure to calcuate the contract amount for the current and previous
  -- year.

--------------------------------------------------------------------------------
  PROCEDURE calc_sgr_dtl2
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , x_retcode            OUT VARCHAR2
  ) IS

  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode          VARCHAR2(100)  := NULL ;
  l_sqlerrm          VARCHAR2(1000) := NULL ;

  -- Holds the contract amount for the current and previous
  -- beginning active contracts
  l_curr_active_k       NUMBER   := 0 ;
  l_prev_active_k       NUMBER   := 0 ;
  l_curr_sob_active_k   NUMBER   := 0 ;
  l_prev_sob_active_k   NUMBER   := 0 ;
  -- Holds the contract amount for the current and previous
  -- ending active contracts
  l_curr_end_active_k     NUMBER   := 0 ;
  l_prev_end_active_k     NUMBER   := 0 ;
  l_curr_sob_end_active_k NUMBER   := 0 ;
  l_prev_sob_end_active_k NUMBER   := 0 ;
  -- Holds the sequetial growth rate %
  l_curr_seq_grw_rate     NUMBER   := 0 ;
  l_prev_seq_grw_rate     NUMBER   := 0 ;
  l_curr_sob_seq_grw_rate NUMBER   := 0 ;
  l_prev_sob_seq_grw_rate NUMBER   := 0 ;
  -- Holds the contract amount current and previous
  -- sequential growth rate records
  l_curr_k_amount       NUMBER   := 0 ;
  l_prev_k_amount       NUMBER   := 0 ;
  l_curr_sob_k_amount   NUMBER   := 0 ;
  l_prev_sob_k_amount   NUMBER   := 0 ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(200) ;

  -- Holds the truncated start and end dates from gl_periods
  -- Holds the quarter start and end dates
  l_glpr_qtr_start_date      DATE ;
  l_glpr_qtr_end_date        DATE ;
  -- Holds the prior year summary build date
  l_py_summary_build_date    DATE ;
  -- Holds the start and end dates for the same quarter in the previous year
  l_sqpy_glpr_qtr_start_date DATE ;
  l_sqpy_glpr_qtr_end_date   DATE ;

  -- Cusor declaration

  -- Cursor that calculates the contract amount for all
  -- the active contracts
  CURSOR l_active_k_csr
  (   p_summary_build_date IN DATE
    , p_authoring_org_id   IN NUMBER
  ) IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.date_signed   <= p_summary_build_date
    AND    shd.date_approved <= p_summary_build_date
    AND    shd.start_date    <= p_summary_build_date
    AND    shd.end_date       > p_summary_build_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated  > p_summary_build_date)
    AND    shd.authoring_org_id     = p_authoring_org_id
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_l_active_k_csr l_active_k_csr%ROWTYPE ;

  -- Cursor that calculates contract amounts for all contracts
  -- expiring this quarter
  CURSOR l_expire_in_qtr_csr
  (   p_glpr_qtr_start_date  IN DATE
    , p_glpr_qtr_end_date    IN DATE
    , p_summary_build_date   IN DATE
    , p_authoring_org_id     IN NUMBER
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.date_signed   <= p_glpr_qtr_end_date
    AND    shd.date_approved <= p_glpr_qtr_end_date
    AND    shd.end_date BETWEEN p_glpr_qtr_start_date
                            AND p_glpr_qtr_end_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated  > p_summary_build_date)
    AND    shd.authoring_org_id     = p_authoring_org_id
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_l_expire_in_qtr_csr l_expire_in_qtr_csr%ROWTYPE ;

  -- Cursor that calculates contract amounts for contracts that
  -- have been renewed in this quarter
  CURSOR l_qtr_k_rnw_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
    , p_authoring_org_id    IN NUMBER
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.is_new_yn       IS NULL
    AND    shd.date_signed     IS NOT NULL
    AND    shd.date_approved   IS NOT NULL
    AND    shd.start_date BETWEEN p_glpr_qtr_start_date
                              AND p_summary_build_date
    AND    GREATEST(shd.date_signed, shd.date_approved)
              BETWEEN p_glpr_qtr_start_date
                  AND p_summary_build_date
    AND    shd.authoring_org_id = p_authoring_org_id
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_l_qtr_k_rnw_csr l_qtr_k_rnw_csr%ROWTYPE ;

  -- Contracts that were renewed in this quarter but should
  -- have been renewed before this quarter
  CURSOR l_bklg_k_rnw_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
    , p_authoring_org_id    IN NUMBER
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.is_new_yn     IS NULL
    AND    shd.date_signed   IS NOT NULL
    AND    shd.date_approved IS NOT NULL
    AND    shd.start_date     < p_glpr_qtr_start_date
    AND    GREATEST(shd.date_signed, shd.date_approved)
              BETWEEN p_glpr_qtr_start_date
                  AND p_summary_build_date
    AND    shd.authoring_org_id = p_authoring_org_id
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_l_bklg_k_rnw_csr l_bklg_k_rnw_csr%ROWTYPE ;

  -- Contracts that are active in the current quarter that are not the
  -- result of renewal or renewal consolidation
  CURSOR l_new_bsn_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
    , p_authoring_org_id    IN NUMBER
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.date_signed   <= p_summary_build_date
    AND    shd.date_approved <= p_summary_build_date
    AND    shd.is_new_yn      = 'Y'
    AND    shd.start_date BETWEEN p_glpr_qtr_start_date
                              AND p_summary_build_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated  > p_summary_build_date)
    AND    shd.authoring_org_id     = p_authoring_org_id
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_l_new_bsn_csr l_new_bsn_csr%ROWTYPE ;

  -- Renewal or renewal consolidate contracts that have been cancelled
  CURSOR l_cncl_rnwl_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
    , p_authoring_org_id    IN NUMBER
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.ste_code     = 'CANCELLED'
    AND    shd.is_new_yn    IS NULL
    AND    shd.is_latest_yn IS NULL
    AND    shd.start_date BETWEEN p_glpr_qtr_start_date
                              AND p_summary_build_date
    AND    shd.authoring_org_id = p_authoring_org_id
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_l_cncl_rnwl_csr l_cncl_rnwl_csr%ROWTYPE ;

  -- Contracts that have been termined in this quarter
  CURSOR l_trmn_rnwl_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
    , p_authoring_org_id    IN NUMBER
  )
  IS
    SELECT NVL(SUM((((shd.end_date - shd.date_terminated) /
            (shd.end_date - shd.start_date)) *
            base_contract_amount)), 0) base_contract_amount
         , NVL(SUM((((shd.end_date - shd.date_terminated) /
            (shd.end_date - shd.start_date)) *
            sob_contract_amount)), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  date_terminated BETWEEN p_glpr_qtr_start_date
                               AND p_summary_build_date
    AND    shd.authoring_org_id  = p_authoring_org_id
    AND    shd.base_contract_amount
                 BETWEEN 0 AND oki_load_sgr_pvt.g_problem_k_threshold
    ;
  rec_l_trmn_rnwl_csr l_trmn_rnwl_csr%ROWTYPE ;

  -- Cursor to retrieve the distinct organizations
  CURSOR l_org_csr IS
    SELECT   DISTINCT shd.authoring_org_id authoring_org_id
           , shd.organization_name authoring_org_name
    FROM     oki_sales_k_hdrs shd
    ;


  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    l_loc := 'Looping through valid organizations.' ;
    << l_org_csr_loop >>
    -- Loop through all the organizations to calcuate the
    -- appropriate amounts
    FOR rec_l_org_csr IN l_org_csr LOOP

      l_loc := 'Looping through valid periods.' ;
      << g_glpr_csr_loop >>
      -- Loop through all the periods
      FOR rec_g_glpr_csr IN oki_utl_pvt.g_glpr_csr(
          p_period_set_name, p_period_type, p_summary_build_date ) LOOP

        -- set the quarter and year gl_periods start and end dates
        l_glpr_qtr_start_date := trunc(rec_g_glpr_csr.quarter_start_date) ;
        l_glpr_qtr_end_date   := ADD_MONTHS(l_glpr_qtr_start_date, 3) - 1 ;

        -- Set the prior year summary build date
        l_py_summary_build_date  := ADD_MONTHS(p_summary_build_date, - 12) ;
        -- Set the year start and end dates for the previous year
        l_sqpy_glpr_qtr_start_date := ADD_MONTHS(l_glpr_qtr_start_date, -12) ;
        l_sqpy_glpr_qtr_end_date   := ADD_MONTHS(l_glpr_qtr_end_date, -12) ;

        -- Re-initialize the amounts before calculating
        l_curr_active_k         := 0 ;
        l_prev_active_k         := 0 ;
        l_curr_sob_active_k     := 0 ;
        l_prev_sob_active_k     := 0 ;
        l_curr_end_active_k     := 0 ;
        l_prev_end_active_k     := 0 ;
        l_curr_sob_end_active_k := 0 ;
        l_prev_sob_end_active_k := 0 ;
        l_curr_seq_grw_rate     := 0 ;
        l_prev_seq_grw_rate     := 0 ;
        l_curr_sob_seq_grw_rate := 0 ;
        l_prev_sob_seq_grw_rate := 0 ;
        l_curr_k_amount         := 0 ;
        l_prev_k_amount         := 0 ;
        l_curr_sob_k_amount     := 0 ;
        l_prev_sob_k_amount     := 0 ;

        l_loc := 'Opening cursor to determine the current beginning ' ;
        l_loc := l_loc || 'active contracts.' ;
        OPEN l_active_k_csr ( p_summary_build_date,
             rec_l_org_csr.authoring_org_id ) ;
        FETCH l_active_k_csr INTO rec_l_active_k_csr ;
          IF l_active_k_csr%FOUND THEN
            l_curr_k_amount     := rec_l_active_k_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_l_active_k_csr.sob_contract_amount ;
            -- keep the beginning active amount to determine the sequential
            -- growth rate later
          l_curr_active_k     := l_curr_k_amount ;
          l_curr_sob_active_k := l_curr_sob_k_amount ;
          END IF;
        CLOSE l_active_k_csr ;

        l_loc := 'Opening cursor to determine the previous beginning ' ;
        l_loc := l_loc || 'active contracts.' ;
        OPEN l_active_k_csr ( l_py_summary_build_date,
             rec_l_org_csr.authoring_org_id ) ;
       FETCH l_active_k_csr INTO rec_l_active_k_csr ;
          IF l_active_k_csr%FOUND THEN
            l_prev_k_amount     := rec_l_active_k_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_l_active_k_csr.sob_contract_amount ;
            -- keep the beginning active amount to determine the sequential
            -- growth rate later
            l_prev_active_k     := l_prev_k_amount ;
            l_prev_sob_active_k := l_prev_sob_k_amount ;
          END IF ;
        CLOSE l_active_k_csr ;

        -- Determine running total for ending active contracts
        -- Add beginning active contract amount
        l_curr_end_active_k     := l_curr_k_amount ;
        l_prev_end_active_k     := l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous beginning active contracts' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_csr.authoring_org_id,
             oki_load_sgr_pvt.g_active_k_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous beginning active contracts' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => rec_l_org_csr.authoring_org_id
              , p_authoring_org_name    => rec_l_org_csr.authoring_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_active_k_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , x_retcode                   => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous beginning active contracts' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_active_k
              , p_prev_base_contract_amount => l_prev_active_k
              , p_curr_sob_contract_amount  => l_curr_sob_active_k
              , p_prev_sob_contract_amount  => l_prev_sob_active_k
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current expiring ' ;
        l_loc := l_loc || 'during this quarter.'  ;
        OPEN l_expire_in_qtr_csr ( l_glpr_qtr_start_date,
             l_glpr_qtr_end_date, p_summary_build_date,
             rec_l_org_csr.authoring_org_id ) ;
        FETCH l_expire_in_qtr_csr INTO rec_l_expire_in_qtr_csr ;
          IF l_expire_in_qtr_csr%FOUND THEN
            l_curr_k_amount := rec_l_expire_in_qtr_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_l_expire_in_qtr_csr.sob_contract_amount ;
          END IF;
        CLOSE l_expire_in_qtr_csr ;

        l_loc := 'Opening cursor to determine the previous expiring ' ;
        l_loc := l_loc || 'during this quarter.' ;
        OPEN l_expire_in_qtr_csr ( l_sqpy_glpr_qtr_start_date,
             l_sqpy_glpr_qtr_end_date, l_py_summary_build_date,
             rec_l_org_csr.authoring_org_id ) ;
        FETCH l_expire_in_qtr_csr INTO rec_l_expire_in_qtr_csr ;
          IF l_expire_in_qtr_csr%FOUND THEN
            l_prev_k_amount := rec_l_expire_in_qtr_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_l_expire_in_qtr_csr.sob_contract_amount ;
          END IF ;
        CLOSE l_expire_in_qtr_csr ;

        -- Determine running total for ending active contracts
        -- Subtract expiring during contract amount
        l_curr_end_active_k     := l_curr_end_active_k + (l_curr_k_amount * -1) ;
        l_prev_end_active_k     := l_prev_end_active_k + (l_prev_k_amount * -1) ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + (l_curr_sob_k_amount * -1) ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + (l_prev_sob_k_amount * -1) ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous expiring during quarter' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_csr.authoring_org_id,
             oki_load_sgr_pvt.g_exp_in_qtr_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous expiring during quarter' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => rec_l_org_csr.authoring_org_id
              , p_authoring_org_name    => rec_l_org_csr.authoring_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_exp_in_qtr_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous expiring during quarter' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current quarter ' ;
        l_loc := l_loc || 'contracts renewed.'  ;
        OPEN l_qtr_k_rnw_csr ( l_glpr_qtr_start_date,
             p_summary_build_date, rec_l_org_csr.authoring_org_id ) ;
        FETCH l_qtr_k_rnw_csr INTO rec_l_qtr_k_rnw_csr ;
          IF l_qtr_k_rnw_csr%FOUND THEN
            l_curr_k_amount     := rec_l_qtr_k_rnw_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_l_qtr_k_rnw_csr.sob_contract_amount ;
          END IF;
        CLOSE l_qtr_k_rnw_csr ;

        l_loc := 'Opening cursor to determine the previous quarter ' ;
        l_loc := l_loc || 'contracts renewed.' ;
        OPEN l_qtr_k_rnw_csr ( l_sqpy_glpr_qtr_start_date,
             l_py_summary_build_date, rec_l_org_csr.authoring_org_id ) ;
        FETCH l_qtr_k_rnw_csr INTO rec_l_qtr_k_rnw_csr ;
          IF l_qtr_k_rnw_csr%FOUND THEN
            l_prev_k_amount := rec_l_qtr_k_rnw_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_l_qtr_k_rnw_csr.sob_contract_amount ;
          END IF ;
        CLOSE l_qtr_k_rnw_csr ;

        -- Determine running total for ending active contracts
        -- Add quarter contracts renewed amount
        l_curr_end_active_k     := l_curr_end_active_k + l_curr_k_amount ;
        l_prev_end_active_k     := l_prev_end_active_k + l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous quarter contracts renewed' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_csr.authoring_org_id,
             oki_load_sgr_pvt.g_qtr_k_rnw_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous quarter contracts renewed' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => rec_l_org_csr.authoring_org_id
              , p_authoring_org_name    => rec_l_org_csr.authoring_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_qtr_k_rnw_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous quarter contracts renewed' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount := 0 ;
        l_prev_k_amount := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current backlog' ;
        l_loc := l_loc || 'contracts renewed.'  ;
        OPEN l_bklg_k_rnw_csr ( l_glpr_qtr_start_date,
             p_summary_build_date, rec_l_org_csr.authoring_org_id ) ;
        FETCH l_bklg_k_rnw_csr INTO rec_l_bklg_k_rnw_csr ;
          IF l_bklg_k_rnw_csr%FOUND THEN
            l_curr_k_amount     := rec_l_bklg_k_rnw_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_l_bklg_k_rnw_csr.sob_contract_amount ;
          END IF;
        CLOSE l_bklg_k_rnw_csr ;

        l_loc := 'Opening cursor to determine the previous backlog' ;
        l_loc := l_loc || 'contracts renewed.'  ;
        OPEN l_bklg_k_rnw_csr ( l_sqpy_glpr_qtr_start_date,
             l_py_summary_build_date, rec_l_org_csr.authoring_org_id ) ;
        FETCH l_bklg_k_rnw_csr INTO rec_l_bklg_k_rnw_csr ;
          IF l_bklg_k_rnw_csr%FOUND THEN
            l_prev_k_amount     := rec_l_bklg_k_rnw_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_l_bklg_k_rnw_csr.sob_contract_amount ;
          END IF;
        CLOSE l_bklg_k_rnw_csr ;

        -- Determine running total for ending active contracts
        -- Add backlog contracts renewed amount
        l_curr_end_active_k     := l_curr_end_active_k + l_curr_k_amount ;
        l_prev_end_active_k     := l_prev_end_active_k + l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous backlog contracts renewed' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_csr.authoring_org_id,
             oki_load_sgr_pvt.g_bklg_k_rnw_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous backlog contracts renewed' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => rec_l_org_csr.authoring_org_id
              , p_authoring_org_name    => rec_l_org_csr.authoring_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_bklg_k_rnw_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous backlog contracts renewed' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current new business.' ;
        OPEN l_new_bsn_csr ( l_glpr_qtr_start_date,
             p_summary_build_date, rec_l_org_csr.authoring_org_id ) ;
        FETCH l_new_bsn_csr INTO rec_l_new_bsn_csr ;
          IF l_new_bsn_csr%FOUND THEN
            l_curr_k_amount     := rec_l_new_bsn_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_l_new_bsn_csr.sob_contract_amount ;
          END IF;
        CLOSE l_new_bsn_csr ;

        l_loc := 'Opening cursor to determine the previous new business.' ;
        OPEN l_new_bsn_csr ( l_sqpy_glpr_qtr_start_date,
             l_py_summary_build_date, rec_l_org_csr.authoring_org_id ) ;
        FETCH l_new_bsn_csr INTO rec_l_new_bsn_csr ;
          IF l_new_bsn_csr%FOUND THEN
            l_prev_k_amount     := rec_l_new_bsn_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_l_new_bsn_csr.sob_contract_amount ;
          END IF ;
        CLOSE l_new_bsn_csr ;

        -- Determine running total for ending active contracts
        -- Add new business amount
        l_curr_end_active_k     := l_curr_end_active_k + l_curr_k_amount ;
        l_prev_end_active_k     := l_prev_end_active_k + l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous new business' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_csr.authoring_org_id,
             oki_load_sgr_pvt.g_new_bsn_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous new business' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => rec_l_org_csr.authoring_org_id
              , p_authoring_org_name    => rec_l_org_csr.authoring_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_new_bsn_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous new business' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

      -- Re-initialize the amounts before calculating
      l_curr_k_amount     := 0 ;
      l_prev_k_amount     := 0 ;
      l_curr_sob_k_amount := 0 ;
      l_prev_sob_k_amount := 0 ;

      l_loc := 'Opening cursor to determine the current cancelled renewals.' ;
      OPEN l_cncl_rnwl_csr( l_glpr_qtr_start_date,
           p_summary_build_date, rec_l_org_csr.authoring_org_id ) ;
      FETCH l_cncl_rnwl_csr INTO rec_l_cncl_rnwl_csr ;
        IF l_cncl_rnwl_csr%FOUND THEN
          l_curr_k_amount     := rec_l_cncl_rnwl_csr.base_contract_amount ;
          l_curr_sob_k_amount := rec_l_cncl_rnwl_csr.sob_contract_amount ;
        END IF;
      CLOSE l_cncl_rnwl_csr ;

      l_loc := 'Opening cursor to determine the previous cancelled renewals.' ;
      OPEN l_cncl_rnwl_csr( l_sqpy_glpr_qtr_start_date,
           l_py_summary_build_date, rec_l_org_csr.authoring_org_id ) ;
      FETCH l_cncl_rnwl_csr INTO rec_l_cncl_rnwl_csr ;
        IF l_cncl_rnwl_csr%FOUND THEN
          l_prev_k_amount     := rec_l_cncl_rnwl_csr.base_contract_amount ;
          l_prev_sob_k_amount := rec_l_cncl_rnwl_csr.sob_contract_amount ;
        END IF ;
      CLOSE l_cncl_rnwl_csr ;

      -- Determine running total for ending active contracts
      -- Subtract cancelled contract amount
      l_curr_end_active_k     := l_curr_end_active_k + (l_curr_k_amount * -1) ;
      l_prev_end_active_k     := l_prev_end_active_k + (l_prev_k_amount * -1) ;
      l_curr_sob_end_active_k := l_curr_sob_end_active_k + (l_curr_sob_k_amount * -1) ;
      l_prev_sob_end_active_k := l_prev_sob_end_active_k + (l_prev_sob_k_amount * -1) ;

      l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
      l_loc := l_loc || ' -- current / previous cancelled contract' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
           rec_g_glpr_csr.period_name, rec_l_org_csr.authoring_org_id,
           oki_load_sgr_pvt.g_cncl_rnwl_code, oki_load_sgr_pvt.g_all_scs_code,
           oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
           p_summary_build_date, rec_g_glpr_csr.period_type ) ;
      FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
        IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
          l_loc := 'Insert the new record.' ;
          l_loc := l_loc || ' -- current / previous cancelled renewals' ;
          -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => rec_l_org_csr.authoring_org_id
              , p_authoring_org_name    => rec_l_org_csr.authoring_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_cncl_rnwl_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous cancelled renewals' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Looping through all the current contracts terminated in the period.';
        << l_trmn_rnwl_csr_loop >>
        -- Loop through all the contracts terminated in the period
        FOR rec_l_trmn_rnwl_csr IN l_trmn_rnwl_csr ( l_glpr_qtr_start_date,
            p_summary_build_date, rec_l_org_csr.authoring_org_id ) LOOP
          l_curr_k_amount := l_curr_k_amount +
                              rec_l_trmn_rnwl_csr.base_contract_amount ;
          l_curr_sob_k_amount := l_curr_sob_k_amount +
                              rec_l_trmn_rnwl_csr.sob_contract_amount ;
        END LOOP l_trmn_rnwl_csr_loop ;
        l_curr_k_amount     := ROUND(l_curr_k_amount, 2) ;
        l_curr_sob_k_amount := ROUND(l_curr_sob_k_amount, 2) ;

        l_loc := 'Looping through all the previous contracts terminated in the period.';
        << l_trmn_rnwl_csr_loop >>
        -- Loop through all the contracts terminated in the period
        FOR rec_l_trmn_rnwl_csr IN l_trmn_rnwl_csr ( l_sqpy_glpr_qtr_start_date,
            l_py_summary_build_date, rec_l_org_csr.authoring_org_id ) LOOP
          l_prev_k_amount := l_prev_k_amount +
                              rec_l_trmn_rnwl_csr.base_contract_amount ;
          l_prev_sob_k_amount := l_prev_sob_k_amount +
                              rec_l_trmn_rnwl_csr.sob_contract_amount ;
        END LOOP l_trmn_rnwl_csr_loop ;
        l_prev_k_amount     := ROUND(l_prev_k_amount, 2) ;
        l_prev_sob_k_amount := ROUND(l_prev_sob_k_amount, 2) ;

        -- Determine running total for ending active contracts
        -- Subtract terminated contract amount
        l_curr_end_active_k     := l_curr_end_active_k + (l_curr_k_amount * -1) ;
        l_prev_end_active_k     := l_prev_end_active_k + (l_prev_k_amount * -1) ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + (l_curr_sob_k_amount * -1) ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + (l_prev_sob_k_amount * -1) ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous terminated renewals' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_csr.authoring_org_id,
             oki_load_sgr_pvt.g_seq_trmn_k_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous terminated renewals' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => rec_l_org_csr.authoring_org_id
              , p_authoring_org_name    => rec_l_org_csr.authoring_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_seq_trmn_k_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous terminated renewals' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous ending active contracts' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_csr.authoring_org_id,
             oki_load_sgr_pvt.g_end_active_k_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous ending active contracts' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => rec_l_org_csr.authoring_org_id
              , p_authoring_org_name    => rec_l_org_csr.authoring_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_end_active_k_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_end_active_k
              , p_prev_base_contract_amount  => l_prev_end_active_k
              , p_curr_sob_contract_amount   => l_curr_sob_end_active_k
              , p_prev_sob_contract_amount   => l_prev_sob_end_active_k
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous ending active contracts' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_end_active_k
              , p_prev_base_contract_amount => l_prev_end_active_k
              , p_curr_sob_contract_amount  => l_curr_sob_end_active_k
              , p_prev_sob_contract_amount  => l_prev_sob_end_active_k
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        -- If the denomiator is zero, then set the sequential growth rate to zero
        l_loc := 'Setting the sequential growth rate value.' ;
        IF l_curr_active_k = 0 THEN
          l_curr_seq_grw_rate := 0 ;
        ELSE
          l_curr_seq_grw_rate := ROUND(((l_curr_end_active_k -
                 l_curr_active_k ) / l_curr_active_k  ) * 100, 2) ;
        END IF ;

        IF l_curr_sob_active_k = 0 THEN
          l_curr_sob_seq_grw_rate := 0 ;
        ELSE
          l_curr_sob_seq_grw_rate := ROUND(((l_curr_sob_end_active_k -
                 l_curr_sob_active_k ) / l_curr_sob_active_k  ) * 100, 2) ;
        END IF ;

        IF l_prev_active_k = 0 THEN
          l_prev_seq_grw_rate := 0 ;
        ELSE
          l_prev_seq_grw_rate := ROUND(((l_prev_end_active_k -
                     l_prev_active_k ) / l_prev_active_k ) * 100, 2) ;
        END IF ;

        IF l_prev_sob_active_k = 0 THEN
          l_prev_sob_seq_grw_rate := 0 ;
        ELSE
          l_prev_sob_seq_grw_rate := ROUND(((l_prev_sob_end_active_k -
                 l_prev_sob_active_k ) / l_prev_sob_active_k ) * 100, 2) ;
        END IF ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous sequential growth rate' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_csr.authoring_org_id,
             oki_load_sgr_pvt.g_seq_grw_rate_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous sequential growth rate' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => rec_l_org_csr.authoring_org_id
              , p_authoring_org_name    => rec_l_org_csr.authoring_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_seq_grw_rate_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_seq_grw_rate
              , p_prev_base_contract_amount  => l_prev_seq_grw_rate
              , p_curr_sob_contract_amount   => l_curr_sob_seq_grw_rate
              , p_prev_sob_contract_amount   => l_prev_sob_seq_grw_rate
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous sequential growth rate' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_seq_grw_rate
              , p_prev_base_contract_amount => l_prev_seq_grw_rate
              , p_curr_sob_contract_amount  => l_curr_sob_seq_grw_rate
              , p_prev_sob_contract_amount  => l_prev_sob_seq_grw_rate
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

      END LOOP g_glpr_csr_loop ;
    END LOOP l_org_csr_loop ;

  EXCEPTION
    WHEN oki_load_sgr_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;


    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2' ;

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_SGR_PVT.CALC_SGR_DTL2');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      -- Log the location within the procedure where the error occurred
      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_LOC_IN_PROG_FAILURE');

      fnd_message.set_token(  token => 'LOCATION'
                            , value => l_loc);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '|| l_sqlerrm );

  END calc_sgr_dtl2 ;

--------------------------------------------------------------------------------
  -- Procedure to calcuate the contract amount for the current and previous
  -- quarter / year.

--------------------------------------------------------------------------------
  PROCEDURE calc_sgr_dtl3
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , p_ending_period_type IN  vARCHAR2
    , x_retcode            OUT VARCHAR2
  ) IS

  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode          VARCHAR2(100)  := NULL ;
  l_sqlerrm          VARCHAR2(1000) := NULL ;

  -- Holds the contract amount for the current and previous
  -- beginning active contracts
  l_curr_active_k       NUMBER   := 0 ;
  l_prev_active_k       NUMBER   := 0 ;
  l_curr_sob_active_k   NUMBER   := 0 ;
  l_prev_sob_active_k   NUMBER   := 0 ;
  -- Holds the contract amount for the current and previous
  -- ending active contracts
  l_curr_end_active_k     NUMBER   := 0 ;
  l_prev_end_active_k     NUMBER   := 0 ;
  l_curr_sob_end_active_k NUMBER   := 0 ;
  l_prev_sob_end_active_k NUMBER   := 0 ;
  -- Holds the sequetial growth rate %
  l_curr_seq_grw_rate     NUMBER   := 0 ;
  l_prev_seq_grw_rate     NUMBER   := 0 ;
  l_curr_sob_seq_grw_rate NUMBER   := 0 ;
  l_prev_sob_seq_grw_rate NUMBER   := 0 ;
  -- Holds the contract amount current and previous
  -- sequential growth rate records
  l_curr_k_amount       NUMBER   := 0 ;
  l_prev_k_amount       NUMBER   := 0 ;
  l_curr_sob_k_amount   NUMBER   := 0 ;
  l_prev_sob_k_amount   NUMBER   := 0 ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(200) ;

  -- Holds the truncated start and end dates from gl_periods
  -- Holds the quarter start and end dates
  l_glpr_qtr_start_date       DATE ;
  l_glpr_qtr_end_date         DATE ;
  -- Holds the year start and end dates
  l_glpr_year_start_date      DATE ;
  l_glpr_year_end_date        DATE ;
  l_period_start_date         DATE ;
  l_period_end_date           DATE ;
  -- Holds the prior year summary build date
  l_py_summary_build_date     DATE ;
  -- Holds the start and end dates for the same quarter in the previous year
  l_sqpy_glpr_qtr_start_date  DATE ;
  l_sqpy_glpr_qtr_end_date    DATE ;
  -- Holds the start and end dates for the previous year
  l_py_glpr_period_start_date DATE ;
  l_py_glpr_period_end_date   DATE ;
  l_py_period_start_date      DATE ;
  l_py_period_end_date        DATE ;

  -- If the period is the build summary date, then calculate
  -- the period amounts
  l_period_end VARCHAR2(30) := 'NOT_PERIOD_END' ;

  BEGIN
    -- initialize return code to success
    l_retcode := '0';

    << g_glpr_csr_loop >>
    -- Loop through all the periods
    FOR rec_g_glpr_csr IN oki_utl_pvt.g_glpr_csr(
        p_period_set_name, p_period_type, p_summary_build_date ) LOOP

      -- set the quarter and year gl_periods start and end dates
      l_glpr_qtr_start_date  := trunc(rec_g_glpr_csr.quarter_start_date) ;
      l_glpr_qtr_end_date    := ADD_MONTHS(l_glpr_qtr_start_date, 3) - 1 ;
      l_glpr_year_start_date := TRUNC(rec_g_glpr_csr.year_start_date) ;
      l_glpr_year_end_date   := ADD_MONTHS(TRUNC(rec_g_glpr_csr.year_start_date), 12) - 1 ;

      -- Set the prior year summary build date
      l_py_summary_build_date    := ADD_MONTHS(p_summary_build_date, - 12) ;
      -- Set the quarter start and end dates for the same quarter
      -- in the previous  year
      l_sqpy_glpr_qtr_start_date := ADD_MONTHS(l_glpr_qtr_start_date, -12) ;
      l_sqpy_glpr_qtr_end_date   := ADD_MONTHS(l_glpr_qtr_end_date, -12) ;

      -- Set the year start and end dates for the previous year
      l_py_glpr_period_start_date := ADD_MONTHS(l_glpr_year_start_date, -12) ;
      l_py_glpr_period_end_date   := ADD_MONTHS(l_glpr_year_end_date, -12) ;

      IF p_ending_period_type = 'Quarter' THEN
        IF p_summary_build_date = l_glpr_qtr_end_date THEN
          -- The summary build date is the quarter end date
          -- Set up the current and previous start and end dates
          -- for the quarter
          l_period_start_date    := l_glpr_qtr_start_date ;
          l_period_end_date      := l_glpr_qtr_end_date ;
          l_py_period_start_date := l_sqpy_glpr_qtr_start_date ;
          l_py_period_end_date   := l_sqpy_glpr_qtr_end_date ;
          l_period_end           := 'PERIOD_END' ;
        END IF ;
      ELSIF p_ending_period_type = 'Year' THEN
        IF p_summary_build_date = l_glpr_year_end_date THEN
          -- The summary build date is the year end date
          -- Set up the current and previous start and end dates
          -- for the year
          l_period_start_date    := l_glpr_year_start_date ;
          l_period_end_date      := l_glpr_year_end_date   ;
          l_period_end           := 'PERIOD_END' ;
          l_py_period_start_date := l_py_glpr_period_start_date ;
          l_py_period_end_date   := l_py_glpr_period_end_date ;
        END IF ;
      END IF ;

      IF l_period_end = 'PERIOD_END' THEN
        l_period_end := 'NOT_PERIOD_END' ;

        -- Re-initialize the amounts before calculating
        l_curr_active_k         := 0 ;
        l_prev_active_k         := 0 ;
        l_curr_sob_active_k     := 0 ;
        l_prev_sob_active_k     := 0 ;
        l_curr_end_active_k     := 0 ;
        l_prev_end_active_k     := 0 ;
        l_curr_sob_end_active_k := 0 ;
        l_prev_sob_end_active_k := 0 ;
        l_curr_seq_grw_rate     := 0 ;
        l_prev_seq_grw_rate     := 0 ;
        l_curr_sob_seq_grw_rate := 0 ;
        l_prev_sob_seq_grw_rate := 0 ;
        l_curr_k_amount         := 0 ;
        l_prev_k_amount         := 0 ;
        l_curr_sob_k_amount     := 0 ;
        l_prev_sob_k_amount     := 0 ;


        l_loc := 'Opening cursor to determine the current beginning ' ;
        l_loc := l_loc || 'active contracts.' ;
        OPEN oki_load_sgr_pvt.g_active_k_csr ( p_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_active_k_csr INTO rec_g_active_k_csr ;
          IF oki_load_sgr_pvt.g_active_k_csr%FOUND THEN
            l_curr_k_amount := rec_g_active_k_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_g_active_k_csr.sob_contract_amount ;
            -- keep the beginning active amount to determine the sequential
            -- growth rate later
            l_curr_active_k     := l_curr_k_amount ;
            l_curr_sob_active_k := l_curr_sob_k_amount ;
          END IF;
        CLOSE oki_load_sgr_pvt.g_active_k_csr ;

        l_loc := 'Opening cursor to determine the previous beginning ' ;
        l_loc := l_loc || 'active contracts.' ;
        OPEN oki_load_sgr_pvt.g_active_k_csr ( l_py_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_active_k_csr INTO rec_g_active_k_csr ;
          IF oki_load_sgr_pvt.g_active_k_csr%FOUND THEN
            l_prev_k_amount := rec_g_active_k_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_g_active_k_csr.sob_contract_amount ;
            -- keep the beginning active amount to determine the sequential
            -- growth rate later
            l_prev_active_k     := l_prev_k_amount ;
            l_prev_sob_active_k := l_prev_sob_k_amount ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_active_k_csr ;

        -- Determine running total for ending active contracts
        -- Add beginning active contract amount
        l_curr_end_active_k     := l_curr_k_amount ;
        l_prev_end_active_k     := l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous beginning active contracts' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_active_k_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, p_ending_period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous beginning active contracts' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => p_ending_period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_active_k_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , x_retcode                   => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous beginning active contracts' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_active_k
              , p_prev_base_contract_amount => l_prev_active_k
              , p_curr_sob_contract_amount  => l_curr_sob_active_k
              , p_prev_sob_contract_amount  => l_prev_sob_active_k
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount := 0 ;
        l_prev_k_amount := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current expiring ' ;
        l_loc := l_loc || 'during this quarter.'  ;

        OPEN oki_load_sgr_pvt.g_expire_in_qtr_csr ( l_period_start_date,
             l_period_end_date, p_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_expire_in_qtr_csr INTO rec_g_expire_in_qtr_csr ;
          IF oki_load_sgr_pvt.g_expire_in_qtr_csr%FOUND THEN
            l_curr_k_amount     := rec_g_expire_in_qtr_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_g_expire_in_qtr_csr.sob_contract_amount ;
          END IF;
        CLOSE oki_load_sgr_pvt.g_expire_in_qtr_csr ;

        l_loc := 'Opening cursor to determine the previous expiring ' ;
        l_loc := l_loc || 'during this quarter.' ;
        OPEN oki_load_sgr_pvt.g_expire_in_qtr_csr ( l_py_period_start_date,
             l_py_period_end_date, l_py_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_expire_in_qtr_csr INTO rec_g_expire_in_qtr_csr ;
          IF oki_load_sgr_pvt.g_expire_in_qtr_csr%FOUND THEN
            l_prev_k_amount     := rec_g_expire_in_qtr_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_g_expire_in_qtr_csr.sob_contract_amount ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_expire_in_qtr_csr ;

        -- Determine running total for ending active contracts
        -- Subtract expiring during contract amount
        l_curr_end_active_k     := l_curr_end_active_k + (l_curr_k_amount * -1);
        l_prev_end_active_k     := l_prev_end_active_k + (l_prev_k_amount * -1);
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + (l_curr_sob_k_amount * -1) ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + (l_prev_sob_k_amount * -1) ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous expiring during quarter' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_exp_in_qtr_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, p_ending_period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous expiring during quarter' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => p_ending_period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_exp_in_qtr_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous expiring during quarter' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current quarter ' ;
        l_loc := l_loc || 'contracts renewed.'  ;
        OPEN oki_load_sgr_pvt.g_qtr_k_rnw_csr ( l_period_start_date,
             p_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_qtr_k_rnw_csr INTO rec_g_qtr_k_rnw_csr ;
          IF oki_load_sgr_pvt.g_qtr_k_rnw_csr%FOUND THEN
            l_curr_k_amount     := rec_g_qtr_k_rnw_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_g_qtr_k_rnw_csr.sob_contract_amount ;
          END IF;
        CLOSE oki_load_sgr_pvt.g_qtr_k_rnw_csr ;

        l_loc := 'Opening cursor to determine the previous quarter ' ;
        l_loc := l_loc || 'contracts renewed.' ;
        OPEN oki_load_sgr_pvt.g_qtr_k_rnw_csr ( l_py_period_start_date,
             l_py_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_qtr_k_rnw_csr INTO rec_g_qtr_k_rnw_csr ;
          IF oki_load_sgr_pvt.g_qtr_k_rnw_csr%FOUND THEN
            l_prev_k_amount := rec_g_qtr_k_rnw_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_g_qtr_k_rnw_csr.sob_contract_amount ;
        END IF ;
        CLOSE oki_load_sgr_pvt.g_qtr_k_rnw_csr ;

        -- Determine running total for ending active contracts
        -- Add quarter contracts renewed amount
        l_curr_end_active_k     := l_curr_end_active_k + l_curr_k_amount ;
        l_prev_end_active_k     := l_prev_end_active_k + l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous quarter contracts renewed' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_qtr_k_rnw_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, p_ending_period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous quarter contracts renewed' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => p_ending_period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_qtr_k_rnw_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous quarter contracts renewed' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current backlog' ;
        l_loc := l_loc || 'contracts renewed.'  ;
        OPEN oki_load_sgr_pvt.g_bklg_k_rnw_csr ( l_period_start_date,
             p_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_bklg_k_rnw_csr INTO rec_g_bklg_k_rnw_csr ;
          IF oki_load_sgr_pvt.g_bklg_k_rnw_csr%FOUND THEN
            l_curr_k_amount     := rec_g_bklg_k_rnw_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_g_bklg_k_rnw_csr.sob_contract_amount ;
          END IF;
        CLOSE oki_load_sgr_pvt.g_bklg_k_rnw_csr ;

        l_loc := 'Opening cursor to determine the previous backlog' ;
        l_loc := l_loc || 'contracts renewed.'  ;
        OPEN oki_load_sgr_pvt.g_bklg_k_rnw_csr ( l_py_period_start_date,
             l_py_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_bklg_k_rnw_csr INTO rec_g_bklg_k_rnw_csr ;
          IF oki_load_sgr_pvt.g_bklg_k_rnw_csr%FOUND THEN
            l_prev_k_amount := rec_g_bklg_k_rnw_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_g_bklg_k_rnw_csr.sob_contract_amount ;
          END IF;
        CLOSE oki_load_sgr_pvt.g_bklg_k_rnw_csr ;

        -- Determine running total for ending active contracts
        -- Add backlog contracts renewed amount
        l_curr_end_active_k := l_curr_end_active_k + l_curr_k_amount ;
        l_prev_end_active_k := l_prev_end_active_k + l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous backlog contracts renewed' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_bklg_k_rnw_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, p_ending_period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous backlog contracts renewed' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => p_ending_period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_bklg_k_rnw_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous backlog contracts renewed' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount := 0 ;
        l_prev_k_amount := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current new business.' ;
        OPEN oki_load_sgr_pvt.g_new_bsn_csr ( l_period_start_date,
             p_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_new_bsn_csr INTO rec_g_new_bsn_csr ;
          IF oki_load_sgr_pvt.g_new_bsn_csr%FOUND THEN
            l_curr_k_amount     := rec_g_new_bsn_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_g_new_bsn_csr.sob_contract_amount ;
          END IF;
        CLOSE oki_load_sgr_pvt.g_new_bsn_csr ;

        l_loc := 'Opening cursor to determine the previous new business.' ;
        OPEN oki_load_sgr_pvt.g_new_bsn_csr ( l_py_period_start_date,
             l_py_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_new_bsn_csr INTO rec_g_new_bsn_csr ;
        IF oki_load_sgr_pvt.g_new_bsn_csr%FOUND THEN
          l_prev_k_amount     := rec_g_new_bsn_csr.base_contract_amount ;
          l_prev_sob_k_amount := rec_g_new_bsn_csr.sob_contract_amount ;
        END IF ;
        CLOSE oki_load_sgr_pvt.g_new_bsn_csr ;

        -- Determine running total for ending active contracts
        -- Add new business amount
        l_curr_end_active_k     := l_curr_end_active_k + l_curr_k_amount ;
        l_prev_end_active_k     := l_prev_end_active_k + l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous new business' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_new_bsn_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, p_ending_period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous new business' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => p_ending_period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_new_bsn_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous new business' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current cancelled renewals.' ;
        OPEN oki_load_sgr_pvt.g_cncl_rnwl_csr( l_period_start_date,
             p_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_cncl_rnwl_csr INTO rec_g_cncl_rnwl_csr ;
          IF oki_load_sgr_pvt.g_cncl_rnwl_csr%FOUND THEN
            l_curr_k_amount := rec_g_cncl_rnwl_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_g_cncl_rnwl_csr.sob_contract_amount ;
          END IF;
        CLOSE oki_load_sgr_pvt.g_cncl_rnwl_csr ;

        l_loc := 'Opening cursor to determine the previous cancelled renewals.' ;
        OPEN oki_load_sgr_pvt.g_cncl_rnwl_csr( l_py_period_start_date,
             l_py_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_cncl_rnwl_csr INTO rec_g_cncl_rnwl_csr ;
          IF oki_load_sgr_pvt.g_cncl_rnwl_csr%FOUND THEN
            l_prev_k_amount := rec_g_cncl_rnwl_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_g_cncl_rnwl_csr.sob_contract_amount ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_cncl_rnwl_csr ;

        -- Determine running total for ending active contracts
        -- Subtract cancelled contract amount
        l_curr_end_active_k     := l_curr_end_active_k + (l_curr_k_amount * -1) ;
        l_prev_end_active_k     := l_prev_end_active_k + (l_prev_k_amount * -1) ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + (l_curr_sob_k_amount * -1) ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + (l_prev_sob_k_amount * -1) ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous cancelled contract' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_cncl_rnwl_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, p_ending_period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous cancelled renewals' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => p_ending_period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_cncl_rnwl_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous cancelled renewals' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Looping through all the current contracts terminated in the period.';
        << g_trmn_rnwl_csr_loop >>
        -- Loop through all the contracts terminated in the period
        FOR rec_g_trmn_rnwl_csr IN oki_load_sgr_pvt.g_trmn_rnwl_csr(
            l_period_start_date, p_summary_build_date ) LOOP
          l_curr_k_amount := l_curr_k_amount +
                              rec_g_trmn_rnwl_csr.base_contract_amount ;
          l_curr_sob_k_amount := l_curr_sob_k_amount +
                            rec_g_trmn_rnwl_csr.sob_contract_amount ;
        END LOOP g_trmn_rnwl_csr_loop ;
        l_curr_k_amount := ROUND(l_curr_k_amount, 2) ;
        l_curr_sob_k_amount := ROUND(l_curr_sob_k_amount, 2) ;

        l_loc := 'Looping through all the previous contracts terminated in the period.';
        << g_trmn_rnwl_csr_loop >>
        -- Loop through all the contracts terminated in the period
        FOR rec_g_trmn_rnwl_csr IN oki_load_sgr_pvt.g_trmn_rnwl_csr(
            l_py_period_start_date, l_py_summary_build_date ) LOOP
          l_prev_k_amount := l_prev_k_amount +
                               rec_g_trmn_rnwl_csr.base_contract_amount ;
          l_prev_sob_k_amount := l_prev_sob_k_amount +
                                 rec_g_trmn_rnwl_csr.sob_contract_amount ;
        END LOOP g_trmn_rnwl_csr_loop ;
        l_prev_k_amount := ROUND(l_prev_k_amount, 2) ;
        l_prev_sob_k_amount := ROUND(l_prev_sob_k_amount, 2) ;

        -- Determine running total for ending active contracts
        -- Subtract terminated contract amount
        l_curr_end_active_k     := l_curr_end_active_k + (l_curr_k_amount * -1) ;
        l_prev_end_active_k     := l_prev_end_active_k + (l_prev_k_amount  * -1) ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + (l_curr_sob_k_amount * -1) ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + (l_prev_sob_k_amount * -1) ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous terminated renewals' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_seq_trmn_k_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, p_ending_period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous terminated renewals' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => p_ending_period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_seq_trmn_k_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous terminated renewals' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount := 0 ;
        l_prev_k_amount := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous ending active contracts' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_end_active_k_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, p_ending_period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous ending active contracts' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => p_ending_period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_end_active_k_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_end_active_k
              , p_prev_base_contract_amount  => l_prev_end_active_k
              , p_curr_sob_contract_amount   => l_curr_sob_end_active_k
              , p_prev_sob_contract_amount   => l_prev_sob_end_active_k
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous ending active contracts' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_end_active_k
              , p_prev_base_contract_amount => l_prev_end_active_k
              , p_curr_sob_contract_amount  => l_curr_sob_end_active_k
              , p_prev_sob_contract_amount  => l_prev_sob_end_active_k
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        -- If the denominator is zero, then set the sequential growth rate to zero
        l_loc := 'Setting the sequential growth rate value.' ;
        IF l_curr_active_k = 0 THEN
          l_curr_seq_grw_rate := 0 ;
        ELSE
          l_curr_seq_grw_rate := ROUND(((l_curr_end_active_k -
                 l_curr_active_k ) / l_curr_active_k  ) * 100, 2) ;
        END IF ;

        IF l_curr_sob_active_k = 0 THEN
          l_curr_sob_seq_grw_rate := 0 ;
        ELSE
          l_curr_sob_seq_grw_rate := ROUND(((l_curr_sob_end_active_k -
                 l_curr_sob_active_k ) / l_curr_sob_active_k  ) * 100, 2) ;
        END IF ;

        IF l_prev_active_k = 0 THEN
          l_prev_seq_grw_rate := 0 ;
        ELSE
          l_prev_seq_grw_rate := ROUND(((l_prev_end_active_k -
                 l_prev_active_k ) / l_prev_active_k ) * 100, 2) ;
        END IF ;

        IF l_prev_sob_active_k = 0 THEN
          l_prev_sob_seq_grw_rate := 0 ;
        ELSE
          l_prev_sob_seq_grw_rate := ROUND(((l_prev_sob_end_active_k -
                 l_prev_sob_active_k ) / l_prev_sob_active_k ) * 100, 2) ;
        END IF ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous sequentail growth rate' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_seq_grw_rate_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, p_ending_period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous sequentail growth rate' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => p_ending_period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_seq_grw_rate_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_seq_grw_rate
              , p_prev_base_contract_amount  => l_prev_seq_grw_rate
              , p_curr_sob_contract_amount   => l_curr_sob_seq_grw_rate
              , p_prev_sob_contract_amount   => l_prev_sob_seq_grw_rate
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous sequentail growth rate' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_seq_grw_rate
              , p_prev_base_contract_amount => l_prev_seq_grw_rate
              , p_curr_sob_contract_amount  => l_curr_sob_seq_grw_rate
              , p_prev_sob_contract_amount  => l_prev_sob_seq_grw_rate
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;
      END IF ;

    END LOOP g_glpr_csr_loop ;

  EXCEPTION
    WHEN oki_load_sgr_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;


    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2' ;

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_SGR_PVT.CALC_SGR_DTL3');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      -- Log the location within the procedure where the error occurred
      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_LOC_IN_PROG_FAILURE');

      fnd_message.set_token(  token => 'LOCATION'
                            , value => l_loc);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '|| l_sqlerrm );
  END calc_sgr_dtl3 ;
--------------------------------------------------------------------------------
  -- Procedure to calcuate the contract amount for the current and previous
  -- year.

--------------------------------------------------------------------------------
  PROCEDURE calc_sgr_sum
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , x_retcode            OUT VARCHAR2
  ) IS

  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode          VARCHAR2(100)  := NULL ;
  l_sqlerrm          VARCHAR2(1000) := NULL ;

  -- Holds the contract amount for the current and previous
  -- beginning active contracts
  l_curr_active_k         NUMBER   := 0 ;
  l_prev_active_k         NUMBER   := 0 ;
  l_curr_sob_active_k     NUMBER   := 0 ;
  l_prev_sob_active_k     NUMBER   := 0 ;
  -- Holds the contract amount for the current and previous
  -- ending active contracts
  l_curr_end_active_k     NUMBER   := 0 ;
  l_prev_end_active_k     NUMBER   := 0 ;
  l_curr_sob_end_active_k NUMBER   := 0 ;
  l_prev_sob_end_active_k NUMBER   := 0 ;
  -- Holds the sequetial growth rate %
  l_curr_seq_grw_rate     NUMBER   := 0 ;
  l_prev_seq_grw_rate     NUMBER   := 0 ;
  l_curr_sob_seq_grw_rate NUMBER   := 0 ;
  l_prev_sob_seq_grw_rate NUMBER   := 0 ;
  -- Holds the contract amount current and previous
  -- sequential growth rate records
  l_curr_k_amount       NUMBER   := 0 ;
  l_prev_k_amount       NUMBER   := 0 ;
  l_curr_sob_k_amount   NUMBER   := 0 ;
  l_prev_sob_k_amount   NUMBER   := 0 ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(200) ;

  -- Holds the truncated start and end dates from gl_periods
  -- Holds the quarter start and end dates
  l_glpr_qtr_start_date      DATE ;
  l_glpr_qtr_end_date        DATE ;
  -- Holds the prior year summary build date
  l_py_summary_build_date    DATE ;
  -- Holds the start and end dates for the same quarter in the previous year
  l_sqpy_glpr_qtr_start_date DATE ;
  l_sqpy_glpr_qtr_end_date   DATE ;
/*
  -- Cusor declaration

  -- Cursor that calculates the contract amount for all
  -- the active contracts
  CURSOR l_active_k_csr
  (   p_summary_build_date IN DATE
  ) IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.date_signed   <= p_summary_build_date
    AND    shd.date_approved <= p_summary_build_date
    AND    shd.start_date    <= p_summary_build_date
    AND    shd.end_date       > p_summary_build_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated  > p_summary_build_date)
    ;
  rec_l_active_k_csr l_active_k_csr%ROWTYPE ;

  -- Cursor that calculates contract amounts for all contracts
  -- expiring this quarter
  CURSOR l_expire_in_qtr_csr
  (   p_glpr_qtr_start_date  IN DATE
    , p_glpr_qtr_end_date    IN DATE
    , p_summary_build_date   IN DATE
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.date_signed   <= p_glpr_qtr_end_date
    AND    shd.date_approved <= p_glpr_qtr_end_date
    AND    shd.end_date BETWEEN p_glpr_qtr_start_date
                            AND p_glpr_qtr_end_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated  > p_summary_build_date)
    ;
  rec_l_expire_in_qtr_csr l_expire_in_qtr_csr%ROWTYPE ;

  -- Cursor that calculates contract amounts for contracts that
  -- have been renewed in this quarter
  CURSOR l_qtr_k_rnw_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.is_new_yn            IS NULL
    AND    shd.date_signed   IS NOT NULL
    AND    shd.date_approved IS NOT NULL
    AND    shd.start_date BETWEEN p_glpr_qtr_start_date
                                     AND p_summary_build_date
    AND    GREATEST(shd.date_signed, shd.date_approved)
              BETWEEN p_glpr_qtr_start_date
                  AND p_summary_build_date
    ;
  rec_l_qtr_k_rnw_csr l_qtr_k_rnw_csr%ROWTYPE ;

  -- Contracts that were renewed in this quarter but should
  -- have been renewed before this quarter
  CURSOR l_bklg_k_rnw_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.is_new_yn     IS NULL
    AND    shd.date_signed   IS NOT NULL
    AND    shd.date_approved IS NOT NULL
    AND    shd.start_date     < p_glpr_qtr_start_date
    AND    GREATEST(shd.date_signed, shd.date_approved)
              BETWEEN p_glpr_qtr_start_date
                  AND p_summary_build_date
    ;
  rec_l_bklg_k_rnw_csr l_bklg_k_rnw_csr%ROWTYPE ;

  -- Contracts that are active in the current quarter that are not the
  -- result of renewal or renewal consolidation
  CURSOR l_new_bsn_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.date_signed   <= p_summary_build_date
    AND    shd.date_approved <= p_summary_build_date
    AND    shd.is_new_yn      = 'Y'
    AND    shd.start_date  BETWEEN p_glpr_qtr_start_date
                               AND p_summary_build_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated  > p_summary_build_date)
    ;
  rec_l_new_bsn_csr l_new_bsn_csr%ROWTYPE ;

  -- Renewal or renewal consolidate contracts that have been cancelled
  CURSOR l_cncl_rnwl_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
  )
  IS
    SELECT NVL(SUM(base_contract_amount), 0) base_contract_amount
         , NVL(SUM(sob_contract_amount), 0) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.ste_code     = 'CANCELLED'
    AND    shd.is_new_yn    IS NULL
    AND    shd.is_latest_yn IS NULL
    AND    shd.start_date BETWEEN p_glpr_qtr_start_date
                              AND p_summary_build_date
    ;
  rec_l_cncl_rnwl_csr l_cncl_rnwl_csr%ROWTYPE ;

  -- Contracts that have been termined in this quarter
  CURSOR l_trmn_rnwl_csr
  (   p_glpr_qtr_start_date IN DATE
    , p_summary_build_date  IN DATE
  )
  IS
    SELECT  (((shd.end_date - shd.date_terminated) /
            (shd.end_date - shd.start_date)) *
            base_contract_amount) base_contract_amount
          , (((shd.end_date - shd.date_terminated) /
            (shd.end_date - shd.start_date)) *
            sob_contract_amount) sob_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  date_terminated BETWEEN p_glpr_qtr_start_date
                               AND p_summary_build_date
    ;
  rec_l_trmn_rnwl_csr l_trmn_rnwl_csr%ROWTYPE ;
*/

  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    l_loc := 'Looping through valid organizations.' ;
    -- Loop through all the organizations to calcuate the
    -- appropriate amounts

    l_loc := 'Looping through valid periods.' ;
    << g_glpr_csr_loop >>
    -- Loop through all the periods
    FOR rec_g_glpr_csr IN oki_utl_pvt.g_glpr_csr(
        p_period_set_name, p_period_type, p_summary_build_date ) LOOP

      -- set the quarter and year gl_periods start and end dates
      l_glpr_qtr_start_date := trunc(rec_g_glpr_csr.quarter_start_date) ;
      l_glpr_qtr_end_date   := ADD_MONTHS(l_glpr_qtr_start_date, 3) - 1 ;

      -- Set the prior year summary build date
      l_py_summary_build_date  := ADD_MONTHS(p_summary_build_date, - 12) ;
      -- Set the quarter start and end dates for the same quarter
      -- in the previous  year
      l_sqpy_glpr_qtr_start_date := ADD_MONTHS(l_glpr_qtr_start_date, -12) ;
      l_sqpy_glpr_qtr_end_date   := ADD_MONTHS(l_glpr_qtr_end_date, -12) ;

      -- Re-initialize the amounts before calculating
      l_curr_active_k         := 0 ;
      l_prev_active_k         := 0 ;
      l_curr_sob_active_k     := 0 ;
      l_prev_sob_active_k     := 0 ;
      l_curr_end_active_k     := 0 ;
      l_prev_end_active_k     := 0 ;
      l_curr_sob_end_active_k := 0 ;
      l_prev_sob_end_active_k := 0 ;
      l_curr_seq_grw_rate     := 0 ;
      l_prev_seq_grw_rate     := 0 ;
      l_curr_sob_seq_grw_rate := 0 ;
      l_prev_sob_seq_grw_rate := 0 ;
      l_curr_k_amount         := 0 ;
      l_prev_k_amount         := 0 ;
      l_curr_sob_k_amount     := 0 ;
      l_prev_sob_k_amount     := 0 ;

      l_loc := 'Opening cursor to determine the current beginning ' ;
      l_loc := l_loc || 'active contracts.' ;
      OPEN oki_load_sgr_pvt.g_active_k_csr ( p_summary_build_date ) ;
      FETCH oki_load_sgr_pvt.g_active_k_csr INTO rec_g_active_k_csr ;
        IF oki_load_sgr_pvt.g_active_k_csr%FOUND THEN
          l_curr_k_amount     := rec_g_active_k_csr.base_contract_amount ;
          l_curr_sob_k_amount := rec_g_active_k_csr.sob_contract_amount ;
          -- keep the beginning active amount to determine the sequential
          -- growth rate later
          l_curr_active_k     := l_curr_k_amount ;
          l_curr_sob_active_k := l_curr_sob_k_amount ;
        END IF;
      CLOSE oki_load_sgr_pvt.g_active_k_csr ;


      l_loc := 'Opening cursor to determine the previous beginning ' ;
      l_loc := l_loc || 'active contracts.' ;
      OPEN oki_load_sgr_pvt.g_active_k_csr ( l_py_summary_build_date ) ;
      FETCH oki_load_sgr_pvt.g_active_k_csr INTO rec_g_active_k_csr ;
        IF oki_load_sgr_pvt.g_active_k_csr%FOUND THEN
          l_prev_k_amount     := rec_g_active_k_csr.base_contract_amount ;
          l_prev_sob_k_amount := rec_g_active_k_csr.sob_contract_amount ;
          -- keep the beginning active amount to determine the sequential
          -- growth rate later
          l_prev_active_k     := l_prev_k_amount ;
          l_prev_sob_active_k := l_prev_sob_k_amount ;
        END IF ;
      CLOSE oki_load_sgr_pvt.g_active_k_csr ;

      -- Determine running total for ending active contracts
      -- Add beginning active contract amount
      l_curr_end_active_k     := l_curr_k_amount ;
      l_prev_end_active_k     := l_prev_k_amount ;
      l_curr_sob_end_active_k := l_curr_sob_k_amount ;
      l_prev_sob_end_active_k := l_prev_sob_k_amount ;

      l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
      l_loc := l_loc || ' -- current / previous beginning active contracts' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
           rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
           oki_load_sgr_pvt.g_active_k_code, oki_load_sgr_pvt.g_all_scs_code,
           oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
           p_summary_build_date, rec_g_glpr_csr.period_type ) ;
      FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
        IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
          l_loc := 'Insert the new record.' ;
          l_loc := l_loc || ' -- current / previous beginning active contracts' ;
          -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_active_k_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , x_retcode                   => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous beginning active contracts' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_active_k
              , p_prev_base_contract_amount => l_prev_active_k
              , p_curr_sob_contract_amount  => l_curr_sob_active_k
              , p_prev_sob_contract_amount  => l_prev_sob_active_k
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current expiring ' ;
        l_loc := l_loc || 'during this quarter.'  ;
        OPEN oki_load_sgr_pvt.g_expire_in_qtr_csr ( l_glpr_qtr_start_date,
             l_glpr_qtr_end_date, p_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_expire_in_qtr_csr INTO rec_g_expire_in_qtr_csr ;
          IF oki_load_sgr_pvt.g_expire_in_qtr_csr%FOUND THEN
            l_curr_k_amount     := rec_g_expire_in_qtr_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_g_expire_in_qtr_csr.sob_contract_amount ;
          END IF;
        CLOSE oki_load_sgr_pvt.g_expire_in_qtr_csr ;

        l_loc := 'Opening cursor to determine the previous expiring ' ;
        l_loc := l_loc || 'during this quarter.' ;
        OPEN oki_load_sgr_pvt.g_expire_in_qtr_csr ( l_sqpy_glpr_qtr_start_date,
             l_sqpy_glpr_qtr_end_date, l_py_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_expire_in_qtr_csr INTO rec_g_expire_in_qtr_csr ;
          IF oki_load_sgr_pvt.g_expire_in_qtr_csr%FOUND THEN
            l_prev_k_amount     := rec_g_expire_in_qtr_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_g_expire_in_qtr_csr.sob_contract_amount ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_expire_in_qtr_csr ;

        -- Determine running total for ending active contracts
        -- Subtract expiring during contract amount
        l_curr_end_active_k     := l_curr_end_active_k + (l_curr_k_amount * -1) ;
        l_prev_end_active_k     := l_prev_end_active_k + (l_prev_k_amount * -1) ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + (l_curr_sob_k_amount * -1) ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + (l_prev_sob_k_amount * -1) ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous expiring during quarter' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_exp_in_qtr_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN

            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous expiring during quarter' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_exp_in_qtr_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous expiring during quarter' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount := 0 ;
        l_prev_k_amount := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current quarter ' ;
        l_loc := l_loc || 'contracts renewed.'  ;
        OPEN oki_load_sgr_pvt.g_qtr_k_rnw_csr ( l_glpr_qtr_start_date,
             p_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_qtr_k_rnw_csr INTO rec_g_qtr_k_rnw_csr ;
          IF oki_load_sgr_pvt.g_qtr_k_rnw_csr%FOUND THEN
            l_curr_k_amount     := rec_g_qtr_k_rnw_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_g_qtr_k_rnw_csr.sob_contract_amount ;
          END IF;
        CLOSE oki_load_sgr_pvt.g_qtr_k_rnw_csr ;

        l_loc := 'Opening cursor to determine the previous quarter ' ;
        l_loc := l_loc || 'contracts renewed.' ;
        OPEN oki_load_sgr_pvt.g_qtr_k_rnw_csr ( l_sqpy_glpr_qtr_start_date,
             l_py_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_qtr_k_rnw_csr INTO rec_g_qtr_k_rnw_csr ;
          IF oki_load_sgr_pvt.g_qtr_k_rnw_csr%FOUND THEN
            l_prev_k_amount     := rec_g_qtr_k_rnw_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_g_qtr_k_rnw_csr.sob_contract_amount ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_qtr_k_rnw_csr ;

        -- Determine running total for ending active contracts
        -- Add quarter contracts renewed amount
        l_curr_end_active_k     := l_curr_end_active_k + l_curr_k_amount ;
        l_prev_end_active_k     := l_prev_end_active_k + l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous quarter contracts renewed' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_qtr_k_rnw_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous quarter contracts renewed' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_qtr_k_rnw_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous quarter contracts renewed' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current backlog' ;
        l_loc := l_loc || 'contracts renewed.'  ;
        OPEN oki_load_sgr_pvt.g_bklg_k_rnw_csr ( l_glpr_qtr_start_date,
             p_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_bklg_k_rnw_csr INTO rec_g_bklg_k_rnw_csr ;
          IF oki_load_sgr_pvt.g_bklg_k_rnw_csr%FOUND THEN
            l_curr_k_amount     := rec_g_bklg_k_rnw_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_g_bklg_k_rnw_csr.sob_contract_amount ;
          END IF;
        CLOSE oki_load_sgr_pvt.g_bklg_k_rnw_csr ;

        l_loc := 'Opening cursor to determine the previous backlog' ;
        l_loc := l_loc || 'contracts renewed.'  ;
        OPEN oki_load_sgr_pvt.g_bklg_k_rnw_csr ( l_sqpy_glpr_qtr_start_date,
             l_py_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_bklg_k_rnw_csr INTO rec_g_bklg_k_rnw_csr ;
          IF oki_load_sgr_pvt.g_bklg_k_rnw_csr%FOUND THEN
            l_prev_k_amount     := rec_g_bklg_k_rnw_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_g_bklg_k_rnw_csr.sob_contract_amount ;
          END IF;
        CLOSE oki_load_sgr_pvt.g_bklg_k_rnw_csr ;

        -- Determine running total for ending active contracts
        -- Add backlog contracts renewed amount
        l_curr_end_active_k     := l_curr_end_active_k + l_curr_k_amount ;
        l_prev_end_active_k     := l_prev_end_active_k + l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous backlog contracts renewed' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_bklg_k_rnw_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous backlog contracts renewed' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_bklg_k_rnw_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous backlog contracts renewed' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current new business.' ;
        OPEN oki_load_sgr_pvt.g_new_bsn_csr ( l_glpr_qtr_start_date,
             p_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_new_bsn_csr INTO rec_g_new_bsn_csr ;
          IF oki_load_sgr_pvt.g_new_bsn_csr%FOUND THEN
            l_curr_k_amount := rec_g_new_bsn_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_g_new_bsn_csr.sob_contract_amount ;
          END IF;
        CLOSE oki_load_sgr_pvt.g_new_bsn_csr ;

        l_loc := 'Opening cursor to determine the previous new business.' ;
        OPEN oki_load_sgr_pvt.g_new_bsn_csr ( l_sqpy_glpr_qtr_start_date,
             l_py_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_new_bsn_csr INTO rec_g_new_bsn_csr ;
          IF oki_load_sgr_pvt.g_new_bsn_csr%FOUND THEN
            l_prev_k_amount     := rec_g_new_bsn_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_g_new_bsn_csr.sob_contract_amount ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_new_bsn_csr ;

        -- Determine running total for ending active contracts
        -- Add new business amount
        l_curr_end_active_k     := l_curr_end_active_k + l_curr_k_amount ;
        l_prev_end_active_k     := l_prev_end_active_k + l_prev_k_amount ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + l_curr_sob_k_amount ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + l_prev_sob_k_amount ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous new business' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_new_bsn_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous new business' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_new_bsn_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous new business' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine the current cancelled renewals.' ;
        OPEN oki_load_sgr_pvt.g_cncl_rnwl_csr( l_glpr_qtr_start_date,
             p_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_cncl_rnwl_csr INTO rec_g_cncl_rnwl_csr ;
          IF oki_load_sgr_pvt.g_cncl_rnwl_csr%FOUND THEN
            l_curr_k_amount     := rec_g_cncl_rnwl_csr.base_contract_amount ;
            l_curr_sob_k_amount := rec_g_cncl_rnwl_csr.sob_contract_amount ;
          END IF;
        CLOSE oki_load_sgr_pvt.g_cncl_rnwl_csr ;

        l_loc := 'Opening cursor to determine the previous cancelled renewals.' ;
        OPEN oki_load_sgr_pvt.g_cncl_rnwl_csr( l_sqpy_glpr_qtr_start_date,
             l_py_summary_build_date ) ;
        FETCH oki_load_sgr_pvt.g_cncl_rnwl_csr INTO rec_g_cncl_rnwl_csr ;
          IF oki_load_sgr_pvt.g_cncl_rnwl_csr%FOUND THEN
            l_prev_k_amount     := rec_g_cncl_rnwl_csr.base_contract_amount ;
            l_prev_sob_k_amount := rec_g_cncl_rnwl_csr.sob_contract_amount ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_cncl_rnwl_csr ;

        -- Determine running total for ending active contracts
        -- Subtract cancelled contract amount
        l_curr_end_active_k     := l_curr_end_active_k + (l_curr_k_amount * -1) ;
        l_prev_end_active_k     := l_prev_end_active_k + (l_prev_k_amount * -1) ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + (l_curr_sob_k_amount * -1) ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + (l_prev_sob_k_amount * -1) ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous cancelled contract' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_cncl_rnwl_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous cancelled renewals' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_cncl_rnwl_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous cancelled renewals' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount := 0 ;
        l_prev_k_amount := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Looping through all the current contracts terminated in the period.';
        << l_trmn_rnwl_csr_loop >>
        -- Loop through all the contracts terminated in the period
        FOR rec_g_trmn_rnwl_csr IN oki_load_sgr_pvt.g_trmn_rnwl_csr(
            l_glpr_qtr_start_date, p_summary_build_date ) LOOP
          l_curr_k_amount := l_curr_k_amount +
                             rec_g_trmn_rnwl_csr.base_contract_amount ;
          l_curr_sob_k_amount := l_curr_sob_k_amount +
                            rec_g_trmn_rnwl_csr.sob_contract_amount ;
        END LOOP l_trmn_rnwl_csr_loop ;
        l_curr_k_amount     := ROUND(l_curr_k_amount, 2) ;
        l_curr_sob_k_amount := ROUND(l_curr_sob_k_amount, 2) ;

        l_loc := 'Looping through all the previous contracts terminated in the period.';
        << l_trmn_rnwl_csr_loop >>
        -- Loop through all the contracts terminated in the period
        FOR rec_g_trmn_rnwl_csr IN oki_load_sgr_pvt.g_trmn_rnwl_csr(
            l_sqpy_glpr_qtr_start_date, l_py_summary_build_date ) LOOP
          l_prev_k_amount := l_prev_k_amount +
                              rec_g_trmn_rnwl_csr.base_contract_amount ;
          l_prev_sob_k_amount := l_prev_sob_k_amount +
                            rec_g_trmn_rnwl_csr.sob_contract_amount ;
        END LOOP l_trmn_rnwl_csr_loop ;
        l_prev_k_amount := ROUND(l_prev_k_amount, 2) ;
        l_prev_sob_k_amount := ROUND(l_prev_sob_k_amount, 2) ;

        -- Determine running total for ending active contracts
        -- Subtract terminated contract amount
        l_curr_end_active_k     := l_curr_end_active_k + (l_curr_k_amount * -1);
        l_prev_end_active_k     := l_prev_end_active_k + (l_prev_k_amount * -1) ;
        l_curr_sob_end_active_k := l_curr_sob_end_active_k + (l_curr_sob_k_amount * -1) ;
        l_prev_sob_end_active_k := l_prev_sob_end_active_k + (l_prev_sob_k_amount * -1) ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous terminated renewals' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_seq_trmn_k_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous terminated renewals' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_seq_trmn_k_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_k_amount
              , p_prev_base_contract_amount  => l_prev_k_amount
              , p_curr_sob_contract_amount   => l_curr_sob_k_amount
              , p_prev_sob_contract_amount   => l_prev_sob_k_amount
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous terminated renewals' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_k_amount
              , p_prev_base_contract_amount => l_prev_k_amount
              , p_curr_sob_contract_amount  => l_curr_sob_k_amount
              , p_prev_sob_contract_amount  => l_prev_sob_k_amount
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous ending active contracts' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_end_active_k_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous ending active contracts' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_end_active_k_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_end_active_k
              , p_prev_base_contract_amount  => l_prev_end_active_k
              , p_curr_sob_contract_amount   => l_curr_sob_end_active_k
              , p_prev_sob_contract_amount   => l_prev_sob_end_active_k
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous ending active contracts' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_end_active_k
              , p_prev_base_contract_amount => l_prev_end_active_k
              , p_curr_sob_contract_amount  => l_curr_sob_end_active_k
              , p_prev_sob_contract_amount  => l_prev_sob_end_active_k
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;


        -- Re-initialize the amounts before calculating
        l_curr_k_amount     := 0 ;
        l_prev_k_amount     := 0 ;
        l_curr_sob_k_amount := 0 ;
        l_prev_sob_k_amount := 0 ;

        -- If the denominator is zero, then set the sequential growth rate to zero
        l_loc := 'Setting the sequential growth rate value.' ;
        IF l_curr_active_k = 0 THEN
          l_curr_seq_grw_rate     := 0 ;
        ELSE
          l_curr_seq_grw_rate := ROUND(((l_curr_end_active_k -
                 l_curr_active_k ) / l_curr_active_k  ) * 100, 2) ;
        END IF ;

        IF l_curr_sob_active_k = 0 THEN
          l_curr_sob_seq_grw_rate := 0 ;
        ELSE
          l_curr_sob_seq_grw_rate := ROUND(((l_curr_sob_end_active_k -
                 l_curr_sob_active_k ) / l_curr_sob_active_k  ) * 100, 2) ;
        END IF ;

        IF l_prev_active_k = 0 THEN
          l_prev_seq_grw_rate     := 0 ;
        ELSE
          l_prev_seq_grw_rate := ROUND(((l_prev_end_active_k -
                 l_prev_active_k ) / l_prev_active_k ) * 100, 2) ;
        END IF ;

        IF l_prev_sob_active_k = 0 THEN
          l_prev_sob_seq_grw_rate := 0 ;
        ELSE
          l_prev_sob_seq_grw_rate := ROUND(((l_prev_sob_end_active_k -
                 l_prev_sob_active_k ) / l_prev_sob_active_k ) * 100, 2) ;
        END IF ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        l_loc := l_loc || ' -- current / previous sequentail growth rate' ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_sgr_pvt.g_sgr_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_sgr_pvt.g_all_org_id,
             oki_load_sgr_pvt.g_seq_grw_rate_code, oki_load_sgr_pvt.g_all_scs_code,
             oki_load_sgr_pvt.g_all_cst_id, oki_load_sgr_pvt.g_all_pct_code,
             p_summary_build_date, rec_g_glpr_csr.period_type ) ;
        FETCH oki_load_sgr_pvt.g_sgr_csr INTO rec_g_sgr_csr ;
          IF oki_load_sgr_pvt.g_sgr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            l_loc := l_loc || ' -- current / previous sequentail growth rate' ;
            -- Insert the current period data for the period
            oki_load_sgr_pvt.ins_seq_grw_rate (
                p_period_set_name       => rec_g_glpr_csr.period_set_name
              , p_period_name           => rec_g_glpr_csr.period_name
              , p_period_type           => rec_g_glpr_csr.period_type
              , p_summary_build_date    => p_summary_build_date
              , p_authoring_org_id      => oki_load_sgr_pvt.g_all_org_id
              , p_authoring_org_name    => oki_load_sgr_pvt.g_all_org_name
              , p_customer_party_id     => oki_load_sgr_pvt.g_all_cst_id
              , p_customer_name         => oki_load_sgr_pvt.g_all_cst_name
              , p_seq_grw_rate_code     => oki_load_sgr_pvt.g_seq_grw_rate_code
              , p_scs_code              => oki_load_sgr_pvt.g_all_scs_code
              , p_product_category_code => oki_load_sgr_pvt.g_all_pct_code
              , p_curr_base_contract_amount  => l_curr_seq_grw_rate
              , p_prev_base_contract_amount  => l_prev_seq_grw_rate
              , p_curr_sob_contract_amount   => l_curr_sob_seq_grw_rate
              , p_prev_sob_contract_amount   => l_prev_sob_seq_grw_rate
              , x_retcode                    => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            l_loc := l_loc || ' -- current / previous sequentail growth rate' ;
            -- Record already exists, so perform an update
            oki_load_sgr_pvt.upd_seq_grw_rate (
                p_curr_base_contract_amount => l_curr_seq_grw_rate
              , p_prev_base_contract_amount => l_prev_seq_grw_rate
              , p_curr_sob_contract_amount  => l_curr_sob_seq_grw_rate
              , p_prev_sob_contract_amount  => l_prev_sob_seq_grw_rate
              , p_sgr_rowid                 => rec_g_sgr_csr.rowid
              , x_retcode                   => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_sgr_pvt.g_sgr_csr ;

    END LOOP g_glpr_csr_loop ;

  EXCEPTION
    WHEN oki_load_sgr_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;


    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2' ;

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_SGR_PVT.CALC_SGR_SUM');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      -- Log the location within the procedure where the error occurred
      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_LOC_IN_PROG_FAILURE');

      fnd_message.set_token(  token => 'LOCATION'
                            , value => l_loc);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '|| l_sqlerrm );
  END calc_sgr_sum ;

--------------------------------------------------------------------------------
  -- Procedure to create all the seqeuantial growth rate records.  If an
  -- error is encountered in this procedure or subsequent procedures then
  -- rollback all changes.  Once the table is loaded and the data is committed
  -- the load is considered successful even if update of the oki_refreshs
  -- table failed.
--------------------------------------------------------------------------------
  PROCEDURE crt_seq_grw
  (   p_period_set_name          IN  VARCHAR2
    , p_period_type              IN  VARCHAR2
    , p_start_summary_build_date IN  DATE
    , p_end_summary_build_date   IN  DATE
    , x_errbuf                   OUT VARCHAR2
    , x_retcode                  OUT VARCHAR2
  ) IS


  -- Local exception declaration

  -- Exception to immediately exit the procedure
  l_excp_upd_refresh   EXCEPTION ;


  -- Constant declaration

  -- Name of the table for which data is being inserted
  l_table_name  CONSTANT VARCHAR2(30) := 'OKI_SEQ_GROWTH_RATE' ;


  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  l_upper_bound NUMBER := 0 ;
  l_summary_build_date DATE := NULL ;

  l_ending_period_type VARCHAR2(15) := NULL ;


  BEGIN

    SAVEPOINT oki_load_sgr_pvt_crt_seq_grw ;

    -- initialize return code to success
    l_retcode := '0' ;
    x_retcode := '0' ;

    l_upper_bound := TRUNC(p_end_summary_build_date) -
                           TRUNC(p_start_summary_build_date) + 1 ;

    l_summary_build_date := TRUNC(p_start_summary_build_date) ;

    FOR i IN 1..l_upper_bound  LOOP

      -- Procedure to calculate the amounts for each customer
      oki_load_sgr_pvt.calc_sgr_dtl1 (
          p_period_set_name    => p_period_set_name
        , p_period_type        => p_period_type
        , p_summary_build_date => l_summary_build_date
        , x_retcode            => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
      END IF ;

      -- Procedure to calculate the amounts for each organization
      oki_load_sgr_pvt.calc_sgr_dtl2 (
          p_period_set_name    => p_period_set_name
        , p_period_type        => p_period_type
        , p_summary_build_date => l_summary_build_date
        , x_retcode            => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
      END IF ;

/*
   l_ending_period_type := 'Quarter' ;
    -- Procedure to calculate the amounts across organizations
    oki_load_sgr_pvt.calc_sgr_dtl3 (
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => l_summary_build_date
      , p_ending_period_type => l_ending_period_type
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
    END IF ;

   l_ending_period_type := 'Year' ;
    -- Procedure to calculate the amounts across organizations
    oki_load_sgr_pvt.calc_sgr_dtl3 (
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => l_summary_build_date
      , p_ending_period_type => l_ending_period_type
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
    END IF ;
*/
      -- Procedure to calculate the amounts amounts across organizations,
      -- subclasses
      oki_load_sgr_pvt.calc_sgr_sum (
          p_period_set_name    => p_period_set_name
        , p_period_type        => p_period_type
        , p_summary_build_date => l_summary_build_date
        , x_retcode            => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_load_sgr_pvt.g_excp_exit_immediate ;
      END IF ;

      l_summary_build_date := l_summary_build_date + 1 ;

    END LOOP ;

    COMMIT;

    SAVEPOINT oki_load_sgr_pvt_upd_refresh ;


    -- Table loaded successfully.  Log message IN concurrent manager
    -- log indicating successful load.
    fnd_message.set_name(  application => 'OKI'
                         , name        => 'OKI_TABLE_LOAD_SUCCESS');

    fnd_message.set_token(  token => 'TABLE_NAME'
                          , value => l_table_name );

    fnd_file.put_line(  which => fnd_file.log
                      , buff  => fnd_message.get);

    oki_refresh_pvt.update_oki_refresh( l_table_name, l_retcode ) ;

    IF l_retcode in ('1', '2') THEN
      -- Update to OKI_REFRESHS failed, exit immediately.
      RAISE l_excp_upd_refresh ;
    END IF ;

    COMMIT ;

  EXCEPTION
    WHEN l_excp_upd_refresh THEN
      -- Do not log error; It has already been logged by the refreshs
      -- program
      x_retcode := l_retcode ;

      ROLLBACK to oki_load_sgr_pvt_upd_refresh ;

    WHEN oki_load_sgr_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

      ROLLBACK TO oki_load_sgr_pvt_crt_seq_grw ;

    WHEN OTHERS THEN

      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2' ;

      -- ROLLBACK all transactions
      ROLLBACK TO oki_load_sgr_pvt_crt_seq_grw ;


      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_SGR_PVT.CRT_SEQ_GRW');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );

  END crt_seq_grw ;


BEGIN
  -- Initialize the global variables used TO log this job run
  -- FROM concurrent manager
  g_request_id             :=  fnd_global.conc_request_id ;
  g_program_application_id :=  fnd_global.prog_appl_id ;
  g_program_id             :=  fnd_global.conc_program_id ;
  g_program_update_date    :=  SYSDATE ;

END oki_load_sgr_pvt ;

/
