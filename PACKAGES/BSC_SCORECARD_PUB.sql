--------------------------------------------------------
--  DDL for Package BSC_SCORECARD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_SCORECARD_PUB" AUTHID CURRENT_USER as
/* $Header: BSCPTABS.pls 120.1 2005/08/24 02:22:36 visuri noship $ */

TYPE Bsc_Tab_Entity_Rec is RECORD(
  Bsc_Bsc_Model          NUMBER
 ,Bsc_Created_By         NUMBER
 ,Bsc_Creation_Date      DATE
 ,Bsc_Cross_Model        NUMBER
 ,Bsc_Csf_Id             NUMBER
 ,Bsc_Csf_Type           NUMBER
 ,Bsc_Default_Model      NUMBER
 ,Bsc_Intermediate_Flag  NUMBER
 ,Bsc_Kpi_Model          NUMBER
 ,Bsc_Language           BSC_TABS_TL.LANGUAGE%TYPE
 ,Bsc_Last_Updated_By    NUMBER
 ,Bsc_Last_Update_Date   DATE
 ,Bsc_Last_Update_Login  NUMBER
 ,Bsc_Owner_Id           NUMBER
 ,Bsc_Parent_Tab_Id      NUMBER
 ,Bsc_Resp_Start_Date    DATE
 ,Bsc_Resp_End_Date      DATE
 ,Bsc_Responsibility_Id  NUMBER
 ,Bsc_Source_Language    BSC_TABS_TL.SOURCE_LANG%TYPE
 ,Bsc_Tab_Help           BSC_TABS_TL.HELP%TYPE
 ,Bsc_Tab_Id             NUMBER
 ,Bsc_Tab_Index          NUMBER
 ,Bsc_Tab_Name           BSC_TABS_TL.NAME%TYPE
 ,Bsc_Zoom_Factor        NUMBER
 ,Bsc_Tab_Info           BSC_TABS_TL.ADDITIONAL_INFO%TYPE
 ,Bsc_Short_Name         BSC_TABS_B.SHORT_NAME%TYPE
);

TYPE Bsc_Tab_Entity_Tbl IS TABLE OF Bsc_Tab_Entity_Rec
  INDEX BY BINARY_INTEGER;

procedure Initialize_Tab_Entity_Rec(
  p_Bsc_Tab_Entity_Rec  IN            BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_Bsc_Tab_Entity_Rec  OUT NOCOPY    BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY    varchar2
 ,x_msg_count           OUT NOCOPY    number
 ,x_msg_data            OUT NOCOPY    varchar2
);

procedure Create_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN  BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_Bsc_Tab_Entity_Rec  OUT NOCOPY     BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN  BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_Bsc_Tab_Entity_Rec  IN OUT NOCOPY   BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN  BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
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

procedure Create_Tab_Grants(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
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


function is_child_tab_of(
  p_child_tab_id        IN      number
 ,p_parent_tab_id       IN      number
) return varchar2;

FUNCTION Check_Tab_UserAccess(
  p_tab_id           IN     NUMBER
 ,p_user_name        IN     VARCHAR2
 ,p_user_access      IN     VARCHAR2
)return VARCHAR2;

FUNCTION Check_Tab_UserAccess_Func_Only(
  p_tab_id           IN     NUMBER
 ,p_user_name        IN     VARCHAR2
 ,p_user_access      IN     VARCHAR2
)return VARCHAR2;

PROCEDURE Validate_Scorecard_Revoke (
  p_grant_guids      IN     VARCHAR2
 ,x_chd_tabname_list OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_Scorecard_Access (
  p_tab_id         IN     NUMBER
 ,p_user_name      IN     VARCHAR2
 ,x_par_tab_name     OUT NOCOPY VARCHAR2
 ,x_par_tabname_list OUT NOCOPY VARCHAR2
);

FUNCTION is_Tab_Ordering_Enabled(
 p_tab_id        IN      NUMBER
,p_user_name     IN      VARCHAR2
)RETURN VARCHAR2;


end BSC_SCORECARD_PUB;

 

/
