--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_CONTROL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_CONTROL_GRP" AS
/* $Header: POXGDCOB.pls 120.2.12010000.8 2013/01/21 02:25:17 mazhong ship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

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
    p_source           IN   VARCHAR2,
    p_action           IN   VARCHAR2,
    p_action_date      IN   DATE,
    p_cancel_reason    IN   PO_LINES.cancel_reason%TYPE,
    p_cancel_reqs_flag IN   VARCHAR2,
    p_print_flag       IN   VARCHAR2,
    p_note_to_vendor   IN   PO_HEADERS.note_to_vendor%TYPE,
    p_use_gldate       IN   VARCHAR2, -- <ENCUMBRANCE FPJ>
    p_launch_approvals_flag IN   VARCHAR2, -- Bug#8224603
    p_caller           IN VARCHAR2 --Bug6603493
   )
IS

l_api_name CONSTANT VARCHAR2(30) := 'control_document';
l_api_version CONSTANT NUMBER := 1.0;
l_doc_id NUMBER;
l_doc_line_id NUMBER;
l_doc_line_loc_id NUMBER;

-- Bug 8831247
x_online_report_id number;

--16035142 start
 	x_default_method VARCHAR2(30);
	x_preparer_id		 NUMBER(12);
	x_print_flag            varchar2(1)   := 'N';
	x_fax_flag              varchar2(1)   := 'N';
	x_email_flag            varchar2(1)   := 'N';
	x_eMail_address         po_vendor_sites_all.email_address%TYPE  :=  null;
	x_fax_number            varchar2(100) := null;
	x_po_api_return_status  varchar2 (3) := null;
	x_msg_count             number := NULL;
	x_msg_data              varchar2(2000):= NULL;
	x_document_num          po_headers.segment1%type := null;
	x_communication_method_value varchar2(100) := null;
--16035142 end

BEGIN
    -- Start standard API initialization
    SAVEPOINT control_document_GRP;
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
                      '.invoked, Original', 'Source: ' || NVL(p_source,'null') ||
                      ', Action: ' || NVL(p_action,'null') ||
                      ', Type: ' || NVL(p_doc_type,'null') ||
                      ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
       END IF;
    END IF;

    -- Validate the action parameter
    IF (p_action NOT IN ('CANCEL')) THEN
        FND_MESSAGE.set_name('PO','PO_CONTROL_INVALID_ACTION');
        FND_MESSAGE.set_token('ACTION',p_action);
        IF (g_fnd_debug = 'Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
             FND_LOG.message(FND_LOG.level_error, g_module_prefix || l_api_name ||
                           '.invalid_action', FALSE);
           END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;

    val_doc_params(p_api_version      => 1.0,
                   p_init_msg_list    => FND_API.G_FALSE,
                   x_return_status    => x_return_status,
                   p_doc_type         => p_doc_type,
                   p_doc_subtype      => p_doc_subtype,
                   p_doc_id           => p_doc_id,
                   p_doc_num          => p_doc_num,
                   p_doc_line_id      => p_doc_line_id,
                   p_doc_line_num     => p_doc_line_num,
                   p_release_id       => p_release_id,
                   p_release_num      => p_release_num,
                   p_doc_line_loc_id  => p_doc_line_loc_id,
                   p_doc_shipment_num => p_doc_shipment_num,
                   x_doc_id           => l_doc_id,
                   x_doc_line_id      => l_doc_line_id,
                   x_doc_line_loc_id  => l_doc_line_loc_id);
    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    --16035142 start
         /* Get supplier's default transmission settings */

    IF p_launch_approvals_flag = 'Y' THEN
      PO_VENDOR_SITES_GRP.Get_Transmission_Defaults(
                     p_api_version      => 1.0,
                     p_init_msg_list    => FND_API.G_FALSE,
                     p_document_id      => l_doc_id,
                     p_document_type    => p_doc_type,
                     p_document_subtype => p_doc_subtype,
                     p_preparer_id      => x_preparer_id,
                     x_default_method   => x_default_method,
                     x_email_address    => x_email_address,
                     x_fax_number       => x_fax_number,
                     x_document_num     => x_document_num,
                     x_print_flag       => x_print_flag,
                     x_fax_flag         => x_fax_flag,
                     x_email_flag       => x_email_flag,
                     x_return_status    => x_po_api_return_status,
                     x_msg_count        => x_msg_count,
                     x_msg_data         => x_msg_data);

      if x_email_flag = 'Y' then
        x_communication_method_value := x_email_address;
      elsif x_fax_flag = 'Y' then
        x_communication_method_value := x_fax_number;
      else
        x_communication_method_value := null;
      end if;

      IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                      'PO_VENDOR_SITES_GRP.Get_Transmission_Defaults.invoked, Original', 'x_email_flag: ' || NVL(x_email_flag,'null') ||
                      ', x_fax_flag: ' || NVL(x_fax_flag,'null') ||
                      ', x_communication_method_value: ' || NVL(x_communication_method_value,'null') ||
                      ', x_default_method: ' || NVL(TO_CHAR(x_default_method),'null'));
       END IF;
      END IF;
     END IF;

    --16035142 end

    /* Bug 8831247 , As part of this bug we introduced a new out parameter
      p_online_report_id, Modifying below call accordingly */

    PO_Document_Control_PVT.control_document
           (p_api_version      => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_commit           => FND_API.G_FALSE,
            x_return_status    => x_return_status,
            p_doc_type         => p_doc_type,
            p_doc_subtype      => p_doc_subtype,
            p_doc_id           => l_doc_id,
            p_doc_line_id      => l_doc_line_id,
            p_doc_line_loc_id  => l_doc_line_loc_id,
            p_source           => p_source,
            p_action           => p_action,
            p_action_date      => p_action_date,
            p_cancel_reason    => p_cancel_reason,
            p_cancel_reqs_flag => p_cancel_reqs_flag,
            p_print_flag       => x_print_flag,	   	--16035142
            p_note_to_vendor   => p_note_to_vendor,
            p_use_gldate       => p_use_gldate,  -- <ENCUMBRANCE FPJ>
            p_launch_approvals_flag => p_launch_approvals_flag, --Bug8224603
            p_communication_method_option => x_default_method,			--16035142
            p_communication_method_value  => x_communication_method_value,	--16035142
	    p_online_report_id => x_online_report_id,
	    p_caller           =>   p_caller    --Bug6603493
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
        ROLLBACK TO control_document_GRP;
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        ROLLBACK TO control_document_GRP;
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        ROLLBACK TO control_document_GRP;
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

/*Bug66603493: overloaded procedure control_document*/

PROCEDURE control_document(
     p_api_version      IN   NUMBER,
     p_init_msg_list    IN   VARCHAR2,
     p_commit           IN   VARCHAR2,
     x_return_status    OUT  NOCOPY VARCHAR2,
     p_doc_type         IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
     p_doc_subtype      IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
     p_doc_id           IN   NUMBER,
     p_doc_num          IN   PO_HEADERS.segment1%TYPE,
     p_release_id       IN   NUMBER,
     p_release_num      IN   NUMBER,
     p_doc_line_id      IN   RecTabpo_line_ids,
     p_doc_line_num     IN   NUMBER,
     p_doc_line_loc_id  IN   NUMBER,
     p_doc_shipment_num IN   NUMBER,
     p_source           IN   VARCHAR2,
     p_action           IN   VARCHAR2,
     p_action_date      IN   DATE,
     p_cancel_reason    IN   PO_LINES.cancel_reason%TYPE,
     p_cancel_reqs_flag IN   VARCHAR2,
     p_print_flag       IN   VARCHAR2,
     p_note_to_vendor   IN   PO_HEADERS.note_to_vendor%TYPE,
     p_use_gldate       IN   VARCHAR2,
     p_launch_approvals_flag   IN VARCHAR2,
     p_caller             IN VARCHAR2)
       -- <ENCUMBRANCE FPJ>)
 IS

    l_entity_dtl_rec_tbl  po_document_action_pvt.entity_dtl_rec_type_tbl;
    l_online_report_id    NUMBER;
    l_exc_msg             VARCHAR2(2000);
    l_return_code         VARCHAR2(25);
    l_communication_method_option VARCHAR2(30);
    l_communication_method_value  VARCHAR2(30);
    l_old_auth_status  VARCHAR2(30);
    l_api_name CONSTANT VARCHAR2(30) := 'control_document';
    l_api_version CONSTANT NUMBER := 1.0;
    l_doc_id NUMBER;
    l_doc_line_id NUMBER;
    l_doc_line_loc_id NUMBER;

--16035142 start
 	x_default_method VARCHAR2(30);
	x_preparer_id		 NUMBER(12);
	x_print_flag            varchar2(1)   := 'N';
	x_fax_flag              varchar2(1)   := 'N';
	x_email_flag            varchar2(1)   := 'N';
	x_eMail_address         po_vendor_sites_all.email_address%TYPE  :=  null;
	x_fax_number            varchar2(100) := null;
	x_po_api_return_status  varchar2 (3) := null;
	x_msg_count             number := NULL;
	x_msg_data              varchar2(2000):= NULL;
	x_document_num          po_headers.segment1%type := null;
--16035142 end


BEGIN

    -- Start standard API initialization
    SAVEPOINT control_document_GRP;
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
                      '.invoked, Overloaded', 'Source: ' || NVL(p_source,'null') ||
                      ', Action: ' || NVL(p_action,'null') ||
                      ', Type: ' || NVL(p_doc_type,'null') ||
                      ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
      END IF;
    END IF;



    -- Validate the action parameter
    IF (p_action NOT IN ('CANCEL')) THEN
      FND_MESSAGE.set_name('PO','PO_CONTROL_INVALID_ACTION');
      FND_MESSAGE.set_token('ACTION',p_action);
      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
          FND_LOG.message(FND_LOG.level_error, g_module_prefix || l_api_name ||
                           '.invalid_action', FALSE);
        END IF;
      END IF;
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF;

    l_entity_dtl_rec_tbl :=  po_document_action_pvt.entity_dtl_rec_type_tbl();

    FOR i IN p_doc_line_id.FIRST..p_doc_line_id.LAST LOOP

      --  Validates the input parameters to be valid and match the
      --  document specified
      --  Input to the routine can be document id or document numbers
      --  For the p_doc_id/p_doc_num, it returns l_doc_id i.e. corresponding PO_HEADER_ID
      --  For the p_release_id/p_release_num, it returns l_doc_id i.e. corresponding PO_RELEASE_ID
      --  For the p_doc_line_id/p_doc_line_num, it returns l_doc_line_id i.e. corresponding PO_LINE_ID
      --  For the p_doc_line_loc_id/p_doc_shipment_num, it returns l_doc_line_loc_id i.e. corresponding LINE_LOCATION_ID

      val_doc_params(
        p_api_version      => 1.0,
        p_init_msg_list    => FND_API.G_FALSE,
        x_return_status    => x_return_status,
        p_doc_type         => p_doc_type,
        p_doc_subtype      => p_doc_subtype,
        p_doc_id           => p_doc_id,
        p_doc_num          => p_doc_num,
        p_doc_line_id      => p_doc_line_id(i).po_line_id,
        p_doc_line_num     => p_doc_line_num,
        p_release_id       => p_release_id,
        p_release_num      => p_release_num,
        p_doc_line_loc_id  => p_doc_line_id(i).po_line_location_id,
        p_doc_shipment_num => p_doc_shipment_num,
        x_doc_id           => l_doc_id,
        x_doc_line_id      => l_doc_line_id,
        x_doc_line_loc_id  => l_doc_line_loc_id);


      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- Constructing the table of records
      l_entity_dtl_rec_tbl.extend;
      l_entity_dtl_rec_tbl(i).doc_id               := l_doc_id;
      l_entity_dtl_rec_tbl(i).document_type        := p_doc_type;
      l_entity_dtl_rec_tbl(i).document_subtype     := p_doc_subtype;

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


    END LOOP;

    BEGIN

      IF (p_doc_type = 'RELEASE') THEN

        SELECT authorization_status
        INTO   l_old_auth_status
        FROM po_releases_all
        WHERE  po_release_id = l_doc_id;

      ELSE

        SELECT authorization_status
        INTO   l_old_auth_status
        FROM po_headers_all
        WHERE  po_header_id= l_doc_id;

      END IF;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_old_auth_status:=null;
          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                                'API control_document exception', 'Authorization Status not found for '||p_doc_type);
          END IF;
    END;

    -- Call do_cancel for cancelling all the entities

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



    --Add all the messages to the message list
    IF l_return_code ='F' AND l_online_report_id IS NOT NULL THEN
      PO_Document_Control_PVT.add_online_report_msgs(
        p_api_version      => 1.0,
        p_init_msg_list    => FND_API.G_FALSE,
        x_return_status    => x_return_status,
        p_online_report_id => l_online_report_id);

      RAISE FND_API.g_exc_error;
    END IF;

    IF p_print_flag ='Y' THEN
      l_communication_method_option := 'PRINT';
      l_communication_method_value :=NULL;
    END IF;

--16035142 start
        /* Get supplier's default transmission settings */
	PO_VENDOR_SITES_GRP.Get_Transmission_Defaults(
	                     p_api_version      => 1.0,
	                     p_init_msg_list    => FND_API.G_FALSE,
	                     p_document_id      => l_doc_id,
	                     p_document_type    => p_doc_type,
	                     p_document_subtype => p_doc_subtype,
	                     p_preparer_id      => x_preparer_id,
	                     x_default_method   => x_default_method,
	                     x_email_address    => x_email_address,
	                     x_fax_number       => x_fax_number,
	                     x_document_num     => x_document_num,
	                     x_print_flag       => x_print_flag,
	                     x_fax_flag         => x_fax_flag,
	                     x_email_flag       => x_email_flag,
	                     x_return_status    => x_po_api_return_status,
	                     x_msg_count        => x_msg_count,
	                     x_msg_data         => x_msg_data);

	    if x_email_flag = 'Y' then
	      l_communication_method_value := x_email_address;
	    elsif x_fax_flag = 'Y' then
	      l_communication_method_value := x_fax_number;
	    else
	      l_communication_method_value := null;
	    end if;

    IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                      'PO_VENDOR_SITES_GRP.Get_Transmission_Defaults.invoked, Original', 'x_email_flag: ' || NVL(x_email_flag,'null') ||
                      ', x_fax_flag: ' || NVL(x_fax_flag,'null') ||
                      ', l_communication_method_value: ' || NVL(l_communication_method_value,'null') ||
                      ', x_default_method: ' || NVL(TO_CHAR(x_default_method),'null'));
       END IF;
    END IF;

    --16035142 end


    -- Approve the document if p_launch_approvals_flag='Y'
    IF (p_launch_approvals_flag  = 'Y'
       AND l_old_auth_status ='APPROVED') THEN

      PO_Document_Control_PVT.do_approve_on_cancel(
        p_doc_type         => p_doc_type,
        p_doc_subtype      => p_doc_subtype,
        p_doc_id           => p_doc_id,
        p_communication_method_option => x_default_method,	--16035142
        p_communication_method_value  => l_communication_method_value,
        p_note_to_vendor   => p_note_to_vendor,
        p_source                      => p_caller,
        x_exception_msg               => l_exc_msg,
        x_return_status               => x_return_status
           );

      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

    END IF;

    -- If the Cancel action is successful
    -- Communicate the same to the supplier
    PO_Document_Control_PVT.doc_communicate_oncancel(
      p_doc_type         => p_doc_type,
      p_doc_subtype      => p_doc_subtype,
      p_doc_id           => p_doc_id,
      p_communication_method_option => x_default_method,	--16035142
      p_communication_method_value  => l_communication_method_value,
      x_return_status               => x_return_status);

      -- If the procedure does not complete successfully raise the
      -- appropriate exception
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
   IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix , 'There is a problem '||'SQLCODE '|| SQLCODE
                  || 'SQLERRM '||SQLERRM);
   END IF;

  END control_document;

/*Bug6603493*/
/**
 * Private Procedure: validate_control_action
 * Requires: API message list has been initialized.
 * Modifies: API message list.
 * Effects: Validates that p_action is an allowable control action to be
 *   executed by the caller on the document entity level specified. Derives any
 *   ID if the ID is NULL, but the matching number is passed in. If both ID and
 *   number are passed in, the ID is used. Validates at shipment level if the
 *   final line_loc_id is not NULL. Else, validates at line level if the final
 *   line_id is not NULL. Else, validates at header level if the final doc_id is
 *   not NULL. Control actions supported for p_action are: 'CANCEL'.
 *   Requisitions are currently not supported. Appends to API message list on
 *   error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if validation succeeds
 *                     FND_API.G_RET_STS_ERROR if validation fails
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE validate_control_action
   (p_doc_type         IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
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
    p_agent_id         IN   PO_HEADERS.agent_id%TYPE,
    x_return_status    OUT  NOCOPY VARCHAR2)
IS

l_api_name CONSTANT VARCHAR2(30) := 'validate_control_action';
l_control_level NUMBER;
l_doc_id NUMBER;
l_doc_line_id NUMBER;
l_doc_line_loc_id NUMBER;

BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                      '.invoked', 'Action: ' || NVL(p_action,'null')  ||
                      ', Type: ' || NVL(p_doc_type,'null') ||
                      ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
       END IF;
    END IF;

    -- Validate the action parameter
    IF (p_action NOT IN ('CANCEL')) THEN
        FND_MESSAGE.set_name('PO','PO_CONTROL_INVALID_ACTION');
        FND_MESSAGE.set_token('ACTION',p_action);
        IF (g_fnd_debug = 'Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
             FND_LOG.message(FND_LOG.level_error, g_module_prefix || l_api_name ||
                           '.invalid_action', FALSE);
           END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;

    val_doc_params(p_api_version      => 1.0,
                   p_init_msg_list    => FND_API.G_FALSE,
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
                   x_doc_id           => l_doc_id,
                   x_doc_line_id      => l_doc_line_id,
                   x_doc_line_loc_id  => l_doc_line_loc_id);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- Call private level validation. If the agent ID is not NULL, then user
    -- authority and document access levels will be validated as well.
    PO_Document_Control_PVT.val_control_action
                      (p_api_version     => 1.0,
                       p_init_msg_list   => FND_API.G_FALSE,
                       x_return_status   => x_return_status,
                       p_doc_type        => p_doc_type,
                       p_doc_subtype     => p_doc_subtype,
                       p_doc_id          => l_doc_id,
                       p_doc_line_id     => l_doc_line_id,
                       p_doc_line_loc_id => l_doc_line_loc_id,
                       p_action          => p_action,
                       p_agent_id        => p_agent_id,
                       x_control_level   => l_control_level);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
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
END validate_control_action;


/**
 * Public Procedure: val_control_action
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list.
 * Effects: Validates that p_action is an allowable control action to be
 *   executed by the caller on the document entity level specified. Derives any
 *   ID if the ID is NULL, but the matching number is passed in. If both ID and
 *   number are passed in, the ID is used. Validates at shipment level if the
 *   final line_loc_id is not NULL. Else, validates at line level if the final
 *   line_id is not NULL. Else, validates at header level if the final doc_id is
 *   not NULL. Control actions supported for p_action are: 'CANCEL'.
 *   Requisitions are currently not supported. Appends to API message list on
 *   error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if validation succeeds
 *                     FND_API.G_RET_STS_ERROR if validation fails
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE val_control_action
   (p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2,
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
    p_action           IN   VARCHAR2)
IS

l_api_name CONSTANT VARCHAR2(30) := 'val_control_action';
l_api_version CONSTANT NUMBER := 1.0;

-- Apps context should be initialized, so we can get the employee id directly
l_agent_id PO_HEADERS.agent_id%TYPE := FND_GLOBAL.employee_id;

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

    -- Ensure that we are not using a NULL agent ID.
    IF (l_agent_id IS NULL) THEN
        l_agent_id := -1;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                      '.invoked', 'Action: ' || NVL(p_action,'null')  ||
                      ', Type: ' || NVL(p_doc_type,'null') ||
                      ', ID: ' || NVL(TO_CHAR(p_doc_id),'null') ||
                      ', agent ID: ' || NVL(TO_CHAR(l_agent_id),'null'));
       END IF;
    END IF;

    -- Call private procedure validation with agent ID. This ensures that the
    -- user's authority and document access level are validated.
    validate_control_action(p_doc_type         => p_doc_type,
                            p_doc_subtype      => p_doc_subtype,
                            p_doc_id           => p_doc_id,
                            p_doc_num          => p_doc_num,
                            p_release_id       => p_release_id,
                            p_release_num      => p_release_num,
                            p_doc_line_id      => p_doc_line_id,
                            p_doc_line_num     => p_doc_line_num,
                            p_doc_line_loc_id  => p_doc_line_loc_id,
                            p_doc_shipment_num => p_doc_shipment_num,
                            p_action           => p_action,
                            p_agent_id         => l_agent_id,
                            x_return_status    => x_return_status);
    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
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
END val_control_action;


/**
 * Public Procedure: check_control_action
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list.
 * Effects: Checks that p_action is an allowable control action to be executed
 *   on the document at the entity level specified, regardless of the API
 *   caller's authority or access level. Derives any ID if the ID is NULL, but
 *   the matching number is passed in. If both ID and number are passed in, the
 *   ID is used. Checks at shipment level if the final line_loc_id is not NULL.
 *   Else, checks at line level if the final line_id is not NULL. Else, checks
 *   at header level if the final doc_id is not NULL. Control actions supported
 *   for p_action are: 'CANCEL'. Requisitions are currently not  supported.
 *   Appends to API message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if check succeeds
 *                     FND_API.G_RET_STS_ERROR if check fails
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE check_control_action
   (p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2,
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
    p_action           IN   VARCHAR2)
IS

l_api_name CONSTANT VARCHAR2(30) := 'check_control_action';
l_api_version CONSTANT NUMBER := 1.0;

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

    IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                      '.invoked', 'Action: ' || NVL(p_action,'null')  ||
                      ', Type: ' || NVL(p_doc_type,'null') ||
                      ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
       END IF;
    END IF;

    -- Call private procedure validation with a NULL agent ID. This will
    -- ensure that no user authority or document access levels are checked.
    validate_control_action(p_doc_type         => p_doc_type,
                            p_doc_subtype      => p_doc_subtype,
                            p_doc_id           => p_doc_id,
                            p_doc_num          => p_doc_num,
                            p_release_id       => p_release_id,
                            p_release_num      => p_release_num,
                            p_doc_line_id      => p_doc_line_id,
                            p_doc_line_num     => p_doc_line_num,
                            p_doc_line_loc_id  => p_doc_line_loc_id,
                            p_doc_shipment_num => p_doc_shipment_num,
                            p_action           => p_action,
                            p_agent_id         => NULL,
                            x_return_status    => x_return_status);
    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
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
END check_control_action;


/**
 * Private Procedure: val_po_params
 * Requires: API message list has been initialized. Document is PO or PA.
 * Modifies: API message list
 * Effects: Derives any ID if the ID is NULL and the matching number is passed
 *   in. If both the ID and number are passed in, the ID is used for validation.
 *   The final IDs must match the document specified. Appends to API message
 *   list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if derived all IDs correctly
 *                     FND_API.G_RET_STS_ERROR if error occurred
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE val_po_params
   (p_doc_type         IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype      IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id           IN   NUMBER,
    p_doc_num          IN   PO_HEADERS.segment1%TYPE,
    p_doc_line_id      IN   NUMBER,
    p_doc_line_num     IN   NUMBER,
    p_doc_line_loc_id  IN   NUMBER,
    p_doc_shipment_num IN   NUMBER,
    x_doc_id           OUT  NOCOPY NUMBER,
    x_doc_line_id      OUT  NOCOPY NUMBER,
    x_doc_line_loc_id  OUT  NOCOPY NUMBER,
    x_return_status    OUT  NOCOPY VARCHAR2)
IS

l_api_name CONSTANT VARCHAR2(30) := 'val_po_params';
l_exists VARCHAR2(10);
l_control_level NUMBER;

BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                      '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                      ', Subtype: ' || NVL(p_doc_subtype,'null') ||
                      ', ID: ' || NVL(TO_CHAR(p_doc_id),'null') ||
                      ', Num: ' || NVL(p_doc_num,'null'));
       END IF;
    END IF;

    -- Must have a document ID or document num
    IF (p_doc_id IS NULL) AND (p_doc_num IS NULL) THEN
        FND_MESSAGE.set_name('PO','PO_INVALID_DOC_IDS');
        IF (g_fnd_debug = 'Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
             FND_LOG.message(FND_LOG.level_error, g_module_prefix || l_api_name
                           || '.invalid_doc_ids', FALSE);
           END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;  --<if p_doc_id ...>

    -- initialize outputs
    x_doc_id := p_doc_id;
    x_doc_line_id := p_doc_line_id;
    x_doc_line_loc_id := p_doc_line_loc_id;

    -- Find level of control action
    IF (p_doc_line_loc_id IS NOT NULL) OR (p_doc_shipment_num IS NOT NULL)
    THEN
        l_control_level := PO_Document_Control_PVT.g_shipment_level;
    ELSIF (p_doc_line_id IS NOT NULL) OR (p_doc_line_num IS NOT NULL) THEN
        l_control_level := PO_Document_Control_PVT.g_line_level;
    ELSE
        l_control_level := PO_Document_Control_PVT.g_header_level;
    END IF;  --<if p_doc_line_loc_id ...>

    -- Derive header
    IF (p_doc_id IS NULL) THEN
        SELECT poh.po_header_id
          INTO x_doc_id
          FROM po_headers poh
         WHERE poh.segment1 = p_doc_num AND
               poh.type_lookup_code = p_doc_subtype;
    ELSE
        SELECT poh.po_header_id
          INTO x_doc_id
          FROM po_headers poh
         WHERE poh.po_header_id = p_doc_id;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_module_prefix || l_api_name ||
               '.validated_header', 'ID: ' || NVL(TO_CHAR(x_doc_id),'null'));
       END IF;
    END IF;

    IF (l_control_level <> PO_Document_Control_PVT.g_header_level) THEN

        IF (p_doc_line_id IS NULL) THEN
            SELECT pol.po_line_id
              INTO x_doc_line_id
              FROM po_lines pol
             WHERE pol.po_header_id = x_doc_id AND
                   pol.line_num = p_doc_line_num;
        ELSE
            SELECT 'Exists'
              INTO l_exists
              FROM po_lines pol
             WHERE pol.po_line_id = x_doc_line_id AND
                   pol.po_header_id = x_doc_id;
        END IF;  --<if p_doc_line_id ...>

        IF (g_fnd_debug = 'Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_module_prefix ||
                          l_api_name || '.validated_line', 'ID: ' ||
                          NVL(TO_CHAR(x_doc_line_id),'null'));
           END IF;
        END IF;

        -- Derive shipment if at shipment level and doc is PO
        IF (l_control_level = PO_Document_Control_PVT.g_shipment_level) THEN

            IF (p_doc_type = 'PO') THEN

                IF (p_doc_line_loc_id IS NULL) THEN
                    SELECT poll.line_location_id
                      INTO x_doc_line_loc_id
                      FROM po_line_locations poll
                     WHERE poll.shipment_num = p_doc_shipment_num AND
                           poll.po_line_id = x_doc_line_id AND
                           poll.po_header_id = x_doc_id;
                ELSE
                    SELECT 'Exists'
                      INTO l_exists
                      FROM po_line_locations poll
                     WHERE poll.line_location_id = x_doc_line_loc_id AND
                           poll.po_line_id = x_doc_line_id AND
                           poll.po_header_id = x_doc_id;
                END IF;  --<if p_doc_line_loc_id ...>

                IF (g_fnd_debug = 'Y') THEN
                   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                     FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_module_prefix ||
                                  l_api_name || '.validated_shipment', 'ID: ' ||
                                  NVL(TO_CHAR(x_doc_line_loc_id),'null'));
                   END IF;
                END IF;

            ELSE
                FND_MESSAGE.set_name('PO','PO_INVALID_DOC_IDS');
                IF (g_fnd_debug = 'Y') THEN
                   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
                     FND_LOG.message(FND_LOG.level_error, g_module_prefix ||
                                   l_api_name || '.pa_has_ship_ids', FALSE);
                   END IF;
                END IF;
                FND_MSG_PUB.add;
                RAISE FND_API.g_exc_error;
            END IF;  --<if p_doc_type PO>

        END IF;  --<if l_control_level = g_shipment_level>

    END IF;  --<if l_control_level <> g_header_level>

EXCEPTION
    WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
        x_return_status := FND_API.g_ret_sts_error;
        FND_MESSAGE.set_name('PO','PO_INVALID_DOC_IDS');
        IF (g_fnd_debug = 'Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
             FND_LOG.message(FND_LOG.level_error, g_module_prefix || l_api_name ||
                           '.invalid_doc_ids', FALSE);
           END IF;
        END IF;
        FND_MSG_PUB.add;
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN OTHERS THEN
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
END val_po_params;


/**
 * Private Procedure: val_rel_params
 * Requires: API message list has been initialized. Document is a Release.
 * Modifies: API message list
 * Effects: Derives any ID if the ID is NULL and the matching number is passed
 *   in. If both the ID and number are passed in, the ID is used for validation.
 *   The final IDs must match the document specified. Appends to API message
 *   list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if derived all IDs correctly
 *                     FND_API.G_RET_STS_ERROR if error occurred
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE val_rel_params
   (p_doc_type         IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype      IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id           IN   NUMBER,
    p_doc_num          IN   PO_HEADERS.segment1%TYPE,
    p_release_id       IN   NUMBER,
    p_release_num      IN   NUMBER,
    p_doc_line_loc_id  IN   NUMBER,
    p_doc_shipment_num IN   NUMBER,
    x_doc_id           OUT  NOCOPY NUMBER,
    x_doc_line_loc_id  OUT  NOCOPY NUMBER,
    x_return_status    OUT  NOCOPY VARCHAR2)
IS

l_api_name CONSTANT VARCHAR2(30) := 'val_rel_params';
l_exists VARCHAR2(10);
l_control_level NUMBER;
l_release_po_header_id NUMBER;
l_release_po_subtype PO_DOCUMENT_TYPES.document_subtype%TYPE;

BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                      '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                      ', Subtype: ' || NVL(p_doc_subtype,'null') ||
                      ', ID: ' || NVL(TO_CHAR(p_release_id),'null') ||
                      ', Num: ' || NVL(TO_CHAR(p_release_num),'null'));
       END IF;
    END IF;

    -- Must have a document ID or document num if release_id is null
    IF (p_release_id IS NULL) AND (p_doc_id IS NULL) AND (p_doc_num IS NULL)
    THEN
        FND_MESSAGE.set_name('PO','PO_INVALID_DOC_IDS');
        IF (g_fnd_debug = 'Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
             FND_LOG.message(FND_LOG.level_error, g_module_prefix || l_api_name
                           || '.invalid_doc_ids', FALSE);
           END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;  --<if p_doc_id ...>

    -- initialize output
    x_doc_id := p_release_id;
    x_doc_line_loc_id := p_doc_line_loc_id;

    -- Find level of control action
    IF (p_doc_line_loc_id IS NOT NULL) OR (p_doc_shipment_num IS NOT NULL)
    THEN
        l_control_level := PO_Document_Control_PVT.g_rel_shipment_level;
    ELSE
        l_control_level := PO_Document_Control_PVT.g_rel_header_level;
    END IF;  --<if p_doc_line_loc_id ...>

    -- Derive release header
    IF (p_release_id IS NULL) THEN

        IF (p_doc_id IS NULL) THEN
            IF (p_doc_subtype = 'BLANKET') THEN
                l_release_po_subtype := 'BLANKET';
            ELSE
                l_release_po_subtype := 'PLANNED';
            END IF;

            -- SQL What: Query to find po_header_id and po_release_id
            -- SQL Why: Need to derive the missing unique po_release_id
            -- SQL Join: po_header_id
            SELECT poh.po_header_id, por.po_release_id
              INTO l_release_po_header_id, x_doc_id
              FROM po_headers poh,
                   po_releases por
             WHERE poh.segment1 = p_doc_num AND
                   poh.type_lookup_code = l_release_po_subtype AND
                   por.po_header_id = poh.po_header_id AND
                   por.release_num = p_release_num;
        ELSE
            -- SQL What: Query to find po_header_id and po_release_id
            -- SQL Why: Need to derive the missing unique po_release_id
            -- SQL Join: po_header_id
            SELECT poh.po_header_id, por.po_release_id
              INTO l_release_po_header_id, x_doc_id
              FROM po_headers poh,
                   po_releases por
             WHERE poh.po_header_id = p_doc_id AND
                   por.po_header_id = poh.po_header_id AND
                   por.release_num = p_release_num;
        END IF;  --<if p_doc_id is null>

    ELSE
        SELECT por.po_header_id
          INTO l_release_po_header_id
          FROM po_releases por
         WHERE por.po_release_id = x_doc_id;
    END IF;  --<if p_release_id is null>

    IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_module_prefix || l_api_name ||
                      '.validated_rel_header', 'ID: ' ||
                      NVL(TO_CHAR(x_doc_id),'null'));
       END IF;
    END IF;

    -- Derive release shipment if at shipment level
    IF (l_control_level = PO_Document_Control_PVT.g_rel_shipment_level) THEN

        IF (p_doc_line_loc_id IS NULL) THEN
            -- SQL What: Query to find the line_location_id
            -- SQL Why: Need to derive the missing unique line_location_id
            -- SQL Join: po_line_id
            SELECT poll.line_location_id
              INTO x_doc_line_loc_id
              FROM po_line_locations poll,
                   po_lines pol
             WHERE poll.po_release_id = x_doc_id AND
                   poll.po_header_id = l_release_po_header_id AND
                   poll.po_line_id = pol.po_line_id AND
                   poll.shipment_num = p_doc_shipment_num AND
                   pol.po_header_id = l_release_po_header_id;
        ELSE
            SELECT 'Exists'
              INTO l_exists
              FROM po_line_locations poll
             WHERE poll.line_location_id = x_doc_line_loc_id AND
                   poll.po_release_id = x_doc_id;
        END IF;  --<if p_doc_line_loc_id ...>

        IF (g_fnd_debug = 'Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_module_prefix ||
                          l_api_name || '.validated_rel_shipment', 'ID: ' ||
                          NVL(TO_CHAR(x_doc_line_loc_id),'null'));
           END IF;
        END IF;

    END IF;  --<if l_control_level = g_rel_shipment_level>

EXCEPTION
    WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
        x_return_status := FND_API.g_ret_sts_error;
        FND_MESSAGE.set_name('PO','PO_INVALID_DOC_IDS');
        IF (g_fnd_debug = 'Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
             FND_LOG.message(FND_LOG.level_error, g_module_prefix || l_api_name ||
                           '.invalid_doc_ids', FALSE);
           END IF;
        END IF;
        FND_MSG_PUB.add;
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN OTHERS THEN
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
END val_rel_params;


/**
 * Public Procedure: val_doc_params
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list
 * Effects: Validates that the input parameters are all valid and match the
 *   document specified. Derives any ID if the ID is NULL, but the matching
 *   number is passed in. If both the ID and number are passed in, the ID is
 *   used. Appends to API message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if validation succeeds
 *                     FND_API.G_RET_STS_ERROR if validation fails
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 *   x_doc_id - The valid document ID
 *   x_doc_line_id - The valid line ID, if at line level
 *   x_doc_line_loc_id - The valid line location ID, if at shipment level
 */
PROCEDURE val_doc_params
   (p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2,
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
    x_doc_id           OUT  NOCOPY NUMBER,
    x_doc_line_id      OUT  NOCOPY NUMBER,
    x_doc_line_loc_id  OUT  NOCOPY NUMBER)
IS

l_api_name CONSTANT VARCHAR2(30) := 'val_doc_params';
l_api_version CONSTANT NUMBER := 1.0;
l_exists VARCHAR2(10);
l_control_level NUMBER;
l_release_po_header_id NUMBER;
l_release_po_subtype PO_DOCUMENT_TYPES.document_subtype%TYPE;

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

    IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                      '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                      ', Subtype: ' || NVL(p_doc_subtype,'null') ||
                      ', ID: ' || NVL(TO_CHAR(p_doc_id),'null'));
       END IF;
    END IF;

    -- Must have correct, matching doc types and subtypes
    IF ((p_doc_type IS NULL) OR (p_doc_subtype IS NULL)) OR
       (p_doc_type NOT IN ('PO','PA','RELEASE')) OR
       ((p_doc_type = 'PO') AND (p_doc_subtype NOT IN('STANDARD','PLANNED'))) OR
       ((p_doc_type = 'PA') AND (p_doc_subtype NOT IN('BLANKET','CONTRACT'))) OR
       ((p_doc_type = 'RELEASE') AND
            (p_doc_subtype NOT IN ('BLANKET','SCHEDULED')))
    THEN
        FND_MESSAGE.set_name('PO','PO_INVALID_DOC_TYPE_SUBTYPE');
        FND_MESSAGE.set_token('TYPE',p_doc_type);
        FND_MESSAGE.set_token('SUBTYPE',p_doc_subtype);
        IF (g_fnd_debug = 'Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
             FND_LOG.message(FND_LOG.level_error, g_module_prefix || l_api_name ||
                           '.invalid_doc_type', FALSE);
           END IF;
        END IF;
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
    END IF;

    IF (p_doc_type IN ('PO','PA')) THEN

        IF (p_release_id IS NOT NULL) OR (p_release_num IS NOT NULL) THEN
            -- Should not pass in release info for POs and PAs
            FND_MESSAGE.set_name('PO','PO_INVALID_DOC_IDS');
            IF (g_fnd_debug = 'Y') THEN
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
                 FND_LOG.message(FND_LOG.level_error, g_module_prefix || l_api_name ||
                               '.po_pa_has_release_info', FALSE);
               END IF;
            END IF;
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;
        END IF;  --<if p_doc_line_id ...>

        val_po_params(p_doc_type         => p_doc_type,
                      p_doc_subtype      => p_doc_subtype,
                      p_doc_id           => p_doc_id,
                      p_doc_num          => p_doc_num,
                      p_doc_line_id      => p_doc_line_id,
                      p_doc_line_num     => p_doc_line_num,
                      p_doc_line_loc_id  => p_doc_line_loc_id,
                      p_doc_shipment_num => p_doc_shipment_num,
                      x_doc_id           => x_doc_id,
                      x_doc_line_id      => x_doc_line_id,
                      x_doc_line_loc_id  => x_doc_line_loc_id,
                      x_return_status    => x_return_status);

    ELSE  -- else is a release

        IF (p_doc_line_id IS NOT NULL) OR (p_doc_line_num IS NOT NULL) THEN
            -- Releases don't have lines
            FND_MESSAGE.set_name('PO','PO_INVALID_DOC_IDS');
            IF (g_fnd_debug = 'Y') THEN
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
                 FND_LOG.message(FND_LOG.level_error, g_module_prefix || l_api_name ||
                               '.release_has_line_ids', FALSE);
               END IF;
            END IF;
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;
        END IF;  --<if p_doc_line_id ...>

        val_rel_params(p_doc_type         => p_doc_type,
                       p_doc_subtype      => p_doc_subtype,
                       p_doc_id           => p_doc_id,
                       p_doc_num          => p_doc_num,
                       p_release_id       => p_release_id,
                       p_release_num      => p_release_num,
                       p_doc_line_loc_id  => p_doc_line_loc_id,
                       p_doc_shipment_num => p_doc_shipment_num,
                       x_doc_id           => x_doc_id,
                       x_doc_line_loc_id  => x_doc_line_loc_id,
                       x_return_status    => x_return_status);

        x_doc_line_id := NULL;

    END IF;  --<if p_doc_type PO or PA>

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
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
END val_doc_params;


END PO_Document_Control_GRP;

/
