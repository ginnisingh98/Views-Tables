--------------------------------------------------------
--  DDL for Package Body BSC_BIS_DIM_REL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BIS_DIM_REL_PUB" AS
/* $Header: BSCRPMDB.pls 120.12 2006/07/17 07:14:34 ppandey ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCRPMDB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper for Dimension-Relationships, part of PMD APIs     |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 14-FEB-2003 PAJOHRI   Created.                                        |
REM | 21-MAY-2003 ADRAO     Added Incremental Changes                       |
REM | 09-JUN-2003 ADRAO     Added Granular Locking                          |
REM | 18-JUL-2003 Pradeep   VL used in place of TL for NLS Bug#3053793      |
REM | 11-AUG-2003 ADEULGAO  fixed bug#3081595                               |
REM | 12-AUG-2003 ADRAO     Added new index for Loader Performance for      |
REM |                       for Dimension Object tables  Bug#3090828        |
REM | 20-OCT-2003 PAJOHRI   Bug#3179995                                     |
REM | 29-OCT-2003 PAJOHRI   Bug#3120190,Modified API- Create_One_To_N_MTable|
REM |                           to Create Non_Unique Index on 'Master_Table'|
REM |                           for all its parent relation columns.        |
REM | 20-OCT-2003 PAJOHRI   Bug # 3179995                                   |
REM | 04-NOV-2003 PAJOHRI   Bug # 3152258                                   |
REM | 08-DEC-2003 KYADAMAK  Bug #3225685                                    |
REM | 15-DEC-2003 ADRAO     Removed Dynamic SQLs for Bug #3236356           |
REM | 02-JAN-2004 Adeulgao  fixed bug#3343898                               |
REM | 28-JAN-2004 ADRAO     Fixed API Assign_New_Dim_Obj_Rels(), to handle  |
REM |                       MxN relationship when the child is updated for  |
REM |                       Bug #3395161                                    |
REM | 19-MAR-2004 PAJOHRI   Bug #3518647, Added a validation for message    |
REM |                       text "BSC_MAX_DIM_OBJ_RELS"  and replaced       |
REM |                       VARCHAR2(8000) size to VARCHAR2(32000)          |
REM | 29-MAR-2004 PAJOHRI   Bug #3530886, Modified tablespaces for tables   |
REM |                       VARCHAR2(8000) size to VARCHAR2(32000)          |
REM | 23-APR-2004 ASHANKAR  Bug #3518610,Added the fucntion Validate        |
REM |                       listbutton                                      |
REM | 15-OCT-2004 ASHANKAR  Bug#3459282 Filter button Validation.           |
REM | 16-FEB-2005 ashankar  Bug#4184438 Added the Synch Up API              |
REM |                       BSC_SYNC_MVLOGS.Sync_dim_table_mv_log           |
REM |  02-May-2005 visuri   Modified for Bug#4323383                        |
REM |  18-Jul-2005 ppandey  Enh #4417483, Restrict Internal/Calendar Dims   |
REM |  12-SEP-2005 adrao    Modified API Assign_Dim_Obj_Rels for Bug4601099 |
REM |  29-SEP-2005 adrao    Modified API Assign_Dim_Obj_Rels for Bug4619393 |
REM | 25-OCT-2005 kyadamak  Removed literals for Enhancement#4618419        |
REM | 27-DEC-2005 kyadamak  Calling BIA API for bug#4875047                 |
REM | 13-jan-2005 ashankar  Bug#4947293  calling the API sync_dimension_table|
REM |                       dynamically                                     |
REM | 31-JAN-2005 adrao     Made a call to Refresh_BSC_PMF_Dim_View() API   |
REM |                       for Bug#4758995                                 |
REM | 01-MAR-2006 adrao     is_KPI_Flag_For_Dim_Obj_Rels Modified for       |
REM |                       Bug#5057436                                     |
REM | 19-JUN-2006 adrao     Bug#5300060 - refresh all the child dimension   |
REM |                                     objects as well                   |
REM | 26-JUN-2006 akoduri   Bug#5335325 - Prototype flag not getting changed|
REM |                       when a BIS dimension object is added to AG Rep  |
REM | 17-JUL-2006 ppandey   Bug#5389895 - Create/Update Relationship issue  |
REM |                                     for non-numeric user code         |
REM +=======================================================================+
*/
CONFIG_LIMIT_RELS             CONSTANT        NUMBER := 5;
MAX_PARENTS_RELS_1_N          CONSTANT        NUMBER := 50;
--==============================================================
TYPE One_To_N_Index_Type IS Record
(       p_Column_Name       VARCHAR2(30)
);
--==============================================================
TYPE One_To_N_Index_Table IS TABLE OF One_To_N_Index_Type INDEX BY BINARY_INTEGER;
--==============================================================
TYPE One_To_N_Original_Type IS Record
(       p_Dim_Obj_ID        BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE
    ,   p_Parent_Dim_Ids    VARCHAR2(32000)
    ,   p_Parent_Count      NUMBER
    ,   p_Refresh_Flag      BOOLEAN
);
--==============================================================
TYPE One_To_N_Org_Table_Type IS TABLE OF One_To_N_Original_Type INDEX BY BINARY_INTEGER;
--==============================================================
TYPE M_To_N_Original_Type IS Record
(       p_Dim_Obj_ID        BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE
    ,   p_Parent_Dim_ID     BSC_SYS_DIM_LEVEL_RELS.parent_dim_level_id%TYPE
    ,   p_Refresh_Flag      BOOLEAN
);
--==============================================================
TYPE M_To_N_Org_Table_Type IS TABLE OF M_To_N_Original_Type INDEX BY BINARY_INTEGER;
--==============================================================
TYPE Relation_Original_Type IS Record
(       p_Dim_Obj_ID        BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE
    ,   p_Parent_Dim_Id     BSC_SYS_DIM_LEVEL_RELS.parent_dim_level_id%TYPE
    ,   p_Relation_Type     BSC_SYS_DIM_LEVEL_RELS.relation_type%TYPE
    ,   p_Refresh_Flag      BOOLEAN
    ,   p_Refresh_No        NUMBER
);

TYPE Relation_Table_Type IS TABLE OF Relation_Original_Type INDEX BY BINARY_INTEGER;

FUNCTION is_more
(       x_remain_id             IN  OUT     NOCOPY  VARCHAR2
    ,   x_remain_rel_type       IN  OUT     NOCOPY  VARCHAR2
    ,   x_remain_rel_column     IN  OUT     NOCOPY  VARCHAR2
    ,   x_remain_data_type      IN  OUT     NOCOPY  VARCHAR2
    ,   x_remain_data_source    IN  OUT     NOCOPY  VARCHAR2
    ,   x_id                        OUT     NOCOPY  NUMBER
    ,   x_rel_type                  OUT     NOCOPY  NUMBER
    ,   x_rel_column                OUT     NOCOPY  VARCHAR2
    ,   x_data_type                 OUT     NOCOPY  VARCHAR2
    ,   x_data_source               OUT     NOCOPY  VARCHAR2
) RETURN BOOLEAN;
--==============================================================
FUNCTION Create_One_To_N_MTable
(       p_dim_obj_id        IN          NUMBER
    ,   x_return_status     OUT NOCOPY  VARCHAR2
    ,   x_msg_count         OUT NOCOPY  NUMBER
    ,   x_msg_data          OUT NOCOPY  VARCHAR2
) RETURN   BOOLEAN;
--==============================================================
FUNCTION Create_M_To_N_MTable
(       p_dim_obj_id        IN          NUMBER
    ,   p_parent_id         IN          VARCHAR2
    ,   x_return_status     OUT NOCOPY  VARCHAR2
    ,   x_msg_count         OUT NOCOPY  NUMBER
    ,   x_msg_data          OUT NOCOPY  VARCHAR2
) RETURN   BOOLEAN;
--==============================================================
PROCEDURE Drop_M_To_N_Unused_Tabs
(       p_dim_obj_id        IN          NUMBER
    ,   p_parent_id         IN          VARCHAR2
    ,   x_return_status     OUT NOCOPY  VARCHAR2
    ,   x_msg_count         OUT NOCOPY  NUMBER
    ,   x_msg_data          OUT NOCOPY  VARCHAR2
);

/*********************************************************************************
                  FUNCTION Get_Original_Child_Ids, Bug#5300060
*********************************************************************************/
FUNCTION Get_Original_Child_Ids
(
    p_dim_obj_id  IN  NUMBER
) RETURN VARCHAR2;

--==============================================================
FUNCTION Is_More
(       x_remain_id             IN  OUT     NOCOPY  VARCHAR2
    ,   x_remain_rel_type       IN  OUT     NOCOPY  VARCHAR2
    ,   x_id                        OUT     NOCOPY  NUMBER
    ,   x_rel_type                  OUT     NOCOPY  NUMBER
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
BEGIN
    IF (x_remain_id IS NOT NULL) THEN
        l_pos_ids           := INSTR(x_remain_id,            ',');
        l_pos_rel_types     := INSTR(x_remain_rel_type,      ',');

        IF (l_pos_ids > 0) THEN
            x_id                    :=  TO_NUMBER(TRIM(SUBSTR(x_remain_id,           1,    l_pos_ids - 1)));
            x_rel_type              :=  TO_NUMBER(TRIM(SUBSTR(x_remain_rel_type,     1,    l_pos_rel_types   - 1)));

            x_remain_id             :=  TRIM(SUBSTR(x_remain_id,            l_pos_ids + 1));
            x_remain_rel_type       :=  TRIM(SUBSTR(x_remain_rel_type,      l_pos_rel_types + 1));
        ELSE
            x_id                    :=  TO_NUMBER(TRIM(x_remain_id));
            x_rel_type              :=  TO_NUMBER(TRIM(x_remain_rel_type));

            x_remain_id             :=  NULL;
            x_remain_rel_type       :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;
--==============================================================
FUNCTION Is_More
(       p_dim_lev_ids   IN  OUT NOCOPY  VARCHAR2
    ,   p_dim_lev_id        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
    l_pos_rel_columns       NUMBER;
BEGIN
    IF (p_dim_lev_ids IS NOT NULL) THEN
        l_pos_ids           := INSTR(p_dim_lev_ids,   ',');
        IF (l_pos_ids > 0) THEN
            p_dim_lev_id      :=  TRIM(SUBSTR(p_dim_lev_ids,    1,    l_pos_ids - 1));
            p_dim_lev_ids     :=  TRIM(SUBSTR(p_dim_lev_ids,    l_pos_ids + 1));
        ELSE
            p_dim_lev_id      :=  TRIM(p_dim_lev_ids);
            p_dim_lev_ids     :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;
--==============================================================
PROCEDURE get_Original_Relations
(       p_dim_obj_id        IN              NUMBER
    ,   x_One_N_Table       OUT     NOCOPY  BSC_BIS_DIM_REL_PUB.One_To_N_Org_Table_Type
    ,   x_M_N_Table         OUT     NOCOPY  BSC_BIS_DIM_REL_PUB.M_To_N_Org_Table_Type
    ,   x_return_status     OUT     NOCOPY  VARCHAR2
    ,   x_msg_count         OUT     NOCOPY  NUMBER
    ,   x_msg_data          OUT     NOCOPY  VARCHAR2
) IS
    CURSOR  c_keep_original_rels IS
    SELECT  Dim_Level_Id
          , Parent_Dim_Level_Id
          , Relation_Type
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE  (Parent_Dim_Level_Id = p_dim_obj_id
    AND     Relation_Type      <>  2 )
    OR      Dim_Level_Id        = p_dim_obj_id
    ORDER   BY Dim_Level_Id;

    l_One_N_Count           NUMBER := 0;
    l_M_N_Count             NUMBER := 0;
BEGIN
    --DBMS_OUTPUT.PUT_LINE('Entered inside BSC_BIS_DIM_REL_PUB.get_Original_Relations Procedure');
    x_return_status         := FND_API.G_RET_STS_SUCCESS;
    FOR cd IN c_keep_original_rels LOOP
        --for one to many relations where cd.Relation_Type = 1
        IF ((l_One_N_Count = 0) AND (cd.Relation_Type = 1)) THEN
            x_One_N_Table(l_One_N_Count).p_dim_obj_id       :=  cd.Dim_Level_Id;
            x_One_N_Table(l_One_N_Count).p_Parent_dim_ids   :=  cd.Parent_Dim_Level_Id;
            x_One_N_Table(l_One_N_Count).p_parent_count     :=  1;
            x_One_N_Table(l_One_N_Count).p_refresh_flag     :=  TRUE;
            l_One_N_Count                                   :=  l_One_N_Count + 1;
        ELSIF ((l_One_N_Count <> 0) AND (cd.Relation_Type = 1) AND
               (x_One_N_Table(l_One_N_Count - 1).p_dim_obj_id = cd.Dim_Level_Id)) THEN
            x_One_N_Table(l_One_N_Count-1).p_Parent_dim_ids
                    := x_One_N_Table(l_One_N_Count-1).p_Parent_dim_ids||', '|| cd.Parent_Dim_Level_Id;
            x_One_N_Table(l_One_N_Count-1).p_parent_count
                    := x_One_N_Table(l_One_N_Count-1).p_parent_count + 1;
        ELSIF ((l_One_N_Count <> 0) AND (cd.Relation_Type = 1) AND
               (x_One_N_Table(l_One_N_Count - 1).p_dim_obj_id <> cd.Dim_Level_Id)) THEN
            x_One_N_Table(l_One_N_Count).p_parent_count     :=  1;
            x_One_N_Table(l_One_N_Count).p_dim_obj_id       :=  cd.Dim_Level_Id;
            x_One_N_Table(l_One_N_Count).p_Parent_dim_ids   :=  cd.Parent_Dim_Level_Id;
            x_One_N_Table(l_One_N_Count).p_refresh_flag     :=  TRUE;
            l_One_N_Count                                   :=  l_One_N_Count     + 1;
        END IF;
        --for many to many relations where cd.Relation_Type = 2
        IF (cd.Relation_Type = 2) THEN
            IF (cd.Dim_Level_Id < cd.Parent_Dim_Level_Id) THEN
                x_M_N_Table(l_M_N_Count).p_dim_obj_id       :=  cd.Dim_Level_Id ;
                x_M_N_Table(l_M_N_Count).p_Parent_dim_id    :=  cd.Parent_Dim_Level_Id;
                x_M_N_Table(l_M_N_Count).p_refresh_flag     :=  TRUE;
                l_M_N_Count                                 :=  l_M_N_Count + 1;
            ELSE
                x_M_N_Table(l_M_N_Count).p_dim_obj_id       :=  cd.Parent_Dim_Level_Id;
                x_M_N_Table(l_M_N_Count).p_Parent_dim_id    :=  cd.Dim_Level_Id ;
                x_M_N_Table(l_M_N_Count).p_refresh_flag     :=  TRUE;
                l_M_N_Count                                 :=  l_M_N_Count + 1;
            END IF;
        END IF;
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE('Exiting from BSC_BIS_DIM_REL_PUB.get_Original_Relations Procedure');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.get_Original_Relations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.get_Original_Relations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.get_Original_Relations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.get_Original_Relations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END get_Original_Relations;

/********************************************************************
  PROCEDURE   : store_Relations
  DESCRIPTION : This procedure stores the relationship between
                dimension objects into Cache.
  INPUT       : p_dim_obj_id :Dimension object corresponding to which
                relationship needs to be stored.

  OUPUT       : x_rel_Table : Cache which stores the relationships.
  AUTHOR      : ashankar 25-OCT-2004  BUG 3459282
/*******************************************************************/

PROCEDURE store_Relations
(        p_dim_obj_id       IN              NUMBER
     ,   x_rel_Table        OUT     NOCOPY  BSC_BIS_DIM_REL_PUB.Relation_Table_Type
     ,   x_return_status    OUT     NOCOPY  VARCHAR2
     ,   x_msg_count        OUT     NOCOPY  NUMBER
     ,   x_msg_data         OUT     NOCOPY  VARCHAR2
)IS
    CURSOR c_relations IS
    SELECT  Dim_Level_Id
          , Parent_Dim_Level_Id
          , Relation_Type
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   Parent_Dim_Level_Id = p_dim_obj_id
    OR      Dim_Level_Id        = p_dim_obj_id
    ORDER   BY Dim_Level_Id;

    l_Count     NUMBER;

BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_Count := 0;

     FOR cd IN c_relations LOOP
      x_rel_Table(l_Count).p_Dim_Obj_ID      :=  cd.Dim_Level_Id;
      x_rel_Table(l_Count).p_Parent_Dim_Id   :=  cd.Parent_Dim_Level_Id;
      x_rel_Table(l_Count).p_Relation_Type   :=  cd.Relation_Type;
      x_rel_Table(l_Count).p_Refresh_Flag    :=  FALSE;
      x_rel_Table(l_Count).p_Refresh_No      :=  -1;
      l_Count := l_Count + 1;
    END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.store_Relations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.store_Relations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.store_Relations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.store_Relations ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END store_Relations;

/********************************************************************
  PROCEDURE   : is_Filtered_Applied
  DESCRIPTION : This fucntion tells whether the dimension objects are being
                used in Filter views or not.
  INPUT       : p_dim_level_id :Dimension object corresponding to which
                                Filter views need to be find out.

  OUPUT       : TRUE : Used in Filter views
                FALSE: Not used in Filter Views
  AUTHOR      : ashankar 25-OCT-2004  BUG 3459282
/*******************************************************************/
FUNCTION is_Filtered_Applied
(
 p_dim_level_id      IN  BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE
)RETURN BOOLEAN IS
 l_count   NUMBER;
BEGIN
   SELECT COUNT(0)
   INTO   l_count
   FROM   BSC_SYS_FILTERS_VIEWS
   WHERE  DIM_LEVEL_ID = p_dim_level_id;

   IF(l_count>0)THEN
    RETURN TRUE;
   ELSE
    RETURN FALSE;
   END IF;
END is_Filtered_Applied;

/********************************************************************
  PROCEDURE   : get_Filtered_Tabs
  DESCRIPTION : This procedure returns the comma separated tabs where
                dimension objects are used in filter views.
  INPUT       : p_dim_level_id :
                p_par_dim_level_id

  OUPUT       : p_common_tabs (comma separated tabs where the passed dimension
                 objects are used as filters)
  AUTHOR      : ashankar 25-OCT-2004  BUG 3459282
/*******************************************************************/

PROCEDURE get_Filtered_Tabs
(
        p_dim_level_id          IN              NUMBER
    ,   p_par_dim_level_id      IN              NUMBER
    ,   p_common_tabs           OUT     NOCOPY  VARCHAR2
    ,   x_return_status         OUT     NOCOPY  VARCHAR2
    ,   x_msg_count             OUT     NOCOPY  NUMBER
    ,   x_msg_data              OUT     NOCOPY  VARCHAR2
)IS

    l_dim_level_id        BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE;
    l_common_tabs         VARCHAR2(32000);
    l_par_tab             NUMBER;
    l_child_tab           NUMBER;
    l_Count               NUMBER;


    CURSOR c_filter_par_tabs IS
    SELECT DISTINCT source_code
    FROM   BSC_SYS_FILTERS_VIEWS
    WHERE  source_type  = 1
    AND    dim_level_id = p_par_dim_level_id;

    CURSOR c_filter_chd_tabs  IS
    SELECT DISTINCT source_code
    FROM   BSC_SYS_FILTERS_VIEWS
    WHERE  source_type  = 1
    AND    dim_level_id = p_dim_level_id;

BEGIN
   l_Count := 0;

   IF((p_dim_level_id IS NOT NULL) AND (p_par_dim_level_id IS NOT NULL)) THEN
      FOR  cd_par IN c_filter_par_tabs LOOP
        FOR cd_chd IN c_filter_chd_tabs LOOP
           IF(cd_chd.source_code = cd_par.source_code) THEN
                IF(l_Count = 0) THEN
                    l_common_tabs :=  cd_par.source_code;
                    l_Count       :=  l_Count + 1;
                ELSE
                    l_common_tabs :=  l_common_tabs || ',' || cd_par.source_code;
                END IF;
                EXIT;
           END IF;
        END LOOP;
      END LOOP;
   END IF;
   p_common_tabs := l_common_tabs;

END get_Filtered_Tabs;

/********************************************************************
  PROCEDURE   : Validate_Filtered_Tabs
  DESCRIPTION : This procedure Validates if the dimension objects being passed are used in
                filter views.If yes then it get all the corresponding tabs
                where the filter views need to be dropped.for each tab
                it drops the child filter view.Parent view remains as it is.
  INPUT       : p_dim_level_id :
                p_par_dim_level_id

  OUPUT       : Corresponding filter views for dimension objects are dropped.
  AUTHOR      : ashankar 25-OCT-2004  BUG 3459282
/*******************************************************************/

PROCEDURE Validate_Filtered_Tabs
(
        p_dim_obj_id          IN              BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE
    ,   p_par_dim_obj_id      IN              BSC_SYS_DIM_LEVEL_RELS.parent_dim_level_id%TYPE
    ,   x_return_status       OUT     NOCOPY  VARCHAR2
    ,   x_msg_count           OUT     NOCOPY  NUMBER
    ,   x_msg_data            OUT     NOCOPY  VARCHAR2
)IS
   l_common_tabs         VARCHAR2(32000);
   l_tab                 VARCHAR2(30);
   l_Sql                 VARCHAR2(32000);
   l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
BEGIN
     FND_MSG_PUB.Initialize;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF((p_dim_obj_id IS NOT NULL) AND (p_par_dim_obj_id IS NOT NULL)) THEN
        IF(BSC_BIS_DIM_REL_PUB.is_Filtered_Applied(p_dim_obj_id)
            AND(BSC_BIS_DIM_REL_PUB.is_Filtered_Applied(p_par_dim_obj_id)))THEN

             BSC_BIS_DIM_REL_PUB.get_Filtered_Tabs
             (
                   p_dim_level_id      => p_dim_obj_id
                 , p_par_dim_level_id  => p_par_dim_obj_id
                 , p_common_tabs       => l_common_tabs
                 , x_return_status     => x_return_status
                 , x_msg_Count         => x_msg_count
                 , x_msg_data          => x_msg_data
             );
             IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

             IF(l_common_tabs IS NOT NULL) THEN
                 WHILE (is_more(  p_dim_lev_ids   =>  l_common_tabs
                              ,   p_dim_lev_id    =>  l_tab)
                 )LOOP
                     BSC_DIM_FILTERS_PUB.Drop_Filter
                     (       p_Tab_Id        => l_tab
                         ,   p_Dim_Level_Id  => p_dim_obj_id
                         ,   x_return_status => x_return_status
                         ,   x_msg_COUNT     => x_msg_count
                         ,   x_msg_data      => x_msg_data
                     );
                     IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                 END LOOP;
             END IF;
        ELSIF(BSC_BIS_DIM_REL_PUB.is_Filtered_Applied(p_dim_obj_id)
               AND(NOT BSC_BIS_DIM_REL_PUB.is_Filtered_Applied(p_par_dim_obj_id)))THEN
               /*********************************************************
                Its not possible to have filter applied on child and parent is not
                having the filter applied.If this condition exists then we have to remove
                the filter on the child.
                No need to check for relations because we couldn't have reached here
                if there was no relationship between dimesnion objects.
               /*********************************************************/
            l_Sql := ' SELECT DISTINCT A.TAB_ID '||
                     ' FROM ' ||
                     '     BSC_TABS_VL           A '||
                     '  ,  BSC_TAB_INDICATORS    B '||
                     '  ,  BSC_KPI_DIM_LEVELS_VL C '||
                     '  ,  BSC_SYS_DIM_LEVELS_VL D '||
                     '  WHERE A.TAB_ID =B.TAB_ID   '||
                     '  AND   B.INDICATOR =C.INDICATOR '||
                     '  AND   C.LEVEL_TABLE_NAME = D.LEVEL_TABLE_NAME '||
                     '  AND   D.DIM_LEVEL_ID IN  (:1,:2) ' ;
            OPEN l_cursor FOR l_sql USING p_dim_obj_id,p_par_dim_obj_id;
            LOOP
            FETCH l_cursor INTO l_tab ;
            EXIT WHEN l_cursor%NOTFOUND;
                BSC_DIM_FILTERS_PUB.Drop_Filter
                (       p_Tab_Id        => l_tab
                    ,   p_Dim_Level_Id  => p_dim_obj_id
                    ,   x_return_status => x_return_status
                    ,   x_msg_COUNT     => x_msg_count
                    ,   x_msg_data      => x_msg_data
                 );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END LOOP;
        END IF;
     END IF;


EXCEPTION
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
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Validate_Filtered_Tabs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Validate_Filtered_Tabs ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Validate_Filtered_Tabs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Validate_Filtered_Tabs ';
        END IF;
END Validate_Filtered_Tabs;

/********************************************************************
  PROCEDURE   : Verify_Recreate_Filter_Views
  DESCRIPTION : This procedure validates if the filtered view is fine or it got invalidated.
                This may happen when the underlying view on which filter view is based
                gets modified when more columns are added to it or some columns dropped
                when relationship changes.
  INPUT       : p_source :  Tab_Id
                p_level_view_name :Filter view
                p_dim_level_id    : Dimesnion level id

  OUPUT       : If filter view was invalidated then it will recreate the filter view.
  AUTHOR      : ashankar 25-OCT-2004  BUG 3459282
/*******************************************************************/

PROCEDURE Verify_Recreate_Filter_Views
(
       p_source            IN      NUMBER
    ,  p_level_view_name   IN      BSC_SYS_FILTERS_VIEWS.level_view_name%TYPE
    ,  p_dim_level_id      IN      BSC_SYS_FILTERS_VIEWS.dim_level_id%TYPE
    ,  x_return_status     OUT     NOCOPY  VARCHAR2
    ,  x_msg_count         OUT     NOCOPY  NUMBER
    ,  x_msg_data          OUT     NOCOPY  VARCHAR2
)IS

    l_Sql            VARCHAR2(4000);
    l_code           NUMBER;
    l_count          NUMBER;
    l_user_code      VARCHAR2(100);
    l_name           VARCHAR2(100);
    l_view_text      VARCHAR2(32000);

BEGIN

      FND_MSG_PUB.Initialize;
      x_return_status  := FND_API.G_RET_STS_SUCCESS;
      BSC_APPS.Init_Bsc_Apps;

      IF(BSC_UTILITY.is_View_Exists(p_level_view_name)) THEN
        l_Sql :=    C_SELECT   || C_SELECT_CLAUSE
                 || C_FROM     || p_level_view_name
                 || C_WHERE    || C_WHERE_CLAUSE ;

        EXECUTE IMMEDIATE l_Sql INTO l_code, l_user_code, l_name;
      END IF;
EXCEPTION
 WHEN OTHERS THEN
     IF(SQLCODE =-4063)THEN
       BEGIN

         SELECT count(1)
         INTO   l_count
         FROM   ALL_VIEWS
         WHERE  VIEW_NAME = p_level_view_name
         AND    OWNER = BSC_APPS.get_user_schema('APPS')
         AND    TEXT IS NOT NULL;

         IF(l_count > 0) THEN
            l_Sql := 'ALTER VIEW '|| p_level_view_name ||' COMPILE';

            BSC_APPS.Do_Ddl_AT(l_Sql, ad_ddl.alter_view, p_level_view_name, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
         END IF;

        EXCEPTION
          WHEN OTHERS THEN
           NULL;
        END;
     END IF;
END Verify_Recreate_Filter_Views;

/********************************************************************
  PROCEDURE   : Validate_filter_views
  DESCRIPTION : This procedure validates if the dimension objects are being used
                in filter.If yes then it will validate all the filter views.
  INPUT       : p_dim_obj_id      :  Current dimension object
                x_new_rel_Table   :  New relationship table
                x_prev_rel_Table  :  Old relationship table.

  OUPUT       : If filter view was invalidated then it will recreate the filter view.
  AUTHOR      : ashankar 25-OCT-2004  BUG 3459282
/*******************************************************************/

PROCEDURE Validate_filter_views
(
        p_dim_obj_id       IN              NUMBER
    ,   x_new_rel_Table    IN              BSC_BIS_DIM_REL_PUB.Relation_Table_Type
    ,   x_prev_rel_Table   IN              BSC_BIS_DIM_REL_PUB.Relation_Table_Type
    ,   x_return_status    OUT     NOCOPY  VARCHAR2
    ,   x_msg_count        OUT     NOCOPY  NUMBER
    ,   x_msg_data         OUT     NOCOPY  VARCHAR2
)IS
  CURSOR c_filter_tabs(l_dim_level_id IN NUMBER) IS
  SELECT source_code,level_view_name,dim_level_id
  FROM   BSC_SYS_FILTERS_VIEWS
  WHERE  SOURCE_TYPE=1
  AND    DIM_LEVEL_ID =l_dim_level_id;

  l_tab               NUMBER;
  l_level_view_name   BSC_SYS_FILTERS_VIEWS.level_view_name%TYPE;
  l_dim_level_id      BSC_SYS_FILTERS_VIEWS.dim_level_id%TYPE;

  l_old_count         NUMBER;
  l_new_count         NUMBER;


BEGIN
     FND_MSG_PUB.Initialize;
     x_return_status   := FND_API.G_RET_STS_SUCCESS;

     l_new_count := x_new_rel_Table.COUNT;
     l_old_count := x_prev_rel_Table.COUNT;

     -- for old relationships
     IF(l_old_count>0) THEN
        FOR i IN 0..l_old_count -1 LOOP
           IF(x_prev_rel_Table(i).p_Relation_Type=1) THEN
                IF(BSC_BIS_DIM_REL_PUB.is_Filtered_Applied(x_prev_rel_Table(i).p_Parent_Dim_Id))THEN
                  OPEN c_filter_tabs(x_prev_rel_Table(i).p_Parent_Dim_Id);
                  FETCH c_filter_tabs INTO l_tab,l_level_view_name,l_dim_level_id;
                  WHILE(c_filter_tabs%FOUND)LOOP
                     IF(l_level_view_name IS NOT NULL)THEN
                        BSC_BIS_DIM_REL_PUB.Verify_Recreate_Filter_Views
                        (
                             p_source          => l_tab
                          ,  p_level_view_name => l_level_view_name
                          ,  p_dim_level_id    => l_dim_level_id
                          ,  x_return_status   => x_return_status
                          ,  x_msg_count       => x_msg_count
                          ,  x_msg_data        => x_msg_data
                        );
                        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                     END IF;
                     FETCH c_filter_tabs INTO l_tab,l_level_view_name,l_dim_level_id;
                  END LOOP;
                  CLOSE c_filter_tabs;
                END IF;
           ELSE
               IF(BSC_BIS_DIM_REL_PUB.is_Filtered_Applied(x_prev_rel_Table(i).p_Dim_Obj_ID))THEN
                 OPEN c_filter_tabs(x_prev_rel_Table(i).p_Dim_Obj_ID);
                 FETCH c_filter_tabs INTO l_tab,l_level_view_name,l_dim_level_id;
                 WHILE(c_filter_tabs%FOUND)LOOP
                    IF(l_level_view_name IS NOT NULL)THEN
                       BSC_BIS_DIM_REL_PUB.Verify_Recreate_Filter_Views
                       (
                            p_source          => l_tab
                         ,  p_level_view_name => l_level_view_name
                         ,  p_dim_level_id    => l_dim_level_id
                         ,  x_return_status   => x_return_status
                         ,  x_msg_count       => x_msg_count
                         ,  x_msg_data        => x_msg_data
                       );
                       IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                       END IF;
                    END IF;
                    FETCH c_filter_tabs INTO l_tab,l_level_view_name,l_dim_level_id;
                 END LOOP;
                 CLOSE c_filter_tabs;
              END IF;

              --Now for parent
              IF(BSC_BIS_DIM_REL_PUB.is_Filtered_Applied(x_prev_rel_Table(i).p_Parent_Dim_Id))THEN
                    OPEN c_filter_tabs(x_prev_rel_Table(i).p_Parent_Dim_Id);
                    FETCH c_filter_tabs INTO l_tab,l_level_view_name,l_dim_level_id;
                    WHILE(c_filter_tabs%FOUND)LOOP
                       IF(l_level_view_name IS NOT NULL)THEN
                          BSC_BIS_DIM_REL_PUB.Verify_Recreate_Filter_Views
                          (
                               p_source          => l_tab
                            ,  p_level_view_name => l_level_view_name
                            ,  p_dim_level_id    => l_dim_level_id
                            ,  x_return_status   => x_return_status
                            ,  x_msg_count       => x_msg_count
                            ,  x_msg_data        => x_msg_data
                          );
                          IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                          END IF;
                       END IF;
                       FETCH c_filter_tabs INTO l_tab,l_level_view_name,l_dim_level_id;
                    END LOOP;
                    CLOSE c_filter_tabs;
                END IF;
           END IF;
         END LOOP;
     END IF;

     -- for new relationships
     IF(l_new_count>0) THEN
         FOR j IN 0..l_new_count -1 LOOP
          IF(x_new_rel_Table(j).p_Relation_Type=1) THEN
                IF(BSC_BIS_DIM_REL_PUB.is_Filtered_Applied(x_new_rel_Table(j).p_Parent_Dim_Id))THEN
                    OPEN c_filter_tabs(x_new_rel_Table(j).p_Parent_Dim_Id);
                    FETCH c_filter_tabs INTO l_tab,l_level_view_name,l_dim_level_id;
                    WHILE(c_filter_tabs%FOUND)LOOP
                       IF(l_level_view_name IS NOT NULL)THEN
                          BSC_BIS_DIM_REL_PUB.Verify_Recreate_Filter_Views
                          (
                               p_source          => l_tab
                            ,  p_level_view_name => l_level_view_name
                            ,  p_dim_level_id    => l_dim_level_id
                            ,  x_return_status   => x_return_status
                            ,  x_msg_count       => x_msg_count
                            ,  x_msg_data        => x_msg_data
                          );
                          IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                          END IF;
                       END IF;
                       FETCH c_filter_tabs INTO l_tab,l_level_view_name,l_dim_level_id;
                    END LOOP;
                    CLOSE c_filter_tabs;
                END IF;
            ELSE
                IF(BSC_BIS_DIM_REL_PUB.is_Filtered_Applied(x_new_rel_Table(j).p_Dim_Obj_ID))THEN
                    OPEN c_filter_tabs(x_new_rel_Table(j).p_Dim_Obj_ID);
                    FETCH c_filter_tabs INTO l_tab,l_level_view_name,l_dim_level_id;
                    WHILE(c_filter_tabs%FOUND)LOOP
                       IF(l_level_view_name IS NOT NULL)THEN
                          BSC_BIS_DIM_REL_PUB.Verify_Recreate_Filter_Views
                          (
                               p_source          => l_tab
                            ,  p_level_view_name => l_level_view_name
                            ,  p_dim_level_id    => l_dim_level_id
                            ,  x_return_status   => x_return_status
                            ,  x_msg_count       => x_msg_count
                            ,  x_msg_data        => x_msg_data
                          );
                          IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                          END IF;
                       END IF;
                       FETCH c_filter_tabs INTO l_tab,l_level_view_name,l_dim_level_id;
                    END LOOP;
                    CLOSE c_filter_tabs;
                END IF;

                         --Now for parent
                IF(BSC_BIS_DIM_REL_PUB.is_Filtered_Applied(x_new_rel_Table(j).p_Parent_Dim_Id))THEN
                    OPEN c_filter_tabs(x_new_rel_Table(j).p_Parent_Dim_Id);
                    FETCH c_filter_tabs INTO l_tab,l_level_view_name,l_dim_level_id;
                    WHILE(c_filter_tabs%FOUND)LOOP
                      IF(l_level_view_name IS NOT NULL)THEN
                         BSC_BIS_DIM_REL_PUB.Verify_Recreate_Filter_Views
                         (
                              p_source          => l_tab
                           ,  p_level_view_name => l_level_view_name
                           ,  p_dim_level_id    => l_dim_level_id
                           ,  x_return_status   => x_return_status
                           ,  x_msg_count       => x_msg_count
                           ,  x_msg_data        => x_msg_data
                         );
                         IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                         END IF;
                      END IF;
                      FETCH c_filter_tabs INTO l_tab,l_level_view_name,l_dim_level_id;
                    END LOOP;
                    CLOSE c_filter_tabs;
                END IF;
              END IF;
         END LOOP;
     END IF;

EXCEPTION
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
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Validate_filter_views ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Validate_filter_views ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Validate_filter_views ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Validate_filter_views ';
        END IF;
END Validate_filter_views;

/********************************************************************
  PROCEDURE   : Validate_Filter_Button
  DESCRIPTION : This procedure does the filter button validations.
                It is divided into 3 parts.
                 1.Previously there was no relationship and now relationship exists.
                 2.Previously relationship exists and now no relationship.
                 3.Changed/Unchanged relationships.
                 4.Relationship got reversed.
  INPUT       : p_dim_obj_id  : Current dimesnion object whose relationship is being
                                effected.
                x_new_rel_Table  : Cache which stores the new relationship corresponding
                                   to current dimension object.
                x_prev_rel_Table : Cache which stores the old relationship for the current
                                   dimension object.
  OUPUT       : Drops the filter views based on the following conditions

  Validations
  -----------
  1. If A and B from none relationship changes to 1-M, then keep filter of the
     A and remove filter of B.

  2. If A and B have 1-M changes to none relationship, then keep filter of A
     and remove filter of B.
  3. If A and B have 1-M changes to M-N, then keep filter of A and remove
     filter for B.
  4. If A and B have M-N changes to 1-M, then keep filter of A and remove
     filter for B.

  5. Keep filters for both dimension objects whenever removing or adding a M-N
     relationship since they are treaten as independent:

  6. If A and B have none relationship changes to M-N, then keep filter of A
     and B, since they will continue be treaten as independent.
  7. If A and B have M-N changes to none relationship, then keep filter of A
     and B.

  8. In the case where the relationship is reversed, meaning the parent changes
   to be the child, remove filter for both of the dimension objects.

  AUTHOR      : ashankar 25-OCT-2004  BUG 3459282
/*******************************************************************/
PROCEDURE Validate_Filter_Button
 (
         p_dim_obj_id          IN              NUMBER
     ,   x_new_rel_Table       IN              BSC_BIS_DIM_REL_PUB.Relation_Table_Type
     ,   x_prev_rel_Table      IN              BSC_BIS_DIM_REL_PUB.Relation_Table_Type
     ,   x_return_status       OUT     NOCOPY  VARCHAR2
     ,   x_msg_count           OUT     NOCOPY  NUMBER
     ,   x_msg_data            OUT     NOCOPY  VARCHAR2

 )IS
      l_new_rel_Table       BSC_BIS_DIM_REL_PUB.Relation_Table_Type;
      l_prev_rel_Table      BSC_BIS_DIM_REL_PUB.Relation_Table_Type;
      l_dim_obj_tbls        BSC_UTILITY.varchar_tabletype;


      l_New_Count           NUMBER;
      l_Old_Count           NUMBER;
      l_Count               NUMBER;
      l_par_count           NUMBER;
      l_child_number        NUMBER;
      l_common_tabs         VARCHAR2(32000);
      l_tab                 VARCHAR2(30);
      l_outer_loop          NUMBER;
      l_inner_loop          NUMBER;
      l_found_count         NUMBER;

 BEGIN
      FND_MSG_PUB.Initialize;
      x_return_status   := FND_API.G_RET_STS_SUCCESS;
      l_new_rel_Table   :=  x_new_rel_Table;
      l_prev_rel_Table  :=  x_prev_rel_Table;

      l_New_Count       :=  l_new_rel_Table.COUNT;
      l_Old_Count       :=  l_prev_rel_Table.COUNT;

      /*****************************************************************
       Previuosly there was no relationship and now there is relationship
       In the new relationship check if it is 1xN relationship.
         If yes then check the current dimension object is acting as a child or parent.
          If as child then validate if the child and parent dimension objects are used in filter views.
            If yes then get the common tabs where they are used as filters.
            For each tab and for the current dimension object drop the filter views.
            Don't drop the filter view of the parent dimension object.
          If acting as parent then do the same for each of its child.
      /*****************************************************************/

      IF((l_Old_Count=0) AND(l_New_Count<>0))THEN
          FOR i_index IN 0..l_New_Count -1 LOOP
            IF(l_new_rel_Table(i_index).p_Relation_Type =1) THEN
               IF((l_new_rel_Table(i_index).p_Dim_Obj_ID=p_dim_obj_id)
                   AND (l_new_rel_Table(i_index).p_Parent_Dim_Id<> p_dim_obj_id)) THEN

                   BSC_BIS_DIM_REL_PUB.Validate_Filtered_Tabs
                   (
                           p_dim_obj_id      => l_new_rel_Table(i_index).p_Dim_Obj_ID
                       ,   p_par_dim_obj_id  => l_new_rel_Table(i_index).p_Parent_Dim_Id
                       ,   x_return_status   => x_return_status
                       ,   x_msg_count       => x_msg_count
                       ,   x_msg_data        => x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

               ELSIF((l_new_rel_Table(i_index).p_Dim_Obj_ID<>p_dim_obj_id)
                   AND (l_new_rel_Table(i_index).p_Parent_Dim_Id = p_dim_obj_id)) THEN

                   BSC_BIS_DIM_REL_PUB.Validate_Filtered_Tabs
                    (
                          p_dim_obj_id      => l_new_rel_Table(i_index).p_Dim_Obj_ID
                      ,   p_par_dim_obj_id  => l_new_rel_Table(i_index).p_Parent_Dim_Id
                      ,   x_return_status   => x_return_status
                      ,   x_msg_count       => x_msg_count
                      ,   x_msg_data        => x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
               END IF;
            END IF;
          END LOOP;
      ELSIF((l_Old_Count<>0) AND(l_New_Count=0)) THEN
     /*****************************************************************
        Previuosly there was no relationship and now there is relationship
        In the new relationship check if it is 1xN relationship.
        If yes then check the current dimension object is acting as a child or parent.
        If as child then validate if the child and parent dimension objects are used in filter views.
        If yes then get the common tabs where they are used as filters.
        For each tab and for the current dimension object drop the filter views.
        Don't drop the filter view of the parent dimension object.
        If acting as parent then do the same for each of its child.
      /*****************************************************************/
          FOR i_index IN 0..l_Old_Count -1 LOOP
             IF(l_prev_rel_Table(i_index).p_Relation_Type =1) THEN
                IF((l_prev_rel_Table(i_index).p_Dim_Obj_ID=p_dim_obj_id)
                   AND (l_prev_rel_Table(i_index).p_Parent_Dim_Id<> p_dim_obj_id)) THEN

                    BSC_BIS_DIM_REL_PUB.Validate_Filtered_Tabs
                    (
                          p_dim_obj_id      => l_prev_rel_Table(i_index).p_Dim_Obj_ID
                      ,   p_par_dim_obj_id  => l_prev_rel_Table(i_index).p_Parent_Dim_Id
                      ,   x_return_status   => x_return_status
                      ,   x_msg_count       => x_msg_count
                      ,   x_msg_data        => x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                ELSIF((l_prev_rel_Table(i_index).p_Dim_Obj_ID<>p_dim_obj_id)
                       AND (l_prev_rel_Table(i_index).p_Parent_Dim_Id =p_dim_obj_id))THEN

                    BSC_BIS_DIM_REL_PUB.Validate_Filtered_Tabs
                    (
                          p_dim_obj_id      => l_prev_rel_Table(i_index).p_Dim_Obj_ID
                      ,   p_par_dim_obj_id  => l_prev_rel_Table(i_index).p_Parent_Dim_Id
                      ,   x_return_status   => x_return_status
                      ,   x_msg_count       => x_msg_count
                      ,   x_msg_data        => x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
             END IF;
          END LOOP;
      ELSIF((l_Old_Count<>0) AND(l_New_Count<>0)) THEN
        /*****************************************************************
         Here we will find the difference in relationships between the old
         and new.To filter out the dimension objects we are using the following logic
         1.We check if the old relationship record eixts in the new Cache.
           If yes then we check if any change is there in the relationship.
           If relationship change then we flag the refresh flag in old cache to TRUE so that it can be
            acted upon.p_Refresh_No is the new Cache will be set to 0 to indicate that this record doesn't need to
            be touched.
           It may happen that the old record no longer exits and is no longer exists.In that case
           l_found_count will be set to -1.In that case too verify what the relationship type
           if it was set to -1 then set the refresh falg to TRUE.

           If the relationships were revered then set the relfresh_flag to TRUE and set p_Refresh_No =1
           This indicates that we need to drop the filter views of both the dimension objects.
        /*****************************************************************/

          FOR out_index IN 0..l_Old_Count - 1 LOOP
              l_found_count := -1;
              FOR in_index IN 0..l_New_Count - 1 LOOP
                IF((l_prev_rel_Table(out_index).p_Dim_Obj_ID = l_new_rel_Table(in_index).p_Dim_Obj_ID)
                 AND ((l_prev_rel_Table(out_index).p_Parent_Dim_Id = l_new_rel_Table(in_index).p_Parent_Dim_Id))) THEN
                   IF(l_prev_rel_Table(out_index).p_Relation_Type <> l_new_rel_Table(in_index).p_Relation_Type) THEN
                     l_prev_rel_Table(out_index).p_Refresh_Flag := TRUE;
                     l_new_rel_Table(in_index).p_Refresh_No := 0;
                     l_found_count := in_index;
                   ELSE
                     l_new_rel_Table(in_index).p_Refresh_No := 0;
                   END IF;
                ELSIF((l_prev_rel_Table(out_index).p_Dim_Obj_ID = l_new_rel_Table(in_index).p_Parent_Dim_Id)
                    AND ((l_prev_rel_Table(out_index).p_Parent_Dim_Id = l_new_rel_Table(in_index).p_Dim_Obj_ID))
                    AND (l_prev_rel_Table(out_index).p_Relation_Type = l_new_rel_Table(in_index).p_Relation_Type)) THEN
                     l_prev_rel_Table(out_index).p_Refresh_Flag := TRUE;
                     l_prev_rel_Table(out_index).p_Refresh_No := 1;
                END IF;
              END LOOP;

              IF(l_found_count =-1) THEN
                  IF(l_prev_rel_Table(out_index).p_Relation_Type = 1) THEN
                     l_prev_rel_Table(out_index).p_Refresh_Flag := TRUE;
                  END IF;
              END IF;
          END LOOP;--out_index

          FOR j IN 0..l_prev_rel_Table.COUNT -1 LOOP
                IF((l_prev_rel_Table(j).p_Refresh_Flag=TRUE) AND (l_prev_rel_Table(j).p_Refresh_No =-1))THEN
                     BSC_BIS_DIM_REL_PUB.Validate_Filtered_Tabs
                      (
                            p_dim_obj_id      => l_prev_rel_Table(j).p_Dim_Obj_ID
                        ,   p_par_dim_obj_id  => l_prev_rel_Table(j).p_Parent_Dim_Id
                        ,   x_return_status   => x_return_status
                        ,   x_msg_count       => x_msg_count
                        ,   x_msg_data        => x_msg_data
                      );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                ELSIF((l_prev_rel_Table(j).p_Refresh_Flag=TRUE) AND (l_prev_rel_Table(j).p_Refresh_No =1)) THEN

                    BSC_DIM_FILTERS_PUB.Drop_Filter_By_Dim_Obj
                    (       p_Dim_Level_Id    =>  l_prev_rel_Table(j).p_Dim_Obj_ID
                        ,   x_return_status   =>  x_return_status
                        ,   x_msg_Count       =>  x_msg_Count
                        ,   x_msg_data        =>  x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                     BSC_DIM_FILTERS_PUB.Drop_Filter_By_Dim_Obj
                    (       p_Dim_Level_Id    =>  l_prev_rel_Table(j).p_Parent_Dim_Id
                        ,   x_return_status   =>  x_return_status
                        ,   x_msg_Count       =>  x_msg_Count
                        ,   x_msg_data        =>  x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
          END LOOP;

          --Now for new relationships

          /*****************************************************************
           We have to take into account the new relationships which were not
           there in the old Cache.If p_Refresh_No is set to 0 it means
           the no change in the relationships.
           We have to take into account p_Refresh_No =-1 (it means new relatiosnhip
           for the current dimension object) and p_Relation_Type =1
          /****************************************************************/

          FOR i IN 0..l_new_rel_Table.COUNT -1 LOOP
               IF((l_new_rel_Table(i).p_Refresh_No = -1) AND (l_new_rel_Table(i).p_Relation_Type=1)) THEN
                     BSC_BIS_DIM_REL_PUB.Validate_Filtered_Tabs
                     (
                           p_dim_obj_id      => l_new_rel_Table(i).p_Dim_Obj_ID
                       ,   p_par_dim_obj_id  => l_new_rel_Table(i).p_Parent_Dim_Id
                       ,   x_return_status   => x_return_status
                       ,   x_msg_count       => x_msg_count
                       ,   x_msg_data        => x_msg_data
                     );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
               END IF;
          END LOOP;
      END IF;
      /************************************************************
        This procedure is added to ensure that filter views are
        invalidated when relationship type is changed. If yes then
        it will recreate the filter views.
      /***********************************************************/

      BSC_BIS_DIM_REL_PUB.Validate_filter_views
      (
            p_dim_obj_id       => p_dim_obj_id
        ,   x_new_rel_Table    => l_new_rel_Table
        ,   x_prev_rel_Table   => l_prev_rel_Table
        ,   x_return_status    => x_return_status
        ,   x_msg_count        => x_msg_count
        ,   x_msg_data         => x_msg_data
      );
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

EXCEPTION
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
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Validate_Filter_Button ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Validate_Filter_Button ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Validate_Filter_Button ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Validate_Filter_Button ';
        END IF;
 END Validate_Filter_Button;

--=====================================================================================*/

FUNCTION get_Next_Alias
(
    p_Alias        IN   VARCHAR2
) RETURN VARCHAR2
IS
    l_alias     VARCHAR2(3);
    l_return    VARCHAR2(3);
    l_count     NUMBER;
BEGIN
    IF (p_Alias IS NULL) THEN
        l_return :=  'A';
    ELSE
        l_count := LENGTH(p_Alias);
        IF (l_count = 1) THEN
            l_return   := 'A0';
        ELSIF (l_count > 1) THEN
            l_alias     :=  SUBSTR(p_Alias, 2);
            l_count     :=  TO_NUMBER(l_alias)+1;
            l_return    :=  SUBSTR(p_Alias, 1, 1)||TO_CHAR(l_count);
        END IF;
    END IF;
    RETURN l_return;
END get_Next_Alias;

--==============================================================
PROCEDURE Assign_Dim_Obj_Rels
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_id            IN          NUMBER
    ,   p_parent_ids            IN          VARCHAR2
    ,   p_parent_rel_type       IN          VARCHAR2
    ,   p_parent_rel_column     IN          VARCHAR2
    ,   p_parent_data_type      IN          VARCHAR2
    ,   p_parent_data_source    IN          VARCHAR2
    ,   p_child_ids             IN          VARCHAR2
    ,   p_child_rel_type        IN          VARCHAR2
    ,   p_child_rel_column      IN          VARCHAR2
    ,   p_child_data_type       IN          VARCHAR2
    ,   p_child_data_source     IN          VARCHAR2
    ,   p_time_stamp            IN          VARCHAR2   := NULL   -- Granular Locking
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
    l_parent_ids                VARCHAR2(32000);
    l_parent_rel_type           VARCHAR2(32000);
    l_parent_rel_column         VARCHAR2(32000);
    l_parent_data_type          VARCHAR2(32000);
    l_parent_data_source        VARCHAR2(32000);
    l_child_ids                 VARCHAR2(32000);
    l_child_rel_type            VARCHAR2(32000);
    l_child_rel_column          VARCHAR2(32000);
    l_child_data_type           VARCHAR2(32000);
    l_child_data_source         VARCHAR2(32000);

    CURSOR  c_parent_ids IS
    SELECT  parent_dim_level_id
          , relation_type
          , relation_col
          , data_source_type
          , data_source
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   dim_level_id = p_dim_obj_id;

    CURSOR  c_childs_ids IS
    SELECT  dim_level_id
          , relation_type
          , relation_col
          , data_source_type
          , data_source
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   parent_dim_level_id = p_dim_obj_id
    AND     relation_type       = 1;
BEGIN
    --DBMS_OUTPUT.PUT_LINE('Entered inside BSC_BIS_DIM_REL_PUB.Assign_Dim_Obj_Rels Procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_dim_obj_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_parent_ids IS NOT NULL) THEN
        l_parent_ids            :=  p_parent_ids;
        l_parent_rel_type       :=  NVL(p_parent_rel_type,    'NULL');
        l_parent_rel_column     :=  NVL(p_parent_rel_column,  'NULL');
        l_parent_data_type      :=  NVL(p_parent_data_type,   'NULL');
        l_parent_data_source    :=  NVL(p_parent_data_source, 'NULL');
    END IF;
    IF (p_child_ids IS NOT NULL) THEN
        l_child_ids             :=  p_child_ids;
        l_child_rel_type        :=  NVL(p_child_rel_type,     'NULL');
        l_child_rel_column      :=  NVL(p_child_rel_column,   'NULL');
        l_child_data_type       :=  NVL(p_child_data_type,    'NULL');
        l_child_data_source     :=  NVL(p_child_data_source,  'NULL');
    END IF;

    --added additional if condition to check for duplicates - Bug#4601099
    FOR cd IN c_parent_ids LOOP
        IF(INSTR(','||REPLACE(l_parent_ids, ' ', '')||',', ',' || cd.parent_dim_level_id ||',') = 0) THEN
            IF (l_parent_ids IS NULL) THEN
                l_parent_ids         :=  NVL(TO_CHAR(cd.parent_dim_level_id), 'NULL');
            ELSE
                l_parent_ids         :=  l_parent_ids||', '||NVL(TO_CHAR(cd.parent_dim_level_id), 'NULL');
            END IF;
            IF (l_parent_rel_type IS NULL) THEN
                l_parent_rel_type    :=  NVL(TO_CHAR(cd.relation_type), 'NULL');
            ELSE
                l_parent_rel_type    :=  l_parent_rel_type||', '||NVL(TO_CHAR(cd.relation_type), 'NULL');
            END IF;
            IF (l_parent_rel_column IS NULL) THEN
                l_parent_rel_column  :=  NVL(cd.relation_col, 'NULL');
            ELSE
                l_parent_rel_column  :=  l_parent_rel_column||', '||NVL(cd.relation_col, 'NULL');
            END IF;
            IF (l_parent_data_type IS NULL) THEN
                l_parent_data_type   :=  NVL(cd.data_source_type, 'NULL');
            ELSE
                l_parent_data_type   :=  l_parent_data_type||', '||NVL(cd.data_source_type, 'NULL');
            END IF;
            IF (l_parent_data_source IS NULL) THEN
                l_parent_data_source :=  NVL(cd.data_source, 'NULL');
            ELSE
                l_parent_data_source :=  l_parent_data_source||', '||NVL(cd.data_source, 'NULL');
            END IF;
        END IF;
    END LOOP;
    FOR cd IN c_childs_ids LOOP
        IF(INSTR(','||REPLACE(l_child_ids, ' ', '')||',', ',' || cd.dim_level_id ||',') = 0) THEN
            IF (l_child_ids IS NULL) THEN
                l_child_ids         :=  NVL(TO_CHAR(cd.dim_level_id), 'NULL');
            ELSE
                l_child_ids :=  l_child_ids||', '||NVL(TO_CHAR(cd.dim_level_id), 'NULL');
            END IF;
            IF (l_child_rel_type IS NULL) THEN
                l_child_rel_type    :=  NVL(TO_CHAR(cd.relation_type), 'NULL');
            ELSE
                l_child_rel_type    :=  l_child_rel_type||', '||NVL(TO_CHAR(cd.relation_type), 'NULL');
            END IF;
            IF (l_child_rel_column IS NULL) THEN
                l_child_rel_column  :=  NVL(cd.relation_col, 'NULL');
            ELSE
                l_child_rel_column  :=  l_child_rel_column||', '||NVL(cd.relation_col, 'NULL');
            END IF;
            IF (l_child_data_type IS NULL) THEN
                l_child_data_type   :=  NVL(cd.data_source_type, 'NULL');
            ELSE
                l_child_data_type   :=  l_child_data_type||', '||NVL(cd.data_source_type, 'NULL');
            END IF;
            IF (l_child_data_source IS NULL) THEN
                l_child_data_source :=  NVL(cd.data_source, 'NULL');
            ELSE
                l_child_data_source :=  l_child_data_source||', '||NVL(cd.data_source, 'NULL');
            END IF;
        END IF;
    END LOOP;

    --DBMS_OUTPUT.PUT_LINE('    BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels');
    --DBMS_OUTPUT.PUT_LINE('    (');
    --DBMS_OUTPUT.PUT_LINE('            p_commit                =>  FND_API.G_FALSE');
    --DBMS_OUTPUT.PUT_LINE('        ,   p_dim_obj_id            =>  '||p_dim_obj_id);
    --DBMS_OUTPUT.PUT_LINE('        ,   p_parent_ids            =>  '''||l_parent_ids||''' ');
    --DBMS_OUTPUT.PUT_LINE('        ,   p_parent_rel_type       =>  '''||l_parent_rel_type||'''');
    --DBMS_OUTPUT.PUT_LINE('        ,   p_parent_rel_column     =>  '''||l_parent_rel_column||'''');
    --DBMS_OUTPUT.PUT_LINE('        ,   p_parent_data_type      =>  '''||l_parent_data_type||'''');
    --DBMS_OUTPUT.PUT_LINE('        ,   p_parent_data_source    =>  '''||l_parent_data_source||'''');
    --DBMS_OUTPUT.PUT_LINE('        ,   p_child_ids             =>  '''||l_child_ids||'''');
    --DBMS_OUTPUT.PUT_LINE('        ,   p_child_rel_type        =>  '''||l_child_rel_type||'''');
    --DBMS_OUTPUT.PUT_LINE('        ,   p_child_rel_column      =>  '''||l_child_rel_column||'''');
    --DBMS_OUTPUT.PUT_LINE('        ,   p_child_data_type       =>  '''||l_child_data_type||'''');
    --DBMS_OUTPUT.PUT_LINE('        ,   p_child_data_source     =>  '''||l_child_data_source||'''');
    --DBMS_OUTPUT.PUT_LINE('        ,   x_return_status         =>  l_return_status');
    --DBMS_OUTPUT.PUT_LINE('        ,   x_msg_count             =>  l_msg_count');
    --DBMS_OUTPUT.PUT_LINE('        ,   x_msg_data              =>  l_msg_data');
    --DBMS_OUTPUT.PUT_LINE('    );');
    BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_dim_obj_id            =>  p_dim_obj_id
        ,   p_parent_ids            =>  l_parent_ids
        ,   p_parent_rel_type       =>  l_parent_rel_type
        ,   p_parent_rel_column     =>  l_parent_rel_column
        ,   p_parent_data_type      =>  l_parent_data_type
        ,   p_parent_data_source    =>  l_parent_data_source
        ,   p_child_ids             =>  l_child_ids
        ,   p_child_rel_type        =>  l_child_rel_type
        ,   p_child_rel_column      =>  l_child_rel_column
        ,   p_child_data_type       =>  l_child_data_type
        ,   p_child_data_source     =>  l_child_data_source
        ,   p_time_stamp            =>  p_time_stamp    -- Granular Locking
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Assign_Dim_Obj_Rels Failed: at BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --DBMS_OUTPUT.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    --DBMS_OUTPUT.PUT_LINE('Exiting from BSC_BIS_DIM_REL_PUB.Assign_Dim_Obj_Rels Procedure');
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
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Assign_Dim_Obj_Rels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Assign_Dim_Obj_Rels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Assign_Dim_Obj_Rels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Assign_Dim_Obj_Rels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Assign_Dim_Obj_Rels;
/*********************************************************************************
                      ASSIGN DIMENSION-LEVELS RELATIONSHIPS
*********************************************************************************/
/*
    This procedure allow user to assign dimension object relationships whose records
    will be inserted into the following table.
        1. BSC_SYS_DIM_LEVEL_RELS
    The procedure will remove all the older relationships before assigning new
    relationships.

    Validations:
        1. Source must be same either BSC or PMF.
        2. Circularity check must be there.
        3. p_dim_obj_id must not be null.
*/
PROCEDURE Assign_New_Dim_Obj_Rels
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_id            IN          NUMBER
    ,   p_parent_ids            IN          VARCHAR2
    ,   p_parent_rel_type       IN          VARCHAR2
    ,   p_parent_rel_column     IN          VARCHAR2
    ,   p_parent_data_type      IN          VARCHAR2
    ,   p_parent_data_source    IN          VARCHAR2
    ,   p_child_ids             IN          VARCHAR2
    ,   p_child_rel_type        IN          VARCHAR2
    ,   p_child_rel_column      IN          VARCHAR2
    ,   p_child_data_type       IN          VARCHAR2
    ,   p_child_data_source     IN          VARCHAR2
    ,   p_time_stamp            IN          VARCHAR2   := NULL   -- Granular Locking
    ,   p_is_not_config         IN          BOOLEAN    := TRUE
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
    l_One_N_Table           BSC_BIS_DIM_REL_PUB.One_To_N_Org_Table_Type;
    l_M_N_Table             BSC_BIS_DIM_REL_PUB.M_To_N_Org_Table_Type;

    l_prev_rel_Table        BSC_BIS_DIM_REL_PUB.Relation_Table_Type;
    l_new_rel_Table         BSC_BIS_DIM_REL_PUB.Relation_Table_Type;

    l_bsc_dim_obj_rec       BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;

    l_count                 NUMBER;
    l_flag                  BOOLEAN := TRUE;
    l_source                BSC_SYS_DIM_LEVELS_B.Source%TYPE;

    l_child_ids             VARCHAR2(32000);
    l_child_rel_type        VARCHAR2(32000);
    l_child_rel_column      VARCHAR2(32000);
    l_child_data_type       VARCHAR2(32000);
    l_child_data_source     VARCHAR2(32000);

    l_refresh_kpi_ids       VARCHAR2(32000);

    l_parent_ids            VARCHAR2(32000);
    l_parent_rel_type       VARCHAR2(32000);
    l_parent_rel_column     VARCHAR2(32000);
    l_parent_data_type      VARCHAR2(32000);
    l_parent_data_source    VARCHAR2(32000);

    l_dim_obj_id            VARCHAR2(200);

    -- Start Granular Locking added by Aditya
    lg_Dim_Obj_Tab_p        BSC_BIS_LOCKS_PUB.t_numberTable;
    lg_Dim_Obj_Tab_c        BSC_BIS_LOCKS_PUB.t_numberTable;
    lg_dim_obj_ids          VARCHAR2(32000);

    lg_dim_obj_id           VARCHAR2(30);
    lg_index                NUMBER := 0;
    -- End Granular Locking added by Aditya

    l_db_child_rel_type     NUMBER;
    l_rel_ids               VARCHAR2(32000);
    l_rel_id                VARCHAR2(10);
    l_dim_obj_sname         VARCHAR2(30);
    l_dim_obj_name          VARCHAR2(400);
    l_is_denorm_deleted     VARCHAR(1);
    l_dim_short_name        VARCHAR2(30);
    l_Sql                   VARCHAR2(8000);

    l_original_child_ids             VARCHAR2(32000);



    CURSOR  c_par_dim_ids IS
    SELECT  parent_dim_level_id
          , relation_type
          , dim_level_id
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   dim_level_id    =   l_dim_obj_id;

    CURSOR  c_child_ids IS
    SELECT  dim_level_id
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   parent_dim_level_id = p_dim_obj_id
    AND     relation_type      <> 2;


    CURSOR c_Kpi_Dim_Set IS
    SELECT DISTINCT A.INDICATOR Indicator,
           A.DIM_SET_ID Dim_Set_Id,
           C.short_name
    FROM   BSC_KPI_DIM_LEVELS_VL A,
           BSC_SYS_DIM_LEVELS_VL B,
           BSC_KPIS_B            C
    WHERE  A.LEVEL_TABLE_NAME=B.LEVEL_TABLE_NAME
    AND    C.INDICATOR = A.INDICATOR
    AND    C.SHARE_FLAG <> 2
    AND    INSTR(l_Refresh_Kpi_Ids, ','||b.dim_level_id||',') > 0;

    CURSOR  c_new_relations IS
    SELECT  DISTINCT Dim_Level_Id
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   (Parent_Dim_Level_Id = p_dim_obj_id
    OR      Dim_Level_Id        = p_dim_obj_id);

    -- added cursor for Bug #3395161
    CURSOR  c_db_child_type IS
    SELECT  Relation_Type
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   dim_level_id        =  l_bsc_dim_obj_rec.Bsc_Level_Id
    AND     parent_dim_level_id =  l_bsc_dim_obj_rec.Bsc_Parent_Level_Id;

    l_one_N_flag            BOOLEAN;
    l_One_N_Count           NUMBER := 0;
    l_Num_One_N_Count       NUMBER := 0;
    l_M_N_Count             NUMBER := 0;

    -- added for Bug#4601099
    l_Is_PMF_Recur_Type     BOOLEAN;

BEGIN
    SAVEPOINT AssUnassBSCRelsPMD;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --DBMS_OUTPUT.PUT_LINE('Entered inside BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Procedure');
    --DBMS_OUTPUT.PUT_LINE('p_dim_obj_id                   '||p_dim_obj_id);
    --DBMS_OUTPUT.PUT_LINE('p_parent_ids                   '||p_parent_ids);
    --DBMS_OUTPUT.PUT_LINE('p_parent_rel_type              '||p_parent_rel_type);
    --DBMS_OUTPUT.PUT_LINE('p_parent_rel_column            '||p_parent_rel_column);
    --DBMS_OUTPUT.PUT_LINE('p_parent_data_type             '||p_parent_data_type);
    --DBMS_OUTPUT.PUT_LINE('p_parent_data_source           '||p_parent_data_source);
    --DBMS_OUTPUT.PUT_LINE('p_child_ids                    '||p_child_ids);
    --DBMS_OUTPUT.PUT_LINE('p_child_rel_type               '||p_child_rel_type);
    --DBMS_OUTPUT.PUT_LINE('p_child_rel_column             '||p_child_rel_column);
    --DBMS_OUTPUT.PUT_LINE('p_child_data_type              '||p_child_data_type);
    --DBMS_OUTPUT.PUT_LINE('p_child_data_source            '||p_child_data_source);
    IF (p_dim_obj_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    SELECT  COUNT(*) INTO l_count
    FROM    BSC_SYS_DIM_LEVELS_B
    WHERE   dim_level_id = p_dim_obj_id;
    IF (l_count = 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INCORRECT_NAME_ENTERED');
        FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_ID'), TRUE);
        FND_MESSAGE.SET_TOKEN('NAME_VALUE',  p_dim_obj_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Restrict Period Dim Object from relationship.
    IF (p_parent_ids IS NOT NULL) THEN
        l_rel_ids := p_parent_ids;
        WHILE (is_more(     p_dim_lev_ids   => l_rel_ids
                        ,   p_dim_lev_id    => l_rel_id
        )) LOOP
          SELECT NAME, SHORT_NAME
          INTO l_dim_obj_name, l_dim_obj_sname
          FROM BSC_SYS_DIM_LEVELS_VL
          WHERE DIM_LEVEL_ID = l_rel_id;

          BSC_UTILITY.Enable_Dimension_Entity(
              p_Entity_Type           => BSC_UTILITY.c_DIMENSION_OBJECT
            , p_Entity_Short_Name     => l_dim_obj_sname
            , p_Entity_Action_Type    => BSC_UTILITY.c_UPDATE
            , p_Entity_Name           => l_dim_obj_name
            , x_Return_Status         => x_return_status
            , x_Msg_Count             => x_msg_count
            , x_Msg_Data              => x_msg_data
          );
          IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END LOOP;
    END IF;
    IF (p_child_ids IS NOT NULL) THEN
        l_rel_ids := p_child_ids;
        WHILE (is_more(     p_dim_lev_ids   => l_rel_ids
                        ,   p_dim_lev_id    => l_rel_id
        )) LOOP
          SELECT NAME, SHORT_NAME
          INTO l_dim_obj_name, l_dim_obj_sname
          FROM BSC_SYS_DIM_LEVELS_VL
          WHERE DIM_LEVEL_ID = l_rel_id;

          BSC_UTILITY.Enable_Dimension_Entity(
              p_Entity_Type           => BSC_UTILITY.c_DIMENSION_OBJECT
            , p_Entity_Short_Name     => l_dim_obj_sname
            , p_Entity_Action_Type    => BSC_UTILITY.c_UPDATE
            , p_Entity_Name           => l_dim_obj_name
            , x_Return_Status         => x_return_status
            , x_Msg_Count             => x_msg_count
            , x_Msg_Data              => x_msg_data
          );
          IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END LOOP;
    END IF;

    SELECT  NVL(source, 'BSC')
          , short_name
    INTO    l_bsc_dim_obj_rec.bsc_parent_level_source
          , l_bsc_dim_obj_rec.bsc_parent_level_short_name
    FROM    BSC_SYS_DIM_LEVELS_B
    WHERE   dim_level_id = p_dim_obj_id;
    l_source    :=  l_bsc_dim_obj_rec.bsc_parent_level_source;
    -- START: Granular Locking
    IF(p_is_not_config) THEN
        IF (l_child_ids IS NOT NULL) THEN
            lg_dim_obj_ids := l_child_ids;

            WHILE (is_more(     p_dim_lev_ids   =>  lg_dim_obj_ids
                            ,   p_dim_lev_id    =>  lg_dim_obj_id)
            ) LOOP
                lg_Dim_Obj_Tab_c(lg_index) := NVL(TO_NUMBER(lg_dim_obj_id), -1);
                lg_index := lg_index + 1;
            END LOOP;
        END IF;
        IF (l_parent_ids IS NOT NULL) THEN
            lg_dim_obj_ids := l_parent_ids;
            lg_index := 0; -- Initialize the index to 0, since we have to pass two
                          -- separate table params to the Locking Procedure.
            WHILE (is_more( p_dim_lev_ids   =>  lg_dim_obj_ids
                          , p_dim_lev_id    =>  lg_dim_obj_id)
            ) LOOP
                lg_Dim_Obj_Tab_p(lg_index) := NVL(TO_NUMBER(lg_dim_obj_id), -1);
                lg_index := lg_index + 1;
            END LOOP;
        END IF;
        -- Lock all the Parent/Children and The Dimension Level affected.
        BSC_BIS_LOCKS_PUB.LOCK_UPDATE_RELATIONSHIPS
        (       p_dim_object_id     => p_dim_obj_id
             ,  p_selected_parends  => lg_Dim_Obj_Tab_p
             ,  p_selected_childs   => lg_Dim_Obj_Tab_c
             ,  p_time_stamp        => p_time_stamp
             ,  x_return_status     => x_return_status
             ,  x_msg_count         => x_msg_count
             ,  x_msg_data          => x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    -- END:  Granular Locking
    --find out all the initial childs first
    --for relation type 2, which are not needed
    --if dimension objects are of type 'BSC'
    --DBMS_OUTPUT.PUT_LINE('BEFORE BSC_BIS_DIM_REL_PUB.get_Original_Relations');
    BSC_BIS_DIM_REL_PUB.get_Original_Relations
    (       p_dim_obj_id        =>  p_dim_obj_id
        ,   x_One_N_Table       =>  l_One_N_Table
        ,   x_M_N_Table         =>  l_M_N_Table
        ,   x_return_status     =>  x_return_status
        ,   x_msg_count         =>  x_msg_count
        ,   x_msg_data          =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.get_Original_Relations Failed: at BSC_BIS_DIM_REL_PUB.get_Original_Relations <'||x_msg_data||'>');
        RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Added for Bug#5300060
    l_original_child_ids := Get_Original_Child_Ids(p_dim_obj_id);

    /****************************************************
     Store the original relationships for the filter view validation
    /****************************************************/
    IF((p_is_not_config) AND (l_source = 'BSC'))THEN

        BSC_BIS_DIM_REL_PUB.store_Relations
         (       p_dim_obj_id        =>  p_dim_obj_id
             ,   x_rel_Table         =>  l_prev_rel_Table
             ,   x_return_status     =>  x_return_status
             ,   x_msg_count         =>  x_msg_count
             ,   x_msg_data          =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Failed: at BSC_BIS_DIM_REL_PUB.store_Prev_Relations <'||x_msg_data||'>');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('AFTER BSC_BIS_DIM_REL_PUB.get_Original_Relations');
    --DBMS_OUTPUT.PUT_LINE('  ---  INITIAL TABLE  ----');
    --DBMS_OUTPUT.PUT_LINE('PRINT OUT OF THE TABLES THAT WE HAVE GOT 1 x N RELATIONS');
    /*FOR i IN 0..(l_One_N_Table.COUNT-1) LOOP
        --DBMS_OUTPUT.PUT_LINE('l_One_N_Table('||i||').p_dim_obj_id '||l_One_N_Table(i).p_dim_obj_id);
        IF (l_One_N_Table(i).p_refresh_flag) THEN
            --DBMS_OUTPUT.PUT_LINE('l_One_N_Table('||i||').p_refresh_flag TRUE');
        ELSE
            --DBMS_OUTPUT.PUT_LINE('l_One_N_Table('||i||').p_refresh_flag FALSE');
        END IF;
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE('PRINT OUT OF THE TABLES THAT WE HAVE GOT M x N RELATIONS');
    FOR i IN 0..(l_M_N_Table.COUNT-1) LOOP
        --DBMS_OUTPUT.PUT_LINE('l_M_N_Table('||i||').p_dim_obj_id    '||l_M_N_Table(i).p_dim_obj_id);
        --DBMS_OUTPUT.PUT_LINE('l_M_N_Table('||i||').p_Parent_dim_id '||l_M_N_Table(i).p_Parent_dim_id);
        IF (l_M_N_Table(i).p_refresh_flag) THEN
            --DBMS_OUTPUT.PUT_LINE('l_M_N_Table('||i||').p_refresh_flag TRUE');
        ELSE
            --DBMS_OUTPUT.PUT_LINE('l_M_N_Table('||i||').p_refresh_flag FALSE');
        END IF;
    END LOOP;*/

    -- START: Granular Locking
    -- The following statement direcly removes all the parents & children
    -- in the relationship. So for the time being, we need to implement
    -- granular locking to lock all the dimension levels that are going
    -- to be deleted. This will be removed once the DML statement is
    -- removed.
    -- checking for configuration flag
    IF(p_is_not_config) THEN
        --DBMS_OUTPUT.PUT_LINE('WRONGLY ENTERED');
        IF (l_source = 'BSC') THEN
            FOR cd IN c_child_ids LOOP
                 --contains all the initial childs
                BSC_BIS_LOCKS_PUB.LOCK_DIM_LEVEL
                (       p_dim_level_id      => cd.dim_level_id
                     ,  p_time_stamp        => NULL
                     ,  x_return_status     => x_return_status
                     ,  x_msg_count         => x_msg_count
                     ,  x_msg_data          => x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE    FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END LOOP;
            l_dim_obj_id    := p_dim_obj_id;
            FOR pd IN c_par_dim_ids LOOP
                 --contains all the initial parents
                BSC_BIS_LOCKS_PUB.LOCK_DIM_LEVEL
                (       p_dim_level_id      => pd.parent_dim_level_id
                     ,  p_time_stamp        => NULL
                     ,  x_return_status     => x_return_status
                     ,  x_msg_count         => x_msg_count
                     ,  x_msg_data          => x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE    FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END LOOP;
        END IF;
    END IF;
    -- END: Granular Locking
    --delete all the existing parents and childs first
    --IN future replace the delete SQL to call the existing APIs
    --to delete
    --DBMS_OUTPUT.PUT_LINE('BEFOR DELETE QUERY');
    DELETE  FROM BSC_SYS_DIM_LEVEL_RELS
    WHERE   dim_level_id        = p_dim_obj_id
    OR      parent_dim_level_id = p_dim_obj_id;
    l_child_ids             :=  TRIM(p_child_ids);
    l_child_rel_type        :=  TRIM(p_child_rel_type);
    l_child_rel_column      :=  TRIM(p_child_rel_column);
    l_child_data_type       :=  TRIM(p_child_data_type);
    l_child_data_source     :=  TRIM(p_child_data_source);
    --DBMS_OUTPUT.PUT_LINE('Assigning Relations I '||l_child_ids);
    --DBMS_OUTPUT.PUT_LINE('BEFOR CHILD IDS');
    IF (l_child_ids IS NOT NULL) THEN
        WHILE (is_more(     x_remain_id             =>  l_child_ids
                        ,   x_remain_rel_type       =>  l_child_rel_type
                        ,   x_remain_rel_column     =>  l_child_rel_column
                        ,   x_remain_data_type      =>  l_child_data_type
                        ,   x_remain_data_source    =>  l_child_data_source
                        ,   x_id                    =>  l_bsc_dim_obj_rec.bsc_level_id
                        ,   x_rel_type              =>  l_bsc_dim_obj_rec.bsc_relation_type
                        ,   x_rel_column            =>  l_bsc_dim_obj_rec.bsc_relation_column
                        ,   x_data_type             =>  l_bsc_dim_obj_rec.Bsc_Data_Source_Type
                        ,   x_data_source           =>  l_bsc_dim_obj_rec.Bsc_Data_Source
        )) LOOP
            l_bsc_dim_obj_rec.bsc_parent_level_id     :=  p_dim_obj_id;
            SELECT  NVL(source, 'BSC')
                  , short_name
            INTO    l_bsc_dim_obj_rec.Bsc_Source,
                    l_bsc_dim_obj_rec.bsc_level_short_name
            FROM    BSC_SYS_DIM_LEVELS_B
            WHERE   dim_level_id = l_bsc_dim_obj_rec.Bsc_Level_Id;
            IF ((l_bsc_dim_obj_rec.bsc_relation_type IS NULL) OR
                (l_bsc_dim_obj_rec.bsc_relation_type <> 1) AND (l_bsc_dim_obj_rec.bsc_relation_type <> 2)) THEN
                l_bsc_dim_obj_rec.bsc_relation_type       :=  1;
            END IF;
            IF (l_bsc_dim_obj_rec.bsc_parent_level_source <> l_bsc_dim_obj_rec.Bsc_Source) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_RELS_SOURCE');
                FND_MESSAGE.SET_TOKEN('DIM_OBJ1', BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Name(l_bsc_dim_obj_rec.Bsc_Level_Id));
                FND_MESSAGE.SET_TOKEN('DIM_OBJ2', BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Name(l_bsc_dim_obj_rec.bsc_parent_level_id));
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
                --DBMS_OUTPUT.PUT_LINE('ERROR FOR DELETE QUERY');
            END IF;
            --DBMS_OUTPUT.PUT_LINE('l_bsc_dim_obj_rec.bsc_level_id          <'||l_bsc_dim_obj_rec.bsc_level_id);
            --DBMS_OUTPUT.PUT_LINE('l_bsc_dim_obj_rec.bsc_parent_level_id   <'||l_bsc_dim_obj_rec.bsc_parent_level_id);
            --DBMS_OUTPUT.PUT_LINE('l_bsc_dim_obj_rec.bsc_relation_type     <'||l_bsc_dim_obj_rec.bsc_relation_type);
            --DBMS_OUTPUT.PUT_LINE('l_bsc_dim_obj_rec.bsc_relation_column   <'||l_bsc_dim_obj_rec.bsc_relation_column);
            --DBMS_OUTPUT.PUT_LINE('l_bsc_dim_obj_rec.Bsc_Data_Source_Type  <'||l_bsc_dim_obj_rec.Bsc_Data_Source_Type);
            --DBMS_OUTPUT.PUT_LINE('l_bsc_dim_obj_rec.Bsc_Data_Source       <'||l_bsc_dim_obj_rec.Bsc_Data_Source);
            IF (l_bsc_dim_obj_rec.Bsc_Source = 'PMF') THEN
                IF((l_bsc_dim_obj_rec.Bsc_Data_Source_Type IS NULL) OR
                   ((l_bsc_dim_obj_rec.Bsc_Data_Source_Type <> 'TABLE') AND
                    (l_bsc_dim_obj_rec.Bsc_Data_Source_Type <> 'API'))) THEN
                        --need more clarifications what value should bo here
                        l_bsc_dim_obj_rec.Bsc_Data_Source_Type  :=  NULL;
                END IF;
                l_bsc_dim_obj_rec.bsc_relation_type :=  1; --for PMF valid relationship is type 1
            END IF;

            -- moved below the above IF condition for Bug#4619393
            IF (l_bsc_dim_obj_rec.bsc_relation_type = 2) THEN
                --for realtion type 2, pass this value as null, it will be generated internally
                l_bsc_dim_obj_rec.bsc_relation_column     :=  NULL;
            END IF;

            IF ((l_bsc_dim_obj_rec.bsc_relation_type = 2) AND
                (l_bsc_dim_obj_rec.Bsc_Level_Id = l_bsc_dim_obj_rec.bsc_parent_level_id)) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_SAME_DIM_LEVEL_REL');
                FND_MESSAGE.SET_TOKEN('LEVEL_CHILD', BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Name(l_bsc_dim_obj_rec.Bsc_Level_Id));
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
                --DBMS_OUTPUT.PUT_LINE('ERROR FOR DELETE QUERY');
            END IF;
            SELECT COUNT(*) INTO l_count
            FROM   BSC_SYS_DIM_LEVEL_RELS
            WHERE  dim_level_id        =  l_bsc_dim_obj_rec.Bsc_Level_Id
            AND    parent_dim_level_id =  l_bsc_dim_obj_rec.bsc_parent_level_id;
            IF (l_count = 0) THEN
                IF (l_bsc_dim_obj_rec.bsc_relation_type = 1) THEN
                    --DBMS_OUTPUT.PUT_LINE('BEFORE BSC_BIS_DIM_REL_PUB.Is_Valid_Relationship');
                    l_flag  :=  BSC_DIMENSION_LEVELS_PUB.Is_Valid_Relationship
                                (       p_commit            =>  FND_API.G_FALSE
                                    ,   p_Dim_Level_Rec     =>  l_bsc_dim_obj_rec
                                    ,   x_return_status     =>  x_return_status
                                    ,   x_msg_count         =>  x_msg_count
                                    ,   x_msg_data          =>  x_msg_data
                                );
                    IF (NOT l_flag) THEN
                        --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Failed: at BSC_DIMENSION_LEVELS_PUB.Is_Valid_Relationship.');
                        --DBMS_OUTPUT.PUT_LINE(SUBSTR(x_msg_data, 1, 200));
                        RAISE            FND_API.G_EXC_ERROR;
                        --DBMS_OUTPUT.PUT_LINE('ERROR FOR DELETE QUERY');
                    END IF;
                ELSE
                    SELECT COUNT(*) INTO l_count
                    FROM   BSC_SYS_DIM_LEVEL_RELS
                    WHERE  dim_level_id        =  l_bsc_dim_obj_rec.bsc_parent_level_id
                    AND    parent_dim_level_id =  l_bsc_dim_obj_rec.Bsc_Level_Id;
                    IF (l_count <> 0) THEN
                        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_RELATIONSHIPS');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                END IF;
                --DBMS_OUTPUT.PUT_LINE('reached I 6');
                --DBMS_OUTPUT.PUT_LINE('BEFORE BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level_Relation');
                BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level_Relation
                (       p_commit          =>    FND_API.G_FALSE
                    ,   p_Dim_Level_Rec   =>    l_bsc_dim_obj_rec
                    ,   x_return_status   =>    x_return_status
                    ,   x_msg_count       =>    x_msg_count
                    ,   x_msg_data        =>    x_msg_data
                );
                --DBMS_OUTPUT.PUT_LINE('reached I 7');
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Failed: at BSC_DIMENSION_LEVELS_PUB.create_dim_level_relation');
                    RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                -- START Granluar Locking
                -- Change the time stamp of the Child Dimension Level
                IF(p_is_not_config) THEN
                    BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_LEVEL
                    (     p_dim_level_id    =>    l_bsc_dim_obj_rec.Bsc_Level_Id
                      ,   x_return_status   =>    x_return_status
                      ,   x_msg_count       =>    x_msg_count
                      ,   x_msg_data        =>    x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Failed: at BSC_DIMENSION_LEVELS_PUB.create_dim_level_relation');
                        RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
                -- END Granluar Locking
            ELSE
                FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_RELATIONSHIPS');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END LOOP;
        --DBMS_OUTPUT.PUT_LINE('reached I 9');
    END IF;
    --DBMS_OUTPUT.PUT_LINE('AFTER CHILD IDS');
    l_parent_ids            :=  TRIM(p_parent_ids);
    l_parent_rel_type       :=  TRIM(p_parent_rel_type);
    l_parent_rel_column     :=  TRIM(p_parent_rel_column);
    l_parent_data_type      :=  TRIM(p_parent_data_type);
    l_parent_data_source    :=  TRIM(p_parent_data_source);

    SELECT  NVL(source, 'BSC')
          , short_name
    INTO    l_bsc_dim_obj_rec.Bsc_Source,
            l_bsc_dim_obj_rec.bsc_level_short_name
    FROM    BSC_SYS_DIM_LEVELS_B
    WHERE   dim_level_id = p_dim_obj_id;
    --DBMS_OUTPUT.PUT_LINE('Assigning Relations II');
    --DBMS_OUTPUT.PUT_LINE('BEFORE PARENT IDS');
    IF (l_parent_ids IS NOT NULL) THEN
        WHILE(is_more(      x_remain_id             =>  l_parent_ids
                        ,   x_remain_rel_type       =>  l_parent_rel_type
                        ,   x_remain_rel_column     =>  l_parent_rel_column
                        ,   x_remain_data_type      =>  l_parent_data_type
                        ,   x_remain_data_source    =>  l_parent_data_source
                        ,   x_id                    =>  l_bsc_dim_obj_rec.bsc_parent_level_id
                        ,   x_rel_type              =>  l_bsc_dim_obj_rec.bsc_relation_type
                        ,   x_rel_column            =>  l_bsc_dim_obj_rec.bsc_relation_column
                        ,   x_data_type             =>  l_bsc_dim_obj_rec.Bsc_Data_Source_Type
                        ,   x_data_source           =>  l_bsc_dim_obj_rec.Bsc_Data_Source
        )) LOOP
            l_bsc_dim_obj_rec.Bsc_Level_Id    :=  p_dim_obj_id;

            SELECT  NVL(source, 'BSC')
                  , short_name
            INTO    l_bsc_dim_obj_rec.bsc_parent_level_source
                  , l_bsc_dim_obj_rec.bsc_parent_level_short_name
            FROM    BSC_SYS_DIM_LEVELS_B
            WHERE   dim_level_id = l_bsc_dim_obj_rec.Bsc_Parent_Level_Id;
            --DBMS_OUTPUT.PUT_LINE('PARENT IDS STAGE1');

            IF ((l_bsc_dim_obj_rec.bsc_relation_type IS NULL) OR
                 (l_bsc_dim_obj_rec.bsc_relation_type <> 1) AND (l_bsc_dim_obj_rec.bsc_relation_type <> 2)) THEN
                l_bsc_dim_obj_rec.bsc_relation_type       :=  1;
            END IF;
            IF(l_bsc_dim_obj_rec.bsc_parent_level_source <> l_bsc_dim_obj_rec.Bsc_Source) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_RELS_SOURCE');
                FND_MESSAGE.SET_TOKEN('DIM_OBJ1', BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Name(l_bsc_dim_obj_rec.Bsc_Level_Id));
                FND_MESSAGE.SET_TOKEN('DIM_OBJ2', BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Name(l_bsc_dim_obj_rec.bsc_parent_level_id));
                FND_MSG_PUB.ADD;
                --DBMS_OUTPUT.PUT_LINE('PARENT IDS EXE ERROR');
                RAISE FND_API.G_EXC_ERROR;

            END IF;
            IF (l_bsc_dim_obj_rec.Bsc_Source = 'PMF') THEN
                IF((l_bsc_dim_obj_rec.Bsc_Data_Source_Type IS NULL) OR
                   ((l_bsc_dim_obj_rec.Bsc_Data_Source_Type <> 'TABLE') AND
                    (l_bsc_dim_obj_rec.Bsc_Data_Source_Type <> 'API'))) THEN
                        --need more clarifications what value should bo here
                        l_bsc_dim_obj_rec.Bsc_Data_Source_Type  :=  NULL;
                END IF;
                l_bsc_dim_obj_rec.bsc_relation_type :=  1;
            END IF;

            -- moved below the above IF condition for Bug#4619393
            IF (l_bsc_dim_obj_rec.bsc_relation_type = 2) THEN
                --for realtion type 2, pass this value as null, it will be generated internally
                l_bsc_dim_obj_rec.bsc_relation_column     :=  NULL;
            END IF;

            --DBMS_OUTPUT.PUT_LINE('PARENT IDS STAGE2');
            --DBMS_OUTPUT.PUT_LINE('l_bsc_dim_obj_rec.bsc_level_id          <'||l_bsc_dim_obj_rec.bsc_level_id);
            --DBMS_OUTPUT.PUT_LINE('l_bsc_dim_obj_rec.bsc_parent_level_id   <'||l_bsc_dim_obj_rec.bsc_parent_level_id);
            --DBMS_OUTPUT.PUT_LINE('l_bsc_dim_obj_rec.bsc_relation_type     <'||l_bsc_dim_obj_rec.bsc_relation_type);
            --DBMS_OUTPUT.PUT_LINE('l_bsc_dim_obj_rec.bsc_relation_column   <'||l_bsc_dim_obj_rec.bsc_relation_column);
            --DBMS_OUTPUT.PUT_LINE('l_bsc_dim_obj_rec.Bsc_Data_Source_Type  <'||l_bsc_dim_obj_rec.Bsc_Data_Source_Type);
            --DBMS_OUTPUT.PUT_LINE('l_bsc_dim_obj_rec.Bsc_Data_Source       <'||l_bsc_dim_obj_rec.Bsc_Data_Source);
            IF ((l_bsc_dim_obj_rec.bsc_relation_type = 2) AND
                (l_bsc_dim_obj_rec.Bsc_Level_Id = l_bsc_dim_obj_rec.bsc_parent_level_id)) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_SAME_DIM_LEVEL_REL');
                FND_MESSAGE.SET_TOKEN('LEVEL_CHILD', BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Name(l_bsc_dim_obj_rec.Bsc_Level_Id));
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
                --DBMS_OUTPUT.PUT_LINE('PARENT IDS EXE ERROR');
            END IF;

            -- Get the Dimension Object Relationship for Bug #3395161
            l_count := 1;

            IF (c_db_child_type%ISOPEN) THEN
                CLOSE c_db_child_type;
            END IF;

            OPEN  c_db_child_type;
            FETCH c_db_child_type INTO l_db_child_rel_type;
            IF(c_db_child_type%NOTFOUND) THEN
                l_count := 0;
            END IF;
            CLOSE c_db_child_type;


            --DBMS_OUTPUT.PUT_LINE('PARENT IDS STAGE3');
            IF (l_count = 0) THEN
                IF (l_bsc_dim_obj_rec.bsc_relation_type = 1) THEN
                    --DBMS_OUTPUT.PUT_LINE('BEFORE BSC_DIMENSION_LEVELS_PUB.Is_Valid_Relationship');
                    l_flag  :=  BSC_DIMENSION_LEVELS_PUB.Is_Valid_Relationship
                                (       p_commit            =>  FND_API.G_FALSE
                                    ,   p_Dim_Level_Rec     =>  l_bsc_dim_obj_rec
                                    ,   x_return_status     =>  x_return_status
                                    ,   x_msg_count         =>  x_msg_count
                                    ,   x_msg_data          =>  x_msg_data
                                );
                    IF (NOT l_flag) THEN
                        --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Failed: at BSC_DIMENSION_LEVELS_PUB.Is_Valid_Relationship');
                        RAISE            FND_API.G_EXC_ERROR;
                        --DBMS_OUTPUT.PUT_LINE('PARENT IDS EXE ERROR');
                    END IF;
                ELSE
                    SELECT COUNT(*) INTO l_count
                    FROM   BSC_SYS_DIM_LEVEL_RELS
                    WHERE  dim_level_id        =  l_bsc_dim_obj_rec.Bsc_Parent_Level_Id
                    AND    parent_dim_level_id =  l_bsc_dim_obj_rec.Bsc_Level_Id;
                    IF (l_count <> 0) THEN
                        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_RELATIONSHIPS');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                END IF;

                --DBMS_OUTPUT.PUT_LINE('BEFORE BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level_Relation');
                BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level_Relation
                (       p_commit          =>    FND_API.G_FALSE
                    ,   p_Dim_Level_Rec   =>    l_bsc_dim_obj_rec
                    ,   x_return_status   =>    x_return_status
                    ,   x_msg_count       =>    x_msg_count
                    ,   x_msg_data        =>    x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Failed: at BSC_DIMENSION_LEVELS_PUB.create_dim_level_relation');
                    RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                -- START Granluar Locking
                -- Change the time stamp of the Parent Dimension Level
                IF(p_is_not_config) THEN
                    BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_LEVEL
                    (     p_dim_level_id    =>    l_bsc_dim_obj_rec.bsc_parent_level_id
                      ,   x_return_status   =>    x_return_status
                      ,   x_msg_count       =>    x_msg_count
                      ,   x_msg_data        =>    x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Failed: at BSC_DIMENSION_LEVELS_PUB.create_dim_level_relation');
                        RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
                --DBMS_OUTPUT.PUT_LINE('PARENT IDS STAGE4');
                -- END Granluar Locking
            ELSE
                -- Added condition to filter MxN type for parent shuttle DimObjs for Bug #3395161
                -- added further condition for Bug#4601099
                l_Is_PMF_Recur_Type := FALSE;
                IF ((l_bsc_dim_obj_rec.bsc_level_id = l_bsc_dim_obj_rec.bsc_parent_level_id) AND
                    l_bsc_dim_obj_rec.Bsc_Source = 'PMF') THEN
                    l_Is_PMF_Recur_Type := TRUE;
                END IF;

                IF (NOT ((l_db_child_rel_type = 2) AND (l_bsc_dim_obj_rec.bsc_relation_type = 2)) AND l_Is_PMF_Recur_Type = FALSE)THEN
                    FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_RELATIONSHIPS');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;
        END LOOP;
    END IF;
    --DBMS_OUTPUT.PUT_LINE('AFTER CHILD IDS');
    --get the size of the tables and put them into some local variables
    l_One_N_Count       :=  l_One_N_Table.COUNT;
    l_M_N_Count         :=  l_M_N_Table.COUNT;
    lg_index            :=  l_M_N_Count;
    --DBMS_OUTPUT.PUT_LINE('l_One_N_Count  '||l_One_N_Count);
    --DBMS_OUTPUT.PUT_LINE('l_M_N_Count    '||l_M_N_Count);
    FOR cd IN c_new_relations LOOP
        l_dim_obj_id        :=   cd.Dim_Level_Id;
        l_one_N_flag        :=   TRUE;
        l_Num_One_N_Count   :=  -1;
        l_count             :=   0;
        --DBMS_OUTPUT.PUT_LINE('cd.Dim_Level_Id '||l_dim_obj_id);
        FOR bsc_cn IN c_par_dim_ids LOOP
            --DBMS_OUTPUT.PUT_LINE('cn.parent_dim_level_id '||cn.parent_dim_level_id);
            --DBMS_OUTPUT.PUT_LINE('cn.relation_type       '||cn.relation_type);
            IF ((bsc_cn.parent_dim_level_id = p_dim_obj_id) OR (bsc_cn.dim_level_id = p_dim_obj_id)) THEN
                IF (bsc_cn.relation_type = 1) THEN
                    l_count :=  l_count + 1;
                    IF (l_one_N_flag) THEN
                        FOR i IN 0..(l_One_N_Table.COUNT-1) LOOP
                            IF (l_One_N_Table(i).p_dim_obj_id = l_dim_obj_id) THEN
                                l_one_N_flag      := FALSE;
                                l_Num_One_N_Count := i;
                                EXIT;
                            END IF;
                        END LOOP;
                    END IF;
                    IF (l_Num_One_N_Count = -1) THEN
                        l_One_N_Table(l_One_N_Count).p_dim_obj_id     :=  l_dim_obj_id;
                        l_One_N_Table(l_One_N_Count).p_refresh_flag   :=  TRUE;
                        l_One_N_Count    :=  l_One_N_Count + 1;
                    ELSE
                        l_flag          := FALSE;
                        l_parent_ids    := l_One_N_Table(l_Num_One_N_Count).p_Parent_dim_ids;
                        --DBMS_OUTPUT.PUT_LINE('l_parent_ids   '||l_parent_ids);
                        WHILE (is_more(     p_dim_lev_ids   =>  l_parent_ids
                                        ,   p_dim_lev_id    =>  lg_dim_obj_id)
                        ) LOOP
                            IF (lg_dim_obj_id = bsc_cn.parent_dim_level_id) THEN
                                --DBMS_OUTPUT.PUT_LINE('p_parent_count       '||l_One_N_Table(l_Num_One_N_Count).p_parent_count);
                                --DBMS_OUTPUT.PUT_LINE('l_count              '||l_count);
                                IF (l_count = l_One_N_Table(l_Num_One_N_Count).p_parent_count) THEN
                                    l_One_N_Table(l_Num_One_N_Count).p_refresh_flag := FALSE;
                                ELSE
                                    l_One_N_Table(l_Num_One_N_Count).p_refresh_flag := TRUE;
                                END IF;
                                l_flag := TRUE;
                                EXIT;
                            END IF;
                        END LOOP;
                        IF (NOT l_flag) THEN
                            l_One_N_Table(l_Num_One_N_Count).p_refresh_flag := TRUE;
                            EXIT;
                        END IF;
                    END IF;
                ELSIF (bsc_cn.relation_type = 2) THEN
                    l_flag  := FALSE;
                    IF (l_dim_obj_id < bsc_cn.parent_dim_level_id) THEN
                        FOR i IN 0..(l_M_N_Table.COUNT-1) LOOP
                           IF ((l_M_N_Table(i).p_dim_obj_id =  l_dim_obj_id) AND
                                (l_M_N_Table(i).p_Parent_dim_id =  bsc_cn.parent_dim_level_id)) THEN
                                IF(i < lg_index) THEN
                                    l_M_N_Table(i).p_refresh_flag    :=  FALSE;
                                END IF;
                                l_flag := TRUE;
                                EXIT;
                           END IF;
                        END LOOP;
                        IF (NOT l_flag) THEN
                            --DBMS_OUTPUT.PUT_LINE('l_M_N_Count              '||l_M_N_Count);
                            --DBMS_OUTPUT.PUT_LINE('cn.parent_dim_level_id   '||cn.parent_dim_level_id);
                            --DBMS_OUTPUT.PUT_LINE('l_dim_obj_id             '||l_dim_obj_id);
                            l_M_N_Table(l_M_N_Count).p_dim_obj_id      :=  l_dim_obj_id ;
                            l_M_N_Table(l_M_N_Count).p_Parent_dim_id   :=  bsc_cn.parent_dim_level_id;
                            l_M_N_Table(l_M_N_Count).p_refresh_flag    :=  TRUE;
                            l_M_N_Count         :=  l_M_N_Count + 1;
                        END IF;
                    ELSE
                        FOR i IN 0..(l_M_N_Table.COUNT-1) LOOP
                           IF ((l_M_N_Table(i).p_dim_obj_id =  bsc_cn.parent_dim_level_id) AND
                                 (l_M_N_Table(i).p_Parent_dim_id =  l_dim_obj_id)) THEN
                                IF(i < lg_index) THEN
                                    l_M_N_Table(i).p_refresh_flag    :=  FALSE;
                                END IF;
                                l_flag := TRUE;
                                EXIT;
                           END IF;
                        END LOOP;
                        IF (NOT l_flag) THEN
                            --DBMS_OUTPUT.PUT_LINE('l_M_N_Count              '||l_M_N_Count);
                            --DBMS_OUTPUT.PUT_LINE('cn.parent_dim_level_id   '||cn.parent_dim_level_id);
                            --DBMS_OUTPUT.PUT_LINE('l_dim_obj_id             '||l_dim_obj_id);
                            l_M_N_Table(l_M_N_Count).p_dim_obj_id      :=  bsc_cn.parent_dim_level_id;
                            l_M_N_Table(l_M_N_Count).p_Parent_dim_id   :=  l_dim_obj_id;
                            l_M_N_Table(l_M_N_Count).p_refresh_flag    :=  TRUE;
                            l_M_N_Count         :=  l_M_N_Count + 1;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END LOOP;
    l_refresh_kpi_ids   :=  ',';
    FOR i IN 0..(l_One_N_Table.COUNT-1) LOOP
        IF (l_One_N_Table(i).p_refresh_flag) THEN
            l_refresh_kpi_ids   :=  l_refresh_kpi_ids||l_One_N_Table(i).p_dim_obj_id||',';
        END IF;
    END LOOP;
    FOR i IN 0..(l_M_N_Table.COUNT-1) LOOP
        IF (l_M_N_Table(i).p_refresh_flag) THEN
            IF(INSTR(l_refresh_kpi_ids, ','||l_M_N_Table(i).p_dim_obj_id||',') = 0) THEN
                l_refresh_kpi_ids   :=  l_refresh_kpi_ids||l_M_N_Table(i).p_dim_obj_id||',';
            END IF;
            IF(INSTR(l_refresh_kpi_ids, ','||l_M_N_Table(i).p_Parent_dim_id||',') = 0) THEN
                l_refresh_kpi_ids   :=  l_refresh_kpi_ids||l_M_N_Table(i).p_Parent_dim_id||',';
            END IF;
        END IF;
    END LOOP;

    --DBMS_OUTPUT.PUT_LINE('l_refresh_kpi_ids   '||l_refresh_kpi_ids);
    IF (l_refresh_kpi_ids <> ',') THEN
        --DBMS_OUTPUT.PUT_LINE('Cascading changes to KPIs Part Starts Here');
        FOR cd IN c_kpi_dim_set LOOP
            --DBMS_OUTPUT.PUT_LINE('BEFORE BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet');
            IF(NOT (l_source = 'PMF' AND cd.short_name IS NULL)) THEN
              BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet
              (       p_commit             =>   FND_API.G_FALSE
                  ,   p_kpi_id             =>   cd.Indicator
                  ,   p_dim_set_id         =>   cd.Dim_Set_Id
                  ,   p_delete             =>   TRUE -- delete before creating in cascading
                  ,   x_return_status      =>   x_return_status
                  ,   x_msg_count          =>   x_msg_count
                  ,   x_msg_data           =>   x_msg_data
              );
             END IF;
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Failed: at BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END LOOP;
        --DBMS_OUTPUT.PUT_LINE('Cascading changes to KPIs Part Ends Here');
    /********************************************************
                Check no of independent dimension objects in dimension set
    ********************************************************/

    BSC_BIS_DIM_OBJ_PUB.check_indp_dimobjs
    (
            p_dim_id                    =>  p_dim_obj_id
        ,   x_return_status             =>  x_return_status
        ,   x_msg_count                 =>  x_msg_count
        ,   x_msg_data                  =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_OBJ_PUB.check_indp_dimobjs Failed: at BSC_DIMENSION_LEVELS_PUB.Update_Dim_Level <'||x_msg_data||'>');
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

        /*************************************************************
        List Button validation.For a list button all the dimension objects
        should have 1xM relationship.If the relationhsip is changed to
        MxN then list button should be disabled.
        /************************************************************/
        BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button
        (    p_Kpi_Id           =>  NULL
          ,  p_Dim_Level_Id     =>  p_dim_obj_id
          ,  x_return_status    =>  x_return_status
          ,  x_msg_count        =>  x_msg_count
          ,  x_msg_data         =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Failed:  at BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button');
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    --DBMS_OUTPUT.PUT_LINE('  ---  FINAL TABLE  ----');
    --DBMS_OUTPUT.PUT_LINE('PRINT OUT OF THE TABLES THAT WE HAVE GOT 1 x N RELATIONS');
    /*FOR i IN 0..(l_One_N_Table.COUNT-1) LOOP
        --DBMS_OUTPUT.PUT_LINE('l_One_N_Table('||i||').p_dim_obj_id '||l_One_N_Table(i).p_dim_obj_id);
        IF (l_One_N_Table(i).p_refresh_flag) THEN
            --DBMS_OUTPUT.PUT_LINE('l_One_N_Table('||i||').p_refresh_flag TRUE');
        ELSE
            --DBMS_OUTPUT.PUT_LINE('l_One_N_Table('||i||').p_refresh_flag FALSE');
        END IF;
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE('PRINT OUT OF THE TABLES THAT WE HAVE GOT M x N RELATIONS');
    FOR i IN 0..(l_M_N_Table.COUNT-1) LOOP
        --DBMS_OUTPUT.PUT_LINE('l_M_N_Table('||i||').p_dim_obj_id    '||l_M_N_Table(i).p_dim_obj_id);
        --DBMS_OUTPUT.PUT_LINE('l_M_N_Table('||i||').p_Parent_dim_id '||l_M_N_Table(i).p_Parent_dim_id);
        IF (l_M_N_Table(i).p_refresh_flag) THEN
            --DBMS_OUTPUT.PUT_LINE('l_M_N_Table('||i||').p_refresh_flag TRUE');
        ELSE
            --DBMS_OUTPUT.PUT_LINE('l_M_N_Table('||i||').p_refresh_flag FALSE');
        END IF;
    END LOOP;*/
    IF ((p_is_not_config) AND (l_source = 'BSC')) THEN
        FOR i IN 0..(l_One_N_Table.COUNT-1) LOOP
            IF (l_One_N_Table(i).p_refresh_flag) THEN
                SELECT  COUNT(A.Parent_Dim_Level_Id) INTO l_Count
                FROM    BSC_SYS_DIM_LEVEL_RELS   A
                WHERE   A.Dim_Level_Id  = l_One_N_Table(i).p_dim_obj_id
                AND     A.Relation_Type = 1;
                IF (l_Count > MAX_PARENTS_RELS_1_N) THEN
                    FND_MESSAGE.SET_NAME('BSC','BSC_MAX_DIM_OBJ_RELS');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;
        END LOOP;
        --DBMS_OUTPUT.PUT_LINE('REFRESHING MASTER TABLES PART STARTS HERE');
        --DBMS_OUTPUT.PUT_LINE('---  ******** FOR 1 x N RELATIONS ******** -----');
        FOR i IN 0..(l_One_N_Table.COUNT-1) LOOP
            IF (l_One_N_Table(i).p_refresh_flag) THEN
                --DBMS_OUTPUT.PUT_LINE('Parameters to BSC_BIS_DIM_REL_PUB.Create_One_To_N_MTable');
                --DBMS_OUTPUT.PUT_LINE('p_dim_obj_id  '||l_One_N_Table(i).p_dim_obj_id);
                l_flag  :=  BSC_BIS_DIM_REL_PUB.Create_One_To_N_MTable
                            (       p_dim_obj_id        =>  l_One_N_Table(i).p_dim_obj_id
                                ,   x_return_status     =>  x_return_status
                                ,   x_msg_count         =>  x_msg_count
                                ,   x_msg_data          =>  x_msg_data
                            );
                IF(NOT l_flag) THEN
                    --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Failed: at BSC_BIS_DIM_REL_PUB.Create_One_To_N_MTable <'||x_msg_data||'>');
                    RAISE  FND_API.G_EXC_ERROR;
                END IF;
            END IF;
        END LOOP;
        --DBMS_OUTPUT.PUT_LINE('---  ******** FOR M x N RELATIONS ******** -----');
        FOR i IN 0..(l_M_N_Table.COUNT-1) LOOP
            IF (l_M_N_Table(i).p_refresh_flag) THEN
                --DBMS_OUTPUT.PUT_LINE('Parameters to BSC_BIS_DIM_REL_PUB.Create_M_To_N_MTable');
                --DBMS_OUTPUT.PUT_LINE('p_dim_obj_id  '||l_M_N_Table(i).p_dim_obj_id);
                --DBMS_OUTPUT.PUT_LINE('p_parent_ids  '||l_M_N_Table(i).p_Parent_dim_id);
                l_flag  :=  BSC_BIS_DIM_REL_PUB.Create_M_To_N_MTable
                            (       p_dim_obj_id        =>  l_M_N_Table(i).p_dim_obj_id
                                ,   p_parent_id         =>  l_M_N_Table(i).p_Parent_dim_id
                                ,   x_return_status     =>  x_return_status
                                ,   x_msg_count         =>  x_msg_count
                                ,   x_msg_data          =>  x_msg_data
                            );
                IF (NOT l_flag) THEN
                    --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Failed: at BSC_BIS_DIM_REL_PUB.Create_M_To_N_MTable <'||x_msg_data||'>');
                    RAISE            FND_API.G_EXC_ERROR;
                END IF;
            END IF;
        END LOOP;
        --DBMS_OUTPUT.PUT_LINE('REFRESHING MASTER TABLES PART ENDS HERE');
    END IF;

    IF((p_is_not_config) AND (l_source = 'BSC'))THEN
        BSC_BIS_DIM_REL_PUB.store_Relations
         (       p_dim_obj_id        =>  p_dim_obj_id
             ,   x_rel_Table         =>  l_new_rel_Table
             ,   x_return_status     =>  x_return_status
             ,   x_msg_count         =>  x_msg_count
             ,   x_msg_data          =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Failed: at BSC_BIS_DIM_REL_PUB.store_Prev_Relations <'||x_msg_data||'>');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        BSC_BIS_DIM_REL_PUB.Validate_Filter_Button
        (
                 p_dim_obj_id        =>  p_dim_obj_id
             ,   x_new_rel_Table     =>  l_new_rel_Table
             ,   x_prev_rel_Table    =>  l_prev_rel_Table
             ,   x_return_status     =>  x_return_status
             ,   x_msg_count         =>  x_msg_count
             ,   x_msg_data          =>  x_msg_data

        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Failed: at BSC_BIS_DIM_REL_PUB.store_Prev_Relations <'||x_msg_data||'>');
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    -- To delete denormailized table which is created from recursive relationship
    /****************************************************
     BSC_PMA_APIS_PUB.sync_dimension_table Should be called only when
     BSC53 is installed.So first we are checking if BSC53 is installed on the
     environment.Since this file is the part of MD/DD ARU we have made the call to
     the PL/SQL procedure "BSC_PMA_APIS_PUB.sync_dimension_table" dynamic so that
     the package gets complied on the pure BIS409 enviornments.
    /****************************************************/

    IF(BIS_UTILITIES_PUB.Enable_Generated_Source_Report = FND_API.G_TRUE) THEN
        l_is_denorm_deleted := FND_API.G_TRUE;

        SELECT short_name
        INTO   l_dim_short_name
        FROM   bsc_sys_dim_levels_b
        WHERE  dim_level_id = p_dim_obj_id;

        BEGIN
            l_Sql := 'BEGIN IF(BSC_PMA_APIS_PUB.sync_dimension_table (:2,:3,:4)) THEN :1 :=FND_API.G_TRUE; ELSE :1:=FND_API.G_FALSE; END IF;END;';
            EXECUTE IMMEDIATE l_Sql USING IN l_dim_short_name,IN BIS_UTIL.G_ALTER_TABLE,OUT x_msg_data,OUT l_is_denorm_deleted;
        EXCEPTION
           WHEN OTHERS THEN
             NULL;
        END;

        IF(l_is_denorm_deleted=FND_API.G_FALSE) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    -- Added for Bug#4758995
    IF (l_source = BSC_UTILITY.c_PMF) THEN

        SELECT short_name
        INTO   l_dim_short_name
        FROM   bsc_sys_dim_levels_b
        WHERE  dim_level_id = p_dim_obj_id;

        BSC_BIS_DIM_OBJ_PUB.Refresh_BSC_PMF_Dim_View
        (       p_Short_Name      => l_dim_short_name
            ,   x_return_status   => x_return_status
            ,   x_msg_count       => x_msg_count
            ,   x_msg_data        => x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- now, refresh all the child dimension object views as well - Bug#5300060
        -- Create an unique list child IDs ,which has been removed from the relationship, which exist in
        -- the relationship and that have been newly added to relationship
        l_rel_ids := BSC_UTILITY.Create_Unique_Comma_List(l_original_child_ids, p_child_ids);

        IF (l_rel_ids IS NOT NULL) THEN
            WHILE (is_more(     p_dim_lev_ids   => l_rel_ids
                            ,   p_dim_lev_id    => l_rel_id
            )) LOOP

              SELECT short_name
              INTO   l_dim_short_name
              FROM   bsc_sys_dim_levels_b
              WHERE  dim_level_id = l_rel_id;

              BSC_BIS_DIM_OBJ_PUB.Refresh_BSC_PMF_Dim_View
              (       p_Short_Name      => l_dim_short_name
                  ,   x_return_status   => x_return_status
                  ,   x_msg_count       => x_msg_count
                  ,   x_msg_data        => x_msg_data
              );
              IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                  RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END LOOP;
        END IF;
    END IF;

    -- START Granluar Locking
    -- Change the time stamp of the main Dimension Level
    IF (p_is_not_config) THEN
        BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_LEVEL
        (      p_dim_level_id    =>    p_dim_obj_id
           ,   x_return_status   =>    x_return_status
           ,   x_msg_count       =>    x_msg_count
           ,   x_msg_data        =>    x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (p_commit = FND_API.G_TRUE) THEN
            COMMIT;
            --DBMS_OUTPUT.PUT_LINE('COMMIT SUCCESSFUL');
        END IF;
    END IF;

    -- END Granluar Locking

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --DBMS_OUTPUT.PUT_LINE('Exiting from BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels Procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        IF (c_db_child_type%ISOPEN) THEN
            CLOSE c_db_child_type;
        END IF;
        ROLLBACK TO AssUnassBSCRelsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_db_child_type%ISOPEN) THEN
            CLOSE c_db_child_type;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        ROLLBACK TO AssUnassBSCRelsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        IF (c_db_child_type%ISOPEN) THEN
            CLOSE c_db_child_type;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        ROLLBACK TO AssUnassBSCRelsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels ';
        END IF;
    WHEN OTHERS THEN
        IF (c_db_child_type%ISOPEN) THEN
            CLOSE c_db_child_type;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        ROLLBACK TO AssUnassBSCRelsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels ';
        END IF;
END Assign_New_Dim_Obj_Rels;
/*********************************************************************************
                      UNASSIGN DIMENSION-OBJECTS RELATIONSHIPS
*********************************************************************************/
PROCEDURE UnAssign_Dim_Obj_Rels
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_id            IN          NUMBER
    ,   p_parent_ids            IN          VARCHAR2
    ,   p_child_ids             IN          VARCHAR2
    ,   p_time_stamp            IN          VARCHAR2   := NULL   -- Granular Locking
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
    l_dim_obj_ids               VARCHAR2(32000);
    l_dim_obj_id                BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE;
    l_flag                      BOOLEAN :=  TRUE;

    l_parent_ids                VARCHAR2(32000);
    l_parent_rel_type           VARCHAR2(32000);
    l_parent_rel_column         VARCHAR2(32000);
    l_parent_data_type          VARCHAR2(32000);
    l_parent_data_source        VARCHAR2(32000);
    l_child_ids                 VARCHAR2(32000);
    l_child_rel_type            VARCHAR2(32000);
    l_child_rel_column          VARCHAR2(32000);
    l_child_data_type           VARCHAR2(32000);
    l_child_data_source         VARCHAR2(32000);

    CURSOR  c_parent_ids IS
    SELECT  parent_dim_level_id
          , relation_type
          , relation_col
          , data_source_type
          , data_source
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   dim_level_id = p_dim_obj_id;

    CURSOR  c_childs_ids IS
    SELECT  dim_level_id
          , relation_type
          , relation_col
          , data_source_type
          , data_source
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   parent_dim_level_id = p_dim_obj_id
    AND     relation_type       = 1;
BEGIN
    --DBMS_OUTPUT.PUT_LINE('Entered inside BSC_BIS_DIM_REL_PUB.UnAssign_Dim_Obj_Rels Procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_dim_obj_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    FOR cd IN c_parent_ids LOOP
        l_dim_obj_ids  :=   p_parent_ids;
        l_flag         :=   TRUE;
        IF (l_dim_obj_ids IS NOT NULL) THEN
            WHILE (is_more(     p_dim_lev_ids   =>  l_dim_obj_ids
                            ,   p_dim_lev_id    =>  l_dim_obj_id)
            ) LOOP
                IF (l_dim_obj_id = TO_CHAR(cd.parent_dim_level_id)) THEN
                    l_flag  :=  FALSE;
                    EXIT;
                END IF;
            END LOOP;
        END IF;
        IF (l_flag) THEN
            IF (l_parent_ids IS NULL) THEN
                l_parent_ids         :=  NVL(TO_CHAR(cd.parent_dim_level_id), 'NULL');
            ELSE
                l_parent_ids         :=  l_parent_ids||', '||NVL(TO_CHAR(cd.parent_dim_level_id), 'NULL');
            END IF;
            IF (l_parent_rel_type IS NULL) THEN
                l_parent_rel_type    :=  NVL(TO_CHAR(cd.relation_type), 'NULL');
            ELSE
                l_parent_rel_type    :=  l_parent_rel_type||', '||NVL(TO_CHAR(cd.relation_type), 'NULL');
            END IF;
            IF (l_parent_rel_column IS NULL) THEN
                l_parent_rel_column  :=  NVL(cd.relation_col, 'NULL');
            ELSE
                l_parent_rel_column  :=  l_parent_rel_column||', '||NVL(cd.relation_col, 'NULL');
            END IF;
            IF (l_parent_data_type IS NULL) THEN
                l_parent_data_type   :=  NVL(cd.data_source_type, 'NULL');
            ELSE
                l_parent_data_type   :=  l_parent_data_type||', '||NVL(cd.data_source_type, 'NULL');
            END IF;
            IF (l_parent_data_source IS NULL) THEN
                l_parent_data_source :=  NVL(cd.data_source, 'NULL');
            ELSE
                l_parent_data_source :=  l_parent_data_source||', '||NVL(cd.data_source, 'NULL');
            END IF;
        END IF;
    END LOOP;
    FOR cd IN c_childs_ids LOOP
        l_dim_obj_ids  :=   p_child_ids;
        l_flag         :=   TRUE;
        IF (l_dim_obj_ids IS NOT NULL) THEN
            WHILE (is_more(     p_dim_lev_ids   =>  l_dim_obj_ids
                            ,   p_dim_lev_id    =>  l_dim_obj_id)
            ) LOOP
                IF (l_dim_obj_id = TO_CHAR(cd.dim_level_id)) THEN
                    l_flag  :=  FALSE;
                    EXIT;
                END IF;
            END LOOP;
        END IF;
        IF (l_flag) THEN
            IF (l_child_ids IS NULL) THEN
                l_child_ids         :=  NVL(TO_CHAR(cd.dim_level_id), 'NULL');
            ELSE
                l_child_ids :=  l_child_ids||', '||NVL(TO_CHAR(cd.dim_level_id), 'NULL');
            END IF;
            IF (l_child_rel_type IS NULL) THEN
                l_child_rel_type    :=  NVL(TO_CHAR(cd.relation_type), 'NULL');
            ELSE
                l_child_rel_type    :=  l_child_rel_type||', '||NVL(TO_CHAR(cd.relation_type), 'NULL');
            END IF;
            IF (l_child_rel_column IS NULL) THEN
                l_child_rel_column  :=  NVL(cd.relation_col, 'NULL');
            ELSE
                l_child_rel_column  :=  l_child_rel_column||', '||NVL(cd.relation_col, 'NULL');
            END IF;
            IF (l_child_data_type IS NULL) THEN
                l_child_data_type   :=  NVL(cd.data_source_type, 'NULL');
            ELSE
                l_child_data_type   :=  l_child_data_type||', '||NVL(cd.data_source_type, 'NULL');
            END IF;
            IF (l_child_data_source IS NULL) THEN
                l_child_data_source :=  NVL(cd.data_source, 'NULL');
            ELSE
                l_child_data_source :=  l_child_data_source||', '||NVL(cd.data_source, 'NULL');
            END IF;
        END IF;
    END LOOP;
    BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_dim_obj_id            =>  p_dim_obj_id
        ,   p_parent_ids            =>  l_parent_ids
        ,   p_parent_rel_type       =>  l_parent_rel_type
        ,   p_parent_rel_column     =>  l_parent_rel_column
        ,   p_parent_data_type      =>  l_parent_data_type
        ,   p_parent_data_source    =>  l_parent_data_source
        ,   p_child_ids             =>  l_child_ids
        ,   p_child_rel_type        =>  l_child_rel_type
        ,   p_child_rel_column      =>  l_child_rel_column
        ,   p_child_data_type       =>  l_child_data_type
        ,   p_child_data_source     =>  l_child_data_source
        ,   p_time_stamp            =>  p_time_stamp
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.UnAssign_Dim_Obj_Rels Failed: at BSC_BIS_DIM_REL_PUB.Assign_New_Dim_Obj_Rels');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --DBMS_OUTPUT.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    --DBMS_OUTPUT.PUT_LINE('Exiting from BSC_BIS_DIM_REL_PUB.UnAssign_Dim_Obj_Rels Procedure');
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
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.UnAssign_Dim_Obj_Rels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.UnAssign_Dim_Obj_Rels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.UnAssign_Dim_Obj_Rels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.UnAssign_Dim_Obj_Rels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END UnAssign_Dim_Obj_Rels;

/*********************************************************************************
                            FUNCTION GET_PARENTS
*********************************************************************************/
FUNCTION get_parents
(
    p_dim_obj_id  IN  NUMBER
) RETURN VARCHAR2
IS
    l_parent_dim_names VARCHAR2(32000);
    l_name             BSC_SYS_DIM_LEVELS_TL.NAME%TYPE;

    CURSOR  c_parent_dim_level_name IS
    SELECT  l.name name
    FROM    BSC_SYS_DIM_LEVEL_RELS r
         ,  BSC_SYS_DIM_LEVELS_VL  l
    WHERE   r.dim_level_id        = p_dim_obj_id
    AND     r.parent_dim_level_id = l.dim_level_id;
BEGIN
    IF (c_parent_dim_level_name%ISOPEN) THEN
        CLOSE c_parent_dim_level_name;
    END IF;

    FOR cd IN c_parent_dim_level_name LOOP
        l_name := cd.name;
        IF (l_name IS NOT NULL) THEN
            IF (l_parent_dim_names IS NULL) THEN
                l_parent_dim_names := l_name;
            ELSE
                l_parent_dim_names := l_parent_dim_names ||', '|| l_name;
            END IF;
        END IF;
    END LOOP;
    RETURN l_parent_dim_names;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_parent_dim_level_name%ISOPEN) THEN
            CLOSE c_parent_dim_level_name;
        END IF;
        RETURN NULL;
END get_parents;

/*********************************************************************************
                            FUNCTION GET_CHILDS
*********************************************************************************/
FUNCTION get_children
(
    p_dim_obj_id  IN  NUMBER
) RETURN VARCHAR2
IS
    l_child_dim_names VARCHAR2(32000);
    l_name BSC_SYS_DIM_LEVELS_TL.NAME%TYPE;

    CURSOR  c_child_dim_level_name IS
    SELECT  l.name name
    FROM    BSC_SYS_DIM_LEVEL_RELS  r
          , BSC_SYS_DIM_LEVELS_VL   l
    WHERE   r.parent_dim_level_id = p_dim_obj_id
    AND     r.dim_level_id        = l.dim_level_id;
BEGIN
    IF (c_child_dim_level_name%ISOPEN) THEN
        CLOSE c_child_dim_level_name;
    END IF;

    FOR cd IN c_child_dim_level_name LOOP
        l_name := cd.name;
        IF (l_name IS NOT NULL) THEN
            IF (l_child_dim_names IS NULL) THEN
                l_child_dim_names := l_name;
            ELSE
                l_child_dim_names := l_child_dim_names ||', '|| l_name;
            END IF;
        END IF;
    END LOOP;
    RETURN l_child_dim_names;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_child_dim_level_name%ISOPEN) THEN
            CLOSE c_child_dim_level_name;
        END IF;
    RETURN NULL;
END get_children;


/*********************************************************************************
                 FUNCTION Get_Original_Child_Ids -- Bug#5300060
*********************************************************************************/
FUNCTION Get_Original_Child_Ids
(
    p_dim_obj_id  IN  NUMBER
) RETURN VARCHAR2
IS
    l_child_dim_ids VARCHAR2(32000);

    CURSOR  c_child_dim_level_ids IS
    SELECT  r.DIM_LEVEL_ID
    FROM    BSC_SYS_DIM_LEVEL_RELS  r
    WHERE   r.parent_dim_level_id = p_dim_obj_id;
BEGIN
    FOR cd IN c_child_dim_level_ids LOOP
      IF (l_child_dim_ids IS NULL) THEN
        l_child_dim_ids := CD.dim_level_id;
      ELSE
        l_child_dim_ids := l_child_dim_ids || ',' || CD.dim_level_id;
      END IF;
    END LOOP;

    RETURN l_child_dim_ids;
EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
END Get_Original_Child_Ids;

--==============================================================
FUNCTION Is_More
(       x_remain_id             IN  OUT     NOCOPY  VARCHAR2
    ,   x_remain_rel_type       IN  OUT     NOCOPY  VARCHAR2
    ,   x_remain_rel_column     IN  OUT     NOCOPY  VARCHAR2
    ,   x_remain_data_type      IN  OUT     NOCOPY  VARCHAR2
    ,   x_remain_data_source    IN  OUT     NOCOPY  VARCHAR2
    ,   x_id                        OUT     NOCOPY  NUMBER
    ,   x_rel_type                  OUT     NOCOPY  NUMBER
    ,   x_rel_column                OUT     NOCOPY  VARCHAR2
    ,   x_data_type                 OUT     NOCOPY  VARCHAR2
    ,   x_data_source               OUT     NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
    l_pos_rel_columns       NUMBER;
    l_pos_data_types        NUMBER;
    l_pos_data_sources      NUMBER;

BEGIN
    IF (x_remain_id IS NOT NULL) THEN
        l_pos_ids           := INSTR(x_remain_id,            ',');
        l_pos_rel_types     := INSTR(x_remain_rel_type,      ',');
        l_pos_rel_columns   := INSTR(x_remain_rel_column,    ',');
        l_pos_data_types    := INSTR(x_remain_data_type,     ',');
        l_pos_data_sources  := INSTR(x_remain_data_source,   ',');

        IF (l_pos_ids > 0) THEN
            x_id                    :=  TO_NUMBER(TRIM(SUBSTR(x_remain_id,           1,    l_pos_ids - 1)));
            x_rel_type              :=  TO_NUMBER(TRIM(SUBSTR(x_remain_rel_type,     1,    l_pos_rel_types   - 1)));
            x_rel_column            :=  TRIM(SUBSTR(x_remain_rel_column,   1,    l_pos_rel_columns - 1));
            IF (UPPER(x_rel_column) = 'NULL') THEN
                x_rel_column := NULL;
            END IF;
            x_data_type             :=  TRIM(SUBSTR(x_remain_data_type,    1,    l_pos_data_types   - 1));
            IF (UPPER(x_data_type) = 'NULL') THEN
                x_data_type := NULL;
            END IF;
            x_data_source           :=  TRIM(SUBSTR(x_remain_data_source,  1,    l_pos_data_sources - 1));
            IF (UPPER(x_data_source) = 'NULL') THEN
                x_data_source := NULL;
            END IF;

            x_remain_id             :=  TRIM(SUBSTR(x_remain_id,            l_pos_ids + 1));
            x_remain_rel_type       :=  TRIM(SUBSTR(x_remain_rel_type,      l_pos_rel_types + 1));
            x_remain_rel_column     :=  TRIM(SUBSTR(x_remain_rel_column,    l_pos_rel_columns + 1));
            x_remain_data_type      :=  TRIM(SUBSTR(x_remain_data_type,     l_pos_data_types + 1));
            x_remain_data_source    :=  TRIM(SUBSTR(x_remain_data_source,   l_pos_data_sources + 1));
        ELSE
            x_id                    :=  TO_NUMBER(TRIM(x_remain_id));
            x_rel_type              :=  TO_NUMBER(TRIM(x_remain_rel_type));
            x_rel_column            :=  TRIM(x_remain_rel_column);
            IF (UPPER(x_rel_column) = 'NULL') THEN
                x_rel_column := NULL;
            END IF;
            x_data_type             :=  TRIM(x_remain_data_type);
            IF (UPPER(x_data_type)  = 'NULL') THEN
                x_data_type := NULL;
            END IF;
            x_data_source           :=  TRIM(x_remain_data_source);
            IF (UPPER(x_data_source) = 'NULL') THEN
                x_data_source := NULL;
            END IF;

            x_remain_id             :=  NULL;
            x_remain_rel_column     :=  NULL;
            x_remain_rel_type       :=  NULL;
            x_remain_data_type      :=  NULL;
            x_remain_data_source    :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;
/*******************************************************************************
        FUNCTION TO CREATE MASTER TABLE FOR ONE-MANY RELATIONS IN BSC
********************************************************************************/
FUNCTION Create_One_To_N_MTable
(       p_dim_obj_id        IN          NUMBER
    ,   x_return_status     OUT NOCOPY  VARCHAR2
    ,   x_msg_count         OUT NOCOPY  NUMBER
    ,   x_msg_data          OUT NOCOPY  VARCHAR2
)
RETURN BOOLEAN IS
    l_sql_stmt                  VARCHAR2(32000);
    l_sql_stmt1                 VARCHAR2(32000);
    l_input_col_names           VARCHAR2(32000);
    l_from_clause               VARCHAR2(32000);
    l_where_clause              VARCHAR2(32000);
    l_level_pk_cols             VARCHAR2(32000);
    l_view_columns              VARCHAR2(32000);

    l_master_table              VARCHAR2(30);
    l_input_table               VARCHAR2(30);
    l_view_name                 VARCHAR2(30);
    l_dummy_table               VARCHAR2(30)    :=  'BSC_B_DUMMY_TABLE';
    l_temp_table                VARCHAR2(30);

    l_level_pk_col              BSC_SYS_DIM_LEVELS_B.Level_Pk_Col%TYPE;
    l_label_table_name          BSC_SYS_DIM_LEVELS_B.Level_Table_Name%TYPE;
    l_index_Table               BSC_BIS_DIM_REL_PUB.One_To_N_Index_Table;
    l_index_Count               NUMBER;

    l_alias                     VARCHAR2(4);
    l_flag                      BOOLEAN;

    l_col_names                 VARCHAR2(400)  :=  NULL;
    l_bsc_dim_obj_rec           BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
    l_count                     NUMBER          := 0;
    e_mlog_exception            EXCEPTION;
    l_error_msg                 VARCHAR2(4000);
    l_max_code                  NUMBER;
    l_max_usr_code              VARCHAR2(32000);

    --cursor to get the columns for creation of view based on master-table
    CURSOR  c_parents_Ids IS
    SELECT  A.Parent_Dim_Level_Id
         ,  B.Level_Pk_Col
         ,  B.Level_Table_Name
    FROM    BSC_SYS_DIM_LEVEL_RELS   A
         ,  BSC_SYS_DIM_LEVELS_B     B
    WHERE   A.Dim_Level_Id  = p_dim_obj_id
    AND     B.Dim_Level_Id  = A.Parent_Dim_Level_Id
    AND     A.Relation_Type = 1;
BEGIN
    SAVEPOINT CreateBSC1toNTabsPMD;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BSC_APPS.Init_Bsc_Apps;
    --DBMS_OUTPUT.PUT_LINE('Entered inside BSC_BIS_DIMENSION_PUB.Create_One_To_N_MTable Function');
    IF (p_dim_obj_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_dim_obj_id IS NOT NULL) THEN
        -- Bug #3236356
        SELECT COUNT(0) INTO l_count
        FROM   BSC_SYS_DIM_LEVELS_B
        WHERE  Dim_Level_Id = p_dim_obj_id;

        IF (l_count = 0) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_INCORRECT_NAME_ENTERED');
            FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_ID'), TRUE);
            FND_MESSAGE.SET_TOKEN('NAME_VALUE', p_dim_obj_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
    --DBMS_OUTPUT.PUT_LINE('2 ');
    SELECT  level_table_name
    INTO    l_bsc_dim_obj_rec.Bsc_Level_View_Name
    FROM    BSC_SYS_DIM_LEVELS_B
    WHERE   DIM_LEVEL_ID = p_dim_obj_id;
    --DBMS_OUTPUT.PUT_LINE('5 ');
    l_bsc_dim_obj_rec.Bsc_Level_Id  := p_dim_obj_id;
    l_master_table  :=  UPPER(l_bsc_dim_obj_rec.Bsc_Level_View_Name);
    --DBMS_OUTPUT.PUT_LINE('l_master_table  <'||l_master_table||'>');
    l_input_table   :=  UPPER('BSC_DI_'||l_bsc_dim_obj_rec.Bsc_Level_Id);
    --DBMS_OUTPUT.PUT_LINE('l_input_table   <'||l_input_table||'>');
    l_view_name     :=  UPPER('BSC_D_'||l_bsc_dim_obj_rec.Bsc_Level_Id||'_VL');
    --DBMS_OUTPUT.PUT_LINE('l_view_name     <'||l_view_name||'>');

    /*************  LOGIC FOR GENERATION OF MASTER TABLE BASED ON RELATIONS 1-N************/
    l_flag          :=  TRUE;
    l_alias         :=  NULL;
    l_temp_table    :=  l_dummy_table;
    WHILE (l_flag) LOOP
        l_sql_stmt  :=  ' SELECT COUNT(*) FROM   USER_OBJECTS '||
                        ' WHERE  OBJECT_NAME =   :1';
        --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
        EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_temp_table;
        IF (l_count = 0) THEN
            l_flag          :=  FALSE;
            l_dummy_table   :=  UPPER(l_temp_table);
        END IF;
        l_alias        := BSC_BIS_DIM_REL_PUB.get_Next_Alias(l_alias);
        l_temp_table   := l_dummy_table||l_alias;
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE('l_dummy_table     <'||l_dummy_table||'>');

    l_col_names         :=  'A.CODE, A.USER_CODE, A.NAME, A.LANGUAGE, A.SOURCE_LANG ';
    l_view_columns      :=  'CODE, USER_CODE, NAME ';
    l_input_col_names   :=  'USER_CODE, NAME ';

    --DBMS_OUTPUT.PUT_LINE('Original Master Columns     <'||l_col_names||'>');
    l_alias            :=   BSC_BIS_DIM_REL_PUB.get_Next_Alias(NULL);
    l_level_pk_cols    :=   NULL;
    l_index_Count      :=   0;
    l_sql_stmt         :=  'CREATE  TABLE  '||l_dummy_table||' '||' TABLESPACE '||
                            BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Table_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause||
                           ' AS SELECT   '||l_col_names||' ';
    FOR cd IN c_parents_Ids LOOP
        --DBMS_OUTPUT.PUT_LINE('11 l_level_pk_col <'||cd.Level_Pk_Col||'>  l_label_table_name  <'||cd.Level_Table_Name||'>' );
        l_level_pk_col      := cd.Level_Pk_Col;
        l_label_table_name  := cd.Level_Table_Name;

        IF(l_level_pk_cols IS NULL) THEN
            l_level_pk_cols := ''''||l_level_pk_col||'''';
        ELSE
            l_level_pk_cols := l_level_pk_cols||', '||''''||l_level_pk_col||'''';
        END IF;
        l_sql_stmt1 := 'SELECT code,user_code  FROM '||l_label_table_name||' WHERE code = (SELECT MAX(a.code) FROM '||l_label_table_name ||' a) AND ROWNUM <2';
        EXECUTE IMMEDIATE l_sql_stmt1 INTO l_max_code,l_max_usr_code ;
        l_alias             := BSC_BIS_DIM_REL_PUB.get_Next_Alias(l_alias);
        --DBMS_OUTPUT.PUT_LINE('l_alias     <'||l_alias||'>');
        l_sql_stmt          := l_sql_stmt||' , ';
        l_sql_stmt          := l_sql_stmt||' '||'NVL('||l_alias||'.CODE,'||l_max_code||') AS '||l_level_pk_col||', '||'NVL('||
                               l_alias||'.USER_CODE,'''||l_max_usr_code||''') AS '||l_level_pk_col||'_USR ';
        l_view_columns      := l_view_columns||', '||l_level_pk_col||', '||l_level_pk_col||'_USR ';
        l_input_col_names   := l_input_col_names||', '||l_level_pk_col||'_USR ';

        l_index_Table(l_index_Count).p_Column_Name  :=  l_level_pk_col;
        l_index_Count :=  l_index_Count + 1;
        --from clause
        IF (l_alias = 'A0') THEN
            l_from_clause   :=  ',  '||l_label_table_name||'  '||l_alias||'  ';
            l_where_clause  :=  ' WHERE ';
        ELSE
            l_from_clause   :=  l_from_clause||',  '||l_label_table_name||'  '||l_alias||'  ';
            l_where_clause  :=  l_where_clause||' AND  ';
        END IF;
        l_where_clause      :=  l_where_clause||' A.CODE  = '||l_alias||'.CODE(+) '||' AND A.LANGUAGE = '||l_alias||'.LANGUAGE(+) ';
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE('l_level_pk_cols     <'||l_level_pk_cols||'>');
    --DBMS_OUTPUT.PUT_LINE('length is '||(lengthb(l_sql_stmt) + lengthb('FROMa') + lengthb(l_from_clause) + lengthb(l_where_clause)));
    l_sql_stmt  :=  l_sql_stmt||' FROM '||l_master_table||'  A  '||l_from_clause||l_where_clause;
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 1,    200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 201,  200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 401,  200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 601,  200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 801,  200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 1001, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 1201, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 1401, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 1601, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 1801, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 2001, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 2201, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 2401, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 2601, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 2801, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 3001, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 3201, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 3401, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 3601, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 3801, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 4001, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 4201, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 4401, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 4601, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 4801, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 5001, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 5201, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 5401, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 5601, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 5801, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 6001, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 6201, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 6401, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 6601, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 6801, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 7001, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 7201, 200));
    --DBMS_OUTPUT.PUT_LINE('---------CREATION OF DUMMY MASTER TABLE---------');

    BSC_APPS.DO_DDL(l_sql_stmt,   ad_ddl.create_table,    l_dummy_table);

    --DBMS_OUTPUT.PUT_LINE('---------DROP MASTER TABLE----------');
    l_sql_stmt  :=  ' SELECT COUNT(*) FROM   USER_OBJECTS '||
                    ' WHERE  OBJECT_NAME =   :1';
    --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
    EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_master_table;

    IF (l_count <> 0) THEN
        l_sql_stmt    := 'DROP TABLE '||l_master_table;
        --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
        BSC_APPS.DO_DDL(l_sql_stmt,    ad_ddl.drop_table,  l_master_table);
    END IF;

    --DBMS_OUTPUT.PUT_LINE('---------CREATION OF MASTER TABLE---------');
    l_sql_stmt    := 'CREATE TABLE '||l_master_table||' '||' TABLESPACE '||
                      BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Table_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause||
                     ' AS SELECT * FROM '||l_dummy_table;


    --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');

    BSC_APPS.DO_DDL(l_sql_stmt,   ad_ddl.create_table,    l_master_table);

    --DBMS_OUTPUT.PUT_LINE('---------DROP DUMMY TABLE---------');
    l_sql_stmt    := 'Drop Table '||l_dummy_table;
    BSC_APPS.DO_DDL(l_sql_stmt,    ad_ddl.drop_table,  l_dummy_table);


    --DBMS_OUTPUT.PUT_LINE('---------CREATION OF INDEXS ON MASTER TABLE---------');
    l_sql_stmt    :=  ' CREATE UNIQUE INDEX '||l_master_table||'_U1 '||
                      ' ON '||l_master_table||' (CODE,LANGUAGE) '||' '||
                      ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Index_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause;
    --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
    BSC_APPS.DO_DDL(l_sql_stmt,   ad_ddl.create_index, l_master_table);

    -- Create a new UNIQUE INDEX for Loader Performance - Bug #3090828
    l_sql_stmt    :=  ' CREATE UNIQUE INDEX '||l_master_table||'_U2 '||
                      ' ON '||l_master_table||' (USER_CODE,LANGUAGE) '||' '||
                      ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Index_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause;
    --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
    BSC_APPS.DO_DDL(l_sql_stmt,   ad_ddl.create_index, l_master_table);

    --DBMS_OUTPUT.PUT_LINE('---------CREATION OF INDEXS ON MASTER TABLE LOADER BUG #3120190---------');
    FOR i IN 0..(l_index_Table.COUNT-1) LOOP
        --DBMS_OUTPUT.PUT_LINE('l_index_Table('||i||').p_Column_Name '||l_index_Table(i).p_Column_Name);
        -- Create a new Non-Unique INDEX for Loader Performance - Bug #3120190
        --Due to DB restrictions, index can't be created if length is > 30 characters.
        --DBMS_OUTPUT.PUT_LINE('index length '||LENGTH(l_master_table||'_N'||(i+1)));
        IF (LENGTH(l_master_table||'_N'||(i+1)) <= 30) THEN
            l_sql_stmt    :=  ' CREATE INDEX '||l_master_table||'_N'||(i+1)||' '||
                              ' ON '||l_master_table||' ('||l_index_Table(i).p_Column_Name||') '||' '||
                              ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Index_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause;
            --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
            BSC_APPS.DO_DDL(l_sql_stmt,   ad_ddl.create_index, l_master_table);
        ELSE
            EXIT;
        END IF;
    END LOOP;

    /*************  LOGIC FOR GENERATION OF MASTER TABLE ENDS HERE BASED ON RELATIONS 1-N************/
    --DBMS_OUTPUT.PUT_LINE('---------GENERATION OF INPUT TABLE---------');
    l_sql_stmt  :=  ' SELECT COUNT(*) FROM   USER_OBJECTS '||
                    ' WHERE  OBJECT_NAME =   :1';
    --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
    EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_input_table;

    IF (l_count <> 0) THEN
        l_sql_stmt    := 'DROP TABLE '||l_input_table;
        --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
        BSC_APPS.DO_DDL(l_sql_stmt,    ad_ddl.drop_table,  l_input_table);
    END IF;
    l_sql_stmt    :=  ' CREATE TABLE   '||l_input_table||' '||' TABLESPACE '||
                        BSC_APPS.Get_Tablespace_Name(BSC_APPS.Input_Table_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause||
                      ' AS SELECT '||l_input_col_names||' FROM   '||l_master_table||' WHERE 1 = 2';

    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 1,    200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 201,  200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 401,  200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 601,  200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 801,  200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 1001, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 1201, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 1401, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 1601, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 1801, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 2001, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 2201, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 2401, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 2601, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 2801, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 3001, 200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 3201, 200));

    BSC_APPS.DO_DDL(l_sql_stmt,   ad_ddl.create_table,    l_input_table);

    l_sql_stmt    :=  ' CREATE UNIQUE INDEX '||l_input_table||'_U1 '||
                      ' ON '||l_input_table||' (USER_CODE) '||' '||
                      ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.Input_Index_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause;
    --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
    BSC_APPS.DO_DDL(l_sql_stmt,   ad_ddl.create_index,    l_input_table);

    --create dynamic view for modified master table
    --DBMS_OUTPUT.PUT_LINE('---------GENERATION OF VIEW BASED ON MASTER TABLE---------');
    l_sql_stmt  :=  ' CREATE OR REPLACE VIEW '||l_view_name||' AS ('  ||
                    ' SELECT '||l_view_columns||
                    ' FROM   '||l_master_table||
                    ' WHERE LANGUAGE = USERENV(''LANG''))';
    --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
    BSC_APPS.DO_DDL(l_sql_stmt,   ad_ddl.create_view, l_view_name);

    /************************************************************************
     Child dimension object table will contain the columns of the parent
     dimension object and will be added or removed.So after the creation of the new
     child dimension object table we need to cascade these changes to
     MLOG table also.
    /************************************************************************/
    IF NOT (BSC_SYNC_MVLOGS.Sync_dim_table_mv_log(l_master_table,l_error_msg)) THEN
       RAISE e_mlog_exception;
    END IF;

    COMMIT;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --DBMS_OUTPUT.PUT_LINE('Exiting from BSC_BIS_DIMENSION_PUB.Create_One_To_N_MTable Function');
    RETURN TRUE;
EXCEPTION
    WHEN e_mlog_exception THEN
        ROLLBACK TO CreateBSC1toNTabsPMD;
        x_msg_data      := NULL;
        x_msg_data      := l_error_msg || ' -> BSC_BIS_DIM_REL_PUB.Create_One_To_N_MTable';
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    RETURN FALSE;
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSC1toNTabsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RETURN FALSE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSC1toNTabsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RETURN FALSE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSC1toNTabsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Create_One_To_N_MTable ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Create_One_To_N_MTable ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RETURN FALSE;
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSC1toNTabsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Create_One_To_N_MTable ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Create_One_To_N_MTable ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RETURN FALSE;
END Create_One_To_N_MTable;

/*******************************************************************************
        FUNCTION TO CREATE MASTER TABLE FOR MANY TO MANY RELATIONS IN BSC
********************************************************************************/
FUNCTION Create_M_To_N_MTable
(       p_dim_obj_id        IN          NUMBER
    ,   p_parent_id         IN          VARCHAR2
    ,   x_return_status     OUT NOCOPY  VARCHAR2
    ,   x_msg_count         OUT NOCOPY  NUMBER
    ,   x_msg_data          OUT NOCOPY  VARCHAR2
)
RETURN BOOLEAN IS
    l_sql_stmt                    VARCHAR2(32000);
    l_flag                        BOOLEAN;
    l_count                       NUMBER          := 0;

    l_c_dim_level_id              BSC_SYS_DIM_LEVELS_B.Dim_Level_Id%TYPE;
    l_c_abbr                      BSC_SYS_DIM_LEVELS_B.Abbreviation%TYPE;
    l_c_level_pk_col              BSC_SYS_DIM_LEVELS_B.Level_PK_Col%TYPE;
    l_c_level_table               BSC_SYS_DIM_LEVELS_B.Level_Table_Name%TYPE;

    l_p_dim_level_id              BSC_SYS_DIM_LEVELS_B.Dim_Level_Id%TYPE;
    l_p_abbr                      BSC_SYS_DIM_LEVELS_B.Abbreviation%TYPE;
    l_p_level_pk_col              BSC_SYS_DIM_LEVELS_B.Level_PK_Col%TYPE;
    l_p_level_table               BSC_SYS_DIM_LEVELS_B.Level_Table_Name%TYPE;

    l_master_table                VARCHAR2(30);
    l_input_table                 VARCHAR2(30);
BEGIN
    SAVEPOINT CreateBSCMtoNTabsPMD;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BSC_APPS.Init_Bsc_Apps;
    IF (p_dim_obj_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --DBMS_OUTPUT.PUT_LINE('Entered inside BSC_BIS_DIMENSION_PUB.Create_M_To_N_MTable Function');
    IF (p_dim_obj_id IS NOT NULL) THEN

        -- Bug #3236356
        SELECT COUNT(0) INTO l_count
        FROM   BSC_SYS_DIM_LEVELS_B
        WHERE  Dim_Level_Id = p_dim_obj_id;

        IF (l_count = 0) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_INCORRECT_NAME_ENTERED');
            FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_ID'), TRUE);
            FND_MESSAGE.SET_TOKEN('NAME_VALUE', p_dim_obj_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
    SELECT  COUNT(*) INTO l_count
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   dim_level_id        = p_dim_obj_id
    AND     parent_dim_level_id = p_parent_id
    AND     relation_type       = 2;
    --DBMS_OUTPUT.PUT_LINE('After');
    IF (l_count = 0) THEN
        --DBMS_OUTPUT.PUT_LINE('Parameters to BSC_BIS_DIM_REL_PUB.Drop_M_To_N_Unused_Tabs');
        --DBMS_OUTPUT.PUT_LINE('p_dim_obj_id  '||p_dim_obj_id);
        --DBMS_OUTPUT.PUT_LINE('p_parent_ids  '||p_parent_id);
        BSC_BIS_DIM_REL_PUB.Drop_M_To_N_Unused_Tabs
        (       p_dim_obj_id      =>   p_dim_obj_id
            ,   p_parent_id       =>   p_parent_id
            ,   x_return_status   =>   x_return_status
            ,   x_msg_count       =>   x_msg_count
            ,   x_msg_data        =>   x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_REL_PUB.Create_M_To_N_MTable Failed: at BSC_DIMENSION_LEVELS_PUB.Drop_M_To_N_Unused_Tabs <'||x_msg_data||'>');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSE
        SELECT dim_level_id
             , abbreviation
             , level_pk_col
             , level_table_name
        INTO   l_c_dim_level_id
             , l_c_abbr
             , l_c_level_pk_col
             , l_c_level_table
        FROM   BSC_SYS_DIM_LEVELS_B WHERE dim_level_id = p_dim_obj_id;

        SELECT dim_level_id
             , abbreviation
             , level_pk_col
             , level_table_name
        INTO   l_p_dim_level_id
             , l_p_abbr
             , l_p_level_pk_col
             , l_p_level_table
        FROM   BSC_SYS_DIM_LEVELS_B WHERE dim_level_id = p_parent_id;

        IF (l_c_abbr <= l_p_abbr) THEN
            l_master_table   :=  'BSC_D_'||l_c_abbr||'_'||l_p_abbr;
        ELSE
            l_master_table   :=  'BSC_D_'||l_p_abbr||'_'||l_c_abbr;
        END IF;
        l_master_table       :=   UPPER(l_master_table);
        IF (l_c_dim_level_id <= l_p_dim_level_id) THEN
            l_input_table    :=  'BSC_DI_'||l_c_dim_level_id||'_'||l_p_dim_level_id;
        ELSE
            l_input_table    :=  'BSC_DI_'||l_p_dim_level_id||'_'||l_c_dim_level_id;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('---------DROP MASTER TABLE IF EXISTS----------');
        --DBMS_OUTPUT.PUT_LINE('l_master_table  <'||l_master_table||'>');

        l_sql_stmt  :=  ' SELECT COUNT(*) FROM   USER_OBJECTS '||
                        ' WHERE  OBJECT_NAME =   :1';
        --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
        EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_master_table;

        IF (l_count = 0) THEN
            --DBMS_OUTPUT.PUT_LINE('---------CREATION OF MASTER TABLE---------');
            l_sql_stmt    := ' CREATE TABLE '||l_master_table||' '||' TABLESPACE '||
                               BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Table_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause||
                             ' AS SELECT '||'  A.CODE AS '||l_c_level_pk_col||
                             ', B.CODE AS '||l_p_level_pk_col||
                             '  FROM  '||l_c_level_table||'  A, '||
                                l_p_level_table||'  B '||
                             '  WHERE A.LANGUAGE =  B.LANGUAGE '||
                             '  AND   A.LANGUAGE = '''||USERENV('LANG')||'''';

            --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||SUBSTR(l_sql_stmt, 1, 200)||'>');
            --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||SUBSTR(l_sql_stmt, 201, 200)||'>');

            BSC_APPS.DO_DDL(l_sql_stmt,   ad_ddl.create_table,    l_master_table);
        END IF;
        --DBMS_OUTPUT.PUT_LINE('l_input_table  <'||l_input_table||'>');
        --DBMS_OUTPUT.PUT_LINE('---------CREATION OF INPUT TABLE---------');
        l_sql_stmt  :=  ' SELECT COUNT(*) FROM   USER_OBJECTS '||
                        ' WHERE  OBJECT_NAME =   :1';
        --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
        EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_input_table;
        IF (l_count = 0) THEN
            l_sql_stmt    := ' CREATE TABLE '||l_input_table||' '||' TABLESPACE '||
                               BSC_APPS.Get_Tablespace_Name(BSC_APPS.Input_Table_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause||
                             ' AS SELECT '||' A.USER_CODE AS '||l_c_level_pk_col||'_USR, B.USER_CODE AS '||
                               l_p_level_pk_col||'_USR '||
                             ' FROM  '||l_c_level_table||'  A, '||
                             ' '||l_p_level_table||'  B '||
                             ' WHERE 1 = 2 ';

            --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 1,    200));
            --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 201,  200));
            --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 401,  200));
            --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 601,  200));
            --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_stmt, 801,  200));
            BSC_APPS.DO_DDL(l_sql_stmt,   ad_ddl.create_table,    l_input_table);
        END IF;
        --insert into BSC_DB_TABLES_RELS & BSC_DB_TABLES
        --DBMS_OUTPUT.PUT_LINE('INSERT INTO BSC_DB_TABLES_RELS');
        SELECT COUNT(*) INTO l_count
        FROM   BSC_DB_TABLES_RELS
        WHERE  Source_Table_Name = l_input_table;
        --DBMS_OUTPUT.PUT_LINE('INSERT INTO BSC_DB_TABLES_RELS '||l_count);
        --DBMS_OUTPUT.PUT_LINE('l_master_table '||l_master_table);
        --DBMS_OUTPUT.PUT_LINE('l_input_table '||l_input_table);
        IF (l_count = 0) THEN
            INSERT INTO BSC_DB_TABLES_RELS
                        (Table_Name,  Source_Table_Name, Relation_Type)
            VALUES      (l_master_table, l_input_table, 0);
        ELSE
            UPDATE BSC_DB_TABLES_RELS
            SET    Table_Name         = l_master_table
            WHERE  Source_Table_Name  = l_input_table;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('INSERT INTO BSC_DB_TABLES');
        SELECT COUNT(*) INTO l_count
        FROM   BSC_DB_TABLES
        WHERE  Table_Name  = l_input_table;
        --DBMS_OUTPUT.PUT_LINE('INSERT INTO BSC_DB_TABLES '||l_count);
        IF (l_count = 0) THEN
            INSERT INTO BSC_DB_TABLES
                        (Table_Name, Table_Type, Periodicity_Id,
                         Source_Data_Type, Source_File_Name)
            VALUES      (l_input_table, 2, 0, 0, NULL);
        END IF;
    END IF;

    COMMIT;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --DBMS_OUTPUT.PUT_LINE('Exiting from BSC_BIS_DIMENSION_PUB.Create_M_To_N_MTable Function');
    RETURN TRUE;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        ROLLBACK TO CreateBSCMtoNTabsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RETURN FALSE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        ROLLBACK TO CreateBSCMtoNTabsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN FALSE;
    WHEN NO_DATA_FOUND THEN
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        ROLLBACK TO CreateBSCMtoNTabsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Create_M_To_N_MTable ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Create_M_To_N_MTable ';
        END IF;
        RETURN FALSE;
    WHEN OTHERS THEN
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        ROLLBACK TO CreateBSCMtoNTabsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Create_M_To_N_MTable ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Create_M_To_N_MTable ';
        END IF;
        RETURN FALSE;
END Create_M_To_N_MTable;
/*******************************************************************************
   DROP MASTER TABLES THAT ARE NOT USED IN THE CONTEXT FOR M x N RELATIONSHIPS
********************************************************************************/
PROCEDURE Drop_M_To_N_Unused_Tabs
(       p_dim_obj_id        IN          NUMBER
    ,   p_parent_id         IN          VARCHAR2
    ,   x_return_status     OUT NOCOPY  VARCHAR2
    ,   x_msg_count         OUT NOCOPY  NUMBER
    ,   x_msg_data          OUT NOCOPY  VARCHAR2
) IS
    l_sql_stmt              VARCHAR2(32000);
    l_count                 NUMBER;

    l_master_table          VARCHAR2(50);
    l_input_table           VARCHAR2(50);

    l_c_abbre               BSC_SYS_DIM_LEVELS_B.Abbreviation%TYPE;
    l_p_abbre               BSC_SYS_DIM_LEVELS_B.Abbreviation%TYPE;
BEGIN
    SAVEPOINT DropBSCMtoNTabsPMD;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --DBMS_OUTPUT.PUT_LINE('Entered inside BSC_BIS_DIMENSION_PUB.Drop_M_To_N_Unused_Tabs Procedure');
    IF (p_dim_obj_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT  abbreviation INTO l_p_abbre
    FROM    BSC_SYS_DIM_LEVELS_B
    WHERE   dim_level_id = p_dim_obj_id;

    SELECT  abbreviation INTO l_c_abbre
    FROM    BSC_SYS_DIM_LEVELS_B
    WHERE   dim_level_id = p_parent_id;
    --drop tables, needs changes, will be done in IInd release
    IF (p_dim_obj_id <= p_parent_id) THEN
        l_input_table  := 'BSC_DI_'||p_dim_obj_id||'_'||p_parent_id;
    ELSE
        l_input_table  := 'BSC_DI_'||p_parent_id||'_'||p_dim_obj_id;
    END IF;

    IF (l_c_abbre <= l_p_abbre) THEN
        l_master_table  := UPPER('BSC_D_'||l_c_abbre||'_'||l_p_abbre);
    ELSE
        l_master_table  := UPPER('BSC_D_'||l_p_abbre||'_'||l_c_abbre);
    END IF;

    l_sql_stmt  :=  ' SELECT COUNT(*) FROM   USER_OBJECTS '||
                    ' WHERE  OBJECT_NAME =   :1';
    --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
    EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_master_table;
    IF (l_count <> 0) THEN
        l_sql_stmt    := 'DROP TABLE '||l_master_table;
        --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
        BSC_APPS.DO_DDL(l_sql_stmt,    ad_ddl.drop_table,  l_master_table);
    END IF;
    l_sql_stmt  :=  ' SELECT COUNT(*) FROM   USER_OBJECTS '||
                    ' WHERE  OBJECT_NAME =   :1';
    --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
    EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_input_table;
    IF (l_count <> 0) THEN
        l_sql_stmt    := 'DROP TABLE '||l_input_table;
        --DBMS_OUTPUT.PUT_LINE('l_sql_stmt  <'||l_sql_stmt||'>');
        BSC_APPS.DO_DDL(l_sql_stmt,    ad_ddl.drop_table,  l_input_table);
    END IF;
    --DBMS_OUTPUT.PUT_LINE('DELETE TABLES BSC_DB_TABLES '||l_input_table);
    DELETE FROM BSC_DB_TABLES
    WHERE  Table_Name = l_input_table;

    DELETE FROM BSC_DB_TABLES_RELS
    WHERE  Source_Table_Name = l_input_table;

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --DBMS_OUTPUT.PUT_LINE('Exiting from BSC_BIS_DIMENSION_PUB.Drop_M_To_N_Unused_Tabs Procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DropBSCMtoNTabsPMD;
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
        ROLLBACK TO DropBSCMtoNTabsPMD;
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
        ROLLBACK TO DropBSCMtoNTabsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Drop_M_To_N_Unused_Tabs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Drop_M_To_N_Unused_Tabs ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO DropBSCMtoNTabsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_REL_PUB.Drop_M_To_N_Unused_Tabs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_REL_PUB.Drop_M_To_N_Unused_Tabs ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Drop_M_To_N_Unused_Tabs;

/********************************************************************************
    WARNING :
    This function will return false if any changes to dim_object relations
    will result in structural changes. This is designed to fulfil the UI screen
    need and not a generic function so it should not be called internally from any
    other APIs without proper impact analysis.
********************************************************************************/
FUNCTION is_KPI_Flag_For_Dim_Obj_Rels
(       p_dim_obj_id            IN          NUMBER
    ,   p_parent_ids            IN          VARCHAR2
    ,   p_parent_rel_type       IN          VARCHAR2
    ,   p_child_ids             IN          VARCHAR2
    ,   p_child_rel_type        IN          VARCHAR2
) RETURN VARCHAR2 IS
    l_Msg_Data              VARCHAR2(32000);
    l_msg_count             NUMBER;

    l_Source                BSC_SYS_DIM_LEVELS_B.Source%TYPE;

    l_par_original_ids      VARCHAR2(32000);
    l_par_original_types    VARCHAR2(32000);
    l_par_original_id       VARCHAR2(32000);
    l_par_original_type     VARCHAR2(32000);

    l_chd_original_ids      VARCHAR2(32000);
    l_chd_original_types    VARCHAR2(32000);
    l_chd_original_id       VARCHAR2(32000);
    l_chd_original_type     VARCHAR2(32000);

    l_child_ids             VARCHAR2(32000);
    l_child_rel_types       VARCHAR2(32000);
    l_child_id              VARCHAR2(100);
    l_child_rel_type        VARCHAR2(100);
    l_final_chd_ids         VARCHAR2(32000);

    l_parent_ids            VARCHAR2(32000);
    l_parent_rel_types      VARCHAR2(32000);
    l_parent_id             VARCHAR2(100);
    l_parent_rel_type       VARCHAR2(100);

    l_temp_ids              VARCHAR2(32000);
    l_temp_types            VARCHAR2(32000);

    l_Strut_Flag            BOOLEAN := FALSE;
    l_kpi_names             VARCHAR2(32000);
    l_par_flag              BOOLEAN := FALSE;

    CURSOR  c_Source IS
    SELECT  Source
    FROM    BSC_SYS_DIM_LEVELS_B
    WHERE   dim_level_id    =   p_dim_obj_id;

    CURSOR  c_Par_Dim_Ids IS
    SELECT  Parent_Dim_Level_Id
          , Relation_Type
          , Dim_Level_Id
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   dim_level_id    =   p_dim_obj_id;

    CURSOR  c_Child_Ids IS
    SELECT  Dim_Level_Id
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   parent_dim_level_id =  p_dim_obj_id;


    CURSOR  c_kpi_dim_set IS
    SELECT  DISTINCT C.Name||'['||C.Indicator||']' Name, C.short_name
    FROM    BSC_KPI_DIM_LEVELS_B    A
          , BSC_SYS_DIM_LEVELS_B    D
          , BSC_KPIS_VL             C
    WHERE   A.Level_Table_Name      =  D.Level_Table_Name
    AND     D.Dim_Level_Id          =  p_dim_obj_id
    AND     C.share_flag           <>  2
    AND     C.Indicator             =  A.Indicator;

    CURSOR  c_Kpi_Dim_Set1 IS
    SELECT DISTINCT C.Name||'['||C.Indicator||']' Name, C.short_name
    FROM   BSC_KPI_DIM_LEVELS_VL A,
           BSC_SYS_DIM_LEVELS_VL B,
           BSC_KPIS_VL           C
    WHERE  A.LEVEL_TABLE_NAME=B.LEVEL_TABLE_NAME
    AND    C.INDICATOR = A.INDICATOR
    AND    C.SHARE_FLAG <> 2
    AND    INSTR(', '||l_final_chd_ids||',', ', '||b.dim_level_id||',') > 0;

BEGIN
    --DBMS_OUTPUT.PUT_LINE('Entered inside BSC_BIS_DIM_REL_PUB.is_KPI_Flag_For_Dim_Obj_Rels Function');

    FND_MSG_PUB.Initialize;
    IF (NOT BSC_UTILITY.isBscInProductionMode()) THEN
        RETURN NULL;
    END IF;

    OPEN c_Source;
        FETCH   c_Source INTO l_Source;
    CLOSE c_Source;
    IF (l_Source IS NULL) THEN
        RETURN NULL;
    END IF;

    --check if any childs are of type Many to Many
    l_child_ids         :=  TRIM(p_child_ids);
    l_child_rel_types   :=  TRIM(p_child_rel_type);
    IF (l_child_ids IS NOT NULL) THEN
        WHILE (is_more( x_remain_id         =>  l_child_ids
                      , x_remain_rel_type   =>  l_child_rel_types
                      , x_id                =>  l_child_id
                      , x_rel_type          =>  l_child_rel_type
        )) LOOP
            l_child_rel_type  :=  NVL(l_child_rel_type, 1);
            IF (l_child_rel_type = 2) THEN
            --add children in parents
                IF (l_parent_ids IS NULL) THEN
                    l_parent_ids        :=  l_child_id||', ';
                    l_parent_rel_types  :=  l_child_rel_type||', ';
                ELSE
                    l_parent_ids        :=  l_parent_ids||l_child_id||', ';
                    l_parent_rel_types  :=  l_parent_rel_types||l_child_rel_type||', ';
                END IF;
            END IF;

           --We need the children from  M N relationship here
           --prepare final children list
                IF (l_final_chd_ids IS NULL) THEN
                    l_final_chd_ids :=  l_child_id;
                ELSE
                    l_final_chd_ids :=  l_final_chd_ids||', '||l_child_id;
                END IF;
            --END IF;
        END LOOP;
    END IF;
    FOR cd IN c_Child_Ids LOOP
         --contains all the initial children
        l_Strut_Flag        :=  TRUE;
        IF (l_chd_original_ids IS NULL) OR (l_chd_original_types IS NULL) THEN
            l_chd_original_ids      :=  cd.Dim_Level_Id;
            l_chd_original_types    :=  1;
        ELSE
            l_chd_original_ids      :=  l_chd_original_ids||','||cd.Dim_Level_Id;
            l_chd_original_types    :=  l_chd_original_types||','||1;
        END IF;
        l_child_ids         :=  TRIM(p_child_ids);
        l_child_rel_types   :=  TRIM(p_child_rel_type);
        IF (l_child_ids IS NOT NULL) THEN
            WHILE (is_more( x_remain_id         =>  l_child_ids
                          , x_remain_rel_type   =>  l_child_rel_types
                          , x_id                =>  l_child_id
                          , x_rel_type          =>  l_child_rel_type
            )) LOOP
                l_child_rel_type  :=  NVL(l_child_rel_type, 1);
                --DBMS_OUTPUT.PUT_LINE('l_child_id        <'||l_child_id||'>');
                --DBMS_OUTPUT.PUT_LINE('l_child_rel_type  <'||l_child_rel_type||'>');
                IF ((l_child_rel_type <> 2) AND (cd.Dim_Level_Id = l_child_id)) THEN
                    l_Strut_Flag :=  FALSE;
                END IF;
            END LOOP;
        END IF;
        IF (l_Strut_Flag) THEN
            --DBMS_OUTPUT.PUT_LINE('cd.Dim_Level_Id  <'||cd.Dim_Level_Id||'>');
            --DBMS_OUTPUT.PUT_LINE('cd.Relation_Type <1>');
            EXIT;
        END IF;
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE('l_chd_original_ids    <'||l_chd_original_ids||'>');
    --DBMS_OUTPUT.PUT_LINE('l_chd_original_types  <'||l_chd_original_types||'>');
    --DBMS_OUTPUT.PUT_LINE('p_child_ids           <'||p_child_ids||'>');
    --DBMS_OUTPUT.PUT_LINE('l_final_chd_ids       <'||l_final_chd_ids||'>');
    --DBMS_OUTPUT.PUT_LINE('p_child_rel_type      <'||p_child_rel_type||'>');
    --DBMS_OUTPUT.PUT_LINE('1111p_parent_ids <'||l_parent_ids||'>');
    IF (l_parent_ids IS NOT NULL) THEN

    --l_parent_ids are only parents coming from M by N relationship

        l_child_ids        :=  l_parent_ids;
        l_child_rel_types  :=  l_parent_rel_types;
    ELSE
        l_child_ids         :=  NULL;
        l_child_rel_types   :=  NULL;
    END IF;
    --IF (NOT l_Strut_Flag) THEN
        FOR cd IN c_par_dim_ids LOOP
            --contains all the initial parents
            l_Strut_Flag        :=  TRUE;
            --DBMS_OUTPUT.PUT_LINE('cd.Parent_Dim_Level_Id  <'||cd.Parent_Dim_Level_Id||'>  cd.Relation_Type  <'||cd.Relation_Type||'>');
            IF ((l_par_original_ids IS NULL) OR (l_par_original_types IS NULL)) THEN
                l_par_original_ids      :=  cd.Parent_Dim_Level_Id;
                l_par_original_types    :=  cd.Relation_Type;
            ELSE
                l_par_original_ids      :=  l_par_original_ids||', '||cd.Parent_Dim_Level_Id;
                l_par_original_types    :=  l_par_original_types||', '||cd.Relation_Type;
            END IF;
            --appending children coming from MN Relationsip to l_parent_ids
            l_parent_ids        :=  NVL(l_child_ids, '')||TRIM(p_parent_ids);
            l_parent_rel_types  :=  NVL(l_child_rel_types, '')||TRIM(p_parent_rel_type);
            IF (l_parent_ids IS NOT NULL) THEN
            --final parents iterator(Inside)
                WHILE (is_more( x_remain_id         =>  l_parent_ids
                              , x_remain_rel_type   =>  l_parent_rel_types
                              , x_id                =>  l_parent_id
                              , x_rel_type          =>  l_parent_rel_type
                )) LOOP
                    l_parent_rel_type  :=  NVL(l_parent_rel_type, 1);
                    --DBMS_OUTPUT.PUT_LINE('l_parent_id             <'||l_parent_id||'>');
                    --DBMS_OUTPUT.PUT_LINE('l_parent_rel_type       <'||l_parent_rel_type||'>');
                    IF ((cd.Parent_Dim_Level_Id = l_parent_id) AND (cd.Relation_Type = l_parent_rel_type)) THEN
                        l_Strut_Flag :=  FALSE;
                        EXIT;
                    END IF;
                END LOOP;
            END IF;
            IF (l_Strut_Flag) THEN
                --DBMS_OUTPUT.PUT_LINE('cd.Parent_Dim_Level_Id  <'||cd.Parent_Dim_Level_Id||'>');
                --DBMS_OUTPUT.PUT_LINE('cd.Relation_Type        <'||cd.Relation_Type||'>');
                l_par_flag := TRUE; --Will be set to True  if Structural Chnges are needed do to Change in Parent
                EXIT;
            END IF;
        END LOOP;
    --END IF;
    --DBMS_OUTPUT.PUT_LINE('l_par_original_ids    <'||l_par_original_ids||'>');
    --DBMS_OUTPUT.PUT_LINE('l_par_original_types  <'||l_par_original_types||'>');
    --DBMS_OUTPUT.PUT_LINE('p_parent_ids          <'||NVL(l_child_ids, '')||p_parent_ids||'>');
    --DBMS_OUTPUT.PUT_LINE('p_parent_rel_type     <'||NVL(l_child_rel_types, '')||p_parent_rel_type||'>');
    --IF (NOT l_Strut_Flag) THEN
        IF ((p_parent_ids IS NOT NULL) OR (l_child_ids IS NOT NULL)) THEN
            l_parent_ids         :=  NVL(l_child_ids, '')||TRIM(p_parent_ids);
            l_parent_rel_types   :=  NVL(l_child_rel_types, '')||TRIM(p_parent_rel_type);

            --final parents iterator(Outside)
            WHILE (is_more( x_remain_id         =>  l_parent_ids
                          , x_remain_rel_type   =>  l_parent_rel_types
                          , x_id                =>  l_parent_id
                          , x_rel_type          =>  l_parent_rel_type
            )) LOOP
                l_Strut_Flag         :=  TRUE;
                l_temp_ids           :=  l_par_original_ids;
                l_temp_types         :=  l_par_original_types;
                WHILE (is_more( x_remain_id         =>  l_temp_ids
                              , x_remain_rel_type   =>  l_temp_types
                              , x_id                =>  l_par_original_id
                              , x_rel_type          =>  l_par_original_type
                )) LOOP
                    IF ((l_par_original_id = l_parent_id) AND (l_par_original_type = l_parent_rel_type)) THEN
                        l_Strut_Flag :=  FALSE;
                        EXIT;
                    END IF;
                END LOOP;
                IF (l_Strut_Flag) THEN
                    --DBMS_OUTPUT.PUT_LINE('l_parent_id        <'||l_parent_id||'>');
                    --DBMS_OUTPUT.PUT_LINE('l_parent_rel_type  <'||l_parent_rel_type||'>');
                    l_par_flag := TRUE;
                    EXIT;
                END IF;
            END LOOP;
        END IF;
    --END IF;
    --IF (NOT l_Strut_Flag) THEN
    --DBMS_OUTPUT.PUT_LINE('<< l_final_chd_ids1  >>'||l_final_chd_ids);
        IF (l_final_chd_ids IS NOT NULL) THEN
            l_child_ids         :=  TRIM(l_final_chd_ids);
            l_child_rel_types   :=  NULL;
            --final_child iterator
            WHILE (is_more( x_remain_id         =>  l_child_ids
                          , x_remain_rel_type   =>  l_child_rel_types
                          , x_id                =>  l_child_id
                          , x_rel_type          =>  l_child_rel_type
            )) LOOP
                l_Strut_Flag        :=  TRUE;
                l_temp_ids          :=  l_chd_original_ids;
                l_temp_types        :=  l_chd_original_types;
                ---original child iterator
                WHILE (is_more( x_remain_id         =>  l_temp_ids
                              , x_remain_rel_type   =>  l_temp_types
                              , x_id                =>  l_chd_original_id
                              , x_rel_type          =>  l_chd_original_type
                )) LOOP
                    -- Added l_final_chd_types comparison for Bug#5057436
                    IF ((l_chd_original_id = l_child_id) AND (l_chd_original_type = l_child_rel_type)) THEN
                        l_Strut_Flag :=  FALSE;
                        EXIT;
                    END IF;
                END LOOP;
                IF (l_Strut_Flag) THEN
                    --DBMS_OUTPUT.PUT_LINE('l_child_id            <'||l_child_id||'>');
                    --DBMS_OUTPUT.PUT_LINE('l_child_rel_type      <'||l_child_rel_type||'>');
                    EXIT;
                END IF;
            END LOOP;
        END IF;
    --END IF;

    --Check to see if any chld DOs have beed removed. If yes, they will be added in l_final_chd_ids for the warning
    l_temp_ids  :=  l_chd_original_ids;
    l_temp_types        :=  l_chd_original_types;

    --DBMS_OUTPUT.PUT_LINE('<< l_final_chd_ids  >>'||l_final_chd_ids);
    --DBMS_OUTPUT.PUT_LINE('<< l_chd_original_ids  >>'||l_chd_original_ids);

    WHILE (is_more( x_remain_id         =>  l_temp_ids
                  , x_remain_rel_type   =>  l_temp_types
                  , x_id                =>  l_chd_original_id
                  , x_rel_type          =>  l_chd_original_type
    )) LOOP

        IF (INSTR(', '||l_final_chd_ids||',', ', '||l_chd_original_id||',') = 0)  THEN
            IF (l_final_chd_ids IS NULL) THEN
                l_final_chd_ids := l_chd_original_id;
            ELSE
                l_final_chd_ids := l_final_chd_ids ||', '||l_chd_original_id;
            END IF;
        END IF;
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE('<< l_final_chd_ids  >>'||l_final_chd_ids);

    IF (l_strut_flag) THEN
        IF (l_par_flag) THEN
            FOR cd IN c_kpi_dim_set LOOP
              IF(NOT (l_source = 'PMF' AND cd.short_name is NULL)) THEN
                IF (l_kpi_names IS NULL) THEN
                    l_kpi_names :=  cd.Name;
                ELSIF (INSTR(', '||l_kpi_names||', ', ', '||cd.Name||', ') = 0 ) THEN
                        l_kpi_names :=  l_kpi_names||', '||cd.Name;
                END IF;
              END IF;
            END LOOP;
        END IF;



        IF (l_final_chd_ids IS NOT NULL) THEN
            FOR cd IN c_kpi_dim_set1 LOOP
              IF(NOT (l_source = 'PMF' AND cd.short_name is NULL)) THEN
                IF (l_kpi_names IS NULL) THEN
                    l_kpi_names :=  cd.Name;
                ELSIF (INSTR(', '||l_kpi_names||', ', ', '||cd.Name||', ') = 0 ) THEN
                    l_kpi_names :=  l_kpi_names||', '||cd.Name;
                END IF;
              END IF;
            END LOOP;
        END IF;
    END IF;


    --DBMS_OUTPUT.PUT_LINE('<< l_kpi_names  >>');
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_kpi_names, 1,    200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_kpi_names, 201,  200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_kpi_names, 401,  200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_kpi_names, 601,  200));
    --DBMS_OUTPUT.PUT_LINE(SUBSTR(l_kpi_names, 801,  200));
    IF ((l_strut_flag) AND (l_kpi_names IS NOT NULL)) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_PMD_KPI_STRUCT_INVALID');
        FND_MESSAGE.SET_TOKEN('INDICATORS', l_kpi_names);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --DBMS_OUTPUT.PUT_LINE('Exiting from BSC_BIS_DIM_REL_PUB.is_KPI_Flag_For_Dim_Obj_Rels Function');
    RETURN NULL;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (l_Msg_Data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  l_Msg_Data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR BSC_BIS_DIM_REL_PUB.is_KPI_Flag_For_Dim_Obj_Rels');
        RETURN l_Msg_Data;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (l_Msg_Data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  l_Msg_Data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR BSC_BIS_DIM_REL_PUB.is_KPI_Flag_For_Dim_Obj_Rels');
        RETURN l_Msg_Data;
    WHEN OTHERS THEN
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||SQLERRM);
        RETURN NULL;
END is_KPI_Flag_For_Dim_Obj_Rels;
/********************************************************************************/
FUNCTION check_config_impact_rels
  (
          p_dim_obj_id            IN          NUMBER
      ,   p_parent_ids            IN          VARCHAR2
      ,   p_parent_rel_type       IN          VARCHAR2
      ,   p_parent_rel_column     IN          VARCHAR2
      ,   p_parent_data_type      IN          VARCHAR2
      ,   p_parent_data_source    IN          VARCHAR2
      ,   p_child_ids             IN          VARCHAR2
      ,   p_child_rel_type        IN          VARCHAR2
      ,   p_child_rel_column      IN          VARCHAR2
      ,   p_child_data_type       IN          VARCHAR2
      ,   p_child_data_source     IN          VARCHAR2
      ,   p_time_stamp            IN          VARCHAR2   := NULL   -- Granular Locking
  ) RETURN VARCHAR2 IS
      l_kpi_id                    NUMBER;
      l_dimset_id                 NUMBER;
      l_parent_ids                VARCHAR2(32000);
      l_child_ids                 VARCHAR2(32000);
      l_no_rels                   NUMBER;
      l_msg_count                 NUMBER;
      l_Msg_Data                  VARCHAR2(32000);
      x_return_status             VARCHAR2(32000);
      x_msg_count                 NUMBER;
      x_msg_data                  VARCHAR2(32000);
      TYPE index_by_table_kpi IS Record
      (
              kpi_id     NUMBER
          ,   dim_set_id NUMBER
      );

      TYPE index_by_table_type_kpi IS TABLE OF index_by_table_kpi INDEX BY BINARY_INTEGER;
      TYPE index_by_table IS Record
      (       p_no_dim_object       VARCHAR2(32000)
      );
      TYPE index_by_table_type IS TABLE OF index_by_table INDEX BY BINARY_INTEGER;
      dim_objs_in_dimset   index_by_table_type_kpi;
      dimobjs_array index_by_table_type;

      CURSOR cr_kpi_dim_set IS
      SELECT INDICATOR,DIM_SET_ID
      FROM   BSC_KPI_DIM_LEVEL_PROPERTIES
      WHERE  DIM_LEVEL_ID = p_dim_obj_id;

      i NUMBER;

  BEGIN
      SAVEPOINT sp_before_rel_config;
      IF(p_parent_ids IS NOT NULL OR p_child_ids IS NOT NULL) THEN
          --DBMS_OUTPUT.PUT_LINE('BEFORE ASSIGN DIM OBJE RELS  LOOP' );
        Assign_New_Dim_Obj_Rels
        (       p_dim_obj_id            => p_dim_obj_id
            ,   p_parent_ids            => p_parent_ids
            ,   p_parent_rel_type       => p_parent_rel_type
            ,   p_parent_rel_column     => p_parent_rel_column
            ,   p_parent_data_type      => p_parent_data_type
            ,   p_parent_data_source    => p_parent_data_source
            ,   p_child_ids             => p_child_ids
            ,   p_child_rel_type        => p_child_rel_type
            ,   p_child_rel_column      => p_child_rel_column
            ,   p_child_data_type       => p_child_data_type
            ,   p_child_data_source     => p_child_data_source
            ,   p_time_stamp            => p_time_stamp
            ,   p_is_not_config         => FALSE
            ,   x_return_status         => x_return_status
            ,   x_msg_count             => x_msg_count
            ,   x_msg_data              => x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('X RETURN STATUS IS  '|| x_return_status );
        IF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          OPEN cr_kpi_dim_set;
          -- bug#3405498 meastmon 28-jan-2004: The following is not supported in 8i
          --FETCH cr_kpi_dim_set BULK COLLECT INTO dim_objs_in_dimset;
          dim_objs_in_dimset.delete;
          i := 0;
          LOOP
              FETCH cr_kpi_dim_set INTO l_kpi_id, l_dimset_id;
              EXIT WHEN cr_kpi_dim_set%NOTFOUND;
              i := i+1;
              dim_objs_in_dimset(i).kpi_id := l_kpi_id;
              dim_objs_in_dimset(i).dim_set_id := l_dimset_id;
          END LOOP;
          CLOSE cr_kpi_dim_set;

          --DBMS_OUTPUT.PUT_LINE('BEFORE MAIN LOOP' );
          FOR index_loop IN 1..(dim_objs_in_dimset.COUNT) LOOP
            l_kpi_id     := dim_objs_in_dimset(index_loop).kpi_id;
            l_dimset_id  := dim_objs_in_dimset(index_loop).dim_set_id;

            SELECT COUNT(INDICATOR) INTO l_no_rels
            FROM   BSC_KPI_DIM_LEVELS_B
            WHERE  INDICATOR = l_kpi_id
            AND    DIM_SET_ID = l_dimset_id
            AND    PARENT_LEVEL_INDEX >= 0;
            --DBMS_OUTPUT.PUT_LINE('kpi_id :- '||l_kpi_id||'dimset_id :- '||l_dimset_id||'No of rels are :-  '||l_no_rels );
            IF(l_no_rels > BSC_BIS_KPI_MEAS_PUB.CONFIG_LIMIT_RELS) THEN
              FND_MESSAGE.SET_NAME('BSC','BSC_PMD_IMPACT_KPI_SUMMARY_LVL');
              FND_MESSAGE.SET_TOKEN('CONTINUE', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'YES'), TRUE);
              FND_MESSAGE.SET_TOKEN('CANCEL', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'NO'), TRUE);
              FND_MSG_PUB.ADD;
              ROLLBACK TO sp_before_rel_config;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END LOOP;
        END IF;
      END IF;
      ROLLBACK TO sp_before_rel_config;
      IF(cr_kpi_dim_set%ISOPEN)        THEN
        CLOSE cr_kpi_dim_set;
      END IF ;
      RETURN NULL;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_Msg_Data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (       p_encoded   =>  FND_API.G_FALSE
            ,   p_count     =>  l_msg_count
            ,   p_data      =>  l_Msg_Data
        );
      END IF;
      IF(cr_kpi_dim_set%ISOPEN)        THEN
        CLOSE cr_kpi_dim_set;
      END IF ;
      RETURN  l_Msg_Data;
    WHEN OTHERS THEN
      ROLLBACK TO sp_before_rel_config;
      IF(cr_kpi_dim_set%ISOPEN)        THEN
        CLOSE cr_kpi_dim_set;
      END IF ;
      --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||SQLERRM);
      RETURN NULL;
  END check_config_impact_rels;
--**************************************************************************
FUNCTION check_invalid_pmf_view_inrel
  (
          p_dim_obj_id            IN          NUMBER
      ,   p_parent_ids            IN          VARCHAR2
      ,   p_parent_rel_type       IN          VARCHAR2
      ,   p_parent_rel_column     IN          VARCHAR2
      ,   p_parent_data_type      IN          VARCHAR2
      ,   p_parent_data_source    IN          VARCHAR2
      ,   p_child_ids             IN          VARCHAR2
      ,   p_child_rel_type        IN          VARCHAR2
      ,   p_child_rel_column      IN          VARCHAR2
      ,   p_child_data_type       IN          VARCHAR2
      ,   p_child_data_source     IN          VARCHAR2
      ,   p_time_stamp            IN          VARCHAR2   := NULL   -- Granular Locking
  ) RETURN VARCHAR2 IS
      l_msg_count                 NUMBER;
      l_Msg_Data                  VARCHAR2(32000);
      x_return_status             VARCHAR2(32000);
      x_msg_count                 NUMBER;
      x_msg_data                  VARCHAR2(32000);
      l_short_name                VARCHAR2(32000);

      CURSOR C_SHORT_NAMES_IDS IS
      SELECT short_name
      FROM bsc_sys_dim_levels_vl
      WHERE INSTR(','||p_child_ids ||',',','||dim_level_id||',') > 0;



  BEGIN
      SAVEPOINT sp_before_rel_view;
      --DBMS_OUTPUT.PUT_LINE('In check_invalid_pmf_view_inrel:  The child dimensions are :-' ||p_child_ids);
      --DBMS_OUTPUT.PUT_LINE('In check_invalid_pmf_view_inrel:  The parent dimensions are :-'|| p_parent_ids);
      IF(p_parent_ids IS NOT NULL OR p_child_ids IS NOT NULL) THEN
          --DBMS_OUTPUT.PUT_LINE('BEFORE ASSIGN DIM OBJE RELS  LOOP' );
          Assign_New_Dim_Obj_Rels
          (       p_dim_obj_id            => p_dim_obj_id
              ,   p_parent_ids            => p_parent_ids
              ,   p_parent_rel_type       => p_parent_rel_type
              ,   p_parent_rel_column     => p_parent_rel_column
              ,   p_parent_data_type      => p_parent_data_type
              ,   p_parent_data_source    => p_parent_data_source
              ,   p_child_ids             => p_child_ids
              ,   p_child_rel_type        => p_child_rel_type
              ,   p_child_rel_column      => p_child_rel_column
              ,   p_child_data_type       => p_child_data_type
              ,   p_child_data_source     => p_child_data_source
              ,   p_time_stamp            => p_time_stamp
              ,   p_is_not_config         => FALSE
              ,   x_return_status         => x_return_status
              ,   x_msg_count             => x_msg_count
              ,   x_msg_data              => x_msg_data
          );
        --DBMS_OUTPUT.PUT_LINE('X RETURN STATUS IS  '|| x_return_status );
          IF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              --DBMS_OUTPUT.PUT_LINE('assign new dim rel is success');
           FOR CD IN C_SHORT_NAMES_IDS LOOP
               --DBMS_OUTPUT.PUT_LINE('Calling validate pmf view for :-'|| CD.SHORT_NAME);
               BSC_BIS_DIM_OBJ_PUB.Validate_PMF_Views
               (
                        p_Dim_Obj_Short_Name            => CD.SHORT_NAME
                      , p_Dim_Obj_View_Name             => NULL
                      , x_Return_Status                 => x_return_status
                      , x_Msg_Count                     => x_msg_count
                      , x_Msg_Data                      => x_msg_data
                );
                IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE FND_API.G_EXC_ERROR;
                    --DBMS_OUTPUT.PUT_LINE('faliled the check for  :-'|| CD.SHORT_NAME);
                END IF;

           END LOOP;
           --DBMS_OUTPUT.PUT_LINE('For present dimension object :-  '|| p_dim_obj_id);

           SELECT SHORT_NAME
           INTO   l_short_name
           FROM   BSC_SYS_DIM_LEVELS_VL
           WHERE  DIM_LEVEL_ID = p_dim_obj_id;
           --DBMS_OUTPUT.PUT_LINE('For present dimension object shortname :-  '|| l_short_name);
           BSC_BIS_DIM_OBJ_PUB.Validate_PMF_Views
           (
                               p_Dim_Obj_Short_Name            => l_short_name
                             , p_Dim_Obj_View_Name             => NULL
                             , x_Return_Status                 => x_return_status
                             , x_Msg_Count                     => x_msg_count
                             , x_Msg_Data                      => x_msg_data
           );
           IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_ERROR;
                --DBMS_OUTPUT.PUT_LINE('ooops faliled the check for present dim :-'|| l_short_name);
           END IF;
          END IF;
          ROLLBACK TO sp_before_rel_view;
          --DBMS_OUTPUT.PUT_LINE('validte view is succeed');
      END IF;
      RETURN  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (       p_encoded   =>  FND_API.G_FALSE
            ,   p_count     =>  x_msg_count
            ,   p_data      =>  x_msg_data
        );
      END IF;
      IF(C_SHORT_NAMES_IDS%ISOPEN) THEN
       CLOSE C_SHORT_NAMES_IDS;
      END IF;
      ROLLBACK TO sp_before_rel_view;
      RETURN  x_msg_data;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (       p_encoded   =>  FND_API.G_FALSE
                ,   p_count     =>  x_msg_count
                ,   p_data      =>  x_msg_data
            );
        END IF;
        IF(C_SHORT_NAMES_IDS%ISOPEN) THEN
            CLOSE C_SHORT_NAMES_IDS;
        END IF;
        ROLLBACK TO sp_before_rel_view;
        RETURN  x_msg_data;

    WHEN OTHERS THEN
      ROLLBACK TO sp_before_rel_view;
      --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||SQLERRM);
      RETURN  x_msg_data;
  END check_invalid_pmf_view_inrel;

--***************************************************************

END BSC_BIS_DIM_REL_PUB;

/
