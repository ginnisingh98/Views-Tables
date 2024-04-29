--------------------------------------------------------
--  DDL for Package OKI_LOAD_YRA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_LOAD_YRA_PUB" AUTHID CURRENT_USER AS
/* $Header: OKIPYRAS.pls 115.4 2002/12/01 17:50:56 rpotnuru noship $ */

--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name   : OKI_LOAD_YRA_PUB
-- Type       : Public
-- Purpose    : Load the oki_yoy_renewal_amt table.
-- Modification History
-- 19-Sep-2001 Mezra         Created
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--
-- Notes      :
--
-- End of comments
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
  -- Procedure to create the yoy renewal amount.
  -- The out parameters are listed first due to restrictions in concurrent
  -- manager.

--------------------------------------------------------------------------------
  PROCEDURE crt_yoy_rnwl
  (   x_errbuf             OUT NOCOPY VARCHAR2
    , x_retcode            OUT NOCOPY VARCHAR2
    , p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  VARCHAR2
  ) ;

END oki_load_yra_pub ;

 

/
