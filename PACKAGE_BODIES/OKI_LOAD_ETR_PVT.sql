--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_ETR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_ETR_PVT" AS
/* $Header: OKIRETRB.pls 115.8 2002/12/01 17:53:17 rpotnuru noship $ */

--------------------------------------------------------------------------------
-- Modification History
-- 26-Dec-2001  mezra        Initial version
-- 20-Mar-2002  mezra        Added logic to retrieve change yoy and status
--                           value.
-- 08-Apr-2002  mezra        Added logic to load organization_name,
--                           customer_name, measure_code_meaning, bin_code_seq.
-- 11-Apr-2002  mezra        Removed the dbms_output lines.
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--------------------------------------------------------------------------------

  --
  -- Global constant delcaration
  --

  -- Measure code for each measure
  g_tactk_code          CONSTANT VARCHAR2(30) := 'TACTK' ;
  g_rnwl_rate_code      CONSTANT VARCHAR2(30) := 'RNWLRATE' ;
  g_seq_grw_rate_code   CONSTANT VARCHAR2(30) := 'SGR' ;
  g_rnwl_oppty_code     CONSTANT VARCHAR2(30) := 'RNWLOPPTY' ;
  g_auto_rnwl_vol_code  CONSTANT VARCHAR2(30) := 'ARNWLV' ;
  g_auto_rnwl_rate_code CONSTANT VARCHAR2(30) := 'ARNWLRATE' ;
  g_rnwl_prc_uplft_code CONSTANT VARCHAR2(30) := 'RNWLPRCUPLFT' ;

  g_red_down_arrow    NUMBER := 1 ;
  g_green_checkmark   NUMBER := 2 ;
  g_green_up_arrow    NUMBER := 3 ;


  g_bin_id   VARCHAR2(30) := 'OKI_EXP_TO_RNWL_BIN' ;

  --
  -- Global cursor declaration
  --

  -- Cursor to retrieve the rowid for the selected record
  -- If the rowid exists, then the selected record will be
  -- updated, else it is inserted into the table.
  CURSOR g_etr_csr
  (
      p_summary_build_date    IN  DATE
    , p_authoring_org_id      IN  NUMBER
    , p_customer_party_id     IN  NUMBER
    , p_scs_code              IN  VARCHAR2
    , p_measure_code          IN  VARCHAR2
  ) IS
    SELECT rowid
    FROM   oki_exp_to_rnwl etr
    WHERE
           etr.summary_build_date    = p_summary_build_date
    AND    etr.authoring_org_id      = p_authoring_org_id
    AND    etr.customer_party_id     = p_customer_party_id
    AND    etr.scs_code              = p_scs_code
    AND    etr.measure_code          = p_measure_code
    ;
  rec_g_etr_csr g_etr_csr%ROWTYPE ;

--------------------------------------------------------------------------------
--
--Procedure to insert records into the oki_exp_to_rnwl table.
--
--------------------------------------------------------------------------------

  PROCEDURE ins_exp_to_rnwl
  (
      p_summary_build_date   IN  DATE
    , p_authoring_org_id     IN  NUMBER
    , p_organization_name    IN  VARCHAR2
    , p_customer_party_id    IN  NUMBER
    , p_customer_name        IN  VARCHAR2
    , p_scs_code             IN  VARCHAR2
    , p_measure_code         IN  VARCHAR2
    , p_measure_code_meaning IN  VARCHAR2
    , p_bin_code_seq         IN  NUMBER
    , p_measure_value1       IN  NUMBER
    , p_measure_value2       IN  NUMBER
    , p_measure_value3       IN  NUMBER
    , x_retcode              OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  BEGIN

    -- initialize return code to success
    x_retcode := '0';

    INSERT INTO oki_exp_to_rnwl
    (
             summary_build_date
           , authoring_org_id
           , organization_name
           , customer_party_id
           , customer_name
           , scs_code
           , measure_code
           , measure_code_meaning
           , bin_code_seq
           , measure_value1
           , measure_value2
           , measure_value3
           , request_id
           , program_application_id
           , program_id
           , program_update_date )
    VALUES (
             p_summary_build_date
           , p_authoring_org_id
           , p_organization_name
           , p_customer_party_id
           , p_customer_name
           , p_scs_code
           , p_measure_code
           , p_measure_code_meaning
           , p_bin_code_seq
           , p_measure_value1
           , p_measure_value2
           , p_measure_value3
           , oki_load_etr_pvt.g_request_id
           , oki_load_etr_pvt.g_program_application_id
           , oki_load_etr_pvt.g_program_id
           , oki_load_etr_pvt.g_program_update_date ) ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_TABLE_LOAD_FAILURE' ) ;

      fnd_message.set_token(  token => 'TABLE_NAME'
                            , value => 'OKI_EXP_TO_RNWL' ) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get ) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;
  END ins_exp_to_rnwl ;

--------------------------------------------------------------------------------
--
--  Procedure to update records in the oki_exp_to_rnwl table.
--
--------------------------------------------------------------------------------
  PROCEDURE upd_exp_to_rnwl
  (
      p_measure_value1       IN  NUMBER
    , p_measure_value2       IN  NUMBER
    , p_measure_value3       IN  NUMBER
    , p_measure_code_meaning IN  VARCHAR2
    , p_bin_code_seq         IN  NUMBER
    , p_organization_name    IN  VARCHAR2
    , p_customer_name        IN  VARCHAR2
    , p_etr_rowid            IN  ROWID
    , x_retcode              OUT NOCOPY VARCHAR2

  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  BEGIN

    -- initialize return code to success
    x_retcode := '0';

    UPDATE oki_exp_to_rnwl SET
        measure_value1            = p_measure_value1
      , measure_value2            = p_measure_value2
      , measure_value3            = p_measure_value3
      , measure_code_meaning      = p_measure_code_meaning
      , bin_code_seq              = p_bin_code_seq
      , organization_name         = p_organization_name
      , customer_name             = p_customer_name
      , request_id                = oki_load_etr_pvt.g_request_id
      , program_application_id    = oki_load_etr_pvt.g_program_application_id
      , program_id                = oki_load_etr_pvt.g_program_id
      , program_update_date       = oki_load_etr_pvt.g_program_update_date
    WHERE ROWID =  p_etr_rowid ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE' ) ;

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_ETR_PVT.UPD_EXP_TO_RNWL' ) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get );

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode || ' ' || l_sqlerrm ) ;
  END upd_exp_to_rnwl ;

--------------------------------------------------------------------------------
--
--  Procedure to calculate the expiration to renewal at the organization level.
--
--------------------------------------------------------------------------------
  PROCEDURE calc_etr_dtl1
  (
      x_retcode            OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode          VARCHAR2(100)  := NULL ;
  l_sqlerrm          VARCHAR2(1000) := NULL ;

  -- Location within the program before the error was encountered.
  l_loc              VARCHAR2(200) ;

  rec_l_tactk_by_org_csr        oki_utl_pvt.g_tactk_by_org_csr_row ;
  rec_l_rnwl_oppty_by_org_csr   oki_utl_pvt.g_rnwl_oppty_by_org_csr_row ;
  rec_l_k_exp_in_qtr_by_org_csr oki_utl_pvt.g_k_exp_in_qtr_by_org_csr_row ;
  rec_l_bin_disp_lkup_csr       oki_utl_pvt.g_bin_disp_lkup_csr_row ;

  -- Current and previous total active contract amount
  l_curr_tactk_value NUMBER         := 0 ;
  l_prev_tactk_value NUMBER         := 0 ;

  -- total active contract value as of the quarter start date
  l_qsd_tactk_value    NUMBER       := 0 ;
  l_py_qsd_tactk_value NUMBER       := 0 ;

  l_exp_in_qtr_count NUMBER         := 0 ;

  l_curr_value       NUMBER         := 0 ;
  l_prev_value       NUMBER         := 0 ;

  l_pct_change       NUMBER         := 0 ;

  l_measure_type     VARCHAR2(60) := NULL ;

  l_status_icon      NUMBER := NULL ;

  l_bin_code_meaning  VARCHAR2(240) := NULL ;
  l_bin_code_seq      NUMBER := NULL ;

  -- Retrieve the Renewal Rate in the Expiration to Renwal bin
  CURSOR l_rnwl_rate_csr
  (
     p_summary_build_date IN DATE
   , p_qtr_start_date     IN DATE
   , p_authoring_org_id   IN NUMBER
  ) IS
  SELECT DECODE(expiredtilldate.value
               ,0 , 1,
              ( rnwinqtr.value / expiredtilldate.value ) * 100 ) value
  FROM
      (   SELECT count(shd.chr_id) value
          FROM oki_sales_k_hdrs shd
          WHERE shd.date_signed <= p_qtr_start_date
          AND   shd.end_date BETWEEN p_qtr_start_date
                                 AND p_summary_build_date
          AND   (   shd.date_terminated IS NULL
                 OR shd.date_terminated > p_summary_build_date )
          AND   shd.base_contract_amount BETWEEN 0
          AND oki_utl_pub.g_contract_limit
          AND    shd.authoring_org_id = p_authoring_org_id	) expiredtilldate
      , ( SELECT count(shd.chr_id)  value
          FROM oki_sales_k_hdrs shd
          WHERE shd.is_new_yn   IS NULL
          AND   shd.date_signed IS NOT NULL
          AND   shd.date_signed BETWEEN p_qtr_start_date
          AND p_summary_build_date
          AND   shd.base_contract_amount
			   BETWEEN 0 AND oki_utl_pub.g_contract_limit
          AND    shd.authoring_org_id = p_authoring_org_id ) rnwinqtr;


  /*
    SELECT DECODE( (k_exp_qtd.value + bklg_k_qsd.value )
             , 0, 0
             , (((k_rnw_qtd.value + all_bklg_qsd.value ) /
                 (k_exp_qtd.value + bklg_k_qsd.value )) * 100)) value
    FROM
         (  SELECT COUNT(shd.chr_id) value
            FROM   oki_sales_k_hdrs shd
            WHERE  shd.is_new_yn   IS NULL
            AND    shd.date_signed IS NOT NULL
            AND    shd.start_date BETWEEN p_qtr_start_date
                                      AND p_summary_build_date
            AND    GREATEST(shd.date_signed, shd.date_approved) <=
                            p_summary_build_date
            AND    shd.base_contract_amount
                       BETWEEN 0 AND oki_utl_pub.g_contract_limit
            AND    shd.authoring_org_id = p_authoring_org_id
         ) k_rnw_qtd
        , ( SELECT COUNT(shd.chr_id) value
            FROM   oki_sales_k_hdrs shd
            WHERE  shd.is_new_yn     IS NULL
            AND    shd.date_signed   IS NOT NULL
            AND    shd.date_approved IS NOT NULL
            AND    shd.start_date     < p_qtr_start_date
            AND    GREATEST(shd.date_signed, shd.date_approved )
                       BETWEEN p_qtr_start_date AND p_summary_build_date
            AND    shd.base_contract_amount
                       BETWEEN 0 AND oki_utl_pub.g_contract_limit
            AND    shd.authoring_org_id = p_authoring_org_id
         ) all_bklg_qsd
        , ( SELECT COUNT(shd.chr_id) value
            FROM   oki_sales_k_hdrs shd
            WHERE  shd.date_signed   <= p_qtr_start_date
            AND    shd.date_approved <= p_summary_build_date
            AND    shd.end_date
                       BETWEEN p_qtr_start_date AND p_summary_build_date
            AND    shd.date_terminated IS NULL
            AND    shd.base_contract_amount
                       BETWEEN 0 AND oki_utl_pub.g_contract_limit
            AND    shd.authoring_org_id = p_authoring_org_id
         ) k_exp_qtd
        , ( SELECT COUNT(shd.chr_id) value
            FROM   oki_sales_k_hdrs shd
            WHERE  shd.is_new_yn         IS NULL
            AND    (   shd.date_canceled IS NULL
                    OR shd.date_canceled >= p_qtr_start_date )
            AND    (   shd.date_signed   IS NULL
                    OR shd.date_signed   >= p_qtr_start_date )
            AND    shd.start_date         < p_qtr_start_date
            AND    shd.base_contract_amount
                       BETWEEN 0 AND oki_utl_pub.g_contract_limit
            AND    shd.authoring_org_id = p_authoring_org_id
          ) bklg_k_qsd ;
		*/
  rec_l_rnwl_rate_csr l_rnwl_rate_csr%ROWTYPE ;

  -- Retrieve the Renewal Opportunity in the Expiration to Renewal bin
  CURSOR l_rnwl_oppty_csr
  (  p_qtr_end_date IN DATE
  ) IS
    SELECT COUNT(shd.chr_id) contract_count
         , NVL(SUM(shd.base_contract_amount), 0) value
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.start_date    <= p_qtr_end_date
    AND    shd.is_new_yn     IS NULL
    AND    shd.date_signed   IS NULL
    AND    shd.date_canceled IS NULL
    AND    shd.contract_amount BETWEEN 0
                                   AND oki_utl_pub.g_contract_limit
    ;
  rec_l_rnwl_oppty_csr l_rnwl_oppty_csr%ROWTYPE ;

  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    << g_org_csr_loop >>
    -- Loop through all the organizations to calculate the
    -- appropriate amounts
    FOR rec_g_org_csr IN oki_utl_pvt.g_org_csr LOOP

      --
      -- Process Total Active Contracts record
      --

      l_curr_value       := 0 ;
      l_prev_value       := 0 ;
      l_curr_tactk_value := 0 ;
      l_prev_tactk_value := 0 ;

      l_measure_type := 'Total Active Contracts By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_etr_pvt.g_bin_id
              , oki_load_etr_pvt.g_tactk_code ) ;
      FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
      IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
        l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
        l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
      ELSE
        RAISE NO_DATA_FOUND ;
      END IF ;
      CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

      -- Get the current value
      l_loc := 'Opening cursor to determine current ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_tactk_by_org_csr (
             oki_utl_pub.g_summary_build_date
           , rec_g_org_csr.authoring_org_id ) ;
      FETCH oki_utl_pvt.g_tactk_by_org_csr INTO rec_l_tactk_by_org_csr ;
      IF oki_utl_pvt.g_tactk_by_org_csr%FOUND THEN
        l_curr_tactk_value := rec_l_tactk_by_org_csr.value ;
        l_curr_value       := rec_l_tactk_by_org_csr.value ;
      END IF ;
      CLOSE oki_utl_pvt.g_tactk_by_org_csr ;

      -- Get the previous value
      l_loc := 'Opening Cursor to determine previous  ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_tactk_by_org_csr (
             oki_utl_pub.g_py_summary_build_date
           , rec_g_org_csr.authoring_org_id ) ;
      FETCH oki_utl_pvt.g_tactk_by_org_csr INTO rec_l_tactk_by_org_csr ;
      IF oki_utl_pvt.g_tactk_by_org_csr%FOUND THEN
        l_prev_tactk_value := rec_l_tactk_by_org_csr.value ;
        l_prev_value       := rec_l_tactk_by_org_csr.value ;
      END IF ;
      CLOSE oki_utl_pvt.g_tactk_by_org_csr ;

      l_loc := 'Setting the percent change ' || l_measure_type || '.' ;
      IF l_prev_value = 0 THEN
        l_pct_change := 100 ;
      ELSE
        l_pct_change := (( l_curr_value - l_prev_value ) /
                           l_prev_value ) * 100 ;
      END IF ;

      l_loc := 'Setting the status ' || l_measure_type || '.' ;
      IF l_pct_change < 0 THEN
        l_status_icon := g_red_down_arrow ;
      ELSIF ((l_pct_change >= 0) AND ( l_pct_change <= 10)) THEN
        l_status_icon := g_green_checkmark ;
      ELSE
        l_status_icon := g_green_up_arrow ;
      END IF ;

      l_loc := 'Inserting / updating  ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_etr_pvt.g_etr_csr ( oki_utl_pub.g_summary_build_date
           , rec_g_org_csr.authoring_org_id, oki_utl_pub.g_all_customer_id
           , oki_utl_pub.g_all_k_category_code
           , oki_load_etr_pvt.g_tactk_code ) ;
      FETCH oki_load_etr_pvt.g_etr_csr INTO rec_g_etr_csr ;
      IF oki_load_etr_pvt.g_etr_csr%NOTFOUND THEN
        l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_etr_pvt.ins_exp_to_rnwl(
              p_summary_build_date   => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id     => rec_g_org_csr.authoring_org_id
            , p_organization_name    => rec_g_org_csr.organization_name
            , p_customer_party_id    => oki_utl_pub.g_all_customer_id
            , p_customer_name        => oki_utl_pub.g_all_customer_name
            , p_scs_code             => oki_utl_pub.g_all_k_category_code
            , p_measure_code         => oki_load_etr_pvt.g_tactk_code
            , p_measure_code_meaning => l_bin_code_meaning
            , p_bin_code_seq         => l_bin_code_seq
            , p_measure_value1       => l_curr_value
            , p_measure_value2       => l_pct_change
            , p_measure_value3       => l_status_icon
            , x_retcode              => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record

        oki_load_etr_pvt.upd_exp_to_rnwl(
              p_measure_value1       => l_curr_value
            , p_measure_value2       => l_pct_change
            , p_measure_value3       => l_status_icon
            , p_measure_code_meaning => l_bin_code_meaning
            , p_bin_code_seq         => l_bin_code_seq
            , p_organization_name    => rec_g_org_csr.organization_name
            , p_customer_name        => oki_utl_pub.g_all_customer_name
            , p_etr_rowid            => rec_g_etr_csr.rowid
            , x_retcode              => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_etr_pvt.g_etr_csr ;

      --
      -- Process Renewal Rate record
      --

      -- Reset value
      l_curr_value := 0 ;
      l_prev_value := 0 ;
      l_exp_in_qtr_count := 0 ;
      l_measure_type := 'Renewal Rate By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_etr_pvt.g_bin_id
              , oki_load_etr_pvt.g_rnwl_rate_code ) ;
      FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
      IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
        l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
        l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
      ELSE
        RAISE NO_DATA_FOUND ;
      END IF ;
      CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

      -- Get the current value
      l_loc := 'Opening cursor to determine current ' ||
                l_measure_type || '.' ;
      OPEN l_rnwl_rate_csr ( oki_utl_pub.g_summary_build_date,
           oki_utl_pub.g_glpr_qtr_start_date,
           rec_g_org_csr.authoring_org_id ) ;
      FETCH l_rnwl_rate_csr INTO rec_l_rnwl_rate_csr ;
      IF l_rnwl_rate_csr%FOUND THEN
        l_curr_value := rec_l_rnwl_rate_csr.value ;
      END IF ;
      CLOSE l_rnwl_rate_csr ;

      -- Get the previous value
      l_loc := 'Opening cursor to determine previous ' ||
                l_measure_type || '.' ;
      OPEN l_rnwl_rate_csr ( oki_utl_pub.g_py_summary_build_date,
           oki_utl_pub.g_py_glpr_qtr_start_date,
           rec_g_org_csr.authoring_org_id ) ;
      FETCH l_rnwl_rate_csr INTO rec_l_rnwl_rate_csr ;
      IF l_rnwl_rate_csr%FOUND THEN
        l_prev_value := rec_l_rnwl_rate_csr.value ;
      END IF ;
      CLOSE l_rnwl_rate_csr ;

      l_loc := 'Setting the percent change ' ||
                l_measure_type || '.' ;
      IF l_prev_value = 0 THEN
        l_pct_change := 100 ;
      ELSE
        l_pct_change := (( l_curr_value - l_prev_value ) /
                           l_prev_value ) * 100 ;
      END IF ;

      l_loc := 'Setting the status ' || l_measure_type || '.' ;
      IF l_pct_change < 0 THEN
        l_status_icon := g_red_down_arrow ;
      ELSIF ((l_pct_change >= 0) AND ( l_pct_change <= 10)) THEN
        l_status_icon := g_green_checkmark ;
      ELSE
        l_status_icon := g_green_up_arrow ;
      END IF ;

      l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_etr_pvt.g_etr_csr ( oki_utl_pub.g_summary_build_date
           , rec_g_org_csr.authoring_org_id, oki_utl_pub.g_all_customer_id
           , oki_utl_pub.g_all_k_category_code
           , oki_load_etr_pvt.g_rnwl_rate_code ) ;
      FETCH oki_load_etr_pvt.g_etr_csr INTO rec_g_etr_csr ;
      IF oki_load_etr_pvt.g_etr_csr%NOTFOUND THEN
        l_loc := 'Insert the new record -- ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_etr_pvt.ins_exp_to_rnwl(
              p_summary_build_date   => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id     => rec_g_org_csr.authoring_org_id
            , p_organization_name    => rec_g_org_csr.organization_name
            , p_customer_party_id    => oki_utl_pub.g_all_customer_id
            , p_customer_name        => oki_utl_pub.g_all_customer_name
            , p_scs_code             => oki_utl_pub.g_all_k_category_code
            , p_measure_code         => oki_load_etr_pvt.g_rnwl_rate_code
            , p_measure_code_meaning => l_bin_code_meaning
            , p_bin_code_seq         => l_bin_code_seq
            , p_measure_value1       => l_curr_value
            , p_measure_value2       => l_pct_change
            , p_measure_value3       => l_status_icon
            , x_retcode              => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_etr_pvt.upd_exp_to_rnwl(
              p_measure_value1       => l_curr_value
            , p_measure_value2       => l_pct_change
            , p_measure_value3       => l_status_icon
            , p_measure_code_meaning => l_bin_code_meaning
            , p_bin_code_seq         => l_bin_code_seq
            , p_organization_name    => rec_g_org_csr.organization_name
            , p_customer_name        => oki_utl_pub.g_all_customer_name
            , p_etr_rowid            => rec_g_etr_csr.rowid
            , x_retcode              => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_etr_pvt.g_etr_csr ;

      --
      -- Process Sequential Growth Rate record
      --

      -- Reset value
      l_curr_value := 0 ;
      l_prev_value := 0 ;

      l_measure_type := 'Sequential Growth Rate By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_etr_pvt.g_bin_id
              , oki_load_etr_pvt.g_seq_grw_rate_code ) ;
      FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
      IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
        l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
        l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
      ELSE
        RAISE NO_DATA_FOUND ;
      END IF ;
      CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

      -- Get the current value
      l_loc := 'Opening cursor to determine current' ||
                l_measure_type || '.' ;
      -- Get the active contracts as of the start of the quarter
      OPEN oki_utl_pvt.g_tactk_by_org_csr (
             oki_utl_pub.g_glpr_qtr_start_date
           , rec_g_org_csr.authoring_org_id ) ;
      FETCH oki_utl_pvt.g_tactk_by_org_csr INTO rec_l_tactk_by_org_csr ;
      IF oki_utl_pvt.g_tactk_by_org_csr%FOUND THEN
        l_qsd_tactk_value := rec_l_tactk_by_org_csr.value ;
      END IF ;
      CLOSE oki_utl_pvt.g_tactk_by_org_csr ;

      l_loc := 'Setting the current percent value ' ||
                l_measure_type || '.' ;
      -- NOTE: l_qsd_tactk_value is the value as of the start of the quarter
      -- l_curr_tactk_value is the value as of the summary build date
      IF l_qsd_tactk_value = 0 THEN
        l_curr_value := 100 ;
      ELSE
        l_curr_value := (( l_curr_tactk_value - l_qsd_tactk_value ) /
                           l_qsd_tactk_value ) * 100 ;
      END IF ;

      -- Get the previous value
      l_loc := 'Opening cursor to determine previous ' ||
                l_measure_type || '.' ;
      -- Get the active contracts as of the start of the quarter
      OPEN oki_utl_pvt.g_tactk_by_org_csr (
             oki_utl_pub.g_py_glpr_qtr_start_date
           , rec_g_org_csr.authoring_org_id ) ;
      FETCH oki_utl_pvt.g_tactk_by_org_csr INTO rec_l_tactk_by_org_csr ;
      IF oki_utl_pvt.g_tactk_by_org_csr%FOUND THEN
        l_py_qsd_tactk_value := rec_l_tactk_by_org_csr.value ;
      END IF ;
      CLOSE oki_utl_pvt.g_tactk_by_org_csr ;

      l_loc := 'Setting the previous percent value ' ||
                l_measure_type || '.' ;
      -- NOTE: l_py_qsd_tactk_value is the value as of the prevoius year
      --       start of the quarter
      -- l_prev_tactk_value is the value as of the previous year
      -- summary build date
      IF l_py_qsd_tactk_value = 0 THEN
        l_prev_value := 0 ;
      ELSE
        l_prev_value := (( l_prev_tactk_value - l_py_qsd_tactk_value ) /
                           l_py_qsd_tactk_value ) * 100 ;
      END IF ;

      l_loc := 'Setting the percent change ' || l_measure_type || '.' ;
      IF l_prev_value = 0 THEN
        l_pct_change := 100 ;
      ELSE
        l_pct_change := (( l_curr_value - l_prev_value ) /
                           l_prev_value ) * 100 ;
      END IF ;

      l_loc := 'Setting the status ' || l_measure_type || '.' ;
      IF l_pct_change < 0 THEN
        l_status_icon := g_red_down_arrow ;
      ELSIF ((l_pct_change >= 0) AND ( l_pct_change <= 10)) THEN
        l_status_icon := g_green_checkmark ;
      ELSE
        l_status_icon := g_green_up_arrow ;
      END IF ;

      l_loc := 'Inserting / updating total ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_etr_pvt.g_etr_csr ( oki_utl_pub.g_summary_build_date
           , rec_g_org_csr.authoring_org_id, oki_utl_pub.g_all_customer_id
           , oki_utl_pub.g_all_k_category_code
           , oki_load_etr_pvt.g_seq_grw_rate_code ) ;
      FETCH oki_load_etr_pvt.g_etr_csr INTO rec_g_etr_csr ;
      IF oki_load_etr_pvt.g_etr_csr%NOTFOUND THEN
        l_loc := 'Insert the new record -- ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_etr_pvt.ins_exp_to_rnwl(
              p_summary_build_date   => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id     => rec_g_org_csr.authoring_org_id
            , p_organization_name    => rec_g_org_csr.organization_name
            , p_customer_party_id    => oki_utl_pub.g_all_customer_id
            , p_customer_name        => oki_utl_pub.g_all_customer_name
            , p_scs_code             => oki_utl_pub.g_all_k_category_code
            , p_measure_code         => oki_load_etr_pvt.g_seq_grw_rate_code
            , p_measure_code_meaning => l_bin_code_meaning
            , p_bin_code_seq         => l_bin_code_seq
            , p_measure_value1       => l_curr_value
            , p_measure_value2       => l_pct_change
            , p_measure_value3       => l_status_icon
            , x_retcode              => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_etr_pvt.upd_exp_to_rnwl(
              p_measure_value1       => l_curr_value
            , p_measure_value2       => l_pct_change
            , p_measure_value3       => l_status_icon
            , p_measure_code_meaning => l_bin_code_meaning
            , p_bin_code_seq         => l_bin_code_seq
            , p_organization_name    => rec_g_org_csr.organization_name
            , p_customer_name        => oki_utl_pub.g_all_customer_name
            , p_etr_rowid            => rec_g_etr_csr.rowid
            , x_retcode              => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_etr_pvt.g_etr_csr ;

      --
      -- Process Renewal Opportunity Outstanding record
      --

      -- Reset value
      l_curr_value := 0 ;
      l_prev_value := 0 ;
      l_measure_type := 'Renewal Opportunity Outstanding By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_etr_pvt.g_bin_id
              , oki_load_etr_pvt.g_rnwl_oppty_code ) ;
      FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
      IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
        l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
        l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
      ELSE
        RAISE NO_DATA_FOUND ;
      END IF ;
      CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

      -- Get the current value
      l_loc := 'Opening cursor to determine current ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_rnwl_oppty_by_org_csr (
             oki_utl_pub.g_glpr_qtr_end_date
           , rec_g_org_csr.authoring_org_id ) ;
      FETCH oki_utl_pvt.g_rnwl_oppty_by_org_csr INTO
                rec_l_rnwl_oppty_by_org_csr ;
      IF oki_utl_pvt.g_rnwl_oppty_by_org_csr%FOUND THEN
        l_curr_value := rec_l_rnwl_oppty_by_org_csr.value  ;
      END IF ;
      CLOSE oki_utl_pvt.g_rnwl_oppty_by_org_csr ;

      -- Get the previous value
      l_loc := 'Opening cursor to determine previous ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_rnwl_oppty_by_org_csr (
             oki_utl_pub.g_py_glpr_qtr_end_date
           , rec_g_org_csr.authoring_org_id ) ;
      FETCH oki_utl_pvt.g_rnwl_oppty_by_org_csr INTO
                rec_l_rnwl_oppty_by_org_csr ;
      IF oki_utl_pvt.g_rnwl_oppty_by_org_csr%FOUND THEN
        l_prev_value := rec_l_rnwl_oppty_by_org_csr.value  ;
      END IF ;
      CLOSE oki_utl_pvt.g_rnwl_oppty_by_org_csr ;

      l_loc := 'Setting the percent change ' || l_measure_type || '.' ;
      IF l_prev_value = 0 THEN
        l_pct_change := 100 ;
      ELSE
        l_pct_change := (( l_curr_value - l_prev_value ) /
                           l_prev_value ) * 100 ;
      END IF ;

      l_loc := 'Setting the status ' || l_measure_type || '.' ;
      IF l_pct_change < 0 THEN
        l_status_icon := g_red_down_arrow ;
      ELSIF ((l_pct_change >= 0) AND ( l_pct_change <= 10)) THEN
        l_status_icon := g_green_checkmark ;
      ELSE
        l_status_icon := g_green_up_arrow ;
      END IF ;

      l_loc := 'Inserting / updating total ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_etr_pvt.g_etr_csr ( oki_utl_pub.g_summary_build_date
           , rec_g_org_csr.authoring_org_id, oki_utl_pub.g_all_customer_id
           , oki_utl_pub.g_all_k_category_code
           , oki_load_etr_pvt.g_rnwl_oppty_code ) ;
      FETCH oki_load_etr_pvt.g_etr_csr INTO rec_g_etr_csr ;
      IF oki_load_etr_pvt.g_etr_csr%NOTFOUND THEN
        l_loc := 'Insert the new record -- ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_etr_pvt.ins_exp_to_rnwl(
              p_summary_build_date   => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id     => rec_g_org_csr.authoring_org_id
            , p_organization_name    => rec_g_org_csr.organization_name
            , p_customer_party_id    => oki_utl_pub.g_all_customer_id
            , p_customer_name        => oki_utl_pub.g_all_customer_name
            , p_scs_code             => oki_utl_pub.g_all_k_category_code
            , p_measure_code         => oki_load_etr_pvt.g_rnwl_oppty_code
            , p_measure_code_meaning => l_bin_code_meaning
            , p_bin_code_seq         => l_bin_code_seq
            , p_measure_value1       => l_curr_value
            , p_measure_value2       => l_pct_change
            , p_measure_value3       => l_status_icon
            , x_retcode              => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_etr_pvt.upd_exp_to_rnwl(
              p_measure_value1       => l_curr_value
            , p_measure_value2       => l_pct_change
            , p_measure_value3       => l_status_icon
            , p_measure_code_meaning => l_bin_code_meaning
            , p_bin_code_seq         => l_bin_code_seq
            , p_organization_name    => rec_g_org_csr.organization_name
            , p_customer_name        => oki_utl_pub.g_all_customer_name
            , p_etr_rowid            => rec_g_etr_csr.rowid
            , x_retcode              => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_etr_pvt.g_etr_csr ;

--------------------------------------------------------------------------------
/*
      --
      -- Process Auto Renewal % By Volume record
      --

      -- Reset value
      l_curr_value := 0 ;
      l_prev_value := 0 ;
      l_measure_type := 'Auto Renewal % By Volume By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_etr_pvt.g_bin_id
              , oki_load_etr_pvt.g_auto_rnwl_vol_code ) ;
      FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
      IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
        l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
        l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
      ELSE
        RAISE NO_DATA_FOUND ;
      END IF ;
      CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;


      l_curr_value := NULL ;




      l_loc := 'Inserting / updating total ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_etr_pvt.g_etr_csr ( oki_utl_pub.g_summary_build_date
           , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
           , oki_utl_pub.g_all_k_category_code
           , oki_load_etr_pvt.g_auto_rnwl_vol_code ) ;
      FETCH oki_load_etr_pvt.g_etr_csr INTO rec_g_etr_csr ;
      IF oki_load_etr_pvt.g_etr_csr%NOTFOUND THEN
        l_loc := 'Insert the new record -- ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_etr_pvt.ins_exp_to_rnwl(
              p_summary_build_date   => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id     => oki_utl_pub.g_all_organization_id
            , p_organization_name    => rec_g_org_csr.organization_name
            , p_customer_party_id    => oki_utl_pub.g_all_customer_id
            , p_customer_name        => oki_utl_pub.g_all_customer_name
            , p_scs_code             => oki_utl_pub.g_all_k_category_code
            , p_measure_code         => oki_load_etr_pvt.g_auto_rnwl_vol_code
            , p_measure_code_meaning => l_bin_code_meaning
            , p_bin_code_seq         => l_bin_code_seq
            , p_measure_value1       => l_curr_value
            , p_measure_value2       => NULL
            , p_measure_value3       => NULL
            , x_retcode              => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_etr_pvt.upd_exp_to_rnwl(
              p_measure_value1       => l_curr_value
            , p_measure_value2       => NULL
            , p_measure_value3       => NULL
            , p_measure_code_meaning => l_bin_code_meaning
            , p_bin_code_seq         => l_bin_code_seq
            , p_organization_name    => rec_g_org_csr.organization_name
            , p_customer_name        => oki_utl_pub.g_all_customer_name
            , p_etr_rowid            => rec_g_etr_csr.rowid
            , x_retcode              => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_etr_pvt.g_etr_csr ;


      --
      -- Process Auto Renewal Rate record
      --

      -- Reset value
      l_curr_value := 0 ;
      l_prev_value := 0 ;
      l_measure_type := 'Auto Renewal Rate By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_etr_pvt.g_bin_id
              , oki_load_etr_pvt.g_auto_rnwl_rate_code ) ;
      FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
      IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
        l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
        l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
      ELSE
        RAISE NO_DATA_FOUND ;
      END IF ;
      CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;


      l_curr_value := NULL ;


      l_loc := 'Inserting / updating total ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_etr_pvt.g_etr_csr ( oki_utl_pub.g_summary_build_date,
             oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id,
             oki_utl_pub.g_all_k_category_code, oki_load_etr_pvt.g_auto_rnwl_rate_code  ) ;
      FETCH oki_load_etr_pvt.g_etr_csr INTO rec_g_etr_csr ;
      IF oki_load_etr_pvt.g_etr_csr%NOTFOUND THEN
        l_loc := 'Insert the new record -- ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_etr_pvt.ins_exp_to_rnwl(
              p_summary_build_date   => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id     => oki_utl_pub.g_all_organization_id
            , p_organization_name    => rec_g_org_csr.organization_name
            , p_customer_party_id    => oki_utl_pub.g_all_customer_id
            , p_customer_name        => oki_utl_pub.g_all_customer_name
            , p_scs_code             => oki_utl_pub.g_all_k_category_code
            , p_measure_code         => oki_load_etr_pvt.g_auto_rnwl_rate_code
            , p_measure_code_meaning => l_bin_code_meaning
            , p_bin_code_seq         => l_bin_code_seq
            , p_measure_value1       => l_curr_value
            , p_measure_value2       => NULL
            , p_measure_value3       => NULL
            , x_retcode              => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_etr_pvt.upd_exp_to_rnwl(
              p_measure_value1       => l_curr_value
            , p_measure_value2       => NULL
            , p_measure_value3       => NULL
            , p_measure_code_meaning => l_bin_code_meaning
            , p_bin_code_seq         => l_bin_code_seq
            , p_organization_name    => rec_g_org_csr.organization_name
            , p_customer_name        => oki_utl_pub.g_all_customer_name
            , p_etr_rowid            => rec_g_etr_csr.rowid
            , x_retcode              => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_etr_pvt.g_etr_csr ;





      --
      -- Process Renewal Price Uplift
      --

     -- Reset value
      l_curr_value := 0 ;
      l_prev_value := 0 ;
      l_measure_type := 'Renewal Price Uplift By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_etr_pvt.g_bin_id
              , oki_load_etr_pvt.g_rnwl_prc_uplft_code ) ;
      FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
      IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
        l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
        l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
      ELSE
        RAISE NO_DATA_FOUND ;
      END IF ;
      CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;


      l_curr_value := NULL ;


      l_loc := 'Inserting / updating total ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_etr_pvt.g_etr_csr ( oki_utl_pub.g_summary_build_date,
             oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id,
             oki_utl_pub.g_all_k_category_code, oki_load_etr_pvt.g_rnwl_prc_uplft_code ) ;
      FETCH oki_load_etr_pvt.g_etr_csr INTO rec_g_etr_csr ;
      IF oki_load_etr_pvt.g_etr_csr%NOTFOUND THEN
        l_loc := 'Insert the new record -- ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_etr_pvt.ins_exp_to_rnwl(
              p_summary_build_date   => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id     => oki_utl_pub.g_all_organization_id
            , p_organization_name    => rec_g_org_csr.organization_name
            , p_customer_party_id    => oki_utl_pub.g_all_customer_id
            , p_customer_name        => oki_utl_pub.g_all_customer_name
            , p_scs_code             => oki_utl_pub.g_all_k_category_code
            , p_measure_code         => oki_load_etr_pvt.g_rnwl_prc_uplft_code
            , p_measure_code_meaning => l_bin_code_meaning
            , p_bin_code_seq         => l_bin_code_seq
            , p_measure_value1       => l_curr_value
            , p_measure_value2       => NULL
            , p_measure_value3       => NULL
            , x_retcode              => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_etr_pvt.upd_exp_to_rnwl(
              p_measure_value1       => l_curr_value
            , p_measure_value2       => NULL
            , p_measure_value3       => NULL
            , p_measure_code_meaning => l_bin_code_meaning
            , p_bin_code_seq         => l_bin_code_seq
            , p_organization_name    => rec_g_org_csr.organization_name
            , p_customer_name        => oki_utl_pub.g_all_customer_name
            , p_etr_rowid            => rec_g_etr_csr.rowid
            , x_retcode              => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_etr_pvt.g_etr_csr ;
*/
    END LOOP g_org_csr_loop ;

  EXCEPTION
    WHEN oki_utl_pub.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

    WHEN NO_DATA_FOUND THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2' ;

      -- Log the location within the procedure where the error occurred
      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_LOC_IN_PROG_FAILURE');

      fnd_message.set_token(  token => 'LOCATION'
                            , value => l_loc);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode || ' ' || l_sqlerrm );
    WHEN OTHERS THEN

      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2' ;

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_ETR_PVT.CALC_ETR_DTL1');

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
                        , buff  => l_sqlcode || ' ' || l_sqlerrm );

  END calc_etr_dtl1 ;

--------------------------------------------------------------------------------
--
--  Procedure to calculate the expiration to renewal at the top most level.
--
--------------------------------------------------------------------------------
  PROCEDURE calc_etr_sum
  (
      x_retcode            OUT NOCOPY VARCHAR2
  ) IS

  --
  -- Local variable declaration
  --

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode          VARCHAR2(100)  := NULL ;
  l_sqlerrm          VARCHAR2(1000) := NULL ;

  -- Location within the program before the error was encountered.
  l_loc              VARCHAR2(200) ;

  rec_l_tactk_all_csr        oki_utl_pvt.g_tactk_all_csr_row ;
  rec_l_rnwl_oppty_all_csr   oki_utl_pvt.g_rnwl_oppty_all_csr_row ;
  rec_l_k_exp_in_qtr_all_csr oki_utl_pvt.g_k_exp_in_qtr_all_csr_row ;
  rec_l_bin_disp_lkup_csr    oki_utl_pvt.g_bin_disp_lkup_csr_row ;

  -- Current and previous total active contract amount
  l_curr_tactk_value NUMBER         := 0 ;
  l_prev_tactk_value NUMBER         := 0 ;

  -- total active contract value as of the quarter start date
  l_qsd_tactk_value    NUMBER       := 0 ;
  l_py_qsd_tactk_value NUMBER       := 0 ;

  l_exp_in_qtr_count NUMBER         := 0 ;

  l_curr_value       NUMBER         := 0 ;
  l_prev_value       NUMBER         := 0 ;

  l_pct_change       NUMBER         := 0 ;

  l_measure_type     VARCHAR2(60) := NULL ;

  l_status_icon      NUMBER := NULL ;

  l_bin_code_meaning  VARCHAR2(240) := NULL ;
  l_bin_code_seq      NUMBER := NULL ;

  -- Retrieve the Renewal Rate in the Expiration to Renwal bin
  CURSOR l_rnwl_rate_csr
  (
     p_summary_build_date IN DATE
   , p_qtr_start_date     IN DATE
  ) IS
  SELECT DECODE(expiredtilldate.value
               ,0 , 1,
              ( rnwinqtr.value / expiredtilldate.value ) * 100 ) value
  FROM
      (   SELECT count(shd.chr_id) value
          FROM oki_sales_k_hdrs shd
          WHERE shd.date_signed <= p_qtr_start_date
          AND   shd.end_date BETWEEN p_qtr_start_date
                                 AND p_summary_build_date
          AND   (   shd.date_terminated IS NULL
                 OR shd.date_terminated > p_summary_build_date )
          AND   shd.base_contract_amount BETWEEN 0
          AND oki_utl_pub.g_contract_limit) expiredtilldate
      , ( SELECT count(shd.chr_id)  value
          FROM oki_sales_k_hdrs shd
          WHERE shd.is_new_yn   IS NULL
          AND   shd.date_signed IS NOT NULL
          AND   shd.date_signed BETWEEN p_qtr_start_date
          AND p_summary_build_date
          AND   shd.base_contract_amount
			   BETWEEN 0 AND oki_utl_pub.g_contract_limit) rnwinqtr;


/*
    SELECT DECODE( (k_exp_qtd.value + bklg_k_qsd.value )
             , 0, 0
             , (((k_rnw_qtd.value + all_bklg_qsd.value ) /
                 (k_exp_qtd.value + bklg_k_qsd.value )) * 100)) value
    FROM
         (  SELECT COUNT(shd.chr_id) value
            FROM   oki_sales_k_hdrs shd
            WHERE  shd.is_new_yn   IS NULL
            AND    shd.date_signed IS NOT NULL
            AND    shd.start_date BETWEEN p_qtr_start_date
                                      AND p_summary_build_date
            AND    GREATEST(shd.date_signed, shd.date_approved) <=
                            p_summary_build_date
            AND    shd.base_contract_amount
                       BETWEEN 0 AND oki_utl_pub.g_contract_limit
         ) k_rnw_qtd
        , ( SELECT COUNT(shd.chr_id) value
            FROM   oki_sales_k_hdrs shd
            WHERE  shd.is_new_yn     IS NULL
            AND    shd.date_signed   IS NOT NULL
            AND    shd.date_approved IS NOT NULL
            AND    shd.start_date     < p_qtr_start_date
            AND    GREATEST(shd.date_signed, shd.date_approved )
                       BETWEEN p_qtr_start_date AND p_summary_build_date
            AND    shd.base_contract_amount
                       BETWEEN 0 AND oki_utl_pub.g_contract_limit
         ) all_bklg_qsd
        , ( SELECT COUNT(shd.chr_id) value
            FROM   oki_sales_k_hdrs shd
            WHERE  shd.date_signed   <= p_qtr_start_date
            AND    shd.date_approved <= p_summary_build_date
            AND    shd.end_date
                       BETWEEN p_qtr_start_date AND p_summary_build_date
            AND    shd.date_terminated IS NULL
            AND    shd.base_contract_amount
                       BETWEEN 0 AND oki_utl_pub.g_contract_limit
         ) k_exp_qtd
        , ( SELECT COUNT(shd.chr_id) value
            FROM   oki_sales_k_hdrs shd
            WHERE  shd.is_new_yn         IS NULL
            AND    (   shd.date_canceled IS NULL
                    OR shd.date_canceled >= p_qtr_start_date )
            AND    (   shd.date_signed   IS NULL
                    OR shd.date_signed   >= p_qtr_start_date )
            AND    shd.start_date         < p_qtr_start_date
            AND    shd.base_contract_amount
                       BETWEEN 0 AND oki_utl_pub.g_contract_limit
          ) bklg_k_qsd ;
*/
  rec_l_rnwl_rate_csr l_rnwl_rate_csr%ROWTYPE ;

  -- Retrieve the Renewal Opportunity in the Expiration to Renewal bin
  CURSOR l_rnwl_oppty_csr
  (  p_qtr_end_date IN DATE
  ) IS
    SELECT COUNT(shd.chr_id) contract_count
         , NVL(SUM(shd.base_contract_amount), 0) value
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.start_date    <= p_qtr_end_date
    AND    shd.is_new_yn     IS NULL
    AND    shd.date_signed   IS NULL
    AND    shd.date_canceled IS NULL
    AND    shd.contract_amount BETWEEN 0
                                   AND oki_utl_pub.g_contract_limit
    ;
  rec_l_rnwl_oppty_csr l_rnwl_oppty_csr%ROWTYPE ;


  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    --
    -- Process Total Active Contracts record
    --

    l_measure_type := 'Total Active Contracts' ;

    -- Reset value
    l_curr_value       := 0 ;
    l_prev_value       := 0 ;
    l_curr_tactk_value := 0 ;
    l_prev_tactk_value := 0 ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_etr_pvt.g_bin_id
            , oki_load_etr_pvt.g_tactk_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

    -- Get the current value
    l_loc := 'Opening cursor to determine current ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_tactk_all_csr ( oki_utl_pub.g_summary_build_date ) ;
    FETCH oki_utl_pvt.g_tactk_all_csr INTO rec_l_tactk_all_csr ;
    IF oki_utl_pvt.g_tactk_all_csr%FOUND THEN
      l_curr_tactk_value := rec_l_tactk_all_csr.value ;
      l_curr_value       := rec_l_tactk_all_csr.value ;
    END IF ;
    CLOSE oki_utl_pvt.g_tactk_all_csr ;

    -- Get the previous value
    l_loc := 'Opening Cursor to determine previous  ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_tactk_all_csr ( oki_utl_pub.g_py_summary_build_date ) ;
    FETCH oki_utl_pvt.g_tactk_all_csr INTO rec_l_tactk_all_csr ;
    IF oki_utl_pvt.g_tactk_all_csr%FOUND THEN
      l_prev_tactk_value := rec_l_tactk_all_csr.value ;
      l_prev_value       := rec_l_tactk_all_csr.value ;
    END IF ;
    CLOSE oki_utl_pvt.g_tactk_all_csr ;

    l_loc := 'Setting the percent change.' || l_measure_type || '.' ;
    IF l_prev_value = 0 THEN
      l_pct_change := 100 ;
    ELSE
      l_pct_change := (( l_curr_value - l_prev_value ) /
                         l_prev_value ) * 100 ;
    END IF ;

    IF l_pct_change < 0 THEN
      l_status_icon := g_red_down_arrow ;
    ELSIF ((l_pct_change >= 0) AND ( l_pct_change <= 10)) THEN
      l_status_icon := g_green_checkmark ;
    ELSE
      l_status_icon := g_green_up_arrow ;
    END IF ;

    l_loc := 'Inserting / updating  ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_etr_pvt.g_etr_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
         , oki_utl_pub.g_all_k_category_code, oki_load_etr_pvt.g_tactk_code ) ;
    FETCH oki_load_etr_pvt.g_etr_csr INTO rec_g_etr_csr ;
    IF oki_load_etr_pvt.g_etr_csr%NOTFOUND THEN
      l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_etr_pvt.ins_exp_to_rnwl(
            p_summary_build_date   => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id     => oki_utl_pub.g_all_organization_id
          , p_organization_name    => oki_utl_pub.g_all_organization_name
          , p_customer_party_id    => oki_utl_pub.g_all_customer_id
          , p_customer_name        => oki_utl_pub.g_all_customer_name
          , p_scs_code             => oki_utl_pub.g_all_k_category_code
          , p_measure_code         => oki_load_etr_pvt.g_tactk_code
          , p_measure_code_meaning => l_bin_code_meaning
          , p_bin_code_seq         => l_bin_code_seq
          , p_measure_value1       => l_curr_value
          , p_measure_value2       => l_pct_change
          , p_measure_value3       => l_status_icon
          , x_retcode              => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_etr_pvt.upd_exp_to_rnwl(
            p_measure_value1       => l_curr_value
          , p_measure_value2       => l_pct_change
          , p_measure_value3       => l_status_icon
          , p_measure_code_meaning => l_bin_code_meaning
          , p_bin_code_seq         => l_bin_code_seq
          , p_organization_name    => oki_utl_pub.g_all_organization_name
          , p_customer_name        => oki_utl_pub.g_all_customer_name
          , p_etr_rowid            => rec_g_etr_csr.rowid
          , x_retcode              => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_etr_pvt.g_etr_csr ;

    --
    -- Process Renewal Rate record
    --

    -- Reset value
    l_curr_value := 0 ;
    l_prev_value := 0 ;
    l_exp_in_qtr_count := 0;

    l_measure_type := 'Renewal Rate' ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_etr_pvt.g_bin_id
            , oki_load_etr_pvt.g_rnwl_rate_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

/*
    l_loc := 'Opening cursor to determine current ' || l_measure_type ;
    l_loc :=  l_loc || ' for exp in Qtr.' ;
    OPEN oki_utl_pvt.g_k_exp_in_qtr_all_csr (
         oki_utl_pub.g_glpr_qtr_start_date,
         oki_utl_pub.g_glpr_qtr_end_date ) ;
    FETCH oki_utl_pvt.g_k_exp_in_qtr_all_csr INTO rec_l_k_exp_in_qtr_all_csr ;
    IF oki_utl_pvt.g_k_exp_in_qtr_all_csr%FOUND THEN
      l_exp_in_qtr_count := rec_l_k_exp_in_qtr_all_csr.contract_count ;
    END IF ;
    CLOSE oki_utl_pvt.g_k_exp_in_qtr_all_csr ;
*/

    -- Get the current value
    l_loc := 'Opening cursor to determine current ' || l_measure_type || '.' ;
    OPEN l_rnwl_rate_csr ( oki_utl_pub.g_summary_build_date,
         oki_utl_pub.g_glpr_qtr_start_date ) ;
    FETCH l_rnwl_rate_csr INTO rec_l_rnwl_rate_csr ;
    IF l_rnwl_rate_csr%FOUND THEN
      l_curr_value := rec_l_rnwl_rate_csr.value ;
    END IF ;
    CLOSE l_rnwl_rate_csr ;

    -- Get the previous value
    l_loc := 'Opening cursor to determine previous ' || l_measure_type || '.' ;
    OPEN l_rnwl_rate_csr ( oki_utl_pub.g_py_summary_build_date,
         oki_utl_pub.g_py_glpr_qtr_start_date ) ;
    FETCH l_rnwl_rate_csr INTO rec_l_rnwl_rate_csr ;
    IF l_rnwl_rate_csr%FOUND THEN
      l_prev_value := rec_l_rnwl_rate_csr.value ;
    END IF ;
    CLOSE l_rnwl_rate_csr ;

    l_loc := 'Setting the percent change ' || l_measure_type || '.' ;
    IF l_prev_value = 0 THEN
      l_pct_change := 100 ;
    ELSE
      l_pct_change := (( l_curr_value - l_prev_value ) / l_prev_value ) * 100 ;
    END IF ;

    l_loc := 'Setting the status ' || l_measure_type || '.' ;
    IF l_pct_change < 0 THEN
      l_status_icon := g_red_down_arrow ;
    ELSIF ((l_pct_change >= 0) AND ( l_pct_change <= 10)) THEN
      l_status_icon := g_green_checkmark ;
    ELSE
      l_status_icon := g_green_up_arrow ;
    END IF ;

/*
    l_loc := 'Opening cursor to determine current ' || l_measure_type || '.' ;
    OPEN l_rnwl_rate_csr ( oki_utl_pub.g_summary_build_date,
         oki_utl_pub.g_glpr_qtr_start_date, oki_utl_pub.g_glpr_qtr_end_date,
         l_exp_in_qtr_count ) ;
    FETCH l_rnwl_rate_csr INTO rec_l_rnwl_rate_csr ;
    IF l_rnwl_rate_csr%FOUND THEN
      l_curr_value       := rec_l_rnwl_rate_csr.value ;
    END IF ;
    CLOSE l_rnwl_rate_csr ;
*/
/*
    l_loc := 'Opening cursor to determine current ' || l_measure_type || '.' ;
    OPEN l_rnwl_rate_csr ( oki_utl_pub.g_summary_build_date,
         oki_utl_pub.g_glpr_qtr_start_date, oki_utl_pub.g_glpr_qtr_end_date ) ;
    FETCH l_rnwl_rate_csr INTO rec_l_rnwl_rate_csr ;
    IF l_rnwl_rate_csr%FOUND THEN
      l_curr_value       := rec_l_rnwl_rate_csr.value ;
    END IF ;
    CLOSE l_rnwl_rate_csr ;
*/
    l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_etr_pvt.g_etr_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
         , oki_utl_pub.g_all_k_category_code
         , oki_load_etr_pvt.g_rnwl_rate_code ) ;
    FETCH oki_load_etr_pvt.g_etr_csr INTO rec_g_etr_csr ;
    IF oki_load_etr_pvt.g_etr_csr%NOTFOUND THEN
      l_loc := 'Insert the new record -- ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_etr_pvt.ins_exp_to_rnwl(
            p_summary_build_date   => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id     => oki_utl_pub.g_all_organization_id
          , p_organization_name    => oki_utl_pub.g_all_organization_name
          , p_customer_party_id    => oki_utl_pub.g_all_customer_id
          , p_customer_name        => oki_utl_pub.g_all_customer_name
          , p_scs_code             => oki_utl_pub.g_all_k_category_code
          , p_measure_code         => oki_load_etr_pvt.g_rnwl_rate_code
          , p_measure_code_meaning => l_bin_code_meaning
          , p_bin_code_seq         => l_bin_code_seq
          , p_measure_value1       => l_curr_value
          , p_measure_value2       => l_pct_change
          , p_measure_value3       => l_status_icon
          , x_retcode              => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_etr_pvt.upd_exp_to_rnwl(
            p_measure_value1       => l_curr_value
          , p_measure_value2       => l_pct_change
          , p_measure_value3       => l_status_icon
          , p_measure_code_meaning => l_bin_code_meaning
          , p_bin_code_seq         => l_bin_code_seq
          , p_organization_name    => oki_utl_pub.g_all_organization_name
          , p_customer_name        => oki_utl_pub.g_all_customer_name
          , p_etr_rowid            => rec_g_etr_csr.rowid
          , x_retcode              => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_etr_pvt.g_etr_csr ;

    --
    -- Process Sequential Growth Rate record
    --

    -- Reset value
    l_curr_value := 0 ;
    l_prev_value := 0 ;
    l_measure_type := 'Sequential Growth Rate' ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_etr_pvt.g_bin_id
            , oki_load_etr_pvt.g_seq_grw_rate_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

    l_loc := 'Opening cursor to determine current' || l_measure_type || '.' ;
    -- Get the active contracts as of the start of the quarter
    OPEN oki_utl_pvt.g_tactk_all_csr ( oki_utl_pub.g_glpr_qtr_start_date ) ;
    FETCH oki_utl_pvt.g_tactk_all_csr INTO rec_l_tactk_all_csr ;
    IF oki_utl_pvt.g_tactk_all_csr%FOUND THEN
      l_qsd_tactk_value := rec_l_tactk_all_csr.value ;
    END IF ;
    CLOSE oki_utl_pvt.g_tactk_all_csr ;

    l_loc := 'Setting the current percent value ' || l_measure_type || '.' ;
    -- NOTE: l_qsd_tactk_value is the value as of the start of the quarter
    -- l_curr_tactk_value is the value as of the summary build date
    IF l_qsd_tactk_value = 0 THEN
      l_curr_value := 100 ;
    ELSE
      l_curr_value := (( l_curr_tactk_value - l_qsd_tactk_value ) /
                         l_qsd_tactk_value ) * 100 ;
    END IF ;

    -- Get the current value
    l_loc := 'Opening cursor to determine previous ' || l_measure_type || '.' ;
    -- Get the active contracts as of the start of the quarter
    OPEN oki_utl_pvt.g_tactk_all_csr ( oki_utl_pub.g_py_glpr_qtr_start_date ) ;
    FETCH oki_utl_pvt.g_tactk_all_csr INTO rec_l_tactk_all_csr ;
    IF oki_utl_pvt.g_tactk_all_csr%FOUND THEN
      l_py_qsd_tactk_value := rec_l_tactk_all_csr.value ;
    END IF ;
    CLOSE oki_utl_pvt.g_tactk_all_csr ;

    -- Get the previous value
    l_loc := 'Setting the previous percent value ' || l_measure_type || '.' ;
    -- NOTE: l_qsd_tactk_value is the value as of the start of the quarter
    -- l_prev_tactk_value is the value as of the summary build date
    IF l_py_qsd_tactk_value = 0 THEN
      l_prev_value := 0 ;
    ELSE
      l_prev_value := (( l_prev_tactk_value - l_py_qsd_tactk_value ) /
                         l_py_qsd_tactk_value ) * 100 ;
    END IF ;

    l_loc := 'Setting the percent change ' || l_measure_type || '.' ;
    IF l_prev_value = 0 THEN
      l_pct_change := 100 ;
    ELSE
      l_pct_change := (( l_curr_value - l_prev_value ) /
                         l_prev_value ) * 100 ;
    END IF ;

    l_loc := 'Setting the status ' || l_measure_type || '.' ;
    IF l_pct_change < 0 THEN
      l_status_icon := g_red_down_arrow ;
    ELSIF ((l_pct_change >= 0) AND ( l_pct_change <= 10)) THEN
      l_status_icon := g_green_checkmark ;
    ELSE
      l_status_icon := g_green_up_arrow ;
    END IF ;

    l_loc := 'Inserting / updating total ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_etr_pvt.g_etr_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
         , oki_utl_pub.g_all_k_category_code
         , oki_load_etr_pvt.g_seq_grw_rate_code  ) ;
    FETCH oki_load_etr_pvt.g_etr_csr INTO rec_g_etr_csr ;
    IF oki_load_etr_pvt.g_etr_csr%NOTFOUND THEN
      l_loc := 'Insert the new record -- ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_etr_pvt.ins_exp_to_rnwl(
            p_summary_build_date   => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id     => oki_utl_pub.g_all_organization_id
          , p_organization_name    => oki_utl_pub.g_all_organization_name
          , p_customer_party_id    => oki_utl_pub.g_all_customer_id
          , p_customer_name        => oki_utl_pub.g_all_customer_name
          , p_scs_code             => oki_utl_pub.g_all_k_category_code
          , p_measure_code         => oki_load_etr_pvt.g_seq_grw_rate_code
          , p_measure_code_meaning => l_bin_code_meaning
          , p_bin_code_seq         => l_bin_code_seq
          , p_measure_value1       => l_curr_value
          , p_measure_value2       => l_pct_change
          , p_measure_value3       => l_status_icon
          , x_retcode              => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_etr_pvt.upd_exp_to_rnwl(
            p_measure_value1       => l_curr_value
          , p_measure_value2       => l_pct_change
          , p_measure_value3       => l_status_icon
          , p_measure_code_meaning => l_bin_code_meaning
          , p_bin_code_seq         => l_bin_code_seq
          , p_organization_name    => oki_utl_pub.g_all_organization_name
          , p_customer_name        => oki_utl_pub.g_all_customer_name
          , p_etr_rowid            => rec_g_etr_csr.rowid
          , x_retcode              => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_etr_pvt.g_etr_csr ;

    --
    -- Process Renewal Opportunity Outstanding record
    --

    -- Reset value
    l_curr_value := 0 ;
    l_prev_value := 0 ;
    l_measure_type := 'Renewal Opportunity Outstanding' ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_etr_pvt.g_bin_id
            , oki_load_etr_pvt.g_rnwl_oppty_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

    -- Get the current value
    l_loc := 'Opening cursor to determine ' || l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_rnwl_oppty_all_csr ( oki_utl_pub.g_glpr_qtr_end_date ) ;
    FETCH oki_utl_pvt.g_rnwl_oppty_all_csr INTO rec_l_rnwl_oppty_all_csr ;
    IF oki_utl_pvt.g_rnwl_oppty_all_csr%FOUND THEN
      l_curr_value := rec_l_rnwl_oppty_all_csr.value ;
    END IF ;
    CLOSE oki_utl_pvt.g_rnwl_oppty_all_csr ;

    -- Get the previous value
    l_loc := 'Opening cursor to determine ' || l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_rnwl_oppty_all_csr ( oki_utl_pub.g_py_glpr_qtr_end_date ) ;
    FETCH oki_utl_pvt.g_rnwl_oppty_all_csr INTO rec_l_rnwl_oppty_all_csr ;
    IF oki_utl_pvt.g_rnwl_oppty_all_csr%FOUND THEN
      l_prev_value := rec_l_rnwl_oppty_all_csr.value ;
    END IF ;
    CLOSE oki_utl_pvt.g_rnwl_oppty_all_csr ;

    l_loc := 'Setting the percent change ' || l_measure_type || '.' ;
    IF l_prev_value = 0 THEN
      l_pct_change := 100 ;
    ELSE
      l_pct_change := (( l_curr_value - l_prev_value ) /
                         l_prev_value ) * 100 ;
    END IF ;

    IF l_pct_change < 0 THEN
      l_status_icon := g_red_down_arrow ;
    ELSIF ((l_pct_change >= 0) AND ( l_pct_change <= 10)) THEN
      l_status_icon := g_green_checkmark ;
    ELSE
      l_status_icon := g_green_up_arrow ;
    END IF ;

    l_loc := 'Inserting / updating total ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_etr_pvt.g_etr_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
         , oki_utl_pub.g_all_k_category_code
         , oki_load_etr_pvt.g_rnwl_oppty_code ) ;
    FETCH oki_load_etr_pvt.g_etr_csr INTO rec_g_etr_csr ;
    IF oki_load_etr_pvt.g_etr_csr%NOTFOUND THEN
      l_loc := 'Insert the new record -- ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_etr_pvt.ins_exp_to_rnwl(
            p_summary_build_date   => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id     => oki_utl_pub.g_all_organization_id
          , p_organization_name    => oki_utl_pub.g_all_organization_name
          , p_customer_party_id    => oki_utl_pub.g_all_customer_id
          , p_customer_name        => oki_utl_pub.g_all_customer_name
          , p_scs_code             => oki_utl_pub.g_all_k_category_code
          , p_measure_code         => oki_load_etr_pvt.g_rnwl_oppty_code
          , p_measure_code_meaning => l_bin_code_meaning
          , p_bin_code_seq         => l_bin_code_seq
          , p_measure_value1       => l_curr_value
          , p_measure_value2       => l_pct_change
          , p_measure_value3       => l_status_icon
          , x_retcode              => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_etr_pvt.upd_exp_to_rnwl(
            p_measure_value1       => l_curr_value
          , p_measure_value2       => l_pct_change
          , p_measure_value3       => l_status_icon
          , p_measure_code_meaning => l_bin_code_meaning
          , p_bin_code_seq         => l_bin_code_seq
          , p_organization_name    => oki_utl_pub.g_all_organization_name
          , p_customer_name        => oki_utl_pub.g_all_customer_name
          , p_etr_rowid            => rec_g_etr_csr.rowid
          , x_retcode              => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_etr_pvt.g_etr_csr ;


    --
    -- Process Auto Renewal % By Volume record
    --

    -- Reset value
    l_curr_value := 0 ;
    l_prev_value := 0 ;
    l_measure_type := 'Auto Renewal % By Volume' ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_etr_pvt.g_bin_id
            , oki_load_etr_pvt.g_auto_rnwl_vol_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

    l_curr_value := NULL ;


    l_loc := 'Inserting / updating total ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_etr_pvt.g_etr_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
         , oki_utl_pub.g_all_k_category_code
         , oki_load_etr_pvt.g_auto_rnwl_vol_code ) ;
    FETCH oki_load_etr_pvt.g_etr_csr INTO rec_g_etr_csr ;
    IF oki_load_etr_pvt.g_etr_csr%NOTFOUND THEN
      l_loc := 'Insert the new record -- ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_etr_pvt.ins_exp_to_rnwl(
            p_summary_build_date   => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id     => oki_utl_pub.g_all_organization_id
          , p_organization_name    => oki_utl_pub.g_all_organization_name
          , p_customer_party_id    => oki_utl_pub.g_all_customer_id
          , p_customer_name        => oki_utl_pub.g_all_customer_name
          , p_scs_code             => oki_utl_pub.g_all_k_category_code
          , p_measure_code_meaning => l_bin_code_meaning
          , p_bin_code_seq         => l_bin_code_seq
          , p_measure_code         => oki_load_etr_pvt.g_auto_rnwl_vol_code
          , p_measure_value1       => l_curr_value
          , p_measure_value2       => NULL
          , p_measure_value3       => NULL
          , x_retcode              => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_etr_pvt.upd_exp_to_rnwl(
            p_measure_value1       => l_curr_value
          , p_measure_value2       => NULL
          , p_measure_value3       => NULL
          , p_measure_code_meaning => l_bin_code_meaning
          , p_bin_code_seq         => l_bin_code_seq
          , p_organization_name    => oki_utl_pub.g_all_organization_name
          , p_customer_name        => oki_utl_pub.g_all_customer_name
          , p_etr_rowid            => rec_g_etr_csr.rowid
          , x_retcode              => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_etr_pvt.g_etr_csr ;



    --
    -- Process Auto Renewal Rate record
    --

    -- Reset value
    l_curr_value := 0 ;
    l_prev_value := 0 ;
    l_measure_type := 'Auto Renewal Rate' ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_etr_pvt.g_bin_id
            , oki_load_etr_pvt.g_auto_rnwl_rate_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

    l_curr_value := NULL ;

    l_loc := 'Inserting / updating total ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_etr_pvt.g_etr_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
         , oki_utl_pub.g_all_k_category_code
         , oki_load_etr_pvt.g_auto_rnwl_rate_code  ) ;
    FETCH oki_load_etr_pvt.g_etr_csr INTO rec_g_etr_csr ;
    IF oki_load_etr_pvt.g_etr_csr%NOTFOUND THEN
      l_loc := 'Insert the new record -- ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_etr_pvt.ins_exp_to_rnwl(
            p_summary_build_date   => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id     => oki_utl_pub.g_all_organization_id
          , p_organization_name    => oki_utl_pub.g_all_organization_name
          , p_customer_party_id    => oki_utl_pub.g_all_customer_id
          , p_customer_name        => oki_utl_pub.g_all_customer_name
          , p_scs_code             => oki_utl_pub.g_all_k_category_code
          , p_measure_code         => oki_load_etr_pvt.g_auto_rnwl_rate_code
          , p_measure_code_meaning => l_bin_code_meaning
          , p_bin_code_seq         => l_bin_code_seq
          , p_measure_value1       => l_curr_value
          , p_measure_value2       => NULL
          , p_measure_value3       => NULL
          , x_retcode              => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_etr_pvt.upd_exp_to_rnwl(
            p_measure_value1       => l_curr_value
          , p_measure_value2       => NULL
          , p_measure_value3       => NULL
          , p_measure_code_meaning => l_bin_code_meaning
          , p_bin_code_seq         => l_bin_code_seq
          , p_organization_name    => oki_utl_pub.g_all_organization_name
          , p_customer_name        => oki_utl_pub.g_all_customer_name
          , p_etr_rowid            => rec_g_etr_csr.rowid
          , x_retcode              => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_etr_pvt.g_etr_csr ;


    --
    -- Process Renewal Price Uplift record
    --

   -- Reset value
    l_curr_value := 0 ;
    l_prev_value := 0 ;
    l_measure_type := 'Renewal Price Uplift' ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_etr_pvt.g_bin_id
            , oki_load_etr_pvt.g_rnwl_prc_uplft_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;


    l_curr_value := NULL ;


    l_loc := 'Inserting / updating total ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_etr_pvt.g_etr_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
         , oki_utl_pub.g_all_k_category_code
         , oki_load_etr_pvt.g_rnwl_prc_uplft_code ) ;
    FETCH oki_load_etr_pvt.g_etr_csr INTO rec_g_etr_csr ;
    IF oki_load_etr_pvt.g_etr_csr%NOTFOUND THEN
      l_loc := 'Insert the new record -- ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_etr_pvt.ins_exp_to_rnwl(
            p_summary_build_date   => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id     => oki_utl_pub.g_all_organization_id
          , p_organization_name    => oki_utl_pub.g_all_organization_name
          , p_customer_party_id    => oki_utl_pub.g_all_customer_id
          , p_customer_name        => oki_utl_pub.g_all_customer_name
          , p_scs_code             => oki_utl_pub.g_all_k_category_code
          , p_measure_code_meaning => l_bin_code_meaning
          , p_bin_code_seq         => l_bin_code_seq
          , p_measure_code         => oki_load_etr_pvt.g_rnwl_prc_uplft_code
          , p_measure_value1       => l_curr_value
          , p_measure_value2       => NULL
          , p_measure_value3       => NULL
          , x_retcode              => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_etr_pvt.upd_exp_to_rnwl(
            p_measure_value1       => l_curr_value
          , p_measure_value2       => NULL
          , p_measure_value3       => NULL
          , p_measure_code_meaning => l_bin_code_meaning
          , p_bin_code_seq         => l_bin_code_seq
          , p_organization_name    => oki_utl_pub.g_all_organization_name
          , p_customer_name        => oki_utl_pub.g_all_customer_name
          , p_etr_rowid            => rec_g_etr_csr.rowid
          , x_retcode              => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_etr_pvt.g_etr_csr ;

  EXCEPTION
    WHEN oki_utl_pub.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

    WHEN NO_DATA_FOUND THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2' ;

      -- Log the location within the procedure where the error occurred
      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_LOC_IN_PROG_FAILURE');

      fnd_message.set_token(  token => 'LOCATION'
                            , value => l_loc);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode || ' ' || l_sqlerrm );

    WHEN OTHERS THEN

      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2' ;

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_ETR_PVT.CALC_ETR_SUM');

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
                        , buff  => l_sqlcode || ' ' || l_sqlerrm );

  END calc_etr_sum ;
--------------------------------------------------------------------------------
--
-- Procedure which loops through the summary build date and calls procedures
-- to load the expiration to renewal table.
--
--------------------------------------------------------------------------------
  PROCEDURE crt_exp_to_rnwl
  (   p_start_summary_build_date IN  DATE
    , p_end_summary_build_date   IN  DATE
    , x_errbuf                   OUT NOCOPY VARCHAR2
    , x_retcode                  OUT NOCOPY VARCHAR2
  ) IS

  -- Local exception declaration

  -- Exception to immediately exit the procedure
  l_excp_upd_refresh   EXCEPTION ;


  -- Constant declaration

  -- Name of the table for which data is being inserted
  l_table_name  CONSTANT VARCHAR2(30) := 'OKI_EXP_TO_RNWL' ;

  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  l_upper_bound        NUMBER := 0 ;
  l_summary_build_date DATE := NULL ;

  l_ending_period_type VARCHAR2(15) := NULL ;


  BEGIN

    SAVEPOINT oki_etr_exp_to_rnwl ;

    -- initialize return code to success
    l_retcode := '0' ;
    x_retcode := '0' ;

    l_upper_bound := TRUNC(p_end_summary_build_date) -
                           TRUNC(p_start_summary_build_date) + 1 ;

    l_summary_build_date := TRUNC(p_start_summary_build_date) ;

    FOR i IN 1..l_upper_bound  LOOP

      oki_utl_pub.g_summary_build_date := l_summary_build_date ;

      -- Get the GL periods start / end date
      oki_utl_pvt.get_gl_period_date (
            x_retcode  => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;

      -- Procedure to calculate the amounts for the all level
      oki_load_etr_pvt.calc_etr_sum (
            x_retcode  => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;

      -- Procedure to calculate the amounts for the organization level
      oki_load_etr_pvt.calc_etr_dtl1 (
            x_retcode  => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;

      l_summary_build_date := l_summary_build_date + 1 ;

    END LOOP ;

    COMMIT;

    SAVEPOINT oki_etr_upd_refresh ;


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

      ROLLBACK TO oki_etr_upd_refresh ;

    WHEN oki_utl_pub.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

      ROLLBACK TO oki_etr_exp_to_rnwl ;

    WHEN OTHERS THEN

      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2' ;

      -- ROLLBACK all transactions
      ROLLBACK TO oki_etr_exp_to_rnwl ;


      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE' ) ;

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_ETR_PVT.CRT_EXP_TO_RNWL' ) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get ) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm ) ;

  END crt_exp_to_rnwl ;


BEGIN
  -- Initialize the global variables used TO log this job run
  -- FROM concurrent manager
  g_request_id             :=  fnd_global.conc_request_id ;
  g_program_application_id :=  fnd_global.prog_appl_id ;
  g_program_id             :=  fnd_global.conc_program_id ;
  g_program_update_date    :=  SYSDATE ;

END oki_load_etr_pvt ;

/
