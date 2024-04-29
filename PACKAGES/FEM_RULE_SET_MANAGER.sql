--------------------------------------------------------
--  DDL for Package FEM_RULE_SET_MANAGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_RULE_SET_MANAGER" AUTHID CURRENT_USER AS
--$Header: FEMRSMANS.pls 120.2.12000000.3 2007/08/20 16:38:56 gcheng ship $

--Lookup Codes for Error text
G_RSM_MEMBER_VALID	VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
				          ,'FEM_RSM_ERROR_TYPES'
                                          ,'FEM_RSM_MEMBER_VALID'); --'Valid';
G_RSM_INVALID_STATUS	VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
				          ,'FEM_RSM_ERROR_TYPES'
                                          ,'FEM_RSM_INVALID_STATUS'); --'Not Valid';
G_RSM_MEMBER_ENABLED 	VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
                                          ,'FEM_RSM_ERROR_TYPES'
                                          ,'FEM_RSM_MEMBER_ENABLED'); --'Enabled';
G_RSM_MEMBER_DISABLED  	VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
                                          ,'FEM_RSM_ERROR_TYPES'
                                          ,'FEM_RSM_MEMBER_DISABLED'); --'Disabled';
G_RSM_MEMBER_PREV_PROCESSED     VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
                                         ,'FEM_RSM_ERROR_TYPES'
                                         ,'FEM_RSM_MEM_PREV_PROCESSED'); --'Previously Processed';
G_RSM_CYCLICAL_FAILURE	        VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
                                         ,'FEM_RSM_ERROR_TYPES'
                                         ,'FEM_RSM_CYCLICAL_FAILURE'); --'Cyclical Failure';
G_RSM_DEPTH_FAILURE	        VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
                                         ,'FEM_RSM_ERROR_TYPES'
                                         ,'FEM_RSM_DEPTH_FAILURE'); --'Depth Failure';
G_RSM_VALID_DEFN_EXISTS         VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
                                         ,'FEM_RSM_ERROR_TYPES'
                                         ,'FEM_RSM_VALID_DEFN_EXISTS'); --'Exists';
G_RSM_NO_VALID_DEFN	        VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
                                        ,'FEM_RSM_ERROR_TYPES'
                                        ,'FEM_RSM_NO_VALID_DEFN'); --'Not Exists';
G_RSM_RULE_APPROVED		VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
                                        ,'FEM_RSM_ERROR_TYPES'
                                        ,'FEM_RSM_RULE_APPROVED'); --'Approved';
G_RSM_RULE_NOT_APPROVED  	VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
                                        ,'FEM_RSM_ERROR_TYPES'
                                        ,'FEM_RSM_RULE_NOT_APPROVED'); --'Not Approved';
G_RSM_NO_DEP_OBJECTS		VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
                                        ,'FEM_RSM_ERROR_TYPES'
                                        ,'FEM_RSM_NO_DEP_OBJECTS'); --'None';
G_RSM_DEP_OBJECTS_INVALID       VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
                                        ,'FEM_RSM_ERROR_TYPES'
                                        ,'FEM_RSM_DEP_OBJECTS_INVALID'); --'Not Valid';
G_RSM_RULE_LOCKED		VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
                                        ,'FEM_RSM_ERROR_TYPES'
                                        ,'FEM_RSM_RULE_LOCKED'); --'Locked';
G_RSM_RULE_NOT_LOCKED           VARCHAR2(30) := FEM_UTILS.getLookupMeaning(274
                                        ,'FEM_RSM_ERROR_TYPES'
                                        ,'FEM_RSM_RULE_NOT_LOCKED'); --'Not Locked';

--Error Message variables
 G_INVALID_DATASET_GROUP VARCHAR2(30) := 'FEM_INVALID_DATASET_GROUP';
 G_INVALID_LVSCID_ON_OBJECT VARCHAR2(30) := 'FEM_INVALID_LVSCID_ON_OBJECT';

--Exceptions
USER_EXCEPTION EXCEPTION;

--Global Variables
DEF_OBJECT_ID			 FEM_OBJECT_CATALOG_B.OBJECT_ID%TYPE;
DEF_OBJECT_TYPE_CODE             FEM_OBJECT_CATALOG_B.OBJECT_TYPE_CODE%TYPE;
DEF_LOCAL_VS_COMBO_ID		 FEM_OBJECT_CATALOG_B.LOCAL_VS_COMBO_ID%TYPE;

DEF_OBJECT_DISPLAY_NAME	         FEM_OBJECT_CATALOG_VL.OBJECT_NAME%TYPE;
DEF_FOLDER_ID		         FEM_FOLDERS_B.FOLDER_ID%TYPE;
DEF_FOLDER_NAME                  FEM_FOLDERS_VL.FOLDER_NAME%TYPE;

DEF_OBJECT_DEFINITION_ID	 FEM_OBJECT_DEFINITION_B.OBJECT_DEFINITION_ID%TYPE;
DEF_APPROVAL_STATUS_CODE         FEM_OBJECT_DEFINITION_B.APPROVAL_STATUS_CODE%TYPE;

DEF_RULESET_OBJECT_TYPE_CODE     FEM_RULE_SETS.RULE_SET_OBJECT_TYPE_CODE%TYPE;

DEF_CHILD_EXEC_SEQUENCE          FEM_RULE_SET_MEMBERS.CHILD_EXECUTION_SEQUENCE%TYPE;
DEF_EXECUTE_CHILD_FLAG		 FEM_RULE_SET_MEMBERS.EXECUTE_CHILD_FLAG%TYPE;

DEF_DATASET_CODE		 FEM_DATASETS_B.DATASET_CODE%TYPE;


TYPE Rule_Set_Instance_Rec IS RECORD( RuleSet_Object_ID DEF_OBJECT_ID%TYPE
                                     ,Owning_RuleSet_Name DEF_OBJECT_DISPLAY_NAME%TYPE
                                     ,RuleSet_Object_Name DEF_OBJECT_DISPLAY_NAME%TYPE         );

TYPE Rule_Set_Instance_Tab IS TABLE OF Rule_Set_Instance_Rec INDEX BY BINARY_INTEGER;

TYPE Members_Processed_Instance_Rec IS RECORD(Member_Object_ID DEF_OBJECT_ID%TYPE);
TYPE Members_Processed_Instance_Tab IS TABLE OF Members_Processed_Instance_Rec INDEX BY BINARY_INTEGER;

TYPE Valid_Invalid_Members_Inst_Rec IS RECORD(Folder_Name DEF_FOLDER_NAME%TYPE
					     ,Owning_RuleSet_Name DEF_OBJECT_DISPLAY_NAME%TYPE
                                             ,Object_Name DEF_OBJECT_DISPLAY_NAME%TYPE
					     ,Object_Type DEF_OBJECT_TYPE_CODE%TYPE
					     ,Object_ID	DEF_OBJECT_ID%TYPE
                                             ,Validation_Status VARCHAR2(12)
                                             ,Message_If_Invalid VARCHAR2(80));
TYPE Valid_Invalid_Members_Inst_Tab IS TABLE OF Valid_Invalid_Members_Inst_Rec INDEX BY BINARY_INTEGER;

TYPE Members_Validation_Status_Rec IS RECORD(Folder_Name DEF_FOLDER_NAME%TYPE
					    ,Owning_RuleSet_Name DEF_OBJECT_DISPLAY_NAME%TYPE
                                            ,Object_Name DEF_OBJECT_DISPLAY_NAME%TYPE
					    ,Object_Type DEF_OBJECT_TYPE_CODE%TYPE
					    ,Object_ID DEF_OBJECT_ID%TYPE
					    ,Valid_Member_Enabled_Status VARCHAR2(30)
					    ,Valid_Rule_Def_Status VARCHAR2(30)
					    ,Valid_Lock_Status	VARCHAR2(30)
					    ,Valid_Approval_Status VARCHAR2(30)
					    ,Valid_Dep_Obj_Status VARCHAR2(30)
					    ,Valid_Local_VS_Status VARCHAR2(30)
					    ,Other_Error_Status VARCHAR2(30)
					    );

TYPE Members_Validation_Status_Tab IS TABLE OF Members_Validation_Status_Rec INDEX BY BINARY_INTEGER;

-- CURRENT USE: used to track current ruleset being processed
TYPE Rule_Info IS RECORD(  Owning_RuleSet_Name DEF_OBJECT_DISPLAY_NAME%TYPE ,
                           Object_Name DEF_OBJECT_DISPLAY_NAME%TYPE         ,
					            Object_ID DEF_OBJECT_ID%TYPE                        );



TYPE Dependent_Objects_Rec IS RECORD(Parent_Object_ID DEF_OBJECT_ID%TYPE
				    ,Dependent_Object_ID DEF_OBJECT_ID%TYPE
		  		    ,Dependent_Object_Display_Name DEF_OBJECT_DISPLAY_NAME%TYPE
				    ,Dependent_Object_Folder_Name DEF_FOLDER_NAME%TYPE
				    ,Dependent_Object_Type_Code DEF_OBJECT_TYPE_CODE%TYPE
				    ,Status VARCHAR2(1)
				    ,Message_If_Invalid VARCHAR2(80));

TYPE Dependent_Objects_Tab IS TABLE OF Dependent_Objects_Rec INDEX BY BINARY_INTEGER;

cursor getValidDefForObject(p_Obj_Id IN DEF_OBJECT_ID%TYPE
                           ,p_Rule_Effective_Date IN DATE) IS
select
 a.object_definition_id
,a.approval_status_code
from
fem_object_definition_vl a
where
    a.object_id = p_Obj_ID
and p_Rule_Effective_Date >= a.EFFECTIVE_START_DATE
and p_Rule_Effective_Date <= nvl(a.EFFECTIVE_END_DATE,to_date('31/12/9999','DD/MM/YYYY'))
and a.OLD_APPROVED_COPY_FLAG = 'N';

Procedure Get_ValidDefinition_Pub(p_Object_ID IN DEF_OBJECT_ID%TYPE
				 ,p_Rule_Effective_Date IN VARCHAR2
				 ,x_Object_Definition_ID OUT NOCOPY FEM_OBJECT_DEFINITION_B.OBJECT_DEFINITION_ID%TYPE
				 ,x_Err_Code OUT NOCOPY NUMBER
			         ,x_Err_Msg  OUT NOCOPY VARCHAR2);

Procedure Validate_Rule_Public(x_Err_Code OUT NOCOPY NUMBER
                              ,x_Err_Msg  OUT NOCOPY VARCHAR2
			      ,p_Rule_Object_ID IN DEF_OBJECT_ID%TYPE
                              ,p_DS_IO_Def_ID IN DEF_OBJECT_DEFINITION_ID%TYPE
                              ,p_Rule_Effective_Date IN VARCHAR2
                              ,p_Reference_Period_ID IN NUMBER
                              ,p_Ledger_ID IN NUMBER);

Procedure Validate_Rule_Public(p_api_version IN NUMBER
                              ,p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
                              ,p_encoded IN VARCHAR2 := FND_API.G_TRUE
                              ,p_Rule_Object_ID IN DEF_OBJECT_ID%TYPE
                              ,p_DS_IO_Def_ID IN DEF_OBJECT_DEFINITION_ID%TYPE
                              ,p_Rule_Effective_Date IN VARCHAR2
                              ,p_Reference_Period_ID IN NUMBER
                              ,p_Ledger_ID IN NUMBER
                              ,x_return_status OUT NOCOPY VARCHAR2
                              ,x_msg_count OUT NOCOPY NUMBER
                              ,x_msg_data OUT NOCOPY VARCHAR2);

-- Being called from a concurrent program: "FEM: Validate Rule Set"
PROCEDURE Preprocess_RuleSet(x_Err_Code OUT NOCOPY NUMBER
                            ,x_Err_Msg OUT NOCOPY VARCHAR2
                            ,p_Orig_RuleSet_Object_ID IN DEF_OBJECT_ID%TYPE
                            ,p_DS_IO_Def_ID IN DEF_OBJECT_DEFINITION_ID%TYPE
                            ,p_Rule_Effective_Date IN VARCHAR2
                            ,p_Output_Period_ID IN NUMBER
                            ,p_Ledger_ID IN NUMBER
                            ,p_Continue_Process_On_Err_Flg IN VARCHAR2
                            ,p_Execution_Mode IN VARCHAR2);

PROCEDURE FEM_Preprocess_RuleSet_PVT(
                              p_api_version                 IN             NUMBER
                             ,p_init_msg_list               IN             VARCHAR2 := FND_API.G_FALSE
                             ,p_commit                      IN             VARCHAR2 := FND_API.G_FALSE
                             ,p_encoded                     IN             VARCHAR2 := FND_API.G_TRUE
                             ,x_return_status               OUT   NOCOPY   VARCHAR2
                             ,x_msg_count                   OUT   NOCOPY   NUMBER
                             ,x_msg_data                    OUT   NOCOPY   VARCHAR2
                             ,p_Orig_RuleSet_Object_ID      IN             DEF_OBJECT_ID%TYPE
                             ,p_DS_IO_Def_ID                IN             DEF_OBJECT_DEFINITION_ID%TYPE
                             ,p_Rule_Effective_Date         IN             VARCHAR2
                             ,p_Output_Period_ID            IN             NUMBER
                             ,p_Ledger_ID                   IN             NUMBER
                             ,p_Continue_Process_On_Err_Flg IN             VARCHAR2
                             ,p_Execution_Mode              IN             VARCHAR2
                             );

PROCEDURE FEM_DeleteFlatRuleList_PVT(
                              p_api_version                 IN             NUMBER
                             ,p_init_msg_list               IN             VARCHAR2 := FND_API.G_FALSE
                             ,p_commit                      IN             VARCHAR2 := FND_API.G_FALSE
                             ,p_encoded                     IN             VARCHAR2 := FND_API.G_TRUE
                             ,x_return_status               OUT   NOCOPY   VARCHAR2
                             ,x_msg_count                   OUT   NOCOPY   NUMBER
                             ,x_msg_data                    OUT   NOCOPY   VARCHAR2
                             ,p_RuleSet_Object_ID  IN             DEF_OBJECT_ID%TYPE
                             ) ;


end fem_rule_set_manager;

 

/
