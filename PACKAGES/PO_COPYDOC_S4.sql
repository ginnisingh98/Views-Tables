--------------------------------------------------------
--  DDL for Package PO_COPYDOC_S4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COPYDOC_S4" AUTHID CURRENT_USER AS
/* $Header: POXCPO4S.pls 120.1 2005/09/13 17:56:53 spangulu noship $*/

--< Shared Proc FPJ Start >
PROCEDURE validate_shipment
(
    p_action_code           IN     VARCHAR2,
    p_to_doc_subtype        IN     VARCHAR2,
    p_orig_line_location_id IN     NUMBER,
    p_po_header_id          IN     NUMBER,
    p_po_line_id            IN     NUMBER,
    p_item_category_id      IN     NUMBER,      --< Shared Proc FPJ >
    p_inv_org_id            IN     NUMBER,      -- Bug 2761415
    p_copy_price            IN     BOOLEAN,
    p_online_report_id      IN     NUMBER,
    p_line_num              IN     NUMBER,
    p_item_id               IN     NUMBER, --Bug 3433867
    x_po_shipment_record    IN OUT NOCOPY PO_LINE_LOCATIONS%ROWTYPE,
    x_sequence              IN OUT NOCOPY NUMBER,
    x_return_code           OUT    NOCOPY NUMBER,
    p_is_complex_work_po    IN     BOOLEAN      -- <Complex Work R12>
);
--< Shared Proc FPJ End >

END po_copydoc_s4;

 

/
