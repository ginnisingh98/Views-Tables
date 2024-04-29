--------------------------------------------------------
--  DDL for Package BIS_CUSTOM_CAUSE_EFFECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_CUSTOM_CAUSE_EFFECT_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVCECS.pls 120.0 2006/08/04 17:14:01 appldev noship $ */

PROCEDURE Create_Custom_Cause_Effect_Rel(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Cause_Short_Name     	IN	bis_custom_cause_effect_rels.cause_short_name%TYPE
 ,p_Effect_Short_Name     	IN	bis_custom_cause_effect_rels.effect_short_name%TYPE
 ,p_Cause_Sequence         	IN	bis_custom_cause_effect_rels.cause_sequence%TYPE
 ,p_Effect_Sequence         	IN	bis_custom_cause_effect_rels.effect_sequence%TYPE
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count			OUT NOCOPY	NUMBER
 ,x_msg_data			OUT NOCOPY	VARCHAR2
);

PROCEDURE Update_Custom_Cause_Effect_Rel(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Cause_Short_Name     	IN	bis_custom_cause_effect_rels.cause_short_name%TYPE
 ,p_Effect_Short_Name     	IN	bis_custom_cause_effect_rels.effect_short_name%TYPE
 ,p_Cause_Sequence         	IN	bis_custom_cause_effect_rels.cause_sequence%TYPE
 ,p_Effect_Sequence         	IN	bis_custom_cause_effect_rels.effect_sequence%TYPE
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count			OUT NOCOPY	NUMBER
 ,x_msg_data			OUT NOCOPY	VARCHAR2
);


PROCEDURE Delete_Custom_Cause_Effect_Rel(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Cause_Short_Name     	IN	bis_custom_cause_effect_rels.cause_short_name%TYPE
 ,p_Effect_Short_Name     	IN	bis_custom_cause_effect_rels.effect_short_name%TYPE
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count			OUT NOCOPY	NUMBER
 ,x_msg_data			OUT NOCOPY	VARCHAR2
);

PROCEDURE Delete_Custom_Cause_Effect_Rel(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Cause_DataSetId     	IN	bis_indicators.dataset_id%TYPE
 ,p_Effect_DataSetId     	IN	bis_indicators.dataset_id%TYPE
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count			OUT NOCOPY	NUMBER
 ,x_msg_data			OUT NOCOPY	VARCHAR2
);

END BIS_CUSTOM_CAUSE_EFFECT_PVT;

 

/
