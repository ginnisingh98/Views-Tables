--------------------------------------------------------
--  DDL for Package Body PA_WBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WBS_PKG" AS
 -- $Header: PAXWBSB.pls 115.0 99/07/16 15:38:23 porting ship $
--================================================================
--
--
----------------------------------------------------------------------------------
-- Functions and Procedures
----------------------------------------------------------------------------------
--

FUNCTION Get_project_id RETURN NUMBER
IS
BEGIN

	RETURN (  GlobVars.project_id );
END;

PROCEDURE Set_Project_id ( x_project_id IN NUMBER)
IS
BEGIN
  GlobVars.project_id                   :=      x_project_id;
END;

FUNCTION Get_Task_Number RETURN VARCHAR2
IS
BEGIN

        RETURN ( GlobVars.task_number );
END;

PROCEDURE Set_Task_Number ( x_task_number IN VARCHAR2)
IS
BEGIN
  GlobVars.task_number                  :=      x_task_number;
END;

FUNCTION Get_Task_Name RETURN VARCHAR2
IS
BEGIN

        RETURN ( GlobVars.task_name );
END;

PROCEDURE Set_Task_Name ( x_task_name IN VARCHAR2)
IS
BEGIN
  GlobVars.task_name                    :=      x_task_name;
END;

FUNCTION Get_Organization_id RETURN NUMBER
IS
BEGIN

        RETURN ( GlobVars.carrying_out_organization_id );
END;

PROCEDURE Set_Organization_id ( x_carrying_out_organization_id IN NUMBER)
IS
BEGIN
  GlobVars.carrying_out_organization_id :=      x_carrying_out_organization_id;
END;

FUNCTION Get_Service_Code RETURN VARCHAR2
IS
BEGIN

        RETURN ( GlobVars.service_type_code );
END;

PROCEDURE Set_Service_Code ( x_service_type_code IN VARCHAR2)
IS
BEGIN
  GlobVars.service_type_code            :=      x_service_type_code;
END;

FUNCTION Get_Manager_id RETURN NUMBER
IS
BEGIN

	RETURN ( GlobVars.task_manager_person_id );
END;

PROCEDURE Set_Manager_id ( x_task_manager_person_id IN NUMBER)
IS
BEGIN
  GlobVars.task_manager_person_id       :=      x_task_manager_person_id;
END;

FUNCTION Get_wbs_level RETURN NUMBER
IS
BEGIN

	RETURN ( GlobVars.wbs_level );
END;

PROCEDURE Set_wbs_level ( x_wbs_level IN NUMBER)
IS
BEGIN
  GlobVars.wbs_level                    :=      x_wbs_level;
END;

FUNCTION Get_Chargeable_flag RETURN VARCHAR2
IS
BEGIN

	RETURN ( GlobVars.chargeable_flag );
END;

PROCEDURE Set_Chargeable_flag ( x_chargeable_flag IN VARCHAR2)
IS
BEGIN
  GlobVars.chargeable_flag              :=      x_chargeable_flag;
END;

FUNCTION Get_Billable_flag RETURN VARCHAR2
IS
BEGIN

	RETURN ( GlobVars.billable_flag );
END;

PROCEDURE Set_Billable_flag ( x_billable_flag IN VARCHAR2)
IS
BEGIN
  GlobVars.billable_flag                :=      x_billable_flag;
END;

FUNCTION Get_Product_Code RETURN VARCHAR2
IS
BEGIN

        RETURN ( GlobVars.pm_product_code );
END;

PROCEDURE Set_Product_Code ( x_product_code IN VARCHAR2)
IS
BEGIN
  GlobVars.pm_product_code                    :=      x_product_code;
END;

FUNCTION Get_Task_Reference RETURN VARCHAR2
IS
BEGIN

        RETURN ( GlobVars.pm_task_reference );
END;

PROCEDURE Set_Task_Reference ( x_task_reference IN VARCHAR2)
IS
BEGIN
  GlobVars.pm_task_reference                    :=      x_task_reference;
END;


END pa_wbs_pkg;

/
