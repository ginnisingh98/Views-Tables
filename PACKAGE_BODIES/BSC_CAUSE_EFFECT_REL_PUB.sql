--------------------------------------------------------
--  DDL for Package Body BSC_CAUSE_EFFECT_REL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_CAUSE_EFFECT_REL_PUB" AS
/* $Header: BSCPCAEB.pls 120.0 2005/06/01 16:00:39 appldev noship $ */

G_PKG_NAME              CONSTANT        VARCHAR2(30) := 'BSC_CAUSE_EFFECT_REL_PUB';


PROCEDURE Create_Cause_Effect_Rel(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Cause_Effect_Rel_Rec  	IN      BSC_CAUSE_EFFECT_REL_PUB.Bsc_Cause_Effect_Rel_Rec
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count           	OUT NOCOPY     NUMBER
 ,x_msg_data            	OUT NOCOPY     VARCHAR2
) IS

BEGIN

    BSC_CAUSE_EFFECT_REL_PVT.Create_Cause_Effect_Rel(p_commit
                               ,p_Bsc_Cause_Effect_Rel_Rec
                               ,x_return_status
                               ,x_msg_count
                               ,x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

END Create_Cause_Effect_Rel;

/************************************************************************************
************************************************************************************/

PROCEDURE Delete_Cause_Effect_Rel(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Cause_Effect_Rel_Rec  	IN      BSC_CAUSE_EFFECT_REL_PUB.Bsc_Cause_Effect_Rel_Rec
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count           	OUT NOCOPY     NUMBER
 ,x_msg_data            	OUT NOCOPY     VARCHAR2
) IS

BEGIN

    BSC_CAUSE_EFFECT_REL_PVT.Delete_Cause_Effect_Rel(p_commit
                               ,p_Bsc_Cause_Effect_Rel_Rec
                               ,x_return_status
                               ,x_msg_count
                               ,x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

END Delete_Cause_Effect_Rel;

/************************************************************************************
************************************************************************************/

PROCEDURE Delete_All_Cause_Effect_Rels(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_indicator			IN	NUMBER
 ,p_level			IN	VARCHAR2
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count			OUT NOCOPY	NUMBER
 ,x_msg_data			OUT NOCOPY	VARCHAR2
) IS

BEGIN

    BSC_CAUSE_EFFECT_REL_PVT.Delete_All_Cause_Effect_Rels(p_commit
                               ,p_indicator
                               ,p_level
                               ,x_return_status
                               ,x_msg_count
                               ,x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

END Delete_All_Cause_Effect_Rels;

/************************************************************************************
************************************************************************************/

END BSC_CAUSE_EFFECT_REL_PUB;

/
