--------------------------------------------------------
--  DDL for Package INL_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_CUSTOM_PUB" AUTHID CURRENT_USER AS
/* $Header: INLPCUSS.pls 120.0.12010000.14 2011/08/03 20:40:50 acferrei noship $ */

G_MODULE_NAME  CONSTANT VARCHAR2(200) := 'INL.PLSQL.INL_CUSTOM_PUB.';
G_PKG_NAME     CONSTANT VARCHAR2(30)  := 'INL_CUSTOM_PUB';

PROCEDURE Get_Charges(
    p_ship_header_rec              IN inl_ship_headers%ROWTYPE,
    p_ship_ln_group_tbl            IN inl_charge_pvt.ship_ln_group_tbl_tp,
    p_ship_ln_tbl_tp               IN inl_charge_pvt.ship_ln_tbl_tp,
    x_charge_ln_tbl                OUT NOCOPY inl_charge_pvt.charge_ln_tbl,
    x_override_default_processing  OUT NOCOPY  BOOLEAN,
    x_return_status                OUT NOCOPY VARCHAR2);

PROCEDURE Get_Taxes(
    p_ship_header_rec              IN inl_tax_pvt.Shipment_Header%ROWTYPE,
    p_ship_ln_groups_tbl           IN inl_tax_pvt.sh_group_ln_tbl_tp,
    p_ship_lines_tbl               IN inl_tax_pvt.ship_ln_tbl_tp,
    p_charge_lines_tbl             IN inl_tax_pvt.charge_ln_tbl_tp,
    x_tax_ln_tbl                   OUT NOCOPY inl_tax_pvt.tax_ln_tbl,
    x_override_default_processing  OUT NOCOPY  BOOLEAN,
    x_return_status                OUT NOCOPY VARCHAR2);

FUNCTION Get_LastTaskCodeForSimul RETURN VARCHAR2;

TYPE flexfield_ln_rec IS RECORD(
    attribute_category VARCHAR2(150),
    attribute1 VARCHAR2(150),
    attribute2 VARCHAR2(150),
    attribute3 VARCHAR2(150),
    attribute4 VARCHAR2(150),
    attribute5 VARCHAR2(150),
    attribute6 VARCHAR2(150),
    attribute7 VARCHAR2(150),
    attribute8 VARCHAR2(150),
    attribute9 VARCHAR2(150),
    attribute10 VARCHAR2(150),
    attribute11 VARCHAR2(150),
    attribute12 VARCHAR2(150),
    attribute13 VARCHAR2(150),
    attribute14 VARCHAR2(150),
    attribute15 VARCHAR2(150));

PROCEDURE Get_SimulFlexFields(p_parent_table_name IN VARCHAR2,
                              p_parent_table_id IN NUMBER,
                              p_parent_table_revision_num IN NUMBER,
                              x_flexfield_ln_rec OUT NOCOPY INL_CUSTOM_PUB.flexfield_ln_rec,
                              x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Get_SimulShipNum(p_simulation_rec IN INL_SIMULATION_PVT.simulation_rec,
                           p_document_number IN VARCHAR2,
                           p_organization_id IN NUMBER,
                           p_sequence IN NUMBER,
                           x_ship_num OUT NOCOPY VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2);

END INL_CUSTOM_PUB;


/
