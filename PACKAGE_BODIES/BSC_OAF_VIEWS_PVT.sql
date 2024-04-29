--------------------------------------------------------
--  DDL for Package Body BSC_OAF_VIEWS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_OAF_VIEWS_PVT" AS
/* $Header: BSCOAFVB.pls 120.2 2007/02/08 13:20:08 ppandey ship $ */
/*===========================================================================+
|
|   Name:          GET_AOPTS_SERIES_NAMES
|
|   Description:   Return a string with the all the Analysis option names in this format:
|                      A0_Name,A1_Name,A2_Name;Series Name
|
|   Parameters:
+============================================================================*/
/*===========================================================================+
|               Copyright (c) 1999 Oracle Corporation                        |
|                  Redwood Shores, California, USA                           |
|                       All rights reserved                                  |
|============================================================================|
|
|   Name:          BSCOAFVB.pls
|
|   Description:   Package to support OA framework Views
|
|
|   Dependencies:
|
|   Example:
|
|   Security:
|
|   History:       Created By: Henry Camacho        Date: 30-NOV-01
|                  Bug #2660714 Pankaj                    14-NOV-02
|                  Bug #2663355 Ashankar                  30-DEC-02
|                  Bug #2943217 PWALI                     15-MAY-03
|   31-JUL-2003    mahrao  Increased the size of v_name in GET_LEVEL_PARENT_NAMES
|                          for bug# 3030788
|   16-NOV-2006    ankgoel Color By KPI enh#5244136
|   28-DEC-2006    ppandey For simulation display series name, enh#5386112
+============================================================================*/


FUNCTION GET_AOPTS_SERIES_NAMES(X_INDICATOR in NUMBER,
      X_A0 in NUMBER,
      X_A1 in NUMBER,
      X_A2 in NUMBER,
      X_SERIES_ID in NUMBER
) RETURN VARCHAR2 IS

    h_ag_count NUMBER;
    h_ag1_depend NUMBER;
    h_ag2_depend NUMBER;
    h_val VARCHAR2(350);
    h_a0_name BSC_KPI_ANALYSIS_OPTIONS_tl.Name%TYPE;
    h_a1_name BSC_KPI_ANALYSIS_OPTIONS_tl.Name%TYPE;
    h_a2_name BSC_KPI_ANALYSIS_OPTIONS_tl.Name%TYPE;
    h_series_name BSC_KPI_ANALYSIS_MEASURES_TL.Name%TYPE;
    h_series_count NUMBER;

    l_al_count NUMBER;               --added to solve the bug 2663355

    h_err NUMBER;
    CURSOR c_kpi IS
    SELECT INDICATOR_TYPE,CONFIG_TYPE
    FROM BSC_KPIS_B
    WHERE INDICATOR=X_INDICATOR;

   h_kpi_type NUMBER;
   h_kpi_config NUMBER;

BEGIN
    h_err := 0;
    -- Number of Analysis Groups
    SELECT MAX( ANALYSIS_GROUP_ID)
    INTO h_ag_count
    FROM BSC_KPI_ANALYSIS_GROUPS
    WHERE INDICATOR=X_INDICATOR;


    h_err := 1;
    l_al_count := 0;
    -- Get Name for A0
    SELECT NAME
    INTO h_a0_name
    FROM BSC_KPI_ANALYSIS_OPTIONS_VL
    WHERE ANALYSIS_GROUP_ID =0 AND
    OPTION_ID=X_A0 AND
    INDICATOR=X_INDICATOR;


    -- Get Name for A1
    IF h_ag_count >= 1 THEN
        h_err := 2;

        --h_ag_depend
        SELECT DEPENDENCY_FLAG
        INTO h_ag1_depend
        FROM BSC_KPI_ANALYSIS_GROUPS
        WHERE ANALYSIS_GROUP_ID =1 AND
        INDICATOR=X_INDICATOR;



                -- If depend it
        IF h_ag1_depend = 0 THEN
            h_err := 3;
            SELECT NAME
            INTO h_a1_name
            FROM BSC_KPI_ANALYSIS_OPTIONS_VL
            WHERE ANALYSIS_GROUP_ID =1 AND
            OPTION_ID=X_A1 AND
            INDICATOR=X_INDICATOR;
                ELSE
            h_err := 4;
            BEGIN
                SELECT NAME
                INTO h_a1_name
                FROM BSC_KPI_ANALYSIS_OPTIONS_VL
                WHERE ANALYSIS_GROUP_ID =1 AND
                OPTION_ID=X_A1 AND
                PARENT_OPTION_ID = X_A0 AND
                INDICATOR=X_INDICATOR;

                ---Added to fix the bug 2663355 ----
                SELECT COUNT(*)
                INTO l_al_count
                FROM BSC_KPI_ANALYSIS_OPTIONS_VL
                WHERE ANALYSIS_GROUP_ID =1 AND
                PARENT_OPTION_ID = X_A0 AND
                INDICATOR =X_INDICATOR;
                ------------------------------------


                        --Validation if there is not record
            EXCEPTION WHEN OTHERS THEN NULL; END;
        END IF;
    END IF;
    h_err := 5;
    -- Concat A0 and A1
        h_val :=  h_a0_name ;

        IF h_a1_name IS NOT NULL THEN


      IF l_al_count >1 or l_al_count =0 THEN                     -- condition aded to fix the bug 2663355

             h_val := h_val || ',' || h_a1_name;
         l_al_count := 0;
      ELSE

         h_val := h_val;
      END IF;
       END IF;





    -- Get Name for A2
    IF h_ag_count >= 2 THEN
        h_err := 6;
        --h_ag_depend
        SELECT DEPENDENCY_FLAG
        INTO h_ag2_depend
        FROM BSC_KPI_ANALYSIS_GROUPS
        WHERE ANALYSIS_GROUP_ID =2 AND
        INDICATOR=X_INDICATOR;
                -- If depend it
        IF h_ag2_depend = 0 THEN
            h_err := 7;
            SELECT NAME
            INTO h_a2_name
            FROM BSC_KPI_ANALYSIS_OPTIONS_VL
            WHERE ANALYSIS_GROUP_ID =2 AND
            OPTION_ID=X_A2 AND
            INDICATOR=X_INDICATOR;
                ELSE
                     -- The AG2 is dependent, but AG1 is not
             h_err := 8;
             IF h_ag2_depend = 1 AND h_ag1_depend = 0 THEN
            h_err := 9;
            BEGIN
                SELECT NAME
                INTO h_a2_name
                FROM BSC_KPI_ANALYSIS_OPTIONS_VL
                WHERE ANALYSIS_GROUP_ID =2 AND
                OPTION_ID=X_A2 AND
                PARENT_OPTION_ID = X_A1 AND
                INDICATOR=X_INDICATOR;


                ---Added to fix the bug 2663355 ----
                SELECT COUNT(*)
                INTO l_al_count
                FROM BSC_KPI_ANALYSIS_OPTIONS_VL
                WHERE ANALYSIS_GROUP_ID =2 AND
                PARENT_OPTION_ID = X_A1 AND
                INDICATOR =X_INDICATOR;
                ------------------------------------


                        --Validation if there is not record
            EXCEPTION WHEN OTHERS THEN NULL; END;
                    ELSE
            h_err := 10;
            BEGIN
                SELECT NAME
                INTO h_a2_name
                FROM BSC_KPI_ANALYSIS_OPTIONS_VL
                WHERE ANALYSIS_GROUP_ID =2 AND
                OPTION_ID=X_A2 AND
                PARENT_OPTION_ID = X_A1 AND
                GRANDPARENT_OPTION_ID = X_A0 AND
                INDICATOR=X_INDICATOR;

                -- Added to fix the bug 2663355 ----------
                SELECT COUNT(*)
                INTO l_al_count
                FROM BSC_KPI_ANALYSIS_OPTIONS_VL
                WHERE ANALYSIS_GROUP_ID =2 AND
                PARENT_OPTION_ID = X_A1 AND
                GRANDPARENT_OPTION_ID = X_A0 AND
                INDICATOR =X_INDICATOR;
                ------------------------------------------


                        --Validation if there is not record
            EXCEPTION WHEN OTHERS THEN NULL; END;
                    END IF;
        END IF;
    END IF;
    h_err := 11;
    -- Concat A1 and A2

    IF h_a2_name IS NOT NULL THEN

    IF l_al_count > 1 or l_al_count =0  THEN               -- added condition to fix the bug 2663355.
       h_val := h_val || ',' || h_a2_name;
       l_al_count := 0;
    END IF;

        END IF;


    -- Get Series Name
    OPEN c_kpi;
    FETCH c_kpi INTO h_kpi_type,h_kpi_config;
    IF (c_kpi%notfound) THEN
        h_kpi_type := 1;
        h_kpi_config := 1;
    END IF;
    CLOSE c_kpi;
        --Multiple series
    IF (h_kpi_type = 10 AND h_kpi_config = 1)
        OR (h_kpi_type = 1 AND h_kpi_config = 7) THEN
        BEGIN
            SELECT COUNT(*) VAL
            INTO h_series_count
            FROM BSC_KPI_ANALYSIS_MEASURES_VL
            WHERE  ANALYSIS_OPTION0 =X_A0 AND
            ANALYSIS_OPTION1 =X_A1 AND
            ANALYSIS_OPTION2 =X_A2 AND
            INDICATOR=X_INDICATOR;
            IF h_series_count >1 THEN
                SELECT NAME
                INTO h_series_name
                FROM BSC_KPI_ANALYSIS_MEASURES_VL
                WHERE  ANALYSIS_OPTION0 =X_A0 AND
                ANALYSIS_OPTION1 =X_A1 AND
                ANALYSIS_OPTION2 =X_A2 AND
                SERIES_ID = X_SERIES_ID AND
                INDICATOR=X_INDICATOR;
            ELSE
                h_series_name := '';
            END IF;
        --Validation if there is not record
        EXCEPTION WHEN OTHERS THEN NULL; END;
        -- Concat series name
        IF (h_kpi_type = 1 AND h_kpi_config = 7 AND h_series_name IS NOT NULL) THEN
          h_val := h_series_name;
        ELSIF h_series_name IS NOT NULL THEN
            h_val := h_val || ';' || h_series_name;
        END IF;
    END IF;


        RETURN h_val;
EXCEPTION
    WHEN OTHERS THEN
    h_val := h_val || '/' || h_err || '/' || SQLERRM;
        RETURN h_val;
END GET_AOPTS_SERIES_NAMES;

/* ===========================================================
 | Description : Return the Alarm Color for Kpi measure.
 |       This color is showed buy Ibuilder
 |
 |Psuedo logic
 |        If DefaultMeasure  = "BSC"  Then
 |      Color = KPI Color    -> BSC_DESIGNER_PVT.GET_KPI_COLOR
 |        Elseif Measure is BSC and not DEFault THEN
 |      Color = No Color 'WHITE'
 |        Elseif Measure is PMF and kpi <> PRODUCTION THEN
 |      Color = KPI Color    -> BSC_DESIGNER_PVT.GET_KPI_COLOR
 |        Elseif Measure is PMF and kpi = PRODUCTION THEN
 |      Color = No Color 'WHITE'
 |  end if;
 ===========================================================*/
/*FUNCTION GET_MEASURE_COLOR(X_INDICATOR in NUMBER,
      X_A0 in NUMBER,
      X_A1 in NUMBER,
      X_A2 in NUMBER,
      X_SERIES_ID in NUMBER
    ) RETURN VARCHAR2 is

h_kpi_prototype  VARCHAR2(10);
h_kpi_measure_source    bsc_kpi_defaults_b.measure_source%TYPE;
h_measure_source    BSC_SYS_DATASETS_B.source%type;
h_color         bsc_kpis_b.prototype_color%TYPE;
h_RED       bsc_kpis_b.prototype_color%TYPE;
h_GREEN     bsc_kpis_b.prototype_color%TYPE;
h_YELLOW    bsc_kpis_b.prototype_color%TYPE;
h_GRAY      bsc_kpis_b.prototype_color%TYPE;
h_LIGHTGRAY     bsc_kpis_b.prototype_color%TYPE;
h_WHITE     bsc_kpis_b.prototype_color%TYPE;

d_A0  NUMBER;
d_A1  NUMBER;
d_A2  NUMBER;
d_SERIES_ID  NUMBER;
h_com_default NUMBER(1);

BEGIN
    h_RED :='R';
    h_GREEN  :='G';
    h_YELLOW :='Y';
    h_GRAY :='X';
    h_LIGHTGRAY :='L';
    h_WHITE :='W';

    --Get Defaults
    SELECT DISTINCT DF.A0_DEFAULT,DF.A1_DEFAULT,DF.A2_DEFAULT,MS.SERIES_ID
    INTO d_A0,d_A1,d_A2,d_SERIES_ID
    FROM BSC_DB_COLOR_AO_DEFAULTS_V DF,
         BSC_KPI_ANALYSIS_MEASURES_B MS
    WHERE
    DEFAULT_VALUE =1 AND
    DF.INDICATOR = MS.INDICATOR AND
    DF.A0_DEFAULT = MS.ANALYSIS_OPTION0 AND
    DF.A1_DEFAULT = MS.ANALYSIS_OPTION1 AND
    DF.A2_DEFAULT = MS.ANALYSIS_OPTION2 AND
    DF.INDICATOR =X_INDICATOR;

    h_com_default :=0;
    IF X_A0 = d_A0 AND X_A1 = d_A1 AND X_A2 = d_A2 AND X_SERIES_ID = d_SERIES_ID THEN
        h_com_default := 1;
    END IF;

    --Get if the measure is BSC or PMF
    --Bug #2660714
    SELECT NVL(DS.SOURCE,'BSC') VAL
    INTO h_measure_source
    FROM  BSC_KPI_ANALYSIS_MEASURES_B MS,
    BSC_SYS_DATASETS_B DS
    WHERE
    ANALYSIS_OPTION0 =X_A0 AND
    ANALYSIS_OPTION1 =X_A1 AND
    ANALYSIS_OPTION2 =X_A2 AND
    SERIES_ID = X_SERIES_ID AND
    MS.DATASET_ID = DS.DATASET_ID AND
    MS.INDICATOR =X_INDICATOR;

    --Get if prototype for pmf
    SELECT DECODE(PROTOTYPE_FLAG,
            0,'FALSE',
            5,'FALSE',
            6,'FALSE',
              'TRUE') PROTOTYPE
    INTO h_kpi_prototype
    FROM BSC_KPIS_B
    WHERE INDICATOR =X_INDICATOR;
    -- Calculate the Color
        IF h_measure_source ='BSC' THEN
        IF h_com_default = 1  THEN
            h_color := BSC_DESIGNER_PVT.GET_KPI_COLOR(X_INDICATOR);
        ELSE
            h_color := h_WHITE;
        END IF;
    ELSE
        IF h_kpi_prototype = 'TRUE' THEN
            h_color := BSC_DESIGNER_PVT.GET_KPI_COLOR(X_INDICATOR);
        ELSE
            h_color := h_WHITE;
        END IF;
    END IF;
RETURN h_color;

EXCEPTION
    WHEN OTHERS THEN
    RETURN h_WHITE;
end GET_MEASURE_COLOR;*/


function Get_Aopts_Display_Flag(
  x_indicator   IN  number
 ,x_a0      IN  number
 ,x_a1      IN  number
 ,x_a2      IN  number
 ,x_series_id   IN  number
) return number is

--  This function returns the flag value for the analysis option in a multi analysis
--  group Indicator.  If it encounters a value of 0 (hide) for the flag at any level
--  then it returns this zero immediately (there is no need to keep checking for other
--  values in the same combination since the zero will hide the entire combination),
--  else it returns either 1 (default) or 2 (non-default).

cursor c_kpi is
  select indicator_type,config_type
    from BSC_KPIS_B
   where indicator = x_indicator;

h_ag_count              number;
h_ag1_depend            number;
h_ag2_depend            number;
h_series_count      number;
h_err           number;
l_disp_flag0        number;
l_def_flag0     number;
l_disp_flag1        number;
l_def_flag1     number;
l_disp_flag2        number;
l_def_flag2     number;
l_disp_flag_show    number;
l_simul_tree        number;
l_def_opt_count     number;

begin

  h_err := 0;
  -- Number of Analysis Groups
  select max(analysis_group_id)
    into h_ag_count
    from BSC_KPI_ANALYSIS_GROUPS
   where indicator = x_indicator;

  h_err := 1;

  -- Get option id default value for Analysis Group 0.
  select default_value
    into l_def_flag0
    from BSC_KPI_ANALYSIS_GROUPS
   where indicator = x_indicator
     and analysis_group_id = 0;

  -- Get Name for A0
  select user_level1
    into l_disp_flag0
    from BSC_KPI_ANALYSIS_OPTIONS_VL
   where analysis_group_id = 0
     and option_id = x_a0
     and indicator = x_indicator;

  -- if 0 then return value immediately.
  if l_disp_flag0 = 0 then
    return l_disp_flag0;
  end if;

  -- Get Name for A1
  if h_ag_count >= 1 then -- if for A1

    h_err := 2;

    -- Get dependency flag and option id default value for Analysis group 1.
    select dependency_flag, default_value
      into h_ag1_depend, l_def_flag1
      from BSC_KPI_ANALYSIS_GROUPS
     where analysis_group_id = 1
       and indicator = x_indicator;

    -- If depend it
    if h_ag1_depend = 0 then

      h_err := 3;
      select user_level1
        into l_disp_flag1
        from BSC_KPI_ANALYSIS_OPTIONS_VL
       where analysis_group_id = 1
         and option_id = x_a1
         and indicator = x_indicator;

      -- if 0 then return value immediately.
      if l_disp_flag1 = 0 then
        return l_disp_flag1;
      end if;

    else

      h_err := 4;
      begin

        select user_level1
          into l_disp_flag1
          from BSC_KPI_ANALYSIS_OPTIONS_VL
     where analysis_group_id = 1
           and option_id = x_a1
           and parent_option_id = x_a0
           and indicator = x_indicator;


        -- if 0 then return value immediately.
        if l_disp_flag1 = 0 then
          return l_disp_flag1;
        end if;


      --Validation if there is no record
      EXCEPTION
        WHEN OTHERS THEN
          null;
      end;

    end if;

  end if;  -- end if for A1.



  -- Get Name for A2
  if h_ag_count >= 2 then

    h_err := 6;
    -- Get dependency flag and option id default value for Analysis group 2.
    select dependency_flag, default_value
      into h_ag2_depend, l_def_flag2
      from BSC_KPI_ANALYSIS_GROUPS
     where analysis_group_id = 2
       and indicator = x_indicator;

    -- If dependent
    if h_ag2_depend = 0 then

      h_err := 7;
      select user_level1
      into l_disp_flag2
      from BSC_KPI_ANALYSIS_OPTIONS_VL
      where analysis_group_id = 2
      and option_id = x_a2
      and indicator = x_indicator;

      if l_disp_flag2 = 0 then
        return l_disp_flag2;
      end if;

    else

      -- The AG2 is dependent, but AG1 is not
      h_err := 8;
      if h_ag2_depend = 1 and h_ag1_depend = 0 then

        h_err := 9;
    begin
      select user_level1
        into l_disp_flag2
        from BSC_KPI_ANALYSIS_OPTIONS_VL
       where analysis_group_id = 2
             and option_id = x_a2
             and parent_option_id = x_a1
             and indicator=x_indicator;

          if l_disp_flag2 = 0 then
            return l_disp_flag2;
          end if;

        --Validation if there is not record
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        end;

      else

    h_err := 10;
    begin

      select user_level1
        into l_disp_flag2
        from BSC_KPI_ANALYSIS_OPTIONS_VL
       where analysis_group_id = 2
             and option_id = x_a2
             and parent_option_id = x_a1
             and grandparent_option_id = x_a0
             and indicator = x_indicator;

          if l_disp_flag2 = 0 then
            return l_disp_flag2;
          end if;

        --Validation if there is no record
    EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

      end if;

    end if;

  end if;

  -- determine if this is a simulation tree indicator.
  select count(indicator)
    into l_simul_tree
    from BSC_KPIS_B
   where indicator = x_indicator
     and indicator_type = 1
     and config_type = 7;

  -- Determine value to return.
  -- First check if this is a simulation tree Indicator.
  if l_simul_tree <> 0 then
    select count(a.option_id)
      into l_def_opt_count
      from BSC_KPI_ANALYSIS_OPTIONS_B a,
           BSC_KPI_ANALYSIS_GROUPS b
     where a.indicator = x_indicator
       and a.indicator = b.indicator
       and a.analysis_group_id = b.analysis_group_id
       and a.option_id = b.default_value
       and a.user_level1 = 1;
    if l_def_opt_count > 0 then
      return 1;
    else
      return 0;
    end if;
  elsif h_ag_count < 1 then
    if x_a0 = l_def_flag0 then
      return 1;
    else
      return 2;
    end if;
  elsif h_ag_count < 2 then
    if x_a0 = l_def_flag0 and x_a1 = l_def_flag1 then
      return 1;
    else
      return 2;
    end if;
  else
    if x_a0 = l_def_flag0 and x_a1 = l_def_flag1 and x_a2 = l_def_flag2 then
      return 1;
    else
      return 2;
    end if;
  end if;


EXCEPTION
    WHEN OTHERS THEN
        return 0;
end Get_Aopts_Display_Flag;

/* ===========================================================
 | Description : Return the parent level names of a given level
 |       in a string
 |
 |Psuedo logic
 ===========================================================*/
FUNCTION  GET_LEVEL_PARENT_NAMES(p_level_id IN NUMBER
    ) RETURN VARCHAR2 IS
  CURSOR c_parents IS
    SELECT PL.NAME
     FROM BSC_SYS_DIM_LEVEL_RELS LR,
              BSC_SYS_DIM_LEVELS_VL PL
     WHERE LR.DIM_LEVEL_ID = p_level_id
               AND PL.DIM_LEVEL_ID = PARENT_DIM_LEVEL_ID;
  v_name BSC_SYS_DIM_LEVELS_TL.NAME%TYPE;
  v_parents VARCHAR2(3000) := '';
  v_count INTEGER := 0;
BEGIN
  OPEN c_parents;
  LOOP
    FETCH c_parents INTO v_name;
    EXIT WHEN c_parents%NOTFOUND;
    IF v_count > 0 THEN
        v_parents := v_parents || ', ';
    END IF;
    v_parents := v_parents || v_name;
    v_count := v_count + 1;
  END LOOP;
  CLOSE c_parents;
  RETURN v_parents;
 EXCEPTION
  WHEN OTHERS THEN
    RETURN v_parents;
END GET_LEVEL_PARENT_NAMES;


/* ===========================================================
 | Description :
 |  This function returns the flag value that identify the default
 |      Analsyis option combination for the kpi.
 |
 ===========================================================*/
FUNCTION GET_AOPTS_DEFAULT_FLAG(
  x_indicator   IN  number
 ,x_a0      IN  number
 ,x_a1      IN  number
 ,x_a2      IN  number
 ,x_series_id   IN  number
) return number is

d_A0  NUMBER;
d_A1  NUMBER;
d_A2  NUMBER;
d_SERIES_ID  NUMBER;
h_com_default NUMBER(1);

BEGIN
    --Get Defaults
    SELECT DISTINCT DF.A0_DEFAULT,DF.A1_DEFAULT,DF.A2_DEFAULT,MS.SERIES_ID
    INTO d_A0,d_A1,d_A2,d_SERIES_ID
    FROM BSC_DB_COLOR_AO_DEFAULTS_V DF,
         BSC_KPI_ANALYSIS_MEASURES_B MS
    WHERE
    DEFAULT_VALUE =1 AND
    DF.INDICATOR = MS.INDICATOR AND
    DF.A0_DEFAULT = MS.ANALYSIS_OPTION0 AND
    DF.A1_DEFAULT = MS.ANALYSIS_OPTION1 AND
    DF.A2_DEFAULT = MS.ANALYSIS_OPTION2 AND
    DF.INDICATOR =X_INDICATOR;

    h_com_default :=0;
    IF X_A0 = d_A0 AND X_A1 = d_A1 AND X_A2 = d_A2 AND X_SERIES_ID = d_SERIES_ID THEN
        h_com_default := 1;
    END IF;
    RETURN h_com_default;

EXCEPTION
    WHEN OTHERS THEN
        return 0;
end GET_AOPTS_DEFAULT_FLAG;

function Is_Parent_Tab(
  p_tab_id      number
) return varchar2 is

l_count         number;

begin
  SELECT COUNT(*) INTO l_Count
  FROM   BSC_TABS_VL
  WHERE  Parent_Tab_Id = p_tab_id;


  IF (l_Count > 1) THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;
EXCEPTION
    WHEN OTHERS THEN
        return 'N';

end Is_Parent_Tab;


/*===========================================================================+
|
|   Name:          GET_DATASET_SOURCE
|
|   Description:   Return if the dataset_id is BSC OR PMV
|   Return :       'BSC' : BSC measure
|                  'PMF' : PMF measure
|   Parameters:    X_DATASET_ID     Menu Id that will be inserted
+============================================================================*/
FUNCTION  GET_DATASET_SOURCE(X_DATASET_ID in NUMBER
    ) RETURN VARCHAR2 IS

l_tmp VARCHAR2(10);
begin
     IF h_dataset = X_DATASET_ID THEN
    l_tmp := h_source;
     ELSE
         l_tmp := 'BSC';
         SELECT NVL(SOURCE,'BSC') SOURCE
         into l_tmp
         FROM BSC_SYS_DATASETS_B
         WHERE
         DATASET_ID = X_DATASET_ID;

    h_dataset := X_DATASET_ID;
        h_source := l_tmp;
     END IF;
     return l_tmp;

EXCEPTION
    WHEN OTHERS THEN
        return l_tmp;
end GET_DATASET_SOURCE;

END BSC_OAF_VIEWS_PVT;


/
