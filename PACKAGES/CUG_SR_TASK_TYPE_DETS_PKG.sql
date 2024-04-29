--------------------------------------------------------
--  DDL for Package CUG_SR_TASK_TYPE_DETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CUG_SR_TASK_TYPE_DETS_PKG" AUTHID CURRENT_USER as
/* $Header: CUGSRTTS.pls 115.4 2002/12/04 20:27:00 pkesani noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SR_TASK_TYPE_DET_ID in NUMBER,
  X_ASSIGNED_BY_ID in NUMBER,
  X_ASSIGNEE_TYPE_CODE in VARCHAR2,
  X_TASK_PRIORITY_ID in NUMBER,
  X_PLANNED_START_OFFSET in NUMBER,
  X_PLANNED_END_OFFSET in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_OWNER_TYPE_CODE in VARCHAR2,
  X_PLANNED_START_UOM in VARCHAR2,
  X_PLANNED_END_UOM in VARCHAR2,
  X_SCHEDULED_START_OFFSET in NUMBER,
  X_TSK_TYP_ATTR_DEP_ID in NUMBER,
  X_TASK_STATUS_ID in NUMBER,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_OWNER_ID in NUMBER,
  X_SCHEDULED_END_OFFSET in NUMBER,
  X_SCHEDULED_START_UOM in VARCHAR2,
  X_SCHEDULED_END_UOM in VARCHAR2,
  X_PRIVATE_FLAG in VARCHAR2,
  X_PUBLISH_FLAG in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_SR_TASK_TYPE_DET_ID in NUMBER,
  X_ASSIGNED_BY_ID in NUMBER,
  X_ASSIGNEE_TYPE_CODE in VARCHAR2,
  X_TASK_PRIORITY_ID in NUMBER,
  X_PLANNED_START_OFFSET in NUMBER,
  X_PLANNED_END_OFFSET in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_OWNER_TYPE_CODE in VARCHAR2,
  X_PLANNED_START_UOM in VARCHAR2,
  X_PLANNED_END_UOM in VARCHAR2,
  X_SCHEDULED_START_OFFSET in NUMBER,
  X_TSK_TYP_ATTR_DEP_ID in NUMBER,
  X_TASK_STATUS_ID in NUMBER,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_OWNER_ID in NUMBER,
  X_SCHEDULED_END_OFFSET in NUMBER,
  X_SCHEDULED_START_UOM in VARCHAR2,
  X_SCHEDULED_END_UOM in VARCHAR2,
  X_PRIVATE_FLAG in VARCHAR2,
  X_PUBLISH_FLAG in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_SR_TASK_TYPE_DET_ID in NUMBER,
  X_ASSIGNED_BY_ID in NUMBER,
  X_ASSIGNEE_TYPE_CODE in VARCHAR2,
  X_TASK_PRIORITY_ID in NUMBER,
  X_PLANNED_START_OFFSET in NUMBER,
  X_PLANNED_END_OFFSET in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_OWNER_TYPE_CODE in VARCHAR2,
  X_PLANNED_START_UOM in VARCHAR2,
  X_PLANNED_END_UOM in VARCHAR2,
  X_SCHEDULED_START_OFFSET in NUMBER,
  X_TSK_TYP_ATTR_DEP_ID in NUMBER,
  X_TASK_STATUS_ID in NUMBER,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_OWNER_ID in NUMBER,
  X_SCHEDULED_END_OFFSET in NUMBER,
  X_SCHEDULED_START_UOM in VARCHAR2,
  X_SCHEDULED_END_UOM in VARCHAR2,
  X_PRIVATE_FLAG in VARCHAR2,
  X_PUBLISH_FLAG in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_TASK_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_SR_TASK_TYPE_DET_ID in NUMBER
);
procedure ADD_LANGUAGE;
end CUG_SR_TASK_TYPE_DETS_PKG;

 

/
