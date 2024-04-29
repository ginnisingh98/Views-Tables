--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_TNK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_TNK_PVT" AS
/* $Header: OKIRTNKB.pls 115.1 2002/07/05 18:02:32 appldev noship $ */

--------------------------------------------------------------------------------
-- Modification History
-- 10-Apr-2002  mezra         Initial version.
--                            Create stub in order to branch.
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Procedure to insert records into the oki_top_x_k table.
--
--------------------------------------------------------------------------------
  PROCEDURE crt_top_n_k
  (   p_start_summary_build_date IN  DATE     DEFAULT SYSDATE
    , p_end_summary_build_date   IN  DATE     DEFAULT SYSDATE
    , x_errbuf                   OUT VARCHAR2
    , x_retcode                  OUT VARCHAR2
  ) IS

  -- Local variable declaration

  -- For capturing the return code, 0 = success, 1 = warning, 2 = error
  l_retcode          VARCHAR2(1)    := NULL ;
  -- For error handling
  l_sqlcode            VARCHAR2(100) ;
  l_sqlerrm            VARCHAR2(1000) ;

  BEGIN
    -- initialize return code to success
    l_retcode := '0' ;
    x_retcode := '0' ;

  EXCEPTION

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
                            , value => 'OKI_LOAD_TNK_PVT.CRT_TOP_N_K' ) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => fnd_message.get ) ;

      fnd_file.put_line(  which => fnd_file.log
                        , buff  => l_sqlcode||' '||l_sqlerrm ) ;
  END crt_top_n_k ;

BEGIN
  -- Initialize the global variables used to log this job run
  -- FROM concurrent manager
  g_request_id             :=  fnd_global.conc_request_id ;
  g_program_application_id :=  fnd_global.prog_appl_id ;
  g_program_id             :=  fnd_global.conc_program_id ;
  g_program_update_date    :=  SYSDATE ;

END oki_load_tnk_pvt ;

/
