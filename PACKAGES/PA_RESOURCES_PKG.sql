--------------------------------------------------------
--  DDL for Package PA_RESOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RESOURCES_PKG" AUTHID CURRENT_USER AS
/* $Header: PARESOTS.pls 120.1 2005/08/19 16:50:56 mwasowic noship $ */
-- Standard Table Handler procedures for PA_RESOURCES table
PROCEDURE Insert_row (
                X_Row_Id     IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                X_RESOURCE_ID IN NUMBER,
                X_NAME IN VARCHAR2,
                X_DESCRIPTION IN VARCHAR2,
                X_RESOURCE_TYPE_ID IN NUMBER,
                X_UNIT_OF_MEASURE IN VARCHAR2,
                X_ROLLUP_QUANTITY_FLAG IN VARCHAR2,
                X_START_DATE_ACTIVE IN DATE,
                X_END_DATE_ACTIVE IN DATE,
                X_TRACK_AS_LABOR_FLAG IN VARCHAR2,
                X_LAST_UPDATE_DATE IN DATE,
                X_LAST_UPDATED_BY IN NUMBER,
                X_CREATION_DATE IN DATE,
                X_CREATED_BY IN NUMBER,
                X_LAST_UPDATE_LOGIN IN NUMBER,
                X_ATTRIBUTE_CATEGORY IN VARCHAR2,
                X_ATTRIBUTE1 IN VARCHAR2);
Procedure Update_Row (
                X_Row_Id     IN VARCHAR2,
                X_RESOURCE_ID IN NUMBER,
                X_NAME IN VARCHAR2,
                X_DESCRIPTION IN VARCHAR2,
                X_RESOURCE_TYPE_ID IN NUMBER,
                X_UNIT_OF_MEASURE IN VARCHAR2,
                X_ROLLUP_QUANTITY_FLAG IN VARCHAR2,
                X_START_DATE_ACTIVE IN DATE,
                X_END_DATE_ACTIVE IN DATE,
                X_TRACK_AS_LABOR_FLAG IN VARCHAR2,
                X_LAST_UPDATE_DATE IN DATE,
                X_LAST_UPDATED_BY IN NUMBER,
                X_LAST_UPDATE_LOGIN IN NUMBER,
                X_ATTRIBUTE_CATEGORY IN VARCHAR2,
                X_ATTRIBUTE1 IN VARCHAR2);
Procedure Lock_Row (
                X_Row_Id     IN VARCHAR2,
                X_RESOURCE_ID IN NUMBER,
                X_NAME IN VARCHAR2,
                X_DESCRIPTION IN VARCHAR2,
                X_RESOURCE_TYPE_ID IN NUMBER,
                X_UNIT_OF_MEASURE IN VARCHAR2,
                X_ROLLUP_QUANTITY_FLAG IN VARCHAR2,
                X_START_DATE_ACTIVE IN DATE,
                X_END_DATE_ACTIVE IN DATE,
                X_TRACK_AS_LABOR_FLAG IN VARCHAR2,
                X_LAST_UPDATE_DATE IN DATE,
                X_LAST_UPDATED_BY IN NUMBER,
                X_LAST_UPDATE_LOGIN IN NUMBER,
                X_ATTRIBUTE_CATEGORY IN VARCHAR2,
                X_ATTRIBUTE1 IN VARCHAR2);
Procedure Delete_Row (X_Row_Id In Varchar2);

/* Added function get_resource_name for bug 1299456 */
Function Get_Resource_Name( P_Resource_Id IN NUMBER,
                            P_resource_type_id IN NUMBER) RETURN VARCHAR2;

pragma RESTRICT_REFERENCES (Get_Resource_Name, WNDS, WNPS);

Function Get_Resource_List_Member_Name(p_resource_list_member_Id IN pa_resource_list_members.resource_list_member_id%TYPE) RETURN VARCHAR2;
--pragma RESTRICT_REFERENCES (Get_Resource_List_Member_Name, WNDS, WNPS);

END PA_RESOURCES_Pkg;
 

/
