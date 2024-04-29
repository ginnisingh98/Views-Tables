--------------------------------------------------------
--  DDL for Package EAM_WORKORDERS_JSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WORKORDERS_JSP" AUTHID CURRENT_USER AS
/* $Header: EAMJOBJS.pls 120.2.12010000.2 2009/08/21 06:32:21 vchidura ship $
   $Author: vchidura $ */

  -- Author  : YULIN
  -- Created : 7/24/01 12:48:31 PM
  -- Purpose : eam work order functionalities
   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   g_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   g_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   g_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;



-----------------------------------------------------------------
--procedure to validate if a work order can be cancelled or not
-----------------------------------------------------------
procedure validate_cancel(p_wip_entity_id NUMBER);



-------------------------------------------------------------
--procedure to add existing work orders
----------------------------------------------------------------
procedure add_exist_work_order(
       p_api_version                 IN    NUMBER        := 1.0
      ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
      ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
      ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
      ,p_record_version_number       IN    NUMBER        := NULL
      ,x_return_status               OUT NOCOPY   VARCHAR2
      ,x_msg_count                   OUT NOCOPY   NUMBER
      ,x_msg_data                    OUT NOCOPY   VARCHAR2
      ,p_organization_id             IN    NUMBER
      ,p_wip_entity_id   IN    NUMBER
      ,p_firm_flag    IN  NUMBER
      ,p_parent_wip_id   IN  NUMBER
      , p_relation_type  IN NUMBER


);


-------------------------------------------------------------------------
-- a wrapper procedure to the eam_completion.complete_work_order,
-- also check the return status add message to the message list
-- so jsp pages can get them.
-------------------------------------------------------------------------
  procedure Complete_Workorder
  ( p_api_version                 IN    NUMBER        := 1.0
   ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
   ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
   ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
   ,p_record_version_number       IN    NUMBER        := NULL
   ,x_return_status               OUT NOCOPY   VARCHAR2
   ,x_msg_count                   OUT NOCOPY   NUMBER
   ,x_msg_data                    OUT NOCOPY   VARCHAR2
   ,p_wip_entity_id               IN    NUMBER
   ,p_actual_start_date           IN    DATE
   ,p_actual_end_date             IN    DATE
   ,p_actual_duration             IN    NUMBER
   ,p_transaction_date            IN    DATE
   ,p_transaction_type            IN    NUMBER
   ,p_shutdown_start_date         IN    DATE
   ,p_shutdown_end_date           IN    DATE
   ,p_reconciliation_code         IN    VARCHAR2
   ,p_stored_last_update_date     IN    DATE
    ,p_rebuild_jobs                IN    VARCHAR2     := NULL -- holds 'Y' or 'N'
    ,p_subinventory                IN    VARCHAR2     := NULL
	,p_subinv_ctrl                 IN    NUMBER       := NULL
	,p_org_id                      IN    NUMBER       := NULL
	,p_item_id                     IN    NUMBER       := NULL
    ,p_locator_id                  IN    NUMBER       := NULL
	,p_locator_ctrl                IN    NUMBER       := NULL
	,p_locator                     IN    VARCHAR2     := NULL
    ,p_lot                         IN    VARCHAR2     := NULL
    ,p_serial                      IN    VARCHAR2     := NULL
	,p_manual_flag                 IN    VARCHAR2     := NULL
	,p_serial_status               IN    VARCHAR2     := NULL
    ,p_qa_collection_id            IN		NUMBER DEFAULT NULL
    ,p_attribute_category  IN VARCHAR2 := null
    ,p_attribute1          IN VARCHAR2 := null
    ,p_attribute2          IN VARCHAR2 := null
	,p_attribute3          IN VARCHAR2 := null
    ,p_attribute4          IN VARCHAR2 := null
    ,p_attribute5          IN VARCHAR2 := null
    ,p_attribute6          IN VARCHAR2 := null
    ,p_attribute7          IN VARCHAR2 := null
    ,p_attribute8          IN VARCHAR2 := null
    ,p_attribute9          IN VARCHAR2 := null
    ,p_attribute10         IN VARCHAR2 := null
    ,p_attribute11         IN VARCHAR2 := null
    ,p_attribute12         IN VARCHAR2 := null
    ,p_attribute13         IN VARCHAR2 := null
    ,p_attribute14         IN VARCHAR2 := null
    ,p_attribute15         IN VARCHAR2 := null
  );

-------------------------------------------------------------------------------
-- Creating easy work order
-- insert row into wip_discrete_jobs, wip_entities
-- create a default operation 10 for the new work order
-- release the work order and call wip_change_status.release
-------------------------------------------------------------------------------
  procedure create_ez_work_order
    (  p_api_version                 IN    NUMBER        := 1.0
      ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
      ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
      ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
      ,p_record_version_number       IN    NUMBER        := NULL
      ,x_return_status               OUT NOCOPY   VARCHAR2
      ,x_msg_count                   OUT NOCOPY   NUMBER
      ,x_msg_data                    OUT NOCOPY   VARCHAR2
      ,p_organization_id             IN    NUMBER        := 929
      ,p_asset_number                IN    VARCHAR2  --corresponds to serial number in csi_item_instances
      ,p_asset_group                 IN    VARCHAR2
      ,p_work_order_type             IN    NUMBER        -- data
      ,p_description                 IN    VARCHAR2
      ,p_activity_type               IN    NUMBER
      ,p_activity_cause              IN    NUMBER
      ,p_scheduled_start_date        IN    DATE
      ,p_scheduled_completion_date   IN    DATE
      ,p_owning_department           IN    VARCHAR2
      ,p_priority                    IN    NUMBER
      ,p_request_type   IN NUMBER  := 1
      ,p_work_request_number         IN    VARCHAR2
      ,p_work_request_id             IN    NUMBER
      ,x_new_work_order_name         OUT NOCOPY   VARCHAR2
      ,x_new_work_order_id           OUT NOCOPY   NUMBER
      ,p_asset_activity              IN    VARCHAR2 DEFAULT NULL
      ,p_project_number              IN    VARCHAR2 DEFAULT NULL
      ,p_task_number                 IN    VARCHAR2 DEFAULT NULL
      ,p_service_request_number	   IN    VARCHAR2 DEFAULT NULL
      ,p_service_request_id	   IN	 NUMBER   DEFAULT NULL
      ,p_material_issue_by_mo	   IN    VARCHAR2 DEFAULT NULL
      ,p_status_type                 IN    NUMBER
      ,p_mode                        IN    NUMBER
      ,p_wip_entity_name     IN    VARCHAR2
      ,p_user_id                     IN    NUMBER
      ,p_responsibility_id           IN    NUMBER
      ,p_firm                        IN    VARCHAR2  -- JSP passes it as a string
      ,p_activity_source             IN    NUMBER
      ,p_shutdown_type               IN    NUMBER
      ,p_parent_work_order	   IN		VARCHAR2 DEFAULT NULL
       ,p_sched_parent_wip_entity_id  IN    VARCHAR2  DEFAULT NULL
      ,p_relationship_type      IN    VARCHAR2  DEFAULT NULL
      , p_attribute_category    IN    VARCHAR2   DEFAULT NULL
      , p_attribute1                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute2                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute3                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute4                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute5                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute6                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute7                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute8                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute9                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute10                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute11                   IN    VARCHAR2   DEFAULT NULL
      , p_attribute12                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute13                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute14                    IN    VARCHAR2   DEFAULT NULL
      , p_attribute15                    IN    VARCHAR2   DEFAULT NULL
      , p_failure_id          IN NUMBER			DEFAULT NULL
      , p_failure_date        IN DATE				DEFAULT NULL
      , p_failure_entry_id    IN NUMBER		DEFAULT NULL
      , p_failure_code        IN VARCHAR2		 DEFAULT NULL
      , p_cause_code          IN VARCHAR2		DEFAULT NULL
      , p_resolution_code     IN VARCHAR2		DEFAULT NULL
      , p_failure_comments    IN VARCHAR2		DEFAULT NULL
      , p_failure_code_required     IN VARCHAR2 DEFAULT NULL
      , p_instance_number     IN    VARCHAR2  --corresponds to instance_number in csi_item_instances (for Bug 8667921)
    );






  -----------------------------------------------------------------------------------
  -- update work order, not involved in changes that could invoke transaction
  -----------------------------------------------------------------------------------
  procedure update_work_order
  (  p_api_version                 IN    NUMBER        := 1.0
    ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
    ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
    ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
    ,p_record_version_number       IN    NUMBER        := NULL
    ,x_return_status               OUT NOCOPY   VARCHAR2
    ,x_msg_count                   OUT NOCOPY   NUMBER
    ,x_msg_data                    OUT NOCOPY   VARCHAR2
    ,p_wip_entity_id               IN    NUMBER
    ,p_description                 IN    VARCHAR2
    ,p_owning_department           IN    VARCHAR2
    ,p_priority                    IN    NUMBER
    ,p_shutdown_type               IN    VARCHAR2
    ,p_activity_type               IN    VARCHAR2
    ,p_activity_cause              IN    VARCHAR2
    ,p_firm_planned_flag           IN    NUMBER
    ,p_notification_required       IN    VARCHAR2
    ,p_tagout_required             IN    VARCHAR2
    ,p_scheduled_start_date        IN    DATE
    ,p_stored_last_update_date     IN    DATE
   );

   procedure get_completion_defaults (
     p_wip_entity_id in number
    ,p_tx_type in number default 1
    ,p_sched_start_date in date default null
    ,p_sched_end_date in date default null
    ,x_start_date out NOCOPY date
    ,x_end_date out NOCOPY date
    ,x_return_status out NOCOPY varchar2
    ,x_msg_count out NOCOPY number
    ,x_msg_data out NOCOPY varchar2
   );

        procedure Add_WorkOrder_Dependency (
      p_api_version                 IN    NUMBER         := 1.0
      ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_TRUE
      ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
      ,p_organization_id             IN	   NUMBER
      ,p_prior_object_id	     IN	   NUMBER
      ,p_prior_object_type_id	     IN	   NUMBER
      ,p_next_object_id 	     IN	   NUMBER
      ,p_next_object_type_id	     IN	   NUMBER
      ,x_return_status               OUT NOCOPY   VARCHAR2
      ,x_msg_count                   OUT NOCOPY   NUMBER
      ,x_msg_data                    OUT NOCOPY   VARCHAR2
     );

    procedure Delete_WorkOrder_Dependency (
      p_api_version                 IN    NUMBER         := 1.0
      ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_TRUE
      ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
      ,p_organization_id             IN    NUMBER
      ,p_prior_object_id	     IN	   NUMBER
      ,p_prior_object_type_id	     IN	   NUMBER
      ,p_next_object_id 	     IN	   NUMBER
      ,p_next_object_type_id	     IN	   NUMBER
      ,p_relationship_type           IN NUMBER := 2
      ,x_return_status               OUT NOCOPY   VARCHAR2
      ,x_msg_count                   OUT NOCOPY   NUMBER
      ,x_msg_data                    OUT NOCOPY   VARCHAR2
     );

    -- Start of comments
   -- API name    : resize_wo_edit_hierarchy_pvt
   -- Type     :  Private.
   -- Function : Insert the hierarchy into the CST_EAM_HIERARCHY_SNAPSHOT table.
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version      IN NUMBER
   --          p_init_msg_list    IN VARCHAR2 Default = FND_API.G_FALSE
   --          p_commit           IN VARCHAR2 Default = FND_API.G_FALSE
   --          p_validation_level IN NUMBER Default = FND_API.G_VALID_LEVEL_FULL
   --          p_object_id        IN NUMBER
   --          p_object_type_id   IN NUMBER
   --          p_schedule_start_date IN DATE
   --          p_schedule_end_date   IN DATE
   --          p_requested_start_date IN DATE := NULL
   --	       p_requested_due_date IN DATE := NULL
   --          p_duration_for_shifting IN NUMBER
   --          p_firm IN NUMBER
   -- OUT      x_return_status      OUT NOCOPY  NUMBER
   --          x_msg_count	    OUT	NOCOPY NUMBER
   --          x_msg_data           OUT	NOCOPY VARCHAR2
   -- Notes    : The procedure sees if the dates being passed are >= current date.
   --          Consider only schedule start and end date if schedule start date,end date and duration
   --          is entered.If any 2 is given calculate the other and pass the Start Date and End Date
   --          to the API to resize the workorder.
   --
   -- End of comments
/*Bug3521886: Pass requested start date and due date*/
PROCEDURE resize_wo_hierarchy_pvt(
	p_api_version           IN NUMBER   ,
	p_init_msg_list    	IN VARCHAR2:= FND_API.G_TRUE,
	p_commit 		IN VARCHAR2:= FND_API.G_FALSE ,
	p_validation_level 	IN NUMBER:= FND_API.G_VALID_LEVEL_FULL,
 	p_object_id 	IN NUMBER,
	p_object_type_id IN NUMBER,
	p_schedule_start_date 	IN DATE,
	p_schedule_end_date 	IN DATE,
	p_duration_for_shifting	IN NUMBER,
	p_requested_start_date IN DATE := NULL ,
	p_requested_due_date IN DATE := NULL,
	p_firm IN NUMBER,
	p_org_id IN VARCHAR2,
	x_return_status		OUT	NOCOPY VARCHAR2	,
	x_msg_count		OUT	NOCOPY NUMBER	,
	x_msg_data		OUT	NOCOPY VARCHAR2
   ) ;

   -- Start of comments
   -- API name    : create_cost_hierarchy_pvt
   -- Type     :  Private.
   -- Function : Creates the costing hierarchy from the scheduling hierarchy.
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version      IN NUMBER
   --          p_init_msg_list    IN VARCHAR2 Default = FND_API.G_TRUE
   --          p_commit           IN VARCHAR2 Default = FND_API.G_FALSE
   --          p_validation_level IN NUMBER Default = FND_API.G_VALID_LEVEL_FULL
   --          p_top_level_object_id IN VARCHAR2
   -- OUT      x_return_status      OUT NOCOPY  NUMBER
   --          x_msg_count	    OUT	NOCOPY NUMBER
   --          x_msg_data           OUT	NOCOPY VARCHAR2
   -- Notes    : The procedure gets the entire work hierarchy for the required top_level_object_id.
   --          It then passes the child workorder and the parent Work order to the Process_Master_Child_WO
   --          in the EAM_PROCESS_WO_PUB, to generate the costing relationship between the 2 workorders
   --
   -- End of comments

   procedure create_cost_hierarchy_pvt(
        p_api_version           IN NUMBER  :=1.0 ,
	p_init_msg_list    	IN VARCHAR2:= FND_API.G_TRUE,
	p_commit 		IN VARCHAR2:= FND_API.G_FALSE ,
	p_validation_level 	IN NUMBER:= FND_API.G_VALID_LEVEL_FULL,
        p_wip_entity_id   IN VARCHAR2,
	p_org_id IN VARCHAR2,
        x_return_status		OUT	NOCOPY VARCHAR2	,
	x_msg_count		OUT	NOCOPY NUMBER	,
	x_msg_data		OUT	NOCOPY VARCHAR2
   ) ;


end EAM_WORKORDERS_JSP;

/
