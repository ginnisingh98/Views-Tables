--------------------------------------------------------
--  DDL for Package Body BIS_WEIGHTED_MEASURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_WEIGHTED_MEASURE_PVT" AS
/* $Header: BISVWMEB.pls 120.1 2005/09/16 17:02:02 jxyu noship $ */
/*======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BISVWMB.pls                                                     |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      April 11, 2005                                                  |
 | Creator:                                                                             |
 |                      William Cano                                                    |
 |                                                                                      |
 | Description:                                                                         |
 |                      Public version.		                     		        |
 |			This package Handle Weighted Measures			        |
 |                                                                                      |
 |                                                                                      |
 |   History:                                                                           |
 |       04/11/05    wcano    Created.                                                  |
 |       09/15/05    jxyu     Added Update_WM_Last_Update_Info API for bug#4427932.     |
 |                                                                                      |
 +======================================================================================*/

-- Abbreviation Used"
--   WM -> Weighted Measure
--   SN -> Short Name

 ------- APIs for tables BIS_WEIGHTED_MEASURE_DEPENDS
/*******************************************************************
 *******************************************************************/
PROCEDURE Create_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
   SAVEPOINT CreateWMDependencyPVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   INSERT INTO BIS_WEIGHTED_MEASURE_DEPENDS(
       WEIGHTED_MEASURE_ID
       ,DEPENDENT_MEASURE_ID
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_LOGIN
   ) VALUES (
      p_Bis_WM_Rec.weighted_measure_id
     ,p_Bis_WM_Rec.dependent_measure_id
     ,p_Bis_WM_Rec.Creation_Date
     ,p_Bis_WM_Rec.Created_By
     ,p_Bis_WM_Rec.Last_Update_Date
     ,p_Bis_WM_Rec.Last_Updated_By
     ,p_Bis_WM_Rec.Last_Update_Login
   );
  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;
  x_Bis_WM_Rec := p_Bis_WM_Rec;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateWMDependencyPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateWMDependencyPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO CreateWMDependencyPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Create_WM_Dependency ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Create_WM_Dependency ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Create_WM_Dependency;


/*******************************************************************
 *******************************************************************/
PROCEDURE Retrieve_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
    SAVEPOINT Retrieve_WM_Dependency_PVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

SELECT
   WEIGHTED_MEASURE_ID
   ,DEPENDENT_MEASURE_ID
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_LOGIN
INTO
      x_Bis_WM_Rec.weighted_measure_id
     ,x_Bis_WM_Rec.dependent_measure_id
     ,x_Bis_WM_Rec.Creation_Date
     ,x_Bis_WM_Rec.Created_By
     ,x_Bis_WM_Rec.Last_Update_Date
     ,x_Bis_WM_Rec.Last_Updated_By
     ,x_Bis_WM_Rec.Last_Update_Login
FROM BIS_WEIGHTED_MEASURE_DEPENDS
WHERE WEIGHTED_MEASURE_ID = p_Bis_WM_Rec.weighted_measure_id
  AND DEPENDENT_MEASURE_ID = p_Bis_WM_Rec.dependent_measure_id;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Retrieve_WM_Dependency_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Retrieve_WM_Dependency_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        raise;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO Retrieve_WM_Dependency_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Dependency ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Dependency ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;

END Retrieve_WM_Dependency;

/*******************************************************************
 *******************************************************************/
PROCEDURE Update_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
    SAVEPOINT bis_Update_WM_Dependency_PVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   UPDATE BIS_WEIGHTED_MEASURE_DEPENDS SET
       LAST_UPDATE_DATE = p_Bis_WM_Rec.Last_Update_Date
       ,LAST_UPDATED_BY = p_Bis_WM_Rec.Last_Updated_By
       ,LAST_UPDATE_LOGIN = p_Bis_WM_Rec.Last_Update_Login
   WHERE WEIGHTED_MEASURE_ID = p_Bis_WM_Rec.weighted_measure_id
     AND DEPENDENT_MEASURE_ID = p_Bis_WM_Rec.dependent_measure_id;

  x_Bis_WM_Rec := p_Bis_WM_Rec;
  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Update_WM_Dependency_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Update_WM_Dependency_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Update_WM_Dependency_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Update_WM_Dependency ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Update_WM_Dependency ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Update_WM_Dependency;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
   SAVEPOINT Delete_WM_Dependency_PVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

     DELETE BIS_WEIGHTED_MEASURE_DEPENDS
     WHERE WEIGHTED_MEASURE_ID = p_Bis_WM_Rec.weighted_measure_id
        AND DEPENDENT_MEASURE_ID = p_Bis_WM_Rec.dependent_measure_id;


  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;
  x_Bis_WM_Rec := p_Bis_WM_Rec;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Delete_WM_Dependency_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_WM_Dependency_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Delete_WM_Dependency_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Dependency ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Dependency ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Delete_WM_Dependency;

 ------- APIs for table BIS_WEIGHTED_MEASURE_DEFNS

/*******************************************************************
 *******************************************************************/
PROCEDURE Create_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_weighted_definition_id NUMBER;
BEGIN
  SAVEPOINT CreateWMDefinitionPVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   INSERT INTO BIS_WEIGHTED_MEASURE_DEFNS(
       WEIGHTED_DEFINITION_ID
       ,WEIGHTED_MEASURE_ID
       ,VIEWBY_DIMENSION_SHORT_NAME
       ,VIEWBY_DIM_LEVEL_SHORT_NAME
       ,FILTER_DIMENSION_SHORT_NAME
       ,FILTER_DIM_LEVEL_SHORT_NAME
       ,TIME_DIMENSION_SHORT_NAME
       ,TIME_DIM_LEVEL_SHORT_NAME
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_LOGIN
   ) VALUES (
      p_Bis_WM_Rec.weighted_definition_id
     ,p_Bis_WM_Rec.weighted_measure_id
     ,p_Bis_WM_Rec.VIEWBY_dimension_SN
     ,p_Bis_WM_Rec.VIEWBY_dim_level_SN
     ,p_Bis_WM_Rec.FILTER_dimension_SN
     ,p_Bis_WM_Rec.FILTER_dim_level_SN
     ,p_Bis_WM_Rec.time_dimension_short_name
     ,p_Bis_WM_Rec.time_dim_level_short_name
     ,p_Bis_WM_Rec.Creation_Date
     ,p_Bis_WM_Rec.Created_By
     ,p_Bis_WM_Rec.Last_Update_Date
     ,p_Bis_WM_Rec.Last_Updated_By
     ,p_Bis_WM_Rec.Last_Update_Login
   );

 x_Bis_WM_Rec := p_Bis_WM_Rec;
  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateWMDefinitionPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateWMDefinitionPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO CreateWMDefinitionPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Create_WM_Definition ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Create_WM_Definition ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Create_WM_Definition;

/*******************************************************************
 *******************************************************************/
PROCEDURE Retrieve_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
    SAVEPOINT Retrieve_WM_Definition_PVT;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

SELECT
   WEIGHTED_DEFINITION_ID
   ,WEIGHTED_MEASURE_ID
   ,VIEWBY_DIMENSION_SHORT_NAME
   ,VIEWBY_DIM_LEVEL_SHORT_NAME
   ,FILTER_DIMENSION_SHORT_NAME
   ,FILTER_DIM_LEVEL_SHORT_NAME
   ,TIME_DIMENSION_SHORT_NAME
   ,TIME_DIM_LEVEL_SHORT_NAME
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_LOGIN
INTO
      x_Bis_WM_Rec.weighted_definition_id
     ,x_Bis_WM_Rec.weighted_measure_id
     ,x_Bis_WM_Rec.VIEWBY_dimension_SN
     ,x_Bis_WM_Rec.VIEWBY_dim_level_SN
     ,x_Bis_WM_Rec.FILTER_dimension_SN
     ,x_Bis_WM_Rec.FILTER_dim_level_SN
     ,x_Bis_WM_Rec.time_dimension_short_name
     ,x_Bis_WM_Rec.time_dim_level_short_name
     ,x_Bis_WM_Rec.Creation_Date
     ,x_Bis_WM_Rec.Created_By
     ,x_Bis_WM_Rec.Last_Update_Date
     ,x_Bis_WM_Rec.Last_Updated_By
     ,x_Bis_WM_Rec.Last_Update_Login
FROM BIS_WEIGHTED_MEASURE_DEFNS
WHERE WEIGHTED_DEFINITION_ID = p_Bis_WM_Rec.weighted_definition_id;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Retrieve_WM_Definition_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Retrieve_WM_Definition_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        raise;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Definition ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Definition ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO Retrieve_WM_Definition_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Definition ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Definition ';
        END IF;
        raise;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Retrieve_WM_Definition;

/*******************************************************************
 *******************************************************************/
PROCEDURE Update_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT bis_Update_WM_Definition_PVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   UPDATE BIS_WEIGHTED_MEASURE_DEFNS SET
       WEIGHTED_MEASURE_ID = p_Bis_WM_Rec.weighted_measure_id
       ,VIEWBY_DIMENSION_SHORT_NAME = p_Bis_WM_Rec.VIEWBY_dimension_SN
       ,VIEWBY_DIM_LEVEL_SHORT_NAME = p_Bis_WM_Rec.VIEWBY_dim_level_SN
       ,FILTER_DIMENSION_SHORT_NAME = p_Bis_WM_Rec.FILTER_dimension_SN
       ,FILTER_DIM_LEVEL_SHORT_NAME = p_Bis_WM_Rec.FILTER_dim_level_SN
       ,TIME_DIMENSION_SHORT_NAME = p_Bis_WM_Rec.time_dimension_short_name
       ,TIME_DIM_LEVEL_SHORT_NAME = p_Bis_WM_Rec.time_dim_level_short_name
       ,LAST_UPDATE_DATE = p_Bis_WM_Rec.Last_Update_Date
       ,LAST_UPDATED_BY = p_Bis_WM_Rec.Last_Updated_By
       ,LAST_UPDATE_LOGIN = p_Bis_WM_Rec.Last_Update_Login
   WHERE
   WEIGHTED_DEFINITION_ID =  p_Bis_WM_Rec.weighted_definition_id;

  x_Bis_WM_Rec := p_Bis_WM_Rec;
  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Update_WM_Definition_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Update_WM_Definition_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Update_WM_Definition_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Update_WM_Definition ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Update_WM_Definition ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Update_WM_Definition;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
    SAVEPOINT Delete_WM_Definition_PVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   DELETE BIS_WEIGHTED_MEASURE_DEFNS
   WHERE WEIGHTED_DEFINITION_ID = p_Bis_WM_Rec.weighted_definition_id;

  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;
  x_Bis_WM_Rec := p_Bis_WM_Rec;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Delete_WM_Definition_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_WM_Definition_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Delete_WM_Definition_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Definition ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Definition ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Delete_WM_Definition;

 ------- APIs for table BIS_WEIGHTED_MEASURE_PARAMS

/*******************************************************************
 *******************************************************************/
PROCEDURE Create_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_count NUMBER;
BEGIN
   SAVEPOINT CreateWMParameterPVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   INSERT INTO BIS_WEIGHTED_MEASURE_PARAMS(
       WEIGHTED_PARAMETER_ID
       ,WEIGHTED_DEFINITION_ID
       ,TIME_LEVEL_VALUE_ID
       ,FILTER_LEVEL_VALUE_ID
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_LOGIN
   ) VALUES (
     p_Bis_WM_Rec.weighted_parameter_id
     ,p_Bis_WM_Rec.weighted_definition_id
     ,p_Bis_WM_Rec.time_level_value_id
     ,p_Bis_WM_Rec.filter_level_value_id
     ,p_Bis_WM_Rec.Creation_Date
     ,p_Bis_WM_Rec.Created_By
     ,p_Bis_WM_Rec.Last_Update_Date
     ,p_Bis_WM_Rec.Last_Updated_By
     ,p_Bis_WM_Rec.Last_Update_Login
   );

  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;
  x_Bis_WM_Rec := p_Bis_WM_Rec;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateWMParameterPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateWMParameterPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO CreateWMParameterPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Create_WM_Parameter ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Create_WM_Parameter ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Create_WM_Parameter;

/*******************************************************************
 *******************************************************************/
PROCEDURE Retrieve_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
    SAVEPOINT Retrieve_WM_Parameter_PVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

SELECT
   WEIGHTED_PARAMETER_ID
   ,WEIGHTED_DEFINITION_ID
   ,time_level_value_id
   ,FILTER_LEVEL_VALUE_ID
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_LOGIN
INTO
     x_Bis_WM_Rec.weighted_parameter_id
     ,x_Bis_WM_Rec.weighted_definition_id
     ,x_Bis_WM_Rec.time_level_value_id
     ,x_Bis_WM_Rec.FILTER_level_value_id
     ,x_Bis_WM_Rec.Creation_Date
     ,x_Bis_WM_Rec.Created_By
     ,x_Bis_WM_Rec.Last_Update_Date
     ,x_Bis_WM_Rec.Last_Updated_By
     ,x_Bis_WM_Rec.Last_Update_Login
FROM BIS_WEIGHTED_MEASURE_PARAMS
WHERE WEIGHTED_PARAMETER_ID = p_Bis_WM_Rec.weighted_parameter_id;



EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Retrieve_WM_Parameter_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Retrieve_WM_Parameter_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        raise;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO Retrieve_WM_Parameter_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Parameter ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Parameter ';
        END IF;
        raise;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Retrieve_WM_Parameter;

/*******************************************************************
 *******************************************************************/
PROCEDURE Update_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT bis_Update_WM_Parameter_PVT;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   UPDATE BIS_WEIGHTED_MEASURE_PARAMS SET
       WEIGHTED_DEFINITION_ID = p_Bis_WM_Rec.weighted_definition_id
       ,TIME_LEVEL_VALUE_ID = p_Bis_WM_Rec.time_level_value_id
       ,FILTER_LEVEL_VALUE_ID = p_Bis_WM_Rec.filter_level_value_id
       ,LAST_UPDATE_DATE = p_Bis_WM_Rec.Last_Update_Date
       ,LAST_UPDATED_BY = p_Bis_WM_Rec.Last_Updated_By
       ,LAST_UPDATE_LOGIN = p_Bis_WM_Rec.Last_Update_Login
   WHERE WEIGHTED_PARAMETER_ID = p_Bis_WM_Rec.weighted_parameter_id;

  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;
  x_Bis_WM_Rec := p_Bis_WM_Rec;

  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Update_WM_Parameter_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Update_WM_Parameter_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Update_WM_Parameter_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Update_WM_Parameter ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Update_WM_Parameter ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Update_WM_Parameter;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
    SAVEPOINT Delete_WM_Parameter_PVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   DELETE  BIS_WEIGHTED_MEASURE_PARAMS
   WHERE WEIGHTED_PARAMETER_ID = p_Bis_WM_Rec.weighted_parameter_id;

  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;
  x_Bis_WM_Rec := p_Bis_WM_Rec;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Delete_WM_Parameter_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_WM_Parameter_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Delete_WM_Parameter_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Parameter ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Parameter ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Delete_WM_Parameter;

------- APIs for table BIS_WEIGHTED_MEASURE_WEIGHTS

/*******************************************************************
 *******************************************************************/
PROCEDURE Create_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
   SAVEPOINT CreateWMDependencyPVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   INSERT INTO BIS_WEIGHTED_MEASURE_WEIGHTS(
       WEIGHT_ID
       ,WEIGHTED_PARAMETER_ID
       ,DEPENDENT_MEASURE_ID
       ,WEIGHT
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_LOGIN
   ) VALUES (
     p_Bis_WM_Rec.weight_id
     ,p_Bis_WM_Rec.weighted_parameter_id
     ,p_Bis_WM_Rec.dependent_measure_id
     ,p_Bis_WM_Rec.weight
     ,p_Bis_WM_Rec.Creation_Date
     ,p_Bis_WM_Rec.Created_By
     ,p_Bis_WM_Rec.Last_Update_Date
     ,p_Bis_WM_Rec.Last_Updated_By
     ,p_Bis_WM_Rec.Last_Update_Login
   );
  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;
  x_Bis_WM_Rec := p_Bis_WM_Rec;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateWMDependencyPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateWMDependencyPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO CreateWMDependencyPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Create_WM_Weight ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Create_WM_Weight ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Create_WM_Weight;

/*******************************************************************
 *******************************************************************/
PROCEDURE Retrieve_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
    SAVEPOINT bis_Retrieve_WM_Weight_PVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

SELECT
   WEIGHT_ID
   ,WEIGHTED_PARAMETER_ID
   ,DEPENDENT_MEASURE_ID
   ,WEIGHT
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_LOGIN
INTO
     x_Bis_WM_Rec.weight_id
     ,x_Bis_WM_Rec.weighted_parameter_id
     ,x_Bis_WM_Rec.dependent_measure_id
     ,x_Bis_WM_Rec.weight
     ,x_Bis_WM_Rec.Creation_Date
     ,x_Bis_WM_Rec.Created_By
     ,x_Bis_WM_Rec.Last_Update_Date
     ,x_Bis_WM_Rec.Last_Updated_By
     ,x_Bis_WM_Rec.Last_Update_Login
FROM BIS_WEIGHTED_MEASURE_WEIGHTS
WHERE WEIGHT_ID = p_Bis_WM_Rec.weight_id;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Weight ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Weight ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Weight ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Weight ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
--        raise;
END Retrieve_WM_Weight;

/*******************************************************************
 *******************************************************************/
PROCEDURE Update_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN

 SAVEPOINT bis_Update_WM_Weight_PVT;
 x_return_status :=  FND_API.G_RET_STS_SUCCESS;

 UPDATE BIS_WEIGHTED_MEASURE_WEIGHTS SET
   WEIGHT_ID = p_Bis_WM_Rec.weight_id
   ,WEIGHTED_PARAMETER_ID = p_Bis_WM_Rec.weighted_parameter_id
   ,DEPENDENT_MEASURE_ID = p_Bis_WM_Rec.dependent_measure_id
   ,WEIGHT = p_Bis_WM_Rec.weight
   ,LAST_UPDATE_DATE = p_Bis_WM_Rec.Last_Update_Date
   ,LAST_UPDATED_BY = p_Bis_WM_Rec.Last_Updated_By
   ,LAST_UPDATE_LOGIN = p_Bis_WM_Rec.Last_Update_Login
 WHERE WEIGHT_ID = p_Bis_WM_Rec.weight_id;

 x_Bis_WM_Rec := p_Bis_WM_Rec;
 IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
 END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Update_WM_Weight_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Update_WM_Weight_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Update_WM_Weight_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Update_WM_Weight ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Update_WM_Weight ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Update_WM_Weight;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
   SAVEPOINT Delete_WM_Weight_PVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  DELETE BIS_WEIGHTED_MEASURE_WEIGHTS
  WHERE WEIGHT_ID = p_Bis_WM_Rec.weight_id;

  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;
  x_Bis_WM_Rec := p_Bis_WM_Rec;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Delete_WM_Weight_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_WM_Weight_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Delete_WM_Weight_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Weight ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Weight ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Delete_WM_Weight;

------- APIs for table BIS_WEIGHTED_MEASURE_SCORES
/*******************************************************************
 *******************************************************************/
PROCEDURE Create_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
   SAVEPOINT bisCreateWMScorePVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   INSERT INTO BIS_WEIGHTED_MEASURE_SCORES(
       WEIGHT_ID
       ,LOW_RANGE
       ,HIGH_RANGE
       ,SCORE
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_LOGIN
   ) VALUES (
      p_Bis_WM_Rec.weight_id
     ,p_Bis_WM_Rec.low_range
     ,p_Bis_WM_Rec.high_range
     ,p_Bis_WM_Rec.score
     ,p_Bis_WM_Rec.Creation_Date
     ,p_Bis_WM_Rec.Created_By
     ,p_Bis_WM_Rec.Last_Update_Date
     ,p_Bis_WM_Rec.Last_Updated_By
     ,p_Bis_WM_Rec.Last_Update_Login
   );
  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;
  x_Bis_WM_Rec := p_Bis_WM_Rec;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bisCreateWMScorePVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bisCreateWMScorePVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bisCreateWMScorePVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Create_WM_Score ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Create_WM_Score ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Create_WM_Score;

/*******************************************************************
 *******************************************************************/
PROCEDURE Retrieve_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
    SAVEPOINT bis_Retrieve_WM_Score_PVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

SELECT
   WEIGHT_ID
   ,LOW_RANGE
   ,HIGH_RANGE
   ,SCORE
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_LOGIN
INTO
      x_Bis_WM_Rec.weight_id
     ,x_Bis_WM_Rec.low_range
     ,x_Bis_WM_Rec.high_range
     ,x_Bis_WM_Rec.score
     ,x_Bis_WM_Rec.Creation_Date
     ,x_Bis_WM_Rec.Created_By
     ,x_Bis_WM_Rec.Last_Update_Date
     ,x_Bis_WM_Rec.Last_Updated_By
     ,x_Bis_WM_Rec.Last_Update_Login
FROM BIS_WEIGHTED_MEASURE_SCORES
WHERE WEIGHT_ID = p_Bis_WM_Rec.weight_id
   AND LOW_RANGE = p_Bis_WM_Rec.low_range
   AND HIGH_RANGE = p_Bis_WM_Rec.high_range;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Retrieve_WM_Score_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Retrieve_WM_Score_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Score ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Score ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Retrieve_WM_Score_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Score ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Score ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Retrieve_WM_Score;

/*******************************************************************
 *******************************************************************/
PROCEDURE Update_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
   SAVEPOINT bis_Update_WM_Score_PVT;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   UPDATE BIS_WEIGHTED_MEASURE_SCORES SET
       WEIGHT_ID = p_Bis_WM_Rec.weight_id
       ,LOW_RANGE = p_Bis_WM_Rec.low_range
       ,HIGH_RANGE = p_Bis_WM_Rec.high_range
       ,SCORE = p_Bis_WM_Rec.score
       ,LAST_UPDATE_DATE = p_Bis_WM_Rec.Last_Update_Date
       ,LAST_UPDATED_BY = p_Bis_WM_Rec.Last_Updated_By
       ,LAST_UPDATE_LOGIN = p_Bis_WM_Rec.Last_Update_Login
   WHERE WEIGHT_ID = p_Bis_WM_Rec.weight_id
     AND LOW_RANGE = p_Bis_WM_Rec.low_range
     AND HIGH_RANGE = p_Bis_WM_Rec.high_range;

  x_Bis_WM_Rec := p_Bis_WM_Rec;
  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Update_WM_Score_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Update_WM_Score_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Update_WM_Score_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Update_WM_Score ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Update_WM_Score ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Update_WM_Score;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT Delete_WM_Score_PVT;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

IF p_Bis_WM_Rec.low_range IS NULL AND p_Bis_WM_Rec.low_range IS NULL THEN
-- delete all the Scores for a specific Weight_id
-- Use for Cascading
   DELETE BIS_WEIGHTED_MEASURE_SCORES
   WHERE WEIGHT_ID = p_Bis_WM_Rec.weight_id;
ELSE
-- Delete jus one Score
   DELETE BIS_WEIGHTED_MEASURE_SCORES
   WHERE WEIGHT_ID = p_Bis_WM_Rec.weight_id
     AND LOW_RANGE = p_Bis_WM_Rec.low_range
     AND HIGH_RANGE = p_Bis_WM_Rec.high_range;
END IF;

IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
END IF;
x_Bis_WM_Rec := p_Bis_WM_Rec;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Delete_WM_Score_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_WM_Score_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Delete_WM_Score_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Score ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Score ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
    END Delete_WM_Score;

/*******************************************************************
 *******************************************************************/
function validate_measure_id(
  measure_id     IN   NUMBER
) RETURN VARCHAR2 IS
  l_return_value VARCHAR2 (1);
  l_count  NUMBER;
BEGIN
    l_return_value := FND_API.G_TRUE;
    -- Pending code the validation
    SELECT COUNT(INDICATOR_ID)
    INTO l_count
    FROM BIS_INDICATORS
    WHERE INDICATOR_ID = measure_id;

  --DBMS_OUTPUT.PUT_LINE('validate_measure_id: measure_id = '|| measure_id);
  --DBMS_OUTPUT.PUT_LINE('validate_measure_id: l_count = '||l_count);

    IF l_count = 0 THEN
      l_return_value := FND_API.G_FALSE;
    END IF;

--    l_return_value := FND_API.G_TRUE;  -- This need to be deleted

    RETURN l_return_value;


EXCEPTION
  WHEN OTHERS THEN
  return l_return_value;
end validate_measure_id;


/*******************************************************************
 *******************************************************************/
PROCEDURE Update_WM_Last_Update_Info(
  p_commit          IN VARCHAR2 := FND_API.G_FALSE
 ,p_weighted_measure_id      IN NUMBER
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
l_user_id           NUMBER;
l_login_id          NUMBER;
l_dataset_id        NUMBER;
BEGIN

   SAVEPOINT Update_WM_Last_Update_Info;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    l_user_id := fnd_global.USER_ID;
    l_login_id := fnd_global.LOGIN_ID;

    UPDATE bis_indicators
    SET
      last_update_date = sysdate
     ,last_updated_by = l_user_id
     ,last_update_login = l_login_id
    WHERE indicator_id = p_weighted_measure_id;

    SELECT dataset_id
    INTO l_dataset_id
    FROM bis_indicators
    WHERE indicator_id = p_weighted_measure_id;

    UPDATE bsc_sys_datasets_b
    SET
      last_update_date = sysdate
     ,last_updated_by = l_user_id
     ,last_update_login = l_login_id
    WHERE dataset_id = l_dataset_id;

  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Update_WM_Last_Update_Info;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Update_WM_Last_Update_Info;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Update_WM_Last_Update_Info;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PVT.Update_WM_Last_Update_Info ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PVT.Update_WM_Last_Update_Info ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Update_WM_Last_Update_Info;


END BIS_WEIGHTED_MEASURE_PVT;

/
