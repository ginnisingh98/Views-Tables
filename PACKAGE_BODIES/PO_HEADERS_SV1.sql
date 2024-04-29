--------------------------------------------------------
--  DDL for Package Body PO_HEADERS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADERS_SV1" as
/* $Header: POXPOH1B.pls 120.4.12010000.6 2011/06/24 11:35:17 vegajula ship $*/


/*Added Log Messages as part of bug 12405805 */
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_log_head CONSTANT VARCHAR2(50) :='po.plsql.PO_HEADERS_SV1';

/*===========================================================================

  PROCEDURE NAME:	lock_row_for_status_update

===========================================================================*/

PROCEDURE lock_row_for_status_update (x_po_header_id	  IN  NUMBER)
IS
    CURSOR C IS
        SELECT 	*
        FROM   	po_headers
        WHERE   po_header_id = x_po_header_id
        FOR UPDATE of po_header_id NOWAIT;
    Recinfo C%ROWTYPE;

    x_progress	VARCHAR2(3) := '';

BEGIN
    x_progress := '010';
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE C;

EXCEPTION
    WHEN app_exception.record_lock_exception THEN
        po_message_s.app_error ('PO_ALL_CANNOT_RESERVE_RECORD');

    WHEN OTHERS THEN
	--dbms_output.put_line('In Exception');
	PO_MESSAGE_S.SQL_ERROR('LOCK_ROW_FOR_STATUS_UPDATE', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  FUNCTION NAME:	val_po_encumbered()

===========================================================================*/

/* PROCEDURE val_po_encumbered() IS

x_progress VARCHAR2(3) := NULL;

BEGIN


   EXCEPTION
   WHEN OTHERS THEN
      po_message.set_name('val_po_encumbered', x_progress, sqlcode);
   RAISE;

END val_po_encumbered;  */

/*===========================================================================

  FUNCTION NAME:	get_doc_num()

===========================================================================*/

/*PROCEDURE get_doc_num() IS

x_progress VARCHAR2(3) := NULL;

BEGIN


   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_doc_num', x_progress, sqlcode);
   RAISE;

END get_doc_num;  */

/*===========================================================================

  PROCEDURE NAME:	val_delete()

===========================================================================*/

 FUNCTION  val_delete(X_po_header_id IN NUMBER , X_type_lookup_code IN VARCHAR2)
           return boolean is
           X_allow_delete boolean;

           X_progress VARCHAR2(3) := NULL;
           X_encumbered boolean;

BEGIN

     /* If it is a PO or an Agreement check if it is encumbered */

       if ((X_type_lookup_code = 'STANDARD') or
           (X_type_lookup_code = 'PLANNED') or
           (X_type_lookup_code = 'BLANKET') or
           (X_type_lookup_code = 'CONTRACT') ) then

          X_progress := '005';

          X_encumbered := po_headers_sv1.get_po_encumbered(X_po_header_id);

          /* If the PO is encumbered, it has to be cancelled */

          if X_encumbered then
             X_allow_delete := FALSE;
             po_message_s.app_error('PO_PO_USE_CANCEL_ON_ENCUMB_PO');
          else
             X_allow_delete := TRUE;
          end if;

       elsif (X_type_lookup_code = 'RFQ') then

	      X_progress := '010';
              po_rfqs_sv.val_header_delete (X_po_header_id,
                                 	    X_allow_delete);

       elsif (X_type_lookup_code = 'QUOTATION') then

	      X_progress := '015';
              po_quotes_sv.val_header_delete (X_po_header_id,
                                 	      X_allow_delete);
       end if;

      return(X_allow_delete);


   EXCEPTION
      when others then
           X_allow_delete := FALSE;
           po_message_s.sql_error('val_delete', x_progress, sqlcode);
           raise;

END val_delete;

/*===========================================================================

  PROCEDURE NAME:	get_po_encumbered()

===========================================================================*/

 FUNCTION  get_po_encumbered(X_po_header_id IN  number)
           return boolean is

           X_encumbered boolean := FALSE;

           X_progress VARCHAR2(3) := '';

           cursor c1 is SELECT 'Y'
                        FROM   po_distributions
                        WHERE  po_header_id              = X_po_header_id
                        AND    nvl(encumbered_flag,'N') <> 'N';

                        --BUG 3230237
                        --PO_HEADERS_SV1.delete_po calls this procedure to determine
                        --if a PO can be deleted. We need to prevent encumbered
                        --BPAs from getting deleted.
			--AND  distribution_type <> 'AGREEMENT'; --<Encumbrance FPJ>

           Recinfo c1%rowtype;

BEGIN
     X_progress := '010';
     open c1;
     X_progress := '020';

     /* Check if any distributions for a given po_header_id is encumbered
     ** If there are encumbered distributions, return TRUE else
     ** return FALSE */

     fetch c1 into recinfo;

     X_progress := '030';

     if (c1%notfound) then
        close c1;
        X_encumbered := FALSE;
        return(X_encumbered);
     end if;

     X_encumbered := TRUE;
     return(X_encumbered);


   exception
      when others then
           po_message_s.sql_error('get_po_encumbered', X_progress, sqlcode);
           raise;

END get_po_encumbered;

/*===========================================================================

  PROCEDURE NAME:	delete_children()

===========================================================================*/

PROCEDURE delete_children(X_po_header_id IN NUMBER,
                          X_type_lookup_code IN VARCHAR2) IS

          X_progress VARCHAR2(3) := NULL;
          X_deleted  boolean;
BEGIN


         --BUG 3230237
         --Added 'BLANKET' to the if-condition since Encumbrance BPAs can have distributions.
         if (X_type_lookup_code IN ('STANDARD','PLANNED','BLANKET')) then --BUG 3230237
	        /* Delete Distributions for a PO */
                X_progress := '020';
                --dbms_output.put_line('Before Delete All Distributions');
                po_distributions_sv.delete_distributions(X_po_header_id, 'HEADER');
         end if;

         if (X_type_lookup_code <> 'CONTRACT') then

 	     /* Delete Shipments for a PO */
             X_progress := '015';
	     --dbms_output.put_line('Before Delete All Shipments ');
             po_shipments_sv4.delete_all_shipments (X_po_header_id, 'HEADER',
						    X_type_lookup_code);

             /* Delete Lines for a PO */
	     X_progress := '010';
	     --dbms_output.put_line('Before Delete All lines ');
             po_lines_sv.delete_all_lines (X_po_header_id,
	                                   X_type_lookup_code); --<HTML Agreements R12>

             /* Delete Vendors for a PO */
             if (X_type_lookup_code in ('RFQ','QUOTATION')) then
         	X_progress := '035';
	        --dbms_output.put_line('Before Delete All vendors ');
                po_rfq_vendors_pkg_s2.delete_all_vendors (X_po_header_id);
             end if;

         end if;

        /* Delete Notification Controls if it is PLANNED/BLANKET/CONTRACT PO */

        if ((X_type_lookup_code = 'PLANNED') or
            (X_type_lookup_code = 'BLANKET') or
            (X_type_lookup_code = 'CONTRACT')) then

            /* Call routine to delete po notification controls */
            X_progress := '025';
            --dbms_output.put_line('Before Delete Notification Controls');
            X_deleted := po_notif_controls_sv.delete_notifs (X_po_header_id);

        end if;

-- DEBUG it seems that this part of code is not needed since we don't allow to
--       delete approved blanket/planned PO.  If it is unapproved, there should
--       have no releases against it.
--       Remove it after reviewing this with KIM.
--
--        /* Delete All Releases for this  BLANKET/PLANNED that is being deleted.*/
--
--        if ((X_type_lookup_code = 'PLANNED') or
--            (X_type_lookup_code = 'BLANKET')) then
--
--             X_progress := '030';
--             --dbms_output.put_line('Before Delete all releases');
--             po_headers_sv1.delete_this_release (X_po_header_id);
--
--        end if;
--


 EXCEPTION

     when others then
           po_message_s.sql_error('delete_children', x_progress, sqlcode);
           raise;

END delete_children;

/*===========================================================================

  PROCEDURE NAME:	delete_po()

===========================================================================*/

FUNCTION delete_po(X_po_header_id     IN NUMBER,
                   X_type_lookup_code IN VARCHAR2,
                   p_skip_validation  IN VARCHAR2) --<HTML Agreements R12>
return boolean is

         X_deleted 		boolean;
         X_progress 		VARCHAR2(3) := NULL;
         X_allow_delete         boolean;
         X_rowid                varchar2(30);
         x_item_type            varchar2(8);
         x_item_key             varchar2(240);

BEGIN
       X_progress := '010';

       /* Retrieve PO row_id */
        SELECT poh.rowid
          INTO X_rowid
          FROM PO_HEADERS_ALL poh     /*Bug6632095: using base table instead of view */
         WHERE poh.po_header_id = X_po_header_id;

    --<HTML Agreements R12 Start>
    -- If the calling source is HTML then we need not do the validations as we
    -- would have already performed these validations in
    -- PO_HEADERS_SV1.validate_delete_document
    IF p_skip_validation = 'Y' THEN
        x_progress := '012';
        x_allow_delete := TRUE;
    ELSE
       X_progress := '015';
      /* Validate if the Document can be deleted */
       X_allow_delete := val_delete (X_po_header_id, X_type_lookup_code);
    END IF;
    --<HTML Agreements R12 End>

      /* If the doc can be deleted, */

       if (X_allow_delete) then

          /*  Call routine to delete PO notifications */
          /*hvadlamu : commenting out the delete part. Adding the Workflow call to stop the process.
            This call would also cancel any existing notifications waiting for a response*/
           /*po_notifications_sv1.delete_po_notif (x_type_lookup_code,
					        x_po_header_id); */
	SELECT wf_item_type,wf_item_key
	INTO   x_item_type,x_item_key
	FROM   PO_HEADERS_ALL                        /*Bug6632095: using base table instead of view */
	WHERE  po_header_id = x_po_header_id;

	if ((x_item_type is null) and (x_item_key is null)) then
		 po_approval_reminder_sv.cancel_notif (x_type_lookup_code,
               	                      x_po_header_id);
	else
         /* when trying to delete a po it could be that it was submitted to
            approval workflow and was never approved in which case  we
           need to stop the approval workflow as well as the  reminder workflow */
         po_approval_reminder_sv.cancel_notif (x_type_lookup_code,x_po_header_id);

          po_approval_reminder_sv.stop_process(x_item_type,x_item_key);


	end if;

         /* Bug 2904413 Need to delete the action history also */
         Delete po_action_history
         Where OBJECT_TYPE_CODE = decode(x_type_lookup_code,
                                         'STANDARD', 'PO',
                                         'PLANNED','PO','PA') and
               OBJECT_SUB_TYPE_CODE = x_type_lookup_code and
               OBJECT_ID = x_po_header_id;

          /* Delete header attachments */

          fnd_attached_documents2_pkg.delete_attachments('PO_HEADERS',
                                     			 x_po_header_id,
                                    			 '', '', '', '', 'Y');

           po_headers_sv1.delete_events_entities('PURCHASE_ORDER',  X_po_header_id);   ----Bug 12405805


          po_headers_sv1.delete_children(X_po_header_id, X_type_lookup_code);

          po_headers_pkg_s2.delete_row(X_rowid);

          if ((X_type_lookup_code = 'STANDARD') or
              (X_type_lookup_code = 'PLANNED'))  then

              /* UPDATE REQ LINK */
              po_headers_sv2.update_req_link(X_po_header_id);

          end if;

         X_deleted := TRUE;
         return(X_deleted);

       else

         X_deleted := FALSE;
         return(X_deleted);

       end if;

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
            po_message_s.app_error('PO_ALL_RECORDS_NOT_FOUND');
            RETURN (FALSE);
          RAISE;
       when others then
            po_message_s.sql_error('delete_po', x_progress, sqlcode);
            raise;

END delete_po;

/*===========================================================================

  PROCEDURE NAME:	delete_this_release()
===========================================================================*/

 PROCEDURE delete_this_release(X_po_header_id IN NUMBER) is

           X_progress  		varchar2(3) := '';
           X_release_id     	NUMBER;
           X_rowid              varchar2(30);

 BEGIN

          /* Delete the Releases against the PA if they exist */

          X_progress := '010';
          /* Retrieve the related release id and  rowid if exists */

          SELECT   prl.po_release_id,
                   prl.rowid
          INTO     X_release_id,
                   X_rowid
          FROM     PO_RELEASES prl
          WHERE    prl.po_header_id = x_po_header_id;


          X_progress := '015';

          IF   X_release_id is not NUll THEN

               -- Attempt to lock the release for delete
               po_releases_sv.lock_row_for_status_update (X_release_id);

               -- Call the release server to delete the release document
               po_releases_sv.delete_release (X_release_id, X_rowid);

          END IF;


 EXCEPTION

         when no_data_found then

             /* It is not an error if there have been no releases against this PA */
              null;

         when others then

            po_message_s.sql_error('delete_po', x_progress, sqlcode);
            raise;

END delete_this_release;

/*===========================================================================

  PROCEDURE NAME:	insert_po()- Moved to po_headers_sv11
===========================================================================*/

/*===========================================================================

  PROCEDURE NAME:	insert_children()

===========================================================================*/
/*
PROCEDURE insert_children() IS

x_progress VARCHAR2(3) := NULL;

BEGIN


   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('insert_children', x_progress, sqlcode);
   RAISE;

END insert_children;  */

--<HTML Agreements R12 START>
-----------------------------------------------------------------------------
--Start of Comments
--Name: validate_delete_document
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Checks whether the delete action is valid for this header
--  and in case it is not it returns the error message.
--Parameters:
--IN:
--p_doc_type
--  Document Type PO/PA
--p_doc_header_id
--  Header ID of the document whose header is being validated
--p_doc_approved_date
--  Latest Approval Date for the document
--p_auth_status
--  Authorization Status of the Document. See 'AUTHORIZATION STATUS' lookup type
--p_style_disp_name
--  Translated Style Display Name
--x_message_text
--  Will hold the error message in case the header cannot be deleted
--Notes:
--  Some of the validations which have already been done in Java layer are done
--  here again so that this procedure can be used by other modules which may
--  not have done any validation before calling this procedure.
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE validate_delete_document( p_doc_type          IN VARCHAR2
                                   ,p_doc_header_id     IN NUMBER
                                   ,p_doc_approved_date IN DATE
                                   ,p_auth_status       IN VARCHAR2
                                   ,p_style_disp_name   IN VARCHAR2
                                   ,x_message_text      OUT NOCOPY VARCHAR2)
IS
  l_some_dists_reserved_flag  VARCHAR2(1) := 'N';
  d_pos                    NUMBER := 10;
  l_api_name CONSTANT      VARCHAR2(30) := 'validate_delete_document';
  d_module   CONSTANT      VARCHAR2(70) := 'po.plsql.PO_HEADERS_SV1.validate_delete_document';
BEGIN
  IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_begin(d_module); PO_LOG.proc_begin(d_module,'p_doc_type', p_doc_type); PO_LOG.proc_begin(d_module,'p_doc_header_id', p_doc_header_id); PO_LOG.proc_begin(d_module,'p_doc_approved_date', p_doc_approved_date);
      PO_LOG.proc_begin(d_module,'p_auth_status', p_auth_status); PO_LOG.proc_begin(d_module,'p_style_disp_name', p_style_disp_name);
  END IF;

  IF p_doc_approved_date IS NOT NULL THEN
      x_message_text := PO_CORE_S.get_translated_text('PO_PO_USE_CANCEL_ON_APRVD_PO3'
                                                      ,'DOCUMENT_TYPE'
                                                      , p_style_disp_name);
      RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
  END IF;

  d_pos := 20;
  -- Disallow a delete if any distributions are reserved.
  PO_CORE_S.are_any_dists_reserved(
                   p_doc_type                 => p_doc_type,
                   p_doc_level                => PO_CORE_S.g_doc_level_HEADER,
                   p_doc_level_id             => p_doc_header_id,
                   x_some_dists_reserved_flag => l_some_dists_reserved_flag);
  d_pos:= 30;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_pos,'l_some_dists_reserved_flag',l_some_dists_reserved_flag);
  END IF;

  IF l_some_dists_reserved_flag = 'Y'
  THEN
      x_message_text := PO_CORE_S.get_translated_text('PO_PO_USE_CANCEL_ON_ENCUMB_PO');
      RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN PO_CORE_S.G_EARLY_RETURN_EXC THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_pos,'x_message_text',x_message_text);
    END IF;
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name||':'||d_pos);
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in'  || d_module);
    END IF;
    RAISE;
END validate_delete_document;

-----------------------------------------------------------------------------
--Start of Comments
--Name: delete_document
--Pre-reqs:
--  PO_HEADERS_SV1.validate_delete_document should be called to check if the
--  the delete action is a valid action on the document.
--Modifies:
--  None
--Locks:
--  None
--Function:
--  If the delete action is valid on the header, this procedure is responsible for
--  deleting the header as well its children and all the associated entities.
--Parameters:
--IN:
--p_doc_type
--  Document type of the PO [PO/PA]
--p_doc_subtype
--  Document Subtype of the [STANDARD/BLANKET/CONTRACT]
--p_doc_header_id
--  Header ID of the PO to which the entity being deleted belongs
--p_ga_flag
--  Whether the Document is global or not Global Agreement flag
--p_conterms_exist_flag
--  Whether the Document has Contract Terms or not
--OUT:
--x_return_status
--  Standard API specification parameter
--  Can hold one of the following values:
--    FND_API.G_RET_STS_SUCCESS (='S')
--    FND_API.G_RET_STS_ERROR (='E')
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE delete_document( p_doc_type            IN VARCHAR2
                          ,p_doc_subtype         IN VARCHAR2
                          ,p_doc_header_id       IN NUMBER
                          ,p_ga_flag             IN VARCHAR2
                          ,p_conterms_exist_flag IN VARCHAR2
                          ,x_return_status       OUT NOCOPY VARCHAR2)
IS
  l_msg_count  NUMBER;
  l_msg_data   VARCHAR2(2000);
  d_pos                      NUMBER := 0;
  l_api_name CONSTANT        VARCHAR2(30) := 'delete_document';
  d_module   CONSTANT        VARCHAR2(70) := 'po.plsql.PO_HEADERS_SV1.delete_document';

BEGIN
  IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_begin(d_module); PO_LOG.proc_begin(d_module,'p_doc_type', p_doc_type); PO_LOG.proc_begin(d_module,'p_doc_header_id', p_doc_header_id); PO_LOG.proc_begin(d_module,'p_ga_flag', p_ga_flag);
      PO_LOG.proc_begin(d_module,'p_conterms_exist_flag', p_conterms_exist_flag);
  END IF;
  d_pos := 10;
 -- By default return status is SUCCESS if no exception occurs
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Call the delete procedure
  IF delete_po( x_po_header_id     => p_doc_header_id
               ,x_type_lookup_code => p_doc_subtype
               ,p_skip_validation  => 'Y') THEN

        d_pos := 20;
        --delete the GA Org Assignment Records if an Global Agreement
        IF  (p_ga_flag = 'Y' )
        THEN
            d_pos := 30;
            PO_GA_ORG_ASSIGN_PVT.delete_row(p_doc_header_id);
        END IF;

        d_pos := 40;
        IF p_conterms_exist_flag  = 'Y' then
            d_pos := 50;
            -- call contracts to delete contract terms
             OKC_TERMS_UTIL_GRP.DELETE_DOC(
                     p_api_version     => 1.0,
                     p_init_msg_list   => 'F',
                     p_commit          => 'F',
                     p_doc_id          => p_doc_header_id,
                     p_doc_type        => p_doc_type || '_' || p_doc_subtype,
                     p_validate_commit =>'F',
                     x_return_status   => x_return_status,
                     x_msg_data        => l_msg_data,
                     x_msg_count       => l_msg_count);

            d_pos := 60;
            IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_module,d_pos,'x_return_status',x_return_status); PO_LOG.stmt(d_module,d_pos,'l_msg_count',l_msg_count); PO_LOG.stmt(d_module,d_pos,'l_msg_data',l_msg_data);
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               d_pos := 70;
               IF(FND_MSG_PUB.Count_Msg = 0) THEN
                   FND_MESSAGE.set_name('PO','PO_API_ERROR');
                   FND_MESSAGE.set_token('PROC_CALLER',l_api_name);
                   FND_MESSAGE.set_token('PROC_CALLED','OKC_TERMS_UTIL_GRP.delete_doc');
                   FND_MSG_PUB.add;
                   RAISE FND_API.g_exc_error;
               --else the message stack will be populated by the called procedure
               END IF;
            END IF; --x_return_status <> FND_API.G_RET_STS_SUCCESS

        END IF; -- conterms flag

  ELSE
    d_pos := 80;
    RAISE FND_API.g_exc_error;
  END IF;--PO_HEADERS_SV1.delete_po

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name||':'||d_pos);
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in'  || d_module);
    END IF;
    RAISE;
END;



-----------------------------------------------------------------------------
--Bug 12405805
--Start of Comments
--Name: delete_events_entities
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None
--Function:
--  If there are any unprocessed events associated with a document, those will be deleted.
--  If, after deleting unprocessed events, no processed events exist for the document,
--  then the entity associated with the document is deleted too.
--Parameters:
--IN:
--p_doc_entity
--  'PURCHASE_ORDER', 'RELEASE', 'REQUISITION'
--p_doc_id
-- Header id of the p_doc_entity
--OUT:

--End of Comments
-----------------------------------------------------------------------------


PROCEDURE Delete_events_entities(p_doc_entity IN VARCHAR2,
                                 p_doc_id     IN NUMBER)
IS
  l_event_source_info xla_events_pub_pkg.t_event_source_info;
  l_security_context  xla_events_pub_pkg.t_security;
  l_ledger_id         NUMBER;
  l_legal_entity_id   NUMBER;
  l_delete_event      NUMBER;
  l_org_id NUMBER;

  l_api_name              CONSTANT varchar2(30) := 'Delete_events_entities';
  l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';
  l_doc_type varchar2(20);
  l_is_encumb_on BOOLEAN;

  g_doc_type_RELEASE               CONSTANT
  PO_DOCUMENT_TYPES.document_type_code%TYPE := PO_CORE_S.g_doc_type_RELEASE;

  g_doc_type_REQUISITION            CONSTANT
  PO_DOCUMENT_TYPES.document_type_code%TYPE := PO_CORE_S.g_doc_type_REQUISITION;


  g_doc_type_PO            CONSTANT
  PO_DOCUMENT_TYPES.document_type_code%TYPE := PO_CORE_S.g_doc_type_PO;


BEGIN


     IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(l_log_head);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_entity',p_doc_entity);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_id',p_doc_id);
     END IF;



     IF ( p_doc_entity = 'RELEASE' ) THEN
        SELECT org_id INTO l_org_id FROM po_releases_all WHERE po_release_id = p_doc_id;
        l_doc_type := g_doc_type_RELEASE;
     ELSIF(p_doc_entity ='PURCHASE_ORDER' ) THEN
        SELECT org_id INTO l_org_id FROM po_headers_all WHERE po_header_id = p_doc_id;
	l_doc_type := g_doc_type_PO;
     ELSE /*p_doc_entity = 'REQUISITION' */
         SELECT org_id INTO l_org_id FROM po_requisition_headers_all WHERE requisition_header_id = p_doc_id;
           l_doc_type := g_doc_type_REQUISITION;
     END IF;



     l_progress:= '010';

     IF g_debug_stmt THEN
        PO_DEBUG.debug_var(l_log_head,l_progress,'l_org_id',l_org_id);
     END IF;

     l_progress:= '015';

     /*Event and entity deletions are done for encumbered documents only.
      Checking whether the document is created in encumbrance environment
      or not.
     */

     l_is_encumb_on := 	PO_CORE_S.is_encumbrance_on(
				 p_doc_type => l_doc_type
				,  p_org_id => l_org_id
			) ;
     IF ( NOT l_is_encumb_on ) THEN
       RETURN;
     ELSE

       IF g_debug_stmt THEN
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_is_encumb_on', 'TRUE');
       END IF;


       SELECT set_of_books_id INTO l_ledger_id
       FROM hr_operating_units hou
       WHERE hou.organization_id = l_org_id;

       l_progress:= '020';

       IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_ledger_id',l_ledger_id);
       END IF;

       l_security_context.security_id_int_1 := l_org_id;
       l_legal_entity_id := xle_utilities_grp.Get_defaultlegalcontext_ou(l_org_id);

       l_progress:= '030';

       IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_ledger_id',l_ledger_id);
       END IF;

       --Building the event source information
       l_event_source_info.source_application_id := NULL;
       l_event_source_info.application_id := 201;
       l_event_source_info.legal_entity_id := l_legal_entity_id;
       l_event_source_info.ledger_id := l_ledger_id;
       l_event_source_info.entity_type_code := p_doc_entity;
       l_event_source_info.source_id_int_1 := p_doc_id;    -- header_id

       l_progress:= '040';

       IF g_debug_stmt THEN
           PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_source_info.source_application_id',l_event_source_info.source_application_id);
           PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_source_info.application_id', l_event_source_info.application_id);
           PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_source_info.legal_entity_id', l_event_source_info.legal_entity_id);
           PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_source_info.ledger_id', l_event_source_info.ledger_id);
           PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_source_info.entity_type_code', l_event_source_info.entity_type_code);
           PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_source_info.source_id_int_1', l_event_source_info.source_id_int_1);
       END IF;

       IF( p_doc_entity <> 'RELEASE' ) then
           --Before cleaning up of unwanted events, cleaning the PO_BC_DISTRIBUTIONS too
           DELETE FROM po_bc_distributions WHERE header_id = p_doc_id
           AND APPLIED_TO_ENTITY_CODE  =  p_doc_entity
           AND ae_event_id IN (SELECT event_id FROM xla_events WHERE event_status_code = 'U' AND process_status_code IN ('I', 'D'));
       else
           --Before cleaning up of unwanted events, cleaning the PO_BC_DISTRIBUTIONS too
           DELETE FROM po_bc_distributions WHERE po_release_id = p_doc_id
           AND APPLIED_TO_ENTITY_CODE  =  p_doc_entity
           AND ae_event_id IN (SELECT event_id FROM xla_events WHERE event_status_code = 'U' AND process_status_code IN ('I', 'D'));
       END IF;

       begin
            IF (xla_events_pub_pkg.event_exists(p_event_source_info      => l_event_source_info,
                                         p_valuation_method => NULL,
                                         p_security_context => l_security_context,
                                         p_event_status_code => 'U'
                                       ) ) THEN

              l_delete_event :=     xla_events_pub_pkg.delete_events(p_event_source_info      => l_event_source_info,
                                         p_valuation_method => NULL,
                                         p_security_context => l_security_context) ;
          END if;
       EXCEPTION
         WHEN OTHERS THEN
            IF g_debug_stmt THEN
              PO_DEBUG.debug_var(l_log_head,l_progress,'Exception of event_exists, delete_event',sqlerrm);
            END IF;
         NULL;
       END;


       begin
          l_delete_event := xla_events_pub_pkg.Delete_entity(
                           p_source_info      => l_event_source_info,
                           p_valuation_method => NULL,
                           p_security_context => l_security_context);

        EXCEPTION
        WHEN OTHERS THEN
          IF g_debug_stmt THEN
            PO_DEBUG.debug_var(l_log_head,l_progress,'Exception of delete_entity',sqlerrm);
          END IF;
         NULL;
        END;
     END IF;

 EXCEPTION
   WHEN OTHERS THEN
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'Exception Block of Delete_Events_entities',sqlerrm);
      END IF;

  RAISE;
END delete_events_entities;


--<HTML Agreements R12 END>
END PO_HEADERS_SV1;

/
