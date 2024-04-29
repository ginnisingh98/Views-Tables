--------------------------------------------------------
--  DDL for Package AMW_CONTROLS_PAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_CONTROLS_PAGE_PKG" AUTHID CURRENT_USER as
/* $Header: amwcnpgs.pls 120.0 2005/05/31 20:17:18 appldev noship $ */
FUNCTION OBJECTIVE_PRESENT (P_CONTROL_REV_ID IN NUMBER,
		            P_OBJECTIVE_CODE IN VARCHAR2) RETURN VARCHAR2;

FUNCTION new_OBJECTIVE_PRESENT (P_CONTROL_REV_ID IN NUMBER,
		                        P_OBJECTIVE_CODE IN VARCHAR2) RETURN VARCHAR2;

-------------------------------------------------------------------------------------
FUNCTION preventive_control_PRESENT (P_CONTROL_REV_ID IN NUMBER)
		 RETURN VARCHAR2;

-------------------------------------------------------------------------------------
FUNCTION GET_OBJ (P_CONTROL_REV_ID IN NUMBER,P_TAG_NUM IN NUMBER)
		 RETURN VARCHAR2;

-------------------------------------------------------------------------------------
FUNCTION ASSERTION_PRESENT (P_CONTROL_REV_ID     IN NUMBER,
		            P_ASSERTION_CODE IN VARCHAR2) RETURN VARCHAR2;

-------------------------------------------------------------------------------------
FUNCTION new_ASSERTION_PRESENT (P_CONTROL_REV_ID     IN NUMBER,
		            P_ASSERTION_CODE IN VARCHAR2) RETURN VARCHAR2;

-------------------------------------------------------------------------------------
FUNCTION component_PRESENT (P_CONTROL_REV_ID     IN NUMBER,
		            	   	P_component_CODE 	 IN VARCHAR2) RETURN VARCHAR2;

-------------------------------------------------------------------------------------
FUNCTION new_component_PRESENT (P_CONTROL_REV_ID     IN NUMBER,
		            	   	P_component_CODE 	 IN VARCHAR2) RETURN VARCHAR2;

-------------------------------------------------------------------------------------------
FUNCTION GET_LOOKUP_VALUE(p_lookup_type  in  varchar2,
                          p_lookup_code  in varchar2) return varchar2;

-------------------------------------------------------------------------------------------
FUNCTION association_exists (P_process_objective_ID IN NUMBER) RETURN VARCHAR2;

------------------------------------------------------------------------------------------
FUNCTION GET_CONTROL_SOURCE (p_control_source_id   varchar2,
                             p_control_type        varchar2,
                             p_automation_type     varchar2,
                             p_application_id      number,
							 p_control_rev_id      number) return varchar2;

---------------------------------------------------------------------------------
PROCEDURE PROCESS_OBJECTIVE (p_init_msg_list       IN 		VARCHAR2   := FND_API.G_FALSE,
 			     p_commit              IN 		VARCHAR2   := FND_API.G_FALSE,
 			     p_validate_only       IN 		VARCHAR2   := FND_API.G_FALSE,
			     p_select_flag         IN           VARCHAR2,
                             p_control_rev_id 	   IN 	        NUMBER,
                             p_objective_code      IN           VARCHAR2,
                             x_return_status       OUT NOCOPY   VARCHAR2,
 			     x_msg_count           OUT NOCOPY 	NUMBER,
 			     x_msg_data            OUT NOCOPY 	VARCHAR2);
----------------------------------------------------------------------------------
PROCEDURE PROCESS_ASSERTION (p_init_msg_list      IN 		    VARCHAR2,
 			     			p_commit              IN 			VARCHAR2,
 			     			p_validate_only       IN 			VARCHAR2,
			     			p_select_flag         IN        	VARCHAR2,
                            p_control_rev_id 	  IN 	    	NUMBER,
                            p_assertion_code      IN        	VARCHAR2,
                            x_return_status       OUT NOCOPY   	VARCHAR2,
 			     			x_msg_count           OUT NOCOPY 	NUMBER,
 			     			x_msg_data            OUT NOCOPY 	VARCHAR2);

----------------------------------------------------------------------------------
PROCEDURE PROCESS_component (p_init_msg_list      IN 			VARCHAR2,
 			     			p_commit              IN 			VARCHAR2,
 			     			p_validate_only       IN 			VARCHAR2,
			     			p_select_flag         IN           	VARCHAR2,
                            p_control_rev_id 	  IN 	        NUMBER,
                            p_component_code      IN           	VARCHAR2,
                            x_return_status       OUT NOCOPY   	VARCHAR2,
 			     			x_msg_count           OUT NOCOPY 	NUMBER,
 			     			x_msg_data            OUT NOCOPY 	VARCHAR2);

----------------------------------------------------------------------------------
PROCEDURE delete_control_association (p_init_msg_list     		IN 			VARCHAR2,
		 			     			p_commit              		IN 			VARCHAR2,
		 			     			p_object_type         		IN 			VARCHAR2,
					     			p_risk_association_id 		IN 	        NUMBER,
									p_orig_control_id			in			number,
		                            x_return_status       		OUT NOCOPY  VARCHAR2,
		 			     			x_msg_count           		OUT NOCOPY 	NUMBER,
		 			     			x_msg_data            		OUT NOCOPY 	VARCHAR2);

----------------------------------------------------------------------------------
PROCEDURE delete_obj_assert_comp (p_init_msg_list     		IN 			VARCHAR2,
		 			     		  p_commit              	IN 			VARCHAR2,
		 			     		  p_control_rev_id			in			number,
		                          x_return_status       	OUT NOCOPY  VARCHAR2,
		 			     		  x_msg_count           	OUT NOCOPY 	NUMBER,
		 			     		  x_msg_data            	OUT NOCOPY 	VARCHAR2);

--npanandi 11.16.2004
--enhancement bugfix: 3391157
------------------------------------------------------------------------------------------------------------
FUNCTION IS_CONTROL_EFFECTIVE(
   P_ORGANIZATION_ID IN NUMBER
  ,P_CONTROL_ID IN NUMBER
) RETURN VARCHAR2;

--npanandi 11.19.2004
--enhancement TO DISPLAY POLICY FOR A CONTROL
------------------------------------------------------------------------------------------------------------
FUNCTION GET_POLICY(P_CONTROL_ID IN NUMBER) RETURN VARCHAR2;

--npanandi 11.19.2004
--enhancement TO ENABLE AUTO APPROVAL OF CTRL IF DISABLE WORKFLOW PROFILE
--OPTION IS SET TO YES
------------------------------------------------------------------------------------------------------------
PROCEDURE IS_WKFLW_APPR_DISBLD(
   P_CONTROL_REV_ID IN NUMBER
  ,P_PROFILE_OPTION OUT NOCOPY VARCHAR2
  ,p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE
  ,x_return_status  OUT NOCOPY   VARCHAR2
  ,x_msg_count      OUT NOCOPY 	NUMBER
  ,x_msg_data       OUT NOCOPY 	VARCHAR2
);

---------------------------------------------------------------------
----npanandi 12.02.2004: Added below function to get UnitOfMeasureTL
----given UoM_Code, and UoM_Class (from Profile Option)
---------------------------------------------------------------------
FUNCTION GET_UOM_TL(P_UOM_CODE IN VARCHAR2) RETURN VARCHAR2;

---------------------------------------------------------------------
----npanandi 12.03.2004: Added below function to check
----if this Ctrl contains this CtrlPurposeCode or not
---------------------------------------------------------------------
FUNCTION PURPOSE_PRESENT (
   P_CONTROL_REV_ID     IN NUMBER,
   P_PURPOSE_CODE 	IN VARCHAR2) RETURN VARCHAR2;

------------------------------------------------------------------------------------------------------------
FUNCTION NEW_PURPOSE_PRESENT (
   P_CONTROL_REV_ID     IN NUMBER,
   P_PURPOSE_CODE 	IN VARCHAR2) RETURN VARCHAR2;

---------------------------------------------------------------------
----npanandi 12.03.2004: Added below function to insert
----CtrlPurposeCode for this CtrlRevId
---------------------------------------------------------------------
PROCEDURE PROCESS_PURPOSE(
   p_init_msg_list       IN 		VARCHAR2,
   p_commit              IN 		VARCHAR2,
   p_validate_only       IN 		VARCHAR2,
   p_select_flag         IN           VARCHAR2,
   p_control_rev_id 	 IN 	        NUMBER,
   p_PURPOSE_code      	 IN           VARCHAR2,
   x_return_status       OUT NOCOPY   VARCHAR2,
   x_msg_count           OUT NOCOPY 	NUMBER,
   x_msg_data            OUT NOCOPY 	VARCHAR2);

---------------------------------------------------------------------
FUNCTION get_control_objective_rl(
            p_process_id in number,
            p_risk_id in number,
            p_control_id in number,
            p_rev in number) RETURN VARCHAR2;
---------------------------------------------------------------------

END  AMW_CONTROLS_PAGE_PKG;

 

/
