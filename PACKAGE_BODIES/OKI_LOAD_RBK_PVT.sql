--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_RBK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_RBK_PVT" AS
/* $Header: OKIRRBKB.pls 115.7 2002/12/01 17:52:54 rpotnuru noship $ */

--------------------------------------------------------------------------------
-- Modification History
-- 26-Dec-2001  mezra        Initial version
-- 18-Jan-2001  mezra        Corrected code passed when checking if quarter
--                           activity record exists.
-- 20-Mar-2002  mezra        Added logic to retrieve previous year and
--                           change percent
-- 08-Apr-2002  mezra        Added logic to load organization_name,
--                           customer_name, measure_code_meaning, bin_code_seq.
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--
--------------------------------------------------------------------------------

  --
  -- Global constant delcaration
  --
  g_b_act_k_code       CONSTANT VARCHAR2(30) := 'BACTK' ;
  g_exp_in_qtr_code    CONSTANT VARCHAR2(30) := 'EXPINQTR' ;
  g_bklg_k_to_rnw_code CONSTANT VARCHAR2(30) := 'BKLGKTORWN' ;
  g_b_rnwl_oppty_code  CONSTANT VARCHAR2(30) := 'BRNWLOPPTY' ;
  g_qtr_actvty_code    CONSTANT VARCHAR2(30) := 'QTRACTVTY' ;
  g_bklg_k_rnwed_code  CONSTANT VARCHAR2(30) := 'BKLGKRNW' ;
  g_k_rnwed_code       CONSTANT VARCHAR2(30) := 'KRNW' ;
  g_new_bsn_code       CONSTANT VARCHAR2(30) := 'NEWBUS' ;
  g_trmn_k_code        CONSTANT VARCHAR2(30) := 'TRMNK' ;
  g_e_act_k_code       CONSTANT VARCHAR2(30) := 'ENDACTK' ;

  g_bin_id   VARCHAR2(30) := 'OKI_RNWL_BKNG_RPT' ;

  --
  -- Global cursor declaration
  --

  -- Cursor to retrieve the rowid for the selected record
  -- If the rowid exists, then the selected record will be
  -- updated, else it is inserted into the table.
  CURSOR g_rbk_csr
  (
     p_summary_build_date IN  DATE
   , p_authoring_org_id   IN  NUMBER
   , p_customer_party_id  IN  NUMBER
   , p_scs_code           IN  VARCHAR2
   , p_measure_code       IN  VARCHAR2
  ) IS
    SELECT rowid
    FROM   oki_rnwl_bookings rbk
    WHERE  rbk.summary_build_date    = p_summary_build_date
    AND    rbk.authoring_org_id      = p_authoring_org_id
    AND    rbk.customer_party_id     = p_customer_party_id
    AND    rbk.scs_code              = p_scs_code
    AND    rbk.measure_code          = p_measure_code
    ;
  rec_g_rbk_csr g_rbk_csr%ROWTYPE ;

--------------------------------------------------------------------------------
--
--Procedure to insert records into the oki_rnwl_bookings table.
--
--------------------------------------------------------------------------------
  PROCEDURE ins_rnwl_bkng
  (
      p_summary_build_date        IN  DATE
    , p_authoring_org_id          IN  NUMBER
    , p_organization_name         IN  VARCHAR2
    , p_customer_party_id         IN  NUMBER
    , p_customer_name             IN  VARCHAR2
    , p_scs_code                  IN  VARCHAR2
    , p_measure_code              IN  VARCHAR2
    , p_measure_code_meaning      IN  VARCHAR2
    , p_bin_code_seq              IN  NUMBER
    , p_curr_base_contract_amount IN  NUMBER
    , p_prev_base_contract_amount IN  NUMBER
    , x_retcode                   OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  BEGIN

    -- initialize return code to success
    x_retcode := '0';

    INSERT INTO oki_rnwl_bookings
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
           , curr_base_contract_amount
           , prev_base_contract_amount
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
           , p_curr_base_contract_amount
           , p_prev_base_contract_amount
           , oki_load_rbk_pvt.g_request_id
           , oki_load_rbk_pvt.g_program_application_id
           , oki_load_rbk_pvt.g_program_id
           , oki_load_rbk_pvt.g_program_update_date ) ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_TABLE_LOAD_FAILURE' ) ;

      fnd_message.set_token(  token => 'TABLE_NAME'
                            , value => 'OKI_RNWL_BOOKINGS' ) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get ) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '|| l_sqlerrm ) ;
  END ins_rnwl_bkng ;
--------------------------------------------------------------------------------
--
--  Procedure to update records in the oki_rnwl_bookings table.
--
--------------------------------------------------------------------------------
  PROCEDURE upd_rnwl_bkng
  (
      p_curr_base_contract_amount IN  NUMBER
    , p_prev_base_contract_amount IN  NUMBER
    , p_measure_code_meaning      IN  VARCHAR2
    , p_bin_code_seq              IN  NUMBER
    , p_organization_name         IN  VARCHAR2
    , p_customer_name             IN  VARCHAR2
    , p_rbk_rowid                 IN  ROWID
    , x_retcode                   OUT NOCOPY VARCHAR2

  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  BEGIN

    -- initialize return code to success
    x_retcode := '0';

    UPDATE oki_rnwl_bookings SET
        curr_base_contract_amount = p_curr_base_contract_amount
      , prev_base_contract_amount = p_prev_base_contract_amount
      , measure_code_meaning      = p_measure_code_meaning
      , bin_code_seq              = p_bin_code_seq
      , organization_name         = p_organization_name
      , customer_name             = p_customer_name
      , request_id                = oki_load_rbk_pvt.g_request_id
      , program_application_id    = oki_load_rbk_pvt.g_program_application_id
      , program_id                = oki_load_rbk_pvt.g_program_id
      , program_update_date       = oki_load_rbk_pvt.g_program_update_date
    WHERE ROWID =  p_rbk_rowid ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE' ) ;

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_RBK_PVT.UPD_RNWL_BKNG' ) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get );

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '|| l_sqlerrm ) ;
  END upd_rnwl_bkng ;

--------------------------------------------------------------------------------
--
--  Procedure to calculate the renewal bookings at the organization level.
--
--------------------------------------------------------------------------------
  PROCEDURE calc_rbk_dtl1
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

  l_measure_type     VARCHAR2(60) := NULL ;

  l_bin_code_meaning  VARCHAR2(240) := NULL ;
  l_bin_code_seq      NUMBER := NULL ;

  rec_l_tactk_by_org_csr        oki_utl_pvt.g_tactk_by_org_csr_row ;
  rec_l_k_exp_in_qtr_by_org_csr oki_utl_pvt.g_k_exp_in_qtr_by_org_csr_row ;
  rec_l_bin_disp_lkup_csr       oki_utl_pvt.g_bin_disp_lkup_csr_row ;

  -- Holds the current measure values for the renewal bookings bin
  l_curr_b_act_k        NUMBER := 0 ;
  l_curr_k_exp_in_qtr   NUMBER := 0 ;
  l_curr_bklg_k_to_rnw  NUMBER := 0 ;
  l_curr_b_rnwl_oppty   NUMBER := 0 ;
  l_curr_bklg_k_rwned   NUMBER := 0 ;
  l_curr_k_rnwed        NUMBER := 0 ;
  l_curr_new_bus        NUMBER := 0 ;
  l_curr_trmn_k         NUMBER := 0 ;
  l_curr_e_act_k        NUMBER := 0 ;

  -- Holds the previous measure values for the renewal bookings bin
  l_prev_b_act_k        NUMBER := 0 ;
  l_prev_k_exp_in_qtr   NUMBER := 0 ;
  l_prev_bklg_k_to_rnw  NUMBER := 0 ;
  l_prev_b_rnwl_oppty   NUMBER := 0 ;
  l_prev_bklg_k_rwned   NUMBER := 0 ;
  l_prev_k_rnwed        NUMBER := 0 ;
  l_prev_new_bus        NUMBER := 0 ;
  l_prev_trmn_k         NUMBER := 0 ;
  l_prev_e_act_k        NUMBER := 0 ;


  -- Contracts that have should have been renewed (booked) by the start of
  -- the quarter but were not.  These contracts are the considered
  -- the backlog contracts to be renewed this quarter
  CURSOR l_bklg_k_to_rnw_csr
  (
     p_qtr_start_date   IN DATE
   , p_authoring_org_id IN NUMBER
  ) IS
    SELECT NVL(SUM(base_contract_amount), 0) value
         , COUNT(shd.chr_id) contract_count
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.is_new_yn         IS NULL
    AND    (   shd.date_canceled IS NULL
            OR shd.date_canceled >= p_qtr_start_date )
    AND    (   shd.date_signed   IS NULL
            OR shd.date_signed   >= p_qtr_start_date )
    AND    shd.start_date         < p_qtr_start_date
    AND    shd.base_contract_amount BETWEEN 0
                                        AND oki_utl_pub.g_contract_limit
    AND    shd.authoring_org_id = p_authoring_org_id
    ;
    rec_l_bklg_k_to_rnw_csr l_bklg_k_to_rnw_csr%ROWTYPE ;

  -- Contracts that have been renewed (booked) in this quarter but should have
  -- been booked before this quarter
  CURSOR l_bklg_k_rwned_csr
  (
     p_summary_build_date IN DATE
   , p_qtr_start_date     IN DATE
   , p_authoring_org_id   IN NUMBER
  ) IS
    SELECT NVL(SUM(base_contract_amount), 0) value
       , COUNT(shd.chr_id) contract_count
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.is_new_yn     IS NULL
    AND    shd.date_signed   IS NOT NULL
    AND    shd.date_approved IS NOT NULL
    AND    shd.start_date     < p_qtr_start_date
    AND    GREATEST(shd.date_signed, shd.date_approved )
               BETWEEN p_qtr_start_date AND p_summary_build_date
    AND    shd.base_contract_amount BETWEEN 0
                                        AND oki_utl_pub.g_contract_limit
    AND    shd.authoring_org_id = p_authoring_org_id
    ;
  rec_l_bklg_k_rwned_csr l_bklg_k_rwned_csr%ROWTYPE ;

  -- Contracts that have been renewed in the quarter
  CURSOR l_k_rnwed_csr
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
    rec_l_k_rnwed_csr l_k_rnwed_csr%ROWTYPE ;

  -- Contracts that became active between the start of quarter
  -- and the summary build date and are not a result of a renewal
  CURSOR l_new_bus_csr
  (
     p_summary_build_date IN DATE
   , p_qtr_start_date     IN DATE
   , p_authoring_org_id   IN NUMBER
  ) IS
    SELECT NVL(SUM(base_contract_amount), 0) value
         , COUNT(shd.chr_id) contract_count
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.date_signed   <= p_summary_build_date
    AND    shd.date_approved <= p_summary_build_date
    AND    shd.is_new_yn      = 'Y'
    AND    shd.start_date BETWEEN p_qtr_start_date
                               AND p_summary_build_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated  > p_summary_build_date )
    AND    shd.base_contract_amount BETWEEN 0
                                        AND oki_utl_pub.g_contract_limit
    AND    shd.authoring_org_id = p_authoring_org_id
    ;
  rec_l_new_bus_csr l_new_bus_csr%ROWTYPE ;

  -- Contracts that were terminated between the start of the quarter and the
  -- summary build date
  CURSOR l_trmn_k_csr
  (
     p_summary_build_date IN DATE
   , p_qtr_start_date     IN DATE
   , p_authoring_org_id   IN NUMBER
  ) IS
    SELECT NVL(SUM(base_contract_amount), 0)  value
         , COUNT(shd.chr_id) contract_count
    FROM   oki_sales_k_hdrs shd
    WHERE  date_terminated  BETWEEN p_qtr_start_date
                                AND p_summary_build_date
    AND    shd.date_signed   IS NOT NULL
    AND    shd.date_approved IS NOT NULL
    AND    shd.base_contract_amount BETWEEN 0
                                        AND oki_utl_pub.g_contract_limit
    AND    shd.authoring_org_id = p_authoring_org_id
  ;
  rec_l_trmn_k_csr l_trmn_k_csr%ROWTYPE ;

  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    << g_org_csr_loop >>
    -- Loop through all the organizations to calculate the
    -- appropriate amounts
    FOR rec_g_org_csr IN oki_utl_pvt.g_org_csr LOOP

      --
      -- Process Beginning Active Contracts record
      --

      l_measure_type := 'Beginning Active Contracts By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
              , oki_load_rbk_pvt.g_b_act_k_code ) ;
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
           oki_utl_pub.g_glpr_qtr_start_date
         , rec_g_org_csr.authoring_org_id ) ;
      FETCH oki_utl_pvt.g_tactk_by_org_csr INTO rec_l_tactk_by_org_csr ;
      IF oki_utl_pvt.g_tactk_by_org_csr%FOUND THEN
        l_curr_b_act_k := rec_l_tactk_by_org_csr.value ;
      END IF ;
      CLOSE oki_utl_pvt.g_tactk_by_org_csr ;

      -- Get the previous value
      l_loc := 'Opening Cursor to determine previous ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_tactk_by_org_csr (
           oki_utl_pub.g_py_glpr_qtr_start_date,
           rec_g_org_csr.authoring_org_id ) ;
      FETCH oki_utl_pvt.g_tactk_by_org_csr INTO rec_l_tactk_by_org_csr ;
      IF oki_utl_pvt.g_tactk_by_org_csr%FOUND THEN
        l_prev_b_act_k := rec_l_tactk_by_org_csr.value ;
      END IF ;
      CLOSE oki_utl_pvt.g_tactk_by_org_csr ;

      l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_rbk_pvt.g_rbk_csr (
                 oki_utl_pub.g_summary_build_date
               , rec_g_org_csr.authoring_org_id
               , oki_utl_pub.g_all_customer_id
               , oki_utl_pub.g_all_k_category_code
               , oki_load_rbk_pvt.g_b_act_k_code ) ;
      FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
      IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
        l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_rbk_pvt.ins_rnwl_bkng (
              p_summary_build_date        => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id          => rec_g_org_csr.authoring_org_id
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_party_id         => oki_utl_pub.g_all_customer_id
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_scs_code                  => oki_utl_pub.g_all_k_category_code
            , p_measure_code              => oki_load_rbk_pvt.g_b_act_k_code
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_curr_base_contract_amount => l_curr_b_act_k
            , p_prev_base_contract_amount => l_prev_b_act_k
            , x_retcode                   => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_rbk_pvt.upd_rnwl_bkng (
              p_curr_base_contract_amount => l_curr_b_act_k
            , p_prev_base_contract_amount => l_prev_b_act_k
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_rbk_rowid                 => rec_g_rbk_csr.rowid
            , x_retcode                   => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_rbk_pvt.g_rbk_csr ;

      --
      -- Process Expiring During Quarter record
      --

      l_measure_type := 'Expiring During Quarter By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
              , oki_load_rbk_pvt.g_exp_in_qtr_code ) ;
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
      OPEN oki_utl_pvt.g_k_exp_in_qtr_by_org_csr (
             oki_utl_pub.g_glpr_qtr_start_date
           , oki_utl_pub.g_glpr_qtr_end_date
           , rec_g_org_csr.authoring_org_id ) ;
      FETCH oki_utl_pvt.g_k_exp_in_qtr_by_org_csr INTO
            rec_l_k_exp_in_qtr_by_org_csr ;
      IF oki_utl_pvt.g_k_exp_in_qtr_by_org_csr%FOUND THEN
        l_curr_k_exp_in_qtr := rec_l_k_exp_in_qtr_by_org_csr.value ;
      END IF ;
      CLOSE oki_utl_pvt.g_k_exp_in_qtr_by_org_csr ;

      -- Get the previous value
      l_loc := 'Opening Cursor to determine previous ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_k_exp_in_qtr_by_org_csr (
             oki_utl_pub.g_py_glpr_qtr_start_date
           , oki_utl_pub.g_py_glpr_qtr_end_date
           , rec_g_org_csr.authoring_org_id ) ;
      FETCH oki_utl_pvt.g_k_exp_in_qtr_by_org_csr INTO
            rec_l_k_exp_in_qtr_by_org_csr ;
      IF oki_utl_pvt.g_k_exp_in_qtr_by_org_csr%FOUND THEN
        l_prev_k_exp_in_qtr := rec_l_k_exp_in_qtr_by_org_csr.value ;
      END IF ;
      CLOSE oki_utl_pvt.g_k_exp_in_qtr_by_org_csr ;

      l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_rbk_pvt.g_rbk_csr (
             oki_utl_pub.g_summary_build_date
           , rec_g_org_csr.authoring_org_id
           , oki_utl_pub.g_all_customer_id
           , oki_utl_pub.g_all_k_category_code
           , oki_load_rbk_pvt.g_exp_in_qtr_code ) ;
      FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
      IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
        l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_rbk_pvt.ins_rnwl_bkng (
              p_summary_build_date        => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id          => rec_g_org_csr.authoring_org_id
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_party_id         => oki_utl_pub.g_all_customer_id
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_scs_code                  => oki_utl_pub.g_all_k_category_code
            , p_measure_code              => oki_load_rbk_pvt.g_exp_in_qtr_code
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_curr_base_contract_amount => l_curr_k_exp_in_qtr
            , p_prev_base_contract_amount => l_prev_k_exp_in_qtr
            , x_retcode                   => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_rbk_pvt.upd_rnwl_bkng (
              p_curr_base_contract_amount => l_curr_k_exp_in_qtr
            , p_prev_base_contract_amount => l_prev_k_exp_in_qtr
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_rbk_rowid                 => rec_g_rbk_csr.rowid
            , x_retcode                   => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_rbk_pvt.g_rbk_csr ;

      --
      -- Process Backlog Renewals record
      --

      l_measure_type := 'Backlog Renewals By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
              , oki_load_rbk_pvt.g_bklg_k_to_rnw_code ) ;
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
      OPEN l_bklg_k_to_rnw_csr ( oki_utl_pub.g_glpr_qtr_start_date,
           rec_g_org_csr.authoring_org_id ) ;
      FETCH l_bklg_k_to_rnw_csr INTO rec_l_bklg_k_to_rnw_csr ;
      IF l_bklg_k_to_rnw_csr%FOUND THEN
        l_curr_bklg_k_to_rnw := rec_l_bklg_k_to_rnw_csr.value ;
      END IF ;
      CLOSE l_bklg_k_to_rnw_csr ;

      -- Get the previous value
      l_loc := 'Opening Cursor to determine previous ' ||
                l_measure_type || '.' ;
      OPEN l_bklg_k_to_rnw_csr ( oki_utl_pub.g_py_glpr_qtr_start_date,
           rec_g_org_csr.authoring_org_id ) ;
      FETCH l_bklg_k_to_rnw_csr INTO rec_l_bklg_k_to_rnw_csr ;
      IF l_bklg_k_to_rnw_csr%FOUND THEN
        l_prev_bklg_k_to_rnw := rec_l_bklg_k_to_rnw_csr.value ;
      END IF ;
      CLOSE l_bklg_k_to_rnw_csr ;

      l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
           , rec_g_org_csr.authoring_org_id, oki_utl_pub.g_all_customer_id
           , oki_utl_pub.g_all_k_category_code
           , oki_load_rbk_pvt.g_bklg_k_to_rnw_code ) ;
      FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
      IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
        l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_rbk_pvt.ins_rnwl_bkng (
              p_summary_build_date        => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id          => rec_g_org_csr.authoring_org_id
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_party_id         => oki_utl_pub.g_all_customer_id
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_scs_code                  => oki_utl_pub.g_all_k_category_code
            , p_measure_code              => oki_load_rbk_pvt.g_bklg_k_to_rnw_code
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_curr_base_contract_amount => l_curr_bklg_k_to_rnw
            , p_prev_base_contract_amount => l_prev_bklg_k_to_rnw
            , x_retcode                   => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_rbk_pvt.upd_rnwl_bkng (
              p_curr_base_contract_amount => l_curr_bklg_k_to_rnw
            , p_prev_base_contract_amount => l_prev_bklg_k_to_rnw
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_rbk_rowid                 => rec_g_rbk_csr.rowid
            , x_retcode                   => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
       END IF ;
      END IF ;
      CLOSE oki_load_rbk_pvt.g_rbk_csr ;

      --
      -- Process Beginning Renewal Opportunity record
      --

      l_measure_type := 'Beginning Renewal Opportunity By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
              , oki_load_rbk_pvt.g_b_rnwl_oppty_code ) ;
      FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
      IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
        l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
        l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
      ELSE
        RAISE NO_DATA_FOUND ;
      END IF ;
      CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

      l_curr_b_rnwl_oppty := l_curr_k_exp_in_qtr + l_curr_bklg_k_to_rnw ;
      l_prev_b_rnwl_oppty := l_prev_k_exp_in_qtr + l_prev_bklg_k_to_rnw ;

      l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
           , rec_g_org_csr.authoring_org_id, oki_utl_pub.g_all_customer_id
           , oki_utl_pub.g_all_k_category_code
           , oki_load_rbk_pvt.g_b_rnwl_oppty_code ) ;
      FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
      IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
        l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_rbk_pvt.ins_rnwl_bkng (
              p_summary_build_date        => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id          => rec_g_org_csr.authoring_org_id
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_party_id         => oki_utl_pub.g_all_customer_id
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_scs_code                  => oki_utl_pub.g_all_k_category_code
            , p_measure_code              => oki_load_rbk_pvt.g_b_rnwl_oppty_code
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_curr_base_contract_amount => l_curr_b_rnwl_oppty
            , p_prev_base_contract_amount => l_prev_b_rnwl_oppty
            , x_retcode                   => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_rbk_pvt.upd_rnwl_bkng (
              p_curr_base_contract_amount => l_curr_b_rnwl_oppty
            , p_prev_base_contract_amount => l_prev_b_rnwl_oppty
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_rbk_rowid                 => rec_g_rbk_csr.rowid
            , x_retcode                   => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_rbk_pvt.g_rbk_csr ;

      --
      -- Process Backlog Contracts Renewed record
      --

      l_measure_type := 'Backlog Contracts Renewed By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
              , oki_load_rbk_pvt.g_bklg_k_rnwed_code ) ;
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
      OPEN l_bklg_k_rwned_csr( oki_utl_pub.g_summary_build_date,
           oki_utl_pub.g_glpr_qtr_start_date
         , rec_g_org_csr.authoring_org_id ) ;
      FETCH l_bklg_k_rwned_csr INTO rec_l_bklg_k_rwned_csr ;
      IF l_bklg_k_rwned_csr%FOUND THEN
        l_curr_bklg_k_rwned := rec_l_bklg_k_rwned_csr.value ;
      END IF ;
      CLOSE l_bklg_k_rwned_csr;

      -- Get the previous value
      l_loc := 'Opening cursor to determine previous ' ||
                l_measure_type || '.' ;
      OPEN l_bklg_k_rwned_csr( oki_utl_pub.g_py_summary_build_date,
           oki_utl_pub.g_py_glpr_qtr_start_date
         , rec_g_org_csr.authoring_org_id ) ;
      FETCH l_bklg_k_rwned_csr INTO rec_l_bklg_k_rwned_csr ;
      IF l_bklg_k_rwned_csr%FOUND THEN
        l_prev_bklg_k_rwned := rec_l_bklg_k_rwned_csr.value ;
      END IF ;
      CLOSE l_bklg_k_rwned_csr ;

      l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
           , rec_g_org_csr.authoring_org_id, oki_utl_pub.g_all_customer_id
           , oki_utl_pub.g_all_k_category_code
           , oki_load_rbk_pvt.g_bklg_k_rnwed_code ) ;
      FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
      IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
        l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_rbk_pvt.ins_rnwl_bkng (
              p_summary_build_date        => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id          => rec_g_org_csr.authoring_org_id
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_party_id         => oki_utl_pub.g_all_customer_id
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_scs_code                  => oki_utl_pub.g_all_k_category_code
            , p_measure_code              => oki_load_rbk_pvt.g_bklg_k_rnwed_code
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_curr_base_contract_amount => l_curr_bklg_k_rwned
            , p_prev_base_contract_amount => l_prev_bklg_k_rwned
            , x_retcode                   => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_rbk_pvt.upd_rnwl_bkng (
              p_curr_base_contract_amount => l_curr_bklg_k_rwned
            , p_prev_base_contract_amount => l_prev_bklg_k_rwned
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_rbk_rowid                 => rec_g_rbk_csr.rowid
            , x_retcode                   => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_rbk_pvt.g_rbk_csr ;

      --
      -- Process Contracts Renewed record
      --

      l_measure_type := 'Contracts Renewed By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
              , oki_load_rbk_pvt.g_k_rnwed_code ) ;
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
      OPEN l_k_rnwed_csr( oki_utl_pub.g_glpr_qtr_start_date
           , oki_utl_pub.g_glpr_qtr_end_date
           , rec_g_org_csr.authoring_org_id ) ;
      FETCH l_k_rnwed_csr INTO rec_l_k_rnwed_csr ;
      IF l_k_rnwed_csr%FOUND THEN
        l_curr_k_rnwed := rec_l_k_rnwed_csr.value ;
      END IF ;
      CLOSE l_k_rnwed_csr ;

      -- Get the previous value
      l_loc := 'Opening Cursor to determine previous ' ||
                l_measure_type || '.' ;
      OPEN l_k_rnwed_csr( oki_utl_pub.g_py_glpr_qtr_start_date
           , oki_utl_pub.g_py_glpr_qtr_end_date
           , rec_g_org_csr.authoring_org_id ) ;
      FETCH l_k_rnwed_csr INTO rec_l_k_rnwed_csr ;
      IF l_k_rnwed_csr%FOUND THEN
        l_prev_k_rnwed := rec_l_k_rnwed_csr.value ;
      END IF ;
      CLOSE l_k_rnwed_csr ;

      l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
           , rec_g_org_csr.authoring_org_id, oki_utl_pub.g_all_customer_id
           , oki_utl_pub.g_all_k_category_code
           , oki_load_rbk_pvt.g_k_rnwed_code ) ;
      FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
      IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
        l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_rbk_pvt.ins_rnwl_bkng (
              p_summary_build_date        => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id          => rec_g_org_csr.authoring_org_id
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_party_id         => oki_utl_pub.g_all_customer_id
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_scs_code                  => oki_utl_pub.g_all_k_category_code
            , p_measure_code              => oki_load_rbk_pvt.g_k_rnwed_code
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_curr_base_contract_amount => l_curr_k_rnwed
            , p_prev_base_contract_amount => l_prev_k_rnwed
            , x_retcode                   => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_rbk_pvt.upd_rnwl_bkng (
              p_curr_base_contract_amount => l_curr_k_rnwed
            , p_prev_base_contract_amount => l_prev_k_rnwed
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_rbk_rowid                 => rec_g_rbk_csr.rowid
            , x_retcode                   => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_rbk_pvt.g_rbk_csr ;

      --
      -- Process New Business record
      --

      l_measure_type := 'New Business By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
              , oki_load_rbk_pvt.g_new_bsn_code ) ;
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
      OPEN l_new_bus_csr( oki_utl_pub.g_summary_build_date
           , oki_utl_pub.g_glpr_qtr_start_date
           , rec_g_org_csr.authoring_org_id ) ;
      FETCH l_new_bus_csr INTO rec_l_new_bus_csr ;
      IF l_new_bus_csr%FOUND THEN
        l_curr_new_bus := rec_l_new_bus_csr.value ;
      END IF ;
      CLOSE l_new_bus_csr ;

      -- Get the previous value
    l_loc := 'Opening Cursor to determine previous ' ||
              l_measure_type || '.' ;
    OPEN l_new_bus_csr( oki_utl_pub.g_py_summary_build_date
         , oki_utl_pub.g_py_glpr_qtr_start_date
         , rec_g_org_csr.authoring_org_id ) ;
    FETCH l_new_bus_csr INTO rec_l_new_bus_csr ;
    IF l_new_bus_csr%FOUND THEN
      l_prev_new_bus := rec_l_new_bus_csr.value ;
    END IF ;
    CLOSE l_new_bus_csr ;

      l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
           , rec_g_org_csr.authoring_org_id, oki_utl_pub.g_all_customer_id
           , oki_utl_pub.g_all_k_category_code
           , oki_load_rbk_pvt.g_new_bsn_code ) ;
      FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
      IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
        l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_rbk_pvt.ins_rnwl_bkng (
              p_summary_build_date        => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id          => rec_g_org_csr.authoring_org_id
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_party_id         => oki_utl_pub.g_all_customer_id
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_scs_code                  => oki_utl_pub.g_all_k_category_code
            , p_measure_code              => oki_load_rbk_pvt.g_new_bsn_code
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_curr_base_contract_amount => l_curr_new_bus
            , p_prev_base_contract_amount => l_prev_new_bus
            , x_retcode                   => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_rbk_pvt.upd_rnwl_bkng (
              p_curr_base_contract_amount => l_curr_new_bus
            , p_prev_base_contract_amount => l_prev_new_bus
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_rbk_rowid                 => rec_g_rbk_csr.rowid
            , x_retcode                   => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_rbk_pvt.g_rbk_csr ;

      --
      -- Process Terminated Contracts record
      --

      l_measure_type := 'Terminated Contracts By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
              , oki_load_rbk_pvt.g_trmn_k_code ) ;
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
      OPEN l_trmn_k_csr( oki_utl_pub.g_summary_build_date
           , oki_utl_pub.g_glpr_qtr_start_date
           , rec_g_org_csr.authoring_org_id ) ;
      FETCH l_trmn_k_csr INTO rec_l_trmn_k_csr ;
      IF l_trmn_k_csr%FOUND THEN
        l_curr_trmn_k := rec_l_trmn_k_csr.value ;
      END IF ;
      CLOSE l_trmn_k_csr ;

      -- Get the previous value
      l_loc := 'Opening Cursor to determine previous ' ||
                l_measure_type || '.' ;
      OPEN l_trmn_k_csr( oki_utl_pub.g_py_summary_build_date
           , oki_utl_pub.g_py_glpr_qtr_start_date
           , rec_g_org_csr.authoring_org_id ) ;
      FETCH l_trmn_k_csr INTO rec_l_trmn_k_csr ;
      IF l_trmn_k_csr%FOUND THEN
        l_prev_trmn_k := rec_l_trmn_k_csr.value ;
      END IF ;
      CLOSE l_trmn_k_csr ;

      l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
           , rec_g_org_csr.authoring_org_id, oki_utl_pub.g_all_customer_id
           , oki_utl_pub.g_all_k_category_code
           , oki_load_rbk_pvt.g_trmn_k_code ) ;
      FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
      IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
        l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_rbk_pvt.ins_rnwl_bkng (
              p_summary_build_date        => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id          => rec_g_org_csr.authoring_org_id
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_party_id         => oki_utl_pub.g_all_customer_id
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_scs_code                  => oki_utl_pub.g_all_k_category_code
            , p_measure_code              => oki_load_rbk_pvt.g_trmn_k_code
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_curr_base_contract_amount => l_curr_trmn_k
            , p_prev_base_contract_amount => l_prev_trmn_k
            , x_retcode                   => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_rbk_pvt.upd_rnwl_bkng (
              p_curr_base_contract_amount => l_curr_trmn_k
            , p_prev_base_contract_amount => l_prev_trmn_k
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_rbk_rowid                 => rec_g_rbk_csr.rowid
            , x_retcode                   => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_rbk_pvt.g_rbk_csr ;

      --
      -- Process Ending Active Contracts record
      --

      l_measure_type := 'Ending Active Contracts By Organization' ;

      -- Get the bin display lookup values
      l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
                l_measure_type || '.' ;
      OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
              , oki_load_rbk_pvt.g_e_act_k_code ) ;
      FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
      IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
        l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
        l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
      ELSE
        RAISE NO_DATA_FOUND ;
      END IF ;
      CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

      -- Get the current value
      l_curr_e_act_k := ( l_curr_b_act_k + l_curr_bklg_k_rwned +
                          l_curr_k_rnwed + l_curr_new_bus ) -
                        ( l_curr_k_exp_in_qtr + l_curr_trmn_k ) ;

      -- Get the previous value
      l_prev_e_act_k := ( l_prev_b_act_k + l_prev_bklg_k_rwned +
                          l_prev_k_rnwed + l_prev_new_bus ) -
                        ( l_prev_k_exp_in_qtr + l_prev_trmn_k ) ;

      l_loc := 'Opening cursor to determine current ' || l_measure_type || '.' ;

      l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
      -- Determine if the record is a new one or an existing one
      OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
           , rec_g_org_csr.authoring_org_id, oki_utl_pub.g_all_customer_id
           , oki_utl_pub.g_all_k_category_code
           , oki_load_rbk_pvt.g_e_act_k_code ) ;
      FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
      IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
        l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
        -- Insert the new record
        oki_load_rbk_pvt.ins_rnwl_bkng (
              p_summary_build_date        => oki_utl_pub.g_summary_build_date
            , p_authoring_org_id          => rec_g_org_csr.authoring_org_id
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_party_id         => oki_utl_pub.g_all_customer_id
            , p_customer_name             => oki_utl_pub.g_all_customer_name
            , p_scs_code                  => oki_utl_pub.g_all_k_category_code
            , p_measure_code              => oki_load_rbk_pvt.g_e_act_k_code
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_curr_base_contract_amount => l_curr_e_act_k
            , p_prev_base_contract_amount => l_prev_e_act_k
            , x_retcode                   => l_retcode ) ;
        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      ELSE
        l_loc := 'Update the record -- ' || l_measure_type || '.' ;
        -- Update the existing record
        oki_load_rbk_pvt.upd_rnwl_bkng (
              p_curr_base_contract_amount => l_curr_e_act_k
            , p_prev_base_contract_amount => l_prev_e_act_k
            , p_measure_code_meaning      => l_bin_code_meaning
            , p_bin_code_seq              => l_bin_code_seq
            , p_organization_name         => rec_g_org_csr.organization_name
            , p_customer_name            => oki_utl_pub.g_all_customer_name
            , p_rbk_rowid                 => rec_g_rbk_csr.rowid
            , x_retcode                   => l_retcode ) ;

        IF l_retcode = '2' THEN
          -- Load failed, exit immediately.
          RAISE oki_utl_pub.g_excp_exit_immediate ;
        END IF ;
      END IF ;
      CLOSE oki_load_rbk_pvt.g_rbk_csr ;

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
                            , value => 'OKI_LOAD_RBK_PVT.CALC_RBK_DLTL1');

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
  END calc_rbk_dtl1 ;

--------------------------------------------------------------------------------
--
--  Procedure to calculate the renewal bookings at the top most levet.
--
--------------------------------------------------------------------------------
  PROCEDURE calc_rbk_sum
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

  l_measure_type     VARCHAR2(60) := NULL ;

  l_bin_code_meaning  VARCHAR2(240) := NULL ;
  l_bin_code_seq      NUMBER := NULL ;

  rec_l_tactk_all_csr        oki_utl_pvt.g_tactk_all_csr_row ;
  rec_l_k_exp_in_qtr_all_csr oki_utl_pvt.g_k_exp_in_qtr_all_csr_row ;
  rec_l_bin_disp_lkup_csr    oki_utl_pvt.g_bin_disp_lkup_csr_row ;

  -- Holds the current measure values for the renewal bookings bin
  l_curr_b_act_k        NUMBER := 0 ;
  l_curr_k_exp_in_qtr   NUMBER := 0 ;
  l_curr_bklg_k_to_rnw  NUMBER := 0 ;
  l_curr_b_rnwl_oppty   NUMBER := 0 ;
  l_curr_bklg_k_rwned   NUMBER := 0 ;
  l_curr_k_rnwed        NUMBER := 0 ;
  l_curr_new_bus        NUMBER := 0 ;
  l_curr_trmn_k         NUMBER := 0 ;
  l_curr_e_act_k        NUMBER := 0 ;

  -- Holds the previous measure values for the renewal bookings bin
  l_prev_b_act_k        NUMBER := 0 ;
  l_prev_k_exp_in_qtr   NUMBER := 0 ;
  l_prev_bklg_k_to_rnw  NUMBER := 0 ;
  l_prev_b_rnwl_oppty   NUMBER := 0 ;
  l_prev_bklg_k_rwned   NUMBER := 0 ;
  l_prev_k_rnwed        NUMBER := 0 ;
  l_prev_new_bus        NUMBER := 0 ;
  l_prev_trmn_k         NUMBER := 0 ;
  l_prev_e_act_k        NUMBER := 0 ;


  -- Contracts that have should have been renewed (booked) by the start of
  -- the quarter but were not.  These contracts are the considered
  -- the backlog contracts to be renewed this quarter
  CURSOR l_bklg_k_to_rnw_csr
  (
     p_qtr_start_date IN DATE
  ) IS
    SELECT NVL(SUM(base_contract_amount), 0) value
         , COUNT(shd.chr_id) contract_count
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.is_new_yn         IS NULL
    AND    (   shd.date_canceled IS NULL
            OR shd.date_canceled >= p_qtr_start_date )
    AND    (   shd.date_signed   IS NULL
            OR shd.date_signed   >= p_qtr_start_date )
    AND    shd.start_date         < p_qtr_start_date
    AND    shd.base_contract_amount BETWEEN 0
                                        AND oki_utl_pub.g_contract_limit
    ;
    rec_l_bklg_k_to_rnw_csr l_bklg_k_to_rnw_csr%ROWTYPE ;

  -- Contracts that have been renewed (booked) in this quarter but should have
  -- been booked before this quarter
  CURSOR l_bklg_k_rwned_csr
  (
     p_summary_build_date IN DATE
   , p_qtr_start_date     IN DATE
  ) IS
    SELECT NVL(SUM(base_contract_amount), 0) value
       , COUNT(shd.chr_id) contract_count
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.is_new_yn     IS NULL
    AND    shd.date_signed   IS NOT NULL
    AND    shd.date_approved IS NOT NULL
    AND    shd.start_date     < p_qtr_start_date
    AND    GREATEST(shd.date_signed, shd.date_approved )
               BETWEEN p_qtr_start_date AND p_summary_build_date
    AND    shd.base_contract_amount BETWEEN 0
                                        AND oki_utl_pub.g_contract_limit
    ;
  rec_l_bklg_k_rwned_csr l_bklg_k_rwned_csr%ROWTYPE ;

  -- Contracts that have been renewed in the quarter
  CURSOR l_k_rnwed_csr
  (
     p_qtr_start_date IN DATE
   , p_qtr_end_date   IN DATE
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
    ;
    rec_l_k_rnwed_csr l_k_rnwed_csr%ROWTYPE ;

  -- Contracts that became active between the start of quarter
  -- and the summary build date and are is not a result of a renewal
  CURSOR l_new_bus_csr
  (
     p_summary_build_date IN DATE
   , p_qtr_start_date     IN DATE
  ) IS
    SELECT NVL(SUM(base_contract_amount), 0) value
         , COUNT(shd.chr_id) contract_count
    FROM   oki_sales_k_hdrs shd
    WHERE  shd.date_signed   <= p_summary_build_date
    AND    shd.date_approved <= p_summary_build_date
    AND    shd.is_new_yn      = 'Y'
    AND    shd.start_date BETWEEN p_qtr_start_date
                               AND p_summary_build_date
    AND    (   shd.date_terminated IS NULL
            OR shd.date_terminated  > p_summary_build_date )
    AND    shd.base_contract_amount BETWEEN 0
                                        AND oki_utl_pub.g_contract_limit
    ;
  rec_l_new_bus_csr l_new_bus_csr%ROWTYPE ;

  -- Contracts that were terminated between the start of the quarter and the
  -- summary build date
  CURSOR l_trmn_k_csr
  (
     p_summary_build_date IN DATE
   , p_qtr_start_date     IN DATE
  ) IS
    SELECT NVL(SUM(base_contract_amount), 0)  value
         , COUNT(shd.chr_id) contract_count
    FROM   oki_sales_k_hdrs shd
    WHERE  date_terminated  BETWEEN p_qtr_start_date
                                AND p_summary_build_date
    AND    shd.date_signed   IS NOT NULL
    AND    shd.date_approved IS NOT NULL
    AND    shd.base_contract_amount BETWEEN 0
                                        AND oki_utl_pub.g_contract_limit
  ;
  rec_l_trmn_k_csr l_trmn_k_csr%ROWTYPE ;

  BEGIN

    -- initialize return code to success
    l_retcode := '0';

    --
    -- Process Beginning Active Contracts record
    --

    l_measure_type := 'Beginning Active Contracts' ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
            , oki_load_rbk_pvt.g_b_act_k_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;


    -- Get the current value
    l_loc := 'Opening cursor to determine current ' || l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_tactk_all_csr ( oki_utl_pub.g_glpr_qtr_start_date ) ;
    FETCH oki_utl_pvt.g_tactk_all_csr INTO rec_l_tactk_all_csr ;
    IF oki_utl_pvt.g_tactk_all_csr%FOUND THEN
      l_curr_b_act_k := rec_l_tactk_all_csr.value ;
    END IF ;
    CLOSE oki_utl_pvt.g_tactk_all_csr ;

    -- Get the previous value
    l_loc := 'Opening Cursor to determine previous ' || l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_tactk_all_csr ( oki_utl_pub.g_py_glpr_qtr_start_date ) ;
    FETCH oki_utl_pvt.g_tactk_all_csr INTO rec_l_tactk_all_csr ;
    IF oki_utl_pvt.g_tactk_all_csr%FOUND THEN
      l_prev_b_act_k := rec_l_tactk_all_csr.value ;
    END IF ;
    CLOSE oki_utl_pvt.g_tactk_all_csr ;

    l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
         , oki_utl_pub.g_all_k_category_code
         , oki_load_rbk_pvt.g_b_act_k_code ) ;
    FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
    IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
      l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_rbk_pvt.ins_rnwl_bkng (
            p_summary_build_date        => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id          => oki_utl_pub.g_all_organization_id
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_party_id         => oki_utl_pub.g_all_customer_id
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_scs_code                  => oki_utl_pub.g_all_k_category_code
          , p_measure_code              => oki_load_rbk_pvt.g_b_act_k_code
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_curr_base_contract_amount => l_curr_b_act_k
          , p_prev_base_contract_amount => l_prev_b_act_k
          , x_retcode                   => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_rbk_pvt.upd_rnwl_bkng (
            p_curr_base_contract_amount => l_curr_b_act_k
          , p_prev_base_contract_amount => l_prev_b_act_k
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_rbk_rowid                 => rec_g_rbk_csr.rowid
          , x_retcode                   => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_rbk_pvt.g_rbk_csr ;

    --
    -- Process Expiring During Quarter record
    --

    l_measure_type := 'Expiring During Quarter' ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
            , oki_load_rbk_pvt.g_exp_in_qtr_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

    -- Get the current value
    l_loc := 'Opening cursor to determine current ' || l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_k_exp_in_qtr_all_csr (
         oki_utl_pub.g_glpr_qtr_start_date,
         oki_utl_pub.g_glpr_qtr_end_date ) ;
    FETCH oki_utl_pvt.g_k_exp_in_qtr_all_csr INTO rec_l_k_exp_in_qtr_all_csr ;
    IF oki_utl_pvt.g_k_exp_in_qtr_all_csr%FOUND THEN
      l_curr_k_exp_in_qtr := rec_l_k_exp_in_qtr_all_csr.value ;
    END IF ;
    CLOSE oki_utl_pvt.g_k_exp_in_qtr_all_csr ;

    -- Get the previous value
    l_loc := 'Opening cursor to determine previous ' || l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_k_exp_in_qtr_all_csr (
         oki_utl_pub.g_py_glpr_qtr_start_date,
         oki_utl_pub.g_py_glpr_qtr_end_date ) ;
    FETCH oki_utl_pvt.g_k_exp_in_qtr_all_csr INTO rec_l_k_exp_in_qtr_all_csr ;
    IF oki_utl_pvt.g_k_exp_in_qtr_all_csr%FOUND THEN
      l_prev_k_exp_in_qtr := rec_l_k_exp_in_qtr_all_csr.value ;
    END IF ;
    CLOSE oki_utl_pvt.g_k_exp_in_qtr_all_csr ;

    l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
         , oki_utl_pub.g_all_k_category_code
         , oki_load_rbk_pvt.g_exp_in_qtr_code ) ;
    FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
    IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
      l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_rbk_pvt.ins_rnwl_bkng (
            p_summary_build_date        => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id          => oki_utl_pub.g_all_organization_id
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_party_id         => oki_utl_pub.g_all_customer_id
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_scs_code                  => oki_utl_pub.g_all_k_category_code
          , p_measure_code              => oki_load_rbk_pvt.g_exp_in_qtr_code
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_curr_base_contract_amount => l_curr_k_exp_in_qtr
          , p_prev_base_contract_amount => l_prev_k_exp_in_qtr
          , x_retcode                   => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_rbk_pvt.upd_rnwl_bkng (
            p_curr_base_contract_amount => l_curr_k_exp_in_qtr
          , p_prev_base_contract_amount => l_prev_k_exp_in_qtr
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_rbk_rowid                 => rec_g_rbk_csr.rowid
          , x_retcode                   => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_rbk_pvt.g_rbk_csr ;

    --
    -- Process Backlog Renewals record
    --

    l_measure_type := 'Backlog Renewals' ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
            , oki_load_rbk_pvt.g_bklg_k_to_rnw_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

    -- Get the current value
    l_loc := 'Opening cursor to determine current ' || l_measure_type || '.' ;
    OPEN l_bklg_k_to_rnw_csr ( oki_utl_pub.g_glpr_qtr_start_date ) ;
    FETCH l_bklg_k_to_rnw_csr INTO rec_l_bklg_k_to_rnw_csr ;
    IF l_bklg_k_to_rnw_csr%FOUND THEN
      l_curr_bklg_k_to_rnw := rec_l_bklg_k_to_rnw_csr.value ;
    END IF ;
    CLOSE l_bklg_k_to_rnw_csr ;

    -- Get the previous value
    l_loc := 'Opening Cursor to determine previous ' || l_measure_type || '.' ;
    OPEN l_bklg_k_to_rnw_csr ( oki_utl_pub.g_py_glpr_qtr_start_date ) ;
    FETCH l_bklg_k_to_rnw_csr INTO rec_l_bklg_k_to_rnw_csr ;
    IF l_bklg_k_to_rnw_csr%FOUND THEN
      l_prev_bklg_k_to_rnw := rec_l_bklg_k_to_rnw_csr.value ;
    END IF ;
    CLOSE l_bklg_k_to_rnw_csr ;

    l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
         , oki_utl_pub.g_all_k_category_code
         , oki_load_rbk_pvt.g_bklg_k_to_rnw_code ) ;
    FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
    IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
      l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_rbk_pvt.ins_rnwl_bkng (
            p_summary_build_date        => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id          => oki_utl_pub.g_all_organization_id
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_party_id         => oki_utl_pub.g_all_customer_id
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_scs_code                  => oki_utl_pub.g_all_k_category_code
          , p_measure_code              => oki_load_rbk_pvt.g_bklg_k_to_rnw_code
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_curr_base_contract_amount => l_curr_bklg_k_to_rnw
          , p_prev_base_contract_amount => l_prev_bklg_k_to_rnw
          , x_retcode                   => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_rbk_pvt.upd_rnwl_bkng (
            p_curr_base_contract_amount => l_curr_bklg_k_to_rnw
          , p_prev_base_contract_amount => l_prev_bklg_k_to_rnw
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_rbk_rowid                 => rec_g_rbk_csr.rowid
          , x_retcode                   => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_rbk_pvt.g_rbk_csr ;

    --
    -- Process Beginning Renewal Opportunity record
    --

    l_measure_type := 'Beginning Renewal Opportunity' ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
            , oki_load_rbk_pvt.g_b_rnwl_oppty_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

    l_curr_b_rnwl_oppty := l_curr_k_exp_in_qtr + l_curr_bklg_k_to_rnw ;
    l_prev_b_rnwl_oppty := l_prev_k_exp_in_qtr + l_prev_bklg_k_to_rnw ;

    l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
         , oki_utl_pub.g_all_k_category_code
         , oki_load_rbk_pvt.g_b_rnwl_oppty_code ) ;
    FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
    IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
      l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_rbk_pvt.ins_rnwl_bkng (
            p_summary_build_date        => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id          => oki_utl_pub.g_all_organization_id
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_party_id         => oki_utl_pub.g_all_customer_id
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_scs_code                  => oki_utl_pub.g_all_k_category_code
          , p_measure_code              => oki_load_rbk_pvt.g_b_rnwl_oppty_code
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_curr_base_contract_amount => l_curr_b_rnwl_oppty
          , p_prev_base_contract_amount => l_prev_b_rnwl_oppty
          , x_retcode                   => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_rbk_pvt.upd_rnwl_bkng (
            p_curr_base_contract_amount => l_curr_b_rnwl_oppty
          , p_prev_base_contract_amount => l_prev_b_rnwl_oppty
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_rbk_rowid                 => rec_g_rbk_csr.rowid
          , x_retcode                   => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_rbk_pvt.g_rbk_csr ;

    --
    -- Process Quarter Activity record
    --

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
            , oki_load_rbk_pvt.g_qtr_actvty_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

    l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date,
             oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id,
             oki_utl_pub.g_all_k_category_code, oki_load_rbk_pvt.g_qtr_actvty_code ) ;
    FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
    IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
      l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_rbk_pvt.ins_rnwl_bkng (
            p_summary_build_date        => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id          => oki_utl_pub.g_all_organization_id
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_party_id         => oki_utl_pub.g_all_customer_id
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_scs_code                  => oki_utl_pub.g_all_k_category_code
          , p_measure_code              => oki_load_rbk_pvt.g_qtr_actvty_code
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_curr_base_contract_amount => NULL
          , p_prev_base_contract_amount => NULL
          , x_retcode                   => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_rbk_pvt.upd_rnwl_bkng (
            p_curr_base_contract_amount => NULL
          , p_prev_base_contract_amount => NULL
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_rbk_rowid                 => rec_g_rbk_csr.rowid
          , x_retcode                   => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_rbk_pvt.g_rbk_csr ;

    --
    -- Process Backlog Contracts Renewed record
    --

    l_measure_type := 'Backlog Contracts Renewed' ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
            , oki_load_rbk_pvt.g_bklg_k_rnwed_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

    -- Get the current value
    l_loc := 'Opening cursor to determine current ' || l_measure_type || '.' ;
    OPEN l_bklg_k_rwned_csr( oki_utl_pub.g_summary_build_date,
         oki_utl_pub.g_glpr_qtr_start_date ) ;
    FETCH l_bklg_k_rwned_csr INTO rec_l_bklg_k_rwned_csr ;
    IF l_bklg_k_rwned_csr%FOUND THEN
      l_curr_bklg_k_rwned := rec_l_bklg_k_rwned_csr.value ;
    END IF ;
    CLOSE l_bklg_k_rwned_csr;

    -- Get the previous value
    OPEN l_bklg_k_rwned_csr( oki_utl_pub.g_py_summary_build_date,
         oki_utl_pub.g_py_glpr_qtr_start_date ) ;
    FETCH l_bklg_k_rwned_csr INTO rec_l_bklg_k_rwned_csr ;
    IF l_bklg_k_rwned_csr%FOUND THEN
      l_prev_bklg_k_rwned := rec_l_bklg_k_rwned_csr.value ;
    END IF ;
    CLOSE l_bklg_k_rwned_csr ;

    l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id
         , oki_utl_pub.g_all_customer_id, oki_utl_pub.g_all_k_category_code
         , oki_load_rbk_pvt.g_bklg_k_rnwed_code ) ;
    FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
    IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
      l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_rbk_pvt.ins_rnwl_bkng (
            p_summary_build_date        => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id          => oki_utl_pub.g_all_organization_id
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_party_id         => oki_utl_pub.g_all_customer_id
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_scs_code                  => oki_utl_pub.g_all_k_category_code
          , p_measure_code              => oki_load_rbk_pvt.g_bklg_k_rnwed_code
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_curr_base_contract_amount => l_curr_bklg_k_rwned
          , p_prev_base_contract_amount => l_prev_bklg_k_rwned
          , x_retcode                   => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_rbk_pvt.upd_rnwl_bkng (
            p_curr_base_contract_amount => l_curr_bklg_k_rwned
          , p_prev_base_contract_amount => l_prev_bklg_k_rwned
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_rbk_rowid                 => rec_g_rbk_csr.rowid
          , x_retcode                   => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_rbk_pvt.g_rbk_csr ;

    --
    -- Process Contracts Renewed record
    --

    l_measure_type := 'Contracts Renewed' ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
            , oki_load_rbk_pvt.g_k_rnwed_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

    -- Get the current value
    l_loc := 'Opening cursor to determine current ' || l_measure_type || '.' ;
    OPEN l_k_rnwed_csr( oki_utl_pub.g_glpr_qtr_start_date,
         oki_utl_pub.g_glpr_qtr_end_date ) ;
    FETCH l_k_rnwed_csr INTO rec_l_k_rnwed_csr ;
    IF l_k_rnwed_csr%FOUND THEN
      l_curr_k_rnwed := rec_l_k_rnwed_csr.value ;
    END IF ;
    CLOSE l_k_rnwed_csr ;

    -- Get the previous value
    l_loc := 'Opening Cursor to determine previous ' || l_measure_type || '.' ;
    OPEN l_k_rnwed_csr( oki_utl_pub.g_py_glpr_qtr_start_date,
         oki_utl_pub.g_py_glpr_qtr_end_date ) ;
    FETCH l_k_rnwed_csr INTO rec_l_k_rnwed_csr ;
    IF l_k_rnwed_csr%FOUND THEN
      l_prev_k_rnwed := rec_l_k_rnwed_csr.value ;
    END IF ;
    CLOSE l_k_rnwed_csr ;

    l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date,
             oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id,
             oki_utl_pub.g_all_k_category_code, oki_load_rbk_pvt.g_k_rnwed_code ) ;
    FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
    IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
      l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_rbk_pvt.ins_rnwl_bkng (
            p_summary_build_date        => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id          => oki_utl_pub.g_all_organization_id
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_party_id         => oki_utl_pub.g_all_customer_id
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_scs_code                  => oki_utl_pub.g_all_k_category_code
          , p_measure_code              => oki_load_rbk_pvt.g_k_rnwed_code
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_curr_base_contract_amount => l_curr_k_rnwed
          , p_prev_base_contract_amount => l_prev_k_rnwed
          , x_retcode                   => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_rbk_pvt.upd_rnwl_bkng (
            p_curr_base_contract_amount => l_curr_k_rnwed
          , p_prev_base_contract_amount => l_prev_k_rnwed
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_rbk_rowid                 => rec_g_rbk_csr.rowid
          , x_retcode                   => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_rbk_pvt.g_rbk_csr ;

    --
    -- Process New Business record
    --

    l_measure_type := 'New Business' ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
            , oki_load_rbk_pvt.g_new_bsn_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

    -- Get the current value
    l_loc := 'Opening cursor to determine current ' || l_measure_type || '.' ;
    OPEN l_new_bus_csr( oki_utl_pub.g_summary_build_date,
         oki_utl_pub.g_glpr_qtr_start_date ) ;
    FETCH l_new_bus_csr INTO rec_l_new_bus_csr ;
    IF l_new_bus_csr%FOUND THEN
      l_curr_new_bus := rec_l_new_bus_csr.value ;
    END IF ;
    CLOSE l_new_bus_csr ;

    -- Get the previous value
    l_loc := 'Opening Cursor to determine previous ' || l_measure_type || '.' ;
    OPEN l_new_bus_csr( oki_utl_pub.g_py_summary_build_date,
         oki_utl_pub.g_py_glpr_qtr_start_date ) ;
    FETCH l_new_bus_csr INTO rec_l_new_bus_csr ;
    IF l_new_bus_csr%FOUND THEN
      l_prev_new_bus := rec_l_new_bus_csr.value ;
    END IF ;
    CLOSE l_new_bus_csr ;

    l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
         , oki_utl_pub.g_all_k_category_code
         , oki_load_rbk_pvt.g_new_bsn_code ) ;
    FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
    IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
      l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_rbk_pvt.ins_rnwl_bkng (
            p_summary_build_date        => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id          => oki_utl_pub.g_all_organization_id
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_party_id         => oki_utl_pub.g_all_customer_id
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_scs_code                  => oki_utl_pub.g_all_k_category_code
          , p_measure_code              => oki_load_rbk_pvt.g_new_bsn_code
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_curr_base_contract_amount => l_curr_new_bus
          , p_prev_base_contract_amount => l_prev_new_bus
          , x_retcode                   => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_rbk_pvt.upd_rnwl_bkng (
            p_curr_base_contract_amount => l_curr_new_bus
          , p_prev_base_contract_amount => l_prev_new_bus
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_rbk_rowid                 => rec_g_rbk_csr.rowid
          , x_retcode                   => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_rbk_pvt.g_rbk_csr ;

    --
    -- Process Terminated Contracts record
    --

    l_measure_type := 'Terminated Contracts' ;

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
            , oki_load_rbk_pvt.g_trmn_k_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

    -- Get the current value
    l_loc := 'Opening cursor to determine current ' || l_measure_type || '.' ;
    OPEN l_trmn_k_csr( oki_utl_pub.g_summary_build_date,
         oki_utl_pub.g_glpr_qtr_start_date ) ;
    FETCH l_trmn_k_csr INTO rec_l_trmn_k_csr ;
    IF l_trmn_k_csr%FOUND THEN
      l_curr_trmn_k := rec_l_trmn_k_csr.value ;
    END IF ;
    CLOSE l_trmn_k_csr ;

    -- Get the previous value
    l_loc := 'Opening Cursor to determine previous ' || l_measure_type || '.' ;
    OPEN l_trmn_k_csr( oki_utl_pub.g_py_summary_build_date,
         oki_utl_pub.g_py_glpr_qtr_start_date ) ;
    FETCH l_trmn_k_csr INTO rec_l_trmn_k_csr ;
    IF l_trmn_k_csr%FOUND THEN
      l_prev_trmn_k := rec_l_trmn_k_csr.value ;
    END IF ;
    CLOSE l_trmn_k_csr ;

    l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
         , oki_utl_pub.g_all_k_category_code
         , oki_load_rbk_pvt.g_trmn_k_code ) ;
    FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
    IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
      l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_rbk_pvt.ins_rnwl_bkng (
            p_summary_build_date        => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id          => oki_utl_pub.g_all_organization_id
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_party_id         => oki_utl_pub.g_all_customer_id
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_scs_code                  => oki_utl_pub.g_all_k_category_code
          , p_measure_code              => oki_load_rbk_pvt.g_trmn_k_code
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_curr_base_contract_amount => l_curr_trmn_k
          , p_prev_base_contract_amount => l_prev_trmn_k
          , x_retcode                   => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_rbk_pvt.upd_rnwl_bkng (
            p_curr_base_contract_amount => l_curr_trmn_k
          , p_prev_base_contract_amount => l_prev_trmn_k
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_rbk_rowid                 => rec_g_rbk_csr.rowid
          , x_retcode                   => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_rbk_pvt.g_rbk_csr ;

    --
    -- Process Ending Active Contracts record
    --

    -- Get the bin display lookup values
    l_loc := 'Opening cursor to retrieve bin display lookup values for ' ||
              l_measure_type || '.' ;
    OPEN oki_utl_pvt.g_bin_disp_lkup_csr ( oki_load_rbk_pvt.g_bin_id
            , oki_load_rbk_pvt.g_e_act_k_code ) ;
    FETCH oki_utl_pvt.g_bin_disp_lkup_csr INTO rec_l_bin_disp_lkup_csr ;
    IF oki_utl_pvt.g_bin_disp_lkup_csr%FOUND THEN
      l_bin_code_meaning  := rec_l_bin_disp_lkup_csr.bin_code_meaning ;
      l_bin_code_seq      := rec_l_bin_disp_lkup_csr.bin_code_seq ;
    ELSE
      RAISE NO_DATA_FOUND ;
    END IF ;
    CLOSE oki_utl_pvt.g_bin_disp_lkup_csr ;

    l_measure_type := 'Ending Active Contracts' ;

    l_curr_e_act_k := ( l_curr_b_act_k + l_curr_bklg_k_rwned +
                       l_curr_k_rnwed + l_curr_new_bus ) -
                     ( l_curr_k_exp_in_qtr + l_curr_trmn_k ) ;

    l_prev_e_act_k := ( l_prev_b_act_k + l_prev_bklg_k_rwned +
                       l_prev_k_rnwed + l_prev_new_bus ) -
                     ( l_prev_k_exp_in_qtr + l_prev_trmn_k ) ;

    l_loc := 'Opening cursor to determine current ' || l_measure_type || '.' ;

    l_loc := 'Inserting / updating ' || l_measure_type || '.' ;
    -- Determine if the record is a new one or an existing one
    OPEN oki_load_rbk_pvt.g_rbk_csr ( oki_utl_pub.g_summary_build_date
         , oki_utl_pub.g_all_organization_id, oki_utl_pub.g_all_customer_id
         , oki_utl_pub.g_all_k_category_code
         , oki_load_rbk_pvt.g_e_act_k_code ) ;
    FETCH oki_load_rbk_pvt.g_rbk_csr INTO rec_g_rbk_csr ;
    IF oki_load_rbk_pvt.g_rbk_csr%NOTFOUND THEN
      l_loc := 'Insert the new record --  ' || l_measure_type || '.' ;
      -- Insert the new record
      oki_load_rbk_pvt.ins_rnwl_bkng (
            p_summary_build_date        => oki_utl_pub.g_summary_build_date
          , p_authoring_org_id          => oki_utl_pub.g_all_organization_id
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_party_id         => oki_utl_pub.g_all_customer_id
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_scs_code                  => oki_utl_pub.g_all_k_category_code
          , p_measure_code              => oki_load_rbk_pvt.g_e_act_k_code
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_curr_base_contract_amount => l_curr_e_act_k
          , p_prev_base_contract_amount => l_prev_e_act_k
          , x_retcode                   => l_retcode ) ;
      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    ELSE
      l_loc := 'Update the record -- ' || l_measure_type || '.' ;
      -- Update the existing record
      oki_load_rbk_pvt.upd_rnwl_bkng (
            p_curr_base_contract_amount => l_curr_e_act_k
          , p_prev_base_contract_amount => l_prev_e_act_k
          , p_measure_code_meaning      => l_bin_code_meaning
          , p_bin_code_seq              => l_bin_code_seq
          , p_organization_name         => oki_utl_pub.g_all_organization_name
          , p_customer_name             => oki_utl_pub.g_all_customer_name
          , p_rbk_rowid                 => rec_g_rbk_csr.rowid
          , x_retcode                   => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;
    END IF ;
    CLOSE oki_load_rbk_pvt.g_rbk_csr ;

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
                            , value => 'OKI_LOAD_RBK_PVT.CALC_RBK_SUM');

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
  END calc_rbk_sum ;
--------------------------------------------------------------------------------
--
-- Procedure which loops through the summary build date and calls procedures
-- to load the renewal bookings table.
--
--------------------------------------------------------------------------------

  PROCEDURE crt_rnwl_bkng
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
  l_table_name  CONSTANT VARCHAR2(30) := 'OKI_RNWL_BOOKINGS' ;

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

    SAVEPOINT oki_etr_rnwl_bkng ;

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
      oki_load_rbk_pvt.calc_rbk_sum (
            x_retcode  => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;

      -- Procedure to calculate the amounts for the organization level
      oki_load_rbk_pvt.calc_rbk_dtl1 (
            x_retcode  => l_retcode ) ;

      IF l_retcode = '2' THEN
        -- Load failed, exit immediately.
        RAISE oki_utl_pub.g_excp_exit_immediate ;
      END IF ;

      l_summary_build_date := l_summary_build_date + 1 ;

    END LOOP ;

    COMMIT;

    SAVEPOINT oki_rbk_upd_refresh ;


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

      ROLLBACK TO oki_rbk_upd_refresh ;

    WHEN oki_utl_pub.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

      ROLLBACK TO oki_etr_rnwl_bkng ;

    WHEN OTHERS THEN

      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2' ;

      -- ROLLBACK all transactions
      ROLLBACK TO oki_etr_rnwl_bkng ;


      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE' ) ;

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_RBK_PVT.CRT_RNWL_BKNG' ) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get ) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm ) ;
  END crt_rnwl_bkng ;

BEGIN
  -- Initialize the global variables used TO log this job run
  -- FROM concurrent manager
  g_request_id             :=  fnd_global.conc_request_id ;
  g_program_application_id :=  fnd_global.prog_appl_id ;
  g_program_id             :=  fnd_global.conc_program_id ;
  g_program_update_date    :=  SYSDATE ;

END oki_load_rbk_pvt ;

/
