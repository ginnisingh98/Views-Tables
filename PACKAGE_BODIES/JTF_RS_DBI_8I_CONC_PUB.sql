--------------------------------------------------------
--  DDL for Package Body JTF_RS_DBI_8I_CONC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_DBI_8I_CONC_PUB" AS
/* $Header: jtfrsdab.pls 115.5 2004/06/09 17:31:17 nsinghai noship $ */

  /****************************************************************************
   This is 8i compatible concurrent program
   This is a concurrent program to populate the data in JTF_RS_DBI_MGR_GROUPS
   and JTF_RS_DBI_DENORM_RES_GROUPS
   table so that it can be accessed via view JTF_RS_DBI_RES_GRP_VL for Sales
   Group Hierarchy in DBI product. This program is exclusively built for DBI
   product and is NOT included in mainline code of ATG Resource Manager.

   CREATED BY         nsinghai      10/27/2003
   MODIFIED BY        nsinghai      02/18/2004   Added DBI 7.0 (Drop 2) functionality
                                                 "Expired Sales Group Hierarchy Support"
                                                 Also added manager role to be picked up
                                                 for group members. ER 3378250
   ***************************************************************************/

PROCEDURE  populate_res_grp
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2)
  IS

  CURSOR c_get_bis_date IS
  SELECT current_date_id
  FROM   bis_system_date;

  CURSOR c_product_info IS
    SELECT i.tablespace, i.index_tablespace, u.oracle_username
    FROM   fnd_product_installations i, fnd_application a, fnd_oracle_userid u
    WHERE  a.application_short_name = 'JTF'
    AND    a.application_id = i.application_id
    AND    u.oracle_id = i.oracle_id;

  l_temp_bis_date DATE;
  l_bis_date      DATE;
  l_index_owner   VARCHAR2(30) ;
  l_table_owner   VARCHAR2(30) ;
  l_index_tblspace VARCHAR2(45) ;
  l_insert_count  NUMBER       ;
  l_index_exists  VARCHAR2(10) ;
  l_sysdate       DATE         ;
  l_user_id       NUMBER       ;
  l_stage         VARCHAR2(100) ;

  l_jtfu varchar2(60);
  l_jtfx varchar2(60);
  l_jtft varchar2(60);


BEGIN
   --EXECUTE IMMEDIATE 'ALTER SESSION SET sql_trace=TRUE';

  -- Initialize variables
  l_index_owner    := 'JTF';
  l_table_owner    := 'JTF';
  l_insert_count   := 0;
  l_index_exists   := 'Y';
  l_sysdate        := sysdate;
  l_user_id        := fnd_global.user_id;
  l_stage          := 'Stage = START : '   ;

  retcode := '0' ;

  -- Call BIS_COLLECTION_UTILITIES to enable parallel session and other logging utilities
  IF(BIS_COLLECTION_UTILITIES.Setup(
       p_object_name => 'JTF_RS_DBI_RES_GRP_VL') = false)
  THEN
    errbuf := FND_MESSAGE.Get;
    retcode := '-1';
    RAISE_APPLICATION_ERROR(-20000,errbuf);
  END IF;

  -- fetch bis date
  OPEN c_get_bis_date;
  FETCH c_get_bis_date INTO l_temp_bis_date;
  CLOSE c_get_bis_date;

  --fetch user name for JTF product
  OPEN  c_product_info;
  FETCH c_product_info INTO l_jtft,l_jtfx,l_jtfu;
  CLOSE c_product_info;

  l_bis_date := TRUNC(NVL(l_temp_bis_date, SYSDATE));

  l_stage    := 'Stage = INDEX INFO : '   ;

  -- keep index information so that it is easy to create them back
  -- Check owner name for the tables and indexes.
  BEGIN
    SELECT owner, table_owner, tablespace_name
    INTO   l_index_owner, l_table_owner, l_index_tblspace
    FROM   ALL_INDEXES
    WHERE  TABLE_NAME = 'JTF_RS_DBI_DENORM_RES_GROUPS'
    AND    index_name = 'JTF_RS_DBI_DENORM_RES_GRPS_N1'
	AND    table_owner= l_jtfu;

    l_index_exists := 'Y' ;

  EXCEPTION WHEN OTHERS THEN

    l_index_exists := 'N' ;

    -- Check some ther index which will definitly exist
    SELECT owner, table_owner, tablespace_name
    INTO   l_index_owner, l_table_owner, l_index_tblspace
    FROM   ALL_INDEXES
    WHERE  TABLE_NAME = 'JTF_RS_GROUPS_DENORM'
    AND    index_name = 'JTF_RS_GROUPS_DENORM_U1'
    AND    table_owner= l_jtfu;
  END;

  BIS_COLLECTION_UTILITIES.debug('Index Information: l_index_owner='||l_index_owner
  ||': l_table_owner='||l_table_owner||': l_index_tblspace='||l_index_tblspace
  ||': Degree of parallelism='||bis_common_parameters.get_degree_of_parallelism);

  EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_table_owner||'.JTF_RS_DBI_MGR_GROUPS';

  l_stage    := 'Stage =  jtf_rs_dbi_mgr_groups : '   ;

  -- INSERT top manager groups in intermediate table
  INSERT /*+ APPEND PARALLEL(jtf_rs_dbi_mgr_groups) NOLOGGING */
  INTO   jtf_rs_dbi_mgr_groups
         (dbi_mgr_id, resource_id, user_id, group_id,
         creation_date, created_by )
  SELECT  /*+ use_hash(x) parallel(x) */
          jtf_rs_dbi_mgr_groups_s.nextval, x.resource_id, x.user_id, x.group_id
        , l_sysdate, l_user_id
  FROM (
  SELECT /*+ use_hash(res mgr) parallel(res) parallel(mgr) */
         DISTINCT mgr.resource_id, res.user_id, mgr.group_id
  FROM   jtf_rs_rep_managers mgr, jtf_rs_resource_extns res
  WHERE  mgr.hierarchy_type IN ('MGR_TO_MGR','ADMIN_TO_ADMIN')
  AND    mgr.resource_id = mgr.parent_resource_id
  AND    l_bis_date BETWEEN mgr.start_date_active
                    AND NVL(mgr.end_date_active,to_date('12/31/4712','MM/DD/RRRR'))
  AND    mgr.resource_id = res.resource_id
  AND    res.user_id IS NOT NULL ) x
  ;

  COMMIT;

  fnd_stats.gather_table_stats(ownname => l_table_owner, tabname => 'JTF_RS_DBI_MGR_GROUPS',
  percent=>5, degree=>bis_common_parameters.get_degree_of_parallelism ,granularity=>'GLOBAL',cascade=>TRUE);

  EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_table_owner||'.JTF_RS_DBI_DENORM_RES_GROUPS' ;

  -- Can drop index only if it exists
  IF (l_index_exists <> 'N') THEN
    EXECUTE IMMEDIATE 'DROP INDEX '||l_index_owner||'.JTF_RS_DBI_DENORM_RES_GRPS_N1';
  END IF;

  COMMIT;

  l_stage    := 'Stage =  Z-TOP-MANAGER-GROUPS : '   ;

  -- INSERT star groups (Top manager groups)
  INSERT /*+ APPEND PARALLEL(jtf_rs_dbi_denorm_res_groups) NOLOGGING  */
  INTO    jtf_rs_dbi_denorm_res_groups
         (VALUE, id ,  current_id ,
          parent_id , denorm_level ,  start_date ,
          end_date , user_id , resource_id,
          debug_column, denorm_id ,  mem_flag,
          mem_status ,  creation_date, created_by, active_grp_rel_only )
  SELECT  /*+ use_hash(g x) parallel(g) parallel(x) */
          '   * ' VALUE, x.group_id id , TO_NUMBER(-9999) current_id,
		  x.group_id parent_id, TO_NUMBER(0) denorm_level, g.start_date_active start_date,
          g.end_date_active end_date, x.user_id user_id, x.resource_id resource_id,
          'Z-TOP-MANAGER-GROUPS' debug_column, jtf_rs_dbi_denorm_res_groups_s.NEXTVAL denorm_id, 'N' mem_flag,
          'A' mem_status, l_sysdate creation_date, l_user_id created_by
          , 'Y' active_grp_rel_only
  FROM (
  SELECT /*+ use_hash(res mgr) parallel(res) parallel(mgr) */
         DISTINCT mgr.resource_id, res.user_id, mgr.group_id
  FROM   jtf_rs_rep_managers mgr, jtf_rs_resource_extns res
  WHERE  mgr.hierarchy_type IN ('MGR_TO_MGR','ADMIN_TO_ADMIN')
  AND    mgr.resource_id = mgr.parent_resource_id
  AND    l_bis_date BETWEEN mgr.start_date_active
                    AND NVL(mgr.end_date_active,to_date('12/31/4712','MM/DD/RRRR'))
  AND    mgr.resource_id = res.resource_id
  AND    res.user_id IS NOT NULL ) x
       , jtf_rs_groups_b g
  WHERE x.group_id = g.group_id
  ;

  COMMIT;

  l_stage    := 'Stage =  0-FIRST-TIME-GROUPS : '   ;

  --first time login groups
  INSERT /*+ APPEND PARALLEL(a) NOLOGGING  */ INTO jtf_rs_dbi_denorm_res_groups a
         (VALUE,
          id ,
          current_id ,
          parent_id ,
          denorm_level ,
          start_date ,
          end_date ,
          user_id ,
          resource_id,
          debug_column,
          denorm_id ,
          mem_flag,
          mem_status,
          creation_date,
          created_by,
		  active_grp_rel_only )
  SELECT /*+ use_hash(d1 n1) PARALLEL(d1) PARALLEL(n1) */
         DECODE(d1.denorm_level,1,DECODE(d1.active_flag,'Y','-- ','-- [ '),' ') VALUE,
         --DECODE(d1.denorm_level,1,'-- ',' ') VALUE,
		 d1.group_id id,
         TO_NUMBER(-1111) current_id, d1.actual_parent_id parent_id,
         d1.denorm_level , d1.start_date_active start_date,
         d1.end_date_active end_date, n1.user_id ,n1.resource_id ,
         '0-FIRST-TIME-GROUPS' debug_column, jtf_rs_dbi_denorm_res_groups_s.nextval
         ,'N' mem_flag , 'A' mem_status
         ,l_sysdate, l_user_id
         ,DECODE(d1.active_flag,'Y','Y','N')
  FROM   jtf_rs_groups_denorm d1 , jtf_rs_dbi_mgr_groups n1
  WHERE  n1.group_id = d1.actual_parent_id
  AND    d1.denorm_level < 2
  AND    d1.latest_relationship_flag = 'Y'
       ;

  COMMIT;

  l_stage    := 'Stage =  A-PARENT : '   ;

  --parent
  INSERT /*+ APPEND PARALLEL(a) NOLOGGING  */ INTO jtf_rs_dbi_denorm_res_groups a
         (VALUE,
          id ,
          current_id ,
          parent_id ,
          denorm_level ,
          start_date ,
          end_date ,
          user_id ,
          resource_id,
          debug_column,
          denorm_id ,
          mem_flag,
          mem_status ,
          creation_date,
          created_by,
		  active_grp_rel_only )
  SELECT /*+ use_hash(d1 d2 n1) PARALLEL(d1) PARALLEL(d2) PARALLEL(n1) */
         DECODE (d1.active_flag,'Y','  ','  [ ') VALUE,
		 d1.group_id id, d2.group_id current_id,
         d1.actual_parent_id parent_id,  d1.denorm_level,
         d1.start_date_active start_date, d1.end_date_active end_date,
         n1.user_id, n1.resource_id, 'A-PARENT' debug_column,
         jtf_rs_dbi_denorm_res_groups_s.nextval
         ,'N' mem_flag , 'A' mem_status
         ,l_sysdate, l_user_id
         ,DECODE(d1.active_flag,'Y','Y','N')
  FROM   jtf_rs_groups_denorm d1 , jtf_rs_groups_denorm d2,
         jtf_rs_dbi_mgr_groups n1
  WHERE  n1.group_id = d1.parent_group_id
  AND    d1.group_id = d2.actual_parent_id
  AND    n1.group_id = d2.parent_group_id
  AND    d1.group_id <> d2.group_id
  AND    d1.latest_relationship_flag = 'Y'
  AND    d2.latest_relationship_flag = 'Y'
  ;

  COMMIT;

  l_stage    := 'Stage =  C-SELF : '   ;

  --self
  INSERT /*+ APPEND PARALLEL(a) NOLOGGING  */ INTO jtf_rs_dbi_denorm_res_groups a
         (VALUE,
          id ,
          current_id ,
          parent_id ,
          denorm_level ,
          start_date ,
          end_date ,
          user_id ,
          resource_id,
          debug_column,
          denorm_id ,
          mem_flag,
          mem_status,
          creation_date,
          created_by,
		  active_grp_rel_only )
  SELECT /*+ use_hash(d1 n1) PARALLEL(d1) PARALLEL(n1) */
         DECODE(d1.active_flag,'Y','-- ','-- [ ') VALUE
		 , d1.group_id id, d1.group_id current_id,
         d1.actual_parent_id parent_id, d1.denorm_level,
         d1.start_date_active start_date, d1.end_date_active end_date,
         n1.user_id, n1.resource_id, 'C-SELF' debug_column,
         jtf_rs_dbi_denorm_res_groups_s.nextval
         ,'N' mem_flag , 'A' mem_status
         ,l_sysdate, l_user_id
         ,DECODE(d1.active_flag,'Y','Y','N')
  FROM   jtf_rs_groups_denorm d1, jtf_rs_dbi_mgr_groups n1
  WHERE  n1.group_id = d1.parent_group_id
  AND    d1.latest_relationship_flag = 'Y'
  ;

  COMMIT;

  l_stage    := 'Stage =  D-CHILD : '   ;

  --child
  INSERT /*+ APPEND PARALLEL(a) NOLOGGING  */ INTO jtf_rs_dbi_denorm_res_groups a
         (VALUE,
          id ,
          current_id ,
          parent_id ,
          denorm_level ,
          start_date ,
          end_date ,
          user_id ,
          resource_id,
          debug_column,
          denorm_id ,
          mem_flag,
          mem_status ,
          creation_date,
          created_by,
		  active_grp_rel_only )
  SELECT /*+ use_hash(d1 n1) PARALLEL(d1) PARALLEL(n1) */
         DECODE (d1.active_flag, 'Y','---- ','---- [ ') VALUE
		 ,d1.group_id id,
         d1.actual_parent_id current_id, d1.actual_parent_id parent_id,
         d1.denorm_level, d1.start_date_active start_date,
         d1.end_date_active end_date, n1.user_id, n1.resource_id, 'D-CHILD' debug_column
         , jtf_rs_dbi_denorm_res_groups_s.nextval
         ,'N' mem_flag , 'A' mem_status
         ,l_sysdate, l_user_id
         ,DECODE(d1.active_flag,'Y','Y','N')
  FROM   jtf_rs_groups_denorm d1, jtf_rs_dbi_mgr_groups n1
  WHERE  n1.group_id = d1.parent_group_id
    AND  d1.denorm_level > 0
   AND   d1.latest_relationship_flag = 'Y'
  ;

  COMMIT;

  --------------------Commented out by NSINGHAI on 02/20/04 --------------------
  -- This is new query if ever it has to be used for peer groups.
  -- right now shifted the query to view definition since it takes > 6 minutes
  -- and inserts 3.5 million rows in the table
  -- memory footprint in the view is comparable.It increased from 125Kb to 167Kb
  -- if anytime this insert query is to be used, the below given logic should be used.
  ------------------------------------------------------------------------------

--  l_stage    := 'Stage =  B-PEER : '   ;

  -- peer groups
--  INSERT /*+ APPEND PARALLEL(a) NOLOGGING  */ INTO jtf_rs_dbi_denorm_res_groups a
/*         (VALUE,
          id ,
          current_id ,
          parent_id ,
          denorm_level ,
          start_date ,
          end_date ,
          user_id ,
          resource_id,
          debug_column,
          denorm_id,
          mem_flag,
          mem_status ,
          creation_date,
          created_by,
          active_grp_rel_only )
    SELECT /*+ use_hash(d1 drg1) PARALLEL(d1) PARALLEL(drg1) */
/*       DECODE (d1.active_flag ,'Y', ' -- ', ' -- [ ') VALUE,
	   d1.group_id id, drg1.current_id current_id,
       d1.parent_group_id parent_id, d1.denorm_level denorm_level,
       d1.start_date_active start_date, d1.end_date_active end_date,
       drg1.user_id,  drg1.resource_id, 'B-PEER' DEBUG_COLUMN , jtf_rs_dbi_denorm_res_groups_s.nextval
       ,'N' mem_flag , 'A' mem_status
       ,l_sysdate, l_user_id
       ,DECODE(d1.active_flag,'Y','Y','N') active_grp_rel_only
    FROM   jtf_rs_groups_denorm d1,
	       jtf_rs_dbi_denorm_res_groups drg1
    WHERE  drg1.current_id = drg1.id
    AND    drg1.denorm_level > 0
    AND    drg1.parent_id = d1.parent_group_id
    AND    drg1.current_id <> d1.group_id
    AND    drg1.parent_id = d1.actual_parent_id
    AND    d1.denorm_level = 1
    AND    d1.latest_relationship_flag = 'Y'
    ;

  COMMIT;

 -- End of Peer Groups insert
*/

  l_stage    := 'Stage =  E-SELF-GROUP-MEMBERS : '   ;

  -- group members -- not for specific user -- just preprocessed records
  -- so that view performs faster and takes less sharable memory. no security applied
  -- not for 1st time login. First time login group members done after index creation.
  -- (since that query uses indexes)
  -- For group member rows, no data is inserted in Id, user_id and resource_id columns
  -- since they are not for specific user.
  -- Making it dynamic SQL because in 8i 'CASE' function doesn't work in PLSQL
  -- on 01/16/2004, Now manager and member roles will be displayed
  -- admin roles will be excluded.

  EXECUTE IMMEDIATE
  'INSERT /*+ APPEND PARALLEL(a) NOLOGGING  */ INTO jtf_rs_dbi_denorm_res_groups a
         (VALUE,
          id_for_grp_mem ,
          current_id ,
          parent_id ,
          denorm_level ,
          debug_column,
          denorm_id,
          grp_mem_resource_id,
          mem_flag,
          mem_status,
          creation_date,
          created_by,
		  active_grp_rel_only )
  SELECT  Decode(x.mem_status,''I'',''----[ '',''----'')value,
          x.resource_id||''.''||x.group_id id_for_grp_mem, x.group_id current_id,
          x.group_id parent_id, to_number(100) denorm_level,
          ''E-SELF-GROUP-MEMBERS'' debug_column , jtf_rs_dbi_denorm_res_groups_s.NEXTVAL denorm_id
          ,x.resource_id grp_mem_resource_id, ''Y'' mem_flag, x.mem_status
         ,:l_sysdate, :l_user_id, ''Y'' active_grp_rel_only
  FROM  (
        SELECT /*+ use_hash(gm1 rrl1 rol1) PARALLEL(gm1) PARALLEL(rrl1) PARALLEL(rol1) */
               DISTINCT  gm1.resource_id, gm1.group_id
              , ''A'' mem_status
        FROM   jtf_rs_group_members gm1, jtf_rs_role_relations rrl1, jtf_rs_roles_b rol1
        WHERE  gm1.group_member_id = rrl1.role_resource_id
        AND    gm1.delete_flag = ''N''
        AND    rrl1.role_resource_type = ''RS_GROUP_MEMBER''
        AND    rrl1.delete_flag = ''N''
        AND    rrl1.role_id = rol1.role_id
        AND    ''Y'' IN (rol1.member_flag, rol1.manager_flag)
        AND    rrl1.active_flag = ''Y''
        UNION ALL
        SELECT /*+ use_hash(gm2 rrl2 rol2) PARALLEL(gm2) PARALLEL(rrl2) PARALLEL(rol2) */
               DISTINCT gm2.resource_id, gm2.group_id
               , ''I'' mem_status
        FROM   jtf_rs_group_members gm2, jtf_rs_role_relations rrl2, jtf_rs_roles_b rol2
        WHERE  gm2.group_member_id = rrl2.role_resource_id
        AND    gm2.delete_flag = ''N''
        AND    rrl2.role_resource_type = ''RS_GROUP_MEMBER''
        AND    rrl2.delete_flag = ''N''
        AND    rrl2.role_id = rol2.role_id
        AND    ''Y'' IN (rol2.member_flag, rol2.manager_flag)
        AND    rrl2.active_flag IS NULL
        AND    NOT EXISTS (
                   SELECT /*+ use_hash(gm3 rrl3 rol3) PARALLEL(gm3) PARALLEL(rrl3) PARALLEL(rol3) */
				          ''1''
                   FROM   jtf_rs_group_members gm3, jtf_rs_role_relations rrl3
				        , jtf_rs_roles_b rol3
                   WHERE  gm3.group_member_id = rrl3.role_resource_id
                   AND    gm3.delete_flag = ''N''
                   AND    rrl3.role_resource_type = ''RS_GROUP_MEMBER''
                   AND    rrl3.delete_flag = ''N''
                   AND    rrl3.role_id = rol3.role_id
                   AND    ''Y'' IN (rol3.member_flag, rol3.manager_flag)
                   AND    rrl3.active_flag = ''Y''
                   AND    gm3.resource_id = gm2.resource_id
                   AND    gm3.group_id    = gm2.group_id
                )
           ) x
   ' USING l_sysdate, l_user_id
   ;

  COMMIT;

  EXECUTE IMMEDIATE 'CREATE INDEX '||l_index_owner
             ||'.JTF_RS_DBI_DENORM_RES_GRPS_N1 ON '
             ||l_table_owner||'.JTF_RS_DBI_DENORM_RES_GROUPS (current_id, user_id,  id) '
             ||' TABLESPACE '||l_index_tblspace
             ||' NOLOGGING PARALLEL (DEGREE '||bis_common_parameters.get_degree_of_parallelism||' ) ';

   fnd_stats.gather_table_stats(ownname => l_table_owner, tabname => 'JTF_RS_DBI_DENORM_RES_GROUPS',
   percent=>5, degree=>bis_common_parameters.get_degree_of_parallelism, granularity=>'GLOBAL',cascade=>TRUE);

  ---------Commented out this code on 18th Feb 04 by NSINGHAI ------------------
  -- we do not need first time login
  -- child groups any more because, all teams will query the function
  -- jtf_rs_dbi_conc_pub.get_sg_id to default first time login groups for
  -- their pages. Teams will never see first time login functionality in
  -- Sales Group LOV dropdown.
  -----------------------------------------------------------------------------
--  l_stage    := 'Stage =  F-FIRST-TIME-GROUP-MEMBERS : '   ;

  --Insert FIRST TIME LOGIN group members. To be done after index is created because
  -- the select statement given below uses index in the query
  -- Here, no data inserted for Id column. In view, id_for_grp_mem column will be used as
  -- id. This is just for group members rows.
  -- Making it dynamic SQL because in 8i 'CASE' function doesn't work in PLSQL
--  EXECUTE IMMEDIATE
--  'INSERT /*+ APPEND PARALLEL(a) NOLOGGING  */ INTO jtf_rs_dbi_denorm_res_groups a
/*         (VALUE,
          id_for_grp_mem ,
          current_id ,
          parent_id ,
          denorm_level ,
          user_id ,
          resource_id,
          debug_column,
          denorm_id,
          grp_mem_resource_id,
          mem_flag,
          mem_status ,
          creation_date,
          created_by )
  SELECT  Decode(x.mem_status,''I'',''--[ '',''--'')value,
          x.grp_mem_resource_id||''.''||x.group_id id_for_grp_mem, to_number(-1111) current_id,
          x.group_id parent_id, to_number(1) denorm_level, x.user_id, x.resource_id,
          ''F-FIRST-TIME-GROUP-MEMBERS'' debug_column , jtf_rs_dbi_denorm_res_groups_s.NEXTVAL denorm_id
          ,x.grp_mem_resource_id, ''Y'' mem_flag, x.mem_status
         ,:l_sysdate, :l_user_id
  FROM  (
  SELECT  /*+ use_hash(dbi mem rrl rol) PARALLEL(dbi) PARALLEL(mem) PARALLEL(rrl)
              PARALLEL(rol)*/
/*          DISTINCT mem.resource_id grp_mem_resource_id, mem.group_id, to_number(-1111) current_id,
          dbi.user_id, dbi.resource_id,
          CASE WHEN :l_bis_date BETWEEN rrl.start_date_active AND nvl(rrl.end_date_active, :l_bis_date + 1)
           THEN ''A'' ELSE ''I'' END AS mem_status
  FROM   jtf_rs_group_members mem,
         jtf_rs_role_relations rrl,
         jtf_rs_dbi_denorm_res_groups dbi
         ,jtf_rs_roles_b rol
  WHERE  mem.group_member_id = rrl.role_resource_id
  AND    mem.delete_flag = ''N''
  AND    rrl.role_resource_type = ''RS_GROUP_MEMBER''
  AND    rrl.delete_flag = ''N''
  AND    dbi.id = mem.group_id
  AND    dbi.id = dbi.parent_id
  AND    dbi.current_id = -1111
  AND    dbi.denorm_level = 0
  AND    rrl.role_id = rol.role_id
  AND    rol.member_flag = ''Y''
  ) x
  ' USING l_sysdate, l_user_id, l_bis_date, l_bis_date;

  COMMIT;

  fnd_stats.gather_table_stats(ownname => l_table_owner, tabname => 'JTF_RS_DBI_DENORM_RES_GROUPS',
  percent=>5, degree=>bis_common_parameters.get_degree_of_parallelism, granularity=>'GLOBAL',cascade=>TRUE);

*/

  SELECT COUNT(*)
  INTO   l_insert_count
  FROM   jtf_rs_dbi_denorm_res_groups;

  l_stage    := 'Stage =  WRAPUP : '   ;

  BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => TRUE ,
   p_count       => l_insert_count,
   p_period_to   => l_bis_date);

  --EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE=FALSE';

 EXCEPTION
   WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.log, l_stage||sqlcode||':'||sqlerrm);
     retcode := '2'; -- Error
     errbuf  := l_stage||sqlerrm;
     BIS_COLLECTION_UTILITIES.Debug('Error in Update Sales Group Hierarchy: '||l_stage||errbuf);

     BIS_COLLECTION_UTILITIES.wrapup(
       p_status      => FALSE ,
       p_message     => l_stage||sqlerrm,
       p_count       => l_insert_count,
       p_period_to   => l_bis_date);

     -- dbms_output.put_line('Error : '||sqlcode||':'||sqlerrm);

  END populate_res_grp;

  /****************************************************************************
      This function is for providing a common method of fetching the group id
      for first time login pages. Instead of passing '-1111' to Sales Group
      Dimension LOV, product teams will call this function which will return
      them a valid group id. This group id will be used by product teams to
      query the data rather then querying data for dummy group '-1111'.
      Internally this function will query for '-1111' and then return the first
      record.

      This is 8i compatible version

   ER # 3155246
   Created By      nsinghai      03-Oct-2003
   ***************************************************************************/

   FUNCTION get_sg_id RETURN VARCHAR2 IS
     l_sg_id  VARCHAR2(100);

   BEGIN
     -- dynamic sql for 8i
     EXECUTE IMMEDIATE
     'SELECT id
      FROM   (
             SELECT id, rank() over (order by value, id  nulls last) rnk
             FROM   jtf_rs_dbi_res_grp_vl
             WHERE  usage = ''SALES''
             AND    current_id = -1111
             AND    denorm_level = 0
            )
      WHERE rnk = 1'  INTO   l_sg_id;

    l_sg_id := NVL(l_sg_id, '-1111');

   RETURN l_sg_id;

   EXCEPTION
     WHEN OTHERS THEN
       RETURN '-1111';
  END get_sg_id;

END jtf_rs_dbi_8i_conc_pub ; -- end package body

/
