--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_RAG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_RAG_PVT" AS
/* $Header: OKIRRAGB.pls 115.8 2003/11/24 08:25:03 kbajaj ship $ */

--------------------------------------------------------------------------------
-- Modification History
-- 19-Sep-2001  mezra        Initial version
-- 25-Sep-2001  mezra        Change usd_ columns to base_.
-- 22-Oct-2001  mezra        Changed All Categories value to -1.
-- 26-NOV-2002 rpotnuru      NOCOPY Changes
--
-- 29-Oct-2003 axraghav      Modified l_org_id_csr in calc_rag_dtl1,
--                           calc_rag_dtl2 and calc_rag_sum to populate null for
--                           organization and customer name
--------------------------------------------------------------------------------

  -- Global exception declaration

  -- Generic exception to immediately exit the procedure
  g_excp_exit_immediate   EXCEPTION ;

  -- Global variable declaration

  -- Start and end ranges for the aging buckets
  g_start_age_group1     NUMBER := 0 ;
  g_end_age_group1       NUMBER := 0 ;
  g_start_age_group2     NUMBER := 0 ;
  g_end_age_group2       NUMBER := 0 ;
  g_start_age_group3     NUMBER := 0 ;
  g_end_age_group3       NUMBER := 0 ;
  g_start_age_group4     NUMBER := 0 ;


  -- Global constant delcaration

  -- Constants for the "All" organization, subclass, and customer record
  g_all_scs_code CONSTANT VARCHAR2(30) := '-1' ;
  g_all_cst_id   CONSTANT NUMBER       := -1 ;
  g_all_cst_name CONSTANT VARCHAR2(30) := 'All Customers' ;


  -- Global cursor declaration

  -- Cusror to retrieve the rowid for the selected record.
  -- If a rowid is retrieved, then the record is updated,
  -- else the record is inserted.
  CURSOR g_rag_csr
  (   p_period_set_name   IN VARCHAR2
    , p_period_name       IN VARCHAR2
    , p_authoring_org_id  IN NUMBER
    , p_customer_party_id IN NUMBER
    , p_scs_code          IN VARCHAR2
  ) IS
    SELECT rowid
    FROM   oki_renewal_aging rag
    WHERE  rag.period_set_name   = p_period_set_name
    AND    rag.period_name       = p_period_name
    AND    rag.authoring_org_id  = p_authoring_org_id
    AND    rag.customer_party_id = p_customer_party_id
    AND    rag.scs_code          = p_scs_code
    ;
  rec_g_rag_csr g_rag_csr%ROWTYPE ;

--------------------------------------------------------------------------------
  -- Procedure to insert records into the oki_rnwl_age_by_orgs table.

--------------------------------------------------------------------------------
  PROCEDURE ins_rnwl_aging
  (   p_period_set_name     IN  VARCHAR2
    , p_period_name         IN  VARCHAR2
    , p_period_type         IN  VARCHAR2
    , p_authoring_org_id    IN  NUMBER
    , p_authoring_org_name  IN  VARCHAR2
    , p_customer_party_id   IN  NUMBER
    , p_customer_name       IN  VARCHAR2
    , p_scs_code            IN  VARCHAR2
    , p_age_group1          IN  NUMBER
    , p_age_group2          IN  NUMBER
    , p_age_group3          IN  NUMBER
    , p_age_group4          IN  NUMBER
    , x_retcode             OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  l_sequence  NUMBER := NULL ;

  -- Cursor declaration
  CURSOR l_seq_num IS
    SELECT oki_renewal_aging_s1.nextval seq
    FROM dual ;
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

    INSERT INTO oki_renewal_aging
    (        id
           , period_set_name
           , period_name
           , period_type
           , authoring_org_id
           , authoring_org_name
           , customer_party_id
           , customer_name
           , scs_code
           , age_group1
           , age_group2
           , age_group3
           , age_group4
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
           , p_age_group1
           , p_age_group2
           , p_age_group3
           , p_age_group4
           , oki_load_rag_pvt.g_request_id
           , oki_load_rag_pvt.g_program_application_id
           , oki_load_rag_pvt.g_program_id
           , oki_load_rag_pvt.g_program_update_date ) ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code TO error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_TABLE_LOAD_FAILURE');

      fnd_message.set_token(  token => 'TABLE_NAME'
                            , value => 'OKI_RENEWAL_AGING');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END ins_rnwl_aging ;

--------------------------------------------------------------------------------
  -- Procedure to update records in the oki_rnwl_age_by_orgs table.

--------------------------------------------------------------------------------
  PROCEDURE upd_rnwl_aging
  (   p_age_group1   IN  NUMBER
    , p_age_group2   IN  NUMBER
    , p_age_group3   IN  NUMBER
    , p_age_group4   IN  NUMBER
    , p_rag_rowid    IN  ROWID
    , x_retcode      OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  BEGIN

    -- initialize return code to success
    x_retcode := '0';

    UPDATE oki_renewal_aging SET
        age_group1             = p_age_group1
      , age_group2             = p_age_group2
      , age_group3             = p_age_group3
      , age_group4             = p_age_group4
      , request_id             = oki_load_rag_pvt.g_request_id
      , program_application_id = oki_load_rag_pvt.g_program_application_id
      , program_id             = oki_load_rag_pvt.g_program_id
      , program_update_date    = oki_load_rag_pvt.g_program_update_date
    WHERE ROWID =  p_rag_rowid ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE' );

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_RAG_PVT.OKI_UPD_RNWL_AGING' );

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END upd_rnwl_aging ;

--------------------------------------------------------------------------------
  -- Procedure to calculate the start and end ranges for each
  -- age grouping.
--------------------------------------------------------------------------------
  PROCEDURE calc_age_group
  (   x_start_age_group1 OUT NOCOPY NUMBER
    , x_end_age_group1   OUT NOCOPY NUMBER
    , x_start_age_group2 OUT NOCOPY NUMBER
    , x_end_age_group2   OUT NOCOPY NUMBER
    , x_start_age_group3 OUT NOCOPY NUMBER
    , x_end_age_group3   OUT NOCOPY NUMBER
    , x_start_age_group4 OUT NOCOPY NUMBER
    , x_retcode          OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode     VARCHAR2(100) ;
  l_sqlerrm     VARCHAR2(1000) ;

  -- The range for each aging bucket
  l_aging_range NUMBER :=
                  to_number(fnd_profile.value('OKI_AGING_RANGE'), 9999) ;

  -- constant declaration

  -- The number of aging buckets
  l_num_of_aging_buckets CONSTANT NUMBER := 4 ;

  BEGIN

    -- initialize return code to success
    x_retcode := '0';

    FOR i in 1 .. l_num_of_aging_buckets loop
       IF i = 1 THEN
         x_start_age_group1 := 0 ;
         x_end_age_group1   := x_start_age_group1 + l_aging_range ;

       ELSIF i = 2 THEN
         x_start_age_group2 := x_end_age_group1 + 1 ;
         x_end_age_group2   := x_end_age_group1 + l_aging_range ;

       ELSIF i = 3 THEN
         x_start_age_group3 := x_end_age_group2 + 1 ;
         x_end_age_group3   := x_end_age_group2 + l_aging_range ;

       ELSE
         x_start_age_group4 := x_end_age_group3 + 1 ;
       END IF ;
    END LOOP ;

  EXCEPTION
    WHEN OTHERS THEN

      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2' ;


      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_RAG_PVT.CALC_AGE_GROUP');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END calc_age_group ;

--------------------------------------------------------------------------------
  -- Procedure to calcuate the age of the renewal for the organizations.
  -- Calculates the amounts by each dimension:
  --   period set name
  --   period type
  --   period name
  --   customer
  --   subclass
  --   organization
  --
--------------------------------------------------------------------------------
  PROCEDURE calc_rag_dtl1
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , x_retcode            OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode  VARCHAR2(100)  := NULL ;
  l_sqlerrm  VARCHAR2(1000) := NULL ;

  l_base_fcst_age_group1   NUMBER := 0 ;
  l_base_fcst_age_group2   NUMBER := 0 ;
  l_base_fcst_age_group3   NUMBER := 0 ;
  l_base_fcst_age_group4   NUMBER := 0 ;

  -- holds the rowid of the record in the oki_rnwl_age_by_orgs table
  l_rag_rowid ROWID ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date  DATE ;
  l_glpr_end_date    DATE ;

  -- Cusor declaration

  -- Cursor to get all the organizations
  CURSOR l_org_id_csr IS
    SELECT   DISTINCT shd.authoring_org_id org_id
           , /*11510 changes*/ NULL organization_name
           , shd.customer_party_id customer_id
           , /*11510 changes*/ NULL customer_name
           , shd.scs_code
    FROM     oki_sales_k_hdrs shd ;

  -- Cursor to calculate the age of the renewals for each
  -- organization, customer and subclass
  CURSOR l_rnwl_age_csr
  (   p_summary_build_date IN DATE
    , p_org_id             IN NUMBER
    , p_customer_party_id  IN NUMBER
    , p_scs_code           IN VARCHAR2
    , p_start_age_group1   IN NUMBER
    , p_end_age_group1     IN NUMBER
    , p_start_age_group2   IN NUMBER
    , p_end_age_group2     IN NUMBER
    , p_start_age_group3   IN NUMBER
    , p_end_age_group3     IN NUMBER
    , p_start_age_group4   IN NUMBER
  ) IS
    SELECT
         NVL(SUM(DECODE(SIGN( (TRUNC(p_summary_build_date) -
                            TRUNC(shd.creation_date)) - p_start_age_group1),
            1, DECODE(SIGN( p_end_age_group1 -
                     (TRUNC(p_summary_build_date) - trunc(shd.creation_date))),
                 1, shd.base_forecast_amount,
                 0, shd.base_forecast_amount,
                 0),
            0, shd.base_forecast_amount,
            0)), 0) age_group1,
         NVL(SUM(DECODE(SIGN( (TRUNC(p_summary_build_date) -
                            TRUNC(shd.creation_date)) - p_start_age_group2),
            1, DECODE(SIGN( p_end_age_group2 -
                     (TRUNC(p_summary_build_date) - TRUNC(shd.creation_date))),
                 1, shd.base_forecast_amount,
                 0, shd.base_forecast_amount,
                 0),
            0, shd.base_forecast_amount,
            0)), 0) age_group2,
         NVL(SUM(DECODE(SIGN( (TRUNC(p_summary_build_date) -
                            TRUNC(shd.creation_date)) - p_start_age_group3),
            1, decode(sign( p_end_age_group3 -
                     (trunc(p_summary_build_date) - trunc(shd.creation_date))),
                 1, shd.base_forecast_amount,
                 0, shd.base_forecast_amount,
                 0),
            0, shd.base_forecast_amount,
            0)), 0) age_group3,
         NVL(SUM(DECODE(SIGN( (TRUNC(p_summary_build_date) -
                            TRUNC(shd.creation_date)) - p_start_age_group4),
            1, shd.base_forecast_amount,
            0, shd.base_forecast_amount,
            0)), 0) age_group4
    FROM     oki_sales_k_hdrs shd
    -- contract has undergone forecasting
    WHERE    shd.win_percent is not null
    AND      shd.close_date  is not null
    -- renewal contract      is entered
    AND      shd.ste_code          = 'ENTERED'
    AND      is_new_yn         IS NULL
    AND      shd.authoring_org_id  = p_org_id
    AND      shd.customer_party_id = p_customer_party_id
    AND      shd.scs_code = p_scs_code
    ;
  rec_l_rnwl_age_csr l_rnwl_age_csr%ROWTYPE ;

  BEGIN

    -- Initialize return code to success
    l_retcode := '0';

    -- Get the ranges for the aging buckets
    oki_load_rag_pvt.calc_age_group (
          x_start_age_group1 => oki_load_rag_pvt.g_start_age_group1
        , x_end_age_group1   => oki_load_rag_pvt.g_end_age_group1
        , x_start_age_group2 => oki_load_rag_pvt.g_start_age_group2
        , x_end_age_group2   => oki_load_rag_pvt.g_end_age_group2
        , x_start_age_group3 => oki_load_rag_pvt.g_start_age_group3
        , x_end_age_group3   => oki_load_rag_pvt.g_end_age_group3
        , x_start_age_group4 => oki_load_rag_pvt.g_start_age_group4
        , x_retcode          => l_retcode );

     IF l_retcode = '2' THEN
       -- Load failed, exit immediately.
       RAISE oki_load_rag_pvt.g_excp_exit_immediate ;
     END IF ;
     COMMIT;

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
        l_base_fcst_age_group1 := 0 ;
        l_base_fcst_age_group2 := 0 ;
        l_base_fcst_age_group3 := 0 ;
        l_base_fcst_age_group4 := 0 ;

        l_loc := 'Opening cursor to determine the age.' ;
        -- Calculate the forecast amount for a given organization
        OPEN  l_rnwl_age_csr (p_summary_build_date,
              rec_l_org_id_csr.org_id, rec_l_org_id_csr.customer_id,
              rec_l_org_id_csr.scs_code, oki_load_rag_pvt.g_start_age_group1,
              oki_load_rag_pvt.g_end_age_group1,
              oki_load_rag_pvt.g_start_age_group2,
              oki_load_rag_pvt.g_end_age_group2,
              oki_load_rag_pvt.g_start_age_group3,
              oki_load_rag_pvt.g_end_age_group3,
              oki_load_rag_pvt.g_start_age_group4  ) ;
        FETCH l_rnwl_age_csr INTO rec_l_rnwl_age_csr ;
          IF l_rnwl_age_csr%FOUND THEN
            l_base_fcst_age_group1 := rec_l_rnwl_age_csr.age_group1 ;
            l_base_fcst_age_group2 := rec_l_rnwl_age_csr.age_group2 ;
            l_base_fcst_age_group3 := rec_l_rnwl_age_csr.age_group3 ;
            l_base_fcst_age_group4 := rec_l_rnwl_age_csr.age_group4 ;
          END IF ;
        CLOSE l_rnwl_age_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_rag_pvt.g_rag_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_id_csr.org_id,
             rec_l_org_id_csr.customer_id, rec_l_org_id_csr.scs_code ) ;
        FETCH oki_load_rag_pvt.g_rag_csr INTO rec_g_rag_csr ;
          IF oki_load_rag_pvt.g_rag_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;

            -- Insert the current period data for the period
            oki_load_rag_pvt.ins_rnwl_aging (
                p_period_set_name     => rec_g_glpr_csr.period_set_name
              , p_period_name         => rec_g_glpr_csr.period_name
              , p_period_type         => rec_g_glpr_csr.period_type
              , p_authoring_org_id    => rec_l_org_id_csr.org_id
              , p_authoring_org_name  => rec_l_org_id_csr.organization_name
              , p_customer_party_id   => rec_l_org_id_csr.customer_id
              , p_customer_name       => rec_l_org_id_csr.customer_name
              , p_scs_code            => rec_l_org_id_csr.scs_code
              , p_age_group1          => l_base_fcst_age_group1
              , p_age_group2          => l_base_fcst_age_group2
              , p_age_group3          => l_base_fcst_age_group3
              , p_age_group4          => l_base_fcst_age_group4
              , x_retcode             => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rag_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_rag_pvt.upd_rnwl_aging (
                p_age_group1          => l_base_fcst_age_group1
              , p_age_group2          => l_base_fcst_age_group2
              , p_age_group3          => l_base_fcst_age_group3
              , p_age_group4          => l_base_fcst_age_group4
              , p_rag_rowid           => rec_g_rag_csr.rowid
              , x_retcode             => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rag_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_rag_pvt.g_rag_csr ;

      END LOOP g_glpr_csr_loop ;
   END LOOP l_org_id_csr_loop ;


  EXCEPTION
    WHEN oki_load_rag_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_rag_PVT.CALC_RAG_DTL1');

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

  END calc_rag_dtl1 ;

--------------------------------------------------------------------------------
  -- Procedure to calcuate the age of the renewal for the organizations.
  -- Calculates the amounts across categories:
  --   each period set name
  --   each period type
  --   each period name
  --   each customer
  --   all  subclass
  --   each organizations
  --
--------------------------------------------------------------------------------
  PROCEDURE calc_rag_dtl2
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , x_retcode            OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode  VARCHAR2(100)  := NULL ;
  l_sqlerrm  VARCHAR2(1000) := NULL ;

  l_base_fcst_age_group1   NUMBER := 0 ;
  l_base_fcst_age_group2   NUMBER := 0 ;
  l_base_fcst_age_group3   NUMBER := 0 ;
  l_base_fcst_age_group4   NUMBER := 0 ;

  -- holds the rowid of the record in the oki_rnwl_age_by_orgs table
  l_rag_rowid ROWID ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date  DATE ;
  l_glpr_end_date    DATE ;

  -- Cusor declaration

  -- Cursor to get all the organizations
  CURSOR l_org_id_csr IS
    SELECT   DISTINCT shd.authoring_org_id org_id
           , /*11510 changes*/ NULL organization_name
           , shd.customer_party_id
           , /*11510 changes*/ NULL customer_name
    FROM     oki_sales_k_hdrs shd  ;

  -- Cursor to calculate the age of the renewals for each
  -- orgnization and customer
  CURSOR l_rnwl_age_csr
  (   p_summary_build_date IN DATE
    , p_org_id             IN NUMBER
    , p_customer_party_id  IN NUMBER
    , p_start_age_group1   IN NUMBER
    , p_end_age_group1     IN NUMBER
    , p_start_age_group2   IN NUMBER
    , p_end_age_group2     IN NUMBER
    , p_start_age_group3   IN NUMBER
    , p_end_age_group3     IN NUMBER
    , p_start_age_group4   IN NUMBER
  ) IS
    SELECT
         NVL(SUM(DECODE(SIGN( (TRUNC(p_summary_build_date) -
                            TRUNC(shd.creation_date)) - p_start_age_group1),
            1, DECODE(SIGN( p_end_age_group1 -
                     (TRUNC(p_summary_build_date) - trunc(shd.creation_date))),
                 1, shd.base_forecast_amount,
                 0, shd.base_forecast_amount,
                 0),
            0, shd.base_forecast_amount,
            0)), 0) age_group1,
         NVL(SUM(DECODE(SIGN( (TRUNC(p_summary_build_date) -
                            TRUNC(shd.creation_date)) - p_start_age_group2),
            1, DECODE(SIGN( p_end_age_group2 -
                     (TRUNC(p_summary_build_date) - TRUNC(shd.creation_date))),
                 1, shd.base_forecast_amount,
                 0, shd.base_forecast_amount,
                 0),
            0, shd.base_forecast_amount,
            0)), 0) age_group2,
         NVL(SUM(DECODE(SIGN( (TRUNC(p_summary_build_date) -
                            TRUNC(shd.creation_date)) - p_start_age_group3),
            1, decode(sign( p_end_age_group3 -
                     (trunc(p_summary_build_date) - trunc(shd.creation_date))),
                 1, shd.base_forecast_amount,
                 0, shd.base_forecast_amount,
                 0),
            0, shd.base_forecast_amount,
            0)), 0) age_group3,
         NVL(SUM(DECODE(SIGN( (TRUNC(p_summary_build_date) -
                            TRUNC(shd.creation_date)) - p_start_age_group4),
            1, shd.base_forecast_amount,
            0, shd.base_forecast_amount,
            0)), 0) age_group4
    FROM     oki_sales_k_hdrs shd
    -- contract has undergone forecasting
    WHERE    shd.win_percent is not null
    AND      shd.close_date  is not null
    -- renewal contract      is entered
    AND      shd.ste_code          = 'ENTERED'
    AND      is_new_yn         IS NULL
    AND      shd.authoring_org_id  = p_org_id
    AND      shd.customer_party_id = p_customer_party_id
    ;
  rec_l_rnwl_age_csr l_rnwl_age_csr%ROWTYPE ;


  BEGIN

    -- Initialize return code to success
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
        l_base_fcst_age_group1 := 0 ;
        l_base_fcst_age_group2 := 0 ;
        l_base_fcst_age_group3 := 0 ;
        l_base_fcst_age_group4 := 0 ;

        l_loc := 'Opening cursor to determine the age.' ;
        -- Calculate the forecast amount for a given organization
        OPEN  l_rnwl_age_csr (p_summary_build_date,
              rec_l_org_id_csr.org_id, rec_l_org_id_csr.customer_party_id,
              oki_load_rag_pvt.g_start_age_group1,
              oki_load_rag_pvt.g_end_age_group1,
              oki_load_rag_pvt.g_start_age_group2,
              oki_load_rag_pvt.g_end_age_group2,
              oki_load_rag_pvt.g_start_age_group3,
              oki_load_rag_pvt.g_end_age_group3,
              oki_load_rag_pvt.g_start_age_group4  ) ;
        FETCH l_rnwl_age_csr INTO rec_l_rnwl_age_csr ;
          IF l_rnwl_age_csr%FOUND THEN
            l_base_fcst_age_group1 := rec_l_rnwl_age_csr.age_group1 ;
            l_base_fcst_age_group2 := rec_l_rnwl_age_csr.age_group2 ;
            l_base_fcst_age_group3 := rec_l_rnwl_age_csr.age_group3 ;
            l_base_fcst_age_group4 := rec_l_rnwl_age_csr.age_group4 ;
          END IF ;
        CLOSE l_rnwl_age_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_rag_pvt.g_rag_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_id_csr.org_id,
             rec_l_org_id_csr.customer_party_id,
             oki_load_rag_pvt.g_all_scs_code ) ;
        FETCH oki_load_rag_pvt.g_rag_csr INTO rec_g_rag_csr ;
          IF oki_load_rag_pvt.g_rag_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;

            -- Insert the current period data for the period
            oki_load_rag_pvt.ins_rnwl_aging (
                p_period_set_name     => rec_g_glpr_csr.period_set_name
              , p_period_name         => rec_g_glpr_csr.period_name
              , p_period_type         => rec_g_glpr_csr.period_type
              , p_authoring_org_id    => rec_l_org_id_csr.org_id
              , p_authoring_org_name  => rec_l_org_id_csr.organization_name
              , p_customer_party_id   => rec_l_org_id_csr.customer_party_id
              , p_customer_name       => rec_l_org_id_csr.customer_name
              , p_scs_code            => oki_load_rag_pvt.g_all_scs_code
              , p_age_group1          => l_base_fcst_age_group1
              , p_age_group2          => l_base_fcst_age_group2
              , p_age_group3          => l_base_fcst_age_group3
              , p_age_group4          => l_base_fcst_age_group4
              , x_retcode             => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rag_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_rag_pvt.upd_rnwl_aging (
                p_age_group1          => l_base_fcst_age_group1
              , p_age_group2          => l_base_fcst_age_group2
              , p_age_group3          => l_base_fcst_age_group3
              , p_age_group4          => l_base_fcst_age_group4
              , p_rag_rowid           => rec_g_rag_csr.rowid
              , x_retcode             => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rag_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_rag_pvt.g_rag_csr ;

      END LOOP g_glpr_csr_loop ;
   END LOOP l_org_id_csr_loop ;


  EXCEPTION
    WHEN oki_load_rag_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_rag_PVT.CALC_RAG_DTL2');

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

  END calc_rag_dtl2 ;

--------------------------------------------------------------------------------
  -- Procedure to calcuate the age of the renewal for the organizations.
  -- Calculates the amounts across customers and subclasses
  --   each period set name
  --   each period type
  --   each period name
  --   all  customers
  --   all  subclasses
  --   each organization
  --
--------------------------------------------------------------------------------
  PROCEDURE calc_rag_sum
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , x_retcode            OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode  VARCHAR2(100)  := NULL ;
  l_sqlerrm  VARCHAR2(1000) := NULL ;

  l_base_fcst_age_group1   NUMBER := 0 ;
  l_base_fcst_age_group2   NUMBER := 0 ;
  l_base_fcst_age_group3   NUMBER := 0 ;
  l_base_fcst_age_group4   NUMBER := 0 ;

  -- holds the rowid of the record in the oki_rnwl_age_by_orgs table
  l_rag_rowid ROWID ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date  DATE ;
  l_glpr_end_date    DATE ;

  -- Cusor declaration

  -- Cursor to get all the organizations
  CURSOR l_org_id_csr IS
    SELECT   DISTINCT shd.authoring_org_id org_id
           , /*11510 changes*/ NULL organization_name
    FROM     oki_sales_k_hdrs shd
    ;

  -- Cursor to calculate the age of the renewals for each
  -- organization
  CURSOR l_rnwl_age_csr
  (   p_summary_build_date IN DATE
    , p_org_id             IN NUMBER
    , p_start_age_group1   IN NUMBER
    , p_end_age_group1     IN NUMBER
    , p_start_age_group2   IN NUMBER
    , p_end_age_group2     IN NUMBER
    , p_start_age_group3   IN NUMBER
    , p_end_age_group3     IN NUMBER
    , p_start_age_group4   IN NUMBER
  ) IS
    SELECT
         NVL(SUM(DECODE(SIGN( (TRUNC(p_summary_build_date) -
                            TRUNC(shd.creation_date)) - p_start_age_group1),
            1, DECODE(SIGN( p_end_age_group1 -
                     (TRUNC(p_summary_build_date) - trunc(shd.creation_date))),
                 1, shd.base_forecast_amount,
                 0, shd.base_forecast_amount,
                 0),
            0, shd.base_forecast_amount,
            0)), 0) age_group1,
         NVL(SUM(DECODE(SIGN( (TRUNC(p_summary_build_date) -
                            TRUNC(shd.creation_date)) - p_start_age_group2),
            1, DECODE(SIGN( p_end_age_group2 -
                     (TRUNC(p_summary_build_date) - TRUNC(shd.creation_date))),
                 1, shd.base_forecast_amount,
                 0, shd.base_forecast_amount,
                 0),
            0, shd.base_forecast_amount,
            0)), 0) age_group2,
         NVL(SUM(DECODE(SIGN( (TRUNC(p_summary_build_date) -
                            TRUNC(shd.creation_date)) - p_start_age_group3),
            1, decode(sign( p_end_age_group3 -
                     (trunc(p_summary_build_date) - trunc(shd.creation_date))),
                 1, shd.base_forecast_amount,
                 0, shd.base_forecast_amount,
                 0),
            0, shd.base_forecast_amount,
            0)), 0) age_group3,
         NVL(SUM(DECODE(SIGN( (TRUNC(p_summary_build_date) -
                            TRUNC(shd.creation_date)) - p_start_age_group4),
            1, shd.base_forecast_amount,
            0, shd.base_forecast_amount,
            0)), 0) age_group4
    FROM     oki_sales_k_hdrs shd
    -- contract has undergone forecasting
    WHERE    shd.win_percent is not null
    AND      shd.close_date  is not null
    -- renewal contract      is entered
    AND      shd.ste_code          = 'ENTERED'
    AND      is_new_yn         IS NULL
    AND      shd.authoring_org_id  = p_org_id
    ;
  rec_l_rnwl_age_csr l_rnwl_age_csr%ROWTYPE ;


  BEGIN

    -- Initialize return code to success
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
        l_base_fcst_age_group1 := 0 ;
        l_base_fcst_age_group2 := 0 ;
        l_base_fcst_age_group3 := 0 ;
        l_base_fcst_age_group4 := 0 ;

        l_loc := 'Opening cursor to determine the age.' ;
        -- Calculate the forecast amount for a given organization
        OPEN  l_rnwl_age_csr (p_summary_build_date,
              rec_l_org_id_csr.org_id, oki_load_rag_pvt.g_start_age_group1,
              oki_load_rag_pvt.g_end_age_group1,
              oki_load_rag_pvt.g_start_age_group2,
              oki_load_rag_pvt.g_end_age_group2,
              oki_load_rag_pvt.g_start_age_group3,
              oki_load_rag_pvt.g_end_age_group3,
              oki_load_rag_pvt.g_start_age_group4  ) ;
        FETCH l_rnwl_age_csr INTO rec_l_rnwl_age_csr ;
          IF l_rnwl_age_csr%FOUND THEN
            l_base_fcst_age_group1 := rec_l_rnwl_age_csr.age_group1 ;
            l_base_fcst_age_group2 := rec_l_rnwl_age_csr.age_group2 ;
            l_base_fcst_age_group3 := rec_l_rnwl_age_csr.age_group3 ;
            l_base_fcst_age_group4 := rec_l_rnwl_age_csr.age_group4 ;
          END IF ;
        CLOSE l_rnwl_age_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_rag_pvt.g_rag_csr ( rec_g_glpr_csr.period_set_name,
             rec_g_glpr_csr.period_name, rec_l_org_id_csr.org_id,
             oki_load_rag_pvt.g_all_cst_id, oki_load_rag_pvt.g_all_scs_code ) ;
        FETCH oki_load_rag_pvt.g_rag_csr INTO rec_g_rag_csr ;
          IF oki_load_rag_pvt.g_rag_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;

            -- Insert the current period data for the period
            oki_load_rag_pvt.ins_rnwl_aging (
                p_period_set_name     => rec_g_glpr_csr.period_set_name
              , p_period_name         => rec_g_glpr_csr.period_name
              , p_period_type         => rec_g_glpr_csr.period_type
              , p_authoring_org_id    => rec_l_org_id_csr.org_id
              , p_authoring_org_name  => rec_l_org_id_csr.organization_name
              , p_customer_party_id   => oki_load_rag_pvt.g_all_cst_id
              , p_customer_name       => oki_load_rag_pvt.g_all_cst_name
              , p_scs_code            => oki_load_rag_pvt.g_all_scs_code
              , p_age_group1          => l_base_fcst_age_group1
              , p_age_group2          => l_base_fcst_age_group2
              , p_age_group3          => l_base_fcst_age_group3
              , p_age_group4          => l_base_fcst_age_group4
              , x_retcode             => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rag_pvt.g_excp_exit_immediate ;
            END IF ;
          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_rag_pvt.upd_rnwl_aging (
                p_age_group1          => l_base_fcst_age_group1
              , p_age_group2          => l_base_fcst_age_group2
              , p_age_group3          => l_base_fcst_age_group3
              , p_age_group4          => l_base_fcst_age_group4
              , p_rag_rowid           => rec_g_rag_csr.rowid
              , x_retcode             => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_rag_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;
        CLOSE oki_load_rag_pvt.g_rag_csr ;

      END LOOP g_glpr_csr_loop ;
   END LOOP l_org_id_csr_loop ;


  EXCEPTION
    WHEN oki_load_rag_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_rag_PVT.CALC_RAG_SUM');

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
  END calc_rag_sum ;

--------------------------------------------------------------------------------
  -- Procedure to create all the renewal aging by organization records.  If an
  -- error is encountered in this procedure or subsequent procedures then
  -- rollback all changes.  Once the table is loaded and the data is committed
  -- the load is considered successful even if update of the oki_refreshs
  -- table failed.
--------------------------------------------------------------------------------

  PROCEDURE crt_rnwl_aging
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
  l_table_name  CONSTANT VARCHAR2(30) := 'OKI_RENEWAL_AGING' ;



  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;


  BEGIN

    SAVEPOINT oki_load_rag_pvt_crt_rnwl_age ;

    -- initialize return code to success
    l_retcode := '0' ;
    x_retcode := '0' ;

    -- Procedure to calculate the amounts for each dimension
    oki_load_rag_pvt.calc_rag_dtl1 (
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

     IF l_retcode = '2' THEN
       -- Load failed, exit immediately.
       RAISE oki_load_rag_pvt.g_excp_exit_immediate ;
     END IF ;

    -- Procedure to calculate the amounts across subclasses
    oki_load_rag_pvt.calc_rag_dtl2 (
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

     IF l_retcode = '2' THEN
       -- Load failed, exit immediately.
       RAISE oki_load_rag_pvt.g_excp_exit_immediate ;
     END IF ;

    -- Procedure to calculate the amounts across customers
    -- and subclasses
    oki_load_rag_pvt.calc_rag_sum (
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

     IF l_retcode = '2' THEN
       -- Load failed, exit immediately.
       RAISE oki_load_rag_pvt.g_excp_exit_immediate ;
     END IF ;

     COMMIT;

    SAVEPOINT oki_load_rag_pvt_upd_refresh ;

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

      ROLLBACK to oki_load_rag_pvt_upd_refresh ;

    WHEN oki_load_rag_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

      ROLLBACK TO oki_load_rag_pvt_crt_rnwl_age ;

    WHEN OTHERS THEN

      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2' ;

      -- Rollback all transactions
      ROLLBACK TO oki_load_rag_pvt_crt_rnwl_age ;


      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_RAG_PVT.CRT_RNWL_AGE_BY_ORGS');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END crt_rnwl_aging ;

BEGIN
  -- Initialize the global variables used to log this job run
  -- FROM concurrent manager
  g_request_id             :=  fnd_global.conc_request_id ;
  g_program_application_id :=  fnd_global.prog_appl_id ;
  g_program_id             :=  fnd_global.conc_program_id ;
  g_program_update_date    :=  SYSDATE ;

END oki_load_rag_pvt ;

/
