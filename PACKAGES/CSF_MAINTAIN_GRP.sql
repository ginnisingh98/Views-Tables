--------------------------------------------------------
--  DDL for Package CSF_MAINTAIN_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_MAINTAIN_GRP" AUTHID CURRENT_USER as
/* $Header: csfpurgs.pls 120.0 2005/06/23 10:59:58 rhungund noship $ */
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE Validate_FieldServiceObjects(
      P_API_VERSION                 IN        NUMBER  ,
      P_INIT_MSG_LIST              IN   VARCHAR2     := FND_API.G_FALSE,
      P_COMMIT                     IN   VARCHAR2     := FND_API.G_FALSE,
      P_PROCESSING_SET_ID                 IN        NUMBER  ,
      P_OBJECT_TYPE                IN  VARCHAR2 ,
      X_RETURN_STATUS              IN   OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT                 IN OUT NOCOPY   NUMBER,
      X_MSG_DATA                 IN OUT NOCOPY VARCHAR2);



PROCEDURE Purge_FieldServiceObjects(
      P_API_VERSION                 IN        NUMBER  ,
      P_INIT_MSG_LIST              IN   VARCHAR2     := FND_API.G_FALSE,
      P_COMMIT                     IN   VARCHAR2     := FND_API.G_FALSE,
      P_PROCESSING_SET_ID                 IN        NUMBER  ,
      P_OBJECT_TYPE                IN  VARCHAR2 ,
      X_RETURN_STATUS              IN   OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT                 IN OUT NOCOPY   NUMBER,
      X_MSG_DATA                 IN OUT NOCOPY VARCHAR2);

END CSF_MAINTAIN_GRP;


 

/
