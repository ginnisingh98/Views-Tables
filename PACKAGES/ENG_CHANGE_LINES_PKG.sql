--------------------------------------------------------
--  DDL for Package ENG_CHANGE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: ENGCHLUS.pls 115.7 2003/11/22 19:01:38 sshrikha ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CHANGE_LINE_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_CHANGE_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_CHANGE_TYPE_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_ASSIGNEE_ID in NUMBER,
  X_NEED_BY_DATE in DATE,
  X_ORIGINAL_SYSTEM_REFERENCE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SCHEDULED_DATE in DATE,
  X_IMPLEMENTATION_DATE in DATE,
  X_CANCELATION_DATE in DATE,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_APPROVAL_STATUS_TYPE      IN NUMBER,
  X_APPROVAL_DATE             IN DATE,
  X_APPROVAL_REQUEST_DATE     IN DATE,
  X_ROUTE_ID                  IN NUMBER,
  X_REQUIRED_FLAG             IN VARCHAR2,
  X_COMPLETE_BEFORE_STATUS_CODE IN NUMBER,
  X_START_AFTER_STATUS_CODE   IN NUMBER
);
procedure LOCK_ROW (
  X_CHANGE_LINE_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_CHANGE_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_CHANGE_TYPE_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_ASSIGNEE_ID in NUMBER,
  X_NEED_BY_DATE in DATE,
  X_ORIGINAL_SYSTEM_REFERENCE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SCHEDULED_DATE in DATE,
  X_IMPLEMENTATION_DATE in DATE,
  X_CANCELATION_DATE in DATE,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_APPROVAL_STATUS_TYPE      IN NUMBER,
  X_APPROVAL_DATE             IN DATE,
  X_APPROVAL_REQUEST_DATE     IN DATE,
  X_ROUTE_ID                  IN NUMBER,
  X_REQUIRED_FLAG             IN VARCHAR2,
  X_COMPLETE_BEFORE_STATUS_CODE IN NUMBER,
  X_START_AFTER_STATUS_CODE   IN NUMBER
);
procedure UPDATE_ROW (
  X_CHANGE_LINE_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_CHANGE_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_CHANGE_TYPE_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_ASSIGNEE_ID in NUMBER,
  X_NEED_BY_DATE in DATE,
  X_ORIGINAL_SYSTEM_REFERENCE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SCHEDULED_DATE in DATE,
  X_IMPLEMENTATION_DATE in DATE,
  X_CANCELATION_DATE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_APPROVAL_STATUS_TYPE      IN NUMBER,
  X_APPROVAL_DATE             IN DATE,
  X_APPROVAL_REQUEST_DATE     IN DATE,
  X_ROUTE_ID                  IN NUMBER,
  X_REQUIRED_FLAG             IN VARCHAR2,
  X_COMPLETE_BEFORE_STATUS_CODE IN NUMBER,
  X_START_AFTER_STATUS_CODE   IN NUMBER
);
procedure DELETE_ROW (
  X_CHANGE_LINE_ID in NUMBER
);
procedure ADD_LANGUAGE;
end ENG_CHANGE_LINES_PKG;

 

/