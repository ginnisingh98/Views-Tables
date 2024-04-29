--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_ETR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_ETR_PUB" AS
/* $Header: OKIPETRB.pls 115.2 2002/12/01 17:51:14 rpotnuru noship $ */
--------------------------------------------------------------------------------
-- Modification History
-- 26-DEC-2001 mezra        Initial version
-- 30-APR-2002 mezra        Added dbdrv and set verify command.
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
  -- Procedure to create all the expiration to renewal records.

--------------------------------------------------------------------------------
  PROCEDURE crt_exp_to_rnwl
  (   x_errbuf                    OUT NOCOPY VARCHAR2
    , x_retcode                   OUT NOCOPY VARCHAR2
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


    -- Call procedure to create the expiration to renewal
    oki_load_etr_pvt.crt_exp_to_rnwl (
          p_start_summary_build_date  => l_start_summary_build_date
        , p_end_summary_build_date    => l_end_summary_build_date
        , x_errbuf                    => x_errbuf
        , x_retcode                   => x_retcode ) ;

  END crt_exp_to_rnwl;

END oki_load_etr_pub ;

/
