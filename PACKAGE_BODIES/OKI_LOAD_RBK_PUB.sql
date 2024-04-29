--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_RBK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_RBK_PUB" AS
/* $Header: OKIPRBKB.pls 115.2 2002/12/01 17:50:52 rpotnuru noship $ */
--------------------------------------------------------------------------------
-- Modification History
-- 26-DEC-2001 mezra        Initial version
-- 15-APR-2002 mezra        Added dbdrv and set verify off commands.
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
  -- Procedure to create all the renewal bookings records.

--------------------------------------------------------------------------------
  PROCEDURE crt_rnwl_bkng
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


    -- Call procedure to create the renewal bookings
    oki_load_rbk_pvt.crt_rnwl_bkng (
          p_start_summary_build_date  => l_start_summary_build_date
        , p_end_summary_build_date    => l_end_summary_build_date
        , x_errbuf                    => x_errbuf
        , x_retcode                   => x_retcode ) ;

  END crt_rnwl_bkng ;

END oki_load_rbk_pub ;

/
