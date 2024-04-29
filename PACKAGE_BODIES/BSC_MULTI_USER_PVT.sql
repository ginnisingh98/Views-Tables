--------------------------------------------------------
--  DDL for Package Body BSC_MULTI_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_MULTI_USER_PVT" as
/* $Header: BSCVMUFB.pls 120.0 2005/06/01 17:00:01 appldev noship $*/


procedure Apply_Multi_User_Env(
  p_obj_type            IN      varchar2
 ,p_obj_id              IN      number := 0
 ,p_obj_id2             IN      number := 0
 ,p_obj_id3		IN	number := 0
 ,p_obj_location        IN      varchar2 := 'DUMMY'
 ,p_obj_action          IN      varchar2
 ,p_time_stamp          IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_obj_action			varchar2(10) := null;
l_time_stamp			date;

begin

  FND_MSG_PUB.Initialize;

l_time_stamp := to_date(p_time_stamp, 'DD-MM-YYYY-HH24-MI-SS');

  x_return_status := null;

  if p_obj_type = 'TAB' and p_obj_action = 'LCK' then

    if p_obj_location = 'DETAILS' then
      -- Lock for Details Scorecard Screen.
     /* Tab_Details_Lock( p_obj_id
                       ,x_return_status
                       ,x_msg_count
                       ,x_msg_data);*/

      -- Set flag to check time stamp.
      l_obj_action := 'TST';

    elsif p_obj_location = 'DELETE' then
      -- Lock for Delete Screen.
      Tab_Delete_Lock( p_obj_id
                      ,x_return_status
                      ,x_msg_count
                      ,x_msg_data);

      -- Set flag to check time stamp.
      l_obj_action := 'TST';

    elsif p_obj_location = 'SELECT' then
      -- Lock for Select Scorecard Item Screen.
      Tab_Select_Items_Lock( p_obj_id
                            ,x_return_status
                            ,x_msg_count
                            ,x_msg_data);

      -- Set flag to check time stamp.
      l_obj_action := 'TST';

    end if;

  elsif p_obj_type = 'KPI' and p_obj_action = 'LCK' then

    if p_obj_location = 'ADDMEASURE' then

      Kpi_Lock( p_obj_id
               ,x_return_status
               ,x_msg_count
               ,x_msg_data);

      -- Set flag to check time stamp.
      l_obj_action := 'TST';

    elsif p_obj_location = 'OPTION' then

      Option_Lock( p_obj_id
                  ,p_obj_id2
                  ,p_obj_id3
                  ,x_return_status
                  ,x_msg_count
                  ,x_msg_data);

      -- Set flag to check time stamp.
      l_obj_action := 'TST';

    end if;

  elsif p_obj_type = 'SYSTEM' and p_obj_action = 'TST' then
    if p_obj_location = 'CREATE' then
      -- Time stamp check for Create Scorecard button.
      Check_System_Change( 'LOCK_SYSTEM'
                          ,l_time_stamp
                          ,x_msg_count
                          ,x_return_status
                          ,x_msg_data);
    end if;
  elsif p_obj_type = 'DIM_LEVEL' and p_obj_action = 'LCK' then

      Dim_Level_Lock( p_obj_id
               ,p_obj_location    /*  Short Name  */
               ,x_return_status
               ,x_msg_count
               ,x_msg_data);

  elsif p_obj_action = 'TST' then

    l_obj_action := 'TST';

  end if;

  if (l_obj_action = 'TST'  and x_return_status is null) then
    Have_Time_Stamps_Changed( p_obj_type
                             ,p_obj_id
                             ,l_time_stamp
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);
  end if;

  if x_return_status is null then
    x_return_status := 'S';
  end if;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

end Apply_Multi_User_Env;

/************************************************************************************
************************************************************************************/

procedure Have_Time_Stamps_Changed(
  p_obj_type		IN	varchar2
 ,p_obj_id		IN	number
 ,p_time_stamp		IN	date
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin


  if p_obj_type = 'TAB' then
    Check_Tab_Time_Stamp( p_obj_id
                         ,p_time_stamp
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data);
  elsif p_obj_type = 'KPI' then
    Check_Kpi_Time_Stamp( p_obj_id
                         ,p_time_stamp
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data);
  else
    RAISE FND_API.G_EXC_ERROR;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    FND_MSG_PUB.Initialize;
    --x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status := 'C';
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

end Have_Time_Stamps_Changed;

/************************************************************************************
************************************************************************************/

procedure Check_Tab_Time_Stamp(
  p_obj_id		IN	number
 ,p_time_stamp	 	IN	date
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_time_stamp			date;

begin

  select last_update_date
    into l_time_stamp
    from BSC_TABS_B
   where tab_id = p_obj_id;

  if l_time_stamp > p_time_stamp then
    RAISE FND_API.G_EXC_ERROR;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := 'C';
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := 'D';
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

end Check_Tab_Time_Stamp;

/************************************************************************************
************************************************************************************/

procedure Check_Kpi_Time_Stamp(
  p_obj_id		IN	number
 ,p_time_stamp		IN	date
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_time_stamp			date;

begin

  select last_update_date
    into l_time_stamp
    from BSC_KPIS_B
   where indicator = p_obj_id;

/*
  if l_time_stamp > p_time_stamp then
    RAISE FND_API.G_EXC_ERROR;
  end if;
*/
  if to_date(l_time_stamp, 'DD-MM-YYYY-HH24-MI-SS') > to_date(p_time_stamp, 'DD-MM-YYYY-HH24-MI-SS') then
    RAISE FND_API.G_EXC_ERROR;
  end if;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := 'C';
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := 'D';
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

end Check_Kpi_Time_Stamp;

/************************************************************************************
************************************************************************************/

procedure Check_System_Change(
  p_property_code       IN      varchar2
 ,p_time_stamp          IN      date
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_time_stamp                    date;

begin

  select last_update_date
    into l_time_stamp
    from BSC_SYS_INIT
   where property_code = p_property_code;

  if l_time_stamp > p_time_stamp then
    RAISE FND_API.G_EXC_ERROR;
  end if;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := 'C';
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

end Check_System_Change;

/************************************************************************************
************************************************************************************/

procedure Tab_Details_Lock(
  p_obj_id			number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

-- This procedure locks name for a given tab.
-- We lock name so no other "Details" nor "Delete" sessions access it.

l_dummy1		BSC_TABS_TL.NAME%TYPE;

begin

  select name
    into l_dummy1
    from BSC_TABS_TL
   where tab_id = p_obj_id
     and rownum < 2
  for update nowait;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
--    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
--    rollback;
    x_return_status := 'D';
--    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
--    rollback;
    if SQLCODE = -00054 then
       FND_MESSAGE.SET_NAME('BSC','BSC_MUSERS_LOCKED_TAB');
       FND_MSG_PUB.ADD;
      x_return_status := 'L';
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
    else
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
      IF (x_msg_data IS NULL) THEN
        x_msg_data      :=  SQLERRM||' at BSC_MULTI_USER_PVT.Tab_Details_Lock ';
      END IF;
    end if;

end Tab_Details_Lock;

/************************************************************************************
************************************************************************************/

procedure Tab_Delete_Lock(
  p_obj_id                      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

-- This procedure locks tab_id for a given Tab.
-- We lock tab_id from BSC_TABS_B to prevent "Delete" and "Select Scorecard Items"
-- sessions to access the screen.
-- We lock name from BSC_TABS_B to lock out NOCOPY "Details".

l_dummy1			number;
l_dummy2			BSC_TABS_TL.NAME%TYPE;

begin

  select name
    into l_dummy2
    from BSC_TABS_TL
   where tab_id = p_obj_id
     and rownum < 2
  for update nowait;

  select tab_id
    into l_dummy1
    from BSC_TABS_B
   where tab_id = p_obj_id
  for update nowait;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := 'D';
--    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    if SQLCODE = -00054 then
      x_return_status := 'L';
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
    else
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
    end if;

end Tab_Delete_Lock;

/************************************************************************************
************************************************************************************/

procedure Tab_Select_Items_Lock(
  p_obj_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

-- This procedure locks tab_id for a given Tab.
-- We lock tab_id from BSC_TABS_B to lock other "Select Scorecard Items"
-- sessions and to lock out NOCOPY "Delete".

l_dummy1			number;

begin

  select tab_id
    into l_dummy1
    from BSC_TABS_B
   where tab_id = p_obj_id
  for update nowait;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := 'D';
--    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    if SQLCODE = -00054 then
      x_return_status := 'L';
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
    else
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
    end if;

end Tab_Select_Items_Lock;

/************************************************************************************
************************************************************************************/

procedure Kpi_Lock(
  p_obj_id                      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_dummy1			number;
l_dummy2			varchar2(20);

begin

  select indicator, property_code
    into l_dummy1, l_dummy2
    from bsc_kpi_properties
   where property_code = 'LOCK_INDICATOR'
     and indicator = p_obj_id
     for update nowait;

  select indicator
    into l_dummy1
    from BSC_KPIS_B
   where indicator = p_obj_id
  for update nowait;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := 'D';
--    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    if SQLCODE = -00054 then
      x_return_status := 'L';
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
    else
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
    end if;

end Kpi_Lock;

/************************************************************************************
************************************************************************************/

procedure Option_Lock(
  p_obj_id              IN      number
 ,p_obj_id2             IN      number
 ,p_obj_id3             IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_dummy1			varchar2(50);
l_dummy2			varchar2(50);

begin

  select indicator, property_code
    into l_dummy1, l_dummy2
    from bsc_kpi_properties
   where property_code = 'LOCK_INDICATOR'
     and indicator = p_obj_id
     for update nowait;

/*
  select name
    into l_dummy1
    from BSC_KPI_ANALYSIS_OPTIONS_TL
   where indicator = p_obj_id
     and option_id = p_obj_id2
     and analysis_group_id = p_obj_id3
  for update nowait;
*/

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := 'D';
--    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    if SQLCODE = -00054 then
      x_return_status := 'L';
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
    else
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
    end if;

end Option_Lock;

/************************************************************************************
************************************************************************************/

procedure Dim_Level_Lock(
  p_obj_id              IN      number
 ,p_obj_shortName       IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_dummy				number;

begin

 IF p_obj_id >= 0 and  (p_obj_shortName is null or  p_obj_shortName = '' or p_obj_shortName = 'DUMMY' )  then
    select DIM_LEVEL_ID
        into l_dummy
        from BSC_SYS_DIM_LEVELS_B
    where DIM_LEVEL_ID = p_obj_id
    for update nowait;
 else
    select DIM_LEVEL_ID
        into l_dummy
        from BSC_SYS_DIM_LEVELS_B
    where  upper(SHORT_NAME) = upper(p_obj_shortName)
    for update nowait;
 end if;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := 'D';
--    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    if SQLCODE = -00054 then
      x_return_status := 'L';
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
    else
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
    end if;

end Dim_Level_Lock;

/************************************************************************************
************************************************************************************/

end BSC_MULTI_USER_PVT;

/
