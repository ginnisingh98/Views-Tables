--------------------------------------------------------
--  DDL for Package Body CSTPSCHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPSCHO" AS
/* $Header: CSTSCHOB.pls 115.4 2002/11/11 22:56:31 awwang ship $ */

FUNCTION get_buy_cost_hook (
p_rollup_id             IN      NUMBER,
p_assignment_set_id     IN      NUMBER,
p_item_id               IN      NUMBER,
p_organization_id       IN      NUMBER,
p_vendor_id             IN      NUMBER,
p_site_id		IN	NUMBER,
p_ship_method		IN	NUMBER,
x_err_code              OUT NOCOPY     NUMBER,
x_err_buf               OUT NOCOPY     VARCHAR2
)
RETURN INTEGER
IS
l_buy_cost  NUMBER;
l_stmt_num  NUMBER;
BEGIN

    l_stmt_num := 10;
    l_buy_cost := -1;

    x_err_code := 0;
    x_err_buf := 'CSTPSCHK.get_buy_cost_hook' ||': Returned Success';

    return l_buy_cost;

EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := 'CSTPSCHK.get_buy_cost_hook' ||'stmt_num='||l_stmt_num||' : '||substrb(sqlerrm,1,60);

        return -1;


END get_buy_cost_hook;

PROCEDURE get_markup_hook (
p_rollup_id             IN      NUMBER,
p_item_id               IN      NUMBER,
p_dest_organization_id  IN      NUMBER,
p_src_organization_id   IN      NUMBER,
p_sc_cost_type_id       IN      NUMBER,
p_buy_cost_type_id      IN      NUMBER,
x_markup                OUT NOCOPY     NUMBER,
x_markup_code           OUT NOCOPY     NUMBER,
x_err_code              OUT NOCOPY     NUMBER,
x_err_buf               OUT NOCOPY     VARCHAR2
)
IS
l_stmt_num  NUMBER;
BEGIN
    l_stmt_num := 10;
    x_markup_code := -1;
    x_markup := NULL;

    x_err_code := 0;
    x_err_buf := 'CSTPSCHK.get_markup_hook' ||': Returned Success';

    return;

EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := 'CSTPSCHK.get_markup_hook' ||'stmt_num='||l_stmt_num||' : '||substrb(sqlerrm,1,60);

        x_markup_code := -1;
        x_markup := NULL;

        return;


END get_markup_hook;


PROCEDURE get_shipping_hook (
p_rollup_id             IN      NUMBER,
p_item_id               IN      NUMBER,
p_dest_organization_id  IN      NUMBER,
p_src_organization_id   IN      NUMBER,
p_sc_cost_type_id       IN      NUMBER,
p_buy_cost_type_id      IN      NUMBER,
x_ship_method           IN      VARCHAR2,
x_ship_charge           OUT NOCOPY     NUMBER,
x_ship_charge_code    OUT NOCOPY     NUMBER,
x_err_code              OUT NOCOPY     NUMBER,
x_err_buf               OUT NOCOPY     VARCHAR2
)
IS
l_stmt_num  NUMBER;
BEGIN
    l_stmt_num := 10;
    x_ship_charge_code := -1;
    x_ship_charge := NULL;

    x_err_code := 0;
    x_err_buf := 'CSTPSCHK.get_shipping_hook' ||': Returned Success';

    return;

EXCEPTION
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        x_err_buf := 'CSTPSCHK.get_shipping_hook' ||'stmt_num='||l_stmt_num||' :
		 ' ||substrb(sqlerrm,1,60);

        x_ship_charge_code := -1;
        x_ship_charge := NULL;

        return;

END get_shipping_hook;


END CSTPSCHO;

/
