--------------------------------------------------------
--  DDL for Package PO_PDOI_MOVE_TO_DRAFT_TABS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_MOVE_TO_DRAFT_TABS_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_MOVE_TO_DRAFT_TABS_PVT.pls 120.1 2005/08/18 18:58 jinwang noship $ */

PROCEDURE insert_headers
(
  p_headers     IN PO_PDOI_TYPES.headers_rec_type
);

PROCEDURE insert_lines
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE update_lines
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE insert_line_locs
(
  p_line_locs   IN PO_PDOI_TYPES.line_locs_rec_type
);

PROCEDURE insert_dists
(
  p_dists       IN PO_PDOI_TYPES.distributions_rec_type
);

PROCEDURE insert_price_diffs
(
  p_price_diffs IN PO_PDOI_TYPES.price_diffs_rec_type
);

PROCEDURE merge_attr_values
(
  p_processing_row_tbl IN DBMS_SQL.NUMBER_TABLE,
  p_sync_attr_id_tbl   IN PO_TBL_NUMBER,
  p_sync_draft_id_tbl  IN PO_TBL_NUMBER,
  p_attr_values        IN PO_PDOI_TYPES.attr_values_rec_type
);

PROCEDURE merge_attr_values_tlp
(
  p_processing_row_tbl   IN DBMS_SQL.NUMBER_TABLE,
  p_sync_attr_tlp_id_tbl IN PO_TBL_NUMBER,
  p_sync_draft_id_tbl    IN PO_TBL_NUMBER,
  p_attr_values_tlp      IN PO_PDOI_TYPES.attr_values_tlp_rec_type
);

END PO_PDOI_MOVE_TO_DRAFT_TABS_PVT;

 

/
