--------------------------------------------------------
--  DDL for Package PON_MASS_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_MASS_UPDATE_PVT" AUTHID CURRENT_USER as
/* $Header: PON_MASS_UPDATE_PVT.pls 120.0.12010000.3 2013/08/30 09:05:57 nrayi noship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) :=
  NVL (FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- other
g_pkg_name CONSTANT VARCHAR2(30) := 'PON_MASS_UPDATE_PVT';
g_module_prefix CONSTANT VARCHAR2(50) := 'pon.plsql.'||g_pkg_name||'.';
TYPE g_pon_buyer IS REF CURSOR;

-- Global variables to hold the  concurrent program parameter values.

g_old_personid     NUMBER;
g_document_type    VARCHAR2(200);
g_document_no_from NUMBER;
g_document_no_to   NUMBER;
g_date_from        DATE;
g_date_to          DATE;
g_supplier_id      NUMBER;
g_old_username     VARCHAR2(200);

TYPE g_auc IS REF CURSOR;
--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : pon_update_buyer
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Calls the procedure to update the Buyer person
--              accordingly to the input received.
-- Parameters :

-- IN         : p_old_buyer_id         Id of the old person.
--		p_new_buyer_id         Id of the new person.
--		p_doc_no_from          Document number from.
--		p_doc_no_to            Document number to.
--	 	p_date_from            Date from.
--		p_date_to              Date to.
--		p_commit_intrl         Commit interval.
--		p_simulate             Simulate.

-- OUT        : EFFBUF             Actual message in encoded format.
--		RETCODE        Return status of the API .

-- End of Comments
--------------------------------------------------------------------------------------------------


PROCEDURE pon_update_buyer(EFFBUF           OUT NOCOPY VARCHAR2,
                           RETCODE           OUT NOCOPY VARCHAR2,
                           p_old_buyer_id     IN number,
                          p_new_buyer_id     IN NUMBER,
                          p_doc_no_from      IN NUMBER,
                          p_doc_no_to        IN NUMBER,
                          p_date_from        IN VARCHAR2,
                          p_date_to          IN VARCHAR2,
                          p_commit_intrl     IN NUMBER,
                          p_simulate         IN VARCHAR2
                          );


FUNCTION get_old_person_id RETURN NUMBER;
FUNCTION get_document_no_from RETURN NUMBER;

FUNCTION get_document_no_to RETURN NUMBER;

FUNCTION get_date_from RETURN DATE;

FUNCTION get_date_to RETURN DATE;

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Print_Output
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Prints the header and body of the output file showing the documents
--		          updated along with the person who have been updated in the
--		          document.

-- Parameters :

-- IN         : p_old_buyer_name       Buyer name of the old person.
--		p_new_buyer_name       Buyer name of the new person.
--              p_document_no_from     Document number from.
--		p_document_no_to       Document number to.
--		p_date_from            Date from.
--		p_date_to              Date to.
--		p_commit_intrl         Commit interval.
--		p_simulate             Simulate.


--
-- OUT        : p_msg_data             Actual message in encoded format.
--		p_msg_count            Holds the number of messages in the API list.
--		p_return_status        Return status of the API (Includes 'S','E','U').

-- End of Comments
--------------------------------------------------------------------------------------------------

PROCEDURE Print_Output(p_old_buyer_name   IN VARCHAR2,
                       p_new_buyer_name   IN VARCHAR2,
                       p_document_no_from IN VARCHAR2,
                       p_document_no_to   IN VARCHAR2,
                       p_date_from        IN DATE,
                       p_date_to          IN DATE,
                       p_commit_intrl     IN NUMBER,
                       p_simulate         IN VARCHAR2,
                       p_msg_data         OUT NOCOPY  VARCHAR2,
                       p_msg_count        OUT NOCOPY  NUMBER,
                       p_return_status    OUT NOCOPY  VARCHAR2);


-----------------------------------------------------------------------
--Start of Comments
--Name:  print_log
--Description  : Helper procedure for logging
--Pre-reqs:
--Parameters:
--IN:  p_message
--     p_header
--     p_process
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE print_log
  (
    p_log_head IN VARCHAR2,
    p_process IN VARCHAR2,
    p_message IN VARCHAR2
     );

END PON_MASS_UPDATE_PVT;

/
