--------------------------------------------------------
--  DDL for Package Body BIS_FUNCTIONAL_AREA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_FUNCTIONAL_AREA_PVT" AS
/* $Header: BISVFASB.pls 120.0 2005/06/01 16:05:07 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVFASB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Private for populating the table BIS_FUNCTIONAL_ARES_TL   |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 24-NOV-2004 Aditya Rao  Created.                                      |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_FUNCTIONAL_AREA_PVT';

/*
  Private CRUD APIs
*/


PROCEDURE Create_Functional_Area(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS

    l_Func_Area_Rec   BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type;
    l_Count           NUMBER;

BEGIN
    SAVEPOINT CreateFuncAreaSP_Pvt;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    l_Func_Area_Rec := p_Func_Area_Rec;

    IF(l_Func_Area_Rec.Created_By IS NULL) THEN
        l_Func_Area_Rec.Created_By := FND_GLOBAL.USER_ID;
    END IF;

    IF(l_Func_Area_Rec.Last_Updated_By IS NULL) THEN
        l_Func_Area_Rec.Last_Updated_By := l_Func_Area_Rec.Created_By;
    END IF;

    IF(l_Func_Area_Rec.Last_Update_Login IS NULL) THEN
        l_Func_Area_Rec.Last_Update_Login := FND_GLOBAL.LOGIN_ID;
    END IF;

    IF(l_Func_Area_Rec.Last_Update_Date IS NULL) THEN
       l_Func_Area_Rec.Creation_Date    := SYSDATE;
       l_Func_Area_Rec.Last_Update_Date := SYSDATE;
    ELSE
       l_Func_Area_Rec.Creation_Date    := l_Func_Area_Rec.Last_Update_Date;
    END IF;

    -- INSERT THE ACTUAL VALUES INTO BASE TABLES
    INSERT INTO BIS_FUNCTIONAL_AREAS
    (
        FUNCTIONAL_AREA_ID
      , SHORT_NAME
      , CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATE_LOGIN
    )
    VALUES
    (
        l_Func_Area_Rec.Functional_Area_Id
      , l_Func_Area_Rec.Short_Name
      , l_Func_Area_Rec.Created_By
      , l_Func_Area_Rec.Creation_Date
      , l_Func_Area_Rec.Last_Updated_By
      , l_Func_Area_Rec.Last_Update_Date
      , l_Func_Area_Rec.Last_Update_Login
    );

    -- INSERT THE ACTUAL VALUES INTO TRANSLATABLE TABLES
    INSERT INTO BIS_FUNCTIONAL_AREAS_TL
    (
        FUNCTIONAL_AREA_ID
      , NAME
      , DESCRIPTION
      , LANGUAGE
      , SOURCE_LANG
      , CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATE_LOGIN
    )
    SELECT
        l_Func_Area_Rec.Functional_Area_Id
      , l_Func_Area_Rec.Name
      , l_Func_Area_Rec.Description
      , L.LANGUAGE_CODE
      , USERENV('LANG')
      , l_Func_Area_Rec.Created_By
      , l_Func_Area_Rec.Creation_Date
      , l_Func_Area_Rec.Last_Updated_By
      , l_Func_Area_Rec.Last_Update_Date
      , l_Func_Area_Rec.Last_Update_Login
   FROM  FND_LANGUAGES L
   WHERE L.INSTALLED_FLAG IN ('I', 'B')
   AND   NOT EXISTS
        (
          SELECT NULL
          FROM   BIS_FUNCTIONAL_AREAS_TL T
          WHERE  T.FUNCTIONAL_AREA_ID = l_Func_Area_Rec.Functional_Area_Id
          AND    T.LANGUAGE           = L.LANGUAGE_CODE
        );

  -- Commit if required
  IF (p_Commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateFuncAreaSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateFuncAreaSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateFuncAreaSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Create_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Create_Functional_Area ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreateFuncAreaSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Create_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Create_Functional_Area ';
        END IF;
END Create_Functional_Area;



-- Update Functional Area API
PROCEDURE Update_Functional_Area(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS
  l_Count                  NUMBER;
  l_Func_Area_Rec          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type;
BEGIN
    SAVEPOINT UpdateFuncAreaSP_Pvt;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    BIS_FUNCTIONAL_AREA_PVT.Retrieve_Functional_Area
    (
       p_Func_Area_Rec   => p_Func_Area_Rec
      ,x_Func_Area_Rec   => l_Func_Area_Rec
      ,x_Return_Status   => x_Return_Status
      ,x_Msg_Count       => x_Msg_Count
      ,x_Msg_Data        => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --DBMS_OUTPUT.PUT_LINE ('l_Func_Area_Rec.Short_Name - ' || l_Func_Area_Rec.Short_Name);
    -- Name can never be null
    IF (l_Func_Area_Rec.Name <> p_Func_Area_Rec.Name) THEN
      l_Func_Area_Rec.Name := p_Func_Area_Rec.Name;
    END IF;
    --DBMS_OUTPUT.PUT_LINE ('l_Func_Area_Rec.Name - ' || l_Func_Area_Rec.Name);

    IF ((p_Func_Area_Rec.Description IS NULL) OR (l_Func_Area_Rec.Description <> p_Func_Area_Rec.Description)) THEN
      l_Func_Area_Rec.Description := p_Func_Area_Rec.Description;
    END IF;

    IF(p_Func_Area_Rec.Last_Update_Date IS NULL) THEN
       l_Func_Area_Rec.Last_Update_Date := SYSDATE;
    ELSE
       l_Func_Area_Rec.Last_Update_Date := p_Func_Area_Rec.Last_Update_Date ;
    END IF;

    IF (p_Func_Area_Rec.Last_Updated_By IS NULL) THEN
      l_Func_Area_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;
    ELSE
      l_Func_Area_Rec.Last_Updated_By := p_Func_Area_Rec.Last_Updated_By;
    END IF;

    IF (p_Func_Area_Rec.Last_Update_Login IS NULL) THEN
      l_Func_Area_Rec.Last_Update_Login := FND_GLOBAL.LOGIN_ID;
    ELSE
      l_Func_Area_Rec.Last_Update_Login := p_Func_Area_Rec.Last_Update_Login;
    END IF;

    -- Update the base table
    UPDATE BIS_FUNCTIONAL_AREAS
    SET
        LAST_UPDATED_BY    = l_Func_Area_Rec.Last_Updated_By
      , LAST_UPDATE_DATE   = l_Func_Area_Rec.Last_Update_Date
      , LAST_UPDATE_LOGIN  = l_Func_Area_Rec.Last_Update_Login
    WHERE
        SHORT_NAME         = l_Func_Area_Rec.Short_Name;

    -- Translate the Measures
    BIS_FUNCTIONAL_AREA_PVT.Translate_Functional_Area(
      p_Api_Version     => 1.0
     ,p_Commit          => p_Commit
     ,p_Func_Area_Rec   => p_Func_Area_Rec
     ,x_Return_Status   => x_Return_Status
     ,x_Msg_Count       => x_Msg_Count
     ,x_Msg_Data        => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Commit if required
    IF (p_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateFuncAreaSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateFuncAreaSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateFuncAreaSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Update_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Update_Functional_Area ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateFuncAreaSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Update_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Update_Functional_Area ';
        END IF;

END Update_Functional_Area;

-- Translate the Functional  Area Name/Description
PROCEDURE Translate_Functional_Area(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS
  l_Count                  NUMBER;
  l_Func_Area_Rec          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type;

BEGIN
    SAVEPOINT TransFuncAreaSP_Pvt;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    BIS_FUNCTIONAL_AREA_PVT.Retrieve_Functional_Area
    (
       p_Func_Area_Rec   => p_Func_Area_Rec
      ,x_Func_Area_Rec   => l_Func_Area_Rec
      ,x_Return_Status   => x_Return_Status
      ,x_Msg_Count       => x_Msg_Count
      ,x_Msg_Data        => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Name can never be null
    IF (l_Func_Area_Rec.Name <> p_Func_Area_Rec.Name) THEN
      l_Func_Area_Rec.Name := p_Func_Area_Rec.Name;
    END IF;

    l_Func_Area_Rec.Description := p_Func_Area_Rec.Description;

    IF (p_Func_Area_Rec.Last_Update_Date IS NULL) THEN
       l_Func_Area_Rec.Last_Update_Date := SYSDATE;
    ELSE
       l_Func_Area_Rec.Last_Update_Date := p_Func_Area_Rec.Last_Update_Date;
    END IF;

    IF (p_Func_Area_Rec.Last_Updated_By IS NULL) THEN
      l_Func_Area_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;
    ELSE
      l_Func_Area_Rec.Last_Updated_By := p_Func_Area_Rec.Last_Updated_By;
    END IF;

    IF (p_Func_Area_Rec.Last_Update_Login IS NULL) THEN
      l_Func_Area_Rec.Last_Update_Login := FND_GLOBAL.LOGIN_ID;
    ELSE
      l_Func_Area_Rec.Last_Update_Login := p_Func_Area_Rec.Last_Update_Login;
    END IF;

    --DBMS_OUTPUT.PUT_LINE ('T l_Func_Area_Rec.Name  - ' || l_Func_Area_Rec.Name );
    --DBMS_OUTPUT.PUT_LINE ('T p_Func_Area_Rec.Name  - ' || p_Func_Area_Rec.Name);
    --DBMS_OUTPUT.PUT_LINE ('T l_Func_Area_Rec.Description  - ' || l_Func_Area_Rec.Description );
    --DBMS_OUTPUT.PUT_LINE ('T p_Func_Area_Rec.Description  - ' || p_Func_Area_Rec.Description);
    --DBMS_OUTPUT.PUT_LINE ('T l_Func_Area_Rec.Last_Update_Date - ' || l_Func_Area_Rec.Last_Update_Date);
    --DBMS_OUTPUT.PUT_LINE ('T p_Func_Area_Rec.Last_Updated_By - ' || p_Func_Area_Rec.Last_Updated_By);
    --DBMS_OUTPUT.PUT_LINE ('T l_Func_Area_Rec.Last_Update_Date - ' || l_Func_Area_Rec.Last_Update_Date);

    -- Update the base table
    UPDATE BIS_FUNCTIONAL_AREAS_TL
    SET
        NAME               = l_Func_Area_Rec.Name
      , DESCRIPTION        = l_Func_Area_Rec.Description
      , LAST_UPDATED_BY    = l_Func_Area_Rec.Last_Updated_By
      , LAST_UPDATE_DATE   = l_Func_Area_Rec.Last_Update_Date
      , LAST_UPDATE_LOGIN  = l_Func_Area_Rec.Last_Update_Login
      , SOURCE_LANG        = USERENV('LANG')
    WHERE
        FUNCTIONAL_AREA_ID = l_Func_Area_Rec.Functional_Area_Id
    AND USERENV('LANG')    IN (LANGUAGE, SOURCE_LANG);

    -- Translate the Measures

    -- Commit if required
    IF (p_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO TransFuncAreaSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO TransFuncAreaSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO TransFuncAreaSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Translate_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Translate_Functional_Area ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO TransFuncAreaSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Translate_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Translate_Functional_Area ';
        END IF;
END Translate_Functional_Area;

PROCEDURE Retrieve_Functional_Area(
  p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Func_Area_Rec       OUT NOCOPY  BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS

    l_Count           NUMBER;

    CURSOR cRetrieveFuncArea IS
     SELECT  F.FUNCTIONAL_AREA_ID
           , F.SHORT_NAME
           , F.NAME
           , F.DESCRIPTION
           , F.CREATED_BY
           , F.CREATION_DATE
           , F.LAST_UPDATED_BY
           , F.LAST_UPDATE_DATE
           , F.LAST_UPDATE_LOGIN
     FROM    BIS_FUNCTIONAL_AREAS_VL F
     WHERE   F.SHORT_NAME = p_Func_Area_Rec.Short_Name;

BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    l_Count := 0;

    FOR cRFA IN cRetrieveFuncArea LOOP
       x_Func_Area_Rec.Functional_Area_Id := cRFA.FUNCTIONAL_AREA_ID;
       x_Func_Area_Rec.Short_Name         := cRFA.SHORT_NAME;
       x_Func_Area_Rec.Name               := cRFA.NAME;
       x_Func_Area_Rec.Description        := cRFA.DESCRIPTION;
       x_Func_Area_Rec.Created_By         := cRFA.CREATED_BY;
       x_Func_Area_Rec.Creation_Date      := cRFA.CREATION_DATE;
       x_Func_Area_Rec.Last_Updated_By    := cRFA.LAST_UPDATED_BY;
       x_Func_Area_Rec.Last_Update_Date   := cRFA.LAST_UPDATE_DATE;
       x_Func_Area_Rec.Last_Update_Login  := cRFA.LAST_UPDATE_LOGIN;
       l_Count := 1;
    END LOOP;

    IF (l_Count = 0) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Retrieve_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Retrieve_Functional_Area ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Retrieve_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Retrieve_Functional_Area ';
        END IF;
END Retrieve_Functional_Area;



-- This is the Functional Area/Application ID dependency table

PROCEDURE Create_Func_Area_Apps_Dep (
  p_Api_Version         IN           NUMBER
 ,p_Commit              IN           VARCHAR2 := FND_API.G_FALSE
 ,p_Functional_Area_Id  IN           NUMBER
 ,p_Application_Id      IN           NUMBER
 ,x_Return_Status       OUT  NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT  NOCOPY  NUMBER
 ,x_Msg_Data            OUT  NOCOPY  VARCHAR2
) IS

   l_Count NUMBER;
   --l_Default_Flag VARCHAR2(1);

BEGIN
    SAVEPOINT CreateFuncAreaAppDepSP_Pvt;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO BIS_FUNC_AREA_APP_DEPENDENCY
    (
       FUNCTIONAL_AREA_ID
      ,APPLICATION_ID
    )
    VALUES
    (
       p_Functional_Area_Id
      ,p_Application_Id
    );

  -- Commit if required
  IF (p_Commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateFuncAreaAppDepSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateFuncAreaAppDepSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateFuncAreaAppDepSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Create_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Create_Func_Area_Apps_Dep ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreateFuncAreaAppDepSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Create_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Create_Func_Area_Apps_Dep ';
        END IF;
END Create_Func_Area_Apps_Dep;

-- Update Functional Area dependency with Application ID
PROCEDURE Update_Func_Area_Apps_Dep (
  p_Api_Version         IN           NUMBER
 ,p_Commit              IN           VARCHAR2 := FND_API.G_FALSE
 ,p_Functional_Area_Id  IN           NUMBER
 ,p_Application_Id      IN           NUMBER
 ,x_Return_Status       OUT  NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT  NOCOPY  NUMBER
 ,x_Msg_Data            OUT  NOCOPY  VARCHAR2
) IS
    l_Count             NUMBER;
    --l_Default_Flag      VARCHAR2(1);
    --l_Temp_Default_Flag VARCHAR2(1);

BEGIN
    SAVEPOINT UpdateFuncAreaAppDepSP_Pvt;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -- currently we do not have the default flag to update,
  -- this API is for future implementations.

  -- Commit if required
  IF (p_Commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateFuncAreaAppDepSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateFuncAreaAppDepSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateFuncAreaAppDepSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Update_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Update_Func_Area_Apps_Dep ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateFuncAreaAppDepSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Update_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Update_Func_Area_Apps_Dep ';
        END IF;

END Update_Func_Area_Apps_Dep;


-- Delete the Functional Area
PROCEDURE Delete_Functional_Area(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS
    l_Func_Area_Rec   BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type;
    l_Count           NUMBER;

    CURSOR c_FuncArea_Dep IS
      SELECT  B.FUNCTIONAL_AREA_ID,
              B.APPLICATION_ID
      FROM    BIS_FUNC_AREA_APP_DEPENDENCY B
      WHERE   B.FUNCTIONAL_AREA_ID = l_Func_Area_Rec.Functional_Area_Id;
BEGIN
    SAVEPOINT DeleteFuncAreaSP_Pvt;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    l_Func_Area_Rec := p_Func_Area_Rec;

    FOR cFAD IN c_FuncArea_Dep LOOP
       BIS_FUNCTIONAL_AREA_PVT.Remove_Func_Area_Apps_Dep (
             p_Api_Version         => 1.0
            ,p_Commit              => p_Commit
            ,p_Functional_Area_Id  => cFAD.FUNCTIONAL_AREA_ID
            ,p_Application_Id      => cFAD.APPLICATION_ID
            ,x_Return_Status       => x_Return_Status
            ,x_Msg_Count           => x_Msg_Count
            ,x_Msg_Data            => x_Msg_Data
       );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    END LOOP;

    DELETE BIS_FUNCTIONAL_AREAS
    WHERE  FUNCTIONAL_AREA_ID = l_Func_Area_Rec.Functional_Area_Id
    AND    SHORT_NAME         = l_Func_Area_Rec.Short_Name;

    DELETE BIS_FUNCTIONAL_AREAS_TL
    WHERE  FUNCTIONAL_AREA_ID = l_Func_Area_Rec.Functional_Area_Id;
  -- Commit if required
    IF (p_Commit = FND_API.G_TRUE) THEN
       COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteFuncAreaSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteFuncAreaSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteFuncAreaSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Delete_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Delete_Functional_Area ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteFuncAreaSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Delete_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Delete_Functional_Area ';
        END IF;
END Delete_Functional_Area;

-- remove Functional Area/Application ID dependency
PROCEDURE Remove_Func_Area_Apps_Dep (
  p_Api_Version         IN           NUMBER
 ,p_Commit              IN           VARCHAR2 := FND_API.G_FALSE
 ,p_Functional_Area_Id  IN           NUMBER
 ,p_Application_Id      IN           NUMBER
 ,x_Return_Status       OUT  NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT  NOCOPY  NUMBER
 ,x_Msg_Data            OUT  NOCOPY  VARCHAR2
) IS
    l_Count           NUMBER;

BEGIN
    SAVEPOINT RemoveFuncAreaDependencySP_Pvt;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    DELETE BIS_FUNC_AREA_APP_DEPENDENCY B
    WHERE  B.FUNCTIONAL_AREA_ID = p_Functional_Area_Id
    AND    B.APPLICATION_ID     = p_Application_Id;

  -- Commit if required
    IF (p_Commit = FND_API.G_TRUE) THEN
       COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO RemoveFuncAreaDependencySP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO RemoveFuncAreaDependencySP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO RemoveFuncAreaDependencySP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Remove_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Remove_Func_Area_Apps_Dep ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO RemoveFuncAreaDependencySP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PVT.Remove_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PVT.Remove_Func_Area_Apps_Dep ';
        END IF;
END Remove_Func_Area_Apps_Dep;


-- procedure to add a language.
PROCEDURE Add_Language IS
BEGIN

    DELETE FROM BIS_FUNCTIONAL_AREAS_TL T
    WHERE NOT EXISTS
    (
      SELECT NULL
      FROM   BIS_FUNCTIONAL_AREAS B
      WHERE  B.FUNCTIONAL_AREA_ID = T.FUNCTIONAL_AREA_ID
    );

    UPDATE BIS_FUNCTIONAL_AREAS_TL T SET (
        NAME,
        DESCRIPTION
    ) = (SELECT
            B.NAME,
            B.DESCRIPTION
         FROM  BIS_FUNCTIONAL_AREAS_TL B
         WHERE B.FUNCTIONAL_AREA_ID = T.FUNCTIONAL_AREA_ID
         AND   B.LANGUAGE           = T.SOURCE_LANG)
         WHERE (
            T.FUNCTIONAL_AREA_ID,
            T.LANGUAGE
         ) IN (SELECT
                SUBT.FUNCTIONAL_AREA_ID,
                SUBT.LANGUAGE
                FROM  BIS_FUNCTIONAL_AREAS_TL SUBB, BIS_FUNCTIONAL_AREAS_TL SUBT
                WHERE SUBB.FUNCTIONAL_AREA_ID = SUBT.FUNCTIONAL_AREA_ID
                AND   SUBB.LANGUAGE           = SUBT.SOURCE_LANG
                AND (
                     SUBB.NAME              <> SUBT.NAME
                     OR SUBB.DESCRIPTION    <> SUBT.DESCRIPTION
                    )
                );

    INSERT INTO BIS_FUNCTIONAL_AREAS_TL
    (
        FUNCTIONAL_AREA_ID
      , NAME
      , DESCRIPTION
      , LANGUAGE
      , SOURCE_LANG
      , CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATE_LOGIN
    )
    SELECT
        B.FUNCTIONAL_AREA_ID
      , B.NAME
      , B.DESCRIPTION
      , L.LANGUAGE_CODE
      , B.SOURCE_LANG
      , B.CREATED_BY
      , B.CREATION_DATE
      , B.LAST_UPDATED_BY
      , B.LAST_UPDATE_DATE
      , B.LAST_UPDATE_LOGIN
   FROM  BIS_FUNCTIONAL_AREAS_TL B, FND_LANGUAGES L
   WHERE L.INSTALLED_FLAG IN ('I', 'B')
   AND   B.LANGUAGE = USERENV('LANG')
   AND   NOT EXISTS
        (
          SELECT NULL
          FROM   BIS_FUNCTIONAL_AREAS_TL T
          WHERE  T.FUNCTIONAL_AREA_ID = B.FUNCTIONAL_AREA_ID
          AND    T.LANGUAGE           = L.LANGUAGE_CODE
        );

END Add_Language;

END BIS_FUNCTIONAL_AREA_PVT;

/
