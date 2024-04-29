--------------------------------------------------------
--  DDL for Package INL_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_TAX_PVT" AUTHID CURRENT_USER AS
/* $Header: INLVTAXS.pls 120.6.12010000.9 2009/08/17 19:10:20 aicosta ship $ */

    G_ENTITY_CODE   zx_evnt_cls_mappings.entity_code%TYPE;
    G_MODULE_NAME   CONSTANT VARCHAR2(200)  := 'INL.PLSQL.INL_TAX_PVT.';
    G_PKG_NAME      CONSTANT VARCHAR2(30):='INL_TAX_PVT';
    CURSOR Shipment_Lines(p_ship_header_id number) IS
    SELECT bill_from_party_id
    ,bill_from_party_site_id
    ,bill_to_location_id
    ,bill_to_organization_id
    ,currency_code
    ,currency_conversion_date
    ,currency_conversion_rate
    ,currency_conversion_type
    ,intended_use
    ,inventory_item_id
    ,line_qty
    ,party_id
    ,party_site_id
    ,poa_party_id
    ,poa_party_site_id
    ,poo_location_id
    ,poo_organization_id
    ,product_category
    ,product_fiscal_class
    ,product_type
    ,ship_from_party_id
    ,ship_from_party_site_id
    ,ship_header_id
    ,ship_line_id
    ,ship_line_num
    ,ship_to_location_id
    ,ship_to_organization_id
    ,source
    ,src_id
    ,src_type_code
    ,tax_already_calculated_flag
    ,tax_classification_code
    ,trx_business_category
    ,unit_price
    ,uom_code
    ,user_def_fiscal_class
    FROM inl_ebtax_lines_v
    WHERE ship_header_id = p_ship_header_id
    AND adjustment_num = 0;
    TYPE ship_Lines_Tab_Type IS TABLE OF Shipment_Lines%ROWTYPE;
    l_ship_line_list              ship_Lines_Tab_Type;

    CURSOR Shipment_Header(p_ship_header_id number)  IS
    SELECT -- all fields could be used by hook
         ship_header_id
        ,ship_num
        ,ship_date
        ,ship_type_id
        ,ship_status_code
        ,pending_matching_flag
        ,legal_entity_id
        ,organization_id
        ,location_id
        ,org_id
        ,taxation_country
        ,document_sub_type
        ,ship_header_int_id
        ,interface_source_code
        ,interface_source_table
        ,interface_source_line_id
        ,adjustment_num
        ,created_by
        ,creation_date
        ,last_updated_by
        ,last_update_date
        ,last_update_login
        ,program_id
        ,program_update_date
        ,program_application_id
        ,request_id
        ,attribute_category
        ,attribute1
        ,attribute2
        ,attribute3
        ,attribute4
        ,attribute5
        ,attribute6
        ,attribute7
        ,attribute8
        ,attribute9
        ,attribute10
        ,attribute11
        ,attribute12
        ,attribute13
        ,attribute14
        ,attribute15
        ,rcv_enabled_flag
    FROM inl_ship_headers
    WHERE ship_header_id = p_ship_header_id;
    l_ship_header_rec  Shipment_Header%ROWTYPE;

-- Record to keep Tax Line info.
TYPE tax_ln_rec IS RECORD(
    tax_code                   VARCHAR2(30),
    ship_header_id             NUMBER,
    source_parent_table_name   VARCHAR2(30),
    source_parent_table_id     NUMBER,
    tax_amt                    NUMBER,
    nrec_tax_amt               NUMBER,
    currency_code              VARCHAR2(15),
    currency_conversion_type   VARCHAR2(30),
    currency_conversion_date   DATE,
    currency_conversion_rate   NUMBER,
    tax_amt_included_flag      VARCHAR2(1),
    -- Association attributes
    to_parent_table_name       VARCHAR2(30),
    to_parent_table_id         NUMBER
);

TYPE tax_ln_tbl IS TABLE OF tax_ln_rec INDEX BY BINARY_INTEGER;

CURSOR charge_ln (p_ship_header_id number) IS
SELECT
    assoc.to_parent_table_name,
    assoc.to_parent_table_id,
    assoc.allocation_basis,
    assoc.allocation_uom_code,
    cl.*
FROM inl_adj_charge_lines_v cl,
     inl_associations assoc
WHERE assoc.from_parent_table_name = 'INL_CHARGE_LINES'
AND assoc.from_parent_table_id   = cl.charge_line_id
AND assoc.ship_header_id = p_ship_header_id
order by assoc.to_parent_table_name,
    assoc.to_parent_table_id,
    cl.charge_line_id
;

TYPE charge_ln_tbl_tp IS TABLE OF charge_ln%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE sh_group_ln_tbl_tp IS TABLE OF inl_ship_line_groups%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE ship_ln_tbl_tp IS TABLE OF inl_adj_ship_lines_v%ROWTYPE INDEX BY BINARY_INTEGER;

PROCEDURE Generate_Taxes(
    p_api_version    IN NUMBER,
    p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE,
    p_commit         IN VARCHAR2 := FND_API.G_FALSE,
    p_ship_header_id IN NUMBER,
    p_source         IN VARCHAR2 := 'PO',
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2
);

PROCEDURE Calculate_Tax(
    p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN VARCHAR2 := FND_API.G_FALSE,
    p_ship_header_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
);

PROCEDURE Get_DefaultTaxDetAttribs(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_application_id          IN NUMBER,
    p_entity_code             IN VARCHAR2,
    p_event_class_code        IN VARCHAR2,
    p_org_id                  IN VARCHAR2,
    p_item_id                 IN NUMBER,
    p_country_code            IN VARCHAR2,
    p_effective_date          IN DATE,
    p_source_type_code        IN VARCHAR2,
    p_po_line_location_id     IN NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    x_trx_biz_category        OUT NOCOPY VARCHAR2,
    x_intended_use            OUT NOCOPY VARCHAR2,
    x_prod_category           OUT NOCOPY VARCHAR2,
    x_prod_fisc_class_code    OUT NOCOPY VARCHAR2,
    x_product_type            OUT NOCOPY VARCHAR2
);

END INL_TAX_PVT;

/
