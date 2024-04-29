--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_OKV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_OKV_PVT" AS
/* $Header: OKIROKVB.pls 115.25 2003/11/24 08:24:54 kbajaj ship $ */

--------------------------------------------------------------------------------
-- Modification History
-- 25-Aug-2001  mezra        Changed program to reflect the addition of
--                           new columns: authoring_org_id,
--                           authoring_org_name, and subclass code.
-- 10-Sep-2001  mezra        Added column value, All Categories, for summary
--                           level of all scs_code; All Organizations, for
--                           summary level of all organizations.
-- 18-Sep-2001  mezra        Moved okv_csr from local cursor to global
--                           cursor since it is used by all the calc
--                           procedures.
-- 25-Sep-2001  mezra        Change usd_ columns to base_.
-- 22-Oct-2001  mezra        Changed All Categories value to -1.
-- 24-Oct-2001  mezra        Removed trunc on date columns to increase
--                           performance since index will be used.
-- 04-Apr-2002  mezra        Synched branh with mainline.
-- 26-NOV-2002  rpotnuru     NOCOPY Changes
-- 19-Dec-2002  brrao        UTF-8 Changes for Org Name
--
-- 29-OCT-2003  axraghav     Modified l_org_id_csr in OKIROKVB.pls to populate
--                           null for the orgnization names
--                           Modified the proceures calc_okv_dtl1,calc_okv_dtl2,
--                           calc_okv_sum to calculate the base price negotiated
--                           from oki_sales_k_hdrs table.
--------------------------------------------------------------------------------

  -- Global exception declaration

  -- Generic exception to immediately exit the procedure
  g_excp_exit_immediate   EXCEPTION ;


  -- Global constant delcaration

  -- Constants for the "All" organization and subclass record
  g_all_org_id   CONSTANT NUMBER       := -1 ;
  g_all_org_name CONSTANT VARCHAR2(240) := 'All Organizations' ;
  g_all_scs_code CONSTANT VARCHAR2(30) := '-1' ;

  g_base_currency     fnd_currencies.currency_code%TYPE :=
                        fnd_profile.value('OKI_BASE_CURRENCY');



  -- Global cursor declaration

  -- Cursor to get the FND_LOOKUPS code based on the lookup_type and code
  -- Retrieves the code representing the column label, e.g, if the days renewal
  -- outstanding is being retrieved for insertion into a table, then retrieve
  -- the corresponding code (DRO IN this example).
  -- Note:  The fnd_lookups.lookup_code is hard coded in this program.
  -- We use this cursor to verify the hard coded values before we use the
  -- actual value itself.

  CURSOR g_lkup_csr
  (   p_lookup_type IN VARCHAR2
     ,p_lookup_code IN VARCHAR2
  ) IS
    SELECT  lkup.lookup_code
    FROM    fnd_lookups lkup
    WHERE   lkup.lookup_type = p_lookup_type
    AND     lkup.lookup_code = p_lookup_code
    ;
  rec_g_lkup_csr g_lkup_csr%ROWTYPE ;

  -- Cursor to retrieve the rowid for the selected record
  -- If a rowid is retrieved, then the record will be updated,
  -- else the record will be inserted.
  CURSOR g_okv_csr
  (   p_period_set_name  IN VARCHAR2
    , p_period_name      IN VARCHAR2
    , p_authoring_org_id IN VARCHAR2
    , p_kpi_code         IN VARCHAR2
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT rowid
    FROM   oki_perf_measures okv
    WHERE  okv.period_set_name  = p_period_set_name
    AND    okv.period_name      = p_period_name
    AND    okv.authoring_org_id = p_authoring_org_id
    AND    okv.kpi_code         = p_kpi_code
    AND    okv.scs_code         = p_scs_code
    ;
  rec_g_okv_csr g_okv_csr%ROWTYPE ;

--------------------------------------------------------------------------------
  -- Procedure to insert records into the oki_perf_measures table.

--------------------------------------------------------------------------------

  PROCEDURE ins_perf_meas
  (   p_period_name        IN  VARCHAR2
    , p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_authoring_org_id   IN  NUMBER
    , p_authoring_org_name IN  VARCHAR2
    , p_kpi_code           IN  VARCHAR2
    , p_kpi_value          IN  NUMBER
    , p_scs_code           IN  VARCHAR2
    , x_retcode            OUT NOCOPY VARCHAR2
  ) IS


  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  l_sequence  NUMBER := NULL ;

  -- Cursor declaration
  CURSOR l_seq_num IS
    SELECT oki_perf_measures_s1.nextval seq
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
    x_retcode := '0' ;

    INSERT INTO oki_perf_measures
    (        id
           , period_set_name
           , period_name
           , period_type
           , authoring_org_id
           , authoring_org_name
           , kpi_code
           , kpi_value
           , scs_code
           , request_id
           , program_application_id
           , program_id
           , program_update_date  )
    VALUES ( l_sequence
           , p_period_set_name
           , p_period_name
           , p_period_type
           , p_authoring_org_id
           , p_authoring_org_name
           , p_kpi_code
           , p_kpi_value
           , p_scs_code
           , oki_load_okv_pvt.g_request_id
           , oki_load_okv_pvt.g_program_application_id
           , oki_load_okv_pvt.g_program_id
           , oki_load_okv_pvt.g_program_update_date ) ;

  EXCEPTION
    WHEN oki_load_okv_pvt.g_excp_exit_immediate THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_TABLE_LOAD_FAILURE');

      fnd_message.set_token(  token => 'TABLE_NAME'
                            , value => 'OKI_PERF_MEASURES');

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
                            , value => 'OKI_PERF_MEASURES');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );

  END ins_perf_meas ;

--------------------------------------------------------------------------------
  -- Procedure to update records in the oki_perf_measures table.

--------------------------------------------------------------------------------
  PROCEDURE upd_perf_meas
  (   p_kpi_value IN  NUMBER
    , p_okv_rowid IN  ROWID
    , x_retcode   OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;


  BEGIN

    -- initialize return code to success
    x_retcode := '0';

    UPDATE oki_perf_measures SET
        kpi_value              = p_kpi_value
      , request_id             = oki_load_okv_pvt.g_request_id
      , program_application_id = oki_load_okv_pvt.g_program_application_id
      , program_id             = oki_load_okv_pvt.g_program_id
      , program_update_date    = oki_load_okv_pvt.g_program_update_date
    WHERE ROWID = p_okv_rowid ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_OKV_PVT.OKI_UPD_PERF_MEAS');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END upd_perf_meas ;

--------------------------------------------------------------------------------
  -- Procedure to calculate the performance measures.
  -- Calculates the amounts by each dimension:
  --   period set name
  --   period type
  --   period name
  --   measure
  --   subclass
  --   organization
--------------------------------------------------------------------------------

  PROCEDURE calc_okv_dtl1
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , x_retcode            OUT NOCOPY VARCHAR2
  ) IS


  -- Constant declaration

  -- Codes for the performance measures in fnd_lookups
  l_hardcoded_dro_code   CONSTANT VARCHAR2(30) := 'DRO' ;
  l_hardcoded_fcacp_code CONSTANT VARCHAR2(30) := 'FCACP' ;
  l_hardcoded_cncs_code  CONSTANT VARCHAR2(30) := 'CNCS' ;
  l_lkup_type            CONSTANT VARCHAR2(30) := 'OKI_PERF_MEASURE_TYPES' ;


  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode          VARCHAR2(100)  := NULL ;
  l_sqlerrm          VARCHAR2(1000) := NULL ;

  -- Holds the calculated days renewal outstanding,
  -- forecast achievement % and the contracts consolidated values
  l_dro_value                 NUMBER := 0 ;
  l_base_achv_forecast_amount NUMBER := 0 ;
  l_base_achv_contract_amount NUMBER := 0 ;
  l_base_consolidated_amount  NUMBER := 0 ;
  l_achv_pct                  NUMBER := 0 ;

  -- Holds the code from the fnd_lookups table for the
  -- OKI_PERF_MEASURE_TYPES type
  l_dro_code   VARCHAR2(30) := NULL ;
  l_fcacp_code VARCHAR2(30) := NULL ;
  l_cncs_code  VARCHAR2(30) := NULL ;

  -- Location within the program before the error was encountered.
  l_loc        VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;


  -- Cursor declaration

  -- Cursor to get all the organizations and subclasses
  CURSOR l_org_id_csr IS
    SELECT   DISTINCT shd.authoring_org_id org_id
           , /*11510 change*/ NULL  organization_name
           , shd.scs_code
    FROM     oki_sales_k_hdrs shd
    ;

  -- Cursor that calculates the days renewals outstanding
  -- for a particular organization and subclass
  CURSOR l_dro_csr
  (   p_summary_build_date IN DATE
    , p_authoring_org_id   IN NUMBER
    , p_scs_code           IN VARCHAR2
  ) IS
    SELECT   ROUND(NVL(SUM(TRUNC(p_summary_build_date ) - TRUNC(shd.creation_date)), 0)
             / DECODE(COUNT(shd.chr_id), NULL, 1, 0, 1, COUNT(shd.chr_id)), 2) dro_value
    FROM     oki_sales_k_hdrs shd
    WHERE    shd.ste_code  = 'ENTERED'
    AND      shd.is_new_yn IS NULL
    AND      shd.authoring_org_id  = p_authoring_org_id
    AND      shd.scs_code          = p_scs_code
    ;
  rec_l_dro_csr l_dro_csr%ROWTYPE ;

  -- Cursor that calculates the contract amount portion for the
  -- forecast achievement % for a particular organization and subclass
  CURSOR l_achv_cntr_csr
  (   p_glpr_start_date  IN DATE
    , p_glpr_end_date    IN DATE
    , p_authoring_org_id IN NUMBER
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT NVL(SUM(shd.base_contract_amount), 0) base_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.ste_code    IN ('SIGNED', 'ACTIVE')
    AND    shd.win_percent IS NOT NULL
    AND    shd.close_date  IS NOT NULL
    AND    shd.close_date  BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND    shd.date_signed BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND    shd.is_new_yn   IS NULL
    AND    shd.authoring_org_id  = p_authoring_org_id
    AND    shd.scs_code          = p_scs_code
    ;
  rec_l_achv_cntr_csr l_achv_cntr_csr%ROWTYPE ;


  -- Cursor that calculates the forecast amount portion for the
  -- forecast achievement % for a particular organization and subclass
  CURSOR l_achv_fcst_csr
  (   p_glpr_start_date  IN DATE
    , p_glpr_end_date    IN DATE
    , p_authoring_org_id IN NUMBER
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT NVL(SUM(shd.base_forecast_amount), 0) base_forecast_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.ste_code    IN ('SIGNED', 'ACTIVE', 'ENTERED')
    AND    shd.win_percent IS NOT NULL
    AND    shd.close_date  IS NOT NULL
    AND    shd.close_date  BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND    shd.is_new_yn   IS NULL
    AND    shd.authoring_org_id = p_authoring_org_id
    AND    shd.scs_code         = p_scs_code
    ;
  rec_l_achv_fcst_csr l_achv_fcst_csr%ROWTYPE ;


  -- Cursor that calculates the contracts consolidated amount
  -- for a particular organization and subclass.
  -- Converts the contracts consolidated amount to base for insertion
  -- into the table
  CURSOR l_cntr_cnsl_csr
  (   p_glpr_start_date  IN DATE
    , p_glpr_end_date    IN DATE
    , p_authoring_org_id IN NUMBER
    , p_scs_code         IN VARCHAR2
  ) IS
    SELECT /*11510 changes removed NVL(SUM(cle.price_negotiated * odr.conversion_rate), 0) */ SUM(shd.base_contract_amount) base_price_negotiated
    FROM
           /* 11510 changes removed okc_k_lines_b cle */
           oki_sales_k_hdrs shd
         , okc_operation_lines ole
         , okc_operation_instances oie
         , okc_class_operations cop
        /*,11510 changes removed oki_daily_rates odr */
    -- Join lines to head to get currency code from header
    -- and convert the currency in base
    WHERE
    /*11510 changes comment out the following joins
      shd.chr_id        = cle.dnz_chr_id
    AND    odr.to_currency   = oki_load_okv_pvt.g_base_currency
    AND    odr.from_currency = nvl(cle.currency_code, shd.currency_code) */
    -- Get all consolidated contracts
           cop.opn_code      = 'REN_CON'
    AND    ole.process_flag  = 'P'
    -- Get all signed and active or contracts
    AND    shd.ste_code     IN ('SIGNED', 'ACTIVE')
    -- Get priced lines
 /*11510 changes removed the condition AND    cle.price_level_ind = 'Y' */
    -- Go from okc_k_lines_b to okc_class_operations
    AND    shd.chr_id       = ole.subject_chr_id
    AND    ole.oie_id       = oie.id
    AND    oie.cop_id       = cop.id
    AND    shd.date_signed  BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND    shd.is_new_yn    IS NULL
    AND    shd.authoring_org_id = p_authoring_org_id
    AND    shd.scs_code         = p_scs_code
    ;
  rec_l_cntr_cnsl_csr l_cntr_cnsl_csr%ROWTYPE ;

  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    l_loc := 'Opening cursor to determine days renewal outstanding code.' ;
    -- Validate the days renewal outstanding code
    OPEN oki_load_okv_pvt.g_lkup_csr( l_lkup_type, l_hardcoded_dro_code ) ;
    FETCH oki_load_okv_pvt.g_lkup_csr INTO rec_g_lkup_csr ;
      -- If there was not a valid DRO code then exit ;
      IF oki_load_okv_pvt.g_lkup_csr%NOTFOUND THEN
        RAISE g_excp_exit_immediate ;
      END IF ;
      l_dro_code := rec_g_lkup_csr.lookup_code ;
    CLOSE oki_load_okv_pvt.g_lkup_csr ;

    l_loc := 'Opening cursor to determine forecast achievement % code.' ;
    -- Validate the forecast achievement %
    OPEN oki_load_okv_pvt.g_lkup_csr( l_lkup_type, l_hardcoded_fcacp_code ) ;
    FETCH oki_load_okv_pvt.g_lkup_csr INTO rec_g_lkup_csr ;
      -- If there was not a valid FCACP code then exit ;
      IF oki_load_okv_pvt.g_lkup_csr%NOTFOUND THEN
        RAISE g_excp_exit_immediate ;
      END IF ;
      l_fcacp_code := rec_g_lkup_csr.lookup_code ;
    CLOSE oki_load_okv_pvt.g_lkup_csr ;

    l_loc := 'Opening cursor to determine contracts consolidated code.' ;
    -- Validate the contracts consolidate code
    OPEN oki_load_okv_pvt.g_lkup_csr( l_lkup_type, l_hardcoded_cncs_code ) ;
    FETCH oki_load_okv_pvt.g_lkup_csr INTO rec_g_lkup_csr ;
      -- If there was not a valid CNCS code then exit ;
      IF oki_load_okv_pvt.g_lkup_csr%NOTFOUND THEN
        RAISE g_excp_exit_immediate ;
      END IF ;
      l_cncs_code := rec_g_lkup_csr.lookup_code ;
    CLOSE oki_load_okv_pvt.g_lkup_csr ;


    l_loc := 'Looping through valid organizations.' ;
    << l_org_id_csr_loop >>
    -- Loop through all the organizations to calcuate the
    -- appropriate amounts
    FOR rec_l_org_id_csr IN l_org_id_csr LOOP

      l_loc := 'Looping through valid periods.' ;
      -- Loop through all the periods
      FOR rec_g_glpr_csr IN oki_utl_pvt.g_glpr_csr(
          p_period_set_name, p_period_type, p_summary_build_date ) LOOP

        -- Get the truncated gl_periods start and end dates
        l_glpr_start_date := trunc(rec_g_glpr_csr.start_date );
        l_glpr_end_date   := trunc(rec_g_glpr_csr.end_date );

        -- Re-initialize the amounts before calculating
        l_dro_value                 := 0 ;
        l_base_achv_forecast_amount := 0 ;
        l_base_achv_contract_amount := 0 ;
        l_base_consolidated_amount  := 0 ;

        l_loc := 'Opening cursor to determine the days renewal outstanding value.' ;
        << l_dro_csr_loop >>
        -- Calculate the days renewals outstanding
        FOR rec_l_dro_csr in l_dro_csr (p_summary_build_date,
            rec_l_org_id_csr.org_id, rec_l_org_id_csr.scs_code ) LOOP
          l_dro_value          := rec_l_dro_csr.dro_value ;

          l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
          -- Determine if the DRO record is a new one or an existing one
          OPEN oki_load_okv_pvt.g_okv_csr( rec_g_glpr_csr.period_set_name,
               rec_g_glpr_csr.period_name, rec_l_org_id_csr.org_id, l_dro_code,
               rec_l_org_id_csr.scs_code ) ;
          FETCH oki_load_okv_pvt.g_okv_csr INTO rec_g_okv_csr ;
            IF oki_load_okv_pvt.g_okv_csr%NOTFOUND THEN
              l_loc := 'Insert the new record.' ;
              l_loc := 'Update the existing record.' ;
              -- Insert the current period data for the period
              oki_load_okv_pvt.ins_perf_meas(
                   p_period_name        => rec_g_glpr_csr.period_name
                 , p_period_set_name    => rec_g_glpr_csr.period_set_name
                 , p_period_type        => rec_g_glpr_csr.period_type
                 , p_authoring_org_id   => rec_l_org_id_csr.org_id
                 , p_authoring_org_name => rec_l_org_id_csr.organization_name
                 , p_kpi_code           => l_dro_code
                 , p_kpi_value          => l_dro_value
                 , p_scs_code           => rec_l_org_id_csr.scs_code
                 , x_retcode            => l_retcode ) ;

              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
              END IF ;

            ELSE
              l_loc := 'Update the existing record.' ;
              -- Record already exists, so perform an update
              oki_load_okv_pvt.upd_perf_meas(
                  p_kpi_value => l_dro_value
                , p_okv_rowid => rec_g_okv_csr.rowid
                , x_retcode   => l_retcode ) ;

              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
              END IF ;

            END IF ;
          CLOSE oki_load_okv_pvt.g_okv_csr ;
        END LOOP l_dro_csr_loop ;


        l_loc := 'Opening cursor to determine the contract amount of FA %.' ;
        << l_achv_cntr_csr_loop >>
        -- Calculate the contract amount portion of the
        -- forecast achievement %
        FOR rec_l_achv_cntr_csr in l_achv_cntr_csr( l_glpr_start_date,
              l_glpr_end_date, rec_l_org_id_csr.org_id,
              rec_l_org_id_csr.scs_code   ) LOOP
          l_base_achv_contract_amount :=
                             rec_l_achv_cntr_csr.base_contract_amount ;

          l_loc := 'Opening cursor to determine the forecast amount of FA %.' ;
          -- Calculate the forecast amount portion of the
          -- forecast achievement %
          OPEN  l_achv_fcst_csr( l_glpr_start_date, l_glpr_end_date,
                rec_l_org_id_csr.org_id, rec_l_org_id_csr.scs_code ) ;
          FETCH l_achv_fcst_csr into rec_l_achv_fcst_csr ;
            IF l_achv_fcst_csr%FOUND THEN
              l_base_achv_forecast_amount :=
                                rec_l_achv_fcst_csr.base_forecast_amount ;
            END IF ;
          CLOSE l_achv_fcst_csr ;

          IF l_base_achv_forecast_amount = 0 THEN
            l_achv_pct := 0 ;
          ELSE
            -- Calculate the forecast achievement % and round to the nearest
            -- hundredth.
            l_achv_pct := ROUND(( l_base_achv_contract_amount /
                                l_base_achv_forecast_amount ) * 100, 2) ;
          END IF ;

          l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
          -- Determine if the FCACP record is a new one or an existing one
          OPEN oki_load_okv_pvt.g_okv_csr( rec_g_glpr_csr.period_set_name,
               rec_g_glpr_csr.period_name, rec_l_org_id_csr.org_id, l_fcacp_code,
               rec_l_org_id_csr.scs_code ) ;
          FETCH oki_load_okv_pvt.g_okv_csr INTO rec_g_okv_csr ;
            IF oki_load_okv_pvt.g_okv_csr%NOTFOUND THEN
              l_loc := 'Insert the new record.' ;
              -- Insert the current period data for the period
              oki_load_okv_pvt.ins_perf_meas(
                   p_period_name        => rec_g_glpr_csr.period_name
                 , p_period_set_name    => rec_g_glpr_csr.period_set_name
                 , p_period_type        => rec_g_glpr_csr.period_type
                 , p_authoring_org_id   => rec_l_org_id_csr.org_id
                 , p_authoring_org_name => rec_l_org_id_csr.organization_name
                 , p_kpi_code           => l_fcacp_code
                 , p_kpi_value          => l_achv_pct
                 , p_scs_code           => rec_l_org_id_csr.scs_code
                 , x_retcode            => l_retcode ) ;
              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
              END IF ;
            ELSE
              l_loc := 'Update the existing record.' ;
              -- Record already exists, so perform an update
              oki_load_okv_pvt.upd_perf_meas(
                  p_kpi_value => l_achv_pct
                , p_okv_rowid => rec_g_okv_csr.rowid
                , x_retcode   => l_retcode ) ;

              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
              END IF ;

            END IF ;
          CLOSE oki_load_okv_pvt.g_okv_csr ;
        END LOOP l_achv_cntr_csr_loop ;


        l_loc := 'Opening cursor to determine the contracts consilodated value.' ;
        << l_cntr_cnsl_csr_loop >>
        -- Calculate the contracts consolidated amount
        FOR rec_l_cntr_cnsl_csr IN l_cntr_cnsl_csr( l_glpr_start_date,
            l_glpr_end_date, rec_l_org_id_csr.org_id,
            rec_l_org_id_csr.scs_code ) LOOP

          l_base_consolidated_amount :=
                rec_l_cntr_cnsl_csr.base_price_negotiated ;

          l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
          -- Determine if the CNCS record is a new one or an existing one
          OPEN oki_load_okv_pvt.g_okv_csr( rec_g_glpr_csr.period_set_name,
               rec_g_glpr_csr.period_name, rec_l_org_id_csr.org_id, l_cncs_code,
               rec_l_org_id_csr.scs_code ) ;
          FETCH oki_load_okv_pvt.g_okv_csr INTO rec_g_okv_csr ;
            IF oki_load_okv_pvt.g_okv_csr%NOTFOUND THEN
              l_loc := 'Insert the new record.' ;
              -- Insert the current period data for the period
              oki_load_okv_pvt.ins_perf_meas(
                  p_period_name        => rec_g_glpr_csr.period_name
                , p_period_set_name    => rec_g_glpr_csr.period_set_name
                , p_period_type        => rec_g_glpr_csr.period_type
                , p_authoring_org_id   => rec_l_org_id_csr.org_id
                , p_authoring_org_name => rec_l_org_id_csr.organization_name
                , p_kpi_code           => l_cncs_code
                , p_kpi_value          => l_base_consolidated_amount
                , p_scs_code           => rec_l_org_id_csr.scs_code
                , x_retcode            => l_retcode ) ;

              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
              END IF ;

            ELSE
              l_loc := 'Update the existing record.' ;
              -- Record already exists, so perform an update
              oki_load_okv_pvt.upd_perf_meas(
                  p_kpi_value => l_base_consolidated_amount
                , p_okv_rowid => rec_g_okv_csr.rowid
                , x_retcode   => l_retcode ) ;

              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
              END IF ;

            END IF ;
          CLOSE oki_load_okv_pvt.g_okv_csr ;
        END LOOP l_cntr_cnsl_csr_loop ;
      END LOOP g_glpr_csr_loop ;
    END LOOP l_org_id_csr_loop ;

  EXCEPTION

    WHEN oki_load_okv_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_OKV_PVT.CALC_OKV_DTL1');

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
  END calc_okv_dtl1 ;

--------------------------------------------------------------------------------
  -- Procedure to calculate the performance measures.
  -- Calculates the amounts across organizations:
  --   each period set name
  --   each period type
  --   each period name
  --   each measure
  --   each subclass
  --   all  organizations
--------------------------------------------------------------------------------

  PROCEDURE calc_okv_dtl2
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , x_retcode            OUT NOCOPY VARCHAR2
  ) IS


  -- Constant declaration

  -- Codes for the performance measures in fnd_lookups
  l_hardcoded_dro_code   CONSTANT VARCHAR2(30) := 'DRO' ;
  l_hardcoded_fcacp_code CONSTANT VARCHAR2(30) := 'FCACP' ;
  l_hardcoded_cncs_code  CONSTANT VARCHAR2(30) := 'CNCS' ;
  l_lkup_type            CONSTANT VARCHAR2(30) := 'OKI_PERF_MEASURE_TYPES' ;


  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode          VARCHAR2(100)  := NULL ;
  l_sqlerrm          VARCHAR2(1000) := NULL ;

  -- Holds the calculated days renewal outstanding,
  -- forecast achievement % and the contracts consolidated values
  l_dro_value                 NUMBER := 0 ;
  l_base_achv_forecast_amount NUMBER := 0 ;
  l_base_achv_contract_amount NUMBER := 0 ;
  l_base_consolidated_amount  NUMBER := 0 ;
  l_achv_pct                  NUMBER := 0 ;

  -- Holds the code from the fnd_lookups table for the
  -- OKI_PERF_MEASURE_TYPES type
  l_dro_code   VARCHAR2(30) := NULL ;
  l_fcacp_code VARCHAR2(30) := NULL ;
  l_cncs_code  VARCHAR2(30) := NULL ;

  -- Location within the program before the error was encountered.
  l_loc        VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;


  -- Cusror declaration

  -- Cursor to get all the organizations
  CURSOR l_scs_csr IS
    SELECT   DISTINCT shd.scs_code
    FROM     oki_sales_k_hdrs shd
    ;

  -- Cursor that calculates the days renewals outstanding for all
  -- contracts by subclass
  CURSOR l_dro_csr
  (   p_summary_build_date IN DATE
    , p_scs_code           IN VARCHAR2
  ) IS
    SELECT   ROUND(NVL(SUM(TRUNC(p_summary_build_date ) - TRUNC(shd.creation_date)), 0)
             / DECODE(COUNT(shd.chr_id), NULL, 1, 0, 1, COUNT(shd.chr_id)), 2) dro_value
    FROM     oki_sales_k_hdrs shd
    WHERE    shd.ste_code  = 'ENTERED'
    AND      shd.is_new_yn IS NULL
    AND    shd.scs_code = p_scs_code
    ;
  rec_l_dro_csr l_dro_csr%ROWTYPE ;

  -- Cursor that calculates the contract amount portion for the
  -- forecast achievement % by subclass
  CURSOR l_achv_cntr_csr
  (   p_glpr_start_date  IN DATE
    , p_glpr_end_date    IN DATE
    , p_scs_code           IN VARCHAR2
  ) IS
    SELECT NVL(SUM(shd.base_contract_amount), 0) base_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.ste_code    IN ('SIGNED', 'ACTIVE')
    AND    shd.win_percent IS NOT NULL
    AND    shd.close_date  IS NOT NULL
    AND    shd.close_date  BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND    shd.date_signed BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND    shd.is_new_yn   IS NULL
    AND    shd.scs_code    = p_scs_code
    ;
  rec_l_achv_cntr_csr l_achv_cntr_csr%ROWTYPE ;


  -- Cursor that calculates the forecast amount portion for the
  -- forecast achievement % by subclass
  CURSOR l_achv_fcst_csr
  (   p_glpr_start_date  IN DATE
    , p_glpr_end_date    IN DATE
    , p_scs_code           IN VARCHAR2
  ) IS
    SELECT NVL(SUM(shd.base_forecast_amount), 0) base_forecast_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.ste_code    IN ('SIGNED', 'ACTIVE', 'ENTERED')
    AND    shd.win_percent IS NOT NULL
    AND    shd.close_date  IS NOT NULL
    AND    shd.close_date  BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND    shd.is_new_yn   IS NULL
    AND    shd.scs_code    = p_scs_code
    ;
  rec_l_achv_fcst_csr l_achv_fcst_csr%ROWTYPE ;


  -- Cursor that calculates the contracts consolidated amount for contracts
  -- by subclass.
  -- Convert the contracts consolidated amount to base for insertion
  -- into the table
  CURSOR l_cntr_cnsl_csr
  (   p_glpr_start_date IN DATE
    , p_glpr_end_date   IN DATE
    , p_scs_code           IN VARCHAR2
  ) IS
     SELECT /*11510 changes removed NVL(SUM(cle.price_negotiated * odr.conversion_rate), 0) */ SUM(shd.base_contract_amount) base_price_negotiated
           /* 11510 changes removed okc_k_lines_b cle */
         FROM
             oki_sales_k_hdrs shd
         , okc_operation_lines ole
         , okc_operation_instances oie
         , okc_class_operations cop
        /*,11510 changes removed oki_daily_rates odr */
    -- Join lines to head to get currency code from header
    -- and convert the currency in base
    WHERE
    /*11510 changes removed the following joins
      shd.chr_id        = cle.dnz_chr_id
    AND    odr.to_currency   = oki_load_okv_pvt.g_base_currency
    AND    odr.from_currency = nvl(cle.currency_code, shd.currency_code) */
    -- Get all consolidated contracts
           cop.opn_code      = 'REN_CON'
    AND    ole.process_flag  = 'P'
    -- Get all signed and active or contracts
    AND    shd.ste_code     IN ('SIGNED', 'ACTIVE')
    AND    shd.chr_id       = ole.subject_chr_id
    AND    ole.oie_id       = oie.id
    AND    oie.cop_id       = cop.id
    AND    shd.date_signed  BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND    shd.is_new_yn    IS NULL
    AND    shd.scs_code     = p_scs_code
    ;
  rec_l_cntr_cnsl_csr l_cntr_cnsl_csr%ROWTYPE ;

  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    l_loc := 'Opening cursor to determine days renewal outstanding code.' ;
    -- Validate the days renewal outstanding code
    OPEN oki_load_okv_pvt.g_lkup_csr( l_lkup_type, l_hardcoded_dro_code ) ;
    FETCH oki_load_okv_pvt.g_lkup_csr INTO rec_g_lkup_csr ;
      -- If there was not a valid DRO code then exit ;
      IF oki_load_okv_pvt.g_lkup_csr%NOTFOUND THEN
        RAISE g_excp_exit_immediate ;
      END IF ;
      l_dro_code := rec_g_lkup_csr.lookup_code ;
    CLOSE oki_load_okv_pvt.g_lkup_csr ;

    l_loc := 'Opening cursor to determine forecast achievement % code.' ;
    -- Validate the forecast achievement %
    OPEN oki_load_okv_pvt.g_lkup_csr( l_lkup_type, l_hardcoded_fcacp_code ) ;
    FETCH oki_load_okv_pvt.g_lkup_csr INTO rec_g_lkup_csr ;
      -- If there was not a valid FCACP code then exit ;
      IF oki_load_okv_pvt.g_lkup_csr%NOTFOUND THEN
        RAISE g_excp_exit_immediate ;
      END IF ;
      l_fcacp_code := rec_g_lkup_csr.lookup_code ;
    CLOSE oki_load_okv_pvt.g_lkup_csr ;

    l_loc := 'Opening cursor to determine contracts consolidated code.' ;
    -- Validate the contracts consolidate code
    OPEN  oki_load_okv_pvt.g_lkup_csr( l_lkup_type, l_hardcoded_cncs_code ) ;
    FETCH oki_load_okv_pvt.g_lkup_csr INTO rec_g_lkup_csr ;
      -- If there was not a valid CNCS code then exit ;
      IF oki_load_okv_pvt.g_lkup_csr%NOTFOUND THEN
        RAISE g_excp_exit_immediate ;
      END IF ;
      l_cncs_code := rec_g_lkup_csr.lookup_code ;
    CLOSE oki_load_okv_pvt.g_lkup_csr ;

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
        l_dro_value                 := 0 ;
        l_base_achv_forecast_amount := 0 ;
        l_base_achv_contract_amount := 0 ;
        l_base_consolidated_amount  := 0 ;

        l_loc := 'Opening cursor to determine the days renewal outstanding value.' ;
        << l_dro_csr_loop >>
        -- Calculate the days renewals outstanding
        FOR rec_l_dro_csr in l_dro_csr (p_summary_build_date,
            rec_l_scs_csr.scs_code ) LOOP
          l_dro_value  := rec_l_dro_csr.dro_value ;

          l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
          -- Determine if the DRO record is a new one or an existing one
          OPEN oki_load_okv_pvt.g_okv_csr( rec_g_glpr_csr.period_set_name,
               rec_g_glpr_csr.period_name, oki_load_okv_pvt.g_all_org_id,
               l_dro_code, rec_l_scs_csr.scs_code ) ;
          FETCH oki_load_okv_pvt.g_okv_csr INTO rec_g_okv_csr ;
            IF oki_load_okv_pvt.g_okv_csr%NOTFOUND THEN
              l_loc := 'Insert the new record.' ;
              l_loc := 'Update the existing record.' ;
              -- Insert the current period data for the period
              oki_load_okv_pvt.ins_perf_meas(
                   p_period_name        => rec_g_glpr_csr.period_name
                 , p_period_set_name    => rec_g_glpr_csr.period_set_name
                 , p_period_type        => rec_g_glpr_csr.period_type
                 , p_authoring_org_id   => oki_load_okv_pvt.g_all_org_id
                 , p_authoring_org_name => oki_load_okv_pvt.g_all_org_name
                 , p_kpi_code           => l_dro_code
                 , p_kpi_value          => l_dro_value
                 , p_scs_code           => rec_l_scs_csr.scs_code
                 , x_retcode            => l_retcode ) ;

              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
              END IF ;

            ELSE
              l_loc := 'Update the existing record.' ;
              -- Record already exists, so perform an update
              oki_load_okv_pvt.upd_perf_meas(
                  p_kpi_value => l_dro_value
                , p_okv_rowid => rec_g_okv_csr.rowid
                , x_retcode   => l_retcode ) ;

              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
              END IF ;

            END IF ;
          CLOSE oki_load_okv_pvt.g_okv_csr ;
        END LOOP l_dro_csr_loop ;


        l_loc := 'Opening cursor to determine the contract amount of FA %.' ;
        << l_achv_cntr_csr_loop >>
        -- Calculate the contract amount portion of the
        -- forecast achievement %
        FOR rec_l_achv_cntr_csr in l_achv_cntr_csr( l_glpr_start_date,
            l_glpr_end_date, rec_l_scs_csr.scs_code ) LOOP
          l_base_achv_contract_amount :=
                           rec_l_achv_cntr_csr.base_contract_amount ;

          l_loc := 'Opening cursor to determine the forecast amount of FA %.' ;
          -- Calculate the forecast amount portion of the
          -- forecast achievement %
          OPEN  l_achv_fcst_csr( l_glpr_start_date, l_glpr_end_date,
                rec_l_scs_csr.scs_code ) ;
          FETCH l_achv_fcst_csr into rec_l_achv_fcst_csr ;
            IF l_achv_fcst_csr%FOUND THEN
              l_base_achv_forecast_amount :=
                                rec_l_achv_fcst_csr.base_forecast_amount ;
            END IF ;
          CLOSE l_achv_fcst_csr ;

          IF l_base_achv_forecast_amount = 0 THEN
            l_achv_pct := 0 ;
          ELSE
            -- Calculate the forecast achievement % and round to the nearest
            -- hundredth.
            l_achv_pct := ROUND(( l_base_achv_contract_amount /
                                l_base_achv_forecast_amount ) * 100, 2) ;
          END IF ;

          l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
          -- Determine if the FCACP record is a new one or an existing one
          OPEN oki_load_okv_pvt.g_okv_csr( rec_g_glpr_csr.period_set_name,
               rec_g_glpr_csr.period_name, oki_load_okv_pvt.g_all_org_id,
               l_fcacp_code, rec_l_scs_csr.scs_code ) ;
          FETCH oki_load_okv_pvt.g_okv_csr INTO rec_g_okv_csr ;
            IF oki_load_okv_pvt.g_okv_csr%NOTFOUND THEN
              l_loc := 'Insert the new record.' ;
              -- Insert the current period data for the period
              oki_load_okv_pvt.ins_perf_meas(
                  p_period_name        => rec_g_glpr_csr.period_name
                , p_period_set_name    => rec_g_glpr_csr.period_set_name
                , p_period_type        => rec_g_glpr_csr.period_type
                , p_authoring_org_id   => oki_load_okv_pvt.g_all_org_id
                , p_authoring_org_name => oki_load_okv_pvt.g_all_org_name
                , p_kpi_code           => l_fcacp_code
                , p_kpi_value          => l_achv_pct
                , p_scs_code           => rec_l_scs_csr.scs_code
                , x_retcode            => l_retcode ) ;
              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
              END IF ;
            ELSE
              l_loc := 'Update the existing record.' ;
              -- Record already exists, so perform an update
              oki_load_okv_pvt.upd_perf_meas(
                  p_kpi_value => l_achv_pct
                , p_okv_rowid => rec_g_okv_csr.rowid
                , x_retcode   => l_retcode ) ;

              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
              END IF ;

            END IF ;
          CLOSE oki_load_okv_pvt.g_okv_csr ;
        END LOOP l_achv_cntr_csr_loop ;


        l_loc := 'Opening cursor to determine the contracts consilodated value.' ;
        << l_cntr_cnsl_csr_loop >>
        -- Calculate the contracts consolidated amount
        FOR rec_l_cntr_cnsl_csr IN l_cntr_cnsl_csr( l_glpr_start_date,
            l_glpr_end_date, rec_l_scs_csr.scs_code ) LOOP

          l_base_consolidated_amount :=
                rec_l_cntr_cnsl_csr.base_price_negotiated ;

          l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
          -- Determine if the CNCS record is a new one or an existing one
          OPEN oki_load_okv_pvt.g_okv_csr( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, oki_load_okv_pvt.g_all_org_id,
             l_cncs_code, rec_l_scs_csr.scs_code ) ;
          FETCH oki_load_okv_pvt.g_okv_csr INTO rec_g_okv_csr ;
            IF oki_load_okv_pvt.g_okv_csr%NOTFOUND THEN
              l_loc := 'Insert the new record.' ;
              -- Insert the current period data for the period
              oki_load_okv_pvt.ins_perf_meas(
                  p_period_name        => rec_g_glpr_csr.period_name
                , p_period_set_name    => rec_g_glpr_csr.period_set_name
                , p_period_type        => rec_g_glpr_csr.period_type
                , p_authoring_org_id   => oki_load_okv_pvt.g_all_org_id
                , p_authoring_org_name => oki_load_okv_pvt.g_all_org_name
                , p_kpi_code           => l_cncs_code
                , p_kpi_value          => l_base_consolidated_amount
                , p_scs_code           => rec_l_scs_csr.scs_code
                , x_retcode            => l_retcode ) ;

              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
              END IF ;

            ELSE
              l_loc := 'Update the existing record.' ;
              -- Record already exists, so perform an update
              oki_load_okv_pvt.upd_perf_meas(
                  p_kpi_value => l_base_consolidated_amount
                , p_okv_rowid => rec_g_okv_csr.rowid
                , x_retcode   => l_retcode ) ;

              IF l_retcode = '2' THEN
                -- Load failed, exit immediately.
                RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
              END IF ;

            END IF ;
          CLOSE oki_load_okv_pvt.g_okv_csr ;
        END LOOP l_cntr_cnsl_csr_loop ;
      END LOOP g_glpr_csr_loop ;
    END LOOP l_org_id_csr_loop ;
  EXCEPTION

    WHEN oki_load_okv_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_OKV_PVT.CALC_OKV_DTL2');

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

  END calc_okv_dtl2 ;
--------------------------------------------------------------------------------
  -- Procedure to calculate the performance measures.
  -- Calculates the amounts across organizations and subclasses
  --   each period set name
  --   each period type
  --   each period name
  --   each measures
  --   all  subclasses
  --   all  organizations
  --
--------------------------------------------------------------------------------

  PROCEDURE calc_okv_sum
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , x_retcode            OUT NOCOPY VARCHAR2
  ) IS


  -- Constant declaration

  -- Codes for the performance measures in fnd_lookups
  l_hardcoded_dro_code   CONSTANT VARCHAR2(30) := 'DRO' ;
  l_hardcoded_fcacp_code CONSTANT VARCHAR2(30) := 'FCACP' ;
  l_hardcoded_cncs_code  CONSTANT VARCHAR2(30) := 'CNCS' ;
  l_lkup_type            CONSTANT VARCHAR2(30) := 'OKI_PERF_MEASURE_TYPES' ;


  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode          VARCHAR2(100)  := NULL ;
  l_sqlerrm          VARCHAR2(1000) := NULL ;

  -- Holds the calculated days renewal outstanding,
  -- forecast achievement % and the contracts consolidated values
  l_dro_value                 NUMBER := 0 ;
  l_base_achv_forecast_amount NUMBER := 0 ;
  l_base_achv_contract_amount NUMBER := 0 ;
  l_base_consolidated_amount  NUMBER := 0 ;

  l_achv_pct                  NUMBER := 0 ;

  -- Holds the code from the fnd_lookups table for the
  -- OKI_PERF_MEASURE_TYPES type
  l_dro_code   VARCHAR2(30) := NULL ;
  l_fcacp_code VARCHAR2(30) := NULL ;
  l_cncs_code  VARCHAR2(30) := NULL ;

  -- Location within the program before the error was encountered.
  l_loc        VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;


  -- Cusror declaration

  -- Cursor that calculates the days renewals outstanding for all
  -- contracts
  CURSOR l_dro_csr
  (   p_summary_build_date IN DATE
  ) IS
    SELECT ROUND(NVL(SUM(TRUNC(p_summary_build_date ) - TRUNC(shd.creation_date)), 0)
           / DECODE(COUNT(shd.chr_id), NULL, 1, 0, 1, COUNT(shd.chr_id)), 2) dro_value
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.ste_code  = 'ENTERED'
    AND    shd.is_new_yn IS NULL
    ;
  rec_l_dro_csr l_dro_csr%ROWTYPE ;


  -- Cursor that calculates the contract amount portion for the
  -- forecast achievement %
  CURSOR l_achv_cntr_csr
  (   p_glpr_start_date IN DATE
    , p_glpr_end_date   IN DATE
  ) IS
    SELECT NVL(SUM(shd.base_contract_amount), 0) base_contract_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.ste_code    IN ('SIGNED', 'ACTIVE')
    AND    shd.win_percent IS NOT NULL
    AND    shd.close_date  IS NOT NULL
    AND    shd.close_date  BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND    shd.date_signed BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND    shd.is_new_yn   IS NULL
    ;
  rec_l_achv_cntr_csr l_achv_cntr_csr%ROWTYPE ;


  -- Cursor that calculates the forecast amount portion for the
  -- forecast achievement %
  CURSOR l_achv_fcst_csr
  (   p_glpr_start_date IN DATE
    , p_glpr_end_date   IN DATE
  ) IS
    SELECT NVL(SUM(shd.base_forecast_amount), 0) base_forecast_amount
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.ste_code    IN ('SIGNED', 'ACTIVE', 'ENTERED')
    AND    shd.win_percent IS NOT NULL
    AND    shd.close_date  IS NOT NULL
    AND    shd.close_date  BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND    shd.is_new_yn   IS NULL
    ;
  rec_l_achv_fcst_csr l_achv_fcst_csr%ROWTYPE ;

  -- Cursor that calculates the contracts consolidated amount for contracts
  -- Convert the contracts consolidated amount to base for insertion
  -- into the table
  CURSOR l_cntr_cnsl_csr
  (   p_glpr_start_date IN DATE
    , p_glpr_end_date   IN DATE
  ) IS
    SELECT /*11510 changes removed NVL(SUM(cle.price_negotiated * odr.conversion_rate), 0) */
           SUM(shd.base_contract_amount) base_price_negotiated
           /* 11510 changes removed okc_k_lines_b cle */
         FROM
           oki_sales_k_hdrs shd
         , okc_operation_lines ole
         , okc_operation_instances oie
         , okc_class_operations cop
        /*11510 changes removed oki_daily_rates odr */
    WHERE
    /*11510 changes removed the following joins
      shd.chr_id        = cle.dnz_chr_id
    AND    odr.to_currency   = oki_load_okv_pvt.g_base_currency
    AND    odr.from_currency = nvl(cle.currency_code, shd.currency_code) */
    --  Get all consolidated contracts
          cop.opn_code      = 'REN_CON'
    AND    ole.process_flag  = 'P'
    -- Get all signed and active or contracts
    AND    shd.ste_code     IN ('SIGNED', 'ACTIVE')
    AND    shd.chr_id       = ole.subject_chr_id
    AND    ole.oie_id       = oie.id
    AND    oie.cop_id       = cop.id
    AND    shd.date_signed  BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND    shd.is_new_yn    IS NULL ;


  rec_l_cntr_cnsl_csr l_cntr_cnsl_csr%ROWTYPE ;

  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    l_loc := 'Opening cursor to determine days renewal outstanding code.' ;
    -- Validate the days renewal outstanding code
    OPEN  oki_load_okv_pvt.g_lkup_csr( l_lkup_type, l_hardcoded_dro_code ) ;
    FETCH oki_load_okv_pvt.g_lkup_csr INTO rec_g_lkup_csr ;
      -- If there was not a valid DRO code then exit ;
      IF oki_load_okv_pvt.g_lkup_csr%NOTFOUND THEN
        RAISE g_excp_exit_immediate ;
      END IF ;
      l_dro_code := rec_g_lkup_csr.lookup_code ;
    CLOSE oki_load_okv_pvt.g_lkup_csr ;

    l_loc := 'Opening cursor to determine forecast achievement % code.' ;
    -- Validate the forecast achievement %
    OPEN  oki_load_okv_pvt.g_lkup_csr( l_lkup_type, l_hardcoded_fcacp_code ) ;
    FETCH oki_load_okv_pvt.g_lkup_csr INTO rec_g_lkup_csr ;
      -- If there was not a valid FCACP code then exit ;
      IF oki_load_okv_pvt.g_lkup_csr%NOTFOUND THEN
        RAISE g_excp_exit_immediate ;
      END IF ;
      l_fcacp_code := rec_g_lkup_csr.lookup_code ;
    CLOSE oki_load_okv_pvt.g_lkup_csr ;

    l_loc := 'Opening cursor to determine contracts consolidated code.' ;
    -- Validate the contracts consolidate code
    OPEN  oki_load_okv_pvt.g_lkup_csr( l_lkup_type, l_hardcoded_cncs_code ) ;
    FETCH oki_load_okv_pvt.g_lkup_csr INTO rec_g_lkup_csr ;
      -- If there was not a valid CNCS code then exit ;
      IF oki_load_okv_pvt.g_lkup_csr%NOTFOUND THEN
        RAISE g_excp_exit_immediate ;
      END IF ;
      l_cncs_code := rec_g_lkup_csr.lookup_code ;
    CLOSE oki_load_okv_pvt.g_lkup_csr ;

    l_loc := 'Looping through valid periods.' ;
    -- Loop through all the periods
    FOR rec_g_glpr_csr IN oki_utl_pvt.g_glpr_csr(
        p_period_set_name, p_period_type, p_summary_build_date ) LOOP

      l_dro_value                 := 0 ;
      l_base_achv_forecast_amount := 0 ;
      l_base_achv_contract_amount := 0 ;
      l_base_consolidated_amount  := 0 ;

      l_loc := 'Opening cursor to determine the days renewal outstanding value.' ;
      -- Calculate the days renewals outstanding
      OPEN  l_dro_csr (p_summary_build_date ) ;
      FETCH l_dro_csr INTO rec_l_dro_csr ;
        IF l_dro_csr%FOUND THEN
          l_dro_value := rec_l_dro_csr.dro_value ;
        END IF ;
      CLOSE l_dro_csr ;

      l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
      -- Determine if the DRO record is a new one or an existing one
      OPEN oki_load_okv_pvt.g_okv_csr( rec_g_glpr_csr.period_set_name,
           rec_g_glpr_csr.period_name, oki_load_okv_pvt.g_all_org_id,
           l_dro_code, oki_load_okv_pvt.g_all_scs_code ) ;
      FETCH oki_load_okv_pvt.g_okv_csr INTO rec_g_okv_csr ;
        IF oki_load_okv_pvt.g_okv_csr%NOTFOUND THEN
          l_loc := 'Insert the new record.' ;
          l_loc := 'Update the existing record.' ;
          -- Insert the current period data for the period
          oki_load_okv_pvt.ins_perf_meas(
               p_period_name         => rec_g_glpr_csr.period_name
             , p_period_set_name     => rec_g_glpr_csr.period_set_name
             , p_period_type         => rec_g_glpr_csr.period_type
             , p_authoring_org_id    => oki_load_okv_pvt.g_all_org_id
             , p_authoring_org_name  => oki_load_okv_pvt.g_all_org_name
             , p_kpi_code            => l_dro_code
             , p_kpi_value           => l_dro_value
             , p_scs_code            => oki_load_okv_pvt.g_all_scs_code
             , x_retcode             => l_retcode ) ;

          IF l_retcode = '2' THEN
            -- Load failed, exit immediately.
            RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
          END IF ;

        ELSE
          l_loc := 'Update the existing record.' ;
          -- Record already exists, so perform an update
          oki_load_okv_pvt.upd_perf_meas(
              p_kpi_value => l_dro_value
            , p_okv_rowid => rec_g_okv_csr.rowid
            , x_retcode   => l_retcode ) ;

          IF l_retcode = '2' THEN
            -- Load failed, exit immediately.
            RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
          END IF ;

        END IF ;
      CLOSE oki_load_okv_pvt.g_okv_csr ;


      l_loc := 'Opening cursor to determine the contract amount of FA %.' ;
      -- Calculate the contract amount portion of the
      -- forecast achievement %
      OPEN  l_achv_cntr_csr( rec_g_glpr_csr.start_date,
            rec_g_glpr_csr.end_date ) ;
      FETCH l_achv_cntr_csr into rec_l_achv_cntr_csr ;
        IF l_achv_cntr_csr%FOUND THEN
          l_base_achv_contract_amount :=
                           rec_l_achv_cntr_csr.base_contract_amount ;
        END IF ;
      CLOSE l_achv_cntr_csr ;

      l_loc := 'Opening cursor to determine the forecast amount of FA %.' ;
      -- Calculate the forecast amount portion of the
      -- forecast achievement %
      OPEN  l_achv_fcst_csr( rec_g_glpr_csr.start_date,
            rec_g_glpr_csr.end_date ) ;
      FETCH l_achv_fcst_csr into rec_l_achv_fcst_csr ;
        IF l_achv_fcst_csr%FOUND THEN
          l_base_achv_forecast_amount :=
                            rec_l_achv_fcst_csr.base_forecast_amount ;
        END IF ;
      CLOSE l_achv_fcst_csr ;

      IF l_base_achv_forecast_amount = 0 THEN
        l_achv_pct := 0 ;
      ELSE
        -- Calculate the forecast achievement % and round to the nearest
        -- hundredth.
        l_achv_pct := ROUND(( l_base_achv_contract_amount /
                            l_base_achv_forecast_amount ) * 100, 2) ;
      END IF ;

      l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
      -- Determine if the FCACP record is a new one or an existing one
      OPEN oki_load_okv_pvt.g_okv_csr( rec_g_glpr_csr.period_set_name,
           rec_g_glpr_csr.period_name, oki_load_okv_pvt.g_all_org_id,
           l_fcacp_code, oki_load_okv_pvt.g_all_scs_code ) ;
      FETCH oki_load_okv_pvt.g_okv_csr INTO rec_g_okv_csr ;
        IF oki_load_okv_pvt.g_okv_csr%NOTFOUND THEN
         l_loc := 'Insert the new record.' ;
         -- Insert the current period data for the period
         oki_load_okv_pvt.ins_perf_meas(
             p_period_name        => rec_g_glpr_csr.period_name
           , p_period_set_name    => rec_g_glpr_csr.period_set_name
           , p_period_type        => rec_g_glpr_csr.period_type
           , p_authoring_org_id   => oki_load_okv_pvt.g_all_org_id
           , p_authoring_org_name => oki_load_okv_pvt.g_all_org_name
           , p_kpi_code           => l_fcacp_code
           , p_kpi_value          => l_achv_pct
           , p_scs_code           => oki_load_okv_pvt.g_all_scs_code
           , x_retcode            => l_retcode ) ;

         IF l_retcode = '2' THEN
           -- Load failed, exit immediately.
           RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
         END IF ;

        ELSE
          l_loc := 'Update the existing record.' ;
          -- Record already exists, so perform an update
          oki_load_okv_pvt.upd_perf_meas(
              p_kpi_value => l_achv_pct
            , p_okv_rowid => rec_g_okv_csr.rowid
            , x_retcode   => l_retcode ) ;

          IF l_retcode = '2' THEN
            -- Load failed, exit immediately.
            RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
          END IF ;

        END IF ;
      CLOSE oki_load_okv_pvt.g_okv_csr ;

      l_loc := 'Opening cursor to determine the contracts consilodated value.' ;
      -- Calculate the contracts consolidated amount
      OPEN  l_cntr_cnsl_csr( rec_g_glpr_csr.start_date,
            rec_g_glpr_csr.end_date ) ;
      FETCH l_cntr_cnsl_csr INTO rec_l_cntr_cnsl_csr ;
        IF l_cntr_cnsl_csr%FOUND THEN
          l_base_consolidated_amount :=
              rec_l_cntr_cnsl_csr.base_price_negotiated ;
        END IF ;
      CLOSE l_cntr_cnsl_csr ;

      l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
      -- Determine if the CNCS record is a new one or an existing one
      OPEN oki_load_okv_pvt.g_okv_csr( rec_g_glpr_csr.period_set_name,
           rec_g_glpr_csr.period_name, oki_load_okv_pvt.g_all_org_id,
           l_cncs_code, oki_load_okv_pvt.g_all_scs_code ) ;
      FETCH oki_load_okv_pvt.g_okv_csr INTO rec_g_okv_csr ;
        IF oki_load_okv_pvt.g_okv_csr%NOTFOUND THEN
          l_loc := 'Insert the new record.' ;
          -- Insert the current period data for the period
          oki_load_okv_pvt.ins_perf_meas(
              p_period_name        => rec_g_glpr_csr.period_name
            , p_period_set_name    => rec_g_glpr_csr.period_set_name
            , p_period_type        => rec_g_glpr_csr.period_type
            , p_authoring_org_id   => oki_load_okv_pvt.g_all_org_id
            , p_authoring_org_name => oki_load_okv_pvt.g_all_org_name
            , p_kpi_code           => l_cncs_code
            , p_kpi_value          => l_base_consolidated_amount
            , p_scs_code           => oki_load_okv_pvt.g_all_scs_code
            , x_retcode            => l_retcode ) ;

          IF l_retcode = '2' THEN
            -- Load failed, exit immediately.
            RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
          END IF ;

        ELSE
          l_loc := 'Update the existing record.' ;
          -- Record already exists, so perform an update
          oki_load_okv_pvt.upd_perf_meas(
              p_kpi_value => l_base_consolidated_amount
            , p_okv_rowid => rec_g_okv_csr.rowid
            , x_retcode   => l_retcode ) ;

          IF l_retcode = '2' THEN
            -- Load failed, exit immediately.
            RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
          END IF ;

        END IF ;
      CLOSE oki_load_okv_pvt.g_okv_csr ;

    END LOOP ;
  EXCEPTION

    WHEN oki_load_okv_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_OKV_PVT.CALC_OKV_SUM');

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

  END calc_okv_sum ;
--------------------------------------------------------------------------------
  -- Procedure to create all the performance measures.  If an
  -- error is encountered in this procedure or subsequent procedures then
  -- rollback all changes.  Once the table is loaded and the data is committed
  -- the load is considered successful even if update of the oki_refreshs
  -- table failed.
  --
--------------------------------------------------------------------------------
  PROCEDURE create_perf_measures
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
  l_table_name      CONSTANT VARCHAR2(30) := 'OKI_PERF_MEASURES' ;


  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode          VARCHAR2(100)  := NULL ;
  l_sqlerrm          VARCHAR2(1000) := NULL ;


  BEGIN

    SAVEPOINT oki_load_okv_pvt_crt_perf_meas ;

    -- initialize return code TO success
    l_retcode := '0' ;
    x_retcode := '0' ;

    -- calculate the peformance measures for each dimension
    oki_load_okv_pvt.calc_okv_dtl1(
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
    END IF ;

    -- calculate the peformance measures across organizations
    oki_load_okv_pvt.calc_okv_dtl2(
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
    END IF ;

    -- calculate the peformance measures across organizations
    -- and subclasses
    oki_load_okv_pvt.calc_okv_sum(
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_okv_pvt.g_excp_exit_immediate ;
    END IF ;

    COMMIT ;

    SAVEPOINT oki_load_okv_pvt_upd_refresh ;

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

      ROLLBACK to oki_load_okv_pvt_upd_refresh ;

    WHEN oki_load_okv_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

      ROLLBACK TO oki_load_okv_pvt_crt_perf_meas ;

    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2' ;

      -- ROLLBACK all transactions
      ROLLBACK TO oki_load_okv_pvt_crt_perf_meas ;


      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_OKV_PVT.CREATE_PERF_MEASURES');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END create_perf_measures ;


BEGIN

  -- Initialize the global variables used to log this job run
  -- FROM concurrent manager
  g_request_id             :=  fnd_global.conc_request_id ;
  g_program_application_id :=  fnd_global.prog_appl_id ;
  g_program_id             :=  fnd_global.conc_program_id ;
  g_program_update_date    :=  SYSDATE ;

END oki_load_okv_pvt ;

/
