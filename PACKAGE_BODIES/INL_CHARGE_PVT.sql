--------------------------------------------------------
--  DDL for Package Body INL_CHARGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_CHARGE_PVT" AS
/* $Header: INLVCHGB.pls 120.2.12010000.31 2012/10/04 20:01:48 acferrei ship $ */

    L_FND_USER_ID               CONSTANT NUMBER        := fnd_global.user_id;           --Bug#9660056
--    L_FND_CONC_PROGRAM_ID       CONSTANT NUMBER        := fnd_global.conc_program_id;   --Bug#9660056
--    L_FND_PROG_APPL_ID          CONSTANT NUMBER        := fnd_global.prog_appl_id ;     --Bug#9660056
--    L_FND_CONC_REQUEST_ID       CONSTANT NUMBER        := fnd_global.conc_request_id;   --Bug#9660056
--    L_FND_LOCAL_CHR             CONSTANT VARCHAR2(100) := fnd_global.local_chr (10);    --Bug#9660056
    L_FND_LOGIN_ID              CONSTANT NUMBER        := fnd_global.login_id;          --Bug#9660056

--    L_FND_TRUE                  CONSTANT VARCHAR2(1)   := fnd_api.g_true;               --Bug#9660056
--    L_FND_VALID_LEVEL_FULL      CONSTANT NUMBER        := fnd_api.g_valid_level_full;   --Bug#9660056
--    L_FND_MISS_NUM              CONSTANT NUMBER        := fnd_api.g_miss_num;           --Bug#9660056
--    L_FND_MISS_CHAR             CONSTANT VARCHAR2(1)   := fnd_api.g_miss_char;          --Bug#9660056

    L_FND_EXC_ERROR             EXCEPTION;                                              --Bug#9660056
    L_FND_EXC_UNEXPECTED_ERROR  EXCEPTION;                                              --Bug#9660056

    L_FND_RET_STS_SUCCESS       CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_success;    --Bug#9660056
    L_FND_RET_STS_ERROR         CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_error;      --Bug#9660056
    L_FND_RET_STS_UNEXP_ERROR   CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_unexp_error;--Bug#9660056


-- Utility name : Insert_Association
-- Type       : Private
-- Function   : Insert a record into INL Association's table.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id          IN NUMBER
--              p_from_parent_table_name  IN VARCHAR2
--              p_from_parent_table_id    IN NUMBER
--              p_to_parent_table_name    IN VARCHAR2
--              p_to_parent_table_id      IN NUMBER
--
-- OUT          x_return_status           OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Insert_Association(
    p_ship_header_id          IN NUMBER,
    p_from_parent_table_name  IN VARCHAR2,
    p_from_parent_table_id    IN NUMBER,
    p_to_parent_table_name    IN VARCHAR2,
    p_to_parent_table_id      IN NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2
) IS

    l_proc_name  CONSTANT VARCHAR2(30) := 'Insert_Association';
    l_debug_info VARCHAR2(200);
    l_allocation_basis VARCHAR2(30);
    l_allocation_uom_code VARCHAR(30);

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name);

    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Get the Allocation Basis and UOM Code';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name,
                                   p_debug_info => l_debug_info);
    SELECT icv.allocation_basis,
           ab.base_uom_code
      INTO l_allocation_basis,
           l_allocation_uom_code
      FROM inl_allocation_basis_vl ab,
           inl_charge_line_types_vl icv,
           inl_charge_lines icl
     WHERE ab.allocation_basis_code (+) = icv.allocation_basis
       AND icv.charge_line_type_id (+) = icl.charge_line_type_id
       AND icl.charge_line_id = p_from_parent_table_id;

    l_debug_info := 'Insert into INL Associations table';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name,
                                   p_debug_info => l_debug_info);

    INSERT INTO inl_associations(
        association_id,
        ship_header_id,
        from_parent_table_name,
        from_parent_table_id,
        to_parent_table_name,
        to_parent_table_id,
        allocation_basis,
        allocation_uom_code,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
    VALUES (
        inl_associations_s.NEXTVAL,
        p_ship_header_id,
        p_from_parent_table_name,
        p_from_parent_table_id,
        p_to_parent_table_name,
        p_to_parent_table_id,
        l_allocation_basis,
        l_allocation_uom_code,
        L_FND_USER_ID,
        SYSDATE,
        L_FND_USER_ID,
        SYSDATE,
        L_FND_LOGIN_ID
    );

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name
    );
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(
            p_pkg_name => g_pkg_name,
            p_procedure_name => l_proc_name
        );
    END IF;
END Insert_Association;

-- Utility name : Insert_ChargeLines
-- Type       : Private
-- Function   : Insert an INL Charge Line and call the routine
--              to create the related INL Association
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id           IN NUMBER
--              p_charge_line_type_id      IN NUMBER
--              p_landed_cost_flag         IN VARCHAR2
--              p_update_allowed           IN VARCHAR2
--              p_source_code              IN VARCHAR2
--              p_charge_amt               IN NUMBER
--              p_currency_code            IN VARCHAR2
--              p_currency_conversion_type IN VARCHAR2
--              p_currency_conversion_date IN DATE
--              p_currency_conversion_rate IN NUMBER
--              p_party_id                 IN NUMBER
--              p_party_site_id            IN NUMBER
--              p_trx_business_category    IN VARCHAR2
--              p_intended_use             IN VARCHAR2
--              p_product_fiscal_class     IN VARCHAR2
--              p_product_category         IN VARCHAR2
--              p_product_type             IN VARCHAR2
--              p_user_def_fiscal_class    IN VARCHAR2
--              p_tax_classification_code  IN VARCHAR2
--              p_assessable_value         IN NUMBER
--              p_ship_from_party_id       IN NUMBER
--              p_ship_from_party_site_id  IN NUMBER
--              p_ship_to_organization_id  IN NUMBER
--              p_ship_to_location_id      IN NUMBER
--              p_bill_from_party_id       IN NUMBER
--              p_bill_from_party_site_id  IN NUMBER
--              p_bill_to_organization_id  IN NUMBER
--              p_bill_to_location_id      IN NUMBER
--              p_poa_party_id             IN NUMBER
--              p_poa_party_site_id        IN NUMBER
--              p_poo_organization_id      IN NUMBER
--              p_poo_location_id          IN NUMBER
--              p_to_parent_table_name     IN VARCHAR2
--              p_to_parent_table_id       IN NUMBER
--
-- OUT          x_return_status            OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Insert_ChargeLines(
    p_ship_header_id           IN NUMBER,
    p_charge_line_type_id      IN NUMBER,
    p_landed_cost_flag         IN VARCHAR2,
    p_update_allowed           IN VARCHAR2,
    p_source_code              IN VARCHAR2,
    p_charge_amt               IN NUMBER,
    p_currency_code            IN VARCHAR2,
    p_currency_conversion_type IN VARCHAR2,
    p_currency_conversion_date IN DATE,
    p_currency_conversion_rate IN NUMBER,
    p_party_id                 IN NUMBER,
    p_party_site_id            IN NUMBER,
    p_trx_business_category    IN VARCHAR2,
    p_intended_use             IN VARCHAR2,
    p_product_fiscal_class     IN VARCHAR2,
    p_product_category         IN VARCHAR2,
    p_product_type             IN VARCHAR2,
    p_user_def_fiscal_class    IN VARCHAR2,
    p_tax_classification_code  IN VARCHAR2,
    p_assessable_value         IN NUMBER,
    p_ship_from_party_id       IN NUMBER,
    p_ship_from_party_site_id  IN NUMBER,
    p_ship_to_organization_id  IN NUMBER,
    p_ship_to_location_id      IN NUMBER,
    p_bill_from_party_id       IN NUMBER,
    p_bill_from_party_site_id  IN NUMBER,
    p_bill_to_organization_id  IN NUMBER,
    p_bill_to_location_id      IN NUMBER,
    p_poa_party_id             IN NUMBER,
    p_poa_party_site_id        IN NUMBER,
    p_poo_organization_id      IN NUMBER,
    p_poo_location_id          IN NUMBER,
    p_to_parent_table_name     IN VARCHAR2,
    p_to_parent_table_id       IN NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2
) IS

    l_proc_name        CONSTANT VARCHAR2(30) := 'Insert_ChargeLines';
    l_debug_info       VARCHAR2(200);
    l_return_status    VARCHAR2(1);
    l_charge_line_id   NUMBER;
    l_charge_line_num  NUMBER;

BEGIN
    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name
    );

    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Get the Charge Line ID';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info
    );

    SELECT inl_charge_lines_s.NEXTVAL
      INTO l_charge_line_id
      FROM dual;

    l_debug_info := 'Get the Charge Line Number';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info
    );

    SELECT NVL(MAX(icl.charge_line_num),0) + 1
      INTO l_charge_line_num
      FROM inl_charge_lines icl,
           inl_associations ias
     WHERE ias.from_parent_table_name = 'INL_CHARGE_LINES'
       AND ias.from_parent_table_id = icl.charge_line_id
       AND ias.ship_header_id = p_ship_header_id;

    l_debug_info := 'Insert into INL Charge Line table.';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name,
                                   p_debug_info => l_debug_info);

    INSERT INTO inl_charge_lines(
        charge_line_id,
        charge_line_num,
        charge_line_type_id,
        landed_cost_flag,
        update_allowed,
        source_code,
        adjustment_num,
        charge_amt,
        currency_code,
        currency_conversion_type,
        currency_conversion_date,
        currency_conversion_rate,
        party_id,
        party_site_id,
        trx_business_category,
        intended_use,
        product_fiscal_class,
        product_category,
        product_type,
        user_def_fiscal_class,
        tax_classification_code,
        assessable_value,
        tax_already_calculated_flag,
        ship_from_party_id,
        ship_from_party_site_id,
        ship_to_organization_id,
        ship_to_location_id,
        bill_from_party_id,
        bill_from_party_site_id,
        bill_to_organization_id,
        bill_to_location_id,
        poa_party_id,
        poa_party_site_id,
        poo_organization_id,
        poo_location_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
    VALUES(
        l_charge_line_id,
        l_charge_line_num,
        p_charge_line_type_id,
        p_landed_cost_flag,
        p_update_allowed,
        p_source_code,
        0, -- adjustment_num
        p_charge_amt,
        p_currency_code,
        p_currency_conversion_type,
        p_currency_conversion_date,
        p_currency_conversion_rate,
        p_party_id,
        p_party_site_id,
        p_trx_business_category,
        p_intended_use,
        p_product_fiscal_class,
        p_product_category,
        p_product_type,
        p_user_def_fiscal_class,
        p_tax_classification_code,
        p_assessable_value,
        'N', -- tax_already_calculated_flag
        p_ship_from_party_id,
        p_ship_from_party_site_id,
        p_ship_to_organization_id,
        p_ship_to_location_id,
        p_bill_from_party_id,
        p_bill_from_party_site_id,
        p_bill_to_organization_id,
        p_bill_to_location_id,
        p_poa_party_id,
        p_poa_party_site_id,
        p_poo_organization_id,
        p_poo_location_id,
        L_FND_USER_ID,
        SYSDATE,
        L_FND_USER_ID,
        SYSDATE,
        L_FND_LOGIN_ID
    );

    l_debug_info := 'Call Insert_Association(...)';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info
    );

    Insert_Association(
        p_ship_header_id         => p_ship_header_id,
        p_from_parent_table_name => 'INL_CHARGE_LINES', -- from_parent_table_name
        p_from_parent_table_id   => l_charge_line_id, -- from_parent_table_id
        p_to_parent_table_name   => p_to_parent_table_name,
        p_to_parent_table_id     => p_to_parent_table_id,
        x_return_status          => l_return_status
    );

    -- If any errors happen abort the process.
    IF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name
    );
EXCEPTION
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name,
                                          p_procedure_name => l_proc_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name => g_pkg_name,
                p_procedure_name => l_proc_name);
        END IF;
END Insert_ChargeLines;

-- Utility name  : Populate_HeaderRecord
-- Type       : Private
-- Function   : Populate the global header structure with the
--              LCM Shipment Line Group info.
-- Pre-reqs   : None
-- Parameters :
-- IN           p_org_id            IN  NUMBER
--              p_order_header_id       IN  NUMBER
--              p_supplier_id           IN  NUMBER
--              p_supplier_site_id      IN  NUMBER
--              p_creation_date         IN  DATE
--              p_order_type            IN  VARCHAR2
--              p_ship_to_location_id   IN  NUMBER
--              p_ship_to_org_id        IN  NUMBER
--              p_shipment_header_id    IN  NUMBER   DEFAULT NULL
--              p_hazard_class          IN  VARCHAR2 DEFAULT NULL
--              p_hazard_code           IN  VARCHAR2 DEFAULT NULL
--              p_shipped_date          IN  DATE     DEFAULT NULL
--              p_shipment_num          IN  VARCHAR2 DEFAULT NULL
--              p_carrier_method        IN  VARCHAR2 DEFAULT NULL
--              p_packaging_code        IN  VARCHAR2 DEFAULT NULL
--              p_freight_carrier_code  IN  VARCHAR2 DEFAULT NULL
--              p_freight_terms         IN  VARCHAR2 DEFAULT NULL
--              p_currency_code         IN  VARCHAR2 DEFAULT NULL
--              p_rate              IN  NUMBER   DEFAULT NULL
--              p_rate_type         IN  VARCHAR2 DEFAULT NULL
--              p_source_org_id         IN  NUMBER   DEFAULT NULL
--              p_expected_receipt_date IN  DATE     DEFAULT NULL
--
-- OUT          x_return_status         OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Populate_HeaderRecord(
    p_org_id            IN  NUMBER,
    p_order_header_id       IN  NUMBER,
    p_supplier_id           IN  NUMBER,
    p_supplier_site_id      IN  NUMBER,
    p_creation_date         IN  DATE,
    p_order_type            IN  VARCHAR2,
    p_ship_to_location_id   IN  NUMBER,
    p_ship_to_org_id        IN  NUMBER,
    p_shipment_header_id    IN  NUMBER   DEFAULT NULL,
    p_hazard_class          IN  VARCHAR2 DEFAULT NULL,
    p_hazard_code           IN  VARCHAR2 DEFAULT NULL,
    p_shipped_date          IN  DATE     DEFAULT NULL,
    p_shipment_num          IN  VARCHAR2 DEFAULT NULL,
    p_carrier_method        IN  VARCHAR2 DEFAULT NULL,
    p_packaging_code        IN  VARCHAR2 DEFAULT NULL,
    p_freight_carrier_code  IN  VARCHAR2 DEFAULT NULL,
    p_freight_terms         IN  VARCHAR2 DEFAULT NULL,
    p_currency_code         IN  VARCHAR2 DEFAULT NULL,
    p_rate              IN  NUMBER   DEFAULT NULL,
    p_rate_type         IN  VARCHAR2 DEFAULT NULL,
    p_source_org_id         IN  NUMBER   DEFAULT NULL,
    p_expected_receipt_date IN  DATE     DEFAULT NULL,
    x_return_status         OUT NOCOPY VARCHAR2
)IS

    l_proc_name CONSTANT VARCHAR2(30) := 'Populate_HeaderRecord';

BEGIN

    -- Begin the procedure
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name);
    -- Init return status
    x_return_status := L_FND_RET_STS_SUCCESS;

    -- Setting the global header record structure
    po_advanced_price_pvt.g_hdr.org_id                := p_org_id;
    po_advanced_price_pvt.g_hdr.p_order_header_id     := p_order_header_id;
    po_advanced_price_pvt.g_hdr.supplier_id           := p_supplier_id;
    po_advanced_price_pvt.g_hdr.supplier_site_id      := p_supplier_site_id;
    po_advanced_price_pvt.g_hdr.creation_date         := p_creation_date;
    po_advanced_price_pvt.g_hdr.order_type            := p_order_type;
    po_advanced_price_pvt.g_hdr.ship_to_location_id   := p_ship_to_location_id;
    po_advanced_price_pvt.g_hdr.ship_to_org_id        := p_ship_to_org_id;
    po_advanced_price_pvt.g_hdr.shipment_header_id    := p_shipment_header_id;
    po_advanced_price_pvt.g_hdr.hazard_class          := p_hazard_class;
    po_advanced_price_pvt.g_hdr.hazard_code           := p_hazard_code;
    po_advanced_price_pvt.g_hdr.shipped_date          := p_shipped_date;
    po_advanced_price_pvt.g_hdr.shipment_num          := p_shipment_num;
    po_advanced_price_pvt.g_hdr.carrier_method        := p_carrier_method;
    po_advanced_price_pvt.g_hdr.packaging_code        := p_packaging_code;
    po_advanced_price_pvt.g_hdr.freight_carrier_code  := p_freight_carrier_code;
    po_advanced_price_pvt.g_hdr.freight_terms         := p_freight_terms;
    po_advanced_price_pvt.g_hdr.currency_code         := p_currency_code;
    po_advanced_price_pvt.g_hdr.rate                  := p_rate;
    po_advanced_price_pvt.g_hdr.rate_type             := p_rate_type;
    po_advanced_price_pvt.g_hdr.source_org_id         := p_source_org_id;
    po_advanced_price_pvt.g_hdr.expected_receipt_date := p_expected_receipt_date;

    -- End the procedure
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name
    );
EXCEPTION
  WHEN OTHERS THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name
    );
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
END Populate_HeaderRecord;

-- Utility name  : Populate_LineRecord
-- Type       : Private
-- Function   : Populate the global line structure with the LCM Shipment Line info.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_order_line_id       IN NUMBER
--              p_item_revision       IN VARCHAR2
--              p_item_id         IN NUMBER
--              p_category_id         IN NUMBER
--              p_supplier_item_num   IN VARCHAR2
--              p_agreement_type      IN VARCHAR2
--              p_agreement_id        IN NUMBER
--              p_agreement_line_id   IN NUMBER  DEFAULT NULL
--              p_supplier_id         IN NUMBER
--              p_supplier_site_id    IN NUMBER
--              p_ship_to_location_id     IN NUMBER
--              p_ship_to_org_id      IN NUMBER
--              p_rate            IN NUMBER
--              p_rate_type       IN VARCHAR2
--              p_currency_code       IN VARCHAR2
--              p_need_by_date        IN DATE
--              p_shipment_line_id        IN NUMBER    DEFAULT NULL
--              p_primary_unit_of_measure IN VARCHAR2   DEFAULT NULL
--              p_to_organization_id      IN NUMBER    DEFAULT NULL
--              p_unit_of_measure         IN VARCHAR2  DEFAULT NULL
--              p_source_document_code    IN VARCHAR2  DEFAULT NULL
--              p_unit_price              IN NUMBER    DEFAULT NULL
--              p_quantity                IN NUMBER    DEFAULT NULL
--
-- OUT          x_return_status           OUT  NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Populate_LineRecord(
    p_order_line_id           IN  NUMBER,
    p_item_revision           IN  VARCHAR2,
    p_item_id                 IN  NUMBER,
    p_category_id             IN  NUMBER,
    p_supplier_item_num       IN  VARCHAR2,
    p_agreement_type          IN  VARCHAR2,
    p_agreement_id            IN  NUMBER,
    p_agreement_line_id       IN  NUMBER  DEFAULT NULL,
    p_supplier_id             IN  NUMBER,
    p_supplier_site_id        IN  NUMBER,
    p_ship_to_location_id     IN  NUMBER,
    p_ship_to_org_id          IN  NUMBER,
    p_rate                    IN  NUMBER,
    p_rate_type               IN  VARCHAR2,
    p_currency_code           IN  VARCHAR2,
    p_need_by_date            IN  DATE,
    p_shipment_line_id        IN  NUMBER    DEFAULT NULL,
    p_primary_unit_of_measure IN VARCHAR2   DEFAULT NULL,
    p_to_organization_id      IN  NUMBER    DEFAULT NULL,
    p_unit_of_measure         IN  VARCHAR2  DEFAULT NULL,
    p_source_document_code    IN  VARCHAR2  DEFAULT NULL,
    p_unit_price              IN  NUMBER    DEFAULT NULL,
    p_quantity                IN  NUMBER    DEFAULT NULL,
    x_return_status           OUT NOCOPY VARCHAR2
) IS

    l_proc_name CONSTANT VARCHAR2(30) := 'Populate_LineRecord';

BEGIN

    -- Begin the procedure
    INL_LOGGING_PVT.Log_BeginProc (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name);
    -- Init return status
    x_return_status := L_FND_RET_STS_SUCCESS;

    -- Setting the global line record structure
    po_advanced_price_pvt.g_line.order_line_id           := p_order_line_id;
    po_advanced_price_pvt.g_line.item_revision           := p_item_revision;
    po_advanced_price_pvt.g_line.item_id                 := p_item_id;
    po_advanced_price_pvt.g_line.category_id             := p_category_id;
    po_advanced_price_pvt.g_line.supplier_item_num       := p_supplier_item_num;
    po_advanced_price_pvt.g_line.agreement_type          := p_agreement_type;
    po_advanced_price_pvt.g_line.agreement_id            := p_agreement_id;
    po_advanced_price_pvt.g_line.agreement_line_id       := p_agreement_line_id;
    po_advanced_price_pvt.g_line.supplier_id             := p_supplier_id;
    po_advanced_price_pvt.g_line.supplier_site_id        := p_supplier_site_id;
    po_advanced_price_pvt.g_line.ship_to_location_id     := p_ship_to_location_id;
    po_advanced_price_pvt.g_line.ship_to_org_id          := p_ship_to_org_id;
    po_advanced_price_pvt.g_line.rate                    := p_rate;
    po_advanced_price_pvt.g_line.rate_type               := p_rate_type;
    po_advanced_price_pvt.g_line.currency_code           := p_currency_code;
    po_advanced_price_pvt.g_line.need_by_date            := p_need_by_date;
    po_advanced_price_pvt.g_line.shipment_line_id        := p_shipment_line_id;
    po_advanced_price_pvt.g_line.primary_unit_of_measure := p_primary_unit_of_measure;
    po_advanced_price_pvt.g_line.to_organization_id      := p_to_organization_id;
    po_advanced_price_pvt.g_line.unit_of_measure         := p_unit_of_measure;
    po_advanced_price_pvt.g_line.source_document_code    := p_source_document_code;
    po_advanced_price_pvt.g_line.unit_price              := p_unit_price;
    po_advanced_price_pvt.g_line.quantity                := p_quantity;

    -- End the procedure
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name
    );
EXCEPTION
  WHEN OTHERS THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name
    );
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
END Populate_LineRecord;

-- Utility name : Get_ChargesFromQP
-- Type       : Private
-- Function   : Encapsulate the necessary steps to integrate with QP
--              and return a table with all generated Charge Lines.
-- Pre-reqs   : None
-- Parameters :
-- IN         :   p_ship_ln_group_rec   ship_ln_group_rec
--                p_ship_ln_tbl         ship_ln_tbl
--
-- OUT            x_charge_ln_tbl       OUT NOCOPY charge_ln_tbl
--                x_return_status       OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Get_ChargesFromQP(
    p_ship_ln_group_rec IN ship_ln_group_rec,
    p_ship_ln_tbl       IN ship_ln_tbl,
    x_charge_ln_tbl     IN OUT NOCOPY charge_ln_tbl,
    x_return_status     OUT NOCOPY VARCHAR2
) IS

    l_proc_name         CONSTANT VARCHAR2(30) := 'Get_ChargesFromQP';
    l_to_parent_tbl_name_order CONSTANT VARCHAR2(30) := 'INL_SHIP_LINE_GROUPS';
    l_to_parent_tbl_name_line  CONSTANT VARCHAR2(30) := 'INL_SHIP_LINES';
    l_no_freight_charge EXCEPTION;

    l_debug_info VARCHAR2(200);
    l_return_status VARCHAR2(1);
    l_return_status_text VARCHAR2(2000);
    l_line_index PLS_INTEGER := 1;
    l_charge_ln_index NUMBER := NVL(x_charge_ln_tbl.count,0) + 1;
    l_pass_line VARCHAR2(1);
    l_exception_msg VARCHAR2(2000);
    l_qp_license VARCHAR2(30) := NULL;
    l_currency_code DBMS_SQL.varchar2_table;
    l_line_quantities DBMS_SQL.number_table;
    l_line_1ary_quantities DBMS_SQL.number_table; --BUG#8928845

    l_request_type_code_tbl        QP_PREQ_GRP.varchar_type;
    l_line_id_tbl                  QP_PREQ_GRP.number_type;
    l_line_index_tbl               QP_PREQ_GRP.pls_integer_type;
    l_line_type_code_tbl           QP_PREQ_GRP.varchar_type;
    l_pricinl_effective_date_tbl   QP_PREQ_GRP.date_type;
    l_active_date_first_tbl        QP_PREQ_GRP.date_type;
    l_active_date_second_tbl       QP_PREQ_GRP.date_type;
    l_active_date_first_type_tbl   QP_PREQ_GRP.varchar_type;
    l_active_date_second_type_tbl  QP_PREQ_GRP.varchar_type;
    l_line_unit_price_tbl          QP_PREQ_GRP.number_type;
    l_line_quantity_tbl            QP_PREQ_GRP.number_type;
    l_line_uom_code_tbl            QP_PREQ_GRP.varchar_type;
    l_currency_code_tbl            QP_PREQ_GRP.varchar_type;
    l_price_flag_tbl               QP_PREQ_GRP.varchar_type;
    l_usage_pricing_type_tbl       QP_PREQ_GRP.varchar_type;
    l_priced_quantity_tbl          QP_PREQ_GRP.number_type;
    l_priced_uom_code_tbl          QP_PREQ_GRP.varchar_type;
    l_unit_price_tbl               QP_PREQ_GRP.number_type;
    l_percent_price_tbl            QP_PREQ_GRP.number_type;
    l_uom_quantity_tbl             QP_PREQ_GRP.number_type;
    l_adjusted_unit_price_tbl      QP_PREQ_GRP.number_type;
    l_upd_adjusted_unit_price_tbl  QP_PREQ_GRP.number_type;
    l_processed_flag_tbl           QP_PREQ_GRP.varchar_type;
    l_processing_order_tbl         QP_PREQ_GRP.pls_integer_type;
    l_pricing_status_code_tbl      QP_PREQ_GRP.varchar_type;
    l_pricing_status_text_tbl      QP_PREQ_GRP.varchar_type;
    l_rounding_flag_tbl            QP_PREQ_GRP.flag_type;
    l_rounding_factor_tbl          QP_PREQ_GRP.pls_integer_type;
    l_qualifiers_exist_flag_tbl    QP_PREQ_GRP.varchar_type;
    l_pricing_attrs_exist_flag_tbl QP_PREQ_GRP.varchar_type;
    l_price_list_id_tbl            QP_PREQ_GRP.number_type;
    l_pl_validated_flag_tbl        QP_PREQ_GRP.varchar_type;
    l_price_request_code_tbl       QP_PREQ_GRP.varchar_type;
    l_line_category_tbl            QP_PREQ_GRP.varchar_type;
    l_list_price_overide_flag_tbl  QP_PREQ_GRP.varchar_type;
    l_control_rec                  QP_PREQ_GRP.control_record_type;

    l_freight_charge_rec_tbl       freight_charge_tbl;
    l_freight_charge_tbl           freight_charge_tbl;
    l_qp_cost_table                qp_price_result_tbl;
    l_cost_factor_details          pon_price_element_types_vl%ROWTYPE;

    l_ship_ln_group_tbl            ship_ln_group_rec;
    l_ship_ln_tbl                  ship_ln_tbl;
    l_log_all_input_var            VARCHAR2(1):='Y';
    l_qp_charge_lookup             NUMBER; -- Bug #9274538
    l_cost_factor_valid            VARCHAR2(1):='T'; -- Bug #9274538

BEGIN
    -- Begin the procedure
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name);

    -- Init return status
    x_return_status := L_FND_RET_STS_SUCCESS;

    IF l_log_all_input_var = 'Y'
    THEN
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.ship_line_group_id     ',
            p_var_value      => p_ship_ln_group_rec.ship_line_group_id     );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.org_id                 ',
            p_var_value      => p_ship_ln_group_rec.org_id                 );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.p_order_header_id      ',
            p_var_value      => p_ship_ln_group_rec.p_order_header_id      );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.supplier_id            ',
            p_var_value      => p_ship_ln_group_rec.supplier_id            );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.supplier_site_id       ',
            p_var_value      => p_ship_ln_group_rec.supplier_site_id       );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.creation_date          ',
            p_var_value      => p_ship_ln_group_rec.creation_date          );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.order_type             ',
            p_var_value      => p_ship_ln_group_rec.order_type             );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.ship_to_location_id    ',
            p_var_value      => p_ship_ln_group_rec.ship_to_location_id    );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.ship_to_org_id         ',
            p_var_value      => p_ship_ln_group_rec.ship_to_org_id         );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.shipment_header_id     ',
            p_var_value      => p_ship_ln_group_rec.shipment_header_id     );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.hazard_class           ',
            p_var_value      => p_ship_ln_group_rec.hazard_class           );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.hazard_code            ',
            p_var_value      => p_ship_ln_group_rec.hazard_code            );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.shipped_date           ',
            p_var_value      => p_ship_ln_group_rec.shipped_date           );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.shipment_num           ',
            p_var_value      => p_ship_ln_group_rec.shipment_num           );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.carrier_method         ',
            p_var_value      => p_ship_ln_group_rec.carrier_method         );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.packaging_code         ',
            p_var_value      => p_ship_ln_group_rec.packaging_code         );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.freight_carrier_code   ',
            p_var_value      => p_ship_ln_group_rec.freight_code   );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.freight_terms          ',
            p_var_value      => p_ship_ln_group_rec.freight_terms          );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.currency_code          ',
            p_var_value      => p_ship_ln_group_rec.currency_code          );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.rate                   ',
            p_var_value      => p_ship_ln_group_rec.rate                   );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.rate_type              ',
            p_var_value      => p_ship_ln_group_rec.rate_type              );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.source_org_id          ',
            p_var_value      => p_ship_ln_group_rec.source_org_id          );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.expected_receipt_date  ',
            p_var_value      => p_ship_ln_group_rec.expected_receipt_date  );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.request_type           ',
            p_var_value      => 'Have not'         );
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.pricing_event          ',
            p_var_value      => 'Have not');
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_var_name       => 'p_ship_ln_group_rec.qp_curr_conv_type      ',
            p_var_value      => 'Have not'   );

        FOR l IN 1..p_ship_ln_tbl.COUNT LOOP
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'l: ',
                p_var_value      => l                                       );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).order_line_id          ',
                p_var_value      => p_ship_ln_tbl(l).order_line_id          );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).agreement_type         ',
                p_var_value      => p_ship_ln_tbl(l).agreement_type         );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).agreement_id           ',
                p_var_value      => p_ship_ln_tbl(l).agreement_id           );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).agreement_line_id      ',
                p_var_value      => p_ship_ln_tbl(l).agreement_line_id      );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).supplier_id            ',
                p_var_value      => p_ship_ln_tbl(l).supplier_id            );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).supplier_site_id       ',
                p_var_value      => p_ship_ln_tbl(l).supplier_site_id       );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).ship_to_location_id    ',
                p_var_value      => p_ship_ln_tbl(l).ship_to_location_id    );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).ship_to_org_id         ',
                p_var_value      => p_ship_ln_tbl(l).ship_to_org_id         );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).supplier_item_num      ',
                p_var_value      => p_ship_ln_tbl(l).supplier_item_num      );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).item_revision          ',
                p_var_value      => p_ship_ln_tbl(l).item_revision          );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).item_id                ',
                p_var_value      => p_ship_ln_tbl(l).item_id                );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).category_id            ',
                p_var_value      => p_ship_ln_tbl(l).category_id            );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).rate                   ',
                p_var_value      => p_ship_ln_tbl(l).rate                   );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).rate_type              ',
                p_var_value      => p_ship_ln_tbl(l).rate_type              );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).currency_code          ',
                p_var_value      => p_ship_ln_tbl(l).currency_code          );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).need_by_date           ',
                p_var_value      => p_ship_ln_tbl(l).need_by_date           );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).shipment_line_id       ',
                p_var_value      => p_ship_ln_tbl(l).shipment_line_id       );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).primary_unit_of_measure',
                p_var_value      => p_ship_ln_tbl(l).primary_unit_of_measure);
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).to_organization_id     ',
                p_var_value      => p_ship_ln_tbl(l).to_organization_id     );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).unit_of_measure        ',
                p_var_value      => p_ship_ln_tbl(l).unit_of_measure        );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).source_document_code   ',
                p_var_value      => p_ship_ln_tbl(l).source_document_code   );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).unit_price             ',
                p_var_value      => p_ship_ln_tbl(l).unit_price             );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).quantity               ',
                p_var_value      => p_ship_ln_tbl(l).quantity               );
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).primary_quantity       ',
                p_var_value      => p_ship_ln_tbl(l).primary_quantity        );--BUG#8928845
        END LOOP;
    END IF;

    -- Bug #8304106
    l_debug_info := 'Check profile QP_LICENSED_FOR_PRODUCT';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info);

    FND_PROFILE.get('QP_LICENSED_FOR_PRODUCT',l_qp_license);

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name       => 'l_qp_license',
        p_var_value      => l_qp_license);

    -- In order to work for LCM QP_LICENSED_FOR_PRODUCT
    -- profile must be set for Purchasing application (PO).
    IF (l_qp_license IS NULL OR l_qp_license <> 'PO') THEN
        FND_MESSAGE.SET_NAME('INL','INL_ERR_NO_CH_LN_QP_LICENSE');
        FND_MSG_PUB.ADD;
        RAISE L_FND_EXC_ERROR;
    END IF;

    l_debug_info := 'Call QP_PRICE_REQUEST_CONTEXT.set_request_id';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info);

    -- Enable the price engine to identify the data in the
    -- pricing temporary tables that belongs to the current
    -- pricing engine call.
    QP_PRICE_REQUEST_CONTEXT.set_request_id;

    l_debug_info := 'Initialize the Global HDR Structure and QP Context';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info);

    Populate_HeaderRecord(
        p_org_id                => p_ship_ln_group_rec.org_id,
        p_order_header_id       => p_ship_ln_group_rec.po_header_id, -- Bug#13092165
        p_supplier_id           => p_ship_ln_group_rec.supplier_id,
        p_supplier_site_id      => p_ship_ln_group_rec.supplier_site_id,
        p_creation_date         => p_ship_ln_group_rec.creation_date,
        p_order_type            => p_ship_ln_group_rec.order_type,
        p_ship_to_location_id   => p_ship_ln_group_rec.ship_to_location_id,
        p_ship_to_org_id        => p_ship_ln_group_rec.ship_to_org_id,
        p_shipment_header_id    => p_ship_ln_group_rec.shipment_header_id,
        p_hazard_class          => p_ship_ln_group_rec.hazard_class,
        p_hazard_code           => p_ship_ln_group_rec.hazard_code,
        p_shipped_date          => p_ship_ln_group_rec.shipped_date,
        p_shipment_num          => p_ship_ln_group_rec.shipment_num,
        p_carrier_method        => p_ship_ln_group_rec.carrier_method,
        p_packaging_code        => p_ship_ln_group_rec.packaging_code,
        p_freight_carrier_code  => p_ship_ln_group_rec.freight_code,
        p_freight_terms         => p_ship_ln_group_rec.freight_terms,
        p_currency_code         => p_ship_ln_group_rec.currency_code,
        p_rate                  => p_ship_ln_group_rec.rate,
        p_rate_type             => p_ship_ln_group_rec.rate_type,
        p_source_org_id         => p_ship_ln_group_rec.source_org_id,
        p_expected_receipt_date => p_ship_ln_group_rec.expected_receipt_date,
        x_return_status         => l_return_status);

    l_debug_info := 'Call QP_ATTR_MAPPING_PUB.Build_Contexts for HEADER';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info);

    -- Build Attributes Mapping Contexts for HEADER
    QP_ATTR_MAPPING_PUB.Build_Contexts(
        p_request_type_code => p_ship_ln_group_rec.request_type,
        p_line_index        => l_line_index,
        p_pricing_type_code => 'H',
        p_check_line_flag   => 'N',
        p_pricing_event     => p_ship_ln_group_rec.pricing_event,
        x_pass_line         => l_pass_line);

    l_request_type_code_tbl(l_line_index)       := p_ship_ln_group_rec.request_type;
    l_line_id_tbl(l_line_index)                 := NVL(p_ship_ln_group_rec.p_order_header_id,p_ship_ln_group_rec.shipment_header_id);-- header id
    l_line_index_tbl(l_line_index)              := l_line_index; -- Request Line Index
    l_line_type_code_tbl(l_line_index)          := 'ORDER'; -- LINE or ORDER(Summary Line)
    l_pricinl_effective_date_tbl(l_line_index)  := trunc(SYSDATE);-- Pricing as of effective date
    l_active_date_first_tbl(l_line_index)       := NULL; -- Can be Ordered Date or Ship Date
    l_active_date_second_tbl(l_line_index)      := NULL; -- Can be Ordered Date or Ship Date
    l_active_date_first_type_tbl(l_line_index)  := NULL; -- ORD/SHIP
    l_active_date_second_type_tbl(l_line_index) := NULL; -- ORD/SHIP
    l_line_unit_price_tbl(l_line_index)         := NULL; -- Unit Price
    l_line_quantity_tbl(l_line_index)           := NULL; -- Ordered Quantity
    l_line_uom_code_tbl(l_line_index)           := NULL; -- Ordered UOM Code
    l_currency_code_tbl(l_line_index)           := p_ship_ln_group_rec.currency_code;-- Currency Code
    l_price_flag_tbl(l_line_index)              := 'Y'; -- Price Flag can have 'Y', 'N'(No pricing),'P'(Phase)
    l_usage_pricing_type_tbl(l_line_index)      := QP_PREQ_GRP.g_regular_usage_type;
    l_priced_quantity_tbl(l_line_index)         := NULL;
    l_priced_uom_code_tbl(l_line_index)         := NULL;
    l_unit_price_tbl(l_line_index)              := NULL;
    l_percent_price_tbl(l_line_index)           := NULL;
    l_uom_quantity_tbl(l_line_index)            := NULL;
    l_adjusted_unit_price_tbl(l_line_index)     := NULL;
    l_upd_adjusted_unit_price_tbl(l_line_index) := NULL;
    l_processed_flag_tbl(l_line_index)          := NULL;
    l_processing_order_tbl(l_line_index)        := NULL;
    l_pricing_status_code_tbl(l_line_index)     := QP_PREQ_GRP.g_status_unchanged;
    l_pricing_status_text_tbl(l_line_index)     := NULL;
    l_rounding_flag_tbl(l_line_index)           := NULL;
    l_rounding_factor_tbl(l_line_index)         := NULL;
    l_qualifiers_exist_flag_tbl(l_line_index)   := 'N';
    l_pricing_attrs_exist_flag_tbl(l_line_index):= 'N';
    l_price_list_id_tbl(l_line_index)           := -9999;
    l_pl_validated_flag_tbl(l_line_index)       := 'N';
    l_price_request_code_tbl(l_line_index)      := NULL;
    l_line_category_tbl(l_line_index)           := NULL;
    l_list_price_overide_flag_tbl(l_line_index) := 'O';
    l_line_index := l_line_index + 1;

    l_debug_info := 'Loop to initialize the Global LINE Structure and QP Context';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name,
                                   p_debug_info => l_debug_info);

    FOR j IN 1..p_ship_ln_tbl.COUNT LOOP
        l_debug_info := 'Call Populate_LineRecord';
        INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                       p_procedure_name => l_proc_name,
                                       p_debug_info => l_debug_info);

        -- Populate the Global Line Structure
        Populate_LineRecord(
            p_order_line_id             => p_ship_ln_tbl(j).order_line_id,
            p_item_revision             => p_ship_ln_tbl(j).item_revision,
            p_item_id                   => p_ship_ln_tbl(j).item_id,
            p_category_id               => p_ship_ln_tbl(j).category_id,
            p_supplier_item_num         => p_ship_ln_tbl(j).supplier_item_num,
            p_agreement_type            => p_ship_ln_tbl(j).agreement_type,
            p_agreement_id              => p_ship_ln_tbl(j).agreement_id,
            p_agreement_line_id         => p_ship_ln_tbl(j).agreement_line_id,
            p_supplier_id               => p_ship_ln_tbl(j).supplier_id,
            p_supplier_site_id          => p_ship_ln_tbl(j).supplier_site_id,
            p_ship_to_location_id       => p_ship_ln_tbl(j).ship_to_location_id,
            p_ship_to_org_id            => p_ship_ln_tbl(j).ship_to_org_id,
            p_rate                      => p_ship_ln_tbl(j).rate,
            p_rate_type                 => p_ship_ln_tbl(j).rate_type,
            p_currency_code             => p_ship_ln_tbl(j).currency_code,
            p_need_by_date              => p_ship_ln_tbl(j).need_by_date,
            p_shipment_line_id          => p_ship_ln_tbl(j).shipment_line_id,
            p_primary_unit_of_measure   => p_ship_ln_tbl(j).primary_unit_of_measure,
            p_to_organization_id        => p_ship_ln_tbl(j).to_organization_id,
            p_unit_of_measure           => p_ship_ln_tbl(j).unit_of_measure,
            p_source_document_code      => p_ship_ln_tbl(j).source_document_code,
            p_quantity                  => p_ship_ln_tbl(j).quantity,
            x_return_status             => l_return_status);

        l_debug_info := 'Call QP_ATTR_MAPPING_PUB.Build_Contexts for each LINE';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info     => l_debug_info);

        -- Build Attributes Mapping Contexts for LINES
        QP_ATTR_MAPPING_PUB.Build_Contexts(
            p_request_type_code  => p_ship_ln_group_rec.request_type,
            p_line_index         => l_line_index,
            p_pricing_type_code  => 'L',
            p_check_line_flag    => 'N',
            p_pricing_event      => p_ship_ln_group_rec.pricing_event,
            x_pass_line          => l_pass_line);

        l_request_type_code_tbl(l_line_index)       := p_ship_ln_group_rec.request_type;
        l_line_id_tbl(l_line_index)                 := NVL(p_ship_ln_tbl(j).order_line_id,p_ship_ln_tbl(j).shipment_line_id);   -- order line id
        l_line_index_tbl(l_line_index)              := l_line_index; -- Request Line Index
        l_line_type_code_tbl(l_line_index)          := 'LINE'; -- LINE or ORDER(Summary Line)
        l_pricinl_effective_date_tbl(l_line_index)  := trunc(p_ship_ln_tbl(j).need_by_date);-- Pricing as of effective date
        l_active_date_first_tbl(l_line_index)       := NULL; -- Can be Ordered Date or Ship Date
        l_active_date_second_tbl(l_line_index)      := NULL; -- Can be Ordered Date or Ship Date
        l_active_date_first_type_tbl(l_line_index)  := NULL; -- ORD/SHIP
        l_active_date_second_type_tbl(l_line_index) := NULL; -- ORD/SHIP
        l_line_unit_price_tbl(l_line_index)         := p_ship_ln_tbl(j).unit_price; -- Unit Price
        l_line_quantity_tbl(l_line_index)           := NVL(p_ship_ln_tbl(j).quantity, 1); -- Ordered Quantity
        l_line_uom_code_tbl(l_line_index)           := p_ship_ln_tbl(j).unit_of_measure; -- Ordered UOM Code
        l_currency_code_tbl(l_line_index)           := p_ship_ln_tbl(j).currency_code; -- Currency Code
        l_price_flag_tbl(l_line_index)              := 'Y'; -- Price Flag can have 'Y', 'N'(No pricing), 'P'(Phase)
        l_usage_pricing_type_tbl(l_line_index)      := QP_PREQ_GRP.g_regular_usage_type;
        l_priced_quantity_tbl(l_line_index)         := NVL(p_ship_ln_tbl(j).quantity, 1);
        l_priced_uom_code_tbl(l_line_index)         := p_ship_ln_tbl(j).unit_of_measure;
        l_unit_price_tbl(l_line_index)              := p_ship_ln_tbl(j).unit_price;
        l_percent_price_tbl(l_line_index)           := NULL;
        l_uom_quantity_tbl(l_line_index)            := NULL;
        l_adjusted_unit_price_tbl(l_line_index)     := NULL;
        l_upd_adjusted_unit_price_tbl(l_line_index) := NULL;
        l_processed_flag_tbl(l_line_index)          := NULL;
        l_processing_order_tbl(l_line_index)        := NULL;
        l_pricing_status_code_tbl(l_line_index)     := QP_PREQ_GRP.g_status_unchanged;
        l_pricing_status_text_tbl(l_line_index)     := NULL;
        l_rounding_flag_tbl(l_line_index)           := NULL;
        l_rounding_factor_tbl(l_line_index)         := NULL;
        l_qualifiers_exist_flag_tbl(l_line_index)   := 'N';
        l_pricing_attrs_exist_flag_tbl(l_line_index):= 'N';
        l_price_list_id_tbl(l_line_index)           := -9999;
        l_pl_validated_flag_tbl(l_line_index)       := 'N';
        l_price_request_code_tbl(l_line_index)      := NULL;
        l_line_category_tbl(l_line_index)           := NULL;
        l_list_price_overide_flag_tbl(l_line_index) := 'O'; -- Override price

        -- Prepare Shipment Line Qty for multiplying with Freight Charges
        l_line_quantities(p_ship_ln_tbl(j).shipment_line_id) := NVL(p_ship_ln_tbl(j).quantity, 1);
        l_line_1ary_quantities(p_ship_ln_tbl(j).shipment_line_id) := NVL(p_ship_ln_tbl(j).primary_quantity, 1); --BUG#8928845

        -- Setting the currency code to be used when creting Charges for Line level
        l_currency_code(p_ship_ln_tbl(j).shipment_line_id) := p_ship_ln_tbl(j).currency_code;
        l_line_index := l_line_index + 1;
    END LOOP;

    l_debug_info := 'Call QP_PREQ_GRP.INSERT_LINES2 to insert into qp_preq_lines_tmp table';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name,
                                   p_debug_info => l_debug_info);

    -- Insert the request lines into the pricing temporary table qp_preq_lines_tmp
    QP_PREQ_GRP.INSERT_LINES2(
        p_line_index               => l_line_index_tbl,
        p_line_type_code           => l_line_type_code_tbl,
        p_pricing_effective_date   => l_pricinl_effective_date_tbl,
        p_active_date_first        => l_active_date_first_tbl,
        p_active_date_first_type   => l_active_date_first_type_tbl,
        p_active_date_second       => l_active_date_second_tbl,
        p_active_date_second_type  => l_active_date_second_type_tbl,
        p_line_quantity            => l_line_quantity_tbl,
        p_line_uom_code            => l_line_uom_code_tbl,
        p_request_type_code        => l_request_type_code_tbl,
        p_priced_quantity          => l_priced_quantity_tbl,
        p_priced_uom_code          => l_priced_uom_code_tbl,
        p_currency_code            => l_currency_code_tbl,
        p_unit_price               => l_unit_price_tbl,
        p_percent_price            => l_percent_price_tbl,
        p_uom_quantity             => l_uom_quantity_tbl,
        p_adjusted_unit_price      => l_adjusted_unit_price_tbl,
        p_upd_adjusted_unit_price  => l_upd_adjusted_unit_price_tbl,
        p_processed_flag           => l_processed_flag_tbl,
        p_price_flag               => l_price_flag_tbl,
        p_line_id                  => l_line_id_tbl,
        p_processing_order         => l_processing_order_tbl,
        p_pricing_status_code      => l_pricing_status_code_tbl,
        p_pricing_status_text      => l_pricing_status_text_tbl,
        p_rounding_flag            => l_rounding_flag_tbl,
        p_rounding_factor          => l_rounding_factor_tbl,
        p_qualifiers_exist_flag    => l_qualifiers_exist_flag_tbl,
        p_pricing_attrs_exist_flag => l_pricing_attrs_exist_flag_tbl,
        p_price_list_id            => l_price_list_id_tbl,
        p_validated_flag           => l_pl_validated_flag_tbl,
        p_price_request_code       => l_price_request_code_tbl,
        p_usage_pricing_type       => l_usage_pricing_type_tbl,
        p_line_category            => l_line_category_tbl,
        p_line_unit_price          => l_line_unit_price_tbl,
        p_list_price_override_flag => l_list_price_overide_flag_tbl,
        x_status_code              => x_return_status,
        x_status_text              => l_return_status_text);

    IF x_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        FND_MESSAGE.SET_NAME('INL','INL_ERR_QP_PRICE_API');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_return_status_text);
        FND_MSG_PUB.ADD;
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = L_FND_RET_STS_ERROR THEN
        FND_MESSAGE.SET_NAME('INL','INL_ERR_QP_PRICE_API');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_return_status_text);
        FND_MSG_PUB.ADD;
        RAISE L_FND_EXC_ERROR;
    END IF;

    l_debug_info := 'Populate Control Record variables for Pricing Request Call';
    INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                   p_procedure_name => l_proc_name,
                                   p_debug_info => l_debug_info);

    l_control_rec.calculate_flag         := 'Y';
    l_control_rec.simulation_flag        := 'N';
    l_control_rec.pricing_event          := p_ship_ln_group_rec.pricing_event;
    l_control_rec.temp_table_insert_flag := 'N';
    l_control_rec.check_cust_view_flag   := 'N';
    l_control_rec.request_type_code      := p_ship_ln_group_rec.request_type;
    l_control_rec.rounding_flag          := 'Q';
    l_control_rec.use_multi_currency     := 'Y';
    l_control_rec.user_conversion_rate   := p_ship_ln_group_rec.rate;
    l_control_rec.user_conversion_type   := p_ship_ln_group_rec.rate_type;
    l_control_rec.function_currency      := p_ship_ln_group_rec.currency_code;
    l_control_rec.get_freight_flag       := 'N';

    l_debug_info := 'Call QP_PREQ_PUB.PRICE_REQUEST';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info
    );

    QP_PREQ_PUB.PRICE_REQUEST(
        p_control_rec       => l_control_rec,
        x_return_status     => x_return_status,
        x_return_status_Text=> l_return_status_Text
    );

    IF x_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
        FND_MESSAGE.SET_NAME('INL','INL_ERR_QP_PRICE_API');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_return_status_text);
        FND_MSG_PUB.ADD;
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = L_FND_RET_STS_ERROR THEN
        FND_MESSAGE.SET_NAME('INL','INL_ERR_QP_PRICE_API');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_return_status_text);
        FND_MSG_PUB.ADD;
        RAISE L_FND_EXC_ERROR;
    END IF;

    -- Access the QP qp_ldets_v view to retrieve the freight charge info.
    FOR k IN 1..l_line_index-1 LOOP
        l_debug_info := 'Access the QP qp_ldets_v view to retrieve the freight charge info.';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => l_debug_info
        );
        SELECT charge_type_code,
               order_qty_adj_amt freight_charge,
               pricing_status_code,
               pricing_status_text,
               modifier_level_code,
               override_flag,
               operand_calculation_code --Bug#8928845
        BULK COLLECT INTO l_freight_charge_rec_tbl
        FROM  qp_ldets_v
        WHERE line_index = k
        AND   list_line_type_code = 'FREIGHT_CHARGE'
        AND   applied_flag = 'Y';

        l_qp_cost_table(k).line_index := l_line_index_tbl(k);
        l_qp_cost_table(k).base_unit_price := l_unit_price_tbl(k);
        l_qp_cost_table(k).freight_charge_rec_tbl := l_freight_charge_rec_tbl;
        l_qp_cost_table(k).line_id := l_line_id_tbl(k);

        l_debug_info := 'Get pricing_status_code and pricing_status_text from qp_preq_lines_tmp';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => l_debug_info
        );

        SELECT pricing_status_code,
               pricing_status_text
          INTO l_qp_cost_table(k).pricing_status_code,
               l_qp_cost_table(k).pricing_status_text
          FROM qp_preq_lines_tmp
         WHERE line_index = k;
    END LOOP;

    l_debug_info := 'Check if the l_qp_cost_table has records';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info
    );

    IF l_qp_cost_table.COUNT < 1 THEN
        l_debug_info := 'l_qp_cost_table has no records';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => l_debug_info
        );
    END IF;

    l_debug_info := 'Iterate through all returned l_qp_cost_table records';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info
    );

    FOR k IN 1 .. l_qp_cost_table.COUNT LOOP
        BEGIN
            IF l_qp_cost_table(k).freight_charge_rec_tbl.COUNT < 1 THEN
                l_debug_info := 'The l_no_freight_charge has no records';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_debug_info => l_debug_info
                );
                RAISE l_no_freight_charge;
            END IF;

            l_freight_charge_tbl := l_qp_cost_table(k).freight_charge_rec_tbl;
            l_debug_info := 'Iterate through all returned l_freight_charge_tbl records';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_proc_name,
                p_debug_info => l_debug_info
            );

            FOR n IN 1 .. l_freight_charge_tbl.COUNT LOOP
                l_debug_info := 'Call PON_CF_TYPE_GRP.get_cost_factor_details';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_debug_info => l_debug_info
                );

               INL_LOGGING_PVT.Log_Variable (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name       => 'l_freight_charge_tbl(n).charge_type_code',
                    p_var_value      => nvl(l_freight_charge_tbl(n).charge_type_code,'NULL'));

                -- Bug #9274538
                SELECT COUNT(1)
                INTO  l_qp_charge_lookup
                FROM  qp_charge_lookup qcl
                WHERE qcl.lookup_code = l_freight_charge_tbl(n).charge_type_code
                AND   qcl.lookup_type = 'FREIGHT_CHARGES_TYPE';

                IF NVL(l_qp_charge_lookup,0) = 0 THEN
                    SELECT COUNT(1)
                    INTO  l_qp_charge_lookup
                    FROM  qp_charge_lookup qcl
                    WHERE qcl.lookup_code = l_freight_charge_tbl(n).charge_type_code
                    AND   qcl.lookup_type = 'FREIGHT_COST_TYPE';
                END IF;

               INL_LOGGING_PVT.Log_Variable (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name       => 'l_qp_charge_lookup',
                    p_var_value      => NVL(l_qp_charge_lookup,0));

                IF (NVL(l_qp_charge_lookup,0) > 0) THEN
                    l_debug_info := 'LCM only accepts cost factors for charges. Charge ' || l_freight_charge_tbl(n).charge_type_code||
                                    ' cannot be generated.' ;
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => l_debug_info);
                ELSE -- Bug #9274538

                    BEGIN
                        l_cost_factor_details := PON_CF_TYPE_GRP.get_cost_factor_details(TO_NUMBER(l_freight_charge_tbl(n).charge_type_code));
                    EXCEPTION
                        WHEN OTHERS THEN
                            l_cost_factor_valid := 'F';
                            l_debug_info := 'Cost Factor ' || l_freight_charge_tbl(n).charge_type_code ||
                                    ' is not valid and will not be generated.' ;
                            INL_LOGGING_PVT.Log_Statement (
                                p_module_name => g_module_name,
                                p_procedure_name => l_proc_name,
                                p_debug_info => l_debug_info);
                    END;

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name    => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name       => 'l_cost_factor_valid',
                        p_var_value      => l_cost_factor_valid);

                    IF l_cost_factor_valid = 'T' THEN -- Bug #9274538

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name       => 'l_freight_charge_tbl(n).freight_charge',
                            p_var_value      => l_freight_charge_tbl(n).freight_charge);

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name       => 'l_freight_charge_tbl(n).pricing_status_code',
                            p_var_value      => nvl(l_freight_charge_tbl(n).pricing_status_code,'NULL'));

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name       => 'l_freight_charge_tbl(n).pricing_status_text',
                            p_var_value      => nvl(l_freight_charge_tbl(n).pricing_status_text,'NULL'));

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name       => 'l_freight_charge_tbl(n).modifier_level_code',
                            p_var_value      => nvl(l_freight_charge_tbl(n).modifier_level_code,'NULL'));

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name       => 'l_freight_charge_tbl(n).override_flag',
                            p_var_value      => nvl(l_freight_charge_tbl(n).override_flag,'NULL'));

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name       => 'l_freight_charge_tbl(n).operand_calculation_code',
                            p_var_value      => nvl(l_freight_charge_tbl(n).operand_calculation_code,'NULL'));

                       INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name       => 'l_cost_factor_details.price_element_type_id',
                            p_var_value      => l_cost_factor_details.price_element_type_id);

                       INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name       => 'l_cost_factor_details.cost_component_class_id',
                            p_var_value      => l_cost_factor_details.cost_component_class_id);

                       INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name       => 'l_cost_factor_details.cost_analysis_code',
                            p_var_value      => nvl(l_cost_factor_details.cost_analysis_code,'NULL'));

                       INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name       => 'l_cost_factor_details.cost_acquisition_code',
                            p_var_value      => nvl(l_cost_factor_details.cost_acquisition_code,'NULL'));

                       INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name       => 'l_cost_factor_details.price_element_code',
                            p_var_value      => nvl(l_cost_factor_details.price_element_code,'NULL'));

                       INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name       => 'l_cost_factor_details.pricing_basis',
                            p_var_value      => nvl(l_cost_factor_details.pricing_basis,'NULL'));

                       INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name       => 'l_cost_factor_details.allocation_basis',
                            p_var_value      => nvl(l_cost_factor_details.allocation_basis,'NULL'));

                       INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_var_name       => 'l_cost_factor_details.invoice_line_type',
                            p_var_value      => nvl(l_cost_factor_details.invoice_line_type,'NULL'));

                        IF l_freight_charge_tbl(n).modifier_level_code = 'LINE' THEN
                            INL_LOGGING_PVT.Log_Variable (
                                 p_module_name    => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name       => 'k',
                                 p_var_value      => k);

                            INL_LOGGING_PVT.Log_Variable (
                                p_module_name    => g_module_name,
                                p_procedure_name => l_proc_name,
                                p_var_name       => 'l_qp_cost_table(k).line_id',
                                p_var_value      => l_qp_cost_table(k).line_id);

                            INL_LOGGING_PVT.Log_Variable (
                                p_module_name    => g_module_name,
                                p_procedure_name => l_proc_name,
                                p_var_name       => 'l_line_quantities(l_qp_cost_table(k).line_id',
                                p_var_value      => to_char(l_line_quantities(l_qp_cost_table(k).line_id)));

                            INL_LOGGING_PVT.Log_Variable (
                                p_module_name    => g_module_name,
                                p_procedure_name => l_proc_name,
                                p_var_name       => 'l_line_1ary_quantities(l_qp_cost_table(k).line_id',
                                p_var_value      => to_char(l_line_1ary_quantities(l_qp_cost_table(k).line_id)));
                        END IF;

                        l_debug_info := 'Populate the x_charge_ln_tbl type table';
                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name => g_module_name,
                            p_procedure_name => l_proc_name,
                            p_debug_info => l_debug_info);

                        -- Populate x_charge_ln_tbl
                        x_charge_ln_tbl(l_charge_ln_index).charge_line_type_id := l_cost_factor_details.price_element_type_id;
                        x_charge_ln_tbl(l_charge_ln_index).landed_cost_flag := 'Y';
                        x_charge_ln_tbl(l_charge_ln_index).to_parent_table_id := l_qp_cost_table(k).line_id;
                        x_charge_ln_tbl(l_charge_ln_index).update_allowed := l_freight_charge_tbl(n).override_flag;
                        x_charge_ln_tbl(l_charge_ln_index).source_code := 'QP';

                        IF l_freight_charge_tbl(n).modifier_level_code = 'ORDER' THEN
                            x_charge_ln_tbl(l_charge_ln_index).to_parent_table_name := l_to_parent_tbl_name_order;
                            x_charge_ln_tbl(l_charge_ln_index).charge_amt := l_freight_charge_tbl(n).freight_charge;
                            x_charge_ln_tbl(l_charge_ln_index).currency_code := p_ship_ln_group_rec.currency_code;
                        ELSIF l_freight_charge_tbl(n).modifier_level_code = 'LINE' THEN
                            x_charge_ln_tbl(l_charge_ln_index).to_parent_table_name := l_to_parent_tbl_name_line;
                            x_charge_ln_tbl(l_charge_ln_index).currency_code := l_currency_code(l_qp_cost_table(k).line_id);
                            IF l_freight_charge_tbl(n).operand_calculation_code = '%' THEN --Bug#8928845
                                x_charge_ln_tbl(l_charge_ln_index).charge_amt := l_freight_charge_tbl(n).freight_charge * l_line_quantities(l_qp_cost_table(k).line_id);
                            ELSIF l_freight_charge_tbl(n).operand_calculation_code = 'AMT' THEN --Bug#8928845
                                x_charge_ln_tbl(l_charge_ln_index).charge_amt := l_freight_charge_tbl(n).freight_charge * l_line_1ary_quantities(l_qp_cost_table(k).line_id); --Bug#8928845
                            ELSIF l_freight_charge_tbl(n).operand_calculation_code = 'LUMPSUM' THEN --Bug#9059678
                                x_charge_ln_tbl(l_charge_ln_index).charge_amt := l_freight_charge_tbl(n).freight_charge * l_line_quantities(l_qp_cost_table(k).line_id); --Bug#9059678
                            ELSE --Bug#8928845
                                x_charge_ln_tbl(l_charge_ln_index).charge_amt := l_freight_charge_tbl(n).freight_charge; --Bug#8928845
                            END IF; --Bug#8928845
                        END IF;
                        l_charge_ln_index := l_charge_ln_index + 1;
                    END IF; -- Bug#9274538
                END IF; -- Bug#9274538
            END LOOP;
        EXCEPTION
            WHEN l_no_freight_charge THEN
                l_debug_info := 'No QP charge for the line : ' || l_qp_cost_table(k).line_id;
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_debug_info => l_debug_info
                );
        END;
    END LOOP;

    -- End the procedure
    INL_LOGGING_PVT.Log_EndProc (p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name);
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        --raised expected error: assume raiser already pushed onto the stack
        l_exception_msg := FND_MSG_PUB.get(p_msg_index => FND_MSG_PUB.G_LAST,
                                           p_encoded => 'F');
        x_return_status := L_FND_RET_STS_ERROR;
        -- Push the po_return_msg onto msg list and message stack
        FND_MESSAGE.set_name('INL', 'INL_ERR_QP_PRICE_API');
        FND_MESSAGE.set_token('ERROR_TEXT',l_exception_msg);

        l_debug_info := 'Erro: ' || sqlerrm;
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => l_debug_info);

    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        --raised unexpected error: assume raiser already pushed onto the stack
        l_exception_msg := FND_MSG_PUB.get(p_msg_index => FND_MSG_PUB.G_LAST,
                                           p_encoded => 'F');
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        -- Push the po_return_msg onto msg list and message stack
        FND_MESSAGE.set_name('INL', 'INL_ERR_QP_PRICE_API');
        FND_MESSAGE.set_token('ERROR_TEXT',l_exception_msg);

        l_debug_info := 'Erro: ' || sqlerrm;
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => l_debug_info);

    WHEN OTHERS THEN
        --unexpected error from this procedure: get SQLERRM
        l_exception_msg := FND_MESSAGE.get;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        -- Push the po_return_msg onto msg list and message stack
        FND_MESSAGE.set_name('INL', 'INL_ERR_QP_PRICE_API');
        FND_MESSAGE.set_token('ERROR_TEXT',l_exception_msg);

        l_debug_info := 'Erro: ' || sqlerrm;
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => l_debug_info);

END Get_ChargesFromQP;

-- Utility name : Prepare_AndGetChargesFromQP
-- Type       : Private
-- Function   : Encapsulate the necessary steps to integrate with QP
--              and return a table with all generated Charge Lines.
-- Pre-reqs   : None
-- Parameters :
-- IN         :   p_ship_header_rec   ship_header_rec_tp
--                p_ship_ln_group_tbl ship_ln_group_tbl_tp
--                p_ship_ln_tbl       ship_ln_tbl_tp
--
-- OUT            x_charge_ln_tbl       OUT NOCOPY charge_ln_tbl
--                x_return_status       OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Prepare_AndGetChargesFromQP(
    p_ship_header_rec   IN  inl_ship_headers%ROWTYPE,
    p_ship_ln_group_tbl IN  ship_ln_group_tbl_tp,
    p_ship_ln_tbl       IN  ship_ln_tbl_tp,
    x_charge_ln_tbl     IN OUT NOCOPY charge_ln_tbl, -- Bug #10100951
    x_return_status     OUT NOCOPY VARCHAR2
) IS
    l_proc_name  CONSTANT VARCHAR2(30) := 'Prepare_AndGetChargesFromQP';
    l_debug_info VARCHAR2(240);
    l_return_status VARCHAR2(1);
    l_exception_msg VARCHAR2(2000);

    l_ship_ln_group_rec ship_ln_group_rec;
    l_ship_ln_tbl       ship_ln_tbl;
    l_qp_curr_conv_date date;
    l_get_group_info    VARCHAR2(1) := 'Y';
    l_get_rcv_head_info VARCHAR2(1) := 'Y';
    ln_index            NUMBER;
BEGIN
    -- Begin the procedure
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name);
    -- Init return status
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Populate a Shipment Line Group record type';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_debug_info => l_debug_info);
    --  Populate header dependent variables

    l_qp_curr_conv_date                         := p_ship_header_rec.ship_date;
    l_ship_ln_group_rec.ship_to_location_id     := p_ship_header_rec.location_id;
    l_ship_ln_group_rec.ship_to_org_id          := p_ship_header_rec.org_id;

    l_ship_ln_group_rec.currency_code           := FND_PROFILE.VALUE('INL_QP_CURRENCY_CODE');
    IF l_ship_ln_group_rec.currency_code IS NULL
    THEN
        SELECT gl.currency_code
        INTO l_ship_ln_group_rec.currency_code
        FROM gl_sets_of_books gl,
            financials_system_parameters fsp
        WHERE gl.set_of_books_id = fsp.set_of_books_id
        AND fsp.org_id = p_ship_header_rec.org_id;
    END IF;
    l_ship_ln_group_rec.rate                    := NULL;
    l_ship_ln_group_rec.rate_type               := NULL;
    l_ship_ln_group_rec.qp_curr_conv_type       := NVL(FND_PROFILE.VALUE('INL_QP_CURRENCY_CONVERSION_TYPE'), 'Corporate');

    ln_index := p_ship_ln_tbl.FIRST;
    FOR i IN 1 .. p_ship_ln_group_tbl.COUNT LOOP
        l_debug_info := 'Populate line group dependent variables';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => l_debug_info);

        l_ship_ln_group_rec.org_id                  := PO_MOAC_UTILS_PVT.get_current_org_id;
        l_ship_ln_group_rec.p_order_header_id       := NULL;
        l_ship_ln_group_rec.order_type              := NULL;
        l_ship_ln_group_rec.shipment_header_id      := p_ship_ln_group_tbl(i).ship_line_group_id;
        l_ship_ln_group_rec.ship_line_group_id      := p_ship_ln_group_tbl(i).ship_line_group_id;
        FOR l IN ln_index..p_ship_ln_tbl.COUNT LOOP
            l_debug_info := 'Populate lines dependent variables ('||l||')';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_proc_name,
                p_debug_info => l_debug_info);

            l_ship_ln_tbl(l - ln_index + 1).order_line_id           := NULL;
            l_ship_ln_tbl(l - ln_index + 1).agreement_type          := NULL;
            l_ship_ln_tbl(l - ln_index + 1).agreement_id            := NULL;
            l_ship_ln_tbl(l - ln_index + 1).agreement_line_id       := NULL;
            l_ship_ln_tbl(l - ln_index + 1).category_id             := NULL;
            l_ship_ln_tbl(l - ln_index + 1).ship_to_location_id     := p_ship_header_rec.location_id;
            l_ship_ln_tbl(l - ln_index + 1).ship_to_org_id          := p_ship_header_rec.org_id;
            l_ship_ln_tbl(l - ln_index + 1).to_organization_id      := p_ship_header_rec.organization_id;

            l_ship_ln_tbl(l - ln_index + 1).primary_unit_of_measure := p_ship_ln_tbl(l).primary_uom_code;
            l_ship_ln_tbl(l - ln_index + 1).unit_of_measure         := p_ship_ln_tbl(l).txn_uom_code;
            l_ship_ln_tbl(l - ln_index + 1).source_document_code    := p_ship_ln_group_tbl(i).src_type_code;

            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'l_ship_ln_group_rec.currency_code',
                p_var_value      => l_ship_ln_group_rec.currency_code);

            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).currency_code',
                p_var_value      => p_ship_ln_tbl(l).currency_code);

            IF p_ship_ln_tbl(l).currency_code = l_ship_ln_group_rec.currency_code
            THEN
                l_ship_ln_tbl(l - ln_index + 1).rate                 := p_ship_ln_tbl(l).currency_conversion_rate;
                l_ship_ln_tbl(l - ln_index + 1).unit_price           := p_ship_ln_tbl(l).txn_unit_price;
            ELSE

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name       => 'l_ship_ln_group_rec.qp_curr_conv_type',
                    p_var_value      => l_ship_ln_group_rec.qp_curr_conv_type);

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name       => 'l_qp_curr_conv_date',
                    p_var_value      => l_qp_curr_conv_date);

                l_ship_ln_tbl(l - ln_index + 1).unit_price := inl_landedcost_pvt.Converted_Amt (
                                                        p_ship_ln_tbl(l).txn_unit_price,
                                                        p_ship_ln_tbl(l).currency_code,
                                                        l_ship_ln_group_rec.currency_code,
                                                        l_ship_ln_group_rec.qp_curr_conv_type,
                                                        l_qp_curr_conv_date,
                                                        l_ship_ln_tbl(l - ln_index + 1).rate);
            END IF;
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'l_ship_ln_tbl(l - ln_index + 1).rate',
                p_var_value      => l_ship_ln_tbl(l - ln_index + 1).rate);

            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'l_ship_ln_tbl(l - ln_index + 1).unit_price',
                p_var_value      => l_ship_ln_tbl(l - ln_index + 1).unit_price);


            l_ship_ln_tbl(l - ln_index + 1).rate_type := p_ship_ln_tbl(l).currency_conversion_type;

            l_ship_ln_tbl(l - ln_index + 1).currency_code := l_ship_ln_group_rec.currency_code;

            l_ship_ln_tbl(l - ln_index + 1).shipment_line_id := p_ship_ln_tbl(l).ship_line_id;

            l_ship_ln_tbl(l - ln_index + 1).quantity := p_ship_ln_tbl(l).txn_qty;

            l_ship_ln_tbl(l - ln_index + 1).primary_quantity := p_ship_ln_tbl(l).primary_qty;   --BUG#8928845

            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_group_tbl(i).src_type_code',
                p_var_value      => p_ship_ln_group_tbl(i).src_type_code);

            IF p_ship_ln_group_tbl(i).src_type_code = 'PO'
            THEN
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name       => 'l_ship_ln_group_rec.supplier_id',
                    p_var_value      => l_ship_ln_group_rec.supplier_id);

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name       => 'p_ship_ln_tbl(l).ship_line_source_id',
                    p_var_value      => p_ship_ln_tbl(l).ship_line_source_id);

                IF l_get_group_info = 'Y' THEN
                    l_ship_ln_group_rec.request_type     := 'PO';
                    l_ship_ln_group_rec.pricing_event    := 'PO_RECEIPT';
--Bug#9660056
                    SELECT
                        ph.po_header_id,  -- Bug#13092165
                        NVL(s.vendor_id, ph.vendor_id) as vendor_id,
                        NVL(s.vendor_site_id, ph.vendor_site_id) as vendor_site_id,
                        ph.creation_date,
                        ph.org_id,
                        pll.shipment_num,
                        NVL(pll.need_by_date,SYSDATE) need_by_date, --Bug#9570880
                        pl.item_revision,
                        pl.item_id
                    INTO
                        l_ship_ln_group_rec.po_header_id, -- Bug#13092165
                        l_ship_ln_group_rec.supplier_id,
                        l_ship_ln_group_rec.supplier_site_id,
                        l_ship_ln_group_rec.creation_date,
                        l_ship_ln_group_rec.source_org_id,
                        l_ship_ln_group_rec.shipment_num,
                        l_ship_ln_tbl(l - ln_index + 1).need_by_date,
                        l_ship_ln_tbl(l - ln_index + 1).item_revision,
                        l_ship_ln_tbl(l - ln_index + 1).item_id
                    FROM
                        po_lines_all pl,
                        po_headers_all ph,
                        po_line_locations_all pll,
                        inl_simulations s
                    WHERE
                        ph.po_header_id = pll.po_header_id
                        AND pll.line_location_id = p_ship_ln_tbl(l).ship_line_source_id
                        AND pl.po_line_id = pll.po_line_id
                        AND s.parent_table_name(+) = 'PO_HEADERS'
                        AND s.parent_table_id  (+) = ph.po_header_id --for the use of outer join
                        AND s.simulation_id    (+) = p_ship_header_rec.simulation_id;
--Bug#9660056
                    l_get_group_info := 'N';
                ELSE
                    SELECT
                        NVL(pll.need_by_date,SYSDATE) need_by_date, --Bug#9570880
                        pl.item_revision,
                        pl.item_id
                    INTO
                        l_ship_ln_tbl(l - ln_index + 1).need_by_date,
                        l_ship_ln_tbl(l - ln_index + 1).item_revision,
                        l_ship_ln_tbl(l - ln_index + 1).item_id
                    FROM po_lines_all pl,
                         po_line_locations_all pll
                    WHERE pl.po_line_id = pll.po_line_id
                    AND pll.line_location_id = p_ship_ln_tbl(l).ship_line_source_id;
                END IF;
            END IF;

            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_header_rec.rcv_enabled_flag',
                p_var_value      => p_ship_header_rec.rcv_enabled_flag);


            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name       => 'p_ship_ln_tbl(l).ship_line_id',
                p_var_value      => p_ship_ln_tbl(l).ship_line_id);

            IF NVL(p_ship_header_rec.rcv_enabled_flag,'Y') = 'Y'     -- dependence
            THEN
                BEGIN
                    IF  l_get_rcv_head_info  = 'Y' THEN
                        --There is a meaningful diference in performance using po_line_location_id
                        -- and this column can be used for PO only
                        IF p_ship_ln_group_tbl(i).src_type_code = 'PO' THEN
                        --There is a meaningful diference in performance using po_line_location_id
                        -- and this column can be used for PO only
                            SELECT
                                rsh.hazard_class,
                                rsh.hazard_code,
                                rsh.shipped_date,
                                rsh.carrier_method,
                                rsh.packaging_code,
                                DECODE(p_ship_header_rec.simulation_id, NULL,
                                rsh.freight_carrier_code,
                                (SELECT s.freight_code
                                 FROM inl_simulations s
                                 WHERE s.simulation_id = p_ship_header_rec.simulation_id)) AS freight_code, -- Bug# 9279355
                                rsh.freight_terms,
                                rsh.expected_receipt_date,
                                rsl.vendor_item_num
                            INTO
                                l_ship_ln_group_rec.hazard_class           ,
                                l_ship_ln_group_rec.hazard_code            ,
                                l_ship_ln_group_rec.shipped_date           ,
                                l_ship_ln_group_rec.carrier_method         ,
                                l_ship_ln_group_rec.packaging_code         ,
                                l_ship_ln_group_rec.freight_code           ,
                                l_ship_ln_group_rec.freight_terms          ,
                                l_ship_ln_group_rec.expected_receipt_date  ,
                                l_ship_ln_tbl(l - ln_index + 1).supplier_item_num
                            FROM rcv_transactions rtr,
                                 rcv_shipment_headers rsh,
                                 rcv_shipment_lines rsl
                            WHERE rsh.shipment_header_id = rtr.shipment_header_id
                            AND rsl.shipment_line_id = rtr.shipment_line_id
                            AND rtr.lcm_shipment_line_id = p_ship_ln_tbl(l).ship_line_id
                            AND rtr.po_line_location_id = p_ship_ln_tbl(l).ship_line_source_id;
                        ELSIF p_ship_ln_group_tbl(i).src_type_code = 'IR'
                        THEN
                            SELECT
                                rsh.hazard_class,
                                rsh.hazard_code,
                                rsh.shipped_date,
                                rsh.carrier_method,
                                rsh.packaging_code,
                                rsh.freight_carrier_code,
                                rsh.freight_terms,
                                rsh.expected_receipt_date,
                                rsl.vendor_item_num
                            INTO
                                l_ship_ln_group_rec.hazard_class           ,
                                l_ship_ln_group_rec.hazard_code            ,
                                l_ship_ln_group_rec.shipped_date           ,
                                l_ship_ln_group_rec.carrier_method         ,
                                l_ship_ln_group_rec.packaging_code         ,
                                l_ship_ln_group_rec.freight_code   ,
                                l_ship_ln_group_rec.freight_terms          ,
                                l_ship_ln_group_rec.expected_receipt_date  ,
                                l_ship_ln_tbl(l - ln_index + 1).supplier_item_num
                            FROM rcv_transactions rtr,
                                 rcv_shipment_headers rsh,
                                 rcv_shipment_lines rsl
                            WHERE rsh.shipment_header_id = rtr.shipment_header_id
                            AND rsl.shipment_line_id = rtr.shipment_line_id
                            AND rtr.lcm_shipment_line_id = p_ship_ln_tbl(l).ship_line_id
                            AND rtr.shipment_line_id = p_ship_ln_tbl(l).ship_line_source_id;
                        ELSE
                            SELECT
                                rsh.hazard_class,
                                rsh.hazard_code,
                                rsh.shipped_date,
                                rsh.carrier_method,
                                rsh.packaging_code,
                                rsh.freight_carrier_code,
                                rsh.freight_terms,
                                rsh.expected_receipt_date,
                                rsl.vendor_item_num
                            INTO
                                l_ship_ln_group_rec.hazard_class           ,
                                l_ship_ln_group_rec.hazard_code            ,
                                l_ship_ln_group_rec.shipped_date           ,
                                l_ship_ln_group_rec.carrier_method         ,
                                l_ship_ln_group_rec.packaging_code         ,
                                l_ship_ln_group_rec.freight_code   ,
                                l_ship_ln_group_rec.freight_terms          ,
                                l_ship_ln_group_rec.expected_receipt_date  ,
                                l_ship_ln_tbl(l - ln_index + 1).supplier_item_num
                            FROM rcv_transactions rtr,
                                 rcv_shipment_headers rsh,
                                 rcv_shipment_lines rsl
                            WHERE rsh.shipment_header_id = rtr.shipment_header_id
                            AND rsl.shipment_line_id = rtr.shipment_line_id
                            AND rtr.lcm_shipment_line_id = p_ship_ln_tbl(l).ship_line_id;
                        END IF;
                        l_get_rcv_head_info  := 'Y';
                    ELSE
                        --There is a meaningful diference in performance using po_line_location_id
                        -- and this column can be used for PO only
                        IF p_ship_ln_group_tbl(i).src_type_code = 'PO'
                        THEN
                            SELECT rsl.vendor_item_num
                            INTO l_ship_ln_tbl(l - ln_index + 1).supplier_item_num
                            FROM rcv_transactions rtr,
                                 rcv_shipment_lines rsl
                            WHERE rsl.shipment_line_id   = rtr.shipment_line_id
                            AND rtr.lcm_shipment_line_id = p_ship_ln_tbl(l).ship_line_id
                            AND rtr.po_line_location_id  = p_ship_ln_tbl(l).ship_line_source_id;
                        ELSE
                            SELECT
                                rsl.vendor_item_num
                            INTO
                                l_ship_ln_tbl(l - ln_index + 1).supplier_item_num
                            FROM rcv_transactions rtr,
                                 rcv_shipment_lines rsl
                            WHERE rsl.shipment_line_id   = rtr.shipment_line_id
                            AND rtr.lcm_shipment_line_id = p_ship_ln_tbl(l).ship_line_id;
                        END IF;
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL;
                END;
            END IF;
            l_ship_ln_tbl(l - ln_index + 1).supplier_id             := l_ship_ln_group_rec.supplier_id;
            l_ship_ln_tbl(l - ln_index + 1).supplier_site_id        := l_ship_ln_group_rec.supplier_site_id;

            l_ship_ln_group_rec.request_type     := NVL(l_ship_ln_group_rec.request_type, 'PO');
            l_ship_ln_group_rec.pricing_event    := NVL(l_ship_ln_group_rec.pricing_event,'PO_RECEIPT');

            IF l < p_ship_ln_tbl.COUNT
                AND p_ship_ln_tbl(l+1).ship_line_group_id <> p_ship_ln_group_tbl(i).ship_line_group_id
            THEN
                ln_index := l + 1;
                exit;
            END IF;
        END LOOP;

        l_debug_info := 'Call Get_ChargesFromQP(...)';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_proc_name,
            p_debug_info => l_debug_info);

        -- Get Charges from QP
        Get_ChargesFromQP(
            p_ship_ln_group_rec => l_ship_ln_group_rec,
            p_ship_ln_tbl       => l_ship_ln_tbl,
            x_charge_ln_tbl     => x_charge_ln_tbl,
            x_return_status     => l_return_status);

        -- If any errors happen abort the process.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;

        l_get_group_info := 'Y';
        l_get_rcv_head_info  := 'Y';

    END LOOP;

    -- End the procedure
    INL_LOGGING_PVT.Log_EndProc (p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name);
EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        --raised expected error: assume raiser already pushed onto the stack
        l_exception_msg := FND_MSG_PUB.get(p_msg_index => FND_MSG_PUB.G_LAST,
                                           p_encoded => 'F');
        x_return_status := L_FND_RET_STS_ERROR;
        -- Push the po_return_msg onto msg list and message stack
        FND_MESSAGE.set_name('INL', 'INL_ERR_QP_PRICE_API');
        FND_MESSAGE.set_token('ERROR_TEXT',l_exception_msg);
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        --raised unexpected error: assume raiser already pushed onto the stack
        l_exception_msg := FND_MSG_PUB.get(p_msg_index => FND_MSG_PUB.G_LAST,
                                           p_encoded => 'F');
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        -- Push the po_return_msg onto msg list and message stack
        FND_MESSAGE.set_name('INL', 'INL_ERR_QP_PRICE_API');
        FND_MESSAGE.set_token('ERROR_TEXT',l_exception_msg);
    WHEN OTHERS THEN
        --unexpected error from this procedure: get SQLERRM
        l_exception_msg := FND_MESSAGE.get;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        -- Push the po_return_msg onto msg list and message stack
        FND_MESSAGE.set_name('INL', 'INL_ERR_QP_PRICE_API');
        FND_MESSAGE.set_token('ERROR_TEXT',l_exception_msg);
END Prepare_AndGetChargesFromQP;

-- Bug# 9279355
-- Utility name   : Get_SimulShipLine
-- Type       : Private
-- Function   : Get the simulated ship line id correspondent to a given
--              shipment line id
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_line_id IN NUMBER
--
-- OUT        : x_return_status IN OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Get_SimulShipLine(
    p_ship_line_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER IS

    l_func_name CONSTANT VARCHAR2(30) := 'Get_SimulShipLine';
    l_debug_info VARCHAR2(400);
    l_result VARCHAR2(1) := FND_API.G_TRUE;
    l_return_status VARCHAR2(1) := FND_API.G_TRUE;
    l_ship_line_source_id NUMBER;
    l_ship_line_src_type_code VARCHAR2(30);
    l_simul_ship_line_id NUMBER;
BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_func_name) ;

    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_func_name,
        p_var_name       => 'p_ship_line_id',
        p_var_value      => p_ship_line_id);

    SELECT sl.ship_line_src_type_code,
           sl.ship_line_source_id
    INTO l_ship_line_src_type_code,
         l_ship_line_source_id
    FROM inl_ship_lines sl
    WHERE sl.ship_line_id = p_ship_line_id;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_func_name,
        p_var_name       => 'l_ship_line_src_type_code',
        p_var_value      => l_ship_line_src_type_code);

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_func_name,
        p_var_name       => 'l_ship_line_source_id',
        p_var_value      => l_ship_line_source_id);

    l_debug_info := 'Get the simulated Shipment Line Id';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_func_name,
        p_debug_info       => l_debug_info);

    BEGIN
        SELECT sl.ship_line_id
        INTO l_simul_ship_line_id
        FROM   inl_simulations s,
               inl_ship_headers_all sh,
               inl_ship_lines_all sl
        WHERE  -- s.parent_table_name = DECODE(sh.interface_source_code,'PO','PO_HEADERS','-1')
               sh.interface_source_code = DECODE(s.parent_table_name,'PO_HEADERS','PO',
                                          DECODE(s.parent_table_name, 'PO_RELEASES', 'PO', '-1')) -- Bug 14280113
        -- AND    s.parent_table_id = sh.interface_source_line_id
        AND sh.interface_source_line_id = DECODE(s.parent_table_name,'PO_HEADERS', s.parent_table_id,
                                                  DECODE(s.parent_table_name,'PO_RELEASES',(SELECT po_header_id
                                                                                            FROM po_releases_all
                                                                                            WHERE po_release_id = s.parent_table_id), -1)) -- Bug 14280113
        AND    s.simulation_id = sh.simulation_id
        AND    s.firmed_flag = 'Y'
        AND    sh.ship_header_id = sl.ship_header_id
        AND    sl.ship_line_src_type_code = l_ship_line_src_type_code
        AND    sl.ship_line_source_id = l_ship_line_source_id
        AND    s.parent_table_revision_num = (
                   SELECT MAX(s1.parent_table_revision_num)
                   FROM   inl_simulations s1
                   WHERE  -- s1.parent_table_name = DECODE(sh.interface_source_code,'PO','PO_HEADERS','-1')
                          sh.interface_source_code = DECODE(s1.parent_table_name,'PO_HEADERS','PO',
                                                     DECODE(s1.parent_table_name, 'PO_RELEASES', 'PO', '-1')) -- Bug 14280113
                   -- AND    s1.parent_table_id = sh.interface_source_line_id
                   AND    sh.interface_source_line_id = DECODE(s1.parent_table_name,'PO_HEADERS', s1.parent_table_id,
                                                               DECODE(s1.parent_table_name,'PO_RELEASES',(SELECT pr.po_header_id
                                                                                                          FROM po_releases_all pr,
                                                                                                               po_line_locations_all pl
                                                                                                          WHERE pr.po_release_id = s1.parent_table_id
                                                                                                          AND pr.po_release_id = pl.po_release_id
                                                                                                          AND pl.line_location_id = l_ship_line_source_id), -1))-- Bug 14280113
                   AND    s1.firmed_flag = 'Y');
    EXCEPTION
        -- Shipment Line could not have simulated shipment line
        WHEN NO_DATA_FOUND THEN NULL;
    END;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name    => g_module_name,
        p_procedure_name => l_func_name,
        p_var_name       => 'l_simul_ship_line_id',
        p_var_value      => l_simul_ship_line_id);

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_func_name);

    RETURN l_simul_ship_line_id;

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_func_name);
        RETURN NULL;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_func_name);
        RETURN NULL;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_func_name);
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_func_name);
        END IF;
        RETURN NULL;
END Get_SimulShipLine;

-- Bug# 9279355
-- Utility name : Get_ChargesFromSimul
-- Type       : Private
-- Function   : Creates charge lines for a given Shipment, based on charge
--              line allocations of corresponding simulated shipment
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id IN NUMBER
--              x_charge_ln_tbl IN OUT NOCOPY charge_ln_tbl,
--
-- OUT          x_return_status OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Get_ChargesFromSimul(p_ship_header_id IN NUMBER,
                               x_charge_ln_tbl IN OUT NOCOPY charge_ln_tbl,
                               x_return_status OUT NOCOPY VARCHAR2) IS

    l_proc_name CONSTANT VARCHAR2(30) := 'Get_ChargesFromSimul';
    l_debug_info VARCHAR2(200);

    CURSOR c_ship_ln(p_ship_header_id NUMBER) IS
        SELECT sl.ship_line_id,
               sl.primary_qty,
               sl.org_id
        FROM inl_ship_lines_all sl
        WHERE sl.ship_header_id = p_ship_header_id;

    TYPE ship_ln_list_type IS TABLE OF c_ship_ln%ROWTYPE;
    ship_ln_list ship_ln_list_type;

    CURSOR c_charge_ln(p_simul_ship_line_id NUMBER) IS
        SELECT cl.charge_line_type_id,
               a.allocation_amt/sl.primary_qty unit_charge_amt,
               cl.update_allowed,
               cl.source_code,
               cl.party_id,
               cl.party_site_id,
               cl.trx_business_category,
               cl.intended_use,
               cl.product_fiscal_class,
               cl.product_category,
               cl.product_type,
               cl.user_def_fiscal_class,
               cl.tax_classification_code,
               cl.assessable_value,
               cl.ship_from_party_id,
               cl.ship_from_party_site_id,
               cl.ship_to_organization_id,
               cl.ship_to_location_id,
               cl.bill_from_party_id,
               cl.bill_from_party_site_id,
               cl.bill_to_organization_id,
               cl.bill_to_location_id,
               cl.poa_party_id,
               cl.poa_party_site_id,
               cl.poo_organization_id,
               cl.poo_location_id
        FROM inl_charge_lines cl,
             inl_ship_lines_all sl,
             inl_allocations a
        WHERE cl.charge_line_id = a.from_parent_table_id
        AND sl.ship_line_id = a.ship_line_id
        AND from_parent_table_name = 'INL_CHARGE_LINES'
        AND a.ship_line_id = p_simul_ship_line_id;

    TYPE charge_ln_list_type IS TABLE OF c_charge_ln%ROWTYPE;
    charge_ln_list charge_ln_list_type;

    l_simul_ship_line_id NUMBER;
    l_return_status VARCHAR2(1);
    l_func_currency_code VARCHAR2(15);
    l_charge_ln_index NUMBER := NVL(x_charge_ln_tbl.count,0) + 1;

BEGIN
    -- Begin the procedure
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name);

    -- Init return status
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(
        p_module_name => g_module_name,
        p_procedure_name => l_proc_name,
        p_var_name => 'p_ship_header_id',
        p_var_value => p_ship_header_id);

    OPEN c_ship_ln(p_ship_header_id);
        FETCH c_ship_ln BULK COLLECT INTO ship_ln_list;
    CLOSE c_ship_ln;

    IF NVL(ship_ln_list.COUNT,0) > 0 THEN
        FOR i IN 1 .. ship_ln_list.COUNT
        LOOP
            l_simul_ship_line_id := Get_SimulShipLine(
                                       p_ship_line_id => ship_ln_list(i).ship_line_id,
                                       x_return_status => l_return_status);

            -- If any errors happen abort the process.
            IF l_return_status = L_FND_RET_STS_ERROR THEN
                RAISE L_FND_EXC_ERROR;
            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                RAISE L_FND_EXC_UNEXPECTED_ERROR;
            END IF;

            INL_LOGGING_PVT.Log_Variable(
                p_module_name => g_module_name,
                p_procedure_name => l_proc_name,
                p_var_name => 'l_simul_ship_line_id',
                p_var_value => l_simul_ship_line_id);

            IF l_simul_ship_line_id IS NOT NULL THEN
                IF l_func_currency_code IS NULL THEN
                    SELECT gl.currency_code
                    INTO l_func_currency_code
                    FROM gl_sets_of_books gl,
                         financials_system_parameters fsp
                    WHERE gl.set_of_books_id = fsp.set_of_books_id
                    AND fsp.org_id = ship_ln_list(i).org_id;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'l_func_currency_code',
                        p_var_value => l_func_currency_code);
                END IF;

                OPEN c_charge_ln(l_simul_ship_line_id);
                FETCH c_charge_ln BULK COLLECT INTO charge_ln_list;
                CLOSE c_charge_ln;

                INL_LOGGING_PVT.Log_Variable(
                    p_module_name => g_module_name,
                    p_procedure_name => l_proc_name,
                    p_var_name => 'charge_ln_list.COUNT,',
                    p_var_value => NVL(charge_ln_list.COUNT,0));

               FOR j IN 1 .. charge_ln_list.COUNT
                LOOP
                    l_debug_info := 'Collect data to be passed to Insert_ChargeLines' ;
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_debug_info => l_debug_info);

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'ship_ln_list(i).primary_qty',
                        p_var_value => ship_ln_list(i).primary_qty);

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'charge_ln_list(j).unit_charge_amt',
                        p_var_value => charge_ln_list(j).unit_charge_amt);

                    --Collect data to be passed to INL_CHARGE_PVT.Insert_ChargeLines:
                   -- x_charge_ln_tbl(l_charge_ln_index).ship_header_id := p_ship_header_id;
                    x_charge_ln_tbl(l_charge_ln_index).charge_line_type_id := charge_ln_list(j).charge_line_type_id;
                    x_charge_ln_tbl(l_charge_ln_index).landed_cost_flag := 'Y';
                    x_charge_ln_tbl(l_charge_ln_index).update_allowed := charge_ln_list(j).update_allowed;
                    x_charge_ln_tbl(l_charge_ln_index).source_code :=  'SIMUL';--charge_ln_list(j).source_code;
                    x_charge_ln_tbl(l_charge_ln_index).charge_amt := ship_ln_list(i).primary_qty * charge_ln_list(j).unit_charge_amt;
                    x_charge_ln_tbl(l_charge_ln_index).currency_code := l_func_currency_code;
                    x_charge_ln_tbl(l_charge_ln_index).currency_conversion_type := NULL;
                    x_charge_ln_tbl(l_charge_ln_index).currency_conversion_date := NULL;
                    x_charge_ln_tbl(l_charge_ln_index).currency_conversion_rate := NULL;
                    x_charge_ln_tbl(l_charge_ln_index).party_id := charge_ln_list(j).party_id;
                    x_charge_ln_tbl(l_charge_ln_index).party_site_id := charge_ln_list(j).party_site_id;
                    x_charge_ln_tbl(l_charge_ln_index).trx_business_category    := charge_ln_list(j).trx_business_category;
                    x_charge_ln_tbl(l_charge_ln_index).intended_use := charge_ln_list(j).intended_use;
                    x_charge_ln_tbl(l_charge_ln_index).product_fiscal_class := charge_ln_list(j).product_fiscal_class;
                    x_charge_ln_tbl(l_charge_ln_index).product_category := charge_ln_list(j).product_category;
                    x_charge_ln_tbl(l_charge_ln_index).product_type := charge_ln_list(j).product_type;
                    x_charge_ln_tbl(l_charge_ln_index).user_def_fiscal_class    := charge_ln_list(j).user_def_fiscal_class;
                    x_charge_ln_tbl(l_charge_ln_index).tax_classification_code := charge_ln_list(j).tax_classification_code;
                    x_charge_ln_tbl(l_charge_ln_index).assessable_value := charge_ln_list(j).assessable_value;
                    x_charge_ln_tbl(l_charge_ln_index).ship_from_party_id := charge_ln_list(j).ship_from_party_id;
                    x_charge_ln_tbl(l_charge_ln_index).ship_from_party_site_id := charge_ln_list(j).ship_from_party_site_id;
                    x_charge_ln_tbl(l_charge_ln_index).ship_to_organization_id := charge_ln_list(j).ship_to_organization_id;
                    x_charge_ln_tbl(l_charge_ln_index).ship_to_location_id := charge_ln_list(j).ship_to_location_id;
                    x_charge_ln_tbl(l_charge_ln_index).bill_from_party_id := charge_ln_list(j).bill_from_party_id;
                    x_charge_ln_tbl(l_charge_ln_index).bill_from_party_site_id := charge_ln_list(j).bill_from_party_site_id;
                    x_charge_ln_tbl(l_charge_ln_index).bill_to_organization_id := charge_ln_list(j).bill_to_organization_id;
                    x_charge_ln_tbl(l_charge_ln_index).bill_to_location_id := charge_ln_list(j).bill_to_location_id;
                    x_charge_ln_tbl(l_charge_ln_index).poa_party_id := charge_ln_list(j).poa_party_id;
                    x_charge_ln_tbl(l_charge_ln_index).poa_party_site_id    := charge_ln_list(j).poa_party_site_id;
                    x_charge_ln_tbl(l_charge_ln_index).poo_organization_id := charge_ln_list(j).poo_organization_id;
                    x_charge_ln_tbl(l_charge_ln_index).poo_location_id := charge_ln_list(j).poo_location_id;
                    x_charge_ln_tbl(l_charge_ln_index).to_parent_table_name := 'INL_SHIP_LINES';
                    x_charge_ln_tbl(l_charge_ln_index).to_parent_table_id := ship_ln_list(i).ship_line_id;

                    INL_LOGGING_PVT.Log_Variable(
                        p_module_name => g_module_name,
                        p_procedure_name => l_proc_name,
                        p_var_name => 'x_charge_ln_tbl(l_charge_ln_index).charge_amt',
                        p_var_value => x_charge_ln_tbl(l_charge_ln_index).charge_amt);

                    -- If any errors happen abort the process.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                            RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                    l_charge_ln_index := l_charge_ln_index + 1;
                END LOOP;
            END IF;
        END LOOP;
    END IF;
    -- End the procedure
    INL_LOGGING_PVT.Log_EndProc (p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name);

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_proc_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level =>FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name       => g_pkg_name,
                p_procedure_name => l_proc_name);
        END IF;
END Get_ChargesFromSimul;

-- API name   : Generate_Charges
-- Type       : Private
-- Function   : Generate Charge Lines automatically from a source that
--              can be the QP or any other logic defined inside the Charges Hook.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version       IN NUMBER      Required
--              p_init_msg_list     IN VARCHAR2    Optional  Default = FND_API.G_FALSE
--              p_commit            IN VARCHAR2    Optional  Default = FND_API.G_FALSE
--              p_ship_header_id    IN NUMBER      Required
--
-- OUT          x_return_status     OUT NOCOPY VARCHAR2
--              x_msg_count         OUT NOCOPY  NUMBER
--              x_msg_data          OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Generate_Charges(
    p_api_version    IN NUMBER,
    p_init_msg_list  IN VARCHAR2 := L_FND_FALSE,
    p_commit         IN VARCHAR2 := L_FND_FALSE,
    p_ship_header_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'Generate_Charges';
    l_api_version CONSTANT NUMBER := 1.0;
    l_debug_info VARCHAR2(240);
    l_return_status VARCHAR2(1);
    l_override_default_processing BOOLEAN := FALSE;
    l_firm_simulation NUMBER;

    l_ship_ln_group_rec ship_ln_group_rec;
    l_ship_ln_group_id_tbl DBMS_SQL.number_table;
    l_association_tbl DBMS_SQL.number_table;
    l_charge_line_tbl DBMS_SQL.number_table;

    l_charge_ln_tbl charge_ln_tbl;

    l_currency_conversion_rate NUMBER;
    l_count_dual_assoc NUMBER;

    -- ln group
    l_ship_ln_group_tbl ship_ln_group_tbl_tp;

    -- ship ln
    l_ship_ln_tbl ship_ln_tbl_tp;

    -- header
    l_ship_header_rec inl_ship_headers%ROWTYPE;
    l_allocation_basis_uom_class VARCHAR2(30);
    l_alloc_bas_uom_class_err_flag VARCHAR2(1):='N';

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name);

    -- Standard Start of API savepoint
    SAVEPOINT Generate_Charges_PVT;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        p_current_version_number => l_api_version,
        p_caller_version_number => p_api_version,
        p_api_name => l_api_name,
        p_pkg_name => g_pkg_name)
    THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check for profile setup.     Bug#8898208
    FND_PROFILE.GET('INL_VOLUME_UOM_CLASS',l_allocation_basis_uom_class);
    IF l_allocation_basis_uom_class IS NULL
    THEN
        FND_MESSAGE.SET_NAME('INL','INL_ERR_CHK_VOL_UOM_CLASS_PROF');
        FND_MSG_PUB.Add;
        l_alloc_bas_uom_class_err_flag:='Y';
    END IF;
    FND_PROFILE.GET('INL_QUANTITY_UOM_CLASS',l_allocation_basis_uom_class);
    IF l_allocation_basis_uom_class IS NULL
    THEN
        FND_MESSAGE.SET_NAME('INL','INL_ERR_CHK_QTY_UOM_CLASS_PROF');
        FND_MSG_PUB.Add;
        l_alloc_bas_uom_class_err_flag:='Y';
    END IF;
    FND_PROFILE.GET('INL_WEIGHT_UOM_CLASS',l_allocation_basis_uom_class);
    IF l_allocation_basis_uom_class IS NULL
    THEN
        FND_MESSAGE.SET_NAME('INL','INL_ERR_CHK_WEI_UOM_CLASS_PROF');
        FND_MSG_PUB.Add;
        l_alloc_bas_uom_class_err_flag:='Y';
    END IF;
    IF l_alloc_bas_uom_class_err_flag = 'Y'
    THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Check for profile setup.     Bug#8898208

    --  Initialize API return status to success
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'Getting all Shipment Line Groups from a given Shipment Header ID';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info);

    -- Error if exist any estimated charge associated to different Shipment
    -- this situation is not covered yet
    l_debug_info := 'Verifying if there is charge with dual association.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info);

    SELECT COUNT(*)
    INTO l_count_dual_assoc
    FROM inl_associations ias,
         inl_charge_lines icl
    WHERE ias.from_parent_table_id = icl.charge_line_id
      AND ias.from_parent_table_name = 'INL_CHARGE_LINES'
      AND ias.ship_header_id = p_ship_header_id
      AND EXISTS (SELECT 1
                  FROM inl_associations ia2
                  WHERE ia2.from_parent_table_name = 'INL_CHARGE_LINES'
                  AND ia2.from_parent_table_id = ias.from_parent_table_id
                  AND ia2.ship_header_id <> p_ship_header_id);
    IF NVL(l_count_dual_assoc,0) > 0 THEN
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name       => 'l_count_dual_assoc',
            p_var_value      => l_count_dual_assoc);

        l_debug_info := 'No data found in Shipment Line Groups / Shipment Line. Raising expected error.';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info);

        FND_MESSAGE.SET_NAME('INL','INL_ERR_CHAR_LN_GEN');
        FND_MSG_PUB.ADD;
        RAISE L_FND_EXC_ERROR;
    END IF;

    --as recomended in TDD: Delete all CHARGES and ASSOCIATIONS
    l_debug_info := 'Deleting CHARGES and ASSOCIATIONS.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info);
/* --Bug#9660056
    DELETE
    FROM inl_charge_lines icl
    WHERE icl.charge_line_id
       IN (SELECT ias.from_parent_table_id
           FROM inl_associations ias
           WHERE  ias.from_parent_table_name = 'INL_CHARGE_LINES'
           AND ias.ship_header_id = p_ship_header_id);
*/
--Bug#9660056
    DELETE
    FROM inl_charge_lines icl
    WHERE
       EXISTS ( SELECT 1
                FROM  inl_associations ias
                WHERE ias.from_parent_table_name   = 'INL_CHARGE_LINES'
                AND   ias.ship_header_id              = p_ship_header_id
                AND   ias.from_parent_table_id        = icl.charge_line_id );
--Bug#9660056

    l_debug_info := 'Deleted '|| SQL%ROWCOUNT||' CHARGE LINES.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info);

    DELETE
    FROM inl_associations ias
    WHERE  ias.from_parent_table_name = 'INL_CHARGE_LINES'
    AND ias.ship_header_id = p_ship_header_id;

    l_debug_info := 'Deleted '|| SQL%ROWCOUNT||' ASSOCIATION LINES.';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name => g_module_name,
        p_procedure_name => l_api_name,
        p_debug_info => l_debug_info);

    --prepare hook information
    SELECT *
    INTO l_ship_header_rec
    FROM inl_ship_headers sh
    WHERE sh.ship_header_id = p_ship_header_id;

    SELECT *
    BULK COLLECT INTO l_ship_ln_group_tbl
    FROM inl_ship_line_groups lg
    WHERE lg.ship_header_id = p_ship_header_id
    ORDER BY ship_line_group_id; -- line in the same order

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name       => 'l_ship_ln_group_tbl.COUNT',
        p_var_value      => l_ship_ln_group_tbl.COUNT);

    SELECT *
    BULK COLLECT INTO l_ship_ln_tbl
    FROM inl_adj_ship_lines_v sl
    WHERE sl.ship_header_id = p_ship_header_id
    ORDER BY ship_line_group_id, ship_line_num;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_api_name,
        p_var_name       => 'l_ship_ln_tbl.COUNT',
        p_var_value      => l_ship_ln_tbl.COUNT);


    IF NVL(l_ship_ln_group_tbl.COUNT, 0) = 0 OR
       NVL(l_ship_ln_tbl.COUNT, 0) = 0 THEN
        l_debug_info := 'No data found in Shipment Lines or Shipment Line Groups. Raising expected error.';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info);
        FND_MESSAGE.SET_NAME('INL','INL_ERR_CHAR_LN_GEN');
        FND_MSG_PUB.ADD;
        RAISE L_FND_EXC_ERROR;
    ELSE
        inl_custom_pub.Get_Charges(
            p_ship_header_rec             => l_ship_header_rec,
            p_ship_ln_group_tbl           => l_ship_ln_group_tbl,
            p_ship_ln_tbl_tp              => l_ship_ln_tbl,
            x_charge_ln_tbl               => l_charge_ln_tbl,
            x_override_default_processing => l_override_default_processing,
            x_return_status               => l_return_status);

        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_api_name,
            p_var_name       => 'l_charge_ln_tbl.COUNT',
            p_var_value      => l_charge_ln_tbl.COUNT);

        -- If any errors happen abort the process.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
            RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
            RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Check whether Charges Hook override
        -- the default Generate Charges processing.
        IF NOT (l_override_default_processing) THEN
            l_debug_info := 'l_override_default_processing is false';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info);

            l_debug_info := 'Check if Shipment is simulated';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info);

            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_api_name,
                p_var_name       => 'l_ship_header_rec.simulation_id',
                p_var_value      => l_ship_header_rec.simulation_id);

            IF l_ship_header_rec.simulation_id IS NULL THEN  -- Bug# 9279355
            -- Is not a simulated shipment
                l_debug_info := 'Shipment is no simulated, then checking its simulations.';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_api_name,
                    p_debug_info => l_debug_info);

                SELECT COUNT(*)
                INTO l_firm_simulation
                FROM inl_simulations s,
                     inl_ship_headers_all sh,
                     inl_ship_lines_all sl2, -- Simulated Shipment Line
                     inl_ship_lines_all sl1  -- ELC Shipment Line
                WHERE s.simulation_id = sh.simulation_id
                AND s.firmed_flag = 'Y'
                AND sh.ship_header_id = sl2.ship_header_id
                -- AND sl2.ship_line_src_type_code = DECODE(s.parent_table_name,'PO_HEADERS','PO','-1') -- Bug 14280113
                AND sl2.ship_line_src_type_code = DECODE(s.parent_table_name,'PO_HEADERS','PO',
                                                         DECODE(s.parent_table_name,'PO_RELEASES','PO', '-1'))-- Bug 14280113
                AND sl2.ship_line_source_id = sl1.ship_line_source_id
                AND sl2.ship_header_id <> sl1.ship_header_id
                AND sl1.ship_header_id = p_ship_header_id;

                INL_LOGGING_PVT.Log_Variable (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_api_name,
                    p_var_name       => 'l_firm_simulation',
                    p_var_value      => l_firm_simulation);

                IF NVL(l_firm_simulation,0) > 0 THEN
                    l_debug_info := 'Exists Firmed Simulation for the Shipment. Get charges from Simulated Shipment';
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_api_name,
                        p_debug_info => l_debug_info);

                    Get_ChargesFromSimul(p_ship_header_id => p_ship_header_id,
                                         x_charge_ln_tbl => l_charge_ln_tbl,
                                         x_return_status => l_return_status);

                    -- If any errors happen abort the process.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                ELSE
                    l_debug_info := 'There is NO Firmed Simulation for the Shipment. Get charges from QP';
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_api_name,
                        p_debug_info => l_debug_info);

                    l_debug_info := 'Call Prepare_AndGetChargesFromQP(...)';
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name => g_module_name,
                        p_procedure_name => l_api_name,
                        p_debug_info => l_debug_info);

                    -- Get Charges from QP
                    Prepare_AndGetChargesFromQP(
                        p_ship_header_rec   => l_ship_header_rec,
                        p_ship_ln_group_tbl => l_ship_ln_group_tbl,
                        p_ship_ln_tbl       => l_ship_ln_tbl,
                        x_charge_ln_tbl     => l_charge_ln_tbl,
                        x_return_status     => l_return_status);

                    -- If any errors happen abort the process.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                        RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                        RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
            ELSE
                l_debug_info := 'Simulated Shipment. Call Prepare_AndGetChargesFromQP(...)';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name => g_module_name,
                    p_procedure_name => l_api_name,
                    p_debug_info => l_debug_info);

                -- Get Charges from QP
                Prepare_AndGetChargesFromQP(
                    p_ship_header_rec   => l_ship_header_rec,
                    p_ship_ln_group_tbl => l_ship_ln_group_tbl,
                    p_ship_ln_tbl       => l_ship_ln_tbl,
                    x_charge_ln_tbl     => l_charge_ln_tbl,
                    x_return_status     => l_return_status);

                -- If any errors happen abort the process.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                    RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                    RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        END IF;

        l_debug_info := 'Check whether Charge Lines were generated and populated into l_charge_ln_tbl';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name => g_module_name,
            p_procedure_name => l_api_name,
            p_debug_info => l_debug_info);

        -- Bug #8304106
        -- Check if Charges got generated by QP
        IF l_charge_ln_tbl.COUNT < 1 AND NOT(l_override_default_processing) AND
           NVL(l_firm_simulation,0) = 0 THEN
            l_debug_info := 'No Charges have been generated by Advanced Pricing';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info);
            FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_NO_CH_LN_QP_CALL') ;
            FND_MSG_PUB.ADD;
            RAISE L_FND_EXC_ERROR;
        ELSIF l_charge_ln_tbl.COUNT < 1 AND NOT(l_override_default_processing) AND
           NVL(l_firm_simulation,0) > 0 THEN
            -- Charges have not been copied from FIRMED simulated shipment
            l_debug_info := 'Charges have not been copied from FIRMED simulated shipment';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info);
            FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_NO_CH_LN_FIRMED_SHIP') ;
            FND_MSG_PUB.ADD;
            RAISE L_FND_EXC_ERROR;
        ELSIF l_charge_ln_tbl.COUNT < 1 AND l_override_default_processing THEN
            l_debug_info := 'No Charges have been generated by the Custom Hook';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name => g_module_name,
                p_procedure_name => l_api_name,
                p_debug_info => l_debug_info);
            FND_MESSAGE.SET_NAME ('INL', 'INL_ERR_NO_CH_LN_HOOK_CALL') ;
            FND_MSG_PUB.ADD;
            RAISE L_FND_EXC_ERROR;
        -- Otherwise charges were generated and now we can process them
        ELSE
          -- Iterate through all generated Charges to insert
          -- into INL Charge Lines and INL Associations table
          FOR j IN 1 .. l_charge_ln_tbl.COUNT LOOP
              l_debug_info := 'Call Insert_ChargeLines(...)';
              INL_LOGGING_PVT.Log_Statement (p_module_name => g_module_name,
                                           p_procedure_name => l_api_name,
                                           p_debug_info => l_debug_info);

               INL_LOGGING_PVT.Log_Variable (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_api_name,
                    p_var_name       => 'l_charge_ln_tbl(j).charge_amt',
                    p_var_value      => l_charge_ln_tbl(j).charge_amt);

              Insert_ChargeLines(
                p_ship_header_id           => p_ship_header_id,
                p_charge_line_type_id      => l_charge_ln_tbl(j).charge_line_type_id,
                p_landed_cost_flag         => l_charge_ln_tbl(j).landed_cost_flag,
                p_update_allowed           => l_charge_ln_tbl(j).update_allowed,
                p_source_code              => l_charge_ln_tbl(j).source_code,
                p_charge_amt               => l_charge_ln_tbl(j).charge_amt,
                p_currency_code            => l_charge_ln_tbl(j).currency_code,
                p_currency_conversion_type => l_charge_ln_tbl(j).currency_conversion_type,
                p_currency_conversion_date => l_charge_ln_tbl(j).currency_conversion_date,
                p_currency_conversion_rate => l_charge_ln_tbl(j).currency_conversion_rate,
                p_party_id                 => l_charge_ln_tbl(j).party_id,
                p_party_site_id            => l_charge_ln_tbl(j).party_site_id,
                p_trx_business_category    => l_charge_ln_tbl(j).trx_business_category,
                p_intended_use             => l_charge_ln_tbl(j).intended_use,
                p_product_fiscal_class     => l_charge_ln_tbl(j).product_fiscal_class,
                p_product_category         => l_charge_ln_tbl(j).product_category,
                p_product_type             => l_charge_ln_tbl(j).product_type,
                p_user_def_fiscal_class    => l_charge_ln_tbl(j).user_def_fiscal_class,
                p_tax_classification_code  => l_charge_ln_tbl(j).tax_classification_code,
                p_assessable_value         => l_charge_ln_tbl(j).assessable_value,
                p_ship_from_party_id       => l_charge_ln_tbl(j).ship_from_party_id,
                p_ship_from_party_site_id  => l_charge_ln_tbl(j).ship_from_party_site_id,
                p_ship_to_organization_id  => l_charge_ln_tbl(j).ship_to_organization_id,
                p_ship_to_location_id      => l_charge_ln_tbl(j).ship_to_location_id,
                p_bill_from_party_id       => l_charge_ln_tbl(j).bill_from_party_id,
                p_bill_from_party_site_id  => l_charge_ln_tbl(j).bill_from_party_site_id,
                p_bill_to_organization_id  => l_charge_ln_tbl(j).bill_to_organization_id,
                p_bill_to_location_id      => l_charge_ln_tbl(j).bill_to_location_id,
                p_poa_party_id             => l_charge_ln_tbl(j).poa_party_id,
                p_poa_party_site_id        => l_charge_ln_tbl(j).poa_party_site_id,
                p_poo_organization_id      => l_charge_ln_tbl(j).poo_organization_id,
                p_poo_location_id          => l_charge_ln_tbl(j).poo_location_id,
                p_to_parent_table_name     => l_charge_ln_tbl(j).to_parent_table_name,
                p_to_parent_table_id       => l_charge_ln_tbl(j).to_parent_table_id,
                x_return_status            => l_return_status);

              -- If any errors happen abort the process.
              IF l_return_status = L_FND_RET_STS_ERROR THEN
                  RAISE L_FND_EXC_ERROR;
              ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                  RAISE L_FND_EXC_UNEXPECTED_ERROR;
              END IF;
          END LOOP;
        END IF;
    END IF;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.g_false,
        p_count => x_msg_count,
        p_data => x_msg_data);

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc (p_module_name => g_module_name,
                                 p_procedure_name => l_api_name);

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError (p_module_name => g_module_name,
                                        p_procedure_name => l_api_name);
        ROLLBACK TO Generate_Charges_PVT;
        x_return_status := L_FND_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name,
                                          p_procedure_name => l_api_name);
        ROLLBACK TO Generate_Charges_PVT;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name => g_module_name,
                                          p_procedure_name => l_api_name);
        ROLLBACK TO Generate_Charges_PVT;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => g_pkg_name,
                                  p_procedure_name => l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
END Generate_Charges;

END INL_CHARGE_PVT;

/
