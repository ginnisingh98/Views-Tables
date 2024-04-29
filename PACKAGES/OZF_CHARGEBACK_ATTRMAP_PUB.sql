--------------------------------------------------------
--  DDL for Package OZF_CHARGEBACK_ATTRMAP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CHARGEBACK_ATTRMAP_PUB" AUTHID CURRENT_USER AS
/* $Header: ozfpcams.pls 115.0 2003/06/26 05:06:02 mchang noship $ */


-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

--===================================================================
--    Start of Comments
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Global_Header
--
-- PURPOSE
--    Create_Global_Header
--
-- PARAMETERS
--    xp_hdr                   INOUT NOCOPY OE_ORDER_PUB. HEADER_REC_TYPE
--    p_interface_id           IN    NUMBER
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE  Create_Global_Header
(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,xp_hdr                   IN OUT NOCOPY OE_ORDER_PUB.HEADER_REC_TYPE
   ,p_interface_id           IN    NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Global_Line
--
-- PURPOSE
--    Create_Global_Line
--
-- PARAMETERS
--    xp_line                   INOUT NOCOPY OE_ORDER_PUB.LINE_REC_TYPE
--    p_interface_id           IN    NUMBER
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE  Create_Global_Line
(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,xp_line                  IN OUT NOCOPY OE_ORDER_PUB.LINE_REC_TYPE
   ,p_interface_id           IN    NUMBER
);

END OZF_CHARGEBACK_ATTRMAP_PUB;

 

/
