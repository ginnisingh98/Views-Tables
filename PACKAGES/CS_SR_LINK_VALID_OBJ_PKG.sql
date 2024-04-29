--------------------------------------------------------
--  DDL for Package CS_SR_LINK_VALID_OBJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_LINK_VALID_OBJ_PKG" AUTHID CURRENT_USER AS
/* $Header: cstlnvos.pls 115.1 2002/12/04 03:27:21 dejoseph noship $ */

   PROCEDURE INSERT_ROW (
      PX_LINK_VALID_OBJ_ID      IN OUT NOCOPY NUMBER,
      P_SUBJECT_TYPE            IN VARCHAR2,
      P_OBJECT_TYPE             IN VARCHAR2,
      P_LINK_TYPE_ID            IN NUMBER,
      P_START_DATE_ACTIVE       IN DATE,
      P_END_DATE_ACTIVE         IN DATE,
      P_USER_ID                 IN NUMBER,
      P_LOGIN_ID                IN NUMBER,
      P_SECURITY_GROUP_ID       IN NUMBER,
      P_APPLICATION_ID          IN NUMBER,
      P_SEEDED_FLAG             IN VARCHAR2,
      P_OBJECT_VERSION_NUMBER   IN NUMBER );


   PROCEDURE LOCK_ROW (
      P_LINK_VALID_OBJ_ID       IN NUMBER,
      P_OBJECT_VERSION_NUMBER   IN NUMBER );


   PROCEDURE UPDATE_ROW (
      P_LINK_VALID_OBJ_ID       IN NUMBER,
      P_SUBJECT_TYPE            IN VARCHAR2,
      P_OBJECT_TYPE             IN VARCHAR2,
      P_LINK_TYPE_ID            IN NUMBER,
      P_START_DATE_ACTIVE       IN DATE,
      P_END_DATE_ACTIVE         IN DATE,
      P_USER_ID                 IN NUMBER,
      P_LOGIN_ID                IN NUMBER,
      P_SECURITY_GROUP_ID       IN NUMBER,
      P_APPLICATION_ID          IN NUMBER,
      P_SEEDED_FLAG             IN VARCHAR2,
      P_OBJECT_VERSION_NUMBER   IN NUMBER );

   PROCEDURE DELETE_ROW (
      P_LINK_VALID_OBJ_ID       IN NUMBER );

   PROCEDURE LOAD_ROW (
      P_LINK_VALID_OBJ_ID       IN NUMBER,
      P_SUBJECT_TYPE            IN VARCHAR2,
      P_OBJECT_TYPE             IN VARCHAR2,
      P_LINK_TYPE_ID            IN NUMBER,
      P_START_DATE_ACTIVE       IN VARCHAR2,
      P_END_DATE_ACTIVE         IN VARCHAR2,
      P_OWNER                   IN VARCHAR2,
      P_APPLICATION_ID          IN NUMBER,
      P_SEEDED_FLAG             IN VARCHAR2,
      P_SECURITY_GROUP_ID       IN NUMBER,
      P_OBJECT_VERSION_NUMBER   IN NUMBER );


END CS_SR_LINK_VALID_OBJ_PKG;

 

/
