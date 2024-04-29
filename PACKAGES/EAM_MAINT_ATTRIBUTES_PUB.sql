--------------------------------------------------------
--  DDL for Package EAM_MAINT_ATTRIBUTES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_MAINT_ATTRIBUTES_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPMATS.pls 120.2 2005/11/29 05:00:18 yjhabak noship $*/
   -- Start of comments
   -- API name : eam_maint_attributes_pub
   -- Type     : Private.
   -- Function :
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN    p_api_version      IN NUMBER    Required
   --       p_init_msg_list    IN VARCHAR2  Optional  Default = FND_API.G_FALSE
   --       p_commit           IN VARCHAR2  Optional  Default = FND_API.G_FALSE
   --       p_validation_level IN NUMBER    Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --       parameter1
   --       parameter2
   --       .
   --       .
   -- OUT   x_return_status   OUT   VARCHAR2(1)
   --       x_msg_count       OUT   NUMBER
   --       x_msg_data        OUT   VARCHAR2(2000)
   --       parameter1
   --       parameter2
   --       .
   --       .
   -- Version  Current version x.x
   --          Changed....
   --          previous version   y.y
   --          Changed....
   --         .
   --         .
   --          previous version   2.0
   --          Changed....
   --          Initial version    1.0
   --
   -- Notes    : Note text
   --
   -- End of comments

   PROCEDURE create_maint_attributes
   (
      p_api_version           IN  NUMBER
     ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
     ,p_commit                IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_id           IN  NUMBER
     ,p_owning_department_id  IN  NUMBER   := NULL
     ,p_accounting_class_code IN  VARCHAR2 := NULL
     ,p_area_id               IN  NUMBER   := NULL
     ,p_parent_instance_id    IN  NUMBER   := NULL
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
   ) ;

   PROCEDURE update_maint_attributes
   (
      p_api_version           IN  NUMBER
     ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
     ,p_commit                IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_id           IN  NUMBER
     ,p_owning_department_id  IN  NUMBER   := NULL
     ,p_accounting_class_code IN  VARCHAR2 := NULL
     ,p_area_id               IN  NUMBER   := NULL
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
   ) ;

   /* Added p_mode for bug # 4764280.
      1 - Insert and 2 - Update
   */
   PROCEDURE validate_maint_defaults
   (
      p_api_version           IN  NUMBER
     ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
     ,p_commit                IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_id           IN  NUMBER
     ,p_owning_department_id  IN  NUMBER   := NULL
     ,p_accounting_class_code IN  VARCHAR2 := NULL
     ,p_area_id               IN  NUMBER   := NULL
     ,p_mode                  IN  NUMBER
     ,x_org_id                OUT NOCOPY NUMBER
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
   ) ;


END eam_maint_attributes_pub ;

 

/
