--------------------------------------------------------
--  DDL for Package PO_PDOI_HEADER_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_HEADER_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_HEADER_PROCESS_PVT.pls 120.1 2005/08/09 16:34 jinwang noship $ */

PROCEDURE open_headers
(
  p_max_intf_header_id   IN NUMBER,
  x_headers_csr   OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type
);

PROCEDURE fetch_headers
(
  x_headers_csr   IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type,
  x_headers       OUT NOCOPY PO_PDOI_TYPES.headers_rec_type
);

PROCEDURE derive_headers
(
  x_headers       IN OUT NOCOPY PO_PDOI_TYPES.headers_rec_type
);


PROCEDURE default_headers
(
  x_headers       IN OUT NOCOPY PO_PDOI_TYPES.headers_rec_type
);

PROCEDURE validate_headers
(
  x_headers       IN OUT NOCOPY PO_PDOI_TYPES.headers_rec_type
);

-- shared with line location derivation logic
PROCEDURE derive_location_id
(
  p_key                IN po_session_gt.key%TYPE,
  p_index_tbl          IN DBMS_SQL.NUMBER_TABLE,
  p_location_type      IN VARCHAR2,
  p_location_tbl       IN PO_TBL_VARCHAR100,
  x_location_id_tbl    IN OUT NOCOPY PO_TBL_NUMBER
);

-- shared with line location derivation logic
PROCEDURE derive_terms_id
(
  p_key                IN po_session_gt.key%TYPE,
  p_index_tbl          IN DBMS_SQL.NUMBER_TABLE,
  p_payment_terms_tbl  IN PO_TBL_VARCHAR100,
  x_terms_id_tbl       IN OUT NOCOPY PO_TBL_NUMBER
);

-- shared with pre-processing
PROCEDURE derive_vendor_id
(
  p_key              IN po_session_gt.key%TYPE,
  p_index_tbl        IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_name_tbl  IN PO_TBL_VARCHAR2000,
  p_vendor_num_tbl   IN PO_TBL_VARCHAR30,
  x_vendor_id_tbl    IN OUT NOCOPY PO_TBL_NUMBER
);
END PO_PDOI_HEADER_PROCESS_PVT;

 

/
