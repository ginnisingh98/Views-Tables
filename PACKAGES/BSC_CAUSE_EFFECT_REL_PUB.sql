--------------------------------------------------------
--  DDL for Package BSC_CAUSE_EFFECT_REL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_CAUSE_EFFECT_REL_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPCAES.pls 120.0 2005/06/01 14:41:32 appldev noship $ */

TYPE Bsc_Cause_Effect_Rel_Rec is RECORD(
  Cause_Indicator		NUMBER
 ,Cause_Level                	VARCHAR2(10)
 ,Effect_Indicator		NUMBER
 ,Effect_Level			VARCHAR2(10)
);

TYPE Bsc_Cause_Effect_Rel_Tbl IS TABLE OF Bsc_Cause_Effect_Rel_Rec
  INDEX BY BINARY_INTEGER;


PROCEDURE Create_Cause_Effect_Rel(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Cause_Effect_Rel_Rec	IN	BSC_CAUSE_EFFECT_REL_PUB.Bsc_Cause_Effect_Rel_Rec
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count           	OUT NOCOPY     NUMBER
 ,x_msg_data            	OUT NOCOPY     VARCHAR2
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

END BSC_CAUSE_EFFECT_REL_PUB;

 

/
