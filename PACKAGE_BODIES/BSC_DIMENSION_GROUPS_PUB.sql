--------------------------------------------------------
--  DDL for Package Body BSC_DIMENSION_GROUPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DIMENSION_GROUPS_PUB" as
/* $Header: BSCPDMGB.pls 120.0 2005/05/31 18:54:36 appldev noship $ */
/*
 +==============================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA            |
 |                         All rights reserved.                                 |
 +==============================================================================+
 | FILENAME                                                                     |
 |                      BSCPDMGB.pls                                            |
 |                                                                              |
 | Creation Date:                                                               |
 |                      October 9, 2001                                         |
 |                                                                              |
 | Creator:                                                                     |
 |                      Mario-Jair Campos                                       |
 |                                                                              |
 | Description:                                                                 |
 |          Public Body version.                                                |
 |          This Package creates a Dimension Group.                             |
 | History:                                                                     |
 | 23-FEB-03 PAJOHRI  Added Short_Name to  Bsc_Dim_Group_Rec_Type               |
 |                    Created Overloaded procedures CREATE_DIMENSION_GROUP      |
 |                                                  UPDATE_DIMENSION_GROUP      |
 | 29-MAY-03  All Enhancement Phase I- Functions added                          |
 |             "Retrieve_Sys_Dim_Lvls_Grp_Wrap"                                 |
 |                        and set_dim_lvl_grp_prop_wrap                         |
 | 07-JUN-03  mahrao Modified for ALL enhancement                               |
 | 13-JUN-03  Adeulgao fixed Bug#2878840,Added function Get_Next_Value to get   |
 |            the next DIM GROUP ID                                             |
 | 13-JUN-03  Adeulgao Modified procedure Create_Dimension_Group for Bug2878840 |
 | 14-JUN-03  mahrao   Added Translate_dimesnsion_group procedure               |
 | 17-JUL-03  mahrao   Modified exception handling section of                   |
 |                     Translate_Dimension_Group as part of forward porting of  |
 |                     ALL enhancement to BSC 5.1                               |
 |                     Modified load_dimension_group as part of forward porting |
 |                     of ALL enhancement to BSC 5.1.                           |
 |                     Modified exception handling section of                   |
 |                     load_dim_levels_in_group as part of forward porting of   |
 |                     ALL enhancement to BSC 5.1                               |
 |                     Modified exception handling section of as                |
 |                     ret_dimgrpid_fr_shname part of forward port of           |
 |                     ALL enhancement to BSC 5.1                               |
 | 22-JUL-2003 arhegde bug#3050270 Added dim_properties_default_values and calls|
 | 29-OCT-2003 mahrao  bug#3209967 Added a column to bsc_sys_dim_levels_by_group|
 | 14-NOV-2003 mahrao  x_dim_level_where_clause is removed from prcoedure       |
 |                     Retrieve_Sys_Dim_Lvls_Grp_Wrap as PMF 4.0.7 shouldn't    |
 |                     pick up any dependency on 5.1.1                          |
 | 07-JAN-2004 rpenneru bug#3459443 Modified for getting where clause from      |
 |                                 BSC data model		                |
 | 30-Jul-04   rpenneru Modified for enhancemen#3748519                         |
 | 21-DEC-04   vtulasi  Modified for bug#4045278 - Addtion of LUD               |
 | 30-DEC-04   vtulasi  For bug #4093926                                        |
+==============================================================================+
*/
G_PKG_NAME      CONSTANT    varchar2(30) := 'BSC_DIMENSION_GROUPS_PUB';

--: This procedure is used to Create a Dimension Group.  This is the entry point
--: for the API for the Dimension Group entity.
--: This procedure is part of the Dimension Group API.

procedure Create_Dimension_Group(
  p_commit              IN         varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN         BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,p_create_Dim_Levels   IN         BOOLEAN
 ,x_return_status       OUT NOCOPY varchar2
 ,x_msg_count           OUT NOCOPY number
 ,x_msg_data            OUT NOCOPY varchar2
) is

l_Dim_Grp_Rec           BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;
  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Dim_Grp_Rec := p_Dim_Grp_Rec;

  -- Assign certain default values if ther are currently null.
  if l_Dim_Grp_Rec.Bsc_Group_Level_Comp_Flag is null then
    l_Dim_Grp_Rec.Bsc_Group_Level_Comp_Flag := 1;
  end if;
  if l_Dim_Grp_Rec.Bsc_Group_Level_Default_Value is null then
    l_Dim_Grp_Rec.Bsc_Group_Level_Default_Value := 'T';
  end if;
  if l_Dim_Grp_Rec.Bsc_Group_Level_Default_Type is null then
    l_Dim_Grp_Rec.Bsc_Group_Level_Default_Type := 0;
  end if;
  if l_Dim_Grp_Rec.Bsc_Group_Level_Filter_Value is null then
    l_Dim_Grp_Rec.Bsc_Group_Level_Filter_Value := 0;
  end if;
  if l_Dim_Grp_Rec.Bsc_Group_Level_No_Items is null then
    l_Dim_Grp_Rec.Bsc_Group_Level_No_Items := 0;
  end if;
  if l_Dim_Grp_Rec.Bsc_Group_Level_Parent_In_Tot is null then
    l_Dim_Grp_Rec.Bsc_Group_Level_Parent_In_Tot := 2;
  end if;
  if l_Dim_Grp_Rec.Bsc_Group_Level_Total_Flag is null then
    l_Dim_Grp_Rec.Bsc_Group_Level_Total_Flag := -1;
  end if;

  -- PMD WHO Columns for Granular Locking
  if l_Dim_Grp_Rec.Bsc_Created_By is null then
    l_Dim_Grp_Rec.Bsc_Created_By := FND_GLOBAL.USER_ID;
  end if;
  l_Dim_Grp_Rec.Bsc_Last_Update_Date := NVL(p_Dim_Grp_Rec.Bsc_Last_Update_Date, SYSDATE);
  if l_Dim_Grp_Rec.Bsc_Creation_Date is null then
    l_Dim_Grp_Rec.Bsc_Creation_Date := l_Dim_Grp_Rec.Bsc_Last_Update_Date;
  end if;
  if l_Dim_Grp_Rec.Bsc_Last_Updated_By is null then
    l_Dim_Grp_Rec.Bsc_Last_Updated_By := FND_GLOBAL.USER_ID;
  end if;
   if l_Dim_Grp_Rec.Bsc_Last_Update_Login is null then
    l_Dim_Grp_Rec.Bsc_Last_Update_Login := FND_GLOBAL.LOGIN_ID;
  end if;


  -- Check that a group name has been entered.
  if l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name is not null then

    -- Validate if this Group already exists, if it does not then create it and assign
    -- the current dimension to the group, if the group already exists then just assign
    -- the dimension level to it.
    --PAJOHRI Commented the condition below
    --if BSC_DIMENSION_LEVELS_PVT.Validate_Dim_Group(p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name) < 1 then

      -- Get the next ID value for the current group.

      IF  l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id IS NULL THEN
        l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value( 'BSC_SYS_DIM_GROUPS_TL'
                                                          ,'DIM_GROUP_ID');
      END IF;


      -- Call private version of this procedure.
      BSC_DIMENSION_GROUPS_PVT.Create_Dimension_Group( p_commit
                                                ,l_Dim_Grp_Rec
                                                ,x_return_status
                                                ,x_msg_count
                                                ,x_msg_data);


      -- Call private version of this procedure.
      IF (p_create_Dim_Levels) THEN
        Create_Dim_Levels_In_Group( p_commit
                                 ,l_Dim_Grp_Rec
                                 ,x_return_status
                                 ,x_msg_count
                                 ,x_msg_data);
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

   /* else
        IF (p_create_Dim_Levels) THEN
          -- Get the group id for the current group name.
          select dim_group_id
            into l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id
            from BSC_SYS_DIM_GROUPS_VL
           where upper(name) = upper(p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name);

          -- Call private version of this procedure.
          Create_Dim_Levels_In_Group( p_commit
                                   ,l_Dim_Grp_Rec
                                   ,x_return_status
                                   ,x_msg_count
                                   ,x_msg_data);
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    end if;*/

  else

    FND_MESSAGE.SET_NAME('BSC','BSC_GROUP_NAME_NOT_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_GROUP_NAME', l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;

  end if;


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
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Create_Dimension_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Create_Dimension_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Create_Dimension_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Create_Dimension_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Dimension_Group;


procedure Create_Dimension_Group(
  p_commit              IN         varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN         BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY varchar2
 ,x_msg_count           OUT NOCOPY number
 ,x_msg_data            OUT NOCOPY varchar2
) is

l_Dim_Grp_Rec BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;

BEGIN
    l_Dim_Grp_Rec := p_Dim_Grp_Rec;
    l_Dim_Grp_Rec.Bsc_Last_Update_Date := NVL(p_Dim_Grp_Rec.Bsc_Last_Update_Date, SYSDATE);

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    Create_Dimension_Group(
      p_commit              =>  p_commit
     ,p_Dim_Grp_Rec         =>  l_Dim_Grp_Rec
     ,p_create_Dim_Levels   =>  TRUE
     ,x_return_status       =>  x_return_status
     ,x_msg_count           =>  x_msg_count
     ,x_msg_data            =>  x_msg_data
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
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Create_Dimension_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Create_Dimension_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Create_Dimension_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Create_Dimension_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Dimension_Group;
/************************************************************************************
************************************************************************************/

procedure Retrieve_Dimension_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec       IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_Dim_Grp_Rec       IN OUT NOCOPY     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_GROUPS_PVT.Retrieve_Dimension_Group( p_commit
                                              ,p_Dim_Grp_Rec
                                              ,x_Dim_Grp_Rec
                                              ,x_return_status
                                              ,x_msg_count
                                              ,x_msg_data);

  Retrieve_Dim_Levels_In_Group( p_commit
                               ,p_Dim_Grp_Rec
                               ,x_Dim_Grp_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Retrieve_Dimension_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Retrieve_Dimension_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Retrieve_Dimension_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Retrieve_Dimension_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Retrieve_Dimension_Group;

/************************************************************************************
************************************************************************************/

procedure Update_Dimension_Group(
  p_commit              IN            varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN            BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,p_create_Dim_Levels   IN            BOOLEAN
 ,x_return_status       OUT  NOCOPY   varchar2
 ,x_msg_count           OUT  NOCOPY   number
 ,x_msg_data            OUT  NOCOPY   varchar2
) IS

l_Dim_Grp_Rec BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
begin

  l_Dim_Grp_Rec := p_Dim_Grp_Rec;
  l_Dim_Grp_Rec.Bsc_Last_Update_Date := NVL(p_Dim_Grp_Rec.Bsc_Last_Update_Date, SYSDATE);
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  BSC_DIMENSION_GROUPS_PVT.Update_Dimension_Group( p_commit
                                            ,l_Dim_Grp_Rec
                                            ,x_return_status
                                            ,x_msg_count
                                            ,x_msg_data);
  IF (p_create_Dim_Levels) THEN
      Update_Dim_Levels_In_Group( p_commit
                                 ,p_Dim_Grp_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Update_Dimension_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Update_Dimension_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Update_Dimension_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Update_Dimension_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Update_Dimension_Group;


procedure Update_Dimension_Group(
  p_commit              IN            varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN            BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT   NOCOPY  varchar2
 ,x_msg_count           OUT   NOCOPY  number
 ,x_msg_data            OUT   NOCOPY  varchar2
) is

l_Dim_Grp_Rec BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
begin
  l_Dim_Grp_Rec := p_Dim_Grp_Rec;
  l_Dim_Grp_Rec.Bsc_Last_Update_Date := NVL(p_Dim_Grp_Rec.Bsc_Last_Update_Date, SYSDATE);

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  Update_Dimension_Group(
    p_commit              =>  p_commit
   ,p_Dim_Grp_Rec         =>  l_Dim_Grp_Rec
   ,p_create_Dim_Levels   =>  TRUE
   ,x_return_status       =>  x_return_status
   ,x_msg_count           =>  x_msg_count
   ,x_msg_data            =>  x_msg_data
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
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Update_Dimension_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Update_Dimension_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Update_Dimension_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Update_Dimension_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Update_Dimension_Group;

/************************************************************************************
************************************************************************************/

--: This procedure is part of the Dimension Group API.

procedure Delete_Dimension_Group(
  p_commit              IN            varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN            BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT  NOCOPY   varchar2
 ,x_msg_count           OUT  NOCOPY   number
 ,x_msg_data            OUT  NOCOPY   varchar2
)is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  -- When deleting dimension groups the first thing to do is to delete
  -- the dimension levels from the group.
  Delete_Dim_Levels_In_Group( p_commit
                             ,p_Dim_Grp_Rec
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  BSC_DIMENSION_GROUPS_PVT.Delete_Dimension_Group( p_commit
                                                  ,p_Dim_Grp_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Delete_Dimension_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Delete_Dimension_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Delete_Dimension_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Delete_Dimension_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Delete_Dimension_Group;

/************************************************************************************
************************************************************************************/

--:     This procedure assigns the dimension to the dimension group.
--:     This procedure is part of the Dimension Group API.

procedure Create_Dim_Levels_In_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is
  l_dim_level_index NUMBER;
  l_total_flag NUMBER;
  l_comparison_flag NUMBER;
  l_filter_column bsc_sys_dim_levels_by_group.filter_column%TYPE;
  l_filter_value NUMBER;
  l_default_value bsc_sys_dim_levels_by_group.default_value%TYPE;
  l_default_type NUMBER;
  l_parent_in_total NUMBER;
  l_no_items NUMBER;
  l_total_disp_name bsc_sys_dim_levels_vl.total_disp_name%TYPE;
  l_comp_disp_name bsc_sys_dim_levels_vl.comp_disp_name%TYPE;
  l_Dim_Grp_Rec BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
begin

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_Dim_Grp_Rec := p_Dim_Grp_Rec;

  dim_properties_default_values (
     x_dim_level_index => l_dim_level_index
    ,x_total_flag => l_total_flag
    ,x_comparison_flag => l_comparison_flag
    ,x_filter_column => l_filter_column
    ,x_filter_value => l_filter_value
    ,x_default_value => l_default_value
    ,x_default_type => l_default_type
    ,x_parent_in_total => l_parent_in_total
    ,x_no_items => l_no_items
    ,x_total_disp_name => l_total_disp_name
    ,x_comp_disp_name => l_comp_disp_name
  );

  IF (l_Dim_Grp_Rec.Bsc_Group_Level_Comp_Flag IS NULL) THEN
    l_Dim_Grp_Rec.Bsc_Group_Level_Comp_Flag := l_comparison_flag;
  END IF;
  IF (l_Dim_Grp_Rec.Bsc_Group_Level_Default_Value IS NULL) THEN
    l_Dim_Grp_Rec.Bsc_Group_Level_Default_Value := l_default_value;
  END IF;
  IF (l_Dim_Grp_Rec.Bsc_Group_Level_Default_Type IS NULL) THEN
    l_Dim_Grp_Rec.Bsc_Group_Level_Default_Type := l_default_type;
  END IF;
  IF (l_Dim_Grp_Rec.Bsc_Group_Level_Filter_Value IS NULL) THEN
    l_Dim_Grp_Rec.Bsc_Group_Level_Filter_Value := l_filter_value;
  END IF;
  IF (l_Dim_Grp_Rec.Bsc_Group_Level_No_Items IS NULL) THEN
    l_Dim_Grp_Rec.Bsc_Group_Level_No_Items := l_no_items;
  END IF;
  IF (l_Dim_Grp_Rec.Bsc_Group_Level_Parent_In_Tot IS NULL) THEN
    l_Dim_Grp_Rec.Bsc_Group_Level_Parent_In_Tot := l_parent_in_total;
  END IF;
  IF (l_Dim_Grp_Rec.Bsc_Group_Level_Total_Flag IS NULL) THEN
    l_Dim_Grp_Rec.Bsc_Group_Level_Total_Flag := l_total_flag;
  END IF;

  -- Call private version of the procedure.
  BSC_DIMENSION_GROUPS_PVT.Create_Dim_Levels_In_Group( p_commit
                                                      ,l_Dim_Grp_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Create_Dim_Levels_In_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Create_Dim_Levels_In_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Create_Dim_Levels_In_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Create_Dim_Levels_In_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Create_Dim_Levels_In_Group;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Dim_Levels_In_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec       IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_Dim_Grp_Rec       IN OUT NOCOPY     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_GROUPS_PVT.Retrieve_Dim_Levels_In_Group( p_commit
                                                        ,p_Dim_Grp_Rec
                                                        ,x_Dim_Grp_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Retrieve_Dim_Levels_In_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Retrieve_Dim_Levels_In_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Retrieve_Dim_Levels_In_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Retrieve_Dim_Levels_In_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Retrieve_Dim_Levels_In_Group;

/************************************************************************************
************************************************************************************/

procedure Update_Dim_Levels_In_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec       IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_GROUPS_PVT.Update_Dim_Levels_In_Group( p_commit
                                                ,p_Dim_Grp_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Update_Dim_Levels_In_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Update_Dim_Levels_In_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Update_Dim_Levels_In_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Update_Dim_Levels_In_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Update_Dim_Levels_In_Group;

/************************************************************************************
************************************************************************************/

--: This procedure deletes dimensions from dimension groups.

procedure Delete_Dim_Levels_In_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_GROUPS_PVT.Delete_Dim_Levels_In_Group( p_commit
                                                ,p_Dim_Grp_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Delete_Dim_Levels_In_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Delete_Dim_Levels_In_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Delete_Dim_Levels_In_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Delete_Dim_Levels_In_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Delete_Dim_Levels_In_Group;

--===================================================================
/*
 * This is called from PMF - DimLevelUtil.java
 * Returns the properties set in bsc_sys_dim_levels_by_group such as
 * 'All' property. If no data is present in the tables, then it returns
 * default values set at the record level
 */

PROCEDURE Retrieve_Sys_Dim_Lvls_Grp_Wrap
(
        p_dim_level_shortname   IN          VARCHAR2
    ,   p_dim_shortname         IN          VARCHAR2
    ,   x_dim_group_id          OUT NOCOPY  NUMBER
    ,   x_dim_level_id          OUT NOCOPY  NUMBER
    ,   x_dim_level_index       OUT NOCOPY  NUMBER
    ,   x_total_flag            OUT NOCOPY  NUMBER
    ,   x_total_disp_name       OUT NOCOPY  VARCHAR2
    ,   x_dim_level_where_clause OUT NOCOPY VARCHAR2
    ,   x_comparison_flag       OUT NOCOPY  NUMBER
    ,   x_comp_disp_name        OUT NOCOPY  VARCHAR2
    ,   x_filter_column         OUT NOCOPY  VARCHAR2
    ,   x_filter_value          OUT NOCOPY  NUMBER
    ,   x_default_value         OUT NOCOPY  VARCHAR2
    ,   x_default_type          OUT NOCOPY  NUMBER
    ,   x_parent_in_total       OUT NOCOPY  NUMBER
    ,   x_no_items              OUT NOCOPY  NUMBER
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
 )
 IS
  l_dim_level_id NUMBER;
  l_dim_group_id NUMBER;
  l_dim_grp_rec BSC_DIMENSION_GROUPS_PUB.BSC_DIM_GROUP_REC_TYPE;
  l_dim_grp_rec_out BSC_DIMENSION_GROUPS_PUB.BSC_DIM_GROUP_REC_TYPE;

  CURSOR c_dim_group (cp_dim_shortname VARCHAR2) IS
    SELECT dim_group_id
    FROM   bsc_sys_dim_groups_vl
    WHERE  short_name = cp_dim_shortname;

  CURSOR c_dim_level (cp_dim_level_shortname VARCHAR2) IS
    SELECT dim_level_id, total_disp_name, comp_disp_name
    FROM   bsc_sys_dim_levels_vl
    WHERE  short_name = cp_dim_level_shortname;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- group
  IF (c_dim_group%ISOPEN) THEN
    CLOSE c_dim_group;
  END IF;

  OPEN c_dim_group (cp_dim_shortname => p_dim_shortname);
  FETCH c_dim_group INTO l_dim_group_id;
  CLOSE c_dim_group;

  -- level
  IF (c_dim_level%ISOPEN) THEN
    CLOSE c_dim_level;
  END IF;

  OPEN c_dim_level (cp_dim_level_shortname => p_dim_level_shortname);
  FETCH c_dim_level INTO l_dim_level_id, x_total_disp_name, x_comp_disp_name;
  CLOSE c_dim_level;

  -- only if values are present in BSC tables
  IF ((l_dim_group_id IS NOT NULL) AND (l_dim_level_id IS NOT NULL)) THEN
    l_dim_grp_rec.bsc_level_id := l_dim_level_id;
    l_dim_grp_rec.Bsc_Dim_Level_Group_Id := l_dim_group_id;

    BEGIN

      BSC_DIMENSION_GROUPS_PVT.Retrieve_Dim_Levels_In_Group(
         p_commit => NULL
        ,p_Dim_Grp_Rec => l_dim_grp_rec
        ,x_Dim_Grp_Rec => l_dim_grp_rec_out
        ,x_return_status => x_return_status
        ,x_msg_count => x_msg_count
        ,x_msg_data => x_msg_data
      );
    EXCEPTION
      WHEN OTHERS THEN
      x_return_status := C_DEFAULT_DATA;
    END;

    l_dim_grp_rec_out.bsc_level_id  := l_dim_level_id;
    l_dim_grp_rec_out.Bsc_Dim_Level_Group_Id := l_dim_group_id;

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := C_DEFAULT_DATA;
    END IF;
  ELSE
    x_return_status := C_DEFAULT_DATA;
  END IF;

  IF (x_return_status = C_DEFAULT_DATA) THEN
    -- All default values when error occurs
    dim_properties_default_values (
       x_dim_level_index => x_dim_level_index
      ,x_total_flag => x_total_flag
      ,x_comparison_flag => x_comparison_flag
      ,x_filter_column => x_filter_column
      ,x_filter_value => x_filter_value
      ,x_default_value => x_default_value
      ,x_default_type => x_default_type
      ,x_parent_in_total => x_parent_in_total
      ,x_no_items => x_no_items
      ,x_total_disp_name => x_total_disp_name
      ,x_comp_disp_name => x_comp_disp_name
    );

  ELSE

    -- These are populated with values retrieved
    x_dim_group_id := l_dim_grp_rec_out.bsc_dim_level_group_id;
    x_dim_level_id := l_dim_grp_rec_out.bsc_level_Id;
    x_dim_level_index := l_dim_grp_rec_out.bsc_dim_level_index;
    x_total_flag := l_dim_grp_rec_out.bsc_group_level_total_flag;
    x_dim_level_where_clause := l_dim_grp_rec_out.Bsc_Group_Level_Where_Clause;
    x_comparison_flag := l_dim_grp_rec_out.bsc_group_level_comp_flag;
    x_filter_column := l_dim_grp_rec_out.bsc_group_level_filter_col;
    x_filter_value := l_dim_grp_rec_out.bsc_group_level_filter_value;
    x_default_value := l_dim_grp_rec_out.bsc_group_level_default_value;
    x_default_type := l_dim_grp_rec_out.bsc_group_level_default_type;
    x_parent_in_total := l_dim_grp_rec_out.bsc_group_level_parent_in_tot;
    x_no_items := l_dim_grp_rec_out.bsc_group_level_no_items;

  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_dim_group%ISOPEN) THEN
          CLOSE c_dim_group;
        END IF;
        IF (c_dim_level%ISOPEN) THEN
          CLOSE c_dim_level;
        END IF;
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
        IF (c_dim_group%ISOPEN) THEN
          CLOSE c_dim_group;
        END IF;
        IF (c_dim_level%ISOPEN) THEN
          CLOSE c_dim_level;
        END IF;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        IF (c_dim_group%ISOPEN) THEN
          CLOSE c_dim_group;
        END IF;
        IF (c_dim_level%ISOPEN) THEN
          CLOSE c_dim_level;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Retrieve_Sys_Dim_Lvls_Grp_Wrap ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.Retrieve_Sys_Dim_Lvls_Grp_Wrap ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Retrieve_Sys_Dim_Lvls_Grp_Wrap;

--========================================================================

PROCEDURE dim_properties_default_values (
  x_dim_level_index OUT NOCOPY NUMBER
 ,x_total_flag OUT NOCOPY NUMBER
 ,x_comparison_flag OUT NOCOPY NUMBER
 ,x_filter_column OUT NOCOPY VARCHAR2
 ,x_filter_value OUT NOCOPY NUMBER
 ,x_default_value OUT NOCOPY VARCHAR2
 ,x_default_type OUT NOCOPY NUMBER
 ,x_parent_in_total OUT NOCOPY NUMBER
 ,x_no_items OUT NOCOPY NUMBER
 ,x_total_disp_name OUT NOCOPY VARCHAR2
 ,x_comp_disp_name OUT NOCOPY VARCHAR2
)
IS

BEGIN
 x_dim_level_index := NULL;
 x_total_flag := c_total_flag;
 x_comparison_flag := c_comp_flag;
 x_filter_column := NULL;
 x_filter_value := c_filter_value;
 x_default_value := c_default_value;
 x_default_type := c_default_type;
 x_parent_in_total := c_parent_in_tot;
 x_no_items := c_no_items;

 x_total_disp_name := NVL(BSC_APPS.get_lookup_value('BSC_UI_COMMON', 'ALL'), 'ALL');
 x_comp_disp_name := NVL(BSC_APPS.get_lookup_value('BSC_UI_COMMON', 'COMPARISON'), 'COMPARISON');

EXCEPTION
  WHEN OTHERS THEN
  NULL;
END;

--======================================================================

PROCEDURE set_dim_lvl_grp_prop_wrap (
  p_dim_level_shortname IN VARCHAR2
 ,p_dim_shortname   IN VARCHAR2
 ,p_all_id IN NUMBER
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count   OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
 ) IS

 l_dim_grp_rec BSC_DIMENSION_GROUPS_PUB.BSC_DIM_GROUP_REC_TYPE;
 l_dim_level_id NUMBER;
 l_dim_group_id NUMBER;
BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;
  IF (p_all_id NOT IN (0, -1)) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_ALL_ID');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
-- Dimension level short name in bsc_sys_dim_levels_b should be same as dimension
-- level short name in bis_levels.
    SELECT dim_level_id
  INTO   l_dim_level_id
  FROM   bsc_sys_dim_levels_b
  WHERE  short_name = p_dim_level_shortname;

-- Passing dim_group_id is mandatory for calling the below procedure. As,
-- dimension short name is not populated as of now in bsc_sys_dim_groups_tl
-- dim_group_id will be retrieved from the bsc_sys_dim_levels_by_group table.
-- This shouldn't create any problem as dim_level_id is unique in
-- bsc_sys_dim_levels_by_group table for levels imported from PMF to BSC.

    SELECT dim_group_id
  INTO   l_dim_group_id
  FROM   bsc_sys_dim_groups_vl
  WHERE  short_name = p_dim_shortname;

    l_dim_grp_rec.bsc_level_id := l_dim_level_id;
    l_dim_grp_rec.bsc_dim_level_group_id := l_dim_group_id;
  l_dim_grp_rec.bsc_group_level_total_flag := p_all_id;

    BSC_DIMENSION_GROUPS_PVT.Update_Dim_Levels_In_Group(
     p_commit => FND_API.G_TRUE
    ,p_dim_grp_rec => l_dim_grp_rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.set_dim_lvl_grp_prop_wrap ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.set_dim_lvl_grp_prop_wrap ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.set_dim_lvl_grp_prop_wrap ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_GROUPS_PUB.set_dim_lvl_grp_prop_wrap ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END set_dim_lvl_grp_prop_wrap;

/************************************************************************************
************************************************************************************/

-- Amit Code

function Get_Next_Value(
  p_table_name          IN      varchar2
 ,p_column_name         IN      varchar2
)return number is

l_return_status                 varchar2(100);
l_msg_data                      varchar2(10);
l_msg_count                     number;

begin

return BSC_DIMENSION_LEVELS_PVT.Get_Next_Value( p_table_name
                                                ,p_column_name);
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    l_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      l_msg_count
                              ,p_data   =>      l_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      l_msg_count
                              ,p_data     =>      l_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    l_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      l_msg_count
                              ,p_data     =>      l_msg_data);
    raise;
  WHEN OTHERS THEN
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      l_msg_count
                              ,p_data     =>      l_msg_data);
    raise;
end Get_Next_Value;

--=============================================================================
/* Used only by PMF for "All" enhancement to upload bisdimlv.ldt.
 * Called from BISDIMLV.lct
 */
PROCEDURE Translate_Dimension_Group
( p_commit IN  VARCHAR2   := FND_API.G_FALSE
 ,p_Dim_Grp_Rec IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
)
IS
   l_Dim_Grp_Rec BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;

BEGIN

  l_Dim_Grp_Rec := p_Dim_Grp_Rec;
  -- If the dimension group name in bsc is the same as that in pmf seeded dimensions, then use another name
  -- since name is used as a unique column in bsc_sys_dim_groups_tl. The name itself will not matter
  -- for PMF since short_name is used at all places. (bug# 3028436)

  get_unique_dim_group_name(
    p_dim_group_name => p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name
   ,p_dim_group_short_name => p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name
   ,p_is_insert => 'N'
   ,p_counter => 0
   ,x_dim_group_name => l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name
  );

  l_Dim_Grp_Rec.Bsc_Last_Update_Date := NVL(p_Dim_Grp_Rec.Bsc_Last_Update_Date, SYSDATE);

  BSC_DIMENSION_GROUPS_PVT.Translate_Dimension_Group
    ( p_commit => p_Commit
     ,p_Dim_Grp_Rec => l_Dim_Grp_Rec
     ,x_return_status => x_return_status
     ,x_msg_count => x_msg_count
     ,x_msg_data => x_msg_data
    );

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
      x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.Translate_Dimension_Group ';
    ELSE
      x_msg_data      := 'BSC_DIMENSION_GROUPS_PUB.Translate_Dimension_Group '||SQLERRM;
    END IF;
END Translate_Dimension_Group;

--====================================================================

/*
 * Recursive function used to get unique name when
 * called from PMF for "All" enhancement.
 */
PROCEDURE get_unique_dim_group_name(
  p_dim_group_name IN VARCHAR2
 ,p_dim_group_short_name IN VARCHAR2
 ,p_counter IN NUMBER
 ,p_is_insert IN VARCHAR2 := 'Y'
 ,x_dim_group_name OUT NOCOPY VARCHAR2
)
IS
  l_count NUMBER;
  l_counter NUMBER;
  l_dim_group_name bsc_sys_dim_groups_tl.name%TYPE;
BEGIN
  l_dim_group_name := p_dim_group_name;
  l_counter := p_counter + 1;

  IF (p_is_insert = 'Y') THEN
    SELECT count(dim_group_id)
    INTO l_count
    FROM bsc_sys_dim_groups_vl
    WHERE
    UPPER(name) = UPPER(p_dim_group_name);
  ELSE -- for update
    SELECT count(dim_group_id)
    INTO l_count
    FROM bsc_sys_dim_groups_vl
    WHERE
    UPPER(name) = UPPER(p_dim_group_name)
    AND
    UPPER(short_name) <> UPPER(p_dim_group_short_name);
  END IF;
  IF (l_count = 0) THEN
    x_dim_group_name := l_dim_group_name;
  ELSE
    get_unique_dim_group_name(
      p_dim_group_name => p_dim_group_name || ' (' || TO_CHAR(l_counter) || ')'
     ,p_dim_group_short_name => p_dim_group_short_name
     ,p_counter => l_counter
     ,p_is_insert => p_is_insert
     ,x_dim_group_name => x_dim_group_name
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_dim_group_name := l_dim_group_name;
END;

--====================================================================
/* This API is used only by PMF as of now for "All" enhancement
 * where the bisdimlv.ldt is uploaded to BSC data model.
 */

 PROCEDURE load_dimension_group (
    p_commit              IN          VARCHAR2 := FND_API.G_FALSE
   ,p_Dim_Grp_Rec         IN          BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2
   ,p_force_mode          IN BOOLEAN := FALSE
 )
 IS
  l_Bsc_Dim_Group_Rec BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
  l_is_insert VARCHAR2(10) := 'Y';
  l_count NUMBER;
  l_owner_name VARCHAR2(100);
  l_ret_code BOOLEAN;
 BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Short_Name := p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name;
  l_Bsc_Dim_Group_Rec.Bsc_Created_By := p_Dim_Grp_Rec.Bsc_Created_By;
  l_Bsc_Dim_Group_Rec.Bsc_Last_Updated_By := p_Dim_Grp_Rec.Bsc_Last_Updated_By;

  SELECT count(dim_group_id)
    INTO l_count
    FROM bsc_sys_dim_groups_vl
    WHERE
    short_name = l_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Short_Name;

  IF (l_count > 0) THEN -- update
    l_is_insert := 'N';
  END IF;

  -- If the dimension group name in bsc is the same as that in pmf seeded dimensions, then use another name
  -- since name is used as a unique column in bsc_sys_dim_groups_tl. The name itself will not matter
  -- for PMF since short_name is used at all places. (bug# 3028436)

  get_unique_dim_group_name(
    p_dim_group_name => p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name
   ,p_dim_group_short_name => l_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Short_Name
   ,p_is_insert => l_is_insert
   ,p_counter => 0
   ,x_dim_group_name => l_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Name
  );


  l_Bsc_Dim_Group_Rec.Bsc_Last_Update_Date := NVL(p_Dim_Grp_Rec.Bsc_Last_Update_Date, SYSDATE);

  IF (l_is_insert = 'N') THEN

    l_owner_name := BIS_UTILITIES_PUB.Get_Owner_Name(p_Dim_Grp_Rec.Bsc_Last_Updated_By);

    BIS_UTIL.Validate_For_Update (p_last_update_date  =>  l_Bsc_Dim_Group_Rec.Bsc_Last_Update_Date
                                 ,p_owner             =>  l_owner_name
			         ,p_force_mode        =>  p_force_mode
			         ,p_table_name        =>  'BSC_SYS_DIM_GROUPS_VL'
			         ,p_key_value         =>  l_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Short_Name
			         ,x_ret_code          =>  l_ret_code
			         ,x_return_status     =>  x_return_status
			         ,x_msg_data          =>  x_msg_data
			         );
   IF (l_ret_code) THEN

     BSC_DIMENSION_GROUPS_PUB.Update_Dimension_Group(
        p_commit => FND_API.G_TRUE
       ,p_Dim_Grp_Rec => l_Bsc_Dim_Group_Rec
       ,p_create_Dim_Levels => FALSE
       ,x_return_status => x_return_status
       ,x_msg_count => x_msg_count
       ,x_msg_data => x_msg_data
     );
   END IF;
 ELSE

    BSC_DIMENSION_GROUPS_PUB.Create_Dimension_Group(
       p_commit => FND_API.G_TRUE
      ,p_Dim_Grp_Rec => l_Bsc_Dim_Group_Rec
      ,p_create_Dim_Levels => FALSE
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data
    );

  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
       p_encoded   => 'F'
      ,p_count     =>  x_msg_count
      ,p_data      =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
       p_encoded   => 'F'
      ,p_count     =>  x_msg_count
      ,p_data      =>  x_msg_data
    );
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.load_dimension_group ';
    ELSE
      x_msg_data      := 'BSC_DIMENSION_GROUPS_PUB.load_dimension_group '||SQLERRM;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.load_dimension_group ';
    ELSE
      x_msg_data      := 'BSC_DIMENSION_GROUPS_PUB.load_dimension_group '||SQLERRM;
    END IF;

 END load_dimension_group;

--====================================================================
/* This API is used only by PMF as of now for "All" enhancement
 * where the bisdimlv.ldt is uploaded to BSC data model.
 */
PROCEDURE load_dim_levels_in_group(
  p_commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Pmf_Dim_Rec     IN          BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
 ,p_Dim_Grp_Rec         IN          BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY  VARCHAR2
 ,x_msg_count           OUT NOCOPY  NUMBER
 ,x_msg_data            OUT NOCOPY  VARCHAR2
)
IS
  l_rel_count NUMBER;
  l_Bsc_Dim_Group_Rec BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Bsc_Dim_Group_Rec := p_Dim_Grp_Rec;

  SELECT dim_level_id
  INTO   l_Bsc_Dim_Group_Rec.Bsc_Level_Id
  FROM   bsc_sys_dim_levels_b
  WHERE  short_name = p_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name;

  SELECT count(a.dim_level_id)
   INTO l_rel_count
   FROM
   bsc_sys_dim_levels_b a
   , bsc_sys_dim_groups_vl b
   , bsc_sys_dim_levels_by_group c
   WHERE
   a.short_name = p_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name
   and b.short_name = l_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Short_Name
   and a.dim_level_id = c.dim_level_id
   and b.dim_group_id = c.dim_group_id;

   IF (l_rel_count = 0) THEN
     -- no values in group-level relationship table; hence insert
     Create_Dim_Levels_In_Group(
        p_commit => p_Commit
       ,p_Dim_Grp_Rec => l_Bsc_Dim_Group_Rec
       ,x_return_status => x_return_status
       ,x_msg_count => x_msg_count
       ,x_msg_data => x_msg_data
     );

   ELSE
      -- since group-level relationship is present, update
      Update_Dim_Levels_In_Group(
        p_commit => p_Commit
       ,p_Dim_Grp_Rec => l_Bsc_Dim_Group_Rec
       ,x_return_status => x_return_status
       ,x_msg_count => x_msg_count
       ,x_msg_data => x_msg_data
      );

   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
    (      p_encoded   => 'F'
       ,   p_count     =>  x_msg_count
       ,   p_data      =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
    (      p_encoded   => 'F'
       ,   p_count     =>  x_msg_count
       ,   p_data      =>  x_msg_data
    );
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.load_dim_levels_in_group ';
    ELSE
      x_msg_data      := 'BSC_DIMENSION_GROUPS_PUB.load_dim_levels_in_group '||SQLERRM;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.load_dim_levels_in_group ';
    ELSE
      x_msg_data      := 'BSC_DIMENSION_GROUPS_PUB.load_dim_levels_in_group '||SQLERRM;
    END IF;
END load_dim_levels_in_group;

--=============================================================================
PROCEDURE ret_dimgrpid_fr_shname (
   p_dim_short_name IN VARCHAR2
  ,x_dim_grp_id OUT NOCOPY VARCHAR2
  ,x_return_status OUT NOCOPY VARCHAR2
  ,x_msg_count OUT NOCOPY NUMBER
  ,x_msg_data OUT NOCOPY VARCHAR2
) IS

CURSOR c_dim_grp_id (cp_short_name VARCHAR2) IS
  SELECT dim_group_id
  FROM   bsc_sys_dim_groups_vl
  WHERE  short_name = cp_short_name;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (c_dim_grp_id%ISOPEN) THEN
    CLOSE c_dim_grp_id;
  END IF;

  OPEN c_dim_grp_id (cp_short_name => p_dim_short_name);
  FETCH c_dim_grp_id INTO x_dim_grp_id;
  CLOSE c_dim_grp_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (c_dim_grp_id%ISOPEN) THEN
      CLOSE c_dim_grp_id;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.ret_dimgrpid_fr_shname ';
    ELSE
      x_msg_data      := 'BSC_DIMENSION_GROUPS_PUB.ret_dimgrpid_fr_shname '||SQLERRM;
    END IF;
  WHEN FND_API.G_EXC_ERROR THEN
    IF (c_dim_grp_id%ISOPEN) THEN
      CLOSE c_dim_grp_id;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
       p_encoded   => 'F'
      ,p_count     =>  x_msg_count
      ,p_data      =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (c_dim_grp_id%ISOPEN) THEN
      CLOSE c_dim_grp_id;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
       p_encoded   => 'F'
      ,p_count     =>  x_msg_count
      ,p_data      =>  x_msg_data
    );
  WHEN OTHERS THEN
    IF (c_dim_grp_id%ISOPEN) THEN
      CLOSE c_dim_grp_id;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PUB.ret_dimgrpid_fr_shname ';
    ELSE
      x_msg_data      := 'BSC_DIMENSION_GROUPS_PUB.ret_dimgrpid_fr_shname '||SQLERRM;
    END IF;

END ret_dimgrpid_fr_shname;


/*************************************************************************************

    API TO SYNC UP THE DIMENSION GROUPS LANGUAGE DATA FROM PMF TO BSC

*************************************************************************************/

procedure Translate_Dim_By_Given_Lang
( p_commit          IN  VARCHAR2
, p_Dim_Grp_Rec     IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
)
IS

BEGIN
    BSC_DIMENSION_GROUPS_PVT.Translate_Dim_By_Given_Lang
    (
            p_commit                =>  FND_API.G_FALSE
        ,   p_Dim_Grp_Rec           =>  p_Dim_Grp_Rec
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
END Translate_Dim_By_Given_Lang;



end BSC_DIMENSION_GROUPS_PUB;

/
