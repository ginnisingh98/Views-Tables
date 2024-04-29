--------------------------------------------------------
--  DDL for Package Body INV_DETAIL_SERIAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DETAIL_SERIAL_PUB" AS
/* $Header: INVSRSTB.pls 115.0 2003/11/25 20:47:36 jsheu noship $ */

--  Global constant holding the package name
g_pkg_name    CONSTANT VARCHAR2(30) := 'INV_DETAIL_SERIAL_PUB';
g_pkg_version CONSTANT VARCHAR2(100) := '$Header: INVSRSTB.pls 115.0 2003/11/25 20:47:36 jsheu noship $';

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
) IS
BEGIN
  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;

EXCEPTION
  WHEN OTHERS THEN
    -- For stub purposes, return success.  Should be replaced
    -- with appropriate error handling when implemented upon
    x_return_status  := fnd_api.g_ret_sts_success;
END Get_User_Serial_Numbers;

END INV_DETAIL_SERIAL_PUB;

/
