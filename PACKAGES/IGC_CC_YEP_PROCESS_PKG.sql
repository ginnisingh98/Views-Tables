--------------------------------------------------------
--  DDL for Package IGC_CC_YEP_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_YEP_PROCESS_PKG" AUTHID CURRENT_USER as
/* $Header: IGCCYEPS.pls 120.3.12000000.3 2007/10/18 12:23:15 bmaddine ship $  */



/*==================================================================================
                             Procedure YEAR_END_MAIN
  =================================================================================*/


PROCEDURE YEAR_END_MAIN (  errbuf                OUT NOCOPY  VARCHAR2,
                           retcode               OUT NOCOPY  VARCHAR2,
/* Bug No : 6341012. MOAC uptake. ORG_ID,SOB_ID are retrieved from packages rather than from Profile values */
--                           p_SOB_ID              IN   NUMBER,
--                           p_ORG_ID              IN   NUMBER,
                           p_PROCESS_PHASE       IN   VARCHAR2,
                           p_YEAR                IN   NUMBER);



END IGC_CC_YEP_PROCESS_PKG;
 

/
