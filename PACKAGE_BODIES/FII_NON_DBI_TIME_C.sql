--------------------------------------------------------
--  DDL for Package Body FII_NON_DBI_TIME_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_NON_DBI_TIME_C" AS
/*$Header: FIICMT2B.pls 120.1 2005/10/30 05:13:29 appldev noship $*/

g_schema          varchar2(30);
g_user_id         number := FND_GLOBAL.User_Id;
g_login_id        number := FND_GLOBAL.Login_Id;

---------------------------------------------------
-- PRIVATE PROCEDURE GATHER_TABLE_STATS
---------------------------------------------------
procedure gather_table_stats
( p_table_name in varchar2
, p_schema_name in varchar := g_schema
) is

begin

  fnd_stats.gather_table_stats( ownname => p_schema_name
                              , tabname => p_table_name
                              );

end gather_table_stats;

---------------------------------------------------
-- PUBLIC PROCEDURE LOAD_CAL_NAME
---------------------------------------------------
PROCEDURE LOAD_CAL_NAME IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_status             VARCHAR2(30);
   l_industry           VARCHAR2(30);
   l_name_row           number;
   l_max_cal_name       number;

   cursor new_cal is
     select distinct gl.period_set_name, gl.period_type from gl_periods gl
     minus
     select distinct cal.period_set_name, cal.period_type from fii_time_cal_name cal;

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_name_row    := 0;

   select nvl(max(calendar_id),0)
   into l_max_cal_name
   from fii_time_cal_name;

   IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_schema)) THEN
     NULL;
   END IF;

   -- ----------------------
   -- Populate Calendar Name Level
   -- ----------------------
   FOR new_cal_rec IN new_cal LOOP

      insert into fii_time_cal_name
      (calendar_id,
       period_set_name,
       period_type,
       name,
       creation_date,
       last_update_date,
       last_updated_by,
       created_by,
       last_update_login)
      values(
       l_max_cal_name+1,
       new_cal_rec.period_set_name,
       new_cal_rec.period_type,
       new_cal_rec.period_set_name||' ('||new_cal_rec.period_type||')',
       sysdate,
       sysdate,
       g_user_id,
       g_user_id,
       g_login_id);

       l_max_cal_name := l_max_cal_name+1;
       l_name_row := l_name_row+1;

   end loop;

   commit;

   if l_name_row > 0 then

      gather_table_stats('FII_TIME_CAL_NAME');

   end if;

end LOAD_CAL_NAME;

END FII_NON_DBI_TIME_C;

/
