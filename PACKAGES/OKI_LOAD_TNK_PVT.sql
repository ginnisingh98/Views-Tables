--------------------------------------------------------
--  DDL for Package OKI_LOAD_TNK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_LOAD_TNK_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRTNKS.pls 115.2 2002/07/12 01:16:25 rpotnuru noship $ */
--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name   : OKI_LOAD_TNK_PVT
-- Type       : Process
-- Purpose    : Load the oki_top_n_contracts table.
-- Modification History
-- 10-Apr-2002  mezra         Initial version.
--                            Create stub in order to branch.
--
-- Notes      :
--
-- End of comments
--------------------------------------------------------------------------------

  -- Global variable declaration

  -- variables to log this job run from concurrent manager
  g_request_id               oki.oki_refreshs.request_id%TYPE;
  g_program_application_id   oki.oki_refreshs.PROGRAM_APPLICATION_ID%TYPE;
  g_program_id               oki.oki_refreshs.PROGRAM_ID%TYPE;
  g_program_update_date      oki.oki_refreshs.PROGRAM_UPDATE_DATE%TYPE;

--------------------------------------------------------------------------------
-- Procedure to create top n contract records.
--
--------------------------------------------------------------------------------
  PROCEDURE crt_top_n_k
  (   p_start_summary_build_date IN  DATE     DEFAULT SYSDATE
    , p_end_summary_build_date   IN  DATE     DEFAULT SYSDATE
    , x_errbuf                   OUT VARCHAR2
    , x_retcode                  OUT VARCHAR2
  ) ;


END oki_load_tnk_pvt ;

 

/
