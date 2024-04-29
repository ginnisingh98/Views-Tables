--------------------------------------------------------
--  DDL for Package PO_DOC_STYLE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOC_STYLE_GRP" AUTHID CURRENT_USER AS
/* $Header: PO_DOC_STYLE_GRP.pls 120.2 2006/03/01 01:03:01 scolvenk noship $ */

FUNCTION is_style_alias_conflict (
  p_name IN VARCHAR2
  , p_style_id IN NUMBER default NULL)
  RETURN VARCHAR2;

FUNCTION is_style_name_conflict (
  p_name IN VARCHAR2
  , p_style_id IN NUMBER default NULL)
  RETURN VARCHAR2;

FUNCTION is_standard_doc_style(p_style_id IN NUMBER)
  RETURN VARCHAR2;

FUNCTION get_standard_doc_style
  RETURN NUMBER;

PROCEDURE get_document_style_settings(
  p_api_version                 IN NUMBER
  , p_style_id                    IN NUMBER
  , x_style_name               OUT NOCOPY VARCHAR2
  , x_style_description        OUT NOCOPY VARCHAR2
  , x_style_type               OUT NOCOPY VARCHAR2
  , x_status                   OUT NOCOPY VARCHAR2
  , x_advances_flag            OUT NOCOPY VARCHAR2
  , x_retainage_flag           OUT NOCOPY VARCHAR2
  , x_price_breaks_flag        OUT NOCOPY VARCHAR2
  , x_price_differentials_flag OUT NOCOPY VARCHAR2
  , x_progress_payment_flag    OUT NOCOPY VARCHAR2
  , x_contract_financing_flag  OUT NOCOPY VARCHAR2
  , x_line_type_allowed        OUT NOCOPY VARCHAR2);

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

END PO_DOC_STYLE_GRP;

 

/
