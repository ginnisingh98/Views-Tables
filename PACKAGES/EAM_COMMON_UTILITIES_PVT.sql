--------------------------------------------------------
--  DDL for Package EAM_COMMON_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_COMMON_UTILITIES_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMPUTLS.pls 120.12.12010000.2 2008/11/06 23:51:26 mashah ship $*/
   -- Start of comments
   -- API name    : APIname
   -- Type     : Public or Group or Private.
   -- Function :
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version              IN NUMBER   Required
   --          p_init_msg_list    IN VARCHAR2    Optional
   --                                                  Default = FND_API.G_FALSE
   --          p_commit          IN VARCHAR2 Optional
   --             Default = FND_API.G_FALSE
   --          p_validation_level      IN NUMBER   Optional
   --             Default = FND_API.G_VALID_LEVEL_FULL
   --          parameter1
   --          parameter2
   --          .
   --          .
   -- OUT      x_return_status      OUT   VARCHAR2(1)
   --          x_msg_count       OUT   NUMBER
   --          x_msg_data        OUT   VARCHAR2(2000)
   --          parameter1
   --          parameter2
   --          .
   --          .
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

   PROCEDURE get_org_code(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER
            := fnd_api.g_valid_level_full
     ,p_organization_id    IN       NUMBER
     ,x_organization_code  OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2);

   -- Start of comments
   -- API name    : APIname
   -- Type     : Public or Group or Private.
   -- Function :
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version              IN NUMBER   Required
   --          p_init_msg_list    IN VARCHAR2    Optional
   --                                                  Default = FND_API.G_FALSE
   --          p_commit          IN VARCHAR2 Optional
   --             Default = FND_API.G_FALSE
   --          p_validation_level      IN NUMBER   Optional
   --             Default = FND_API.G_VALID_LEVEL_FULL
   --          parameter1
   --          parameter2
   --          .
   --          .
   -- OUT      x_return_status      OUT   VARCHAR2(1)
   --          x_msg_count       OUT   NUMBER
   --          x_msg_data        OUT   VARCHAR2(2000)
   --          parameter1
   --          parameter2
   --          .
   --          .
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

   PROCEDURE get_item_id(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER
            := fnd_api.g_valid_level_full
     ,p_organization_id    IN       NUMBER
     ,p_concatenated_segments IN    VARCHAR2
     ,x_inventory_item_id  OUT NOCOPY      NUMBER
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2);




     PROCEDURE get_current_period(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER
            := fnd_api.g_valid_level_full
     ,p_organization_id    IN       NUMBER
     ,x_period_name  OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2);


     PROCEDURE get_currency(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER
            := fnd_api.g_valid_level_full
     ,p_organization_id    IN       NUMBER
     ,x_currency  OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2);



   -- Start of comments
   -- API name    : APIname
   -- Type     : Public or Group or Private.
   -- Function :
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version              IN NUMBER   Required
   --          p_init_msg_list    IN VARCHAR2    Optional
   --                                                  Default = FND_API.G_FALSE
   --          p_commit          IN VARCHAR2 Optional
   --             Default = FND_API.G_FALSE
   --          p_validation_level      IN NUMBER   Optional
   --             Default = FND_API.G_VALID_LEVEL_FULL
   --          parameter1
   --          parameter2
   --          .
   --          .
   -- OUT      x_return_status      OUT   VARCHAR2(1)
   --          x_msg_count       OUT   NUMBER
   --          x_msg_data        OUT   VARCHAR2(2000)
   --          parameter1
   --          parameter2
   --          .
   --          .
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

   PROCEDURE get_next_asset_number (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER
            := fnd_api.g_valid_level_full
     ,p_organization_id    IN       NUMBER
     ,p_inventory_item_id  IN       NUMBER
     ,x_asset_number       OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2);

PROCEDURE verify_org(
                      p_resp_id number default FND_GLOBAL.RESP_ID,
                      p_resp_app_id number default FND_GLOBAL.RESP_APPL_ID,
                      p_org_id     number,
                      p_init_msg_list in VARCHAR2 := FND_API.G_FALSE,
                      x_boolean   out NOCOPY  number,
                      x_return_status out NOCOPY VARCHAR2,
                      x_msg_count out NOCOPY NUMBER,
                      x_msg_data out NOCOPY VARCHAR2);

FUNCTION invalid_item_name (p_item_name in varchar2)
      	return boolean;

FUNCTION  get_mfg_meaning(p_lookup_type in VARCHAR2 , p_lookup_code in number)
                                return VARCHAR2 ;

FUNCTION get_item_name(p_service_request_id in number,
            p_org_id        in number,
            p_inv_organization_id in number
        ) return varchar2;


-- Following new functions added by lllin for 11.5.10

-- This function validates an asset group, asset activity, or
-- rebuildable item. p_eam_item_type indicates the type of item being
-- validated. Asset group: 1; Asset activity: 2; Rebuildable item: 3.
FUNCTION validate_inventory_item_id
(
	p_organization_id in number,
	p_inventory_item_id in number,
	p_eam_item_type in number
) return boolean;

-- This function validates an asset number or serialized rebuildable.
-- p_eam_item_type indicates the type of serial number being validated.
-- Asset group: 1; Asset activity: 2; Rebuildable item: 3.
FUNCTION validate_serial_number
(
	p_organization_id in number,
	p_inventory_item_id in number,
	p_serial_number in varchar2,
	p_eam_item_type in number:=1
) return boolean;

-- This function validates the boolean flags.
-- A boolean flag has to be either 'Y' or 'N'.
FUNCTION validate_boolean_flag
(
	p_flag in varchar2
) return boolean;

-- Following function validates department id in bom_departments table.
FUNCTION validate_department_id
(
	p_department_id in number,
        p_organization_id in number

) return boolean;

-- Validates eam location id in mtl_eam_locations table.
FUNCTION validate_eam_location_id
(
        p_location_id in number
) return boolean;

-- The following function should NOT be called for rebuilds
-- This function validates the eam location for an asset.
-- The location has to exist, and its organization_id has to
-- the same as the current_organization_id of the serial number.
FUNCTION validate_eam_location_id_asset
(
	p_organization_id in number,  -- use organization id, not creation org id
	p_location_id in number
) return boolean;

FUNCTION validate_wip_acct_class_code
(
	p_organization_id in number,
	p_wip_accounting_class_code in varchar2
) return boolean;


-- This function validates a meter_id.
-- If p_tmpl_flag is null, then p_meter_id can be either template or instance
-- to be valid.
-- If p_tmpl_flag is 'Y', p_meter_id has to be a template.
-- If p_tmpl_flag is 'N', p_meter_id has to be an instance.
-- If p_tmpl_flag is not null, not 'Y', and not 'N', false is returned.
FUNCTION validate_meter_id
(
	p_meter_id in number,
        p_tmpl_flag in varchar2:=null
) return boolean;

function validate_desc_flex_field
        (
        p_app_short_name        IN                      VARCHAR:='EAM',
        p_desc_flex_name        IN                      VARCHAR,
        p_ATTRIBUTE_CATEGORY    IN                      VARCHAR2 default null,
        p_ATTRIBUTE1            IN                        VARCHAR2 default null,
        p_ATTRIBUTE2            IN                        VARCHAR2 default null,
        p_ATTRIBUTE3            IN                        VARCHAR2 default null,
        p_ATTRIBUTE4            IN                        VARCHAR2 default null,
        p_ATTRIBUTE5            IN                        VARCHAR2 default null,
        p_ATTRIBUTE6            IN                        VARCHAR2 default null,
        p_ATTRIBUTE7            IN                        VARCHAR2 default null,
        p_ATTRIBUTE8            IN                        VARCHAR2 default null,
        p_ATTRIBUTE9            IN                        VARCHAR2 default null,
        p_ATTRIBUTE10           IN                       VARCHAR2 default null,
        p_ATTRIBUTE11           IN                       VARCHAR2 default null,
        p_ATTRIBUTE12           IN                       VARCHAR2 default null,
        p_ATTRIBUTE13           IN                       VARCHAR2 default null,
        p_ATTRIBUTE14           IN                       VARCHAR2 default null,
        p_ATTRIBUTE15           IN                       VARCHAR2 default null,
        x_error_segments        OUT NOCOPY               NUMBER,
        x_error_message         OUT NOCOPY               VARCHAR2
)
return boolean;

FUNCTION  validate_mfg_lookup_code
          (p_lookup_type in VARCHAR2,
           p_lookup_code in NUMBER)
return boolean;

-- Validates that the maintained object type and id represent a valid
-- maintained object.
-- x_eam_item_type represents the eam_item_type of the object.

FUNCTION validate_maintained_object_id
	(p_maintenance_object_type in NUMBER,
	p_maintenance_object_id in NUMBER,
	p_organization_id in NUMBER default null,
	p_eam_item_type in NUMBER
	)
return boolean;

-- Validates that the combination (Organization_id, inventory_item_id, and
-- serial number) and the combination (maintenance_object_type and
-- maintenance_object_id) represent the same valid maintained object.
-- x_eam_item_type represents the eam_item_type of the object.

FUNCTION validate_maintained_object
	(p_organization_id in NUMBER,
	p_inventory_item_id in NUMBER,
	p_serial_number in VARCHAR2 default null,
	p_maintenance_object_type in NUMBER,
	p_maintenance_object_id in NUMBER,
	p_eam_item_type in NUMBER)
return boolean;

-- Translates a combination of {organization_id, inventory_item_id, and
-- serial_number} into a combination of {maintenance_object_type and
-- maintenance_object_id}.
-- If the object is found, x_object_found is true, and vice-versa.
-- Serial_number can be null.

procedure translate_asset_maint_obj
        (p_organization_id in number,
        p_inventory_item_id in number,
        p_serial_number in varchar2 default null,
        x_object_found out nocopy boolean,
        x_maintenance_object_type out nocopy number,
        x_maintenance_object_id out nocopy number);


-- Translates a combination of {maintenance_object_type and
-- maintenance_object_id} into a combination of {organization_id,
-- inventory_item_id, and serial_number}.
-- If maintenance_object_type is 2, p_organization_id must be supplied.

procedure translate_maint_obj_asset
        (p_maintenance_object_type in number,
        p_maintenance_object_id in number,
        p_organization_id in number default null,
        x_object_found out nocopy boolean,
        x_organization_id out nocopy number,
        x_inventory_item_id out nocopy number,
        x_serial_number out nocopy varchar2
        );

/* ----------------------------------------------------------------------------------------------
-- Procedure to get the sum of today's work, overdue work, open work and unassigned work in Maintenance
-- Engineer's Workbench
-- Author : amondal, Aug '03
------------------------------------------------------------------------------------------------*/

PROCEDURE get_work_order_count (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
     ,p_organization_id    IN       VARCHAR2
     ,p_employee_id  IN       VARCHAR2
     ,p_instance_id	   IN       NUMBER
     ,p_asset_group_id	   IN       NUMBER
     ,p_department_id	   IN       NUMBER
     ,p_resource_id	   IN       NUMBER
     ,p_current_date      IN  VARCHAR2
     ,x_todays_work        OUT NOCOPY      VARCHAR2
     ,x_overdue_work       OUT NOCOPY      VARCHAR2
     ,x_open_work          OUT NOCOPY      VARCHAR2
     ,x_todays_work_duration OUT NOCOPY      VARCHAR2
     ,x_overdue_work_duration OUT NOCOPY      VARCHAR2
     ,x_open_work_duration OUT NOCOPY      VARCHAR2
     ,x_current_date   OUT NOCOPY      VARCHAR2
     ,x_current_time   OUT NOCOPY      VARCHAR2
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2);

  /* ----------------------------------------------------------------------------------------------
 -- Procedure for inserting into WIP_OP_RESOURCE_INSTANCES in Maintenance
 -- Engineer's Workbench
 -- Author : amondal, Aug '03
------------------------------------------------------------------------------------------------*/

   PROCEDURE  insert_into_wori (
         p_api_version        IN       NUMBER
        ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
        ,p_commit             IN       VARCHAR2 := fnd_api.g_false
        ,p_organization_id    IN       VARCHAR2
        ,p_employee_id        IN       VARCHAR2
        ,p_wip_entity_id      IN    VARCHAR2
        ,p_operation_seq_num  IN  VARCHAR2
        ,p_resource_seq_num   IN  VARCHAR2
        ,p_resource_id        IN  VARCHAR2
        ,x_return_status      OUT NOCOPY      VARCHAR2
        ,x_msg_count          OUT NOCOPY      NUMBER
        ,x_msg_data           OUT NOCOPY      VARCHAR2
        ,x_wip_entity_name    OUT NOCOPY      VARCHAR2);

   FUNCTION get_person_id RETURN VARCHAR2;

function get_dept_id(p_org_code in varchar2, p_org_id in number, p_dept_code in varchar2, p_dept_id in number)
return number;

PROCEDURE deactivate_assets(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_INVENTORY_ITEM_ID IN NUMBER DEFAULT NULL,
  P_SERIAL_NUMBER IN VARCHAR2 DEFAULT NULL,
  P_ORGANIZATION_ID IN NUMBER,
  P_GEN_OBJECT_ID IN NUMBER DEFAULT NULL,
  P_INSTANCE_ID	IN NUMBER DEFAULT NULL,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
  X_MSG_COUNT OUT NOCOPY NUMBER,
  X_MSG_DATA OUT NOCOPY VARCHAR2);


procedure log_api_return(
 p_module in varchar2 default 'eam.plsql.eam_common_utilities_pvt.log_api_return',
 p_api in varchar2 default 'Unknown API',
 p_return_status in varchar2 default null,
 p_msg_count in number default null,
 p_msg_data in varchar2 default null
);


FUNCTION get_onhand_quant(p_org_id in number, p_inventory_item_id in number)
RETURN number ;


/* Bug # 3698307
   validate_linear_id is added for Linear Asset Management project
   Basically it verify's whether the passed linear_id exists in EAM_LINEAR_LOCATIONS
   table or not.
*/

FUNCTION validate_linear_id(p_eam_linear_id IN NUMBER)
RETURN BOOLEAN;


--------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Create_Asset                                                         --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API is used to create an IB instance whenever a work order is   --
--   saved on a rebuild in predefined status. It will call the wrapper    --
--   API that in turn calls the IB create_asset API                       --
--   It  a) Create the IB instance b) Updates current status in MSN       --
--   c) Instantiates the rebuild d) Updates the WO Record                 --
--                                                                        --
--   This API is invoked from the WO API.                                 --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 12                                           --
--                                                                        --
-- HISTORY:                                                               --
--    05/20/05     Anju Gupta       Created                               --
----------------------------------------------------------------------------


 PROCEDURE CREATE_ASSET(
          P_API_VERSION                IN NUMBER
         ,P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE
         ,P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE
         ,P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL
         ,X_EAM_WO_REC                 IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
             ,X_RETURN_STATUS              OUT NOCOPY VARCHAR2
             ,X_MSG_COUNT                  OUT NOCOPY NUMBER
             ,X_MSG_DATA                   OUT NOCOPY VARCHAR2
        );

FUNCTION check_deactivate(
	p_maintenance_object_id		IN	NUMBER, -- for Maintenance Object Type of 3, this should be Instance_Id
	p_maintenance_object_type	IN	NUMBER --  Type 3 (Instance Id)

)
return boolean;

FUNCTION  get_parent_asset(p_parent_job_id in number, p_organization_id in number)
                                return VARCHAR2 ;


PROCEDURE write_WORU (
				P_WIP_ENTITY_ID  	IN  NUMBER
				,P_ORGANIZATION_ID  IN 	NUMBER
	        	,P_OPERATION_SEQ_NUM IN  NUMBER
	        	,P_RESOURCE_SEQ_NUM	IN  NUMBER
	           	,P_UPDATE_HIERARCHY IN  VARCHAR2
	           	,P_START			IN	DATE
	           	,P_END				IN	DATE
	           	,P_DELTA			IN	NUMBER
	            ,X_RETURN_STATUS    OUT NOCOPY VARCHAR2
	            ,X_MSG_COUNT        OUT NOCOPY NUMBER
	            ,X_MSG_DATA         OUT NOCOPY VARCHAR2
	);

PROCEDURE Adjust_WORU (
				 P_API_VERSION      IN NUMBER
            	,P_INIT_MSG_LIST    IN VARCHAR2 := FND_API.G_FALSE
	            ,P_COMMIT           IN VARCHAR2 := FND_API.G_FALSE
	        	,P_VALIDATION_LEVEL	IN NUMBER   := FND_API.G_VALID_LEVEL_FULL
	        	,P_WIP_ENTITY_ID  	IN  NUMBER
	        	,P_ORGANIZATION_ID  IN 	NUMBER
	        	,P_OPERATION_SEQ_NUM IN  NUMBER
	        	,P_RESOURCE_SEQ_NUM	IN  NUMBER
	        	,P_DELTA			IN  NUMBER
	        	,P_UPDATE_HIERARCHY IN  VARCHAR2
	            ,X_RETURN_STATUS    OUT NOCOPY VARCHAR2
	            ,X_MSG_COUNT        OUT NOCOPY NUMBER
	            ,X_MSG_DATA         OUT NOCOPY VARCHAR2
	);

-- Function to fetch Asset area code for corresponding maintenance organization.
FUNCTION get_asset_area( p_instance_id NUMBER, p_maint_org_id NUMBER) RETURN VARCHAR2;


PROCEDURE set_profile(
       	  name in varchar2,
       	  value in varchar2
	) ;
Function is_active(
	p_instance_id	number
) return varchar2;

-- Function to check if completion subinventory, locator and lot are required to be shown in SSWA Work Order Completion Page.
FUNCTION showCompletionFields( p_wip_entity_id NUMBER ) RETURN VARCHAR2;


PROCEDURE update_logical_asset(
	p_inventory_item_id	number
        ,p_serial_number  varchar2
        ,p_equipment_gen_object_id  number
	,p_network_asset_flag varchar2
	,p_pn_location_id number
	,x_return_status out nocopy varchar2
);

FUNCTION get_scheduled_start_date( p_wip_entity_id NUMBER ) RETURN DATE;

FUNCTION get_scheduled_completion_date( p_wip_entity_id NUMBER ) RETURN DATE;

END EAM_COMMON_UTILITIES_PVT;


/
