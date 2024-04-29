--------------------------------------------------------
--  DDL for Package Body BSC_SCORECARD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SCORECARD_PVT" as
/* $Header: BSCVTABB.pls 120.0.12000000.2 2007/05/31 07:42:53 ashankar ship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCVTABB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 22, 2001                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 |                      Private Body version.                                           |
 |          This package creates a BSC Scorecard/Tab.                                   |
 |                                                                                      |
 | History:                                                                             |
 | 13-JAN-2003 ASHANKAR Bug Fix #2742973 Runtime Error "3021" when clicking on          |
 |                        the next button in VB-Builder.                                |
 | 04-MAR-2003 PAJOHRI  MLS Bug #2721899                                                |
 |                        1. Modified Update Query for  BSC_TABS_TL, BSC_TAB_CSF_TL     |
 | 30-APR-2003 PWALI  Bug #2926199                                                      |
 |                    1. Modified Retrieve_Tab(), to change the Query filter            |
 | 13-MAY-2003 PWALI  Bug #2942895, SQL BIND COMPLIANCE                                 |
 | 18-MAY-04          adrao Modified PL/SQL records and CRUD to accept SHORT_NAME       |
 | 02-SEP-04            ashankar fix for the bug 3866577                                |
 | 28-OCT-04   wleung modified delete_tab() adding delete_function() logic enh 3934298  |
 | 29-Mar-2005 kyadamak bug#4268439
 |       30-May-2007  ashankar ER#TGSS 5844382                                          |
 +======================================================================================+
*/
G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_SCORECARD_PVT';
g_db_object                             varchar2(30) := null;

procedure Create_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

l_language                      varchar2(4);

CURSOR c_language IS
SELECT language_code
FROM   fnd_languages
WHERE  installed_flag IN ('I','B');

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT CreateBSCTabPVT;
  -- Check Tab Id does not exist.
  IF p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id IS NOT NULL THEN

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_TABS_B T
    WHERE  T.TAB_ID = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

    IF l_Count <> 0 THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_TAB_ID_EXISTS');
      FND_MESSAGE.SET_TOKEN('BSC_TAB', p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Check for duplicate short_name
    IF p_Bsc_Tab_Entity_Rec.Bsc_Short_Name IS NOT NULL THEN
        SELECT COUNT(1) INTO l_Count
        FROM   BSC_TABS_B T
        WHERE  T.SHORT_NAME = p_Bsc_Tab_Entity_Rec.Bsc_Short_Name;

        IF l_Count <> 0 THEN
          FND_MESSAGE.SET_NAME('BSC','BSC_TAB_SHORT_NAME_NOT_UNIQUE');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_TAB_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_TAB', p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  g_db_object := 'BSC_TABS_B';

  -- if there are no errors up to this point then create tab.
  INSERT INTO BSC_TABS_B( TAB_ID
                         ,KPI_MODEL
                         ,BSC_MODEL
                         ,CROSS_MODEL
                         ,DEFAULT_MODEL
                         ,ZOOM_FACTOR
                         ,CREATED_BY
                         ,CREATION_DATE
                         ,LAST_UPDATED_BY
                         ,LAST_UPDATE_DATE
                         ,LAST_UPDATE_LOGIN
                         ,TAB_INDEX
                         ,PARENT_TAB_ID
                         ,OWNER_ID
                         ,SHORT_NAME)
                  VALUES( p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
                         ,p_Bsc_Tab_Entity_Rec.Bsc_Kpi_Model
                         ,p_Bsc_Tab_Entity_Rec.Bsc_Bsc_Model
                         ,p_Bsc_Tab_Entity_Rec.Bsc_Cross_Model
                         ,p_Bsc_Tab_Entity_Rec.Bsc_Default_Model
                         ,p_Bsc_Tab_Entity_Rec.Bsc_Zoom_Factor
                         ,p_Bsc_Tab_Entity_Rec.Bsc_Created_By
                         ,SYSDATE
                         ,p_Bsc_Tab_Entity_Rec.Bsc_Last_Updated_By
                         ,SYSDATE
                         ,p_Bsc_Tab_Entity_Rec.Bsc_Last_Update_Login
                         ,p_Bsc_Tab_Entity_Rec.Bsc_Tab_Index
                         ,p_Bsc_Tab_Entity_Rec.Bsc_Parent_Tab_Id
                         ,p_Bsc_Tab_Entity_Rec.Bsc_Owner_Id
                         ,p_Bsc_Tab_Entity_Rec.Bsc_Short_Name);


  g_db_object := 'BSC_TABS_TL';

  IF (c_language%ISOPEN) THEN
    CLOSE c_language;
  END IF;

  OPEN c_language;
  LOOP
  FETCH c_language INTO l_language;
  EXIT WHEN c_language%NOTFOUND;

  INSERT INTO BSC_TABS_TL( TAB_ID
                           ,LANGUAGE
                           ,SOURCE_LANG
                           ,NAME
                           ,HELP
                           ,ADDITIONAL_INFO)
                     VALUES( p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
                            ,l_Language
                            ,USERENV('LANG')
                            ,p_Bsc_Tab_Entity_Rec.Bsc_Tab_Name
                            ,p_Bsc_Tab_Entity_Rec.Bsc_Tab_Help
                            ,p_Bsc_Tab_Entity_Rec.Bsc_Tab_Info);

  END LOOP;
  CLOSE c_language;

  g_db_object := 'BSC_TAB_CSF_B';

  INSERT INTO BSC_TAB_CSF_B(  TAB_ID
                             ,CSF_ID
                             ,CSF_TYPE
                             ,INTERMEDIATE_FLAG)
                      VALUES( p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
                             ,p_Bsc_Tab_Entity_Rec.Bsc_Csf_Id
                             ,p_Bsc_Tab_Entity_Rec.Bsc_Csf_Type
                             ,p_Bsc_Tab_Entity_Rec.Bsc_Intermediate_Flag);

   g_db_object := 'BSC_TAB_CSF_TL';

   IF (c_language%ISOPEN) THEN
      CLOSE c_language;
   END IF;

   OPEN c_language;
   LOOP
   FETCH c_language INTO l_language;
   EXIT WHEN c_language%NOTFOUND;

   INSERT INTO BSC_TAB_CSF_TL(  TAB_ID
                               ,CSF_ID
                               ,LANGUAGE
                               ,SOURCE_LANG
                               ,NAME
                               ,HELP)
                            VALUES( p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
                                   ,p_Bsc_Tab_Entity_Rec.Bsc_Csf_Id
                                   ,l_language
                                   ,USERENV('LANG')
                                   ,p_Bsc_Tab_Entity_Rec.Bsc_Tab_Name
                                   ,p_Bsc_Tab_Entity_Rec.Bsc_Tab_Help);

   END LOOP;
   CLOSE c_language;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCTabPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCTabPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCTabPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Create_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Create_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCTabPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Create_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Create_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Tab;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_Bsc_Tab_Entity_Rec  IN OUT NOCOPY     BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) is

begin

  g_db_object := 'Retrieve_Tab';

  SELECT DISTINCT A.KPI_MODEL
                 ,A.BSC_MODEL
                 ,A.CROSS_MODEL
                 ,A.DEFAULT_MODEL
                 ,A.ZOOM_FACTOR
                 ,A.CREATED_BY
                 ,A.CREATION_DATE
                 ,A.LAST_UPDATED_BY
                 ,A.LAST_UPDATE_DATE
                 ,A.LAST_UPDATE_LOGIN
                 ,A.TAB_INDEX
                 ,A.PARENT_TAB_ID
                 ,A.OWNER_ID
                 ,A.SHORT_NAME
                 ,B.NAME
                 ,B.HELP
                 ,B.ADDITIONAL_INFO
                 ,C.CSF_ID
                 ,C.CSF_TYPE
                 ,C.INTERMEDIATE_FLAG
                 ,D.CSF_ID
            INTO  x_Bsc_Tab_Entity_Rec.Bsc_Kpi_Model
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Bsc_Model
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Cross_Model
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Default_Model
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Zoom_Factor
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Created_By
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Creation_Date
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Last_Updated_By
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Last_Update_Date
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Last_Update_Login
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Tab_Index
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Parent_Tab_Id
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Owner_Id
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Short_Name
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Tab_Name
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Tab_Help
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Tab_Info
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Csf_Id
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Csf_Type
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Intermediate_Flag
                 ,x_Bsc_Tab_Entity_Rec.Bsc_Csf_Id
            FROM  BSC_TABS_B A
                 ,BSC_TABS_TL B
                 ,BSC_TAB_CSF_B C
                 ,BSC_TAB_CSF_TL D
           WHERE A.TAB_ID   = B.TAB_ID
             AND A.TAB_ID   = C.TAB_ID
             AND C.TAB_ID   = D.TAB_ID
             AND A.TAB_ID   = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
             AND B.LANGUAGE = USERENV('LANG')
             AND D.LANGUAGE = USERENV('LANG');
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
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Retrieve_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Retrieve_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Retrieve_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Retrieve_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Retrieve_Tab;

/************************************************************************************
************************************************************************************/

procedure Update_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Tab_Entity_Rec        BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;
l_Bsc_Tab_Entity_Tbl        BSC_SCORECARD_PUB.Bsc_Tab_Entity_Tbl;

l_count             number;
l_move_flag         number := 0;  --Flag to move Tabs.

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT UpdateBSCTabPVT;
  -- Check that valid Tab id was entered.
  if p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_TABS_B'
                                                 ,'tab_id'
                                                 ,p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_TAB_ID');
      FND_MESSAGE.SET_TOKEN('BSC_TAB', p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_TAB_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_TAB', p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Tab( p_commit
               ,p_Bsc_Tab_Entity_Rec
               ,l_Bsc_Tab_Entity_Rec
               ,x_return_status
               ,x_msg_count
               ,x_msg_data);



  -- update LOCAL language ,source language  and Tab Id values with PASSED values.
  l_Bsc_Tab_Entity_Rec.Bsc_Language := p_Bsc_Tab_Entity_Rec.Bsc_Language;
  l_Bsc_Tab_Entity_Rec.Bsc_Source_Language := p_Bsc_Tab_Entity_Rec.Bsc_Source_Language;
  l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id := p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;


  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Bsc_Tab_Entity_Rec.Bsc_Kpi_Model is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Kpi_Model := p_Bsc_Tab_Entity_Rec.Bsc_Kpi_Model;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Bsc_Model is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Bsc_Model := p_Bsc_Tab_Entity_Rec.Bsc_Bsc_Model;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Cross_Model is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Cross_Model := p_Bsc_Tab_Entity_Rec.Bsc_Cross_Model;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Default_Model is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Default_Model := p_Bsc_Tab_Entity_Rec.Bsc_Default_Model;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Zoom_Factor is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Zoom_Factor := p_Bsc_Tab_Entity_Rec.Bsc_Zoom_Factor;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Created_By is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Created_By := p_Bsc_Tab_Entity_Rec.Bsc_Created_By;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Creation_Date is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Creation_Date := p_Bsc_Tab_Entity_Rec.Bsc_Creation_Date;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Last_Updated_By is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Last_Updated_By := p_Bsc_Tab_Entity_Rec.Bsc_Last_Updated_By;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Last_Update_Date is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Last_Update_Date := p_Bsc_Tab_Entity_Rec.Bsc_Last_Update_Date;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Last_Update_Login is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Last_Update_Login := p_Bsc_Tab_Entity_Rec.Bsc_Last_Update_Login;
  end if;
  /* This was the Bug */
  if p_Bsc_Tab_Entity_Rec.Bsc_Parent_Tab_Id = -2 then
    l_Bsc_Tab_Entity_Rec.Bsc_Parent_Tab_Id := null;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Parent_Tab_Id is not null then
    if p_Bsc_Tab_Entity_Rec.Bsc_Parent_Tab_Id = -2 then
      l_Bsc_Tab_Entity_Rec.Bsc_Parent_Tab_Id := null;
    else
      l_Bsc_Tab_Entity_Rec.Bsc_Parent_Tab_Id := p_Bsc_Tab_Entity_Rec.Bsc_Parent_Tab_Id;
    end if;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Owner_Id is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Owner_Id := p_Bsc_Tab_Entity_Rec.Bsc_Owner_Id;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Tab_Name is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name := p_Bsc_Tab_Entity_Rec.Bsc_Tab_Name;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Tab_Help is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Tab_Help := p_Bsc_Tab_Entity_Rec.Bsc_Tab_Help;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Tab_Info is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Tab_Info := p_Bsc_Tab_Entity_Rec.Bsc_Tab_Info;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Csf_Id is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Csf_Id := p_Bsc_Tab_Entity_Rec.Bsc_Csf_Id;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Csf_Type is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Csf_Type := p_Bsc_Tab_Entity_Rec.Bsc_Csf_Type;
  end if;
  if p_Bsc_Tab_Entity_Rec.Bsc_Intermediate_Flag is not null then
    l_Bsc_Tab_Entity_Rec.Bsc_Intermediate_Flag := p_Bsc_Tab_Entity_Rec.Bsc_Intermediate_Flag;
  end if;

  -- Check to see if the Index has changed. If it has then all Tabs need to be moved.
  if p_Bsc_Tab_Entity_Rec.Bsc_Tab_Index is not null then
    if p_Bsc_Tab_Entity_Rec.Bsc_Tab_Index <> l_Bsc_Tab_Entity_Rec.Bsc_Tab_Index then
      l_move_flag := 1;
    end if;
    l_Bsc_Tab_Entity_Rec.Bsc_Tab_Index := p_Bsc_Tab_Entity_Rec.Bsc_Tab_Index;
  end if;

  update BSC_TABS_B
     set  kpi_model = l_Bsc_Tab_Entity_Rec.Bsc_Kpi_Model
         ,bsc_model = l_Bsc_Tab_Entity_Rec.Bsc_Bsc_Model
         ,cross_model = l_Bsc_Tab_Entity_Rec.Bsc_Cross_Model
         ,default_model = l_Bsc_Tab_Entity_Rec.Bsc_Default_Model
         ,zoom_factor = l_Bsc_Tab_Entity_Rec.Bsc_Zoom_Factor
         ,created_by = l_Bsc_Tab_Entity_Rec.Bsc_Created_By
         ,creation_date = l_Bsc_Tab_Entity_Rec.Bsc_Creation_Date
         ,last_updated_by = l_Bsc_Tab_Entity_Rec.Bsc_Last_Updated_By
         ,last_update_date = l_Bsc_Tab_Entity_Rec.Bsc_Last_Update_Date
         ,last_update_login = l_Bsc_Tab_Entity_Rec.Bsc_Last_Update_Login
         ,tab_index = l_Bsc_Tab_Entity_Rec.Bsc_Tab_Index
         ,parent_tab_id = l_Bsc_Tab_Entity_Rec.Bsc_Parent_Tab_Id
         ,owner_id = l_Bsc_Tab_Entity_Rec.Bsc_Owner_Id
   where tab_id = l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

  update BSC_TABS_TL
     set  name = l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name
         ,help = l_Bsc_Tab_Entity_Rec.Bsc_Tab_Help
         ,ADDITIONAL_INFO = l_Bsc_Tab_Entity_Rec.Bsc_Tab_Info
         ,SOURCE_LANG     = userenv('LANG')
   where tab_id = l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
     and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  update BSC_TAB_CSF_B
     set  csf_id = l_Bsc_Tab_Entity_Rec.Bsc_Csf_Id
         ,csf_type = l_Bsc_Tab_Entity_Rec.Bsc_Csf_Type
         ,intermediate_flag = l_Bsc_Tab_Entity_Rec.Bsc_Intermediate_Flag
   where tab_id = l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

  update BSC_TAB_CSF_TL
     set  csf_id = l_Bsc_Tab_Entity_Rec.Bsc_Csf_Id
         ,name = l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name
         ,help = l_Bsc_Tab_Entity_Rec.Bsc_Tab_Help
         ,SOURCE_LANG     = userenv('LANG')
   where tab_id = l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
     and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  --If the move flag is set to 1 then move all tabs.
  if l_move_flag = 1 then
    Move_Tab( p_commit
             ,l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
             ,l_Bsc_Tab_Entity_Rec.Bsc_Tab_Index
             ,x_return_status
             ,x_msg_count
             ,x_msg_data);
  end if;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateBSCTabPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateBSCTabPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateBSCTabPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Update_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Update_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateBSCTabPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Update_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Update_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Update_Tab;

/************************************************************************************
************************************************************************************/

procedure Delete_Tab(
  p_commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN          BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY  VARCHAR2
 ,x_msg_count           OUT NOCOPY  NUMBER
 ,x_msg_data            OUT NOCOPY  VARCHAR2
) is

TYPE Recdc_value        IS REF CURSOR;
dc_value            Recdc_value;

l_sql               VARCHAR2(1000);
l_child_tab         NUMBER;
l_count             NUMBER;
l_tab_index         NUMBER;

CURSOR  c_sys_images IS
SELECT  image_id
FROM    BSC_SYS_IMAGES
WHERE   image_id NOT IN
(   SELECT DISTINCT(image_id)
      FROM   BSC_SYS_IMAGES_MAP_TL);

CURSOR c_indic_in_tab IS
SELECT INDICATOR
FROM   BSC_TAB_INDICATORS
WHERE  TAB_ID = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

CURSOR c_tab_views IS
  SELECT tab_id, tab_view_id
  FROM BSC_TAB_VIEWS_B
  WHERE tab_id = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;



begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT DeleteBSCTabPVT;
  -- Check that valid Tab id was entered.
  if p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id is not null then

     SELECT COUNT(0)
     INTO   l_count
     FROM   BSC_TABS_B
     WHERE  Tab_Id = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_TAB_ID');
      FND_MESSAGE.SET_TOKEN('BSC_TAB', p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_TAB_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_TAB', p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Before we delete the tab we need to reset the tab id parent and tab_index
  -- for the children of current tab.
  -- get the index.
  select max(tab_index)
    into l_tab_index
    from BSC_TABS_B
   where tab_id = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

  l_sql := 'select tab_id ' ||
           '  from BSC_TABS_B ' ||
           ' where parent_tab_id = :1';

  open dc_value for l_sql using p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;
    loop
      fetch dc_value into l_child_tab;
      exit when dc_value%NOTFOUND;

      -- update the index
      l_tab_index := l_tab_index + 1;

      update BSC_TABS_B
         set parent_tab_id = null
            ,tab_index = l_tab_index
       where tab_id = l_child_tab;

    end loop;
  close dc_value;

  /*

      DELETE FROM BSC_TAB_INDICATORS
      WHERE tab_id = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;*/


 -- Unassingn the indicator from the tab first
 -- The rules for unassign will apply while deleting tab also
  FOR CD IN c_indic_in_tab LOOP

         BSC_PMF_UI_WRAPPER.Unassign_KPI(
                                   p_commit             => FND_API.G_FALSE
                                  ,p_kpi_id             => CD.INDICATOR
                                  ,p_tab_id             => p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
                                  ,x_return_status      => x_return_status
                                  ,x_msg_count          => x_msg_count
                                  ,x_msg_data           => x_msg_data
                                  );
     IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END LOOP;

  IF(c_indic_in_tab%ISOPEN ) THEN
      CLOSE c_indic_in_tab;
  END IF;

    -- delete form function defined for each custom view
    FOR cd IN c_tab_views LOOP
        BSC_CUSTOM_VIEW_UI_WRAPPER.delete_function( p_tab_id        => cd.tab_id
                                                   ,p_tab_view_id   => cd.tab_view_id
                                                   ,x_return_status => x_return_status
                                                   ,x_msg_count     => x_msg_count
                                                   ,x_msg_data      => x_msg_data);
    END LOOP;
    IF (c_tab_views%ISOPEN) THEN
            CLOSE c_tab_views;
    END IF;

    -- delete pertinent values from pertinent tables.
    DELETE FROM BSC_TABS_B
    WHERE tab_id = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

    DELETE FROM BSC_TABS_TL
    WHERE tab_id = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

    DELETE FROM BSC_TAB_IND_GROUPS_B
    WHERE tab_id = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

    DELETE FROM BSC_TAB_IND_GROUPS_TL
    WHERE tab_id = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

    DELETE FROM BSC_TAB_CSF_B
    WHERE tab_id = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

    DELETE FROM BSC_TAB_CSF_TL
    WHERE tab_id = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

    DELETE FROM BSC_USER_TAB_ACCESS
    WHERE tab_id = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

    DELETE FROM BSC_TAB_VIEW_LABELS_B
    WHERE TAB_ID = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

    DELETE FROM BSC_TAB_VIEW_LABELS_TL
    WHERE TAB_ID =p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

    DELETE FROM BSC_TAB_VIEWS_B
    WHERE TAB_ID = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

    DELETE FROM BSC_TAB_VIEWS_TL
    WHERE TAB_ID = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

    DELETE
    FROM    BSC_SYS_IMAGES_MAP_TL
    WHERE   SOURCE_TYPE IN (1,3)
    AND     SOURCE_CODE =   p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

    FOR cd IN c_sys_images LOOP

      DELETE
      FROM   BSC_SYS_IMAGES
      WHERE  IMAGE_ID   = cd.image_id;

    END LOOP;

    DELETE FROM BSC_SYS_COM_DIM_LEVELS
    WHERE TAB_ID = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;


    -- Role-based scorecard security
    Remove_Scorecard_Grants(p_tab_id => p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id);

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteBSCTabPVT;
        IF(c_indic_in_tab%ISOPEN ) THEN
            CLOSE c_indic_in_tab;
        END IF;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteBSCTabPVT;
        IF(c_indic_in_tab%ISOPEN ) THEN
            CLOSE c_indic_in_tab;
        END IF;

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteBSCTabPVT;
        IF(c_indic_in_tab%ISOPEN ) THEN
            CLOSE c_indic_in_tab;
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Delete_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Delete_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteBSCTabPVT;
        IF(c_indic_in_tab%ISOPEN ) THEN
            CLOSE c_indic_in_tab;
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Delete_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Delete_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Delete_Tab;

/************************************************************************************
************************************************************************************/

procedure Create_Tab_Access(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT CreateBSCTabAccessPVT;
  -- Check that valid Tab id was entered.
  if p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_TABS_B'
                                                 ,'tab_id'
                                                 ,p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_TAB_ID');
      FND_MESSAGE.SET_TOKEN('BSC_TAB', p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_TAB_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_TAB', p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  g_db_object := 'BSC_USER_TAB_ACCESS';

  insert into BSC_USER_TAB_ACCESS( responsibility_id
                                  ,tab_id
                                  ,creation_date
                                  ,created_by
                                  ,last_update_date
                                  ,last_updated_by
                                  ,last_update_login
                                  ,start_date
                                  ,end_date)
                           values( p_Bsc_Tab_Entity_Rec.Bsc_Responsibility_Id
                                  ,p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
                                  ,sysdate
                                  ,p_Bsc_Tab_Entity_Rec.Bsc_Created_By
                                  ,sysdate
                                  ,p_Bsc_Tab_Entity_Rec.Bsc_Last_Updated_By
                                  ,p_Bsc_Tab_Entity_Rec.Bsc_Last_Update_Login
                                  ,sysdate
                                  ,p_Bsc_Tab_Entity_Rec.Bsc_Resp_End_Date);

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCTabAccessPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCTabAccessPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCTabAccessPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Create_Tab_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Create_Tab_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCTabAccessPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Create_Tab_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Create_Tab_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Create_Tab_Access;

/************************************************************************************
************************************************************************************/

-- Role-based scorecard security.
-- Initally, grant admin access to scorecard creater, and view access to all other designers.
procedure Create_Tab_Grants(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT CreateBSCTabGrantsPVT;

   Insert_Scorecard_Grants(
     p_tab_id => p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
    ,p_user_name => FND_GLOBAL.USER_NAME);

   IF (p_commit = FND_API.G_TRUE) THEN
     COMMIT;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCTabGrantsPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCTabGrantsPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCTabGrantsPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Create_Tab_Grants ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Create_Tab_Grants ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCTabGrantsPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Create_Tab_Grants ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Create_Tab_Grants ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Create_Tab_Grants;

/************************************************************************************
************************************************************************************/

procedure Move_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_tab_id      IN  number
 ,p_tab_index       IN  number
 ,x_return_status   OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Tab_Entity_Tbl        BSC_SCORECARD_PUB.Bsc_Tab_Entity_Tbl;

TYPE Recdc_value                IS REF CURSOR;
dc_value                        Recdc_value;

l_cnt               number;

l_sql               varchar2(2000);

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT MoveBSCTabPVT;
  l_sql := 'select distinct tab_id, tab_index ' ||
           '  from BSC_TABS_B ' ||
           ' where tab_index >= :1' ||
           '   and tab_id <>  :2' ||
           ' order by tab_index asc';

  l_cnt := 0;
  open dc_value for l_sql using p_tab_index, p_tab_id;
    loop
      fetch dc_value into l_Bsc_Tab_Entity_Tbl(l_cnt + 1).Bsc_Tab_Id,
                          l_Bsc_Tab_Entity_Tbl(l_cnt + 1).Bsc_Tab_Index;
      exit when dc_value%NOTFOUND;
      l_cnt := l_cnt + 1;
    end loop;
  close dc_value;

  for i in 1..l_Bsc_Tab_Entity_Tbl.count loop
    update BSC_TABS_B
       set tab_index = l_Bsc_Tab_Entity_Tbl(i).Bsc_Tab_Index + 1
     where tab_id = l_Bsc_Tab_Entity_Tbl(i).Bsc_Tab_Id;
  end loop;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO MoveBSCTabPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO MoveBSCTabPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO MoveBSCTabPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Move_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Move_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO MoveBSCTabPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Move_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Move_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Move_Tab;

/************************************************************************************
************************************************************************************/

procedure Update_Tab_Time_Stamp(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT UpdateBSCTabTimStmPVT;
  update BSC_TABS_B
     set last_update_date = sysdate
   where tab_id = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateBSCTabTimStmPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateBSCTabTimStmPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateBSCTabTimStmPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Update_Tab_Time_Stamp ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Update_Tab_Time_Stamp ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateBSCTabTimStmPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Update_Tab_Time_Stamp ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Update_Tab_Time_Stamp ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Update_Tab_Time_Stamp;

/************************************************************************************
************************************************************************************/

procedure Update_System_Time_Stamp(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT UpdateBSCTabSysTimStmPVT;
  update BSC_SYS_INIT
     set last_update_date = sysdate
   where property_code = 'LOCK_SYSTEM';

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateBSCTabSysTimStmPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateBSCTabSysTimStmPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateBSCTabSysTimStmPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Update_System_Time_Stamp ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Update_System_Time_Stamp ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateBSCTabSysTimStmPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PVT.Update_System_Time_Stamp ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PVT.Update_System_Time_Stamp ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

end Update_System_Time_Stamp;

/************************************************************************************
************************************************************************************/

function Validate_Tab(
  p_Tab_Name        IN  varchar2
) return number is

l_count         number;

begin

  select count(*)
    into l_count
    from BSC_TABS_TL
   where upper(name) = upper(p_Tab_Name);

  return l_count;

EXCEPTION
  when others then
    rollback;

end Validate_Tab;

/************************************************************************************
************************************************************************************/

function Validate_Kpi_Group(
  p_Kpi_Group_Name      IN  varchar2
) return number is

l_count         number;

begin

  select count(*)
    into l_count
    from BSC_TAB_IND_GROUPS_TL
   where upper(name) = upper(p_Kpi_Group_Name);

  return l_count;

EXCEPTION
  when others then
    rollback;

end Validate_Kpi_Group;

/************************************************************************************
************************************************************************************/

function Validate_Kpi(
  p_Kpi_Name                  IN      varchar2
) return number is

l_count                 number;

begin

  select count(*)
    into l_count
    from BSC_KPIS_TL
   where upper(name) = upper(p_Kpi_Name);

  return l_count;

EXCEPTION
  when others then
    rollback;

end Validate_Kpi;

/************************************************************************************
************************************************************************************
 PROCEDURE  Grant_Scorecard_Access
 Description :
              This procedure grants access to the users.For the user who is creating
              the Scorecard will have administartor access, while other users
              within the BSC_Manager and BSC_DESIGNER responsibility will have view
              access.

Input   :  p_tab_id,
           p_user_name
Creator :
        ashankar 05-05-04
Note:   This API is called from VB part.. so don't change the exception block.
        Any exception raised will be logged into BSC_Messages and will be checked in
        VB part.
/***********************************************************************************/


PROCEDURE Insert_Scorecard_Grants
(
    p_tab_id        IN      NUMBER
  , p_user_name     IN      VARCHAR2
)IS

CURSOR c_BscUserPool IS
SELECT distinct usr.user_name
FROM   fnd_user_resp_groups ur,
       fnd_responsibility r,
       fnd_user  usr
WHERE  ur.responsibility_id = r.responsibility_id
AND    usr.user_id = ur.user_id
AND    ur.responsibility_application_id = r.application_id
AND    r.application_id = 271
AND    r.responsibility_key IN ('BSC_DESIGNER' ,'BSC_Manager')
AND    SYSDATE BETWEEN usr.Start_Date AND NVL(usr.End_Date, SYSDATE)
AND    SYSDATE BETWEEN r.Start_Date   AND NVL(r.End_Date, SYSDATE)
AND    SYSDATE BETWEEN ur.Start_Date  AND NVL(ur.End_Date, SYSDATE);


l_count         NUMBER;
l_grant_guid    FND_GRANTS.grant_guid%TYPE;
l_success       VARCHAR2(5);
l_errorcode     NUMBER;
l_user_name     VARCHAR2(256);

BEGIN

     IF(p_tab_id IS NOT NULL ) THEN

        l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_TABS_B','tab_id',p_tab_id);
            IF l_count = 0 THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_TAB_ID');
                FND_MESSAGE.SET_TOKEN('BSC_TAB', p_tab_id);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
     ELSE
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_TAB_ID_ENTERED');
        FND_MESSAGE.SET_TOKEN('BSC_TAB', p_tab_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     /*User name can never be null, so no need to check for null condition*/

     FND_GRANTS_PKG.GRANT_FUNCTION
     (
         p_api_version          => 1.0
        ,p_menu_name            => BSC_ADMIN_ACCESS
        ,p_object_name          => BSC_OBJECT_NAME
        ,p_instance_type        => BSC_INSTANCE_TYPE
        ,p_instance_pk1_value   => to_char(p_tab_id)
        ,p_grantee_type         => BSC_GRANTEE_TYPE
        ,p_grantee_key          => UPPER(p_user_name)
        ,p_start_date           => SYSDATE
        ,p_end_date             => NULL
        ,p_program_name         => BSC_PROGRAM_NAME
        ,x_grant_guid           => l_grant_guid
        ,x_success              => l_success
        ,x_errorcode            => l_errorcode
     );
    IF (l_success  <> FND_API.G_TRUE) THEN
      --DBMS_OUTPUT.PUT_LINE('BSC_SCORECARD_PVT.Grant_Scorecard_Access Failed: at FND_GRANTS_DELETE_PKG.GRANT_FUNCTION );
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /****************************************************
     Except the current user other users will have the Viewer
     access, so we have to filter out the current user from the
     list of users returned by the cursor.
    /***************************************************/

    FOR user_pool IN c_BscUserPool LOOP
          l_user_name := user_pool.user_name;
          IF(UPPER(l_user_name)<>UPPER(p_user_name)) THEN
              FND_GRANTS_PKG.GRANT_FUNCTION
              (
                 p_api_version          => 1.0
                ,p_menu_name            => BSC_VIEWER_ACCESS
                ,p_object_name          => BSC_OBJECT_NAME
                ,p_instance_type        => BSC_INSTANCE_TYPE
                ,p_instance_pk1_value   => TO_CHAR(p_tab_id)
                ,p_grantee_type         => BSC_GRANTEE_TYPE
                ,p_grantee_key          => UPPER(l_user_name)
                ,p_start_date           => SYSDATE
                ,p_end_date             => NULL
                ,p_program_name         => BSC_PROGRAM_NAME
                ,x_grant_guid           => l_grant_guid
                ,x_success              => l_success
                ,x_errorcode            => l_errorcode
             );
            IF (l_success  <> FND_API.G_TRUE) THEN
              --DBMS_OUTPUT.PUT_LINE('BSC_SCORECARD_PVT.Grant_Scorecard_Access Failed: at FND_GRANTS_DELETE_PKG.GRANT_FUNCTION );
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
    END LOOP;


EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        BSC_MESSAGE.Add
        (    x_message   => SQLERRM
           , x_source    =>  'BSC_SCORECARD_PVT.Insert_Scorecard_Grants'
           , x_mode      => 'I'
        );


    WHEN FND_API.G_EXC_ERROR THEN
       BSC_MESSAGE.Add
        (    x_message   => SQLERRM
           , x_source    => 'BSC_SCORECARD_PVT.Insert_Scorecard_Grants'
           , x_mode      => 'I'
        );

    WHEN OTHERS THEN
        BSC_MESSAGE.Add
        (    x_message   => SQLERRM
           , x_source    =>  'BSC_SCORECARD_PVT.Insert_Scorecard_Grants'
           , x_mode      => 'I'
        );

END Insert_Scorecard_Grants;

/************************************************************************************
 PROCEDURE  Remove_Scorecard_Grants
 Description :
              This procedure Should be CALLED TO remove the records from FND_Grants table
              after the scorecard is deleted.

Input   :  p_tab_id,
           p_user_name
Creator :
        ashankar 05-05-04
Note:   This API is called from VB and PMD part.. so don't change the exception block.
        Any exception raised will be logged into BSC_Messages and will be checked in
        VB part.
/***********************************************************************************/

PROCEDURE Remove_Scorecard_Grants
(
    p_tab_id        IN      NUMBER
)IS
l_success       VARCHAR2(5);
l_errorcode     NUMBER;
l_object_id     NUMBER;
/*CURSOR c_BscUserPool IS
SELECT DISTINCT U.USER_ID,U.USER_NAME,U.FULL_NAME
FROM   bsc_apps_users_v  U,
       FND_USER_RESP_GROUPS fug,
       FND_RESPONSIBILITY rd
WHERE  U.BSC_VALID_FLAG =1
AND    U.USER_ID = fug.USER_ID
AND    fug.RESPONSIBILITY_ID = rd.RESPONSIBILITY_ID
AND    UPPER(RESPONSIBILITY_KEY) IN ('BSC_MANAGER','BSC_DESIGNER') ;*/

BEGIN


   /*FOR user_pool IN c_BscUserPool LOOP

       FND_GRANTS_PKG.delete_grant
        (
              p_grantee_type        => BSC_GRANTEE_TYPE
            , p_object_name         => BSC_OBJECT_NAME
            , p_grantee_key         => upper(user_pool.user_name)
            , p_instance_type       => BSC_INSTANCE_TYPE
            , p_instance_pk1_value  => to_char(p_tab_id)
            , p_instance_pk2_value  => '*NULL*'
            , p_instance_pk3_value  => '*NULL*'
            , p_instance_pk4_value  => '*NULL*'
            , p_instance_pk5_value  => '*NULL*'
            , p_program_name        => BSC_PROGRAM_NAME
            , x_success             => l_success
            , x_errcode             => l_errorcode
        );

        IF (l_success  <> FND_API.G_TRUE) THEN
          --DBMS_OUTPUT.PUT_LINE('BSC_SCORECARD_PVT.Remove_Scorecard_Grants Failed: at FND_GRANTS_DELETE_PKG.delete_grant );
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END LOOP;   */

    SELECT OBJECT_ID
    INTO   l_object_id
    FROM   FND_OBJECTS
    WHERE  OBJ_NAME = 'BSC_TAB';

    DELETE FROM FND_GRANTS
    WHERE  OBJECT_ID  = TO_CHAR(l_object_id)
    AND INSTANCE_TYPE = 'INSTANCE'
    AND INSTANCE_PK1_VALUE = TO_CHAR(p_tab_id)
    AND  PROGRAM_NAME = 'BSC_PMD_GRANTS';

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        BSC_MESSAGE.Add
        (
             x_message   => SQLERRM
           , x_source    =>  'BSC_SCORECARD_PVT.Remove_Scorecard_Grants'
           , x_mode      => 'I'
        );

    WHEN OTHERS THEN
        BSC_MESSAGE.Add
        (
             x_message   => SQLERRM
           , x_source    =>  'BSC_SCORECARD_PVT.Remove_Scorecard_Grants'
           , x_mode      => 'I'

        );
END Remove_Scorecard_Grants;
procedure REVOKE_GRANT
(  p_commit              IN  VARCHAR2
,  p_api_version         IN  NUMBER
,  p_grant_guid          IN  VARCHAR2
,  x_success             OUT NOCOPY VARCHAR2
,  x_errorcode           OUT NOCOPY NUMBER
) IS

xa_success  VARCHAR2(32000);
xa_errorcode NUMBER;
l_grant_guids  VARCHAR2(32000);
l_single_grant_guid VARCHAR2(32000);
BEGIN
l_grant_guids := p_grant_guid;
    WHILE (is_more( p_grant_uids  =>  l_grant_guids
                  , p_grant_uid         =>  l_single_grant_guid)
    ) LOOP
        begin
        FND_GRANTS_PKG.REVOKE_GRANT(  p_api_version => p_api_version
                                    , p_grant_guid  => l_single_grant_guid
                                    , x_success     => xa_success
                                    , x_errorcode   => xa_errorcode
                                    );
        EXCEPTION WHEN OTHERS THEN NULL; END;
    END LOOP;
  IF (p_commit = 'T') THEN
    COMMIT;
  END IF;
EXCEPTION
   when others then
    BSC_MESSAGE.Add(x_message => sqlerrm,
                    x_source => 'reovkeaccess',
                    x_mode => 'I');


END REVOKE_GRANT;


FUNCTION Is_More
(       p_grant_uids   IN  OUT NOCOPY  VARCHAR2
    ,   p_grant_uid        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
    l_pos_rel_columns       NUMBER;
BEGIN
    IF (p_grant_uids IS NOT NULL) THEN
        l_pos_ids           := INSTR(p_grant_uids,   ',');
        IF (l_pos_ids > 0) THEN
            p_grant_uid          :=  TRIM(SUBSTR(p_grant_uids,    1,    l_pos_ids - 1));
            p_grant_uids   :=  TRIM(SUBSTR(p_grant_uids,    l_pos_ids + 1));
        ELSE
            p_grant_uid          :=  TRIM(p_grant_uids);
            p_grant_uids   :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;
end BSC_SCORECARD_PVT;

/
