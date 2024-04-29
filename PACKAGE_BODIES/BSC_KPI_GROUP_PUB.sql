--------------------------------------------------------
--  DDL for Package Body BSC_KPI_GROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPI_GROUP_PUB" as
/* $Header: BSCPKGPB.pls 120.0 2005/06/01 15:25:33 appldev noship $ */

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_KPI_GROUP_PUB';


--New procedure with OUT parameter
procedure Create_Kpi_Group(
  p_commit              IN             varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec   IN             BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_Bsc_Kpi_Group_Rec   OUT NOCOPY     BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Group_Rec            BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCCreateKPIGROUP;
  --  Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Bsc_Kpi_Group_Rec := p_Bsc_Kpi_Group_Rec;

  -- The action of assigning a KPI Group to a tab creates a new record (row) therefore
  -- we need to insert a new record.  But before we need to know whether this record is really
  -- a new Group, or just a new assignment.  If Tab Id is -1 or null then it is a new Kpi Group.
  if l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id is null or l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id = -1 then

    -- Check that this Kpi Group name does not exist.
    if l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name is not null then
      if BSC_SCORECARD_PVT.Validate_Kpi_Group(l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name) <> 0 then
        FND_MESSAGE.SET_NAME('BSC','BSC_KGROUP_NAME_EXISTS');
        FND_MESSAGE.SET_TOKEN('BSC_KGROUP', l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    end if;

    -- Bug #3236356
    SELECT (NVL(MAX(IND_GROUP_ID), 0) + 1)
    INTO   l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id
    FROM   BSC_TAB_IND_GROUPS_B;

    -- Give Default name to Kpi Group if Group name is originally null.
    if l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name is null then
      l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name := BSC_APPS.GET_LOOKUP_VALUE('BSC_UI_COMMON', 'GROUP')|| ' ' || l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id;
    end if;

    -- If help is null then set it equal to the name.
    if l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Help is null then
      --l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Help := l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name;
      --Fix Bug #2608683
      l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Help := l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Help;
    end if;

    -- This is a "Create_Procedure" therefore it does not assign the KPI group
    -- to any Tab. -1 is assigned as the tab_id, that's the BSC default.
    if l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id is null then
      l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id := -1;
    end if;

  end if;

  BSC_KPI_GROUP_PVT.Create_Kpi_Group( p_commit
                                     ,l_Bsc_Kpi_Group_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_Bsc_Kpi_Group_Rec := l_Bsc_Kpi_Group_Rec;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCCreateKPIGROUP;
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
        ROLLBACK TO BSCCreateKPIGROUP;
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
        ROLLBACK TO BSCCreateKPIGROUP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PUB.Create_Kpi_Group with parameter x_Bsc_Kpi_Group_Rec ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PUB.Create_Kpi_Group with parameter x_Bsc_Kpi_Group_Rec ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCCreateKPIGROUP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PUB.Create_Kpi_Group with parameter x_Bsc_Kpi_Group_Rec ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PUB.Create_Kpi_Group with parameter x_Bsc_Kpi_Group_Rec ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Create_Kpi_Group;


/************************************************************************************
************************************************************************************/
--Modified procedure without OUT parameter
procedure Create_Kpi_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec   IN  BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Group_Rec            BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;
l_Bsc_Kpi_Group_Rec_Out        BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_Bsc_Kpi_Group_Rec := p_Bsc_Kpi_Group_Rec;

  -- Call the create kpi group API with OUT parameter for kpi group record.
  BSC_KPI_GROUP_PUB.Create_Kpi_Group( p_commit => p_commit
                     ,p_Bsc_Kpi_Group_Rec => l_Bsc_Kpi_Group_Rec
                     ,x_Bsc_Kpi_Group_Rec => l_Bsc_Kpi_Group_Rec_Out
                                     ,x_return_status => x_return_status
                                     ,x_msg_count => x_msg_count
                                     ,x_msg_data => x_msg_data);
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
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PUB.Create_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PUB.Create_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PUB.Create_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PUB.Create_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Create_Kpi_Group;


/************************************************************************************
************************************************************************************/
--new procedure. Initializing the kpi group record.
procedure Initialize_Kpi_Group_Rec(
  p_Bsc_Kpi_Group_Rec   IN            BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_Bsc_Kpi_Group_Rec   OUT NOCOPY    BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY    varchar2
 ,x_msg_count           OUT NOCOPY    number
 ,x_msg_data            OUT NOCOPY    varchar2
) is

begin
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  x_Bsc_Kpi_Group_Rec := p_Bsc_Kpi_Group_Rec;

  -- set some default values.
  x_Bsc_Kpi_Group_Rec.Bsc_Csf_Id := 0;
  x_Bsc_Kpi_Group_Rec.Bsc_Group_Height := 1000;
  x_Bsc_Kpi_Group_Rec.Bsc_Group_Width := 2000;
  x_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Type := 0;
  x_Bsc_Kpi_Group_Rec.Bsc_Language := 'US';
  x_Bsc_Kpi_Group_Rec.Bsc_Left_Position_In_Tab := 1380;
  x_Bsc_Kpi_Group_Rec.Bsc_Name_Justif_In_Tab := 0;
  x_Bsc_Kpi_Group_Rec.Bsc_Name_Pos_In_Tab := 1;
  x_Bsc_Kpi_Group_Rec.Bsc_Source_Language := 'US';
  x_Bsc_Kpi_Group_Rec.Bsc_Top_Position_In_Tab := 0;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data :=  x_msg_data||' -> BSC_KPI_GROUP_PUB.Initialize_Kpi_Group_Rec ';
        ELSE
            x_msg_data :=  SQLERRM||' at BSC_KPI_GROUP_PUB.Initialize_Kpi_Group_Rec ';
        END IF;
        RAISE;
end Initialize_Kpi_Group_Rec;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Kpi_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec  IN      BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_Bsc_Kpi_Group_Rec  IN OUT NOCOPY      BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_KPI_GROUP_PVT.Retrieve_Kpi_Group( p_commit
                                       ,p_Bsc_Kpi_Group_Rec
                                       ,x_Bsc_Kpi_Group_Rec
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
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PUB.Retrieve_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PUB.Retrieve_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PUB.Retrieve_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PUB.Retrieve_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

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

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCUpdateKPIGROUP;
  BSC_KPI_GROUP_PVT.Update_Kpi_Group( p_commit
                                     ,p_Bsc_Kpi_Group_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCUpdateKPIGROUP;
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
        ROLLBACK TO BSCUpdateKPIGROUP;
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
        ROLLBACK TO BSCUpdateKPIGROUP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PUB.Update_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PUB.Update_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCUpdateKPIGROUP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PUB.Update_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PUB.Update_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Update_Kpi_Group;

/************************************************************************************
************************************************************************************/

procedure Delete_Kpi_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Bsc_Kpi_Group_Rec  IN      BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Kpi_Group_Rec     BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCDeleteKPIGROUP;
  l_Bsc_Kpi_Group_Rec := p_Bsc_Kpi_Group_Rec;

  -- Get the Group name.
  -- Aditya, changed to VL Table for bug 2796033
  select distinct(name)
    into l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name
    from BSC_TAB_IND_GROUPS_VL
   where ind_group_id = l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id;


  BSC_KPI_GROUP_PVT.Delete_Kpi_Group( p_commit
                                     ,l_Bsc_Kpi_Group_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCDeleteKPIGROUP;
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
        ROLLBACK TO BSCDeleteKPIGROUP;
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
        ROLLBACK TO BSCDeleteKPIGROUP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PUB.Delete_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PUB.Delete_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCDeleteKPIGROUP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_KPI_GROUP_PUB.Delete_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_GROUP_PUB.Delete_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Delete_Kpi_Group;

/************************************************************************************
************************************************************************************/

end BSC_KPI_GROUP_PUB;

/
