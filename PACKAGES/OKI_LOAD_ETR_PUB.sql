--------------------------------------------------------
--  DDL for Package OKI_LOAD_ETR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_LOAD_ETR_PUB" AUTHID CURRENT_USER AS
/* $Header: OKIPETRS.pls 115.3 2002/12/01 17:51:41 rpotnuru noship $ */

--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name   : OKI_LOAD_ETR_PUB
-- Type       : Public
-- Purpose    : Load the oki_exp_to_rnwl table.
-- Modification History
-- 26-DEC-2001 Mezra        Initial version
-- 30-APR-2002 mezra        Added dbdrv and set verify command.
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--
-- Notes      :
--
-- End of comments
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
  -- Procedure to create the expiration to renewal records.
  -- The out parameters are listed first due to restrictions in concurrent
  -- manager.

--------------------------------------------------------------------------------
  PROCEDURE crt_exp_to_rnwl
  (   x_errbuf                    OUT NOCOPY VARCHAR2
    , x_retcode                   OUT NOCOPY VARCHAR2
    , p_start_summary_build_date  IN  VARCHAR2
    , p_end_summary_build_date    IN  VARCHAR2
  ) ;

END oki_load_etr_pub ;

 

/
