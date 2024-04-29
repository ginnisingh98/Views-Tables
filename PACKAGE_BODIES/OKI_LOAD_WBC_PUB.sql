--------------------------------------------------------
--  DDL for Package Body OKI_LOAD_WBC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_LOAD_WBC_PUB" AS
/* $Header: OKIPWBCB.pls 115.8 2002/12/01 17:53:31 rpotnuru noship $ */

-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--------------------------------------------------------------------------------
  -- Procedure to create all the wip by customer records.

--------------------------------------------------------------------------------
  PROCEDURE crt_wip_by_cust
  (   x_errbuf             OUT NOCOPY VARCHAR2
    , x_retcode            OUT NOCOPY VARCHAR2
    , p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  VARCHAR2
  ) IS


  -- Local variable declaration

  -- Effective date of the job run.
  -- Also treated as "current date" for bin calculations (e.g., aging reports).
  l_summary_build_date DATE := NULL ;

  BEGIN

    -- Convert the varchar2 date input to a date datatype
    l_summary_build_date := fnd_conc_date.string_to_date(p_summary_build_date);

    -- Call procedure to create the WIP by customers
    oki_load_wbc_pvt.crt_wip_by_cust (
          p_period_set_name    => p_period_set_name
        , p_period_type        => p_period_type
        , p_summary_build_date => l_summary_build_date
        , x_errbuf             => x_errbuf
        , x_retcode            => x_retcode ) ;

  END crt_wip_by_cust ;

END oki_load_wbc_pub ;

/
