--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_CONTROL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_CONTROL_PVT" AS
/* $Header: POXVDCOB.pls 120.34.12010000.45 2014/12/22 05:41:33 linlilin ship $ */

--< Bug 3194665 Start >
-- Refactored debugging
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

-- Moved table type declaration to spec file
--< Bug 3194665 End >

g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';
g_approval_initiated_flag BOOLEAN := FALSE;
g_cancel_flag_reset_flag BOOLEAN := FALSE;
/**
 * Private Procedure: lock_doc_row
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list
 * Effects: Locks the row with ID p_doc_id for this document. Appends to API
 *   message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if successfully locked row
 *                     FND_API.G_RET_STS_ERROR if lock failed
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE lock_doc_row
   (p_api_version    IN   NUMBER,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_id         IN   NUMBER)
IS

l_api_name CONSTANT VARCHAR2(30) := 'lock_doc_row';
l_api_version CONSTANT NUMBER := 1.0;
l_lock_row VARCHAR2(30);
RESOURCE_BUSY exception;
pragma exception_init (RESOURCE_BUSY, -54 ); --<HTML Agreements R12>
BEGIN
    -- Start standard API initialization
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                       ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
        END IF;
    END IF;


    IF (p_doc_type IN ('PO','PA')) THEN
        SELECT 'Lock header'
          INTO l_lock_row
          FROM po_headers poh
         WHERE poh.po_header_id = p_doc_id
           FOR UPDATE NOWAIT;
    ELSIF (p_doc_type = 'RELEASE') THEN
        SELECT 'Lock release'
          INTO l_lock_row
          FROM po_releases por
         WHERE por.po_release_id = p_doc_id
           FOR UPDATE NOWAIT;
    ELSIF (p_doc_type = 'REQUISITION') THEN
        SELECT 'Lock req'
          INTO l_lock_row
          FROM po_requisition_headers porh
         WHERE porh.requisition_header_id = p_doc_id
           FOR UPDATE NOWAIT;
    ELSE
        -- This document type is not supported
        FND_MESSAGE.set_name('PO','PO_INVALID_DOC_TYPE');
        FND_MESSAGE.set_token('TYPE',p_doc_type);
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix || l_api_name
                            || '.invalid_doc_type', FALSE);
            END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;  --<if p_doc_type ...>

EXCEPTION
   --<HTML Agreements R12 Start>
   --Handling deadlock with proper error message
    WHEN RESOURCE_BUSY THEN
        x_return_status := FND_API.g_ret_sts_error;
        FND_MESSAGE.set_name('PO','PO_ALL_CANNOT_RESERVE_RECORD');
        FND_MSG_PUB.add;
   --<HTML Agreements R12 End>
    WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
        x_return_status := FND_API.g_ret_sts_error;
        FND_MESSAGE.set_name('PO','PO_CONTROL_LOCK_FAILED');
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.lock_failed', FALSE);
            END IF;
        END IF;
        FND_MSG_PUB.add;
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END lock_doc_row;





--------------------------------------------------------------------------------
--<Bug 14387025 :Cancel Refactoring Project
--Start of Comments
--Name: do_approve_on_cancel
--Function:
--  called after the successful cancel action
--  Approve the document if the document's current status is Requires Reapproval
--  This will be called if p_launch_approval_flag is 'Y'
--  And the docuemnts original status was 'Approved'
--  These checks are handled in the caller of this routine
--Parameters:
--IN:
-- p_doc_type
-- p_doc_subtype
-- p_doc_id
-- p_communication_method_option
-- p_communication_method_value
-- p_source
-- p_note_to_vendor

--
--IN OUT :
--OUT :

-- x_return_status
--     FND_API.G_RET_STS_SUCCESS if communicate action succeeds
--     FND_API.G_RET_STS_ERROR if communicate action fails
--     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------


PROCEDURE do_approve_on_cancel(
            p_doc_type                     IN VARCHAR2,
            p_doc_subtype                  IN VARCHAR2,
            p_doc_id                       IN NUMBER,
            p_communication_method_option  IN VARCHAR2,
            p_communication_method_value   IN VARCHAR2,
            p_source                       IN VARCHAR2,
            p_note_to_vendor               IN VARCHAR2,
            x_exception_msg                OUT NOCOPY VARCHAR2,
            x_return_status                OUT NOCOPY VARCHAR2
  )
  IS

    d_api_name    CONSTANT VARCHAR2(30) := 'do_approve_on_cancel';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module      CONSTANT VARCHAR2(100) := g_pkg_name|| d_api_name;
    l_progress    VARCHAR2(3)  := '000' ;

    l_auth_status   po_headers.authorization_status%TYPE;
    l_sub_check_status VARCHAR2(1);
    l_online_report_id        NUMBER;
    l_check_asl  BOOLEAN;
    l_approval_path_id NUMBER;



  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    IF g_debug_stmt THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        PO_DEBUG.debug_begin(d_module);
        PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_type', p_doc_type);
        PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
        PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_id', p_doc_id);
        PO_DEBUG.debug_var(d_module, l_progress, 'p_communication_method_value', p_communication_method_value);
        PO_DEBUG.debug_var(d_module, l_progress, 'p_communication_method_option', p_communication_method_option);
        PO_DEBUG.debug_var(d_module, l_progress, 'p_source', p_source);

      END IF;
    END IF;

    IF  p_doc_subtype in ('BLANKET', 'STANDARD') THEN
      l_check_asl := TRUE;
    ELSE
      l_check_asl := FALSE;

    END IF ;

    IF g_debug_stmt THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'l_check_asl', l_check_asl);
      END IF;
    END IF;

    BEGIN

      IF  p_doc_type <> 'RELEASE' THEN

        l_progress :='001';

        SELECT authorization_status
        INTO   l_auth_status
        FROM   po_headers_all
        WHERE  po_header_id=p_doc_id;

      ELSE

        l_progress :='002';

        SELECT authorization_status
        INTO   l_auth_status
        FROM   po_releases_all
        WHERE  po_release_id=p_doc_id;
      END IF;

    EXCEPTION
      WHEN No_Data_Found THEN
        l_auth_status:=NULL;
      WHEN OTHERS THEN
        RAISE;
    END;

    IF g_debug_stmt THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'l_auth_status', l_auth_status);
      END IF;
    END IF;

    l_progress :='003';

    IF l_auth_status = po_document_action_pvt.g_doc_status_REAPPROVAL THEN

      PO_DOCUMENT_CHECKS_GRP.po_submission_check(
        p_api_version   	=> 1.0,
        p_action_requested  => 'DOC_SUBMISSION_CHECK',
        p_document_type   	=> p_doc_type,
        p_document_subtype  => p_doc_subtype,
        p_document_id   	  => p_doc_id,
        p_check_asl   		  => l_check_asl,
        x_return_status   	=> x_return_status,
        x_sub_check_status  => l_sub_check_status,
        x_msg_data    		  => x_exception_msg,
        x_online_report_id  => l_online_report_id
      );

      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          PO_DEBUG.debug_var(d_module, l_progress, 'l_online_report_id', l_online_report_id);
          PO_DEBUG.debug_var(d_module, l_progress, 'l_sub_check_status', l_sub_check_status);
          PO_DEBUG.debug_var(d_module, l_progress, 'x_exception_msg', x_exception_msg);
        END IF;
      END IF;


      l_progress :='004';

      --Add all the messages to the message list
      IF x_return_status =FND_API.G_RET_STS_SUCCESS
         AND l_sub_check_status = FND_API.G_RET_STS_ERROR
         AND l_online_report_id IS NOT NULL THEN

        PO_Document_Control_PVT.add_online_report_msgs(
          p_api_version      => 1.0
         ,p_init_msg_list    => FND_API.G_FALSE
         ,x_return_status    => x_return_status
         ,p_online_report_id => l_online_report_id);

        RAISE FND_API.g_exc_error;
      END IF;

      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;



      l_progress := '005' ;

      SELECT podt.default_approval_path_id
      INTO   l_approval_path_id
      FROM   po_document_types podt
      WHERE  podt.document_type_code   = p_doc_type
             AND podt.document_subtype = p_doc_subtype;

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'l_approval_path_id', l_approval_path_id);
      END IF;

      l_progress :='006';

      PO_DOCUMENT_ACTION_PVT.do_approve(
        p_document_id       => p_doc_id,
        p_document_type     => p_doc_type,
        p_document_subtype  => p_doc_subtype,
        p_note              => p_note_to_vendor,
        p_approval_path_id  => l_approval_path_id,
        x_return_status     => x_return_status,
        x_exception_msg     => x_exception_msg
      );

      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

      g_approval_initiated_flag := TRUE;


      END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);


    WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END do_approve_on_cancel;

---------------------------------------------------------------------------
--Start of Comments
--Name: control_document
--Pre-reqs:
--  FND_MSG_PUB has been initialized if p_init_msg_list is false.
--Modifies:
--  All columns related to the control action, and WHO columns.
--  PO_ONLINE_REPORT_TEXT.
--  FND_MSG_PUB.
--Locks:
--  Document at header level, and at entity level(s) specified.
--Function:
--  Performs the control action p_action on the specified document. Currently,
--  only the 'CANCEL' action is supported. If the control action was
--  successful, the document will be updated at the specified entity level.
--  Executes at shipment level if p_doc_id, p_doc_line_id, and
--  p_doc_line_loc_id are not NULL. Executes at line level if only p_doc_id
--  and p_doc_line_id are not NULL. Executes at header level if only p_doc_id
--  is not NULL. The document will be printed if it is a PO, PA, or RELEASE,
--  and the p_print_flag is 'Y'. All changes will be committed upon success if
--  p_commit is FND_API.G_TRUE. Appends to FND_MSG_PUB message list on error
--Parameters:
--IN:
--p_api_version
--p_init_msg_list
--p_commit
--p_doc_type
--  'PO', 'PA', or 'RELEASE'.
--p_doc_subtype
--  'STANDARD', 'PLANNED', 'BLANKET', 'CONTRACT', 'SCHEDULED'.
--p_doc_id
--p_doc_line_id
--p_doc_line_loc_id
--p_source
--p_action
--  Only supports 'CANCEL' action.
--p_action_date
--p_cancel_reason
--p_cancel_reqs_flag
--  'Y' or 'N'. NULL is handled as 'N'. This value is validated against the
--  current OU's Purchasing Setup, and may be overridden.
--p_print_flag
--  'Y' or 'N'. NULL is handled as 'N'.
--p_note_to_vendor
--p_communication_method_option
--  Communicattion Method to be used
--p_communication_method_value
--  Email Address or Fax Number
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - on success
--  FND_API.g_ret_sts_error - expected error
--  FND_API.g_ret_sts_unexp_error - unexpected error
--Testing:
--End of Comments
---------------------------------------------------------------------------

PROCEDURE control_document
   (p_api_version           IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    x_return_status         OUT  NOCOPY VARCHAR2,
    p_doc_type              IN   VARCHAR2,
    p_doc_subtype           IN   VARCHAR2,
    p_doc_id                IN   NUMBER,
    p_doc_line_id           IN   NUMBER,
    p_doc_line_loc_id       IN   NUMBER,
    p_source                IN   VARCHAR2,
    p_action                IN   VARCHAR2,
    p_action_date           IN   DATE,
    p_cancel_reason         IN   VARCHAR2,
    p_cancel_reqs_flag      IN   VARCHAR2,
    p_print_flag            IN   VARCHAR2,
    p_note_to_vendor        IN   VARCHAR2,
    p_use_gldate            IN   VARCHAR2,  -- <ENCUMBRANCE FPJ>
    p_launch_approvals_flag IN   VARCHAR2 := 'Y', -- <CancelPO FPJ>
    p_communication_method_option  IN   VARCHAR2 , --<HTML Agreements R12>
    p_communication_method_value   IN   VARCHAR2,  --<HTML Agreements R12>
    p_online_report_id  OUT NOCOPY NUMBER, -- Bug 8831247
    p_caller                IN   VARCHAR2    --Bug	6603493
    )
IS

    l_api_name CONSTANT VARCHAR2(30) := 'control_document';
    l_api_version CONSTANT NUMBER := 1.0;
    l_progress VARCHAR2(3) :='000';

    d_module      CONSTANT VARCHAR2(100) := g_pkg_name|| l_api_name;

    l_msg_data VARCHAR2(2000);
    l_msg_count NUMBER;
    l_old_auth_status   po_headers.authorization_status%TYPE; --Bug5142892
    -- <Bug 14207546 :Cancel Refactoring Project>
    l_entity_dtl_rec_tbl     po_document_action_pvt.entity_dtl_rec_type_tbl;
    l_exc_msg                 VARCHAR2(2000);
    l_return_code            VARCHAR2(25);
    l_communication_method_option VARCHAR2(30);
    l_communication_method_value  VARCHAR2(2000); --Bug 15984307



BEGIN
    -- Start standard API initialization
    SAVEPOINT control_document_PVT;
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          PO_DEBUG.debug_begin(d_module);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_commit', p_commit);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_type', p_doc_type);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_id', p_doc_id);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_line_id', p_doc_line_id);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_line_loc_id', p_doc_line_loc_id);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_source', p_source);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_action', p_action);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_action_date', p_action_date);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_cancel_reason', p_cancel_reason);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_cancel_reqs_flag', p_cancel_reqs_flag);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_print_flag', p_print_flag);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_note_to_vendor', p_note_to_vendor);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_use_gldate', p_use_gldate);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_launch_approvals_flag', p_launch_approvals_flag);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_caller', p_caller);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_communication_method_value', p_communication_method_value);
          PO_DEBUG.debug_var(d_module, l_progress, 'p_communication_method_option', p_communication_method_option);

          END IF;
        END IF;


      x_return_status := FND_API.g_ret_sts_success;
      l_communication_method_option :=p_communication_method_option;
      l_communication_method_value :=p_communication_method_value;


      --Resetting the global variables which keep track of whether
      --approval is submitted
      --g_approval_initiated_flag flag will only be
      --be toggled if the document is submitted for approval below.
       g_approval_initiated_flag := FALSE;


      BEGIN
        IF  p_doc_type <> 'RELEASE' THEN

          l_progress :='001';

          SELECT authorization_status
          INTO   l_old_auth_status
          FROM   po_headers_all
          WHERE  po_header_id=p_doc_id;

        ELSE

          l_progress :='002';

          SELECT authorization_status
          INTO   l_old_auth_status
          FROM   po_releases_all
          WHERE  po_release_id=p_doc_id;
        END IF;

      EXCEPTION
        WHEN No_Data_Found THEN
          l_old_auth_status:=NULL;
        WHEN OTHERS THEN
          RAISE;
      END;

      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          PO_DEBUG.debug_var(d_module, l_progress, 'l_old_auth_status', l_old_auth_status);
        END IF;
       END IF;


      l_progress :='003';

    IF (p_action = 'CANCEL') THEN

  -- <Bug 14207546 :Cancel Refactoring Project Starts>
        l_entity_dtl_rec_tbl :=  po_document_action_pvt.entity_dtl_rec_type_tbl();
        l_entity_dtl_rec_tbl.extend;
        l_entity_dtl_rec_tbl(1).doc_id :=p_doc_id;
        l_entity_dtl_rec_tbl(1).document_type :=p_doc_type;
        l_entity_dtl_rec_tbl(1).document_subtype :=p_doc_subtype;

        IF p_doc_line_loc_id IS NOT NULL THEN
          l_entity_dtl_rec_tbl(1).entity_level :=PO_Document_Cancel_PVT.c_entity_level_SHIPMENT;
          l_entity_dtl_rec_tbl(1).entity_id    := p_doc_line_loc_id;

        ELSIF p_doc_line_id IS NOT NULL THEN
          l_entity_dtl_rec_tbl(1).entity_level :=PO_Document_Cancel_PVT.c_entity_level_LINE;
          l_entity_dtl_rec_tbl(1).entity_id    := p_doc_line_id;

        ELSE
          l_entity_dtl_rec_tbl(1).entity_level :=PO_Document_Cancel_PVT.c_entity_level_HEADER;
          l_entity_dtl_rec_tbl(1).entity_id    := p_doc_id;
        END IF;


        l_entity_dtl_rec_tbl(1).entity_action_date :=p_action_date;
        l_entity_dtl_rec_tbl(1).process_entity_flag :='Y';
        l_entity_dtl_rec_tbl(1).recreate_demand_flag :='N';



        PO_DOCUMENT_ACTION_PVT.do_cancel(
          p_entity_dtl_rec               => l_entity_dtl_rec_tbl,
          p_reason                       => p_cancel_reason,
          p_action                       => PO_DOCUMENT_ACTION_PVT.g_doc_action_CANCEL,
          p_action_date                  => p_action_date,
          p_use_gl_date                  => p_use_gldate,
          p_cancel_reqs_flag             => p_cancel_reqs_flag,
          p_note_to_vendor               => p_note_to_vendor,
          p_caller                       => p_source,
          x_online_report_id             => p_online_report_id,
          x_return_status                => x_return_status,
          x_exception_msg                => l_exc_msg,
          x_return_code                  => l_return_code);



        IF g_debug_stmt THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
            PO_DEBUG.debug_var(d_module,l_progress,'l_return_code',l_return_code);
            PO_DEBUG.debug_var(d_module,l_progress,'x_return_status',x_return_status);
            PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
          END IF;
        END IF;

        -- If the procedure does not complete successfully raise the
        -- appropriate exception
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.g_exc_error;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;


        l_progress :='004';

        --Add all the messages to the message list
        IF l_return_code ='F' AND p_online_report_id IS NOT NULL THEN
          PO_Document_Control_PVT.add_online_report_msgs(
            p_api_version      => 1.0
           ,p_init_msg_list    => FND_API.G_FALSE
           ,x_return_status    => x_return_status
           ,p_online_report_id => p_online_report_id);

          RAISE FND_API.g_exc_error;
        END IF;

        l_progress :='005';

    /* Bug 19077847(18940353) :
       Approve the Document after Cancel action
       1) i.e. When Cancel is done at Header Level(Summary/Details Page)
       -- This is done in do_cancel itself

       2) Or when Line/Shipment is canceled from BWC Summary
         -- [(p_launch_approvals_flag  = 'Y' AND (p_source ='PO_DOCUMENT_CANCEL_PVT.c_HTML_CONTROL_ACTION'))]

        3) Or When Line/Shipment is canceled from Integration API and the p_launch_approvals_flag
         is Y and the document was in approved status before
         -- [(p_launch_approvals_flag  = 'Y' AND (l_old_auth_status ='APPROVED'))]
      */
        IF (p_launch_approvals_flag  = 'Y'
            AND (l_old_auth_status ='APPROVED'
                 OR p_source =PO_DOCUMENT_CANCEL_PVT.c_HTML_CONTROL_ACTION) )THEN

          do_approve_on_cancel(
            p_doc_type                    => p_doc_type,
            p_doc_subtype                 => p_doc_subtype,
            p_doc_id                      => p_doc_id,
            p_communication_method_option => p_communication_method_option,
            p_communication_method_value  => p_communication_method_value,
            p_note_to_vendor              => p_note_to_vendor,
            p_source                      => p_source,
            x_exception_msg               => l_exc_msg,
            x_return_status               => x_return_status

           );

           IF (x_return_status = FND_API.g_ret_sts_error) THEN
                RAISE FND_API.g_exc_error;
            ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
                RAISE FND_API.g_exc_unexpected_error;
            END IF;

        END IF;
        -- Block modified for Bug 19077847(18940353) ends

        l_progress :='006';

        -- Bug 14271696 :Cancel Refactoring Project <Communicate>
        -- If the Cancel action is successful
        -- Communicate the same to the supplier
        IF p_print_flag ='Y' THEN
          l_communication_method_option := 'PRINT';
          l_communication_method_value :=NULL;
        END IF;

/*  Bug 19077847(18940353) starts:
    Communicate the cancel action only when the documnet would be	approved after Cancel
     1) i.e. When Cancel is done at Header Level(Summary/Details Page)
         --  [(p_doc_line_loc_id IS NULL and p_doc_line_id IS NULL)]
     2) Or when Line/Shipment is canceled from BWC Summary
         -- [(p_launch_approvals_flag  = 'Y' AND (p_source ='PO_DOCUMENT_CANCEL_PVT.c_HTML_CONTROL_ACTION'))]
      3) Or When Line/Shipment is canceled from Integration API and the p_launch_approvals_flag
         is Y and the document was in approved status before
          -- [(p_launch_approvals_flag  = 'Y' AND (l_old_auth_status ='APPROVED'))]
*/
    IF ((p_doc_line_loc_id IS NULL and p_doc_line_id IS NULL)
         OR (p_launch_approvals_flag  = 'Y'
             AND (l_old_auth_status ='APPROVED'
	          OR p_source =PO_DOCUMENT_CANCEL_PVT.c_HTML_CONTROL_ACTION)))THEN

        doc_communicate_oncancel(
            p_doc_type                    => p_doc_type,
            p_doc_subtype                 => p_doc_subtype,
            p_doc_id                      => p_doc_id,
            p_communication_method_option => l_communication_method_option,
            p_communication_method_value  => l_communication_method_value,
            x_return_status               => x_return_status
          );

        -- If the procedure does not complete successfully raise the
        -- appropriate exception
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.g_exc_error;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

        END IF;
        -- Block modified for Bug 19077847(18940353) ends
      ELSE

        l_progress :='007';

        FND_MESSAGE.set_name('PO','PO_CONTROL_INVALID_ACTION');
        FND_MESSAGE.set_token('ACTION',p_action);

        IF g_debug_stmt THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
              PO_DEBUG.debug_stmt(d_module,l_progress,'invalid_action');
          END IF;
        END IF;

        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;

      END IF;  --<if p_action CANCEL>

    --Bug#16839869 We should only call FTE API PO_DELREC_PVT.create_update_delrec when  doc_type  is PO or RELEASE
	IF (p_doc_type IN ('PO','RELEASE')) THEN
      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
            PO_DEBUG.debug_stmt(d_module,l_progress,'Before PO_DELREC_PVT.create_update_delrec Call');
        END IF;
      END IF;



      PO_DELREC_PVT.create_update_delrec(
        p_api_version   => 1.0,
                             x_return_status => x_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data,
        p_action        => 'CANCEL',
                             p_doc_type      => p_doc_type,
        p_doc_subtype   => p_doc_subtype,
        p_doc_id        => p_doc_id,
        p_line_id       => p_doc_line_id,
        p_line_location_id => p_doc_line_loc_id);

      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
            PO_DEBUG.debug_stmt(d_module,l_progress,'After PO_DELREC_PVT.create_update_delrec Call');
            PO_DEBUG.debug_var(d_module,l_progress,'x_return_status',x_return_status);

           END IF;
        END IF;
	END IF;

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    --Standard API check of p_commit
    IF FND_API.to_boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
EXCEPTION
    WHEN FND_API.g_exc_error THEN
        ROLLBACK TO control_document_PVT;
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        ROLLBACK TO control_document_PVT;
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        ROLLBACK TO control_document_PVT;
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END control_document;


/**
 * Public Procedure: init_action_date
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list.
 * Effects: Checks if CBC is enabled, storing the result in x_cbc_enabled. If
 *   x_action_date is NULL, then sets it to a valid CBC accounting date if CBC
 *   is enabled. Otherwise, sets it to the current system date. Appends message
 *   to API message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if initialization is successful
 *                     FND_API.G_RET_STS_ERROR if error initializing action date
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
 *   x_action_date - The action date, truncated.
 *   x_cbc_enabled - 'Y' if CBC is enabled, 'N' otherwise.
 */
PROCEDURE init_action_date
   (p_api_version    IN     NUMBER,
    p_init_msg_list  IN     VARCHAR2,
    x_return_status  OUT    NOCOPY VARCHAR2,
    p_doc_type       IN     PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype    IN     PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id         IN     NUMBER,
    x_action_date    IN OUT NOCOPY DATE,
    x_cbc_enabled    OUT    NOCOPY VARCHAR2)
IS

l_api_name CONSTANT VARCHAR2(30) := 'init_action_date';
l_api_version CONSTANT NUMBER := 1.0;
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);

BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                       ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
        END IF;
    END IF;

    IGC_CBC_PO_GRP.is_cbc_enabled
                         ( p_api_version      => 1.0,
                           p_init_msg_list    => FND_API.G_FALSE,
                           p_commit           => FND_API.G_FALSE,
                           p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                           x_return_status    => x_return_status,
                           x_msg_count        => l_msg_count,
                           x_msg_data         => l_msg_data,
                           x_cbc_enabled      => x_cbc_enabled );
    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_module_prefix || l_api_name ||
                       '.is_cbc_enabled', 'Is CBC enabled: ' ||
                      NVL(x_cbc_enabled,'N'));
        END IF;
    END IF;

    -- Set the action date if it was not passed in
    IF (x_action_date IS NULL) THEN

        get_action_date( p_api_version   => 1.0,
                         p_init_msg_list => FND_API.G_FALSE,
                         x_return_status => x_return_status,
                         p_doc_type      => p_doc_type,
                         p_doc_subtype   => p_doc_subtype,
                         p_doc_id        => p_doc_id,
                         p_cbc_enabled   => x_cbc_enabled,
                         x_action_date   => x_action_date );
        IF (x_return_status = FND_API.g_ret_sts_error) THEN
            RAISE FND_API.g_exc_error;
        ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;

    ELSE

        x_action_date := TRUNC(x_action_date);

    END IF;  --<if x_action_date is null ...>

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END init_action_date;


/**
 * Public Procedure: get_action_date
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list
 * Effects: If p_cbc_enabled is 'Y', then sets x_action_date to a valid CBC
 *   accounting date for this document. Otherwise, sets x_action_date to
 *   the current system date. Appends to API message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if date is set successfully
 *                     FND_API.G_RET_STS_ERROR if error occurs getting date
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 *   x_action_date - A truncated date that is either a valid CBC accounting date
 *                   or the current system date.
 */
PROCEDURE get_action_date
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype    IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id         IN   NUMBER,
    p_cbc_enabled    IN   VARCHAR2,
    x_action_date    OUT  NOCOPY DATE)
IS

l_api_name CONSTANT VARCHAR2(30) := 'get_action_date';
l_api_version CONSTANT NUMBER := 1.0;
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);

BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                       ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
        END IF;
    END IF;

    -- Initialize date to be null
    x_action_date := NULL;

    IF (p_cbc_enabled = 'Y') THEN

        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
              FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix||l_api_name
                         ||'.get_cbc_date', 'IGC_CBC_PO_GRP.get_cbc_acct_date');
            END IF;
        END IF;

        IGC_CBC_PO_GRP.get_cbc_acct_date
                        ( p_api_version       => 1.0,
                          p_init_msg_list     => FND_API.G_FALSE,
                          p_commit            => FND_API.G_FALSE,
                          p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                          x_return_status     => x_return_status,
                          x_msg_count         => l_msg_count,
                          x_msg_data          => l_msg_data,
                          p_document_id       => p_doc_id,
                          p_document_type     => p_doc_type,
                          p_document_sub_type => p_doc_subtype,
                          p_default           => 'Y',
                          x_cbc_acct_date     => x_action_date );
        IF (x_return_status = FND_API.g_ret_sts_error) THEN
            RAISE FND_API.g_exc_error;
        ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;

        x_action_date := TRUNC(x_action_date);

    END IF;  --<if p_cbc_enabled ...>

    IF (x_action_date IS NULL) THEN
        x_action_date := TRUNC(SYSDATE);
    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
        x_action_date := TRUNC(SYSDATE);
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        x_action_date := TRUNC(SYSDATE);
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END get_action_date;


/**
 * Public Procedure: val_action_date
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list
 * Effects: If encumbrance is on, checks that p_date lies in an open GL period
 *   for requisitions or for cancel or finally closing a purchase order. Also
 *   checks that p_date is a valid CBC accounting date for cancel or finally
 *   close actions if CBC is enabled. Appends to API message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if validation succeeds
 *                     FND_API.G_RET_STS_ERROR if validation fails
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE val_action_date
   (p_api_version          IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2,
    x_return_status        OUT  NOCOPY VARCHAR2,
    p_doc_type             IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype          IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id               IN   NUMBER,
    p_action               IN   VARCHAR2,
    p_action_date          IN   DATE,
    p_cbc_enabled          IN   VARCHAR2,
    p_po_encumbrance_flag  IN   VARCHAR2,
    p_req_encumbrance_flag IN   VARCHAR2,
    p_skip_valid_cbc_acct_date IN   VARCHAR2)
IS

l_api_name CONSTANT VARCHAR2(30) := 'val_action_date';
l_api_version CONSTANT NUMBER := 1.0;
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_po_enc_req_flag VARCHAR2(1) :='N'; --bug 17014798

BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                  '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                  ', ID: ' || NVL(TO_CHAR(p_doc_id),'null') ||
                  ', Date: ' || NVL(TO_CHAR(p_action_date,'DD-MON-RR'),'null'));
        END IF;
    END IF;

    /**bug 17014798 ,add one more condition before PA GL date validation*/

    IF p_po_encumbrance_flag = 'Y' then
	  IF p_doc_type ='PA' then
        begin
          select nvl(encumbrance_required_flag,'N')
          into l_po_enc_req_flag
          from po_headers_all
          where po_header_id=p_doc_id ;
        EXCEPTION
        when no_data_found then
          IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
          END IF;
          l_po_enc_req_flag:='N';
        end;
	  ELSIF(p_doc_type IN ('PO','RELEASE')) THEN
	    l_po_enc_req_flag:='Y';
	  END IF;
    end if;

    IF (p_doc_type = 'REQUISITION' AND p_req_encumbrance_flag = 'Y') OR
       ((p_doc_type IN ('PO','PA','RELEASE')) AND
        (p_action IN ('CANCEL','FINALLY CLOSE')) AND
        (l_po_enc_req_flag = 'Y'))
    THEN
    /**bug 17014798 end*/

        IF NOT in_open_gl_period( p_api_version   => 1.0,
                                  p_init_msg_list => FND_API.G_FALSE,
                                  x_return_status => x_return_status,
                                  p_date          => p_action_date )
        THEN
            IF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
                RAISE FND_API.g_exc_unexpected_error;
            END IF;

            -- No error, so add a message saying open gl period check failed
            FND_MESSAGE.set_name('PO','PO_INV_CR_INVALID_GL_PERIOD');
            FND_MESSAGE.set_token('GL_DATE',
                                  TO_CHAR(p_action_date,'DD-MON-YYYY'));
            IF (g_debug_stmt) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
                  FND_LOG.message(FND_LOG.level_error, g_module_prefix ||
                                l_api_name || '.gl_period', FALSE);
                END IF;
            END IF;
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;
        END IF;  -- if not in_open_gl_period ...

    END IF;  -- if p_doc_type ...

    --As CBC not supported from html pages, we would skip the cbc date validation
    --If the procedure is invoked by HTML pages.
    --See Bug#4569120

    /* Bug 6507195 : PO CBC Integration
    Only when the Parameter P_SKIP_VALID_CBC_ACCT_DATE is FND_API.G_TRUE, we should skip validation
    Hence Changed condition from FND_API.G_TRUE to FND_API.G_FALSE
    */

    IF(nvl(p_skip_valid_cbc_acct_date, FND_API.G_FALSE) = FND_API.G_FALSE) THEN
      -- Validate with CBC accounting date if enabled for cancel or finally close
      IF (p_cbc_enabled = 'Y') AND (p_action IN ('CANCEL','FINALLY CLOSE')) THEN

          IF (g_debug_stmt) THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
                FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix||l_api_name
                        || '.val_cbc_date', 'IGC_CBC_PO_GRP.valid_cbc_acct_date');
              END IF;
          END IF;

          IGC_CBC_PO_GRP.valid_cbc_acct_date
                          ( p_api_version       => 1.0,
                            p_init_msg_list     => FND_API.G_FALSE,
                            p_commit            => FND_API.G_FALSE,
                            p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                            x_return_status     => x_return_status,
                            x_msg_count         => l_msg_count,
                            x_msg_data          => l_msg_data,
                            p_document_id       => p_doc_id,
                            p_document_type     => p_doc_type,
                            p_document_sub_type => p_doc_subtype,
                            p_cbc_acct_date     => p_action_date );
          IF (x_return_status = FND_API.g_ret_sts_error) THEN
              RAISE FND_API.g_exc_error;
          ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
              RAISE FND_API.g_exc_unexpected_error;
          END IF;

      END IF;  -- if p_cbc_enabled ...
    END IF;--p_skip_valid_cbc_acct_date = FND_API.G_FALSE

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END val_action_date;

--< Bug 3194665 > Changed signature.
--------------------------------------------------------------------------------
--Start of Comments
--Name: get_header_actions
--Pre-reqs:
--  None.
--Modifies:
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Retrieves all allowable control actions that p_agent_id can perform on the
--  document at header level. Appends to API msg list upon unexpected error.
--Parameters:
--IN:
--p_doc_subtype
--p_doc_id
--  The document header ID.
--p_agent_id
--  The person attempting to perform the control action. If this ID is NULL,
--  then document security checks are skipped.
--OUT:
--x_lookup_code_tbl
--  Table storing the lookup_code values for each allowable control action.
--  These elements are in sync with the elements in x_displayed_field_tbl.
--x_displayed_field_tbl
--  Table storing the displayed_field values for each allowable control action.
--  These elements are in sync with the elements in x_lookup_code_tbl.
--x_return_status
--  FND_API.g_ret_sts_success     - if 1 or more actions were found
--  FND_API.g_ret_sts_error       - if no control actions were found
--  FND_API.g_ret_sts_unexp_error - if unexpected error occurs
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_header_actions
    ( p_doc_subtype         IN   VARCHAR2
    , p_doc_id              IN   NUMBER
    , p_agent_id            IN   NUMBER
    , x_lookup_code_tbl     OUT  NOCOPY g_lookup_code_tbl_type
    , x_displayed_field_tbl OUT  NOCOPY g_displayed_field_tbl_type
    , x_return_status       OUT  NOCOPY VARCHAR2
    , p_mode                IN   VARCHAR2 --<HTML Agreements R12>
    )
IS

l_api_name CONSTANT VARCHAR2(30) := 'get_header_actions';

-- bug5353337
-- Improve cursor performance by using _ALL tables


--< Bug 3194665 Start >
-- Removed unnecessary std api var.
-- Now select displayed field in cursor.
CURSOR l_get_actions_csr IS
    -- SQL What: Querying for control actions
    -- SQL Why: Find all allowable header level control actions for this doc
    SELECT polc.displayed_field,
           polc.lookup_code
      FROM po_lookup_codes polc,
           po_headers poh
     WHERE poh.po_header_id = p_doc_id
       AND polc.lookup_type = 'CONTROL ACTIONS'
       AND NVL(poh.closed_code, 'OPEN') <> 'FINALLY CLOSED'
       AND (   NVL(poh.cancel_flag, 'N') IN ('N','I')
            OR polc.lookup_code = 'FINALLY CLOSE'
           )  /** <Encumbrance FPJ> FC of cancelled PO **/
           /** Bug 3231524 Removed restrictions for drop ship PO. **/
       AND (   (    (   (    polc.lookup_code = 'FREEZE'
                         AND NVL(poh.frozen_flag, 'N') = 'N'
                        )
                     OR (    polc.lookup_code = 'UNFREEZE'
                         AND poh.frozen_flag = 'Y'
                        )
                    )
                AND NVL(poh.user_hold_flag, 'N') = 'N'
                AND NVL(poh.authorization_status, 'INCOMPLETE') = 'APPROVED'
                AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
               )
            OR (    polc.lookup_code = 'HOLD'
                AND NVL(poh.user_hold_flag, 'N') = 'N'
                AND NVL(poh.frozen_flag, 'N') = 'N'
                AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
               )
            OR (    polc.lookup_code = 'RELEASE HOLD'
                AND poh.user_hold_flag = 'Y'
                AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
               )
            OR (    polc.lookup_code = 'CANCEL PO'
                AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                AND NVL(poh.user_hold_flag, 'N') = 'N'
                AND NVL(poh.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED')
                AND poh.approved_date IS NOT NULL
               -- bug 12347143
                AND NVL(poh.authorization_status, 'INCOMPLETE') NOT IN
                          /* <CancelPO FPJ> 'REQUIRES REAPPROVAL', */
                          ('IN PROCESS', 'PRE-APPROVED', 'INCOMPLETE')
                -- AND NVL(poh.conterms_exist_flag, 'N') <> 'Y'  /* <CancelPO FPJ> */ --Bug 7309989
                AND (   (p_agent_id IS NULL)
                     OR (poh.agent_id = p_agent_id)
                     OR EXISTS (SELECT 'security_level is full'
                                  FROM po_document_types podt
                                 WHERE podt.document_type_code IN ('PO', 'PA')
                                   AND podt.document_subtype = p_doc_subtype
                                   AND podt.access_level_code = 'FULL')
                    )
               )
            OR (    poh.approved_flag = 'Y'
                AND (   (    polc.lookup_code = 'CLOSE'
                         AND NVL(poh.closed_code, 'OPEN') <> 'CLOSED'
                        )
                     OR (    polc.lookup_code = 'FINALLY CLOSE'
                         AND (   (p_agent_id IS NULL)
                              OR (poh.agent_id = p_agent_id)
                              OR EXISTS (SELECT 'security_level = full'
                                           FROM po_document_types podt
                                          WHERE podt.document_type_code IN ('PO', 'PA')
                                            AND podt.document_subtype = p_doc_subtype
                                            AND podt.access_level_code = 'FULL')
                             )
                        )
                     OR (    polc.lookup_code = 'OPEN'
                         /* CONSIGNED FPI START */
                         AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'
                         AND (   (    poh.type_lookup_code IN ('BLANKET', 'CONTRACT')   /* <GC FPJ> */
                                  AND NVL(poh.closed_code, 'OPEN') <> 'OPEN'
                                 )
                              OR (    poh.type_lookup_code NOT IN ('BLANKET', 'CONTRACT')
                                  AND EXISTS (SELECT 'Ship exists not OPEN'
                                                FROM po_line_locations poll
                                               WHERE poll.po_header_id = p_doc_id
                                                 AND NVL(poll.consigned_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                                                 AND NVL(poll.closed_code, 'OPEN') <> 'OPEN')
                                 )
                             )
                        )
                        /* CONSIGNED FPI END */
                     OR (    polc.lookup_code = 'RECEIVE CLOSE'
                         AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'   /* CONSIGNED FPI */
                         AND poh.type_lookup_code NOT IN ('BLANKET', 'CONTRACT')
                         AND EXISTS (SELECT 'Ships exist  OPEN'
                                       FROM po_line_locations poll
                                      WHERE poll.po_header_id = p_doc_id
                                        AND NVL(poll.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED', 'CLOSED FOR RECEIVING'))  --Bug l
                        )
                     OR (    polc.lookup_code = 'INVOICE CLOSE'
                         AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'   /* CONSIGNED FPI */
                         AND poh.type_lookup_code NOT IN ('BLANKET', 'CONTRACT')
                         AND EXISTS(SELECT 'Ships exist OPEN'
                                      FROM po_line_locations poll
                                     WHERE poll.po_header_id = p_doc_id
                                       AND NVL(poll.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED', 'CLOSED FOR INVOICE'))   --Bug 954
                        )
                     OR (    polc.lookup_code = 'RECEIVE OPEN'
                         AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'   /* CONSIGNED FPI */
                         AND poh.type_lookup_code NOT IN ('BLANKET', 'CONTRACT')
                         AND EXISTS (SELECT 'Ships exist RCLOSED'
                                       FROM po_line_locations poll
                                      WHERE poll.po_header_id = p_doc_id
                                        AND poll.closed_code IN ('CLOSED FOR RECEIVING', 'CLOSED'))
                        )
                     OR (    polc.lookup_code = 'INVOICE OPEN'
                         AND poh.type_lookup_code NOT IN ('BLANKET', 'CONTRACT')
                         AND EXISTS (SELECT 'Ships exits IC/CLOSED'
                                       FROM po_line_locations poll
                                      WHERE poll.po_header_id = p_doc_id
                                        AND NVL(poll.consigned_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                                        AND poll.closed_code IN ('CLOSED FOR INVOICE', 'CLOSED'))
                        )
                    )
               )
           )
     ORDER BY polc.displayed_field;
--< Bug 3194665 End >

BEGIN
    --< Bug 3194665 > Removed unnecessary std api work
    x_return_status := FND_API.g_ret_sts_success;

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Subtype: ' || NVL(p_doc_subtype,'null') ||
                       ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
        END IF;
    END IF;

    OPEN l_get_actions_csr;
    --< Bug 3194665 Start >
    -- Select displayed_field and lookup_code
    FETCH l_get_actions_csr BULK COLLECT INTO x_displayed_field_tbl,
                                              x_lookup_code_tbl;

    IF (l_get_actions_csr%ROWCOUNT = 0) THEN
        -- No data found, so just return error status without a msg
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                           '.no_data_found', FALSE);
            END IF;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
    END IF;
    --< Bug 3194665 End >
    CLOSE l_get_actions_csr;

EXCEPTION
    --< Bug 3194665 > Removed unnecessary std api exception blocks
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF l_get_actions_csr%ISOPEN THEN
            CLOSE l_get_actions_csr;
        END IF;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END get_header_actions;


--< Bug 3194665 > Changed signature.
--------------------------------------------------------------------------------
--Start of Comments
--Name: get_line_actions
--Pre-reqs:
--  None.
--Modifies:
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Retrieves all allowable control actions that p_agent_id can perform on the
--  document at line level. Appends to API msg list upon unexpected error.
--Parameters:
--IN:
--p_doc_subtype
--p_doc_line_id
--  The document line ID.
--p_agent_id
--  The person attempting to perform the control action. If this ID is NULL,
--  then document security checks are skipped.
--OUT:
--x_lookup_code_tbl
--  Table storing the lookup_code values for each allowable control action.
--  These elements are in sync with the elements in x_displayed_field_tbl.
--x_displayed_field_tbl
--  Table storing the displayed_field values for each allowable control action.
--  These elements are in sync with the elements in x_lookup_code_tbl.
--x_return_status
--  FND_API.g_ret_sts_success     - if 1 or more actions were found
--  FND_API.g_ret_sts_error       - if no control actions were found
--  FND_API.g_ret_sts_unexp_error - if unexpected error occurs
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_line_actions
    ( p_doc_subtype         IN   VARCHAR2
    , p_doc_line_id         IN   NUMBER
    , p_agent_id            IN   NUMBER
    , x_lookup_code_tbl     OUT  NOCOPY g_lookup_code_tbl_type
    , x_displayed_field_tbl OUT  NOCOPY g_displayed_field_tbl_type
    , x_return_status       OUT  NOCOPY VARCHAR2
    , p_mode                IN   VARCHAR2 --<HTML Agreements R12>
    )
IS

l_api_name CONSTANT VARCHAR2(30) := 'get_line_actions';

-- bug5353337
-- Improve performance by using _ALL tables

--< Bug 3194665 Start >
-- Removed unnecessary std api var.
-- Now select displayed field in cursor.
CURSOR l_get_actions_csr IS
    -- SQL What: Querying for control actions
    -- SQL Why: Find all allowable line level control actions for this doc
    SELECT polc.displayed_field,
           polc.lookup_code
      FROM po_lookup_codes polc,
           po_lines pol,
           po_headers poh
     WHERE pol.po_line_id = p_doc_line_id
       AND pol.po_header_id = poh.po_header_id
       AND polc.lookup_type = 'CONTROL ACTIONS'
       AND NVL(pol.closed_code, 'OPEN') <> 'FINALLY CLOSED'
       AND (   NVL(pol.cancel_flag, 'N') IN ('N','I')
            OR polc.lookup_code = 'FINALLY CLOSE'
           )  /** <Encumbrance FPJ> FC of cancelled PO **/
           /** Bug 3231524 Removed restrictions for drop ship PO. **/
       AND (   (    polc.lookup_code = 'CANCEL PO LINE'
                AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                AND NVL(poh.user_hold_flag, 'N') = 'N'
                AND poh.approved_date IS NOT NULL -- bug 12347143
                AND NVL(poh.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED')
                AND NVL(poh.authorization_status, 'INCOMPLETE') NOT IN
                        /* <CancelPO FPJ> ('REQUIRES REAPPROVAL', */
                        ('INCOMPLETE', 'IN PROCESS', 'PRE-APPROVED')
                -- AND NVL(poh.conterms_exist_flag, 'N') <> 'Y'  /* <CancelPO FPJ> */ --Bug 7309989*/
                AND (   (p_agent_id IS NULL)
                     OR (poh.agent_id = p_agent_id)
                     OR EXISTS (SELECT 'security_level is full'
                                  FROM po_document_types podt
                                 WHERE podt.document_type_code IN ('PO', 'PA')
                                   AND podt.document_subtype = p_doc_subtype
                                   AND podt.access_level_code = 'FULL')
                    )
               )
            OR (    poh.approved_flag = 'Y'
                AND (   (    polc.lookup_code = 'CLOSE'
                         AND NVL(pol.closed_code, 'OPEN') <> 'CLOSED'
                        )
                     OR (    polc.lookup_code = 'FINALLY CLOSE'
                         AND (   (p_agent_id IS NULL)
                              OR (poh.agent_id = p_agent_id)
                              OR EXISTS (SELECT 'security_level is= full'
                                           FROM po_document_types podt
                                          WHERE podt.document_type_code IN ('PO', 'PA')
                                            AND podt.document_subtype = p_doc_subtype
                                            AND podt.access_level_code = 'FULL')
                             )
                        )
                     OR (    polc.lookup_code = 'OPEN'
                         AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND (   (poh.type_lookup_code = 'BLANKET')
                              OR (    poh.type_lookup_code NOT IN ('BLANKET', 'CONTRACT')
                                  AND EXISTS (SELECT 'Ships exist not OPEN'
                                                FROM po_line_locations poll
                                               WHERE poll.po_line_id = p_doc_line_id
                                                 AND NVL(poll.consigned_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                                                 AND NVL(poll.closed_code, 'OPEN') <> 'OPEN')
                                 )
                             )
                        )
                     OR (    polc.lookup_code = 'RECEIVE CLOSE'
                         AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND poh.type_lookup_code NOT IN ('BLANKET', 'CONTRACT')
                         AND EXISTS (SELECT 'Ships exist that are OPEN'
                                       FROM po_line_locations poll
                                      WHERE poll.po_line_id = p_doc_line_id
                                        AND NVL(poll.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED', 'CLOSED FOR RECEIVING'))  --Bug 5113609
                        )
                     OR (    polc.lookup_code = 'INVOICE CLOSE'
                         AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND poh.type_lookup_code NOT IN ('BLANKET', 'CONTRACT')
                         AND EXISTS (SELECT 'Ships exist OPEN'
                                       FROM po_line_locations poll
                                      WHERE poll.po_line_id = p_doc_line_id
                                        AND NVL(poll.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED', 'CLOSED FOR INVOICE'))   --Bug 5113609
                        )
                     OR (    polc.lookup_code = 'RECEIVE OPEN'
                         AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND poh.type_lookup_code NOT IN ('BLANKET', 'CONTRACT')
                         AND EXISTS (SELECT 'Ships exist RCLOSED'
                                       FROM po_line_locations poll
                                      WHERE poll.po_line_id = p_doc_line_id
                                        AND poll.closed_code IN ('CLOSED FOR RECEIVING', 'CLOSED'))
                        )
                     OR (    polc.lookup_code = 'INVOICE OPEN'
                         AND poh.type_lookup_code NOT IN ('BLANKET', 'CONTRACT')
                         AND EXISTS (SELECT 'Ships exits IC/CLOSED'
                                       FROM po_line_locations poll
                                      WHERE poll.po_line_id = p_doc_line_id
                                        AND NVL(poll.consigned_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                                        AND poll.closed_code IN ('CLOSED FOR INVOICE', 'CLOSED'))
                        )
                    )
               )
           )
     ORDER BY polc.displayed_field;--< Bug 3194665 End >

BEGIN
    --< Bug 3194665 > Removed unnecessary std api work
    x_return_status := FND_API.g_ret_sts_success;

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Subtype: ' || NVL(p_doc_subtype,'null') ||
                       ', Line ID: ' || NVL(TO_CHAR(p_doc_line_id),'null'));
        END IF;
    END IF;

    OPEN l_get_actions_csr;
    --< Bug 3194665 Start >
    -- Select displayed_field and lookup_code
    FETCH l_get_actions_csr BULK COLLECT INTO x_displayed_field_tbl,
                                              x_lookup_code_tbl;

    IF (l_get_actions_csr%ROWCOUNT = 0) THEN
        -- No data found, so just return error status without a msg
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.get_failed', FALSE);
            END IF;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
    END IF;
    --< Bug 3194665 End >

    CLOSE l_get_actions_csr;

EXCEPTION
    --< Bug 3194665 > Removed unnecessary std api exception blocks
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF l_get_actions_csr%ISOPEN THEN
            CLOSE l_get_actions_csr;
        END IF;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END get_line_actions;


--< Bug 3194665 > Changed signature.
--------------------------------------------------------------------------------
--Start of Comments
--Name: get_shipment_actions
--Pre-reqs:
--  None.
--Modifies:
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Retrieves all allowable control actions that p_agent_id can perform on the
--  document at shipment level. Appends to API msg list upon unexpected error.
--Parameters:
--IN:
--p_doc_type
--p_doc_subtype
--p_doc_line_loc_id
--  The document shipment ID.
--p_agent_id
--  The person attempting to perform the control action. If this ID is NULL,
--  then document security checks are skipped.
--OUT:
--x_lookup_code_tbl
--  Table storing the lookup_code values for each allowable control action.
--  These elements are in sync with the elements in x_displayed_field_tbl.
--x_displayed_field_tbl
--  Table storing the displayed_field values for each allowable control action.
--  These elements are in sync with the elements in x_lookup_code_tbl.
--x_return_status
--  FND_API.g_ret_sts_success     - if 1 or more actions were found
--  FND_API.g_ret_sts_error       - if no control actions were found
--  FND_API.g_ret_sts_unexp_error - if unexpected error occurs
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_shipment_actions
    ( p_doc_type            IN   VARCHAR2
    , p_doc_subtype         IN   VARCHAR2
    , p_doc_line_loc_id     IN   NUMBER
    , p_agent_id            IN   NUMBER
    , x_lookup_code_tbl     OUT  NOCOPY g_lookup_code_tbl_type
    , x_displayed_field_tbl OUT  NOCOPY g_displayed_field_tbl_type
    , x_return_status       OUT  NOCOPY VARCHAR2
    , p_mode              IN   VARCHAR2 --<HTML Agreements R12>
    )
IS

l_api_name CONSTANT VARCHAR2(30) := 'get_shipment_actions';

-- bug5353337
-- Improve performance by using _ALL tables

--< Bug 3194665 Start >
-- Removed unnecessary std api var.
-- Now select displayed field in cursor.
CURSOR l_get_actions_csr IS
    -- SQL What: Querying for control actions
    -- SQL Why: Find all allowable shipment level control actions for this doc
    SELECT polc.displayed_field,
           polc.lookup_code
      FROM po_lookup_codes polc,
           po_line_locations_all poll,
           po_headers_all poh
     WHERE poll.line_location_id = p_doc_line_loc_id
       AND poll.po_header_id = poh.po_header_id
       AND polc.lookup_type = 'CONTROL ACTIONS'
       AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
       AND (   NVL(poll.cancel_flag, 'N') IN ('N','I')
            OR polc.lookup_code = 'FINALLY CLOSE'
           )  /** <Encumbrance FPJ> FC of cancelled PO **/
       AND poll.shipment_type <> 'PRICE BREAK'  /*<bug 3323045>*/
           /** Bug 3231524 Removed restrictions for drop ship PO. **/
       AND (   (    polc.lookup_code = 'CANCEL PO SHIPMENT'
                AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                AND NVL(poh.user_hold_flag, 'N') = 'N'
                AND poh.approved_date IS NOT NULL -- bug 12347143
                AND NVL(poh.authorization_status, 'INCOMPLETE') NOT IN
                        /* <CancelPO FPJ> 'REQUIRES REAPPROVAL', */
                        ('INCOMPLETE', 'IN PROCESS', 'PRE-APPROVED')
                --<HTML Agreements R12 Start>
			/*
  			 * Bug 12334616 : Allowing the Cancel action on Po shipments even if there are contract
			 * terms associated with the PO [Partial Fix of :7309989]
			 * Condition(p_mode = 'UPDATE'  OR NVL(poh.conterms_exist_flag,'N')<> 'Y') means the cancel action on Po shipments
			 * is allowed from  the Details/Entry pages[p_mode=Update]
			 * and from summary page[p_mode=summary] only if there are no contract terms associated with the PO.
			 * So on allowing Cancel action on Po shipments even if there are contract terms associated with the PO
			 * will enable cancel action on Summary/Update page both,hence commenting the entire condition.
			 *
			 */
	             /*  AND (   p_mode = 'UPDATE'
	                    OR NVL(poh.conterms_exist_flag,'N')<> 'Y')*/
                --AND NVL(poh.conterms_exist_flag, 'N') <> 'Y'  /* <CancelPO FPJ> */
                --<HTML Agreements R12 End>
                AND NVL(poll.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED')
                AND (   (p_agent_id IS NULL)
                     OR (poh.agent_id = p_agent_id)
                     OR EXISTS (SELECT 'security_level is full'
                                  FROM po_document_types_all_b podt
                                 WHERE podt.document_type_code = p_doc_type
                                   AND podt.document_subtype = p_doc_subtype
                                   AND podt.access_level_code = 'FULL'
                                   AND podt.org_id = poh.org_id)
                    )
                --<Complex Work R12>: Can not cancel a Milestone Pay Item
                --if it has been executed against (cancel line/header instead)
                AND( NVL(poll.payment_type, 'NULL') <> 'MILESTONE'
                    OR
                     (coalesce(poll.quantity_billed, poll.amount_billed,
                                poll.quantity_financed, poll.amount_financed,
                                poll.quantity_shipped, poll.amount_shipped,
                                poll.quantity_received, poll.amount_received, 0) = 0
                     )
                   )
			    /* bug 13513989 : We cannot cancel the shipment when there is only one shipment. Adding check for same. */
				 /* Bug : 13654046 : Reverting the fix made in bug 13513989
				AND EXISTS ( SELECT poll_1.line_location_id
				             FROM po_line_locations_all poll_1
				             where poll_1.po_line_id=poll.po_line_id
					     AND poll_1.po_header_id=poll.po_header_id
                                             AND poll_1.line_location_id  <> p_doc_line_loc_id
					     AND nvl(poll_1.cancel_flag,'N') <> 'Y'
					     AND NVL(poll_1.closed_code, 'OPEN') <> 'FINALLY CLOSED'
					    ) */
               )
            OR (    poh.approved_flag = 'Y'
                AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
                AND (   (    polc.lookup_code = 'CLOSE'
                         AND NVL(poll.closed_code, 'OPEN') <> 'CLOSED'
                        )
                     OR (    polc.lookup_code = 'FINALLY CLOSE'
                         AND (   (p_agent_id IS NULL)
                              OR (poh.agent_id = p_agent_id)
                              OR EXISTS (SELECT 'security_level is full'
                                           FROM po_document_types_all_b podt
                                          WHERE podt.document_type_code = p_doc_type
                                            AND podt.document_subtype = p_doc_subtype
                                            AND podt.access_level_code = 'FULL'
                                            AND podt.org_id = poh.org_id)
                             )
                         -- <Complex Work R12 Start>: Can't FC with open recoup/retain balance.
                         AND (
                               NVL(poll.retainage_released_amount, 0) >=
                                       NVL(poll.retainage_withheld_amount, 0)
                             )
                         AND (
                                   (poll.shipment_type <> 'PREPAYMENT')
                                OR (coalesce(poll.quantity_recouped,
                                                  poll.amount_recouped, 0) >=
                                    coalesce(poll.quantity_financed,
                                                  poll.amount_financed, 0))
                             )
                         -- <Complex Work R12 End>
                        )
                     OR (    polc.lookup_code = 'OPEN'
                         AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND NVL(poll.consigned_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND NVL(poll.closed_code, 'OPEN') <> 'OPEN'
                        )
                     OR (    polc.lookup_code = 'INVOICE CLOSE'
                         --<Bug#4534587: Removed the check for consigned_consumption_flag/>
                         AND NVL(poll.closed_code, 'OPEN') NOT IN ('CLOSED', 'CLOSED FOR INVOICE')
                         AND NVL(poll.consigned_flag, 'N') <> 'Y'  --<Bug#4534587: Added Check for Consigned Shipment/>
                        )
                     OR (    polc.lookup_code = 'RECEIVE CLOSE'
                         AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND NVL(poll.closed_code, 'OPEN') NOT IN ('CLOSED', 'CLOSED FOR RECEIVING')
                        )
                     OR (    polc.lookup_code = 'INVOICE OPEN'
                         AND NVL(poll.consigned_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND NVL(poll.closed_code, 'OPEN') NOT IN ('OPEN', 'OPEN FOR INVOICE', 'CLOSED FOR RECEIVING')
                        )
                     OR (    polc.lookup_code = 'RECEIVE OPEN'
                         AND NVL(poh.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND NVL(poll.closed_code, 'OPEN') NOT IN ('OPEN', 'OPEN FOR RECEIVING', 'CLOSED FOR INVOICE')
                        )
                    )
               )
           )
     ORDER BY polc.displayed_field;
--< Bug 3194665 End >

BEGIN
    --< Bug 3194665 > Removed unnecessary std api work
    x_return_status := FND_API.g_ret_sts_success;

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                   '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                   ', Subtype: ' || NVL(p_doc_subtype,'null') ||
                   ', Line Loc ID: ' || NVL(TO_CHAR(p_doc_line_loc_id),'null'));
        END IF;
    END IF;

    OPEN l_get_actions_csr;
    --< Bug 3194665 Start >
    -- Select displayed_field and lookup_code
    FETCH l_get_actions_csr BULK COLLECT INTO x_displayed_field_tbl,
                                              x_lookup_code_tbl;

    IF (l_get_actions_csr%ROWCOUNT = 0) THEN
        -- No data found, so just return error status without a msg
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.get_failed', FALSE);
            END IF;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
    END IF;
    --< Bug 3194665 End >
    CLOSE l_get_actions_csr;

EXCEPTION
    --< Bug 3194665 > Removed unnecessary std api exception blocks
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF l_get_actions_csr%ISOPEN THEN
            CLOSE l_get_actions_csr;
        END IF;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END get_shipment_actions;


--< Bug 3194665 > Changed signature.
--------------------------------------------------------------------------------
--Start of Comments
--Name: get_rel_header_actions
--Pre-reqs:
--  None.
--Modifies:
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Retrieves all allowable control actions that p_agent_id can perform on the
--  document at release header level. Appends to API msg list upon unexpected
--  error.
--Parameters:
--IN:
--p_doc_subtype
--p_doc_id
--  The document release ID.
--p_agent_id
--  The person attempting to perform the control action. If this ID is NULL,
--  then document security checks are skipped.
--OUT:
--x_lookup_code_tbl
--  Table storing the lookup_code values for each allowable control action.
--  These elements are in sync with the elements in x_displayed_field_tbl.
--x_displayed_field_tbl
--  Table storing the displayed_field values for each allowable control action.
--  These elements are in sync with the elements in x_lookup_code_tbl.
--x_return_status
--  FND_API.g_ret_sts_success     - if 1 or more actions were found
--  FND_API.g_ret_sts_error       - if no control actions were found
--  FND_API.g_ret_sts_unexp_error - if unexpected error occurs
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_rel_header_actions
    ( p_doc_subtype         IN   VARCHAR2
    , p_doc_id              IN   NUMBER
    , p_agent_id            IN   NUMBER
    , x_lookup_code_tbl     OUT  NOCOPY g_lookup_code_tbl_type
    , x_displayed_field_tbl OUT  NOCOPY g_displayed_field_tbl_type
    , x_return_status       OUT  NOCOPY VARCHAR2
    )
IS

l_api_name CONSTANT VARCHAR2(30) := 'get_rel_header_actions';
--< Bug 3194665 Start >
-- Removed unnecessary std api var.
-- Now select displayed field in cursor.
CURSOR l_get_actions_csr IS
    -- SQL What: Querying for control actions
    -- SQL Why: Find all allowable release header level control actions for this
    --          release.
    SELECT polc.displayed_field,
           polc.lookup_code
      FROM po_lookup_codes polc,
           po_releases por
     WHERE por.po_release_id = p_doc_id
       AND polc.lookup_type = 'CONTROL ACTIONS'
       AND NVL(por.closed_code, 'OPEN') <> 'FINALLY CLOSED'
       AND (   NVL(por.cancel_flag, 'N') IN ('N','I')
            OR polc.lookup_code = 'FINALLY CLOSE'
           )  /** <Encumbrance FPJ> FC of cancelled Rel **/
           /** Bug 3231524 Removed restrictions for drop ship release. **/
       AND (   (    (   (    polc.lookup_code = 'FREEZE'
                         AND NVL(por.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND NVL(por.frozen_flag, 'N') = 'N'
                        )
                     OR (    polc.lookup_code = 'UNFREEZE'
                         AND NVL(por.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND por.frozen_flag = 'Y'
                        )
                    )
                AND NVL(por.hold_flag, 'N') = 'N'
                AND NVL(por.authorization_status, 'INCOMPLETE') = 'APPROVED'
               )
            OR (    polc.lookup_code = 'HOLD'
                AND NVL(por.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                AND NVL(por.hold_flag, 'N') = 'N'
               )
            OR (    polc.lookup_code = 'RELEASE HOLD'
                AND NVL(por.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                AND por.hold_flag = 'Y'
               )
            OR (    polc.lookup_code = 'CANCEL REL'
                AND NVL(por.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                AND NVL(por.hold_flag, 'N') = 'N'
                AND NVL(por.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED')
                AND por.approved_date IS NOT NULL -- bug 12347143
                AND NVL(por.authorization_status, 'INCOMPLETE') NOT IN
                          /* <CancelPO FPJ> 'REQUIRES REAPPROVAL', */
                          ('IN PROCESS', 'PRE-APPROVED', 'INCOMPLETE')
                AND (   (p_agent_id IS NULL)
                     OR (por.agent_id = p_agent_id)
                     OR EXISTS (SELECT 'security_level is full'
                                  FROM po_document_types podt
                                 WHERE podt.document_type_code = 'RELEASE'
                                   AND podt.document_subtype = p_doc_subtype
                                   AND podt.access_level_code = 'FULL')
                    )
               )
            OR (    por.approved_flag = 'Y'
                AND (   (    polc.lookup_code = 'CLOSE'
                         AND NVL(por.closed_code, 'OPEN') <> 'CLOSED'
                        )
                     OR (    polc.lookup_code = 'FINALLY CLOSE'
                         AND (   (p_agent_id IS NULL)
                              OR (por.agent_id = p_agent_id)
                              OR EXISTS (SELECT 'security_level is full'
                                           FROM po_document_types podt
                                          WHERE podt.document_type_code = 'RELEASE'
                                            AND podt.document_subtype = p_doc_subtype
                                            AND podt.access_level_code = 'FULL')
                             )
                        )
                     OR (    polc.lookup_code = 'OPEN'
                         AND NVL(por.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND NVL(por.closed_code, 'OPEN') <> 'OPEN'
                        )
                     OR (    polc.lookup_code = 'RECEIVE CLOSE'
                         AND NVL(por.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND EXISTS (SELECT 'Ships exist that are OPEN'
                                       FROM po_line_locations poll
                                      WHERE poll.po_release_id = p_doc_id
                                        AND NVL(poll.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED', 'CLOSED FOR RECEIVING'))  --Bug 5113609
                        )
                     OR (    polc.lookup_code = 'INVOICE CLOSE'
                         AND NVL(por.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND EXISTS (SELECT 'Ships exist that are OPEN'
                                       FROM po_line_locations poll
                                      WHERE poll.po_release_id = p_doc_id
                                        AND NVL(poll.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED', 'CLOSED FOR INVOICE'))   --Bug 5113609
                        )
                     OR (    polc.lookup_code = 'RECEIVE OPEN'
                         AND NVL(por.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND EXISTS (SELECT 'Ships exist that are RCLOSED'
                                       FROM po_line_locations poll
                                      WHERE poll.po_release_id = p_doc_id
                                        AND poll.closed_code IN ('CLOSED FOR RECEIVING', 'CLOSED'))
                        )
                     OR (    polc.lookup_code = 'INVOICE OPEN'
                         AND EXISTS (SELECT 'Ships exits that are IC/CLOSED'
                                       FROM po_line_locations poll
                                      WHERE poll.po_release_id = p_doc_id
                                        AND poll.closed_code IN ('CLOSED FOR INVOICE', 'CLOSED'))
                        )
                    )
               )
           )
     ORDER BY polc.displayed_field;
--< Bug 3194665 End >

BEGIN
    --< Bug 3194665 > Removed unnecessary std api work
    x_return_status := FND_API.g_ret_sts_success;

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Subtype: ' || NVL(p_doc_subtype,'null') ||
                       ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
        END IF;
    END IF;

    OPEN l_get_actions_csr;
    --< Bug 3194665 Start >
    -- Select displayed_field and lookup_code
    FETCH l_get_actions_csr BULK COLLECT INTO x_displayed_field_tbl,
                                              x_lookup_code_tbl;

    IF (l_get_actions_csr%ROWCOUNT = 0) THEN
        -- No data found, so just return error status without a msg
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.get_failed', FALSE);
            END IF;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
    END IF;
    --< Bug 3194665 End >
    CLOSE l_get_actions_csr;

EXCEPTION
    --< Bug 3194665 > Removed unnecessary std api exception blocks
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF l_get_actions_csr%ISOPEN THEN
            CLOSE l_get_actions_csr;
        END IF;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END get_rel_header_actions;


--< Bug 3194665 > Changed signature.
--------------------------------------------------------------------------------
--Start of Comments
--Name: get_rel_shipment_actions
--Pre-reqs:
--  None.
--Modifies:
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Retrieves all allowable control actions that p_agent_id can perform on the
--  document at release shipment level. Appends to API msg list upon unexpected
--  error.
--Parameters:
--IN:
--p_doc_subtype
--p_doc_line_loc_id
--  The document release shipment ID.
--p_agent_id
--  The person attempting to perform the control action. If this ID is NULL,
--  then document security checks are skipped.
--OUT:
--x_lookup_code_tbl
--  Table storing the lookup_code values for each allowable control action.
--  These elements are in sync with the elements in x_displayed_field_tbl.
--x_displayed_field_tbl
--  Table storing the displayed_field values for each allowable control action.
--  These elements are in sync with the elements in x_lookup_code_tbl.
--x_return_status
--  FND_API.g_ret_sts_success     - if 1 or more actions were found
--  FND_API.g_ret_sts_error       - if no control actions were found
--  FND_API.g_ret_sts_unexp_error - if unexpected error occurs
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_rel_shipment_actions
    ( p_doc_subtype         IN   VARCHAR2
    , p_doc_line_loc_id     IN   NUMBER
    , p_agent_id            IN   NUMBER
    , x_lookup_code_tbl     OUT  NOCOPY g_lookup_code_tbl_type
    , x_displayed_field_tbl OUT  NOCOPY g_displayed_field_tbl_type
    , x_return_status       OUT  NOCOPY VARCHAR2
    )
IS

l_api_name CONSTANT VARCHAR2(30) := 'get_rel_shipment_actions';
--< Bug 3194665 Start >
-- Removed unnecessary std api var.
-- Now select displayed field in cursor.
CURSOR l_get_actions_csr IS
    -- SQL What: Querying for control actions
    -- SQL Why: Find all allowable shipment level control actions for this
    --          release.
    SELECT polc.displayed_field,
           polc.lookup_code
      FROM po_lookup_codes polc,
           po_line_locations poll,
           po_releases por
     WHERE poll.line_location_id = p_doc_line_loc_id
       AND poll.po_release_id = por.po_release_id
       AND polc.lookup_type = 'CONTROL ACTIONS'
       AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
       AND (   NVL(poll.cancel_flag, 'N') IN ('N','I')
            OR polc.lookup_code = 'FINALLY CLOSE'
           )  /** <Encumbrance FPJ> FC of cancelled Rel **/
           /** Bug 3231524 Removed restrictions for drop ship release. **/
       AND (   (    polc.lookup_code = 'CANCEL REL SHIPMENT'
                AND NVL(por.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                AND NVL(por.hold_flag, 'N') = 'N'
                AND por.approved_date IS NOT NULL -- bug 12347143
		/* Bug no 5388496 cancelling is allowed for releases with status 'REQUIRES REAPPROVAL'*/
                AND NVL(por.authorization_status, 'INCOMPLETE') NOT IN ('INCOMPLETE', 'IN PROCESS', 'PRE-APPROVED')
                AND NVL(poll.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED')
                AND (   (p_agent_id IS NULL)
                     OR (por.agent_id = p_agent_id)
                     OR EXISTS (SELECT 'security_level is full'
                                  FROM po_document_types podt
                                 WHERE podt.document_type_code = 'RELEASE'
                                   AND podt.document_subtype = p_doc_subtype
                                   AND podt.access_level_code = 'FULL')
                    )
               )
            OR (    por.approved_flag = 'Y'
                AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
                AND (   (    polc.lookup_code = 'CLOSE'
                         AND NVL(poll.closed_code, 'OPEN') <> 'CLOSED'
                        )
                     OR (    polc.lookup_code = 'FINALLY CLOSE'
                         AND (   (p_agent_id IS NULL)
                              OR (por.agent_id = p_agent_id)
                              OR EXISTS(SELECT 'security_level is full'
                                          FROM po_document_types podt
                                         WHERE podt.document_type_code = 'RELEASE'
                                           AND podt.document_subtype = p_doc_subtype
                                           AND podt.access_level_code = 'FULL')
                             )
                        )
                     OR (    polc.lookup_code = 'OPEN'
                         AND NVL(por.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND NVL(poll.closed_code, 'OPEN') <> 'OPEN'
                        )
                     OR (    polc.lookup_code = 'INVOICE CLOSE'
                         AND NVL(por.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND NVL(poll.closed_code, 'OPEN') NOT IN ('CLOSED', 'CLOSED FOR INVOICE')
                        )
                     OR (    polc.lookup_code = 'RECEIVE CLOSE'
                         AND NVL(por.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND NVL(poll.closed_code, 'OPEN') NOT IN ('CLOSED', 'CLOSED FOR RECEIVING')
                        )
                     OR (    polc.lookup_code = 'INVOICE OPEN'
                         AND NVL(poll.closed_code, 'OPEN') NOT IN ('OPEN', 'CLOSED FOR RECEIVING') /* <GC FPJ>: bug2749001 */
                        )
                     OR (    polc.lookup_code = 'RECEIVE OPEN'
                         AND NVL(por.consigned_consumption_flag, 'N') <> 'Y'  /* CONSIGNED FPI */
                         AND NVL(poll.closed_code, 'OPEN') NOT IN ('OPEN', 'CLOSED FOR INVOICE') /* <GC FPJ>: bug2749001 */
                        )
                    )
               )
           )
     ORDER BY polc.displayed_field;
--< Bug 3194665 End >

BEGIN
    --< Bug 3194665 > Removed unnecessary std api work
    x_return_status := FND_API.g_ret_sts_success;

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                   '.invoked', 'Subtype: ' || NVL(p_doc_subtype,'null') ||
                   ', Line Loc ID: ' || NVL(TO_CHAR(p_doc_line_loc_id),'null'));
        END IF;
    END IF;

    OPEN l_get_actions_csr;
    --< Bug 3194665 Start >
    -- Select displayed_field and lookup_code
    FETCH l_get_actions_csr BULK COLLECT INTO x_displayed_field_tbl,
                                              x_lookup_code_tbl;

    IF (l_get_actions_csr%ROWCOUNT = 0) THEN
        -- No data found, so just return error status without a msg
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                           '.get_failed', FALSE);
            END IF;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
    END IF;
    --< Bug 3194665 End >
    CLOSE l_get_actions_csr;

EXCEPTION
    --< Bug 3194665 > Removed unnecessary std api exception block
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF l_get_actions_csr%ISOPEN THEN
            CLOSE l_get_actions_csr;
        END IF;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END get_rel_shipment_actions;

/**
 * Public Procedure: val_control_action
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list.
 * Effects: Validates that p_action is an allowable control action to be
 *   executed by p_agent_id on the document entity level specified. If
 *   p_agent_id is NULL, then user authority and document access level checks
 *   are skipped. Validates at shipment level if p_doc_line_loc_id is not NULL.
 *   Else, validates at line level if p_doc_line_id is not NULL. Else, validates
 *   at header level if p_doc_id is not NULL. Control actions supported for
 *   p_action are: 'CANCEL'. Requisitions are currently not supported. Appends
 *   to API message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if validation succeeds
 *                     FND_API.G_RET_STS_ERROR if validation fails
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 *   x_control_level - g_header_level
 *                     g_line_level
 *                     g_shipment_level
 *                     g_rel_header_level
 *                     g_rel_shipment_level
 */
PROCEDURE val_control_action
   (p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2,
    x_return_status    OUT  NOCOPY VARCHAR2,
    p_doc_type         IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype      IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id           IN   NUMBER,
    p_doc_line_id      IN   NUMBER,
    p_doc_line_loc_id  IN   NUMBER,
    p_action           IN   VARCHAR2,
    p_agent_id         IN   PO_HEADERS.agent_id%TYPE,
    x_control_level    OUT  NOCOPY NUMBER)
IS

l_api_name CONSTANT VARCHAR2(30) := 'val_control_action';
l_api_version CONSTANT NUMBER := 1.0;
l_allowable_actions_tbl g_lookup_code_tbl_type;         --< Bug 3194665 >
l_displayed_field_tbl g_displayed_field_tbl_type;       --< Bug 3194665 >
l_action PO_LOOKUP_CODES.lookup_code%TYPE := p_action;
l_action_ok BOOLEAN;
l_current_entity_changed VARCHAR2(1); --<CancelPO FPJ>
-- <SERVICES OTL FPJ START>
l_progress          VARCHAR2(3) := '000';
l_otl_field_name    VARCHAR2(20);
l_otl_field_value   NUMBER;
l_timecard_exists   BOOLEAN;
l_return_status     VARCHAR2(1);
-- <SERVICES OTL FPJ END>

BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Action: ' || NVL(p_action,'null')  ||
                       ', Type: ' || NVL(p_doc_type,'null') ||
                       ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
        END IF;
    END IF;

    --<CancelPO FPJ Start>
    PO_DOCUMENT_REVISION_GRP.Compare(
        p_api_version      => 1.0,
        p_doc_id           => p_doc_id,
        p_doc_subtype      => p_doc_subtype,
        p_doc_type         => p_doc_type,
        p_line_id          => p_doc_line_id,
        p_line_location_id => p_doc_line_loc_id,
        x_different        => l_current_entity_changed,
        x_return_status    => x_return_status);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- If the current entity: Header/Line/Shipent changed, return error
    IF l_current_entity_changed = 'Y' THEN
        FND_MESSAGE.set_name('PO','PO_CHANGED_CANT_CANCEL');
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;
    --<CancelPO FPJ End>

    IF (p_doc_type = 'RELEASE') THEN

        IF (p_doc_line_loc_id IS NOT NULL) THEN
            IF (l_action = 'CANCEL') THEN
                l_action := 'CANCEL REL SHIPMENT';
            END IF;
            x_control_level := g_rel_shipment_level;
            --< Bug 3194665 Start > New signature
            get_rel_shipment_actions
                ( p_doc_subtype         => p_doc_subtype
                , p_doc_line_loc_id     => p_doc_line_loc_id
                , p_agent_id            => p_agent_id
                , x_lookup_code_tbl     => l_allowable_actions_tbl
                , x_displayed_field_tbl => l_displayed_field_tbl
                , x_return_status       => x_return_status
                );
            --< Bug 3194665 End >
        ELSIF (p_doc_id IS NOT NULL) THEN
            IF (l_action = 'CANCEL') THEN
                l_action := 'CANCEL REL';
            END IF;
            x_control_level := g_rel_header_level;
            --< Bug 3194665 Start > New signature
            get_rel_header_actions
                ( p_doc_subtype         => p_doc_subtype
                , p_doc_id              => p_doc_id
                , p_agent_id            => p_agent_id
                , x_lookup_code_tbl     => l_allowable_actions_tbl
                , x_displayed_field_tbl => l_displayed_field_tbl
                , x_return_status       => x_return_status
                );
            --< Bug 3194665 End >
        ELSE
            FND_MESSAGE.set_name('PO','PO_INVALID_DOC_IDS');
            IF (g_debug_stmt) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
                  FND_LOG.message(FND_LOG.level_error, g_module_prefix ||
                                l_api_name || '.invalid_doc_ids', FALSE);
                END IF;
            END IF;
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;
        END IF;  --<if p_doc_line_loc_id ...>

    ELSIF (p_doc_type IN ('PO','PA')) THEN

        IF (p_doc_line_loc_id IS NOT NULL) THEN
            IF (l_action = 'CANCEL') THEN
                l_action := 'CANCEL PO SHIPMENT';
            END IF;
            x_control_level := g_shipment_level;
            --< Bug 3194665 Start > New signature
            get_shipment_actions
                ( p_doc_type            => p_doc_type
                , p_doc_subtype         => p_doc_subtype
                , p_doc_line_loc_id     => p_doc_line_loc_id
                , p_agent_id            => p_agent_id
                , x_lookup_code_tbl     => l_allowable_actions_tbl
                , x_displayed_field_tbl => l_displayed_field_tbl
                , x_return_status       => x_return_status
                );
            --< Bug 3194665 End >
        ELSIF (p_doc_line_id IS NOT NULL) THEN
            IF (l_action = 'CANCEL') THEN
                l_action := 'CANCEL PO LINE';
            END IF;
            x_control_level := g_line_level;
            --< Bug 3194665 Start > New signature
            get_line_actions
                ( p_doc_subtype         => p_doc_subtype
                , p_doc_line_id         => p_doc_line_id
                , p_agent_id            => p_agent_id
                , x_lookup_code_tbl     => l_allowable_actions_tbl
                , x_displayed_field_tbl => l_displayed_field_tbl
                , x_return_status       => x_return_status
                );
            --< Bug 3194665 End >
        ELSIF (p_doc_id IS NOT NULL) THEN
            IF (l_action = 'CANCEL') THEN
                l_action := 'CANCEL PO';
            END IF;
            x_control_level := g_header_level;
            --< Bug 3194665 Start > New signature
            get_header_actions
                ( p_doc_subtype         => p_doc_subtype
                , p_doc_id              => p_doc_id
                , p_agent_id            => p_agent_id
                , x_lookup_code_tbl     => l_allowable_actions_tbl
                , x_displayed_field_tbl => l_displayed_field_tbl
                , x_return_status       => x_return_status
                );
            --< Bug 3194665 End >
        ELSE
            FND_MESSAGE.set_name('PO','PO_INVALID_DOC_IDS');
            IF (g_debug_stmt) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
                  FND_LOG.message(FND_LOG.level_error, g_module_prefix ||
                                l_api_name || '.invalid_doc_ids', FALSE);
                END IF;
            END IF;
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;
        END IF;  --<if p_doc_line_loc_id ...>

    ELSE
        -- This document type is not supported
        FND_MESSAGE.set_name('PO','PO_INVALID_DOC_TYPE');
        FND_MESSAGE.set_token('TYPE',p_doc_type);
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.invalid_doc_type', FALSE);
            END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;  --<if p_doc_type = RELEASE>

    -- Check if the get action procedure had an error
    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        FND_MESSAGE.set_name('PO','PO_CONTROL_INVALID_ACTION');
        FND_MESSAGE.set_token('ACTION',p_action);
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                           '.get_action_failed', FALSE);
            END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- Loop through allowable actions to see if this action is in the set
    l_action_ok := FALSE;
    FOR i IN l_allowable_actions_tbl.first..l_allowable_actions_tbl.last
    LOOP
        IF (l_action = l_allowable_actions_tbl(i)) THEN
            l_action_ok := TRUE;
            EXIT;
        END IF;
    END LOOP;

    -- If not in the set, return error
    IF NOT l_action_ok THEN
        FND_MESSAGE.set_name('PO','PO_CONTROL_INVALID_ACTION');
        FND_MESSAGE.set_token('ACTION',p_action);
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.status_failed', FALSE);
            END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;

    -- <SERVICES OTL FPJ START>
    l_progress := '100';
    -- For cancel or finally close on Standard POs, call the OTL API to check
    -- if there are any submitted/approved timecards associated with the
    -- PO header/line. If so, prevent the control action by returning an error.
    IF (p_doc_type = 'PO') AND (p_doc_subtype = 'STANDARD')
       AND (p_action IN ('CANCEL', 'FINALLY CLOSE')) THEN

      IF (x_control_level = g_header_level) THEN
        l_otl_field_name := PO_HXC_INTERFACE_PVT.field_PO_HEADER_ID;
        l_otl_field_value := p_doc_id;
      ELSE -- line or shipment level
        l_otl_field_name := PO_HXC_INTERFACE_PVT.field_PO_LINE_ID;
        l_otl_field_value := p_doc_line_id;
      END IF; -- x_control_level

      -- Bug 3537441 Call the new interface package.
      PO_HXC_INTERFACE_PVT.check_timecard_exists (
        p_api_version => 1.0,
        x_return_status => l_return_status,
        p_field_name => l_otl_field_name,
        p_field_value => l_otl_field_value,
        p_end_date => NULL,
        x_timecard_exists => l_timecard_exists
      );
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (l_timecard_exists) THEN
        FND_MESSAGE.set_name('PO','PO_CONTROL_OTL_INVALID_ACTION');
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
      END IF;

    END IF; -- p_doc_type = 'PO'
    -- <SERVICES OTL FPJ END>

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END val_control_action;

/**
 * Public Procedure: po_stop_wf_process
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: Workflow processes for this document, API message list.
 * Effects: Stops any pending workflow process and respond notification for
 *   this document. Also does the same for any unapproved releases against this
 *   document with authorization status INCOMPLETE, REJECTED, or REQUIRES
 *   APPROVAL. Appends to API message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if no errors occur
 *                     FND_API.G_RET_STS_ERROR if error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE po_stop_wf_process
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype    IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id         IN   NUMBER)
IS

CURSOR l_po_wf_csr IS
    SELECT poh.wf_item_type, poh.wf_item_key
      FROM po_headers poh
     WHERE poh.po_header_id = p_doc_id;
CURSOR l_unapproved_releases_csr IS
    -- SQL What: Querying PO_HEADERS, PO_RELEASES for unapproved releases
    -- SQL Why: Need to stop wf processes for unapproved releases
    -- SQL Join: po_header_id
    SELECT por.po_release_id, poh.type_lookup_code,
           por.wf_item_type, por.wf_item_key
      FROM po_releases por,
           po_headers poh
     WHERE por.po_header_id = p_doc_id AND
           por.po_header_id = poh.po_header_id AND
           NVL(por.authorization_status,'INCOMPLETE') IN
		       ('INCOMPLETE','REJECTED','REQUIRES REAPPROVAL') AND
           NVL(por.cancel_flag,'N') = 'N' AND
           NVL(por.closed_code,'OPEN') <> 'FINALLY CLOSED';

-- Bulk processing types and variables
TYPE release_id_tbl_type IS TABLE OF PO_RELEASES.po_release_id%TYPE
    INDEX BY BINARY_INTEGER;
TYPE doc_subtype_tbl_type IS TABLE OF PO_HEADERS.type_lookup_code%TYPE
    INDEX BY BINARY_INTEGER;
TYPE wf_item_type_tbl_type IS TABLE OF PO_RELEASES.wf_item_type%TYPE
    INDEX BY BINARY_INTEGER;
TYPE wf_item_key_tbl_type IS TABLE OF PO_RELEASES.wf_item_key%TYPE
    INDEX BY BINARY_INTEGER;
l_release_id_tbl release_id_tbl_type;
l_doc_subtype_tbl doc_subtype_tbl_type;
l_wf_item_type_tbl wf_item_type_tbl_type;
l_wf_item_key_tbl wf_item_key_tbl_type;

l_api_name CONSTANT VARCHAR2(30) := 'po_stop_wf_process';
l_api_version CONSTANT NUMBER := 1.0;
l_wf_item_type PO_HEADERS.wf_item_type%TYPE;
l_wf_item_key PO_HEADERS.wf_item_key%TYPE;
l_num_fetched NUMBER := 0;  -- number of rows fetched at each iteration

BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                       ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
        END IF;
    END IF;

    OPEN l_po_wf_csr;
    FETCH l_po_wf_csr INTO l_wf_item_type, l_wf_item_key;
    IF l_po_wf_csr%NOTFOUND THEN
        FND_MESSAGE.set_name('PO','PO_INVALID_DOC_IDS');
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.invalid_doc_ids', FALSE);
            END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;
    CLOSE l_po_wf_csr;

    -- Cancel any approval reminder notifications. 'N' means not a release
    PO_APPROVAL_REMINDER_SV.cancel_notif(p_doc_subtype, p_doc_id, 'N');

    IF (l_wf_item_type IS NOT NULL) AND (l_wf_item_key IS NOT NULL) THEN
        -- Stop any active workflows for this document
        PO_APPROVAL_REMINDER_SV.stop_process(l_wf_item_type, l_wf_item_key);
    END IF;

    -- Blankets and Planned PO's: check if there are any unapproved releases
    IF (p_doc_subtype IN ('BLANKET','PLANNED')) THEN
        OPEN l_unapproved_releases_csr;
        LOOP
            FETCH l_unapproved_releases_csr
            BULK COLLECT INTO l_release_id_tbl, l_doc_subtype_tbl,
                              l_wf_item_type_tbl, l_wf_item_key_tbl LIMIT 1000;

            -- Loop through the unapproved releases tables to stop wf
            -- processes for each release found
            FOR i IN 1..l_release_id_tbl.count LOOP
                IF (l_doc_subtype_tbl(i) = 'PLANNED') THEN
                    l_doc_subtype_tbl(i) := 'SCHEDULED';
                END IF;

                -- Cancel any approval reminder notifications. 'Y' = release
                PO_APPROVAL_REMINDER_SV.cancel_notif
                        (l_doc_subtype_tbl(i), l_release_id_tbl(i), 'Y');

                IF (l_wf_item_type_tbl(i) IS NOT NULL) AND
                   (l_wf_item_key_tbl(i) IS NOT NULL)
                THEN
                    -- Stop any active workflows for this document
                    PO_APPROVAL_REMINDER_SV.stop_process
                        (l_wf_item_type_tbl(i), l_wf_item_key_tbl(i));
                END IF;  --<if l_wf_item_type_tbl ...>
            END LOOP;  --<for loop>

            EXIT WHEN l_unapproved_releases_csr%NOTFOUND;
        END LOOP;

        CLOSE l_unapproved_releases_csr;

    END IF;  --<if p_doc_subtype in ...>

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
        IF l_po_wf_csr%ISOPEN THEN
            CLOSE l_po_wf_csr;
        END IF;
        IF l_unapproved_releases_csr%ISOPEN THEN
            CLOSE l_unapproved_releases_csr;
        END IF;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF l_po_wf_csr%ISOPEN THEN
            CLOSE l_po_wf_csr;
        END IF;
        IF l_unapproved_releases_csr%ISOPEN THEN
            CLOSE l_unapproved_releases_csr;
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF l_po_wf_csr%ISOPEN THEN
            CLOSE l_po_wf_csr;
        END IF;
        IF l_unapproved_releases_csr%ISOPEN THEN
            CLOSE l_unapproved_releases_csr;
        END IF;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END po_stop_wf_process;

/**
 * Public Procedure: rel_stop_wf_process
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: Workflow processes for this document, API message list.
 * Effects: Stops any pending workflow process and respond notification for
 *   this document. Appends to API message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if there are no errors
 *                     FND_API.G_RET_STS_ERROR if error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE rel_stop_wf_process
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype    IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id         IN   NUMBER)
IS

CURSOR l_rel_wf_csr IS
    SELECT por.wf_item_type, por.wf_item_key
      FROM po_releases por
     WHERE por.po_release_id = p_doc_id;

l_api_name CONSTANT VARCHAR2(30) := 'rel_stop_wf_process';
l_api_version CONSTANT NUMBER := 1.0;
l_wf_item_type PO_RELEASES.wf_item_type%TYPE;
l_wf_item_key PO_RELEASES.wf_item_key%TYPE;

BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                       ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
        END IF;
    END IF;

    OPEN l_rel_wf_csr;
    FETCH l_rel_wf_csr INTO l_wf_item_type, l_wf_item_key;
    IF l_rel_wf_csr%NOTFOUND THEN
        FND_MESSAGE.set_name('PO','PO_INVALID_DOC_IDS');
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.invalid_doc_ids', FALSE);
            END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;
    CLOSE l_rel_wf_csr;

    -- Cancel any approval reminder notifications. 'Y' means this is a release
    PO_APPROVAL_REMINDER_SV.cancel_notif(p_doc_subtype, p_doc_id, 'Y');

    IF (l_wf_item_type IS NOT NULL) AND (l_wf_item_key IS NOT NULL) THEN
        -- Stop any active workflows for this release
        PO_APPROVAL_REMINDER_SV.stop_process(l_wf_item_type, l_wf_item_key);
    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
        IF l_rel_wf_csr%ISOPEN THEN
            CLOSE l_rel_wf_csr;
        END IF;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF l_rel_wf_csr%ISOPEN THEN
            CLOSE l_rel_wf_csr;
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF l_rel_wf_csr%ISOPEN THEN
            CLOSE l_rel_wf_csr;
        END IF;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END rel_stop_wf_process;


/**
 * Private Procedure: submit_po_print_request
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list.
 * Effects: Submits a concurrent request to print the document specified.
 *   Appends to API message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if request was created
 *                     FND_API.G_RET_STS_ERROR if request was not created
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 *   x_request_id - The ID of the print request
 */
PROCEDURE submit_po_print_request
   (p_api_version    IN   NUMBER,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_num        IN   VARCHAR2,
    p_user_id        IN   VARCHAR2,
    p_qty_precision  IN   VARCHAR2,
    x_request_id     OUT  NOCOPY NUMBER)
IS

l_api_name CONSTANT VARCHAR2(30) := 'submit_po_print_request';
l_api_version CONSTANT NUMBER := 1.0;
l_set_lang boolean;

BEGIN
    -- Start standard API initialization
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Doc num: ' || NVL(p_doc_num,'null'));
        END IF;
    END IF;

    -- Only pass in necessary params. After the last necessary param, pass in
    -- FND_GLOBAL.local_chr(0) to signify end of param list, allowing the rest
    -- to be skipped. Defaulting the remainders would be more expensive to do.

    --<R12 MOAC START>
    po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);
    --<R12 MOAC END>
    /* bug 13540069*/
	l_set_lang := fnd_request.set_options('NO', 'NO', NULL,NULL, NULL, FND_PROFILE.VALUE('ICX_NUMERIC_CHARACTERS'));

    x_request_id := FND_REQUEST.submit_request
                            ( 'PO',
                    		  'POXPPO',
                    		  NULL,
                    		  NULL,
                    		  FALSE,
                	    	  'P_REPORT_TYPE=R',
            	    	      'P_TEST_FLAG=N',
                    		  'P_PO_NUM_FROM='   || p_doc_num,
                    		  'P_PO_NUM_TO='     || p_doc_num,
                    		  'P_USER_ID='       || p_user_id,
                    		  'P_QTY_PRECISION=' || p_qty_precision,
                       		  FND_GLOBAL.local_chr(0),
                              NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL );

    IF (x_request_id = 0) THEN
        -- The call to FND_REQUEST sets a message name on error
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.request_failed', FALSE);
            END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END submit_po_print_request;


/**
 * Private Procedure: submit_rel_print_request
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list
 * Effects: Submits a concurrent request to print the release specified.
 *   Appends to API message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if request was created
 *                     FND_API.G_RET_STS_ERROR if request was not created
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 *   x_request_id - The ID of the print request
 */
PROCEDURE submit_rel_print_request
   (p_api_version    IN   NUMBER,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_num        IN   VARCHAR2,
    p_rel_doc_num    IN   VARCHAR2,
    p_user_id        IN   VARCHAR2,
    p_qty_precision  IN   VARCHAR2,
    x_request_id     OUT  NOCOPY NUMBER)
IS

l_api_name CONSTANT VARCHAR2(30) := 'submit_rel_print_request';
l_api_version CONSTANT NUMBER := 1.0;
l_set_lang boolean;

BEGIN
    -- Start standard API initialization
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Doc num: ' || NVL(p_doc_num,'null') ||
                       ', Rel num: ' || NVL(p_rel_doc_num,'null'));
        END IF;
    END IF;

    -- Only pass in necessary params. After the last necessary param, pass in
    -- FND_GLOBAL.local_chr(0) to signify end of param list, allowing the rest
    -- to be skipped. Defaulting the remainders would be more expensive to do.

    --<R12 MOAC START>
    po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);
    --<R12 MOAC END>
    /* bug 13540069*/
	l_set_lang := fnd_request.set_options('NO', 'NO', NULL,NULL, NULL, FND_PROFILE.VALUE('ICX_NUMERIC_CHARACTERS'));
    x_request_id := FND_REQUEST.submit_request
                            ( 'PO',
                    		  'POXPPO',
                    		  NULL,
                    		  NULL,
                    		  FALSE,
                	    	  'P_REPORT_TYPE=R',
            	    	      'P_TEST_FLAG=N',
                    		  'P_PO_NUM_FROM='      || p_doc_num,
                    		  'P_PO_NUM_TO='        || p_doc_num,
                              'P_RELEASE_NUM_FROM=' || p_rel_doc_num,
                              'P_RELEASE_NUM_TO='   || p_rel_doc_num,
                    		  'P_USER_ID='          || p_user_id,
                    		  'P_QTY_PRECISION='    || p_qty_precision,
                       		  FND_GLOBAL.local_chr(0),
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL );

    IF (x_request_id = 0) THEN
        -- The call to FND_REQUEST sets a message name on error
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.request_failed', FALSE);
            END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END submit_rel_print_request;


/**
 * Private Procedure: submit_req_print_request
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list
 * Effects: Submits a concurrent request to print the requistion specified.
 *   Appends to API message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if request was created
 *                     FND_API.G_RET_STS_ERROR if request was not created
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 *   x_request_id - The ID of the print request
 */
PROCEDURE submit_req_print_request
   (p_api_version    IN   NUMBER,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_num        IN   VARCHAR2,
    p_user_id        IN   VARCHAR2,
    p_qty_precision  IN   VARCHAR2,
    x_request_id     OUT  NOCOPY NUMBER)
IS

l_api_name CONSTANT VARCHAR2(30) := 'submit_req_print_request';
l_api_version CONSTANT NUMBER := 1.0;

BEGIN
    -- Start standard API initialization
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Doc num: ' || NVL(p_doc_num,'null'));
        END IF;
    END IF;

    -- Only pass in necessary params. After the last necessary param, pass in
    -- FND_GLOBAL.local_chr(0) to signify end of param list, allowing the rest
    -- to be skipped. Defaulting the remainders would be more expensive to do.


    --<R12 MOAC START>
    po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);
    --<R12 MOAC END>

    x_request_id := FND_REQUEST.submit_request
                            ( 'PO',
                    		  'PRINTREQ',
                    		  NULL,
                    		  NULL,
                    		  FALSE,
                    		  'P_REQ_NUM_FROM='   || p_doc_num,
                    		  'P_REQ_NUM_TO='     || p_doc_num,
                    		  'P_QTY_PRECISION=' || p_qty_precision,
                       		  FND_GLOBAL.local_chr(0),
                              NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL, NULL, NULL );

    IF (x_request_id = 0) THEN
        -- The call to FND_REQUEST sets a message name on error
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.request_failed', FALSE);
            END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END submit_req_print_request;


/**
 * Public Procedure: create_print_request
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list
 * Effects: Creates a request to print the document specified. Appends to API
 *   message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if request was created
 *                     FND_API.G_RET_STS_ERROR if request was not created
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 *   x_request_id - The ID of the print request
 */
PROCEDURE create_print_request
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_num        IN   VARCHAR2,
    p_rel_doc_num    IN   VARCHAR2,
    x_request_id     OUT  NOCOPY NUMBER)
IS

l_api_name CONSTANT VARCHAR2(30) := 'create_print_request';
l_api_version CONSTANT NUMBER := 1.0;
l_qty_precision FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
l_user_id FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;

BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                       ', Doc num: ' || NVL(p_doc_num,'null') ||
                       ', Rel num: ' || NVL(p_rel_doc_num,'null'));
        END IF;
    END IF;

    FND_PROFILE.get('REPORT_QUANTITY_PRECISION', l_qty_precision);
    FND_PROFILE.get('USER_ID', l_user_id);

    IF (p_doc_type IN ('PO','PA')) THEN

        submit_po_print_request( p_api_version   => 1.0,
                                 x_return_status => x_return_status,
                                 p_doc_num       => p_doc_num,
                                 p_user_id       => l_user_id,
                                 p_qty_precision => l_qty_precision,
                                 x_request_id    => x_request_id);

    ELSIF (p_doc_type = 'RELEASE') THEN

        submit_rel_print_request( p_api_version   => 1.0,
                                  x_return_status => x_return_status,
                                  p_doc_num       => p_doc_num,
                                  p_rel_doc_num   => p_rel_doc_num,
                                  p_user_id       => l_user_id,
                                  p_qty_precision => l_qty_precision,
                                  x_request_id    => x_request_id);

    ELSIF (p_doc_type = 'REQUISITION') THEN

        submit_req_print_request( p_api_version   => 1.0,
                                  x_return_status => x_return_status,
                                  p_doc_num       => p_doc_num,
                                  p_user_id       => l_user_id,
                                  p_qty_precision => l_qty_precision,
                                  x_request_id    => x_request_id);

    ELSE
        -- This document type is not supported
        FND_MESSAGE.set_name('PO','PO_INVALID_DOC_TYPE');
        FND_MESSAGE.set_token('TYPE',p_doc_type);
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.invalid_doc_type', FALSE);
            END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END create_print_request;


/**
 * Public Procedure: update_note_to_vendor
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: note_to_vendor in PO_HEADERS, PO_LINES, or PO_RELEASES. API message
 *   list.
 * Effects: Updates the note_to_vendor column of PO_HEADERS, PO_LINES, or
 *   PO_RELEASES depending upon p_doc_type. If p_doc_line_id is not NULL and the
 *   document is not a RELEASE, then updates PO_LINES. All changes will be
 *   committed upon success if p_commit is FND_API.G_TRUE. Appends to API
 *   message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if the update was successful
 *                     FND_API.G_RET_STS_ERROR if no update was made
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE update_note_to_vendor
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    p_commit         IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_id         IN   NUMBER,
    p_doc_line_id    IN   NUMBER,
    p_note_to_vendor IN   PO_HEADERS.note_to_vendor%TYPE)
IS

l_api_name CONSTANT VARCHAR2(30) := 'update_note_to_vendor';
l_api_version CONSTANT NUMBER := 1.0;

BEGIN
    -- Start standard API initialization
    SAVEPOINT update_note_to_vendor_PVT;
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                       ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
        END IF;
    END IF;

    IF (p_doc_type IN ('PO','PA')) THEN

        IF (p_doc_line_id IS NOT NULL) THEN

            UPDATE po_lines pol
               SET pol.note_to_vendor = p_note_to_vendor
             WHERE pol.po_line_id = p_doc_line_id AND
                   pol.po_header_id = p_doc_id;

           --<Bug 2843843 mbhargav START>
           -- Return error if no update was made.
           IF SQL%NOTFOUND THEN
                FND_MESSAGE.set_name('PO','PO_INVALID_DOC_IDS');
                IF (g_debug_stmt) THEN
                     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
                       FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.invalid_document', FALSE);
                     END IF;
                END IF;
                FND_MSG_PUB.add;
                RAISE FND_API.g_exc_error;
           END IF;
           --<Bug 2843843 mbhargav END>

  /* Bug 2781710: We should update the note_to_vendor column
     in the archive table also. */

            UPDATE po_lines_archive pla
               SET pla.note_to_vendor = p_note_to_vendor
             WHERE pla.po_line_id = p_doc_line_id AND
                   pla.po_header_id = p_doc_id AND
                   pla.revision_num = (SELECT poh.revision_num
                                         FROM po_headers poh
                                        WHERE poh.po_header_id = p_doc_id);

        ELSE

           UPDATE po_headers poh
             SET poh.note_to_vendor = p_note_to_vendor
             WHERE poh.po_header_id = p_doc_id;

           --<Bug 2843843 mbhargav START>
           -- Return error if no update was made.
           IF SQL%NOTFOUND THEN
                FND_MESSAGE.set_name('PO','PO_INVALID_DOC_IDS');
                IF (g_debug_stmt) THEN
                     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
                       FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.invalid_document', FALSE);
                     END IF;
                END IF;
                FND_MSG_PUB.add;
                RAISE FND_API.g_exc_error;
           END IF;
           --<Bug 2843843 mbhargav END>

  /* Bug 2781710: We should update the note_to_vendor column
     in the archive table also. */

            UPDATE po_headers_archive pha
               SET pha.note_to_vendor = p_note_to_vendor
             WHERE pha.po_header_id = p_doc_id AND
                   pha.revision_num = (SELECT poh.revision_num
                                         FROM po_headers poh
                                        WHERE poh.po_header_id = p_doc_id);
        END IF;  --<if p_doc_line_id ...>

    ELSIF (p_doc_type = 'RELEASE') THEN

        UPDATE po_releases por
           SET por.note_to_vendor = p_note_to_vendor
         WHERE por.po_release_id = p_doc_id;

        --<Bug 2843843 mbhargav START>
        -- Return error if no update was made.
        IF SQL%NOTFOUND THEN
             FND_MESSAGE.set_name('PO','PO_INVALID_DOC_IDS');
             IF (g_debug_stmt) THEN
                   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
                     FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.invalid_document', FALSE);
                   END IF;
             END IF;
             FND_MSG_PUB.add;
             RAISE FND_API.g_exc_error;
        END IF;
        --<Bug 2843843 mbhargav END>

  /* Bug 2781710: We should update the note_to_vendor column
     in the archive table also. */

        UPDATE po_releases_archive pra
           SET pra.note_to_vendor = p_note_to_vendor
         WHERE pra.po_release_id = p_doc_id AND
               pra.revision_num = (SELECT por.revision_num
                                     FROM po_releases por
                                    WHERE por.po_release_id = p_doc_id);
    ELSE
        -- This document type is not supported
        FND_MESSAGE.set_name('PO','PO_INVALID_DOC_TYPE');
        FND_MESSAGE.set_token('TYPE',p_doc_type);
        IF (g_debug_stmt) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix||l_api_name||
                            '.invalid_doc_type', FALSE);
            END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;

    END IF;  --<if p_doc_type ...>

    -- Standard API check of p_commit
    IF FND_API.to_boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
EXCEPTION
    WHEN FND_API.g_exc_error THEN
        ROLLBACK TO update_note_to_vendor_PVT;
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        ROLLBACK TO update_note_to_vendor_PVT;
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        ROLLBACK TO update_note_to_vendor_PVT;
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END update_note_to_vendor;


/**
 * Public Function: pass_security_check
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list
 * Effects: Checks if p_agent_id has the access and security clearance to modify
 *   or act upon this document. Appends to API message list on error.
 * Returns:
 *   TRUE - if the check passes
 *   FALSE - otherwise, or if an error occurs
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if no error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
FUNCTION pass_security_check
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype    IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id         IN   NUMBER,
    p_agent_id       IN   PO_HEADERS.agent_id%TYPE)
RETURN BOOLEAN
IS

l_api_name CONSTANT VARCHAR2(30) := 'pass_security_check';
l_api_version CONSTANT NUMBER := 1.0;
l_doc_agent_id PO_HEADERS.agent_id%TYPE;
l_return_value BOOLEAN;

BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                       ', ID: ' || NVL(TO_CHAR(p_doc_id),'null') ||
                       ', Agent: ' || NVL(TO_CHAR(p_agent_id),'null'));
        END IF;
    END IF;

    -- Find the original agent or preparer of the document depending on its type
    IF (p_doc_type = 'REQUISITION') THEN
        SELECT porh.preparer_id
          INTO l_doc_agent_id
          FROM po_requisition_headers porh
         WHERE porh.requisition_header_id = p_doc_id;
    ELSIF (p_doc_type = 'RELEASE') THEN
        SELECT por.agent_id
          INTO l_doc_agent_id
          FROM po_releases por
         WHERE por.po_release_id = p_doc_id;
    ELSE
        SELECT poh.agent_id
          INTO l_doc_agent_id
          FROM po_headers poh
         WHERE poh.po_header_id = p_doc_id;
    END IF;  -- if p_doc_type = ...

    -- Check if this agent has security clearance for this document
    RETURN PO_REQS_CONTROL_SV.val_doc_security(x_doc_agent_id => l_doc_agent_id,
                                               x_agent_id => p_agent_id,
                                               x_doc_type => p_doc_type,
                                               x_doc_subtype => p_doc_subtype);
EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        RETURN FALSE;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
        RETURN FALSE;
END pass_security_check;


/**
 * Public Function: has_shipments
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list
 * Effects: Checks if the document has shipments that are not cancelled
 *   or finally closed. Appends to API message list on error.
 * Returns:
 *   TRUE - if the check passes
 *   FALSE - otherwise, or if an error occurs
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if no error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
FUNCTION has_shipments
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_id         IN   NUMBER)
RETURN BOOLEAN
IS

CURSOR l_has_ship_csr IS
    -- SQL What: Query PO_LINE_LOCATIONS for shipments
    -- SQL Why: Check if this document has any shipments
    --<Complex Work R12>: include PREPAYMENT line locations
    SELECT 'Has shipments'
      FROM po_line_locations poll
     WHERE poll.po_header_id = p_doc_id AND
           poll.shipment_type IN
             ('STANDARD', 'PLANNED', 'BLANKET', 'PREPAYMENT') AND
           NVL(poll.cancel_flag, 'N') = 'N' AND
           NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED';
CURSOR l_has_rel_ship_csr IS
    -- SQL What: Query PO_LINE_LOCATIONS for shipments
    -- SQL Why: Check if this release has any shipments
    SELECT 'Has shipments'
      FROM po_line_locations poll
     WHERE poll.po_release_id = p_doc_id AND
           poll.shipment_type IN ('STANDARD', 'PLANNED', 'BLANKET') AND
           NVL(poll.cancel_flag, 'N') = 'N' AND
           NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED';

l_api_name CONSTANT VARCHAR2(30) := 'has_shipments';
l_api_version CONSTANT NUMBER := 1.0;
l_has_shipments VARCHAR2(15);
l_return_value BOOLEAN;

BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                       ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
        END IF;
    END IF;

    -- Choose cursor depending upon document type
    IF (p_doc_type = 'RELEASE') THEN
        OPEN l_has_rel_ship_csr;
        FETCH l_has_rel_ship_csr INTO l_has_shipments;

        -- if the cursor fetched a row, then this release has shipments
        l_return_value := l_has_rel_ship_csr%FOUND;
        CLOSE l_has_rel_ship_csr;
    ELSE
        OPEN l_has_ship_csr;
        FETCH l_has_ship_csr INTO l_has_shipments;

        -- if the cursor fetched a row, then this document has shipments
        l_return_value := l_has_ship_csr%FOUND;
        CLOSE l_has_ship_csr;
    END IF; -- if p_doc_type = RELEASE

    RETURN l_return_value;

EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF l_has_ship_csr%ISOPEN THEN
            CLOSE l_has_ship_csr;
        END IF;
        IF l_has_rel_ship_csr%ISOPEN THEN
            CLOSE l_has_rel_ship_csr;
        END IF;
        RETURN FALSE;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF l_has_ship_csr%ISOPEN THEN
            CLOSE l_has_ship_csr;
        END IF;
        IF l_has_rel_ship_csr%ISOPEN THEN
            CLOSE l_has_rel_ship_csr;
        END IF;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
        RETURN FALSE;
END has_shipments;

-- Bug#17805976 : add p_entity_id and p_entity_level to
-- FUNCTION has_unencumbered_shipments
/**
 * Public Function: has_unencumbered_shipments
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list
 * Effects: Checks if the document has any unencumbered shipments that are not
 *   cancelled or finally closed. Appends to API message list on error.
 * Returns:
 *   TRUE - if the check passes
 *   FALSE - otherwise, or if an error occurred
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if no error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
FUNCTION has_unencumbered_shipments
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_id         IN   NUMBER,
    p_entity_id      IN   NUMBER,        --Bug#17805976
    p_entity_level   IN   VARCHAR2)      --Bug#17805976
RETURN BOOLEAN
IS

l_api_name CONSTANT VARCHAR2(30) := 'has_unencumbered_shipments';
l_api_version CONSTANT NUMBER := 1.0;
l_return_value BOOLEAN;

--<Encumbrance FPJ>
l_fully_reserved_flag            VARCHAR2(1);

--Bug#17805976
l_doc_level                      VARCHAR2(30);
BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                       ', ID: ' || NVL(TO_CHAR(p_doc_id),'null') ||
                       ' Entity ID : ' || NVL(TO_CHAR(p_entity_id), 'null') ||
                       ' Entity Level: ' || NVL(p_entity_level, 'null'));
        END IF;
    END IF;

  -- Bug#17805976  start
  -- need to  convert doc level if it is shipment
  --
  l_doc_level := p_entity_level;
  IF (p_entity_level = PO_Document_Cancel_PVT.c_entity_level_SHIPMENT) THEN
    l_doc_level := PO_CORE_S.g_doc_level_SHIPMENT;
  END IF;
  -- Bug#17805976 end

--<Encumbrance FPJ START>
PO_CORE_S.is_fully_reserved(
   p_doc_type => p_doc_type
-- Bug#17805976,  p_doc_level => PO_CORE_S.g_doc_level_header
,   p_doc_level => l_doc_level
-- Bug#17805976,  p_doc_level_id => p_doc_id
,   p_doc_level_id => p_entity_id
,  x_fully_reserved_flag => l_fully_reserved_flag
);

IF (l_fully_reserved_flag = 'N') THEN
   l_return_value := TRUE;
ELSE
   l_return_value := FALSE;
END IF;
--<Encumbrance FPJ END>

    RETURN l_return_value;

EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        RETURN FALSE;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
        RETURN FALSE;
END has_unencumbered_shipments;

/**
 * Public Function: in_open_gl_period
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list
 * Effects: Checks if p_date lies within a valid open GL period. Appends to API
 *   message list on error.
 * Returns:
 *   TRUE - if the check passes
 *   FALSE - otherwise, or if an error occurred
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if no error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
FUNCTION in_open_gl_period
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_date           IN   DATE)
RETURN BOOLEAN
IS

-- bug 5498063 <R12 GL PERIOD VALIDATION>
l_validate_gl_period VARCHAR2(1);

CURSOR l_gl_period_csr IS
    -- SQL What: Querying GL_PERIOD_STATUSES and FINANCIALS_SYSTEM_PARAMETERS
    -- SQL Why: Check if p_date is in an open GL period
    -- SQL Join: set_of_books_id, period_name
    SELECT 'In open GL period'
      FROM gl_period_statuses gl_ps,
           gl_period_statuses po_ps,
           financials_system_parameters fsp
     WHERE gl_ps.application_id = 101 AND
           gl_ps.set_of_books_id = fsp.set_of_books_id AND
  	       -- bug 5498063 <R12 GL PERIOD VALIDATION>
 	       ((  (l_validate_gl_period = 'Y' OR l_validate_gl_period = 'R') --Bug15874392
 	              and GL_PS.closing_status IN ('O', 'F'))
 	        OR
 	          (l_validate_gl_period = 'N')) AND
 	       -- gl_ps.closing_status IN ('O','F') AND
 	       -- bug 5498063 <R12 GL PERIOD VALIDATION>
  	  	   gl_ps.period_name = po_ps.period_name AND
           gl_ps.adjustment_period_flag = 'N' AND
           (TRUNC(p_date) BETWEEN
               TRUNC(gl_ps.start_date) AND TRUNC(gl_ps.end_date)) AND
           po_ps.application_id = 201 AND
           po_ps.closing_status = 'O' AND
           po_ps.adjustment_period_flag = 'N' AND
           po_ps.set_of_books_id = fsp.set_of_books_id;

l_api_name CONSTANT VARCHAR2(30) := 'in_open_gl_period';
l_api_version CONSTANT NUMBER := 1.0;
l_row_exists VARCHAR2(20);
l_return_value BOOLEAN;

BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Date: ' ||
                       NVL(TO_CHAR(p_date,'DD-MON-RR'),'null'));
        END IF;
    END IF;

	-- bug 5498063 <R12 GL PERIOD VALIDATION>
	l_validate_gl_period := nvl(FND_PROFILE.VALUE('PO_VALIDATE_GL_PERIOD'),'Y');

    OPEN l_gl_period_csr;
    FETCH l_gl_period_csr INTO l_row_exists;

    -- Date is in an open GL period if a row was fetched
    l_return_value := l_gl_period_csr%FOUND;

    CLOSE l_gl_period_csr;

    RETURN l_return_value;

EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF l_gl_period_csr%ISOPEN THEN
            CLOSE l_gl_period_csr;
        END IF;
        RETURN FALSE;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF l_gl_period_csr%ISOPEN THEN
            CLOSE l_gl_period_csr;
        END IF;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
        RETURN FALSE;
END in_open_gl_period;


/**
 * Public Procedure: add_online_report_msgs
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list
 * Effects: Retrieves all text lines from PO_ONLINE_REPORT_TEXT for
 *   p_online_report_id, and appends each one to the API message list. Does not
 *   append to API message list upon expected error, just unexpected error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if all messages are appended
 *                     FND_API.G_RET_STS_ERROR if an error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE add_online_report_msgs
   (p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2,
    x_return_status    OUT  NOCOPY VARCHAR2,
    p_online_report_id IN   NUMBER)
IS

l_api_name CONSTANT VARCHAR2(30) := 'add_online_report_msgs';
l_api_version CONSTANT NUMBER := 1.0;
CURSOR l_get_online_report_csr IS
    SELECT poort.text_line
      FROM po_online_report_text poort
     WHERE poort.online_report_id = p_online_report_id;
TYPE text_line_tbl_type IS TABLE OF PO_ONLINE_REPORT_TEXT.text_line%TYPE
    INDEX BY BINARY_INTEGER;
l_text_line_tbl text_line_tbl_type;

BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_debug_stmt) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Online report ID: ' ||
                       NVL(TO_CHAR(p_online_report_id),'null'));
        END IF;
    END IF;

    OPEN l_get_online_report_csr;
    LOOP
        FETCH l_get_online_report_csr
            BULK COLLECT INTO l_text_line_tbl LIMIT 1000;
        FOR i IN 1..l_text_line_tbl.count LOOP
            -- The text_line column contains translated messages
            FND_MESSAGE.set_name('PO','PO_CUSTOM_MSG');
            FND_MESSAGE.set_token('TRANSLATED_TOKEN', l_text_line_tbl(i));
            IF (g_debug_stmt) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
                  FND_LOG.message(FND_LOG.level_error, g_module_prefix ||
                                l_api_name || '.msg', FALSE);
                END IF;
            END IF;
            FND_MSG_PUB.add;
        END LOOP;  --<for loop>

        EXIT WHEN l_get_online_report_csr%NOTFOUND;
    END LOOP;

    IF (l_get_online_report_csr%ROWCOUNT = 0) THEN
        RAISE FND_API.g_exc_error;
    END IF;
EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.others_exception', 'Exception');
            END IF;
        END IF;
END add_online_report_msgs;
--<HTML Agreements R12 Start>
----------------------------------------------------------------------------
--Start of Comments
--Name: Val_Cancel_FinalClose_Action
--Pre-reqs:
--  None.
--Modifies:
--  FND_MSG_PUB.
--Locks:
--  None.
--Function:
-- This procedure would be responsible for validating the control action
-- for the document. This code would be called when we cancel or
-- finally close from HTML
--Parameters:
--IN:
--p_control_action
-- Document Control Action being executed
--p_doc_level
-- Document Level at which control Action was taken
--p_doc_header_id
-- Document Header Id
--p_doc_line_id
-- Document Line Id
--p_doc_line_loc_id
-- Document Line Location Id
--p_doc_type
-- Document Type
--p_doc_subtype
-- Document Sub Type (type_lookup_code)
--OUT:
--x_return_status
-- Return Status of API .
--Testing:
-- Refer the Unit Test Plan for 'HTML Agreements R12'
--End of Comments
----------------------------------------------------------------------------
procedure Val_Cancel_FinalClose_Action( p_control_action  IN VARCHAR2
                                       ,p_doc_level       IN VARCHAR2
                                       ,p_doc_header_id   IN NUMBER
                                       ,p_doc_line_id     IN NUMBER
                                       ,p_doc_line_loc_id IN NUMBER
                                       ,p_doc_type        IN VARCHAR2
                                       ,p_doc_subtype     IN VARCHAR2
                                       ,x_return_status   OUT NOCOPY VARCHAR2) IS
  l_timecard_exists        BOOLEAN;
  l_otl_field_name         VARCHAR2(20);
  l_otl_field_value        NUMBER;
  l_current_entity_changed VARCHAR2(1);
  l_dummy                  PO_LINE_LOCATIONS_ALL.line_location_id%type := 0;
  d_pos                    NUMBER;
  l_api_name CONSTANT      VARCHAR2(30) := 'Val_Cancel_FinalClose_Action';
  d_module   CONSTANT      VARCHAR2(70) := 'po.plsql.PO_Document_Control_PVT.Val_Cancel_FinalClose_Action' ;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module,'p_control_action',p_control_action);
    PO_LOG.proc_begin(d_module,'p_doc_level',p_doc_level);
    PO_LOG.proc_begin(d_module,'p_doc_header_id',p_doc_header_id);
    PO_LOG.proc_begin(d_module,'p_doc_line_id',p_doc_line_id);
    PO_LOG.proc_begin(d_module,'p_doc_line_loc_id',p_doc_line_loc_id);
    PO_LOG.proc_begin(d_module,'p_doc_type',p_doc_type);
    PO_LOG.proc_begin(d_module,'p_doc_subtype',p_doc_subtype);
  END IF;
  d_pos := 10;
  --Initialising the variables to default value
  x_return_status          := FND_API.g_ret_sts_success;
  l_current_entity_changed := 'N';

  -- <Bug 14207546 :Cancel Refactoring Project: removed the block>
  -- For cancel or finally close on Standard POs, call the OTL API to check
  -- if there are any submitted/approved timecards associated with the
  -- PO header/line. If so, return an error.

  IF (p_doc_subtype = PO_CONSTANTS_SV.STANDARD) THEN
    d_pos := 50;
    IF p_doc_level = PO_CORE_S.g_doc_level_HEADER THEN
      l_otl_field_name  := PO_HXC_INTERFACE_PVT.field_PO_HEADER_ID;
      l_otl_field_value := p_doc_header_id;
    ELSE
      -- line or shipment level
      l_otl_field_name  := PO_HXC_INTERFACE_PVT.field_PO_LINE_ID;
      l_otl_field_value := p_doc_line_id;
    END IF; --p_doc_level = 'HEADER'
    d_pos := 60;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_pos,'l_otl_field_name',l_otl_field_name);
      PO_LOG.stmt(d_module,d_pos,'l_otl_field_value',l_otl_field_value);
    END IF;
    PO_HXC_INTERFACE_PVT.check_timecard_exists(p_api_version     => 1.0,
                                               x_return_status   => x_return_status,
                                               p_field_name      => l_otl_field_name,
                                               p_field_value     => l_otl_field_value,
                                               p_end_date        => NULL,
                                               x_timecard_exists => l_timecard_exists);
    d_pos := 70;
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    d_pos := 80;
    IF (l_timecard_exists) THEN
      FND_MESSAGE.set_name('PO','PO_CONTROL_OTL_INVALID_ACTION');
      FND_MSG_PUB.add;
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_module,d_pos,'Document with timecard cannot be Cancelled or Finally Closed');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF; -- IF(l_timecard_exists) THEN
  END IF; --p_doc_subtype = 'STANDARD'
  d_pos := 90;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unexpected Error in ' || d_module);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name||':'||d_pos);
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in'  || d_module);
    END IF;
END Val_Cancel_FinalClose_Action;

------------------------------------------------------------------------
--Start of Comments
--Name: do_control_action
--Pre-reqs:
--  None.
--Modifies:
-- None.
--Locks:
--  None.
--Function:
-- This procedure is responsible for executing the control action and
-- formatting the errors encountered show that user can be displayed the
-- error message.
--IN:
--p_mode
-- HTML mode EDIT/UPDATE/SUMMARY
--p_control_action
-- Document Control Action being executed
--p_doc_level
-- Document Level at which control Action was taken
--p_doc_header_id
-- Document Header Id
--p_doc_line_id
-- Document Line Id
--p_doc_line_loc_id
-- Document Line Location Id
--p_doc_type
-- Document Type
--p_doc_sub_type
-- Document Sub Type (type_lookup_code)
--p_action_date
-- GL Date value provided by the user
--p_use_gldate
-- Value of the Use GL Date to Unreserve Checkbox
--p_reason
-- Possible Reason for excuting the control Action
--p_note_to_vendor
-- Not for the Supplier in case a document is being cancelled
--p_communication_method
-- Communication method selected by the user {EMAIL/FAX/PRINT/EDI/XML}
--p_communication_value
-- Communication method value provided by the user {Email Address/ Fax Number}
--p_cancel_reqs
-- value of Cancel Requisitions checkbox
--OUT:
--x_approval_initiated
-- Was approval initaited for the document?
--x_cancel_req_flag_reset
-- Was the cancel requisitions flag reset by the cancel code
--x_return_status
-- Return Status of API .
--x_error_msg_tbl
-- table for Error messages if any .
--x_is_encumbrance_error
-- whether the error (if any) was due to encumbrance - Bug 5000165
--x_online_report_id
-- determines the online report id generated during an encumbrance transaction - Bug 5055417
--Testing:
-- Refer the Unit Test Plan for 'HTML Agreements R12'
--End of Comments
----------------------------------------------------------------------------
procedure do_control_action( p_mode                 IN VARCHAR2
                            ,p_control_action       IN  VARCHAR2
                            ,p_doc_level            IN  VARCHAR2
                            ,p_doc_header_id        IN  NUMBER
                            ,p_doc_line_id          IN  NUMBER
                            ,p_doc_line_loc_id      IN  NUMBER
                            ,p_doc_type             IN  VARCHAR2
                            ,p_doc_subtype          IN  VARCHAR2
                            ,p_action_date          IN  DATE
                            ,p_use_gldate           IN  VARCHAR2
                            ,p_reason               IN  VARCHAR2
                            ,p_note_to_vendor       IN  VARCHAR2
                            ,p_communication_method IN  VARCHAR2
                            ,p_communication_value  IN  VARCHAR2
                            ,p_cancel_reqs          IN  VARCHAR2
                            ,x_return_status        OUT NOCOPY VARCHAR2
                            ,x_approval_initiated   OUT NOCOPY VARCHAR2
                            ,x_cancel_req_flag_reset OUT NOCOPY VARCHAR2
                            ,x_is_encumbrance_error OUT NOCOPY VARCHAR2
                            ,x_online_report_id       OUT NOCOPY NUMBER--bug#5055417
                            )
IS
  l_doc_subtype             PO_LINE_LOCATIONS_ALL.shipment_type%type;
  l_conterms_exist_flag     PO_HEADERS_ALL.conterms_exist_flag%TYPE;
  l_document_start_date     PO_HEADERS_ALL.start_date%TYPE;
  l_document_end_date       PO_HEADERS_ALL.end_date%TYPE;
  l_document_version        PO_HEADERS_ALL.revision_num%TYPE;
  l_cancel_flag             PO_HEADERS_ALL.cancel_flag%TYPE;
  l_print_flag              VARCHAR2(1);
  l_event_code              VARCHAR2(30);
  SUBTYPE busdocdates_tbl_type IS
                            okc_manage_deliverables_grp.busdocdates_tbl_type;
  l_busdocdates_tbl         busdocdates_tbl_type;
  l_exc_msg                 VARCHAR2(2000);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_online_report_id       PO_ONLINE_REPORT_TEXT.online_report_id%type;
  l_return_code            VARCHAR2(25);
  l_control_action_disp_name PO_LOOKUP_CODES.displayed_field%type;
  d_pos                    NUMBER;
  l_launch_approvals_flag  VARCHAR2(1) ;-- <bug 19077847 >
  l_api_name CONSTANT      VARCHAR2(30) := 'do_control_action';
  d_module   CONSTANT      VARCHAR2(70) := 'po.plsql.PO_Document_Control_PVT.do_control_action';

BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module,'p_mode',p_mode);
    PO_LOG.proc_begin(d_module,'p_control_action',p_control_action);
    PO_LOG.proc_begin(d_module,'p_doc_level',p_doc_level);
    PO_LOG.proc_begin(d_module,'p_doc_header_id',p_doc_header_id);
    PO_LOG.proc_begin(d_module,'p_doc_line_id',p_doc_line_id);
    PO_LOG.proc_begin(d_module,'p_doc_line_loc_id',p_doc_line_loc_id);
    PO_LOG.proc_begin(d_module,'p_doc_type',p_doc_type);
    PO_LOG.proc_begin(d_module,'p_doc_subtype',p_doc_subtype);
    PO_LOG.proc_begin(d_module,'p_action_date',p_action_date);
    PO_LOG.proc_begin(d_module,'p_use_gldate',p_use_gldate);
    PO_LOG.proc_begin(d_module,'p_reason',p_reason);
    PO_LOG.proc_begin(d_module,'p_note_to_vendor',p_note_to_vendor);
    PO_LOG.proc_begin(d_module,'p_communication_method',p_communication_method);
    PO_LOG.proc_begin(d_module,'p_communication_value',p_communication_value);
    PO_LOG.proc_begin(d_module,'p_cancel_reqs',p_cancel_reqs);
  END IF;
  d_pos := 10;
  --initialise the out variables to default value
  l_online_report_id := NULL;
  l_return_code := NULL;
  x_return_status := FND_API.g_ret_sts_success;
  x_approval_initiated := 'N';
  x_cancel_req_flag_reset := 'N';
  x_is_encumbrance_error := 'N'; -- Bug 5000165
  l_launch_approvals_flag := 'N'; -- bug 19077847

  d_pos := 15;
  SELECT displayed_field
  INTO l_control_action_disp_name
  FROM PO_LOOKUP_CODES
  WHERE lookup_type = 'CONTROL ACTIONS'
  AND lookup_code = p_control_action;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_pos,'l_control_action_disp_name', l_control_action_disp_name);
  END IF;

  IF p_control_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_FINALLY_CLOSE THEN
    d_pos := 20;
    --When one finally close a PO, the req is NOT returned to the req pool.
    --Since you cannot generate a new PO from the same req, the req cannot be
    --considered supply, so we remove the reservation entirely.

    PO_RESERVATION_MAINTAIN_SV.maintain_reservation(
       p_header_id            => p_doc_header_id,
       p_action               => 'CANCEL_PO_SUPPLY',
       p_recreate_demand_flag => 'N',
       x_return_status        => x_return_status);
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_pos,'x_return_status',x_return_status);
    END IF;

    d_pos := 30;
       --PO_RESERVATION_MAINTAIN_SV.maintain_reservation nullifies the
       -- x_return_status
    IF(x_return_status is null) THEN
       x_return_status := FND_API.g_ret_sts_success;
    END IF;
    d_pos := 40;
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Update cbc_accounting_date for Finally Close actions
    IF (IGC_CBC_PO_GRP.cbc_po_enabled_flag = 'Y') THEN
      d_pos := 50;
      IGC_CBC_PO_GRP.update_cbc_acct_date(
         p_api_version       => 1.0
         ,p_init_msg_list     => FND_API.G_FALSE
         ,p_commit            => FND_API.G_FALSE
         ,p_validation_level  => 100
         ,x_return_status     => x_return_status
         ,x_msg_count         => l_msg_count
         ,x_msg_data          => l_msg_data
         ,p_document_id       => p_doc_header_id
         ,p_document_type     => p_doc_type
         ,p_document_sub_type => p_doc_subtype
         ,p_cbc_acct_date     => p_action_date);

      d_pos := 60;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module,d_pos,'x_return_status',x_return_status);
      END IF;
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;  --IGC_CBC_PO_GRP.cbc_po_enabled_flag = 'Y'

    -- call to Contracts API to cancel deliverables only on the header level
    -- for finally close
    IF (p_doc_level = PO_CORE_S.g_doc_level_HEADER) THEN
      d_pos := 60;
      select conterms_exist_flag, start_date,
             end_date, decode(cancel_flag,'I',null,cancel_flag)
      into l_conterms_exist_flag, l_document_start_date,
           l_document_end_date, l_cancel_flag
      from po_headers_all
      where po_header_id = p_doc_header_id;
      d_pos := 70;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module,d_pos,'l_conterms_exist_flag',l_conterms_exist_flag);
        PO_LOG.stmt(d_module,d_pos,'l_document_start_date',l_document_start_date);
        PO_LOG.stmt(d_module,d_pos,'l_document_end_date',l_document_end_date);
        PO_LOG.stmt(d_module,d_pos,'l_cancel_flag',l_cancel_flag);
      END IF;

      IF ((UPPER(NVL(l_conterms_exist_flag, 'N'))='Y') AND
           (UPPER(NVL(l_cancel_flag, 'N'))='N')) THEN

        d_pos := 80;

        l_event_code := 'PO_CLOSE';
        -- populate the records and the table with event names and dates.
        l_busdocdates_tbl(1).event_code := 'PO_START_DATE';
        l_busdocdates_tbl(1).event_date := l_document_start_date;
        l_busdocdates_tbl(2).event_code := 'PO_END_DATE';
        l_busdocdates_tbl(2).event_date := l_document_end_date;

        d_pos := 90;

        PO_CONTERMS_WF_PVT.cancel_deliverables (
            p_bus_doc_id                => p_doc_header_id
           ,p_bus_doc_type              => p_doc_type
           ,p_bus_doc_subtype           => p_doc_subtype
           ,p_bus_doc_version           => l_document_version
           ,p_event_code                => l_event_code
           ,p_event_date                => SYSDATE
           ,p_busdocdates_tbl           => l_busdocdates_tbl
           ,x_return_status             => x_return_status);

        d_pos := 100;
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module,d_pos,'x_return_status',x_return_status);
        END IF;
        IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF; -- conterms exist
    END IF;--p_doc_level = 'HEADER'
  END IF;--p_control_action = 'FINALLY CLOSE'
  d_pos := 110;
  IF p_control_action LIKE 'CANCEL%' THEN

    -- If Condition Added for bug 19077847
    -- Approve the document after Cancel action when the
    -- Line/Shipment is canceled from BWC Summary
     IF p_doc_level <> 'HEADER' and p_mode = 'SUMMARY' then
        l_launch_approvals_flag:='Y';
      END IF;

/* Bug 8831247 Start
       Assign the OUT Parameter Online_Report_Id to temp_online_report_id and assign the same to x_online_report_id */

    PO_DOCUMENT_CONTROL_PVT.control_document(
        p_api_version                  => 1.0
       ,p_init_msg_list                => FND_API.G_FALSE
       ,p_commit                       => FND_API.G_FALSE
       ,x_return_status                => x_return_status
       ,p_doc_type                     => p_doc_type
       ,p_doc_subtype                  => p_doc_subtype
       ,p_doc_id                       => p_doc_header_id
       ,p_doc_line_id                  => p_doc_line_id
       ,p_doc_line_loc_id              => p_doc_line_loc_id
       ,p_source                       => PO_DOCUMENT_CANCEL_PVT.c_HTML_CONTROL_ACTION
       ,p_action                       => PO_DOCUMENT_ACTION_PVT.g_doc_action_CANCEL
       ,p_action_date                  => p_action_date
       ,p_cancel_reason                => p_reason
       ,p_cancel_reqs_flag             => p_cancel_reqs
       ,p_print_flag                   => 'N'
       ,p_note_to_vendor               => p_note_to_vendor
       ,p_use_gldate                   => p_use_gldate
       ,p_launch_approvals_flag        => l_launch_approvals_flag  -- bug 19077847
       ,p_communication_method_option  => p_communication_method
       ,p_communication_method_value   => p_communication_value
       ,p_online_report_id             => l_online_report_id
       );

      /* Bug 8831247 ,Assigning the out parameter value to x_online_report_id */
       x_online_report_id:=l_online_report_id;

     d_pos := 130;
     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module,d_pos,'x_return_status',x_return_status);
     END IF;
     -- If the procedure does not complete successfully raise the
     -- appropriate exception
     IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE FND_API.g_exc_error;
     ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.g_exc_unexpected_error;
     END IF;


  ELSIF (p_control_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_HOLD) THEN  --Hold
    d_pos := 140;
    PO_DOCUMENT_ACTION_PVT.do_hold(
       p_document_id       => p_doc_header_id
      ,p_document_type     => p_doc_type
      ,p_document_subtype  => p_doc_subtype
      ,p_reason            => p_reason
      ,x_return_status     => x_return_status
      ,x_return_code       => l_return_code
      ,x_exception_msg     => l_exc_msg);

  ELSIF (p_control_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_RELEASE_HOLD) THEN --Release Hold
    d_pos := 150;
      PO_DOCUMENT_ACTION_PVT.do_release_hold(
          p_document_id       => p_doc_header_id
         ,p_document_type     => p_doc_type
         ,p_document_subtype  => p_doc_subtype
         ,p_reason            => p_reason
         ,x_return_status     => x_return_status
         ,x_return_code       => l_return_code
         ,x_exception_msg     => l_exc_msg);

  ELSIF (p_control_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_FREEZE) THEN --Freeze
    d_pos := 160;
    PO_DOCUMENT_ACTION_PVT.do_freeze(
        p_document_id       => p_doc_header_id
       ,p_document_type     => p_doc_type
       ,p_document_subtype  => p_doc_subtype
       ,p_reason            => p_reason
       ,x_return_status     => x_return_status
       ,x_return_code       => l_return_code
       ,x_exception_msg     => l_exc_msg);

  ELSIF (p_control_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_UNFREEZE) THEN  --Un Freeze
    d_pos := 170;
    PO_DOCUMENT_ACTION_PVT.do_unfreeze(
        p_document_id       => p_doc_header_id
       ,p_document_type     => p_doc_type
       ,p_document_subtype  => p_doc_subtype
       ,p_reason            => p_reason
       ,x_return_status     => x_return_status
       ,x_return_code       => l_return_code
       ,x_exception_msg     => l_exc_msg);

  ELSE       -- closed-state related action
    d_pos := 180;
    IF (p_doc_level = PO_CORE_S.g_doc_level_SHIPMENT)
    THEN
      select shipment_type
      into l_doc_subtype
      from po_line_locations_all
      where line_location_id = p_doc_line_loc_id;
    ELSE
      l_doc_subtype := p_doc_subtype;
    END IF;
    d_pos := 190;
    IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module,d_pos,'l_doc_subtype',l_doc_subtype);
    END IF;

    PO_DOCUMENT_ACTION_PVT.do_manual_close(
        p_action            => p_control_action
       ,p_document_id       => p_doc_header_id
       ,p_document_type     => p_doc_type
       ,p_document_subtype  => l_doc_subtype
       ,p_line_id           => p_doc_line_id
       ,p_shipment_id       => p_doc_line_loc_id
       ,p_reason            => p_reason
       ,p_action_date       => p_action_date
       ,p_calling_mode      => 'PO'
       ,p_origin_doc_id     => NULL
       ,p_called_from_conc  => FALSE
       ,p_use_gl_date       => p_use_gldate
       ,x_return_status     => x_return_status
       ,x_return_code       => l_return_code
       ,x_exception_msg     => l_exc_msg
       ,x_online_report_id  => l_online_report_id);
  END IF;  -- IF p_control_action LIKE 'CANCEL%'
  d_pos := 200;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_pos,'x_return_status',x_return_status);
    PO_LOG.stmt(d_module,d_pos,'l_return_code',l_return_code);
    PO_LOG.stmt(d_module,d_pos,'l_exc_msg',l_exc_msg);
    PO_LOG.stmt(d_module,d_pos,'l_online_report_id',l_online_report_id);
  END IF;

  IF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    IF (l_return_code = 'STATE_FAILED') THEN
      d_pos := 210;
       -- The document state was not valid for this control action
       FND_MESSAGE.set_name('PO','PO_APP_APP_FAILED');
       FND_MSG_PUB.add;
       RAISE FND_API.g_exc_error;
    ELSIF (l_return_code = 'SUBMISSION_FAILED') THEN
      d_pos := 220;
      -- Submission check failed for final close action
      IF l_online_report_id IS NULL THEN
        FND_MESSAGE.set_name('PO','PO_CONTROL_USER_EXIT_FAILED');
        FND_MESSAGE.set_token('USER_EXIT', l_control_action_disp_name);
        FND_MESSAGE.set_token('RETURN_CODE',NVL(l_return_code, fnd_message.get_string('PO','PO_ERROR')));
        FND_MSG_PUB.add;
      ELSE
        d_pos := 230;
        --Add all the messages to the message list
        PO_Document_Control_PVT.add_online_report_msgs(
            p_api_version      => 1.0
           ,p_init_msg_list    => FND_API.G_FALSE
           ,x_return_status    => x_return_status
           ,p_online_report_id => l_online_report_id);
      END IF; --l_online_report_id IS NULL
      RAISE FND_API.g_exc_error;
    -- Bug 5000165 START
    -- For Encumbrance errors, we do not need to put the messages into the
    -- online report table, since we will be showing the PSA Budgetary Control
    -- Results page.
    ELSIF (l_return_code in ('F', 'P', 'T')) THEN
      x_is_encumbrance_error := 'Y';
      x_online_report_id     :=l_online_report_id;--bug#5055417
    -- Bug 5000165 END
    END IF;--l_return_code = 'STATE_FAILED'
  ELSE
    d_pos := 240;
    IF (l_exc_msg IS NOT NULL)  THEN
      PO_LOG.exc(d_module,d_pos,l_exc_msg);
    END IF;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;--x_return_status = FND_API.G_RET_STS_SUCCESS
  d_pos := 250;

  --g_approval_initiated_flag global variable set to true after
  --PO_REQAPPROVAL_INIT1.start_wf_process is called
  IF g_approval_initiated_flag THEN
    x_approval_initiated := 'Y';
  END IF;

  --g_cancel_flag_reset_flag is set to true after the cancel flag is
  --set to N by the cancel code in control_document procedure
  IF g_cancel_flag_reset_flag THEN
    x_cancel_req_flag_reset := 'Y';
  END IF;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_pos,'x_approval_initiated',x_approval_initiated);
  END IF;
  d_pos := 260;
EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unexpected Error in ' || d_module);
      IF FND_MSG_PUB.count_msg = 0 THEN
        FND_MESSAGE.set_name('PO','PO_DOC_CONTROL_ACTION_FAILED');
        FND_MESSAGE.set_token('CONTROL_ACTION_NAME', l_control_action_disp_name);
        FND_MESSAGE.set_token('ERROR_TEXT',l_exc_msg);
        FND_MSG_PUB.add;
      END IF;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name||':'||d_pos);
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in'  || d_module);
    END IF;
END do_control_action;
------------------------------------------------------------------------
--Start of Comments
--Name: process_doc_control_action
--Pre-reqs:
--  None.
--Modifies:
-- None Directly.
--Locks:
--  None.
--Function:
-- This procedure is responsible for processing the document control actions
-- That is it locks the record, check if that control action is valid for that
-- document and finally updates the document according to the control action
--IN:
--p_mode
-- HTML mode EDIT/UPDATE/SUMMARY
--p_control_action
-- Document Control Action being executed
--p_doc_level
-- Document Level at which control Action was taken
--p_doc_header_id
-- Document Header Id
--p_doc_line_id
-- Document Line Id
--p_doc_line_loc_id
-- Document Line Location Id
--p_doc_type
-- Document Type
--p_doc_sub_type
-- Document Sub Type (type_lookup_code)
--p_action_date
-- GL Date value provided by the user
--p_use_gldate
-- Value of the Use GL Date to Unreserve Checkbox
--p_gl_date
-- GL Date Entered by the User
--p_po_encumbrance_flag
-- PO Encumbrance is enabled for that org
--p_req_encumbrance_flag
-- Req Encumbrance is enabled for that org
--p_reason
-- Possible Reason for excuting the control Action
--p_note_to_vendor
-- Not for the Supplier in case a document is being cancelled
--p_communication_method
-- Communication method selected by the user {EMAIL/FAX/PRINT/EDI/XML}
--p_communication_value
-- Communication method value provided by the user {Email Address/ Fax Number}
--p_cancel_reqs
-- value of Cancel Requisitions checkbox
--OUT:
--x_approval_initiated
-- Was approval initaited for the document
--x_return_status
-- Return Status of API .
--x_error_msg_tbl
-- table for Error messages if any .
--x_is_encumbrance_error
-- whether the error (if any) was due to encumbrance - Bug 5000165
--x_online_report_id
-- determines the online report id generated during an encumbrance transaction - Bug 5055417
--Testing:
-- Refer the Unit Test Plan for 'HTML Agreements R12'
--End of Comments
----------------------------------------------------------------------------
procedure process_doc_control_action( p_control_action       IN VARCHAR2
                                     ,p_mode                 IN VARCHAR2
                                     ,p_doc_level            IN VARCHAR2
                                     ,p_doc_header_id        IN NUMBER
                                     ,p_doc_org_id           IN NUMBER
                                     ,p_doc_line_id          IN NUMBER
                                     ,p_doc_line_loc_id      IN NUMBER
                                     ,p_doc_type             IN VARCHAR2
                                     ,p_doc_subtype          IN VARCHAR2
                                     ,p_gl_date              IN DATE
                                     ,p_po_encumbrance_flag  IN VARCHAR2
                                     ,p_req_encumbrance_flag IN VARCHAR2
                                     ,p_use_gldate           IN  VARCHAR2
                                     ,p_reason               IN  VARCHAR2
                                     ,p_note_to_vendor       IN  VARCHAR2
                                     ,p_communication_method IN  VARCHAR2
                                     ,p_communication_value  IN  VARCHAR2
                                     ,p_cancel_reqs          IN  VARCHAR2
                                     ,x_return_status        OUT NOCOPY VARCHAR2
                                     ,x_approval_initiated   OUT NOCOPY VARCHAR2
                                     ,x_cancel_req_flag_reset OUT NOCOPY VARCHAR2
                                     ,x_error_msg_tbl        OUT NOCOPY PO_TBL_VARCHAR2000
                                     ,x_is_encumbrance_error OUT NOCOPY VARCHAR2
                                     ,x_online_report_id       OUT NOCOPY NUMBER --bug#5055417
                                     )
IS
  d_pos                      NUMBER;
  l_api_name CONSTANT        VARCHAR2(30) := 'process_doc_control_action';
  d_module   CONSTANT        VARCHAR2(70) := 'po.plsql.PO_Document_Control_PVT.process_doc_control_action';
  l_mode VARCHAR2(30);
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module,'p_mode',p_mode);
    PO_LOG.proc_begin(d_module,'p_control_action',p_control_action);
    PO_LOG.proc_begin(d_module,'p_doc_level',p_doc_level);
    PO_LOG.proc_begin(d_module,'p_doc_header_id',p_doc_header_id);
    PO_LOG.proc_begin(d_module,'p_doc_org_id',p_doc_org_id);
    PO_LOG.proc_begin(d_module,'p_doc_line_id',p_doc_line_id);
    PO_LOG.proc_begin(d_module,'p_doc_line_loc_id',p_doc_line_loc_id);
    PO_LOG.proc_begin(d_module,'p_doc_type',p_doc_type);
    PO_LOG.proc_begin(d_module,'p_doc_subtype',p_doc_subtype);
    PO_LOG.proc_begin(d_module,'p_gl_date',p_gl_date);
    PO_LOG.proc_begin(d_module,'p_use_gldate',p_use_gldate);
    PO_LOG.proc_begin(d_module,'p_reason',p_reason);
    PO_LOG.proc_begin(d_module,'p_note_to_vendor',p_note_to_vendor);
    PO_LOG.proc_begin(d_module,'p_communication_method',p_communication_method);
    PO_LOG.proc_begin(d_module,'p_communication_value',p_communication_value);
    PO_LOG.proc_begin(d_module,'p_cancel_reqs',p_cancel_reqs);
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_mode := UPPER(p_mode);

  -- Standard start of API savepoint
  SAVEPOINT PROCESS_DOC_CONTROL_ACTION;
  d_pos := 10;
  -- Validate the action date
  /* Bug 6507195 : PO CBC Integration
  Parameter P_SKIP_VALID_CBC_ACCT_DATE value should be FND_API.G_FALSE to Validate Acct Date
  */
  val_action_date( p_api_version          => 1.0,
                   p_init_msg_list        => FND_API.G_TRUE,
                   x_return_status        => x_return_status,
                   p_doc_type             => p_doc_type,
                   p_doc_subtype          => p_doc_subtype,
                   p_doc_id               => p_doc_header_id,
                   p_action               => p_control_action,
                   p_action_date          => p_gl_date,
                   p_cbc_enabled          => IGC_CBC_PO_GRP.cbc_po_enabled_flag,
                   p_po_encumbrance_flag  => p_po_encumbrance_flag,
                   p_req_encumbrance_flag => p_req_encumbrance_flag,
                   p_skip_valid_cbc_acct_date => FND_API.G_FALSE); --Bug#4569120
  d_pos := 20;
  IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module,d_pos,'x_return_status',x_return_status);
  END IF;
  IF (x_return_status = FND_API.g_ret_sts_error) THEN
     RAISE FND_API.g_exc_error;
  ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
  END IF;
  d_pos := 30;
  --Do not lock the header record in case of CANCEL control Action
  --as it would be locked in the cancel_api
  IF(NOT(p_control_action LIKE 'CANCEL%' )) THEN
      PO_DOCUMENT_LOCK_GRP.lock_document( p_api_version   => 1.0
                                         ,p_init_msg_list => FND_API.G_FALSE
                                         ,x_return_status => x_return_status
                                         ,p_document_type => p_doc_type
                                         ,p_document_id   => p_doc_header_id);
  END IF;
  d_pos := 40;
  IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module,d_pos,'x_return_status',x_return_status);
  END IF;
  IF (x_return_status = FND_API.g_ret_sts_error) THEN
     RAISE FND_API.g_exc_error;
  ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
  END IF;

  d_pos := 50;
  -- validating the Cancel or Finally Close Control Action
  IF(p_control_action LIKE 'CANCEL%'
     OR p_control_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_FINALLY_CLOSE) THEN

    val_cancel_finalclose_action( p_control_action  => p_control_action
                                 ,p_doc_level       => p_doc_level
                                 ,p_doc_header_id   => p_doc_header_id
                                 ,p_doc_line_id     => p_doc_line_id
                                 ,p_doc_line_loc_id => p_doc_line_loc_id
                                 ,p_doc_type        => p_doc_type
                                 ,p_doc_subtype     => p_doc_subtype
                                 ,x_return_status   => x_return_status);
    d_pos := 60;
    IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module,d_pos,'x_return_status',x_return_status);
    END IF;
    IF (x_return_status = FND_API.g_ret_sts_error) THEN
       RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;
  END IF;


  --Executing the Control Action
  d_pos := 70;
  do_control_action( p_mode                 => l_mode
                    ,p_control_action       => p_control_action
                    ,p_doc_level            => p_doc_level
                    ,p_doc_header_id        => p_doc_header_id
                    ,p_doc_line_id          => p_doc_line_id
                    ,p_doc_line_loc_id      => p_doc_line_loc_id
                    ,p_doc_type             => p_doc_type
                    ,p_doc_subtype          => p_doc_subtype
                    ,p_action_date          => p_gl_date
                    ,p_use_gldate           => p_use_gldate
                    ,p_reason               => p_reason
                    ,p_note_to_vendor       => p_note_to_vendor
                    ,p_communication_method => p_communication_method
                    ,p_communication_value  => p_communication_value
                    ,p_cancel_reqs          => p_cancel_reqs
                    ,x_return_status        => x_return_status
                    ,x_approval_initiated   => x_approval_initiated
                    ,x_cancel_req_flag_reset =>x_cancel_req_flag_reset
                    ,x_is_encumbrance_error => x_is_encumbrance_error
                    ,x_online_report_id     => x_online_report_id);--bug#5055417
  d_pos := 80;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_pos,'x_return_status',x_return_status);
    PO_LOG.stmt(d_module,d_pos,'x_approval_initiated',x_approval_initiated);
  END IF;

  IF (x_return_status = FND_API.g_ret_sts_error) THEN
     RAISE FND_API.g_exc_error;
  ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO SAVEPOINT PROCESS_DOC_CONTROL_ACTION;
    x_return_status := FND_API.g_ret_sts_error;
    x_error_msg_tbl := PO_TBL_VARCHAR2000();
    --Copy the messages on the list to the out parameter
    FOR i IN 1..FND_MSG_PUB.count_msg LOOP
      FND_MESSAGE.set_encoded(encoded_message => FND_MSG_PUB.get(p_msg_index => i));
      x_error_msg_tbl.extend;
      x_error_msg_tbl(i) := FND_MESSAGE.get;
    END LOOP;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO SAVEPOINT PROCESS_DOC_CONTROL_ACTION;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unexpected Error in ' || d_module);
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO SAVEPOINT PROCESS_DOC_CONTROL_ACTION;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name||':'||d_pos);
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in'  || d_module);
    END IF;
END process_doc_control_action;
-------------------------------------------------------------------------------
--Start of Comments
--Name: is_backing_req_labor_expense
--Pre-reqs:
--  Must be called from Document Control window.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  For a PO line or shipment, determines if ANY backing Requisition line
--  is an Expense line or a parent Temp Labor line.
--Parameters:
--IN:
--p_doc_level_id
-- The Id of the enitity on which control Action was taken
--p_doc_level
-- Document Level at which control Action was taken
--Returns:
--  TRUE if backing Requisition line(s) exist for the given line or shipment
--  and it is an Expense or parent Temp Labor line. FALSE otherwise.
--Notes:
--  Any backing Requisition lines will be found by examining all distributions
--  of the given PO line or shipment. If the current entity is not a PO line
--  or shipment, return FALSE (i.e. this function does not apply at the
--  PO header level).
--Testing:
-- Refer the Unit Test Plan for 'HTML Agreements R12'
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_backing_req_labor_expense(p_doc_level_id IN NUMBER,
                                      p_doc_level    IN VARCHAR2)
RETURN BOOLEAN
IS
  l_po_line_id               PO_LINES_ALL.po_line_id%TYPE := NULL;
  l_line_location_id         PO_LINE_LOCATIONS_ALL.line_location_id%TYPE := NULL;
  l_has_labor_expense_req    BOOLEAN := FALSE;
  d_pos NUMBER := 0;
  l_api_name CONSTANT VARCHAR2(30) := 'is_backing_req_labor_expense';
  d_module   CONSTANT VARCHAR2(70) := 'po.plsql.PO_Document_Control_PVT.is_backing_req_labor_expense';

  -- Selects dummy string for each backing Requisition line that is an
  -- Expense or parent Temp Labor line.
  CURSOR shipment_labor_expense_req_csr ( p_line_location_id NUMBER ) IS
      SELECT 'Backing Temp Labor/Expense Req'
      FROM   po_distributions_all      pod
      ,      po_requisition_lines_all  prl
      ,      po_req_distributions_all  prd
      WHERE  pod.line_location_id = p_line_location_id             -- For each PO Distribution
      AND    pod.req_distribution_id = prd.distribution_id         -- join to backing Req Distribution
      AND    prd.requisition_line_id = prl.requisition_line_id     -- and then up to the Req Line.
      AND    (   ( prl.labor_req_line_id IS NOT NULL )             -- That Req Line must be an Expense line
             OR  ( EXISTS ( SELECT 'Parent Temp Labor Req Line'    -- or a parent Temp Labor line
                            FROM   po_requisition_lines_all prl2   -- of some Expense line.
                            WHERE  prl2.labor_req_line_id = prl.requisition_line_id
                          )
                 )
             );
  -- Selects dummy string for each backing Requisition line that is an
  -- Expense or parent Temp Labor line.
  CURSOR line_labor_expense_req_csr ( p_po_line_id NUMBER ) IS
      SELECT 'Backing Temp Labor/Expense Req'
      FROM   po_distributions_all      pod
      ,      po_requisition_lines_all  prl
      ,      po_req_distributions_all  prd
      WHERE  pod.po_line_id = p_po_line_id                         -- For each PO Distribution
      AND    pod.req_distribution_id = prd.distribution_id         -- join to backing Req Distribution
      AND    prd.requisition_line_id = prl.requisition_line_id     -- and then up to the Req Line.
      AND    (   ( prl.labor_req_line_id IS NOT NULL )             -- That Req Line must be an Expense line
             OR  ( EXISTS ( SELECT 'Parent Temp Labor Req Line'    -- or a parent Temp Labor line
                            FROM   po_requisition_lines_all prl2   -- of some Expense line.
                            WHERE  prl2.labor_req_line_id = prl.requisition_line_id
                          )
                 )
             );
  l_dummy1                   shipment_labor_expense_req_csr%ROWTYPE;
  l_dummy2                   line_labor_expense_req_csr%ROWTYPE;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module,'p_doc_level_id',p_doc_level_id);
    PO_LOG.proc_begin(d_module,'p_doc_level',p_doc_level);
  END IF;

  IF(p_doc_level = PO_CORE_S.g_doc_level_LINE) THEN
    l_po_line_id := p_doc_level_id;
  ELSIF(p_doc_level = PO_CORE_S.g_doc_level_SHIPMENT) THEN
    l_line_location_id := p_doc_level_id;
  END IF;

  d_pos := 10;
  IF ( l_line_location_id IS NOT NULL ) THEN
   d_pos := 20;
   OPEN  shipment_labor_expense_req_csr(l_line_location_id);
   FETCH shipment_labor_expense_req_csr INTO l_dummy1;
   l_has_labor_expense_req := shipment_labor_expense_req_csr%FOUND;
   CLOSE shipment_labor_expense_req_csr;
   d_pos := 30;
  ELSIF ( l_po_line_id IS NOT NULL ) THEN
   d_pos := 40;
   OPEN  line_labor_expense_req_csr(l_po_line_id);
   FETCH line_labor_expense_req_csr INTO l_dummy2;
   l_has_labor_expense_req := line_labor_expense_req_csr%FOUND;
   CLOSE line_labor_expense_req_csr;
   d_pos := 50;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module,'l_has_labor_expense_req',l_has_labor_expense_req);
    PO_LOG.proc_end(d_module,'l_line_location_id',l_line_location_id);
    PO_LOG.proc_end(d_module,'l_po_line_id',l_po_line_id);
    PO_LOG.proc_end(d_module);
  END IF;

  return (l_has_labor_expense_req);
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name||':'||d_pos);
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in'  || d_module);
    END IF;
    RAISE;
END is_backing_req_labor_expense;
-----------------------------------------------------------------------------
--Start of Comments
--Name: get_cancel_req_chkbox_attributes
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This procedure would be responsible to fetch the various attributes, which
-- would determine the UI features of the field. That is whether it should be
-- Y or N and whether it should be enabled or disabled
--Parameters:
--IN:
--p_doc_level_id
-- The Id of the enitity on which control Action was taken
--p_doc_level
-- Document Level at which control Action was taken
--p_doc_header_id
-- Document header Id
--p_doc_sub_type
-- Document Sub Type (type_lookup_code)
--p_cancel_req_on_cancel_po
-- Cancel Requisition on Cancel PO Flag
--OUT:
--x_drop_ship_flag
-- PO is a Drop Ship PO
--x_labor_expense_req_flag
-- Any backing Requisition line is an Expense line or a parent Temp Labor line
--x_svc_line_with_req_flag
-- If PO has at least one Services Line with a backing req
--x_fps_line_ship_with_req_flag
-- If any PO line or shipment of line type Fixed Price Service has
--  a backing requisition.
--x_return_status
-- Return Status of API .
--x_is_partially_received_billed
--PO is partially received or billed
--p_doc_type
--Document Type
--Testing:
-- Refer the Unit Test Plan for 'HTML Agreements R12'
--End of Comments
----------------------------------------------------------------------------
procedure get_cancel_req_chkbox_attr(p_doc_level_id                 IN NUMBER,
                                     p_doc_header_id                IN NUMBER,
                                     p_doc_level                    IN VARCHAR2,
                                     p_doc_subtype                  IN VARCHAR2,
                                     p_cancel_req_on_cancel_po      IN VARCHAR2,
                                     x_drop_ship_flag               OUT NOCOPY VARCHAR2,
                                     x_labor_expense_req_flag       OUT NOCOPY VARCHAR2,
                                     x_svc_line_with_req_flag       OUT NOCOPY VARCHAR2,
                                     x_fps_line_ship_with_req_flag  OUT NOCOPY VARCHAR2,
                                     x_return_status                OUT NOCOPY VARCHAR2,
				     x_is_partially_received_billed OUT NOCOPY VARCHAR2, --Bug 16276254
				     p_doc_type  		    IN VARCHAR2 --Bug 16276254
				    )
IS
  d_pos      NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'get_cancel_req_chkbox_attr';
  d_module   CONSTANT VARCHAR2(70) := 'po.plsql.PO_Document_Control_PVT.get_cancel_req_chkbox_attr';
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module,'p_doc_level_id',p_doc_level_id);
    PO_LOG.proc_begin(d_module,'p_doc_level',p_doc_level);
    PO_LOG.proc_begin(d_module,'p_doc_subtype',p_doc_subtype);
    PO_LOG.proc_begin(d_module,'p_cancel_req_on_cancel_po',p_cancel_req_on_cancel_po);
  END IF;
  d_pos := 10;
  --Initialise Out Variables
  x_drop_ship_flag              := 'N';
  x_labor_expense_req_flag      := 'N';
  x_svc_line_with_req_flag      := 'N';
  x_fps_line_ship_with_req_flag := 'N';
  x_return_status                := FND_API.g_ret_sts_success;
  x_is_partially_received_billed := 'N';--Bug 16276254
  --Check for dropship PO
  IF(PO_COPYDOC_S1.po_is_dropship(p_doc_header_id)) THEN
   x_drop_ship_flag := 'Y';
   RAISE PO_CORE_S.g_early_return_exc;
  END IF;

  d_pos := 20;

  IF p_cancel_req_on_cancel_po <> 'A' THEN
    -- Check if backing Requisition line(s) exist for the given line or shipment
    -- and it is an Expense or parent Temp Labor line.
    IF(is_backing_req_labor_expense(p_doc_level_id => p_doc_level_id,
                                    p_doc_level => p_doc_level)) THEN
      d_pos := 30;
      x_labor_expense_req_flag := 'Y';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_pos := 40;
    -- Check if a given PO contains at least one Services line, i.e. if the
    -- value basis of any line is FIXED PRICE or  RATE
    IF(p_doc_level = PO_CORE_S.g_doc_level_HEADER
       AND p_doc_subtype = PO_CONSTANTS_SV.STANDARD) THEN

      IF (PO_SERVICES_PVT.check_po_has_svc_line_with_req(p_doc_header_id)) THEN
        d_pos := 50;
        x_svc_line_with_req_flag := 'Y';
        RAISE PO_CORE_S.g_early_return_exc;
       END IF;
    END IF; --p_doc_level = 'HEADER'  AND docSubType = 'STANDARD'

    d_pos := 60;
    --  Checks if the line type is Fixed Price Service AND a backing
    -- requisition exists for the given line or shipment
    IF(p_doc_subtype = PO_CONSTANTS_SV.STANDARD) THEN
      IF p_doc_level = PO_CORE_S.g_doc_level_LINE THEN
        IF PO_SERVICES_PVT.is_FPS_po_line_with_req(p_doc_level_id) THEN
           x_fps_line_ship_with_req_flag := 'Y';
        END IF;
      ELSIF p_doc_level = PO_CORE_S.g_doc_level_SHIPMENT THEN
        IF PO_SERVICES_PVT.is_FPS_po_shipment_with_req(p_doc_level_id) THEN
           x_fps_line_ship_with_req_flag := 'Y';
        END IF;
      END IF; --p_doc_level = 'LINE'
    END IF; --p_doc_subtype = 'STANDARD'
  END IF; --p_cancel_req_on_cancel_po = 'A'

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module,'x_drop_ship_flag',x_drop_ship_flag);
    PO_LOG.proc_end(d_module,'x_labor_expense_req_flag',x_labor_expense_req_flag);
    PO_LOG.proc_end(d_module,'x_svc_line_with_req_flag',x_svc_line_with_req_flag);
    PO_LOG.proc_end(d_module,'x_fps_line_ship_with_req_flag',x_fps_line_ship_with_req_flag);
    PO_LOG.proc_end(d_module,'x_return_status',x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  --Checks if there were any partial transactions done on the PO (Bug 16276254)
  IF PO_Document_Cancel_PVT.isPartialRcvBilled(
      p_api_version   => 1.0,
      p_init_msg_list => FND_API.G_FALSE,
      p_entity_level=> p_doc_level,
      p_document_type=> p_doc_type,
      p_entity_id=> p_doc_level_id)
  THEN
    x_is_partially_received_billed := 'Y';
  END IF;
  --Bug 16276254

EXCEPTION
  WHEN PO_CORE_S.g_early_return_exc THEN
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module,d_pos,'Early exit from ' || d_module);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name||':'||d_pos);
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in'  || d_module);
    END IF;
END get_cancel_req_chkbox_attr;
------------------------------------------------------------------------------
--Start of Comments
--Name: get_valid_control_actions
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This procedure would get us the list of valid Document Control Actions
-- for a given
-- document and the level for which it is requested.
--Parameters:
--IN:
--p_mode
-- The mode in which the document is <CREATE/UPDATE/SUMMARY/VIEW>
--p_doc_type
-- The document Type (PO/PA)
--p_doc_level
-- Document Level at which control Action was taken
--p_doc_level_id
-- The Id of the enitity on which control Action was taken
--p_doc_type
-- Document Type
--p_doc_header_id
-- Document Header Id
--p_item_id
-- If the p_doc_level is 'LINE', the Item ID of the Item on the line
--OUT:
--x_valid_ctrl_ctn_tbl
-- List of valid Document Control Actions for the given entity .
--x_return_status
-- Return Status of API .
--Testing:
-- Refer the Unit Test Plan for 'HTML Agreements R12'
--End of Comments
-----------------------------------------------------------------------------
procedure get_valid_control_actions( p_mode                IN   VARCHAR2
                                    ,p_doc_level           IN   VARCHAR2
                                    ,p_doc_type            IN   VARCHAR2
                                    ,p_doc_header_id       IN   NUMBER
                                    ,p_doc_level_id        IN   NUMBER
                                    ,x_return_status       OUT  NOCOPY VARCHAR2
                                    ,x_valid_ctrl_ctn_tbl  OUT  NOCOPY PO_TBL_VARCHAR30)
IS
  l_valid_actions_tbl g_lookup_code_tbl_type;
  l_displayed_field_tbl   g_displayed_field_tbl_type;
  l_doc_subtype           PO_HEADERS_ALL.type_lookup_code%type;
  l_cons_trans_exist      VARCHAR2(1);
  l_index                 NUMBER;
  l_agent_id              NUMBER;
  l_item_id               PO_LINES_ALL.item_Id%TYPE;
  l_po_line_id            PO_LINES_ALL.po_line_id%TYPE;
  l_current_action        PO_LOOKUP_CODES.lookup_code%TYPE;
  l_mode                  VARCHAR2(30);
  l_ship_invalid_for_ctrl_actn  VARCHAR2(1) := 'N';
  d_pos      NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'get_valid_control_actions';
  d_module   CONSTANT VARCHAR2(70) := 'po.plsql.PO_Document_Control_PVT.get_valid_control_actions';
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module,'p_mode',p_mode);
    PO_LOG.proc_begin(d_module,'p_doc_level',p_doc_level);
    PO_LOG.proc_begin(d_module,'p_doc_type',p_doc_type);
    PO_LOG.proc_begin(d_module,'p_doc_header_id',p_doc_header_id);
    PO_LOG.proc_begin(d_module,'p_doc_level_id',p_doc_level_id);
  END IF;
  --Initialisation of local variables
  x_return_status := FND_API.g_ret_sts_success;
  l_cons_trans_exist := 'N';
  l_index := 1;
  l_mode := UPPER(p_mode);
  x_valid_ctrl_ctn_tbl := PO_TBL_VARCHAR30();
  d_pos := 10;
  --Get the Employee Id of the Current User
  l_agent_id := fnd_global.employee_id;
  --Get Document Sub type
  IF(p_doc_type IN (PO_CORE_S.g_doc_type_PO, PO_CORE_S.g_doc_type_PA)) THEN
    SELECT type_lookup_code
    INTO l_doc_subtype
    FROM po_headers_all
    WHERE po_header_id = p_doc_header_id;
  END IF;
  d_pos := 20;
  IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module,d_pos,'l_agent_id',l_agent_id);
       PO_LOG.stmt(d_module,d_pos,'l_doc_subtype',l_doc_subtype);
  END IF;
  IF (p_doc_level = PO_CORE_S.g_doc_level_HEADER) THEN   --header level
    d_pos := 30;
    PO_DOCUMENT_CONTROL_PVT.get_header_actions
                ( p_doc_subtype         => l_doc_subtype
                , p_doc_id              => p_doc_level_id
                , p_agent_id            => l_agent_id
                , x_lookup_code_tbl     => l_valid_actions_tbl
                , x_displayed_field_tbl => l_displayed_field_tbl
                , x_return_status       => x_return_status
                , p_mode                => l_mode);

  ELSIF (p_doc_level = PO_CORE_S.g_doc_level_LINE) THEN   --line level
    d_pos := 40;
    --get the itme_id for the consumption transaction existence check
    SELECT item_id
    INTO l_item_id
    FROM po_lines_all
    WHERE po_line_id = p_doc_level_id;

    IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module,d_pos,'l_item_id',l_agent_id);
    END IF;

    PO_DOCUMENT_CONTROL_PVT.get_line_actions
                ( p_doc_subtype         => l_doc_subtype
                , p_doc_line_id         => p_doc_level_id
                , p_agent_id            => l_agent_id
                , x_lookup_code_tbl     => l_valid_actions_tbl
                , x_displayed_field_tbl => l_displayed_field_tbl
                , x_return_status       => x_return_status
                , p_mode                => l_mode);

  ELSIF (p_doc_level = PO_CORE_S.g_doc_level_SHIPMENT) THEN
     d_pos := 50;
     --shipment levl
     PO_DOCUMENT_CONTROL_PVT.get_shipment_actions
                ( p_doc_type            => p_doc_type
                , p_doc_subtype         => l_doc_subtype
                , p_doc_line_loc_id     => p_doc_level_id
                , p_agent_id            => l_agent_id
                , x_lookup_code_tbl     => l_valid_actions_tbl
                , x_displayed_field_tbl => l_displayed_field_tbl
                , x_return_status       => x_return_status
                , p_mode                => l_mode);

  END IF;
  IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module,d_pos,'x_return_status',x_return_status);
  END IF;
  d_pos := 60;

  IF (x_return_status = FND_API.g_ret_sts_success)then

    IF p_doc_level IN (PO_CORE_S.g_doc_level_HEADER, PO_CORE_S.g_doc_level_LINE) THEN
      -- Checks  if there exists a consumption transaction that is in process for
      -- the passed in transaction source document ID and and item ID.
      l_cons_trans_exist := PO_INV_THIRD_PARTY_STOCK_MDTR.consumption_trans_exist(
                                                        p_doc_header_id,
                                                        l_item_id);
    END IF;
    d_pos := 70;
    IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module,d_pos,'l_cons_trans_exist',l_cons_trans_exist);
    END IF;
    --<Bug#4515762 Start>
    --Prevent cancel option for shipment if it is the only shipment on the
    --line that is not cancelled or finally closed.
    IF(p_doc_level = PO_CORE_S.g_doc_level_SHIPMENT) THEN

       BEGIN
         d_pos := 75;
         SELECT 'N'
         INTO l_ship_invalid_for_ctrl_actn
         FROM DUAL
         WHERE EXISTS(
           SELECT 1
           FROM po_line_locations_all poll1,
                po_line_locations_all poll2
           WHERE poll1.line_location_id = p_doc_level_id
           AND poll1.po_line_id  = poll2.po_line_id
           AND NVL(poll2.cancel_flag,'N') <> 'Y'
           AND NVL(poll2.payment_type, 'NULL') NOT IN ('ADVANCE', 'DELIVERY') --<Complex Work R12>
           AND NVL(poll2.closed_code, PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN)
                 <> PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_FIN_CLOSED
           AND poll2.line_location_id <> p_doc_level_id);
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           --Current shipment is the only shipment on the line that is not cancelled or finally closed
           --OR there are no open, uncancelled shipments.
           IF PO_LOG.d_stmt THEN
             PO_LOG.stmt(d_module,d_pos,'Control Action cannot be performed on the shipment');
           END IF;
           l_ship_invalid_for_ctrl_actn := 'Y';
       END;

    END IF; --p_doc_level = PO_CORE_S.g_doc_level_SHIPMENT
    --<Bug#4515762 End>

    FOR i IN l_valid_actions_tbl.first..l_valid_actions_tbl.last
    LOOP
        d_pos := 80;
      l_current_action := l_valid_actions_tbl(i);
      IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module,d_pos,'l_current_action',l_current_action);
      END IF;
      -- If consumption transaction exist we don't allow Cancel and Finally
      -- Close actions
      IF (l_cons_trans_exist = 'Y'
          AND l_current_action in ('CANCEL PO','CANCEL PO LINE', PO_DOCUMENT_ACTION_PVT.g_doc_action_FINALLY_CLOSE)) THEN
        NULL;
      --If it is the only shipment then we dont allow the cancellation or finally closing of the shipment.
      ELSIF(l_ship_invalid_for_ctrl_actn = 'Y'
            AND l_current_action in ('CANCEL PO SHIPMENT', PO_DOCUMENT_ACTION_PVT.g_doc_action_FINALLY_CLOSE)) THEN
        NULL;
      ELSE
        -- For Update Mode only Cancel Related And Hold Related
        -- Control Actions are valid
        IF(l_mode = 'UPDATE'
           AND NOT (l_current_action LIKE 'CANCEL%'
                    OR l_current_action LIKE '%HOLD%')) THEN
          NULL;
        ELSE
          x_valid_ctrl_ctn_tbl.extend;
          IF(l_mode = 'SUMMARY' AND l_current_action LIKE 'CANCEL%' ) THEN
          -- For Summary we Show Cancel Action as Cancel at all the Levels
            d_pos := 90;
            IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_module,d_pos,l_current_action || 'is replaced by CANCEL for summary mode');
            END IF;
            x_valid_ctrl_ctn_tbl(l_index) := PO_DOCUMENT_ACTION_PVT.g_doc_action_CANCEL;
          ELSIF(l_mode = 'UPDATE' AND l_current_action = 'CANCEL PO') THEN

            IF(p_doc_type = PO_CORE_S.g_doc_type_PO)  THEN
              -- For Update mode we Show Cancel Action at Header as Cancel Order
              d_pos := 100;
              IF (PO_LOG.d_stmt) THEN
                PO_LOG.stmt(d_module,d_pos,l_current_action || 'is replaced by CANCEL ORDER for update mode');
              END IF;
              x_valid_ctrl_ctn_tbl(l_index) := 'CANCEL ORDER';
            ELSIF(p_doc_type = PO_CORE_S.g_doc_type_PA)  THEN
              -- For Update mode we Show Cancel Action at Header as Cancel Agreement.
              d_pos := 110;
              IF (PO_LOG.d_stmt) THEN
                PO_LOG.stmt(d_module,d_pos,l_current_action || 'is replaced by CANCEL AGREEMENT for update mode');
              END IF;
              x_valid_ctrl_ctn_tbl(l_index) := 'CANCEL AGREEMENT';
            END IF; -- (p_doc_type = 'PO')
          ELSE
            d_pos := 120;
            IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_module,d_pos,l_current_action || 'is directly placed');
            END IF;
            x_valid_ctrl_ctn_tbl(l_index) := l_valid_actions_tbl(i);
          END IF; --mode = 'SUMMARY' AND l_current_action LIKE 'CANCEL%'
          l_index := l_index+1;
        END IF; --l_mode = 'UPDATE'
      END IF; -- l_cons_trans_exist = 'Y'
    END LOOP;

  ELSIF (x_return_status = FND_API.g_ret_sts_error)then
    d_pos := 130;
    IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module,d_pos,'No Valid Control Action Found');
    END IF;
  ELSE
    d_pos := 140;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF; --x_return_status = FND_API.g_ret_sts_success
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name||':'||d_pos);
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in'  || d_module);
    END IF;
END get_valid_control_actions;

--------------------------------------------------------------------------------
--<Bug 14271696 :Cancel Refactoring Project (Communicate)>
--Start of Comments
--Name: doc_communicate_oncancel
--Function:
--  called after the successful cancel action
--  method to communicate the docuemnt status to the Supplier
--Parameters:
--IN:
-- p_doc_type
-- p_doc_subtype
-- p_doc_id
-- p_communication_method_option
-- p_communication_method_value

--
--IN OUT :
--OUT :

-- x_return_status
--     FND_API.G_RET_STS_SUCCESS if communicate action succeeds
--     FND_API.G_RET_STS_ERROR if communicate action fails
--     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------


PROCEDURE doc_communicate_oncancel(
            p_doc_type                     IN VARCHAR2,
            p_doc_subtype                  IN VARCHAR2,
            p_doc_id                       IN NUMBER,
            p_communication_method_option  IN VARCHAR2,
            p_communication_method_value   IN VARCHAR2,
            x_return_status                OUT NOCOPY VARCHAR2
  )
  IS

    d_api_name    CONSTANT VARCHAR2(30) := 'doc_communicate_oncancel';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module      CONSTANT VARCHAR2(100) := g_pkg_name|| d_api_name;
    l_progress    VARCHAR2(3)  := '000' ;

    --bug 16676826, remove the prefixe po.
    --l_conterms_exist_flag     po.PO_HEADERS_ALL.conterms_exist_flag%TYPE;
	l_conterms_exist_flag     PO_HEADERS_ALL.conterms_exist_flag%TYPE;
    l_auth_status   VARCHAR2(30);
    l_revision_num  NUMBER;
    l_request_id    NUMBER := 0;
    l_doc_type      VARCHAR2(30);
    l_archive_count NUMBER;
    l_item_key      varchar2(60);

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select p_doc_id || '-' || to_char(PO_WF_ITEMKEY_S.NEXTVAL)
      into l_item_key
      from sys.dual;

    IF g_debug_stmt THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        PO_DEBUG.debug_begin(d_module);
        PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_type', p_doc_type);
        PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
        PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_id', p_doc_id);
        PO_DEBUG.debug_var(d_module, l_progress, 'l_item_key', l_item_key);
        PO_DEBUG.debug_var(d_module, l_progress, 'p_communication_method_value', p_communication_method_value);
        PO_DEBUG.debug_var(d_module, l_progress, 'p_communication_method_option', p_communication_method_option);
        PO_DEBUG.debug_var(d_module, l_progress, 'Cancel Communicate Process Start Time', to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
      END IF;
    END IF;

    --Bug#18301844
    -- Call COmmunicate process Workflow
    PO_REQAPPROVAL_INIT1.cancel_comm_process
    ( ItemType => 'POAPPRV',
      ItemKey => l_item_key,
      WorkflowProcess => 'COMMUNICATE_CANCEL',
      ActionOriginatedFrom => 'CANCEL',
      DocumentId => p_doc_id,
      DocumentTypeCode => p_doc_type,
      DocumentSubtype => p_doc_subtype,
      SubmitterAction => 'CANCEL',
      p_Background_Flag => 'N',   --bug#19214300
      p_communication_method_value => p_communication_method_value,  --bug#19214300
      p_communication_method_option => p_communication_method_option --bug#19214300
    );


    IF g_debug_stmt THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        PO_DEBUG.debug_end(d_module);
        PO_DEBUG.debug_var(d_module, l_progress, 'Cancel Communicate Process End Time', to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
      END IF;
    END IF;

    /*
    IF  p_communication_method_option IS NOT NULL THEN

      IF p_doc_type <> 'RELEASE' THEN

        l_progress :='001';
        l_doc_type := p_doc_subtype;

        SELECT  Nvl(conterms_exist_flag,'N'),
                authorization_status,
                revision_num
        INTO    l_conterms_exist_flag,
                l_auth_status,
                l_revision_num
        FROM    po_headers_all
        WHERE   po_header_id = p_doc_id;

      ELSE

        l_progress :='002';

        l_doc_type :=p_doc_type;
        select  'N',
                authorization_status,
                revision_num
        INTO    l_conterms_exist_flag,
                l_auth_status,
                l_revision_num
        FROM    po_releases_all
        WHERE   po_release_id = p_doc_id;

      END IF;

      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          PO_DEBUG.debug_var(d_module,l_progress,'l_conterms_exist_flag',l_conterms_exist_flag);
          PO_DEBUG.debug_var(d_module,l_progress,'l_auth_status',l_auth_status);
          PO_DEBUG.debug_var(d_module,l_progress,'l_revision_num',l_revision_num);
          PO_DEBUG.debug_var(d_module,l_progress,'l_doc_type',l_doc_type);
        END IF;
      END IF;
      l_archive_count := 1;

      -- When the document is not in Approved/Pre-Approved status, the
      -- latest revision FROM archive is used FOR communication
      -- So in case Archive entry does not exists for teh document, the
      -- po_communication_pvt.communicate routine will through No_data_Found exception
      -- So calling the communication routine only for document in Approved/Pre-Approved status
      -- Or for those, teh archive entry exists.

      IF l_auth_status NOT IN (po_document_action_pvt.g_doc_status_APPROVED,
                               po_document_action_pvt.g_doc_status_PREAPPROVED)
      THEN
        IF p_doc_type <> 'RELEASE' THEN

          l_progress :='003';
          SELECT  Count(1)
          INTO    l_archive_count
          FROM    po_headers_archive_all
          WHERE   po_header_id = p_doc_id;

        ELSE
          l_progress :='004';
          SELECT Count(1)
          INTO   l_archive_count
          FROM   po_releases_archive_all
          WHERE  po_release_id = p_doc_id;

        END IF;


      END IF;

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module,l_progress,'l_archive_count',l_archive_count);
      END IF;

      IF  l_archive_count >0 THEN

        l_progress :='005';
        po_communication_pvt.communicate(
          p_authorization_status=>l_auth_status,
          p_with_terms=>l_conterms_exist_flag,
          p_language_code=>FND_GLOBAL.CURRENT_LANGUAGE,
          p_mode =>p_communication_method_option,
          p_document_id =>p_doc_id,
          p_revision_number =>l_revision_num,
          p_document_type =>l_doc_type,
          p_fax_number =>p_communication_method_value,
          p_email_address =>p_communication_method_value,
          p_request_id =>l_request_id);

        IF g_debug_stmt
           AND (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          PO_DEBUG.debug_var(d_module,l_progress,'l_request_id',l_request_id);
        END IF;
      END IF;


    END IF;*/

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);


    WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END doc_communicate_oncancel;


/*Added for bug:18202450 to get the cancel backing requisition field attributes to display in buyer response for PO cancellation*/

PROCEDURE cancelbackingReq(
    p_doc_header_id  IN NUMBER,
    p_doc_line_id    IN NUMBER DEFAULT NULL,
    p_doc_lineloc_id IN NUMBER DEFAULT NULL ,
    isCancelChkBoxReadonly OUT NOCOPY BOOLEAN ,
    cancelReqVal OUT NOCOPY           VARCHAR2,
    x_return_status OUT NOCOPY        VARCHAR2 )
IS
  d_api_name                     CONSTANT VARCHAR2(30)  := 'cancelbackingReq';
  d_api_version                  CONSTANT NUMBER        := 1.0;
  d_module                       CONSTANT VARCHAR2(100) := g_pkg_name|| d_api_name;
  l_progress                     VARCHAR2(3)            := '000' ;
  docLevel                       VARCHAR2(20);
  docLevelId                     NUMBER;
  cancelReqOnPoCancel            VARCHAR2(100);
  doc_subtype                    VARCHAR2(100);
  document_type                  VARCHAR2(100);
  x_drop_ship_exists             VARCHAR2(10);
  x_labor_expense_req_exist      VARCHAR2(10);
  x_svc_line_with_req_exists     VARCHAR2(10);
  x_fps_line_ship_with_req_exist VARCHAR2(10);
  x_is_partially_received_billed VARCHAR2(10);
  l_is_cto_order                 BOOLEAN := FALSE;
  x_return_status2               VARCHAR2(10);
  x_is_complex_flag              VARCHAR2(10);
  CANCEL_REQ_ALWAYS              VARCHAR2(10) := 'A';
  CANCEL_REQ_OPTIONAL            VARCHAR2(10) := 'O';
  CANCEL_REQ_NEVER               VARCHAR2(10) := 'N';
BEGIN

  docLevelId             := NULL;
  isCancelChkBoxReadonly := FALSE;
  cancelReqVal           := NULL;

  SELECT NVL(PSP.cancel_reqs_on_po_cancel_flag,'N')
  INTO cancelReqOnPoCancel
  FROM po_system_parameters_all PSP,
    po_headers_all poh
  WHERE poh.org_id      =psp.org_id
  AND poh.po_header_id  =p_doc_header_id ;

  l_progress           := '001';
  IF (p_doc_lineloc_id IS NOT NULL) THEN
    docLevelId         := p_doc_lineloc_id ;
    docLevel           :='SHIPMENT';
  ELSIF(p_doc_line_id  IS NOT NULL) THEN
    docLevelId         := p_doc_line_id ;
    docLevel           :='LINE';
  ELSE
    docLevelId := p_doc_header_id ;
    docLevel   :='HEADER';
  END IF;

  l_progress := '002';
  SELECT type_lookup_code
  INTO doc_subtype
  FROM po_headers_all
  WHERE po_header_id = p_doc_header_id;

  l_progress        := '003';
  IF((doc_subtype    = 'STANDARD') OR (doc_subtype = 'PLANNED')) THEN
    document_type   := 'PO';
  ELSE
    document_type := 'PA';
  END IF;

  l_progress := '004';
  PO_DOCUMENT_CONTROL_PVT.get_cancel_req_chkbox_attr(
							p_doc_level_id => docLevelId ,
							p_doc_header_id => p_doc_header_id ,
							p_doc_level => docLevel ,
							p_doc_subtype => doc_subtype ,
							p_cancel_req_on_cancel_po => cancelReqOnPoCancel ,
							x_drop_ship_flag => x_drop_ship_exists ,
							x_labor_expense_req_flag => x_labor_expense_req_exist , x_svc_line_with_req_flag => x_svc_line_with_req_exists , x_fps_line_ship_with_req_flag => x_fps_line_ship_with_req_exist , x_return_status => x_return_status ,
							x_is_partially_received_billed => x_is_partially_received_billed , p_doc_type => document_type );


  l_progress        := '005';
  IF(x_return_status = 'S') THEN
    l_is_cto_order  := PO_Document_Cancel_PVT.is_document_cto_order( p_doc_header_id,document_type );

    l_progress      := '006';
    PO_COMPLEX_WORK_GRP.is_complex_work_po
						( p_api_version => 1.0,
						  p_po_header_id => p_doc_header_id,
						  x_return_status => x_return_status2,
						  x_is_complex_flag => x_is_complex_flag );

    l_progress := '007';
    -- Set the cancel req flag to YES if the document is a CTO order
    IF ((l_is_cto_order IS NOT NULL) AND (l_is_cto_order = TRUE)) THEN
      cancelReqVal          := 'Y';
    elsif (x_drop_ship_exists='Y') THEN
      --If PO is a Drop Ship PO. Set the Cancel Req Flag to N
      cancelReqVal            := 'N';
    elsif((cancelReqOnPoCancel = CANCEL_REQ_ALWAYS) OR x_labor_expense_req_exist = 'Y' OR x_fps_line_ship_with_req_exist = 'Y') THEN
      --If PO satisfies one of the above condition. Set the Cancel Req
      --Flag to Y
      cancelReqVal           := 'Y';
    elsif(cancelReqOnPoCancel = CANCEL_REQ_NEVER) THEN --For cases when the profile value if set to Never
      IF((x_is_complex_flag   = 'Y') AND (x_is_partially_received_billed='Y')) THEN
        cancelReqVal         := 'Y';
      ELSE
        cancelReqVal := 'N';
      END IF;
    elsif(cancelReqOnPoCancel   = CANCEL_REQ_OPTIONAL) THEN
      IF(x_is_complex_flag      = 'Y' AND x_is_partially_received_billed = 'Y') THEN
        cancelReqVal           := 'Y';
        isCancelChkBoxReadonly := TRUE ;
      END IF;
    END IF;
    --If we get a value from above we disable the checkbox else default it to N
    --leave it enabled
    IF(cancelReqVal          IS NOT NULL) THEN
      isCancelChkBoxReadonly := TRUE;
    END IF;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
WHEN OTHERS THEN
  FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END cancelbackingReq;




END PO_Document_Control_PVT;

/
