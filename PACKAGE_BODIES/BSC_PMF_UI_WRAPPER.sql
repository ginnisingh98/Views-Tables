--------------------------------------------------------
--  DDL for Package Body BSC_PMF_UI_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PMF_UI_WRAPPER" as
/* $Header: BSCPMFWB.pls 120.21 2007/06/01 06:49:24 ashankar ship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPMFWB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 18, 2001                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                      Pankaj Johri   Fix Bug #2608683                                 |
 |                      Adeulgao bug fix #2680214                                       |
 |              Adeulgao bug fix #2722565 06-Jan-2003                                   |
 |              Adeulgao bug fix #2731334 06-Jan-2003                                   |
 |              Pradeep  bug fix #2747256 15-Jan-2003                                   |
 |              Adeulgao bug fix #2731334 22-Jan-2003                                   |
 |                      Aditya   bug fix #2786053 20-Feb-2003                           |
 |                      PWALI    Bug #2942895, SQL BIND COMPLIANCE    13-MAY-2003       |
 |                      Adrao fixed bug#3118110 added function is_In_Dimension          |
 |                      ADEULGAO fixed bug#3127992 MODIFIED function is_In_Dimension    |
 |                      ADEULGAO fixed bug#3138010                                      |
 |                      ADRAO  Bug #3248729 14-NOV-2003                                 |
 |                      ADRAO  Modified Delete_KPI_Group() not to throw error for       |
 |                              for KPIs associated for Bug #3315077 14-DEC-2003        |
 |                                                                                      |
 |                                                                                      |
 |  08-JAN-2004        krishan fixed for the bug 3357984                                |
 |  27-FEB-2004        krishna fixed the bug# 3464251                                   |
 |   10-MAR-04          jxyu  Modified for enhancement #3493589                         |
 |  30-APR-2004        PAJOHRI Bug #3598852                                             |
 |   05-MAY6-04        wcano add procedure Update_Kpi_Periodicities                     |
 |   18-MAY-04          adrao Modified PL/SQL records and CRUD to accept SHORT_NAME     |
 |   19-MAY-04          adrao Modified Assign_Kpi_Group to pass FALSE as p_commit to    |
 |                      assign_kpi API                                                  |
 |   02-JUL-04         rpenneru Modified for enh# 3532517                               |
 |   30-SEP-04         visuri modified for bug 3852611                                  |
 |   08-JUL-05         ashankar nodified the API Check_Tab by changing the API          |
 |                     is_Scorecard_From_AG_Report TO is_Scorecard_From_Reports         |
 |   14-JUL-05          Krishna modified update_kpi_periodicities for bug#4376162       |
 |   25-JUL-05         hengliu added Check_Tabview_Dependency for bug#4237294           |
 |   31-AUG-2005       ashankar Bugfix#4576022                                          |
 |   25-MAY-2006       jxyu Bugfix#4174625                                              |
 |   02-Aug-2006       ashankar Bug fix #5400575 made changes to the method Unassign_kpi|
 |   17-Oct-2006       ppandey  Bug #5584826 Calender properties cascaded to Shared Obj |
 |   08-jan-07         ashankar Bug#5652713 Added the method Is_Valid_Sim_Period        |
 |   16-NOV-2006       ankgoel  Color By KPI enh#5244136                                |
 |   09-feb-2007       ashankar Simulation Tree Enhacement 5386112                      |
 |   27-feb-07         ashankar Fixed the issue in Update_Kpi_Periodicities             |
 |   30-MAR-2007       akoduri  Enh #5928640 Migration of Periodicity properties from   |
 |                              VB to Html                                              |
 +======================================================================================+
*/

G_PKG_NAME        varchar2(30) := 'BSC_PMF_UI_WRAPPER';

C_COL_M1_LEVEL1          CONSTANT      VARCHAR2(20):= 'COL_M1_LEVEL1';
C_COL_M1_LEVEL2          CONSTANT      VARCHAR2(20):= 'COL_M1_LEVEL2';
C_COL_M2_LEVEL1          CONSTANT      VARCHAR2(20):= 'COL_M2_LEVEL1';
C_COL_M2_LEVEL2          CONSTANT      VARCHAR2(20):= 'COL_M2_LEVEL2';
C_COL_M3_LEVEL1          CONSTANT      VARCHAR2(20):= 'COL_M3_LEVEL1';
C_COL_M3_LEVEL2          CONSTANT      VARCHAR2(20):= 'COL_M3_LEVEL2';
C_COL_M3_LEVEL3          CONSTANT      VARCHAR2(20):= 'COL_M3_LEVEL3';
C_COL_M3_LEVEL4          CONSTANT      VARCHAR2(20):= 'COL_M3_LEVEL4';
C_LANGUAGE               CONSTANT      VARCHAR2(2) := 'US';
C_ENABLE_FLAG            CONSTANT      NUMBER      := 2;
C_DISABLE_FLAG           CONSTANT      NUMBER      := 1;
C_HIDE_FLAG              CONSTANT      NUMBER      := 0;

-- Define global variables to be passed to PMF-BSC API.
g_Bsc_Pmf_Ui_Rec      BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type;
g_Bsc_Pmf_Dim_Tbl     BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Tbl_Type;
g_Fire                varchar2(3);




FUNCTION remove_percent(
  p_input IN VARCHAR2
) RETURN NUMBER;


-- adrao added

FUNCTION Is_More
(
        p_dim_short_names IN  OUT NOCOPY  VARCHAR2
    ,   p_dim_name        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
    l_pos_rel_columns       NUMBER;
BEGIN
    IF (p_dim_short_names IS NOT NULL) THEN
        l_pos_ids           := INSTR(p_dim_short_names,   ','); -- adeulgao changed from ";" to ","
        IF (l_pos_ids > 0) THEN
            p_dim_name      :=  TRIM(SUBSTR(p_dim_short_names,    1,    l_pos_ids - 1));

            p_dim_short_names     :=  TRIM(SUBSTR(p_dim_short_names,    l_pos_ids + 1));
        ELSE
            p_dim_name      :=  TRIM(p_dim_short_names);

            p_dim_short_names     :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;


procedure Fire_Api(
  p_api_call    varchar2
  ) is

begin
   FND_MSG_PUB.Initialize;
  if p_api_call = 'YES' then
  g_Fire := 'YES';
  else
  g_Fire := 'NO';
  end if;

EXCEPTION
  when others then
    rollback;
end Fire_Api;


procedure Table_Generator(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_id                      number
 ,p_meas_short_name             varchar2
 ,p_dim_level_short_name        varchar2
) is

l_commit      varchar2(10);
l_return_status     varchar2(100);
l_error_tbl     BIS_UTILITIES_PUB.Error_Tbl_Type;
l_msg_count     number;
l_msg_data      varchar2(255);
l_bad_level     varchar2(50);

l_tbl_cnt     number;

begin
   FND_MSG_PUB.Initialize;
  g_Bsc_Pmf_Ui_Rec.Kpi_id := to_number(p_kpi_id);
  g_Bsc_Pmf_Ui_Rec.Measure_Short_Name := p_meas_short_name;

  l_tbl_cnt := g_Bsc_Pmf_Dim_Tbl.count;

  g_Bsc_Pmf_Dim_Tbl(l_tbl_cnt + 1).Dimension_Level_Short_Name := p_dim_level_short_name;

  if g_Fire = 'YES' then
    BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Api( FND_API.G_FALSE
                                      ,g_Bsc_Pmf_Ui_Rec
                                      ,g_Bsc_Pmf_Dim_Tbl
                                      ,0
                                      ,l_bad_level
                                      ,l_return_status
                                      ,l_msg_count
                                      ,l_msg_data);
    for i in 1..g_Bsc_Pmf_Dim_Tbl.count loop
      g_Bsc_Pmf_Dim_Tbl.delete(i);
    end loop;
    g_Bsc_Pmf_Ui_Rec := null;

  end if;
  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    FND_MSG_PUB.Count_And_Get( p_count  =>      l_msg_count
                              ,p_data   =>      l_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    FND_MSG_PUB.Count_And_Get( p_count    =>      l_msg_count
                              ,p_data     =>      l_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    FND_MSG_PUB.Count_And_Get( p_count    =>      l_msg_count
                              ,p_data     =>      l_msg_data);
  WHEN OTHERS THEN
    rollback;
    FND_MSG_PUB.Count_And_Get( p_count    =>      l_msg_count
                              ,p_data     =>      l_msg_data);
end Table_Generator;

/************************************************************************************
************************************************************************************/

-- this procedure creates analysis options in a KPI.  No commits are passed to the
-- BSC APIs because these commits will undo the indicator lock.  The commit is
-- executed at the end of this procedure.

PROCEDURE Add_Analysis_Option(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_option_name                 IN VARCHAR2
 ,p_option_description          IN VARCHAR2
 ,p_meas_short_name             IN VARCHAR2
 ,p_dim_level_short_names       IN VARCHAR2
 ,p_kpi_id                      IN NUMBER
 ,x_bad_level           OUT NOCOPY     varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2

) IS

TYPE Recdc_value    IS REF CURSOR;
dc_value      Recdc_value;

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_sql       varchar2(1000);

l_kpi_id      number;

  l_commit              VARCHAR2(10) := FND_API.G_FALSE;
  l_return_status VARCHAR2(100);
  l_error_tbl           BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(255);
  l_dim_level           VARCHAR2(100);
  l_dim_levels          VARCHAR2(32000);
  l_dim_levels_count    NUMBER;
  l_dim_levels_table    BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Tbl_Type;
  l_analysis_option_rec BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Rec_Type;
  l_pos                 NUMBER;

  -- following set of variables add to support Default and View by Levels.
  l_bis_dim_levels  varchar2(5000);
  l_bis_end   number;
  l_bis_lvl_status  varchar2(10);
  l_temp    varchar2(30);

  l_cntr    number;


BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- The first thing to do is not to allow

  l_analysis_option_rec.Kpi_id := p_kpi_id;
  l_analysis_option_rec.Measure_Short_Name := p_meas_short_name;
  l_analysis_option_rec.Option_Name := p_option_name;
  l_analysis_option_rec.Option_Description := p_option_description;
  l_dim_levels := p_dim_level_short_names;
  l_dim_levels_count := 0;


  -- This called could be made from two different places in IBuilder, when importing
  -- a measure from BIS, or when adding a measure already within BSC.  If importing
  -- from BIS then we need to handle it differently.
  --
  -- A BIS measure import will contain the string "BIS;" as its first 4 characters.
  -- The entire string will have the following format:
  -- 'BIS;'DIMLEVEL1;DIMLEVEL2;DIMLEVEL3;DFL;DIMLEVEL1,LD;DIMLEVEL3,LD;DIMLEVEL3;C'
  -- where from "BIS" to "DFL" contains all dimension levels.  After "DFL" a dimension level
  -- with "LD" is a default Dimension Level, and a level with "C" is a 'View by' Level.

  if (substr(p_dim_level_short_names, 1,4) = 'BIS;') then
   -- l_bis_dim_levels := p_dim_level_short_names;
    -- get a string containing onlya the dimension levels with no ALL or View by info.
    l_bis_dim_levels := substr(p_dim_level_short_names, 5, (instr(p_dim_level_short_names, 'DFL;') - 5));

    -- assign the dimension levels to the TABLE type.
    while length(l_bis_dim_levels) > 0 loop
      l_pos := instr(l_bis_dim_levels, ';');
      if l_pos > 0 then
        l_dim_level := ltrim(rtrim(substr(l_bis_dim_levels, 1, l_pos - 1)));
        l_bis_dim_levels := substr(l_bis_dim_levels, l_pos + 1, length(l_bis_dim_levels));
      else
        l_dim_level := ltrim(rtrim(l_bis_dim_levels));
        l_bis_dim_levels := '';
      end if;

      if length(l_dim_level) > 0 THEN
        l_dim_levels_count := l_dim_levels_count + 1;
        l_dim_levels_table(l_dim_levels_count).Dimension_Level_Short_Name := l_dim_level;
      end if;

    end loop;

    -- reset l_bis_dim_levels to read the rest of the string containing info
    -- on view by or ALL
    l_bis_dim_levels := substr(p_dim_level_short_names, (instr(p_dim_level_short_names, 'DFL;') + 4));

    -- parse string into levels and their ALL or view by value.
    while length(l_bis_dim_levels) > 0 loop
      l_pos := instr(l_bis_dim_levels, ';');
      if l_pos > 0 then
        l_dim_level := ltrim(rtrim(substr(l_bis_dim_levels, 1, l_pos - 1)));
        l_bis_dim_levels := substr(l_bis_dim_levels, l_pos + 1, length(l_bis_dim_levels));
      else
        l_dim_level := ltrim(rtrim(l_bis_dim_levels));
        l_bis_dim_levels := '';
      end if;

      if length(l_dim_level) > 0 THEN
        l_dim_levels_count := l_dim_levels_count + 1;
      end if;

      -- Now extract whether this level is ALL (LD) or view by (C)
      l_bis_lvl_status := substr(l_dim_level, instr(l_dim_level, ',') + 1, length(l_dim_level) -1);
      l_dim_level := substr(l_dim_level, 1, instr(l_dim_level, ',') - 1);

      -- Now set the level ALL or View By value to the TABLE TYPE
      l_cntr := 1;
      for l_cntr in 1..l_dim_levels_table.count loop
        if (l_dim_levels_table(l_cntr).Dimension_Level_Short_Name = l_dim_level) then
          l_dim_levels_table(l_cntr).Dimension_Level_Status := l_bis_lvl_status;

        end if;
      end loop;

    end loop;


  else

    -- Parse the dimension level short names
    WHILE LENGTH(l_dim_levels) > 0 LOOP
      l_pos := INSTR(l_dim_levels, ';');

      IF l_pos > 0 THEN
        l_dim_level := LTRIM(RTRIM(SUBSTR(l_dim_levels, 1, l_pos - 1)));
        l_dim_levels := SUBSTR(l_dim_levels, l_pos + 1, LENGTH(l_dim_levels));
      ELSE
        l_dim_level := LTRIM(RTRIM(l_dim_levels));
        l_dim_levels := '';
      END IF;

      IF LENGTH(l_dim_level) > 0 THEN
        l_dim_levels_count := l_dim_levels_count + 1;
        l_dim_levels_table(l_dim_levels_count).Dimension_Level_Short_Name := l_dim_level;
      END IF;
    END LOOP;

  end if;

  -- call the api to create analysis option
  BSC_PMF_UI_API_PUB.Bsc_Pmf_Ui_Api(
    FND_API.G_FALSE,
    l_analysis_option_rec,
    l_dim_levels_table,
    0,
    x_bad_level,
    x_return_status,
    x_msg_count,
    x_msg_data);

    -- check value of x_bad_level, if not null then raise error.
    if (x_bad_level is not null) then
      RAISE FND_API.G_EXC_ERROR;
    end if;

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_kpi_id;

  BSC_KPI_PUB.Update_Kpi_Time_Stamp( FND_API.G_FALSE
                                    ,l_Bsc_Kpi_Entity_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);

  -- Add the analysis dimension levels to the shared Indicators.
  l_sql := 'select indicator ' ||
           '  from BSC_KPIS_B ' ||
           ' where source_indicator = :1';

  open dc_value for l_sql using p_kpi_id;
    loop
      fetch dc_value into l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_id;
      exit when dc_value%NOTFOUND;

      l_kpi_id := l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_id;

      BSC_DESIGNER_PVT.Duplicate_Record_by_Indicator('BSC_KPI_DIM_LEVELS_B', p_kpi_id, l_kpi_id);
      BSC_DESIGNER_PVT.Duplicate_Record_by_Indicator('BSC_KPI_DIM_LEVELS_TL', p_kpi_id, l_kpi_id);
      BSC_DESIGNER_PVT.Duplicate_Record_by_Indicator('BSC_KPI_DIM_GROUPS', p_kpi_id, l_kpi_id);
      BSC_DESIGNER_PVT.Duplicate_Record_by_Indicator('BSC_KPI_DIM_SETS_TL', p_kpi_id, l_kpi_id);
      BSC_DESIGNER_PVT.Duplicate_Record_by_Indicator('BSC_KPI_DIM_LEVEL_PROPERTIES', p_kpi_id, l_kpi_id);

      BSC_KPI_PUB.Update_Kpi_Time_Stamp( FND_API.G_FALSE
                                        ,l_Bsc_Kpi_Entity_Rec
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data);

    end loop;
  close dc_value;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK;
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
        ROLLBACK;
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
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Add_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Add_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Add_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Add_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Add_Analysis_Option;

/************************************************************************************
************************************************************************************/

--Modified procedure. It does not return the kpi_group_id.
procedure Create_Kpi_Group(
  p_commit              IN             VARCHAR2 := FND_API.G_TRUE
 ,p_tab_id              IN             number
 ,p_kpi_group_id        IN             number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_kpi_group_name      IN             varchar2
 ,p_kpi_group_help      IN             varchar2
) is

l_Bsc_Kpi_Group_Rec              BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;

l_commit                        varchar2(10);

--l_kpi_group_id      number;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_commit := FND_API.G_FALSE;
  SAVEPOINT  BSCCrtKPIGrpWrapper;

  --Call procedure to initialize Kpi Group Rec
  BSC_KPI_GROUP_PUB.Initialize_Kpi_Group_Rec(
                          p_Bsc_Kpi_Group_Rec => l_Bsc_Kpi_Group_Rec
                         ,x_Bsc_Kpi_Group_Rec => l_Bsc_Kpi_Group_Rec
                         ,x_return_status => x_return_status
                         ,x_msg_count => x_msg_count
                         ,x_msg_data => x_msg_data);
  IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- set the passed values to the record.
  l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name := p_kpi_group_name;
  /*Fix Bug #2608683 */
  l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Help := p_kpi_group_help;
  l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id := p_kpi_group_id;

/*  Below code has been commented until further review.

  -- The BSC APIs (following original builder functionality) assign Tab ID of -1
  -- as a default tab when a KPI group is first created.  Most of the logic in the
  -- current APIs assume this default tab id.
  -- However, for IBuilder (HTML builder) tab id of -1 is not being used.  Instead
  -- a "Library Tab" is being used, with id of -2.
  -- Therefore, in order to have both ends (UI and back end APIS) match, this wrapper
  -- calls the APIs passing null for the tab id.  This will assign it to tab -1.  This
  -- should only happen if the group is being created for the first time (UI tab id -2)
  -- After that we will call the APIs again, but with -2 (if first time) or with whatever
  -- tab id desired.
  if p_tab_id = -2 then
    l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id := -1;
    BSC_KPI_GROUP_PUB.Create_Kpi_Group( l_commit
                                       ,l_Bsc_Kpi_Group_Rec
                                       ,x_return_status
                                       ,x_msg_count
                                       ,x_msg_data);

    -- the following piece of code should be removed ASAP.  We need it due to the fact
    -- mentioned above (tabs -1, -2 , 2 different default tabs).  We need to assign a
    -- brand new KPI group to both tabs, however, after assigning to one, the group is no
    -- longer new.  We need to get the id for this group.
    -- To do this we ASSUME that the id that was created last is what was created in the
    -- previous call.  DANGEROUS.

    select MAX(ind_group_id)
      into l_kpi_group_id
      from BSC_TAB_IND_GROUPS_TL;

    l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id := l_kpi_group_id;
  end if;
*/

  -- set the Tab id to value passed.
  l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id := p_tab_id;

  if l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id is null then
    BSC_KPI_GROUP_PUB.Create_Kpi_Group( p_commit => l_commit
                                       ,p_Bsc_Kpi_Group_Rec => l_Bsc_Kpi_Group_Rec
                                       ,x_return_status => x_return_status
                                       ,x_msg_count => x_msg_count
                                       ,x_msg_data => x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  else
    BSC_KPI_GROUP_PUB.Update_Kpi_Group( FND_API.G_FALSE
                                       ,l_Bsc_Kpi_Group_Rec
                                       ,x_return_status
                                       ,x_msg_count
                                       ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  end if;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCCrtKPIGrpWrapper;
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
        ROLLBACK TO BSCCrtKPIGrpWrapper;
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
        ROLLBACK TO BSCCrtKPIGrpWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Create_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Create_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCCrtKPIGrpWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Create_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Create_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Create_Kpi_Group;



/************************************************************************************
************************************************************************************/

--New procedure. It returns the kpi_group_id.
procedure Create_Kpi_Group(
  p_commit                IN             VARCHAR2 := FND_API.G_FALSE
 ,p_tab_id                IN             NUMBER  -- It needs to pass NULL or -1  if you want to create a kpi group
 ,p_kpi_group_id          IN             NUMBER
 ,p_kpi_group_name        IN             VARCHAR2
 ,p_kpi_group_help        IN             VARCHAR2
 ,p_Kpi_Group_short_Name  IN             VARCHAR2 := NULL
 ,x_kpi_group_id          OUT NOCOPY     NUMBER  -- OUT parameter for kpi group id
 ,x_return_status         OUT NOCOPY     VARCHAR2
 ,x_msg_count             OUT NOCOPY     NUMBER
 ,x_msg_data              OUT NOCOPY     VARCHAR2
) is

l_Bsc_Kpi_Group_Rec              BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;
l_Bsc_Kpi_Group_Rec_Out          BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;

l_commit                        varchar2(10);

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_commit := FND_API.G_FALSE;  --local commit flag.
  SAVEPOINT  BSCCrtKPIGrpWrapper;

  --Call procedure to initialize Kpi Group Rec
  BSC_KPI_GROUP_PUB.Initialize_Kpi_Group_Rec(
          p_Bsc_Kpi_Group_Rec => l_Bsc_Kpi_Group_Rec
         ,x_Bsc_Kpi_Group_Rec => l_Bsc_Kpi_Group_Rec
         ,x_return_status     => x_return_status
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
  );
  IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- set the passed values to the record.
  l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name := p_kpi_group_name;
  l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Help := p_kpi_group_help;
  l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id := p_kpi_group_id;
  l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id := p_tab_id;
  l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Short_Name := p_Kpi_Group_short_Name;

  if l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id is null then
    BSC_KPI_GROUP_PUB.Create_Kpi_Group( p_commit => l_commit
                                       ,p_Bsc_Kpi_Group_Rec => l_Bsc_Kpi_Group_Rec
                                       ,x_Bsc_Kpi_Group_Rec => l_Bsc_Kpi_Group_Rec_Out
                                       ,x_return_status => x_return_status
                                       ,x_msg_count => x_msg_count
                                       ,x_msg_data => x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_kpi_group_id := l_Bsc_Kpi_Group_Rec_Out.Bsc_Kpi_Group_Id;

  else
    BSC_KPI_GROUP_PUB.Update_Kpi_Group( FND_API.G_FALSE
                                       ,l_Bsc_Kpi_Group_Rec
                                       ,x_return_status
                                       ,x_msg_count
                                       ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  end if;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

 --DBMS_OUTPUT.PUT_LINE('Created kpi_group_id '||x_kpi_group_id);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCCrtKPIGrpWrapper;
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
        ROLLBACK TO BSCCrtKPIGrpWrapper;
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
        ROLLBACK TO BSCCrtKPIGrpWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Create_Kpi_Group with parameter x_kpi_group_id ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Create_Kpi_Group with parameter x_kpi_group_id ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCCrtKPIGrpWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Create_Kpi_Group with parameter x_kpi_group_id ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Create_Kpi_Group with parameter x_kpi_group_id ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Create_Kpi_Group;


/************************************************************************************
************************************************************************************/

procedure Update_Kpi_Group(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_group_id                number
 ,p_kpi_group_name              varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_kpi_group_help              varchar2
) is

l_Bsc_Kpi_Group_Rec              BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;

l_commit                        varchar2(10);

l_kpi_group_id                  number;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCUpdKPIGrpWrapper;
  l_commit := FND_API.G_TRUE;

  l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id := p_kpi_group_id;
  l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Name := p_kpi_group_name;
  l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Help := p_kpi_group_help;

  -- set some defaults.  At the moment the UI is unable to set/pass these values.
  -- Added 'USERENV()' to implement NLS fix for Bug #2786053
  l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id := -1;
  l_Bsc_Kpi_Group_Rec.Bsc_Language := NVL(USERENV('LANG'),'US');
  l_Bsc_Kpi_Group_Rec.Bsc_Source_Language := 'US';


  BSC_KPI_GROUP_PUB.Update_Kpi_Group( FND_API.G_FALSE
                                     ,l_Bsc_Kpi_Group_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCUpdKPIGrpWrapper;
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
        ROLLBACK TO BSCUpdKPIGrpWrapper;
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
        ROLLBACK TO BSCUpdKPIGrpWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Update_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Update_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCUpdKPIGrpWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Update_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Update_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Update_Kpi_Group;

/************************************************************************************
************************************************************************************/

--Modified procedure. It does not return the kpi_id.
procedure Create_Kpi(
  p_commit              IN             VARCHAR2 := FND_API.G_TRUE
 ,p_group_id            IN             number
 ,p_responsibility_id   IN             number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_kpi_name            IN             varchar2
 ,p_kpi_help            IN             varchar2
) is

l_Bsc_Kpi_Entity_Rec              BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_commit                        varchar2(10);


begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCCreateKPIWrapper;
  l_commit := FND_API.G_FALSE;

  --Call procedure to initialize Kpi Entity Rec
  BSC_KPI_PUB.Initialize_Kpi_Entity_Rec(
                          p_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
                         ,x_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
                         ,x_return_status => x_return_status
                         ,x_msg_count => x_msg_count
                         ,x_msg_data => x_msg_data);
  IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- set the passed values to the record.
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id := p_group_id;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name := p_kpi_name;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help := p_kpi_help;
  l_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id := p_responsibility_id;


  BSC_KPI_PUB.Create_Kpi( p_commit => l_commit
                         ,p_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
                         ,x_return_status => x_return_status
                         ,x_msg_count => x_msg_count
                         ,x_msg_data => x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCCreateKPIWrapper;
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
        ROLLBACK TO BSCCreateKPIWrapper;
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
        ROLLBACK TO BSCCreateKPIWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Create_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Create_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCCreateKPIWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Create_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Create_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Kpi;


/************************************************************************************
************************************************************************************/

--New procedure. It returns the kpi_id.
procedure Create_Kpi(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_group_id            IN            NUMBER
 ,p_responsibility_id   IN            NUMBER
 ,p_kpi_name            IN            VARCHAR2
 ,p_kpi_help            IN            VARCHAR2
 ,p_Kpi_Short_Name      IN            VARCHAR2 := NULL
 ,p_Kpi_Indicator_Type  IN            NUMBER   := NULL
 ,x_kpi_id              OUT NOCOPY    NUMBER
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) is

l_Bsc_Kpi_Entity_Rec              BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
l_Bsc_Kpi_Entity_Rec_Out          BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
l_commit                          varchar2(10);

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCCreateKPIWrapper;
  l_commit := FND_API.G_FALSE;  --local commit flag.

  --Call procedure to initialize Kpi Entity Rec
  BSC_KPI_PUB.Initialize_Kpi_Entity_Rec(
                          p_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
                         ,x_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
                         ,x_return_status => x_return_status
                         ,x_msg_count => x_msg_count
                         ,x_msg_data => x_msg_data);
  IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- set the passed values to the record.
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id := p_group_id;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name := p_kpi_name;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help := p_kpi_help;
  l_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id := p_responsibility_id;

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Short_Name := p_Kpi_Short_Name;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Indicator_Type := p_Kpi_Indicator_Type;

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Config_Type := BSC_BIS_KPI_CRUD_PUB.C_NORMAL_INDICATOR_CONFIG_TYPE;

  IF(p_Kpi_Indicator_Type = BSC_BIS_KPI_CRUD_PUB.C_SIMULATION_INDICATOR)THEN
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Config_Type := BSC_BIS_KPI_CRUD_PUB.C_SIM_INDICATOR_CONFIG_TYPE;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Indicator_Type :=   BSC_BIS_KPI_CRUD_PUB.C_SINGLE_BAR_INDICATOR;
  END IF;


  BSC_KPI_PUB.Create_Kpi( p_commit => l_commit
                         ,p_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
                         ,x_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec_Out
                         ,x_return_status => x_return_status
                         ,x_msg_count => x_msg_count
                         ,x_msg_data => x_msg_data);
  IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_kpi_id := l_Bsc_Kpi_Entity_Rec_Out.Bsc_Kpi_Id;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

 --DBMS_OUTPUT.PUT_LINE('Created kpi_id '||x_kpi_id);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCCreateKPIWrapper;
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
        ROLLBACK TO BSCCreateKPIWrapper;
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
        ROLLBACK TO BSCCreateKPIWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Create_Kpi with parameter x_kpi_id ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Create_Kpi with parameter x_kpi_id ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCCreateKPIWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Create_Kpi with parameter x_kpi_id ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Create_Kpi with parameter x_kpi_id ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Kpi;


/************************************************************************************
************************************************************************************/

procedure Update_Kpi(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_id            IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_kpi_name            IN      varchar2 DEFAULT null
 ,p_kpi_help            IN      varchar2 DEFAULT null
) is

l_Bsc_Kpi_Entity_Rec              BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

TYPE Recdc_value                IS REF CURSOR;
dc_value                        Recdc_value;

l_commit                        varchar2(10);
l_sql                           varchar2(1000);
l_tab_name                      BSC_TABS_TL.NAME%TYPE;

l_count       number;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCUpdateKPIWrapper;
  l_commit := FND_API.G_TRUE;

  l_count := 0;

  -- We need to check if there is an update on the Indicator name in order
  -- to prevent it.  To do this we need to check if there is a different
  -- indicator in the same tab  with the same name.
  select count(indicator)
    into l_count
    from bsc_tab_indicators a
   where a.indicator <> p_kpi_id
     and a.tab_id = (select tab_id
                       from bsc_tab_indicators
                      where indicator = p_kpi_id)
     and a.indicator in (select indicator
                           from bsc_kpis_tl
                          where name = p_kpi_name);

  if l_count <> 0 then
    select d.name
      into l_tab_name
      from BSC_TAB_INDICATORS a,
           BSC_KPIS_TL b,
           BSC_KPIS_TL c,
           BSC_TABS_TL d
     where a.indicator = b.indicator
       and a.tab_id = d.tab_id
       and b.name = c.name
       and c.indicator = p_kpi_id;

    FND_MESSAGE.SET_NAME('BSC','BSC_B_NO_SAMEKPI_TAB');
    FND_MESSAGE.SET_TOKEN('Indicator name: ', p_kpi_name);
    FND_MESSAGE.SET_TOKEN('Tab name: ', l_tab_name);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;


  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_kpi_id;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name := p_kpi_name;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help := p_kpi_help;

  -- set some default values.
  l_Bsc_Kpi_Entity_Rec.Bsc_Language := 'US';
  l_Bsc_Kpi_Entity_Rec.Bsc_Source_Language:= 'US';

  -- Calling private version.  The public version does a few things which
  -- are not supported yet.  When those features are supported (Update
  -- Properties, Update Defaults, etc.) then the call should be changed
  -- to the Public version.  The UI only allows "Updates" on Master Indicators
  -- so it is assumed the Indicator currently being handled is the Masater Indicator.

  BSC_KPI_PVT.Update_Kpi( FND_API.G_FALSE
                         ,l_Bsc_Kpi_Entity_Rec
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


  -- The public version of the API determines how many shared indicators there
  -- are.  However since we are bypassing the Public version we need to determine
  -- those indicators here.  Once we call the Public version again then we can
  -- remove this block.

  -- determine if there are any shared KPI based on this KPI.
  select count(indicator)
    into l_count
    from BSC_KPIS_B
   where source_indicator = p_kpi_id;

  -- if there are any shared KPIs update those also.
  if l_count > 0 then

    l_sql := 'select indicator ' ||
             '  from BSC_KPIS_B ' ||
             ' where source_indicator = :1';

    open dc_value for l_sql using p_kpi_id;
      loop
        fetch dc_value into l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
        exit when dc_value%NOTFOUND;

        BSC_KPI_PVT.Update_Kpi( FND_API.G_FALSE
                               ,l_Bsc_Kpi_Entity_Rec
                               ,x_return_status
                               ,x_msg_count
                               ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


      END LOOP;
    close dc_value;

  end if;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCUpdateKPIWrapper;
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
        ROLLBACK TO BSCUpdateKPIWrapper;
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
        ROLLBACK TO BSCUpdateKPIWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Update_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Update_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCUpdateKPIWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Update_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Update_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Update_Kpi;

/************************************************************************************
************************************************************************************/

--It doesn't need to be modified for enhancement#3493589.
procedure Create_Tab
(   p_commit                IN          VARCHAR2 := FND_API.G_TRUE
  , p_responsibility_id     IN          NUMBER
  , x_return_status         OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  , p_tab_name              IN          VARCHAR2 := NULL
  , p_tab_help              IN          VARCHAR2 := NULL
) IS
    l_Bsc_Tab_Entity_Rec            BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;
    l_commit                        VARCHAR2(10);
    l_tab_Id                        NUMBER;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT BSCPMFUICrtTab;
    l_commit            := FND_API.G_TRUE;
    BSC_PMF_UI_WRAPPER.Create_Tab
    (   p_commit             =>   FND_API.G_FALSE
      , p_responsibility_id  =>   p_responsibility_id
      , p_parent_tab_id      =>   NULL
      , p_owner_id           =>   NULL
      , x_tab_id             =>   l_tab_Id
      , x_return_status      =>   x_return_status
      , x_msg_count          =>   x_msg_count
      , x_msg_data           =>   x_msg_data
      , p_tab_name           =>   p_tab_name
      , p_tab_help           =>   p_tab_help
      , p_tab_info           =>   NULL
    );
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCPMFUICrtTab;
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
        ROLLBACK TO BSCPMFUICrtTab;
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
        ROLLBACK TO BSCPMFUICrtTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Create_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Create_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCPMFUICrtTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Create_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Create_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Create_Tab;

/************************************************************************************
************************************************************************************/

--modified procedure to correct the way to get the tab_id
-- Modifed Procedure to accept SHORT_NAME
PROCEDURE Create_Tab
(   p_Commit            IN          VARCHAR2 := FND_API.G_TRUE --should be false
  , p_Responsibility_Id IN          NUMBER
  , p_Parent_Tab_Id     IN          NUMBER
  , p_Owner_Id          IN          NUMBER
  , p_Short_Name        IN          VARCHAR2 := NULL
  , x_tab_id            OUT NOCOPY  NUMBER
  , x_return_status     OUT NOCOPY  VARCHAR2
  , x_msg_count         OUT NOCOPY  NUMBER
  , x_msg_data          OUT NOCOPY  VARCHAR2
  , p_tab_name          IN          VARCHAR2 := NULL
  , p_tab_help          IN          VARCHAR2 := NULL
  , p_tab_info          IN          VARCHAR2 := NULL
) IS
    l_Bsc_Tab_Entity_Rec        BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;
    l_Bsc_Tab_Entity_Rec_Out    BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;
    l_Bsc_Tab_Entity_Rec_P      BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;
    l_commit                    VARCHAR2(10);
    l_parent_tab_id             NUMBER := NULL;
BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCPMFUICrtTab1;
    l_commit := FND_API.G_FALSE;
    -- check value of parent_tab_id.  If value is -2 then the tab about to be created is
    -- a root tab (no parent), else this new tab will have a parent.
    IF (p_parent_tab_id >= 0) THEN
        l_parent_tab_id := p_parent_tab_id;
    END IF;

  --Call procedure to initialize Tab Entity Rec
  BSC_SCORECARD_PUB.Initialize_Tab_Entity_Rec(
                          p_Bsc_Tab_Entity_Rec => l_Bsc_Tab_Entity_Rec
                         ,x_Bsc_Tab_Entity_Rec => l_Bsc_Tab_Entity_Rec
                         ,x_return_status => x_return_status
                         ,x_msg_count => x_msg_count
                         ,x_msg_data => x_msg_data);
  IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- set the passed values to the record.
    l_Bsc_Tab_Entity_Rec.Bsc_Parent_Tab_Id      := l_parent_tab_id;
    l_Bsc_Tab_Entity_Rec.Bsc_Responsibility_Id  := p_responsibility_id;
    l_Bsc_Tab_Entity_Rec.Bsc_Owner_Id           := p_owner_id;
    l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name           := TRIM(p_tab_name);
    l_Bsc_Tab_Entity_Rec.Bsc_Tab_Help           := p_tab_help;
    l_Bsc_Tab_Entity_Rec.Bsc_Tab_Info           := p_tab_info;
    l_Bsc_Tab_Entity_Rec.Bsc_Short_Name         := p_Short_Name;



    BSC_SCORECARD_PUB.Create_Tab( p_commit => l_commit
                                , p_Bsc_Tab_Entity_Rec => l_Bsc_Tab_Entity_Rec
                                , x_Bsc_Tab_Entity_Rec => l_Bsc_Tab_Entity_Rec_Out
                                , x_return_status => x_return_status
                                , x_msg_count => x_msg_count
                                , x_msg_data => x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_tab_id := l_Bsc_Tab_Entity_Rec_Out.Bsc_Tab_Id;

    --Only for parent tab.
    l_Bsc_Tab_Entity_Rec_P.Bsc_Tab_Id := p_parent_tab_id;

    --Update the tab time stamp for parent tab.
    IF (p_parent_tab_id is not NULL) THEN
       BSC_SCORECARD_PUB.Update_Tab_Time_Stamp( FND_API.G_FALSE
                                              , l_Bsc_Tab_Entity_Rec_P
                                              , x_return_status
                                              , x_msg_count
                                              , x_msg_data);
       IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    --update the system time stamp.
    BSC_SCORECARD_PUB.Update_System_Time_Stamp( FND_API.G_FALSE
                                              , l_Bsc_Tab_Entity_Rec
                                              , x_return_status
                                              , x_msg_count
                                              , x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

    --DBMS_OUTPUT.PUT_LINE('Created tab_id '||x_tab_id);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCPMFUICrtTab1;
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
        ROLLBACK TO BSCPMFUICrtTab1;
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
        ROLLBACK TO BSCPMFUICrtTab1;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Create_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Create_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCPMFUICrtTab1;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Create_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Create_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Create_Tab;


/************************************************************************************
************************************************************************************/

-- this procedure updates a tab in BSC.  No commits are passed to the
-- BSC APIs because these commits will undo the indicator lock.  The commit is
-- executed at the end of this procedure.

procedure Update_Tab(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_tab_id    IN      number
 ,p_tab_name            IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_tab_help            IN      varchar2 DEFAULT null
) is

l_Bsc_Tab_Entity_Rec            BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;

l_commit                        varchar2(10);

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCPMFUIUpdTab;
   BSC_PMF_UI_WRAPPER.Update_Tab
   (    p_commit        =>  FND_API.G_FALSE
     ,  p_tab_id        =>  p_tab_id
     ,  p_owner_id      =>  NULL
     ,  p_tab_name      =>  p_tab_name
     ,  x_return_status =>  x_return_status
     ,  x_msg_count     =>  x_msg_count
     ,  x_msg_data      =>  x_msg_data
     ,  p_tab_help      =>  p_tab_help
     ,  p_tab_info      =>  NULL
     ,  p_time_stamp    =>  NULL
    );
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCPMFUIUpdTab;
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
        ROLLBACK TO BSCPMFUIUpdTab;
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
        ROLLBACK TO BSCPMFUIUpdTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Update_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Update_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCPMFUIUpdTab;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Update_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Update_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Update_Tab;

/************************************************************************************
************************************************************************************/

-- this procedure updates a tab in BSC.  No commits are passed to the
-- BSC APIs because these commits will undo the indicator lock.  The commit is
-- executed at the end of this procedure.

procedure Update_Tab(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_tab_id    IN      number
 ,p_owner_id    IN  number
 ,p_tab_name            IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_tab_help            IN      varchar2 DEFAULT null
 ,p_tab_info            IN      varchar2 DEFAULT null
 ,p_time_stamp          IN      VARCHAR2 := NULL

) is

l_Bsc_Tab_Entity_Rec            BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;

  l_commit                        varchar2(10);
  l_Count                       NUMBER := 0;
  CURSOR c_Tab_Name IS
  SELECT Name
  FROM   BSC_TABS_VL
  WHERE  Tab_Id = l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id;
begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCPMFUIUpdTab1;
  l_commit := FND_API.G_FALSE;

  IF (c_Tab_Name%ISOPEN) THEN
    CLOSE c_Tab_Name;
  END IF;
  l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id   := p_tab_id;
  OPEN c_Tab_Name;
      FETCH c_Tab_Name INTO l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name;
  CLOSE c_Tab_Name;
  IF (l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
    FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_IVIEWER', 'SCORECARD'), TRUE);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF ((p_tab_name IS NOT NULL) AND (l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name <> p_tab_name)) THEN
      l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name := TRIM(p_tab_name);

      SELECT COUNT(*) INTO l_Count
      FROM   BSC_TABS_VL
      WHERE  Tab_Id     <> l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
      AND    UPPER(Name) = UPPER(l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name);
      IF (l_Count <> 0) THEN
          FND_MESSAGE.SET_NAME('BSC',      'BSC_TAB_NAME_EXISTS');
          FND_MESSAGE.SET_TOKEN('BSC_TAB',  l_Bsc_Tab_Entity_Rec.Bsc_Tab_Name);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;

  l_Bsc_Tab_Entity_Rec.Bsc_Tab_Help := p_tab_help;
  l_Bsc_Tab_Entity_Rec.Bsc_Owner_Id := p_owner_id;
  if p_tab_info is null then
        -- Set space when is null in order to delete the contens of the column --
  l_Bsc_Tab_Entity_Rec.Bsc_Tab_Info := ' ';
  else
    l_Bsc_Tab_Entity_Rec.Bsc_Tab_Info := p_tab_info;
  end if;

  --set some default values
  l_Bsc_Tab_Entity_Rec.Bsc_Language := 'US';
  l_Bsc_Tab_Entity_Rec.Bsc_Source_Language := 'US';
  BSC_BIS_LOCKS_PUB.LOCK_TAB(
           p_tab_id          => p_tab_id
          ,p_time_stamp             => p_time_stamp  -- Granular Locking
          ,x_return_status          => x_return_status
          ,x_msg_count              => x_msg_count
          ,x_msg_data               => x_msg_data
  );
    IF ((x_return_status IS NOT NULL)AND(x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


  BSC_SCORECARD_PUB.Update_Tab( FND_API.G_FALSE
                               ,l_Bsc_Tab_Entity_Rec
                               ,x_return_status
                               ,x_msg_count
                               ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  BSC_SCORECARD_PUB.Update_Tab_Time_Stamp( FND_API.G_FALSE
                                          ,l_Bsc_Tab_Entity_Rec
                                          ,x_return_status
                                          ,x_msg_count
                                          ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  BSC_SCORECARD_PUB.Update_System_Time_Stamp( FND_API.G_FALSE
                                             ,l_Bsc_Tab_Entity_Rec
                                             ,x_return_status
                                             ,x_msg_count
                                             ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
--DBMS_OUTPUT.PUT_LINE('End Update_Tab ');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCPMFUIUpdTab1;
        IF (c_Tab_Name%ISOPEN) THEN
            CLOSE c_Tab_Name;
        END IF;
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
        ROLLBACK TO BSCPMFUIUpdTab1;
        IF (c_Tab_Name%ISOPEN) THEN
            CLOSE c_Tab_Name;
        END IF;
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
        ROLLBACK TO BSCPMFUIUpdTab1;
        IF (c_Tab_Name%ISOPEN) THEN
            CLOSE c_Tab_Name;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Update_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Update_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCPMFUIUpdTab1;
        IF (c_Tab_Name%ISOPEN) THEN
            CLOSE c_Tab_Name;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Update_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Update_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Update_Tab;

/************************************************************************************
************************************************************************************/

procedure Update_Analysis_Option(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_id              IN      number
 ,p_option_group_id IN  number
 ,p_option_id   IN  number
 ,p_option_name   IN  varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_option_help            IN      varchar2 DEFAULT null
) is

l_Bsc_Option_Rec    BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

l_commit                        varchar2(10);

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCPMFUIUpdAnaOpt;
  l_commit := FND_API.G_FALSE;

  l_Bsc_Option_Rec.Bsc_Kpi_Id := p_kpi_id;
  l_Bsc_Option_Rec.Bsc_Analysis_Group_Id := p_option_group_id;
  l_Bsc_Option_Rec.Bsc_Analysis_Option_Id := p_option_id;
  l_Bsc_Option_Rec.Bsc_Option_Name := p_option_name;
  l_Bsc_Option_Rec.Bsc_Option_Help := p_option_help;
  l_Bsc_Option_Rec.Bsc_Option_Group0 := p_option_group_id;
  l_Bsc_Option_Rec.Bsc_Option_Group1 := 0;
  l_Bsc_Option_Rec.Bsc_Option_Group2 := 0;

  -- set some default values.
  l_Bsc_Option_Rec.Bsc_Language := 'US';
  l_Bsc_Option_Rec.Bsc_Source_Language := 'US';

  BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options( FND_API.G_FALSE
                                                  ,l_Bsc_Option_Rec
                                                  ,x_return_status
                                                  ,x_msg_count
                                                  ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_kpi_id;
  BSC_KPI_PUB.Update_Kpi_Time_Stamp( FND_API.G_FALSE
                                    ,l_Bsc_Kpi_Entity_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback to BSCPMFUIUpdAnaOpt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback to BSCPMFUIUpdAnaOpt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback to BSCPMFUIUpdAnaOpt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback to BSCPMFUIUpdAnaOpt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

end Update_Analysis_Option;

/************************************************************************************
************************************************************************************/

procedure Delete_Analysis_Option(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_id    IN  number
 ,p_option_group_id IN  number
 ,p_option_id   IN  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

TYPE Recdc_opt      IS REF CURSOR;
dc_opt        Recdc_opt;
dc_shr        Recdc_opt;

TYPE Recdc_opt1     IS REF CURSOR;
dc_opt1       Recdc_opt1;

l_Bsc_Anal_Opt_Rec    BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
l_Bsc_Dim_Set_Rec_Type    BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

l_commit      varchar2(10);
l_opt_sql     varchar2(1000);
l_opt_sql1      varchar2(1000);
l_shr_sql     varchar2(1000);

l_dim_set_id      number;
l_count       number;
l_ind_tab_count                 number;
l_tab_id                        number;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_commit := FND_API.G_FALSE;

  -- set some of the values for the Record Type
  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id := p_kpi_id;
  l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id := p_option_group_id;
  l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id := p_option_id;

  -- we also need to normalize the values for column ANALYSYS_OPTION0,
  -- ANALYSYS_OPTION1, ANALYSYS_OPTION2 based on group id.
  if p_option_group_id = 0 then
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0 := p_option_id;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1 := 0;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2 := 0;
  elsif p_option_group_id = 1 then
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1 := p_option_id;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0 := 0;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2 := 0;
  else
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2 := p_option_id;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0 := 0;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1 := 0;
  end if;

  --Determine if Indicator assigned to a tab.
  select count(indicator)
    into l_ind_tab_count
    from BSC_TAB_INDICATORS
   where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  -- if indicator assigned to tab get tab id.
  if l_ind_tab_count > 0 then

    select tab_id
      into l_tab_id
    from BSC_TAB_INDICATORS
   where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  end if;


  -- obtain dimension set id this option is using.
  select dim_set_id
    into l_dim_set_id
    from BSC_KPI_ANALYSIS_OPTIONS_B
   where indicator = p_kpi_id
     and analysis_group_id = p_option_group_id
     and option_id = p_option_id;


  -- Call Analysis Option API.
  BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Options( FND_API.G_FALSE
                                                  ,l_Bsc_Anal_Opt_Rec
                                                  ,x_return_status
                                                  ,x_msg_count
                                                  ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_kpi_id;
  BSC_KPI_PUB.Update_Kpi_Time_Stamp( FND_API.G_FALSE
                                    ,l_Bsc_Kpi_Entity_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  -- Determine if the dimension set is being used by other options.
  select count(option_id)
    into l_count
    from BSC_KPI_ANALYSIS_OPTIONS_B
   where indicator = p_kpi_id
     and dim_set_id = l_dim_set_id;

  -- If there are no more options using this dim set delete it.
  if l_count = 0 then

    --populate Dimension Set Record.
    l_Bsc_Dim_Set_Rec_Type.Bsc_Dim_Set_Id := l_dim_set_id;


    -- If deleting the dimension set, then delete it from all indicators,
    -- master,  and shared.

    l_shr_sql := 'select indicator ' ||
                 '  from BSC_KPIS_B ' ||
                 ' where indicator = :1' ||
                 '    or source_indicator = :2';

    open dc_shr for l_shr_sql using p_kpi_id, p_kpi_id;
      loop
        fetch dc_shr into l_Bsc_Dim_Set_Rec_Type.Bsc_Kpi_Id ;
        exit when dc_shr%NOTFOUND;

        --Determine if Indicator assigned to a tab.
        select count(indicator)
          into l_ind_tab_count
          from BSC_TAB_INDICATORS
         where indicator = l_Bsc_Dim_Set_Rec_Type.Bsc_Kpi_Id;

        -- if indicator assigned to tab get indicator.
        if l_ind_tab_count > 0 then
          select tab_id
            into l_tab_id
          from BSC_TAB_INDICATORS
         where indicator = l_Bsc_Dim_Set_Rec_Type.Bsc_Kpi_Id;
        end if;



        -- get dimension groups in this dimension set for this indicator.
        l_opt_sql := 'select dim_group_id ' ||
                 '  from BSC_KPI_DIM_GROUPS ' ||
                 ' where indicator = :1' ||
                 '   and dim_set_id = :2';

        open dc_opt for l_opt_sql using l_Bsc_Dim_Set_Rec_Type.Bsc_Kpi_Id, l_Bsc_Dim_Set_Rec_Type.Bsc_Dim_Set_Id;
          loop
            fetch dc_opt into l_Bsc_Dim_Set_Rec_Type.Bsc_Dim_Level_Group_Id;
            exit when dc_opt%NOTFOUND;

            BSC_DIMENSION_SETS_PVT.Delete_Dim_Group_In_Dset( FND_API.G_FALSE
                                                            ,l_Bsc_Dim_Set_Rec_Type
                                                            ,x_return_status
                                                            ,x_msg_count
                                                            ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

--        l_Bsc_Dim_Set_Rec_Type.Bsc_Action := 'RESET';

          end loop;
        close dc_opt;

        -- Delete the levels from the kpi and dimension set.
        delete from BSC_KPI_DIM_LEVEL_PROPERTIES
         where indicator = l_Bsc_Dim_Set_Rec_Type.Bsc_Kpi_Id
           and dim_set_id = l_dim_set_id;


        BSC_DIMENSION_SETS_PVT.Delete_Dim_Levels( FND_API.G_FALSE
                                                 ,l_Bsc_Dim_Set_Rec_Type
                                                 ,x_return_status
                                                 ,x_msg_count
                                                 ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

        BSC_DIMENSION_SETS_PUB.Delete_Bsc_Kpi_Dim_Sets_Tl( FND_API.G_FALSE
                                                          ,l_Bsc_Dim_Set_Rec_Type
                                                          ,x_return_status
                                                          ,x_msg_count
                                                          ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

        -- Need to call procedure for list button logic.
        BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels( FND_API.G_FALSE
                                                          ,l_tab_id
                                                          ,x_return_status
                                                          ,x_msg_count
                                                          ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

       end loop;

    close dc_shr;

  end if;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

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
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);



end Delete_Analysis_Option;

/************************************************************************************
************************************************************************************/

procedure Delete_Kpi(
  p_commit              IN            VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_id              IN            NUMBER
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) is

l_Bsc_Kpi_Entity        BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
l_Bsc_Tab_Entity_Rec    BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;
l_commit                VARCHAR2(10);
l_count                 NUMBER;
l_Tab_Id                BSC_TABS_B.Tab_Id%TYPE;
l_Row_Count             NUMBER;
l_Tabs_Tbl_Type         BSC_PMF_UI_WRAPPER.Bsc_Tabs_Tbl_Rec;


CURSOR c_Tab_Id IS
SELECT DISTINCT A.Tab_Id
FROM   BSC_TAB_INDICATORS     A
     , BSC_KPIS_B             B
     , BSC_SYS_FILTERS_VIEWS  C
WHERE  A.Indicator    = B.Indicator
AND    C.Source_Type  = BSC_DIM_FILTERS_PUB.Source_Type_Tab
AND    C.Source_Code  = A.Tab_Id
AND    ((B.Indicator  = p_kpi_id) OR (B.Source_Indicator = p_kpi_id));

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCDelKPIWrapper;
  l_commit := FND_API.G_TRUE;

  -- check if this Indicator has been assigned to a Tab.
  select count(tab_id)
    into l_count
    from BSC_TAB_INDICATORS
   where indicator = p_kpi_id;

  if l_count > 0 then
    -- Get the tab id for this indicator.
    select tab_id
    into l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id
    from BSC_TAB_INDICATORS
    where indicator = p_kpi_id;
  end if;

  -- set some of the values for the Record Type
  l_Bsc_Kpi_Entity.Bsc_Kpi_Id := p_kpi_id;

  l_Row_Count := 0;

  FOR cd IN c_Tab_Id LOOP
   l_Tabs_Tbl_Type(l_Row_Count).Bsc_tab_id := cd.Tab_Id;
   l_Row_Count := l_Row_Count + 1;
  END LOOP;

  BSC_KPI_PUB.Delete_Kpi( FND_API.G_FALSE
                         ,l_Bsc_Kpi_Entity
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  -- if indicator assigned to a tab then get tab id and update time stamp.

  FOR i IN 0..(l_Tabs_Tbl_Type.COUNT-1 ) LOOP
    BSC_DIM_FILTERS_PUB.Check_Filters_Not_Apply
      (   p_Tab_Id         =>  l_Tabs_Tbl_Type(i).Bsc_tab_id
       ,  x_return_status  =>  x_return_status
       ,  x_msg_count      =>  x_msg_count
       ,  x_msg_data       =>  x_msg_data
      );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('BSC_PMF_UI_WRAPPER.Delete_Kpi Failed: at BSC_DIM_FILTERS_PUB.Check_Filters_Not_Apply');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END LOOP;

  if l_count > 0 then

    BSC_SCORECARD_PUB.Update_Tab_Time_Stamp( FND_API.G_FALSE
                                            ,l_Bsc_Tab_Entity_Rec
                                            ,x_return_status
                                            ,x_msg_count
                                            ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  end if;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

        IF(c_Tab_Id%ISOPEN) THEN
          CLOSE c_Tab_Id;
        END IF;

        ROLLBACK TO BSCDelKPIWrapper;
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

        IF(c_Tab_Id%ISOPEN) THEN
           CLOSE c_Tab_Id;
        END IF;
        ROLLBACK TO BSCDelKPIWrapper;
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

        IF(c_Tab_Id%ISOPEN) THEN
           CLOSE c_Tab_Id;
        END IF;
        ROLLBACK TO BSCDelKPIWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Delete_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Delete_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN

        IF(c_Tab_Id%ISOPEN) THEN
           CLOSE c_Tab_Id;
        END IF;
        ROLLBACK TO BSCDelKPIWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Delete_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Delete_Kpi ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
end Delete_Kpi;

/************************************************************************************
************************************************************************************/

procedure Delete_Kpi_Group(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_group_id  IN      number
 ,p_tab_id    IN  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

  l_Bsc_Kpi_Group                 BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;
  l_commit                        varchar2(10);
  l_count                         NUMBER;
  l_group_name                    BSC_TAB_IND_GROUPS_TL.name%TYPE;
begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCDelKPIGrpWrapper;
  l_commit := FND_API.G_TRUE;

  -- set some of the values for the Record Type
  l_Bsc_Kpi_Group.Bsc_Kpi_Group_Id := p_kpi_group_id;
  l_Bsc_Kpi_Group.Bsc_Tab_Id       := p_tab_id;
  --before deleteing indicator group, delete all the indicators first

  BSC_KPI_GROUP_PUB.Delete_Kpi_Group( FND_API.G_FALSE
                                     ,l_Bsc_Kpi_Group
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCDelKPIGrpWrapper;
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
        ROLLBACK TO BSCDelKPIGrpWrapper;
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
        ROLLBACK TO BSCDelKPIGrpWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Delete_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Delete_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCDelKPIGrpWrapper;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Delete_Kpi_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Delete_Kpi_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Delete_Kpi_Group;

/************************************************************************************
************************************************************************************/

-- this procedure deletes a Tab in BSC.  No commits are passed to the
-- BSC APIs because these commits will undo the indicator lock.  The commit is
-- executed at the end of this procedure.

procedure Delete_Tab(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_tab_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

  l_Bsc_Tab_Entity                 BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;
  l_Bsc_Kpi_Entity        BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
  l_commit                        varchar2(10);

  CURSOR c_Share_Ind IS
  SELECT DISTINCT K.Indicator
  FROM   BSC_KPIS_VL        K
       , BSC_TAB_INDICATORS T
  WHERE  K.Indicator    =  T.Indicator
  AND    K.Share_Flag   =  2
  AND    T.Tab_Id       =  p_tab_id;


begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCPMFUIDelete;
  l_commit := FND_API.G_FALSE;

    FOR cd_Share_Ind IN c_Share_Ind LOOP
        -- call the procedure to delete share kpi from scorecard;
        -- Master Kpi will not be deleted.
        l_Bsc_Kpi_Entity.Bsc_Kpi_Id := cd_Share_Ind.Indicator;
        BSC_KPI_PUB.Delete_Kpi
        (   p_commit                =>  FND_API.G_FALSE
          , p_Bsc_Kpi_Entity_Rec    =>  l_Bsc_Kpi_Entity
          , x_return_status         =>  x_return_status
          , x_msg_count             =>  x_msg_count
          , x_msg_data              =>  x_msg_data
        );
        IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;

  -- set some of the values for the Record Type
  l_Bsc_Tab_Entity.Bsc_Tab_Id := p_tab_id;

  BSC_SCORECARD_PUB.Delete_Tab( FND_API.G_FALSE
                               ,l_Bsc_Tab_Entity
                               ,x_return_status
                               ,x_msg_count
                               ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  BSC_SCORECARD_PUB.Update_System_Time_Stamp( FND_API.G_FALSE
                                             ,l_Bsc_Tab_Entity
                                             ,x_return_status
                                             ,x_msg_count
                                             ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  -- Fix for bug 3459282
  -- Delete the Dim Object Filters Associated to the Scorecard.
  -- It needs to be at the final it deletes view objects
   BSC_DIM_FILTERS_PUB.Drop_Filter_By_Tab (
           p_Tab_Id             =>   p_Tab_Id
       ,   x_return_status      =>   x_return_status
       ,   x_msg_COUNT          =>   x_msg_COUNT
       ,   x_msg_data           =>   x_msg_data
    );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCPMFUIDelete;
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
        ROLLBACK TO BSCPMFUIDelete;
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
        ROLLBACK TO BSCPMFUIDelete;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Delete_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Delete_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCPMFUIDelete;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Delete_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Delete_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Delete_Tab;


/************************************************************************************
************************************************************************************/

-- this procedure unassign Indicators  to a Tab.  It Received the Master KPI ID

-- This is part of the Master/ Shared Indicator process.
-- No commits are passed to the BSC APIs because these commits will undo the
-- indicator lock.  The commit is executed at the end of this procedure.

-- This Procedure unassign a KPI from a Tab. It Received the Master KPI ID

-- Logic :

-- Check if the KPI is already assigned to other Tab
-- If the KPI is not assigned to other Tab then
     -- Just assign the KPI to the Tab and set as Master
-- else the KPI is already assigned to other Tab then
         -- Create a Share KPI
         -- Assign the Share KPI to the Tab
-- end if

procedure Assign_KPI(
  p_commit                IN          VARCHAR2 := FND_API.G_FALSE
 ,p_kpi_id    IN  number
 ,p_tab_id              IN      number
 ,x_return_status       IN OUT NOCOPY     varchar2
 ,x_msg_count           IN OUT NOCOPY     number
 ,x_msg_data            IN OUT NOCOPY     varchar2
 ,p_time_stamp          IN      varchar2        :=  NULL
) is

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
l_Bsc_Tab_Entity_Rec    BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;

l_commit      varchar2(10);
l_option_ids      varchar2(300);
l_kpi_name      varchar2(250);

l_kpi_id      number;

l_count                         number;
l_kpi_source                    number;
l_beg_str     number;
l_end_str     number;
l_occur       number;
l_opt_id      number;
l_share_flag      number;
l_same_name     number;
l_kpi_group_type    number;

begin
   SAVEPOINT BscPmfUIAssignKpi;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  --l_commit := FND_API.G_FALSE;


  -- get the name, l_share_flag and Indicator source .  It will be used for tab validation.

  select name, share_flag, source_indicator
    into l_kpi_name, l_share_flag, l_kpi_source
    from BSC_KPIS_VL
   where indicator = p_kpi_id;

  -- Validate that the p_KPI_id corresponds to the Master KPI.
  if l_share_flag <> 2 then
       l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_kpi_id;
  else
      -- if it's a share KPI it got the Master KPI Id
      l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := l_kpi_source;
  end if;
  -- Evaluate if the KPI is unassign to the Tab:
  if Is_KPI_Assigned (l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id, p_tab_id ) = FND_API.G_FALSE  then

  -- if the KPI is not assigned to the Tab yet

    l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id := p_tab_id;
    l_Bsc_Kpi_Entity_Rec.Bsc_Source_Language := 'US';
    l_Bsc_Kpi_Entity_Rec.Bsc_Language := 'US';

    -- Determine if there are kpis in this tab which have the same name as
    -- the kpi being passed.
    select count(indicator)
      into l_same_name
      from BSC_TAB_INDICATORS
      where tab_id = p_tab_id
       and indicator in (select indicator
                         from BSC_KPIS_TL
                        where upper(name) = upper(l_kpi_name));
    -- if there are kpis in this tab which have the same name it throws an error.
    if l_same_name <> 0 then
        FND_MESSAGE.SET_NAME('BSC','BSC_B_NO_SAMEKPI_TAB');
        FND_MESSAGE.SET_TOKEN('Indicator name: ', l_kpi_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    -- need to get kpi group for this kpi.
    select distinct(ind_group_id)
      into l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id
      from BSC_KPIS_B
      where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
   -- Evaluate the Group Type
    SELECT GROUP_TYPE
      into l_kpi_group_type
      FROM BSC_TAB_IND_GROUPS_B
      WHERE IND_GROUP_ID = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id
      and tab_id = -1 ;

    if l_kpi_group_type = 1 then
      -- if the the Group is Below the name
        SELECT COUNT(BK.INDICATOR)
            into l_count
            FROM BSC_KPIS_B BK, BSC_TAB_INDICATORS TI
            WHERE BK.IND_GROUP_ID = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id
             AND TI.TAB_ID = p_tab_id
             AND BK.INDICATOR = TI.INDICATOR;
        if l_count > 0 then
            update BSC_TAB_IND_GROUPS_B
              set GROUP_TYPE = 0
              where IND_GROUP_ID = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id;
        end if;
    end if;

    -- Need to determine if this KPI will be master or shared;
    -- Check If the Master is already assigned to other Tab.
    select count(tab_id)
      into l_count
      from BSC_TAB_INDICATORS
     where indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

         BSC_BIS_LOCKS_PUB.LOCK_TAB(
             p_tab_id          => p_tab_id
            ,p_time_stamp             => p_time_stamp  -- Granular Locking
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
        );

      IF ((x_return_status IS NOT NULL)AND(x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- if count is zero then ussigned KPI will be the master, else will be the shared one.
    if l_count = 0 then
      -- about to create master KPI

      --DBMS_OUTPUT.PUT_LINE('BSC_PMF_UI_WRAPPER.Assign_KPI -  Flag 7');




      BSC_KPI_PUB.Create_Master_Kpi( FND_API.G_FALSE
                                    ,l_Bsc_Kpi_Entity_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    else
      l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Source_Ind := l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

      --DBMS_OUTPUT.PUT_LINE('BSC_PMF_UI_WRAPPER.Assign_KPI -  Flag 8');
      --DBMS_OUTPUT.PUT_LINE('l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Source_Ind -'||l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Source_Ind );


      BSC_KPI_PUB.Create_Shared_Kpi( FND_API.G_FALSE
                                    ,l_Bsc_Kpi_Entity_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    end if;

     -- Added to fix issue oin bug 2731675



     BSC_COMMON_DIM_LEVELS_PUB.Check_Dim_Level_Default_Value( FND_API.G_FALSE
                                                     ,p_tab_id
                                                     ,x_return_status
                                                     ,x_msg_count
                                                     ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;



  end if;

      --BSC_DEBUG.PUT_LINE('BSC_PMF_UI_WRAPPER.Assign_KPI -  Flag 11');

  -- Need to call procedure for list button logic.


  BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels( FND_API.G_FALSE
                                                     ,p_tab_id
                                                     ,x_return_status
                                                     ,x_msg_count
                                                     ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;



   -- Need to fix bug 3543675
   BSC_DIM_FILTERS_PUB.Synch_Fiters_And_Kpi_Dim
   (       p_Tab_Id            => p_tab_id
       ,   x_return_status     => x_return_status
       ,   x_msg_count         => x_msg_count
       ,   x_msg_data          => x_msg_data
   );

  l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id := p_tab_id;
  BSC_SCORECARD_PUB.Update_Tab_Time_Stamp( FND_API.G_FALSE
                                          ,l_Bsc_Tab_Entity_Rec
                                          ,x_return_status
                                          ,x_msg_count
                                          ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;



  IF (p_commit = FND_API.G_TRUE) THEN

    COMMIT;
  END IF;


    --BSC_DEBUG.PUT_LINE('End BSC_PMF_UI_WRAPPER.Assign_KPI' );
  --BSC_DEBUG.finish;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscPmfUIAssignKpi;
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
        ROLLBACK TO BscPmfUIAssignKpi;
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
        ROLLBACK TO BscPmfUIAssignKpi;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Assign_KPI ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Assign_KPI ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BscPmfUIAssignKpi;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Assign_KPI ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Assign_KPI ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Assign_KPI;



/************************************************************************************
************************************************************************************/
-- This Procedure unassign a KPI from a Tab. It Received the Master KPI ID

-- Logic for the Maste/Share KPI :

-- If the KPI assign to the current tab is the Master then
     -- if there is not more share KPIs assigned to any tab then
         -- Just unassign the Master from the tab
     -- else if there is just one Share KPI then
         -- unassign the Master from the tab
         -- Delete the Master KPI Metadata
         -- Set the Share KPI as Master KPI
     -- else if there are more than one Share KPI assigned the tabs then
         -- User can not unassign the Master KPI
     -- end if
-- else if the KPI assigned to the Tab is a Share KPI then
         -- unassign the Master from the tab
         -- Delete the Master KPI Metadata
-- end if

-- Logic for handle the KPI Groups:
  --   Checks to see if this is the last KPI from the group.
  --   If it is the last KPI from the group assigned anywhere,
  --          then delete the group.
  --   else If it is the last KPI from the group assigned to this tab
  --          but there are other KPIs assigned elsewhere then
  --          just remove group from tab.


procedure Unassign_KPI(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_id              IN      number
 ,p_tab_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_time_stamp          IN             varchar2 := NULL
) is

l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
l_Bsc_Kpi_Group_Rec             BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;
l_Bsc_Option_Rec                BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
l_Bsc_Tab_Entity_Rec    BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;

l_commit                        varchar2(10);

l_count       number;
l_kpi_group_id      number;
l_kpi_count     number;
l_kpi_id      number;
l_share_flag                     number;
l_Master_KPI_id                  number;
l_unassiged                      number;
l_kpi_source                     number;
l_is_obj_in_production           BOOLEAN;
l_prototype_flag                 number;
l_Simulation_Tree_flag           number;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BscPmfUIUnAssignKpi;
  l_commit := FND_API.G_TRUE;

  --assign values.
  l_is_obj_in_production := FALSE;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_kpi_id;
  l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id := p_tab_id;
  l_Bsc_Kpi_Entity_Rec.Bsc_Language := 'US';
  l_Bsc_Kpi_Entity_Rec.Bsc_Source_Language := 'US';

  l_Bsc_Kpi_Group_Rec.Bsc_Tab_Id := p_tab_id;
  l_Bsc_Kpi_Group_Rec.Bsc_Language := 'US';
  l_Bsc_Kpi_Group_Rec.Bsc_Source_Language := 'US';

  -- get l_share_flag,  Indicator source and KPI Group.  It will be used for tab validation.
  select share_flag, source_indicator
    into l_share_flag, l_kpi_source
    from BSC_KPIS_B
   where indicator = p_kpi_id;

  -- Validate that the p_KPI_id corresponds to the Master KPI.
  if l_share_flag <> 2 then
      l_Master_KPI_id := p_kpi_id;
  else
      -- if it a share KPI it got the Master KPI Id
      l_Master_KPI_id := l_kpi_source;
  end if;

  -- Evaluate if the KPI is assigned to the Tab:
  if Is_KPI_Assigned (l_Master_KPI_id, p_tab_id ) = FND_API.G_TRUE  then

    l_unassiged := 1;

    -- Get the KPI group id.
    select IND_GROUP_ID
      into l_kpi_group_id
      from BSC_KPIS_B
     where indicator = p_kpi_id;
     l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id := l_kpi_group_id;

    -- Evaluate if the KPI Assigned to the Tab is the Master or a Share KPI
    select count(indicator)
        into l_count
    from BSC_TAB_INDICATORS
    where tab_id = l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id
          and indicator = l_Master_KPI_id;

    -- If l_count = 0 then the KPI assiged is a Share KPI
    if l_count = 0 then
      -- get the code for Share KPI assiged to the Tab
          select indicator
          into l_Bsc_Kpi_Entity_Rec.Bsc_kpi_id
          from BSC_TAB_INDICATORS
          where tab_id = l_Bsc_Kpi_Entity_Rec.Bsc_Tab_Id
          and indicator in (select indicator from BSC_KPIS_B
                             where source_indicator = l_Master_KPI_id
                           );
  --   Granular Locking
        BSC_BIS_LOCKS_PUB.LOCK_TAB(
              p_tab_id                 => p_tab_id
             ,p_time_stamp             => p_time_stamp  -- Granular Locking
             ,x_return_status          => x_return_status
             ,x_msg_count              => x_msg_count
             ,x_msg_data               => x_msg_data
   )  ;

       IF ((x_return_status IS NOT NULL)AND(x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
        -- Delete the Share KPI


        BSC_KPI_PUB.Delete_Kpi( FND_API.G_FALSE
                               ,l_Bsc_Kpi_Entity_Rec
                               ,x_return_status
                               ,x_msg_count
                               ,x_msg_data);
      IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


    else -- The KPI assiged to the Tab is the Master KPI
      l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := l_Master_KPI_id;
      -- Count the Share KPIs in other tabs
      select count(indicator)
        into l_kpi_count
        from BSC_TAB_INDICATORS
        where indicator in (select indicator
                                from BSC_KPIS_B
                                where source_indicator = l_Master_KPI_id );
      -- Get production Mode Flag for Master KPI
        select prototype_flag, decode(CONFIG_TYPE, 7, 1, 0)
            into l_prototype_flag, l_Simulation_Tree_flag
            from BSC_KPIS_B
           where indicator = l_Master_KPI_id;
        if l_prototype_flag <> 1 and l_prototype_flag <> 3 then
            l_is_obj_in_production := TRUE;
        else
            l_is_obj_in_production := FALSE;
        end if;
      -- if l_kpi_count is 0 there are no shared KPIs.  Delete Master from Tab.  Reset flag.
       IF l_kpi_count = 0 then

        BSC_KPI_PUB.Delete_Kpi_In_Tab( FND_API.G_FALSE
                                    ,l_Bsc_Kpi_Entity_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);
        IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        BSC_KPI_PUB.Update_Kpi_Time_Stamp( FND_API.G_FALSE
                                        ,l_Bsc_Kpi_Entity_Rec
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data);
        IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       ELSIF l_kpi_count = 1 THEN
           -- if l_kpi_count is one then
           -- Check The Production Flag for The Master KPI
           IF (l_is_obj_in_production) THEN
             l_unassiged := 0;
             FND_MESSAGE.SET_NAME('BSC','BSC_KPI_PROD_UNASSIGN');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
           ELSE
              IF (l_Simulation_Tree_flag = 0) THEN
                   ---  Delete Master KPI from Tab and Library.
                   ---  Make Shared KPI as the Master KPI to make it appear in library.
                   --   Get the Share KPI Code
                   SELECT indicator
                   INTO   l_kpi_id
                   FROM   BSC_TAB_INDICATORS
                   WHERE  indicator IN (SELECT indicator
                                        FROM   bsc_kpis_b
                                        WHERE  source_indicator = l_Master_KPI_id );

                   -- Once the shared KPI obtained then delete master KPI.
                   -- call the public version of Delete_Kpi_Defaults.
                   BSC_KPI_PUB.Delete_Kpi_Defaults( FND_API.G_FALSE
                                                  , l_Bsc_Kpi_Entity_Rec
                                                  , x_return_status
                                                  , x_msg_count
                                                  , x_msg_data);

                  IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                   -- Call the private version.  The public version deletes all shared kpis.
                  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_kpi_id;
                  BSC_KPI_PVT.Delete_Kpi( FND_API.G_FALSE
                                         ,l_Bsc_Kpi_Entity_Rec
                                         ,x_return_status
                                         ,x_msg_count
                                         ,x_msg_data);
                  IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
                  -- reset flags for Shared KPI as Master KPI.
                  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Source_Ind := null;
                  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Share_Flag := 1;
                  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := l_kpi_id;

                  BSC_KPI_PVT.Update_Kpi(  FND_API.G_FALSE
                                         , l_Bsc_Kpi_Entity_Rec
                                         , x_return_status
                                         , x_msg_count
                                         , x_msg_data);
                  IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
                     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
                   -- Need to do this update directly because the procedure will see the null
                   -- value for Source Indicator and it will update it with previos value, not
                   -- the null one.
                  UPDATE bsc_kpis_b
                  SET    source_indicator = NULL
                  WHERE  indicator = l_kpi_id;

              ELSE
                  BSC_KPI_PUB.move_master_kpi
                  (
                          p_master_kpi     =>   l_Master_KPI_id
                         ,x_return_status  =>   x_return_status
                         ,x_msg_count      =>   x_msg_count
                         ,x_msg_data       =>   x_msg_data
                  );
                IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
                  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
              END IF;
           END IF;
      ELSE
        -- If there is more than one Share KPI user can not unassign the Master KPI from de Tab
        l_unassiged := 0;
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_MASTER_DELETE');
        FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    end if;

    if l_unassiged <> 0 then
      -- Evaluate if it needs to unassign the KPI Group

      select count(b.indicator)
        into l_kpi_count
        from bsc_kpis_b a, bsc_tab_indicators b
        where a.ind_group_id = l_kpi_group_id
         and a.indicator = b.indicator
         and b.tab_id = p_tab_id;


      -- if l_kpi_count is zero then unassign group from Tab.
      if l_kpi_count = 0 then

        BSC_KPI_GROUP_PUB.Delete_Kpi_Group( FND_API.G_FALSE
                                           ,l_Bsc_Kpi_Group_Rec
                                           ,x_return_status
                                           ,x_msg_count
                                           ,x_msg_data);
            IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
      end if;


      -- Call procedure to handle list button logic.
      BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels( FND_API.G_FALSE
                                                        ,p_tab_id
                                                        ,x_return_status
                                                        ,x_msg_count
                                                        ,x_msg_data);
        IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      BSC_DIM_FILTERS_PUB.Check_Filters_Not_Apply
      (        p_Tab_Id         =>  p_tab_id
            ,  x_return_status  =>  x_return_status
            ,  x_msg_count      =>  x_msg_count
            ,  x_msg_data       =>  x_msg_data
      );
       IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          --DBMS_OUTPUT.PUT_LINE('BSC_PMF_UI_WRAPPER.Unassign_KPI Failed: at BSC_DIM_FILTERS_PUB.Check_Filters_Not_Apply');
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       -- Need to fix bug 3543675
       -- it pass null in order to syscronize KPIs not assigned to any tab
      BSC_DIM_FILTERS_PUB.Synch_Fiters_And_Kpi_Dim
      (       p_Tab_Id            => null
           ,   x_return_status     => x_return_status
           ,   x_msg_count         => x_msg_count
           ,   x_msg_data          => x_msg_data
      );

      l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id := p_tab_id;
      BSC_SCORECARD_PUB.Update_Tab_Time_Stamp( FND_API.G_FALSE
                                          ,l_Bsc_Tab_Entity_Rec
                                          ,x_return_status
                                          ,x_msg_count
                                          ,x_msg_data);
        IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    end if;

     BSC_CUSTOM_VIEW_PUB.Delete_Custom_View_Links
     (
          p_commit         =>  FND_API.G_FALSE
        , p_tab_id         =>  p_tab_id
        , p_obj_id         =>  p_kpi_id
        , x_return_status  =>  x_return_status
        , x_msg_count      =>  x_msg_count
        , x_msg_data       =>  x_msg_data
     );
     IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


  end if;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscPmfUIUnAssignKpi;
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
        ROLLBACK TO BscPmfUIUnAssignKpi;
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
        ROLLBACK TO BscPmfUIUnAssignKpi;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Unassign_KPI ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Unassign_KPI ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BscPmfUIUnAssignKpi;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Unassign_KPI ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Unassign_KPI ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Unassign_KPI;



/************************************************************************************
************************************************************************************/

-- Return TRUE or False ('T' or 'F')  when the KPI (p_kpi_id)  is assigned
-- to the tab (p_tab_id) or a Share KPI of the mension KPI (p_kpi_id) is assigned to the tab.

function Is_KPI_Assigned(
  p_kpi_id              IN      number
 ,p_tab_id              IN      number
) return varchar2 IS
 l_count     number;
Begin

  select count(indicator)
    into l_count
    from BSC_TAB_INDICATORS
    where tab_id = p_tab_id
      and (indicator = p_kpi_id  or
           indicator in (select indicator
                           from BSC_KPIS_B
                           where source_indicator = p_kpi_id)
          );

  if l_count <> 0 then
  return FND_API.G_TRUE;
  else
    return FND_API.G_FALSE;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    return FND_API.G_FALSE;

End Is_KPI_Assigned;

/************************************************************************************
************************************************************************************/

-- Revamped API to do proper rollback and handling

procedure Assign_KPI_Group(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_Group_id        IN      number
 ,p_tab_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_kpi_id    number;
    CURSOR c_kpis IS
    SELECT indicator
    FROM bsc_kpis_b
    WHERE ind_group_id = p_kpi_group_id
    AND SHARE_FLAG <> 2
    AND PROTOTYPE_FLAG <> 2;

l_Bsc_Kpi_Group_Rec   BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;
l_Bsc_tab_Group_Rec   BSC_KPI_GROUP_PUB.Bsc_Kpi_Group_Rec;
l_count           NUMBER;

BEGIN

   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BscPmfUIUAssignKpiGrp;

   SELECT COUNT(*)
   INTO  l_count
   FROM BSC_KPIS_B
   WHERE  ind_group_id = p_kpi_group_id
   and SHARE_FLAG <> 2
   and PROTOTYPE_FLAG <> 2;

   IF (l_count = 0) THEN

      l_Bsc_Kpi_Group_Rec.Bsc_Kpi_Group_Id := p_kpi_Group_id;
      l_Bsc_Kpi_Group_Rec.Bsc_Language     := USERENV('LANG');

      BSC_KPI_GROUP_PVT.Retrieve_Kpi_Group(
             p_commit              =>  FND_API.G_FALSE
            ,p_Bsc_Kpi_Group_Rec   =>  l_Bsc_Kpi_Group_Rec
            ,x_Bsc_Kpi_Group_Rec   =>  l_Bsc_tab_Group_Rec
            ,x_return_status       =>  x_return_status
            ,x_msg_count           =>  x_msg_count
            ,x_msg_data            =>  x_msg_data
       );
       IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       l_Bsc_tab_Group_Rec.Bsc_Tab_Id := p_tab_id;
       l_Bsc_tab_Group_Rec.Bsc_Kpi_Group_Id := p_kpi_Group_id;

       BSC_KPI_GROUP_PVT.Create_Kpi_Group(
           p_commit            =>  FND_API.G_FALSE
          ,p_Bsc_Kpi_Group_Rec =>  l_Bsc_tab_Group_Rec
          ,x_return_status       =>  x_return_status
          ,x_msg_count           =>  x_msg_count
          ,x_msg_data            =>  x_msg_data
       );
    ELSE
       IF (c_kpis%ISOPEN) THEN
            CLOSE c_kpis;
       END IF;
       OPEN c_kpis;
       LOOP
         FETCH c_kpis INTO l_kpi_id;
         EXIT WHEN c_kpis%NOTFOUND;


         BSC_PMF_UI_WRAPPER.Assign_KPI(
                p_Commit         =>  FND_API.G_FALSE
               ,p_kpi_id         =>  l_kpi_id
               ,p_tab_id         =>  p_tab_id
               ,x_return_status  =>  x_return_status
               ,x_msg_count      =>  x_msg_count
               ,x_msg_data       =>  x_msg_data
         );
         IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
        END LOOP;
       CLOSE c_kpis;
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (c_kpis%ISOPEN) THEN
        CLOSE c_kpis;
    END IF;
    rollback to BscPmfUIUAssignKpiGrp;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (c_kpis%ISOPEN) THEN
        CLOSE c_kpis;
    END IF;
    rollback to BscPmfUIUAssignKpiGrp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    IF (c_kpis%ISOPEN) THEN
        CLOSE c_kpis;
    END IF;
    rollback to BscPmfUIUAssignKpiGrp;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    IF (c_kpis%ISOPEN) THEN
        CLOSE c_kpis;
    END IF;
    rollback to BscPmfUIUAssignKpiGrp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

end Assign_KPI_Group;

/************************************************************************************
************************************************************************************/

procedure Assign_Analysis_Option(
  p_kpi_id                  IN      number
 ,p_analysis_group_id       IN      number
 ,p_option_id               IN      number
 ,p_parent_option_id        IN      number
 ,p_grandparent_option_id   IN      number
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
 ,p_commit                  IN      varchar2 /* := FND_API.G_TRUE */
 ,p_time_stamp_to_check     IN      varchar2 /* := null */

) IS

 l_Bsc_kpi_Entity_Rec      BSC_KPI_PUB.Bsc_kpi_Entity_Rec;
 l_time_stamp              varchar(200);
Begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BscPmfUIUAssignAnaOpt;
 --DBMS_OUTPUT.PUT_LINE('Begin BSC_PMF_UI_WRAPPER.Assign_Analysis_Option');
 FND_MSG_PUB.Initialize;

 IF p_time_stamp_to_check IS NOT NULL then
        l_time_stamp := get_KPI_Time_Stamp(p_kpi_id);
        IF l_time_stamp IS NULL or l_time_stamp <> p_time_stamp_to_check then
            FND_MESSAGE.SET_NAME('BSC','BSC_KPI_CHANGED');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END if;
 ELSE
   Populate_Option_Dependency_Rec (
                  FND_API.G_FALSE
                 ,p_kpi_id
                 ,p_analysis_group_id
         ,p_option_id
         ,p_parent_option_id
         ,p_grandparent_option_id
         ,l_Bsc_kpi_Entity_Rec
         ,x_return_status
         ,x_msg_count
         ,x_msg_data );
           IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
   BSC_KPI_PUB.Assign_Analysis_Option(
              l_Bsc_kpi_Entity_Rec
       ,x_return_status
       ,x_msg_count
       ,x_msg_data );
   IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF ;
   BSC_KPI_PUB.Update_Kpi_Time_Stamp(
         FND_API.G_FALSE
        ,l_Bsc_kpi_Entity_Rec
        ,x_return_status
        ,x_msg_count
        ,x_msg_data );
   IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF ;

   IF p_commit = FND_API.G_TRUE THEN
     commit;
   END IF;

 END IF;


 --DBMS_OUTPUT.PUT_LINE('End BSC_PMF_UI_WRAPPER.Assign_Analysis_Option');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback to BscPmfUIUAssignAnaOpt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback to BscPmfUIUAssignAnaOpt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback to BscPmfUIUAssignAnaOpt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback to BscPmfUIUAssignAnaOpt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

End Assign_Analysis_Option;


/************************************************************************************
************************************************************************************/

procedure Unassign_Analysis_Option(
  p_kpi_id                  IN      number
 ,p_analysis_group_id       IN      number
 ,p_option_id               IN      number
 ,p_parent_option_id        IN      number
 ,p_grandparent_Option_id   IN      number
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
 ,p_commit                  IN      varchar2 /* := FND_API.G_TRUE */
 ,p_time_stamp_to_check     IN      varchar2 /* := null */

) IS
 l_Bsc_kpi_Entity_Rec      BSC_KPI_PUB.Bsc_kpi_Entity_Rec;
 l_time_stamp              varchar(200);


Begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BscPmfUIUnAssignAnaOpt;

 IF p_time_stamp_to_check IS NOT NULL then
        l_time_stamp := get_KPI_Time_Stamp(p_kpi_id);
        IF l_time_stamp IS NULL or l_time_stamp <> p_time_stamp_to_check then
            FND_MESSAGE.SET_NAME('BSC','BSC_KPI_CHANGED');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END if;
 ELSE
    Populate_Option_Dependency_Rec (
                  FND_API.G_FALSE
                 ,p_kpi_id
                 ,p_analysis_group_id
         ,p_option_id
         ,p_parent_option_id
         ,p_grandparent_option_id
         ,l_Bsc_kpi_Entity_Rec
         ,x_return_status
         ,x_msg_count
         ,x_msg_data );
   IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF ;

    BSC_KPI_PUB.Unassign_Analysis_Option(
                         l_Bsc_kpi_Entity_Rec
       ,x_return_status
       ,x_msg_count
       ,x_msg_data );
   IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   BSC_KPI_PUB.Update_Kpi_Time_Stamp(
         FND_API.G_FALSE
        ,l_Bsc_kpi_Entity_Rec
        ,x_return_status
        ,x_msg_count
        ,x_msg_data );
   IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF p_commit = FND_API.G_TRUE THEN
     commit;
   END IF;

 END IF;


 --DBMS_OUTPUT.PUT_LINE('End BSC_PMF_UI_WRAPPER.Unassign_Analysis_Option');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback to BscPmfUIUnAssignAnaOpt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback to BscPmfUIUnAssignAnaOpt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback to BscPmfUIUnAssignAnaOpt;
    x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback to BscPmfUIUnAssignAnaOpt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

End Unassign_Analysis_Option;

/************************************************************************************
************************************************************************************/

function Is_Analysis_Option_Selected(
  p_kpi_id                  IN      number
 ,p_analysis_group_id       IN      number
 ,p_option_id               IN      number
 ,p_parent_option_id        IN      number
 ,p_grandparent_Option_id   IN      number
) return varchar2 IS

 l_Bsc_kpi_Entity_Rec      BSC_KPI_PUB.Bsc_kpi_Entity_Rec;
 x_return_status          varchar2(3000);
 x_msg_count              number;
 x_msg_data               varchar2(3000);
 temp                     varchar2(5);

Begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
 --DBMS_OUTPUT.PUT_LINE('Begin BSC_PMF_UI_WRAPPER.Is_Analysis_Option_Selected');

 -- it return Empty if option does not exist
 temp := '';
 -- populate the record l_Bsc_kpi_Entity_Rec with the parameters
 Populate_Option_Dependency_Rec ( FND_API.G_FALSE
                                 ,p_kpi_id
                                 ,p_analysis_group_id
         ,p_option_id
         ,p_parent_option_id
         ,p_grandparent_option_id
         ,l_Bsc_kpi_Entity_Rec
         ,x_return_status
         ,x_msg_count
         ,x_msg_data );
   IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

 -- Call main function
 temp := BSC_KPI_PUB.Is_Analysis_Option_Selected(
                            l_Bsc_kpi_Entity_Rec
          ,x_return_status
          ,x_msg_count
          ,x_msg_data );

 --DBMS_OUTPUT.PUT_LINE('End BSC_PMF_UI_WRAPPER.Is_Analysis_Option_Selected  -  return ' || temp);

 return temp;

EXCEPTION
  WHEN OTHERS THEN
    return temp;

end Is_Analysis_Option_Selected;

/************************************************************************************
************************************************************************************/

function Is_Leaf_Analysis_Option(
  p_kpi_id                  IN      number
 ,p_analysis_group_id       IN      number
 ,p_option_id               IN      number
 ,p_parent_option_id        IN      number
 ,p_grandparent_Option_id   IN      number
) return varchar2 IS

 l_Bsc_kpi_Entity_Rec     BSC_KPI_PUB.Bsc_kpi_Entity_Rec;
 x_return_status          varchar2(3000);
 x_msg_count              number;
 x_msg_data               varchar2(3000);
 temp                     varchar2(5);
 l_count      number;

Begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  --DBMS_OUTPUT.PUT_LINE('Begin BSC_PMF_UI_WRAPPER.Is_Leaf_Analysis_Option ');


  l_Bsc_kpi_Entity_Rec.Bsc_kpi_Id := p_kpi_id;
  l_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id := p_analysis_group_id;

  l_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1 := 0;
  l_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option2 := 0;

  if p_analysis_group_id = 0 then
      l_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0 := p_option_id;
  elsif p_analysis_group_id = 1 then
      l_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0 := p_parent_option_id;
      l_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1 := p_option_id;
  else
      l_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0 := p_grandparent_option_id;
      l_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1 := p_parent_option_id;
      l_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option2 := p_option_id;
  end if;

  -- Evaluate if the option exists
  select count(option_id)
     into l_count
   from BSC_KPI_ANALYSIS_OPTIONS_B
   where indicator = p_kpi_id
         and analysis_group_id = p_analysis_group_id
           and option_id = p_option_id
     and parent_option_id = p_parent_option_id
     and grandparent_option_id = p_grandparent_option_id;

  if l_count <> 0 then
     temp := BSC_KPI_PUB.Is_Leaf_Analysis_Option(
                            l_Bsc_kpi_Entity_Rec
          ,x_return_status
          ,x_msg_count
          ,x_msg_data );
  else
    -- Return Empty when the Option does not exists
    temp := '';
  end if;


  --DBMS_OUTPUT.PUT_LINE('End BSC_PMF_UI_WRAPPER.Is_Leaf_Analysis_Option  -  return ' || temp);

  return temp;

EXCEPTION
  WHEN OTHERS THEN
    return '' ;

end Is_Leaf_Analysis_Option;

/************************************************************************************
************************************************************************************/

procedure Populate_Option_Dependency_Rec(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_id                  IN      number
 ,p_analysis_group_id       IN      number
 ,p_option_id               IN      number
 ,p_parent_option_id        IN      number
 ,p_grandparent_option_id   IN      number
 ,p_Bsc_kpi_Entity_Rec      OUT NOCOPY     BSC_KPI_PUB.Bsc_kpi_Entity_Rec
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
) IS

 l_count  number;
Begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  --DBMS_OUTPUT.PUT_LINE('Begin BSC_PMF_UI_WRAPPER.Populate_Option_Dependency_Rec');

  -- Evaluate if the Analysis option Exist in the Metadata
  select count(option_id)
     into l_count
   from BSC_KPI_ANALYSIS_OPTIONS_B
   where indicator = p_kpi_id
         and analysis_group_id = p_analysis_group_id
           and option_id = p_option_id
     and parent_option_id = p_parent_option_id
     and grandparent_option_id = p_grandparent_option_id;

  if l_count = 0 then
    --  l_count = 0 means the option does not exist
    --DBMS_OUTPUT.PUT_LINE('--BSC_PMF_UI_WRAPPER.Populate_Option_Dependency_Rec -  BSC_NO_VALUE_FOUND ');
    FND_MSG_PUB.Initialize;
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_VALUE_FOUND');
    FND_MESSAGE.SET_TOKEN('BSC_OBJECT', 'Populate_Option_Dependency_Rec');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  p_Bsc_kpi_Entity_Rec.Bsc_kpi_Id := p_kpi_id;
  p_Bsc_kpi_Entity_Rec.Bsc_kpi_Group_Id := p_analysis_group_id;

  p_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag := 0;
  p_Bsc_kpi_Entity_Rec.Bsc_gp_Dependency_Flag := 0;


  if p_analysis_group_id > 0 then
    select DEPENDENCY_FLAG
      into p_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag
      from BSC_KPI_ANALYSIS_GROUPS
      where INDICATOR = p_kpi_id
        and ANALYSIS_GROUP_ID = p_analysis_group_id;

     if p_analysis_group_id = 2 and p_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag <> 0 then
        select DEPENDENCY_FLAG
          into p_Bsc_kpi_Entity_Rec.Bsc_gp_Dependency_Flag
          from BSC_KPI_ANALYSIS_GROUPS
          where INDICATOR = p_kpi_id
            and ANALYSIS_GROUP_ID = 1;
     end if;

  end if;

  p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0 := 0;
  p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1 := 0;
  p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option2 := 0;

  if p_analysis_group_id = 0 then
      p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0 := p_option_id;
  elsif p_analysis_group_id = 1 then
      if p_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag <> 0 then
        p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0 := p_parent_option_id;
      end if;
      p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1 := p_option_id;
  else
      if p_Bsc_kpi_Entity_Rec.Bsc_gp_Dependency_Flag <> 0 then
         p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option0 := p_grandparent_option_id;
      end if;
      if p_Bsc_kpi_Entity_Rec.Bsc_Dependency_Flag <> 0 then
        p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option1 := p_parent_option_id;
      end if;
      p_Bsc_kpi_Entity_Rec.Bsc_kpi_Analysis_Option2 := p_option_id;
  end if;

  --DBMS_OUTPUT.PUT_LINE('End BSC_PMF_UI_WRAPPER.Populate_Option_Dependency_Rec');


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

End Populate_Option_Dependency_Rec;


/*********************************************************************************

-- Procedures to Handle Relationships between Dimension Levels

**********************************************************************************/

procedure Change_Error_Msg(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_msg_name        IN          varchar2
 ,p_new_msg_name    IN          varchar2
 ,p_token1          IN          varchar2
 ,p_token1_value    IN          varchar2
 ,p_token2          IN          varchar2
 ,p_token2_value    IN          varchar2
 ,p_initialize_flag IN          varchar2
 ,p_sys_admin_flag  IN          varchar2
 ,x_return_status   IN OUT NOCOPY      varchar2
 ,x_msg_count       OUT NOCOPY      number
 ,x_msg_data        OUT NOCOPY      varchar2

) is

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
--DBMS_OUTPUT.PUT_LINE('Begin ChangeErrorMsg');

 if x_return_status is not null then

   FND_MSG_PUB.Count_And_Get( p_count     =>      x_msg_count
                              ,p_data     =>      x_msg_data);
 --DBMS_OUTPUT.PUT_LINE( '--- Change_Error_Msg   -   x_return_status = ' || x_return_status  );
 --DBMS_OUTPUT.PUT_LINE( '--- Change_Error_Msg   -   x_msg_data  = ' || x_msg_data );
   if p_msg_name is not null then
    if instr(x_msg_data, p_msg_name) <> 0 then
          if p_initialize_flag = 'Y' then
        FND_MSG_PUB.Initialize;
          end if;
        FND_MESSAGE.SET_NAME('BSC',p_new_msg_name);
        IF p_token1 is not null then
        FND_MESSAGE.SET_TOKEN(p_token1, p_token1_value);
        end if;
        IF p_token2 is not null then
        FND_MESSAGE.SET_TOKEN(p_token2, p_token2_value);
        end if;
          FND_MSG_PUB.ADD;
    if p_sys_admin_flag = 'Y' then
            FND_MESSAGE.SET_NAME('BSC','BSC_CONTACT_SYS_AD');
            FND_MSG_PUB.ADD;
                end if;
          RAISE FND_API.G_EXC_ERROR;
    end if;
   elsif p_new_msg_name is not null then
        if p_initialize_flag = 'Y' then
      FND_MSG_PUB.Initialize;
        end if;
      FND_MESSAGE.SET_NAME('BSC', p_new_msg_name);
      IF p_token1 is not null then
      FND_MESSAGE.SET_TOKEN(p_token1, p_token1_value);
      end if;
      IF p_token2 is not null then
      FND_MESSAGE.SET_TOKEN(p_token2, p_token2_value);
      end if;
        FND_MSG_PUB.ADD;
  if p_sys_admin_flag = 'Y' then
          FND_MESSAGE.SET_NAME('BSC','BSC_CONTACT_SYS_AD');
          FND_MSG_PUB.ADD;
        end if;
        if x_return_status = FND_API.G_RET_STS_ERROR then
            RAISE FND_API.G_EXC_ERROR;
        else
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;
   elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        if p_initialize_flag = 'Y' then
      FND_MSG_PUB.Initialize;
        end if;
        FND_MESSAGE.SET_NAME('BSC','BSC_WARNING_DIMREL_IMPORTERR');
        FND_MESSAGE.SET_TOKEN('RETURN_STATUS', x_return_status);
        FND_MESSAGE.SET_TOKEN('RETURN_MESSAGE', x_msg_data);
        FND_MSG_PUB.ADD;
  if p_sys_admin_flag = 'Y' then
          FND_MESSAGE.SET_NAME('BSC','BSC_CONTACT_SYS_AD');
          FND_MSG_PUB.ADD;
        end if;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

 end if;
--DBMS_OUTPUT.PUT_LINE('End ChangeErrorMsg');


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  --DBMS_OUTPUT.PUT_LINE('End ChangeErrorMsg');

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  --DBMS_OUTPUT.PUT_LINE('End ChangeErrorMsg');


end Change_Error_Msg;

/*-------------------------------------------------------------------------------------------------------------------
   Import_Dim_Level
-------------------------------------------------------------------------------------------------------------------*/

PROCEDURE Import_Dim_Level(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_Short_Name          IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count   OUT NOCOPY  number
 ,x_msg_data    OUT NOCOPY  varchar2
) IS

 v_Bsc_Pmf_Dim_Rec               BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type;
 v_commit                        varchar(5) := FND_API.G_FALSE;
 v_temp         number;
 v_level_view_name               varchar(200);
 v_sql                           varchar(300);

 TYPE RefCurTyp IS REF CURSOR;
 cv RefCurTyp;


BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    v_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name := p_Short_Name;

    -- Get the BSC Dimension Level Id of the Imported PMF Level
    v_temp :=  BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(v_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name);

    if v_temp is null  then   /*  If the Dimension Level has not been Imported */

    v_sql := 'select LEVEL_VIEW_NAME from bsc_bis_dim_levels_v where SHORT_NAME = :1';
  OPEN cv FOR v_sql USING p_Short_Name;
  FETCH cv INTO v_level_view_name;
  --DBMS_OUTPUT.PUT_LINE(' Import_Dim_Level (wrapper)   -  v_level_view_name = ' || v_level_view_name );

        BSC_PMF_UI_API_PUB.Import_PMF_Dim_Level( v_commit ,v_Bsc_Pmf_Dim_Rec  ,x_return_status  ,x_msg_count  ,x_msg_data );
    end if;
--DBMS_OUTPUT.PUT_LINE('End  Import_Dim_Level (wrapper) ' );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    Change_Error_Msg(
    p_msg_name    => 'BSC_PMF_LEVEL_NOT_EXISTS'
   ,p_new_msg_name      => 'BSC_LVLREL_VIEW_NOTEXIST'
   ,p_token1            => 'LEVEL_SHORT_NAME'
   ,p_token1_value      => p_Short_Name
   ,p_token2            => 'LEVEL_VIEW_NAME'
   ,p_token2_value      => v_level_view_name
         ,p_sys_admin_flag      => 'Y'
   ,x_return_status     => x_return_status
   ,x_msg_count         => x_msg_count
   ,x_msg_data          => x_msg_data
    );
  WHEN OTHERS THEN /*FND_API.G_EXC_UNEXPECTED_ERROR THEN */
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    Change_Error_Msg(
    p_new_msg_name      => ''
   ,x_return_status     => x_return_status
   ,x_msg_count         => x_msg_count
   ,x_msg_data          => x_msg_data
    );

END Import_Dim_Level;

/*-------------------------------------------------------------------------------------------------------------------
   Update_RelationShips
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE Update_RelationShips(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_Dim_Level_Id        IN      number
 ,p_Short_Name          IN      varchar2
 ,p_Parents             IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count   OUT NOCOPY  number
 ,x_msg_data    OUT NOCOPY  varchar2
) IS

 x_array      t_of_varchar2;
 v_count number;
 v_Temp boolean;
 v_aux number;

 v_Num_Columns    INTEGER :=3 ;
 v_Num_Rows     INTEGER;
 I INTEGER ;

 v_array_Dim_Levels   t_of_Bsc_Dim_Level_Rec;

 v_Dim_Level_Rec  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
 v_Bsc_Pmf_Dim_Rec      BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type;
 v_commit               varchar(5) := FND_API.G_FALSE;

 v_Dim_Level_Id   number;

    CURSOR c_parents IS
    SELECT PARENT_DIM_LEVEL_ID
    FROM   BSC_SYS_DIM_LEVEL_RELS
    WHERE  DIM_LEVEL_ID = v_Dim_Level_Id;

BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Ckeck the Imput parameter
/*
 if p_Dim_Level_Id Is null then
       v_Dim_Level_Rec.Bsc_Level_Id := null;
       v_Dim_Level_Rec.Bsc_Level_Short_Name := p_Short_Name;
       v_Dim_Level_Rec.Bsc_Source := 'PMF';
 else
      v_Dim_Level_Rec.Bsc_Level_Id := p_Dim_Level_Id;
      v_Dim_Level_Rec.Bsc_Level_Short_Name := null;
      v_Dim_Level_Rec.Bsc_Source := 'BSC';
 end if;
*/
-- For now just work for PMF Levels
  v_Dim_Level_Rec.Bsc_Level_Id := null;
  v_Dim_Level_Rec.Bsc_Level_Short_Name := p_Short_Name;
  v_Dim_Level_Rec.Bsc_Source := 'PMF';

 if v_Dim_Level_Rec.Bsc_Source <> 'BSC' then
       v_Dim_Level_Rec.Bsc_Level_Id := BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(v_Dim_Level_Rec.Bsc_Level_Short_Name);
       if v_Dim_Level_Rec.Bsc_Level_Id is null then
           v_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name := v_Dim_Level_Rec.Bsc_Level_Short_Name;
     BSC_PMF_UI_API_PUB.Import_PMF_Dim_Level(v_commit ,v_Bsc_Pmf_Dim_Rec
             ,x_return_status ,x_msg_count ,x_msg_data );
           v_Dim_Level_Rec.Bsc_Level_Id := BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(v_Dim_Level_Rec.Bsc_Level_Short_Name);
           BSC_MULTI_USER_PVT.Apply_Multi_User_Env('DIM_LEVEL', v_Dim_Level_Rec.Bsc_Level_Id
                           , null, null, null, 'LCK',  null, x_return_status,  x_msg_count  ,x_msg_data);
       end if;
 end if;

    --DBMS_OUTPUT.PUT_LINE('Update_RelationShip    v_Dim_Level_Rec.Bsc_Source = ' || v_Dim_Level_Rec.Bsc_Source);
    --DBMS_OUTPUT.PUT_LINE('Update_RelationShip    v_Dim_Level_Rec.Bsc_Level_Id = ' || v_Dim_Level_Rec.Bsc_Level_Id );
    --DBMS_OUTPUT.PUT_LINE('Update_RelationShip    v_Dim_Level_Rec.Bsc_Level_Short_Name = ' || v_Dim_Level_Rec.Bsc_Level_Short_Name );

 v_count := Decompose_String_List(p_Parents, x_array, ';');
 v_Num_Rows := v_count / v_Num_Columns;


-- Evaluate Get parameters and Evaluate the Relationships

v_Temp := TRUE;

FOR I IN 1.. v_Num_Rows LOOP
   -- Get the maim parameters for each relation --
   v_aux := (I - 1) * v_Num_Columns ;

    --DBMS_OUTPUT.PUT_LINE('Update_RelationShip    v_aux = ' || v_aux );
    --DBMS_OUTPUT.PUT_LINE('Update_RelationShip  x_array(v_aux+1) ' ||  x_array(v_aux+1) );

   if LOWER( x_array(v_aux+1)) = 'null' OR  x_array(v_aux+1) = '' then
       v_Dim_Level_Rec.Bsc_Parent_Level_Id := NULL;
       v_Dim_Level_Rec.Bsc_Parent_Level_Source := 'PMF';
   else
       v_Dim_Level_Rec.Bsc_Parent_Level_Id := TO_NUMBER(x_array(v_aux+1));
       v_Dim_Level_Rec.Bsc_Parent_Level_Source := 'BSC';
   end if;

    --DBMS_OUTPUT.PUT_LINE('Update_RelationShip  x_array(v_aux+2) ' ||  x_array(v_aux+2) );

   if LOWER( x_array(v_aux+2)) = 'null' OR x_array(v_aux+2) = '' then
       v_Dim_Level_Rec.Bsc_Parent_Level_Short_Name := NULL;
   else
       v_Dim_Level_Rec.Bsc_Parent_Level_Short_Name := x_array(v_aux+2);
   end if;
   v_Dim_Level_Rec.Bsc_Relation_Column := x_array(v_aux+3);
   v_Dim_Level_Rec.Bsc_Relation_Type := 1;

    --DBMS_OUTPUT.PUT_LINE('Update_RelationShip   v_Dim_Level_Rec.Bsc_Relation_Column = ' || v_Dim_Level_Rec.Bsc_Relation_Column );
    --DBMS_OUTPUT.PUT_LINE('Update_RelationShip   v_Dim_Level_Rec.Bsc_Parent_Level_Source = ' || v_Dim_Level_Rec.Bsc_Parent_Level_Source );
    --DBMS_OUTPUT.PUT_LINE('Update_RelationShip   v_Dim_Level_Rec.Bsc_Parent_Level_Short_Name = ' || v_Dim_Level_Rec.Bsc_Parent_Level_Short_Name );

   -- Evaluate if it need import the child dimension Level--
   if v_Dim_Level_Rec.Bsc_Parent_Level_Source <> 'BSC' then

       v_Dim_Level_Rec.Bsc_Parent_Level_Id := BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(v_Dim_Level_Rec.Bsc_Parent_Level_Short_Name);
       if v_Dim_Level_Rec.Bsc_Parent_Level_Id is null then
          v_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name := v_Dim_Level_Rec.Bsc_Parent_Level_Short_Name;

          BSC_PMF_UI_API_PUB.Import_PMF_Dim_Level(v_commit ,v_Bsc_Pmf_Dim_Rec
             ,x_return_status ,x_msg_count ,x_msg_data );

          v_Dim_Level_Rec.Bsc_Parent_Level_Id := BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(v_Dim_Level_Rec.Bsc_Parent_Level_Short_Name);
          BSC_MULTI_USER_PVT.Apply_Multi_User_Env('DIM_LEVEL', v_Dim_Level_Rec.Bsc_Level_Id, null, null, null
                                                   , 'LCK',  null, x_return_status,  x_msg_count  ,x_msg_data);

       end if;
   end if;
    --DBMS_OUTPUT.PUT_LINE('Update_RelationShip    v_Dim_Level_Rec.Bsc_Parent_Level_Id = ' || v_Dim_Level_Rec.Bsc_Parent_Level_Id);

   -- Evaluate if the relation is valid --
   if BSC_DIMENSION_LEVELS_PUB.Is_Valid_Relationship(v_commit, v_Dim_Level_Rec, x_return_status, x_msg_count, x_msg_data) then
     -- Set the Relation into the array --
        v_array_Dim_Levels(v_Dim_Level_Rec.Bsc_Parent_Level_Id):=  v_Dim_Level_Rec;
   else
  v_Temp :=  false;
   end if;

 END LOOP;
          --DBMS_OUTPUT.PUT_LINE('Update_RelationShip ******** Delete ****** ');

if v_Temp  then
-- Delete the Relationships that Not apply any more ---

   v_Dim_Level_Id := v_Dim_Level_Rec.Bsc_Level_Id;  /* set Query parameter */
   IF (c_parents%ISOPEN) THEN
        CLOSE c_parents;
   END IF;
   OPEN c_parents;
   LOOP
     FETCH c_parents INTO v_Dim_Level_Rec.Bsc_Parent_Level_Id;
     EXIT WHEN c_parents%NOTFOUND;

        if v_array_Dim_Levels.EXISTS(v_Dim_Level_Rec.Bsc_Parent_Level_Id) = false then

            --DBMS_OUTPUT.PUT_LINE('Update_RelationShip  Delete_Dim_Level_Relation ' ||   v_Dim_Level_Rec.Bsc_Parent_Level_Id);

            BSC_DIMENSION_LEVELS_PUB.Delete_Dim_Level_Relation(v_commit, v_Dim_Level_Rec
                                           ,x_return_status, x_msg_count, x_msg_data);
            BSC_MULTI_USER_PVT. Apply_Multi_User_Env('DIM_LEVEL', v_Dim_Level_Rec.Bsc_Level_Id
                           , null, null, null, 'LCK',  null, x_return_status,  x_msg_count  ,x_msg_data);
        else
            v_array_Dim_Levels(v_Dim_Level_Rec.Bsc_Parent_Level_Id).Bsc_Flag := -999;
        end if;
   END LOOP;

-- Update/Insert the Apply the Relationships

          --DBMS_OUTPUT.PUT_LINE('Update_RelationShip ***** Update/Insert ****');

 if v_array_Dim_Levels.COUNT > 0 then
    v_aux := v_array_Dim_Levels.FIRST;

    LOOP
      v_Dim_Level_Rec := v_array_Dim_Levels(v_aux);
      if v_Dim_Level_Rec.Bsc_Flag = -999 then  /* Flag for Update */
          --DBMS_OUTPUT.PUT_LINE('Update_RelationShip  Delete  ' || v_Dim_Level_Rec.Bsc_Parent_Level_Id  );

            BSC_DIMENSION_LEVELS_PUB.Delete_Dim_Level_Relation(v_commit, v_Dim_Level_Rec
                                           ,x_return_status, x_msg_count, x_msg_data);
      end if;
          --DBMS_OUTPUT.PUT_LINE('Update_RelationShip  Insert  ' || v_Dim_Level_Rec.Bsc_Parent_Level_Id  );

      BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level_Relation(v_commit, v_Dim_Level_Rec
                                           ,x_return_status, x_msg_count, x_msg_data);

      EXIT WHEN (v_aux = v_array_Dim_Levels.LAST);
      v_aux := v_array_Dim_Levels.NEXT(v_aux);
   END LOOP;
 end if;
end if;
    --DBMS_OUTPUT.PUT_LINE('End Update_RelationShip');

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    IF (c_parents%ISOPEN) THEN
        CLOSE c_parents;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    IF (c_parents%ISOPEN) THEN
        CLOSE c_parents;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    IF (c_parents%ISOPEN) THEN
        CLOSE c_parents;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    IF (c_parents%ISOPEN) THEN
        CLOSE c_parents;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

END Update_RelationShips;


/*===========================================================================+
| FUNCTION Decompose_String_List
+============================================================================*/

FUNCTION Decompose_String_List(
 x_string IN VARCHAR2,
 x_varchar2_array IN OUT NOCOPY t_of_varchar2,
 x_separator IN VARCHAR2
 ) RETURN VARCHAR2 IS

    h_num_items NUMBER := 0;

    h_sub_string VARCHAR2(32700);
    h_position NUMBER;

BEGIN
   FND_MSG_PUB.Initialize;
      --DBMS_OUTPUT.PUT_LINE('Begin Decompose_String_List');

    IF x_string IS NOT NULL THEN
        h_sub_string := x_string;
        h_position := INSTR(h_sub_string, x_separator);

        WHILE h_position <> 0 LOOP
            h_num_items := h_num_items + 1;
            x_varchar2_array(h_num_items) :=
                           RTRIM(LTRIM(SUBSTR(h_sub_string, 1, h_position - 1)));

            h_sub_string := SUBSTR(h_sub_string, h_position + 1);
            h_position := INSTR(h_sub_string, x_separator);
        END LOOP;

        h_num_items := h_num_items + 1;
        x_varchar2_array(h_num_items) := RTRIM(LTRIM(h_sub_string));

    END IF;

      --DBMS_OUTPUT.PUT_LINE('End Decompose_String_List');


    RETURN h_num_items;

END Decompose_String_List;

/*===========================================================================+
| FUNCTION Create_PMF_Relationship
+============================================================================*/
procedure Create_PMF_Relationship (
  p_commit               IN      varchar := FND_API.G_FALSE
 ,p_SHORT_NAME        IN      VARCHAR2
 ,p_PARENT_SHORT_NAME   IN      VARCHAR2
 ,p_RELATION_COL        IN      VARCHAR2

) is

 v_Dim_Level_Rec BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
  x_return_status       varchar2(3000);
  x_msg_count   number;
  x_msg_data    varchar2(3000);
  v_count               number;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
--DBMS_OUTPUT.PUT_LINE('Begin Create_PMF_Relationship' );

  v_Dim_Level_Rec.Bsc_Source := 'PMF';
  v_Dim_Level_Rec.Bsc_Level_Short_Name := p_SHORT_NAME;
  v_Dim_Level_Rec.Bsc_Relation_Column := p_RELATION_COL;
  v_Dim_Level_Rec.Bsc_Relation_Type := 1;
  v_Dim_Level_Rec.Bsc_Parent_Level_Source := 'PMF';
  v_Dim_Level_Rec.Bsc_Parent_Level_Short_Name := p_PARENT_SHORT_NAME;

      --DBMS_OUTPUT.PUT_LINE('  Create_PMF_Relationship     v_Dim_Level_Rec.Bsc_Level_Short_Name = ' || v_Dim_Level_Rec.Bsc_Level_Short_Name );
      --DBMS_OUTPUT.PUT_LINE('  Create_PMF_Relationship     v_Dim_Level_Rec.Bsc_Relation_Column = '  || v_Dim_Level_Rec.Bsc_Relation_Column );
      --DBMS_OUTPUT.PUT_LINE('  Create_PMF_Relationship     v_Dim_Level_Rec.Bsc_Parent_Level_Short_Name =  ' || v_Dim_Level_Rec.Bsc_Parent_Level_Short_Name );

        select count(*)
           into v_count
           from BSC_SYS_DIM_LEVEL_RELS_V
     where SHORT_NAME = p_SHORT_NAME
             AND PARENT_SHORT_NAME = p_PARENT_SHORT_NAME;

  --DBMS_OUTPUT.PUT_LINE('  Create_PMF_Relationship     v_count =  ' || v_count );

        if v_count <> 0 then
              --DBMS_OUTPUT.PUT_LINE('  Create_PMF_Relationship     Deleting Relation  ');

          BSC_DIMENSION_LEVELS_PUB.Delete_Dim_Level_Relation(FND_API.G_FALSE, v_Dim_Level_Rec
                                           ,x_return_status, x_msg_count, x_msg_data);
           IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        end if;
  BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level_Relation(FND_API.G_FALSE, v_Dim_Level_Rec
                                           ,x_return_status, x_msg_count, x_msg_data);
   IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
--DBMS_OUTPUT.PUT_LINE('End Create_PMF_Relationship' );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    raise;
  WHEN NO_DATA_FOUND THEN
    rollback;
    raise;
  WHEN OTHERS THEN
    rollback;
    raise;
end Create_PMF_Relationship;


/************************************************************************************
************************************************************************************/

procedure Order_Tab_Index(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_tab_ids             IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

TYPE Bsc_Tab_Index_Rec is RECORD(
  Bsc_Tab_Id    number
 ,Bsc_Tab_Index   number
);

TYPE Bsc_Tab_Index_Tbl IS TABLE OF Bsc_Tab_Index_Rec
  INDEX BY BINARY_INTEGER;

Bsc_Tab_Index     Bsc_Tab_Index_Tbl;

l_tab_id_string     varchar2(1000);

l_tab_id      number;
l_index       number;
l_pos       number;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BscPmfUIOrdTabIndex;

  l_tab_id_string := p_tab_ids;
  l_index := 0;

  -- do the loop while l_tab_id_string contains characters.
  while length(l_tab_id_string) > 0 loop
    -- find position of next semi-colon.
    l_pos := instr(l_tab_id_string, ';');

    -- get the first id in current string.
    l_tab_id := substr(l_tab_id_string, 1, l_pos -1);

    -- assign the current tab_id and current index to the Record Table.
    Bsc_Tab_Index(l_index + 1).Bsc_Tab_Id := l_tab_id;
    Bsc_Tab_Index(l_index + 1).Bsc_Tab_Index := l_index;

    l_index := l_index + 1;

    -- update the string to contain characters starting from the semi-colon
    -- position found earlier.
    l_tab_id_string := substr(l_tab_id_string, l_pos + 1);


  end loop;

  -- Update Table
  for i in 1..Bsc_Tab_Index.count loop

    update BSC_TABS_B
       set tab_index = Bsc_Tab_Index(i).Bsc_Tab_Index
     where tab_id = Bsc_Tab_Index(i).Bsc_Tab_Id;

  end loop;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscPmfUIOrdTabIndex;
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
        ROLLBACK TO BscPmfUIOrdTabIndex;
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
        ROLLBACK TO BscPmfUIOrdTabIndex;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Order_Tab_Index ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Order_Tab_Index ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BscPmfUIOrdTabIndex;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Order_Tab_Index ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Order_Tab_Index ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Order_Tab_Index;

/************************************************************************************
************************************************************************************/

procedure Update_Tab_Parent(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_tab_id              IN      number
 ,p_parent_tab_id       IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Tab_Entity_Rec    BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;

l_commit                        varchar2(10);
l_tab_name      varchar2(105);
l_tab_index     number;
l_return_value                  varchar2(10);

l_count       number;
l_rollback                      number := 0;  -- flag to prevent rollback for a specific
                                              -- case.

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BscPmfUIUptTabParent;
  l_commit := FND_API.G_FALSE;

--DBMS_OUTPUT.PUT_LINE('Begin Update_Tab_Parent' );

--DBMS_OUTPUT.PUT_LINE('  Update_Tab_Parent   p_tab_id = ' || p_tab_id );
--DBMS_OUTPUT.PUT_LINE('  Update_Tab_Parent   p_parent_tab_id = ' || p_parent_tab_id );

  -- execute lock on parent tab_id.
  -- Execute the lock only if parent tab id is a valid tab, i.e. not the root node.
  if p_parent_tab_id <> -2 then

    BSC_MULTI_USER_PVT.Tab_Details_Lock( p_parent_tab_id
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    if x_return_status = 'D' then
      -- set the rollback flag so as not to do a rollback.
      -- this will eventually be removed.
      l_rollback := 1;
      FND_MESSAGE.SET_NAME('BSC','BSC_NO_PARENT_TAB');
      FND_MESSAGE.SET_TOKEN('BSC_TAB', p_parent_tab_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;

  end if;



  -- check to see tab is not being made a child of itself.
  if p_tab_id = p_parent_tab_id then
    --get tab name to display error.
    select name into l_tab_name
      from BSC_TABS_VL where tab_id = p_tab_id;
    FND_MESSAGE.SET_NAME('BSC','BSC_TAB_SELF_REL');
    FND_MESSAGE.SET_TOKEN('BSC_TAB', l_tab_name);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  else
    --Evaluate circular parent reference to fixs bug 2406652--
    l_return_value := BSC_SCORECARD_PUB.is_child_tab_of( p_parent_tab_id, p_tab_id );
    if l_return_value = FND_API.G_TRUE then
      --DBMS_OUTPUT.PUT_LINE('  Update_Tab_Parent   l_return_value = ' || l_return_value );
      FND_MESSAGE.SET_NAME('BSC','BSC_TAB_CIRCULAR_REL');
  select name into l_tab_name
        from BSC_TABS_VL where tab_id = p_tab_id;
      FND_MESSAGE.SET_TOKEN('BSC_TAB', l_tab_name);
  select name into l_tab_name
        from BSC_TABS_VL where tab_id = p_parent_tab_id;
      FND_MESSAGE.SET_TOKEN('BSC_TABCHILD', l_tab_name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;

  end if;


  l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id := p_tab_id;
  l_Bsc_Tab_Entity_Rec.Bsc_Parent_Tab_Id := p_parent_tab_id;


  -- if parent tab_id = -2 then the tab being moved will be a root node and
  -- need to change parent to null.
--  if p_parent_tab_id <> -2 then
--    l_Bsc_Tab_Entity_Rec.Bsc_Parent_Tab_Id := p_parent_tab_id;
--  end if;

  --set some default values
  l_Bsc_Tab_Entity_Rec.Bsc_Language := 'US';
  l_Bsc_Tab_Entity_Rec.Bsc_Source_Language := 'US';

  -- The tab (tab_id) is being moved to a different parent.  This tab needs an
  -- Index under the new parent.  We will assing the next Index.
  select max(tab_index) + 1
    into l_Bsc_Tab_Entity_Rec.Bsc_Tab_Index
    from BSC_TABS_B
   where tab_id = p_parent_tab_id;

  -- call update Tab procedure.
  BSC_SCORECARD_PUB.Update_Tab( FND_API.G_FALSE
                               ,l_Bsc_Tab_Entity_Rec
                               ,x_return_status
                               ,x_msg_count
                               ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  -- call time stamp for Tab
  BSC_SCORECARD_PUB.Update_Tab_Time_Stamp( FND_API.G_FALSE
                                          ,l_Bsc_Tab_Entity_Rec
                                          ,x_return_status
                                          ,x_msg_count
                                          ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  -- Update time stamp for parent tab.
  l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id := p_parent_tab_id;
  BSC_SCORECARD_PUB.Update_Tab_Time_Stamp( FND_API.G_FALSE
                                          ,l_Bsc_Tab_Entity_Rec
                                          ,x_return_status
                                          ,x_msg_count
                                          ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  -- Update system time stamp.
  BSC_SCORECARD_PUB.Update_System_Time_Stamp( FND_API.G_FALSE
                                             ,l_Bsc_Tab_Entity_Rec
                                             ,x_return_status
                                             ,x_msg_count
                                             ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

--DBMS_OUTPUT.PUT_LINE('End Update_Tab_Parent' );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscPmfUIUptTabParent;
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
        ROLLBACK TO BscPmfUIUptTabParent;
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
        ROLLBACK TO BscPmfUIUptTabParent;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Update_Tab_Parent ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Update_Tab_Parent ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BscPmfUIUptTabParent;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Update_Tab_Parent ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Update_Tab_Parent ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);


end Update_Tab_Parent;

/************************************************************************************
************************************************************************************/

procedure Create_Measure(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_short_name          IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Bsc_Dataset_Rec               BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
l_commit                        varchar2(15);
l_measure_col                   BSC_SYS_MEASURES.MEASURE_COL%TYPE;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BscPmfUICrtMeas;
  l_commit := FND_API.G_FALSE;

  -- Get PMF measure long based on the shortname.
  select distinct measure_name
    into l_Bsc_Dataset_Rec.Bsc_Dataset_Name
    from BISFV_PERFORMANCE_MEASURES
   where upper(measure_short_name) = upper(p_short_name);

  -- Set some expected values.
  l_Bsc_Dataset_Rec.Bsc_Measure_Short_Name := p_short_name;
  l_Bsc_Dataset_Rec.Bsc_Measure_Operation := 'SUM';
  --l_Bsc_Dataset_Rec.Bsc_Measure_Col := p_short_name;
  l_Bsc_Dataset_Rec.Bsc_Language := 'US';
  l_Bsc_Dataset_Rec.Bsc_Source_Language := 'US';
  l_Bsc_Dataset_Rec.Bsc_Source := 'PMF';
  l_measure_col := BSC_BIS_MEASURE_PUB.get_measure_col(l_Bsc_Dataset_Rec.Bsc_Dataset_Name, NULL, NULL, p_short_name);
  if (l_measure_col is not null) then
      l_Bsc_Dataset_Rec.Bsc_Measure_Col := l_measure_col;
  else
      l_Bsc_Dataset_Rec.Bsc_Measure_Col := p_short_name;
  end if;


  BSC_DATASETS_PUB.Create_Measures( FND_API.G_FALSE
                                   ,l_Bsc_Dataset_Rec
                                   ,x_return_status
                                   ,x_msg_count
                                   ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscPmfUICrtMeas;
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
        ROLLBACK TO BscPmfUICrtMeas;
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
        ROLLBACK TO BscPmfUICrtMeas;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Create_Measure ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Create_Measure ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BscPmfUICrtMeas;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Create_Measure ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Create_Measure ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);


end Create_Measure;

/************************************************************************************
************************************************************************************/

procedure Create_Measure_VB(
  p_short_name          IN      varchar2
) is

 l_return_status       varchar2(30);
 l_msg_count           number;
 l_msg_data            varchar2(32000);

 l_count    number;
 e_error    exception;

begin
   FND_MSG_PUB.Initialize;
  BSC_APPS.Init_Bsc_Apps;
  BSC_MESSAGE.Init;

  -- Create the measure
  Create_Measure(
      p_short_name => p_short_name
      ,x_return_status => l_return_status
      ,x_msg_count => l_msg_count
      ,x_msg_data => l_msg_data
  );
    IF ((l_return_status IS NOT NULL) AND (l_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  -- Verify that the dataset was created
  SELECT count(*)
  INTO l_count
  FROM bsc_sys_datasets_vl
  WHERE measure_id1 = (
     SELECT measure_id
     FROM bsc_sys_measures
     WHERE short_name = p_short_name);

  IF l_count = 0 THEN
      RAISE e_error;
  END IF;


EXCEPTION
    WHEN e_error THEN
        BSC_MESSAGE.Add(x_message => bsc_apps.get_message('BSC_MEASURE_NOT_IMPORTED'),
                        x_source => 'BSC_PMF_UI_WRAPPER.Create_Measure_Vb',
                        x_mode => 'I');
        COMMIT;
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_PMF_UI_WRAPPER.Create_Measure_Vb',
                        x_mode => 'I');
        COMMIT;
end Create_Measure_VB;

/************************************************************************************
************************************************************************************/

procedure Get_PMV_Report_Levels(
  p_region_code         IN      varchar2
 ,p_measure_short_name  IN      varchar2
 ,x_dim1_name   OUT NOCOPY     varchar2
 ,x_dim1_levels   OUT NOCOPY  varchar2
 ,x_dim2_name           OUT NOCOPY     varchar2
 ,x_dim2_levels         OUT NOCOPY     varchar2
 ,x_dim3_name           OUT NOCOPY     varchar2
 ,x_dim3_levels         OUT NOCOPY     varchar2
 ,x_dim4_name           OUT NOCOPY     varchar2
 ,x_dim4_levels         OUT NOCOPY     varchar2
 ,x_dim5_name           OUT NOCOPY     varchar2
 ,x_dim5_levels         OUT NOCOPY     varchar2
 ,x_dim6_name           OUT NOCOPY     varchar2
 ,x_dim6_levels         OUT NOCOPY     varchar2
 ,x_dim7_name           OUT NOCOPY     varchar2
 ,x_dim7_levels         OUT NOCOPY     varchar2
 ,x_is_there_time       OUT NOCOPY     varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

TYPE Pmv_Dim_Levels_Rec IS RECORD (
  Dim_Name      varchar2(30)
 ,Dim_Short_Level   varchar2(500)
 ,Dim_Number      number
 ,ViewByLevel     varchar2(5)
 ,AllLevel      varchar2(5)
);

TYPE Pmv_Dim_Levels_Tbl IS TABLE OF Pmv_Dim_Levels_Rec
  INDEX BY BINARY_INTEGER;

l_Pmv_Dim_Levels_Tbl    Pmv_Dim_Levels_Tbl;

l_DimLevel_Viewby_Tbl   BIS_PMV_BSC_API_PUB.DimLevel_Viewby_Tbl_Type;
l_cntr        number;
l_2cntr       number;
l_number_records    number;

l_new_level     varchar2(1);
l_temp_dim      varchar2(30);
l_temp_level      varchar2(500);

is_time_dim     varchar2(1) := 'N';
sub_string      number := -1;

l_region_code     varchar2(30);
l_function_code     varchar2(30);

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- When this call was first implemented, PMV had mistakenly advice on using
  -- the most recent region code to obtain the proper report for the given measure
  -- After further research it was determined that this wrapper should be making
  -- the same call as Iviewer is, which does not coincide with PMVs advice.
  -- In order not to change current java files, we are implementing the call
  -- completely within this Wrapper.  Therefore the region code passed to this
  -- wrapper is completely disregarded.
  -- For more references see bug# 2647833
  bsc_jv_pmf.get_pmf_measure( p_measure_short_name
                             ,l_function_code
                             ,l_region_code);



  x_is_there_time := 'N';

--  BSC_PMF_UI_API_PUB.Get_DimLevel_Viewby( 1
  BIS_PMV_BSC_API_PUB.Get_DimLevel_Viewby( 1
                                         ,l_region_code
                                         ,p_measure_short_name
                                         ,l_DimLevel_Viewby_Tbl
                                         ,x_return_status
                                         ,x_msg_count
                                         ,x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  -- loop over the TABLE RECORD obtained from above call. Parse it into the Dimension and dimension level.
  l_cntr := 1;
  for l_cntr in 1..l_DimLevel_Viewby_Tbl.count loop
    l_temp_dim := substr(l_DimLevel_Viewby_Tbl(l_cntr).Dim_DimLevel, 1, (instr(l_DimLevel_Viewby_Tbl(l_cntr).Dim_DimLevel, '+') - 1));
    l_temp_level := substr(l_DimLevel_Viewby_Tbl(l_cntr).Dim_DimLevel, (instr(l_DimLevel_Viewby_Tbl(l_cntr).Dim_DimLevel, '+')+1));


  -- Determine if the current dimension is time dimension
  if (is_time_dim = 'N') then
    sub_string := instr(l_temp_dim, 'TIME');
    if (sub_string > 0) then
      is_time_dim := 'Y';
      x_is_there_time := 'Y';
    end if;
  end if;

    -- With the parsed Dimension, check if it exists in the local TABLE Record.  If it exists then set

    -- the New Level Flag to 'N' and add the level to the level member.
    l_2cntr := 1;
    l_new_level := 'Y';
    l_number_records := l_Pmv_Dim_Levels_Tbl.count;
    for l_2cntr in 1..l_number_records loop
      if (l_Pmv_Dim_Levels_Tbl(l_2cntr).Dim_Name = l_temp_dim) then
        l_new_level := 'N';
        if (l_Pmv_Dim_Levels_Tbl(l_2cntr).Dim_Short_Level is null) then
          l_Pmv_Dim_Levels_Tbl(l_2cntr).Dim_Short_Level := l_temp_level || ', -' ||
            l_DimLevel_Viewby_Tbl(l_cntr).Viewby_Applicable || ',' ||
            l_DimLevel_Viewby_Tbl(l_cntr).All_Applicable || ';';
        else
          l_Pmv_Dim_Levels_Tbl(l_2cntr).Dim_Short_Level := l_Pmv_Dim_Levels_Tbl(l_2cntr).Dim_Short_Level ||
            l_temp_level || ', -' || l_DimLevel_Viewby_Tbl(l_cntr).Viewby_Applicable || ',' ||
            l_DimLevel_Viewby_Tbl(l_cntr).All_Applicable || ';';
        end if;
      end if;
    end loop;

    if (l_new_level = 'Y') then
      l_Pmv_Dim_Levels_Tbl(l_number_records + 1).Dim_Name := l_temp_dim;
      l_Pmv_Dim_Levels_Tbl(l_number_records + 1).Dim_Short_Level := l_temp_level || ', -' ||
                                 l_DimLevel_Viewby_Tbl(l_cntr).Viewby_Applicable || ',' ||
                                 l_DimLevel_Viewby_Tbl(l_cntr).All_Applicable || ';';
    end if;

  end loop;

  -- set the values in the record to the OUT NOCOPY parameters. Only setting up to the size l_number_records
  -- adeulgao changed from l_number_records to l_Pmv_Dim_Levels_Tbl.COUNT

  l_cntr := 1;
  for l_cntr in 1..l_Pmv_Dim_Levels_Tbl.COUNT loop
    -- set the values in the record to the OUT NOCOPY parameters.
        if (l_cntr =1) then
            x_dim1_name := l_Pmv_Dim_Levels_Tbl(1).Dim_Name;
            x_dim1_levels := l_Pmv_Dim_Levels_Tbl(1).Dim_Short_Level;
        elsif (l_cntr =2) then
            x_dim2_name := l_Pmv_Dim_Levels_Tbl(2).Dim_Name;
            x_dim2_levels := l_Pmv_Dim_Levels_Tbl(2).Dim_Short_Level;
        elsif (l_cntr =3) then
            x_dim3_name := l_Pmv_Dim_Levels_Tbl(3).Dim_Name;
            x_dim3_levels := l_Pmv_Dim_Levels_Tbl(3).Dim_Short_Level;
        elsif (l_cntr =4) then
            x_dim4_name := l_Pmv_Dim_Levels_Tbl(4).Dim_Name;
            x_dim4_levels := l_Pmv_Dim_Levels_Tbl(4).Dim_Short_Level;
        elsif (l_cntr =5) then
            x_dim5_name := l_Pmv_Dim_Levels_Tbl(5).Dim_Name;
            x_dim5_levels := l_Pmv_Dim_Levels_Tbl(5).Dim_Short_Level;
        elsif (l_cntr =6) then
            x_dim6_name := l_Pmv_Dim_Levels_Tbl(6).Dim_Name;
            x_dim6_levels := l_Pmv_Dim_Levels_Tbl(6).Dim_Short_Level;
        elsif (l_cntr =7) then
            x_dim7_name := l_Pmv_Dim_Levels_Tbl(7).Dim_Name;
            x_dim7_levels := l_Pmv_Dim_Levels_Tbl(7).Dim_Short_Level;
        end if;
  end loop;

 /***********************************************************
  if (l_Pmv_Dim_Levels_Tbl(1).Dim_Name is not null) then
    x_dim1_name := l_Pmv_Dim_Levels_Tbl(1).Dim_Name;
    x_dim1_levels := l_Pmv_Dim_Levels_Tbl(1).Dim_Short_Level;
  end if;
  if (l_Pmv_Dim_Levels_Tbl(2).Dim_Name is not null) then
    x_dim2_name := l_Pmv_Dim_Levels_Tbl(2).Dim_Name;
    x_dim2_levels := l_Pmv_Dim_Levels_Tbl(2).Dim_Short_Level;
  end if;
  if (l_Pmv_Dim_Levels_Tbl(3).Dim_Name is not null) then
    x_dim3_name := l_Pmv_Dim_Levels_Tbl(3).Dim_Name;
    x_dim3_levels := l_Pmv_Dim_Levels_Tbl(3).Dim_Short_Level;
  end if;
  if (l_Pmv_Dim_Levels_Tbl(4).Dim_Name is not null) then
    x_dim4_name := l_Pmv_Dim_Levels_Tbl(4).Dim_Name;
    x_dim4_levels := l_Pmv_Dim_Levels_Tbl(4).Dim_Short_Level;
  end if;
  if (l_Pmv_Dim_Levels_Tbl(5).Dim_Name is not null) then
    x_dim5_name := l_Pmv_Dim_Levels_Tbl(5).Dim_Name;
    x_dim5_levels := l_Pmv_Dim_Levels_Tbl(5).Dim_Short_Level;
  end if;
  if (l_Pmv_Dim_Levels_Tbl(6).Dim_Name is not null) then
    x_dim6_name := l_Pmv_Dim_Levels_Tbl(6).Dim_Name;
    x_dim6_levels := l_Pmv_Dim_Levels_Tbl(6).Dim_Short_Level;
  end if;
  if (l_Pmv_Dim_Levels_Tbl(7).Dim_Name is not null) then
    x_dim7_name := l_Pmv_Dim_Levels_Tbl(7).Dim_Name;
    x_dim7_levels := l_Pmv_Dim_Levels_Tbl(7).Dim_Short_Level;
  end if;
 *****************************************************************/

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
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);


end Get_PMV_Report_Levels;

/************************************************************************************
************************************************************************************/


function get_KPI_Time_Stamp(
  p_kpi_id              IN      number
) return varchar2 is
   l_time_stamp  date;
begin
   l_time_stamp := BSC_KPI_PUB.get_KPI_Time_Stamp(p_kpi_id);
   return  TO_CHAR(l_time_stamp , g_time_stamp_format );

EXCEPTION
  WHEN OTHERS THEN
    return null;
end get_KPI_Time_Stamp;

/************************************************************************************
************************************************************************************/

FUNCTION remove_percent(
  p_input IN VARCHAR2
) RETURN NUMBER IS
BEGIN
IF (SUBSTR(p_input, LENGTH(p_input), 1) = '%') THEN
  RETURN SUBSTR(p_input, 1, LENGTH(p_input)-1);
ELSE
  RETURN p_input;
END IF;
END remove_percent;

/************************************************************************************

  Adeulgao changed

  The API now call get_DimObj_ViewBy_Tbl()
  written in BSC_BIS_KPI_MEAS_PUB to get dimension levels
  associated with PMV report.

************************************************************************************/

FUNCTION is_In_Dimension
(       p_measure_short_name IN  VARCHAR2
    ,   p_dims_short_name    IN  VARCHAR2
    ,   p_dim_obj            IN  VARCHAR2
) RETURN VARCHAR2
IS
    l_region_code          VARCHAR2(80);
    l_function_code      VARCHAR2(80);
    l_DimObj_ViewBy_Tbl    BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type;
    l_return_status        VARCHAR2(10);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_temp                 VARCHAR2(8000);
    l_table_index      NUMBER;

BEGIN
    --DBMS_OUTPUT.PUT_LINE(' Before ');

    /*SELECT  DISTINCT region_code Region
    INTO    l_region_code
    FROM    ak_region_items
    WHERE   attribute1= 'MEASURE'
    AND     attribute2 = p_measure_short_name;*/

    --DBMS_OUTPUT.PUT_LINE(' After ');

    BSC_JV_PMF.get_Pmf_Measure
              (        p_Measure_ShortName   =>    p_Measure_Short_Name
                      ,x_function_name       =>    l_function_code
                      ,x_region_code         =>    l_Region_Code
          );

    IF (l_region_code IS NULL) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --DBMS_OUTPUT.PUT_LINE(' ******* After 1');

    BSC_BIS_KPI_MEAS_PUB.get_DimObj_ViewBy_Tbl
        (       p_Measure_Short_Name   =>   p_measure_short_name
              ,   p_Region_Code          =>   l_region_code
              ,   x_DimObj_ViewBy_Tbl    =>   l_DimObj_ViewBy_Tbl
              ,   x_return_status        =>   l_return_status
              ,   x_msg_count            =>   l_msg_count
              ,   x_msg_data             =>   l_msg_data
          );

  IF (l_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    --DBMS_OUTPUT.PUT_LINE(' *** Error calling PMV API');
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  FOR l_table_index IN 0..l_DimObj_ViewBy_Tbl.COUNT-1
  LOOP

    IF (TRIM(l_DimObj_ViewBy_Tbl(l_table_index).p_Dimension_Name) = p_dims_short_name ) THEN

      --DBMS_OUTPUT.PUT_LINE(' dimension found -- '||l_DimObj_ViewBy_Tbl(l_table_index).p_Dimension_Name);
      WHILE (is_more(  p_dim_short_names  =>  l_DimObj_ViewBy_Tbl(l_table_index).p_Dim_Object_Names
                          ,p_dim_name         =>  l_temp)
          ) LOOP

            --DBMS_OUTPUT.PUT_LINE(' searched -- '||l_temp);

              l_temp := l_temp||',';
              IF (TRIM(SUBSTR(l_temp, 0, INSTR(l_temp, ',') - 1)) = p_dim_obj) THEN
                  RETURN 'Y';
              END IF;
          END LOOP;
    END IF;
  END LOOP;

  RETURN 'N';

EXCEPTION
    WHEN OTHERS THEN
    RAISE;
END is_In_Dimension;

FUNCTION is_group_selected
(
    p_tab_id    IN  NUMBER
  ,   p_group_id  IN  NUMBER

) RETURN VARCHAR2
IS
l_count  NUMBER;

BEGIN

  SELECT count(*)
  INTO  l_count
  FROM  BSC_TAB_IND_GROUPS_B
  WHERE tab_id =  p_tab_id
  AND   ind_group_id  =   p_group_id;

  IF (l_count = 0) THEN
    RETURN 'N';
  ELSE
    RETURN 'Y';
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'N';
END is_group_selected;


/********************************************************************************
 Name :- Assign_Kpi_Tab
 Description :- This procedure will assign the Kpis to the tab.
        It will internally call the existing API Assign_KPI.
        Internally it will get the group of the kpi and check if the kpi is
        assigned to the tab, if not then it will assign the group to the tab
        and after that assign the kpi to the tab.
Input :-    p_tab_id
        p_kpi_ids  Comma separated kpi ids.
Creator : - ashankar 13-FEB-2003
/********************************************************************************/


PROCEDURE Assign_Kpi_Tab
(
      p_commit              IN              VARCHAR2   := FND_API.G_FALSE
    , p_tab_id      IN      NUMBER
    , p_kpi_ids     IN      VARCHAR2
    , x_return_status   IN OUT NOCOPY   VARCHAR2
    , x_msg_count       IN OUT NOCOPY   NUMBER
    , x_msg_data        IN OUT NOCOPY   VARCHAR2
    , p_time_stamp  IN      VARCHAR2  :=  NULL
)IS
    l_kpi_ids       VARCHAR2(32000);
        l_kpi_id        VARCHAR2(10);
    l_Time_Stamp    VARCHAR2(100);
BEGIN
    SAVEPOINT BscPmfUIAssignKpiTab;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF(p_kpi_ids IS NOT NULL) THEN
        l_kpi_ids := p_kpi_ids;
        l_Time_Stamp := p_time_stamp;
        WHILE (is_more(  p_dim_short_names  =>  l_kpi_ids
                    ,p_dim_name         =>  l_kpi_id)
           ) LOOP

             BSC_PMF_UI_WRAPPER.Assign_KPI
             (
                  p_commit          =>    FND_API.G_FALSE
                , p_kpi_id          =>    l_kpi_id
                , p_tab_id          =>    p_tab_id
                , x_return_status   =>    x_return_status
                , x_msg_count       =>    x_msg_count
                , x_msg_data        =>    x_msg_data
                , p_time_stamp      =>    l_Time_Stamp
          );
          IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          -- retrieving the current value of timestamp from database which will
          --be assigned to p_time_stamp after the 1st cycle.

          l_Time_Stamp := BSC_BIS_LOCKS_PVT.get_tab_time_stamp(p_tab_id);
           END LOOP;
    END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback TO BscPmfUIAssignKpiTab;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback TO BscPmfUIAssignKpiTab;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if( x_msg_data is null) then

      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    end if;

  WHEN NO_DATA_FOUND THEN
    rollback TO BscPmfUIAssignKpiTab;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

  WHEN OTHERS THEN
    rollback TO BscPmfUIAssignKpiTab;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Assign_Kpi_Tab ';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Assign_Kpi_Tab ';
    END IF;

END Assign_Kpi_Tab;

FUNCTION get_Tab_Id
(
    p_Tab_Name  IN  VARCHAR2
) RETURN NUMBER IS

  CURSOR c_Tab_Id IS
  SELECT Tab_ID
  FROM   BSC_TABS_VL
  WHERE  Name = p_Tab_Name;

  l_Tab_Id NUMBER := -2;
BEGIN
  IF (c_Tab_Id%ISOPEN) THEN
      CLOSE c_Tab_Id;
  END IF;
  OPEN c_Tab_Id;
      FETCH c_Tab_Id INTO l_Tab_Id;
  CLOSE c_Tab_Id;
  RETURN l_Tab_Id;
EXCEPTION
    WHEN OTHERS THEN
    IF (c_Tab_Id%ISOPEN) THEN
        CLOSE c_Tab_Id;
    END IF;
        RETURN l_Tab_Id;
END get_Tab_Id;

/*
 * Objective Calendar properties. (Added as part of Bug #5584826 fix)
 * Internal procedure called from Update_Kpi_Periodicities only.
 * The API is called seperately for objective and its shared objectives if exists.
 */

PROCEDURE Update_Obj_Cal_properties (
   p_commit              IN             VARCHAR2
  ,p_calendar_id         IN             NUMBER
  ,l_Bsc_Kpi_Entity_Rec  IN OUT NOCOPY BSC_KPI_PUB.Bsc_Kpi_Entity_Rec
  ,l_periodicities_tbl   IN BSC_BIS_LOCKS_PUB.t_numberTable
  ,l_current_periods     IN BSC_BIS_LOCKS_PUB.t_numberTable
  ,l_Dft_periodicity_id  IN NUMBER
  ,l_action_flag         IN NUMBER
  ,x_return_status       OUT NOCOPY     VARCHAR2
  ,x_msg_count           OUT NOCOPY     NUMBER
  ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
  l_count NUMBER;

  CURSOR c_reorder_periods IS
  SELECT rownum-1 newRow, periodicity_id
  FROM   bsc_kpi_periodicities
  WHERE  indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

BEGIN
  -- Create the new periodicites
  FOR l_count IN 1.. l_periodicities_tbl.count LOOP
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id := l_periodicities_tbl(l_count);
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Current_Period := l_current_periods (l_count);

    IF l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Current_Period > 1900 then
      l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Num_Years := 10;
      l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Previous_Years := 5;
    ELSE
      l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Num_Years := 0;
      l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Previous_Years := 0 ;
    END IF;

    BSC_KPI_PUB.Create_Kpi_Periodicity
    ( p_commit              => p_commit
    , p_Bsc_Kpi_Entity_Rec  => l_Bsc_Kpi_Entity_Rec
    , x_return_status       => x_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END LOOP;

  -- Reorder the sequence.
  FOR cd_reorder IN c_reorder_periods LOOP
    UPDATE bsc_kpi_periodicities
    SET    display_order = cd_reorder.newRow
    WHERE  periodicity_id = cd_reorder.periodicity_id
    AND    indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
  END LOOP;

  UPDATE bsc_kpis_b
  SET    calendar_id      = p_calendar_id
        ,periodicity_id   = l_Dft_periodicity_id
        ,last_update_date = SYSDATE
  WHERE  indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

  UPDATE bsc_kpi_periodicities
  SET    user_level0 = C_DISABLE_FLAG
        ,user_level1 = C_DISABLE_FLAG
  WHERE  indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
  AND    periodicity_id = l_Dft_periodicity_id;

  IF (l_action_flag IS NOT NULL) THEN
    --Reset the db_transform
    --ppandey 'DB_TRANSFORM' is Objective Type 0->Precalculated, 1->normal, 2->Target at differet Benchmarks.
    IF (l_action_flag = BSC_DESIGNER_PVT.G_ActionFlag.Prototype) THEN
      UPDATE bsc_kpi_properties
      SET    property_value = 1
      WHERE  indicator      = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
      AND    property_code  = 'DB_TRANSFORM'
      AND    property_value = 2;

      UPDATE bsc_kpi_periodicities
      SET    target_level = 1
      WHERE  indicator    = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
      --AND    target_level <> 1;
    END IF;

    BSC_DESIGNER_PVT.ActionFlag_Change
    ( x_indicator => l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
    , x_newflag   => l_action_flag
    );
  END IF;
END Update_Obj_Cal_properties;

/************************************************************************************
--      API name        : Update_Periodicity_Props
--      Type            : Private
************************************************************************************/
PROCEDURE Update_Periodicity_Props(
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator           IN   NUMBER
 ,p_calendar_id         IN   NUMBER
 ,p_Periods_In_Graph    IN   FND_TABLE_OF_NUMBER := NULL
 ,p_Periodicity_Id_Tbl  IN   FND_TABLE_OF_NUMBER := NULL
 ,p_Number_Of_Years     IN   NUMBER := 10
 ,p_Previous_Years      IN   NUMBER := 5
 ,p_cascade_shared      IN   BOOLEAN := FALSE
 ,x_return_status       OUT  NOCOPY   VARCHAR2
 ,x_msg_count           OUT  NOCOPY   NUMBER
 ,x_msg_data            OUT  NOCOPY   VARCHAR2
) IS
 l_Max_Periods NUMBER := 0;
 l_Bsc_Kpi_Entity_Rec  BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

 CURSOR c_share_kpis IS
 SELECT
   indicator
 FROM
   bsc_kpis_b
 WHERE
   source_indicator = p_Indicator
   AND PROTOTYPE_FLAG <> 2;

 CURSOR c_Kpi_Periodicities IS
 SELECT
   kp. periodicity_id,
   p.periodicity_type,
   DECODE(p.periodicity_type, 1 , kp.num_of_years, p.num_of_periods) max_periods
 FROM
   bsc_kpi_periodicities kp,
   bsc_sys_periodicities_vl p
 WHERE
   kp.indicator = p_Indicator
   AND kp.periodicity_id = p.periodicity_id
   AND p.calendar_id = p_calendar_id;
BEGIN

  SAVEPOINT  UpdatePeriodicityPropsPUB;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  FOR cd IN c_Kpi_Periodicities LOOP
    IF p_Periodicity_Id_Tbl IS NOT NULL AND p_Periods_In_Graph IS NOT NULL THEN
      FOR i IN 1..p_Periodicity_Id_Tbl.COUNT LOOP
        IF p_Periodicity_Id_Tbl(i) = cd.periodicity_id THEN

         -- If both are same ignore otherwise viewport_flag = 1 and viewport_defaultsize = p_Periods_In_Graph(i)
          IF cd.max_periods > p_Periods_In_Graph(i) THEN
             l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Flag := 1;
             l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Default_Size :=  p_Periods_In_Graph(i);
          ELSE
             l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Flag := 0;
             l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Default_Size :=  0;
          END IF;

          IF cd.periodicity_type = 1 THEN
            l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Num_Years := p_Number_Of_Years;
            l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Previous_Years := p_Previous_Years;
          ELSE
            l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Num_Years := 0;
            l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Previous_Years := 0;
          END IF;

          l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Indicator;
          l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id := cd.periodicity_id;
          BSC_KPI_PUB.Update_Kpi_Periodicity (
            p_commit             => FND_API.G_FALSE
           ,p_Bsc_Kpi_Entity_Rec =>  l_Bsc_Kpi_Entity_Rec
           ,x_return_status      =>  x_return_status
           ,x_msg_count          =>  x_msg_count
           ,x_msg_data           =>  x_msg_data
          ) ;
          IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          IF p_cascade_shared THEN
            FOR cd IN c_share_kpis LOOP
              l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := cd.Indicator;
              BSC_KPI_PUB.Update_Kpi_Periodicity (
                p_commit             => FND_API.G_FALSE
               ,p_Bsc_Kpi_Entity_Rec =>  l_Bsc_Kpi_Entity_Rec
               ,x_return_status      =>  x_return_status
               ,x_msg_count          =>  x_msg_count
               ,x_msg_data           =>  x_msg_data
              );
	      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
	        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	      END IF;
	    END LOOP;
          END IF;
        END IF;
      END LOOP;
    END IF;
  END LOOP;

  IF p_Commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UpdatePeriodicityPropsPUB;
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UpdatePeriodicityPropsPUB;
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO UpdatePeriodicityPropsPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' ->BSC_PMF_UI_WRAPPER.Update_Periodicity_Props ';
    ELSE
        x_msg_data      :=  SQLERRM||'BSC_PMF_UI_WRAPPER.Update_Periodicity_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO UpdatePeriodicityPropsPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' ->BSC_PMF_UI_WRAPPER.Update_Periodicity_Props ';
    ELSE
        x_msg_data      :=  SQLERRM||'BSC_PMF_UI_WRAPPER.Update_Periodicity_Props ';
    END IF;
END Update_Periodicity_Props;


/********************************************************************************
 Name :- Update_Kpi_Periodicities
 Description :- This procedure will assign the Periodicities to one KPI
        It will replace the previous peridicities with the new set of
        periodicities.

Input :-  p_kpi_id           Indicator ID (Master)
          p_calendar_id      Calendar Id. It is mandatory
          p_periodicity_ids  Set of periodicities separates by ","
                             when it is null it will assign allo the Calendar
                             periodicities
          p_Dft_periodicity_id   Default kpi periodicity Id
                                 It is null it will set the first periodicity
                                 id in the p_periodicity_ids LIST


Creator : - William Cano APR 16 / 2003
/********************************************************************************/
procedure Update_Kpi_Periodicities(
  p_commit              IN             VARCHAR2 -- := FND_API.G_FALSE
 ,p_kpi_id              IN             NUMBER
 ,p_calendar_id         IN             NUMBER
 ,p_periodicity_ids     IN             VARCHAR2
 ,p_Dft_periodicity_id  IN             NUMBER
 ,p_Periods_In_Graph    IN             FND_TABLE_OF_NUMBER := NULL
 ,p_Periodicity_Id_Tbl  IN             FND_TABLE_OF_NUMBER := NULL
 ,p_Number_Of_Years     IN             NUMBER := 10
 ,p_Previous_Years      IN             NUMBER := 5
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
  l_periodicity_ids     VARCHAR2(300);
  l_count               NUMBER;
  l_per_count           NUMBER;
  l_cur_cal_id          NUMBER;
  l_cur_periodicity_id  NUMBER;
  l_Bsc_Kpi_Entity_Rec  BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(500);
  l_Dft_periodicity_id  NUMBER ;
  l_periodicity_id      NUMBER;
  l_current_period      NUMBER;
  l_periodicities_tbl   BSC_BIS_LOCKS_PUB.t_numberTable;
  l_current_periods     BSC_BIS_LOCKS_PUB.t_numberTable;
  l_Indic_Type          BSC_KPIS_B.INDICATOR_TYPE%TYPE;
  l_Indic_Config_Type   BSC_KPIS_B.CONFIG_TYPE%TYPE;
  l_Periodicity_Type    BSC_SYS_PERIODICITIES.PERIODICITY_ID%TYPE;
  l_Is_Invalid_Per_Sim  BOOLEAN := FALSE;
  l_Period_Name         BSC_SYS_PERIODICITIES_TL.NAME%TYPE;
  l_Invalid_Period_Name BSC_SYS_PERIODICITIES_TL.NAME%TYPE;
  l_Count_Tables        NUMBER;
  l_action_flag         NUMBER;
  l_old_periodicities   NUMBER;
  l_new_periodicities   NUMBER;
  l_cur_prototype_flag  NUMBER;
  l_is_prototype        BOOLEAN;
  l_Old_Number_Years    bsc_kpi_periodicities.num_of_years%TYPE := 0;
  l_Old_Previous_Years  bsc_kpi_periodicities.previous_years%TYPE := 0;
  l_New_Number_Years    bsc_kpi_periodicities.num_of_years%TYPE := 0;
  l_New_Previous_Years  bsc_kpi_periodicities.previous_years%TYPE := 0;


  CURSOR c_share_kpis IS
   SELECT indicator
   FROM BSC_KPIS_B
   WHERE source_indicator = p_kpi_id
     AND PROTOTYPE_FLAG <> 2;

  CURSOR c_Yearly_Periodicity IS
  SELECT
    NVL(kp.num_of_years,0),
    NVL(kp.previous_years,0)
  FROM
    bsc_kpi_periodicities kp,
    bsc_sys_periodicities_vl p
  WHERE
    kp.indicator(+) = p_kpi_id
    AND kp.periodicity_id(+) = p.periodicity_id
    AND p.calendar_id = p_calendar_id;

BEGIN

  SAVEPOINT BSCUpdKpiPeriodicities;
  FND_MSG_PUB.Initialize;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_periodicity_ids := TRIM(p_periodicity_ids);
  l_Dft_periodicity_id := NULL;

  /* The following validation apply for this API
    1)Simulation tree cannot have more than one periodicity
    2)Simulation tree cannot have periodicities of type 1,9,10
 */

  IF(l_periodicity_ids IS NULL )THEN
    RETURN;
    -- It should give a message, but needs to be verified that it has no impact on Report Designer.
    /*FND_MESSAGE.SET_NAME('BSC','BSC_D_KPI_AT_LEAST_1_PERIOD');
      FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;*/
  END IF;

  OPEN c_Yearly_Periodicity;
  FETCH c_Yearly_Periodicity INTO l_Old_Number_Years,l_Old_Previous_Years;
  CLOSE c_Yearly_Periodicity;

  SELECT indicator_type, config_type, calendar_id, periodicity_id, prototype_flag
  INTO   l_Indic_Type,l_Indic_Config_Type, l_cur_cal_id, l_cur_periodicity_id, l_cur_prototype_flag
  FROM   bsc_kpis_b
  WHERE  indicator = p_kpi_id;

  --now we will support more than 1 periodicity for Simulation tree.
  -- so relaxing this condition
  /*IF(l_Indic_Type = 1 AND l_Indic_Config_Type = 7) THEN

    l_sql :='
      SELECT COUNT(1)
      FROM   bsc_sys_periodicities_vl P
           , bsc_sys_calendars_b C
      WHERE C.calendar_id =:1
      AND   P.calendar_id = C.calendar_id';
    l_sql := l_sql || '  AND periodicity_id IN (' || l_periodicity_ids || ')';

    EXECUTE IMMEDIATE l_sql INTO l_count USING p_calendar_id;

    IF(l_count > 1) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_D_ONE_PERIOD_IN_SIM_TREE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;*/

  IF (l_cur_cal_id = p_calendar_id) THEN -- Calendar is not changed.
    -- Find new Periods added and make the list which will be passed to Update_Obj_Cal_properties

    -- If yearly get the fiscal year, else put it to 1, it will be updated by loader as per the data loaded.
    l_sql :='
    SELECT P.periodicity_id
          ,DECODE (P.yearly_flag, 1, C.fiscal_year, 1 )
          ,P.periodicity_type
          ,P.name
    FROM   bsc_sys_periodicities_vl P
         , bsc_sys_calendars_b C
    WHERE C.calendar_id =:1
    AND   P.calendar_id = C.calendar_id
    AND   periodicity_id NOT IN (
          SELECT periodicity_id FROM bsc_kpi_periodicities where indicator = :2
    )';
    l_sql := l_sql || '  AND periodicity_id IN (' || l_periodicity_ids || ')';

    l_count := 0;
    OPEN l_cursor FOR l_sql USING p_calendar_id, p_kpi_id;
        LOOP
          FETCH   l_cursor INTO l_periodicity_id, l_current_period ,l_periodicity_type,l_Period_Name;
          EXIT WHEN l_cursor%NOTFOUND;
          l_count :=  l_count + 1;
          l_periodicities_tbl(l_count) := l_periodicity_id;
          l_current_periods (l_count)  := l_current_period;
        END LOOP;
    CLOSE l_cursor;

    IF (l_cur_prototype_flag = BSC_DESIGNER_PVT.G_ActionFlag.Prototype) THEN
      l_is_prototype := TRUE;
    ELSE
      l_is_prototype := FALSE;
    END IF;

    IF (NOT l_is_prototype AND l_count > 0) THEN
      l_action_flag := BSC_DESIGNER_PVT.G_ActionFlag.Prototype;
      l_is_prototype:= TRUE;
    ELSE
      SELECT COUNT(1)
      INTO   l_old_periodicities
      FROM   bsc_kpi_periodicities
      WHERE  indicator = p_kpi_id;
    END IF;

    -- Delete the Periods which are Removed (from master and shared objectives).
    l_sql :='
    DELETE bsc_kpi_periodicities
    WHERE  indicator IN
           (SELECT indicator
            FROM   bsc_kpis_b
            WHERE  indicator = :1 OR source_indicator = :2)';
    l_sql := l_sql || '  AND periodicity_id NOT IN (' || l_periodicity_ids || ')';

    EXECUTE IMMEDIATE l_sql USING p_kpi_id, p_kpi_id;

    IF (l_count = 0) THEN
      SELECT COUNT(1)
      INTO   l_new_periodicities
      FROM   bsc_kpi_periodicities
      WHERE  indicator = p_kpi_id;
      IF (l_old_periodicities <> l_new_periodicities) THEN
        l_action_flag := BSC_DESIGNER_PVT.G_ActionFlag.Prototype;
      END IF;
    END IF;

    -- p_Dft_periodicity_id is null in case of Report Designer Create flow Bug #5629309
    IF (p_Dft_periodicity_id IS NOT NULL) THEN
      l_sql :='
        SELECT COUNT(1)
        FROM   bsc_sys_periodicities_vl P
             , bsc_sys_calendars_b C
        WHERE C.calendar_id =:1
        AND   P.calendar_id = C.calendar_id
        AND   periodicity_id = :2';
        l_sql := l_sql || '  AND periodicity_id IN (' || l_periodicity_ids || ')';

      EXECUTE IMMEDIATE l_sql INTO l_per_count USING p_calendar_id, p_Dft_periodicity_id;

      IF (l_per_count > 0 ) THEN
        l_Dft_periodicity_id := p_Dft_periodicity_id;
      END IF;
    END IF;

    IF (l_Dft_periodicity_id IS NULL) THEN
      IF (l_count > 0) THEN
        l_Dft_periodicity_id:= l_periodicities_tbl(1);
      ELSE
        SELECT periodicity_id
        INTO   l_Dft_periodicity_id
        FROM   bsc_kpi_periodicities
        WHERE  indicator = p_kpi_id
        AND    rownum = 1;
      END IF;
    END IF;

    IF (l_Dft_periodicity_id <> l_cur_periodicity_id) THEN
      IF (NOT l_is_prototype) THEN
        l_action_flag := BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color;
      END IF;
    -- Reset the default period to enable, it will be taken care in Update_Obj_Cal_properties
      UPDATE bsc_kpi_periodicities
      SET    user_level0=C_ENABLE_FLAG, user_level1=C_ENABLE_FLAG
      WHERE  user_level0=C_DISABLE_FLAG
      AND    user_level1=C_DISABLE_FLAG
      AND    periodicity_id = l_cur_periodicity_id
      AND    indicator IN
             (SELECT indicator
              FROM   bsc_kpis_b
              WHERE  indicator = p_kpi_id
              OR     source_indicator=p_kpi_id);
    END IF;

  ELSE -- calendar is changed for the objective
    --We don't need to check if the current prototype_flag is not equal to
    --prototype_flag,because changing the calendar always result in
    --structural changes.so we will pass the prototype_flag
    /*IF (l_cur_prototype_flag <> BSC_DESIGNER_PVT.G_ActionFlag.Prototype) THEN
      l_action_flag := BSC_DESIGNER_PVT.G_ActionFlag.Prototype;
    END IF;*/
    l_action_flag := BSC_DESIGNER_PVT.G_ActionFlag.Prototype;

    l_sql :='
    SELECT P.periodicity_id
          ,DECODE (P.yearly_flag, 1, C.fiscal_year, 1 )
          ,P.periodicity_type
          ,P.name
    FROM   bsc_sys_periodicities_vl P
         , bsc_sys_calendars_b C
    WHERE C.calendar_id =:1
    AND   P.calendar_id = C.calendar_id';
    l_sql := l_sql || '  AND periodicity_id IN (' || l_periodicity_ids || ')';
    l_count := 0;

    OPEN l_cursor FOR l_sql USING p_calendar_id;
    LOOP
      FETCH   l_cursor INTO l_periodicity_id, l_current_period ,l_periodicity_type,l_Period_Name;
      EXIT WHEN l_cursor%NOTFOUND;
      l_count :=  l_count + 1;
      l_periodicities_tbl(l_count) := l_periodicity_id;
      l_current_periods (l_count)  := l_current_period;
      IF p_Dft_periodicity_id = l_periodicity_id THEN
       l_Dft_periodicity_id := l_periodicity_id ;
      END IF;
      -- Following code doesn't seems to be used anywhere
      IF(l_periodicity_type = 1 OR l_periodicity_type = 9 OR l_periodicity_type = 10 ) THEN
        l_Is_Invalid_Per_Sim := TRUE;
        l_Invalid_Period_Name := l_Period_Name;
      END IF;
    END LOOP;
    CLOSE l_cursor;

    -- Remove all the Master/Shared Objective periodicities.
    DELETE bsc_kpi_periodicities p
    WHERE p.indicator in
       (SELECT k.indicator
        FROM   bsc_kpis_b k
        WHERE  k.indicator = p_kpi_id
        OR k.source_indicator = p_kpi_id);

    IF (l_Dft_periodicity_id IS NULL) THEN
      l_Dft_periodicity_id:= l_periodicities_tbl(1);
    END IF;
  END IF;

  -- If any chage then only do the operations
  -- l_action_flag null if no change, Color change on Default, prototype on calendar change or periodicity add/remove.
  IF (l_action_flag IS NOT NULL) THEN
    BSC_KPI_PUB.Initialize_Kpi_Entity_Rec
    ( p_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
    , x_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- All the periodicities will be enabled.
    -- Only default will be disabled, which is taken care in Update_Obj_Cal_properties.
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0 := C_ENABLE_FLAG;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1 := C_ENABLE_FLAG;

    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_kpi_id;
    l_periodicity_ids := TRIM(p_periodicity_ids);

    -- lock the KPI
    BSC_BIS_LOCKS_PUB.LOCK_KPI
    ( p_kpi_Id               => l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
    , p_time_stamp           => NULL
    , p_full_lock_flag       => FND_API.G_FALSE
    , x_return_status        => x_return_status
    , x_msg_count            => x_msg_count
    , x_msg_data             => x_msg_data
    );

    -- Create the new periodicites for Master.
    Update_Obj_Cal_properties (
      p_commit             => p_commit
     ,p_calendar_id        => p_calendar_id
     ,l_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
     ,l_periodicities_tbl  => l_periodicities_tbl
     ,l_current_periods    => l_current_periods
     ,l_Dft_periodicity_id => l_Dft_periodicity_id
     ,l_action_flag        => l_action_flag
     ,x_return_status      => x_return_status
     ,x_msg_count          => x_msg_count
     ,x_msg_data           => x_msg_data
    );

    FOR l_count IN 1.. l_periodicities_tbl.count LOOP
      l_periodicity_id := l_periodicities_tbl(l_count);

      SELECT COUNT(1)
      INTO   l_Count_Tables
      FROM   bsc_kpi_data_tables
      WHERE  indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
      AND    periodicity_id = l_periodicity_id;
      IF(l_Count_Tables = 0) THEN
        INSERT INTO bsc_kpi_data_tables
               ( indicator
               , periodicity_id
               , dim_set_id
               , level_comb)
        VALUES
               ( l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
               , l_periodicity_id
               , 0
               , '?'
        );

      END IF;
    END LOOP;

  -------------------------------------
  --  share kpis
  -------------------------------------
    IF (c_share_kpis%ISOPEN) THEN
      CLOSE c_share_kpis;
    END IF;

    OPEN c_share_kpis;
    LOOP
      FETCH  c_share_kpis INTO l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id ;
      EXIT WHEN c_share_kpis%NOTFOUND;

     Update_Obj_Cal_properties (
       p_commit             => p_commit
      ,p_calendar_id        => p_calendar_id
      ,l_Bsc_Kpi_Entity_Rec => l_Bsc_Kpi_Entity_Rec
      ,l_periodicities_tbl  => l_periodicities_tbl
      ,l_current_periods    => l_current_periods
      ,l_Dft_periodicity_id => l_Dft_periodicity_id
      ,l_action_flag        => l_action_flag
      ,x_return_status      => x_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data
     );

    END LOOP;
    CLOSE c_share_kpis;

  END IF;

  Update_Periodicity_Props (
    p_commit             => p_commit
   ,p_Indicator          => p_kpi_id
   ,p_calendar_id        => p_calendar_id
   ,p_Periods_In_Graph   => p_Periods_In_Graph
   ,p_Periodicity_Id_Tbl => p_Periodicity_Id_Tbl
   ,p_Number_Of_Years    => p_Number_Of_Years
   ,p_Previous_Years     => p_Previous_Years
   ,p_cascade_shared     => TRUE
   ,x_return_status      => x_return_status
   ,x_msg_count          => x_msg_count
   ,x_msg_data           => x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  OPEN c_Yearly_Periodicity;
  FETCH c_Yearly_Periodicity INTO l_New_Number_Years,l_New_Previous_Years;
  CLOSE c_Yearly_Periodicity;

  IF l_Old_Number_Years <> l_New_Number_Years OR
    l_Old_Previous_Years <> l_New_Previous_Years THEN
    BSC_DESIGNER_PVT.ActionFlag_Change(p_kpi_id , BSC_DESIGNER_PVT.G_ActionFlag.GAA_Update);
    FOR cd IN c_share_kpis LOOP
      BSC_DESIGNER_PVT.ActionFlag_Change(cd.indicator , BSC_DESIGNER_PVT.G_ActionFlag.GAA_Update);
    END LOOP;
  END IF;

  IF p_commit = FND_API.G_TRUE then
    commit;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCUpdKpiPeriodicities;
        IF (c_share_kpis%ISOPEN) THEN
            CLOSE c_share_kpis;
        END IF;
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
        ROLLBACK TO BSCUpdKpiPeriodicities;
        IF (c_share_kpis%ISOPEN) THEN
            CLOSE c_share_kpis;
        END IF;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCUpdKpiPeriodicities;
        IF (c_share_kpis%ISOPEN) THEN
            CLOSE c_share_kpis;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Update_Kpi_Periodicities ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Update_Kpi_Periodicities ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Update_Kpi_Periodicities;

/*
 * This procedure is used to check whether any KPI in a scorecard is attached to
 * any KPI region(KPI portlet).
 */
 procedure Check_Tab(
  p_tab_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ) is

   l_ret_status            varchar2(10);
   l_msg_data              varchar2(100);
   l_parent_obj_table  BIS_RSG_PUB_API_PKG.t_BIA_RSG_Obj_Table;
   l_index integer;
   l_dep_obj_name          varchar2(240);
   l_dep_obj_message       varchar2(1000);
   l_dep_obj_list          varchar2(2000);
   l_scr_name              BSC_TABS_VL.NAME%TYPE;
   l_scr_short_name        BSC_TABS_VL.SHORT_NAME%TYPE;
   l_objective_name        BSC_KPIS_VL.NAME%TYPE;
   l_Is_Ag_Type_Scorecard  VARCHAR2(1);
   l_exist_dependency      VARCHAR2(10);

    CURSOR c_scr IS
    SELECT name, short_name
    FROM   bsc_tabs_vl
    WHERE tab_id = p_tab_id;

    CURSOR c_Kpi_function IS
    SELECT c.function_name,d.name
    FROM bsc_oaf_analysys_opt_comb_v a,bsc_tab_indicators b,bis_indicators c,bsc_kpis_vl d
    WHERE a.indicator = b.indicator
    AND a.dataset_id = c.dataset_id
    AND a.indicator = d.indicator
    AND b.tab_id = p_tab_id;

   BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_dep_obj_list  := '';
    x_msg_data := '';
    l_exist_dependency := FND_API.G_FALSE;

    IF (c_scr%ISOPEN) THEN
      CLOSE c_scr;
    END IF;

    OPEN c_scr;
    FETCH c_scr INTO l_scr_name,l_scr_short_name;
    CLOSE c_scr;

    BSC_PMF_UI_WRAPPER.Check_Tabviews(
          p_tab_id             => p_tab_id
        , p_list_dependency    => FND_API.G_TRUE
        , x_exist_dependency   => l_exist_dependency
        , x_dep_obj_list       => l_dep_obj_list
        , x_return_status      => l_ret_status
        , x_msg_count          => x_msg_count
        , x_msg_data           => l_msg_data);

    IF ((l_ret_status IS NOT NULL) AND (l_ret_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        FND_MSG_PUB.Initialize;
        FND_MESSAGE.SET_NAME('BIS',l_msg_data);
        FND_MSG_PUB.ADD;
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_exist_dependency = FND_API.G_TRUE) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_SCR_DELETE_VIEW_ERR');
        FND_MESSAGE.SET_TOKEN('SCR_NAME', l_scr_name);
        FND_MESSAGE.SET_TOKEN('DEP_OBJ_LIST',l_dep_obj_list);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
         p_encoded   =>  FND_API.G_FALSE
       , p_count     =>  x_msg_count
       , p_data      =>  x_msg_data);
       return;
    END IF;

    IF (BSC_BIS_CUSTOM_KPI_UTIL_PUB.is_kpi_endtoend_scorecard(l_scr_short_name) = 'F') THEN
       RETURN;
    END IF;

    l_Is_Ag_Type_Scorecard := BSC_BIS_KPI_CRUD_PUB.is_Scorecard_From_Reports(l_scr_short_name);

    IF (l_Is_Ag_Type_Scorecard = FND_API.G_TRUE) THEN
        -- The scorecard, Report, Objective and Objective Group have the same name in
        -- an AG Report scenario.
        FND_MESSAGE.SET_NAME('BSC','BSC_AG_SCORECARD_DELETE');
        FND_MESSAGE.SET_TOKEN('SNAME', l_scr_name);
        FND_MESSAGE.SET_TOKEN('RNAME', l_scr_name);
        FND_MSG_PUB.ADD;
    ELSE
        FOR cd_kpi_function IN c_Kpi_function LOOP
            -- call the procedure to get the parent objects for each KPI
            l_dep_obj_name  := cd_kpi_function.function_name;
            l_objective_name := cd_kpi_function.name;
            l_parent_obj_table := BIS_RSG_PUB_API_PKG.GetParentObjects(l_dep_obj_name,'REPORT','PORTLET',l_ret_status,l_msg_data);
            IF ((l_ret_status IS NOT NULL) AND (l_ret_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
                FND_MSG_PUB.Initialize;
                FND_MESSAGE.SET_NAME('BIS',l_msg_data);
                FND_MSG_PUB.ADD;
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSE
                IF (l_parent_obj_table.COUNT > 0) THEN
                  l_index := l_parent_obj_table.first;
                  LOOP
                    FND_MESSAGE.SET_NAME('BSC','BSC_SCR_DEP_OBJ');
                    FND_MESSAGE.SET_TOKEN('OBJECTIVE',l_objective_name);
                    FND_MESSAGE.SET_TOKEN('KPI_REGION',l_parent_obj_table(l_index).user_object_name);
                    l_dep_obj_message := FND_MESSAGE.GET;
                    IF l_index = l_parent_obj_table.first THEN
                      l_dep_obj_list :=  '<ul><li>'|| l_dep_obj_message ||'</li>';
                    ELSE
                      l_dep_obj_list := '<li>'|| l_dep_obj_message ||'</li>';
                    END IF;
                    EXIT WHEN l_index = l_parent_obj_table.last;
                    l_index := l_parent_obj_table.next(l_index);
                  END LOOP;
                  l_dep_obj_list := l_dep_obj_list || '</ul>';
                  FND_MESSAGE.SET_NAME('BSC','BSC_SCR_DELETE');
                  FND_MESSAGE.SET_TOKEN('SCR_NAME', l_scr_name);
                  FND_MESSAGE.SET_TOKEN('DEP_OBJ_LIST',l_dep_obj_list);
                  FND_MSG_PUB.ADD;
                END IF;
            END IF;
        END LOOP;
    END IF;

    FND_MSG_PUB.Count_And_Get
    (      p_encoded   =>  FND_API.G_FALSE
       ,   p_count     =>  x_msg_count
       ,   p_data      =>  x_msg_data
    );
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_scr%ISOPEN) THEN
          CLOSE c_scr;
        END IF;
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
        IF (c_scr%ISOPEN) THEN
          CLOSE c_scr;
        END IF;
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
        IF (c_scr%ISOPEN) THEN
          CLOSE c_scr;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Delete_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Delete_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        IF (c_scr%ISOPEN) THEN
          CLOSE c_scr;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Delete_Tab ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Delete_Tab ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
  end Check_Tab;

PROCEDURE Check_Tabviews (
   p_tab_id              IN             NUMBER
  ,p_list_dependency     IN             VARCHAR2
  ,x_exist_dependency    OUT NOCOPY     VARCHAR2
  ,x_dep_obj_list        OUT NOCOPY     VARCHAR2
  ,x_return_status       OUT NOCOPY     VARCHAR2
  ,x_msg_count           OUT NOCOPY     NUMBER
  ,x_msg_data            OUT NOCOPY     VARCHAR2
 ) IS

  l_tab_view_id             BSC_TAB_VIEWS_VL.tab_view_id%TYPE;
  l_tab_view_name           BSC_TAB_VIEWS_VL.NAME%TYPE;
  l_dep_obj_list            VARCHAR2(2000);
  l_dep_obj_count           NUMBER;
  l_msg_data            VARCHAR2(1000);
  l_temp_list           VARCHAR2(200);
  l_msg_count           NUMBER;
  l_exist_dependency    VARCHAR2(10);

  CURSOR c_tab_views IS
    SELECT UNIQUE NAME, tab_view_id
    FROM BSC_TAB_VIEWS_VL
    WHERE tab_id = p_tab_id;

 BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_exist_dependency := FND_API.G_FALSE;

    FOR cd_tab_view IN c_tab_views LOOP
        l_tab_view_id := cd_tab_view.tab_view_id;
        l_tab_view_name := cd_tab_view.NAME;

        BSC_PMF_UI_WRAPPER.Check_Tabview_Dependency( p_tab_id           => p_tab_id
                                                    ,p_tab_view_id      => l_tab_view_id
                                                    ,p_list_dependency  => p_list_dependency
                                                    ,x_exist_dependency => l_exist_dependency
                                                    ,x_dep_obj_list     => l_temp_list
                                                    ,x_return_status    => x_return_status
                                                    ,x_msg_count        => l_msg_count
                                                    ,x_msg_data         => l_msg_data);

    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
          FND_MSG_PUB.Initialize;
          FND_MESSAGE.SET_NAME('BIS',l_msg_data);
          FND_MSG_PUB.ADD;
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (l_exist_dependency = FND_API.G_TRUE) THEN
      x_exist_dependency := l_exist_dependency;
      l_dep_obj_list := l_dep_obj_list || l_temp_list;
        END IF;

    EXIT WHEN (x_exist_dependency = FND_API.G_TRUE AND p_list_dependency = FND_API.G_FALSE);


    END LOOP;

    x_dep_obj_list := l_dep_obj_list;


 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (   p_encoded   =>  FND_API.G_FALSE
           ,p_count     =>  x_msg_count
           ,p_data      =>  x_msg_data
        );
      END IF;
      x_return_status :=  FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        ( p_encoded   =>  FND_API.G_FALSE
         ,p_count     =>  x_msg_count
         ,p_data      =>  x_msg_data
         );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> Check_Tabviews';
     ELSE
        x_msg_data      :=  SQLERRM||' at Check_Tabviews';
     END IF;

 END Check_Tabviews;

PROCEDURE Check_Tabview_Dependency (
   p_tab_id              IN             NUMBER
  ,p_tab_view_id         IN             NUMBER
  ,p_list_dependency     IN             VARCHAR2
  ,x_exist_dependency    OUT NOCOPY     VARCHAR2
  ,x_dep_obj_list        OUT NOCOPY     VARCHAR2
  ,x_return_status       OUT NOCOPY     VARCHAR2
  ,x_msg_count           OUT NOCOPY     NUMBER
  ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
  l_param_search_string     FND_FORM_FUNCTIONS_VL.PARAMETERS%TYPE;
  l_portlet_type            VARCHAR2(20);
  l_temp_list               VARCHAR2(1000);
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_exist_dependency := FND_API.G_FALSE;
    l_portlet_type := 'CUSTOM_VIEW_PORTLET';
    l_param_search_string := '%pRequestType=C&%pTabId=' || p_tab_id || '&pViewId=' || p_tab_view_id;

    BIS_UTIL.Check_Object_Dependency(p_param_search_string => l_param_search_string
                                    ,p_obj_portlet_type    => l_portlet_type
                                    ,p_list_dependency     => p_list_dependency
                                    ,x_exist_dependency    => x_exist_dependency
                                    ,x_dep_obj_list        => x_dep_obj_list
                                    ,x_return_status       => x_return_status
                                    ,x_msg_count           => x_msg_count
                                    ,x_msg_data            => x_msg_data);
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
          FND_MSG_PUB.Initialize;
          FND_MESSAGE.SET_NAME('BIS',x_msg_data);
          FND_MSG_PUB.ADD;
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (   p_encoded   =>  FND_API.G_FALSE
           ,p_count     =>  x_msg_count
           ,p_data      =>  x_msg_data
        );
      END IF;
      x_return_status :=  FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        ( p_encoded   =>  FND_API.G_FALSE
         ,p_count     =>  x_msg_count
         ,p_data      =>  x_msg_data
         );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> Check_Tabview_Dependency';
     ELSE
        x_msg_data      :=  SQLERRM||' at Check_Tabview_Dependency';
     END IF;
END Check_Tabview_Dependency;

 --/////////////////Added for TGSS Enahcnement ///////////////////////////////////

 PROCEDURE  Add_Or_Update_Tab_Logo
 (
   p_tab_id            IN NUMBER
  ,p_image_id          IN NUMBER
  ,p_file_name         IN VARCHAR2
  ,p_description       IN VARCHAR2
  ,p_width             IN NUMBER
  ,p_height            IN NUMBER
  ,p_mime_type         IN VARCHAR2
  ,x_image_id          OUT NOCOPY NUMBER
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
l_count            NUMBER;
l_next_image_id    BSC_SYS_IMAGES.image_id%TYPE;
BEGIN
  SAVEPOINT AddOrUpdateTabLogo;
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  SELECT COUNT(0)
  INTO   l_count
  FROM bsc_sys_images bsi,
       bsc_sys_images_map_vl bsim
  WHERE bsim.source_type =BSC_PMF_UI_WRAPPER.C_SCORECARD_LOGO_TYPE
  AND   bsim.source_code = p_tab_id
  AND   bsim.type = BSC_PMF_UI_WRAPPER.C_SCORECARD_LOGO_TYPE
  AND   bsim.image_id = p_image_id
  AND   bsim.image_id = bsi.image_id;


  IF (l_count > 0) THEN
      --check if the image is owned by current NLS session

      SELECT COUNT(0)
      INTO   l_count
      FROM   bsc_sys_images_map_TL
      WHERE  source_type =BSC_PMF_UI_WRAPPER.C_SCORECARD_LOGO_TYPE
      AND    source_code = p_tab_id
      AND    type = BSC_PMF_UI_WRAPPER.C_SCORECARD_LOGO_TYPE
      AND    image_id = p_image_id
      AND    source_lang = USERENV('LANG');

      IF (l_count > 0) THEN
        --image owned by this NLS session, just simply update the same image
        x_image_id := p_image_id;

        BEGIN
          UPDATE  BSC_SYS_IMAGES
          SET     FILE_NAME              =   p_file_name,
                  DESCRIPTION            =   p_description,
                  WIDTH                  =   p_width,
                  HEIGHT                 =   p_height,
                  MIME_TYPE              =   p_mime_type,
                  LAST_UPDATE_DATE       =   SYSDATE,
                  LAST_UPDATED_BY        =   fnd_global.user_id,
                  LAST_UPDATE_LOGIN      =   fnd_global.login_id,
                  FILE_BODY              =   EMPTY_BLOB()
          WHERE   IMAGE_ID               =   p_image_id;
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK TO AddOrUpdateTabLogo;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_data := 'Update to BSC_SYS_IMAGES failed' || SQLERRM;
            RETURN;
        END;

        BSC_SYS_IMAGES_MAP_PKG.UPDATE_ROW
        (
           X_SOURCE_TYPE       => BSC_PMF_UI_WRAPPER.C_SCORECARD_LOGO_TYPE
          ,X_SOURCE_CODE       => p_tab_id
          ,X_TYPE              => BSC_PMF_UI_WRAPPER.C_SCORECARD_LOGO_TYPE
          ,X_IMAGE_ID          => p_image_id
          ,X_CREATION_DATE     => SYSDATE
          ,X_CREATED_BY        => fnd_global.user_id
          ,X_LAST_UPDATE_DATE  => SYSDATE
          ,X_LAST_UPDATED_BY   => fnd_global.user_id
          ,X_LAST_UPDATE_LOGIN => fnd_global.login_id
        );

      ELSE
        --image not owned by this NLS session, need to create a new image and update the image map
        SELECT BSC_SYS_IMAGE_ID_S.NEXTVAL
        INTO   l_next_image_id
        FROM   dual;

        x_image_id := l_next_image_id;

        BEGIN
          BSC_SYS_IMAGES_PKG.INSERT_ROW
          (
             X_IMAGE_ID           => l_next_image_id
            ,X_FILE_NAME          => p_file_name
            ,X_DESCRIPTION        => p_description
            ,X_WIDTH              => p_width
            ,X_HEIGHT             => p_height
            ,X_MIME_TYPE          => p_mime_type
            ,X_CREATED_BY         => fnd_global.user_id
            ,X_LAST_UPDATED_BY    => fnd_global.user_id
            ,X_LAST_UPDATE_LOGIN  => fnd_global.login_id
          );

        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK TO AddOrUpdateTabLogo;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_data := 'Insertion to BSC_SYS_IMAGES_PKG failed' || SQLERRM;
            RETURN;
        END;

        BSC_SYS_IMAGES_MAP_PKG.UPDATE_ROW
        (
           X_SOURCE_TYPE       => BSC_PMF_UI_WRAPPER.C_SCORECARD_LOGO_TYPE
          ,X_SOURCE_CODE       => p_tab_id
          ,X_TYPE              => BSC_PMF_UI_WRAPPER.C_SCORECARD_LOGO_TYPE
          ,X_IMAGE_ID          => p_image_id
          ,X_CREATION_DATE     => SYSDATE
          ,X_CREATED_BY        => fnd_global.user_id
          ,X_LAST_UPDATE_DATE  => SYSDATE
          ,X_LAST_UPDATED_BY   => fnd_global.user_id
          ,X_LAST_UPDATE_LOGIN => fnd_global.login_id
        );
        END IF;
  ELSE
      --create a new image for this Simulation Tree Objective
      Create_Scorecard_logo (
        p_obj_id            => p_tab_id
       ,p_file_name         => p_file_name
       ,p_description       => p_description
       ,p_width             => p_width
       ,p_height            => p_height
       ,p_mime_type         => p_mime_type
       ,x_image_id          => x_image_id
       ,x_return_status     => x_return_status
       ,x_msg_count         => x_msg_count
       ,x_msg_data          => x_msg_data
      );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO AddOrUpdateTabLogo;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data      :=  SQLERRM;
 END Add_Or_Update_Tab_Logo;


 --/////////////////Added for TGSS Enahcnement ///////////////////////////////////


 PROCEDURE Create_Scorecard_logo (
   p_obj_id            IN NUMBER
  ,p_file_name         IN VARCHAR2
  ,p_description       IN VARCHAR2
  ,p_width             IN NUMBER
  ,p_height            IN NUMBER
  ,p_mime_type         IN VARCHAR2
  ,x_image_id          OUT NOCOPY NUMBER
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
 ) IS
  l_next_image_id      NUMBER;
  l_str                VARCHAR2(100);
 BEGIN

   SAVEPOINT CreateScorecardlogo;
   FND_MSG_PUB.INITIALIZE;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT BSC_SYS_IMAGE_ID_S.NEXTVAL
   INTO   l_next_image_id
   FROM   dual;

   x_image_id := l_next_image_id;

   BEGIN
     BSC_SYS_IMAGES_PKG.INSERT_ROW
     (
        X_IMAGE_ID         => l_next_image_id
       ,X_FILE_NAME        => p_file_name
       ,X_DESCRIPTION      => p_description
       ,X_WIDTH            => p_width
       ,X_HEIGHT           => p_height
       ,X_MIME_TYPE        => p_mime_type
       ,X_CREATED_BY       => fnd_global.user_id
       ,X_LAST_UPDATED_BY  => fnd_global.user_id
       ,X_LAST_UPDATE_LOGIN=> fnd_global.login_id
     );

   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_data := 'Insertion to BSC_SYS_IMAGES_PKG failed' || SQLERRM;
       RAISE;
   END;

   BSC_SYS_IMAGES_MAP_PKG.INSERT_ROW
   (
      X_ROWID              => l_str
     ,X_SOURCE_TYPE        => BSC_PMF_UI_WRAPPER.C_SCORECARD_LOGO_TYPE
     ,X_SOURCE_CODE        => p_obj_id
     ,X_TYPE               => BSC_PMF_UI_WRAPPER.C_SCORECARD_LOGO_TYPE
     ,X_IMAGE_ID           => l_next_image_id
     ,X_CREATION_DATE      => SYSDATE
     ,X_CREATED_BY         => fnd_global.user_id
     ,X_LAST_UPDATE_DATE   => SYSDATE
     ,X_LAST_UPDATED_BY    => fnd_global.user_id
     ,X_LAST_UPDATE_LOGIN  => fnd_global.login_id
   );
 EXCEPTION
   WHEN others THEN
     ROLLBACK TO CreateScorecardlogo;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      :=  SQLERRM;
     RAISE;
 END Create_Scorecard_logo;


 --/////////////////Added for TGSS Enahcnement ///////////////////////////////////


 PROCEDURE Delete_Tab_Logo
 (
     p_tab_id            IN         BSC_TABS_B.tab_id%TYPE
    ,x_return_status     OUT NOCOPY VARCHAR2
    ,x_msg_count         OUT NOCOPY NUMBER
    ,x_msg_data          OUT NOCOPY VARCHAR2
 )IS
  CURSOR c_tab_logo IS
  SELECT image_id
  FROM   bsc_sys_images_map_tl
  WHERE  source_type = BSC_PMF_UI_WRAPPER.C_SCORECARD_LOGO_TYPE
  AND    source_code = p_tab_id;

  l_image_id  BSC_SYS_IMAGES_MAP_TL.image_id%TYPE;

 BEGIN
   SAVEPOINT DeleteTabLogo;
   FND_MSG_PUB.INITIALIZE;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF(p_tab_id IS NOT NULL) THEN
       FOR cd IN  c_tab_logo LOOP
         l_image_id := cd.image_id;
       END LOOP;
       DELETE FROM bsc_sys_images_map_tl
       WHERE  image_id =l_image_id;

       DELETE FROM bsc_sys_images
       WHERE  image_id =l_image_id;
   END IF;

 EXCEPTION
   WHEN others THEN
     ROLLBACK TO DeleteTabLogo;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      :=  SQLERRM;
     RAISE;
 END  Delete_Tab_Logo;



END BSC_PMF_UI_WRAPPER;

/
