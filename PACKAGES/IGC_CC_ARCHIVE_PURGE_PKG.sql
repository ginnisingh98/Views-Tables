--------------------------------------------------------
--  DDL for Package IGC_CC_ARCHIVE_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_ARCHIVE_PURGE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCCAPRS.pls 120.3.12000000.4 2007/10/08 05:59:47 smannava ship $ */

/* ------------------------------------------------------------------------- */
/*                                                                           */
/*  Archive Purge API for CC whenever there is a request to purge off the    */
/*  Periods that are closed for a fiscal year.                               */
/*  Funds Reservation need to be performed.                                  */
/*                                                                           */
/*  This routine returns SUCCESS or FAILURE.                                 */
/*                                                                           */
/*  In case of failure, this routine will populate the global Message Stack  */
/*  using FND_MESSAGE. The calling routine will retrieve the message from    */
/*  the Stack                                                                */
/*                                                                           */
/*  External Packages which are being invoked include :                      */
/*                                                                           */
/*            FND_MSG_PUB.Check_Msg_Level                                    */
/*            FND_MSG_PUB.Add_Exc_Msg                                        */
/*                                                                           */
/*  PO Tables which are being used include :                                 */
/*                                                                           */
/*            PO_HEADERS_ALL                                                 */
/*            PO_LINES_ALL                                                   */
/*            PO_DISTRIBUTIONS_ALL                                           */
/*            PO_LINE_LOCATIONS_ALL                                          */
/*                                                                           */
/*  IGC Tables which are being used include :                                */
/*                                                                           */
/*            IGC_CC_ACTIONS                                                 */
/*            IGC_CC_HEADERS                                                 */
/*            IGC_CC_HEADER_HISTORY                                          */
/*            IGC_CC_ACCT_LINES                                              */
/*            IGC_CC_ACCT_LINE_HISTORY                                       */
/*            IGC_CC_DET_PF                                                  */
/*            IGC_CC_DET_PF_HISTORY                                          */
/*            IGC_CC_MC_HEADERS                                              */
/*            IGC_CC_MC_HEADER_HISTORY                                       */
/*            IGC_CC_MC_ACCT_LINES                                           */
/*            IGC_CC_MC_ACCT_LINE_HISTORY                                    */
/*            IGC_CC_MC_DET_PF                                               */
/*            IGC_CC_MC_DET_PF_HISTORY                                       */
/*            IGC_CC_ARCHIVE_HISTORY                                         */
/*            IGC_CC_ARC_ACTIONS                                             */
/*            IGC_CC_ARC_HEADERS                                             */
/*            IGC_CC_ARC_HEADER_HIST                                         */
/*            IGC_CC_ARC_ACCT_LINES                                          */
/*            IGC_CC_ARC_ACCT_LINE_HIST                                      */
/*            IGC_CC_ARC_DET_PF                                              */
/*            IGC_CC_ARC_DET_PF_HIST                                         */
/*            IGC_CC_ARC_MC_HEADERS                                          */
/*            IGC_CC_ARC_MC_HEADER_HIST                                      */
/*            IGC_CC_ARC_MC_ACCT_LINES                                       */
/*            IGC_CC_ARC_MC_ACCT_LINE_HIST                                   */
/*            IGC_CC_ARC_MC_DET_PF                                           */
/*            IGC_CC_ARC_MC_DET_PF_HIST                                      */
/*                                                                           */
/* ------------------------------------------------------------------------- */

--
-- Main Procedure for Archiving and Purging the CBC tables
--
-- Parameters :
--
-- errbuf                   ==> Error msg buffer returned
-- retcode                  ==> Return status code.
-- p_req_last_activity_date ==> last date record activity took place
-- p_req_mode               ==> Archive ("AR"), Pre-Purge ("PP"), Purge ("PU")
-- p_req_commit_work        ==> Boolean indicating if this process should commit work or not
--

PROCEDURE Archive_Purge_CC_Request
(
   errbuf                    OUT NOCOPY VARCHAR2,
   retcode                   OUT NOCOPY NUMBER,
   p_req_mode                 IN VARCHAR2,
   p_req_last_activity_date   IN VARCHAR2
);


--
-- Function designed to return the current global value for the SET_OF_BOOKS_ID
-- in the package as being run
--
-- Parameters :
--
--     None
--

FUNCTION Get_SOB_ID RETURN NUMBER;


--
-- Function designed to return the current global value for the ORG_ID
-- in the package as being run
--
-- Parameters :
--
--     None
--

FUNCTION Get_ORG_ID RETURN NUMBER;


--
-- Function designed to return the current global value for the LAST_ACTIVITY_DATE
-- that the user input for the package to be run with
--
-- Parameters :
--
--     None
--

FUNCTION Get_Last_Activity_Date RETURN DATE;

END IGC_CC_ARCHIVE_PURGE_PKG;


 

/
