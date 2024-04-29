--------------------------------------------------------
--  DDL for Package CSTPSCHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPSCHO" AUTHID CURRENT_USER AS
/* $Header: CSTSCHOS.pls 115.4 2002/11/11 22:56:46 awwang ship $ */

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
RETURN INTEGER;


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
);

PROCEDURE get_shipping_hook (
p_rollup_id             IN      NUMBER,
p_item_id               IN      NUMBER,
p_dest_organization_id  IN      NUMBER,
p_src_organization_id   IN      NUMBER,
p_sc_cost_type_id	IN	NUMBER,
p_buy_cost_type_id	IN	NUMBER,
x_ship_method		IN	VARCHAR2,
x_ship_charge           OUT NOCOPY     NUMBER,
x_ship_charge_code    OUT NOCOPY     NUMBER,
x_err_code              OUT NOCOPY     NUMBER,
x_err_buf               OUT NOCOPY     VARCHAR2
);


END CSTPSCHO;

 

/
