--------------------------------------------------------
--  DDL for Package WIP_EAMWORKORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_EAMWORKORDER_PVT" AUTHID CURRENT_USER AS
/* $Header: WIPVEWOS.pls 120.0 2005/05/24 18:01:46 appldev noship $ */

TYPE work_order_interface_rec_type is RECORD
 (
  last_update_date                DATE , --NOT NULL,
  last_updated_by                 NUMBER,
  creation_date                   DATE , --NOT NULL,
  created_by                      NUMBER,
  last_update_login               NUMBER,
  request_id                      NUMBER,
  program_id                      NUMBER,
  program_application_id          NUMBER,
  program_update_date             DATE,
  group_id                        NUMBER,
  source_code                     VARCHAR2(30),
  source_line_id                  NUMBER,
 --  process_type                    NUMBER,
  organization_id                 NUMBER,
  load_type                       NUMBER, -- NOT NULL,
  status_type                     NUMBER,
 -- old_status_type                 NUMBER,
  last_unit_completion_date       DATE,
 -- old_completion_date             DATE,
  processing_work_days            NUMBER,
  daily_production_rate           NUMBER,
  line_id                         NUMBER,
  primary_item_id                 NUMBER,
  bom_reference_id                NUMBER,
  routing_reference_id            NUMBER,
  bom_revision_date               DATE,
  routing_revision_date           DATE,
  wip_supply_type                 NUMBER,
  class_code                      VARCHAR2(10),
  lot_number                      VARCHAR2(80),
 -- lot_control_code                NUMBER,
  job_name                        VARCHAR2(240),
  description                     VARCHAR2(240),
  firm_planned_flag               NUMBER,
  alternate_routing_designator    VARCHAR2(10),
  alternate_bom_designator        VARCHAR2(10),
  demand_class                    VARCHAR2(30),
  start_quantity                  NUMBER,
 -- old_start_quantity              NUMBER,
  wip_entity_id                   NUMBER,
  repetitive_schedule_id          NUMBER,
 -- error                           VARCHAR2(240),
 -- parent_group_id                 NUMBER,
  attribute_category              VARCHAR2(30),
  attribute1                      VARCHAR2(150),
  attribute2                      VARCHAR2(150),
  attribute3                      VARCHAR2(150),
  attribute4                      VARCHAR2(150),
  attribute5                      VARCHAR2(150),
  attribute6                      VARCHAR2(150),
  attribute7                      VARCHAR2(150),
  attribute8                      VARCHAR2(150),
  attribute9                      VARCHAR2(150),
  attribute10                     VARCHAR2(150),
  attribute11                     VARCHAR2(150),
  attribute12                     VARCHAR2(150),
  attribute13                     VARCHAR2(150),
  attribute14                     VARCHAR2(150),
  attribute15                     VARCHAR2(150),
  interface_id                    NUMBER,
  last_updated_by_name            VARCHAR2(100),
  created_by_name                 VARCHAR2(100),
  process_phase                   NUMBER,
  process_status                  NUMBER,
  organization_code               VARCHAR2(3),
  first_unit_start_date           DATE,
  first_unit_completion_date      DATE,
  last_unit_start_date            DATE,
  scheduling_method               NUMBER,
  line_code                       VARCHAR2(10),
  primary_item_segments           VARCHAR2(2000),
  bom_reference_segments          VARCHAR2(2000),
  routing_reference_segments      VARCHAR2(2000),
  routing_revision                VARCHAR2(3),
  bom_revision                    VARCHAR2(3),
  completion_subinventory         VARCHAR2(10),
  completion_locator_id           NUMBER,
  completion_locator_segments     VARCHAR2(2000),
  schedule_group_id               NUMBER,
  schedule_group_name             VARCHAR2(30),
  build_sequence                  NUMBER,
  project_id                      NUMBER,
 -- project_name                    VARCHAR2(30),
  task_id                         NUMBER,
 -- task_name                       VARCHAR2(20),
  net_quantity                    NUMBER,
 --  descriptive_flex_segments       VARCHAR2(2000),
  project_number                  VARCHAR2(25),
  task_number                     VARCHAR2(25),
  --project_costed                  NUMBER,
  end_item_unit_number            VARCHAR2(30),
  overcompletion_tolerance_type   NUMBER,
  overcompletion_tolerance_value  NUMBER,
  kanban_card_id                  NUMBER,
  priority                        NUMBER,
  due_date                        DATE,
  allow_explosion                 VARCHAR2(1),
  header_id                       NUMBER,
  delivery_id                     NUMBER,
  coproducts_supply               NUMBER,
  due_date_penalty                NUMBER,
  due_date_tolerance              NUMBER,
  xml_document_id                 VARCHAR2(240),
  parent_wip_entity_id            NUMBER,
  parent_job_name                 VARCHAR2(240),
  asset_number                    VARCHAR2(30),
  asset_group_id                  NUMBER,
  asset_group_segments            VARCHAR2(2000),
  pm_schedule_id                  NUMBER,
  rebuild_item_id                 NUMBER,
  rebuild_item_segments           VARCHAR2(2000),
  rebuild_serial_number           VARCHAR2(30),
  manual_rebuild_flag             VARCHAR2(1),
  shutdown_type                   VARCHAR2(30),
  notification_required           VARCHAR2(1),
  work_order_type                 VARCHAR2(30),
  owning_department               NUMBER,
  owning_department_code          VARCHAR2(10),
  activity_type                   VARCHAR2(30),
  activity_cause                  VARCHAR2(30),
  tagout_required                 VARCHAR2(1),
  plan_maintenance                VARCHAR2(1),
  date_released                   DATE,
  requested_start_date            DATE,
  maintenance_object_id           NUMBER,
  maintenance_object_type         NUMBER,
  maintenance_object_source       NUMBER,
  activity_source                 VARCHAR2(30),
  serialization_start_op          NUMBER
 );


-- Start of comments
--    API name    : Create_EAM_Work_Order
--    Type        : Private.
--    Function    :
--    Pre-reqs    : None.
--    Parameters  :
--    IN          : p_api_version          IN     NUMBER       Required
--                  p_init_msg_list        IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_commit               IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_validation_level     IN     NUMBER       Optional
--                    Default = FND_API.G_VALID_LEVEL_FULL
--                  parameter1
--                  parameter2
--                  .
--                  .
--    OUT         : x_return_status        OUT    VARCHAR2(1)
--                  x_msg_count            OUT    NUMBER
--                  x_msg_data             OUT    VARCHAR2(2000)
--                  parameter1
--                  parameter2
--                  .
--                  .
--    Version     : Initial version     1.0
--
--    Notes       : Note text
--
-- End of comments

PROCEDURE Create_EAM_Work_Order
(     p_api_version               IN    NUMBER                ,
      p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE    ,
    p_commit                IN      VARCHAR2 := FND_API.G_FALSE    ,
    p_validation_level        IN      NUMBER    :=     FND_API.G_VALID_LEVEL_FULL    ,
    x_return_status        OUT NOCOPY    VARCHAR2              ,
    x_msg_count            OUT NOCOPY    NUMBER                ,
    x_msg_data            OUT NOCOPY    VARCHAR2            ,
    p_work_order_rec    IN  work_order_interface_rec_type,
    x_group_id          OUT NOCOPY NUMBER,
    x_request_id        OUT NOCOPY NUMBER
);

--Procedure to return the log directory path to workorder api
--x_output_dir will be null if no directory is found
--else it will be the directory name
 PROCEDURE log_path(
	    x_output_dir   OUT NOCOPY VARCHAR2
	  );


-- Start of comments
--    API name    : Get_EAM_Activity_Cause_Default
--    Type        : Private.
--    Function    :
--    Pre-reqs    : None.
--    Parameters  :
--    IN          : p_api_version          IN     NUMBER       Required
--                  p_init_msg_list        IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_commit               IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_validation_level     IN     NUMBER       Optional
--                    Default = FND_API.G_VALID_LEVEL_FULL
--                  parameter1
--                  parameter2
--                  .
--                  .
--    OUT         : x_return_status        OUT    VARCHAR2(1)
--                  x_msg_count            OUT    NUMBER
--                  x_msg_data             OUT    VARCHAR2(2000)
--                  parameter1
--                  parameter2
--                  .
--                  .
--    Version     : Initial version     1.0
--
--    Notes       : Note text
--
-- End of comments

PROCEDURE Get_EAM_Act_Cause_Default
(     p_api_version               IN    NUMBER                ,
      p_init_msg_list                IN    VARCHAR2 := FND_API.G_FALSE    ,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE    ,
    p_validation_level            IN     NUMBER    :=     FND_API.G_VALID_LEVEL_FULL    ,
    x_return_status                OUT NOCOPY    VARCHAR2              ,
    x_msg_count                    OUT NOCOPY    NUMBER                ,
    x_msg_data                    OUT NOCOPY    VARCHAR2            ,
    p_primary_item_id           IN  NUMBER              ,
    p_organization_id           IN  NUMBER              ,
    p_maintenance_object_type   IN  NUMBER              ,
    p_maintenance_object_id     IN  NUMBER              ,
    p_rebuild_item_id           IN  NUMBER              ,
    x_activity_cause_code       OUT NOCOPY NUMBER
);


-- Start of comments
--    API name    : Get_EAM_Activity_Type_Default
--    Type        : Private.
--    Function    :
--    Pre-reqs    : None.
--    Parameters  :
--    IN          : p_api_version          IN     NUMBER       Required
--                  p_init_msg_list        IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_commit               IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_validation_level     IN     NUMBER       Optional
--                    Default = FND_API.G_VALID_LEVEL_FULL
--                  parameter1
--                  parameter2
--                  .
--                  .
--    OUT         : x_return_status        OUT    VARCHAR2(1)
--                  x_msg_count            OUT    NUMBER
--                  x_msg_data             OUT    VARCHAR2(2000)
--                  parameter1
--                  parameter2
--                  .
--                  .
--    Version     : Initial version     1.0
--
--    Notes       : Note text
--
-- End of comments

PROCEDURE Get_EAM_Act_Type_Default
(     p_api_version               IN    NUMBER                ,
      p_init_msg_list                IN    VARCHAR2 := FND_API.G_FALSE    ,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE    ,
    p_validation_level            IN     NUMBER    :=     FND_API.G_VALID_LEVEL_FULL    ,
    x_return_status                OUT NOCOPY    VARCHAR2              ,
    x_msg_count                    OUT NOCOPY    NUMBER                ,
    x_msg_data                    OUT NOCOPY    VARCHAR2            ,
    p_primary_item_id           IN  NUMBER              ,
    p_organization_id           IN  NUMBER              ,
    p_maintenance_object_type   IN  NUMBER              ,
    p_maintenance_object_id     IN  NUMBER              ,
    p_rebuild_item_id           IN  NUMBER              ,
    x_activity_type_code       OUT NOCOPY NUMBER
);


-- Start of comments
--    API name    : Get_EAM_Act_Source_Default
--    Type        : Private.
--    Function    :
--    Pre-reqs    : None.
--    Parameters  :
--    IN          : p_api_version          IN     NUMBER       Required
--                  p_init_msg_list        IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_commit               IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_validation_level     IN     NUMBER       Optional
--                    Default = FND_API.G_VALID_LEVEL_FULL
--                  parameter1
--                  parameter2
--                  .
--                  .
--    OUT         : x_return_status        OUT    VARCHAR2(1)
--                  x_msg_count            OUT    NUMBER
--                  x_msg_data             OUT    VARCHAR2(2000)
--                  parameter1
--                  parameter2
--                  .
--                  .
--    Version     : Initial version     1.0
--
--    Notes       : Note text
--
-- End of comments

PROCEDURE Get_EAM_Act_Source_Default
(     p_api_version               IN    NUMBER                ,
      p_init_msg_list                IN    VARCHAR2 := FND_API.G_FALSE    ,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE    ,
    p_validation_level            IN     NUMBER    :=     FND_API.G_VALID_LEVEL_FULL    ,
    x_return_status                OUT NOCOPY    VARCHAR2              ,
    x_msg_count                    OUT NOCOPY    NUMBER                ,
    x_msg_data                    OUT NOCOPY    VARCHAR2            ,
    p_primary_item_id           IN  NUMBER              ,
    p_organization_id           IN  NUMBER              ,
    p_maintenance_object_type   IN  NUMBER              ,
    p_maintenance_object_id     IN  NUMBER              ,
    p_rebuild_item_id           IN  NUMBER              ,
    x_activity_source_code       OUT NOCOPY NUMBER
);


-- Start of comments
--    API name    : Get_EAM_Shutdown_Default
--    Type        : Private.
--    Function    :
--    Pre-reqs    : None.
--    Parameters  :
--    IN          : p_api_version          IN     NUMBER       Required
--                  p_init_msg_list        IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_commit               IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_validation_level     IN     NUMBER       Optional
--                    Default = FND_API.G_VALID_LEVEL_FULL
--                  parameter1
--                  parameter2
--                  .
--                  .
--    OUT         : x_return_status        OUT    VARCHAR2(1)
--                  x_msg_count            OUT    NUMBER
--                  x_msg_data             OUT    VARCHAR2(2000)
--                  parameter1
--                  parameter2
--                  .
--                  .
--    Version     : Initial version     1.0
--
--    Notes       : Note text
--
-- End of comments

PROCEDURE Get_EAM_Shutdown_Default
(     p_api_version               IN    NUMBER                ,
      p_init_msg_list                IN    VARCHAR2 := FND_API.G_FALSE    ,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE    ,
    p_validation_level            IN     NUMBER    :=     FND_API.G_VALID_LEVEL_FULL    ,
    x_return_status                OUT NOCOPY    VARCHAR2              ,
    x_msg_count                    OUT NOCOPY    NUMBER                ,
    x_msg_data                    OUT NOCOPY    VARCHAR2            ,
    p_primary_item_id           IN  NUMBER              ,
    p_organization_id           IN  NUMBER              ,
    p_maintenance_object_type   IN  NUMBER              ,
    p_maintenance_object_id     IN  NUMBER              ,
    p_rebuild_item_id           IN  NUMBER              ,
    x_shutdown_type_code       OUT NOCOPY NUMBER
);


-- Start of comments
--    API name    : Get_EAM_Notification_Default
--    Type        : Private.
--    Function    :
--    Pre-reqs    : None.
--    Parameters  :
--    IN          : p_api_version          IN     NUMBER       Required
--                  p_init_msg_list        IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_commit               IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_validation_level     IN     NUMBER       Optional
--                    Default = FND_API.G_VALID_LEVEL_FULL
--                  parameter1
--                  parameter2
--                  .
--                  .
--    OUT         : x_return_status        OUT    VARCHAR2(1)
--                  x_msg_count            OUT    NUMBER
--                  x_msg_data             OUT    VARCHAR2(2000)
--                  parameter1
--                  parameter2
--                  .
--                  .
--    Version     : Initial version     1.0
--
--    Notes       : Note text
--
-- End of comments

PROCEDURE Get_EAM_Notification_Default
(     p_api_version               IN    NUMBER                ,
      p_init_msg_list                IN    VARCHAR2 := FND_API.G_FALSE    ,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE    ,
    p_validation_level            IN     NUMBER    :=     FND_API.G_VALID_LEVEL_FULL    ,
    x_return_status                OUT NOCOPY    VARCHAR2              ,
    x_msg_count                    OUT NOCOPY    NUMBER                ,
    x_msg_data                    OUT NOCOPY    VARCHAR2            ,
    p_primary_item_id           IN  NUMBER              ,
    p_organization_id           IN  NUMBER              ,
    p_maintenance_object_type   IN  NUMBER              ,
    p_maintenance_object_id     IN  NUMBER              ,
    p_rebuild_item_id           IN  NUMBER              ,
    x_notification_flag         OUT NOCOPY VARCHAR2
);



-- Start of comments
--    API name    : Get_EAM_Nitification_Default
--    Type        : Private.
--    Function    :
--    Pre-reqs    : None.
--    Parameters  :
--    IN          : p_api_version          IN     NUMBER       Required
--                  p_init_msg_list        IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_commit               IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_validation_level     IN     NUMBER       Optional
--                    Default = FND_API.G_VALID_LEVEL_FULL
--                  parameter1
--                  parameter2
--                  .
--                  .
--    OUT         : x_return_status        OUT    VARCHAR2(1)
--                  x_msg_count            OUT    NUMBER
--                  x_msg_data             OUT    VARCHAR2(2000)
--                  parameter1
--                  parameter2
--                  .
--                  .
--    Version     : Initial version     1.0
--
--    Notes       : Note text
--
-- End of comments

PROCEDURE Get_EAM_Tagout_Default
(     p_api_version               IN    NUMBER                ,
      p_init_msg_list                IN    VARCHAR2 := FND_API.G_FALSE    ,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE    ,
    p_validation_level            IN     NUMBER    :=     FND_API.G_VALID_LEVEL_FULL    ,
    x_return_status                OUT NOCOPY    VARCHAR2              ,
    x_msg_count                    OUT NOCOPY    NUMBER                ,
    x_msg_data                    OUT NOCOPY    VARCHAR2            ,
    p_primary_item_id           IN  NUMBER              ,
    p_organization_id           IN  NUMBER              ,
    p_maintenance_object_type   IN  NUMBER              ,
    p_maintenance_object_id     IN  NUMBER              ,
    p_rebuild_item_id           IN  NUMBER              ,
    x_tagout_required           OUT NOCOPY VARCHAR2
);


-- Start of comments
--    API name    : Get_EAM_Owning_Dept_Default
--    Type        : Private.
--    Function    :
--    Pre-reqs    : None.
--    Parameters  :
--    IN          : p_api_version          IN     NUMBER       Required
--                  p_init_msg_list        IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_commit               IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_validation_level     IN     NUMBER       Optional
--                    Default = FND_API.G_VALID_LEVEL_FULL
--                  parameter1
--                  parameter2
--                  .
--                  .
--    OUT         : x_return_status        OUT    VARCHAR2(1)
--                  x_msg_count            OUT    NUMBER
--                  x_msg_data             OUT    VARCHAR2(2000)
--                  parameter1
--                  parameter2
--                  .
--                  .
--    Version     : Initial version     1.0
--
--    Notes       : Note text
--
-- End of comments

PROCEDURE Get_EAM_Owning_Dept_Default
(     p_api_version               IN    NUMBER                ,
      p_init_msg_list                IN    VARCHAR2 := FND_API.G_FALSE    ,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE    ,
    p_validation_level            IN     NUMBER    :=     FND_API.G_VALID_LEVEL_FULL    ,
    x_return_status                OUT NOCOPY    VARCHAR2              ,
    x_msg_count                    OUT NOCOPY    NUMBER                ,
    x_msg_data                    OUT NOCOPY    VARCHAR2            ,
    p_primary_item_id           IN  NUMBER              ,
    p_organization_id           IN  NUMBER              ,
    p_maintenance_object_type   IN  NUMBER              ,
    p_maintenance_object_id     IN  NUMBER              ,
    p_rebuild_item_id           IN  NUMBER              ,
    x_owning_department_id      OUT NOCOPY NUMBER
);

END WIP_EAMWORKORDER_PVT;


 

/
