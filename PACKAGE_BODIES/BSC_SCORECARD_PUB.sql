--------------------------------------------------------
--  DDL for Package Body BSC_SCORECARD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SCORECARD_PUB" as
/* $Header: BSCPTABB.pls 120.6 2007/12/10 11:19:39 bijain ship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPTABB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 22, 2001                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 |                      Public Body version                                             |
 |          This package creates a BSC Scorecard/Tab.                                   |
 |                                                                                      |
 | 20-MAR-03 PWALI for bug #2843082                                                     |
 | 24-JUL-03 Adeulgao fixed bug#3047536 granted access of tabs to BSC_PMD_USER          |
 | 15-DEC-03 Aditya Rao removed Dynamic SQLs for Bug #3236356                           |
 |   10-MAR-04          jxyu  Modified for enhancement #3493589                         |
 |   06-MAY-04          ADRAO added code to handle BIS_DBI_ADMIN responsibility         |
 |   18-MAY-04          adrao Modified PL/SQL records and CRUD to accept SHORT_NAME     |
 |   20-JUL-04          adrao added PMU Responsibility for all S2E KPIs created from    |
 |                      Configure Region link from any responsibility. Bug#3775876      |
 |   10-SEP-04          adrao modified Create_Tab_User_Access for Bug#3877636           |
 |   13-JUL-05          akoduri Bug #4368221 Added the function Get_Custom_View_Name    |
 |   12-AGU-05  Kyadamak Bug#4462346  Modified function Check_Tab_UserAccess()          |
 |   23-AUG-05  visuri    Added Validate_Scorecard_Revoke(),Chk_Child_Scd_Has_Access()  |
 |                              Validate_Scorecard_Access() for bug 4103395             |
 |   01-SEP-05  Aditya Rao fixed Bug#4563456 in API Create_Tab_Access ()                |
 |   02-NOV-07  bijain           BugFix 6340598                                         |
 +======================================================================================+
*/

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_SCORECARD_PUB';


--New procedure with OUT parameter
procedure Create_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_Bsc_Tab_Entity_Rec  OUT NOCOPY     BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Tab_Entity_Rec            BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  --  Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Bsc_Tab_Entity_Rec := p_Bsc_Tab_Entity_Rec;

  -- Check that this Tab name does not exist.
  if l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name is not null then
    if BSC_SCORECARD_PVT.Validate_Tab(l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name) > 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_TAB_NAME_EXISTS');
      FND_MESSAGE.SET_TOKEN('BSC_TAB', l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;

  -- Get the next id available for the current Tab.
  -- Bug #3236356
  SELECT (NVL(MAX(TAB_ID), 0) + 1)
  INTO   l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
  FROM   BSC_TABS_B;

  --DBMS_OUTPUT.PUT_LINE('tab _id =============='  || l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id);

  -- If tab name is null then assign default name.
  if l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name is null then
    l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name := BSC_APPS.GET_LOOKUP_VALUE('BSC_UI_BUILDER', 'TAB')|| ' ' || l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;
  end if;

  -- Bug #3236356
  SELECT (NVL(MAX(TAB_INDEX), 0) + 1)
  INTO   l_Bsc_Tab_Entity_Rec.Bsc_Tab_Index
  FROM   BSC_TABS_B;
  -- The Tab needs an Index (location within BSC Tabs) get the next index.



  --DBMS_OUTPUT.PUT_LINE('parent tab id=============='  || l_Bsc_Tab_Entity_Rec.Bsc_Parent_Tab_Id);
  --DBMS_OUTPUT.PUT_LINE('tab index =============='  || l_Bsc_Tab_Entity_Rec.Bsc_Tab_Index);
  --DBMS_OUTPUT.PUT_LINE('tab name =============='  || l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name);



  BSC_SCORECARD_PVT.Create_Tab( p_commit
                               ,l_Bsc_Tab_Entity_Rec
                               ,x_return_status
                               ,x_msg_count
                               ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF(l_Bsc_Tab_Entity_Rec.Bsc_Short_Name is NULL) THEN
  Create_Tab_Access( p_commit
                    ,l_Bsc_Tab_Entity_Rec
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Role-based scorecard security.
  -- Initally, grant admin access to scorecard creater, and view access to all other designers.
  Create_Tab_Grants( p_commit
                    ,l_Bsc_Tab_Entity_Rec
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data);

  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
END IF;
  x_Bsc_Tab_Entity_Rec := l_Bsc_Tab_Entity_Rec;

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
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Create_Tab with parameter x_Bsc_Tab_Entity_Rec ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Create_Tab with parameter x_Bsc_Tab_Entity_Rec ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Create_Tab with parameter x_Bsc_Tab_Entity_Rec ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Create_Tab with parameter x_Bsc_Tab_Entity_Rec ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Create_Tab;


/************************************************************************************
************************************************************************************/
--Modified procedure without OUT parameter
procedure Create_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Tab_Entity_Rec            BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;
l_Bsc_Tab_Entity_Rec_Out        BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Bsc_Tab_Entity_Rec := p_Bsc_Tab_Entity_Rec;

  BSC_SCORECARD_PUB.Create_Tab(
             p_commit             => p_commit
            ,p_Bsc_Tab_Entity_Rec => l_Bsc_Tab_Entity_Rec
            ,x_Bsc_Tab_Entity_Rec => l_Bsc_Tab_Entity_Rec_Out
            ,x_return_status      => x_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
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
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Create_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Create_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Create_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Create_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Create_Tab;


/************************************************************************************
************************************************************************************/
--new procedure. Initializing the Tab Entity record.
procedure Initialize_Tab_Entity_Rec(
  p_Bsc_Tab_Entity_Rec  IN            BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_Bsc_Tab_Entity_Rec  OUT NOCOPY    BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY    varchar2
 ,x_msg_count           OUT NOCOPY    number
 ,x_msg_data            OUT NOCOPY    varchar2
) is

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  x_Bsc_Tab_Entity_Rec := p_Bsc_Tab_Entity_Rec;

  --set some default values
  x_Bsc_Tab_Entity_Rec.Bsc_Kpi_Model          := 1;
  x_Bsc_Tab_Entity_Rec.Bsc_Bsc_Model          := 0;
  x_Bsc_Tab_Entity_Rec.Bsc_Default_Model      := 0;
  x_Bsc_Tab_Entity_Rec.Bsc_Created_By         := 0;
  x_Bsc_Tab_Entity_Rec.Bsc_Csf_Id             := 0;
  x_Bsc_Tab_Entity_Rec.Bsc_Csf_Type           := 0;
  x_Bsc_Tab_Entity_Rec.Bsc_Intermediate_Flag  := 0;
  x_Bsc_Tab_Entity_Rec.Bsc_Language           := 'US';
  x_Bsc_Tab_Entity_Rec.Bsc_Last_Updated_By    := 0;
  x_Bsc_Tab_Entity_Rec.Bsc_Last_Update_Login  := 0;
  x_Bsc_Tab_Entity_Rec.Bsc_Source_Language    := 'US';


EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data :=  x_msg_data||' -> BSC_SCORECARD_PUB.Initialize_Tab_Entity_Rec ';
        ELSE
            x_msg_data :=  SQLERRM||' at BSC_SCORECARD_PUB.Initialize_Tab_Entity_Rec ';
        END IF;
        RAISE;
end Initialize_Tab_Entity_Rec;


/************************************************************************************
************************************************************************************/

procedure Retrieve_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_Bsc_Tab_Entity_Rec  IN OUT NOCOPY      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_SCORECARD_PVT.Retrieve_Tab( p_commit
                                 ,p_Bsc_Tab_Entity_Rec
                                 ,x_Bsc_Tab_Entity_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Retrieve_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Retrieve_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Retrieve_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Retrieve_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

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

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_SCORECARD_PVT.Update_Tab( p_commit
                               ,p_Bsc_Tab_Entity_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Update_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Update_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Update_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Update_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Update_Tab;

/************************************************************************************
************************************************************************************/

procedure Delete_Tab(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_SCORECARD_PVT.Delete_Tab( p_commit
                               ,p_Bsc_Tab_Entity_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Delete_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Delete_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Delete_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Delete_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Delete_Tab;
/************************************************************************************
 Function    :   Create_Tab_Access_For_Resp
 Description :   This function will assign a scorecard to a given responsibility
***********************************************************************************/
PROCEDURE Create_Tab_Access_For_Resp(
  p_Resposibility_Key   IN      VARCHAR2
 ,p_commit              IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
)IS
l_Bsc_Tab_Entity_Rec  BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;
l_Count               NUMBER;

CURSOR c_Resp_Ids IS
SELECT responsibility_id
FROM   fnd_responsibility
WHERE  INSTR(','||p_Resposibility_Key||',',','||responsibility_key||',') > 0;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Bsc_Tab_Entity_Rec := p_Bsc_Tab_Entity_Rec;

  FOR CD IN c_Resp_Ids LOOP
    SELECT COUNT(1)
    INTO   l_Count
    FROM   bsc_user_tab_access
    WHERE  tab_id = p_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
    AND    responsibility_id = CD.responsibility_id;
    --dbms_output.put_line(' resp id :-' || CD.responsibility_id);
    l_Bsc_Tab_Entity_Rec.Bsc_Responsibility_Id := CD.responsibility_id;

    IF(l_Count = 0) THEN
      --dbms_output.put_line(' calling create tab_access for resp id :-' || l_Bsc_Tab_Entity_Rec.Bsc_Responsibility_Id);
      BSC_SCORECARD_PVT.Create_Tab_Access
      ( p_commit
      , l_Bsc_Tab_Entity_Rec
      , x_return_status
      , x_msg_count
      , x_msg_data
      );
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

  END LOOP;

  --dbms_output.put_line(' end loop:-' );

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
      x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Create_Tab_Access_For_Resp ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Create_Tab_Access_For_Resp ';
    END IF;
    --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Create_Tab_Access_For_Resp ';
    ELSE
      x_msg_data      :=  SQLERRM||' AT BSC_SCORECARD_PUB.Create_Tab_Access_For_Resp ';
    END IF;
END Create_Tab_Access_For_Resp;


/************************************************************************************
************************************************************************************/

PROCEDURE Create_Tab_Access(
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS

l_Bsc_Tab_Entity_Rec  BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;
l_Responsibility_Key  FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE;
l_Comma_Sep_Resp_Key  VARCHAR2(32000):= NULL;
l_Tab_Short_Name      BSC_TABS_B.SHORT_NAME%TYPE := NULL;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Bsc_Tab_Entity_Rec := p_Bsc_Tab_Entity_Rec;

  BEGIN
   SELECT T.SHORT_NAME
   INTO   l_Tab_Short_Name
   FROM   BSC_TABS_B T
   WHERE  T.TAB_ID = l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_Tab_Short_Name := NULL;
  END;

  -- added for Bug#4563456
  l_Responsibility_Key := BSC_UTILITY.Get_Responsibility_Key;

  IF UPPER(l_Responsibility_Key) = 'BSC_DESIGNER' OR upper(l_Responsibility_Key) = 'BSC_MANAGER' OR l_Tab_Short_Name IS NOT NULL THEN
    l_Comma_Sep_Resp_Key := l_Comma_Sep_Resp_Key       ||','||
                            bsc_utility.c_BSC_Manager  ||','||
                            bsc_utility.c_BSC_DESIGNER ||','||
                            bsc_utility.c_BSC_PMD_USER ||','||
                            bsc_utility.c_BIS_BID_RESP ||','||
                            bsc_utility.c_BIS_DBI_ADMIN||','||
                            l_Responsibility_Key;
  ELSE
    l_Comma_Sep_Resp_Key :=  l_Responsibility_Key;
  END IF;

  Create_Tab_Access_For_Resp
  ( p_Resposibility_Key   => l_Comma_Sep_Resp_Key
  , p_commit              => p_commit
  , p_Bsc_Tab_Entity_Rec  => l_Bsc_Tab_Entity_Rec
  , x_return_status       => x_return_status
  , x_msg_count           => x_msg_count
  , x_msg_data            => x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
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
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Create_Tab_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Create_Tab_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Create_Tab_Access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Create_Tab_Access ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Create_Tab_Access;

/************************************************************************************
************************************************************************************/

procedure Create_Tab_Grants(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Tab_Entity_Rec  IN      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Tab_Entity_Rec        BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;

l_responsibility_key        varchar2(30);

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- set local record equal to the one passed.
  l_Bsc_Tab_Entity_Rec := p_Bsc_Tab_Entity_Rec;

  -- Insert the record for the current responsibility.
  BSC_SCORECARD_PVT.Create_Tab_Grants( p_commit
                                      ,l_Bsc_Tab_Entity_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Create_Tab_Grants ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Create_Tab_Grants ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Create_Tab_Grants ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Create_Tab_Grants ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Create_Tab_Grants;

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
  BSC_SCORECARD_PVT.Update_System_Time_Stamp( p_commit
                                             ,p_Bsc_Tab_Entity_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Update_System_Time_Stamp ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Update_System_Time_Stamp ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Update_System_Time_Stamp ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Update_System_Time_Stamp ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Update_System_Time_Stamp;

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
  BSC_SCORECARD_PVT.Update_Tab_Time_Stamp( p_commit
                                          ,p_Bsc_Tab_Entity_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Update_Tab_Time_Stamp ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Update_Tab_Time_Stamp ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_SCORECARD_PUB.Update_Tab_Time_Stamp ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_SCORECARD_PUB.Update_Tab_Time_Stamp ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Update_Tab_Time_Stamp;

/************************************************************************************   392
************************************************************************************/

function is_child_tab_of(
  p_child_tab_id        IN      number
 ,p_parent_tab_id       IN      number
) return varchar2 is

  l_tab_parent          number;
  l_tab_child           number;
  l_return_value        varchar2(10);

begin

        --DBMS_OUTPUT.PUT_LINE('Begin is_child_tab_of' );
        --DBMS_OUTPUT.PUT_LINE('  is_child_tab_of   p_child_tab_id  = ' || p_child_tab_id  );
        --DBMS_OUTPUT.PUT_LINE('  is_child_tab_of   p_parent_tab_id  = ' || p_parent_tab_id  );
        l_return_value := FND_API.G_FALSE;

    l_tab_child := p_child_tab_id;
        while l_tab_child is not null loop
       select PARENT_TAB_ID into l_tab_parent
         from  BSC_TABS_VL where TAB_ID = l_tab_child;
           --DBMS_OUTPUT.PUT_LINE('  is_child_tab_of   l_tab_parent  = ' || l_tab_parent  );

           if l_tab_parent is not null then
              if l_tab_parent = p_parent_tab_id then
                l_return_value := FND_API.G_TRUE;
                exit;
              end if;
           end if;
           l_tab_child := l_tab_parent;
        end loop;

        --DBMS_OUTPUT.PUT_LINE('is_child_tab_of x_return_status = ' || x_return_status );
        --DBMS_OUTPUT.PUT_LINE('End is_child_tab_of' );

        return l_return_value;

EXCEPTION
  WHEN OTHERS THEN
  return l_return_value;

end is_child_tab_of;
/**************************************************************************
Check_Tab_UserAccess_Func_Only checks the accessibility of the user
for the function passed, without taking into account the user responsibility
**************************************************************************/

FUNCTION Check_Tab_UserAccess_Func_Only(
  p_tab_id           IN     NUMBER
 ,p_user_name        IN     VARCHAR2
 ,p_user_access      IN     VARCHAR2
)return VARCHAR2 IS

l_isaccess      boolean ;
l_function_id   NUMBER;
l_count         NUMBER;
l_user_name     VARCHAR2(256);

BEGIN

    IF(p_user_name IS NULL) THEN
       l_user_name := FND_GLOBAL.USER_NAME;
    ELSE
       l_user_name := p_user_name;
    END IF;

    SELECT function_id INTO l_function_id
    FROM fnd_form_functions
    WHERE function_name= p_user_access;

    SELECT COUNT(GNT.grant_guid)
    INTO   l_count
    FROM   FND_GRANTS GNT,
           FND_OBJECTS b,
           FND_MENUS m,
           FND_MENU_ENTRIES e
    WHERE   GNT.PROGRAM_NAME = 'BSC_PMD_GRANTS'
    AND     b.OBJ_NAME = 'BSC_TAB'
    AND     GNT.OBJECT_ID = b.OBJECT_ID
    AND     GNT.INSTANCE_PK1_VALUE = to_char(p_tab_id)
    AND     ( GNT.GRANTEE_TYPE = 'USER' AND GNT.GRANTEE_KEY = UPPER(l_user_name))
    AND     GNT.START_DATE <= sysdate
    AND     (GNT.END_DATE IS NULL OR GNT.END_DATE >= sysdate )
    AND     m.MENU_ID = GNT.MENU_ID
    AND     e.MENU_ID = m.MENU_ID
    AND     e.function_id = l_function_id;

    IF(l_count = 0) THEN
        RETURN 'N';
    ELSE
        RETURN 'Y';
    END IF;
END Check_Tab_UserAccess_Func_Only;


/************************************************************************************
 Function    :   CheckTabViewAccess
 Description :   This fucntion will validate if particular user has BSC_SCORECARD_VIEWER
                 access.If yes then it return 'Y'.It means the user can only view
                 the scorecards and its contents. He cannot do any upadte/delete
                 operations.
 Input parameters    :    p_tab_id,p_user_name
 output      : 'Y' indicating user has View Acces otherwsie not.He comes under
               designer and administrator access. so he can do update , view and delete
               operations
***********************************************************************************/
FUNCTION Check_Tab_UserAccess(
  p_tab_id           IN     NUMBER
 ,p_user_name        IN     VARCHAR2
 ,p_user_access      IN     VARCHAR2
)return VARCHAR2 IS

l_isaccess      boolean ;
l_function_id   NUMBER;
l_count         NUMBER;
l_user_name     VARCHAR2(256);
l_resp_id       NUMBER;
l_resp_count    NUMBER:=0;

BEGIN
    -- Default the user name if not passed in.
    l_resp_id:= FND_GLOBAL.RESP_ID;
    IF(p_user_name IS NULL) THEN
       l_user_name := FND_GLOBAL.USER_NAME;
    ELSE
       l_user_name := p_user_name;
    END IF;

    SELECT function_id INTO l_function_id
    FROM fnd_form_functions
    WHERE function_name= p_user_access;

    SELECT COUNT(GNT.grant_guid)
    INTO   l_count
    FROM   FND_GRANTS GNT,
           FND_OBJECTS b,
           FND_MENUS m,
           FND_MENU_ENTRIES e
    WHERE   GNT.PROGRAM_NAME = 'BSC_PMD_GRANTS'
    AND     b.OBJ_NAME = 'BSC_TAB'
    AND     GNT.OBJECT_ID = b.OBJECT_ID
    AND     GNT.INSTANCE_PK1_VALUE = to_char(p_tab_id)
    AND     ( GNT.GRANTEE_TYPE = 'USER' AND GNT.GRANTEE_KEY = UPPER(l_user_name))
    AND     GNT.START_DATE <= sysdate
    AND     (GNT.END_DATE IS NULL OR GNT.END_DATE >= sysdate )
    AND     m.MENU_ID = GNT.MENU_ID
    AND     e.MENU_ID = m.MENU_ID
    AND     e.function_id = l_function_id;

   SELECT COUNT(1)
   INTO   l_resp_count
   FROM   bsc_user_tab_access
   WHERE  tab_id = p_tab_id
   AND    responsibility_id =l_resp_id
   AND   (SYSDATE BETWEEN NVL(start_date, SYSDATE) AND   NVL(end_date, SYSDATE));
    --Scorecard security is both at user , responsibility levels
    -- So while deciding to show up scorecard or not we need to consider responsibility also
    IF(l_count = 0 OR l_resp_count = 0) THEN
        RETURN 'N';
    ELSE
        RETURN 'Y';
    END IF;
END Check_Tab_UserAccess;

/***********************************************************************
Validate_Scorecard_Access ensures that if a scorecard is added in the
access list for a particular user, then all its parent scorecards have
atleast 'User' access for that scorecard.

It returns comma separated list of names for tabs which need to be added
in the user's access list.
************************************************************************/
PROCEDURE Validate_Scorecard_Access (
  p_tab_id           IN     NUMBER
 ,p_user_name        IN     VARCHAR2
 ,x_par_tab_name     OUT NOCOPY VARCHAR2
 ,x_par_tabname_list OUT NOCOPY VARCHAR2
  ) IS
l_parent_tab_id   bsc_tabs_vl.tab_id%TYPE;
l_parent_tab_id1  bsc_tabs_vl.tab_id%TYPE;
l_par_tabname_list  VARCHAR2(4000);
l_name              bsc_tabs_vl.name%TYPE;
BEGIN

  SELECT parent_tab_id,name
    INTO l_parent_tab_id, x_par_tab_name
    FROM bsc_tabs_vl
    WHERE tab_id = p_tab_id;

  WHILE (l_parent_tab_id IS NOT NULL) LOOP
    IF(Check_Tab_UserAccess_Func_Only(l_parent_tab_id, p_user_name, 'BSC_SCORECARD_ACCESS_VIEW' ) = 'N') THEN

      SELECT name
        INTO l_name
        FROM BSC_TABS_VL
        WHERE tab_id = l_parent_tab_id;

      IF (l_par_tabname_list IS NULL) THEN
        l_par_tabname_list := l_name;

      ELSE
        l_par_tabname_list := l_par_tabname_list ||', '|| l_name;

      END IF;
    END IF;

    l_parent_tab_id1 := l_parent_tab_id;

    SELECT parent_tab_id
      INTO l_parent_tab_id
      FROM bsc_tabs_b
      WHERE tab_id = l_parent_tab_id1;

  END LOOP;

  x_par_tabname_list := l_par_tabname_list;

END Validate_Scorecard_Access;


/***********************************************************************
Chk_Child_Scd_Has_Access returns list of all children of current
scorecard, for which the current user has access
************************************************************************/

FUNCTION Chk_Child_Scd_Has_Access(
  p_tab_id IN NUMBER
 ,p_user    IN VARCHAR2
  ) RETURN VARCHAR2 IS

  CURSOR c_chid_scorecards IS
    SELECT tab_id,name
    FROM bsc_tabs_vl
    WHERE parent_tab_id = p_tab_id;

  l_tablist_name  VARCHAR2(4000);
  l_return_tablist VARCHAR2(4000);

  BEGIN

  FOR cd IN c_chid_scorecards LOOP

    IF (BSC_SCORECARD_PUB.Check_Tab_UserAccess_Func_Only(cd.tab_id,p_user,'BSC_SCORECARD_ACCESS_VIEW') ='Y') THEN

      IF (l_tablist_name IS NULL) THEN
        l_tablist_name := cd.name ;
      ELSE
        l_tablist_name := l_tablist_name ||', '||cd.name;
      END IF;
    END IF;

    l_return_tablist := Chk_Child_Scd_Has_Access(cd.tab_id,p_user);

    IF (l_return_tablist IS NOT NULL) THEN

      IF (l_tablist_name IS NULL) THEN
        l_tablist_name := l_return_tablist ;
      ELSE
        l_tablist_name := l_tablist_name ||', '||l_return_tablist;
      END IF;
    END IF;
  END LOOP;

  RETURN l_tablist_name;

 END Chk_Child_Scd_Has_Access;

/********************************************************************
Validate_Scorecard_Revoke() ensures that if a scorecard access has to
be revoked, then there is no other scorecard which is a child of the
current scorecard for which the user still has access
*******************************************************************/

PROCEDURE Validate_Scorecard_Revoke (
  p_grant_guids      IN     VARCHAR2
 ,x_chd_tabname_list OUT NOCOPY VARCHAR2
  ) IS

l_grant_guids       VARCHAR2(32000);
l_grantee_key       FND_GRANTS.GRANTEE_KEY%TYPE;
l_tab_id            FND_GRANTS.INSTANCE_PK1_VALUE%TYPE;
l_single_grant_guid FND_GRANTS.GRANT_GUID%TYPE;
l_tablist_name      VARCHAR2(4000);
l_check_children    VARCHAR2(4000);
l_check_child       BSC_TABS_VL.NAME%TYPE;

BEGIN
  l_grant_guids := p_grant_guids;

  WHILE (BSC_SCORECARD_PVT.Is_More( p_grant_uids  =>  l_grant_guids
                 , p_grant_uid         =>  l_single_grant_guid)) LOOP

    SELECT grantee_key,instance_pk1_value
    INTO l_grantee_key, l_tab_id
    FROM fnd_grants
    WHERE grant_guid = l_single_grant_guid;

    l_check_children := Chk_Child_Scd_Has_Access(l_tab_id,l_grantee_key);

    IF (l_tablist_name IS NULL AND l_check_children IS NOT NULL) THEN
      l_tablist_name := l_check_children;

    ELSIF (l_check_children IS NOT NULL) THEN
      WHILE (BSC_SCORECARD_PVT.Is_More( p_grant_uids  =>  l_check_children
                                       , p_grant_uid         =>  l_check_child)) LOOP
        IF(INSTR(', '||l_tablist_name||', ',', '||l_check_child||', ') = 0) THEN
          l_tablist_name := l_tablist_name ||', '||l_check_child;

        END IF;
      END LOOP;
    END IF;
  END LOOP;

  x_chd_tabname_list := l_tablist_name;

END Validate_Scorecard_Revoke;
/*********************************************************************
 Function       :   is_Tab_Ordering_Enabled
 Description    :   This function will check if ordering of the scorecards
                    is enabled or not

1.Check if the p_tab_id is null.if yes then it means that it is called from
  the root VO of the Hgrid page.
  If null then do verify if any of the parent_tabs are having update access.
  if no then return false whcih will disbale the re-ordering button
  on the top of the VO.

2.IF not null then check if it having the child or not.
   if not then return empty it means re-ordering is not to be shown.
3. if it is the parent then verify if all the childs are having the update access.
   if all the childs are having the update access then only the reordering button should be enabled.
   else it will be disabled.
/********************************************************************/


FUNCTION is_Tab_Ordering_Enabled(
 p_tab_id        IN      NUMBER
,p_user_name     IN      VARCHAR2
)RETURN VARCHAR2 IS

CURSOR c_root_tab_ids IS
SELECT tab_id
FROM   BSC_TABS_VL
WHERE  PARENT_TAB_ID IS NULL;



CURSOR c_child_tab_ids IS
SELECT tab_id
FROM   BSC_TABS_VL
WHERE  PARENT_TAB_ID = p_tab_id;

l_istaborderEnabled     VARCHAR2(3);

BEGIN
     l_istaborderEnabled := 'N';

      IF(p_tab_id IS NULL) THEN
          FOR root_tabs IN c_root_tab_ids LOOP
             l_istaborderEnabled := BSC_SCORECARD_PUB.Check_Tab_UserAccess
                                    (
                                        p_tab_id        => root_tabs.tab_id
                                       ,p_user_name     => p_user_name
                                       ,p_user_access   => 'BSC_SCORECARD_ACCESS_UPDATE'
                                    );
              EXIT WHEN (l_istaborderEnabled<>'Y');
           END LOOP;
      ELSE
          FOR child_tabs IN c_child_tab_ids LOOP
              l_istaborderEnabled := BSC_SCORECARD_PUB.Check_Tab_UserAccess
                                     (
                                         p_tab_id        => child_tabs.tab_id
                                        ,p_user_name     => p_user_name
                                        ,p_user_access   => 'BSC_SCORECARD_ACCESS_UPDATE'
                                     );
              EXIT WHEN (l_istaborderEnabled<>'Y');
          END LOOP;
      END IF;

 RETURN l_istaborderEnabled;

END is_Tab_Ordering_Enabled;


end BSC_SCORECARD_PUB;

/
