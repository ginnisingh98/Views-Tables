--------------------------------------------------------
--  DDL for Package Body BSC_DIM_FILTERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DIM_FILTERS_PVT" AS
/* $Header: BSCVFDLB.pls 120.2 2007/02/23 10:42:43 psomesul ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCCPMDB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: This Package handle Common Dimension Level for Scorecards |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 16-MAR-2004 WCANO    Created.                                         |
REM | 05-NOV-2004 ashankar fix bug 3459282                                  |
REM |             Changed procedure Synch_Fiters_And_Kpi_Dim                |
REM | 16-12-2006 PSOMESUL E#5678943 MIGRATE COMMON DIMENSIONS AND DIMENSION FILTERS TO SCORECARD DESIGNER|
REM +=======================================================================+
*/

/*-------------------------------------------------------------------------------------------------------------------
    PROCEDURE TO get THE LEVEL VIEW NAME FOR DIMENSION Filter
    RETURN NULL WHEN THE filter does NOT EXITs IN THE tab FOR THE specIFict
    DIMENSION objec
-------------------------------------------------------------------------------------------------------------------*/
FUNCTION Get_Filter_View_Name
(       p_Tab_Id          NUMBER
   ,    p_Dim_Level_Id    NUMBER
) RETURN VARCHAR2 IS
    l_Cursor             BSC_BIS_LOCKS_PUB.t_cursor;
    l_Level_View_Nane    BSC_SYS_FILTERS_VIEWS.level_view_name%TYPE;
BEGIN
    SELECT Level_View_Name
    INTO   l_Level_View_Nane
    FROM   BSC_SYS_FILTERS_VIEWS
    WHERE  Source_Type    =  BSC_DIM_FILTERS_PUB.SOURCE_TYPE_TAB
    AND    Source_Code    =  p_Tab_Id
    AND    Dim_Level_Id   =  p_Dim_Level_Id;

    RETURN l_Level_View_Nane;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Filter_View_Name;

/*-------------------------------------------------------------------------------------------------------------------
 Check_Filters_Not_Apply:
   This PROCEDURE will CHECK FOR filters that NOT apply ANY more TO THE tabs
   It will made one OF THE NEXT options:
   1. CHECK FOR a ALL THE DIMENSION object IN a specIFic tab WHEN  p_Dim_Level_Id IS NULL AND p_Tab_Id IS NOT NULL
   2. CHECK FOR a ALL THE DIMENSION object IN ALL THE  tab WHEN  p_Dim_Level_Id IS NULL AND p_Tab_Id IS NULL
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE  Check_Filters_Not_Apply
(       p_Tab_Id         IN  NUMBER := NULL
    ,   x_return_status  OUT NOCOPY VARCHAR2
    ,   x_msg_COUNT      OUT NOCOPY NUMBER
    ,   x_msg_data       OUT NOCOPY VARCHAR2
) IS
    l_Filtered_Dim_Level     NUMBER;
    l_Tab_Id                 NUMBER;

    CURSOR  c_Filters_Not_Apply IS
    SELECT  TF.Dim_Level_Id
    FROM    BSC_SYS_FILTERS_VIEWS TF
    WHERE   TF.Source_Type  =   BSC_DIM_FILTERS_PUB.SOURCE_TYPE_TAB
    AND     TF.Source_Code  =   p_Tab_Id
    AND     TF.Dim_Level_Id NOT IN
            (   SELECT  SL.Dim_Level_Id
                FROM    BSC_TAB_INDICATORS      TI
                      , BSC_KPI_DIM_LEVELS_B    K
                      , BSC_SYS_DIM_LEVELS_B    SL
                WHERE   SL.SOURCE            <> 'PMF'
                AND     TI.Tab_Id            =  p_Tab_Id
                AND     K.INDICATOR          =  TI.INDICATOR
                AND     SL.Level_Table_Name  =  K.Level_Table_Name
            );

BEGIN
    SAVEPOINT CheckFiltersNotApplyPvt;
    --DBMS_OUTPUT.PUT_LINE('BEGIN Check_Filters_Not_Apply' );
    ----DBMS_OUTPUT.PUT_LINE('Check_Filters_Not_Apply   p_Tab_Id = ' || p_Tab_Id  );

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_Tab_Id IS NOT NULL) THEN
        -- Find Tab Dim Levels
        OPEN c_Filters_Not_Apply;
            ----DBMS_OUTPUT.PUT_LINE('  OPENed cursor c_Filters_Not_Apply ');
            LOOP
                FETCH c_Filters_Not_Apply
                INTO  l_Filtered_Dim_Level;

                EXIT WHEN c_Filters_Not_Apply%NOTFOUND;
                ----DBMS_OUTPUT.PUT_LINE('FETCH l_Filtered_Dim_Level : = ' || l_Filtered_Dim_Level );
                --INSERT INTO TESTBUG values('FETCH l_Filtered_Dim_Level p_Tab_Id-->'|| to_char(p_Tab_Id));
                --INSERT INTO TESTBUG values('FETCH l_Filtered_Dim_Level-->'|| to_char(l_Filtered_Dim_Level));
                --commit;

                Drop_Filter (
                        p_Tab_Id           => p_Tab_Id
                    ,   p_Dim_Level_Id     => l_Filtered_Dim_Level
                    ,   x_return_status    => x_return_status
                    ,   x_msg_COUNT        => x_msg_COUNT
                    ,   x_msg_data         => x_msg_data
                );
            END LOOP;

        CLOSE c_Filters_Not_Apply;
    END IF;
    ----DBMS_OUTPUT.PUT_LINE('END Check_Filters_Not_Apply' );
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_Filters_Not_Apply%ISOPEN) THEN
            CLOSE c_Filters_Not_Apply;
        END IF;
        ROLLBACK TO CheckFiltersNotApplyPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_And_Get
        (   p_encoded =>  FND_API.G_FALSE
          , p_COUNT   =>  x_msg_COUNT
          , p_data    =>  x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        IF (c_Filters_Not_Apply%ISOPEN) THEN
            CLOSE c_Filters_Not_Apply;
        END IF;
        ROLLBACK TO CheckFiltersNotApplyPvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_And_Get
        (   p_encoded =>  FND_API.G_FALSE
          , p_COUNT   =>  x_msg_COUNT
          , p_data    =>  x_msg_data
        );
        RAISE;
END  Check_Filters_Not_Apply;

/*-------------------------------------------------------------------------------------------------------------------
   Drop_Filter   :
      DELETE a Filter metadata AND filter VIEW object
      AND CHECK IF EXISTS ANY  filter FOR a CHILD DIMENSION IN ORDER TO
      deleted OR recreated. (BY now it will be DELETE.  Later will be more intalligent
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE  Drop_Filter
(       p_Tab_Id            IN      NUMBER
    ,   p_Dim_Level_Id      IN      NUMBER
    ,   x_return_status     OUT NOCOPY     VARCHAR2
    ,   x_msg_count         OUT NOCOPY     NUMBER
    ,   x_msg_data          OUT NOCOPY     VARCHAR2
) IS
    l_Count                     NUMBER;
    l_sql                       VARCHAR2(500);
    l_Child_Dim_Level_Id        NUMBER;
    l_Filter_Level_View_Name    BSC_SYS_FILTERS_VIEWS.level_view_name%TYPE;
    l_count_filter_values       NUMBER;

    -- Cursor for get child dimension levels
    CURSOR  c_child_dim_obj IS
    SELECT  Dim_Level_Id
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   Parent_Dim_Level_Id = p_Dim_Level_Id
    AND     Relation_Type       = 1;

    -- Cursor Velidate if the child has specifict values
    -- difined

    CURSOR  c_count_filter_values IS
      SELECT COUNT(A.DIM_LEVEL_VALUE)
        FROM BSC_SYS_FILTERS A
        WHERE A.SOURCE_TYPE = 1
         AND A.SOURCE_CODE = p_Tab_Id
         AND A.DIM_LEVEL_ID = l_Child_Dim_Level_Id;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('BEGIN Drop_Filter' );
    --DBMS_OUTPUT.PUT_LINE('Drop_Filter  p_Tab_Id       = ' || p_Tab_Id );
    --DBMS_OUTPUT.PUT_LINE('Drop_Filter  p_Dim_Level_Id =  ' || p_Dim_Level_Id );

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_Filter_Level_View_Name := BSC_DIM_FILTERS_PVT.Get_Filter_View_Name(p_Tab_Id, p_Dim_Level_Id);

    --DBMS_OUTPUT.PUT_LINE('  Drop_Filter  l_Filter_Level_View_Name = ' || l_Filter_Level_View_Name );

    IF (l_Filter_Level_View_Name IS NOT NULL) THEN
        --------------------------------------------------------------
        --  Cascading delete for child dimension Levels Filters
        --  when the child filter it just a extension of the parent filter
        --------------------------------------------------------------
        OPEN c_child_dim_obj;
            --DBMS_OUTPUT.PUT_LINE('  OPENed c_child_dim_obj');
            LOOP
                FETCH c_child_dim_obj
                INTO  l_Child_Dim_Level_Id;

                EXIT WHEN c_child_dim_obj%NOTFOUND;
                --DBMS_OUTPUT.PUT_LINE('  call Drop_Filter  for l_Child_Dim_Level_Id = ' || l_Child_Dim_Level_Id );

                OPEN c_count_filter_values;
                FETCH c_count_filter_values INTO  l_count_filter_values;
                CLOSE c_count_filter_values;

                if l_count_filter_values = 0 then
                   Drop_Filter
                     (       p_Tab_Id        => p_Tab_Id
                         ,   p_Dim_Level_Id  => l_Child_Dim_Level_Id
                         ,   x_return_status => x_return_status
                         ,   x_msg_COUNT     => x_msg_COUNT
                         ,   x_msg_data      => x_msg_data
                     );
                end if;

            END LOOP;
        CLOSE c_child_dim_obj;

        -- Save point for the current filters view
        SAVEPOINT BcsFiltersPubDeleteFilterView;
        --DBMS_OUTPUT.PUT_LINE('   SAVEPOINT BcsFiltersPubDeleteFilterView ');
        --DBMS_OUTPUT.PUT_LINE('  Drop_Filter  p_Tab_Id = ' || p_Tab_Id );
        --DBMS_OUTPUT.PUT_LINE('  Drop_Filter  p_Dim_Level_Id = ' || p_Dim_Level_Id );

        Drop_Filter_Objects  (
                        p_Tab_Id        => p_Tab_Id
                    ,   p_Dim_Level_Id  => p_Dim_Level_Id
                    ,   x_return_status => x_return_status
                    ,   x_msg_COUNT     => x_msg_COUNT
                    ,   x_msg_data      => x_msg_data
       );

   END IF;

    --DBMS_OUTPUT.PUT_LINE('END Drop_Filter  p_Tab_Id = ' || p_Tab_Id || ' p_Dim_Level_Id = ' || p_Dim_Level_Id );
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_child_dim_obj%ISOPEN) THEN
            CLOSE c_child_dim_obj;
        END IF;
        ROLLBACK TO BcsFiltersPubDeleteFilterView;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_And_Get
        (   p_encoded =>  FND_API.G_FALSE
          , p_COUNT   =>  x_msg_COUNT
          , p_data    =>  x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        IF (c_child_dim_obj%ISOPEN) THEN
            CLOSE c_child_dim_obj;
        END IF;
        ROLLBACK TO BcsFiltersPubDeleteFilterView;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
           x_msg_data := x_msg_data||' -> BSC_DIM_FILTERS_PVT.Drop_Filter';
        ELSE
           x_msg_data := SQLERRM||' at BSC_DIM_FILTERS_PVT.Drop_Filter';
        END IF;
        RAISE;
END Drop_Filter;

/*-------------------------------------------------------------------------------------------------------------------
   Drop_Filter   :
      DELETE a Filter metadata AND filter VIEW object
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE  Drop_Filter_Objects
(       p_Tab_Id            IN      NUMBER
    ,   p_Dim_Level_Id      IN      NUMBER
    ,   x_return_status     OUT NOCOPY     VARCHAR2
    ,   x_msg_COUNT         OUT NOCOPY     NUMBER
    ,   x_msg_data          OUT NOCOPY     VARCHAR2
) IS
    l_Count                     NUMBER;
    l_sql                       VARCHAR2(500);
    l_Child_Dim_Level_Id        NUMBER;
    l_Filter_Level_View_Name    BSC_SYS_FILTERS_VIEWS.level_view_name%TYPE;

BEGIN
    ----DBMS_OUTPUT.PUT_LINE('BEGIN Drop_Filter' );
    ----DBMS_OUTPUT.PUT_LINE('Drop_Filter  p_Tab_Id       = ' || p_Tab_Id );
    ----DBMS_OUTPUT.PUT_LINE('Drop_Filter  p_Dim_Level_Id = ' || p_Dim_Level_Id );

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Save point for the current filters view
    SAVEPOINT BcsFiltersPvtDeleteFilterView;

    l_Filter_Level_View_Name := Get_Filter_View_Name(p_Tab_Id, p_Dim_Level_Id);

    ----DBMS_OUTPUT.PUT_LINE('  Drop_Filter  l_Filter_Level_View_Name = ' || l_Filter_Level_View_Name );
    IF (l_Filter_Level_View_Name IS NOT NULL) THEN

        ----DBMS_OUTPUT.PUT_LINE('   SAVEPOINT BcsFiltersPvtDeleteFilterView ');
        ----DBMS_OUTPUT.PUT_LINE('  Drop_Filter  p_Tab_Id = ' || p_Tab_Id );
        ----DBMS_OUTPUT.PUT_LINE('  Drop_Filter  p_Dim_Level_Id = ' || p_Dim_Level_Id );

        --Delete Filter Level View metadata
        DELETE  FROM BSC_SYS_FILTERS_VIEWS
        WHERE   Source_Type  = BSC_DIM_FILTERS_PUB.SOURCE_TYPE_TAB
        AND     Source_Code  = p_Tab_Id
        AND     Dim_Level_Id = p_Dim_Level_Id;

        ----DBMS_OUTPUT.PUT_LINE('  DELETE FROM BSC_SYS_FILTERS_VIEWS ' );

        -- Delete Filter Level Values metadata
        DELETE  FROM BSC_SYS_FILTERS
        WHERE   Source_Type     =   BSC_DIM_FILTERS_PUB.SOURCE_TYPE_TAB
        AND     Source_Code     =   p_Tab_Id
        AND     Dim_Level_Id    =   p_Dim_Level_Id;

        ----DBMS_OUTPUT.PUT_LINE('  BSC_SYS_FILTERS ' );

        -- Syscronize Filters metadata with KPI dim obj metadat
        Synch_Fiters_And_Kpi_Dim
        (       p_Tab_Id            => p_Tab_Id
            ,   x_return_status     => x_return_status
            ,   x_msg_COUNT         => x_msg_COUNT
            ,   x_msg_data          => x_msg_data
        );
        -------------------------------------------
        -- Drop View Object
        --------------------------------------------
        -- sql_to_validate IF the filter view exists
        SELECT  COUNT(OBJECT_NAME)
        INTO    l_Count
        FROM    USER_OBJECTS
        WHERE   OBJECT_NAME = l_Filter_Level_View_Name ;

        -- IF COUNT <> 0 means view exists and must to be delteted
        IF (l_Count <> 0) THEN
            -- sql_to_drop_view
            l_sql:= 'DROP VIEW ' ||l_Filter_Level_View_Name ;
            BSC_APPS.Init_Bsc_Apps;
            --BSC_APPS.do_ddl(l_sql,x_statement_type, l_Filter_Level_View_Name);
            BSC_APPS.Execute_DDL(l_sql);
            --BSC_APPS.DO_DDL_AT(l_sql, ad_ddl.drop_view, l_Filter_Level_View_Name,
            --                BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            -- we need to commit after delete the view to ensure the View objects match
            -- with the metadata defined for the View.
            ----DBMS_OUTPUT.PUT_LINE('  Deleted Filter View : ' || l_Filter_Level_View_Name );
        END IF;
        --------------------------------------------
    END IF;

    ----DBMS_OUTPUT.PUT_LINE('END Drop_Filter  p_Tab_Id = ' || p_Tab_Id || ' p_Dim_Level_Id = ' || p_Dim_Level_Id );
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BcsFiltersPvtDeleteFilterView;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_And_Get
        (   p_encoded =>  FND_API.G_FALSE
          , p_COUNT   =>  x_msg_COUNT
          , p_data    =>  x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BcsFiltersPvtDeleteFilterView;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
           x_msg_data := x_msg_data||' -> BSC_DIM_FILTERS_PVT.Drop_Filter_Objects';
        ELSE
           x_msg_data := SQLERRM||' at BSC_DIM_FILTERS_PVT.Drop_Filter_Objects';
        END IF;
        RAISE;
END Drop_Filter_Objects;

PROCEDURE Synch_Fiters_And_Kpi_Dim
(       p_Tab_Id            IN      NUMBER
    ,   x_return_status     OUT NOCOPY     VARCHAR2
    ,   x_msg_COUNT         OUT NOCOPY     NUMBER
    ,   x_msg_data          OUT NOCOPY     VARCHAR2
) IS
    l_indicator         NUMBER;
    l_kpi_flag          NUMBER;

    l_Sys_Table_Name    BSC_SYS_DIM_LEVELS_B.Level_Table_Name%TYPE;
    l_Sys_View_Name     BSC_SYS_DIM_LEVELS_B.Level_View_Name%TYPE;
    l_Kpi_View_Name     BSC_KPI_DIM_LEVELS_B.Level_View_Name%TYPE;
    l_New_View_Name     BSC_KPI_DIM_LEVELS_B.Level_View_Name%TYPE;

    -- CURSOT to get the KPI Dimension Levels that need to be synchronize with the
    -- tab dimension filters

    CURSOR  c_Kpi_Dim_Obj_To_Synch IS
    SELECT  DISTINCT KD.INDICATOR  --Distinct need it
         ,  SD.Level_Table_Name     SYS_TABLE
         ,  SD.Level_View_Name      SYS_VIEW
         ,  KD.Level_View_Name      KPI_VIEW
         ,  NVL(FV.Level_View_Name, SD.Level_View_Name) NEW_VIEW
    FROM    BSC_TAB_INDICATORS      TI
         ,  BSC_KPI_DIM_LEVELS_B    KD
         ,  BSC_SYS_DIM_LEVELS_B    SD
         ,  (
             SELECT *
             FROM BSC_SYS_FILTERS_VIEWS A
             WHERE A.Source_Type  = BSC_DIM_FILTERS_PUB.SOURCE_TYPE_TAB
                AND A.Source_Code = p_Tab_Id
             ) FV
    WHERE   TI.Tab_Id               = p_Tab_Id
    AND     KD.INDICATOR            = TI.INDICATOR
    AND     KD.Level_Table_Name     = SD.Level_Table_Name
    AND     FV.Level_Table_Name(+)        = KD.Level_Table_Name
    AND     (  NVL(FV.Level_View_Name, SD.Level_View_Name) <> KD.Level_View_Name
    --               OR KD.Level_View_Name IS NULL
            );

-- Cursor to syncronize KPI NOT assigned to any scorecard:

   CURSOR  c_Kpi_Dim_Obj_To_Synch2 IS
    SELECT  DISTINCT KD.INDICATOR  --Distinct need it
         ,  SD.Level_Table_Name     SYS_TABLE
         ,  SD.Level_View_Name      SYS_VIEW
         ,  KD.Level_View_Name      KPI_VIEW
    FROM    BSC_TAB_INDICATORS      TI
         ,  BSC_KPI_DIM_LEVELS_B    KD
         ,  BSC_SYS_DIM_LEVELS_B    SD
    WHERE   KD.INDICATOR            = TI.INDICATOR (+)
    AND     TI.Tab_Id               IS NULL
    AND     KD.Level_Table_Name     = SD.Level_Table_Name
    AND     KD.Level_View_Name <> SD.Level_View_Name;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT  BcsFiltersPvtSynchKpiDim;
    ----DBMS_OUTPUT.PUT_LINE('BEGIN Synch_Fiters_And_Kpi_Dim' );

IF p_Tab_Id IS NOT NULL THEN

    OPEN c_Kpi_Dim_Obj_To_Synch;
        ----DBMS_OUTPUT.PUT_LINE('  OPEN c_Kpi_Dim_Obj_To_Synch; ');
        LOOP
            FETCH   c_Kpi_Dim_Obj_To_Synch
            INTO    l_indicator
                  , l_Sys_Table_Name
                  , l_Sys_View_Name
                  , l_Kpi_View_Name
                  , l_New_View_Name;

            EXIT WHEN c_Kpi_Dim_Obj_To_Synch%NOTFOUND;

            -- update table BSC_KPI_DIM_LEVELS_B
            UPDATE  BSC_KPI_DIM_LEVELS_B
            SET     Level_View_Name     = l_New_View_Name
            WHERE   INDICATOR           = l_indicator
            AND     Level_Table_Name    = l_Sys_Table_Name;

            ----DBMS_OUTPUT.PUT_LINE(' Upated BSC_KPI_DIM_LEVELS_B for INDICATOR = ' ||  l_indicator  || ' AND LEVEL_TABLE_NAME = ' || l_New_View_Name  );

            -- Update KPI Prototype flag
            IF (l_Kpi_View_Name = l_Sys_View_Name) THEN
                --It change from No-Filter To Filter
                l_kpi_flag := 1;
            ELSIF (l_New_View_Name = l_Sys_View_Name) THEN
                -- It change from To Filter to No-Filter
                l_kpi_flag := 1;
            ELSE
                -- It change from To Filter to Filter
                l_kpi_flag := 6;
            END IF;
            BSC_DESIGNER_PVT.ActionFlag_Change
            (   x_indicator => l_indicator
              , x_newflag   => l_kpi_flag
            );
            ----DBMS_OUTPUT.PUT_LINE( ' flag 2' );
        END LOOP;
    CLOSE c_Kpi_Dim_Obj_To_Synch;

ELSE

    OPEN c_Kpi_Dim_Obj_To_Synch2;
        ----DBMS_OUTPUT.PUT_LINE('  OPEN c_Kpi_Dim_Obj_To_Synch2; ');
        LOOP
            FETCH   c_Kpi_Dim_Obj_To_Synch2
            INTO    l_indicator
                  , l_Sys_Table_Name
                  , l_Sys_View_Name
                  , l_Kpi_View_Name;

            EXIT WHEN c_Kpi_Dim_Obj_To_Synch2%NOTFOUND;

            -- update table BSC_KPI_DIM_LEVELS_B
            UPDATE  BSC_KPI_DIM_LEVELS_B
            SET     Level_View_Name     = l_Sys_View_Name
            WHERE   INDICATOR           = l_indicator
            AND     Level_Table_Name    = l_Sys_Table_Name;

            ----DBMS_OUTPUT.PUT_LINE(' Upated BSC_KPI_DIM_LEVELS_B for INDICATOR = ' ||  l_indicator  || ' AND LEVEL_TABLE_NAME = ' || l_Sys_View_Name  );
        END LOOP;
    CLOSE c_Kpi_Dim_Obj_To_Synch2;

END IF;

    ----DBMS_OUTPUT.PUT_LINE('END Synch_Fiters_And_Kpi_Dim' );
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_Kpi_Dim_Obj_To_Synch%ISOPEN) THEN
            CLOSE c_Kpi_Dim_Obj_To_Synch;
        END IF;
        IF (c_Kpi_Dim_Obj_To_Synch2%ISOPEN) THEN
            CLOSE c_Kpi_Dim_Obj_To_Synch;
        END IF;
        ROLLBACK TO BcsFiltersPvtSynchKpiDim;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_And_Get
        (   p_encoded =>  FND_API.G_FALSE
          , p_COUNT   =>  x_msg_COUNT
          , p_data    =>  x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        IF (c_Kpi_Dim_Obj_To_Synch%ISOPEN) THEN
          CLOSE c_Kpi_Dim_Obj_To_Synch;
        END IF;
        IF (c_Kpi_Dim_Obj_To_Synch%ISOPEN) THEN
            CLOSE c_Kpi_Dim_Obj_To_Synch2;
        END IF;
        ROLLBACK TO BcsFiltersPvtSynchKpiDim;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
           x_msg_data := x_msg_data ||' -> BSC_DIM_FILTERS_PVT.Synch_Fiters_And_Kpi_Dim ';
        ELSE
           x_msg_data := SQLERRM ||' at BSC_DIM_FILTERS_PVT.Synch_Fiters_And_Kpi_Dim ';
        END IF;
        RAISE;
END Synch_Fiters_And_Kpi_Dim;


END BSC_DIM_FILTERS_PVT;

/
