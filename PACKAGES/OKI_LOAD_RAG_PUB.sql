--------------------------------------------------------
--  DDL for Package OKI_LOAD_RAG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_LOAD_RAG_PUB" AUTHID CURRENT_USER AS
/* $Header: OKIPRAGS.pls 115.4 2002/12/01 17:50:28 rpotnuru noship $ */

--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name   : OKI_LOAD_RAG_PUB
-- Type       : Public
-- Purpose    : Load the oki_renewal_aging table.
-- Modification History
-- 19-Sep-2001 Mezra         Created
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--
-- Notes      :
--
-- End of comments
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
  -- Procedure to create the renewal aging.
  -- The out parameters are listed first due to restrictions in concurrent
  -- manager.

--------------------------------------------------------------------------------
  PROCEDURE crt_rnwl_aging
  (   x_errbuf             OUT NOCOPY VARCHAR2
    , x_retcode            OUT NOCOPY VARCHAR2
    , p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  VARCHAR2
  ) ;

END oki_load_rag_pub ;

 

/
