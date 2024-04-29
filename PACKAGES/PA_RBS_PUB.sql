--------------------------------------------------------
--  DDL for Package PA_RBS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_PUB" AUTHID CURRENT_USER AS
/* $Header: PARBSAPS.pls 120.3 2006/07/24 11:50:47 dthakker noship $*/
/*#
 * This package contains the public APIs for resource breakdown structure information.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Resource Breakdown Structure API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_RES_BRK_DWN_STRUCT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
/*
* *********************************************************************
* Package Name: Pa_Rbs_Pub
* Description:
*  --This AMG package has 2 ways that it can be used depending on
*  customer needs and/or limitations of third party software:
*
*   1) Directly calling the Create_Rbs() and Update_Rbs() apis
*     passing it pl/sql records and tables and receiving back
*     the rbs_header_id, rbs_version_id, and rbs_element_id's via
*     pl/sql table.
*
*   2) Calling the Following sequence of apis:
*      To add new Rbs:
*            i) Init_Rbs_Processing() - required
*           ii) Load_Rbs_Header() - required
*          iii) Load_Rbs_Version() - optional
*           iv) Load_Rbs_Elements() - optional
*            v  Exec_Create_Rbs() - required
*           vi) Fetch_Rbs_Header() - optional
*          vii) Fetch_Rbs_Version() - optional
*        viii) Fetch_Rbs_Elements() - optional
*       To Update the current Rbs:
*            i) Init_Rbs_Processing() - required
*           ii) Load_Rbs_Header() - optional
*          iii) Load_Rbs_Version() - optional
*           iv) Load_Rbs_Elements() - optional
*            v  Exec_Update_Rbs() - required
*           vi) Fetch_Rbs_Header() - optional
*         vii) Fetch_Rbs_Version() - optional
*         viii) Fetch_Rbs_Elements() - optional
*
*   On any error or failed validation the processing will stop and
*   all insertion, updates, deletions will be undone and will not
*   be saved.
*  This package does not offer the ability to delete an RBS header
*  or version record.  If does not offer the ability to delete an
* entire RBS.  To *ove the RBS from use within Projects,change the
*  end date of the RBS Header to the data desired.
* ********************************************************************
*/

 /* Package constant used for package version validation */
G_Api_Version_Number CONSTANT NUMBER := 1;
G_Pkg_Name           CONSTANT VARCHAR2(30) := 'PA_RBS_PUB';



/*
* *******************************************************************
* Rbs_Header_Rec_Typ
* Description :
*   This is the resource breakdown strucure's header record structure. You need to
*   pass the resource breakdown structure's header record whenever you are creating
*   a new resource breakdown structure's header, or when you are updating an existing
*   resource breakdown structure's header. The attributes which are defaulted need
*   to be passed if required to be modified.
* Attributes:
*      Rbs_Header_Id             : The resource breakdown structure's header identifier.Need to be passed
*                                  only while updating the resource breakdown structure's header.
*        Name                    : The resource breakdown structure's name .Can be up to 240 characters long
*        Description             : Description of the resource breakdown structure.
*       Effective_From_Date      : The date from which the resource breakdown structure can be used.
*                                RBS with effective from date before the system date are eligible to
*                                be assigned to project. Effective From date cannot be null.
*     Effective_To_Date        : The date till which the resource breakdown structure can be used.
*                                RBS with effective to date on or after the system date are eligible to
*                                be assigned to project. Null effective from date is replaced with sysdate
*                                when checking to see if the RBS is eligible to be assigned to a project.
*     Record_Version_Number    : Record Version Number of the resource breakdown structure's header record
                                from the view PA_RBS_HEADERS_AMG_V
*  ***************************************************************
*/

TYPE Rbs_Header_Rec_Typ Is Record (
        Rbs_Header_Id               Number     Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        Name                        Varchar2(240)  Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        Description                 Varchar2(2000) Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        Effective_From_Date         Date           Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
        Effective_To_Date           Date           Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
        Record_Version_Number       Number     Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM);

/*
* *******************************************************************
* Rbs_Header_Rec_Out_Typ
* Description :
*   This is the resource breakdown strucure's header record structure which stores the output values of
*   the newly created header identifier.
* Attributes:
*      Rbs_Header_Id             : The resource breakdown structure's header identifier.
*
*  ***************************************************************
*/
TYPE Rbs_Header_Rec_Out_Typ Is Record (
        Rbs_Header_Id         Number
        );

/*
* *******************************************************************
* Rbs_Version_Rec_Typ
* Description :
*    This is the resource breakdown strucure's version record structure.
*
*       When creating an RBS, you need to pass the version record only if you want any specific
*       version attributes. Else, the system  will create a working version whenever you are
*       creating an RBS header.
*
*       When updating an RBS, you need to pass the version record only if you
*       want to update the version attributes - such as version name or job group. If you are
*       not updating any version attributes, you do not need to pass this record.
*       The only version you can update is the current working version. The
*       version attributes can be read from the view PA_RBS_VERSIONS_AMG_V.
* Attributes:
*      Rbs_Version_Id            : The resource breakdown structure's version identifier.Need to be passed
*                                  only while updating the version of resource breakdown structure.
*        Name                    : The resource breakdown structure's version's name .
*        Description             : Description of the resource breakdown structure's version.
*        Version_Start_Date      :  The date from which the resource breakdown structure's version
*                                becomes effective. The date is used when deciding whether all the
*                                project transactions should be mapped to the version. If the date
*                                is before the sysdate, transactions will be mapped to this version.
*
*      Job_Group_Id            :  Job Group Identifier of the job group for the RBS version. Jobs from this
*                                job group are eligible to be elements of the RBS hierarchy.  You can select
*                                the job group from the view PA_JOB_GROUPS_VIEW .
*
*      Record_Version_Number :  The record version number of the rbs version record from the view
*                              PA_RBS_VERSIONS_AMG_V.
*  ***************************************************************
*/
TYPE Rbs_Version_Rec_Typ Is Record (
        Rbs_Version_Id              Number     Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        Name                        Varchar2(240)  Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        Description                 Varchar2(2000) Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        Version_Start_Date          Date           Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
        Job_Group_Id                Number         Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        Record_Version_Number       Number     Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM);



/*
* *******************************************************************
* Rbs_Version_Rec_Out_Typ
* Description :
*   This is the resource breakdown strucure's version record structure which stores the output values of
*   the newly created version of the resource breakdown structure.
* Attributes:
*      Rbs_Version_Id            : The resource breakdown structure's  version identifier for the newly created version.
*
*  ***************************************************************
*/
TYPE Rbs_Version_Rec_Out_Typ Is Record (
        Rbs_Version_Id        Number
        );






/*
* *******************************************************************
* Rbs_Elements_Rec_Typ
* Description :
*   This is the resource breakdown strucure's element's record structure. You need to
*   pass the resource breakdown structure's element record whenever you are creating
*   a new element for a resource breakdown structure, or when you are updating an existing
*   element of a resource breakdown structure. The attributes which are defaulted don't need
*   to be passed in unless they are modified and need to be updated.
* Attributes:
*      Rbs_Version_Id            : The resource breakdown structure's version identifier.
*                                  The element belongs to this version.
*        Rbs_Element_Id          : The resource breakdown structure's element's identifier.
*                                  This is a required field in the update mode.
*        Parent_Element_Id       : The element identifier of the parent of the current element.
*        Resource_Type_Id        : The resource type identifier of the element. You can get the value from
*                                view PA_RES_TYPES_AMG_V.
*        Resource_Source_Id      :  The identifier of the resource that makes up the element of the RBS.
*                                 If the element is a rule, then pass -1 as the resource_source_id
*                                 If the element is an instance, pass the identifier for the resource, if
*                                 the resource has an identifier. Following are the resource types for which
*                                  Identifiers exists:
*                                  BOM_LABOR:      Get the BOM Labor ID from PA_BOM_LABOR_RES_V
*                                  BOM_EQUIPMENT:  Get the BOM Equipment ID from PA_BOM_EQUIPMENT_RES_V
*                                  NAMED_PERSON:   Get the person's ID from PA_EMPLOYEES_RES_V
*                                    EVENT_TYPE:     Get the event id from PA_EVENT_TYPES_RES_V
*                                  EXPENDITURE_CATEGORY:
*                                         Get the expenditure_type_id from PA_EXPEND_CATEGORIES_RES_V
*                                  EXPENDITURE_TYPE:
*                                         Get the EXPENDITURE_TYPE_ID from PA_EXPENDITURE_TYPES_RES_V
*                                  ITEM_CATEGORY:
*                                         Get the ITEM_CATEGORY_ID from PA_ITEM_CATEGORY_RES_V
*                                    INVENTORY_ITEM: Get the ITEM_ID from PA_ITEMS_RES_V
*                                  JOB:            Get the JOB_ID from PA_JOBS_RES_V
*                                  ORGANIZATION:   Get the organization_Id from PA_ORGANIZATIONS_RES_V
*                                  NON_LABOR_RESOURCE:
*                                        Get the non-labor resource_id from PA_NON_LABOR_RESOURCES_RES_V
*                                    RESOURCE_CLASS: Get the resource_class_Id from PA_RESOURCE_CLASS_RES_V
*                                  ROLE: Get the project_role_id from PA_PROJECT_ROLES_RES_V
*                                  SUPPLIER: Get vendor_id from PA_VENDORS_RES_V
*      Resource_Source_Code    :  The resource breakdown structure's element's source code.
*                                  This would have value if the element's resource type is
*                                  associated to the resource type code of REVENUE_CATEGORY
*                                  or USER_DEFINED.
*
*       Order_Number           :  The order in which the elements should be  displayed on a given
*                                  level of the resource breakdown structure in project reporting .
*
*      Process_Type            :  The type of processing required for the resource breakdown structure's
*                                   element.
*                                  Must contain a value of 'A' or 'U' or 'D'.
*                                  Value     Meaning
*                                 -------   -------
*                                  A      Add element
*                                  U      Update element
*                                  D      Delete element and its children if the element exists.
*     Rbs_Level               : To be passed if creating the element. This is the level at which the element
*                                should be placed in the resource breakdown structure.
*                                  The level can have a value between 1 and 10.  1 is reserved for the
*                                root element which will be ignored during processing.
*
*      Record_Version_Number   : Record version number of the resource breakdown structure's element. To
*                                be passed when updating or deleting the element.
*                                You can get the valie from the view. PA_RBS_ELEMENTS_AMG_V
*
*      Rbs_Ref_Element_Id      :  To be passed when creating an element. Each Element must have
*                                Rbs_Ref_Element_Id . This is the identifier you are using to distinguish
*                                each element.
*                                processed at each rbs level
*
*      Parent_Ref_Element_Id   : During creation, each element must have a
*                                Parent_Ref_Element_Id which indicates the parent of the element.
*                                This Identier is the Rbs_Ref_Element_Id of the parent.
*                                If the rbs_level is 1 or 2 then it does not need to be
*                                  populated.  Rbs_level 1 element need no parent and
*                                  rbs_level 2 elements parent is update by the system from the
*                                root element's Id.
*  ***************************************************************
*/
TYPE Rbs_Elements_Rec_Typ IS RECORD (
        Rbs_Version_Id              Number    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        Rbs_Element_Id              Number    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        Parent_Element_Id           Number    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        Resource_Type_Id            Number,
        Resource_Source_Id          Number    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        Resource_Source_Code        Varchar2(240) Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        Order_Number                Number    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        Process_Type                Varchar2(1),
        Rbs_Level                   Number,
        Record_Version_Number       Number    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        Parent_Ref_Element_Id       Number    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        Rbs_Ref_Element_Id          Number    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM);

TYPE Rbs_Elements_Tbl_Typ IS TABLE OF Rbs_Elements_Rec_Typ
     INDEX BY BINARY_INTEGER;


/*
* *********************************************************************
* Rbs_Elements_Rec_Out_Typ
* Description :
*   This is the resource breakdown strucure's element's record structure which stores the output values of
*   the newly created element of the resource breakdown structure.
* Attributes:
*      Rbs_Element_Id            : The resource breakdown structure's element identifier for the newly created element.

*  **********************************************************************
*/
TYPE Rbs_Elements_Rec_Out_Typ Is Record (
        Rbs_Element_Id        Number
        );

TYPE Rbs_Elements_Tbl_Out_Typ Is Table Of Rbs_Elements_Rec_Out_Typ
     INDEX BY BINARY_INTEGER;

-- Header global pl/sql records
G_Rbs_Hdr_Rec           Rbs_Header_Rec_Typ;
G_Empty_Rbs_Hdr_Rec     Rbs_Header_Rec_Typ;
G_Rbs_Hdr_Out_Rec       Rbs_Header_Rec_Out_Typ;
G_Empty_Rbs_Hdr_Out_Rec Rbs_Header_Rec_Out_Typ;

-- Version global pl/sql records
G_Rbs_Ver_Rec           Rbs_Version_Rec_Typ;
G_Empty_Rbs_Ver_Rec     Rbs_Version_Rec_Typ;
G_Rbs_Ver_Out_Rec       Rbs_Version_Rec_Out_Typ;
G_Empty_Rbs_Ver_Out_Rec Rbs_Version_Rec_Out_Typ;

-- Elements global pl/sql tablex
G_Rbs_Elements_Tbl       Rbs_Elements_Tbl_Typ;
G_Empty_Rbs_Elements_Tbl Rbs_Elements_Tbl_Typ;
G_Rbs_Elements_Count     Number := 0;
G_Rbs_Elements_Out_Tbl   Rbs_Elements_Tbl_Out_Typ;


/*
* ***********************************************************************
* API Name          : Init_Rbs_Processing
* Public/Private    : Public
* Procedure/Function: Procedure
* Description       : This procedure initialize global pl/sql records and tables and
*                       other variables.It is used solely in conjunction with option 2
*                       identified in the package description on how to use this package.
*
* ************************************************************************
*/
/*#
 * This API procedure is used to initialize the resource breakdown structure global tables prior to
 * the Load-Execute-Fetch cycle.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Initialize Resource Breakdown Structure
 * @rep:compatibility S
*/
Procedure Init_Rbs_Processing;







/*
* **************************************************************************
*  API Name                  : Create_Rbs()
*  Public/Private            : Public
*  Procedure/Function        : Procedure
*  Description               : This API will create a Resource Breakdown Structure.
*                               At a minimum this API will create the header and a working version
*                                 for the Resource Breakdown Structure.
*                                 The API can also create the entire hierarchy, if the elements of the
*                               hierarchy are passed.
*                                 The root element of the hierarchy for a version, if the version itself.
*                               This is not an updatable element.
*                                 If you provide a root element it will be ignored here.
*
*   Attributes:
*       INPUT Values:
*     P_Commit          : This parameter is optional, by default no commit will take place.
*     P_Init_Msg_List         : This parameter is optional, by default the error msg stack
*                                 is not initialized.
*     P_API_Version_Number    : This parameter is required.It is the API version number.
*     P_Header_Rec              : This parameter is required, See the package specification for
*                                  record structure details.This will hold the values for the RBS header.
*     P_Version_Rec     :  This parameter is optional, if not populated then the version
*                                 record will use the (P_Header_Rec) header record parameter
*                                 to create the version record.  See the package
*                                 specification for record structure for details.
*     P_Elements_Tbl            : Pass this table, if you want to create elements in the RBS.
*                               This holds the actual RBS structure; See the package
*                                 specifications for table record structure for details.
*                                 If this table is populated then it is required to have the root
*                                 element data included in one of the records.
*    OUTPUT Values:
*     X_Rbs_Header_Id        : The Resource breakdown structure's header identifier .
*     X_Rbs_Version_Id       : The Resource breakdown structure's version identifier.
*     X_Elements_Tbl         :  This element will only be populated if the input parameter
*                                 P_Elements_Tbl has records in it, otherwise this element
*                                 would be empty. If P_Elements_Tbl
*                                 is populated then the only  difference X_Elements_Tbl
*                                 will have with P_Elements_Tbl is that the Rbs_Elements_Id
*                                 and Parent_Element_Id will be populated.
*     X_Return_Status        :  Return Status of the API. The API will error out even if one of the
*                              elements errors out.
*                              It will return "S" if the API call was successfull.
*                              It will return a value of 'E' when the API fails
*                              due to a validation error.
*                              It will return a value of 'U' when the API hits
*                              and unexpected error(Some ORA or such error).
*                              The API will error out if even one of the
*                               elements in the hierarchy errors out.
*     X_Msg_Count            : Depending on the P_Init_Msg_List parameter value
*                              this paramenter may have a value of 1 or higher
*     X_Error_Msg_Data       : The parameter will hold a message if there is an
*                              error in this API.
*
*  Considerations:
*                               : If the P_Version_Rec parameter is not populated then the API
*                                  will use the data stored in the P_Header_Rec parameter to
*                                  create the version record.
*                               :  Even if no records exist in the the P_Elements_Tbl parameter a root
*                                  node/element will always be created for the RBS.
*                            :   When populating the P_Header_Rec parameter the rbs_header_id,
*                                  description, effective_to_date, record_version_number are not
*                                  required.
*                               : When populating the P_Version_Rec parameter the version_start_date
*                                  must be greater or equal to the Effective_From_Date
*                                  of the header record.
*                               :  When populating the P_Elements_Tbl parameter, for each record added
*                                  the rbs_level, process_type, parent_ref_element_id, rbs_ref_element_id
*                                  must be populated.  And either the Resource_Source_Id or the
*                                  Resource_Source_Code must be populated.
* ***************************************************************************
*/
/*#
 * This API is used to create a resource breakdown structure (RBS), which is composed of the RBS header,
 * the RBS version, and its elements of the hierarchy.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_header_rec Input record of RBS header information
 * @rep:paraminfo {@rep:required}
 * @param p_version_rec Input record of RBS version information
 * @param p_elements_tbl Input record of RBS version elements
 * @param x_rbs_header_id Identifier of the RBS header
 * @rep:paraminfo {@rep:required}
 * @param x_rbs_version_id Identifier of the RBS version
 * @rep:paraminfo {@rep:required}
 * @param x_elements_tbl Table of RBS element identifiers
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_error_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Resource Breakdown Structure
 * @rep:compatibility S
*/
Procedure Create_Rbs(
        P_Commit             IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List      IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number IN         Number,
        P_Header_Rec         IN         Pa_Rbs_Pub.Rbs_Header_Rec_Typ,
        P_Version_Rec        IN         Pa_Rbs_Pub.Rbs_Version_Rec_Typ Default G_Empty_Rbs_Ver_Rec,
        P_Elements_Tbl       IN         Rbs_Elements_Tbl_Typ Default G_Empty_Rbs_Elements_Tbl,
        X_Rbs_Header_Id      OUT NOCOPY Number,
        X_Rbs_Version_Id     OUT NOCOPY Number,
        X_Elements_Tbl       OUT NOCOPY Rbs_Elements_Tbl_Typ,
        X_Return_Status      OUT NOCOPY Varchar2,
        X_Msg_Count          OUT NOCOPY Number,
        X_Error_Msg_Data     OUT NOCOPY Varchar2);


/*
* ****************************************************************************
* API Name              : Update_Rbs()
* Public/Private        : Public
* Procedure/Function    : Procedure
* Description           :  This API can be used to update the RBS header, RBS Version, or the
*                         RBS Element/Node records or a combination of them.
*                         If P_Header_Rec, P_Version_Rec, and P_Elements_Tbl are null then
*                         nothing will be updated.
*                         If this API is called for a non-existant RBS then the API will error
*                         out with a No Data Found error.
*
*                         If the P_Elements_Tbl is populated then the data will be processed in
*                         the following order:
*                         Process_Type: 'D','U','A'.
*  Example:
*       You want to update the description in the header record.
*      You must provide the rbs_header_id, record_version_number,
*       and new value for description.
*
*  Attributes          :
*      INPUT VALUES :
*               P_Commit : This parameter is optional, by default no commit will take place
*        P_Init_Msg_List : This parameter is optional, by default the error msg stack
*                        is not initialized.
* P_API_Version_Number : required
*         P_Header_Rec : This parameter is optional,
*                               See the package specification for record structure details.
*          P_Version_Rec : This parameter is optional,
*                              See the package specification for record structure details.
*       P_Elements_Tbl : This parameter is optional, this holds the actual RBS structure .
*                         See the package specifications for table record structure for details.
*
*  OUTPUT VALUES :
*       X_Elements_Tbl : This element will only be populated if the
*                         input parameter P_Elements_Tbl has records in it,
*                         otherwise it will be empty.If P_Elements_Tbl
*                        is populated then the only difference
*                         X_Elements_Tbl will have with
*                        P_Elements_Tbl is that the Rbs_Elements_Id
*                        and Parent_Element_Id will be populated where
*                        the process_type = 'A'.
*      X_Return_Status :  Will return a value of 'S' when the API is
*                        succesful in updating the RBS.
*                        Will return a value of 'E' when the API fails
*                        due to a validation error.
*                        Will return a value of 'U' when the API hits
*                        and unexpected error(Some ORA or such error).
*          X_Msg_Count : Depending on the P_Init_Msg_List parameter value
*                        this parameter may have a value of 1 or higher.
*    X_Error_Msg_Data  : This paramter will hold a message if there is an
*                        error in this API.
*
*  Considerations:
*                        : If the P_Header_Rec parameter is not populated then the API
*                          will not update the header record.
*                        : If the P_Version_Rec parameter is not populated then the API
*                          will not update the version record.
*                        : If the P_Elements_Tbl parameter is not populated then the API
*                          will not update/delete/add node/element records to the RBS.
*                        : The API will not allow to add a root node/element record with your own values.
*                          This is done automatically with preset values being system generated.
*                        : The API will not allow to update or delete the root node/element record because
*                          it is system generated.
*
* *****************************************************************************
*/
/*#
 * This API is used to update the resource breakdown structure header and version and delete, update, or
 * add records to element records.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_header_rec Input record of RBS header information
 * @rep:paraminfo {@rep:required}
 * @param p_version_rec Input record of RBS version information
 * @rep:paraminfo {@rep:required}
 * @param p_elements_tbl Input record of RBS version elements
 * @rep:paraminfo {@rep:required}
 * @param x_elements_tbl Table of RBS element identifiers
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_error_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Resource Breakdown Structure
 * @rep:compatibility S
*/
Procedure Update_Rbs(
        P_Commit             IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List      IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number IN         Number,
        P_Header_Rec         IN         Pa_Rbs_Pub.Rbs_Header_Rec_Typ,
        P_Version_Rec        IN         Pa_Rbs_Pub.Rbs_Version_Rec_Typ,
        P_Elements_Tbl       IN         Rbs_Elements_Tbl_Typ,
        X_Elements_Tbl       OUT        NOCOPY Rbs_Elements_Tbl_Typ,
        X_Return_Status      OUT        NOCOPY Varchar2,
        X_Msg_Count          OUT        NOCOPY Number,
        X_Error_Msg_Data     OUT        NOCOPY Varchar2);









/*
* ***********************************************************************************
*  API Name          : Load_Rbs_Header
*  Public/Private    : Public
*  Procedure/Function: Procedure
*  Description       :  This API allows the user to load the RBS header record data.
*                        This has to be executed to create a new RBS.
*                        If used for Creating an RBS then the following parameter must be
*                        populated. p_api_version_number, p_name and p_effective_start_datr .
*
*
*
*
*  Attributes        :
*      INPUT VALUES:
*             P_Api_Version_Number    : The Api version number.This is a mandatory parameter.
*             P_Rbs_Header_Id         : The identifier for the resource breakdown structure's header.
*             P_Name                  : The name of the resource breakdown structure.
*             P_Description           : The description of the resource breakdown structure.
*             P_Effective_From_Date   : The date from which the resource breakdown structure is effective.
*             P_Effective_To_Date     : The date till which the resource breakdown structure is effective.
*             P_Record_Version_Number : The record version number of the RBS header.
*
*     OUTPUT VALUES:
*               X_Return_Status         :  Will return a value of 'S' when the API is
*                                         succesful in loading the RBS.
*                                         Will return a value of 'E' when the API fails
*                                         due to a validation error.
*                                         Will return a value of 'U' when the API hits
*                                         and unexpected error(Some ORA or such error).
* *************************************************************************************
*/
/*#
 * This API is used to load header record information to a global PL/SQL table for the resource
 * breakdown structure.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_rbs_header_id Resource breakdown structure header identifier
 * @param p_name Resource breakdown structure header name
 * @rep:paraminfo {@rep:required}
 * @param p_description Resource breakdown structure header description
 * @param p_effective_from_date Resource breakdown structure header effective start date
 * @rep:paraminfo {@rep:required}
 * @param P_Effective_To_Date Resource breakdown structure header effective end date
 * @param p_record_version_number Resource breakdown structure header record version number
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Resource Breakdown Structure Header
 * @rep:compatibility S
*/
Procedure Load_Rbs_Header(
        P_Api_Version_Number    IN         Number,
        P_Rbs_Header_Id         IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Name                  IN         Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        P_Description           IN         Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        P_Effective_From_Date   IN         Date     Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
        P_Effective_To_Date     IN         Date     Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
        P_Record_Version_Number IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        X_Return_status         OUT NOCOPY Varchar2);



/*
* ***************************************************************************************
* API Name           : Load_Rbs_Version
* Public/Private     : Public
* Procedure/Function : Procedure
* Description        :
*                       This API allows the user to load the RBS version record data.
*                       It is never required to be executed.
*
*                       It can be used for Creating an RBS version record.In that case the
*                       following parameter must be populated. p_api_version_number, p_name,
*                       p_effective_start_date.
*
*
*                       It can be used for Updating an RBS version. In that case  the
*                       following parameters must be populated. p_api_version_number,
*                       p_rbs_header_id, p_rbs_version_id, p_name,p_version_start_date,
*                       p_record_version_number.
*  Attributes:
*      INPUT VALUES:
*             P_Api_Version_Number    : The Api version number.This is a mandatory parameter.
*               P_Rbs_Version_Id        : The identifier for the resource breakdown structure's version.
*               P_Name                  : The name of the resource breakdown structure's version.
*               P_Description           : The description of the resource breakdown structure's version.
*               P_Version_Start_Date    : The date from which the resource breakdown structure's version is effective.
*             P_Job_Group_Id          : The job group identifier associated with the RBS version.
*               P_Record_Version_Number : The record version number of the RBS version.
*      OUTPUT VALUES:
*               X_Return_Status         : Will return a value of 'S' when the API is
*                                         succesful in loading the RBS version.
*                                         Will return a value of 'E' when the API fails
*                                         due to a validation error.
*                                         Will return a value of 'U' when the API hits
*                                         and unexpected error(Some ORA or such error).
* *************************************************************************************
*/
/*#
 * This API is used to load resource breakdown structure version record information to a global
 * PL/SQL table.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_rbs_version_id Resource breakdown structure version identifier
 * @param p_name Resource breakdown structure version name
 * @rep:paraminfo {@rep:required}
 * @param p_description Resource breakdown structure version description
 * @param p_version_start_date Resource breakdown structure version start date
 * @rep:paraminfo {@rep:required}
 * @param p_job_group_id Job group identifier for resource breakdown structure version
 * @param p_record_version_number Resource breakdown structure record version number
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Resource Breakdown Structure Version
 * @rep:compatibility S
*/
Procedure Load_Rbs_Version(
        P_Api_Version_Number    IN         Number,
        P_Rbs_Version_Id        IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Name                  IN         Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        P_Description           IN         Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        P_Version_Start_Date    IN         Date     Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
        P_Job_Group_Id          IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Record_Version_Number IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        X_Return_Status         OUT NOCOPY VARCHAR2);



/*
* ****************************************************************************
* API Name            : Load_Rbs_Elements
* Public/Private      : Public
* Procedure/Function  : Procedure
* Description         :
*                        This API allows the user to load the RBS element records data.
*                        It is never required to be executed.
*
*                        If used with Exec_Create_Rbs() api the following parameters
*                        must be populated when used: p_api_version_number, P_Resource_Type_Id,
*                        P_Resource_Source_Id or P_Resource_Source_Code, P_Process_Type,
*                        P_Rbs_Level, P_Parent_Ref_Element_Id, P_Rbs_Ref_Element_Id.  The process
*                        type must always be 'A'.
*
*                        If used with Exec_Update_Rbs() API then the following parameters
*                        must be populated when used: p_api_version_number, P_Resource_Type_Id,
*                        P_Resource_Source_Id or P_Resource_Source_Code, P_Process_Type,
*                        P_Rbs_Level.  When process type is 'U' or 'D' then P_Rbs_Version_Id,
*                        P_Parent_Element_Id are required.  When process type is 'A' then
*                        P_Parent_Ref_Element_Id, P_Rbs_Ref_Element_Id are required.
*
*                       If you are loading the root node/element then the rbs_level must be 1
*                        and the P_Parent_Ref_Element_Id and P_Parent_Element_Id are always null.
*
*                        Process_Type      Meaning
*                        ------------      -------
*                          A             Add Element
*                          U             Update Node/Element
*                          D             Delete Node/Element and its children if they exist.
*
*                        The P_Order_Number is used to  specificy the order in which the elements
*                        are ordered under their parents.  If no order number is provided then the order will
*                        be automatically created for the children of each parent node/element.
*
*                        Note that when using this API it is going to be called many times and you
*                        will need some mechanism in the calling routine to keep track of how many
*                        record were loaded if you wish to use the fetch_rbs_element() API.
*  Attributes                    :
*         INPUT VALUES:
*                       P_Api_Version_Number   : This is a mandatory parameter.It specifies the API version number.
*                       P_Rbs_Version_Id       : This specifies the Resource breakdown structure's version identifier.
*                       P_Rbs_Element_Id       : This specifies the identifier of the resource breakdown structure's element.
*                     P_Parent_Element_Id    : The element identifier of the parent of the current element.
*                       P_Resource_Type_Id     : The resource type identifier of the element.
*                     P_Resource_Source_Id   : The resource breakdown structure's element's source id.
*                                                This would have value if the element's resource type is
*                                                associated to the resource type of BOM_LABOR, BOM_EQUIPMENT, NAMED_PERSON,
*                                                EVENT_TYPE, EXPENDITURE_CATEGORY,EXPENDITURE_TYPE, ITEM_CATEGORY,
*                                                INVENTORY_ITEM JOB, ORGANIZATION, PERSON_TYPE, NON_LABOR_RESOURCE
*                                                RESOURCE_CLASS, ROLE, SUPPLIER.
*                     P_Resource_Source_Code :  The resource breakdown structure's element's source code.
*                                                This would have value if the element's resource type is
*                                                associated to the resource type code of REVENUE_CATEGORY
*                                                or USER_DEFINED.
*                      P_Order_Number          : The order in which the elements are displayed on a given
*                                                level of the  resource breakdown structure
*
*                      P_Process_Type          :  The type of processing required for the resource breakdown structure's element.
*                                                Must contain a value of 'A' or 'U' or 'D'.
*                                                Value     Meaning
*                                                -------   -------
*                                                A         Add element
*                                                U         Update element
*                                                D         Delete element and its children if the element exists.
*
*                    P_Rbs_Level             :  The level at which the element would be placed in the resource breakdown structure.
*                                                The level can have a value between 1 and 10.  1 is reserved for the root element which
*                                                will be ignored during processing.
*
*                    P_Record_Version_Number : Record version number of the resource breakdown structure's element.
*                      P_Parent_Ref_Element_Id :  This is your parent internal identifier to the
*                                                rbs.  This cannot be an arbitrary value.  At each
*                                                rbs_level the rbs element must be associated to an
*                                                existing rbs element parent so must contain a value
*                                                from the previous rbs_level Rbs_Ref_Element_Id.  If
*                                                the rbs_level is 1 or 2 then it does not need to be
*                                                populated.  Rbs_level 1 element need no parent and
*                                                rbs_level 2 elements parent is automatically create
*                                                and root element internal identifier will be used.
*
*                       P_Rbs_Ref_Element_Id   : This is your internal identifier but does
*                                                effect the order with which the records are
*                                                processed at each rbs level
*                OUTPUT VALUES:
*                       X_Return_Status         : Will return a value of 'S' when the API is
*                                                 succesful in loading the RBS elements.
*                                                 Will return a value of 'E' when the API fails
*                                                 due to a validation error.
*                                                 Will return a value of 'U' when the API hits
*                                                 and unexpected error(Some ORA or such error).
* ********************************************************************************
*/
/*#
 * This API is used to load resource breakdown structure element record information to a global
 * PL/SQL table.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_rbs_version_id Resource breakdown structure version identifier
 * @param p_rbs_element_id Identifier of the resource breakdown structure element
 * @param p_parent_element_id Parent element identifier of the current element
 * @rep:paraminfo {@rep:required}
 * @param p_resource_type_id Resource type of the element
 * @rep:paraminfo {@rep:required}
 * @param p_resource_source_id Source identifier of the resource
 * @param p_resource_source_code Source code of the resource
 * @param p_order_number Order number of the element
 * @param p_process_type Indicates whether to insert, update, or delete the element
 * @rep:paraminfo {@rep:required}
 * @param P_Rbs_Level Level at which the element will be placed in the resource breakdown structure
 * @rep:paraminfo {@rep:required}
 * @param p_record_version_number Element record version number
 * @param p_parent_ref_element_id Parent element reference identifier
 * @param p_rbs_ref_element_id Element reference identifier
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Load Resource Breakdown Structure Elements
 * @rep:compatibility S
*/
Procedure Load_Rbs_Elements(
        P_Api_Version_Number    IN         Number,
        P_Rbs_Version_Id        IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Rbs_Element_Id        IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Parent_Element_Id     IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Resource_Type_Id      IN         Number,
        P_Resource_Source_Id    IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Resource_Source_Code  IN         Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        P_Order_Number          IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Process_Type          IN         Varchar2,
        P_Rbs_Level             IN         Number,
        P_Record_Version_Number IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Parent_Ref_Element_Id IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Rbs_Ref_Element_Id    IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        X_Return_Status         OUT NOCOPY Varchar2);





/*
* *************************************************************************************
* API Name           : Fetch_Rbs_Header
* Public/Private     : Public
* Procedure/Function : Procedure
* Description        :
*                     This API returns the internal identifier and status of the Rbs Header
*                     record.
*
*                        There are 3 status that can be returned:
*                        S - Success
*                        E - Error; caused when fails validation
*                        U - Unexpected Error; system error and unhandle issue like ORA errors
* Attributes         :
*      INPUT VALUES:
*                  P_Api_Version_Number     : This is a mandatory parameter.It specifies the API version number.
*      OUTPUT VALUES:
*                  X_Rbs_Header_Id          :  The identifier for the resource breakdown structure's header.
*
*                X_Return_Status            :  Will return a value of 'S' when the API is
*                                                 succesful in fetching the RBS header.
*                                                 Will return a value of 'E' when the API fails
*                                                 due to a validation error.
*                                                 Will return a value of 'U' when the API hits
*                                                 and unexpected error(Some ORA or such error).
* *****************************************************************************************
*/
/*#
 * This API is used to fetch output parameters related to resource breakdown structure header information.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param x_rbs_header_id Resource breakdown structure header identifier
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Resource Breakdown Structure Header
 * @rep:compatibility S
*/
Procedure Fetch_Rbs_Header(
        P_Api_Version_Number    IN         Number,
        X_Rbs_Header_Id         OUT NOCOPY Number,
        X_Return_Status         OUT NOCOPY Varchar2);





/*
* *****************************************************************************************
* API Name           : Fetch_Rbs_Version
* Public/Private     : Public
* Procedure/Function : Procedure
* Description        :
*                     This API returns the internal identifier and status of the Rbs Version
*                     record.
*
*                        There are 3 status that can be returned:
*                        S - Success
*                        E - Error; caused when fails validation
*                        U - Unexpected Error; system error and unhandle issue like ORA errors
* Attributes         :
*   INPUT VALUES :
*                  P_Api_Version_Number     : This is a mandatory parameter.It specifies the API version number.
*   OUTPUT VALUES:
*                  X_Rbs_Version_Id         : The identifier for the resource breakdown structure's version.
*
*                  X_Return_Status          :  Will return a value of 'S' when the API is
*                                                 succesful in fetching the RBS Version.
*                                                 Will return a value of 'E' when the API fails
*                                                 due to a validation error.
*                                                 Will return a value of 'U' when the API hits
*                                                 and unexpected error(Some ORA or such error).
* ********************************************************************************************
*/
/*#
 * This API is used to fetch output parameters related to resource breakdown structure version information.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param x_rbs_version_id Resource Breakdown Structure version identifier
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Resource Breakdown Structure Version
 * @rep:compatibility S
*/
Procedure Fetch_Rbs_Version(
        P_Api_Version_Number    IN         Number,
        X_Rbs_Version_Id        OUT NOCOPY Number,
        X_Return_Status         OUT NOCOPY Varchar2);






/*
* ****************************************************************************************
*  API Name             : Fetch_Rbs_Element
*  Public/Private       : Public
*  Procedure/Function : Procedure
*  Description  :
*               This API returns the internal identifier and status of the Rbs element/node
*               record.  If no records were loaded using load_rbs_elements then there
*               will no records to fetch.
*
*                There are 3 status that can be returned:
*                S - Success
*                E - Error; caused when fails validation
*                U - Unexpected Error; system error and unhandle issue like ORA errors
*
*
*
* Attributes         :
*   INPUT VALUES:
*                  P_Api_Version_Number         : This is a mandatory parameter.It specifies the API version number.
*                  P_Rbs_Element_Index          : The p_rbs_element_index in parameter is the order in which you called
*                                                 load_rbs_elements() API.  So you will need to track that when
*                                                 when using the load_rbs_elements() API in your calling routine.
*  OUTPUT VALUES:
*                  X_Rbs_Element_Id             : The identifier for the resource breakdown structure's element.
*
*                  X_Return_Status              :  Will return a value of 'S' when the API is
*                                                 succesful in fetching the RBS element.
*                                                 Will return a value of 'E' when the API fails
*                                                 due to a validation error.
*                                                 Will return a value of 'U' when the API hits
*                                                 and unexpected error(Some ORA or such error).
* ********************************************************************************************************************
*/
/*#
 * This API is used to fetch output parameters related to resource breakdown structure element information.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_rbs_element_index Resource breakdown structure element index
 * @rep:paraminfo {@rep:required}
 * @param x_rbs_element_id Resource breakdown structure element identifier
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Resource Breakdown Structure Element
 * @rep:compatibility S
*/
Procedure Fetch_Rbs_Element(
        P_Api_Version_Number        IN         Number,
        P_Rbs_Element_Index         IN         Number,
        X_Rbs_Element_Id            OUT NOCOPY Number,
        X_Return_Status             OUT NOCOPY Varchar2);









/*
* ********************************************************************************************************
* API Name             : Exec_Create_Rbs
* Public/Private     : Public
* Procedure/Function : Procedure
* Description        :
*                       This API uses the data that was loaded via the load_rbs_header(),
*                       load_rbs_version(), and load_rbs_elements() API's to call the
*                       Create_Rbs() API.
* Attributes         :
*     INPUT VALUES :
*                  P_Commit        : This parameter is optional, by default no commit will take place.
*            P_Init_Msg_List     : This parameter is optional, by default the error msg stack
*                                    is not initialized.
*           P_Api_Version_Number :  This parameter is  required. The Api version number.
*
*     OUTPUT VALUES :
*     X_Return_Status            : Will return a value of 'S' when the API is
*                                 successful in creating the RBS.
*                                : Will return a value of 'E' when the API fails
*                                 due to a validation error.
*                                : Will return a value of 'U' when the API hits
*                                 and unexpected error(Some ORA or such error).
*     X_Msg_Count                : Depending on the P_Init_Msg_List parameter value
*                                 this paramenter may have a value of 1 or higher
*     X_Error_Msg_Data           : The parameter will hold a message if there is an
*                                 error in this API.
* *******************************************************************************************************
*/
/*#
 * This API is used to create resource breakdown structure using the data stored in the global tables.
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
 * @rep:displayname Execute Create Resource Breakdown Structure
 * @rep:compatibility S
*/
Procedure Exec_Create_Rbs(
        P_Commit             IN         Varchar2 := Fnd_Api.G_False,
        P_Init_Msg_List      IN         Varchar2 := Fnd_Api.G_True,
        P_Api_Version_Number IN         Number,
        X_Return_Status      OUT NOCOPY Varchar2,
        X_Msg_Count          OUT NOCOPY Number,
        X_Msg_Data           OUT NOCOPY Varchar2);







/*
* ********************************************************************************************************
* API Name           : Exec_Update_Rbs
* Public/Private     : Public
* Procedure/Function : Procedure
* Description        :
*                        This API uses the data that was loaded via the load_rbs_header(),
*                        load_rbs_version(), and load_rbs_elements() API's to call the
*                        Update_Rbs() API.
*     INPUT VALUES :
*                  P_Commit        : This parameter is optional, by default no commit will take place
*            P_Init_Msg_List     : This parameter is optional, by default the error msg stack
*                                    is initialized
*           P_Api_Version_Number : This parameter is  required. The Api version number.
*
*     OUTPUT VALUES :
*     X_Return_Status            : Will return a value of 'S' when the API is
*                                  successful in creating the RBS.
*                                  Will return a value of 'E' when the API fails
*                                  due to a validation error.
*                                  Will return a value of 'U' when the API hits
*                                  and unexpected error(Some ORA or such error).
*     X_Msg_Count                : Depending on the P_Init_Msg_List parameter value
*                                  this paramenter may have a value of 1 or higher
*     X_Error_Msg_Data           : The parameter will hold a message if there is an
*                                  error in this API.
* *****************************************************************************************************
*/
/*#
 * This API is used to update resource breakdown structure using the data stored in the global tables.
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
 * @rep:displayname Execute Update Resource Breakdown Structure
 * @rep:compatibility S
*/
Procedure Exec_Update_Rbs(
        P_Commit             IN         Varchar2 := Fnd_Api.G_False,
        P_Init_Msg_List      IN         Varchar2 := Fnd_Api.G_True,
        P_Api_Version_Number IN         Number,
        X_Return_Status      OUT NOCOPY Varchar2,
        X_Msg_Count          OUT NOCOPY Number,
        X_Msg_Data           OUT NOCOPY Varchar2);









/*
* *****************************************************************************************************
* API Name            : Copy_Rbs_Working_Version
* Public/Private      : Public
* Procedure/Function  : Procedure
* Description         :
*                       This API is used to create a working version from an existing frozen version.
*  Attributes          :
*    INPUT VALUES :
*            P_Commit         : This parameter is optional, by default no commit will take place.
*            P_Init_Msg_List  : This parameter is optional, by default the error msg stack
*                                    is not initialized.
*       P_Api_Version_Number  : This parameter is  required. The Api version number.
*
*          P_RBS_Version_Id     : The RBS frozen version's id to copy from.
*       P_Rbs_Header_Id       : The RBS  Header for the frozen and the working version.
*        P_Rbs_Header_Name      : The rbs header name of the version selected to make a copy.
*        P_Rbs_Version_Number   : The  version number of the rbs version selected to make a copy.
*      P_Rec_Version_Number   : The record version number for the current working version.
*    OUTPUT VALUES :
*     X_Return_Status            : Will return a value of 'S' when the API is
*                                  successful in creating the RBS.
*                                : Will return a value of 'E' when the API fails
*                                  due to a validation error.
*                                : Will return a value of 'U' when the API hits
*                                  and unexpected error(Some ORA or such error).
*     X_Msg_Count                : Depending on the P_Init_Msg_List parameter value
*                                  this paramenter may have a value of 1 or higher
*     X_Error_Msg_Data           : The parameter will hold a message if there is an
*                                  error in this API.
* *************************************************************************************************************
*/

/*#
 * This API is used to create a working version of a resource breakdown structure from an existing frozen
 * version.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_rbs_version_id Resource breakdown structure version identifier of the frozen version to be copied
 * @param p_rbs_header_id Identifier of the resource breakdown structure header
 * @param p_rbs_header_name Name of the resource breakdown structure header
 * @param p_rbs_version_number Number of the resource breakdown structure version
 * @param p_rec_version_number Record version number of the current resource breakdown structure working version
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_error_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Copy Resource Breakdown Structure Working Version
 * @rep:compatibility S
*/
Procedure Copy_Rbs_Working_Version(
        P_Commit                IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List         IN         Varchar2 Default Fnd_Api.G_True,
        P_Api_Version_Number    IN         Number,
        P_RBS_Version_Id        IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Rbs_Header_Id         IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Rbs_Header_Name       IN         Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        P_Rbs_Version_Number    IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Rec_Version_Number    IN         Number,
        X_Return_Status         OUT NOCOPY Varchar2,
        X_Msg_Count             OUT NOCOPY Number,
        X_Error_Msg_Data        OUT NOCOPY Varchar2 );











/*
* ************************************************************************************************************
* API Name              : Freeze_Rbs_Version
* Public/Private        : Public
* Procedure/Function  : Procedure
* Description           :
*               This API to freeze the current working version for the RBS and create and new
*               working version.
*  Attributes          :
*
*    INPUT VALUES :
*            P_Commit              : This parameter is optional, by default no commit will take place.
*            P_Init_Msg_List       : This parameter is optional, by default the error msg stack
*                                      is not initialized.
*       P_Api_Version_Number       : This parameter is  required. The Api version number.
*
*          P_RBS_Version_Id          : The  version id of the RBS which has to be freezed.
*        P_Rbs_Header_Name           : The rbs header name of the version to be freezed.
*       P_Rbs_Header_Id            : The header  id of the RBS that has to be freezed.
*
*     P_Rbs_Version_Record_Ver_Num : The record version number of the RBS Version.
*
*
*    OUTPUT VALUES :
*     X_Return_Status              : Will return a value of 'S' when the API is
*                                    successful in creating the RBS.
*                                  : Will return a value of 'E' when the API fails
*                                    due to a validation error.
*                                  : Will return a value of 'U' when the API hits
*                                    and unexpected error(Some ORA or such error).
*     X_Msg_Count                  : Depending on the P_Init_Msg_List parameter value
*                                    this paramenter may have a value of 1 or higher
*     X_Error_Msg_Data             : The parameter will hold a message if there is an
*                                    error in this API.
* *****************************************************************************************************
*/
/*#
 * This API is used to freeze the current working resource breakdown structure version and enable the user
 * to create a new working version.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_rbs_version_id Resource breakdown structure version identifier
 * @rep:paraminfo {@rep:required}
 * @param p_rbs_header_name Name of resource breakdown structure whose working version should be frozen
 * @param p_rbs_header_id Resource breakdown structure header identifier whose working version should be frozen
 * @param P_Rbs_Version_Record_Ver_Num Resource breakdown structure version record version number
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_error_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Freeze Resource Breakdown Structure Version
 * @rep:compatibility S
*/
Procedure Freeze_Rbs_Version(
        P_Commit                     IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List              IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number         IN         Number,
        P_Rbs_Version_Id             IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Rbs_Header_Name            IN         Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        P_Rbs_Header_Id              IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Rbs_Version_Record_Ver_Num IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        X_Return_Status              OUT NOCOPY Varchar2,
        X_Msg_Count                  OUT NOCOPY Number,
        X_Error_Msg_Data             OUT NOCOPY Varchar2);













/*
* **************************************************************************************************
*  API Name           : Assign_Rbs_To_Project
*  Public/Private     : Public
*  Procedure/Function : Procedure
*  Description        :
*                   This API will assign the RBS to a project.
*                   You must provide the Rbs Header Id and the Project Id as in parameters
*                   The rest have default values.  The RBS will always have a usage of Reporting.
* Attributes:
*    INPUT VALUES:
*            P_Commit              : This parameter is optional, by default no commit will take place.
*            P_Init_Msg_List       : This parameter is optional, by default the error msg stack
*                                      is not initialized.
*       P_Api_Version_Number       : This parameter is  required. The Api version number.
*          P_RBS_Version_Id          : The  version identifier of the RBS which has to be associated with the project.
*       P_Rbs_Header_Id            : The header  identifier of the RBS that has to be associated to the project.
*          P_Project_Id            : The identifier of the project to which the RBS has to be associated.
*       P_Pm_Project_Reference       : The project reference that would be generated when a third party software
*                                       gets migrated to oracle applications.Like a project from Microsoft project getting
*                                       created/migrated to Oracle projects.If a project is created in Oracle Projects
*                                       this would have a null value.
*     P_Rbs_Header_Name            : The Resource breakdown structure's header's name.
*       P_Rbs_Version_Number         : The version number of the RBS. This is not the version id.
*      P_Prog_Rep_Usage_Flag       :  Flag which indicates whether the RBS would be used for Program Reporting.
*                                       'Y' indicates that it would be used.
*                                       'N' indicates that it would not be used.
*      P_Primary_Rep_Flag          :  Flag which indicates whether the RBS would be used for Primary Reporting.
*                                       'Y' indicates that it would be used.
*                                       'N' indicates that it would not be used.
*
*    OUTPUT VALUES :
*     X_Return_Status              : Will return a value of 'S' when the API is
*                                    successful in creating the RBS.
*                                  : Will return a value of 'E' when the API fails
*                                    due to a validation error.
*                                  : Will return a value of 'U' when the API hits
*                                    and unexpected error(Some ORA or such error).
*     X_Msg_Count                  : Depending on the P_Init_Msg_List parameter value
*                                    this paramenter may have a value of 1 or higher
*     X_Error_Msg_Data             : The parameter will hold a message if there is an
*                                    error in this API.
* NOTE: The parameter P_Rbs_Version_Id is not used in the procedure. It is retained for the time being.
* *********************************************************************************************************
*/
/*#
 * This API is used to assign the resource breakdown structure to a project.
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_project_id Identifier of the project to which the resource breakdown structure should be assigned
 * @rep:paraminfo {@rep:required}
 * @param p_pm_project_reference Identifier of the project of the external system to which the resource
 * breakdown structure should be assigned
 * @param p_rbs_header_id Resource breakdown structure header identifier
 * @rep:paraminfo {@rep:required}
 * @param p_rbs_header_name Name of resource breakdown structure
 * @param p_rbs_version_number Resource breakdown structure version number
 * @rep:paraminfo {@rep:required}
 * @param p_rbs_version_id Resource breakdown structure version identifier
 * @param p_prog_rep_usage_flag Flag indicating whether the assigned resource breakdown structure is used for
 *  program reporting
 * @param p_primary_rep_flag Flag indicating whether the assigned resource breakdown structure is the primary
 *  reporting resource breakdown structure
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_error_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Assign Resource Breakdown Structure To Project
 * @rep:compatibility S
*/
Procedure Assign_Rbs_To_Project(
        P_Commit              IN         Varchar2 DEFAULT FND_API.G_FALSE,
        P_Init_Msg_List       IN         Varchar2 DEFAULT FND_API.G_True,
        P_API_Version_Number  IN         Number,
        P_Rbs_Header_Id       IN         Number   DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Rbs_Version_Id      IN         Number   DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Not used
        P_Project_Id          IN         Number   DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Pm_Project_Reference IN        Varchar2 DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        P_Rbs_Header_Name     IN         Varchar2 DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        P_Rbs_Version_Number  IN         Number   DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Prog_Rep_Usage_Flag IN         Varchar2 DEFAULT 'N',
        P_Primary_Rep_Flag    IN         Varchar2 DEFAULT 'N',
        X_Return_Status       OUT NOCOPY Varchar2,
        X_Msg_Count           OUT NOCOPY Number,
        X_Error_Msg_Data      OUT NOCOPY Varchar2);











/*
* *****************************************************************************************************
* API Name           : PopulateErrorStack
* Public/Private     : Private
* Procedure/Function : Procedure
* Description        :
*                  This API is used to generate a usable message when processing the
*                  rbs elements.  If is for internal use only and should not be called
*                   externally.
*  Attributes        :
*     INPUT VALUES :
*           P_Ref_Element_Id          :  This is an internal identifier for the element but does
*                                        effect the order with which the records are
*                                        processed at each rbs_level.
*               P_Element_Id          : The RBS element id.
*          P_Process_Type             : The type of the process.It can have the following values.'U','A','D'
*          P_Error_Msg_Data           :  The parameter will hold a message if there is an
*                                       error in the which calls this method.
* ********************************************************************************************************
*/

Procedure PopulateErrorStack(
        P_Ref_Element_Id IN Number,
        P_Element_Id     IN Number,
        P_Process_Type   IN Varchar,
        P_Error_Msg_Data IN Varchar2);




END Pa_Rbs_Pub;

 

/
