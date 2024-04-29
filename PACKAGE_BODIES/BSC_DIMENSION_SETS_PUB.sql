--------------------------------------------------------
--  DDL for Package Body BSC_DIMENSION_SETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DIMENSION_SETS_PUB" as
/* $Header: BSCPDMSB.pls 120.0.12000000.2 2007/01/30 11:09:18 ashankar ship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPDMSB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 9, 2001                                                 |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 |          Public body version.                                                        |
 |          This package creates a Dimension Set.                                       |
 |                                                                                      |
 |                      13-MAY-2003 PWALI   Bug #2942895, SQL BIND COMPLIANCE           |
 |                      19-JUN-2003 ADRAO   Bug #3013460                                |
 |                      12-AUG-2003 PAJOHRI Bug #3083831                                |
 |                                          Modified procedure 'Create_Dim_Levels'      |
 |                      12-SEP-2003 ADRAO   Modified Create_Dim_Levels and              |
 |                                          Update_Dim_Levels for Bug# 3141813          |
 |                      19-SEP-2003 ADRAO   Added API Reorder_Dim_Level                 |
 |                      20-SEP-2003 ADRAO   Added a condition not to allow more than 1  |
 |                                          DimObj in Comparison within a DimSet.       |
 |                      20-NOV-2003 PAJOHRI Bug #3269384                                |
 |                      15-DEC-2003 ADRAO   removed Dynamic SQLs for Bug #3236356       |
 |                      12-APR-2004 PAJOHRI Bug #3426566, added conditions to filter    |
 |                                          Dimension whose Short_Name = 'UNASSIGNED'   |
 |                      07-DEC-2004 ADRAO   Added API Get_MN_Table_Name for Bug#4052221 |
 |                      30-MAR-2005 ADRAO   Relaxed the validation to check for mixed   |
 |                                          Dimension Objects within a Dimension for    |
 |                                          BSC 5.3 (Conditionally)                     |
 |                                           (BSC_NO_MIX_DIM_SET_SOURCE)                |
 |                      28-APR-2005 ADRAO   Fixed Bug#4335892                           |
 |                      03-JAN-2006 ashankar Fixed Bug#5734259                          |
 +======================================================================================+
*/


G_PKG_NAME    CONSTANT  varchar2(30) := 'BSC_DIMENSION_SETS_PUB';

/*********************************************************************************************
This function will return true if passed dimension id is valid and not equal to "UNASSIGNED"
*********************************************************************************************/
FUNCTION Is_Valid_Dimension
(  p_Dim_Group_Id  IN BSC_SYS_DIM_GROUPS_VL.Dim_Group_Id%TYPE
) RETURN BOOLEAN IS
    l_Count NUMBER := 0;
BEGIN
    SELECT COUNT(Dim_Group_ID) INTO l_Count
    FROM   BSC_SYS_DIM_GROUPS_VL
    WHERE  Dim_Group_Id  = p_Dim_Group_Id
    AND    Short_Name   <> BSC_BIS_DIMENSION_PUB.Unassigned_Dim;

    IF (l_Count <> 0) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_Valid_Dimension;


/*********************************************************************************************
This function will return the table name for a MxN type of relationship, otherwise return NULL
*********************************************************************************************/

FUNCTION Get_MN_Table_Name (
     p_Dim_Level_Id IN BSC_SYS_DIM_LEVEL_RELS.DIM_LEVEL_ID%TYPE
   , p_Parent_Dim_Level_Id IN BSC_SYS_DIM_LEVEL_RELS.PARENT_DIM_LEVEL_ID%TYPE
) RETURN VARCHAR2 IS
   l_Table_Name BSC_SYS_DIM_LEVEL_RELS.RELATION_COL%TYPE;
BEGIN
   SELECT R.RELATION_COL INTO l_Table_Name
   FROM   BSC_SYS_DIM_LEVEL_RELS R
   WHERE  R.DIM_LEVEL_ID        = p_Dim_Level_Id
   AND    R.PARENT_DIM_LEVEL_ID = p_Parent_Dim_Level_Id
   AND    R.RELATION_TYPE       = C_REL_MANY_TO_MANY;

   RETURN l_Table_Name;

EXCEPTION
  WHEN OTHERS THEN
     RETURN NULL;
END Get_MN_Table_Name;



--: This procedure is used to create dimension sets in a KPI.  This is the entry
--: point for the Dimension Sets API.
--: This procedure is part of the Dimension Set API.

procedure Create_Dim_Group_In_Dset(
  p_commit              IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,p_create_Dim_Lev_Grp  IN         BOOLEAN
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Set_Rec           BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
l_count                 NUMBER := 0;
begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  --Assign the passed record to the local record.
  l_Dim_Set_Rec := p_Dim_Set_Rec;

  --Assign certain default values if they are currently null.
  --PAJOHRI commented if condition
  /*if l_Dim_Set_Rec.Bsc_Dset_Level_Display is null then
    l_Dim_Set_Rec.Bsc_Dset_Level_Display := 0;
  end if;*/
  if l_Dim_Set_Rec.Bsc_Dset_Position is null then
    l_Dim_Set_Rec.Bsc_Dset_Position := 0;
  end if;
  if l_Dim_Set_Rec.Bsc_Dset_Total0 is null then
    l_Dim_Set_Rec.Bsc_Dset_Total0 := 0;
  end if;
  if l_Dim_Set_Rec.Bsc_Dset_User_Level0 is null then
    l_Dim_Set_Rec.Bsc_Dset_User_Level0 := 2;
  end if;
  if l_Dim_Set_Rec.Bsc_Dset_User_Level1 is null then
    l_Dim_Set_Rec.Bsc_Dset_User_Level1 := 2;
  end if;
  if l_Dim_Set_Rec.Bsc_Dset_User_Level1_Default is null then
    l_Dim_Set_Rec.Bsc_Dset_User_Level1_Default := 2;
  end if;

  --NOTE:  wrapper needs to be written to determine what next dim set is.

  -- Call private version of the procedure.
  -- PAJOHRI added if condition.
  -- if group_id is null, than don't insert into BSC_KPI_DIM_GROUPS
  IF ((l_Dim_Set_Rec.Bsc_Dim_Level_Group_Id IS NOT NULL) AND
       (BSC_DIMENSION_SETS_PUB.Is_Valid_Dimension(l_Dim_Set_Rec.Bsc_Dim_Level_Group_Id))) THEN
      BSC_DIMENSION_SETS_PVT.Create_Dim_Group_In_Dset( p_commit
                                                      ,l_Dim_Set_Rec
                                                      ,x_return_status
                                                      ,x_msg_count
                                                      ,x_msg_data);
      SELECT MAX(NUM) INTO l_count
      FROM  (SELECT   COUNT(SYS_DIM_LEL.Dim_Group_Id) NUM
                  ,   SYS_DIM_LEL.Dim_Level_Id
             FROM     BSC_KPI_DIM_GROUPS            KPI_GROUP
                  ,   BSC_SYS_DIM_LEVELS_BY_GROUP   SYS_DIM_LEL
             WHERE    KPI_GROUP.Dim_Group_Id   =    SYS_DIM_LEL.Dim_Group_Id
             AND      KPI_GROUP.Indicator      =    l_Dim_Set_Rec.Bsc_Kpi_Id
             AND      KPI_GROUP.Dim_Set_Id     =    l_Dim_Set_Rec.Bsc_Dim_Set_Id
             GROUP BY SYS_DIM_LEL.Dim_Level_Id);
     IF (l_count > 1) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_KPI_COMMON_DIM_OBJS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  -- The following calls call procedures that populate metadata for Dimension
  -- Sets in a KPI.
  IF (p_create_Dim_Lev_Grp) THEN
      Create_Bsc_Kpi_Dim_Sets_Tl( p_commit
                                 ,l_Dim_Set_Rec
                                 ,x_return_status
                                 ,x_msg_count
                                 ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  -- PAJOHRI added if condition.
  -- if group_id is null, than don't insert into BSC_KPI_DIM_GROUPS, as there
  -- will be not bsc_level_ids
      IF (l_Dim_Set_Rec.Bsc_Dim_Level_Group_Id IS NOT NULL) THEN
          Create_Dim_Level_Properties( p_commit
                                      ,l_Dim_Set_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

      END IF;
      Create_Dim_Levels( p_commit
                        ,l_Dim_Set_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      Update_Kpi_Analysis_Options_B( p_commit
                                    ,l_Dim_Set_Rec
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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Create_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Create_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Create_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Create_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Dim_Group_In_Dset;

procedure Create_Dim_Group_In_Dset(
  p_commit      IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec   IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Set_Rec     BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

begin
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    Create_Dim_Group_In_Dset(
      p_commit              => p_commit
     ,p_Dim_Set_Rec         => p_Dim_Set_Rec
     ,p_create_Dim_Lev_Grp  => TRUE
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Create_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Create_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Create_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Create_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Dim_Group_In_Dset;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Dim_Group_In_Dset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec       IN      BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec       IN OUT NOCOPY     BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Group_In_Dset( p_commit
                        ,p_Dim_Set_Rec
                        ,x_Dim_Set_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);

  Retrieve_Bsc_Kpi_Dim_Sets_Tl( p_commit
                               ,p_Dim_Set_Rec
                               ,x_Dim_Set_Rec
                               ,x_return_status
                               ,x_msg_count
                               ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  Retrieve_Dim_Level_Properties( p_commit
                                ,p_Dim_Set_Rec
                                ,x_Dim_Set_Rec
                                ,x_return_status
                                ,x_msg_count
                                ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  Retrieve_Dim_Levels( p_commit
                      ,p_Dim_Set_Rec
                      ,x_Dim_Set_Rec
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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Retrieve_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Retrieve_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Retrieve_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Retrieve_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Retrieve_Dim_Group_In_Dset;

/************************************************************************************
************************************************************************************/

procedure Update_Dim_Group_In_Dset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec         IN      BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,p_create_Dim_Lev_Grp  IN         BOOLEAN
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is
    l_count    NUMBER := 0;
begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_SETS_PVT.Update_Dim_Group_In_Dset( p_commit
                        ,p_Dim_Set_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);

  SELECT MAX(NUM) INTO l_count
  FROM  (SELECT   COUNT(SYS_DIM_LEL.Dim_Group_Id) NUM
              ,   SYS_DIM_LEL.Dim_Level_Id
         FROM     BSC_KPI_DIM_GROUPS            KPI_GROUP
              ,   BSC_SYS_DIM_LEVELS_BY_GROUP   SYS_DIM_LEL
         WHERE    KPI_GROUP.Dim_Group_Id   =    SYS_DIM_LEL.Dim_Group_Id
         AND      KPI_GROUP.Indicator      =    p_Dim_Set_Rec.Bsc_Kpi_Id
         AND      KPI_GROUP.Dim_Set_Id     =    p_Dim_Set_Rec.Bsc_Dim_Set_Id
         GROUP BY SYS_DIM_LEL.Dim_Level_Id);
  IF (l_count > 1) THEN
     FND_MESSAGE.SET_NAME('BSC','BSC_KPI_COMMON_DIM_OBJS');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF (p_create_Dim_Lev_Grp) THEN
    Update_Bsc_Kpi_Dim_Sets_Tl( p_commit
                             ,p_Dim_Set_Rec
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    Update_Dim_Level_Properties( p_commit
                              ,p_Dim_Set_Rec
                              ,x_return_status
                              ,x_msg_count
                              ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    Update_Dim_Levels( p_commit
                    ,p_Dim_Set_Rec
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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Dim_Group_In_Dset;

procedure Update_Dim_Group_In_Dset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec       IN      BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    Update_Dim_Group_In_Dset(
      p_commit              => p_commit
     ,p_Dim_Set_Rec         => p_Dim_Set_Rec
     ,p_create_Dim_Lev_Grp  => TRUE
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Dim_Group_In_Dset;

/************************************************************************************
************************************************************************************/

--: This procedure deletes dimension sets.  Since a dimension cannot be added to a
--: dimension set without its group, then we delete the entire group from the dimension
--: set irrespective of dimension.

procedure Delete_Dim_Group_In_Dset
(
        p_commit                IN          varchar2 := FND_API.G_FALSE
    ,   p_Dim_Set_Rec           IN          BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
    ,   p_create_Dim_Lev_Grp    IN          BOOLEAN
    ,   x_return_status         OUT NOCOPY  varchar2
    ,   x_msg_count             OUT NOCOPY  number
    ,   x_msg_data              OUT NOCOPY  varchar2
) is
    l_Dim_Set_Rec           BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
    l_group_id              NUMBER;
    l_level_id              NUMBER;

    CURSOR  c_group_id IS
    SELECT  dim_group_id
    FROM    BSC_KPI_DIM_GROUPS
    WHERE   indicator = p_Dim_Set_Rec.Bsc_Kpi_Id
    AND     dim_set_id = p_Dim_Set_Rec.Bsc_Dim_Set_Id;

    CURSOR  c_dim_level_id IS
    SELECT  dim_level_id
    FROM    BSC_SYS_DIM_LEVELS_BY_GROUP
    WHERE   dim_group_id = l_group_id;
begin
  -- Assign all passed values to local record.
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_Dim_Set_Rec := p_Dim_Set_Rec;
  -- PAJOHRI added if condition.
  -- if group_id is null, than don't delete from BSC_KPI_DIM_GROUPS
  IF (l_Dim_Set_Rec.Bsc_Dim_Level_Group_Id IS NULL) THEN
    FOR cd IN c_group_id LOOP
        l_group_id    :=  cd.dim_group_id;
        l_Dim_Set_Rec.Bsc_Dim_Level_Group_Id    :=  l_group_id;

        BSC_DIMENSION_SETS_PVT.Delete_Dim_Group_In_Dset( p_commit --BSC_KPI_DIM_GROUPS
                                                      ,l_Dim_Set_Rec
                                                      ,x_return_status
                                                      ,x_msg_count
                                                      ,x_msg_data);

        FOR cd IN c_dim_level_id LOOP
          l_level_id    :=  cd.dim_level_id;
          l_Dim_Set_Rec.Bsc_Level_Id   := l_level_id;
          Delete_Dim_Level_Properties( p_commit --BSC_KPI_DIM_LEVEL_PROPERTIES
                                      ,l_Dim_Set_Rec
                                      ,x_return_status
                                      ,x_msg_count
                                      ,x_msg_data);
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          Delete_Dim_Levels( p_commit --BSC_KPI_DIM_LEVELS_B
                            ,l_Dim_Set_Rec
                            ,x_return_status
                            ,x_msg_count
                            ,x_msg_data);
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END LOOP;
    END LOOP;
  ELSE
    l_group_id  :=  l_Dim_Set_Rec.Bsc_Dim_Level_Group_Id;
    BSC_DIMENSION_SETS_PVT.Delete_Dim_Group_In_Dset( p_commit    --BSC_KPI_DIM_GROUPS
                                                  ,l_Dim_Set_Rec
                                                  ,x_return_status
                                                  ,x_msg_count
                                                  ,x_msg_data);
    FOR cd IN c_dim_level_id LOOP
        l_level_id    :=  cd.dim_level_id;
        l_Dim_Set_Rec.Bsc_Level_Id   := l_level_id;
        Delete_Dim_Level_Properties( p_commit       --BSC_KPI_DIM_LEVEL_PROPERTIES
                                  ,l_Dim_Set_Rec
                                  ,x_return_status
                                  ,x_msg_count
                                  ,x_msg_data);
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        Delete_Dim_Levels( p_commit  --BSC_KPI_DIM_LEVELS_B
                        ,l_Dim_Set_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
  END IF;
  IF (p_create_Dim_Lev_Grp) THEN
      l_Dim_Set_Rec.Bsc_Action := 'RESET';
      l_Dim_Set_Rec.Bsc_Dim_Level_Group_Id    :=  l_group_id;

      Update_Kpi_Analysis_Options_B( p_commit
                                    ,l_Dim_Set_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
      -- Call this procedure last. This procedure will delete the entire dimension set.
      Delete_Bsc_Kpi_Dim_Sets_Tl( p_commit -- delete from BSC_KPI_DIM_SETS_TL
                                 ,l_Dim_Set_Rec
                                 ,x_return_status
                                 ,x_msg_count
                                 ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
      l_Dim_Set_Rec.Bsc_Dim_Level_Group_Id  := NULL;
      l_Dim_Set_Rec.Bsc_Level_Id            := NULL;
      Delete_Dim_Levels( p_commit
                        ,l_Dim_Set_Rec
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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Delete_Dim_Group_In_Dset;


procedure Delete_Dim_Group_In_Dset(
  p_commit      IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec   IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Set_Rec     BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

begin
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    Delete_Dim_Group_In_Dset(
      p_commit              => p_commit
     ,p_Dim_Set_Rec         => p_Dim_Set_Rec
     ,p_create_Dim_Lev_Grp  => TRUE
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Delete_Dim_Group_In_Dset;

/************************************************************************************
************************************************************************************/

--: This procedure creates the dimension set id and name for the KPI.
--: This procedure belongs to the Dimension Set API.

procedure Create_Bsc_Kpi_Dim_Sets_Tl(
  p_commit    IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec   IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_SETS_PVT.Create_Bsc_Kpi_Dim_Sets_Tl( p_commit
                                                    ,p_Dim_Set_Rec
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);

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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Create_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Create_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Create_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Create_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Bsc_Kpi_Dim_Sets_Tl;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Bsc_Kpi_Dim_Sets_Tl(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec       IN      BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec       IN OUT NOCOPY     BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_SETS_PVT.Retrieve_Bsc_Kpi_Dim_Sets_Tl( p_commit
                                                      ,p_Dim_Set_Rec
                                                      ,x_Dim_Set_Rec
                                                      ,x_return_status
                                                      ,x_msg_count
                                                      ,x_msg_data);
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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Retrieve_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Retrieve_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Retrieve_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Retrieve_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Retrieve_Bsc_Kpi_Dim_Sets_Tl;

/************************************************************************************
************************************************************************************/

procedure Update_Bsc_Kpi_Dim_Sets_Tl(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec       IN      BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_SETS_PVT.Update_Bsc_Kpi_Dim_Sets_Tl( p_commit
                                                    ,p_Dim_Set_Rec
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);

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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Update_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Update_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Update_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Update_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Bsc_Kpi_Dim_Sets_Tl;

/************************************************************************************
************************************************************************************/

procedure Delete_Bsc_Kpi_Dim_Sets_Tl(
  p_commit      IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec   IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count       number;

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_SETS_PVT.Delete_Bsc_Kpi_Dim_Sets_Tl( p_commit
                                                    ,p_Dim_Set_Rec
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);

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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Delete_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Delete_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Delete_Bsc_Kpi_Dim_Sets_Tl ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Delete_Bsc_Kpi_Dim_Sets_Tl ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Delete_Bsc_Kpi_Dim_Sets_Tl;

/************************************************************************************
************************************************************************************/

--: This procedure creates the properties for the dimension set for the KPI.
--: This procedure belongs to the Dimension Set API.

procedure Create_Dim_Level_Properties(
  p_commit      IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec   IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

-- Define a Table Record.
l_Dim_Set_Rec     BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Tbl_Type;

l_cnt                           number;

CURSOR c_Dim_Level_Id IS
SELECT DISTINCT DIM_LEVEL_ID
FROM   BSC_SYS_DIM_LEVELS_BY_GROUP
WHERE  DIM_GROUP_ID = p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id;

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  IF (BSC_DIMENSION_SETS_PUB.Is_Valid_Dimension(p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id)) THEN
      -- Set the first values of the Table Record equal to the Record passed.
      l_Dim_Set_Rec(1).Bsc_Kpi_Id                   := p_Dim_Set_Rec.Bsc_Kpi_Id;
      l_Dim_Set_Rec(1).Bsc_Dim_Set_Id               := p_Dim_Set_Rec.Bsc_Dim_Set_Id;
      l_Dim_Set_Rec(1).Bsc_Dim_Set_Name             := p_Dim_Set_Rec.Bsc_Dim_Set_Name;
      l_Dim_Set_Rec(1).Bsc_Dim_Level_Group_Id       := p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id;
      l_Dim_Set_Rec(1).Bsc_Dset_Position            := p_Dim_Set_Rec.Bsc_Dset_Position;
      l_Dim_Set_Rec(1).Bsc_Dset_Total0              := p_Dim_Set_Rec.Bsc_Dset_Total0;
      l_Dim_Set_Rec(1).Bsc_Dset_Level_Display       := p_Dim_Set_Rec.Bsc_Dset_Level_Display;
      l_Dim_Set_Rec(1).Bsc_Dset_Default_Key_Value   := p_Dim_Set_Rec.Bsc_Dset_Default_Key_Value;
      l_Dim_Set_Rec(1).Bsc_Dset_User_Level0         := p_Dim_Set_Rec.Bsc_Dset_User_Level0;
      l_Dim_Set_Rec(1).Bsc_Dset_User_Level1         := p_Dim_Set_Rec.Bsc_Dset_User_Level1;
      l_Dim_Set_Rec(1).Bsc_Dset_User_Level1_Default := p_Dim_Set_Rec.Bsc_Dset_User_Level1_Default;
      l_Dim_Set_Rec(1).Bsc_Dset_User_Level2         := p_Dim_Set_Rec.Bsc_Dset_User_Level2;
      l_Dim_Set_Rec(1).Bsc_Dset_User_Level2_Default := p_Dim_Set_Rec.Bsc_Dset_User_Level2_Default;
      l_Dim_Set_Rec(1).Bsc_Action                   := p_Dim_Set_Rec.Bsc_Action;
      l_Dim_Set_Rec(1).Bsc_Language                 := p_Dim_Set_Rec.Bsc_Language;
      l_Dim_Set_Rec(1).Bsc_Source_Language          := p_Dim_Set_Rec.Bsc_Source_Language;
      l_Dim_Set_Rec(1).Bsc_Dset_Target_Level        := p_Dim_Set_Rec.Bsc_Dset_Target_Level;

      -- Create query to fetch all dimension level ids for this dimension group.
      -- Run and fetch values from above query.

      -- Bug #3236356
      l_cnt := 0;

      FOR cr IN c_Dim_Level_Id LOOP
         l_Dim_Set_Rec(l_cnt + 1).Bsc_Level_Id := cr.Dim_Level_Id;
         l_cnt := l_cnt + 1;
      END LOOP;

      -- For the number of values in the Record Table call the private version of the
      -- procedure.
      -- Also set all values except Bsc_Dim_Level_Id equal to the first value in the same
      -- Record Table.
      for i in 1..l_Dim_Set_Rec.count loop

        if i <> 1 then
          l_Dim_Set_Rec(i).Bsc_Kpi_Id                   := l_Dim_Set_Rec(1).Bsc_Kpi_Id;
          l_Dim_Set_Rec(i).Bsc_Dim_Set_Id               := l_Dim_Set_Rec(1).Bsc_Dim_Set_Id;
          l_Dim_Set_Rec(i).Bsc_Dim_Set_Name             := l_Dim_Set_Rec(1).Bsc_Dim_Set_Name;
          l_Dim_Set_Rec(i).Bsc_Dim_Level_Group_Id       := l_Dim_Set_Rec(1).Bsc_Dim_Level_Group_Id;
          l_Dim_Set_Rec(i).Bsc_Dset_Position            := l_Dim_Set_Rec(1).Bsc_Dset_Position;
          l_Dim_Set_Rec(i).Bsc_Dset_Total0              := l_Dim_Set_Rec(1).Bsc_Dset_Total0;
          l_Dim_Set_Rec(i).Bsc_Dset_Level_Display       := l_Dim_Set_Rec(1).Bsc_Dset_Level_Display;
          l_Dim_Set_Rec(i).Bsc_Dset_Default_Key_Value   := l_Dim_Set_Rec(1).Bsc_Dset_Default_Key_Value;
          l_Dim_Set_Rec(i).Bsc_Dset_User_Level0         := l_Dim_Set_Rec(1).Bsc_Dset_User_Level0;
          l_Dim_Set_Rec(i).Bsc_Dset_User_Level1         := l_Dim_Set_Rec(1).Bsc_Dset_User_Level1;
          l_Dim_Set_Rec(i).Bsc_Dset_User_Level1_Default := l_Dim_Set_Rec(1).Bsc_Dset_User_Level1_Default;
          l_Dim_Set_Rec(i).Bsc_Dset_User_Level2         := l_Dim_Set_Rec(1).Bsc_Dset_User_Level2;
          l_Dim_Set_Rec(i).Bsc_Dset_User_Level2_Default := l_Dim_Set_Rec(1).Bsc_Dset_User_Level2_Default;
          l_Dim_Set_Rec(i).Bsc_Action                   := l_Dim_Set_Rec(1).Bsc_Action;
          l_Dim_Set_Rec(i).Bsc_Language                 := l_Dim_Set_Rec(1).Bsc_Language;
          l_Dim_Set_Rec(i).Bsc_Source_Language          := l_Dim_Set_Rec(1).Bsc_Source_Language;
          l_Dim_Set_Rec(i).Bsc_Dset_Target_Level        := l_Dim_Set_Rec(1).Bsc_Dset_Target_Level;
        end if;

        -- Call private version of the procedure.
        BSC_DIMENSION_SETS_PVT.Create_Dim_Level_Properties( p_commit
                                                           ,l_Dim_Set_Rec(i)
                                                           ,x_return_status
                                                           ,x_msg_count
                                                           ,x_msg_data);

      end loop;
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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Create_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Create_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Create_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Create_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Dim_Level_Properties;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Dim_Level_Properties(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec       IN      BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec       IN OUT NOCOPY     BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Level_Properties( p_commit
                                                       ,p_Dim_Set_Rec
                                                       ,x_Dim_Set_Rec
                                                       ,x_return_status
                                                       ,x_msg_count
                                                       ,x_msg_data);

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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Retrieve_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Retrieve_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Retrieve_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Retrieve_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Retrieve_Dim_Level_Properties;

/************************************************************************************
************************************************************************************/

procedure Update_Dim_Level_Properties(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec       IN      BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_SETS_PVT.Update_Dim_Level_Properties( p_commit
                                                     ,p_Dim_Set_Rec
                                                     ,x_return_status
                                                     ,x_msg_count
                                                     ,x_msg_data);

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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Update_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Update_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Update_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Update_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Dim_Level_Properties;

/************************************************************************************
************************************************************************************/

procedure Delete_Dim_Level_Properties(
  p_commit        IN          varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec   IN          BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status   OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
) is

--Define a Table Record.
l_Dim_Set_Rec     BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Tbl_Type;

TYPE Recdc_value      IS REF CURSOR;
dc_value        Recdc_value;

l_count           number;

l_sql         varchar2(1000);

CURSOR c_Dim_Level_Id is
SELECT DISTINCT DIM_LEVEL_ID
FROM   BSC_SYS_DIM_LEVELS_BY_GROUP
WHERE  DIM_GROUP_ID = p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id;

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  -- Set the first values of the Table Record equal to the Record passed.
  l_Dim_Set_Rec(1).Bsc_Kpi_Id               := p_Dim_Set_Rec.Bsc_Kpi_Id;
  l_Dim_Set_Rec(1).Bsc_Dim_Set_Id           := p_Dim_Set_Rec.Bsc_Dim_Set_Id;
  l_Dim_Set_Rec(1).Bsc_Dim_Set_Name         := p_Dim_Set_Rec.Bsc_Dim_Set_Name;
  l_Dim_Set_Rec(1).Bsc_Dim_Level_Group_Id   := p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id;
  l_Dim_Set_Rec(1).Bsc_Action               := p_Dim_Set_Rec.Bsc_Action;
  l_Dim_Set_Rec(1).Bsc_Language             := p_Dim_Set_Rec.Bsc_Language;
  l_Dim_Set_Rec(1).Bsc_Source_Language := p_Dim_Set_Rec.Bsc_Source_Language;

  -- Create query to fetch all dimension level ids for this dimension group.

  -- Bug #3236356

  l_count := 0;
  FOR cr IN c_Dim_Level_Id LOOP
       l_Dim_Set_Rec(l_count + 1).Bsc_Level_Id := cr.Dim_Level_Id;
       l_count := l_count + 1;
  END LOOP;

  -- For the number of values in the Record Table call the private version of the
  -- procedure.
  -- Also set all values except Bsc_Dim_Level_Id equal to the first value in the same
  -- Record Table.
  for i in 1..l_Dim_Set_Rec.count loop

    if i <> 1 then
      l_Dim_Set_Rec(i).Bsc_Kpi_Id := l_Dim_Set_Rec(1).Bsc_Kpi_Id;
      l_Dim_Set_Rec(i).Bsc_Dim_Set_Id := l_Dim_Set_Rec(1).Bsc_Dim_Set_Id;
      l_Dim_Set_Rec(i).Bsc_Dim_Set_Name := l_Dim_Set_Rec(1).Bsc_Dim_Set_Name;
      l_Dim_Set_Rec(i).Bsc_Dim_Level_Group_Id := l_Dim_Set_Rec(1).Bsc_Dim_Level_Group_Id;
      l_Dim_Set_Rec(i).Bsc_Action := l_Dim_Set_Rec(1).Bsc_Action;
      l_Dim_Set_Rec(i).Bsc_Language := l_Dim_Set_Rec(1).Bsc_Language;
      l_Dim_Set_Rec(i).Bsc_Source_Language := l_Dim_Set_Rec(1).Bsc_Source_Language;
    end if;

    -- Call private version of the procedure.
    BSC_DIMENSION_SETS_PVT.Delete_Dim_Level_Properties( p_commit
                                                       ,l_Dim_Set_Rec(i)
                                                       ,x_return_status
                                                       ,x_msg_count
                                                       ,x_msg_data);

  end loop;


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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Delete_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Delete_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Delete_Dim_Level_Properties ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Delete_Dim_Level_Properties ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Delete_Dim_Level_Properties;


/************************************************************************************
************************************************************************************/

--: This procedure reorders the dimension ids to the dimension set.

PROCEDURE Reorder_Dim_Levels
(
        p_commit            IN           VARCHAR2 := FND_API.G_FALSE
    ,   p_Dim_Set_Rec       IN           BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
    ,   x_return_status     OUT NOCOPY   VARCHAR2
    ,   x_msg_count         OUT NOCOPY   NUMBER
    ,   x_msg_data          OUT NOCOPY   VARCHAR2
) IS

  l_count         NUMBER := 0;

  CURSOR set_correct_index IS
  SELECT DIM_LEVEL_INDEX,
         PARENT_LEVEL_INDEX,
         PARENT_LEVEL_INDEX2
  FROM   BSC_KPI_DIM_LEVELS_VL
  WHERE  Indicator            =   p_Dim_Set_Rec.Bsc_Kpi_Id
  AND    Dim_Set_Id           =   p_Dim_Set_Rec.Bsc_Dim_Set_Id
  ORDER  BY DIM_LEVEL_INDEX;

BEGIN
    SAVEPOINT ReorderBSCDimLevsPUB;

    l_count := 0;
    FOR cd IN set_correct_index LOOP
           UPDATE  BSC_KPI_DIM_LEVELS_B
           SET     Parent_Level_Index  =  l_count
           WHERE   Indicator           =  p_Dim_Set_Rec.Bsc_Kpi_Id
           AND     Dim_Set_Id          =  p_Dim_Set_Rec.Bsc_Dim_Set_Id
           AND     Parent_Level_Index  =  cd.Dim_Level_Index;


           UPDATE  BSC_KPI_DIM_LEVELS_B
           SET     Parent_Level_Index2  =  l_count
           WHERE   Indicator            =  p_Dim_Set_Rec.Bsc_Kpi_Id
           AND     Dim_Set_Id           =  p_Dim_Set_Rec.Bsc_Dim_Set_Id
           AND     Parent_Level_Index2  =  cd.Dim_Level_Index;

           UPDATE  BSC_KPI_DIM_LEVELS_TL
           SET     Dim_Level_Index      =  l_count
           WHERE   Indicator            =  p_Dim_Set_Rec.Bsc_Kpi_Id
           AND     Dim_Set_Id           =  p_Dim_Set_Rec.Bsc_Dim_Set_Id
           AND     Dim_Level_Index      =  cd.Dim_Level_Index;

           UPDATE  BSC_KPI_DIM_LEVELS_B
           SET     Dim_Level_Index      =  l_count
           WHERE   Indicator            =  p_Dim_Set_Rec.Bsc_Kpi_Id
           AND     Dim_Set_Id           =  p_Dim_Set_Rec.Bsc_Dim_Set_Id
           AND     Dim_Level_Index      =  cd.Dim_Level_Index;

           l_count := l_count + 1;

   END LOOP;

   IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
   END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO ReorderBSCDimLevsPUB;
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
        ROLLBACK TO ReorderBSCDimLevsPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO ReorderBSCDimLevsPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Reorder_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Reorder_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO ReorderBSCDimLevsPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Reorder_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Reorder_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Reorder_Dim_Levels;

/************************************************************************************
************************************************************************************/

--: This procedure assigns the dimension ids to the dimension set.
--: This procedure is part of the Dimension Set API.



PROCEDURE Create_Dim_Levels
(       p_commit            IN           VARCHAR2 := FND_API.G_FALSE
    ,   p_Dim_Set_Rec       IN           BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
    ,   x_return_status     OUT NOCOPY   VARCHAR2
    ,   x_msg_count         OUT NOCOPY   NUMBER
    ,   x_msg_data          OUT NOCOPY   VARCHAR2
) IS
    l_Dim_Set_Rec           BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
    l_Update_Dim_Set_Rec    BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

    l_index_cnt             NUMBER := 0;
    l_count                 NUMBER;

    CURSOR    c_dim_levels IS
    SELECT    A.Dim_Level_Id
           ,  B.Level_Table_Name
           ,  B.Level_Pk_Col
           ,  B.Name
           ,  B.Help
           ,  B.Total_Disp_Name
           ,  B.Comp_Disp_Name
           ,  B.Level_View_Name
           ,  B.Value_Order_By
           ,  B.Comp_Order_By
           ,  A.Filter_Column
           ,  A.Filter_Value
           ,  A.Default_Value
           ,  A.Default_Type
           ,  A.Parent_In_Total
           ,  A.No_Items
           ,  A.Total_Flag
           ,  A.Comparison_Flag
           ,  B.Source
    FROM      BSC_SYS_DIM_LEVELS_BY_GROUP  A
           ,  BSC_SYS_DIM_LEVELS_VL        B
           ,  BSC_SYS_DIM_GROUPS_VL        C
    WHERE     A.Dim_Group_Id               =  p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id
    AND       C.Dim_Group_Id               =  A.Dim_Group_Id
    AND       C.Short_Name                <>  BSC_BIS_DIMENSION_PUB.Unassigned_Dim
    AND       A.Dim_Level_Id               =  B.Dim_Level_Id
    ORDER  BY A.Dim_Level_Index;

    CURSOR    c_kpi_dim_set_relations IS
    SELECT    E.Dim_Level_Id
           ,  E.Parent_Dim_Level_ID
           ,  A.Dim_Level_Index         Dim_Level_Index
           ,  B.Dim_Level_Index         Par_Dim_Level_Index
           ,  C.Abbreviation            Abbreviation
           ,  D.Abbreviation            Parent_Abbreviation
           ,  E.Relation_Type
           ,  D.Level_Pk_Col
           ,  C.Level_Table_Name
           ,  C.Source
    FROM      BSC_KPI_DIM_LEVELS_B    A -- current
           ,  BSC_KPI_DIM_LEVELS_B    B -- parent
           ,  BSC_SYS_DIM_LEVELS_B    C -- current
           ,  BSC_SYS_DIM_LEVELS_B    D -- parent
           ,  BSC_SYS_DIM_LEVEL_RELS  E
    WHERE     A.Indicator             =  p_Dim_Set_Rec.Bsc_Kpi_Id
    AND       A.Dim_Set_Id            =  p_Dim_Set_Rec.Bsc_Dim_Set_Id
    AND       A.Indicator             =  B.Indicator
    AND       A.Dim_Set_Id            =  B.Dim_Set_Id
    AND       A.Level_Table_Name      =  C.Level_Table_Name
    AND       B.Level_Table_Name      =  D.Level_Table_Name
    AND       E.Dim_Level_Id          =  C.Dim_Level_Id
    AND       E.Parent_Dim_Level_Id   =  D.Dim_Level_Id
    AND       C.Source                = 'BSC'
    ORDER BY  B.Dim_Level_Index;

    CURSOR    c_pmf_dim_set_relations IS
    SELECT    E.Dim_Level_Id
           ,  E.Parent_Dim_Level_ID
           ,  A.Dim_Level_Index         Dim_Level_Index
           ,  B.Dim_Level_Index         Par_Dim_Level_Index
           ,  C.Abbreviation            Abbreviation
           ,  D.Abbreviation            Parent_Abbreviation
           ,  E.Relation_Type
           ,  D.Level_Pk_Col
           ,  C.Level_Table_Name
           ,  C.Source
    FROM      BSC_KPI_DIM_LEVELS_B    A -- current
           ,  BSC_KPI_DIM_LEVELS_B    B -- parent
           ,  BSC_SYS_DIM_LEVELS_B    C -- current
           ,  BSC_SYS_DIM_LEVELS_B    D -- parent
           ,  BSC_SYS_DIM_LEVEL_RELS  E
    WHERE     A.Indicator             =  p_Dim_Set_Rec.Bsc_Kpi_Id
    AND       A.Dim_Set_Id            =  p_Dim_Set_Rec.Bsc_Dim_Set_Id
    AND       A.Indicator             =  B.Indicator
    AND       A.Dim_Set_Id            =  B.Dim_Set_Id
    AND       A.Level_Table_Name      =  C.Level_Table_Name
    AND       B.Level_Table_Name      =  D.Level_Table_Name
    AND       E.Dim_Level_Id          =  C.Dim_Level_Id
    AND       E.Parent_Dim_Level_Id   =  D.Dim_Level_Id
    AND       C.Source                = 'PMF'
    ORDER BY  B.Dim_Level_Index;

BEGIN
    SAVEPOINT CreateBSCDimLevsPUB;
    FND_MSG_PUB.Initialize;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    IF (p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id IS NULL) THEN
       -- Call private version of the procedure.
       --DBMS_OUTPUT.PUT_LINE(' Step 0');

       BSC_DIMENSION_SETS_PVT.Create_Dim_Levels
       (
           p_commit          =>  p_commit
         , p_Dim_Set_Rec     =>  p_Dim_Set_Rec
         , x_return_status   =>  x_return_status
         , x_msg_count       =>  x_msg_count
         , x_msg_data        =>  x_msg_data
       );
    ELSIF (BSC_DIMENSION_SETS_PUB.Is_Valid_Dimension(p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id)) THEN
        -- Set the first values of the Table Record equal to the Record passed.
        --DBMS_OUTPUT.PUT_LINE(' Step 1');
        l_Dim_Set_Rec.Bsc_Kpi_Id                     := p_Dim_Set_Rec.Bsc_Kpi_Id;
        l_Dim_Set_Rec.Bsc_Dim_Set_Id                 := p_Dim_Set_Rec.Bsc_Dim_Set_Id;
        l_Dim_Set_Rec.Bsc_Dim_Set_Name               := p_Dim_Set_Rec.Bsc_Dim_Set_Name;
        l_Dim_Set_Rec.Bsc_Dim_Level_Group_Id         := p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id;
        l_Dim_Set_Rec.Bsc_Action                     := p_Dim_Set_Rec.Bsc_Action;
        l_Dim_Set_Rec.Bsc_Language                   := p_Dim_Set_Rec.Bsc_Language;
        l_Dim_Set_Rec.Bsc_Source_Language            := p_Dim_Set_Rec.Bsc_Source_Language;
        l_Dim_Set_Rec.Bsc_Dset_Total0                := p_Dim_Set_Rec.Bsc_Dset_Total0;
        l_Dim_Set_Rec.Bsc_Dset_Level_Display         := p_Dim_Set_Rec.Bsc_Dset_Level_Display;
        l_Dim_Set_Rec.Bsc_Dset_User_Level0           := p_Dim_Set_Rec.Bsc_Dset_User_Level0;
        l_Dim_Set_Rec.Bsc_Dset_User_Level1           := p_Dim_Set_Rec.Bsc_Dset_User_Level1;
        l_Dim_Set_Rec.Bsc_Dset_User_Level1_Default   := p_Dim_Set_Rec.Bsc_Dset_User_Level1_Default;
        l_Dim_Set_Rec.Bsc_Dset_Target_Level          := p_Dim_Set_Rec.Bsc_Dset_Target_Level;
        l_Dim_Set_Rec.Bsc_Dset_Status                := 2;
        l_Dim_Set_Rec.Bsc_Dset_Position              := 0;

        SELECT  NVL(MAX(dim_level_index)+1, 0)
        INTO    l_index_cnt
        FROM    BSC_KPI_DIM_LEVELS_B
        WHERE   Indicator  = l_Dim_Set_Rec.Bsc_Kpi_Id
        AND     Dim_Set_Id = l_Dim_Set_Rec.Bsc_Dim_Set_Id;

        FOR cd IN c_dim_levels LOOP
           l_Dim_Set_Rec.Bsc_Dset_Dim_Level_Index    := l_index_cnt+1;
           l_Dim_Set_Rec.Bsc_Level_Id                := cd.Dim_Level_Id;
           l_Dim_Set_Rec.Bsc_Level_Name              := cd.Level_Table_Name;
           l_Dim_Set_Rec.Bsc_Pk_Col                  := cd.Level_Pk_Col;
           l_Dim_Set_Rec.Bsc_Dim_Level_Long_Name     := cd.Name;
           l_Dim_Set_Rec.Bsc_Dim_Level_Help          := cd.Help;

           IF ((cd.Source = 'PMF') AND (cd.Total_Flag = 0)) THEN
              l_Dim_Set_Rec.Bsc_Dim_Tot_Disp_Name    := NULL;
           ELSIF ((cd.Total_Flag = 0) AND (cd.Comparison_Flag = -1) AND (cd.Default_Value = 'C')) THEN
              l_Dim_Set_Rec.Bsc_Dim_Tot_Disp_Name    := NULL;
           ELSE
              l_Dim_Set_Rec.Bsc_Dim_Tot_Disp_Name    := cd.Total_Disp_Name;
           END IF;

           IF ((cd.Total_Flag = -1) AND (cd.Comparison_Flag = 0) AND (cd.Default_Value = 'T')) THEN
              l_Dim_Set_Rec.Bsc_Dim_Comp_Disp_Name   := NULL;
           ELSE
              l_Dim_Set_Rec.Bsc_Dim_Comp_Disp_Name   := cd.Comp_Disp_Name;
           END IF;

           IF (cd.Source = 'BSC') THEN
               l_Dim_Set_Rec.Bsc_View_Name           := NVL(BSC_DIM_FILTERS_PUB.Get_Filter_View_Name
                                                        (l_Dim_Set_Rec.Bsc_Kpi_Id, l_Dim_Set_Rec.Bsc_Level_Id), cd.Level_View_Name);
           ELSE
               l_Dim_Set_Rec.Bsc_View_Name           := cd.Level_View_Name;
           END IF;
           l_Dim_Set_Rec.Bsc_Dset_Value_Order        := cd.Value_Order_By;
           l_Dim_Set_Rec.Bsc_Dset_Comp_Order         := cd.Comp_Order_By;
           l_Dim_Set_Rec.Bsc_Dset_Filter_Column      := cd.Filter_Column;
           l_Dim_Set_Rec.Bsc_Dset_Filter_Value       := cd.Filter_Value;
           l_Dim_Set_Rec.Bsc_Dset_Default_Value      := cd.Default_Value;
           l_Dim_Set_Rec.Bsc_Dset_Default_Type       := cd.Default_Type;
           l_Dim_Set_Rec.Bsc_Dset_Parent_In_Total    := cd.Parent_In_Total;
           l_Dim_Set_Rec.Bsc_Dset_No_Items           := cd.No_Items;
           l_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel   := NULL;
           l_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel2  := NULL;
           l_Dim_Set_Rec.Bsc_Dset_Table_Relation     := NULL;
           -- Call private version of the procedure.
           BSC_DIMENSION_SETS_PVT.Create_Dim_Levels
           (
               p_commit          =>  p_commit
             , p_Dim_Set_Rec     =>  l_Dim_Set_Rec
             , x_return_status   =>  x_return_status
             , x_msg_count       =>  x_msg_count
             , x_msg_data        =>  x_msg_data
           );
           l_index_cnt  :=  l_index_cnt + 1;
        END LOOP;
        FOR cd IN c_kpi_dim_set_relations LOOP
            SELECT COUNT(1) INTO l_Count
            FROM   BSC_KPI_DIM_LEVELS_B
            WHERE  Indicator         =  p_Dim_Set_Rec.Bsc_Kpi_Id
            AND    Dim_Set_Id        =  p_Dim_Set_Rec.Bsc_Dim_Set_Id
            AND    Dim_Level_Index   =  cd.Dim_Level_Index
            AND    Parent_Level_Index IS NULL;
            IF (l_Count <> 0) THEN
                IF (NOT ((cd.Relation_Type = 1) AND (cd.Par_Dim_Level_Index > cd.Dim_Level_Index))) THEN
                    l_Update_Dim_Set_Rec.Bsc_Kpi_Id                      :=  p_Dim_Set_Rec.Bsc_Kpi_Id;
                    l_Update_Dim_Set_Rec.Bsc_Dim_Set_Id                  :=  p_Dim_Set_Rec.Bsc_Dim_Set_Id;
                    l_Update_Dim_Set_Rec.Bsc_Dset_Dim_Level_Index        :=  cd.Dim_Level_Index;
                    l_Update_Dim_Set_Rec.Bsc_Level_Name                  :=  cd.Level_Table_Name;
                    IF (cd.Relation_Type = 1) THEN -- if relation is of type one to many
                        l_Update_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel   :=  cd.Level_Pk_Col;
                        l_Update_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index :=  cd.Par_Dim_Level_Index;
                        l_Update_Dim_Set_Rec.Bsc_Dset_Table_Relation     :=  NULL;
                    ELSIF ((cd.Relation_Type = C_REL_MANY_TO_MANY) AND (cd.Par_Dim_Level_Index < cd.Dim_Level_Index)) THEN -- if relation of type many to many.
                        l_Update_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel   :=  cd.Level_Pk_Col;
                        l_Update_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index :=  cd.Par_Dim_Level_Index;
                        l_Update_Dim_Set_Rec.Bsc_Dset_Table_Relation     :=  NULL;

                        -- added for Bug#4052221
                        l_Update_Dim_Set_Rec.Bsc_Dset_Table_Relation     :=
                                     Get_MN_Table_Name(cd.Dim_Level_ID, cd.Parent_Dim_Level_ID);

                        IF (l_Update_Dim_Set_Rec.Bsc_Dset_Table_Relation IS NULL) THEN
                            IF (cd.Abbreviation < cd.Parent_Abbreviation) THEN
                                l_Update_Dim_Set_Rec.Bsc_Dset_Table_Relation := 'BSC_D_'||cd.Abbreviation||'_'||cd.Parent_Abbreviation;
                            ELSE
                                l_Update_Dim_Set_Rec.Bsc_Dset_Table_Relation := 'BSC_D_'||cd.Parent_Abbreviation||'_'||cd.Abbreviation;
                            END IF;
                        END IF;
                    ELSE
                        l_Update_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel   :=  NULL;
                        l_Update_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index :=  NULL;
                        l_Update_Dim_Set_Rec.Bsc_Dset_Table_Relation     :=  NULL;
                    END IF;
                    BSC_DIMENSION_SETS_PUB.Update_Dim_Levels
                    (       p_commit          =>  FND_API.G_FALSE
                        ,   p_Dim_Set_Rec     =>  l_Update_Dim_Set_Rec
                        ,   x_return_status   =>  x_return_status
                        ,   x_msg_count       =>  x_msg_count
                        ,   x_msg_data        =>  x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        --DBMS_OUTPUT.PUT_LINE('BSC_DIMENSION_SETS_PUB.Update_Dim_Levels');
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
            END IF;
        END LOOP;
        ---//////////////Fix for the bug 5734259 //////////////////////
        IF (BIS_UTILITIES_PUB.Enable_Generated_Source_Report = FND_API.G_TRUE) THEN
          FOR  cd IN c_pmf_dim_set_relations LOOP
            SELECT COUNT(1) INTO l_Count
            FROM   BSC_KPI_DIM_LEVELS_B
            WHERE  Indicator         =  p_Dim_Set_Rec.Bsc_Kpi_Id
            AND    Dim_Set_Id        =  p_Dim_Set_Rec.Bsc_Dim_Set_Id
            AND    Dim_Level_Index   =  cd.Dim_Level_Index
            AND    Parent_Level_Index IS NULL;

            IF (l_Count <> 0) THEN
              IF (NOT ((cd.Relation_Type = 1) AND (cd.Par_Dim_Level_Index > cd.Dim_Level_Index))) THEN
                l_Update_Dim_Set_Rec.Bsc_Kpi_Id                  :=  p_Dim_Set_Rec.Bsc_Kpi_Id;
                l_Update_Dim_Set_Rec.Bsc_Dim_Set_Id              :=  p_Dim_Set_Rec.Bsc_Dim_Set_Id;
                l_Update_Dim_Set_Rec.Bsc_Dset_Dim_Level_Index    :=  cd.Dim_Level_Index;
                --/////////Right now PMF dim objects only support 1x1 relationship

                l_Update_Dim_Set_Rec.Bsc_Level_Name              :=  cd.Level_Table_Name;
                l_Update_Dim_Set_Rec.Bsc_Dset_Parent_Level_Rel   :=  cd.Level_Pk_Col;
                l_Update_Dim_Set_Rec.Bsc_Dset_Parent_Level_Index :=  cd.Par_Dim_Level_Index;
                l_Update_Dim_Set_Rec.Bsc_Dset_Table_Relation     :=  NULL;
                BSC_DIMENSION_SETS_PUB.Update_Dim_Levels
                (       p_commit          =>  FND_API.G_FALSE
                    ,   p_Dim_Set_Rec     =>  l_Update_Dim_Set_Rec
                    ,   x_return_status   =>  x_return_status
                    ,   x_msg_count       =>  x_msg_count
                    ,   x_msg_data        =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --DBMS_OUTPUT.PUT_LINE('BSC_DIMENSION_SETS_PUB.Update_Dim_Levels');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
              END IF;
            END IF;
          END LOOP;
        END IF;

        -- Establish relationship if the Dimension Levels are from other Groups.
        --DBMS_OUTPUT.PUT_LINE(' Step 2');

        BSC_DIMENSION_SETS_PUB.Reorder_Dim_Levels
        (       p_commit            =>  FND_API.G_FALSE
            ,   p_Dim_Set_Rec       =>  p_Dim_Set_Rec
            ,   x_return_status     =>  x_return_status
            ,   x_msg_count         =>  x_msg_count
            ,   x_msg_data          =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --DBMS_OUTPUT.PUT_LINE('BSC_DIMENSION_SETS_PUB.Reorder_Dim_Levels');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- 09/16 adrao added for bug# 3141813
        SELECT COUNT(0) INTO l_count
        FROM   BSC_KPI_DIM_LEVELS_VL
        WHERE  Indicator   =   p_Dim_Set_Rec.Bsc_Kpi_Id
        AND    Dim_Set_Id  =   p_Dim_Set_Rec.Bsc_Dim_Set_Id
        AND    Level_Source = 'BSC';
        IF (l_count > BSC_UTILITY.MAX_DIM_IN_DIM_SET) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_DIM_SET_OVERFLOW');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        --DBMS_OUTPUT.PUT_LINE(' Step 3');

        -- added to relax checking for mixed type of Dimension Objects within a Dimension
        -- for Autogenerated reports and removing the disctiction, BSC 5.3
        IF (BIS_UTILITIES_PUB.Enable_Generated_Source_Report = FND_API.G_FALSE) THEN
            SELECT COUNT(DISTINCT(Level_Source)) INTO l_count
            FROM   BSC_KPI_DIM_LEVELS_VL
            WHERE  Indicator   =   p_Dim_Set_Rec.Bsc_Kpi_Id
            AND    Dim_Set_Id  =   p_Dim_Set_Rec.Bsc_Dim_Set_Id
            AND    Level_Source IS NOT NULL;
            IF (l_count > 1) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_NO_MIX_DIM_SET_SOURCE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

        -- 09/20 adrao added for bug# 3152590
        SELECT COUNT(0) INTO l_count
        FROM   BSC_KPI_DIM_LEVELS_VL
        WHERE  Indicator     =   p_Dim_Set_Rec.Bsc_Kpi_Id
        AND    Dim_Set_Id    =   p_Dim_Set_Rec.Bsc_Dim_Set_Id
        AND    DEFAULT_VALUE = 'C'
        AND    Level_Source  = 'BSC';
        IF (l_count > 1) THEN -- not more that 1 DimObj can be in comparison within a Dimension Set.
            FND_MESSAGE.SET_NAME('BSC','BSC_D_ONE_DIM_IN_COMPARISON');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --DBMS_OUTPUT.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;

    --DBMS_OUTPUT.PUT_LINE(' Step 4');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCDimLevsPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCDimLevsPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCDimLevsPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Create_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Create_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCDimLevsPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Create_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Create_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Dim_Levels;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Dim_Levels(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec       IN      BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_Dim_Set_Rec       IN OUT NOCOPY     BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_SETS_PVT.Retrieve_Dim_Levels( p_commit
                                             ,p_Dim_Set_Rec
                                             ,x_Dim_Set_Rec
                                             ,x_return_status
                                             ,x_msg_count
                                             ,x_msg_data);

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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Retrieve_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Retrieve_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Retrieve_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Retrieve_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Retrieve_Dim_Levels;

/************************************************************************************
************************************************************************************/

procedure Update_Dim_Levels(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec       IN      BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is
    l_count     NUMBER;
begin
  FND_MSG_PUB.Initialize;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BSC_DIMENSION_SETS_PVT.Update_Dim_Levels( p_commit
                                           ,p_Dim_Set_Rec
                                           ,x_return_status
                                           ,x_msg_count
                                           ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('BSC_DIMENSION_SETS_PUB.Reorder_Dim_Levels');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  -- added to relax checking for mixed type of Dimension Objects within a Dimension
  -- for Autogenerated reports and removing the disctiction, BSC 5.3
  IF (BIS_UTILITIES_PUB.Enable_Generated_Source_Report = FND_API.G_FALSE) THEN
      SELECT COUNT(DISTINCT(Level_Source)) INTO l_count
      FROM   BSC_KPI_DIM_LEVELS_VL
      WHERE  Indicator   =   p_Dim_Set_Rec.Bsc_Kpi_Id
      AND    Dim_Set_Id  =   p_Dim_Set_Rec.Bsc_Dim_Set_Id
      AND    Level_Source IS NOT NULL;
      IF (l_count > 1) THEN
          FND_MESSAGE.SET_NAME('BSC','BSC_NO_MIX_DIM_SET_SOURCE');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;

    -- 09/16 adrao added for bug# 3141813
  SELECT COUNT(0) INTO l_count
  FROM   BSC_KPI_DIM_LEVELS_VL
  WHERE  Indicator   =   p_Dim_Set_Rec.Bsc_Kpi_Id
  AND    Dim_Set_Id  =   p_Dim_Set_Rec.Bsc_Dim_Set_Id
  AND    Level_Source = 'BSC';
  IF (l_count > BSC_UTILITY.MAX_DIM_IN_DIM_SET) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_DIM_SET_OVERFLOW');
      x_msg_data := x_msg_data || bsc_apps.get_message('BSC_DIM_SET_OVERFLOW');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  SELECT COUNT(0) INTO l_count
  FROM   BSC_KPI_DIM_LEVELS_VL
  WHERE  Indicator   =   p_Dim_Set_Rec.Bsc_Kpi_Id
  AND    Dim_Set_Id  =   p_Dim_Set_Rec.Bsc_Dim_Set_Id
  AND    DEFAULT_VALUE= 'C';
  IF (l_count > 1) THEN -- not more that 1 DimObj can be in comparison within a Dimension Set.
      FND_MESSAGE.SET_NAME('BSC','BSC_ONE_DIM_OBJ_IN_COMPARISON');  -- Need to change to a better meaning,
      x_msg_data := x_msg_data || bsc_apps.get_message('BSC_ONE_DIM_OBJ_IN_COMPARISON');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Update_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Update_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Update_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Update_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Dim_Levels;

/************************************************************************************
************************************************************************************/

procedure Delete_Dim_Levels
(
   p_commit           IN             VARCHAR2 := FND_API.G_FALSE
 , p_Dim_Set_Rec      IN             BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 , x_return_status       OUT NOCOPY  VARCHAR2
 , x_msg_count           OUT NOCOPY  NUMBER
 , x_msg_data            OUT NOCOPY  VARCHAR2
) is

-- Define a Table Record.
l_Dim_Set_Rec                   BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Tbl_Type;

CURSOR c_Delete_Dim_Level IS
SELECT DISTINCT A.DIM_LEVEL_ID
               ,B.LEVEL_TABLE_NAME
               ,B.LEVEL_PK_COL
               ,C.NAME
FROM  BSC_SYS_DIM_LEVELS_BY_GROUP  A,
      BSC_SYS_DIM_LEVELS_B         B,
      BSC_SYS_DIM_LEVELS_TL        C
WHERE A.DIM_GROUP_ID = p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id
AND   A.DIM_LEVEL_ID = B.DIM_LEVEL_ID
AND   B.DIM_LEVEL_ID = C.DIM_LEVEL_ID;

TYPE Recdc_value                IS REF CURSOR;
dc_value                        Recdc_value;

l_count               NUMBER;
l_index_count         NUMBER;

l_sql                         VARCHAR2(1000);

begin
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  IF ((p_Dim_Set_Rec.Bsc_Level_Id IS NULL) AND
    (p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id IS NOT NULL)) THEN
        -- Set the first values of the Table Record equal to the Record passed.
        l_Dim_Set_Rec(1).Bsc_Kpi_Id              := p_Dim_Set_Rec.Bsc_Kpi_Id;
        l_Dim_Set_Rec(1).Bsc_Dim_Set_Id          := p_Dim_Set_Rec.Bsc_Dim_Set_Id;
        l_Dim_Set_Rec(1).Bsc_Dim_Set_Name        := p_Dim_Set_Rec.Bsc_Dim_Set_Name;
        l_Dim_Set_Rec(1).Bsc_Dim_Level_Group_Id  := p_Dim_Set_Rec.Bsc_Dim_Level_Group_Id;
        l_Dim_Set_Rec(1).Bsc_Action              := p_Dim_Set_Rec.Bsc_Action;
        l_Dim_Set_Rec(1).Bsc_Language            := p_Dim_Set_Rec.Bsc_Language;
        l_Dim_Set_Rec(1).Bsc_Source_Language     := p_Dim_Set_Rec.Bsc_Source_Language;
        -- Create query to fetch all dimension level ids for this dimension group.

        -- Bug #3236356
        l_count := 0;

        FOR cr IN c_Delete_Dim_Level LOOP
           l_Dim_Set_Rec(l_count + 1).Bsc_Level_Id            := cr.Dim_Level_Id;
           l_Dim_Set_Rec(l_count + 1).Bsc_Level_Name          := cr.Level_Table_Name;
           l_Dim_Set_Rec(l_count + 1).Bsc_Pk_Col              := cr.Level_Pk_Col;
           l_Dim_Set_Rec(l_count + 1).Bsc_Dim_Level_Long_Name := cr.Name;
           l_Dim_Set_Rec(l_count + 1).Bsc_Dim_Level_Help      := cr.Name;

           l_count := l_count + 1;

        END LOOP;

        -- For the number of values in the Record Table call the private version of the
        -- procedure.
        -- Also set all values except the 4 set above equal to the first value in the same
        -- Record Table.
        FOR i IN 1..l_Dim_Set_Rec.COUNT LOOP

          l_Dim_Set_Rec(i).Bsc_Dset_Dim_Level_Index := l_index_count + i;
          l_Dim_Set_Rec(i).Bsc_Dset_Value_Order     := 0;
          l_Dim_Set_Rec(i).Bsc_Dset_Comp_Order      := i - 1;
          l_Dim_Set_Rec(i).Bsc_Dset_Status          := 2;
          l_Dim_Set_Rec(i).Bsc_Dset_Position        := 0;

          IF i <> 1 THEN
            l_Dim_Set_Rec(i).Bsc_Kpi_Id             := l_Dim_Set_Rec(1).Bsc_Kpi_Id;
            l_Dim_Set_Rec(i).Bsc_Dim_Set_Id         := l_Dim_Set_Rec(1).Bsc_Dim_Set_Id;
            l_Dim_Set_Rec(i).Bsc_Dim_Set_Name       := l_Dim_Set_Rec(1).Bsc_Dim_Set_Name;
            l_Dim_Set_Rec(i).Bsc_Dim_Level_Group_Id := l_Dim_Set_Rec(1).Bsc_Dim_Level_Group_Id;
            l_Dim_Set_Rec(i).Bsc_Action             := l_Dim_Set_Rec(1).Bsc_Action;
            l_Dim_Set_Rec(i).Bsc_Language           := l_Dim_Set_Rec(1).Bsc_Language;
            l_Dim_Set_Rec(i).Bsc_Source_Language    := l_Dim_Set_Rec(1).Bsc_Source_Language;
          END IF;

          -- Call private version of the procedure.
          BSC_DIMENSION_SETS_PVT.Delete_Dim_Levels( p_commit
                                                   ,l_Dim_Set_Rec(i)
                                                   ,x_return_status
                                                   ,x_msg_count
                                                   ,x_msg_data);

        END LOOP;
    ELSE
        -- Call private version of the procedure.
        BSC_DIMENSION_SETS_PVT.Delete_Dim_Levels( p_commit
                                                 ,p_Dim_Set_Rec
                                                 ,x_return_status
                                                 ,x_msg_count
                                                 ,x_msg_data);
    END IF;

    BSC_DIMENSION_SETS_PUB.Reorder_Dim_Levels( p_commit
                                              ,p_Dim_Set_Rec
                                              ,x_return_status
                                              ,x_msg_count
                                              ,x_msg_data);

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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Delete_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Delete_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Delete_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Delete_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Delete_Dim_Levels;

/************************************************************************************
************************************************************************************/

--: This procedure updates an analysis option with dimension set information.
--: This procedure is part of the Dimension Set API.

procedure Update_Kpi_Analysis_Options_B(
  p_commit      IN    varchar2 := FND_API.G_FALSE
 ,p_Dim_Set_Rec   IN  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type
 ,x_return_status       OUT NOCOPY   varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is
begin
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    BSC_DIMENSION_SETS_PVT.Update_Kpi_Analysis_Options_B( p_commit
                                                         ,p_Dim_Set_Rec
                                                         ,x_return_status
                                                         ,x_msg_count
                                                         ,x_msg_data);
  --end if;

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
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Update_Kpi_Analysis_Options_B ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Update_Kpi_Analysis_Options_B ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_SETS_PUB.Update_Kpi_Analysis_Options_B ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIMENSION_SETS_PUB.Update_Kpi_Analysis_Options_B ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Kpi_Analysis_Options_B;

/************************************************************************************
************************************************************************************/


end BSC_DIMENSION_SETS_PUB;

/
