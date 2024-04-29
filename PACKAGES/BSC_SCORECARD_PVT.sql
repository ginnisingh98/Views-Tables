--------------------------------------------------------
--  DDL for Package BSC_SCORECARD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_SCORECARD_PVT" AUTHID CURRENT_USER as
/* $Header: BSCVTABS.pls 120.0 2005/06/01 15:46:21 appldev noship $ */

BSC_ADMIN_ACCESS    CONSTANT VARCHAR2(30) :='BSC_SCORECARD_ADMINISTRATOR';
BSC_OBJECT_NAME     CONSTANT VARCHAR2(10) :='BSC_TAB';
BSC_INSTANCE_TYPE   CONSTANT VARCHAR2(10) :='INSTANCE';
BSC_GRANTEE_TYPE    CONSTANT VARCHAR2(5)  :='USER';
BSC_PROGRAM_NAME    CONSTANT VARCHAR2(15) :='BSC_PMD_GRANTS';
BSC_VIEWER_ACCESS   CONSTANT VARCHAR2(30) :='BSC_SCORECARD_USER';
procedure Create_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN  BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

procedure Retrieve_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_Bsc_Tab_Entity_Rec  IN OUT NOCOPY      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Tab_Access(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Move_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_tab_id                      number
 ,p_tab_index                   number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Tab_Time_Stamp(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_System_Time_Stamp(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

function Validate_Tab(
  p_Tab_Name            IN      varchar2
) return number;

function Validate_Kpi_Group(
  p_Kpi_Group_Name              IN      varchar2
) return number;

function Validate_Kpi(
  p_Kpi_Name                  IN      varchar2
) return number;

/*************************************************************
 Added for Scorecard Security Enhancement
/************************************************************/

PROCEDURE Remove_Scorecard_Grants
(
    p_tab_id        IN      NUMBER
);

PROCEDURE Insert_Scorecard_Grants
(
    p_tab_id        IN      NUMBER
  , p_user_name     IN      VARCHAR2
);

procedure Create_Tab_Grants(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure REVOKE_GRANT
(  p_commit         IN            VARCHAR2
,  p_api_version    IN            NUMBER
,  p_grant_guid     IN            VARCHAR2
,  x_success        OUT NOCOPY    VARCHAR2
,  x_errorcode      OUT NOCOPY    NUMBER
);

FUNCTION Is_More
(       p_grant_uids IN  OUT NOCOPY  VARCHAR2
    ,   p_grant_uid        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN;

/**************************************************************/
end BSC_SCORECARD_PVT;

 

/
