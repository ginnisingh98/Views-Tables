--------------------------------------------------------
--  DDL for Package PA_PLANNING_RESOURCE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PLANNING_RESOURCE_UTILS" AUTHID CURRENT_USER AS
/* $Header: PARPRLUS.pls 120.2 2006/02/22 16:28:46 ramurthy noship $*/

   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_date        DATE       := SYSDATE;
   g_creation_date           DATE       := SYSDATE;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;

  FUNCTION chk_spread_curve_in_use(p_spread_curve_id IN NUMBER) return BOOLEAN;

  FUNCTION chk_nlr_resource_exists(p_non_labor_resource IN Varchar2) return BOOLEAN;

/*************************************************************
 * Function : get_Res_member_code
 * **********************************************************/
FUNCTION Get_res_member_code(p_resource_list_member_id IN NUMBER)
return VARCHAR2;
/*************************************************************
 * Function : get_member_fin_cat_code
 * **********************************************************/
FUNCTION Get_member_fin_cat_code(p_resource_list_member_id IN NUMBER)
return VARCHAR2;
/*************************************************************
 * Function : get_member_incur_by_res_code
 * **********************************************************/
FUNCTION Get_member_incur_by_res_code(p_resource_list_member_id IN NUMBER)
return VARCHAR2;

/**************************************************************
 * FUNCTION : Get_res_type_code
 * ************************************************************/
 FUNCTION Get_res_type_code(p_res_format_id IN NUMBER)
 RETURN VARCHAR2;

/****************************************************************
 * Purpose of Get_Resource_Code Function is to return the resource code
 * for a given resource assignment.
 * ***************************************************************/
FUNCTION Get_resource_Code(p_resource_assignment_id IN NUMBER) return VARCHAR2;


/***************************************************************************
 * Purpose of Get_Incur_By_Res_Code Function is to return the Incur
 * by resource code for a given resource assignment.
 * **************************************************************/
FUNCTION Get_Incur_By_Res_Code(p_resource_assignment_id IN NUMBER) return VARCHAR2;

/*********************************************************************
 * Purpose of Get_Fin_Category_Code Function is to return the Financial
 * category code for a given resource assignment.
 * *******************************************************************/
FUNCTION Get_Fin_Category_Code(p_resource_assignment_id IN NUMBER) return VARCHAR2;


/******************************************************************
 * Purpose of the Validate_Organization procedure is to validate
 * organization for the planning resource.
 * **********************************************************/
PROCEDURE Validate_organization(
              p_organization_name	 IN 	       VARCHAR2,
              p_organization_id		 IN	       NUMBER,
              x_organization_id		 OUT NOCOPY    NUMBER,
              x_return_status		 OUT NOCOPY    VARCHAR2,
              x_error_msg_code           OUT NOCOPY    VARCHAR2);


/************************************************************************
 *   Procedure        : Check_SupplierName_Or_Id
 *   Description      : This Subprog validates the supplier name
 *                      and ID combination
 *********************************************************************/
PROCEDURE Check_SupplierName_Or_Id
            ( p_supplier_id            IN      	      NUMBER
             ,p_supplier_name          IN             VARCHAR2
             ,p_check_id_flag          IN             VARCHAR2
             ,x_supplier_id            OUT NOCOPY     NUMBER
             ,x_return_status          OUT NOCOPY     VARCHAR2
             ,x_error_msg_code         OUT NOCOPY     VARCHAR2 );

/****************************************************************
 * The purpose of the Validate_Supplier procedure is to validate the
 * supplier
 *****************************************************************/
PROCEDURE Validate_Supplier(
             p_resource_class_code  	IN	        VARCHAR2,
             p_person_id		IN		NUMBER,
             p_supplier_id		IN		NUMBER  DEFAULT NULL,
             p_supplier_name		IN		VARCHAR2  DEFAULT NULL,
             x_supplier_id		OUT NOCOPY	NUMBER,
             x_return_status		OUT NOCOPY	VARCHAR2,
             x_error_msg_code           OUT NOCOPY      VARCHAR2);
/*********************************************************
 * Procedure : Check_PersonName_or_ID
 * Description  : Used to validate the Person ID
 *                Name combination.
 ********************************************************/
PROCEDURE  Check_PersonName_or_ID(
               p_person_id      IN          VARCHAR2,
               p_person_name    IN          VARCHAR2,
               p_check_id_flag  IN          VARCHAR2,
               x_person_id      OUT NOCOPY  NUMBER,
               x_return_status  OUT NOCOPY  VARCHAR2,
               x_error_msg_code OUT NOCOPY  VARCHAR2);

/****************************************************
 * Procedure : Check_JobName_or_ID
 * Description  : Used to validate the Job ID
 *                Name combination.
 ****************************************************/
PROCEDURE  Check_JobName_or_ID(
               p_job_id  		IN          VARCHAR2,
               p_job_name  		IN          VARCHAR2,
               p_check_id_flag  	IN          VARCHAR2,
               x_job_id      		OUT NOCOPY  NUMBER,
               x_return_status  	OUT NOCOPY  VARCHAR2,
               x_error_msg_code 	OUT NOCOPY  VARCHAR2);
/******************************************************
 * Procedure : Check_BOM_EqLabor_or_ID
 * Description  : Used to validate the BOM ID
 *                Name combination.
 *******************************************************/
PROCEDURE Check_BOM_EqLabor_or_ID
              ( p_bom_eqlabor_id         IN              NUMBER
              , p_bom_eqlabor_name       IN              VARCHAR2
              , p_res_type_code          IN              VARCHAR2
              , p_check_id_flag          IN              VARCHAR2
              , x_bom_resource_id        OUT NOCOPY      NUMBER
              , x_return_status          OUT NOCOPY      VARCHAR2
              , x_error_msg_code     	 OUT NOCOPY      VARCHAR2 );

/******************************************************
 * Procedure : Check_ItemCat_or_ID
 * Description  : Used to validate the Item Category ID
 *                Category name combination.
 *******************************************************/
PROCEDURE Check_ItemCat_or_ID
          ( p_item_cat_id               IN        NUMBER
           ,p_item_cat_name             IN        VARCHAR2
           , P_item_category_set_id     IN        NUMBER
           , p_check_id_flag            IN        VARCHAR2
           , x_item_category_id         OUT NOCOPY       NUMBER
           , x_return_status            OUT NOCOPY       VARCHAR2
           , x_error_msg_code           OUT NOCOPY       VARCHAR2 );

/******************************************************
 * Procedure : Check_InventoryItem_or_ID
 * Description  : Used to validate the Inventory Item ID
 *                Inv Item name combination.
 *******************************************************/
PROCEDURE Check_InventoryItem_or_ID
          ( p_item_id                   IN        NUMBER
           ,p_item_name                 IN        VARCHAR2
           , P_item_master_id           IN        NUMBER
           , p_check_id_flag            IN        VARCHAR2
           , x_item_id                  OUT NOCOPY       NUMBER
           , x_return_status            OUT NOCOPY       VARCHAR2
           , x_error_msg_code           OUT NOCOPY       VARCHAR2 );
/*****************************************************
 * procedure : Validate_resource
 * *************************************************/
PROCEDURE Validate_Resource(
        p_resource_code         IN      VARCHAR2        DEFAULT NULL,
        p_resource_name         IN      VARCHAR2        DEFAULT NULL,
        p_resource_class_code   IN      VARCHAR2,
        p_res_type_code         IN      VARCHAR2        DEFAULT NULL,
        x_person_id             OUT NOCOPY     NUMBER,
        x_bom_resource_id       OUT NOCOPY     NUMBER,
        x_job_id                OUT NOCOPY     NUMBER,
        x_person_type_code      OUT NOCOPY     VARCHAR2,
        x_non_labor_resource    OUT NOCOPY     VARCHAR2,
        x_inventory_item_id     OUT NOCOPY     NUMBER,
        x_item_category_id      OUT NOCOPY     NUMBER,
        x_resource_class_code   OUT NOCOPY     VARCHAR2,
        x_resource_class_flag   OUT NOCOPY     VARCHAR2,
        x_return_status         OUT NOCOPY     VARCHAR2,
        x_error_msg_code        OUT NOCOPY     VARCHAR2);

/*******************************************************
 * Procedure : Default_expenditure_type
 ********************************************************/
PROCEDURE Default_expenditure_type;

/*******************************************************
 * Procedure : Default_rate_expenditure_type
 ********************************************************/
PROCEDURE Default_rate_expenditure_type;

/*******************************************************
 * Procedure : Default_Supplier
 * ****************************************************/
PROCEDURE Default_Supplier;

/*********************************************************
 * PROCEDURE  : default_job
 *******************************************************/
 PROCEDURE Default_job;

/**********************************************************
 * Procedure  : Default_Organization
 *********************************************************/
PROCEDURE Default_Organization(p_project_id IN PA_PROJECTS_ALL.PROJECT_ID%TYPE);

/*******************************************************************
 * Procedure : Default_rate_based
 * *****************************************************************/
PROCEDURE Default_rate_based;

/*******************************************************************
 * Procedure : Default_ou
 ******************************************************************/
PROCEDURE Default_ou(p_project_id IN PA_PROJECTS_ALL.PROJECT_ID%TYPE);

/*******************************************************************
 * Procedure : Default_currency_code
 ******************************************************************/
PROCEDURE Default_currency_code;

/*******************************************************************
 * Procedure : Default_UOM
 ******************************************************************/
PROCEDURE Default_UOM;

/********************************************************************
 * Procedure  : get_resource_defaults
 * *****************************************************************/
PROCEDURE get_resource_defaults (
P_resource_list_members         IN              SYSTEM.PA_NUM_TBL_TYPE,
P_project_id			IN 	        PA_PROJECTS_ALL.PROJECT_ID%TYPE,
X_resource_class_flag		OUT NOCOPY	SYSTEM.PA_VARCHAR2_1_TBL_TYPE,
X_resource_class_code		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_resource_class_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_res_type_code			OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_incur_by_res_type		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_person_id			OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_job_id			OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_person_type_code		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_named_role			OUT NOCOPY	SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
X_bom_resource_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_non_labor_resource		OUT NOCOPY	SYSTEM.PA_VARCHAR2_20_TBL_TYPE,
X_inventory_item_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_item_category_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_project_role_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_organization_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_fc_res_type_code		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_expenditure_type		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_expenditure_category		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_event_type			OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_revenue_category_code		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_supplier_id			OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_spread_curve_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_etc_method_code		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_mfc_cost_type_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_incurred_by_res_flag		OUT NOCOPY	SYSTEM.PA_VARCHAR2_1_TBL_TYPE,
X_incur_by_res_class_code	OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_incur_by_role_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_unit_of_measure		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_org_id			OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_rate_based_flag		OUT NOCOPY	SYSTEM.PA_VARCHAR2_1_TBL_TYPE,
X_rate_expenditure_type		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_rate_func_curr_code		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_msg_data			OUT NOCOPY	VARCHAR2,
X_msg_count			OUT NOCOPY	NUMBER,
X_return_status			OUT NOCOPY	VARCHAR2);

--Eugenes proc and Funcs
/*****************************************************************
* Type (Procedure or Procedure): Function
 * Package Object Name         : Ret_Resource_Name
 * Purpose                     : Return the resource name from a given
 *                               resource type code and id.
 * Public or Private API?
 *           		    Public
 ******************************************************************/
  Function Ret_Resource_Name ( P_Res_Type_Code            IN Varchar2,
			       P_Person_Id                IN Number,
			       P_Bom_Resource_Id          IN Number,
    			       P_Job_Id        	     	  IN Number,
			       P_Person_Type_Code         IN Varchar2,
			       P_Non_Labor_Resource       IN Varchar2,
			       P_Inventory_Item_Id        IN Number,
			       P_Resource_Class_Id        IN Number,
			       P_Item_Category_Id         IN Number,
                               p_res_assignment_id       IN NUMBER DEFAULT NULL)
Return VARCHAR2;

/**********************************************************************
 *Type (Procedure or Procedure): Procedure
 *Package Object Name:           Get_Resource_Name
 *Purpose:                       Return the resource name from a given
 *               		 resource type code/id.
 *Public or Private API?         Public
 *Note: The parameter P_Proc_Func_Flag indicates where
 *      this procedure is being called from a procedure
 *      or a function.  If called from a function then no data
 *      found will be supressed and the id/code is null will not get
 *      and raise exception and returns null for displayed parameter.  All
 *      other errors will be raise;
 *      If called form a procedure then
 *      raise exception on no data found and when needed id/code is null.
************************************************************/
Procedure Get_Resource_Name ( P_Res_Type_Code           IN Varchar2,
			        P_Person_Id               IN Number,
			        P_Bom_Resource_Id         IN Number,
    			        P_Job_Id                  IN Number,
			        P_Person_Type_Code        IN Varchar2,
			        P_Non_Labor_Resource      IN Varchar2,
			        P_Inventory_Item_Id       IN Number,
			        P_Item_Category_Id        IN Number,
				P_Resource_Class_Id       IN Number,
				P_Proc_Func_Flag          IN Varchar2,
                               p_res_assignment_id       IN NUMBER DEFAULT NULL,
				X_Resource_Displayed      OUT NOCOPY Varchar2,
		 		X_Return_Status           OUT NOCOPY Varchar2,
				X_Msg_Data    	           OUT NOCOPY Varchar2
                                );

/***********************************************************************
*Type (Procedure or Procedure): Function
*Package Object Name:           Ret_Fin_Category_Name
*Purpose:                       Return the resource name from a given
*        			  resource type code.
*Public or Private API?
*          				     Public
***************************************************************/
  Function Ret_Fin_Category_Name ( P_FC_Res_Type_Code      IN Varchar2,
			           P_Expenditure_Type      IN Varchar2,
			           P_Expenditure_Category  IN Varchar2,
			           P_Event_Type            IN Varchar2,
		                   P_Revenue_Category_Code IN Varchar2,
                                   p_res_assignment_id   IN NUMBER default null
) Return varchar2;

/******************************************************************
 *Type (Procedure or Procedure): Procedure
 *Package Object Name:           Get_Fin_Category_Name
 *Purpose:                       Return the resource name from a given
 *    				  resource type code.
 ********************************************************************/
  Procedure Get_Fin_Category_Name ( P_FC_Res_Type_Code      IN Varchar2,
			            P_Expenditure_Type      IN Varchar2,
			            P_Expenditure_Category  IN Varchar2,
			            P_Event_Type            IN Varchar2,
			            P_Revenue_Category_Code IN Varchar2,
			            P_Proc_Func_Flag        IN Varchar2,
			            p_res_assignment_id IN NUMBER default null,
                                    X_Fin_Cat_Displayed    OUT NOCOPY Varchar2,
		 	            X_Return_Status        OUT NOCOPY Varchar2,
			            X_Msg_Data    	   OUT NOCOPY Varchar2
                                  );

/***********************************************************************
 * Function : ret_Organization_Name
 * *******************************************************************/
Function Ret_Organization_Name ( P_Organization_Id IN Number ) Return Varchar2;

/******************************************************************
 * Procedure : Get_Organization_Name
 * ************************************************************/
Procedure Get_Organization_Name ( P_Organization_Id IN Number,
				    P_Proc_Func_Flag  IN Varchar2,
				    X_Org_Displayed  OUT NOCOPY Varchar2,
		 		    X_Return_Status  OUT NOCOPY Varchar2,
				    X_Msg_Data       OUT NOCOPY Varchar2 );

/*****************************************************************
 * Function : Ret_Supplier_Name
 * **************************************************************/
Function Ret_Supplier_Name ( P_Supplier_Id         IN Number ) Return Varchar2;

/**************************************************************
 * Procedure : Get_Supplier_Name
 * **********************************************************/
Procedure Get_Supplier_Name ( P_Supplier_Id         IN Number,
				P_Proc_Func_Flag      IN Varchar2,
				X_Supplier_Displayed OUT NOCOPY Varchar2,
		 		X_Return_Status      OUT NOCOPY Varchar2,
				X_Msg_Data    	      OUT NOCOPY Varchar2 );
/****************************************************************
 * Function : Ret_role_name
 * *************************************************************/
  Function Ret_Role_Name ( P_Role_Id         IN Number ) Return Varchar2;

/*************************************************************
 * Procedure : Get_Role_Name
 * ***********************************************************/
 Procedure Get_Role_Name ( P_Role_Id         IN Number,
			    P_Proc_Func_Flag  IN Varchar2,
			    X_Role_Displayed OUT NOCOPY Varchar2,
		 	    X_Return_Status  OUT NOCOPY Varchar2,
			    X_Msg_Data       OUT NOCOPY Varchar2 );

/************************************************************
 * Function : Ret_Incur_By_Res_Name
 * *********************************************************/
Function Ret_Incur_By_Res_Name ( P_Person_Id 	           IN Number,
			           P_Job_Id    	           IN Number,
			           P_Incur_By_Role_Id      IN Number,
			           P_Person_Type_Code      IN Varchar2,
			           P_Inc_By_Res_Class_Code IN Varchar2,
                                  p_res_assignment_id IN NUMBER default null)
Return varchar2;

/*************************************************************
 * Procedure : Get_Incur_By_Res_Name
 * ***********************************************************/
Procedure Get_Incur_By_Res_Name ( P_Person_Id 	    IN Number,
			            P_Job_Id   	            IN Number,
			            P_Incur_By_Role_Id      IN Number,
			            P_Person_Type_Code      IN Varchar2,
			            P_Inc_By_Res_Class_Code IN Varchar2,
			            P_Proc_Func_Flag        IN Varchar2,
                               p_res_assignment_id    IN NUMBER default null,
			            X_Inc_By_Displayed     OUT NOCOPY Varchar2,
		 	            X_Return_Status        OUT NOCOPY Varchar2,
			            X_Msg_Data    	   OUT NOCOPY Varchar2
                                );


/************************************************************
 * Procedure : Get_Plan_Res_Combination
 * *********************************************************/
  Procedure Get_Plan_Res_Combination(
		P_Resource_List_Member_Id IN  Number,
		X_Resource_Alias         OUT NOCOPY Varchar2,
 		X_Plan_Res_Combination   OUT NOCOPY Varchar2,
		X_Return_Status          OUT NOCOPY Varchar2,
		X_Msg_Count              OUT NOCOPY Number,
		X_Msg_Data               OUT NOCOPY Varchar2);

/*****************************************************************
 * Function : Get_plan_res_combination
 * ************************************************************/
FUNCTION Get_plan_res_combination( p_resource_list_member_id  IN  NUMBER) return
VARCHAR2;

/**************************************************************
 * Procedure : Validate_fin_category
 * ************************************************************/
  Procedure Validate_Fin_Category(
		P_FC_Res_Type_Code	IN  Varchar2,
		P_Resource_Class_Code	IN  Varchar2,
		P_Fin_Category_Name	IN  Varchar2,
		P_migration_code   	IN  Varchar2,
		X_Expenditure_Type	OUT NOCOPY Varchar2,
		x_Expenditure_Category 	OUT NOCOPY Varchar2,
		X_Event_Type		OUT NOCOPY Varchar2,
		X_Revenue_Category	OUT NOCOPY Varchar2,
		X_Return_Status		OUT NOCOPY Varchar2,
		X_Error_Message_Code	OUT NOCOPY Varchar2);

/***************************************************************
 * Procedure : Validate_Incur_by_resource
 * ***********************************************************/
 Procedure Validate_Incur_by_Resource(
		P_Resource_Class_Code	  IN  Varchar2,
		P_Res_Type_Code		  IN  Varchar2	Default Null,
		P_Incur_By_Res_Code	  IN  varchar2	Default Null,
		X_Person_Id		  OUT NOCOPY Number,
		X_Incur_By_Role_Id	  OUT NOCOPY Number,
		X_Job_Id		  OUT NOCOPY Number,
		X_Person_Type_Code	  OUT NOCOPY varchar2,
		X_Incur_By_Res_Class_Code OUT NOCOPY varchar2,
		X_Return_Status		  OUT NOCOPY Varchar2,
		X_Error_Message_Code	  OUT NOCOPY Varchar2);

/**************************************************************
 * Procedure : Validate_Planning_Resource
 * ************************************************************/
 Procedure Validate_Planning_Resource(
		P_Task_Name		  IN  VARCHAR2 	Default Null,
		P_Task_Number		  IN  Varchar2 	Default Null,
		P_Planning_Resource_Alias IN  Varchar2 	Default Null,
		P_Resource_List_Member_Id IN  Number 	Default Null,
		P_Resource_List_Id        IN  Number 	Default Null,
		P_Res_Format_Id		  IN  Number 	Default Null,
		P_Resource_Class_Code	  IN  Varchar2,
		P_Res_Type_Code		  IN  Varchar2 	Default Null,
		P_Resource_Code		  IN  Varchar2 	Default Null,
		P_Resource_Name		  IN  Varchar2 	Default Null,
		P_Project_Role_Id	  IN  Number 	Default Null,
		P_Project_Role_Name	  IN  Varchar2 	Default Null,
		P_Team_role	          IN  Varchar2 	Default Null,
		P_Organization_Id	  IN  Number 	Default Null,
		P_Organization_Name	  IN  Varchar2 	Default Null,
		P_FC_Res_Type_Code	  IN  Varchar2 	Default Null,
		P_Fin_Category_Name	  IN  Varchar2 	Default Null,
		P_Supplier_Id		  IN  Number 	Default Null,
		P_Supplier_Name		  IN  Varchar2 	Default Null,
		P_Incur_By_Resource_Code  IN  varchar2 	Default Null,
		P_Incur_By_resource_Type  IN  Varchar2 	Default Null,
		X_Resource_List_Member_Id OUT NOCOPY Number,
		X_Person_Id		  OUT NOCOPY Number,
		X_Bom_Resource_Id	  OUT NOCOPY Number,
		X_Job_Id		  OUT NOCOPY Number,
		X_Person_Type_Code	  OUT NOCOPY varchar2,
		X_Non_Labor_Resource	  OUT NOCOPY varchar2,
		X_Inventory_Item_Id	  OUT NOCOPY Number,
		X_Item_Category_Id	  OUT NOCOPY Number,
		X_Project_Role_Id	  OUT NOCOPY Number,
		X_team_role      	  OUT NOCOPY Varchar2,
		X_Organization_Id	  OUT NOCOPY Number,
		X_Expenditure_Type	  OUT NOCOPY Varchar2,
		X_Expenditure_Category	  OUT NOCOPY Varchar2,
		X_Event_Type		  OUT NOCOPY Varchar2,
		X_Revenue_Category_Code	  OUT NOCOPY Varchar2,
		X_Supplier_Id		  OUT NOCOPY Number,
		X_Resource_Class_Id	  OUT NOCOPY Number,
                X_resource_class_flag     OUT NOCOPY varchar2,
		X_Incur_By_Role_Id	  OUT NOCOPY Number,
		X_Incur_By_res_Class_Code OUT NOCOPY varchar2,
		X_Incur_By_Res_Flag	  OUT NOCOPY varchar2,
		X_Return_Status		  OUT NOCOPY Varchar2,
		X_Msg_Data		  OUT NOCOPY Varchar2,
		X_Msg_Count		  OUT NOCOPY Number);


  /* -----------------------------------------------------------------------
   Type (Procedure or Procedure): Procedure
   Package Object Name:           Get_Resource_Cost_Rate
   Purpose:                       Return the resource raw/burden rate and the
                                  currency values.
   Public or Private API?         Public

   ------------------------------------------------------------------------- */
Procedure Get_Resource_Cost_Rate
(P_eligible_rlm_id_tbl        IN SYSTEM.PA_NUM_TBL_TYPE
  ,P_project_id               IN pa_projects_all.project_id%type
  ,p_structure_type           IN VARCHAR2
  ,p_fin_plan_type_id         IN NUMBER  DEFAULT NULL
  ,P_resource_curr_code_tbl   OUT NOCOPY SYSTEM.PA_VARCHAR2_15_TBL_TYPE
  ,P_resource_raw_rate_tbl    OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
  ,P_resource_burden_rate_tbl OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
                       ) ;

  Function Derive_Resource_List_Member
    (p_project_id                IN     NUMBER,
     p_res_format_id             IN     NUMBER,
     p_person_id                 IN     NUMBER     DEFAULT NULL,
     p_job_id                    IN     NUMBER     DEFAULT NULL,
     p_organization_id           IN     NUMBER     DEFAULT NULL,
     p_expenditure_type          IN     Varchar2   DEFAULT NULL,
     p_expenditure_category      IN     Varchar2   DEFAULT NULL,
     p_project_role_id           IN     Number     DEFAULT NULL,
     p_person_type_code          IN     Varchar2   DEFAULT NULL,
     p_named_role                IN     Varchar2   DEFAULT NULL)
    RETURN NUMBER;

  Procedure Get_Res_Format_For_Team_Role
    (p_resource_list_id     IN          NUMBER,
     x_asgmt_res_format_id  OUT NOCOPY  NUMBER,
     x_req_res_format_id    OUT NOCOPY  NUMBER,
     x_return_status        OUT NOCOPY  Varchar2);


/* ----------------------------------------------------------------
 * API for populating a resource list into the new TL tables. This API
 * is called by the resource list upgrade concurrent program.
 * ----------------------------------------------------------------*/
PROCEDURE Populate_list_into_tl(
  p_resource_list_id   IN         NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY VARCHAR2,
  x_msg_data           OUT NOCOPY VARCHAR2 );

/*******************************************************************
 * Procedure : Delete_proj_specific_resource
 * Desc      : This API is used to delete the project specific resources
 *             once the project is deleted.
 *******************************************************************/
 PROCEDURE Delete_Proj_Specific_Resource(
   p_project_id         IN         NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER);

/*****************************************************************
 * Function : Get_class_member_id
 * Given a resource list, project and resource class, this function
 * returns the class level resource list member for that class, for
 * both centrally and non-centrally controlled resource lists.
 * ************************************************************/
FUNCTION Get_class_member_id(p_project_id          IN NUMBER,
                             p_resource_list_id    IN NUMBER,
                             p_resource_class_code IN VARCHAR2) return NUMBER;

/*****************************************************************
 *  Function : get_rate_based_flag
 *  Given a resource list member, this function returns a flag
 *  to indicate whether the list member is rate based or not.
 *  ************************************************************/
FUNCTION Get_rate_based_flag(p_resource_list_member_id IN NUMBER) return VARCHAR2;

/*****************************************************************
 * Function : check_enable_allowed
 * Given a disabled resource list member, this function checks to see if
 * enabling it is allowed - meaning that it won't result in a duplicate
 * resource list member.  Hence it checks to see if there are any enabled
 * list members with the same format and attributes.  Returns Y if the
 * given list member is unique; and N if not.
 * ************************************************************/

FUNCTION check_enable_allowed(p_resource_list_member_id    IN NUMBER)
                              return VARCHAR2;

/*****************************************************************
 * Procedure : check_list_member_on_list
 * Given a resource list member and a resource list, this procedure checks
 * to see if the list member is on the list (looking at the project specific
 * case as well) and returns an error message if it isn't.
 * If p_chk_enabled is passed in as 'Y', an additional check is done
 * to see whether the list member is enabled or not.
 * ************************************************************/
PROCEDURE check_list_member_on_list(
  p_resource_list_id          IN NUMBER,
  p_resource_list_member_id   IN NUMBER,
  p_project_id                IN NUMBER,
  p_chk_enabled               IN VARCHAR2 DEFAULT 'N',
  p_alias                     IN VARCHAR2 DEFAULT NULL,
  x_resource_list_member_id   OUT NOCOPY NUMBER,
  x_valid_member_flag         OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY VARCHAR2,
  x_msg_data                  OUT NOCOPY VARCHAR2 );

/********************************************************************
 * Procedure  : default_other_elements
 * This procedure derives other segments for a planning resource, based
 * on the resource format, if it is possible to derive anything.  For
 * example, if the format provided is Named Person - Organization, and
 * the person ID or name is specified, the person's HR Organization is derived
 * and passed back as X_organization_id and X_organization_name.  Please
 * see the functional design for all the values that can be derived.
 * *****************************************************************/
PROCEDURE default_other_elements (
P_res_format_id          IN             NUMBER,
P_person_id              IN             NUMBER    DEFAULT NULL,
P_person_name            IN             VARCHAR2  DEFAULT NULL,
p_bom_resource_id        IN             NUMBER    DEFAULT NULL,
p_bom_resource_name      IN             VARCHAR2  DEFAULT NULL,
p_non_labor_resource     IN             VARCHAR2  DEFAULT NULL,
X_organization_id	 OUT NOCOPY	NUMBER,
x_organization_name      OUT NOCOPY     VARCHAR2,
X_expenditure_type	 OUT NOCOPY	VARCHAR2,
X_msg_data		 OUT NOCOPY	VARCHAR2,
X_msg_count		 OUT NOCOPY	NUMBER,
X_return_status		 OUT NOCOPY	VARCHAR2);

END PA_PLANNING_RESOURCE_UTILS;

 

/
