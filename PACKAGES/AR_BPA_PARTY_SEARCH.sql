--------------------------------------------------------
--  DDL for Package AR_BPA_PARTY_SEARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BPA_PARTY_SEARCH" AUTHID CURRENT_USER AS
/*$Header: ARBPDQMS.pls 120.1 2004/12/03 01:45:03 orashid noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

/*========================================================================
 | PUBLIC PROCEDURE DQM_SEARCH
 |
 | DESCRIPTION
 |      This procedure provides the cover routine for the call to the
 |      DQM search engine.
 |     This is used from the credit management search pages.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_keyword             IN      The keyword on which search is to
 |                                    be performed.
 |      p_search_context_id   OUT NOCOPY     The unique id returned by DQM
 |
 | KNOWN ISSUES
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-Jan-2003           LISHAO            Created
 |
 *=======================================================================*/
PROCEDURE DQM_SEARCH(  p_keyword IN  VARCHAR2,
                       p_search_context_id OUT NOCOPY NUMBER);

END AR_BPA_PARTY_SEARCH;

 

/
