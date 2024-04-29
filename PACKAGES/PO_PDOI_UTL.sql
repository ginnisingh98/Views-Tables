--------------------------------------------------------
--  DDL for Package PO_PDOI_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_UTL" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_UTL.pls 120.4 2006/09/15 22:26:24 jinwang noship $ */

-- define pls integer table type (used by FORALL statement)
TYPE pls_integer_tbl_type IS TABLE OF PLS_INTEGER;

PROCEDURE remove_session_gt_records
( p_key IN NUMBER
);

PROCEDURE commit_work;

FUNCTION get_next_batch_id RETURN NUMBER;

PROCEDURE reject_headers_intf
( p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_TBL_NUMBER,
  p_cascade IN VARCHAR2
);

PROCEDURE reject_lines_intf
( p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_TBL_NUMBER,
  p_cascade IN VARCHAR2
);

PROCEDURE reject_line_locations_intf
( p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_TBL_NUMBER,
  p_cascade IN VARCHAR2
);

PROCEDURE reject_distributions_intf
( p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_TBL_NUMBER
);

PROCEDURE reject_price_diff_intf
( p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_TBL_NUMBER
);

PROCEDURE reject_attr_values_intf
( p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_TBL_NUMBER
);

PROCEDURE reject_attr_values_tlp_intf
( p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_TBL_NUMBER
);

PROCEDURE post_reject_document
( p_interface_header_id IN NUMBER,
  p_po_header_id IN NUMBER,
  p_draft_id IN NUMBER,
  p_remove_draft IN VARCHAR2   -- bug5129752
);

PROCEDURE generate_ordered_num_list
( p_size IN NUMBER,
  x_num_list OUT NOCOPY DBMS_SQL.NUMBER_TABLE
);

PROCEDURE get_processing_doctype_info
( x_doc_type    OUT NOCOPY VARCHAR2,
  x_doc_subtype OUT NOCOPY VARCHAR2
);

FUNCTION is_old_request_complete
( p_old_request_id IN NUMBER
) RETURN VARCHAR2;

PROCEDURE reject_unprocessed_intf
(
  p_intf_header_id IN NUMBER
);

END PO_PDOI_UTL;

 

/
