--------------------------------------------------------
--  DDL for Package Body BSC_DIM_FILTERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DIM_FILTERS_PUB" AS
/* $Header: BSCPFDLB.pls 120.4 2007/02/23 10:41:26 psomesul ship $ */
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
REM | 12-APR-2004 PAJOHRI  Bug #3426566, added a new function               |
REM |                      Get_Filter_View_Name                             |
REM | 16-12-2006 PSOMESUL E#5678943 MIGRATE COMMON DIMENSIONS AND DIMENSION FILTERS TO SCORECARD DESIGNER|
REM +=======================================================================+
*/

/*-----------------------------------------------------------------------------
 Check_Filters_Not_Apply:
   This procedure will check for filters that NOT apply any more to the tabs
   It will made one of the next options:
   1. Check for a all the dimension object in a specIFic tab
      WHEN  p_Dim_Level_Id IS NULL and p_Tab_Id IS NOT NULL
-----------------------------------------------------------------------------*/
PROCEDURE Check_Filters_Not_Apply
(       p_Tab_Id         IN  NUMBER := NULL
    ,   x_return_status  OUT NOCOPY VARCHAR2
    ,   x_msg_COUNT      OUT NOCOPY NUMBER
    ,   x_msg_data       OUT NOCOPY VARCHAR2
) IS
    l_Tab_Id                 NUMBER;
    -- Cursor to get all tab with filter views
    CURSOR  c_Tabs_With_Filters IS
    SELECT  DISTINCT Source_Code   -- Distinct need it
    FROM    BSC_SYS_FILTERS_VIEWS
    WHERE   Source_Type = BSC_DIM_FILTERS_PUB.SOURCE_TYPE_TAB;

BEGIN
    SAVEPOINT CheckFiltersNotApply;
    --DBMS_OUTPUT.PUT_LINE('BEGIN Check_Filters_Not_Apply' );
    --DBMS_OUTPUT.PUT_LINE('Check_Filters_Not_Apply   p_Tab_Id = ' || p_Tab_Id  );

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_Tab_Id IS NOT NULL) THEN

        --INSERT INTO TESTBUG values('Check_Filters_Not_Apply pub-->'|| to_char(p_Tab_Id));
        --commit;

            BSC_DIM_FILTERS_PVT.Check_Filters_Not_Apply
            (    p_Tab_Id         => p_Tab_Id
                ,x_return_status  => x_return_status
                ,x_msg_COUNT      => x_msg_COUNT
                ,x_msg_data       => x_msg_data
            );
    ELSE
        -- SQL to the the tabs with filters:
        OPEN c_tabs_with_filters;
        LOOP
            FETCH c_tabs_with_filters
            INTO  l_Tab_Id;

            EXIT WHEN c_tabs_with_filters%NOTFOUND;
            BSC_DIM_FILTERS_PVT.Check_Filters_Not_Apply
            (    p_Tab_Id         => l_Tab_Id
                ,x_return_status  => x_return_status
                ,x_msg_COUNT      => x_msg_COUNT
                ,x_msg_data       => x_msg_data
            );
        END LOOP;
        CLOSE c_tabs_with_filters;
    END IF;
    --DBMS_OUTPUT.PUT_LINE('END Check_Filters_Not_Apply' );
EXCEPTION
/*
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_tabs_with_filters%ISOPEN) THEN
            CLOSE c_tabs_with_filters;
        END IF;
        ROLLBACK TO CheckFiltersNotApply;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.COUNT_And_Get
        (   p_encoded =>  FND_API.G_FALSE
          , p_COUNT   =>  x_msg_COUNT
          , p_data    =>  x_msg_data
        );
        RAISE;
*/
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_tabs_with_filters%ISOPEN) THEN
            CLOSE c_tabs_with_filters;
        END IF;
        ROLLBACK TO CheckFiltersNotApply;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_And_Get
        (   p_encoded =>  FND_API.G_FALSE
          , p_COUNT   =>  x_msg_COUNT
          , p_data    =>  x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        IF (c_tabs_with_filters%ISOPEN) THEN
            CLOSE c_tabs_with_filters;
        END IF;
        ROLLBACK TO CheckFiltersNotApply;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_And_Get
        (   p_encoded =>  FND_API.G_FALSE
          , p_COUNT   =>  x_msg_COUNT
          , p_data    =>  x_msg_data
        );
        RAISE;
END  Check_Filters_Not_Apply;

PROCEDURE Check_Filters_Not_Apply_By_KPI
(       p_Kpi_Id                IN              BSC_KPIS_B.Indicator%TYPE
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
    CURSOR c_Filters_Tab IS
    SELECT DISTINCT C.Source_Code
    FROM   BSC_TAB_INDICATORS     A
         , BSC_KPIS_B             B
         , BSC_SYS_FILTERS_VIEWS  C
    WHERE  A.Indicator    = B.Indicator
    AND    C.Source_Type  = BSC_DIM_FILTERS_PUB.Source_Type_Tab
    AND    C.Source_Code  = A.Tab_Id
    AND    ((B.Indicator  = p_kpi_id) OR (B.Source_Indicator = p_kpi_id));

BEGIN
    --DBMS_OUTPUT.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Check_Filters_Not_Apply Procedure');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR cd IN c_Filters_Tab LOOP

        --INSERT INTO TESTBUG values('Now deleting -->'|| to_char(cd.Source_Code));
        --commit;

        BSC_DIM_FILTERS_PUB.Check_Filters_Not_Apply
        (       p_Tab_Id         =>  cd.Source_Code
            ,   x_return_status  =>  x_return_status
            ,   x_msg_count      =>  x_msg_count
            ,   x_msg_data       =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Check_Filters_Not_Apply Failed: at BSC_DIM_FILTERS_PUB.Check_Filters_Not_Apply');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;

    --DBMS_OUTPUT.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Check_Filters_Not_Apply Procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
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
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_FILTERS_PUB.Check_Filters_Not_Apply_By_KPI ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_FILTERS_PUB.Check_Filters_Not_Apply_By_KPI ';
        END IF;
END Check_Filters_Not_Apply_By_KPI;

/*-------------------------------------------------------------------------------------------------------------------
   Drop_Filter   :
      Delete a Filter View a and make cascading delete for child dimension Filter views
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE  Drop_Filter
(       p_Tab_Id            IN      NUMBER
    ,   p_Dim_Level_Id      IN      NUMBER
    ,   x_return_status     OUT NOCOPY     VARCHAR2
    ,   x_msg_COUNT         OUT NOCOPY     NUMBER
    ,   x_msg_data          OUT NOCOPY     VARCHAR2
) IS

BEGIN

        BSC_DIM_FILTERS_PVT.Drop_Filter  (
                        p_Tab_Id        => p_Tab_Id
                    ,   p_Dim_Level_Id  => p_Dim_Level_Id
                    ,   x_return_status => x_return_status
                    ,   x_msg_COUNT     => x_msg_COUNT
                    ,   x_msg_data      => x_msg_data
       );


    --DBMS_OUTPUT.PUT_LINE('END Drop_Filter  p_Tab_Id = ' || p_Tab_Id || ' p_Dim_Level_Id = ' || p_Dim_Level_Id );
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_And_Get
        (   p_encoded =>  FND_API.G_FALSE
          , p_COUNT   =>  x_msg_COUNT
          , p_data    =>  x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
           x_msg_data := x_msg_data||' -> BSC_DIM_FILTERS_PUB.Drop_Filter';
        ELSE
           x_msg_data := SQLERRM||' at BSC_DIM_FILTERS_PUB.Drop_Filter';
        END IF;
        RAISE;
END Drop_Filter;

PROCEDURE Synch_Fiters_And_Kpi_Dim
(       p_Tab_Id            IN      NUMBER
    ,   x_return_status     OUT NOCOPY     VARCHAR2
    ,   x_msg_COUNT         OUT NOCOPY     NUMBER
    ,   x_msg_data          OUT NOCOPY     VARCHAR2
) IS

BEGIN
    SAVEPOINT  BcsFiltersPubSynchKpiDim;

    BSC_DIM_FILTERS_PVT.Synch_Fiters_And_Kpi_Dim
       (       p_Tab_Id            =>  p_Tab_Id
           ,   x_return_status     =>  x_return_status
           ,   x_msg_COUNT         =>  x_msg_COUNT
           ,   x_msg_data          =>  x_msg_data
       );

    --DBMS_OUTPUT.PUT_LINE('END Synch_Fiters_And_Kpi_Dim' );
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BcsFiltersPubSynchKpiDim;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_And_Get
        (   p_encoded =>  FND_API.G_FALSE
          , p_COUNT   =>  x_msg_COUNT
          , p_data    =>  x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BcsFiltersPubSynchKpiDim;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
           x_msg_data := x_msg_data ||' -> BSC_DIM_FILTERS_PUB.Synch_Fiters_And_Kpi_Dim ';
        ELSE
           x_msg_data := SQLERRM ||' at BSC_DIM_FILTERS_PUB.Synch_Fiters_And_Kpi_Dim ';
        END IF;
        RAISE;
END Synch_Fiters_And_Kpi_Dim;


PROCEDURE Drop_Filter_By_Dim_Obj
(       p_Dim_Level_Id   IN  NUMBER
    ,   x_return_status  OUT NOCOPY VARCHAR2
    ,   x_msg_COUNT      OUT NOCOPY NUMBER
    ,   x_msg_data       OUT NOCOPY VARCHAR2
) IS
    l_tab_id                 NUMBER;

    -- SQL to get the Tab_Ids where the dimension has filters
    CURSOR  c_Tabs_With_Current_Dim_Obj IS
    SELECT  Source_Code     TAB_ID
    FROM    BSC_SYS_FILTERS_VIEWS
    WHERE   Dim_Level_Id = p_Dim_Level_Id;
BEGIN
    --DBMS_OUTPUT.PUT_LINE(' BEGIN Drop_Filter_By_Dim_Obj ');
    --DBMS_OUTPUT.PUT_LINE('     p_Dim_Level_Id = ' || p_Dim_Level_Id);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SAVEPOINT BcsFiltersPubDelFilterViewBDO;

    OPEN c_tabs_with_current_dim_obj;
        LOOP
            FETCH c_Tabs_With_Current_Dim_Obj
            INTO  l_Tab_Id;

            EXIT WHEN c_tabs_with_current_dim_obj%NOTFOUND;

            --DBMS_OUTPUT.PUT_LINE(' call Drop_Filter_By_Dim_Obj for Tab_Id = ' || l_Tab_Id);
            BSC_DIM_FILTERS_PUB.Drop_Filter
            (       p_Tab_Id           => l_Tab_Id
                ,   p_Dim_Level_Id     => p_Dim_Level_Id
                ,   x_return_status    => x_return_status
                ,   x_msg_COUNT        => x_msg_COUNT
                ,   x_msg_data         => x_msg_data
            );
        END LOOP;
    CLOSE c_tabs_with_current_dim_obj;
    --DBMS_OUTPUT.PUT_LINE(' END Drop_Filter_By_Dim_Obj ');
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_tabs_with_current_dim_obj%ISOPEN) THEN
            CLOSE c_tabs_with_current_dim_obj;
        END IF;
        ROLLBACK TO BcsFiltersPubDelFilterViewBDO;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_And_Get
        (   p_encoded =>  FND_API.G_FALSE
          , p_COUNT   =>  x_msg_COUNT
          , p_data    =>  x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        IF (c_tabs_with_current_dim_obj%ISOPEN) THEN
            CLOSE c_tabs_with_current_dim_obj;
        END IF;
        ROLLBACK TO BcsFiltersPubDelFilterViewBDO;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
           x_msg_data := x_msg_data||' -> BSC_DIM_FILTERS_PUB.Drop_Filter_By_Dim_Obj';
        ELSE
           x_msg_data := SQLERRM||' at BSC_DIM_FILTERS_PUB.Drop_Filter_By_Dim_Obj';
        END IF;
        RAISE;
END Drop_Filter_By_Dim_Obj;


PROCEDURE Drop_Filter_By_Tab
(       p_Tab_Id         IN  NUMBER
    ,   x_return_status  OUT NOCOPY VARCHAR2
    ,   x_msg_COUNT      OUT NOCOPY NUMBER
    ,   x_msg_data       OUT NOCOPY VARCHAR2
) IS

    -- Cursors to get the Dim_Obj with firters in the current tab
    CURSOR  c_dim_filters IS
    SELECT  Dim_Level_Id
    FROM    BSC_SYS_FILTERS_VIEWS
    WHERE   Source_Code = p_Tab_Id;

    l_Dim_Level_id           NUMBER;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT BcsFiltersPubDelFilterViewBT;
    --DBMS_OUTPUT.PUT_LINE(' BEGIN Drop_Filter_By_Tab ');
    --DBMS_OUTPUT.PUT_LINE('      p_Tab_Id = ' || p_Tab_Id);

    OPEN c_dim_filters;
        LOOP
            FETCH c_dim_filters
            INTO  l_Dim_Level_id;

            EXIT WHEN c_dim_filters%NOTFOUND;
            --DBMS_OUTPUT.PUT_LINE(' call Drop_Filter_By_Tab  --   l_Dim_Level_id  = ' || l_Dim_Level_id);

            BSC_DIM_FILTERS_PUB.Drop_Filter
            (       p_Tab_Id           => p_Tab_Id
                ,   p_Dim_Level_Id     => l_Dim_Level_id
                ,   x_return_status    => x_return_status
                ,   x_msg_COUNT        => x_msg_COUNT
                ,   x_msg_data         => x_msg_data
            );
        END LOOP;
    CLOSE c_dim_filters;
    --DBMS_OUTPUT.PUT_LINE(' END Drop_Filter_By_Tab ');
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_dim_filters%ISOPEN) THEN
            CLOSE c_dim_filters;
        END IF;
        ROLLBACK TO BcsFiltersPubDelFilterViewBT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.COUNT_And_Get
        (   p_encoded =>  FND_API.G_FALSE
          , p_COUNT   =>  x_msg_COUNT
          , p_data    =>  x_msg_data
        );
        RAISE;
    WHEN OTHERS THEN
        IF (c_dim_filters%ISOPEN) THEN
            CLOSE c_dim_filters;
        END IF;
        ROLLBACK TO BcsFiltersPubDelFilterViewBT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
           x_msg_data := x_msg_data||' -> BSC_DIM_FILTERS_PUB.Drop_Filter_By_Tab';
        ELSE
           x_msg_data := SQLERRM||' at BSC_DIM_FILTERS_PUB.Drop_Filter_By_Tab';
        END IF;
        RAISE;
END Drop_Filter_By_Tab;

/********************************************************************************
      Function to return Filter View Name on the basis of KPI Id and Dim Level Id.
      This is used in cascading the data through PMD while creating new entries
      in BSC_KPI_DIM_LEVELS_B table
      This function will return NULL if no view exists
********************************************************************************/
FUNCTION Get_Filter_View_Name
(   p_Kpi_Id        IN  BSC_KPIS_B.Indicator%TYPE
  , p_Dim_Level_Id  IN  BSC_SYS_DIM_LEVELS_B.Dim_Level_Id%TYPE
) RETURN VARCHAR2
IS
    CURSOR c_Filter_View_Name IS
    SELECT B.Level_View_Name
    FROM   BSC_TAB_INDICATORS     A
         , BSC_SYS_FILTERS_VIEWS  B
    WHERE  A.Indicator     =  p_Kpi_Id
    AND    B.Dim_Level_Id  =  p_Dim_Level_Id
    AND    B.Source_Code   =  A.Tab_Id
    AND    B.Source_Type   =  BSC_DIM_FILTERS_PUB.Source_Type_Tab;

    l_Filter_View_Name     BSC_KPI_DIM_LEVELS_B.Level_View_Name%TYPE := NULL;
BEGIN
    IF (c_Filter_View_Name%ISOPEN) THEN
        CLOSE c_Filter_View_Name;
    END IF;
    OPEN c_Filter_View_Name;
        FETCH   c_Filter_View_Name INTO l_Filter_View_Name;
    CLOSE c_Filter_View_Name;
    RETURN  l_Filter_View_Name;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_Filter_View_Name%ISOPEN) THEN
            CLOSE c_Filter_View_Name;
        END IF;
        RETURN NULL;
END Get_Filter_View_Name;




END BSC_DIM_FILTERS_PUB;

/
