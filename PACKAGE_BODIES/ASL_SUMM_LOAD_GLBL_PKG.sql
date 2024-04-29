--------------------------------------------------------
--  DDL for Package Body ASL_SUMM_LOAD_GLBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASL_SUMM_LOAD_GLBL_PKG" AS
/* $Header: aslmlogb.pls 120.1 2006/02/14 00:05:05 vjayamoh noship $ */


PROCEDURE Delete_Rows (
             p_table_name        IN  VARCHAR2
           , p_category_set_id   IN  NUMBER
	        , p_organization_id   IN  NUMBER
	        , p_category_id       IN  NUMBER
	        , x_err_msg           OUT NOCOPY VARCHAR2
	        , x_err_code          OUT NOCOPY VARCHAR2
	   ) IS

	   l_del_sql        VARCHAR2(2000);
	   l_del_where1     VARCHAR2(1000);
	   l_del_where2     VARCHAR2(1000);
	   l_del_where3     VARCHAR2(1000);
	   l_del_where4     VARCHAR2(1000);
	   l_select         VARCHAR2(2000);
	   l_where          VARCHAR2(2000);
	   l_close          VARCHAR2(200);

BEGIN
     IF p_table_name = 'ASL_INVENTORY_ITEM_DENORM' THEN

         l_del_sql    :=  'DELETE FROM ' || p_table_name ;
         l_del_where1 := ' WHERE CATEGORY_SET_ID = :1 ';
         l_del_where2 := ' AND  ORGANIZATION_ID =  :2 ';
         l_del_where3 := ' AND CATEGORY_ID  = :3 ';
         l_del_where4 := ' AND LANGUAGE_CODE  = USERENV (''LANG'') ';

         IF p_category_id IS NULL THEN
            EXECUTE IMMEDIATE l_del_sql||l_del_where1||l_del_where2||l_del_where4 using p_category_set_id, p_organization_id;
         ELSE
            EXECUTE IMMEDIATE l_del_sql||l_del_where1||l_del_where2||l_del_where3||l_del_where4 using p_category_set_id, p_organization_id, p_category_id;
         END IF;

     ELSIF p_table_name = 'ASL_INVENTORY_PRICING' THEN
         l_del_sql := ' DELETE FROM ASL_INVENTORY_PRICING AI WHERE AI.INVENTORY_ITEM_ID IN (';
         l_select  := ' SELECT AI.INVENTORY_ITEM_ID FROM ASL_INVENTORY_PRICING AI, ASL_INVENTORY_ITEM_DENORM AD';
         l_where   := ' WHERE AI.INVENTORY_ITEM_ID =  AD.INVENTORY_ITEM_ID AND AI.ORGANIZATION_ID = AD.ORGANIZATION_ID ';
         l_del_where1 := ' AND AD.CATEGORY_SET_ID = :1 ';
         l_del_where2 := ' AND AD.ORGANIZATION_ID = :2 ';
         l_del_where3 := ' AND AD.CATEGORY_ID  = :3 ';
         l_close := ' )';

         IF p_category_id IS NULL THEN
            EXECUTE IMMEDIATE l_del_sql||l_select||l_where||l_del_where1||l_del_where2||l_close  using p_category_set_id, p_organization_id;
         ELSE
            EXECUTE IMMEDIATE l_del_sql||l_select||l_where||l_del_where1||l_del_where2||l_del_where3||l_close using p_category_set_id, p_organization_id, p_category_id;
         END IF;
     ELSE
         NULL;
     END IF;


        IF SQL%NOTFOUND THEN
           NULL;
        ELSE
          COMMIT;
        END IF;

         x_err_msg  := 'Delete_Rows: PASS';
         x_err_code := '0';

END Delete_Rows;


PROCEDURE Write_Log(
              p_table         IN   VARCHAR2 DEFAULT NULL
		      , p_action        IN   VARCHAR2 DEFAULT NULL
            , p_procedure     IN   VARCHAR2 DEFAULT NULL
            , p_num_rows      IN   NUMBER   DEFAULT 0
		      , p_load_mode     IN   VARCHAR2 DEFAULT NULL
            , p_message       IN   VARCHAR2 DEFAULT NULL
            , p_start         IN   VARCHAR2 DEFAULT NULL
            , p_end           IN   VARCHAR2 DEFAULT NULL
            , p_load_year     IN   NUMBER   DEFAULT NULL
		      , p_delete_mode   IN   VARCHAR2 DEFAULT NULL
		) IS

BEGIN

     IF p_action = 'I'  -- Insert
     THEN
         FND_MESSAGE.SET_NAME( 'ASL', 'ASL_LOAD_ROWS_INSERTED' );
         FND_MESSAGE.SET_TOKEN( 'PROCEDURE', p_procedure );
         FND_MESSAGE.SET_TOKEN( 'NUMBER_OF_ROWS', p_num_rows );

     ELSIF p_action = 'U'   -- Update
     THEN
         FND_MESSAGE.SET_NAME( 'ASL', 'ASL_LOAD_ROWS_UPDATED' );
         FND_MESSAGE.SET_TOKEN( 'PROCEDURE', p_procedure );
         FND_MESSAGE.SET_TOKEN( 'NUMBER_OF_ROWS', p_num_rows );

     ELSIF p_action = 'D'   -- Delete
     THEN
         FND_MESSAGE.SET_NAME( 'ASL', 'ASL_LOAD_ROWS_DELETED' );
         FND_MESSAGE.SET_TOKEN( 'NUMBER_OF_ROWS', p_num_rows );

     ELSIF p_action = 'E'   -- Error
     THEN
         FND_MESSAGE.SET_NAME( 'ASL', 'ASL_LOAD_ERROR' );
         FND_MESSAGE.SET_TOKEN( 'PROCEDURE', p_procedure );
         FND_MESSAGE.SET_TOKEN( 'LOAD_MODE', p_load_mode );
         FND_MESSAGE.SET_TOKEN( 'ERROR_MESSAGE', p_message );

     ELSIF p_action = 'C'   -- Completed
     THEN
         FND_MESSAGE.SET_NAME( 'ASL', 'ASL_LOAD_COMPLETED' );

     ELSIF p_action = 'B'   -- Load Begin
     THEN
         FND_MESSAGE.SET_NAME( 'ASL', 'ASL_LOAD_BEGIN' );
         FND_MESSAGE.SET_TOKEN( 'START_RANGE', p_start );
         FND_MESSAGE.SET_TOKEN( 'END_RANGE', p_end );
         FND_MESSAGE.SET_TOKEN( 'LOAD_YEAR', p_load_year );
         FND_MESSAGE.SET_TOKEN( 'LOAD_MODE', p_load_mode );
         FND_MESSAGE.SET_TOKEN( 'DELETE_MODE', p_delete_mode );

     ELSE   -- Message
         FND_MESSAGE.SET_NAME( 'ASL', 'ASL_LOAD_MESSAGE' );
         FND_MESSAGE.SET_TOKEN( 'MESSAGE', p_message );
     END IF;

     FND_MESSAGE.SET_TOKEN( 'TABLE_NAME', p_table );
     FND_MESSAGE.SET_TOKEN( 'DATE_TIME', to_char(SYSDATE,'DD-MON-YYYY HH:MI:SS') );

     FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET );
	FND_MESSAGE.CLEAR;

END Write_Log;

END asl_summ_load_glbl_pkg;


/
