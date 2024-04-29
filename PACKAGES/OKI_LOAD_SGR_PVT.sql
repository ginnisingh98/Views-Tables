--------------------------------------------------------
--  DDL for Package OKI_LOAD_SGR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_LOAD_SGR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRSGRS.pls 115.3 2002/06/06 11:35:22 pkm ship        $ */
--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name   : OKI_LOAD_SGR_PVT
-- Type       : Process
-- Purpose    : Load the oki_seq_growth_rate table
-- Modification History
-- 10-Oct-2001 mezra         Initial version
--
-- Notes      :
--              The following is an overview of the program
--              For each distinct customer in OKI_SALES_K_HDRS
--                For valid period from GL_PERIODS
--                  Calculate the following:
--                    1.  Current / previous beginning active contract
--                        amount
--                    2.  Current / previous expiring during quarter contract
--                        amount
--                    3.  Current / previous quarter contract renewed
--                        amount
--                    4.  Current / previous backlog contract renewed
--                        amount
--                    5.  Current / previous new business contract
--                        amount
--                    6.  Current / previous cancelled renewal contract
--                        amount
--                    7.  Current / previous terminated contract
--                        amount (lost)
--                    8.  Current / previous ending active contract
--                        amount
--                    9.  Current / previous sequential growth rate
--                  Determine if each of the above should be inserted or updated
--              For each distinct organization in OKI_SALES_K_HDRS
--                For valid period from GL_PERIODS
--                  Repeat steps 1 - 9 above.
--                  Determine if each of the above should be inserted or updated
--              For each summary build date
--                  Repeat steps 1 - 9 above.
--                  Determine if each of the above should be inserted or updated
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
-- Procedure to create the sequential growth rate records.

--------------------------------------------------------------------------------
  PROCEDURE crt_seq_grw
  (   p_period_set_name          IN  VARCHAR2
    , p_period_type              IN  VARCHAR2
    , p_start_summary_build_date IN  DATE     DEFAULT SYSDATE
    , p_end_summary_build_date   IN  DATE     DEFAULT SYSDATE
    , x_errbuf                   OUT VARCHAR2
    , x_retcode                  OUT VARCHAR2
  ) ;


END oki_load_sgr_pvt ;

 

/
