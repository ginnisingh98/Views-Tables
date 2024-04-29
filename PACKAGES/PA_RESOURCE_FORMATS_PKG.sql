--------------------------------------------------------
--  DDL for Package PA_RESOURCE_FORMATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RESOURCE_FORMATS_PKG" AUTHID CURRENT_USER as
/* $Header: PAREPRFS.pls 115.5 2002/03/04 04:48:40 pkm ship     $ */
procedure INSERT_ROW (
  X_RESOURCE_FORMAT_ID               in NUMBER,
  X_PERSON_ID_FLAG                   in VARCHAR2,
  X_JOB_ID_FLAG                      in VARCHAR2,
  X_ORGANIZATION_ID_FLAG             in VARCHAR2,
  X_VENDOR_ID_FLAG                   in VARCHAR2,
  X_EXPENDITURE_TYPE_FLAG            in VARCHAR2,
  X_EVENT_TYPE_FLAG                  in VARCHAR2,
  X_NON_LABOR_RESOURCE_FLAG          in VARCHAR2,
  X_EXPENDITURE_CATEGORY_FLAG        in VARCHAR2,
  X_REVENUE_CATEGORY_FLAG            in VARCHAR2,
  X_NON_LABOR_RESOURCE_ORG_FLAG      in VARCHAR2,
  X_EVENT_CLASSIFICATION_FLAG        in VARCHAR2,
  X_SYSTEM_LINKAGE_FUNCTION_FLAG     in VARCHAR2,
  X_DESCRIPTION                      in VARCHAR2,
  X_PROJECT_ROLE_ID_FLAG             in VARCHAR2,
  X_CREATION_DATE                    in DATE,
  X_CREATED_BY                       in NUMBER,
  X_LAST_UPDATE_DATE                 in DATE,
  X_LAST_UPDATED_BY                  in NUMBER,
  X_LAST_UPDATE_LOGIN                in NUMBER);

procedure TRANSLATE_ROW (
  X_RESOURCE_FORMAT_ID       in NUMBER,
  X_OWNER                    in VARCHAR2,
  X_DESCRIPTION              in VARCHAR2);

procedure UPDATE_ROW (
  X_RESOURCE_FORMAT_ID               in NUMBER,
  X_PERSON_ID_FLAG                   in VARCHAR2,
  X_JOB_ID_FLAG                      in VARCHAR2,
  X_ORGANIZATION_ID_FLAG             in VARCHAR2,
  X_VENDOR_ID_FLAG                   in VARCHAR2,
  X_EXPENDITURE_TYPE_FLAG            in VARCHAR2,
  X_EVENT_TYPE_FLAG                  in VARCHAR2,
  X_NON_LABOR_RESOURCE_FLAG          in VARCHAR2,
  X_EXPENDITURE_CATEGORY_FLAG        in VARCHAR2,
  X_REVENUE_CATEGORY_FLAG            in VARCHAR2,
  X_NON_LABOR_RESOURCE_ORG_FLAG      in VARCHAR2,
  X_EVENT_CLASSIFICATION_FLAG        in VARCHAR2,
  X_SYSTEM_LINKAGE_FUNCTION_FLAG     in VARCHAR2,
  X_DESCRIPTION                      in VARCHAR2,
  X_PROJECT_ROLE_ID_FLAG             in VARCHAR2,
  X_LAST_UPDATE_DATE                 in DATE,
  X_LAST_UPDATED_BY                  in NUMBER,
  X_LAST_UPDATE_LOGIN                in NUMBER
);
end PA_RESOURCE_FORMATS_PKG;

 

/
