--------------------------------------------------------
--  DDL for Package PER_CALENDAR_ENTRIES_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CALENDAR_ENTRIES_LOAD_PKG" AUTHID CURRENT_USER as
/* $Header: peentlct.pkh 120.0 2005/05/31 08:09 appldev noship $ */
procedure INSERT_ROW (
  X_CALENDAR_ENTRY_ID                   in NUMBER,
  X_NAME                                in VARCHAR2,
  X_TYPE                                in VARCHAR2,
  X_START_DATE                          in DATE,
  X_END_DATE                            in DATE,
  X_START_HOUR                          in VARCHAR2,
  X_START_MIN                           in VARCHAR2,
  X_END_HOUR                            in VARCHAR2,
  X_END_MIN                             in VARCHAR2,
  X_HIERARCHY_ID                        in NUMBER,
  X_VALUE_SET_ID                        in NUMBER,
  X_ORG_STRUCT_ID                       in NUMBER,
  X_ORG_STRUCT_VER_ID                   in NUMBER,
  X_DESCRIPTION                         in VARCHAR2,
  X_CREATION_DATE                       in DATE,
  X_CREATED_BY                          in NUMBER,
  X_LAST_UPDATE_DATE                    in DATE,
  X_LAST_UPDATED_BY                     in NUMBER,
  X_LAST_UPDATE_LOGIN                   in NUMBER,
  X_BUS_GRP_ID                          in NUMBER,
  X_IDENTIFIER_KEY                      in VARCHAR2,
  X_LEGISLATION_CODE                    in VARCHAR2);

procedure LOAD_ROW (
  X_IDENTIFIER_KEY                      in VARCHAR2,
  X_LEGISLATION_CODE                    in VARCHAR2,
  X_BUS_GRP_NAME 			in VARCHAR2,
  X_NAME 				in VARCHAR2,
  X_START_DATE 		   	        in VARCHAR2,
  X_END_DATE 			        in VARCHAR2,
  X_TYPE 				in VARCHAR2,
  X_START_HOUR 		          	in VARCHAR2,
  X_START_MIN 			        in VARCHAR2,
  X_END_HOUR 			        in VARCHAR2,
  X_END_MIN 			        in VARCHAR2,
  X_HIERARCHY_NAME 			in VARCHAR2,
  X_FLEX_VALUE_SET_NAME                 in VARCHAR2,
  X_ORG_HIER_NAME                       in VARCHAR2,
  X_ORG_HIER_VERSION                    in NUMBER,
  X_DESCRIPTION 			in VARCHAR2,
  X_OWNER                       	in VARCHAR2,
  X_LAST_UPDATE_DATE                  	in VARCHAR2);


procedure UPDATE_ROW (
  X_CALENDAR_ENTRY_ID                   in NUMBER,
  X_NAME                                in VARCHAR2,
  X_TYPE                                in VARCHAR2,
  X_START_DATE                          in DATE,
  X_END_DATE                            in DATE,
  X_START_HOUR                          in VARCHAR2,
  X_START_MIN                           in VARCHAR2,
  X_END_HOUR                            in VARCHAR2,
  X_END_MIN                             in VARCHAR2,
  X_HIERARCHY_ID                        in NUMBER,
  X_VALUE_SET_ID                        in NUMBER,
  X_ORG_STRUCT_ID                       in NUMBER,
  X_ORG_STRUCT_VER_ID                   in NUMBER,
  X_DESCRIPTION                         in VARCHAR2,
  X_LAST_UPDATE_DATE                    in DATE,
  X_LAST_UPDATED_BY                     in NUMBER,
  X_LAST_UPDATE_LOGIN                   in NUMBER);

end PER_CALENDAR_ENTRIES_LOAD_PKG;

 

/
