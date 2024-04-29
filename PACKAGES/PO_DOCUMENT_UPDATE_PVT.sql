--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_UPDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVCPOS.pls 120.2.12010000.4 2012/10/31 09:05:15 mitao ship $*/

-------------------------------------------------------------------------------
--Start of Comments
--Name: update_document
--Function:
-- Validates and applies the requested changes and any derived
-- changes to the Purchase Order, Purchase Agreement, or Release.
--Note:
-- For details, see the package body comments.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE update_document (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2,
  p_changes                IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  p_run_submission_checks  IN VARCHAR2,
  p_launch_approvals_flag  IN VARCHAR2,
  p_buyer_id               IN NUMBER,
  p_update_source          IN VARCHAR2,
  p_override_date          IN DATE,
  x_api_errors             OUT NOCOPY PO_API_ERRORS_REC_TYPE,
  p_approval_background_flag IN VARCHAR2 DEFAULT NULL,
  p_mass_update_releases   IN VARCHAR2 DEFAULT NULL, -- Bug 3373453
  p_req_chg_initiator      IN VARCHAR2 DEFAULT NULL --Bug 14549341
);

-- Bug 3605355 START
-------------------------------------------------------------------------------
--Start of Comments
--Name: launch_po_approval_wf
--Function:
--  Launches the Document Approval workflow for the given document.
--Note:
-- For details, see the package body comments for
-- PO_DOCUMENT_UPDATE_PVT.launch_po_approval_wf.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE launch_po_approval_wf (
  p_api_version           IN NUMBER,
  p_init_msg_list         IN VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  p_document_id           IN NUMBER,
  p_document_type         IN PO_DOCUMENT_TYPES_ALL_B.document_type_code%TYPE,
  p_document_subtype      IN PO_DOCUMENT_TYPES_ALL_B.document_subtype%TYPE,
  p_preparer_id           IN NUMBER,
  p_approval_background_flag IN VARCHAR2,
  p_mass_update_releases  IN VARCHAR2,
  p_retroactive_price_change IN VARCHAR2
);
-- Bug 3605355 END

-- Parameter value constants:

G_PARAMETER_YES VARCHAR2(1) := PO_CORE_S.G_PARAMETER_YES;
G_PARAMETER_NO  VARCHAR2(1) := PO_CORE_S.G_PARAMETER_NO;

-- Constants for the p_update_source parameter of update_document:

G_UPDATE_SOURCE_OM CONSTANT VARCHAR2(10) := 'OM'; -- OM (Drop Ship Integration)

-- Entity type constants:

G_ENTITY_TYPE_CHANGES CONSTANT VARCHAR2(30) := 'PO_CHANGES_REC_TYPE';
G_ENTITY_TYPE_LINES CONSTANT VARCHAR2(30) := 'PO_LINES_REC_TYPE';
G_ENTITY_TYPE_SHIPMENTS CONSTANT VARCHAR2(30) := 'PO_SHIPMENTS_REC_TYPE';
G_ENTITY_TYPE_DISTRIBUTIONS CONSTANT VARCHAR2(30)
  := 'PO_DISTRIBUTIONS_REC_TYPE';

-- Use this constant in the change object to indicate that a field should be
-- set to NULL.
G_NULL_NUM CONSTANT NUMBER := 9.99E125; -- (See FND_API.G_MISS_NUM.)

G_CALL_MOD_HTML_CONTROL_ACTION CONSTANT VARCHAR2(30) :='HTML_CONTROL_ACTION';
-------------------------------------------------------------------------------
--Start of Comments
--Name: init_change_indexes
--Function:
--  Clears the change indexes, including the line changes index, the
--  shipment changes index, etc.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE init_change_indexes;

-------------------------------------------------------------------------------
--Start of Comments
--Name: add_line_change_to_index
--Function:
--  Adds the i-th line change in p_chg to the line changes index.
--  Raises a duplicate_change_exception if the index already has a change
--  for the same PO_LINE_ID.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE add_line_change_to_index (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
);

-------------------------------------------------------------------------------
--Start of Comments
--Name: add_ship_change_to_index
--Function:
--  Adds the i-th shipment change in p_chg to the shipment changes index.
--  Raises a duplicate_change_exception if the index already has a change
--  for the same LINE_LOCATION_ID.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE add_ship_change_to_index (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
);

-------------------------------------------------------------------------------
--Start of Comments
--Name: add_dist_change_to_index
--Function:
--  Adds the i-th distribution change in p_chg to the distribution changes
--  index. Raises a duplicate_change_exception if the index already has a
--  change for the same PO_DISTRIBUTION_ID.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE add_dist_change_to_index (
  p_chg IN PO_CHANGES_REC_TYPE,
  i     IN NUMBER
);

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_line_change
--Function:
--  Returns the index of the line change for p_po_line_id.
--  If none exists, returns NULL.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_line_change (
  p_po_line_id          IN PO_LINES.po_line_id%TYPE
) RETURN NUMBER;

-------------------------------------------------------------------------------
--Start of Comments
--Name: find_line_change
--Function:
--  Returns the index of the line change for p_po_line_id.
--  If none exists, adds a line change for p_po_line_id and returns its index.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION find_line_change (
  p_chg                 IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  p_po_line_id          IN PO_LINES.po_line_id%TYPE
) RETURN NUMBER;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_ship_change
--Function:
--  Returns the index of the shipment change for p_po_line_id.
--  If none exists, returns NULL.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_ship_change (
  p_line_location_id    IN PO_LINE_LOCATIONS.line_location_id%TYPE
) RETURN NUMBER;

-------------------------------------------------------------------------------
--Start of Comments
--Name: find_ship_change
--Function:
--  Returns the index of the shipment change for p_line_location_id.
--  If none exists, adds a shipment change for p_line_location_id and
--  returns its index.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION find_ship_change (
  p_chg                 IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  p_line_location_id    IN PO_LINE_LOCATIONS.line_location_id%TYPE
) RETURN NUMBER;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_dist_change
--Function:
--  Returns the index of the distribution change for p_po_distribution_id.
--  If none exists, returns NULL.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_dist_change (
  p_po_distribution_id    IN PO_DISTRIBUTIONS.po_distribution_id%TYPE
) RETURN NUMBER;

-------------------------------------------------------------------------------
--Start of Comments
--Name: find_dist_change
--Function:
--  Returns the index of the distribution change for p_po_distribution_id.
--  If none exists, adds a distribution change for p_po_distribution_id and
--  returns its index.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION find_dist_change (
  p_chg                 IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  p_po_distribution_id  IN PO_DISTRIBUTIONS.po_distribution_id%TYPE
) RETURN NUMBER;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_split_ship_change
--Function:
--  Returns the index of the split shipment change for p_parent_line_location_id
--  and p_split_shipment_num. If none exists, returns NULL.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_split_ship_change (
  p_chg                    IN PO_CHANGES_REC_TYPE,
  p_po_line_id             IN PO_LINES.po_line_id%TYPE,
  p_parent_line_loc_id     IN PO_LINE_LOCATIONS.line_location_id%TYPE,
  p_split_shipment_num     IN PO_LINE_LOCATIONS.shipment_num%TYPE
) RETURN NUMBER;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_split_dist_change
--Function:
--  Returns the index of the split distribution change for
--  p_parent_distribution_id and p_split_shipment_num.
--  If none exists, returns NULL.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_split_dist_change (
  p_chg                    IN PO_CHANGES_REC_TYPE,
  p_parent_distribution_id IN PO_DISTRIBUTIONS.po_distribution_id%TYPE,
  p_parent_line_loc_id     IN PO_LINE_LOCATIONS.line_location_id%TYPE,
  p_split_shipment_num     IN PO_LINE_LOCATIONS.shipment_num%TYPE
) RETURN NUMBER;

-------------------------------------------------------------------------------
--Start of Comments
--Name: find_split_dist_change
--Function:
--  Returns the index of the split distribution change for
--  p_parent_distribution_id and p_split_shipment_num.
--  If none exists, adds a distribution change for this split distribution
--  and returns its index.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION find_split_dist_change (
  p_chg                    IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  p_parent_distribution_id IN PO_DISTRIBUTIONS.po_distribution_id%TYPE,
  p_parent_line_loc_id     IN PO_LINE_LOCATIONS.line_location_id%TYPE,
  p_split_shipment_num     IN PO_LINE_LOCATIONS.shipment_num%TYPE
) RETURN NUMBER;

-------------------------------------------------------------------------------
--Start of Comments
--Name: add_error
--Function:
--  Adds an error message to p_api_errors.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE add_error
( p_api_errors          IN OUT NOCOPY PO_API_ERRORS_REC_TYPE,
  x_return_status       OUT NOCOPY VARCHAR2,
  p_message_name        IN VARCHAR2,
  p_message_text        IN VARCHAR2 DEFAULT NULL,
  p_table_name          IN VARCHAR2 DEFAULT NULL,
  p_column_name         IN VARCHAR2 DEFAULT NULL,
  p_entity_type         IN VARCHAR2 DEFAULT NULL,
  p_entity_id           IN NUMBER   DEFAULT NULL,
  p_token_name1  	IN VARCHAR2 DEFAULT NULL,
  p_token_value1 	IN VARCHAR2 DEFAULT NULL,
  p_token_name2  	IN VARCHAR2 DEFAULT NULL,
  p_token_value2 	IN VARCHAR2 DEFAULT NULL,
  p_module              IN VARCHAR2 DEFAULT NULL,
  p_level               IN VARCHAR2 DEFAULT NULL,
  p_message_type        IN VARCHAR2 DEFAULT NULL
);

-------------------------------------------------------------------------------
--Start of Comments
--Name: add_message_list_errors
--Function:
--  Adds all the messages on the standard API message list to p_api_errors.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE add_message_list_errors
( p_api_errors          IN OUT NOCOPY PO_API_ERRORS_REC_TYPE,
  x_return_status       OUT NOCOPY VARCHAR2,
  p_start_index         IN NUMBER   DEFAULT NULL,
  p_entity_type         IN VARCHAR2 DEFAULT NULL,
  p_entity_id           IN NUMBER   DEFAULT NULL
);

--<HTML Agreements R12 Start>
PROCEDURE validate_delete_action( p_entity          IN VARCHAR2
                                 ,p_doc_type        IN VARCHAR2
                                 ,p_doc_header_id   IN NUMBER
                                 ,p_po_line_id      IN NUMBER
                                 ,p_line_loc_id     IN NUMBER
                                 ,p_distribution_id IN NUMBER
                                 ,x_error_message   OUT NOCOPY VARCHAR2);

PROCEDURE process_delete_action( p_init_msg_list       IN VARCHAR2
                                ,x_return_status       OUT NOCOPY VARCHAR2
                                ,p_calling_program     IN VARCHAR2
                                ,p_entity              IN VARCHAR2
                                ,p_entity_row_id       IN ROWID
                                ,p_doc_type            IN VARCHAR2
                                ,p_doc_subtype         IN VARCHAR2
                                ,p_doc_header_id       IN NUMBER
                                ,p_ga_flag             IN VARCHAR2
                                ,p_conterms_exist_flag IN VARCHAR2
                                ,p_po_line_id          IN NUMBER
                                ,p_line_loc_id         IN NUMBER
                                ,p_distribution_id     IN NUMBER
                                ,x_error_msg_tbl       OUT NOCOPY PO_TBL_VARCHAR2000);
--<HTML Agreements R12 End>
END PO_DOCUMENT_UPDATE_PVT;

/
