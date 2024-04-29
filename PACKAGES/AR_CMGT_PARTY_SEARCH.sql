--------------------------------------------------------
--  DDL for Package AR_CMGT_PARTY_SEARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_PARTY_SEARCH" AUTHID CURRENT_USER AS
/*$Header: ARDQMSRS.pls 120.6 2006/03/17 12:31:47 kjoshi noship $ */

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
 | 06-AUG-2002           APANDIT            Created
 | 12-MAY-2004           BSARKAR            Added 3 out parameter
 *=======================================================================*/
PROCEDURE DQM_SEARCH(  p_keyword IN  VARCHAR2,
                       p_dqm_param    IN  VARCHAR2,
                       p_search_context_id OUT NOCOPY NUMBER,
		       p_return_status	   OUT NOCOPY VARCHAR2,
		       p_msg_count	   OUT NOCOPY NUMBER,
		       p_msg_data	   OUT NOCOPY VARCHAR2);

END AR_CMGT_PARTY_SEARCH;

 

/
