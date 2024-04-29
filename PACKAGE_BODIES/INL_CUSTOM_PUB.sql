--------------------------------------------------------
--  DDL for Package Body INL_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_CUSTOM_PUB" AS
/* $Header: INLPCUSB.pls 120.0.12010000.18 2012/10/02 19:16:21 acferrei noship $ */

-- Utility name : Get_Charges
-- Type       : Public
-- Function   :
-- Pre-reqs   : None
-- Parameters :
-- IN         :   p_ship_header_rec              IN inl_charge_pvt.ship_header_rec_tp,
--                p_ship_ln_group_rec            IN inl_charge_pvt.ship_ln_group_tbl_tp,
--                p_ship_ln_tbl                  IN inl_charge_pvt.ship_ln_tbl_tp,
--
-- OUT            x_charge_ln_tbl                OUT NOCOPY inl_charge_pvt.charge_ln_tbl
--                x_override_default_processing  OUT BOOLEAN (If TRUE, it enables the hook execution
--                                                            to override the default processing from
--                                                            the caller routine)
--                x_return_status                OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :

PROCEDURE Get_Charges(
    p_ship_header_rec              IN inl_ship_headers%ROWTYPE,
    p_ship_ln_group_tbl            IN inl_charge_pvt.ship_ln_group_tbl_tp,
    p_ship_ln_tbl_tp               IN inl_charge_pvt.ship_ln_tbl_tp,
    x_charge_ln_tbl                OUT NOCOPY inl_charge_pvt.charge_ln_tbl,
    x_override_default_processing  OUT NOCOPY BOOLEAN,
    x_return_status                OUT NOCOPY VARCHAR2
) IS
BEGIN
    x_override_default_processing := FALSE;
    RETURN;
END Get_Charges;

-- Utility name : Get_Taxes
-- Type       : Public
-- Function   :
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_rec              IN INL_TAX_PVT.Shipment_Header%ROWTYPE,
--              p_ship_ln_groups_tbl           IN INL_TAX_PVT.sh_group_ln_tbl_tp,
--              p_ship_lines_tbl               IN INL_TAX_PVT.ship_ln_tbl_tp,
--              p_charge_lines_tbl             IN inl_tax_pvt.charge_ln_tbl_tp,
--
-- OUT        : x_tax_ln_tbl                   OUT inl_tax_pvt.tax_ln_tbl
--              x_override_default_processing  OUT BOOLEAN
--              x_return_status                OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Get_Taxes(
    p_ship_header_rec              IN INL_TAX_PVT.Shipment_Header%ROWTYPE,
    p_ship_ln_groups_tbl           IN INL_TAX_PVT.sh_group_ln_tbl_tp,
    p_ship_lines_tbl               IN INL_TAX_PVT.ship_ln_tbl_tp,
    p_charge_lines_tbl             IN inl_tax_pvt.charge_ln_tbl_tp,
    x_tax_ln_tbl                   OUT NOCOPY inl_tax_pvt.tax_ln_tbl,
    x_override_default_processing  OUT NOCOPY  BOOLEAN,
    x_return_status                OUT NOCOPY VARCHAR2
) IS
BEGIN
    x_override_default_processing := FALSE;
    RETURN;
END Get_Taxes;

-- Bug #9279355
-- Utility name : Get_LastTaskCodeForSimul
-- Type       : Public
-- Function   : Get Last Task Code for Simulated Shipment
--
-- Pre-reqs   : None
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Get_LastTaskCodeForSimul RETURN VARCHAR2
IS
    l_last_task_code VARCHAR2(25);
BEGIN
    l_last_task_code := 50;
/*---Possiblevalues
10 - Import     Process until "Import"     task
20 - GetCharges Process until "GetCharges" task
30 - GetTaxes   Process until "GetTaxes"   task
40 - Validate   Process until "Validation" task
50 - LandedCost Process until "LandedCost" task
60 - Submit     Process until "Submit"     task
*/
    RETURN l_last_task_code;

END Get_LastTaskCodeForSimul;

-- Bug #9279355
-- Utility name : Get_SimulFlexFields
-- Type       : Public
-- Function   : Get Flexfield values for INL_SIMULATION table
-- Pre-reqs   : None
-- Parameters :
-- IN         :   p_parent_table_name IN VARCHAR2
--                p_parent_table_id IN NUMBER
--                p_parent_table_revision_num IN NUMBER
--
-- OUT            x_flexfield_ln_rec OUT NOCOPY INL_CUSTOM_PUB.flexfield_ln_rec
--                x_return_status OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Get_SimulFlexFields(p_parent_table_name IN VARCHAR2,
                              p_parent_table_id IN NUMBER,
                              p_parent_table_revision_num IN NUMBER,
                              x_flexfield_ln_rec OUT NOCOPY INL_CUSTOM_PUB.flexfield_ln_rec,
                              x_return_status OUT NOCOPY VARCHAR2) IS
BEGIN
    -- Clean output table of records
    x_flexfield_ln_rec.attribute_category := NULL;
    x_flexfield_ln_rec.attribute1 := NULL;
    x_flexfield_ln_rec.attribute2 := NULL;
    x_flexfield_ln_rec.attribute3 := NULL;
    x_flexfield_ln_rec.attribute4 := NULL;
    x_flexfield_ln_rec.attribute5 := NULL;
    x_flexfield_ln_rec.attribute6 := NULL;
    x_flexfield_ln_rec.attribute7 := NULL;
    x_flexfield_ln_rec.attribute8 := NULL;
    x_flexfield_ln_rec.attribute9 := NULL;
    x_flexfield_ln_rec.attribute10 := NULL;
    x_flexfield_ln_rec.attribute11 := NULL;
    x_flexfield_ln_rec.attribute12 := NULL;
    x_flexfield_ln_rec.attribute13 := NULL;
    x_flexfield_ln_rec.attribute14 := NULL;
    x_flexfield_ln_rec.attribute15 := NULL;

END Get_SimulFlexFields;

-- Bug #9279355
-- Utility name : Get_SimulShipNum
-- Type       : Public
-- Function   : Get Shipment Number for the Simulated Shipment
-- Pre-reqs   : None
-- Parameters :
-- IN         :   p_simulation_rec IN INL_SIMULATION_PVT.simulation_rec,
--                p_document_number IN VARCHAR2,
--                p_organization_id IN NUMBER
--                p_sequence IN NUMBER
--
-- OUT            x_ship_num OUT VARCHAR2
--                x_return_status OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Get_SimulShipNum(p_simulation_rec IN INL_SIMULATION_PVT.simulation_rec,
                           p_document_number IN VARCHAR2,
                           p_organization_id IN NUMBER,
                           p_sequence IN NUMBER,
                           x_ship_num OUT NOCOPY VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2) IS

  l_po_lookup_code VARCHAR2(25);
  l_ship_num_prefix VARCHAR2(3); -- Bug 14280113
  l_release_num NUMBER;          -- Bug 14280113

BEGIN
    IF p_simulation_rec.parent_table_name = 'PO_HEADERS' THEN

        x_ship_num := 'P'||'O'||'.' || p_document_number || '.' || p_simulation_rec.parent_table_revision_num ||
                      '.' || p_simulation_rec.version_num || '.' || p_sequence;

    ELSIF p_simulation_rec.parent_table_name = 'PO_RELEASES' THEN -- Bug 14280113

       SELECT ph.type_lookup_code, pr.release_num
       INTO l_po_lookup_code, l_release_num
       FROM po_headers_all ph,
            po_releases_all pr
       WHERE ph.po_header_id = pr.po_header_id
       AND pr.po_release_id = p_simulation_rec.parent_table_id;

       IF l_po_lookup_code = 'PLANNED' THEN
         l_ship_num_prefix := 'PPO';
       ELSIF l_po_lookup_code = 'BLANKET' THEN
          l_ship_num_prefix := 'BPA';
       END IF;

       x_ship_num := l_ship_num_prefix ||'.' || p_document_number || '.' || l_release_num || '.' ||
                     p_simulation_rec.parent_table_revision_num || '.' || p_simulation_rec.version_num || '.' || p_sequence;

    ELSE
        x_ship_num := TO_NUMBER(TO_CHAR(SYSDATE,'YYMMDDHHMISS'));
    END IF;

--- Customize here, if needed:
--- x_ship_num := shipment number according to custom logic. Should not exceed 25 characters.

END Get_SimulShipNum;

END INL_CUSTOM_PUB;

/
