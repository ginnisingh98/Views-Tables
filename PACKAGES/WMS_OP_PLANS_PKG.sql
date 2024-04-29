--------------------------------------------------------
--  DDL for Package WMS_OP_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_OP_PLANS_PKG" AUTHID CURRENT_USER AS
/* $Header: WMSOPTBS.pls 120.1 2006/06/19 06:55:01 amohamme noship $ */
--
PROCEDURE INSERT_ROW (
   x_rowid                          IN OUT nocopy VARCHAR2
  ,x_operation_plan_id         	    IN     NUMBER
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_created_by                     IN     NUMBER
  ,x_creation_date                  IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_operation_plan_name	    IN     VARCHAR2
  ,x_language                       IN     VARCHAR2
  ,x_source_lang                    IN     VARCHAR2
  ,x_description                    IN     VARCHAR2
  ,x_system_task_type               IN     NUMBER
  ,x_organization_id                IN     NUMBER
  ,x_user_defined                   IN     VARCHAR2
  ,x_enabled_flag                   IN     VARCHAR2
  ,x_effective_date_from            IN     DATE
  ,x_effective_date_to              IN     DATE
  ,x_activity_type_id               IN     NUMBER
  ,x_common_to_all_org              IN     VARCHAR2
  ,x_plan_type_id                   IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2 DEFAULT NULL
  ,x_attribute1                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute2                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute3                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute4                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute5                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute6                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute7                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute8                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute9                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute10                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute11                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute12                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute13                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute14                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute15                    IN     VARCHAR2 DEFAULT NULL
  ,x_default_flag                   IN     VARCHAR2
  ,x_template_flag                  IN     VARCHAR2
  ,x_crossdock_to_wip_flag          IN     VARCHAR2
  );

--
PROCEDURE UPDATE_ROW (
   x_operation_plan_id         	    IN     NUMBER
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_operation_plan_name            IN     VARCHAR2
  ,x_language                       IN     VARCHAR2
  ,x_source_lang                    IN     VARCHAR2
  ,x_description                    IN     VARCHAR2
  ,x_system_task_type               IN     NUMBER
  ,x_organization_id                IN     NUMBER
  ,x_user_defined                   IN     VARCHAR2
  ,x_enabled_flag                   IN     VARCHAR2
  ,x_effective_date_from            IN     DATE
  ,x_effective_date_to              IN     DATE
  ,x_activity_type_id               IN     NUMBER
  ,x_common_to_all_org              IN     VARCHAR2
  ,x_plan_type_id                   IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2 DEFAULT NULL
  ,x_attribute1                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute2                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute3                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute4                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute5                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute6                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute7                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute8                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute9                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute10                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute11                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute12                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute13                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute14                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute15                    IN     VARCHAR2 DEFAULT NULL
  ,x_default_flag                   IN     VARCHAR2
  ,x_template_flag                  IN     VARCHAR2
  ,x_crossdock_to_wip_flag          IN     VARCHAR2
  );

--
PROCEDURE LOAD_ROW (
   x_operation_plan_id         	    IN     NUMBER
  ,x_owner                          IN     VARCHAR2
  ,x_last_update_date               IN     VARCHAR2
  ,x_system_task_type               IN     NUMBER
  ,x_organization_id                IN     NUMBER
  ,x_user_defined                   IN     VARCHAR2
  ,x_enabled_flag                   IN     VARCHAR2
  ,x_effective_date_from            IN     DATE
  ,x_effective_date_to              IN     DATE
  ,x_activity_type_id               IN     NUMBER
  ,x_common_to_all_org              IN     VARCHAR2
  ,x_plan_type_id                   IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2 DEFAULT NULL
  ,x_attribute1                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute2                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute3                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute4                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute5                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute6                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute7                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute8                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute9                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute10                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute11                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute12                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute13                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute14                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute15                    IN     VARCHAR2 DEFAULT NULL
  ,x_operation_plan_name            IN     VARCHAR2
  ,x_description                    IN     VARCHAR2
  ,x_default_flag                   IN     VARCHAR2
  ,x_template_flag                  IN     VARCHAR2
  ,x_crossdock_to_wip_flag          IN     VARCHAR2
  ,x_custom_mode 		    IN     VARCHAR2
  );



-- added by Grace Xiao 07/28/03
PROCEDURE delete_row (
  x_operation_plan_id		    IN	   NUMBER
  );

-- added by Grace Xiao 07/28/03
PROCEDURE lock_row (
   x_operation_plan_id              IN     NUMBER
  ,x_operation_plan_name            IN     VARCHAR2
  ,x_description                    IN     VARCHAR2
  ,x_system_task_type               IN     NUMBER
  ,x_organization_id                IN     NUMBER
  ,x_user_defined                   IN     VARCHAR2
  ,x_enabled_flag                   IN     VARCHAR2
  ,x_effective_date_from            IN     DATE
  ,x_effective_date_to              IN     DATE
  ,x_activity_type_id               IN     NUMBER
  ,x_common_to_all_org              IN     VARCHAR2
  ,x_plan_type_id                   IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2 DEFAULT NULL
  ,x_attribute1                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute2                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute3                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute4                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute5                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute6                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute7                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute8                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute9                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute10                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute11                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute12                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute13                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute14                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute15                    IN     VARCHAR2 DEFAULT NULL
  ,x_default_flag                   IN     VARCHAR2
  ,x_template_flag                  IN     VARCHAR2
  ,x_crossdock_to_wip_flag          IN     VARCHAR2
  );

PROCEDURE translate_row
  (
   x_operation_plan_id              IN  VARCHAR2 ,
   x_owner                          IN  VARCHAR2 ,
   x_last_update_date               IN  VARCHAR2 ,
   x_operation_plan_name            IN  VARCHAR2 ,
   x_description                    IN  VARCHAR2 ,
   x_custom_mode 		    IN  VARCHAR2
   );

procedure add_language;

--
END WMS_OP_PLANS_PKG;

 

/
