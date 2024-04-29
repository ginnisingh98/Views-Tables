--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_CONTROL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_CONTROL_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVDCOS.pls 120.7.12010000.9 2014/05/01 12:44:05 pneralla ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_DOCUMENT_CONTROL_PVT';

-- Global constants to identify the level of the control action
g_header_level       CONSTANT NUMBER := 0;
g_line_level         CONSTANT NUMBER := 1;
g_shipment_level     CONSTANT NUMBER := 2;
g_rel_header_level   CONSTANT NUMBER := 3;
g_rel_shipment_level CONSTANT NUMBER := 4;

--< Bug 3194665 Start >
TYPE g_lookup_code_tbl_type IS TABLE OF PO_LOOKUP_CODES.lookup_code%TYPE
    INDEX BY BINARY_INTEGER;
TYPE g_displayed_field_tbl_type IS TABLE OF PO_LOOKUP_CODES.displayed_field%TYPE
    INDEX BY BINARY_INTEGER;
--< Bug 3194665 End >

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
    p_use_gldate            IN   VARCHAR2 DEFAULT NULL,   -- <ENCUMBRANCE FPJ>
    p_launch_approvals_flag IN   VARCHAR2 := 'Y', -- <CancelPO FPJ>
    p_communication_method_option  IN   VARCHAR2 DEFAULT NULL, --<HTML Agreements R12>
    p_communication_method_value   IN   VARCHAR2 DEFAULT NULL, --<HTML Agreements R12>
    p_online_report_id OUT NOCOPY NUMBER, -- Bug 8831247
    p_caller                IN   VARCHAR2 DEFAULT NULL  --Bug6603493
    );

PROCEDURE init_action_date
   (p_api_version    IN     NUMBER,
    p_init_msg_list  IN     VARCHAR2,
    x_return_status  OUT    NOCOPY VARCHAR2,
    p_doc_type       IN     PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype    IN     PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id         IN     NUMBER,
    x_action_date    IN OUT NOCOPY DATE,
    x_cbc_enabled    OUT    NOCOPY VARCHAR2);


PROCEDURE get_action_date
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype    IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id         IN   NUMBER,
    p_cbc_enabled    IN   VARCHAR2,
    x_action_date    OUT  NOCOPY DATE);


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
    p_skip_valid_cbc_acct_date IN VARCHAR2 DEFAULT NULL); --Bug#4569120


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
    x_control_level    OUT  NOCOPY NUMBER);


PROCEDURE po_stop_wf_process
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype    IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id         IN   NUMBER);


PROCEDURE rel_stop_wf_process
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype    IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id         IN   NUMBER);


PROCEDURE create_print_request
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_num        IN   VARCHAR2,
    p_rel_doc_num    IN   VARCHAR2,
    x_request_id     OUT  NOCOPY NUMBER);


PROCEDURE update_note_to_vendor
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    p_commit         IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_id         IN   NUMBER,
    p_doc_line_id    IN   NUMBER,
    p_note_to_vendor IN   PO_HEADERS.note_to_vendor%TYPE);


FUNCTION pass_security_check
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_subtype    IN   PO_DOCUMENT_TYPES.document_subtype%TYPE,
    p_doc_id         IN   NUMBER,
    p_agent_id       IN   PO_HEADERS.agent_id%TYPE)
RETURN BOOLEAN;


FUNCTION has_shipments
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_id         IN   NUMBER)
RETURN BOOLEAN;

-- Bug#17805976: add p_entity_id and p_entity_level
FUNCTION has_unencumbered_shipments
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_id         IN   NUMBER,
    p_entity_id      IN   NUMBER,
    p_entity_level   IN   VARCHAR2)
RETURN BOOLEAN;


FUNCTION in_open_gl_period
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_date           IN   DATE)
RETURN BOOLEAN;


PROCEDURE add_online_report_msgs
   (p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2,
    x_return_status    OUT  NOCOPY VARCHAR2,
    p_online_report_id IN   NUMBER);

--< Bug 3194665 Start >
PROCEDURE get_header_actions
    ( p_doc_subtype         IN   VARCHAR2
    , p_doc_id              IN   NUMBER
    , p_agent_id            IN   NUMBER
    , x_lookup_code_tbl     OUT  NOCOPY g_lookup_code_tbl_type
    , x_displayed_field_tbl OUT  NOCOPY g_displayed_field_tbl_type
    , x_return_status       OUT  NOCOPY VARCHAR2
    , p_mode                 IN  VARCHAR2 DEFAULT NULL);--<HTML Agreements R12>

PROCEDURE get_line_actions
    ( p_doc_subtype         IN   VARCHAR2
    , p_doc_line_id         IN   NUMBER
    , p_agent_id            IN   NUMBER
    , x_lookup_code_tbl     OUT  NOCOPY g_lookup_code_tbl_type
    , x_displayed_field_tbl OUT  NOCOPY g_displayed_field_tbl_type
    , x_return_status       OUT  NOCOPY VARCHAR2
    , p_mode                 IN  VARCHAR2 DEFAULT NULL);--<HTML Agreements R12>

PROCEDURE get_shipment_actions
    ( p_doc_type            IN   VARCHAR2
    , p_doc_subtype         IN   VARCHAR2
    , p_doc_line_loc_id     IN   NUMBER
    , p_agent_id            IN   NUMBER
    , x_lookup_code_tbl     OUT  NOCOPY g_lookup_code_tbl_type
    , x_displayed_field_tbl OUT  NOCOPY g_displayed_field_tbl_type
    , x_return_status       OUT  NOCOPY VARCHAR2
    , p_mode                 IN  VARCHAR2 DEFAULT NULL);--<HTML Agreements R12>

PROCEDURE get_rel_header_actions
    ( p_doc_subtype         IN   VARCHAR2
    , p_doc_id              IN   NUMBER
    , p_agent_id            IN   NUMBER
    , x_lookup_code_tbl     OUT  NOCOPY g_lookup_code_tbl_type
    , x_displayed_field_tbl OUT  NOCOPY g_displayed_field_tbl_type
    , x_return_status       OUT  NOCOPY VARCHAR2
    );

PROCEDURE get_rel_shipment_actions
    ( p_doc_subtype         IN   VARCHAR2
    , p_doc_line_loc_id     IN   NUMBER
    , p_agent_id            IN   NUMBER
    , x_lookup_code_tbl     OUT  NOCOPY g_lookup_code_tbl_type
    , x_displayed_field_tbl OUT  NOCOPY g_displayed_field_tbl_type
    , x_return_status       OUT  NOCOPY VARCHAR2
    );
--< Bug 3194665 End >
 --<HTML Agreements R12 Start>
procedure get_valid_control_actions( p_mode                IN   VARCHAR2
                                    ,p_doc_level           IN   VARCHAR2
                                    ,p_doc_type            IN   VARCHAR2
                                    ,p_doc_header_id       IN   NUMBER
                                    ,p_doc_level_id        IN   NUMBER
                                    ,x_return_status       OUT  NOCOPY VARCHAR2
                                    ,x_valid_ctrl_ctn_tbl  OUT  NOCOPY PO_TBL_VARCHAR30);

-- Bug 5000165 Added the x_is_encumbrance_error parameter.
procedure process_doc_control_action( p_control_action         IN  VARCHAR2
                                     ,p_mode                   IN  VARCHAR2
                                     ,p_doc_level              IN  VARCHAR2
                                     ,p_doc_header_id          IN  NUMBER
                                     ,p_doc_org_id             IN  NUMBER
                                     ,p_doc_line_id            IN  NUMBER
                                     ,p_doc_line_loc_id        IN  NUMBER
                                     ,p_doc_type               IN  VARCHAR2
                                     ,p_doc_subtype            IN  VARCHAR2
                                     ,p_gl_date                IN  DATE
                                     ,p_po_encumbrance_flag    IN  VARCHAR2
                                     ,p_req_encumbrance_flag   IN  VARCHAR2
                                     ,p_use_gldate             IN  VARCHAR2
                                     ,p_reason                 IN  VARCHAR2
                                     ,p_note_to_vendor         IN  VARCHAR2
                                     ,p_communication_method   IN  VARCHAR2
                                     ,p_communication_value    IN  VARCHAR2
                                     ,p_cancel_reqs            IN  VARCHAR2
                                     ,x_return_status          OUT NOCOPY VARCHAR2
                                     ,x_approval_initiated     OUT NOCOPY VARCHAR2
                                     ,x_cancel_req_flag_reset  OUT NOCOPY VARCHAR2
                                     ,x_error_msg_tbl          OUT NOCOPY PO_TBL_VARCHAR2000
                                     ,x_is_encumbrance_error   OUT NOCOPY VARCHAR2
                                     ,x_online_report_id       OUT NOCOPY NUMBER --bug#5055417
                                     );

procedure get_cancel_req_chkbox_attr( p_doc_level_id                 IN NUMBER
                                     ,p_doc_header_id                IN NUMBER
                                     ,p_doc_level                    IN VARCHAR2
                                     ,p_doc_subtype                  IN VARCHAR2
                                     ,p_cancel_req_on_cancel_po      IN VARCHAR2
                                     ,x_drop_ship_flag               OUT NOCOPY VARCHAR2
                                     ,x_labor_expense_req_flag       OUT NOCOPY VARCHAR2
                                     ,x_svc_line_with_req_flag       OUT NOCOPY VARCHAR2
                                     ,x_fps_line_ship_with_req_flag  OUT NOCOPY VARCHAR2
                                     ,x_return_status                OUT NOCOPY VARCHAR2
				     ,x_is_partially_received_billed OUT NOCOPY VARCHAR2 --Bug 16276254
				     ,p_doc_type  		     IN VARCHAR2 --Bug 16276254
				     );
 --<HTML Agreements R12 End>

--------------------------------------------------------------------------------
--<Bug 14271696> :Cancel Refactoring Project <Communicate>
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
  );

--------------------------------------------------------------------------------
--<Bug 14387025 :Cancel Refactoring Project
--Start of Comments
--Name: do_approve_on_cancel
--Function:
--  called after the successful cancel action
--  Aprrove the document if the document's current status is Requires Reapproval
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
  );

  /*Added for Bug:18202450 to get cancel backing requistion field attributes*/

PROCEDURE cancelbackingReq(p_doc_header_id IN NUMBER,
  p_doc_line_id IN NUMBER DEFAULT NULL,
  p_doc_lineloc_id IN NUMBER DEFAULT NULL ,
  isCancelChkBoxReadonly OUT NOCOPY BOOLEAN ,
  cancelReqVal OUT  NOCOPY VARCHAR2 ,
  x_return_status  OUT NOCOPY VARCHAR2
) ;

END PO_Document_Control_PVT;

/
