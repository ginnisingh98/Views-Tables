--------------------------------------------------------
--  DDL for Package CS_SR_STATUS_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_STATUS_GROUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: cststgrs.pls 120.0 2006/02/28 11:48:15 spusegao noship $ */

PROCEDURE INSERT_ROW (
  X_ROWID                      in out NOCOPY VARCHAR2 ,
  X_STATUS_GROUP_ID            in NUMBER,
  X_SECURITY_GROUP_ID          in NUMBER,
  X_TRANSITION_IND             in VARCHAR2,
  X_OBJECT_VERSION_NUMBER      in NUMBER,
  X_ORIG_SYSTEM_REFERENCE_ID   in NUMBER,
  X_END_DATE                   in DATE,
  X_START_DATE                 in DATE,
  X_DEFAULT_INCIDENT_STATUS_ID in NUMBER,
  X_GROUP_NAME                 in VARCHAR2,
  X_DESCRIPTION                in VARCHAR2,
  X_LANGUAGE                   in VARCHAR2,
  X_SOURCE_LANG                in VARCHAR2,
  X_CREATION_DATE              in DATE,
  X_CREATED_BY                 in NUMBER,
  X_LAST_UPDATE_DATE           in DATE,
  X_LAST_UPDATED_BY            in NUMBER,
  X_LAST_UPDATE_LOGIN          in NUMBER);

procedure LOCK_ROW (
  X_STATUS_GROUP_ID            in NUMBER,
  X_SECURITY_GROUP_ID          in NUMBER,
  X_TRANSITION_IND             in VARCHAR2,
  X_OBJECT_VERSION_NUMBER      in NUMBER,
  X_ORIG_SYSTEM_REFERENCE_ID   in NUMBER,
  X_END_DATE                   in DATE,
  X_START_DATE                 in DATE,
  X_DEFAULT_INCIDENT_STATUS_ID in NUMBER,
  X_GROUP_NAME                 in VARCHAR2,
  X_DESCRIPTION                in VARCHAR2,
  X_LANGUAGE                   in VARCHAR2,
  X_SOURCE_LANG                in VARCHAR2);


procedure UPDATE_ROW (
  X_STATUS_GROUP_ID            in NUMBER,
  X_SECURITY_GROUP_ID          in NUMBER,
  X_TRANSITION_IND             in VARCHAR2,
  X_OBJECT_VERSION_NUMBER      in NUMBER,
  X_ORIG_SYSTEM_REFERENCE_ID   in NUMBER,
  X_END_DATE                   in DATE,
  X_START_DATE                 in DATE,
  X_DEFAULT_INCIDENT_STATUS_ID in NUMBER,
  X_GROUP_NAME                 in VARCHAR2,
  X_DESCRIPTION                in VARCHAR2,
  X_LANGUAGE                   in VARCHAR2,
  X_SOURCE_LANG                in VARCHAR2,
  X_LAST_UPDATE_DATE           in DATE,
  X_LAST_UPDATED_BY            in NUMBER,
  X_LAST_UPDATE_LOGIN          in NUMBER);


PROCEDURE DELETE_ROW (
   X_STATUS_GROUP_ID              IN  NUMBER );

PROCEDURE ADD_LANGUAGE;

PROCEDURE LOAD_ROW (
   P_STATUS_GROUP_ID              IN  NUMBER,
   P_OWNER                        IN  VARCHAR2,
   P_TRANSITION_IND               IN  VARCHAR2,
   P_DEFAULT_INCIDENT_STATUS_ID   IN  NUMBER,
   P_ORIG_SYSTEM_REFERENCE_ID     IN  NUMBER,
   P_START_DATE                   IN  VARCHAR2,
   P_END_DATE                     IN  VARCHAR2,
   P_GROUP_NAME                   IN  VARCHAR2,
   P_DESCRIPTION                  IN  VARCHAR2,
   P_LANGUAGE                     IN VARCHAR2,
   P_SOURCE_LANG                  IN VARCHAR2,
   P_OBJECT_VERSION_NUMBER        IN  NUMBER,
   P_SECURITY_GROUP_ID            IN  NUMBER );

PROCEDURE TRANSLATE_ROW (
   P_STATUS_GROUP_ID              IN NUMBER,
   P_GROUP_NAME                   IN VARCHAR2,
   P_DESCRIPTION                  IN VARCHAR2,
   P_OWNER                        IN VARCHAR2 );

END CS_SR_STATUS_GROUPS_PKG;

 

/
