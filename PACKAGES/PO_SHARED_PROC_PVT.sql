--------------------------------------------------------
--  DDL for Package PO_SHARED_PROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SHARED_PROC_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVSPSS.pls 120.0.12010000.2 2013/10/03 09:31:09 inagdeo ship $ */

PROCEDURE check_transaction_flow
(
    p_init_msg_list              IN  VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    p_start_ou_id                IN  NUMBER,
    p_end_ou_id                  IN  NUMBER,
    p_ship_to_org_id             IN  NUMBER,
    p_item_category_id           IN  NUMBER,
    p_transaction_date           IN  DATE,
    x_transaction_flow_header_id OUT NOCOPY NUMBER
);

FUNCTION get_coa_from_inv_org
(
    p_inv_org_id IN NUMBER
)
RETURN NUMBER;

PROCEDURE get_ou_and_coa_from_inv_org
(
    p_inv_org_id    IN  NUMBER,
    x_coa_id        OUT NOCOPY NUMBER,
    x_ou_id         OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2
);

FUNCTION is_SPS_distribution
(
    p_destination_type_code      IN VARCHAR2,
    p_document_type_code         IN VARCHAR2,
    p_purchasing_ou_id           IN NUMBER,
    p_project_id                 IN NUMBER,
    p_ship_to_ou_id              IN NUMBER,
    p_transaction_flow_header_id IN NUMBER
)
RETURN BOOLEAN;

FUNCTION is_pa_project_referenced
(
    p_requisition_line_id IN NUMBER
)
RETURN BOOLEAN;

PROCEDURE validate_cross_ou_purchasing
(
    p_api_version         IN NUMBER,
    p_requisition_line_id IN NUMBER,
    p_requesting_org_id   IN NUMBER,
    p_purchasing_org_id   IN NUMBER,
    p_item_id             IN NUMBER,
    p_source_doc_id       IN NUMBER,
    p_vmi_flag            IN VARCHAR2,
    p_cons_from_supp_flag IN VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_msg_name      OUT NOCOPY VARCHAR2,
    p_document_type		  IN VARCHAR2 := 'STANDARD'                 -- <HTMLAC>
);

PROCEDURE validate_cross_ou_tbl                               -- <HTMLAC START>
(
    p_req_line_id_tbl        IN         PO_TBL_NUMBER
,   p_requesting_org_id_tbl  IN         PO_TBL_NUMBER
,   p_purchasing_org_id      IN         NUMBER
,   p_document_type          IN         VARCHAR2
,   p_item_id_tbl            IN         PO_TBL_NUMBER
,   p_source_doc_id_tbl      IN         PO_TBL_NUMBER
,   p_vmi_flag_tbl           IN         PO_TBL_VARCHAR1
,   p_consigned_flag_tbl     IN         PO_TBL_VARCHAR1
,   x_valid_flag_tbl         OUT NOCOPY PO_TBL_VARCHAR1
,   x_error_msg_tbl          OUT NOCOPY PO_TBL_VARCHAR30
);                                                              -- <HTMLAC END>

PROCEDURE check_item_in_inventory_org
(
    p_init_msg_list IN  VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    p_item_id       IN  NUMBER,
    p_item_revision IN  VARCHAR2,
    p_inv_org_id    IN  NUMBER,
    x_in_inv_org    OUT NOCOPY BOOLEAN
);

PROCEDURE validate_ship_to_org
(
    p_init_msg_list              IN  VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    p_ship_to_org_id             IN  NUMBER,
    p_item_category_id           IN  NUMBER,
    p_item_id                    IN  NUMBER, -- Bug 3433867
    x_is_valid                   OUT NOCOPY BOOLEAN,
    x_in_current_sob             OUT NOCOPY BOOLEAN,
    x_check_txn_flow             OUT NOCOPY BOOLEAN,
    x_transaction_flow_header_id OUT NOCOPY NUMBER
);

FUNCTION is_txn_flow_supported RETURN BOOLEAN;

FUNCTION get_inv_qualifier_code RETURN NUMBER;

PROCEDURE do_item_validity_checks(
                      p_item_id             IN NUMBER,
                      p_org_id              IN NUMBER,
                      p_valid_org_id        IN NUMBER,
                      p_do_osp_check        IN BOOLEAN,
                      x_return_status       OUT NOCOPY VARCHAR2,
                      x_item_valid_msg_name OUT NOCOPY VARCHAR2);

FUNCTION get_logical_inv_org_id
(
    p_transaction_flow_header_id IN NUMBER
)
RETURN NUMBER;

PROCEDURE get_po_setup_parameters
(
    p_org_id         IN NUMBER,
    x_po_num_code    OUT NOCOPY VARCHAR2,
    x_po_num_type    OUT NOCOPY VARCHAR2
);

-- Bug 3433867: added the following procedure to perform extra item
-- validation for Shared Procurement
PROCEDURE check_item_in_linv_pou
(
    x_return_status              OUT NOCOPY VARCHAR2,
    p_item_id                    IN  NUMBER,
    p_transaction_flow_header_id IN  NUMBER,
    x_item_in_linv_pou           OUT NOCOPY VARCHAR2
);

-- <<PDOI Enhancement Bug#17063664 Start>>

PROCEDURE validate_cross_ou_purchasing
(
    p_line_id_tbl                  IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl      IN PO_TBL_NUMBER ,
    p_item_id_tbl                  IN PO_TBL_NUMBER ,
    p_vmi_flag_tbl                 IN PO_TBL_VARCHAR1 ,
    p_cons_from_supp_flag_tbl      IN PO_TBL_VARCHAR1 ,
    p_txn_flow_header_id_tbl       IN PO_TBL_NUMBER ,
    p_source_doc_id_tbl            IN PO_TBL_NUMBER ,
    p_purchasing_org_id_tbl        IN PO_TBL_NUMBER ,
    p_requesting_org_id_tbl        IN PO_TBL_NUMBER ,
    p_dest_inv_org_ou_id_tbl       IN PO_TBL_NUMBER ,
    p_deliver_to_location_id_tbl   IN PO_TBL_NUMBER ,
    p_destination_org_id_tbl       IN PO_TBL_NUMBER ,
    p_destination_type_code_tbl    IN PO_TBL_VARCHAR30 ,
    p_document_type_tbl            IN PO_TBL_VARCHAR30 ,
    x_result_set_id                IN OUT NOCOPY NUMBER,
    x_results                      IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE ,
    x_result_type                  OUT NOCOPY VARCHAR2
);

PROCEDURE cross_ou_vmi_check
(
    p_line_id_tbl             IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl IN PO_TBL_NUMBER ,
    p_vmi_flag_tbl            IN PO_TBL_VARCHAR1 ,
    p_document_type_tbl       IN PO_TBL_VARCHAR30 ,
    x_result_set_id           IN OUT NOCOPY NUMBER ,
    x_result_type             OUT NOCOPY VARCHAR2
);

PROCEDURE cross_ou_consigned_check
(
    p_line_id_tbl             IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl IN PO_TBL_NUMBER ,
    p_cons_from_supp_flag_tbl IN PO_TBL_VARCHAR1 ,
    p_document_type_tbl       IN PO_TBL_VARCHAR30 ,
    x_result_set_id           IN OUT NOCOPY NUMBER ,
    x_result_type             OUT NOCOPY VARCHAR2
);

PROCEDURE cross_ou_item_validity_check
(
    p_line_id_tbl               IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl   IN PO_TBL_NUMBER ,
    p_item_id_tbl               IN PO_TBL_NUMBER ,
    p_global_agreement_flag_tbl IN PO_TBL_VARCHAR1 ,
    p_purchasing_org_id_tbl     IN PO_TBL_NUMBER ,
    p_requesting_org_id_tbl     IN PO_TBL_NUMBER ,
    p_owning_org_id_tbl         IN PO_TBL_NUMBER ,
    p_document_type_tbl         IN PO_TBL_VARCHAR30 ,
    x_result_set_id             IN OUT NOCOPY NUMBER ,
    x_result_type               OUT NOCOPY VARCHAR2
);

PROCEDURE cross_ou_pa_project_check
(
    p_line_id_tbl                 IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl     IN PO_TBL_NUMBER ,
    p_project_referenced_flag_tbl IN PO_TBL_VARCHAR1 ,
    p_document_type_tbl           IN PO_TBL_VARCHAR30 ,
    x_result_set_id               IN OUT NOCOPY NUMBER ,
    x_result_type                 OUT NOCOPY VARCHAR2
);

PROCEDURE cross_ou_dest_ou_check
(
    p_line_id_tbl             IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl IN PO_TBL_NUMBER ,
    p_dest_inv_org_ou_id_tbl  IN PO_TBL_NUMBER ,
    p_purchasing_org_id_tbl   IN PO_TBL_NUMBER ,
    p_requesting_org_id_tbl   IN PO_TBL_NUMBER ,
    p_document_type_tbl       IN PO_TBL_VARCHAR30 ,
    x_result_set_id           IN OUT NOCOPY NUMBER ,
    x_result_type             OUT NOCOPY VARCHAR2
);

PROCEDURE cross_ou_txn_flow_check
(
    p_line_id_tbl                    IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl        IN PO_TBL_NUMBER ,
    p_txn_flow_header_id_tbl         IN PO_TBL_NUMBER ,
    p_item_id_tbl                    IN PO_TBL_NUMBER ,
    p_document_type_tbl              IN PO_TBL_VARCHAR30 ,
    x_result_set_id                  IN OUT NOCOPY NUMBER ,
    x_result_type                    OUT NOCOPY VARCHAR2
);

PROCEDURE cross_ou_services_check
(
    p_line_id_tbl             IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl IN PO_TBL_NUMBER ,
    p_purchasing_org_id_tbl   IN PO_TBL_NUMBER ,
    p_requesting_org_id_tbl   IN PO_TBL_NUMBER ,
    p_document_type_tbl       IN PO_TBL_VARCHAR30 ,
    x_result_set_id           IN OUT NOCOPY NUMBER ,
    x_result_type             OUT NOCOPY VARCHAR2
);

PROCEDURE cross_ou_cust_loc_check
(
    p_line_id_tbl                IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl    IN PO_TBL_NUMBER ,
    p_deliver_to_location_id_tbl IN PO_TBL_NUMBER ,
    p_document_type_tbl          IN PO_TBL_VARCHAR30 ,
    x_result_set_id              IN OUT NOCOPY NUMBER ,
    x_result_type                OUT NOCOPY VARCHAR2
);

PROCEDURE cross_ou_ga_encumbrance_check
(
    p_line_id_tbl             IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl IN PO_TBL_NUMBER ,
    p_requesting_org_id_tbl   IN PO_TBL_NUMBER ,
    p_purchasing_org_id_tbl   IN PO_TBL_NUMBER ,
    p_document_type_tbl       IN PO_TBL_VARCHAR30 ,
    x_result_set_id           IN OUT NOCOPY NUMBER ,
    x_result_type             OUT NOCOPY VARCHAR2
);

-- <<PDOI Enhancement Bug#17063664 End>>

END PO_SHARED_PROC_PVT;

/
