--------------------------------------------------------
--  DDL for Package PO_PDOI_PRICE_DIFF_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_PRICE_DIFF_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_PRICE_DIFF_PROCESS_PVT.pls 120.3.12010000.2 2013/10/03 09:27:11 inagdeo ship $ */


PROCEDURE open_price_diffs
(
  p_max_intf_price_diff_id   IN NUMBER,
  x_price_diffs_csr          OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type
);

PROCEDURE fetch_price_diffs
(
  x_price_diffs_csr   IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type,
  x_price_diffs       OUT NOCOPY PO_PDOI_TYPES.price_diffs_rec_type
);

PROCEDURE default_price_diffs
(
  x_price_diffs       IN OUT NOCOPY PO_PDOI_TYPES.price_diffs_rec_type
);

PROCEDURE validate_price_diffs
(
  x_price_diffs       IN OUT NOCOPY PO_PDOI_TYPES.price_diffs_rec_type
);

-- PDOI Enhancement Bug#17063664
PROCEDURE setup_price_diffs_intf;

END PO_PDOI_PRICE_DIFF_PROCESS_PVT;

/
