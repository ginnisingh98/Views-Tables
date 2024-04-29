--------------------------------------------------------
--  DDL for Package Body BSC_DIMENSION_LEVELS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DIMENSION_LEVELS_PUB" as
/* $Header: BSCPDMLB.pls 120.0 2005/06/01 16:50:01 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPDMLB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 9, 2001                                                 |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 |          Public version.                                                             |
 |          This Package creates a dimension level in BSC.                              |
 | History                                                                              |
 |          24-APR-2003  is_Child_Parent() Added by ADRAO for Enh#2901823               |
 |          07-MAY-2003  Retrieve_Relationship() Added by ADRAO for change Enh#2901823  |
 |          01-JUN-2003  Created Overloaded procedure Create_Dim_Level                  |
 |          07-JUN-03    mahrao Modified for ALL enhancement                            |
 |          05-JUN-2003  ADRAO made changes for Granular Locking                        |
 | 14-JUN-03  mahrao   Added Translate_dimesnsion_level procedure for enh# 2842894      |
 | 17-JUL-03  mahrao   Modified Load_Dimension_Level exception handling section         |
 |                     as part of forward port of ALL enhancement to BSC 5.1            |
 | 22-JUL-2003 arhegde bug# 3050270 Modified Create_Dim_Level(); 'All' and 'Comparison' |
 |        got from lookups                                                              |
 | 04-NOV-2003 PAJOHRI  Bug #3232366                                                    |
 | 02-MAR-2004 ankgoel  Bug #3464470                                                    |
 | 26-MAR-2004 kyadamak Bug# 3528143 Removed the hardcoding of 'US' for source language |
 |                       and language                                                   |
 | 30-Jul-04   rpenneru  Modified for enhancemen#3748519                                |
 | 21-DEC-04   vtulasi   Modified for bug#4045278 - Addtion of LUD                      |
 | 30-DEC-04   vtulasi   For bug #4093926                                               |
 | 09-Feb-05   ankgoel   Bug#4172055 LUD validations for dim_lvls_by_group              |
 | 02-MAR-05   ashankar  Bug#3583110 modified l_Dim_Level_Rec.Bsc_Level_Abbreviation    |
 |                       when called from upload of LDT file                            |
 +======================================================================================+
*/

G_PKG_NAME      CONSTANT    varchar2(30) := 'BSC_DIMENSION_LEVELS_PUB';

/*
The following procedures are used by BSC to create Dimension Levels.
*/

--: The following procedure is used to create the BSC Dimension entity.
--: It is the entry point to populate all necessary meta data.
--: This procedure is part of the Dimension API.
procedure Create_Dim_Level(
  p_commit              IN      varchar2 ---:= FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,p_create_tables       IN             BOOLEAN
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
)is

l_Dim_Level_Rec         BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;

l_count             number;

begin
  --Assign passed Record values to local Record.
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_Dim_Level_Rec := p_Dim_Level_Rec;

  -- Check to see that dimension level has not been created. If it has not then create it
  -- else do nothing.
  select count(1)
    into l_count
    from BSC_SYS_DIM_LEVELS_B
    where short_name = l_Dim_Level_Rec.Bsc_Level_Short_Name;

  if l_count = 0 then

    --Assign certain default values if they are null.
    if l_Dim_Level_Rec.Bsc_Dim_Comp_Disp_Name is null then
      l_Dim_Level_Rec.Bsc_Dim_Comp_Disp_Name := NVL(BSC_APPS.get_lookup_value('BSC_UI_COMMON', 'COMPARISON'), 'COMPARISON');
    end if;
    if l_Dim_Level_Rec.Bsc_Dim_Level_Help is null then
      l_Dim_Level_Rec.Bsc_Dim_Level_Help := 'Help: ' || l_Dim_Level_Rec.Bsc_Dim_Level_Long_Name;
    end if;
    if l_Dim_Level_Rec.Bsc_Dim_Tot_Disp_Name is null then
      l_Dim_Level_Rec.Bsc_Dim_Tot_Disp_Name := NVL(BSC_APPS.get_lookup_value('BSC_UI_COMMON', 'ALL'), 'ALL');
    end if;
    if l_Dim_Level_Rec.Bsc_Level_Abbreviation is null then
      l_Dim_Level_Rec.Bsc_Level_Abbreviation := substr(replace(l_Dim_Level_Rec.Bsc_Dim_Level_Long_Name, ' ', ''), 1, 8);
    end if;
    if l_Dim_Level_Rec.Bsc_Level_Comp_Order_By is null then
      l_Dim_Level_Rec.Bsc_Level_Comp_Order_By := 0;
    end if;
    if l_Dim_Level_Rec.Bsc_Level_Custom_Group is null then
      l_Dim_Level_Rec.Bsc_Level_Custom_Group := 0;
    end if;
    if l_Dim_Level_Rec.Bsc_Level_Disp_Key_Size is null then
      l_Dim_Level_Rec.Bsc_Level_Disp_Key_Size := 15;
    end if;
    if l_Dim_Level_Rec.Bsc_Level_User_Key_Size is null then
      l_Dim_Level_Rec.Bsc_Level_User_Key_Size := 5;
    end if;
    if l_Dim_Level_Rec.Bsc_Level_Table_Type is null then
      l_Dim_Level_Rec.Bsc_Level_Table_Type := 1;
    end if;
    if l_Dim_Level_Rec.Bsc_Level_Value_Order_By is null then
      l_Dim_Level_Rec.Bsc_Level_Value_Order_By := 0;
    end if;

    -- Aditya added from PMD GL
    if l_Dim_Level_Rec.Bsc_Created_By is null then
      l_Dim_Level_Rec.Bsc_Created_By := FND_GLOBAL.USER_ID;
    end if;
    if l_Dim_Level_Rec.Bsc_Creation_Date is null then
      l_Dim_Level_Rec.Bsc_Creation_Date := l_Dim_Level_Rec.Bsc_Last_Update_Date;
    end if;
    if l_Dim_Level_Rec.Bsc_Last_Updated_By is null then
      l_Dim_Level_Rec.Bsc_Last_Updated_By := FND_GLOBAL.USER_ID;
    end if;
    l_Dim_Level_Rec.Bsc_Last_Update_Date := NVL(p_Dim_Level_Rec.Bsc_Last_Update_Date, SYSDATE);
    if l_Dim_Level_Rec.Bsc_Last_Update_Login is null then
      l_Dim_Level_Rec.Bsc_Last_Update_Login := FND_GLOBAL.LOGIN_ID;
    end if;



    --Get the next id for this level.
    IF ( l_Dim_Level_Rec.Bsc_Level_Id IS NULL) THEN
        l_Dim_Level_Rec.Bsc_Level_Id := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value( 'BSC_SYS_DIM_LEVELS_B'
                                                                                ,'DIM_LEVEL_ID');
    END IF;

  IF(p_create_tables) THEN
    BSC_DIMENSION_LEVELS_PVT.Create_Dim_Level( p_commit
                                              ,l_Dim_Level_Rec
                                              ,x_return_status
                                              ,x_msg_count
                                              ,x_msg_data);
  END IF;

    Create_Bsc_Dim_Levels_Md( p_commit
                             ,l_Dim_Level_Rec
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Dim_Level;


procedure Create_Dim_Level(
  p_commit              IN      varchar2 --:= FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Level_Rec BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
BEGIN
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    l_Dim_Level_Rec := p_Dim_Level_Rec;
    l_Dim_Level_Rec.Bsc_Last_Update_Date := NVL(p_Dim_Level_Rec.Bsc_Last_Update_Date, SYSDATE);

    BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level
    (
            p_commit              =>    p_commit
        ,   p_Dim_Level_Rec       =>    l_Dim_Level_Rec
        ,   p_create_tables       =>    TRUE
        ,   x_return_status       =>    x_return_status
        ,   x_msg_count           =>    x_msg_count
        ,   x_msg_data            =>    x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Dim_Level;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Dim_Level(
  p_commit              IN      varchar2 --:= FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_Dim_Level_Rec       IN OUT NOCOPY     BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  Retrieve_Bsc_Dim_Levels_Md( p_commit
                             ,p_Dim_Level_Rec
                             ,x_Dim_Level_Rec
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Retrieve_Dim_Level ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Retrieve_Dim_Level ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Retrieve_Dim_Level ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Retrieve_Dim_Level ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Retrieve_Dim_Level;

/************************************************************************************
************************************************************************************/

procedure Update_Dim_Level(
  p_commit              IN      varchar2 --:= FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Level_Rec BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
begin

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_Dim_Level_Rec := p_Dim_Level_Rec;
  l_Dim_Level_Rec.Bsc_Last_Update_Date := NVL(p_Dim_Level_Rec.Bsc_Last_Update_Date, SYSDATE);

  Update_Bsc_Dim_Levels_Md( p_commit
                           ,l_Dim_Level_Rec
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data);

    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Update_Dim_Level ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Update_Dim_Level ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Update_Dim_Level ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Update_Dim_Level ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Dim_Level;

/************************************************************************************
************************************************************************************/

procedure Delete_Dim_Level(
  p_commit              IN      varchar2 --:= FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_LEVELS_PVT.Delete_Dim_Level
  (
      p_commit          =>  p_commit
    , p_Dim_Level_Rec   =>  p_Dim_Level_Rec
    , x_return_status   =>  x_return_status
    , x_msg_count       =>  x_msg_count
    , x_msg_data        =>  x_msg_data
  );
  Delete_Bsc_Dim_Levels_Md( p_commit
                           ,p_Dim_Level_Rec
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Delete_Dim_Level ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Delete_Dim_Level ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Delete_Dim_Level ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Delete_Dim_Level ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Delete_Dim_Level;

/************************************************************************************
************************************************************************************/

--: This procedure populates the meta data for BSC dimensions, such as
--: dimension id, dimension names, dimension view/table columns.
--:     This procedure is part of the Dimension API.

procedure Create_Bsc_Dim_Levels_Md(
  p_commit              IN      varchar2 -- := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Level_Rec                 BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Dim_Level_Rec := p_Dim_Level_Rec;

  l_Dim_Level_Rec.Bsc_Last_Update_Date := NVL(p_Dim_Level_Rec.Bsc_Last_Update_Date, SYSDATE);

  -- Call the private package.procedure.
  BSC_DIMENSION_LEVELS_PVT.Create_Bsc_Dim_Levels_Md( p_commit
                                                    ,l_Dim_Level_Rec
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);

  -- Reminder:  The values below are hard coded, need to find a source for them.
  --            Also there are more values when the table has parent and children.

  l_Dim_Level_Rec.Bsc_Level_Column_Name := 'CODE';
  l_Dim_Level_Rec.Bsc_Level_Column_Type := 'P';
  Create_Bsc_Sys_Dim_Lvl_Cols( p_commit
                              ,l_Dim_Level_Rec
                              ,x_return_status
                              ,x_msg_count
                              ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  l_Dim_Level_Rec.Bsc_Level_Column_Name := 'USER_CODE';
  l_Dim_Level_Rec.Bsc_Level_Column_Type := 'U';
  Create_Bsc_Sys_Dim_Lvl_Cols( p_commit
                              ,l_Dim_Level_Rec
                              ,x_return_status
                              ,x_msg_count
                              ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  l_Dim_Level_Rec.Bsc_Level_Column_Name := 'NAME';
  l_Dim_Level_Rec.Bsc_Level_Column_Type := 'D';
  Create_Bsc_Sys_Dim_Lvl_Cols( p_commit
                              ,l_Dim_Level_Rec
                              ,x_return_status
                              ,x_msg_count
                              ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Create_Bsc_Dim_Levels_Md ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Create_Bsc_Dim_Levels_Md ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Create_Bsc_Dim_Levels_Md ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Create_Bsc_Dim_Levels_Md ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Bsc_Dim_Levels_Md;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Bsc_Dim_Levels_Md(
  p_commit              IN      varchar2 --:= FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_Dim_Level_Rec       IN OUT NOCOPY      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_LEVELS_PVT.Retrieve_Bsc_Dim_Levels_Md( p_commit
                                                      ,p_Dim_Level_Rec
                                                      ,x_Dim_Level_Rec
                                                      ,x_return_status
                                                      ,x_msg_count
                                                      ,x_msg_data);

  Retrieve_Bsc_Sys_Dim_Lvl_Cols( p_commit
                                ,p_Dim_Level_Rec
                                ,x_Dim_Level_Rec
                                ,x_return_status
                                ,x_msg_count
                                ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Retrieve_Bsc_Dim_Levels_Md ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Retrieve_Bsc_Dim_Levels_Md ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Retrieve_Bsc_Dim_Levels_Md ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Retrieve_Bsc_Dim_Levels_Md ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Retrieve_Bsc_Dim_Levels_Md;

/************************************************************************************
************************************************************************************/

procedure Update_Bsc_Dim_Levels_Md(
  p_commit              IN      varchar2 --:= FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Level_Rec         BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Dim_Level_Rec := p_Dim_Level_Rec;
  l_Dim_Level_Rec.Bsc_Last_Update_Date := NVL(p_Dim_Level_Rec.Bsc_Last_Update_Date, SYSDATE);
  -- If language values are null assign 'US'.

  BSC_DIMENSION_LEVELS_PVT.Update_Bsc_Dim_Levels_Md( p_commit
                                                    ,l_Dim_Level_Rec
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);

 Update_Bsc_Sys_Dim_Lvl_Cols( p_commit
                             ,l_Dim_Level_Rec
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Update_Bsc_Dim_Levels_Md ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Update_Bsc_Dim_Levels_Md ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Update_Bsc_Dim_Levels_Md ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Update_Bsc_Dim_Levels_Md ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Bsc_Dim_Levels_Md;

/************************************************************************************
************************************************************************************/

procedure Delete_Bsc_Dim_Levels_Md(
  p_commit              IN      varchar2 --:= FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

-- Procedure to delete meta data for the Dimension Level.

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  -- Call the private package.procedure.
  BSC_DIMENSION_LEVELS_PVT.Delete_Bsc_Dim_Levels_Md( p_commit
                                                    ,p_Dim_Level_Rec
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);
  IF ((x_return_status  =  FND_API.G_RET_STS_ERROR)  OR (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) THEN
    RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  Delete_Bsc_Sys_Dim_Lvl_Cols( p_commit
                              ,p_Dim_Level_Rec
                              ,x_return_status
                              ,x_msg_count
                              ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Delete_Bsc_Dim_Levels_Md ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Delete_Bsc_Dim_Levels_Md ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Delete_Bsc_Dim_Levels_Md ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Delete_Bsc_Dim_Levels_Md ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Delete_Bsc_Dim_Levels_Md;

/************************************************************************************
************************************************************************************/

--: This procedure populates column information for the Dimension view/table.
--: This procedure is part of the Dimension API.

procedure Create_Bsc_Sys_Dim_Lvl_Cols(
  p_commit              IN      varchar2 -- := FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  -- Call the private package.procedure.
  BSC_DIMENSION_LEVELS_PVT.Create_Bsc_Sys_Dim_Lvl_Cols( p_commit
                                                       ,p_Dim_Level_Rec
                                                       ,x_return_status
                                                       ,x_msg_count
                                                       ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Create_Bsc_Sys_Dim_Lvl_Cols ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Create_Bsc_Sys_Dim_Lvl_Cols ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Create_Bsc_Sys_Dim_Lvl_Cols ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Create_Bsc_Sys_Dim_Lvl_Cols ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Bsc_Sys_Dim_Lvl_Cols;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Bsc_Sys_Dim_Lvl_Cols(
  p_commit              IN      varchar2 --:= FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_Dim_Level_Rec       IN OUT NOCOPY      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_LEVELS_PVT.Retrieve_Bsc_Sys_Dim_Lvl_Cols( p_commit
                                                         ,p_Dim_Level_Rec
                                                         ,x_Dim_Level_Rec
                                                         ,x_return_status
                                                         ,x_msg_count
                                                         ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Retrieve_Bsc_Sys_Dim_Lvl_Cols ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Retrieve_Bsc_Sys_Dim_Lvl_Cols ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Retrieve_Bsc_Sys_Dim_Lvl_Cols ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Retrieve_Bsc_Sys_Dim_Lvl_Cols ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Retrieve_Bsc_Sys_Dim_Lvl_Cols;

/************************************************************************************
************************************************************************************/

procedure Update_Bsc_Sys_Dim_Lvl_Cols(
  p_commit              IN      varchar2 --:= FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_LEVELS_PVT.Update_Bsc_Sys_Dim_Lvl_Cols( p_commit
                                                       ,p_Dim_Level_Rec
                                                       ,x_return_status
                                                       ,x_msg_count
                                                       ,x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Update_Bsc_Sys_Dim_Lvl_Cols ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Update_Bsc_Sys_Dim_Lvl_Cols ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Update_Bsc_Sys_Dim_Lvl_Cols ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Update_Bsc_Sys_Dim_Lvl_Cols ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Bsc_Sys_Dim_Lvl_Cols;

/************************************************************************************
************************************************************************************/

procedure Delete_Bsc_Sys_Dim_Lvl_Cols(
  p_commit              IN      varchar2 --:= FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

-- Procedure to Delete data on Dimension Level column information.
begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  -- Call the private package.procedure.
  BSC_DIMENSION_LEVELS_PVT.Delete_Bsc_Sys_Dim_Lvl_Cols( p_commit
                                                       ,p_Dim_Level_Rec
                                                       ,x_return_status
                                                       ,x_msg_count
                                                       ,x_msg_data);
  IF ((x_return_status  =  FND_API.G_RET_STS_ERROR)  OR (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) THEN
    RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Delete_Bsc_Sys_Dim_Lvl_Cols ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Delete_Bsc_Sys_Dim_Lvl_Cols ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Delete_Bsc_Sys_Dim_Lvl_Cols ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Delete_Bsc_Sys_Dim_Lvl_Cols ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Delete_Bsc_Sys_Dim_Lvl_Cols;



/*********************************************************************************

-- Procedures to Handle Relationships between Dimension Levels

**********************************************************************************/

/*---------------------------------------------------------------------------------------
  Procedure :
---------------------------------------------------------------------------------------*/
PROCEDURE Create_Dim_Level_Relation(
  p_commit              IN      varchar2 --:= FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
) IS
 v_count        number;
 v_Dim_Level_Rec    BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
 v_Bsc_Pmf_Dim_Rec      BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type;


BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
 v_Dim_Level_Rec := p_Dim_Level_Rec;

 -- if the child is a PMF Level Check for Import the Level --
 if p_Dim_Level_Rec.Bsc_Source <> 'BSC' then
       v_Dim_Level_Rec.Bsc_Level_Id := BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(v_Dim_Level_Rec.Bsc_Level_Short_Name);
       if v_Dim_Level_Rec.Bsc_Level_Id is null then
         v_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name := v_Dim_Level_Rec.Bsc_Level_Short_Name;
         BSC_PMF_UI_API_PUB.Import_PMF_Dim_Level(p_commit ,v_Bsc_Pmf_Dim_Rec
                         ,x_return_status ,x_msg_count ,x_msg_data );
         v_Dim_Level_Rec.Bsc_Level_Id := BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(v_Dim_Level_Rec.Bsc_Level_Short_Name);
       end if;
 end if;

 -- if the parent is a PMF Level Check for Import it --
 if p_Dim_Level_Rec.Bsc_Parent_Level_Source <> 'BSC' then
       v_Dim_Level_Rec.Bsc_Parent_Level_Id  := BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(v_Dim_Level_Rec.Bsc_Parent_Level_Short_Name);
       if v_Dim_Level_Rec.Bsc_Parent_Level_Id is null then
         v_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name := v_Dim_Level_Rec.Bsc_Parent_Level_Short_Name;
         BSC_PMF_UI_API_PUB.Import_PMF_Dim_Level(p_commit ,v_Bsc_Pmf_Dim_Rec
                         ,x_return_status ,x_msg_count ,x_msg_data );
         v_Dim_Level_Rec.Bsc_Parent_Level_Id  := BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(v_Dim_Level_Rec.Bsc_Parent_Level_Short_Name);
       end if;
 end if;

 -- Insert the relationship Metadata --
 if Is_Valid_Relationship(p_commit, v_Dim_Level_Rec
                                           ,x_return_status, x_msg_count, x_msg_data) then
     BSC_DIMENSION_LEVELS_PVT.Create_Dim_Level_Relation(p_commit, v_Dim_Level_Rec
                                           ,x_return_status, x_msg_count, x_msg_data);
 -- Recreate Dimension Level View --
    if p_Dim_Level_Rec.Bsc_Source <> 'BSC' then
      BSC_DIMENSION_LEVELS_PVT.Create_BSC_Dim_Level_View (p_commit, v_Dim_Level_Rec
                                                    ,x_return_status, x_msg_count, x_msg_data);
    end if;

 end if;

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level_Relation ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level_Relation ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level_Relation ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level_Relation ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Create_Dim_Level_Relation;

/*---------------------------------------------------------------------------------------
  Procedure :
---------------------------------------------------------------------------------------*/
PROCEDURE Delete_Dim_Level_Relation(
  p_commit              IN      varchar2 --:= FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
 ) IS

 v_count number;
 v_Dim_Level_Rec BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;


BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  v_Dim_Level_Rec := p_Dim_Level_Rec;

 -- Check Bsc_Level_Id if the child is a PMF --
 IF (v_Dim_Level_Rec.Bsc_Level_Id IS NULL) THEN
     if v_Dim_Level_Rec.Bsc_Source <> 'BSC' then
          if v_Dim_Level_Rec.Bsc_Level_Id is null then
              v_Dim_Level_Rec.Bsc_Level_Id := BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(v_Dim_Level_Rec.Bsc_Level_Short_Name);
          end if;
     end if;
 END IF;

 -- Check Bsc_Level_Id if the parent is a PMF --
 IF (v_Dim_Level_Rec.Bsc_Parent_Level_Id IS NULL) THEN
     if v_Dim_Level_Rec.Bsc_Parent_Level_Source <> 'BSC' then
          if v_Dim_Level_Rec.Bsc_Parent_Level_Id is null then
               v_Dim_Level_Rec.Bsc_Parent_Level_Id := BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(v_Dim_Level_Rec.Bsc_Parent_Level_Short_Name);
          end if;
     end if;
 END IF;

 -- Delete the relationship Metadata --
 BSC_DIMENSION_LEVELS_PVT.Delete_Dim_Level_Relation(p_commit, v_Dim_Level_Rec
                                           ,x_return_status, x_msg_count, x_msg_data);

-- Recreate Level View for BSC --
 if v_Dim_Level_Rec.Bsc_Source <> 'BSC' then
   BSC_DIMENSION_LEVELS_PVT.Create_BSC_Dim_Level_View (p_commit, v_Dim_Level_Rec,
                                                             x_return_status, x_msg_count, x_msg_data);
 end if;

        --DBMS_OUTPUT.PUT_LINE('End Delete_Dim_Level_Relation ' );

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Delete_Dim_Level_Relation ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Delete_Dim_Level_Relation ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Delete_Dim_Level_Relation ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Delete_Dim_Level_Relation ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Dim_Level_Relation;
/*---------------------------------------------------------------------------------------
  Is_Valid_Relationship :
        Return tre if the future relation is valid
--------------------------------------------------------------------------------------*/
FUNCTION Is_Valid_Relationship(
  p_commit              IN      varchar2 --:= FND_API.G_FALSE
 ,p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
 ) RETURN BOOLEAN IS

 v_Temp BOOLEAN;
 v_msg varchar2(4000);

BEGIN
     x_return_status :=  FND_API.G_RET_STS_SUCCESS;
     FND_MSG_PUB.Initialize;
     v_Temp := BSC_DIMENSION_LEVELS_PVT.Evaluate_Circular_Relationship
                (   p_Dim_Level_Rec.Bsc_Level_Id
                   ,p_Dim_Level_Rec.Bsc_Parent_Level_Id
                   ,p_Dim_Level_Rec.Bsc_Relation_Type
                   ,true
                   ,v_msg
                   ,x_return_status
                   ,x_msg_count
                   ,x_msg_data
                );
     if v_Temp = false then
       if x_return_status = 'SAME' then
            FND_MESSAGE.SET_NAME('BSC','BSC_SAME_DIM_LEVEL_REL');
            FND_MESSAGE.SET_TOKEN('LEVEL_CHILD', BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Name(p_Dim_Level_Rec.Bsc_Level_Id) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       else
            FND_MESSAGE.SET_NAME('BSC','BSC_CIRCULAR_DIM_LEVEL_REL');
            FND_MESSAGE.SET_TOKEN('LEVEL_CHILD', BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Name(p_Dim_Level_Rec.Bsc_Level_Id) );
            FND_MESSAGE.SET_TOKEN('LEVEL_PARENT', BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Name(p_Dim_Level_Rec.Bsc_Parent_Level_Id));
            FND_MSG_PUB.ADD;
            --FND_MESSAGE.SET_NAME('BSC','BSC_EXISTING_DEPENDENCIES');
            --FND_MESSAGE.SET_TOKEN('DEPENDENCY', SUBSTR(v_msg, 1, 220)) ;
            --FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       end if;
     end if;
 x_return_status :=  FND_API.G_RET_STS_SUCCESS;
 RETURN v_Temp;
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RETURN FALSE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RETURN FALSE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Is_Valid_Relationship ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Is_Valid_Relationship ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RETURN FALSE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Is_Valid_Relationship ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Is_Valid_Relationship ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RETURN FALSE;
END Is_Valid_Relationship;

--------------------------------------------------------------------------------------
--  is_dependent :
--      Return Out NOCOPY parameter x_return_value = 'TRUE' or 'FALSE'
--------------------------------------------------------------------------------------
PROCEDURE is_dependent(
  p_commit                   IN     varchar2 --:= FND_API.G_FALSE
 ,p_child_dim_level_short_name   IN     varchar2
 ,p_parent_dim_level_short_name  IN     varchar2
 ,x_return_value        OUT NOCOPY             varchar2
 ,x_return_status       OUT NOCOPY          varchar2  /* return  FND_API.G_FALSE or  FND_API.G_TRUE */
 ,x_msg_count       OUT NOCOPY      number
 ,x_msg_data        OUT NOCOPY      varchar2
 ) IS

 CURSOR c_parents IS
     Select PARENT_SHORT_NAME
     from BSC_SYS_DIM_LEVEL_RELS_V
     where SHORT_NAME = UPPER(p_child_dim_level_short_name);

  v_parent  varchar2(50);
  v_count   number;

BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
   x_return_value := FND_API.G_FALSE;

   Select COUNT(1)
     into v_count
     from BSC_SYS_DIM_LEVEL_RELS_V
     where SHORT_NAME = UPPER(p_child_dim_level_short_name)
       and PARENT_SHORT_NAME = UPPER(p_parent_dim_level_short_name);

   if v_count <> 0 then
       x_return_value := FND_API.G_TRUE;
   else
    OPEN c_parents;
    LOOP
         FETCH c_parents INTO v_parent;
         EXIT WHEN c_parents%NOTFOUND;
         is_dependent( p_commit
                  ,v_parent
              ,p_parent_dim_level_short_name
              ,x_return_value
              ,x_return_status ,x_msg_count ,x_msg_data
                         );
             if x_return_value = FND_API.G_TRUE then
                   EXIT;
         end if;
    END LOOP;
    CLOSE c_parents;
   end if;

  --DBMS_OUTPUT.PUT_LINE('end is_dependent ' );

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.is_dependent ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.is_dependent ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.is_dependent ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.is_dependent ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END is_dependent;

--------------------------------------------------------------------------------------
--  get_parent_dimension_levels :
--      Return out NOCOPY parameter p_parent_dim_level_short_names with the parent
--                     short names separated by commas ","
--------------------------------------------------------------------------------------
PROCEDURE get_parent_dimension_levels(
  p_commit                   IN     varchar2 --:= FND_API.G_FALSE
 ,p_child_dim_level_short_name   IN     varchar2
 ,p_parent_dim_level_short_names OUT NOCOPY    varchar2
 ,x_return_status       OUT NOCOPY          varchar2  /* return  FND_API.G_FALSE or  FND_API.G_TRUE */
 ,x_msg_count       OUT NOCOPY      number
 ,x_msg_data        OUT NOCOPY      varchar2
 ) IS

  CURSOR c_parents IS
     Select PARENT_SHORT_NAME
     from BSC_SYS_DIM_LEVEL_RELS_V
     where SHORT_NAME = UPPER(p_child_dim_level_short_name);

  v_parent  varchar2(50);


BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  --DBMS_OUTPUT.PUT_LINE('Begin get_parent_dimension_levels' );

  p_parent_dim_level_short_names := null;
  OPEN c_parents;
   LOOP
     FETCH c_parents INTO v_parent;
     EXIT WHEN c_parents%NOTFOUND;
     --DBMS_OUTPUT.PUT_LINE('  get_parent_dimension_levels    v_parent = ' || v_parent );
     if p_parent_dim_level_short_names  is not null   then
    p_parent_dim_level_short_names := p_parent_dim_level_short_names || ',';
     end if;
     p_parent_dim_level_short_names := p_parent_dim_level_short_names ||  v_parent;
     --DBMS_OUTPUT.PUT_LINE('  get_parent_dimension_levels      p_parent_dim_level_short_names = ' || p_parent_dim_level_short_names );

   END LOOP;
   CLOSE c_parents;

  --DBMS_OUTPUT.PUT_LINE('end get_parent_dimension_levels' );

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.get_parent_dimension_levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.get_parent_dimension_levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.get_parent_dimension_levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.get_parent_dimension_levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END get_parent_dimension_levels;
--------------------------------------------------------------------------------------
--  get_child_dimension_levels :
--      Return out NOCOPY parameter p_parent_dim_level_short_names with the parent
--                     short names separated by commas ","
--------------------------------------------------------------------------------------
PROCEDURE get_child_dimension_levels(
  p_commit                   IN     varchar2 --:= FND_API.G_FALSE
 ,p_parent_dim_level_short_name  IN     varchar2
 ,p_child_dim_level_short_names  OUT NOCOPY    varchar2
 ,x_return_status       OUT NOCOPY          varchar2  /* return  FND_API.G_FALSE or  FND_API.G_TRUE */
 ,x_msg_count       OUT NOCOPY      number
 ,x_msg_data        OUT NOCOPY      varchar2
 ) IS
  CURSOR c_childs IS
     Select SHORT_NAME
     from BSC_SYS_DIM_LEVEL_RELS_V
     where PARENT_SHORT_NAME = UPPER(p_parent_dim_level_short_name);

  v_child   varchar2(50);


BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  --DBMS_OUTPUT.PUT_LINE('Begin get_child_dimension_levels' );

  p_child_dim_level_short_names := null;
  OPEN c_childs;
   LOOP
     FETCH c_childs INTO v_child;
     EXIT WHEN c_childs%NOTFOUND;
     --DBMS_OUTPUT.PUT_LINE('  get_child_dimension_levels    v_child = ' || v_child );
     if p_child_dim_level_short_names is not null  then
    p_child_dim_level_short_names := p_child_dim_level_short_names || ',' ;
     end if;
     p_child_dim_level_short_names  := p_child_dim_level_short_names ||  v_child;
     --DBMS_OUTPUT.PUT_LINE('  get_child_dimension_levels      p_child_dim_level_short_names = ' || p_child_dim_level_short_names );

   END LOOP;
   CLOSE c_childs;

  --DBMS_OUTPUT.PUT_LINE('end get_child_dimension_levels' );

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.get_child_dimension_levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.get_child_dimension_levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.get_child_dimension_levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.get_child_dimension_levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END get_child_dimension_levels;


--------------------------------------------------------------------------------------
--  is_Child_Parent :
--  Check to see if the passed Dim Level Ids form a Parent child relationship.
--
--  Added by ADRAO for Enh#2901823
--  Values returned wouid be in x_return_status (FND_API.G_FALSE or FND_API.G_TRUE)
--------------------------------------------------------------------------------------
FUNCTION is_Child_Parent
(
       p_child_dim_level_short_name     IN              VARCHAR2
     , p_parent_dim_level_short_name    IN              VARCHAR2
     , x_return_status                  OUT NOCOPY      VARCHAR2
     , x_msg_count                      OUT NOCOPY      NUMBER
     , x_msg_data                       OUT NOCOPY      VARCHAR2
) RETURN BOOLEAN IS

    l_count  NUMBER;
BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   SELECT COUNT(DIM_LEVEL_ID)
   INTO   l_count
   FROM   BSC_SYS_DIM_LEVEL_RELS_V
   WHERE  SHORT_NAME         = p_child_dim_level_short_name
   AND    PARENT_SHORT_NAME  = p_parent_dim_level_short_name ;

   IF (l_count <> 0) THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    RETURN FALSE;
END is_Child_Parent;



/************************************************************************************
************************************************************************************/

procedure Retrieve_Relationship
(
        p_Dim_Level_Rec         IN          BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_Dim_Level_Rec         OUT NOCOPY  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
 BEGIN
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    BSC_DIMENSION_LEVELS_PVT.Retrieve_Relationship
    (
            p_Dim_Level_Rec     =>  p_Dim_Level_Rec
        ,   x_Dim_Level_Rec     =>  x_Dim_Level_Rec
        ,   x_return_status     =>  x_return_status
        ,   x_msg_count         =>  x_msg_count
        ,   x_msg_data          =>  x_msg_data
    );
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Retrieve_Relationship ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Retrieve_Relationship ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Retrieve_Relationship ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Retrieve_Relationship ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Retrieve_Relationship;

/************************************************************************************
************************************************************************************/
--PAJOHRI added 01-JUN-2003
PROCEDURE Drop_Dim_Level_Tabs
(
   p_Dim_Level_Rec       IN      BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 , x_return_status       OUT     NOCOPY     VARCHAR2
 , x_msg_count           OUT     NOCOPY     NUMBER
 , x_msg_data            OUT     NOCOPY     VARCHAR2
) IS
BEGIN
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    BSC_DIMENSION_LEVELS_PVT.Delete_Dim_Level
    (
      p_commit              =>  FND_API.G_FALSE
     ,p_Dim_Level_Rec       =>  p_Dim_Level_Rec
     ,x_return_status       =>  x_return_status
     ,x_msg_count           =>  x_msg_count
     ,x_msg_data            =>  x_msg_data
    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Drop_Dim_Level_Tabs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Drop_Dim_Level_Tabs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Drop_Dim_Level_Tabs ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Drop_Dim_Level_Tabs;
--=============================================================================
PROCEDURE Translate_Dimension_Level (
  p_Commit IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bsc_Pmf_Dim_Rec IN BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
 ,p_Bsc_Dim_Level_Rec IN BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
)
IS
BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_LEVELS_PVT.Translate_Dimension_Level
    ( p_commit => p_Commit
     ,p_Bsc_Pmf_Dim_Rec  => p_Bsc_Pmf_Dim_Rec
     ,p_Bsc_Dim_Level_Rec => p_Bsc_Dim_Level_Rec
     ,x_return_status => x_return_status
     ,x_msg_count => x_msg_count
     ,x_msg_data => x_msg_data
    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Translate_Dimension_Level ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Translate_Dimension_Level ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.Translate_Dimension_Level ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_LEVELS_PUB.Translate_Dimension_Level ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Translate_Dimension_Level;
--=============================================================================
--=============================================================================
/*
 * API called from PMF for "All" enhancement
 */
PROCEDURE load_dimension_level(
  p_commit              IN          VARCHAR2 --:= FND_API.G_FALSE
 ,p_dim_level_rec       IN          BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY  VARCHAR2
 ,x_msg_count           OUT NOCOPY  NUMBER
 ,x_msg_data            OUT NOCOPY  VARCHAR2
)
IS
  l_bsc_dim_rec BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
  l_level_view_name     BSC_SYS_DIM_LEVELS_B.Level_View_Name%TYPE;
  l_count               NUMBER;
  l_table_type          BSC_SYS_DIM_LEVELS_B.Table_Type%TYPE;
  l_level_pk_col        BSC_SYS_DIM_LEVELS_B.Level_Pk_Col%TYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_bsc_dim_rec := p_dim_level_rec;
  BEGIN
    SELECT dim_level_id
         , level_view_name
         , table_type
         , level_pk_col
    INTO   l_Bsc_Dim_Rec.Bsc_Level_Id
         , l_level_view_name
         , l_table_type
         , l_level_pk_col
    FROM   bsc_sys_dim_levels_b
    WHERE  short_name = p_dim_level_rec.Bsc_Level_Short_Name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_Bsc_Dim_Rec.Bsc_Level_Id := NULL;
  END;

  IF (l_Bsc_Dim_Rec.Bsc_Level_Id IS NULL) THEN
    BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level(
       p_commit => p_Commit
      ,p_Dim_Level_Rec => l_Bsc_Dim_Rec
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data
    );
  ELSE
    l_Bsc_Dim_Rec.Bsc_Level_Table_Type := l_table_type;
    l_Bsc_Dim_Rec.Bsc_Pk_Col           := l_level_pk_col;

    BSC_DIMENSION_LEVELS_PUB.Update_Dim_Level(
       p_commit => p_Commit
      ,p_Dim_Level_Rec => l_Bsc_Dim_Rec
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data
    );

  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
       p_encoded   => 'F'
      ,p_count     =>  x_msg_count
      ,p_data      =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
       p_encoded   => 'F'
      ,p_count     =>  x_msg_count
      ,p_data      =>  x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_LEVELS_PUB.load_dimension_level ';
    ELSE
      x_msg_data      := 'BSC_DIMENSION_LEVELS_PUB.load_dimension_level '||SQLERRM;
    END IF;

END load_dimension_level;
--=============================================================================


/*************************************************************************************

    API TO SYNC UP THE DIMENSION LEVEL DATA FROM PMF TO BSC

*************************************************************************************/

procedure Trans_DimObj_By_Given_Lang
(
    p_commit              IN  VARCHAR2
  , p_dim_level_rec       IN  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
  , x_return_status       OUT NOCOPY  VARCHAR2
  , x_msg_count           OUT NOCOPY  NUMBER
  , x_msg_data            OUT NOCOPY  VARCHAR2
)
IS

BEGIN

    BSC_DIMENSION_LEVELS_PVT.Trans_DimObj_By_Given_Lang
    (
            p_commit                =>  FND_API.G_FALSE
        ,   p_dim_level_rec         =>  p_dim_level_rec
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);

END Trans_DimObj_By_Given_Lang;


/*************************************************************************************

    API TO FIX/VALIDATE VIEWS FROM SOURCE PMF DIM LEVELS
    Called by Concurrent Program BSC_VALID_DIM_LEVELS_TABLE

*************************************************************************************/

PROCEDURE Validate_Imported_Level_Views
(
    ERRBUF OUT NOCOPY VARCHAR2
  , RETCODE OUT NOCOPY VARCHAR2
)
IS
    x_return_status       VARCHAR2(1);
    x_msg_count           NUMBER;
    x_msg_data            VARCHAR2(200);

    l_dim_level_rec       BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
    l_Error_Tbl           BIS_UTILITIES_PUB.Error_Tbl_Type;
    l_Count               number;
    l_Temp_Count          NUMBER;
    l_Dummy               VARCHAR2(100);
    l_Debug_Flag          BOOLEAN;
    l_Fix_Row_Flag        BOOLEAN ;
    p_commit              VARCHAR2(1);
BEGIN

   l_Fix_Row_Flag := FALSE;
   p_commit       := FND_API.G_TRUE;

   SAVEPOINT ValidImportDimLevelViews;
   FND_MSG_PUB.Initialize;

   BIS_UTILITIES_PUB.Get_Debug_Mode_Profile
   (
       x_Is_Debug_Mode => l_Debug_Flag
     , x_Return_Status => x_Return_Status
     , x_Return_Msg    => x_Msg_Data
   );

   BIS_UTILITIES_PUB.Set_Debug_Log_Flag
   (   p_is_true       => TRUE
     , x_Return_Status => x_Return_Status
     , x_Return_Msg    => x_Msg_Data
   );

   BIS_UTILITIES_PUB.PUT_LINE
   (
        p_text => 'BEGIN IMPORT DIMENSION OBJECT VIEWS VALIDATION ....'
   );


    -- Sucess --
   x_Return_Status := FND_API.G_RET_STS_SUCCESS;

   -- Call the refresh Dimension Object Views.
   BSC_BIS_DIM_OBJ_PUB.Refresh_BSC_PMF_Dim_View
   (     p_Short_Name        =>  NULL
       , x_return_status     =>  x_Return_Status
       , x_msg_count         =>  x_Msg_Count
       , x_msg_data          =>  x_Msg_Data
   );


   IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
   END IF;

   BIS_UTILITIES_PUB.PUT_LINE
   (
        p_text => 'END IMPORT DIMENSION OBJECT VIEWS VALIDATION ...'
   );

   BIS_UTILITIES_PUB.Set_Debug_Log_Flag
   (
         p_Is_True       => l_Debug_Flag
       , x_Return_Status => x_Return_Status
       , x_Return_Msg    => x_Msg_Data
   );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETCODE         := 2; -- Concurrent program display Error
    ERRBUF          := x_msg_data; -- Concurrent program err message

    BIS_UTILITIES_PUB.PUT_LINE
    (
        p_Text => x_Msg_Data
    );

    BIS_UTILITIES_PUB.set_debug_log_flag
    (
         p_is_true       => l_debug_flag
       , x_return_status => x_return_status
       , x_return_msg    => x_msg_data
    );

    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETCODE := 2; -- Concurrent program display Error
    ERRBUF := x_msg_data; -- Concurrent program err message
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PUB.PUT_LINE
    (
        p_Text => x_Msg_Data
    );

    BIS_UTILITIES_PUB.set_debug_log_flag
    (
         p_is_true       => l_debug_flag
       , x_return_status => x_return_status
       , x_return_msg    => x_msg_data
    );
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETCODE := 2; -- Concurrent program display Error
    ERRBUF := x_msg_data; -- Concurrent program err message
    BIS_UTILITIES_PUB.PUT_LINE
    (
        p_Text => x_Msg_Data
    );

    BIS_UTILITIES_PUB.set_debug_log_flag
    (
         p_is_true       => l_debug_flag
       , x_return_status => x_return_status
       , x_return_msg    => x_msg_data
    );
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN OTHERS THEN
    RETCODE := 2; -- Concurrent program display Error
    ERRBUF := x_msg_data; -- Concurrent program err message
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PUB.PUT_LINE
    (
        p_Text => x_Msg_Data
    );

    BIS_UTILITIES_PUB.set_debug_log_flag
    (
         p_is_true       => l_debug_flag
       , x_return_status => x_return_status
       , x_return_msg    => x_msg_data
    );
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;

END Validate_Imported_Level_Views;

end BSC_DIMENSION_LEVELS_PUB;

/
