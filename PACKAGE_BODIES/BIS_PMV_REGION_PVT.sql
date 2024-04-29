--------------------------------------------------------
--  DDL for Package Body BIS_PMV_REGION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_REGION_PVT" AS
/* $Header: BISVREPB.pls 120.1 2006/02/07 20:28:27 hengliu noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVREPB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Private API for Region                                    |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 02/03/04 nbarik   Created.                                            |
REM | 05/22/04 adrao    Added Exception Handling                            |
REM | 02/07/06 hengliu  Bug#4955493 - Cannot overwrite global menu/title    |
REM +=======================================================================+
*/

PROCEDURE CREATE_REGION
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_Report_Region_Rec     IN          BIS_AK_REGION_PUB.Bis_Region_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BIS_AK_REGION_PUB.INSERT_REGION_ROW
    (      p_commit                => p_commit
       ,   p_Report_Region_Rec     => p_Report_Region_Rec
       ,   x_return_status         => x_return_status
       ,   x_msg_count             => x_msg_count
       ,   x_msg_data              => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BIS_REGION_EXTENSION_PVT.CREATE_REGION_EXTN_RECORD
    (       p_commit                 => p_commit
        ,   pRegionCode              => p_Report_Region_Rec.Region_Code
        ,   pRegionAppId             => p_Report_Region_Rec.Region_Application_Id
        ,   pAttribute16             => p_Report_Region_Rec.Kpi_Id || ''
        ,   pAttribute17             => p_Report_Region_Rec.Analysis_Option_Id || ''
        ,   pAttribute18             => p_Report_Region_Rec.Dim_Set_Id || ''
        ,   pAttribute19             => p_Report_Region_Rec.Global_Menu || ''
        ,   pAttribute20             => p_Report_Region_Rec.Global_Title || ''
    );
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
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
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_PMV_REGION_PVT.CREATE_REGION ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_PMV_REGION_PVT.CREATE_REGION ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END CREATE_REGION;

PROCEDURE UPDATE_REGION
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_Report_Region_Rec     IN          BIS_AK_REGION_PUB.Bis_Region_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BIS_AK_REGION_PUB.UPDATE_REGION_ROW
    (      p_commit                => p_commit
       ,   p_Report_Region_Rec     => p_Report_Region_Rec
       ,   x_return_status         => x_return_status
       ,   x_msg_count             => x_msg_count
       ,   x_msg_data              => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BIS_REGION_EXTENSION_PVT.UPDATE_REGION_EXTN_RECORD
    (       p_commit                 => p_commit
        ,   pRegionCode              => p_Report_Region_Rec.Region_Code
        ,   pRegionAppId             => p_Report_Region_Rec.Region_Application_Id
        ,   pAttribute16             => p_Report_Region_Rec.Kpi_Id || ''
        ,   pAttribute17             => p_Report_Region_Rec.Analysis_Option_Id || ''
        ,   pAttribute18             => p_Report_Region_Rec.Dim_Set_Id || ''
        ,   pAttribute19             => p_Report_Region_Rec.Global_Menu || ''
        ,   pAttribute20             => p_Report_Region_Rec.Global_Title || ''
    );
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
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
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_PMV_REGION_PVT.UPDATE_REGION ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_PMV_REGION_PVT.UPDATE_REGION ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END UPDATE_REGION;

PROCEDURE DELETE_REGION
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_Region_Code           IN          VARCHAR2
    ,   p_Region_Application_Id IN          NUMBER
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BIS_AK_REGION_PUB.DELETE_REGION_ROW
    (      p_REGION_CODE           => p_Region_Code
       ,   p_REGION_APPLICATION_ID => p_Region_Application_Id
       ,   x_return_status         => x_return_status
       ,   x_msg_count             => x_msg_count
       ,   x_msg_data              => x_msg_data
       ,   p_commit                => p_commit
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BIS_REGION_EXTENSION_PVT.DELETE_REGION_EXTN_RECORD
    (      p_commit                 => p_commit
       ,   pRegionCode              => p_Region_Code
       ,   pRegionAppId             => p_Region_Application_Id
    );
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
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
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_PMV_REGION_PVT.DELETE_REGION ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_PMV_REGION_PVT.DELETE_REGION ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END DELETE_REGION;

END BIS_PMV_REGION_PVT;

/
