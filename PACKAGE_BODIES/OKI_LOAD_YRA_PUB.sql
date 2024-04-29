--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_YRA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_YRA_PUB" AS
/* $Header: OKIPYRAB.pls 115.4 2002/12/01 17:50:33 rpotnuru noship $ */
--------------------------------------------------------------------------------
-- Modification History
-- 19-Sep-2001  mezra        Initial version
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
  -- Procedure to create all the yoy renewal amount records.

--------------------------------------------------------------------------------
  PROCEDURE crt_yoy_rnwl
  (   x_errbuf             OUT NOCOPY VARCHAR2
    , x_retcode            OUT NOCOPY VARCHAR2
    , p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  VARCHAR2
  ) IS


  -- Local variable declaration

  -- Effective date of the job run.
  -- Also treated as "current DATE" for bin calculations (e.g., aging reports).
  l_summary_build_date DATE := NULL ;


  BEGIN

    -- Convert the varchar2 date input to a date datatype
    l_summary_build_date := fnd_conc_date.string_to_date(p_summary_build_date);


    -- Call procedure to create the yoy renewal
    oki_load_yra_pvt.crt_yoy_rnwl (
          p_period_set_name    => p_period_set_name
        , p_period_type        => p_period_type
        , p_summary_build_date => l_summary_build_date
        , x_errbuf             => x_errbuf
        , x_retcode            => x_retcode ) ;

  END crt_yoy_rnwl ;

END oki_load_yra_pub ;

/
