--------------------------------------------------------
--  DDL for Package EAM_REBUILD_GENEALOGY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_REBUILD_GENEALOGY" AUTHID CURRENT_USER AS
/* $Header: EAMRBGNS.pls 115.3 2002/11/20 19:28:17 aan noship $*/

PROCEDURE create_rebuild_genealogy(
     p_api_version                   IN  NUMBER
 ,   p_init_msg_list	             IN  VARCHAR2 := FND_API.G_FALSE
 ,   p_commit		                 IN  VARCHAR2 := FND_API.G_FALSE
 ,   p_validation_level	             IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,   p_subinventory                  IN  VARCHAR2 := NULL
 ,   p_locator_id		     IN NUMBER  := NULL
 ,   p_object_id                     IN  number := null
 ,   p_serial_number                 IN  VARCHAR2 := NULL
 ,   p_organization_id                        IN  NUMBER := NULL
 ,   p_inventory_item_id               IN NUMBER := NULL
 ,   p_parent_object_id	             IN  NUMBER   := NULL
 ,   p_parent_serial_number          IN  VARCHAR2 := NULL
 ,   p_parent_inventory_item_id	     IN  NUMBER   := NULL
 ,   p_parent_organization_id		         IN  NUMBER   := NULL
 ,   p_start_date_active             IN  DATE     := sysdate
 ,   p_end_date_active               IN  DATE     := NULL
 ,   x_msg_count                     OUT NOCOPY NUMBER
 ,   x_msg_data                      OUT NOCOPY VARCHAR2
 ,   x_return_status                 OUT NOCOPY VARCHAR2);

  PROCEDURE update_rebuild_genealogy(
     p_api_version                   IN  NUMBER
 ,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
 ,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
 ,   p_validation_level              IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,   p_object_type                   IN  NUMBER
 ,   p_object_id                     IN  NUMBER   := NULL
 ,   p_serial_number                 IN  VARCHAR2 := NULL
 ,   p_inventory_item_id             IN  NUMBER   := NULL
 ,   p_organization_id                        IN  NUMBER   := NULL
 ,   p_subinventory                  IN VARCHAR2  := NULL
 ,   p_locator_id		     IN NUMBER  := NULL
 ,   p_genealogy_origin              IN  NUMBER   := NULL
 ,   p_genealogy_type                IN  NUMBER   := NULL
 ,   p_end_date_active               IN  DATE     := NULL
 ,   x_return_status                 OUT NOCOPY VARCHAR2
 ,   x_msg_count                     OUT NOCOPY NUMBER
 ,   x_msg_data                      OUT NOCOPY VARCHAR2);

 end eam_rebuild_genealogy;



 

/
