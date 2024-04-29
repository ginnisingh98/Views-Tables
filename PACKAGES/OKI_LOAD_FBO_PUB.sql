--------------------------------------------------------
--  DDL for Package OKI_LOAD_FBO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_LOAD_FBO_PUB" AUTHID CURRENT_USER AS
/* $Header: OKIPFBOS.pls 115.6 2002/12/01 17:52:34 rpotnuru noship $ */
--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name   : OKI_LOAD_FBO_PUB
-- Type       : Public
-- Purpose    : Load the oki_forecast_by_orgs table.
-- Modification History
-- 16-July-2001 Mezra         Created
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--
-- Notes      :
--
-- End of comments
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
  -- Procedure to create the forecast by organization records.
  -- The out parameters are listed first due to restrictions in concurrent
  -- manager.

--------------------------------------------------------------------------------
  PROCEDURE crt_fcst_org
  (   x_errbuf             OUT NOCOPY VARCHAR2
    , x_retcode            OUT NOCOPY VARCHAR2
    , p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  VARCHAR2
  ) ;


END oki_load_fbo_pub ;

 

/
