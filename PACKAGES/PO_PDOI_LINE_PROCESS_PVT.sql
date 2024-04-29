--------------------------------------------------------
--  DDL for Package PO_PDOI_LINE_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_LINE_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_LINE_PROCESS_PVT.pls 120.7.12010000.6 2014/08/21 05:08:29 linlilin ship $ */

PROCEDURE reject_dup_lines_for_spo;

PROCEDURE reject_invalid_action_lines;

PROCEDURE open_lines
(
  p_data_set_type      IN NUMBER,
  p_max_intf_line_id   IN NUMBER,
  x_lines_csr          OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type
);

PROCEDURE fetch_lines
(
  x_lines_csr   IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type,
  x_lines       OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE derive_lines
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE derive_lines_for_update
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE default_lines_for_update
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE default_lines
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE validate_lines
(
  p_action      IN VARCHAR2 DEFAULT 'CREATE',
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE match_lines
(
  p_data_set_type  IN NUMBER,  -- bug5129752
  x_lines          IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_create_lines   OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_update_lines   OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_match_lines    OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE check_line_locations
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE update_line_intf_tbl
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE uniqueness_check
(
  p_type                  IN NUMBER,
  p_group_num             IN NUMBER,
  x_processing_row_tbl    IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_lines                 IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_expire_line_id_tbl    OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_expire_line_index_tbl    OUT NOCOPY DBMS_SQL.NUMBER_TABLE --bug19046588
);

PROCEDURE split_lines
(
  p_group_num             IN NUMBER,
  p_lines                 IN PO_PDOI_TYPES.lines_rec_type,
  x_create_lines          IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_update_lines          IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_match_lines           IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) ;

PROCEDURE uniqueness_check
(
  x_lines                 IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE reject_after_grp_validate ( p_draft_id_tbl PO_TBL_NUMBER
                                    , p_line_id_tbl  PO_TBL_NUMBER);

PROCEDURE handle_err_tolerance
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

END PO_PDOI_LINE_PROCESS_PVT;

/
