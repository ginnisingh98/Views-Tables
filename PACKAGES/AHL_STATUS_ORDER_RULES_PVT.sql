--------------------------------------------------------
--  DDL for Package AHL_STATUS_ORDER_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_STATUS_ORDER_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVSORS.pls 115.0 2003/07/07 19:06:09 sdevaki noship $ */

-----------------------------------------------------------
-- PACKAGE
--    AHL_STATUS_ORDER_RULES_PVT
--
-- PURPOSE
--    This package is a Private API for retrieving the valid
--    statuses for the current status
--
--    Advanced Services Online.  It contains specification for pl/sql records and tables
--
--    AHL_STATUS_ORDER_RULES
--    Get_Valid_Status_Order_Values (see below for specification)
--
-- NOTES
--
--
-- HISTORY
-- 09-May-2003    sdevaki      Created.
-----------------------------------------------------------

-------------------------------------
-----   AHL_STATUS_ORDER_RULES  -----
-------------------------------------
-- Record for AHL_STATUS_ORDER_RULES

TYPE Status_Order_Rules_Rec IS RECORD (
   status_order_rule_id         NUMBER,
   object_version_number        NUMBER,
   last_update_date             DATE,
   last_updated_by              NUMBER(15),
   creation_date                DATE,
   created_by                   NUMBER(15),
   last_update_login            NUMBER(15),
   system_status_type           VARCHAR2(30),
   current_status_code          VARCHAR2(30),
   next_status_code             VARCHAR2(30),
   next_status_meaning          VARCHAR2(80),
   security_groupd_id           NUMBER
);


--Declare StatusOrderRules table type
TYPE Status_Order_Rules_Tbl IS TABLE OF Status_Order_Rules_Rec
INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------
-- PROCEDURE
--    Get_Status_Order_Rules
--
-- PURPOSE
--    To Retrieve the valid Status Order Rules for the current Status
--    Order Rule
--
-- PARAMETERS
--    p_current_status_code   : current status code
--    p_system_status_type    : current status type
--    x_status_order_rules_tbl: the table of records representing
--                              AHL_STATUS_ORDER_RULES table.
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Get_Status_Order_Rules (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_current_status_code     IN      VARCHAR2,
   p_system_status_type      IN      VARCHAR2,
   x_status_order_rules_tbl      OUT NOCOPY Status_Order_Rules_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);


END AHL_STATUS_ORDER_RULES_PVT;

 

/
