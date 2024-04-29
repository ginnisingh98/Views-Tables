--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_OKV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_OKV_PUB" AS
/* $Header: OKIPOKVB.pls 115.7 2002/12/01 17:53:03 rpotnuru noship $ */

-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--------------------------------------------------------------------------------
  -- Procedure to create all the performance measures records.

--------------------------------------------------------------------------------
  PROCEDURE create_perf_measures
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


    -- call procedure to create the performance measures
    oki_load_okv_pvt.create_perf_measures(
          p_period_set_name    => p_period_set_name
        , p_period_type        => p_period_type
        , p_summary_build_date => l_summary_build_date
        , x_errbuf             => x_errbuf
        , x_retcode            => x_retcode ) ;

  END create_perf_measures ;

END oki_load_okv_pub ;

/
