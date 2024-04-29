--------------------------------------------------------
--  DDL for Package MRP_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_ITEM_PUB" AUTHID CURRENT_USER AS
/* $Header: MRPPITMS.pls 115.0 99/07/16 12:32:46 porting ship $ */

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
--
--  End of Comments

PROCEDURE Check_Order_Modifiers
( arg_compile_desig   IN      VARCHAR2
, arg_org_id          IN      NUMBER
, arg_item_id         IN      NUMBER
, arg_order_qty       IN      NUMBER
, arg_err_message     IN OUT  VARCHAR2
, arg_err_token       IN OUT  VARCHAR2
);

END MRP_Item_PUB;

 

/
