--------------------------------------------------------
--  DDL for Package PO_INTERFACE_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_INTERFACE_S2" AUTHID CURRENT_USER AS
/* $Header: POXBWP2S.pls 115.7 2003/11/15 00:32:43 anhuang ship $*/

PROCEDURE get_source_info(x_requisition_line_id IN number,
                         x_vendor_id IN number,
                         x_currency  IN varchar2,
                         x_source_header_id IN OUT NOCOPY number,
                         x_source_line_id OUT NOCOPY number,
                         p_vendor_site_id IN NUMBER,                -- <GC FPJ>
                         p_purchasing_org_id IN NUMBER,             -- <GC FPJ>
                         x_src_document_type OUT NOCOPY VARCHAR2);  -- <GC FPJ>

PROCEDURE get_doc_header_info (p_add_to_doc_id                    IN  NUMBER,
                               p_add_to_type                      OUT NOCOPY VARCHAR2,
                               p_add_to_vendor_id                 OUT NOCOPY NUMBER,
                               p_add_to_vendor_site_id            OUT NOCOPY NUMBER,
                               p_add_to_currency_code             OUT NOCOPY VARCHAR2,
                               p_add_to_terms_id                  OUT NOCOPY NUMBER,
                               p_add_to_ship_via_lookup_code      OUT NOCOPY VARCHAR2,
                               p_add_to_fob_lookup_code           OUT NOCOPY VARCHAR2,
                               p_add_to_freight_lookup_code       OUT NOCOPY VARCHAR2,
                               x_add_to_shipping_control          OUT NOCOPY VARCHAR2    -- <INBOUND LOGISTICS FPJ>
);

FUNCTION is_req_in_pool ( p_req_line_id IN NUMBER )           -- <SERVICES FPJ>
  RETURN BOOLEAN;

PROCEDURE update_terms(p_new_po_id IN number) ;


END po_interface_s2;

 

/
