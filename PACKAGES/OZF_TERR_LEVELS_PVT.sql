--------------------------------------------------------
--  DDL for Package OZF_TERR_LEVELS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_TERR_LEVELS_PVT" AUTHID CURRENT_USER AS
/*$Header: ozfvtlvs.pls 120.2 2005/09/23 10:50:02 yzhao noship $*/
/*
---------------------------------------------------------------------
-- PROCEDURE
--
--
-- HISTORY
--    03/07/2000  mpande  Created.
--    06/09/2005  kdass   Bug 4415878 SQL Repository Fix - removed update_terr_levels as it is not used anywhere
---------------------------------------------------------------------
*/

/* Start of comments for Insert_SelectDefns API definition
    API Name  : OZF_TERR_LEVELS_PVT.Create_terr_hierarchy
    Type      : Private
    Function  :
    Pre-reqs  : None
    IN        : p_api_version      IN    NUMBER    Required,
                p_init_msg_list    IN    VARCHAR2  Optional Default = FND_API.G_FALSE,
                p_commit           IN    VARCHAR2  Optional Default = FND_API.G_FALSE,
                p_validation_level IN    NUMBER    Optional Default = FND_API.G_VALID_LEVEL_FULL,
		ERRBUF      OUT NOCOPY     VARCHAR2     Required for concurrent manager
		RETCODE     OUT NOCOPY     NUMBER    Required  for concurrent manager
                p_start_node_id  IN    NUMBER        Required :value comes from the topmost node of jtf territories
    OUT NOCOPY       : x_return_status    OUT  VARCHAR2(1)    Required
                x_msg_count        OUT NOCOPY  NUMBER         Optional
                x_msg_data         OUT NOCOPY  VARCHAR2(2000) Optional


    Version  : Current version 1.0
               Creation of package body and the body

    Notes    : Version 1.0
               Create_terr_hierarchy API :
                       This API accepts IN parameters of a table  of record type
                       and inserts records into AMS_TERR_LEVELS_ALL table.
*/

   -- This is wrapper for the concurrent process to be called
   PROCEDURE  Create_Terr_Hierarchy
   (ERRBUF      OUT NOCOPY     VARCHAR2
   ,RETCODE     OUT NOCOPY     NUMBER
   ,p_start_node_id         IN    NUMBER
   );

   -- This the package to import the territory APIS and create
   PROCEDURE  Insert_Terr_Levels
   (p_api_version            IN    NUMBER := 1
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_start_node_id         IN    NUMBER
   );

   -- This the package to import all territories defined under Trade Management
   PROCEDURE bulk_insert_terr_levels (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
   );


   -- This the package to delete the a definite territory sturucture from our schema
   PROCEDURE  Delete_Terr_Levels
   (p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER    := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_hierarchy_id           IN NUMBER
   );

END;

 

/
