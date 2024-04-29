--------------------------------------------------------
--  DDL for Package INL_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: INLGITGS.pls 120.0.12010000.41 2014/01/02 14:19:41 anandpra noship $ */

g_module_name VARCHAR2(100) := 'INL_INTEGRATION_GRP';
g_pkg_name CONSTANT VARCHAR2(30) := 'INL_INTEGRATION_GRP';

g_records_processed NUMBER := 0     ; --Bug#9279355
g_lines_processed   VARCHAR2(2000)  ; --Bug#9279355
g_records_inserted  NUMBER := 0     ; --Bug#9279355
g_lines_inserted    VARCHAR2(2000)  ; --Bug#9279355

TYPE lci_rec IS RECORD  (
    shipment_header_id            NUMBER,
    transaction_type              VARCHAR2(25),
    processing_status_code        VARCHAR2(25),
    interface_source_code         VARCHAR2(25),
    hdr_interface_source_table    VARCHAR2(30),
    hdr_interface_source_line_id  NUMBER,
    validation_flag               VARCHAR2(1),
    receipt_num                   VARCHAR2(500),
    ship_num                      VARCHAR2(25),  --Bug#8971617
    ship_date                     DATE,
    ship_type_id                  NUMBER,
    ship_type_code                VARCHAR2(15),
    --legal_entity_id               NUMBER,
    --legal_entity_name             VARCHAR2(50),
    organization_id               NUMBER,
    organization_code             VARCHAR2(3),
    location_id                   NUMBER,
    location_code                 VARCHAR2(60),
    --org_id                        NUMBER,
    taxation_country              VARCHAR2(30),
    document_sub_type             VARCHAR2(150),
    ship_header_id                NUMBER,
    last_task_code                VARCHAR2(25),
    ship_line_group_reference     VARCHAR2(30),
    party_id                      NUMBER,
    party_number                  VARCHAR2(30),
    party_site_id                 NUMBER,
    party_site_number             VARCHAR2(30),
    source_organization_id        NUMBER,
    source_organization_code      VARCHAR2(3),
    ship_line_num                 NUMBER,
    ship_line_type_id             NUMBER,
    ship_line_type_code           VARCHAR2(15),
    ship_line_src_type_code       VARCHAR2(30),
    ship_line_source_id           NUMBER,
    currency_code                 VARCHAR2(15),
    currency_conversion_type      VARCHAR2(30),
    currency_conversion_date      DATE,
    currency_conversion_rate      NUMBER,
    inventory_item_id             NUMBER,
    txn_qty                       NUMBER,
    txn_uom_code                  VARCHAR2(3),
    txn_unit_price                NUMBER,
    primary_qty                   NUMBER,
    primary_uom_code              VARCHAR2(3),
    primary_unit_price            NUMBER,
    secondary_qty                 NUMBER,
    secondary_uom_code            VARCHAR2(3),
    secondary_unit_price          NUMBER,
    landed_cost_flag              VARCHAR2(1),
    allocation_enabled_flag       VARCHAR2(1),
    trx_business_category         VARCHAR2(240),
    intended_use                  VARCHAR2(30),
    product_fiscal_class          VARCHAR2(240),
    product_category              VARCHAR2(240),
    product_type                  VARCHAR2(240),
    user_def_fiscal_class         VARCHAR2(240),
    tax_classification_code       VARCHAR2(30),
    assessable_value              NUMBER,
    ship_from_party_id            NUMBER,
    ship_from_party_number        VARCHAR2(30),
    ship_from_party_site_id       NUMBER,
    ship_from_party_site_number   VARCHAR2(30),
    ship_to_organization_id       NUMBER,
    ship_to_organization_code     VARCHAR2(3),
    ship_to_location_id           NUMBER,
    ship_to_location_code         VARCHAR2(60),
    bill_from_party_id            NUMBER,
    bill_from_party_number        VARCHAR2(30),
    bill_from_party_site_id       NUMBER,
    bill_from_party_site_number   VARCHAR2(30),
    bill_to_organization_id       NUMBER,
    bill_to_organization_code     VARCHAR2(3),
    bill_to_location_id           NUMBER,
    bill_to_location_code         VARCHAR2(60),
    poa_party_id                  NUMBER,
    poa_party_number              VARCHAR2(30),
    poa_party_site_id             NUMBER,
    poa_party_site_number         VARCHAR2(30),
    poo_organization_id           NUMBER,
    poo_to_organization_code      VARCHAR2(3),
    poo_location_id               NUMBER,
    poo_location_code             VARCHAR2(60),
    ship_line_id                  NUMBER,
    line_interface_source_table   VARCHAR2(30),
    line_interface_source_line_id NUMBER,
    header_interface_id           NUMBER,
    rcv_enabled_flag              VARCHAR2(1),  --Bug#9279355
    group_id                      NUMBER        --Bug#9279355
);

TYPE lci_table IS TABLE OF lci_rec INDEX BY BINARY_INTEGER;

CURSOR c_ship_lines(l_ship_header_id IN NUMBER,
                    l_src_type_code IN VARCHAR2,
                    l_interface_source_table IN VARCHAR2) IS
    SELECT sl.ship_line_id,
           sl.ship_line_num,
           sl.ship_line_source_id,
           sl.inventory_item_id,
           sl.txn_qty,
           sl.txn_uom_code,
           sl.primary_qty,
           sl.primary_uom_code,
           sl.secondary_qty,        -- Bug 8911750
           sl.secondary_uom_code,   -- Bug 8911750
           sl.currency_code,
           sl.currency_conversion_type,
           sl.currency_conversion_date,
           sl.currency_conversion_rate,
           slg.party_id,
           slg.party_site_id,
           slg.src_type_code,
           slg.ship_line_group_id,
           sh.organization_id,
--Bug#16901486 BEG
--           sh.location_id,
           NVL((SELECT pll.ship_to_location_id
                FROM po_line_locations_all pll
                WHERE pll.line_location_id = sl.ship_line_source_id
                AND sl.ship_line_src_type_code = 'PO'),sl.ship_to_location_id) location_id,
--Bug#16901486 END
           sh.org_id,
           msi.description AS item_description,
           msi.segment1 AS item,
           sh.interface_source_code,
           sl.interface_source_table,
           sl.interface_source_line_id,
           lc.unit_landed_cost,
		       pl.VENDOR_PRODUCT_NUM		--Added for bug # 17334902
    FROM   inl_ship_lines sl,
           inl_ship_line_groups slg,
           inl_ship_headers sh,
           inl_shipln_landed_costs_v lc,
           mtl_system_items msi,
		       po_line_locations_all pll,	--Added for bug # 17334902
           po_lines_all pl				--Added for bug # 17334902
    WHERE  msi.inventory_item_id  = sl.inventory_item_id
    AND    msi.organization_id    = sh.organization_id
    AND    sl.ship_header_id      = slg.ship_header_id
    AND    sl.ship_line_group_id  = slg.ship_line_group_id
    AND    slg.ship_header_id     = sh.ship_header_id
    AND    lc.ship_line_id        = sl.ship_line_id
    AND    sh.ship_header_id      = l_ship_header_id
    AND   (slg.src_type_code      = l_src_type_code
    OR     l_src_type_code IS NULL)
    AND   (sl.interface_source_table = l_interface_source_table
    OR     l_interface_source_table IS NULL)
	  AND    pll.po_line_id         = pl.po_line_id					--Added for bug # 17334902
    AND    pll.line_location_id   = sl.ship_line_source_id			--Added for bug # 17334902
    ORDER BY slg.ship_line_group_id, sl.ship_line_num; --open source

TYPE ship_lines_table IS TABLE OF c_ship_lines%ROWTYPE;

-- Bug #9279355
TYPE po_hdr_rec IS RECORD(
    po_header_id NUMBER,
    po_release_id NUMBER, -- Bug 14280113
    segment1 VARCHAR2(20),
    vendor_id NUMBER,
    vendor_site_id NUMBER,
    ship_via_lookup_code VARCHAR2(25),
    currency_code VARCHAR2(15),
    rate_type VARCHAR2(30),
    rate_date DATE,
    rate NUMBER,
    revision_num NUMBER,
    approved_date DATE,
    org_id NUMBER,
    simulation_id NUMBER);

PROCEDURE Import_FromRCV (
    p_int_rec        IN RCV_CALL_LCM_WS.rti_rec,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2
);

PROCEDURE Get_LandedCost(
    p_rti_rec         IN RCV_LCM_WEB_SERVICE.rti_cur_table,
    p_group_id        IN NUMBER,
    p_processing_mode IN VARCHAR2
);

--Bug 17536452
PROCEDURE Get_LandedCost(
    p_rti_opm_rec         IN RCV_LCM_WEB_SERVICE.rti_opm_cur_table,
    p_group_id            IN NUMBER,
    p_processing_mode     IN VARCHAR2
);
--Bug 17536452

PROCEDURE Call_StampLC (
    p_api_version    IN NUMBER,
    p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE,
    p_commit         IN VARCHAR2 := FND_API.G_FALSE,
    p_ship_header_id IN NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2
);

PROCEDURE Export_ToRCV (
    p_api_version    IN NUMBER,
    p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE,
    p_commit         IN VARCHAR2 := FND_API.G_FALSE,
    p_ship_header_id IN NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2
);

PROCEDURE Export_ToCST (
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN VARCHAR2 := FND_API.G_FALSE,
    p_ship_header_id    IN NUMBER,
    p_max_allocation_id IN NUMBER, --Bug#10032820
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE Insert_LCMInterface (
    p_api_version    IN NUMBER,
    p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE,
    p_commit         IN VARCHAR2 := FND_API.G_FALSE,
    p_lci_table      IN OUT NOCOPY lci_table,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2);

PROCEDURE Get_CurrencyInfo(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    p_ship_line_id               IN NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    x_currency_code              OUT NOCOPY VARCHAR2,
    x_currency_conversion_type   OUT NOCOPY VARCHAR2,
    x_currency_conversion_date   OUT NOCOPY DATE,
    x_currency_conversion_rate   OUT NOCOPY NUMBER);

PROCEDURE Create_POSimulation(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    p_commit        IN VARCHAR2 := FND_API.G_FALSE,
    p_po_header_id  IN  NUMBER,
    p_po_release_id IN NUMBER, -- Bug 14280113
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2);


FUNCTION Get_ExtPrecFormatMask(
    p_currency_code   IN VARCHAR2,
    p_field_length    IN NUMBER)
return VARCHAR2;

FUNCTION Check_POLcmSynch (
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    p_commit IN VARCHAR2 := FND_API.G_FALSE,
    p_simulation_id IN  NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION Check_POEligibility(p_po_header_id  IN NUMBER) RETURN VARCHAR2;

END INL_INTEGRATION_GRP;

/
