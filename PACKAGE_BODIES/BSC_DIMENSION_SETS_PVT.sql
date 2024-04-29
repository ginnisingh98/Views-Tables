--------------------------------------------------------
--  DDL for Package Body BSC_DIMENSION_SETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DIMENSION_SETS_PVT" as
/* $Header: BSCVDMSB.pls 120.1 2005/07/21 05:31:50 ashankar noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCVDMSB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 9, 2001                                                 |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 |          Private Body Version.                                                       |
 |          This package creates Dimension Sets.                                        |
 |                                                                                      |
 | History:                                                                             |
 |                                                                                      |
 | 18-DEC-2002 ASHANKAR Bug Fix #2716498                                                |
 |                                                                                      |
 | 04-MAR-2003 PAJOHRI  MLS Bug #2721899                                                |
 |                        1. Modified Update Query for  BSC_KPI_DIM_SETS_TL,            |
 |                           BSC_KPI_DIM_LEVELS_TL, and Insert Query for                |
 |                           BSC_KPI_DIM_LEVELS_TL.                                     |
 |                        2. Changed nvl(l_Dim_Set_Rec.Bsc_Language, userenv('LANG'))   |
 |                           to userenv('LANG')                                         |
 | 18-MAR-2003 PAJOHRI  Added Condition to update l_Dim_Set_Rec.Bsc_Dim_Set_Name, only  |
 |                        when it is Not Null                                           |
 | 24-JULY-2003 ASHANKAR Fix for the bug 3060555                                        |
 | 05-SEP-2003  Adeulgao Fixed bug#3128103                                              |
 | 07-JAN-2004  PAJOHRI  Bug #3343860, modified procedure Create_Dim_Levels for when    |
 |                      there is no dimension group associated with dimension set       |
 | 25-FEB-2004  PAJOHRI  Bug #3446359, modified insertion logic for                     |
 |                       BSC_KPI_DIM_LEVELS_TL to allow NULL value if NULL values are   |
 |                       passed from the Public APIs                                    |
 |   21-JUL-2005        ashankar Bug#4314386                                            |
 +======================================================================================+
*/
G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_DIMENSION_SETS_PVT';
g_db_object                             varchar2(30) := null;

--:     This procedure is used to create dimension sets in a KPI.  This is the entry
--:     point for the Dimension Sets API.
--:     This procedure is part of the Dimension Set API.

procedure Create_Dim_Group_In_Dset(
  p_commit          IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec     IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin
  SAVEPOINT CreateBSCDimGrpInDSetPvt;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Verify value to be inserted does not exist.
  select count(*)
    into l_count
    from BSC_KPI_DIM_GROUPS
   where indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
     and dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id
     and dim_group_id = p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id;

  if l_count = 0 then

    g_db_object := 'BSC_KPI_DIM_GROUPS';

    -- Insert pertaining values into table bsc_kpi_dim_groups.
    -- Reminder:  Index value is hard coded.
    insert into BSC_KPI_DIM_GROUPS( indicator
                                   ,dim_set_id
                                   ,dim_group_id
                                   ,dim_group_index)
                            values( p_Dim_Set_Rec.Bsc_Kpi_Id
                                   ,p_Dim_Set_Rec.Bsc_Dim_Set_Id
                                   ,p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id
                                   ,p_Dim_Set_Rec.Bsc_Dim_Level_Group_Index);
    if (p_commit = FND_API.G_TRUE) then
      commit;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_DSDL_COMBO_EXISTS');
    FND_MESSAGE.SET_TOKEN('BSC_COMBO', p_Dim_Set_Rec.Bsc_Dim_Set_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCDimGrpInDSetPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCDimGrpInDSetPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCDimGrpInDSetPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Create_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Create_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCDimGrpInDSetPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Create_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Create_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Dim_Group_In_Dset;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Dim_Group_In_Dset(
  p_commit              IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN    BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec         IN OUT NOCOPY   BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  select dim_set_id
        ,dim_group_index
    into x_Dim_Set_Rec.Bsc_Dim_Set_Id
        ,x_Dim_Set_Rec.Bsc_Dim_Level_Group_Index
    from BSC_KPI_DIM_GROUPS
   where indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
     and dim_group_id = p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id
     and dim_set_id   = NVL(p_Dim_Set_Rec.Bsc_Dim_Set_Id, 0);
  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Dim_Group_In_Dset;

/************************************************************************************
************************************************************************************/

procedure Update_Dim_Group_In_Dset(
  p_commit              IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN    BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Set_Rec           BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

l_count                         number;

begin
  SAVEPOINT UpdateBSCDimGrpInDSetPvt;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check that valid kpi id entered.
  if p_Dim_Set_Rec.Bsc_Kpi_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Dim_Set_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Check that valid group id entered.
  if p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_SYS_DIM_GROUPS_TL'
                                                       ,'dim_group_id'
                                                       ,p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_ID');
      FND_MESSAGE.SET_TOKEN('BSC_GROUP_ID', p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_GROUP_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_GROUP_ID', p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Dim_Group_In_Dset( p_commit
                             ,p_Dim_Set_Rec
                             ,l_Dim_Set_Rec
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);

  -- update LOCAL language ,source language, group id and level Id values with PASSED values.
  l_Dim_Set_Rec.Bsc_Language := p_Dim_Set_Rec.Bsc_Language;
  l_Dim_Set_Rec.Bsc_Source_Language := p_Dim_Set_Rec.Bsc_Source_Language;
  l_Dim_Set_Rec.Bsc_Dim_Level_Group_Id := p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id;
  l_Dim_Set_Rec.Bsc_Kpi_Id := p_Dim_Set_Rec.Bsc_Kpi_Id;

  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Dim_Set_Rec.Bsc_Dim_Set_Id is not null then
    l_Dim_Set_Rec.Bsc_Dim_Set_Id := p_Dim_Set_Rec.Bsc_Dim_Set_Id;
  end if;
  if p_Dim_Set_Rec.Bsc_Dim_Level_Group_Index is not null then
    l_Dim_Set_Rec.Bsc_Dim_Level_Group_Index := p_Dim_Set_Rec.Bsc_Dim_Level_Group_Index;
  end if;

  update BSC_KPI_DIM_GROUPS
     set dim_group_index = l_Dim_Set_Rec.Bsc_Dim_Level_Group_Index
   where indicator = l_Dim_Set_Rec.Bsc_Kpi_Id
     and dim_group_id = l_Dim_Set_Rec.Bsc_Dim_Level_Group_Id
     and dim_set_id   = l_Dim_Set_Rec.Bsc_Dim_Set_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateBSCDimGrpInDSetPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateBSCDimGrpInDSetPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateBSCDimGrpInDSetPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Update_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Update_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateBSCDimGrpInDSetPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Update_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Update_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Dim_Group_In_Dset;

/************************************************************************************
************************************************************************************/

procedure Delete_Dim_Group_In_Dset(
  p_commit          IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec     IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin
  SAVEPOINT DeleteBSCDimGrpInDSetPvt;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check that valid kpi id entered.
  if p_Dim_Set_Rec.Bsc_Kpi_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Dim_Set_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Check that valid group id entered.
  if p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_SYS_DIM_GROUPS_TL'
                                                       ,'dim_group_id'
                                                       ,p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_ID');
      FND_MESSAGE.SET_TOKEN('BSC_GROUP_ID', p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_GROUP_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_GROUP_ID', p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  delete from BSC_KPI_DIM_GROUPS
   where indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
     and dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id
     and dim_group_id = p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteBSCDimGrpInDSetPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteBSCDimGrpInDSetPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteBSCDimGrpInDSetPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Delete_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Delete_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteBSCDimGrpInDSetPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Delete_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Delete_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Delete_Dim_Group_In_Dset;

/************************************************************************************
************************************************************************************/

--:     This procedure creates the dimension set id and name for the KPI.
--:     This procedure belongs to the Dimension Set API.

procedure Create_Bsc_Kpi_Dim_Sets_Tl(
  p_commit          IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec     IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Set_Rec                   BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

l_count             number;

begin
  SAVEPOINT CreateBSCKpiDSetTlPvt;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Dim_Set_Rec := p_Dim_Set_Rec;

  -- set l_count to zero.
  -- This will determine if the Dset for this KPI already exists.
  l_count := 0;

  -- If The dimension set Id is null then get the next available one.
  if l_Dim_Set_Rec.Bsc_Dim_Set_Id is null then
    select count(*)
      into l_Dim_Set_Rec.Bsc_Dim_Set_Id
      from BSC_KPI_DIM_SETS_TL
     where indicator = l_Dim_Set_Rec.Bsc_Kpi_Id;
  else -- Determine if the KPI already contains this dimension set id.
    select count(*)
      into l_count
      from BSC_KPI_DIM_SETS_TL
     where indicator = l_Dim_Set_Rec.Bsc_Kpi_Id
       and dim_set_id = l_Dim_Set_Rec.Bsc_Dim_Set_Id;
  end if;

  -- Following current BSC standards name the dimension set with 'Dimension set '
  -- concatenated with the dimension set id.
  -- PAJOHRI Added the if condition
  IF (l_Dim_Set_Rec.Bsc_Dim_Set_Name IS NULL) THEN
    l_Dim_Set_Rec.Bsc_Dim_Set_Name := 'Dimension set ' || l_Dim_Set_rec.Bsc_Dim_Set_Id;
  END IF;

  -- If Dim Set Id not in KPI yet then insert pertaining values, else raise error.
  if l_count = 0 then

    g_db_object := 'BSC_KPI_DIM_SETS_TL';

    -- Insert pertaining values into table bsc_kpi_dim_sets_tl.
/* Fixed bug 2787553 */
    insert into BSC_KPI_DIM_SETS_TL( indicator
                                    ,dim_set_id
                                    ,language
                                    ,source_lang
                                    ,name
                                    ,created_by             -- Added for PMD
                                    ,creation_date          -- Added for PMD
                                    ,last_updated_by        -- Added for PMD
                                    ,last_update_date       -- Added for PMD
                                    ,last_update_login      -- Added for PMD
                                    ,short_name
                                    )
                             SELECT  l_Dim_Set_Rec.Bsc_Kpi_Id
                                    ,l_Dim_Set_Rec.Bsc_Dim_Set_Id
                                    ,L.LANGUAGE_CODE
                                    ,USERENV('LANG')
                                    ,l_Dim_Set_Rec.Bsc_Dim_Set_Name
                                    ,fnd_global.USER_ID      -- Added for PMD
                                    ,sysdate                 -- Added for PMD
                                    ,fnd_global.USER_ID      -- Added for PMD
                                    ,sysdate                 -- Added for PMD
                                    ,fnd_global.LOGIN_ID     -- Added for PMD
                                    ,l_Dim_Set_Rec.Bsc_Dim_Set_Short_Name
                                  FROM  FND_LANGUAGES L
                                  WHERE L.INSTALLED_FLAG IN ('I', 'B')
                                  AND NOT EXISTS
                                  ( SELECT NULL
                                    FROM   BSC_KPI_DIM_SETS_TL T
                                    WHERE  T.indicator = l_Dim_Set_Rec.Bsc_Kpi_Id
                                      AND  T.dim_set_id = l_Dim_Set_Rec.Bsc_Dim_Set_Id
                                      AND  T.LANGUAGE     = L.LANGUAGE_CODE);
     --PAJOHRI added 23-JUL-2003
     if(l_Dim_Set_Rec.Bsc_Dim_Set_Id <> 0) then
        -- Reminder:  For now we will assume that if more than one dimension set is created
        --            then the user wants to be able to change dimension sets across
        --            Analysis options.
        update BSC_KPI_ANALYSIS_GROUPS
           set change_dim_set = 1
         where indicator = l_Dim_Set_Rec.Bsc_Kpi_Id
           and analysis_group_id = 0;
     end if;
    if (p_commit = FND_API.G_TRUE) then
      commit;
    end if;

  else
    if l_Dim_Set_Rec.Bsc_New_Dset = 'Y' then
      FND_MESSAGE.SET_NAME('BSC','BSC_DSET_KPI_EXISTS');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Dim_Set_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCKpiDSetTlPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCKpiDSetTlPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCKpiDSetTlPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Create_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Create_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCKpiDSetTlPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Create_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Create_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Bsc_Kpi_Dim_Sets_Tl;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Bsc_Kpi_Dim_Sets_Tl(
  p_commit              IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN    BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec         IN OUT NOCOPY   BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  g_db_object := 'Retrieve_Bsc_Kpi_Dim_Sets_Tl';
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- fix the bug 2716498 INCORRECT MESSAGE REGARDING DELETE MASTER KPI WHILE ATTEMPTING TO ADD KPI TO TAB
  -- added the condition  "and LANGUAGE = p_Dim_Set_Rec.Bsc_Language" because two rows were returned.


    SELECT DISTINCT  NAME
                    ,SHORT_NAME
    INTO             x_Dim_Set_Rec.Bsc_Dim_Set_Name
                    ,x_Dim_Set_Rec.Bsc_Dim_Set_Short_Name
    FROM BSC_KPI_DIM_SETS_TL
    WHERE INDICATOR = p_Dim_Set_Rec.Bsc_Kpi_Id
    AND DIM_SET_ID  = p_Dim_Set_Rec.Bsc_Dim_Set_Id
    AND LANGUAGE    = USERENV('LANG');



  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCDimLevMdPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCDimLevMdPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCDimLevMdPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Retrieve_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Retrieve_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCDimLevMdPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Retrieve_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Retrieve_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Bsc_Kpi_Dim_Sets_Tl;

/************************************************************************************
************************************************************************************/

procedure Update_Bsc_Kpi_Dim_Sets_Tl(
  p_commit              IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN    BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Set_Rec           BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

l_count             number;

begin
  SAVEPOINT UpdateBSCKpiDSetTlPvt;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check that valid KPI id was entered.
  if p_Dim_Set_Rec.Bsc_Kpi_Id is not null then

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_KPIS_B
    WHERE  INDICATOR = p_Dim_Set_Rec.Bsc_Kpi_Id;

    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    else
      select count(dim_set_id)
        into l_count
        from BSC_KPI_DIM_SETS_TL
       where indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
         and dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id;
      if l_count = 0 then
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_DSET_ID');
        FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_Dim_Set_Rec := p_Dim_Set_Rec;

  -- Added for PMD
  IF p_Dim_Set_Rec.Bsc_Last_Updated_By IS NULL THEN
     l_Dim_Set_Rec.Bsc_Last_Updated_By := fnd_global.USER_ID;
  END IF;

  IF p_Dim_Set_Rec.Bsc_Last_Update_Login IS NULL THEN
     l_Dim_Set_Rec.Bsc_Last_Update_Login := fnd_global.LOGIN_ID;
  END IF;

  IF p_Dim_Set_Rec.Bsc_Dim_Set_Short_Name IS NOT NULL THEN
     l_Dim_Set_Rec.Bsc_Dim_Set_Short_Name := p_Dim_Set_Rec.Bsc_Dim_Set_Short_Name;
  END IF;


  if l_Dim_Set_Rec.Bsc_Dim_Set_Name is not null  then
      UPDATE BSC_KPI_DIM_SETS_TL
         SET NAME = l_Dim_Set_Rec.Bsc_Dim_Set_Name
        ,SOURCE_LANG = userenv('LANG')
            , LAST_UPDATED_BY      = l_Dim_Set_Rec.Bsc_Last_Updated_By   -- Added for PMD
            , LAST_UPDATE_DATE     = SYSDATE                             -- Added for PMD
            , LAST_UPDATE_LOGIN    = l_Dim_Set_Rec.Bsc_Last_Update_Login -- Added for PMD
            , SHORT_NAME           = l_Dim_Set_Rec.Bsc_Dim_Set_Short_Name
         where indicator = l_Dim_Set_Rec.Bsc_Kpi_Id
              and dim_set_id = l_Dim_Set_Rec.Bsc_Dim_Set_Id
              and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);
  end if;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateBSCKpiDSetTlPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateBSCKpiDSetTlPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateBSCKpiDSetTlPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Update_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Update_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateBSCKpiDSetTlPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Update_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Update_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Bsc_Kpi_Dim_Sets_Tl;

/************************************************************************************
************************************************************************************/

procedure Delete_Bsc_Kpi_Dim_Sets_Tl(
  p_commit          IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec     IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin
  SAVEPOINT DeleteBSCKpiDSetTlPvt;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- If there are no groups assigned to this dimension set then delete it.
  select count(dim_group_id)
    into l_count
    from BSC_KPI_DIM_GROUPS
   where indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
     and dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id;

  if l_count = 0 then
    delete from BSC_KPI_DIM_SETS_TL
     where indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
       and dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id;

    if (p_commit = FND_API.G_TRUE) then
      commit;
    end if;

  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteBSCKpiDSetTlPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteBSCKpiDSetTlPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteBSCKpiDSetTlPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Delete_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Delete_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteBSCKpiDSetTlPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Delete_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Delete_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Delete_Bsc_Kpi_Dim_Sets_Tl;

/************************************************************************************
************************************************************************************/

--:     This procedure creates the properties for the dimension set for the KPI.
--:     This procedure belongs to the Dimension Set API.

procedure Create_Dim_Level_Properties(
  p_commit          IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec     IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin
  SAVEPOINT CreateBSCDimLevPropPvt;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Determine if the properties for this KPI, dimension set and Dimension id
  -- combination have been set.
  IF (p_Dim_Set_Rec.Bsc_Level_Id IS NOT NULL) THEN
      select count(*)
        into l_count
        from BSC_KPI_DIM_LEVEL_PROPERTIES
       where indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
         and dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id
         and dim_level_id = p_Dim_Set_Rec.Bsc_Level_Id;

      -- If properties have not been set then go ahead and set them, else raise an error.
      if l_count = 0 then

        g_db_object := 'BSC_KPI_DIM_LEVEL_PROPERTIES';

        -- Insert pertaining values into table bsc_kpi_dim_level_properties.
        -- Reminder:  Some values are hard coded, need to get the source.
        insert into BSC_KPI_DIM_LEVEL_PROPERTIES( indicator
                                                 ,dim_set_id
                                                 ,dim_level_id
                                                 ,position
                                                 ,total0
                                                 ,level_display
                                                 ,default_key_value
                                                 ,user_level0
                                                 ,user_level1
                                                 ,user_level1_default
                                                 ,user_level2
                                                 ,user_level2_default
                                                 ,target_level)
                                          values( p_Dim_Set_Rec.Bsc_Kpi_Id
                                                 ,p_Dim_Set_Rec.Bsc_Dim_Set_Id
                                                 ,p_Dim_Set_Rec.Bsc_Level_Id
                                                 ,p_Dim_Set_Rec.Bsc_Dset_Position
                                                 ,p_Dim_Set_Rec.Bsc_Dset_Total0
                                                 ,p_Dim_Set_Rec.Bsc_Dset_Level_Display
                                                 ,p_Dim_Set_Rec.Bsc_Dset_Default_Key_Value
                                                 ,p_Dim_Set_Rec.Bsc_Dset_User_Level0
                                                 ,p_Dim_Set_Rec.Bsc_Dset_User_Level1
                                                 ,p_Dim_Set_Rec.Bsc_Dset_User_Level1_Default
                                                 ,p_Dim_Set_Rec.Bsc_Dset_User_Level2
                                                 ,p_Dim_Set_Rec.Bsc_Dset_User_Level2_Default
                                                 ,p_Dim_Set_Rec.Bsc_Dset_Target_Level);
      else
        FND_MESSAGE.SET_NAME('BSC','BSC_DSDL_COMBO_EXISTS');
        FND_MESSAGE.SET_TOKEN('BSC_COMBO', p_Dim_Set_Rec.Bsc_Kpi_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    END IF;
    if (p_commit = FND_API.G_TRUE) then
      commit;
    end if;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCDimLevPropPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCDimLevPropPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCDimLevPropPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Create_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Create_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCDimLevPropPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Create_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Create_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Dim_Level_Properties;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Dim_Level_Properties(
  p_commit              IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN    BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec         IN OUT NOCOPY   BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  g_db_object := 'Retrieve_Dim_Level_Properties';
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  select distinct position
                 ,total0
                 ,level_display
                 ,default_key_value
                 ,user_level0
                 ,user_level1
                 ,user_level1_default
                 ,user_level2
                 ,user_level2_default
             into x_Dim_Set_Rec.Bsc_Dset_Position
                 ,x_Dim_Set_Rec.Bsc_Dset_Total0
                 ,x_Dim_Set_Rec.Bsc_Dset_Level_Display
                 ,x_Dim_Set_Rec.Bsc_Dset_Default_Key_Value
                 ,x_Dim_Set_Rec.Bsc_Dset_User_Level0
                 ,x_Dim_Set_Rec.Bsc_Dset_User_Level1
                 ,x_Dim_Set_Rec.Bsc_Dset_User_Level1_Default
                 ,x_Dim_Set_Rec.Bsc_Dset_User_Level2
                 ,x_Dim_Set_Rec.Bsc_Dset_User_Level2_Default
             from BSC_KPI_DIM_LEVEL_PROPERTIES
            where indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
              and dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id
              and dim_level_id = p_Dim_Set_Rec.Bsc_Level_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Dim_Level_Properties;

/************************************************************************************
************************************************************************************/

procedure Update_Dim_Level_Properties(
  p_commit              IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN    BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Set_Rec           BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

l_count             number;

begin

  SAVEPOINT UpdateBSCDimLevPropPvt;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check that valid KPI id was entered.
  if p_Dim_Set_Rec.Bsc_Kpi_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Dim_Set_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    else
      select count(dim_set_id)
        into l_count
        from BSC_KPI_DIM_SETS_TL
       where indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
         and dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id;
      if l_count = 0 then
        FND_MESSAGE.SET_NAME('BSC','BSC_DSDL_COMBO_EXISTS');
        FND_MESSAGE.SET_TOKEN('BSC_COMBO', p_Dim_Set_Rec.Bsc_Kpi_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Check that valid Level Id was entered.
  if p_Dim_Set_Rec.Bsc_Level_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_SYS_DIM_LEVELS_B'
                                                       ,'dim_level_id'
                                                       ,p_Dim_Set_Rec.Bsc_Level_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_LEVEL_ID');
      FND_MESSAGE.SET_TOKEN('BSC_LEVEL_ID', p_Dim_Set_Rec.Bsc_Level_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_LEVEL_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_LEVEL_ID', p_Dim_Set_Rec.Bsc_Level_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Dim_Level_Properties( p_commit
                                ,p_Dim_Set_Rec
                                ,l_Dim_Set_Rec
                                ,x_return_status
                                ,x_msg_count
                                ,x_msg_data);

  -- update LOCAL language ,source language, kpi id, dim set id and level Id values with PASSED values.
  l_Dim_Set_Rec.Bsc_Language := p_Dim_Set_Rec.Bsc_Language;
  l_Dim_Set_Rec.Bsc_Source_Language := p_Dim_Set_Rec.Bsc_Source_Language;
  l_Dim_Set_Rec.Bsc_Kpi_Id := p_Dim_Set_Rec.Bsc_Kpi_Id;
  l_Dim_Set_Rec.Bsc_Dim_Set_Id := p_Dim_Set_Rec.Bsc_Dim_Set_Id;
  l_Dim_Set_Rec.Bsc_Level_Id := p_Dim_Set_Rec.Bsc_Level_Id;

  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Dim_Set_Rec.Bsc_Dset_Position is not null then
    l_Dim_Set_Rec.Bsc_Dset_Position := p_Dim_Set_Rec.Bsc_Dset_Position;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Total0 is not null then
    l_Dim_Set_Rec.Bsc_Dset_Total0 := p_Dim_Set_Rec.Bsc_Dset_Total0;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Level_Display is not null then
    l_Dim_Set_Rec.Bsc_Dset_Level_Display := p_Dim_Set_Rec.Bsc_Dset_Level_Display;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Default_Key_Value is not null then
    l_Dim_Set_Rec.Bsc_Dset_Default_Key_Value := p_Dim_Set_Rec.Bsc_Dset_Default_Key_Value;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_User_Level0 is not null then
    l_Dim_Set_Rec.Bsc_Dset_User_Level0 := p_Dim_Set_Rec.Bsc_Dset_User_Level0;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_User_Level1 is not null then
    l_Dim_Set_Rec.Bsc_Dset_User_Level1 := p_Dim_Set_Rec.Bsc_Dset_User_Level1;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_User_Level1_Default is not null then
    l_Dim_Set_Rec.Bsc_Dset_User_Level1_Default := p_Dim_Set_Rec.Bsc_Dset_User_Level1_Default;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_User_Level2 is not null then
    l_Dim_Set_Rec.Bsc_Dset_User_Level2 := p_Dim_Set_Rec.Bsc_Dset_User_Level2;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_User_Level2_Default is not null then
    l_Dim_Set_Rec.Bsc_Dset_User_Level2_Default := p_Dim_Set_Rec.Bsc_Dset_User_Level2_Default;
  end if;

  update BSC_KPI_DIM_LEVEL_PROPERTIES
     set position = l_Dim_Set_Rec.Bsc_Dset_Position
        ,total0 = l_Dim_Set_Rec.Bsc_Dset_Total0
        ,level_display = l_Dim_Set_Rec.Bsc_Dset_Level_Display
        ,default_key_value = l_Dim_Set_Rec.Bsc_Dset_Default_Key_Value
        ,user_level0 = l_Dim_Set_Rec.Bsc_Dset_User_Level0
        ,user_level1 = l_Dim_Set_Rec.Bsc_Dset_User_Level1
        ,user_level1_default = l_Dim_Set_Rec.Bsc_Dset_User_Level1_Default
        ,user_level2 =l_Dim_Set_Rec.Bsc_Dset_User_Level2
        ,user_level2_default = l_Dim_Set_Rec.Bsc_Dset_User_Level2_Default
   where indicator = l_Dim_Set_Rec.Bsc_Kpi_Id
     and dim_set_id = l_Dim_Set_Rec.Bsc_Dim_Set_Id
     and dim_level_id = l_Dim_Set_Rec.Bsc_Level_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateBSCDimLevPropPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateBSCDimLevPropPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateBSCDimLevPropPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Update_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Update_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateBSCDimLevPropPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Update_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Update_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Dim_Level_Properties;

/************************************************************************************
************************************************************************************/

procedure Delete_Dim_Level_Properties(
  p_commit          IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec     IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin

  SAVEPOINT DeleteBSCDimLevPropPvt;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check that valid KPI id was entered.
  if p_Dim_Set_Rec.Bsc_Kpi_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Dim_Set_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    else
      select count(dim_set_id)
        into l_count
        from BSC_KPI_DIM_SETS_TL
       where indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
         and dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id;
      if l_count = 0 then
        FND_MESSAGE.SET_NAME('BSC','BSC_DSDL_COMBO_EXISTS');
        FND_MESSAGE.SET_TOKEN('BSC_COMBO', p_Dim_Set_Rec.Bsc_Kpi_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;


  delete from BSC_KPI_DIM_LEVEL_PROPERTIES
   where indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
     and dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id
     and dim_level_id = p_Dim_Set_Rec.Bsc_Level_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteBSCDimLevPropPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteBSCDimLevPropPvt;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteBSCDimLevPropPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Delete_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Delete_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteBSCDimLevPropPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Delete_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Delete_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Delete_Dim_Level_Properties;

/************************************************************************************
************************************************************************************/

--:     This procedure assigns the dimension ids to the dimension set.
--:     This procedure is part of the Dimension Set API.

PROCEDURE Create_Dim_Levels
(       p_commit            IN               VARCHAR2 := FND_API.G_FALSE
    ,   p_Dim_Set_Rec       IN               BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
    ,   x_return_status     OUT     NOCOPY   VARCHAR2
    ,   x_msg_count         OUT     NOCOPY   NUMBER
    ,   x_msg_data          OUT     NOCOPY   VARCHAR2
) IS

    l_count                 NUMBER;
    kpi_dim_set_exists      EXCEPTION;
    l_Dim_Set_Rec           BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

    CURSOR  c_dim_sys_levels_tl IS
    SELECT  Name
          , Help
          , Total_Disp_Name
          , Comp_Disp_Name
          , Language
          , Source_Lang
    FROM    BSC_SYS_DIM_LEVELS_TL
    WHERE   DIM_LEVEL_ID = p_Dim_Set_Rec.Bsc_Level_Id;
BEGIN
    SAVEPOINT DeleteBSCDimLevsPVT;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_Dim_Set_Rec   := p_Dim_Set_Rec;
    -- Determine if the dimension already belongs to this dimension set.
    IF (p_Dim_Set_Rec.Bsc_Level_Name IS NOT NULL) THEN
        SELECT count(*)
          INTO l_count
          FROM BSC_KPI_DIM_LEVELS_B
         WHERE indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
           AND dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id
           AND upper(level_table_name) = upper(p_Dim_Set_Rec.Bsc_Level_Name)
           AND dim_level_index = p_Dim_Set_Rec.Bsc_Dset_Dim_Level_Index - 1;

        -- If the dimension does not belong to the dimension set assign it, else
        -- raise an error.
        IF l_count = 0 THEN
            -- Insert pertaining values into table bsc_kpi_dim_levels_b.
            -- Reminder:  some values are hard coded, need to get source.
            INSERT INTO BSC_KPI_DIM_LEVELS_B( indicator
                                             ,dim_set_id
                                             ,dim_level_index
                                             ,level_table_name
                                             ,level_view_name
                                             ,filter_column
                                             ,filter_value
                                             ,default_value
                                             ,default_type
                                             ,value_order_by
                                             ,comp_order_by
                                             ,level_pk_col
                                             ,parent_level_index
                                             ,parent_level_rel
                                             ,table_relation
                                             ,parent_level_index2
                                             ,parent_level_rel2
                                             ,status
                                             ,parent_in_total
                                             ,position
                                             ,total0
                                             ,level_display
                                             ,no_items
                                             ,default_key_value
                                             ,user_level0
                                             ,user_level1
                                             ,user_level1_default
                                             ,user_level2
                                             ,user_level2_default
                                             ,target_level)
                                      VALUES( p_Dim_Set_Rec.Bsc_Kpi_Id
                                             ,p_Dim_Set_Rec.Bsc_Dim_Set_Id
                                             ,p_Dim_Set_Rec.Bsc_Dset_Dim_Level_Index - 1
                                             ,p_Dim_Set_Rec.Bsc_Level_Name
                                             ,p_Dim_Set_Rec.Bsc_View_Name
                                             ,p_Dim_Set_Rec.Bsc_Dset_Filter_Column
                                             ,p_Dim_Set_Rec.Bsc_Dset_Filter_Value
                                             ,p_Dim_Set_Rec.Bsc_Dset_Default_Value
                                             ,p_Dim_Set_Rec.Bsc_Dset_Default_Type
                                             ,p_Dim_Set_Rec.Bsc_Dset_Value_Order
                                             ,p_Dim_Set_Rec.Bsc_Dset_Comp_Order
                                             ,p_Dim_Set_Rec.Bsc_Pk_Col
                                             ,p_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index
                                             ,p_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel
                                             ,p_Dim_Set_Rec.Bsc_Dset_Table_Relation
                                             ,p_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index2
                                             ,p_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel2
                                             ,p_Dim_Set_Rec.Bsc_Dset_Status
                                             ,p_Dim_Set_Rec.Bsc_Dset_Parent_In_Total
                                             ,p_Dim_Set_Rec.Bsc_Dset_Position
                                             ,p_Dim_Set_Rec.Bsc_Dset_Total0
                                             ,p_Dim_Set_Rec.Bsc_Dset_Level_Display
                                             ,p_Dim_Set_Rec.Bsc_Dset_No_Items
                                             ,p_Dim_Set_Rec.Bsc_Dset_Default_Key_Value
                                             ,p_Dim_Set_Rec.Bsc_Dset_User_Level0
                                             ,p_Dim_Set_Rec.Bsc_Dset_User_Level1
                                             ,p_Dim_Set_Rec.Bsc_Dset_User_Level1_Default
                                             ,p_Dim_Set_Rec.Bsc_Dset_User_Level2
                                             ,p_Dim_Set_Rec.Bsc_Dset_User_Level2_Default
                                             ,p_Dim_Set_Rec.Bsc_Dset_Target_Level);
            -- Insert pertaining values into table bsc_kpi_dim_levels_tl.
            IF (p_Dim_Set_Rec.Bsc_Level_Id IS NULL) THEN
                INSERT INTO BSC_KPI_DIM_LEVELS_TL
                (       Indicator
                    ,   Dim_Set_Id
                    ,   Dim_Level_Index
                    ,   Language
                    ,   Source_Lang
                    ,   Name
                    ,   Help
                    ,   Total_Disp_Name
                    ,   Comp_Disp_Name
                )
                SELECT  p_Dim_Set_Rec.Bsc_Kpi_Id
                    ,   p_Dim_Set_Rec.Bsc_Dim_Set_Id
                    ,   p_Dim_Set_Rec.Bsc_Dset_Dim_Level_Index - 1
                    ,   L.LANGUAGE_CODE
                    ,   USERENV('LANG')
                    ,   p_Dim_Set_Rec.Bsc_Dim_Level_Long_Name
                    ,   p_Dim_Set_Rec.Bsc_Dim_Level_Help
                    ,   p_Dim_Set_Rec.Bsc_Dim_Tot_Disp_Name
                    ,   p_Dim_Set_Rec.Bsc_Dim_Comp_Disp_Name
                FROM  FND_LANGUAGES L
                WHERE L.INSTALLED_FLAG IN ('I', 'B')
                AND   NOT EXISTS
                (   SELECT NULL
                    FROM   BSC_KPI_DIM_LEVELS_TL T
                    WHERE  T.indicator     =  p_Dim_Set_Rec.Bsc_Kpi_Id
                    AND    dim_set_id      =  p_Dim_Set_Rec.Bsc_Dim_Set_Id
                    AND    dim_level_index =  p_Dim_Set_Rec.Bsc_Dset_Dim_Level_Index - 1
                    AND    T.LANGUAGE      =  L.LANGUAGE_CODE
                );
            ELSE
                FOR cd IN c_dim_sys_levels_tl LOOP
                    l_Dim_Set_Rec.Bsc_Dim_Level_Long_Name   :=  cd.Name;
                    l_Dim_Set_Rec.Bsc_Dim_Level_Help        :=  cd.Help;
                    l_Dim_Set_Rec.Bsc_Dim_Tot_Disp_Name     :=  cd.Total_Disp_Name;
                    l_Dim_Set_Rec.Bsc_Dim_Comp_Disp_Name    :=  cd.Comp_Disp_Name;
                    l_Dim_Set_Rec.Bsc_Language              :=  cd.Language;
                    l_Dim_Set_Rec.Bsc_Source_Language       :=  cd.Source_Lang;
                    INSERT INTO BSC_KPI_DIM_LEVELS_TL
                    (   indicator
                      , dim_set_id
                      , dim_level_index
                      , language
                      , source_lang
                      , name
                      , help
                      , total_disp_name
                      , comp_disp_name
                    ) VALUES
                    (   p_Dim_Set_Rec.Bsc_Kpi_Id
                      , p_Dim_Set_Rec.Bsc_Dim_Set_Id
                      , (p_Dim_Set_Rec.Bsc_Dset_Dim_Level_Index - 1)
                      , l_Dim_Set_Rec.Bsc_Language
                      , l_Dim_Set_Rec.Bsc_Source_Language
                      , l_Dim_Set_Rec.Bsc_Dim_Level_Long_Name
                      , l_Dim_Set_Rec.Bsc_Dim_Level_Help
                      , DECODE(p_Dim_Set_Rec.Bsc_Dim_Tot_Disp_Name,   NULL, NULL, l_Dim_Set_Rec.Bsc_Dim_Tot_Disp_Name)
                      , DECODE(p_Dim_Set_Rec.Bsc_Dim_Comp_Disp_Name,  NULL, NULL, l_Dim_Set_Rec.Bsc_Dim_Comp_Disp_Name)
                    );
                END LOOP;
            END IF;
        ELSE
            FND_MESSAGE.SET_NAME('BSC','BSC_DSDL_COMBO_EXISTS');
            FND_MESSAGE.SET_TOKEN('BSC_COMBO', p_Dim_Set_Rec.Bsc_Kpi_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteBSCDimLevsPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteBSCDimLevsPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteBSCDimLevsPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Create_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Create_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteBSCDimLevsPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Create_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Create_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Dim_Levels;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Dim_Levels(
  p_commit              IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN    BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec         IN OUT NOCOPY    BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   g_db_object := 'Retrieve_Dim_Levels';

  select distinct  a.indicator
                 , a.dim_set_id
                 , a.dim_level_index
                 , a.level_table_name
                 , a.level_view_name
                 , a.filter_column
                 , a.filter_value
                 , a.default_value
                 , a.default_type
                 , a.value_order_by
                 , a.comp_order_by
                 , a.level_pk_col
                 , a.parent_level_index
                 , a.parent_level_rel
                 , a.table_relation
                 , a.parent_level_index2
                 , a.parent_level_rel2
                 , a.status
                 , a.parent_in_total
                 , a.position
                 , a.total0
                 , a.level_display
                 , a.no_items
                 , a.default_key_value
                 , a.user_level0
                 , a.user_level1
                 , a.user_level1_default
                 , a.user_level2
                 , a.user_level2_default
                 , a.target_level
                 , b.name
                 , b.help
                 , b.total_disp_name
                 , b.comp_disp_name
            into   x_Dim_Set_Rec.Bsc_Kpi_Id
                 , x_Dim_Set_Rec.Bsc_Dim_Set_Id
                 , x_Dim_Set_Rec.Bsc_Dset_Dim_Level_Index
                 , x_Dim_Set_Rec.Bsc_Level_Name
                 , x_Dim_Set_Rec.Bsc_View_Name
                 , x_Dim_Set_Rec.Bsc_Dset_Filter_Column
                 , x_Dim_Set_Rec.Bsc_Dset_Filter_Value
                 , x_Dim_Set_Rec.Bsc_Dset_Default_Value
                 , x_Dim_Set_Rec.Bsc_Dset_Default_Type
                 , x_Dim_Set_Rec.Bsc_Dset_Value_Order
                 , x_Dim_Set_Rec.Bsc_Dset_Comp_Order
                 , x_Dim_Set_Rec.Bsc_Pk_Col
                 , x_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index
                 , x_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel
                 , x_Dim_Set_Rec.Bsc_Dset_Table_Relation
                 , x_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index2
                 , x_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel2
                 , x_Dim_Set_Rec.Bsc_Dset_Status
                 , x_Dim_Set_Rec.Bsc_Dset_Parent_In_Total
                 , x_Dim_Set_Rec.Bsc_Dset_Position
                 , x_Dim_Set_Rec.Bsc_Dset_Total0
                 , x_Dim_Set_Rec.Bsc_Dset_Level_Display
                 , x_Dim_Set_Rec.Bsc_Dset_No_Items
                 , x_Dim_Set_Rec.Bsc_Dset_Default_Key_Value
                 , x_Dim_Set_Rec.Bsc_Dset_User_Level0
                 , x_Dim_Set_Rec.Bsc_Dset_User_Level1
                 , x_Dim_Set_Rec.Bsc_Dset_User_Level1_Default
                 , x_Dim_Set_Rec.Bsc_Dset_User_Level2
                 , x_Dim_Set_Rec.Bsc_Dset_User_Level2_Default
                 , x_Dim_Set_Rec.Bsc_Dset_Target_Level
                 , x_Dim_Set_Rec.Bsc_Dim_Level_Long_Name
                 , x_Dim_Set_Rec.Bsc_Dim_Level_Help
                 , x_Dim_Set_Rec.Bsc_Dim_Tot_Disp_Name
                 , x_Dim_Set_Rec.Bsc_Dim_Comp_Disp_Name
             from  BSC_KPI_DIM_LEVELS_B a
                 , BSC_KPI_DIM_LEVELS_TL b
            where a.indicator         = b.indicator
              and a.dim_set_id        = b.dim_set_id
              and a.dim_level_index   = b.dim_level_index
              and a.indicator         = p_Dim_Set_Rec.Bsc_Kpi_Id
              and a.dim_set_id        = p_Dim_Set_Rec.Bsc_Dim_Set_Id
              and a.level_table_name  = p_Dim_Set_Rec.Bsc_Level_Name
              and b.language          = USERENV('LANG');
  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Dim_Levels;

/************************************************************************************
************************************************************************************/

procedure Update_Dim_Levels(
  p_commit              IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN    BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Set_Rec           BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

l_count             number;

begin

  SAVEPOINT UpdateBSCDimLevsPVT;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check that valid KPI id was entered.
  if p_Dim_Set_Rec.Bsc_Kpi_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Dim_Set_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    else
      select count(dim_set_id)
        into l_count
        from BSC_KPI_DIM_SETS_TL
       where indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
         and dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id;
      if l_count = 0 then
        FND_MESSAGE.SET_NAME('BSC','BSC_DSDL_COMBO_EXISTS');
        FND_MESSAGE.SET_TOKEN('BSC_COMBO', p_Dim_Set_Rec.Bsc_Kpi_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Check that valid Level name was entered.
  if p_Dim_Set_Rec.Bsc_Level_Name is not null then
    select count(distinct dim_level_id)
      into l_count
      from BSC_SYS_DIM_LEVELS_B
     where upper(level_table_name) = upper(p_Dim_Set_Rec.Bsc_Level_Name);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_LEVEL_NAME');
      FND_MESSAGE.SET_TOKEN('BSC_LEVEL_NAME', p_Dim_Set_Rec.Bsc_Level_Name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_LEVEL_NAME_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_LEVEL_NAME', p_Dim_Set_Rec.Bsc_Level_Name);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Dim_Levels( p_commit
                      ,p_Dim_Set_Rec
                      ,l_Dim_Set_Rec
                      ,x_return_status
                      ,x_msg_count
                      ,x_msg_data);

  -- update LOCAL language ,source language, kpi id, dim set id and level Id values with PASSED values.
  l_Dim_Set_Rec.Bsc_Language        := p_Dim_Set_Rec.Bsc_Language;
  l_Dim_Set_Rec.Bsc_Source_Language := p_Dim_Set_Rec.Bsc_Source_Language;
  l_Dim_Set_Rec.Bsc_Kpi_Id          := p_Dim_Set_Rec.Bsc_Kpi_Id;
  l_Dim_Set_Rec.Bsc_Dim_Set_Id      := p_Dim_Set_Rec.Bsc_Dim_Set_Id;
  l_Dim_Set_Rec.Bsc_Level_Name      := p_Dim_Set_Rec.Bsc_Level_Name;

  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Dim_Set_Rec.Bsc_Dset_Dim_Level_Index is not null then
    l_Dim_Set_Rec.Bsc_Dset_Dim_Level_Index := p_Dim_Set_Rec.Bsc_Dset_Dim_Level_Index;
  end if;
  if p_Dim_Set_Rec.Bsc_View_Name is not null then
    l_Dim_Set_Rec.Bsc_View_Name  := p_Dim_Set_Rec.Bsc_View_Name;
  end if;
  if p_Dim_Set_Rec.Bsc_Level_Name is not null then
    l_Dim_Set_Rec.Bsc_Level_Name := p_Dim_Set_Rec.Bsc_Level_Name;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Filter_Column is not null then
    l_Dim_Set_Rec.Bsc_Dset_Filter_Column := p_Dim_Set_Rec.Bsc_Dset_Filter_Column ;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Filter_Value is not null then
    l_Dim_Set_Rec.Bsc_Dset_Filter_Value := p_Dim_Set_Rec.Bsc_Dset_Filter_Value ;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Default_Value is not null then
    l_Dim_Set_Rec.Bsc_Dset_Default_Value := p_Dim_Set_Rec.Bsc_Dset_Default_Value;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Default_Type is not null then
    l_Dim_Set_Rec.Bsc_Dset_Default_Type := p_Dim_Set_Rec.Bsc_Dset_Default_Type;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Value_Order is not null then
    l_Dim_Set_Rec.Bsc_Dset_Value_Order := p_Dim_Set_Rec.Bsc_Dset_Value_Order;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Comp_Order is not null then
    l_Dim_Set_Rec.Bsc_Dset_Comp_Order := p_Dim_Set_Rec.Bsc_Dset_Comp_Order;
  end if;
  if p_Dim_Set_Rec.Bsc_Pk_Col is not null then
    l_Dim_Set_Rec.Bsc_Pk_Col := p_Dim_Set_Rec.Bsc_Pk_Col;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index is not null then
    l_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index := p_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel is not null then
    l_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel := p_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Table_Relation is not null then
    l_Dim_Set_Rec.Bsc_Dset_Table_Relation := p_Dim_Set_Rec.Bsc_Dset_Table_Relation;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index2 is not null then
    l_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index2 := p_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index2;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel2 is not null then
    l_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel2 := p_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel2;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Status is not null then
    l_Dim_Set_Rec.Bsc_Dset_Status := p_Dim_Set_Rec.Bsc_Dset_Status;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Parent_In_Total is not null then
    l_Dim_Set_Rec.Bsc_Dset_Parent_In_Total := p_Dim_Set_Rec.Bsc_Dset_Parent_In_Total;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Position is not null then
    l_Dim_Set_Rec.Bsc_Dset_Position := p_Dim_Set_Rec.Bsc_Dset_Position;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Total0 is not null then
    l_Dim_Set_Rec.Bsc_Dset_Total0 := p_Dim_Set_Rec.Bsc_Dset_Total0;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Level_Display is not null then
    l_Dim_Set_Rec.Bsc_Dset_Level_Display := p_Dim_Set_Rec.Bsc_Dset_Level_Display;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_No_Items is not null then
    l_Dim_Set_Rec.Bsc_Dset_No_Items := p_Dim_Set_Rec.Bsc_Dset_No_Items;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Default_Key_Value is not null then
    l_Dim_Set_Rec.Bsc_Dset_Default_Key_Value := p_Dim_Set_Rec.Bsc_Dset_Default_Key_Value;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_User_Level0 is not null then
    l_Dim_Set_Rec.Bsc_Dset_User_Level0 := p_Dim_Set_Rec.Bsc_Dset_User_Level0;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_User_Level1 is not null then
    l_Dim_Set_Rec.Bsc_Dset_User_Level1 := p_Dim_Set_Rec.Bsc_Dset_User_Level1;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_User_Level1_Default is not null then
    l_Dim_Set_Rec.Bsc_Dset_User_Level1_Default := p_Dim_Set_Rec.Bsc_Dset_User_Level1_Default;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_User_Level2 is not null then
    l_Dim_Set_Rec.Bsc_Dset_User_Level2 := p_Dim_Set_Rec.Bsc_Dset_User_Level2;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_User_Level2_Default is not null then
    l_Dim_Set_Rec.Bsc_Dset_User_Level2_Default := p_Dim_Set_Rec.Bsc_Dset_User_Level2_Default;
  end if;
  if p_Dim_Set_Rec.Bsc_Dim_Level_Long_Name is not null then
    l_Dim_Set_Rec.Bsc_Dim_Level_Long_Name := p_Dim_Set_Rec.Bsc_Dim_Level_Long_Name;
  end if;
  if p_Dim_Set_Rec.Bsc_Dim_Level_Help is not null then
    l_Dim_Set_Rec.Bsc_Dim_Level_Help := p_Dim_Set_Rec.Bsc_Dim_Level_Help;
  end if;
  if p_Dim_Set_Rec.Bsc_Dim_Tot_Disp_Name is not null then
    l_Dim_Set_Rec.Bsc_Dim_Tot_Disp_Name := p_Dim_Set_Rec.Bsc_Dim_Tot_Disp_Name;
  end if;
  if p_Dim_Set_Rec.Bsc_Dim_Comp_Disp_Name is not null then
    l_Dim_Set_Rec.Bsc_Dim_Comp_Disp_Name := p_Dim_Set_Rec.Bsc_Dim_Comp_Disp_Name;
  end if;
  if p_Dim_Set_Rec.Bsc_Dset_Target_Level is not null then
    l_Dim_Set_Rec.Bsc_Dset_Target_Level := p_Dim_Set_Rec.Bsc_Dset_Target_Level;
  end if;

  update  BSC_KPI_DIM_LEVELS_B a
     set  dim_level_index          =   l_Dim_Set_Rec.Bsc_Dset_Dim_Level_Index
        , level_view_name          =   l_Dim_Set_Rec.Bsc_View_Name
        , filter_column            =   l_Dim_Set_Rec.Bsc_Dset_Filter_Column
        , filter_value             =   l_Dim_Set_Rec.Bsc_Dset_Filter_Value
        , default_value            =   l_Dim_Set_Rec.Bsc_Dset_Default_Value
        , default_type             =   l_Dim_Set_Rec.Bsc_Dset_Default_Type
        , value_order_by           =   l_Dim_Set_Rec.Bsc_Dset_Value_Order
        , comp_order_by            =   l_Dim_Set_Rec.Bsc_Dset_Comp_Order
        , level_pk_col             =   l_Dim_Set_Rec.Bsc_Pk_Col
        , parent_level_index       =   l_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index
        , parent_level_rel         =   l_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel
        , table_relation           =   l_Dim_Set_Rec.Bsc_Dset_Table_Relation
        , parent_level_index2      =   l_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index2
        , parent_level_rel2        =   l_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel2
        , status                   =   l_Dim_Set_Rec.Bsc_Dset_Status
        , parent_in_total          =   l_Dim_Set_Rec.Bsc_Dset_Parent_In_Total
        , position                 =   l_Dim_Set_Rec.Bsc_Dset_Position
        , total0                   =   l_Dim_Set_Rec.Bsc_Dset_Total0
        , level_display            =   l_Dim_Set_Rec.Bsc_Dset_Level_Display
        , no_items                 =   l_Dim_Set_Rec.Bsc_Dset_No_Items
        , default_key_value        =   l_Dim_Set_Rec.Bsc_Dset_Default_Key_Value
        , user_level0              =   l_Dim_Set_Rec.Bsc_Dset_User_Level0
        , user_level1              =   l_Dim_Set_Rec.Bsc_Dset_User_Level1
        , user_level1_default      =   l_Dim_Set_Rec.Bsc_Dset_User_Level1_Default
        , user_level2              =   l_Dim_Set_Rec.Bsc_Dset_User_Level2
        , user_level2_default      =   l_Dim_Set_Rec.Bsc_Dset_User_Level2_Default
        , target_level             =   l_Dim_Set_Rec.Bsc_Dset_Target_Level
   where  indicator                =   l_Dim_Set_Rec.Bsc_Kpi_Id
     and  dim_set_id               =   l_Dim_Set_Rec.Bsc_Dim_Set_Id
     and  level_table_name         =   l_Dim_Set_Rec.Bsc_Level_Name;

  update  BSC_KPI_DIM_LEVELS_TL
     set  name                     =   l_Dim_Set_Rec.Bsc_Dim_Level_Long_Name
        , help                     =   l_Dim_Set_Rec.Bsc_Dim_Level_Help
        , total_disp_name          =   l_Dim_Set_Rec.Bsc_Dim_Tot_Disp_Name
        , comp_disp_name           =   l_Dim_Set_Rec.Bsc_Dim_Comp_Disp_Name
        , source_lang              =   USERENV('LANG')
   where indicator                 =   l_Dim_Set_Rec.Bsc_Kpi_Id
     and dim_set_id                =   l_Dim_Set_Rec.Bsc_Dim_Set_Id
     and dim_level_index           =   l_Dim_Set_Rec.Bsc_Dset_Dim_Level_Index
     and USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateBSCDimLevsPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateBSCDimLevsPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateBSCDimLevsPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Update_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Update_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateBSCDimLevsPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Update_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Update_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Dim_Levels;

/************************************************************************************
************************************************************************************/

procedure Delete_Dim_Levels(
  p_commit          IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec     IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

    l_count             number;
    --PAJOHRI ADDED 02-Jun-2003
    l_dim_index     NUMBER;

    CURSOR c_dim_index IS
    SELECT DIM_LEVEL_INDEX FROM BSC_KPI_DIM_LEVELS_B
    WHERE  DIM_SET_ID = p_Dim_Set_Rec.Bsc_Dim_Set_Id
    AND    INDICATOR  = p_Dim_Set_Rec.Bsc_Kpi_Id
    AND    (LEVEL_TABLE_NAME = (SELECT LEVEL_TABLE_NAME FROM BSC_SYS_DIM_LEVELS_B
    WHERE  DIM_LEVEL_ID = p_Dim_Set_Rec.Bsc_Level_Id)
    OR     LEVEL_TABLE_NAME = 'XXX')
    ORDER  BY DIM_LEVEL_INDEX DESC;
begin
  SAVEPOINT DeleteBSCDimLevsPVT;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check that valid KPI id was entered.
  if p_Dim_Set_Rec.Bsc_Kpi_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Dim_Set_Rec.Bsc_Kpi_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Dim_Set_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  FOR cd IN c_dim_index LOOP
     l_dim_index    :=  cd.Dim_Level_Index;

     DELETE
     FROM  bsc_kpi_dim_levels_b
     WHERE indicator       = p_Dim_Set_Rec.Bsc_Kpi_Id
     AND   dim_set_id      = p_Dim_Set_Rec.Bsc_Dim_Set_Id
     AND   dim_level_index = l_dim_index;

     DELETE
     FROM  bsc_kpi_dim_levels_tl
     WHERE indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
     AND   dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id
     AND   dim_level_index = l_dim_index;

     DELETE
     FROM  bsc_kpi_dim_levels_user
     WHERE indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
     AND   dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id
     AND   dim_level_index = l_dim_index;

  END LOOP;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteBSCDimLevsPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteBSCDimLevsPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteBSCDimLevsPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Delete_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Delete_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteBSCDimLevsPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Delete_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Delete_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Delete_Dim_Levels;

/************************************************************************************
************************************************************************************/

--:     This procedure updates an analysis option with dimension set information.
--:     This procedure is part of the Dimension Set API.

procedure Update_Kpi_Analysis_Options_B(
  p_commit          IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec     IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is
l_option_id NUMBER := 0;
begin
  SAVEPOINT UpdateBSCKpiAnaOptsPVT;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- If action value is 'RESET' then reset the values for dimension set 0,
  -- else update the current dimension set id.
  IF (p_Dim_Set_Rec.Bsc_Analysis_Id IS NOT NULL) THEN
    l_option_id :=  p_Dim_Set_Rec.Bsc_Analysis_Id;
  END IF;
  if upper(p_Dim_Set_Rec.Bsc_Action) = 'RESET' then

    update BSC_KPI_ANALYSIS_OPTIONS_B
       set dim_set_id = 0
     where indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
       and analysis_group_id = l_option_id
       and dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id;

       /*and option_id = p_Dim_Set_Rec.Bsc_Option_Id;*/

       /* removed this from the where clause as this is not
          needed.
          When the user deletes the dimension set
          within an indicator, we assign all the analysis
          options the defualt dimension set i.e "0" */
  else

    update BSC_KPI_ANALYSIS_OPTIONS_B
       set dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id
     where indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
       and analysis_group_id = l_option_id
       and option_id = p_Dim_Set_Rec.Bsc_Option_Id;

  end if;


  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateBSCKpiAnaOptsPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateBSCKpiAnaOptsPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateBSCKpiAnaOptsPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Update_Kpi_Analysis_Options_B ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Update_Kpi_Analysis_Options_B ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateBSCKpiAnaOptsPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PVT.Update_Kpi_Analysis_Options_B ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PVT.Update_Kpi_Analysis_Options_B ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Kpi_Analysis_Options_B;

/************************************************************************************
************************************************************************************/

end BSC_DIMENSION_SETS_PVT;

/
