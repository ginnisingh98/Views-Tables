--------------------------------------------------------
--  DDL for Package BSC_CAUSE_EFFECT_REL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_CAUSE_EFFECT_REL_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCVCAES.pls 115.4 2003/02/12 14:30:31 adeulgao ship $ */

PROCEDURE Create_Cause_Effect_Rel(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Cause_Effect_Rel_Rec	IN	BSC_CAUSE_EFFECT_REL_PUB.Bsc_Cause_Effect_Rel_Rec
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count			OUT NOCOPY	NUMBER
 ,x_msg_data			OUT NOCOPY	VARCHAR2
);

PROCEDURE Delete_Cause_Effect_Rel(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Cause_Effect_Rel_Rec	IN	BSC_CAUSE_EFFECT_REL_PUB.Bsc_Cause_Effect_Rel_Rec
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count			OUT NOCOPY	NUMBER
 ,x_msg_data			OUT NOCOPY	VARCHAR2
);

PROCEDURE Delete_All_Cause_Effect_Rels(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_indicator			IN	NUMBER
 ,p_level			IN	VARCHAR2
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count			OUT NOCOPY	NUMBER
 ,x_msg_data			OUT NOCOPY	VARCHAR2
);


END BSC_CAUSE_EFFECT_REL_PVT;

 

/
