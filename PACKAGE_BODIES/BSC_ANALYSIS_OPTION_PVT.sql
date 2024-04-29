--------------------------------------------------------
--  DDL for Package Body BSC_ANALYSIS_OPTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_ANALYSIS_OPTION_PVT" as
/* $Header: BSCVANOB.pls 120.7 2007/04/13 13:07:14 ppandey ship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCVANOB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 10, 2001                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 |          Private Body version.                                                       |
 |          This package creates a BSC Analysis Option.                                 |
 |                                                                                      |
 | History:                                                                             |
 |                      05-MAR-2003 ADEULGAO fixed MLS issue bug#2721899                |
 |                      changed BSC_KPI_ANALYSIS_OPTIONS_TL to                          |
 |                  BSC_KPI_ANALYSIS_OPTIONS_VL in select statement                     |
 |                      13-MAY-2003 PWALI  Bug #2942895, SQL BIND COMPLIANCE            |
 |                                                                                      |
 |          08-SEP-2003 kyadamak FIX THE BUG   3124010                                  |
 |          14-NOV-2003 PAJOHRI  Bug #3248729                                           |
 |          17-NOV-2003 wcano    Bug #3248729                                           |
 |          09-DEC-2003 PAJOHRI  Bug #3293895                                           |
 |                               Added new procedures Set_Default_Value &               |
 |                                                    Swap_Option_Id                    |
 |                               and modified the procedures Delete_Analysis_Measures   |
 |                                                           Delete_Analysis_Options    |
 |          23-DEC-2003 ashankar  Bug#3327016                                           |
 |                                Modified the procedure  Set_Default_Value             |
 |                                to update BSC_KPI_ANALYSIS_GROUPS                     |
 |          14-JUN-2004 adrao     Enh#3540302, added SHORT_NAME column to the Analysis  |
 |                                Options table. Tracked in Bug#3691035                 |
 |          02-jul-2004  rpenneru Modified for Enhancement#3532517                      |
 |          14-jul-2004  rpenneru Modified for bug#3746564                              |
 |          07-JAN-2005  ashankar Fix for the bug #4099597                              |
 |          20-APR-2005  adrao added API Cascade_Series_Default_Value                   |
 |          11-MAY-2005  adrao Removed incremental change during series cascading       |
 |          22-AUG-2005  ashankar Bug#4220400 added the method                          |
 |                       Set_Default_Analysis_Option                                    |
 |          11-APR-2006 visuri   Bug#5151997 Changes for Protoype Flag change during    |
 |                               update of PMF Measure in Objective                     |
 |          31-Jan-2007 akoduri   Enh #5679096 Migration of multibar functionality from |
 |                                VB to Html                                            |
 +======================================================================================+
*/
G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_ANALYSIS_OPTION_PVT';
g_db_object             varchar2(30) := null;


TYPE Swap_Ana_Opts_Type IS Record
(       p_AnaOpt_Prev_Id      NUMBER
    ,   p_AnaOpt_Next_Id      NUMBER
);
--==============================================================
TYPE Swap_Ana_Opts_Table IS TABLE OF Swap_Ana_Opts_Type INDEX BY BINARY_INTEGER;

/**************************************************************************************/
FUNCTION is_Parent_Exists
( p_kpi_Id NUMBER,
  p_Parent NUMBER,
  p_Group  NUMBER
) RETURN BOOLEAN IS
   l_Count  NUMBER;
BEGIN
    SELECT COUNT(*) INTO l_Count
    FROM   BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE  Parent_Option_Id     = p_Parent
    AND    Analysis_Group_Id    = p_Group
    AND    Indicator            = p_kpi_Id;
    IF (l_Count <> 0) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END is_Parent_Exists;
/*********************************************************************************/

FUNCTION is_not_Child
(p_kpi_Id NUMBER,
 p_Parent NUMBER,
 p_child  NUMBER,
 p_Group  NUMBER
) RETURN BOOLEAN
IS
 l_Count  NUMBER;
BEGIN
    SELECT COUNT(*) INTO l_Count
    FROM   BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE  Parent_Option_Id  = p_Parent
    AND    OPTION_ID         = p_child
    AND    Analysis_Group_Id = p_Group
    AND    Indicator         = p_kpi_Id;
    IF (l_Count = 0) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END is_not_Child;
/**************************************************************************************/
FUNCTION is_GrandParent_Exists
( p_kpi_Id      NUMBER,
  p_GrandParent NUMBER,
  p_Group       NUMBER
) RETURN BOOLEAN IS
   l_Count  NUMBER;
BEGIN
    SELECT COUNT(*) INTO l_Count
    FROM   BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE   GrandParent_Option_Id = p_GrandParent
    AND     Analysis_Group_Id = p_Group
    AND     Indicator =p_kpi_Id;
    IF (l_Count <> 0) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END is_GrandParent_Exists;
/***************************************************************************
  Name :-  get_number_of_child
  This fucntion will return the number of child for the parent.
/**************************************************************************/
FUNCTION get_number_of_child
(       p_Kpi_id            IN       NUMBER--BSC_KPIS_B.indicator%TYPE
  ,     p_group_count       IN       NUMBER
  ,     p_Anal_Opt_Tbl      IN       BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type
  ,     p_Anal_Opt_Comb_Tbl IN       BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
)RETURN NUMBER IS
     l_count        NUMBER;
BEGIN
    IF (p_Anal_Opt_Tbl(p_group_count + 1).Bsc_dependency_flag = 1) THEN
        IF((p_group_count = 1)AND(p_Anal_Opt_Tbl(p_group_count).Bsc_dependency_flag = 1))THEN
            SELECT COUNT(0)
            INTO   l_count
            FROM   BSC_KPI_ANALYSIS_OPTIONS_B
            WHERE  Indicator             = p_Kpi_id
            AND    Analysis_Group_Id     = p_group_count + 1
            AND    Parent_Option_Id      = p_Anal_Opt_Comb_Tbl(p_group_count)
            AND    Grandparent_Option_Id = p_Anal_Opt_Comb_Tbl(p_group_count - 1);
         ELSIF((p_group_count = 1)AND(p_Anal_Opt_Tbl(p_group_count).Bsc_dependency_flag = 0)) THEN
            SELECT COUNT(0)
            INTO   l_count
            FROM   BSC_KPI_ANALYSIS_OPTIONS_B
            WHERE  Indicator             = p_Kpi_id
            AND    Analysis_Group_Id     = p_group_count + 1
            AND    Parent_Option_Id      = p_Anal_Opt_Comb_Tbl(p_group_count);
         ELSE
            SELECT COUNT(0)
            INTO   l_count
            FROM   BSC_KPI_ANALYSIS_OPTIONS_B
            WHERE  Indicator = p_Kpi_id
            AND    Analysis_Group_Id = p_group_count + 1
            AND    Parent_Option_Id  = p_Anal_Opt_Comb_Tbl(p_group_count);
         END IF;
         RETURN l_count;
    ELSE
        RETURN 0;
    END IF;
 END  get_number_of_child;

/*******************************************************************************/
FUNCTION get_parent_level_id
(   p_Kpi_id          IN          BSC_KPIS_B.indicator%TYPE
  , p_Group_id        IN          BSC_KPI_ANALYSIS_OPTIONS_B.Analysis_Group_Id%TYPE
  , p_Option_id       IN          BSC_KPI_ANALYSIS_OPTIONS_B.Option_Id%TYPE
) RETURN NUMBER IS
    l_parent_option       BSC_KPI_ANALYSIS_OPTIONS_B.Parent_Option_Id%TYPE;
BEGIN
    SELECT PARENT_OPTION_ID
    INTO   l_parent_option
    FROM   BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE  Indicator         = p_Kpi_id
    AND    Analysis_Group_Id = p_Group_id
    AND    Option_Id         = p_Option_id;

    RETURN l_parent_option;
END get_parent_level_id;

/*******************************************************************************/
FUNCTION is_custom_kpi
(   p_Kpi_id          IN          BSC_KPIS_B.indicator%TYPE
  , p_Kpi_Name        OUT NOCOPY  BSC_KPIS_VL.NAME%TYPE
) RETURN BOOLEAN IS
    l_Kpi_ShortName    VARCHAR2(50);
    l_Kpi_Name         BSC_KPIS_VL.NAME%TYPE;

    CURSOR c_kpis IS
    SELECT name, short_name
    FROM BSC_KPIS_VL WHERE  Indicator = p_Kpi_id;
BEGIN
    IF (c_kpis%ISOPEN) THEN
      CLOSE c_kpis;
    END IF;

    OPEN c_kpis;
    FETCH c_kpis INTO l_Kpi_Name,l_Kpi_ShortName;
    CLOSE c_kpis;

    p_Kpi_Name := l_Kpi_Name;
    IF l_Kpi_ShortName IS NOT NULL THEN
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  EXCEPTION
    WHEN OTHERS THEN
        IF (c_kpis%ISOPEN) THEN
          CLOSE c_kpis;
        END IF;
        RETURN FALSE;
END is_custom_kpi;

/*******************************************************************************/
PROCEDURE Store_Anal_Opt_Grp_Count
(     p_kpi_id        IN            NUMBER
  ,   x_Anal_Opt_Tbl  IN OUT NOCOPY BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type
) IS
    l_count         NUMBER ;

    CURSOR c_anal_grp_opt_count IS
    SELECT analysis_group_id
         , COUNT(option_id) option_count
    FROM   BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE  indicator = p_Kpi_Id
    GROUP  BY analysis_group_id;
BEGIN
     l_count := 0;
     FOR cd IN c_anal_grp_opt_count LOOP
          x_Anal_Opt_Tbl(l_count).Bsc_analysis_group_id := cd.analysis_group_id;
          x_Anal_Opt_Tbl(l_count).Bsc_no_option_id      := cd.option_count;
          l_count := l_count +1;
     END LOOP;
END store_anal_opt_grp_count;

/*******************************************************************************/
PROCEDURE Set_Default_Value
(    p_Kpi_Id                  NUMBER
   , p_group_Id                NUMBER
   , p_parent_option_Id        NUMBER
   , p_grand_parent_option_Id  NUMBER
   , p_option_Id               NUMBER
) IS
    l_Dependency_Flag   NUMBER  := 0;
    l_User_Default      NUMBER  := 0;
    l_next_option       NUMBER  := 0;
    l_Default_Modified  BOOLEAN := FALSE;
    l_Default_Value     NUMBER  := 0;
    l_count             NUMBER  := 0;

    CURSOR  c_option_id IS
    SELECT  Option_Id
    FROM    BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE   Indicator         = p_Kpi_Id
    AND     Analysis_Group_ID = p_group_Id
    AND     ROWNUM < 2;
BEGIN
    SAVEPOINT BSCSeefaulValPVT;
    SELECT  Dependency_Flag, Default_Value
    INTO    l_Dependency_Flag, l_Default_Value
    FROM    BSC_KPI_ANALYSIS_GROUPS
    WHERE   Indicator         = p_Kpi_Id
    AND     Analysis_Group_Id = p_group_Id;

    IF (l_Dependency_Flag = 0) THEN -- for indenpendent
         SELECT COUNT(*) INTO l_User_Default
         FROM   BSC_KPI_ANALYSIS_OPTIONS_B
         WHERE  Indicator            =  p_Kpi_Id
         AND    Analysis_Group_Id    =  p_group_Id
         AND    User_Level0          =  1;
         IF (l_User_Default = 0) THEN
            IF (c_option_id%ISOPEN) THEN
              CLOSE c_option_id;
            END IF;
            OPEN c_option_id;
                FETCH c_option_id INTO l_next_option;
                IF (c_option_id%NOTFOUND) THEN
                    l_next_option := 0;
                END IF;
            CLOSE c_option_id;

            UPDATE  BSC_KPI_ANALYSIS_OPTIONS_B
            SET     User_Level0        =  1
                 ,  User_Level1        =  1
            WHERE   Indicator          =  p_Kpi_Id
            AND     Analysis_Group_Id  =  p_group_Id
            AND     Option_Id          =  l_next_option;

            UPDATE  BSC_KPI_ANALYSIS_GROUPS
            SET     Default_Value     =   l_next_option
            WHERE   Indicator         =   p_Kpi_Id
            AND     Analysis_Group_Id =   p_group_Id;
            l_Default_Modified := TRUE;
         END IF;

    ELSE -- for dependent
         IF (p_group_Id = 0) THEN
             SELECT COUNT(*) INTO l_User_Default
             FROM   BSC_KPI_ANALYSIS_OPTIONS_B
             WHERE  Indicator            =  p_Kpi_Id
             AND    Analysis_Group_Id    =  p_group_Id
             AND    User_Level0          =  1;
             IF (l_User_Default = 0) THEN
                IF (c_option_id%ISOPEN) THEN
                  CLOSE c_option_id;
                END IF;
                OPEN c_option_id;
                    FETCH c_option_id INTO l_next_option;
                    IF (c_option_id%NOTFOUND) THEN
                        l_next_option := 0;
                    END IF;
                CLOSE c_option_id;

                UPDATE  BSC_KPI_ANALYSIS_OPTIONS_B
                SET     User_Level0        =  1
                     ,  User_Level1        =  1
                WHERE   Indicator          =  p_Kpi_Id
                AND     Analysis_Group_Id  =  p_group_Id
                AND     Option_Id          =  l_next_option;

                UPDATE  BSC_KPI_ANALYSIS_GROUPS
                SET     Default_Value     =   l_next_option
                WHERE   Indicator         =   p_Kpi_Id
                AND     Analysis_Group_Id =   p_group_Id;
                l_Default_Modified := TRUE;
             END IF;
         ELSIF (p_group_Id = 1) THEN
             SELECT COUNT(*) INTO l_User_Default
             FROM   BSC_KPI_ANALYSIS_OPTIONS_B
             WHERE  Indicator            =  p_Kpi_Id
             AND    Analysis_Group_Id    =  p_group_Id
             AND    User_Level0          =  1;
             IF (l_User_Default = 0) THEN
                IF (c_option_id%ISOPEN) THEN
                  CLOSE c_option_id;
                END IF;
                OPEN c_option_id;
                    FETCH c_option_id INTO l_next_option;
                    IF (c_option_id%NOTFOUND) THEN
                        l_next_option := 0;
                    END IF;
                CLOSE c_option_id;

                UPDATE  BSC_KPI_ANALYSIS_OPTIONS_B
                SET     User_Level0        =  1
                     ,  User_Level1        =  1
                WHERE   Indicator          =  p_Kpi_Id
                AND     Analysis_Group_Id  =  p_group_Id
                AND     Option_Id          =  l_next_option
                AND     Parent_Option_Id   =  p_Parent_Option_Id;

                UPDATE  BSC_KPI_ANALYSIS_GROUPS
                SET     Default_Value     =   l_next_option
                WHERE   Indicator         =   p_Kpi_Id
                AND     Analysis_Group_Id =   p_group_Id;
                l_Default_Modified := TRUE;
             END IF;
         ELSIF (p_group_Id = 2) THEN
             SELECT COUNT(*) INTO l_User_Default
             FROM   BSC_KPI_ANALYSIS_OPTIONS_B
             WHERE  Indicator            =  p_Kpi_Id
             AND    Analysis_Group_Id    =  p_group_Id
             AND    User_Level0          =  1;
             IF (l_User_Default = 0) THEN
                IF (c_option_id%ISOPEN) THEN
                  CLOSE c_option_id;
                END IF;
                OPEN c_option_id;
                    FETCH c_option_id INTO l_next_option;
                    IF (c_option_id%NOTFOUND) THEN
                        l_next_option := 0;
                    END IF;
                CLOSE c_option_id;

                UPDATE  BSC_KPI_ANALYSIS_OPTIONS_B
                SET     User_Level0            =  1
                     ,  User_Level1            =  1
                WHERE   Indicator              =  p_Kpi_Id
                AND     Analysis_Group_Id      =  p_group_Id
                AND     Option_Id              =  l_next_option
                AND     Parent_Option_Id       =  p_Parent_Option_Id
                AND     Grandparent_Option_Id  =  p_Grand_Parent_Option_Id;

                UPDATE  BSC_KPI_ANALYSIS_GROUPS
                SET     Default_Value     =   l_next_option
                WHERE   Indicator         =   p_Kpi_Id
                AND     Analysis_Group_Id =   p_group_Id;
                l_Default_Modified := TRUE;
             END IF;
           END IF;
    END IF;

    SELECT  COUNT(*)
    INTO    l_count
    FROM    BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE   Indicator         =   p_Kpi_Id
    AND     Analysis_Group_Id =   p_group_Id;
    IF(l_count =0) THEN
       l_Default_Modified := TRUE;
    END IF;

    IF (NOT l_Default_Modified) THEN
    IF (l_default_value = p_option_Id) THEN
      l_default_value := 0;
        ELSIF(l_default_value > p_option_Id) THEN
      l_default_value := l_default_value - 1 ;
      IF(l_default_value<0) THEN
        l_default_value := 0;
      END IF;
    END IF;

    UPDATE BSC_KPI_ANALYSIS_GROUPS
    SET DEFAULT_VALUE = l_default_value
    WHERE INDiCATOR   = p_Kpi_Id
    AND   ANALYSIS_GROUP_ID = p_group_Id;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO BSCSeefaulValPVT;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS at Set_Default_Value '||SQLERRM);
        RAISE;
END Set_Default_Value;

/*******************************************************************************/
PROCEDURE Swap_Option_Id
(    p_Kpi_Id                  NUMBER
   , p_group_Id                NUMBER
   , p_parent_option_Id        NUMBER
   , p_grand_parent_option_Id  NUMBER
) IS
    l_Swap_Table                BSC_ANALYSIS_OPTION_PVT.Swap_Ana_Opts_Table;
    l_Count                     NUMBER  :=  0;
    l_Table_Count               NUMBER  :=  0;
    l_Dependency_Flag           NUMBER  :=  0;
    l_parent_option_Id          NUMBER  := -1;
    l_grand_parent_option_Id    NUMBER  := -1;

    CURSOR  c_Kpi_InDependent_Opts IS
    SELECT  Option_ID
    FROM    BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE   Indicator         = p_Kpi_Id
    AND     Analysis_Group_Id = p_group_Id
    ORDER   BY Option_ID;

    CURSOR  c_Kpi_Dependent_Opts IS
    SELECT  Option_ID
    FROM    BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE   Indicator             = p_Kpi_Id
    AND     Analysis_Group_Id     = p_group_Id
    AND     Parent_Option_Id      = p_parent_option_Id
    AND     GrandParent_Option_Id = p_grand_parent_option_Id
    ORDER   BY Option_ID;

    CURSOR  c_Kpi_Par_Dependent_Opts IS
    SELECT  Parent_Option_Id
    FROM    BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE   Indicator             = p_Kpi_Id
    AND     Analysis_Group_Id     = 1
    AND     Parent_Option_Id      = l_parent_option_Id
    ORDER   BY Parent_Option_Id;

    CURSOR  c_Kpi_Gra_Par_Dep_Opts IS
    SELECT  Parent_Option_Id
    FROM    BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE   Indicator             = p_Kpi_Id
    AND     Analysis_Group_Id     = 2
    AND     Parent_Option_Id      = l_parent_option_Id
    ORDER   BY Parent_Option_Id;

    CURSOR  c_Kpi_GraPar_Dependent_Opts IS
    SELECT  GrandParent_Option_Id
    FROM    BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE   Indicator             = p_Kpi_Id
    AND     Analysis_Group_Id     = 2
    AND     GrandParent_Option_Id = l_grand_parent_option_Id
    ORDER   BY GrandParent_Option_Id;

    CURSOR  c_Dependency_Flag IS
    SELECT  Dependency_Flag
    FROM    BSC_KPI_ANALYSIS_GROUPS
    WHERE   Indicator         = p_Kpi_Id
    AND     Analysis_Group_Id = DECODE(p_Group_Id, 0, 1, p_Group_Id);
BEGIN
    --DBMS_OUTPUT.PUT_LINE('entered inside Swap_Option_Id '||p_Group_Id);
    SAVEPOINT BSCSwapOptIdPVT;
    IF (c_Dependency_Flag%ISOPEN) THEN
      CLOSE c_Dependency_Flag;
    END IF;
    OPEN c_Dependency_Flag;
        FETCH c_Dependency_Flag INTO l_Dependency_Flag;
        IF (c_Dependency_Flag%NOTFOUND) THEN
            l_Dependency_Flag := 0;
        END IF;
    CLOSE c_Dependency_Flag;
    --DBMS_OUTPUT.PUT_LINE('l_Dependency_Flag  <'||l_Dependency_Flag||'>');
    IF (l_Dependency_Flag = 0) THEN -- for indenpendent
         l_Table_Count   := 0;
         l_Count         := 0;
         FOR cd IN c_Kpi_InDependent_Opts LOOP
             IF (l_Count <> cd.Option_Id) THEN
                 l_swap_Table(l_Table_Count).p_AnaOpt_Prev_Id    := cd.Option_Id;
                 l_swap_Table(l_Table_Count).p_AnaOpt_Next_Id    := l_Count;

                 UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
                 SET    Option_ID         = l_Count
                 WHERE  Indicator         = p_Kpi_Id
                 AND    Analysis_Group_ID = p_group_Id
                 AND    Option_Id         = cd.Option_Id;

                 UPDATE BSC_KPI_ANALYSIS_OPTIONS_TL
                 SET    Option_ID         = l_Count
                 WHERE  Indicator         = p_Kpi_Id
                 AND    Analysis_Group_ID = p_group_Id
                 AND    Option_Id         = cd.Option_Id;

                l_Parent_Option_Id            :=   cd.Option_Id;
                l_Grand_Parent_Option_Id      :=   cd.Option_Id;
                --DBMS_OUTPUT.PUT_LINE('p_Group_Id                <'||p_Group_Id||'>');
                --DBMS_OUTPUT.PUT_LINE('l_Parent_Option_Id        <'||l_Parent_Option_Id||'>');
                --DBMS_OUTPUT.PUT_LINE('l_Grand_Parent_Option_Id  <'||l_Grand_Parent_Option_Id||'>');
                --DBMS_OUTPUT.PUT_LINE('l_swap_Table('||l_Table_Count||').p_AnaOpt_Prev_Id    <'||cd.Option_Id||'>');
                --DBMS_OUTPUT.PUT_LINE('l_swap_Table('||l_Table_Count||').p_AnaOpt_Next_Id    <'||l_Count||'>');
                FOR ck IN c_Kpi_Gra_Par_Dep_Opts LOOP
                    UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
                    SET    parent_option_id       = l_Count
                    WHERE  Indicator              = p_Kpi_Id
                    AND    Analysis_Group_ID      = 2
                    AND    Parent_Option_Id       = ck.Parent_Option_Id;

                    UPDATE BSC_KPI_ANALYSIS_OPTIONS_TL
                    SET    parent_option_id       = l_Count
                    WHERE  Indicator              = p_Kpi_Id
                    AND    Analysis_Group_ID      = 2
                    AND    Parent_Option_Id       = ck.Parent_Option_Id;
                END LOOP;

                FOR cn1 IN c_Kpi_GraPar_Dependent_Opts LOOP
                    UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
                    SET    Grandparent_Option_Id  = l_Count
                    WHERE  Indicator              = p_Kpi_Id
                    AND    Analysis_Group_ID      = 2
                    AND    Grandparent_Option_Id  = cn1.GrandParent_Option_Id;

                    UPDATE BSC_KPI_ANALYSIS_OPTIONS_TL
                    SET    Grandparent_Option_Id  = l_Count
                    WHERE  Indicator              = p_Kpi_Id
                    AND    Analysis_Group_ID      = 2
                    AND    Grandparent_Option_Id  = cn1.GrandParent_Option_Id;
                END LOOP;
                l_Table_Count := l_Table_Count + 1;
             END IF;
             l_Count := l_Count + 1;
         END LOOP;
         IF (l_Table_Count <> 0) THEN
            IF (p_group_Id = 0) THEN
                FOR i IN 0..(l_swap_Table.COUNT-1) LOOP
                    UPDATE  BSC_KPI_ANALYSIS_MEASURES_B
                    SET     Analysis_Option0 = l_swap_Table(i).p_AnaOpt_Next_Id
                    WHERE   Indicator        = p_Kpi_Id
                    AND     Analysis_Option0 = l_swap_Table(i).p_AnaOpt_Prev_Id;

                    UPDATE  BSC_KPI_ANALYSIS_MEASURES_TL
                    SET     Analysis_Option0 = l_swap_Table(i).p_AnaOpt_Next_Id
                    WHERE   Indicator        = p_Kpi_Id
                    AND     Analysis_Option0 = l_swap_Table(i).p_AnaOpt_Prev_Id;
                 END LOOP;
             ELSIF (p_group_Id = 1) THEN
                 FOR i IN 0..(l_swap_Table.COUNT-1) LOOP
                     UPDATE  BSC_KPI_ANALYSIS_MEASURES_B
                     SET     Analysis_Option1 = l_swap_Table(i).p_AnaOpt_Next_Id
                     WHERE   Indicator        = p_Kpi_Id
                     AND     Analysis_Option1 = l_swap_Table(i).p_AnaOpt_Prev_Id;

                     UPDATE  BSC_KPI_ANALYSIS_MEASURES_TL
                     SET     Analysis_Option1 = l_swap_Table(i).p_AnaOpt_Next_Id
                     WHERE   Indicator        = p_Kpi_Id
                     AND     Analysis_Option1 = l_swap_Table(i).p_AnaOpt_Prev_Id;
                 END LOOP;
             ELSIF (p_group_Id = 2) THEN
                 FOR i IN 0..(l_swap_Table.COUNT-1) LOOP
                     UPDATE  BSC_KPI_ANALYSIS_MEASURES_B
                     SET     Analysis_Option2 = l_swap_Table(i).p_AnaOpt_Next_Id
                     WHERE   Indicator        = p_Kpi_Id
                     AND     Analysis_Option2 = l_swap_Table(i).p_AnaOpt_Prev_Id;

                     UPDATE  BSC_KPI_ANALYSIS_MEASURES_TL
                     SET     Analysis_Option2 = l_swap_Table(i).p_AnaOpt_Next_Id
                     WHERE   Indicator        = p_Kpi_Id
                     AND     Analysis_Option2 = l_swap_Table(i).p_AnaOpt_Prev_Id;
                 END LOOP;
             END IF;
         END IF;
    ELSE -- for dependent
        l_Table_Count   := 0;
        l_Count         := 0;
        FOR cd IN c_Kpi_Dependent_Opts LOOP
            --DBMS_OUTPUT.PUT_LINE('l_swap_Table('||l_Table_Count||').p_AnaOpt_Prev_Id    <'||cd.Option_Id||'>');
            --DBMS_OUTPUT.PUT_LINE('l_swap_Table('||l_Table_Count||').p_AnaOpt_Next_Id    <'||l_Count||'>');
            IF (l_Count <> cd.Option_Id) THEN
                l_swap_Table(l_Table_Count).p_AnaOpt_Prev_Id    := cd.Option_Id;
                l_swap_Table(l_Table_Count).p_AnaOpt_Next_Id    := l_Count;
                --DBMS_OUTPUT.PUT_LINE('*** SWAP ***');
                IF (p_Group_Id = 0) THEN
                    UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
                    SET    Option_ID              = l_Count
                    WHERE  Indicator              = p_Kpi_Id
                    AND    Option_Id              = cd.Option_Id
                    AND    Analysis_Group_ID      = p_Group_Id
                    AND    parent_option_id       = p_Parent_Option_Id
                    AND    Grandparent_Option_Id  = p_Grand_Parent_Option_Id;

                    UPDATE BSC_KPI_ANALYSIS_OPTIONS_TL
                    SET    Option_ID              = l_Count
                    WHERE  Indicator              = p_Kpi_Id
                    AND    Analysis_Group_ID      = p_group_Id
                    AND    Option_Id              = cd.Option_Id
                    AND    parent_option_id       = p_Parent_Option_Id
                    AND    Grandparent_Option_Id  = p_Grand_Parent_Option_Id;
                    l_Parent_Option_Id            :=   cd.Option_Id;
                    l_Grand_Parent_Option_Id      :=   cd.Option_Id;
                    FOR cm IN c_Kpi_Par_Dependent_Opts LOOP
                        UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
                        SET    parent_option_id       = l_Count
                        WHERE  Indicator              = p_Kpi_Id
                        AND    Analysis_Group_ID      = 1
                        AND    Parent_Option_Id       = cm.Parent_Option_Id;

                        UPDATE BSC_KPI_ANALYSIS_OPTIONS_TL
                        SET    parent_option_id       = l_Count
                        WHERE  Indicator              = p_Kpi_Id
                        AND    Analysis_Group_ID      = 1
                        AND    Parent_Option_Id       = cm.Parent_Option_Id;
                    END LOOP;
                    FOR ck IN c_Kpi_Gra_Par_Dep_Opts LOOP
                        UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
                        SET    parent_option_id       = l_Count
                        WHERE  Indicator              = p_Kpi_Id
                        AND    Analysis_Group_ID      = 2
                        AND    Parent_Option_Id       = ck.Parent_Option_Id;

                        UPDATE BSC_KPI_ANALYSIS_OPTIONS_TL
                        SET    parent_option_id       = l_Count
                        WHERE  Indicator              = p_Kpi_Id
                        AND    Analysis_Group_ID      = 2
                        AND    Parent_Option_Id       = ck.Parent_Option_Id;
                    END LOOP;
                    FOR cn1 IN c_Kpi_GraPar_Dependent_Opts LOOP
                        UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
                        SET    Grandparent_Option_Id  = l_Count
                        WHERE  Indicator              = p_Kpi_Id
                        AND    Analysis_Group_ID      = 2
                        AND    Grandparent_Option_Id  = cn1.GrandParent_Option_Id;

                        UPDATE BSC_KPI_ANALYSIS_OPTIONS_TL
                        SET    Grandparent_Option_Id  = l_Count
                        WHERE  Indicator              = p_Kpi_Id
                        AND    Analysis_Group_ID      = 2
                        AND    Grandparent_Option_Id  = cn1.GrandParent_Option_Id;
                    END LOOP;
                ELSIF (p_Group_Id = 1) THEN
                    UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
                    SET    Option_ID              = l_Count
                    WHERE  Indicator              = p_Kpi_Id
                    AND    Option_Id              = cd.Option_Id
                    AND    Analysis_Group_ID      = p_Group_Id
                    AND    parent_option_id       = p_Parent_Option_Id
                    AND    Grandparent_Option_Id  = p_Grand_Parent_Option_Id;

                    UPDATE BSC_KPI_ANALYSIS_OPTIONS_TL
                    SET    Option_ID              = l_Count
                    WHERE  Indicator              = p_Kpi_Id
                    AND    Analysis_Group_ID      = p_group_Id
                    AND    Option_Id              = cd.Option_Id
                    AND    parent_option_id       = p_Parent_Option_Id
                    AND    Grandparent_Option_Id  = p_Grand_Parent_Option_Id;

                    l_Parent_Option_Id            :=   cd.Option_Id;
                    FOR cm IN c_Kpi_Par_Dependent_Opts LOOP
                        UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
                        SET    parent_option_id       = l_Count
                        WHERE  Indicator              = p_Kpi_Id
                        AND    Analysis_Group_ID      = 1
                        AND    parent_option_id       = cm.Parent_Option_Id;

                        UPDATE BSC_KPI_ANALYSIS_OPTIONS_TL
                        SET    parent_option_id       = l_Count
                        WHERE  Indicator              = p_Kpi_Id
                        AND    Analysis_Group_ID      = 1
                        AND    parent_option_id       = cm.Parent_Option_Id;
                    END LOOP;
                ELSIF (p_Group_Id = 2) THEN
                    UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
                    SET    Option_ID              = l_Count
                    WHERE  Indicator              = p_Kpi_Id
                    AND    Option_Id              = cd.Option_Id
                    AND    Analysis_Group_ID      = p_Group_Id
                    AND    parent_option_id       = p_Parent_Option_Id
                    AND    Grandparent_Option_Id  = p_Grand_Parent_Option_Id;

                    UPDATE BSC_KPI_ANALYSIS_OPTIONS_TL
                    SET    Option_ID              = l_Count
                    WHERE  Indicator              = p_Kpi_Id
                    AND    Analysis_Group_ID      = p_group_Id
                    AND    Option_Id              = cd.Option_Id
                    AND    parent_option_id       = p_Parent_Option_Id
                    AND    Grandparent_Option_Id  = p_Grand_Parent_Option_Id;
                END IF;
                l_Table_Count := l_Table_Count + 1;
            END IF;
            l_Count := l_Count + 1;
        END LOOP;
        IF (l_Table_Count <> 0) THEN
            IF (p_group_Id = 0) THEN
                FOR i IN 0..(l_swap_Table.COUNT-1) LOOP
                    UPDATE  BSC_KPI_ANALYSIS_MEASURES_B
                    SET     Analysis_Option0    = l_swap_Table(i).p_AnaOpt_Next_Id
                    WHERE   Indicator           = p_Kpi_Id
                    AND     Analysis_Option0    = l_swap_Table(i).p_AnaOpt_Prev_Id;

                    UPDATE  BSC_KPI_ANALYSIS_MEASURES_TL
                    SET     Analysis_Option0    = l_swap_Table(i).p_AnaOpt_Next_Id
                    WHERE   Indicator           = p_Kpi_Id
                    AND     Analysis_Option0    = l_swap_Table(i).p_AnaOpt_Prev_Id;
                END LOOP;
            ELSIF (p_group_Id = 1) THEN
                FOR i IN 0..(l_swap_Table.COUNT-1) LOOP
                    UPDATE  BSC_KPI_ANALYSIS_MEASURES_B
                    SET     Analysis_Option1 = l_swap_Table(i).p_AnaOpt_Next_Id
                    WHERE   Indicator        = p_Kpi_Id
                    AND     Analysis_Option1 = l_swap_Table(i).p_AnaOpt_Prev_Id
                    AND     Analysis_Option0 = p_Parent_Option_Id;

                    UPDATE  BSC_KPI_ANALYSIS_MEASURES_TL
                    SET     Analysis_Option1 = l_swap_Table(i).p_AnaOpt_Next_Id
                    WHERE   Indicator        = p_Kpi_Id
                    AND     Analysis_Option1 = l_swap_Table(i).p_AnaOpt_Prev_Id
                    AND     Analysis_Option0 = p_Parent_Option_Id;
                END LOOP;
            ELSIF (p_group_Id = 2) THEN
                FOR i IN 0..(l_swap_Table.COUNT-1) LOOP
                    UPDATE  BSC_KPI_ANALYSIS_MEASURES_B
                    SET     Analysis_Option2 = l_swap_Table(i).p_AnaOpt_Next_Id
                    WHERE   Indicator        = p_Kpi_Id
                    AND     Analysis_Option2 = l_swap_Table(i).p_AnaOpt_Prev_Id
                    AND     Analysis_Option1 = p_Parent_Option_Id
                    AND     Analysis_Option0 = p_Grand_Parent_Option_Id;

                    UPDATE  BSC_KPI_ANALYSIS_MEASURES_TL
                    SET     Analysis_Option2 = l_swap_Table(i).p_AnaOpt_Next_Id
                    WHERE   Indicator        = p_Kpi_Id
                    AND     Analysis_Option2 = l_swap_Table(i).p_AnaOpt_Prev_Id
                    AND     Analysis_Option1 = p_parent_option_Id
                    AND     Analysis_Option0 = p_grand_parent_option_Id;
                END LOOP;
            END IF;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_Dependency_Flag%ISOPEN) THEN
          CLOSE c_Dependency_Flag;
        END IF;
        ROLLBACK TO BSCSwapOptIdPVT;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS at Swap_Option_Id '||SQLERRM);
        RAISE;
END Swap_Option_Id;
/**************************************************************************************************/
--:     This procedure is used to create an analysis option.  This is the entry point
--:     for the Analysis Option API.
--:     This procedure is part of the Analysis Option API.

procedure Create_Analysis_Options(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;
l_Anal_Opt_Rec BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT CreateBSCAnaOptPVT;
  -- Check that valid Kpi id was entered.
  if p_Anal_Opt_Rec.Bsc_Kpi_Id is not null then
    /*l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                      ,'indicator'
                                                      ,p_Anal_Opt_Rec.Bsc_Kpi_Id);*/
     SELECT COUNT(0)
     INTO   l_count
     FROM   BSC_KPIS_B
     WHERE INDICATOR = p_Anal_Opt_Rec.Bsc_Kpi_Id;

    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  g_db_object := 'BSC_KPI_ANALYSIS_OPTIONS_B';

  -- Insert pertaining values into table bsc_kpi_analysis_options_b.
  INSERT INTO BSC_KPI_ANALYSIS_OPTIONS_B( INDICATOR
                                         ,ANALYSIS_GROUP_ID
                                         ,OPTION_ID
                                         ,PARENT_OPTION_ID
                                         ,GRANDPARENT_OPTION_ID
                                         ,DIM_SET_ID
                                         ,USER_LEVEL0
                                         ,USER_LEVEL1
                                         ,USER_LEVEL1_DEFAULT
                                         ,USER_LEVEL2
                                         ,USER_LEVEL2_DEFAULT
                                         ,SHORT_NAME)
                                  VALUES( p_Anal_Opt_Rec.Bsc_Kpi_Id
                                         ,p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
                                         ,p_Anal_Opt_Rec.Bsc_Analysis_Option_Id
                                         ,p_Anal_Opt_Rec.Bsc_Parent_Option_Id
                                         ,p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id
                                         ,p_Anal_Opt_Rec.Bsc_Dim_Set_Id
                                         ,p_Anal_Opt_Rec.Bsc_User_Level0
                                         ,p_Anal_Opt_Rec.Bsc_User_Level1
                                         ,p_Anal_Opt_Rec.Bsc_User_Level1_Default
                                         ,p_Anal_Opt_Rec.Bsc_User_Level2
                                         ,p_Anal_Opt_Rec.Bsc_User_Level2_Default
                                         ,p_Anal_Opt_Rec.Bsc_Option_Short_Name);

  g_db_object := 'BSC_KPI_ANALYSIS_OPTIONS_TL';

  -- Insert pertaining values into table bsc_kpi_analysis_options_tl.
  INSERT INTO BSC_KPI_ANALYSIS_OPTIONS_TL( INDICATOR
                                          ,ANALYSIS_GROUP_ID
                                          ,OPTION_ID
                                          ,PARENT_OPTION_ID
                                          ,GRANDPARENT_OPTION_ID
                                          ,LANGUAGE
                                          ,SOURCE_LANG
                                          ,NAME
                                          ,HELP)
                                   select  p_Anal_Opt_Rec.Bsc_Kpi_Id
                                          ,p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
                                          ,p_Anal_Opt_Rec.Bsc_Analysis_Option_Id
                                          ,p_Anal_Opt_Rec.Bsc_Parent_Option_Id
                                          ,p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id
                                          ,L.LANGUAGE_CODE
                                          ,userenv('LANG')
                                          ,p_Anal_Opt_Rec.Bsc_Option_Name
                                          ,p_Anal_Opt_Rec.Bsc_Option_Help
                                      from FND_LANGUAGES L
                                     where L.INSTALLED_FLAG in ('I', 'B')
                                       and not exists
                                           (select NULL
                                              from BSC_KPI_ANALYSIS_OPTIONS_TL T
                                             where T.indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id
                                               and T.analysis_group_id = p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
                                               and T.option_id = p_Anal_Opt_Rec.Bsc_Analysis_Option_Id
                                               and T.parent_option_id = p_Anal_Opt_Rec.Bsc_Parent_Option_Id
                                               and T.grandparent_option_id = p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id
                                               and T.LANGUAGE = L.LANGUAGE_CODE);

  -- Update table bsc_kpi_analysis_groups with the current number of options.
  update BSC_KPI_ANALYSIS_GROUPS
     set num_of_options = p_Anal_Opt_Rec.Bsc_Analysis_Option_Id + 1
   where indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCAnaOptPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCAnaOptPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   => 'F'
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCAnaOptPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Create_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Create_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCAnaOptPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Create_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Create_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Analysis_Options;

/************************************************************************************
************************************************************************************/

-- added code to retrive Short_Name as well.
procedure Retrieve_Analysis_Options
(
    p_commit              IN              varchar2 -- :=  FND_API.G_FALSE
 ,  p_Anal_Opt_Rec        IN              BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,  x_Anal_Opt_Rec        IN  OUT NOCOPY  BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,  p_data_source         IN              VARCHAR2
 ,  x_return_status       OUT NOCOPY      varchar2
 ,  x_msg_count           OUT NOCOPY      number
 ,  x_msg_data            OUT NOCOPY      varchar2
) is

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  g_db_object := 'Retrieve_Analysis_Options';
IF ((p_Data_Source IS NOT NULL) AND
       (p_Data_Source = 'BSC') AND
         (p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id IS NULL) AND
           (p_Anal_Opt_Rec.Bsc_Parent_Option_Id IS NOT NULL )) THEN
        SELECT DISTINCT GRANDPARENT_OPTION_ID
                       ,DIM_SET_ID
                       ,USER_LEVEL0
                       ,USER_LEVEL1
                       ,USER_LEVEL1_DEFAULT
                       ,USER_LEVEL2
                       ,USER_LEVEL2_DEFAULT
                       ,NAME
                       ,HELP
                       ,SHORT_NAME
                  into  x_Anal_Opt_Rec.Bsc_Grandparent_Option_Id
                       ,x_Anal_Opt_Rec.Bsc_Dim_Set_Id
                       ,x_Anal_Opt_Rec.Bsc_User_Level0
                       ,x_Anal_Opt_Rec.Bsc_User_Level1
                       ,x_Anal_Opt_Rec.Bsc_User_Level1_Default
                       ,x_Anal_Opt_Rec.Bsc_User_Level2
                       ,x_Anal_Opt_Rec.Bsc_User_Level2_Default
                       ,x_Anal_Opt_Rec.Bsc_Option_Name
                       ,x_Anal_Opt_Rec.Bsc_Option_Help
                       ,x_Anal_Opt_Rec.Bsc_Option_Short_Name
                  from  BSC_KPI_ANALYSIS_OPTIONS_VL
                 where indicator          = p_Anal_Opt_Rec.Bsc_Kpi_Id
                   and analysis_group_id  = p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
                   and option_id          = p_Anal_Opt_Rec.Bsc_Analysis_Option_Id
                   and parent_option_id   = p_Anal_Opt_Rec.Bsc_Parent_Option_Id;
  ELSIF ((p_Data_Source IS NOT NULL) AND
          (p_Data_Source = 'BSC') AND
            (p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id IS NOT NULL) AND
              (p_Anal_Opt_Rec.Bsc_Parent_Option_Id IS NOT NULL )) THEN
      SELECT DISTINCT DIM_SET_ID
                       ,USER_LEVEL0
                       ,USER_LEVEL1
                       ,USER_LEVEL1_DEFAULT
                       ,USER_LEVEL2
                       ,USER_LEVEL2_DEFAULT
                       ,NAME
                       ,HELP
                       ,SHORT_NAME
                  into  x_Anal_Opt_Rec.Bsc_Dim_Set_Id
                       ,x_Anal_Opt_Rec.Bsc_User_Level0
                       ,x_Anal_Opt_Rec.Bsc_User_Level1
                       ,x_Anal_Opt_Rec.Bsc_User_Level1_Default
                       ,x_Anal_Opt_Rec.Bsc_User_Level2
                       ,x_Anal_Opt_Rec.Bsc_User_Level2_Default
                       ,x_Anal_Opt_Rec.Bsc_Option_Name
                       ,x_Anal_Opt_Rec.Bsc_Option_Help
                       ,x_Anal_Opt_Rec.Bsc_Option_Short_Name
                  from  BSC_KPI_ANALYSIS_OPTIONS_VL
                 where indicator              = p_Anal_Opt_Rec.Bsc_Kpi_Id
                   and analysis_group_id      = p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
                   and option_id              = p_Anal_Opt_Rec.Bsc_Analysis_Option_Id
                   and parent_option_id       = p_Anal_Opt_Rec.Bsc_Parent_Option_Id
                   and grandparent_option_id  = p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;
  ELSE
        SELECT DISTINCT PARENT_OPTION_ID
                       ,GRANDPARENT_OPTION_ID
                       ,DIM_SET_ID
                       ,USER_LEVEL0
                       ,USER_LEVEL1
                       ,USER_LEVEL1_DEFAULT
                       ,USER_LEVEL2
                       ,USER_LEVEL2_DEFAULT
                       ,NAME
                       ,HELP
                       ,SHORT_NAME
                  into  x_Anal_Opt_Rec.Bsc_Parent_Option_Id
                       ,x_Anal_Opt_Rec.Bsc_Grandparent_Option_Id
                       ,x_Anal_Opt_Rec.Bsc_Dim_Set_Id
                       ,x_Anal_Opt_Rec.Bsc_User_Level0
                       ,x_Anal_Opt_Rec.Bsc_User_Level1
                       ,x_Anal_Opt_Rec.Bsc_User_Level1_Default
                       ,x_Anal_Opt_Rec.Bsc_User_Level2
                       ,x_Anal_Opt_Rec.Bsc_User_Level2_Default
                       ,x_Anal_Opt_Rec.Bsc_Option_Name
                       ,x_Anal_Opt_Rec.Bsc_Option_Help
                       ,x_Anal_Opt_Rec.Bsc_Option_Short_Name
                  from  BSC_KPI_ANALYSIS_OPTIONS_VL
                 where indicator          = p_Anal_Opt_Rec.Bsc_Kpi_Id
                   and analysis_group_id  = p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
                   and option_id          = p_Anal_Opt_Rec.Bsc_Analysis_Option_Id;

  END IF;
  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

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
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Retrieve_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Retrieve_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Retrieve_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Retrieve_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Analysis_Options;

/************************************************************************************
************************************************************************************/

procedure Update_Analysis_Options
(
    p_commit              IN            varchar2 -- :=  FND_API.G_FALSE
 ,  p_Anal_Opt_Rec        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,  p_data_source         IN            VARCHAR2
 ,  x_return_status       OUT NOCOPY    VARCHAR2
 ,  x_msg_count           OUT NOCOPY    NUMBER
 ,  x_msg_data            OUT NOCOPY    VARCHAR2
) IS
  l_Anal_Opt_Rec      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
  l_count                     number;
begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT UpdateBSCAnaOptPVT;
  -- Check that valid Kpi id was entered.
  if p_Anal_Opt_Rec.Bsc_Kpi_Id is not null then
    /*l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Anal_Opt_Rec.Bsc_Kpi_Id);*/
     SELECT COUNT(0)
     INTO   l_count
     FROM   BSC_KPIS_B
     WHERE INDICATOR = p_Anal_Opt_Rec.Bsc_Kpi_Id;

    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;
  -- update LOCAL language ,source language, group id and level Id values with PASSED values.
  l_Anal_Opt_Rec.Bsc_Language               := p_Anal_Opt_Rec.Bsc_Language;
  l_Anal_Opt_Rec.Bsc_Source_Language        := p_Anal_Opt_Rec.Bsc_Source_Language;
  l_Anal_Opt_Rec.Bsc_Kpi_Id                 := p_Anal_Opt_Rec.Bsc_Kpi_Id;
  l_Anal_Opt_Rec.Bsc_Analysis_Group_Id      := p_Anal_Opt_Rec.Bsc_Analysis_Group_Id;
  l_Anal_Opt_Rec.Bsc_Analysis_Option_Id     := p_Anal_Opt_Rec.Bsc_Analysis_Option_Id;
  l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id  := p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;
  l_Anal_Opt_Rec.Bsc_Parent_Option_Id       := p_Anal_Opt_Rec.Bsc_Parent_Option_Id;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Analysis_Options( p_commit
                            ,p_Anal_Opt_Rec
                            ,l_Anal_Opt_Rec
                            ,p_data_source
                            ,x_return_status
                            ,x_msg_count
                            ,x_msg_data);

  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Anal_Opt_Rec.Bsc_Parent_Option_Id is not null then
    l_Anal_Opt_Rec.Bsc_Parent_Option_Id := p_Anal_Opt_Rec.Bsc_Parent_Option_Id;
  end if;
  if p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id is not null then
    l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id := p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;
  end if;
  if p_Anal_Opt_Rec.Bsc_Dim_Set_Id is not null then
    l_Anal_Opt_Rec.Bsc_Dim_Set_Id := p_Anal_Opt_Rec.Bsc_Dim_Set_Id;
  end if;
  if p_Anal_Opt_Rec.Bsc_User_Level0 is not null then
    l_Anal_Opt_Rec.Bsc_User_Level0 := p_Anal_Opt_Rec.Bsc_User_Level0;
  end if;
  if p_Anal_Opt_Rec.Bsc_User_Level1 is not null then
    l_Anal_Opt_Rec.Bsc_User_Level1 := p_Anal_Opt_Rec.Bsc_User_Level1;
  end if;
  if p_Anal_Opt_Rec.Bsc_User_Level1_Default is not null then
    l_Anal_Opt_Rec.Bsc_User_Level1_Default := p_Anal_Opt_Rec.Bsc_User_Level1_Default;
  end if;
  if p_Anal_Opt_Rec.Bsc_User_Level2 is not null then
    l_Anal_Opt_Rec.Bsc_User_Level2 := p_Anal_Opt_Rec.Bsc_User_Level2;
  end if;
  if p_Anal_Opt_Rec.Bsc_User_Level2_Default is not null then
    l_Anal_Opt_Rec.Bsc_User_Level2_Default := p_Anal_Opt_Rec.Bsc_User_Level2_Default;
  end if;
  if p_Anal_Opt_Rec.Bsc_Option_Name is not null then
    l_Anal_Opt_Rec.Bsc_Option_Name := p_Anal_Opt_Rec.Bsc_Option_Name;
  end if;
  if p_Anal_Opt_Rec.Bsc_Option_Help is not null then
    l_Anal_Opt_Rec.Bsc_Option_Help := p_Anal_Opt_Rec.Bsc_Option_Help;
  end if;

  -- adrao added for Enh#3540302 and Bug#3691035
  if p_Anal_Opt_Rec.Bsc_Option_Short_Name is not null then
    l_Anal_Opt_Rec.Bsc_Option_Short_Name := p_Anal_Opt_Rec.Bsc_Option_Short_Name;
  end if;

  IF ((p_Data_Source IS NOT NULL) AND
       (p_Data_Source = 'BSC') AND
         (p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id IS NULL) AND
           (p_Anal_Opt_Rec.Bsc_Parent_Option_Id IS NOT NULL )) THEN
      update BSC_KPI_ANALYSIS_OPTIONS_B
         set  grandparent_option_id = l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id
             ,dim_set_id            = l_Anal_Opt_Rec.Bsc_Dim_Set_Id
             ,user_level0           = l_Anal_Opt_Rec.Bsc_User_Level0
             ,user_level1           = l_Anal_Opt_Rec.Bsc_User_Level1
             ,user_level1_default   = l_Anal_Opt_Rec.Bsc_User_Level1_Default
             ,user_level2           = l_Anal_Opt_Rec.Bsc_User_Level2
             ,user_level2_default   = l_Anal_Opt_Rec.Bsc_User_Level2_Default
             ,short_name            = l_Anal_Opt_Rec.Bsc_Option_Short_Name
       where indicator              = p_Anal_Opt_Rec.Bsc_Kpi_Id
         and analysis_group_id      = p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
         and option_Id              = p_Anal_Opt_Rec.Bsc_Analysis_Option_Id
         and parent_option_id       = p_Anal_Opt_Rec.Bsc_Parent_Option_Id;

      update BSC_KPI_ANALYSIS_OPTIONS_TL
         set name                   = l_Anal_Opt_Rec.Bsc_Option_Name
            ,help                   = l_Anal_Opt_Rec.Bsc_Option_Help
            ,source_lang            = userenv('LANG')
       where indicator              = p_Anal_Opt_Rec.Bsc_Kpi_Id
         and analysis_group_id      = p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
         and option_Id              = p_Anal_Opt_Rec.Bsc_Analysis_Option_Id
         and parent_option_id       = p_Anal_Opt_Rec.Bsc_Parent_Option_Id
         and userenv('LANG')       in (LANGUAGE, SOURCE_LANG);
  ELSIF ((p_Data_Source IS NOT NULL) AND
          (p_Data_Source = 'BSC') AND
            (p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id IS NOT NULL) AND
              (p_Anal_Opt_Rec.Bsc_Parent_Option_Id IS NOT NULL )) THEN
      update BSC_KPI_ANALYSIS_OPTIONS_B
         set  dim_set_id            = l_Anal_Opt_Rec.Bsc_Dim_Set_Id
             ,user_level0           = l_Anal_Opt_Rec.Bsc_User_Level0
             ,user_level1           = l_Anal_Opt_Rec.Bsc_User_Level1
             ,user_level1_default   = l_Anal_Opt_Rec.Bsc_User_Level1_Default
             ,user_level2           = l_Anal_Opt_Rec.Bsc_User_Level2
             ,user_level2_default   = l_Anal_Opt_Rec.Bsc_User_Level2_Default
             ,short_name            = l_Anal_Opt_Rec.Bsc_Option_Short_Name
       where indicator              = p_Anal_Opt_Rec.Bsc_Kpi_Id
         and analysis_group_id      = p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
         and option_Id              = p_Anal_Opt_Rec.Bsc_Analysis_Option_Id
         and parent_option_id       = p_Anal_Opt_Rec.Bsc_Parent_Option_Id
         and grandparent_option_id  = p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;

      update BSC_KPI_ANALYSIS_OPTIONS_TL
         set name                   = l_Anal_Opt_Rec.Bsc_Option_Name
            ,help                   = l_Anal_Opt_Rec.Bsc_Option_Help
            ,source_lang            = userenv('LANG')
       where indicator              = p_Anal_Opt_Rec.Bsc_Kpi_Id
         and analysis_group_id      = p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
         and option_Id              = p_Anal_Opt_Rec.Bsc_Analysis_Option_Id
         and parent_option_id       = p_Anal_Opt_Rec.Bsc_Parent_Option_Id
         and grandparent_option_id  = p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id
         and userenv('LANG')       in (LANGUAGE, SOURCE_LANG);
  ELSE
      update BSC_KPI_ANALYSIS_OPTIONS_B
         set  parent_option_id      = l_Anal_Opt_Rec.Bsc_Parent_Option_Id
             ,grandparent_option_id = l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id
             ,dim_set_id            = l_Anal_Opt_Rec.Bsc_Dim_Set_Id
             ,user_level0           = l_Anal_Opt_Rec.Bsc_User_Level0
             ,user_level1           = l_Anal_Opt_Rec.Bsc_User_Level1
             ,user_level1_default   = l_Anal_Opt_Rec.Bsc_User_Level1_Default
             ,user_level2           = l_Anal_Opt_Rec.Bsc_User_Level2
             ,user_level2_default   = l_Anal_Opt_Rec.Bsc_User_Level2_Default
             ,short_name            = l_Anal_Opt_Rec.Bsc_Option_Short_Name
       where indicator              = p_Anal_Opt_Rec.Bsc_Kpi_Id
         and analysis_group_id      = p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
         and option_Id              = p_Anal_Opt_Rec.Bsc_Analysis_Option_Id;

      update BSC_KPI_ANALYSIS_OPTIONS_TL
         set name                   = l_Anal_Opt_Rec.Bsc_Option_Name
            ,help                   = l_Anal_Opt_Rec.Bsc_Option_Help
            ,source_lang            = userenv('LANG')
       where indicator              = p_Anal_Opt_Rec.Bsc_Kpi_Id
         and analysis_group_id      = p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
         and option_Id              = p_Anal_Opt_Rec.Bsc_Analysis_Option_Id
         and userenv('LANG')       in (LANGUAGE, SOURCE_LANG);
  END IF;
  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateBSCAnaOptPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateBSCAnaOptPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateBSCAnaOptPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Update_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Update_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateBSCAnaOptPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Update_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Update_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Analysis_Options;

/************************************************************************************
************************************************************************************/

PROCEDURE Delete_Analysis_Options
(       p_commit              IN            varchar2 -- :=  FND_API.G_FALSE
    ,   p_Anal_Opt_Rec        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    ,   x_return_status       OUT NOCOPY    VARCHAR2
    ,   x_msg_count           OUT NOCOPY    NUMBER
    ,   x_msg_data            OUT NOCOPY    VARCHAR2
) IS
    l_Group_ID              BSC_KPI_ANALYSIS_OPTIONS_B.Analysis_Group_Id%TYPE;
    l_Anal_Opt_Rec          BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
    l_Bsc_Kpi_Entity_Rec    BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

    l_AnaOpt_Delete         BOOLEAN := TRUE;
    l_delete                VARCHAR2(1);
    l_count                 NUMBER;
    l_shared_count          NUMBER;
    l_default_option        NUMBER;
    l_next_option           NUMBER;

    l_Parent_Opt_Id         NUMBER;
    l_Gra_Parent_Opt_Id     NUMBER;
    l_default_value     NUMBER;
    l_Kpi_Name          BSC_KPIS_VL.NAME%TYPE;

    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  p_Anal_Opt_Rec.Bsc_Kpi_Id
    AND     Prototype_Flag  <> BSC_KPI_PUB.Delete_Kpi_Flag;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT DeleteBSCAnaOptPVT;
    l_Anal_Opt_Rec := p_Anal_Opt_Rec;
    -- Check that valid Kpi id was entered.
    IF (p_Anal_Opt_Rec.Bsc_Kpi_Id IS NOT NULL) THEN
        l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B', 'indicator', p_Anal_Opt_Rec.Bsc_Kpi_Id);
        IF l_count = 0 THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
            FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSE
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
        FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_delete := Delete_Analysis_Option( l_Anal_Opt_Rec.Bsc_Kpi_Id
                                     ,l_Anal_Opt_Rec.Bsc_Analysis_Option_Id
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data
                                     ,l_Anal_Opt_Rec.Bsc_Analysis_Group_Id);
    IF (l_delete = 'S') THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_KPI');
        FND_MESSAGE.SET_TOKEN('BSC_AO_DELETE', l_Anal_Opt_Rec.Bsc_Kpi_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF l_delete = 'L' THEN
        IF is_custom_kpi(l_Anal_Opt_Rec.Bsc_Kpi_Id,l_Kpi_Name) = FALSE THEN
          FND_MESSAGE.SET_NAME('BSC','BSC_LAST_AO_IN_KPI');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          FND_MESSAGE.SET_NAME('BSC','BSC_LAST_AO_IN_CUST_KPI');
          FND_MESSAGE.SET_TOKEN('OBJ_NAME', l_Kpi_Name);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    IF (l_Anal_Opt_Rec.Bsc_Analysis_Group_Id IS NULL) THEN
        l_Anal_Opt_Rec.Bsc_Analysis_Group_Id := 0;
    END IF;
    l_AnaOpt_Delete := TRUE;
    l_Parent_Opt_Id         := l_Anal_Opt_Rec.Bsc_Parent_Option_Id;
    l_Gra_Parent_Opt_Id     := l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;
    --DBMS_OUTPUT.PUT_LINE('l_Anal_Opt_Rec.Bsc_Analysis_Option_Id <'||l_Anal_Opt_Rec.Bsc_Analysis_Option_Id||'>');
    --DBMS_OUTPUT.PUT_LINE('l_Anal_Opt_Rec.Bsc_Parent_Option_Id   <'||l_Anal_Opt_Rec.Bsc_Parent_Option_Id||'>');
    --DBMS_OUTPUT.PUT_LINE('l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id <'||l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id||'>');
    --DBMS_OUTPUT.PUT_LINE('l_Anal_Opt_Rec.Bsc_Analysis_Group_Id <'||l_Anal_Opt_Rec.Bsc_Analysis_Group_Id||'>');
    IF (l_AnaOpt_Delete) THEN
        SELECT MAX(Analysis_Group_Id) INTO l_Group_ID
        FROM   BSC_KPI_ANALYSIS_OPTIONS_B
        WHERE  Indicator = l_Anal_Opt_Rec.Bsc_Kpi_Id;

        IF (l_Group_ID = 0) THEN
            l_Anal_Opt_Rec.Bsc_Parent_Option_Id           := NULL;
            l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id      := NULL;
        ELSIF (l_Group_ID = 1) THEN
            l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id      := NULL;
            IF (l_Anal_Opt_Rec.Bsc_Parent_Option_Id IS NULL) THEN
                l_Anal_Opt_Rec.Bsc_Parent_Option_Id       := 0;
            END IF;
        ELSE
            IF (l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id IS NULL) THEN
                l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id  := 0;
            END IF;
            IF (l_Anal_Opt_Rec.Bsc_Parent_Option_Id IS NULL) THEN
                l_Anal_Opt_Rec.Bsc_Parent_Option_Id       := 0;
            END IF;
        END IF;
        IF ((l_Anal_Opt_Rec.Bsc_Analysis_Option_Id IS NOT NULL) AND
                (l_Anal_Opt_Rec.Bsc_Parent_Option_Id IS NOT NULL) AND
                  (l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id IS NOT NULL)) THEN
            DELETE FROM BSC_KPI_ANALYSIS_OPTIONS_B
             WHERE indicator            = l_Anal_Opt_Rec.Bsc_Kpi_Id
              AND analysis_group_id     = NVL(l_Anal_Opt_Rec.Bsc_Analysis_Group_Id, 2)
              AND option_id             = l_Anal_Opt_Rec.Bsc_Analysis_Option_Id
              AND parent_option_id      = l_Anal_Opt_Rec.Bsc_Parent_Option_Id
              AND grandparent_option_id = l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;

            DELETE FROM BSC_KPI_ANALYSIS_OPTIONS_TL
             WHERE indicator            = l_Anal_Opt_Rec.Bsc_Kpi_Id
              AND analysis_group_id     = NVL(l_Anal_Opt_Rec.Bsc_Analysis_Group_Id, 2)
              AND option_id             = l_Anal_Opt_Rec.Bsc_Analysis_Option_Id
              AND parent_option_id      = l_Anal_Opt_Rec.Bsc_Parent_Option_Id
              AND grandparent_option_id = l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;

        ELSIF ((l_Anal_Opt_Rec.Bsc_Analysis_Option_Id IS NOT NULL) AND
                (l_Anal_Opt_Rec.Bsc_Parent_Option_Id IS NOT NULL)) THEN
            DELETE FROM BSC_KPI_ANALYSIS_OPTIONS_B
            WHERE   indicator         = l_Anal_Opt_Rec.Bsc_Kpi_Id
            AND     analysis_group_id = NVL(l_Anal_Opt_Rec.Bsc_Analysis_Group_Id, 1)
            AND     option_id         = l_Anal_Opt_Rec.Bsc_Analysis_Option_Id
            AND     parent_option_id  = l_Anal_Opt_Rec.Bsc_Parent_Option_Id;

            DELETE FROM BSC_KPI_ANALYSIS_OPTIONS_TL
            WHERE   indicator         = l_Anal_Opt_Rec.Bsc_Kpi_Id
            AND     analysis_group_id = NVL(l_Anal_Opt_Rec.Bsc_Analysis_Group_Id, 1)
            AND     option_id         = l_Anal_Opt_Rec.Bsc_Analysis_Option_Id
            AND     parent_option_id  = l_Anal_Opt_Rec.Bsc_Parent_Option_Id;

        ELSE
            DELETE FROM BSC_KPI_ANALYSIS_OPTIONS_B
            WHERE indicator         = l_Anal_Opt_Rec.Bsc_Kpi_Id
            AND   analysis_group_id = NVL(l_Anal_Opt_Rec.Bsc_Analysis_Group_Id, 0)
            AND   option_id         = l_Anal_Opt_Rec.Bsc_Analysis_Option_Id;

            DELETE FROM BSC_KPI_ANALYSIS_OPTIONS_TL
            WHERE indicator         = l_Anal_Opt_Rec.Bsc_Kpi_Id
            AND   analysis_group_id = NVL(l_Anal_Opt_Rec.Bsc_Analysis_Group_Id, 0)
            AND   option_id         = l_Anal_Opt_Rec.Bsc_Analysis_Option_Id;

        END IF;
    END IF;
    BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Measures( p_commit
                             ,l_Anal_Opt_Rec
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);

    --DBMS_OUTPUT.PUT_LINE(' Swap_Option_Id( p_Kpi_Id                  <'||l_Anal_Opt_Rec.Bsc_Kpi_Id ||'>');
    --DBMS_OUTPUT.PUT_LINE(' Swap_Option_Id( p_group_id                <'||l_Anal_Opt_Rec.Bsc_Analysis_Group_Id||'>');
    --DBMS_OUTPUT.PUT_LINE(' Swap_Option_Id( p_parent_option_Id        <'||NVL(l_Parent_Opt_Id, 0)||'>');
    --DBMS_OUTPUT.PUT_LINE(' Swap_Option_Id( p_grand_parent_option_Id  <'||NVL(l_Gra_Parent_Opt_Id, 0)||'>');
    BSC_ANALYSIS_OPTION_PVT.Swap_Option_Id
    (  p_Kpi_Id                  =>  l_Anal_Opt_Rec.Bsc_Kpi_Id
     , p_group_id                =>  l_Anal_Opt_Rec.Bsc_Analysis_Group_Id
     , p_parent_option_Id        =>  NVL(l_Parent_Opt_Id, 0)
     , p_grand_parent_option_Id  =>  NVL(l_Gra_Parent_Opt_Id, 0)
    );
    BSC_ANALYSIS_OPTION_PVT.Set_Default_Value
    (  p_Kpi_Id                  =>  l_Anal_Opt_Rec.Bsc_Kpi_Id
     , p_group_id                =>  l_Anal_Opt_Rec.Bsc_Analysis_Group_Id
     , p_parent_option_Id        =>  NVL(l_Parent_Opt_Id, 0)
     , p_grand_parent_option_Id  =>  NVL(l_Gra_Parent_Opt_Id, 0)
     , p_option_Id               =>  NVL(l_Anal_Opt_Rec.Bsc_Analysis_Option_Id,0)
    );

    /*IF(l_Anal_Opt_Rec.Bsc_Analysis_Group_Id =0) THEN
    SELECT DEFAULT_VALUE
    INTO l_default_value
    FROM BSC_KPI_ANALYSIS_GROUPS
    WHERE INDICATOR = l_Anal_Opt_Rec.Bsc_Kpi_Id
    AND   ANALYSIS_GROUP_ID = 0;

    IF (l_default_value = l_Anal_Opt_Rec.Bsc_Analysis_Option_Id) THEN
      l_default_value := 0;
        ELSIF(l_default_value>l_Anal_Opt_Rec.Bsc_Analysis_Option_Id) THEN
      l_default_value := l_default_value - 1 ;
    END IF;

    UPDATE BSC_KPI_ANALYSIS_GROUPS
    SET DEFAULT_VALUE = l_default_value
    WHERE INDiCATOR   = l_Anal_Opt_Rec.Bsc_Kpi_Id
    AND   ANALYSIS_GROUP_ID = 0;
    END IF;*/
     -- if there are any shared KPIs update those also.
    FOR cd IN c_kpi_ids LOOP
        l_Anal_Opt_Rec.Bsc_Kpi_Id       := cd.Indicator;
        l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := cd.Indicator;
        IF (l_AnaOpt_Delete) THEN
            IF ((l_Anal_Opt_Rec.Bsc_Analysis_Option_Id IS NOT NULL) AND
                  (l_Anal_Opt_Rec.Bsc_Parent_Option_Id IS NOT NULL) AND
                    (l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id IS NOT NULL)) THEN
                delete from BSC_KPI_ANALYSIS_OPTIONS_B
                 where indicator            = l_Anal_Opt_Rec.Bsc_Kpi_Id
                  and analysis_group_id     = NVL(l_Anal_Opt_Rec.Bsc_Analysis_Group_Id, 2)
                  and option_id             = l_Anal_Opt_Rec.Bsc_Analysis_Option_Id
                  and parent_option_id      = l_Anal_Opt_Rec.Bsc_Parent_Option_Id
                  and grandparent_option_id = l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;

                delete from BSC_KPI_ANALYSIS_OPTIONS_TL
                 where indicator            = l_Anal_Opt_Rec.Bsc_Kpi_Id
                  and analysis_group_id     = NVL(l_Anal_Opt_Rec.Bsc_Analysis_Group_Id, 2)
                  and option_id             = l_Anal_Opt_Rec.Bsc_Analysis_Option_Id
                  and parent_option_id      = l_Anal_Opt_Rec.Bsc_Parent_Option_Id
                  and grandparent_option_id = l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;
            ELSIF ((l_Anal_Opt_Rec.Bsc_Analysis_Option_Id IS NOT NULL) AND
                     (l_Anal_Opt_Rec.Bsc_Parent_Option_Id IS NOT NULL)) THEN
                delete from BSC_KPI_ANALYSIS_OPTIONS_B
                 where indicator            = l_Anal_Opt_Rec.Bsc_Kpi_Id
                  and analysis_group_id     = NVL(l_Anal_Opt_Rec.Bsc_Analysis_Group_Id, 1)
                  and option_id             = l_Anal_Opt_Rec.Bsc_Analysis_Option_Id
                  and parent_option_id      = l_Anal_Opt_Rec.Bsc_Parent_Option_Id;

                delete from BSC_KPI_ANALYSIS_OPTIONS_TL
                 where indicator            = l_Anal_Opt_Rec.Bsc_Kpi_Id
                  and analysis_group_id     = NVL(l_Anal_Opt_Rec.Bsc_Analysis_Group_Id, 1)
                  and option_id             = l_Anal_Opt_Rec.Bsc_Analysis_Option_Id
                  and parent_option_id      = l_Anal_Opt_Rec.Bsc_Parent_Option_Id;
            ELSE
                delete from BSC_KPI_ANALYSIS_OPTIONS_B
                 where indicator            = l_Anal_Opt_Rec.Bsc_Kpi_Id
                  and analysis_group_id     = NVL(l_Anal_Opt_Rec.Bsc_Analysis_Group_Id, 0)
                  and option_id             = l_Anal_Opt_Rec.Bsc_Analysis_Option_Id;

                delete from BSC_KPI_ANALYSIS_OPTIONS_TL
                 where indicator            = l_Anal_Opt_Rec.Bsc_Kpi_Id
                  and analysis_group_id     = NVL(l_Anal_Opt_Rec.Bsc_Analysis_Group_Id, 0)
                  and option_id             = l_Anal_Opt_Rec.Bsc_Analysis_Option_Id;
            END IF;
        END IF;
        BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Measures( p_commit
                             ,l_Anal_Opt_Rec
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data);

        --BSC_ANALYSIS_OPTION_PVT.Swap_Option_Id(  p_Kpi_Id    =>   l_Anal_Opt_Rec.Bsc_Kpi_Id);
        BSC_ANALYSIS_OPTION_PVT.Swap_Option_Id
        (   p_Kpi_Id                  =>  l_Anal_Opt_Rec.Bsc_Kpi_Id
          , p_group_id                =>  l_Anal_Opt_Rec.Bsc_Analysis_Group_Id
          , p_parent_option_Id        =>  NVL(l_Parent_Opt_Id, 0)
          , p_grand_parent_option_Id  =>  NVL(l_Gra_Parent_Opt_Id, 0)
        );
        BSC_ANALYSIS_OPTION_PVT.Set_Default_Value
        (   p_Kpi_Id                  =>  l_Anal_Opt_Rec.Bsc_Kpi_Id
          , p_group_id                =>  l_Anal_Opt_Rec.Bsc_Analysis_Group_Id
          , p_parent_option_Id        =>  NVL(l_Parent_Opt_Id, 0)
          , p_grand_parent_option_Id  =>  NVL(l_Gra_Parent_Opt_Id, 0)
          , p_option_Id               =>  NVL(l_Anal_Opt_Rec.Bsc_Analysis_Option_Id,0)
        );
        -- update default option for the shared KPIs
        BSC_KPI_PVT.Set_Default_Option
        (    p_commit                =>   FND_API.G_FALSE
          ,  p_Bsc_Kpi_Entity_Rec    =>   l_Bsc_Kpi_Entity_Rec
          ,  x_return_status         =>   x_return_status
          ,  x_msg_count             =>   x_msg_count
          ,  x_msg_data              =>   x_msg_data
        );
    END LOOP;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteBSCAnaOptPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteBSCAnaOptPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteBSCAnaOptPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteBSCAnaOptPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Options ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Delete_Analysis_Options;

/************************************************************************************
************************************************************************************/

--:     This procedure assigns the given measure to the given analysis option.
--:     This procedure is part of the Analysis Option API.

procedure Create_Analysis_Measures(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_count             number;

begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT CreateBSCAnaMeasPVT;
  -- Check that valid Kpi id was entered.
  if p_Anal_Opt_Rec.Bsc_Kpi_Id is not null then
    /*l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Anal_Opt_Rec.Bsc_Kpi_Id);*/
     SELECT COUNT(0)
     INTO   l_count
     FROM   BSC_KPIS_B
     WHERE INDICATOR = p_Anal_Opt_Rec.Bsc_Kpi_Id;
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;


  -- If the Option Id is zero for all groups then there is nothing to do.
  if (p_Anal_Opt_Rec.Bsc_Option_Group0 = 0 and
      p_Anal_Opt_Rec.Bsc_Option_Group1 = 0 and
      p_Anal_Opt_Rec.Bsc_Option_Group2 = 0 and
      p_Anal_Opt_Rec.Bsc_Dataset_Series_Id = 0 and
      p_Anal_Opt_Rec.Bsc_New_Kpi <> 'Y') then

     FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_OPTION_ID');
     FND_MESSAGE.SET_TOKEN('BSC_OPTION', p_Anal_Opt_Rec.Bsc_Option_Group0);
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;

  else

    g_db_object := 'BSC_KPI_ANALYSIS_MEASURES_B';

    -- Insert pertaining values into table bsc_kpi_analysis_measures_b.
    insert into BSC_KPI_ANALYSIS_MEASURES_B( indicator
                                            ,ANALYSIS_OPTION0
                                            ,ANALYSIS_OPTION1
                                            ,ANALYSIS_OPTION2
                                            ,SERIES_ID
                                            ,DATASET_ID
                                            ,AXIS
                                            ,SERIES_TYPE
                                            ,STACK_SERIES_ID
                                            ,BM_FLAG
                                            ,BUDGET_FLAG
                                            ,DEFAULT_VALUE
                                            ,SERIES_COLOR
                                            ,BM_COLOR
                                            ,PROTOTYPE_FLAG
                                            ,KPI_MEASURE_ID)
                                     values( p_Anal_Opt_Rec.Bsc_Kpi_Id
                                            ,p_Anal_Opt_Rec.Bsc_Option_Group0
                                            ,p_Anal_Opt_Rec.Bsc_Option_Group1
                                            ,p_Anal_Opt_Rec.Bsc_Option_Group2
                                            ,p_Anal_Opt_Rec.Bsc_Dataset_Series_Id
                                            ,p_Anal_Opt_Rec.Bsc_Dataset_Id
                                            ,p_Anal_Opt_Rec.Bsc_Dataset_Axis
                                            ,p_Anal_Opt_Rec.Bsc_Dataset_Series_Type
                                            ,p_Anal_Opt_Rec.Bsc_Dataset_Stack_Series_Id
                                            ,p_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag
                                            ,p_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag
                                            ,p_Anal_Opt_Rec.Bsc_Dataset_Default_Value
                                            ,p_Anal_Opt_Rec.Bsc_Dataset_Series_Color
                                            ,p_Anal_Opt_Rec.Bsc_Dataset_Bm_Color
                                            ,p_Anal_Opt_Rec.Bsc_Measure_Prototype_Flag
                                            ,p_Anal_Opt_Rec.Bsc_Kpi_Measure_Id);

    g_db_object := 'BSC_KPI_ANALYSIS_MEASURES_TL';

    -- Insert pertaining values into table bsc_kpi_analysis_measures_tl.
    insert into BSC_KPI_ANALYSIS_MEASURES_TL( indicator
                                             ,analysis_option0
                                             ,analysis_option1
                                             ,analysis_option2
                                             ,series_id
                                             ,language
                                             ,source_lang
                                             ,name
                                             ,help)
                                      select  p_Anal_Opt_Rec.Bsc_Kpi_Id
                                             ,p_Anal_Opt_Rec.Bsc_Option_Group0
                                             ,p_Anal_Opt_Rec.Bsc_Option_Group1
                                             ,p_Anal_Opt_Rec.Bsc_Option_Group2
                                             ,p_Anal_Opt_Rec.Bsc_Dataset_Series_Id
                                             ,L.LANGUAGE_CODE
                                             ,userenv('LANG')
                                             ,p_Anal_Opt_Rec.Bsc_Measure_Long_Name
                                             ,p_Anal_Opt_Rec.Bsc_Measure_Help
                                         from FND_LANGUAGES L
                                        where L.INSTALLED_FLAG in ('I', 'B')
                                          and not exists
                                              (select NULL
                                                 from BSC_KPI_ANALYSIS_MEASURES_TL T
                                                where T.indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id
                                                  and T.analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
                                                  and T.analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
                                                  and T.analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2
                                                  and T.series_id = p_Anal_Opt_Rec.Bsc_Dataset_Series_Id
                                                  and T.LANGUAGE = L.LANGUAGE_CODE);

    if (p_commit = FND_API.G_TRUE) then
      commit;
    end if;

  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCAnaMeasPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCAnaMeasPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCAnaMeasPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Create_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Create_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCAnaMeasPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Create_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Create_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Create_Analysis_Measures;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Analysis_Measures
(
    p_commit              IN                varchar2 -- :=  FND_API.G_FALSE
 ,  p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,  x_Anal_Opt_Rec        IN  OUT NOCOPY      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,  x_return_status           OUT NOCOPY     varchar2
 ,  x_msg_count               OUT NOCOPY     number
 ,  x_msg_data                OUT NOCOPY     varchar2
) is
begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   g_db_object := 'Retrieve_Analysis_Measures';
  IF (p_Anal_Opt_Rec.Bsc_Dataset_Series_Id IS NULL) THEN
    select distinct  series_id
                    ,dataset_id
                    ,axis
                    ,series_type
                    ,stack_series_id
                    ,bm_flag
                    ,budget_flag
                    ,default_value
                    ,series_color
                    ,bm_color
                    ,prototype_flag
                    ,name
                    ,help
                    ,kpi_measure_id
               into  x_Anal_Opt_Rec.Bsc_Dataset_Series_Id
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Id
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Axis
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Series_Type
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Stack_Series_Id
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Default_Value
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Series_Color
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Bm_Color
                    ,x_Anal_Opt_Rec.Bsc_Measure_Prototype_Flag
                    ,x_Anal_Opt_Rec.Bsc_Measure_Long_Name
                    ,x_Anal_Opt_Rec.Bsc_Measure_Help
                    ,x_Anal_Opt_Rec.Bsc_Kpi_Measure_Id
               from  BSC_KPI_ANALYSIS_MEASURES_VL
              where indicator        = p_Anal_Opt_Rec.Bsc_Kpi_Id
                and analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
                and analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
                and analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2;
  ELSE

     select distinct dataset_id
                    ,axis
                    ,series_type
                    ,stack_series_id
                    ,bm_flag
                    ,budget_flag
                    ,default_value
                    ,series_color
                    ,bm_color
                    ,prototype_flag
                    ,name
                    ,help
               into  x_Anal_Opt_Rec.Bsc_Dataset_Id
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Axis
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Series_Type
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Stack_Series_Id
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Default_Value
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Series_Color
                    ,x_Anal_Opt_Rec.Bsc_Dataset_Bm_Color
                    ,x_Anal_Opt_Rec.Bsc_Measure_Prototype_Flag
                    ,x_Anal_Opt_Rec.Bsc_Measure_Long_Name
                    ,x_Anal_Opt_Rec.Bsc_Measure_Help
               from  BSC_KPI_ANALYSIS_MEASURES_VL
              where indicator        = p_Anal_Opt_Rec.Bsc_Kpi_Id
                and analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
                and analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
                and analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2
                and series_id        = p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;

  END IF;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

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
        FND_MSG_PUB.Initialize;
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_VALUE_FOUND');
        FND_MESSAGE.SET_TOKEN('BSC_OBJECT', g_db_object);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Retrieve_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Retrieve_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Retrieve_Analysis_Measures;

/************************************************************************************
************************************************************************************/

procedure Update_Analysis_Measures
(
    p_commit              IN            varchar2 -- :=  FND_API.G_FALSE
  , p_Anal_Opt_Rec        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
) is
  l_Anal_Opt_Rec                BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
  l_count                         number;
  l_source                      BSC_SYS_DATASETS_B.SOURCE%TYPE;
  l_sname                       BSC_KPIS_B.SHORT_NAME%TYPE;
  l_kpi_measure_id              BSC_KPI_ANALYSIS_MEASURES_B.KPI_MEASURE_ID%TYPE;
  l_dataset_color_change        BOOLEAN := FALSE;
  l_old_color_method            bsc_sys_datasets_b.color_method%TYPE;
  l_new_color_method            bsc_sys_datasets_b.color_method%TYPE;
begin
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT UpdateBSCAnaMeasPVT;
  -- Check that valid Kpi id was entered.
  if p_Anal_Opt_Rec.Bsc_Kpi_Id is not null then
    /*l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       ,p_Anal_Opt_Rec.Bsc_Kpi_Id); */
    SELECT COUNT(0)
     INTO   l_count
     FROM   BSC_KPIS_B
     WHERE INDICATOR = p_Anal_Opt_Rec.Bsc_Kpi_Id;
    if l_count = 0 then
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- Not all values will be passed.  We need to make sure values not passed are not
  -- changed by procedure, therefore we get what is there before we do any updates.
  Retrieve_Analysis_Measures ( p_commit
                              ,p_Anal_Opt_Rec
                              ,l_Anal_Opt_Rec
                              ,x_return_status
                              ,x_msg_count
                              ,x_msg_data);

  -- update LOCAL language ,source language, group id and level Id values with PASSED values.
  l_Anal_Opt_Rec.Bsc_Language := p_Anal_Opt_Rec.Bsc_Language;
  l_Anal_Opt_Rec.Bsc_Source_Language := p_Anal_Opt_Rec.Bsc_Source_Language;
  l_Anal_Opt_Rec.Bsc_Kpi_Id := p_Anal_Opt_Rec.Bsc_Kpi_Id;
  l_Anal_Opt_Rec.Bsc_Option_Group0 := p_Anal_Opt_Rec.Bsc_Option_Group0;
  l_Anal_Opt_Rec.Bsc_Option_Group1 := p_Anal_Opt_Rec.Bsc_Option_Group1;
  l_Anal_Opt_Rec.Bsc_Option_Group2 := p_Anal_Opt_Rec.Bsc_Option_Group2;


  -- Copy PASSED Record values into LOCAL Record values for the PASSED Record values
  -- which are NOT NULL.
  if p_Anal_Opt_Rec.Bsc_Dataset_Series_Id is not null then
    l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;
  end if;
  if p_Anal_Opt_Rec.Bsc_Dataset_Id is not null then
    if l_Anal_Opt_Rec.Bsc_Dataset_Id <> p_Anal_Opt_Rec.Bsc_Dataset_Id then

      SELECT color_method
      INTO   l_old_color_method
      FROM   bsc_sys_datasets_b
      WHERE  dataset_id = p_Anal_Opt_Rec.Bsc_Dataset_Id;

      SELECT color_method
      INTO   l_new_color_method
      FROM   bsc_sys_datasets_b
      WHERE  dataset_id = l_Anal_Opt_Rec.Bsc_Dataset_Id;

      -- ppandey - Even if dataset id is changed, reset the color method
      --           only if color method of two dataset are different.
      IF(l_old_color_method <> l_new_color_method) THEN
        l_dataset_color_change := TRUE;
      END IF;

      l_Anal_Opt_Rec.Bsc_Dataset_Id := p_Anal_Opt_Rec.Bsc_Dataset_Id;

      -- Set Objective Structural Change

      SELECT source
      INTO   l_source
      FROM bsc_sys_datasets_b
      WHERE  dataset_id = p_Anal_Opt_Rec.Bsc_Dataset_Id;

      SELECT SHORT_NAME
      INTO   l_sname
      FROM BSC_KPIS_B
      WHERE INDICATOR = l_Anal_Opt_Rec.Bsc_Kpi_Id;

      IF (p_Anal_Opt_Rec.Bsc_Change_Action_Flag = FND_API.G_TRUE AND ((l_source = 'BSC') OR (l_sname IS NOT NULL) )) THEN
        BSC_DESIGNER_PVT.ActionFlag_Change( l_Anal_Opt_Rec.Bsc_Kpi_Id ,
                             BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure );
      END IF;
    end if;
  end if;
  if p_Anal_Opt_Rec.Bsc_Dataset_Axis is not null then
    l_Anal_Opt_Rec.Bsc_Dataset_Axis := p_Anal_Opt_Rec.Bsc_Dataset_Axis;
  end if;
  if p_Anal_Opt_Rec.Bsc_Dataset_Series_Type is not null then
    l_Anal_Opt_Rec.Bsc_Dataset_Series_Type := p_Anal_Opt_Rec.Bsc_Dataset_Series_Type;
  end if;
  l_Anal_Opt_Rec.Bsc_Dataset_Stack_Series_Id := p_Anal_Opt_Rec.Bsc_Dataset_Stack_Series_Id;
  if p_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag is not null then
    l_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag := p_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag;
  end if;
  if p_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag is not null then
    l_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag := p_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag;
  end if;

  if p_Anal_Opt_Rec.Bsc_Dataset_Default_Value is not null then
    l_Anal_Opt_Rec.Bsc_Dataset_Default_Value := p_Anal_Opt_Rec.Bsc_Dataset_Default_Value;
  end if;

  if p_Anal_Opt_Rec.Bsc_Dataset_Series_Color is not null then
    l_Anal_Opt_Rec.Bsc_Dataset_Series_Color := p_Anal_Opt_Rec.Bsc_Dataset_Series_Color;
  end if;
  if p_Anal_Opt_Rec.Bsc_Dataset_Bm_Color is not null then
    l_Anal_Opt_Rec.Bsc_Dataset_Bm_Color := p_Anal_Opt_Rec.Bsc_Dataset_Bm_Color;
  end if;
  if p_Anal_Opt_Rec.Bsc_Measure_Prototype_Flag is not null then
    l_Anal_Opt_Rec.Bsc_Measure_Prototype_Flag := p_Anal_Opt_Rec.Bsc_Measure_Prototype_Flag;
  end if;
  if p_Anal_Opt_Rec.Bsc_Measure_Long_Name is not null then
    l_Anal_Opt_Rec.Bsc_Measure_Long_Name := p_Anal_Opt_Rec.Bsc_Measure_Long_Name;
  end if;
  if p_Anal_Opt_Rec.Bsc_Measure_Help is not null then
    l_Anal_Opt_Rec.Bsc_Measure_Help := p_Anal_Opt_Rec.Bsc_Measure_Help;
  end if;
  IF (p_Anal_Opt_Rec.Bsc_Dataset_Series_Id IS NULL) THEN
      update BSC_KPI_ANALYSIS_MEASURES_B
         set series_id = l_Anal_Opt_Rec.Bsc_Dataset_Series_Id
            ,dataset_id = l_Anal_Opt_Rec.Bsc_Dataset_Id
            ,axis = l_Anal_Opt_Rec.Bsc_Dataset_Axis
            ,series_type = l_Anal_Opt_Rec.Bsc_Dataset_Series_Type
            ,stack_series_id = l_Anal_Opt_Rec.Bsc_Dataset_Stack_Series_Id
            ,bm_flag = l_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag
            ,budget_flag = l_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag
            ,default_value = l_Anal_Opt_Rec.Bsc_Dataset_Default_Value
            ,series_color = l_Anal_Opt_Rec.Bsc_Dataset_Series_Color
            ,bm_color = l_Anal_Opt_Rec.Bsc_Dataset_Bm_Color
            ,prototype_flag = l_Anal_Opt_Rec.Bsc_Measure_Prototype_Flag
      where indicator = l_Anal_Opt_Rec.Bsc_Kpi_Id
        and analysis_option0 = l_Anal_Opt_Rec.Bsc_Option_Group0
        and analysis_option1 = l_Anal_Opt_Rec.Bsc_Option_Group1
        and analysis_option2 = l_Anal_Opt_Rec.Bsc_Option_Group2;

      update BSC_KPI_ANALYSIS_MEASURES_TL
         set name = l_Anal_Opt_Rec.Bsc_Measure_Long_Name
            ,help = l_Anal_Opt_Rec.Bsc_Measure_Help
            ,source_lang = userenv('LANG')
      where indicator = l_Anal_Opt_Rec.Bsc_Kpi_Id
        and analysis_option0 = l_Anal_Opt_Rec.Bsc_Option_Group0
        and analysis_option1 = l_Anal_Opt_Rec.Bsc_Option_Group1
        and analysis_option2 = l_Anal_Opt_Rec.Bsc_Option_Group2
        and indicator = l_Anal_Opt_Rec.Bsc_Kpi_Id
        and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  ELSE
      update BSC_KPI_ANALYSIS_MEASURES_B
         set series_id          = l_Anal_Opt_Rec.Bsc_Dataset_Series_Id
            ,dataset_id         = l_Anal_Opt_Rec.Bsc_Dataset_Id
            ,axis               = l_Anal_Opt_Rec.Bsc_Dataset_Axis
            ,series_type        = l_Anal_Opt_Rec.Bsc_Dataset_Series_Type
            ,stack_series_id    = l_Anal_Opt_Rec.Bsc_Dataset_Stack_Series_Id
            ,bm_flag            = l_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag
            ,budget_flag        = l_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag
            ,default_value      = l_Anal_Opt_Rec.Bsc_Dataset_Default_Value
            ,series_color       = l_Anal_Opt_Rec.Bsc_Dataset_Series_Color
            ,bm_color           = l_Anal_Opt_Rec.Bsc_Dataset_Bm_Color
            ,prototype_flag     = l_Anal_Opt_Rec.Bsc_Measure_Prototype_Flag
      where indicator           = l_Anal_Opt_Rec.Bsc_Kpi_Id
        and analysis_option0    = l_Anal_Opt_Rec.Bsc_Option_Group0
        and analysis_option1    = l_Anal_Opt_Rec.Bsc_Option_Group1
        and analysis_option2    = l_Anal_Opt_Rec.Bsc_Option_Group2
        and series_id           = l_Anal_Opt_Rec.Bsc_Dataset_Series_Id;

      update BSC_KPI_ANALYSIS_MEASURES_TL
         set name               = l_Anal_Opt_Rec.Bsc_Measure_Long_Name
            ,help               = l_Anal_Opt_Rec.Bsc_Measure_Help
            ,source_lang        = userenv('LANG')
      where indicator           = l_Anal_Opt_Rec.Bsc_Kpi_Id
        and analysis_option0    = l_Anal_Opt_Rec.Bsc_Option_Group0
        and analysis_option1    = l_Anal_Opt_Rec.Bsc_Option_Group1
        and analysis_option2    = l_Anal_Opt_Rec.Bsc_Option_Group2
        and indicator           = l_Anal_Opt_Rec.Bsc_Kpi_Id
        and userenv('LANG')     in (LANGUAGE, SOURCE_LANG)
        and series_id           = l_Anal_Opt_Rec.Bsc_Dataset_Series_Id;

        --DBMS_OUTPUT.PUT_LINE(' l_Anal_Opt_Rec.Bsc_Kpi_Id '||l_Anal_Opt_Rec.Bsc_Kpi_Id);
        --DBMS_OUTPUT.PUT_LINE(' l_Anal_Opt_Rec.Bsc_Option_Group0 '||l_Anal_Opt_Rec.Bsc_Option_Group0);
        --DBMS_OUTPUT.PUT_LINE(' l_Anal_Opt_Rec.Bsc_Option_Group1 '||l_Anal_Opt_Rec.Bsc_Option_Group1);
        --DBMS_OUTPUT.PUT_LINE(' l_Anal_Opt_Rec.Bsc_Option_Group2 '||l_Anal_Opt_Rec.Bsc_Option_Group2);
        --DBMS_OUTPUT.PUT_LINE(' l_Anal_Opt_Rec.Bsc_Dataset_Series_Id '||l_Anal_Opt_Rec.Bsc_Dataset_Series_Id);
        --DBMS_OUTPUT.PUT_LINE(' l_Anal_Opt_Rec.Bsc_Measure_Long_Name '||l_Anal_Opt_Rec.Bsc_Measure_Long_Name);
        --DBMS_OUTPUT.PUT_LINE(' l_Anal_Opt_Rec.Bsc_Dataset_Id '||l_Anal_Opt_Rec.Bsc_Dataset_Id);
        --DBMS_OUTPUT.PUT_LINE(' . ');

  END IF;

  IF (l_dataset_color_change) THEN
    SELECT kpi_measure_id
    INTO   l_kpi_measure_id
    FROM   bsc_kpi_analysis_measures_b
    WHERE  indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id
    AND    dataset_id = l_Anal_Opt_Rec.Bsc_Dataset_Id;

    BSC_COLOR_RANGES_PUB.Delete_Color_Prop_Ranges (p_objective_id    => p_Anal_Opt_Rec.Bsc_Kpi_Id
                                                   ,p_kpi_measure_id => l_kpi_measure_id
                                                   ,p_cascade_shared => TRUE
                                                   ,x_return_status  => x_return_status
                                                   ,x_msg_count      => x_msg_count
                                                   ,x_msg_data       => x_msg_data);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    BSC_COLOR_RANGES_PUB.Create_Def_Color_Prop_Ranges(p_objective_id    => p_Anal_Opt_Rec.Bsc_Kpi_Id
                                                     ,p_kpi_measure_id => l_kpi_measure_id
                                                     ,p_cascade_shared => TRUE
                                                     ,x_return_status  => x_return_status
                                                     ,x_msg_count      => x_msg_count
                                                     ,x_msg_data       => x_msg_data);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateBSCAnaMeasPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateBSCAnaMeasPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateBSCAnaMeasPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Update_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Update_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateBSCAnaMeasPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Update_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Update_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Update_Analysis_Measures;

 --Dont call the private API directly. Color table data depending on the  kpi_measure_id
 --need to be deleted

procedure Delete_Analysis_Measures(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

    l_count             number;

    CURSOR c_GrandParent_Option IS
    SELECT A.Option_ID              Option_Id
        ,  B.Option_ID              Parent_Option_Id
        ,  C.Option_ID              GrandParent_Option_Id
    FROM   BSC_KPI_ANALYSIS_OPTIONS_B  A
        ,  BSC_KPI_ANALYSIS_OPTIONS_B  B
        ,  BSC_KPI_ANALYSIS_OPTIONS_B  C
    WHERE  A.Indicator          = B.Indicator
    AND    A.Indicator          = C.Indicator
    AND    A.Analysis_Group_Id  = 0
    AND    B.Analysis_Group_Id  = 1
    AND    C.Analysis_Group_Id  = 2
    AND    A.Indicator          = p_Anal_Opt_Rec.Bsc_Kpi_Id;

    CURSOR c_Parent_Option IS
    SELECT A.Option_ID              Option_Id
        ,  B.Option_ID              Parent_Option_Id
    FROM   BSC_KPI_ANALYSIS_OPTIONS_B  A
        ,  BSC_KPI_ANALYSIS_OPTIONS_B  B
    WHERE  A.Indicator          = B.Indicator
    AND    A.Analysis_Group_Id  = 0
    AND    B.Analysis_Group_Id  = 1
    AND    A.Indicator          = p_Anal_Opt_Rec.Bsc_Kpi_Id;


    CURSOR c_Grand_Parent_depend IS
    SELECT Dependency_Flag
    FROM   BSC_KPI_ANALYSIS_GROUPS
    WHERE  Indicator         = p_Anal_Opt_Rec.Bsc_Kpi_Id
    AND    Analysis_Group_Id = 2;

    CURSOR c_Parent_depend IS
    SELECT Dependency_Flag
    FROM   BSC_KPI_ANALYSIS_GROUPS
    WHERE  Indicator         = p_Anal_Opt_Rec.Bsc_Kpi_Id
    AND    Analysis_Group_Id = 1;

    l_Parent_Analysis       NUMBER :=  0;
    l_Grand_Parent_Analysis NUMBER :=  0;
    l_Parent_Dependent      NUMBER := -1;
    l_GrandParent_Dependent NUMBER := -1;

    l_parent_Exist          BOOLEAN;
    l_grand_parent_Exist    BOOLEAN;

    l_Temp number;
    l_Delete_Flag           BOOLEAN := FALSE;
BEGIN
    FND_MSG_PUB.Initialize;
    SAVEPOINT DeleteBSCAnaMeasPVT;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Check that valid Kpi id was entered.
    IF (p_Anal_Opt_Rec.Bsc_Kpi_Id IS NOT NULL) THEN
        l_count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B', 'indicator', p_Anal_Opt_Rec.Bsc_Kpi_Id);
        IF (l_count = 0) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
            FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSE
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
        FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Anal_Opt_Rec.Bsc_Kpi_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_Count := 0;
    IF (c_Grand_Parent_depend%ISOPEN) THEN
      CLOSE c_Grand_Parent_depend;
    END IF;
    OPEN c_Grand_Parent_depend;
        FETCH c_Grand_Parent_depend INTO l_GrandParent_Dependent;
        IF (c_Grand_Parent_depend%NOTFOUND) THEN
            l_GrandParent_Dependent := 0;
        END IF;
    CLOSE c_Grand_Parent_depend;

    IF (c_Parent_depend%ISOPEN) THEN
      CLOSE c_Parent_depend;
    END IF;
    OPEN c_Parent_depend;
        FETCH c_Parent_depend INTO l_Parent_Dependent;
        IF (c_Parent_depend%NOTFOUND) THEN
            l_Parent_Dependent := 0;
        END IF;
    CLOSE c_Parent_depend;
    --DBMS_OUTPUT.PUT_LINE('p_Anal_Opt_Rec.Bsc_Analysis_Option_Id    <'||p_Anal_Opt_Rec.Bsc_Analysis_Option_Id||'>');
    --DBMS_OUTPUT.PUT_LINE('p_Anal_Opt_Rec.Bsc_Parent_Option_Id      <'||p_Anal_Opt_Rec.Bsc_Parent_Option_Id||'>');
    --DBMS_OUTPUT.PUT_LINE('p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id <'||p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id||'>');
    --DBMS_OUTPUT.PUT_LINE('l_GrandParent_Dependent                  <'||l_GrandParent_Dependent||'>');
    --DBMS_OUTPUT.PUT_LINE('l_Parent_Dependent                       <'||l_Parent_Dependent||'>');
    IF p_Anal_Opt_Rec.Bsc_Dataset_Series_Id IS NOT NULL THEN
       DELETE FROM BSC_KPI_ANALYSIS_MEASURES_B
         WHERE indicator        = p_Anal_Opt_Rec.Bsc_Kpi_Id
           AND analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
           AND analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
           AND analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2
           AND series_id        = p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;

        DELETE FROM BSC_KPI_ANALYSIS_MEASURES_TL
         WHERE indicator        = p_Anal_Opt_Rec.Bsc_Kpi_Id
           AND analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
           AND analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
           AND analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2
           AND series_id        = p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;
    ELSIF ((p_Anal_Opt_Rec.Bsc_Analysis_Option_Id IS NOT NULL) AND
         (p_Anal_Opt_Rec.Bsc_Parent_Option_Id IS NOT NULL) AND
          (p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id IS NOT NULL)) THEN
        FOR cd IN c_GrandParent_Option LOOP
            SELECT COUNT(*) INTO l_COunt
            FROM   BSC_KPI_ANALYSIS_MEASURES_B
            WHERE  Indicator         =  p_Anal_Opt_Rec.Bsc_Kpi_Id
            AND    analysis_option0  =  cd.Option_Id
            AND    analysis_option1  =  cd.Parent_Option_Id
            AND    analysis_option2  =  cd.GrandParent_Option_Id;
            IF (l_Count <> 0) THEN
                l_Delete_Flag := TRUE;
                l_Count       := 0;
                IF ((l_GrandParent_Dependent > 0) AND (l_Parent_Dependent > 0)) THEN
                    IF ((is_GrandParent_Exists(p_Anal_Opt_Rec.Bsc_Kpi_Id, cd.Option_Id, 2)) AND
                         (is_Parent_Exists(p_Anal_Opt_Rec.Bsc_Kpi_Id, cd.Parent_Option_Id, 2))) THEN
                        SELECT COUNT(*) INTO l_Count
                        FROM   BSC_KPI_ANALYSIS_OPTIONS_B  A
                            ,  BSC_KPI_ANALYSIS_MEASURES_B D
                        WHERE  D.Indicator             = A.Indicator
                        AND    A.Analysis_Group_Id     = 2
                        AND    A.Option_Id             = D.Analysis_Option2
                        AND    A.Parent_Option_Id      = D.Analysis_Option1
                        AND    A.GrandParent_Option_Id = D.Analysis_Option0
                        AND    D.Indicator             = p_Anal_Opt_Rec.Bsc_Kpi_Id
                        AND    D.Analysis_Option0      = cd.Option_Id
                        AND    D.Analysis_Option1      = cd.Parent_Option_Id
                        AND    D.Analysis_Option2      = cd.GrandParent_Option_Id;

                        l_Parent_Analysis       :=  cd.Parent_Option_Id;
                        l_Grand_Parent_Analysis :=  cd.GrandParent_Option_Id;
                    ELSE
                        l_Count := 1;
                        l_Parent_Analysis       :=  cd.Parent_Option_Id;
                        l_Grand_Parent_Analysis :=  cd.GrandParent_Option_Id;
                        IF (is_Parent_Exists(p_Anal_Opt_Rec.Bsc_Kpi_Id, cd.Parent_Option_Id, 2)) THEN
                            IF(is_not_Child(p_Anal_Opt_Rec.Bsc_Kpi_Id, cd.Option_Id,cd.Parent_Option_Id, 1)) THEN
                                l_Parent_Analysis     :=  0;
                            END IF;
                        ELSIF(is_not_Child(p_Anal_Opt_Rec.Bsc_Kpi_Id, cd.Option_Id,cd.Parent_Option_Id, 1)) THEN
                           l_Parent_Analysis          :=  0;
                        END IF;
                        IF (NOT is_GrandParent_Exists(p_Anal_Opt_Rec.Bsc_Kpi_Id, cd.Option_Id, 2)) THEN
                            l_Grand_Parent_Analysis   :=  0;
                        END IF;
                    END IF;
                    --DBMS_OUTPUT.PUT_LINE('BOTH -- 0 <'||l_Count||'>   <'||cd.Option_Id||'>  <'||cd.Parent_Option_Id||'>  <'||cd.GrandParent_Option_Id||'>');
                ELSIF (l_Parent_Dependent > 0) THEN
                    IF (is_Parent_Exists(p_Anal_Opt_Rec.Bsc_Kpi_Id, cd.Option_Id, 1)) THEN
                        SELECT COUNT(*) INTO l_Count
                        FROM   BSC_KPI_ANALYSIS_OPTIONS_B  A
                            ,  BSC_KPI_ANALYSIS_MEASURES_B D
                        WHERE  D.Indicator             = A.Indicator
                        AND    A.Analysis_Group_Id     = 1
                        AND    A.Option_Id             = D.Analysis_Option1
                        AND    A.Parent_Option_Id      = D.Analysis_Option0
                        AND    D.Indicator             = p_Anal_Opt_Rec.Bsc_Kpi_Id
                        AND    D.Analysis_Option0      = cd.Option_Id
                        AND    D.Analysis_Option1      = cd.Parent_Option_Id;
                        l_Parent_Analysis       :=  cd.Parent_Option_Id;
                        l_Grand_Parent_Analysis :=  cd.GrandParent_Option_Id;
                    ELSE
                        l_Count := 1;
                        l_Parent_Analysis       :=  0;
                        l_Grand_Parent_Analysis :=  cd.GrandParent_Option_Id;
                    END IF;
                    --DBMS_OUTPUT.PUT_LINE('L_PARENT_DEPENDENT -- <'||l_Count||'>   <'||cd.Option_Id||'>  <'||cd.Parent_Option_Id||'>  <'||cd.GrandParent_Option_Id||'>');
                ELSIF (l_GrandParent_Dependent > 0) THEN
                    IF (is_Parent_Exists(p_Anal_Opt_Rec.Bsc_Kpi_Id, cd.Parent_Option_Id, 2)) THEN
                        SELECT COUNT(*) INTO l_Count
                        FROM   BSC_KPI_ANALYSIS_OPTIONS_B  A
                            ,  BSC_KPI_ANALYSIS_MEASURES_B D
                        WHERE  D.Indicator             = A.Indicator
                        AND    A.Analysis_Group_Id     = 2
                        AND    A.Parent_Option_Id      = D.Analysis_Option1
                        AND    A.GrandParent_Option_Id = 0
                        AND    D.Indicator             = p_Anal_Opt_Rec.Bsc_Kpi_Id
                        AND    D.Analysis_Option1      = cd.Parent_Option_Id
                        AND    D.Analysis_Option2      = cd.GrandParent_Option_Id;

                        l_Parent_Analysis       :=  cd.Parent_Option_Id;
                        l_Grand_Parent_Analysis :=  cd.GrandParent_Option_Id;
                        IF(is_not_Child(p_Anal_Opt_Rec.Bsc_Kpi_Id, cd.Parent_Option_Id,cd.GrandParent_Option_Id, 2)) THEN
                            l_Grand_Parent_Analysis     :=  0;
                        END IF;

                    ELSE
                        l_Count := 1;
                        l_Parent_Analysis       :=  cd.Parent_Option_Id;
                        l_Grand_Parent_Analysis :=  cd.GrandParent_Option_Id;
                    END IF;
                    --DBMS_OUTPUT.PUT_LINE('L_GRANDPARENT_DEPENDENT -- <'||l_Count||'>   <'||cd.Option_Id||'>  <'||cd.Parent_Option_Id||'>  <'||cd.GrandParent_Option_Id||'>');
                END IF;
                IF (((l_Parent_Dependent = 0) AND (l_GrandParent_Dependent = 0)) OR (l_Count <> 0)) THEN
                    IF((l_Parent_Dependent = 0) AND (l_GrandParent_Dependent = 0)) THEN
                        l_Parent_Analysis       :=  cd.Parent_Option_Id;
                        l_Grand_Parent_Analysis :=  cd.GrandParent_Option_Id;
                    END IF;
                    UPDATE BSC_KPI_ANALYSIS_MEASURES_B
                    SET    Indicator         = -999
                    WHERE  Indicator         =  p_Anal_Opt_Rec.Bsc_Kpi_Id
                    AND    analysis_option0  =  cd.Option_Id
                    AND    analysis_option1  =  l_Parent_Analysis
                    AND    analysis_option2  =  l_Grand_Parent_Analysis;

                    UPDATE BSC_KPI_ANALYSIS_MEASURES_TL
                    SET    Indicator         = -999
                    WHERE  Indicator         =  p_Anal_Opt_Rec.Bsc_Kpi_Id
                    AND    analysis_option0  =  cd.Option_Id
                    AND    analysis_option1  =  l_Parent_Analysis
                    AND    analysis_option2  =  l_Grand_Parent_Analysis;
                    --DBMS_OUTPUT.PUT_LINE('INDEPENDENT -- <'||l_Count||'>   <'||cd.Option_Id||'>  <'||cd.Parent_Option_Id||'>  <'||cd.GrandParent_Option_Id||'>');
                END IF;
            END IF;
        END LOOP;
        IF (l_Delete_Flag) THEN
            DELETE FROM BSC_KPI_ANALYSIS_MEASURES_B
            WHERE  Indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id;

            DELETE FROM BSC_KPI_ANALYSIS_MEASURES_TL
            WHERE  Indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id;

            UPDATE BSC_KPI_ANALYSIS_MEASURES_B
            SET    Indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id
            WHERE  Indicator = -999;

            UPDATE BSC_KPI_ANALYSIS_MEASURES_TL
            SET    Indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id
            WHERE  Indicator = -999;
        END IF;
    ELSIF ((p_Anal_Opt_Rec.Bsc_Analysis_Option_Id IS NOT NULL) AND
            (p_Anal_Opt_Rec.Bsc_Parent_Option_Id IS NOT NULL)) THEN
        FOR cd IN c_Parent_Option LOOP
            l_Delete_Flag := TRUE;
            IF (l_Parent_Dependent = -1) THEN
                SELECT Dependency_Flag INTO l_Parent_Dependent
                FROM   BSC_KPI_ANALYSIS_GROUPS
                WHERE  Indicator         = p_Anal_Opt_Rec.Bsc_Kpi_Id
                AND    Analysis_Group_Id = 1;

                SELECT  COUNT(*)
                INTO l_count
                FROM BSC_KPI_ANALYSIS_OPTIONS_B
                WHERE INDICATOR = p_Anal_Opt_Rec.Bsc_Kpi_Id
                AND Analysis_Group_Id = 1;
            END IF;
            IF (l_Parent_Dependent > 0) THEN
                IF (is_Parent_Exists(p_Anal_Opt_Rec.Bsc_Kpi_Id, cd.Option_Id, 1)) THEN
                    SELECT COUNT(*) INTO l_Count
                    FROM   BSC_KPI_ANALYSIS_OPTIONS_B  A
                        ,  BSC_KPI_ANALYSIS_MEASURES_B D
                    WHERE  D.Indicator             = A.Indicator
                    AND    A.Analysis_Group_Id     = 1
                    AND    A.Option_Id             = D.Analysis_Option1
                    AND    A.Parent_Option_Id      = D.Analysis_Option0
                    AND    D.Indicator             = p_Anal_Opt_Rec.Bsc_Kpi_Id
                    AND    D.Analysis_Option0      = cd.Option_Id
                    AND    D.Analysis_Option1      = cd.Parent_Option_Id;
                    l_Parent_Analysis := cd.Parent_Option_Id;
                ELSE
                    l_Count           := 1;
                    l_Parent_Analysis := 0;
                END IF;
            END IF;
            IF ((l_Parent_Dependent = 0) OR (l_Count <> 0)) THEN
                IF(l_Parent_Dependent = 0) THEN
                   l_Parent_Analysis  :=  cd.Parent_Option_Id;
                END IF;

                UPDATE BSC_KPI_ANALYSIS_MEASURES_B
                SET    Indicator         = -999
                WHERE  Indicator         =  p_Anal_Opt_Rec.Bsc_Kpi_Id
                AND    analysis_option0  =  cd.Option_Id
                AND    analysis_option1  =  l_Parent_Analysis
                AND    analysis_option2  =  0;

                UPDATE BSC_KPI_ANALYSIS_MEASURES_TL
                SET    Indicator         = -999
                WHERE  Indicator         =  p_Anal_Opt_Rec.Bsc_Kpi_Id
                AND    analysis_option0  =  cd.Option_Id
                AND    analysis_option1  =  l_Parent_Analysis
                AND    analysis_option2  =  0;
            END IF;
        END LOOP;
        IF (l_Delete_Flag) THEN
            DELETE FROM BSC_KPI_ANALYSIS_MEASURES_B
            WHERE  Indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id;

            DELETE FROM BSC_KPI_ANALYSIS_MEASURES_TL
            WHERE  Indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id;

            UPDATE BSC_KPI_ANALYSIS_MEASURES_B
            SET    Indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id
            WHERE  Indicator = -999;

            UPDATE BSC_KPI_ANALYSIS_MEASURES_TL
            SET    Indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id
            WHERE  Indicator = -999;
        END IF;
    ELSE
        DELETE FROM BSC_KPI_ANALYSIS_MEASURES_B
         WHERE indicator        = p_Anal_Opt_Rec.Bsc_Kpi_Id
           AND analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
           AND analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
           AND analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2;

        DELETE FROM BSC_KPI_ANALYSIS_MEASURES_TL
         WHERE indicator        = p_Anal_Opt_Rec.Bsc_Kpi_Id
           AND analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
           AND analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
           AND analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
    --DBMS_OUTPUT.PUT_LINE('coming out Delete_Analysis_Measures ');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_Grand_Parent_depend%ISOPEN) THEN
          CLOSE c_Grand_Parent_depend;
        END IF;
        IF (c_Parent_depend%ISOPEN) THEN
          CLOSE c_Parent_depend;
        END IF;
        ROLLBACK TO DeleteBSCAnaMeasPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_Grand_Parent_depend%ISOPEN) THEN
          CLOSE c_Grand_Parent_depend;
        END IF;
        IF (c_Parent_depend%ISOPEN) THEN
          CLOSE c_Parent_depend;
        END IF;
        ROLLBACK TO DeleteBSCAnaMeasPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        IF (c_Grand_Parent_depend%ISOPEN) THEN
          CLOSE c_Grand_Parent_depend;
        END IF;
        IF (c_Parent_depend%ISOPEN) THEN
          CLOSE c_Parent_depend;
        END IF;
        ROLLBACK TO DeleteBSCAnaMeasPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        IF (c_Grand_Parent_depend%ISOPEN) THEN
          CLOSE c_Grand_Parent_depend;
        END IF;
        IF (c_Parent_depend%ISOPEN) THEN
          CLOSE c_Parent_depend;
        END IF;
        ROLLBACK TO DeleteBSCAnaMeasPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Measures ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Delete_Analysis_Measures;

/************************************************************************************
************************************************************************************/

FUNCTION Delete_Analysis_Option
(       p_kpi_id              IN            NUMBER
    ,   p_anal_option_id      IN            NUMBER
    ,   x_return_status       OUT NOCOPY    VARCHAR2
    ,   x_msg_count           OUT NOCOPY    NUMBER
    ,   x_msg_data            OUT NOCOPY    VARCHAR2
    ,   p_anal_group_id       IN            NUMBER      DEFAULT 0
) RETURN VARCHAR2
IS
    -- This function checks if an analysis option may be deleted.  The checks are: If
    -- this is the last analysis Option then it may not be deleted. If it is used by a
    -- shared KPI then  if it is being displayed then it may not be deleted.  Any other
    -- result allows deletion.
    l_kpi_id            NUMBER;
    l_value             NUMBER;  -- This variable will be used to store values
                                         -- for number of items, or for value of the
                                         -- shared flag, or for the display value.

    --get shared indicators
    CURSOR  c_kpi_ids IS
    SELECT  DISTINCT A.Indicator
          , B.User_Level1
    FROM    BSC_KPIS_B                  A
       ,    BSC_KPI_ANALYSIS_OPTIONS_B  B
    WHERE   Source_Indicator    =  p_kpi_id
    AND     A.Indicator         =  B.Indicator
    AND     B.analysis_group_id =  p_anal_group_id
    AND     B.option_id         =  p_anal_option_id
    AND     Prototype_Flag      <> BSC_KPI_PUB.Delete_Kpi_Flag;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- First check if it is a Shared Kpi. If it is then no deletion.
    SELECT  DISTINCT(Share_Flag)
    INTO    l_value
    FROM    BSC_KPIS_B
    WHERE   indicator = p_kpi_id;
    IF (l_value = 2) then
        RETURN 'S';-- it is a shared kpi
    END IF;

    -- Now check that this is not the last analysis Option, if it is then no deletion.
    SELECT  COUNT(option_id)
    INTO    l_value
    FROM    BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE   indicator = p_kpi_id;
    IF (l_value < 2) THEN
        RETURN 'L';
    END IF;

    -- Now find out NOCOPY if the indicator has any shared indicators, if not then deletion
    -- may proceed.
    SELECT  COUNT(indicator)
    INTO    l_value
    FROM    BSC_KPIS_B
    WHERE   source_indicator = p_kpi_id
    AND     Prototype_Flag  <> BSC_KPI_PUB.Delete_Kpi_Flag;
    IF (l_value = 0) then
        RETURN 'Y';
    END IF;

    -- Now, if the analysis has come to this point, then it means that the Analysis Option
    -- belongs to a KPI that it is being shared.  In order to delete, no Shared KPI must be
    -- displaying this Analysis Option.

    -- We need to get the ids for all Shared Kpis for this Master kpi.
    FOR cd IN c_kpi_ids LOOP
        -- if the value is not zero (for any shared KPI) then option may not be deleted.
        IF (cd.User_Level1 <> 0) THEN
            RETURN 'D';
        END IF;
    END LOOP;
    -- If the analysis has come to this point then it means that the Analysis Option
    -- belong to a KPI that is being shared, but none of the Shared KPI is actually
    -- displaying the option therefore it may be deleted.
    RETURN 'Y';
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
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Option ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
end Delete_Analysis_Option;

/**************************************************************************/
PROCEDURE Initialize_Anal_Opt_Tbl
(
        p_Kpi_id             IN            BSC_KPIS_B.indicator%TYPE
   ,    p_Anal_Opt_Tbl       IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type
   ,    p_max_group_count    IN            NUMBER
   ,    p_Anal_Opt_Comb_Tbl  IN            BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
   ,    p_Anal_Det_Opt_Tbl   IN OUT NOCOPY BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Det_Tbl_Type
)IS
   l_group_count            NUMBER;
   l_option_id              BSC_KPI_ANALYSIS_OPTIONS_B.Option_Id%TYPE;
   l_parent_option_id       BSC_KPI_ANALYSIS_OPTIONS_B.Parent_Option_Id%TYPE;
   l_grand_parent_option_id BSC_KPI_ANALYSIS_OPTIONS_B.Grandparent_Option_Id%TYPE;
   l_dependent              BSC_KPI_ANALYSIS_GROUPS.dependency_flag%TYPE;
   l_no_child               NUMBER;
   l_Anal_grp_Id            BSC_KPI_ANALYSIS_OPTIONS_B.Analysis_Group_Id%TYPE;


   CURSOR c_grp_one_details IS
   SELECT Option_Id,Parent_Option_Id,Grandparent_Option_Id
   FROM   BSC_KPI_ANALYSIS_OPTIONS_B
   WHERE  Indicator              = p_Kpi_id
   AND    Analysis_Group_Id      = l_group_count
   AND    Option_Id              = l_option_id
   AND    Parent_Option_Id       = l_parent_option_id;

   CURSOR c_grp_two_details IS
   SELECT Option_Id,Parent_Option_Id,Grandparent_Option_Id
   FROM   BSC_KPI_ANALYSIS_OPTIONS_B
   WHERE  Indicator              = p_Kpi_id
   AND    Analysis_Group_Id      = l_group_count
   AND    Option_Id              = l_option_id
   AND    Parent_Option_Id       = l_parent_option_id
   AND    Grandparent_Option_Id  = l_grand_parent_option_id;


   CURSOR c_grp_zero_details IS
   SELECT Option_Id,Parent_Option_Id,Grandparent_Option_Id
   FROM   BSC_KPI_ANALYSIS_OPTIONS_B
   WHERE  Indicator              = p_Kpi_id
   AND    Analysis_Group_Id      = l_group_count
   AND    Option_Id              = l_option_id;

BEGIN

     l_group_count := 0;

     WHILE( l_group_count <= (p_Anal_Opt_Tbl.COUNT - 1)) LOOP
        IF( l_group_count = 2 ) THEN
          l_option_id               := p_Anal_Opt_Comb_Tbl(l_group_count);
          l_parent_option_id        := p_Anal_Opt_Comb_Tbl(l_group_count - 1);
          l_grand_parent_option_id  := p_Anal_Opt_Comb_Tbl(l_group_count - 2);

          IF(c_grp_two_details%ISOPEN) THEN
            CLOSE c_grp_two_details;
          END IF;

          OPEN c_grp_two_details;
          FETCH c_grp_two_details INTO l_option_id,l_parent_option_id,l_grand_parent_option_id;
          IF(c_grp_two_details%NOTFOUND) THEN
              l_option_id               := p_Anal_Opt_Comb_Tbl(l_group_count);
              l_parent_option_id        := p_Anal_Opt_Comb_Tbl(l_group_count - 1);
              IF(c_grp_one_details%ISOPEN) THEN
                 CLOSE c_grp_two_details;
              END IF;
              OPEN c_grp_one_details;
              FETCH c_grp_one_details INTO l_option_id,l_parent_option_id,l_grand_parent_option_id;
              IF(c_grp_one_details%NOTFOUND) THEN
                 l_option_id              := p_Anal_Opt_Comb_Tbl(l_group_count);
                 l_parent_option_id       := 0;
                 l_grand_parent_option_id := 0;
              END IF;
              CLOSE c_grp_one_details;
          END IF;
          CLOSE c_grp_two_details;

          l_dependent := p_Anal_Opt_Tbl(l_group_count).Bsc_dependency_flag;
          l_no_child  := 0;
        ELSIF( l_group_count = 1)THEN

          IF(c_grp_one_details%ISOPEN) THEN
             CLOSE c_grp_two_details;
          END IF;
          l_option_id                 := p_Anal_Opt_Comb_Tbl(l_group_count);
          l_parent_option_id          := p_Anal_Opt_Comb_Tbl(l_group_count - 1);
          OPEN c_grp_one_details;
          FETCH c_grp_one_details INTO l_option_id,l_parent_option_id,l_grand_parent_option_id;
          IF(c_grp_one_details%NOTFOUND) THEN
             l_option_id              := p_Anal_Opt_Comb_Tbl(l_group_count);
             l_parent_option_id       := 0;
             l_grand_parent_option_id := 0;
          END IF;

          CLOSE c_grp_one_details;

          l_dependent := p_Anal_Opt_Tbl(l_group_count).Bsc_dependency_flag;
          IF (p_Anal_Opt_Tbl.EXISTS(l_group_count + 1) AND (p_Anal_Opt_Tbl(l_group_count + 1).Bsc_dependency_flag =1)) THEN
            l_no_child  := get_number_of_child
                           (  p_Kpi_id            => p_Kpi_id
                             ,p_group_count       => l_group_count
                             ,p_Anal_Opt_Tbl      => p_Anal_Opt_Tbl
                             ,p_Anal_Opt_Comb_Tbl => p_Anal_Opt_Comb_Tbl
                           );

          ELSE
            l_no_child  := 0;
          END IF;
        ELSE
          l_option_id                 := p_Anal_Opt_Comb_Tbl(l_group_count);
          OPEN c_grp_zero_details;
          FETCH c_grp_zero_details INTO l_option_id,l_parent_option_id,l_grand_parent_option_id;
          IF(c_grp_zero_details%NOTFOUND) THEN
             l_option_id              := 0;
             l_parent_option_id       := 0;
             l_grand_parent_option_id := 0;
          END IF;
          CLOSE c_grp_zero_details;


          l_dependent := 0;
          l_no_child  := get_number_of_child
                         (  p_Kpi_id            => p_Kpi_id
                           ,p_group_count       => l_group_count
                           ,p_Anal_Opt_Tbl      => p_Anal_Opt_Tbl
                           ,p_Anal_Opt_Comb_Tbl => p_Anal_Opt_Comb_Tbl
                          );

        END IF;
        p_Anal_Det_Opt_Tbl(l_group_count).Bsc_Option_Id             :=  l_option_id;
        p_Anal_Det_Opt_Tbl(l_group_count).Bsc_Parent_Option_Id      :=  l_parent_option_id;
        p_Anal_Det_Opt_Tbl(l_group_count).Bsc_Grandparent_Option_Id :=  l_grand_parent_option_id;
        p_Anal_Det_Opt_Tbl(l_group_count).Bsc_dependency_flag       :=  l_dependent;
        p_Anal_Det_Opt_Tbl(l_group_count).No_of_child               :=  l_no_child;

        l_group_count := l_group_count + 1;

     END LOOP;

END Initialize_Anal_Opt_Tbl;
/*******************************************************************************/

FUNCTION Validate_If_single_Anal_Opt
(
    p_Anal_Opt_Tbl      IN    BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type

)RETURN BOOLEAN
IS
    l_Anal_Opt_Tbl          BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type;
    l_count                 NUMBER;

BEGIN
    l_Anal_Opt_Tbl      :=  p_Anal_Opt_Tbl;
    l_count             :=  l_Anal_Opt_Tbl.COUNT - 1;
    IF(l_count = 2)THEN
        IF(((l_Anal_Opt_Tbl.EXISTS(l_count))AND(l_Anal_Opt_Tbl(l_count).Bsc_no_option_id =1)AND (l_Anal_Opt_Tbl(l_count).Bsc_dependency_flag =1))) THEN
            IF((l_Anal_Opt_Tbl.EXISTS(l_count -1)) AND (l_Anal_Opt_Tbl(l_count - 1).Bsc_no_option_id =1) AND(l_Anal_Opt_Tbl(l_count - 1).Bsc_dependency_flag =1)) THEN
               IF((l_Anal_Opt_Tbl.EXISTS(l_count-2)) AND (l_Anal_Opt_Tbl(l_count - 2).Bsc_no_option_id =1)) THEN
                 RETURN TRUE;
               END IF;
            END IF;
        END IF;
    ELSE
        IF((l_Anal_Opt_Tbl.EXISTS(l_count))AND(l_Anal_Opt_Tbl(l_count).Bsc_no_option_id =1)AND((l_Anal_Opt_Tbl(l_count).Bsc_dependency_flag =1))) THEN
            IF((l_Anal_Opt_Tbl.EXISTS(l_count -1)) AND (l_Anal_Opt_Tbl(l_count - 1).Bsc_no_option_id =1)) THEN
               RETURN TRUE;
            END IF;
        END IF;
    END IF;
    RETURN  FALSE;
END Validate_If_single_Anal_Opt;

/************************************************************************************

************************************************************************************/

PROCEDURE Delete_Ana_Opt_Mult_Groups
(       p_commit              IN            VARCHAR2:=FND_API.G_FALSE
    ,   p_Kpi_id              IN            BSC_KPIS_B.indicator%TYPE
    ,   p_Anal_Opt_Tbl        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type
    ,   p_max_group_count     IN            NUMBER
    ,   p_Anal_Opt_Comb_Tbl   IN            BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
    ,   p_Anal_Opt_Rec        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    ,   x_return_status       OUT NOCOPY    VARCHAR2
    ,   x_msg_count           OUT NOCOPY    NUMBER
    ,   x_msg_data            OUT NOCOPY    VARCHAR2
)IS
   l_count                  NUMBER;
   l_Anal_Opt_Rec           BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
   l_Source                 VARCHAR2(3) := 'BSC';
   l_parent_option_id       BSC_KPI_ANALYSIS_OPTIONS_B.Parent_Option_Id%TYPE;
   l_Anal_Det_Opt_Tbl       BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Det_Tbl_Type;
   l_anal_opt_name          VARCHAR2(3000);
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT DeleteBSCAnaOptMultGroups;
    l_Anal_Opt_Rec.Bsc_Kpi_Id   := p_Kpi_id;

    IF(Validate_If_single_Anal_Opt(p_Anal_Opt_Tbl)) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_LAST_AO_IN_KPI');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    --BSC_D_NOT_DELETE_AO_DEPEN

    BSC_ANALYSIS_OPTION_PVT.Initialize_Anal_Opt_Tbl
    (
         p_Kpi_id            =>  p_Kpi_id
        ,p_Anal_Opt_Tbl      =>  p_Anal_Opt_Tbl
        ,p_max_group_count   =>  p_max_group_count
        ,p_Anal_Opt_Comb_Tbl =>  p_Anal_Opt_Comb_Tbl
        ,p_Anal_Det_Opt_Tbl  =>  l_Anal_Det_Opt_Tbl
    );

    l_count := l_Anal_Det_Opt_Tbl.COUNT - 1 ;

    l_Anal_Opt_Rec.Bsc_Option_Group0      :=   p_Anal_Opt_Rec.Bsc_Option_Group0;
    l_Anal_Opt_Rec.Bsc_Option_Group1      :=   p_Anal_Opt_Rec.Bsc_Option_Group1;
    l_Anal_Opt_Rec.Bsc_Option_Group2      :=   p_Anal_Opt_Rec.Bsc_Option_Group2;
    l_Anal_Opt_Rec.Bsc_Dataset_Series_Id  :=   p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;

    IF((l_Anal_Det_Opt_Tbl(l_count).Bsc_dependency_flag = 1)AND(l_Anal_Det_Opt_Tbl.EXISTS(l_count-1))AND(l_Anal_Det_Opt_Tbl(l_count-1).No_of_child <>0)) THEN

       IF((l_Anal_Det_Opt_Tbl(l_count-1).No_of_child >1)AND(l_Anal_Det_Opt_Tbl(l_count).Bsc_Option_Id=0)) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_D_NOT_DELETE_AO_DEPEN');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;

       l_Anal_Opt_Rec.Bsc_Analysis_Group_Id        :=  l_count;
       l_Anal_Opt_Rec.Bsc_Analysis_Option_Id       :=  l_Anal_Det_Opt_Tbl(l_count).Bsc_Option_Id            ;
       l_Anal_Opt_Rec.Bsc_Parent_Option_Id         :=  l_Anal_Det_Opt_Tbl(l_count).Bsc_Parent_Option_Id     ;
       l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id    :=  l_Anal_Det_Opt_Tbl(l_count).Bsc_Grandparent_Option_Id;

        BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Options
        (       p_commit              =>    FND_API.G_FALSE
            ,   p_Anal_Opt_Rec        =>    l_Anal_Opt_Rec
            ,   x_return_status       =>    x_return_status
            ,   x_msg_count           =>    x_msg_count
            ,   x_msg_data            =>    x_msg_data
        );

        IF((l_Anal_Det_Opt_Tbl.EXISTS(l_count-1))AND(l_Anal_Det_Opt_Tbl(l_count-1).No_of_child =1)) THEN

           IF((l_Anal_Det_Opt_Tbl(l_count).Bsc_dependency_flag = 1)AND(l_Anal_Det_Opt_Tbl.EXISTS(l_count-2))AND(l_Anal_Det_Opt_Tbl(l_count-2).No_of_child >1)AND(l_Anal_Det_Opt_Tbl(l_count -1).Bsc_Option_Id=0)) THEN
              FND_MESSAGE.SET_NAME('BSC','BSC_D_NOT_DELETE_AO_DEPEN');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END IF;

            l_Anal_Opt_Rec.Bsc_Analysis_Group_Id        :=  l_count -1;
            l_Anal_Opt_Rec.Bsc_Analysis_Option_Id       :=  l_Anal_Det_Opt_Tbl(l_count -1).Bsc_Option_Id            ;
            l_Anal_Opt_Rec.Bsc_Parent_Option_Id         :=  l_Anal_Det_Opt_Tbl(l_count -1).Bsc_Parent_Option_Id     ;
            l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id    :=  l_Anal_Det_Opt_Tbl(l_count -1).Bsc_Grandparent_Option_Id;

            BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Options
            (       p_commit              =>    FND_API.G_FALSE
                ,   p_Anal_Opt_Rec        =>    l_Anal_Opt_Rec
                ,   x_return_status       =>    x_return_status
                ,   x_msg_count           =>    x_msg_count
                ,   x_msg_data            =>    x_msg_data
            );

            IF((l_Anal_Det_Opt_Tbl.EXISTS(l_count-2))AND(l_Anal_Det_Opt_Tbl(l_count-2).No_of_child =1)AND(l_Anal_Det_Opt_Tbl(l_count-1).Bsc_dependency_flag =1)) THEN
                  l_Anal_Opt_Rec.Bsc_Analysis_Group_Id        :=  l_count -2;
                  l_Anal_Opt_Rec.Bsc_Analysis_Option_Id       :=  l_Anal_Det_Opt_Tbl(l_count -2).Bsc_Option_Id            ;
                  l_Anal_Opt_Rec.Bsc_Parent_Option_Id         :=  l_Anal_Det_Opt_Tbl(l_count -2).Bsc_Parent_Option_Id     ;
                  l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id    :=  l_Anal_Det_Opt_Tbl(l_count -2).Bsc_Grandparent_Option_Id;

                  BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Options
                  (       p_commit              =>    FND_API.G_FALSE
                      ,   p_Anal_Opt_Rec        =>    l_Anal_Opt_Rec
                      ,   x_return_status       =>    x_return_status
                      ,   x_msg_count           =>    x_msg_count
                      ,   x_msg_data            =>    x_msg_data
                  );


            END IF;
          END IF;
    ELSIF((l_Anal_Det_Opt_Tbl(l_count).Bsc_dependency_flag = 1)AND(l_Anal_Det_Opt_Tbl.EXISTS(l_count-1))AND(l_Anal_Det_Opt_Tbl(l_count-1).No_of_child =0)) THEN
       IF((l_Anal_Det_Opt_Tbl(l_count-1).Bsc_dependency_flag = 1)AND(l_Anal_Det_Opt_Tbl.EXISTS(l_count-2))AND(l_Anal_Det_Opt_Tbl(l_count-2).No_of_child =0)) THEN

         l_Anal_Opt_Rec.Bsc_Analysis_Group_Id        :=  l_count -2;
         l_Anal_Opt_Rec.Bsc_Analysis_Option_Id       :=  l_Anal_Det_Opt_Tbl(l_count -2).Bsc_Option_Id            ;
         l_Anal_Opt_Rec.Bsc_Parent_Option_Id         :=  l_Anal_Det_Opt_Tbl(l_count -2).Bsc_Parent_Option_Id     ;
         l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id    :=  l_Anal_Det_Opt_Tbl(l_count -2).Bsc_Grandparent_Option_Id;

         BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Options
         (       p_commit              =>    FND_API.G_FALSE
             ,   p_Anal_Opt_Rec        =>    l_Anal_Opt_Rec
             ,   x_return_status       =>    x_return_status
             ,   x_msg_count           =>    x_msg_count
             ,   x_msg_data            =>    x_msg_data
          );
       ELSE
         IF((l_Anal_Det_Opt_Tbl(l_count-1).Bsc_dependency_flag = 1)AND(l_Anal_Det_Opt_Tbl.EXISTS(l_count-2))AND(l_Anal_Det_Opt_Tbl(l_count-2).No_of_child >1)AND(l_Anal_Det_Opt_Tbl(l_count -1).Bsc_Option_Id=0)) THEN
           FND_MESSAGE.SET_NAME('BSC','BSC_D_NOT_DELETE_AO_DEPEN');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_Anal_Opt_Rec.Bsc_Analysis_Group_Id        :=  l_count -1;
         l_Anal_Opt_Rec.Bsc_Analysis_Option_Id       :=  l_Anal_Det_Opt_Tbl(l_count -1).Bsc_Option_Id            ;
         l_Anal_Opt_Rec.Bsc_Parent_Option_Id         :=  l_Anal_Det_Opt_Tbl(l_count -1).Bsc_Parent_Option_Id     ;
         l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id    :=  l_Anal_Det_Opt_Tbl(l_count -1).Bsc_Grandparent_Option_Id;

         BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Options
         (      p_commit              =>    FND_API.G_FALSE
            ,   p_Anal_Opt_Rec        =>    l_Anal_Opt_Rec
            ,   x_return_status       =>    x_return_status
            ,   x_msg_count           =>    x_msg_count
            ,   x_msg_data            =>    x_msg_data
         );




         IF((l_Anal_Det_Opt_Tbl.EXISTS(l_count-2))AND(l_Anal_Det_Opt_Tbl(l_count-2).No_of_child =1)AND(l_Anal_Det_Opt_Tbl(l_count-1).Bsc_dependency_flag =1)) THEN
            l_Anal_Opt_Rec.Bsc_Analysis_Group_Id        :=  l_count -2;
            l_Anal_Opt_Rec.Bsc_Analysis_Option_Id       :=  l_Anal_Det_Opt_Tbl(l_count -2).Bsc_Option_Id            ;
            l_Anal_Opt_Rec.Bsc_Parent_Option_Id         :=  l_Anal_Det_Opt_Tbl(l_count -2).Bsc_Parent_Option_Id     ;
            l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id    :=  l_Anal_Det_Opt_Tbl(l_count -2).Bsc_Grandparent_Option_Id;
            BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Options
            (       p_commit              =>    FND_API.G_FALSE
                ,   p_Anal_Opt_Rec        =>    l_Anal_Opt_Rec
                ,   x_return_status       =>    x_return_status
                ,   x_msg_count           =>    x_msg_count
                ,   x_msg_data            =>    x_msg_data
             );
          END IF;
       END IF;
    ELSE
      l_Anal_Opt_Rec.Bsc_Analysis_Group_Id        :=  l_count;
      l_Anal_Opt_Rec.Bsc_Analysis_Option_Id       :=  l_Anal_Det_Opt_Tbl(l_count).Bsc_Option_Id            ;
      l_Anal_Opt_Rec.Bsc_Parent_Option_Id         :=  l_Anal_Det_Opt_Tbl(l_count).Bsc_Parent_Option_Id     ;
      l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id    :=  l_Anal_Det_Opt_Tbl(l_count).Bsc_Grandparent_Option_Id;
      BSC_ANALYSIS_OPTION_PVT.Delete_Analysis_Options
       (       p_commit              =>    FND_API.G_FALSE
           ,   p_Anal_Opt_Rec        =>    l_Anal_Opt_Rec
           ,   x_return_status       =>    x_return_status
           ,   x_msg_count           =>    x_msg_count
           ,   x_msg_data            =>    x_msg_data
       );
     END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteBSCAnaOptMultGroups;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteBSCAnaOptMultGroups;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteBSCAnaOptMultGroups;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Delete_Ana_Opt_Mult_Groups ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Delete_Ana_Opt_Mult_Groups ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteBSCAnaOptMultGroups;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Delete_Ana_Opt_Mult_Groups ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Delete_Ana_Opt_Mult_Groups ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Delete_Ana_Opt_Mult_Groups;
/*****************************************************************************************/

PROCEDURE Synch_Kpi_Anal_Group
(        p_commit              IN            VARCHAR2:=FND_API.G_FALSE
     ,   p_Kpi_Id              IN            BSC_KPIS_B.indicator%TYPE
     ,   p_Anal_Opt_Tbl        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type
     ,   x_return_status       OUT NOCOPY    VARCHAR2
     ,   x_msg_count           OUT NOCOPY    NUMBER
     ,   x_msg_data            OUT NOCOPY    VARCHAR2
)IS
    l_Anal_Grp_Opt_Tbl          BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type;
    l_Anal_Opt_Tbl              BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type;
    l_count                     NUMBER;
    l_old_group_count           NUMBER;
    l_new_group_count           NUMBER;
    l_group_count               NUMBER;
    l_Num_Opt_Id                NUMBER;
 BEGIN
     FND_MSG_PUB.Initialize;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     SAVEPOINT BSCSynchKpiAnalGroup;

     l_Anal_Opt_Tbl :=    p_Anal_Opt_Tbl;
     FOR table_index in 0..l_Anal_Grp_Opt_Tbl.COUNT-1 LOOP
         l_Anal_Grp_Opt_Tbl.DELETE(table_index);
     END LOOP;
     BSC_ANALYSIS_OPTION_PVT.Store_Anal_Opt_Grp_Count(p_kpi_id, l_Anal_Grp_Opt_Tbl);

     l_old_group_count := l_Anal_Opt_Tbl.COUNT;
     l_new_group_count := l_Anal_Grp_Opt_Tbl.COUNT;

     WHILE (l_old_group_count <> l_new_group_count) LOOP
       EXIT WHEN (l_old_group_count < 0);
           DELETE FROM BSC_KPI_ANALYSIS_GROUPS
           WHERE  Indicator    =  p_Kpi_Id
           AND    Analysis_Group_Id =  l_old_group_count - 1;

           l_Anal_Opt_Tbl.DELETE(l_old_group_count - 1);
           l_old_group_count := l_old_group_count - 1;
     END LOOP;

     l_group_count := 0;
     WHILE(l_group_count <= (l_Anal_Grp_Opt_Tbl.COUNT -1 )) LOOP
        IF(((l_Anal_Grp_Opt_Tbl(l_group_count).Bsc_analysis_group_id) =
             (l_Anal_Opt_Tbl(l_group_count).Bsc_analysis_group_id)) AND
               ((l_Anal_Grp_Opt_Tbl(l_group_count).Bsc_no_option_id) <>
                 (l_Anal_Opt_Tbl(l_group_count).Bsc_no_option_id))) THEN

            SELECT COUNT(DISTINCT(Option_Id)) INTO l_Num_Opt_Id
            FROM   BSC_KPI_ANALYSIS_OPTIONS_B
            WHERE  Indicator         = p_Kpi_Id
            AND    Analysis_Group_Id = l_group_count;

            UPDATE  BSC_KPI_ANALYSIS_GROUPS
            SET     Num_Of_Options    = l_Num_Opt_Id
            WHERE   Indicator         = p_Kpi_Id
            AND     Analysis_Group_Id = l_group_count;
        END IF;
        l_group_count := l_group_count + 1;
      END LOOP;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCSynchKpiAnalGroup;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCSynchKpiAnalGroup;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BSCSynchKpiAnalGroup;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Synch_Kpi_Anal_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Synch_Kpi_Anal_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BSCSynchKpiAnalGroup;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Synch_Kpi_Anal_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Synch_Kpi_Anal_Group ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
 END Synch_Kpi_Anal_Group;


/*
    This API refreshes all the short_names to reflect the correct AK region its is pointing to.
    API is to be called after an Analysis Option has been deleted, etc from Start-end-KPI UI

    WARNING: This should not be used from within PMD. Its been implemented only for START-TO-END KPI.
*/

-- Added for Start-to-End KPI Project, Bug#3691035

PROCEDURE Refresh_Short_Names (
        p_Commit                    IN VARCHAR2
      , p_Kpi_Id                    IN NUMBER
      , x_Return_Status             OUT NOCOPY   VARCHAR2
      , x_Msg_Count                 OUT NOCOPY   NUMBER
      , x_Msg_Data                  OUT NOCOPY   VARCHAR2
) IS

  CURSOR c_Update_Short_Names IS
    SELECT INDICATOR, OPTION_ID
    FROM   BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE  INDICATOR         = p_Kpi_Id
    AND    ANALYSIS_GROUP_ID = 0
    AND    SHORT_NAME IS NOT NULL;

BEGIN
    SAVEPOINT AORefreshShortNamesPVT;
    FND_MSG_PUB.Initialize;
    x_Return_Status  := FND_API.G_RET_STS_SUCCESS;


    FOR cUSN IN c_Update_Short_Names LOOP
        UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
        SET    SHORT_NAME        = BSC_ANALYSIS_OPTION_PUB.C_BSC_UNDERSCORE || cUSN.INDICATOR || '_' || cUSN.OPTION_ID
        WHERE  INDICATOR         = cUSN.INDICATOR
        AND    OPTION_ID         = cUSN.OPTION_ID
        AND    ANALYSIS_GROUP_ID = 0
        AND    SHORT_NAME IS NOT NULL;
    END LOOP;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO AORefreshShortNamesPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO AORefreshShortNamesPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO AORefreshShortNamesPVT;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Refresh_Short_Names ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Refresh_Short_Names ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO AORefreshShortNamesPVT;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Refresh_Short_Names ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Refresh_Short_Names ';
        END IF;

END Refresh_Short_Names;




/************************************************************************************
************************************************************************************/

PROCEDURE Validate_Custom_Measure
(    p_kpi_id              IN         BSC_OAF_ANALYSYS_OPT_COMB_V.INDICATOR%TYPE
    , p_option0            IN         BSC_OAF_ANALYSYS_OPT_COMB_V.ANALYSIS_OPTION0%TYPE
    , p_option1            IN         BSC_OAF_ANALYSYS_OPT_COMB_V.ANALYSIS_OPTION1%TYPE
    , p_option2            IN         BSC_OAF_ANALYSYS_OPT_COMB_V.ANALYSIS_OPTION2%TYPE
    , p_series_id          IN         BSC_OAF_ANALYSYS_OPT_COMB_V.SERIES_ID%TYPE
    , x_return_status       OUT NOCOPY    VARCHAR2
    , x_msg_count           OUT NOCOPY    NUMBER
    , x_msg_data            OUT NOCOPY    VARCHAR2
) IS
    l_Measure_AKRegion      BIS_INDICATORS.ACTUAL_DATA_SOURCE%TYPE;
    l_Measure_Function      BIS_INDICATORS.FUNCTION_NAME%TYPE;
    l_Measure_DatasetId     BSC_OAF_ANALYSYS_OPT_COMB_V.DATASET_ID%TYPE;
    l_AnaOpt_AKRegion       varchar2(50);
    l_position              NUMBER;
    l_index                 integer;
    l_ret_status            varchar2(10);
    l_msg_data              varchar2(30);
    l_parent_obj_table      BIS_RSG_PUB_API_PKG.t_BIA_RSG_Obj_Table;

    l_Allow_Delete          BOOLEAN;
    l_mess_count            NUMBER;
    l_dep_obj_message           varchar2(1000);
    l_message               varchar2(1000);
    l_AnaOpt_Name           BSC_OAF_ANALYSYS_OPT_COMB_V.FULL_NAME%TYPE;
    l_kpi_name              BSC_KPI_ANALYSIS_MEASURES_VL.NAME%TYPE;
    l_objective_name        BSC_KPIS_VL.NAME%TYPE;
    l_objective             BSC_KPIS_VL.NAME%TYPE;

    CURSOR  c_Measure_ak IS
     SELECT  c.actual_data_source actual_data_source , c.function_name function_name
             ,a.dataset_id dataset_id
             ,a.full_name name
       FROM    bsc_oaf_analysys_opt_comb_v a,
               bsc_sys_datasets_b b,
               bis_indicators c
       WHERE   a.dataset_id = b.dataset_id
       AND     b.dataset_id = c.dataset_id
       AND     a.Indicator        = p_kpi_id
       AND     a.Analysis_Option0 = p_option0
       AND     a.Analysis_Option1 = p_option1
       AND     a.Analysis_Option2 = p_option2
       AND     a.SERIES_ID        = p_series_id;

    CURSOR c_AnaOpt_ak IS
    SELECT a.short_name , b.name
    FROM  bsc_kpi_analysis_options_b a, bsc_kpis_vl b
    WHERE a.indicator = p_kpi_id
    AND   a.option_id = p_option0
    AND   a.parent_option_id = p_option1
    AND   a.grandparent_option_id = p_option2
    AND   a.indicator = b.indicator;

    CURSOR c_KpiMeasure(p_dataset_id BSC_KPI_ANALYSIS_MEASURES_VL.dataset_id%TYPE) IS
    SELECT a.name KPI_NAME, b.name  OBJECTVIE_NAME
    FROM  BSC_KPI_ANALYSIS_MEASURES_VL a
    ,BSC_KPIS_VL b
    WHERE a.indicator = b.indicator
    AND   a.dataset_id = p_dataset_id
    AND     a.Indicator        <> p_kpi_id
    AND     a.Analysis_Option0 <> p_option0
    AND     a.Analysis_Option1 <> p_option1
    AND     a.Analysis_Option2 <> p_option2
    AND     a.SERIES_ID        <> p_series_id;

    CURSOR c_KpiName(p_kpi_id BSC_KPIS_B.INDICATOR%TYPE) IS
    SELECT name
    FROM BSC_KPIS_VL
    WHERE indicator = p_kpi_id;

BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_Allow_Delete  := TRUE;

    IF (c_Measure_ak%ISOPEN) THEN
      CLOSE c_Measure_ak;
    END IF;

    OPEN c_Measure_ak;
    FETCH c_Measure_ak into l_Measure_AKRegion,l_Measure_Function,l_Measure_DatasetId,l_AnaOpt_Name;
    CLOSE c_Measure_ak;

    IF (c_AnaOpt_ak%ISOPEN) THEN
      CLOSE c_AnaOpt_ak;
    END IF;

    OPEN c_AnaOpt_ak;
    FETCH c_AnaOpt_ak into l_AnaOpt_AKRegion,l_objective;
    CLOSE c_AnaOpt_ak;

    IF (l_Measure_AKRegion IS NOT NULL) THEN
      l_position := INSTR(l_Measure_AKRegion,'.');
      IF l_position <> 0 THEN
        l_Measure_AKRegion := substr(l_Measure_AKRegion,1,l_position-1);
      END IF;
    END IF;

    IF (l_Measure_AKRegion <> l_AnaOpt_AKRegion) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_KPI_NOT_PRIM_SOURCE');
      FND_MESSAGE.SET_TOKEN('AK_KPI', l_AnaOpt_AKRegion);
      FND_MESSAGE.SET_TOKEN('AK_MES', l_Measure_AKRegion);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_parent_obj_table := BIS_RSG_PUB_API_PKG.GetParentObjects(l_Measure_Function
                                    ,'REPORT','PORTLET',l_ret_status,l_msg_data);
    IF ((l_ret_status IS NOT NULL) AND (l_ret_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BIS',l_msg_data);
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_mess_count := 1;
    l_message    := '<ol>';
    IF (l_parent_obj_table.COUNT > 0) THEN
        l_Allow_Delete := FALSE;
        l_index := l_parent_obj_table.first;
        LOOP
          FND_MESSAGE.SET_NAME('BSC','BSC_KPI_DEP_KPI_REGION');
          FND_MESSAGE.SET_TOKEN('DEP_OBJECT',BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_User_Function_Name(l_parent_obj_table(l_index).object_name));
          l_dep_obj_message := FND_MESSAGE.GET;
          l_message := l_message || '<li type=1>'||l_dep_obj_message || '</li>';
          l_mess_count := l_mess_count + 1;
          EXIT WHEN l_index = l_parent_obj_table.last;
          l_index := l_parent_obj_table.next(l_index);
        END LOOP;
    END IF;

    IF (c_KpiMeasure%ISOPEN) THEN
        CLOSE c_KpiMeasure;
    END IF;

    OPEN c_KpiMeasure(l_Measure_DatasetId);
    LOOP
    FETCH c_KpiMeasure INTO l_kpi_name,l_objective_name;
    EXIT WHEN c_KpiMeasure%NOTFOUND;
        l_Allow_Delete := FALSE;
        FND_MESSAGE.SET_NAME('BSC','BSC_KPI_DEP_KPI');
        FND_MESSAGE.SET_TOKEN('KPI_NAME',l_kpi_name);
        FND_MESSAGE.SET_TOKEN('OBJECTIVE_NAME',l_objective_name);
        l_dep_obj_message := FND_MESSAGE.GET;
        l_message := l_message || '<li type=1>'|| l_dep_obj_message  ||'</li>';
        l_mess_count := l_mess_count + 1;
    END LOOP;
    CLOSE c_KpiMeasure;

    l_message := l_message || '</ol>';
    IF (l_Allow_Delete = FALSE) THEN

      IF (c_KpiName%ISOPEN) THEN
         CLOSE c_KpiMeasure;
      END IF;

      OPEN c_KpiName(p_kpi_id);
      FETCH c_KpiName INTO l_objective_name;
      CLOSE c_KpiName;

      FND_MESSAGE.SET_NAME('BSC','BSC_OBJ_DELETE');
      FND_MESSAGE.SET_TOKEN('OBJ_NAME', l_objective_name);
      FND_MESSAGE.SET_TOKEN('KPI_NAME', l_AnaOpt_Name);
      FND_MESSAGE.SET_TOKEN('DEP_OBJ_LIST', l_message);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FND_MESSAGE.SET_NAME('BSC','BSC_MEASURE_DELETE');
    FND_MESSAGE.SET_TOKEN('MEASURE', l_AnaOpt_Name);
    FND_MESSAGE.SET_TOKEN('AK_REGION', l_Measure_AKRegion);
    FND_MESSAGE.SET_TOKEN('FORM_FUNCTION', l_Measure_Function);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.Count_And_Get
    (      p_encoded   =>  FND_API.G_FALSE
       ,   p_count     =>  x_msg_count
       ,   p_data      =>  x_msg_data
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_AnaOpt_ak%ISOPEN) THEN
          CLOSE c_AnaOpt_ak;
        END IF;
        IF (c_KpiName%ISOPEN) THEN
            CLOSE c_KpiMeasure;
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
        IF (c_AnaOpt_ak%ISOPEN) THEN
          CLOSE c_AnaOpt_ak;
        END IF;
        IF (c_KpiName%ISOPEN) THEN
           CLOSE c_KpiMeasure;
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
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (c_AnaOpt_ak%ISOPEN) THEN
          CLOSE c_AnaOpt_ak;
        END IF;
        IF (c_KpiName%ISOPEN) THEN
         CLOSE c_KpiMeasure;
        END IF;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.checkMeasure ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.CheckMeasure ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (c_AnaOpt_ak%ISOPEN) THEN
          CLOSE c_AnaOpt_ak;
        END IF;
        IF (c_KpiName%ISOPEN) THEN
         CLOSE c_KpiMeasure;
        END IF;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.checkMeasure ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.checkMeasure ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Validate_Custom_Measure;

PROCEDURE delete_extra_series(
      p_Bsc_Anal_Opt_Rec    IN  BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    , x_return_status       OUT NOCOPY    VARCHAR2
    , x_msg_count           OUT NOCOPY    NUMBER
    , x_msg_data            OUT NOCOPY    VARCHAR2
) IS
l_Bsc_Anal_Opt_Rec      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MSG_PUB.Initialize;
    --DBMS_OUTPUT.PUT_LINE('in private delte');

    DELETE  FROM BSC_KPI_ANALYSIS_MEASURES_B
    WHERE   indicator        = p_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
    AND     analysis_option0 = 0
    AND     analysis_option1 = p_Bsc_Anal_Opt_Rec.Bsc_Option_Group1
    AND     analysis_option2 = p_Bsc_Anal_Opt_Rec.Bsc_Option_Group2
    AND     series_id        > 0;
    --DBMS_OUTPUT.PUT_LINE('after deleting baset table');

    DELETE  FROM BSC_KPI_ANALYSIS_MEASURES_TL
    WHERE   indicator        = p_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
    AND     analysis_option0 = 0
    AND     analysis_option1 = p_Bsc_Anal_Opt_Rec.Bsc_Option_Group1
    AND     analysis_option2 = p_Bsc_Anal_Opt_Rec.Bsc_Option_Group2
    AND     series_id        > 0;
    --DBMS_OUTPUT.PUT_LINE('after deleting base table');


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
          x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       ELSE
          x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       END IF;
       --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups ';
       END IF;
      --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END delete_extra_series;

/************************************************************************************
************************************************************************************/

procedure Delete_Data_Series(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

Cursor c_Dataseries is
    SELECT SERIES_ID
    FROM BSC_KPI_ANALYSIS_MEASURES_B
    WHERE indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id
           AND analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
           AND analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
           AND analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2
           AND SERIES_ID > p_Anal_Opt_Rec.Bsc_Dataset_Series_Id
    ORDER BY SERIES_ID;

 l_Anal_Opt_Rec        BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
 l_new_series_id  number;

 l_Count NUMBER;

BEGIN
    FND_MSG_PUB.Initialize;
    SAVEPOINT DeleteBSCDataSeriesPVT;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Delete the Data Series
         DELETE FROM BSC_KPI_ANALYSIS_MEASURES_B
         WHERE indicator        = p_Anal_Opt_Rec.Bsc_Kpi_Id
           AND analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
           AND analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
           AND analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2
           AND SERIES_ID = p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;

         DELETE FROM BSC_KPI_ANALYSIS_MEASURES_TL
         WHERE indicator        = p_Anal_Opt_Rec.Bsc_Kpi_Id
           AND analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
           AND analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
           AND analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2
           AND SERIES_ID = p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;

        -- Renumerate the Series Id
         IF (c_Dataseries%ISOPEN) THEN
            CLOSE c_Dataseries;
         END IF;

         -- Renumerate Data Series Id
         l_new_series_id := p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;
         l_Anal_Opt_Rec := p_Anal_Opt_Rec;
         FOR CD IN c_Dataseries LOOP
          l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := CD.SERIES_ID;
          l_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id := l_new_series_id;
          Swap_Data_Series_Id(
              p_commit              =>  FND_API.G_FALSE
             ,p_Anal_Opt_Rec        =>  l_Anal_Opt_Rec
             ,x_return_status       =>  x_return_status
             ,x_msg_count           =>  x_msg_count
             ,x_msg_data            =>  x_msg_data
          );
          l_new_series_id := l_new_series_id + 1;
         END LOOP;

         -- This code need to moved to a better place.
         -- currently this is very crude and needs to be replaced and moved to
         -- a better place.
         BEGIN
             SELECT COUNT(1) INTO l_Count
             FROM   BSC_KPI_ANALYSIS_MEASURES_B K
             WHERE K.INDICATOR        = p_Anal_Opt_Rec.Bsc_Kpi_Id
             AND   K.ANALYSIS_OPTION0 = p_Anal_Opt_Rec.Bsc_Option_Group0
             AND   K.ANALYSIS_OPTION1 = p_Anal_Opt_Rec.Bsc_Option_Group1
             AND   K.ANALYSIS_OPTION2 = p_Anal_Opt_Rec.Bsc_Option_Group2
             AND   K.DEFAULT_VALUE    = 1;

             IF (l_Count = 0) THEN
                 UPDATE BSC_KPI_ANALYSIS_MEASURES_B K
                 SET   K.DEFAULT_VALUE    = 1
                 WHERE K.INDICATOR        = p_Anal_Opt_Rec.Bsc_Kpi_Id
                 AND   K.ANALYSIS_OPTION0 = p_Anal_Opt_Rec.Bsc_Option_Group0
                 AND   K.ANALYSIS_OPTION1 = p_Anal_Opt_Rec.Bsc_Option_Group1
                 AND   K.ANALYSIS_OPTION2 = p_Anal_Opt_Rec.Bsc_Option_Group2
                 AND   K.SERIES_ID        = 0;
             END IF;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;

        IF p_commit =  FND_API.G_TRUE THEN
            commit;
        END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_Dataseries%ISOPEN) THEN
            CLOSE c_Dataseries;
        END IF;
        ROLLBACK TO DeleteBSCDataSeriesPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_Dataseries%ISOPEN) THEN
            CLOSE c_Dataseries;
        END IF;
        ROLLBACK TO DeleteBSCDataSeriesPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        IF (c_Dataseries%ISOPEN) THEN
            CLOSE c_Dataseries;
        END IF;
        ROLLBACK TO DeleteBSCDataSeriesPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Delete_Data_Series ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Delete_Data_Series ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

End Delete_Data_Series;


/*---------------------------------------------------------------------------
 Swap_Data_Series : Swap the Data Series Id between two DataSerid

 Use Parameters:
           p_Anal_Opt_Rec.Bsc_Kpi_Id
           p_Anal_Opt_Rec.Bsc_Option_Group0
           p_Anal_Opt_Rec.Bsc_Option_Group1
           Anal_Opt_Rec.Bsc_Option_Group2
           p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;
           p_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id;
----------------------------------------------------------------------------*/
procedure Swap_Data_Series_Id(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is


Cursor c_Data_Series is
    SELECT SERIES_ID
    FROM BSC_KPI_ANALYSIS_MEASURES_B
    WHERE indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id
           AND analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
           AND analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
           AND analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2
           AND SERIES_ID =  p_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id;

    l_temp_data_series_id number;
    l_Anal_Opt_Rec        BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
    l_temp_value          number := -999;

BEGIN
  FND_MSG_PUB.Initialize;
  SAVEPOINT SwapDataSeriesPVT;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF  p_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id  is not null
      and p_Anal_Opt_Rec.Bsc_Dataset_Series_Id is not null
      and p_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id  <>
                              p_Anal_Opt_Rec.Bsc_Dataset_Series_Id THEN

    l_Anal_Opt_Rec := p_Anal_Opt_Rec;
    l_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id := NULL;

    -- Check if the Bsc_Dataset_New_Series_Id exist to Swap to a temporaty value
    FOR cd IN c_Data_Series LOOP
        l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := p_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id;
        l_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id := l_temp_value;
        Swap_Data_Series_Id(
          p_commit              =>  p_commit
         ,p_Anal_Opt_Rec        =>  l_Anal_Opt_Rec
         ,x_return_status       =>  x_return_status
         ,x_msg_count           =>  x_msg_count
         ,x_msg_data            =>  x_msg_data
        );
    END LOOP;

    -- Swap the Data Series Id
           UPDATE BSC_KPI_ANALYSIS_MEASURES_B
           SET SERIES_ID = p_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id
           WHERE indicator         = p_Anal_Opt_Rec.Bsc_Kpi_Id
              AND analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
              AND analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
              AND analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2
              AND SERIES_ID = p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;

           UPDATE BSC_KPI_ANALYSIS_MEASURES_TL
           SET SERIES_ID = p_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id
           WHERE indicator         = p_Anal_Opt_Rec.Bsc_Kpi_Id
              AND analysis_option0 = p_Anal_Opt_Rec.Bsc_Option_Group0
              AND analysis_option1 = p_Anal_Opt_Rec.Bsc_Option_Group1
              AND analysis_option2 = p_Anal_Opt_Rec.Bsc_Option_Group2
              AND SERIES_ID =  p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;

    -- Swap the temporay Series Id
    IF  l_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id = l_temp_value THEN
        l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := l_temp_value;
        l_Anal_Opt_Rec.Bsc_Dataset_New_Series_Id :=  p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;
        Swap_Data_Series_Id(
          p_commit              =>  p_commit
         ,p_Anal_Opt_Rec        =>  l_Anal_Opt_Rec
         ,x_return_status       =>  x_return_status
         ,x_msg_count           =>  x_msg_count
         ,x_msg_data            =>  x_msg_data
        );
    END IF;

  END IF;

  IF p_commit =  FND_API.G_TRUE THEN
        commit;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_Data_Series%ISOPEN) THEN
            CLOSE c_Data_Series;
        END IF;
        ROLLBACK TO SwapDataSeriesPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_Data_Series%ISOPEN) THEN
            CLOSE c_Data_Series;
        END IF;
        ROLLBACK TO SwapDataSeriesPVT;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Swap_Data_Series_Id ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Swap_Data_Series_Id ';
        END IF;
        RAISE;
    WHEN OTHERS THEN
        IF (c_Data_Series%ISOPEN) THEN
            CLOSE c_Data_Series;
        END IF;
        ROLLBACK TO SwapDataSeriesPVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Swap_Data_Series_Id ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Swap_Data_Series_Id ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;

End Swap_Data_Series_Id;


/*---------------------------------------------------------------------------------/
    API: Cascade_Series_Default_Value

    This API cascades the correct DEFAULT_VALUE that exists in the table
    BSC_KPI_ANALYSIS_MEASURES_B. Only one value of the default value needs to be
    set to 1 and the rest needs to be 0, so the following API will ensure the following

    If in "CREATE" mode
    -------------------
    1) If the table is empty for the combination (kpi,option0,option1,option2) then
       the return value x_Default_Value will always be returned as 1 (Assuming that
       DATASET_ID = -1 for the "Default Measure"
    2) If during a create the default_value is passed as 1, then the rest of the
       default_Values in the table by the comination (kpi,option0,option1,option2)
       will be set to 0 and the Series under consideration will be returned with
       x_Default_Value as 1
    3) If p_Default_Value is passed as 0, then no action is taken.

    If in "UPDATE" mode
    -------------------

    1) If we have p_Default_Value passed as 0 and the table BSC_KPI_ANALYSIS_MEASURES_B
       has only one single entry, then x_Default_Value will be returned as 1
    2) If we have p_Default_Value passed as 0 for a series which already has
       default_value as 1, then the next subsequent series is set with 1 and if the
       series being updated is already the last one, then SERIES_ID = 0 will be updated
       with default_value = 1.
    3) If One of the default value is being changed from 0 to 1, then the rest of
       default_Value is set to 0 and the current series is set to 1.

    The API ensures that there is exactly one entry in BSC_kPI_ANALYSIS_OPTIONS_B
    table for DEFAULT_VALUE =1 for the (kpi,option0,option1,option2) combination.

    Appropriate color changes are cascaded into the Objectives (and Shared)
    Also changes will be cascaded only if the current analysis option combination
    is the default combination
/---------------------------------------------------------------------------------*/


PROCEDURE Cascade_Series_Default_Value (
      p_Commit        IN  VARCHAR2
    , p_Api_Mode      IN  VARCHAR2
    , p_Kpi_Id        IN  NUMBER
    , p_Option0       IN  NUMBER
    , p_Option1       IN  NUMBER
    , p_Option2       IN  NUMBER
    , p_Series_Id     IN  NUMBER
    , p_Default_Value IN  NUMBER
    , x_Default_Value OUT NOCOPY NUMBER
    , x_Return_Status OUT NOCOPY VARCHAR2
    , x_Msg_Count     OUT NOCOPY NUMBER
    , x_Msg_Data      OUT NOCOPY VARCHAR2
) IS
    CURSOR  c_Shared_Objectives IS
      SELECT  K.INDICATOR
      FROM    BSC_KPIS_B K
      WHERE   K.SOURCE_INDICATOR  =  p_Kpi_Id
      AND     K.PROTOTYPE_FLAG   <>  BSC_KPI_PUB.DELETE_KPI_FLAG;


    l_Default_Value   BSC_KPI_ANALYSIS_MEASURES_B.DEFAULT_VALUE%TYPE;
    l_Count           NUMBER;
    l_Max_Series_Id   NUMBER;
    l_Upd_Series_Id   NUMBER;
BEGIN
    FND_MSG_PUB.Initialize;
    SAVEPOINT CascadedSeriesPVT;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_Count := 0;

    x_Default_Value := p_Default_Value;

    SELECT COUNT(1) INTO l_Count
    FROM bsc_db_color_ao_defaults_v
    WHERE indicator = p_Kpi_Id
    AND a0_default = p_Option0
    AND a1_default = p_Option1
    AND a2_default = p_Option2;

    IF l_Count = 0 THEN
      RETURN;
    END IF;

    IF (p_Api_Mode = C_API_CREATE) THEN

        SELECT COUNT(1) INTO l_Count
        FROM   BSC_KPI_ANALYSIS_MEASURES_B K
        WHERE  K.INDICATOR        = p_Kpi_Id
        AND    K.ANALYSIS_OPTION0 = p_Option0
        AND    K.ANALYSIS_OPTION1 = p_Option1
        AND    K.ANALYSIS_OPTION2 = p_Option2;
        --AND    K.DATASET_ID      <> -1; -- default measure dataset

        IF (l_Count = 0) THEN
            x_Default_Value := 1; -- enabled
        ELSE
            IF p_Default_Value = 1 THEN
                UPDATE BSC_KPI_ANALYSIS_MEASURES_B K
                SET    K.DEFAULT_VALUE    = 0
                WHERE  K.INDICATOR        = p_Kpi_Id
                AND    K.ANALYSIS_OPTION0 = p_Option0
                AND    K.ANALYSIS_OPTION1 = p_Option1
                AND    K.ANALYSIS_OPTION2 = p_Option2;

                x_Default_Value := p_Default_Value;
            ELSE
                x_Default_Value := p_Default_Value;
            END IF;
        END IF;
    ELSIF (p_Api_Mode = C_API_UPDATE) THEN

       SELECT K.DEFAULT_VALUE INTO l_Default_Value
       FROM   BSC_KPI_ANALYSIS_MEASURES_B K
       WHERE  K.INDICATOR        = p_Kpi_Id
       AND    K.ANALYSIS_OPTION0 = p_Option0
       AND    K.ANALYSIS_OPTION1 = p_Option1
       AND    K.ANALYSIS_OPTION2 = p_Option2
       AND    K.SERIES_ID        = p_Series_Id;

       IF (l_Default_Value = 0 AND p_Default_Value = 1) THEN
            UPDATE BSC_KPI_ANALYSIS_MEASURES_B K
            SET    K.DEFAULT_VALUE    = 0
            WHERE  K.INDICATOR        = p_Kpi_Id
            AND    K.ANALYSIS_OPTION0 = p_Option0
            AND    K.ANALYSIS_OPTION1 = p_Option1
            AND    K.ANALYSIS_OPTION2 = p_Option2;

       ELSIF (l_Default_Value = 1 AND p_Default_Value = 0) THEN

            SELECT NVL(MAX(K.SERIES_ID), 0) INTO l_Max_Series_Id
            FROM   BSC_KPI_ANALYSIS_MEASURES_B K
            WHERE  K.INDICATOR        = p_Kpi_Id
            AND    K.ANALYSIS_OPTION0 = p_Option0
            AND    K.ANALYSIS_OPTION1 = p_Option1
            AND    K.ANALYSIS_OPTION2 = p_Option2;

            IF (l_Max_Series_Id = p_Series_Id) THEN
                 l_Upd_Series_Id := 0;
            ELSE
                 l_Upd_Series_Id := p_Series_Id + 1;
            END IF;

            UPDATE BSC_KPI_ANALYSIS_MEASURES_B K
            SET    K.DEFAULT_VALUE    = 0
            WHERE  K.INDICATOR        = p_Kpi_Id
            AND    K.ANALYSIS_OPTION0 = p_Option0
            AND    K.ANALYSIS_OPTION1 = p_Option1
            AND    K.ANALYSIS_OPTION2 = p_Option2;

            UPDATE BSC_KPI_ANALYSIS_MEASURES_B K
            SET    K.DEFAULT_VALUE    = 1
            WHERE  K.INDICATOR        = p_Kpi_Id
            AND    K.ANALYSIS_OPTION0 = p_Option0
            AND    K.ANALYSIS_OPTION1 = p_Option1
            AND    K.ANALYSIS_OPTION2 = p_Option2
            AND    K.SERIES_ID        = l_Upd_Series_Id;

            BEGIN
                -- get the updated values of the series into x_Default_Value
                SELECT K.DEFAULT_VALUE INTO x_Default_Value
                FROM   BSC_KPI_ANALYSIS_MEASURES_B K
                WHERE  K.INDICATOR        = p_Kpi_Id
                AND    K.ANALYSIS_OPTION0 = p_Option0
                AND    K.ANALYSIS_OPTION1 = p_Option1
                AND    K.ANALYSIS_OPTION2 = p_Option2
                AND    K.SERIES_ID        = p_Series_Id;
            EXCEPTION
                WHEN OTHERS THEN
                    x_Default_Value := p_Default_Value;
            END;

       END IF;
    END IF;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CascadedSeriesPVT;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Cascade_Series_Default_Value ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Cascade_Series_Default_Value ';
        END IF;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO CascadedSeriesPVT;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Cascade_Series_Default_Value ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Cascade_Series_Default_Value ';
        END IF;
        RAISE;
END Cascade_Series_Default_Value;



/************************************************************************************
************************************************************************************/

-- added for Bug#4324947
-- Returns the short_name of next associated Objective
-- of type AG only.
FUNCTION Get_Next_Associated_Obj_SN (
       p_Dataset_Id  IN NUMBER
) RETURN VARCHAR2 IS
    l_Dataset_Id  NUMBER;
    l_Short_Name  BSC_KPIS_B.SHORT_NAME%TYPE;

    CURSOR c_Objectives IS
        SELECT
          K.SHORT_NAME
        FROM
          BSC_KPIS_B K,
          BSC_KPI_ANALYSIS_MEASURES_B M
        WHERE
              K.INDICATOR  = M.INDICATOR
          AND M.DATASET_ID = p_Dataset_Id
          AND K.SHORT_NAME IS NOT NULL
          AND ROWNUM      <= 1
          ORDER BY K.CREATION_DATE;
BEGIN
    l_Short_Name := NULL;

    FOR cObjs IN c_Objectives LOOP
        l_Short_Name := cObjs.SHORT_NAME;
    END LOOP;

    RETURN l_Short_Name;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Next_Associated_Obj_SN;

/************************************************************************************
************************************************************************************/

-- Modified API for Bug#4638384 - changed signature to add p_Comparison_Source
-- added for Bug#4324947
PROCEDURE Cascade_Data_Src_Values (
      p_Commit                  IN  VARCHAR2
    , p_Measure_Short_Name      IN  VARCHAR2
    , p_Empty_Source            IN  VARCHAR2
    , p_Actual_Data_Source_Type IN  VARCHAR2
    , p_Actual_Data_Source      IN  VARCHAR2
    , p_Function_Name           IN  VARCHAR2
    , p_Enable_Link             IN  VARCHAR2
    , p_Comparison_Source       IN VARCHAR2
    , x_Return_Status           OUT NOCOPY VARCHAR2
    , x_Msg_Count               OUT NOCOPY NUMBER
    , x_Msg_Data                OUT NOCOPY VARCHAR2
) IS
    l_Actual_Data_Source_Type   BIS_INDICATORS.ACTUAL_DATA_SOURCE_TYPE%TYPE;
    l_Actual_Data_Source        BIS_INDICATORS.ACTUAL_DATA_SOURCE%TYPE;
    l_Function_Name             BIS_INDICATORS.FUNCTION_NAME%TYPE;
    l_Enable_Link               BIS_INDICATORS.ENABLE_LINK%TYPE;
    l_Comparison_Source         BIS_INDICATORS.COMPARISON_SOURCE%TYPE;

BEGIN
    FND_MSG_PUB.Initialize;
    SAVEPOINT CascadedDataSrcPVT;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;


    IF (p_Measure_Short_Name IS NULL) THEN
        RETURN;
    END IF;

    IF (p_Empty_Source = FND_API.G_TRUE) THEN
        l_Actual_Data_Source_Type := NULL;
        l_Actual_Data_Source      := NULL;
        l_Function_Name           := NULL;
        l_Enable_Link             := 'N';
        l_Comparison_Source       := NULL;
    ELSE
        l_Actual_Data_Source_Type := p_Actual_Data_Source_Type;
        l_Actual_Data_Source      := p_Actual_Data_Source;
        l_Function_Name           := p_Function_Name;
        l_Enable_Link             := p_Enable_Link;
        l_Comparison_Source       := p_Comparison_Source;
    END IF;

    -- This API expects BIS_INDICATORS to be syncronized correctly with BSC_SYS_DATASETS_VL
    UPDATE BIS_INDICATORS I
    SET    I.ACTUAL_DATA_SOURCE_TYPE = l_Actual_Data_Source_Type
         , I.ACTUAL_DATA_SOURCE      = l_Actual_Data_Source
         , I.FUNCTION_NAME           = l_Function_Name
         , I.ENABLE_LINK             = l_Enable_Link
         , I.COMPARISON_SOURCE       = l_Comparison_Source
    WHERE  I.SHORT_NAME              = p_Measure_Short_Name;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CascadedDataSrcPVT;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Cascade_Data_Src_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Cascade_Data_Src_Values ';
        END IF;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO CascadedDataSrcPVT;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Cascade_Data_Src_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Cascade_Data_Src_Values ';
        END IF;
        RAISE;
END Cascade_Data_Src_Values;


/***********************************************************
 Name       : Set_Default_Analysis_Option
 Description: This Function sets the current default analysis combination.
 Input      : p_obj_id            --> Objective Id
              p_Anal_Opt_Comb_Tbl --> Analysis Option combination Table
              p_Anal_Grp_Id       --> The current analysis group
 Created BY : ashankar For bug 4220400
/**********************************************************/
PROCEDURE Set_Default_Analysis_Option
(
      p_commit              IN             VARCHAR2
    , p_obj_id              IN             BSC_KPIS_B.indicator%TYPE
    , p_Anal_Opt_Comb_Tbl   IN             BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
    , p_Anal_Grp_Id         IN             BSC_KPIS_B.ind_group_id%TYPE
    , x_return_status       OUT NOCOPY     VARCHAR2
    , x_msg_count           OUT NOCOPY     NUMBER
    , x_msg_data            OUT NOCOPY     VARCHAR2
)IS
   l_anal_grp_id            BSC_KPIS_B.ind_group_id%TYPE;
   l_default_value          BSC_KPI_ANALYSIS_GROUPS.default_value%TYPE;
   l_Anal_Opt_Comb_Tbl      BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type;
BEGIN
   SAVEPOINT SetDftAnalOption;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   FND_MSG_PUB.Initialize;

   IF( p_Anal_Opt_Comb_Tbl IS NOT NULL) THEN
      l_Anal_Opt_Comb_Tbl  := p_Anal_Opt_Comb_Tbl;
      l_anal_grp_id        := p_Anal_Grp_Id;
      l_default_value      := l_Anal_Opt_Comb_Tbl(l_anal_grp_id);


      UPDATE  bsc_kpi_analysis_groups
      SET     default_value =  BSC_ANALYSIS_OPTION_PUB.c_ANAL_SERIES_DISABLED
      WHERE   indicator     =  p_obj_id;

      IF(l_anal_grp_id>=0)THEN
        WHILE (l_anal_grp_id>=0) LOOP
            UPDATE  bsc_kpi_analysis_groups
            SET     default_value     = l_Anal_Opt_Comb_Tbl(l_anal_grp_id)
            WHERE   indicator         = p_obj_id
            AND     analysis_group_id = l_anal_grp_id;

            l_anal_grp_id := l_anal_grp_id - 1;
        END LOOP;
      END IF;

      UPDATE bsc_kpi_analysis_measures_b
      SET    default_value    = BSC_ANALYSIS_OPTION_PUB.c_ANAL_SERIES_DISABLED
      WHERE  indicator        = p_obj_id
      AND    analysis_option0 = l_Anal_Opt_Comb_Tbl(0)
      AND    analysis_option1 = l_Anal_Opt_Comb_Tbl(1)
      AND    analysis_option2 = l_Anal_Opt_Comb_Tbl(2);

      UPDATE bsc_kpi_analysis_measures_b
      SET    default_value    = BSC_ANALYSIS_OPTION_PUB.c_ANAL_SERIES_ENABLED
      WHERE  indicator        = p_obj_id
      AND    analysis_option0 = l_Anal_Opt_Comb_Tbl(0)
      AND    analysis_option1 = l_Anal_Opt_Comb_Tbl(1)
      AND    analysis_option2 = l_Anal_Opt_Comb_Tbl(2)
      AND    series_id        = l_Anal_Opt_Comb_Tbl(3);
    END IF;

   IF(p_commit=FND_API.G_TRUE)THEN
     COMMIT;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO SetDftAnalOption;
       FND_MSG_PUB.Count_And_Get
       (      p_encoded   =>  FND_API.G_FALSE
          ,   p_count     =>  x_msg_count
          ,   p_data      =>  x_msg_data
       );
       --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
       x_return_status :=  FND_API.G_RET_STS_ERROR;
       RAISE;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO SetDftAnalOption;
       FND_MSG_PUB.Count_And_Get
       (      p_encoded   =>  FND_API.G_FALSE
          ,   p_count     =>  x_msg_count
          ,   p_data      =>  x_msg_data
       );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
   WHEN OTHERS THEN
       ROLLBACK TO SetDftAnalOption;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BSC_ANALYSIS_OPTION_PVT.Set_Default_Analysis_Option ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BSC_ANALYSIS_OPTION_PVT.Set_Default_Analysis_Option ';
       END IF;
       --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
      RAISE;

END Set_Default_Analysis_Option;


/************************************************************************************
************************************************************************************/

end BSC_ANALYSIS_OPTION_PVT;

/
