--------------------------------------------------------
--  DDL for Package PA_ROLE_JOB_BG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ROLE_JOB_BG_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRJBTS.pls 115.1 2003/08/25 19:01:08 ramurthy ship $ */

PROCEDURE INSERT_ROW (
 P_ROLE_JOB_BG_ID               OUT NOCOPY NUMBER,
 P_PROJECT_ROLE_ID              IN         NUMBER,
 P_BUSINESS_GROUP_ID            IN	   NUMBER,
 P_JOB_ID                       IN	   NUMBER,
 P_MIN_JOB_LEVEL                IN	   NUMBER,
 P_MAX_JOB_LEVEL                IN	   NUMBER,
 P_OBJECT_VERSION_NUMBER        OUT NOCOPY NUMBER,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER
);

PROCEDURE LOCK_ROW (
 P_ROLE_JOB_BG_ID               IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER
);


PROCEDURE UPDATE_ROW (
 P_ROLE_JOB_BG_ID               IN         NUMBER,
 P_PROJECT_ROLE_ID              IN         NUMBER,
 P_BUSINESS_GROUP_ID            IN         NUMBER,
 P_JOB_ID                       IN         NUMBER,
 P_MIN_JOB_LEVEL                IN         NUMBER,
 P_MAX_JOB_LEVEL                IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN OUT NOCOPY    NUMBER,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER
);

PROCEDURE DELETE_ROW (
 P_ROLE_JOB_BG_ID               IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER);

END pa_role_job_bg_pkg ;

 

/
