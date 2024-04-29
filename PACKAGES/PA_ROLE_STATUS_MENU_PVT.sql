--------------------------------------------------------
--  DDL for Package PA_ROLE_STATUS_MENU_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ROLE_STATUS_MENU_PVT" AUTHID CURRENT_USER AS
 /* $Header: PAXRSMVS.pls 115.2 2003/08/21 07:38:30 bvarnasi ship $ */

procedure INSERT_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 P_ROLE_STATUS_MENU_ID          OUT NOCOPY NUMBER,
 P_ROLE_ID                      IN         NUMBER,
 P_STATUS_TYPE                  IN         VARCHAR2,
 P_STATUS_CODE                  IN         VARCHAR2,
 P_MENU_ID                      IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        OUT NOCOPY NUMBER,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER,
 p_return_status                OUT NOCOPY varchar2,
 p_msg_count                    out NOCOPY number,
 p_msg_data                     out NOCOPY varchar2
);

procedure LOCK_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 P_ROLE_STATUS_MENU_ID          IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER,
 p_return_status                OUT NOCOPY varchar2,
 p_msg_count                    out NOCOPY number,
 p_msg_data                     out NOCOPY varchar2
);

procedure UPDATE_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 P_ROLE_STATUS_MENU_ID          IN         NUMBER,
 P_ROLE_ID                      IN         NUMBER,
 P_STATUS_TYPE                  IN         VARCHAR2,
 P_STATUS_CODE                  IN         VARCHAR2,
 P_MENU_ID                      IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN OUT NOCOPY    NUMBER,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER,
 p_return_status                OUT NOCOPY varchar2,
 p_msg_count                    out NOCOPY number,
 p_msg_data                     out NOCOPY varchar2
);

procedure DELETE_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 P_ROLE_STATUS_MENU_ID          IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER,
 p_return_status                OUT NOCOPY varchar2,
 p_msg_count                    out NOCOPY number,
 p_msg_data                     out NOCOPY varchar2
);

end PA_ROLE_STATUS_MENU_PVT;

 

/
