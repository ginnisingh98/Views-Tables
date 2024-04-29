--------------------------------------------------------
--  DDL for Package Body PO_MASS_UPDATE_PO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_MASS_UPDATE_PO_PVT" AS
/* $Header: PO_Mass_Update_PO_PVT.plb 120.9.12010000.12 2014/07/18 06:35:29 ptulzapu ship $*/

--------------------------------------------------------------------------------------------------

-- Call is made such that the sql file POXMUB.sql calls the procedure
-- PO_Mass_Update_PO_GRP.Update_Persons
-- PO_Mass_Update_PO_GRP.Update_Persons calls the procedure PO_Mass_Update_PO_PVT.DO_Update

--------------------------------------------------------------------------------------------------

g_debug_stmt                 CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp                CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;
g_pkg_name                   CONSTANT VARCHAR2(100) := 'PO_Mass_Update_PO_PVT';
g_log_head                   CONSTANT VARCHAR2(1000) := 'po.plsql.' || g_pkg_name || '.';

TYPE g_po IS REF CURSOR;

TYPE g_rel IS REF CURSOR;

TYPE g_po_approver is REF CURSOR;

TYPE g_rel_approver is REF CURSOR;

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
                    p_return_status    OUT NOCOPY  VARCHAR2) IS

l_progress          VARCHAR2(3) := '000';
l_log_head          CONSTANT VARCHAR2(1000) := g_log_head||'Do_Update';
x_valid_buyer       VARCHAR2(10) := 'N';
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
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_supplier_id',p_supplier_id);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_include_close_po',p_include_close_po);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit_interval',p_commit_interval);

END IF;

SAVEPOINT Do_Update_SP;

l_progress := '001';

	IF (p_update_person = 'BUYER' OR p_update_person = 'ALL') THEN

		BEGIN

			l_progress := '002';

			IF g_debug_stmt THEN

				PO_DEBUG.debug_var(l_log_head,l_progress,'p_update_person',p_update_person );

			END IF;

			SAVEPOINT PO_Mass_Update_Buyer_SP;

			BEGIN
				SELECT 'Y' INTO x_valid_buyer
				  FROM po_buyers_val_v
				 WHERE employee_id = p_new_personid;
                        EXCEPTION
			  WHEN NO_DATA_FOUND THEN
				po_message_s.sql_error('Not a Valid Buyer','Not a Valid Buyer',l_progress,SQLCODE,SQLERRM);
				fnd_file.put_line(fnd_file.log,fnd_message.get);
				x_valid_buyer := 'N';
			END;

                           IF x_valid_buyer = 'Y' THEN


				Update_Buyer(p_update_person,
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
					l_return_status);

				IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				   ROLLBACK TO PO_Mass_Update_Buyer_SP;
				   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				END IF;

			  END IF;

		EXCEPTION

		WHEN OTHERS THEN

			ROLLBACK TO PO_Mass_Update_Buyer_SP;

			IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

				FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

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
					p_supplier_id,
					p_include_close_po,
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

				FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

			END IF;

			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

			FND_MSG_PUB.Count_And_Get(
				p_count =>  p_msg_count,
				p_data  =>  p_msg_data);

		END;

	END IF;

	IF (p_update_person = 'DELIVER TO' OR p_update_person = 'ALL') THEN

		BEGIN

			l_progress := '004';

			IF g_debug_stmt THEN

				PO_DEBUG.debug_var(l_log_head,l_progress,'p_update_person',p_update_person );

			END IF;

			SAVEPOINT PO_Mass_Update_Deliver_To_SP;

			Update_Deliver_To(p_update_person,
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
					  l_return_status);

			IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				   ROLLBACK TO PO_Mass_Update_Deliver_To_SP;
				   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			END IF;




		EXCEPTION

		WHEN OTHERS THEN

			ROLLBACK TO PO_Mass_Update_Deliver_To_SP;

			IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

				FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

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

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	FND_MSG_PUB.Count_And_Get(
		p_count =>  p_msg_count,
		p_data  =>  p_msg_data);

END DO_Update;

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

PROCEDURE Update_Buyer (p_update_person    IN VARCHAR2,
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

c_po g_po;
c_rel g_rel;

stmt_rel                  VARCHAR2(4000);
stmt_po                   VARCHAR2(4000);
po_num_type               VARCHAR2(100);
l_commit_count            NUMBER := 0;
l_progress                VARCHAR2(3) := '000';
l_log_head                CONSTANT VARCHAR2(1000) := g_log_head||'Update_Buyer';

-- Cursor Output Variables.

l_po_rowid                ROWID;
l_rel_rowid		  ROWID;
l_po_num	          po_headers.segment1%TYPE;
l_rel_num		  po_releases.release_num%TYPE;
l_doc_type                po_document_types_all.type_name%TYPE;
l_auth_status	          po_headers.authorization_status%TYPE;
l_itemtype                wf_items.item_type%TYPE;
l_itemkey	          wf_items.item_key%TYPE;

-- Variables used in OKC API.

l_document_id	          po_headers.po_header_id%TYPE;
l_document_type	          po_headers.type_lookup_code%TYPE;
l_document_version        po_headers.revision_num%TYPE;
l_conterms_exist_flag     po_headers.conterms_exist_flag%TYPE;
l_contracts_document_type VARCHAR2(150);
SUBTYPE busdocs_tbl_type  IS okc_manage_deliverables_grp.busdocs_tbl_type;
l_busdocs_tbl             busdocs_tbl_type;
l_empty_busdocs_tbl       busdocs_tbl_type;
l_row_index               PLS_INTEGER := 0;

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
g_supplier_id      := p_supplier_id;


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

SAVEPOINT  PO_Mass_Update_Buyer_SP;

l_progress := '001';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'Before Calling Buyer_Info','Before Calling Buyer_Info' );

	END IF;

	BEGIN

	SAVEPOINT Update_Buyer_REC_SP;

	Buyer_Info(p_old_personid,
		   p_new_personid,
		   p_supplier_id,
		   p_old_buyer_name,
	           p_new_buyer_name,
		   p_old_username,
	           p_new_username,
		   p_new_user_display_name,
	           p_old_buyer_user_id,
		   p_new_buyer_user_id,
	           p_supplier_name,
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

	IF (p_update_person = 'BUYER' OR p_update_person = 'ALL') THEN

		Print_Output(p_update_person,
			     p_old_buyer_name,
		             p_new_buyer_name,
			     p_org_name,
			     p_document_type,
			     p_document_no_from,
		             p_document_no_to,
			     p_date_from,
		             p_date_to,
			     p_supplier_name,
			     p_msg_data,
			     p_msg_count,
		             p_return_status);

	END IF;

	SELECT  manual_po_num_type
	  INTO  po_num_type
	  FROM  po_system_parameters;

	fnd_message.set_name('PO','PO_MUB_MSG_BUYER');
	l_msg15 :=  fnd_message.get;

        l_progress := '003';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'po_num_type',po_num_type );

	END IF;

	EXCEPTION

	WHEN OTHERS THEN

	ROLLBACK TO Update_Buyer_REC_SP;

		IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

			FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

		END IF;

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	FND_MSG_PUB.Count_And_Get(
		p_count =>  p_msg_count,
		p_data  =>  p_msg_data);

	END;

stmt_po := 'SELECT poh.ROWID,
	           poh.segment1,
		   pdt.type_name,
		   poh.authorization_status,
		   poh.wf_item_type,
		   poh.wf_item_key,
		   poh.po_header_id,
		   poh.type_lookup_code,
		   poh.revision_num,
		   Nvl(poh.conterms_exist_flag, ''N'')
	      FROM po_headers poh,
		   po_document_types_vl pdt
             WHERE poh.agent_id = PO_MASS_UPDATE_PO_PVT.get_old_personid
	       AND pdt.document_type_code IN (''PO'',''PA'')
	       AND pdt.document_subtype = poh.type_lookup_code
	       AND Nvl(poh.authorization_status,''INCOMPLETE'') IN (''APPROVED'',''REQUIRES REAPPROVAL'',''INCOMPLETE'',''REJECTED'',''IN PROCESS'',''PRE-APPROVED'')
	       AND Nvl(poh.cancel_flag,''N'') = ''N''
	       AND Nvl(poh.frozen_flag,''N'') = ''N'' ';

        IF p_document_type IS NOT NULL AND p_document_type <> 'ALL' THEN  -- <BUG 6988269>

		stmt_po := stmt_po || ' AND poh.type_lookup_code = PO_MASS_UPDATE_PO_PVT.get_document_type';

	END IF;

        IF ( po_num_type = 'NUMERIC' ) THEN

		IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

			stmt_po := stmt_po || ' AND 1 = 1 ';

                ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

			stmt_po := stmt_po || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) >= to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_from) ';

                ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

			stmt_po := stmt_po || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) <= to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_to ||) ';

		ELSE

			stmt_po := stmt_po || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL )

						    BETWEEN to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_from) AND to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_to) ';

		END IF;

        ELSE

	        IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

			stmt_po := stmt_po || ' AND 1 = 1 ';

		ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

			stmt_po := stmt_po || ' AND POH.SEGMENT1 >= PO_MASS_UPDATE_PO_PVT.get_document_no_from';

		ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

			stmt_po := stmt_po || ' AND POH.SEGMENT1 <= PO_MASS_UPDATE_PO_PVT.get_document_no_to';

		ELSE

			stmt_po := stmt_po || ' AND POH.SEGMENT1 BETWEEN PO_MASS_UPDATE_PO_PVT.get_document_no_from AND PO_MASS_UPDATE_PO_PVT.get_document_no_to';

	        END IF;

        END IF; /* End of po_num_type = 'NUMERIC' */

	/* Bug 6899092 Added Trunc condition in validating the date ranges */

	IF p_date_from IS NULL AND p_date_to IS NULL THEN

		stmt_po := stmt_po || ' AND 1 = 1 ';

	ELSIF p_date_from IS NOT NULL AND p_date_to IS NULL THEN

		stmt_po := stmt_po || ' AND POH.creation_date >= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_from)';

	ELSIF p_date_from IS NULL AND p_date_to IS NOT NULL THEN

		stmt_po := stmt_po || ' AND POH.creation_date <= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_to)';

	ELSE
	        stmt_po := stmt_po || ' AND POH.creation_date >= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_from)
		                        AND POH.creation_date < Trunc(PO_MASS_UPDATE_PO_PVT.get_date_to)+1';

	END IF;


        IF p_supplier_id IS NOT NULL THEN

		stmt_po := stmt_po || ' AND POH.vendor_id = PO_MASS_UPDATE_PO_PVT.get_supplier_id';

	END IF;

	IF p_include_close_po = 'YES' THEN

		stmt_po := stmt_po || ' AND Nvl(POH.closed_code,''OPEN'') NOT IN (''FINALLY CLOSED'') '; /* 6868589 */

	ELSE

		stmt_po := stmt_po || ' AND Nvl(POH.closed_code,''OPEN'') NOT IN (''CLOSED'',''FINALLY CLOSED'') '; /* 6868589 */

	END IF;

	stmt_po := stmt_po || ' ORDER BY POH.segment1';

IF (p_document_type IS NULL OR p_document_type IN ('STANDARD','BLANKET','PLANNED','CONTRACT','ALL')) THEN  -- <BUG 6988269>

OPEN c_po for stmt_po;

LOOP

FETCH c_po INTO  l_po_rowid,
                 l_po_num,
                 l_doc_type,
                 l_auth_status,
                 l_itemtype,
                 l_itemkey,
                 l_document_id,
                 l_document_type,
                 l_document_version,
                 l_conterms_exist_flag;

EXIT when c_po%NOTFOUND;

BEGIN

SAVEPOINT Update_Buyer_REC_PO_SP;

l_progress := '004';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_rowid',l_po_rowid );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_num',l_po_num );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_type',l_doc_type );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_auth_status',l_auth_status );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_itemtype',l_itemtype );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_itemkey',l_itemkey );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_document_id',l_document_id );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_document_type',l_document_type );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_document_version',l_document_version );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_conterms_exist_flag',l_conterms_exist_flag );

	END IF;

    BEGIN
        UPDATE po_headers_all
        SET agent_id = p_new_personid,
            last_update_date  = sysdate,
    	    last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
        WHERE rowid = l_po_rowid;

     --Bug 8551445 for PO121, update archive also.
        UPDATE po_headers_archive_all
        SET  agent_id = p_new_personid,
             last_update_date  = sysdate,
             last_updated_by   = fnd_global.user_id,
             last_update_login = fnd_global.login_id
        WHERE po_header_id=l_document_id
        AND   latest_external_flag= 'Y';
      EXCEPTION
              WHEN NO_DATA_FOUND THEN
              NULL;
     END;
     --Bug for 8551445 PO121 end.

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

       l_buyer_user_id  := po_wf_util_pkg.GetItemAttrText ( itemtype   => l_itemtype,
                                                            itemkey    => l_itemkey,
                                                            aname      => 'BUYER_USER_ID');

               IF (l_buyer_user_id = p_old_buyer_user_id) THEN

                        po_wf_util_pkg.SetItemAttrText ( itemtype   => l_itemtype,
                                                         itemkey    => l_itemkey,
                                                         aname      => 'BUYER_USER_ID' ,
                                                         avalue     =>  p_new_buyer_user_id);

                        po_wf_util_pkg.SetItemAttrText ( itemtype   => l_itemtype,
                                                         itemkey    => l_itemkey,
                                                         aname      => 'BUYER_USER_NAME' ,
                                                         avalue     =>  p_new_username);
                        /*
                        Bug 14078118
                        POXPOPDF uses 'USER_ID' and not 'BUYER_USER_ID', so this will make sure that, even after 'Mass Update' is run to
                        change a terminated buyer, POXPOPDF would not run with the terminated user's USER_ID
                        */
                        po_wf_util_pkg.SetItemAttrText ( itemtype   => l_itemtype,
                                                         itemkey    => l_itemkey,
                                                         aname      => 'USER_ID' ,
                                                         avalue     =>  p_new_buyer_user_id);

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

    /*
    Bug 14078118
    Added this condition to take care of the case in which Mass Update is run on an 'Approved' PO.
    */
    ELSIF (l_auth_status='APPROVED') THEN

        l_buyer_user_id  := po_wf_util_pkg.GetItemAttrText ( itemtype   => l_itemtype,
                                                            itemkey    => l_itemkey,
                                                            aname      => 'BUYER_USER_ID');

               IF (l_buyer_user_id = p_old_buyer_user_id) THEN

                        po_wf_util_pkg.SetItemAttrText ( itemtype   => l_itemtype,
                                                         itemkey    => l_itemkey,
                                                         aname      => 'BUYER_USER_ID' ,
                                                         avalue     =>  p_new_buyer_user_id);

                        po_wf_util_pkg.SetItemAttrText ( itemtype   => l_itemtype,
                                                         itemkey    => l_itemkey,
                                                         aname      => 'BUYER_USER_NAME' ,
                                                         avalue     =>  p_new_username);
                        po_wf_util_pkg.SetItemAttrText ( itemtype   => l_itemtype,
                                                         itemkey    => l_itemkey,
                                                         aname      => 'USER_ID' ,
                                                         avalue     =>  p_new_buyer_user_id);

               END IF;

    END IF; /* End of l_auth_status = 'PRE APPROVED' */

l_commit_count := l_commit_count + 1;

l_progress := '006';

IF g_debug_stmt THEN

	PO_DEBUG.debug_var(l_log_head,l_progress,'l_commit_count',l_commit_count );

END IF;

IF (UPPER(l_conterms_exist_flag)='Y') THEN

	l_row_index := l_row_index + 1;

	l_busdocs_tbl(l_row_index).bus_doc_id := l_document_id;
	l_busdocs_tbl(l_row_index).bus_doc_version := l_document_version;

	IF (p_document_type IN ('BLANKET', 'CONTRACT')) THEN

		l_contracts_document_type := 'PA_'||p_document_type;

        ELSIF (p_document_type = 'STANDARD') THEN

		l_contracts_document_type := 'PO_'||p_document_type;

        END IF;

	l_busdocs_tbl(l_row_index).bus_doc_type := l_contracts_document_type;
END IF;

IF l_commit_count = p_commit_interval THEN

	IF (l_busdocs_tbl.COUNT >= 1) THEN

		okc_manage_deliverables_grp.updateIntContactOnDeliverables (
			p_api_version                  => 1.0,
			p_init_msg_list                => FND_API.G_FALSE,
	                p_commit                       => FND_API.G_FALSE,
		        p_bus_docs_tbl                 => l_busdocs_tbl,
	                p_original_internal_contact_id => p_old_personid,
		        p_new_internal_contact_id      => p_new_personid,
	                x_msg_data                     => p_msg_data,
		        x_msg_count                    => p_msg_count,
	                x_return_status                => p_return_status);

			IF (p_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

			        FND_MSG_PUB.Count_and_Get(p_count => p_msg_count,p_data  => p_msg_data);
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

			END IF;

	END IF;

	COMMIT;
	l_commit_count := 0;

	l_busdocs_tbl := l_empty_busdocs_tbl;
	l_row_index := 0;

END IF;

fnd_file.put_line(fnd_file.output, rpad(l_po_num,26) ||  rpad(l_doc_type,32) || l_msg15 );

EXCEPTION

WHEN OTHERS THEN

IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

ROLLBACK TO Update_Buyer_REC_PO_SP;

p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

END;


END LOOP;

CLOSE c_po;

END IF; -- < End of p_document_type >

IF (l_busdocs_tbl.COUNT >= 1) THEN

	okc_manage_deliverables_grp.updateIntContactOnDeliverables (
		  p_api_version                  => 1.0,
                  p_init_msg_list                => FND_API.G_FALSE,
                  p_commit                       => FND_API.G_FALSE,
                  p_bus_docs_tbl                 => l_busdocs_tbl,
                  p_original_internal_contact_id => p_old_personid,
                  p_new_internal_contact_id      => p_new_personid,
                  x_msg_data                     => p_msg_data,
                  x_msg_count                    => p_msg_count,
                  x_return_status                => p_return_status);

		IF (p_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

			FND_MSG_PUB.Count_and_Get(p_count => p_msg_count
				                 ,p_data  => p_msg_data);

		        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		END IF;

END IF;

stmt_rel := 'SELECT por.ROWID,
		    poh.segment1,
		    por.release_num,
		    pdt.type_name,
		    por.authorization_status,
		    por.wf_item_type,
		    por.wf_item_key,
                    por.po_release_id --8551445 fix for PO121
	       FROM po_headers poh,
		    po_releases por,
		    po_document_types_vl pdt
	      WHERE poh.po_header_id = por.po_header_id
		AND por.agent_id = PO_MASS_UPDATE_PO_PVT.get_old_personid
		AND pdt.document_type_code   = ''RELEASE''
	        AND pdt.document_subtype     = por.release_type
		AND Nvl(por.authorization_status,''INCOMPLETE'') IN (''APPROVED'',''REQUIRES REAPPROVAL'',''INCOMPLETE'',''REJECTED'',''IN PROCESS'',''PRE-APPROVED'')
		AND Nvl(por.cancel_flag,''N'') = ''N''
		AND Nvl(por.frozen_flag,''N'') = ''N''';


	IF p_document_type IS NOT NULL AND p_document_type <> 'ALL' THEN  -- <BUG 6988269>

		stmt_rel := stmt_rel || ' AND ((PO_MASS_UPDATE_PO_PVT.get_document_type = ''PLANNED'' and por.release_type = ''SCHEDULED'')

	                                  OR (por.release_type = Nvl(PO_MASS_UPDATE_PO_PVT.get_document_type,por.release_type)))';

	END IF;


	IF ( po_num_type = 'NUMERIC' ) THEN

		IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

			stmt_rel := stmt_rel || ' AND 1 = 1 ';

	        ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

			stmt_rel := stmt_rel || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) >= to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_from)';

	        ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

			stmt_rel := stmt_rel || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) <= to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_to)';

		ELSE

			stmt_rel := stmt_rel || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL )

						      BETWEEN to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_from) AND to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_to)';

		END IF;

	ELSE

		IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

			stmt_rel := stmt_rel || ' AND 1 = 1 ';

		ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

			stmt_rel := stmt_rel || ' AND POH.SEGMENT1 >= PO_MASS_UPDATE_PO_PVT.get_document_no_from';

		ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

			stmt_rel := stmt_rel || ' AND POH.SEGMENT1 <= PO_MASS_UPDATE_PO_PVT.get_document_no_to';

		ELSE

			stmt_rel := stmt_rel || ' AND POH.SEGMENT1 BETWEEN PO_MASS_UPDATE_PO_PVT.get_document_no_from AND PO_MASS_UPDATE_PO_PVT.get_document_no_to';

		END IF;


	END IF; /* End of po_num_type = 'NUMERIC' */

	/* Bug 6899092 Added Trunc condition in validating the date ranges */

	IF p_date_from IS NULL AND p_date_to IS NULL THEN

		stmt_rel := stmt_rel || ' AND 1 = 1 ';

	ELSIF p_date_from IS NOT NULL AND p_date_to IS NULL THEN

		stmt_rel := stmt_rel || ' AND POR.creation_date >= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_from)';

	ELSIF p_date_from IS NULL AND p_date_to IS NOT NULL THEN

		stmt_rel := stmt_rel || ' AND POR.creation_date <= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_to)';

	ELSE

		stmt_rel := stmt_rel || ' AND POR.creation_date >= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_from)
		                          AND POR.creation_date < Trunc(PO_MASS_UPDATE_PO_PVT.get_date_to)+1';

	END IF;


	IF p_supplier_id IS NOT NULL THEN

		stmt_rel := stmt_rel || ' AND POH.vendor_id = PO_MASS_UPDATE_PO_PVT.get_supplier_id';

	END IF;


	IF p_include_close_po = 'YES' THEN

		stmt_rel := stmt_rel || ' AND Nvl(POR.closed_code,''OPEN'') NOT IN (''FINALLY CLOSED'') '; /* 6868589 */

	ELSE

		stmt_rel := stmt_rel || ' AND Nvl(POR.closed_code,''OPEN'') NOT IN (''CLOSED'',''FINALLY CLOSED'') '; /* 6868589 */

	END IF;

	stmt_rel := stmt_rel || ' ORDER BY POH.segment1,POR.release_num';


IF (p_document_type IS NULL OR p_document_type IN ('BLANKET','PLANNED','ALL')) THEN  -- <BUG 6988269 Added 'ALL' condition>

	OPEN c_rel for stmt_rel;

	LOOP

	FETCH c_rel INTO l_rel_rowid,
		         l_po_num,
			 l_rel_num,
	                 l_doc_type,
		         l_auth_status,
			 l_itemtype,
	                 l_itemkey,
                         l_document_id;--Bug 8551445 for PO121;

	EXIT WHEN c_rel%NOTFOUND;

	BEGIN

	SAVEPOINT Update_Buyer_REC_REL_SP;

	l_progress := '007';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_rel_rowid',l_rel_rowid );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_num',l_po_num );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_rel_num',l_rel_num );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_type',l_doc_type );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_auth_status',l_auth_status );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_itemtype',l_itemtype );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_itemkey',l_itemkey );

	END IF;

        BEGIN
	     UPDATE po_releases_all
	     SET agent_id = p_new_personid,
		 last_update_date  = sysdate,
		 last_updated_by   = fnd_global.user_id,
		 last_update_login = fnd_global.login_id
	     WHERE rowid = l_rel_rowid;

	 --Bug 8551445 for PO121, update archive also.

	     UPDATE po_releases_archive_all
	     SET  agent_id = p_new_personid,
	          last_update_date  = sysdate,
	          last_updated_by   = fnd_global.user_id,
	          last_update_login = fnd_global.login_id
	     WHERE po_release_id=l_document_id
	     AND   latest_external_flag= 'Y';

	 EXCEPTION
	          WHEN NO_DATA_FOUND THEN
	          NULL;
	 END;
       --Bug 8551445 for PO121 end.
	 l_progress := '008';

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

			l_buyer_user_id  := po_wf_util_pkg.GetItemAttrText ( itemtype   => l_itemtype,
					                                     itemkey    => l_itemkey,
							                     aname      => 'BUYER_USER_ID');

			    IF (l_buyer_user_id = p_old_buyer_user_id) THEN

				po_wf_util_pkg.SetItemAttrText ( itemtype   => l_itemtype,
						                 itemkey    => l_itemkey,
								 aname      => 'BUYER_USER_ID' ,
		                                                 avalue     =>  p_new_buyer_user_id);

				po_wf_util_pkg.SetItemAttrText ( itemtype   => l_itemtype,
						                 itemkey    => l_itemkey,
								 aname      => 'BUYER_USER_NAME' ,
		                                                 avalue     =>  p_new_username);

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

	l_progress := '009';

        IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_commit_count',l_commit_count );

	END IF;

		IF l_commit_count = p_commit_interval THEN

			COMMIT;
			l_commit_count := 0;

		END IF;

	fnd_file.put_line(fnd_file.output, rpad(l_po_num || '-' || l_rel_num,32) ||  rpad(l_doc_type,26) || l_msg15 );

	EXCEPTION

	WHEN OTHERS THEN

	IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

	ROLLBACK TO Update_Buyer_REC_REL_SP;

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

	FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

	END;

	END LOOP;

	CLOSE c_rel;

	END IF; /* End of p_document_type IS NULL */

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

END Update_Buyer;

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
                          p_return_status    OUT NOCOPY  VARCHAR2) IS

c_po_approver             g_po_approver;
c_rel_approver            g_rel_approver;
stmt_rel                  VARCHAR2(4000);
stmt_po                   VARCHAR2(4000);
l_po_rowid                ROWID;
l_rel_rowid		  ROWID;
l_po_num	          po_headers.segment1%TYPE;
l_rel_num		  po_releases.release_num%TYPE;
po_num_type               VARCHAR2(100);
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
g_supplier_id      := p_supplier_id;


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

SAVEPOINT  PO_Mass_Update_Approver_SP;

l_progress := '001';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'Before Calling Buyer_Info','Before Calling Buyer_Info' );

	END IF;

	BEGIN

	SAVEPOINT Update_Approver_REC_SP;

	Buyer_Info(p_old_personid,
		   p_new_personid,
		   p_supplier_id,
		   p_old_buyer_name,
	           p_new_buyer_name,
		   p_old_username,
	           p_new_username,
		   p_new_user_display_name,
	           p_old_buyer_user_id,
		   p_new_buyer_user_id,
	           p_supplier_name,
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
			     p_old_buyer_name,
		             p_new_buyer_name,
			     p_org_name,
			     p_document_type,
			     p_document_no_from,
		             p_document_no_to,
			     p_date_from,
		             p_date_to,
			     p_supplier_name,
			     p_msg_data,
			     p_msg_count,
		             p_return_status);

	END IF;

	SELECT  manual_po_num_type
	  INTO  po_num_type
	  FROM  po_system_parameters;

	fnd_message.set_name('PO','PO_MUB_MSG_NEW_APPROVER');
        l_msg16 := fnd_message.get;

	fnd_message.set_name('PO','PO_MUB_MSG_APPROVER');
        l_msg17 := fnd_message.get;

        l_progress := '003';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'po_num_type',po_num_type );

	END IF;

	EXCEPTION

	WHEN OTHERS THEN

	ROLLBACK TO Update_Approver_REC_SP;

		IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

			FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

		END IF;

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	FND_MSG_PUB.Count_And_Get(
		p_count =>  p_msg_count,
		p_data  =>  p_msg_data);

	END;


stmt_po := 'SELECT  wfn.notification_id,
        poh.segment1,
        pdt.type_name
  FROM  wf_notifications wfn,
        wf_item_activity_statuses wfa,
        po_headers poh,
        po_document_types_vl pdt
 WHERE  wfn.notification_id = wfa.notification_id
   AND  wfa.item_type       = poh.wf_item_type
   AND  wfa.item_key        = poh.wf_item_key
   AND  wfn.status NOT IN (''CLOSED'',''CANCELED'')
   AND  Nvl(poh.authorization_status,''INCOMPLETE'') IN (''IN PROCESS'',''PRE-APPROVED'')
   AND  wfn.recipient_role = PO_Mass_Update_PO_PVT.get_old_username
   AND  pdt.document_type_code in (''PO'',''PA'')
   AND  pdt.document_subtype = poh.type_lookup_code';


	IF p_document_type IS NOT NULL AND p_document_type <> 'ALL' THEN  -- <BUG 6988269>

		stmt_po := stmt_po || ' AND poh.type_lookup_code = PO_MASS_UPDATE_PO_PVT.get_document_type';

	END IF;


	IF ( po_num_type = 'NUMERIC' ) THEN

		IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

			stmt_po := stmt_po || ' AND 1 = 1 ';

		ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

			stmt_po := stmt_po || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) >= to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_from)';

		ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

			stmt_po := stmt_po || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) <= to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_to)';

		ELSE

			stmt_po := stmt_po || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL )

						    BETWEEN to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_from) AND to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_to)';

		END IF;

	ELSE

		IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

			stmt_po := stmt_po || ' AND 1 = 1 ';

		ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

			stmt_po := stmt_po || ' AND POH.SEGMENT1 >= PO_MASS_UPDATE_PO_PVT.get_document_no_from';

		ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

			stmt_po := stmt_po || ' AND POH.SEGMENT1 <= PO_MASS_UPDATE_PO_PVT.get_document_no_to';

		ELSE

			stmt_po := stmt_po || ' AND POH.SEGMENT1 BETWEEN PO_MASS_UPDATE_PO_PVT.get_document_no_from AND PO_MASS_UPDATE_PO_PVT.get_document_no_to';

		END IF;

	END IF; /* End of po_num_type = 'NUMERIC' */

	/* Bug 6899092 Added Trunc condition in validating the date ranges */

	IF p_date_from IS NULL AND p_date_to IS NULL THEN

		stmt_po := stmt_po || ' AND 1 = 1 ';

	ELSIF p_date_from IS NOT NULL AND p_date_to IS NULL THEN

		stmt_po := stmt_po || ' AND POH.creation_date >= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_from)';

	ELSIF p_date_from IS NULL AND p_date_to IS NOT NULL THEN

		stmt_po := stmt_po || ' AND POH.creation_date <= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_to)';

	ELSE

		stmt_po := stmt_po || ' AND POH.creation_date >= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_from)
		                        AND POH.creation_date < Trunc(PO_MASS_UPDATE_PO_PVT.get_date_to)+1';

	END IF;


	IF p_supplier_id IS NOT NULL THEN

		stmt_po := stmt_po || ' AND POH.vendor_id = PO_MASS_UPDATE_PO_PVT.get_supplier_id';

	END IF;

	IF p_include_close_po = 'YES' THEN

		stmt_po := stmt_po || ' AND Nvl(POH.closed_code,''OPEN'') NOT IN (''FINALLY CLOSED'') '; /* 6868589 */

	ELSE

		stmt_po := stmt_po || ' AND Nvl(POH.closed_code,''OPEN'') NOT IN (''CLOSED'',''FINALLY CLOSED'') '; /* 6868589 */

	END IF;

	stmt_po := stmt_po || ' ORDER BY POH.segment1';

IF (p_document_type IS NULL OR p_document_type IN ('STANDARD','BLANKET','PLANNED','CONTRACT','ALL')) THEN  -- <BUG 6988269>

OPEN c_po_approver for stmt_po;
LOOP

FETCH c_po_approver INTO l_notification_id,
                         l_po_num,
                         l_doc_type;

EXIT WHEN c_po_approver%NOTFOUND;

	l_progress := '004';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_notification_id',l_notification_id );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_num',l_po_num );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_type', l_doc_type);

	END IF;


	BEGIN

	SAVEPOINT Mass_Update_Forward_SP;

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



	fnd_file.put_line(fnd_file.output, rpad(l_po_num,26) ||  rpad(l_doc_type,32) || l_msg17 );

	EXCEPTION

	WHEN OTHERS THEN

		IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

			FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

		END IF;

		ROLLBACK TO Mass_Update_Forward_SP;

		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

		END IF;

		FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );


	END;

END LOOP;

CLOSE c_po_approver;

END IF; -- < End of p_document_type >


	IF (p_document_type IS NULL OR p_document_type IN ('BLANKET','PLANNED','ALL') ) THEN  -- <BUG 6988269 Added 'ALL' condition>


		stmt_rel := 'SELECT  wfn.notification_id,
				     poh.segment1,
				     por.release_num,
				     pdt.type_name
			       FROM  wf_notifications wfn,
				     wf_item_activity_statuses wfa,
				     po_headers poh,
				     po_releases por,
				     po_document_types_vl pdt
			      WHERE  wfn.notification_id = wfa.notification_id
				AND wfa.item_type       = por.wf_item_type
			        AND wfa.item_key        = por.wf_item_key
			        AND wfn.status NOT IN (''CLOSED'',''CANCELED'')
			        AND Nvl(por.authorization_status,''INCOMPLETE'') IN (''IN PROCESS'',''PRE-APPROVED'')
			        AND recipient_role         = PO_Mass_Update_PO_PVT.get_old_username
			        AND por.po_header_id       = poh.po_header_id
			        AND pdt.document_type_code = ''RELEASE''
			        AND pdt.document_subtype   = por.release_type';


		IF p_document_type IS NOT NULL AND p_document_type <> 'ALL' THEN  -- <BUG 6988269>

			stmt_rel := stmt_rel || ' AND ((PO_MASS_UPDATE_PO_PVT.get_document_type = ''PLANNED'' and por.release_type = ''SCHEDULED'')

						  OR (por.release_type = Nvl(PO_MASS_UPDATE_PO_PVT.get_document_type,por.release_type)))';

		END IF;

		IF ( po_num_type = 'NUMERIC' ) THEN

			IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

				stmt_rel := stmt_rel || ' AND 1 = 1 ';

			ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

				stmt_rel := stmt_rel || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) >= to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_from)';

			ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

				stmt_rel := stmt_rel || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) <= to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_to)';

			ELSE

				stmt_rel := stmt_rel || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL )

							      BETWEEN to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_from) AND to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_to)';

			END IF;

		ELSE

			IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

				stmt_rel := stmt_rel || ' AND 1 = 1 ';

			ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

				stmt_rel := stmt_rel || ' AND POH.SEGMENT1 >= PO_MASS_UPDATE_PO_PVT.get_document_no_from';

			ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

				stmt_rel := stmt_rel || ' AND POH.SEGMENT1 <= PO_MASS_UPDATE_PO_PVT.get_document_no_to';

			ELSE

				stmt_rel := stmt_rel || ' AND POH.SEGMENT1 BETWEEN PO_MASS_UPDATE_PO_PVT.get_document_no_from AND PO_MASS_UPDATE_PO_PVT.get_document_no_to';

			END IF;

		END IF;	/* End of po_num_type = 'NUMERIC' */

		/* Bug 6899092 Added Trunc condition in validating the date ranges */

		IF p_date_from IS NULL AND p_date_to IS NULL THEN

			stmt_rel := stmt_rel || ' AND 1 = 1 ';

		ELSIF p_date_from IS NOT NULL AND p_date_to IS NULL THEN

			stmt_rel := stmt_rel || ' AND POR.creation_date >= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_from)';

		ELSIF p_date_from IS NULL AND p_date_to IS NOT NULL THEN

			stmt_rel := stmt_rel || ' AND POR.creation_date <= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_to)';

		ELSE

			stmt_rel := stmt_rel || ' AND POR.creation_date >= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_from)
			                          AND POR.creation_date < Trunc(PO_MASS_UPDATE_PO_PVT.get_date_to)+1';

		END IF;

		IF p_supplier_id IS NOT NULL THEN

			stmt_rel := stmt_rel || ' AND POH.vendor_id = PO_MASS_UPDATE_PO_PVT.get_supplier_id';

		END IF;

		IF p_include_close_po = 'YES' THEN

		stmt_rel := stmt_rel || ' AND Nvl(POR.closed_code,''OPEN'') NOT IN (''FINALLY CLOSED'') '; /* Bug 6868589 */

		ELSE

		stmt_rel := stmt_rel || ' AND Nvl(POR.closed_code,''OPEN'') NOT IN (''CLOSED'',''FINALLY CLOSED'') '; /* Bug 6868589 */

		END IF;

		stmt_rel := stmt_rel ||  ' ORDER BY poh.segment1, por.release_num';

		OPEN c_rel_approver for stmt_rel;

		LOOP

		FETCH c_rel_approver INTO l_notification_id,
					  l_po_num,
					  l_rel_num,
					  l_doc_type;

	        EXIT WHEN c_rel_approver%NOTFOUND;

		l_progress := '007';

			IF g_debug_stmt THEN

				PO_DEBUG.debug_var(l_log_head,l_progress,'l_notification_id',l_notification_id );
				PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_num',l_po_num );
				PO_DEBUG.debug_var(l_log_head,l_progress,'l_rel_num',l_rel_num );
				PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_type', l_doc_type);

			END IF;

		BEGIN

			SAVEPOINT Mass_Update_Forward_SP;

			Wf_Notification.Forward(l_notification_id, p_new_username,l_msg16);

			l_progress := '008';

				IF g_debug_stmt THEN

					PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_username',p_new_username );

				END IF;

			l_commit_count := l_commit_count + 1;

				IF l_commit_count = p_commit_interval THEN

					COMMIT;
					l_commit_count := 0;

				END IF;

			l_progress := '009';

				IF g_debug_stmt THEN

					PO_DEBUG.debug_var(l_log_head,l_progress,'l_commit_count',l_commit_count );

				END IF;


			fnd_file.put_line(fnd_file.output, rpad(l_po_num || '-' || l_rel_num,32) ||  rpad(l_doc_type,26) || l_msg17);

		EXCEPTION

		WHEN OTHERS THEN

			IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

				FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

			END IF;

		ROLLBACK TO Mass_Update_Forward_SP;

		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

			IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

				FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

			END IF;

		FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

		END;

		END LOOP;

		CLOSE c_rel_approver;

     END IF; /* End of p_document_type IS NULL */

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
                            p_return_status    OUT NOCOPY  VARCHAR2) IS

c_po                      g_po;
c_rel                     g_rel;
stmt_rel                  VARCHAR2(4000);
stmt_po                   VARCHAR2(4000);
po_num_type               VARCHAR2(100);
l_po_rowid                ROWID;
l_rel_rowid		  ROWID;
l_po_num	          po_headers.segment1%TYPE;
l_rel_num		  po_releases.release_num%TYPE;
l_commit_count            NUMBER := 0;
l_progress                VARCHAR2(3) := '000';
l_log_head                CONSTANT VARCHAR2(1000) := g_log_head||'Update_Deliver_To';
l_doc_type                po_document_types_all.type_name%TYPE;
l_auth_status	          po_headers.authorization_status%TYPE;
l_msg18                   VARCHAR2(240);
l_release_id              po_releases.po_release_id%TYPE;

BEGIN

-- Intializing package variables

g_old_personid     := p_old_personid;
g_document_type    := p_document_type;
g_document_no_from := p_document_no_from;
g_document_no_to   := p_document_no_to;
g_date_from        := p_date_from;
g_date_to          := p_date_to;
g_supplier_id      := p_supplier_id;


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

SAVEPOINT  PO_Mass_Update_DeliverTo_SP;

l_progress := '001';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'Before Calling Buyer_Info','Before Calling Buyer_Info' );

	END IF;

	BEGIN

	SAVEPOINT Update_DeliverTo_REC_SP;

	Buyer_Info(p_old_personid,
		   p_new_personid,
		   p_supplier_id,
		   p_old_buyer_name,
	           p_new_buyer_name,
		   p_old_username,
	           p_new_username,
		   p_new_user_display_name,
	           p_old_buyer_user_id,
		   p_new_buyer_user_id,
	           p_supplier_name,
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

	IF (p_update_person = 'DELIVER TO' ) THEN

		Print_Output(p_update_person,
			     p_old_buyer_name,
		             p_new_buyer_name,
			     p_org_name,
			     p_document_type,
			     p_document_no_from,
		             p_document_no_to,
			     p_date_from,
		             p_date_to,
			     p_supplier_name,
			     p_msg_data,
			     p_msg_count,
		             p_return_status);

	END IF;

	SELECT  manual_po_num_type
	  INTO  po_num_type
	  FROM  po_system_parameters;

	fnd_message.set_name('PO','PO_MUB_MSG_DELIVER_TO');
        l_msg18 := fnd_message.get;

        l_progress := '003';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'po_num_type',po_num_type );

	END IF;

	EXCEPTION

	WHEN OTHERS THEN

	ROLLBACK TO Update_DeliverTo_REC_SP;

		IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

			FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

		END IF;

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	FND_MSG_PUB.Count_And_Get(
		p_count =>  p_msg_count,
		p_data  =>  p_msg_data);

	END;


stmt_po := 'SELECT pod.ROWID,
       poh.segment1,
       pdt.type_name,
       pod.po_release_id
  FROM po_headers poh,
       po_document_types_vl pdt,
       po_distributions pod
 WHERE pod.deliver_to_person_id = PO_MASS_UPDATE_PO_PVT.get_old_personid
   AND poh.po_header_id = pod.po_header_id
   AND pdt.document_type_code IN (''PO'',''PA'')
   AND pdt.document_subtype = poh.type_lookup_code
   AND Nvl(poh.authorization_status,''INCOMPLETE'') IN (''APPROVED'',''REQUIRES REAPPROVAL'',''INCOMPLETE'',''REJECTED'',''IN PROCESS'',''PRE-APPROVED'')
   AND Nvl(poh.cancel_flag,''N'') = ''N''
   AND Nvl(poh.frozen_flag,''N'') = ''N''';

   IF p_document_type IS NOT NULL AND p_document_type <> 'ALL' THEN  -- <BUG 6988269>

   stmt_po := stmt_po || 'AND poh.type_lookup_code = PO_MASS_UPDATE_PO_PVT.get_document_type';

   END IF;

   IF ( po_num_type = 'NUMERIC' ) THEN

	IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

		stmt_po := stmt_po || ' AND 1 = 1 ';

        ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

		stmt_po := stmt_po || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) >= to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_from)';

        ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

		stmt_po := stmt_po || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) <= to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_to)';

	ELSE

		stmt_po := stmt_po || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL )

					    BETWEEN to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_from) AND to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_to)';

	END IF;

    ELSE

        IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

		stmt_po := stmt_po || ' AND 1 = 1 ';

	ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

		stmt_po := stmt_po || ' AND POH.SEGMENT1 >= PO_MASS_UPDATE_PO_PVT.get_document_no_from';

	ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

		stmt_po := stmt_po || ' AND POH.SEGMENT1 <= PO_MASS_UPDATE_PO_PVT.get_document_no_to';

	ELSE

		stmt_po := stmt_po || ' AND POH.SEGMENT1 BETWEEN PO_MASS_UPDATE_PO_PVT.get_document_no_from AND PO_MASS_UPDATE_PO_PVT.get_document_no_to';

        END IF;

    END IF; /* End of po_num_type = 'NUMERIC' */

	/* Bug 6899092 Added Trunc condition in validating the date ranges */

	IF p_date_from IS NULL AND p_date_to IS NULL THEN

		stmt_po := stmt_po || ' AND 1 = 1 ';

	ELSIF p_date_from IS NOT NULL AND p_date_to IS NULL THEN

		stmt_po := stmt_po || ' AND POH.creation_date >= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_from)';

	ELSIF p_date_from IS NULL AND p_date_to IS NOT NULL THEN

		stmt_po := stmt_po || ' AND POH.creation_date <= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_to)';

	ELSE
	        stmt_po := stmt_po || ' AND POH.creation_date >= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_from)
		                        AND POH.creation_date < Trunc(PO_MASS_UPDATE_PO_PVT.get_date_to)+1';

	END IF;

        IF p_supplier_id IS NOT NULL THEN

		stmt_po := stmt_po || ' AND POH.vendor_id = PO_MASS_UPDATE_PO_PVT.get_supplier_id';

	END IF;

	IF p_include_close_po = 'YES' THEN

		stmt_po := stmt_po || ' AND Nvl(POH.closed_code,''OPEN'') NOT IN (''FINALLY CLOSED'') '; /* Bug 6868589 */

	ELSE

		stmt_po := stmt_po || ' AND Nvl(POH.closed_code,''OPEN'') NOT IN (''CLOSED'',''FINALLY CLOSED'') '; /* Bug 6868589 */

	END IF;

	stmt_po := stmt_po || ' ORDER BY POH.segment1';

   IF (p_document_type IS NULL OR p_document_type IN ('STANDARD','BLANKET','PLANNED','CONTRACT','ALL')) THEN  -- <BUG 6988269>

   OPEN c_po for stmt_po;

   LOOP

   FETCH c_po INTO l_po_rowid,
                   l_po_num,
                   l_doc_type,
		   l_release_id;

   EXIT when c_po%NOTFOUND;

   BEGIN

   SAVEPOINT Update_DeliverTo_RECPO_SP;

   l_progress := '004';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_rowid',l_po_rowid );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_num',l_po_num );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_type',l_doc_type );

	END IF;



   UPDATE po_distributions_all
      SET deliver_to_person_id = p_new_personid,
          last_update_date  = sysdate,
          last_updated_by   = fnd_global.user_id,
          last_update_login = fnd_global.login_id
    WHERE rowid = l_po_rowid
      AND po_release_id IS NULL;

    --Bug 18667867. Update data in archive table as well.
    UPDATE po_distributions_archive_all
       SET deliver_to_person_id = p_new_personid,
           last_update_date  = sysdate,
           last_updated_by   = fnd_global.user_id,
           last_update_login = fnd_global.login_id
	 WHERE po_distribution_id =
	         (SELECT po_distribution_id
                FROM po_distributions_all
               WHERE rowid = l_po_rowid)
       AND latest_external_flag = 'Y'
       AND po_release_id IS NULL;


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

   IF l_release_id IS NULL THEN

   fnd_file.put_line(fnd_file.output, rpad(l_po_num,26) ||  rpad(l_doc_type,32) || l_msg18 );

   END IF;

   EXCEPTION

   WHEN OTHERS THEN

   IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress||SQLCODE||SUBSTR(SQLERRM,1,200));

	END IF;

   ROLLBACK TO Update_DeliverTo_RECPO_SP;

   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

   END;

   END LOOP;

   CLOSE c_po;

   END IF; -- <End of p_document_type>

   stmt_rel := 'SELECT  pod.ROWID,
			poh.segment1,
		        por.release_num,
		        pdt.type_name
		  FROM  po_releases por,
		        po_headers poh,
		        po_document_types_vl pdt,
			po_distributions_all pod
		 WHERE  por.po_header_id = poh.po_header_id
		   AND poh.po_header_id = pod.po_header_id
		   AND pod.po_release_id = por.po_release_id     /* Bug 6868589 */
		   AND pod.deliver_to_person_id = PO_MASS_UPDATE_PO_PVT.get_old_personid
		   AND pdt.document_type_code   =''RELEASE''
		   AND pdt.document_subtype     = por.release_type
		   AND Nvl(por.authorization_status,''INCOMPLETE'') IN (''APPROVED'',''REQUIRES REAPPROVAL'',''INCOMPLETE'',''REJECTED'',''IN PROCESS'',''PRE-APPROVED'')
		   AND Nvl(por.cancel_flag,''N'') = ''N''
		   AND Nvl(por.frozen_flag,''N'') = ''N''';

    IF p_document_type IS NOT NULL AND p_document_type <> 'ALL' THEN  -- <BUG 6988269>

	stmt_rel := stmt_rel || ' AND ((PO_MASS_UPDATE_PO_PVT.get_document_type = ''PLANNED'' and por.release_type = ''SCHEDULED'')

				OR (por.release_type = Nvl(PO_MASS_UPDATE_PO_PVT.get_document_type,por.release_type)))';

    END IF;


    IF ( po_num_type = 'NUMERIC' ) THEN

	IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

		stmt_rel := stmt_rel || ' AND 1 = 1 ';

        ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

		stmt_rel := stmt_rel || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) >= to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_from)';

        ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

		stmt_rel := stmt_rel || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL ) <= to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_to )';

	ELSE

		stmt_rel := stmt_rel || ' AND DECODE ( RTRIM ( POH.SEGMENT1,''0123456789'' ), NULL, To_Number ( POH.SEGMENT1 ) , NULL )

					      BETWEEN to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_from) AND to_number(PO_MASS_UPDATE_PO_PVT.get_document_no_to)';

	END IF;

    ELSE

        IF p_document_no_from IS NULL AND p_document_no_to IS NULL THEN

		stmt_rel := stmt_rel || ' AND 1 = 1 ';

	ELSIF p_document_no_from IS NOT NULL AND p_document_no_to IS NULL THEN

		stmt_rel := stmt_rel || ' AND POH.SEGMENT1 >= PO_MASS_UPDATE_PO_PVT.get_document_no_from';

	ELSIF p_document_no_from IS NULL AND p_document_no_to IS NOT NULL THEN

		stmt_rel := stmt_rel || ' AND POH.SEGMENT1 <= PO_MASS_UPDATE_PO_PVT.get_document_no_to';

	ELSE

		stmt_rel := stmt_rel || ' AND POH.SEGMENT1 BETWEEN PO_MASS_UPDATE_PO_PVT.get_document_no_from AND PO_MASS_UPDATE_PO_PVT.get_document_no_to';

	END IF;

     END IF; /* End of po_num_type = 'NUMERIC' */

     /* Bug 6899092 Added Trunc condition in validating the date ranges */

     IF p_date_from IS NULL AND p_date_to IS NULL THEN

	stmt_rel := stmt_rel || ' AND 1 = 1 ';

     ELSIF p_date_from IS NOT NULL AND p_date_to IS NULL THEN

	stmt_rel := stmt_rel || ' AND POR.creation_date >= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_from)';

     ELSIF p_date_from IS NULL AND p_date_to IS NOT NULL THEN

	stmt_rel := stmt_rel || ' AND POR.creation_date <= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_to)';

     ELSE

	stmt_rel := stmt_rel || ' AND POR.creation_date >= Trunc(PO_MASS_UPDATE_PO_PVT.get_date_from)
	                          AND POR.creation_date < Trunc(PO_MASS_UPDATE_PO_PVT.get_date_to)+1';

     END IF;

     IF p_supplier_id IS NOT NULL THEN

	stmt_rel := stmt_rel || ' AND POH.vendor_id = PO_MASS_UPDATE_PO_PVT.get_supplier_id';

     END IF;

     IF p_include_close_po = 'YES' THEN

	stmt_rel := stmt_rel || ' AND Nvl(POR.closed_code,''OPEN'') NOT IN (''FINALLY CLOSED'') '; /* Bug 6868589 */

     ELSE

	stmt_rel := stmt_rel || ' AND Nvl(POR.closed_code,''OPEN'') NOT IN (''CLOSED'',''FINALLY CLOSED'') '; /* Bug 6868589 */

     END IF;

  stmt_rel := stmt_rel || ' ORDER BY POH.segment1,POR.release_num';


  IF (p_document_type IS NULL OR p_document_type IN ('BLANKET','PLANNED','ALL')) THEN  -- <BUG 6988269 Added 'ALL' condition>

	OPEN c_rel for stmt_rel;

        LOOP

        FETCH c_rel INTO l_rel_rowid,
                         l_po_num,
                         l_rel_num,
                         l_doc_type;

        EXIT WHEN c_rel%NOTFOUND;

	BEGIN

	SAVEPOINT Update_DeliverTo_RECREL_SP;

	l_progress := '007';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_rel_rowid',l_rel_rowid );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_num',l_po_num );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_rel_num',l_rel_num );
		PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_type',l_doc_type );

	END IF;

        UPDATE po_distributions_all
           SET deliver_to_person_id = p_new_personid,
               last_update_date  = sysdate,
               last_updated_by   = fnd_global.user_id,
               last_update_login = fnd_global.login_id
         WHERE rowid = l_rel_rowid;

	 --Bug 18667867. Update data in archive table as well.
	 UPDATE po_distributions_archive_all
            SET deliver_to_person_id = p_new_personid,
                last_update_date  = sysdate,
                last_updated_by   = fnd_global.user_id,
                last_update_login = fnd_global.login_id
	     WHERE po_distribution_id =
	            (SELECT po_distribution_id
                 FROM po_distributions_all
                 WHERE rowid = l_po_rowid)
           AND latest_external_flag = 'Y';

	 l_progress := '007';

	 IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_personid', p_new_personid);

	 END IF;


	l_commit_count := l_commit_count + 1;

		IF l_commit_count = p_commit_interval then

			COMMIT;
		        l_commit_count := 0;

		END IF;


        l_progress := '007';

	IF g_debug_stmt THEN

		PO_DEBUG.debug_var(l_log_head,l_progress,'l_commit_count', l_commit_count);

	END IF;

        fnd_file.put_line(fnd_file.output, rpad(l_po_num || '-' || l_rel_num,32) ||  rpad(l_doc_type,26) || l_msg18);

	EXCEPTION

	WHEN OTHERS THEN

	IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

	ROLLBACK TO Update_DeliverTo_RECREL_SP;

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

	FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

	END;

	END LOOP;

        CLOSE c_rel;

END IF; /* End of p_document_type IS NULL */

EXCEPTION

WHEN OTHERS THEN

	IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

ROLLBACK TO PO_Mass_Update_DeliverTo_SP;

p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

END Update_Deliver_To;

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
                       p_return_status    OUT NOCOPY  VARCHAR2) IS

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
l_msg11            VARCHAR2(240);
l_msg12            VARCHAR2(2000); -- BUG 18688214 fix
l_msg13            VARCHAR2(240);
l_msg14            VARCHAR2(240);
l_msg15            VARCHAR2(240);


l_progress                 VARCHAR2(3);
l_log_head                 CONSTANT VARCHAR2(1000) := g_log_head||'Print_Output';

BEGIN

l_progress  := '000';

IF g_debug_stmt THEN

	PO_DEBUG.debug_begin(l_log_head);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_update_person',p_update_person );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_buyer_name',p_old_buyer_name );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_buyer_name',p_new_buyer_name );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_org_name',p_org_name );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_type',p_document_type );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_no_from',p_document_no_from );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_no_to',p_document_no_to );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_from', p_date_from);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_to', p_date_to);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_supplier_name',p_supplier_name );

END IF;

     fnd_message.set_name('PO','PO_MUB_MSG_BUYER_HEADER1');
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

     fnd_message.set_name('PO','PO_MUB_MSG_SUPPLIER');
     l_msg11 := fnd_message.get;

     SAVEPOINT Print_SP;

     IF (p_update_person = 'BUYER') THEN

	fnd_message.set_name('PO','PO_MUB_MSG_BUYER_HEADER2');
	fnd_message.set_token('OLD_BUYER',p_old_buyer_name);
	fnd_message.set_token('NEW_BUYER',p_new_buyer_name);

     ELSIF (p_update_person = 'APPROVER') THEN

	fnd_message.set_name('PO','PO_MUB_MSG_BUYER_HEADER3');
	fnd_message.set_token('OLD_APPROVER',p_old_buyer_name);
	fnd_message.set_token('NEW_APPROVER',p_new_buyer_name);

     ELSIF (p_update_person = 'DELIVER TO') THEN

	fnd_message.set_name('PO','PO_MUB_MSG_BUYER_HEADER4');
	fnd_message.set_token('OLD_DELIVER_TO_PERSON',p_old_buyer_name);
	fnd_message.set_token('NEW_DELIVER_TO_PERSON',p_new_buyer_name);

     ELSIF (p_update_person = 'ALL') THEN

	fnd_message.set_name('PO','PO_MUB_MSG_BUYER_HEADER5');
	fnd_message.set_token('OLD_PERSON',p_old_buyer_name);
	fnd_message.set_token('NEW_PERSON',p_new_buyer_name);

     END IF;

     l_progress  := '001';

     IF g_debug_stmt THEN

	PO_DEBUG.debug_var(l_log_head,l_progress,'p_update_person',p_update_person );

     END IF;

     l_msg12 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DOC_NUM');
     l_msg13 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DOC_TYPE');
     l_msg14 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_PERSON');
     l_msg15 := fnd_message.get;

     l_progress  := '002';

     fnd_file.put_line(fnd_file.output, l_msg1);
     fnd_file.put_line(fnd_file.output, '                         ');
     fnd_file.put_line(fnd_file.output, rpad(l_msg2,21)  || ' : ' || sysdate);
     fnd_file.put_line(fnd_file.output, rpad(l_msg3,21)  || ' : ' || p_org_name);
     fnd_file.put_line(fnd_file.output, rpad(l_msg4,21)  || ' : ' || p_old_buyer_name);
     fnd_file.put_line(fnd_file.output, rpad(l_msg5,21)  || ' : ' || p_new_buyer_name);
     fnd_file.put_line(fnd_file.output, rpad(l_msg6,21)  || ' : ' || p_document_type);
     l_progress  := '003';
     fnd_file.put_line(fnd_file.output, rpad(l_msg7,21)  || ' : ' || p_document_no_from);
     fnd_file.put_line(fnd_file.output, rpad(l_msg8,21)  || ' : ' || p_document_no_to);
     fnd_file.put_line(fnd_file.output, rpad(l_msg9,21)  || ' : ' || p_date_from);
     fnd_file.put_line(fnd_file.output, rpad(l_msg10,21) || ' : ' || p_date_to);
     fnd_file.put_line(fnd_file.output, rpad(l_msg11,21) || ' : ' || p_supplier_name);
     l_progress  := '004';
     fnd_file.put_line(fnd_file.output, '                                         ');
     fnd_file.put_line(fnd_file.output, l_msg12);
     fnd_file.put_line(fnd_file.output, '                                                      ');
     fnd_file.put_line(fnd_file.output,  rpad(l_msg13,26) || rpad(l_msg14,32) || l_msg15);
     fnd_file.put_line(fnd_file.output,  rpad('-',70,'-'));

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
		     p_msg_data		     OUT NOCOPY  VARCHAR2,
                     p_msg_count	     OUT NOCOPY  NUMBER,
                     p_return_status	     OUT NOCOPY  VARCHAR2) IS

l_progress           VARCHAR2(3);
l_log_head           CONSTANT VARCHAR2(1000) := g_log_head||'Buyer_Info';
l_org_id             NUMBER;

 cursor c_old_buyer IS
    select name,
           substrb(display_name,1,360)
           p_display_name
    from   wf_local_roles
    where  orig_system     = 'PER'
    and    orig_system_id  = p_old_personid
    order by status, start_date;                                   ---Bug 9890242

BEGIN

l_progress := '000';

IF g_debug_stmt THEN

	PO_DEBUG.debug_begin(l_log_head);
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_personid',p_old_personid );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_personid',p_new_personid );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_supplier_id',p_supplier_id );

END IF;

SAVEPOINT Buyer_Info_SP;

l_progress := '001';

p_old_buyer_name := PO_EMPLOYEES_SV.get_emp_name(p_old_personid);

IF g_debug_stmt THEN

	PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_buyer_name',p_old_buyer_name );

     END IF;

p_new_buyer_name := PO_EMPLOYEES_SV.get_emp_name(p_new_personid);


IF g_debug_stmt THEN

	PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_buyer_name',p_new_buyer_name );

     END IF;

WF_DIRECTORY.GetUserName('PER',p_old_personid, p_old_username,p_old_user_display_name);
IF g_debug_stmt THEN

	PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_username',p_old_username );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_user_display_name',p_old_user_display_name );

 END IF;

---Bug 9890242 Start

IF p_old_username IS NULL AND p_old_user_display_name IS NULL
THEN

 open  c_old_buyer;
    fetch c_old_buyer into p_old_username, p_old_user_display_name;
    close c_old_buyer;

 IF g_debug_stmt THEN

	PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_user_display_name',p_old_user_display_name );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_username',p_old_username );

     END IF;

 END IF;

 ---Bug 9890242 End


WF_DIRECTORY.GetUserName('PER',p_new_personid, p_new_username,p_new_user_display_name);
IF g_debug_stmt THEN

	PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_username',p_new_username );
	PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_user_display_name',p_new_user_display_name );


     END IF;

--For Bug 13532047
--Handling this SQL in exception to continue the process
--though Fnd User id of old buyer is fetched or not.
BEGIN
SELECT user_id
  INTO p_old_buyer_user_id
  FROM fnd_user
 WHERE employee_id = p_old_personid
   AND user_name = p_old_username;
EXCEPTION
WHEN OTHERS THEN
NULL;
END;

 IF g_debug_stmt THEN

	PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_buyer_user_id',p_old_buyer_user_id );

 END IF;

 /*Bug 14475766 start.
   Added exception handling in case the new person is not an apps user
 */
 BEGIN
	SELECT user_id
	INTO p_new_buyer_user_id
	FROM fnd_user
	WHERE employee_id = p_new_personid
	AND user_name = p_new_username;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     IF g_debug_stmt THEN
        PO_DEBUG.debug_var(l_log_head,l_progress,'The new person is not APPS user.','The new person is not APPS user.' );
     END IF;
	 p_new_buyer_user_id := null;
 END;
 --Bug 14475766 end.

  IF g_debug_stmt THEN

	PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_buyer_user_id',p_new_buyer_user_id );

     END IF;

IF (p_supplier_id IS NOT NULL) then

    SELECT vendor_name
      INTO p_supplier_name
      FROM po_vendors
     WHERE vendor_id = p_supplier_id;

END IF;

SELECT org_id
  INTO l_org_id
  FROM po_system_parameters;

SELECT hou.name
  INTO p_org_name
  FROM hr_all_organization_units hou,
       hr_all_organization_units_tl hout
 WHERE hou.organization_id = hout.organization_id
   AND hout.LANGUAGE = UserEnv('LANG')
   AND hou.organization_id = l_org_id;

IF g_debug_stmt THEN

	PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_buyer_name', p_old_buyer_name);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_buyer_name', p_new_buyer_name);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_username', p_old_username);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_username', p_new_username);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_user_display_name', p_new_user_display_name);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_old_buyer_user_id', p_old_buyer_user_id);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_new_buyer_user_id', p_new_buyer_user_id);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_supplier_name',p_supplier_name);
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_org_name ', p_org_name);

END IF;

EXCEPTION

WHEN OTHERS THEN
	IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

		FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress || SQLCODE || SUBSTR(SQLERRM,1,200));

	END IF;

ROLLBACK TO Buyer_Info_SP;

p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN

		FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );

	END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );

END Buyer_Info;

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

FUNCTION get_supplier_id RETURN NUMBER
IS
BEGIN
	RETURN g_supplier_id;
END;

FUNCTION get_old_username RETURN VARCHAR2
IS
BEGIN
	RETURN g_old_username;
END;

END PO_Mass_Update_PO_PVT;

/
