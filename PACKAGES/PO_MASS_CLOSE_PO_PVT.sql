--------------------------------------------------------
--  DDL for Package PO_MASS_CLOSE_PO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_MASS_CLOSE_PO_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_Mass_Close_PO_PVT.pls 120.3 2008/01/09 14:39:14 rakchakr noship $*/

p_org_name          hr_all_organization_units.name%TYPE;
p_supplier_name     VARCHAR2(1000);

-- Global variables to hold the  concurrent program parameter values.

g_document_type    VARCHAR2(200);
g_document_no_from VARCHAR2(200);
g_document_no_to   VARCHAR2(200);
g_date_from        DATE;
g_date_to          DATE;
g_supplier_id      NUMBER;

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : po_close_documents.
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Calls the procedure po_actions.close_po to close the PO's and releases.

-- Parameters :

-- IN         : p_document_type        Type of the document(STANDARD,BLANKET.CONTRACT,PLANNED).
--		p_document_no_from     Document number from.
--		p_document_no_to       Document number to.
--		p_date_from            Date from.
--		p_date_to              Date to.
--		p_supplier_id          Supplier id.
--		p_commit_interval      Commit interval.

-- OUT        : p_msg_data             Actual message in encoded format.
--		p_msg_count            Holds the number of messages in the API list.
--		p_return_status        Return status of the API (Includes 'S','E','U').

-- End of Comments
--------------------------------------------------------------------------------------------------

PROCEDURE po_close_documents(p_document_type      IN VARCHAR2,
                             p_document_no_from   IN VARCHAR2,
                             p_document_no_to     IN VARCHAR2,
                             p_date_from          IN VARCHAR2,
                             p_date_to            IN VARCHAR2,
                             p_supplier_id        IN NUMBER,
			     p_commit_interval    IN NUMBER,
			     p_msg_data           OUT NOCOPY  VARCHAR2,
                             p_msg_count          OUT NOCOPY  NUMBER,
                             p_return_status      OUT NOCOPY  VARCHAR2);

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Print_Output
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Prints the header and body of the output file showing the documents and
--		document types which are closed.

-- Parameters :

-- IN         : p_org_name             Operating unit name.
--		p_document_type        Type of the document(STANDARD,BLANKET.CONTRACT,PLANNED).
--		p_document_no_from     Document number from.
--		p_document_no_to       Document number to.
--		p_date_from            Date from.
--		p_date_to              Date to.
--		p_supplier_name        Supplier name.

-- OUT        : p_msg_data             Actual message in encoded format.
--		p_msg_count            Holds the number of messages in the API list.
--		p_return_status        Return status of the API (Includes 'S','E','U').

-- End of Comments
--------------------------------------------------------------------------------------------------

PROCEDURE Print_Output(p_org_name           IN VARCHAR2,
                       p_document_type      IN VARCHAR2,
                       p_document_no_from   IN VARCHAR2,
                       p_document_no_to     IN VARCHAR2,
                       p_date_from          IN DATE,
                       p_date_to            IN DATE,
		       p_supplier_name      IN VARCHAR2,
		       p_msg_data           OUT NOCOPY  VARCHAR2,
                       p_msg_count          OUT NOCOPY  NUMBER,
                       p_return_status      OUT NOCOPY  VARCHAR2);

--------------------------------------------------------------------------------------------------

-- Functions declared to return the value of the parameters passed in this API.

--------------------------------------------------------------------------------------------------

FUNCTION get_document_type RETURN VARCHAR2;

FUNCTION get_document_no_from RETURN VARCHAR2;

FUNCTION get_document_no_to RETURN VARCHAR2;

FUNCTION get_date_from RETURN DATE;

FUNCTION get_date_to RETURN DATE;

FUNCTION get_supplier_id RETURN NUMBER;

END PO_Mass_Close_PO_PVT;

/
