--------------------------------------------------------
--  DDL for Package Body BIS_PMF_MIGRATE_DIMENSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMF_MIGRATE_DIMENSIONS_PVT" AS
/* $Header: BISVMDLB.pls 115.11 2002/12/16 10:26:01 rchandra ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVMDLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for getting Dimensions from EDW and populating the
REM |     corresponding BIS Tables  .
REM |     Issues : Error Handling
REM |     Mismatch in the lengths of name, description for both entities
REM |                                                                       |
REM | HISTORY                                                               |
REM | August-2000 amkulkar Creation
REM +=======================================================================+
*/
--
G_PKG_NAME CONSTANT VARCHAR2(30):= 'BIS_PMF_MIGRATE_DIMENSIONS_PVT';
PROCEDURE MIGRATE_EDW_DIMENSIONS
(ERRBUF           OUT NOCOPY    VARCHAR2
,RETCODE          OUT NOCOPY    VARCHAR2
)
IS
  --This needs to be dynamic SQL as it needs to get installed with BIS
  /*CURSOR c_dims IS
  SELECT dim.name dimshortname, dim.longname dimname, dim.description dimdesc
  FROM  cmpwbdimension_v dim;

  CURSOR c_dim_lvls IS
  SELECT  dim.name dimshortname, dim.longname dimname, dim.description dimdesc
         ,lvl.name lvlshortname, lvl.longname lvlname ,lvl.description lvldesc
  FROM
          cmpwbdimension_v dim, cmplevel_v lvl
  WHERE
         lvl.dimension = dim.elementid
  ;
  */
  l_dimension_rec          BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_dimension_level_rec    BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_return_status          VARCHAR2(20);
  l_error_tbl              BIS_UTILITIES_PUB.ERROR_TBL_TYPE;
  l_dim_sql                VARCHAR2(32000);
  l_dimlvl_sql            VARCHAR2(32000);
  l_dimname                VARCHAR2(32000);
  l_dimdesc                VARCHAR2(32000);
  l_dimshortname           VARCHAR2(32000);
  l_lvlname                VARCHAR2(32000);
  l_lvlshortname           VARCHAR2(32000);
  l_lvldesc                VARCHAR2(32000);
  TYPE DIM_CURSOR_TYPE   IS REF CURSOR;
  TYPE DIM_LEVEL_CURSOR_TYPE IS REF CURSOR;
  l_dim_cursor             DIM_CURSOR_TYPE;
  l_dimlevel_Cursor        DIM_LEVEL_CURSOR_TYPE;
  l_count_dims             NUMBER := 0;
  l_count_levels           NUMBER := 0;
BEGIN
-- Fix for 2214178 starts
/*
  l_dim_sql  := ' SELECT dim.name dimshortname, dim.longname dimname, dim.description dimdesc '||
                ' FROM  cmpwbdimension_v dim '||
                ' WHERE dim.name NOT IN '|| G_LEVEL_EXCLUSION_STRING;
  l_dimlvl_sql :=' SELECT  dim.name dimshortname, dim.longname dimname, dim.description dimdesc '||
                 ' ,lvl.name lvlshortname, lvl.longname lvlname ,lvl.description lvldesc ' ||
                 ' FROM   ' ||
                 ' cmpwbdimension_v dim, cmplevel_v lvl ' ||
                 ' WHERE  '||
                 ' lvl.dimension = dim.elementid '||
                 ' AND dim.name NOT IN ' || G_LEVEL_EXCLUSION_STRING ;
*/
  l_dim_sql  := ' SELECT dim.DIM_NAME dimshortname, dim.DIM_LONG_NAME dimname, dim.DIM_DESCRIPTION dimdesc '||
                ' FROM  edw_dimensions_md_v dim '||
                ' WHERE dim.DIM_NAME NOT IN '|| G_LEVEL_EXCLUSION_STRING;

  l_dimlvl_sql :=' SELECT  dim.DIM_NAME dimshortname, dim.DIM_LONG_NAME dimname, dim.DIM_DESCRIPTION dimdesc '||
                 ' ,lvl.LEVEL_NAME lvlshortname, lvl.LEVEL_LONG_NAME lvlname ,lvl.description lvldesc ' ||
                 ' FROM   ' ||
                 ' edw_dimensions_md_v dim, edw_levels_md_v lvl ' ||
                 ' WHERE  '||
                 ' lvl.DIM_ID = dim.DIM_ID '||
                 ' AND dim.DIM_NAME NOT IN ' || G_LEVEL_EXCLUSION_STRING ;

-- Fix for 2214178 ends

  --Loop thru the CURSOR get all the records and Load BIS_DIMENSIONS
    OPEN l_dim_cursor FOR l_dim_sql;
    LOOP
    --FOR c_rec IN c_dims LOOP
        FETCH  l_dim_cursor INTO l_dimshortname, l_dimname, l_dimdesc;
        EXIT WHEN l_dim_cursor%NOTFOUND;
        l_count_Dims := l_count_Dims+1;
        l_return_status     := NULL;
        l_dimension_rec.dimension_short_name := l_dimshortname;
        l_dimension_rec.dimension_name       := substr(l_dimname,1,80);
        l_dimension_rec.description          := substr(l_dimdesc,1,240);
        --Call the API to load the dimension
        BIS_DIMENSION_PUB.LOAD_DIMENSION(
                          p_api_version      => 1.0
		         ,p_Commit           =>  FND_API.G_TRUE
			 ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
			 ,p_dimension_rec    => l_dimension_rec
			 ,p_owner            => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
                         ,x_return_status    => l_return_Status
	                 ,x_error_tbl        => l_error_tbl
			 );
    END LOOP;
    OPEN l_dimlevel_cursor FOR l_dimlvl_sql;
    --FOR c_rec IN c_dim_lvls LOOP
    LOOP
        FETCH l_dimlevel_cursor INTO l_Dimshortname, l_dimname, l_dimdesc, l_lvlshortname,
                                     l_lvlname, l_lvldesc;
        EXIT WHEN l_dimlevel_cursor%NOTFOUND;
        l_count_levels := l_count_levels+1;
        l_return_status     := NULL;
        l_dimension_level_rec.dimension_short_name       := l_dimshortname;
        l_dimension_level_rec.dimension_name             := substr(l_dimname,1,80);
        l_dimension_level_rec.dimension_level_short_name := l_lvlshortname;
        l_dimension_level_rec.dimension_level_name       := substr(l_lvlname,1,80);
	l_dimension_level_rec.description                := substr(l_lvldesc,1,240);
	l_dimension_level_rec.level_values_view_name     := null;--'BIS_'||c_rec.lvlshortname||'_V';
        l_Dimension_level_rec.where_clause               := null;
        l_dimension_level_rec.source                     := G_EDW;
        BIS_DIMENSION_LEVEL_PUB.LOAD_DIMENSION_LEVEL(
                                  p_api_version          => 1.0
			         ,p_commit               => FND_API.G_TRUE
			         ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
				 ,p_dimension_level_rec  => l_dimension_level_rec
			         ,p_owner                => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
			         ,x_return_status        => l_return_status
                                 ,x_error_tbl            => l_error_tbl
				);

     END LOOP;
     FND_MESSAGE.SET_NAME('BIS', 'BIS_DIM_COUNT');
     FND_MESSAGE.SET_TOKEN('DIMCOUNT', l_count_dims);
     FND_MESSAGE.SET_TOKEN('DIMLEVELCOUNT', l_count_levels);
     errbuf := FND_MESSAGE.GET;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
      RETCODE := 1;
      ERRBUF := SQLERRM;
      RETURN;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RETCODE := 1;
      ERRBUF := SQLERRM;
      RETURN;
   WHEN OTHERS THEN
      RETCODE := 1;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME
      );
      RETURN;

END;
END BIS_PMF_MIGRATE_DIMENSIONS_PVT;

/
