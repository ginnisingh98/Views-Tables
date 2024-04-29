--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_FBO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_FBO_PVT" AS
/* $Header: OKIRFBOB.pls 115.21 2003/11/24 08:24:48 kbajaj ship $ */

--------------------------------------------------------------------------------
-- Modification History
-- 25-Aug-2001  mezra        Changed program to reflect the addition of
--                           new columns: authoring_org_id,
--                           authoring_org_name, and subclass code.
-- 10-Sep-2001  mezra        Added column value, All Categories, for summary
--                           level of all scs_code.
-- 18-Sep-2001  mezra        Moved fbo_csr from local cursor to global
--                           cursor since it is used by all the calc
--                           procedures.
-- 25-Sep-2001  mezra        Change usd_ columns to base_.
-- 22-Oct-2001  mezra        Changed All Categories value to -1.
-- 24-Oct-2001  mezra        Removed trunc on date columns to increase
--                           performance since index will be used.
-- 26-NOV-2002 rpotnuru      NOCOPY Changes
--
-- 29-oct-2003 axraghav      Modified l_org_id_csr in calc_fbo_Dtl and
--                           calc_fbo_sum to null out organization_name
--
--------------------------------------------------------------------------------

  -- Global exception declaration

  -- Generic exception to immediately exit the procedure
  g_excp_exit_immediate   EXCEPTION ;


  -- Global constant delcaration

  -- Constants for the all subclass record
  g_all_ctg_code CONSTANT VARCHAR2(30) := '-1' ;


  -- Global cursor declaration

  -- Cursor to retrieve the rowid for the selected record
  -- If a rowid is retrieved, then the record will be updated,
  -- else the record will be inserted.
  CURSOR g_fbo_csr
  (   p_period_set_name  IN VARCHAR2
    , p_period_name      IN VARCHAR2
    , p_authoring_org_id IN NUMBER
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT rowid
    FROM   oki_forecast_by_orgs fbo
    WHERE  fbo.period_set_name  = p_period_set_name
    AND    fbo.period_name      = p_period_name
    AND    fbo.authoring_org_id = p_authoring_org_id
    AND    fbo.scs_code         = p_scs_code
    ;
  rec_g_fbo_csr g_fbo_csr%ROWTYPE ;

--------------------------------------------------------------------------------
  -- Procedure to insert records into the oki_forecast_by_orgs table.

--------------------------------------------------------------------------------
  PROCEDURE ins_fcst_by_org
  (   p_period_name          IN  VARCHAR2
    , p_period_set_name      IN  VARCHAR2
    , p_period_type          IN  VARCHAR2
    , p_authoring_org_id     IN  NUMBER
    , p_authoring_org_name   IN  VARCHAR2
    , p_scs_code             IN  VARCHAR2
    , p_base_forecast_amount IN  NUMBER
    , p_base_booked_amount   IN  NUMBER
    , x_retcode              OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  l_sequence  NUMBER := NULL ;

  -- Cursor declaration
  CURSOR l_seq_num IS
    SELECT oki_forecast_by_orgs_s1.nextval seq
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

    INSERT INTO oki_forecast_by_orgs
    (        id
           , period_name
           , period_set_name
           , period_type
           , authoring_org_id
           , authoring_org_name
           , scs_code
           , base_forecast_amount
           , base_booked_amount
           , request_id
           , program_application_id
           , program_id
           , program_update_date )
    VALUES ( l_sequence
           , p_period_name
           , p_period_set_name
           , p_period_type
           , p_authoring_org_id
           , p_authoring_org_name
           , p_scs_code
           , p_base_forecast_amount
           , p_base_booked_amount
           , oki_load_fbo_pvt.g_request_id
           , oki_load_fbo_pvt.g_program_application_id
           , oki_load_fbo_pvt.g_program_id
           , oki_load_fbo_pvt.g_program_update_date ) ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_TABLE_LOAD_FAILURE');

      fnd_message.set_token(  token => 'TABLE_NAME'
                            , value => 'OKI_FORECAST_BY_ORGS');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END ins_fcst_by_org ;

--------------------------------------------------------------------------------
  -- Procedure to update records in the oki_forecast_by_orgs table.

--------------------------------------------------------------------------------
  PROCEDURE upd_fcst_by_org
  (   p_base_forecast_amount IN  NUMBER
    , p_base_booked_amount   IN  NUMBER
    , p_fbo_rowid            IN  ROWID
    , x_retcode              OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;


  BEGIN

    -- initialize return code to success
    x_retcode := '0';

    UPDATE oki_forecast_by_orgs SET
        base_forecast_amount   = p_base_forecast_amount
      , base_booked_amount     = p_base_booked_amount
      , request_id             = oki_load_fbo_pvt.g_request_id
      , program_application_id = oki_load_fbo_pvt.g_program_application_id
      , program_id             = oki_load_fbo_pvt.g_program_id
      , program_update_date    = oki_load_fbo_pvt.g_program_update_date
    WHERE ROWID =  p_fbo_rowid ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_UPD_FCST_BY_ORG');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END upd_fcst_by_org ;

--------------------------------------------------------------------------------
  -- Procedure to calculate the forecast and booked amounts for the
  -- organizations.
  -- Calculates the amounts by each dimension:
  --   period set name
  --   period type
  --   period name
  --   subclass
  --   organization
  --
--------------------------------------------------------------------------------
  PROCEDURE calc_fbo_dtl1
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

  -- Holds the calculated forecast and booked amounts
  l_base_forecast_amount  NUMBER := 0 ;
  l_base_booked_amount    NUMBER := 0 ;

  -- holds the rowid of the record in the oki_forecast_by_orgs table
  l_fbo_rowid        ROWID ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;

  -- Cursor declaration

  -- Cursor to get all the organizations and subclasses
  CURSOR l_org_id_csr IS
    SELECT   DISTINCT shd.authoring_org_id org_id
           , /*11510 change */ NULL  organization_name
           , shd.scs_code
    FROM     oki_sales_k_hdrs shd
    ;

  -- Cursor that calculates the forecast amount for a
  -- particular organization and subclass
  CURSOR l_org_fcst_csr
  (   p_glpr_start_date  IN DATE
    , p_glpr_end_date    IN DATE
    , p_authoring_org_id IN NUMBER
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT     NVL(SUM(shd.base_forecast_amount), 0) base_forecast_amount
    FROM       oki_sales_k_hdrs shd
    -- Contract is a renewal contract
    WHERE      shd.is_new_yn        IS NULL
    -- Contract must have undergone forecasting
    AND        shd.close_date       IS NOT NULL
    AND        shd.win_percent      IS NOT NULL
    -- get forecast amount for a particular org
    AND        shd.authoring_org_id = p_authoring_org_id
    -- Expected close date is in the period
    AND        shd.close_date BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND        shd.scs_code   = p_scs_code
    ;
  rec_l_org_fcst_csr l_org_fcst_csr%ROWTYPE ;

  -- Cursor that calculates the booked amount for a
  -- particular organization and subclass
  CURSOR l_org_booked_csr
  (   p_glpr_start_date  IN DATE
    , p_glpr_end_date    IN DATE
    , p_authoring_org_id IN NUMBER
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT     NVL(SUM(shd.base_contract_amount), 0) base_contract_amount
    FROM       oki_sales_k_hdrs shd
    -- Contract is a renewal contract
    WHERE      shd.is_new_yn        IS NULL
    -- Contract is signed or active
    AND        shd.ste_code         IN ('SIGNED', 'ACTIVE')
    -- get booked amount for a particular org
    AND        shd.authoring_org_id = p_authoring_org_id
    -- Lesser of the signed DATE or the start date falls within
    -- the period
    AND        least(NVL(shd.date_signed, shd.start_date), shd.start_date)
                            BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND        shd.scs_code = p_scs_code
    ;
  rec_l_org_booked_csr l_org_booked_csr%ROWTYPE ;

  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    l_loc := 'Looping through valid organizations.' ;
    << l_org_id_csr_loop >>
    -- Loop through all the organizations to calcuate the
    -- appropriate amounts
    FOR rec_l_org_id_csr IN l_org_id_csr LOOP

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

        l_loc := 'Opening cursor to determine the forecast amount.' ;
        -- Calculate the forecast amount for a given organization
        << l_org_fcst_csr_loop >>
        OPEN  l_org_fcst_csr ( l_glpr_start_date, l_glpr_end_date,
              rec_l_org_id_csr.org_id, rec_l_org_id_csr.scs_code ) ;
        FETCH l_org_fcst_csr INTO rec_l_org_fcst_csr ;
          IF l_org_fcst_csr%FOUND THEN
            l_base_forecast_amount := rec_l_org_fcst_csr.base_forecast_amount ;
          END IF ;
        CLOSE l_org_fcst_csr ;

        l_loc := 'Opening cursor to determine the booked amount.' ;
        -- Calculate the booked amount for a given organization
        OPEN  l_org_booked_csr ( l_glpr_start_date, l_glpr_end_date,
              rec_l_org_id_csr.org_id, rec_l_org_id_csr.scs_code ) ;
        FETCH l_org_booked_csr INTO rec_l_org_booked_csr  ;
          IF l_org_booked_csr%FOUND THEN
            l_base_booked_amount := rec_l_org_booked_csr.base_contract_amount ;
          END IF ;
        CLOSE l_org_booked_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_fbo_pvt.g_fbo_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_id_csr.org_id,
             rec_l_org_id_csr.scs_code ) ;
        FETCH oki_load_fbo_pvt.g_fbo_csr INTO rec_g_fbo_csr ;
          IF oki_load_fbo_pvt.g_fbo_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_fbo_pvt.ins_fcst_by_org (
                p_period_name          => rec_g_glpr_csr.period_name
              , p_period_set_name      => rec_g_glpr_csr.period_set_name
              , p_period_type          => rec_g_glpr_csr.period_type
              , p_authoring_org_id     => rec_l_org_id_csr.org_id
              , p_authoring_org_name   => rec_l_org_id_csr.organization_name
              , p_scs_code             => rec_l_org_id_csr.scs_code
              , p_base_forecast_amount => l_base_forecast_amount
              , p_base_booked_amount   => l_base_booked_amount
              , x_retcode              => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_fbo_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_fbo_pvt.upd_fcst_by_org (
                p_base_forecast_amount => l_base_forecast_amount
              , p_base_booked_amount   => l_base_booked_amount
              , p_fbo_rowid            => rec_g_fbo_csr.rowid
              , x_retcode              => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_fbo_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_fbo_pvt.g_fbo_csr ;

      END LOOP g_glpr_csr_loop ;
   END LOOP l_org_id_csr_loop ;

  EXCEPTION
    WHEN oki_load_fbo_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_FBO_PVT.CALC_FBO_DTL1');

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
  END calc_fbo_dtl1 ;

--------------------------------------------------------------------------------
  -- Procedure to calculate the forecast and booked amounts for the
  -- organizations.
  -- Calculates the amounts across subclasses
  --   each period set name
  --   each period type
  --   each period name
  --   each status
  --   all  subclasses
  --   each organization
  --
--------------------------------------------------------------------------------
  PROCEDURE calc_fbo_sum
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

  -- Holds the calculated forecast and booked amounts
  l_base_forecast_amount  NUMBER := 0 ;
  l_base_booked_amount    NUMBER := 0 ;

  -- holds the rowid of the record in the oki_forecast_by_orgs table
  l_fbo_rowid        ROWID ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;

  -- Cusor declaration

  -- Cursor to get all the organizations
  CURSOR l_org_id_csr IS
    SELECT   DISTINCT shd.authoring_org_id org_id
           , /*11510 change*/ NULL  organization_name
    FROM     oki_sales_k_hdrs shd
    ;

  -- Cursor that calculates the forecast amount for a
  -- particular organization
  CURSOR l_org_fcst_csr
  (   p_glpr_start_date  IN DATE
    , p_glpr_end_date    IN DATE
    , p_authoring_org_id IN NUMBER
  ) IS
    SELECT     NVL(SUM(shd.base_forecast_amount), 0) base_forecast_amount
    FROM       oki_sales_k_hdrs shd
    -- Contract is a renewal contract
    WHERE      shd.is_new_yn        IS NULL
    -- Contract must have undergone forecasting
    AND        shd.close_date       IS NOT NULL
    AND        shd.win_percent      IS NOT NULL
    -- get forecast amount for a particular org
    AND        shd.authoring_org_id = p_authoring_org_id
    -- Expected close date is in the period
    AND        shd.close_date BETWEEN p_glpr_start_date AND p_glpr_end_date
    ;
  rec_l_org_fcst_csr l_org_fcst_csr%ROWTYPE ;

  -- Cursor that calculates the booked amount for a
  -- particular organization
  CURSOR l_org_booked_csr
  (   p_glpr_start_date  IN DATE
    , p_glpr_end_date    IN DATE
    , p_authoring_org_id IN NUMBER
  ) IS
    SELECT     NVL(SUM(shd.base_contract_amount), 0) base_contract_amount
    FROM       oki_sales_k_hdrs shd
    -- Contract is a renewal contract
    WHERE      shd.is_new_yn        IS NULL
    -- Contract is signed or active
    AND        shd.ste_code         IN ('SIGNED', 'ACTIVE')
    -- get booked amount for a particular org
    AND        shd.authoring_org_id = p_authoring_org_id
    -- Lesser of the signed DATE or the start date falls within
    -- the period
    AND        least(NVL(shd.date_signed, shd.start_date), shd.start_date)
                     BETWEEN p_glpr_start_date AND p_glpr_end_date
    ;
  rec_l_org_booked_csr l_org_booked_csr%ROWTYPE ;


  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    l_loc := 'Looping through valid organizations.' ;
    << l_org_id_csr_loop >>
    -- Loop through all the organizations to calcuate the
    -- appropriate amounts
    FOR rec_l_org_id_csr IN l_org_id_csr LOOP

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

        l_loc := 'Opening cursor to determine the forecast amount.' ;
        -- Calculate the forecast amount for a given organization
        OPEN  l_org_fcst_csr ( l_glpr_start_date, l_glpr_end_date,
              rec_l_org_id_csr.org_id ) ;
        FETCH l_org_fcst_csr INTO rec_l_org_fcst_csr ;
          IF l_org_fcst_csr%FOUND THEN
            l_base_forecast_amount := rec_l_org_fcst_csr.base_forecast_amount ;
          END IF ;
        CLOSE l_org_fcst_csr ;

        l_loc := 'Opening cursor to determine the booked amount.' ;
        -- Calculate the booked amount for a given organization
        OPEN  l_org_booked_csr ( l_glpr_start_date, l_glpr_end_date,
              rec_l_org_id_csr.org_id ) ;
        FETCH l_org_booked_csr INTO rec_l_org_booked_csr  ;
          IF l_org_booked_csr%FOUND THEN
            l_base_booked_amount := rec_l_org_booked_csr.base_contract_amount ;
          END IF ;
        CLOSE l_org_booked_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_fbo_pvt.g_fbo_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_id_csr.org_id,
             oki_load_fbo_pvt.g_all_ctg_code ) ;
        FETCH oki_load_fbo_pvt.g_fbo_csr INTO rec_g_fbo_csr ;
          IF oki_load_fbo_pvt.g_fbo_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_fbo_pvt.ins_fcst_by_org (
                p_period_name          => rec_g_glpr_csr.period_name
              , p_period_set_name      => rec_g_glpr_csr.period_set_name
              , p_period_type          => rec_g_glpr_csr.period_type
              , p_authoring_org_id     => rec_l_org_id_csr.org_id
              , p_authoring_org_name   => rec_l_org_id_csr.organization_name
              , p_scs_code             => oki_load_fbo_pvt.g_all_ctg_code
              , p_base_forecast_amount => l_base_forecast_amount
              , p_base_booked_amount   => l_base_booked_amount
              , x_retcode              => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_fbo_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_fbo_pvt.upd_fcst_by_org (
                p_base_forecast_amount => l_base_forecast_amount
              , p_base_booked_amount   => l_base_booked_amount
              , p_fbo_rowid            => rec_g_fbo_csr.rowid
              , x_retcode              => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_fbo_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_fbo_pvt.g_fbo_csr ;

      END LOOP g_glpr_csr_loop ;
   END LOOP l_org_id_csr_loop ;

  EXCEPTION
    WHEN oki_load_fbo_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_FBO_PVT.CALC_FBO_SUM');

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
  END calc_fbo_sum ;

--------------------------------------------------------------------------------
  -- Procedure to create all the forecast by organization records.  If an
  -- error is encountered in this procedure or subsequent procedures then
  -- rollback all changes.  Once the table is loaded and the data is committed
  -- the load is considered successful even if update of the oki_refreshs
  -- table failed.
--------------------------------------------------------------------------------
  PROCEDURE crt_fcst_org
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
  l_table_name  CONSTANT VARCHAR2(30) := 'OKI_FORECAST_BY_ORGS' ;


  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;


  BEGIN

    SAVEPOINT oki_load_fbo_pvt_crt_fcst_org ;

    -- initialize return code to success
    l_retcode := '0' ;
    x_retcode := '0' ;

    -- Procedure to calculate the amounts for each dimension
    -- and subclass
    oki_load_fbo_pvt.calc_fbo_dtl1 (
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_fbo_pvt.g_excp_exit_immediate ;
    END IF ;

    -- Procedure to calculate the amounts across subclasses
    oki_load_fbo_pvt.calc_fbo_sum (
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_fbo_pvt.g_excp_exit_immediate ;
    END IF ;

    COMMIT;

    SAVEPOINT oki_load_fbo_pvt_upd_refresh ;


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

      ROLLBACK to oki_load_fbo_pvt_upd_refresh ;

    WHEN oki_load_fbo_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

      ROLLBACK TO oki_load_fbo_pvt_crt_fcst_org ;

    WHEN OTHERS THEN

      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2' ;

      -- ROLLBACK all transactions
      ROLLBACK TO oki_load_fbo_pvt_crt_fcst_org ;


      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_FBO_PVT.CRT_FCST_ORG');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );

  END crt_fcst_org ;


BEGIN
  -- Initialize the global variables used to log this job run
  -- FROM concurrent manager
  g_request_id             :=  fnd_global.conc_request_id ;
  g_program_application_id :=  fnd_global.prog_appl_id ;
  g_program_id             :=  fnd_global.conc_program_id ;
  g_program_update_date    :=  SYSDATE ;

END oki_load_fbo_pvt ;

/
