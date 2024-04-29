--------------------------------------------------------
--  DDL for Package OKI_LOAD_RBK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_LOAD_RBK_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRRBKS.pls 115.4 2002/12/01 17:53:22 rpotnuru noship $ */
--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name   : OKI_LOAD_RBK_PUB
-- Type       : Process
-- Purpose    : Load the oki_rnwl_bookings table
-- Modification History
-- 26-DEC-2001 mezra         Initial version
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
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
-- Procedure to create the sequential growth rate records.

--------------------------------------------------------------------------------
  PROCEDURE crt_rnwl_bkng
  (   p_start_summary_build_date IN  DATE
    , p_end_summary_build_date   IN  DATE
    , x_errbuf                   OUT NOCOPY VARCHAR2
    , x_retcode                  OUT NOCOPY VARCHAR2
  ) ;


END oki_load_rbk_pvt ;

 

/
