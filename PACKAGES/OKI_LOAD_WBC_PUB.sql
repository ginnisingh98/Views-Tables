--------------------------------------------------------
--  DDL for Package OKI_LOAD_WBC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_LOAD_WBC_PUB" AUTHID CURRENT_USER AS
/* $Header: OKIPWBCS.pls 115.6 2002/12/01 17:53:53 rpotnuru noship $ */

--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name   : OKI_LOAD_WBC_PUB
-- Type       : Public
-- Purpose    : Load the oki_wip_by_customers table.
-- Modification History
-- 16-July-2001 Mezra         Created
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--
-- Notes      :
--
-- End of comments
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
  -- Procedure to create the WIP by customer records.
  -- The out parameters are listed first due to restrictions in concurrent
  -- manager.

--------------------------------------------------------------------------------
  PROCEDURE crt_wip_by_cust
  (   x_errbuf             OUT NOCOPY VARCHAR2
    , x_retcode            OUT NOCOPY VARCHAR2
    , p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  VARCHAR2
  ) ;


END oki_load_wbc_pub ;

 

/
