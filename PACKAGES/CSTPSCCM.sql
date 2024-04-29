--------------------------------------------------------
--  DDL for Package CSTPSCCM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPSCCM" AUTHID CURRENT_USER AS
/* $Header: CSTSCCMS.pls 120.1 2007/12/19 08:08:59 smsasidh ship $ */

FUNCTION merge_costs (
p_rollup_id             IN      NUMBER,
p_dest_cost_type_id     IN      NUMBER,
p_buy_cost_type_id      IN      NUMBER,
p_inventory_item_id     IN      NUMBER,
p_dest_organization_id  IN      NUMBER,
p_assignment_set_id     IN      NUMBER,
x_err_buf               OUT NOCOPY     VARCHAR2,
p_buy_cost_detail       IN      NUMBER := NULL  -- SCAPI: option to preserve buy cost details
)
RETURN INTEGER;

FUNCTION remove_rollup_history (
p_rollup_id             IN      NUMBER,
p_sc_cost_type_id       IN      NUMBER,
p_rollup_option         IN      NUMBER,
x_err_buf               OUT NOCOPY     VARCHAR2
)
RETURN INTEGER;

/* Added for Bug 5678464 */
PROCEDURE proc_remove_rollup_history(
x_err_buf               OUT NOCOPY     VARCHAR2,
retcode                 OUT NOCOPY     NUMBER,
p_rollup_id             IN      VARCHAR2,
p_sc_cost_type_id	IN	VARCHAR2,
p_rollup_option		IN	VARCHAR2
);

END CSTPSCCM;

/
