--------------------------------------------------------
--  DDL for Package IGC_CBC_PO_YEAR_END_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CBC_PO_YEAR_END_PKG" AUTHID CURRENT_USER AS
/*$Header: IGCPOYES.pls 120.1.12000000.5 2007/10/24 08:48:41 bmaddine ship $*/


--  Procedure Year_End_Main
--  =======================
--
--  This is the main procedure of the PO/CBC Year End Process.
--  This process, to be run at Year End, carries forward encumbrances to the next fiscal year.
--  Encumbrances are carried forward in both the Standard and Commitment Budgets at a transactional
--  level for Requisitions, whilst encumbrances for PO's are carried forward only in the Standard
--  Budget.  Funds reservation in the Standard Budget is carried out in Forced Mode.
--
--  IN Parameters
--  -------------
--  p_sob_id             Set of Books Id
--  p_org_id             Org Id
--  p_process_phase      User entered processing phase: F - Final, P - Preliminary
--  p_year               User entered Year being closed
--  p_process_frozen     User entered choice whether to process Frozen documents: Y or N
--  p_trunc_exception    User entered choice to truncate the exception table: Y or N
--  p_batch_size         User entered value used to determine batch size of bulk fetches
--
--  OUT Parameters
--  --------------
--  errbuf               Standard Concurrent Processing Error Buffer
--  retcode              Standard Concurrent Processing Return Code
--
--
PROCEDURE  Year_End_Main(errbuf            OUT NOCOPY VARCHAR2,
                         retcode           OUT NOCOPY VARCHAR2,
/* Bug No : 6341012. MOAC uptake. SOB_ID, ORG_ID are no more retrieved from profile values in R12 */
--                         p_sobid           IN NUMBER,
--                         p_org_id          IN NUMBER,
                         p_process_phase   IN VARCHAR2,
                         p_year            IN NUMBER,
                         p_process_frozen  IN VARCHAR2,
                         p_trunc_exception IN VARCHAR2,
                         p_batch_size      IN NUMBER
                         ) ;


END IGC_CBC_PO_YEAR_END_PKG;

 

/
