--------------------------------------------------------
--  DDL for Package PO_DOC_STYLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOC_STYLE_PVT" AUTHID CURRENT_USER AS
  /* $Header: PO_DOC_STYLE_PVT.pls 120.2 2005/08/08 08:04:46 scolvenk noship $ */

  TYPE g_po_tbl_num IS TABLE OF NUMBER index by binary_integer;
  TYPE g_po_tbl_char30 IS TABLE OF VARCHAR2(30) index by binary_integer;

  PROCEDURE populate_gt_and_validate(p_api_version             IN NUMBER DEFAULT 1.0,
                                     p_init_msg_list           IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     x_return_status           OUT NOCOPY VARCHAR2,
                                     x_msg_count               OUT NOCOPY NUMBER,
                                     x_msg_data                OUT NOCOPY VARCHAR2,
                                     p_req_line_id_table       IN g_po_tbl_num,
                                     p_source_doc_id_table     IN g_po_tbl_num,
                                     p_line_type_id_table      IN g_po_tbl_num,
                                     p_destination_type_table  IN g_po_tbl_char30,
                                     p_purchase_basis_table    IN g_po_tbl_char30,
                                     p_po_header_id            IN NUMBER,
                                     p_po_style_id             IN NUMBER DEFAULT NULL,
                                     x_style_id                OUT NOCOPY NUMBER);

  PROCEDURE style_validate_req_lines(p_api_version    IN NUMBER DEFAULT 1.0,
                                     p_init_msg_list  IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     x_return_status  OUT NOCOPY VARCHAR2,
                                     x_msg_count      OUT NOCOPY NUMBER,
                                     x_msg_data       OUT NOCOPY VARCHAR2,
                                     p_session_gt_key IN NUMBER,
                                     p_po_header_id   IN NUMBER,
                                     p_po_style_id    IN NUMBER DEFAULT NULL,
                                     x_style_id       OUT  NOCOPY NUMBER);

  PROCEDURE style_validate_req_attrs(p_api_version      IN NUMBER DEFAULT 1.0,
                                     p_init_msg_list    IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2,
                                     p_doc_style_id     IN NUMBER,
                                     p_document_id      IN NUMBER,
                                     p_line_type_id     IN VARCHAR2,
                                     p_purchase_basis   IN VARCHAR2,
                                     p_destination_type IN VARCHAR2,
                                     p_source           IN VARCHAR2);

  FUNCTION is_progress_payments_enabled(p_style_id NUMBER)
  RETURN BOOLEAN;

  FUNCTION get_doc_style_id(p_doc_id IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_style_display_name(p_doc_id   IN NUMBER,
                                  p_language IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

END PO_DOC_STYLE_PVT;


 

/
