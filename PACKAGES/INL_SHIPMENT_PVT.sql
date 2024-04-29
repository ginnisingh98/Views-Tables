--------------------------------------------------------
--  DDL for Package INL_SHIPMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_SHIPMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: INLVSHPS.pls 120.13.12010000.31 2013/09/06 18:25:30 acferrei ship $ */

G_MODULE_NAME           CONSTANT VARCHAR2(200)  := 'INL.PLSQL.INL_SHIPMENT_PVT.';
G_PKG_NAME              CONSTANT VARCHAR2(30)   := 'INL_SHIPMENT_PVT';

L_FND_FALSE            CONSTANT VARCHAR2(1)   := fnd_api.g_false;            --Bug#9660082
L_FND_VALID_LEVEL_FULL CONSTANT NUMBER        := fnd_api.g_valid_level_full; --Bug#9660082


TYPE ship_qty_validation_inf_rec IS RECORD(ship_num        VARCHAR2(25),
                           ship_line_num   NUMBER);


TYPE ship_qty_validation_inf_tbl IS
TABLE OF ship_qty_validation_inf_rec INDEX BY BINARY_INTEGER;

TYPE inl_Assoc_tp IS RECORD (
    association_id              NUMBER       ,
    ship_header_id              NUMBER       ,
    allocation_basis            VARCHAR2(30) ,
    allocation_uom_code         VARCHAR2(3)  ,
    to_parent_table_name        VARCHAR2(30) ,
    to_parent_table_id          NUMBER
);

TYPE inl_ChLn_Assoc_tp IS RECORD (
    charge_line_num             NUMBER       ,
    charge_line_type_id         NUMBER       ,
    landed_cost_flag            VARCHAR2(1)  ,
    parent_charge_line_id       NUMBER       ,
    adjustment_num              NUMBER       ,
    match_id                    NUMBER       ,
    match_amount_id             NUMBER       ,
    charge_amt                  NUMBER       ,
    currency_code               VARCHAR2(15) ,
    currency_conversion_type    VARCHAR2(30) ,
    currency_conversion_date    DATE         ,
    currency_conversion_rate    NUMBER       ,
    party_id                    NUMBER       ,
    party_site_id               NUMBER       ,
    trx_business_category       VARCHAR2(240),
    intended_use                VARCHAR2(30) ,
    product_fiscal_class        VARCHAR2(240),
    product_category            VARCHAR2(240),
    product_type                VARCHAR2(240),
    user_def_fiscal_class       VARCHAR2(240),
    tax_classification_code     VARCHAR2(30) ,
    assessable_value            NUMBER       ,
    tax_already_calculated_flag VARCHAR2(1)  ,
    ship_from_party_id          NUMBER       ,
    ship_from_party_site_id     NUMBER       ,
    ship_to_organization_id     NUMBER       ,
    ship_to_location_id         NUMBER       ,
    bill_from_party_id          NUMBER       ,
    bill_from_party_site_id     NUMBER       ,
    bill_to_organization_id     NUMBER       ,
    bill_to_location_id         NUMBER       ,
    poa_party_id                NUMBER       ,
    poa_party_site_id           NUMBER       ,
    poo_organization_id         NUMBER       ,
    poo_location_id             NUMBER       ,
    inl_Assoc                   inl_Assoc_tp
);
TYPE inl_TxLn_Assoc_tp IS RECORD (
    tax_line_num              NUMBER       ,
    tax_code                  VARCHAR2(30) ,
    parent_tax_line_id        NUMBER       ,
    adjustment_num            NUMBER       ,
    match_id                  NUMBER       ,
    match_amount_id             NUMBER       ,
    source_parent_table_name  VARCHAR2(30) ,
    source_parent_table_id    NUMBER       ,
    matched_amt               NUMBER       ,
    nrec_tax_amt              NUMBER       ,
    currency_code             VARCHAR2(15) ,
    currency_conversion_type  VARCHAR2(30) ,
    currency_conversion_date  DATE         ,
    currency_conversion_rate  NUMBER       ,
    tax_amt_included_flag     VARCHAR2(1)  ,
    inl_Assoc                 inl_Assoc_tp
);

PROCEDURE Set_ToRevalidate(
    p_api_version     IN         NUMBER,
    p_init_msg_list   IN         VARCHAR2 := L_FND_FALSE,
    p_commit          IN         VARCHAR2 := L_FND_FALSE,
    p_ship_header_id  IN         NUMBER,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2
    );

PROCEDURE Validate_Shipment(
    p_api_version     IN         NUMBER,
    p_init_msg_list     IN         VARCHAR2 := L_FND_FALSE,
    p_commit            IN         VARCHAR2 := L_FND_FALSE,
    p_validation_level  IN         NUMBER   := L_FND_VALID_LEVEL_FULL,
    p_ship_header_id    IN         NUMBER,
    p_task_code         IN         VARCHAR2 DEFAULT NULL, --Bug#9836174
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
    );

FUNCTION Validate_InvOpenPeriod(
    x_trx_date      IN            VARCHAR2,
    x_sob_id        IN            NUMBER,
    x_org_id        IN            NUMBER,
    x_return_status IN OUT NOCOPY VARCHAR2
    ) RETURN VARCHAR2;

PROCEDURE Adjust_ShipLines(
    p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 := L_FND_FALSE,
    p_commit             IN VARCHAR2 := L_FND_FALSE,
    p_match_id           IN NUMBER,
    p_adjustment_num     IN NUMBER,
    p_func_currency_code IN  VARCHAR2 , --BUG#8468830
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
    );

PROCEDURE Adjust_ChargeLines (
    p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 := L_FND_FALSE,
    p_commit             IN VARCHAR2 := L_FND_FALSE,
    p_match_id           IN NUMBER,
    p_adjustment_num     IN NUMBER,
    p_func_currency_code IN VARCHAR2 , --BUG#8468830
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
);

PROCEDURE Adjust_ChargeLines (
    p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 := L_FND_FALSE,
    p_commit             IN VARCHAR2 := L_FND_FALSE,
    p_match_amount_id    IN NUMBER,
    p_adjustment_num     IN NUMBER,
    p_func_currency_code IN        VARCHAR2 , --BUG#8468830
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2);

PROCEDURE Adjust_TaxLines (
    p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 := L_FND_FALSE,
    p_commit             IN VARCHAR2 := L_FND_FALSE,
    p_match_id           IN NUMBER,
    p_adjustment_num     IN NUMBER,
    p_func_currency_code IN        VARCHAR2 , --BUG#8468830
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
);

PROCEDURE Adjust_Lines (
    p_api_version     IN NUMBER,
    p_init_msg_list   IN VARCHAR2 := L_FND_FALSE,
    p_commit          IN VARCHAR2 := L_FND_FALSE,
    p_ship_header_id  IN NUMBER,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2
    );

PROCEDURE Get_1ary2aryQty (
    p_api_version            IN NUMBER,
    p_init_msg_list          IN VARCHAR2 := L_FND_FALSE,
    p_commit                 IN VARCHAR2 := L_FND_FALSE,
    p_inventory_item_id      IN NUMBER,
    p_organization_id        IN NUMBER,
    p_uom_code               IN VARCHAR2,
    p_qty                    IN NUMBER,
    x_1ary_uom_code         OUT NOCOPY VARCHAR2,
    x_1ary_qty              OUT NOCOPY NUMBER,
    x_2ary_uom_code         OUT NOCOPY VARCHAR2,
    x_2ary_qty              OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
    );

FUNCTION Get_SrcAvailableQty(
    p_ship_line_src_type_code IN VARCHAR2,
    p_parent_id IN NUMBER
    ) RETURN NUMBER;

-- /SCM-051
PROCEDURE ProcessAction(
    p_api_version    IN NUMBER,
    p_init_msg_list  IN VARCHAR2 := L_FND_FALSE,
    p_commit         IN VARCHAR2 := L_FND_FALSE,
    p_ship_header_id IN NUMBER,
    p_task_code      IN VARCHAR2,
    p_caller         IN VARCHAR2,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2);
-- /SCM-051

PROCEDURE Complete_PendingShipment (
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_organization_id IN NUMBER,
    p_ship_header_id IN NUMBER
);

PROCEDURE Update_PendingMatchingFlag (
    p_ship_header_id IN NUMBER,
    p_pending_matching_flag IN VARCHAR,
    x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_ChargeAssoc(
    p_api_version    IN           NUMBER,
    p_init_msg_list  IN           VARCHAR2 := L_FND_FALSE,
    p_commit         IN           VARCHAR2 := L_FND_FALSE,
    p_ship_header_id IN           NUMBER,
    p_charge_line_id IN           NUMBER,
    x_return_status  OUT NOCOPY   VARCHAR2,
    x_msg_count      OUT NOCOPY   NUMBER,
    x_msg_data       OUT NOCOPY   VARCHAR2
);

-- SCM-051 Bug# 13590582
PROCEDURE Check_PoTolerances(
    p_api_version              IN NUMBER,
    p_init_msg_list            IN VARCHAR2 := L_FND_FALSE,
    p_commit                   IN VARCHAR2 := L_FND_FALSE,
    p_ship_header_id           IN NUMBER,
    p_ship_line_id             IN NUMBER,
    p_organization_id          IN NUMBER,
    p_ship_line_num            IN NUMBER,
    p_ship_line_src_id         IN NUMBER,
    p_inventory_item_id        IN NUMBER,
    p_primary_qty              IN NUMBER,
    p_primary_uom_code         IN VARCHAR2,
    p_txn_uom_code             IN VARCHAR2,
    p_new_txn_unit_price       IN NUMBER,
    p_pri_unit_price           IN NUMBER,
    p_currency_code            IN VARCHAR2,
    p_currency_conversion_type IN VARCHAR2,
    p_currency_conversion_date IN DATE,
    p_currency_conversion_rate IN NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_count                OUT NOCOPY NUMBER,
    x_msg_data                 OUT NOCOPY VARCHAR2);
-- /SCM-051 Bug# 13590582

PROCEDURE Check_PoTolerances(
    p_api_version              IN NUMBER,
    p_init_msg_list            IN VARCHAR2 := L_FND_FALSE,
    p_commit                   IN VARCHAR2 := L_FND_FALSE,
    p_ship_header_id           IN NUMBER,
    p_ship_line_id             IN NUMBER,
    p_organization_id          IN NUMBER,
    p_ship_line_num            IN NUMBER,
    p_ship_line_src_id         IN NUMBER,
    p_inventory_item_id        IN NUMBER,
    p_primary_qty              IN NUMBER,
    p_primary_uom_code         IN VARCHAR2,
    p_txn_uom_code             IN VARCHAR2,
    p_pri_unit_price           IN NUMBER,
    p_currency_code            IN VARCHAR2,
    p_currency_conversion_type IN VARCHAR2,
    p_currency_conversion_date IN DATE,
    p_currency_conversion_rate IN NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_count                OUT NOCOPY NUMBER,
    x_msg_data                 OUT NOCOPY VARCHAR2
);

PROCEDURE Check_PoPriceTolerance(
    p_ship_header_id           IN NUMBER,
    p_ship_line_id             IN NUMBER,
    p_organization_id          IN NUMBER,
    p_ship_line_num            IN NUMBER,
    p_ship_line_src_id         IN NUMBER,
    p_pri_unit_price           IN NUMBER,
    p_primary_uom_code         IN VARCHAR2, --BUG#7670307
    p_currency_code            IN VARCHAR2, --BUG#7670307
    p_currency_conversion_type IN VARCHAR2, --BUG#7670307
    p_currency_conversion_date IN DATE,     --BUG#7670307
    p_currency_conversion_rate IN NUMBER,   --BUG#7670307
    x_return_validation_status OUT NOCOPY VARCHAR2, -- ebarbosa
    x_return_status            OUT NOCOPY VARCHAR2
); -- ebarbosa

/* Bug#10032820
can't be call from none else process_action
PROCEDURE Complete_Shipment (
    p_api_version            IN NUMBER,
    p_init_msg_list          IN VARCHAR2 := L_FND_FALSE,
    p_commit                 IN VARCHAR2 := L_FND_FALSE,
    p_ship_header_id         IN NUMBER,
    p_rcv_enabled_flag       IN VARCHAR2,
    p_pending_matching_flag  IN VARCHAR2,
    p_organization_id        IN NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
);
*/
FUNCTION Get_MatchedAmt(p_ship_header_id         IN NUMBER,
                        p_ship_line_id           IN NUMBER,
                        p_charge_line_type_id    IN NUMBER,
                        p_tax_code               IN VARCHAR2,
                        p_match_table_name       IN VARCHAR2,
                        p_summarized_matched_amt IN VARCHAR2) RETURN NUMBER;

FUNCTION Get_LastUpdateDateForShip(p_ship_header_id IN NUMBER) RETURN DATE; -- Bug #9098758

PROCEDURE Discard_Updates(p_api_version    IN NUMBER,
                          p_init_msg_list  IN VARCHAR2 := L_FND_FALSE,
                          p_commit         IN VARCHAR2 := L_FND_FALSE,
                          p_ship_header_id IN NUMBER,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2);
--- Bug 13914863
PROCEDURE Get_1aryQty(p_api_version       IN NUMBER,
                      p_init_msg_list     IN VARCHAR2 := L_FND_FALSE,
                      p_commit            IN VARCHAR2 := L_FND_FALSE,
                      p_inventory_item_id IN NUMBER,
                      p_organization_id   IN NUMBER,
                      p_uom_code          IN VARCHAR2,
                      p_qty               IN NUMBER,
                      x_1ary_uom_code     OUT NOCOPY VARCHAR2,
                      x_1ary_qty          OUT NOCOPY NUMBER,
                      x_return_status     OUT NOCOPY VARCHAR2,
                      x_msg_count         OUT NOCOPY NUMBER,
                      x_msg_data          OUT NOCOPY VARCHAR2);

-- Bug 13914863
PROCEDURE Get_2aryQty(p_api_version       IN NUMBER,
                      p_init_msg_list     IN VARCHAR2 := L_FND_FALSE,
                      p_commit            IN VARCHAR2 := L_FND_FALSE,
                      p_inventory_item_id IN NUMBER,
                      p_organization_id   IN NUMBER,
                      p_uom_code          IN VARCHAR2,
                      p_qty               IN NUMBER,
                      x_2ary_uom_code     OUT NOCOPY VARCHAR2,
                      x_2ary_qty          OUT NOCOPY NUMBER,
                      x_return_status     OUT NOCOPY VARCHAR2,
                      x_msg_count         OUT NOCOPY NUMBER,
                      x_msg_data          OUT NOCOPY VARCHAR2);

-- Bug 13914863
FUNCTION Derive_DualQuantities(p_organization_id     IN NUMBER,
                               p_inventory_item_id   IN NUMBER,
                               p_calling_field       IN VARCHAR2,
                               p_txn_qty             IN NUMBER,
                               p_txn_uom_code        IN VARCHAR2,
                               p_secondary_qty       IN NUMBER,
                               p_secondary_uom_code  IN VARCHAR2) RETURN NUMBER;

-- Bug 13914863
PROCEDURE Validate_DualQuantities(
                   p_api_version         IN NUMBER,
                   p_init_msg_list       IN VARCHAR2 := L_FND_FALSE,
                   p_commit              IN VARCHAR2 := L_FND_FALSE,
                   p_organization_id     IN NUMBER,
                   p_inventory_item_id   IN NUMBER,
                   p_primary_qty         IN NUMBER,
                   p_primary_uom_code    IN VARCHAR2,
                   p_secondary_qty       IN NUMBER,
                   p_secondary_uom_code  IN VARCHAR2,
                   x_return_status      OUT NOCOPY VARCHAR2,
                   x_msg_count          OUT NOCOPY NUMBER,
                   x_msg_data           OUT NOCOPY VARCHAR2);

END INL_SHIPMENT_PVT;

/
