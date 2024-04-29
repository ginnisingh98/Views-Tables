--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_FUNDS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_FUNDS_GRP" AUTHID CURRENT_USER AS
-- $Header: POXGENCS.pls 120.1 2006/07/06 11:55:39 asista noship $

-- Global Variables

g_doc_type_REQUISITION CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_REQUISITION;
g_doc_type_PO CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_PO;
g_doc_type_PA CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_PA;
g_doc_type_RELEASE CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_RELEASE;
g_doc_type_MIXED_PO_RELEASE CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_MIXED_PO_RELEASE;
g_doc_type_ANY CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_ANY;

g_doc_subtype_STANDARD CONSTANT
   PO_HEADERS_ALL.type_lookup_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_STANDARD;
g_doc_subtype_PLANNED CONSTANT
   PO_HEADERS_ALL.type_lookup_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_PLANNED;
g_doc_subtype_BLANKET CONSTANT
   PO_RELEASES_ALL.release_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_BLANKET;
g_doc_subtype_SCHEDULED CONSTANT
   PO_RELEASES_ALL.release_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_SCHEDULED;
g_doc_subtype_MIXED_PO_RELEASE CONSTANT
   PO_HEADERS_ALL.type_lookup_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_MIXED_PO_RELEASE;

g_doc_level_HEADER         CONSTANT VARCHAR2(25)
   := PO_DOCUMENT_FUNDS_PVT.g_doc_level_HEADER;
g_doc_level_LINE           CONSTANT VARCHAR2(25)
   := PO_DOCUMENT_FUNDS_PVT.g_doc_level_LINE;
g_doc_level_SHIPMENT       CONSTANT VARCHAR2(25)
   := PO_DOCUMENT_FUNDS_PVT.g_doc_level_SHIPMENT;
g_doc_level_DISTRIBUTION   CONSTANT VARCHAR2(25)
   := PO_DOCUMENT_FUNDS_PVT.g_doc_level_DISTRIBUTION;

g_dist_type_STANDARD    CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_STANDARD;
g_dist_type_PLANNED     CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_PLANNED;
g_dist_type_SCHEDULED   CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_SCHEDULED;
g_dist_type_BLANKET     CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_BLANKET;
g_dist_type_AGREEMENT   CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_AGREEMENT;
g_dist_type_REQUISITION CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_REQUISITION;
g_dist_type_MIXED_PO_RELEASE CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_MIXED_PO_RELEASE;

g_adjustment_status_OLD    CONSTANT
   PO_ENCUMBRANCE_GT.adjustment_status%TYPE
   :=  PO_DOCUMENT_FUNDS_PVT.g_adjustment_status_OLD;
g_adjustment_status_NEW    CONSTANT
   PO_ENCUMBRANCE_GT.adjustment_status%TYPE
   :=  PO_DOCUMENT_FUNDS_PVT.g_adjustment_status_NEW;

g_parameter_YES            CONSTANT VARCHAR2(1)
   := PO_DOCUMENT_FUNDS_PVT.g_parameter_YES;
g_parameter_NO             CONSTANT VARCHAR2(1)
   := PO_DOCUMENT_FUNDS_PVT.g_parameter_NO;
g_parameter_USE_PROFILE    CONSTANT VARCHAR2(1)
   := PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE;

g_return_SUCCESS           CONSTANT VARCHAR2(10)
   := PO_DOCUMENT_FUNDS_PVT.g_return_SUCCESS;
g_return_WARNING           CONSTANT VARCHAR2(10)
   := PO_DOCUMENT_FUNDS_PVT.g_return_WARNING;
g_return_PARTIAL           CONSTANT VARCHAR2(10)
   := PO_DOCUMENT_FUNDS_PVT.g_return_PARTIAL;
g_return_FAILURE           CONSTANT VARCHAR2(10)
   := PO_DOCUMENT_FUNDS_PVT.g_return_FAILURE;
g_return_FATAL             CONSTANT VARCHAR2(10)
   := PO_DOCUMENT_FUNDS_PVT.g_return_FATAL;

g_action_FINAL_CLOSE     CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_FINAL_CLOSE;
g_action_RESERVE         CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_RESERVE;
g_action_CANCEL          CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_CANCEL;
g_action_ADJUST          CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_ADJUST;
g_action_UNRESERVE       CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_UNRESERVE;
g_action_REJECT          CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_REJECT;
g_action_RETURN          CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_RETURN;


g_MAIN        CONSTANT     VARCHAR2(10)
   := PO_DOCUMENT_FUNDS_PVT.g_MAIN;
g_BACKING     CONSTANT     VARCHAR2(10)
   := PO_DOCUMENT_FUNDS_PVT.g_BACKING;

PROCEDURE check_reserve(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_doc_level          IN           VARCHAR2
,  p_doc_level_id       IN           NUMBER
,  p_use_enc_gt_flag    IN           VARCHAR2
,  p_override_funds     IN           VARCHAR2
,  p_report_successes   IN           VARCHAR2
,  x_po_return_code     OUT  NOCOPY  VARCHAR2
,  x_detailed_results   OUT  NOCOPY  po_fcout_type
);


PROCEDURE check_adjust(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_override_funds     IN           VARCHAR2
,  p_use_gl_date        IN           VARCHAR2
,  p_override_date      IN           DATE
,  p_report_successes   IN           VARCHAR2
,  x_po_return_code     OUT  NOCOPY  VARCHAR2
,  x_detailed_results   OUT  NOCOPY  po_fcout_type
);


PROCEDURE do_reserve(
   p_api_version                    IN             NUMBER
,  p_commit                         IN             VARCHAR2
      default FND_API.G_FALSE
,  p_init_msg_list                  IN             VARCHAR2
      default FND_API.G_FALSE
,  p_validation_level               IN             NUMBER
      default FND_API.G_VALID_LEVEL_FULL
,  x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  p_prevent_partial_flag           IN             VARCHAR2
,  p_employee_id                    IN             NUMBER
,  p_override_funds                 IN             VARCHAR2
,  p_report_successes               IN             VARCHAR2
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_detailed_results               OUT NOCOPY     po_fcout_type
);


PROCEDURE do_unreserve(
   p_api_version                    IN             NUMBER
,  p_commit                         IN             VARCHAR2
      default FND_API.G_FALSE
,  p_init_msg_list                  IN             VARCHAR2
      default FND_API.G_FALSE
,  p_validation_level               IN             NUMBER
      default FND_API.G_VALID_LEVEL_FULL
,  x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  p_employee_id                    IN             NUMBER
,  p_override_funds                 IN             VARCHAR2
,  p_use_gl_date                    IN             VARCHAR2
,  p_override_date                  IN             DATE
,  p_report_successes               IN             VARCHAR2
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_detailed_results               OUT NOCOPY     po_fcout_type
);


PROCEDURE do_return(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_doc_level          IN           VARCHAR2
,  p_doc_level_id       IN           NUMBER
,  p_override_date      IN           DATE
,  p_use_gl_date        IN           VARCHAR2
,  p_report_successes   IN           VARCHAR2
,  x_po_return_code     OUT  NOCOPY  VARCHAR2
,  x_detailed_results   OUT  NOCOPY  po_fcout_type
);


PROCEDURE do_reject(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_doc_level          IN           VARCHAR2
,  p_doc_level_id       IN           NUMBER
,  p_override_funds     IN           VARCHAR2
,  p_use_gl_date        IN           VARCHAR2
,  p_override_date      IN           DATE
,  p_report_successes   IN           VARCHAR2
,  x_po_return_code     OUT  NOCOPY  VARCHAR2
,  x_detailed_results   OUT  NOCOPY  po_fcout_type
);


PROCEDURE do_cancel(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_doc_level          IN           VARCHAR2
,  p_doc_level_id       IN           NUMBER
,  p_override_funds     IN           VARCHAR2
,  p_use_gl_date        IN           VARCHAR2
,  p_override_date      IN           DATE
,  p_report_successes   IN           VARCHAR2
,  x_po_return_code     OUT  NOCOPY  VARCHAR2
,  x_detailed_results   OUT  NOCOPY  po_fcout_type
);


PROCEDURE do_adjust(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_employee_id        IN           NUMBER
,  p_override_funds     IN           VARCHAR2
,  p_use_gl_date        IN           VARCHAR2
,  p_override_date      IN           DATE
,  p_report_successes   IN           VARCHAR2
,  x_po_return_code     OUT  NOCOPY  VARCHAR2
,  x_detailed_results   OUT  NOCOPY  po_fcout_type
);


PROCEDURE do_final_close(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_doc_level          IN           VARCHAR2
,  p_doc_level_id       IN           NUMBER
,  p_override_date      IN           DATE
,  p_use_gl_date        IN           VARCHAR2
,  p_report_successes   IN           VARCHAR2
,  x_po_return_code     OUT  NOCOPY  VARCHAR2
,  x_detailed_results   OUT  NOCOPY  po_fcout_type
);


PROCEDURE reinstate_po_encumbrance(
   p_api_version       IN         NUMBER,
   p_commit            IN         VARCHAR2 default FND_API.G_FALSE,
   p_init_msg_list     IN         VARCHAR2 default FND_API.G_FALSE,
   p_validation_level  IN         NUMBER default FND_API.G_VALID_LEVEL_FULL,
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
   p_tax_line_flag     IN         VARCHAR2 default NULL,  -- Bug 3480949
   x_packet_id         OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2
);


PROCEDURE is_agreement_encumbered(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_agreement_id_tbl   IN           PO_TBL_NUMBER
,  x_agreement_encumbered_tbl        OUT NOCOPY PO_TBL_VARCHAR1
);


PROCEDURE is_reservable(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_doc_level          IN           VARCHAR2
,  p_doc_level_id       IN           NUMBER
,  x_reservable_flag    OUT  NOCOPY  VARCHAR2
);

PROCEDURE is_unreservable(
   p_api_version        IN           NUMBER
,  p_commit             IN           VARCHAR2   default FND_API.G_FALSE
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  p_doc_type           IN           VARCHAR2
,  p_doc_subtype        IN           VARCHAR2
,  p_doc_level          IN           VARCHAR2
,  p_doc_level_id       IN           NUMBER
,  x_unreservable_flag  OUT  NOCOPY  VARCHAR2
);

PROCEDURE populate_encumbrance_gt(
   p_api_version        IN           NUMBER
,  p_init_msg_list      IN           VARCHAR2   default FND_API.G_FALSE
,  p_validation_level   IN           NUMBER     default FND_API.G_VALID_LEVEL_FULL
,  x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  p_make_old_copies_flag           IN             VARCHAR2
,  p_make_new_copies_flag           IN             VARCHAR2
,  p_check_only_flag                IN             VARCHAR2
);
--<bug#5010001 START>

FUNCTION get_online_report_id RETURN NUMBER;

--<bug#5010001 END>
END PO_DOCUMENT_FUNDS_GRP;

 

/
