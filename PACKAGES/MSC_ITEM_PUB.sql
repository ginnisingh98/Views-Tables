--------------------------------------------------------
--  DDL for Package MSC_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ITEM_PUB" AUTHID CURRENT_USER AS
/* $Header: MSCPITMS.pls 120.1 2005/06/16 19:50:08 appldev  $ */

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
( arg_plan_id         IN      NUMBER
, arg_org_id          IN      NUMBER
, arg_instance_id     IN      NUMBER
, arg_item_id         IN      NUMBER
, arg_order_qty       IN      NUMBER
, arg_err_message     IN OUT  nocopy VARCHAR2
, arg_err_token       IN OUT  nocopy VARCHAR2
);

END MSC_Item_PUB;

 

/
