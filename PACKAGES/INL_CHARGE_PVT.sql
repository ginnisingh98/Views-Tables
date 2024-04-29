--------------------------------------------------------
--  DDL for Package INL_CHARGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_CHARGE_PVT" AUTHID CURRENT_USER AS
/* $Header: INLVCHGS.pls 120.1.12010000.14 2011/10/13 14:58:21 ebarbosa ship $ */

G_MODULE_NAME  CONSTANT VARCHAR2(200) := 'INL.PLSQL.INL_CHARGE_PVT.';
G_PKG_NAME     CONSTANT VARCHAR2(30)  := 'INL_CHARGE_PVT';

L_FND_FALSE CONSTANT VARCHAR2(1)   := fnd_api.g_false; --Bug#9660056

-- Record to keep Charge Line info.
TYPE charge_ln_rec IS RECORD(
    charge_line_type_id       NUMBER,
    landed_cost_flag          VARCHAR2(1),
    update_allowed            VARCHAR2(1),
    source_code               VARCHAR2(25),
    charge_amt                NUMBER,
    currency_code             VARCHAR2(15),
    currency_conversion_type  VARCHAR2(30),
    currency_conversion_date  DATE,
    currency_conversion_rate  NUMBER,
    party_id                  NUMBER,
    party_site_id             NUMBER,
    trx_business_category     VARCHAR2(240),
    intended_use              VARCHAR2(30),
    product_fiscal_class      VARCHAR2(240),
    product_category          VARCHAR2(240),
    product_type              VARCHAR2(240),
    user_def_fiscal_class     VARCHAR2(240),
    tax_classification_code   VARCHAR2(30),
    assessable_value          NUMBER,
    ship_from_party_id        NUMBER,
    ship_from_party_site_id   NUMBER,
    ship_to_organization_id   NUMBER,
    ship_to_location_id       NUMBER,
    bill_from_party_id        NUMBER,
    bill_from_party_site_id   NUMBER,
    bill_to_organization_id   NUMBER,
    bill_to_location_id       NUMBER,
    poa_party_id              NUMBER,
    poa_party_site_id         NUMBER,
    poo_organization_id       NUMBER,
    poo_location_id           NUMBER,
    -- Association attributes
    to_parent_table_name      VARCHAR2(30),
    to_parent_table_id        NUMBER
);

TYPE charge_ln_tbl IS TABLE OF charge_ln_rec INDEX BY BINARY_INTEGER;

-- Record to keep Shipment Line Group info. (HDR Global Structure)
TYPE ship_ln_group_rec IS     RECORD(
    ship_line_group_id        NUMBER,
    org_id                    NUMBER,
    p_order_header_id         NUMBER,
    supplier_id               NUMBER,
    supplier_site_id          NUMBER,
    creation_date             DATE,
    order_type                VARCHAR2(20), -- REQUISITION/PO
    ship_to_location_id       NUMBER,
    ship_to_org_id            NUMBER,
    shipment_header_id        NUMBER,
    hazard_class              VARCHAR2(4),
    hazard_code               VARCHAR2(1),
    shipped_date              DATE,
    shipment_num              VARCHAR2(30),
    carrier_method            VARCHAR2(2),
    packaging_code            VARCHAR2(5),
    freight_code              VARCHAR2(25),
    freight_terms             VARCHAR2(25),
    currency_code             VARCHAR2(15),
    rate                      VARCHAR2(30),
    rate_type                 VARCHAR2(30),
    source_org_id             NUMBER,
    expected_receipt_date     DATE,
    request_type              VARCHAR2(2),
    pricing_event             VARCHAR2(20),
    qp_curr_conv_type         VARCHAR2(20),
    po_header_id              NUMBER  -- Bug#13092165
);

-- Record to keep Shipment Line info. (LINE Global Structure)
TYPE ship_ln_rec IS RECORD(
    order_line_id             NUMBER,
    agreement_type            VARCHAR2(25),
    agreement_id              NUMBER,
    agreement_line_id         NUMBER,
    supplier_id               NUMBER,
    supplier_site_id          NUMBER,
    ship_to_location_id       NUMBER,
    ship_to_org_id            NUMBER,
    supplier_item_num         VARCHAR2(25),
    item_revision             VARCHAR2(3),
    item_id                   NUMBER,
    category_id               NUMBER,
    rate                      NUMBER,
    rate_type                 VARCHAR2(30),
    currency_code             VARCHAR2(15),
    need_by_date              DATE,
    shipment_line_id          NUMBER,
    primary_unit_of_measure   VARCHAR2(25),
    to_organization_id        NUMBER,
    unit_of_measure           VARCHAR2(25),
    source_document_code      VARCHAR2(25),
    unit_price                NUMBER,
    quantity                  NUMBER,
    primary_quantity          NUMBER    --BUG#8928845
);

TYPE ship_ln_tbl IS TABLE OF ship_ln_rec INDEX BY BINARY_INTEGER;

-- Record to keep the freight charge info. per line
TYPE freight_charge_rec IS    RECORD(
    charge_type_code          VARCHAR2(30),
    freight_charge            NUMBER,
    pricing_status_code       VARCHAR2(30),
    pricing_status_text       VARCHAR2(2000),
    modifier_level_code       VARCHAR2(30),
    override_flag             VARCHAR2(1),
    operand_calculation_code  VARCHAR2(30) --Bug#8928845
);


TYPE freight_charge_tbl IS TABLE OF freight_charge_rec INDEX BY BINARY_INTEGER;

--Record to keep the price/charge info. per line
TYPE qp_price_result_rec IS   RECORD(
    line_index                NUMBER,
    line_id                   NUMBER,
    base_unit_price           NUMBER,
    adjusted_price            NUMBER,
    freight_charge_rec_tbl    freight_charge_tbl,
    pricing_status_code       VARCHAR2(30),
    pricing_status_text       VARCHAR2(2000)
);

TYPE qp_price_result_tbl IS TABLE OF qp_price_result_rec INDEX BY BINARY_INTEGER;

TYPE ship_ln_group_tbl_tp IS TABLE OF inl_ship_line_groups%ROWTYPE INDEX BY BINARY_INTEGER;

TYPE ship_ln_tbl_tp     IS TABLE OF inl_adj_ship_lines_v%ROWTYPE INDEX BY BINARY_INTEGER;

--
PROCEDURE Generate_Charges(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := L_FND_FALSE,
    p_commit              IN  VARCHAR2 := L_FND_FALSE,
    p_ship_header_id      IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
);

END INL_CHARGE_PVT;

/
