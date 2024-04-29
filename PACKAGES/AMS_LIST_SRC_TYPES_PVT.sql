--------------------------------------------------------
--  DDL for Package AMS_LIST_SRC_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_SRC_TYPES_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvstvs.pls 120.0 2005/06/01 23:45:14 appldev noship $ */

-----------------------------------------------------------
-- PACKAGE
--   AMS_LIST_SRC_TYPES_PVT
--
-- PURPOSE
--      The purpose of this package is to creat and update the
--      views for Master list source type.
--	The following cases are handled.
--		1. Create Master view for new source type.
--		2. Update the Master view for new source type.
--		3. Create/Update the Master view in case a new
--                 Sub source type is added or deleted.
--		4. Create/Update ALL the Master view in case a new
--                 item is added/deleted from the Sub source type.
--
--
-- PROCEDURES
--
--
-- PARAMETERS
--           INPUT
--
--
--           OUTPUT
--
-- HISTORY
-- 	19-Apr-2001 usingh      Created.
--      18-Feb-2005 musman     added api standard parameters to procedures
-- ---------------------------------------------------------


-- This procedure create or updates the Master source type view.

PROCEDURE master_source_type_view(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
 p_list_source_type_id IN  NUMBER
                      );


PROCEDURE update_all_master_views(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_list_source_type_id  IN NUMBER
                      );

PROCEDURE process_views(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_source_type_id        IN  NUMBER
                      );

end AMS_LIST_SRC_TYPES_PVT;

 

/
