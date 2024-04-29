--------------------------------------------------------
--  DDL for Package INV_SERIAL_PICK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SERIAL_PICK_PKG" AUTHID CURRENT_USER AS
/* $Header: INVSNPIS.pls 120.1 2005/06/20 09:12:34 appldev ship $ */
PROCEDURE DEBUG(p_message       IN VARCHAR2);

procedure delete_move_order_allocation(
			 x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2
			,x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
			,p_move_order_line_id NUMBER);
procedure process_serial_picking(
			x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
			x_error_msg          OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
			p_initial_serial        IN  VARCHAR2,
			p_organization_id       IN  NUMBER,
			p_move_order_line_id    IN  NUMBER,
			p_serial_number         IN  VARCHAR2,
			p_inventory_item_id     IN  NUMBER,
			p_revision              IN  VARCHAR2,
			p_subinventory_code     IN  VARCHAR2,
			p_locator_id            IN  NUMBER,
			p_to_subinventory_code  IN  VARCHAR2,
			p_to_locator_id         IN  NUMBER,
			p_reason_id             IN  NUMBER,
			p_lot_number            IN  VARCHAR2,
			p_wms_installed         IN  VARCHAR2,
			p_transaction_action_id IN  NUMBER,
			p_transaction_type_id   IN  VARCHAR2,
			p_source_type_id        IN  NUMBER,
			p_user_id               IN  NUMBER
			);
procedure backorder_nonpick_quantity(
              	x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
		x_error_msg          OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
		p_quantity           IN   NUMBER,
		p_move_order_line_id IN   NUMBER);
END INV_SERIAL_PICK_PKG;

 

/
