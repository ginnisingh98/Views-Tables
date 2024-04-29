--------------------------------------------------------
--  DDL for Package EAM_LINEAR_LOCATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_LINEAR_LOCATIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPELLS.pls 120.0 2005/05/25 16:01:37 appldev noship $*/
   -- Start of comments
   -- API name : eam_linear_locations_pub
   -- Type     : Public.
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

   TYPE bom_departments_record is RECORD
   (
   	Department_Id 	bom_departments.department_id%type,
   	Department_Code bom_departments.department_code%type,
   	Description	bom_departments.description%type,
   	Organization_Id bom_departments.organization_id%type

   );

   Type Bom_Departments_Table is TABLE of bom_departments_record index by binary_integer;

   TYPE Org_Access_Record is record
   (
   	Organization_Id		Number,
   	Organization_Code	Varchar2(3),
   	Organization_Name	Varchar2(240)

   );

   TYPE Org_Access_Table is TABLE of Org_Access_Record index by binary_integer;

   TYPE Work_Request_Record is record
   (
   	Work_Request_Number		Number,
	Asset_Number	Varchar2(80),
	ORGANIZATION_CODE varchar2(3),
	Organization_Name varchar2(240),
	work_request_status varchar2(80),
	work_request_priority varchar2(80),
	owning_dept_code varchar2(80),
	owning_dept_description varchar2(80),
	EXPECTED_RESOLUTION_DATE                  DATE,
	work_order varchar2(80),
	DESCRIPTION                               VARCHAR2(240),
	WORK_REQUEST_TYPE                     VARCHAR2(80),
	PHONE_NUMBER                              VARCHAR2(4000),
	E_MAIL                                    VARCHAR2(240),
	CONTACT_PREFERENCE                        NUMBER(30,0)
   );

   TYPE Work_Request_Table is TABLE of Work_Request_Record index by binary_integer;


   Type Work_Order_Record is record
        ( HEADER_ID                     NUMBER          :=null,
          BATCH_ID                      NUMBER          :=null,
          ROW_ID                        NUMBER          :=null,
          WIP_ENTITY_NAME               VARCHAR2(240)   :=null,
          WIP_ENTITY_ID                 NUMBER          :=null,
          ORGANIZATION_ID               NUMBER          :=null,
          DESCRIPTION                   VARCHAR2(240)   :=null,
          ASSET_NUMBER                  VARCHAR2(30)    :=null,
          ASSET_GROUP_ID                NUMBER          :=null,
          REBUILD_ITEM_ID               NUMBER          :=null,
          REBUILD_SERIAL_NUMBER         VARCHAR2(30)    :=null,
          MAINTENANCE_OBJECT_ID         NUMBER          :=null,
          MAINTENANCE_OBJECT_TYPE       NUMBER          :=null,
          MAINTENANCE_OBJECT_SOURCE     NUMBER          :=null,
          EAM_LINEAR_LOCATION_ID        NUMBER          :=null,
          CLASS_CODE                    VARCHAR2(10)    :=null,
          ASSET_ACTIVITY_ID             NUMBER          :=null,
          ACTIVITY_TYPE                 VARCHAR2(30)    :=null,
          ACTIVITY_CAUSE                VARCHAR2(30)    :=null,
          ACTIVITY_SOURCE               VARCHAR2(30)    :=null,
          WORK_ORDER_TYPE               VARCHAR2(30)    :=null,
          STATUS_TYPE                   NUMBER          :=null,
          WO_STATUS                     VARCHAR2(80)    :=null,
          JOB_QUANTITY                  NUMBER          :=null,
          DATE_RELEASED                 DATE            :=null,
          OWNING_DEPARTMENT             NUMBER          :=null,
          PRIORITY                      NUMBER          :=null,
          REQUESTED_START_DATE          DATE            :=null,
          DUE_DATE                      DATE            :=null,
          SHUTDOWN_TYPE                 VARCHAR2(30)    :=null,
          FIRM_PLANNED_FLAG             NUMBER          :=null,
          NOTIFICATION_REQUIRED         VARCHAR2(1)     :=null,
          TAGOUT_REQUIRED               VARCHAR2(1)     :=null,
          PLAN_MAINTENANCE              VARCHAR2(1)     :=null,
          PROJECT_ID                    NUMBER          :=null,
          TASK_ID                       NUMBER          :=null,
          END_ITEM_UNIT_NUMBER          VARCHAR2(30)    :=null,
          SCHEDULE_GROUP_ID             NUMBER          :=null,
          BOM_REVISION_DATE             DATE            :=null,
          ROUTING_REVISION_DATE         DATE            :=null,
          ALTERNATE_ROUTING_DESIGNATOR  VARCHAR2(10)    :=null,
          ALTERNATE_BOM_DESIGNATOR      VARCHAR2(10)    :=null,
          ROUTING_REVISION              VARCHAR2(3)     :=null,
          BOM_REVISION                  VARCHAR2(3)     :=null,
          PARENT_WIP_ENTITY_ID          NUMBER          :=null,
          MANUAL_REBUILD_FLAG           VARCHAR2(1)     :=null,
          PM_SCHEDULE_ID                NUMBER          :=null,
          WIP_SUPPLY_TYPE               NUMBER          :=null,
          MATERIAL_ACCOUNT              NUMBER          :=null,
          MATERIAL_OVERHEAD_ACCOUNT     NUMBER          :=null,
          RESOURCE_ACCOUNT              NUMBER          :=null,
          OUTSIDE_PROCESSING_ACCOUNT    NUMBER          :=null,
          MATERIAL_VARIANCE_ACCOUNT     NUMBER          :=null,
          RESOURCE_VARIANCE_ACCOUNT     NUMBER          :=null,
          OUTSIDE_PROC_VARIANCE_ACCOUNT NUMBER          :=null,
          STD_COST_ADJUSTMENT_ACCOUNT   NUMBER          :=null,
          OVERHEAD_ACCOUNT              NUMBER          :=null,
          OVERHEAD_VARIANCE_ACCOUNT     NUMBER          :=null,
          SCHEDULED_START_DATE          DATE            :=null,
          SCHEDULED_COMPLETION_DATE     DATE            :=null,
          COMMON_BOM_SEQUENCE_ID        NUMBER          :=null,
          COMMON_ROUTING_SEQUENCE_ID    NUMBER          :=null,
          PO_CREATION_TIME              NUMBER          :=null,
          GEN_OBJECT_ID                 NUMBER          :=null,
	  RUN_SCHEDULER			VARCHAR2(1)     :=null,
          ATTRIBUTE_CATEGORY            VARCHAR2(30)    :=null,
          ATTRIBUTE1                    VARCHAR2(150)   :=null,
          ATTRIBUTE2                    VARCHAR2(150)   :=null,
          ATTRIBUTE3                    VARCHAR2(150)   :=null,
          ATTRIBUTE4                    VARCHAR2(150)   :=null,
          ATTRIBUTE5                    VARCHAR2(150)   :=null,
          ATTRIBUTE6                    VARCHAR2(150)   :=null,
          ATTRIBUTE7                    VARCHAR2(150)   :=null,
          ATTRIBUTE8                    VARCHAR2(150)   :=null,
          ATTRIBUTE9                    VARCHAR2(150)   :=null,
          ATTRIBUTE10                   VARCHAR2(150)   :=null,
          ATTRIBUTE11                   VARCHAR2(150)   :=null,
          ATTRIBUTE12                   VARCHAR2(150)   :=null,
          ATTRIBUTE13                   VARCHAR2(150)   :=null,
          ATTRIBUTE14                   VARCHAR2(150)   :=null,
          ATTRIBUTE15                   VARCHAR2(150)   :=null,
          MATERIAL_ISSUE_BY_MO          VARCHAR2(1)     :=null,
          ISSUE_ZERO_COST_FLAG          VARCHAR2(1)     :=null,
          USER_ID                       NUMBER          :=null,
          RESPONSIBILITY_ID             NUMBER          :=null,
          REQUEST_ID                    NUMBER          :=null,
          PROGRAM_ID                    NUMBER          :=null,
          PROGRAM_APPLICATION_ID        NUMBER          :=null,
          SOURCE_LINE_ID                NUMBER          :=null,
          SOURCE_CODE                   VARCHAR2(30)    :=null,
	  VALIDATE_STRUCTURE		VARCHAR2(1)	:='N',
          RETURN_STATUS                 VARCHAR2(1)     :=null,
          TRANSACTION_TYPE              NUMBER          :=null
        );

   TYPE Work_Order_Table is TABLE of Work_Order_Record index by binary_integer;


   PROCEDURE insert_row
   (
      p_api_version          IN  NUMBER
     ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
     ,p_commit               IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_external_linear_id   IN  NUMBER
     ,p_external_linear_name IN  VARCHAR2
     ,p_external_source_name IN  VARCHAR2
     ,p_external_linear_type IN  VARCHAR2
     ,x_eam_linear_id        OUT NOCOPY NUMBER
     ,x_return_status        OUT NOCOPY VARCHAR2
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
   );


   PROCEDURE update_row
   (
      p_api_version          IN  NUMBER
     ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
     ,p_commit               IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_external_linear_id   IN  NUMBER
     ,p_external_linear_name IN  VARCHAR2
     ,p_external_source_name IN  VARCHAR2
     ,p_external_linear_type IN  VARCHAR2
     ,p_eam_linear_id        IN  NUMBER
     ,x_return_status        OUT NOCOPY VARCHAR2
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
   );


   PROCEDURE get_eam_linear_id
   (
      p_api_version          IN  NUMBER
     ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_external_linear_id   IN  NUMBER
     ,p_external_source_name IN  VARCHAR2
     ,p_external_linear_type IN  VARCHAR2
     ,x_eam_linear_id        OUT NOCOPY NUMBER
     ,x_return_status        OUT NOCOPY VARCHAR2
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
   );

   procedure create_asset(
      p_api_version          IN  NUMBER
      ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
      ,p_commit               IN  VARCHAR2 := fnd_api.g_false
      ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
      ,p_external_linear_id   IN  NUMBER
      ,p_external_linear_name IN  VARCHAR2
      ,p_external_source_name IN  VARCHAR2
      ,p_external_linear_type IN  VARCHAR2
      ,p_serial_number	      IN  VARCHAR2
      ,p_user_name	      IN  VARCHAR2
      ,p_inventory_item_id    IN NUMBER
      ,p_current_organization_id IN NUMBER
      ,p_owning_department_id IN NUMBER
      ,p_descriptive_text     IN VARCHAR2
      ,x_object_id	      OUT NOCOPY VARCHAR2
      ,x_return_status        OUT NOCOPY VARCHAR2
      ,x_msg_count            OUT NOCOPY NUMBER
      ,x_msg_data             OUT NOCOPY VARCHAR2
   );

   procedure create_work_request(
            p_api_version          IN  NUMBER
            ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
            ,p_commit               IN  VARCHAR2 := fnd_api.g_false
            ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
            ,p_external_linear_id   IN  NUMBER
            ,p_external_linear_name IN  VARCHAR2
            ,p_external_source_name IN  VARCHAR2
            ,p_external_linear_type IN  VARCHAR2
            ,p_work_request_rec     IN  WIP_EAM_WORK_REQUESTS%ROWTYPE
            ,p_user_name	    IN VARCHAR2
            ,p_mode 		    IN VARCHAR2
            ,p_request_log	    IN VARCHAR2
            ,x_work_request_id	    OUT NOCOPY VARCHAR2
            ,x_return_status        OUT NOCOPY VARCHAR2
            ,x_msg_count            OUT NOCOPY NUMBER
            ,x_msg_data             OUT NOCOPY VARCHAR2
   );




        PROCEDURE CREATE_EAM_WO
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version             IN  NUMBER := 1.0
         , p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
         , p_commit                  IN  VARCHAR2 := fnd_api.g_false
         , p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
         , p_external_source_name    IN  VARCHAR2
         , p_external_linear_type    IN  VARCHAR2 := 'ASSET'
         , p_external_linear_name    IN  VARCHAR2
         , p_external_linear_id      IN  NUMBER
         , p_user_name	      	     IN  VARCHAR2
         , x_wip_entity_id           OUT NOCOPY NUMBER
         , x_msg_data                OUT NOCOPY VARCHAR2
         , p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , p_eam_wo_comp_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
         , p_eam_wo_quality_tbl      IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
         , p_eam_meter_reading_tbl   IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
         , p_eam_wo_comp_rebuild_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
         , p_eam_wo_comp_mr_read_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
         , p_eam_op_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
         , p_eam_request_tbl         IN  EAM_PROCESS_WO_PUB.eam_request_tbl_type
	 , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
	, x_eam_wo_comp_rec          OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
	, x_eam_wo_quality_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
	, x_eam_meter_reading_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
	, x_eam_wo_comp_rebuild_tbl  OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
	, x_eam_wo_comp_mr_read_tbl  OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
	, x_eam_op_comp_tbl          OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	, x_eam_request_tbl          OUT NOCOPY EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := fnd_api.g_false
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'EAM_WO_DEBUG.log'
         , p_debug_file_mode         IN  VARCHAR2 := 'w'
         );

         PROCEDURE return_bom_departments
         (
         	p_organization_id	 NUMBER
         	,p_user_name		VARCHAR2
         	,x_bom_departments_table OUT NOCOPY EAM_LINEAR_LOCATIONS_PUB.bom_departments_table
         );

         Procedure return_organizations
         (
         	p_user_name		VARCHAR2
         	,x_organizations_table	OUT NOCOPY EAM_LINEAR_LOCATIONS_PUB.Org_Access_Table
         );

	Procedure return_work_request_details
	(
		p_user_name	VARCHAR2
		, p_work_request_id number
		, x_work_request_table OUT NOCOPY EAM_LINEAR_LOCATIONS_PUB.Work_Request_Table
	);

	Procedure return_work_order_details
	(
		p_user_name	VARCHAR2
		, p_wip_entity_id number
		, x_work_order_rec OUT NOCOPY EAM_LINEAR_LOCATIONS_PUB.Work_Order_Record
	);


END eam_linear_locations_pub;

 

/
