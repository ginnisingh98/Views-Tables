--------------------------------------------------------
--  DDL for Package WMS_REPL_CUSTOM_APIS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_REPL_CUSTOM_APIS_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSREPCS.pls 120.0 2007/12/30 22:42:07 satkumar noship $  */


g_is_api_implemented BOOLEAN := FALSE;

PROCEDURE  GET_CONSOL_REPL_DEMAND_CUST(x_return_status        OUT NOCOPY VARCHAR2,
				       x_msg_count            OUT NOCOPY NUMBER,
				       x_msg_data             OUT NOCOPY VARCHAR2,
				       x_consol_item_repl_tbl OUT NOCOPY WMS_REPLENISHMENT_PVT.CONSOL_ITEM_REPL_TBL);

END WMS_REPL_CUSTOM_APIS_PUB;

/
