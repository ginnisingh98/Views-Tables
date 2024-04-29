--------------------------------------------------------
--  DDL for Package OZF_SPLIT_CLAIM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SPLIT_CLAIM_PVT" AUTHID CURRENT_USER as
/* $Header: ozfvspcs.pls 120.1.12010000.2 2009/01/13 08:20:16 ateotia ship $ */

TYPE Child_Claim_type IS RECORD (
     claim_id                        NUMBER ,
     object_version_number           NUMBER ,
     claim_type_id                   NUMBER ,
     amount                          NUMBER ,
     line_amount_sum                 NUMBER ,
     reason_code_id                  NUMBER ,
     parent_claim_id                 NUMBER ,
     parent_object_ver_num           NUMBER ,
     line_table                      VARCHAR2(32767) --Bug # 7699177 fixed by ateotia
);

TYPE Child_Claim_tbl_type IS TABLE of Child_Claim_type
                  INDEX BY BINARY_INTEGER;

TYPE Parent_Claim_type IS RECORD (
     claim_id                        NUMBER ,
     object_version_number           NUMBER ,
     amount_adjusted                 NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_child_claim_tbl
--
-- PURPOSE
--    Split a child claim
--
-- PARAMETERS
--    p_claim    : the new claim to be created.
--    p_line_tbl : the table of lines associated with this new claim if any.
--
-- NOTES
----------------------------------------------------------------------
PROCEDURE create_child_claim_tbl (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_child_claim_tbl        IN    Child_Claim_tbl_type
   ,p_mode                   IN    VARCHAR2
   );
---------------------------------------------------------------------
-- PROCEDURE
--    update_child_claim_tbl
--
-- PURPOSE
--    Update a child claim
--
-- PARAMETERS
--    p_claim    : the claim to be update.
--    p_line_tbl : the table of lines associated with this claim if any.
--
-- NOTES
----------------------------------------------------------------------
PROCEDURE update_child_claim_tbl (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_child_claim_tbl        IN    child_claim_tbl_type
   ,p_mode                   IN    VARCHAR2
   );

END;

/
