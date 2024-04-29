--------------------------------------------------------
--  DDL for Package PER_CAL_ENTRY_VALUES_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CAL_ENTRY_VALUES_LOAD_PKG" AUTHID CURRENT_USER as
/* $Header: peenvlct.pkh 120.0 2005/05/31 08:10 appldev noship $ */

procedure INSERT_ROW (
  X_CAL_ENTRY_VALUE_ID                  in NUMBER,
  X_CALENDAR_ENTRY_ID                   in NUMBER,
  X_HIERARCHY_NODE_ID                   in NUMBER,
  X_IDVALUE                             in VARCHAR2,
  X_ORG_STRUCTURE_ELEMENT_ID            in NUMBER,
  X_ORGANIZATION_ID                     in NUMBER,
  X_OVERRIDE_NAME                       in VARCHAR2,
  X_OVERRIDE_TYPE                       in VARCHAR2,
  X_PARENT_ENTRY_VALUE_ID               in NUMBER,
  X_USAGE_FLAG                          in VARCHAR2,
  X_CREATED_BY                          in NUMBER,
  X_LAST_UPDATE_DATE                    in DATE,
  X_LAST_UPDATED_BY                     in NUMBER,
  X_LAST_UPDATE_LOGIN                   in NUMBER,
  X_CREATION_DATE                       in DATE,
  X_IDENTIFIER_KEY                      in VARCHAR2);

procedure LOAD_ROW (
  X_VALUE_IDENTIFIER_KEY                in VARCHAR2,
  X_PARENT_VALUE_IDENTIFIER_KEY         in VARCHAR2,
  X_ENTRY_IDENTIFIER_KEY                in VARCHAR2,
  X_HIERARCHY_NODE_NAME                 in VARCHAR2,
  X_IDVALUE                             in VARCHAR2,
  X_ORG_HIER_NAME                       in VARCHAR2,
  X_ORG_HIER_VERSION                    in NUMBER,
  X_ORG_HIER_ELEMENT_PARENT             in VARCHAR2,
  X_ORG_HIER_ELEMENT_CHILD              in VARCHAR2,
  X_ORG_HIER_NODE_NAME                  in VARCHAR2,
  X_OVERRIDE_NAME                       in VARCHAR2,
  X_OVERRIDE_TYPE                       in VARCHAR2,
  X_USAGE_FLAG                          in VARCHAR2,
  X_OWNER                               in VARCHAR2,
  X_LAST_UPDATE_DATE                    in VARCHAR2);

procedure UPDATE_ROW (
   X_CAL_ENTRY_VALUE_ID                 in NUMBER,
   X_HIERARCHY_NODE_ID                  in NUMBER,
   X_IDVALUE                            in VARCHAR2,
   X_ORG_STRUCTURE_ELEMENT_ID           in NUMBER,
   X_ORGANIZATION_ID                    in NUMBER,
   X_OVERRIDE_NAME                      in VARCHAR2,
   X_OVERRIDE_TYPE                      in VARCHAR2,
   X_USAGE_FLAG                         in VARCHAR2,
   X_LAST_UPDATE_DATE                   in DATE,
   X_LAST_UPDATED_BY                    in NUMBER,
   X_LAST_UPDATE_LOGIN                  in NUMBER);

end PER_CAL_ENTRY_VALUES_LOAD_PKG;

 

/
