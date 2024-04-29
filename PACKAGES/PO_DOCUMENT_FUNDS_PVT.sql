--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_FUNDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_FUNDS_PVT" AUTHID CURRENT_USER AS
-- $Header: POXVENCS.pls 120.6.12010000.2 2014/10/31 06:10:30 gjyothi ship $


-------------------------------------------------------------------------------
-- Package exceptions
-------------------------------------------------------------------------------

g_NO_VALID_PERIOD_EXC 	 EXCEPTION;

-------------------------------------------------------------------------------
-- Package constants
-------------------------------------------------------------------------------

-- encumbrance actions
g_action_RESERVE                 CONSTANT
   PO_ACTION_HISTORY.action_code%TYPE
   := PO_CONSTANTS_SV.RESERVE
   ;
g_action_UNRESERVE               CONSTANT
   PO_ACTION_HISTORY.action_code%TYPE
   := PO_CONSTANTS_SV.UNRESERVE
   ;
g_action_ADJUST                  CONSTANT
   PO_ACTION_HISTORY.action_code%TYPE
   := PO_CONSTANTS_SV.ADJUST
   ;
g_action_REQ_SPLIT               CONSTANT
   VARCHAR2(30)
   := 'REQ_SPLIT'
   ;
g_action_CANCEL                  CONSTANT
   PO_ACTION_HISTORY.action_code%TYPE
   := PO_CONSTANTS_SV.CANCEL
   ;
g_action_FINAL_CLOSE             CONSTANT
   VARCHAR2(30)
   := 'FINAL CLOSE'
   ;
g_action_UNDO_FINAL_CLOSE        CONSTANT
   VARCHAR2(30)
   := 'UNDO FINAL CLOSE'
   ;
g_action_REJECT                  CONSTANT
   PO_ACTION_HISTORY.action_code%TYPE
   := PO_CONSTANTS_SV.REJECT
   ;
g_action_RETURN                  CONSTANT
   PO_ACTION_HISTORY.action_code%TYPE
   := PO_CONSTANTS_SV.RETURN
   ;
g_action_CBC_RESERVE             CONSTANT
   PO_ACTION_HISTORY.action_code%TYPE
   := PO_CONSTANTS_SV.IGC_YEAR_END_RESERVE
   ;
g_action_CBC_UNRESERVE           CONSTANT
   PO_ACTION_HISTORY.action_code%TYPE
   := PO_CONSTANTS_SV.IGC_YEAR_END_UNRESERVE
   ;

g_action_INVOICE_CANCEL          CONSTANT
   VARCHAR2(30)
   := 'AP INVOICE CANCEL'
   ;

g_action_CR_MEMO_CANCEL          CONSTANT
   VARCHAR2(30)
   := 'AP CREDIT MEMO CANCEL'
   ;


--standard document types:
g_doc_type_REQUISITION           CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_CORE_S.g_doc_type_REQUISITION
   ;
g_doc_type_PO                    CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_CORE_S.g_doc_type_PO
   ;
g_doc_type_PA                    CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_CORE_S.g_doc_type_PA
   ;
g_doc_type_RELEASE               CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_CORE_S.g_doc_type_RELEASE
   ;
-- non-standard doc type:
g_doc_type_MIXED_PO_RELEASE      CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := 'MIXED_PO_RELEASE'
   ;
g_doc_type_ANY                   CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := 'ANY'
   ;


g_doc_subtype_STANDARD           CONSTANT
   PO_HEADERS_ALL.type_lookup_code%TYPE
   := 'STANDARD'
   ;
g_doc_subtype_PLANNED            CONSTANT
   PO_HEADERS_ALL.type_lookup_code%TYPE
   := 'PLANNED'
   ;
g_doc_subtype_BLANKET            CONSTANT
   PO_RELEASES_ALL.release_type%TYPE
   := 'BLANKET'
   ;
g_doc_subtype_SCHEDULED          CONSTANT
   PO_RELEASES_ALL.release_type%TYPE
   := 'SCHEDULED'
   ;
g_doc_subtype_MIXED_PO_RELEASE   CONSTANT
   PO_HEADERS_ALL.type_lookup_code%TYPE
   := 'MIXED_PO_RELEASE'
   ;


g_doc_level_HEADER               CONSTANT
   VARCHAR2(25)
   := PO_CORE_S.g_doc_level_HEADER
   ;
g_doc_level_LINE                 CONSTANT
   VARCHAR2(25)
   := PO_CORE_S.g_doc_level_LINE
   ;
g_doc_level_SHIPMENT             CONSTANT
   VARCHAR2(25)
   := PO_CORE_S.g_doc_level_SHIPMENT
   ;
g_doc_level_DISTRIBUTION         CONSTANT
   VARCHAR2(25)
   := PO_CORE_S.g_doc_level_DISTRIBUTION
   ;


g_dist_type_STANDARD             CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_CORE_S.g_dist_type_STANDARD
   ;
g_dist_type_PLANNED              CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_CORE_S.g_dist_type_PLANNED
   ;
g_dist_type_SCHEDULED            CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_CORE_S.g_dist_type_SCHEDULED
   ;
g_dist_type_BLANKET              CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_CORE_S.g_dist_type_BLANKET
   ;
g_dist_type_AGREEMENT            CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_CORE_S.g_dist_type_AGREEMENT
   ;
--<Complex Work R12>: added prepayment type
g_dist_type_PREPAYMENT           CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_CORE_S.g_dist_type_PREPAYMENT
   ;
-- non-standard distribution types:
g_dist_type_REQUISITION          CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := 'REQUISITION'
   ;
g_dist_type_MIXED_PO_RELEASE     CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := 'MIXED_PO_RELEASE'
   ;


g_adjustment_status_OLD          CONSTANT
   PO_ENCUMBRANCE_GT.adjustment_status%TYPE
   := 'OLD'
   ;
g_adjustment_status_NEW          CONSTANT
   PO_ENCUMBRANCE_GT.adjustment_status%TYPE
   := 'NEW'
   ;

g_parameter_YES                  CONSTANT
   VARCHAR2(1)
   := 'Y'
   ;
g_parameter_NO                   CONSTANT
   VARCHAR2(1)
   := 'N'
   ;
g_parameter_USE_PROFILE          CONSTANT
   VARCHAR2(1)
   := 'U'
   ;

g_return_SUCCESS                 CONSTANT
   VARCHAR2(10)
   := 'SUCCESS'
   ;
g_return_WARNING                 CONSTANT
   VARCHAR2(10)
   := 'WARNING'
   ;
g_return_PARTIAL                 CONSTANT
   VARCHAR2(10)
   := 'PARTIAL'
   ;
g_return_FAILURE                 CONSTANT
   VARCHAR2(10)
   := 'FAILURE'
   ;
g_return_FATAL                   CONSTANT
   VARCHAR2(10)
   := 'FATAL'
   ;

-- Result classifications (for online report)
g_result_SUCCESS  		CONSTANT
	PO_ENCUMBRANCE_GT.result_type%TYPE := 'S';

g_result_WARNING  		CONSTANT
	PO_ENCUMBRANCE_GT.result_type%TYPE := 'W';

g_result_ERROR  		CONSTANT
	PO_ENCUMBRANCE_GT.result_type%TYPE := 'E';

--<SLA R12 Start>
g_event_type_code               VARCHAR2(30);
g_entity_type_code              VARCHAR2(30);
--<SLA R12 End>

-- Global package variables

g_req_encumbrance_on             BOOLEAN;
g_po_encumbrance_on              BOOLEAN;
g_pa_encumbrance_on              BOOLEAN;

g_MAIN        CONSTANT     VARCHAR2(10) := 'MAIN';
g_BACKING     CONSTANT     VARCHAR2(10) := 'BACKING';

--<bug#5010001 START>
g_ONLINE_REPORT_ID PO_ONLINE_REPORT_TEXT.online_report_id%type;
--<bug#5010001 END>

PROCEDURE check_reserve(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_override_funds                 IN             VARCHAR2
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
);

PROCEDURE check_adjust(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_override_funds                 IN             VARCHAR2
,  p_use_gl_date                    IN             VARCHAR2
,  p_override_date                  IN             DATE
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
);


PROCEDURE do_reserve(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_prevent_partial_flag           IN             VARCHAR2
,  p_validate_document              IN             VARCHAR2
,  p_override_funds                 IN             VARCHAR2
,  p_employee_id                    IN             NUMBER
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
);


PROCEDURE do_unreserve(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_validate_document              IN             VARCHAR2
,  p_override_funds                 IN             VARCHAR2
,  p_use_gl_date                    IN             VARCHAR2
,  p_override_date                  IN             DATE
,  p_employee_id                    IN             NUMBER
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
);


PROCEDURE do_return(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_use_gl_date                    IN             VARCHAR2
,  p_override_date                  IN             DATE
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
);


PROCEDURE do_reject(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_override_funds                 IN             VARCHAR2
,  p_use_gl_date                    IN             VARCHAR2
,  p_override_date                  IN             DATE
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
);


PROCEDURE do_cancel(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_override_funds                 IN             VARCHAR2
,  p_use_gl_date                    IN             VARCHAR2
,  p_override_date                  IN             DATE
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
);


PROCEDURE do_adjust(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_override_funds                 IN             VARCHAR2
,  p_use_gl_date                    IN             VARCHAR2
,  p_validate_document              IN             VARCHAR2
,  p_override_date                  IN             DATE
,  p_employee_id                    IN             NUMBER
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
);

PROCEDURE do_req_split(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_before_dist_ids_tbl            IN             po_tbl_number
,  p_after_dist_ids_tbl             IN             po_tbl_number
,  p_employee_id                    IN             NUMBER
,  p_override_funds                 IN             VARCHAR2
,  p_override_date                  IN             DATE
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
);

PROCEDURE do_final_close(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_use_gl_date                    IN             VARCHAR2
,  p_override_date                  IN             DATE
,  p_invoice_id                     IN             NUMBER   DEFAULT NULL
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
);

PROCEDURE undo_final_close(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_override_funds                 IN             VARCHAR2
,  p_use_gl_date                    IN             VARCHAR2
,  p_override_date                  IN             DATE
,  p_invoice_id                     IN             NUMBER
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
);


PROCEDURE do_cbc_yearend_reserve(
   x_return_status      OUT NOCOPY  VARCHAR2
,  p_doc_type           IN    VARCHAR2
,  p_doc_subtype        IN    VARCHAR2
,  p_doc_level          IN    VARCHAR2
,  p_doc_level_id       IN    NUMBER
,  p_override_funds     IN    VARCHAR2
,  p_employee_id        IN    NUMBER
,  x_po_return_code     OUT NOCOPY  VARCHAR2
,  x_online_report_id   OUT NOCOPY  NUMBER
);


PROCEDURE do_cbc_yearend_unreserve(
   x_return_status      OUT NOCOPY  VARCHAR2
,  p_doc_type           IN    VARCHAR2
,  p_doc_subtype        IN    VARCHAR2
,  p_doc_level          IN    VARCHAR2
,  p_doc_level_id       IN    NUMBER
,  p_override_funds     IN    VARCHAR2
,  p_use_gl_date        IN    VARCHAR2
,  p_override_date      IN    DATE
,  p_employee_id        IN    NUMBER
,  x_po_return_code     OUT NOCOPY  VARCHAR2
,  x_online_report_id   OUT NOCOPY  NUMBER
);


PROCEDURE reinstate_po_encumbrance(
   x_return_status     OUT NOCOPY VARCHAR2,
   p_distribution_id   IN         NUMBER,
   p_invoice_id        IN         NUMBER,
   p_encumbrance_amt   IN         NUMBER,
   p_qty_cancelled     IN         NUMBER,
   p_budget_account_id IN         NUMBER,
   p_gl_date           IN         DATE,
   p_period_name       IN         VARCHAR2,
   p_period_year       IN         VARCHAR2,
   p_period_num        IN         VARCHAR2,
   p_quarter_num       IN         VARCHAR2,
   p_tax_line_flag     IN         VARCHAR2,  -- But 3480949
   x_packet_id         OUT NOCOPY NUMBER
);


PROCEDURE is_agreement_encumbered(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_agreement_id_tbl               IN             PO_TBL_NUMBER
,  x_agreement_encumbered_tbl       OUT NOCOPY     PO_TBL_VARCHAR1
);


PROCEDURE is_agreement_encumbered(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_agreement_id                   IN             NUMBER
,  x_agreement_encumbered_flag      OUT NOCOPY     VARCHAR2
);


PROCEDURE is_reservable(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  x_reservable_flag                OUT NOCOPY     VARCHAR2
);


PROCEDURE is_unreservable(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  x_unreservable_flag              OUT NOCOPY     VARCHAR2
);


PROCEDURE populate_encumbrance_gt(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  p_adjustment_status_tbl          IN             po_tbl_varchar5
,  p_check_only_flag                IN             VARCHAR2
);


PROCEDURE populate_enc_gt_action_ids(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
);


PROCEDURE create_report_object(
   x_return_status	OUT NOCOPY	VARCHAR2
,  p_online_report_id	IN		NUMBER
,  p_report_successes	IN 		VARCHAR2
,  x_report_object	OUT NOCOPY	po_fcout_type
);

--<R12 SLA Start>
PROCEDURE POPULATE_BC_REPORT_EVENTS
(
  x_return_status            OUT NOCOPY VARCHAR2,
  p_online_report_id         IN         NUMBER,--<bug#5055417>
  x_events_populated         OUT NOCOPY VARCHAR2
);

PROCEDURE POPULATE_AND_CREATE_BC_REPORT
(
  x_return_status         OUT NOCOPY VARCHAR2,
  p_online_report_id      IN  NUMBER,--<bug#5055417>
  p_ledger_id             IN  NUMBER,
  p_sequence_id           IN  NUMBER,
  x_report_created        OUT NOCOPY VARCHAR2
);
--<R12 SLA End>
--<bug#5085428 START>
FUNCTION is_req_enc_flipped(p_req_dist_id IN NUMBER,
                            p_event_id IN NUMBER)
                            RETURN VARCHAR2;
--<bug#5085428 END>

--<<Bug18898767>>
PROCEDURE do_unreserve(
  p_draft_id IN NUMBER,
  p_po_header_id IN NUMBER,
  p_employee_id IN NUMBER,
  x_enc_report_id OUT NOCOPY NUMBER,
  l_return_status OUT NOCOPY VARCHAR2,
  l_po_return_code OUT NOCOPY VARCHAR2
);
END PO_DOCUMENT_FUNDS_PVT;

/
