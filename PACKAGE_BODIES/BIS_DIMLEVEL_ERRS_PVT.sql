--------------------------------------------------------
--  DDL for Package Body BIS_DIMLEVEL_ERRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_DIMLEVEL_ERRS_PVT" AS
/* $Header: BISVEDEB.pls 115.12 2003/03/27 20:09:22 sashaik ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVGDLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for getting the Select String for DimensionLevelValues|
REM |     This API will get the Select String from either EDW or BIS        |
REM |     depending on the profile option BIS_SOURCE                        |
REM |                                                                       |
REM | HISTORY                                                               |
REM | December-2000 amkulkar Creation                                       |
REM +=======================================================================+
*/
--
-- CONSTANTS
   EDW_ACCT_FLEXFIELD           VARCHAR2(200) := 'EDW_GL';
   EDW_LVL_TBL_SUFFIX           VARCHAR2(200) := '_LTC';
   EDW_LVL_FLEX_PK_SUFFIX       VARCHAR2(200) := '_NAME';
   G_PKG_NAME                   VARCHAR2(200) := 'BIS_PMF_GET_DIMLEVELS_PVT';
--Copied from JK's utilities blindly almost
PROCEDURE FILE_OPEN
(p_file_name              IN     VARCHAR2
,x_file_handle            OUT NOCOPY    UTL_FILE.FILE_TYPE
)
IS
   l_dir                     VARCHAR2(32000);

   CURSOR c_file IS
   SELECT vp.value
   FROM v$parameter vp
   WHERE vp.name = 'utl_file_dir';

   l_file_name                  VARCHAR2(32000);

BEGIN
   IF (p_file_name IS NULL) THEN
      l_file_name := EDW_ERRORS;
   ELSE
      l_file_name := p_file_name;
   END IF;
   OPEN c_file;
   FETCH c_file INTO l_dir;
   CLOSE c_file;
   IF instr(l_dir,',') > 0 THEN
      l_dir := substr(l_dir,1,instr(l_dir,',')-1);
   END IF;
   IF UTL_FILE.IS_OPEN(x_file_handle) THEN
      UTL_FILE.FCLOSE(x_file_handle);
   END IF;
   x_file_handle := UTL_FILE.FOPEN(l_dir, l_file_name, 'w');
EXCEPTION
    WHEN UTL_FILE.INVALID_PATH THEN
         RAISE_APPLICATION_ERROR(-20100, 'Invalid PAth');
    WHEN UTL_FILE.INVALID_MODE THEN
         RAISE_APPLICATION_ERROR(-20101,'Invalid Mode');
    WHEN UTL_FILE.INVALID_OPERATION THEN
         RAISE_APPLICATION_ERROR(-20101,' Invalid operation');
END;
--Copied from JK's utilities blindly almost
PROCEDURE WRITE_TO_FILE
(p_text           IN     VARCHAR2
,p_file_handle    IN     UTL_FILE.FILE_TYPE
)
IS
BEGIN
    UTL_FILE.putf(p_file_handle, '%s \n', p_text);
    UTL_FILE.fflush(p_file_handle);
EXCEPTION
   WHEN UTL_FILE.INVALID_OPERATION THEN
        RAISE_APPLICATION_ERROR(-20101, 'Invalid Operation');
   WHEN UTL_FILE.INVALID_FILEHANDLE THEN
      RAISE_APPLICATION_ERROR(-20103,
                              'Debug: Invalid File Handle');
   WHEN UTL_FILE.WRITE_ERROR THEN
      RAISE_APPLICATION_ERROR(-20104,
                              'Debug: Write Error');
END;
PROCEDURE REPORT_ERRORS
(p_Dim_Level_Name         IN     VARCHAR2  DEFAULT NULL
,p_file_name              IN     VARCHAR2  DEFAULT NULL
)
IS
 l_lvlshortname      VARCHAR2(32000);
 l_pkkey             VARCHAR(2000);
 l_valuename         VARCHAR2(2000);
 l_tablename         VARCHAR2(2000);
 l_distinct          VARCHAR2(2000);
 l_select_string     VARCHAR2(32000);
 l_temp_tablename   VARCHAR2(32000);
 l_sql_string        VARCHAR2(32000);

 /*CURSOR c_dimlvls IS
 SELECT
       lvl.name lvlshortname, lvl.longname lvlname, lvl.description lvldesc
       ,lvl.prefix prefix
 FROM
        cmplevel_v lvl
 WHERE
        (lvl.name = p_dim_level_name OR p_dim_level_name IS NULL)
 ;
 CURSOR c_dims(p_lvlshort_name IN varchar2) IS
 SELECT dim.name dimshortname
 FROM cmpwbdimension_v dim, cmplevel_v lvl
 WHERE
       lvl.name=p_lvlshort_name AND
       lvl.dimension = dim.elementid
 ;

 CURSOR c_pkkey IS
 SELECT item.name
 FROM cmpitem_v item, cmprelation_v rel,
      cmpwbitemsetusage_v isu, cmpuniquekey_v pk
 WHERE pk.owningrelation=rel.elementid
         and isu.itemset=pk.elementid
         and isu.attribute=item.elementid
         and upper(rel.name)  = upper(l_lvlshortname )
         and item.name like '%PK_KEY';

 CURSOR c_pkkey IS
 SELECT level_table_col_name
 FROM edw_level_Table_atts_md_v
 WHERE key_type='UK' AND
       upper(level_Table_name) = upper(l_lvlshortname||'_LTC') AND
       level_table_col_name like '%PK_KEY%';
 i*/
 l_time_columns               VARCHAR2(2000);
 l_err_file_handle            UTL_FILE.FILE_TYPE;
 l_success_file_handle        UTL_FILE.FILE_TYPE;
 l_error_text                 VARCHAR2(32000);
 l_success_text		      VARCHAR2(32000);
 l_dimshortname               VARCHAR2(32000);
 l_success_file		      VARCHAR2(32000) := 'DIMLEVELSUCCESS.log';
 l_status                     VARCHAR2(32000);
 l_pkkey_sql                  VARCHAR2(32000);
 l_dim_level_sql              VARCHAR2(32000);
 l_dim_sql                    VARCHAR2(32000);
 l_lvlshortname_ltc         VARCHAR2(32000);
 l_longname                   VARCHAR2(32000);
 l_description                VARCHAR2(32000);
 l_prefix                     VARCHAR2(32000);
 TYPE dimlvls_cursor_type     IS REF CURSOR;
 l_dimlvls_cursor             dimlvls_cursor_type;

BEGIN
  l_pkkey_sql := ' SELECT level_table_col_name '||
        --2245747         ' FROM edw_level_Table_atts_md_v '||
                 ' FROM EDW_LVL_TBL_UK_MD_V  '||     --2245747
                 ' WHERE key_type=''UK'' AND '||
                 ' upper(level_Table_name) = upper(:l_lvlshortname_ltc) AND '||
                 ' level_table_col_name like ''%PK_KEY%''';
-- Fix for 2214178 starts
/*
  l_dim_sql := ' SELECT dim.name dimshortname  '||
               ' FROM cmpwbdimension_v dim, cmplevel_v lvl '||
               ' WHERE  '||
               ' lvl.name=:p_lvlshort_name AND '||
               ' lvl.dimension = dim.elementid ';
  l_dim_level_sql := ' SELECT  '||
                     ' lvl.name lvlshortname, lvl.longname lvlname, lvl.description lvldesc '||
                     ' ,lvl.prefix prefix '||
                     ' FROM '||
                     ' cmplevel_v lvl '||
                     ' WHERE  '||
                     ' (lvl.name = :1 OR :2 IS NULL) ';
*/
  l_dim_sql := ' SELECT dim.dim_name dimshortname  '||
               ' FROM edw_dimensions_md_v dim, edw_levels_md_v lvl '||
               ' WHERE  '||
               ' lvl.level_name=:p_lvlshort_name AND '||
               ' lvl.dim_id = dim.dim_id ';

  l_dim_level_sql := ' SELECT  '||
                     ' lvl.LEVEL_NAME lvlshortname, lvl.LEVEL_LONG_NAME lvlname, lvl.DESCRIPTION lvldesc '||
                     ' ,lvl.LEVEL_PREFIX prefix '||
                     ' FROM '||
                     ' edw_levels_md_v lvl '||
                     ' WHERE  '||
                     ' (lvl.LEVEL_NAME = :1 OR :2 IS NULL) ';

-- Fix for 2214178 ends
  FILE_OPEN(p_File_name, l_err_file_handle);
  FILE_OPEN(l_success_file, l_success_file_handle);
  OPEN l_dimlvls_cursor FOR l_dim_level_sql USING  p_dim_level_name,p_dim_level_name;
  --FOR c_rec IN c_dimlvls LOOP
  LOOP
      FETCH l_dimlvls_cursor INTO l_lvlshortname, l_longname, l_description, l_prefix;
      EXIT WHEN l_dimlvls_cursor%NOTFOUND;
      l_status     := FND_API.G_RET_STS_SUCCESS;
      --l_error_text := c_rec.lvlshortname || ' : ';
      --l_lvlshortname := c_Rec.lvlshortname;
     l_error_text := l_lvlshortname || ' : ';
      /*OPEN c_dims(l_lvlshortname);
      FETCH c_dims INTO l_dimshortname;
      CLOSE c_dims;
      */
      EXECUTE IMMEDIATE l_dim_sql INTO l_dimshortname USING l_lvlshortname;
      IF (BIS_PMF_GET_DIMLEVELS_PVT.isAccounting_Flexfield(l_lvlshortname))
      THEN
         --l_pkkey := c_rec.prefix||EDW_LVL_FLEX_PK_SUFFIX;
         l_pkkey := l_prefix||EDW_LVL_FLEX_PK_SUFFIX;
         l_tablename := l_dimshortname;
         l_distinct  := ' DISTINCT ';
         l_valuename := L_prefix||EDW_LVL_FLEX_PK_SUFFIX;
         l_sql_string := 'SELECT '||l_pkkey||' from '||l_tablename|| ' where rownum < 2';
         BEGIN
            EXECUTE IMMEDIATE l_sql_string ;
         EXCEPTION
         WHEN OTHERS THEN
              IF (SQLCODE= -904) THEN
                FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_EDW_PK_KEY');
                FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME',l_lvlshortname);
                l_status := FND_API.G_RET_STS_ERROR;
                l_error_text := l_lvlshortname || ' : ';
                l_error_text := l_error_text || FND_MESSAGE.GET;
                WRITE_TO_FILE(l_error_text, l_err_file_handle);
              END IF;
          END;
      ELSE
        /*OPEN c_pkkey;
        FETCH c_pkkey INTO l_pkkey;
        IF c_pkkey%NOTFOUND THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_EDW_PK_KEY');
            FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME',l_lvlshortname);
            l_status := FND_API.G_RET_STS_ERROR;
            l_error_text := l_lvlshortname || ' : ';
            l_error_text := l_error_text || FND_MESSAGE.GET;
            WRITE_TO_FILE(l_error_text, l_err_file_handle);
         END IF;
         CLOSE c_pkkey;
         */
         l_lvlshortname_ltc := l_lvlshortname || '_LTC';
         BEGIN
         EXECUTE IMMEDIATE l_pkkey_sql INTO  l_pkkey USING l_lvlshortname_ltc;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_EDW_PK_KEY');
            FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME',l_lvlshortname);
            l_status := FND_API.G_RET_STS_ERROR;
            l_error_text := l_lvlshortname || ' : ';
            l_error_text := l_error_text || FND_MESSAGE.GET;
            WRITE_TO_FILE(l_error_text, l_err_file_handle);
         END;
         l_tablename := l_lvlshortname || EDW_LVL_TBL_SUFFIX ;
         l_sql_string := 'SELECT '||l_pkkey||' from '||l_tablename|| ' where rownum < 2';
         BEGIN
           EXECUTE IMMEDIATE l_sql_string ;
         EXCEPTION
         WHEN OTHERS THEN
           IF (SQLCODE = -942) THEN
               FND_MESSAGE.SET_NAME ('BIS', 'BIS_NO_LTC_TABLE');
               FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_dim_level_name);
               l_status := FND_API.G_RET_STS_ERROR;
               l_error_text := l_lvlshortname || ' : ';
               l_error_text := l_error_text || FND_MESSAGE.GET;
               WRITE_TO_FILE(l_error_text, l_err_file_handle);
           END IF;
           IF (SQLCODE= -904) THEN
              FND_MESSAGE.SET_NAME ('BIS', 'BIS_INVALID_EDW_PK_KEY');
              FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_dim_level_name);
              l_status := FND_API.G_RET_STS_ERROR;
              l_error_text := l_lvlshortname || ' : ';
              l_error_text := l_error_text || FND_MESSAGE.GET;
              WRITE_TO_FILE(l_error_text, l_err_file_handle);
           END IF;
         END;
         l_valuename := ' NAME ';
      END IF;
      --IF (l_dimshortname = 'EDW_TIME_M')
      IF ((l_dimshortname = 'EDW_TIME_M') AND
       (l_lvlshortname <> BIS_UTILITIES_PVT.GET_TOTAL_DIMLEVEL_NAME(p_dim_short_name=>l_dimshortname
                                                                   ,p_DimLevelId => NULL
                                                                   ,p_DimLevelName => l_lvlshortname)))
      THEN
            l_time_columns := ' ,start_date, end_date ';
            l_sql_string   := 'SELECT start_date from '||l_tablename||' where rownum < 2';
            BEGIN
                EXECUTE IMMEDIATE l_sql_string ;
            EXCEPTION
            WHEN OTHERS THEN
                 IF (SQLCODE= -904) THEN
                     FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_START_DATE');
                     FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME',l_lvlshortname);
                     l_status := FND_API.G_RET_STS_ERROR;
                     l_error_text := l_lvlshortname || ' : ';
                     l_error_text := l_error_text || FND_MESSAGE.GET;
                     WRITE_TO_FILE(l_error_text, l_err_file_handle);
                 END IF;
            END;
            l_sql_string   := 'SELECT end_date from '||l_tablename||' where rownum < 2';
            BEGIN
              EXECUTE IMMEDIATE l_sql_string ;
            EXCEPTION
            WHEN OTHERS THEN
                 IF (SQLCODE= -904) THEN
                    FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_EDW_END_DATE');
                    FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME',l_lvlshortname);
                    l_status := FND_API.G_RET_STS_ERROR;
                    l_error_text := l_lvlshortname || ' : ';
                    l_error_text := l_error_text || FND_MESSAGE.GET;
                    WRITE_TO_FILE(l_error_text, l_err_file_handle);
                 END IF;
            END;
        ELSE
             l_time_columns := '';
        END IF;
--        IF (NOT(BIS_PMF_GET_DIMLEVELS_PVT.isAccounting_Flexfield(l_lvlshortname))) THEN
        l_sql_string := 'SELECT '||l_valuename||' from '||l_tablename|| ' where rownum < 2';
        BEGIN
           EXECUTE IMMEDIATE l_sql_string ;
        EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE = -942) THEN
               FND_MESSAGE.SET_NAME ('BIS', 'BIS_NO_LTC_TABLE');
               FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', l_lvlshortname);
               l_status := FND_API.G_RET_STS_ERROR;
               l_error_text := l_lvlshortname || ' : ';
               l_error_text := l_error_text || FND_MESSAGE.GET;
               WRITE_TO_FILE(l_error_text, l_err_file_handle);
           END IF;
           IF (SQLCODE= -904) THEN
              FND_MESSAGE.SET_NAME ('BIS', 'BIS_INVALID_VALUE');
              FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', l_lvlshortname);
              l_status := FND_API.G_RET_STS_ERROR;
              l_error_text := l_lvlshortname || ' : ';
              l_error_text := l_error_text || FND_MESSAGE.GET;
              WRITE_TO_FILE(l_error_text, l_err_file_handle);
           END IF;
        END;
        --END IF;
        IF (l_status = FND_API.G_RET_STS_SUCCESS) THEN
           FND_MESSAGE.SET_NAME ('BIS', 'BIS_NO_ERRORS');
           l_success_text := l_lvlshortname || ' ' || FND_MESSAGE.GET;
           WRITE_TO_FILE(l_success_text , l_success_file_handle);
        END IF;
  END LOOP;
  utl_file.fclose(l_success_file_handle);
  utl_file.fclose(l_err_file_handle);
/*
EXCEPTION
  WHEN OTHERS THEN
       utl_file.fclose(l_err_file_handle);
       utl_file.fclose(l_success_file_handle);
*/
END;

END BIS_DIMLEVEL_ERRS_PVT;

/
