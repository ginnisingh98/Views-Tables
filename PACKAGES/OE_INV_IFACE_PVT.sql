--------------------------------------------------------
--  DDL for Package OE_INV_IFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_INV_IFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVIIFS.pls 120.0.12000000.1 2007/01/16 22:10:37 appldev ship $ */

--  Start of Comments
--  API name    OE_Inv_Iface_PVT
--  Type        Private
--  Version     Current version = 1.0
--              Initial version = 1.0

PROCEDURE Inventory_Interface
(p_line_id       IN NUMBER,
x_return_status OUT NOCOPY VARCHAR2,

x_result_out OUT NOCOPY VARCHAR2

);


END OE_Inv_Iface_PVT;

 

/
