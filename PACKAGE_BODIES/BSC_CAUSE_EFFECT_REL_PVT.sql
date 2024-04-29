--------------------------------------------------------
--  DDL for Package Body BSC_CAUSE_EFFECT_REL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_CAUSE_EFFECT_REL_PVT" AS
/* $Header: BSCVCAEB.pls 120.0 2005/06/01 16:04:30 appldev noship $ */

G_PKG_NAME              CONSTANT        VARCHAR2(30) := 'BSC_CAUSE_EFFECT_REL_PVT';
g_db_object                             VARCHAR2(30) := NULL;

PROCEDURE Create_Cause_Effect_Rel(
  p_commit              	IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Cause_Effect_Rel_Rec	IN      BSC_CAUSE_EFFECT_REL_PUB.Bsc_Cause_Effect_Rel_Rec
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count           	OUT NOCOPY     NUMBER
 ,x_msg_data            	OUT NOCOPY     VARCHAR2
) IS

l_count				NUMBER;
l_dynamic_sql       VARCHAR2(32000);

BEGIN

  -- Check that all the information is provided
  IF p_Bsc_Cause_Effect_Rel_Rec.Cause_Indicator IS NULL THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_CAUSE_INDICATOR');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_Bsc_Cause_Effect_Rel_Rec.Cause_Level NOT IN ('KPI', 'DATASET') THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_CAUSE_LEVEL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_Bsc_Cause_Effect_Rel_Rec.Effect_Indicator IS NULL THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_EFFECT_INDICATOR');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_Bsc_Cause_Effect_Rel_Rec.Effect_Level NOT IN ('KPI', 'DATASET') THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_EFFECT_LEVEL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check that the kpi (if KPI level) or dataset (DATASET level) already exists
  l_count := 0;
  IF p_Bsc_Cause_Effect_Rel_Rec.Cause_Level = 'KPI' THEN
      SELECT count(*) INTO l_count
      FROM bsc_kpis_b
      WHERE indicator = p_Bsc_Cause_Effect_Rel_Rec.Cause_Indicator;
  ELSE
      SELECT count(*) INTO l_count
      FROM bsc_sys_datasets_b
      WHERE dataset_id = p_Bsc_Cause_Effect_Rel_Rec.Cause_Indicator;
  END IF;
  IF l_count = 0 THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_CAUSE_INDICATOR');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_count := 0;
  IF p_Bsc_Cause_Effect_Rel_Rec.Effect_Level = 'KPI' THEN
      SELECT count(*) INTO l_count
      FROM bsc_kpis_b
      WHERE indicator = p_Bsc_Cause_Effect_Rel_Rec.Effect_Indicator;
  ELSE
      SELECT count(*) INTO l_count
      FROM bsc_sys_datasets_b
      WHERE dataset_id = p_Bsc_Cause_Effect_Rel_Rec.Effect_Indicator;
  END IF;
  IF l_count = 0 THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_EFFECT_INDICATOR');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Now that the record is validated, we can insert the record in the table BSC_KPI_CAUSE_EFFECT_RELS
  -- Only create the relation if it already does not exists
  l_count := 0;
  SELECT count(*) INTO l_count
  FROM bsc_kpi_cause_effect_rels
  WHERE
      cause_indicator = p_Bsc_Cause_Effect_Rel_Rec.Cause_Indicator AND
      effect_indicator = p_Bsc_Cause_Effect_Rel_Rec.Effect_Indicator AND
      NVL(cause_level, 'KPI') = p_Bsc_Cause_Effect_Rel_Rec.Cause_Level AND
      NVL(effect_level, 'KPI') = p_Bsc_Cause_Effect_Rel_Rec.Effect_Level;

  IF l_count = 0 THEN

      l_dynamic_sql := 'INSERT INTO bsc_kpi_cause_effect_rels (cause_indicator,effect_indicator,'||
                       'cause_level,effect_level)VALUES (:1,:2,:3,:4)';


      EXECUTE IMMEDIATE l_dynamic_sql USING p_Bsc_Cause_Effect_Rel_Rec.Cause_Indicator,p_Bsc_Cause_Effect_Rel_Rec.Effect_Indicator,p_Bsc_Cause_Effect_Rel_Rec.Cause_Level,p_Bsc_Cause_Effect_Rel_Rec.Effect_Level;
  END IF;
  IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
  END IF;

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
 ,p_Bsc_Cause_Effect_Rel_Rec	IN      BSC_CAUSE_EFFECT_REL_PUB.Bsc_Cause_Effect_Rel_Rec
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count           	OUT NOCOPY     NUMBER
 ,x_msg_data            	OUT NOCOPY     VARCHAR2
) IS

l_count				NUMBER;

BEGIN

  -- I do not need to make validations. It just delete the record if exists.
  -- If it does not exist it is OK.
  DELETE FROM bsc_kpi_cause_effect_rels
  WHERE
      cause_indicator = p_Bsc_Cause_Effect_Rel_Rec.Cause_Indicator AND
      effect_indicator = p_Bsc_Cause_Effect_Rel_Rec.Effect_Indicator AND
      NVL(cause_level, 'KPI') = p_Bsc_Cause_Effect_Rel_Rec.Cause_Level AND
      NVL(effect_level, 'KPI') = p_Bsc_Cause_Effect_Rel_Rec.Effect_Level;

  IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
  END IF;

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
 ,p_indicator			IN      NUMBER
 ,p_level			IN      VARCHAR2
 ,x_return_status       	OUT NOCOPY     VARCHAR2
 ,x_msg_count           	OUT NOCOPY     NUMBER
 ,x_msg_data            	OUT NOCOPY     VARCHAR2
) IS

l_count				NUMBER;

BEGIN

  -- I do not need to make validations. It just delete the records if exists.
  -- If it does not exist it is OK.
  DELETE FROM bsc_kpi_cause_effect_rels
  WHERE
      (cause_indicator = p_indicator AND NVL(cause_level, 'KPI') = p_level) OR
      (effect_indicator = p_indicator AND NVL(effect_level, 'KPI') = p_level);

  IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
  END IF;

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

END BSC_CAUSE_EFFECT_REL_PVT;

/
