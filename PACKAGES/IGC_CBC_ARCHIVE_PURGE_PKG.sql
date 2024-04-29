--------------------------------------------------------
--  DDL for Package IGC_CBC_ARCHIVE_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CBC_ARCHIVE_PURGE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCBAPRS.pls 120.3.12000000.3 2007/10/13 09:44:01 dvjoshi ship $ */

/* ------------------------------------------------------------------------- */
/*                                                                           */
/*  Archive Purge API for CBC whenever there is a request to purge off the   */
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
/*  GL Tables which are being used include :                                 */
/*                                                                           */
/*            GL_PERIOD_STATUSES                                             */
/*                                                                           */
/*  IGC Tables which are being used include :                                */
/*                                                                           */
/*            IGC_CBC_MC_ARCHIVE_JE_LINES                                    */
/*            IGC_CBC_MC_ARCHIVE_JE_BATCHES                                  */
/*            IGC_CBC_ARCHIVE_JE_LINES                                       */
/*            IGC_CBC_ARCHIVE_JE_BATCHES                                     */
/*            IGC_CBC_ARCHIVE_HISTORY                                        */
/*            IGC_CBC_JE_LINES                                               */
/*            IGC_CBC_JE_BATCHES                                             */
/*            IGC_CBC_MC_JE_LINES                                            */
/*            IGC_CBC_MC_JE_BATCHES                                          */
/*                                                                           */
/* ------------------------------------------------------------------------- */

--
-- Main Procedure for Archiving and Purging the CBC tables
--
-- Parameters :
--
-- errbuf              ==> Error Buffer for Concurrent Request.
-- retcode             ==> Return Code for the Concurrent Request.
-- p_mode              ==> P = Purge A = Archive B = Both
-- p_fiscal_year       ==> Fiscal year data that is to be archievd/purged.
-- p_commit_work       ==> Boolean indicating if this process should commit work or not
--

END IGC_CBC_ARCHIVE_PURGE_PKG;


 

/
