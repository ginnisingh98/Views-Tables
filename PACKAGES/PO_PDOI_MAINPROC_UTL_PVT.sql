--------------------------------------------------------
--  DDL for Package PO_PDOI_MAINPROC_UTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_MAINPROC_UTL_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_MAINPROC_UTL_PVT.pls 120.4 2005/12/05 23:06 jinwang noship $ */

PROCEDURE cleanup;

FUNCTION get_quotation_class_code
(
  p_doc_subtype IN VARCHAR2
) RETURN VARCHAR2;

PROCEDURE default_who_columns(
  x_last_update_date_tbl       IN OUT NOCOPY PO_TBL_DATE,
  x_last_updated_by_tbl        IN OUT NOCOPY PO_TBL_NUMBER,
  x_last_update_login_tbl      IN OUT NOCOPY PO_TBL_NUMBER,
  x_creation_date_tbl          IN OUT NOCOPY PO_TBL_DATE,
  x_created_by_tbl             IN OUT NOCOPY PO_TBL_NUMBER,
  x_request_id_tbl             IN OUT NOCOPY PO_TBL_NUMBER,
  x_program_application_id_tbl IN OUT NOCOPY PO_TBL_NUMBER,
  x_program_id_tbl             IN OUT NOCOPY PO_TBL_NUMBER,
  x_program_update_date_tbl    IN OUT NOCOPY PO_TBL_DATE
);

-- line related utility method
PROCEDURE calculate_max_line_num
(
  p_po_header_id_tbl    IN PO_TBL_NUMBER,
  p_draft_id_tbl        IN PO_TBL_NUMBER
);

FUNCTION get_next_line_num
(
  p_po_header_id        IN NUMBER
) RETURN NUMBER;

FUNCTION get_next_po_line_id
RETURN NUMBER;

PROCEDURE check_line_num_unique
(
  p_po_header_id_tbl    IN PO_TBL_NUMBER,
  p_draft_id_tbl        IN PO_TBL_NUMBER,
  p_intf_line_id_tbl    IN PO_TBL_NUMBER,
  p_line_num_tbl        IN PO_TBL_NUMBER,
  x_line_num_unique_tbl OUT NOCOPY PO_TBL_VARCHAR1
);

-- location related utility method
PROCEDURE calculate_max_shipment_num
(
  p_po_line_id_tbl      IN PO_TBL_NUMBER,
  p_draft_id_tbl        IN PO_TBL_NUMBER
);

FUNCTION get_next_shipment_num
(
  p_po_line_id          IN NUMBER
) RETURN NUMBER;

FUNCTION get_next_line_loc_id
RETURN NUMBER;

PROCEDURE check_shipment_num_unique
(
  p_po_line_id_tbl          IN PO_TBL_NUMBER,
  p_draft_id_tbl            IN PO_TBL_NUMBER,
  p_intf_line_loc_id_tbl    IN PO_TBL_NUMBER,
  p_shipment_num_tbl        IN PO_TBL_NUMBER,
  x_shipment_num_unique_tbl OUT NOCOPY PO_TBL_VARCHAR1
);

-- Distribution related utility method
PROCEDURE calculate_max_dist_num
(
  p_line_loc_id_tbl      IN PO_TBL_NUMBER,
  p_draft_id_tbl         IN PO_TBL_NUMBER
);

FUNCTION get_next_dist_num
(
  p_line_loc_id          IN NUMBER
) RETURN NUMBER;

FUNCTION get_next_dist_id
RETURN NUMBER;

PROCEDURE check_dist_num_unique
(
  p_line_loc_id_tbl     IN PO_TBL_NUMBER,
  p_draft_id_tbl        IN PO_TBL_NUMBER,
  p_intf_dist_id_tbl    IN PO_TBL_NUMBER,
  p_dist_num_tbl        IN PO_TBL_NUMBER,
  x_dist_num_unique_tbl OUT NOCOPY PO_TBL_VARCHAR1
);

-- Price Differential related utility method
PROCEDURE calculate_max_price_diff_num
(
  p_entity_type_tbl      IN PO_TBL_VARCHAR30,
  p_entity_id_tbl        IN PO_TBL_NUMBER,
  p_draft_id_tbl         IN PO_TBL_NUMBER,
  p_price_diff_num_tbl   IN PO_TBL_NUMBER
);

FUNCTION get_next_price_diff_num
(
  p_entity_type IN VARCHAR2,
  p_entity_id   IN NUMBER
)
RETURN NUMBER;

PROCEDURE check_price_diff_num_unique
(
  p_entity_type_tbl            IN PO_TBL_VARCHAR30,
  p_entity_id_tbl              IN PO_TBL_NUMBER,
  p_draft_id_tbl               IN PO_TBL_NUMBER,
  p_intf_price_diff_id_tbl     IN PO_TBL_NUMBER,
  p_price_diff_num_tbl         IN PO_TBL_NUMBER,
  x_price_diff_num_unique_tbl  OUT NOCOPY PO_TBL_VARCHAR1
);

-- utility method used in item creation
FUNCTION get_next_set_process_id
RETURN NUMBER;

-- utility method to get precision from currency
FUNCTION get_currency_precision
(
  p_currency_code         IN VARCHAR2,
  x_precision_tbl         IN OUT NOCOPY PO_PDOI_TYPES.varchar_index_tbl_type
) RETURN NUMBER;

END PO_PDOI_MAINPROC_UTL_PVT;

 

/
