--------------------------------------------------------
--  DDL for Package Body BSC_PMF_UI_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PMF_UI_API_PUB" as
/* $Header: BSCUIAPB.pls 120.3 2006/02/10 01:31:26 ppandey noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCUIAPB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 16, 2001                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 | 04-MAR-2003 PAJOHRI  MLS Bug #2721899                                                |
 |                        Changed BSC_SYS_DIM_GROUPS_TL to BSC_SYS_DIM_GROUPS_VL in     |
 |                        select query.                                                 |
 |                                                                                      |
 | 12-MAR-2003 ADRAO   FIXED Bug #2834277                                               |
 | 20-MAR-03 PWALI for bug #2843082                                                     |
 | 13-MAY-2003 PWALI  Bug #2942895, SQL BIND COMPLIANCE                                 |
 | 04-APR-03 ASHANKAR Fix for the bug#2883880 added new procedure Update_Bsc_Dataset    |
 | 13-JUN-03 ADEULGAO Bug#2878840, Modified function Create_Bsc_Dimension to have       |
 |                    single DIM group for including all DIM LEVELS imported            |
 | 05-DEC-03   PAJOHRI  Removed use of All_Objects, Bug #3236002                        |
 | 27-FEB-2004 adeulgao fixed bug#3431750                                               |
 | 25-OCT-2005 kyadamak  Removed literals for Enhancement#4618419                       |
 +======================================================================================+
*/
G_PKG_NAME          varchar2(30) := 'BSC_PMF_UI_API_PUB';

g_Bsc_Pmf_Ui_Rec        BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type;
g_Bsc_Pmf_Dim_Tbl       BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Tbl_Type;
g_Bsc_Dim_Rec           BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
g_Bsc_Dim_Group_Rec     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
g_Bsc_Dataset_Rec       BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
g_Bsc_Dimset_Rec        BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
g_Bsc_Anal_Opt_Rec      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
--g_Bsc_Kpi_Rec         BSC_KPI_METADATA_PUB.Bsc_Kpi_Rec_Type;
--g_Bsc_Kpi_Tbl         BSC_KPI_METADATA_PUB.Bsc_Kpi_Tbl_Type;

g_source            varchar2(10);
g_invalid_level         varchar2(50);

procedure Bsc_Pmf_Ui_Api(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,p_Bsc_Pmf_Dim_Tbl     IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Tbl_Type
 ,p_Dim_Count       IN  number
 ,x_bad_level           OUT NOCOPY     varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  -- Delete all leftover values from global variables.
  g_Bsc_Pmf_Ui_Rec := null;
  g_Bsc_Dim_Rec := null;
  g_Bsc_Dim_Group_Rec := null;
  g_Bsc_Dataset_Rec := null;
  g_Bsc_Dimset_Rec := null;
  g_Bsc_Anal_Opt_Rec := null;
--  g_Bsc_Kpi_Rec := null;


  for i in 1..g_Bsc_Pmf_Dim_Tbl.count loop
    g_Bsc_Pmf_Dim_Tbl.delete(i);
  end loop;

/*
  for i in 1..g_Bsc_Kpi_Tbl.count loop
    g_Bsc_Kpi_Tbl.delete(i);
  end loop;
*/

  if p_Bsc_Pmf_Ui_Rec.Kpi_Id is null then
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Bsc_Pmf_Ui_Rec.Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  g_Bsc_Pmf_Ui_Rec.Kpi_Id := p_Bsc_Pmf_Ui_Rec.Kpi_Id;
  g_Bsc_Pmf_Ui_Rec.Kpi_Group_Id := p_Bsc_Pmf_Ui_Rec.Kpi_Group_Id;
  g_Bsc_Pmf_Ui_Rec.Tab_Id := p_Bsc_Pmf_Ui_Rec.Tab_Id;
  g_Bsc_Pmf_Ui_Rec.Option_Name := p_Bsc_Pmf_Ui_Rec.Option_Name;
  g_Bsc_Pmf_Ui_Rec.Option_Description := p_Bsc_Pmf_Ui_Rec.Option_Description;

  Get_Measure_Long_Name( p_commit
                        ,p_Bsc_Pmf_Ui_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);

  Modify_Passed_Parameters( p_commit
                           ,p_Bsc_Pmf_Ui_Rec
                           ,p_Bsc_Pmf_Dim_Tbl
                           ,p_Dim_Count
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data);



  Create_Bsc_Dimension( p_commit
                       ,p_Bsc_Pmf_Dim_Tbl
                       ,p_Dim_Count
                       ,x_return_status
                       ,x_msg_count
                       ,x_msg_data);



  Create_Bsc_Dataset( p_commit
                     ,p_Bsc_Pmf_Ui_Rec
                     ,x_return_status
                     ,x_msg_count
                     ,x_msg_data);

  Update_Bsc_Dataset( p_commit
                      ,p_Bsc_Pmf_Ui_Rec
                      ,x_return_status
                      ,x_msg_count
                      ,x_msg_data);



  Create_Bsc_Dimension_Set( p_commit
                           ,p_Bsc_Pmf_Ui_Rec
                           ,p_Bsc_Pmf_Dim_Tbl
                           ,p_Dim_Count
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    -- if the error is and invalid level we won't raise, we need to pass value of invalid
    -- level, else raise.
    if(g_invalid_level is not null) then
      x_bad_level := g_invalid_level;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                                ,p_data   =>      x_msg_data);
    else
      x_bad_level := null;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                                ,p_data   =>      x_msg_data);
      raise;
    end if;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Bsc_Pmf_Ui_Api;

/************************************************************************************
************************************************************************************/

procedure Get_Measure_Long_Name(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  if p_Bsc_Pmf_Ui_Rec.Measure_Short_Name is null then
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_SHORT_NAME');
    FND_MESSAGE.SET_TOKEN('BSC_SHORT_NAME', p_Bsc_Pmf_Ui_Rec.Measure_Short_Name);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  g_Bsc_Pmf_Ui_Rec.Measure_Short_Name := p_Bsc_Pmf_Ui_Rec.Measure_Short_Name;

  select distinct(name)
    into g_Bsc_Pmf_Ui_Rec.Measure_Long_Name
    from bis_indicators_vl
   where short_name = p_Bsc_Pmf_Ui_Rec.Measure_Short_Name;

--  g_Bsc_Dataset_Rec.Bsc_Measure_Long_Name := g_Bsc_Pmf_Ui_Rec.Measure_Long_Name;
  g_Bsc_Dataset_Rec.Bsc_Measure_Short_Name := g_Bsc_Pmf_Ui_Rec.Measure_Short_Name;
  g_Bsc_Dataset_Rec.Bsc_Measure_Long_Name := g_Bsc_Pmf_Ui_Rec.Option_Name;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Get_Measure_Long_Name;

/************************************************************************************
************************************************************************************/

procedure Get_Dimension_Long_Name(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  select distinct(dimension_name)
    into g_Bsc_Pmf_Ui_Rec.Dimension_Long_Name
    from bisfv_dimensions
   where dimension_short_name = p_Bsc_Pmf_Ui_Rec.Dimension_Short_Name;




EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Get_Dimension_Long_Name;

/************************************************************************************
************************************************************************************/

/*
procedure Get_Dimension_Level_Name(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  g_Bsc_Pmf_Ui_Rec.Dimension_Short_Name := p_Bsc_Pmf_Ui_Rec.Dimension_Short_Name;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Get_Dimension_Level_Name;
*/

/************************************************************************************
************************************************************************************/

procedure Modify_Passed_Parameters(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,p_Bsc_Pmf_Dim_Tbl     IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Tbl_Type
 ,p_Dim_Count       IN  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

TYPE Recdc_value        IS REF CURSOR;
dc_value            Recdc_value;
dc_value1           Recdc_value;

no_dim_level            exception;

l_alternate_level_view      varchar2(30);
l_sql               varchar2(1000);
l_sql1              varchar2(1000);
l_owner             VARCHAR2(256);

begin

  g_invalid_level := null;

  -- Set and modify the passed Record for measure and Dimension.
  g_Bsc_Pmf_Ui_Rec.Measure_Short_Name := p_Bsc_Pmf_Ui_Rec.Measure_Short_Name;

  -- Set and modify the passed Table for Dimension and Dimension Levels.
  for i in 1..p_Bsc_Pmf_Dim_Tbl.count loop

    -- Set the dimension level short name and get the dimension level long name.
    if p_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name is null then
      raise no_dim_level;
    end if;

    g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name :=  p_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name;
    g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Status :=  p_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Status;

    select distinct source
--      into g_source
      into g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Source
      from bisfv_dimension_levels
     where upper(dimension_level_short_name) = upper(p_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name);

    if g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Source = 'OLTP' then
      select distinct dimension_level_name, level_values_view_name, 'ID', 'value'
--      select distinct dimension_level_name, level_values_view_name, 'rownum', 'value'
        into g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Long_Name,
             g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_View_Name,
             g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Pk_Key,
             g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Name_Column
        from bisbv_dimension_levels
       where upper(dimension_level_short_name) = upper(p_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name);

      -- added as a request by PM to fix bug# 2598829
      g_invalid_level := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Long_Name;

      l_sql := 'select max(length(value)) ' ||
               'from ' || g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_View_Name;

      open dc_value for l_sql;
        fetch dc_value into g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Disp_Size;
      close dc_value;


    else

      select distinct dimension_level_name
                     ,dimension_level_short_name || '_LTC'
                     ,level_values_view_name
        into  g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Long_Name
             ,g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_View_Name
             ,l_alternate_level_view
        from bisfv_dimension_levels
       where dimension_level_short_name = p_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name;

      if l_alternate_level_view is not null then
        g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_View_Name := l_alternate_level_view;
        g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Pk_Key_edw := 'ID';
        g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Name_Column := 'VALUE';

      -- added as a request by PM to fix bug# 2598829
--      g_invalid_level := p_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name;
      g_invalid_level := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Long_Name;


      else

/*
        -- Changed to dynamic sql, in case EDW has not been installed.
        l_sql1 := ' select distinct level_table_col_name ' ||
                  '   from edw_level_Table_atts_md_v ' ||
                  '  where key_type=''UK'' and ' ||
                  '        upper(level_Table_name) = upper(''' || g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_View_Name || ''') and ' ||
                  '        upper(level_table_col_name) like ''%PK_KEY%''';
*/

        -- Change to query data dictionary due to EDW APIs not being there.
        l_owner := bsc_utility.get_owner_for_object(g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_View_Name);

        l_sql1 := ' SELECT column_name ' ||
                 '   FROM ALL_TAB_COLUMNS ' ||
                 '  WHERE table_name = UPPER(:1) AND ' ||
                 '        column_name LIKE ''%PK_KEY%'''||
                 ' AND OWNER = :2 ';
        open dc_value1 for l_sql1 using g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_View_Name, l_owner;
          fetch dc_value1 into g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Pk_Key_edw;
        close dc_value1;

/*
        -- Changed to dynamic sql, in case EDW has not been installed.
        l_sql1 := ' select level_table_col_name ' ||
                  '   from edw_level_Table_atts_md_v ' ||
                  '  where upper(level_Table_name) = upper(''' || g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_View_Name || ''') and ' ||
                  '        (upper(level_table_col_name) like ''%DESCRIPTION%'' or ' ||
                  '        upper(level_table_col_name) like ''NAME%'') and ' ||
                  '        rownum < 2';
*/

        -- Change to query data dictionary due to EDW APIs not being there.
        l_sql1 := ' select column_name ' ||
                 '   from ALL_TAB_COLUMNS ' ||
                 '  where table_name = upper(:1) and ' ||
                 '        (column_name like ''%DESCRIPTION%'' or ' ||
                 '         column_name like ''NAME%'') ' ||
                 '         AND OWNER = :2 '||
                 '         AND rownum < 2';


        open dc_value1 for l_sql1 using g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_View_Name, l_owner;
          fetch dc_value1 into g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Name_Column;
        close dc_value1;

      end if;

      l_sql := 'select max(length(' || g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Name_Column || ')) ' ||
               'from ' || g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_View_Name;

      open dc_value for l_sql;
        fetch dc_value into g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Disp_Size;
      close dc_value;



    end if;

    -- Double the size of the Level Display Size if under 125;
    if g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Disp_Size < 125 then
      g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Disp_Size := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Disp_Size * 2;
    end if;

  end loop;

  -- If execution has come this far then clear out NOCOPY g_invalid_level variable.
  g_invalid_level := null;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    rollback;
    if g_invalid_level is not null then
      FND_MESSAGE.SET_NAME('BSC','BSC_UNAVAILABLE_LEVEL');
      FND_MESSAGE.SET_TOKEN('BSC_LEVEL', g_invalid_level);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    else
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
      raise;
    end if;

end Modify_Passed_Parameters;

/************************************************************************************
************************************************************************************/

procedure Create_Bsc_Dimension(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Dim_Tbl IN  BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Tbl_Type
 ,p_Dim_Count       IN  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin


    /* from now on all the dimensions will be attached to single dim group
       generate the unique group name here and attach all the dim levels to it */

    g_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Id := BSC_DIMENSION_GROUPS_PUB.Get_Next_Value('BSC_SYS_DIM_GROUPS_TL'
                                                          ,'DIM_GROUP_ID');

    g_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Name := 'Dgrp_'||g_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Id;
    g_Bsc_Dim_Group_Rec.Bsc_Language := 'US';
    g_Bsc_Dim_Group_Rec.Bsc_Source_Language := 'US';


  for i in 1..g_Bsc_Pmf_Dim_Tbl.count loop

    -- Set values for Dimension Level in BSC.
    g_Bsc_Dim_Rec.Bsc_Level_Short_Name := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name;
    g_Bsc_Dim_Rec.Bsc_Dim_Level_Long_Name := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Long_Name;
    g_Bsc_Dim_Rec.Bsc_Level_Disp_Key_Size := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Disp_Size;
    g_Bsc_Dim_Rec.Bsc_Level_Name := get_Dim_Level_View_Name(g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name);
    g_Bsc_Dim_Rec.Bsc_Level_View_Name := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_View_Name;
--    if g_source = 'OLTP' then
    if g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Source = 'OLTP' then
      g_Bsc_Dim_Rec.Bsc_Level_Pk_Key := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Pk_Key;
    else
      g_Bsc_Dim_Rec.Bsc_Level_Pk_Key := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Pk_Key_edw;
    end if;
--    if g_source = 'OLTP' then
    if g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Source = 'OLTP' then
      g_Bsc_Dim_Rec.Bsc_Pk_Col := 'ID';
    else
      g_Bsc_Dim_Rec.Bsc_Pk_Col := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Pk_Key_edw;
    end if;
/*
    if g_source = 'OLTP' then
      g_Bsc_Dim_Rec.Bsc_Pk_Col := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Pk_Key;
    else
      g_Bsc_Dim_Rec.Bsc_Pk_Col := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Pk_Key_edw;
    end if;
*/
    g_Bsc_Dim_Rec.Bsc_Source := 'PMF';
    g_Bsc_Dim_Rec.Source := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Source; /* Added to fix 2674365 */

    g_Bsc_Dim_Rec.Bsc_Level_Name_Column := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Name_Column;
--    g_Bsc_Dim_Rec.Bsc_Kpi_Id := g_Bsc_Pmf_Ui_Rec.Kpi_Id;
    g_Bsc_Dim_Rec.Bsc_Language := 'US';
    g_Bsc_Dim_Rec.Bsc_Source_Language := 'US';

    BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level( FND_API.G_TRUE
                                              ,g_Bsc_Dim_Rec
                                              ,x_return_status
                                              ,x_msg_count
                                              ,x_msg_data);

    -- Set values for Dimension Group in BSC.
    --g_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Name := 'Dgrp ' || lower(replace(g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name, '_', ' '));
    --g_Bsc_Dim_Group_Rec.Bsc_Language := 'US';
    --g_Bsc_Dim_Group_Rec.Bsc_Source_Language := 'US';


    -- Get the Id for the recently created Dimension (Level) in BSC.
    select distinct dim_level_id
      into g_Bsc_Dim_Group_Rec.Bsc_Level_Id
      from BSC_SYS_DIM_LEVELS_B
     where SHORT_NAME = g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name;


    -- Create a Dimension Group for all Dimension Level.
    BSC_DIMENSION_GROUPS_PUB.Create_Dimension_Group( FND_API.G_TRUE
                                                    ,g_Bsc_Dim_Group_Rec
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);


  end loop;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Create_Bsc_Dimension;

/************************************************************************************
************************************************************************************/
procedure Update_Bsc_Dataset(
  p_commit              IN             VARCHAR2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN             BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) is


 l_language             VARCHAR2(2000);
 l_Dataset_Rec          BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
 l_Measure_Id           NUMBER;
 l_dataset_id           NUMBER;

 CURSOR c_language IS
 SELECT language_code
 FROM   fnd_languages
 WHERE  installed_flag IN ('I','B') AND language_code <> USERENV('LANG');

BEGIN

 l_Dataset_Rec.Bsc_Measure_Short_Name := p_Bsc_Pmf_Ui_Rec.Measure_Short_Name;

    SELECT  A.MEASURE_ID, B.DATASET_ID
    INTO    l_Measure_Id,
            l_dataset_id
    FROM    BSC_SYS_MEASURES     A,
            BSC_SYS_DATASETS_B   B
    WHERE   A.SHORT_NAME =  l_Dataset_Rec.Bsc_Measure_Short_Name
    AND     A.SOURCE     = 'PMF'
    AND     A.MEASURE_ID =  B.MEASURE_ID1;

    IF  (l_dataset_id IS NOT NULL) THEN

        l_Dataset_Rec.Bsc_Dataset_Id := l_dataset_id;

        IF (c_language%ISOPEN) THEN
         CLOSE c_language;
        END IF;

        OPEN c_language;

        LOOP
          FETCH c_language INTO l_language;
        EXIT WHEN c_language%NOTFOUND;

        SELECT  T.NAME,
                T.DESCRIPTION,
                T.SOURCE_LANG
        INTO    l_Dataset_Rec.Bsc_Dataset_Name,
                l_Dataset_Rec.Bsc_Dataset_Help,
                l_Dataset_Rec.Bsc_Source_Language
        FROM    BIS_INDICATORS_TL T,
                BIS_INDICATORS    B
        WHERE   T.INDICATOR_ID =    B.INDICATOR_ID
        AND     B.SHORT_NAME   =    l_Dataset_Rec.Bsc_Measure_Short_Name
        AND     T.LANGUAGE     =    l_language;

        BSC_DATASETS_PUB.Update_Dataset
        (
             p_commit           =>  p_commit
           , p_Dataset_Rec      =>  l_Dataset_Rec
           , p_update_dset_calc =>  FALSE
           , x_return_status    =>  x_return_status
           , x_msg_count        =>  x_msg_count
           , x_msg_data         =>  x_msg_data
        );

         END LOOP;
         CLOSE c_language;
        IF (p_commit = FND_API.G_TRUE) THEN
            COMMIT;
        END if;
   END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (c_language%ISOPEN) THEN
          CLOSE c_language;
      END IF;
      rollback;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                                ,p_data   =>      x_msg_data);
      raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (c_language%ISOPEN) THEN
            CLOSE c_language;
      END IF;

      rollback;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
      raise;
    WHEN NO_DATA_FOUND THEN
      IF (c_language%ISOPEN) THEN
            CLOSE c_language;
      END IF;

      rollback;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
      raise;
    WHEN OTHERS THEN
      IF (c_language%ISOPEN) THEN
            CLOSE c_language;
      END IF;
      rollback;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
    raise;

END Update_Bsc_Dataset;
/***************************************************************************************/


procedure Create_Bsc_Dataset(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

  --Bug 2677766
  l_bsc_format_id   number;
  l_measure_col     BSC_SYS_MEASURES.MEASURE_COL%TYPE;
begin

  g_Bsc_Dataset_Rec.Bsc_Measure_Short_Name := p_Bsc_Pmf_Ui_Rec.Measure_Short_Name;
  g_Bsc_Dataset_Rec.Bsc_Measure_Operation := 'SUM';
  --g_Bsc_Dataset_Rec.Bsc_Measure_Col := p_Bsc_Pmf_Ui_Rec.Measure_Short_Name;
  g_Bsc_Dataset_Rec.Bsc_Language := 'US';
  g_Bsc_Dataset_Rec.Bsc_Source_Language := 'US';
  g_Bsc_Dataset_Rec.Bsc_Source := 'PMF';
  g_Bsc_Dataset_Rec.Bsc_Dataset_Name := g_Bsc_Pmf_Ui_Rec.Measure_Long_Name;
  l_measure_col := BSC_BIS_MEASURE_PUB.get_measure_col(g_Bsc_Dataset_Rec.Bsc_Dataset_Name, NULL, NULL,g_Bsc_Dataset_Rec.Bsc_Measure_Short_Name);
  if (l_measure_col is not null) then
      g_Bsc_Dataset_Rec.Bsc_Measure_Col := l_measure_col;
  else
      g_Bsc_Dataset_Rec.Bsc_Measure_Col := g_Bsc_Dataset_Rec.Bsc_Measure_Short_Name;
  end if;
  --Bug 2677766
  BSC_BIS_WRAPPER_PVT.get_bsc_format_id(  p_measure_shortname => p_Bsc_Pmf_Ui_Rec.Measure_Short_Name
                     ,x_bsc_format_id     => l_bsc_format_id);
  if l_bsc_format_id is null then
    l_bsc_format_id := 5;
  end if;
  g_Bsc_Dataset_Rec.Bsc_Dataset_Format_Id := l_bsc_format_id;
  --end 2677766

  BSC_DATASETS_PUB.Create_Measures( FND_API.G_TRUE
                                   ,g_Bsc_Dataset_Rec
                                   ,x_return_status
                                   ,x_msg_count
                                   ,x_msg_data);
commit;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Create_Bsc_Dataset;

/************************************************************************************
************************************************************************************/

procedure Create_Bsc_Dimension_Set(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Ui_Rec      IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type
 ,p_Bsc_Pmf_Dim_Tbl IN  BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Tbl_Type
 ,p_Dim_Count       IN  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  -- Get the next dimension set id for the current dimension set.
  select max(dim_set_id) + 1
    into g_Bsc_Dimset_Rec.Bsc_Dim_Set_Id
    from BSC_KPI_DIM_SETS_TL
   where indicator = g_Bsc_Pmf_Ui_Rec.Kpi_Id;

  -- Set the record parameter Bsc_New_Dset to 'Y'.  This tells the Dimension
  -- set API that this is a new Dim set.  Set it to 'N' after the first call to
  -- the Dim Set.
  g_Bsc_Dimset_Rec.Bsc_New_Dset := 'Y';

  for i in 1..g_Bsc_Pmf_Dim_Tbl.count loop

--    g_Bsc_Dimset_Rec.Source_Level_Short_Name := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name;
--    g_Bsc_Dimset_Rec.Source_Level_Long_Name := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Long_Name;
    g_Bsc_Dimset_Rec.Bsc_Level_Name := get_Dim_Level_View_Name(g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name);
    g_Bsc_Dimset_Rec.Bsc_Dset_Default_Value := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Status;
    select TOTAL_DISP_NAME, COMP_DISP_NAME
      into g_Bsc_Dimset_Rec.Bsc_Dim_Tot_Disp_Name,
           g_Bsc_Dimset_Rec.Bsc_Dim_Comp_Disp_Name
      from BSC_SYS_DIM_LEVELS_VL
     where SHORT_NAME = g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name;

--    g_Bsc_Dimset_Rec.Bsc_Level_View_Name := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_View_Name;
--    g_Bsc_Dimset_Rec.Bsc_Level_Pk_Key := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Pk_Key;
--    g_Bsc_Dimset_Rec.Bsc_Level_Name_Column := g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Name_Column;
    g_Bsc_Dimset_Rec.Bsc_Kpi_Id := g_Bsc_Pmf_Ui_Rec.Kpi_Id;
    g_Bsc_Dimset_Rec.Bsc_Language := 'US';
    g_Bsc_Dimset_Rec.Bsc_Source_Language := 'US';
    g_Bsc_Dimset_Rec.Bsc_Dim_Level_Group_Index := i;

    --set the name of the group using the dimension level record.
    g_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Name := 'Dgrp ' || lower(replace(g_Bsc_Pmf_Dim_Tbl(i).Dimension_Level_Short_Name, '_', ' '));


    -- Get the group Id for the current dimension level.
    select distinct dim_group_id
      into g_Bsc_Dimset_Rec.Bsc_Dim_Level_Group_Id
      from BSC_SYS_DIM_GROUPS_VL
     where upper(name) = upper(g_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Name);


    -- Call the BSC API to Populate Dimension sets.
    BSC_DIMENSION_SETS_PUB.Create_Dim_Group_In_Dset( FND_API.G_TRUE
                                                    ,g_Bsc_Dimset_Rec
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);

    g_Bsc_Dimset_Rec.Bsc_New_Dset := 'N';

  end loop;

  -- Get the Dataset Id for the current PMF Measure.  This Dataset Id was set in the
  -- Create_Bsc_Dataset procedure.
  select distinct a.dataset_id
    into g_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id
    from BSC_SYS_DATASETS_B a,
         BSC_SYS_MEASURES b
   where upper(b.short_name) = upper(p_Bsc_Pmf_Ui_Rec.Measure_Short_Name)
     and a.measure_id1 = b.measure_id
     and rownum < 2;

  g_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id := p_Bsc_Pmf_Ui_Rec.Kpi_Id;
  g_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id := g_Bsc_Dimset_Rec.Bsc_Dim_Set_Id;


  -- Call the procedure that will create the Analysis Option.
  Create_Bsc_Analysis_Option( p_commit
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Create_Bsc_Dimension_Set;

/************************************************************************************
************************************************************************************/

procedure Create_Bsc_Analysis_Option(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin

  -- Set the values for Option Properties.
  g_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id := 0;
  g_Bsc_Anal_Opt_Rec.Bsc_Parent_Option_Id := 0;
  g_Bsc_Anal_Opt_Rec.Bsc_Grandparent_Option_Id := 0;
  g_Bsc_Anal_Opt_Rec.Bsc_Option_Group1 := 0;
  g_Bsc_Anal_Opt_Rec.Bsc_Option_Group2 := 0;
  g_Bsc_Anal_Opt_Rec.Bsc_Language := 'US';
  g_Bsc_Anal_Opt_Rec.Bsc_Source_Language := 'US';
  g_Bsc_Anal_Opt_Rec.Bsc_Option_Name := g_Bsc_Pmf_Ui_Rec.Option_Name;
  g_Bsc_Anal_Opt_Rec.Bsc_Option_Help := g_Bsc_Pmf_Ui_Rec.Option_Description;

  select count(option_id) + 1
    into g_Bsc_Anal_Opt_Rec.Bsc_Option_Group0
    from BSC_KPI_ANALYSIS_OPTIONS_B
   where indicator = g_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
     and analysis_group_id = g_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id;

  -- Need to create Analysis Options for this KPI. But first we need to determine
  -- if the KPI only has 1 option, and if this option is the default option.  If it
  -- is then we need to replace it.
    select count(option_id)
      into l_count
      from BSC_KPI_ANALYSIS_OPTIONS_B
     where indicator = g_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
       and analysis_group_id = g_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id;

  -- if there's only one option then check if this is the default option.
  if l_count = 1 then
    select count(option_id)
      into l_count
      from BSC_KPI_ANALYSIS_OPTIONS_VL
     where name = 'Option 0'
       and indicator = g_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;

    -- now double check by checking the dataset id.
    if l_count = 1 then
      select dataset_id
        into l_count
        from BSC_KPI_ANALYSIS_MEASURES_B
       where indicator = g_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
         and analysis_option0 = 0
         and analysis_option1 = g_Bsc_Anal_Opt_Rec.Bsc_Option_Group1
         and analysis_option2 = g_Bsc_Anal_Opt_Rec.Bsc_Option_Group2
         and series_id = 0;
      if l_count = -1 then
        -- If we've come this far then we need to update the default Option.
        g_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id := 0;
        g_Bsc_Anal_Opt_Rec.Bsc_Option_Group0 := 0;
        BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options( FND_API.G_TRUE
                                                        ,g_Bsc_Anal_Opt_Rec
                                                        ,x_return_status
                                                        ,x_msg_count
                                                        ,x_msg_data);

        -- Now we need to change the defaults from BSC values to PMF values.
        BSC_DESIGNER_PVT.Deflt_RefreshKpi(g_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id);

      else
        -- Call procedure to create Analysis Option.
        BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Options( FND_API.G_TRUE
                                                      ,g_Bsc_Anal_Opt_Rec
                                                      ,x_return_status
                                                      ,x_msg_count
                                                      ,x_msg_data);
      end if;
    else
      -- Call procedure to create Analysis Option.
      BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Options( FND_API.G_TRUE
                                                      ,g_Bsc_Anal_Opt_Rec
                                                      ,x_return_status
                                                      ,x_msg_count
                                                      ,x_msg_data);

    end if;

  else

    -- Call procedure to create Analysis Option.
    BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Options( FND_API.G_TRUE
                                                    ,g_Bsc_Anal_Opt_Rec
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Create_Bsc_Analysis_Option;

/************************************************************************************
************************************************************************************/

procedure Import_PMF_Dim_Level(
  p_commit              IN      varchar2 := FND_API.G_TRUE
 ,p_Bsc_Pmf_Dim_Rec     IN      BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

v_Bsc_Pmf_Dim_Rec               BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type;
v_Bsc_Dim_Rec           BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
v_Bsc_Dim_Group_Rec     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;


BEGIN

          --DBMS_OUTPUT.PUT_LINE('Begin Import_Dim_Level   ' );
          --DBMS_OUTPUT.PUT_LINE(' Import_Dim_Level   p_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name = ' || p_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name  );

    Populate_Bsc_Pmf_Dim_Rec(
                         p_commit
             ,p_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name
             ,v_Bsc_Pmf_Dim_Rec
             ,x_return_status
             ,x_msg_count
             ,x_msg_data );

          --DBMS_OUTPUT.PUT_LINE(' Import_Dim_Level  Flag 1  x_return_status = ' || x_return_status  );

    -- Set values for Dimension Level in BSC.
    v_Bsc_Dim_Rec.Bsc_Level_Short_Name := p_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name;
    v_Bsc_Dim_Rec.Bsc_Dim_Level_Long_Name := v_Bsc_Pmf_Dim_Rec.Dimension_Level_Long_Name;
    v_Bsc_Dim_Rec.Bsc_Level_Disp_Key_Size := v_Bsc_Pmf_Dim_Rec.Dimension_Level_Disp_Size;
    v_Bsc_Dim_Rec.Bsc_Level_Name := get_Dim_Level_View_Name(p_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name);
    v_Bsc_Dim_Rec.Bsc_Level_View_Name := v_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name;
    if v_Bsc_Pmf_Dim_Rec.Dimension_Level_Source = 'OLTP' then
      v_Bsc_Dim_Rec.Bsc_Level_Pk_Key := v_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key;
    else
      v_Bsc_Dim_Rec.Bsc_Level_Pk_Key := v_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key_edw;
    end if;
    if v_Bsc_Pmf_Dim_Rec.Dimension_Level_Source = 'OLTP' then
      v_Bsc_Dim_Rec.Bsc_Pk_Col := 'ID';
    else
      v_Bsc_Dim_Rec.Bsc_Pk_Col := v_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key_edw;
    end if;
/*
    if v_Bsc_Pmf_Dim_Rec.Dimension_Level_Source = 'OLTP' then
      v_Bsc_Dim_Rec.Bsc_Pk_Col := v_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key;
    else
      v_Bsc_Dim_Rec.Bsc_Pk_Col := v_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key_edw;
    end if;
*/
    v_Bsc_Dim_Rec.Bsc_Source := 'PMF';
    v_Bsc_Dim_Rec.Source := v_Bsc_Pmf_Dim_Rec.Dimension_Level_Source; /* added to fix 2674365 */

    v_Bsc_Dim_Rec.Bsc_Level_Name_Column := v_Bsc_Pmf_Dim_Rec.Dimension_Level_Name_Column;
--    v_Bsc_Dim_Rec.Bsc_Kpi_Id := g_Bsc_Pmf_Ui_Rec.Kpi_Id;
    v_Bsc_Dim_Rec.Bsc_Language := 'US';
    v_Bsc_Dim_Rec.Bsc_Source_Language := 'US';

          --DBMS_OUTPUT.PUT_LINE(' Import_Dim_Level  Flag 2  x_return_status = ' || x_return_status  );

    BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level( FND_API.G_TRUE
                                              ,v_Bsc_Dim_Rec
                                              ,x_return_status
                                              ,x_msg_count
                                              ,x_msg_data);

          --DBMS_OUTPUT.PUT_LINE(' Import_Dim_Level  Flag 3  x_return_status = ' || x_return_status  );


    -- Set values for Dimension Group in BSC.
    v_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Name := 'Dgrp ' || lower(replace(v_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name, '_', ' '));
    v_Bsc_Dim_Group_Rec.Bsc_Language := 'US';
    v_Bsc_Dim_Group_Rec.Bsc_Source_Language := 'US';

          --DBMS_OUTPUT.PUT_LINE(' Import_Dim_Level  Flag 4  x_return_status = ' || x_return_status  );

    -- Get the Id for the recently created Dimension (Level) in BSC.
    select distinct dim_level_id
      into v_Bsc_Dim_Group_Rec.Bsc_Level_Id
      from BSC_SYS_DIM_LEVELS_B
     where SHORT_NAME = p_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name;

    -- Create a Dimension Group for the Dimension Level.

          --DBMS_OUTPUT.PUT_LINE(' Import_Dim_Level - Flag 5 - Create Dimension Group -   x_return_status = ' || x_return_status  );

    BSC_DIMENSION_GROUPS_PUB.Create_Dimension_Group( FND_API.G_TRUE
                                                    ,v_Bsc_Dim_Group_Rec
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data);

          --DBMS_OUTPUT.PUT_LINE('End Import_Dim_Level ');


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Import_PMF_Dim_Level;

/************************************************************************************
************************************************************************************/

procedure Populate_Bsc_Pmf_Dim_Rec(
  p_commit                IN    varchar2 := FND_API.G_TRUE
 ,p_Dim_Level_Short_Name  IN    varchar2
 ,x_Bsc_Pmf_Dim_Rec     OUT NOCOPY     BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

TYPE Recdc_value        IS REF CURSOR;
dc_value            Recdc_value;
dc_value1           Recdc_value;

no_dim_level            exception;

l_alternate_level_view      varchar2(30);
l_sql               varchar2(1000);
l_sql1              varchar2(1000);
l_count                         number;

BEGIN

  --DBMS_OUTPUT.PUT_LINE('Begin  Populate_Bsc_Pmf_Dim_Rec ');   /* 949 */

    -- Set the dimension level short name and get the dimension level long name.
    if p_Dim_Level_Short_Name is null then
          --DBMS_OUTPUT.PUT_LINE('Populate_Bsc_Pmf_Dim_Rec  - Short_Name is null ');
      raise no_dim_level;
    end if;

    --x_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name := substr(p_Dim_Level_Short_Name, 1, 24);
    x_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name := p_Dim_Level_Short_Name;

  --DBMS_OUTPUT.PUT_LINE(' Populate_Bsc_Pmf_Dim_Rec  p_Dim_Level_Short_Name =                        '  || p_Dim_Level_Short_Name );
  --DBMS_OUTPUT.PUT_LINE(' Populate_Bsc_Pmf_Dim_Rec  x_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name  = '  || x_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name );

    select distinct source
      into x_Bsc_Pmf_Dim_Rec.Dimension_Level_Source
      from bisfv_dimension_levels
      where upper(dimension_level_short_name) = upper(p_Dim_Level_Short_Name);

  --DBMS_OUTPUT.PUT_LINE('Populate_Bsc_Pmf_Dim_Rec  x_Bsc_Pmf_Dim_Rec.Dimension_Level_Source  =      '  || x_Bsc_Pmf_Dim_Rec.Dimension_Level_Source );

    if x_Bsc_Pmf_Dim_Rec.Dimension_Level_Source = 'OLTP' then
    --DBMS_OUTPUT.PUT_LINE(' Populate_Bsc_Pmf_Dim_Rec  -  OLTP ' );

      select distinct dimension_level_name, level_values_view_name, 'ID', 'value'
--      select distinct dimension_level_name, level_values_view_name, 'rownum', 'value'
        into x_Bsc_Pmf_Dim_Rec.Dimension_Level_Long_Name,
             x_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name,
             x_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key,
             x_Bsc_Pmf_Dim_Rec.Dimension_Level_Name_Column
        from bisbv_dimension_levels
       where upper(dimension_level_short_name) = upper(p_Dim_Level_Short_Name);

    else
    --DBMS_OUTPUT.PUT_LINE(' Populate_Bsc_Pmf_Dim_Rec  Flag A ' );

      select distinct dimension_level_name
                     ,dimension_level_short_name || '_LTC'
                     ,level_values_view_name
        into  x_Bsc_Pmf_Dim_Rec.Dimension_Level_Long_Name
             ,x_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name
             ,l_alternate_level_view
        from bisbv_dimension_levels
       where upper(dimension_level_short_name) = upper(p_Dim_Level_Short_Name);

    --DBMS_OUTPUT.PUT_LINE('Populate_Bsc_Pmf_Dim_Rec  x_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name  =      '  || x_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name );


      if l_alternate_level_view is not null then
      --DBMS_OUTPUT.PUT_LINE('Populate_Bsc_Pmf_Dim_Rec  l_alternate_level_view  =      '  || l_alternate_level_view );
        x_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name := l_alternate_level_view;
        x_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key_edw := 'ID';
        x_Bsc_Pmf_Dim_Rec.Dimension_Level_Name_Column := 'VALUE';

      else
      --DBMS_OUTPUT.PUT_LINE(' Populate_Bsc_Pmf_Dim_Rec  Flag B ' );

        -- Changed to dynamic sql, in case EDW not installed.
        l_sql1 := ' select distinct level_table_col_name ' ||
                  '   from edw_level_Table_atts_md_v ' ||
                  '  where key_type=''UK'' and ' ||
                  '  upper(level_Table_name) = upper(:1) and ' ||
                  '        upper(level_table_col_name) like ''%PK_KEY%''';


        open dc_value1 for l_sql1 using x_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name;
           fetch dc_value1 into x_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key_edw;
        close dc_value1;

      --DBMS_OUTPUT.PUT_LINE('Populate_Bsc_Pmf_Dim_Rec  C  x_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key_edw  =      '  || x_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key_edw );

         -- Changed to dynamic sql, in case EDW not installed.
        l_sql1 := 'select level_table_col_name ' ||
                  '  from edw_level_Table_atts_md_v ' ||
                  ' where upper(level_Table_name) = upper(:1) and ' ||
                  '       (upper(level_table_col_name) like ''%DESCRIPTION%'' or ' ||
                  '       upper(level_table_col_name) like ''NAME%'') and ' ||
                  '       rownum < 2';

        open dc_value1 for l_sql1 using x_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name;
          fetch dc_value1 into x_Bsc_Pmf_Dim_Rec.Dimension_Level_Name_Column;
        close dc_value1;

      --DBMS_OUTPUT.PUT_LINE('Populate_Bsc_Pmf_Dim_Rec  D  x_Bsc_Pmf_Dim_Rec.Dimension_Level_Name_Column  =      '  || x_Bsc_Pmf_Dim_Rec.Dimension_Level_Name_Column );

      end if;

    end if;

  --DBMS_OUTPUT.PUT_LINE('Populate_Bsc_Pmf_Dim_Rec  XX  x_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name  =      '  || x_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name );

      -- Included to fixed bug 2382059
    IF (NOT BSC_UTILITY.is_Table_View_Exists(x_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name)) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_PMF_LEVEL_NOT_EXISTS');
        FND_MESSAGE.SET_TOKEN('BSC_LEVEL_NAME', x_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
      --  Included to fixed bug 2382059

      -- The 'order by'  added to fix bug 2406866
      l_sql := 'select max(length(' || x_Bsc_Pmf_Dim_Rec.Dimension_Level_Name_Column || '))' ||
               ' from ' || x_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name ||
               ' order by  NVL(:1,:2) ';

    --DBMS_OUTPUT.PUT_LINE('Populate_Bsc_Pmf_Dim_Rec  l_sql  =      '  || l_sql );

      open dc_value for l_sql using x_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key,x_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key_edw ;
        fetch dc_value into x_Bsc_Pmf_Dim_Rec.Dimension_Level_Disp_Size;
      close dc_value;
    --DBMS_OUTPUT.PUT_LINE('Populate_Bsc_Pmf_Dim_Rec  F x_Bsc_Pmf_Dim_Rec.Dimension_Level_Disp_Size  =      '  || x_Bsc_Pmf_Dim_Rec.Dimension_Level_Disp_Size );

    -- Double the size of the Level Display Size if under 125;
    if x_Bsc_Pmf_Dim_Rec.Dimension_Level_Disp_Size < 125 then
      x_Bsc_Pmf_Dim_Rec.Dimension_Level_Disp_Size := x_Bsc_Pmf_Dim_Rec.Dimension_Level_Disp_Size * 2;
    end if;


  --DBMS_OUTPUT.PUT_LINE('End  Populate_Bsc_Pmf_Dim_Rec ');


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

    raise;
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;


end Populate_Bsc_Pmf_Dim_Rec;

/************************************************************************************
************************************************************************************/
/*-------------------------------------------------------------------------------------
  get_Dim_Level_View_Name
    Return the Dimension Level View Name to use in BSC for an Imported Dimension Level
---------------------------------------------------------------------------------------*/
FUNCTION get_Dim_Level_View_Name(
   p_Short_Name IN VARCHAR2
) RETURN VARCHAR2 IS
 l_short_Name           varchar2(100);
 l_view_name            varchar2(100);
 l_count        number;
 l_index        number;

 BEGIN
  -- See if the Level Short Name is already imported
  select count(LEVEL_TABLE_NAME)
    into l_count
    from bsc_sys_dim_levels_vl
    where SHORT_NAME = 'p_Short_Name';

  if l_count <> 0 then
    -- if the level is already imported return the same name
    select LEVEL_TABLE_NAME
      into l_view_name
      from bsc_sys_dim_levels_vl
      where SHORT_NAME = p_Short_Name;
  else
    l_index := 0;

    -- if the level is not imported yet
    l_view_name := 'BSC_D_' || substr( replace(p_Short_Name, ' ', '_') , 1, 22) || '_V';
    loop
      select count(object_name)
        into l_count
    from user_objects
        where object_name = upper(l_view_name);
      exit when l_count = 0;

      -- Tries other object name
        l_index := l_index + 1;
        l_view_name := 'BSC_D_' || substr( replace(p_Short_Name, ' ', '_') , 1, 22 - LENGTH('' || l_index) )  || l_index || '_V';

    end loop;

  end if;

 RETURN l_view_name;

 EXCEPTION
  WHEN OTHERS THEN
    RETURN null;

END get_Dim_Level_View_Name;

/*********************************************************************************
**********************************************************************************/

PROCEDURE Get_DimLevel_Viewby
( p_api_version              IN  NUMBER
, p_Region_Code              IN  VARCHAR2
, p_Measure_Short_Name       IN  VARCHAR2
, x_DimLevel_Viewby_Tbl      OUT NOCOPY DimLevel_Viewby_Tbl_Type  /* BIS_PMV_BSC_API_PUB.DimLevel_Viewby_Tbl_Type */
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
) is

 l_Region_Code                      VARCHAR2(200);
 l_nested_region_code               VARCHAR2(200) := null;
 l_Region                           VARCHAR2(200);
 l_attribute1                   VARCHAR2(200);
 l_attribute2                       VARCHAR2(200);
 l_required_flag                        VARCHAR2(200);
 l_Report_View_By_Flag              VARCHAR2(1);
 l_Level_In_Main_Report_Flag        number;
 l_count                    number;
 l_Dimlevel_Viewby_Rec              Dimlevel_Viewby_Rec_Type;
 l_DimLevel_Viewby_Tbl              DimLevel_Viewby_Tbl_Type;
 l_index                                  number;
 NOT_VALID_DIMENSION                    VARCHAR2(40) := 'BSC_NOT_VALID_DIMENSION_FLAG' ;

 -- Cursor to get the Dimension Level Info from ak_region_items table ---------

 CURSOR c_region IS
    SELECT region_code
      FROM ak_region_items
      WHERE attribute1='MEASURE'
        AND attribute2 = p_Measure_Short_Name
      ORDER BY creation_date DESC;

 CURSOR c_nested_region IS
 SELECT DISTINCT nested_region_code
      FROM ak_region_items
      WHERE region_code = l_Region_Code
       AND item_style = 'NESTED_REGION';

 CURSOR c_Viewby_Report IS
   SELECT attribute1
     FROM ak_regions
     WHERE region_code = l_Region_Code;

 CURSOR c_dim_levels IS
     SELECT attribute2, attribute1, required_flag
       FROM ak_region_items
       WHERE region_code = l_Region_Code
           AND (attribute1 = 'DIMENSION LEVEL' OR attribute1 = 'HIDE PARAMETER' OR attribute1 = 'HIDE VIEW BY DIMENSION')
           ORDER BY attribute2, attribute1;

 -- Cursor to get the Dimension Level Info from ak_region_items table when exists a Nested Region
 CURSOR c_dim_levels1 IS
     SELECT attribute2, attribute1, region_code, required_flag
       FROM ak_region_items
       WHERE (region_code = l_Region_Code  OR region_code = l_nested_region_code)
           AND (attribute1 = 'DIMENSION LEVEL' OR attribute1 = 'HIDE PARAMETER' OR attribute1 = 'HIDE VIEW BY DIMENSION')
           ORDER BY attribute2, attribute1, region_code;
Begin

 --DBMS_OUTPUT.PUT_LINE('Begin  BSC_PMF_UI_API_PUB.Get_DimLevel_Viewby');
 --DBMS_OUTPUT.PUT_LINE('--- BSC_PMF_UI_API_PUB.Get_DimLevel_Viewby  -  p_Measure_Short_Name = ' || p_Measure_Short_Name);

 -- Check the Region code passed to the API
 if p_Region_Code is null then
  --If the region_code passed to the API is NULL, then the Measure is not associated with any Report.
  --So we have to query ak_region_items table to get the region_code

  OPEN c_region;
  FETCH c_region INTO l_Region_Code;
  if c_region%NOTFOUND then
    l_Region_Code := null;
    -- through and Error :  Measure does not exist
    --DBMS_OUTPUT.PUT_LINE('--- BSC_PMF_UI_API_PUB.Get_DimLevel_Viewby  -  Measure does not exist ' );
  end if;
  close c_region;
 else
  l_Region_Code := p_Region_Code;
 end if;

 --DBMS_OUTPUT.PUT_LINE('--- BSC_PMF_UI_API_PUB.Get_DimLevel_Viewby  -  l_Region_Code = ' || l_Region_Code);

 -- Check whether the report region contains a Nested Region (DBI Report). -----
  OPEN c_nested_region;
  FETCH c_nested_region INTO l_nested_region_code;
  if c_nested_region%NOTFOUND then
    l_nested_region_code := null;
  end if;
  close c_nested_region;
 --DBMS_OUTPUT.PUT_LINE('--- BSC_PMF_UI_API_PUB.Get_DimLevel_Viewby  -  l_nested_region_code = ' || l_nested_region_code);

 -- Check whether the report is 'View By'  or  'not View By' -------------------
  l_Report_View_By_Flag := 'Y';
  OPEN c_Viewby_Report;
  FETCH c_Viewby_Report INTO l_attribute1;
  if c_Viewby_Report%FOUND then
      if l_attribute1 = 'Y' then
         l_Report_View_By_Flag := 'N';
      end if;
  end if;
  close c_Viewby_Report;
 --DBMS_OUTPUT.PUT_LINE('--- BSC_PMF_UI_API_PUB.Get_DimLevel_Viewby  -  l_Report_View_By_Flag = ' || l_Report_View_By_Flag);

 -- Get the Dimension Level Info from the main Region -------------------------
 -- When not exits a Nested Region

 if l_nested_region_code is null then

  --DBMS_OUTPUT.PUT_LINE('--- BSC_PMF_UI_API_PUB.Get_DimLevel_Viewby  -  NESTED REGION NOT EXISTS ');

   l_Dimlevel_Viewby_Rec.Dim_DimLevel := NOT_VALID_DIMENSION;
   l_index := 1;

   OPEN c_dim_levels;
   LOOP
     FETCH c_dim_levels INTO l_attribute2, l_attribute1, l_required_flag;
     EXIT WHEN c_dim_levels%NOTFOUND;

    --DBMS_OUTPUT.PUT_LINE('--- l_attribute2 = ' || l_attribute2  || '   l_attribute1 = ' || l_attribute1 || '  l_required_flag = ' || l_required_flag);

     if l_Dimlevel_Viewby_Rec.Dim_DimLevel <> l_attribute2 then
    if l_Dimlevel_Viewby_Rec.Dim_DimLevel <> NOT_VALID_DIMENSION then
         l_DimLevel_Viewby_Tbl(l_index) := l_Dimlevel_Viewby_Rec;
             l_index := l_index + 1;
        end if;
        if l_attribute1 = 'DIMENSION LEVEL' then
            l_Dimlevel_Viewby_Rec.Dim_DimLevel := l_attribute2;
            l_Dimlevel_Viewby_Rec.Viewby_Applicable := l_Report_View_By_Flag;
            if l_required_flag = 'Y' then
           l_Dimlevel_Viewby_Rec.All_Applicable := 'N';
            else
               l_Dimlevel_Viewby_Rec.All_Applicable := 'Y';
            end if;
        else
            l_Dimlevel_Viewby_Rec.Dim_DimLevel := NOT_VALID_DIMENSION;
        end if;
     else
       if l_Report_View_By_Flag = 'Y' then
          if l_attribute1 = 'HIDE PARAMETER' or  l_attribute1 = 'HIDE VIEW BY DIMENSION' then
            l_Dimlevel_Viewby_Rec.Viewby_Applicable := 'N';
          end if;
       end if;
       if l_required_flag = 'Y' then
           l_Dimlevel_Viewby_Rec.All_Applicable := 'N';
       end if;
     end if;
   END LOOP;
   if  l_Dimlevel_Viewby_Rec.Dim_DimLevel <> NOT_VALID_DIMENSION then
    l_DimLevel_Viewby_Tbl(l_index) := l_Dimlevel_Viewby_Rec;
   end if;

 else   -- Get the Dimension Level Info from the main Region and Nested Region -----
        -- When exits a Nested Region

  --DBMS_OUTPUT.PUT_LINE('--- BSC_PMF_UI_API_PUB.Get_DimLevel_Viewby  -  NESTED REGION EXISTS ');

   l_Dimlevel_Viewby_Rec.Dim_DimLevel := NOT_VALID_DIMENSION;
   l_index := 1;
   OPEN c_dim_levels1;
   LOOP
     FETCH c_dim_levels1 INTO l_attribute2, l_attribute1, l_Region, l_required_flag ;
     EXIT WHEN c_dim_levels1%NOTFOUND;
    --DBMS_OUTPUT.PUT_LINE('--- l_attribute2 = ' || l_attribute2  || '   l_attribute1 = ' || l_attribute1  || '   l_Region = ' || l_Region  || '  l_required_flag = ' || l_required_flag );

     if l_Dimlevel_Viewby_Rec.Dim_DimLevel <> l_attribute2 then
    if  l_Dimlevel_Viewby_Rec.Dim_DimLevel <> NOT_VALID_DIMENSION then
            --DBMS_OUTPUT.PUT_LINE('--- l_attribute2 = ' || l_attribute2  || '   l_attribute1 = ' || l_attribute1  || '   l_Region = ' || l_Region  );
         l_DimLevel_Viewby_Tbl(l_index) := l_Dimlevel_Viewby_Rec;
             l_index := l_index + 1;
        end if;
        if l_attribute1 = 'DIMENSION LEVEL' then
            l_Dimlevel_Viewby_Rec.Dim_DimLevel := l_attribute2;
            l_Dimlevel_Viewby_Rec.Viewby_Applicable := l_Report_View_By_Flag;
            if l_required_flag = 'Y' then
        l_Dimlevel_Viewby_Rec.All_Applicable := 'N';
            else
            l_Dimlevel_Viewby_Rec.All_Applicable := 'Y';
            end if;
            if l_Region = l_Region_Code then
                l_Level_In_Main_Report_Flag := 1;
            else
                l_Level_In_Main_Report_Flag := 0;
            end if;
        else
            l_Dimlevel_Viewby_Rec.Dim_DimLevel := NOT_VALID_DIMENSION;
        end if;
     elsif l_attribute1 = 'DIMENSION LEVEL' then
        if l_Region = l_Region_Code then
        l_Level_In_Main_Report_Flag := 1;
                l_Dimlevel_Viewby_Rec.Viewby_Applicable := l_Report_View_By_Flag;
                if l_required_flag = 'Y' then
           l_Dimlevel_Viewby_Rec.All_Applicable := 'N';
                else
               l_Dimlevel_Viewby_Rec.All_Applicable := 'Y';
                end if;
        end if;
     else
         if l_Region = l_Region_Code or l_Level_In_Main_Report_Flag = 0 then
           if l_Report_View_By_Flag = 'Y' then
             if l_attribute1 = 'HIDE PARAMETER' or  l_attribute1 = 'HIDE VIEW BY DIMENSION' then
            l_Dimlevel_Viewby_Rec.Viewby_Applicable := 'N';
             end if;
           end if;
           if l_required_flag = 'Y' then
                 l_Dimlevel_Viewby_Rec.All_Applicable := 'N';
           end if;
         end if;
     end if;
   END LOOP;
   if  l_Dimlevel_Viewby_Rec.Dim_DimLevel <> NOT_VALID_DIMENSION then
    l_DimLevel_Viewby_Tbl(l_index) := l_Dimlevel_Viewby_Rec;
   end if;

 end if;

 x_DimLevel_Viewby_Tbl := l_DimLevel_Viewby_Tbl;

--DBMS_OUTPUT.PUT_LINE('End  BSC_PMF_UI_API_PUB.Get_DimLevel_Viewby');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

    raise;
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end Get_DimLevel_Viewby;

/*********************************************************************************
**********************************************************************************/



end BSC_PMF_UI_API_PUB;

/
