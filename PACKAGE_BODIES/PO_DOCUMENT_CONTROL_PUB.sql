--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_CONTROL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_CONTROL_PUB" AS
/* $Header: POXPDCOB.pls 120.2.12010000.3 2012/08/21 06:57:21 vlalwani ship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';


/**
 * Public Procedure: control_document
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: All columns related to the control action, and who columns. The API
 *   message list.
 * Effects: Performs the control action p_action on the specified document.
 *   Currently, only the 'CANCEL' action is supported. If the control action was
 *   successful, the document will be updated at the specified entity level.
 *   Derives any ID if the ID is NULL, but the matching number is passed in. If
 *   both the ID and number are passed in, the ID is used. Executes at shipment
 *   level if the final doc_id, line_id, and line_loc_id are not NULL. Executes
 *   at line level if only the final doc_id and line_id are not NULL. Executes
 *   at header level if only the final doc_id is not NULL. The document will be
 *   printed if it is a PO, PA, or RELEASE, and the p_print_flag is 'Y'. All
 *   changes will be committed upon success if p_commit is FND_API.G_TRUE.
 *   Appends to API message list on error, and leaves the document unchanged.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if control action succeeds
 *                     FND_API.G_RET_STS_ERROR if control action fails
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE control_document
   (p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2,
    p_commit           IN   VARCHAR2,
    x_return_status    OUT  NOCOPY VARCHAR2,
    p_doc_type         IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype      IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id           IN   NUMBER,
    p_doc_num          IN   PO_HEADERS.segment1%TYPE,
    p_release_id       IN   NUMBER,
    p_release_num      IN   NUMBER,
    p_doc_line_id      IN   NUMBER,
    p_doc_line_num     IN   NUMBER,
    p_doc_line_loc_id  IN   NUMBER,
    p_doc_shipment_num IN   NUMBER,
    p_action           IN   VARCHAR2,
    p_action_date      IN   DATE,
    p_cancel_reason    IN   PO_LINES.cancel_reason%TYPE,
    p_cancel_reqs_flag IN   VARCHAR2,
    p_print_flag       IN   VARCHAR2,
    p_note_to_vendor   IN   PO_HEADERS.note_to_vendor%TYPE,
    p_use_gldate       IN   VARCHAR2,  -- <ENCUMBRANCE FPJ>
    p_org_id           IN   NUMBER --<Bug#4581621>
   )
IS

l_api_name CONSTANT VARCHAR2(30) := 'control_document';
l_api_version CONSTANT NUMBER := 1.0;
l_org_id  PO_HEADERS_ALL.org_id%type := p_org_id;
BEGIN
    -- Start standard API initialization
    SAVEPOINT control_document_PUB;
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

    IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                      '.invoked', 'Action: ' || NVL(p_action,'null') ||
                      ', Type: ' || NVL(p_doc_type,'null') ||
                      ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
       END IF;
    END IF;

    --<Bug#4581621 Start>
    PO_MOAC_UTILS_PVT.validate_orgid_pub_api(x_org_id => l_org_id);
    PO_MOAC_UTILS_PVT.set_policy_context('S',l_org_id);
    --<Bug#4581621 End>

    PO_Document_Control_GRP.control_document
           (p_api_version      => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_commit           => FND_API.G_FALSE,
            x_return_status    => x_return_status,
            p_doc_type         => p_doc_type,
            p_doc_subtype      => p_doc_subtype,
            p_doc_id           => p_doc_id,
            p_doc_num          => p_doc_num,
            p_release_id       => p_release_id,
            p_release_num      => p_release_num,
            p_doc_line_id      => p_doc_line_id,
            p_doc_line_num     => p_doc_line_num,
            p_doc_line_loc_id  => p_doc_line_loc_id,
            p_doc_shipment_num => p_doc_shipment_num,
            p_source           => NULL,     -- p_source is currently unresolved
            p_action           => p_action,
            p_action_date      => p_action_date,
            p_cancel_reason    => p_cancel_reason,
            p_cancel_reqs_flag => p_cancel_reqs_flag,
            p_print_flag       => p_print_flag,
            p_note_to_vendor   => p_note_to_vendor,
            p_use_gldate       => p_use_gldate  -- <ENCUMBRANCE FPJ>
           );

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;


    -- Standard API check of p_commit
    IF FND_API.to_boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
EXCEPTION
    WHEN FND_API.g_exc_error THEN
        ROLLBACK TO control_document_PUB;
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        ROLLBACK TO control_document_PUB;
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        ROLLBACK TO control_document_PUB;
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            IF (g_fnd_debug = 'Y') THEN
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                 FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                               l_api_name || '.others_exception', 'Exception');
               END IF;
            END IF;
        END IF;
END control_document;



/**
 * Public Procedure: control_document
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: All columns related to the control action, and who columns. The API
 *   message list.
 * Effects: Performs the control action p_action on the specified document.
 *   Currently, only the 'CANCEL' action is supported. If the control action was
 *   successful, the document will be updated at the specified entity level.
 *   Derives any ID if the ID is NULL, but the matching number is passed in. If
 *   both the ID and number are passed in, the ID is used. Executes at shipment
 *   level if the final doc_id, line_id, and line_loc_id are not NULL. Executes
 *   at line level if only the final doc_id and line_id are not NULL. Executes
 *   at header level if only the final doc_id is not NULL. The document will be
 *   printed if it is a PO, PA, or RELEASE, and the p_print_flag is 'Y'. All
 *   changes will be committed upon success if p_commit is FND_API.G_TRUE.
 *   Appends to API message list on error, and leaves the document unchanged.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if control action succeeds
 *                     FND_API.G_RET_STS_ERROR if control action fails
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */

PROCEDURE control_document(
  p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2,
  p_commit               IN   VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2,
  po_doc_tbl             IN   po_document_control_pub.PO_DTLS_REC_TBL,
  p_action               IN   VARCHAR2,
  p_action_date          IN   DATE,
  p_cancel_reason        IN   PO_LINES.cancel_reason%TYPE,
  p_cancel_reqs_flag     IN   VARCHAR2,
  p_print_flag           IN   VARCHAR2,
  p_revert_chg_flag      IN   VARCHAR2,
  p_launch_approvals_flag IN   VARCHAR2,
  p_note_to_vendor       IN   PO_HEADERS.note_to_vendor%TYPE,
  p_use_gldate           IN   VARCHAR2 DEFAULT NULL,
  p_org_id               IN   NUMBER DEFAULT NULL
  )
  IS

  l_api_name CONSTANT VARCHAR2(30) := 'control_document';
  l_api_version CONSTANT NUMBER := 1.0;
  l_org_id  PO_HEADERS_ALL.org_id%type := p_org_id;


  l_entity_dtl_rec_tbl  po_document_action_pvt.entity_dtl_rec_type_tbl;
  l_online_report_id    NUMBER;
  l_exc_msg             VARCHAR2(2000);
  l_return_code         VARCHAR2(25);
  l_communication_method_option VARCHAR2(30);
  l_communication_method_value  VARCHAR2(30);
  l_old_auth_status_tbl  PO_TBL_VARCHAR30;
  l_doc_id_tbl po_tbl_number :=PO_TBL_NUMBER();
  id_count NUMBER :=0;
  l_doc_id NUMBER;
  l_doc_line_id NUMBER;
  l_doc_line_loc_id NUMBER;



  BEGIN

     -- Start standard API initialization
    SAVEPOINT control_document_PUB;
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(
             l_api_version, p_api_version,
             l_api_name, g_pkg_name)
    THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                    '.invoked', 'Action: ' || NVL(p_action,'null') );
      END IF;
    END IF;

    PO_MOAC_UTILS_PVT.validate_orgid_pub_api(x_org_id => l_org_id);
    PO_MOAC_UTILS_PVT.set_policy_context('S',l_org_id);


    -- Validate the action parameter
    IF (p_action NOT IN ('CANCEL')) THEN
      FND_MESSAGE.set_name('PO','PO_CONTROL_INVALID_ACTION');
      FND_MESSAGE.set_token('ACTION',p_action);

      IF (g_fnd_debug = 'Y') THEN
        IF(FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
          FND_LOG.message(FND_LOG.level_error, g_module_prefix || l_api_name ||
                         '.invalid_action', FALSE);
        END IF;
      END IF;

      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF;


    l_entity_dtl_rec_tbl := po_document_action_pvt.entity_dtl_rec_type_tbl();
    l_old_auth_status_tbl:= PO_TBL_VARCHAR30();

    FOR i IN po_doc_tbl.FIRST..po_doc_tbl.LAST LOOP

      -- Validates the document details and returns the document Id corresponding to the input values
      -- Input to the routine can be document id or document numbers
      -- For the p_doc_id/p_doc_num, it returns l_doc_id i.e. corresponding PO_HEADER_ID
      -- For the p_release_id/p_release_num, it returns l_doc_id i.e. corresponding PO_RELEASE_ID
      -- For the p_doc_line_id/p_doc_line_num, it returns l_doc_line_id i.e. corresponding PO_LINE_ID
      -- For the p_doc_line_loc_id/p_doc_shipment_num, it returns l_doc_line_loc_id i.e. corresponding LINE_LOCATION_ID

      PO_Document_Control_GRP.val_doc_params(
        p_api_version      => 1.0,
        p_init_msg_list    => FND_API.G_FALSE,
        x_return_status    => x_return_status,
        p_doc_type         => po_doc_tbl(i).p_doc_type,
        p_doc_subtype      => po_doc_tbl(i).p_doc_subtype,
        p_doc_id           => po_doc_tbl(i).p_doc_id,
        p_doc_num          => po_doc_tbl(i).p_doc_num,
        p_doc_line_id      => po_doc_tbl(i).p_doc_line_id,
        p_doc_line_num     => po_doc_tbl(i).p_doc_line_num,
        p_release_id       => po_doc_tbl(i).p_release_id,
        p_release_num      => po_doc_tbl(i).p_release_num,
        p_doc_line_loc_id  => po_doc_tbl(i).p_doc_line_loc_id,
        p_doc_shipment_num => po_doc_tbl(i).p_doc_shipment_num,
        x_doc_id           => l_doc_id,
        x_doc_line_id      => l_doc_line_id,
        x_doc_line_loc_id  => l_doc_line_loc_id);


      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

      l_entity_dtl_rec_tbl.extend;
      l_entity_dtl_rec_tbl(i).doc_id               := l_doc_id;
      l_entity_dtl_rec_tbl(i).document_type        := po_doc_tbl(i).p_doc_type;
      l_entity_dtl_rec_tbl(i).document_subtype     := po_doc_tbl(i).p_doc_subtype;

      IF l_doc_line_loc_id IS NOT NULL THEN
        l_entity_dtl_rec_tbl(i).entity_level :=PO_Document_Cancel_PVT.c_entity_level_SHIPMENT;
        l_entity_dtl_rec_tbl(i).entity_id    := l_doc_line_loc_id;

      ELSIF l_doc_line_id IS NOT NULL THEN
        l_entity_dtl_rec_tbl(i).entity_level :=PO_Document_Cancel_PVT.c_entity_level_LINE;
        l_entity_dtl_rec_tbl(i).entity_id    := l_doc_line_id;

      ELSE
        l_entity_dtl_rec_tbl(i).entity_level :=PO_Document_Cancel_PVT.c_entity_level_HEADER;
        l_entity_dtl_rec_tbl(i).entity_id    := l_doc_id;
      END IF;


      l_entity_dtl_rec_tbl(i).entity_action_date   := p_action_date;
      l_entity_dtl_rec_tbl(i).process_entity_flag  := 'Y';
      l_entity_dtl_rec_tbl(i).recreate_demand_flag := 'N';


      BEGIN

        l_old_auth_status_tbl.extend;

        IF (po_doc_tbl(i).p_doc_type = 'RELEASE') THEN

          SELECT authorization_status
          INTO   l_old_auth_status_tbl(i)
          FROM   po_releases_all
          WHERE  po_release_id = l_doc_id;

        ELSE

          SELECT authorization_status
          INTO   l_old_auth_status_tbl(i)
          FROM   po_headers_all
          WHERE  po_header_id= l_doc_id;

        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                        'API control_document exception', 'Authorization Status not found for '||po_doc_tbl(i).p_doc_type);
          END IF;
      END;

    END LOOP;

    -- Cancel the entity
    PO_DOCUMENT_ACTION_PVT.do_cancel(
      p_entity_dtl_rec               => l_entity_dtl_rec_tbl,
      p_reason                       => p_cancel_reason,
      p_action                       => PO_DOCUMENT_ACTION_PVT.g_doc_action_CANCEL,
      p_action_date                  => p_action_date,
      p_use_gl_date                  => p_use_gldate,
      p_cancel_reqs_flag             => p_cancel_reqs_flag,
      p_note_to_vendor               => p_note_to_vendor,
      p_caller                       => PO_DOCUMENT_CANCEL_PVT.c_CANCEL_API,
      x_online_report_id             => l_online_report_id,
      p_commit                       => p_commit,
      x_return_status                => x_return_status,
      x_exception_msg                => l_exc_msg,
      x_return_code                  => l_return_code);


    -- If the procedure does not complete successfully raise the
    -- appropriate exception
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;



    IF p_print_flag ='Y' THEN
      l_communication_method_option := 'PRINT';
      l_communication_method_value :=NULL;
    END IF;

    FOR i IN 1..l_entity_dtl_rec_tbl.Count LOOP

      IF NOT (l_doc_id_tbl.EXISTS(l_entity_dtl_rec_tbl(i).doc_id))
         AND l_entity_dtl_rec_tbl(i).process_entity_flag  ='Y' THEN

        IF (p_launch_approvals_flag  = 'Y'
            AND l_old_auth_status_tbl(i) ='APPROVED') THEN

          PO_Document_Control_PVT.do_approve_on_cancel(
            p_doc_type                  => l_entity_dtl_rec_tbl(i).document_type,
            p_doc_subtype                 => l_entity_dtl_rec_tbl(i).document_subtype,
            p_doc_id                      => l_entity_dtl_rec_tbl(i).doc_id,
            p_communication_method_option => l_communication_method_option,
            p_communication_method_value  => l_communication_method_value,
            p_note_to_vendor              => p_note_to_vendor,
            p_source                      => PO_DOCUMENT_CANCEL_PVT.c_CANCEL_API,
            x_exception_msg               => l_exc_msg,
            x_return_status               => x_return_status);

          IF (x_return_status = FND_API.g_ret_sts_error) THEN
            RAISE FND_API.g_exc_error;
          ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
            RAISE FND_API.g_exc_unexpected_error;
          END IF;

        END IF;

        -- If the Cancel action is successful
        -- Communicate the same to the supplier
        PO_Document_Control_PVT.doc_communicate_oncancel(
          p_doc_type                  => l_entity_dtl_rec_tbl(i).document_type,
          p_doc_subtype                 => l_entity_dtl_rec_tbl(i).document_subtype,
          p_doc_id                      => l_entity_dtl_rec_tbl(i).doc_id,
          p_communication_method_option => l_communication_method_option,
          p_communication_method_value  => l_communication_method_value,
          x_return_status               => x_return_status );

        -- If the procedure does not complete successfully raise the
        -- appropriate exception
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.g_exc_error;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

        l_doc_id_tbl.extend;
        id_count:=id_count+1;
        l_doc_id_tbl(id_count):=l_entity_dtl_rec_tbl(i).doc_id;

      END IF;

    END LOOP;

    --Add all the messages to the message list
    IF l_return_code ='F' AND l_online_report_id IS NOT NULL THEN
      PO_Document_Control_PVT.add_online_report_msgs(
        p_api_version      => 1.0,
        p_init_msg_list    => FND_API.G_FALSE,
        x_return_status    => x_return_status,
        p_online_report_id => l_online_report_id);

      RAISE FND_API.g_exc_error;
    END IF;



    -- Standard API check of p_commit
    IF FND_API.to_boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN FND_API.g_exc_error THEN
        ROLLBACK TO control_document_PUB;
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        ROLLBACK TO control_document_PUB;
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        ROLLBACK TO control_document_PUB;
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            IF (g_fnd_debug = 'Y') THEN
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                 FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                               l_api_name || '.others_exception', 'Exception');
               END IF;
            END IF;
        END IF;
  END control_document;


END PO_Document_Control_PUB;

/
