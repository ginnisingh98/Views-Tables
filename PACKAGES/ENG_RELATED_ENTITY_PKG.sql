--------------------------------------------------------
--  DDL for Package ENG_RELATED_ENTITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_RELATED_ENTITY_PKG" AUTHID CURRENT_USER as
/*$Header: ENGRENTS.pls 120.2 2006/04/13 13:24:06 sbag noship $ */


-- Open_Debug_Session
Procedure Open_Debug_Session (
    p_output_dir IN VARCHAR2 := NULL
   ,p_file_name  IN VARCHAR2 := NULL
);

-- Close Debug_Session
Procedure Close_Debug_Session ;

-- Write Debug Message
Procedure Write_Debug (
    p_debug_message      IN  VARCHAR2 ) ;


Procedure Implement_Relationship_Changes
(
       p_api_version                IN   NUMBER
       ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
       ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
       ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
       ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
       ,p_output_dir                IN   VARCHAR2 := NULL                   --
       ,p_debug_filename            IN   VARCHAR2 := 'ENGRENTB.Implement_Relationship_Changes.log'
       ,x_return_status             OUT  NOCOPY  VARCHAR2
       ,x_msg_count                 OUT  NOCOPY  NUMBER
       ,x_msg_data                  OUT  NOCOPY  VARCHAR2
       ,p_change_id                 IN   NUMBER
       ,p_entity_id                 IN   NUMBER
);

Procedure Validate_floating_revision
(
        p_api_version               IN   NUMBER
       ,p_change_id                 IN   NUMBER
       ,p_rev_item_seq_id           IN   NUMBER := NULL
       ,x_return_status             OUT  NOCOPY  VARCHAR2
       ,x_msg_count                 OUT  NOCOPY  NUMBER
       ,x_msg_data                  OUT  NOCOPY  VARCHAR2
);

END ENG_RELATED_ENTITY_PKG;

 

/
