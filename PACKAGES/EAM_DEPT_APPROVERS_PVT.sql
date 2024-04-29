--------------------------------------------------------
--  DDL for Package EAM_DEPT_APPROVERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_DEPT_APPROVERS_PVT" AUTHID CURRENT_USER as
/* $Header: EAMVDAPS.pls 115.5 2003/08/19 06:49:47 yjhabak ship $ */
-- Start of comments
-- API name : EAM_DEPT_APPROVERS_PVT
-- Type     : Private
-- Function :
-- Pre-reqs : None.
-- Parameters :
-- IN        P_API_VERSION                 IN NUMBER       REQUIRED
--           P_INIT_MSG_LIST               IN VARCHAR2     OPTIONAL
--             DEFAULT = FND_API.G_FALSE
--           P_COMMIT                      IN VARCHAR2     OPTIONAL
--             DEFAULT = FND_API.G_FALSE
--           P_VALIDATION_LEVEL            IN NUMBER       OPTIONAL
--             DEFAULT = FND_API.G_VALID_LEVEL_FULL
--	     P_DEPT_ID			   IN  NUMBER 	   REQUIRED
-- 	     P_LAST_UPDATE_DATE            IN  DATE	   REQUIRED
-- 	     P_LAST_UPDATED_BY             IN  NUMBER	   REQUIRED
-- 	     P_CREATION_DATE               IN  DATE	   REQUIRED
-- 	     P_CREATED_BY                  IN  NUMBER      REQUIRED
-- 	     P_LAST_UPDATE_LOGIN           IN  NUMBER	   OPTIONAL
-- 	     P_RESPONSIBILITY_ID           IN  NUMBER	   REQUIRED
-- 	     P_RESPONSIBILITY_APPLICATN_ID IN  NUMBER	   REQUIRED

 -- OUT      X_RETURN_STATUS               OUT VARCHAR2(1)
 --          X_MSG_COUNT                   OUT NUMBER
 --          X_MSG_DATA                    OUT VARCHAR2(2000)
 --
 -- Version  Current version 115.0
 --
 -- Notes    : Note text
 --
 -- End of comments


PROCEDURE INSERT_ROW(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID			    IN OUT NOCOPY VARCHAR2,
  P_DEPT_ID                         NUMBER,
  P_ORGANIZATION_ID		    NUMBER,
  P_LAST_UPDATE_DATE                DATE,
  P_LAST_UPDATED_BY                 NUMBER,
  P_CREATION_DATE                   DATE,
  P_CREATED_BY                      NUMBER,
  P_LAST_UPDATE_LOGIN               NUMBER,
  P_RESPONSIBILITY_ID               NUMBER,
  P_RESPONSIBILITY_APPLICATN_ID     NUMBER,
  P_PRIMARY_APPROVER                NUMBER,
  X_RETURN_STATUS                   OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                       OUT NOCOPY NUMBER,
  X_MSG_DATA                        OUT NOCOPY VARCHAR2);

PROCEDURE LOCK_ROW(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID			    IN OUT NOCOPY VARCHAR2,
  P_DEPT_ID                         NUMBER,
  P_ORGANIZATION_ID		    NUMBER,
  P_LAST_UPDATE_DATE                DATE,
  P_LAST_UPDATED_BY                 NUMBER,
  P_CREATION_DATE                   DATE,
  P_CREATED_BY                      NUMBER,
  P_LAST_UPDATE_LOGIN               NUMBER,
  P_RESPONSIBILITY_ID               NUMBER,
  P_RESPONSIBILITY_APPLICATN_ID     NUMBER,
  X_RETURN_STATUS                   OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                       OUT NOCOPY NUMBER,
  X_MSG_DATA                        OUT NOCOPY VARCHAR2);

PROCEDURE UPDATE_ROW(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID			    IN OUT NOCOPY VARCHAR2,
  P_DEPT_ID                         NUMBER,
  P_ORGANIZATION_ID		    NUMBER,
  P_LAST_UPDATE_DATE                DATE,
  P_LAST_UPDATED_BY                 NUMBER,
  P_CREATION_DATE                   DATE,
  P_CREATED_BY                      NUMBER,
  P_LAST_UPDATE_LOGIN               NUMBER,
  P_RESPONSIBILITY_ID               NUMBER,
  P_RESPONSIBILITY_APPLICATN_ID     NUMBER,
  P_PRIMARY_APPROVER                NUMBER,
  X_RETURN_STATUS                   OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                       OUT NOCOPY NUMBER,
  X_MSG_DATA                        OUT NOCOPY VARCHAR2);

PROCEDURE DELETE_ROW(
  P_DEPT_ID                         NUMBER,
  P_ORGANIZATION_ID		    NUMBER,
  P_RESPONSIBILITY_ID               NUMBER,
  P_RESPONSIBILITY_APPLICATN_ID     NUMBER
 );

END EAM_DEPT_APPROVERS_PVT;

 

/
