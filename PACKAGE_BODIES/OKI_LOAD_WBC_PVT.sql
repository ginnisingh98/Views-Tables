--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_WBC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_WBC_PVT" as
/* $Header: OKIRWBCB.pls 115.21 2003/11/24 08:24:41 kbajaj ship $ */

--------------------------------------------------------------------------------
-- Modification History
-- 25-Aug-2001  mezra        Changed program to reflect the addition of
--                           new columns: authoring_org_id,
--                           authoring_org_name, and subclass code.
-- 10-Sep-2001  mezra        Added column value, All Categories, for summary
--                           level of all scs_code; All Organizations, for
--                           summary level of all organizations.
-- 18-Sep-2001  mezra        Moved wbc_csr from local cursor to global
--                           cursor since it is used by all the calc
--                           procedures.
-- 25-Sep-2001  mezra        Change usd_ columns to base_.
-- 22-Oct-2001  mezra        Changed All Categories value to -1.
-- 24-Oct-2001  mezra        Removed trunc on date columns to increase
--                           performance since index will be used.
-- 26-NOV-2002  rpotnuru     NOCOPY Changes
-- 19-Dec-2002  brrao        UTF-8 Changes to Org Name
-- 29-oct-2003  axraghav     null out organization_name for 11510 Changes
--
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
  CURSOR g_wbc_csr
  (   p_period_set_name  IN VARCHAR2
    , p_period_name      IN VARCHAR2
    , p_authoring_org_id IN NUMBER
    , p_customer_id      IN NUMBER
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT rowid
    FROM   oki_wip_by_customers wbc
    WHERE  wbc.period_set_name   = p_period_set_name
    AND    wbc.period_name       = p_period_name
    AND    wbc.authoring_org_id  = p_authoring_org_id
    AND    wbc.customer_party_id = p_customer_id
    AND    wbc.scs_code          = p_scs_code ;
  rec_g_wbc_csr g_wbc_csr%ROWTYPE
  ;

--------------------------------------------------------------------------------
  -- Procedure to insert records into the oki_wip_by_customers table.

--------------------------------------------------------------------------------
  PROCEDURE ins_wip_by_cust
  (   p_period_name          IN  VARCHAR2
    , p_period_set_name      IN  VARCHAR2
    , p_period_type          IN  VARCHAR2
    , p_authoring_org_id     IN  NUMBER
    , p_authoring_org_name   IN  VARCHAR2
    , p_customer_party_id    IN  NUMBER
    , p_customer_name        IN  VARCHAR2
    , p_scs_code             IN  VARCHAR2
    , p_base_forecast_amount IN  NUMBER
    , p_base_booked_amount   IN  NUMBER
    , p_base_lost_amount     IN  NUMBER
    , x_retcode              OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  l_sequence  NUMBER := NULL ;

  -- Cursor declaration
  CURSOR l_seq_num IS
    SELECT oki_wip_by_customers_s1.nextval seq
    FROM dual
    ;
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

    INSERT INTO oki_wip_by_customers
    (        id
           , period_set_name
           , period_name
           , period_type
           , authoring_org_id
           , authoring_org_name
           , customer_party_id
           , customer_name
           , scs_code
           , base_forecast_amount
           , base_booked_amount
           , base_lost_amount
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
           , p_customer_party_id
           , p_customer_name
           , p_scs_code
           , p_base_forecast_amount
           , p_base_booked_amount
           , p_base_lost_amount
           , oki_load_wbc_pvt.g_request_id
           , oki_load_wbc_pvt.g_program_application_id
           , oki_load_wbc_pvt.g_program_id
           , oki_load_wbc_pvt.g_program_update_date ) ;


  EXCEPTION
    WHEN oki_load_wbc_pvt.g_excp_exit_immediate THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_TABLE_LOAD_FAILURE');

      fnd_message.set_token(  token => 'TABLE_NAME'
                            , value => 'OKI_WIP_BY_CUSTOMERS' );

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );

    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_TABLE_LOAD_FAILURE');

      fnd_message.set_token(  token => 'TABLE_NAME'
                            , value => 'OKI_WIP_BY_CUSTOMERS' );

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END ins_wip_by_cust ;

--------------------------------------------------------------------------------
  -- Procedure to update records in the oki_wip_by_customers table.

--------------------------------------------------------------------------------
  PROCEDURE upd_wip_by_cust
  (   p_base_forecast_amount IN  NUMBER
    , p_base_booked_amount   IN  NUMBER
    , p_base_lost_amount     IN  NUMBER
    , p_wbc_rowid            IN  ROWID
    , x_retcode              OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;


  BEGIN

    -- initialize return code to success
    x_retcode := '0';

    UPDATE oki_wip_by_customers SET
        base_forecast_amount    = p_base_forecast_amount
      , base_booked_amount      = p_base_booked_amount
      , base_lost_amount        = p_base_lost_amount
      , request_id              = oki_load_wbc_pvt.g_request_id
      , program_application_id  = oki_load_wbc_pvt.g_program_application_id
      , program_id              = oki_load_wbc_pvt.g_program_id
      , program_update_date     = oki_load_wbc_pvt.g_program_update_date
    WHERE ROWID = p_wbc_rowid ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_WBC_PVT.UPD_WIP_BY_CUST');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END upd_wip_by_cust ;

--------------------------------------------------------------------------------
  -- Procedure to calcuate the forecast and booked amounts for the
  -- customers.
  -- Calculates the amounts by each dimension:
  --   period set name
  --   period type
  --   period name
  --   customer
  --   subclass
  --   organization
  --
--------------------------------------------------------------------------------
  PROCEDURE calc_wbc_dtl1
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

  -- Holds the calculated forecast, booked and lost amounts
  l_base_forecast_amount  NUMBER := 0 ;
  l_base_booked_amount    NUMBER := 0 ;
  l_base_lost_amount      NUMBER := 0 ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;

  -- Cursor declaration

  -- Cursor that calculates the forecast amount for a particular customer,
  -- oganization and subclass
  CURSOR l_cust_fcst_csr
  (   p_glpr_start_date   IN DATE
    , p_glpr_end_date     IN DATE
    , p_authoring_org_id  IN NUMBER
    , p_customer_party_id IN NUMBER
    , p_scs_code          IN VARCHAR2
  ) IS
    SELECT     NVL(SUM(shd.base_forecast_amount), 0) base_forecast_amount
    FROM       oki_sales_k_hdrs shd
    -- Contract is a renewal contract
    WHERE      shd.is_new_yn   IS NULL
    -- Contract must have undergone forecasting
    AND        shd.close_date  IS NOT NULL
    AND        shd.win_percent IS NOT NULL
    -- Expected close date is in the period
    AND        shd.close_date BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND        shd.customer_party_id = p_customer_party_id
    AND        shd.authoring_org_id  = p_authoring_org_id
    AND        shd.scs_code          = p_scs_code
    ;
  rec_l_cust_fcst_csr l_cust_fcst_csr%ROWTYPE ;

  -- Cursor that calculates the booked amount for a particular customer,
  -- oganization and subclass
  CURSOR l_cust_booked_csr
  (   p_glpr_start_date   IN DATE
    , p_glpr_end_date     IN DATE
    , p_authoring_org_id  IN NUMBER
    , p_customer_party_id IN NUMBER
    , p_scs_code          IN VARCHAR
  ) IS
    SELECT     NVL(SUM(shd.base_contract_amount), 0) base_contract_amount
    FROM       oki_sales_k_hdrs shd
    -- Contract is a renewal contract
    WHERE      shd.is_new_yn IS NULL
    -- Contract is signed or active
    AND        shd.ste_code  IN ('SIGNED', 'ACTIVE')
    -- Lesser of the signed date or the start date falls within
    -- the period
    AND        LEAST(NVL(shd.date_signed, shd.start_date),shd.start_date)
                     BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND        shd.customer_party_id = p_customer_party_id
    AND        shd.authoring_org_id  = p_authoring_org_id
    AND        shd.scs_code          = p_scs_code
    ;
  rec_l_cust_booked_csr l_cust_booked_csr%ROWTYPE ;

  -- Cursor that calculates the lost amount for a particular customer,
  -- oganization and subclass
  CURSOR l_cust_lost_csr
  (   p_glpr_start_date   IN DATE
    , p_glpr_end_date     IN DATE
    , p_authoring_org_id  IN NUMBER
    , p_customer_party_id IN NUMBER
    , p_scs_code          IN VARCHAR
  ) IS
    SELECT     NVL(SUM(cpl.base_price_negotiated), 0) base_price_negotiated
    /*11510 change removed oki_Expired_lines and joined to oki_cov_prd_lines*/
    FROM       oki_cov_prd_lines cpl
             , oki_sales_k_hdrs shd
    WHERE      shd.chr_id            = cpl.chr_id
    /*11510 change start*/
    AND        cpl.is_exp_not_renewed_yn='Y'
    /*11510 change start*/
    -- expiration date is in the period
    AND        cpl.end_date BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND        shd.customer_party_id = p_customer_party_id
    AND        shd.authoring_org_id  = p_authoring_org_id
    AND        shd.scs_code          = p_scs_code ;
    rec_l_cust_lost_csr l_cust_lost_csr%ROWTYPE ;

  -- Cursor to get all the customers, oganizations and subclasses
  CURSOR l_cust_id_csr IS
    SELECT DISTINCT(shd.customer_party_id) customer_id
           , /*11510 change*/ NULL customer_name
           , shd.authoring_org_id authoring_org_id
           , /*11510 change*/ NULL authoring_org_name
           , shd.scs_code scs_code
    FROM   oki_sales_k_hdrs shd
  ;


  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    l_loc := 'Looping through valid customers.' ;
    << l_cust_id_csr_loop >>
    -- Loop through all the customers to calcuate the appropriate amounts
    FOR rec_l_cust_id_csr IN l_cust_id_csr LOOP

      l_loc := 'Looping through valid periods.' ;
      << g_glpr_csr_loop >>
      -- Loop through all the periods
      FOR rec_g_glpr_csr IN oki_utl_pvt.g_glpr_csr(
          p_period_set_name, p_period_type, p_summary_build_date ) LOOP

        -- Get the truncated gl_periods start and end dates
        l_glpr_start_date := trunc(rec_g_glpr_csr.start_date );
        l_glpr_end_date   := trunc(rec_g_glpr_csr.end_date );

        -- Re-initialize the amounts before calculating
        l_base_forecast_amount := 0 ;
        l_base_booked_amount   := 0 ;
        l_base_lost_amount     := 0 ;

        l_loc := 'Opening cursor to determine the forecast sum.' ;
        -- Calculate the forecast amount for a given customer
        OPEN  l_cust_fcst_csr( l_glpr_start_date, l_glpr_end_date,
              rec_l_cust_id_csr.authoring_org_id,
              rec_l_cust_id_csr.customer_id, rec_l_cust_id_csr.scs_code ) ;
        FETCH l_cust_fcst_csr INTO rec_l_cust_fcst_csr ;
          IF l_cust_fcst_csr%FOUND THEN
            l_base_forecast_amount := rec_l_cust_fcst_csr.base_forecast_amount ;
          END IF ;
        CLOSE l_cust_fcst_csr ;

        l_loc := 'Opening cursor to determine the booked sum.' ;
        -- Calculate the booked amount for a given customer
        OPEN  l_cust_booked_csr( l_glpr_start_date, l_glpr_end_date,
              rec_l_cust_id_csr.authoring_org_id,
              rec_l_cust_id_csr.customer_id, rec_l_cust_id_csr.scs_code ) ;
        FETCH l_cust_booked_csr INTO rec_l_cust_booked_csr ;
          IF l_cust_booked_csr%FOUND THEN
            l_base_booked_amount := rec_l_cust_booked_csr.base_contract_amount ;
          END IF ;
        CLOSE l_cust_booked_csr ;

        l_loc := 'Opening cursor to determine the lost sum.' ;
        -- Calculate the lost amount for a given customer
        OPEN  l_cust_lost_csr( l_glpr_start_date, l_glpr_end_date,
              rec_l_cust_id_csr.authoring_org_id,
              rec_l_cust_id_csr.customer_id, rec_l_cust_id_csr.scs_code ) ;
        FETCH l_cust_lost_csr INTO rec_l_cust_lost_csr ;
          IF l_cust_lost_csr%FOUND THEN
            l_base_lost_amount := rec_l_cust_lost_csr.base_price_negotiated ;
          END IF ;
        CLOSE l_cust_lost_csr ;


        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN  oki_load_wbc_pvt.g_wbc_csr( rec_g_glpr_csr.period_set_name,
              rec_g_glpr_csr.period_name, rec_l_cust_id_csr.authoring_org_id,
               rec_l_cust_id_csr.customer_id, rec_l_cust_id_csr.scs_code ) ;
        FETCH oki_load_wbc_pvt.g_wbc_csr into rec_g_wbc_csr ;
          IF oki_load_wbc_pvt.g_wbc_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_wbc_pvt.ins_wip_by_cust(
                p_period_name          => rec_g_glpr_csr.period_name
              , p_period_set_name      => rec_g_glpr_csr.period_set_name
              , p_period_type          => rec_g_glpr_csr.period_type
              , p_authoring_org_id     => rec_l_cust_id_csr.authoring_org_id
              , p_authoring_org_name   => rec_l_cust_id_csr.authoring_org_name
              , p_customer_party_id    => rec_l_cust_id_csr.customer_id
              , p_customer_name        => rec_l_cust_id_csr.customer_name
              , p_scs_code             => rec_l_cust_id_csr.scs_code
              , p_base_forecast_amount => l_base_forecast_amount
              , p_base_booked_amount   => l_base_booked_amount
              , p_base_lost_amount     => l_base_lost_amount
              , x_retcode              => l_retcode) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_wbc_pvt.g_excp_exit_immediate ;
              EXIT ;
            END IF ;

          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_wbc_pvt.upd_wip_by_cust(
                p_base_forecast_amount => l_base_forecast_amount
              , p_base_booked_amount   => l_base_booked_amount
              , p_base_lost_amount     => l_base_lost_amount
              , p_wbc_rowid            => rec_g_wbc_csr.rowid
              , x_retcode              => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_wbc_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;

        CLOSE g_wbc_csr ;

      END LOOP g_glpr_csr_loop ;
    END LOOP l_cust_id_csr_loop ;

  EXCEPTION
    WHEN oki_load_wbc_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_WBC_PVT.CALC_WBC_DTL1');

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

  END calc_wbc_dtl1 ;

--------------------------------------------------------------------------------
  -- Procedure to calculate the forecast and booked amounts for the
  -- customers.
  -- Calculates the amounts across organizations:
  --   each period set name
  --   each period type
  --   each period name
  --   each customer
  --   each subclass
  --   all  organizations
  --
--------------------------------------------------------------------------------
  PROCEDURE calc_wbc_dtl2
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

  -- Holds the calculated forecast, booked and lost amounts
  l_base_forecast_amount  NUMBER := 0 ;
  l_base_booked_amount    NUMBER := 0 ;
  l_base_lost_amount      NUMBER := 0 ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;

  -- Cusror declaration

  -- Cursor that calculates the forecast amount for a particular customer
  -- and subclass
  CURSOR l_cust_fcst_csr
  (   p_glpr_start_date   IN DATE
    , p_glpr_end_date     IN DATE
    , p_customer_party_id IN NUMBER
    , p_scs_code          IN VARCHAR2
  ) IS
    SELECT     NVL(SUM(shd.base_forecast_amount), 0) base_forecast_amount
    FROM       oki_sales_k_hdrs shd
    -- Contract is a renewal contract
    WHERE      shd.is_new_yn   IS NULL
    -- Contract must have undergone forecasting
    AND        shd.close_date  IS NOT NULL
    AND        shd.win_percent IS NOT NULL
    -- Expected close date is in the period
    AND        shd.close_date BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND        shd.customer_party_id = p_customer_party_id
    AND        shd.scs_code          = p_scs_code
    ;
  rec_l_cust_fcst_csr l_cust_fcst_csr%ROWTYPE ;

  -- Cursor that calculates the booked amount for a particular customer
  -- and subclass
  CURSOR l_cust_booked_csr
  (   p_glpr_start_date   IN DATE
    , p_glpr_end_date     IN DATE
    , p_customer_party_id IN NUMBER
    , p_scs_code          IN VARCHAR2
  ) IS
    SELECT     NVL(SUM(shd.base_contract_amount), 0) base_contract_amount
    FROM       oki_sales_k_hdrs shd
    -- Contract is a renewal contract
    WHERE      shd.is_new_yn IS NULL
    -- Contract is signed or active
    AND        shd.ste_code  IN ('SIGNED', 'ACTIVE')
    -- Lesser of the signed date or the start date falls within
    -- the period
    AND        LEAST(NVL(shd.date_signed, shd.start_date), shd.start_date)
                     BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND        shd.customer_party_id = p_customer_party_id
    AND        shd.scs_code          = p_scs_code
    ;
    rec_l_cust_booked_csr l_cust_booked_csr%ROWTYPE ;

  -- Cursor that calculates the lost amount for a particular customer
  -- and subclass
  CURSOR l_cust_lost_csr
  (   p_glpr_start_date   IN DATE
    , p_glpr_end_date     IN DATE
    , p_customer_party_id IN NUMBER
    , p_scs_code          IN VARCHAR2
  ) IS
    SELECT     NVL(SUM(cpl.base_price_negotiated), 0) base_price_negotiated
    /*11510 change removed oki_Expired_lines and joined to oki_cov_prd_lines*/
    FROM       oki_cov_prd_lines cpl
             , oki_sales_k_hdrs shd
    -- expiration date is in the period
    WHERE      shd.chr_id            = cpl.chr_id
   /*11510 change start*/
    AND        cpl.is_exp_not_renewed_yn  = 'Y'
  /*11510 change end*/
    AND        cpl.end_date BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND        shd.customer_party_id = p_customer_party_id
    AND        shd.scs_code          = p_scs_code
    ;
    rec_l_cust_lost_csr l_cust_lost_csr%ROWTYPE ;

  -- Cusror to get all the customers
  CURSOR l_cust_id_csr IS
    SELECT DISTINCT(shd.customer_party_id) customer_id
           , /*11510 change*/NULL customer_name
           , shd.scs_code
    FROM   oki_sales_k_hdrs shd ;


  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    l_loc := 'Looping through valid customers.' ;
    << l_cust_id_csr_loop >>
    -- Loop through all the customers to calcuate the appropriate amounts
    FOR rec_l_cust_id_csr IN l_cust_id_csr LOOP

      l_loc := 'Looping through valid periods.' ;
      << g_glpr_csr_loop >>
      -- Loop through all the periods
      FOR rec_g_glpr_csr IN oki_utl_pvt.g_glpr_csr(
          p_period_set_name, p_period_type, p_summary_build_date ) LOOP

        -- Get the truncated gl_periods start and end dates
        l_glpr_start_date := trunc(rec_g_glpr_csr.start_date );
        l_glpr_end_date   := trunc(rec_g_glpr_csr.end_date );

        -- Re-initialize the amounts before calculating
        l_base_forecast_amount := 0 ;
        l_base_booked_amount   := 0 ;
        l_base_lost_amount     := 0 ;

        l_loc := 'Opening cursor to determine the forecast sum.' ;
        -- Calculate the forecast amount for a given customer
        OPEN  l_cust_fcst_csr( l_glpr_start_date, l_glpr_end_date,
              rec_l_cust_id_csr.customer_id, rec_l_cust_id_csr.scs_code ) ;
        FETCH l_cust_fcst_csr INTO rec_l_cust_fcst_csr ;
          IF l_cust_fcst_csr%FOUND THEN
            l_base_forecast_amount := rec_l_cust_fcst_csr.base_forecast_amount ;
          END IF ;
        CLOSE l_cust_fcst_csr ;

        l_loc := 'Opening cursor to determine the booked sum.' ;
        -- Calculate the booked amount for a given customer
        OPEN  l_cust_booked_csr( l_glpr_start_date, l_glpr_end_date,
              rec_l_cust_id_csr.customer_id, rec_l_cust_id_csr.scs_code ) ;
        FETCH l_cust_booked_csr INTO rec_l_cust_booked_csr ;
          IF l_cust_booked_csr%FOUND THEN
            l_base_booked_amount := rec_l_cust_booked_csr.base_contract_amount ;
          END IF ;
        CLOSE l_cust_booked_csr ;

        l_loc := 'Opening cursor to determine the lost sum.' ;
        -- Calculate the lost amount for a given customer
        OPEN  l_cust_lost_csr( l_glpr_start_date, l_glpr_end_date,
              rec_l_cust_id_csr.customer_id, rec_l_cust_id_csr.scs_code ) ;
        FETCH l_cust_lost_csr INTO rec_l_cust_lost_csr ;
          IF l_cust_lost_csr%FOUND THEN
            l_base_lost_amount := rec_l_cust_lost_csr.base_price_negotiated ;
          END IF ;
        CLOSE l_cust_lost_csr ;


        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN  oki_load_wbc_pvt.g_wbc_csr( rec_g_glpr_csr.period_set_name,
              rec_g_glpr_csr.period_name, oki_load_wbc_pvt.g_all_org_id,
               rec_l_cust_id_csr.customer_id, rec_l_cust_id_csr.scs_code ) ;
        FETCH oki_load_wbc_pvt.g_wbc_csr into rec_g_wbc_csr ;
          IF oki_load_wbc_pvt.g_wbc_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_wbc_pvt.ins_wip_by_cust(
                p_period_name          => rec_g_glpr_csr.period_name
              , p_period_set_name      => rec_g_glpr_csr.period_set_name
              , p_period_type          => rec_g_glpr_csr.period_type
              , p_authoring_org_id     => oki_load_wbc_pvt.g_all_org_id
              , p_authoring_org_name   => oki_load_wbc_pvt.g_all_org_name
              , p_customer_party_id    => rec_l_cust_id_csr.customer_id
              , p_customer_name        => rec_l_cust_id_csr.customer_name
              , p_scs_code             => rec_l_cust_id_csr.scs_code
              , p_base_forecast_amount => l_base_forecast_amount
              , p_base_booked_amount   => l_base_booked_amount
              , p_base_lost_amount     => l_base_lost_amount
              , x_retcode              => l_retcode) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_wbc_pvt.g_excp_exit_immediate ;
              EXIT ;
            END IF ;

          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_wbc_pvt.upd_wip_by_cust(
                p_base_forecast_amount => l_base_forecast_amount
              , p_base_booked_amount   => l_base_booked_amount
              , p_base_lost_amount     => l_base_lost_amount
              , p_wbc_rowid            => rec_g_wbc_csr.rowid
              , x_retcode              => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_wbc_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;

        CLOSE oki_load_wbc_pvt.g_wbc_csr ;

      END LOOP g_glpr_csr_loop ;
    END LOOP l_cust_id_csr_loop ;

  EXCEPTION
    WHEN oki_load_wbc_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_WBC_PVT.CALC_WBC_DTL2');

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

  END calc_wbc_dtl2 ;

--------------------------------------------------------------------------------
  -- Procedure to calculate the forecast and booked amounts for the
  -- customers.
  -- Calculates the amounts across organizations and subclasses
  --   each period set name
  --   each period type
  --   each period name
  --   each customer
  --   all  subclasses
  --   all  organizations
  --
--------------------------------------------------------------------------------
  PROCEDURE calc_wbc_sum
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

  -- Holds the calculated forecast, booked and lost amounts
  l_base_forecast_amount  NUMBER := 0 ;
  l_base_booked_amount    NUMBER := 0 ;
  l_base_lost_amount      NUMBER := 0 ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;

  -- Cusror declaration

  -- Cursor that calculates the forecast amount for a particular customer
  CURSOR l_cust_fcst_csr
  (   p_glpr_start_date   IN DATE
    , p_glpr_end_date     IN DATE
    , p_customer_party_id IN NUMBER
  ) IS
    SELECT     NVL(SUM(shd.base_forecast_amount), 0) base_forecast_amount
    FROM       oki_sales_k_hdrs shd
    -- Contract is a renewal contract
    WHERE      shd.is_new_yn   IS NULL
    -- Contract must have undergone forecasting
    AND        shd.close_date  IS NOT NULL
    AND        shd.win_percent IS NOT NULL
    -- Expected close date is in the period
    AND        shd.close_date BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND        shd.customer_party_id = p_customer_party_id
    ;
  rec_l_cust_fcst_csr l_cust_fcst_csr%ROWTYPE ;

  -- Cursor that calculates the booked amount for a particular customer
  CURSOR l_cust_booked_csr
  (   p_glpr_start_date   IN DATE
    , p_glpr_end_date     IN DATE
    , p_customer_party_id IN NUMBER
  ) IS
    SELECT     NVL(SUM(shd.base_contract_amount), 0) base_contract_amount
    FROM       oki_sales_k_hdrs shd
    -- Contract is a renewal contract
    WHERE      shd.is_new_yn IS NULL
    -- Contract is signed or active
    AND        shd.ste_code  IN ('SIGNED', 'ACTIVE')
    -- Lesser of the signed date or the start date falls within
    -- the period
    AND        LEAST(NVL(shd.date_signed, shd.start_date), shd.start_date)
                     BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND        shd.customer_party_id = p_customer_party_id
    ;
  rec_l_cust_booked_csr l_cust_booked_csr%ROWTYPE ;

  -- Cursor that calculates the lost amount for a particular customer
  CURSOR l_cust_lost_csr
  (   p_glpr_start_date   IN DATE
    , p_glpr_end_date     IN DATE
    , p_customer_party_id IN NUMBER
  ) IS
    SELECT     NVL(SUM(cpl.base_price_negotiated), 0)  base_price_negotiated
    /*11510 change removed oki_Expired_lines and joined to oki_cov_prd_lines*/
    FROM       oki_cov_prd_lines cpl
             , oki_sales_k_hdrs shd
    -- expiration date is in the period
    WHERE      shd.chr_id            = cpl.chr_id
   /*11510 change start*/
    AND        cpl.is_exp_not_renewed_yn  = 'Y'
  /*11510 change end*/
    AND        cpl.end_date BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND        shd.customer_party_id = p_customer_party_id
    ;
  rec_l_cust_lost_csr l_cust_lost_csr%ROWTYPE ;

  -- Cusror to get all the customers
  CURSOR l_cust_id_csr IS
    SELECT DISTINCT(shd.customer_party_id) customer_id,
           /*11510 Change*/ NULL customer_name
    FROM   oki_sales_k_hdrs shd
    ;


  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    l_loc := 'Looping through valid customers.' ;
    -- Loop through all the customers to calcuate the appropriate amounts
    FOR rec_l_cust_id_csr IN l_cust_id_csr LOOP

      l_loc := 'Looping through valid periods.' ;
      -- Loop through all the periods
      FOR rec_g_glpr_csr IN oki_utl_pvt.g_glpr_csr(
          p_period_set_name, p_period_type, p_summary_build_date ) LOOP

        -- Get the truncated gl_periods start and end dates
        l_glpr_start_date := trunc(rec_g_glpr_csr.start_date );
        l_glpr_end_date   := trunc(rec_g_glpr_csr.end_date );

        -- Re-initialize the amounts before calculating
        l_base_forecast_amount := 0 ;
        l_base_booked_amount   := 0 ;
        l_base_lost_amount     := 0 ;

        l_loc := 'Opening cursor to determine the forecast sum.' ;
        -- Calculate the forecast amount for a given customer
        OPEN  l_cust_fcst_csr( l_glpr_start_date, l_glpr_end_date,
              rec_l_cust_id_csr.customer_id ) ;
        FETCH l_cust_fcst_csr INTO rec_l_cust_fcst_csr ;
          IF l_cust_fcst_csr%FOUND THEN
            l_base_forecast_amount := rec_l_cust_fcst_csr.base_forecast_amount ;
          END IF ;
        CLOSE l_cust_fcst_csr ;

        l_loc := 'Opening cursor to determine the booked sum.' ;
        -- Calculate the booked amount for a given customer
        OPEN  l_cust_booked_csr( l_glpr_start_date, l_glpr_end_date,
              rec_l_cust_id_csr.customer_id ) ;
        FETCH l_cust_booked_csr INTO rec_l_cust_booked_csr ;
          IF l_cust_booked_csr%FOUND THEN
            l_base_booked_amount := rec_l_cust_booked_csr.base_contract_amount ;
          END IF ;
        CLOSE l_cust_booked_csr ;

        l_loc := 'Opening cursor to determine the lost sum.' ;
        -- Calculate the lost amount for a given customer
        OPEN  l_cust_lost_csr( l_glpr_start_date, l_glpr_end_date,
              rec_l_cust_id_csr.customer_id ) ;
        FETCH l_cust_lost_csr INTO rec_l_cust_lost_csr ;
          IF l_cust_lost_csr%FOUND THEN
            l_base_lost_amount := rec_l_cust_lost_csr.base_price_negotiated ;
          END IF ;
        CLOSE l_cust_lost_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN  oki_load_wbc_pvt.g_wbc_csr( rec_g_glpr_csr.period_set_name,
              rec_g_glpr_csr.period_name, oki_load_wbc_pvt.g_all_org_id,
              rec_l_cust_id_csr.customer_id,
              oki_load_wbc_pvt.g_all_scs_code ) ;
        FETCH oki_load_wbc_pvt.g_wbc_csr into rec_g_wbc_csr ;
          IF oki_load_wbc_pvt.g_wbc_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_wbc_pvt.ins_wip_by_cust(
                p_period_name          => rec_g_glpr_csr.period_name
              , p_period_set_name      => rec_g_glpr_csr.period_set_name
              , p_period_type          => rec_g_glpr_csr.period_type
              , p_authoring_org_id     => oki_load_wbc_pvt.g_all_org_id
              , p_authoring_org_name   => oki_load_wbc_pvt.g_all_org_name
              , p_customer_party_id    => rec_l_cust_id_csr.customer_id
              , p_customer_name        => rec_l_cust_id_csr.customer_name
              , p_scs_code             => oki_load_wbc_pvt.g_all_scs_code
              , p_base_forecast_amount => l_base_forecast_amount
              , p_base_booked_amount   => l_base_booked_amount
              , p_base_lost_amount     => l_base_lost_amount
              , x_retcode              => l_retcode) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_wbc_pvt.g_excp_exit_immediate ;
              EXIT ;
            END IF ;

          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_wbc_pvt.upd_wip_by_cust(
                p_base_forecast_amount => l_base_forecast_amount
              , p_base_booked_amount   => l_base_booked_amount
              , p_base_lost_amount     => l_base_lost_amount
              , p_wbc_rowid            => rec_g_wbc_csr.rowid
              , x_retcode              => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_wbc_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;

        CLOSE oki_load_wbc_pvt.g_wbc_csr ;

      END LOOP ;
    END LOOP ;

  EXCEPTION
    WHEN oki_load_wbc_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_WBC_PVT.CALC_WBC_SUM');

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

  END calc_wbc_sum ;

--------------------------------------------------------------------------------
  -- Procedure to create all the WIP by customer records.
  -- If an error is encountered in this procedure or subsequent procedures then
  -- rollback all changes.  Once the table is loaded and the data is committed
  -- the load is considered successful even if update of the oki_refreshs
  -- table failed.
--------------------------------------------------------------------------------
  PROCEDURE crt_wip_by_cust
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
  l_table_name      CONSTANT VARCHAR2(30) := 'OKI_WIP_BY_CUSTOMERS' ;


  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;


  BEGIN

    SAVEPOINT oki_load_wbc_pvt_crt_wip_cust ;

    -- initialize return code to success
    l_retcode := '0' ;
    x_retcode := '0' ;

    -- Procedure to calculate the amounts for each dimension
    oki_load_wbc_pvt.calc_wbc_dtl1(
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_wbc_pvt.g_excp_exit_immediate ;
    END IF ;

    -- Procedure to calculate the amounts across organizations
    oki_load_wbc_pvt.calc_wbc_dtl2(
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_wbc_pvt.g_excp_exit_immediate ;
    END IF ;

    -- Procedure to calculate the amounts across organizations
    -- and subclasses
    oki_load_wbc_pvt.calc_wbc_sum(
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_wbc_pvt.g_excp_exit_immediate ;
    END IF ;

    COMMIT ;

    SAVEPOINT oki_load_wbc_pvt_upd_refresh ;

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

      ROLLBACK to oki_load_wbc_pvt_upd_refresh ;

    WHEN oki_load_wbc_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

      ROLLBACK TO oki_load_wbc_pvt_crt_wip_cust ;

    WHEN OTHERS THEN

      l_sqlcode := sqlcode ;
      l_sqlerrm := sqlerrm ;

      -- Set return code to error
      x_retcode := '2' ;

      -- rollback all transactions
      ROLLBACK to oki_load_wbc_pvt_crt_wip_cust ;


      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_WBC_PVT.CRT_WIP_BY_CUST');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );

  end crt_wip_by_cust ;


BEGIN
  -- Initialize the global variables used to log this job run
  -- from concurrent manager
  g_request_id             :=  fnd_global.conc_request_id ;
  g_program_application_id :=  fnd_global.prog_appl_id ;
  g_program_id             :=  fnd_global.conc_program_id ;
  g_program_update_date    :=  SYSDATE ;

END oki_load_wbc_pvt ;

/
