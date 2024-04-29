--------------------------------------------------------
--  DDL for Package PO_ATTRIBUTE_VALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ATTRIBUTE_VALUES_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_ATTRIBUTE_VALUES_PVT.pls 120.12.12010000.4 2014/03/24 05:10:00 linlilin ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_ATTRIBUTE_VALUES_PVT';

g_ATTR_VALUES_NULL_ID CONSTANT NUMBER := -2;

PROCEDURE handle_attributes
(
  p_interface_header_id IN NUMBER
, p_po_header_id IN NUMBER DEFAULT NULL
, p_language IN VARCHAR2 DEFAULT NULL
);

PROCEDURE transfer_intf_item_attribs
(
  p_interface_header_id IN NUMBER
);

PROCEDURE create_translations
(
  p_doc_type                 IN VARCHAR2, -- 'BLANKET', 'QUOTATION', 'REQ_TEMPLATE'
  p_default_lang_tlp_id      IN PO_ATTRIBUTE_VALUES_TLP.attribute_values_tlp_id%TYPE DEFAULT NULL,
  p_po_line_id               IN PO_LINES.po_line_id%TYPE DEFAULT NULL,
  p_default_lang_tlp_id_list IN PO_TBL_NUMBER DEFAULT NULL,
  p_po_line_id_list          IN PO_TBL_NUMBER DEFAULT NULL,
  p_req_template_name        IN PO_REQEXPRESS_LINES_ALL.express_name%TYPE DEFAULT NULL,
  p_req_template_line_num    IN PO_REQEXPRESS_LINES_ALL.sequence_num%TYPE DEFAULT NULL,
  p_org_id                   IN PO_LINES_ALL.org_id%TYPE DEFAULT NULL
);

PROCEDURE create_default_attributes
(
  p_doc_type              IN VARCHAR2, -- 'BLANKET', 'QUOTATION', 'REQ_TEMPLATE'
  p_po_line_id            IN PO_LINES.po_line_id%TYPE,
  p_req_template_name     IN PO_REQEXPRESS_LINES_ALL.express_name%TYPE,
  p_req_template_line_num IN PO_REQEXPRESS_LINES_ALL.sequence_num%TYPE,
  p_ip_category_id        IN PO_LINES_ALL.ip_category_id%TYPE,
  p_inventory_item_id     IN PO_LINES_ALL.item_id%TYPE,
  p_org_id                IN PO_LINES_ALL.org_id%TYPE,
  p_description           IN PO_ATTRIBUTE_VALUES_TLP.description%TYPE
);

PROCEDURE create_attributes_tlp_MI
(
  p_inventory_item_id     IN PO_LINES_ALL.item_id%TYPE,
  p_ip_category_id        IN PO_LINES_ALL.ip_category_id%TYPE,
  p_org_id                IN PO_LINES_ALL.org_id%TYPE,
  p_language              IN PO_ATTRIBUTE_VALUES_TLP.language%TYPE,
  p_description           IN PO_ATTRIBUTE_VALUES_TLP.description%TYPE,
  p_long_description      IN PO_ATTRIBUTE_VALUES_TLP.long_description%TYPE,
  p_organization_id       IN NUMBER,
  p_master_organization_id IN NUMBER
);


PROCEDURE create_default_attributes_MI
(
  p_ip_category_id        IN PO_LINES_ALL.ip_category_id%TYPE,
  p_inventory_item_id     IN PO_LINES_ALL.item_id%TYPE,
  p_org_id                IN PO_LINES_ALL.org_id%TYPE,
  p_description           IN PO_ATTRIBUTE_VALUES_TLP.description%TYPE,
  p_organization_id       IN NUMBER,
  p_master_organization_id IN NUMBER
);

PROCEDURE update_attributes_MI
(
  p_org_id                IN PO_LINES_ALL.org_id%TYPE,
  p_ip_category_id        IN PO_LINES_ALL.ip_category_id%TYPE,
  p_inventory_item_id     IN PO_ATTRIBUTE_VALUES_TLP.inventory_item_id%TYPE,
  p_language              IN PO_ATTRIBUTE_VALUES_TLP.language%TYPE,
  p_item_description      IN PO_ATTRIBUTE_VALUES_TLP.description%TYPE,
  p_long_description      IN PO_ATTRIBUTE_VALUES_TLP.long_description%TYPE,
  p_organization_id       IN NUMBER,
  p_master_organization_id IN NUMBER
);


PROCEDURE gen_draft_line_translations
(
  p_draft_id IN NUMBER
, p_doc_type IN VARCHAR2
);

PROCEDURE update_attributes
(
  p_doc_type              IN VARCHAR2, -- 'BLANKET', 'QUOTATION', 'REQ_TEMPLATE'
  p_po_line_id            IN PO_LINES.po_line_id%TYPE,
  p_req_template_name     IN PO_REQEXPRESS_LINES_ALL.express_name%TYPE,
  p_req_template_line_num IN PO_REQEXPRESS_LINES_ALL.sequence_num%TYPE,
  p_org_id                IN PO_LINES_ALL.org_id%TYPE,
  p_ip_category_id        IN PO_LINES_ALL.ip_category_id%TYPE,
  p_language              IN PO_ATTRIBUTE_VALUES_TLP.language%TYPE,
  p_item_description      IN PO_ATTRIBUTE_VALUES_TLP.description%TYPE,
  p_inventory_item_id     IN PO_ATTRIBUTE_VALUES_TLP.inventory_item_id%TYPE --bug 18381792
);

PROCEDURE copy_attributes
(
  p_orig_po_line_id IN PO_LINES.po_line_id%TYPE
, p_new_po_line_id  IN PO_LINES.po_line_id%TYPE
);

PROCEDURE get_ip_category_id
(
  p_po_category_id IN NUMBER
, x_ip_category_id OUT NOCOPY NUMBER
);

PROCEDURE delete_attributes
(
  p_doc_type              IN VARCHAR2, -- 'BLANKET', 'QUOTATION', 'REQ_TEMPLATE'
  p_po_line_id            IN PO_LINES.po_line_id%TYPE DEFAULT NULL,
  p_req_template_name     IN PO_REQEXPRESS_LINES_ALL.express_name%TYPE DEFAULT NULL,
  p_req_template_line_num IN PO_REQEXPRESS_LINES_ALL.sequence_num%TYPE DEFAULT NULL,
  p_org_id                IN PO_LINES_ALL.org_id%TYPE DEFAULT NULL
);

PROCEDURE delete_attributes_for_header
(
  p_doc_type     IN VARCHAR2, -- 'BLANKET', 'QUOTATION'
  p_po_header_id IN PO_LINES.po_header_id%TYPE
);

--Bug 7039409: Added new procedure
PROCEDURE get_item_attributes_values
(
  p_inventory_item_id       IN         PO_LINES_ALL.item_id%TYPE,
  p_manufacturer_part_num   OUT NOCOPY PO_ATTRIBUTE_VALUES.manufacturer_part_num%TYPE,
  p_manufacturer            OUT NOCOPY PO_ATTRIBUTE_VALUES_TLP.manufacturer%TYPE,
  p_lead_time               OUT NOCOPY PO_ATTRIBUTE_VALUES.lead_time%TYPE
);

--Bug 7387487: Added new procedure
PROCEDURE get_item_attributes_values
(
  p_inventory_item_id       IN         PO_LINES_ALL.item_id%TYPE,
  p_manufacturer_part_num   OUT NOCOPY PO_ATTRIBUTE_VALUES.manufacturer_part_num%TYPE,
  p_manufacturer            OUT NOCOPY PO_ATTRIBUTE_VALUES_TLP.manufacturer%TYPE,
  p_lead_time               OUT NOCOPY PO_ATTRIBUTE_VALUES.lead_time%TYPE,
  p_manufacturer_id         OUT NOCOPY po_requisition_lines_All.MANUFACTURER_ID%TYPE
)  ;


--Bug 7039409: Added new procedure
PROCEDURE get_item_attributes_tlp_values
(
  p_inventory_item_id       IN         PO_LINES_ALL.item_id%TYPE,
  p_lang                    IN         PO_ATTRIBUTE_VALUES_TLP.language%TYPE,
  p_long_description        OUT NOCOPY PO_ATTRIBUTE_VALUES_TLP.long_description%TYPE
);



FUNCTION get_base_lang
RETURN VARCHAR2;

END;

/
