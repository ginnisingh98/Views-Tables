--------------------------------------------------------
--  DDL for Package Body BSC_SIMULATION_VIEW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SIMULATION_VIEW_PUB" AS
/* $Header: BSCSIMPB.pls 120.3.12000000.1 2007/07/17 07:44:26 appldev noship $ */

PROCEDURE Set_Obj_Kpi_Prototype
(
  p_indicator      IN          BSC_KPIS_B.indicator%TYPE
 ,p_dataset_id     IN          BSC_SYS_DATASETS_B.dataset_id%TYPE
 ,x_return_status  OUT NOCOPY  VARCHAR2
 ,x_msg_count      OUT NOCOPY  NUMBER
 ,x_msg_data       OUT NOCOPY  VARCHAR2
);


FUNCTION Is_More
( p_list_ids    IN  OUT NOCOPY  VARCHAR2
 ,p_id          OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
    l_pos_rel_columns       NUMBER;
BEGIN
    IF (p_list_ids IS NOT NULL) THEN
        l_pos_ids           := INSTR(p_list_ids, ',');
        IF (l_pos_ids > 0) THEN
            p_id            :=  TRIM(SUBSTR(p_list_ids, 1, l_pos_ids - 1));
            p_list_ids      :=  TRIM(SUBSTR(p_list_ids, l_pos_ids + 1));
        ELSE
            p_id            :=  TRIM(p_list_ids);
            p_list_ids      :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;


FUNCTION Get_Kpi_MeasureCol
(
  p_DatasetId    IN   bsc_sys_datasets_b.dataset_id%TYPE
) RETURN VARCHAR2 IS

l_measure_col    bsc_sys_measures.measure_col%TYPE;
BEGIN

    IF(p_DatasetId IS NOT NULL) THEN
      SELECT measure_col
      INTO   l_measure_col
      FROM   bsc_sys_datasets_b b
           , bsc_sys_measures a
      WHERE  b.measure_id1 =a.measure_id
      AND    b.dataset_id =p_DatasetId;
    END IF;
    RETURN l_measure_col;

END Get_Kpi_MeasureCol;


FUNCTION Get_Formula_Base_Columns
(
   p_indicator     IN    bsc_kpis_b.indicator%TYPE
  ,p_Dataset_Id    IN    bsc_sys_datasets_b.dataset_id%TYPE
  ,p_Meas_Col      IN    bsc_sys_measures.measure_col%TYPE
) RETURN VARCHAR2 IS

  l_measure_col      bsc_sys_measures.measure_col%TYPE;
  l_short_name       bsc_kpis_b.short_name%TYPE;
  l_kpi_short_name   bis_indicators.short_name%TYPE;
  l_formula          VARCHAR2(32000);
  l_count            NUMBER;

  l_Ak_Null_Tbl       BSC_SIMULATION_VIEW_PUB.Bsc_Ak_Region_Items_Tbl_Type ;
  l_Ak_NotNull_Tbl    BSC_SIMULATION_VIEW_PUB.Bsc_Ak_Region_Items_Tbl_Type ;

  CURSOR c_meas_null IS
  SELECT v.attribute_code,
         v.attribute2,
         v.attribute3,
         b.operation|| '('|| b.measure_col || ')'  as measure_col
  FROM   ak_region_items_vl v
        ,bsc_sys_measures b
  WHERE v.attribute2 =b.short_name
  AND   v.region_code =l_short_name
  AND   v.attribute1 =BSC_SIMULATION_VIEW_PUB.c_MEASURE_NO_TARGET
  AND   v.attribute3 IS NULL
  ORDER BY v.display_sequence;


  CURSOR c_meas_notnull IS
  SELECT v.attribute_code,
         v.attribute2,
         v.attribute3,
         b.measure_col
  FROM   ak_region_items_vl v
        ,bsc_sys_measures b
  WHERE v.attribute2 =b.short_name
  AND   v.region_code =l_short_name
  AND   v.attribute1 =BSC_SIMULATION_VIEW_PUB.c_MEASURE_NO_TARGET
  AND   v.attribute3 IS NOT NULL
  ORDER BY v.display_sequence;

BEGIN

  SELECT short_name
  INTO   l_short_name
  FROM   bsc_kpis_b
  WHERE  indicator =p_indicator;

  IF(l_short_name IS NOT NULL)THEN
   l_count :=0;

   FOR cd IN c_meas_null LOOP
    l_Ak_Null_Tbl(l_count).Attribute_Code := cd.attribute_code ;
    l_Ak_Null_Tbl(l_count).shortName      := cd.attribute2 ;
    l_Ak_Null_Tbl(l_count).Formula        := cd.attribute3 ;
    l_Ak_Null_Tbl(l_count).Measure_Col    := cd.measure_col ;
    l_Ak_Null_Tbl(l_count).Acutual_Formula:= cd.attribute3 ;
    l_count := l_count + 1;
   END LOOP;

   l_count :=0;

   FOR cd IN c_meas_notnull LOOP
     l_Ak_NotNull_Tbl(l_count).Attribute_Code := cd.attribute_code ;
     l_Ak_NotNull_Tbl(l_count).shortName      := cd.attribute2 ;
     l_Ak_NotNull_Tbl(l_count).Formula        := cd.attribute3 ;
     l_Ak_NotNull_Tbl(l_count).Measure_Col    := cd.measure_col ;
     l_Ak_NotNull_Tbl(l_count).Acutual_Formula:= cd.attribute3 ;
     l_count := l_count + 1;
   END LOOP;

  END IF;

  --/////////////////////Test case //////////////////////////////

  /*  l_Ak_Null_Tbl(0).Attribute_Code := 'BIS_COLUMN_9' ;
    l_Ak_Null_Tbl(0).shortName      := 'SHORT_NAME' ;
    l_Ak_Null_Tbl(0).Formula        := NULL;
    l_Ak_Null_Tbl(0).Measure_Col    := 'SUM(M1)' ;
    l_Ak_Null_Tbl(0).Acutual_Formula:= NULL ;

    l_Ak_Null_Tbl(1).Attribute_Code := 'BIS_COLUMN_13';
    l_Ak_Null_Tbl(1).shortName      := 'SHORT_NAME1' ;
    l_Ak_Null_Tbl(1).Formula        := NULL;
    l_Ak_Null_Tbl(1).Measure_Col    := 'AVG(M2)';
    l_Ak_Null_Tbl(1).Acutual_Formula:= NULL;


    l_Ak_NotNull_Tbl(0).Attribute_Code := 'BIS_COLUMN_16';
    l_Ak_NotNull_Tbl(0).shortName      := 'SHORT_NAME2' ;
    l_Ak_NotNull_Tbl(0).Formula        := 'BIS_COLUMN_9+2*BIS_COLUMN_13';
    l_Ak_NotNull_Tbl(0).Measure_Col    := 'BIS_COLUMN_9+2*BIS_COLUMN_13' ;
    l_Ak_NotNull_Tbl(0).Acutual_Formula:= 'BIS_COLUMN_9+2*BIS_COLUMN_13';


    l_Ak_NotNull_Tbl(1).Attribute_Code := 'BIS_COLUMN_19';
    l_Ak_NotNull_Tbl(1).shortName      := 'SHORT_NAME3' ;
    l_Ak_NotNull_Tbl(1).Formula        := 'BIS_COLUMN_16+POWER(BIS_COLUMN_13,BIS_COLUMN_9)';
    l_Ak_NotNull_Tbl(1).Measure_Col    := 'BIS_COLUMN_16+POWER(BIS_COLUMN_13,BIS_COLUMN_9)';
    l_Ak_NotNull_Tbl(1).Acutual_Formula:= 'BIS_COLUMN_16+POWER(BIS_COLUMN_13,BIS_COLUMN_9)';



    l_Ak_NotNull_Tbl(2).Attribute_Code := 'BIS_COLUMN_21';
    l_Ak_NotNull_Tbl(2).shortName      := 'SHORT_NAME4' ;
    l_Ak_NotNull_Tbl(2).Formula        := 'BIS_COLUMN_19+POWER(BIS_COLUMN_19,BIS_COLUMN_16)';
    l_Ak_NotNull_Tbl(2).Measure_Col    := 'BIS_COLUMN_19+POWER(BIS_COLUMN_19,BIS_COLUMN_16)';
    l_Ak_NotNull_Tbl(2).Acutual_Formula:= 'BIS_COLUMN_19+POWER(BIS_COLUMN_19,BIS_COLUMN_16)'; */

   --/////////////////////////////Test case Ended/////////////////////////////////////////




  FOR i IN 0..l_Ak_Null_Tbl.COUNT - 1 LOOP
     FOR j IN 0 ..l_Ak_NotNull_Tbl.COUNT - 1 LOOP
       IF(INSTR(l_Ak_NotNull_Tbl(j).Measure_Col,l_Ak_Null_Tbl(i).Attribute_Code)>0) THEN
          l_Ak_NotNull_Tbl(j).Measure_Col :=  REPLACE(l_Ak_NotNull_Tbl(j).Measure_Col,l_Ak_Null_Tbl(i).Attribute_Code,l_Ak_Null_Tbl(i).Measure_Col);
       END IF;
     END LOOP;
  END LOOP;

  FOR i IN 0 ..l_Ak_NotNull_Tbl.COUNT - 1 LOOP
     FOR j IN 0..l_Ak_NotNull_Tbl.COUNT - 1 LOOP
      IF(l_Ak_NotNull_Tbl.EXISTS(j) AND INSTR(l_Ak_NotNull_Tbl(j).Measure_Col,l_Ak_NotNull_Tbl(i).Attribute_Code)>0) THEN
          l_Ak_NotNull_Tbl(j).Measure_Col :=  REPLACE(l_Ak_NotNull_Tbl(j).Measure_Col,l_Ak_NotNull_Tbl(i).Attribute_Code,l_Ak_NotNull_Tbl(i).Measure_Col);
      END IF;
     END LOOP;
  END LOOP;



  FOR i IN l_Ak_NotNull_Tbl.COUNT - 1..0 LOOP
       FOR j IN i..0 LOOP
        IF(l_Ak_NotNull_Tbl.EXISTS(j) AND INSTR(l_Ak_NotNull_Tbl(j).Measure_Col,l_Ak_NotNull_Tbl(i).Attribute_Code)>0) THEN
            l_Ak_NotNull_Tbl(j).Measure_Col :=  REPLACE(l_Ak_NotNull_Tbl(j).Measure_Col,l_Ak_NotNull_Tbl(i).Attribute_Code,l_Ak_NotNull_Tbl(i).Measure_Col);
        END IF;
       END LOOP;
  END LOOP;


  /*FOR i IN 0..l_Ak_NotNull_Tbl.COUNT - 1 LOOP
   --DBMS_OUTPUT.PUT_LINE('l_Ak_NotNull_Tbl('|| i||').Attribute_Code-->'||l_Ak_NotNull_Tbl(i).Attribute_Code);
   --DBMS_OUTPUT.PUT_LINE('l_Ak_NotNull_Tbl('|| i||').shortName-->'||l_Ak_NotNull_Tbl(i).shortName);
   --DBMS_OUTPUT.PUT_LINE('l_Ak_NotNull_Tbl('|| i||').Formula-->'||l_Ak_NotNull_Tbl(i).Formula);
   --DBMS_OUTPUT.PUT_LINE('l_Ak_NotNull_Tbl('|| i||').Measure_Col-->'||l_Ak_NotNull_Tbl(i).Measure_Col);
  END LOOP;     */

  SELECT short_name
  INTO   l_short_name
  FROM   bis_indicators
  WHERE  dataset_id = p_Dataset_Id;

  --l_short_name := 'SHORT_NAME4';

  FOR i IN 0..l_Ak_NotNull_Tbl.COUNT - 1 LOOP
   IF(l_Ak_NotNull_Tbl(i).shortName=l_short_name) THEN
    l_formula:= l_Ak_NotNull_Tbl(i).Measure_Col;
    EXIT;
   END IF;
  END LOOP;

  RETURN l_formula;


END Get_Formula_Base_Columns;



PROCEDURE Create_Sim_Tree_bg (
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

  SAVEPOINT CreateSimTreebg;
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
    ,X_SOURCE_TYPE        => BSC_SIMULATION_VIEW_PUB.c_INDICATOR_TYPE
    ,X_SOURCE_CODE        => p_obj_id
    ,X_TYPE               => BSC_SIMULATION_VIEW_PUB.c_TYPE
    ,X_IMAGE_ID           => l_next_image_id
    ,X_CREATION_DATE      => SYSDATE
    ,X_CREATED_BY         => fnd_global.user_id
    ,X_LAST_UPDATE_DATE   => SYSDATE
    ,X_LAST_UPDATED_BY    => fnd_global.user_id
    ,X_LAST_UPDATE_LOGIN  => fnd_global.login_id
  );
EXCEPTION
  WHEN others THEN
    ROLLBACK TO CreateSimTreebg;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
    RAISE;
END Create_Sim_Tree_bg;


/*********************************************************
Procedure   : Add_Or_Update_Tab_View_Bg
Description : This proceudres update or add a new canvas image to the simulation tree.
              We will continue to use the tables BSC_SYS_IMAGES and
              BSC_SYS_IMAGE_MAPS_TL table for storing the simulation tree background
              images.
              Source_Type column in BSC_SYS_IMAGE_MAPS_TL will be set to 2 for indicators

              SOURCE_TYPE  --> 1 [ For tabs ]
                           --> 2 [ For indicators ]

/*********************************************************/

PROCEDURE Add_Or_Update_Sim_Tree_Bg (
   p_obj_id            IN NUMBER
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
  SAVEPOINT AddOrUpdateSimTreeBg;
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  SELECT COUNT(0)
  INTO   l_count
  FROM bsc_sys_images bsi,
       bsc_sys_images_map_vl bsim
  WHERE bsim.source_type =BSC_SIMULATION_VIEW_PUB.c_INDICATOR_TYPE
  AND   bsim.source_code = p_obj_id
  AND   bsim.type = BSC_SIMULATION_VIEW_PUB.c_TYPE
  AND   bsim.image_id = p_image_id
  AND   bsim.image_id = bsi.image_id;


  IF (l_count > 0) THEN
      --check if the image is owned by current NLS session

      SELECT COUNT(0)
      INTO   l_count
      FROM   bsc_sys_images_map_TL
      WHERE  source_type =BSC_SIMULATION_VIEW_PUB.c_INDICATOR_TYPE
      AND    source_code = p_obj_id
      AND    type = BSC_SIMULATION_VIEW_PUB.c_TYPE
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
            ROLLBACK TO AddOrUpdateSimTreeBg;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_data := 'Update to BSC_SYS_IMAGES failed' || SQLERRM;
            RETURN;
        END;

        BSC_SYS_IMAGES_MAP_PKG.UPDATE_ROW
        (
           X_SOURCE_TYPE       => BSC_SIMULATION_VIEW_PUB.c_INDICATOR_TYPE
          ,X_SOURCE_CODE       => p_obj_id
          ,X_TYPE              => BSC_SIMULATION_VIEW_PUB.c_TYPE
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
            ROLLBACK TO AddOrUpdateSimTreeBg;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_data := 'Insertion to BSC_SYS_IMAGES_PKG failed' || SQLERRM;
            RETURN;
        END;

        BSC_SYS_IMAGES_MAP_PKG.UPDATE_ROW
        (
           X_SOURCE_TYPE       => BSC_SIMULATION_VIEW_PUB.c_INDICATOR_TYPE
          ,X_SOURCE_CODE       => p_obj_id
          ,X_TYPE              => BSC_SIMULATION_VIEW_PUB.c_TYPE
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
      Create_Sim_Tree_bg (
        p_obj_id            => p_obj_id
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
      ROLLBACK TO AddOrUpdateSimTreeBg;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data      :=  SQLERRM;

END Add_Or_Update_Sim_Tree_Bg;





PROCEDURE Get_Objective_Details
(
    p_Region_Code       IN         AK_REGIONS.REGION_CODE%TYPE
   ,x_indicator         OUT NOCOPY VARCHAR2
   ,x_ind_group_id      OUT NOCOPY VARCHAR2
   ,x_tab_id            OUT NOCOPY VARCHAR2
   ,x_prototype_flag    OUT NOCOPY VARCHAR2
   ,x_ind_name          OUT NOCOPY VARCHAR2
   ,x_ytd_enabled       OUT NOCOPY VARCHAR2
   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER
   ,x_msg_data          OUT NOCOPY VARCHAR2
)IS
  l_count     NUMBER := 0;
BEGIN
  --DBMS_OUTPUT.PUT_LINE('entering -->'||l_count);
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --DBMS_OUTPUT.PUT_LINE('entering 1 -->'||l_count);

  x_indicator := NULL;
  x_ind_group_id := NULL;
  x_tab_id := NULL;
  x_prototype_flag := NULL;
  x_ind_name:=NULL;
  x_ytd_enabled:=NULL;

  IF(p_Region_Code IS NOT NULL)THEN

     SELECT COUNT(0)
     INTO   l_count
     FROM   bsc_kpis_b
     WHERE  SHORT_NAME = p_Region_Code;


     --DBMS_OUTPUT.PUT_LINE('l_count -->'||l_count);

     IF(l_count<>0)THEN

       SELECT a.INDICATOR
             ,a.ind_group_id
             ,b.tab_id
             ,a.prototype_flag
             ,a.name
             ,c.attribute21
       INTO   x_indicator
             ,x_ind_group_id
             ,x_tab_id
             ,x_prototype_flag
             ,x_ind_name
             ,x_ytd_enabled
       FROM  bsc_kpis_vl a,
             bsc_tab_indicators b,
             bis_ak_region_extension c
       WHERE a.short_name = c.region_code(+)
       AND   a.short_name = p_Region_Code
       AND   a.INDICATOR =b.INDICATOR(+)
       AND   a.prototype_flag<>2
       AND   a.share_flag<>2;

     END IF;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     --DBMS_OUTPUT.PUT_LINE('FND_API.G_EXC_ERROR  -->');
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.PUT_LINE('FND_API.G_EXC_UNEXPECTED_ERROR  -->');
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN
        --DBMS_OUTPUT.PUT_LINE('FND_API.NO_DATA_FOUND  -->');
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Get_Objective_Details ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Get_Objective_Details ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
        --DBMS_OUTPUT.PUT_LINE('FND_API.OTHERS  -->');
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Get_Objective_Details ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Get_Objective_Details ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Get_Objective_Details;


PROCEDURE add_or_update_measure
(
   p_tab_id               IN    NUMBER
  ,p_tab_view_id          IN    NUMBER
  ,p_text_object_id       IN    NUMBER
  ,p_text_flag            IN    NUMBER
  ,p_font_size            IN    NUMBER
  ,p_font_style           IN    NUMBER
  ,p_font_color           IN    NUMBER
  ,p_text_left            IN    NUMBER
  ,p_text_top             IN    NUMBER
  ,p_text_width           IN    NUMBER
  ,p_text_height          IN    NUMBER
  ,p_slider_object_id     IN    NUMBER
  ,p_slider_flag          IN    NUMBER
  ,p_slider_left          IN    NUMBER
  ,p_slider_top           IN    NUMBER
  ,p_slider_width         IN    NUMBER
  ,p_slider_height        IN    NUMBER
  ,p_actual_object_id     IN    NUMBER
  ,p_actual_flag          IN    NUMBER
  ,p_actual_left          IN    NUMBER
  ,p_actual_top           IN    NUMBER
  ,p_actual_width         IN    NUMBER
  ,p_actual_height        IN    NUMBER
  ,p_change_object_id     IN    NUMBER
  ,p_change_flag          IN    NUMBER
  ,p_change_left          IN    NUMBER
  ,p_change_top           IN    NUMBER
  ,p_change_width         IN    NUMBER
  ,p_change_height        IN    NUMBER
  ,p_color_object_id      IN    NUMBER
  ,p_color_flag           IN    NUMBER
  ,p_color_left           IN    NUMBER
  ,p_color_top            IN    NUMBER
  ,p_color_width          IN    NUMBER
  ,p_color_height         IN    NUMBER
  ,p_indicator_id         IN    NUMBER
  ,p_function_id          IN    NUMBER
  ,p_Node_Id              IN    NUMBER
  ,p_Node_Name            IN    VARCHAR2
  ,p_Node_Help            IN    VARCHAR2
  ,p_SimulateFlag         IN    NUMBER
  ,p_Format_id            IN    NUMBER
  ,p_Node_Color_flag      IN    NUMBER
  ,p_Node_Color_method    IN    NUMBER
  ,p_Navigates_to_trend   IN    NUMBER
  ,p_Top_position         IN    NUMBER
  ,p_Left_position        IN    NUMBER
  ,p_Width                IN    NUMBER
  ,p_Height               IN    NUMBER
  ,p_Autoscale_flag       IN    NUMBER
  ,p_Y_axis_title         IN    VARCHAR2
  ,p_Node_Attr_Code       IN    VARCHAR2
  ,p_Node_Short_Name      IN    VARCHAR2
  ,p_default_node         IN    NUMBER
  ,p_color_thresholds     IN    VARCHAR2
  ,p_color_by_total       IN    NUMBER
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
) IS
  l_count         NUMBER;
  l_dataset_id    BSC_SYS_DATASETS_B.dataset_id%TYPE;
BEGIN
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_dataset_id :=  p_indicator_id;
  IF(p_SimulateFlag=BSC_SIMULATION_VIEW_PUB.c_NON_SIM_NODE AND p_Node_Id =BSC_SIMULATION_VIEW_PUB.c_DEFAULT_SIM_NODE_ID)THEN
     l_dataset_id := BSC_BIS_KPI_CRUD_PUB.Get_Dataset_Id(p_Node_Short_Name);
  END IF;

  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_measure
  (
    p_tab_id             => p_tab_id
   ,p_tab_view_id        => p_tab_view_id
   ,p_text_object_id     => p_text_object_id
   ,p_text_flag          => p_text_flag
   ,p_font_size          => p_font_size
   ,p_font_style         => p_font_style
   ,p_font_color         => p_font_color
   ,p_text_left          => p_text_left
   ,p_text_top           => p_text_top
   ,p_text_width         => p_text_width
   ,p_text_height        => p_text_height
   ,p_slider_object_id   => p_slider_object_id
   ,p_slider_flag        => p_slider_flag
   ,p_slider_left        => p_slider_left
   ,p_slider_top         => p_slider_top
   ,p_slider_width       => p_slider_width
   ,p_slider_height      => p_slider_height
   ,p_actual_object_id   => p_actual_object_id
   ,p_actual_flag        => p_actual_flag
   ,p_actual_left        => p_actual_left
   ,p_actual_top         => p_actual_top
   ,p_actual_width       => p_actual_width
   ,p_actual_height      => p_actual_height
   ,p_change_object_id   => p_change_object_id
   ,p_change_flag        => p_change_flag
   ,p_change_left        => p_change_left
   ,p_change_top         => p_change_top
   ,p_change_width       => p_change_width
   ,p_change_height      => p_change_height
   ,p_indicator_id       => l_dataset_id
   ,p_function_id        => p_function_id
   ,x_return_status      => x_return_status
   ,x_msg_count          => x_msg_count
   ,x_msg_data           => x_msg_data
  );

  IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS)THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

 --save the color into BSC_TAB_VIEW_LABELS table

  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view_label
  (
      p_tab_id          => p_tab_id
    , p_tab_view_id     => p_tab_view_id
    , p_object_id       => p_color_object_id
    , p_object_type     => BSC_SIMULATION_VIEW_PUB.C_TYPE_MEASURE_COLOR
    , p_label_text      => BSC_SIMULATION_VIEW_PUB.C_MEASURE_COLOR
    , p_text_flag       => p_color_flag
    , p_font_color      => p_font_color
    , p_font_size       => p_font_size
    , p_font_style      => p_font_style
    , p_left            => p_color_left
    , p_top             => p_color_top
    , p_width           => p_color_width
    , p_height          => p_color_height
    , p_note_text       => NULL
    , p_link_id         => l_dataset_id
    , p_function_id     => p_function_id
    , x_return_status   => x_return_status
    , x_msg_count       => x_msg_count
    , x_msg_data        => x_msg_data
  );

  IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS)THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

 --Now save the node properties

  BSC_SIMULATION_VIEW_PUB.add_or_update_sim_node_props
  (
     p_indicator            =>  p_tab_view_id
    ,p_Node_Id              =>  l_dataset_id
    ,p_Node_Name            =>  p_Node_Name
    ,p_Node_Help            =>  p_Node_Help
    ,p_SimulateFlag         =>  p_SimulateFlag
    ,p_Format_id            =>  p_Format_id
    ,p_Color_flag           =>  p_Node_Color_flag
    ,p_Color_method         =>  p_Node_Color_method
    ,p_Navigates_to_trend   =>  p_Navigates_to_trend
    ,p_Top_position         =>  p_Top_position
    ,p_Left_position        =>  p_Left_position
    ,p_Width                =>  p_Width
    ,p_Height               =>  p_Height
    ,p_Autoscale_flag       =>  p_Autoscale_flag
    ,p_Y_axis_title         =>  p_Y_axis_title
    ,p_Node_Attr_Code       =>  p_Node_Attr_Code
    ,p_Node_Short_Name      =>  p_Node_Short_Name
    ,x_return_status        =>  x_return_status
    ,x_msg_count            =>  x_msg_count
    ,x_msg_data             =>  x_msg_data
  );

  IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS)THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

 --Change the default node and set the objective to
  -- the color change
   BSC_SIMULATION_VIEW_PUB.set_default_node
   (
      p_indicator      =>  p_tab_view_id
     ,p_default_node   =>  p_default_node
     ,p_dataset_id     =>  l_dataset_id
     ,x_return_status  =>  x_return_status
     ,x_msg_count      =>  x_msg_count
     ,x_msg_data       =>  x_msg_data
   );
   IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS)THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   BSC_SIMULATION_VIEW_PUB.Save_Color_Ranges
   (
       p_indicator      =>  p_tab_view_id
      ,p_dataset_id     =>  l_dataset_id
      ,p_color_ranges   =>  p_color_thresholds
      ,x_return_status  =>  x_return_status
      ,x_msg_count      =>  x_msg_count
      ,x_msg_data       =>  x_msg_data
   );
   IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS)THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  --We need to set the color_flag in bsc_kpi_measure_props
   --

   IF(p_SimulateFlag=BSC_SIMULATION_VIEW_PUB.c_NON_SIM_NODE)THEN

     BSC_SIMULATION_VIEW_PVT.Set_Kpi_Color_Method
     (
        p_indicator       =>   p_tab_view_id
       ,p_dataset_id      =>   l_dataset_id
       ,p_color_method    =>   p_Node_Color_method
       ,x_return_status   =>   x_return_status
       ,x_msg_count       =>   x_msg_count
       ,x_msg_data        =>   x_msg_data

     );
     IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS)THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

   BSC_SIMULATION_VIEW_PVT.Set_Kpi_Color_Flag
   (
       p_indicator       =>  p_tab_view_id
      ,p_dataset_id      =>  l_dataset_id
      ,p_color_flag      =>  p_Node_Color_flag
      ,p_color_by_total  =>  p_color_by_total
      ,x_return_status   =>  x_return_status
      ,x_msg_count       =>  x_msg_count
      ,x_msg_data        =>  x_msg_data

   );
   IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS)THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  BSC_SIMULATION_VIEW_PVT.Set_Ak_Format_Id
  (
    p_indicator     => p_tab_view_id
   ,p_dataset_Id    => l_dataset_id
   ,p_format_Id     => p_Format_id
   ,x_return_status => x_return_status
   ,x_msg_count     => x_msg_count
   ,x_msg_data      => x_msg_data
  );

  IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS)THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.add_or_update_measure ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.add_or_update_measure ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.add_or_update_measure ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.add_or_update_measure ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END add_or_update_measure;


PROCEDURE add_or_update_sim_node_props
(
    p_indicator          IN NUMBER
   ,p_Node_Id            IN NUMBER
   ,p_Node_Name          IN VARCHAR2
   ,p_Node_Help          IN VARCHAR2
   ,p_SimulateFlag       IN NUMBER
   ,p_Format_id          IN NUMBER
   ,p_Color_flag         IN NUMBER
   ,p_Color_method       IN NUMBER
   ,p_Navigates_to_trend IN NUMBER
   ,p_Top_position       IN NUMBER
   ,p_Left_position      IN NUMBER
   ,p_Width              IN NUMBER
   ,p_Height             IN NUMBER
   ,p_Autoscale_flag     IN NUMBER
   ,p_Y_axis_title       IN VARCHAR2
   ,p_Node_Attr_Code     IN VARCHAR2
   ,p_Node_Short_Name    IN VARCHAR2
   ,x_return_status      OUT NOCOPY VARCHAR2
   ,x_msg_count          OUT NOCOPY NUMBER
   ,x_msg_data           OUT NOCOPY VARCHAR2
) IS
 l_str                VARCHAR2(100);
 l_count              NUMBER;

BEGIN
  SAVEPOINT addorupdatesimnodeprops;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Node id will be the same as the dataset id
  --There cannot be two nodes whose dataset_ids are same.

  SELECT COUNT(1)
  INTO  l_count
  FROM  bsc_kpi_tree_nodes_vl
  WHERE indicator = p_indicator
  AND   node_id =p_Node_Id;

  IF (l_count = 0) THEN

    BSC_KPI_TREE_NODES_PKG.INSERT_ROW
    (
       X_ROWID              => l_str
      ,X_INDICATOR          => p_indicator
      ,X_NODE_ID            => p_Node_Id
      ,X_SIMULATE_FLAG      => p_SimulateFlag
      ,X_FORMAT_ID          => p_Format_id
      ,X_COLOR_FLAG         => p_Color_flag
      ,X_COLOR_METHOD       => p_Color_method
      ,X_NAVIGATES_TO_TREND => p_Navigates_to_trend
      ,X_TOP_POSITION       => p_Top_position
      ,X_LEFT_POSITION      => p_Left_position
      ,X_WIDTH              => p_Width
      ,X_HEIGHT             => p_Height
      ,X_NAME               => p_Node_Name
      ,X_HELP               => p_Node_Name  --Right now node help will be same
      ,X_Y_AXIS_TITLE       => p_Y_axis_title
    );
  ELSE
    BSC_KPI_TREE_NODES_PKG.UPDATE_ROW
    (
        X_INDICATOR          => p_indicator
       ,X_NODE_ID            => p_Node_Id
       ,X_SIMULATE_FLAG      => p_SimulateFlag
       ,X_FORMAT_ID          => p_Format_id
       ,X_COLOR_FLAG         => p_Color_flag
       ,X_COLOR_METHOD       => p_Color_method
       ,X_NAVIGATES_TO_TREND => p_Navigates_to_trend
       ,X_TOP_POSITION       => p_Top_position
       ,X_LEFT_POSITION      => p_Left_position
       ,X_WIDTH              => p_Width
       ,X_HEIGHT             => p_Height
       ,X_NAME               => p_Node_Name
       ,X_HELP               => p_Node_Name
       ,X_Y_AXIS_TITLE       => p_Y_axis_title
    );

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO addorupdatesimnodeprops;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := SQLERRM;
END add_or_update_sim_node_props;


PROCEDURE set_default_node
(
    p_indicator       IN         NUMBER
   ,p_default_node    IN         NUMBER
   ,p_dataset_id      IN         NUMBER
   ,x_return_status   OUT NOCOPY VARCHAR2
   ,x_msg_count       OUT NOCOPY NUMBER
   ,x_msg_data        OUT NOCOPY VARCHAR2
)IS
  l_prev_default_node     NUMBER;
  l_count                 NUMBER;
BEGIN
   BSC_SIMULATION_VIEW_PVT.set_default_node
    (
        p_indicator       => p_indicator
       ,p_default_node    => p_default_node
       ,p_dataset_id      => p_dataset_id
       ,x_return_status   => x_return_status
       ,x_msg_count       => x_msg_count
       ,x_msg_data        => x_msg_data
    ) ;

  IF(x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.set_default_node ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.set_default_node ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.set_default_node ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.set_default_node ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END set_default_node;


/*************************************************
c_type_measure        CONSTANT NUMBER := 10;
c_type_measure_actual CONSTANT NUMBER := 11;
c_type_measure_change CONSTANT NUMBER := 12;
c_type_measure_slider CONSTANT NUMBER := 14;
c_type_measure_color  CONSTANT NUMBER := 16;
/*************************************************/

PROCEDURE remove_simulation_view_items
(
  p_tab_id           IN         NUMBER
 ,p_obj_Id           IN         NUMBER
 ,p_labels           IN         VARCHAR2
 ,x_return_status    OUT NOCOPY VARCHAR2
 ,x_msg_count        OUT NOCOPY NUMBER
 ,x_msg_data         OUT NOCOPY VARCHAR2
)IS

  TYPE index_table_type IS TABLE OF NUMBER INDEX BY binary_integer;
  l_lables_table   index_table_type;

  l_id             NUMBER;
  l_labels         VARCHAR2(8000);
  l_links_table    BSC_UTILITY.varchar_tabletype;
  l_index          NUMBER;
  l_measure_type   BIS_INDICATORS.measure_type%TYPE;
  l_range_id       NUMBER;
  l_dataset_id     BIS_INDICATORS.dataset_id%TYPE;
  l_Anal_Opt_Rec   BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
  l_default_node   bsc_kpi_properties.property_value%TYPE;
  l_count          NUMBER;


  CURSOR label_cur IS
  SELECT label_id,label_type,link_id
  FROM bsc_tab_view_labels_vl
  WHERE tab_id = p_tab_id
  AND tab_view_id = p_obj_Id;

  CURSOR measure_cur IS
  SELECT measure_type
  FROM   bis_indicators
  WHERE  dataset_id = l_dataset_id;


  CURSOR c_default IS
  SELECT property_value
  FROM   bsc_kpi_properties
  WHERE  indicator = p_obj_Id
  AND    property_code =BSC_SIMULATION_VIEW_PUB.c_SIM_NODE_ID;

  l_label_cur      label_cur%ROWTYPE;

BEGIN

 --SET INDICATOR TO PROTOTYPE MODE IF ANY OF THE BASE MEASURES ARE REMOVED.
 --Before deleting label get the label type and check if it is labeltype is with --in the range of (10,11,12,14,13)
 -- if it is then get the link id for it and delete the corresponding entry from
 -- BSC_KPI_TREE_NODES_VL
  SAVEPOINT removesimviewitems;
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_labels := p_labels;

  WHILE (Is_More(p_list_ids => l_labels, p_id => l_id))
  LOOP
    l_lables_table(l_id) := 1;
  END LOOP;

  l_index := 0;

  FOR l_label_cur IN label_cur LOOP
    IF (l_lables_table.exists(l_label_cur.label_id) = FALSE) THEN
        IF(l_label_cur.label_type =BSC_CUSTOM_VIEW_UI_WRAPPER.c_type_measure)THEN
          l_links_table(l_index):=l_label_cur.link_id;
          l_index := l_index +1;
        END IF;

        BSC_TAB_VIEW_LABELS_PKG.DELETE_ROW
        (
           X_TAB_ID      => p_tab_id
          ,X_TAB_VIEW_ID => p_obj_Id
          ,X_LABEL_ID    => l_label_cur.label_id
        );
    END IF;
  END LOOP;

  -- now delete the entries from BSC_KPI_TREE_NODES_B/TL tables

  IF(l_index<>0)THEN
      FOR cd IN 0..l_index-1 LOOP

        BSC_KPI_TREE_NODES_PKG.DELETE_ROW
        (
           X_INDICATOR  => p_obj_Id
          ,X_NODE_ID    => l_links_table(cd)
        );

         l_dataset_id := l_links_table(cd);
         FOR cd IN measure_cur LOOP

          IF(cd.measure_type IS NULL)THEN
            BSC_DESIGNER_PVT.ActionFlag_Change(p_obj_Id, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
          END IF;
         END LOOP;
       END LOOP;
  END IF;

  --Delete the color ranges for the deleted measures from the objective
 l_Anal_Opt_Rec.Bsc_Kpi_Id := p_obj_Id;

 BSC_ANALYSIS_OPTION_PUB.Cascade_Deletion_Color_Props
  (
     p_commit           =>  FND_API.G_FALSE
    ,p_Anal_Opt_Rec     =>  l_Anal_Opt_Rec
    ,x_return_status    =>  x_return_status
    ,x_msg_count        =>  x_msg_count
    ,x_msg_data         =>  x_msg_data
  ) ;
 IF (x_return_status IS NOT NULL AND x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
   RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;


 --Now we will check if the default node was deleted or not.
 --if yes then we will set the default node back to -1

  FOR cd IN c_default LOOP
    l_default_node := cd.property_value;
    SELECT COUNT(0)
    INTO   l_count
    FROM   bsc_kpi_tree_nodes_b
    WHERE  indicator =p_obj_Id;

    IF(l_count=0) THEN
       BSC_SIMULATION_VIEW_PUB.set_default_node
       (
         p_indicator       =>  p_obj_Id
        ,p_default_node    =>  1
        ,p_dataset_id      =>  BSC_SIMULATION_VIEW_PUB.c_DEFAULT_DATASET_ID
        ,x_return_status   =>  x_return_status
        ,x_msg_count       =>  x_msg_count
        ,x_msg_data        =>  x_msg_data
      );

      IF (x_return_status IS NOT NULL AND x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
   END IF;
  END LOOP;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO removesimviewitems;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO removesimviewitems;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN
      ROLLBACK TO removesimviewitems;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.remove_simulation_view_items ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.remove_simulation_view_items ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     ROLLBACK TO removesimviewitems;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.remove_simulation_view_items ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.remove_simulation_view_items ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END remove_simulation_view_items;


PROCEDURE Duplicate_kpi_metadata
(
   p_source_kpi         IN        NUMBER
  ,p_target_kpi         IN        NUMBER
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
)IS
BEGIN
  SAVEPOINT Duplicatekpimetadata;
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --We need to copy the source indicator data from the following tables
  --BSC_SYS_IMAGES
  --BSC_SYS_IMAGES_MAP_TL
  --BSC_KPI_TREE_NODES
  --BSC_TAB_VIEW_LABELS_B/TL

  --First validate if both the indicators are valid or not
    BSC_BIS_LOCKS_PUB.LOCK_KPI
    (      p_Kpi_Id             =>  p_source_kpi
       ,   p_time_stamp         =>  NULL
       ,   p_Full_Lock_Flag     =>  FND_API.G_FALSE
       ,   x_return_status      =>  x_return_status
       ,   x_msg_count          =>  x_msg_count
       ,   x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_SIMULATION_VIEW_PVT.Duplicate_sim_metadata
    (
        p_source_kpi      =>  p_source_kpi
       ,p_target_kpi      =>  p_target_kpi
       ,x_return_status   =>  x_return_status
       ,x_msg_count       =>  x_msg_count
       ,x_msg_data        =>  x_msg_data
    );

    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Duplicatekpimetadata;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Duplicatekpimetadata;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN
      ROLLBACK TO Duplicatekpimetadata;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Duplicate_kpi_metadata ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Duplicate_kpi_metadata ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     ROLLBACK TO Duplicatekpimetadata;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Duplicate_kpi_metadata ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Duplicate_kpi_metadata ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Duplicate_kpi_metadata;


PROCEDURE Validate_Name_In_Tab
(
   p_name             IN          VARCHAR2
  ,p_tabId            IN          NUMBER
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
)IS
l_same_name      NUMBER;
BEGIN

  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  SELECT COUNT(0)
  INTO   l_same_name
  FROM   bsc_tab_indicators
  WHERE  tab_id = p_tabId
  AND   indicator IN (SELECT indicator
                      FROM BSC_KPIS_TL
                      WHERE UPPER(name) = UPPER(p_name));
 -- if there are kpis in this tab which have the same name it throws an error.
 IF l_same_name <> 0 then
     FND_MESSAGE.SET_NAME('BSC','BSC_B_NO_SAMEKPI_TAB');
     FND_MESSAGE.SET_TOKEN('Indicator name: ', p_name);
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
 END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Validate_Name_In_Tab ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Validate_Name_In_Tab ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Validate_Name_In_Tab ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Validate_Name_In_Tab ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);


END Validate_Name_In_Tab;


PROCEDURE Add_Or_Update_YTD
(
   p_indicator            IN      NUMBER
  ,p_YTD                  IN      VARCHAR2
  ,p_prev_YTD             IN      VARCHAR2
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
) IS
BEGIN
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_SIMULATION_VIEW_PVT.Add_Or_Update_YTD
  (
     p_indicator       =>  p_indicator
    ,p_YTD             =>  p_YTD
    ,p_prev_YTD        =>  p_prev_YTD
    ,x_return_status   =>  x_return_status
    ,x_msg_count       =>  x_msg_count
    ,x_msg_data        =>  x_msg_data
  );
  IF(x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
   RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Add_Or_Update_YTD ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Add_Or_Update_YTD ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Add_Or_Update_YTD ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Add_Or_Update_YTD ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Add_Or_Update_YTD;


PROCEDURE Save_Color_Ranges
(
   p_indicator       IN          NUMBER
  ,p_dataset_id      IN          NUMBER
  ,p_color_ranges    IN          VARCHAR2
  ,x_return_status   OUT NOCOPY  VARCHAR2
  ,x_msg_count       OUT NOCOPY  NUMBER
  ,x_msg_data        OUT NOCOPY  VARCHAR2
)IS
 l_kpi_measure_id                  bsc_kpi_analysis_measures_b.kpi_measure_id%TYPE;
 l_count                           NUMBER;
 l_Bsc_Kpi_Color_Range_Rec         BSC_COLOR_RANGES_PUB.Bsc_Color_Range_Rec;
 l_Bsc_Kpi_Color_Range_New_Rec     BSC_COLOR_RANGES_PUB.Bsc_Color_Range_Rec;
 l_color_ranges_changed            VARCHAR2(2) := FND_API.G_FALSE;

 CURSOR c_color_ranges IS
 SELECT a.color_range_sequence,a.low,a.high,a.color_id
 FROM   bsc_color_ranges a,
        bsc_color_type_props b
 WHERE  a.color_range_id =b.color_range_id
 AND    b.INDICATOR=p_indicator
 AND    b.kpi_measure_id =l_kpi_measure_id
 ORDER BY a.color_range_sequence;

BEGIN
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_kpi_measure_id := BSC_SIMULATION_VIEW_PUB.Get_Kpi_Measure_Id
                      (
                          p_indicator     =>  p_indicator
                        , p_dataset_id    =>  p_dataset_id
                      );

  l_count :=0;
  FOR cd IN c_color_ranges LOOP
    l_Bsc_Kpi_Color_Range_Rec(l_count).color_range_sequence := cd.color_range_sequence;
    l_Bsc_Kpi_Color_Range_Rec(l_count).low                  := cd.low;
    l_Bsc_Kpi_Color_Range_Rec(l_count).high                 := cd.high;
    l_Bsc_Kpi_Color_Range_Rec(l_count).color_id             := cd.color_id;
    l_count := l_count + 1;
  END LOOP;

  BSC_COLOR_RANGES_PUB.Save_Color_Prop_Ranges
  (
     p_commit          =>  FND_API.G_FALSE
   , p_objective_id    =>  p_indicator
   , p_kpi_measure_id  =>  l_kpi_measure_id
   , p_color_type      =>  BSC_SIMULATION_VIEW_PUB.c_PERCENT_OF_TARGET
   , p_threshold_color =>  p_color_ranges
   , p_cascade_shared  =>  TRUE
   , p_time_stamp      =>  NULL
   , x_return_status   =>  x_return_status
   , x_msg_count       =>  x_msg_count
   , x_msg_data        =>  x_msg_data
  );

 IF(x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
   RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 l_count :=0;
 FOR cd IN c_color_ranges LOOP
   l_Bsc_Kpi_Color_Range_New_Rec(l_count).color_range_sequence := cd.color_range_sequence;
   l_Bsc_Kpi_Color_Range_New_Rec(l_count).low                  := cd.low;
   l_Bsc_Kpi_Color_Range_New_Rec(l_count).high                 := cd.high;
   l_Bsc_Kpi_Color_Range_New_Rec(l_count).color_id             := cd.color_id;
   l_count := l_count + 1;
 END LOOP;

 -- Now we need to compare both the old and new color ranges..
-- if they differ then we need to
  IF((l_Bsc_Kpi_Color_Range_Rec IS NOT NULL) AND (l_Bsc_Kpi_Color_Range_New_Rec IS NOT NULL)
     AND l_Bsc_Kpi_Color_Range_Rec.COUNT <> l_Bsc_Kpi_Color_Range_New_Rec.COUNT)THEN


      Set_Obj_Kpi_Prototype
      (
         p_indicator      =>  p_indicator
        ,p_dataset_id     =>  p_dataset_id
        ,x_return_status  =>  x_return_status
        ,x_msg_count      =>  x_msg_count
        ,x_msg_data       =>  x_msg_data
      );
      IF(x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


  ELSE
       FOR l_count IN 0..l_Bsc_Kpi_Color_Range_Rec.COUNT-1 LOOP
        IF((l_Bsc_Kpi_Color_Range_Rec(l_count).low <> l_Bsc_Kpi_Color_Range_New_Rec(l_count).low)
           OR (l_Bsc_Kpi_Color_Range_Rec(l_count).high <> l_Bsc_Kpi_Color_Range_New_Rec(l_count).high)) THEN
            l_color_ranges_changed :=  FND_API.G_TRUE;

         EXIT;
        END IF;
       END LOOP;

       IF(l_color_ranges_changed =FND_API.G_TRUE)THEN

          Set_Obj_Kpi_Prototype
          (
             p_indicator      =>  p_indicator
            ,p_dataset_id     =>  p_dataset_id
            ,x_return_status  =>  x_return_status
            ,x_msg_count      =>  x_msg_count
            ,x_msg_data       =>  x_msg_data
         );
         IF(x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.set_color_ranges ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.set_color_ranges ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.set_color_ranges ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.set_color_ranges ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END  Save_Color_Ranges;



FUNCTION Get_Kpi_Measure_Id
(
   p_indicator       IN          NUMBER
  ,p_dataset_id      IN          NUMBER
) RETURN NUMBER
IS
 l_kpi_measure_id      bsc_kpi_analysis_measures_b.kpi_measure_id%TYPE;
BEGIN

  SELECT kpi_measure_id
  INTO   l_kpi_measure_id
  FROM   bsc_kpi_analysis_measures_b
  WHERE  indicator = p_indicator
  AND    dataset_id = p_dataset_id;

  RETURN l_kpi_measure_id;
END Get_Kpi_Measure_Id;


PROCEDURE copy_sim_metadata
(
   p_source_kpi         IN        NUMBER
  ,p_target_kpi         IN        NUMBER
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
)IS
BEGIN

    BSC_SIMULATION_VIEW_PVT.copy_sim_metadata
    (
       p_source_kpi     => p_source_kpi
      ,p_target_kpi     => p_target_kpi
      ,x_return_status  => x_return_status
      ,x_msg_count      => x_msg_count
      ,x_msg_data       => x_msg_data
    );

   IF(x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.copy_sim_metadata ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.copy_sim_metadata ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.copy_sim_metadata ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.copy_sim_metadata ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END copy_sim_metadata;

/***************************************************
  Set_Sim_Key_Values : API is used to set the Key Items for
                       Simulation Tree objectives.
  Creator : ashankar 29-03-07
/***************************************************/

PROCEDURE Set_Sim_Key_Values
(
   p_ind_Sht_Name   IN          BSC_KPIS_B.short_name%TYPE
  ,p_indicator      IN          BSC_KPIS_B.indicator%TYPE
  ,x_return_status  OUT NOCOPY  VARCHAR2
  ,x_msg_count      OUT NOCOPY  NUMBER
  ,x_msg_data       OUT NOCOPY  VARCHAR2
) IS

  CURSOR c_shared_obj IS
  SELECT indicator
        ,short_name
  FROM  bsc_kpis_b
  WHERE prototype_flag<>2
  AND   share_flag =2
  AND   config_type =7
  AND   source_indicator = p_indicator;

BEGIN

    BSC_SIMULATION_VIEW_PVT.Set_Sim_Key_Values
    (
       p_ind_Sht_Name   => p_ind_Sht_Name
      ,p_indicator      => p_indicator
      ,x_return_status  => x_return_status
      ,x_msg_count      => x_msg_count
      ,x_msg_data       => x_msg_data
    );

    IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --/////////////Handle Shared Objectives /////////////

    --//First refresh the shared objectives from the master.
    BSC_SIMULATION_VIEW_PVT.Handle_Shared_Objectives
    (
       p_indicator      =>   p_indicator
      ,x_return_status  =>   x_return_status
      ,x_msg_count      =>   x_msg_count
      ,x_msg_data       =>   x_msg_data
    );
    IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FOR cd IN c_shared_obj LOOP
     BSC_SIMULATION_VIEW_PVT.Set_Sim_Key_Values
     (
        p_ind_Sht_Name   => cd.short_name
       ,p_indicator      => cd.indicator
       ,x_return_status  => x_return_status
       ,x_msg_count      => x_msg_count
       ,x_msg_data       => x_msg_data
     );

     IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
    END LOOP;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN

     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Set_Sim_Key_Values ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Set_Sim_Key_Values ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Set_Sim_Key_Values ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Set_Sim_Key_Values ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Set_Sim_Key_Values;

PROCEDURE Set_Obj_Kpi_Prototype
(
  p_indicator      IN          BSC_KPIS_B.indicator%TYPE
 ,p_dataset_id     IN          BSC_SYS_DATASETS_B.dataset_id%TYPE
 ,x_return_status  OUT NOCOPY  VARCHAR2
 ,x_msg_count      OUT NOCOPY  NUMBER
 ,x_msg_data       OUT NOCOPY  VARCHAR2

)IS

 CURSOR c_def_node IS
 SELECT property_value
 FROM   bsc_kpi_properties
 WHERE  indicator =p_indicator
 AND    property_code =BSC_SIMULATION_VIEW_PUB.c_SIM_NODE_ID;

 l_count               NUMBER;
 l_kpi_measure_id      bsc_kpi_analysis_measures_b.kpi_measure_id%TYPE;

BEGIN
   FND_MSG_PUB.INITIALIZE;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_kpi_measure_id := BSC_SIMULATION_VIEW_PUB.Get_Kpi_Measure_Id
                      (
                          p_indicator     =>  p_indicator
                        , p_dataset_id    =>  p_dataset_id
                      );

  BSC_KPI_COLOR_PROPERTIES_PUB.Kpi_Prototype_Flag_Change
  (
       p_objective_id    => p_indicator
     , p_kpi_measure_id  => l_kpi_measure_id
     , p_prototype_flag  => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
     , x_return_status   => x_return_status
     , x_msg_count       => x_msg_count
     , x_msg_data        => x_msg_data
  );

  IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
   RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FOR cd IN c_def_node LOOP
    IF(cd.property_value =p_dataset_id) THEN
       BSC_KPI_COLOR_PROPERTIES_PUB.Obj_Prototype_Flag_Change
       (
           p_objective_id   => p_indicator
         , p_prototype_flag => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
         , x_return_status  => x_return_status
         , x_msg_count      => x_msg_count
         , x_msg_data       => x_msg_data
       );
       IF(x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;
  END LOOP;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN

     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Set_Obj_Kpi_Prototype ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Set_Obj_Kpi_Prototype ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Set_Obj_Kpi_Prototype ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Set_Obj_Kpi_Prototype ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Set_Obj_Kpi_Prototype;

END BSC_SIMULATION_VIEW_PUB;

/
