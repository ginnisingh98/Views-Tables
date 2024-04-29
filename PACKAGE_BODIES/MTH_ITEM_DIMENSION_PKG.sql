--------------------------------------------------------
--  DDL for Package Body MTH_ITEM_DIMENSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTH_ITEM_DIMENSION_PKG" AS
/*$Header: mthitemb.pls 120.1.12010000.5 2010/05/17 23:08:32 yfeng ship $ */

/* ****************************************************************************
* Procedure		:ITEM_DIM_LOAD_DENORM	          	              *
* Description 	 	:This procedure is used to populate the denorm table  *
*			 for the item dimension hierarchy		      *
* File Name	 	:MTHITEMDB.PLS              			      *
* Visibility		:Public                				      *
* Parameters	 	:                                             	      *
* Modification log	:						      *
*			Author		Date			Change	      *
*			Ankit Goyal	29-May--2007	Initial Creation      *
**************************************************************************** */
PROCEDURE ITEM_DIM_LOAD_DENORM
IS
  v_unassigned_key number;
  v_unassigned_item_name varchar2(240);
  v_unassigned_category_name varchar2(240);
BEGIN

--insert the values in the denormalised item denorm table.
--use of max function in the select is just to by pass the usage in the
--group by clause.
--Maximun nuumber of leves supported is 10.
--Item will be at lowest level i.e. 10.

  v_unassigned_key := MTH_UTIL_PKG.MTH_UA_GET_VAL;

  BEGIN
  SELECT ITEM_NAME into v_unassigned_item_name
       from MTH_ITEMS_D
       where item_PK_KEY = v_unassigned_key;
  exception
     when TOO_MANY_ROWS then
         v_unassigned_item_name := null;
     when NO_DATA_FOUND then
         v_unassigned_item_name := null;
     when others then
         v_unassigned_item_name := null;
  end;

  BEGIN
  select CATEGORY_NAME into v_unassigned_category_name
       from MTH_ITEM_CATEGORIES_D
       where CATEGORY_PK_KEY = v_unassigned_key;
  exception
     when TOO_MANY_ROWS then
         v_unassigned_item_name := null;
     when NO_DATA_FOUND then
         v_unassigned_item_name := null;
     when others then
         v_unassigned_item_name := null;
  end;

        INSERT
        INTO    MTH_ITEM_DENORM_D
                (
                        HIERARCHY_ID,
                        ITEM_FK_KEY,
                        LEVEL1_FK_KEY,
                        LEVEL2_FK_KEY,
                        LEVEL3_FK_KEY,
                        LEVEL4_FK_KEY,
                        LEVEL5_FK_KEY,
                        LEVEL6_FK_KEY,
                        LEVEL7_FK_KEY,
                        LEVEL8_FK_KEY,
                        LEVEL9_FK_KEY,
                        LEVEL_NUM,
                        ITEM_NAME,
                        LEVEL1_NAME,
                        LEVEL2_NAME,
                        LEVEL3_NAME,
                        LEVEL4_NAME,
                        LEVEL5_NAME,
                        LEVEL6_NAME,
                        LEVEL7_NAME,
                        LEVEL8_NAME,
                        LEVEL9_NAME
                )
       SELECT HIERARCHY_ID,
       ITEM_FK_KEY,
       LEVEL1_FK_KEY,
       LEVEL2_FK_KEY,
       LEVEL3_FK_KEY,
       LEVEL4_FK_KEY,
       LEVEL5_FK_KEY,
       LEVEL6_FK_KEY,
       LEVEL7_FK_KEY,
       LEVEL8_FK_KEY,
       LEVEL9_FK_KEY,
       LEVEL_NUM,
       ITEM_NAME,
       LEVEL1_NAME,
       LEVEL2_NAME,
       LEVEL3_NAME,
       LEVEL4_NAME,
       LEVEL5_NAME,
       LEVEL6_NAME,
       LEVEL7_NAME,
       LEVEL8_NAME,
       LEVEL9_NAME
FROM   (SELECT   HIERARCHY_ID,
                 ITEM_PK_KEY         ITEM_FK_KEY,
                 MAX(LEVEL1_FK_KEY)  LEVEL1_FK_KEY,
                 MAX(LEVEL2_FK_KEY)  LEVEL2_FK_KEY,
                 MAX(LEVEL3_FK_KEY)  LEVEL3_FK_KEY,
                 MAX(LEVEL4_FK_KEY)  LEVEL4_FK_KEY,
                 MAX(LEVEL5_FK_KEY)  LEVEL5_FK_KEY,
                 MAX(LEVEL6_FK_KEY)  LEVEL6_FK_KEY,
                 MAX(LEVEL7_FK_KEY)  LEVEL7_FK_KEY,
                 MAX(LEVEL8_FK_KEY)  LEVEL8_FK_KEY,
                 MAX(LEVEL9_FK_KEY)  LEVEL9_FK_KEY,
                 MAX(LEVEL_NUM)      LEVEL_NUM,
                 MAX(ITEM_NAME)      ITEM_NAME,
                 MAX(LEVEL1_NAME)    LEVEL1_NAME,
                 MAX(LEVEL2_NAME)    LEVEL2_NAME,
                 MAX(LEVEL3_NAME)    LEVEL3_NAME,
                 MAX(LEVEL4_NAME)    LEVEL4_NAME,
                 MAX(LEVEL5_NAME)    LEVEL5_NAME,
                 MAX(LEVEL6_NAME)    LEVEL6_NAME,
                 MAX(LEVEL7_NAME)    LEVEL7_NAME,
                 MAX(LEVEL8_NAME)    LEVEL8_NAME,
                 MAX(LEVEL9_NAME)    LEVEL9_NAME
        FROM     (SELECT HIERARCHY_ID,
                         B.ITEM_PK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 1 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL9_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 2 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL8_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 3 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL7_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 4 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL6_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 5 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL5_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 6 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL4_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 7 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL3_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 8 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL2_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 9 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL1_FK_KEY,
                         10 LEVEL_NUM,
                         B.ITEM_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 1 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL9_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 2 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL8_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 3 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL7_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 4 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL6_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 5 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL5_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 6 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL4_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 7 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL3_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 8 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL2_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 9 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL1_NAME
                  FROM   (SELECT LEVEL  LEVEL_NUM,
                                 ITEM_PK_KEY,
                                 LEVEL_FK_KEY,
                                 LEVEL_NAME,
                                 PARENT_FK_KEY,
                                 PARENT_NAME,
                                 SYS_CONNECT_BY_PATH(LEVEL_FK_KEY,'/')   PATH,
                                 HIERARCHY_ID
                          FROM   MTH_ITEM_HIERARCHY,
                                 MTH_ITEMS_D B
                          WHERE  LEVEL_FK_KEY = B.ITEM_PK_KEY (+)
                          START WITH B.ITEM_PK_KEY IS NOT NULL
                          CONNECT BY LEVEL_FK_KEY = PRIOR PARENT_FK_KEY
                                     AND HIERARCHY_ID = PRIOR HIERARCHY_ID) A,
                         (SELECT ITEM_PK_KEY, ITEM_NAME
                          FROM   MTH_ITEMS_D) B
                  WHERE  A.PATH = ('/' || B.ITEM_PK_KEY ) OR
                                    A.PATH LIKE '/' || B.ITEM_PK_KEY || '/%' )

        --The granuality level is item and this would be done
       -- for all the hierarchies
       GROUP BY HIERARCHY_ID,ITEM_PK_KEY
UNION
select mdh.hierarchy_id,
       MTH_UTIL_PKG.MTH_UA_GET_VAL item_fk_key
       ,v_unassigned_key level1_level_key
       ,v_unassigned_key level2_level_key
       ,v_unassigned_key level3_level_key
       ,v_unassigned_key level4_level_key
       ,v_unassigned_key level5_level_key
       ,v_unassigned_key level6_level_key
       ,v_unassigned_key level7_level_key
       ,v_unassigned_key level8_level_key
       ,v_unassigned_key level9_level_key
       ,10 level_num
       ,v_unassigned_item_name item_name
       ,v_unassigned_category_name level1_name
       ,v_unassigned_category_name level2_name
       ,v_unassigned_category_name level3_name
       ,v_unassigned_category_name level4_name
       ,v_unassigned_category_name level5_name
       ,v_unassigned_category_name level6_name
       ,v_unassigned_category_name level7_name
       ,v_unassigned_category_name level8_name
       ,v_unassigned_category_name level9_name
from  dual,
      mth_dim_hierarchy mdh,
      (select distinct hierarchy_id
       from   mth_dim_level_lookup) mdll
where  mdh.dimension_name= 'ITEM' and
       mdll.hierarchy_id (+) = mdh.hierarchy_id);

-- Balance the item denorm table
mth_util_pkg.mth_hrchy_balance_load('MTH_ITEM_DENORM_D');

-- Push up and fill the level key and name for the ones with NULL

UPDATE MTH_ITEM_DENORM_D
SET  level1_fk_key  = nvl(level1_fk_key, v_unassigned_key),
     level1_name    = nvl(level1_name, v_unassigned_category_name),
     level2_fk_key  = nvl(level2_fk_key, v_unassigned_key),
     level2_name    = nvl(level2_name, v_unassigned_category_name),
     level3_fk_key  = nvl(level3_fk_key, v_unassigned_key),
     level3_name    = nvl(level3_name, v_unassigned_category_name),
     level4_fk_key  = nvl(level4_fk_key, v_unassigned_key),
     level4_name    = nvl(level4_name, v_unassigned_category_name),
     level5_fk_key  = nvl(level5_fk_key, v_unassigned_key),
     level5_name    = nvl(level5_name, v_unassigned_category_name),
     level6_fk_key  = nvl(level6_fk_key, v_unassigned_key),
     level6_name    = nvl(level6_name, v_unassigned_category_name),
     level7_fk_key  = nvl(level7_fk_key, v_unassigned_key),
     level7_name    = nvl(level7_name, v_unassigned_category_name),
     level8_fk_key  = nvl(level8_fk_key, v_unassigned_key),
     level8_name    = nvl(level8_name, v_unassigned_category_name),
     level9_fk_key  = nvl(level9_fk_key, v_unassigned_key),
     level9_name    = nvl(level9_name, v_unassigned_category_name);

-- Add entries for all the rest of levels


  Insert into  mth_item_denorm_d
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          9,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  From  mth_item_denorm_d
  Where LEVEL9_FK_KEY is not null and level_NUM = 10;

  -- insert level 8 entries
  Insert into  mth_item_denorm_d
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          NULL,
          8,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          NULL
  From  mth_item_denorm_d
  Where LEVEL8_FK_KEY is not null and level_NUM = 9;

  -- insert level 7 entries
  Insert into  mth_item_denorm_d
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          NULL,
          NULL,
          7,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          NULL,
          NULL
  From  mth_item_denorm_d
  Where LEVEL7_FK_KEY is not null and level_NUM = 8;

  -- insert level 6 entries
  Insert into  mth_item_denorm_d
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          NULL,
          NULL,
          NULL,
          6,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          NULL,
          NULL,
          NULL
  From  mth_item_denorm_d
  Where LEVEL6_FK_KEY is not null and level_NUM = 7;

  -- insert level 5 entries
  Insert into  mth_item_denorm_d
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          NULL,
          NULL,
          NULL,
          NULL,
          5,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          NULL,
          NULL,
          NULL,
          NULL
  From  mth_item_denorm_d
  Where LEVEL5_FK_KEY is not null and level_NUM = 6;

  -- insert level 4 entries
  Insert into  mth_item_denorm_d
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          4,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL
  From  mth_item_denorm_d
  Where LEVEL4_FK_KEY is not null and level_NUM = 5;


  -- insert level 3 entries
  Insert into  mth_item_denorm_d
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          3,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL
  From  mth_item_denorm_d
  Where LEVEL3_FK_KEY is not null and level_NUM = 4;


  -- insert level 2 entries
  Insert into  mth_item_denorm_d
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          2,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL
  From  mth_item_denorm_d
  Where LEVEL2_FK_KEY is not null and level_NUM = 3;



  -- insert level 1 entries
  Insert into  mth_item_denorm_d
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          null,
          LEVEL1_FK_KEY,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          1,
          null,
          LEVEL1_NAME,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL
  From  mth_item_denorm_d
  Where LEVEL1_FK_KEY is not null and level_NUM = 2;

EXCEPTION
WHEN OTHERS THEN
        ROLLBACK;
        --End of the procedure ITEM_DIM_LOAD_DENORM
END ITEM_DIM_LOAD_DENORM;


/* *****************************************************************************
* Procedure		:MTH_HRCHY_BALANCE_LOAD                                *
* Description 	 	:This procedure is used for the balancing of the       *
* hierarchy. The algorithm used for the balancing is down balancing 	       *
* Please refer to the Item fdd for more details on this.                       *
* File Name	 	:MTHUTILS.PLS			                       *
* Visibility		:Public			       		               *
* Parameters	 	:fact table name		                       *
* Modification log	:		                                       *
*			Author		Date			Change	       *
*	Ankit Goyal	17-Aug-2007	Initial Creation                       *
****************************************************************************** */
PROCEDURE mth_hrchy_balance_load(p_fact_table IN VARCHAR2) is

v_fact_table VARCHAR2(120);

--user defined type for array of records
TYPE denorm_rec_tab_type IS TABLE OF NUMBER;
TYPE denorm_rec_name_tab_type IS TABLE OF VARCHAR2(240);

--user defined type of record of arrays
TYPE denorm_rec_type IS RECORD (level9_fk_key denorm_rec_tab_type,
hierarchy_id denorm_rec_tab_type,
baselevel_fk_key denorm_rec_tab_type,
level7_fk_key denorm_rec_tab_type,
level6_fk_key denorm_rec_tab_type,
level5_fk_key denorm_rec_tab_type,
level4_fk_key denorm_rec_tab_type,
level3_fk_key denorm_rec_tab_type,
level2_fk_key denorm_rec_tab_type,
level1_fk_key denorm_rec_tab_type,
level9_name denorm_rec_name_tab_type,
level7_name denorm_rec_name_tab_type,
level6_name denorm_rec_name_tab_type,
level5_name denorm_rec_name_tab_type,
level4_name denorm_rec_name_tab_type,
level3_name denorm_rec_name_tab_type,
level2_name denorm_rec_name_tab_type,
level1_name denorm_rec_name_tab_type
);

--instantiation of the user defined type
--this will be the placeholder for the records fetched from the denorm table
denorm_rec denorm_rec_type;

--user defined cursor to hold the bulk collection of records
item_cur SYS_REFCURSOR;

--variable for the limit of the bulk collection
v_limit NUMBER :=5000;


BEGIN

--initialize the collection
denorm_rec := NULL;

--initialize the fact table name
v_fact_table :=p_fact_table;

--open the cursor
OPEN item_cur FOR 'SELECT     --select for the newe levels
        level9_fk_key,hierarchy_id,item_fk_key,
        Decode(diff_level,1,level8_fk_key,level9_fk_key) level7_fk_key_new,
        Decode(diff_level,1,level7_fk_key,2,level8_fk_key,level9_fk_key)
        level6_fk_key_new,
        Decode(diff_level,1,level6_fk_key,2,level7_fk_key,3,level8_fk_key,
        level9_fk_key) level5_fk_key_new,
        Decode(diff_level,1,level5_fk_key,2,level6_fk_key,3,level7_fk_key,4,
        level8_fk_key,level9_fk_key) level4_fk_key_new,
        Decode(diff_level,1,level4_fk_key,2,level5_fk_key,3,level6_fk_key,4,
        level7_fk_key,5,level8_fk_key,level9_fk_key) level3_fk_key_new,
        Decode(diff_level,1,level3_fk_key,2,level4_fk_key,3,level5_fk_key,4,
        level6_fk_key,5,level7_fk_key,6,level8_fk_key,level9_fk_key)
        level2_fk_key_new,
        Decode(diff_level,1,level2_fk_key,2,level3_fk_key,3,level4_fk_key,4,
        level5_fk_key,5,level6_fk_key,6,level7_fk_key,7,level8_fk_key,
        level9_fk_key) level1_fk_key_new,
        level9_name,
        Decode(diff_level,1,level8_name,level9_name) level7_name_new,
        Decode(diff_level,1,level7_name,2,level8_name,level9_name)
        level6_name_new,
        Decode(diff_level,1,level6_name,2,level7_name,3,level8_name,
        level9_name) level5_name_new,
        Decode(diff_level,1,level5_name,2,level6_name,3,level7_name,4,
        level8_name,level9_name) level4_name_new,
        Decode(diff_level,1,level4_name,2,level5_name,3,level6_name,4,
        level7_name,5,level8_name,level9_name) level3_name_new,
        Decode(diff_level,1,level3_name,2,level4_name,3,level5_name,4,
        level6_name,5,level7_name,6,level8_name,level9_name)
        level2_name_new,
        Decode(diff_level,1,level2_name,2,level3_name,3,level4_name,4,
        level5_name,5,level6_name,6,level7_name,7,level8_name,
        level9_name) level1_name_new
    from
        (--select the levels to be balanced
        SELECT hierarchy_id ,item_fk_key,
        level9_fk_key,level8_fk_key,level7_fk_key,level6_fk_key,
        level5_fk_key,level4_fk_key,level3_fk_key,level2_fk_key,
        level1_fk_key,
        level9_name,level8_name,level7_name,level6_name,
        level5_name,level4_name,level3_name,level2_name,
        level1_name,
        max_level-c_level diff_level
        FROM
          (
              SELECT hierarchy_id ,item_fk_key,
              level9_fk_key,level8_fk_key,level7_fk_key,level6_fk_key,
              level5_fk_key,level4_fk_key,level3_fk_key,level2_fk_key,
              level1_fk_key,
              level9_name,level8_name,level7_name,level6_name,
              level5_name,level4_name,level3_name,level2_name,
              level1_name,
              decode(level9_fk_key,NULL,0,1) +
              decode(level8_fk_key,NULL,0,1) +
              decode(level7_fk_key,NULL,0,1) +
              decode(level6_fk_key,NULL,0,1) +
              decode(level5_fk_key,NULL,0,1) +
              decode(level4_fk_key,NULL,0,1) +
              decode(level3_fk_key,NULL,0,1) +
              decode(level2_fk_key,NULL,0,1) +
              decode(level1_fk_key,NULL,0,1) c_level,--current level
              Max(decode(level9_fk_key,NULL,0,1) +
              decode(level8_fk_key,NULL,0,1) +
              decode(level7_fk_key,NULL,0,1) +
              decode(level6_fk_key,NULL,0,1) +
              decode(level5_fk_key,NULL,0,1) +
              decode(level4_fk_key,NULL,0,1) +
              decode(level3_fk_key,NULL,0,1) +
              decode(level2_fk_key,NULL,0,1) +
              decode(level1_fk_key,NULL,0,1)) over(PARTITION BY hierarchy_id)
              max_level--maximum level in the hierarchy
              FROM MTH.MTH_ITEM_DENORM_D_TMP
              WHERE item_fk_key != MTH_UTIL_PKG.MTH_UA_GET_VAL
          )
          WHERE c_level<max_level
	  AND level9_fk_key IS NOT NULL
        )';
      LOOP
	    --fetch the rows in in cursor. Bulk collect
            FETCH item_cur BULK COLLECT INTO denorm_rec.level9_fk_key,
            denorm_rec.hierarchy_id,
            denorm_rec.baselevel_fk_key,denorm_rec.level7_fk_key,
		denorm_rec.level6_fk_key,
            denorm_rec.level5_fk_key,denorm_rec.level4_fk_key,
            denorm_rec.level3_fk_key,denorm_rec.level2_fk_key,
		denorm_rec.level1_fk_key,
            denorm_rec.level9_name,
            denorm_rec.level7_name,
	    denorm_rec.level6_name,
            denorm_rec.level5_name,
            denorm_rec.level4_name,
            denorm_rec.level3_name,
            denorm_rec.level2_name,
	    denorm_rec.level1_name
            LIMIT v_limit;

  	    --terminating condition
            EXIT WHEN denorm_rec.baselevel_fk_key.count =0;

	    --bulk update using forall
            FORALL i IN
	denorm_rec.baselevel_fk_key.first..denorm_rec.baselevel_fk_key.last
                UPDATE MTH.MTH_ITEM_DENORM_D_TMP
                SET
                  level8_fk_key = denorm_rec.level9_fk_key(i),
                  level7_fk_key = denorm_rec.level7_fk_key(i),
                  level6_fk_key = denorm_rec.level6_fk_key(i),
                  level5_fk_key = denorm_rec.level5_fk_key(i),
                  level4_fk_key = denorm_rec.level4_fk_key(i),
                  level3_fk_key = denorm_rec.level3_fk_key(i),
                  level2_fk_key = denorm_rec.level2_fk_key(i),
                  level1_fk_key = denorm_rec.level1_fk_key(i),
                  level8_name   = denorm_rec.level9_name(i),
                  level7_name   = denorm_rec.level7_name(i),
                  level6_name   = denorm_rec.level6_name(i),
                  level5_name   = denorm_rec.level5_name(i),
                  level4_name   = denorm_rec.level4_name(i),
                  level3_name   = denorm_rec.level3_name(i),
                  level2_name   = denorm_rec.level2_name(i),
                  level1_name   = denorm_rec.level1_name(i)
                WHERE
                  item_fk_key = denorm_rec.baselevel_fk_key(i)
                  AND hierarchy_id= denorm_rec.hierarchy_id(i);
END LOOP;
--close the cursor
CLOSE item_cur;

--handle exceptions
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   RAISE_APPLICATION_ERROR (-20001,
        'Exception has occured');

END mth_hrchy_balance_load ;

/* ****************************************************************************
* Procedure		:ITEM_DIM_LOAD_DENORM_TMP	          	      *
* Description 	 	:This procedure is used to populate global temporary  *
*			 table for incremental load.     		      *
* File Name	 	:MTHITEMDB.PLS              			      *
* Visibility		:Private                			      *
* Parameters	 	:                                             	      *
* Modification log	:						      *
*			Author		Date		Change	              *
*			Yong Feng	10-July-2008	Initial Creation      *
**************************************************************************** */


PROCEDURE ITEM_DIM_LOAD_DENORM_TMP
IS
  v_unassigned_key number;
  v_unassigned_item_name varchar2(240);
  v_unassigned_category_name varchar2(240);
BEGIN

  v_unassigned_key := MTH_UTIL_PKG.MTH_UA_GET_VAL;

  BEGIN
  SELECT ITEM_NAME into v_unassigned_item_name
       from MTH_ITEMS_D
       where item_PK_KEY = v_unassigned_key;
  exception
     when TOO_MANY_ROWS then
         v_unassigned_item_name := null;
     when NO_DATA_FOUND then
         v_unassigned_item_name := null;
     when others then
         v_unassigned_item_name := null;
  end;

  BEGIN
  select CATEGORY_NAME into v_unassigned_category_name
       from MTH_ITEM_CATEGORIES_D
       where CATEGORY_PK_KEY = v_unassigned_key;
  exception
     when TOO_MANY_ROWS then
         v_unassigned_item_name := null;
     when NO_DATA_FOUND then
         v_unassigned_item_name := null;
     when others then
         v_unassigned_item_name := null;
  end;

        INSERT
        INTO    MTH.MTH_ITEM_DENORM_D_TMP
                (
                        HIERARCHY_ID,
                        ITEM_FK_KEY,
                        LEVEL1_FK_KEY,
                        LEVEL2_FK_KEY,
                        LEVEL3_FK_KEY,
                        LEVEL4_FK_KEY,
                        LEVEL5_FK_KEY,
                        LEVEL6_FK_KEY,
                        LEVEL7_FK_KEY,
                        LEVEL8_FK_KEY,
                        LEVEL9_FK_KEY,
                        LEVEL_NUM,
                        ITEM_NAME,
                        LEVEL1_NAME,
                        LEVEL2_NAME,
                        LEVEL3_NAME,
                        LEVEL4_NAME,
                        LEVEL5_NAME,
                        LEVEL6_NAME,
                        LEVEL7_NAME,
                        LEVEL8_NAME,
                        LEVEL9_NAME
                )
       SELECT HIERARCHY_ID,
       ITEM_FK_KEY,
       LEVEL1_FK_KEY,
       LEVEL2_FK_KEY,
       LEVEL3_FK_KEY,
       LEVEL4_FK_KEY,
       LEVEL5_FK_KEY,
       LEVEL6_FK_KEY,
       LEVEL7_FK_KEY,
       LEVEL8_FK_KEY,
       LEVEL9_FK_KEY,
       LEVEL_NUM,
       ITEM_NAME,
       LEVEL1_NAME,
       LEVEL2_NAME,
       LEVEL3_NAME,
       LEVEL4_NAME,
       LEVEL5_NAME,
       LEVEL6_NAME,
       LEVEL7_NAME,
       LEVEL8_NAME,
       LEVEL9_NAME
FROM   (SELECT   HIERARCHY_ID,
                 ITEM_PK_KEY         ITEM_FK_KEY,
                 MAX(LEVEL1_FK_KEY)  LEVEL1_FK_KEY,
                 MAX(LEVEL2_FK_KEY)  LEVEL2_FK_KEY,
                 MAX(LEVEL3_FK_KEY)  LEVEL3_FK_KEY,
                 MAX(LEVEL4_FK_KEY)  LEVEL4_FK_KEY,
                 MAX(LEVEL5_FK_KEY)  LEVEL5_FK_KEY,
                 MAX(LEVEL6_FK_KEY)  LEVEL6_FK_KEY,
                 MAX(LEVEL7_FK_KEY)  LEVEL7_FK_KEY,
                 MAX(LEVEL8_FK_KEY)  LEVEL8_FK_KEY,
                 MAX(LEVEL9_FK_KEY)  LEVEL9_FK_KEY,
                 MAX(LEVEL_NUM)      LEVEL_NUM,
                 MAX(ITEM_NAME)      ITEM_NAME,
                 MAX(LEVEL1_NAME)    LEVEL1_NAME,
                 MAX(LEVEL2_NAME)    LEVEL2_NAME,
                 MAX(LEVEL3_NAME)    LEVEL3_NAME,
                 MAX(LEVEL4_NAME)    LEVEL4_NAME,
                 MAX(LEVEL5_NAME)    LEVEL5_NAME,
                 MAX(LEVEL6_NAME)    LEVEL6_NAME,
                 MAX(LEVEL7_NAME)    LEVEL7_NAME,
                 MAX(LEVEL8_NAME)    LEVEL8_NAME,
                 MAX(LEVEL9_NAME)    LEVEL9_NAME
        FROM     (SELECT HIERARCHY_ID,
                         B.ITEM_PK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 1 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL9_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 2 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL8_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 3 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL7_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 4 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL6_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 5 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL5_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 6 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL4_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 7 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL3_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 8 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL2_FK_KEY,
                         (CASE
                            WHEN LEVEL_NUM = 9 THEN PARENT_FK_KEY
                            ELSE NULL
                          END) LEVEL1_FK_KEY,
                         10 LEVEL_NUM,
                         B.ITEM_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 1 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL9_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 2 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL8_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 3 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL7_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 4 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL6_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 5 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL5_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 6 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL4_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 7 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL3_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 8 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL2_NAME,
                         (CASE
                            WHEN LEVEL_NUM = 9 THEN PARENT_NAME
                            ELSE NULL
                          END) LEVEL1_NAME
                  FROM   (SELECT LEVEL  LEVEL_NUM,
                                 ITEM_PK_KEY,
                                 LEVEL_FK_KEY,
                                 LEVEL_NAME,
                                 PARENT_FK_KEY,
                                 PARENT_NAME,
                                 SYS_CONNECT_BY_PATH(LEVEL_FK_KEY,'/')   PATH,
                                 HIERARCHY_ID
                          FROM   MTH_ITEM_HIERARCHY,
                                 MTH_ITEMS_D B
                          WHERE  LEVEL_FK_KEY = B.ITEM_PK_KEY (+)
                          START WITH B.ITEM_PK_KEY IS NOT NULL
                          CONNECT BY LEVEL_FK_KEY = PRIOR PARENT_FK_KEY
                                     AND HIERARCHY_ID = PRIOR HIERARCHY_ID) A,
                         (SELECT ITEM_PK_KEY, ITEM_NAME
                          FROM   MTH_ITEMS_D) B
                  WHERE  A.PATH = ('/' || B.ITEM_PK_KEY ) OR
                                    A.PATH LIKE '/' || B.ITEM_PK_KEY || '/%' )
        --The granuality level is item and this would be done
       -- for all the hierarchies
       GROUP BY HIERARCHY_ID,ITEM_PK_KEY
UNION
select mdh.hierarchy_id,
       MTH_UTIL_PKG.MTH_UA_GET_VAL item_fk_key
       ,v_unassigned_key level1_level_key
       ,v_unassigned_key level2_level_key
       ,v_unassigned_key level3_level_key
       ,v_unassigned_key level4_level_key
       ,v_unassigned_key level5_level_key
       ,v_unassigned_key level6_level_key
       ,v_unassigned_key level7_level_key
       ,v_unassigned_key level8_level_key
       ,v_unassigned_key level9_level_key
       ,10 level_num
       ,v_unassigned_item_name item_name
       ,v_unassigned_category_name level1_name
       ,v_unassigned_category_name level2_name
       ,v_unassigned_category_name level3_name
       ,v_unassigned_category_name level4_name
       ,v_unassigned_category_name level5_name
       ,v_unassigned_category_name level6_name
       ,v_unassigned_category_name level7_name
       ,v_unassigned_category_name level8_name
       ,v_unassigned_category_name level9_name
from  dual,
      mth_dim_hierarchy mdh,
      (select distinct hierarchy_id
       from   mth_dim_level_lookup) mdll
where  mdh.dimension_name= 'ITEM' and
       mdll.hierarchy_id (+) = mdh.hierarchy_id);

-- Balance the item denorm table
mth_hrchy_balance_load('MTH.MTH_ITEM_DENORM_D_TMP');
-- Push up and fill the level key and name for the ones with NULL

UPDATE MTH.MTH_ITEM_DENORM_D_TMP
SET  level1_fk_key  = nvl(level1_fk_key, v_unassigned_key),
     level1_name    = nvl(level1_name, v_unassigned_category_name),
     level2_fk_key  = nvl(level2_fk_key, v_unassigned_key),
     level2_name    = nvl(level2_name, v_unassigned_category_name),
     level3_fk_key  = nvl(level3_fk_key, v_unassigned_key),
     level3_name    = nvl(level3_name, v_unassigned_category_name),
     level4_fk_key  = nvl(level4_fk_key, v_unassigned_key),
     level4_name    = nvl(level4_name, v_unassigned_category_name),
     level5_fk_key  = nvl(level5_fk_key, v_unassigned_key),
     level5_name    = nvl(level5_name, v_unassigned_category_name),
     level6_fk_key  = nvl(level6_fk_key, v_unassigned_key),
     level6_name    = nvl(level6_name, v_unassigned_category_name),
     level7_fk_key  = nvl(level7_fk_key, v_unassigned_key),
     level7_name    = nvl(level7_name, v_unassigned_category_name),
     level8_fk_key  = nvl(level8_fk_key, v_unassigned_key),
     level8_name    = nvl(level8_name, v_unassigned_category_name),
     level9_fk_key  = nvl(level9_fk_key, v_unassigned_key),
     level9_name    = nvl(level9_name, v_unassigned_category_name);

-- Add entries for all the rest of levels


  Insert into  MTH.MTH_ITEM_DENORM_D_TMP
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          9,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  From  MTH.MTH_ITEM_DENORM_D_TMP
  Where LEVEL9_FK_KEY is not null and level_NUM = 10;

  -- insert level 8 entries
  Insert into  MTH.MTH_ITEM_DENORM_D_TMP
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          NULL,
          8,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          NULL
  From  MTH.MTH_ITEM_DENORM_D_TMP
  Where LEVEL8_FK_KEY is not null and level_NUM = 9;

  -- insert level 7 entries
  Insert into  MTH.MTH_ITEM_DENORM_D_TMP
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          NULL,
          NULL,
          7,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          NULL,
          NULL
  From  MTH.MTH_ITEM_DENORM_D_TMP
  Where LEVEL7_FK_KEY is not null and level_NUM = 8;

  -- insert level 6 entries
  Insert into  MTH.MTH_ITEM_DENORM_D_TMP
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          NULL,
          NULL,
          NULL,
          6,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          NULL,
          NULL,
          NULL
  From  MTH.MTH_ITEM_DENORM_D_TMP
  Where LEVEL6_FK_KEY is not null and level_NUM = 7;

  -- insert level 5 entries
  Insert into  MTH.MTH_ITEM_DENORM_D_TMP
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          NULL,
          NULL,
          NULL,
          NULL,
          5,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          NULL,
          NULL,
          NULL,
          NULL
  From  MTH.MTH_ITEM_DENORM_D_TMP
  Where LEVEL5_FK_KEY is not null and level_NUM = 6;

  -- insert level 4 entries
  Insert into  MTH.MTH_ITEM_DENORM_D_TMP
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          4,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL
  From  MTH.MTH_ITEM_DENORM_D_TMP
  Where LEVEL4_FK_KEY is not null and level_NUM = 5;


  -- insert level 3 entries
  Insert into  MTH.MTH_ITEM_DENORM_D_TMP
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          3,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL
  From  MTH.MTH_ITEM_DENORM_D_TMP
  Where LEVEL3_FK_KEY is not null and level_NUM = 4;


  -- insert level 2 entries
  Insert into  MTH.MTH_ITEM_DENORM_D_TMP
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          NULL,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          2,
          NULL,
          LEVEL1_NAME,
          LEVEL2_NAME,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL
  From  MTH.MTH_ITEM_DENORM_D_TMP
  Where LEVEL2_FK_KEY is not null and level_NUM = 3;



  -- insert level 1 entries
  Insert into  MTH.MTH_ITEM_DENORM_D_TMP
  (
          HIERARCHY_ID,
          ITEM_FK_KEY,
          LEVEL1_FK_KEY,
          LEVEL2_FK_KEY,
          LEVEL3_FK_KEY,
          LEVEL4_FK_KEY,
          LEVEL5_FK_KEY,
          LEVEL6_FK_KEY,
          LEVEL7_FK_KEY,
          LEVEL8_FK_KEY,
          LEVEL9_FK_KEY,
          LEVEL_NUM,
          ITEM_NAME,
          LEVEL1_NAME,
          LEVEL2_NAME,
          LEVEL3_NAME,
          LEVEL4_NAME,
          LEVEL5_NAME,
          LEVEL6_NAME,
          LEVEL7_NAME,
          LEVEL8_NAME,
          LEVEL9_NAME
  )
  select distinct
          HIERARCHY_ID,
          null,
          LEVEL1_FK_KEY,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          1,
          null,
          LEVEL1_NAME,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL
  From  MTH.MTH_ITEM_DENORM_D_TMP
  Where LEVEL1_FK_KEY is not null and level_NUM = 2;


EXCEPTION
WHEN OTHERS THEN
    ROLLBACK;
END ITEM_DIM_LOAD_DENORM_TMP;


PROCEDURE ITEM_DIM_LOAD_DENORM_INCR
IS
BEGIN

ITEM_DIM_LOAD_DENORM_TMP;

-- delete rows that do not exist in the temp table but exist in the denorm table

DELETE FROM mth_item_denorm_d  d
WHERE NOT EXISTS
        (SELECT 1
         FROM  mth.mth_item_denorm_d_tmp t
         WHERE d.level_num = t.LEVEL_num AND
               d.hierarchy_id = t.hierarchy_id AND
               (d.item_fk_key = t.item_fk_key OR   d.item_fk_key IS null AND  t.item_fk_key IS NULL) AND
               (d.level9_fk_key = t.level9_fk_key OR d.level9_fk_key IS null AND  t.level9_fk_key IS NULL) AND
               (d.level8_fk_key = t.level8_fk_key OR d.level8_fk_key IS null AND  t.level8_fk_key IS NULL) AND
               (d.level7_fk_key = t.level7_fk_key OR d.level7_fk_key IS null AND  t.level7_fk_key IS NULL) AND
               (d.level6_fk_key = t.level6_fk_key OR d.level6_fk_key IS null AND  t.level6_fk_key IS NULL) AND
               (d.level5_fk_key = t.level5_fk_key OR d.level5_fk_key IS null AND  t.level5_fk_key IS NULL) AND
               (d.level4_fk_key = t.level4_fk_key OR d.level4_fk_key IS null AND  t.level4_fk_key IS NULL) AND
               (d.level3_fk_key = t.level3_fk_key OR d.level3_fk_key IS null AND  t.level3_fk_key IS NULL) AND
               (d.level2_fk_key = t.level2_fk_key OR d.level2_fk_key IS null AND  t.level2_fk_key IS NULL) AND
               (d.level1_fk_key = t.level1_fk_key OR d.level1_fk_key IS null AND  t.level1_fk_key IS NULL) AND
               (d.ITEM_NAME = t.ITEM_NAME OR   d.ITEM_NAME IS null AND  t.ITEM_NAME IS NULL) AND
               (d.LEVEL9_NAME = t.LEVEL9_NAME OR   d.LEVEL9_NAME IS null AND  t.LEVEL9_NAME IS NULL) AND
               (d.LEVEL8_NAME = t.LEVEL8_NAME OR   d.LEVEL8_NAME IS null AND  t.LEVEL8_NAME IS NULL) AND
               (d.LEVEL7_NAME = t.LEVEL7_NAME OR   d.LEVEL7_NAME IS null AND  t.LEVEL7_NAME IS NULL) AND
               (d.LEVEL6_NAME = t.LEVEL6_NAME OR   d.LEVEL6_NAME IS null AND  t.LEVEL6_NAME IS NULL) AND
               (d.LEVEL5_NAME = t.LEVEL5_NAME OR   d.LEVEL5_NAME IS null AND  t.LEVEL5_NAME IS NULL) AND
               (d.LEVEL4_NAME = t.LEVEL4_NAME OR   d.LEVEL4_NAME IS null AND  t.LEVEL4_NAME IS NULL) AND
               (d.LEVEL3_NAME = t.LEVEL3_NAME OR   d.LEVEL3_NAME IS null AND  t.LEVEL3_NAME IS NULL) AND
               (d.LEVEL2_NAME = t.LEVEL2_NAME OR   d.LEVEL2_NAME IS null AND  t.LEVEL2_NAME IS NULL) AND
               (d.LEVEL1_NAME = t.LEVEL1_NAME OR   d.LEVEL1_NAME IS null AND  t.LEVEL1_NAME IS NULL));


-- insert rows that exists in the temp table but not in the denorm table


insert into mth_item_denorm_d
                       (
                        HIERARCHY_ID,
                        LEVEL_NUM,
                        ITEM_FK_KEY,
                        LEVEL1_FK_KEY,
                        LEVEL2_FK_KEY,
                        LEVEL3_FK_KEY,
                        LEVEL4_FK_KEY,
                        LEVEL5_FK_KEY,
                        LEVEL6_FK_KEY,
                        LEVEL7_FK_KEY,
                        LEVEL8_FK_KEY,
                        LEVEL9_FK_KEY,
                        ITEM_NAME,
                        LEVEL9_NAME,
                        LEVEL8_NAME,
                        LEVEL7_NAME,
                        LEVEL6_NAME,
                        LEVEL5_NAME,
                        LEVEL4_NAME,
                        LEVEL3_NAME,
                        LEVEL2_NAME,
                        LEVEL1_NAME
                       )
                SELECT
                        t.HIERARCHY_ID,
                        t.LEVEL_NUM,
                        t.ITEM_FK_KEY,
                        t.LEVEL1_FK_KEY,
                        t.LEVEL2_FK_KEY,
                        t.LEVEL3_FK_KEY,
                        t.LEVEL4_FK_KEY,
                        t.LEVEL5_FK_KEY,
                        t.LEVEL6_FK_KEY,
                        t.LEVEL7_FK_KEY,
                        t.LEVEL8_FK_KEY,
                        t.LEVEL9_FK_KEY,
                        t.ITEM_NAME,
                        t.LEVEL9_NAME,
                        t.LEVEL8_NAME,
                        t.LEVEL7_NAME,
                        t.LEVEL6_NAME,
                        t.LEVEL5_NAME,
                        t.LEVEL4_NAME,
                        t.LEVEL3_NAME,
                        t.LEVEL2_NAME,
                        t.LEVEL1_NAME
                  FROM  MTH.MTH_ITEM_DENORM_D_TMP  t
                  WHERE NOT EXISTS
        (SELECT 1
         FROM  mth_item_denorm_d d
         WHERE d.level_num = t.LEVEL_num AND
               d.hierarchy_id = t.hierarchy_id AND
               (d.item_fk_key = t.item_fk_key OR   d.item_fk_key IS null AND  t.item_fk_key IS NULL) AND
               (d.level9_fk_key = t.level9_fk_key OR   d.level9_fk_key IS null AND  t.level9_fk_key IS NULL) AND
               (d.level8_fk_key = t.level8_fk_key OR   d.level8_fk_key IS null AND  t.level8_fk_key IS NULL) AND
               (d.level7_fk_key = t.level7_fk_key OR   d.level7_fk_key IS null AND  t.level7_fk_key IS NULL) AND
               (d.level6_fk_key = t.level6_fk_key OR   d.level6_fk_key IS null AND  t.level6_fk_key IS NULL) AND
               (d.level5_fk_key = t.level5_fk_key OR   d.level5_fk_key IS null AND  t.level5_fk_key IS NULL) AND
               (d.level4_fk_key = t.level4_fk_key OR   d.level4_fk_key IS null AND  t.level4_fk_key IS NULL) AND
               (d.level3_fk_key = t.level3_fk_key OR   d.level3_fk_key IS null AND  t.level3_fk_key IS NULL) AND
               (d.level2_fk_key = t.level2_fk_key OR   d.level2_fk_key IS null AND  t.level2_fk_key IS NULL) AND
               (d.level1_fk_key = t.level1_fk_key OR   d.level1_fk_key IS null AND  t.level1_fk_key IS NULL) AND
               (d.ITEM_NAME = t.ITEM_NAME OR   d.ITEM_NAME IS null AND  t.ITEM_NAME IS NULL) AND
               (d.LEVEL9_NAME = t.LEVEL9_NAME OR   d.LEVEL9_NAME IS null AND  t.LEVEL9_NAME IS NULL) AND
               (d.LEVEL8_NAME = t.LEVEL8_NAME OR   d.LEVEL8_NAME IS null AND  t.LEVEL8_NAME IS NULL) AND
               (d.LEVEL7_NAME = t.LEVEL7_NAME OR   d.LEVEL7_NAME IS null AND  t.LEVEL7_NAME IS NULL) AND
               (d.LEVEL6_NAME = t.LEVEL6_NAME OR   d.LEVEL6_NAME IS null AND  t.LEVEL6_NAME IS NULL) AND
               (d.LEVEL5_NAME = t.LEVEL5_NAME OR   d.LEVEL5_NAME IS null AND  t.LEVEL5_NAME IS NULL) AND
               (d.LEVEL4_NAME = t.LEVEL4_NAME OR   d.LEVEL4_NAME IS null AND  t.LEVEL4_NAME IS NULL) AND
               (d.LEVEL3_NAME = t.LEVEL3_NAME OR   d.LEVEL3_NAME IS null AND  t.LEVEL3_NAME IS NULL) AND
               (d.LEVEL2_NAME = t.LEVEL2_NAME OR   d.LEVEL2_NAME IS null AND  t.LEVEL2_NAME IS NULL) AND
               (d.LEVEL1_NAME = t.LEVEL1_NAME OR   d.LEVEL1_NAME IS null AND  t.LEVEL1_NAME IS NULL));



EXCEPTION
WHEN OTHERS THEN
    ROLLBACK;
END ITEM_DIM_LOAD_DENORM_INCR;


/* ****************************************************************************
* Procedure		:ITEM_DIM_HRCHY_LEVEL_LOAD                            *
* Description 	 	:This procedure will populate the level information   *
*			for the item - category and category - category	      *
*			relatiopnships in the item hierarchy staging table    *
* File Name	 	:MTHITEMDB.PLS              		      *
* Visibility		:Public                     			      *
* Parameters	 	:                                             	      *
* Modification log	:						      *
*			Author		Date			Change	      *
*			Ankit Goyal	29-May--2007	Initial Creation      *
**************************************************************************** */

PROCEDURE ITEM_DIM_HRCHY_LEVEL_LOAD
IS
BEGIN

--use connect by to find out the level number for the child and update the row
--the root node will be level 1 and the leaf node will have highest level
--having the hierarchy name in the connect query will allow multiple
--hierarchies to be present in the staging table.
--the start condition of the connect by query is the root node for
--which the parent is null.


        UPDATE MTH_ITEM_HIERARCHY_STG A
                SET LEVEL_NUM =
                (SELECT LEVEL
                FROM    MTH_ITEM_HIERARCHY_STG B
                WHERE   A.LEVEL_FK             = B.LEVEL_FK
                    AND A.HIERARCHY_NAME       = B.HIERARCHY_NAME CONNECT BY PRIOR
                        B.LEVEL_FK             = B.PARENT_FK
                    AND PRIOR B.HIERARCHY_NAME = A.HIERARCHY_NAME START
                WITH B.PARENT_FK IS NULL
                );
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
                ROLLBACK;

        --End of the procedure ITEM_DIM_HRCHY_LEVEL_LOAD
END ITEM_DIM_HRCHY_LEVEL_LOAD;


END MTH_ITEM_DIMENSION_PKG;

/
