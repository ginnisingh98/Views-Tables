--------------------------------------------------------
--  DDL for Package OKI_LOAD_SGR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_LOAD_SGR_PUB" AUTHID CURRENT_USER AS
/* $Header: OKIPSGRS.pls 115.3 2002/06/06 11:34:38 pkm ship        $ */

--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name   : OKI_LOAD_SGR_PUB
-- Type       : Public
-- Purpose    : Load the oki_seq_growth_rate table.
-- Modification History
-- 10-Oct-2001 Mezra         Initial version
--
-- Notes      :
--
-- End of comments
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
  -- Procedure to create the sequential growth rate.
  -- The out parameters are listed first due to restrictions in concurrent
  -- manager.

--------------------------------------------------------------------------------
  PROCEDURE crt_seq_grw
  (   x_errbuf                    OUT VARCHAR2
    , x_retcode                   OUT VARCHAR2
    , p_period_set_name           IN  VARCHAR2
    , p_period_type               IN  VARCHAR2
    , p_start_summary_build_date  IN  VARCHAR2
    , p_end_summary_build_date    IN  VARCHAR2
  ) ;

END oki_load_sgr_pub ;

 

/
