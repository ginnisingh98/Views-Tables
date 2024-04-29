--------------------------------------------------------
--  DDL for Package PA_ROLE_JOB_BG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ROLE_JOB_BG_PVT" AUTHID CURRENT_USER AS
 /* $Header: PAXRJBVS.pls 115.1 2003/08/25 19:01:53 ramurthy ship $ */

procedure INSERT_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   IN         VARCHAR2 DEFAULT 'N',
 P_ROLE_JOB_BG_ID               OUT NOCOPY NUMBER,
 P_PROJECT_ROLE_ID              IN         NUMBER,
 P_BUSINESS_GROUP_ID            IN         NUMBER,
 P_JOB_ID                       IN         NUMBER,
 P_MIN_JOB_LEVEL                IN         NUMBER,
 P_MAX_JOB_LEVEL                IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        OUT NOCOPY NUMBER,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER,
 p_return_status                OUT NOCOPY VARCHAR2,
 p_msg_count                    OUT NOCOPY NUMBER,
 p_msg_data                     OUT NOCOPY VARCHAR2
);

procedure LOCK_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   IN         VARCHAR2 DEFAULT 'N',
 P_ROLE_JOB_BG_ID               IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER,
 p_return_status                OUT NOCOPY VARCHAR2,
 p_msg_count                    OUT NOCOPY NUMBER,
 p_msg_data                     OUT NOCOPY VARCHAR2
);

procedure UPDATE_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   IN         VARCHAR2 DEFAULT 'N',
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
 P_LAST_UPDATE_LOGIN            IN         NUMBER,
 p_return_status                OUT NOCOPY VARCHAR2,
 p_msg_count                    OUT NOCOPY NUMBER,
 p_msg_data                     OUT NOCOPY VARCHAR2
);

procedure DELETE_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   IN         VARCHAR2 DEFAULT 'N',
 P_ROLE_JOB_BG_ID               IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER,
 p_return_status                OUT NOCOPY VARCHAR2,
 p_msg_count                    OUT NOCOPY NUMBER,
 p_msg_data                     OUT NOCOPY VARCHAR2
);

end PA_ROLE_JOB_BG_PVT;

 

/
