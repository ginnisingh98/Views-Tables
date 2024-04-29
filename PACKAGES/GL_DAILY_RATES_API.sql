--------------------------------------------------------
--  DDL for Package GL_DAILY_RATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_DAILY_RATES_API" AUTHID CURRENT_USER AS
/* $Header: gludlras.pls 120.1 2005/05/05 01:37:38 kvora noship $ */

   run_conc_req_flag  BOOLEAN := TRUE;


      FUNCTION SUBMIT_CONC_REQUEST RETURN NUMBER;


END Gl_Daily_Rates_API;

 

/
