--------------------------------------------------------
--  DDL for Package OKI_LOAD_RAG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_LOAD_RAG_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRRAGS.pls 115.4 2002/12/01 17:52:23 rpotnuru noship $ */
--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name   : OKI_LOAD_RAG_PVT
-- Type       : Process
-- Purpose    : Load the oki_rnwl_aging table
-- Modification History
-- 19-September-2001 Mezra         Created
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--
-- Notes      :
--              The following is an overview of the program
--              For each distinct customer, organization and subclass code
--                  in OKI_SALES_K_HDRS
--                For valid period from GL_PERIODS
--                  Calculate the aging bucket range for each bucket
--                  Calculate the forecast amount
--                  Determine if the record should be inserted or updated
--              For each distinct customer and organization
--                  in OKI_SALES_K_HDRS
--                For valid period from GL_PERIODS
--                  Calculate the forecast amounts
--                  Determine if the record should be inserted or updated
--              For each distinct organization in OKI_SALES_K_HDRS
--                For valid period from GL_PERIODS
--                  Calculate the forecast amounts
--                  Determine if the record should be inserted or updated
--              Update OKI_REFRESHS table with concurrent manager statistics
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
-- Procedure to create the forecast renewal aging records.

--------------------------------------------------------------------------------
  PROCEDURE crt_rnwl_aging
  (   p_period_set_name    IN  VARCHAR2
    , p_period_type        IN  VARCHAR2
    , p_summary_build_date IN  DATE
    , x_errbuf             OUT NOCOPY VARCHAR2
    , x_retcode            OUT NOCOPY VARCHAR2
  ) ;


END oki_load_rag_pvt ;

 

/
