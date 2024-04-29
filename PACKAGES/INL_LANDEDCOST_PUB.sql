--------------------------------------------------------
--  DDL for Package INL_LANDEDCOST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_LANDEDCOST_PUB" AUTHID CURRENT_USER AS
/* $Header: INLPLCOS.pls 120.5.12010000.4 2014/01/02 14:24:14 anandpra ship $ */

    G_MODULE_NAME           CONSTANT VARCHAR2(200) := 'INL.PLSQL.INL_LANDEDCOST_PUB.';
   G_PKG_NAME              CONSTANT VARCHAR2(30)  := 'INL_LANDEDCOST_PUB';

    -- Record to keep Landed Cost info for a given Shipment.
    TYPE landed_cost_rec IS RECORD(
        ship_line_id               NUMBER,
        organization_id            NUMBER,
        inventory_item_id          NUMBER,
        primary_qty                NUMBER,
        primary_uom_code           VARCHAR2(3),
        estimated_item_price       NUMBER,
        estimated_charges          NUMBER,
        estimated_taxes            NUMBER,
        estimated_unit_landed_cost NUMBER,
        actual_item_price          NUMBER,
        actual_charges             NUMBER,
        actual_taxes               NUMBER,
        actual_unit_landed_cost    NUMBER);
    TYPE landed_cost_tbl IS TABLE OF landed_cost_rec INDEX BY BINARY_INTEGER;

    PROCEDURE Get_LandedCost(
        p_api_version                IN NUMBER,
        p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE,
        p_commit                     IN VARCHAR2 := FND_API.G_FALSE,

        p_ship_line_id               IN NUMBER,
-- Bug 17536452
		    p_transaction_date			     IN DATE DEFAULT SYSDATE,
-- Bug 17536452
        x_return_status              OUT NOCOPY VARCHAR2,
        x_msg_count                  OUT NOCOPY NUMBER,
        x_msg_data                   OUT NOCOPY VARCHAR2,
        x_organization_id            OUT NOCOPY NUMBER,
        x_inventory_item_id          OUT NOCOPY NUMBER,
        x_primary_qty                OUT NOCOPY NUMBER,
        x_primary_uom_code           OUT NOCOPY VARCHAR2,
        x_estimated_item_price       OUT NOCOPY NUMBER,
        x_estimated_charges          OUT NOCOPY NUMBER,
        x_estimated_taxes            OUT NOCOPY NUMBER,
        x_estimated_unit_landed_cost OUT NOCOPY NUMBER,
        x_actual_item_price          OUT NOCOPY NUMBER,
        x_actual_charges             OUT NOCOPY NUMBER,
        x_actual_taxes               OUT NOCOPY NUMBER,
        x_actual_unit_landed_cost    OUT NOCOPY NUMBER,
        x_adjustment_num              OUT NOCOPY NUMBER
    );

    PROCEDURE Get_LandedCost(
        p_api_version     IN NUMBER,
        p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
        p_commit          IN VARCHAR2 := FND_API.G_FALSE,
        p_ship_header_id  IN NUMBER,
        x_return_status   OUT NOCOPY VARCHAR2,
        x_msg_count       OUT NOCOPY NUMBER,
        x_msg_data        OUT NOCOPY VARCHAR2,
        x_landed_cost_tbl OUT NOCOPY landed_cost_tbl
    );

END INL_LANDEDCOST_PUB;

/
