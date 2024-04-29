--------------------------------------------------------
--  DDL for Package PO_PDOI_DIST_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_DIST_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_DIST_PROCESS_PVT.pls 120.3.12010000.2 2013/10/03 09:22:21 inagdeo ship $ */

PROCEDURE open_dists
(
  p_max_intf_dist_id   IN NUMBER,
  x_dists_csr          OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type
);

PROCEDURE fetch_dists
(
  x_dists_csr IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type,
  x_dists     OUT NOCOPY PO_PDOI_TYPES.distributions_rec_type
);

PROCEDURE derive_dists
(
  x_dists       IN OUT NOCOPY PO_PDOI_TYPES.distributions_rec_type
);

PROCEDURE default_dists
(
  x_dists     IN OUT NOCOPY PO_PDOI_TYPES.distributions_rec_type
);

PROCEDURE validate_dists
(
  x_dists     IN OUT NOCOPY PO_PDOI_TYPES.distributions_rec_type
);


PROCEDURE derive_account_id
( p_account_number IN VARCHAR2,
  p_chart_of_accounts_id IN NUMBER,
  p_account_segment1 IN VARCHAR2, p_account_segment2 IN VARCHAR2,
  p_account_segment3 IN VARCHAR2, p_account_segment4 IN VARCHAR2,
  p_account_segment5 IN VARCHAR2, p_account_segment6 IN VARCHAR2,
  p_account_segment7 IN VARCHAR2, p_account_segment8 IN VARCHAR2,
  p_account_segment9 IN VARCHAR2, p_account_segment10 IN VARCHAR2,
  p_account_segment11 IN VARCHAR2, p_account_segment12 IN VARCHAR2,
  p_account_segment13 IN VARCHAR2, p_account_segment14 IN VARCHAR2,
  p_account_segment15 IN VARCHAR2, p_account_segment16 IN VARCHAR2,
  p_account_segment17 IN VARCHAR2, p_account_segment18 IN VARCHAR2,
  p_account_segment19 IN VARCHAR2, p_account_segment20 IN VARCHAR2,
  p_account_segment21 IN VARCHAR2, p_account_segment22 IN VARCHAR2,
  p_account_segment23 IN VARCHAR2, p_account_segment24 IN VARCHAR2,
  p_account_segment25 IN VARCHAR2, p_account_segment26 IN VARCHAR2,
  p_account_segment27 IN VARCHAR2, p_account_segment28 IN VARCHAR2,
  p_account_segment29 IN VARCHAR2, p_account_segment30 IN VARCHAR2,
  x_account_id       OUT NOCOPY NUMBER
);

-- <<PDOI Enhancement Bug#17063664 Start>>

PROCEDURE setup_dists_intf;

PROCEDURE process_currency_conversions
(
  x_dists     IN OUT NOCOPY PO_PDOI_TYPES.distributions_rec_type
);

PROCEDURE  process_qty_amt_rollups
(
    p_line_loc_id_tbl       IN PO_TBL_NUMBER,
    p_draft_id_tbl          IN PO_TBL_NUMBER
);

-- <<PDOI Enhancement Bug#17063664 End>>

END PO_PDOI_DIST_PROCESS_PVT;

/
