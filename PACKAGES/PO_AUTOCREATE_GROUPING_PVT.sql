--------------------------------------------------------
--  DDL for Package PO_AUTOCREATE_GROUPING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AUTOCREATE_GROUPING_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_AUTOCREATE_GROUPING_PVT.pls 120.0.12010000.2 2013/01/30 05:47:15 jemishra ship $ */

FUNCTION get_line_action_tbl(
  p_po_line_number_tbl IN PO_TBL_NUMBER,
  p_add_to_po_header_id IN NUMBER
) RETURN PO_TBL_VARCHAR5;

PROCEDURE check_po_line_numbers(
  p_style_id IN NUMBER,
  p_agreement_id IN NUMBER,
  p_supplier_id IN NUMBER,
  p_site_id IN NUMBER,
  p_req_line_id_tbl IN PO_TBL_NUMBER,
  p_po_line_number_tbl IN PO_TBL_NUMBER,
  p_add_to_po_header_id IN NUMBER,
  x_message_code_tbl OUT NOCOPY PO_TBL_VARCHAR30,
  x_token_name_tbl OUT NOCOPY PO_TBL_VARCHAR30,
  x_token_value_tbl OUT NOCOPY PO_TBL_VARCHAR2000
);

PROCEDURE lines_match(
  p_agreement_id IN NUMBER,
  p_supplier_id IN NUMBER,
  p_site_id IN NUMBER,
  p_req_line_id IN NUMBER,
  p_req_line_id_to_compare IN NUMBER,
  p_po_line_id_to_compare IN NUMBER,
  x_message_code OUT NOCOPY VARCHAR2,
  x_token_name OUT NOCOPY VARCHAR2,
  x_token_value OUT NOCOPY VARCHAR2
);

FUNCTION group_req_lines
(   p_req_line_id_tbl      IN  PO_TBL_NUMBER
,   p_req_line_num_tbl     IN  PO_TBL_NUMBER
,   p_po_line_num_tbl      IN  PO_TBL_NUMBER
,   p_add_to_po_header_id  IN  NUMBER
,   p_builder_agreement_id IN  NUMBER
,   p_builder_supplier_id  IN  NUMBER
,   p_builder_site_id      IN  NUMBER
,   p_builder_org_id       IN  NUMBER
,   p_start_index          IN  NUMBER
,   p_end_index            IN  NUMBER
,   p_grouping_method      IN  VARCHAR2
) RETURN PO_TBL_NUMBER;

-- Added as part of bug fix 16097884
PROCEDURE check_item_description(
  p_po_header_id IN NUMBER,
  p_po_line_num IN NUMBER,
  p_req_line_id IN NUMBER,
  x_same_item_desc OUT NOCOPY VARCHAR2
 );

END PO_AUTOCREATE_GROUPING_PVT;

/
