--------------------------------------------------------
--  DDL for Package Body PO_MASS_UPDATE_PO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_MASS_UPDATE_PO_GRP" AS
/* $Header: PO_Mass_Update_PO_GRP.plb 120.2 2008/01/09 14:30:58 rakchakr noship $*/

--------------------------------------------------------------------------------------------------

-- Call is made such that the sql file POXMUB.sql calls the procedure
-- PO_Mass_Update_PO_GRP.Update_Persons
-- PO_Mass_Update_PO_GRP.Update_Persons calls the procedure PO_Mass_Update_PO_PVT.DO_Update

--------------------------------------------------------------------------------------------------

g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;
g_pkg_name CONSTANT VARCHAR2(100) := 'PO_Mass_Update_PO_GRP';
g_log_head  CONSTANT VARCHAR2(100) := 'po.plsql.' || g_pkg_name || '.';

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Update_Persons
-- Type       : Group
-- Pre-reqs   : None
-- Function   : Calls the procedure PO_Mass_Update_PO_PVT.Do_Update to update the
--              Buyer/Approver/Deliver_To person accordingly to the input received
--	        from the Update_Person parameter value set.
-- Parameters :

-- IN         : p_update_person        Person needs to be updated.(Buyer/Approver/Deliver_To)
--              p_old_personid         Id of the old person
--		p_new_personid         Id of the new person
--		p_document_type        Type of the document(STANDARD,BLANKET.CONTRACT,PLANNED).
--		p_document_no_from     Document number from
--		p_document_no_to       Document number to
--		p_date_from            Date from
--		p_date_to              Date to
--		p_supplier_id          Supplier id
--		p_include_close_po     Include Close PO's or not (Value as Yes or No)
--		p_commit_interval      Commit interval

-- OUT        : p_msg_data             Actual message in encoded format
--		p_msg_count            Holds the number of messages in the API list
--		p_return_status        Return status of the API (Includes 'S','E','U')

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
                         p_return_status    OUT NOCOPY  VARCHAR2) IS

l_progress                 VARCHAR2(3);
l_log_head                 CONSTANT VARCHAR2(1000) := g_log_head||'Update_Persons';

BEGIN

l_progress  := '000';

IF g_debug_stmt THEN

	PO_DEBUG.debug_begin(l_log_head);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_update_person',p_update_person );
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_personid', p_old_personid);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_personid', p_new_personid);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_type',p_document_type );
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_no_from',p_document_no_from );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_from',p_date_from);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_to',p_date_to);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_supplier_id',p_supplier_id);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_include_close_po',p_include_close_po);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit_interval',p_commit_interval);

END IF;

SAVEPOINT Update_Persons_SP;

PO_Mass_Update_PO_PVT.DO_Update(p_update_person,
                                p_old_personid,
                                p_new_personid,
                                p_document_type,
                                p_document_no_from,
                                p_document_no_to,
                                p_date_from,
                                p_date_to,
                                p_supplier_id,
                                p_include_close_po,
				p_commit_interval,
				p_msg_data,
                                p_msg_count,
                                p_return_status);


l_progress  := '001';

IF g_debug_stmt THEN

	PO_DEBUG.debug_var(l_log_head,l_progress,'After Calling Do_Update', 'After Calling Do_Update');

END IF;

EXCEPTION

WHEN OTHERS THEN

	IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress||SQLCODE||SUBSTR(SQLERRM,1,200));

	END IF;

ROLLBACK TO Update_Persons_SP;

p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

END Update_Persons;

END PO_Mass_Update_PO_GRP;

/
