--------------------------------------------------------
--  DDL for Package Body MSC_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ITEM_PUB" AS
/* $Header: MSCPITMB.pls 120.2 2005/07/06 13:18:04 pabram noship $ */

--  Start of Comments
--  API name    Check_Order_Modifiers
--  Type        Public
--  Procedure
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--     This procedure ensures that an item does not have any order modifiers
--     associated with it.
--
--  End of Comments

PROCEDURE Check_Order_Modifiers
(  arg_plan_id         IN      NUMBER
,  arg_org_id          IN      NUMBER
,  arg_instance_id     IN      NUMBER
,  arg_item_id         IN      NUMBER
,  arg_order_qty       IN      NUMBER
,  arg_err_message     IN OUT  nocopy VARCHAR2
,  arg_err_token       IN OUT  nocopy VARCHAR2)
IS

--  Constant declarations

    SYS_YES                 CONSTANT NUMBER := 1;

    var_minimum_order_qty   NUMBER;
    var_maximum_order_qty   NUMBER;
    var_round               NUMBER;
    var_fixed_order_qty     NUMBER;
    var_fixed_lot_mult      NUMBER;

BEGIN
    -- select the order modifiers

    SELECT NVL(minimum_order_quantity,0),
           NVL(maximum_order_quantity,0),
	   rounding_control_type,
	   NVL(fixed_order_quantity, 0),
	   NVL(fixed_lot_multiplier, 0)
    INTO   var_minimum_order_qty,
           var_maximum_order_qty,
	   var_round,
	   var_fixed_order_qty,
	   var_fixed_lot_mult
    FROM   msc_system_items
    WHERE  inventory_item_id = arg_item_id
    AND    organization_id = arg_org_id
    AND    sr_instance_id = arg_instance_id
    AND    plan_id = arg_plan_id;

    arg_err_message := NULL;
    arg_err_token    := NULL;

    if (var_minimum_order_qty <> 0 AND arg_order_qty < var_minimum_order_qty)
    then
    	arg_err_message := 'GEN-Item with order modifier';
	arg_err_token   := 'EC_MINIMUM_ORDER_QTY';
	return;
    end if;

    if (var_maximum_order_qty <> 0 AND arg_order_qty > var_maximum_order_qty)
    then
    	arg_err_message := 'GEN-Item with order modifier';
	arg_err_token   := 'EC_MAXIMUM_ORDER_QTY';
	return;
    end if;

    if (var_round = SYS_YES AND round(arg_order_qty) <> 0)
    then
        if (arg_order_qty / round(arg_order_qty) <> 1)
	then
	    arg_err_message := 'GEN-Item with order modifier';
	    arg_err_token   :=  'EC_ROUND';
	    return;
	end if;
    end if;

    if (var_fixed_order_qty <> 0 AND var_fixed_order_qty <> arg_order_qty)
    then
        arg_err_message := 'GEN-Item with order modifier';
	arg_err_token   :=  'EC_FIX_ORDER_QTY';
	return;
    end if;

	if (var_fixed_lot_mult <> 0)
	then
		if ((arg_order_qty / var_fixed_lot_mult ) <>
			round(arg_order_qty / var_fixed_lot_mult))
		then
			arg_err_message := 'GEN-Item with order modifier';
		arg_err_token   :=  'EC_FIX_LOT_MULT';
		return;
		end if;
	end if;

END Check_Order_Modifiers;

END MSC_Item_PUB;

/
