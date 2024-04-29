--------------------------------------------------------
--  DDL for Package Body BIS_CUSTOM_CAUSE_EFFECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_CUSTOM_CAUSE_EFFECT_PVT" AS
/* $Header: BISVCECB.pls 120.0 2006/08/04 17:13:46 appldev noship $ */

PROCEDURE Create_Custom_Cause_Effect_Rel(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Cause_Short_Name     	IN	bis_custom_cause_effect_rels.cause_short_name%TYPE
 ,p_Effect_Short_Name     	IN	bis_custom_cause_effect_rels.effect_short_name%TYPE
 ,p_Cause_Sequence         	IN	bis_custom_cause_effect_rels.cause_sequence%TYPE
 ,p_Effect_Sequence         	IN	bis_custom_cause_effect_rels.effect_sequence%TYPE
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count			OUT NOCOPY	NUMBER
 ,x_msg_data			OUT NOCOPY	VARCHAR2
) IS
BEGIN

  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  IF p_Cause_Short_Name IS NULL THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_CAUSE_MEASURE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_Effect_Short_Name IS NULL THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_EFFECT_MEASURE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_Cause_Sequence IS NULL OR  p_Cause_Sequence = FND_API.G_MISS_NUM THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_CAUSE_SEQUENCE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_Effect_Sequence IS NULL OR  p_Effect_Sequence = FND_API.G_MISS_NUM THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_EFFECT_SEQUENCE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  INSERT INTO BIS_CUSTOM_CAUSE_EFFECT_RELS
  (
    ID,
    CAUSE_SHORT_NAME,
    EFFECT_SHORT_NAME,
    CAUSE_SEQUENCE,
    EFFECT_SEQUENCE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  )
  VALUES
  (
    BIS_CAUSE_EFFECT_S.nextVal,
    p_Cause_Short_Name,
    p_Effect_Short_Name,
    p_Cause_Sequence,
    p_Effect_Sequence,
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.LOGIN_ID
  );

  IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_CUSTOM_CAUSE_EFFECT_PVT.Create_Custom_Cause_Effect_Rel ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_CUSTOM_CAUSE_EFFECT_PVT.Create_Custom_Cause_Effect_Rel ';
        END IF;
END Create_Custom_Cause_Effect_Rel;

PROCEDURE Update_Custom_Cause_Effect_Rel(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Cause_Short_Name     	IN	bis_custom_cause_effect_rels.cause_short_name%TYPE
 ,p_Effect_Short_Name     	IN	bis_custom_cause_effect_rels.effect_short_name%TYPE
 ,p_Cause_Sequence         	IN	bis_custom_cause_effect_rels.cause_sequence%TYPE
 ,p_Effect_Sequence         	IN	bis_custom_cause_effect_rels.effect_sequence%TYPE
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count			OUT NOCOPY	NUMBER
 ,x_msg_data			OUT NOCOPY	VARCHAR2
)IS

  l_count NUMBER := 0;
  CURSOR rec_Count(x_cause_short_name IN bis_custom_cause_effect_rels.cause_short_name%TYPE,x_effect_short_name IN bis_custom_cause_effect_rels.effect_short_name%TYPE)
  IS
  SELECT COUNT(1)
  FROM bis_custom_cause_effect_rels
  WHERE cause_short_name = x_cause_short_name
  AND effect_short_name = x_effect_short_name;

BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  IF p_Cause_Short_Name IS NULL THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_CAUSE_MEASURE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_Effect_Short_Name IS NULL THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_EFFECT_MEASURE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_Cause_Sequence IS NULL OR  p_Cause_Sequence = FND_API.G_MISS_NUM THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_CAUSE_SEQUENCE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_Effect_Sequence IS NULL OR  p_Effect_Sequence = FND_API.G_MISS_NUM THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_EFFECT_SEQUENCE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN rec_Count(p_Cause_Short_Name,p_Effect_Short_Name);
  FETCH rec_Count INTO l_count;
  CLOSE rec_Count;

  IF l_count > 0 THEN
    UPDATE bis_custom_cause_effect_rels
    SET
      cause_sequence    = p_Cause_Sequence
    , effect_sequence   = p_Effect_Sequence
    , last_updated_by   = FND_GLOBAL.USER_ID
    , last_update_date  = SYSDATE
    , last_update_login = FND_GLOBAL.LOGIN_ID
    WHERE
      cause_short_name = p_Cause_Short_Name AND
      effect_short_name = p_Effect_Short_Name;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_CUSTOM_CAUSE_EFFECT_PVT.Update_Custom_Cause_Effect_Rel ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_CUSTOM_CAUSE_EFFECT_PVT.Update_Custom_Cause_Effect_Rel ';
        END IF;
END Update_Custom_Cause_Effect_Rel;


PROCEDURE Delete_Custom_Cause_Effect_Rel(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Cause_Short_Name     	IN	bis_custom_cause_effect_rels.cause_short_name%TYPE
 ,p_Effect_Short_Name     	IN	bis_custom_cause_effect_rels.effect_short_name%TYPE
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count			OUT NOCOPY	NUMBER
 ,x_msg_data			OUT NOCOPY	VARCHAR2
) IS
  l_count NUMBER := 0;
  CURSOR rec_Count(x_cause_short_name IN bis_custom_cause_effect_rels.cause_short_name%TYPE,x_effect_short_name IN bis_custom_cause_effect_rels.effect_short_name%TYPE)
  IS
  SELECT COUNT(1)
  FROM bis_custom_cause_effect_rels
  WHERE cause_short_name = x_cause_short_name
  AND effect_short_name = x_effect_short_name;

BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  IF p_Cause_Short_Name IS NULL THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_CAUSE_MEASURE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_Effect_Short_Name IS NULL THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_EFFECT_MEASURE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN rec_Count(p_Cause_Short_Name,p_Effect_Short_Name);
  FETCH rec_Count INTO l_count;
  CLOSE rec_Count;

  IF l_count > 0 THEN
    DELETE FROM bis_custom_cause_effect_rels
    WHERE
      cause_short_name = p_Cause_Short_Name AND
      effect_short_name = p_Effect_Short_Name;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_CUSTOM_CAUSE_EFFECT_PVT.Delete_Custom_Cause_Effect_Rel ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_CUSTOM_CAUSE_EFFECT_PVT.Delete_Custom_Cause_Effect_Rel ';
        END IF;

END Delete_Custom_Cause_Effect_Rel;


PROCEDURE Delete_Custom_Cause_Effect_Rel(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Cause_DataSetId     	IN	bis_indicators.dataset_id%TYPE
 ,p_Effect_DataSetId     	IN	bis_indicators.dataset_id%TYPE
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count			OUT NOCOPY	NUMBER
 ,x_msg_data			OUT NOCOPY	VARCHAR2
)
IS
  l_Cause_Short_Name bis_custom_cause_effect_rels.cause_short_name%TYPE;
  l_Effect_Short_Name bis_custom_cause_effect_rels.cause_short_name%TYPE;

  CURSOR c_short_Name(l_dataset_id NUMBER)
  IS
  SELECT
    short_name
  FROM
    bis_indicators
  WHERE
    dataset_id = l_dataset_id;

BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  IF p_Cause_DataSetId IS NULL THEN
     FND_MESSAGE.SET_NAME('BIS','BSC_INVALID_CAUSE_INDICATOR');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_Effect_DataSetId IS NULL THEN
     FND_MESSAGE.SET_NAME('BIS','BSC_INVALID_EFFECT_INDICATOR');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN c_short_Name(p_Cause_DataSetId);
  FETCH c_short_Name INTO l_Cause_Short_Name;
  CLOSE c_short_Name;

  OPEN c_short_Name(p_Effect_DataSetId);
  FETCH c_short_Name INTO l_Effect_Short_Name;
  CLOSE c_short_Name;

  Delete_Custom_Cause_Effect_Rel(
      p_commit             => p_commit
    , p_Cause_Short_Name   => l_Cause_Short_Name
    , p_Effect_Short_Name  => l_Effect_Short_Name
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
  );

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_CUSTOM_CAUSE_EFFECT_PVT.Delete_Custom_Cause_Effect_Rel ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_CUSTOM_CAUSE_EFFECT_PVT.Delete_Custom_Cause_Effect_Rel ';
        END IF;

END Delete_Custom_Cause_Effect_Rel;

END BIS_CUSTOM_CAUSE_EFFECT_PVT;

/
