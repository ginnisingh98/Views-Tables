--------------------------------------------------------
--  DDL for Package PA_WBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_WBS_PKG" AUTHID CURRENT_USER as
 -- $Header: PAXWBSS.pls 115.0 99/07/16 15:38:26 porting ship $
--==============================================================

--
-- Define Global Variables, Functions and Procedure
--

-- Define Global Variables

	TYPE GlobalVars IS RECORD
	(	  project_id                    NUMBER(15)
		, task_number                   VARCHAR2(25)
		, task_name                     VARCHAR2(20)
		, carrying_out_organization_id  NUMBER(15)
		, service_type_code             VARCHAR2(30)
		, task_manager_person_id        NUMBER(9)
		, wbs_level                     NUMBER(3)
		, chargeable_flag               VARCHAR2(1)
		, billable_flag                 VARCHAR2(1)
                , pm_product_code               VARCHAR2(30)
                , pm_task_reference             VARCHAR2(25)
	);

GlobVars	GlobalVars;

--
------------------------------------------------------------------------------------------
-- Define Functions and Procedures
------------------------------------------------------------------------------------------
--

--  Derive Project_id
	FUNCTION Get_Project_id RETURN NUMBER;
	pragma RESTRICT_REFERENCES  ( Get_Project_id, WNDS, WNPS );

        PROCEDURE Set_Project_id ( x_project_id IN NUMBER);

--  Derive Task Number
	FUNCTION Get_Task_Number RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  ( Get_Task_Number, WNDS, WNPS );

        PROCEDURE Set_Task_Number ( x_task_number IN VARCHAR2);

--  Derive Task Name
	FUNCTION Get_Task_Name RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  ( Get_Task_Name, WNDS, WNPS );

        PROCEDURE Set_Task_Name ( x_task_name IN VARCHAR2);

--  Derive Organization_id
	FUNCTION Get_Organization_id RETURN NUMBER;
	pragma RESTRICT_REFERENCES  ( Get_Organization_id, WNDS, WNPS );

        PROCEDURE Set_Organization_id ( x_carrying_out_organization_id IN NUMBER);

--  Derive Service Code
	FUNCTION Get_Service_Code RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  ( Get_Service_Code, WNDS, WNPS );

        PROCEDURE Set_Service_Code ( x_service_type_code IN VARCHAR2);

--  Derive Manager_id
	FUNCTION Get_Manager_id RETURN NUMBER;
	pragma RESTRICT_REFERENCES  ( Get_Manager_id, WNDS, WNPS );

        PROCEDURE Set_Manager_id ( x_task_manager_person_id IN NUMBER);

--  Derive WBS Level
	FUNCTION Get_wbs_level RETURN NUMBER;
	pragma RESTRICT_REFERENCES  ( Get_wbs_level, WNDS, WNPS );

        PROCEDURE Set_wbs_level ( x_wbs_level IN NUMBER);

--  Derive Chargeable flag
	FUNCTION Get_Chargeable_flag RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  ( Get_Chargeable_flag, WNDS, WNPS );

        PROCEDURE Set_Chargeable_flag ( x_chargeable_flag IN VARCHAR2);

--  Derive Billable flag
	FUNCTION Get_Billable_flag RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  ( Get_Billable_flag, WNDS, WNPS );

        PROCEDURE Set_Billable_flag ( x_billable_flag IN VARCHAR2);

--  Derive PM Product Code
	FUNCTION Get_Product_Code RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  ( Get_Product_Code, WNDS, WNPS );

        PROCEDURE Set_Product_Code ( x_product_code IN VARCHAR2);

--  Derive PM Task Reference
	FUNCTION Get_Task_Reference RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  ( Get_Task_Reference, WNDS, WNPS );

        PROCEDURE Set_Task_Reference ( x_task_reference IN VARCHAR2);


END pa_wbs_pkg;

 

/
