--------------------------------------------------------
--  DDL for Package WSH_INBOUND_SHIP_ADVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_INBOUND_SHIP_ADVICE_PKG" AUTHID CURRENT_USER as
/* $Header: WSHINSAS.pls 120.0.12010000.1 2008/07/29 06:11:48 appldev ship $ */

C_SDEBUG              CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL1;
C_DEBUG               CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL2;

-- Global variable to store the warehouse type
-- So that any package other than this package could use it if needed.
G_WAREHOUSE_TYPE		VARCHAR2(30);

PROCEDURE Process_Ship_Advice(
		p_delivery_interface_id 	IN NUMBER,
		p_event_key			IN VARCHAR2,
		x_return_status 		OUT NOCOPY  VARCHAR2);

END WSH_INBOUND_SHIP_ADVICE_PKG;

/
