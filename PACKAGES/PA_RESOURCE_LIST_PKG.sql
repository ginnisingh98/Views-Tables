--------------------------------------------------------
--  DDL for Package PA_RESOURCE_LIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RESOURCE_LIST_PKG" AUTHID CURRENT_USER AS
/* $Header: PARELITS.pls 120.1 2005/08/19 16:50:18 mwasowic noship $ */
-- Standard Table Handler procedures for PA_RESOURCE_LISTS table
PROCEDURE Insert_parent_row (X_ROW_ID IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             X_RESOURCE_LIST_MEMBER_ID NUMBER,
                             X_RESOURCE_LIST_ID        NUMBER,
                             X_RESOURCE_ID             NUMBER,
                             X_ALIAS                   VARCHAR2,
                             X_SORT_ORDER              NUMBER,
                             X_MEMBER_LEVEL            NUMBER,
                             X_DISPLAY_FLAG            VARCHAR2,
                             X_ENABLED_FLAG            VARCHAR2,
                             X_TRACK_AS_LABOR_FLAG     VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_CREATION_DATE           DATE,
                             X_CREATED_BY              NUMBER,
                             X_LAST_UPDATE_LOGIN       NUMBER,
                             X_Funds_Control_Level_Code VARCHAR2,
                             p_migration_code          VARCHAR2);

PROCEDURE Update_Parent_Row (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_MEMBER_ID NUMBER,
                             X_ALIAS                   VARCHAR2,
                             X_SORT_ORDER              NUMBER,
                             X_MEMBER_LEVEL            NUMBER,
                             X_DISPLAY_FLAG            VARCHAR2,
                             X_ENABLED_FLAG            VARCHAR2,
                             X_TRACK_AS_LABOR_FLAG     VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_LAST_UPDATE_LOGIN       NUMBER,
                             X_Funds_Control_Level_Code VARCHAR2,
                             p_migration_code          VARCHAR2);

Procedure Lock_Parent_Row   (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_MEMBER_ID NUMBER,
                             X_RESOURCE_ID             NUMBER,
                             X_ALIAS                   VARCHAR2,
                             X_SORT_ORDER              NUMBER,
                             X_DISPLAY_FLAG            VARCHAR2,
                             X_ENABLED_FLAG            VARCHAR2,
                             X_Funds_Control_Level_Code VARCHAR2,
                             p_migration_code          VARCHAR2);

Procedure Delete_Parent_Row (X_ROW_ID IN VARCHAR2);

PROCEDURE Insert_child_row  (X_ROW_ID IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             X_RESOURCE_LIST_MEMBER_ID NUMBER,
                             X_RESOURCE_LIST_ID        NUMBER,
                             X_RESOURCE_ID             NUMBER,
                             X_ALIAS                   VARCHAR2,
                             X_PARENT_MEMBER_ID        NUMBER,
                             X_SORT_ORDER              NUMBER,
                             X_MEMBER_LEVEL            NUMBER,
                             X_DISPLAY_FLAG            VARCHAR2,
                             X_ENABLED_FLAG            VARCHAR2,
                             X_TRACK_AS_LABOR_FLAG     VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_CREATION_DATE           DATE,
                             X_CREATED_BY              NUMBER,
                             X_LAST_UPDATE_LOGIN       NUMBER,
                             X_Funds_Control_Level_Code VARCHAR2);

PROCEDURE Update_Child_Row  (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_MEMBER_ID NUMBER,
                             X_ALIAS                   VARCHAR2,
                             X_SORT_ORDER              NUMBER,
                             X_MEMBER_LEVEL            NUMBER,
                             X_DISPLAY_FLAG            VARCHAR2,
                             X_ENABLED_FLAG            VARCHAR2,
                             X_TRACK_AS_LABOR_FLAG     VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_LAST_UPDATE_LOGIN       NUMBER,
                             X_Funds_Control_Level_Code VARCHAR2 );

Procedure Lock_Child_Row    (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_MEMBER_ID NUMBER,
                             X_RESOURCE_ID             NUMBER,
                             X_ALIAS                   VARCHAR2,
                             X_SORT_ORDER              NUMBER,
                             X_DISPLAY_FLAG            VARCHAR2,
                             X_ENABLED_FLAG            VARCHAR2,
                             X_Funds_Control_Level_Code VARCHAR2 );

Procedure Delete_Child_Row  (X_ROW_ID IN VARCHAR2);


Procedure Delete_Unclassified_Child (x_resource_list_id IN
                                          PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_ID%TYPE,
                                     x_parent_member_id IN
                                          PA_RESOURCE_LIST_MEMBERS.Parent_Member_ID%TYPE,
                                     X_msg_Count  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                     X_msg_Data   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                     X_return_Status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   );
END PA_Resource_List_Pkg;

 

/
