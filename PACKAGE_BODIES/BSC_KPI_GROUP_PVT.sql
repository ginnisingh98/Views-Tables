--------------------------------------------------------
--  DDL for Package Body BSC_KPI_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPI_GROUP_PVT" as
/* $Header: BSCVKGPB.pls 120.0 2005/06/01 16:20:37 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCVKGPB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 22, 2001                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 |                      Private Body version.                                           |
 |                      This package Creates, Retrieves, Updates, Deletes               |
 |                      BSC Kpi Group information.                                      |
 |                                                                                      |
 | History:                                                                             |
 | 04-MAR-2003 PAJOHRI  MLS Bug #2721899                                                |
 |                        1. Modified Update Query for  BSC_TAB_IND_GROUPS_TL.          |
 |                        2. Changed nvl(<record_used>.Bsc_Language, userenv('LANG'))   |
 |                           to userenv('LANG')                                         |
 | 30-Oct-2003 ADEULGAO Fixed Bug#3208420, modified Delete_Kpi_Group to handle          |
 |                      Bsc_Tab_Id <> -1 condition.                                     |
 |                                                                                      |
 | Nov-24  wcano fix bug 3267470                                                        |
 | 08-JAN-2004 krishan fixed for the bug 3357984                                        |
 |   18-MAY-04          adrao Modified PL/SQL records and CRUD to accept SHORT_NAME     |
 +======================================================================================+


*/
G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_KPI_GROUP_PVT';
g_db_object                             varchar2(30) := null;

PROCEDURE Create_Kpi_Group(
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec   IN  BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) is

l_count             NUMBER;

BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCKPIGrpPVT;

  -- This procedure "Creates" a new Kpi Group, and also "Creates" an assignment of a KPI
  -- group to a Scorecard.
  -- If Tab id is -1 then new KPI Group, else a new assignment. If new assignment then check
  -- both tab and groups exist.
  IF p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id <> -1 THEN
    -- Check that valid Kpi group id was entered.
    IF p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id  IS NOT NULL THEN
      SELECT COUNT(1) INTO l_Count
      FROM   BSC_TAB_IND_GROUPS_B
      WHERE  IND_GROUP_ID = p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id;

      IF l_count = 0 THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KGROUP_ID');
        FND_MESSAGE.SET_TOKEN('BSC_KGROUP', p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      FND_MESSAGE.SET_NAME('BSC','BSC_NO_KGROUP_ID_ENTERED');
      FND_MESSAGE.SET_TOKEN('BSC_KGROUP', p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Check that valid Tab id was entered.
    IF p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id  IS NOT NULL THEN

      SELECT COUNT(1) INTO l_Count
      FROM   BSC_TABS_B
      WHERE  TAB_ID = p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id;

      IF l_count = 0 THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_TAB_ID');
        FND_MESSAGE.SET_TOKEN('BSC_TAB', p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      FND_MESSAGE.SET_NAME('BSC','BSC_NO_TAB_ID_ENTERED');
      FND_MESSAGE.SET_TOKEN('BSC_KGROUP', p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE -- New KPI Group to be added
    IF p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Short_Name IS NOT NULL THEN

        SELECT COUNT(1) INTO l_Count
        FROM   BSC_TAB_IND_GROUPS_B
        WHERE  SHORT_NAME = p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Short_Name;

-- Need to review if this validation is required, since we are not deleting KPI Group
-- and it can have multiple rows
--        IF l_Count <> 0 THEN
--          FND_MESSAGE.SET_NAME('BSC','BSC_UNIQUE_NAME_REQUIRED');
--          FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.GET_LOOKUP_VALUE('BSC_UI_BUILDER', 'MEASURE_SHORT_NAME'));
--          FND_MESSAGE.SET_TOKEN('NAME_VALUE', p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Short_Name );
--          FND_MSG_PUB.ADD;
--          RAISE FND_API.G_EXC_ERROR;
--        END IF;
    END IF;
  END IF;

  g_db_object := 'BSC_TAB_IND_GROUPS_B';


  INSERT INTO BSC_TAB_IND_GROUPS_B( TAB_ID
                                   ,CSF_ID
                                   ,IND_GROUP_ID
                                   ,GROUP_TYPE
                                   ,NAME_POSITION
                                   ,NAME_JUSTIFICATION
                                   ,LEFT_POSITION
                                   ,TOP_POSITION
                                   ,WIDTH
                                   ,HEIGHT
                                   ,SHORT_NAME)
                            VALUES( p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id
                                   ,p_Bsc_Kpi_Group_Rec.Bsc_Csf_Id
                                   ,p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id
                                   ,p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Type
                                   ,p_Bsc_Kpi_Group_Rec.Bsc_Name_Pos_In_Tab
                                   ,p_Bsc_Kpi_Group_Rec.Bsc_Name_Justif_In_Tab
                                   ,p_Bsc_Kpi_Group_Rec.Bsc_Left_Position_In_Tab
                                   ,p_Bsc_Kpi_Group_Rec.Bsc_Top_Position_In_Tab
                                   ,p_Bsc_Kpi_Group_Rec.Bsc_Group_Width
                                   ,p_Bsc_Kpi_Group_Rec.Bsc_Group_Height
                                   ,p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Short_Name);

  g_db_object := 'BSC_TAB_IND_GROUPS_TL';

  INSERT INTO BSC_TAB_IND_GROUPS_TL( TAB_ID
                                    ,CSF_ID
                                    ,IND_GROUP_ID
                                    ,LANGUAGE
                                    ,SOURCE_LANG
                                    ,NAME
                                    ,HELP
                                    ) SELECT
                                      p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id,
                                      p_Bsc_Kpi_Group_Rec.Bsc_Csf_Id,
                                      p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id,
                                      L.LANGUAGE_CODE,
                                      USERENV('LANG'),
                                      p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name,
                                      p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Help
                                      FROM FND_LANGUAGES L
                                    WHERE L.INSTALLED_FLAG IN ('I', 'B')
                                     AND NOT EXISTS
                                      (SELECT NULL
                                        FROM BSC_TAB_IND_GROUPS_TL T
                                        WHERE T.tab_id = p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id
                                          AND T.csf_id = p_Bsc_Kpi_Group_Rec.Bsc_Csf_Id
                                          AND T.ind_group_id = p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id
                                          AND T.LANGUAGE = L.LANGUAGE_CODE);

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCKPIGrpPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCKPIGrpPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BSCKPIGrpPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if (SQLCODE = -01400) then
          FND_MESSAGE.SET_NAME('BSC','BSC_TABLE_NULL_VALUE');
          FND_MESSAGE.SET_TOKEN('BSC_OBJECT', 'BSC_KPI_GROUP_PVT.Create_Kpi_Group');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PVT.Create_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PVT.Create_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BSCKPIGrpPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PVT.Create_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PVT.Create_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Kpi_Group;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Kpi_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec   IN      BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_Bsc_Kpi_Group_Rec   IN OUT NOCOPY      BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) is

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  g_db_object := 'Retrieve_Kpi_Group';

  SELECT DISTINCT  A.TAB_ID
                  ,A.CSF_ID
                  ,A.GROUP_TYPE
                  ,A.NAME_POSITION
                  ,A.NAME_JUSTIFICATION
                  ,A.LEFT_POSITION
                  ,A.TOP_POSITION
                  ,A.WIDTH
                  ,A.HEIGHT
                  ,A.SHORT_NAME
                  ,B.NAME
                  ,B.HELP
                  ,B.SOURCE_LANG
             INTO  x_Bsc_Kpi_Group_Rec.Bsc_Tab_Id
                  ,x_Bsc_Kpi_Group_Rec.Bsc_Csf_Id
                  ,x_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Type
                  ,x_Bsc_Kpi_Group_Rec.Bsc_Name_Pos_In_Tab
                  ,x_Bsc_Kpi_Group_Rec.Bsc_Name_Justif_In_Tab
                  ,x_Bsc_Kpi_Group_Rec.Bsc_Left_Position_In_Tab
                  ,x_Bsc_Kpi_Group_Rec.Bsc_Top_Position_In_Tab
                  ,x_Bsc_Kpi_Group_Rec.Bsc_Group_Width
                  ,x_Bsc_Kpi_Group_Rec.Bsc_Group_Height
                  ,x_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Short_Name
                  ,x_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name
                  ,x_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Help
                  ,x_Bsc_Kpi_Group_Rec.Bsc_Source_Language
             FROM  BSC_TAB_IND_GROUPS_B a
                  ,BSC_TAB_IND_GROUPS_TL b
            WHERE a.ind_group_id = b.ind_group_id
              AND b.ind_group_id = p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id
              AND b.language = USERENV('LANG')
              AND a.tab_id = -1
              AND a.tab_id = b.tab_id;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

--BSC_DEBUG.PUT_LINE(' -- End BSC_KPI_GROUP_PVT.Retrieve_Kpi_Group' );


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
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PVT.Retrieve_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PVT.Retrieve_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PVT.Retrieve_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PVT.Retrieve_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Kpi_Group;

/************************************************************************************
************************************************************************************/

procedure Update_Kpi_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec  IN      BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Group_Rec            BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;

l_count             number;
l_name_count        number;
l_update_TL         number := 0;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCKPIUptPVT;
 --BSC_DEBUG.PUT_LINE(' -- Begin BSC_KPI_GROUP_PVT.Update_Kpi_Group' );

  -- Check that valid Kpi group id was entered.
  if p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id  is not null then

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_TAB_IND_GROUPS_B
    WHERE  ind_group_id = p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id;

    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KGROUP_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KGROUP', p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KGROUP_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KGROUP', p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

 --BSC_DEBUG.PUT_LINE(' BSC_KPI_GROUP_PVT.Update_Kpi_Group - Flag 1' );

  select count(ind_group_id)
    into l_name_count
    from BSC_TAB_IND_GROUPS_TL
   where name = p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name
     and ind_group_id <> p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id
     and tab_id = -1;

 --BSC_DEBUG.PUT_LINE(' BSC_KPI_GROUP_PVT.Update_Kpi_Group - Flag 2 ' );

  if l_name_count <> 0 then
    FND_MESSAGE.SET_NAME('BSC','BSC_KGROUP_NAME_EXISTS');
    FND_MESSAGE.SET_TOKEN('BSC_KGROUP', p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

 --BSC_DEBUG.PUT_LINE(' BSC_KPI_GROUP_PVT.Update_Kpi_Group - Flag 3 ' );

  -- Check that valid Tab id was entered, only if tab id is not -1.
  IF p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id <> -1 THEN
    IF p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id  IS NOT NULL THEN

      SELECT COUNT(1) INTO l_Count
      FROM   BSC_TABS_B
      WHERE  TAB_ID = p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id;

      if l_count = 0 then
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_TAB_ID');
        FND_MESSAGE.SET_TOKEN('BSC_TAB', p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    else
      FND_MESSAGE.SET_NAME('BSC','BSC_NO_TAB_ID_ENTERED');
      FND_MESSAGE.SET_TOKEN('BSC_KGROUP', p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Kpi_Group( p_commit
                     ,p_Bsc_Kpi_Group_Rec
                     ,l_Bsc_Kpi_Group_Rec
                     ,x_return_status
                     ,x_msg_count
                     ,x_msg_data);

  -- update LOCAL language ,source language  and Kpi Group Id values with PASSED values.
  l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id := p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id;
  l_Bsc_Kpi_Group_Rec.Bsc_Language := p_Bsc_Kpi_Group_Rec.Bsc_Language;
  l_Bsc_Kpi_Group_Rec.Bsc_Source_Language := p_Bsc_Kpi_Group_Rec.Bsc_Source_Language;
  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Bsc_Kpi_Group_Rec.Bsc_Csf_Id is not null then
    l_Bsc_Kpi_Group_Rec.Bsc_Csf_Id := p_Bsc_Kpi_Group_Rec.Bsc_Csf_Id;
  end if;
  if p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id is not null  then
    l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id := p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id;
  end if;
  if p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Type is not null then
    l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Type := p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Type;
  end if;
  if p_Bsc_Kpi_Group_Rec.Bsc_Name_Pos_In_Tab is not null then
    l_Bsc_Kpi_Group_Rec.Bsc_Name_Pos_In_Tab := p_Bsc_Kpi_Group_Rec.Bsc_Name_Pos_In_Tab;
  end if;
  if p_Bsc_Kpi_Group_Rec.Bsc_Name_Justif_In_Tab is not null then
    l_Bsc_Kpi_Group_Rec.Bsc_Name_Justif_In_Tab := p_Bsc_Kpi_Group_Rec.Bsc_Name_Justif_In_Tab;
  end if;
  if p_Bsc_Kpi_Group_Rec.Bsc_Left_Position_In_Tab is not null then
    l_Bsc_Kpi_Group_Rec.Bsc_Left_Position_In_Tab := p_Bsc_Kpi_Group_Rec.Bsc_Left_Position_In_Tab;
  end if;
  if p_Bsc_Kpi_Group_Rec.Bsc_Top_Position_In_Tab is not null then
    l_Bsc_Kpi_Group_Rec.Bsc_Top_Position_In_Tab := p_Bsc_Kpi_Group_Rec.Bsc_Top_Position_In_Tab;
  end if;
  if p_Bsc_Kpi_Group_Rec.Bsc_Group_Width is not null
       and  p_Bsc_Kpi_Group_Rec.Bsc_Group_Width > 150  then  /*added to fixed bug 2650624 */
    l_Bsc_Kpi_Group_Rec.Bsc_Group_Width := p_Bsc_Kpi_Group_Rec.Bsc_Group_Width;
  end if;
  if p_Bsc_Kpi_Group_Rec.Bsc_Group_Height is not null
       and p_Bsc_Kpi_Group_Rec.Bsc_Group_Width > 150  then /*added to fixed bug 2650624 */
    l_Bsc_Kpi_Group_Rec.Bsc_Group_Height := p_Bsc_Kpi_Group_Rec.Bsc_Group_Height;
  end if;
  if p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name is not null then
    l_update_TL := 1;
    l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name := p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name;
  end if;
  if p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Help is not null then
    l_update_TL := 1;
    l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Help := p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Help;
  end if;

  -- Check to see if combination Tab Id and Kpi Group Id passed already exists.  If it does not then
  -- need to create entry for this group with this tab.
  if p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id is not null and p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id <> -1 then
    select count(*)
      into l_count
      from BSC_TAB_IND_GROUPS_B
     where tab_id = p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id
       and ind_group_id = l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id;
  end if;
--BSC_DEBUG.PUT_LINE('l_count = ' || l_count );

  if l_count = 0 then
    l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id := p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id;
    Create_Kpi_Group( p_commit
                     ,l_Bsc_Kpi_Group_Rec
                     ,x_return_status
                     ,x_msg_count
                     ,x_msg_data);
  end if;

  update BSC_TAB_IND_GROUPS_B
     set  csf_id = l_Bsc_Kpi_Group_Rec.Bsc_Csf_Id
         ,group_type = l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Type
         ,name_position = l_Bsc_Kpi_Group_Rec.Bsc_Name_Pos_In_Tab
         ,name_justification = l_Bsc_Kpi_Group_Rec.Bsc_Name_Justif_In_Tab
   where ind_group_id = l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id;

if l_update_TL = 1 then
--BSC_DEBUG.PUT_LINE(' BSC_KPI_GROUP_PVT.Update_Kpi_Group - Flag 4.5 ' );
  update BSC_TAB_IND_GROUPS_TL
     set  csf_id = l_Bsc_Kpi_Group_Rec.Bsc_Csf_Id
         ,name = l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name
         ,help = l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Help
         ,source_lang = userenv('LANG')
      where ind_group_id = l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id
     and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);
end if;

  -- set the Tab Id to that passed.
  l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id := p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id;

  -- The previous UPDATES are for the group in all tabs.  The following
  -- updates are applied to individual tabs.

  update BSC_TAB_IND_GROUPS_B
     set  left_position = l_Bsc_Kpi_Group_Rec.Bsc_Left_Position_In_Tab
         ,top_position = l_Bsc_Kpi_Group_Rec.Bsc_Top_Position_In_Tab
         ,width = l_Bsc_Kpi_Group_Rec.Bsc_Group_Width
         ,height = l_Bsc_Kpi_Group_Rec.Bsc_Group_Height
   where ind_group_id = l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id
     and (tab_id = l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id or tab_id = -1);


  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

--BSC_DEBUG.PUT_LINE(' -- End BSC_KPI_GROUP_PVT.Update_Kpi_Group' );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCKPIUptPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCKPIUptPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BSCKPIUptPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PVT.Update_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PVT.Update_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BSCKPIUptPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PVT.Update_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PVT.Update_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Kpi_Group;

/************************************************************************************
************************************************************************************/

procedure Delete_Kpi_Group(
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec   IN      BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count                         number;
l_count_kpi                     number;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCKPIDeletePVT;
   SAVEPOINT BSCKPIDelPVT;
  -- Check that Group id is valid.
  if p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id  is not null then

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_TAB_IND_GROUPS_B
    WHERE  IND_GROUP_ID = p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id;

    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KGROUP_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KGROUP', p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KGROUP_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KGROUP', p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Need to determine whether deletion is global, or just from a Tab.

  if ((p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id is not null) and (p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id <> -1)) then

    select count(b.indicator)
    into   l_count_kpi
    from bsc_kpis_b a, bsc_tab_indicators b
    where a.ind_group_id = p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id
    and a.indicator = b.indicator
    and b.tab_id = p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id;

    if l_count_kpi = 0 then
      delete from BSC_TAB_IND_GROUPS_B
      where ind_group_id = p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id
      and tab_id = p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id;

      delete from BSC_TAB_IND_GROUPS_TL
      where ind_group_id = p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id
      and tab_id = p_Bsc_Kpi_Group_Rec.Bsc_Tab_Id;
    else
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_CANNOT_DELETE_KGROUP');
      FND_MESSAGE.SET_TOKEN('BSC_KGROUP', p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;


  else

    -- Before deleting Kpi Group check that there are no KPIs assigned to it.
    select count(indicator)
      into l_count
      from BSC_KPIS_B
     where ind_group_id = p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id
      and PROTOTYPE_FLAG <> BSC_KPI_PUB.DELETE_KPI_FLAG;   -- Added to fix bug 3267470

    if l_count = 0 then
      delete from BSC_TAB_IND_GROUPS_B
       where ind_group_id = p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id;

      delete from BSC_TAB_IND_GROUPS_TL
       where ind_group_id = p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id;
    else
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_CANNOT_DELETE_KGROUP');
      FND_MESSAGE.SET_TOKEN('BSC_KGROUP', p_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;

  end if;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  BSCKPIDeletePVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  BSCKPIDeletePVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO  BSCKPIDeletePVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PVT.Delete_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PVT.Delete_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO  BSCKPIDeletePVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PVT.Delete_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PVT.Delete_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Delete_Kpi_Group;

/************************************************************************************
************************************************************************************/

end BSC_KPI_GROUP_PVT;

/
