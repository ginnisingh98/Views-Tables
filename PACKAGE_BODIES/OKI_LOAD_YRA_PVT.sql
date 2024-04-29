--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_YRA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_YRA_PVT" AS
/* $Header: OKIRYRAB.pls 115.9 2003/11/24 08:25:20 kbajaj ship $ */

--------------------------------------------------------------------------------
-- Modification History
-- 19-Sep-2001  mezra        Initial version
-- 25-Sep-2001  mezra        Change usd_ columns to base_.
-- 22-Oct-2001  mezra        Changed All Categories value to -1.
-- 26-Nov-2002  rpotnuru     NOCOPY Changes
-- 19-Dec-2002  brrao        UTF-8 Changes to Org Name
-- 30-Dec-2002  mezra        Change logic for populating month value from the
--                           meaning to the numeric value.
--
-- 29-Oct-2003  axraghav     Modified l_org_id_csr in calc_yra_dtl1 to
--                           populate null for organization_name
--------------------------------------------------------------------------------

  -- Global exception declaration

  -- Generic exception to immediately exit the procedure
  g_excp_exit_immediate   EXCEPTION ;


  -- Global constant delcaration

  -- Constants for the all organization and caetgory record
  g_all_org_id       CONSTANT NUMBER       := -1 ;
  g_all_org_name     CONSTANT VARCHAR2(240) := 'All Organizations' ;
  g_all_scs_code     CONSTANT VARCHAR2(30) := '-1' ;


  -- Global cursor declaration

  -- Cusror to retrieve the rowid for the selected record
  CURSOR g_yra_csr
  (   p_period_set_name  IN  VARCHAR2
    , p_period_name      IN  VARCHAR2
    , p_authoring_org_id IN  VARCHAR2
    , p_year             IN  VARCHAR2
    , p_month            IN  VARCHAR2
    , p_scs_code         IN  VARCHAR2
  ) IS
    SELECT rowid
    FROM   oki_yoy_renewal_amt yyr
    WHERE  yyr.period_set_name  = p_period_set_name
    AND    yyr.period_name      = p_period_name
    AND    yyr.authoring_org_id = p_authoring_org_id
    AND    yyr.year             = p_year
    AND    yyr.month            = p_month
    AND    yyr.scs_code         = p_scs_code
    ;
  rec_g_yra_csr g_yra_csr%ROWTYPE ;

--------------------------------------------------------------------------------
  -- Procedure to insert records into the oki_yoy_renewal_amt table.

--------------------------------------------------------------------------------
  PROCEDURE ins_yoy_rnwl
  (   p_period_set_name      IN  VARCHAR2
    , p_period_name          IN  VARCHAR2
    , p_period_type          IN  VARCHAR2
    , p_authoring_org_id     IN  NUMBER
    , p_authoring_org_name   IN  VARCHAR2
    , p_year                 IN  VARCHAR2
    , p_month                IN  VARCHAR2
    , p_scs_code             IN  VARCHAR2
    , p_base_contract_amount IN  NUMBER
    , x_retcode              OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  l_sequence  NUMBER := NULL ;

  -- Cursor declaration
  CURSOR l_seq_num IS
    SELECT oki_yoy_renewal_amt_s1.nextval seq
    FROM dual
    ;
  rec_l_seq_num l_seq_num%ROWTYPE ;

  BEGIN

    -- initialize return code to success
    x_retcode := '0';

    OPEN l_seq_num ;
    FETCH l_seq_num INTO rec_l_seq_num ;
      -- unable to generate sequence number, exit immediately
      IF l_seq_num%NOTFOUND THEN
        RAISE g_excp_exit_immediate ;
      END IF ;
      l_sequence := rec_l_seq_num.seq ;
    CLOSE l_seq_num ;

    INSERT INTO oki_yoy_renewal_amt
    (        id
           , period_set_name
           , period_name
           , period_type
           , authoring_org_id
           , authoring_org_name
           , year
           , month
           , scs_code
           , base_contract_amount
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
           , p_year
           , p_month
           , p_scs_code
           , p_base_contract_amount
           , oki_load_yra_pvt.g_request_id
           , oki_load_yra_pvt.g_program_application_id
           , oki_load_yra_pvt.g_program_id
           , oki_load_yra_pvt.g_program_update_date ) ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_TABLE_LOAD_FAILURE' );

      fnd_message.set_token(  token => 'TABLE_NAME'
                            , value => 'OKI_YOY_RENEWAL_AMT' );

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get );

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END ins_yoy_rnwl ;

--------------------------------------------------------------------------------
  -- Procedure to update records in the oki_yoy_renewal_amt table.

--------------------------------------------------------------------------------
  PROCEDURE upd_yoy_rnwl
  (   p_base_contract_amount IN  NUMBER
    , p_yra_rowid            IN  ROWID
    , x_retcode              OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;


  BEGIN

    -- initialize return code to success
    x_retcode := '0';

    UPDATE oki_yoy_renewal_amt SET
        base_contract_amount    = p_base_contract_amount
      , request_id             = oki_load_yra_pvt.g_request_id
      , program_application_id = oki_load_yra_pvt.g_program_application_id
      , program_id             = oki_load_yra_pvt.g_program_id
      , program_update_date    = oki_load_yra_pvt.g_program_update_date
    WHERE ROWID =  p_yra_rowid ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE' );

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_YRA_PVT.UPD_YOY_RNWL' );

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get );

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END upd_yoy_rnwl ;

--------------------------------------------------------------------------------
  -- Procedure to calcuate the contract amount for the current and previous
  -- year.

--------------------------------------------------------------------------------
  PROCEDURE calc_yra_dtl1
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

  l_base_contract_amount  NUMBER   := 0 ;
  l_year             VARCHAR2(4)   := NULL ;
  l_month            VARCHAR2 (20) := NULL ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;

  -- Cusor declaration

  -- Cursor to get all the organizations and subclasses
  CURSOR l_org_id_csr IS
    SELECT   DISTINCT shd.authoring_org_id authoring_org_id
           , /*11510 change*/ NULL  organization_name
           , shd.scs_code
    FROM     oki_sales_k_hdrs shd
    ;

  -- Cursor that calculates the contract amount for a
  -- particular organization and subclass
  CURSOR l_yoy_rnwl_csr
  (   p_glpr_start_date    IN DATE
    , p_glpr_end_date      IN DATE
    , p_authoring_org_id   IN NUMBER
    , p_scs_code           IN VARCHAR2
  ) IS
    SELECT     TO_CHAR(LEAST(NVL(shd.date_signed, shd.start_date),
                             shd.start_date), 'RRRR') year
             , TO_CHAR(LEAST(NVL(shd.date_signed, shd.start_date),
                             shd.start_date), 'FMMM') Month
             , SUM(shd.base_contract_amount ) base_contract_amount
    FROM       oki_sales_k_hdrs shd
    WHERE    LEAST(NVL(shd.date_signed, shd.start_date), shd.start_date)
                 BETWEEN ADD_MONTHS((last_day(p_glpr_start_date) + 1), -24)
                     AND last_day(p_glpr_end_date)
    AND      shd.is_new_yn           IS NULL
    AND      shd.date_signed         IS NOT NULL
    AND      shd.authoring_org_id  = p_authoring_org_id
    AND      shd.scs_code          = p_scs_code
    GROUP BY   TO_CHAR(LEAST(NVL(shd.date_signed, shd.start_date),
                             shd.start_date), 'RRRR')
             , TO_CHAR(least(nvl(shd.date_signed, shd.start_date),
                             shd.start_date), 'FMMM')
    ;
  rec_l_yoy_rnwl_csr l_yoy_rnwl_csr%ROWTYPE ;

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
        l_base_contract_amount := 0 ;
        l_year                 := NULL ;
        l_month                := NULL ;

        l_loc := 'Opening cursor to determine the yoy renewal amount.' ;
        << l_yoy_rnwl_csr_loop >>
        -- Calculate the yoy renewal amount
        FOR rec_l_yoy_rnwl_csr IN l_yoy_rnwl_csr ( l_glpr_start_date,
            l_glpr_end_date, rec_l_org_id_csr.authoring_org_id,
            rec_l_org_id_csr.scs_code ) LOOP
          l_base_contract_amount := rec_l_yoy_rnwl_csr.base_contract_amount ;
          l_year                 := rec_l_yoy_rnwl_csr.year ;
          l_month                := rec_l_yoy_rnwl_csr.month ;

          l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
          -- Determine if the record is a new one or an existing one
          OPEN oki_load_yra_pvt.g_yra_csr ( rec_g_glpr_csr.period_set_name,
               rec_g_glpr_csr.period_name, rec_l_org_id_csr.authoring_org_id,
               l_year, l_month, rec_l_org_id_csr.scs_code ) ;
          FETCH oki_load_yra_pvt.g_yra_csr INTO rec_g_yra_csr ;
            IF oki_load_yra_pvt.g_yra_csr%NOTFOUND THEN
              l_loc := 'Insert the new record.' ;
              -- Insert the current period data for the period
              oki_load_yra_pvt.ins_yoy_rnwl (
                  p_period_set_name      => rec_g_glpr_csr.period_set_name
                , p_period_name          => rec_g_glpr_csr.period_name
                , p_period_type          => rec_g_glpr_csr.period_type
                , p_authoring_org_id     => rec_l_org_id_csr.authoring_org_id
                , p_authoring_org_name   => rec_l_org_id_csr.organization_name
                , p_year                 => l_year
                , p_month                => l_month
                , p_scs_code             => rec_l_org_id_csr.scs_code
                , p_base_contract_amount => l_base_contract_amount
                , x_retcode              => l_retcode ) ;
              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_yra_pvt.g_excp_exit_immediate ;
              END IF ;
            ELSE
              l_loc := 'Update the existing record.' ;
              -- Record already exists, so perform an update
              oki_load_yra_pvt.upd_yoy_rnwl (
                  p_base_contract_amount => l_base_contract_amount
                , p_yra_rowid            => rec_g_yra_csr.rowid
                , x_retcode              => l_retcode ) ;
              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_yra_pvt.g_excp_exit_immediate ;
              END IF ;
            END IF ;
          CLOSE oki_load_yra_pvt.g_yra_csr ;

        END LOOP l_yoy_rnwl_csr_loop ;
      END LOOP g_glpr_csr_loop ;
    END LOOP l_org_id_csr_loop ;

  EXCEPTION
    WHEN oki_load_yra_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_YRA_PVT.CALC_YRA_DTL1');

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
  END calc_yra_dtl1 ;


--------------------------------------------------------------------------------
  -- Procedure to calcuate the contract amount for the current and previous
  -- year.

--------------------------------------------------------------------------------
  PROCEDURE calc_yra_dtl2
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

  l_base_contract_amount  NUMBER   := 0 ;
  l_year             VARCHAR2(4)   := NULL ;
  l_month            VARCHAR2 (20) := NULL ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;

  -- Cusor declaration

  -- Cursor to get all the organizations and subclasses
  CURSOR l_scs_csr IS
    SELECT   distinct shd.scs_code
    FROM     oki_sales_k_hdrs shd
    ;

  -- Cursor that calculates the contract amount for a
  -- particular subclass
  CURSOR l_yoy_rnwl_csr
  (   p_glpr_start_date    IN DATE
    , p_glpr_end_date      IN DATE
    , p_scs_code           IN VARCHAR2
  ) IS
    SELECT     TO_CHAR(LEAST(NVL(shd.date_signed, shd.start_date),
                             shd.start_date), 'RRRR') year
             , TO_CHAR(LEAST(NVL(shd.date_signed, shd.start_date),
                             shd.start_date), 'FMMM') Month
             , SUM(shd.base_contract_amount ) base_contract_amount
    FROM       oki_sales_k_hdrs shd
    WHERE    LEAST(NVL(shd.date_signed, shd.start_date), shd.start_date)
                 BETWEEN ADD_MONTHS((last_day(p_glpr_start_date) + 1), -24)
                     AND last_day(p_glpr_end_date)
    AND      shd.is_new_yn           IS NULL
    AND      shd.date_signed         IS NOT NULL
    AND      shd.scs_code            = p_scs_code
    GROUP BY   TO_CHAR(LEAST(NVL(shd.date_signed, shd.start_date),
                             shd.start_date), 'RRRR')
             , TO_CHAR(least(nvl(shd.date_signed, shd.start_date),
                             shd.start_date), 'FMMM')
    ;
  rec_l_yoy_rnwl_csr l_yoy_rnwl_csr%ROWTYPE ;

  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    l_loc := 'Looping through valid organizations.' ;
    << l_org_id_csr_loop >>
    -- Loop through all the organizations to calcuate the
    -- appropriate amounts
    FOR rec_l_scs_csr IN l_scs_csr LOOP

      l_loc := 'Looping through valid periods.' ;
      << g_glpr_csr_loop >>
      -- Loop through all the periods
      FOR rec_g_glpr_csr IN oki_utl_pvt.g_glpr_csr(
          p_period_set_name, p_period_type, p_summary_build_date ) LOOP

        -- Get the truncated gl_periods start and end dates
        l_glpr_start_date := trunc(rec_g_glpr_csr.start_date );
        l_glpr_end_date   := trunc(rec_g_glpr_csr.end_date );

        -- Re-initialize the amounts before calculating
        l_base_contract_amount := 0 ;
        l_year                 := NULL ;
        l_month                := NULL ;

        l_loc := 'Opening cursor to determine the yoy renewal amount.' ;
        << l_yoy_rnwl_csr_loop >>
        -- Calculate the yoy renewal amount
        FOR rec_l_yoy_rnwl_csr IN l_yoy_rnwl_csr ( l_glpr_start_date,
            l_glpr_end_date,
            rec_l_scs_csr.scs_code ) LOOP
          l_base_contract_amount := rec_l_yoy_rnwl_csr.base_contract_amount ;
          l_year                 := rec_l_yoy_rnwl_csr.year ;
          l_month                := rec_l_yoy_rnwl_csr.month ;

          l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
          -- Determine if the record is a new one or an existing one
          OPEN oki_load_yra_pvt.g_yra_csr ( rec_g_glpr_csr.period_set_name,
               rec_g_glpr_csr.period_name, oki_load_yra_pvt.g_all_org_id,
               l_year, l_month, rec_l_scs_csr.scs_code ) ;
          FETCH oki_load_yra_pvt.g_yra_csr INTO rec_g_yra_csr ;
            IF oki_load_yra_pvt.g_yra_csr%NOTFOUND THEN
              l_loc := 'Insert the new record.' ;
              -- Insert the current period data for the period
              oki_load_yra_pvt.ins_yoy_rnwl (
                  p_period_set_name      => rec_g_glpr_csr.period_set_name
                , p_period_name          => rec_g_glpr_csr.period_name
                , p_period_type          => rec_g_glpr_csr.period_type
                , p_authoring_org_id     => oki_load_yra_pvt.g_all_org_id
                , p_authoring_org_name   => oki_load_yra_pvt.g_all_org_name
                , p_year                 => l_year
                , p_month                => l_month
                , p_scs_code             => rec_l_scs_csr.scs_code
                , p_base_contract_amount => l_base_contract_amount
                , x_retcode              => l_retcode ) ;
              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_yra_pvt.g_excp_exit_immediate ;
              END IF ;
            ELSE
              l_loc := 'Update the existing record.' ;
              -- Record already exists, so perform an update
              oki_load_yra_pvt.upd_yoy_rnwl (
                  p_base_contract_amount => l_base_contract_amount
                , p_yra_rowid            => rec_g_yra_csr.rowid
                , x_retcode              => l_retcode ) ;
              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_yra_pvt.g_excp_exit_immediate ;
              END IF ;
            END IF ;
          CLOSE oki_load_yra_pvt.g_yra_csr ;

        END LOOP l_yoy_rnwl_csr_loop ;
      END LOOP g_glpr_csr_loop ;
    END LOOP l_org_id_csr_loop ;

  EXCEPTION
    WHEN oki_load_yra_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_YRA_PVT.CALC_YRA_DTL2');

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
  END calc_yra_dtl2 ;

--------------------------------------------------------------------------------
  -- Procedure to calcuate the contract amount for the current and previous
  -- year.

--------------------------------------------------------------------------------
  PROCEDURE calc_yra_sum
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

  l_base_contract_amount  NUMBER   := 0 ;
  l_year             VARCHAR2(4)   := NULL ;
  l_month            VARCHAR2 (20) := NULL ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;

  -- Cusor declaration

  -- Cursor that calculates the contract amount
  CURSOR l_yoy_rnwl_csr
  (   p_glpr_start_date    IN DATE
    , p_glpr_end_date      IN DATE
  ) IS
    SELECT     TO_CHAR(LEAST(NVL(shd.date_signed, shd.start_date),
                             shd.start_date), 'RRRR') year
             , TO_CHAR(LEAST(NVL(shd.date_signed, shd.start_date),
                             shd.start_date), 'FMMM') Month
             , SUM(shd.base_contract_amount ) base_contract_amount
    FROM       oki_sales_k_hdrs shd
    WHERE    LEAST(NVL(shd.date_signed, shd.start_date), shd.start_date)
                 BETWEEN ADD_MONTHS((last_day(p_glpr_start_date) + 1), -24)
                     AND last_day(p_glpr_end_date)
    AND      shd.is_new_yn           IS NULL
    AND      shd.date_signed         IS NOT NULL
    GROUP BY   TO_CHAR(LEAST(NVL(shd.date_signed, shd.start_date),
                             shd.start_date), 'RRRR')
             , TO_CHAR(least(nvl(shd.date_signed, shd.start_date),
                             shd.start_date), 'FMMM')
;
  rec_l_yoy_rnwl_csr l_yoy_rnwl_csr%ROWTYPE ;

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

      -- Get the truncated gl_periods start and end dates
      l_glpr_start_date := trunc(rec_g_glpr_csr.start_date );
      l_glpr_end_date   := trunc(rec_g_glpr_csr.end_date );

      -- Re-initialize the amounts before calculating
      l_base_contract_amount := 0 ;
      l_year                 := NULL ;
      l_month                := NULL ;

      l_loc := 'Opening cursor to determine the yoy renewal amount.' ;
      << l_yoy_rnwl_csr_loop >>
      -- Calculate the yoy renewal amount
      FOR rec_l_yoy_rnwl_csr IN l_yoy_rnwl_csr ( l_glpr_start_date,
          l_glpr_end_date ) LOOP
        l_base_contract_amount := rec_l_yoy_rnwl_csr.base_contract_amount ;
        l_year                 := rec_l_yoy_rnwl_csr.year ;
        l_month                := rec_l_yoy_rnwl_csr.month ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_yra_pvt.g_yra_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_yra_pvt.g_all_org_id,
             l_year, l_month, oki_load_yra_pvt.g_all_scs_code ) ;
        FETCH oki_load_yra_pvt.g_yra_csr INTO rec_g_yra_csr ;
          IF oki_load_yra_pvt.g_yra_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_yra_pvt.ins_yoy_rnwl (
                p_period_set_name      => rec_g_glpr_csr.period_set_name
              , p_period_name          => rec_g_glpr_csr.period_name
              , p_period_type          => rec_g_glpr_csr.period_type
              , p_authoring_org_id     => oki_load_yra_pvt.g_all_org_id
              , p_authoring_org_name   => oki_load_yra_pvt.g_all_org_name
              , p_year                 => l_year
              , p_month                => l_month
              , p_scs_code             => oki_load_yra_pvt.g_all_scs_code
              , p_base_contract_amount => l_base_contract_amount
              , x_retcode              => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_yra_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_yra_pvt.upd_yoy_rnwl (
                p_base_contract_amount => l_base_contract_amount
              , p_yra_rowid            => rec_g_yra_csr.rowid
              , x_retcode              => l_retcode ) ;
            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_yra_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_yra_pvt.g_yra_csr ;

      END LOOP l_yoy_rnwl_csr_loop ;

    END LOOP g_glpr_csr_loop ;


  EXCEPTION
    WHEN oki_load_yra_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_YRA_PVT.CALC_YRA_SUM');

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
  END calc_yra_sum ;
--------------------------------------------------------------------------------
  -- Procedure to create all the yoy renewal records.  If an
  -- error is encountered in this procedure or subsequent procedures then
  -- rollback all changes.  Once the table is loaded and the data is committed
  -- the load is considered successful even if update of the oki_refreshs
  -- table failed.
--------------------------------------------------------------------------------
  PROCEDURE crt_yoy_rnwl
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
  l_table_name  CONSTANT VARCHAR2(30) := 'OKI_YOY_RENEWAL_AMT' ;


  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;


  BEGIN

    SAVEPOINT oki_load_yra_pvt_crt_yoy_rnwl ;

    -- initialize return code to success
    l_retcode := '0' ;
    x_retcode := '0' ;

    -- Procedure to calculate the amounts for each dimension
    oki_load_yra_pvt.calc_yra_dtl1 (
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_yra_pvt.g_excp_exit_immediate ;
    END IF ;

    -- Procedure to calculate the amounts across organizations
    oki_load_yra_pvt.calc_yra_dtl2 (
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_yra_pvt.g_excp_exit_immediate ;
    END IF ;

    -- Procedure to calculate the amounts amounts across organizations,
    -- subclasses
    oki_load_yra_pvt.calc_yra_sum (
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_yra_pvt.g_excp_exit_immediate ;
    END IF ;

    COMMIT;

    SAVEPOINT oki_load_yra_pvt_upd_refresh ;


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

      ROLLBACK to oki_load_yra_pvt_upd_refresh ;

    WHEN oki_load_yra_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

      ROLLBACK TO oki_load_yra_pvt_crt_yoy_rnwl ;

    WHEN OTHERS THEN

      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2' ;

      -- ROLLBACK all transactions
      ROLLBACK TO oki_load_yra_pvt_crt_yoy_rnwl ;


      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_YRA_PVT.CRT_YOY_RNWL');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );

  END crt_yoy_rnwl ;


BEGIN
  -- Initialize the global variables used TO log this job run
  -- FROM concurrent manager
  g_request_id             :=  fnd_global.conc_request_id ;
  g_program_application_id :=  fnd_global.prog_appl_id ;
  g_program_id             :=  fnd_global.conc_program_id ;
  g_program_update_date    :=  SYSDATE ;

END oki_load_yra_pvt ;

/
