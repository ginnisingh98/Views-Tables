--------------------------------------------------------
--  DDL for Package Body MRP_PUB_KANBAN_QTY_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_PUB_KANBAN_QTY_CALC" AS
/* $Header: MRPPKQCB.pls 120.1 2005/06/21 09:21:52 appldev ship $  */

l_api_version		constant number := 1.0;

PROCEDURE Calculate_Kanban_Quantity (
		p_version_number		IN 	NUMBER,
		p_average_demand		IN 	NUMBER,
		p_minimum_order_quantity	IN	NUMBER,
		p_fixed_lot_multiplier		IN	NUMBER,
		p_safety_stock_days		IN	NUMBER,
		p_replenishment_lead_time	IN	NUMBER,
		p_kanban_flag			IN	NUMBER,
		p_kanban_size			IN OUT	NOCOPY	NUMBER,
		p_kanban_number			IN OUT	NOCOPY	NUMBER,
		p_return_status			OUT	NOCOPY	VARCHAR2 ) IS
BEGIN

  null;
  p_return_status := 'S';

Exception
  WHEN OTHERS THEN
    p_return_status := 'E';

END Calculate_Kanban_Quantity;

END MRP_PUB_KANBAN_QTY_CALC;

/
