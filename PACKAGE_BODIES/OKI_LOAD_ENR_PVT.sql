--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_ENR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_ENR_PVT" as
/* $Header: OKIRENRB.pls 115.9 2003/11/24 08:24:31 kbajaj ship $ */

--------------------------------------------------------------------------------
-- Modification History
-- 19-Sep-2001  mezra        Initial version
-- 25-Sep-2001  mezra        Change usd_ columns to base_.
-- 22-Oct-2001  mezra        Changed All Categories value to -1.
-- 24-Oct-2001  mezra        Removed trunc on date columns to increase
--                           performance since index will be used.
-- 26-NOV-2002  rpotnuru     NOCOPY Changes
-- 19-Dec-2002  brrao        UTF-8 Changes to Org Name
--
-- 29-Oct-2003  axraghav     Modified l_exp_not_rnw_csr in calc_enr_dtl1 to
--                           populate null values form salesrep name,modified
--                           the join condition to join with Oki_cov_prd_lines
--                           Modified calc_enr_dtl1 to populate null values
--                           for customer and organization names
--                           Modified l_cust_id_csr in calc_enr_dtl2 to populate
--                           null values for customer and organization names
--                           Modified l_exp_not_rnw_csr in calc_enr_dtl2 to
--                           populate null values form salesrep name,modified
--                           the join condition to join with Oki_cov_prd_lines
--                           Modified calc_enr_sum  to populate
--                           null values for customer and organization names
--------------------------------------------------------------------------------

  -- Global exception declaration

  -- Generic exception to immediately exit the procedure
  g_excp_exit_immediate   EXCEPTION ;


  -- Global constant delcaration

  -- Constants for the "All" organization and subclass record
  g_all_org_id       CONSTANT NUMBER       := -1 ;
  g_all_org_name     CONSTANT VARCHAR2(240) := 'All Organizations' ;
  g_all_scs_code     CONSTANT VARCHAR2(30) := '-1' ;
  g_all_contact_id   CONSTANT NUMBER       := -1 ;
  g_all_contact_name CONSTANT VARCHAR2(30) := 'All Sales Reps' ;


  -- Global cursor declaration

  -- Cusror to retrieve the rowid for the selected record.
  -- If a rowid is retrieved, then the record is updated,
  -- else the record is inserted.
  CURSOR g_enr_csr
  (   p_period_set_name   IN  VARCHAR2
    , p_period_name       IN  VARCHAR2
    , p_authoring_org_id  IN  NUMBER
    , p_customer_party_id IN  VARCHAR2
    , p_contact_id        IN  VARCHAR2
    , p_scs_code          IN  VARCHAR2
  ) IS
    SELECT rowid
    FROM   oki_exp_not_renewed enr
    WHERE  enr.period_set_name   = p_period_set_name
    AND    enr.period_name       = p_period_name
    AND    enr.authoring_org_id  = p_authoring_org_id
    AND    enr.customer_party_id = p_customer_party_id
    AND   (enr.contact_id        = p_contact_id
           or enr.contact_id IS NULL )
    AND    enr.scs_code          = p_scs_code
    ;
  rec_g_enr_csr g_enr_csr%ROWTYPE ;

--------------------------------------------------------------------------------
  -- Procedure to insert records into the oki_exp_by_customers table.

--------------------------------------------------------------------------------
  PROCEDURE ins_exp_not_rnw
  (   p_period_set_name             IN  VARCHAR2
    , p_period_name                 IN  VARCHAR2
    , p_period_type                 IN  VARCHAR2
    , p_authoring_org_id            IN  NUMBER
    , p_authoring_org_name          IN  VARCHAR2
    , p_customer_party_id           IN  NUMBER
    , p_customer_name               IN  VARCHAR2
    , p_contact_id                  IN  NUMBER
    , p_salesrep_name               IN  VARCHAR2
    , p_scs_code                    IN  VARCHAR2
    , p_base_lost_amount            IN  NUMBER
    , p_contract_count              IN  NUMBER
    , x_retcode                     OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;

  l_sequence  NUMBER := NULL ;

  -- Cursor declaration
  CURSOR l_seq_num IS
    SELECT oki_exp_not_renewed_s1.nextval seq
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

    INSERT INTO oki_exp_not_renewed
    (        id
           , period_set_name
           , period_name
           , period_type
           , authoring_org_id
           , authoring_org_name
           , customer_party_id
           , customer_name
           , contact_id
           , salesrep_name
           , scs_code
           , base_lost_amount
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
           , p_customer_party_id
           , p_customer_name
           , p_contact_id
           , p_salesrep_name
           , p_scs_code
           , p_base_lost_amount
           , p_contract_count
           , oki_load_enr_pvt.g_request_id
           , oki_load_enr_pvt.g_program_application_id
           , oki_load_enr_pvt.g_program_id
           , oki_load_enr_pvt.g_program_update_date ) ;


  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_TABLE_LOAD_FAILURE');

      fnd_message.set_token(  token => 'TABLE_NAME'
                            , value => 'OKI_EXP_NOT_RENEWED');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END ins_exp_not_rnw ;

--------------------------------------------------------------------------------
  -- Procedure to update records in the oki_exp_by_customers table.

--------------------------------------------------------------------------------
  PROCEDURE upd_exp_not_rnw
  (   p_base_lost_amount  IN  NUMBER
    , p_contract_count    IN  NUMBER
    , p_enr_rowid         IN  ROWID
    , x_retcode           OUT NOCOPY VARCHAR2
  ) IS

  -- Local variable declaration

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;


  BEGIN

    -- initialize return code to success
    x_retcode := '0';

    UPDATE oki_exp_not_renewed SET
        base_lost_amount       = p_base_lost_amount
      , contract_count         = p_contract_count
      , request_id             = oki_load_enr_pvt.g_request_id
      , program_application_id = oki_load_enr_pvt.g_program_application_id
      , program_id             = oki_load_enr_pvt.g_program_id
      , program_update_date    = oki_load_enr_pvt.g_program_update_date
    WHERE ROWID = p_enr_rowid ;

  EXCEPTION
    WHEN OTHERS THEN
      l_sqlcode := SQLCODE ;
      l_sqlerrm := SQLERRM ;

      -- Set return code to error
      x_retcode := '2';

      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_ENR_PVT.UPD_EXP_NOT_RNW');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );
  END upd_exp_not_rnw ;

--------------------------------------------------------------------------------
  -- Procedure to calcuate the base price negotiated amount and contract counts
  -- for the customers.
  -- Calculates the counts and amounts by each dimension:
  --   period set name
  --   period type
  --   period name
  --   customer
  --   sales rep
  --   subclass
  --   organization
  --
--------------------------------------------------------------------------------
  PROCEDURE calc_enr_dtl1
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
  l_base_price_negotiated_amount NUMBER := 0 ;
  l_contract_count               NUMBER := 0 ;

  -- Holds the salesrep ID and name
  l_contact_id           VARCHAR2(40)  := NULL ;
  l_salesrep_name        VARCHAR2(240) := NULL ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;

  -- Cusror declaration
  -- Cursor that calculates the base price negotiated amount and
  -- contract counts for a particular customer, organization and subclass
  CURSOR l_exp_not_rnw_csr
  (   p_glpr_start_date   IN DATE
    , p_glpr_end_date     IN DATE
    , p_authoring_org_id  IN NUMBER
    , p_customer_party_id IN NUMBER
    , p_scs_code          IN VARCHAR2
  ) IS
    SELECT   slr.contact_id
           , NULL salesrep_name /* 1150 Change slr.salesrep_name to null */
             -- display consolidate amount in correct currency format
           , NVL(SUM(cpl/*11510 change ocl*/.base_price_negotiated), 0) base_price_negotiated_amount
             -- display number in correct number format
           , COUNT(DISTINCT (shd.chr_id )) contract_count
    FROM     /*11510 change removed oki_expired_lines oel */
             oki_cov_prd_lines cpl
           , oki_sales_k_hdrs shd
           , oki_k_salesreps slr
    WHERE    shd.chr_id                = /*oel*/cpl.chr_id
    /*11510 changes start */
    AND      cpl.is_exp_not_renewed_yn = 'Y'
    /*11510 changes end */
    AND      cpl/*oel*/.end_date BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND      shd.customer_party_id = p_customer_party_id
    AND      shd.authoring_org_id  = p_authoring_org_id
    AND      shd.scs_code          = p_scs_code
    AND      slr.contract_id(+)    = shd.chr_id
    GROUP BY slr.contact_id   ;

  rec_l_exp_not_rnw_csr l_exp_not_rnw_csr%ROWTYPE ;

  -- Cusror to get all the customers, organizations and subclass
  CURSOR l_cust_id_csr IS
    SELECT DISTINCT(shd.customer_party_id) customer_id
           , NULL customer_name /*11510 change null out shd.customer_name  */
           , shd.authoring_org_id authoring_org_id
           , NULL authoring_org_name /*11510 change null out shd.organization_name  */
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

        -- Re-initialize the amounts and counts before calculating
        l_base_price_negotiated_amount := 0 ;
        l_contract_count               := 0 ;

        l_loc := 'Opening cursor to determine the base price negoiated sum ' ||
                 'and contract sum ' ;
        -- Calculate the forecast amount for a given customer
        OPEN  l_exp_not_rnw_csr( l_glpr_start_date, l_glpr_end_date,
              rec_l_cust_id_csr.authoring_org_id,
              rec_l_cust_id_csr.customer_id, rec_l_cust_id_csr.scs_code ) ;
        FETCH l_exp_not_rnw_csr INTO rec_l_exp_not_rnw_csr ;
          IF l_exp_not_rnw_csr%FOUND THEN
            l_base_price_negotiated_amount :=
                                rec_l_exp_not_rnw_csr.base_price_negotiated_amount ;
            l_contract_count := rec_l_exp_not_rnw_csr.contract_count ;
            l_contact_id     := rec_l_exp_not_rnw_csr.contact_id ;
            l_salesrep_name  := rec_l_exp_not_rnw_csr.salesrep_name ;
          END IF ;
        CLOSE l_exp_not_rnw_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_enr_pvt.g_enr_csr( rec_g_glpr_csr.period_set_name,
              rec_g_glpr_csr.period_name,
              rec_l_cust_id_csr.authoring_org_id,
              rec_l_cust_id_csr.customer_id, l_contact_id,
              rec_l_cust_id_csr.scs_code ) ;
        FETCH oki_load_enr_pvt.g_enr_csr into rec_g_enr_csr ;
          IF oki_load_enr_pvt.g_enr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_enr_pvt.ins_exp_not_rnw(
                p_period_name                 => rec_g_glpr_csr.period_name
              , p_period_set_name             => rec_g_glpr_csr.period_set_name
              , p_period_type                 => rec_g_glpr_csr.period_type
              , p_authoring_org_id            => rec_l_cust_id_csr.authoring_org_id
              , p_authoring_org_name          => rec_l_cust_id_csr.authoring_org_name
              , p_customer_party_id           => rec_l_cust_id_csr.customer_id
              , p_customer_name               => rec_l_cust_id_csr.customer_name
              , p_contact_id                  => l_contact_id
              , p_salesrep_name               => l_salesrep_name
              , p_scs_code                    => rec_l_cust_id_csr.scs_code
              , p_base_lost_amount            => l_base_price_negotiated_amount
              , p_contract_count              => l_contract_count
              , x_retcode                     => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_enr_pvt.g_excp_exit_immediate ;
              EXIT ;
            END IF ;

          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_enr_pvt.upd_exp_not_rnw(
                p_base_lost_amount            => l_base_price_negotiated_amount
              , p_contract_count              => l_contract_count
              , p_enr_rowid                   => rec_g_enr_csr.rowid
              , x_retcode                     => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_enr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;

        CLOSE oki_load_enr_pvt.g_enr_csr ;

      END LOOP g_glpr_csr_loop ;
    END LOOP l_cust_id_csr_loop ;

  EXCEPTION
    WHEN oki_load_enr_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_ENR_PVT.calc_enr_dtl1');

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

  END calc_enr_dtl1 ;

--------------------------------------------------------------------------------
  -- Procedure to calcuate the base price negoiated amount and contract counts
  -- for the customers.
  -- Calculates the counts and amounts across organizations:
  --   each period set name
  --   each period type
  --   each period name
  --   each customer
  --   each sales rep
  --   each subclass
  --   all  organizations
  --
--------------------------------------------------------------------------------
  PROCEDURE calc_enr_dtl2
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
  l_base_price_negotiated_amount NUMBER := 0 ;
  l_contract_count               NUMBER := 0 ;

  -- Holds the salesrep ID and name
  l_contact_id           VARCHAR2(40)  := NULL ;
  l_salesrep_name        VARCHAR2(240) := NULL ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;

  -- Cusror declaration

  -- Cursor that calculates the base price negotiated amount and
  -- contract counts for a particular customer and subclass
  CURSOR l_exp_not_rnw_csr
  (   p_glpr_start_date   IN DATE
    , p_glpr_end_date     IN DATE
    , p_customer_party_id IN NUMBER
    , p_scs_code          IN VARCHAR2
  ) IS
    SELECT   slr.contact_id
           , NULL salesrep_name /*11510 Change  modified slr.salesrep_name */
             -- display consolidate amount in correct currency format
           , NVL(SUM(cpl.base_price_negotiated), 0) base_price_negotiated_amount
             -- display number in correct number format
           , COUNT(DISTINCT (shd.chr_id )) contract_count
    FROM     /*11510 change removed oki_expired_lines oel added oki_cov_prd_lines */
             oki_cov_prd_lines cpl
           , oki_sales_k_hdrs shd
           , oki_k_salesreps slr
    WHERE    shd.chr_id             = cpl.chr_id
/*11510 change start*/
    AND      cpl.is_exp_not_renewed_yn = 'Y'
/*11510 change end*/
    AND      cpl.end_date           BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND      shd.customer_party_id  = p_customer_party_id
    AND      slr.contract_id(+)     = shd.chr_id
    AND      shd.scs_code           = p_scs_code
    GROUP BY slr.contact_id ;

  rec_l_exp_not_rnw_csr l_exp_not_rnw_csr%ROWTYPE ;

  -- Cusror to get all the disctinct customers and subclass combinations
  CURSOR l_cust_id_csr IS
    SELECT DISTINCT(shd.customer_party_id) customer_id
           , NULL customer_name /*11510 change null out shd.customer_name */
           , shd.scs_code
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

        -- Re-initialize the amounts and counts before calculating
        l_base_price_negotiated_amount := 0 ;
        l_contract_count               := 0 ;

        l_loc := 'Opening cursor to determine the base price negoiated sum ' ||
                 'and contract sum ' ;
        -- Calculate the forecast amount for a given customer
        OPEN  l_exp_not_rnw_csr( l_glpr_start_date, l_glpr_end_date,
              rec_l_cust_id_csr.customer_id, rec_l_cust_id_csr.scs_code ) ;
        FETCH l_exp_not_rnw_csr INTO rec_l_exp_not_rnw_csr ;
          IF l_exp_not_rnw_csr%FOUND THEN
            l_base_price_negotiated_amount :=
                                rec_l_exp_not_rnw_csr.base_price_negotiated_amount ;
            l_contract_count := rec_l_exp_not_rnw_csr.contract_count ;
            l_contact_id     := rec_l_exp_not_rnw_csr.contact_id ;
            l_salesrep_name  := rec_l_exp_not_rnw_csr.salesrep_name ;
          END IF ;
        CLOSE l_exp_not_rnw_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN oki_load_enr_pvt.g_enr_csr( rec_g_glpr_csr.period_set_name,
              rec_g_glpr_csr.period_name, oki_load_enr_pvt.g_all_org_id,
              rec_l_cust_id_csr.customer_id, l_contact_id,
              rec_l_cust_id_csr.scs_code ) ;
        FETCH oki_load_enr_pvt.g_enr_csr into rec_g_enr_csr ;
          IF oki_load_enr_pvt.g_enr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_enr_pvt.ins_exp_not_rnw(
                p_period_name                 => rec_g_glpr_csr.period_name
              , p_period_set_name             => rec_g_glpr_csr.period_set_name
              , p_period_type                 => rec_g_glpr_csr.period_type
              , p_authoring_org_id            => oki_load_enr_pvt.g_all_org_id
              , p_authoring_org_name          => oki_load_enr_pvt.g_all_org_name
              , p_customer_party_id           => rec_l_cust_id_csr.customer_id
              , p_customer_name               => rec_l_cust_id_csr.customer_name
              , p_contact_id                  => l_contact_id
              , p_salesrep_name               => l_salesrep_name
              , p_scs_code                    => rec_l_cust_id_csr.scs_code
              , p_base_lost_amount            => l_base_price_negotiated_amount
              , p_contract_count              => l_contract_count
              , x_retcode                     => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_enr_pvt.g_excp_exit_immediate ;
              EXIT ;
            END IF ;

          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_enr_pvt.upd_exp_not_rnw(
                p_base_lost_amount             => l_base_price_negotiated_amount
              , p_contract_count              => l_contract_count
              , p_enr_rowid                   => rec_g_enr_csr.rowid
              , x_retcode                     => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_enr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;

        CLOSE oki_load_enr_pvt.g_enr_csr ;

      END LOOP g_glpr_csr_loop ;
    END LOOP l_cust_id_csr_loop ;

  EXCEPTION
    WHEN oki_load_enr_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_ENR_PVT.CALC_ENR_DTL2');

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

  END calc_enr_dtl2 ;

--------------------------------------------------------------------------------
  -- Procedure to calcuate the base price negoiated amount and contract counts
  -- for the customers.
  -- Calculates the counts and amounts across sales reps, organizations
  -- and subclasses
  --   each period set name
  --   each period type
  --   each period name
  --   each customer
  --   all  sales rep
  --   all  subclasses
  --   all  organizations
  --
--------------------------------------------------------------------------------
  PROCEDURE calc_enr_sum
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
  l_base_price_negotiated_amount NUMBER := 0 ;
  l_contract_count               NUMBER := 0 ;

  -- Location within the program before the error was encountered.
  l_loc                  VARCHAR2(100) ;

  -- Holds the truncated start and end dates from gl_periods
  l_glpr_start_date      DATE ;
  l_glpr_end_date        DATE ;

  -- Cusror declaration

  -- Cursor that calculates the base price negotiated amount and
  -- contract counts for a particular customer
  CURSOR l_exp_not_rnw_csr
  (   p_glpr_start_date   IN DATE
    , p_glpr_end_date     IN DATE
    , p_customer_party_id IN NUMBER
  ) IS
    SELECT
             -- display consolidate amount in correct currency format
            NVL(SUM(cpl.base_price_negotiated), 0) base_price_negotiated_amount
             -- display number in correct number format
           , COUNT(DISTINCT (shd.chr_id )) contract_count
    FROM    /*11510 change removed oki_expired_lines oel*/
             oki_cov_prd_lines cpl
           , oki_sales_k_hdrs shd
    WHERE    shd.chr_id             = cpl.chr_id
  /*11510 change start*/
    AND      cpl.is_exp_not_renewed_yn = 'Y'
 /*11510 change end*/
    AND      cpl.end_date           BETWEEN p_glpr_start_date AND p_glpr_end_date
    AND      shd.customer_party_id  = p_customer_party_id
    ;
  rec_l_exp_not_rnw_csr l_exp_not_rnw_csr%ROWTYPE ;

  -- Cusror to get all the customers
  CURSOR l_cust_id_csr IS
    SELECT DISTINCT(shd.customer_party_id) customer_id
           , NULL customer_name /*11510 change null out customer name*/
           , shd.authoring_org_id authoring_org_id
           , NULL authoring_org_name /*11510 change null out authoring_org_name*/
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

        -- Re-initialize the amounts and counts before calculating
        l_base_price_negotiated_amount := 0 ;
        l_contract_count               := 0 ;

        l_loc := 'Opening cursor to determine the base price negoiated sum ' ||
                 'and contract sum ' ;
        -- Calculate the forecast amount for a given customer
        OPEN  l_exp_not_rnw_csr( l_glpr_start_date, l_glpr_end_date,
              rec_l_cust_id_csr.customer_id ) ;
        FETCH l_exp_not_rnw_csr INTO rec_l_exp_not_rnw_csr ;
          IF l_exp_not_rnw_csr%FOUND THEN
            l_base_price_negotiated_amount :=
                                rec_l_exp_not_rnw_csr.base_price_negotiated_amount ;
            l_contract_count := rec_l_exp_not_rnw_csr.contract_count ;
          END IF ;
        CLOSE l_exp_not_rnw_csr ;

        l_loc := 'Opening cursor to determine if insert or update should occur.'  ;
        -- Determine if the record is a new one or an existing one
        OPEN  oki_load_enr_pvt.g_enr_csr( rec_g_glpr_csr.period_set_name,
              rec_g_glpr_csr.period_name, oki_load_enr_pvt.g_all_org_id,
              rec_l_cust_id_csr.customer_id,
              oki_load_enr_pvt.g_all_contact_id,
              oki_load_enr_pvt.g_all_scs_code ) ;
        FETCH oki_load_enr_pvt.g_enr_csr into rec_g_enr_csr ;
          IF oki_load_enr_pvt.g_enr_csr%NOTFOUND THEN
            l_loc := 'Insert the new record.' ;
            -- Insert the current period data for the period
            oki_load_enr_pvt.ins_exp_not_rnw(
                p_period_name                 => rec_g_glpr_csr.period_name
              , p_period_set_name             => rec_g_glpr_csr.period_set_name
              , p_period_type                 => rec_g_glpr_csr.period_type
              , p_authoring_org_id            => oki_load_enr_pvt.g_all_org_id
              , p_authoring_org_name          => oki_load_enr_pvt.g_all_org_name
              , p_customer_party_id           => rec_l_cust_id_csr.customer_id
              , p_customer_name               => rec_l_cust_id_csr.customer_name
              , p_contact_id                  => oki_load_enr_pvt.g_all_contact_id
              , p_salesrep_name               => oki_load_enr_pvt.g_all_contact_name
              , p_scs_code                    => oki_load_enr_pvt.g_all_scs_code
              , p_base_lost_amount            => l_base_price_negotiated_amount
              , p_contract_count              => l_contract_count
              , x_retcode                     => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_enr_pvt.g_excp_exit_immediate ;
              EXIT ;
            END IF ;

          ELSE
            l_loc := 'Update the existing record.' ;
            -- Record already exists, so perform an update
            oki_load_enr_pvt.upd_exp_not_rnw(
                p_base_lost_amount            => l_base_price_negotiated_amount
              , p_contract_count              => l_contract_count
              , p_enr_rowid                   => rec_g_enr_csr.rowid
              , x_retcode                     => l_retcode ) ;

            IF l_retcode = '2' THEN
              -- Load failed, exit immediately.
              RAISE oki_load_enr_pvt.g_excp_exit_immediate ;
            END IF ;
          END IF ;

        CLOSE oki_load_enr_pvt.g_enr_csr ;

      END LOOP g_glpr_csr_loop ;
    END LOOP l_cust_id_csr_loop ;

  EXCEPTION
    WHEN oki_load_enr_pvt.g_excp_exit_immediate THEN
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
                            , value => 'OKI_LOAD_ENR_PVT.CALC_ENR_SUM');

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
  END calc_enr_sum;

--------------------------------------------------------------------------------
  -- Procedure to create all the expired by customer records.
  -- If an error is encountered in this procedure or subsequent procedures then
  -- rollback all changes.  Once the table is loaded and the data is committed
  -- the load is considered successful even if update of the oki_refreshs
  -- table failed.
--------------------------------------------------------------------------------
  PROCEDURE crt_exp_not_rnw
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
  l_table_name      CONSTANT VARCHAR2(30) := 'OKI_EXP_NOT_RENEWED' ;


  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;

  -- For error handling
  l_sqlcode   VARCHAR2(100) ;
  l_sqlerrm   VARCHAR2(1000) ;


  BEGIN

    SAVEPOINT oki_load_enr_pvt_crt_exp_unrnw ;

    -- initialize return code to success
    l_retcode := '0' ;
    x_retcode := '0' ;

    -- Procedure to calculate the counts and amounts for each dimension
    oki_load_enr_pvt.calc_enr_dtl1(
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_enr_pvt.g_excp_exit_immediate ;
    END IF ;

    -- Procedure to calculate the counts and amounts across organizations
    oki_load_enr_pvt.calc_enr_dtl2(
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_enr_pvt.g_excp_exit_immediate ;
    END IF ;

    -- Procedure to calculate the counts and amounts across organizations,
    -- subclasses and sales reps
    oki_load_enr_pvt.calc_enr_sum(
        p_period_set_name    => p_period_set_name
      , p_period_type        => p_period_type
      , p_summary_build_date => p_summary_build_date
      , x_retcode            => l_retcode ) ;

    IF l_retcode = '2' THEN
      -- Load failed, exit immediately.
      RAISE oki_load_enr_pvt.g_excp_exit_immediate ;
    END IF ;

    COMMIT ;

    SAVEPOINT oki_load_enr_pvt_upd_refresh ;

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

      ROLLBACK to oki_load_enr_pvt_upd_refresh ;

    WHEN oki_load_enr_pvt.g_excp_exit_immediate THEN
      -- Do not log an error ;  It has already been logged.
      -- Set return code to error
      x_retcode := '2' ;

      ROLLBACK TO oki_load_enr_pvt_crt_exp_unrnw ;

    WHEN OTHERS THEN

      l_sqlcode := sqlcode ;
      l_sqlerrm := sqlerrm ;

      -- Set return code to error
      x_retcode := '2' ;

      -- rollback all transactions
      ROLLBACK to oki_load_enr_pvt_crt_exp_unrnw ;


      fnd_message.set_name(  application => 'OKI'
                           , name        => 'OKI_UNEXPECTED_FAILURE');

      fnd_message.set_token(  token => 'OBJECT_NAME'
                            , value => 'OKI_LOAD_ENR_PVT.CRT_EXP_NOT_RNW');

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get);

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm );

  end crt_exp_not_rnw ;


BEGIN
  -- Initialize the global variables used to log this job run
  -- from concurrent manager
  g_request_id             :=  fnd_global.conc_request_id ;
  g_program_application_id :=  fnd_global.prog_appl_id ;
  g_program_id             :=  fnd_global.conc_program_id ;
  g_program_update_date    :=  SYSDATE ;

END oki_load_enr_pvt ;

/
