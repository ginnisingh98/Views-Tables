--------------------------------------------------------
--  DDL for Package PO_TAX_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_TAX_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_TAX_INTERFACE_PVT.pls 120.13.12010000.3 2010/05/07 05:49:10 vlalwani ship $ */

TYPE po_tax_errors_type IS RECORD(
  error_level         PO_TBL_VARCHAR20,
  document_type_code  PO_TBL_VARCHAR25,
  document_id         PO_TBL_NUMBER,
  document_num        PO_TBL_VARCHAR20, -- <Bug 9573874>
  line_id             PO_TBL_NUMBER,
  line_num            PO_TBL_NUMBER,
  line_location_id    PO_TBL_NUMBER,
  shipment_num        PO_TBL_NUMBER,
  distribution_id     PO_TBL_NUMBER,
  distribution_num    PO_TBL_NUMBER,
  message_text        PO_TBL_VARCHAR2000);

G_TAX_ERRORS_TBL po_tax_errors_type;

PROCEDURE calculate_tax(p_po_header_id_tbl    IN          PO_TBL_NUMBER,
                        p_po_release_id_tbl   IN          PO_TBL_NUMBER,
                        p_calling_program     IN          VARCHAR2,
                        x_return_status       OUT NOCOPY  VARCHAR2
);

PROCEDURE calculate_tax(p_po_header_id        IN          NUMBER,
                        p_po_release_id       IN          NUMBER,
                        p_calling_program     IN          VARCHAR2,
                        x_return_status       OUT NOCOPY  VARCHAR2
);

PROCEDURE calculate_tax_requisition(p_requisition_header_id  IN     NUMBER,
                                    p_calling_program        IN     VARCHAR2,
                                    x_return_status     OUT NOCOPY  VARCHAR2);

PROCEDURE determine_recovery_po(p_po_header_id  IN         NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE determine_recovery_rel(p_po_release_id  IN       NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE determine_recovery_req(p_requisition_header_id IN NUMBER,
                                 x_return_status OUT NOCOPY VARCHAR2);

FUNCTION calculate_tax_yes_no
        (p_po_header_id        IN          NUMBER,
         p_po_release_id       IN          NUMBER,
         p_req_header_id       IN          NUMBER)
RETURN VARCHAR2;

PROCEDURE SHIPMENT_DIST_DELETED_FROM_OA
(
  P_PO_HEADER_ID              IN NUMBER,
  P_DEL_SHIPMENT_TABLE        IN PO_TBL_NUMBER,
  P_DEL_DIST_SHIPMENT_TABLE   IN PO_TBL_NUMBER
);

PROCEDURE initialize_global_error_record;

PROCEDURE append_error(p_error_level         IN VARCHAR2,
                       p_document_type_code  IN VARCHAR2,
                       p_document_id         IN NUMBER,
                       p_document_num        IN VARCHAR2, --<BUG 9661881>
                       p_line_id             IN NUMBER,
                       p_line_num            IN NUMBER,
                       p_line_location_id    IN NUMBER,
                       p_shipment_num        IN NUMBER,
                       p_distribution_id     IN NUMBER,
                       p_distribution_num    IN NUMBER,
                       p_message_text        IN VARCHAR2);

FUNCTION any_tax_attributes_updated(
  p_doc_type        IN  VARCHAR2,
  p_doc_level       IN  VARCHAR2,
  p_doc_level_id    IN  NUMBER,
  p_trx_currency    IN  VARCHAR2  DEFAULT NULL,
  p_rate_type       IN  VARCHAR2  DEFAULT NULL,
  p_rate_date       IN  DATE      DEFAULT NULL,
  p_rate            IN  NUMBER    DEFAULT NULL,
  p_fob             IN  VARCHAR2  DEFAULT NULL,
  p_vendor_id       IN  NUMBER    DEFAULT NULL,
  p_vendor_site_id  IN  NUMBER    DEFAULT NULL,
  p_bill_to_loc     IN  NUMBER    DEFAULT NULL, --<ECO 5524555>
  p_uom             IN  VARCHAR2  DEFAULT NULL,
  p_price           IN  NUMBER    DEFAULT NULL,
  p_qty             IN  NUMBER    DEFAULT NULL,
  p_price_override  IN  NUMBER    DEFAULT NULL, --<Bug 5647417>
  p_amt             IN  NUMBER    DEFAULT NULL,
  p_ship_to_org     IN  NUMBER    DEFAULT NULL,
  p_ship_to_loc     IN  NUMBER    DEFAULT NULL,
  p_need_by_date    IN  DATE      DEFAULT NULL,
  p_src_doc         IN  NUMBER    DEFAULT NULL,
  p_src_ship        IN  NUMBER    DEFAULT NULL,
  p_ccid            IN  NUMBER    DEFAULT NULL,
  p_tax_rec_rate    IN  NUMBER    DEFAULT NULL,
  p_project         IN  NUMBER    DEFAULT NULL,
  p_task            IN  NUMBER    DEFAULT NULL,
  p_award           IN  NUMBER    DEFAULT NULL,
  p_exp_type        IN  VARCHAR2  DEFAULT NULL,
  p_exp_org         IN  NUMBER    DEFAULT NULL,
  p_exp_date        IN  DATE      DEFAULT NULL,
  p_dist_quantity_ordered  IN  NUMBER    DEFAULT NULL,
  p_dist_amount_ordered IN  NUMBER    DEFAULT NULL
) RETURN BOOLEAN;

--  Introduced with Bug 4695557.
PROCEDURE cancel_tax_lines(p_document_type  IN VARCHAR2,
                           p_document_id    IN NUMBER,
                           p_line_id        IN NUMBER,
                           p_shipment_id    IN NUMBER,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2);

PROCEDURE global_document_update(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2,
                                 p_commit           IN  VARCHAR2,
                                 p_validation_level IN  NUMBER,
                                 x_return_status    OUT NOCOPY VARCHAR2,
                                 x_msg_count        OUT NOCOPY NUMBER,
                                 x_msg_data         OUT NOCOPY VARCHAR2,
                                 p_org_id           IN  NUMBER,
                                 p_document_type    IN  VARCHAR2,
                                 p_document_id      IN  NUMBER,
                                 p_event_type_code  IN  VARCHAR2);

PROCEDURE unapprove_doc_header(p_document_id   IN         NUMBER,
                               p_document_type IN         VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE unapprove_schedules(p_line_location_id_tbl  IN PO_TBL_NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2);

END PO_TAX_INTERFACE_PVT;

/
