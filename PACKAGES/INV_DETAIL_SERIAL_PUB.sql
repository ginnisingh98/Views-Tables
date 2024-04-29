--------------------------------------------------------
--  DDL for Package INV_DETAIL_SERIAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DETAIL_SERIAL_PUB" AUTHID CURRENT_USER AS
/* $Header: INVSRSTS.pls 120.0 2005/05/24 18:37:01 appldev noship $ */

-- Start of comments
--  API name: Get_User_Serial_Numbers
--  Type    : Public
--  Pre-reqs: None.
--  Function: Given the item/organization, inventory controls,
--            quantity for a autodetailed row and also from/to
--            serial number range info.  Allows for custom sql
--            statements to be used when detailing serials
--
--  Parameters:
--  IN: p_organization_id         IN NUMBER   Required
--        Item organization id. Part of the unique key
--        that uniquely identifies an item record.
--      p_inventory_item_id       IN NUMBER   Required
--        inventory_item_id of item that serials should
--        be selected for
--      p_revision                IN VARCHAR2
--        item revision
--      p_lot_number              IN VARCHAR2
--        item lot number
--      p_subinventory_code       IN VARCHAR2
--        source subinventory of serials
--      p_locator_id              IN NUMBER
--        source locator of serials
--      p_required_sl_qty         IN NUMBER
--        required number of serials to be retrieved
--      p_from_range              IN VARCHAR2
--        serial_number_start from mtl_txn_request_lines
--      p_to_range                IN VARCHAR2
--        serial_number_end from mtl_txn_request_lines
--      p_unit_number             IN VARCHAR2
--        unit_number from mtl_txn_request_lines
--      p_cost_group_id           IN NUMBER
--        cost group id of item
--      p_transaction_type_id     IN NUMBER
--        transaction_type_id from mtl_txn_request_lines
--      p_demand_source_type_id   IN NUMBER
--        transaction_source_type_id from mtl_txn_request_lines
--      p_demand_source_header_id IN NUMBER
--        transaction_header_id from mtl_txn_request_lines
--      p_demand_source_line_id   IN NUMBER
--        txn_source_line_id from mtl_txn_request_lines
-- OUT: x_serial_numbers         OUT NOCOPY VARCHAR2
--        Table of records returned with serials to be allocated
--  Version : Current version 1.0
-- End of comments

PROCEDURE Get_User_Serial_Numbers (
  x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN         NUMBER
, p_inventory_item_id       IN         NUMBER
, p_revision                IN         VARCHAR2
, p_lot_number              IN         VARCHAR2
, p_subinventory_code       IN         VARCHAR2
, p_locator_id              IN         NUMBER
, p_required_sl_qty         IN         NUMBER
, p_from_range              IN         VARCHAR2
, p_to_range                IN         VARCHAR2
, p_unit_number             IN         VARCHAR2
, p_cost_group_id           IN         NUMBER
, p_transaction_type_id     IN         NUMBER
, p_demand_source_type_id   IN         NUMBER
, p_demand_source_header_id IN         NUMBER
, p_demand_source_line_id   IN         NUMBER
, x_serial_numbers          OUT NOCOPY INV_DETAIL_UTIL_PVT.G_SERIAL_ROW_TABLE_REC
);

END INV_DETAIL_SERIAL_PUB;

 

/
