--------------------------------------------------------
--  DDL for Package PA_RES_LIST_ASSIGNMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RES_LIST_ASSIGNMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: PARLASTS.pls 120.1 2005/08/19 16:55:11 mwasowic noship $ */
-- Standard Table Handler procedures for PA_RESOURCE_LIST_ASSIGNMENTS  table
PROCEDURE Insert_row        (X_ROW_ID IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             X_RESOURCE_LIST_ASSIGNMENT_ID NUMBER,
                             X_RESOURCE_LIST_ID        NUMBER,
                             X_PROJECT_ID              NUMBER,
                             X_RESOURCE_LIST_CHANGED_FLAG VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_CREATION_DATE           DATE,
                             X_CREATED_BY              NUMBER,
                             X_LAST_UPDATE_LOGIN       NUMBER );

PROCEDURE Update_Row        (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_CHANGED_FLAG VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_LAST_UPDATE_LOGIN       NUMBER );

Procedure Lock_Row          (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_ASSIGNMENT_ID NUMBER,
                             X_RESOURCE_LIST_ID        NUMBER,
                             X_RESOURCE_LIST_CHANGED_FLAG VARCHAR2);

Procedure Delete_Row         (X_ROW_ID IN VARCHAR2);

END PA_Res_list_Assignment_Pkg;

 

/
