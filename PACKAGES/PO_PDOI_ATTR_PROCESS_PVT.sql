--------------------------------------------------------
--  DDL for Package PO_PDOI_ATTR_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_ATTR_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_ATTR_PROCESS_PVT.pls 120.1 2005/08/09 16:22 jinwang noship $ */

PROCEDURE open_attr_values
(
  p_max_intf_attr_values_id   IN NUMBER,
  x_attr_values_csr           OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type
);

PROCEDURE fetch_attr_values
(
  x_attr_values_csr          IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type,
  x_attr_values              OUT NOCOPY PO_PDOI_TYPES.attr_values_rec_type
);

PROCEDURE check_attr_actions
(
  x_processing_row_tbl       IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_attr_values              IN OUT NOCOPY PO_PDOI_TYPES.attr_values_rec_type,
  x_merge_row_tbl            OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_sync_attr_id_tbl         OUT NOCOPY PO_TBL_NUMBER,
  x_sync_draft_id_tbl        OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE open_attr_values_tlp
(
  p_max_intf_attr_values_tlp_id   IN NUMBER,
  x_attr_values_tlp_csr           IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type
);

PROCEDURE fetch_attr_values_tlp
(
  x_attr_values_tlp_csr          IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type,
  x_attr_values_tlp              IN OUT NOCOPY PO_PDOI_TYPES.attr_values_tlp_rec_type
);

PROCEDURE check_attr_tlp_actions
(
  x_processing_row_tbl       IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_attr_values_tlp          IN OUT NOCOPY PO_PDOI_TYPES.attr_values_tlp_rec_type,
  x_merge_row_tbl            OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_sync_attr_tlp_id_tbl     OUT NOCOPY PO_TBL_NUMBER,
  x_sync_draft_id_tbl        OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE add_default_attrs;

END PO_PDOI_ATTR_PROCESS_PVT;

 

/
