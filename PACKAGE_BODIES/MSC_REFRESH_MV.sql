--------------------------------------------------------
--  DDL for Package Body MSC_REFRESH_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_REFRESH_MV" AS
/* $Header: MSCRFMVB.pls 120.1 2005/06/19 23:03:45 appldev ship $ */

PROCEDURE REFRESH_MAT_VIEWS(
                      ERRBUF             OUT NOCOPY VARCHAR2, /* file.sql.39 change 4405879 */
                      RETCODE            OUT NOCOPY NUMBER,  /* file.sql.39 change 4405879 */
                      p_mv_name          IN  VARCHAR2,
                      p_schema_id        IN  NUMBER DEFAULT 724)
   IS

   l_schema_name     VARCHAR2(30);
   l_mv_exist      number;
   l_complete_refresh_flag  varchar2(1) := 'C' ;
   l_mv_name            varchar2(240) ;

   Cursor application_schema IS
    SELECT a.oracle_username
    FROM   FND_ORACLE_USERID a, FND_PRODUCT_INSTALLATIONS b
    WHERE  a.oracle_id = b.oracle_id
    AND    b.application_id= p_schema_id;

   Cursor mv_exist(p_mv_trim_name varchar2, p_schema_name varchar2) IS
    SELECT 1
    FROM   all_objects
    WHERE  object_name = p_mv_trim_name
    AND    owner = p_schema_name;

BEGIN
      msc_util.msc_log('Begin REFRESH_MAT_VIEWS');
      RETCODE:= G_SUCCESS;

      select nvl(ltrim(rtrim(upper(p_mv_name))), '@@@') into l_mv_name from dual;

      OPEN application_schema;
      FETCH application_schema INTO l_schema_name;
      CLOSE application_schema;

      OPEN mv_exist(l_mv_name, l_schema_name);
      FETCH mv_exist INTO l_mv_exist;
      CLOSE mv_exist;

      if (l_mv_exist = 1) then
         -- msc_util.msc_log('Refreshing ' || l_mv_name);
	 fnd_message.set_name('MSC','MSC_REF_MV_EXIST_PRE');
	 fnd_message.set_token('VIEW_NAME',l_mv_name);
	 msc_util.msc_log(fnd_message.get);
         DBMS_SNAPSHOT.REFRESH( l_schema_name||'.'||l_mv_name , l_complete_refresh_flag);
      else
         -- msc_util.msc_log(l_schema_name||'.'||l_mv_name ||' does not exist');
         fnd_message.set_name('MSC','MSC_REF_MV_EXIST_ERR');
         fnd_message.set_token('VIEW_NAME',l_mv_name);
         fnd_message.set_token('SCHEMA_NAME',l_schema_name);
         msc_util.msc_log(fnd_message.get);
         RETCODE:= G_ERROR;
      end if;

      msc_util.msc_log('End REFRESH_MAT_VIEWS');

   EXCEPTION

   WHEN OTHERS THEN
        msc_util.msc_log(sqlerrm);
        RETCODE:= G_ERROR;
        ERRBUF:= SQLERRM;

   END REFRESH_MAT_VIEWS;


END MSC_REFRESH_MV;

/
