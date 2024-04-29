--------------------------------------------------------
--  DDL for Package Body INL_LANDEDCOST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_LANDEDCOST_PVT" AS
/* $Header: INLVLCOB.pls 120.9.12010000.32 2013/09/06 18:28:24 acferrei ship $ */

    L_FND_USER_ID               CONSTANT NUMBER        := fnd_global.user_id;           --Bug#9660084
    L_FND_LOGIN_ID              CONSTANT NUMBER        := fnd_global.login_id;          --Bug#9660084

    L_FND_EXC_ERROR             EXCEPTION;                                              --Bug#9660084
    L_FND_EXC_UNEXPECTED_ERROR  EXCEPTION;                                              --Bug#9660084

    L_FND_RET_STS_SUCCESS       CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_success;    --Bug#9660084
    L_FND_RET_STS_ERROR         CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_error;      --Bug#9660084
    L_FND_RET_STS_UNEXP_ERROR   CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_unexp_error;--Bug#9660084

-- Utility name : InLoop_Association
-- Type       : Private
-- Function   : If there are Associations in loop, this function will return TRUE,
--              otherwise, will return FALSE.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id         IN  NUMBER
--              p_from_parent_table_name IN  VARCHAR2
--              p_from_parent_table_id   IN  NUMBER
-- OUT        : x_return_status          OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :

FUNCTION InLoop_Association (
    p_ship_header_id         IN  NUMBER,
    p_from_parent_table_name IN  VARCHAR2,
    p_from_parent_table_id   IN  NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_count         NUMBER;
    l_program_name CONSTANT VARCHAR2(30) := 'InLoop_Association';
    l_debug_info    VARCHAR2(240);
    l_in_loop       BOOLEAN;

BEGIN

    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

--
-- Initialize return status to SUCCESS
--
    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'p_ship_header_id';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => TO_CHAR(p_ship_header_id));

    l_debug_info := 'p_from_parent_table_name';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => p_from_parent_table_name);

    l_debug_info := 'p_from_parent_table_id';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => TO_CHAR(p_from_parent_table_id));

    DECLARE
        LOOP_ERROR EXCEPTION;
        PRAGMA EXCEPTION_INIT(LOOP_ERROR, -1436);
    BEGIN
        SELECT count(*)
        INTO l_count
        FROM inl_associations
        WHERE ship_header_id = p_ship_header_id
        START WITH FROM_PARENT_TABLE_NAME = P_from_parent_table_name
            AND FROM_PARENT_TABLE_ID = P_from_parent_table_id
        CONNECT BY PRIOR TO_PARENT_TABLE_NAME = FROM_PARENT_TABLE_NAME
            AND PRIOR TO_PARENT_TABLE_ID = FROM_PARENT_TABLE_ID;
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info     => 'IN LOOP association does not exist'
        );
        l_in_loop := FALSE;
    EXCEPTION
        WHEN LOOP_ERROR THEN
            INL_LOGGING_PVT.Log_Statement (
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info     => 'IN LOOP association exists'
            );
            l_in_loop := TRUE;
    END;

    INL_LOGGING_PVT.Log_EndProc(
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

    IF l_in_loop THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_program_name);
        END IF;

END InLoop_Association;

-- Utility name : Converted_Price
-- Type       : Private
-- Function   : Converts a given Unit Price based on the Unit of Measure
--
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_unit_price        IN NUMBER
--              p_organization_id   IN NUMBER
--              p_inventory_item_id IN NUMBER
--              p_from_uom_code     IN VARCHAR2
--              p_to_uom_code       IN VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :

FUNCTION Converted_Price(
    p_unit_price        IN NUMBER,
    p_organization_id   IN NUMBER,
    p_inventory_item_id IN NUMBER,
    p_from_uom_code     IN VARCHAR2,
    p_to_uom_code       IN VARCHAR2
) RETURN NUMBER IS

    l_program_name CONSTANT VARCHAR2(30) := 'Converted_Price';
    l_debug_info VARCHAR2(240);
    l_msg_data VARCHAR2(2000);
    l_from_uom_class VARCHAR2(10);
    l_to_uom_class VARCHAR2(10);
    l_converted_price NUMBER;
    l_primary_uom_code VARCHAR2(3);
    l_primary_uom_class VARCHAR2(10);
    l_concatenated_segments VARCHAR2(40);

BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

    l_debug_info := 'p_unit_price';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => TO_CHAR(p_unit_price));

    l_debug_info := 'p_organization_id';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => TO_CHAR(p_organization_id));

    l_debug_info := 'p_inventory_item_id';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => TO_CHAR(p_inventory_item_id));

    l_debug_info := 'p_from_uom_code';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => p_from_uom_code);

    l_debug_info := 'p_to_uom_code';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => p_to_uom_code);
    SELECT msi.primary_uom_code,
           uom.uom_class,
           msi.concatenated_segments
    INTO l_primary_uom_code,
         l_primary_uom_class,
         l_concatenated_segments
    FROM mtl_units_of_measure uom,
         mtl_system_items_vl msi
    WHERE uom.uom_code = msi.primary_uom_code
    AND msi.organization_id = p_organization_id
    AND msi.inventory_item_id = p_inventory_item_id;

    l_debug_info := 'l_primary_uom_code';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => l_primary_uom_code);
    l_debug_info := 'l_primary_uom_class';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => l_primary_uom_class);
    l_debug_info := 'l_concatenated_segments';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => l_concatenated_segments);

    SELECT uom_class
    INTO l_from_uom_class
    FROM mtl_units_of_measure
    WHERE uom_code = p_from_uom_code;

    l_debug_info := 'l_from_uom_class';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => l_from_uom_class);
    SELECT uom_class
    INTO l_to_uom_class
    FROM mtl_units_of_measure
    WHERE uom_code = p_to_uom_code;

    l_debug_info := 'l_to_uom_class';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => l_to_uom_class);

    -- When from uom code is different from the primary uom
    -- first get it converted to the primary
    IF p_from_uom_code <> l_primary_uom_code THEN
        SELECT 1/NVL(conversion_rate,0) * NVL(p_unit_price,0)
        INTO l_converted_price
        FROM mtl_uom_conversions_view
        WHERE primary_uom_class = l_primary_uom_class
        AND primary_uom_code = l_primary_uom_code
        AND uom_class = l_from_uom_class
        AND uom_code = p_from_uom_code
        AND organization_id = p_organization_id
        AND inventory_item_id = p_inventory_item_id;

        SELECT NVL(conversion_rate,0) * NVL(l_converted_price,0)
        INTO l_converted_price
        FROM mtl_uom_conversions_view
        WHERE primary_uom_class = l_primary_uom_class
        AND primary_uom_code = l_primary_uom_code
        AND uom_class = l_to_uom_class
        AND uom_code = p_to_uom_code
        AND organization_id = p_organization_id
        AND inventory_item_id = p_inventory_item_id;

        l_debug_info := 'l_converted_price';
        INL_LOGGING_PVT.Log_Variable (p_module_name   => g_module_name,
                                      p_procedure_name=> l_program_name,
                                      p_var_name      => l_debug_info,
                                      p_var_value     => l_converted_price);
    ELSE
        SELECT (SELECT (conversion_rate * p_unit_price) as conversion_rate
                FROM mtl_uom_conversions_view
                WHERE primary_uom_class = l_from_uom_class
                AND primary_uom_code = p_from_uom_code
                AND uom_class = l_to_uom_class
                AND uom_code = p_to_uom_code
                AND organization_id = p_organization_id
                AND inventory_item_id = p_inventory_item_id
                UNION
                SELECT (1/conversion_rate * p_unit_price) as conversion_rate
                FROM mtl_uom_conversions_view
                WHERE primary_uom_class = l_to_uom_class
                AND primary_uom_code = p_to_uom_code
                AND uom_class = l_from_uom_class
                AND uom_code = p_from_uom_code
                AND organization_id = p_organization_id
                AND inventory_item_id = p_inventory_item_id)
        INTO l_converted_price
        FROM dual;

        l_debug_info := 'l_converted_price';
        INL_LOGGING_PVT.Log_Variable (p_module_name   => g_module_name,
                                      p_procedure_name=> l_program_name,
                                      p_var_name      => l_debug_info,
                                      p_var_value     => l_converted_price);
    END IF;
    RETURN l_converted_price;
EXCEPTION
    WHEN OTHERS THEN
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name => g_module_name,
            p_procedure_name => l_program_name);

        FND_MESSAGE.SET_NAME('INL','INL_ERR_QTY_CONV');
        FND_MESSAGE.SET_TOKEN('CONCATENATED_SEGMENTS',l_concatenated_segments);
        BEGIN
            SELECT unit_of_measure_tl
            INTO l_debug_info
            FROM mtl_units_of_measure
            WHERE uom_code = p_from_uom_code;
            l_debug_info := p_from_uom_code||'-'||l_debug_info;
        EXCEPTION
            WHEN OTHERS THEN
                 l_debug_info := p_from_uom_code;
        END;
        FND_MESSAGE.SET_TOKEN('FROM_UOM_CODE',l_debug_info);
        BEGIN
             SELECT unit_of_measure_tl
             INTO l_debug_info
             FROM mtl_units_of_measure
             WHERE uom_code = p_to_uom_code;
             l_debug_info := p_to_uom_code||'-'||l_debug_info;
        EXCEPTION
             WHEN OTHERS THEN
                 l_debug_info := p_to_uom_code;
        END;
        FND_MESSAGE.SET_TOKEN('TO_UOM_CODE',l_debug_info);
        l_msg_data := FND_MESSAGE.GET;
        RAISE_APPLICATION_ERROR (-20001, l_msg_data);
END Converted_Price;

-- Utility name : Converted_Qty
-- Type       : Private
-- Function   : Converts a given quantity, which can be either a primary quantity, or a volume or a weight, into
--              a given Unit Of Measure.
--
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_organization_id IN NUMBER
--              p_inventory_item_id IN NUMBER
--              p_qty IN NUMBER
--              p_from_uom_code IN VARCHAR2
--              P_to_uom_code IN VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Converted_Qty (
    p_organization_id IN NUMBER,
    p_inventory_item_id IN NUMBER,
    p_qty IN NUMBER,
    p_from_uom_code IN VARCHAR2,
    p_to_uom_code IN VARCHAR2
) RETURN NUMBER IS
    l_program_name CONSTANT VARCHAR2(30) := 'Converted_Qty';
    l_debug_info VARCHAR2(240);

    l_conv_not_found_excep  EXCEPTION;

    l_primary_uom_code VARCHAR2(3);
    l_primary_uom_class VARCHAR2(10);
    l_allocation_uom_class VARCHAR2(10);
    l_to_allocation_uom_class VARCHAR2(10);
    l_primary_qty NUMBER;
    l_converted_qty NUMBER;
    l_concatenated_segments VARCHAR2(240);
    l_msg_data      VARCHAR2(2000);

BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );

    l_debug_info := 'p_organization_id';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => TO_CHAR(p_organization_id)
    );

    l_debug_info := 'p_inventory_item_id';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => TO_CHAR(p_inventory_item_id)
    );

    l_debug_info := 'p_qty';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => TO_CHAR(p_qty)
    );

    l_debug_info := 'p_from_uom_code';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => p_from_uom_code
    );

    l_debug_info := 'p_to_uom_code';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => p_to_uom_code
    );

    SELECT
        msi.primary_uom_code,
        uom.uom_class,
        msi.concatenated_segments
    INTO
        l_primary_uom_code,
        l_primary_uom_class,
        l_concatenated_segments
    FROM mtl_units_of_measure uom,
         mtl_system_items_vl msi
    WHERE uom.uom_code = msi.primary_uom_code
    AND msi.organization_id = p_organization_id
    AND msi.inventory_item_id = p_inventory_item_id;

    l_debug_info := 'l_primary_uom_code';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => l_primary_uom_code
    );

    l_debug_info := 'l_primary_uom_class';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => l_primary_uom_class
    );

    SELECT uom_class
    INTO l_allocation_uom_class
    FROM mtl_units_of_measure
    WHERE uom_code = p_from_uom_code;

    l_debug_info := 'l_allocation_uom_class';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => l_allocation_uom_class
    );

    BEGIN

        SELECT NVL(conversion_rate,0) * NVL(p_qty,0)
        INTO l_primary_qty
        FROM mtl_uom_conversions_view
        WHERE
            primary_uom_class = l_primary_uom_class
        AND primary_uom_code = l_primary_uom_code
        AND uom_class = l_allocation_uom_class
        AND uom_code = p_from_uom_code
        AND inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_debug_info := 'Conversion not found.';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info     => l_debug_info
            );
            RAISE l_conv_not_found_excep;
    END;
    l_debug_info := 'l_primary_qty';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => TO_CHAR(l_primary_qty)
    );

    SELECT uom_class
    INTO l_to_allocation_uom_class
    FROM mtl_units_of_measure
    WHERE uom_code = P_to_uom_code;

    l_debug_info := 'l_to_allocation_uom_class';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => l_to_allocation_uom_class
    );

    BEGIN

        SELECT 1/NVL(conversion_rate,0) * NVL(l_primary_qty,0)
        INTO l_converted_qty
        FROM mtl_uom_conversions_view
        WHERE primary_uom_class = l_primary_uom_class
        AND primary_uom_code = l_primary_uom_code
        AND uom_class = l_to_allocation_uom_class
        AND uom_code = p_to_uom_code
        AND inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_debug_info := 'Conversion not found.';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info     => l_debug_info
            );
            RAISE l_conv_not_found_excep;
    END;

    l_debug_info := 'l_converted_qty';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => TO_CHAR(l_converted_qty)
    );

    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name
    );

    RETURN l_converted_qty;
EXCEPTION
    WHEN l_conv_not_found_excep THEN
        l_debug_info := 'l_conv_not_found_excep Exception.';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info     => l_debug_info
        );
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );

        FND_MESSAGE.SET_NAME('INL','INL_ERR_UOM_NFOUND'); --Bug#9011206
        FND_MESSAGE.SET_TOKEN('CONCATENATED_SEGMENTS',l_concatenated_segments);

        BEGIN
            SELECT unit_of_measure_tl
            INTO   l_debug_info
            FROM   mtl_units_of_measure
            WHERE  uom_code = p_from_uom_code;
            l_debug_info := p_from_uom_code||'-'||l_debug_info;
        EXCEPTION
            WHEN OTHERS THEN
                 l_debug_info := p_from_uom_code;
        END;
        FND_MESSAGE.SET_TOKEN('FROM_UOM_CODE',l_debug_info);
        BEGIN
            SELECT unit_of_measure_tl
            INTO l_debug_info
            FROM mtl_units_of_measure
            WHERE uom_code = p_to_uom_code;
            l_debug_info := p_to_uom_code||'-'||l_debug_info;
        EXCEPTION
            WHEN OTHERS THEN
                l_debug_info := p_to_uom_code;
        END;
        FND_MESSAGE.SET_TOKEN('TO_UOM_CODE',l_debug_info);

        l_msg_data := FND_MESSAGE.GET;
        RAISE_APPLICATION_ERROR (-20001, l_msg_data);
    WHEN OTHERS THEN
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
        );

        FND_MESSAGE.SET_NAME('INL','INL_ERR_QTY_CONV');
        FND_MESSAGE.SET_TOKEN('CONCATENATED_SEGMENTS',l_concatenated_segments);

        BEGIN
            SELECT unit_of_measure_tl
            INTO   l_debug_info
            FROM   mtl_units_of_measure
            WHERE  uom_code = p_from_uom_code;
            l_debug_info := p_from_uom_code||'-'||l_debug_info;
        EXCEPTION
            WHEN OTHERS THEN
                 l_debug_info := p_from_uom_code;
        END;
        FND_MESSAGE.SET_TOKEN('FROM_UOM_CODE',l_debug_info);
        BEGIN
            SELECT unit_of_measure_tl
            INTO l_debug_info
            FROM mtl_units_of_measure
            WHERE uom_code = p_to_uom_code;
            l_debug_info := p_to_uom_code||'-'||l_debug_info;
        EXCEPTION
            WHEN OTHERS THEN
                l_debug_info := p_to_uom_code;
        END;
        FND_MESSAGE.SET_TOKEN('TO_UOM_CODE',l_debug_info);

        l_msg_data := FND_MESSAGE.GET;
        RAISE_APPLICATION_ERROR (-20001, l_msg_data);

END Converted_Qty;

-- Utility name : Converted_Amt
-- Type       : Private
-- Function   : Converts a given amount from one currency to another
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_amt IN NUMBER
--              p_from_currency_code IN VARCHAR2
--              p_to_currency_code IN VARCHAR2
--              p_currency_conversion_type IN VARCHAR2
--              p_currency_conversion_date IN DATE
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Converted_Amt (
    p_amt                       IN NUMBER,
    p_from_currency_code        IN VARCHAR2,
    p_to_currency_code          IN VARCHAR2,
    p_currency_conversion_type  IN VARCHAR2,
    p_currency_conversion_date  IN DATE
) RETURN NUMBER IS
    l_program_name CONSTANT VARCHAR2(30) := 'Converted_Amt';
    l_debug_info VARCHAR2(240);
    l_msg_data      VARCHAR2(2000);
    l_converted_amt NUMBER;
    l_conversion_rate NUMBER;
BEGIN

    l_Converted_amt := p_amt;
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

    l_converted_amt := Converted_Amt(
        p_amt                       => p_amt,
        p_from_currency_code        => p_from_currency_code,
        p_to_currency_code          => p_to_currency_code,
        p_currency_conversion_type  => p_currency_conversion_type,
        p_currency_conversion_date  => p_currency_conversion_date,
        x_currency_conversion_rate  => l_conversion_rate);

    RETURN l_Converted_Amt;

EXCEPTION
    WHEN OTHERS THEN
        INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                          p_procedure_name => l_program_name);
        FND_MESSAGE.SET_NAME('INL','INL_ERR_AMT_CONV');
        FND_MESSAGE.SET_TOKEN('FROM_CURRENCY_CODE',p_from_currency_code);
        FND_MESSAGE.SET_TOKEN('TO_CURRENCY_CODE',p_to_currency_code);
        FND_MESSAGE.SET_TOKEN('CURRENCY_CONVERSION_TYPE',p_currency_conversion_type);
        FND_MESSAGE.SET_TOKEN('CURRENCY_CONVERSTION_DATE',p_currency_conversion_date);
        l_msg_data := FND_MESSAGE.GET;
        RAISE_APPLICATION_ERROR (-20002, l_msg_data);
END Converted_Amt;

-- Utility name : Converted_Amt
-- Type       : Private
-- Function   : Converts a given amount from one currency to another
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_amt IN NUMBER
--              p_from_currency_code IN VARCHAR2
--              p_to_currency_code IN VARCHAR2
--              p_currency_conversion_type IN VARCHAR2
--              p_currency_conversion_date IN DATE
--              x_currency_conversion_rate OUT NOCOPY NUMBER
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Converted_Amt (
    p_amt IN NUMBER,
    p_from_currency_code IN VARCHAR2,
    p_to_currency_code IN VARCHAR2,
    p_currency_conversion_type IN VARCHAR2,
    p_currency_conversion_date IN DATE,
    x_currency_conversion_rate OUT NOCOPY NUMBER
) RETURN NUMBER IS
    l_program_name CONSTANT VARCHAR2(30) := 'Converted_Amt2';
    l_debug_info VARCHAR2(240);
    l_msg_data      VARCHAR2(2000);
    l_converted_amt NUMBER;
    l_conversion_rate NUMBER;

BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

    l_Converted_Amt := p_amt;
    IF p_from_currency_code <> p_to_currency_code THEN
        BEGIN
            SELECT NVL(p_amt,0) * NVL(conversion_rate,0),
                   conversion_rate
            INTO l_converted_amt,
                 x_currency_conversion_rate
            FROM gl_daily_rates
            WHERE from_currency = p_from_currency_code
            AND to_currency = p_to_currency_code
            AND conversion_type = p_currency_conversion_type
            AND TRUNC(conversion_date) = TRUNC(p_currency_conversion_date);
        EXCEPTION
            -- Bug #7835356
            WHEN NO_DATA_FOUND THEN x_currency_conversion_rate := NULL;
        END;
    END IF;

    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

    RETURN l_Converted_Amt;
EXCEPTION
    WHEN OTHERS THEN
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        FND_MESSAGE.SET_NAME('INL','INL_ERR_AMT_CONV');
        FND_MESSAGE.SET_TOKEN('FROM_CURRENCY_CODE',p_from_currency_code);
        FND_MESSAGE.SET_TOKEN('TO_CURRENCY_CODE',p_to_currency_code);
        FND_MESSAGE.SET_TOKEN('CURRENCY_CONVERSION_TYPE',p_currency_conversion_type);
        FND_MESSAGE.SET_TOKEN('CURRENCY_CONVERSTION_DATE',p_currency_conversion_date);
        l_msg_data := FND_MESSAGE.GET;
        RAISE_APPLICATION_ERROR (-20002, l_msg_data);
END Converted_Amt;

-- Utility name : Get_TotalAmount
-- Type       : Private
-- Function   :
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id      IN NUMBER
--              p_adjustment_num      IN NUMBER
--              p_le_currency_code    IN VARCHAR2
--              p_from_component_name IN VARCHAR2
--              p_from_component_id   IN NUMBER
--              p_to_component_name   IN VARCHAR2
--              p_to_component_id     IN NUMBER
--              p_allocation_basis    IN VARCHAR2
--              p_allocation_uom_code IN VARCHAR2
-- OUT        : x_total_amt           OUT NOCOPY NUMBER
--              x_do_proportion       OUT NOCOPY VARCHAR2
--              x_return_status       OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Get_TotalAmt (
    p_ship_header_id      IN NUMBER,
    p_adjustment_num      IN NUMBER,
    p_le_currency_code    IN VARCHAR2,
    p_from_component_name IN VARCHAR2,
    p_from_component_id   IN NUMBER,
    p_to_component_name   IN VARCHAR2,
    p_to_component_id     IN NUMBER,
    p_allocation_basis    IN VARCHAR2,
    p_allocation_uom_code IN VARCHAR2,
    x_total_amt           OUT NOCOPY NUMBER,
    x_do_proportion       OUT NOCOPY VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2)
IS
    l_total_amt        NUMBER;
    l_to_component_amt NUMBER;
    l_debug_info       VARCHAR2(240);
    l_program_name     CONSTANT VARCHAR2(30) := 'Get_TotalAmt';
    -- l_inv_org_id       NUMBER; Commented for Bug 14629295
    l_return_status    VARCHAR2(1);
    l_count            NUMBER;
    l_count_aux        NUMBER;

/*----Bug#14265778 BEG
    CURSOR assoc IS
      SELECT a.association_id,
             a.to_parent_table_name,
             DECODE(a.to_parent_table_name,
              'INL_SHIP_LINES',
                  (SELECT MAX(sl.ship_line_id)
                   FROM inl_ship_lines_all sl,
                        inl_ship_lines_all sl0
                   WHERE sl0.ship_line_id         = a.to_parent_table_id
                   AND   sl.ship_header_id        = sl0.ship_header_id
                   AND   sl.ship_line_group_id    = sl0.ship_line_group_id
                   AND   sl.ship_line_num         = sl0.ship_line_num
--- SCM-051
---                AND   (sl.adjustment_num        <= p_adjustment_num
                   AND   (ABS(sl.adjustment_num)   <= ABS(p_adjustment_num)
--- SCM-051
                            OR sl.ship_header_id   <> p_ship_header_id) --Bug#10221931*
                  ),
              'INL_CHARGE_LINES',
                  (SELECT MAX(cl.charge_line_id)
                   FROM inl_charge_lines cl
--- SCM-051
---                WHERE cl.adjustment_num <= p_adjustment_num
                   WHERE ABS(cl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                   START WITH cl.charge_line_id = a.to_parent_table_id
                   CONNECT BY PRIOR cl.charge_line_id = cl.parent_charge_line_id
                  ),
              a.to_parent_table_id) to_parent_table_id
      FROM inl_associations  a
      WHERE a.from_parent_table_name = p_from_component_name
      AND a.from_parent_table_id
        =  DECODE(a.from_parent_table_name,
                    'INL_CHARGE_LINES',
                      (SELECT MIN(cl.charge_line_id)
                       FROM inl_charge_lines cl
--- SCM-051
---                    WHERE cl.adjustment_num <= p_adjustment_num
                       WHERE ABS(cl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                       START WITH cl.charge_line_id = p_from_component_id
                       CONNECT BY PRIOR cl.parent_charge_line_id = cl.charge_line_id),
                    'INL_TAX_LINES',
                      (SELECT MIN(tl.tax_line_id)
                       FROM inl_tax_lines tl
--- SCM-051
---                    WHERE tl.adjustment_num <= p_adjustment_num
                       WHERE ABS(tl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                       START WITH tl.tax_line_id = p_from_component_id
                       CONNECT BY PRIOR tl.parent_tax_line_id = tl.tax_line_id),
                    'INL_SHIP_LINES',
                      (SELECT MIN(sl.ship_line_id)
                       FROM inl_ship_lines sl
--- SCM-051
---                    WHERE (sl.adjustment_num <= p_adjustment_num
                       WHERE (ABS(sl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                              OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                       START WITH sl.ship_line_id = p_from_component_id
                       CONNECT BY PRIOR sl.parent_ship_line_id = sl.ship_line_id))
      ORDER BY a.association_id;
*/
    CURSOR assoc IS
      SELECT a.association_id,
             a.to_parent_table_name,
             DECODE(a.to_parent_table_name,
              'INL_SHIP_LINES',
                  (SELECT MAX(sl.ship_line_id)
                   FROM inl_ship_lines_all sl,
                        inl_ship_lines_all sl0
                   WHERE sl0.ship_line_id         = a.to_parent_table_id
                   AND   sl.ship_header_id        = sl0.ship_header_id
                   AND   sl.ship_line_group_id    = sl0.ship_line_group_id
                   AND   sl.ship_line_num         = sl0.ship_line_num
--- SCM-051
---                   AND   (sl.adjustment_num       <= p_adjustment_num
                   AND   (ABS(sl.adjustment_num)   <= ABS(p_adjustment_num)
--- SCM-051
                           OR sl.ship_header_id   <> p_ship_header_id) --Bug#10221931*
                  ),
              'INL_CHARGE_LINES',
                  (SELECT MAX(cl.charge_line_id)
                   FROM inl_charge_lines cl
--- SCM-051
---               WHERE cl.adjustment_num <= p_adjustment_num
                  WHERE ABS(cl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                   START WITH cl.charge_line_id = a.to_parent_table_id
                   CONNECT BY PRIOR cl.charge_line_id = cl.parent_charge_line_id
                  ),
              a.to_parent_table_id) to_parent_table_id
      FROM inl_associations  a
      WHERE p_from_component_name = 'INL_CHARGE_LINES'
      AND a.from_parent_table_name = p_from_component_name
      AND a.from_parent_table_id
        =  (SELECT MIN(cl.charge_line_id)
            FROM inl_charge_lines cl
--- SCM-051
---        WHERE cl.adjustment_num <= p_adjustment_num
           WHERE ABS(cl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
            START WITH cl.charge_line_id = p_from_component_id
            CONNECT BY PRIOR cl.parent_charge_line_id = cl.charge_line_id)
      UNION ALL
      SELECT a.association_id,
             a.to_parent_table_name,
             DECODE(a.to_parent_table_name,
              'INL_SHIP_LINES',
                  (SELECT MAX(sl.ship_line_id)
                   FROM inl_ship_lines_all sl,
                        inl_ship_lines_all sl0
                   WHERE sl0.ship_line_id         = a.to_parent_table_id
                   AND   sl.ship_header_id        = sl0.ship_header_id
                   AND   sl.ship_line_group_id    = sl0.ship_line_group_id
                   AND   sl.ship_line_num         = sl0.ship_line_num
                   AND   (sl.adjustment_num       <= p_adjustment_num
                           OR sl.ship_header_id   <> p_ship_header_id) --Bug#10221931*
                  ),
              'INL_CHARGE_LINES',
                  (SELECT MAX(cl.charge_line_id)
                   FROM inl_charge_lines cl
--- SCM-051
---                WHERE cl.adjustment_num <= p_adjustment_num
                   WHERE ABS(cl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                   START WITH cl.charge_line_id = a.to_parent_table_id
                   CONNECT BY PRIOR cl.charge_line_id = cl.parent_charge_line_id
                  ),
              a.to_parent_table_id) to_parent_table_id
      FROM inl_associations  a
      WHERE p_from_component_name = 'INL_TAX_LINES'
      AND a.from_parent_table_name = p_from_component_name
      AND a.from_parent_table_id
                   =  (SELECT MIN(tl.tax_line_id)
                       FROM inl_tax_lines tl
--- SCM-051
---                    WHERE tl.adjustment_num <= p_adjustment_num
                       WHERE ABS(tl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                       START WITH tl.tax_line_id = p_from_component_id
                       CONNECT BY PRIOR tl.parent_tax_line_id = tl.tax_line_id)
      UNION ALL
      SELECT a.association_id,
             a.to_parent_table_name,
             DECODE(a.to_parent_table_name,
              'INL_SHIP_LINES',
                  (SELECT MAX(sl.ship_line_id)
                   FROM inl_ship_lines_all sl,
                        inl_ship_lines_all sl0
                   WHERE sl0.ship_line_id         = a.to_parent_table_id
                   AND   sl.ship_header_id        = sl0.ship_header_id
                   AND   sl.ship_line_group_id    = sl0.ship_line_group_id
                   AND   sl.ship_line_num         = sl0.ship_line_num
--- SCM-051
---                AND   (sl.adjustment_num       <= p_adjustment_num
                   AND   (ABS(sl.adjustment_num)       <= ABS(p_adjustment_num)
--- SCM-051
                           OR sl.ship_header_id   <> p_ship_header_id) --Bug#10221931*
                  ),
              'INL_CHARGE_LINES',
                  (SELECT MAX(cl.charge_line_id)
                   FROM inl_charge_lines cl
--- SCM-051
---                WHERE cl.adjustment_num <= p_adjustment_num
                   WHERE ABS(cl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                   START WITH cl.charge_line_id = a.to_parent_table_id
                   CONNECT BY PRIOR cl.charge_line_id = cl.parent_charge_line_id
                  ),
              a.to_parent_table_id) to_parent_table_id
      FROM inl_associations  a
      WHERE p_from_component_name = 'INL_SHIP_LINES'
      AND a.from_parent_table_name = p_from_component_name
      AND a.from_parent_table_id
        =  (SELECT NVL(sl.parent_ship_line_id,sl.ship_line_id)
                       FROM inl_ship_lines sl
                       WHERE sl.ship_line_id = p_from_component_id)
      ORDER BY association_id;
--Bug#14265778 END

    TYPE assoc_ListType IS TABLE OF assoc%ROWTYPE;  --Bulk implem
    assoc_List assoc_ListType;                      --Bulk implem

--
-- Obtains total amount to be passed to the Manage_Proportion routine
--
BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
--
-- Initialize return status to SUCCESS
--
    x_return_status := L_FND_RET_STS_SUCCESS;
--
-- Initialize other output parameters
--
    x_do_proportion := 'N';
--
-- Initialize other variables
--
    l_total_amt := 0;
    l_count := 0;

    OPEN assoc;
    FETCH assoc BULK COLLECT INTO assoc_List; --Bulk implem
    CLOSE assoc;

    l_debug_info := 'Fetched '||NVL(assoc_List.COUNT, 0)||' association(s).';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;

    l_count_aux := NVL(assoc_List.COUNT, 0);

    IF l_count_aux = 1 THEN
        IF assoc_List(1).to_parent_table_name = 'INL_SHIP_HEADERS' THEN
            SELECT
                COUNT(*)
            INTO l_count_aux
            FROM inl_ship_lines_all ol
            WHERE ol.ship_header_id = assoc_List(1).to_parent_table_id
            AND ol.ship_line_id = (SELECT MAX(sl.ship_line_id)
                                   FROM inl_ship_lines_all sl
                                   WHERE sl.ship_header_id   = ol.ship_header_id     --Bug#9660084
                                   AND sl.ship_line_group_id = ol.ship_line_group_id --Bug#9660084
                                   AND sl.ship_line_num      = ol.ship_line_num      --Bug#9660084
--- SCM-051
---                                AND (sl.adjustment_num <= p_adjustment_num
                                   AND (ABS(sl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                                         OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                                   );
           INL_LOGGING_PVT.Log_Variable (
             p_module_name    => g_module_name,
             p_procedure_name => l_program_name,
             p_var_name       => 'A-l_count_aux',
             p_var_value      => l_count_aux);


        ELSIF assoc_List(1).to_parent_table_name = 'INL_SHIP_LINE_GROUPS' THEN
            SELECT
                COUNT(*)
            INTO l_count_aux
            FROM inl_ship_lines_all ol
            WHERE ol.ship_line_group_id = assoc_List(1).to_parent_table_id
            AND ol.ship_line_id = (SELECT MAX(sl.ship_line_id)
                                   FROM inl_ship_lines_all sl
                                   WHERE sl.ship_header_id   = ol.ship_header_id     --Bug#9660084
                                   AND sl.ship_line_group_id = ol.ship_line_group_id --Bug#9660084
                                   AND sl.ship_line_num      = ol.ship_line_num      --Bug#9660084
--- SCM-051
---                                AND (sl.adjustment_num <= p_adjustment_num
                                   AND (ABS(sl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                                        OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                                   );
           INL_LOGGING_PVT.Log_Variable (
             p_module_name    => g_module_name,
             p_procedure_name => l_program_name,
             p_var_name       => 'B-l_count_aux',
             p_var_value      => l_count_aux);
        END IF;
    ELSIF l_count_aux = 0 THEN

            SELECT
                COUNT(*)
            INTO l_count_aux
            FROM inl_ship_lines_all ol
            WHERE ol.ship_header_id = DECODE(p_from_component_name,'INL_SHIP_HEADERS',p_from_component_id,ol.ship_header_id)
            AND ol.ship_line_group_id = DECODE(p_from_component_name,'INL_SHIP_LINE_GROUPS',p_from_component_id,ol.ship_line_group_id)
            AND ol.ship_line_id = DECODE(p_from_component_name,'INL_SHIP_LINES',p_from_component_id,ol.ship_line_id)
            AND ol.ship_header_id = p_ship_header_id
            AND ol.ship_line_id = (SELECT MAX(sl.ship_line_id)
                                   FROM inl_ship_lines_all sl
                                   WHERE sl.ship_header_id = ol.ship_header_id          --Bug#9660084
                                   AND sl.ship_line_group_id = ol.ship_line_group_id    --Bug#9660084
                                   AND sl.ship_line_num = ol.ship_line_num              --Bug#9660084
--- SCM-051
---                                AND (sl.adjustment_num <= p_adjustment_num
                                   AND (ABS(sl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                                        OR sl.ship_header_id <> p_ship_header_id)       --Bug#10221931*
                                   );
    END IF;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_count_aux',
        p_var_value      => l_count_aux);

    IF l_count_aux <> 1 THEN -- l_count_aux = 0 or l_count_aux>1
--
-- Get Inventory Organization. It will be used when getting Item info.
--
-- Commented for Bug 14629295
    /*
        SELECT organization_id
        INTO l_inv_org_id
        FROM inl_ship_headers_all
        WHERE ship_header_id = p_ship_header_id;

        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'l_inv_org_id',
            p_var_value      => l_inv_org_id); */

        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'p_ship_header_id',
            p_var_value      => p_ship_header_id);

        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'p_adjustment_num',
            p_var_value      => p_adjustment_num);

        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'p_from_component_name',
            p_var_value      => p_from_component_name);

        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'p_from_component_id',
            p_var_value      => p_from_component_id);

        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'p_to_component_name',
            p_var_value      => p_to_component_name
        );

        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'p_to_component_id',
            p_var_value      => p_to_component_name
        );

        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'p_allocation_basis',
            p_var_value      => p_allocation_basis
        );

        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'p_allocation_uom_code',
            p_var_value      => p_allocation_uom_code
        );

    END IF;

    IF l_count_aux > 1 THEN

        IF p_to_component_name <> 'INL_SHIP_DISTS' THEN
    --
    -- This is for getting the total amount of each component that an associated amount
    -- refers to.
    --
            l_debug_info := 'p_to_component_name <> INL_SHIP_DISTS';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_debug_info     => l_debug_info);

            FOR iAssoc IN 1 .. assoc_List.COUNT --Bulk implem
            LOOP

                IF assoc_List(iAssoc).to_parent_table_name = 'INL_SHIP_HEADERS' THEN
                    SELECT SUM(DECODE(p_allocation_basis,'VALUE',NVL(NVL(ol.primary_qty,0)*NVL(ol.primary_unit_price * NVL(ol.currency_conversion_rate,1),0),0),
                                                                 Converted_Qty (oh.organization_id, --Modified for Bug 14629295
                                                                                ol.inventory_item_id,
                                                                                NVL(ol.primary_qty,0),
                                                                                ol.primary_uom_code,
                                                                                p_allocation_uom_code))) + l_total_amt,
                           COUNT(*) + l_count
                    INTO l_total_amt,
                         l_count
                    FROM inl_ship_lines_all ol, inl_ship_headers_all oh --Modified for Bug 14629295
                    WHERE ol.ship_header_id = assoc_List(iAssoc).to_parent_table_id
                    AND ol.ship_header_id = oh.ship_header_id
                    AND ol.ship_line_id = (SELECT MAX(sl.ship_line_id)
                                           FROM inl_ship_lines_all sl
                                           WHERE sl.ship_header_id = ol.ship_header_id --Bug#9660084
                                           AND sl.ship_line_group_id = ol.ship_line_group_id --Bug#9660084
                                           AND sl.ship_line_num = ol.ship_line_num --Bug#9660084
--- SCM-051
---                                        AND (sl.adjustment_num <= p_adjustment_num
                                           AND (ABS(sl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                                                 OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                                           );
                   l_debug_info := 'A-l_total_amt';
                   INL_LOGGING_PVT.Log_Variable (
                     p_module_name    => g_module_name,
                     p_procedure_name => l_program_name,
                     p_var_name       => l_debug_info,
                     p_var_value      => l_total_amt);

                   l_debug_info := 'A-l_count';
                   INL_LOGGING_PVT.Log_Variable (
                     p_module_name    => g_module_name,
                     p_procedure_name => l_program_name,
                     p_var_name       => l_debug_info,
                     p_var_value      => l_count);

                ELSIF assoc_List(iAssoc).to_parent_table_name = 'INL_SHIP_LINE_GROUPS' THEN
                    SELECT SUM(DECODE(p_allocation_basis,'VALUE',NVL(NVL(ol.primary_qty,0)*NVL(ol.primary_unit_price * NVL(ol.currency_conversion_rate,1),0),0),
                                                                 Converted_Qty (oh.organization_id, --Modified for Bug 14629295
                                                                                ol.inventory_item_id,
                                                                                NVL(ol.primary_qty,0),
                                                                                ol.primary_uom_code,
                                                                                p_allocation_uom_code))) + l_total_amt,
                           COUNT(*) + l_count
                    INTO l_total_amt,
                         l_count
                    FROM inl_ship_lines_all ol, inl_ship_headers_all oh --Modified for Bug 14629295
                    WHERE ol.ship_line_group_id = assoc_List(iAssoc).to_parent_table_id
                    AND ol.ship_header_id = oh.ship_header_id
                    AND ol.ship_line_id = (SELECT MAX(sl.ship_line_id)
                                           FROM inl_ship_lines_all sl
                                           WHERE sl.ship_header_id = ol.ship_header_id --Bug#9660084
                                           AND sl.ship_line_group_id = ol.ship_line_group_id --Bug#9660084
                                           AND sl.ship_line_num = ol.ship_line_num --Bug#9660084
--- SCM-051
---                                        AND (sl.adjustment_num <= p_adjustment_num
                                           AND (ABS(sl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                                                OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                                           );
                    l_debug_info := 'B-l_total_amt';
                    INL_LOGGING_PVT.Log_Variable (
                      p_module_name    => g_module_name,
                      p_procedure_name => l_program_name,
                      p_var_name       => l_debug_info,
                      p_var_value      => l_total_amt);

                    l_debug_info := 'B-l_count';
                    INL_LOGGING_PVT.Log_Variable (
                      p_module_name    => g_module_name,
                      p_procedure_name => l_program_name,
                      p_var_name       => l_debug_info,
                      p_var_value      => l_count);

                ELSIF assoc_List(iAssoc).to_parent_table_name = 'INL_SHIP_LINES' THEN
                    SELECT SUM(DECODE(p_allocation_basis,'VALUE',NVL(NVL(ol.primary_qty,0)*NVL(ol.primary_unit_price * NVL(ol.currency_conversion_rate,1),0),0),
                                                                 Converted_Qty (oh.organization_id, --Modified for Bug 14629295
                                                                                ol.inventory_item_id,
                                                                                NVL(ol.primary_qty,0),
                                                                                ol.primary_uom_code,
                                                                                p_allocation_uom_code))) + l_total_amt,
                           COUNT(*) + l_count
                    INTO l_total_amt,
                         l_count
                    FROM inl_ship_lines_all ol, inl_ship_headers_all oh --Modified for Bug 14629295
                    WHERE ol.ship_line_id = assoc_List(iAssoc).to_parent_table_id
                    AND ol.ship_header_id = oh.ship_header_id;

                    l_debug_info := 'C-l_total_amt';
                    INL_LOGGING_PVT.Log_Variable (
                      p_module_name    => g_module_name,
                      p_procedure_name => l_program_name,
                      p_var_name       => l_debug_info,
                      p_var_value      => l_total_amt);

                    l_debug_info := 'C-l_count';
                    INL_LOGGING_PVT.Log_Variable (
                      p_module_name    => g_module_name,
                      p_procedure_name => l_program_name,
                      p_var_name       => l_debug_info,
                      p_var_value      => l_count);

                ELSIF assoc_List(iAssoc).to_parent_table_name = 'INL_CHARGE_LINES' THEN
                    IF p_allocation_basis = 'VALUE' THEN
                        SELECT SUM(NVL(charge_amt,0) * NVL(currency_conversion_rate,1)) + l_total_amt,
                               COUNT(*) + l_count
                        INTO l_total_amt,
                             l_count
                        FROM inl_charge_lines cl
                        WHERE cl.charge_line_id = assoc_List(iAssoc).to_parent_table_id;
                        -- If any errors happen abort API.
                        IF l_return_status = L_FND_RET_STS_ERROR THEN
                           RAISE L_FND_EXC_ERROR;
                        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                           RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;
                    ELSE
                        FND_MESSAGE.SET_NAME('INL','INL_ERR_CHK_CH_ALLOC');
                        FND_MSG_PUB.Add;
                        RAISE L_FND_EXC_ERROR;
                    END IF;

                    l_debug_info := 'D-l_total_amt';
                    INL_LOGGING_PVT.Log_Variable (
                      p_module_name    => g_module_name,
                      p_procedure_name => l_program_name,
                      p_var_name       => l_debug_info,
                      p_var_value      => l_total_amt);

                    l_debug_info := 'D-l_count';
                    INL_LOGGING_PVT.Log_Variable (
                      p_module_name    => g_module_name,
                      p_procedure_name => l_program_name,
                      p_var_name       => l_debug_info,
                      p_var_value      => l_count);

                ELSIF assoc_List(iAssoc).to_parent_table_name = 'INL_TAX_LINES' THEN
                    IF p_allocation_basis = 'VALUE' THEN
                        SELECT nvl(SUM(nrec_tax_amt),0) + l_total_amt,
                               COUNT(*) + l_count
                        INTO l_total_amt,
                             l_count
                        FROM inl_tax_lines tl --BUG#8330505
                        WHERE tl.tax_line_id = assoc_List(iAssoc).to_parent_table_id;
                    ELSE
                        FND_MESSAGE.SET_NAME('INL','INL_ERR_TX_ALLOC');
                        FND_MSG_PUB.Add;
                        RAISE L_FND_EXC_ERROR;
                    END IF;
                    l_debug_info := 'E-l_total_amt';
                    INL_LOGGING_PVT.Log_Variable (
                      p_module_name    => g_module_name,
                      p_procedure_name => l_program_name,
                      p_var_name       => l_debug_info,
                      p_var_value      => l_total_amt);

                    l_debug_info := 'E-l_count';
                    INL_LOGGING_PVT.Log_Variable (
                      p_module_name    => g_module_name,
                      p_procedure_name => l_program_name,
                      p_var_name       => l_debug_info,
                      p_var_value      => l_count);

                END IF;
            END LOOP;
        ELSE -- p_to_component_name = 'INL_SHIP_DISTS' THEN
        --
        -- This is for getting the total amount of each component the associated amount gets to.
        --
                l_debug_info := 'p_to_component_name = INL_SHIP_DISTS';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_debug_info     => l_debug_info);

                SELECT SUM(DECODE(p_allocation_basis,'VALUE',NVL(NVL(ol.primary_qty,0)*NVL(ol.primary_unit_price * NVL(ol.currency_conversion_rate,1),0),0),
                                                             Converted_Qty (oh.organization_id, --Modified for Bug 14629295
                                                                            ol.inventory_item_id,
                                                                            NVL(ol.primary_qty,0),
                                                                            ol.primary_uom_code,
                                                                            p_allocation_uom_code))) + l_total_amt,
                       COUNT(*)
                INTO l_total_amt,
                     l_count
                FROM inl_ship_lines_all ol, inl_ship_headers_all oh --Modified for Bug 14629295
                WHERE ol.ship_header_id = DECODE(p_from_component_name,'INL_SHIP_HEADERS',p_from_component_id,ol.ship_header_id)
                AND ol.ship_line_group_id = DECODE(p_from_component_name,'INL_SHIP_LINE_GROUPS',p_from_component_id,ol.ship_line_group_id)
                AND ol.ship_line_id = DECODE(p_from_component_name,'INL_SHIP_LINES',p_from_component_id,ol.ship_line_id)
                AND ol.ship_header_id = p_ship_header_id
                AND ol.ship_header_id = oh.ship_header_id
                AND ol.ship_line_id = (SELECT MAX(sl.ship_line_id)
                                       FROM inl_ship_lines_all sl
                                       WHERE sl.ship_header_id = ol.ship_header_id --Bug#9660084
                                       AND sl.ship_line_group_id = ol.ship_line_group_id --Bug#9660084
                                       AND sl.ship_line_num = ol.ship_line_num --Bug#9660084
--- SCM-051
---                                    AND (sl.adjustment_num <= p_adjustment_num
                                       AND (ABS(sl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                                            OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                                       );
                l_debug_info := 'F-l_total_amt';
                INL_LOGGING_PVT.Log_Variable (
                  p_module_name    => g_module_name,
                  p_procedure_name => l_program_name,
                  p_var_name       => l_debug_info,
                  p_var_value      => l_total_amt);

                l_debug_info := 'F-l_count';
                INL_LOGGING_PVT.Log_Variable (
                  p_module_name    => g_module_name,
                  p_procedure_name => l_program_name,
                  p_var_name       => l_debug_info,
                  p_var_value      => l_count);

        END IF;
    ELSE
        l_count := l_count_aux;
    END IF;
    x_total_amt := l_total_amt;
    l_debug_info := 'x_total_amt';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => TO_CHAR(x_total_amt));

    IF l_count > 1 THEN
      x_do_proportion := 'Y';
    END IF;
    l_debug_info := 'x_do_proportion';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => x_do_proportion);

    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
         INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
         );
         x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
         INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
         );
         x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
         INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
         );
         x_return_status := L_FND_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_program_name);
         END IF;

END Get_TotalAmt;


-- Utility name : Manage_Proportion
-- Type       : Private
-- Function   :
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id      IN NUMBER
--              p_adjustment_num      IN NUMBER
--              p_le_currency_code    IN VARCHAR2
--              p_from_component_name IN VARCHAR2
--              p_from_component_id   IN NUMBER
--              p_to_component_name   IN VARCHAR2
--              p_to_component_id     IN NUMBER
--              p_allocation_basis    IN VARCHAR2
--              p_allocation_uom_code IN VARCHAR2
--              p_total_amt           IN NUMBER,
-- OUT        : o_factor              OUT NOCOPY NUMBER
--              x_return_status       OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :

PROCEDURE Manage_Proportion (
    p_ship_header_id      IN NUMBER,
    p_adjustment_num      IN NUMBER,
    p_le_currency_code    IN VARCHAR2,
    p_from_component_name IN VARCHAR2,
    p_from_component_id   IN NUMBER,
    p_to_component_name   IN VARCHAR2,
    p_to_component_id     IN NUMBER,
    p_allocation_basis    IN VARCHAR2,
    p_allocation_uom_code IN VARCHAR2,
    p_total_amt           IN VARCHAR2,
    o_factor              OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2)
IS
    l_total_amt        NUMBER;
    l_to_component_amt NUMBER;
    l_allocation_basis VARCHAR2(30);
    l_debug_info       VARCHAR2(240);
    l_program_name   CONSTANT VARCHAR2(30) := 'Manage_Proportion';
    --l_inv_org_id       NUMBER;  Commented for Bug 14629295
    l_return_status    VARCHAR2(1);

--
-- Obtains the Proportion Factor to be applied to the allocating amount.
-- This is used when one component is associated to more than one component, e.g.
-- One charge amount associated to two shipment lines. In cases like that,
-- each shipment line must proportionally receive its part from the charge amount,
-- according to the allocation basis of the Shipment Type.
--
-- CH1 $10 associated to SL1 and SL2, where SL1 = $40 and SL2 = $60
-- If the allocation basis of the Association = 'VALUE', then
-- the factor for SL1 = .4 and the factor for SL2 = .6, meaning that
-- SL1 will receive $4 from the $10 charge, and SL2 will receive $6 from the $10 charge
--
-- This routine is also called for prorating a final amount that gets to a
-- landed cost component to its corresponding shipment lines.

BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
--
-- Initialize return status to SUCCESS
--
    x_return_status := L_FND_RET_STS_SUCCESS;
    l_allocation_basis := p_allocation_basis;
--
-- Get Inventory Organization. It will be used when getting Item info.
-- Commented for Bug 14629295
/*  SELECT organization_id
    INTO l_inv_org_id
    FROM inl_ship_headers_all
    WHERE ship_header_id = p_ship_header_id; */


    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_id',
        p_var_value      => p_ship_header_id
        );

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_adjustment_num',
        p_var_value      => p_adjustment_num
        );

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_from_component_name',
        p_var_value      => p_from_component_name
        );

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_from_component_id',
        p_var_value      => p_from_component_id
        );

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_to_component_name',
        p_var_value      => p_to_component_name
        );

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_to_component_id',
        p_var_value      => p_to_component_id
        );

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_allocation_basis',
        p_var_value      => p_allocation_basis
        );

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_allocation_uom_code',
        p_var_value      => p_allocation_uom_code
        );

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_to_component_name',
        p_var_value      => p_to_component_name
        );

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_total_amt',
        p_var_value      => p_total_amt
        );

    IF p_to_component_name  = 'INL_SHIP_HEADERS' THEN
        SELECT SUM(DECODE(l_allocation_basis,'VALUE',NVL(NVL(ol.primary_qty,0)*NVL(ol.primary_unit_price * NVL(ol.currency_conversion_rate,1),0),0),
                                                     Converted_Qty (oh.organization_id, --Modified for Bug 14629295
                                                                    ol.inventory_item_id,
                                                                    NVL(ol.primary_qty,0),
                                                                    ol.primary_uom_code,
                                                                    p_allocation_uom_code)))
        INTO l_to_component_amt
        FROM inl_ship_lines_all ol, inl_ship_headers_all oh --Modified for Bug 14629295
        WHERE ol.ship_header_id = p_to_component_id
        AND ol.ship_header_id = oh.ship_header_id
        AND ol.ship_line_id = (SELECT MAX(sl.ship_line_id)
                               FROM inl_ship_lines_all sl
                               WHERE sl.ship_header_id = ol.ship_header_id --Bug#9660084
                               AND sl.ship_line_group_id = ol.ship_line_group_id --Bug#9660084
                               AND sl.ship_line_num = ol.ship_line_num --Bug#9660084
--- SCM-051
---                            AND (sl.adjustment_num <= p_adjustment_num
                               AND (ABS(sl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                                    OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                               );
    ELSIF p_to_component_name  = 'INL_SHIP_LINE_GROUPS' THEN
        SELECT SUM(DECODE(l_allocation_basis,'VALUE',NVL(NVL(ol.primary_qty,0)*NVL(ol.primary_unit_price * NVL(ol.currency_conversion_rate,1),0),0),
                                                     Converted_Qty (oh.organization_id, --Modified for Bug 14629295
                                                                    ol.inventory_item_id,
                                                                    NVL(ol.primary_qty,0),
                                                                    ol.primary_uom_code,
                                                                    p_allocation_uom_code)))
        INTO l_to_component_amt
        FROM inl_ship_lines_all ol, inl_ship_headers_all oh --Modified for Bug 14629295
        WHERE ol.ship_line_group_id = p_to_component_id
        AND ol.ship_header_id = oh.ship_header_id
        AND ol.ship_line_id = (SELECT MAX(sl.ship_line_id)
                               FROM inl_ship_lines_all sl
                               WHERE sl.ship_header_id = ol.ship_header_id --Bug#9660084
                               AND sl.ship_line_group_id = ol.ship_line_group_id --Bug#9660084
                               AND sl.ship_line_num = ol.ship_line_num --Bug#9660084
--- SCM-051
---                            AND (sl.adjustment_num <= p_adjustment_num
                               AND (ABS(sl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                                    OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                               );
    ELSIF p_to_component_name  = 'INL_SHIP_LINES' THEN
        SELECT SUM(DECODE(l_allocation_basis,'VALUE',NVL(NVL(ol.primary_qty,0)*NVL(ol.primary_unit_price * NVL(ol.currency_conversion_rate,1),0),0),
                                                     Converted_Qty (oh.organization_id, --Modified for Bug 14629295
                                                                    ol.inventory_item_id,
                                                                    NVL(ol.primary_qty,0),
                                                                    ol.primary_uom_code,
                                                                    p_allocation_uom_code)))
        INTO l_to_component_amt
        FROM inl_ship_lines_all ol, inl_ship_headers_all oh --Modified for Bug 14629295
        WHERE ol.ship_line_id = p_to_component_id
        AND ol.ship_header_id = oh.ship_header_id;
    ELSIF p_to_component_name  = 'INL_SHIP_DISTS' THEN
        SELECT SUM(DECODE(l_allocation_basis,'VALUE',NVL(NVL(ol.primary_qty,0)*NVL(ol.primary_unit_price * NVL(ol.currency_conversion_rate,1),0),0),
                                                     Converted_Qty (oh.organization_id, --Modified for Bug 14629295
                                                                    ol.inventory_item_id,
                                                                    NVL(ol.primary_qty,0),
                                                                    ol.primary_uom_code,
                                                                    p_allocation_uom_code)))
        INTO l_to_component_amt
        FROM inl_ship_lines_all ol, inl_ship_headers_all oh --Modified for Bug 14629295
        WHERE ol.ship_line_id = p_to_component_id
        AND ol.ship_header_id = oh.ship_header_id;
    ELSIF p_to_component_name  = 'INL_CHARGE_LINES' THEN
        IF l_allocation_basis = 'VALUE' THEN
            SELECT SUM(NVL(charge_amt,0) * NVL(currency_conversion_rate,1))
            INTO l_to_component_amt
            FROM inl_charge_lines
            WHERE charge_line_id = p_to_component_id;
        ELSE
            FND_MESSAGE.SET_NAME('INL','INL_ERR_CHK_CH_ALLOC');
            FND_MSG_PUB.Add;
            RAISE L_FND_EXC_ERROR;
        END IF;
    ELSIF p_to_component_name  = 'INL_TAX_LINES' THEN
        IF l_allocation_basis = 'VALUE' THEN
            SELECT NVL(SUM(nrec_tax_amt),0)
            INTO l_to_component_amt
            FROM inl_tax_lines --BUG#8330505
            WHERE tax_line_id = p_to_component_id;
        ELSE
            FND_MESSAGE.SET_NAME('INL','INL_ERR_TX_ALLOC');
            FND_MSG_PUB.Add;
            RAISE L_FND_EXC_ERROR;
        END IF;
    END IF;

    l_debug_info := 'l_to_component_amt';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => TO_CHAR(l_to_component_amt));


    IF p_total_amt = 0 THEN
        l_debug_info := 'No value for the basis '||l_allocation_basis;
        IF l_allocation_basis <> 'VALUE' THEN
            l_allocation_basis := 'VALUE';
            l_debug_info := 'No value for the basis '||'Changing allocation basis to '||l_allocation_basis;
        ELSE
            l_debug_info := 'Component not allocated';
            o_factor := 0;
        END IF;
        INL_LOGGING_PVT.Log_Statement (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_debug_info     => l_debug_info);
    ELSE
      o_factor := l_to_component_amt/p_total_amt;
    END IF;

    IF p_allocation_basis <> 'VALUE' THEN
        IF p_to_component_name = 'INL_CHARGE_LINES' THEN
            l_debug_info := 'Assumed allocation basis VALUE for charges';
        ELSIF p_to_component_name = 'INL_TAX_LINES' THEN
            l_debug_info := 'Assumed allocation basis VALUE for taxes';
        END IF;
    END IF;

    l_debug_info := 'o_factor';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => TO_CHAR(o_factor));

    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
         INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
         );
         x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
         INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
         );
         x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
         INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name
         );
         x_return_status := L_FND_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_program_name);
         END IF;

END Manage_Proportion;

-- Utility name : Insert_Allocation
-- Type       : Private
-- Function   :
--
-- Amounts from Landed Cost Shipment Lines as well as amounts from charges and
-- taxes should also generate lines in INL_ALLOCATIONS.
--
-- Landed Cost Shipment Lines that belong to components that are associated to others
-- should generate allocations with LANDED_COST_FLAG = N.
--
-- Charges and taxes will always generate allocations with LANDED_COST_FLAG = N, since
-- they will always end up to be sent to a Shipment Line flagged with LANDED_COST_FLAG = Y.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id      IN NUMBER
--              p_le_currency_code    IN VARCHAR2,
--              p_association_id      IN NUMBER
--              p_ship_line_id        IN NUMBER
--              p_amount              IN NUMBER
--              p_from_component_name IN VARCHAR2
--              p_from_component_id   IN NUMBER
--              p_to_component_name   IN VARCHAR2
--              p_to_component_id     IN NUMBER
--              p_lc_flag             IN VARCHAR2
--              p_adjustment_num      IN NUMBER
-- OUT        : x_return_status        OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Insert_Allocation (
    p_ship_header_id      IN NUMBER,
    p_le_currency_code    IN VARCHAR2,
    p_association_id      IN NUMBER,
    p_ship_line_id        IN NUMBER,
    p_amount              IN NUMBER,
    p_from_component_name IN VARCHAR2,
    p_from_component_id   IN NUMBER,
    p_to_component_name   IN VARCHAR2,
    p_to_component_id     IN NUMBER,
    p_lc_flag             IN VARCHAR2,
    p_adjustment_num      IN NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2
) IS

  l_ship_line_lc_flag VARCHAR2(1);
  l_debug_info      VARCHAR2(240);
  l_program_name  CONSTANT VARCHAR2(30) := 'Insert_Allocation';
  l_from_component_name VARCHAR2(30);
  l_to_component_name VARCHAR2(30);
  l_count NUMBER;
  l_factor NUMBER;
  l_return_status   VARCHAR2(1);
  l_total_amt NUMBER;
  l_do_proportion VARCHAR2(1);

  CURSOR assoc IS
    SELECT a.association_id,
           a.from_parent_table_name,
           (SELECT max(sl.ship_line_id)
            FROM inl_ship_lines_all sl,
                 inl_ship_lines_all sl0
            WHERE sl0.ship_line_id         = a.from_parent_table_id
            AND   sl.ship_header_id        = sl0.ship_header_id
            AND   sl.ship_line_group_id    = sl0.ship_line_group_id
            AND   sl.ship_line_num         = sl0.ship_line_num
--- SCM-051
---         AND   (sl.adjustment_num      <= p_adjustment_num
            AND   (ABS(sl.adjustment_num)      <= ABS(p_adjustment_num)
--- SCM-051
                   OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                               ) from_parent_table_id,
           a.to_parent_table_name,
           (SELECT max(sl.ship_line_id)
            FROM inl_ship_lines_all sl,
                 inl_ship_lines_all sl0
            WHERE sl0.ship_line_id         = a.to_parent_table_id
            AND   sl.ship_header_id        = sl0.ship_header_id
            AND   sl.ship_line_group_id    = sl0.ship_line_group_id
            AND   sl.ship_line_num         = sl0.ship_line_num
--- SCM-051
---         AND ( sl.adjustment_num        <= p_adjustment_num
            AND ( ABS(sl.adjustment_num)        <= ABS(p_adjustment_num)
--- SCM-051
                OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
            ) to_parent_table_id,
           a.allocation_basis,
           a.allocation_uom_code,
           a.to_parent_table_id ship_line_id
/*  SCM-LCM-010
    FROM inl_adj_associations_v a
*/
    FROM inl_associations a
    WHERE a.from_parent_table_name = 'INL_SHIP_LINES'
    AND a.from_parent_table_id =
          (SELECT MIN(sl.ship_line_id)
           FROM inl_ship_lines sl
--- SCM-051
---        WHERE (sl.adjustment_num <= p_adjustment_num
           WHERE (ABS(sl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                  OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
           START WITH sl.ship_line_id = p_ship_line_id
           CONNECT BY PRIOR sl.parent_ship_line_id = sl.ship_line_id )
    AND a.to_parent_table_name = 'INL_SHIP_LINES'
    AND a.ship_header_id = p_ship_header_id
    ORDER BY a.association_id;
--  rec_assoc assoc%ROWTYPE;
    TYPE assoc_ListType IS TABLE OF assoc%ROWTYPE;  --Bulk implem
    assoc_List assoc_ListType;                      --Bulk implem

BEGIN

    INL_LOGGING_PVT.Log_BeginProc (
      p_module_name    => g_module_name,
      p_procedure_name => l_program_name);

--
-- Initialize return status to SUCCESS
--
    x_return_status := L_FND_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_id',
        p_var_value      => p_ship_header_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_le_currency_code',
        p_var_value      => p_le_currency_code);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_association_id',
        p_var_value      => p_association_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_line_id',
        p_var_value      => p_ship_line_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_amount',
        p_var_value      => p_amount);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_from_component_name',
        p_var_value      => p_from_component_name);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_from_component_id',
        p_var_value      => p_from_component_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_to_component_name',
        p_var_value      => p_to_component_name);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_to_component_id',
        p_var_value      => p_to_component_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_lc_flag',
        p_var_value      => p_lc_flag);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_adjustment_num',
        p_var_value      => p_adjustment_num);

-- bug 7660824
-- Allocations from Shipment Lines with landed_cost_flag = 'N' should be inserted normally.
-- The only difference is that it should be considered as amount zero, when inserting the
-- corresponding allocation line.
/*
    BEGIN
       SELECT ol.landed_cost_flag
       INTO l_ship_line_lc_flag
       FROM inl_adj_ship_lines_v ol
       WHERE ol.ship_line_id = p_ship_line_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            l_ship_line_lc_flag := 'N';
    END;
*/
    l_ship_line_lc_flag := 'Y';
--
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_ship_line_lc_flag',
        p_var_value      => l_ship_line_lc_flag);

    -- For backward compatibility we are still using Distributions in calculations;
    -- however, for allocation purposes we'll use Shipment Lines instead.
    l_from_component_name := p_from_component_name;
    l_to_component_name := p_to_component_name;
    IF l_from_component_name = 'INL_SHIP_DISTS' THEN
        l_from_component_name := 'INL_SHIP_LINES';
    END IF;
    IF l_to_component_name = 'INL_SHIP_DISTS' THEN
        l_to_component_name := 'INL_SHIP_LINES';
    END IF;

    -- Check whether the Ship Line of the allocation is associated to other Ship Lines
    l_debug_info := 'Check whether the Ship Line of the allocation is associated to other Ship Lines';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name     => g_module_name,
        p_procedure_name  => l_program_name,
        p_debug_info      => l_debug_info);

    SELECT COUNT(*)
    INTO l_count
    FROM inl_associations a
    WHERE a.from_parent_table_name = 'INL_SHIP_LINES'
    AND a.to_parent_table_name = 'INL_SHIP_LINES'
    AND a.ship_header_id = p_ship_header_id;

    IF nvl(l_count,0)> 0 THEN
        l_count := 0;
        OPEN assoc;
        FETCH assoc BULK COLLECT INTO assoc_List; --Bulk implem
        CLOSE assoc;

        l_debug_info := 'Fetched '||NVL(assoc_List.COUNT, 0)||' association(s).';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info
        ) ;


        IF NVL(assoc_List.COUNT,0) > 0 THEN
            FOR iAssoc IN 1 .. assoc_List.COUNT --Bulk implem
            LOOP
                l_count := l_count + 1;

                IF p_amount <> 0 THEN
                  IF l_count = 1 THEN
                    l_debug_info := 'Call Get_TotalAmt';
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name         => g_module_name,
                        p_procedure_name      => l_program_name,
                        p_debug_info          => l_debug_info);
                    Get_TotalAmt (
                        p_ship_header_id      => p_ship_header_id,
                        p_adjustment_num      => p_adjustment_num,
                        p_le_currency_code    => p_le_currency_code,
                        p_from_component_name => 'INL_SHIP_LINES',
                        p_from_component_id   => p_ship_line_id,
                        p_to_component_name   => assoc_List(iAssoc).to_parent_table_name,
                        p_to_component_id     => assoc_List(iAssoc).to_parent_table_id,
                        p_allocation_basis    => assoc_List(iAssoc).allocation_basis,
                        p_allocation_uom_code => assoc_List(iAssoc).allocation_uom_code,
                        x_total_amt           => l_total_amt,
                        x_do_proportion       => l_do_proportion,
                        x_return_status       => l_return_status);
                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                       RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                       RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                  END IF;
                  IF l_do_proportion = 'Y' THEN
                    l_debug_info := 'Call Manage_Proportion';
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name         => g_module_name,
                        p_procedure_name      => l_program_name,
                        p_debug_info          => l_debug_info);
                    Manage_Proportion (
                        p_ship_header_id      => p_ship_header_id,
                        p_adjustment_num      => p_adjustment_num,
                        p_le_currency_code    => p_le_currency_code,
                        p_from_component_name => 'INL_SHIP_LINES',
                        p_from_component_id   => p_ship_line_id,
                        p_to_component_name   => assoc_List(iAssoc).to_parent_table_name,
                        p_to_component_id     => assoc_List(iAssoc).to_parent_table_id,
                        p_allocation_basis    => assoc_List(iAssoc).allocation_basis,
                        p_allocation_uom_code => assoc_List(iAssoc).allocation_uom_code,
                        p_total_amt           => l_total_amt,
                        o_factor              => l_factor,
                        x_return_status       => l_return_status);
                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                       RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                       RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                  ELSE
                    l_factor := 1;
                  END IF;
                ELSE
                  l_factor := 0;
                END IF;

                l_debug_info := 'l_factor';
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => l_debug_info,
                    p_var_value      => TO_CHAR(l_factor));

                l_debug_info := 'Inserting into inl_allocations';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name     => g_module_name,
                    p_procedure_name  => l_program_name,
                    p_debug_info      => l_debug_info);

                l_debug_info := 'assoc_List('||iAssoc||').to_parent_table_id';
                INL_LOGGING_PVT.Log_Variable (p_module_name    => g_module_name,
                                              p_procedure_name => l_program_name,
                                              p_var_name       => l_debug_info,
                                              p_var_value      => TO_CHAR(assoc_List(iAssoc).to_parent_table_id));

                l_debug_info := 'p_amount * l_factor';
                INL_LOGGING_PVT.Log_Variable (p_module_name    => g_module_name,
                                              p_procedure_name => l_program_name,
                                              p_var_name       => l_debug_info,
                                              p_var_value      => TO_CHAR(p_amount * l_factor));

        --- Bug 7706718 - Recursive call to Insert_Allocation, until there are no shipment lines to redirect the allocation
                Insert_Allocation (
                    p_ship_header_id      => p_ship_header_id,
                    p_le_currency_code    => p_le_currency_code,
                    p_association_id      => p_association_id,
                    p_ship_line_id        => assoc_List(iAssoc).ship_line_id,
                    p_amount              => p_amount * l_factor,
                    p_from_component_name => l_from_component_name,
                    p_from_component_id   => p_from_component_id,
                    p_to_component_name   => assoc_List(iAssoc).to_parent_table_name,
                    p_to_component_id     => assoc_List(iAssoc).to_parent_table_id,
                    p_lc_flag             => p_lc_flag,
                    p_adjustment_num      => p_adjustment_num,
                    x_return_status       => l_return_status);

        -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                   RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                   RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;
            END LOOP;
        END IF;
    END IF;
    IF l_count = 0 THEN
        l_debug_info := 'Inserting into inl_allocations';
        INL_LOGGING_PVT.Log_Statement (
            p_module_name     => g_module_name,
            p_procedure_name  => l_program_name,
            p_debug_info      => l_debug_info);
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'p_ship_line_id',
            p_var_value      => p_ship_line_id);
        INL_LOGGING_PVT.Log_Variable (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name,
            p_var_name       => 'p_amount',
            p_var_value      => p_amount);

        INSERT INTO inl_allocations
             (allocation_id,                                       /* 01 */
              ship_header_id,                                      /* 02 */
              association_id,                                      /* 03 */
              ship_line_id,                                        /* 04 */
              from_parent_table_name,                              /* 05 */
              from_parent_table_id,                                /* 06 */
              to_parent_table_name,                                /* 07 */
              to_parent_table_id,                                  /* 08 */
              adjustment_num,                                      /* 09 */
              allocation_amt,                                      /* 10 */
              landed_cost_flag,                                    /* 11 */
              created_by,                                          /* 12 */
              creation_date,                                       /* 13 */
              last_updated_by,                                     /* 14 */
              last_update_date,                                    /* 15 */
              last_update_login)                                   /* 16 */
        VALUES
             (inl_allocations_s.NEXTVAL,                           /* 01 */
              p_ship_header_id,                                    /* 02 */
              p_association_id,                                    /* 03 */
              p_ship_line_id,                                      /* 04 */
              l_from_component_name,                               /* 05 */
              p_from_component_id,                                 /* 06 */
              l_to_component_name,                                 /* 07 */
              p_to_component_id,                                   /* 08 */
--- SCM-051
              ABS(p_adjustment_num),                               /* 09 */
--- SCM-051
              p_amount,                                            /* 10 */
              DECODE(p_lc_flag,'N','N','Y',l_ship_line_lc_flag),   /* 11 */
              L_FND_USER_ID,                                       /* 12 */
              SYSDATE,                                             /* 13 */
              L_FND_USER_ID,                                       /* 14 */
              SYSDATE,                                             /* 15 */
              L_FND_LOGIN_ID);                                     /* 16 */
    END IF;

    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
         INL_LOGGING_PVT.Log_ExpecError (
             p_module_name    => g_module_name,
             p_procedure_name => l_program_name);
         x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
         INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
         x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
         INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
         x_return_status := L_FND_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_program_name);
         END IF;

END Insert_Allocation;


-- Utility name : Manage_Allocation
-- Type       : Private
-- Function   :
--
-- This routine allocates the amount that gets to a landed cost component into its corresponding
-- Shipment Lines. In this routine, the Manage_Proportion routine is also called, this time
-- to prorate the allocating amount into the many Shipment Lines corresponding to the
-- component that is absorbing it.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id      IN NUMBER
--              p_le_currency_code    IN VARCHAR2
--              p_association_id      IN NUMBER
--              p_allocation_basis    IN VARCHAR2
--              p_allocation_uom_code IN VARCHAR2
--              p_amount              IN NUMBER
--              p_from_component_name IN VARCHAR2
--              p_from_component_id   IN NUMBER
--              p_to_component_name   IN VARCHAR2
--              p_to_component_id     IN NUMBER
--              p_lc_flag             IN VARCHAR2
--              p_adjustment_num      IN NUMBER
-- OUT        : x_return_status       OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Manage_Allocation (
    p_ship_header_id      IN NUMBER,
    p_le_currency_code    IN VARCHAR2,
    p_association_id      IN NUMBER,
    p_allocation_basis    IN VARCHAR2,
    p_allocation_uom_code IN VARCHAR2,
    p_amount              IN NUMBER,
    p_from_component_name IN VARCHAR2,
    p_from_component_id   IN NUMBER,
    p_to_component_name   IN VARCHAR2,
    p_to_component_id     IN NUMBER,
    p_lc_flag             IN VARCHAR2,
    p_adjustment_num      IN NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2
) IS
/*
    CURSOR dist IS
      SELECT ship_line_id
      FROM inl_ship_lines_all ol
      WHERE ol.ship_header_id = p_ship_header_id
      AND ol.ship_line_id = DECODE(p_to_component_name, 'INL_SHIP_LINES', p_to_component_id, ol.ship_line_id)
      AND ol.ship_line_group_id = DECODE(p_to_component_name, 'INL_SHIP_LINE_GROUPS', p_to_component_id, ol.ship_line_group_id)
      AND ol.ship_line_id = (SELECT MAX(sl.ship_line_id)
                             FROM inl_ship_lines_all sl
                             WHERE sl.ship_header_id = ol.ship_header_id --Bug#9660084
                             AND sl.ship_line_group_id = ol.ship_line_group_id --Bug#9660084
                             AND sl.ship_line_num = ol.ship_line_num --Bug#9660084
                             AND (sl.adjustment_num <= p_adjustment_num
                                  OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                               )

      ORDER BY ol.ship_line_id;
*/
    CURSOR dist IS -- this cursor will be open only for p_to_component_name in 'INL_SHIP_LINE_GROUPS', 'INL_SHIP_HEADERS'
      SELECT ship_line_id
      FROM inl_ship_lines_all ol
      WHERE ol.ship_header_id = p_ship_header_id
      AND ol.ship_line_group_id = DECODE(p_to_component_name, 'INL_SHIP_LINE_GROUPS', p_to_component_id, ol.ship_line_group_id)
      AND ol.ship_line_id = (SELECT MAX(sl.ship_line_id)
                             FROM inl_ship_lines_all sl
                             WHERE sl.ship_header_id = ol.ship_header_id --Bug#9660084
                             AND sl.ship_line_group_id = ol.ship_line_group_id --Bug#9660084
                             AND sl.ship_line_num = ol.ship_line_num --Bug#9660084
--- SCM-051
---                          AND (sl.adjustment_num <= p_adjustment_num
                             AND (ABS(sl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                               ))
      ORDER BY ol.ship_line_id;


--    rec_dist dist%ROWTYPE;
    TYPE dist_ListType IS TABLE OF dist%ROWTYPE;  --Bulk implem
    dist_List dist_ListType;                      --Bulk implem


    l_factor          NUMBER;
    l_debug_info      VARCHAR2(240);
    l_program_name  CONSTANT VARCHAR2(30) := 'Manage_Allocation';
    l_return_status   VARCHAR2(1);
    l_count           NUMBER;
    l_total_amt       NUMBER;
    l_do_proportion   VARCHAR2(1);

BEGIN
    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
--
-- Initialize return status to SUCCESS
--
    x_return_status := L_FND_RET_STS_SUCCESS;
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_id',
        p_var_value      => p_ship_header_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_le_currency_code',
        p_var_value      => p_le_currency_code);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_association_id',
        p_var_value      => p_association_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_allocation_basis',
        p_var_value      => p_allocation_basis);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_allocation_uom_code',
        p_var_value      => p_allocation_uom_code);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_amount',
        p_var_value      => p_amount);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_from_component_name',
        p_var_value      => p_from_component_name);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_from_component_id',
        p_var_value      => p_from_component_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_to_component_name',
        p_var_value      => p_to_component_name);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_to_component_id',
        p_var_value      => p_to_component_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_adjustment_num',
        p_var_value      => p_adjustment_num);
    l_count := 0;

    IF p_to_component_name  = 'INL_SHIP_LINES'
    THEN
        l_do_proportion:='N';
        l_total_amt:= 0;
        Insert_Allocation (
            p_ship_header_id      => p_ship_header_id,
            p_le_currency_code    => p_le_currency_code,
            p_association_id      => p_association_id,
            p_ship_line_id        => p_to_component_id,
            p_amount              => p_amount,
            p_from_component_name => p_from_component_name,
            p_from_component_id   => p_from_component_id,
            p_to_component_name   => p_to_component_name,
            p_to_component_id     => p_to_component_id,
            p_lc_flag             => p_lc_flag,
            p_adjustment_num      => p_adjustment_num,
            x_return_status       => l_return_status);

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
           RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
           RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSE

        OPEN dist;
        FETCH dist BULK COLLECT INTO dist_List; --Bulk implem
        CLOSE dist;

        l_debug_info := 'Fetched '||NVL(dist_List.COUNT, 0)||' Line(s).';
        INL_LOGGING_PVT.Log_Statement(
            p_module_name      => g_module_name,
            p_procedure_name   => l_program_name,
            p_debug_info       => l_debug_info
        ) ;

        IF NVL(dist_List.COUNT,0)>0
        THEN
            FOR idist IN 1 .. dist_List.COUNT --Bulk implem
            LOOP

                l_count := l_count + 1;

                IF p_amount <> 0 THEN
                  IF l_count = 1 THEN
                    -- in case of FROM and TO in ('INL_SHIP_DISTS','INL_SHIP_LINES')
                    -- AND  FROM_id = TO_id it is about an allocation from one line to the same line
                        l_debug_info := 'Call Get_TotalAmt';
                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name     => g_module_name,
                            p_procedure_name  => l_program_name,
                            p_debug_info      => l_debug_info);
                        Get_TotalAmt (
                            p_ship_header_id      => p_ship_header_id,
                            p_adjustment_num      => p_adjustment_num,
                            p_le_currency_code    => p_le_currency_code,
                            p_from_component_name => p_to_component_name,
                            p_from_component_id   => p_to_component_id,
                            p_to_component_name   => 'INL_SHIP_DISTS',
                            p_to_component_id     => dist_List(idist).ship_line_id,
                            p_allocation_basis    => p_allocation_basis,
                            p_allocation_uom_code => p_allocation_uom_code,
                            x_total_amt           => l_total_amt,
                            x_do_proportion       => l_do_proportion,
                            x_return_status       => l_return_status);
                        -- If any errors happen abort API.
                        IF l_return_status = L_FND_RET_STS_ERROR THEN
                           RAISE L_FND_EXC_ERROR;
                        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                           RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;
                  END IF;
                  IF l_do_proportion = 'Y' THEN
                    l_debug_info := 'Call Manage_Proportion';
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name     => g_module_name,
                        p_procedure_name  => l_program_name,
                        p_debug_info      => l_debug_info);
                    Manage_Proportion (
                        p_ship_header_id      => p_ship_header_id,
                        p_adjustment_num      => p_adjustment_num,
                        p_le_currency_code    => p_le_currency_code,
                        p_from_component_name => p_to_component_name,
                        p_from_component_id   => p_to_component_id,
                        p_to_component_name   => 'INL_SHIP_DISTS',
                        p_to_component_id     => dist_List(idist).ship_line_id,
                        p_allocation_basis    => p_allocation_basis,
                        p_allocation_uom_code => p_allocation_uom_code,
                        p_total_amt           => l_total_amt,
                        o_factor              => l_factor,
                        x_return_status       => l_return_status);
                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                       RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                       RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;
                  ELSE
                    l_factor := 1;
                  END IF;
                ELSE
                  l_factor := 0;
                END IF;

                Insert_Allocation (
                    p_ship_header_id      => p_ship_header_id,
                    p_le_currency_code    => p_le_currency_code,
                    p_association_id      => p_association_id,
                    p_ship_line_id        => dist_List(idist).ship_line_id,
                    p_amount              => p_amount * l_factor,
                    p_from_component_name => p_from_component_name,
                    p_from_component_id   => p_from_component_id,
                    p_to_component_name   => p_to_component_name,
                    p_to_component_id     => p_to_component_id,
                    p_lc_flag             => p_lc_flag,
                    p_adjustment_num      => p_adjustment_num,
                    x_return_status       => l_return_status);

                -- If any errors happen abort API.
                IF l_return_status = L_FND_RET_STS_ERROR THEN
                   RAISE L_FND_EXC_ERROR;
                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                   RAISE L_FND_EXC_UNEXPECTED_ERROR;
                END IF;

            END LOOP;
        END IF;
    END IF;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
       x_return_status := L_FND_RET_STS_ERROR;
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_program_name);
        END IF;

END Manage_Allocation;


-- Utility name : Control_Allocation
-- Type       : Private
-- Function   : This routine controls and redirect, when necessary, the allocation of an amount that
--              comes from a component to another.
--
--                                                 |-> Shipment Line SL1
--              Example: Charge CH1: Shipment SH1 -
--                                                 |-> Shipment Line SL2
--
--              This routine would take care of calling the Manage_Allocation routine
--              for allocating CH1 amount to Shipment SH1, and then for allocating
--              the SH1 portion of CH1 to Shipment Line SL1 and Shipment Line SL1.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_ship_header_id      IN NUMBER
--              p_le_currency_code    IN VARCHAR2
--              p_association_id      IN NUMBER
--              p_allocation_basis    IN VARCHAR2
--              p_allocation_uom_code IN VARCHAR2
--              p_amount              IN NUMBER
--              p_from_component_name IN VARCHAR2
--              p_from_component_id   IN NUMBER
--              p_to_component_name   IN VARCHAR2
--              p_to_component_id     IN NUMBER
--              p_adjustment_num      IN NUMBER
--
-- OUT          x_return_status      OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :

PROCEDURE Control_Allocation (
    p_ship_header_id      IN NUMBER,
    p_le_currency_code    IN VARCHAR2,
    p_association_id      IN NUMBER,
    p_allocation_basis    IN VARCHAR2,
    p_allocation_uom_code IN VARCHAR2,
    p_amount              IN NUMBER,
    p_from_component_name IN VARCHAR2,
    p_from_component_id   IN NUMBER,
    p_to_component_name   IN VARCHAR2,
    p_to_component_id     IN NUMBER,
    p_adjustment_num      IN NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2
) IS
    CURSOR component IS
      SELECT 1                   SEQ_NUM,
           'INL_SHIP_LINES'    COMPONENT_NAME,
           ol.ship_line_id     COMPONENT_ID
      FROM inl_ship_lines_all ol
      WHERE ol.ship_header_id = p_ship_header_id
      AND ol.ship_line_id = DECODE(p_to_component_name, 'INL_SHIP_LINES', p_to_component_id, -1)
      AND ol.ship_line_id = (SELECT MAX(sl.ship_line_id)
                             FROM inl_ship_lines_all sl
                             WHERE sl.ship_header_id = ol.ship_header_id --Bug#9660084
                             AND sl.ship_line_group_id = ol.ship_line_group_id --Bug#9660084
                             AND sl.ship_line_num = ol.ship_line_num --Bug#9660084
--- SCM-051
---                          AND (sl.adjustment_num <= p_adjustment_num
                             AND (ABS(sl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                                  OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                               )
      UNION
      SELECT 2                   SEQ_NUM,
             'INL_SHIP_HEADERS'  COMPONENT_NAME,
             ol.ship_header_id   COMPONENT_ID
      FROM inl_ship_lines_all ol
      WHERE ol.ship_header_id = p_ship_header_id
      AND ol.ship_line_id = DECODE(p_to_component_name, 'INL_SHIP_LINES', p_to_component_id, -1)
      AND ol.ship_line_id = (SELECT MAX(sl.ship_line_id)
                             FROM inl_ship_lines_all sl
                             WHERE sl.ship_header_id = ol.ship_header_id --Bug#9660084
                             AND sl.ship_line_group_id = ol.ship_line_group_id --Bug#9660084
                             AND sl.ship_line_num = ol.ship_line_num --Bug#9660084
--- SCM-051
---                          AND (sl.adjustment_num <= p_adjustment_num
                             AND (ABS(sl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                                    OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                               )
      UNION
      SELECT 1                    SEQ_NUM,
             p_to_component_name COMPONENT_NAME,
             p_to_component_id   COMPONENT_ID
      FROM dual
      ORDER BY seq_num;

    TYPE component_ListType IS TABLE OF component%ROWTYPE;  --Bulk implem
    component_List component_ListType;                      --Bulk implem

    CURSOR assoc (pc_component_name VARCHAR2, pc_component_id NUMBER) IS
      SELECT a.association_id,
             a.from_parent_table_name,
             DECODE(a.from_parent_table_name,
              'INL_SHIP_LINES',
                  (SELECT MAX(sl.ship_line_id)
                   FROM inl_ship_lines_all sl,
                        inl_ship_lines_all sl0
                   WHERE sl0.ship_line_id         = a.from_parent_table_id
                   AND   sl.ship_header_id        = sl0.ship_header_id
                   AND   sl.ship_line_group_id    = sl0.ship_line_group_id
                   AND   sl.ship_line_num         = sl0.ship_line_num
--- SCM-051
---                AND   (sl.adjustment_num        <= p_adjustment_num
                   AND   (ABS(sl.adjustment_num)        <= ABS(p_adjustment_num)
--- SCM-051
                          OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                   ),
              'INL_CHARGE_LINES',
                  (SELECT MAX(cl.charge_line_id)
                   FROM inl_charge_lines cl
--- SCM-051
---                WHERE cl.adjustment_num <= p_adjustment_num
                   WHERE ABS(cl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                   START WITH cl.charge_line_id = a.from_parent_table_id
                   CONNECT BY PRIOR cl.charge_line_id = cl.parent_charge_line_id
                  ),
              'INL_TAX_LINES',
                  (SELECT MAX(tl.tax_line_id)
                   FROM inl_tax_lines tl
--- SCM-051
---                WHERE tl.adjustment_num <= p_adjustment_num
                   WHERE ABS(tl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                   START WITH tl.tax_line_id = a.from_parent_table_id
                   CONNECT BY PRIOR tl.tax_line_id = tl.parent_tax_line_id
                   ),
             a.from_parent_table_id) from_parent_table_id,
             a.to_parent_table_name,
             DECODE(a.to_parent_table_name,
              'INL_SHIP_LINES',
                  (SELECT MAX(sl.ship_line_id)
                   FROM inl_ship_lines_all sl,
                        inl_ship_lines_all sl0
                   WHERE sl0.ship_line_id         = a.to_parent_table_id
                   AND   sl.ship_header_id        = sl0.ship_header_id
                   AND   sl.ship_line_group_id    = sl0.ship_line_group_id
                   AND   sl.ship_line_num         = sl0.ship_line_num
--- SCM-051
---                AND   (sl.adjustment_num       <= p_adjustment_num
                   AND   (ABS(sl.adjustment_num)       <= ABS(p_adjustment_num)
--- SCM-051
                          OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                  ),
              'INL_CHARGE_LINES',
                  (SELECT MAX(cl.charge_line_id)
                   FROM inl_charge_lines cl
--- SCM-051
---                WHERE cl.adjustment_num <= p_adjustment_num
                   WHERE ABS(cl.adjustment_num) <= ABS(p_adjustment_num)
--- SCM-051
                   START WITH cl.charge_line_id = a.to_parent_table_id
                   CONNECT BY PRIOR cl.charge_line_id = cl.parent_charge_line_id
                  ),
             a.to_parent_table_id) to_parent_table_id
      FROM inl_associations a
      WHERE a.ship_header_id = p_ship_header_id
      AND a.from_parent_table_name = pc_component_name
      AND a.from_parent_table_id = pc_component_id
      ORDER BY a.association_id;

--    rec_assoc assoc%ROWTYPE;
    TYPE assoc_ListType IS TABLE OF assoc%ROWTYPE;  --Bulk implem
    assoc_List assoc_ListType;                      --Bulk implem

    l_next_level_allocation VARCHAR2(1);
    l_lc_flag         VARCHAR2(1);
    l_factor          NUMBER;
    l_debug_info      VARCHAR2(240);
    l_program_name  CONSTANT VARCHAR2(30) := 'Control_Allocation';
    l_return_status   VARCHAR2(1);
    l_count           NUMBER;
    l_total_amt       NUMBER;
    l_do_proportion   VARCHAR2(1);
BEGIN

    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
--
-- Initialize return status to SUCCESS
--

    x_return_status := L_FND_RET_STS_SUCCESS;

    l_next_level_allocation := 'N';

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_ship_header_id',
        p_var_value      => p_ship_header_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_le_currency_code',
        p_var_value      => p_le_currency_code);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_association_id',
        p_var_value      => p_association_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_allocation_basis',
        p_var_value      => p_allocation_basis);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_allocation_uom_code',
        p_var_value      => p_allocation_uom_code);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_amount',
        p_var_value      => p_amount);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_from_component_name',
        p_var_value      => p_from_component_name);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_from_component_id',
        p_var_value      => p_from_component_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_to_component_name',
        p_var_value      => p_to_component_name);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_to_component_id',
        p_var_value      => p_to_component_id);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_adjustment_num',
        p_var_value      => p_adjustment_num);

    OPEN component;
    FETCH component BULK COLLECT INTO component_List; --Bulk implem
    CLOSE component;

    l_debug_info := 'Fetched '||NVL(component_List.COUNT, 0)||' component(s).';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;

    IF NVL(component_List.COUNT,0)>0
    THEN
        FOR icomponent IN 1 .. component_List.COUNT --Bulk implem
        LOOP

            l_count := 0;

            OPEN assoc(component_List(icomponent).component_name,
                       component_List(icomponent).component_id);
            FETCH assoc BULK COLLECT INTO assoc_List; --Bulk implem
            CLOSE assoc;

            l_debug_info := 'Fetched '||NVL(assoc_List.COUNT, 0)||' association(s).';
            INL_LOGGING_PVT.Log_Statement(
                p_module_name      => g_module_name,
                p_procedure_name   => l_program_name,
                p_debug_info       => l_debug_info
            ) ;
            IF NVL(assoc_List.COUNT,0)>0
            THEN
                FOR iAssoc IN 1 .. assoc_List.COUNT --Bulk implem
                LOOP

                    l_count := l_count + 1;

                    l_next_level_allocation := 'Y';

                    IF p_amount <> 0 THEN
                      IF l_count = 1 THEN
                        l_debug_info := 'Call Get_TotalAmt';
                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name     => g_module_name,
                            p_procedure_name  => l_program_name,
                            p_debug_info      => l_debug_info);
                        Get_TotalAmt (
                            p_ship_header_id      =>p_ship_header_id,
                            p_adjustment_num      =>p_adjustment_num,
                            p_le_currency_code    =>p_le_currency_code,
                            p_from_component_name =>assoc_List(iAssoc).from_parent_table_name,
                            p_from_component_id   =>assoc_List(iAssoc).from_parent_table_id,
                            p_to_component_name   =>assoc_List(iAssoc).to_parent_table_name,
                            p_to_component_id     =>assoc_List(iAssoc).to_parent_table_id,
                            p_allocation_basis    =>p_allocation_basis,
                            p_allocation_uom_code =>p_allocation_uom_code,
                            x_total_amt           =>l_total_amt,
                            x_do_proportion       =>l_do_proportion,
                            x_return_status       =>l_return_status);
                        -- If any errors happen abort API.
                        IF l_return_status = L_FND_RET_STS_ERROR THEN
                           RAISE L_FND_EXC_ERROR;
                        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                           RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;
                      END IF;
                      IF l_do_proportion = 'Y' THEN
                        l_debug_info := 'Call Manage_Proportion';
                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name     => g_module_name,
                            p_procedure_name  => l_program_name,
                            p_debug_info      => l_debug_info);
                        Manage_Proportion (
                            p_ship_header_id      =>p_ship_header_id,
                            p_adjustment_num      =>p_adjustment_num,
                            p_le_currency_code    =>p_le_currency_code,
                            p_from_component_name =>assoc_List(iAssoc).from_parent_table_name,
                            p_from_component_id   =>assoc_List(iAssoc).from_parent_table_id,
                            p_to_component_name   =>assoc_List(iAssoc).to_parent_table_name,
                            p_to_component_id     =>assoc_List(iAssoc).to_parent_table_id,
                            p_allocation_basis    =>p_allocation_basis,
                            p_allocation_uom_code =>p_allocation_uom_code,
                            p_total_amt           =>l_total_amt,
                            o_factor              =>l_factor,
                            x_return_status       =>l_return_status);
                        -- If any errors happen abort API.
                        IF l_return_status = L_FND_RET_STS_ERROR THEN
                           RAISE L_FND_EXC_ERROR;
                        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                           RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;
                      ELSE
                        l_factor := 1;
                      END IF;
                    ELSE
                      l_factor := 0;
                    END IF;

                    Control_Allocation  (
                        p_ship_header_id      => p_ship_header_id,
                        p_le_currency_code    => p_le_currency_code,
                        p_association_id      => p_association_id,
                        p_allocation_basis    => p_allocation_basis,
                        p_allocation_uom_code => p_allocation_uom_code,
                        p_amount              => p_amount * l_factor,
        ---- Bug 7706732, Bug 7708012 - Allocations that come from redirected allocations must be created
        ----                 with the original "from" component
        ----                           rec_component.component_name,
        ----                           rec_component.component_id,
                        p_from_component_name => p_from_component_name,
                        p_from_component_id   => p_from_component_id,
        ---- Bug 7706732, Bug 7708012
                        p_to_component_name   => assoc_List(iAssoc).to_parent_table_name,
                        p_to_component_id     => assoc_List(iAssoc).to_parent_table_id,
                        p_adjustment_num      => p_adjustment_num,
                        x_return_status       => l_return_status);

                    -- If any errors happen abort API.
                    IF l_return_status = L_FND_RET_STS_ERROR THEN
                       RAISE L_FND_EXC_ERROR;
                    ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                       RAISE L_FND_EXC_UNEXPECTED_ERROR;
                    END IF;

                END LOOP;
            END IF;
        END LOOP;
    END IF;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'p_to_component_name',
        p_var_value      => p_to_component_name);

    IF p_to_component_name IN ('INL_CHARGE_LINES','INL_TAX_LINES') THEN
        Insert_Allocation (
            p_ship_header_id      => p_ship_header_id,
            p_le_currency_code    => p_le_currency_code,
            p_association_id      => p_association_id,
            p_ship_line_id        => NULL,
            p_amount              => p_amount,
            p_from_component_name => p_from_component_name,
            p_from_component_id   => p_from_component_id,
            p_to_component_name   => p_to_component_name,
            p_to_component_id     => p_to_component_id,
            p_lc_flag             => 'N',
            p_adjustment_num      => p_adjustment_num,
            x_return_status       => l_return_status);

      -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
           RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
           RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSE
        --Bug#9660084
        -- SELECT DECODE(l_next_level_allocation,'N','Y','N')
        -- INTO l_lc_flag
        -- FROM DUAL;
        IF l_next_level_allocation = 'N' THEN
            l_lc_flag := 'Y';
        ELSE
            l_lc_flag := 'N';
        END IF;
        --Bug#9660084

        Manage_Allocation (
            p_ship_header_id      => p_ship_header_id,
            p_le_currency_code    => p_le_currency_code,
            p_association_id      => p_association_id,
            p_allocation_basis    => p_allocation_basis,
            p_allocation_uom_code => p_allocation_uom_code,
            p_amount              => p_amount,
            p_from_component_name => p_from_component_name,
            p_from_component_id   => p_from_component_id,
            p_to_component_name   => p_to_component_name,
            p_to_component_id     => p_to_component_id,
            p_lc_flag             => l_lc_flag,
            p_adjustment_num      => p_adjustment_num,
            x_return_status       => l_return_status);

        -- If any errors happen abort API.
        IF l_return_status = L_FND_RET_STS_ERROR THEN
           RAISE L_FND_EXC_ERROR;
        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
           RAISE L_FND_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;

    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

EXCEPTION
  WHEN L_FND_EXC_ERROR THEN
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name    => g_module_name,
    p_procedure_name => l_program_name);
    x_return_status := L_FND_RET_STS_ERROR;
  WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name    => g_module_name,
    p_procedure_name => l_program_name);
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name    => g_module_name,
    p_procedure_name => l_program_name);
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_program_name);
    END IF;

END Control_Allocation;

-- Utility name : Update_Allocation
-- Type         : Private
-- Function     : For actual amount allocations (adjustment_num > 0), stamp as the parent_allocation_id, the allocation_id
--                of corresponding estimated amount (adjustment_num = 0).
--
-- Pre-reqs     : None
-- Parameters   :
-- IN           : p_ship_header_id     IN NUMBER
--                p_adjustment_num     IN NUMBER,
-- OUT          : x_return_status      OUT NOCOPY VARCHAR2
--
--
PROCEDURE Update_Allocation  (
    p_ship_header_id    IN NUMBER,
    p_adjustment_num    IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2
) IS
   --
   --
   --
    CURSOR updalloc IS
      SELECT allocation_id,
             parent_allocation_id,
             ship_header_id,
             association_id,
             ship_line_id,
             adjustment_num
      FROM inl_allocations
--- SCM-051
---
      WHERE ABS(adjustment_num) = ABS(p_adjustment_num)
--- SCM-051
      AND ship_header_id   = p_ship_header_id
      ORDER BY allocation_id;
--    rec_updalloc updalloc%ROWTYPE;
    TYPE updalloc_ListType IS TABLE OF updalloc%ROWTYPE;  --Bulk implem
    updalloc_List updalloc_ListType;                      --Bulk implem

    l_debug_info      VARCHAR2(240);
    l_program_name  CONSTANT VARCHAR2(30) := 'Update_Allocation';
    l_return_status   VARCHAR2(1);

BEGIN

    INL_LOGGING_PVT.Log_BeginProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
--
--  Initialize return status to SUCCESS
--

    x_return_status := L_FND_RET_STS_SUCCESS;

    l_debug_info := 'p_ship_header_id';
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => l_debug_info,
        p_var_value      => TO_CHAR(p_ship_header_id));

    OPEN updalloc;
    FETCH updalloc BULK COLLECT INTO updalloc_List; --Bulk implem
    CLOSE updalloc;

    l_debug_info := 'Fetched '||NVL(updalloc_List.COUNT, 0)||' record(s).';
    INL_LOGGING_PVT.Log_Statement(
        p_module_name      => g_module_name,
        p_procedure_name   => l_program_name,
        p_debug_info       => l_debug_info
    ) ;

    IF NVL(updalloc_List.COUNT,0)>0
    THEN
        FOR iupdalloc IN 1 .. updalloc_List.COUNT --Bulk implem
        LOOP

            l_debug_info := 'Updating inl_allocations with parent_allocation_id';
            INL_LOGGING_PVT.Log_Statement (
                p_module_name     => g_module_name,
                p_procedure_name  => l_program_name,
                p_debug_info      => l_debug_info);

            UPDATE inl_allocations a1
            SET a1.parent_allocation_id = (SELECT MIN(a2.allocation_id)
                                            FROM inl_allocations a2
                                            WHERE a2.ship_header_id = updalloc_List(iUpdAlloc).ship_header_id
                                            AND NVL(a2.association_id,0) = NVL(updalloc_List(iUpdAlloc).association_id,0)
                                            AND (a2.ship_line_id = updalloc_List(iUpdAlloc).ship_line_id
                                            OR   a2.ship_line_id = (SELECT a.parent_ship_line_id
                                                                    FROM inl_ship_lines_all a
                                                                    WHERE a.ship_line_id = updalloc_List(iUpdAlloc).ship_line_id))

                                            AND a2.adjustment_num = 0
                                            AND NOT EXISTS (SELECT 'X' FROM inl_allocations a1
------ bug #7674125
                                                            WHERE NVL(a1.parent_allocation_id,0) = NVL(a2.allocation_id,0)
                                                            AND   a1.ship_header_id = a2.ship_header_id
                                                            AND   NVL(a1.association_id,0) = NVL(a2.association_id,0)
                                                            AND   a1.adjustment_num = updalloc_List(iUpdAlloc).adjustment_num
                                                            AND   a1.landed_cost_flag = 'Y' ))
            WHERE a1.allocation_id =  updalloc_List(iUpdAlloc).allocation_id
            AND   a1.adjustment_num = updalloc_List(iUpdAlloc).adjustment_num;

            l_debug_info := 'updalloc_List(iUpdAlloc).allocation_id';
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => l_debug_info,
                p_var_value      => TO_CHAR(updalloc_List(iUpdAlloc).allocation_id));

            l_debug_info := 'updalloc_List(iUpdAlloc).adjustment_num';
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => l_debug_info,
                p_var_value      => TO_CHAR(updalloc_List(iUpdAlloc).adjustment_num));

        END LOOP;
    END IF;
    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

EXCEPTION
  WHEN L_FND_EXC_ERROR THEN
    INL_LOGGING_PVT.Log_ExpecError (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    x_return_status := L_FND_RET_STS_ERROR;
  WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    INL_LOGGING_PVT.Log_UnexpecError (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);
    x_return_status := L_FND_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_program_name);
    END IF;
END Update_Allocation;

-- API name   : Run_Calculation
-- Type       : Private
-- Function   : Calculate Landed Costs for a given LCM Shipment.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version        IN NUMBER              Required
--              p_init_msg_list      IN VARCHAR2            Optional  Default = L_FND_FALSE
--              p_commit             IN VARCHAR2            Optional  Default = L_FND_FALSE
--              p_validation_level   IN NUMBER              Optional  Default = L_FND_VALID_LEVEL_FULL
--              p_ship_header_id     IN NUMBER              Required
--              p_calc_scope_code    IN NUMBER              Required  Default = 0
--                                                          0-Run for all components
--                                                          1-Run only for Item Price components
--                                                          2-Run only for Charge components
--                                                          3-Run only form Tax components
--
--              Although kept in the code, calculation scope is no longer used by this program.
--
-- OUT          x_return_status      OUT NOCOPY VARCHAR2
--              x_msg_count          OUT NOCOPY NUMBER
--              x_msg_data           OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Run_Calculation (
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 := L_FND_FALSE,
    p_commit            IN VARCHAR2 := L_FND_FALSE,
    p_validation_level  IN NUMBER   := L_FND_VALID_LEVEL_FULL,
    p_ship_header_id    IN NUMBER,
    p_calc_scope_code   IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2) IS

  CURSOR assoc (pc_adjustment_num IN NUMBER
    ) IS
    SELECT a.ship_header_id,
           a.from_parent_table_name,
           DECODE(a.from_parent_table_name,
            'INL_SHIP_LINES',
                (SELECT MAX(sl.ship_line_id)
                 FROM inl_ship_lines_all sl,
                      inl_ship_lines_all sl0
                 WHERE sl0.ship_line_id         = a.from_parent_table_id
                 AND   sl.ship_header_id        = sl0.ship_header_id
                 AND   sl.ship_line_group_id    = sl0.ship_line_group_id
                 AND   sl.ship_line_num         = sl0.ship_line_num

--- SCM-051
---              AND   (sl.adjustment_num      <= pc_adjustment_num
                 AND   (ABS(sl.adjustment_num) <= ABS(pc_adjustment_num)
--- SCM-051
                        OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                 ),
            'INL_CHARGE_LINES',
                (SELECT MAX(cl.charge_line_id)
                 FROM inl_charge_lines cl
--- SCM-051
---              WHERE cl.adjustment_num <= pc_adjustment_num
                 WHERE ABS(cl.adjustment_num) <= ABS(pc_adjustment_num)
--- SCM-051
                 START WITH cl.charge_line_id = a.from_parent_table_id
                 CONNECT BY PRIOR cl.charge_line_id = cl.parent_charge_line_id
                ),
            'INL_TAX_LINES',
                (SELECT MAX(tl.tax_line_id)
                 FROM inl_tax_lines tl
--- SCM-051
---              WHERE tl.adjustment_num <= pc_adjustment_num
                 WHERE ABS(tl.adjustment_num) <= ABS(pc_adjustment_num)
--- SCM-051
                 START WITH tl.tax_line_id = a.from_parent_table_id
                 CONNECT BY PRIOR tl.tax_line_id = tl.parent_tax_line_id
                 ),
           a.from_parent_table_id) from_parent_table_id,
           a.to_parent_table_name,
           DECODE(a.to_parent_table_name,
            'INL_SHIP_LINES',
                (SELECT MAX(sl.ship_line_id)
                 FROM inl_ship_lines_all sl,
                      inl_ship_lines_all sl0
                 WHERE sl0.ship_line_id         = a.to_parent_table_id
                 AND   sl.ship_header_id        = sl0.ship_header_id
                 AND   sl.ship_line_group_id    = sl0.ship_line_group_id
                 AND   sl.ship_line_num         = sl0.ship_line_num
--- SCM-051
---              AND   (sl.adjustment_num      <= pc_adjustment_num
                 AND   (ABS(sl.adjustment_num)      <= ABS(pc_adjustment_num)
--- SCM-051
                        OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*

                ),
            'INL_CHARGE_LINES',
                (SELECT MAX(cl.charge_line_id)
                 FROM inl_charge_lines cl
--- SCM-051
---              WHERE cl.adjustment_num <= pc_adjustment_num
                 WHERE ABS(cl.adjustment_num) <= ABS(pc_adjustment_num)
--- SCM-051
                 START WITH cl.charge_line_id = a.to_parent_table_id
                 CONNECT BY PRIOR cl.charge_line_id = cl.parent_charge_line_id
                ),
           a.to_parent_table_id) to_parent_table_id,
           a.allocation_basis,
           a.allocation_uom_code,
           a.association_id
    FROM inl_associations a
    WHERE DECODE(a.from_parent_table_name,
            'INL_SHIP_LINES',
                (SELECT MAX(sl.ship_line_id)
                 FROM inl_ship_lines_all sl,
                      inl_ship_lines_all sl0
                 WHERE sl0.ship_line_id         = a.from_parent_table_id
                 AND   sl.ship_header_id        = sl0.ship_header_id
                 AND   sl.ship_line_group_id    = sl0.ship_line_group_id
                 AND   sl.ship_line_num         = sl0.ship_line_num
--- SCM-051
---                 AND   (sl.adjustment_num        <= pc_adjustment_num
                 AND   (ABS(sl.adjustment_num)        <= ABS(pc_adjustment_num)
--- SCM-051
                        OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                 ),
            'INL_CHARGE_LINES',
                (SELECT MAX(cl.charge_line_id)
                 FROM inl_charge_lines cl
--- SCM-051
---                 WHERE cl.adjustment_num <= pc_adjustment_num
                 WHERE ABS(cl.adjustment_num) <= ABS(pc_adjustment_num)
--- SCM-051
                 START WITH cl.charge_line_id = a.from_parent_table_id
                 CONNECT BY PRIOR cl.charge_line_id = cl.parent_charge_line_id
                ),
            'INL_TAX_LINES',
                (SELECT MAX(tl.tax_line_id)
                 FROM inl_tax_lines tl
--- SCM-051
---                 WHERE tl.adjustment_num <= pc_adjustment_num
                 WHERE ABS(tl.adjustment_num) <= ABS(pc_adjustment_num)
--- SCM-051
                 START WITH tl.tax_line_id = a.from_parent_table_id
                 CONNECT BY PRIOR tl.tax_line_id = tl.parent_tax_line_id
                 )) IS NOT NULL
    AND ship_header_id = p_ship_header_id
ORDER BY from_parent_table_name,
         from_parent_table_id,
         to_parent_table_name,
         to_parent_table_id;

--    rec_assoc assoc%ROWTYPE;
    TYPE assoc_ListType IS TABLE OF assoc%ROWTYPE;  --Bulk implem
    assoc_List assoc_ListType;                      --Bulk implem

    CURSOR dist (pc_adjustment_num IN NUMBER
                 ) IS
      SELECT ship_header_id,
             ship_line_id,
             primary_qty,
-- bug 7660824
           DECODE(landed_cost_flag,'Y',ol.primary_unit_price * NVL(ol.currency_conversion_rate,1),0) fc_primary_unit_price
      FROM inl_ship_lines_all ol
      WHERE ol.ship_header_id = p_ship_header_id
      AND ol.ship_line_id = (SELECT MAX(sl.ship_line_id)
                             FROM inl_ship_lines_all sl
                             WHERE sl.ship_header_id = ol.ship_header_id --Bug#9660084
                             AND sl.ship_line_group_id = ol.ship_line_group_id --Bug#9660084
                             AND sl.ship_line_num = ol.ship_line_num --Bug#9660084
--- SCM-051
---                          AND (sl.adjustment_num <= pc_adjustment_num
                             AND (ABS(sl.adjustment_num) <= ABS(pc_adjustment_num)
--- SCM-051
                                  OR sl.ship_header_id <> p_ship_header_id) --Bug#10221931*
                               )
      ORDER BY ship_line_id;

--    rec_dist dist%ROWTYPE;
    TYPE dist_ListType IS TABLE OF dist%ROWTYPE;  --Bulk implem
    dist_List dist_ListType;                      --Bulk implem


    CURSOR charge (pc_adjustment_num IN NUMBER
    ) IS
      SELECT -- c.charge_amt, --BUG#9719618
             DECODE(c.landed_cost_flag,'Y',c.charge_amt,0) charge_amt,  --BUG#9719618
             c.currency_code,
             c.currency_conversion_type,
             c.currency_conversion_rate,
             c.currency_conversion_date,
             c.charge_line_id
      FROM inl_charge_lines c,
--Bug#13988746 BEG
      (
        SELECT DISTINCT a.from_parent_table_id
        FROM inl_associations a
        WHERE a.from_parent_table_name = 'INL_CHARGE_LINES'
        AND a.ship_header_id = p_ship_header_id
    ) X
--Bug#13988746 END
--- SCM-051
---         WHERE c.adjustment_num <= pc_adjustment_num --Bug#9660084
      WHERE ABS(c.adjustment_num) <= ABS(pc_adjustment_num)  --Bug#9660084
--Bug#13988746 BEG
      AND c.charge_line_id
          = (
            SELECT MAX(cl.charge_line_id)
            FROM inl_charge_lines cl
            WHERE cl.adjustment_num <= ABS(pc_adjustment_num) -- SCM-051
            START WITH cl.charge_line_id = x.from_parent_table_id
            CONNECT BY PRIOR cl.charge_line_id = cl.parent_charge_line_id
            )
--- SCM-051
     /*
      AND EXISTS (SELECT 'x'
                    FROM inl_associations x
                    WHERE x.from_parent_table_name = 'INL_CHARGE_LINES'
                    AND (SELECT MAX(cl.charge_line_id)
                         FROM inl_charge_lines cl
--- SCM-051
---                         WHERE cl.adjustment_num <= pc_adjustment_num
                         WHERE ABS(cl.adjustment_num) <= ABS(pc_adjustment_num)
--- SCM-051
                         START WITH cl.charge_line_id = x.from_parent_table_id
                         CONNECT BY PRIOR cl.charge_line_id = cl.parent_charge_line_id) = c.charge_line_id
                    AND x.ship_header_id = p_ship_header_id
                    AND ROWNUM < 2)*/
--Bug#13988746 END
      ORDER BY charge_line_id;
--    rec_charge charge%ROWTYPE;
    TYPE charge_ListType IS TABLE OF charge%ROWTYPE;  --Bulk implem
    charge_List charge_ListType;                      --Bulk implem

    CURSOR tax (pc_adjustment_num IN NUMBER
    ) IS
    SELECT tax_amt,
             tax_line_id
      FROM inl_tax_lines t --BUG#8330505
--Bug#14265778 BEG
      ,(
        SELECT DISTINCT a.from_parent_table_id
        FROM inl_associations a
        WHERE a.from_parent_table_name = 'INL_TAX_LINES'
        AND a.ship_header_id = p_ship_header_id
    ) X
--Bug#14265778 END
--- SCM-051
---      WHERE t.adjustment_num <= pc_adjustment_num --Bug#9660084
    WHERE ABS(t.adjustment_num) <= ABS(pc_adjustment_num) --Bug#9660084
--Bug#14265778 BEG
      AND t.tax_line_id = (
            SELECT MAX(tl.tax_line_id)
            FROM inl_tax_lines tl
--- SCM-051
---        WHERE tl.adjustment_num <= pc_adjustment_num
           WHERE ABS(tl.adjustment_num) <= ABS(pc_adjustment_num)
--- SCM-051
            START WITH tl.tax_line_id = x.from_parent_table_id
            CONNECT BY PRIOR tl.tax_line_id = tl.parent_tax_line_id
            )
/*
--- SCM-051
      AND EXISTS (SELECT 'x'
                    FROM inl_associations x
                    WHERE x.from_parent_table_name = 'INL_TAX_LINES'
                    AND (SELECT MAX(tl.tax_line_id)
                         FROM inl_tax_lines tl
--- SCM-051
---                         WHERE tl.adjustment_num <= pc_adjustment_num
                         WHERE ABS(tl.adjustment_num) <= ABS(pc_adjustment_num)
--- SCM-051
                         START WITH tl.tax_line_id = x.from_parent_table_id
                         CONNECT BY PRIOR tl.tax_line_id = tl.parent_tax_line_id) = t.tax_line_id
                    AND x.ship_header_id = p_ship_header_id
                    AND ROWNUM < 2)
*/
--Bug#14265778 END
      ORDER BY tax_line_id;
--    rec_tax tax%ROWTYPE;
    TYPE tax_ListType IS TABLE OF tax%ROWTYPE;  --Bulk implem
    tax_List tax_ListType;                      --Bulk implem

    l_amount              NUMBER;
    l_from_amount         NUMBER;
    l_to_amount           NUMBER;
    l_factor              NUMBER;
    l_count1              NUMBER;
    l_le_currency_code    VARCHAR2(3);
    l_lc_flag             VARCHAR2(1);
    l_inclusive_tax_amt   NUMBER;
    l_debug_info          VARCHAR2(240);
    l_program_name        CONSTANT VARCHAR2(30) := 'Run_Calculation';
    l_api_version         CONSTANT NUMBER := 1.0;
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_first_adjustment_num       NUMBER;
    l_last_adjustment_num        NUMBER;
    l_current_adjustment_num     NUMBER;
    l_ship_status_code    VARCHAR2(30);
    l_allocation_basis_uom_class VARCHAR2(30);
    l_total_amt           NUMBER;
    l_do_proportion       VARCHAR2(1);
    l_from_parent_table_name_brk VARCHAR2(30);
    l_from_parent_table_id_brk   NUMBER;
--- SCM-051
    l_i_adj           NUMBER;
--- SCM-051

--
-- Landed Cost Calculation engine is a process that captures the many amounts
-- of a given Landed Cost Shipment and prorates them down at the level of
-- Shipment Lines.
-- At the end of this process, all Shipment Lines of all receiving
-- items will have allocations coming from whatever is associated to their
-- parent components, as the example below:
--
-- Shipment SH1 contains 2 lines:
-- SL1 receiving item X, amount $100
-- SL2 receiving item Y, amount $100
--
-- $50 Charge CH1 is associated to SH1, indicating that the amount should be
-- prorated into all its lines (SL1 and SL2)
--
-- At the end of this process, Shipment Lines will have the following allocations:
--
-- SL1: Allocation 1:  $25 from CH1
--       Allocation 2: $100 from SL1 itself
--
-- SL2: Allocation 1:  $25 from CH1
--       Allocation 2: $100 from SL2 itself
--
-- At the highest level, the logic of this process is divided into 2 steps:
-- STEP 1: Allocation of Associated Amounts (SL1 Allocation 1, SL2 Allocation 1)
-- STEP 2: Allocation of Not Associated Amounts (SL1 Allocation 2, SL2 Allocation 2)
--

BEGIN

    INL_LOGGING_PVT.Log_BeginProc (p_module_name    => g_module_name,
                                   p_procedure_name => l_program_name);
--
-- Standard Start of API savepoint
--
    SAVEPOINT Run_Calculation_PVT;

--
-- Initialize message list if p_init_msg_list is set to TRUE
--
    IF FND_API.to_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

--
-- Standard call to check for call compatibility
--
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_program_name,
        G_PKG_NAME)
    THEN
        RAISE L_FND_EXC_UNEXPECTED_ERROR;
    END IF;

--
-- Initialize return status to SUCCESS
--
    x_return_status := L_FND_RET_STS_SUCCESS;


--- SCM-051
--
-- Get Functional Currency, Last Adjustment and Shipment Status
--

    l_debug_info := 'Get Functional Currency, Last Adjustment and Shipment Status';
    INL_LOGGING_PVT.Log_Statement (
        p_module_name     => g_module_name,
        p_procedure_name  => l_program_name,
        p_debug_info      => l_debug_info);

    SELECT DISTINCT
        gl.currency_code,
        oh.adjustment_num,
        oh.ship_status_code
    INTO
        l_le_currency_code,
        l_last_adjustment_num,
        l_ship_status_code
    FROM gl_ledgers gl,
         xle_fp_ou_ledger_v l,
         inl_ship_headers_all oh
    WHERE gl.ledger_id = l.ledger_id
    AND l.legal_entity_id = oh.legal_entity_id
    AND oh.ship_header_id = p_ship_header_id;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_le_currency_code',
        p_var_value      => l_le_currency_code);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_last_adjustment_num',
        p_var_value      => l_last_adjustment_num);
    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_ship_status_code',
        p_var_value      => l_ship_status_code);
--- SCM-051

--
-- Get First Adjustment to Process
--

--- SCM-051
    SELECT MAX(ABS(adjustment_num))
--- SCM-051
    INTO l_first_adjustment_num
    FROM inl_allocations
    WHERE ship_header_id = p_ship_header_id;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_first_adjustment_num',
        p_var_value      => l_first_adjustment_num);

    IF l_ship_status_code = 'COMPLETED' THEN
----Bug#10221931
----There was a charge/tax with association to more than one shipment, in this case,
----if any item actual impacts one of those shipments, all of them should be recalculated
----and a new adjustment number should be generated in order to send a new cost variation to
---- CST
----The "if" below represents the situation where the shipment is marked as pending_matching but
----there isn't a new line to be processed then l_first_adjustment_num = l_last_adjustment_num

--- SCM-051
        IF ABS(l_first_adjustment_num) = ABS(l_last_adjustment_num) THEN
                l_last_adjustment_num := ABS(l_last_adjustment_num) + 1;
--- SCM-051
            UPDATE inl_ship_headers_all
            SET
                adjustment_num = l_last_adjustment_num
            WHERE ship_header_id = p_ship_header_id;
        END IF;
----Bug#10221931
            l_first_adjustment_num := l_first_adjustment_num + 1;
    ELSE
          l_first_adjustment_num := 0;
    END IF;

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_first_adjustment_num',
        p_var_value      => l_first_adjustment_num);

    INL_LOGGING_PVT.Log_Variable (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name,
        p_var_name       => 'l_last_adjustment_num',
        p_var_value      => l_last_adjustment_num);
---- SCM-LCM-010
---- Loop to determine for what Adjustments we have to run the calculation
----
    BEGIN
--- SCM-051
---     FOR i IN l_first_adjustment_num..l_last_adjustment_num LOOP
        l_i_adj := l_first_adjustment_num;
        LOOP
            INL_LOGGING_PVT.Log_Variable (
                p_module_name    => g_module_name,
                p_procedure_name => l_program_name,
                p_var_name       => 'l_i_adj',
                p_var_value      => l_i_adj);
            EXIT WHEN (ABS(l_i_adj) > ABS(l_last_adjustment_num));
--- SCM-051
/* --Bug#14081759 BEG
            SELECT NVL(MIN(x.adjustment_num), l_last_adjustment_num) --Bug#10221931
            INTO l_current_adjustment_num
            FROM (SELECT sl.adjustment_num adjustment_num
                  FROM inl_ship_lines_all sl
                  WHERE sl.ship_header_id = p_ship_header_id
                  UNION ALL
                  SELECT sl.adjustment_num adjustment_num
                  FROM inl_ship_lines_all sl
                  WHERE EXISTS (SELECT 'X'
                                FROM inl_associations a
                                WHERE a.ship_header_id = p_ship_header_id
                                AND a.from_parent_table_name = 'INL_SHIP_LINES'
                                AND a.from_parent_table_id = sl.ship_line_id)
                  UNION ALL
                  SELECT cl.adjustment_num adjustment_num
                  FROM inl_charge_lines cl
                  WHERE EXISTS (SELECT 'X'
                                FROM inl_associations a
                                WHERE a.ship_header_id = p_ship_header_id
                                AND a.from_parent_table_name = 'INL_CHARGE_LINES'
                                AND a.from_parent_table_id = cl.charge_line_id)
                  UNION ALL
                  SELECT tl.adjustment_num adjustment_num
                  FROM inl_tax_lines tl
                  WHERE EXISTS (SELECT 'X'
                                FROM inl_associations a
                                WHERE a.ship_header_id = p_ship_header_id
                                AND a.from_parent_table_name = 'INL_TAX_LINES'
                                AND a.from_parent_table_id = tl.tax_line_id)) x
--- SCM-051
            WHERE ABS(x.adjustment_num) >= ABS(l_i_adj)
            AND ABS(x.adjustment_num) <= ABS(l_last_adjustment_num);
--- SCM-051
*/
            SELECT
              MIN
              (LEAST
              ((    SELECT NVL(MIN(ABS(sl.adjustment_num)),l_last_adjustment_num)
                    FROM inl_ship_lines_all sl
                    WHERE sl.ship_header_id = p_ship_header_id
                    AND ABS(sl.adjustment_num) >= ABS(l_i_adj)
                    AND ABS(sl.adjustment_num) <= ABS(l_last_adjustment_num)
                ),
                (   SELECT NVL(MIN(ABS(cl.adjustment_num)),l_last_adjustment_num)
                    FROM inl_charge_lines cl
                    WHERE a.from_parent_table_name = 'INL_CHARGE_LINES'
                    AND ABS(cl.adjustment_num) >= ABS(l_i_adj)
                    AND ABS(cl.adjustment_num) <= ABS(l_last_adjustment_num)
                    START WITH cl.charge_line_id = a.from_parent_table_id
                    CONNECT BY PRIOR cl.charge_line_id = cl.parent_charge_line_id
               ),
                (   SELECT NVL(MIN(ABS(tl.adjustment_num)),l_last_adjustment_num)
                    FROM inl_tax_lines tl
                    WHERE a.from_parent_table_name = 'INL_TAX_LINES'
                    AND ABS(tl.adjustment_num) >= ABS(l_i_adj)
                    AND ABS(tl.adjustment_num) <= ABS(l_last_adjustment_num)
                    START WITH tl.tax_line_id = a.from_parent_table_id
                    CONNECT BY PRIOR tl.tax_line_id = tl.parent_tax_line_id
               )
               )) adj_num
            INTO l_current_adjustment_num
            FROM
                inl_associations a,
                inl_ship_headers_all sh
            WHERE a.ship_header_id(+)   = sh.ship_header_id
            AND sh.ship_header_id       = p_ship_header_id
            ;
--Bug#14081759 END
            INL_LOGGING_PVT.Log_Variable (
                  p_module_name    => g_module_name,
                  p_procedure_name => l_program_name,
                  p_var_name       => 'l_current_adjustment_num',
                  p_var_value      => l_current_adjustment_num);
--- SCM-051
            INL_LOGGING_PVT.Log_Variable (
                  p_module_name    => g_module_name,
                  p_procedure_name => l_program_name,
                  p_var_name       => 'l_i_adj',
                  p_var_value      => l_i_adj);
--- SCM-051

--- SCM-051
            IF ABS(l_i_adj) = ABS(l_current_adjustment_num) THEN
--- SCM-051
                l_debug_info := 'l_first_adjustment_num';
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => l_debug_info,
                    p_var_value      => l_first_adjustment_num);
                l_debug_info := 'l_last_adjustment_num';
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => l_debug_info,
                    p_var_value      => l_last_adjustment_num);
                l_debug_info := 'l_current_adjustment_num';
                INL_LOGGING_PVT.Log_Variable (
                    p_module_name    => g_module_name,
                    p_procedure_name => l_program_name,
                    p_var_name       => l_debug_info,
                    p_var_value      => l_current_adjustment_num);


                --
                -- For not adjusted shipments, check for Associations in Loop
                --

                IF l_current_adjustment_num = 0 THEN

                    l_debug_info := 'Check for Associations in Loop';
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name     => g_module_name,
                        p_procedure_name  => l_program_name,
                        p_debug_info      => l_debug_info);

                    OPEN assoc(l_current_adjustment_num
                    );
                    FETCH assoc BULK COLLECT INTO assoc_List; --Bulk implem
                    CLOSE assoc;

                    l_debug_info := 'Fetched '||NVL(assoc_List.COUNT, 0)||' association(s).';
                    INL_LOGGING_PVT.Log_Statement(
                        p_module_name      => g_module_name,
                        p_procedure_name   => l_program_name,
                        p_debug_info       => l_debug_info
                    ) ;
                    IF NVL(assoc_List.COUNT,0)>0
                    THEN
                        FOR iAssoc IN 1 .. assoc_List.COUNT --Bulk implem
                        LOOP

                            IF InLoop_Association (
                                    assoc_List(iAssoc).ship_header_id,
                                    assoc_List(iAssoc).from_parent_table_name,
                                    assoc_List(iAssoc).from_parent_table_id,
                                    l_return_status)
                            THEN
                                FND_MESSAGE.SET_NAME('INL','INL_ERR_CHK_IN_LOOP_ASSOC');
                                FND_MSG_PUB.Add;
                                RAISE L_FND_EXC_ERROR;
                            END IF;

                            -- If any errors happen abort API.
                            IF l_return_status = L_FND_RET_STS_ERROR THEN
                               RAISE L_FND_EXC_ERROR;
                            ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                               RAISE L_FND_EXC_UNEXPECTED_ERROR;
                            END IF;

                        END LOOP;
                    END IF;

                END IF;

                --
                -- Remove previous allocations
                --

                l_debug_info := 'Remove previous allocations';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name     => g_module_name,
                    p_procedure_name  => l_program_name,
                    p_debug_info      => l_debug_info);

                DELETE FROM INL_allocations
                WHERE ship_header_id = p_ship_header_id
                  AND ABS(adjustment_num) = ABS(l_current_adjustment_num);
                --SCM-051
                l_debug_info:=l_debug_info||' => '||sql%ROWCOUNT;
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name     => g_module_name,
                    p_procedure_name  => l_program_name,
                    p_debug_info      => l_debug_info);
                --SCM-051
                --
                -- STEP 1 - Allocation of Associated Amounts
                --

                l_debug_info := 'STEP 1: Allocation of Associated Amounts';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name     => g_module_name,
                    p_procedure_name  => l_program_name,
                    p_debug_info      => l_debug_info);

                l_from_parent_table_name_brk := '-1';
                l_from_parent_table_id_brk := -1;

                OPEN assoc( l_current_adjustment_num
                );
                FETCH assoc BULK COLLECT INTO assoc_List; --Bulk implem
                CLOSE assoc;

                l_debug_info := 'Fetched '||NVL(assoc_List.COUNT, 0)||' association(s).';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info
                ) ;
                IF NVL(assoc_List.COUNT,0)>0
                THEN
                    FOR iAssoc IN 1 .. assoc_List.COUNT --Bulk implem
                    LOOP

                        l_debug_info := 'Fetching Associations cursor';
                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name     => g_module_name,
                            p_procedure_name  => l_program_name,
                            p_debug_info      => l_debug_info);

                        l_amount := 0;
                        l_from_amount := 0;
                        l_to_amount := 0;

                        l_debug_info := 'assoc_List(iAssoc).from_parent_table_name';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => assoc_List(iAssoc).from_parent_table_name);

                        l_debug_info := 'assoc_List(iAssoc).from_parent_table_id';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => TO_CHAR(assoc_List(iAssoc).from_parent_table_id));

                        l_debug_info := 'assoc_List(iAssoc).to_parent_table_name';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => assoc_List(iAssoc).to_parent_table_name);

                        l_debug_info := 'assoc_List(iAssoc).to_parent_table_id';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => TO_CHAR(assoc_List(iAssoc).to_parent_table_id));

                        l_debug_info := 'assoc_List(iAssoc).association_id';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => assoc_List(iAssoc).association_id);


                        IF assoc_List(iAssoc).from_parent_table_name = 'INL_CHARGE_LINES' THEN
    ----                    Bug #9215498
    ----                    SELECT Converted_Amt (charge_amt,
    ----                                          currency_code,
    ----                                          l_le_currency_code,
    ----                                          currency_conversion_type,
    ----                                          currency_conversion_date)
                            SELECT DECODE(cl.landed_cost_flag,'Y',NVL(cl.charge_amt,0) * NVL(cl.currency_conversion_rate,1),0)  --BUG#9719618
                            INTO l_from_amount
                            FROM inl_charge_lines cl
                            WHERE cl.charge_line_id = assoc_List(iAssoc).from_parent_table_id;
                        ELSIF assoc_List(iAssoc).from_parent_table_name = 'INL_TAX_LINES' THEN
                            SELECT NVL(SUM(nrec_tax_amt),0)
                            INTO l_from_amount
                            FROM inl_tax_lines tl --BUG#8330505
                            WHERE tl.tax_line_id = assoc_List(iAssoc).from_parent_table_id;
                        ELSIF assoc_List(iAssoc).from_parent_table_name = 'INL_SHIP_HEADERS' THEN
    ----BUG#971 9618        SELECT SUM(NVL(ol.primary_qty,0)*NVL(                            ol.primary_unit_price * NVL(ol.currency_conversion_rate,1),0))
                            SELECT SUM(NVL(ol.primary_qty,0)*NVL(DECODE(ol.landed_cost_flag,'Y',ol.primary_unit_price * NVL(ol.currency_conversion_rate,1),0),0)) --BUG#9719618
                            INTO l_from_amount
                            FROM inl_ship_lines_all ol
                            WHERE ol.ship_header_id = assoc_List(iAssoc).from_parent_table_id;
                        ELSIF assoc_List(iAssoc).from_parent_table_name = 'INL_SHIP_LINES' THEN
    ---- bug 7660824
                           SELECT SUM(NVL(ol.primary_qty,0)*NVL(DECODE(ol.landed_cost_flag,'Y',ol.primary_unit_price * NVL(ol.currency_conversion_rate,1),0),0))
                           INTO l_from_amount
                           FROM inl_ship_lines_all ol
                           WHERE ol.ship_line_id = assoc_List(iAssoc).from_parent_table_id;
                        END IF;

                        l_debug_info := 'l_from_amount';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => TO_CHAR(l_from_amount));

                        l_amount := l_from_amount;

                        l_debug_info := 'l_amount';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => TO_CHAR(l_amount));

                        IF l_amount <> 0 THEN
                          IF l_from_parent_table_name_brk <> assoc_List(iAssoc).from_parent_table_name OR
                             l_from_parent_table_id_brk <> assoc_List(iAssoc).from_parent_table_id
                          THEN
                            l_from_parent_table_name_brk := assoc_List(iAssoc).from_parent_table_name;
                            l_from_parent_table_id_brk := assoc_List(iAssoc).from_parent_table_id;
                            l_debug_info := 'Call Get_TotalAmt';
                            INL_LOGGING_PVT.Log_Statement (
                                p_module_name     => g_module_name,
                                p_procedure_name  => l_program_name,
                                p_debug_info      => l_debug_info);
                            Get_TotalAmt (
                                p_ship_header_id      => assoc_List(iAssoc).ship_header_id,
                                p_adjustment_num      => l_current_adjustment_num,
                                p_le_currency_code    => l_le_currency_code,
                                p_from_component_name => assoc_List(iAssoc).from_parent_table_name,
                                p_from_component_id   => assoc_List(iAssoc).from_parent_table_id,
                                p_to_component_name   => assoc_List(iAssoc).to_parent_table_name,
                                p_to_component_id     => assoc_List(iAssoc).to_parent_table_id,
                                p_allocation_basis    => assoc_List(iAssoc).allocation_basis,
                                p_allocation_uom_code => assoc_List(iAssoc).allocation_uom_code,
                                x_total_amt           => l_total_amt,
                                x_do_proportion       => l_do_proportion,
                                x_return_status       => l_return_status);
                            -- If any errors happen abort API.
                            IF l_return_status = L_FND_RET_STS_ERROR THEN
                               RAISE L_FND_EXC_ERROR;
                                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                               RAISE L_FND_EXC_UNEXPECTED_ERROR;
                            END IF;
                          END IF;
                          IF l_do_proportion = 'Y' THEN
                            l_debug_info := 'Call Manage_Proportion';
                            INL_LOGGING_PVT.Log_Statement (
                                p_module_name     => g_module_name,
                                p_procedure_name  => l_program_name,
                                p_debug_info      => l_debug_info);
                            Manage_Proportion (
                                p_ship_header_id      => assoc_List(iAssoc).ship_header_id,
                                p_adjustment_num      => l_current_adjustment_num,
                                p_le_currency_code    => l_le_currency_code,
                                p_from_component_name => assoc_List(iAssoc).from_parent_table_name,
                                p_from_component_id   => assoc_List(iAssoc).from_parent_table_id,
                                p_to_component_name   => assoc_List(iAssoc).to_parent_table_name,
                                p_to_component_id     => assoc_List(iAssoc).to_parent_table_id,
                                p_allocation_basis    => assoc_List(iAssoc).allocation_basis,
                                p_allocation_uom_code => assoc_List(iAssoc).allocation_uom_code,
                                p_total_amt           => l_total_amt,
                                o_factor              => l_factor,
                                x_return_status       => l_return_status);
                            -- If any errors happen abort API.
                            IF l_return_status = L_FND_RET_STS_ERROR THEN
                               RAISE L_FND_EXC_ERROR;
                                ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                               RAISE L_FND_EXC_UNEXPECTED_ERROR;
                            END IF;
                          ELSE
                            l_factor := 1;
                          END IF;
                        ELSE
                          l_factor := 0;
                        END IF;

                        l_amount := l_amount * l_factor;

                        l_debug_info := 'Call to Control_Allocation';
                        INL_LOGGING_PVT.Log_Statement (p_module_name     => g_module_name,
                                                       p_procedure_name  => l_program_name,
                                                       p_debug_info      => l_debug_info);

                        Control_Allocation (
                            p_ship_header_id      => assoc_List(iAssoc).ship_header_id,
                            p_le_currency_code    => l_le_currency_code,
                            p_association_id      => assoc_List(iAssoc).association_id,
                            p_allocation_basis    => assoc_List(iAssoc).allocation_basis,
                            p_allocation_uom_code => assoc_List(iAssoc).allocation_uom_code,
                            p_amount              => l_amount,
                            p_from_component_name => assoc_List(iAssoc).from_parent_table_name,
                            p_from_component_id   => assoc_List(iAssoc).from_parent_table_id,
                            p_to_component_name   => assoc_List(iAssoc).to_parent_table_name,
                            p_to_component_id     => assoc_List(iAssoc).to_parent_table_id,
                            p_adjustment_num      => l_current_adjustment_num,
                            x_return_status       => l_return_status);

                        -- If any errors happen abort API.
                        IF l_return_status = L_FND_RET_STS_ERROR THEN
                           RAISE L_FND_EXC_ERROR;
                        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                           RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;

                    END LOOP;
                END IF;

                --
                -- STEP 2 - Allocation of Not Associated Amounts
                --

                l_debug_info := 'STEP 2 - Allocation of Not Associated Amounts';
                INL_LOGGING_PVT.Log_Statement (
                    p_module_name     => g_module_name,
                    p_procedure_name  => l_program_name,
                    p_debug_info      => l_debug_info);

                l_count1 := 0;

                OPEN dist(l_current_adjustment_num
                );
                FETCH dist BULK COLLECT INTO dist_List; --Bulk implem
                CLOSE dist;
                l_debug_info := 'Fetched '||NVL(dist_List.COUNT, 0)||' line(s).';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info
                ) ;

                IF NVL(dist_List.COUNT,0)>0
                THEN
                    FOR idist IN 1 .. dist_List.COUNT --Bulk implem
                    LOOP

                        l_count1 := 0;

                        l_debug_info := 'Fetching Distributions cursor';
                        INL_LOGGING_PVT.Log_Statement (
                            p_module_name     => g_module_name,
                            p_procedure_name  => l_program_name,
                            p_debug_info      => l_debug_info);

                        SELECT COUNT(*) + l_count1
                        INTO l_count1
                        FROM inl_associations
                        WHERE from_parent_table_name = 'INL_SHIP_LINES'
                        AND from_parent_table_id = dist_List(iDist).ship_line_id;

                        SELECT COUNT(*) + l_count1
                        INTO l_count1
                        FROM inl_associations
                        WHERE from_parent_table_name = 'INL_SHIP_HEADERS'
                        AND from_parent_table_id = dist_List(iDist).ship_header_id;

                        --Bug#9660084
                        -- SELECT DECODE(l_count1,0,'Y','N') INTO l_lc_flag FROM DUAL;
                        IF l_count1 = 0 THEN
                            l_lc_flag := 'Y';
                        ELSE
                            l_lc_flag := 'N';
                        END IF;
                        --Bug#9660084

                        l_debug_info := 'dist_List('||iDist||').ship_line_id';
                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name       => l_debug_info,
                            p_var_value      => TO_CHAR(dist_List(iDist).ship_line_id));

                        INL_LOGGING_PVT.Log_Variable (
                            p_module_name    => g_module_name,
                            p_procedure_name => l_program_name,
                            p_var_name       => 'l_lc_flag',
                            p_var_value      => l_lc_flag);

                        -- Get Inclusive Taxes

                        l_inclusive_tax_amt := 0;

                        SELECT SUM(NVL(al.allocation_amt,0))
                        INTO l_inclusive_tax_amt
                        FROM
                             inl_tax_lines t, --BUG#8330505
                             inl_associations assoc,
                             inl_allocations al
                        WHERE t.tax_amt_included_flag = 'Y'
                        AND t.tax_line_id = (SELECT MAX(tl.tax_line_id)
                                             FROM inl_tax_lines tl
--- SCM-051
---                                          WHERE tl.adjustment_num <= l_current_adjustment_num
                                             WHERE ABS(tl.adjustment_num) <= ABS(l_current_adjustment_num)
--- SCM-051
                                             START WITH tl.tax_line_id = assoc.from_parent_table_id
                                             CONNECT BY PRIOR tl.tax_line_id = tl.parent_tax_line_id)
                        AND assoc.from_parent_table_name = 'INL_TAX_LINES'
                        AND assoc.association_id = al.association_id
                        AND al.ship_line_id = dist_List(iDist).ship_line_id
                        AND ABS(al.adjustment_num) = ABS(l_current_adjustment_num);

                        Insert_Allocation (
                            p_ship_header_id      => p_ship_header_id,
                            p_le_currency_code    => l_le_currency_code,
                            p_association_id      => NULL,
                            p_ship_line_id        => dist_List(iDist).ship_line_id,
                            p_amount              => (NVL(dist_List(iDist).primary_qty,0)*NVL(dist_List(iDist).fc_primary_unit_price,0))-NVL(l_inclusive_tax_amt,0),
                            p_from_component_name => 'INL_SHIP_DISTS',
                            p_from_component_id   => dist_List(iDist).ship_line_id,
                            p_to_component_name   => 'INL_SHIP_DISTS',
                            p_to_component_id     => dist_List(iDist).ship_line_id,
                            p_lc_flag             => l_lc_flag,
                            p_adjustment_num      => l_current_adjustment_num,
                            x_return_status       => l_return_status
                        );
                        -- If any errors happen abort API.
                        IF l_return_status = L_FND_RET_STS_ERROR THEN
                           RAISE L_FND_EXC_ERROR;
                        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                           RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;

                    END LOOP;
                END IF;

                OPEN charge(l_current_adjustment_num
                );
                FETCH charge BULK COLLECT INTO charge_List; --Bulk implem
                CLOSE charge;
                l_debug_info := 'Fetched '||NVL(charge_List.COUNT, 0)||' charge(s).';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info
                ) ;
                IF NVL(charge_List.COUNT,0)>0
                THEN
                    FOR icharge IN 1 .. charge_List.COUNT --Bulk implem
                    LOOP

                        Insert_Allocation (
                            p_ship_header_id      => p_ship_header_id,
                            p_le_currency_code    => l_le_currency_code,
                            p_association_id      => NULL,
                            p_ship_line_id        => NULL,
                            p_amount              => charge_List(iCharge).charge_amt * NVL(charge_List(iCharge).currency_conversion_rate,1),
                            p_from_component_name => 'INL_CHARGE_LINES',
                            p_from_component_id   => charge_List(iCharge).charge_line_id,
                            p_to_component_name   => 'INL_CHARGE_LINES',
                            p_to_component_id     => charge_List(iCharge).charge_line_id,
                            p_lc_flag             => 'N',
                            p_adjustment_num      => l_current_adjustment_num,
                            x_return_status       => l_return_status);
                        -- If any errors happen abort API.
                        IF l_return_status = L_FND_RET_STS_ERROR THEN
                           RAISE L_FND_EXC_ERROR;
                        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                           RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;
                    END LOOP;
                END IF;

                OPEN tax(l_current_adjustment_num
                );
                FETCH tax BULK COLLECT INTO tax_List; --Bulk implem
                CLOSE tax;
                l_debug_info := 'Fetched '||NVL(tax_List.COUNT, 0)||' tax(s).';
                INL_LOGGING_PVT.Log_Statement(
                    p_module_name      => g_module_name,
                    p_procedure_name   => l_program_name,
                    p_debug_info       => l_debug_info
                ) ;

                IF NVL(tax_List.COUNT,0)>0
                THEN
                    FOR itax IN 1 .. tax_List.COUNT --Bulk implem
                    LOOP

                        Insert_Allocation (
                            p_ship_header_id      => p_ship_header_id,
                            p_le_currency_code    => l_le_currency_code,
                            p_association_id      => NULL,
                            p_ship_line_id        => NULL,
                            p_amount              => NVL(tax_List(iTax).tax_amt,0),
                            p_from_component_name => 'INL_TAX_LINES',
                            p_from_component_id   => tax_List(iTax).tax_line_id,
                            p_to_component_name   => 'INL_TAX_LINES',
                            p_to_component_id     => tax_List(iTax).tax_line_id,
                            p_lc_flag             => 'N',
                            p_adjustment_num      => l_current_adjustment_num,
                            x_return_status       => l_return_status);
                        -- If any errors happen abort API.
                        IF l_return_status = L_FND_RET_STS_ERROR THEN
                           RAISE L_FND_EXC_ERROR;
                        ELSIF l_return_status = L_FND_RET_STS_UNEXP_ERROR THEN
                           RAISE L_FND_EXC_UNEXPECTED_ERROR;
                        END IF;

                    END LOOP;
                END IF;

                -- Bug#16719865 BEGIN
                -- Update_Allocation  REMOVED
                -- The update has been simplified and included in Run_Calculation procedure

                IF l_current_adjustment_num = 0 THEN
                    l_debug_info := '0- Updating inl_allocations with parent_allocation_id';
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name     => g_module_name,
                        p_procedure_name  => l_program_name,
                        p_debug_info      => l_debug_info);

                    UPDATE inl_allocations a1
                    SET a1.parent_allocation_id = a1.allocation_id
                    WHERE a1.ship_header_id =  p_ship_header_id
                    AND   a1.adjustment_num = l_current_adjustment_num;

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => l_debug_info,
                        p_var_value      => '0- UPDATED: '||SQL%ROWCOUNT||' records');

                ELSE
                    l_debug_info := 'Updating inl_allocations with parent_allocation_id';
                    INL_LOGGING_PVT.Log_Statement (
                        p_module_name     => g_module_name,
                        p_procedure_name  => l_program_name,
                        p_debug_info      => l_debug_info);

                    UPDATE inl_allocations a1
                    SET a1.parent_allocation_id = (SELECT MIN(a2.allocation_id)
                                                    FROM inl_allocations a2
                                                    WHERE a2.ship_header_id = p_ship_header_id
                                                    AND NVL(a2.association_id,0) = NVL(a1.association_id,0)
                                                    AND (a2.ship_line_id = a1.ship_line_id
                                                    OR   a2.ship_line_id = (SELECT a.parent_ship_line_id
                                                                            FROM inl_ship_lines_all a
                                                                            WHERE a.ship_line_id = a1.ship_line_id))
                                                    AND a2.adjustment_num = 0
                                                    AND NOT EXISTS (SELECT 'X' FROM inl_allocations a3
                                                                    WHERE NVL(a3.parent_allocation_id,0) = NVL(a2.allocation_id,0)
                                                                    AND   a3.ship_header_id = a2.ship_header_id
                                                                    AND   NVL(a3.association_id,0) = NVL(a2.association_id,0)
                                                                    AND   a3.adjustment_num = l_current_adjustment_num
                                                                    AND   a3.landed_cost_flag = 'Y' ))
                    WHERE a1.ship_header_id =  p_ship_header_id
                    AND   a1.adjustment_num = l_current_adjustment_num;

                    INL_LOGGING_PVT.Log_Variable (
                        p_module_name    => g_module_name,
                        p_procedure_name => l_program_name,
                        p_var_name       => l_debug_info,
                        p_var_value      => 'UPDATED: '||SQL%ROWCOUNT||' records');
                END IF;
                -- Bug#16719865 END
                -- Update_Allocation  REMOVED
                -- The update has been simplified and included in Run_Calculation procedure

            END IF;-- Bug #8869735
--- SCM-051
              l_i_adj := l_i_adj + 1;
--- SCM-051
        END LOOP;
    END;

--
-- Standard check for commit
--
    IF FND_API.To_Boolean (p_commit) THEN
          COMMIT WORK;
    END IF;

-- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (
        p_encoded =>      L_FND_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

    INL_LOGGING_PVT.Log_EndProc (
        p_module_name    => g_module_name,
        p_procedure_name => l_program_name);

EXCEPTION
    WHEN L_FND_EXC_ERROR THEN
        INL_LOGGING_PVT.Log_ExpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        ROLLBACK TO Run_Calculation_PVT;
        x_return_status := L_FND_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
           p_encoded => L_FND_FALSE,
           p_count   => x_msg_count,
           p_data    => x_msg_data);
    WHEN L_FND_EXC_UNEXPECTED_ERROR THEN
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        ROLLBACK TO Run_Calculation_PVT;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => L_FND_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
    WHEN OTHERS THEN
        INL_LOGGING_PVT.Log_UnexpecError (
            p_module_name    => g_module_name,
            p_procedure_name => l_program_name);
        ROLLBACK TO Run_Calculation_PVT;
        x_return_status := L_FND_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_program_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(
             p_encoded => L_FND_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data);
END Run_Calculation;

END INL_LANDEDCOST_PVT;

/
