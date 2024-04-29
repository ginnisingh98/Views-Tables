--------------------------------------------------------
--  DDL for Package Body BIS_PMV_BSC_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_BSC_API_PVT" AS
/* $Header: BISVVEWB.pls 120.0 2005/06/01 17:14:04 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVVEWB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for getting information about PMV Reports             |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | Date              Developer           Comments                        |
REM | 08/22/02          nbarik              Creation                        |
REM | 06/16/04          nbarik              Bug Fix 3616680                 |
REM |                                                                       |
REM +=======================================================================+
*/

-- Global package name
--
G_PKG_NAME CONSTANT VARCHAR2(30) := 'BIS_PMV_BSC_API_PVT';
G_DEBUG BOOLEAN := FALSE;
G_ERROR BOOLEAN := FALSE;

-- Procedure for debugging
--PROCEDURE Print(p_string IN VARCHAR2);

--
-- Get all the Dimension+Dimension Level combination in the report
-- associated with a Measure, and whether View By and All applies to those
-- Dimension Levels
--
PROCEDURE Get_DimLevel_Viewby
( p_api_version              IN  NUMBER     DEFAULT NULL
, p_Region_Code              IN  VARCHAR2
, p_Measure_Short_Name       IN  VARCHAR2
, x_DimLevel_Viewby_Tbl      OUT NOCOPY BIS_PMV_BSC_API_PUB.DimLevel_Viewby_Tbl_Type
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
) IS

l_api_name            VARCHAR2(30) := 'Get_DimLevel_Viewby';
l_region_code         VARCHAR2(30) := NULL;
l_nested_region_code  VARCHAR2(30) := NULL;
l_ak_region_items_rec BIS_PMV_BSC_API_PVT.AK_REGION_ITEMS_REC_TYPE;
l_dimlevel_viewby_rec BIS_PMV_BSC_API_PUB.Dimlevel_Viewby_Rec_Type;
l_disable_viewby      VARCHAR2(1) := 'N';
l_index               NUMBER := 1;
is_duplicate          BOOLEAN := FALSE;

CURSOR region_code_cursor(cp_measure_short_name VARCHAR2) IS
SELECT region_code FROM ak_region_items WHERE attribute1='MEASURE' AND
    attribute2 = cp_measure_short_name
    ORDER BY creation_date DESC;

CURSOR disable_viewby_cursor(cp_region_code VARCHAR2) IS
  SELECT attribute1 FROM ak_regions
  WHERE region_code = cp_region_code;

CURSOR nested_region_cursor(cp_region_code VARCHAR2) IS
   SELECT nested_region_code FROM ak_region_items
   WHERE region_code=cp_region_code AND item_style='NESTED_REGION';

-- Enh 3420818 - retrieve attribute_code
CURSOR ak_region_items_cursor(cp_region_code VARCHAR2)
IS
SELECT attribute_code attribute_code, attribute1 attribute_type, attribute2 attribute_value, required_flag
FROM ak_region_items WHERE region_code = cp_region_code AND
 attribute1 IN ('DIM LEVEL SINGLE VALUE', 'DIMENSION LEVEL', 'HIDE DIMENSION LEVEL',
  'HIDE PARAMETER', 'HIDE VIEW BY DIMENSION', 'VIEWBY PARAMETER', 'HIDE_VIEW_BY_DIM_SINGLE');

BEGIN
/*
  IF fnd_profile.value('BIS_SQL_TRACE')= 'Y' THEN
     g_debug := TRUE;
  ELSE
     g_debug := FALSE;
  END IF;
*/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  G_ERROR := FALSE;

  -- get default region code
  IF p_Region_Code IS NOT NULL THEN -- region_code is passed to the API
    l_region_code := p_Region_Code;
  ELSE -- no default report associated with the measure
    IF p_Measure_Short_Name IS NOT NULL THEN
      IF region_code_cursor%ISOPEN THEN
        CLOSE region_code_cursor;
      END IF;
      FOR cr IN region_code_cursor(p_Measure_Short_Name) LOOP
        l_region_code := cr.region_code; -- get the first region
        EXIT;
      END LOOP;
      IF region_code_cursor%ISOPEN THEN
        CLOSE region_code_cursor;
      END IF;
    END IF;
  END IF;

  IF l_region_code IS NULL THEN
    G_ERROR := TRUE;
    -- nbarik - 06/16/04 - Bug Fix 3616680
    --x_msg_data := G_PKG_NAME || '.' || l_api_name || ' : No Region Associated with the Measure Short Name : ' || p_Measure_Short_Name;
    fnd_message.set_name('BIS','BIS_NO_REGION_MEASURE');
    fnd_message.set_token('SHORT_NAME', p_Measure_Short_Name);
    x_msg_data := fnd_message.get;
    --print(x_msg_data);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --print(G_PKG_NAME || '.' || l_api_name || ' : l_region_code : ' || l_region_code );

  IF disable_viewby_cursor%ISOPEN THEN
    CLOSE disable_viewby_cursor;
  END IF;
  OPEN disable_viewby_cursor(l_region_code);
  FETCH disable_viewby_cursor INTO l_disable_viewby;
  CLOSE disable_viewby_cursor;

  --print(G_PKG_NAME || '.' || l_api_name || ' : l_disable_viewby : ' || l_disable_viewby);

  IF ak_region_items_cursor%ISOPEN THEN
    CLOSE ak_region_items_cursor;
  END IF;
  -- populate records for report region
  -- Enh 3420818 - skip AS_OF_DATE
  FOR cr IN ak_region_items_cursor(l_region_code) LOOP
     IF cr.attribute_value IS NOT NULL AND cr.attribute_code <> 'AS_OF_DATE' THEN

       Populate_DimLevel_Viewby_Rec(
           p_Attribute_Type      =>  cr.attribute_type
         , p_Attribute_Value     =>  cr.attribute_value
         , p_Required_Flag       =>  cr.required_flag
         , p_Disable_Viewby      =>  l_disable_viewby
         , x_DimLevel_Viewby_Rec =>  l_dimlevel_viewby_rec
       );

       x_DimLevel_Viewby_Tbl(l_index) :=  l_dimlevel_viewby_rec;
       l_index := l_index + 1;

     END IF;
  END LOOP;

  IF ak_region_items_cursor%ISOPEN THEN
    CLOSE ak_region_items_cursor;
  END IF;

  -- check whether the report region contains nested region
  IF nested_region_cursor%ISOPEN THEN
    CLOSE nested_region_cursor;
  END IF;

  OPEN nested_region_cursor(l_region_code);
  FETCH nested_region_cursor INTO l_nested_region_code;
  CLOSE nested_region_cursor;

  --print(G_PKG_NAME || '.' || l_api_name || ' : l_nested_region_code : '|| l_nested_region_code);

  -- If report has a nested region - dbi report
  -- Enh 3420818 - skip AS_OF_DATE
  IF l_nested_region_code IS NOT NULL THEN
    IF ak_region_items_cursor%ISOPEN THEN
      CLOSE ak_region_items_cursor;
    END IF;
    FOR cr IN ak_region_items_cursor(l_nested_region_code) LOOP
     IF cr.attribute_value IS NOT NULL AND cr.attribute_code <> 'AS_OF_DATE' THEN
       IF (x_DimLevel_Viewby_Tbl.COUNT > 0) THEN
         is_duplicate := FALSE;
         FOR i IN x_DimLevel_Viewby_Tbl.FIRST..x_DimLevel_Viewby_Tbl.LAST LOOP
           l_dimlevel_viewby_rec := x_DimLevel_Viewby_Tbl(i);
           IF (cr.attribute_value = l_dimlevel_viewby_rec.Dim_DimLevel) THEN
             is_duplicate := TRUE;
             EXIT;
           END IF;
         END LOOP;
         IF NOT is_duplicate THEN
           Populate_DimLevel_Viewby_Rec(
               p_Attribute_Type      =>  cr.attribute_type
             , p_Attribute_Value     =>  cr.attribute_value
             , p_Required_Flag       =>  cr.required_flag
             , p_Disable_Viewby      =>  l_disable_viewby
             , x_DimLevel_Viewby_Rec =>  l_dimlevel_viewby_rec
           );

           x_DimLevel_Viewby_Tbl(l_index) :=  l_dimlevel_viewby_rec;
           l_index := l_index + 1;
         END IF;
       END IF;
     END IF;
    END LOOP;
    IF ak_region_items_cursor%ISOPEN THEN
      CLOSE ak_region_items_cursor;
    END IF;
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF ak_region_items_cursor%ISOPEN THEN
        CLOSE ak_region_items_cursor;
      END IF;
      IF nested_region_cursor%ISOPEN THEN
        CLOSE nested_region_cursor;
      END IF;
      IF disable_viewby_cursor%ISOPEN THEN
        CLOSE disable_viewby_cursor;
      END IF;
      IF region_code_cursor%ISOPEN THEN
        CLOSE region_code_cursor;
      END IF;
      IF NOT G_ERROR THEN
        FND_MSG_PUB.Count_And_Get
      		( 	 p_count => x_msg_count
          		,p_data  => x_msg_data
    		);
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF ak_region_items_cursor%ISOPEN THEN
        CLOSE ak_region_items_cursor;
      END IF;
      IF nested_region_cursor%ISOPEN THEN
        CLOSE nested_region_cursor;
      END IF;
      IF disable_viewby_cursor%ISOPEN THEN
        CLOSE disable_viewby_cursor;
      END IF;
      IF region_code_cursor%ISOPEN THEN
        CLOSE region_code_cursor;
      END IF;
      FND_MSG_PUB.Count_And_Get
    		( 	 p_count => x_msg_count
        		,p_data  => x_msg_data
    		);

   WHEN others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF ak_region_items_cursor%ISOPEN THEN
        CLOSE ak_region_items_cursor;
      END IF;
      IF nested_region_cursor%ISOPEN THEN
        CLOSE nested_region_cursor;
      END IF;
      IF disable_viewby_cursor%ISOPEN THEN
        CLOSE disable_viewby_cursor;
      END IF;
      IF region_code_cursor%ISOPEN THEN
        CLOSE region_code_cursor;
      END IF;
      FND_MSG_PUB.Count_And_Get
    		( 	 p_count => x_msg_count
        		,p_data  => x_msg_data
    		);
END Get_DimLevel_Viewby;

--
-- PROCEDURE Populate_DimLevel_Viewby_Rec
--
-- Populate each DimLevel_Viewby_Rec record depending on Attribute Type,
-- Attribute Value, Required Flag and Disable Viewby Parameter
--
PROCEDURE Populate_DimLevel_Viewby_Rec
( p_Attribute_Type          IN  VARCHAR2
, p_Attribute_Value         IN  VARCHAR2
, p_Required_Flag           IN  VARCHAR2
, p_Disable_Viewby          IN  VARCHAR2
, x_DimLevel_Viewby_Rec     OUT NOCOPY BIS_PMV_BSC_API_PUB.DimLevel_Viewby_Rec_Type
) IS

BEGIN
  --populate Dimension+Dimension Level
  x_DimLevel_Viewby_Rec.Dim_DimLevel := p_Attribute_Value;

  --populate ViewBy Applicable or not
  IF p_Disable_Viewby = 'Y' THEN --No ViewBy Report
    x_DimLevel_Viewby_Rec.ViewBy_Applicable := 'N';
  ELSE
    IF p_Attribute_Type = 'HIDE PARAMETER' OR p_Attribute_Type = 'HIDE VIEW BY DIMENSION' THEN
      x_DimLevel_Viewby_Rec.ViewBy_Applicable := 'N';
    ELSE
      x_DimLevel_Viewby_Rec.ViewBy_Applicable := 'Y';
    END IF;
  END IF;

  --populate All Applicable or not
  IF p_Required_Flag = 'Y' THEN
    x_DimLevel_Viewby_Rec.All_Applicable := 'N';
  ELSE
    x_DimLevel_Viewby_Rec.All_Applicable := 'Y';
  END IF;

  IF ( (p_Attribute_Type = 'HIDE DIMENSION LEVEL') OR (p_Attribute_Type = 'HIDE PARAMETER')
      OR (p_Attribute_Type = 'VIEWBY PARAMETER') )
  THEN
    x_DimLevel_Viewby_Rec.Hide_Level := 'Y';
  ELSE
    x_DimLevel_Viewby_Rec.Hide_Level := 'N';
  END IF;

END Populate_DimLevel_Viewby_Rec;

-- Procedure for debugging
/*
PROCEDURE Print(p_string IN VARCHAR2)
IS
BEGIN
  IF g_debug THEN
    NULL;
    --Enable for Debugging
    --dbms_output.put_line(p_string);
    --fnd_file.put_line(fnd_file.log, p_string);
  END IF;
END Print;
*/

END BIS_PMV_BSC_API_PVT;

/
