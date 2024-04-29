--------------------------------------------------------
--  DDL for Package EAM_ORG_MAINT_DEFAULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ORG_MAINT_DEFAULTS_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVOMDS.pls 120.0 2005/05/25 16:04:48 appldev noship $*/
   -- Start of comments
   -- API name : eam_org_maint_defaults_pvt
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

   PROCEDURE insert_row
   (
      p_api_version           IN  NUMBER
     ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
     ,p_commit                IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_object_type           IN  NUMBER
     ,p_object_id             IN  NUMBER
     ,p_organization_id       IN  NUMBER
     ,p_owning_department_id  IN  NUMBER   := NULL
     ,p_accounting_class_code IN  VARCHAR2 := NULL
     ,p_area_id               IN  NUMBER   := NULL
     ,p_activity_cause_code   IN  VARCHAR2 := NULL
     ,p_activity_type_code    IN  VARCHAR2 := NULL
     ,p_activity_source_code  IN  VARCHAR2 := NULL
     ,p_shutdown_type_code    IN  VARCHAR2 := NULL
     ,p_tagging_required_flag IN  VARCHAR2 := NULL
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
   ) ;

   PROCEDURE update_row
   (
      p_api_version           IN  NUMBER
     ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
     ,p_commit                IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_object_type           IN  NUMBER
     ,p_object_id             IN  NUMBER
     ,p_organization_id       IN  NUMBER
     ,p_owning_department_id  IN  NUMBER   := NULL
     ,p_accounting_class_code IN  VARCHAR2 := NULL
     ,p_area_id               IN  NUMBER   := NULL
     ,p_activity_cause_code   IN  VARCHAR2 := NULL
     ,p_activity_type_code    IN  VARCHAR2 := NULL
     ,p_activity_source_code  IN  VARCHAR2 := NULL
     ,p_shutdown_type_code    IN  VARCHAR2 := NULL
     ,p_tagging_required_flag IN  VARCHAR2 := NULL
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
   ) ;

   PROCEDURE update_insert_row
   (
      p_api_version           IN  NUMBER
     ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
     ,p_commit                IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_object_type           IN  NUMBER
     ,p_object_id             IN  NUMBER
     ,p_organization_id       IN  NUMBER
     ,p_owning_department_id  IN  NUMBER   := NULL
     ,p_accounting_class_code IN  VARCHAR2 := NULL
     ,p_area_id               IN  NUMBER   := NULL
     ,p_activity_cause_code   IN  VARCHAR2 := NULL
     ,p_activity_type_code    IN  VARCHAR2 := NULL
     ,p_activity_source_code  IN  VARCHAR2 := NULL
     ,p_shutdown_type_code    IN  VARCHAR2 := NULL
     ,p_tagging_required_flag IN  VARCHAR2 := NULL
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
   ) ;

END eam_org_maint_defaults_pvt;

 

/
