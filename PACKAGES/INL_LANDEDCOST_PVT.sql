--------------------------------------------------------
--  DDL for Package INL_LANDEDCOST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_LANDEDCOST_PVT" AUTHID CURRENT_USER AS
/* $Header: INLVLCOS.pls 120.6.12010000.9 2013/09/06 18:27:33 acferrei ship $ */

    G_MODULE_NAME           CONSTANT VARCHAR2(200) := 'INL.PLSQL.INL_LANDEDCOST_PVT.';
    G_PKG_NAME              CONSTANT VARCHAR2(30)  := 'INL_LANDEDCOST_PVT';

    L_FND_FALSE             CONSTANT VARCHAR2(1)   := fnd_api.g_false;              --Bug#9660084
    L_FND_VALID_LEVEL_FULL  CONSTANT NUMBER        := fnd_api.g_valid_level_full;   --Bug#9660084

PROCEDURE Run_Calculation    (
    p_api_version       IN         NUMBER,
    p_init_msg_list     IN         VARCHAR2 := L_FND_FALSE,
    p_commit            IN         VARCHAR2 := L_FND_FALSE,
    p_validation_level  IN         NUMBER   := L_FND_VALID_LEVEL_FULL,
    p_ship_header_id    IN         NUMBER,
    p_calc_scope_code   IN         NUMBER   := 0,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
);

FUNCTION Converted_Qty (
    p_organization_id   IN NUMBER,
    p_inventory_item_id IN NUMBER,
    p_qty               IN NUMBER,
    p_from_uom_code     IN VARCHAR2,
    p_to_uom_code       IN VARCHAR2
) RETURN NUMBER;


FUNCTION Converted_Amt (
    p_amt                       IN NUMBER,
    p_from_currency_code        IN VARCHAR2,
    p_to_currency_code          IN VARCHAR2,
    p_currency_conversion_type  IN VARCHAR2,
    p_currency_conversion_date  IN DATE
) RETURN NUMBER;

FUNCTION Converted_Amt (
    p_amt                       IN         NUMBER,
    p_from_currency_code        IN         VARCHAR2,
    p_to_currency_code          IN         VARCHAR2,
    p_currency_conversion_type  IN         VARCHAR2,
    p_currency_conversion_date  IN         DATE,
    x_currency_conversion_rate  OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION Converted_Price(
    p_unit_price        IN NUMBER,
    p_organization_id   IN NUMBER,
    p_inventory_item_id IN NUMBER,
    p_from_uom_code     IN VARCHAR2,
    p_to_uom_code       IN VARCHAR2
) RETURN NUMBER;

END INL_LANDEDCOST_PVT;

/
