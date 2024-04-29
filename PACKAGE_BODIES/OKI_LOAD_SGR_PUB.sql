--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_SGR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_SGR_PUB" AS
/* $Header: OKIPSGRB.pls 115.3 2002/06/06 11:34:37 pkm ship        $ */
--------------------------------------------------------------------------------
-- Modification History
-- 10-Oct-2001 mezra        Initial version
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
  -- Procedure to create all the sequential growth rate records.

--------------------------------------------------------------------------------
  PROCEDURE crt_seq_grw
  (   x_errbuf                    OUT VARCHAR2
    , x_retcode                   OUT VARCHAR2
    , p_period_set_name           IN  VARCHAR2
    , p_period_type               IN  VARCHAR2
    , p_start_summary_build_date  IN  VARCHAR2
    , p_end_summary_build_date    IN  VARCHAR2
  ) IS


  -- Local variable declaration

  -- Effective date of the job run.
  -- Also treated as "current DATE" for bin calculations (e.g., aging reports).
  l_start_summary_build_date  DATE := NULL ;
  l_end_summary_build_date    DATE := NULL ;


  BEGIN

    -- Convert the varchar2 date input to a date datatype
    l_start_summary_build_date  :=
                   fnd_conc_date.string_to_date(p_start_summary_build_date) ;
    l_end_summary_build_date    :=
                   fnd_conc_date.string_to_date(p_end_summary_build_date) ;


    -- Call procedure to create the sequential growth rate
    oki_load_sgr_pvt.crt_seq_grw (
          p_period_set_name           => p_period_set_name
        , p_period_type               => p_period_type
        , p_start_summary_build_date  => l_start_summary_build_date
        , p_end_summary_build_date    => l_end_summary_build_date
        , x_errbuf                    => x_errbuf
        , x_retcode                   => x_retcode ) ;

  END crt_seq_grw ;

END oki_load_sgr_pub ;

/
