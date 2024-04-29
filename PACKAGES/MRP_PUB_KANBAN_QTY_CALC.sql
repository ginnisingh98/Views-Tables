--------------------------------------------------------
--  DDL for Package MRP_PUB_KANBAN_QTY_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_PUB_KANBAN_QTY_CALC" AUTHID CURRENT_USER as
/* $Header: MRPPKQCS.pls 120.3 2006/04/20 16:02:08 yulin ship $  */

VERSION			CONSTANT CHAR(80) := '1.0';

PROCEDURE Calculate_Kanban_Quantity (
                p_version_number                IN      NUMBER,
                p_average_demand                IN      NUMBER,
                p_minimum_order_quantity        IN      NUMBER,
                p_fixed_lot_multiplier          IN      NUMBER,
                p_safety_stock_days             IN      NUMBER,
                p_replenishment_lead_time       IN      NUMBER,
                p_kanban_flag                   IN      NUMBER,
                p_kanban_size                   IN OUT  NOCOPY	NUMBER,
                p_kanban_number                 IN OUT  NOCOPY	NUMBER,
                p_return_status                 OUT     NOCOPY	VARCHAR2 ) ;

END MRP_PUB_KANBAN_QTY_CALC;



 

/
