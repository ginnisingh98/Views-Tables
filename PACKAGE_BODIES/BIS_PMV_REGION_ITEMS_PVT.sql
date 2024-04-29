--------------------------------------------------------
--  DDL for Package Body BIS_PMV_REGION_ITEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_REGION_ITEMS_PVT" AS
/* $Header: BISVRITB.pls 120.1 2005/10/06 07:09:26 adrao noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVRITB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Private API for Region Items                              |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 02/03/04 nbarik   Created.                                            |
REM | 05/22/04 adrao    Added Exception Handling                            |
REM | 10/03/05 adrao    Added new region item attribute Grand_Total_Flag    |
REM |                   for Bug#4594984                                     |
REM +=======================================================================+
*/

PROCEDURE CREATE_REGION_ITEMS
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_region_code           IN          VARCHAR2
    ,   p_region_application_id IN          NUMBER
    ,   p_Region_Item_Tbl       IN          BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
  l_Region_Item_Rec       BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type;
  l_commit                VARCHAR2(1) := 'N';
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_Region_Item_Tbl IS NOT NULL AND p_Region_Item_Tbl.COUNT > 0) THEN
      FOR i IN p_Region_Item_Tbl.FIRST..p_Region_Item_Tbl.LAST LOOP
        l_Region_Item_Rec := p_Region_Item_Tbl(i);
        BIS_AK_REGION_PUB.INSERT_REGION_ITEM_ROW
        (      p_commit                => p_commit
           ,   p_region_code           => p_region_code
           ,   p_region_application_id => p_region_application_id
           ,   p_Region_Item_Rec       => l_Region_Item_Rec
           ,   x_return_status         => x_return_status
           ,   x_msg_count             => x_msg_count
           ,   x_msg_data              => x_msg_data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (p_commit = FND_API.G_TRUE) THEN
          l_commit := 'Y';
        END IF;

        -- No primary key validation on BIS_AK_REGION_EXTENSION
        BIS_REGION_ITEM_EXTENSION_PVT.CREATE_REGION_ITEM_RECORD
        (      pRegionCode              => p_region_code
           ,   pRegionAppId             => p_region_application_id
           ,   pAttributeCode           => l_Region_Item_Rec.Attribute_Code
           ,   pAttributeAppId          => l_Region_Item_Rec.Attribute_Application_Id
           ,   pAttribute16             => l_Region_Item_Rec.Additional_View_By
           ,   pAttribute17             => l_Region_Item_Rec.Rolling_Lookup
           ,   pAttribute18             => l_Region_Item_Rec.Operator_Lookup
           ,   pAttribute19             => l_Region_Item_Rec.Dual_YAxis_Graphs
           ,   pAttribute20             => l_Region_Item_Rec.Custom_View_Name
           ,   pAttribute21             => l_Region_Item_Rec.Graph_Measure_Type
           ,   pAttribute22             => l_Region_Item_Rec.Hide_Target_In_Table
           ,   pAttribute23             => l_Region_Item_Rec.Parameter_Render_Type
           ,   pAttribute24             => l_Region_Item_Rec.Privilege
           ,   pAttribute25             => NULL
           ,   pAttribute26             => l_Region_Item_Rec.Grand_Total_Flag
           ,   pAttribute27             => NULL
           ,   pAttribute28             => NULL
           ,   pAttribute29             => NULL
           ,   pAttribute30             => NULL
           ,   pAttribute31             => NULL
           ,   pAttribute32             => NULL
           ,   pAttribute33             => NULL
           ,   pAttribute34             => NULL
           ,   pAttribute35             => NULL
           ,   pAttribute36             => NULL
           ,   pAttribute37             => NULL
           ,   pAttribute38             => NULL
           ,   pAttribute39             => NULL
           ,   pAttribute40             => NULL
           ,   pCommit                  => l_commit
        );
      END LOOP;
    END IF;
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
            x_msg_data      :=  x_msg_data||' -> BIS_PMV_REGION_ITEMS_PVT.CREATE_REGION_ITEMS ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_PMV_REGION_ITEMS_PVT.CREATE_REGION_ITEMS ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END CREATE_REGION_ITEMS;

PROCEDURE UPDATE_REGION_ITEMS
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_region_code           IN          VARCHAR2
    ,   p_region_application_id IN          NUMBER
    ,   p_Region_Item_Tbl       IN          BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
  l_Region_Item_Rec       BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type;
  l_commit                VARCHAR2(1) := 'N';
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_Region_Item_Tbl IS NOT NULL AND p_Region_Item_Tbl.COUNT > 0) THEN
      FOR i IN p_Region_Item_Tbl.FIRST..p_Region_Item_Tbl.LAST LOOP
        l_Region_Item_Rec := p_Region_Item_Tbl(i);
        BIS_AK_REGION_PUB.UPDATE_REGION_ITEM_ROW
        (      p_commit                => p_commit
           ,   p_region_code           => p_region_code
           ,   p_region_application_id => p_region_application_id
           ,   p_Region_Item_Rec       => l_Region_Item_Rec
           ,   x_return_status         => x_return_status
           ,   x_msg_count             => x_msg_count
           ,   x_msg_data              => x_msg_data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (p_commit = FND_API.G_TRUE) THEN
          l_commit := 'Y';
        END IF;

        -- No primary key validation on BIS_AK_REGION_EXTENSION
        BIS_REGION_ITEM_EXTENSION_PVT.UPDATE_REGION_ITEM_RECORD
        (      pRegionCode              => p_region_code
           ,   pRegionAppId             => p_region_application_id
           ,   pAttributeCode           => l_Region_Item_Rec.Attribute_Code
           ,   pAttributeAppId          => l_Region_Item_Rec.Attribute_Application_Id
           ,   pAttribute16             => l_Region_Item_Rec.Additional_View_By
           ,   pAttribute17             => l_Region_Item_Rec.Rolling_Lookup
           ,   pAttribute18             => l_Region_Item_Rec.Operator_Lookup
           ,   pAttribute19             => l_Region_Item_Rec.Dual_YAxis_Graphs
           ,   pAttribute20             => l_Region_Item_Rec.Custom_View_Name
           ,   pAttribute21             => l_Region_Item_Rec.Graph_Measure_Type
           ,   pAttribute22             => l_Region_Item_Rec.Hide_Target_In_Table
           ,   pAttribute23             => l_Region_Item_Rec.Parameter_Render_Type
           ,   pAttribute24             => l_Region_Item_Rec.Privilege
           ,   pAttribute25             => NULL
           ,   pAttribute26             => l_Region_Item_Rec.Grand_Total_Flag
           ,   pAttribute27             => NULL
           ,   pAttribute28             => NULL
           ,   pAttribute29             => NULL
           ,   pAttribute30             => NULL
           ,   pAttribute31             => NULL
           ,   pAttribute32             => NULL
           ,   pAttribute33             => NULL
           ,   pAttribute34             => NULL
           ,   pAttribute35             => NULL
           ,   pAttribute36             => NULL
           ,   pAttribute37             => NULL
           ,   pAttribute38             => NULL
           ,   pAttribute39             => NULL
           ,   pAttribute40             => NULL
           ,   pCommit                  => l_commit
        );
      END LOOP;
    END IF;
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
            x_msg_data      :=  x_msg_data||' -> BIS_PMV_REGION_ITEMS_PVT.UPDATE_REGION_ITEMS ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_PMV_REGION_ITEMS_PVT.UPDATE_REGION_ITEMS ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END UPDATE_REGION_ITEMS;

PROCEDURE DELETE_REGION_ITEMS
(       p_commit                      IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_region_code                 IN          VARCHAR2
    ,   p_region_application_id       IN          NUMBER
    ,   p_Attribute_Code_Tbl          IN          BISVIEWER.t_char
    ,   p_Attribute_Appl_Id_Tbl       IN          BISVIEWER.t_num
    ,   x_return_status               OUT NOCOPY  VARCHAR2
    ,   x_msg_count                   OUT NOCOPY  NUMBER
    ,   x_msg_data                    OUT NOCOPY  VARCHAR2
) IS
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_Attribute_Code_Tbl IS NOT NULL AND p_Attribute_Code_Tbl.COUNT > 0) THEN
      FOR i IN p_Attribute_Code_Tbl.FIRST..p_Attribute_Code_Tbl.LAST LOOP
        BIS_AK_REGION_PUB.DELETE_REGION_ITEM_ROW
        (      p_REGION_CODE              => p_region_code
           ,   p_REGION_APPLICATION_ID    => p_region_application_id
           ,   p_ATTRIBUTE_CODE           => p_Attribute_Code_Tbl(i)
           ,   p_ATTRIBUTE_APPLICATION_ID => p_Attribute_Appl_Id_Tbl(i)
           ,   x_return_status            => x_return_status
           ,   x_msg_count                => x_msg_count
           ,   x_msg_data                 => x_msg_data
           ,   p_commit                   => p_commit
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- No primary key validation on BIS_AK_REGION_EXTENSION
        BIS_REGION_ITEM_EXTENSION_PVT.DELETE_REGION_ITEM_RECORD
        (      p_commit                 => p_commit
           ,   pRegionCode              => p_region_code
           ,   pRegionAppId             => p_region_application_id
           ,   pAttributeCode           => p_Attribute_Code_Tbl(i)
           ,   pAttributeAppId          => p_Attribute_Appl_Id_Tbl(i)
        );
      END LOOP;
    END IF;
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
            x_msg_data      :=  x_msg_data||' -> BIS_PMV_REGION_ITEMS_PVT.DELETE_REGION_ITEMS ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_PMV_REGION_ITEMS_PVT.DELETE_REGION_ITEMS ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END DELETE_REGION_ITEMS;

END BIS_PMV_REGION_ITEMS_PVT;

/
