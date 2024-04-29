--------------------------------------------------------
--  DDL for Package PO_PDOI_PRICE_TOLERANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_PRICE_TOLERANCE_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_PRICE_TOLERANCE_PVT.pls 120.1 2005/08/20 02:32 jinwang noship $ */

PROCEDURE start_price_tolerance_wf
(
  p_intf_header_id    IN  NUMBER,
  p_po_header_id      IN  NUMBER,
  p_document_num      IN  VARCHAR2,
  p_batch_id          IN  NUMBER,
  p_document_type     IN  VARCHAR2,
  p_document_subtype  IN  VARCHAR2,
  p_commit_interval   IN  NUMBER,
  p_any_line_updated  IN  VARCHAR2,
  p_buyer_id          IN  NUMBER,
  p_agent_id          IN  NUMBER,
  p_vendor_id         IN  NUMBER,
  p_vendor_name       IN  VARCHAR2
);

PROCEDURE get_price_tolerance
(
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_po_header_id_tbl           IN PO_TBL_NUMBER,
  p_item_id_tbl                IN PO_TBL_NUMBER,
  p_category_id_tbl            IN PO_TBL_NUMBER,
  p_vendor_id_tbl              IN PO_TBL_NUMBER,
  x_price_update_tolerance_tbl OUT NOCOPY PO_TBL_NUMBER
);

FUNCTION exceed_tolerance_check
(
  p_price_tolerance IN NUMBER,
  p_old_price       IN NUMBER,
  p_new_price       IN NUMBER
) RETURN VARCHAR2;

END PO_PDOI_PRICE_TOLERANCE_PVT;

 

/
