--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_RBS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_RBS_PVT" as
/* $Header: OKIRRBSB.pls 115.24 2003/11/24 08:25:10 kbajaj ship $ */

--------------------------------------------------------------------------------
-- Modification History
-- 25-Aug-2001  mezra        Changed program to reflect the addition of
--                           new columns: authoring_org_id,
--                           authoring_org_name, and subclass code.
-- 10-Sep-2001  mezra        Added column value, All Categories, for summary
--                           level of all scs_code; All Organizations, for
--                           summary level of all organizations.
-- 18-Sep-2001  mezra        Moved rbs_csr from local cursor to global
--                           cursor since it is used by all the calc
--                           procedures.
-- 25-Sep-2001  mezra        Change usd_ columns to base_.
-- 22-Oct-2001  mezra        Changed All Categories value to -1.
-- 24-Oct-2001  mezra        Removed trunc on date columns to increase
--                           performance since index will be used.
-- 26-NOV-2002  rpotnuru     NOCOPY Changes
-- 19-Dec-2002  brrao        UTF-8 Changes to Org Name
--
-- 29-Oct-2003  axraghav      Modified calc_rbs_dtl1,calc_rbs_dtl2,calc_rbs_sum
--                            to join to oki_cov_prd_lines and also to populate
--                            null values for organization_name
--------------------------------------------------------------------------------

  -- Global exception declaration

  -- Generic exception to immediately exit the procedure
  g_excp_exit_immediate   EXCEPTION ;


  -- Global constant delcaration

  -- Constants for the "All" organization and subclass record
  g_all_org_id   CONSTANT NUMBER       := -1 ;
  g_all_org_name CONSTANT VARCHAR2(240) := 'All Organizations' ;
  g_all_scs_code CONSTANT VARCHAR2(30) := '-1' ;


  -- Global cursor declaration

  -- Cursor to retrieve the rowid for the selected record
  -- If a rowid is retrieved, then the record will be updated,
  -- else the record will be inserted.
  CURSOR g_rbs_csr
  (   p_period_set_name  IN VARCHAR2
    , p_period_name      IN VARCHAR2
    , p_authoring_org_id IN NUMBER
    , p_status_code      IN VARCHAR2
    , p_scs_code         IN VARCHAr2
  ) IS
    SELECT rowid
    FROM   oki_renew_by_statuses rbs
    WHERE  rbs.period_set_name  = p_period_set_name
    AND    rbs.period_name      = p_period_name
    AND    rbs.authoring_org_id = p_authoring_org_id
    AND    rbs.status_code      = p_status_code
    AND    rbs.scs_code         = p_scs_code
    ;

--------------------------------------------------------------------------------
  -- Procedure to insert records into the oki_renew_by_statuses table.

--------------------------------------------------------------------------------
  PROCEDURE ins_rnwl_by_stat
  (   p_period_name         IN  VARCHAR2
    , p_period_set_name     IN  VARCHAR2
    , p_period_type         IN  VARCHAR2
    , p_authoring_org_id    IN  NUMBER
    , p_authoring_org_name  IN  VARCHAR2
    , p_status_code         IN  VARCHAR2
    , p_scs_code            IN  VARCHAR2
    , p_base_amount         IN  NUMBER
    , p_contract_count      IN  NUMBER
    , x_retcode             OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  l_sequence  NUMBER := NULL ;

  -- Cursor declaration
  CURSOR l_seq_num IS
    SELECT oki_renew_by_statuses_s1.nextval seq
    FROM dual ;
  rec_l_seq_num l_seq_num%ROWTYPE ;

  BEGIN

    OPEN l_seq_num ;
    FETCH l_seq_num INTO rec_l_seq_num ;
      -- unable to generate sequence number, exit immediately
      IF l_seq_num%NOTFOUND THEN
        RAISE g_excp_exit_immediate ;
      END IF ;
      l_sequence := rec_l_seq_num.seq ;
    CLOSE l_seq_num ;

    -- initialize return code to success
    x_retcode := '0';

    INSERT INTO oki_renew_by_statuses
    (        id
           , period_set_name
           , period_name
           , period_type
           , authoring_org_id
           , authoring_org_name
           , status_code
           , scs_code
           , base_amount
           , contract_count
           , request_id
           , program_application_id
           , program_id
           , program_update_date )
    VALUES ( l_sequence
           , p_period_set_name
           , p_period_name
           , p_period_type
           , p_authoring_org_id
           , p_authoring_org_name
           , p_status_code
           , p_scs_code
           , p_base_amount
           , p_contract_count
           , oki_load_rbs_pvt.g_request_id
           , oki_load_rbs_pvt.g_program_application_id
           , oki_load_rbs_pvt.g_program_id
           , oki_load_rbs_pvt.g_program_update_date ) ;


  EXCEPTION
    WHEN oki_load_rbs_pvt.g_excp_exit_immediate THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_TABLE_LOAD_FAILURE') ;

      fnd_message.set_token(  token => 'TABLE_NAME'
                            , value => 'OKI_RENEW_BY_STATUSES' ) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm ) ;

    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_TABLE_LOAD_FAILURE') ;

      fnd_message.set_token(  token => 'TABLE_NAME'
                            , value => 'OKI_RENEW_BY_STATUSES' ) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm ) ;
  END ins_rnwl_by_stat ;


--------------------------------------------------------------------------------
  -- Procedure to update records in the oki_renew_by_statuses table.

--------------------------------------------------------------------------------
  PROCEDURE upd_rnwl_by_stat
  (   p_base_amount        IN  NUMBER
    , p_contract_count     IN  NUMBER
    , p_rowid              IN  ROWID
    , x_retcode            OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;


  BEGIN

    -- initialize return code to success
    x_retcode := '0';

    UPDATE oki_renew_by_statuses SET
        base_amount             = p_base_amount
      , contract_count          = p_contract_count
      , request_id              = oki_load_rbs_pvt.g_request_id
      , program_application_id  = oki_load_rbs_pvt.g_program_application_id
      , program_id              = oki_load_rbs_pvt.g_program_id
      , program_update_date     = oki_load_rbs_pvt.g_program_update_date
    WHERE ROWID = p_rowid ;


  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_RBS_PVT.UPD_RNWL_BY_STAT');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END upd_rnwl_by_stat ;


--------------------------------------------------------------------------------
  -- Procedure to calculate the counts and amounts of expired, WIP,
  -- signed, and forecasted contracts.
  -- Calculates the counts and amounts by each dimension:
  --   period set name
  --   period type
  --   period name
  --   status
  --   subclass
  --   organization
  --
--------------------------------------------------------------------------------
  PROCEDURE calc_rbs_dtl1
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , x_retcode            OUT NOCOPY VARCHAR2
  ) IS


  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode          VARCHAR2(100)  := NULL ;
  l_sqlerrm          VARCHAR2(1000) := NULL ;

  -- Holds the calculated contract amount and counts
  l_contract_count       NUMBER ;
  l_base_contract_amount NUMBER ;

  -- holds the rowid of the record in the oki_renew_by_statuses table
  l_rbs_rowid            ROWID := null ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;

  -- Cursor declaration

  -- Cursor to get all the organizations and subclasses
  CURSOR l_org_id_csr IS
    SELECT   DISTINCT shd.authoring_org_id authoring_org_id
           , /*11510 change*/ NULL authoring_org_name
           , shd.scs_code scs_code
    FROM     oki_sales_k_hdrs shd
    ;

  -- Cursor to count the number of contracts with expired lines
  -- for a particular organization and subclass
  CURSOR l_expired_cnt_csr
  (   p_start_date       IN DATE
    , p_end_date         IN DATE
    , p_authoring_org_id IN NUMBER
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT   COUNT(DISTINCT(shd.chr_id)) contract_count
    FROM /*11510 change removed oki_Expired_lines and added oki_cov_prd_lines */
             oki_cov_prd_lines cpl
           , oki_sales_k_hdrs shd
    WHERE    cpl.end_date         BETWEEN p_start_date AND p_end_date
    /*11510 change start*/
    AND      cpl.is_exp_not_renewed_yn='Y'
    /*11510 change end*/
    AND      cpl.chr_id           = shd.chr_id
    AND      shd.authoring_org_id = p_authoring_org_id
    AND      shd.scs_code         = p_scs_code
    ;
  rec_l_expired_cnt_csr l_expired_cnt_csr%ROWTYPE ;

  -- Cursor to sum the amount of the expired lines
  -- for a particular organization and subclass
  CURSOR l_expired_amt_csr
  (    p_start_date       IN DATE
     , p_end_date         IN DATE
     , p_authoring_org_id IN NUMBER
     , p_scs_code         IN vARCHAR2
  ) IS
    SELECT NVL(SUM(cpl.base_price_negotiated), 0) base_price_negotiated
      /*11510 change removed oki_Expired_lines and added oki_cov_prd_lines */
    FROM     oki_cov_prd_lines cpl
           , oki_sales_k_hdrs shd
    WHERE  cpl.end_date       BETWEEN p_start_date AND p_end_date
   /*11510 change start*/
    AND    cpl.is_exp_not_renewed_yn='Y'
    /*11510 change end*/
    AND    cpl.chr_id           = shd.chr_id
    AND    shd.authoring_org_id = p_authoring_org_id
    AND    shd.scs_code         = p_scs_code
    ;
  rec_l_expired_amt_csr l_expired_amt_csr%ROWTYPE ;

  -- Cursor to count and sum the amount of the WIP contracts
  -- for a particular organization and subclass
  CURSOR l_wip_csr
  (   p_start_date       IN DATE
    , p_end_date         IN DATE
    , p_authoring_org_id IN NUMBER
    , p_scs_code         IN vARCHAR2
  ) IS
    SELECT   COUNT(*) contract_count
           , NVL(SUM(shd.base_contract_amount), 0) base_contract_amount
    FROM     oki_sales_k_hdrs shd
    WHERE    shd.ste_code         = 'ENTERED'
    AND      NVL(shd.close_date, shd.start_date)
                   BETWEEN p_start_date AND p_end_date
    AND      shd.is_new_yn IS NULL
    AND      shd.authoring_org_id = p_authoring_org_id
    AND      shd.scs_code         = p_scs_code
    ;
  rec_l_wip_csr l_wip_csr%ROWTYPE ;

  -- Cursor to count and sum the amount of the signed contracts
  -- for a particular organization and subclass
  CURSOR l_signed_csr
  (   p_start_date       IN DATE
    , p_end_date         IN DATE
    , p_authoring_org_id IN NUMBER
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT   COUNT(*) contract_count
           , NVL(SUM(shd.base_contract_amount), 0) base_contract_amount
    FROM     oki_sales_k_hdrs shd
    WHERE    shd.ste_code         IN ('ACTIVE','SIGNED')
    AND      LEAST(NVL(shd.date_signed, shd.start_date), shd.start_date)
                   BETWEEN p_start_date AND p_end_date
    AND      shd.is_new_yn IS NULL
    AND      shd.authoring_org_id = p_authoring_org_id
    AND      shd.scs_code         = p_scs_code
    ;
  rec_l_signed_csr l_signed_csr%ROWTYPE ;

  -- Cursor to count and sum the amount of the forecasted contracts
  -- for a particular organization and subclass
  CURSOR l_forecast_csr
  (   p_start_date       IN DATE
    , p_end_date         IN DATE
    , p_authoring_org_id IN NUMBER
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT   COUNT(*) contract_count
           , NVL(SUM(base_forecast_amount), 0) base_contract_amount
    FROM     oki_sales_k_hdrs shd
    WHERE    shd.close_date       BETWEEN p_start_date AND p_end_date
    AND      shd.win_percent      IS NOT NULL
    AND      shd.close_date       IS NOT NULL
    AND      shd.is_new_yn        IS NULL
    AND      shd.authoring_org_id = p_authoring_org_id
    AND      shd.scs_code         = p_scs_code
    ;
  rec_l_forecast_csr l_forecast_csr%ROWTYPE ;

  BEGIN

    -- initialize return code to success
    l_retcode := '0' ;

    l_loc := 'Looping through valid organizations.' ;
    << l_org_id_csr_loop >>
    -- Loop through all the organizations to calcuate the
    -- appropriate amounts
    FOR rec_l_org_id_csr IN l_org_id_csr LOOP

      l_loc := 'Looping through valid periods.' ;
      << rec_g_glpr_csr_loop >>
      -- Loop through all the periods
      FOR rec_g_glpr_csr IN oki_utl_pvt.g_glpr_csr(
          p_period_set_name, p_period_type, p_summary_build_date ) LOOP

        -- Get the truncated gl_periods start and end dates
        l_glpr_start_date := trunc(rec_g_glpr_csr.start_date );
        l_glpr_end_date   := trunc(rec_g_glpr_csr.end_date );

        -- Re-initialize the counts and amounts before calculating
        l_base_contract_amount := 0 ;
        l_contract_count       := 0 ;

        l_loc := 'Opening cursor to determine the expired count.' ;

        -- Calculate expired amounts and counts
        -- Fetch count of expired contracts
        OPEN l_expired_cnt_csr ( l_glpr_start_date, l_glpr_end_date,
             rec_l_org_id_csr.authoring_org_id, rec_l_org_id_csr.scs_code ) ;
        FETCH l_expired_cnt_csr INTO rec_l_expired_cnt_csr ;
          IF l_expired_cnt_csr%FOUND THEN
            l_contract_count := rec_l_expired_cnt_csr.contract_count ;
          END IF ;
        CLOSE l_expired_cnt_csr ;

        l_loc := 'Opening cursor to determine the expired sum.' ;
        -- Fetch the sum of the amount of the expired lines
        OPEN l_expired_amt_csr( l_glpr_start_date, l_glpr_end_date,
             rec_l_org_id_csr.authoring_org_id, rec_l_org_id_csr.scs_code ) ;
        FETCH l_expired_amt_csr INTO rec_l_expired_amt_csr ;
          IF l_expired_amt_csr%FOUND THEN
            l_base_contract_amount := rec_l_expired_amt_csr.base_price_negotiated ;
          END IF ;
        CLOSE l_expired_amt_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_rbs_pvt.g_rbs_csr( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_id_csr.authoring_org_id,
             'EXPIRED', rec_l_org_id_csr.scs_code ) ;
        FETCH oki_load_rbs_pvt.g_rbs_csr INTO l_rbs_rowid ;
          IF oki_load_rbs_pvt.g_rbs_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_rbs_pvt.ins_rnwl_by_stat(
                p_period_name        => rec_g_glpr_csr.period_name
              , p_period_set_name    => rec_g_glpr_csr.period_set_name
              , p_period_type        => rec_g_glpr_csr.period_type
              , p_authoring_org_id   => rec_l_org_id_csr.authoring_org_id
              , p_authoring_org_name => rec_l_org_id_csr.authoring_org_name
              , p_status_code        => 'EXPIRED'
              , p_scs_code           => rec_l_org_id_csr.scs_code
              , p_base_amount        => l_base_contract_amount
              , p_contract_count     => l_contract_count
              , x_retcode            => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_rbs_pvt.upd_rnwl_by_stat(
                p_base_amount    => l_base_contract_amount
              , p_contract_count => l_contract_count
              , p_rowid          => l_rbs_rowid
              , x_retcode        => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          END IF ;
        CLOSE oki_load_rbs_pvt.g_rbs_csr;


        -- Re-initialize the counts and amounts before calculating
        l_base_contract_amount := 0 ;
        l_contract_count       := 0 ;

        l_loc := 'Opening cursor to determine the WIP count and sum.' ;
        -- Calculate WIP amounts and counts
        OPEN l_wip_csr( l_glpr_start_date, l_glpr_end_date,
             rec_l_org_id_csr.authoring_org_id, rec_l_org_id_csr.scs_code ) ;
        FETCH l_wip_csr INTO rec_l_wip_csr ;
          IF l_wip_csr%FOUND THEN
            l_contract_count      := rec_l_wip_csr.contract_count ;
            l_base_contract_amount := rec_l_wip_csr.base_contract_amount ;
          END IF ;
        CLOSE l_wip_csr;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_rbs_pvt.g_rbs_csr( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_id_csr.authoring_org_id,
             'WIP', rec_l_org_id_csr.scs_code ) ;
        FETCH oki_load_rbs_pvt.g_rbs_csr INTO l_rbs_rowid ;
          IF oki_load_rbs_pvt.g_rbs_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_rbs_pvt.ins_rnwl_by_stat(
                p_period_set_name    => rec_g_glpr_csr.period_set_name
              , p_period_name        => rec_g_glpr_csr.period_name
              , p_period_type        => rec_g_glpr_csr.period_type
              , p_authoring_org_id   => rec_l_org_id_csr.authoring_org_id
              , p_authoring_org_name => rec_l_org_id_csr.authoring_org_name
              , p_status_code        => 'WIP'
              , p_scs_code           => rec_l_org_id_csr.scs_code
              , p_base_amount        => l_base_contract_amount
              , p_contract_count     => l_contract_count
              , x_retcode            => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_rbs_pvt.upd_rnwl_by_stat(
                p_base_amount    => l_base_contract_amount
              , p_contract_count => l_contract_count
              , p_rowid          => l_rbs_rowid
              , x_retcode        => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          END IF;
        CLOSE oki_load_rbs_pvt.g_rbs_csr;

        -- Re-initialize the counts and amounts before calculating
        l_base_contract_amount := 0 ;
        l_contract_count       := 0 ;

        l_loc := 'Opening cursor to determine the signed count and sum.' ;
        -- Calculate signed amounts and counts
        OPEN l_signed_csr( l_glpr_start_date, l_glpr_end_date,
             rec_l_org_id_csr.authoring_org_id, rec_l_org_id_csr.scs_code ) ;
        FETCH l_signed_csr INTO rec_l_signed_csr ;
          IF l_signed_csr%FOUND THEN
            l_contract_count       := rec_l_signed_csr.contract_count ;
            l_base_contract_amount := rec_l_signed_csr.base_contract_amount ;
          END IF ;
        CLOSE l_signed_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_rbs_pvt.g_rbs_csr( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_id_csr.authoring_org_id,
             'SIGNED', rec_l_org_id_csr.scs_code ) ;
        FETCH oki_load_rbs_pvt.g_rbs_csr INTO l_rbs_rowid ;
          IF oki_load_rbs_pvt.g_rbs_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_rbs_pvt.ins_rnwl_by_stat(
                p_period_set_name    => rec_g_glpr_csr.period_set_name
              , p_period_name        => rec_g_glpr_csr.period_name
              , p_period_type        => rec_g_glpr_csr.period_type
              , p_authoring_org_id   => rec_l_org_id_csr.authoring_org_id
              , p_authoring_org_name => rec_l_org_id_csr.authoring_org_name
              , p_status_code        => 'SIGNED'
              , p_scs_code           => rec_l_org_id_csr.scs_code
              , p_base_amount        => l_base_contract_amount
              , p_contract_count     => l_contract_count
              , x_retcode            => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_rbs_pvt.upd_rnwl_by_stat(
                p_base_amount    => l_base_contract_amount
              , p_contract_count => l_contract_count
              , p_rowid          => l_rbs_rowid
              , x_retcode        => l_retcode ) ;

            IF l_retcode = '2' THEN
               -- Load failed, exit immediately.
               RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          END IF;
        CLOSE oki_load_rbs_pvt.g_rbs_csr;

        -- Re-initialize the counts and amounts before calculating
        l_base_contract_amount := 0 ;
        l_contract_count      := 0 ;

        l_loc := 'Opening cursor to determine the forecast count and sum.' ;
        -- Calculate forecast amounts and counts
        OPEN l_forecast_csr( l_glpr_start_date, l_glpr_end_date,
             rec_l_org_id_csr.authoring_org_id, rec_l_org_id_csr.scs_code ) ;
        FETCH l_forecast_csr into rec_l_forecast_csr ;
          IF l_forecast_csr%FOUND THEN
            l_contract_count       := rec_l_forecast_csr.contract_count ;
            l_base_contract_amount := rec_l_forecast_csr.base_contract_amount ;
          END IF ;
        CLOSE l_forecast_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_rbs_pvt.g_rbs_csr( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_id_csr.authoring_org_id,
             'FORECAST', rec_l_org_id_csr.scs_code ) ;
        FETCH oki_load_rbs_pvt.g_rbs_csr INTO l_rbs_rowid ;
          IF oki_load_rbs_pvt.g_rbs_csr%NOTFOUND THEN
            -- Insert the current period data for the period
            l_loc := 'Insert the new record.' ;
            oki_load_rbs_pvt.ins_rnwl_by_stat(
                p_period_name        => rec_g_glpr_csr.period_name
              , p_period_set_name    => rec_g_glpr_csr.period_set_name
              , p_period_type        => rec_g_glpr_csr.period_type
              , p_authoring_org_id   => rec_l_org_id_csr.authoring_org_id
              , p_authoring_org_name => rec_l_org_id_csr.authoring_org_name
              , p_status_code        => 'FORECAST'
              , p_scs_code           => rec_l_org_id_csr.scs_code
              , p_base_amount        => l_base_contract_amount
              , p_contract_count     => l_contract_count
              , x_retcode            => l_retcode ) ;

            IF l_retcode = '2' THEN
               -- Load failed, exit immediately.
               RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_rbs_pvt.upd_rnwl_by_stat(
                p_base_amount    => l_base_contract_amount
              , p_contract_count => l_contract_count
              , p_rowid          => l_rbs_rowid
              , x_retcode        => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          END IF ;
        CLOSE oki_load_rbs_pvt.g_rbs_csr ;
      END LOOP rec_g_glpr_csr_loop ;
    END LOOP l_org_id_csr_loop ;

  EXCEPTION
    WHEN oki_load_rbs_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_RBS_PVT.OKI_CALC_RBS_DTL1' );

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

  end calc_rbs_dtl1 ;

--------------------------------------------------------------------------------
  -- Procedure to calculate the counts and amounts of expired, WIP,
  -- signed, and forecasted contracts.
  -- Calculates the counts and amounts across organizations:
  --   each period set name
  --   each period type
  --   each period name
  --   each status
  --   each subclass
  --   all  organizations
  --
--------------------------------------------------------------------------------
  PROCEDURE calc_rbs_dtl2
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , x_retcode            OUT NOCOPY VARCHAR2
  ) IS


  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode          VARCHAR2(100)  := NULL ;
  l_sqlerrm          VARCHAR2(1000) := NULL ;

  -- Holds the contract amount and counts
  l_contract_count       NUMBER ;
  l_base_contract_amount NUMBER ;

  -- holds the rowid of the record in the oki_renew_by_statuses table
  l_rbs_rowid            ROWID := null ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;

  -- Cusror declaration

  -- Cursor to get all the organizations
  CURSOR l_scs_csr IS
    SELECT   DISTINCT shd.scs_code
    FROM     oki_sales_k_hdrs shd
    ;

  -- Cursor to count the number of contracts with expired lines
  -- for each organization
  CURSOR l_expired_cnt_csr
  (   p_start_date       IN DATE
    , p_end_date         IN DATE
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT   COUNT(DISTINCT(shd.chr_id)) contract_count
/*11510 change removed oki_Expired_lines and added oki_cov_prd_lines */
    FROM     oki_cov_prd_lines cpl
           , oki_sales_k_hdrs shd
    WHERE    cpl.end_date  BETWEEN p_start_date AND p_end_date
/*11510 change start*/
    AND      cpl.is_exp_not_renewed_yn='Y'
/*11510 change end*/
    AND      cpl.chr_id    = shd.chr_id
    AND      shd.scs_code  = p_scs_code
    ;
  rec_l_expired_cnt_csr l_expired_cnt_csr%ROWTYPE ;

  -- Cursor to sum the amount of the expired lines
  -- for each subclass
  CURSOR l_expired_amt_csr
  (    p_start_date       IN DATE
     , p_end_date         IN DATE
    , p_scs_code         IN VARCHAR2

  ) IS
    SELECT NVL(SUM(cpl.base_price_negotiated), 0) base_price_negotiated
 /*11510 change removed oki_Expired_lines and added oki_cov_prd_lines */
       FROM  oki_cov_prd_lines cpl
           , oki_sales_k_hdrs shd
    WHERE    cpl.end_date BETWEEN p_start_date AND p_end_date
 /*11510 change start*/
    AND      cpl.is_exp_not_renewed_yn='Y'
/*11510 change end*/
    AND      cpl.chr_id     = shd.chr_id
    AND      shd.scs_code = p_scs_code
    ;
  rec_l_expired_amt_csr l_expired_amt_csr%ROWTYPE ;

  -- Cursor to count and sum the amount of the WIP contracts
  -- for each subclass
  CURSOR l_wip_csr
  (   p_start_date       IN DATE
    , p_end_date         IN DATE
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT   COUNT(*) contract_count
           , NVL(SUM(shd.base_contract_amount), 0) base_contract_amount
    FROM     oki_sales_k_hdrs shd
    WHERE    shd.ste_code  = 'ENTERED'
    AND      NVL(shd.close_date, shd.start_date) BETWEEN p_start_date AND p_end_date
    AND      shd.is_new_yn IS NULL
    AND      shd.scs_code  = p_scs_code
    ;
  rec_l_wip_csr l_wip_csr%ROWTYPE ;

  -- Cursor to count and sum the amount of the signed contracts
  -- for each subclass
  CURSOR l_signed_csr
  (   p_start_date       IN DATE
    , p_end_date         IN DATE
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT   COUNT(*) contract_count
           , NVL(SUM(shd.base_contract_amount), 0) base_contract_amount
    FROM     oki_sales_k_hdrs shd
    WHERE    shd.ste_code  IN ('ACTIVE','SIGNED')
    AND      LEAST(NVL(shd.date_signed, shd.start_date), shd.start_date)
                           BETWEEN p_start_date AND p_end_date
    AND      shd.is_new_yn IS NULL
    AND      shd.scs_code  = p_scs_code
    ;
  rec_l_signed_csr l_signed_csr%ROWTYPE ;

  -- Cursor to count and sum the amount of the forecasted contracts
  -- for each subclass
  CURSOR l_forecast_csr
  (   p_start_date       IN DATE
    , p_end_date         IN DATE
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT   COUNT(*) contract_count
           , NVL(SUM(base_forecast_amount), 0) base_contract_amount
    FROM     oki_sales_k_hdrs shd
    WHERE    shd.close_date  BETWEEN p_start_date AND p_end_date
    AND      shd.win_percent IS NOT NULL
    AND      shd.close_date  IS NOT NULL
    AND      shd.is_new_yn   IS NULL
    AND      shd.scs_code    = p_scs_code
    ;
  rec_l_forecast_csr l_forecast_csr%ROWTYPE ;

  begin

    -- initialize return code to success
    l_retcode := '0' ;

    l_loc := 'Looping through valid organizations.' ;
    << l_scs_csr_loop >>
    -- Loop through all the organizations to calcuate the
    -- appropriate amounts
    FOR rec_l_scs_csr IN l_scs_csr LOOP

      l_loc := 'Looping through valid periods.' ;
      << rec_g_glpr_csr_loop >>
      -- Loop through all the periods
      FOR rec_g_glpr_csr IN oki_utl_pvt.g_glpr_csr(
          p_period_set_name, p_period_type, p_summary_build_date ) LOOP

        -- Get the truncated gl_periods start and end dates
        l_glpr_start_date := trunc(rec_g_glpr_csr.start_date );
        l_glpr_end_date   := trunc(rec_g_glpr_csr.end_date );

        -- Re-initialize the counts and amounts before calculating
        l_base_contract_amount := 0 ;
        l_contract_count       := 0 ;

        l_loc := 'Opening cursor to determine the expired count.' ;
        -- Calculate expired amounts and counts
        -- Fetch count of expired contracts

        OPEN l_expired_cnt_csr ( l_glpr_start_date, l_glpr_end_date,
             rec_l_scs_csr.scs_code ) ;
        FETCH l_expired_cnt_csr INTO rec_l_expired_cnt_csr ;
          IF l_expired_cnt_csr%FOUND THEN
            l_contract_count := rec_l_expired_cnt_csr.contract_count ;
          END IF ;
        CLOSE l_expired_cnt_csr ;

        l_loc := 'Opening cursor to determine the expired sum.' ;
        -- Fetch the sum of the amount of the expired lines
        OPEN l_expired_amt_csr( l_glpr_start_date, l_glpr_end_date,
             rec_l_scs_csr.scs_code ) ;
        FETCH l_expired_amt_csr INTO rec_l_expired_amt_csr ;
          IF l_expired_amt_csr%FOUND THEN
            l_base_contract_amount := rec_l_expired_amt_csr.base_price_negotiated ;
          END IF ;
        CLOSE l_expired_amt_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_rbs_pvt.g_rbs_csr( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_rbs_pvt.g_all_org_id,
             'EXPIRED', rec_l_scs_csr.scs_code ) ;
        FETCH oki_load_rbs_pvt.g_rbs_csr INTO l_rbs_rowid ;
          IF oki_load_rbs_pvt.g_rbs_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_rbs_pvt.ins_rnwl_by_stat(
                p_period_name        => rec_g_glpr_csr.period_name
              , p_period_set_name    => rec_g_glpr_csr.period_set_name
              , p_period_type        => rec_g_glpr_csr.period_type
              , p_authoring_org_id   => oki_load_rbs_pvt.g_all_org_id
              , p_authoring_org_name => oki_load_rbs_pvt.g_all_org_name
              , p_status_code        => 'EXPIRED'
              , p_scs_code           => rec_l_scs_csr.scs_code
              , p_base_amount        => l_base_contract_amount
              , p_contract_count     => l_contract_count
              , x_retcode            => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_rbs_pvt.upd_rnwl_by_stat(
                p_base_amount    => l_base_contract_amount
              , p_contract_count => l_contract_count
              , p_rowid          => l_rbs_rowid
              , x_retcode        => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          END IF ;
        CLOSE oki_load_rbs_pvt.g_rbs_csr;


        -- Re-initialize the counts and amounts before calculating
        l_base_contract_amount := 0 ;
        l_contract_count       := 0 ;

        l_loc := 'Opening cursor to determine the WIP count and sum.' ;
        -- Calculate WIP amounts and counts
        OPEN l_wip_csr( l_glpr_start_date, l_glpr_end_date,
             rec_l_scs_csr.scs_code ) ;
        FETCH l_wip_csr INTO rec_l_wip_csr ;
          IF l_wip_csr%FOUND THEN
            l_contract_count       := rec_l_wip_csr.contract_count ;
            l_base_contract_amount := rec_l_wip_csr.base_contract_amount ;
          END IF ;
        CLOSE l_wip_csr;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_rbs_pvt.g_rbs_csr( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_rbs_pvt.g_all_org_id,
             'WIP', rec_l_scs_csr.scs_code ) ;
        FETCH oki_load_rbs_pvt.g_rbs_csr INTO l_rbs_rowid ;
          IF oki_load_rbs_pvt.g_rbs_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_rbs_pvt.ins_rnwl_by_stat(
                p_period_set_name    => rec_g_glpr_csr.period_set_name
              , p_period_name        => rec_g_glpr_csr.period_name
              , p_period_type        => rec_g_glpr_csr.period_type
              , p_authoring_org_id   => oki_load_rbs_pvt.g_all_org_id
              , p_authoring_org_name => oki_load_rbs_pvt.g_all_org_name
              , p_status_code        => 'WIP'
              , p_scs_code           => rec_l_scs_csr.scs_code
              , p_base_amount        => l_base_contract_amount
              , p_contract_count     => l_contract_count
              , x_retcode            => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_rbs_pvt.upd_rnwl_by_stat(
                p_base_amount    => l_base_contract_amount
              , p_contract_count => l_contract_count
              , p_rowid          => l_rbs_rowid
              , x_retcode        => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          END IF;
        CLOSE oki_load_rbs_pvt.g_rbs_csr;


        -- Re-initialize the counts and amounts before calculating
        l_base_contract_amount := 0 ;
        l_contract_count       := 0 ;

        l_loc := 'Opening cursor to determine the signed count and sum.' ;
        -- Calculate signed amounts and counts
        OPEN l_signed_csr( l_glpr_start_date, l_glpr_end_date,
             rec_l_scs_csr.scs_code ) ;
        FETCH l_signed_csr INTO rec_l_signed_csr ;
          IF l_signed_csr%FOUND THEN
            l_contract_count      := rec_l_signed_csr.contract_count ;
            l_base_contract_amount := rec_l_signed_csr.base_contract_amount ;
          END IF ;
        CLOSE l_signed_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_rbs_pvt.g_rbs_csr( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_rbs_pvt.g_all_org_id,
             'SIGNED', rec_l_scs_csr.scs_code ) ;
        FETCH oki_load_rbs_pvt.g_rbs_csr INTO l_rbs_rowid ;
          IF oki_load_rbs_pvt.g_rbs_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_rbs_pvt.ins_rnwl_by_stat(
                p_period_set_name    => rec_g_glpr_csr.period_set_name
              , p_period_name        => rec_g_glpr_csr.period_name
              , p_period_type        => rec_g_glpr_csr.period_type
              , p_authoring_org_id   => oki_load_rbs_pvt.g_all_org_id
              , p_authoring_org_name => oki_load_rbs_pvt.g_all_org_name
              , p_status_code        => 'SIGNED'
              , p_scs_code           => rec_l_scs_csr.scs_code
              , p_base_amount        => l_base_contract_amount
              , p_contract_count     => l_contract_count
              , x_retcode            => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_rbs_pvt.upd_rnwl_by_stat(
                p_base_amount    => l_base_contract_amount
              , p_contract_count => l_contract_count
              , p_rowid          => l_rbs_rowid
              , x_retcode        => l_retcode ) ;

            IF l_retcode = '2' THEN
               -- Load failed, exit immediately.
               RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          END IF;
        CLOSE oki_load_rbs_pvt.g_rbs_csr ;

        -- Re-initialize the counts and amounts before calculating
        l_base_contract_amount := 0 ;
        l_contract_count       := 0 ;

        l_loc := 'Opening cursor to determine the forecast count and sum.' ;
        -- Calculate forecast amounts and counts
        OPEN l_forecast_csr( l_glpr_start_date, l_glpr_end_date,
             rec_l_scs_csr.scs_code ) ;
        FETCH l_forecast_csr into rec_l_forecast_csr ;
          IF l_forecast_csr%FOUND THEN
            l_contract_count      := rec_l_forecast_csr.contract_count ;
            l_base_contract_amount := rec_l_forecast_csr.base_contract_amount ;
          END IF ;
        CLOSE l_forecast_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_rbs_pvt.g_rbs_csr( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_rbs_pvt.g_all_org_id,
             'FORECAST', rec_l_scs_csr.scs_code ) ;
        FETCH oki_load_rbs_pvt.g_rbs_csr INTO l_rbs_rowid ;
          IF oki_load_rbs_pvt.g_rbs_csr%NOTFOUND THEN
            -- Insert the current period data for the period
            l_loc := 'Insert the new record.' ;
            oki_load_rbs_pvt.ins_rnwl_by_stat(
                p_period_name        => rec_g_glpr_csr.period_name
              , p_period_set_name    => rec_g_glpr_csr.period_set_name
              , p_period_type        => rec_g_glpr_csr.period_type
              , p_authoring_org_id   => oki_load_rbs_pvt.g_all_org_id
              , p_authoring_org_name => oki_load_rbs_pvt.g_all_org_name
              , p_status_code        => 'FORECAST'
              , p_scs_code           => rec_l_scs_csr.scs_code
              , p_base_amount        => l_base_contract_amount
              , p_contract_count     => l_contract_count
              , x_retcode            => l_retcode ) ;

            IF l_retcode = '2' THEN
               -- Load failed, exit immediately.
               RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_rbs_pvt.upd_rnwl_by_stat(
                p_base_amount    => l_base_contract_amount
              , p_contract_count => l_contract_count
              , p_rowid          => l_rbs_rowid
              , x_retcode        => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
            END IF ;

          END IF ;
        CLOSE oki_load_rbs_pvt.g_rbs_csr ;
      END LOOP rec_g_glpr_csr_loop ;
    END LOOP l_scs_csr_loop ;

  EXCEPTION
    WHEN oki_load_rbs_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_RBS_PVT.OKI_CALC_RBS_DTL1');

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

  end calc_rbs_dtl2 ;

--------------------------------------------------------------------------------
  -- Procedure to calculate the counts and amounts of expired, WIP,
  -- signed, and forecasted contracts.
  -- Calculates the counts and amounts across organizations and subclasses
  --   each period set name
  --   each period type
  --   each period name
  --   each status
  --   all  subclasses
  --   all  organizations
  --
--------------------------------------------------------------------------------
  PROCEDURE calc_rbs_sum
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , x_retcode            OUT NOCOPY VARCHAR2
  ) IS


  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode          VARCHAR2(100)  := NULL ;
  l_sqlerrm          VARCHAR2(1000) := NULL ;

  -- Holds the contract amount and counts
  l_contract_count       NUMBER ;
  l_base_contract_amount NUMBER ;

  -- holds the rowid of the record in the oki_renew_by_statuses table
  l_rbs_rowid            ROWID := null ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;

  -- Cusror declaration

  -- Cursor to sum the amount of the expired lines
  CURSOR l_expired_amt_csr
  (    p_start_date IN DATE
     , p_end_date   IN DATE
  ) IS
    SELECT NVL(SUM(cpl.base_price_negotiated), 0) base_price_negotiated
 /*11510 change removed oki_Expired_lines and added oki_cov_prd_lines */
    FROM     oki_cov_prd_lines cpl
    WHERE    cpl.end_date between p_start_date AND p_end_date
/*11510 change*/
     AND      cpl.is_exp_not_renewed_yn='Y'   ;
  rec_l_expired_amt_csr l_expired_amt_csr%ROWTYPE ;

  -- Cursor to count the number of contracts with expired lines
  CURSOR l_expired_cnt_csr
  (   p_start_date IN DATE
    , p_end_date   IN DATE) IS
    SELECT   COUNT(DISTINCT(shd.chr_id)) contract_count
 /*11510 change removed oki_Expired_lines and added oki_cov_prd_lines */
    FROM     oki_cov_prd_lines cpl
           , oki_sales_k_hdrs shd
    WHERE    cpl.end_date BETWEEN p_start_date and p_end_date
/*11510 change*/
    AND      cpl.is_exp_not_renewed_yn='Y'
    AND      cpl.chr_id   = shd.chr_id     ;

  rec_l_expired_cnt_csr l_expired_cnt_csr%ROWTYPE ;

  -- Cursor to count and sum the amount of the WIP contracts
  CURSOR l_wip_csr
  (   p_start_date IN DATE
    , p_end_date   IN DATE
  ) IS
    SELECT   COUNT(*) contract_count
           , NVL(SUM(shd.base_contract_amount), 0) base_contract_amount
    FROM     oki_sales_k_hdrs shd
    WHERE    shd.ste_code = 'ENTERED'
    AND      NVL(shd.close_date, shd.start_date)
                           BETWEEN p_start_date AND p_end_date
    AND      shd.is_new_yn IS NULL
    ;
  rec_l_wip_csr l_wip_csr%ROWTYPE ;

  -- Cursor to count and sum the amount of the signed contracts
  CURSOR l_signed_csr
  (   p_start_date IN DATE
    , p_end_date   IN DATE
  ) IS
    SELECT     count(*) contract_count
             , NVL(SUM(shd.base_contract_amount), 0) base_contract_amount
    FROM     oki_sales_k_hdrs shd
    WHERE    shd.ste_code  IN ('ACTIVE','SIGNED')
    AND      LEAST(NVL(shd.date_signed, shd.start_date), shd.start_date)
                           BETWEEN p_start_date AND p_end_date
    AND      shd.is_new_yn IS NULL
    ;
  rec_l_signed_csr l_signed_csr%ROWTYPE ;

  -- Cursor to count and sum the amount of the forecasted contracts
  CURSOR l_forecast_csr
  (   p_start_date IN DATE
    , p_end_date   IN DATE) IS
    SELECT   count(*) contract_count
           , NVL(SUM(base_forecast_amount), 0) base_contract_amount
    FROM     oki_sales_k_hdrs shd
    WHERE    shd.close_date  BETWEEN p_start_date AND p_end_date
    AND      shd.win_percent IS NOT NULL
    AND      shd.close_date  IS NOT NULL
    AND      shd.is_new_yn   IS NULL
    ;
  rec_l_forecast_csr l_forecast_csr%ROWTYPE ;

  begin

    -- initialize return code to success
    l_retcode := '0' ;

    l_loc := 'Looping through valid periods.' ;
    -- Loop through all the periods
    FOR rec_g_glpr_csr IN oki_utl_pvt.g_glpr_csr(
        p_period_set_name, p_period_type, p_summary_build_date ) LOOP

      -- Get the truncated gl_periods start and end dates
      l_glpr_start_date := trunc(rec_g_glpr_csr.start_date );
      l_glpr_end_date   := trunc(rec_g_glpr_csr.end_date );

      -- Re-initialize the counts and amounts before calculating
      l_base_contract_amount := 0 ;
      l_contract_count       := 0 ;

      l_loc := 'Opening cursor to determine the expired count.' ;
      -- Calculate expired amounts and counts
      -- Fetch count of expired contracts
      OPEN l_expired_cnt_csr ( l_glpr_start_date, l_glpr_end_date ) ;
      FETCH l_expired_cnt_csr INTO rec_l_expired_cnt_csr ;
        IF l_expired_cnt_csr%FOUND THEN
          l_contract_count := rec_l_expired_cnt_csr.contract_count ;
        END IF ;
      CLOSE l_expired_cnt_csr ;

      l_loc := 'Opening cursor to determine the expired sum.' ;
      -- Fetch the sum of the amount of the expired lines
      OPEN l_expired_amt_csr( l_glpr_start_date, l_glpr_end_date ) ;
      FETCH l_expired_amt_csr INTO rec_l_expired_amt_csr ;
        IF l_expired_amt_csr%FOUND THEN
          l_base_contract_amount := rec_l_expired_amt_csr.base_price_negotiated ;
        END IF ;
      CLOSE l_expired_amt_csr ;

      l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_rbs_pvt.g_rbs_csr( rec_g_glpr_csr.period_set_name,
           rec_g_glpr_csr.period_name, oki_load_rbs_pvt.g_all_org_id,
           'EXPIRED', oki_load_rbs_pvt.g_all_scs_code) ;
      FETCH oki_load_rbs_pvt.g_rbs_csr INTO l_rbs_rowid ;
        IF oki_load_rbs_pvt.g_rbs_csr%NOTFOUND THEN
          l_loc := 'Insert the new record.' ;
          -- Insert the current period data for the period
          oki_load_rbs_pvt.ins_rnwl_by_stat(
                p_period_name        => rec_g_glpr_csr.period_name
              , p_period_set_name    => rec_g_glpr_csr.period_set_name
              , p_period_type        => rec_g_glpr_csr.period_type
              , p_authoring_org_id   => oki_load_rbs_pvt.g_all_org_id
              , p_authoring_org_name => oki_load_rbs_pvt.g_all_org_name
              , p_status_code        => 'EXPIRED'
              , p_scs_code           => oki_load_rbs_pvt.g_all_scs_code
              , p_base_amount        => l_base_contract_amount
              , p_contract_count     => l_contract_count
              , x_retcode            => l_retcode ) ;

          IF l_retcode = '2' THEN
            -- Load failed, exit immediately.
            RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
          END IF ;

        ELSE
          l_loc := 'Update the existing record.' ;
          -- Record already exists, so perform an update
          oki_load_rbs_pvt.upd_rnwl_by_stat(
                p_base_amount     => l_base_contract_amount
              , p_contract_count => l_contract_count
              , p_rowid          => l_rbs_rowid
              , x_retcode        => l_retcode ) ;

          IF l_retcode = '2' THEN
            -- Load failed, exit immediately.
            RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
          END IF ;

        END IF ;
      CLOSE oki_load_rbs_pvt.g_rbs_csr;

      -- Re-initialize the counts and amounts before calculating
      l_base_contract_amount := 0 ;
      l_contract_count       := 0 ;

      l_loc := 'Opening cursor to determine the WIP count and sum.' ;
      -- Calculate WIP amounts and counts
      OPEN l_wip_csr( l_glpr_start_date, l_glpr_end_date ) ;
      FETCH l_wip_csr INTO rec_l_wip_csr ;
        IF l_wip_csr%FOUND THEN
          l_contract_count       := rec_l_wip_csr.contract_count ;
          l_base_contract_amount := rec_l_wip_csr.base_contract_amount ;
        END IF ;
      CLOSE l_wip_csr;

      l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_rbs_pvt.g_rbs_csr( rec_g_glpr_csr.period_set_name,
           rec_g_glpr_csr.period_name, oki_load_rbs_pvt.g_all_org_id,
           'WIP', oki_load_rbs_pvt.g_all_scs_code ) ;
      FETCH oki_load_rbs_pvt.g_rbs_csr INTO l_rbs_rowid;
        IF oki_load_rbs_pvt.g_rbs_csr%NOTFOUND THEN
          l_loc := 'Insert the new record.' ;
          -- Insert the current period data for the period
          oki_load_rbs_pvt.ins_rnwl_by_stat(
                p_period_set_name    => rec_g_glpr_csr.period_set_name
              , p_period_name        => rec_g_glpr_csr.period_name
              , p_period_type        => rec_g_glpr_csr.period_type
              , p_authoring_org_id   => oki_load_rbs_pvt.g_all_org_id
              , p_authoring_org_name => oki_load_rbs_pvt.g_all_org_name
              , p_status_code        => 'WIP'
              , p_scs_code           => oki_load_rbs_pvt.g_all_scs_code
              , p_base_amount        => l_base_contract_amount
              , p_contract_count     => l_contract_count
              , x_retcode            => l_retcode ) ;

          IF l_retcode = '2' THEN
            -- Load failed, exit immediately.
            RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
          END IF ;

        ELSE
          l_loc := 'Update the existing record.' ;
          -- Record already exists, so perform an update
          oki_load_rbs_pvt.upd_rnwl_by_stat(
                p_base_amount    => l_base_contract_amount
              , p_contract_count => l_contract_count
              , p_rowid          => l_rbs_rowid
              , x_retcode        => l_retcode ) ;
          IF l_retcode = '2' THEN
            -- Load failed, exit immediately.
            RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
          END IF ;

        END IF;
      CLOSE oki_load_rbs_pvt.g_rbs_csr;

      -- Re-initialize the counts and amounts before calculating
      l_base_contract_amount := 0 ;
      l_contract_count       := 0 ;

      l_loc := 'Opening cursor to determine the signed count and sum.' ;
      -- Calculate signed amounts and counts
      OPEN l_signed_csr( l_glpr_start_date, l_glpr_end_date ) ;
      FETCH l_signed_csr INTO rec_l_signed_csr ;
        IF l_signed_csr%FOUND THEN
          l_contract_count       := rec_l_signed_csr.contract_count ;
          l_base_contract_amount := rec_l_signed_csr.base_contract_amount ;
        END IF ;
      CLOSE l_signed_csr ;

      l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_rbs_pvt.g_rbs_csr( rec_g_glpr_csr.period_set_name,
           rec_g_glpr_csr.period_name, oki_load_rbs_pvt.g_all_org_id,
           'SIGNED', oki_load_rbs_pvt.g_all_scs_code ) ;
      FETCH oki_load_rbs_pvt.g_rbs_csr INTO l_rbs_rowid ;
        IF oki_load_rbs_pvt.g_rbs_csr%NOTFOUND THEN
          l_loc := 'Insert the new record.' ;
          -- Insert the current period data for the period
          oki_load_rbs_pvt.ins_rnwl_by_stat(
                p_period_set_name    => rec_g_glpr_csr.period_set_name
              , p_period_name        => rec_g_glpr_csr.period_name
              , p_period_type        => rec_g_glpr_csr.period_type
              , p_authoring_org_id   => oki_load_rbs_pvt.g_all_org_id
              , p_authoring_org_name => oki_load_rbs_pvt.g_all_org_name
              , p_status_code        => 'SIGNED'
              , p_scs_code           => oki_load_rbs_pvt.g_all_scs_code
              , p_base_amount        => l_base_contract_amount
              , p_contract_count     => l_contract_count
              , x_retcode            => l_retcode ) ;

          IF l_retcode = '2' THEN
            -- Load failed, exit immediately.
            RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
          END IF ;

        ELSE
          l_loc := 'Update the existing record.' ;
          -- Record already exists, so perform an update
          oki_load_rbs_pvt.upd_rnwl_by_stat(
                p_base_amount    => l_base_contract_amount
              , p_contract_count => l_contract_count
              , p_rowid          => l_rbs_rowid
              , x_retcode        => l_retcode ) ;

          IF l_retcode = '2' THEN
            -- Load failed, exit immediately.
            RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
          END IF ;

        END IF;
      CLOSE oki_load_rbs_pvt.g_rbs_csr;

      -- Re-initialize the counts and amounts before calculating
      l_base_contract_amount := 0 ;
      l_contract_count       := 0 ;

      l_loc := 'Opening cursor to determine the forecast count and sum.' ;
      -- Calculate forecast amounts and counts
      OPEN l_forecast_csr( l_glpr_start_date, l_glpr_end_date ) ;
      FETCH l_forecast_csr into rec_l_forecast_csr ;
        IF l_forecast_csr%FOUND THEN
          l_contract_count       := rec_l_forecast_csr.contract_count ;
          l_base_contract_amount := rec_l_forecast_csr.base_contract_amount ;
        END IF ;
      CLOSE l_forecast_csr ;

      l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_rbs_pvt.g_rbs_csr( rec_g_glpr_csr.period_set_name,
           rec_g_glpr_csr.period_name, oki_load_rbs_pvt.g_all_org_id,
           'FORECAST', oki_load_rbs_pvt.g_all_scs_code ) ;
      FETCH oki_load_rbs_pvt.g_rbs_csr INTO l_rbs_rowid ;
        IF oki_load_rbs_pvt.g_rbs_csr%NOTFOUND THEN
          -- Insert the current period data for the period
          l_loc := 'Insert the new record.' ;
          oki_load_rbs_pvt.ins_rnwl_by_stat(
                p_period_name        => rec_g_glpr_csr.period_name
              , p_period_set_name    => rec_g_glpr_csr.period_set_name
              , p_period_type        => rec_g_glpr_csr.period_type
              , p_authoring_org_id   => oki_load_rbs_pvt.g_all_org_id
              , p_authoring_org_name => oki_load_rbs_pvt.g_all_org_name
              , p_status_code        => 'FORECAST'
              , p_scs_code           => oki_load_rbs_pvt.g_all_scs_code
              , p_base_amount        => l_base_contract_amount
              , p_contract_count     => l_contract_count
              , x_retcode            => l_retcode ) ;

          IF l_retcode = '2' THEN
            -- Load failed, exit immediately.
            RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
          END IF ;

        ELSE
          l_loc := 'Update the existing record.' ;
          -- Record already exists, so perform an update
          oki_load_rbs_pvt.upd_rnwl_by_stat(
                p_base_amount    => l_base_contract_amount
              , p_contract_count => l_contract_count
              , p_rowid          => l_rbs_rowid
              , x_retcode        => l_retcode ) ;

          IF l_retcode = '2' THEN
            -- Load failed, exit immediately.
            RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
          END IF ;

        END IF ;
      CLOSE oki_load_rbs_pvt.g_rbs_csr ;
    END LOOP ;

  EXCEPTION
    WHEN oki_load_rbs_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_RBS_PVT.OKI_CALC_RBS_SUM');

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

  end calc_rbs_sum ;

--------------------------------------------------------------------------------
  -- Procedure to create all the renewal by statuses records.
  -- If an error is encountered in this procedure or subsequent procedures then
  -- rollback all changes.  Once the table is loaded and the data is committed
  -- the load is considered successful even if update of the oki_refreshs
  -- table failed.
--------------------------------------------------------------------------------
  PROCEDURE crt_rnwl_by_stat
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , x_errbuf             OUT NOCOPY VARCHAR2
    , x_retcode            OUT NOCOPY VARCHAR2
  ) IS

  -- Local exception declaration

  -- Exception to immediately exit the procedure
  l_excp_upd_refresh   EXCEPTION ;


  -- Constant declaration

  -- Name of the table for which data is being inserted
  l_table_name      CONSTANT VARCHAR2(30) := 'OKI_RENEW_BY_STATUSES' ;


  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;


  BEGIN

    SAVEPOINT oki_load_rbs_pvt_crt_rnwl_cst ;

    -- initialize return code to success
    l_retcode := '0' ;
    x_retcode := '0' ;

    -- Procedure to calculate the counts and amounts for each dimension
    oki_load_rbs_pvt.calc_rbs_dtl1(
          p_period_set_name    => p_period_set_name
        , p_period_type        => p_period_type
        , p_summary_build_date => p_summary_build_date
        , x_retcode            => l_retcode ) ;

     IF l_retcode = '2' THEN
       -- Load failed, exit immediately.
       RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
     END IF ;

    -- Procedure to calculate the counts and amounts across organizations
    oki_load_rbs_pvt.calc_rbs_dtl2(
          p_period_set_name    => p_period_set_name
        , p_period_type        => p_period_type
        , p_summary_build_date => p_summary_build_date
        , x_retcode            => l_retcode ) ;

     IF l_retcode = '2' THEN
       -- Load failed, exit immediately.
       RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
     END IF ;

    -- Procedure to calculate the counts and amounts across organizations
    -- and subclasses
    oki_load_rbs_pvt.calc_rbs_sum(
          p_period_set_name    => p_period_set_name
        , p_period_type        => p_period_type
        , p_summary_build_date => p_summary_build_date
        , x_retcode            => l_retcode ) ;

     IF l_retcode = '2' THEN
       -- Load failed, exit immediately.
       RAISE oki_load_rbs_pvt.g_excp_exit_immediate ;
     END IF ;

     COMMIT ;

    SAVEPOINT oki_load_rbs_pvt_upd_refresh ;

    -- Table loaded successfully.  Log message in concurrent manager
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

      ROLLBACK to oki_load_rbs_pvt_upd_refresh ;

    WHEN oki_load_rbs_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

      ROLLBACK TO oki_load_rbs_pvt_crt_rnwl_cst ;

    WHEN OTHERS THEN

      l_sqlcode := sqlcode ;
      l_sqlerrm := sqlerrm ;

      -- Set return code to error
      x_retcode := '2' ;

      -- rollback all transactions
      ROLLBACK to oki_load_rbs_pvt_crt_rnwl_cst ;


      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_RBS_PVT.CRT_RNWL_BY_STAT');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  end crt_rnwl_by_stat ;


BEGIN
  -- Initialize the global variables used to log this job run
  -- from concurrent manager
  g_request_id             :=  fnd_global.conc_request_id ;
  g_program_application_id :=  fnd_global.prog_appl_id ;
  g_program_id             :=  fnd_global.conc_program_id ;
  g_program_update_date    :=  SYSDATE ;

END oki_load_rbs_pvt ;

/
