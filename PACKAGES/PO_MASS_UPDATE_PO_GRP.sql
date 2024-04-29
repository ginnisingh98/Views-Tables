--------------------------------------------------------
--  DDL for Package PO_MASS_UPDATE_PO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_MASS_UPDATE_PO_GRP" AUTHID CURRENT_USER AS
/* $Header: PO_Mass_Update_PO_GRP.pls 120.2 2008/01/09 14:27:20 rakchakr noship $*/

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Update_Persons
-- Type       : Group
-- Pre-reqs   : None
-- Function   : Calls the procedure PO_Mass_Update_PO_PVT.Do_Update to update the
--              Buyer/Approver/Deliver_To person accordingly to the input received
--	        from the Update_Person parameter value set.
-- Parameters :

-- IN         : p_update_person        Person needs to be updated(Buyer/Approver/Deliver_To).
--              p_old_personid         Id of the old person.
--		p_new_personid         Id of the new person.
--		p_document_type        Type of the document(STANDARD,BLANKET.CONTRACT,PLANNED).
--		p_document_no_from     Document number from.
--		p_document_no_to       Document number to.
--		p_date_from            Date from.
--		p_date_to              Date to.
--		p_supplier_id          Supplier id.
--		p_include_close_po     Include Close PO's or not (Value as Yes or No).
--		p_commit_interval      Commit interval.

-- OUT        : p_msg_data             Actual message in encoded format.
--		p_msg_count            Holds the number of messages in the API list.
--		p_return_status        Return status of the API (Includes 'S','E','U').

-- End of Comments
--------------------------------------------------------------------------------------------------


PROCEDURE Update_Persons(p_update_person    IN VARCHAR2,
                         p_old_personid     IN NUMBER,
                         p_new_personid     IN NUMBER,
                         p_document_type    IN VARCHAR2,
                         p_document_no_from IN VARCHAR2,
                         p_document_no_to   IN VARCHAR2,
                         p_date_from        IN DATE,
                         p_date_to          IN DATE,
                         p_supplier_id      IN NUMBER,
                         p_include_close_po IN VARCHAR2,
			 p_commit_interval  IN NUMBER,
			 p_msg_data         OUT NOCOPY  VARCHAR2,
                         p_msg_count        OUT NOCOPY  NUMBER,
                         p_return_status    OUT NOCOPY  VARCHAR2);

END PO_Mass_Update_PO_GRP;

/
