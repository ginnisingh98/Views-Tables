--------------------------------------------------------
--  DDL for Package PA_PLAN_RES_LIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PLAN_RES_LIST_PUB" AUTHID CURRENT_USER AS
/* $Header: PARESLPS.pls 120.4 2006/07/24 13:51:50 dthakker noship $*/
/*#
 * This package contains the public APIs for project planning resource information.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Planning Resource List API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJ_PLANNING_RESOURCE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
/*
* *********************************************************************
* Package Name: Pa_Plan_Res_List_Pub
* Description:
*  This AMG package has 2 ways that it can be used depending on
*  customer needs and/or limitations of third party software:
*
*   1) Directly calling the Create_Resource_List() and Update_Resource_list() apis
*     passing it pl/sql records and tables and receiving back
*     the resource_list_id, resource_format_id, and resource_list_member_id's via
*     pl/sql table.
*
*   2) Calling the Following sequence of apis:
*      To add new Resource List:
*            i) Init_Create_Resource_List()  - required
*           ii) Load_Resource_List()         - required
*          iii) Load_Resource_Format()       - optional
*           iv) Load_Planning_Resource()     - optional
*            v  Exec_Create_Resource_List()  - required
*           vi) Fetch_Resource_List()        - optional
*          vii) Fetch_Plan_Format()          - optional
*        viii)  Fetch_Resource_List_Member() - optional
*       To Update the current Resource List:
*            i) Init_Update_Resource_List()  - required
*           ii) Load_Resource_List()         - optional
*          iii) Load_Resource_Format()       - optional
*           iv) Load_Planning_Resource()     - optional
*            v  Exec_Update_Resource_List()  - required
*           vi) Fetch_Resource_List()        - optional
*         vii)  Fetch_Plan_Format()          - optional
*         viii) Fetch_Resource_List_Member() - optional
*
*   Init procedure needs to be called explicitly before calling
*   any Load-Execute-Fetch procedures.
*
*   On any error or failed validation the processing will stop and
*   all insertion, updates, deletions will be undone and will not
*   be saved.
* ********************************************************************
*/

   -- Standard who
   g_last_updated_by              NUMBER(15)   := FND_GLOBAL.USER_ID;
   g_last_update_date             DATE         := SYSDATE;
   g_creation_date                DATE         := SYSDATE;
   g_created_by                   NUMBER(15)   := FND_GLOBAL.USER_ID;
   g_last_update_login            NUMBER(15)   := FND_GLOBAL.LOGIN_ID;
   g_pkg_name            CONSTANT VARCHAR2(30) := 'PA_PLAN_RES_LIST_PUB';
   g_api_version_number  CONSTANT NUMBER       := 1.0;

/**********************************************************************************
* Plan_Res_List_IN_Rec
* Description :
*  This is the planning resource list record structure. You need to
*  pass the planning resource list record whenever you are creating
*  a new planning resource list, or when you are updating an existing
*  planning resource list. The attributes which are defaulted need to be
*  passed in only if there is need to modify them.
* Attributes:
*   p_resource_list_id      : Resource List Identifier.  To be passed
*                             only if you are updating the Resource List.
*                             Get the Value from view PA_RESOURCE_LISTS_V
*   p_resource_list_name    : Resource List Name.
*   p_description           : Descriptoin of the Resource List.
*   p_start_date            : Start Date of the Resource List. Must pass in
*                             during Resource List Creation.
*   p_end_date              : End Date of the Resource List.
*   p_job_group_id          : Job Group Id of the Job attached to the
*                             resource list.  Get the Value from view
*                             PA_JOBS_VIEW
*   p_job_group_name        : Job Group Name of the Job attached to
*                             the resource list. You can either pass
*                             the name or p_job_group_id.
*   p_use_for_wp_flag       : Flag to indicate if the Resource List
*                             will be used for workplan.
*                             'Y' : Resource List will be used for workplan
*                             'N' : Resource List will not be used in workplan
*   p_control_flag          : Flag to indicate whether the resource list is
*                             centrally controlled or Project specific
*                             'Y' : Resource List is centrally controlled.
*                             'N' : Resource List is project specific.
*   p_record_version_number : Record Version Number of the Resource List.
* *********************************************************************************/
TYPE Plan_Res_List_IN_Rec IS RECORD
     (p_resource_list_id       Number         Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_resource_list_name     VARCHAR2(240)  Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_description            VARCHAR2(255)  Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_start_date             DATE           DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
      p_end_date               DATE           DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
      p_job_group_id           NUMBER         DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_job_group_name         VARCHAR2(30)   DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_use_for_wp_flag        VARCHAR2(1)    DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_control_flag           VARCHAR2(1)    DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_record_version_number  NUMBER         DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM);




 /**********************************************************************************
 * Record : Plan_Res_List_OUT_Rec
 * Description :
 *    This is the planning resource list record structure which stores the
 *    resource list identifier of the newly created planning resource list as
 *    an out parameter. This resource list identifier value will be passed while
 *    creating resource formats and resource list members.
 *  Attributes:
 *    X_resource_list_id  : Resource List indentifier of newly created
 *                            planning resource list.
 **********************************************************************************/
 TYPE Plan_Res_List_OUT_Rec IS RECORD(
   X_resource_list_id      NUMBER);




 /************************************************************************************
 * Record : Plan_RL_Format_In_Rec
 * Description :
 *    This is the planning resource list format structure. You need to
 *  pass the planning resource list format record whenever you are
 *  creating a new resource format . Updating resource format allows
 *  either addition or deletion of resource formats.
 * Attributes:
 *  P_Res_Format_Id     : Resource Format Identifier. To be passed
 *                        if you are adding a new resource
 *                        format to the resource list.
 *                        You can get the value from PA_RES_FORMATS_AMG_V.
 *************************************************************************************/

 TYPE Plan_RL_Format_In_Rec IS RECORD(
    P_Res_Format_Id        NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM);





 /************************************************************************************
 * Record : Plan_RL_Format_Out_Rec
 * Description :
 *  This is the planning resource format record structure which stores the
 *  resource list format identifier of the newly created resource list
 *  format as an out parameter.
 * Attributes:
 *  X_Plan_RL_Format_Id      : Planning Resource format identifier of the newly created
 *                             planning resource format.
 *  X_Record_Version_Number  : Record Version Number of the resource format.
 *  x_return_status          : Indicates whether the creation of planning resource
 *                             list was successful or not. It can take any of
 *                             these values.
 *                             'S' : Success
 *                             'U' : Unexpected Error
 *                             'E' : Error
 *************************************************************************************/
 TYPE Plan_RL_Format_Out_Rec IS RECORD(
   X_Plan_RL_Format_Id      NUMBER,
   X_Record_Version_Number  NUMBER);



 /*************************************************************************************
 * Table of records
 * Table : Plan_RL_Format_In_Tbl
 *************************************************************************************/
TYPE Plan_RL_Format_In_Tbl IS TABLE OF Plan_RL_Format_In_Rec
 INDEX BY BINARY_INTEGER;




 /**************************************************************************************
 * Table of records
 * Table : Plan_RL_Format_Out_Tbl
 **************************************************************************************/
TYPE Plan_RL_Format_Out_Tbl IS TABLE OF Plan_RL_Format_Out_Rec
 INDEX BY BINARY_INTEGER;




 /******************************************************************************************************
 * Record Structure Declaration
 * Record : PLANNING_RESOURCE_IN_REC
 * Description :
 *  This is the planning resource list memeber record structure. You need to
 *  pass the resource list member record whenever you are creating a new
 *  planning resource list member, or when you are updating an existing
 *  planning resource list member. The attributes which are defaulted to null need
 *  not be passed in unless they are modified and need to be updated.
 * Attributes :
 *  p_resource_list_member_id     : Optional. Resource list member identifier. To be passed
 *                                  only if you are updating the resource list
 *                                  member of the resource list.
 *  p_resource_alias              : Alias name of the resource.
 *  p_person_id                   : This contains value if the resource is of type NAMED_PERSON.
 *                                  It contains the identifier of the selected resource.
 *  p_person_name                 : This contains value if the resource is of type NAMED_PERSON. It
 *                                  contains the person name.
 *  p_job_id                      : This contains value if the resource is of type JOB. It contains
 *                                  the identifier of the job.
 *  p_job_name                    : This contains value if the resource is of type JOB.
 *                                  It holds the name of the selected resource.
 *  p_organization_id             : This contins value if the resource is of type ORGANIZATION.
 *                                  It holds the identifier of the selected resource.
 *                                  This sets the value for organization_id of pa_resource_list_members
 *                                  table.
 *  p_organization_name           : This contains value if the resource is of type ORGANIZATION.
 *                                  It holds the name of the selected resource.
 *  p_vendor_id                   : This holds the vendor identifier.
 *                                  This sets the value of VENDOR_ID of pa_resource_list_members
 *                                  table.
 *  p_vendor_name                 : This holds the name of the vendor.
 *  p_fin_category_name           : This holds the name of finacial category.
 *  p_non_labor_resource          : This contains value if the resource is of type NON_LABOR_RESOURCE.
 *                                  This holds the name of non labor resource.
 *  p_project_role_id             : This contains value if the resource is of type ROLE.
 *                                  It holds the identifier of the selected resource.
 *  p_project_role_name           : This contains value if the resource is of type ROLE.
 *                                  It holds the name of the selected resource.
 *  p_resource_class_id           : This contains the identifier of the resource class to
 *                                  which the resource belongs to.
 *                                  It can take the following vaues:
 *                                  1,2,3 or 4.
 *  p_resource_class_code         : This contains the code of the resource class to
 *                                  which the resource belongs to.
 *                                  It can take the following values:
 *                                    EQUIPMENT
 *                                    FINANCIAL ELEMENTS,
 *                                    MATERIAL ITEMS or
 *                                    PEOPLE.
 *  p_res_format_id               : It should be passed in during creation of a planning
 *                                  resource list member. This holds the planning resource format id to
 *                                  which the resource belongs to.
 *  p_spread_curve_id             : Optional.This is the planning attribute which defines the way cost or
 *                                  revenue amounts are distributed across periods for financial planning.
 *                                  This holds the identifier of the spread curves available.
 *                                  p_spread_curve_id sets the value for spread_curve_id of
 *                                  pa_resource_list_members table. If p_spread_curve_id is NULL then
 *                                  spread_curve_id is set to its default value
 *                                  decided by the resource class passed in.
 *                                  If p_spread_curve_id is NOT NULL then spread_curve_id is set to
 *                                  whatever is passed.
 *  p_etc_method_code             : Optional.The Users can setup Esitmate to Complete(ETC) Methods by
 *                                  resource.
 *                                  This planning attribute holds the corresponding ETC code.
 *                                  p_etc_method_code sets the value for etc_method_code of
 *                                  pa_resource_list_members table. If p_etc_method_code is NULL then
 *                                  etc_method_code is set to its default value
 *                                  decided by the resource class passed in.
 *                                  If p_etc_method_code is NOT NULL then etc_method_code is set to
 *                                  whatever is passed.
 *  p_mfc_cost_type_id            : Optional. It holds the identifier of manufacturing cost type.
 *                                  Initially it sets the value for mfc_cost_type_id of
 *                                  pa_resource_list_members
 *                                  table with whatever passed in p_mfc_cost_type_id.
 *                                  If p_mfc_cost_type_id is NULL and
 *                                  the resource type is either BOM EQUIPMENT or BOM_LABOR or
 *                                  INVENTORY_ITEM then mfc_cost_type_id is set to its default value
 *                                  decided by the resource class.
 *                                  else mfc_cost_type_id is set to null.
 *  p_fc_res_type_code            : It will decide the value for wp_eligible_flag of
 *                                  pa_resurce_list_members table. Based on this code wp_eligible_flag
 *                                  is set to either 'Y' or 'N'.
 *                                  If p_fc_res_type_code is either 'REVENUE_CATEGORY' or 'EVENT_TYPE'
 *                                  then wp_eligible_flag will hold 'N' else it will hold 'Y'.
 *  p_inventory_item_id           : This contains value if the resource is of type ITEM. It contains
 *                                  the identifier of the the resource.
 *  p_inventory_item_name         : This contains value if the resource is of type ITEM.
 *                                  It holds the name of the selected resource.
 *  p_item_category_id            : This contains value if the resource is of type ITEM CATEGORY.
 *                                  It holds the identifier of the selected resource.
 *  p_item_category_name          : This contains value if the resource is of type ITEM CATEGORY.
 *                                  It holds the name of the selected resource.
 *  p_attribute_category          : Holds the attribute category name.
 *  p_attribute1 to p_attribute30 : These are descriptive flexfields which allow users to define
 *                                  additional information for each planning resource.
 *  p_person_type_code            : This contains value if the resource is of type PERSON_TYPE.
 *                                  This will hold person type code or name.
 *  p_bom_resource_id             : This contains value if the resource is of type BOM_LABOR or
 *                                  BOM_EQUIPMENT.
 *                                  It holds the identifier of the selected resource.
 *  p_bom_resource_name           : This contains value if the resource is of type BOM_LABOR or
 *                                  BOM_EQUIPMENT.
 *                                  It holds the name of the selected resource.
 *  p_team_role                   : This contains value if the resource is of type NAMED_ROLE.
 *                                  It holds the name or code of the team role.
 *  p_incur_by_res_code           : This contains value if the resource belongs to format having
 *                                  Incurred By Resource as planning resource element.
 *                                  It holds the code of the selected resource
 *  p_incur_by_res_type           : This contains value if the resource belongs to format having
 *                                  Incurred By Resource as planning resource element.
 *                                  It holds the type of the selected resource.
 *  p_record_version_number       : Required. It is the record version number of the resource list member.
 *                                  It has significance
 *                                  only during update of resource list member.
 *  p_project_id                  : Required. It holds the project id for project specific resources.
 *                                  It determines the value for object_type and object_id of
 *                                  pa_resource_list_members table.
 *                                  If project_id is not NULL object_type and object_id takes values
 *                                  'PROJECT' and project_id.
 *                                  If project_id is NULL then it takes 'RESOURCE_LIST' and
 *                                  p_resource_list_id as object_type and object_id.
 *  p_enabled_flag                : Optional. This flag indicates whether the resource member is enabled
 *                                  or not. The value need not be passed unless you want to modify its
 *                                  value during update.
 *                                  Enabled_Flag will always be 'Y' during creation of a resource list
 *                                  member.
 *                                  'Y': The resource list member is enabled.
 *                                  'N': The resource list member is disabled.
 *******************************************************************************************************/
TYPE Planning_Resource_In_Rec IS RECORD
(
         p_resource_list_member_id   NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         p_resource_alias            VARCHAR2(80)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_person_id                 NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         --Bug 3593613
         p_person_name               VARCHAR2(240)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_job_id                    NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         --Bug 3593613
         p_job_name                  VARCHAR2(240)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_organization_id           NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         p_organization_name         VARCHAR2(30)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_vendor_id                 NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         --Bug 3593613
         p_vendor_name               VARCHAR2(240)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_fin_category_name         VARCHAR2(30)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_non_labor_resource        VARCHAR2(30)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_project_role_id           NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         --Bug 3593613
         p_project_role_name         VARCHAR2(80)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_resource_class_id         NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         p_resource_class_code       VARCHAR2(30)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_res_format_id             NUMBER        ,
         p_spread_curve_id           NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         p_etc_method_code           VARCHAR2(30)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_mfc_cost_type_id          NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         p_fc_res_type_code          VARCHAR2(30)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_inventory_item_id         NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         --Bug 3593613
         p_inventory_item_name       VARCHAR2(80)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_item_category_id          NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         p_item_category_name        VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute_category        VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute1                VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute2                VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute3                VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute4                VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute5                VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute6                VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute7                VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute8                VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute9                VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute10               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute11               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute12               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute13               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute14               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute15               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute16               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute17               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute18               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute19               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute20               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute21               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute22               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute23               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute24               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute25               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute26               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute27               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute28               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute29               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_attribute30               VARCHAR2(150) DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_person_type_code          VARCHAR2(30)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_bom_resource_id           NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         p_bom_resource_name         VARCHAR2(30)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_team_role                 VARCHAR2(80)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_incur_by_res_code         VARCHAR2(30)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_incur_by_res_type         VARCHAR2(30)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_record_version_number     NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         p_project_id                NUMBER  ,
         p_enabled_flag              Varchar2(1)  DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);


 /*****************************************************************************
 * Record Structure Declaration
 * Record : PLANNING_RESOURCE_OUT_REC
 * Description :
 *  This is the planning resource list member record structure which
 *  stores the resource list member identifier of the newly created
 *  resource list member as an out parameter.
 * Attributes:
 *  x_resource_list_member_id  : Resource list member identifier of
 *                               the newly created resource list member.
 *  x_record_version_number    : Record version number of the resource
 *                               list member.
 *****************************************************************************/
TYPE Planning_Resource_Out_Rec IS RECORD
(  x_resource_list_member_id   NUMBER        DEFAULT NULL,
   x_record_version_number     NUMBER        DEFAULT NULL);




 /***************************************************************************
 * Table of records
 * Table : PLANNING_RESOURCE_IN_TBL
 ***************************************************************************/
TYPE Planning_Resource_In_Tbl IS TABLE OF Planning_Resource_In_Rec
 INDEX BY BINARY_INTEGER;




 /*****************************************************************************
 * Table of records
 * Table : PLANNING_RESOURCE_OUT_TBL
 ****************************************************************************/
TYPE Planning_Resource_Out_Tbl IS TABLE OF Planning_Resource_Out_Rec
 INDEX BY BINARY_INTEGER;




--DECLARE Global Recs and Tables

--If the event data is input in scalar form these will put into these
--global PL/SQL tables before resource list,formats and members can be
--created or updated.
G_Plan_Res_List_IN_Rec           Plan_Res_List_IN_Rec;
G_Plan_Res_List_Out_Rec          Plan_Res_List_Out_Rec;
--Declare a global rec struc similar to Plan_Res_List_IN_Rec
-- and Plan_Res_List_Out_Rec which will be empty and which
--Can be assigned to G_Plan_Res_List_IN_Rec, G_Plan_Res_List_Out_Rec
--while initializing.
G_Res_List_empty_rec             Plan_Res_List_IN_Rec;
G_Res_List_empty_out_rec         Plan_Res_List_Out_Rec;
--Declare global pl/sql tables for the formats.
G_Plan_RL_format_In_Tbl          Plan_RL_Format_In_Tbl;
G_Plan_RL_format_Out_Tbl         Plan_RL_Format_Out_Tbl;
--Declare global pl/sql tables for the Resources.
G_Planning_resource_in_tbl       Planning_Resource_In_Tbl;
G_Planning_resource_out_tbl      Planning_Resource_out_Tbl;
--Initialize global var to store table count.
G_Plan_RL_Format_tbl_count       NUMBER := 0;
G_Plan_Resource_tbl_count        NUMBER := 0;

 /************************************************************************************
 * API Name          : Create_Resource_List
 * Public/Private    : Public
 * Procedure/Function: Procedure
 * Description       : AMG API, used to create a resource list
 *                     and its corresponding members and formats.
 *                      - First it would create a Resource List.
 *                        If Creation of the resource list is not
 *                        successful then rollback all the changes and return.
 *                      - If the resource list is created successfully then
 *                        go ahead and create resource formats if they are passed in as
 *                        parameters to the API. If any format cannot be added to the
 *                        resource list, the API will error out.
 *                      - If the formats are added successfully, it will then process
 *                        the planning resources. If creation of any planning resource
 *                        errors out, the API will error out.
 * IN Parameters    :
 *  p_commit                    - Optional. By default no commit will take place.
 *  p_init_msg_list             - Optional. By default the error msg stack
 *                                is not initialized.
 *  p_api_version_number        - Required. The api version number.
 *  P_plan_res_list_Rec         - Required. The record structure which holds the details
 *                                of the resource list to be created. See the package
 *                                specification for record structure details.
 *                                Following parameters must be passed in the record structure:
 *                                resource_list_name
 *                                start_date
 *                                Optionally pass the following parameters :
 *                                description, end_date, job_group_id,
 *                                job_group_name, use_for_wp_flag and control_flag
 *  P_Plan_RL_Format_Tbl        - Required. This holds the values for resource formats.
 *                                See the package specification record structure for details.
 *  P_Planning_resource_out_tbl - Required. This holds the planning resource list members.
 *                                See the package specification for
 *                                record structure details.
 * OUT Parameters   :
 *  X_plan_res_list_Rec         - This will hold the resource list identifier values
 *                                populated when new resource list are succesfully created.
 *  X_Plan_RL_Format_Tbl        - This will hold the resource format identifier values
 *                                populated when new resource formats are successfully created.
 *  X_planning_resource_out_tbl - This will hold the resource list member idenfier
 *                                populated when new resource list members are
 *                                succesfully created.
 *  X_Return_Status             - Will return a value of 'S' when the API is
 *                                successful in creating the Resource list along with
 *                                the corresponding resource formats and members.
 *                                Will return a value of 'E' when the API fails
 *                                due to a validation error or when any of the API's
 *                                called from within fails.
 *                                Will return a value of 'U' when the API hits
 *                                and unexpected error(Some ORA or such error).
 *  X_Msg_Count                 - Depending on the P_Init_Msg_List parameter value
 *                                this paramenter may have a value of 1 or higher.
 *  X_Msg_Data                  - The parameter will hold a message if there is an
 *                                error in this API.
 *
 *************************************************************************************************/
/*#
 * This API is used to create resource lists, corresponding resource formats and resource list members.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_plan_res_list_rec Record structure that holds the details of the resource list to be created
 * @rep:paraminfo {@rep:required}
 * @param x_plan_res_list_rec Resource list identifier values
 * @rep:paraminfo {@rep:required}
 * @param p_plan_rl_format_tbl Record structure that holds resource formats
 * @rep:paraminfo {@rep:required}
 * @param x_plan_rl_format_tbl Resource format identifier values
 * @rep:paraminfo {@rep:required}
 * @param p_planning_resource_in_tbl Table of planning resources
 * @rep:paraminfo {@rep:required}
 * @param x_planning_resource_out_tbl Table of resource list member identifier
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Project Planning Resource List
 * @rep:compatibility S
*/
PROCEDURE Create_Resource_List
     (p_commit                    IN           VARCHAR2 := FND_API.G_FALSE,
      p_init_msg_list             IN           VARCHAR2 := FND_API.G_FALSE,
      p_api_version_number        IN           NUMBER,
      P_plan_res_list_Rec         IN           Plan_Res_List_IN_Rec,
      X_plan_res_list_Rec         OUT NOCOPY   Plan_Res_List_OUT_Rec,
      P_Plan_RL_Format_Tbl        IN           Plan_RL_Format_In_Tbl,
      X_Plan_RL_Format_Tbl        OUT NOCOPY   Plan_RL_Format_Out_Tbl,
      P_planning_resource_in_tbl  IN           Planning_Resource_In_Tbl,
      X_planning_resource_out_tbl OUT NOCOPY   Planning_Resource_Out_Tbl,
      X_Return_Status             OUT NOCOPY   VARCHAR2,
      X_Msg_Count                 OUT NOCOPY   NUMBER,
      X_Msg_Data                  OUT NOCOPY   VARCHAR2);






 /*****************************************************************************************
 * API Name          : Update_Resource_List
 * Public/Private    : Public
 * Procedure/Function: Procedure
 * Description : AMG API, used to update a resource list
 *               and its corr members and formats.
 *               - It will first update the resource list by call
 *                 to pa_create_Resource.Update_resource_List API.
 *               - Then it would Create the resource format which is passed
 *                 in as a table.Updation of a resource format is not possible.
 *                 Deletions happens through a seperate API.
 *               - Next the API will create/Update the resource members
 *                 based on the table of resource members passed.
 *               - If the resource list member already exists in the
 *                 pa_resource_list_members table then the API will update the
 *                 record with the newly passed in values.
 *               - If the resource list member does not exist then t he API
 *                 will create the records.
 * IN Parameters    :
 *  p_commit                    - Optional. By default no commit will take place.
 *  p_init_msg_list             - Optional. By default the error msg stack
 *                                is not initialized.
 *  p_api_version_number        - Required. The api version number.
 *  P_plan_res_list_Rec         - Required. See the package specification for
 *                                record structure details.
 *  P_Plan_RL_Format_Tbl        - Required. This holds the values for resource formats.
 *                                See the package specification record structure for details.
 *  P_Planning_resource_in_tbl  - Required. This holds the planning resource list members.
 *                                See the package specification for
 *                                record structure details.
 * OUT Parameters   :
 *  X_plan_res_list_Rec         - This will hold the resource list identifier values
 *                                populated when a new resource list is succesfully created.
 *                                No value will be populated in this record during updation
 *                                of already
 *                                existing resource list.
 *  X_Plan_RL_Format_Tbl        - This will hold the resource format identifier values
 *                                populated when a new resource format is successfully created.
 *                                No value will be populated in this record during deleting
 *                                of already existing resource format.
 *  X_planning_resource_out_tbl - This will hold the resource list member idenfier
 *                                populated when a new resource list member is
 *                                succesfully created.
 *                                No value will be populated in this record during updation
 *                                of already
 *                                existing resource list member.
 *  X_Return_Status             - Will return a value of 'S' when the API is
 *                                successful in updating the resource list.
 *                                Will return a value of 'E' when the API fails
 *                                due to a validation error.
 *                                Will return a value of 'U' when the API hits
 *                                and unexpected error(Some ORA or such error).
 *  X_Msg_Count                 - Depending on the P_Init_Msg_List parameter value
 *                                this paramenter may have a value of 1 or higher.
 *  X_Msg_Data                  - The parameter will hold a message if there is an
 *                                error in this API.
 ***********************************************************************************************/
/*#
 * This API is used to update a resource list, corresponding resource formats and planning resources.
 * Updation of a resource format is not possible.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_plan_res_list_rec Record structure for resource list containing attributes to be updated
 * @rep:paraminfo {@rep:required}
 * @param x_plan_res_list_rec Resource list identifier values
 * @rep:paraminfo {@rep:required}
 * @param p_plan_rl_format_tbl Table of resource formats to be added to the resource list
 * @rep:paraminfo {@rep:required}
 * @param x_plan_rl_format_tbl Resource format identifier values
 * @rep:paraminfo {@rep:required}
 * @param p_planning_resource_in_tbl Table of planning resources
 * @rep:paraminfo {@rep:required}
 * @param x_planning_resource_out_tbl Table of resource list member identifier
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Project Planning Resource List
 * @rep:compatibility S
*/
PROCEDURE Update_Resource_List
     (p_commit                     IN              VARCHAR2 := FND_API.G_FALSE,
      p_init_msg_list              IN              VARCHAR2 := FND_API.G_FALSE,
      p_api_version_number         IN              NUMBER,
      P_plan_res_list_Rec          IN              Plan_Res_List_IN_Rec,
      X_plan_res_list_Rec          OUT    NOCOPY   Plan_Res_List_OUT_Rec,
      P_Plan_RL_Format_Tbl         IN              Plan_RL_Format_In_Tbl,
      X_Plan_RL_Format_Tbl         OUT    NOCOPY   Plan_RL_Format_Out_Tbl,
      P_planning_resource_in_tbl   IN              Planning_Resource_In_Tbl,
      X_planning_resource_out_tbl  OUT    NOCOPY   Planning_Resource_Out_Tbl,
      X_Return_Status              OUT    NOCOPY   VARCHAR2,
      X_Msg_Count                  OUT    NOCOPY   NUMBER,
      X_Msg_Data                   OUT    NOCOPY   VARCHAR2);




 /*********************************************************************************
 * Procedure : Delete_Resource_List
 * Public/Private    : Public
 * Procedure/Function: Procedure
 * Description : AMG API, used to Delete a planning resource list
 *               and its corresponding resource formats and planning resources.
 *
 * IN Parameters    :
 *  p_commit                    - Optional. By default no commit will take place.
 *  p_init_msg_list             - Optional. By default the error msg stack
 *                                is not initialized.
 *  p_api_version_number        - Required. The api version number.
 *  P_Res_List_Id               - Required. The resource list identifier. You
 *                                can get the value from view
 *                                PA_RESOURCE_LISTS_V.
 *
 * OUT Parameters   :
 *  X_Return_Status             - Will return a value of 'S' when the API is
 *                                successful in deleting the resource list.
 *                                Will return a value of 'E' when the API fails
 *                                due to a validation error.
 *                                Will return a value of 'U' when the API hits
 *                                and unexpected error(Some ORA or such error).
 *  X_Msg_Count                 - Depending on the P_Init_Msg_List parameter value
 *                                this paramenter may have a value of 1 or higher.
 *  X_Msg_Data                  - The parameter will hold a message if there is an
 *                                error in this API.
 *********************************************************************************/
/*#
 * This API is used to delete a planning resource list and its corresponding resource formats and planning resources.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_res_list_id Resource list identifier
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Project Planning Resource List
 * @rep:compatibility S
*/
PROCEDURE Delete_Resource_List(
       p_commit                     IN           VARCHAR2 := FND_API.G_FALSE,
       p_init_msg_list              IN           VARCHAR2 := FND_API.G_FALSE,
       p_api_version_number         IN           NUMBER,
       P_Res_List_Id                IN           NUMBER   ,
       X_Return_Status              OUT NOCOPY   VARCHAR2,
       X_Msg_Count                  OUT NOCOPY   NUMBER,
       X_Msg_Data                   OUT NOCOPY   VARCHAR2);



 /*******************************************************************************************
 * Procedure   : Delete_Plan_RL_Format
 * Public/Private    : Public
 * Procedure/Function: Procedure
 * Description : Call this API to delete any planning resource format
 *               from the resource list.
 * IN Parameters    :
 *  p_commit                    - Optional. By default no commit will take place.
 *  p_init_msg_list             - Optional. By default the error msg stack
 *                                is not initialized.
 *  P_Res_List_Id               - Required. The resource list identifier.
 *  P_Plan_RL_Format_Tbl        - Required. This holds the values for resource formats.
 *                                See the package specification record structure for details.
 *
 * OUT Parameters   :
 *  X_Return_Status             - Will return a value of 'S' when the API is
 *                                successful in deleting the resource format.
 *                                Will return a value of 'E' when the API fails
 *                                due to a validation error.
 *                                Will return a value of 'U' when the API hits
 *                                and unexpected error(Some ORA or such error).
 *  X_Msg_Count                 - Depending on the P_Init_Msg_List parameter value
 *                                this paramenter may have a value of 1 or higher.
 *  X_Msg_Data                  - The parameter will hold a message if there is an
 *                                error in this API.
 *********************************************************************************************/
/*#
 * This API is used to delete one or more resource formats from a resource list.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_res_list_id Resource list identifier
 * @rep:paraminfo {@rep:required}
 * @param P_Plan_RL_Format_Tbl Table of resource format identifiers to delete from the resource list
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Project Planning Resource List Formats
 * @rep:compatibility S
*/
Procedure Delete_Plan_RL_Format (
        p_commit                 IN          VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_init_msg_list          IN          VARCHAR2 DEFAULT FND_API.G_FALSE,
        P_Res_List_Id            IN          NUMBER   DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Plan_RL_Format_Tbl     IN          Plan_RL_Format_In_Tbl,
        X_Return_Status          OUT NOCOPY  VARCHAR2,
        X_Msg_Count              OUT NOCOPY  NUMBER,
        X_Msg_Data               OUT NOCOPY  VARCHAR2);






 /*********************************************************************************
 * Procedure   : Init_Create_Resource_List
 * Description : This procedure initializes the global
 *               temporary tables for the resource formats,
 *               resoure list members.
 *               Also initializes the record structure
 *               for Resource list.
 **********************************************************************************/
/*#
 * This API procedure is used to initialize the global tables for project planning resource formats and
 * resource list members prior to Load-Execute-Fetch cycle.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Initialize Create Project Planning Resource List
 * @rep:compatibility S
*/
PROCEDURE Init_Create_Resource_List ;





 /***********************************************************************************
 * Procedure   : Init_Update_Resource_List
 * Description : This procedure initializes the global
 *               temporary tables for the resource formats,
 *               resoure list members.
 *               Also initializes the record structure
 *               for Resource list.
 ***********************************************************************************/
/*#
 * This API procedure is used to initialize the global tables for project planning resource formats and
 * resource list members prior to Load-Execute-Fetch cycle.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Initialize Update Project Planning Resource List
 * @rep:compatibility S
*/
PROCEDURE Init_Update_Resource_List ;



 /**********************************************************************************
 * API Name           : Load_Resource_List
 * Public/Private     : Public
 * Procedure/Function : Procedure
 * Description        : This procedure loads the resource
 *                      list globals.
 *                      If you want to call the Exectue API
 *                      (Execute_Create_Planning_Resource_List or Execute_Create_Planning_Resource_List),
 *                      you should load first load the resource list through
 *                      this API.
 *                      If creating a new resource list following parameters
 *                      must be passed:
 *
 *                          p_resource_list_name
 *                          p_start_date
 *
 *                      During creation, you can optionally pass the following
 *                      parameters:
 *
 *                          p_description
 *                          p_end_date
 *                          p_job_group_id
 *                          p_job_group_name
 *                          p_use_for_wp_flag
 *                          p_control_flag
 *
 *                      During Update, you can update any of the following
 *                      parameters:
 *
 *                          p_resource_list_name
 *                          p_start_date
 *                          p_description
 *                          p_end_date
 *                          p_job_group_id
 *                          p_job_group_name
 *                          p_use_for_wp_flag
 *                          p_control_flag
 *
 *                      To identify which resource list needs to be updated,
 *                      you should  pass the following parameter:
 *
 *                      p_resource_list_id: You can get the this identifier
 *                                          from view PA_RESOURCE_LISTS_V
 *
 * IN Paramters :
 *  p_api_version_number      - The api version number.
 *  P_Resource_List_Id        - The resource list identifier.
 *  p_resource_list_name      - The name of the resource list.
 *  p_description             - The description of the resource list.
 *  p_start_date              - The start date of the resource list.
 *                              If nothing is specified the resource list will
 *                              be defaulted with sysdate as the start date.
 *  p_end_date                - The end date of the resource list
 *  p_job_group_id            - The Job group Id of the job attached
 *                              to the resource list. Get the value from view
 *                              PA_JOBS_VIEW.
 *  p_job_group_name          - Job Group Name of the Job attached
 *                              to the resource list. You can either pass
 *                              the name or the job id.
 *  p_use_for_wp_flag         - Flag which indicates whether the
 *                              resource list will be used in workplan or not.
 *                                'Y' : Resource list will be used in workplan.
 *                                'N' : Resource list will not be used in workplan.
 *  p_control_flag            - Flag which indicates whether the
 *                              resource list is centrally controlled or project
 *                              specific.
 *                                'Y': Indicates resource list as centrally controlled.
 *                                'N': Resource List is project specific.
 *  p_record_version_number   - Record version number of the resource list.
 *
 * OUT Parameters   :
 *  X_Return_Status           - Will return a value of 'S' when the API is
 *                              successful in creating the loading the resource list.
 *                              Will return a value of 'E' when the API fails
 *                              due to a validation error.
 *                              Will return a value of 'U' when the API hits
 *                              and unexpected error(Some ORA or such error).
 *
 **************************************************************************************/
/*#
 * This API is used to load resource list to a global PL/SQL table.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_resource_list_id Resource list identifier
 * @param p_resource_list_name Resource list name
 * @rep:paraminfo {@rep:required}
 * @param p_description Resource list description
 * @rep:paraminfo {@rep:required}
 * @param p_start_date Resource list start date
 * @param p_end_date Resource list end date
 * @param p_job_group_id Job group identifier to be used for the resource list
 * @rep:paraminfo {@rep:required}
 * @param p_job_group_name Job group name to be used for the resource list
 * @param p_use_for_wp_flag Flag indicating whether if the resource list will be used for a workplan
 * @param p_control_flag Flag indicating whether the resource list is centrally controlled or project specific
 * @param p_record_version_number Record version number
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Project Planning Resource List
 * @rep:compatibility S
*/
PROCEDURE Load_Resource_List
        (p_api_version_number    IN     NUMBER,
         p_resource_list_id      IN     NUMBER       DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         p_resource_list_name    IN     VARCHAR2,
         p_description           IN     VARCHAR2,
         p_start_date            IN     DATE         DEFAULT SYSDATE,
         p_end_date              IN     DATE         DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
         p_job_group_id          IN     NUMBER,
         p_job_group_name        IN     VARCHAR2     DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_use_for_wp_flag       IN     VARCHAR2     DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_control_flag          IN     VARCHAR2     DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_record_version_number IN     NUMBER       DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         x_return_status         OUT NOCOPY   VARCHAR2);



 /*****************************************************************************
 * API Name           : Load_Resource_Format
 * Public/Private     : Public
 * Procedure/Function : Procedure
 * Description        : This procedure loads the resource format globals.
 *                      The values loaded through this API will be used during
 *                      Execute_Create_Planning_Resource_List or
 *                      Execute_Create_Planning_Resource_List, whichever is
 *                      called.
 * IN Paramters :
 *  p_api_version_number        - The api version number.
 *  P_Res_Format_Id             - This is the identifier of the resource format
 *                                you want to add to the Planning Resource List.
 *                                You can get the value from PA_RES_FORMATS_AMG_V
 *
 * OUT Parameters   :
 *  X_Return_Status             - Will return a value of 'S' when the API is
 *                                successful in loading the resource format.
 *                                Will return a value of 'E' when the API fails
 *                                due to a validation error.
 *                                Will return a value of 'U' when the API hits
 *                                and unexpected error(Some ORA or such error).
 *
 *****************************************************************************/
/*#
 * This API is used to load resource formats to a global PL/SQL table.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_res_format_id Resource format identifier
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Project Planning Resource Format
 * @rep:compatibility S
*/
PROCEDURE Load_Resource_Format
        (p_api_version_number    IN            NUMBER,
         P_Res_Format_Id         IN            NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         x_return_status         OUT NOCOPY    VARCHAR2);




 /*****************************************************************************
 * API Name           : Load_Planning_Resource
 * Public/Private     : Public
 * Procedure/Function : Procedure
 * Description        : This procedure loads the resource
 *                      list members.
 *                      It is required to be executed when u want
 *                      create a new resource list member.
 *                      If used for creating a resource list member then
 *                      the following prameters must be populated
 *                      when used: p_api_version_number,
 * IN Paramters :
 *  p_api_version_number          : Required. The api version number.
 *  p_resource_list_member_id     : Optional. Resource list member identifier. To be passed
 *                                  only if you are updating the resource list
 *                                  member of the resource list.
 *  p_resource_alias              : Alias name of the resource.
 *  p_person_id                   : This contains value if the resource is of type NAMED_PERSON.
 *                                  It contains the identifier of the selected resource.
 *  p_person_name                 : This contains value if the resource is of type NAMED_PERSON. It
 *                                  contains the person name.
 *  p_job_id                      : This contains value if the resource is of type JOB. It contains
 *                                  the identifier of the job.
 *  p_job_name                    : This contains value if the resource is of type JOB.
 *                                  It holds the name of the selected resource.
 *  p_organization_id             : This contains value if the resource is of type ORGANIZATION.
 *                                  It holds the identifier of the selected resource.
 *                                  This sets the value for organization_id of pa_resource_list_members
 *                                  table.
 *  p_organization_name           : This contains value if the resource is of type ORGANIZATION.
 *                                  It holds the name of the selected resource.
 *  p_vendor_id                   : This holds the vendor identifier.
 *                                  This sets the value of VENDOR_ID of pa_resource_list_members
 *                                  table.
 *  p_vendor_name                 : This holds the name of the vendor.
 *  p_fin_category_name           : This holds the name of finacial category.
 *  p_non_labor_resource          : This contains value if the resource is of type NON_LABOR_RESOURCE.
 *                                  This holds the name of non labor resource.
 *  p_project_role_id             : This contains value if the resource is of type ROLE.
 *                                  It holds the identifier of the selected resource.
 *  p_project_role_name           : This contains value if the resource is of type ROLE.
 *                                  It holds the name of the selected resource.
 *  p_resource_class_id           : This contains the identifier of the resource class to
 *                                  which the resource belongs to.
 *                                  It can take the following vaues:
 *                                  1,2,3 or 4.
 *  p_resource_class_code         : This contains the code of the resource class to
 *                                  which the resource belongs to.
 *                                  It can take the following values:
 *                                  EQUIPMENT
 *                                  FINANCIAL ELEMENTS,
 *                                  MATERIAL ITEMS or
 *                                  PEOPLE.
 *  p_res_format_id                : Optional. It should be passed in during creation of a planning
 *                                  resource list member. This holds the planning resource format id to
 *                                  which the resource belongs to.
 *  p_spread_curve_id              : Optional.This is the planning attribute which defines the way cost or
 *                                  revenue amounts are distributed across periods for financial planning.
 *                                  This holds the identifier of the spread curves available.
 *                                  p_spread_curve_id sets the value for spread_curve_id of
 *                                  pa_resource_list_members table. If p_spread_curve_id is NULL then
 *                                  spread_curve_id is set to its default value
 *                                  decided by the resource class passed in.
 *                                  If p_spread_curve_id is NOT NULL then spread_curve_id is set to
 *                                  whatever is passed.
 *  p_etc_method_code              : Optional.The Users can setup Esitmate to Complete(ETC) Methods by
 *                                  resource.
 *                                  This planning attribute holds the corresponding ETC code.
 *                                  p_etc_method_code sets the value for etc_method_code of
 *                                  pa_resource_list_members table. If p_etc_method_code is NULL then
 *                                  etc_method_code is set to its default value
 *                                  decided by the resource class passed in.
 *                                  If p_etc_method_code is NOT NULL then etc_method_code is set to
 *                                  whatever is passed.
 *  p_mfc_cost_type_id            : Optional. It holds the identifier of manufacturing cost type.
 *                                  Initially it sets the value for mfc_cost_type_id of
 *                                  pa_resource_list_members
 *                                  table with whatever passed in p_mfc_cost_type_id.
 *                                  If p_mfc_cost_type_id is NULL and
 *                                  the resource type is either BOM EQUIPMENT or BOM_LABOR or
 *                                  INVENTORY_ITEM then mfc_cost_type_id is set to its default value
 *                                  decided by the resource class.
 *                                  else mfc_cost_type_id is set to null.
 *  p_fc_res_type_code            : It will decide the value for wp_eligible_flag of
 *                                  pa_resurce_list_members table. Based on this code wp_eligible_flag
 *                                  is set to either 'Y' or 'N'.
 *                                  If p_fc_res_type_code is either 'REVENUE_CATEGORY' or 'EVENT_TYPE'
 *                                  then wp_eligible_flag will hold 'N' else it will hold 'Y'.
 *  p_inventory_item_id           : This contains value if the resource is of type ITEM. It contains
 *                                  the identifier of the the resource.
 *  p_inventory_item_name         : This contains value if the resource is of type ITEM.
 *                                  It holds the name of the selected resource.
 *  p_item_category_id            : This contains value if the resource is of type ITEM CATEGORY.
 *                                  It holds the identifier of the selected resource.
 *  p_item_category_name          : This contains value if the resource is of type ITEM CATEGORY.
 *                                  It holds the name of the selected resource.
 *  p_attribute_category          : Holds the attribute category name.
 *  p_attribute1 to p_attribute30 : These are descriptive flexfields which allow users to define
 *                                  additional information for each planning resource.
 *  p_person_type_code            : This contains value if the resource is of type PERSON_TYPE.
 *                                  This will hold person type code or name.
 *  p_bom_resource_id             : This contains value if the resource is of type BOM_LABOR or
 *                                  BOM_EQUIPMENT.
 *                                  It holds the identifier of the selected resource.
 *  p_bom_resource_name           : This contains value if the resource is of type BOM_LABOR or
 *                                  BOM_EQUIPMENT.
 *                                  It holds the name of the selected resource.
 *  p_team_role                   : This contains value if the resource is of type NAMED_ROLE.
 *                                  It holds the name or code of the team role.
 *  p_incur_by_res_code           : This contains value if the resource belongs to format having
 *                                  Incurred By Resource as planning resource element.
 *                                  It holds the code of the selected resource
 *  p_incur_by_res_type           : This contains value if the resource belongs to format having
 *                                  Incurred By Resource as planning resource element.
 *                                  It holds the type of the selected resource.
 *  p_record_version_number       : Required. It is the record version number of the resource list member.
 *                                  It has significance
 *                                  only during update of resource list member.
 *  p_project_id                  : Required. It holds the project id for project specific resources.
 *                                  It determines the value for object_type and object_id of
 *                                  pa_resource_list_members table.
 *                                  If project_id is not NULL object_type and object_id takes values
 *                                  'PROJECT' and project_id.
 *                                  If project_id is NULL then it takes 'RESOURCE_LIST' and
 *                                  p_resource_list_id as object_type and object_id.
 *  p_enabled_flag                 : Optional. This flag indicates whether the resource member is enabled
 *                                  or not. The value need not be passed unless you want to modify its
 *                                  value during update.
 *                                  Enabled_Flag will always be 'Y' during creation of a resource list
 *                                  member.
 *                                  'Y': The resource list member is enabled.
 *                                  'N': The resource list member is disabled.
 *
 * OUT Parameters   :
 *  X_Return_Status             - Will return a value of 'S' when the API is
 *                                successful in creating the Resource List Members.
 *                                Will return a value of 'E' when the API fails
 *                                due to a validation error.
 *                                Will return a value of 'U' when the API hits
 *                                and unexpected error(Some ORA or such error).
 *
 *****************************************************************************/
/*#
 * This API is used to load project planning resource to a global PL/SQL table.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_resource_list_member_id Resource format identifier
 * @param p_resource_alias Planning resource alias
 * @param p_person_id Identifier of the selected resource if the planning resource is of type NAMED_PERSON
 * @param p_person_name Person name if the planning resource is of type NAMED_PERSON
 * @param p_job_id Job identifier if the planning resource is of type JOB
 * @param p_job_name Job name if the planning resource is of type JOB
 * @param p_organization_id Organization identifier if the planning resource contains an organization
 * @param p_organization_name Organization name if the planning resource contains an organization
 * @param p_vendor_id Supplier identifier if the planning resource contains a supplier
 * @param p_vendor_name Supplier name if the planning resource contains a supplier
 * @param p_fin_category_name Financial category name if the planning resource contains a financial category
 * @param p_non_labor_resource Nob-labor resource if the planning resource contains a non-labor resource
 * @param p_project_role_id Project role identifier if the planning resource contains a team role
 * @param p_project_role_name Project role name if the planning resource contains a team role
 * @param p_resource_class_id Resource class
 * @param p_resource_class_code Resource class code
 * @param p_res_format_id Resource format identifier
 * @rep:paraminfo {@rep:required}
 * @param p_spread_curve_id Spread curve identifier which defines the way cost or revenue amounts are distributed
 * across periods for financial planning
 * @param p_etc_method_code Estimate to complete method code
 * @param p_mfc_cost_type_id Manufacturing cost type identifier
 * @param p_fc_res_type_code Financial category resource type code
 * @param p_inventory_item_id Inventory item identifier if the planning resource contains an item
 * @param p_inventory_item_name Inventory item name if the planning resource contains an item
 * @param p_item_category_id Item category identifier if the planning resource contains an item category
 * @param p_item_category_name Item category name if the planning resource contains an item category
 * @param p_attribute_category Descriptive flexfield category
 * @param p_attribute1 Descriptive flexfield attribute
 * @param p_attribute2 Descriptive flexfield attribute
 * @param p_attribute3 Descriptive flexfield attribute
 * @param p_attribute4 Descriptive flexfield attribute
 * @param p_attribute5 Descriptive flexfield attribute
 * @param p_attribute6 Descriptive flexfield attribute
 * @param p_attribute7 Descriptive flexfield attribute
 * @param p_attribute8 Descriptive flexfield attribute
 * @param p_attribute9 Descriptive flexfield attribute
 * @param p_attribute10 Descriptive flexfield attribute
 * @param p_attribute11 Descriptive flexfield attribute
 * @param p_attribute12 Descriptive flexfield attribute
 * @param p_attribute13 Descriptive flexfield attribute
 * @param p_attribute14 Descriptive flexfield attribute
 * @param p_attribute15 Descriptive flexfield attribute
 * @param p_attribute16 Descriptive flexfield attribute
 * @param p_attribute17 Descriptive flexfield attribute
 * @param p_attribute18 Descriptive flexfield attribute
 * @param p_attribute19 Descriptive flexfield attribute
 * @param p_attribute20 Descriptive flexfield attribute
 * @param p_attribute21 Descriptive flexfield attribute
 * @param p_attribute22 Descriptive flexfield attribute
 * @param p_attribute23 Descriptive flexfield attribute
 * @param p_attribute24 Descriptive flexfield attribute
 * @param p_attribute25 Descriptive flexfield attribute
 * @param p_attribute26 Descriptive flexfield attribute
 * @param p_attribute27 Descriptive flexfield attribute
 * @param p_attribute28 Descriptive flexfield attribute
 * @param p_attribute29 Descriptive flexfield attribute
 * @param p_attribute30 Descriptive flexfield attribute
 * @param p_person_type_code Person type code if the planning resource contains a person type
 * @param p_bom_resource_id BOM resource identifier if the planning resource contains a BOM resource
 * @param p_bom_resource_name BOM resource name if the planning resource contains a BOM resource
 * @param p_team_role Team role name if the planning resource contains a team role
 * @param p_incur_by_res_code Incurred by resource type code if the planning resource contains a incurred by resource
 * @param p_incur_by_res_type Incurred by resource type if the planning resource contains a incurred by resource
 * @param p_record_version_number Record version number
 * @rep:paraminfo {@rep:required}
 * @param p_project_id Project identifier
 * @rep:paraminfo {@rep:required}
 * @param p_enabled_flag Flag indicating whether the planning resource is enabled
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Project Planning Resource
 * @rep:compatibility S
*/
PROCEDURE Load_Planning_Resource
     (p_api_version_number      IN          NUMBER,
      p_resource_list_member_id IN          NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_resource_alias          IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_person_id               IN          NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_person_name             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_job_id                  IN          NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_job_name                IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_organization_id         IN          NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_organization_name       IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_vendor_id               IN          NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_vendor_name             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_fin_category_name       IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_non_labor_resource      IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_project_role_id         IN          NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_project_role_name       IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_resource_class_id       IN          NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_resource_class_code     IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_res_format_id           IN          NUMBER        ,
      p_spread_curve_id         IN          NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_etc_method_code         IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_mfc_cost_type_id        IN          NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_fc_res_type_code        IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_inventory_item_id       IN          NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_inventory_item_name     IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_item_category_id        IN          NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_item_category_name      IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute_category      IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute1              IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute2              IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute3              IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute4              IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute5              IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute6              IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute7              IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute8              IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute9              IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute10             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute11             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute12             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute13             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute14             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute15             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute16             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute17             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute18             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute19             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute20             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute21             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute22             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute23             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute24             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute25             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute26             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute27             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute28             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute29             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute30             IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_person_type_code        IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_bom_resource_id         IN          NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_bom_resource_name       IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_team_role               IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_incur_by_res_code       IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_incur_by_res_type       IN          VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_record_version_number   IN          NUMBER,
      p_project_id              IN          NUMBER  ,
      p_enabled_flag            IN          Varchar2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      x_return_status           OUT NOCOPY  Varchar2);





 /*******************************************************************************
 * Procedure   : Exec_Create_Resource_List
 * Description : This procedure calls the Create_Resource_List API.
 *               It picks up the values loaded by the following before calling
 *               the Create_Resource_List API:
 *                  Load_Resource_List
 *                  Load_Resource_Format
 *                  Load_Planning_Resource
 * IN Parameters    :
 *  p_commit                    - Optional. By default no commit will take place.
 *  p_init_msg_list             - Optional. By default the error msg stack
 *                                is not initialized.
 *  p_api_version_number        - Required. The api version number.
 *
 * OUT Parameters   :
 *  X_Return_Status             - Will return a value of 'S' when the API is
 *                                successful in creating the resource List.
 *                                Will return a value of 'E' when the API fails
 *                                due to a validation error.
 *                                Will return a value of 'U' when the API hits
 *                                and unexpected error(Some ORA or such error).
 *  X_Msg_Count                 - Depending on the P_Init_Msg_List parameter value
 *                                this paramenter may have a value of 1 or higher.
 *  X_Msg_Data                  - The parameter will hold a message if there is an
 *                                error in this API.
 *******************************************************************************/
/*#
 * This API is used to create resource lists, corresponding resource formats and resource list members using
 * the data stored in the global tables.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Execute Create Project Planning Resource List
 * @rep:compatibility S
*/
PROCEDURE Exec_Create_Resource_List
    (p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
    p_init_msg_list         IN         VARCHAR2 := FND_API.G_FALSE,
    p_api_version_number    IN         NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2 );




 /*******************************************************************************
 * Procedure   : Exec_Update_Resource_List
 * Description : This procedure calls Update_Resource_List API.
 *               It picks up the values loaded by the following before calling
 *               the Update_Resource_List API:
 *                  Load_Resource_List
 *                  Load_Resource_Format
 *                  Load_Planning_Resource
 * IN Parameters    :
 *  p_commit                    - Optional. By default no commit will take place.
 *  p_init_msg_list             - Optional. By default the error msg stack
 *                                is not initialized.
 *  p_api_version_number        - Required. The api version number.
 *
 * OUT Parameters   :
 *  X_Return_Status             - Will return a value of 'S' when the API is
 *                                successful in updating the Resource List.
 *                                Will return a value of 'E' when the API fails
 *                                due to a validation error.
 *                                Will return a value of 'U' when the API hits
 *                                and unexpected error(Some ORA or such error).
 *  X_Msg_Count                 - Depending on the P_Init_Msg_List parameter value
 *                                this paramenter may have a value of 1 or higher.
 *  X_Msg_Data                  - The parameter will hold a message if there is an
 *                                error in this API.
 ********************************************************************************/
/*#
 * This API is used to update a resource list, corresponding resource formats and planning resources using
 * the data stored in the global tables.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Execute Update Project Planning Resource List
 * @rep:compatibility S
*/
PROCEDURE Exec_Update_Resource_List
    (p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
     p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
     p_api_version_number   IN         NUMBER,
     x_return_status        OUT NOCOPY VARCHAR2,
     x_msg_count            OUT NOCOPY NUMBER,
     x_msg_data             OUT NOCOPY VARCHAR2
 );




 /*********************************************************************************
 * API Name          : Fetch_Resource_List
 * Public/Private    : Public
 * Procedure/Function: Procedure
 * Description : This procedure should be called after
 *               execute_Create_Planning_Resource_List or
 *               Execute_Create_Planning_Resource_List is called.
 *               It returns the resource_list_identifier, if any,
 *               from a load-execute-fetch cycle.
 *               If no records were locaded using Load_Resource_List()
 *               then there will be no records to fetch.
 * IN Parameters    :
 *  p_api_version_number        - Required. The api version number.
 *
 * OUT Parameters   :
 *  X_Return_Status             - Will return a value of 'S' when the API is
 *                                successful in creating the Resource List.
 *                                Will return a value of 'E' when the API fails
 *                                due to a validation error.
 *                                Will return a value of 'U' when the API hits
 *                                and unexpected error(Some ORA or such error).
 *  X_Resource_list_id          - stores the resource list identifier of the newly
 *                                created resource list.
 ***********************************************************************************/
/*#
 * This API is used to fetch one resource list identifier at a time from the global output structure for
 * resource lists.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_resource_list_id Resource list identifier
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Project Planning Resource List
 * @rep:compatibility S
*/
PROCEDURE Fetch_Resource_List
   (p_api_version_number      IN         NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_resource_list_id        OUT NOCOPY NUMBER);




 /***********************************************************************************
 * API Name          : Fetch_Plan_Format
 * Public/Private    : Public
 * Procedure/Function: Procedure
 * Description : This procedure returns the return status
 *               and the newly created Plan_Rl_Format_Id,
 *               if any, from a load-execute-fetch cycle.
 *               If no records were loaded using Load_Resource_Format()
 *               then there will be no records to fetch.
 * IN Parameters    :
 *  p_api_version_number      - Required. The api version number.
 *  p_format_index            - The p_format_index in parameter is the order
 *                                in which you called load_Resource_Format() API.
 *                                So you will need to track that when using
 *                                load_Resource_Format() API in
 *                                your calling routine.
 *
 * OUT Parameters   :
 *  X_Return_Status             - Will return a value of 'S' when the API is
 *                                successful in creating the Resource list format.
 *                                Will return a value of 'E' when the API fails
 *                                due to a validation error.
 *                                Will return a value of 'U' when the API hits
 *                                and unexpected error(Some ORA or such error).
 *  X_Plan_RL_Format_Id         - stores the resource list format identifier of the newly
 *                                created resource list format.
 ************************************************************************************/
/*#
 * This API is used to fetch planning resource list format identifier from the global output.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_format_index Resource format index
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_plan_rl_format_id Planning resource format identifier
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Project Planning Resource List Format
 * @rep:compatibility S
*/
PROCEDURE Fetch_Plan_Format
 ( p_api_version_number      IN         NUMBER,
   p_format_index            IN         NUMBER
                  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
   x_return_status           OUT NOCOPY VARCHAR2,
   X_Plan_RL_Format_Id       OUT NOCOPY NUMBER);




 /*************************************************************************************
 * API Name          : Fetch_Resource_List_Member
 * Public/Private    : Public
 * Procedure/Function: Procedure
 * Description : This procedure returns the return status
 *               and the newly created resource_list_member_id of
 *               the resource list member
 *               if any, from a load-execute-fetch cycle.
 *               If no records were loaded using Load_Planning_Resource()
 *               then there will be no records to fetch.
 * IN Parameters    :
 *  p_api_version_number        - Required. The api version number.
 *  p_member_index              - The p_member_index in parameter is the order
 *                                in which you called load_Planning_Resource() API. So you will
 *                                need to track that when using Load_Planning_Resource() API in
 *                                your calling routine.
 *
 * OUT Parameters   :
 *  X_Return_Status             - Will return a value of 'S' when the API is
 *                                successful in creating the Resource List members.
 *                                Will return a value of 'E' when the API fails
 *                                due to a validation error.
 *                                Will return a value of 'U' when the API hits
 *                                and unexpected error(Some ORA or such error).
 *  X_resource_list_member_id   - stores the resource list member identifier of the newly
 *                                created resource list member.
 ***************************************************************************************/
/*#
 * This API is used to fetch planning resource list member identifier from the global output.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_member_index Resource list member index
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_resource_list_member_id Planning resource list member identifier
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Project Planning Resource List Member
 * @rep:compatibility S
*/
PROCEDURE Fetch_Resource_List_Member
 ( p_api_version_number      IN         NUMBER,
   p_member_index            IN         NUMBER
                := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_resource_list_member_id OUT NOCOPY NUMBER);

/*************************************************
 * Procedure : Delete_Planning_Resource
 * Description : The purpose of this procedure is to
 * delete a planning resource if it is not
 * being used, else disable it.
 * Further details in the Body.
 * ***************************************************/
/*#
 * This API is used to delete a project planning resource that is not in use or disable a planning resource
 * that is in use.
 * @param p_resource_list_member_id Table of planning resource identifiers
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_error_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Project Planning Resource
 * @rep:compatibility S
*/
PROCEDURE Delete_Planning_Resource(
         p_resource_list_member_id  IN          SYSTEM.PA_NUM_TBL_TYPE  ,
         p_commit                   IN          VARCHAR2,
         p_init_msg_list            IN          VARCHAR2,
         x_return_status            OUT NOCOPY  VARCHAR2,
         x_msg_count                OUT NOCOPY  NUMBER,
         x_error_msg_data           OUT NOCOPY  VARCHAR2);

END Pa_Plan_Res_List_Pub;

 

/
