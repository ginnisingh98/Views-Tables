--------------------------------------------------------
--  DDL for Package INV_3PL_SEEDED_SOURCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_3PL_SEEDED_SOURCES" AUTHID CURRENT_USER AS
/* $Header: INVSSRCS.pls 120.0.12010000.1 2010/01/15 15:38:04 damahaja noship $ */

PROCEDURE number_receive_transactions
    (      x_counter_value             OUT NOCOPY NUMBER,
      x_return_status             OUT NOCOPY VARCHAR2
    );

PROCEDURE number_shipment_lines
    (      x_counter_value             OUT NOCOPY NUMBER,
      x_return_status             OUT NOCOPY VARCHAR2
    );

PROCEDURE number_picking_transactions
    (      x_counter_value             OUT NOCOPY NUMBER,
      x_return_status             OUT NOCOPY VARCHAR2
    );

PROCEDURE qty_receiving_transactions
    (      x_counter_value             OUT NOCOPY NUMBER,
      x_return_status             OUT NOCOPY VARCHAR2
    );

PROCEDURE number_putaway_transactions
    (      x_counter_value             OUT NOCOPY NUMBER,
      x_return_status             OUT NOCOPY VARCHAR2
    );

PROCEDURE capacity_number_of_days
    (      x_counter_value             OUT NOCOPY NUMBER,
      x_return_status             OUT NOCOPY VARCHAR2
    );

PROCEDURE volume_utilized
    (      x_counter_value             OUT NOCOPY NUMBER,
      x_return_status             OUT NOCOPY VARCHAR2
    );

PROCEDURE area_utilized
    (      x_counter_value             OUT NOCOPY NUMBER,
      x_return_status             OUT NOCOPY VARCHAR2
    );

FUNCTION get_item_uom_code (p_uom_name   VARCHAR2) RETURN VARCHAR2;

FUNCTION get_area_for_locator(p_inventory_location_id  NUMBER , p_organization_id NUMBER)
RETURN NUMBER;

FUNCTION get_volume_for_locator(p_inventory_location_id  NUMBER , p_organization_id NUMBER , p_billing_uom VARCHAR2)
RETURN NUMBER;

END INV_3PL_SEEDED_SOURCES;

/
