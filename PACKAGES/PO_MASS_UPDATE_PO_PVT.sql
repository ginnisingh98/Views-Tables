--------------------------------------------------------
--  DDL for Package PO_MASS_UPDATE_PO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_MASS_UPDATE_PO_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_Mass_Update_PO_PVT.pls 120.3 2008/01/09 14:32:09 rakchakr noship $*/

-- Global variables to hold the Buyer_Info procedure Information

p_old_buyer_name        VARCHAR2(400);
p_old_username          VARCHAR2(400);
p_new_username          VARCHAR2(400);
p_org_name              VARCHAR2(100);
p_new_buyer_name        VARCHAR2(400);
p_supplier_name         VARCHAR2(400);
p_inc_close_po          VARCHAR2(100);
p_new_user_display_name VARCHAR2(400);
p_old_user_display_name VARCHAR2(400);
p_old_buyer_user_id     NUMBER;
p_new_buyer_user_id     NUMBER;

-- Global variables to hold the  concurrent program parameter values.

g_old_personid     NUMBER;
g_document_type    VARCHAR2(200);
g_document_no_from VARCHAR2(200);
g_document_no_to   VARCHAR2(200);
g_date_from        DATE;
g_date_to          DATE;
g_supplier_id      NUMBER;
g_old_username     VARCHAR2(200);

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Do_Update
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Calls the procedure Update_Buyer/Update_Approver/Update_Deliver_To
--              or All of the above to update the Buyer/Approver/Deliver_To person
--              accordingly to the input received from the Update_Person parameter value set.
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


PROCEDURE DO_Update(p_update_person    IN VARCHAR2,
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

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Update_Buyer
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Updates the old buyer with the new buyer provided and also updates the
--		worklfow attributes when the PO and release are in Inprocess and
--		Pre-approved status.

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

PROCEDURE Update_Buyer(p_update_person    IN VARCHAR2,
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

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Update_Approver
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Updates the old approver with the new approver provided and also forwards
--		the notification from old approver to new approver in case of In process
--		and Pre-approved PO's and releases.

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

PROCEDURE Update_Approver(p_update_person    IN VARCHAR2,
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

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Update_Deliver_To
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Updates the old deliver to person with the new deliver to person provided.

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

PROCEDURE Update_Deliver_To(p_update_person    IN VARCHAR2,
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

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Print_Output
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Prints the header and body of the output file showing the documents and
--		document types updated along with the person who have been updated in the
--		document.

-- Parameters :

-- IN         : p_update_person        Person needs to be updated(Buyer/Approver/Deliver_To).
--              p_old_buyer_name       Buyer name of the old person.
--		p_new_buyer_name       Buyer name of the new person.
--              p_org_name             Operating unit name.
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

PROCEDURE Print_Output(p_update_person    IN VARCHAR2,
		       p_old_buyer_name   IN VARCHAR2,
                       p_new_buyer_name   IN VARCHAR2,
                       p_org_name         IN VARCHAR2,
                       p_document_type    IN VARCHAR2,
                       p_document_no_from IN VARCHAR2,
                       p_document_no_to   IN VARCHAR2,
                       p_date_from        IN DATE,
                       p_date_to          IN DATE,
                       p_supplier_name    IN VARCHAR2,
		       p_msg_data         OUT NOCOPY  VARCHAR2,
                       p_msg_count        OUT NOCOPY  NUMBER,
                       p_return_status    OUT NOCOPY  VARCHAR2);

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Buyer_Info
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Gets the Buyer Information.

-- Parameters :

-- IN         : p_old_personid			Id of the old person.
--		p_new_personid			Id of the new person.
--		p_supplier_id			Supplier id.

-- OUT        : p_old_buyer_name		Buyer name of the old person.
--		p_new_buyer_name		Buyer name of the new person.
--		p_old_username			User name of the old person.
--		p_new_username			User name of the new person.
--		p_new_user_display_name		Display name of the new person.
--		p_old_buyer_user_id		Old person's Buyer user id.
--		p_new_buyer_user_id		New person's Buyer user id.
--		p_supplier_name			Supplier name.
--		p_org_name			Operating unit name.
--		p_msg_data			Actual message in encoded format.
--		p_msg_count			Holds the number of messages in the API list.
--		p_return_status			Return status of the API (Includes 'S','E','U').

-- End of Comments
--------------------------------------------------------------------------------------------------

PROCEDURE Buyer_Info(p_old_personid          IN NUMBER,
                     p_new_personid          IN NUMBER,
		     p_supplier_id           IN NUMBER,
                     p_old_buyer_name        OUT NOCOPY VARCHAR2,
                     p_new_buyer_name        OUT NOCOPY VARCHAR2,
                     p_old_username          OUT NOCOPY VARCHAR2,
                     p_new_username          OUT NOCOPY VARCHAR2,
                     p_new_user_display_name OUT NOCOPY VARCHAR2,
                     p_old_buyer_user_id     OUT NOCOPY NUMBER,
                     p_new_buyer_user_id     OUT NOCOPY NUMBER,
                     p_supplier_name         OUT NOCOPY VARCHAR2,
                     p_org_name              OUT NOCOPY VARCHAR2,
		     p_msg_data              OUT NOCOPY VARCHAR2,
                     p_msg_count             OUT NOCOPY NUMBER,
                     p_return_status         OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------------------------------

-- Functions declared to return the value of the parameters passed in this API.

--------------------------------------------------------------------------------------------------

FUNCTION get_old_personid RETURN NUMBER;

FUNCTION get_document_type RETURN VARCHAR2;

FUNCTION get_document_no_from RETURN VARCHAR2;

FUNCTION get_document_no_to RETURN VARCHAR2;

FUNCTION get_date_from RETURN DATE;

FUNCTION get_date_to RETURN DATE;

FUNCTION get_supplier_id RETURN NUMBER;

FUNCTION get_old_username RETURN VARCHAR2;


END PO_Mass_Update_PO_PVT;

/
