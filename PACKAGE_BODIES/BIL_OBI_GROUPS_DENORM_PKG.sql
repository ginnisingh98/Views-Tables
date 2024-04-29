--------------------------------------------------------
--  DDL for Package Body BIL_OBI_GROUPS_DENORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_OBI_GROUPS_DENORM_PKG" AS
/*$Header: bilobieesgb.pls 120.0.12000000.1 2007/04/12 06:04:26 kreardon noship $*/

  g_pkg VARCHAR2(240);
  g_row_num NUMBER;

 PROCEDURE load(errbuf              IN OUT NOCOPY VARCHAR2,
                retcode             IN OUT NOCOPY  VARCHAR2) IS

 l_proc VARCHAR2(100);
 l_stmt VARCHAR2(400);
 p_table_name VARCHAR2(400);
 l_schema_name VARCHAR2(400);
  BEGIN

   g_pkg := 'bil.patch.115.sql.bil_obi_groups_denorm_pkg.';
   l_proc := 'load';
   p_table_name := 'BIL_OBI_RS_GROUPS_DENORM';

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
   END IF;

        l_schema_name := bil_bi_util_collection_pkg.get_schema_name('BIL');
        l_stmt:='TRUNCATE TABLE '|| l_schema_name || '.' || p_table_name;

        EXECUTE IMMEDIATE l_stmt;

   INSERT INTO BIL_OBI_RS_GROUPS_DENORM
   (DENORM_GRP_ID,
    PARENT_GROUP_ID,
    GROUP_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    IMMEDIATE_PARENT_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    ACTIVE_FLAG,
    DENORM_LEVEL,
    GROUP_LEVEL1,
    GROUP_LEVEL2,
    GROUP_LEVEL3,
    GROUP_LEVEL4)
select denorm_grp_id, parent_group_id, group_id, created_by, creation_date,last_updated_by, last_update_date,
last_update_login, immediate_parent_flag, start_date_active, end_date_active, active_flag, denorm_level,
decode(denorm_level,0,group_id, group_level1) group_level1,
decode(denorm_level,0,group_id,1,group_id,group_level2) group_level2,
decode(denorm_level,0,group_id,1,group_id,2,group_id,group_level3) group_level3,
decode(denorm_level,0,group_id,1,group_id,2,group_id,3,group_id,group_level4) group_level4
from
(select denorm_grp_id, parent_group_id, group_id, created_by, creation_date,last_updated_by, last_update_date,
last_update_login, immediate_parent_flag, start_date_active, end_date_active, active_flag, denorm_level, group_level1,
group_level2, group_level3, group_level4, lag(group_level4) over (partition by group_id order by group_id, denorm_level) group_level5
from
(select denorm_grp_id, group_id, parent_group_id, created_by, creation_date,last_updated_by, last_update_date,
last_update_login, immediate_parent_flag, start_date_active, end_date_active, active_flag, denorm_level, group_level1,
group_level2, group_level3, lag(group_level3) over (partition by group_id order by group_id, denorm_level) group_level4
from
(select denorm_grp_id, group_id, parent_group_id, created_by, creation_date,last_updated_by, last_update_date,
last_update_login, immediate_parent_flag, start_date_active, end_date_active, active_flag, denorm_level, group_level1,
group_level2, lag(group_level2) over (partition by group_id order by group_id, denorm_level) group_level3
from
(select denorm_grp_id, group_id, parent_group_id, created_by, creation_date,last_updated_by, last_update_date,
last_update_login, immediate_parent_flag, start_date_active, end_date_active, active_flag, denorm_level, group_level1,
lag(group_level1) over (partition by group_id order by group_id, denorm_level) group_level2
from
(select denorm_grp_id, group_id, parent_group_id, created_by, creation_date,last_updated_by, last_update_date,
last_update_login, immediate_parent_flag, start_date_active, end_date_active, active_flag, denorm_level,
lag(parent_group_id) over (partition by group_id order by group_id, denorm_level) group_level1
from
(select j.denorm_grp_id, j.group_id, j.parent_group_id, j.created_by, j.creation_date,j.last_updated_by,
j.last_update_date,j.last_update_login, j.immediate_parent_flag, j.start_date_active, j.end_date_active,
j.active_flag, j.denorm_level
from jtf_rs_groups_denorm j, jtf_rs_group_usages u
where j.group_id = u.group_id
and   u.usage = 'SALES'
and latest_relationship_flag = 'Y'
order by group_id, denorm_level))))));


 	g_row_num := sql%rowcount;

    	COMMIT;

    	IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
       		bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Inserted  '||g_row_num||' into BIL_OBI_RS_GROUPS_DENORM table from JTF_RS_GROUPS_DENORM');
    	END IF;

    	IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
       	bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end ',
             p_msg => 'End of Procedure '|| l_proc);
	END IF;

   Exception
    When Others Then
      fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON' ,SQLERRM);
      fnd_message.set_token('ROUTINE' , l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
           p_module => g_pkg || l_proc || ' proc_error',
           p_msg => fnd_message.get,
           p_force_log => TRUE);

   RAISE;

END load;


END BIL_OBI_GROUPS_DENORM_PKG;

/
