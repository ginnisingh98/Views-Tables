--------------------------------------------------------
--  DDL for Package CSM_TASK_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_TASK_PURGE_PKG" AUTHID CURRENT_USER AS
/* $Header: csmtkprs.pls 120.1 2005/08/26 01:47:17 skotikal noship $ */

PROCEDURE VALIDATE_MFS_TASKS(
      P_API_VERSION                IN	NUMBER  ,
      P_INIT_MSG_LIST              IN	VARCHAR2     := FND_API.G_FALSE,
      P_COMMIT                     IN   VARCHAR2     := FND_API.G_FALSE,
      P_PROCESSING_SET_ID          IN   NUMBER  ,
      P_OBJECT_TYPE                IN  	VARCHAR2 ,
      X_RETURN_STATUS              IN   OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT                  IN 	OUT NOCOPY   NUMBER,
      X_MSG_DATA                   IN 	OUT NOCOPY VARCHAR2);

PROCEDURE DELETE_MFS_TASKS(
      P_API_VERSION                IN   NUMBER  ,
      P_INIT_MSG_LIST              IN   VARCHAR2     := FND_API.G_FALSE,
      P_COMMIT                     IN	VARCHAR2     := FND_API.G_FALSE,
      P_PROCESSING_SET_ID          IN   NUMBER  ,
      P_OBJECT_TYPE                IN  	VARCHAR2 ,
      X_RETURN_STATUS              IN   OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT                  IN 	OUT NOCOPY   NUMBER,
      X_MSG_DATA                   IN 	OUT NOCOPY VARCHAR2);

END CSM_TASK_PURGE_PKG;

 

/
