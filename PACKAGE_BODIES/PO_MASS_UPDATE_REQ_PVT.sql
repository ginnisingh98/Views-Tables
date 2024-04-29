--------------------------------------------------------
--  DDL for Package Body PO_MASS_UPDATE_REQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_MASS_UPDATE_REQ_PVT" AS
/* $Header: PO_Mass_Update_Req_PVT.plb 120.7.12010000.8 2014/07/01 04:13:46 rkandima ship $*/

--------------------------------------------------------------------------------------------------

-- Call is made such that the sql file POXMUR.sql calls the procedure
-- PO_Mass_Update_Req_GRP.Update_Persons
-- PO_Mass_Update_Req_GRP.Update_Persons calls the procedure PO_Mass_Update_Req_PVT.DO_Update

--------------------------------------------------------------------------------------------------

g_debug_stmt                 CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp                CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;
g_pkg_name                   CONSTANT VARCHAR2(100) := 'PO_Mass_Update_Req_PVT';
g_log_head                   CONSTANT VARCHAR2(1000) := 'po.plsql.' || g_pkg_name || '.';

TYPE g_req IS REF CURSOR;

TYPE g_req_approver is REF CURSOR;

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Do_Update
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Calls the procedure Update_Preparer/Update_Approver/Update_Requestor
--              or All of the above to update the Preparer/Approver/Requestor
--              accordingly to the input received from the Update_Person parameter value set.
-- Parameters :

-- IN         : p_update_person        Person needs to be updated(Preparer/Approver/Requestor).
--              p_old_personid         Id of the old person.
--		p_new_personid         Id of the new person.
--		p_document_type        Type of the document(INTERNAL AND PURCHASE).
--		p_document_no_from     Document number from.
--		p_document_no_to       Document number to.
--		p_date_from            Date from.
--		p_date_to              Date to.
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
		    p_commit_interval  IN NUMBER,
		    p_msg_data         OUT NOCOPY  VARCHAR2,
                    p_msg_count        OUT NOCOPY  NUMBER,
                    p_return_status    OUT NOCOPY  VARCHAR2) IS

l_progress          VARCHAR2(3) := '000';
l_log_head          CONSTANT VARCHAR2(1000) := g_log_head||'Do_Update';
l_return_status     VARCHAR2(1);

BEGIN

IF g_debug_stmt THEN

	PO_DEBUG.debug_begin(l_log_head);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_update_person',p_update_person );
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_personid', p_old_personid);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_personid', p_new_personid);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_type',p_document_type );
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_no_from',p_document_no_from );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_from',p_date_from);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_to',p_date_to);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit_interval',p_commit_interval);

END IF;

SAVEPOINT Do_Update_SP;

l_progress := '001';

	IF (p_update_person = 'PREPARER' OR p_update_person = 'ALL') THEN

		BEGIN

			l_progress := '002';

			IF g_debug_stmt THEN

				PO_DEBUG.debug_var(l_log_head,l_progress,'p_update_person',p_update_person );

			END IF;

			SAVEPOINT PO_Mass_Update_Preparer_SP;

			Update_Preparer(p_update_person,
				        p_old_personid,
			                p_new_personid,
			                p_document_type,
			                p_document_no_from,
			                p_document_no_to,
			                p_date_from,
			                p_date_to,
			                p_commit_interval,
					p_msg_data,
                                        p_msg_count,
	                                l_return_status);

			IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				   ROLLBACK TO PO_Mass_Update_Preparer_SP;
				   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			END IF;

		EXCEPTION

			WHEN OTHERS THEN

			ROLLBACK TO PO_Mass_Update_Preparer_SP;

			IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

				FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress || SQLCODE || SUBSTR(SQLERRM,1,200));

			END IF;

			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

			FND_MSG_PUB.Count_And_Get(
				p_count =>  p_msg_count,
				p_data  =>  p_msg_data);

		END;

	END IF;

	IF (p_update_person = 'APPROVER' OR p_update_person = 'ALL') THEN

		BEGIN

			l_progress := '003';

			IF g_debug_stmt THEN

				PO_DEBUG.debug_var(l_log_head,l_progress,'p_update_person',p_update_person );

			END IF;

			SAVEPOINT PO_Mass_Update_Approver_SP;

			Update_Approver(p_update_person,
					p_old_personid,
			                p_new_personid,
			                p_document_type,
			                p_document_no_from,
			                p_document_no_to,
			                p_date_from,
			                p_date_to,
					p_commit_interval,
					p_msg_data,
                                        p_msg_count,
	                                l_return_status);

			IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				   ROLLBACK TO PO_Mass_Update_Approver_SP;
				   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			END IF;

		EXCEPTION

			WHEN OTHERS THEN

			ROLLBACK TO PO_Mass_Update_Approver_SP;

			IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

				FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress || SQLCODE || SUBSTR(SQLERRM,1,200));

			END IF;

			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

			FND_MSG_PUB.Count_And_Get(
				p_count =>  p_msg_count,
				p_data  =>  p_msg_data);

		END;

	END IF;

	IF (p_update_person = 'REQUESTOR' OR p_update_person = 'ALL') THEN

		BEGIN

			l_progress := '004';

			IF g_debug_stmt THEN

				PO_DEBUG.debug_var(l_log_head,l_progress,'p_update_person',p_update_person );

			END IF;

			SAVEPOINT PO_Mass_Update_Requestor_SP;

			Update_Requestor(p_update_person,
					 p_old_personid,
					 p_new_personid,
					 p_document_type,
					 p_document_no_from,
					 p_document_no_to,
					 p_date_from,
					 p_date_to,
					 p_commit_interval,
					 p_msg_data,
					 p_msg_count,
					 l_return_status);

			IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				   ROLLBACK TO PO_Mass_Update_Requestor_SP;
				   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			END IF;



		EXCEPTION

		WHEN OTHERS THEN

			ROLLBACK TO PO_Mass_Update_Requestor_SP;

			IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

				FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress || SQLCODE || SUBSTR(SQLERRM,1,200));

			END IF;

			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

			FND_MSG_PUB.Count_And_Get(
				p_count =>  p_msg_count,
				p_data  =>  p_msg_data);

		END;

	END IF;

EXCEPTION

WHEN OTHERS THEN

ROLLBACK TO Do_Update_SP;

	IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress || SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

FND_MSG_PUB.Count_And_Get(
	p_count =>  p_msg_count,
	p_data  =>  p_msg_data);

END DO_Update;

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Update_Preparer
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Updates the old preparer with the new preparer provided and also updates the
--		worklfow attributes when the requisitions are in Inprocess and Pre-approved
--		status.

-- Parameters :

-- IN         : p_update_person        Person needs to be updated(Preparer/Approver/Requestor).
--              p_old_personid         Id of the old person.
--		p_new_personid         Id of the new person.
--		p_document_type        Type of the document(INTERNAL AND PURCHASE).
--		p_document_no_from     Document number from.
--		p_document_no_to       Document number to.
--		p_date_from            Date from.
--		p_date_to              Date to.
--		p_commit_interval      Commit interval.

-- OUT        : p_msg_data             Actual message in encoded format.
--		p_msg_count            Holds the number of messages in the API list.
--		p_return_status        Return status of the API (Includes 'S','E','U').

-- End of Comments
--------------------------------------------------------------------------------------------------

PROCEDURE Update_Preparer (p_update_person    IN VARCHAR2,
			   p_old_personid     IN NUMBER,
                           p_new_personid     IN NUMBER,
                           p_document_type    IN VARCHAR2,
                           p_document_no_from IN VARCHAR2,
                           p_document_no_to   IN VARCHAR2,
                           p_date_from        IN DATE,
                           p_date_to          IN DATE,
                           p_commit_interval  IN NUMBER,
			   p_msg_data         OUT NOCOPY  VARCHAR2,
                           p_msg_count        OUT NOCOPY  NUMBER,
                           p_return_status    OUT NOCOPY  VARCHAR2) IS

c_req                     g_req;

stmt_req                  VARCHAR2(4000);
req_num_type              VARCHAR2(100);
l_commit_count            NUMBER := 0;
l_progress                VARCHAR2(3) := '000';
l_log_head                CONSTANT VARCHAR2(1000) := g_log_head||'Update_Preparer';

-- Cursor Output Variables.
l_req_rowid               ROWID;
l_req_num	          po_requisition_headers.segment1%TYPE;
l_doc_type                po_document_types_all.type_name%TYPE;
l_auth_status	          po_headers.authorization_status%TYPE;
l_itemtype                wf_items.item_type%TYPE;
l_itemkey	          wf_items.item_key%TYPE;

-- Local Variables used in the same procedure.

l_preparer_id             NUMBER;
l_buyer_user_id           NUMBER;
l_forward_from_id         NUMBER;
l_msg15                   VARCHAR2(240);

BEGIN

g_old_personid     := p_old_personid;
g_document_type    := p_document_type;
g_document_no_from := p_document_no_from;
g_document_no_to   := p_document_no_to;
g_date_from        := p_date_from;
g_date_to          := p_date_to;

IF g_debug_stmt THEN

	PO_DEBUG.debug_begin(l_log_head);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_update_person',p_update_person );
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_personid', p_old_personid);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_personid', p_new_personid);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_type',p_document_type );
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_no_from',p_document_no_from );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_from',p_date_from);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_to',p_date_to);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit_interval',p_commit_interval);

END IF;

SAVEPOINT  PO_Mass_Update_Preparer_SP;

l_progress := '001';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'Before Calling Preparer_Info','Before Calling Preparer_Info' );

	END IF;

	BEGIN

	SAVEPOINT Update_Preparer_SP;

	Preparer_Info(p_old_personid,
		      p_new_personid,
		      p_old_preparer_name,
	              p_new_preparer_name,
                      p_old_username,
	              p_new_username,
                      p_new_user_display_name,
	              p_org_name,
		      p_msg_data,
		      p_msg_count,
	              p_return_status);

	IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	     RETURN;
        END IF;


l_progress := '002';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'Before Calling Print_Output','Before Calling Print_Output' );

	END IF;

	IF (p_update_person = 'PREPARER' OR p_update_person = 'ALL') THEN

		Print_Output(p_update_person,
			     p_old_preparer_name,
		             p_new_preparer_name,
			     p_org_name,
			     p_document_type,
			     p_document_no_from,
		             p_document_no_to,
			     p_date_from,
		             p_date_to,
			     p_msg_data,
			     p_msg_count,
		             p_return_status);

	END IF;

	SELECT  manual_req_num_type
	  INTO  req_num_type
	  FROM  po_system_parameters;

	fnd_message.set_name('PO','PO_MUB_MSG_PREPARER');
        l_msg15 := fnd_message.get;

        l_progress := '003';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'req_num_type',req_num_type );

	END IF;

	EXCEPTION

	WHEN OTHERS THEN

	ROLLBACK TO Update_Preparer_SP;

		IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

			FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress || SQLCODE || SUBSTR(SQLERRM,1,200));

		END IF;

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	FND_MSG_PUB.Count_And_Get(
		p_count =>  p_msg_count,
		p_data  =>  p_msg_data);

	END;

stmt_req := 'SELECT por.ROWID,
		    por.segment1,
		    pdt.type_name,
		    por.authorization_status,
		    por.wf_item_type,
		    por.wf_item_key
	       FROM po_requisition_headers por,
		    po_document_types_vl pdt
	      WHERE por.preparer_id = PO_MASS_UPDATE_REQ_PVT.get_old_personid
	        AND pdt.document_type_code IN (''REQUISITION'')
	        AND pdt.document_subtype = por.type_lookup_code
		AND Nvl(por.authorization_status,''INCOMPLETE'') IN (''APPROVED'',''REQUIRES REAPPROVAL'',''INCOMPLETE'',''REJECTED'',''IN PROCESS'',''PRE-APPROVED'',''RETURNED'')
	        AND Nvl(por.cancel_flag,''N'') = ''N''';

	IF p_document_type IS NOT NULL AND p_document_type <> 'ALL' THEN  -- <BUG 6988269>

		stmt_req := stmt_req || ' AND por.type_lookup_code = PO_MASS_UPDATE_REQ_PVT.get_document_type';
        END IF;


	IF ( req_num_type = 'NUMERIC' ) THEN

		IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

			stmt_req := stmt_req || ' AND 1 = 1 ';

                ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

			stmt_req := stmt_req || ' AND DECODE ( RTRIM ( POR.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL ) >= to_number(PO_MASS_UPDATE_REQ_PVT.get_document_no_from)';

                ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

			stmt_req := stmt_req || ' AND DECODE ( RTRIM ( POR.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL ) <= to_number(PO_MASS_UPDATE_REQ_PVT.get_document_no_to)';

		ELSE

			stmt_req := stmt_req || ' AND DECODE ( RTRIM ( POR.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL )

						      BETWEEN to_number(PO_MASS_UPDATE_REQ_PVT.get_document_no_from) AND to_number(PO_MASS_UPDATE_REQ_PVT.get_document_no_to )';

		END IF;

        ELSE

	        IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

			stmt_req := stmt_req || ' AND 1 = 1 ';

		ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

			stmt_req := stmt_req || ' AND POR.SEGMENT1 >= PO_MASS_UPDATE_REQ_PVT.get_document_no_from';

		ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

			stmt_req := stmt_req || ' AND POR.SEGMENT1 <= PO_MASS_UPDATE_REQ_PVT.get_document_no_to';

		ELSE

			stmt_req := stmt_req || ' AND POR.SEGMENT1 BETWEEN PO_MASS_UPDATE_REQ_PVT.get_document_no_from AND PO_MASS_UPDATE_REQ_PVT.get_document_no_to';

	        END IF;

        END IF; /* req_num_type = 'NUMERIC' */

	/* Bug 6899092 Added Trunc condition in validating the date ranges */

	IF p_date_from IS NULL AND p_date_to IS NULL THEN

		stmt_req := stmt_req || ' AND 1 = 1 ';

	ELSIF p_date_from IS NOT NULL AND p_date_to IS NULL THEN

		stmt_req := stmt_req || ' AND POR.creation_date >= Trunc(PO_MASS_UPDATE_REQ_PVT.get_date_from)';

	ELSIF p_date_from IS NULL AND p_date_to IS NOT NULL THEN

		stmt_req := stmt_req || ' AND POR.creation_date <= Trunc(PO_MASS_UPDATE_REQ_PVT.get_date_to)';

	ELSE
	        stmt_req := stmt_req || ' AND POR.creation_date >= Trunc(PO_MASS_UPDATE_REQ_PVT.get_date_from)
		                          AND POR.creation_date < Trunc(PO_MASS_UPDATE_REQ_PVT.get_date_to)+1';

	END IF;

stmt_req := stmt_req || ' ORDER BY por.segment1';

IF (p_document_type IS NULL OR p_document_type IN ('PURCHASE','INTERNAL','ALL')) THEN  -- <BUG 6988269>

OPEN c_req for stmt_req;

LOOP

FETCH c_req INTO l_req_rowid,
                 l_req_num,
                 l_doc_type,
                 l_auth_status,
                 l_itemtype,
                 l_itemkey;

EXIT when c_req%NOTFOUND;

BEGIN

SAVEPOINT Update_Preparer_RECREQ_SP;

l_progress := '004';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_req_rowid',l_req_rowid );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_req_num',l_req_num );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_type',l_doc_type );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_auth_status',l_auth_status );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_itemtype',l_itemtype );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_itemkey',l_itemkey );

	END IF;

    UPDATE po_requisition_headers_all
       SET preparer_id = p_new_personid,
           last_update_date  = sysdate,
           last_updated_by   = fnd_global.user_id,
           last_update_login = fnd_global.login_id
     WHERE rowid = l_req_rowid;

     l_progress := '005';

     IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_personid',p_new_personid );

     END IF;

     IF  ( (l_auth_status='PRE-APPROVED') OR (l_auth_status='IN PROCESS') ) THEN

	    l_preparer_id := po_wf_util_pkg.GetItemAttrText ( itemtype   => l_itemtype,
                                                              itemkey    => l_itemkey,
                                                              aname      => 'PREPARER_ID');

	    IF (l_preparer_id = p_old_personid) THEN

			po_wf_util_pkg.SetItemAttrText ( itemtype   => l_itemtype,
				                         itemkey    => l_itemkey,
						         aname      => 'PREPARER_USER_NAME' ,
                                                         avalue     =>  p_new_username);

                        po_wf_util_pkg.SetItemAttrText ( itemtype   => l_itemtype,
                                                         itemkey    => l_itemkey,
                                                         aname      => 'PREPARER_DISPLAY_NAME' ,
                                                         avalue     =>  p_new_user_display_name);

			po_wf_util_pkg.SetItemAttrText ( itemtype   => l_itemtype,
							 itemkey    => l_itemkey,
	                                                  aname      => 'PREPARER_ID' ,
			                                  avalue     =>  p_new_personid);

            END IF;

            l_forward_from_id := po_wf_util_pkg.GetItemAttrText ( itemtype   => l_itemtype,
                                                                  itemkey    => l_itemkey,
                                                                  aname      => 'FORWARD_FROM_ID');


	    IF (l_forward_from_id = p_old_personid) THEN

			po_wf_util_pkg.SetItemAttrText ( itemtype   => l_itemtype,
	                                                itemkey    => l_itemkey,
		                                        aname      => 'FORWARD_FROM_DISP_NAME' ,
			                                avalue     =>  p_new_user_display_name);

	               po_wf_util_pkg.SetItemAttrText ( itemtype   => l_itemtype,
		                                        itemkey    => l_itemkey,
			                                aname      => 'FORWARD_FROM_ID' ,
				                        avalue     =>  p_new_personid);

	               po_wf_util_pkg.SetItemAttrText ( itemtype   => l_itemtype,
		                                        itemkey    => l_itemkey,
			                                aname      => 'FORWARD_FROM_USER_NAME' ,
				                        avalue     =>  p_new_username);

            END IF;

    END IF; /* End of l_auth_status = 'PRE APPROVED' */

   l_commit_count := l_commit_count + 1;

	IF l_commit_count = p_commit_interval THEN

		COMMIT;
	        l_commit_count := 0;

	END IF;

   l_progress := '006';

     IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_commit_count',l_commit_count );

     END IF;

  fnd_file.put_line(fnd_file.output, rpad(l_req_num,26) ||  RPad(l_doc_type,26) || l_msg15);

  EXCEPTION

  WHEN OTHERS THEN

	IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

  ROLLBACK TO Update_Preparer_RECREQ_SP;

  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

   END;

  END LOOP;

  CLOSE c_req;

  END IF; -- <End of p_document_type>

EXCEPTION

WHEN OTHERS THEN

	IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

ROLLBACK TO PO_Mass_Update_Buyer_SP;

p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

END Update_Preparer;

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Update_Approver
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Updates the old approver with the new approver provided and also forwards
--		the notification from old approver to new approver in case of In process
--		and Pre-approved requisitions.

-- Parameters :

-- IN         : p_update_person        Person needs to be updated(Preparer/Approver/Requestor).
--              p_old_personid         Id of the old person.
--		p_new_personid         Id of the new person.
--		p_document_type        Type of the document(INTERNAL AND PURCHASE).
--		p_document_no_from     Document number from.
--		p_document_no_to       Document number to.
--		p_date_from            Date from.
--		p_date_to              Date to.
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
                          p_commit_interval  IN NUMBER,
			  p_msg_data         OUT NOCOPY  VARCHAR2,
                          p_msg_count        OUT NOCOPY  NUMBER,
                          p_return_status    OUT NOCOPY  VARCHAR2) IS

c_req_approver            g_req_approver;
stmt_req                  VARCHAR2(4000);
--Bug 14393408 Start
stmt_req1                  VARCHAR2(4000);
stmt_req2                  VARCHAR2(4000);
--Bug 14393408 End
l_req_rowid		  ROWID;
l_req_num	          po_requisition_headers.segment1%TYPE;
req_num_type               VARCHAR2(100);
l_commit_count            NUMBER := 0;
l_progress                VARCHAR2(3) := '000';
l_log_head                CONSTANT VARCHAR2(1000) := g_log_head||'Update_Approver';
l_doc_type                po_document_types_all.type_name%TYPE;
l_auth_status	          po_headers.authorization_status%TYPE;
l_notification_id         wf_notifications.notification_id%TYPE;
l_msg16                   VARCHAR2(240);
l_msg17                   VARCHAR2(240);

BEGIN

--package variable intialization

g_old_personid     := p_old_personid;
g_document_type    := p_document_type;
g_document_no_from := p_document_no_from;
g_document_no_to   := p_document_no_to;
g_date_from        := p_date_from;
g_date_to          := p_date_to;

IF g_debug_stmt THEN

	PO_DEBUG.debug_begin(l_log_head);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_update_person',p_update_person );
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_personid', p_old_personid);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_personid', p_new_personid);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_type',p_document_type );
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_no_from',p_document_no_from );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_from',p_date_from);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_to',p_date_to);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit_interval',p_commit_interval);

END IF;

SAVEPOINT  PO_Mass_Update_Approver_SP;

l_progress := '001';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'Before Calling Preparer_Info','Before Calling Preparer_Info' );

	END IF;

	BEGIN

	SAVEPOINT Update_Approver_SP;

	Preparer_Info(p_old_personid,
		      p_new_personid,
		      p_old_preparer_name,
	              p_new_preparer_name,
                      p_old_username,
	              p_new_username,
                      p_new_user_display_name,
	              p_org_name,
		      p_msg_data,
		      p_msg_count,
	              p_return_status);

	IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	     RETURN;
        END IF;


g_old_username     := p_old_username;


l_progress := '002';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'Before Calling Print_Output','Before Calling Print_Output' );

	END IF;

	IF (p_update_person = 'APPROVER' ) THEN

		Print_Output(p_update_person,
			     p_old_preparer_name,
		             p_new_preparer_name,
			     p_org_name,
			     p_document_type,
			     p_document_no_from,
		             p_document_no_to,
			     p_date_from,
		             p_date_to,
			     p_msg_data,
			     p_msg_count,
		             p_return_status);


	END IF;

	SELECT  manual_req_num_type
	  INTO  req_num_type
	  FROM  po_system_parameters;

	fnd_message.set_name('PO','PO_MUB_MSG_NEW_APPROVER');
        l_msg16 := fnd_message.get;

        fnd_message.set_name('PO','PO_MUB_MSG_APPROVER');
        l_msg17 := fnd_message.get;

        l_progress := '003';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'req_num_type',req_num_type );

	END IF;

	EXCEPTION

	WHEN OTHERS THEN

	ROLLBACK TO Update_Approver_SP;

		IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

			FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress || SQLCODE || SUBSTR(SQLERRM,1,200));

		END IF;

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	FND_MSG_PUB.Count_And_Get(
		p_count =>  p_msg_count,
		p_data  =>  p_msg_data);

	END;

--Bug 14393408 Start
--Changed the query for bug 14393408 to handle AME Approval
stmt_req1 := 'SELECT  wfn.notification_id,
        por.segment1,
        pdt.type_name
  FROM  wf_notifications wfn,
        wf_item_activity_statuses wfa,
        po_requisition_headers por,
        po_document_types_vl pdt,
        wf_items wfi
 WHERE  wfn.notification_id = wfa.notification_id
 AND wfi.item_key = wfa.item_key
  and wfi.item_type=wfa.item_type
    AND por.wf_item_type=wfi.parent_item_type
    AND  por.wf_item_key=wfi.parent_item_key
    and wfi.parent_item_key is not null
   AND  wfn.status NOT IN (''CLOSED'',''CANCELED'')
   AND  Nvl(por.authorization_status,''INCOMPLETE'') IN (''IN PROCESS'',''PRE-APPROVED'')
   AND  wfn.recipient_role = PO_Mass_Update_Req_PVT.get_old_username
   AND  pdt.document_type_code in (''REQUISITION'')
   AND  pdt.document_subtype = por.type_lookup_code';

  stmt_req2 := 'SELECT  wfn.notification_id,
        por.segment1,
        pdt.type_name
  FROM  wf_notifications wfn,
        wf_item_activity_statuses wfa,
        po_requisition_headers por,
        po_document_types_vl pdt
 WHERE  wfn.notification_id = wfa.notification_id
   AND  wfa.item_type       = por.wf_item_type
   AND  wfa.item_key        = por.wf_item_key
   AND  wfn.status NOT IN (''CLOSED'',''CANCELED'')
   AND  Nvl(por.authorization_status,''INCOMPLETE'') IN (''IN PROCESS'',''PRE-APPROVED'')
   AND  wfn.recipient_role = PO_Mass_Update_Req_PVT.get_old_username
   AND  pdt.document_type_code in (''REQUISITION'')
   AND  pdt.document_subtype = por.type_lookup_code';


	IF p_document_type IS NOT NULL AND p_document_type <> 'ALL' THEN  -- <BUG 6988269>

		stmt_req1 := stmt_req1 || ' AND por.type_lookup_code = PO_Mass_Update_Req_PVT.get_document_type';
		stmt_req2 := stmt_req2 || ' AND por.type_lookup_code = PO_Mass_Update_Req_PVT.get_document_type';
        END IF;

	IF ( req_num_type = 'NUMERIC' ) THEN

		IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

			stmt_req1 := stmt_req1 || ' AND 1 = 1 ';
			stmt_req2 := stmt_req2 || ' AND 1 = 1 ';

                ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

			stmt_req1 := stmt_req1 || ' AND DECODE ( RTRIM ( POR.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL ) >= to_number(PO_Mass_Update_Req_PVT.get_document_no_from)';
			stmt_req2 := stmt_req2 || ' AND DECODE ( RTRIM ( POR.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL ) >= to_number(PO_Mass_Update_Req_PVT.get_document_no_from)';

                ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

			stmt_req1 := stmt_req1 || ' AND DECODE ( RTRIM ( POR.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL ) <= to_number(PO_Mass_Update_Req_PVT.get_document_no_to)';
			stmt_req2 := stmt_req2 || ' AND DECODE ( RTRIM ( POR.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL ) <= to_number(PO_Mass_Update_Req_PVT.get_document_no_to)';

		ELSE

			stmt_req1 := stmt_req1 || ' AND DECODE ( RTRIM ( POR.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL )

						      BETWEEN to_number(PO_Mass_Update_Req_PVT.get_document_no_from) AND to_number(PO_Mass_Update_Req_PVT.get_document_no_to)';--Bug 12652093, removed '||'

			stmt_req2 := stmt_req2 || ' AND DECODE ( RTRIM ( POR.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL )

						      BETWEEN to_number(PO_Mass_Update_Req_PVT.get_document_no_from) AND to_number(PO_Mass_Update_Req_PVT.get_document_no_to)';

		END IF;

        ELSE

	        IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

			stmt_req1 := stmt_req1|| ' AND 1 = 1 ';
			stmt_req2 := stmt_req2 || ' AND 1 = 1 ';

		ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

			stmt_req1 := stmt_req1 || ' AND POR.SEGMENT1 >= PO_Mass_Update_Req_PVT.get_document_no_from';
			stmt_req2 := stmt_req2 || ' AND POR.SEGMENT1 >= PO_Mass_Update_Req_PVT.get_document_no_from';

		ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

			stmt_req1 := stmt_req1 || ' AND POR.SEGMENT1 <= PO_Mass_Update_Req_PVT.get_document_no_to';
			stmt_req2 := stmt_req2 || ' AND POR.SEGMENT1 <= PO_Mass_Update_Req_PVT.get_document_no_to';

		ELSE

			stmt_req1 := stmt_req1 || ' AND POR.SEGMENT1 BETWEEN PO_Mass_Update_Req_PVT.get_document_no_from AND PO_Mass_Update_Req_PVT.get_document_no_to';
			stmt_req2 := stmt_req2 || ' AND POR.SEGMENT1 BETWEEN PO_Mass_Update_Req_PVT.get_document_no_from AND PO_Mass_Update_Req_PVT.get_document_no_to';

	        END IF;

        END IF; /* req_num_type = 'NUMERIC' */

	/* Bug 6899092 Added Trunc condition in validating the date ranges */

	IF p_date_from IS NULL AND p_date_to IS NULL THEN

		stmt_req1 := stmt_req1 || ' AND 1 = 1 ';
		stmt_req2 := stmt_req2 || ' AND 1 = 1 ';

	ELSIF p_date_from IS NOT NULL AND p_date_to IS NULL THEN

		stmt_req1 := stmt_req1 || ' AND POR.creation_date >= Trunc(PO_Mass_Update_Req_PVT.get_date_from)';
		stmt_req2 := stmt_req2 || ' AND POR.creation_date >= Trunc(PO_Mass_Update_Req_PVT.get_date_from)';

	ELSIF p_date_from IS NULL AND p_date_to IS NOT NULL THEN

		stmt_req1 := stmt_req1 || ' AND POR.creation_date <= Trunc(PO_Mass_Update_Req_PVT.get_date_to)';
		stmt_req2 := stmt_req2 || ' AND POR.creation_date <= Trunc(PO_Mass_Update_Req_PVT.get_date_to)';

	ELSE
	        stmt_req1 := stmt_req1 || ' AND POR.creation_date >= Trunc(PO_Mass_Update_Req_PVT.get_date_from)
		                          AND POR.creation_date < Trunc(PO_Mass_Update_Req_PVT.get_date_to)+1';

		      stmt_req2 := stmt_req2 || ' AND POR.creation_date >= Trunc(PO_Mass_Update_Req_PVT.get_date_from)
		                          AND POR.creation_date < Trunc(PO_Mass_Update_Req_PVT.get_date_to)+1';

	END IF;

stmt_req := stmt_req1 || ' UNION ALL ' || stmt_req2 || ' ORDER BY 2';
--Bug 14393408 End
IF (p_document_type IS NULL OR p_document_type IN ('PURCHASE','INTERNAL','ALL')) THEN  -- <BUG 6988269>

OPEN c_req_approver for stmt_req;

LOOP

FETCH c_req_approver INTO l_notification_id,
                          l_req_num,
                          l_doc_type;

EXIT WHEN c_req_approver%NOTFOUND;

l_progress := '004';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_notification_id',l_notification_id );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_req_num',l_req_num );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_type', l_doc_type);

	END IF;

	BEGIN

	SAVEPOINT Update_Req_Forward_SP;

	l_progress := '005';

	Wf_Notification.Forward(l_notification_id, p_new_username,l_msg16);

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_username',p_new_username );

	END IF;

        l_commit_count := l_commit_count + 1;

		IF l_commit_count = p_commit_interval THEN

			COMMIT;
		        l_commit_count := 0;

		END IF;

	l_progress := '006';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_commit_count',l_commit_count );

	END IF;

	fnd_file.put_line(fnd_file.output, rpad(l_req_num,26) ||  RPad(l_doc_type,26) || l_msg17);

	EXCEPTION

	WHEN OTHERS THEN

		IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

			FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

		END IF;

	ROLLBACK TO Update_Req_Forward_SP;

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

		END IF;

	FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

	END;


    END LOOP;

    CLOSE c_req_approver;

    END IF; -- <End of p_document_type>

EXCEPTION

WHEN OTHERS THEN

	IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

ROLLBACK TO PO_Mass_Update_Approver_SP;

p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

END Update_Approver;

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Update_Requestor
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Updates the old requestor with the new requestor provided.

-- Parameters :

-- IN         : p_update_person        Person needs to be updated(Preparer/Approver/Requestor).
--              p_old_personid         Id of the old person.
--		p_new_personid         Id of the new person.
--		p_document_type        Type of the document(INTERNAL AND PURCHASE).
--		p_document_no_from     Document number from.
--		p_document_no_to       Document number to.
--		p_date_from            Date from.
--		p_date_to              Date to.
--		p_commit_interval      Commit interval.

-- OUT        : p_msg_data             Actual message in encoded format.
--		p_msg_count            Holds the number of messages in the API list.
--		p_return_status        Return status of the API (Includes 'S','E','U').

-- End of Comments
--------------------------------------------------------------------------------------------------

PROCEDURE Update_Requestor(p_update_person    IN VARCHAR2,
			   p_old_personid     IN NUMBER,
                           p_new_personid     IN NUMBER,
                           p_document_type    IN VARCHAR2,
                           p_document_no_from IN VARCHAR2,
                           p_document_no_to   IN VARCHAR2,
                           p_date_from        IN DATE,
                           p_date_to          IN DATE,
                           p_commit_interval  IN NUMBER,
			   p_msg_data         OUT NOCOPY  VARCHAR2,
                           p_msg_count        OUT NOCOPY  NUMBER,
                           p_return_status    OUT NOCOPY  VARCHAR2) IS

c_req                     g_req;
stmt_req                  VARCHAR2(4000);
req_num_type              VARCHAR2(100);
l_req_rowid               ROWID;
l_req_num	          po_requisition_headers.segment1%TYPE;
l_commit_count            NUMBER := 0;
l_progress                VARCHAR2(3) := '000';
l_log_head                CONSTANT VARCHAR2(1000) := g_log_head||'Update_Requestor';
l_doc_type                po_document_types_all.type_name%TYPE;
l_auth_status	          po_headers.authorization_status%TYPE;
l_msg18                   VARCHAR2(240);
--Bug 14153104
l_requester_email         po_requisition_lines.requester_email%TYPE;
l_requester_phone		  po_requisition_lines.requester_phone%TYPE;
l_requester_fax			  po_requisition_lines.requester_fax%TYPE;

BEGIN

-- Intializing package variables

g_old_personid     := p_old_personid;
g_document_type    := p_document_type;
g_document_no_from := p_document_no_from;
g_document_no_to   := p_document_no_to;
g_date_from        := p_date_from;
g_date_to          := p_date_to;

IF g_debug_stmt THEN

	PO_DEBUG.debug_begin(l_log_head);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_update_person',p_update_person );
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_personid', p_old_personid);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_personid', p_new_personid);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_type',p_document_type );
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_no_from',p_document_no_from );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_from',p_date_from);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_to',p_date_to);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit_interval',p_commit_interval);

END IF;

SAVEPOINT  PO_Mass_Update_Requestor_SP;

l_progress := '001';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'Before Calling Preparer_Info','Before Calling Preparer_Info' );

	END IF;

	BEGIN

	SAVEPOINT Update_Requestor_SP;

	Preparer_Info(p_old_personid,
		      p_new_personid,
		      p_old_preparer_name,
	              p_new_preparer_name,
                      p_old_username,
	              p_new_username,
                      p_new_user_display_name,
	              p_org_name,
		      p_msg_data,
		      p_msg_count,
	              p_return_status);

	IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	     RETURN;
        END IF;


	l_progress := '002';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'Before Calling Print_Output','Before Calling Print_Output' );

	END IF;

	IF (p_update_person = 'REQUESTOR' ) THEN

		Print_Output(p_update_person,
			     p_old_preparer_name,
		             p_new_preparer_name,
			     p_org_name,
			     p_document_type,
			     p_document_no_from,
		             p_document_no_to,
			     p_date_from,
		             p_date_to,
			     p_msg_data,
			     p_msg_count,
		             p_return_status);

	END IF;

	SELECT  manual_req_num_type
	  INTO  req_num_type
	  FROM  po_system_parameters;

	fnd_message.set_name('PO','PO_MUB_MSG_REQUESTOR');
        l_msg18 := fnd_message.get;

        l_progress := '003';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'req_num_type',req_num_type );

	END IF;

	EXCEPTION

	WHEN OTHERS THEN

	ROLLBACK TO Update_Requestor_SP;

		IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

			FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress || SQLCODE || SUBSTR(SQLERRM,1,200));

		END IF;

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	FND_MSG_PUB.Count_And_Get(
		p_count =>  p_msg_count,
		p_data  =>  p_msg_data);

	END;



stmt_req := 'SELECT prl.ROWID,
       por.segment1,
       pdt.type_name
  FROM po_requisition_headers por,
       po_document_types_vl pdt,
       po_requisition_lines_all prl
 WHERE prl.to_person_id = PO_MASS_UPDATE_REQ_PVT.get_old_personid
   AND por.requisition_header_id = prl.requisition_header_id
   AND pdt.document_type_code IN (''REQUISITION'')
   AND pdt.document_subtype = por.type_lookup_code
   AND Nvl(por.authorization_status,''INCOMPLETE'') IN (''APPROVED'',''REQUIRES REAPPROVAL'',''INCOMPLETE'',''REJECTED'',''IN PROCESS'',''PRE-APPROVED'',''RETURNED'')
   AND Nvl(por.cancel_flag,''N'') = ''N''';

   IF p_document_type IS NOT NULL AND p_document_type <> 'ALL' THEN  -- <BUG 6988269>

		stmt_req := stmt_req || ' AND por.type_lookup_code = PO_MASS_UPDATE_REQ_PVT.get_document_type';
   END IF;

	IF ( req_num_type = 'NUMERIC' ) THEN

		IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

			stmt_req := stmt_req || ' AND 1 = 1 ';

                ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

			stmt_req := stmt_req || ' AND DECODE ( RTRIM ( POR.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL ) >= to_number(PO_MASS_UPDATE_REQ_PVT.get_document_no_from';

                ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

			stmt_req := stmt_req || ' AND DECODE ( RTRIM ( POR.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL ) <= to_number(PO_MASS_UPDATE_REQ_PVT.get_document_no_to)';

		ELSE

			stmt_req := stmt_req || ' AND DECODE ( RTRIM ( POR.SEGMENT1,''0123456789'' ), NULL, To_Number ( POR.SEGMENT1 ) , NULL )

						      BETWEEN to_number(PO_MASS_UPDATE_REQ_PVT.get_document_no_from) AND to_number(PO_MASS_UPDATE_REQ_PVT.get_document_no_to)';

		END IF;

        ELSE

	        IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

			stmt_req := stmt_req || ' AND 1 = 1 ';

		ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

			stmt_req := stmt_req || ' AND POR.SEGMENT1 >= PO_MASS_UPDATE_REQ_PVT.get_document_no_from';

		ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

			stmt_req := stmt_req || ' AND POR.SEGMENT1 <= PO_MASS_UPDATE_REQ_PVT.get_document_no_to';

		ELSE

			stmt_req := stmt_req || ' AND POR.SEGMENT1 BETWEEN PO_MASS_UPDATE_REQ_PVT.get_document_no_from AND PO_MASS_UPDATE_REQ_PVT.get_document_no_to';

	        END IF;

        END IF; /* req_num_type = 'NUMERIC' */

	/* Bug 6899092 Added Trunc condition in validating the date ranges */

	IF p_date_from IS NULL AND p_date_to IS NULL THEN

		stmt_req := stmt_req || ' AND 1 = 1 ';

	ELSIF p_date_from IS NOT NULL AND p_date_to IS NULL THEN

		stmt_req := stmt_req || ' AND POR.creation_date >= Trunc(PO_MASS_UPDATE_REQ_PVT.get_date_from)';

	ELSIF p_date_from IS NULL AND p_date_to IS NOT NULL THEN

		stmt_req := stmt_req || ' AND POR.creation_date <= Trunc(PO_MASS_UPDATE_REQ_PVT.get_date_to)';

	ELSE
	        stmt_req := stmt_req || ' AND POR.creation_date >= Trunc(PO_MASS_UPDATE_REQ_PVT.get_date_from)
		                          AND POR.creation_date < Trunc(PO_MASS_UPDATE_REQ_PVT.get_date_to)+1';

	END IF;

stmt_req := stmt_req || ' ORDER BY por.segment1';

IF (p_document_type IS NULL OR p_document_type IN ('PURCHASE','INTERNAL','ALL')) THEN  -- <BUG 6988269>

 -- Bug 14153104 start
  BEGIN
  SELECT pap.email_address,
         hr_general.get_work_phone(pap.person_id),
         hr_general.get_phone_number(pap.person_id, 'WF')
  INTO l_requester_email, l_requester_phone, l_requester_fax
  FROM   per_all_people_f pap,
         per_all_assignments_f asgn
  WHERE  pap.person_id = p_new_personid
  AND    asgn.person_id = pap.person_id
  AND    asgn.primary_flag = 'Y'
  AND    asgn.assignment_type IN ('E','C')
  AND    pap.effective_end_date in
         ( SELECT min(pap2.effective_end_date)
          FROM per_all_people_f pap2
          WHERE pap2.person_id = pap.person_id
          AND TRUNC(sysdate) <= pap2.effective_end_date )
  AND    asgn.effective_end_date in
         ( select min(asgn2.effective_end_date)
          from per_all_assignments_f asgn2
          where asgn2.person_id = asgn.person_id
           and asgn2.primary_flag = 'Y'
           and asgn2.assignment_type IN ('E','C')
          and TRUNC(sysdate) <= asgn2.effective_end_date);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	   l_requester_email := null;
	   l_requester_phone := null;
	   l_requester_fax   := null;
  END;
   -- Bug 14153104 end
OPEN c_req for stmt_req;

LOOP

FETCH c_req INTO l_req_rowid,
                 l_req_num,
                 l_doc_type;

EXIT when c_req%NOTFOUND;

BEGIN

SAVEPOINT Update_Requestor_RECREQ_SP;

l_progress := '004';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_req_rowid',l_req_rowid );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_req_num',l_req_num );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_type',l_doc_type );

	END IF;

   UPDATE po_requisition_lines_all
      SET to_person_id = p_new_personid,
	      requester_email = l_requester_email,-- Bug 14153104
		  requester_phone = l_requester_phone,
		  requester_fax  = l_requester_fax,
          last_update_date  = sysdate,
          last_updated_by   = fnd_global.user_id,
          last_update_login = fnd_global.login_id
    WHERE rowid = l_req_rowid;


   l_progress := '005';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_personid',p_new_personid );

	END IF;


   l_commit_count := l_commit_count + 1;

	IF l_commit_count = p_commit_interval THEN

		COMMIT;
		l_commit_count := 0;

	END IF;

   l_progress := '006';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_commit_count',l_commit_count );

	END IF;

   fnd_file.put_line(fnd_file.output, rpad(l_req_num,26) ||  rpad(l_doc_type,26) || l_msg18 );

   EXCEPTION

   WHEN OTHERS THEN

   IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

   ROLLBACK TO Update_Requestor_RECREQ_SP;

   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

   END;

   END LOOP;

   CLOSE c_req;

   END IF; -- <End of p_document_type>

EXCEPTION

WHEN OTHERS THEN

	IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

ROLLBACK TO PO_Mass_Update_Requestor_SP;

p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

END Update_Requestor;

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Print_Output
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Prints the header and body of the output file showing the documents and
--		document types updated along with the person who have been updated in the
--		document.

-- Parameters :

-- IN         : p_update_person        Person needs to be updated(Preparer/Approver/Requestor).
--              p_old_preparer_name    Preparer name of the old person.
--		p_new_preparer_name    Preparer name of the new person.
--              p_org_name             Operating unit name.
--		p_document_type        Type of the document(INTERNAL AND PURCHASE).
--		p_document_no_from     Document number from.
--		p_document_no_to       Document number to.
--		p_date_from            Date from.
--		p_date_to              Date to.

-- OUT        : p_msg_data             Actual message in encoded format.
--		p_msg_count            Holds the number of messages in the API list.
--		p_return_status        Return status of the API (Includes 'S','E','U').

-- End of Comments
--------------------------------------------------------------------------------------------------

PROCEDURE Print_Output(p_update_person       IN VARCHAR2,
		       p_old_preparer_name   IN VARCHAR2,
                       p_new_preparer_name   IN VARCHAR2,
                       p_org_name            IN VARCHAR2,
                       p_document_type       IN VARCHAR2,
                       p_document_no_from    IN VARCHAR2,
                       p_document_no_to      IN VARCHAR2,
                       p_date_from           IN DATE,
                       p_date_to             IN DATE,
		       p_msg_data            OUT NOCOPY  VARCHAR2,
                       p_msg_count           OUT NOCOPY  NUMBER,
                       p_return_status       OUT NOCOPY  VARCHAR2) IS

l_msg1             VARCHAR2(240);
l_msg2             VARCHAR2(240);
l_msg3             VARCHAR2(240);
l_msg4             VARCHAR2(240);
l_msg5             VARCHAR2(240);
l_msg6             VARCHAR2(240);
l_msg7             VARCHAR2(240);
l_msg8             VARCHAR2(240);
l_msg9             VARCHAR2(240);
l_msg10            VARCHAR2(240);
l_msg11            VARCHAR2(1000); -- bug 18650684
l_msg12            VARCHAR2(240);
l_msg13            VARCHAR2(240);
l_msg14            VARCHAR2(240);

l_progress                 VARCHAR2(3);
l_log_head                 CONSTANT VARCHAR2(1000) := g_log_head||'Print_Output';

BEGIN

l_progress  := '000';

IF g_debug_stmt THEN

	PO_DEBUG.debug_begin(l_log_head);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_update_person',p_update_person );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_preparer_name',p_old_preparer_name );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_preparer_name',p_new_preparer_name );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_org_name',p_org_name );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_type',p_document_type );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_no_from',p_document_no_from );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_no_to',p_document_no_to );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_from', p_date_from);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_to', p_date_to);

END IF;

     fnd_message.set_name('PO','PO_MUB_MSG_PREPARER_HEADER1');
     l_msg1 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DATE');
     l_msg2 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_OU');
     l_msg3 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_OLD_PERSON');
     l_msg4 := fnd_message.get;


     fnd_message.set_name('PO','PO_MUB_MSG_NEW_PERSON');
     l_msg5 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DOC_SUB_TYPE');
     l_msg6 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DOC_NUM_FROM');
     l_msg7 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DOC_NUM_TO');
     l_msg8 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DATE_FROM');
     l_msg9 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DATE_TO');
     l_msg10 := fnd_message.get;

     SAVEPOINT Print_SP;

     IF (p_update_person = 'PREPARER') THEN

	fnd_message.set_name('PO','PO_MUB_MSG_PREPARER_HEADER2');
	fnd_message.set_token('OLD_PREPARER',p_old_preparer_name);
	fnd_message.set_token('NEW_PREPARER',p_new_preparer_name);

     ELSIF (p_update_person = 'APPROVER') THEN

	fnd_message.set_name('PO','PO_MUB_MSG_PREPARER_HEADER3');
	fnd_message.set_token('OLD_APPROVER',p_old_preparer_name);
	fnd_message.set_token('NEW_APPROVER',p_new_preparer_name);

     ELSIF (p_update_person = 'REQUESTOR') THEN

	fnd_message.set_name('PO','PO_MUB_MSG_PREPARER_HEADER4');
	fnd_message.set_token('OLD_REQUESTOR',p_old_preparer_name);
	fnd_message.set_token('NEW_REQUESTOR',p_new_preparer_name);

     ELSIF (p_update_person = 'ALL') THEN

	fnd_message.set_name('PO','PO_MUB_MSG_PREPARER_HEADER5');
	fnd_message.set_token('OLD_PERSON',p_old_preparer_name);
	fnd_message.set_token('NEW_PERSON',p_new_preparer_name);

     END IF;

     l_progress  := '001';

     IF g_debug_stmt THEN

	PO_DEBUG.debug_var(l_log_head,l_progress,'p_update_person',p_update_person );

     END IF;

     l_msg11 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DOC_NUM');
     l_msg12 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DOC_TYPE');
     l_msg13 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_PERSON');
     l_msg14 := fnd_message.get;

     l_progress  := '002';

     fnd_file.put_line(fnd_file.output, l_msg1);
     fnd_file.put_line(fnd_file.output, '                         ');
     fnd_file.put_line(fnd_file.output, rpad(l_msg2,21)  || ' : ' || sysdate);
     fnd_file.put_line(fnd_file.output, rpad(l_msg3,21)  || ' : ' || p_org_name);
     fnd_file.put_line(fnd_file.output, rpad(l_msg4,21)  || ' : ' || p_old_preparer_name);
     fnd_file.put_line(fnd_file.output, rpad(l_msg5,21)  || ' : ' || p_new_preparer_name);
     fnd_file.put_line(fnd_file.output, rpad(l_msg6,21)  || ' : ' || p_document_type);
     l_progress  := '003';
     fnd_file.put_line(fnd_file.output, rpad(l_msg7,21)  || ' : ' || p_document_no_from);
     fnd_file.put_line(fnd_file.output, rpad(l_msg8,21)  || ' : ' || p_document_no_to);
     fnd_file.put_line(fnd_file.output, rpad(l_msg9,21)  || ' : ' || p_date_from);
     fnd_file.put_line(fnd_file.output, rpad(l_msg10,21) || ' : ' || p_date_to);
     l_progress  := '004';
     fnd_file.put_line(fnd_file.output, '                                         ');
     fnd_file.put_line(fnd_file.output, l_msg11);
     fnd_file.put_line(fnd_file.output, '                                                      ');

     fnd_file.put_line(fnd_file.output,  rpad(l_msg12,26) || RPad(l_msg13,26) || l_msg14);
     fnd_file.put_line(fnd_file.output,  rpad('-',60,'-'));


EXCEPTION

WHEN OTHERS THEN

     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

END IF;

ROLLBACK TO Print_SP;

p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

END Print_Output;

--------------------------------------------------------------------------------------------------
-- Start of Comments

-- API Name   : Preparer_Info
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Gets the Preparer Information.

-- Parameters :

-- IN         : p_old_personid			Id of the old person.
--		p_new_personid			Id of the new person.

-- OUT        : p_old_preparer_name		Preparer name of the old person.
--		p_new_preparer_name		Preparer name of the new person.
--		p_old_username			User name of the old person.
--		p_new_username			User name of the new person.
--		p_new_user_display_name		Display name of the new person.
--		p_org_name			Operating unit name.
--		p_msg_data			Actual message in encoded format.
--		p_msg_count			Holds the number of messages in the API list.
--		p_return_status			Return status of the API (Includes 'S','E','U').

-- End of Comments
--------------------------------------------------------------------------------------------------

PROCEDURE Preparer_Info(p_old_personid          IN NUMBER,
                        p_new_personid          IN NUMBER,
		        p_old_preparer_name     OUT NOCOPY VARCHAR2,
                        p_new_preparer_name     OUT NOCOPY VARCHAR2,
                        p_old_username          OUT NOCOPY VARCHAR2,
                        p_new_username          OUT NOCOPY VARCHAR2,
                        p_new_user_display_name OUT NOCOPY VARCHAR2,
                        p_org_name              OUT NOCOPY VARCHAR2,
			p_msg_data              OUT NOCOPY  VARCHAR2,
                        p_msg_count             OUT NOCOPY  NUMBER,
                        p_return_status         OUT NOCOPY  VARCHAR2) IS

l_progress                 VARCHAR2(3);
l_log_head                 CONSTANT VARCHAR2(1000) := g_log_head||'Preparer_Info';
l_org_id                   NUMBER;

BEGIN

l_progress := '000';

IF g_debug_stmt THEN

	PO_DEBUG.debug_begin(l_log_head);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_personid',p_old_personid );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_personid',p_new_personid );

END IF;

l_progress := '001';

SAVEPOINT Prep_Info_SP;

p_old_preparer_name := PO_EMPLOYEES_SV.get_emp_name(p_old_personid);

p_new_preparer_name := PO_EMPLOYEES_SV.get_emp_name(p_new_personid);

WF_DIRECTORY.GetUserName('PER',p_old_personid, p_old_username,p_old_user_display_name);

WF_DIRECTORY.GetUserName('PER',p_new_personid, p_new_username,p_new_user_display_name);

SELECT org_id
  INTO l_org_id
  FROM po_system_parameters;

SELECT hou.name
  INTO p_org_name
  FROM hr_all_organization_units hou,
       hr_all_organization_units_tl hout
 WHERE hou.organization_id = hout.organization_id
   AND  hout.LANGUAGE = UserEnv('LANG')
   AND hou.organization_id = l_org_id;

IF g_debug_stmt THEN
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_preparer_name', p_old_preparer_name);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_preparer_name', p_new_preparer_name);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_username', p_old_username);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_username', p_new_username);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_user_display_name', p_new_user_display_name);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_org_name ', p_org_name);
END IF;

EXCEPTION

WHEN OTHERS THEN

	IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

ROLLBACK TO Prep_Info_SP;

p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

END Preparer_Info;

--------------------------------------------------------------------------------------------------

-- Functions declared to return the value of the parameters passed in this API.

--------------------------------------------------------------------------------------------------

FUNCTION get_old_personid RETURN NUMBER
IS
BEGIN
	RETURN g_old_personid;
END;

FUNCTION get_document_type RETURN VARCHAR2
IS
BEGIN
	RETURN g_document_type;
END;

FUNCTION get_document_no_from RETURN VARCHAR2
IS
BEGIN
	RETURN g_document_no_from;
END;

FUNCTION get_document_no_to RETURN VARCHAR2
IS
BEGIN
	RETURN g_document_no_to;
END;

FUNCTION get_date_from RETURN DATE
IS
BEGIN
	RETURN g_date_from;
END;

FUNCTION get_date_to RETURN DATE
IS
BEGIN
	RETURN g_date_to;
END;

FUNCTION get_old_username RETURN VARCHAR2
IS
BEGIN
	RETURN g_old_username;
END;

END PO_Mass_Update_Req_PVT;

/
