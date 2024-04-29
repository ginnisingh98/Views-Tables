--------------------------------------------------------
--  DDL for Package JTF_RESOURCE_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RESOURCE_UTL" AUTHID CURRENT_USER AS
  /* $Header: jtfrspus.pls 120.3 2005/10/17 17:15:59 nsinghai ship $ */

  /*****************************************************************************************
   This package provides the common routines that are called from the resource module
   functions.
   Its main functions and procedures are as following:
   Function_Created_By
   Function_Updated_By
   Function_Login_Id
   Validate_Resource_Group
   Validate_Resource_Number
   Validate_Input_Dates
   Validate_Usage
   Validate_Resource_Category
   Validate_Employee_Resource
   Validate_Time_Zone
   Validate_NLS_Language
   Validate_Support_Site_id
   Validate_Server_Group
   Validate_Currency_Code
   Validate_Hold_Reason_Code
   Validate_Resource_Team
   Validate_User_Id
   Validate_Salesrep_Id
   Validate_Territory_Id
   Validate_Sales_Credit_Type
   Validate_Salesrep_Number
   Check_Object_Existence
   validate_resource_param_value_id
   validate_rs_value_type
   validate_resource_value
   validate_resource_role
   validate_rs_role_flags
   Call_internal_hook
   Validate_Salesrep_dates
   ******************************************************************************************/

  --Global variable Just used for Migration Starts
  G_SOURCE_NAME VARCHAR2(2000);
  --Global variable Just used for Migration Ends

  /* Functions to get the Who columns. */

  FUNCTION created_by
    RETURN NUMBER;

  FUNCTION updated_by
    RETURN NUMBER;

  FUNCTION login_id
    RETURN NUMBER;

  /* Procedure to call internal user hook. */

   PROCEDURE call_internal_hook
    (p_package_name	IN 	VARCHAR2,
     p_api_name 	IN 	VARCHAR2,
     p_processing_type 	IN 	VARCHAR2,
     x_return_status 	OUT NOCOPY	VARCHAR2
   );

  /* Procedure to validate the resource group. */

  PROCEDURE  validate_resource_group
  (p_group_id             IN   NUMBER,
   p_group_number         IN   VARCHAR2,
   x_return_status        OUT NOCOPY  VARCHAR2,
   x_group_id             OUT NOCOPY  NUMBER
  );


  /* Procedure to validate the resource number. */

  PROCEDURE  validate_resource_number
  (p_resource_id          IN   NUMBER,
   p_resource_number      IN   NUMBER,
   x_return_status        OUT NOCOPY  VARCHAR2,
   x_resource_id          OUT NOCOPY  NUMBER
  );


  /* Procedure to validate the resource number. */

  PROCEDURE  validate_input_dates
  (p_start_date_active    IN   DATE,
   p_end_date_active      IN   DATE,
   x_return_status        OUT NOCOPY VARCHAR2
  );


  /* Procedure to validate the usage. */

  PROCEDURE  validate_usage
  (p_usage                IN   VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2
  );


  /* Procedure to validate the resource category. */

  PROCEDURE  validate_resource_category
  (p_category             IN   VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2
  );


 /* Procedure to validate the source id. */

  PROCEDURE  validate_source_id
  (p_category             IN   VARCHAR2,
   p_source_id		  IN   NUMBER,
   p_address_id		  IN   NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2
  );


  /* Procedure to validate the Employee Resource */

  PROCEDURE  validate_employee_resource
  (p_emp_resource_id      IN   NUMBER,
   p_emp_resource_number  IN   NUMBER,
   x_return_status        OUT NOCOPY  VARCHAR2,
   x_emp_resource_id      OUT NOCOPY  NUMBER
  );


  /* Procedure to validate the Time Zone. */

  PROCEDURE  validate_time_zone
  (p_time_zone_id         IN   NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2
  );


  /* Procedure to validate the Language. */

  PROCEDURE  validate_nls_language
  (p_nls_language         IN   VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2
  );


  /* Procedure to validate the Support Site. */

  PROCEDURE  validate_support_site_id
  (p_support_site_id      IN   NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2
  );


  /* Validate the Server Group */

  PROCEDURE  validate_server_group
  (p_server_group_id        IN    NUMBER,
   p_server_group_name      IN    VARCHAR2,
   x_return_status          OUT NOCOPY   VARCHAR2,
   x_server_group_id        OUT NOCOPY   NUMBER
  );


  /* Procedure to validate the Currency Code. */

  PROCEDURE  validate_currency_code
  (p_currency_code        IN   VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2
  );


  /* Procedure to validate the Hold Reason Code. */

  PROCEDURE  validate_hold_reason_code
  (p_hold_reason_code     IN   VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2
  );


  /* Procedure to validate the Resource Team. */

  PROCEDURE  validate_resource_team
  (p_team_id              IN   NUMBER,
   p_team_number          IN   VARCHAR2,
   x_return_status        OUT NOCOPY  VARCHAR2,
   x_team_id              OUT NOCOPY  NUMBER
  );


  /* Procedure to validate the User Id. */

  PROCEDURE  validate_user_id
  (p_user_id              IN   NUMBER,
   p_category             IN   VARCHAR2,
   p_source_id            IN   NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2
  );


  PROCEDURE validate_salesrep_id
   (P_SALESREP_ID		IN 	NUMBER,
    P_ORG_ID		        IN 	NUMBER,
    X_RETURN_STATUS		OUT NOCOPY	VARCHAR2
  );

  PROCEDURE validate_salesrep_dates
  (P_ID               IN   VARCHAR2,
   P_ORG_ID		      IN   NUMBER,
   P_SRP_START_DATE   IN   DATE,
   P_SRP_END_DATE     IN   DATE,
   P_CR_UPD_MODE      IN   VARCHAR2,
   X_RETURN_STATUS    OUT NOCOPY VARCHAR2
  );

  PROCEDURE validate_territory_id
  (P_TERRITORY_ID		IN      NUMBER,
   X_RETURN_STATUS		OUT NOCOPY    VARCHAR2
  );


  PROCEDURE validate_sales_credit_type
  (P_SALES_CREDIT_TYPE_ID     IN   NUMBER,
   X_RETURN_STATUS            OUT NOCOPY VARCHAR2
  );


  PROCEDURE validate_salesrep_number
  (P_SALESREP_NUMBER      IN   VARCHAR2,
   P_ORG_ID		  IN      NUMBER,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  );


  PROCEDURE check_object_existence
  (P_OBJECT_CODE	IN   JTF_OBJECTS_B.OBJECT_CODE%TYPE,
   P_SELECT_ID		IN   VARCHAR2,
   P_OBJECT_USER_CODE   IN   VARCHAR2,
   X_FOUND		OUT NOCOPY BOOLEAN ,
   X_RETURN_STATUS      OUT NOCOPY VARCHAR2
  );


  PROCEDURE check_object_existence_migr
  (P_OBJECT_CODE        IN   JTF_OBJECTS_B.OBJECT_CODE%TYPE,
   P_SELECT_ID          IN   VARCHAR2,
   P_OBJECT_USER_CODE   IN   VARCHAR2,
   P_RS_ID_PUB_FLAG     IN   VARCHAR2,
   X_FOUND              OUT NOCOPY  BOOLEAN ,
   X_RETURN_STATUS      OUT NOCOPY  VARCHAR2
  );


  /* Procedure to validate resource param id. */

  PROCEDURE  validate_resource_param_id
  (p_resource_param_id      IN   NUMBER,
   x_return_status      	   OUT NOCOPY VARCHAR2
  );

  /* Procedure to validate resource value type. */

  PROCEDURE  validate_rs_value_type
  (p_resource_param_id     IN   JTF_RS_RESOURCE_VALUES.RESOURCE_PARAM_ID%TYPE,
   p_value_type            IN   JTF_RS_RESOURCE_VALUES.VALUE_TYPE%TYPE,
   x_return_status         OUT NOCOPY VARCHAR2
  );

  /* Procedure to validate resource value. */

  PROCEDURE  validate_resource_value
  (p_resource_param_id     IN   JTF_RS_RESOURCE_VALUES.RESOURCE_PARAM_ID%TYPE,
   p_value                 IN   JTF_RS_RESOURCE_VALUES.VALUE%TYPE,
   x_return_status         OUT NOCOPY VARCHAR2
  );

  /* Procedure to validate resource role. */

  PROCEDURE  validate_resource_role
  (p_role_id		       IN   	JTF_RS_ROLES_B.ROLE_ID%TYPE,
   p_role_code		       IN   	JTF_RS_ROLES_B.ROLE_CODE%TYPE,
   x_return_status             OUT NOCOPY  	VARCHAR2,
   x_role_id		       OUT NOCOPY 	JTF_RS_ROLES_B.ROLE_ID%TYPE
  );

  /*Procedure to validate resource role flags. */

   PROCEDURE  validate_rs_role_flags
   (p_rs_role_flag        IN      VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2
   );

   /*Function  : get_g_miss_char. */

   FUNCTION get_g_miss_num RETURN NUMBER;

   /*Function  : get_g_miss_char. */

   FUNCTION get_g_miss_char RETURN VARCHAR2;

   /*Function  : get_g_miss_date. */

   FUNCTION get_g_miss_date RETURN DATE;

  /* Function to check for user hooks execution flag */

    Function	Ok_To_Execute(	p_Pkg_name		varchar2,
				p_API_name		varchar2,
				p_Process_type		varchar2,
				p_User_hook_type	varchar2
  ) Return Boolean ;


  /* Function to check for access to XMLGEN and valid status of JTF_USR_HKS*/
-- The below function will not be called from any API's.
-- Removing as a part of fixing GSCC errors in R12
-- Right now it is only called from jtfrsvrb.pls
--    Function  check_access( x_Pkg_name		out NOCOPY varchar2
--                          ) Return Boolean ;

    Function get_inventory_org_id return number;

END jtf_resource_utl;

 

/
