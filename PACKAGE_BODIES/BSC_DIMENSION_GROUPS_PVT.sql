--------------------------------------------------------
--  DDL for Package Body BSC_DIMENSION_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DIMENSION_GROUPS_PVT" as
/* $Header: BSCVDMGB.pls 120.0 2005/06/01 14:37:31 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCVDMGB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 9, 2001                                                 |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 |          Private Body version.                                                       |
 |          This package creates a Dimension Group.                                     |
 |                                                                                      |
 | History:                                                                             |
 | 04-MAR-2003 PAJOHRI  MLS Bug #2721899                                                |
 |                        Changed BSC_SYS_DIM_GROUPS_TL to BSC_SYS_DIM_GROUPS_VL in     |
 |                        select query.                                                 |
 | 29-MAY-03  All Enhancement Phase I- Functions user group short_name if no id         |
 | 07-JUN-03  mahrao Modified for ALL enhancement                                       |
 | 13-JUN-03  ADEULGAO modified for BUG# 2878840                                        |
 | 13-JUN-03  ADEULGAO modified procedure Create_Dimension_Group for BUG# 2878840       |
 | 14-JUN-03  mahrao   Added Translate_dimesnsion_group procedure                       |
 | 17-JUL-03  mahrao   Modified Translate_dimesnsion_group procedure                    |
 |                     as part of forward porting of ALL enhancement to BSC 5.1         |
 |                     Modified Retrieve_Dim_Group procedure                            |
 |                     as part of forward porting of ALL enhancement to BSC 5.1         |
 | 29-OCT-2003 mahrao  bug#3209967 Added a column to bsc_sys_dim_levels_by_group        |
 | 17-NOV-2003 PAJOHRI  Bug #3232366                                                    |
 | 17-NOV-2003 ADRAO    Bug #3236356 - Removed comments which has Validate_Value()      |
 | 30-Jul-04   rpenneru  Modified for enhancemen#3748519                                |
 | 13-Oct-04   rpenneru  Modified for bug#3945655                                       |
 | 21-DEC-04   vtulasi   Modified for bug#4045278 - Addtion of LUD                      |
 | 01-FEB-05   hengliu	 Modified for bug#4104065 - WHERE_CLAUSE can be null			|
 +======================================================================================+
*/
G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_DIMENSION_GROUPS_PVT';
g_db_object                             varchar2(30) := null;

--
/**********************************************************************************/
FUNCTION Validate_Dim_Group_Id(
 p_dim_group_id IN NUMBER
) RETURN NUMBER
IS
  l_count NUMBER := 0;
BEGIN

  SELECT count(dim_group_id)
    INTO l_count
    FROM BSC_SYS_DIM_GROUPS_VL
    WHERE dim_group_id = p_dim_group_id;

  RETURN l_count;
EXCEPTION
  WHEN OTHERS THEN
  RETURN l_count;
END Validate_Dim_Group_Id;
/**********************************************************************************/
procedure Retrieve_Dim_Group(
  p_Dim_Grp_Rec         IN             BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_Dim_Grp_Rec         OUT NOCOPY     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
);
--:     This procedure is used to Create a Dimension Group.  This is the entry point
--:     for the API for the Dimension Group entity.
--:     This procedure is part of the Dimension Group API.

procedure Create_Dimension_Group(
  p_commit              IN  varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Grp_Rec           BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;

l_count                     number;
l_dim_group_short_name      varchar2(40);
l_dim_level_short_name      varchar2(30);

begin
  SAVEPOINT CreateBSCDimGrpPVT;
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Validate Group Id does not exist.
  if p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id is not null then
    l_count := BSC_DIMENSION_GROUPS_PVT.Validate_Dim_Group_Id(p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id);
    if l_count <> 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_GROUP_ID_EXISTS');
      FND_MESSAGE.SET_TOKEN('BSC_GROUP_ID', p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_GROUP_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_GROUP_ID', p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Dim_Grp_Rec := p_Dim_Grp_Rec;

  -- Validate if this Group already exists, if it does not then create it and assign
  -- the current dimension to the group, if the group already exists then just assign
  -- the dimension level to it.
   --if BSC_DIMENSION_LEVELS_PVT.Validate_Dim_Group(l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name) < 1 then

    -- Get the next ID value for the current group.
    -- Bug#2878840

    g_db_object := 'BSC_SYS_DIM_GROUPS_TL';

    -- PMD
    if l_Dim_Grp_Rec.Bsc_Created_By is null then
       l_Dim_Grp_Rec.Bsc_Created_By := 0;
    end if;

    if l_Dim_Grp_Rec.Bsc_Last_Updated_By is null then
      l_Dim_Grp_Rec.Bsc_Last_Updated_By := 0;
    end if;
    -- PMD

    l_Dim_Grp_Rec.Bsc_Last_Update_Date := NVL(p_Dim_Grp_Rec.Bsc_Last_Update_Date, SYSDATE);
    -- Insert pertaining values into table bsc_sys_dim_groups_tl.
    insert into BSC_SYS_DIM_GROUPS_TL( dim_group_id
                                      ,language
                                      ,source_lang
                                      ,name
                                      ,short_name
                                      ,created_by
                                      ,creation_date
                                      ,last_updated_by
                                      ,last_update_date
                                      ,last_update_login)
                               select  l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id
                                      ,L.LANGUAGE_CODE
                                      ,userenv('LANG')
                                      ,l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name
                                      ,l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name
                                      ,l_Dim_Grp_Rec.Bsc_Created_By -- PMD
                                      ,l_Dim_Grp_Rec.Bsc_Last_Update_Date  -- PMD
                                      ,l_Dim_Grp_Rec.Bsc_Last_Updated_By  -- PMD
                                      ,l_Dim_Grp_Rec.Bsc_Last_Update_Date  -- PMD
                                      ,l_Dim_Grp_Rec.Bsc_Last_Update_Login  -- PMD
                                 from FND_LANGUAGES L
                                where L.INSTALLED_FLAG in ('I', 'B')
                                  and not exists
                                      (select NULL
                                         from BSC_SYS_DIM_GROUPS_TL T
                                        where T.dim_group_id = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id
                                          and T.LANGUAGE = L.LANGUAGE_CODE);

    if (p_commit = FND_API.G_TRUE) then
      commit;
    end if;

  --end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCDimGrpPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCDimGrpPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCDimGrpPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Create_Dimension_Group ';
        ELSE
            x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Create_Dimension_Group '||SQLERRM;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCDimGrpPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        if (SQLCODE = -01400) then
          FND_MESSAGE.SET_NAME('BSC','BSC_TABLE_NULL_VALUE');
          FND_MESSAGE.SET_TOKEN('BSC_OBJECT', g_db_object);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Create_Dimension_Group ';
        ELSE
            x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Create_Dimension_Group '||SQLERRM;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Dimension_Group;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Dimension_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_Dim_Grp_Rec         IN OUT NOCOPY     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  g_db_object := 'Retrieve_Dimension_Group';
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  select distinct name
    into x_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name
    from BSC_SYS_DIM_GROUPS_VL
   where dim_group_id = p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Retrieve_Dimension_Group ';
        ELSE
            x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Retrieve_Dimension_Group '||SQLERRM;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Retrieve_Dimension_Group ';
        ELSE
            x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Retrieve_Dimension_Group '||SQLERRM;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Dimension_Group;

/************************************************************************************
************************************************************************************/

procedure Update_Dimension_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count                         number;
l_Dim_Grp_Rec           BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;

CURSOR c_dim_lvls_by_group (p_grp_short_name VARCHAR2)
IS
  SELECT dim_group_id
  FROM   BSC_SYS_DIM_GROUPS_TL
  WHERE SHORT_NAME = p_grp_short_name;

begin
  SAVEPOINT UpdateBSCDimGrpPVT;
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Dim_Grp_Rec := p_Dim_Grp_Rec;

  -- Check that valid dimension group id was entered.
  if p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id is not null then
    l_count := BSC_DIMENSION_GROUPS_PVT.Validate_Dim_Group_Id(p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_ID');
      FND_MESSAGE.SET_TOKEN('BSC_GROUP_ID', p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
     -- if id is null then check for short name name is not null
  elsif (l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name is not null) then
      IF (c_dim_lvls_by_group%ISOPEN) THEN
        CLOSE c_dim_lvls_by_group;
      END IF;
      OPEN c_dim_lvls_by_group(l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name);
      FETCH c_dim_lvls_by_group INTO l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id;
      IF (c_dim_lvls_by_group%NOTFOUND) THEN
         FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_SHORT_NAME');
         FND_MESSAGE.SET_TOKEN('BSC_GROUP_SHORT_NAME',l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_dim_lvls_by_group;
  else
       FND_MESSAGE.SET_NAME('BSC','BSC_NO_GROUP_ID_ENTERED');
       FND_MESSAGE.SET_TOKEN('BSC_GROUP_ID', l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
  end if;

  -- In this case there is only one column that may be updated, therefore there is no
  -- retrieval of previous values.

  -- For PMD, we need to update the WHO Columns appropriately
  -- PMD
  IF p_Dim_Grp_Rec.Bsc_Last_Updated_By IS NULL THEN -- Cannot update p_Dim_Grp_Rec
      l_Dim_Grp_Rec.Bsc_Last_Updated_By := FND_GLOBAL.USER_ID;
  END IF;

  IF p_Dim_Grp_Rec.Bsc_Last_Update_Login IS NULL THEN
     l_Dim_Grp_Rec.Bsc_Last_Update_Login := FND_GLOBAL.LOGIN_ID;
  END IF;
  -- PMD

  l_Dim_Grp_Rec.Bsc_Last_Update_Date := NVL(p_Dim_Grp_Rec.Bsc_Last_Update_Date, SYSDATE);
  IF (p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name IS NOT NULL) THEN
      update BSC_SYS_DIM_GROUPS_TL
         set name = p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name
            ,source_lang = userenv('LANG')
            ,last_updated_by = l_Dim_Grp_Rec.Bsc_Last_Updated_By
            ,last_update_date = l_Dim_Grp_Rec.Bsc_Last_Update_Date
            ,last_update_login = p_Dim_Grp_Rec.Bsc_Last_Update_Login
       where dim_group_id = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id
         and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  END IF;
  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_dim_lvls_by_group%ISOPEN) THEN
            CLOSE c_dim_lvls_by_group;
        END IF;
        ROLLBACK TO UpdateBSCDimGrpPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_dim_lvls_by_group%ISOPEN) THEN
            CLOSE c_dim_lvls_by_group;
        END IF;
        ROLLBACK TO UpdateBSCDimGrpPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        IF (c_dim_lvls_by_group%ISOPEN) THEN
            CLOSE c_dim_lvls_by_group;
        END IF;
        ROLLBACK TO UpdateBSCDimGrpPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Update_Dimension_Group ';
        ELSE
            x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Update_Dimension_Group '||SQLERRM;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        IF (c_dim_lvls_by_group%ISOPEN) THEN
            CLOSE c_dim_lvls_by_group;
        END IF;
        ROLLBACK TO UpdateBSCDimGrpPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Update_Dimension_Group ';
        ELSE
            x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Update_Dimension_Group '||SQLERRM;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Dimension_Group;

/************************************************************************************
************************************************************************************/

procedure Delete_Dimension_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Grp_Rec                           BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;

l_count                 number;

CURSOR c_dim_lvls_by_group (p_grp_short_name VARCHAR2)
IS
  SELECT dim_group_id
  FROM   BSC_SYS_DIM_GROUPS_TL
  WHERE SHORT_NAME = p_grp_short_name;

begin
  SAVEPOINT DeleteBSCDimGrpPVT;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Dim_Grp_Rec := p_Dim_Grp_Rec;

  if l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id is not null then
    l_count := BSC_DIMENSION_GROUPS_PVT.Validate_Dim_Group_Id(l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_ID');
      FND_MESSAGE.SET_TOKEN('BSC_GROUP_ID', l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
   -- if id is null then check that short name is not null
  elsif (l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name is not null) then
      IF (c_dim_lvls_by_group%ISOPEN) THEN
        CLOSE c_dim_lvls_by_group;
      END IF;
      OPEN c_dim_lvls_by_group(l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name);
      FETCH c_dim_lvls_by_group INTO l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id;
      IF (c_dim_lvls_by_group%NOTFOUND) THEN
         FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_SHORT_NAME');
         FND_MESSAGE.SET_TOKEN('BSC_GROUP_SHORT_NAME',l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_dim_lvls_by_group;
    else
       -- if id and shortname both are null then check that name is not null
       if l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name is not null then
         select count(dim_group_id)
      into l_count
      from BSC_SYS_DIM_GROUPS_TL
          where name = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name;
         if l_count = 0 then
       FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_NAME');
       FND_MESSAGE.SET_TOKEN('BSC_GROUP_NAME', l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
         else -- get id for this name
       select distinct dim_group_id
         into l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id
         from BSC_SYS_DIM_GROUPS_VL
         where name = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name;
         end if;
       else
         FND_MESSAGE.SET_NAME('BSC','BSC_NO_GROUP_NAME_ENTERED');
         FND_MESSAGE.SET_TOKEN('BSC_NO_GROUP', l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       end if;
  end if;

  -- If there are no more dimensions assigned to this group then the group
  -- can be deleted.
  select count(dim_group_id)
    into l_count
    from BSC_SYS_DIM_LEVELS_BY_GROUP
   where dim_group_id = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id;
  if l_count = 0 then
    delete from BSC_SYS_DIM_GROUPS_TL
     where dim_group_id = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id;
  end if;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_dim_lvls_by_group%ISOPEN) THEN
            CLOSE c_dim_lvls_by_group;
        END IF;
        ROLLBACK TO DeleteBSCDimGrpPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_dim_lvls_by_group%ISOPEN) THEN
            CLOSE c_dim_lvls_by_group;
        END IF;
        ROLLBACK TO DeleteBSCDimGrpPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        IF (c_dim_lvls_by_group%ISOPEN) THEN
            CLOSE c_dim_lvls_by_group;
        END IF;
        ROLLBACK TO DeleteBSCDimGrpPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Delete_Dimension_Group ';
        ELSE
            x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Delete_Dimension_Group '||SQLERRM;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        IF (c_dim_lvls_by_group%ISOPEN) THEN
            CLOSE c_dim_lvls_by_group;
        END IF;
        ROLLBACK TO DeleteBSCDimGrpPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Delete_Dimension_Group ';
        ELSE
            x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Delete_Dimension_Group '||SQLERRM;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
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

l_Dim_Grp_Rec                   BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;

l_count                         number;

CURSOR c_dim_lvls_by_group (p_grp_short_name VARCHAR2)
IS
  SELECT dim_group_id
  FROM   BSC_SYS_DIM_GROUPS_TL
  WHERE SHORT_NAME = p_grp_short_name;

begin
  SAVEPOINT CreateBSCDimLevInGrpPVT;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Dim_Grp_Rec := p_Dim_Grp_Rec;

  -- Check that the group id is valid or that the name is valid.
  if l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id is not null then
    l_count := BSC_DIMENSION_GROUPS_PVT.Validate_Dim_Group_Id(l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_ID');
      FND_MESSAGE.SET_TOKEN('BSC_GROUP_ID', l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
    -- if id is null then check that short name is not null
  elsif l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name is not null then
       IF (c_dim_lvls_by_group%ISOPEN) THEN
        CLOSE c_dim_lvls_by_group;
      END IF;
      OPEN c_dim_lvls_by_group(l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name);
      FETCH c_dim_lvls_by_group INTO l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id;
      IF (c_dim_lvls_by_group%NOTFOUND) THEN
         FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_SHORT_NAME');
         FND_MESSAGE.SET_TOKEN('BSC_GROUP_SHORT_NAME',l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_dim_lvls_by_group;
    else
        -- if id and short name is null then check that name is not null
       if l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name is not null then
         select count(dim_group_id)
           into l_count
           from BSC_SYS_DIM_GROUPS_TL
           where name = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name;
         if l_count = 0 then
           FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_NAME');
           FND_MESSAGE.SET_TOKEN('BSC_GROUP_NAME', l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         else -- get id for this name
           select distinct dim_group_id
             into l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id
             from BSC_SYS_DIM_GROUPS_VL
            where name = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name;
         end if;
       else
         FND_MESSAGE.SET_NAME('BSC','BSC_NO_GROUP_NAME_ENTERED');
         FND_MESSAGE.SET_TOKEN('BSC_NO_GROUP', l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       end if;
  end if;

  -- Check Dimension level id is valid.
  if l_Dim_Grp_Rec.Bsc_Level_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Dim_Level_Id(l_Dim_Grp_Rec.Bsc_Level_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_LEVEL_ID');
      FND_MESSAGE.SET_TOKEN('BSC_LEVEL_ID', l_Dim_Grp_Rec.Bsc_Level_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_LEVEL_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_LEVEL_ID', l_Dim_Grp_Rec.Bsc_Level_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;



  -- Determine if dimension is already part of the dimension group.
  select count(*)
    into l_count
    from BSC_SYS_DIM_LEVELS_BY_GROUP
   where dim_group_id = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id
     and dim_level_id = l_Dim_Grp_Rec.Bsc_Level_Id;

  -- If the dimension does not belong to the group yet assign it.
  if l_count = 0 then

    -- Get the number of dimensions in the dimension group and add to it one.
    -- This is used for the index for the dimension being added.
    IF (l_Dim_Grp_Rec.Bsc_Dim_Level_Index IS NULL) THEN
      select  NVL((MAX(dim_level_index) + 1), 0)
        into l_Dim_Grp_Rec.Bsc_Dim_Level_Index
        from BSC_SYS_DIM_LEVELS_BY_GROUP
      where dim_group_id = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id;
    END IF;

    g_db_object := 'BSC_SYS_DIM_LEVELS_BY_GROUP';

    -- Insert pertaining values into table bsc_sys_dim_levels_by_group.
    --Reminder:  Hard coded values, need to get the source.
    insert into BSC_SYS_DIM_LEVELS_BY_GROUP( dim_group_id
                                            ,dim_level_id
                                            ,dim_level_index
                                            ,total_flag
                                            ,comparison_flag
                                            ,filter_column
                                            ,filter_value
                                            ,default_value
                                            ,default_type
                                            ,parent_in_total
                                            ,no_items
                        ,where_clause)
                                     values( l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id
                                            ,l_Dim_Grp_Rec.Bsc_Level_Id
                                            ,l_Dim_Grp_Rec.Bsc_Dim_Level_Index
                                            ,l_Dim_Grp_Rec.Bsc_Group_Level_Total_Flag
                                            ,l_Dim_Grp_Rec.Bsc_Group_Level_Comp_Flag
                                            ,l_Dim_Grp_Rec.Bsc_Group_Level_Filter_Col
                                            ,l_Dim_Grp_Rec.Bsc_Group_Level_Filter_Value
                                            ,l_Dim_Grp_Rec.Bsc_Group_Level_Default_Value
                                            ,l_Dim_Grp_Rec.Bsc_Group_Level_Default_Type
                                            ,l_Dim_Grp_Rec.Bsc_Group_Level_Parent_In_Tot
                                            ,l_Dim_Grp_Rec.Bsc_Group_Level_No_Items
                        ,l_Dim_Grp_Rec.Bsc_Group_Level_Where_Clause);

    if (p_commit = FND_API.G_TRUE) then
      commit;
    end if;

  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCDimLevInGrpPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCDimLevInGrpPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCDimLevInGrpPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Create_Dim_Levels_In_Group ';
        ELSE
            x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Create_Dim_Levels_In_Group '||SQLERRM;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCDimLevInGrpPVT;
        if (SQLCODE = -01400) then
          FND_MESSAGE.SET_NAME('BSC','BSC_TABLE_NULL_VALUE');
          FND_MESSAGE.SET_TOKEN('BSC_OBJECT', g_db_object);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Create_Dim_Levels_In_Group ';
        ELSE
            x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Create_Dim_Levels_In_Group '||SQLERRM;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Dim_Levels_In_Group;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Dim_Levels_In_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_Dim_Grp_Rec         IN OUT NOCOPY     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;
  g_db_object := 'Retrieve_Dim_Levels_In_Group';
-- Code added for ALL start here
-- PMF passes dimension level short name and dimension short name.
-- dim_level_id is found from bsc_sys_dim_levels_tl table.
-- As SHORT_NAME column that's being added to bsc_sys_dim_groups_tl table
-- is not populated, for ALL enhancement, query on BSC_SYS_DIM_LEVELS_BY_GROUP
-- is based only on dim_level_id.
-- This is required for PMF ALL enhancement (phase1).
    SELECT DISTINCT dim_level_index
                   ,total_flag
                   ,comparison_flag
                   ,filter_column
                   ,filter_value
                   ,default_value
                   ,default_type
                   ,parent_in_total
                   ,no_items
           ,where_clause
    INTO   x_Dim_Grp_Rec.Bsc_Dim_Level_Index
          ,x_Dim_Grp_Rec.Bsc_Group_Level_Total_Flag
          ,x_Dim_Grp_Rec.Bsc_Group_Level_Comp_Flag
          ,x_Dim_Grp_Rec.Bsc_Group_Level_Filter_Col
          ,x_Dim_Grp_Rec.Bsc_Group_Level_Filter_Value
          ,x_Dim_Grp_Rec.Bsc_Group_Level_Default_Value
          ,x_Dim_Grp_Rec.Bsc_Group_Level_Default_Type
          ,x_Dim_Grp_Rec.Bsc_Group_Level_Parent_In_Tot
          ,x_Dim_Grp_Rec.Bsc_Group_Level_No_Items
      ,x_Dim_Grp_Rec.Bsc_Group_Level_Where_Clause
    FROM  BSC_SYS_DIM_LEVELS_BY_GROUP
    WHERE dim_group_id = p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id
    AND   dim_level_id = p_Dim_Grp_Rec.Bsc_Level_Id;
  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    FND_MSG_PUB.Initialize;
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_VALUE_FOUND');
    FND_MESSAGE.SET_TOKEN('BSC_OBJECT', g_db_object);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

end Retrieve_Dim_Levels_In_Group;

/************************************************************************************
************************************************************************************/

procedure Update_Dim_Levels_In_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Grp_Rec                   BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
l_Dim_Grp_Rec_in  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;

l_count                         number;

CURSOR c_dim_lvls_by_group (p_grp_short_name VARCHAR2)
IS
  SELECT dim_group_id
  FROM   BSC_SYS_DIM_GROUPS_TL
  WHERE SHORT_NAME = p_grp_short_name;

begin
  SAVEPOINT UpdateBSCDimLevInGrpPVT;
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Dim_Grp_Rec_in := p_Dim_Grp_Rec;
  -- Check that the group id is valid or that the name is valid.
    if p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id is not null then
    l_count := BSC_DIMENSION_GROUPS_PVT.Validate_Dim_Group_Id(p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_ID');
      FND_MESSAGE.SET_TOKEN('BSC_GROUP_ID', p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
    -- if id is null then check that short name is not null
  elsif p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name is not null then
       IF (c_dim_lvls_by_group%ISOPEN) THEN
        CLOSE c_dim_lvls_by_group;
      END IF;
      OPEN c_dim_lvls_by_group(l_Dim_Grp_Rec_in.Bsc_Dim_Level_Group_Short_Name);
      FETCH c_dim_lvls_by_group INTO l_Dim_Grp_Rec_in.Bsc_Dim_Level_Group_Id;
      IF (c_dim_lvls_by_group%NOTFOUND) THEN
         FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_SHORT_NAME');
         FND_MESSAGE.SET_TOKEN('BSC_GROUP_SHORT_NAME',l_Dim_Grp_Rec_in.Bsc_Dim_Level_Group_Short_Name);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_dim_lvls_by_group;
    else
        -- if id is null then check that name is not null
       if p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name is not null then
         select count(dim_group_id)
          into l_count
          from BSC_SYS_DIM_GROUPS_TL
          where name = p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name;
         if l_count = 0 then
           FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_NAME');
           FND_MESSAGE.SET_TOKEN('BSC_GROUP_NAME', p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         else -- get id for this name
           select distinct dim_group_id
            into l_Dim_Grp_Rec_in.Bsc_Dim_Level_Group_Id
            from BSC_SYS_DIM_GROUPS_VL
            where name = p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name;
         end if;
       else
         FND_MESSAGE.SET_NAME('BSC','BSC_NO_GROUP_NAME_ENTERED');
         FND_MESSAGE.SET_TOKEN('BSC_NO_GROUP', p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       end if;
  end if;

  -- Check Dimension level id is valid.
  if p_Dim_Grp_Rec.Bsc_Level_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Dim_Level_Id(p_Dim_Grp_Rec.Bsc_Level_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_LEVEL_ID');
      FND_MESSAGE.SET_TOKEN('BSC_LEVEL_ID', p_Dim_Grp_Rec.Bsc_Level_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_LEVEL_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_LEVEL_ID', p_Dim_Grp_Rec.Bsc_Level_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Dim_Levels_In_Group( p_commit
                               ,l_Dim_Grp_Rec_in
                               ,l_Dim_Grp_Rec
                               ,x_return_status
                               ,x_msg_count
                               ,x_msg_data);

  -- update LOCAL language ,source language, group id and level Id values with PASSED values.
  l_Dim_Grp_Rec.Bsc_Language := p_Dim_Grp_Rec.Bsc_Language;
  l_Dim_Grp_Rec.Bsc_Source_Language := p_Dim_Grp_Rec.Bsc_Source_Language;
  l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id := l_Dim_Grp_Rec_in.Bsc_Dim_Level_Group_Id;
  l_Dim_Grp_Rec.Bsc_Level_Id := l_Dim_Grp_Rec_in.Bsc_Level_Id;

  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Dim_Grp_Rec.Bsc_Dim_Level_Index is not null then
    l_Dim_Grp_Rec.Bsc_Dim_Level_Index := p_Dim_Grp_Rec.Bsc_Dim_Level_Index;
  end if;
  if p_Dim_Grp_Rec.Bsc_Group_Level_Total_Flag is not null then
    l_Dim_Grp_Rec.Bsc_Group_Level_Total_Flag := p_Dim_Grp_Rec.Bsc_Group_Level_Total_Flag;
  end if;
  if p_Dim_Grp_Rec.Bsc_Group_Level_Comp_Flag is not null then
    l_Dim_Grp_Rec.Bsc_Group_Level_Comp_Flag := p_Dim_Grp_Rec.Bsc_Group_Level_Comp_Flag;
  end if;
  if p_Dim_Grp_Rec.Bsc_Group_Level_Filter_Col is not null then
    l_Dim_Grp_Rec.Bsc_Group_Level_Filter_Col := p_Dim_Grp_Rec.Bsc_Group_Level_Filter_Col;
  end if;
  if p_Dim_Grp_Rec.Bsc_Group_Level_Filter_Value is not null then
    l_Dim_Grp_Rec.Bsc_Group_Level_Filter_Value := p_Dim_Grp_Rec.Bsc_Group_Level_Filter_Value;
  end if;
  if p_Dim_Grp_Rec.Bsc_Group_Level_Default_Value is not null then
    l_Dim_Grp_Rec.Bsc_Group_Level_Default_Value := p_Dim_Grp_Rec.Bsc_Group_Level_Default_Value;
  end if;
  if p_Dim_Grp_Rec.Bsc_Group_Level_Default_Type is not null then
    l_Dim_Grp_Rec.Bsc_Group_Level_Default_Type := p_Dim_Grp_Rec.Bsc_Group_Level_Default_Type;
  end if;
  if p_Dim_Grp_Rec.Bsc_Group_Level_Parent_In_Tot is not null then
    l_Dim_Grp_Rec.Bsc_Group_Level_Parent_In_Tot := p_Dim_Grp_Rec.Bsc_Group_Level_Parent_In_Tot;
  end if;
  if p_Dim_Grp_Rec.Bsc_Group_Level_No_Items is not null then
    l_Dim_Grp_Rec.Bsc_Group_Level_No_Items := p_Dim_Grp_Rec.Bsc_Group_Level_No_Items;
  end if;
  --Where_Clause can be null
  --if p_Dim_Grp_Rec.Bsc_Group_Level_Where_Clause is not null then
    l_Dim_Grp_Rec.Bsc_Group_Level_Where_Clause := p_Dim_Grp_Rec.Bsc_Group_Level_Where_Clause;
  --end if;

  update BSC_SYS_DIM_LEVELS_BY_GROUP
     set dim_level_index = l_Dim_Grp_Rec.Bsc_Dim_Level_Index
        ,total_flag = l_Dim_Grp_Rec.Bsc_Group_Level_Total_Flag
        ,comparison_flag = l_Dim_Grp_Rec.Bsc_Group_Level_Comp_Flag
        ,filter_column = l_Dim_Grp_Rec.Bsc_Group_Level_Filter_Col
        ,filter_value = l_Dim_Grp_Rec.Bsc_Group_Level_Filter_Value
        ,default_value = l_Dim_Grp_Rec.Bsc_Group_Level_Default_Value
        ,default_type = l_Dim_Grp_Rec.Bsc_Group_Level_Default_Type
        ,parent_in_total = l_Dim_Grp_Rec.Bsc_Group_Level_Parent_In_Tot
        ,no_items = l_Dim_Grp_Rec.Bsc_Group_Level_No_Items
    ,where_clause = l_Dim_Grp_Rec.Bsc_Group_Level_Where_Clause
   where dim_group_id = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id
     and dim_level_id = l_Dim_Grp_Rec.Bsc_Level_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateBSCDimLevInGrpPVT;
        CLOSE c_dim_lvls_by_group;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateBSCDimLevInGrpPVT;
        CLOSE c_dim_lvls_by_group;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateBSCDimLevInGrpPVT;
        CLOSE c_dim_lvls_by_group;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Update_Dim_Levels_In_Group ';
        ELSE
            x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Update_Dim_Levels_In_Group '||SQLERRM;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateBSCDimLevInGrpPVT;
        CLOSE c_dim_lvls_by_group;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Update_Dim_Levels_In_Group ';
        ELSE
            x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Update_Dim_Levels_In_Group '||SQLERRM;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Dim_Levels_In_Group;

/************************************************************************************
************************************************************************************/

procedure Delete_Dim_Levels_In_Group(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN      BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dim_Grp_Rec                   BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;

l_count                         number;

CURSOR c_dim_lvls_by_group (p_grp_short_name VARCHAR2)
IS
  SELECT dim_group_id
  FROM   BSC_SYS_DIM_GROUPS_TL
  WHERE SHORT_NAME = p_grp_short_name;

begin
  SAVEPOINT DeleteBSCDimLevInGrpPVT;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Dim_Grp_Rec := p_Dim_Grp_Rec;

  -- Check that the group id is valid or that the name is valid.
  if l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id is not null then
    l_count := BSC_DIMENSION_GROUPS_PVT.Validate_Dim_Group_Id(l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_ID');
      FND_MESSAGE.SET_TOKEN('BSC_GROUP_ID', l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
    -- if id is null then check for short name name is not null
  elsif l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name is not null then
       IF (c_dim_lvls_by_group%ISOPEN) THEN
        CLOSE c_dim_lvls_by_group;
      END IF;
      OPEN c_dim_lvls_by_group(l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name);
      FETCH c_dim_lvls_by_group INTO l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id;
      IF (c_dim_lvls_by_group%NOTFOUND) THEN
         FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_SHORT_NAME');
         FND_MESSAGE.SET_TOKEN('BSC_GROUP_SHORT_NAME',l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_dim_lvls_by_group;
    else
       -- if id and shortname both are null then check that name is not null
       if l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name is not null then
         select count(dim_group_id)
           into l_count
           from BSC_SYS_DIM_GROUPS_TL
           where name = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name;
         if l_count = 0 then
           FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_NAME');
           FND_MESSAGE.SET_TOKEN('BSC_GROUP_NAME', l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         else -- get id for this name
           select distinct dim_group_id
            into l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id
            from BSC_SYS_DIM_GROUPS_VL
            where name = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name;
         end if;
       else
         FND_MESSAGE.SET_NAME('BSC','BSC_NO_GROUP_NAME_ENTERED');
         FND_MESSAGE.SET_TOKEN('BSC_NO_GROUP', l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       end if;
  end if;

  -- Check Dimension level id is valid.
  if l_Dim_Grp_Rec.Bsc_Level_Id  is not null then
    l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Dim_Level_Id(l_Dim_Grp_Rec.Bsc_Level_Id);
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_LEVEL_ID');
      FND_MESSAGE.SET_TOKEN('BSC_LEVEL_ID', l_Dim_Grp_Rec.Bsc_Level_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;

     delete from BSC_SYS_DIM_LEVELS_BY_GROUP
      where dim_group_id = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id
       and dim_level_id = l_Dim_Grp_Rec.Bsc_Level_Id;
  else
     delete from BSC_SYS_DIM_LEVELS_BY_GROUP
      where dim_group_id = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id;
  end if;
  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        CLOSE c_dim_lvls_by_group;
        ROLLBACK TO DeleteBSCDimLevInGrpPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        CLOSE c_dim_lvls_by_group;
        ROLLBACK TO DeleteBSCDimLevInGrpPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        CLOSE c_dim_lvls_by_group;
        ROLLBACK TO DeleteBSCDimLevInGrpPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Delete_Dim_Levels_In_Group ';
        ELSE
            x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Delete_Dim_Levels_In_Group '||SQLERRM;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        CLOSE c_dim_lvls_by_group;
        ROLLBACK TO DeleteBSCDimLevInGrpPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Delete_Dim_Levels_In_Group ';
        ELSE
            x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Delete_Dim_Levels_In_Group '||SQLERRM;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Delete_Dim_Levels_In_Group;

/************************************************************************************
************************************************************************************/
/************************************************************************************
************************************************************************************/

/*-------------------------------------------------------------------------------------
  get_Dim_Group_Id:
                   Return the Dimension Group ID,  null is returned the Short Name Not exist
---------------------------------------------------------------------------------------*/
FUNCTION get_Dim_Group_Id(
   p_Short_Name IN VARCHAR2
) RETURN number IS
 v_Id number;

 BEGIN
  Select distinct DIM_GROUP_ID
    into v_Id
    from BSC_SYS_DIM_GROUPS_TL
    where SHORT_NAME = p_Short_Name;
 RETURN  v_Id;

 EXCEPTION
  WHEN OTHERS THEN
    RETURN null;
END get_Dim_Group_Id;

--
PROCEDURE Translate_Dimension_Group
( p_commit IN  VARCHAR2   := FND_API.G_FALSE
 ,p_Dim_Grp_Rec IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
) IS
  l_Dim_Grp_rec BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
BEGIN
  SAVEPOINT TranslateBSCDimGrpPVT;
  x_return_status:= FND_API.G_RET_STS_SUCCESS;

  Retrieve_Dim_Group(
    p_Dim_Grp_Rec => p_Dim_Grp_Rec
   ,x_Dim_Grp_Rec => l_Dim_Grp_rec
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_Dim_Grp_rec.Bsc_Dim_Level_Group_Name IS NOT NULL) THEN
    l_Dim_Grp_rec.Bsc_Dim_Level_Group_Name := p_Dim_Grp_rec.Bsc_Dim_Level_Group_Name;
  END IF;

  l_Dim_Grp_rec.Bsc_Last_Update_Date := NVL(p_Dim_Grp_Rec.Bsc_Last_Update_Date, SYSDATE);

  UPDATE bsc_sys_dim_groups_tl
  SET    name = l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name
        ,source_lang = userenv('LANG')
        ,last_updated_by = NVL(l_Dim_Grp_Rec.Bsc_Last_Updated_By, p_Dim_Grp_Rec.Bsc_Last_Updated_By)
        ,last_update_date = l_Dim_Grp_rec.Bsc_Last_Update_Date
        ,last_update_login = p_Dim_Grp_Rec.Bsc_Last_Update_Login
  WHERE short_name = p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name
  AND    userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO TranslateBSCDimGrpPVT;
    FND_MSG_PUB.Count_And_Get(
       p_encoded   => 'F'
      ,p_count     =>  x_msg_count
      ,p_data      =>  x_msg_data
    );
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO TranslateBSCDimGrpPVT;
    FND_MSG_PUB.Count_And_Get(
       p_encoded   => 'F'
      ,p_count     =>  x_msg_count
      ,p_data      =>  x_msg_data
    );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO TranslateBSCDimGrpPVT;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Translate_Dimension_Group ';
    ELSE
      x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Translate_Dimension_Group '||SQLERRM;
    END IF;
    RAISE;
  WHEN OTHERS THEN
    ROLLBACK TO TranslateBSCDimGrpPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Translate_Dimension_Group ';
    ELSE
      x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Translate_Dimension_Group '||SQLERRM;
    END IF;
    RAISE;

END Translate_Dimension_Group;

--====================================================================

procedure Retrieve_Dim_Group(
  p_Dim_Grp_Rec         IN         BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_Dim_Grp_Rec         OUT NOCOPY BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_msg_count           OUT NOCOPY NUMBER
 ,x_msg_data            OUT NOCOPY VARCHAR2
) is

begin
  x_return_status:= FND_API.G_RET_STS_SUCCESS;

  SELECT distinct name, dim_group_id, short_name
  INTO
    x_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name
    ,x_Dim_Grp_Rec.Bsc_Dim_Level_Group_Id
    ,x_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name
    FROM BSC_SYS_DIM_GROUPS_VL
    WHERE short_name = p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name;

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
      x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Retrieve_Dim_Group ';
    ELSE
      x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Retrieve_Dim_Group '||SQLERRM;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_DIMENSION_GROUPS_PVT.Retrieve_Dim_Group ';
    ELSE
      x_msg_data      := 'BSC_DIMENSION_GROUPS_PVT.Retrieve_Dim_Group '||SQLERRM;
    END IF;

END Retrieve_Dim_Group;



/*************************************************************************************

    API TO SYNC UP THE DIMENSION GROUPS LANGUAGE DATA FROM PMF TO BSC

*************************************************************************************/

procedure Translate_Dim_by_given_lang
( p_commit          IN  VARCHAR2  := FND_API.G_FALSE
, p_Dim_Grp_Rec     IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
)
IS

BEGIN

    SAVEPOINT  TransDimByLangBsc;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FND_MSG_PUB.Initialize;

    UPDATE BSC_SYS_DIM_GROUPS_TL
    SET  NAME              = p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name
        ,SOURCE_LANG       = p_Dim_Grp_Rec.Bsc_Source_Language
        ,LAST_UPDATE_DATE  = p_Dim_Grp_Rec.Bsc_Last_Update_Date
    WHERE SHORT_NAME    = p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name
    AND LANGUAGE        = p_Dim_Grp_Rec.Bsc_Language;

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO TransDimByLangBsc;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO TransDimByLangBsc;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO TransDimByLangBsc;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO TransDimByLangBsc;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
END Translate_Dim_by_given_lang;

/******************************************************************************/

end BSC_DIMENSION_GROUPS_PVT;

/
