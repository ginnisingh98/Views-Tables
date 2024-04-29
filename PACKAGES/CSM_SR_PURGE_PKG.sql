--------------------------------------------------------
--  DDL for Package CSM_SR_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_SR_PURGE_PKG" AUTHID CURRENT_USER AS
/* $Header: csmsrprs.pls 120.0 2005/08/10 12:08:57 rsripada noship $ */

PROCEDURE Validate_MobileFSObjects(
      P_API_VERSION                IN	NUMBER  ,
      P_INIT_MSG_LIST              IN	VARCHAR2     := FND_API.G_FALSE,
      P_COMMIT                     IN   VARCHAR2     := FND_API.G_FALSE,
      P_PROCESSING_SET_ID          IN   NUMBER  ,
      P_OBJECT_TYPE                IN  	VARCHAR2 ,
      X_RETURN_STATUS              IN   OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT                  IN 	OUT NOCOPY   NUMBER,
      X_MSG_DATA                   IN 	OUT NOCOPY VARCHAR2);

PROCEDURE Delete_MobileFSObjects(
      P_API_VERSION                IN   NUMBER  ,
      P_INIT_MSG_LIST              IN   VARCHAR2     := FND_API.G_FALSE,
      P_COMMIT                     IN	VARCHAR2     := FND_API.G_FALSE,
      P_PROCESSING_SET_ID          IN   NUMBER  ,
      P_OBJECT_TYPE                IN  	VARCHAR2 ,
      X_RETURN_STATUS              IN   OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT                  IN 	OUT NOCOPY   NUMBER,
      X_MSG_DATA                   IN 	OUT NOCOPY VARCHAR2);

END CSM_SR_PURGE_PKG;

 

/
