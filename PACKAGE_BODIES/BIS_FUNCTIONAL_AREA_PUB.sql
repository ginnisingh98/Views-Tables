--------------------------------------------------------
--  DDL for Package Body BIS_FUNCTIONAL_AREA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_FUNCTIONAL_AREA_PUB" AS
/* $Header: BISPFASB.pls 120.0 2005/06/01 16:38:23 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPFASB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper for populating the table BIS_FUNCTIONAL_ARES_TL   |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 24-NOV-2004 Aditya Rao  Created.                                      |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_FUNCTIONAL_AREA_PUB';

/*
  PRIVATE Validation APIs
*/

PROCEDURE Validate_Functional_Area(
  p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,p_Action_Type         IN          VARCHAR2
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);


PROCEDURE Validate_Func_Area_Apps_Dep (
  p_Functional_Area_Id  IN           NUMBER
 ,p_Application_Id      IN           NUMBER
 ,p_Action_Type         IN           VARCHAR2
 ,x_Return_Status       OUT  NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT  NOCOPY  NUMBER
 ,x_Msg_Data            OUT  NOCOPY  VARCHAR2
);

FUNCTION Get_Next_Functional_Area_Id RETURN NUMBER;
FUNCTION Get_FA_Id_By_Short_Name (p_Functional_Area_Short_Name IN VARCHAR2)RETURN NUMBER;

/*
  PUBLIC accessible CRUD APIs
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
    SAVEPOINT CreateFuncAreaSP;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    l_Func_Area_Rec := p_Func_Area_Rec;

    l_Count := 0;
    l_Func_Area_Rec.Functional_Area_Id := Get_Next_Functional_Area_Id;

    Validate_Functional_Area(
      p_Func_Area_Rec   => l_Func_Area_Rec
     ,p_Action_Type     => C_CREATE
     ,x_Return_Status   => x_Return_Status
     ,x_Msg_Count       => x_Msg_Count
     ,x_Msg_Data        => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call the private PL/SQL API
    BIS_FUNCTIONAL_AREA_PVT.Create_Functional_Area(
      p_Api_Version      => 1.0
     ,p_Commit           => p_Commit
     ,p_Func_Area_Rec    => l_Func_Area_Rec
     ,x_Return_Status    => x_Return_Status
     ,x_Msg_Count        => x_Msg_Count
     ,x_Msg_Data         => x_Msg_Data
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
        ROLLBACK TO CreateFuncAreaSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateFuncAreaSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateFuncAreaSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Create_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Create_Functional_Area ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreateFuncAreaSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Create_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Create_Functional_Area ';
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
    SAVEPOINT UpdateFuncAreaSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    Validate_Functional_Area(
      p_Func_Area_Rec   => p_Func_Area_Rec
     ,p_Action_Type     => C_UPDATE
     ,x_Return_Status   => x_Return_Status
     ,x_Msg_Count       => x_Msg_Count
     ,x_Msg_Data        => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  -- *** PUT IT HERE ***
    BIS_FUNCTIONAL_AREA_PVT.Update_Functional_Area(
      p_Api_Version    => 1.0
     ,p_Commit         => p_Commit
     ,p_Func_Area_Rec  => p_Func_Area_Rec
     ,x_Return_Status  => x_Return_Status
     ,x_Msg_Count      => x_Msg_Count
     ,x_Msg_Data       => x_Msg_Data
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
        ROLLBACK TO UpdateFuncAreaSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateFuncAreaSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateFuncAreaSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Update_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Update_Functional_Area ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateFuncAreaSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Update_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Update_Functional_Area ';
        END IF;

END Update_Functional_Area;

-- Retrieve Functional Area API

PROCEDURE Retrieve_Functional_Area(
  p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Func_Area_Rec       OUT NOCOPY  BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS

BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;


    BIS_FUNCTIONAL_AREA_PVT.Retrieve_Functional_Area(
      p_Func_Area_Rec   => p_Func_Area_Rec
     ,x_Func_Area_Rec   => x_Func_Area_Rec
     ,x_Return_Status   => x_Return_Status
     ,x_Msg_Count       => x_Msg_Count
     ,x_Msg_Data        => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
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
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Retrieve_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Retrieve_Functional_Area ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Retrieve_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Retrieve_Functional_Area ';
        END IF;
END Retrieve_Functional_Area;


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
    SAVEPOINT TransFuncAreaSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    -- Modularize this into a single API (Update and Retrieve)

    Validate_Functional_Area(
      p_Func_Area_Rec   => p_Func_Area_Rec
     ,p_Action_Type     => C_UPDATE
     ,x_Return_Status   => x_Return_Status
     ,x_Msg_Count       => x_Msg_Count
     ,x_Msg_Data        => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BIS_FUNCTIONAL_AREA_PVT.Translate_Functional_Area(
      p_Api_Version    => 1.0
     ,p_Commit         => p_Commit
     ,p_Func_Area_Rec  => p_Func_Area_Rec
     ,x_Return_Status  => x_Return_Status
     ,x_Msg_Count      => x_Msg_Count
     ,x_Msg_Data       => x_Msg_Data
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
        ROLLBACK TO TransFuncAreaSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO TransFuncAreaSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO TransFuncAreaSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Translate_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Translate_Functional_Area ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO TransFuncAreaSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Translate_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Translate_Functional_Area ';
        END IF;
END Translate_Functional_Area;


-- Load Functional Areas for LCT

PROCEDURE Load_Functional_Area(
  p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS

  l_Func_Area_Rec          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type;

BEGIN
    SAVEPOINT LoadFuncAreaSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    BIS_FUNCTIONAL_AREA_PUB.Retrieve_Functional_Area
    (
       p_Func_Area_Rec   => p_Func_Area_Rec
      ,x_Func_Area_Rec   => l_Func_Area_Rec
      ,x_Return_Status   => x_Return_Status
      ,x_Msg_Count       => x_Msg_Count
      ,x_Msg_Data        => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          BIS_FUNCTIONAL_AREA_PUB.Create_Functional_Area(
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
    ELSE
        IF (FND_LOAD_UTIL.UPLOAD_TEST(p_Func_Area_Rec.Last_Updated_By
                                    , p_Func_Area_Rec.Last_Update_Date
                                    , l_Func_Area_Rec.Last_Updated_By
                                    , l_Func_Area_Rec.Last_Update_Date
                                    , NULL)) THEN

              BIS_FUNCTIONAL_AREA_PUB.Update_Functional_Area(
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
         END IF;
    END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO LoadFuncAreaSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO LoadFuncAreaSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO LoadFuncAreaSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Load_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Load_Functional_Area ';
        END IF;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO LoadFuncAreaSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Load_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Load_Functional_Area ';
        END IF;
        RAISE;

END Load_Functional_Area;


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
    SAVEPOINT CreateFuncAreaAppDepSP;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    Validate_Func_Area_Apps_Dep (
      p_Functional_Area_Id  => p_Functional_Area_Id
     ,p_Application_Id      => p_Application_Id
     ,p_Action_Type         => C_CREATE
     ,x_Return_Status       => x_Return_Status
     ,x_Msg_Count           => x_Msg_Count
     ,x_Msg_Data            => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    BIS_FUNCTIONAL_AREA_PVT.Create_Func_Area_Apps_Dep (
      p_Api_Version        => 1.0
     ,p_Commit             => p_Commit
     ,p_Functional_Area_Id => p_Functional_Area_Id
     ,p_Application_Id     => p_Application_Id
     ,x_Return_Status      => x_Return_Status
     ,x_Msg_Count          => x_Msg_Count
     ,x_Msg_Data           => x_Msg_Data
    );

  -- Commit if required
  IF (p_Commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateFuncAreaAppDepSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateFuncAreaAppDepSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateFuncAreaAppDepSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Create_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Create_Func_Area_Apps_Dep ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreateFuncAreaAppDepSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Create_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Create_Func_Area_Apps_Dep ';
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
    SAVEPOINT UpdateFuncAreaAppDepSP;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    Validate_Func_Area_Apps_Dep (
      p_Functional_Area_Id  => p_Functional_Area_Id
     ,p_Application_Id      => p_Application_Id
     ,p_Action_Type         => C_UPDATE
     ,x_Return_Status       => x_Return_Status
     ,x_Msg_Count           => x_Msg_Count
     ,x_Msg_Data            => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BIS_FUNCTIONAL_AREA_PVT.Update_Func_Area_Apps_Dep (
       p_Api_Version         => 1.0
      ,p_Commit              => p_Commit
      ,p_Functional_Area_Id  => p_Functional_Area_Id
      ,p_Application_Id      => p_Application_Id
      ,x_Return_Status       => x_Return_Status
      ,x_Msg_Count           => x_Msg_Count
      ,x_Msg_Data            => x_Msg_Data
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
        ROLLBACK TO UpdateFuncAreaAppDepSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateFuncAreaAppDepSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateFuncAreaAppDepSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Update_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Update_Func_Area_Apps_Dep ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateFuncAreaAppDepSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Update_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Update_Func_Area_Apps_Dep ';
        END IF;

END Update_Func_Area_Apps_Dep;

-- Load API for loading Functional Area/Application ID dependnecy
PROCEDURE Load_Func_Area_Apps_Dep (
  p_Commit                IN           VARCHAR2 := FND_API.G_FALSE
 ,p_Func_Area_App_Dep_Rec IN           BIS_FUNCTIONAL_AREA_PUB.Func_Area_Apps_Depend_Rec_Type
 ,x_Return_Status         OUT  NOCOPY  VARCHAR2
 ,x_Msg_Count             OUT  NOCOPY  NUMBER
 ,x_Msg_Data              OUT  NOCOPY  VARCHAR2
) IS
   l_Count                   NUMBER;
   l_Func_Area_App_Dep_Rec   BIS_FUNCTIONAL_AREA_PUB.Func_Area_Apps_Depend_Rec_Type;
BEGIN
    SAVEPOINT LoadFuncAreaAppDepSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_Func_Area_App_Dep_Rec := p_Func_Area_App_Dep_Rec;

    l_Func_Area_App_Dep_Rec.Functional_Area_Id
      := Get_FA_Id_By_Short_Name (l_Func_Area_App_Dep_Rec.Func_Area_Short_Name);

    IF ((l_Func_Area_App_Dep_Rec.Application_Id IS NULL) AND (l_Func_Area_App_Dep_Rec.Apps_Short_Name IS NOT NULL)) THEN
       l_Func_Area_App_Dep_Rec.Application_Id
         := BIS_UTIL.Get_Apps_Id_By_Short_Name (l_Func_Area_App_Dep_Rec.Apps_Short_Name);
    END IF;

    SELECT COUNT(1) INTO l_Count
    FROM   BIS_FUNC_AREA_APP_DEPENDENCY
    WHERE  FUNCTIONAL_AREA_ID = l_Func_Area_App_Dep_Rec.Functional_Area_Id
    AND    APPLICATION_ID     = l_Func_Area_App_Dep_Rec.Application_Id;

    IF (l_Count = 0) THEN
        BIS_FUNCTIONAL_AREA_PUB.Create_Func_Area_Apps_Dep (
             p_Api_Version        => 1.0
            ,p_Commit             => p_Commit
            ,p_Functional_Area_Id => l_Func_Area_App_Dep_Rec.Functional_Area_Id
            ,p_Application_Id     => l_Func_Area_App_Dep_Rec.Application_Id
            ,x_Return_Status      => x_Return_Status
            ,x_Msg_Count          => x_Msg_Count
            ,x_Msg_Data           => x_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSE
        BIS_FUNCTIONAL_AREA_PUB.Update_Func_Area_Apps_Dep (
             p_Api_Version        => 1.0
            ,p_Commit             => p_Commit
            ,p_Functional_Area_Id => l_Func_Area_App_Dep_Rec.Functional_Area_Id
            ,p_Application_Id     => l_Func_Area_App_Dep_Rec.Application_Id
            ,x_Return_Status      => x_Return_Status
            ,x_Msg_Count          => x_Msg_Count
            ,x_Msg_Data           => x_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO LoadFuncAreaAppDepSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO LoadFuncAreaAppDepSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO LoadFuncAreaAppDepSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Load_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Load_Func_Area_Apps_Dep ';
        END IF;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO LoadFuncAreaAppDepSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Load_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Load_Func_Area_Apps_Dep ';
        END IF;
        RAISE;
END Load_Func_Area_Apps_Dep;

-- Validation API for Functional Area
PROCEDURE Validate_Functional_Area(
  p_Func_Area_Rec       IN          BIS_FUNCTIONAL_AREA_PUB.Functional_Area_Rec_Type
 ,p_Action_Type         IN          VARCHAR2
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS
    l_Count           NUMBER;
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    IF (BIS_UTILITIES_PVT.Value_Missing_Or_Null(LTRIM(RTRIM(p_Func_Area_Rec.Short_Name))) = FND_API.G_TRUE) THEN
       FND_MESSAGE.SET_NAME('BIS','BIS_FA_SHORT_NAME_IS_NULL');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF(p_Action_Type = C_CREATE) THEN


        SELECT COUNT(1) INTO l_Count
        FROM   BIS_FUNCTIONAL_AREAS
        WHERE  UPPER(SHORT_NAME) = UPPER(p_Func_Area_Rec.Short_Name);

        IF (l_Count <> 0) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_FA_SHORT_NAME_EXISTS');
            FND_MESSAGE.SET_TOKEN('SHORT_NAME', p_Func_Area_Rec.Short_Name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (p_Func_Area_Rec.Functional_Area_Id IS NULL) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_FUNC_ID_NOT_ENTERED');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        IF (BIS_UTILITIES_PVT.Value_Missing_Or_Null(LTRIM(RTRIM(p_Func_Area_Rec.Name))) = FND_API.G_TRUE) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_FUNC_NAME_NOT_ENTERED');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    ELSIF(p_Action_Type = C_UPDATE OR p_Action_Type = C_RETRIEVE OR p_Action_Type = C_DELETE) THEN

        /*
        IF (p_Func_Area_Rec.Functional_Area_Id IS NULL) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_FUNC_ID_NOT_ENTERED');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        */

        SELECT COUNT(1) INTO l_Count
        FROM   BIS_FUNCTIONAL_AREAS_VL
        WHERE  SHORT_NAME = p_Func_Area_Rec.Short_Name;

        IF (l_Count = 0) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_FA_SHORT_NAME_NOT_EXISTS');
            FND_MESSAGE.SET_TOKEN('SHORT_NAME', p_Func_Area_Rec.Short_Name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

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
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Validate_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Validate_Functional_Area ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Validate_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Validate_Functional_Area ';
        END IF;

END Validate_Functional_Area;


-- Validate Functional area and Application Dependency.
PROCEDURE Validate_Func_Area_Apps_Dep (
  p_Functional_Area_Id  IN           NUMBER
 ,p_Application_Id      IN           NUMBER
 ,p_Action_Type         IN           VARCHAR2
 ,x_Return_Status       OUT  NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT  NOCOPY  NUMBER
 ,x_Msg_Data            OUT  NOCOPY  VARCHAR2
) IS
    l_Count           NUMBER;
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    IF (p_Functional_Area_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_FUNC_ID_NOT_ENTERED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_Application_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_APP_ID_NOT_ENTERED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    SELECT COUNT(1) INTO l_Count
    FROM   BIS_FUNCTIONAL_AREAS
    WHERE  FUNCTIONAL_AREA_ID = p_Functional_Area_Id;

    IF (l_Count = 0) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_FA_ID_NOT_EXISTS');
        FND_MESSAGE.SET_TOKEN('FA_ID', p_Functional_Area_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;



    IF(p_Action_Type = C_CREATE) THEN
        -- Internally -1 Application ID would mean a default application id
        IF(p_Application_Id <> -1) THEN
            SELECT COUNT(1) INTO l_Count
            FROM   FND_APPLICATION
            WHERE  APPLICATION_ID = p_Application_Id;

            IF (l_Count = 0) THEN
                FND_MESSAGE.SET_NAME('BIS','BIS_APPS_ID_NOT_EXISTS');
                FND_MESSAGE.SET_TOKEN('APPS_ID', p_Application_Id);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        SELECT COUNT(1) INTO l_Count
        FROM   BIS_FUNC_AREA_APP_DEPENDENCY
        WHERE  FUNCTIONAL_AREA_ID = p_Functional_Area_Id
        AND    APPLICATION_ID     = p_Application_Id;

        IF l_Count <> 0 THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_FA_APPS_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('FA_ID', p_Functional_Area_Id);
            FND_MESSAGE.SET_TOKEN('APPS_ID', p_Application_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        SELECT COUNT(1) INTO l_Count
        FROM   BIS_FUNC_AREA_APP_DEPENDENCY
        WHERE  APPLICATION_ID     = p_Application_Id;

        IF l_Count > 0 THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_FA_APPS_ID_ALREADY_EXIST');
            FND_MESSAGE.SET_TOKEN('APPS_ID', p_Application_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;




    ELSIF(p_Action_Type = C_UPDATE OR p_Action_Type = C_DELETE) THEN

        SELECT COUNT(1) INTO l_Count
        FROM   BIS_FUNC_AREA_APP_DEPENDENCY
        WHERE  FUNCTIONAL_AREA_ID = p_Functional_Area_Id
        AND    APPLICATION_ID     = p_Application_Id;

        IF (l_Count = 0) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_FA_APPS_ID_NOT_EXIST');
            FND_MESSAGE.SET_TOKEN('APPS_ID', p_Application_Id);
            FND_MESSAGE.SET_TOKEN('FA_ID', p_Functional_Area_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


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
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Validate_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Validate_Func_Area_Apps_Dep ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Validate_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Validate_Func_Area_Apps_Dep ';
        END IF;
END Validate_Func_Area_Apps_Dep;

-- Returns the next functional area id, this may not be multiuser friendly

FUNCTION Get_Next_Functional_Area_Id
RETURN NUMBER IS
  l_next NUMBER;
  --l_Max_Id NUMBER;
BEGIN
  l_next := 0;

  /*SELECT (NVL(MAX(FUNCTIONAL_AREA_ID), 0)+1)
  INTO   l_Max_Id
  FROM   BIS_FUNCTIONAL_AREAS;

  RETURN l_Max_Id;
  */

  SELECT BIS_FUNC_AREA_ID_S.NEXTVAL
  INTO l_next
  FROM DUAL;

  return l_next;

EXCEPTION
  WHEN OTHERS THEN
     RETURN 0;
END Get_Next_Functional_Area_Id;

-- Get the Functional Area ID from Functional Short_Name
FUNCTION Get_FA_Id_By_Short_Name (
  p_Functional_Area_Short_Name IN VARCHAR2
)RETURN NUMBER IS
  l_FA_Id   NUMBER;
BEGIN
  SELECT FUNCTIONAL_AREA_ID
  INTO   l_FA_Id
  FROM   BIS_FUNCTIONAL_AREAS
  WHERE  UPPER(SHORT_NAME) = UPPER(p_Functional_Area_Short_Name);

  RETURN l_FA_Id;

EXCEPTION
  WHEN OTHERS THEN
     RETURN -1;
END Get_FA_Id_By_Short_Name;

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
    SAVEPOINT DeleteFuncAreaSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    l_Func_Area_Rec := p_Func_Area_Rec;

    Validate_Functional_Area(
      p_Func_Area_Rec   => p_Func_Area_Rec
     ,p_Action_Type     => C_DELETE
     ,x_Return_Status   => x_Return_Status
     ,x_Msg_Count       => x_Msg_Count
     ,x_Msg_Data        => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    BIS_FUNCTIONAL_AREA_PUB.Retrieve_Functional_Area
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

    BIS_FUNCTIONAL_AREA_PVT.Delete_Functional_Area(
      p_Api_Version    => 1.0
     ,p_Commit         => p_Commit
     ,p_Func_Area_Rec  => l_Func_Area_Rec
     ,x_Return_Status  => x_Return_Status
     ,x_Msg_Count      => x_Msg_Count
     ,x_Msg_Data       => x_Msg_Data
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
        ROLLBACK TO DeleteFuncAreaSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteFuncAreaSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteFuncAreaSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Delete_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Delete_Functional_Area ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteFuncAreaSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Delete_Functional_Area ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Delete_Functional_Area ';
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
    SAVEPOINT RemoveFuncAreaDependencySP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    Validate_Func_Area_Apps_Dep (
      p_Functional_Area_Id  => p_Functional_Area_Id
     ,p_Application_Id      => p_Application_Id
     ,p_Action_Type         => C_DELETE
     ,x_Return_Status       => x_Return_Status
     ,x_Msg_Count           => x_Msg_Count
     ,x_Msg_Data            => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BIS_FUNCTIONAL_AREA_PVT.Remove_Func_Area_Apps_Dep (
      p_Api_Version         => 1.0
     ,p_Commit              => p_Commit
     ,p_Functional_Area_Id  => p_Functional_Area_Id
     ,p_Application_Id      => p_Application_Id
     ,x_Return_Status       => x_Return_Status
     ,x_Msg_Count           => x_Msg_Count
     ,x_Msg_Data            => x_Msg_Data
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
        ROLLBACK TO RemoveFuncAreaDependencySP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO RemoveFuncAreaDependencySP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO RemoveFuncAreaDependencySP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Remove_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Remove_Func_Area_Apps_Dep ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO RemoveFuncAreaDependencySP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_FUNCTIONAL_AREA_PUB.Remove_Func_Area_Apps_Dep ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_FUNCTIONAL_AREA_PUB.Remove_Func_Area_Apps_Dep ';
        END IF;
END Remove_Func_Area_Apps_Dep;

-- Add language API
PROCEDURE ADD_LANGUAGE
IS
BEGIN
   BIS_FUNCTIONAL_AREA_PVT.ADD_LANGUAGE;
END ADD_LANGUAGE;


END BIS_FUNCTIONAL_AREA_PUB;

/
