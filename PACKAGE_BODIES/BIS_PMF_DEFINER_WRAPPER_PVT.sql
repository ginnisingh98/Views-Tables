--------------------------------------------------------
--  DDL for Package Body BIS_PMF_DEFINER_WRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMF_DEFINER_WRAPPER_PVT" AS
/* $Header: BISVPFJB.pls 120.0 2005/06/01 15:57:11 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVPFJB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |    Private API which can be called from Java Program for the          |
REM |    PMF definer.                                                       |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |                                                                       |
REM | JUL2000 jradhakr Creation                                             |
REM | AUG/SEP 2000 amkulkar Added Error Handling the ATG way                |
REM |                       Added CRUD wrapper for Targets                  |
REM |                       Made minor modifications as necessary           |
REM | MAR 2001              Added procedure to get target related details   |
REM |                       for the bean/JSP                                |
REM | Jun-05-2002           Fixed for bug#2405029(backward compatible issue)|
REM | 26-JUL-2002 rchandra  Fixed for enh 2440739                           |
REM | 23-JAN-03 sugopal For having different local variables for IN and OUT |
REM |                   parameters (bug#2758428)              	            |
REM | 30-JAN-03 sugopal FND_API.G_MISS_xxx should not be used in            |
REM |                   initialization or declaration (bug#2774644)         |
REM | 11-APR-03 sugopal	Not possible to update an existing value with null  |
REM |			in the Create/Update performance measures page -    |
REM |			modified Update_Performance_Measure for bug#2869324 |
REM | 01-MAR-04	gbhaloti Removed the default commit from measure security   |
REM |			 delete bug#3475674				    |
REM | 22-APR-2005 akoduri   Enhancement#3865711 -- Obsolete Seeded Objects  |
REM | 03-MAY-2005  akoduri  Enh #4268374 -- Weighted Average Measures       |
REM +=======================================================================+
*/
g_api_version   NUMBER := 1;
g_ampersand    VARCHAR2(100) := '&';

Procedure Create_Performance_Measure
(p_Measure_ID                 IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Measure_Short_Name         IN   VARCHAR2
,p_Measure_Name               IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Description                IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Dimension1_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension2_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension3_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension4_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension5_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension6_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension7_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Unit_Of_Measure_Class      IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
--Fix for 1850860 starts here
,p_actual_data_source_type    IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_actual_data_source         IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_function_name              IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_comparison_source          IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_increase_in_measure        IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
-- Fix for 1850860 ends here
,p_enable_link                IN   VARCHAR2 := c_hide_url -- 2440739
,p_obsolete                   IN   VARCHAR2 := FND_API.G_FALSE --3865711
,p_measure_Type                   IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_application_id             IN   NUMBER   := c_default_appl --2465354
,x_return_status                 OUT NOCOPY  VARCHAR2
,x_msg_count                  OUT NOCOPY  VARCHAR2
,x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
l_return_status   varchar2(32000);
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
l_measure_rec     BIS_MEASURE_PUB.Measure_rec_type;
l_ret             VARCHAR2(32000);
Begin
  FND_MSG_PUB.initialize;
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Measure_Short_Name);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Measure_Short_Name := p_Measure_Short_Name;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Measure_Name);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Measure_Name := p_Measure_Name;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Description);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Description := p_Description;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Dimension1_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Dimension1_ID := p_Dimension1_ID;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Dimension2_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Dimension2_ID := p_Dimension2_ID;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Dimension3_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Dimension3_ID := p_Dimension3_ID;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Dimension4_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Dimension4_ID := p_Dimension4_ID;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Dimension5_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Dimension5_ID := p_Dimension5_ID;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Dimension6_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Dimension6_ID := p_Dimension6_ID;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Dimension7_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Dimension7_ID := p_Dimension7_ID;
  END IF;

  -----
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Unit_Of_Measure_Class);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Unit_Of_Measure_Class := p_Unit_Of_Measure_Class;
  END IF;

--Fix for 1850860 starts here
   l_ret := BIS_UTILITIES_PUB.Value_Missing(p_actual_data_source_type);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.actual_data_source_type := p_actual_data_source_type;
  END IF;
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_actual_data_source);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.actual_data_source := p_actual_data_source;
  END IF;
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_function_name);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.function_name := p_function_name;
  END IF;
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_comparison_source);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.comparison_source := p_comparison_source;
  END IF;
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_increase_in_measure);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.increase_in_measure := p_increase_in_measure;
  END IF;
-- Fix for 1850860 ends here
-- 2440739
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_enable_link);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.enable_link := p_enable_link;
  END IF;
-- 2440739
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_obsolete);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.obsolete := p_obsolete;
  END IF;
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_measure_type);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.measure_type := p_measure_type;
  END IF;

  l_measure_rec.Application_Id := p_application_id ; --2465354
  BIS_MEASURE_PUB.Create_Measure( p_api_version   => g_api_version
                                , p_commit        => fnd_api.G_TRUE
                                , p_Measure_Rec   => l_measure_rec
                                , x_return_status => l_return_status
                                , x_error_tbl     => l_error_tbl
                                );
/*  if l_error_tbl.COUNT > 0
  then
    for i in 1..l_error_tbl.COUNT
    loop
       null;
     --    dbms_output.put_line('Error_Msg_ID :' || l_error_tbl(i).Error_Msg_ID);
     --    dbms_output.put_line('Error_Msg_Name :'||  l_error_tbl(i).Error_Msg_Name);
    --     dbms_output.put_line('Error_Description :'||  l_error_tbl(i).Error_Description);
    end loop;
   end if;*/

-- Fix for 2254597 starts here

   x_return_status := l_return_status;

   BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
   (p_error_tbl       => l_error_tbl
   ,x_return_status   => l_return_status
   ,x_msg_count       => x_msg_count
   ,x_msg_data        => x_msg_data
   );


/*
  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
  (p_error_tbl   => l_error_tbl
  ,x_return_status  => x_return_status
  ,x_msg_count     => x_msg_count
  ,x_msg_data      => x_msg_data
  );
*/
-- Fix for 2254597 ends here

END Create_Performance_Measure;

--
Procedure Update_Performance_Measure(
             p_Measure_ID                 IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
           , p_Measure_Short_Name         IN   VARCHAR2
           , p_Measure_Name               IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
           , p_Description                IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
           , p_Dimension1_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
           , p_Dimension2_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
           , p_Dimension3_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
           , p_Dimension4_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
           , p_Dimension5_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
           , p_Dimension6_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
           , p_Dimension7_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
           , p_Unit_Of_Measure_Class      IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
-- Fix for 1850860 starts here
           , p_actual_data_source_type    IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
           , p_actual_data_source         IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
           , p_function_name              IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
           , p_comparison_source          IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
           , p_increase_in_measure        IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
-- Fix for 1850860 ends here
           , p_enable_link                IN   VARCHAR2 := c_hide_url  -- 2440739
           , p_obsolete                   IN   VARCHAR2 := FND_API.G_FALSE --3865711
	   , p_measure_type               IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
           , p_application_id             IN   NUMBER   := c_default_appl -- 2465354
           , x_return_status              OUT NOCOPY  VARCHAR2
           , x_msg_count                  OUT NOCOPY  VARCHAR2
           , x_msg_data                   OUT NOCOPY  VARCHAR2
           )
IS

l_return_status   varchar2(32000);
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
l_measure_rec     BIS_MEASURE_PUB.Measure_rec_type;

Begin
  FND_MSG_PUB.initialize;

  l_measure_rec.Measure_ID := p_Measure_ID;
  l_measure_rec.Measure_Short_Name := p_Measure_Short_Name;
  l_measure_rec.Measure_Name := p_Measure_Name;
  l_measure_rec.Description := p_Description;
  l_measure_rec.Dimension1_ID := p_Dimension1_ID;
  l_measure_rec.Dimension2_ID := p_Dimension2_ID;
  l_measure_rec.Dimension3_ID := p_Dimension3_ID;
  l_measure_rec.Dimension4_ID := p_Dimension4_ID;
  l_measure_rec.Dimension5_ID := p_Dimension5_ID;
  l_measure_rec.Dimension6_ID := p_Dimension6_ID;
  l_measure_rec.Dimension7_ID := p_Dimension7_ID;
  l_measure_rec.Unit_Of_Measure_Class := p_Unit_Of_Measure_Class;
  l_measure_rec.actual_data_source_type := p_actual_data_source_type;
  l_measure_rec.actual_data_source := p_actual_data_source;
  l_measure_rec.function_name := p_function_name;
  l_measure_rec.comparison_source := p_comparison_source;
  l_measure_rec.increase_in_measure := p_increase_in_measure;
  l_measure_rec.enable_link := p_enable_link;
  l_measure_rec.obsolete := p_obsolete;
  l_measure_rec.measure_type := p_measure_type;
  l_measure_rec.Application_Id := p_application_id ; --2465354

  BIS_MEASURE_PUB.Update_Measure( p_api_version   => g_api_version
                                , p_commit        => fnd_api.G_TRUE
                                , p_Measure_Rec   => l_measure_rec
                                , x_return_status => l_return_status
                                , x_error_tbl     => l_error_tbl
                                );

  /*if l_error_tbl.COUNT > 0
  then
    for i in 1..l_error_tbl.COUNT
    loop
       null;
       --  dbms_output.put_line('Error_Msg_ID :' || l_error_tbl(i).Error_Msg_ID);
       --  dbms_output.put_line('Error_Msg_Name :'||  l_error_tbl(i).Error_Msg_Name);
       --  dbms_output.put_line('Error_Description :'||  l_error_tbl(i).Error_Description);
    end loop;
   end if;*/

-- Fix for 2254597 starts here

   x_return_status := l_return_status;

   BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
   (p_error_tbl       => l_error_tbl
   ,x_return_status   => l_return_status
   ,x_msg_count       => x_msg_count
   ,x_msg_data        => x_msg_data
   );

/*
  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
  (p_error_tbl   => l_error_tbl
  ,x_return_status  => x_return_status
  ,x_msg_count     => x_msg_count
  ,x_msg_data      => x_msg_data
  );
*/
-- Fix for 2254597 ends here

END Update_Performance_Measure;

Procedure Delete_Performance_Measure(
             p_Measure_ID                 IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
           , p_Measure_Short_Name         IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
           ,x_return_status                 OUT NOCOPY  VARCHAR2
           ,x_msg_count                  OUT NOCOPY  VARCHAR2
           ,x_msg_data                   OUT NOCOPY  VARCHAR2
           )
IS

l_return_status   varchar2(32000);
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
l_measure_rec     BIS_MEASURE_PUB.Measure_rec_type;
l_ret             VARCHAR2(32000);
-- 2218333
l_msg_count       VARCHAR2(32000);
l_msg_data        VARCHAR2(32000);
-- 2218333
Begin
  FND_MSG_PUB.initialize;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Measure_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Measure_ID := p_Measure_ID;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Measure_Short_Name);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Measure_Short_Name := p_Measure_Short_Name;
  END IF;


  BIS_MEASURE_PUB.Delete_Measure( p_api_version   => g_api_version
                                , p_commit        => fnd_api.G_TRUE
                                , p_Measure_Rec   => l_measure_rec
                                , x_return_status => l_return_status
                                , x_error_tbl     => l_error_tbl
                                );

/*
-- 2218333

x_return_status := l_return_status;
x_msg_count     := l_error_tbl.count;
-- IF clause added as a fix for 2247923
  IF x_msg_count <> '0' THEN
    x_msg_data      := l_error_tbl(l_error_tbl.count).Error_Description;
  END IF;

-- 2218333
*/
  /*if l_error_tbl.COUNT > 0
  then
    for i in 1..l_error_tbl.COUNT
    loop
         --dbms_output.put_line('Error_Msg_ID :' || l_error_tbl(i).Error_Msg_ID);
         --dbms_output.put_line('Error_Msg_Name :'||  l_error_tbl(i).Error_Msg_Name);
         --dbms_output.put_line('Error_Description :'||  l_error_tbl(i).Error_Description);
         null;
    end loop;
   end if;*/
/*
  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
  (p_error_tbl   => l_error_tbl
  ,x_return_status   => x_return_status
  ,x_msg_count     => x_msg_count
  ,x_msg_data      => x_msg_data
  );
*/
-- Commented as a fix for 2247923
-- below code is commented for 2254597
/*
-- 2218333
  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
  (p_error_tbl   => l_error_tbl
  ,x_return_status   => l_return_status
  ,x_msg_count     => l_msg_count
  ,x_msg_data      => l_msg_data
  );
-- 2218333
*/
-- Fix for 2254597 starts here

   x_return_status := l_return_status;

   BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
   (p_error_tbl       => l_error_tbl
   ,x_return_status   => l_return_status
   ,x_msg_count       => x_msg_count
   ,x_msg_data        => x_msg_data
   );

-- Fix for 2254597 ends here

END Delete_Performance_Measure;

Procedure Delete_target_levels(
     P_TARGET_LEVEL_ID           IN NUMBER
   , p_force_delete              IN NUMBER := 0 --gbhaloti #3148615
   , P_TARGET_LEVEL_SHORT_NAME   IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
   ,x_return_status                 OUT NOCOPY  VARCHAR2
   ,x_msg_count                  OUT NOCOPY  VARCHAR2
   ,x_msg_data                   OUT NOCOPY  VARCHAR2
                      )
IS

l_return_status     varchar2(32000);
l_error_tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;
l_target_level_rec  BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_ret               VARCHAR2(32000);

Begin
    FND_MSG_PUB.initialize;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Id) = FND_API.G_FALSE) THEN
      l_target_level_rec.Target_Level_Id :=
                                    p_Target_Level_Id;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Short_Name) = FND_API.G_FALSE) THEN
      l_target_level_rec.Target_Level_Short_Name :=
                                    p_Target_Level_Short_Name;
    END IF;

    BIS_Target_Level_PVT.Delete_Target_Level
    ( p_api_version         => g_api_version
    , p_force_delete        => p_force_delete   --gbhaloti #3148615
    , p_commit              => fnd_api.G_TRUE
    , p_Target_Level_Rec    => l_Target_Level_Rec
    , x_return_status       => l_return_status
    , x_error_Tbl           => l_error_Tbl
    );
-- Fix for 2254597 starts here

   x_return_status := l_return_status;

   BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
   (p_error_tbl       => l_error_tbl
   ,x_return_status   => l_return_status
   ,x_msg_count       => x_msg_count
   ,x_msg_data        => x_msg_data
   );

/*
  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
  (p_error_tbl   => l_error_tbl
  ,x_return_status  => x_return_status
  ,x_msg_count     => x_msg_count
  ,x_msg_data      => x_msg_data
  );
*/
-- Fix for 2254597 ends here

end Delete_target_levels;


Procedure Update_target_levels(
     P_TARGET_LEVEL_ID           IN NUMBER
   , P_TARGET_LEVEL_SHORT_NAME   IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
   , P_TARGET_LEVEL_NAME         IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
   , P_DESCRIPTION               IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
   , P_MEASURE_ID                IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
   , P_DIMENSION1_LEVEL_ID       IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
   , P_DIMENSION2_LEVEL_ID       IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
   , P_DIMENSION3_LEVEL_ID       IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
   , P_DIMENSION4_LEVEL_ID       IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
   , P_DIMENSION5_LEVEL_ID       IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
   , P_DIMENSION6_LEVEL_ID       IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
   , P_DIMENSION7_LEVEL_ID       IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
   , P_WORKFLOW_ITEM_TYPE        IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
   , P_WORKFLOW_PROCESS_SHORT_NAME
                                 IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
   , P_DEFAULT_NOTIFY_RESP_ID
                                 IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
   , P_DEFAULT_NOT_RESP_SHORT_NAME
                                 IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
   , P_COMPUTING_FUNCTION_ID     IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
   , P_COMPUTING_FUNCTION_NAME   IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
   , P_REPORT_FUNCTION_ID        IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
   , P_UNIT_OF_MEASURE           IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
   , p_SOURCE                    IN VARCHAR2
   , p_IS_SEED_USER              IN VARCHAR2 := 'N' --2465354
   ,x_return_status              OUT NOCOPY  VARCHAR2
   ,x_msg_count                  OUT NOCOPY  VARCHAR2
   ,x_msg_data                   OUT NOCOPY  VARCHAR2

                      )
IS

l_return_status     varchar2(32000);
l_error_tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;
l_target_level_rec  BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_ret               VARCHAR2(32000);
l_owner             VARCHAR2(200); --2465354
Begin
    FND_MSG_PUB.initialize;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Id) = FND_API.G_FALSE) THEN
      l_target_level_rec.Target_Level_Id :=
                                    p_Target_Level_Id;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Short_Name) = FND_API.G_FALSE) THEN
      l_target_level_rec.Target_Level_Short_Name :=
                                    p_Target_Level_Short_Name;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Name) = FND_API.G_FALSE) THEN
      l_target_level_rec.Target_Level_Name :=
                                          p_Target_Level_Name;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Description) = FND_API.G_FALSE) THEN
      l_target_level_rec.Description := p_Description;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Measure_Id) = FND_API.G_FALSE) THEN
      l_target_level_rec.Measure_Id := p_Measure_Id;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Dimension1_Level_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Dimension1_Level_ID :=
                                        p_Dimension1_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Dimension2_Level_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Dimension2_Level_ID :=
                                        p_Dimension2_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Dimension3_Level_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Dimension3_Level_ID :=
                                        p_Dimension3_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Dimension4_Level_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Dimension4_Level_ID :=
                                        p_Dimension4_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Dimension5_Level_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Dimension5_Level_ID :=
                                        p_Dimension5_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Dimension6_Level_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Dimension6_Level_ID :=
                                        p_Dimension6_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Dimension7_Level_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Dimension7_Level_ID :=
                                        p_Dimension7_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
       (P_WORKFLOW_ITEM_TYPE) = FND_API.G_FALSE) THEN
      l_target_level_rec.Workflow_Item_type :=
                                P_WORKFLOW_ITEM_TYPE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
       (p_Workflow_Process_Short_Name) = FND_API.G_FALSE) THEN
      l_target_level_rec.Workflow_Process_Short_Name :=
                                p_Workflow_Process_Short_Name;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Default_Notify_Resp_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Default_Notify_Resp_ID :=
                                     p_Default_Notify_Resp_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
      (p_Default_Not_Resp_short_name)=FND_API.G_FALSE) THEN
      l_target_level_rec.Default_Notify_Resp_short_name :=
                             p_Default_Not_Resp_short_name;
    END IF;
    l_target_level_Rec.computing_function_id := p_computing_function_id;
    l_target_level_rec.report_function_id    := p_computing_function_id;
    l_target_level_rec.computing_function_name := p_computing_function_name;
    l_target_level_rec.unit_of_measure         := p_unit_of_measure;
   -- l_target_level_rec.Source         := 'EDW';
   ---------------
    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Source) = FND_API.G_FALSE) THEN
      l_target_level_rec.Source := p_Source;
    END IF;
 -----------------------------------
    -- 2465354
    IF ( p_IS_SEED_USER = 'Y' ) THEN
      l_owner := BIS_UTILITIES_PUB.G_SEED_OWNER ;
    ELSE
      l_owner := BIS_UTILITIES_PUB.G_CUSTOM_OWNER;
    END IF;
    -- 2465354

    BIS_Target_Level_PVT.Update_Target_Level
    ( p_api_version         => g_api_version
    , p_commit              => fnd_api.G_TRUE
    , p_Target_Level_Rec    => l_Target_Level_Rec
    , p_owner               => l_owner --2465354
    , x_return_status       => l_return_status
    , x_error_Tbl           => l_error_Tbl
    );
-- Fix for 2254597 starts here

   x_return_status := l_return_status;

   BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
   (p_error_tbl       => l_error_tbl
   ,x_return_status   => l_return_status
   ,x_msg_count       => x_msg_count
   ,x_msg_data        => x_msg_data
   );

/*
  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
  (p_error_tbl   => l_error_tbl
  ,x_return_status  => x_return_status
  ,x_msg_count     => x_msg_count
  ,x_msg_data      => x_msg_data
  );
*/
-- Fix for 2254597 ends here

end Update_target_levels;


Procedure Create_target_levels(
 P_TARGET_LEVEL_ID                    IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_TARGET_LEVEL_SHORT_NAME            IN VARCHAR2
,P_TARGET_LEVEL_NAME                  IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_DESCRIPTION                        IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_MEASURE_ID                         IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION1_LEVEL_ID                IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION2_LEVEL_ID                IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION3_LEVEL_ID                IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION4_LEVEL_ID                IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION5_LEVEL_ID                IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION6_LEVEL_ID                IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DIMENSION7_LEVEL_ID                IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_WORKFLOW_ITEM_TYPE                 IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_WORKFLOW_PROCESS_SHORT_NAME        IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_DEFAULT_NOTIFY_RESP_ID             IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_DEFAULT_NOT_RESP_SHORT_NAME        IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_COMPUTING_FUNCTION_ID              IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_COMPUTING_FUNCTION_NAME            IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_REPORT_FUNCTION_ID                 IN NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,P_UNIT_OF_MEASURE                    IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_SOURCE                             IN VARCHAR2
,p_IS_SEED_USER                       IN VARCHAR2 := 'N' --2465354
,x_return_status                      OUT NOCOPY  VARCHAR2
,x_msg_count                          OUT NOCOPY  VARCHAR2
,x_msg_data                           OUT NOCOPY  VARCHAR2
)
IS

l_return_status     varchar2(32000);
l_error_tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;
l_target_level_rec  BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_ret               VARCHAR2(32000);
l_time_seq_num      NUMBER;
l_org_seq_num       NUMBER;
l_dim_level_id      NUMBER;
l_dim_level_name    VARCHAR2(32000);
l_Dim_level_short_name   VARCHAR2(32000);
l_owner             VARCHAR2(200); --2465354
Begin
    FND_MSG_PUB.initialize;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Short_Name) = FND_API.G_FALSE) THEN
      l_target_level_rec.Target_Level_Short_Name :=
                                    p_Target_Level_Short_Name;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Name) = FND_API.G_FALSE) THEN
      l_target_level_rec.Target_Level_Name :=
                                          p_Target_Level_Name;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Description) = FND_API.G_FALSE) THEN
      l_target_level_rec.Description := p_Description;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Measure_Id) = FND_API.G_FALSE) THEN
      l_target_level_rec.Measure_Id := p_Measure_Id;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Dimension1_Level_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Dimension1_Level_ID :=
                                        p_Dimension1_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Dimension2_Level_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Dimension2_Level_ID :=
                                        p_Dimension2_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Dimension3_Level_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Dimension3_Level_ID :=
                                        p_Dimension3_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Dimension4_Level_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Dimension4_Level_ID :=
                                        p_Dimension4_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Dimension5_Level_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Dimension5_Level_ID :=
                                        p_Dimension5_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Dimension6_Level_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Dimension6_Level_ID :=
                                        p_Dimension6_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Dimension7_Level_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Dimension7_Level_ID :=
                                        p_Dimension7_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
       (P_WORKFLOW_ITEM_TYPE) = FND_API.G_FALSE) THEN
      l_target_level_rec.Workflow_Item_type :=
                                P_WORKFLOW_ITEM_TYPE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
       (p_Workflow_Process_Short_Name) = FND_API.G_FALSE) THEN
      l_target_level_rec.Workflow_Process_Short_Name :=
                                p_Workflow_Process_Short_Name;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Default_Notify_Resp_ID) = FND_API.G_FALSE) THEN
      l_target_level_rec.Default_Notify_Resp_ID :=
                                     p_Default_Notify_Resp_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
      (p_Default_Not_Resp_short_name)=FND_API.G_FALSE) THEN
      l_target_level_rec.Default_Notify_Resp_short_name :=
                             p_Default_Not_Resp_short_name;
    END IF;
    l_target_level_Rec.computing_function_id := p_computing_function_id;
    l_target_level_rec.report_function_id    := p_computing_function_id;
    l_target_level_rec.computing_function_name := p_computing_function_name;
    l_target_level_rec.unit_of_measure         := p_unit_of_measure;
  --  l_target_level_rec.Source         := 'EDW';
   ---------------
    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Source) = FND_API.G_FALSE) THEN
      l_target_level_rec.Source := p_Source;
    END IF;
 -----------------------------------
    BIS_PMF_DEFINER_WRAPPER_PVT.GET_TIME_LEVEL_ID
    (p_performance_measure_id    => p_measure_id
    ,p_target_level_id           => p_target_level_id
    ,p_perf_measure_short_name   => NULL
    ,p_target_level_short_name   => p_target_level_short_name
    ,p_source                    => p_source
    ,x_sequence_no               => l_time_seq_num
    ,x_dim_level_id              => l_dim_level_id
    ,x_dim_level_short_name      => l_dim_level_short_name
    ,x_dim_level_name            => l_dim_level_name
    ,x_return_status             => x_return_Status
    ,x_error_tbl                 => l_error_tbl
    );
    IF (l_time_seq_num = 1)
    THEN
        l_target_level_rec.time_level_id := p_dimension1_level_id;
    END IF;
    IF (l_time_seq_num = 2)
    THEN
        l_target_level_rec.time_level_id := p_dimension2_level_id;
    END IF;
    IF (l_time_seq_num = 3)
    THEN
        l_target_level_rec.time_level_id := p_dimension3_level_id;
    END IF;
    IF (l_time_seq_num = 4)
    THEN
        l_target_level_rec.time_level_id := p_dimension4_level_id;
    END IF;
    IF (l_time_seq_num = 5)
    THEN
        l_target_level_rec.time_level_id := p_dimension5_level_id;
    END IF;
    IF (l_time_seq_num = 6)
    THEN
        l_target_level_rec.time_level_id := p_dimension6_level_id;
    END IF;
    IF (l_time_seq_num = 7)
    THEN
        l_target_level_rec.time_level_id := p_dimension7_level_id;
    END IF;

    BIS_PMF_DEFINER_WRAPPER_PVT.GET_ORG_LEVEL_ID
    (p_performance_measure_id    => p_measure_id
    ,p_target_level_id           => p_target_level_id
    ,p_perf_measure_short_name   => NULL
    ,p_target_level_short_name   => p_target_level_short_name
    ,p_source                    => p_source
    ,x_sequence_no               => l_org_seq_num
    ,x_dim_level_id              => l_dim_level_id
    ,x_dim_level_short_name      => l_dim_level_short_name
    ,x_dim_level_name            => l_dim_level_name
    ,x_return_status             => x_return_Status
    ,x_error_tbl                 => l_error_tbl
    );
    IF (l_org_seq_num = 1)
    THEN
        l_target_level_Rec.org_level_id := p_dimension1_level_id;
    END IF;
    IF (l_org_seq_num = 2)
    THEN
        l_target_level_Rec.org_level_id := p_dimension2_level_id;
    END IF;
    IF (l_org_seq_num = 3)
    THEN
        l_target_level_Rec.org_level_id := p_dimension3_level_id;
    END IF;
    IF (l_org_seq_num = 4)
    THEN
        l_target_level_Rec.org_level_id := p_dimension4_level_id;
    END IF;
    IF (l_org_seq_num = 5)
    THEN
        l_target_level_Rec.org_level_id := p_dimension5_level_id;
    END IF;
    IF (l_org_seq_num = 6)
    THEN
        l_target_level_Rec.org_level_id := p_dimension6_level_id;
    END IF;
    IF (l_org_seq_num = 7)
    THEN
        l_target_level_Rec.org_level_id := p_dimension7_level_id;
    END IF;

-- 2465354
    IF ( p_IS_SEED_USER = 'Y' ) THEN
      l_owner := BIS_UTILITIES_PUB.G_SEED_OWNER ;
    ELSE
      l_owner := BIS_UTILITIES_PUB.G_CUSTOM_OWNER;
    END IF;
    -- 2465354

    BIS_Target_Level_PVT.Create_Target_Level
    ( p_api_version         => g_api_version
    , p_commit              => fnd_api.G_TRUE
    , p_Target_Level_Rec    => l_Target_Level_Rec
    , p_owner               => l_owner  --2465354
    , x_return_status       => l_return_status
    , x_error_Tbl           => l_error_Tbl
    );
-- Fix for 2254597 starts here

   x_return_status := l_return_status;

   BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
   (p_error_tbl       => l_error_tbl
   ,x_return_status   => l_return_status
   ,x_msg_count       => x_msg_count
   ,x_msg_data        => x_msg_data
   );

/*
  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
  (p_error_tbl   => l_error_tbl
  ,x_return_status  => x_return_status
  ,x_msg_count     => x_msg_count
  ,x_msg_data      => x_msg_data
  );
*/
-- Fix for 2254597 ends here
end Create_target_levels;
--
Procedure Create_Measure_Security(
 P_Target_Level_ID            IN NUMBER       := BIS_UTILITIES_PUB.G_NULL_NUM
,P_Target_Level_Short_Name    IN VARCHAR2     := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_Responsibility_ID          IN NUMBER       := BIS_UTILITIES_PUB.G_NULL_NUM
,P_Responsibility_Short_Name  IN VARCHAR2     := BIS_UTILITIES_PUB.G_NULL_CHAR
,P_Is_Seed_User               IN VARCHAR2     := 'N' --2465354
,x_return_status              OUT NOCOPY  VARCHAR2
,x_msg_count                  OUT NOCOPY  VARCHAR2
,x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
l_Measure_Security_Rec BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type;
l_return_status        varchar2(32000);
l_error_tbl            BIS_UTILITIES_PUB.Error_Tbl_Type;
l_owner                VARCHAR2(200); --2465354
BEGIN
    FND_MSG_PUB.initialize;
    --
    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_ID) = FND_API.G_FALSE) THEN
      l_Measure_Security_Rec.Target_Level_ID :=
                                        p_Target_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Short_Name) = FND_API.G_FALSE) THEN
      l_Measure_Security_Rec.Target_Level_Short_Name :=
                                        p_Target_Level_Short_Name;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Responsibility_ID) = FND_API.G_FALSE) THEN
      l_Measure_Security_Rec.Responsibility_ID  :=
                                        p_Responsibility_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Responsibility_Short_Name) = FND_API.G_FALSE) THEN
      l_Measure_Security_Rec.Responsibility_Short_Name  :=
                                        p_Responsibility_Short_Name;
    END IF;
    -- 2465354
    IF ( p_IS_SEED_USER = 'Y' ) THEN
      l_owner := BIS_UTILITIES_PUB.G_SEED_OWNER ;
    ELSE
      l_owner := BIS_UTILITIES_PUB.G_CUSTOM_OWNER;
    END IF;
    -- 2465354

    BIS_MEASURE_SECURITY_PVT.Create_Measure_Security
    ( p_api_version          => g_api_version
    , p_commit               => fnd_api.G_TRUE
    , p_Measure_Security_Rec => l_Measure_Security_Rec
    , p_owner                => l_owner   --2465354
    , x_return_status        => l_return_status
    , x_error_Tbl            => l_error_Tbl
    );
-- Fix for 2254597 starts here

   x_return_status := l_return_status;

   BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
   (p_error_tbl       => l_error_tbl
   ,x_return_status   => l_return_status
   ,x_msg_count       => x_msg_count
   ,x_msg_data        => x_msg_data
   );

/*
  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
  (p_error_tbl   => l_error_tbl
  ,x_return_status  => x_return_status
  ,x_msg_count     => x_msg_count
  ,x_msg_data      => x_msg_data
  );
*/
-- Fix for 2254597 ends here

END Create_Measure_Security;

Procedure Delete_Measure_Security(
      P_Target_Level_ID            IN NUMBER       := BIS_UTILITIES_PUB.G_NULL_NUM
    , P_Responsibility_ID          IN NUMBER       := BIS_UTILITIES_PUB.G_NULL_NUM
    ,x_return_status                 OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  VARCHAR2
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS

l_Measure_Security_Rec BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type;
l_return_status     varchar2(32000);
l_error_tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
    FND_MSG_PUB.initialize;
    --
    FND_MSG_PUB.initialize;
    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_ID) = FND_API.G_FALSE) THEN
      l_Measure_Security_Rec.Target_Level_ID :=
                                        p_Target_Level_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Responsibility_ID) = FND_API.G_FALSE) THEN
      l_Measure_Security_Rec.Responsibility_ID  :=
                                        p_Responsibility_ID;
    END IF;

    BIS_MEASURE_SECURITY_PVT.Delete_Measure_Security
    ( p_api_version          => g_api_version
    , p_commit               => fnd_api.G_FALSE --gbhaloti, removed commit for #3475674
    , p_Measure_Security_Rec => l_Measure_Security_Rec
    , x_return_status        => l_return_status
    , x_error_Tbl            => l_error_Tbl
    );
-- Fix for 2254597 starts here

   x_return_status := l_return_status;

   BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
   (p_error_tbl       => l_error_tbl
   ,x_return_status   => l_return_status
   ,x_msg_count       => x_msg_count
   ,x_msg_data        => x_msg_data
   );

/*
  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
  (p_error_tbl   => l_error_tbl
  ,x_return_status  => x_return_status
  ,x_msg_count     => x_msg_count
  ,x_msg_data      => x_msg_data
  );
*/
-- Fix for 2254597 ends here

END Delete_Measure_Security;

PROCEDURE CREATE_TARGET
(p_target_id                       IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_is_dbimeasure            	   IN NUMBER 	  := 0 --gbhaloti #3148615
,p_target_level_id		   IN NUMBER	  := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Target_Level_Short_Name         IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Target_Level_Name		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_plan_id			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_plan_name			   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim1_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim1_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim2_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim2_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim3_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim3_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim4_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim4_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim5_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim5_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim6_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim6_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim7_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim7_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_target			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range1_low			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range1_high			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range2_low			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range2_high			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range3_low			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range3_high			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_notify_resp1_id		   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_notify_resp1_short_name         IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp1_name               IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp2_id		   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_notify_resp2_short_name         IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp2_name               IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp3_id		   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_notify_resp3_short_name         IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp3_name               IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,x_return_status			   OUT NOCOPY VARCHAR2
,x_msg_count			   OUT NOCOPY NUMBER
,x_msg_data                      OUT NOCOPY VARCHAR2
)
IS
  l_target_rec			  BIS_TARGET_PUB.TARGET_REC_TYPE;
  l_target_rec_out		  BIS_TARGET_PUB.TARGET_REC_TYPE;
  l_error_tbl			  BIS_UTILITIES_PUB.ERROR_TBL_TYPE;
  l_time_seq_num                  NUMBER;
  l_org_seq_num                   NUMBER;
  l_dim_level_id                  NUMBER;
  l_Dim_level_short_name          VARCHAR2(32000);
  l_dim_level_name                VARCHAR2(32000);

  l_return_status   varchar2(10);

BEGIN
    FND_MSG_PUB.initialize;
    IF BIS_UTILITIES_PUB.VALUE_MISSINg(p_target_id)=FND_API.G_FALSE THEN
       l_target_rec.target_id := p_target_id;
    END IF;

       l_target_rec.target_level_id := p_target_level_id;
       l_target_rec.target_level_short_name := p_target_level_short_name;
       l_target_rec.target_level_name := p_target_level_name;
       l_target_rec.plan_id  := p_plan_id;
       l_target_rec.plan_name := p_plan_name;
       l_target_rec.dim1_level_value_id := p_dim1_level_value_id;
       l_target_rec.dim1_level_value_name := p_dim1_level_value_name;
       l_target_rec.dim2_level_value_id := p_dim2_level_value_id;
       l_target_rec.dim2_level_value_name := p_dim2_level_value_name;
       l_target_rec.dim3_level_value_id := p_dim3_level_value_id;
       l_target_rec.dim3_level_value_name := p_dim3_level_value_name;
       l_target_rec.dim4_level_value_id := p_dim4_level_value_id;
       l_target_rec.dim4_level_value_name := p_dim4_level_value_name;
       l_target_rec.dim5_level_value_id := p_dim5_level_value_id;
       l_target_rec.dim5_level_value_name := p_dim5_level_value_name;
       l_target_rec.dim6_level_value_id := p_dim6_level_value_id;
       l_target_rec.dim6_level_value_name := p_dim6_level_value_name;
       l_target_rec.dim7_level_value_id := p_dim7_level_value_id;
       l_target_rec.dim7_level_value_name := p_dim7_level_value_name;
       l_target_rec.target := p_target;
       l_target_Rec.range1_low := p_range1_low;
       l_target_rec.range1_high := p_range1_high;
       l_target_Rec.range2_low := p_range2_low;
       l_target_rec.range2_high := p_range2_high;
       l_target_Rec.range3_low := p_range3_low;
       l_target_rec.range3_high := p_range3_high;
       l_target_rec.notify_resp1_id := p_notify_resp1_id;
       l_target_rec.notify_resp1_short_name := p_notify_resp1_short_name;
       l_target_rec.notify_resp1_name  := p_notify_resp1_name;
       l_target_rec.notify_resp2_id := p_notify_resp2_id;
       l_target_rec.notify_resp2_short_name := p_notify_resp2_short_name;
       l_target_rec.notify_resp2_name  := p_notify_resp2_name;
       l_target_rec.notify_resp3_id := p_notify_resp3_id;
       l_target_rec.notify_resp3_short_name := p_notify_resp3_short_name;
       l_target_rec.notify_resp3_name  := p_notify_resp3_name;

  --     BIS_TARGET_PVT.GetID
  --      ( p_api_version      => 1.0
  --      , p_Target_Rec       => l_Target_Rec
   --     , x_Target_Rec       => l_Target_Rec_out
   --     , x_return_status    => x_return_status
   --     , x_error_Tbl        => l_error_Tbl
   --     );

        BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
        (p_error_tbl   => l_error_tbl
        ,x_return_status  => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data
        );

     --  IF( BIS_UTILITIES_PUB.Value_Missing(l_Target_Rec_out.TARGET_ID)
    --                     = FND_API.G_TRUE
    --       OR l_Target_Rec_out.TARGET_ID IS NULL
    --   ) THEN

       IF( BIS_UTILITIES_PUB.Value_Missing(P_TARGET_ID)
                         = FND_API.G_TRUE
           OR P_TARGET_ID IS NULL
       ) THEN
       BIS_PMF_DEFINER_WRAPPER_PVT.GET_TIME_LEVEL_ID
      (p_performance_measure_id    => NULL
      ,p_target_level_id           => p_target_level_id
      ,p_perf_measure_short_name   => NULL
      ,p_target_level_short_name   => p_target_level_short_name
      ,x_sequence_no               => l_time_seq_num
      ,x_dim_level_id              => l_dim_level_id
      ,x_dim_level_short_name      => l_dim_level_short_name
      ,x_dim_level_name            => l_dim_level_name
      ,x_return_status             => x_return_Status
      ,x_error_tbl                 => l_error_tbl
      );
      IF (l_time_seq_num = 1)
      THEN
         l_target_rec.time_level_value_id := p_dim1_level_value_id;
      END IF;
      IF (l_time_seq_num = 2)
      THEN
         l_target_rec.time_level_value_id := p_dim2_level_value_id;
      END IF;
      IF (l_time_seq_num = 3)
      THEN
         l_target_rec.time_level_value_id := p_dim3_level_value_id;
      END IF;
      IF (l_time_seq_num = 4)
      THEN
         l_target_rec.time_level_value_id := p_dim4_level_value_id;
      END IF;
      IF (l_time_seq_num = 5)
      THEN
         l_target_rec.time_level_value_id := p_dim5_level_value_id;
      END IF;
      IF (l_time_seq_num = 6)
      THEN
         l_target_rec.time_level_value_id := p_dim6_level_value_id;
      END IF;
      IF (l_time_seq_num = 7)
      THEN
         l_target_rec.time_level_value_id := p_dim7_level_value_id;
      END IF;

      BIS_PMF_DEFINER_WRAPPER_PVT.GET_ORG_LEVEL_ID
      (p_performance_measure_id    => NULL
      ,p_target_level_id           => p_target_level_id
      ,p_perf_measure_short_name   => NULL
      ,p_target_level_short_name   => p_target_level_short_name
      ,x_sequence_no               => l_org_seq_num
      ,x_dim_level_id              => l_dim_level_id
      ,x_dim_level_short_name      => l_dim_level_short_name
      ,x_dim_level_name            => l_dim_level_name
      ,x_return_status             => x_return_Status
      ,x_error_tbl                 => l_error_tbl
      );
      IF (l_org_seq_num = 1)
      THEN
          l_target_Rec.org_level_value_id := p_dim1_level_value_id;
      END IF;
      IF (l_org_seq_num = 2)
      THEN
          l_target_Rec.org_level_value_id := p_dim2_level_value_id;
      END IF;
      IF (l_org_seq_num = 3)
      THEN
          l_target_Rec.org_level_value_id := p_dim3_level_value_id;
      END IF;
      IF (l_org_seq_num = 4)
      THEN
          l_target_Rec.org_level_value_id := p_dim4_level_value_id;
      END IF;
      IF (l_org_seq_num = 5)
      THEN
          l_target_Rec.org_level_value_id := p_dim5_level_value_id;
      END IF;
      IF (l_org_seq_num = 6)
      THEN
          l_target_Rec.org_level_value_id := p_dim6_level_value_id;
      END IF;
      IF (l_org_seq_num = 7)
      THEN
          l_target_Rec.org_level_value_id := p_dim7_level_value_id;
      END IF;

          BIS_TARGET_PVT.CREATE_TARGET
          (p_api_version => 1.0
	  ,p_is_dbimeasure => p_is_dbimeasure --gbhaloti #3148615
          ,p_commit => FND_API.G_TRUE
          ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
          ,p_target_rec => l_target_rec
          ,x_return_status => x_return_status
          ,x_error_tbl => l_error_tbl
          );

       else

          BIS_TARGET_PVT.UPDATE_TARGET
          (p_api_version => 1.0
	  ,p_is_dbimeasure => p_is_dbimeasure --gbhaloti #3148615
          ,p_commit => FND_API.G_TRUE
          ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
          ,p_target_rec => l_target_rec
          ,x_return_status => x_return_status
          ,x_error_tbl => l_error_tbl
          );

       end if;

-- Fix for 2254597 starts here

   BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
   (p_error_tbl       => l_error_tbl
   ,x_return_status   => l_return_status
   ,x_msg_count       => x_msg_count
   ,x_msg_data        => x_msg_data
   );

/*
  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
  (p_error_tbl   => l_error_tbl
  ,x_return_status  => x_return_status
  ,x_msg_count     => x_msg_count
  ,x_msg_data      => x_msg_data
  );
*/
-- Fix for 2254597 ends here

END;
--
PROCEDURE UPDATE_TARGET
(p_target_id                       IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_target_level_id		   IN NUMBER	  := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Target_Level_Short_Name         IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Target_Level_Name		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_plan_id			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_plan_name			   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim1_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim1_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim2_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim2_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim3_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim3_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim4_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim4_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim5_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim5_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim6_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim6_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim7_level_value_id		   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_dim7_level_value_name	   IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_target			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range1_low			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range1_high			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range2_low			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range2_high			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range3_low			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_range3_high			   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_notify_resp1_id		   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_notify_resp1_short_name         IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp1_name               IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp2_id		   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_notify_resp2_short_name         IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp2_name               IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp3_id		   IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_notify_resp3_short_name         IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_notify_resp3_name               IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,x_return_status			   OUT NOCOPY VARCHAR2
,x_msg_count			   OUT NOCOPY NUMBER
,x_msg_data                   OUT NOCOPY  VARCHAR2

)
IS
  l_target_rec			  BIS_TARGET_PUB.TARGET_REC_TYPE;
  l_error_tbl			  BIS_UTILITIES_PUB.ERROR_TBL_TYPE;

  l_return_status   varchar2(10);

BEGIN
    FND_MSG_PUB.initialize;
    IF BIS_UTILITIES_PUB.VALUE_MISSINg(p_target_id)=FND_API.G_FALSE THEN
       l_target_rec.target_id := p_target_id;
    END IF;
       l_target_rec.target_level_id := p_target_level_id;
       l_target_rec.target_level_short_name := p_target_level_short_name;
       l_target_rec.target_level_name := p_target_level_name;
       l_target_rec.plan_id  := p_plan_id;
       l_target_rec.plan_name := p_plan_name;
       l_target_rec.dim1_level_value_id := p_dim1_level_value_id;
       l_target_rec.dim1_level_value_name := p_dim1_level_value_name;
       l_target_rec.dim2_level_value_id := p_dim1_level_value_id;
       l_target_rec.dim2_level_value_name := p_dim1_level_value_name;
       l_target_rec.dim3_level_value_id := p_dim1_level_value_id;
       l_target_rec.dim3_level_value_name := p_dim1_level_value_name;
       l_target_rec.dim4_level_value_id := p_dim1_level_value_id;
       l_target_rec.dim4_level_value_name := p_dim1_level_value_name;
       l_target_rec.dim5_level_value_id := p_dim1_level_value_id;
       l_target_rec.dim5_level_value_name := p_dim1_level_value_name;
       l_target_rec.dim6_level_value_id := p_dim1_level_value_id;
       l_target_rec.dim6_level_value_name := p_dim1_level_value_name;
       l_target_rec.dim7_level_value_id := p_dim1_level_value_id;
       l_target_rec.dim7_level_value_name := p_dim1_level_value_name;
       l_target_rec.target := p_target;
       l_target_Rec.range1_low := p_range1_low;
       l_target_rec.range1_high := p_range1_high;
       l_target_Rec.range2_low := p_range1_low;
       l_target_rec.range2_high := p_range1_high;
       l_target_Rec.range3_low := p_range1_low;
       l_target_rec.range3_high := p_range1_high;
       l_target_rec.notify_resp1_id := p_notify_resp1_id;
       l_target_rec.notify_resp1_short_name := p_notify_resp1_short_name;
       l_target_rec.notify_resp1_name  := p_notify_resp1_name;
       l_target_rec.notify_resp2_id := p_notify_resp1_id;
       l_target_rec.notify_resp2_short_name := p_notify_resp1_short_name;
       l_target_rec.notify_resp2_name  := p_notify_resp1_name;
       l_target_rec.notify_resp3_id := p_notify_resp1_id;
       l_target_rec.notify_resp3_short_name := p_notify_resp1_short_name;
       l_target_rec.notify_resp3_name  := p_notify_resp1_name;
       BIS_TARGET_PVT.UPDATE_TARGET
       (p_api_version => 1.0
       ,p_commit => FND_API.G_TRUE
       ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
       ,p_target_rec => l_target_rec
       ,x_return_status => x_return_status
       ,x_error_tbl => l_error_tbl
       );
-- Fix for 2254597 starts here

   BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
   (p_error_tbl       => l_error_tbl
   ,x_return_status   => l_return_status
   ,x_msg_count       => x_msg_count
   ,x_msg_data        => x_msg_data
   );

/*
  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
  (p_error_tbl   => l_error_tbl
  ,x_return_status  => x_return_status
  ,x_msg_count     => x_msg_count
  ,x_msg_data      => x_msg_data
  );
*/
-- Fix for 2254597 ends here

END;
--
PROCEDURE DELETE_TARGET
(p_target_id                      IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Target_level_id                IN NUMBER      := BIS_UTILITIES_PUB.G_NULL_NUM
,p_target_level_short_name        IN VARCHAR2    := BIS_UTILITIES_PUB.G_NULL_CHAR
,x_return_status                  OUT NOCOPY VARCHAR2
,x_msg_count                      OUT NOCOPY NUMBER
,x_msg_data                       OUT NOCOPY VARCHAR2
)
IS
  l_TargeT_rec                   BIS_TARGET_PUB.TARGET_REC_TYPE;
  l_error_tbl                    BIS_UTILITIES_PUB.ERROR_TBL_TYPE;

  l_return_status   varchar2(10);
BEGIN
  FND_MSG_PUB.initialize;
  l_Target_Rec.target_id := p_target_id;
  l_target_rec.target_level_id := p_target_level_id;
  l_target_rec.target_level_short_name := p_target_level_short_name;
  BIS_TARGET_PVT.DELETE_TARGET
  (p_api_version => 1.0
  ,p_commit      => FND_API.G_TRUE
  ,p_target_Rec  => l_target_rec
  ,x_return_status => x_return_status
  ,x_error_tbl     => l_error_tbl
  );
-- Fix for 2254597 starts here

   BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
   (p_error_tbl       => l_error_tbl
   ,x_return_status   => l_return_status
   ,x_msg_count       => x_msg_count
   ,x_msg_data        => x_msg_data
   );

/*
  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
  (p_error_tbl   => l_error_tbl
  ,x_return_status  => x_return_status
  ,x_msg_count     => x_msg_count
  ,x_msg_data      => x_msg_data
  );
*/
-- Fix for 2254597 ends here

END;
--
PROCEDURE GET_TIME_LEVEL_ID
(p_performance_measure_id         IN  NUMBER DEFAULT BIS_UTILITIES_PUB.G_NULL_NUM
,p_target_level_id                IN  NUMBER
,p_perf_measure_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,p_target_level_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,p_source                         IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,x_sequence_no                    OUT NOCOPY NUMBER
,x_dim_level_id                   OUT NOCOPY NUMBER
,x_dim_level_short_name           OUT NOCOPY VARCHAR2
,x_dim_level_name                 OUT NOCOPY VARCHAR2
,x_return_status                   OUT NOCOPY VARCHAR2
,x_error_tbl                      OUT NOCOPY BIS_UTILITIES_PUB.ERROR_TBL_TYPE
)
IS
  CURSOR c_perf_dim_src IS
  SELECT x.sequence_no
  FROM bis_indicator_dimensions x, bis_dimensions y
  WHERE x.indicator_id = p_performance_measure_id AND
        y.dimension_id = x.dimension_id AND
        y.short_name = BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_SRC(p_source);
  CURSOR c_perf_dim IS
  SELECT x.sequence_no
  FROM bis_indicator_dimensions x, bis_dimensions y
  WHERE x.indicator_id = p_performance_measure_id AND
        y.dimension_id = x.dimension_id AND
        y.short_name = BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_target_level_id,NULL);
  CURSOR c_dim IS
  SELECT x.sequence_no ,
         y.dimension1_level_id, y.dimension1_level_short_name, y.dimension1_level_name,
         y.dimension2_level_id, y.dimension2_level_short_name, y.dimension2_level_name,
         y.dimension3_level_id, y.dimension3_level_short_name, y.dimension3_level_name,
         y.dimension4_level_id, y.dimension4_level_short_name, y.dimension4_level_name,
         y.dimension5_level_id, y.dimension5_level_short_name, y.dimension5_level_name,
         y.dimension6_level_id, y.dimension6_level_short_name, y.dimension6_level_name,
         y.dimension7_level_id, y.dimension7_level_short_name, y.dimension7_level_name
  FROM bis_indicator_dimensions x, bisfv_target_levels y,
       bis_dimensions z
  WHERE y.target_level_id=p_target_level_id AND
        y.measure_id = x.indicator_id AND
        x.dimension_id = z.dimension_id AND
        z.short_name = BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_target_level_id,NULL);
  l_sequence_no                     NUMBER;
  l_dim_level_id                    VARCHAR2(100);
  l_dimension1_level_id             NUMBER;
  l_dimension1_level_short_name     BISFV_TARGET_LEVELS.dimension1_level_short_name%TYPE;
  l_dimension1_level_name           BISFV_TARGET_LEVELS.dimension1_level_name%TYPE;
  l_dimension2_level_id             NUMBER;
  l_dimension2_level_short_name     BISFV_TARGET_LEVELS.dimension2_level_short_name%TYPE;
  l_dimension2_level_name           BISFV_TARGET_LEVELS.dimension2_level_name%TYPE;
  l_dimension3_level_id             NUMBER;
  l_dimension3_level_short_name     BISFV_TARGET_LEVELS.dimension3_level_short_name%TYPE;
  l_dimension3_level_name           BISFV_TARGET_LEVELS.dimension3_level_name%TYPE;
  l_dimension4_level_id             NUMBER;
  l_dimension4_level_short_name     BISFV_TARGET_LEVELS.dimension4_level_short_name%TYPE;
  l_dimension4_level_name           BISFV_TARGET_LEVELS.dimension4_level_name%TYPE;
  l_dimension5_level_id             NUMBER;
  l_dimension5_level_short_name     BISFV_TARGET_LEVELS.dimension5_level_short_name%TYPE;
  l_dimension5_level_name           BISFV_TARGET_LEVELS.dimension5_level_name%TYPE;
  l_dimension6_level_id             NUMBER;
  l_dimension6_level_short_name     BISFV_TARGET_LEVELS.dimension6_level_short_name%TYPE;
  l_dimension6_level_name           BISFV_TARGET_LEVELS.dimension6_level_name%TYPE;
  l_dimension7_level_id             NUMBER;
  l_dimension7_level_short_name     BISFV_TARGET_LEVELS.dimension7_level_short_name%TYPE;
  l_dimension7_level_name           BISFV_TARGET_LEVELS.dimension7_level_name%TYPE;
  l_error_Tbl_p                     BIS_UTILITIES_PUB.ERROR_TBL_TYPE;

BEGIN
    IF (p_performance_measure_id <> FND_API.G_MISS_NUM AND
        p_source <> FND_API.G_MISS_CHAR) THEN
       OPEN c_perf_dim_src;
       FETCH c_perf_dim_src INTO l_sequence_no;
       CLOSE c_perf_dim_src;
       x_sequence_no := l_sequence_no;
    ELSIF (p_performance_measure_id <> FND_API.G_MISS_NUM) THEN
       OPEN c_perf_dim;
       FETCH c_perf_dim INTO l_sequence_no;
       CLOSE c_perf_dim;
       x_sequence_no := l_sequence_no;
    END IF;

    IF (p_target_level_id <> FND_API.G_MISS_NUM) THEN
    OPEN c_dim;
    FETCH c_dim INTO l_sequence_no
         ,l_Dimension1_level_id, l_dimension1_level_short_name,l_Dimension1_level_name
         ,l_Dimension2_level_id, l_dimension2_level_short_name,l_Dimension2_level_name
         ,l_Dimension3_level_id, l_dimension3_level_short_name,l_Dimension3_level_name
         ,l_Dimension4_level_id, l_dimension4_level_short_name,l_Dimension4_level_name
         ,l_Dimension5_level_id, l_dimension5_level_short_name,l_Dimension5_level_name
         ,l_Dimension6_level_id, l_dimension6_level_short_name,l_Dimension6_level_name
         ,l_Dimension7_level_id, l_dimension7_level_short_name,l_Dimension7_level_name
        ;
     CLOSE c_dim;
     x_sequence_no := l_sequence_no;
     IF (l_sequence_no = 1) THEN
        x_dim_level_id := l_Dimension1_level_id;
        x_dim_level_short_name := l_dimension1_level_short_name;
        x_dim_level_name       := l_dimension1_level_name;
     END IF;
     IF (l_sequence_no = 2) THEN
        x_dim_level_id := l_Dimension2_level_id;
        x_dim_level_short_name := l_dimension2_level_short_name;
        x_dim_level_name       := l_dimension2_level_name;
     END IF;
     IF (l_sequence_no = 3) THEN
        x_dim_level_id := l_Dimension3_level_id;
        x_dim_level_short_name := l_dimension3_level_short_name;
        x_dim_level_name       := l_dimension3_level_name;
     END IF;
     IF (l_sequence_no = 4) THEN
        x_dim_level_id := l_Dimension4_level_id;
        x_dim_level_short_name := l_dimension4_level_short_name;
        x_dim_level_name       := l_dimension4_level_name;
     END IF;
     IF (l_sequence_no = 5) THEN
        x_dim_level_id := l_Dimension5_level_id;
        x_dim_level_short_name := l_dimension5_level_short_name;
        x_dim_level_name       := l_dimension5_level_name;
     END IF;
     IF (l_sequence_no = 6) THEN
        x_dim_level_id := l_Dimension6_level_id;
        x_dim_level_short_name := l_dimension6_level_short_name;
        x_dim_level_name       := l_dimension6_level_name;
     END IF;
     IF (l_sequence_no = 7) THEN
        x_dim_level_id := l_Dimension7_level_id;
        x_dim_level_short_name := l_dimension7_level_short_name;
        x_dim_level_name       := l_dimension7_level_name;
     END IF;
    END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF c_perf_dim_src%ISOPEN THEN -- bug 3045087
      CLOSE c_perf_dim_src;
    END IF;
    IF c_perf_dim%ISOPEN THEN
      CLOSE c_perf_dim;
    END IF;
    IF c_dim%ISOPEN THEN
      CLOSE c_dim;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_error_Tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF c_perf_dim_src%ISOPEN THEN
      CLOSE c_perf_dim_src;
    END IF;
    IF c_perf_dim%ISOPEN THEN
      CLOSE c_perf_dim;
    END IF;
    IF c_dim%ISOPEN THEN
      CLOSE c_dim;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    WHEN OTHERS THEN
    IF c_perf_dim_src%ISOPEN THEN
      CLOSE c_perf_dim_src;
    END IF;
    IF c_perf_dim%ISOPEN THEN
      CLOSE c_perf_dim;
    END IF;
    IF c_dim%ISOPEN THEN
      CLOSE c_dim;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
END;
--

PROCEDURE GET_TIME_LEVEL_ID
(p_performance_measure_id         IN  NUMBER DEFAULT BIS_UTILITIES_PUB.G_NULL_NUM
,p_target_level_id                IN  NUMBER
,p_perf_measure_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,p_target_level_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,x_sequence_no                    OUT NOCOPY NUMBER
,x_dim_level_id                   OUT NOCOPY NUMBER
,x_dim_level_short_name           OUT NOCOPY VARCHAR2
,x_dim_level_name                 OUT NOCOPY VARCHAR2
,x_return_status                   OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_perf_dim IS
  SELECT x.sequence_no
  FROM bis_indicator_dimensions x, bis_dimensions y
  WHERE x.indicator_id = p_performance_measure_id AND
        y.dimension_id = x.dimension_id AND
        y.short_name = BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_target_level_id,NULL);
  CURSOR c_dim IS
  SELECT x.sequence_no ,
         y.dimension1_level_id, y.dimension1_level_short_name, y.dimension1_level_name,
         y.dimension2_level_id, y.dimension2_level_short_name, y.dimension2_level_name,
         y.dimension3_level_id, y.dimension3_level_short_name, y.dimension3_level_name,
         y.dimension4_level_id, y.dimension4_level_short_name, y.dimension4_level_name,
         y.dimension5_level_id, y.dimension5_level_short_name, y.dimension5_level_name,
         y.dimension6_level_id, y.dimension6_level_short_name, y.dimension6_level_name,
         y.dimension7_level_id, y.dimension7_level_short_name, y.dimension7_level_name
  FROM bis_indicator_dimensions x, bisfv_target_levels y,
       bis_dimensions z
  WHERE y.target_level_id=p_target_level_id AND
        y.measure_id = x.indicator_id AND
        x.dimension_id = z.dimension_id AND
        z.short_name = BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_target_level_id,NULL);
  l_sequence_no                     NUMBER;
  l_dim_level_id                    VARCHAR2(100);
  l_dimension1_level_id             NUMBER;
  l_dimension1_level_short_name     BISFV_TARGET_LEVELS.dimension1_level_short_name%TYPE;
  l_dimension1_level_name           BISFV_TARGET_LEVELS.dimension1_level_name%TYPE;
  l_dimension2_level_id             NUMBER;
  l_dimension2_level_short_name     BISFV_TARGET_LEVELS.dimension2_level_short_name%TYPE;
  l_dimension2_level_name           BISFV_TARGET_LEVELS.dimension2_level_name%TYPE;
  l_dimension3_level_id             NUMBER;
  l_dimension3_level_short_name     BISFV_TARGET_LEVELS.dimension3_level_short_name%TYPE;
  l_dimension3_level_name           BISFV_TARGET_LEVELS.dimension3_level_name%TYPE;
  l_dimension4_level_id             NUMBER;
  l_dimension4_level_short_name     BISFV_TARGET_LEVELS.dimension4_level_short_name%TYPE;
  l_dimension4_level_name           BISFV_TARGET_LEVELS.dimension4_level_name%TYPE;
  l_dimension5_level_id             NUMBER;
  l_dimension5_level_short_name     BISFV_TARGET_LEVELS.dimension5_level_short_name%TYPE;
  l_dimension5_level_name           BISFV_TARGET_LEVELS.dimension5_level_name%TYPE;
  l_dimension6_level_id             NUMBER;
  l_dimension6_level_short_name     BISFV_TARGET_LEVELS.dimension6_level_short_name%TYPE;
  l_dimension6_level_name           BISFV_TARGET_LEVELS.dimension6_level_name%TYPE;
  l_dimension7_level_id             NUMBER;
  l_dimension7_level_short_name     BISFV_TARGET_LEVELS.dimension7_level_short_name%TYPE;
  l_dimension7_level_name           BISFV_TARGET_LEVELS.dimension7_level_name%TYPE;

BEGIN
IF (p_performance_measure_id <> FND_API.G_MISS_NUM) THEN
       OPEN c_perf_dim;
       FETCH c_perf_dim INTO l_sequence_no;
       CLOSE c_perf_dim;
       x_sequence_no := l_sequence_no;
    END IF;
    IF (p_target_level_id <> FND_API.G_MISS_NUM) THEN
    OPEN c_dim;
    FETCH c_dim INTO l_sequence_no
         ,l_Dimension1_level_id, l_dimension1_level_short_name,l_Dimension1_level_name
         ,l_Dimension2_level_id, l_dimension2_level_short_name,l_Dimension2_level_name
         ,l_Dimension3_level_id, l_dimension3_level_short_name,l_Dimension3_level_name
         ,l_Dimension4_level_id, l_dimension4_level_short_name,l_Dimension4_level_name
         ,l_Dimension5_level_id, l_dimension5_level_short_name,l_Dimension5_level_name
         ,l_Dimension6_level_id, l_dimension6_level_short_name,l_Dimension6_level_name
         ,l_Dimension7_level_id, l_dimension7_level_short_name,l_Dimension7_level_name
        ;
    CLOSE c_dim;
     x_sequence_no := l_sequence_no;
     IF (l_sequence_no = 1) THEN
        x_dim_level_id := l_Dimension1_level_id;
        x_dim_level_short_name := l_dimension1_level_short_name;
        x_dim_level_name       := l_dimension1_level_name;
     END IF;
     IF (l_sequence_no = 2) THEN
        x_dim_level_id := l_Dimension2_level_id;
        x_dim_level_short_name := l_dimension2_level_short_name;
        x_dim_level_name       := l_dimension2_level_name;
     END IF;
     IF (l_sequence_no = 3) THEN
        x_dim_level_id := l_Dimension3_level_id;
        x_dim_level_short_name := l_dimension3_level_short_name;
        x_dim_level_name       := l_dimension3_level_name;END IF;
     IF (l_sequence_no = 4) THEN
        x_dim_level_id := l_Dimension4_level_id;
        x_dim_level_short_name := l_dimension4_level_short_name;
        x_dim_level_name       := l_dimension4_level_name;
     END IF;
     IF (l_sequence_no = 5) THEN
        x_dim_level_id := l_Dimension5_level_id;
        x_dim_level_short_name := l_dimension5_level_short_name;
        x_dim_level_name       := l_dimension5_level_name;
     END IF;
     IF (l_sequence_no = 6) THEN
        x_dim_level_id := l_Dimension6_level_id;
        x_dim_level_short_name := l_dimension6_level_short_name;
        x_dim_level_name       := l_dimension6_level_name;
     END IF;
     IF (l_sequence_no = 7) THEN
        x_dim_level_id := l_Dimension7_level_id;
        x_dim_level_short_name := l_dimension7_level_short_name;
        x_dim_level_name       := l_dimension7_level_name;
     END IF;
    END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF c_perf_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_perf_dim;
    END IF;
    IF c_dim%ISOPEN THEN
      CLOSE c_dim;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF c_perf_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_perf_dim;
    END IF;
    IF c_dim%ISOPEN THEN
      CLOSE c_dim;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    IF c_perf_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_perf_dim;
    END IF;
    IF c_dim%ISOPEN THEN
      CLOSE c_dim;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
--
PROCEDURE GET_ORG_LEVEL_ID
(p_performance_measure_id         IN  NUMBER DEFAULT BIS_UTILITIES_PUB.G_NULL_NUM
,p_target_level_id                IN  NUMBER
,p_perf_measure_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,p_target_level_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,p_source                         IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,x_sequence_no                    OUT NOCOPY NUMBER
,x_dim_level_id                   OUT NOCOPY NUMBER
,x_dim_level_short_name           OUT NOCOPY VARCHAR2
,x_dim_level_name                 OUT NOCOPY VARCHAR2
,x_return_status                   OUT NOCOPY VARCHAR2
,x_error_tbl                      OUT NOCOPY BIS_UTILITIES_PUB.ERROR_TBL_TYPE
)
IS
  CURSOR c_perf_dim_src IS
  SELECT x.sequence_no
  FROM bis_indicator_dimensions x, bis_dimensions y
  WHERE x.indicator_id = p_performance_measure_id AND
        y.dimension_id = x.dimension_id AND
        y.short_name = BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_SRC(p_source);
  CURSOR c_perf_dim IS
  SELECT x.sequence_no
  FROM bis_indicator_dimensions x, bis_dimensions y
  WHERE x.indicator_id = p_performance_measure_id AND
        y.dimension_id = x.dimension_id AND
        y.short_name = BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_TL(p_target_level_id,NULL);
  CURSOR c_dim IS
  SELECT x.sequence_no ,
         y.dimension1_level_id, y.dimension1_level_short_name, y.dimension1_level_name,
         y.dimension2_level_id, y.dimension2_level_short_name, y.dimension2_level_name,
         y.dimension3_level_id, y.dimension3_level_short_name, y.dimension3_level_name,
         y.dimension4_level_id, y.dimension4_level_short_name, y.dimension4_level_name,
         y.dimension5_level_id, y.dimension5_level_short_name, y.dimension5_level_name,
         y.dimension6_level_id, y.dimension6_level_short_name, y.dimension6_level_name,
         y.dimension7_level_id, y.dimension7_level_short_name, y.dimension7_level_name
  FROM bis_indicator_dimensions x, bisfv_target_levels y,
       bis_dimensions z
  WHERE y.target_level_id=p_target_level_id AND
        y.measure_id = x.indicator_id AND
        x.dimension_id = z.dimension_id AND
        z.short_name = BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_TL(p_target_level_id,NULL);
  l_sequence_no      NUMBER;
  l_dim_level_id                    VARCHAR2(100);
  l_dimension1_level_id             NUMBER;
  l_dimension1_level_short_name     BISFV_TARGET_LEVELS.dimension1_level_short_name%TYPE;
  l_dimension1_level_name           BISFV_TARGET_LEVELS.dimension1_level_name%TYPE;
  l_dimension2_level_id             NUMBER;
  l_dimension2_level_short_name     BISFV_TARGET_LEVELS.dimension2_level_short_name%TYPE;
  l_dimension2_level_name           BISFV_TARGET_LEVELS.dimension2_level_name%TYPE;
  l_dimension3_level_id             NUMBER;
  l_dimension3_level_short_name     BISFV_TARGET_LEVELS.dimension3_level_short_name%TYPE;
  l_dimension3_level_name           BISFV_TARGET_LEVELS.dimension3_level_name%TYPE;
  l_dimension4_level_id             NUMBER;
  l_dimension4_level_short_name     BISFV_TARGET_LEVELS.dimension4_level_short_name%TYPE;
  l_dimension4_level_name           BISFV_TARGET_LEVELS.dimension4_level_name%TYPE;
  l_dimension5_level_id             NUMBER;
  l_dimension5_level_short_name     BISFV_TARGET_LEVELS.dimension5_level_short_name%TYPE;
  l_dimension5_level_name           BISFV_TARGET_LEVELS.dimension5_level_name%TYPE;
  l_dimension6_level_id             NUMBER;
  l_dimension6_level_short_name     BISFV_TARGET_LEVELS.dimension6_level_short_name%TYPE;
  l_dimension6_level_name           BISFV_TARGET_LEVELS.dimension6_level_name%TYPE;
  l_dimension7_level_id             NUMBER;
  l_dimension7_level_short_name     BISFV_TARGET_LEVELS.dimension7_level_short_name%TYPE;
  l_dimension7_level_name           BISFV_TARGET_LEVELS.dimension7_level_name%TYPE;
  l_error_Tbl_p                     BIS_UTILITIES_PUB.ERROR_TBL_TYPE;

BEGIN
    IF (p_performance_measure_id <> FND_API.G_MISS_NUM
        AND p_source <> FND_API.G_MISS_CHAR) THEN
       OPEN c_perf_dim_src;
       FETCH c_perf_dim_src INTO l_sequence_no;
       CLOSE c_perf_dim_src;
       x_sequence_no := l_sequence_no;
    ELSIF (p_performance_measure_id <> FND_API.G_MISS_NUM) THEN
       OPEN c_perf_dim;
       FETCH c_perf_dim INTO l_sequence_no;
       CLOSE c_perf_dim;
       x_sequence_no := l_sequence_no;
    END IF;

    IF (p_target_level_id <> FND_API.G_MISS_NUM) THEN
     OPEN c_dim;
     FETCH c_dim INTO l_sequence_no
         ,l_Dimension1_level_id, l_dimension1_level_short_name,l_Dimension1_level_name
         ,l_Dimension2_level_id, l_dimension2_level_short_name,l_Dimension2_level_name
         ,l_Dimension3_level_id, l_dimension3_level_short_name,l_Dimension3_level_name
         ,l_Dimension4_level_id, l_dimension4_level_short_name,l_Dimension4_level_name
         ,l_Dimension5_level_id, l_dimension5_level_short_name,l_Dimension5_level_name
         ,l_Dimension6_level_id, l_dimension6_level_short_name,l_Dimension6_level_name
         ,l_Dimension7_level_id, l_dimension7_level_short_name,l_Dimension7_level_name
        ;
     CLOSE c_dim;
     x_sequence_no := l_sequence_no;
     IF (l_sequence_no = 1) THEN
        x_dim_level_id := l_Dimension1_level_id;
        x_dim_level_short_name := l_dimension1_level_short_name;
        x_dim_level_name       := l_dimension1_level_name;
     END IF;
     IF (l_sequence_no = 2) THEN
        x_dim_level_id := l_Dimension2_level_id;
        x_dim_level_short_name := l_dimension2_level_short_name;
        x_dim_level_name       := l_dimension2_level_name;
     END IF;
     IF (l_sequence_no = 3) THEN
        x_dim_level_id := l_Dimension3_level_id;
        x_dim_level_short_name := l_dimension3_level_short_name;
        x_dim_level_name       := l_dimension3_level_name;
     END IF;
     IF (l_sequence_no = 4) THEN
        x_dim_level_id := l_Dimension4_level_id;
        x_dim_level_short_name := l_dimension4_level_short_name;
        x_dim_level_name       := l_dimension4_level_name;
     END IF;
     IF (l_sequence_no = 5) THEN
        x_dim_level_id := l_Dimension5_level_id;
        x_dim_level_short_name := l_dimension5_level_short_name;
        x_dim_level_name       := l_dimension5_level_name;
     END IF;
     IF (l_sequence_no = 6) THEN
        x_dim_level_id := l_Dimension6_level_id;
        x_dim_level_short_name := l_dimension6_level_short_name;
        x_dim_level_name       := l_dimension6_level_name;
     END IF;
     IF (l_sequence_no = 7) THEN
        x_dim_level_id := l_Dimension7_level_id;
        x_dim_level_short_name := l_dimension7_level_short_name;
        x_dim_level_name       := l_dimension7_level_name;
     END IF;
    END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF c_perf_dim_src%ISOPEN THEN -- bug 3045087
      CLOSE c_perf_dim_src;
    END IF;
    IF c_perf_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_perf_dim;
    END IF;
    IF c_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_dim;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_error_Tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF c_perf_dim_src%ISOPEN THEN -- bug 3045087
      CLOSE c_perf_dim_src;
    END IF;
    IF c_perf_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_perf_dim;
    END IF;
    IF c_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_dim;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
  WHEN OTHERS THEN
    IF c_perf_dim_src%ISOPEN THEN -- bug 3045087
      CLOSE c_perf_dim_src;
    END IF;
    IF c_perf_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_perf_dim;
    END IF;
    IF c_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_dim;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );

END;


---
PROCEDURE GET_ORG_LEVEL_ID
(p_performance_measure_id         IN  NUMBER DEFAULT BIS_UTILITIES_PUB.G_NULL_NUM
,p_target_level_id                IN  NUMBER
,p_perf_measure_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,p_target_level_short_name        IN  VARCHAR2 DEFAULT BIS_UTILITIES_PUB.G_NULL_CHAR
,x_sequence_no                    OUT NOCOPY NUMBER
,x_dim_level_id                   OUT NOCOPY NUMBER
,x_dim_level_short_name           OUT NOCOPY VARCHAR2
,x_dim_level_name                 OUT NOCOPY VARCHAR2
,x_return_status                   OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_perf_dim IS
  SELECT x.sequence_no
  FROM bis_indicator_dimensions x, bis_dimensions y
  WHERE x.indicator_id = p_performance_measure_id AND
        y.dimension_id = x.dimension_id AND
        y.short_name = BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_TL(p_target_level_id,NULL);
  CURSOR c_dim IS
  SELECT x.sequence_no ,
         y.dimension1_level_id, y.dimension1_level_short_name, y.dimension1_level_name,
         y.dimension2_level_id, y.dimension2_level_short_name, y.dimension2_level_name,
         y.dimension3_level_id, y.dimension3_level_short_name, y.dimension3_level_name,
         y.dimension4_level_id, y.dimension4_level_short_name, y.dimension4_level_name,
         y.dimension5_level_id, y.dimension5_level_short_name, y.dimension5_level_name,
         y.dimension6_level_id, y.dimension6_level_short_name, y.dimension6_level_name,
         y.dimension7_level_id, y.dimension7_level_short_name, y.dimension7_level_name
  FROM bis_indicator_dimensions x, bisfv_target_levels y,
       bis_dimensions z
  WHERE y.target_level_id=p_target_level_id AND
        y.measure_id = x.indicator_id AND
        x.dimension_id = z.dimension_id AND
        z.short_name = BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_TL(p_target_level_id,NULL);
  l_sequence_no                     NUMBER;
  l_dim_level_id                    VARCHAR2(100);
  l_dimension1_level_id             NUMBER;
  l_dimension1_level_short_name     BISFV_TARGET_LEVELS.dimension1_level_short_name%TYPE;
  l_dimension1_level_name           BISFV_TARGET_LEVELS.dimension1_level_name%TYPE;
  l_dimension2_level_id             NUMBER;
  l_dimension2_level_short_name     BISFV_TARGET_LEVELS.dimension2_level_short_name%TYPE;
  l_dimension2_level_name           BISFV_TARGET_LEVELS.dimension2_level_name%TYPE;
  l_dimension3_level_id             NUMBER;
  l_dimension3_level_short_name     BISFV_TARGET_LEVELS.dimension3_level_short_name%TYPE;
  l_dimension3_level_name           BISFV_TARGET_LEVELS.dimension3_level_name%TYPE;
  l_dimension4_level_id             NUMBER;
  l_dimension4_level_short_name     BISFV_TARGET_LEVELS.dimension4_level_short_name%TYPE;
  l_dimension4_level_name           BISFV_TARGET_LEVELS.dimension4_level_name%TYPE;
  l_dimension5_level_id             NUMBER;
  l_dimension5_level_short_name     BISFV_TARGET_LEVELS.dimension5_level_short_name%TYPE;
  l_dimension5_level_name           BISFV_TARGET_LEVELS.dimension5_level_name%TYPE;
  l_dimension6_level_id             NUMBER;
  l_dimension6_level_short_name     BISFV_TARGET_LEVELS.dimension6_level_short_name%TYPE;
  l_dimension6_level_name           BISFV_TARGET_LEVELS.dimension6_level_name%TYPE;
  l_dimension7_level_id             NUMBER;
  l_dimension7_level_short_name     BISFV_TARGET_LEVELS.dimension7_level_short_name%TYPE;
  l_dimension7_level_name           BISFV_TARGET_LEVELS.dimension7_level_name%TYPE;

BEGIN
IF (p_performance_measure_id <> FND_API.G_MISS_NUM) THEN
       OPEN c_perf_dim;
       FETCH c_perf_dim INTO l_sequence_no;
       CLOSE c_perf_dim;
       x_sequence_no := l_sequence_no;
    END IF;
    IF (p_target_level_id <> FND_API.G_MISS_NUM) THEN
    OPEN c_dim;
    FETCH c_dim INTO l_sequence_no
         ,l_Dimension1_level_id, l_dimension1_level_short_name,l_Dimension1_level_name
         ,l_Dimension2_level_id, l_dimension2_level_short_name,l_Dimension2_level_name
         ,l_Dimension3_level_id, l_dimension3_level_short_name,l_Dimension3_level_name
         ,l_Dimension4_level_id, l_dimension4_level_short_name,l_Dimension4_level_name
         ,l_Dimension5_level_id, l_dimension5_level_short_name,l_Dimension5_level_name
         ,l_Dimension6_level_id, l_dimension6_level_short_name,l_Dimension6_level_name
         ,l_Dimension7_level_id, l_dimension7_level_short_name,l_Dimension7_level_name
        ;
    CLOSE c_dim;
     x_sequence_no := l_sequence_no;
     IF (l_sequence_no = 1) THEN
        x_dim_level_id := l_Dimension1_level_id;
        x_dim_level_short_name := l_dimension1_level_short_name;
        x_dim_level_name       := l_dimension1_level_name;
     END IF;
     IF (l_sequence_no = 2) THEN
        x_dim_level_id := l_Dimension2_level_id;
        x_dim_level_short_name := l_dimension2_level_short_name;
        x_dim_level_name       := l_dimension2_level_name;
     END IF;
     IF (l_sequence_no = 3) THEN
        x_dim_level_id := l_Dimension3_level_id;
        x_dim_level_short_name := l_dimension3_level_short_name;
        x_dim_level_name       := l_dimension3_level_name;END IF;
     IF (l_sequence_no = 4) THEN
        x_dim_level_id := l_Dimension4_level_id;
        x_dim_level_short_name := l_dimension4_level_short_name;
        x_dim_level_name       := l_dimension4_level_name;
     END IF;
     IF (l_sequence_no = 5) THEN
        x_dim_level_id := l_Dimension5_level_id;
        x_dim_level_short_name := l_dimension5_level_short_name;
        x_dim_level_name       := l_dimension5_level_name;
     END IF;
     IF (l_sequence_no = 6) THEN
        x_dim_level_id := l_Dimension6_level_id;
        x_dim_level_short_name := l_dimension6_level_short_name;
        x_dim_level_name       := l_dimension6_level_name;
     END IF;
     IF (l_sequence_no = 7) THEN
        x_dim_level_id := l_Dimension7_level_id;
        x_dim_level_short_name := l_dimension7_level_short_name;
        x_dim_level_name       := l_dimension7_level_name;
     END IF;
    END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF c_perf_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_perf_dim;
    END IF;
    IF c_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_dim;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF c_perf_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_perf_dim;
    END IF;
    IF c_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_dim;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    IF c_perf_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_perf_dim;
    END IF;
    IF c_dim%ISOPEN THEN -- bug 3045087
      CLOSE c_dim;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;


PROCEDURE ADD_TO_FND_MSG_STACK
(p_error_tbl	IN	BIS_UTILITIES_PUB.ERROR_TBL_TYPE
,x_msg_count    OUT NOCOPY     NUMBER
,x_msg_data     OUT NOCOPY     VARCHAR2
,x_return_status   OUT NOCOPY     VARCHAR2
)
IS
BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
       FOR l_Count in 1..p_error_tbl.COUNT LOOP
           FND_MESSAGE.SET_NAME('BIS',p_error_tbl(l_count).error_msg_name);
           FND_MSG_PUB.Add;
       END LOOP;
-- Fix for 2332823
          FND_MSG_PUB.Count_And_Get
          ( p_count    =>  x_msg_count,
            p_data    =>  x_msg_data
          );
/*
-- Fix for 2254597 starts here
      x_msg_count := p_error_tbl.count;
      x_msg_data  := p_error_tbl(p_error_tbl.count).error_description;
-- Fix for 2254597 ends here
*/
    END IF;
END ADD_TO_FND_MSG_STACK;


--added target_level_id, changed name
FUNCTION BuildAlertRegURLTL
(p_measure_id           IN      NUMBER
,p_target_level_id      IN      NUMBER
,p_dim1_level_id	IN	NUMBER
,p_dim2_level_id	IN	NUMBER
,p_dim3_level_id	IN      NUMBER
,p_Dim4_level_id	IN	NUMBER
,p_Dim5_level_id	IN	NUMBER
,p_dim6_level_id	IN      NUMBER
,p_dim7_level_id	IN	NUMBER
)
RETURN VARCHAR2
IS
  l_alert_url                  VARCHAR2(32000);
  l_dbc                        VARCHAR2(10000);
  l_servlet_agent              VARCHAR2(10000);
  l_encrypted_session_id       VARCHAR2(1000);
  l_session_id                 NUMBER;
BEGIN
  l_session_id := icx_sec.g_session_id; --2751984
  l_encrypted_session_id := icx_call.encrypt3(l_session_id);

  fnd_profile.get(name => 'APPS_SERVLET_AGENT',
                  val  => l_Alert_url);
  l_alert_url := FND_WEB_CONFIG.trail_slash(l_alert_url) ||
                 'bisalrsc.jsp?dbc=' ||FND_WEB_CONFIG.DATABASE_ID
                || G_AMPERSAND||'session_id='||l_encrypted_session_id;
  IF (p_measure_id IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND ||'perfMeasureId='
  -- 2280993 starts
--                    ||wfa_html.conv_special_url_chars(p_measure_id);
                    ||BIS_UTILITIES_PUB.encode(p_measure_id);
  -- 2280993 ends
 END IF;
  --added target_level_id
 IF (p_target_level_id IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND ||'targetLevelId='
  -- 2280993 starts
--                    ||wfa_html.conv_special_url_chars(p_target_level_id);
                    ||BIS_UTILITIES_PUB.encode(p_target_level_id);
  -- 2280993 ends
 END IF;
 ------
 IF (p_dim1_level_id IS NOT NULL) THEN
    l_alert_url := l_alert_url || G_AMPERSAND||'parameter1Level='
  -- 2280993 starts
--		   ||wfa_html.conv_special_url_chars(p_dim1_level_id);
		   ||BIS_UTILITIES_PUB.encode(p_dim1_level_id);
  -- 2280993 ends
 END IF;
 IF (p_dim2_level_id IS NOT NULL) THEN
    l_alert_url := l_alert_url || G_AMPERSAND||'parameter2Level='
  -- 2280993 starts
--		   ||wfa_html.conv_special_url_chars(p_dim2_level_id);
		   ||BIS_UTILITIES_PUB.encode(p_dim2_level_id);
  -- 2280993 ends
 END IF;
 IF (p_dim3_level_id IS NOT NULL) THEN
    l_alert_url := l_alert_url || G_AMPERSAND||'parameter3Level='
  -- 2280993 starts
--		   ||wfa_html.conv_special_url_chars(p_dim3_level_id);
		   ||BIS_UTILITIES_PUB.encode(p_dim3_level_id);
  -- 2280993 ends
 END IF;
 IF (p_dim4_level_id IS NOT NULL) THEN
    l_alert_url := l_alert_url || G_AMPERSAND||'parameter4Level='
  -- 2280993 starts
--		   ||wfa_html.conv_special_url_chars(p_dim4_level_id);
		   ||BIS_UTILITIES_PUB.encode(p_dim4_level_id);
  -- 2280993 ends
 END IF;
 IF (p_dim5_level_id IS NOT NULL) THEN
    l_alert_url := l_alert_url || G_AMPERSAND||'parameter5Level='
  -- 2280993 starts
--		   ||wfa_html.conv_special_url_chars(p_dim5_level_id);
		   ||BIS_UTILITIES_PUB.encode(p_dim5_level_id);
  -- 2280993 ends
 END IF;
 IF (p_dim6_level_id IS NOT NULL) THEN
    l_alert_url := l_alert_url || G_AMPERSAND||'parameter6Level='
  -- 2280993 starts
--		   ||wfa_html.conv_special_url_chars(p_dim6_level_id);
		   ||BIS_UTILITIES_PUB.encode(p_dim6_level_id);
  -- 2280993 ends
 END IF;
 IF (p_dim7_level_id IS NOT NULL) THEN
    l_alert_url := l_alert_url || G_AMPERSAND||'parameter7Level='
  -- 2280993 starts
--		   ||wfa_html.conv_special_url_chars(p_dim7_level_id);
		   ||BIS_UTILITIES_PUB.encode(p_dim7_level_id);
  -- 2280993 ends
 END IF;
 RETURN l_alert_url;
END BuildAlertRegURLTL;
--
--changed name
--added this function for targets schedulealert
FUNCTION  BuildAlertRegURLTarget
(p_measure_id                  IN   NUMBER := NULL
,p_plan_id		       IN   VARCHAR2 := NULL
,p_target_level_id  	       IN   NUMBER := NULL
,p_parameter1levelId	       IN   VARCHAR2 := NULL
,p_parameter1ValueId	       IN   VARCHAR2 := NULL
,p_parameter2levelId	       IN   VARCHAR2 := NULL
,p_parameter2ValueId	       IN   VARCHAR2 := NULL
,p_parameter3levelId           IN   VARCHAR2 := NULL
,p_parameter3ValueId           IN   VARCHAR2 := NULL
,p_parameter4levelId           IN   VARCHAR2 := NULL
,p_parameter4ValueId           IN   VARCHAR2 := NULL
,p_parameter5levelId           IN   VARCHAR2 := NULL
,p_parameter5ValueId           IN   VARCHAR2 := NULL
,p_parameter6levelId           IN   VARCHAR2 := NULL
,p_parameter6ValueId           IN   VARCHAR2 := NULL
,p_parameter7levelId           IN   VARCHAR2 := NULL
,p_parameter7ValueId           IN   VARCHAR2 := NULL
)
RETURN VARCHAR2
IS
    l_alert_url			VARCHAR2(32200);
    l_dbc			VARCHAR2(10000);
    l_servlet_agent		VARCHAR2(10000);
    l_encrypted_session_id	VARCHAR2(1000);
    l_session_id		NUMBER;
BEGIN
    l_session_id := icx_sec.g_session_id; --2751984
    l_encrypted_session_id := icx_call.encrypt3(l_session_id);

    fnd_profile.get(name=>'APPS_SERVLET_AGENT',
	            val => l_alert_url);
    l_alert_url := FND_WEB_CONFIG.trail_slash(l_alert_url) ||
		   'bisalrta.jsp?dbc=' || FND_WEB_CONFIG.DATABASE_ID
	           || G_AMPERSAND ||'sessionid='|| l_encrypted_session_id;
    IF (p_measure_id IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'perfMeasureId='
  -- 2280993 starts
--		      || wfa_html.conv_special_url_chars(p_measure_id);
		      || BIS_UTILITIES_PUB.encode(p_measure_id);
  -- 2280993 ends
    END IF;
    IF (p_plan_id IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'planId='
  -- 2280993 starts
--		      || wfa_html.conv_special_url_chars(p_plan_id);
		      || BIS_UTILITIES_PUB.encode(p_plan_id);
  -- 2280993 ends
    END IF;
    IF (p_target_level_id IS NOT NULL) THEN
       l_Alert_url := l_alert_url || G_AMPERSAND || 'targetLevelId='
  -- 2280993 starts
--		      ||wfa_html.conv_special_url_chars(p_target_level_id);
		      ||BIS_UTILITIES_PUB.encode(p_target_level_id);
  -- 2280993 ends
    END IF;
    IF (p_parameter1levelId IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'parameter1LevelId='
  -- 2280993 starts
--	              ||wfa_html.conv_special_url_chars(p_parameter1levelId);
	              ||BIS_UTILITIES_PUB.encode(p_parameter1levelId);
  -- 2280993 ends
    END IF;
    IF (p_parameter1ValueId IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'parameter1ValueId='
  -- 2280993 starts
--		      ||wfa_html.conv_special_url_chars(p_parameter1ValueId);
		      ||BIS_UTILITIES_PUB.encode(p_parameter1ValueId);
  -- 2280993 ends
    END IF;
    IF (p_parameter2levelId IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'parameter2LevelId='
  -- 2280993 starts
--	              ||wfa_html.conv_special_url_chars(p_parameter2levelId);
	              ||BIS_UTILITIES_PUB.encode(p_parameter2levelId);
  -- 2280993 ends
    END IF;
    IF (p_parameter2ValueId IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'parameter2ValueId='
  -- 2280993 starts
--		      ||wfa_html.conv_special_url_chars(p_parameter2ValueId);
		      ||BIS_UTILITIES_PUB.encode(p_parameter2ValueId);
  -- 2280993 ends
    END IF;
    IF (p_parameter3levelId IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'parameter3LevelId='
  -- 2280993 starts
--	              ||wfa_html.conv_special_url_chars(p_parameter3levelId);
	              ||BIS_UTILITIES_PUB.encode(p_parameter3levelId);
  -- 2280993 ends
    END IF;
    IF (p_parameter3ValueId IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'parameter3ValueId='
  -- 2280993 starts
--		      ||wfa_html.conv_special_url_chars(p_parameter3ValueId);
		      ||BIS_UTILITIES_PUB.encode(p_parameter3ValueId);
  -- 2280993 ends
    END IF;
    IF (p_parameter4levelId IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'parameter4LevelId='
  -- 2280993 starts
--	              ||wfa_html.conv_special_url_chars(p_parameter4levelId);
	              ||BIS_UTILITIES_PUB.encode(p_parameter4levelId);
  -- 2280993 ends
    END IF;
    IF (p_parameter4ValueId IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'parameter4ValueId='
  -- 2280993 starts
--		      ||wfa_html.conv_special_url_chars(p_parameter4ValueId);
		      ||BIS_UTILITIES_PUB.encode(p_parameter4ValueId);
  -- 2280993 ends
    END IF;
    IF (p_parameter5levelId IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'parameter5LevelId='
  -- 2280993 starts
--	              ||wfa_html.conv_special_url_chars(p_parameter5levelId);
	              ||BIS_UTILITIES_PUB.encode(p_parameter5levelId);
  -- 2280993 ends
    END IF;
    IF (p_parameter5ValueId IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'parameter5ValueId='
  -- 2280993 starts
--		      ||wfa_html.conv_special_url_chars(p_parameter5ValueId);
		      ||BIS_UTILITIES_PUB.encode(p_parameter5ValueId);
  -- 2280993 ends
    END IF;
    IF (p_parameter6levelId IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'parameter6LevelId='
  -- 2280993 starts
--	              ||wfa_html.conv_special_url_chars(p_parameter6levelId);
	              ||BIS_UTILITIES_PUB.encode(p_parameter6levelId);
  -- 2280993 ends
    END IF;
    IF (p_parameter6ValueId IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'parameter6ValueId='
  -- 2280993 starts
--		      ||wfa_html.conv_special_url_chars(p_parameter6ValueId);
		      ||BIS_UTILITIES_PUB.encode(p_parameter6ValueId);
  -- 2280993 ends
    END IF;
    IF (p_parameter7levelId IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'parameter7LevelId='
  -- 2280993 starts
--	              ||wfa_html.conv_special_url_chars(p_parameter7levelId);
	              ||BIS_UTILITIES_PUB.encode(p_parameter7levelId);
  -- 2280993 ends
    END IF;
    IF (p_parameter7ValueId IS NOT NULL) THEN
       l_alert_url := l_alert_url || G_AMPERSAND || 'parameter7ValueId='
  -- 2280993 starts
--		      ||wfa_html.conv_special_url_chars(p_parameter7ValueId);
		      ||BIS_UTILITIES_PUB.encode(p_parameter7ValueId);
  -- 2280993 ends
    END IF;
    RETURN l_alert_url;
END BuildAlertRegURLTarget;
--
PROCEDURE GET_TARGET_DETAILS
(p_measure_id		      IN    NUMBER
,p_measure_short_name	      IN    VARCHAR2 DEFAULT NULL
,p_user_id		      IN    VARCHAR2
,p_responsibility_id          IN    VARCHAR2
,p_dim1_level_short_name      IN    VARCHAR2
,p_dim2_level_short_name      IN    VARCHAR2
,p_dim3_level_short_name      IN    VARCHAR2
,p_Dim4_level_short_name      IN    VARCHAR2
,p_dim5_level_short_name      IN    VARCHAR2
,p_dim6_level_short_name      IN    VARCHAR2
,p_dim7_level_short_name      IN    VARCHAR2
,p_dim1_level_value_id        IN    VARCHAR2
,P_dim2_level_value_id        IN    VARCHAR2
,p_dim3_level_Value_id        IN    VARCHAR2
,p_dim4_level_Value_id        IN    VARCHAR2
,p_dim5_level_Value_id        IN    VARCHAR2
,p_Dim6_level_value_id        IN    VARCHAR2
,p_dim7_level_Value_id        IN    VARCHAR2
,p_plan_id           	      IN    NUMBER
,x_target_level_id	      OUT NOCOPY   NUMBER
,x_target_level_short_name    OUT NOCOPY   VARCHAR2
,x_target_id                  OUT NOCOPY   NUMBER
,x_target_value               OUT NOCOPY   VARCHAR2
,x_dim1_level_name            OUT NOCOPY   VARCHAR2
,x_dim2_level_name            OUT NOCOPY   VARCHAR2
,x_dim3_level_name            OUT NOCOPY   VARCHAR2
,x_dim4_level_name            OUT NOCOPY   VARCHAR2
,x_dim5_level_name            OUT NOCOPY   VARCHAR2
,x_dim6_level_name            OUT NOCOPY   VARCHAR2
,x_dim7_level_name            OUT NOCOPY   VARCHAR2
,x_dim1_level_value_name      OUT NOCOPY   VARCHAR2
,x_dim2_level_value_name      OUT NOCOPY   VARCHAR2
,x_dim3_level_value_name      OUT NOCOPY   VARCHAR2
,x_dim4_level_value_name      OUT NOCOPY   VARCHAR2
,x_dim5_level_value_name      OUT NOCOPY   VARCHAR2
,x_dim6_level_value_name      OUT NOCOPY   VARCHAR2
,x_dim7_level_value_name      OUT NOCOPY   VARCHAR2
,x_dim1_level_id              OUT NOCOPY   NUMBER
,x_dim2_level_id              OUT NOCOPY   NUMBER
,x_dim3_level_id              OUT NOCOPY   NUMBER
,x_dim4_level_id              OUT NOCOPY   NUMBER
,x_dim5_level_id              OUT NOCOPY   NUMBER
,x_dim6_level_id              OUT NOCOPY   NUMBER
,x_dim7_level_id              OUT NOCOPY   NUMBER
,x_range1_low		      OUT NOCOPY   NUMBER
,x_range2_low                 OUT NOCOPY   NUMBER
,x_range3_low                 OUT NOCOPY   NUMBER
,x_range1_high                OUT NOCOPY   NUMBER
,x_range2_high                OUT NOCOPY   NUMBER
,x_range3_high                OUT NOCOPY   NUMBER
,x_notify_resp1_id            OUT NOCOPY   NUMBER
,x_notify_resp2_id            OUT NOCOPY   NUMBER
,x_notify_resp3_id            OUT NOCOPY   NUMBER
,x_notify_resp1_short_name    OUT NOCOPY   VARCHAR2
,x_notify_resp2_short_name    OUT NOCOPY   VARCHAR2
,x_notify_resp3_short_name    OUT NOCOPY   VARCHAR2
,x_notify_resp1_name          OUT NOCOPY   VARCHAR2
,x_notify_resp2_name          OUT NOCOPY   VARCHAR2
,x_notify_resp3_name          OUT NOCOPY   VARCHAR2
,x_show_subscribe_screen      OUT NOCOPY   VARCHAR2
,x_msg_count                  OUT NOCOPY   NUMBER
,x_return_status              OUT NOCOPY   VARCHAR2
,x_msg_data                   OUT NOCOPY   VARCHAR2
,x_measure_name               OUT NOCOPY   VARCHAR2
,x_plan_name                  OUT NOCOPY   VARCHAR2
,x_measure_id 		      OUT NOCOPY   NUMBER
,x_unit_of_measure            OUT NOCOPY   VARCHAR2
,x_dim1_level_value_id        OUT NOCOPY   VARCHAR2
,x_dim2_level_value_id        OUT NOCOPY   VARCHAR2
,x_dim3_level_Value_id        OUT NOCOPY   VARCHAR2
,x_dim4_level_Value_id        OUT NOCOPY   VARCHAR2
,x_dim5_level_Value_id        OUT NOCOPY   VARCHAR2
,x_Dim6_level_value_id        OUT NOCOPY   VARCHAR2
,x_dim7_level_Value_id        OUT NOCOPY   VARCHAR2
,x_dim1_level_short_name      OUT NOCOPY   VARCHAR2
,x_dim2_level_short_name      OUT NOCOPY   VARCHAR2
,x_dim3_level_short_name      OUT NOCOPY   VARCHAR2
,x_Dim4_level_short_name      OUT NOCOPY   VARCHAR2
,x_dim5_level_short_name      OUT NOCOPY   VARCHAR2
,x_dim6_level_short_name      OUT NOCOPY   VARCHAR2
,x_dim7_level_short_name      OUT NOCOPY   VARCHAR2
,x_time_sequence_number       OUT NOCOPY   NUMBER
,x_org_sequence_number        OUT NOCOPY   NUMBER
)
IS
  p_dim1_level_id	      NUMBER;
  p_dim2_level_id             NUMBER;
  p_dim3_level_id             NUMBER;
  p_dim4_level_id             NUMBER;
  p_dim5_level_id             NUMBER;
  p_dim6_level_id             NUMBER;
  p_dim7_level_id             NUMBER;
  l_dim1_level_id             NUMBER;
  l_dim2_level_id             NUMBER;
  l_dim3_level_id             NUMBER;
  l_dim4_level_id             NUMBER;
  l_dim5_level_id             NUMBER;
  l_dim6_level_id             NUMBER;
  l_dim7_level_id             NUMBER;
  l_dim1_level_value_id       VARCHAR2(32000);
  l_dim2_level_value_id       VARCHAR2(32000);
  l_dim3_level_value_id       VARCHAR2(32000);
  l_dim4_level_value_id       VARCHAR2(32000);
  l_dim5_level_value_id       VARCHAR2(32000);
  l_dim6_level_value_id       VARCHAR2(32000);
  l_dim7_level_value_id       VARCHAR2(32000);
  l_dim1_id				NUMBER;
  l_dim2_id				NUMBER;
  l_dim3_id				NUMBER;
  l_dim4_id                             NUMBER;
  l_dim5_id				NUMBER;
  l_dim6_id				NUMBER;
  l_dim7_id				NUMBER;
  l_return_Status             VARCHAR2(32000);
  l_status                    VARCHAR2(32000);
  l_measure_rec		      BIS_MEASURE_PUB.MEASURE_REC_TYPE;
  l_target_level_rec          BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
  l_target_level_rec_p        BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
  l_target_rec                BIS_TARGET_PUB.TARGET_REC_TYPE;
  l_target_rec_p              BIS_TARGET_PUB.TARGET_REC_TYPE;
  l_error_tbl                 BIS_UTILITIES_PUB.ERROR_TBL_TYPE;
  l_dim_level_rec             BIS_DIMENSION_LEVEL_PUB.DIMENSION_LEVEL_REC_TYPE;
  l_dim_level_value_rec       BIS_DIM_lEVEL_VALUE_PUB.DIM_LEVEL_VALUE_REC_TYPE;
  G_PKG_NAME                  VARCHAR2(32000):= 'BIS_PMF_DEFINER_WRAPPER_PVT';
  l_api_name                  VARCHAR2(32000):= 'GET_TARGET_DETAILS';
  l_measure_security_rec      BIS_MEASURE_SECURITY_PUB.MEASURE_SECURITY_REC_TYPE;
  l_dlc_sec 		      VARCHAR2(1);
  l_time_level_id             number;
  l_time_level_short_name     varchar2(32000);
  l_time_level_name           varchar2(32000);
  l_org_level_id             number;
  l_org_level_short_name     varchar2(32000);
  l_org_level_name           varchar2(32000);
  CURSOR c_dim_lvl(p_dim_level_short_name in varchar2) IS
  SELECT level_id
  FROM bis_levels
  WHERE short_name=p_dim_level_short_name;
  CURSOR c_resp IS
  SELECT responsibility_id
  FROM fnd_user_resp_groups
  WHERE user_id=p_user_id;
  CURSOR c_indresp(p_target_level_id IN NUMBER) IS
  SELECT responsibility_id
  FROM bis_indicator_Resps
  WHERE target_level_id=p_target_level_id;
  l_parameter_Set_rec         BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_parameter_set_exist       BOOLEAN;
  l_notifiers_code            VARCHAR2(32000);
BEGIN
  FND_MSG_PUB.INITIALIZE;
  l_target_level_rec.measure_short_name := p_measure_short_name;
  l_target_level_rec.dimension1_level_short_name := p_dim1_level_short_name;
  l_target_level_rec.dimension2_level_short_name := p_dim2_level_short_name;
  l_target_level_rec.dimension3_level_short_name := p_dim3_level_short_name;
  l_target_level_rec.dimension4_level_short_name := p_dim4_level_short_name;
  l_target_level_rec.dimension5_level_short_name := p_dim5_level_short_name;
  l_target_level_rec.dimension6_level_short_name := p_dim6_level_short_name;
  l_target_level_rec.dimension7_level_short_name := p_dim7_level_short_name;
  l_target_rec.plan_id := p_plan_id;
  l_target_rec.dim1_level_value_id := p_dim1_level_value_id;
  l_target_rec.dim2_level_value_id := p_dim2_level_value_id;
  l_target_rec.dim3_level_value_id := p_dim3_level_value_id;
  l_target_rec.dim4_level_value_id := p_dim4_level_value_id;
  l_target_rec.dim5_level_value_id := p_dim5_level_value_id;
  l_target_rec.dim6_level_value_id := p_dim6_level_value_id;
  l_target_rec.dim7_level_value_id := p_dim7_level_value_id;
  l_target_level_rec_p := l_target_level_rec;
  l_target_rec_p := l_target_rec;
  BIS_TARGET_PUB.RETRIEVE_TARGET_FROM_SHNMS
  (p_api_version      => 1.0
  ,p_target_level_rec => l_target_level_rec_p
  ,p_Target_Rec       => l_target_rec_p
  ,x_Target_Level_Rec => l_target_level_rec
  ,x_Target_Rec       => l_target_rec
  ,x_return_status    => l_return_status
  ,x_error_Tbl        => l_error_tbl
  );
  IF (l_target_level_rec.target_level_id IS NULL)
  THEN
     FND_MESSAGE.SET_NAME('BIS','BIS_NO_DLC_ACCESS');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF (l_return_Status <> FND_API.G_RET_STS_ERROR) THEN
     --Check if the user has access to set the target . IF not throw him/her/it back to the
     --Reports Page
     l_dlc_sec := 'N';
     FOR c_rec IN c_resp LOOP
        l_measure_security_rec.target_level_id := BIS_UTILITIES_PVT.checkmissnum(l_target_level_rec.target_level_id);
        l_measure_security_rec.responsibility_id := c_rec.responsibility_id;
        /* This does not seem to work.
        BIS_MEASURE_SECURITY_PUB.VALIDATE_MEASURE_SECURITY
        (p_api_version           => 1.0
        ,p_Measure_Security_Rec  => l_measure_security_rec
        ,x_return_status         => l_return_status
        ,x_error_Tbl             => l_error_tbl
        );
        IF (l_return_status <> FND_API.G_RET_STS_ERROR) THEN
           l_dlc_sec := 'Y';
           EXIT;
        END IF;
        */
        FOR c_indrec IN c_indresp(l_target_level_rec.target_level_id) LOOP
            IF (c_indrec.responsibility_id = c_rec.responsibility_id)
            THEN
                l_dlc_sec := 'Y';
                EXIT;
            END IF;
        END LOOP;
     END LOOP;
     IF (l_dlc_sec = 'N') THEN
             FND_MESSAGE.SET_NAME('BIS', 'BIS_NO_SECURITY_ACCESS');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
     END IF;
     x_measure_name          := BIS_UTILITIES_PVT.checkmisschar(l_target_level_Rec.measure_name);
     x_measure_id	     := BIS_UTILITIES_PVT.checkmissnum(l_target_level_rec.measure_id);
     x_target_level_id       := BIS_UTILITIES_PVT.checkmissnum(l_target_level_rec.target_level_id);
     x_dim1_level_name       := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.dimension1_level_name);
     x_dim2_level_name       := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.dimension2_level_name);
     x_dim3_level_name       := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.dimension3_level_name);
     x_dim4_level_name       := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.dimension4_level_name);
     x_dim5_level_name       := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.dimension5_level_name);
     x_dim6_level_name       := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.dimension6_level_name);
     x_dim7_level_name       := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.dimension7_level_name);
     x_dim1_level_id         := BIS_UTILITIES_PVT.checkmissnum(l_target_level_rec.dimension1_level_id);
     x_dim2_level_id         := BIS_UTILITIES_PVT.checkmissnum(l_target_level_rec.dimension2_level_id);
     x_dim3_level_id         := BIS_UTILITIES_PVT.checkmissnum(l_target_level_rec.dimension3_level_id);
     x_dim4_level_id         := BIS_UTILITIES_PVT.checkmissnum(l_target_level_rec.dimension4_level_id);
     x_dim5_level_id         := BIS_UTILITIES_PVT.checkmissnum(l_target_level_rec.dimension5_level_id);
     x_dim6_level_id         := BIS_UTILITIES_PVT.checkmissnum(l_target_level_rec.dimension6_level_id);
     x_dim7_level_id         := BIS_UTILITIES_PVT.checkmissnum(l_target_level_rec.dimension7_level_id);
     x_dim1_level_value_name := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.dim1_level_value_name);
     x_dim2_level_value_name := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.dim2_level_value_name);
     x_dim3_level_value_name := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.dim3_level_value_name);
     x_dim4_level_value_name := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.dim4_level_value_name);
     x_dim5_level_value_name := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.dim5_level_value_name);
     x_dim6_level_value_name := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.dim6_level_value_name);
     x_dim7_level_value_name := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.dim7_level_value_name);
     x_dim1_level_short_name := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.dimension1_level_short_name);
     x_dim2_level_short_name := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.dimension2_level_short_name);
     x_dim3_level_short_name := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.dimension3_level_short_name);
     x_dim4_level_short_name := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.dimension4_level_short_name);
     x_dim5_level_short_name := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.dimension5_level_short_name);
     x_dim6_level_short_name := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.dimension6_level_short_name);
     x_dim7_level_short_name := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.dimension7_level_short_name);
     x_target_value          := BIS_UTILITIES_PVT.checkmissnum(l_target_rec.target);
     x_target_id             := BIS_UTILITIES_PVT.checkmissnum(l_target_rec.target_id);
     --x_target_id             := l_target_rec.target_id;
     --added this for UOM
     x_unit_of_measure       := BIS_UTILITIES_PVT.checkmisschar(l_target_level_rec.Unit_of_Measure);
     IF (x_target_id = 0) THEN
        x_target_id := null;
     END IF;
     x_range1_low            := BIS_UTILITIES_PVT.checkmissnum(l_target_rec.range1_low);
     x_range2_low            := BIS_UTILITIES_PVT.checkmissnum(l_target_rec.range2_low);
     x_range3_low            := BIS_UTILITIES_PVT.checkmissnum(l_target_rec.range3_low);
     x_range1_high           := BIS_UTILITIES_PVT.checkmissnum(l_target_rec.range1_high);
     x_range2_high           := BIS_UTILITIES_PVT.checkmissnum(l_target_rec.range2_high);
     x_range3_high           := BIS_UTILITIES_PVT.checkmissnum(l_target_rec.range3_high);
     x_plan_name             := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.plan_name);
     x_notify_resp1_id       := BIS_UTILITIES_PVT.checkmissnum(l_target_rec.notify_resp1_id);
     x_notify_resp2_id       := BIS_UTILITIES_PVT.checkmissnum(l_target_rec.notify_resp2_id);
     x_notify_resp3_id       := BIS_UTILITIES_PVT.checkmissnum(l_target_rec.notify_resp3_id);
     x_notify_resp1_short_name := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.notify_resp1_short_name);
     x_notify_resp2_short_name := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.notify_resp2_short_name);
     x_notify_resp3_short_name := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.notify_resp3_short_name);
     x_notify_resp1_name       := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.notify_resp1_name);
     x_notify_resp2_name       := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.notify_resp2_name);
     x_notify_resp3_name       := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.notify_resp3_name);

     x_dim1_level_value_id := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.dim1_level_value_id);
     x_dim2_level_value_id := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.dim2_level_value_id);
     x_dim3_level_value_id := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.dim3_level_value_id);
     x_dim4_level_value_id := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.dim4_level_value_id);
     x_dim5_level_value_id := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.dim5_level_value_id);
     x_dim6_level_value_id := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.dim6_level_value_id);
     x_dim7_level_value_id := BIS_UTILITIES_PVT.checkmisschar(l_target_rec.dim7_level_value_id);
     BEGIN
     SELECT name INTO x_plan_name
     FROM BIS_BUSINESS_PLANS_VL
     WHERE PLAN_ID=p_plan_id;
     END;
     --Check if the alert is already scheduled . This will be used to determine whether to show the
     -- Alert button
     l_parameter_set_Rec.registration_id:=null;
     l_parameter_set_rec.performance_measure_id := BIS_UTILITIES_PVT.checkmissnum(l_target_level_rec.measure_id);
     l_parameter_Set_rec.target_level_id := BIS_UTILITIES_PVT.checkmissnum(l_target_level_Rec.target_level_id);
    l_parameter_set_rec.plan_id := p_plan_id;
    l_parameter_set_rec.parameter1_value := p_dim1_level_value_id;
    l_parameter_set_rec.parameter2_value := p_dim2_level_value_id;
    l_parameter_set_rec.parameter3_value := p_dim3_level_value_id;
    l_parameter_set_rec.parameter4_value := p_dim4_level_value_id;
    l_parameter_set_rec.parameter5_value := p_dim5_level_value_id;
    l_parameter_set_rec.parameter6_value := p_dim6_level_value_id;
    l_parameter_set_rec.parameter7_value := p_dim7_level_value_id;
    BIS_PMF_DEFINER_WRAPPER_PVT.GET_TIME_LEVEL_ID
    (p_performance_measure_id   => l_parameter_set_rec.performance_measure_id
    ,p_target_level_id          => l_parameter_Set_rec.target_level_id
    ,p_perf_measure_short_name  => p_measure_short_name
    ,p_target_level_short_name  => null
    ,x_Sequence_no              => x_time_sequence_number
    ,x_dim_level_id             => l_time_level_id
    ,x_dim_level_short_name     => l_time_level_short_name
    ,x_dim_level_name           => l_time_level_name
    ,x_return_status            => l_return_Status
    );
    l_parameter_set_rec.time_dimension_level_id := l_time_level_id;
     l_parameter_set_exist := BIS_PMF_ALERT_REG_PUB.Parameter_set_exist
                              (p_api_version      => 1.0
                              ,p_Param_Set_Rec    => l_parameter_set_Rec
                              ,x_notifiers_code   => l_notifiers_code
                              ,x_return_status    => l_return_Status
                              ,x_error_Tbl        => l_error_Tbl
                              );
     IF (l_parameter_set_exist) THEN
        x_show_subscribe_screen := 'Y';
     ELSE
        x_show_subscribe_screen := 'N';
     END IF;

     BIS_PMF_DEFINER_WRAPPER_PVT.GET_ORG_LEVEL_ID
    (p_performance_measure_id   => l_parameter_set_rec.performance_measure_id
    ,p_target_level_id          => l_parameter_Set_rec.target_level_id
    ,p_perf_measure_short_name  => p_measure_short_name
    ,p_target_level_short_name  => null
    ,x_Sequence_no              => x_org_sequence_number
    ,x_dim_level_id             => l_org_level_id
    ,x_dim_level_short_name     => l_org_level_short_name
    ,x_dim_level_name           => l_org_level_name
    ,x_return_status            => l_return_Status
    );

  ELSE
     BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
     (p_error_tbl   => l_error_tbl
     ,x_return_status    => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     );
  END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      IF c_dim_lvl%ISOPEN THEN -- bug 3045087
       CLOSE c_dim_lvl;
      END IF;
      IF c_resp%ISOPEN THEN -- bug 3045087
       CLOSE c_resp;
      END IF;
      IF c_indresp%ISOPEN THEN -- bug 3045087
       CLOSE c_indresp;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count    =>    x_msg_count,
        p_data     =>    x_msg_data
      );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF c_dim_lvl%ISOPEN THEN -- bug 3045087
       CLOSE c_dim_lvl;
      END IF;
      IF c_resp%ISOPEN THEN -- bug 3045087
       CLOSE c_resp;
      END IF;
      IF c_indresp%ISOPEN THEN -- bug 3045087
       CLOSE c_indresp;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count    =>    x_msg_count,
        p_data     =>    x_msg_data
      );
  WHEN OTHERS THEN
      IF c_dim_lvl%ISOPEN THEN -- bug 3045087
       CLOSE c_dim_lvl;
      END IF;
      IF c_resp%ISOPEN THEN -- bug 3045087
       CLOSE c_resp;
      END IF;
      IF c_indresp%ISOPEN THEN -- bug 3045087
       CLOSE c_indresp;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
          FND_MSG_PUB.Add_Exc_Msg
          ( G_PKG_NAME,
            l_api_name
          );
       END IF;
       FND_MSG_PUB.Count_And_Get
       ( p_count    =>    x_msg_count,
         p_data     =>    x_msg_data
       );

END;
PROCEDURE UPDATE_MEASURE_SECURITY
  (
    p_target_level_id     IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM,
    p_responsibilities    IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY VARCHAR2,
    x_msg_data            OUT NOCOPY VARCHAR2
  )
IS
  l_return_status         VARCHAR2(32000);
  l_error_tbl             BIS_UTILITIES_PUB.ERROR_TBL_TYPE;
  l_target_level_rec      BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
  l_measure_security_rec  BIS_MEASURE_SECURITY_PUB.MEASURE_SECURITY_REC_TYPE;
  l_responsibilities      VARCHAR2(32000);
  l_responsibility_id     PLS_INTEGER;
  l_pos                   PLS_INTEGER;
BEGIN
    FND_MSG_PUB.initialize;
  -- Delete all responsibility associated with this target level

  IF (BIS_UTILITIES_PUB.VALUE_MISSING(p_target_level_id) = FND_API.G_FALSE) THEN
    l_target_level_rec.target_level_id := p_target_level_id;
    l_measure_security_rec.target_level_id := p_target_level_id;
  END IF;

  BIS_MEASURE_SECURITY_PVT.DELETE_MEASURE_SECURITY
    (
      p_api_version => g_api_version,
      p_commit => FND_API.G_FALSE,
      p_target_level_rec => l_target_level_rec,
      x_return_status => l_return_status,
      x_error_tbl => l_error_tbl
    );

  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
    (
      p_error_tbl => l_error_tbl,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
    );

  -- Add responsibilities to this target level

  l_responsibilities := p_responsibilities;

  WHILE LENGTH(l_responsibilities) > 0 LOOP
    l_pos := INSTR(l_responsibilities, '+');

    IF l_pos > 0 THEN
      l_responsibility_id := SUBSTR(l_responsibilities, 1, l_pos - 1);
      l_responsibilities := SUBSTR(l_responsibilities, l_pos + 1, LENGTH(l_responsibilities));
    ELSE
      l_responsibility_id := l_responsibilities;
      l_responsibilities := '';
    END IF;

    IF (BIS_UTILITIES_PUB.VALUE_MISSING(l_responsibility_id) = FND_API.G_FALSE) THEN
      l_measure_security_rec.responsibility_id := l_responsibility_id;

      BIS_MEASURE_SECURITY_PVT.Create_Measure_Security
        (
          p_api_version => g_api_version,
          p_commit => FND_API.G_FALSE,
          p_measure_security_rec => l_measure_security_rec,
          x_return_status => l_return_status,
          x_error_tbl => l_error_tbl
        );

      BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
        (
          p_error_tbl => l_error_tbl,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data
        );
    END IF;
  END LOOP;
END UPDATE_MEASURE_SECURITY;




PROCEDURE GET_TARGET_LEVEL_NAMES
  (
    p_target_level_id     IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM,
    x_measure_name        OUT NOCOPY VARCHAR2,
    x_dim_names           OUT NOCOPY VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY VARCHAR2,
    x_msg_data            OUT NOCOPY VARCHAR2
  )
IS
  l_target_level_rec      BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
  l_target_level_rec_p    BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
  l_error_tbl             BIS_UTILITIES_PUB.ERROR_TBL_TYPE;
  l_names                 VARCHAR2(32000) := '';
  l_sep                   VARCHAR2(2) := '';
BEGIN
  IF (BIS_UTILITIES_PUB.VALUE_MISSING(p_target_level_id) = FND_API.G_FALSE) THEN
    l_target_level_rec.target_level_id := p_target_level_id;
  END IF;

  l_target_level_rec_p := l_target_level_rec;
  BIS_TARGET_LEVEL_PUB.RETRIEVE_TARGET_LEVEL
    (
      p_api_version => g_api_version,
      p_target_level_rec => l_target_level_rec_p,
      p_all_info => FND_API.G_TRUE,
      x_Target_Level_Rec => l_target_level_rec,
      x_return_status => x_return_status,
      x_error_Tbl => l_error_tbl
    );

  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
    (
      p_error_tbl => l_error_tbl,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
    );

  IF l_target_level_rec.dimension1_level_name <> FND_API.G_MISS_CHAR THEN
    l_names := l_names || l_sep || l_target_level_rec.dimension1_level_name;
    l_sep := ', ';
  END IF;

  IF l_target_level_rec.dimension2_level_name <> FND_API.G_MISS_CHAR THEN
    l_names := l_names || l_sep || l_target_level_rec.dimension2_level_name;
    l_sep := ', ';
  END IF;

  IF l_target_level_rec.dimension3_level_name <> FND_API.G_MISS_CHAR THEN
    l_names := l_names || l_sep || l_target_level_rec.dimension3_level_name;
    l_sep := ', ';
  END IF;

  IF l_target_level_rec.dimension4_level_name <> FND_API.G_MISS_CHAR THEN
    l_names := l_names || l_sep || l_target_level_rec.dimension4_level_name;
    l_sep := ', ';
  END IF;

  IF l_target_level_rec.dimension5_level_name <> FND_API.G_MISS_CHAR THEN
    l_names := l_names || l_sep || l_target_level_rec.dimension5_level_name;
    l_sep := ', ';
  END IF;

  IF l_target_level_rec.dimension6_level_name <> FND_API.G_MISS_CHAR THEN
    l_names := l_names || l_sep || l_target_level_rec.dimension6_level_name;
    l_sep := ', ';
  END IF;

  IF l_target_level_rec.dimension7_level_name <> FND_API.G_MISS_CHAR THEN
    l_names := l_names || l_sep || l_target_level_rec.dimension7_level_name;
    l_sep := ', ';
  END IF;

  x_measure_name := l_target_level_rec.measure_name;
  x_dim_names := l_names;

END GET_TARGET_LEVEL_NAMES;

FUNCTION HAS_TARGET_ACCESS
( p_user_id IN NUMBER
 ,p_measure_id IN NUMBER
 ,p_target_level_id IN NUMBER
)
RETURN NUMBER
IS
l_dummy NUMBER;
l_has_auth NUMBER;

cursor cr_tar_auth is
     select target_level_id from bisfv_target_levels where measure_id = p_measure_id
     and target_level_id in (select distinct ir.target_level_id from bis_indicator_resps  ir
     , fnd_user_resp_groups ur
     , bisbv_target_levels  il
      where ur.user_id           = p_user_id
      and   ir.responsibility_id = ur.responsibility_id
      and   il.target_level_id   = ir.target_level_id and il.target_level_id=p_target_level_id);

BEGIN
l_has_auth := 0;

  open cr_tar_auth;
  fetch cr_tar_auth into l_dummy;
  if (cr_tar_auth%NOTFOUND) then
    l_has_auth := 0;
  else
    l_has_auth := 1;
  end if;
  close cr_tar_auth;

return l_has_auth;

EXCEPTION
 WHEN OTHERS THEN
    IF cr_tar_auth%ISOPEN THEN -- bug 3045087
      CLOSE cr_tar_auth;
    END IF;
END;

-- Fix for 2126074 starts here
Procedure Retrieve_Performance_Measure
(p_Measure_ID                 IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Measure_Short_Name         IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Measure_Name               IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Description                IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Dimension1_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension2_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension3_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension4_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension5_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension6_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension7_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Unit_Of_Measure_Class      IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_actual_data_source_type    IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_actual_data_source         IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_function_name              IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_comparison_source          IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_increase_in_measure        IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,x_return_status              OUT NOCOPY  VARCHAR2
,x_msg_count                  OUT NOCOPY  VARCHAR2
,x_msg_data                   OUT NOCOPY  VARCHAR2
,x_Measure_ID                 OUT NOCOPY  NUMBER
,x_Measure_Short_Name         OUT NOCOPY  VARCHAR2
,x_Measure_Name               OUT NOCOPY  VARCHAR2
,x_Description                OUT NOCOPY  VARCHAR2
,x_Dimension1_ID              OUT NOCOPY  NUMBER
,x_Dimension2_ID              OUT NOCOPY  NUMBER
,x_Dimension3_ID              OUT NOCOPY  NUMBER
,x_Dimension4_ID              OUT NOCOPY  NUMBER
,x_Dimension5_ID              OUT NOCOPY  NUMBER
,x_Dimension6_ID              OUT NOCOPY  NUMBER
,x_Dimension7_ID              OUT NOCOPY  NUMBER
,x_Unit_Of_Measure_Class      OUT NOCOPY  VARCHAR2
,x_actual_data_source_type    OUT NOCOPY  VARCHAR2
,x_actual_data_source         OUT NOCOPY  VARCHAR2
--
,x_region_code                OUT NOCOPY  VARCHAR2
,x_attribute_code             OUT NOCOPY  VARCHAR2
--
,x_function_name              OUT NOCOPY  VARCHAR2
,x_comparison_source          OUT NOCOPY  VARCHAR2
,x_increase_in_measure        OUT NOCOPY  VARCHAR2)
IS

l_enable_link     VARCHAR2(1) ;
Begin

--Redirecting this API to the new overloaded API for enh 2440739

Retrieve_Performance_Measure
(p_Measure_ID                 => p_Measure_ID
,p_Measure_Short_Name         => p_Measure_Short_Name
,p_Measure_Name               => p_Measure_Name
,p_Description                => p_Description
,p_Dimension1_ID              => p_Dimension1_ID
,p_Dimension2_ID              => p_Dimension2_ID
,p_Dimension3_ID              => p_Dimension3_ID
,p_Dimension4_ID              => p_Dimension4_ID
,p_Dimension5_ID              => p_Dimension5_ID
,p_Dimension6_ID              => p_Dimension6_ID
,p_Dimension7_ID              => p_Dimension7_ID
,p_Unit_Of_Measure_Class      => p_Unit_Of_Measure_Class
,p_actual_data_source_type    => p_actual_data_source_type
,p_actual_data_source         => p_actual_data_source
,p_function_name              => p_function_name
,p_comparison_source          => p_comparison_source
,p_increase_in_measure        => p_increase_in_measure
,p_enable_link                => NULL
,x_return_status              => x_return_status
,x_msg_count                  => x_msg_count
,x_msg_data                   => x_msg_data
,x_Measure_ID                 => x_Measure_ID
,x_Measure_Short_Name         => x_Measure_Short_Name
,x_Measure_Name               => x_Measure_Name
,x_Description                => x_Description
,x_Dimension1_ID              => x_Dimension1_ID
,x_Dimension2_ID              => x_Dimension2_ID
,x_Dimension3_ID              => x_Dimension3_ID
,x_Dimension4_ID              => x_Dimension4_ID
,x_Dimension5_ID              => x_Dimension5_ID
,x_Dimension6_ID              => x_Dimension6_ID
,x_Dimension7_ID              => x_Dimension7_ID
,x_Unit_Of_Measure_Class      => x_Unit_Of_Measure_Class
,x_actual_data_source_type    => x_actual_data_source_type
,x_actual_data_source         => x_actual_data_source
--
,x_region_code                => x_region_code
,x_attribute_code             => x_attribute_code
--
,x_function_name              => x_function_name
,x_comparison_source          => x_comparison_source
,x_increase_in_measure        => x_increase_in_measure
,x_enable_link                => l_enable_link
);
END Retrieve_Performance_Measure;

-- Fix for 2126074 ends here
-- overloaded with enable_link param for bug 2440739
Procedure Retrieve_Performance_Measure
(p_Measure_ID                 IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Measure_Short_Name         IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Measure_Name               IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Description                IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_Dimension1_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension2_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension3_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension4_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension5_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension6_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Dimension7_ID              IN   NUMBER   := BIS_UTILITIES_PUB.G_NULL_NUM
,p_Unit_Of_Measure_Class      IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_actual_data_source_type    IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_actual_data_source         IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_function_name              IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_comparison_source          IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_increase_in_measure        IN   VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
,p_enable_link                IN   VARCHAR2 := c_hide_url -- 2440739
,x_return_status              OUT NOCOPY  VARCHAR2
,x_msg_count                  OUT NOCOPY  VARCHAR2
,x_msg_data                   OUT NOCOPY  VARCHAR2
,x_Measure_ID                 OUT NOCOPY  NUMBER
,x_Measure_Short_Name         OUT NOCOPY  VARCHAR2
,x_Measure_Name               OUT NOCOPY  VARCHAR2
,x_Description                OUT NOCOPY  VARCHAR2
,x_Dimension1_ID              OUT NOCOPY  NUMBER
,x_Dimension2_ID              OUT NOCOPY  NUMBER
,x_Dimension3_ID              OUT NOCOPY  NUMBER
,x_Dimension4_ID              OUT NOCOPY  NUMBER
,x_Dimension5_ID              OUT NOCOPY  NUMBER
,x_Dimension6_ID              OUT NOCOPY  NUMBER
,x_Dimension7_ID              OUT NOCOPY  NUMBER
,x_Unit_Of_Measure_Class      OUT NOCOPY  VARCHAR2
,x_actual_data_source_type    OUT NOCOPY  VARCHAR2
,x_actual_data_source         OUT NOCOPY  VARCHAR2
--
,x_region_code                OUT NOCOPY  VARCHAR2
,x_attribute_code             OUT NOCOPY  VARCHAR2
--
,x_function_name              OUT NOCOPY  VARCHAR2
,x_comparison_source          OUT NOCOPY  VARCHAR2
,x_increase_in_measure        OUT NOCOPY  VARCHAR2
,x_enable_link                OUT NOCOPY  VARCHAR2
)
IS

l_return_status   varchar2(32000);
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
l_measure_rec     BIS_MEASURE_PUB.Measure_rec_type;
x_measure_rec     BIS_MEASURE_PUB.Measure_rec_type;
l_ret             VARCHAR2(32000);

Begin

  FND_MSG_PUB.initialize;
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Measure_Id);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Measure_Id := p_Measure_Id;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Measure_Short_Name);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Measure_Short_Name := p_Measure_Short_Name;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Measure_Name);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Measure_Name := p_Measure_Name;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Description);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Description := p_Description;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Dimension1_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Dimension1_ID := p_Dimension1_ID;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Dimension2_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Dimension2_ID := p_Dimension2_ID;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Dimension3_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Dimension3_ID := p_Dimension3_ID;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Dimension4_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Dimension4_ID := p_Dimension4_ID;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Dimension5_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Dimension5_ID := p_Dimension5_ID;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Dimension6_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Dimension6_ID := p_Dimension6_ID;
  END IF;

  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Dimension7_ID);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Dimension7_ID := p_Dimension7_ID;
  END IF;

  -----
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_Unit_Of_Measure_Class);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.Unit_Of_Measure_Class := p_Unit_Of_Measure_Class;
  END IF;

   l_ret := BIS_UTILITIES_PUB.Value_Missing(p_actual_data_source_type);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.actual_data_source_type := p_actual_data_source_type;
  END IF;
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_actual_data_source);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.actual_data_source := p_actual_data_source;
  END IF;
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_function_name);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.function_name := p_function_name;
  END IF;
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_comparison_source);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.comparison_source := p_comparison_source;
  END IF;
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_increase_in_measure);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.increase_in_measure := p_increase_in_measure;
  END IF;
--2440739
  l_ret := BIS_UTILITIES_PUB.Value_Missing(p_enable_link);
  IF (l_ret = FND_API.G_FALSE) THEN
    l_measure_rec.increase_in_measure := p_enable_link;
  END IF;
--2440739
  BIS_MEASURE_PUB.Retrieve_Measure( p_api_version   => g_api_version
                                  , p_Measure_Rec   => l_measure_rec
                                  , p_all_info      => fnd_api.G_TRUE
                                  , x_Measure_Rec   => x_measure_rec
                                  , x_return_status => l_return_status
                                  , x_error_Tbl     => l_error_tbl
                                  );

    x_Measure_id                 := x_measure_rec.Measure_Id;
    x_Measure_Short_Name         := x_measure_rec.Measure_Short_Name;
    x_Measure_Name               := x_measure_rec.Measure_Name;
    x_Dimension1_ID              := x_measure_rec.Dimension1_ID;
    x_Dimension2_ID              := x_measure_rec.Dimension2_ID;
    x_Dimension3_ID              := x_measure_rec.Dimension3_ID;
    x_Dimension4_ID              := x_measure_rec.Dimension4_ID;
    x_Dimension5_ID              := x_measure_rec.Dimension5_ID;
    x_Dimension6_ID              := x_measure_rec.Dimension6_ID;
    x_Dimension7_ID              := x_measure_rec.Dimension7_ID;
    x_Unit_Of_Measure_Class      := x_measure_rec.Unit_Of_Measure_Class;
    x_actual_data_source_type    := x_measure_rec.Actual_Data_Source_Type;
    x_actual_data_source         := x_measure_rec.Actual_Data_Source;
    x_function_name              := x_measure_rec.Function_Name;
    x_comparison_source          := x_measure_rec.Comparison_Source;
    x_increase_in_measure        := x_measure_rec.Increase_In_Measure;
    x_Enable_Link                := x_measure_rec.Enable_Link; -- 2440739
    x_return_status              := l_return_status;

--
    x_region_code                := SUBSTR(x_measure_rec.Actual_Data_Source,1, (INSTR(x_measure_rec.Actual_Data_Source,'.',1,1)-1));
    x_attribute_code             := SUBSTR(x_measure_rec.Actual_Data_Source,(INSTR(x_measure_rec.Actual_Data_Source,'.',1,1)+1));

--
  BIS_PMF_DEFINER_WRAPPER_PVT.ADD_TO_FND_MSG_STACK
    (p_error_tbl      => l_error_tbl
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );
END Retrieve_Performance_Measure;
-- overloaded with enable_link param for bug 2440739

END BIS_PMF_DEFINER_WRAPPER_PVT;

/
