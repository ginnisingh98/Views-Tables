--------------------------------------------------------
--  DDL for Package PO_PDOI_LINE_LOC_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_LINE_LOC_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_LINE_LOC_PROCESS_PVT.pls 120.2.12010000.2 2013/10/03 08:35:21 inagdeo ship $ */

PROCEDURE open_line_locs
(
  p_max_intf_line_loc_id IN NUMBER,
  x_line_locs_csr        OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type
);

PROCEDURE fetch_line_locs
(
  x_line_locs_csr IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type,
  x_line_locs     OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);

PROCEDURE derive_line_locs
(
  x_line_locs     IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);

PROCEDURE default_line_locs
(
  x_line_locs     IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);

-- <<PDOI Enhancement Bug#17063664 Start>>
PROCEDURE process_conversions
(
  x_line_locs     IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);

-- <<PDOI Enhancement Bug#17063664 End>>

PROCEDURE validate_line_locs
(
  x_line_locs     IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);

PROCEDURE update_line_loc_interface
(
  p_intf_line_loc_id_tbl   IN PO_TBL_NUMBER,
  p_line_loc_id_tbl        IN PO_TBL_NUMBER,
  p_action_tbl             IN PO_TBL_VARCHAR30, --PDOI Enhancement bug#17063664
  p_error_flag_tbl         IN PO_TBL_VARCHAR1
);

PROCEDURE update_amount_quantity
(
  p_key                  IN  po_session_gt.key%TYPE
);

PROCEDURE delete_exist_price_breaks
(
  p_po_line_id_tbl         IN DBMS_SQL.NUMBER_TABLE,
  p_draft_id_tbl           IN DBMS_SQL.NUMBER_TABLE
);


--<PDOI Enhancement Bug#17063664>
-- Update Price on Line
PROCEDURE update_price_on_line
(
  p_key                  IN  po_session_gt.key%TYPE
);

-- <<PDOI Enhancement Bug#17063664>>

-- Making the below procedure as public
PROCEDURE derive_ship_to_org_id
(
  p_key                  IN po_session_gt.key%TYPE,
  p_index_tbl            IN DBMS_SQL.NUMBER_TABLE,
  p_ship_to_org_code_tbl IN PO_TBL_VARCHAR5,
  x_ship_to_org_id_tbl   IN OUT NOCOPY PO_TBL_NUMBER
);

-- Making the below procedure as public
PROCEDURE default_ship_to_org_id
(
  p_key                          IN po_session_gt.key%TYPE,
  p_index_tbl                    IN DBMS_SQL.NUMBER_TABLE,
  p_ship_to_loc_id_tbl           IN PO_TBL_NUMBER,
  x_ship_to_org_id_tbl           IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE setup_line_locs_intf;

PROCEDURE populate_advance_payitem
(
  p_intf_line_id_tbl       IN PO_TBL_NUMBER,
  p_complex_style_flag_tbl IN PO_TBL_VARCHAR1,
  p_advances_flag_tbl      IN PO_TBL_VARCHAR1
);

PROCEDURE populate_progress_payitem
(
  p_intf_line_id_tbl              IN PO_TBL_NUMBER,
  p_complex_style_flag_tbl        IN PO_TBL_VARCHAR1,
  p_financing_style_flag_tbl      IN PO_TBL_VARCHAR1
);

PROCEDURE match_line_locs
(
 x_line_locs          IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
 x_create_line_locs   IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
 x_update_line_locs   IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);


-- <<PDOI Enhancement Bug#17063664 End>>

END PO_PDOI_LINE_LOC_PROCESS_PVT;

/
