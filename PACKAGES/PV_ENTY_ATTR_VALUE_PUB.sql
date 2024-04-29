--------------------------------------------------------
--  DDL for Package PV_ENTY_ATTR_VALUE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENTY_ATTR_VALUE_PUB" AUTHID CURRENT_USER AS
 /* $Header: pvxvavps.pls 120.1 2005/11/11 15:28:13 amaram noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_ENTY_ATTR_VALUE_PUB
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


-- ===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             attr_val_rec_type
--   -------------------------------------------------------
--   Parameters:
--
--       attr_value
--       attr_value_extn
--
--
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--  ===================================================================

TYPE attr_val_rec_type IS RECORD
(
 attr_value                      VARCHAR2(2000)      := FND_API.G_MISS_CHAR
,attr_value_extn		 VARCHAR2(4000)      := FND_API.G_MISS_CHAR

);

g_miss_attr_val_rec              attr_val_rec_type;
TYPE  attr_value_tbl_type   IS TABLE OF attr_val_rec_type INDEX BY BINARY_INTEGER;
g_miss_attr_value_tbl       attr_value_tbl_type;

TYPE NUMBER_TABLE IS TABLE OF NUMBER;

/*type attr_value_table_type   is TABLE of varchar2(500);
type attr_value_extn_table_type   is TABLE of varchar2(4000);
g_miss_attr_value_table_type  attr_value_table_type;
g_miss_attr_value_extn_table  attr_value_extn_table_type;



TYPE attr_val_rec_group_type IS RECORD

(
	attribute_id				  NUMBER				:= FND_API.G_MISS_NUM
	,entity                       VARCHAR2(50)			:= FND_API.G_MISS_CHAR
	,entity_id			          NUMBER				:= FND_API.G_MISS_NUM
	,version                      NUMBER				:= FND_API.G_MISS_NUM
	,attr_val_tbl				  attr_value_table_type	:= g_miss_attr_value_table_type
	--,attr_value_extn_tbl          attr_value_extn_table_type := g_miss_attr_value_extn_table

);

g_miss_attr_val_group_rec              attr_val_rec_group_type;
TYPE  attr_value_group_tbl_type   IS TABLE OF attr_val_rec_group_type INDEX BY BINARY_INTEGER;
g_miss_attr_value_group_tbl       attr_value_group_tbl_type;
*/
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Upsert_Attr_Value
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number  IN   NUMBER                  Required
--       p_init_msg_list       IN   VARCHAR2                Optional  Default = FND_API_G_FALSE
--       p_commit              IN   VARCHAR2                Optional  Default = FND_API.G_FALSE
--       p_validation_level    IN   NUMBER                  Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_attribute_id		   IN   NUMBER					Required
--		 entity                IN   VARCHAR2                Required
--       entity_id		       IN   NUMBER				    Required
--		 version               IN   NUMBER					Required
--       p_attr_val_tbl        IN   attr_value_tbl_type     Optional   Default= g_miss_attr_value_tbl
--
--   OUT
--       x_return_status       OUT  VARCHAR2
--       x_msg_count           OUT  NUMBER
--       x_msg_data            OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Upsert_Attr_Value(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_attribute_id				  IN   NUMBER
	,p_entity                     IN   VARCHAR2
	,p_entity_id			      IN   NUMBER
	,p_version                    IN   NUMBER		:=0
	,p_attr_val_tbl               IN   attr_value_tbl_type  := g_miss_attr_value_tbl
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Upsert_Attr_Value_in_groups
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number  IN   NUMBER                  Required
--       p_init_msg_list       IN   VARCHAR2                Optional  Default = FND_API_G_FALSE
--       p_commit              IN   VARCHAR2                Optional  Default = FND_API.G_FALSE
--       p_validation_level    IN   NUMBER                  Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_attr_val_group_tbl        IN   attr_value_tbl_type     Optional   Default= g_miss_attr_value_group_tbl
--
--   OUT
--       x_return_status       OUT  VARCHAR2
--       x_msg_count           OUT  NUMBER
--       x_msg_data            OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--
/*
PROCEDURE Upsert_Attr_Value_in_groups(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_attr_val_group_tbl         IN   attr_value_group_tbl_type  := g_miss_attr_value_group_tbl
    );
*/

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Copy_Partner_Attr_Values
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number  IN   NUMBER                  Required
--       p_init_msg_list       IN   VARCHAR2                Optional  Default = FND_API_G_FALSE
--       p_commit              IN   VARCHAR2                Optional  Default = FND_API.G_FALSE
--       p_validation_level    IN   NUMBER                  Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_attr_id_tbl		   IN   JTF_NUMBER_TABLE		Required
--		 entity                IN   VARCHAR2                Required
--       entity_id		       IN   NUMBER				    Required
--		 p_partner_id          IN   NUMBER					Required

--
--   OUT
--       x_return_status       OUT  VARCHAR2
--       x_msg_count           OUT  NUMBER
--       x_msg_data            OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Copy_Partner_Attr_Values(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_attr_id_tbl				  IN   NUMBER_TABLE
	,p_entity                     IN   VARCHAR2
	,p_entity_id			      IN   NUMBER
	,p_partner_id			      IN   NUMBER

    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Upsert_Partner_Types
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number  IN   NUMBER                  Required
--       p_init_msg_list       IN   VARCHAR2                Optional  Default = FND_API_G_FALSE
--       p_commit              IN   VARCHAR2                Optional  Default = FND_API.G_FALSE
--       p_validation_level    IN   NUMBER                  Optional  Default = FND_API.G_VALID_LEVEL_FULL
--	 p_entity_id	       IN   NUMBER                  Required
--       p_version             IN   NUMBER		    Required
--       p_attr_val_tbl        IN   attr_value_tbl_type     Required

--
--   OUT
--       x_return_status       OUT  VARCHAR2
--       x_msg_count           OUT  NUMBER
--       x_msg_data            OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Upsert_Partner_Types (
    p_api_version_number  	IN   NUMBER
   ,p_init_msg_list             IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                    IN   VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level         	IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status             OUT NOCOPY  VARCHAR2
   ,x_msg_count                 OUT NOCOPY  NUMBER
   ,x_msg_data                  OUT NOCOPY  VARCHAR2
   ,p_entity_id			IN   NUMBER
   ,p_version                   IN   NUMBER		:=0
   ,p_attr_val_tbl              IN   attr_value_tbl_type  := g_miss_attr_value_tbl
    );


END PV_ENTY_ATTR_VALUE_PUB;

 

/
