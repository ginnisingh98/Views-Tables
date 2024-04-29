--------------------------------------------------------
--  DDL for Package INV_TURNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TURNS" AUTHID CURRENT_USER as
/* $Header: INVTRNIS.pls 115.8 2003/03/19 05:27:02 aapaul ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'INV_TURNS';

PROCEDURE CLOSED_TB (
	p_organization_id IN NUMBER,
	p_period_id IN NUMBER,
	err_msg OUT NOCOPY VARCHAR2
);

PROCEDURE CLOSED_SC (
	p_organization_id IN NUMBER,
	p_period_id IN NUMBER,
	p_last_period_id IN NUMBER,
	err_msg OUT NOCOPY VARCHAR2
);

PROCEDURE CLOSED_WIP (
	p_organization_id IN NUMBER,
	p_period_id IN NUMBER,
	err_msg OUT NOCOPY VARCHAR2
);

PROCEDURE CLOSED_COGS(
	p_organization_id IN NUMBER,
	p_period_id IN NUMBER,
	err_msg OUT NOCOPY VARCHAR2
);

PROCEDURE CREATE_OPEN_PERIODS (
                             ERRBUF               OUT NOCOPY VARCHAR2,
                             RETCODE              OUT NOCOPY NUMBER
);

PROCEDURE FIND_TXN_VALUES (
	err_msg OUT NOCOPY varchar2,
	p_organization_id IN NUMBER,
	p_new_period IN NUMBER,
	p_period_id IN NUMBER,
	p_period_start_date DATE,
	p_schedule_close_date DATE
);
-- Added the below function for bug 2740652
FUNCTION GET_MBI_ONHAND(x_organization_id NUMBER,
                        x_inventory_item_id NUMBER,
                        x_last_period_id NUMBER) return NUMBER;

END INV_TURNS;

 

/
