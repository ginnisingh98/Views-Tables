--------------------------------------------------------
--  DDL for Package Body BSC_COMMON_DIM_LEVELS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_COMMON_DIM_LEVELS_PUB" AS
/* $Header: BSCPCDLB.pls 120.3 2007/02/20 17:04:07 psomesul ship $ */

-------------------------------------------------------------------------------------------------------------------
--   Check_Common_Dim_Levels
--            Return x_return_status = 'DISABLE'  if it disables one or more common
--                                                Dimension in the Checking.
-------------------------------------------------------------------------------------------------------------------
PROCEDURE  Check_Common_Dim_Levels(
  p_commit          IN      varchar2 -- := FND_API.G_FALSE
 ,p_Tab_Id        	IN      number
 ,x_return_status   OUT NOCOPY     varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
) IS

 v_Common_Level_ReTrieved_Tbl 	BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Tbl_Type;
 v_Common_Level_Found_Tbl 	BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Tbl_Type;

 v_Dim_Level_Rec_R 		BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
 v_Dim_Level_Rec_F 		BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
 v_Index 			    NUMBER;
 v_Parent_Dim_Level_Id	NUMBER;
 l_deleted_rows         NUMBER;
 l_Bsc_Tab_Entity_Rec   BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;


BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCCheDimLevsPUB;
		  --DBMS_OUTPUT.PUT_LINE('Begin Check_Common_Dim_Levels' );
		  --DBMS_OUTPUT.PUT_LINE('Check_Common_Dim_Levels   p_Tab_Id = ' || p_Tab_Id  );
  -- Get the Common Dimension Level already define in the DB.
  Retrieve_Common_Dim_Levels(p_commit, p_Tab_Id, v_Common_Level_ReTrieved_Tbl
				 		,x_return_status ,x_msg_count ,x_msg_data );

  l_deleted_rows := 0;
  IF v_Common_Level_ReTrieved_Tbl.COUNT > 0 THEN   /* If There are common Dimension defined in DB   */
        -- Find the potention Common Dimension Levels
  	Find_Common_Dim_Levels(p_commit, p_Tab_Id, v_Common_Level_Found_Tbl
				 		,x_return_status ,x_msg_count ,x_msg_data );

        -- Check For the Common Dimension Level that not apply any more
        -- Compare data from v_Common_Level_ReTrieved_Tbl and v_Common_Level_Found_Tbl
        -- (The Common Level are stored in secuencial order)
      	v_Index := 0;
        IF v_Common_Level_Found_Tbl.COUNT > 0 THEN
            LOOP
               v_Index := v_Index + 1;
               v_Dim_Level_Rec_R := v_Common_Level_ReTrieved_Tbl(v_Index);
   	           IF v_Index  <= v_Common_Level_Found_Tbl.COUNT  THEN
                	  v_Dim_Level_Rec_F := v_Common_Level_Found_Tbl(v_Index);
        		  IF v_Dim_Level_Rec_R.Bsc_Level_View_Name <>  v_Dim_Level_Rec_F.Bsc_Level_View_Name THEN
                     EXIT;
                  END IF;
               ELSE
		          EXIT;
               END IF;
               IF v_Index = v_Common_Level_ReTrieved_Tbl.COUNT THEN
                     --It does not need to delete any of the defined Common levels
	       	     v_Index := - 9999;
                     EXIT;
               END IF;
            END LOOP;
            v_Index := v_Index - 1;
        END IF;
        IF v_Index >= 0 then
           --DBMS_OUTPUT.PUT_LINE('Check_Common_Dim_Levels    It need delete some common Dimension Levels');

	        -- Delete the Common Levels  that not applay any more
	        DELETE FROM BSC_SYS_COM_DIM_LEVELS
	          WHERE TAB_ID = p_Tab_Id
	          AND DIM_LEVEL_INDEX >= v_Index;
              l_deleted_rows := sql%rowcount;
              --DBMS_OUTPUT.PUT_LINE('Check_Common_Dim_Levels  l_deleted_rows = ' ||l_deleted_rows);
     		-- Delete Records from BSC_USER_LIST_ACCESS that not apply any more
    		DELETE FROM BSC_USER_LIST_ACCESS
                  WHERE TAB_ID = p_Tab_Id
                  AND DIM_LEVEL_INDEX >= v_Index;

    		x_return_status := 'DISABLE';

    		Check_Dim_Level_Default_Value(p_commit, p_Tab_Id
				 		,x_return_status ,x_msg_count ,x_msg_data );
        ELSE
                --DBMS_OUTPUT.PUT_LINE('Check_Common_Dim_Levels    Common Dimension Levels Not need Changes');
                v_Index := 0;   /* Just to support the output */
        END IF;
  ELSE
                --DBMS_OUTPUT.PUT_LINE('Check_Common_Dim_Levels    No Common Dimension Levels Defined in DB');
                v_Index := 0;   /* Just to support the output */
  END IF;

  -- change the Scorecard time stamp when the common dimension were updated.

  --DBMS_OUTPUT.PUT_LINE('Check_Common_Dim_Levels  - l_deleted_rows = '||l_deleted_rows);


  IF l_deleted_rows <> 0  THEN
     --DBMS_OUTPUT.PUT_LINE('Check_Common_Dim_Levels  - l_deleted_rows = '||l_deleted_rows);

     l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id:=p_Tab_Id;
      BSC_SCORECARD_PUB.Update_Tab_Time_Stamp( FND_API.G_FALSE
                                            ,l_Bsc_Tab_Entity_Rec
                                            ,x_return_status
                                            ,x_msg_count
                                            ,x_msg_data
      );
  END IF;

--DBMS_OUTPUT.PUT_LINE('End Check_Common_Dim_Levels');
/*
BSC_MESSAGE.Add(x_message => 'completed run Check_Common_Dim_Levels',
                x_source => 'BSC_COMMON_DIM_LEVELS_PUB',
                x_mode => 'I');
commit;
*/

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCCheDimLevsPUB;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCCheDimLevsPUB;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BSCCheDimLevsPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BSCCheDimLevsPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END  Check_Common_Dim_Levels;

/*-------------------------------------------------------------------------------------------------------------------
  Check_Common_Dim_Levels_DL
     To Check Common dimension levels when dimension level is updated
     ot deleted, etc
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE Check_Common_Dim_Levels_DL(
  p_Dim_Level_Id        IN  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count		    OUT NOCOPY	number
 ,x_msg_data		    OUT NOCOPY	varchar2
) IS
 -- Query to get the tabs where a dimension object is used
 -- as common dimension level
 CURSOR c_tabs_to_check is
  select TAB_ID
  from BSC_SYS_COM_DIM_LEVELS
  Where DIM_LEVEL_id = p_Dim_Level_Id;

  l_tab_id number;

BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCCheDimLevsDL_PUB;
	--DBMS_OUTPUT.PUT_LINE('Begin Check_Common_Dim_Levels_DL' );
	--DBMS_OUTPUT.PUT_LINE('Check_Common_Dim_Levels_DL   p_Dim_Level_Id = ' || p_Dim_Level_Id  );
   open c_tabs_to_check;
   loop
     fetch c_tabs_to_check into l_tab_id;
     exit when c_tabs_to_check%notfound;
     Check_Common_Dim_Levels(
        p_Tab_Id            => l_tab_id
       ,x_return_status     => x_return_status
       ,x_msg_count	    => x_msg_count
       ,x_msg_data	    => x_msg_data
     );
   end loop;
   close c_tabs_to_check;
   --DBMS_OUTPUT.PUT_LINE('Begin Check_Common_Dim_Levels_DL' );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        if c_tabs_to_check%isopen then
          close c_tabs_to_check;
        end if;
        ROLLBACK TO BSCCheDimLevsDL_PUB;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        if c_tabs_to_check%isopen then
          close c_tabs_to_check;
        end if;
        ROLLBACK TO BSCCheDimLevsDL_PUB;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        if c_tabs_to_check%isopen then
          close c_tabs_to_check;
        end if;
        ROLLBACK TO BSCCheDimLevsDL_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels_DL';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels_DL';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END  Check_Common_Dim_Levels_DL;

/*------------------------------------------------------------------------------
 Check_Common_Dim_Levels_by_Dim
    Top be use when a Dimension (Dimension Group is updated)
---------------------------------------------------------------------------------*/
PROCEDURE Check_Common_Dim_Levels_by_Dim(
  p_Dimension_Id        IN  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count		    OUT NOCOPY	number
 ,x_msg_data		    OUT NOCOPY	varchar2
) IS
 -- Query to get the tabs where a dimension object is used
 -- as common dimension level

 CURSOR c_tabs_to_check is
    SELECT DISTINCT B.TAB_ID
      FROM BSC_KPI_DIM_GROUPS A
          ,BSC_TAB_INDICATORS B
      WHERE A.INDICATOR = B.INDICATOR
        AND A.DIM_GROUP_ID = p_Dimension_Id;

  l_tab_id number;

BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCCheckCDimByDim;
	--DBMS_OUTPUT.PUT_LINE('Begin Check_Common_Dim_Levels_by_Dim' );
	--DBMS_OUTPUT.PUT_LINE('Check_Common_Dim_Levels_by_Dim   p_Dimension_Id = ' || p_Dimension_Id  );
   open c_tabs_to_check;
   loop
     fetch c_tabs_to_check into l_tab_id;
     exit when c_tabs_to_check%notfound;
     Check_Common_Dim_Levels(
        p_Tab_Id            => l_tab_id
       ,x_return_status     => x_return_status
       ,x_msg_count	        => x_msg_count
       ,x_msg_data	        => x_msg_data
     );
   end loop;
   close c_tabs_to_check;
   --DBMS_OUTPUT.PUT_LINE('End Check_Common_Dim_Levels_by_Dim' );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        if c_tabs_to_check%isopen then
          close c_tabs_to_check;
        end if;
        ROLLBACK TO BSCCheckCDimByDim;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        if c_tabs_to_check%isopen then
          close c_tabs_to_check;
        end if;
        ROLLBACK TO BSCCheckCDimByDim;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        if c_tabs_to_check%isopen then
          close c_tabs_to_check;
        end if;
        ROLLBACK TO BSCCheckCDimByDim;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels_by_Dim';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels_by_Dim';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END  Check_Common_Dim_Levels_by_Dim;


-------------------------------------------------------------------------------------------------------------------
--   Find_Common_Dim_Levels
-------------------------------------------------------------------------------------------------------------------
PROCEDURE Find_Common_Dim_Levels(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Tab_Id        	IN      number
 ,x_Dim_Level_Tbl 	OUT NOCOPY     BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Tbl_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
) IS

 v_Num_KPI_Default_PMF	number;   /* Number of  KPIs With Default PMF Measures  */
 v_Num_Dim_Sets_In_Tab 			number;
 v_Dim_Level_Rec 			BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;

 v_Index 				number;
 v_Parent_Dim_Level_Id			number;


 --Cursor to get The common Dimensions for the tab.
 CURSOR c_Common_Levels IS
	 SELECT DISTINCT KL.LEVEL_TABLE_NAME, KL.DIM_LEVEL_INDEX, NVL(KL.PARENT_LEVEL_INDEX, -1), SL.DIM_LEVEL_ID
	   FROM BSC_TAB_INDICATORS TI,
	      BSC_KPIS_B KB,
	      BSC_KPI_DIM_LEVELS_VL KL,
	      BSC_SYS_DIM_LEVELS_VL SL
	   WHERE TI.TAB_ID = p_Tab_Id
		  AND KB.INDICATOR = TI.INDICATOR
		  AND KB.PROTOTYPE_FLAG <> 2
		  AND KL.INDICATOR = KB.INDICATOR
		  AND KL.TABLE_RELATION IS NULL
		  AND KL.STATUS <> 0
		  AND KL.DEFAULT_KEY_VALUE IS NULL
		  AND ( KL.DEFAULT_VALUE = 'T' OR KL.DEFAULT_VALUE LIKE 'D%')
		  AND KL.LEVEL_SOURCE ='BSC'
                  AND SL.LEVEL_TABLE_NAME = KL.LEVEL_TABLE_NAME
	   GROUP BY KL.LEVEL_TABLE_NAME,
		KL.PARENT_LEVEL_INDEX,
		KL.DIM_LEVEL_INDEX,
                STATUS,
		KL.TABLE_RELATION,
		SL.DIM_LEVEL_ID
	   HAVING Count(KL.DIM_SET_ID) =  v_Num_Dim_Sets_In_Tab
	   ORDER BY KL.DIM_LEVEL_INDEX;

    CURSOR c_child_validation IS
       SELECT KL.INDICATOR
            , KL.DIM_SET_ID
            , KL.DIM_LEVEL_INDEX
            , SLG.DEFAULT_VALUE
            , KL.PARENT_LEVEL_INDEX
            , KL.DEFAULT_KEY_VALUE
       FROM BSC_TAB_INDICATORS TI
          , BSC_KPIS_B KB
          , BSC_KPI_DIM_LEVELS_VL KL
          , BSC_KPI_DIM_GROUPS KG
          , BSC_SYS_DIM_LEVELS_BY_GROUP SLG
          , BSC_SYS_DIM_LEVELS_VL SL
       WHERE TI.TAB_ID =  p_Tab_Id
         AND KB.INDICATOR = TI.INDICATOR
         AND KB.PROTOTYPE_FLAG <> 2
         AND KL.INDICATOR = KB.INDICATOR
         AND KG.INDICATOR = KL.INDICATOR
         AND KG.DIM_SET_ID = KL.DIM_SET_ID
         AND SLG.DIM_GROUP_ID = KG.DIM_GROUP_ID
         AND SL.DIM_LEVEL_ID = SLG.DIM_LEVEL_ID
         AND SL.LEVEL_TABLE_NAME = KL.LEVEL_TABLE_NAME
       ORDER BY KL.INDICATOR, KL.DIM_SET_ID, KL.DIM_LEVEL_INDEX;

    l_Dim_Set_Changed_Flag  BOOLEAN;
    l_Child_Dim_Obj_Flag    BOOLEAN;
    l_last_KPI_Code         NUMBER;
    l_Last_Dim_Set_Id       NUMBER;
    l_Firt_Dim_Family_Flag  BOOLEAN;

BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
		  --DBMS_OUTPUT.PUT_LINE('Begin Find_Common_Dim_Levels');

 --Evaluate that not KPI in the tab has PMF Measures as Default One
 SELECT COUNT(SOURCE)
   INTO v_Num_KPI_Default_PMF
   FROM (SELECT DISTINCT KM.INDICATOR, DS.DATASET_ID, DS.SOURCE  --, KM.PROTOTYPE_FLAG
	 FROM BSC_TAB_INDICATORS TI,
	  BSC_KPI_ANALYSIS_MEASURES_B KM ,
	  (SELECT INDICATOR, DEFAULT_VALUE
	    FROM  BSC_KPI_ANALYSIS_GROUPS
	    WHERE  ANALYSIS_GROUP_ID = 0 ) A0,
	  (SELECT INDICATOR, DEFAULT_VALUE
	    FROM  BSC_KPI_ANALYSIS_GROUPS
	    WHERE  ANALYSIS_GROUP_ID = 1 ) A1,
	  (SELECT INDICATOR, DEFAULT_VALUE
	    FROM  BSC_KPI_ANALYSIS_GROUPS
	    WHERE  ANALYSIS_GROUP_ID = 2 ) A2,
	  BSC_SYS_DATASETS_B DS
	 WHERE TI.TAB_ID = p_Tab_Id
	   AND KM.INDICATOR = TI.INDICATOR
	   AND KM.DEFAULT_VALUE = 1
	   AND KM.INDICATOR = A0.INDICATOR (+)
	   AND KM.ANALYSIS_OPTION0 = NVL(A0.DEFAULT_VALUE, 0)
	   AND KM.INDICATOR = A1.INDICATOR (+)
	   AND KM.ANALYSIS_OPTION1 = NVL(A1.DEFAULT_VALUE, 0)
	   AND KM.INDICATOR = A2.INDICATOR (+)
	   AND KM.ANALYSIS_OPTION2 = NVL(A2.DEFAULT_VALUE, 0)
	   AND DS.DATASET_ID = KM.DATASET_ID
	)
   WHERE SOURCE <> 'BSC';


 --If There is not PMF Measures as Default
 IF v_Num_KPI_Default_PMF  = 0 Then

  --Evaluate the number of Dimention Set  in the tab, on which a Common Dimension Level must be belong to.
  --It does not take in account PMF Dimension Sets
   SELECT COUNT (DIM_SET_ID)
     INTO v_Num_Dim_Sets_In_Tab
     FROM (
          SELECT DISTINCT INDICATOR, DIM_SET_ID, SOURCE
	    FROM
            ( SELECT KB.INDICATOR, KDS.DIM_SET_ID, SL.DIM_LEVEL_ID, SL.SOURCE
	        FROM BSC_TAB_INDICATORS TI,
	          BSC_KPIS_B KB,
	          BSC_KPI_DIM_SETS_VL KDS,
	          BSC_KPI_DIM_GROUPS KDG,
	          BSC_SYS_DIM_LEVELS_BY_GROUP SLG,
	          BSC_SYS_DIM_LEVELS_B SL
	        WHERE TI.TAB_ID = p_Tab_Id
	          AND KB.INDICATOR = TI.INDICATOR
	          AND KB.PROTOTYPE_FLAG <> 2
	          AND KDS.INDICATOR = KB.INDICATOR
	          AND KDG.INDICATOR (+) = KDS.INDICATOR
	          AND NVL(KDG.DIM_SET_ID , KDS.DIM_SET_ID) =  KDS.DIM_SET_ID
	          AND SLG.DIM_GROUP_ID (+)  = KDG.DIM_GROUP_ID
	          AND SL.DIM_LEVEL_ID (+) =  SLG.DIM_LEVEL_ID
	        ORDER BY KB.INDICATOR, KDS.DIM_SET_ID , KDG.DIM_GROUP_INDEX, SLG.DIM_LEVEL_INDEX
            )
         )
     WHERE (SOURCE <> 'PMF' OR SOURCE IS NULL);

   IF v_Num_Dim_Sets_In_Tab  <> 0 Then
            --Common Dimension are those that are in all the Dimension Sets existing
            --in the Tab  (Not including PMF Dimension)
            --Rules:  Level Status must to be <> 0 . It mean disabled
            --         M x N RelationShips not apply for Common Dimensions
            --         Dimensions with DEFAULT_KEY_VALUE not apply for common Dimensions:
            --              (DEFAULT_VALUE <> 'T Or DEFAULT_KEY_VALUE IS NOT NULL)

     --get The common Dimensions for the tab.
     v_Index := 0;
     v_Parent_Dim_Level_Id := -1;
     OPEN c_Common_Levels;
     LOOP
       FETCH c_Common_Levels INTO v_Dim_Level_Rec.Bsc_Level_View_Name
                                  ,v_Dim_Level_Rec.Bsc_Level_Index
                                  ,v_Dim_Level_Rec.Bsc_Parent_Level_Index
                                  ,v_Dim_Level_Rec.Bsc_Level_Id;
       EXIT WHEN c_Common_Levels%NOTFOUND;
       IF v_Index = v_Dim_Level_Rec.Bsc_Level_Index AND
             (v_Dim_Level_Rec.Bsc_Level_Index = 0 OR v_Dim_Level_Rec.Bsc_Parent_Level_Index <> -1  )  then
                v_Index := v_Index + 1 ;
                v_Dim_Level_Rec.Bsc_Parent_Level_Id  := v_Parent_Dim_Level_Id;
		x_Dim_Level_Tbl(v_Index) := v_Dim_Level_Rec;
		v_Parent_Dim_Level_Id := v_Dim_Level_Rec.Bsc_Level_Id;

                --DBMS_OUTPUT.PUT_LINE('Find_Common_Dim_Levels    v_Dim_Level_Rec.Bsc_Level_View_Name ' || v_Dim_Level_Rec.Bsc_Level_View_Name);
                --DBMS_OUTPUT.PUT_LINE('Find_Common_Dim_Levels    v_Dim_Level_Rec.Bsc_Level_Index ' || v_Dim_Level_Rec.Bsc_Level_Index );
       ELSE
 	     EXIT;
       END IF;
     END LOOP;

     --DBMS_OUTPUT.PUT_LINE('Find_Common_Dim_Levels    x_Dim_Level_Tbl.COUNT = ' || x_Dim_Level_Tbl.COUNT);

     ------------ Disable list button when one of the children of the common
     --           dimension objects doesn't enter in TOTAL
     --  fixed bug 3518610
     l_last_KPI_Code := -999;
     l_Last_Dim_Set_Id := -999;
     l_Child_Dim_Obj_Flag := TRUE;

     FOR CD IN c_child_validation LOOP
       l_Dim_Set_Changed_Flag := (CD.INDICATOR <> l_last_KPI_Code) OR (CD.DIM_SET_ID <> l_Last_Dim_Set_Id);
       IF l_Dim_Set_Changed_Flag THEN
            l_Firt_Dim_Family_Flag := TRUE;
       END IF;
       l_last_KPI_Code := CD.INDICATOR;
       l_Last_Dim_Set_Id := CD.DIM_SET_ID;
       l_Child_Dim_Obj_Flag := l_Dim_Set_Changed_Flag OR (l_Dim_Set_Changed_Flag = FALSE  AND CD.PARENT_LEVEL_INDEX IS NOT NULL);
       l_Firt_Dim_Family_Flag := l_Firt_Dim_Family_Flag AND l_Child_Dim_Obj_Flag;
       --MEM 07/10/00 Bug #1343648 Add condition on DEFAULT_KEY_VALUE. We disable the list also when some common
       --dimension enter in a key value
       IF (UPPER(CD.DEFAULT_VALUE) <> 'T' OR CD.DEFAULT_KEY_VALUE IS NOT NULL) AND l_Firt_Dim_Family_Flag THEN
            -- Clear comman Dimensions
        	x_Dim_Level_Tbl.DELETE;
            EXIT;
       END IF;
     END LOOP;
     -----------------------------------
     --DBMS_OUTPUT.PUT_LINE('Find_Common_Dim_Levels    x_Dim_Level_Tbl.COUNT = ' || x_Dim_Level_Tbl.COUNT);

   END IF;
 END IF;
		  --DBMS_OUTPUT.PUT_LINE('End Find_Common_Dim_Levels');

--debug messages
/*
BSC_MESSAGE.Add(x_message => 'completed run Find_Common_Dim_Levels',
                x_source => 'BSC_COMMON_DIM_LEVELS_PUB',
                x_mode => 'I');
commit;
*/
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
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIM_LEVELS_PUB.Find_Common_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIM_LEVELS_PUB.Find_Common_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIM_LEVELS_PUB.Find_Common_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIM_LEVELS_PUB.Find_Common_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Find_Common_Dim_Levels;


/*-------------------------------------------------------------------------------------------------------------------
   Retrieve_Common_Dim_Levels
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE  Retrieve_Common_Dim_Levels(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Tab_Id        	IN      number
 ,x_Dim_Level_Tbl 	OUT NOCOPY	BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Tbl_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
) IS

-- used

 v_Dim_Level_Rec 			BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
 v_Index 				number;
 v_Parent_Dim_Level_Id			number;


 --Cursor to get The common Dimensions for the tab.
 CURSOR c_Common_Levels IS
	 SELECT SL.LEVEL_TABLE_NAME,
		CL.DIM_LEVEL_INDEX,
		CL.PARENT_LEVEL_INDEX,
		CL.DIM_LEVEL_ID,
                CL.PARENT_DIM_LEVEL_ID
	    FROM BSC_SYS_DIM_LEVELS_B SL,
		BSC_SYS_COM_DIM_LEVELS CL
	   WHERE CL.TAB_ID = p_Tab_Id
		AND SL.DIM_LEVEL_ID (+) = CL.DIM_LEVEL_ID
 	   ORDER BY CL.DIM_LEVEL_INDEX;

BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
		  --DBMS_OUTPUT.PUT_LINE('Begin Retrieve_Common_Dim_Levels');

     v_Index := 0;
     v_Parent_Dim_Level_Id := -1;
     OPEN c_Common_Levels;
     LOOP
       FETCH c_Common_Levels INTO v_Dim_Level_Rec.Bsc_Level_View_Name
                                  ,v_Dim_Level_Rec.Bsc_Level_Index
                                  ,v_Dim_Level_Rec.Bsc_Parent_Level_Index
                                  ,v_Dim_Level_Rec.Bsc_Level_Id
				  ,v_Dim_Level_Rec.Bsc_Parent_Level_Id;
       EXIT WHEN c_Common_Levels%NOTFOUND;
       v_Index := v_Index + 1 ;
       x_Dim_Level_Tbl(v_Index) := v_Dim_Level_Rec;

       --DBMS_OUTPUT.PUT_LINE('Retrieve_Common_Dim_Levels  v_Dim_Level_Rec.Bsc_Level_View_Name ' || v_Dim_Level_Rec.Bsc_Level_View_Name);
       --DBMS_OUTPUT.PUT_LINE('Retrieve_Common_Dim_Levels  v_Dim_Level_Rec.Bsc_Level_Index ' || v_Dim_Level_Rec.Bsc_Level_Index );

     END LOOP;


		  --DBMS_OUTPUT.PUT_LINE('End Retrieve_Common_Dim_Levels');

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
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIM_LEVELS_PUB.Retrieve_Common_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIM_LEVELS_PUB.Retrieve_Common_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIM_LEVELS_PUB.Retrieve_Common_Dim_Levels ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIM_LEVELS_PUB.Retrieve_Common_Dim_Levels ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END  Retrieve_Common_Dim_Levels;

/*-------------------------------------------------------------------------------------------------------------------
   Check_Dim_Level_Default_Value
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE  Check_Dim_Level_Default_Value(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Tab_Id        	IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
) IS

 v_Common_Level_ReTrieved_Tbl 	BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Tbl_Type;
 v_Dim_Level_Rec_R 			BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
 v_Indicator 				number;
 v_index				number;

 CURSOR c_KPIs IS
 	SELECT INDICATOR
          FROM  BSC_TAB_INDICATORS
          WHERE TAB_ID = p_Tab_Id;

BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCChkDimLevDefPUB;

		  --DBMS_OUTPUT.PUT_LINE('Begin Check_Dim_Level_Default_Value');

  -- Get the Common Dimension Level already define in the DB.
  Retrieve_Common_Dim_Levels(p_commit, p_Tab_Id, v_Common_Level_ReTrieved_Tbl
				 		,x_return_status ,x_msg_count ,x_msg_data );

  OPEN c_KPIs;
  LOOP
       FETCH c_KPIs INTO v_Indicator;
       EXIT WHEN c_KPIs%NOTFOUND;

	  UPDATE BSC_KPI_DIM_LEVELS_B SET DEFAULT_VALUE = 'T'
            WHERE INDICATOR = v_Indicator AND DEFAULT_VALUE Like 'D%';

          for v_Index IN 1.. v_Common_Level_ReTrieved_Tbl.COUNT LOOP
	    v_Dim_Level_Rec_R := v_Common_Level_ReTrieved_Tbl(v_Index);
	    UPDATE BSC_KPI_DIM_LEVELS_B SET DEFAULT_VALUE = 'D' || v_Dim_Level_Rec_R.Bsc_Level_Index
              WHERE INDICATOR = v_Indicator AND LEVEL_TABLE_NAME = v_Dim_Level_Rec_R.Bsc_Level_View_Name;

            --DBMS_OUTPUT.PUT_LINE('Check_Dim_Level_Default_Value   v_Indicator ' || v_Indicator);
            --DBMS_OUTPUT.PUT_LINE('Check_Dim_Level_Default_Value   v_Dim_Level_Rec_R.Bsc_Level_View_Name ' || v_Dim_Level_Rec_R.Bsc_Level_View_Name);
            --DBMS_OUTPUT.PUT_LINE('Check_Dim_Level_Default_Value   v_Dim_Level_Rec_R.Bsc_Level_Index ' || v_Dim_Level_Rec_R.Bsc_Level_Index );

          end loop;

 END LOOP;

 if p_commit = FND_API.G_TRUE then
	commit;
 end if;
		  --DBMS_OUTPUT.PUT_LINE('End Check_Dim_Level_Default_Value');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCChkDimLevDefPUB;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCChkDimLevDefPUB;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BSCChkDimLevDefPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIM_LEVELS_PUB.Check_Dim_Level_Default_Value ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIM_LEVELS_PUB.Check_Dim_Level_Default_Value ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO BSCChkDimLevDefPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIM_LEVELS_PUB.Check_Dim_Level_Default_Value ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIM_LEVELS_PUB.Check_Dim_Level_Default_Value ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END  Check_Dim_Level_Default_Value;

/*******************************************************************
 Name	: Validate_List_Button
 Description : This procedure will validate the common dim levels
	       within the tab.
	       This procedure can accept Kpi id and dim level id.
	       If kpi id passed then Check_Common_Dim_Levels is called.
	       If dimension obhect is passed then Check_Common_Dim_Levels_DL
	       will be called.
 Inputs	: p_Kpi_Id
	  p_Dim_Level_Id
Creator : ashankar 26-MAR-2004
Note: This API takes care of shared indicators also.So don't need to call
      this API for shared indiactors.

     The below API does the validation for the list buttons
     Common Dimension are those which are common across the tabs.
     If the tab contains 10 dimension sets, then all these dimension sets
     must have the same dimension levels and in the same order.
     The following is the Logic :-
     1.First check if the indicator is already assigned to the tab.
     2.if yes then get the tab id corresponding to the KPI.
     3.call the common dimension level sanity test API.
     4.Call the same logic for all the shared indiactors also

/******************************************************************/
PROCEDURE Validate_List_Button
(
  	p_Kpi_Id		IN		BSC_KPIS_B.indicator%TYPE := NULL
   ,	p_Dim_Level_Id		IN		NUMBER	:= NULL
   ,	x_return_status		OUT NOCOPY      VARCHAR2
   ,	x_msg_count		OUT NOCOPY	NUMBER
   ,	x_msg_data		OUT NOCOPY	VARCHAR2
)IS
  l_Kpi_Id	BSC_KPIS_B.indicator%TYPE;
  l_count       NUMBER;
  l_tab_id	BSC_TABS_B.Tab_Id%TYPE;

  CURSOR  c_kpi_ids IS
  SELECT  indicator
  FROM    BSC_KPIS_B
  WHERE   Source_Indicator =   l_Kpi_Id
  AND     Prototype_Flag   <>  2;

  CURSOR c_tab_id IS
  SELECT tab_id
  FROM   BSC_TAB_INDICATORS
  WHERE  indicator = l_Kpi_Id;

BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF(p_Kpi_Id IS NOT NULL) THEN
    	l_Kpi_Id := p_Kpi_Id;
       FOR cd IN c_tab_id LOOP
		l_tab_id := cd.tab_id;
		BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels
		(
		      p_Tab_Id             =>  l_tab_id
		     ,x_return_status      =>  x_return_status
		     ,x_msg_count          =>  x_msg_count
		     ,x_msg_data           =>  x_msg_data
         );
         IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
		   --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Set Failed: at  BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels');
		    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;
	   END LOOP;
	/***************For Shared Indiactors ***********************************/

     FOR cd IN c_kpi_ids LOOP
	   l_Kpi_Id :=	cd.indicator;

	   IF(c_tab_id%ISOPEN ) THEN
	   	CLOSE c_tab_id;
	   END IF;

	   OPEN c_tab_id;
	   FETCH c_tab_id INTO l_tab_id;
	   EXIT WHEN c_tab_id%NOTFOUND;
	   CLOSE c_tab_id;

	   BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels
	   (
	         p_Tab_Id             =>  l_tab_id
	        ,x_return_status      =>  x_return_status
	        ,x_msg_count          =>  x_msg_count
	        ,x_msg_data           =>  x_msg_data
	   );
	   IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
	     --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Set Failed: at  BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels');
	     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;
    END LOOP;

    ELSIF(p_Dim_Level_Id IS NOT NULL) THEN

    	BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels_DL
    	(
	  	p_Dim_Level_Id		=>  p_Dim_Level_Id
	       ,x_return_status		=>  x_return_status
	       ,x_msg_count		=>  x_msg_count
	       ,x_msg_data		=>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
	    --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Set Failed: at  BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels');
	    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
    END IF;

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
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        RAISE;
END Validate_List_Button;



END BSC_COMMON_DIM_LEVELS_PUB;

/
