--------------------------------------------------------
--  DDL for Package Body JTF_RS_DBI_CONC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_DBI_CONC_PUB" AS
/* $Header: jtfrsdbb.pls 120.0 2005/05/11 08:19:47 appldev noship $ */

  /****************************************************************************
   This is a concurrent program to populate the data in JTF_RS_DBI_MGR_GROUPS
   and JTF_RS_DBI_DENORM_RES_GROUPS
   table so that it can be accessed via view JTF_RS_DBI_RES_GRP_VL for Sales
   Group Hierarchy in DBI product. This program is exclusively built for DBI
   product and is NOT included in mainline code of ATG Resource Manager.

   CREATED BY         nsinghai      01/16/2003
   MODIFIED BY        nsinghai      02/28/2003 -- Added BIS_COLLECTION_UTILITIES
                                               -- call for setup, wrapup, debug
                                               -- so that parallel session enabling
                                               -- can be done by setup program
                                               -- itself. Done after instructions
                                               -- from performance team.
                      nsinghai      10/03/2003 -- Commented out active_parent_id
                                               -- update in groups denorm (Bug 3162692)
                      nsinghai      10/03/2003 -- Added function get_sg_id for
                                               -- fetching group id for first time login
                                               -- sales pages (usage = 'SALES')
		                               -- ER Bug # 3155246
                      nsinghai      11/18/2003 -- modified for ER 3263259 -to just show
		                               -- the persons with member roles. Manager
		                               -- and admin roles will be excluded.
      		      nsinghai      02/11/2004 -- Perf. Bug # 3423173. Removed peer groups
		                               -- from the insert code. It was the costliest
		                               -- query. Doing online query for peer in view
		                               -- at runtime.
		                               -- Removed first time login group members. This
		                               -- functionality is not being used in product
   		      		       	       -- pages.
                     nsinghai       06/07/2004 -- Bug 3651322, 8i compatibility issue for 11.5.10
                                                  copied code from jtfrsdab.pls (115.4)
                                                  (8i version code). This will go in ver 115.18
                                                  In version 115.19 will revert back the code to
                                                  existing 9i version (same as 115.17).
                     nsinghai       06/07/2004 -- Reverted back to 9i version. Same as 115.17
                                                  for DBI 7.0.
                                                  Moved the variable assignment from declaration
                                                  to body of the code.
                     nsinghai       07/13/2004 -- ER 3761218 - Field Service District DBI conc prog
                                                  Created new procedure populate_main and populate_fld_srv_district
                                                  Moved main processing to populate_main procedure. Similarly
                                                  created new function for taking usage as input parameter.
                     nsinghai       09/03/2004    ER 3855071 - Pass back NULL instead of '-1111' if some exception
                                                  occures in get_sg_id, get_fsg_id and get_first_login_group_id
                                                  functions.
   ***************************************************************************/

/****************************************************************************
  This is a concurrent program to populate the data that can be accessed via view
  JTF_RS_DBI_RES_GRP_VL for Sales Group Hierarchy (usage : SALES) in DBI
  product.

  This program is exclusively built for DBI product and is NOT included in
  mainline code of ATG Resource Manager.

  Created By       nsinghai      16-Jan-2003
 ***************************************************************************/

PROCEDURE  populate_res_grp
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2)
  IS
BEGIN
  retcode := 0;

  JTF_RS_DBI_CONC_PUB.POPULATE_MAIN (P_USAGE   => 'SALES',
                                     P_ERRBUF  => ERRBUF,
                                     P_RETCODE => RETCODE
                                     );
EXCEPTION
  WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
     retcode := '2'; -- Error
     errbuf  := sqlerrm;
     BIS_COLLECTION_UTILITIES.Debug('Error in Update Sales Group Hierarchy:'||errbuf);
END populate_res_grp;

/****************************************************************************
 This is concurrent program to populate the data that can be accessed via view
 JTF_RS_DBI_RES_GRP_VL for usage 'FLD_SRV_DISTRICT' (Field Service District
 Hierarchy) in DBI product.

 This program is exclusively built for DBI product and is NOT included in
 mainline code of ATG Resource Manager.

 Created By       nsinghai      01-JUL-2004
***************************************************************************/

PROCEDURE  populate_fld_srv_district
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2)
  IS
BEGIN
  retcode := 0; -- success

  JTF_RS_DBI_CONC_PUB.POPULATE_MAIN (P_USAGE   => 'FLD_SRV_DISTRICT',
                                     P_ERRBUF  => ERRBUF,
                                     P_RETCODE => RETCODE
                                     );
EXCEPTION
  WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
     retcode := '2'; -- Error
     errbuf  := sqlerrm;
     BIS_COLLECTION_UTILITIES.Debug('Error in Update Field Service District Hierarchy:'||errbuf);
END populate_fld_srv_district;

  /****************************************************************************
   This is main procedure to populate the data in JTF_RS_DBI_MGR_GROUPS
   and JTF_RS_DBI_DENORM_RES_GROUPS table so that it can be accessed via view
   JTF_RS_DBI_RES_GRP_VL for usage 'SALES' (Sales Group Hierarchy) and
   'FLD_SRV_DISTRICT' (Field Service District Hierarchy) in DBI product.

   This program is exclusively built for DBI product and is NOT included in
   mainline code of ATG Resource Manager.

   Created By       nsinghai      01-JUL-2004
   ***************************************************************************/

PROCEDURE  populate_main
  (P_USAGE                     IN  VARCHAR2,
   P_ERRBUF                    OUT NOCOPY VARCHAR2,
   P_RETCODE                   OUT NOCOPY VARCHAR2)
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
  l_index_owner   VARCHAR2(240) ;
  l_table_owner   VARCHAR2(240) ;
  l_index_tblspace VARCHAR2(240) ;
  l_insert_count  NUMBER       ;
  l_index_exists  VARCHAR2(10) ;
  l_sysdate       DATE         ;
  l_user_id       NUMBER       ;

  l_jtfu          VARCHAR2(240);
  l_jtfx          VARCHAR2(240);
  l_jtft          VARCHAR2(240);

  l_usage         VARCHAR2(100);
  l_partition     VARCHAR2(100);

BEGIN
  -- EXECUTE IMMEDIATE 'ALTER SESSION SET sql_trace=TRUE';

  l_index_owner   := 'JTF';
  l_table_owner   := 'JTF';
  l_insert_count  := 0;
  l_index_exists  := 'Y';
  l_sysdate       := sysdate;
  l_user_id       := fnd_global.user_id;

  l_usage         := p_usage;
  l_partition     := 'USAGE_'||p_usage||'_P1' ;

  p_retcode := '0' ;

  -- Call BIS_COLLECTION_UTILITIES to enable parallel session and other logging utilities
  IF(BIS_COLLECTION_UTILITIES.Setup(
       p_object_name => 'JTF_RS_DBI_RES_GRP_VL') = false)
  THEN
    p_errbuf := FND_MESSAGE.Get;
    p_retcode := '-1';
    RAISE_APPLICATION_ERROR(-20000,p_errbuf);
  END IF;

  -- fetch bis date
  OPEN c_get_bis_date;
  FETCH c_get_bis_date INTO l_temp_bis_date;
  CLOSE c_get_bis_date;

  l_bis_date := TRUNC(NVL(l_temp_bis_date, SYSDATE));

  --fetch user name for JTF product
  OPEN  c_product_info;
  FETCH c_product_info INTO l_jtft,l_jtfx,l_jtfu;
  CLOSE c_product_info;

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

  IF (l_index_tblspace IS NULL) THEN
    l_index_tblspace := l_jtfx;
  END IF;

  IF (l_index_owner IS NULL) THEN
    l_index_owner := l_jtfu;
  END IF;

  BIS_COLLECTION_UTILITIES.debug('Index Information: l_index_owner='||l_index_owner
  ||': l_table_owner='||l_table_owner||': l_index_tblspace='||l_index_tblspace
  ||': Degree of parallelism='||bis_common_parameters.get_degree_of_parallelism
  ||': Partition= '||l_partition);

  -- Truncate Table Partitions
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_table_owner||'.JTF_RS_DBI_MGR_GROUPS TRUNCATE PARTITION '||l_partition ;
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_table_owner||'.JTF_RS_DBI_DENORM_RES_GROUPS TRUNCATE PARTITION '||l_partition;

  -- Make indexes unusable
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_table_owner||'.JTF_RS_DBI_MGR_GROUPS MODIFY PARTITION '||l_partition||' UNUSABLE LOCAL INDEXES ';
  EXECUTE IMMEDIATE 'ALTER TABLE '||l_table_owner||'.JTF_RS_DBI_DENORM_RES_GROUPS MODIFY PARTITION '||l_partition||' UNUSABLE LOCAL INDEXES ';

  -- change session parameter so that data can be inserted in partition containing unusable index
  EXECUTE IMMEDIATE 'ALTER SESSION SET SKIP_UNUSABLE_INDEXES = TRUE ' ;

  COMMIT;

  -- MULTI-TABLE Insert
  -- INSERT top manager groups in intermediate table
  -- INSERT star groups (Top manager groups)
  -- INSERT top manager groups (first time login manager groups) in main table
  INSERT ALL
  INTO /*+ APPEND PARALLEL(jtf_rs_dbi_mgr_groups) NOLOGGING */ jtf_rs_dbi_mgr_groups
         (dbi_mgr_id, resource_id, user_id, group_id,
         creation_date, created_by
		 ,last_update_date, last_updated_by, usage )
  VALUES (jtf_rs_dbi_mgr_groups_s.nextval, resource_id, user_id, group_id
        , l_sysdate, l_user_id
		, l_sysdate, l_user_id, usage)
  INTO  /*+ APPEND PARALLEL(jtf_rs_dbi_denorm_res_groups) NOLOGGING  */ jtf_rs_dbi_denorm_res_groups
         (VALUE, id ,  current_id ,
          parent_id , denorm_level ,
		  start_date , end_date ,
		  user_id ,
		  resource_id,
          debug_column, denorm_id ,  mem_flag,
          mem_status ,  creation_date, created_by
		  ,active_grp_rel_only
          ,last_update_date, last_updated_by, usage )
  VALUES ('    * ', group_id, TO_NUMBER(-9999),
           group_id, TO_NUMBER(0),
		   start_date_active,  end_date_active,
		   user_id, resource_id,
           'Z-TOP-MANAGER-GROUPS', jtf_rs_dbi_denorm_res_groups_s.NEXTVAL, 'N',
           'A', l_sysdate, l_user_id ,'Y'
           , l_sysdate, l_user_id, usage)
INTO /*+ APPEND PARALLEL(jtf_rs_dbi_denorm_res_groups) NOLOGGING  */ jtf_rs_dbi_denorm_res_groups
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
		  active_grp_rel_only
          ,last_update_date, last_updated_by, usage )
  VALUES ( ' ', group_id , TO_NUMBER(-1111) , group_id ,
           TO_NUMBER(0) , start_date_active , end_date_active ,
		   user_id , resource_id ,
		   '0-FIRST-TIME-PARENT-GROUPS' , jtf_rs_dbi_denorm_res_groups_s.nextval
           ,'N' , 'A' ,l_sysdate, l_user_id, 'Y'
           , l_sysdate, l_user_id, usage)
  SELECT  /*+ use_hash(g x usg) parallel(g) parallel(x) parallel(usg)*/
          x.resource_id, x.user_id, x.group_id
        , g.start_date_active, g.end_date_active
        , usg.usage
  FROM (
  SELECT /*+ use_hash(res mgr) parallel(res) parallel(mgr) */
         DISTINCT mgr.resource_id, res.user_id, mgr.group_id
  FROM   jtf_rs_rep_managers mgr, jtf_rs_resource_extns res
  WHERE  mgr.hierarchy_type IN ('MGR_TO_MGR','ADMIN_TO_ADMIN')
  AND    mgr.resource_id = mgr.parent_resource_id
  AND    l_bis_date BETWEEN mgr.start_date_active
                    AND NVL(mgr.end_date_active,to_date('12/31/4712','MM/DD/RRRR'))
  AND    mgr.resource_id = res.resource_id
  AND    res.user_id IS NOT NULL
  ) x
       , jtf_rs_groups_b g
       , jtf_rs_group_usages usg
  WHERE x.group_id = g.group_id
    AND x.group_id = usg.group_id
    AND usg.usage = l_usage
  ;

  l_insert_count := l_insert_count + SQL%ROWCOUNT ;

  COMMIT;

  EXECUTE IMMEDIATE 'ALTER TABLE '||l_table_owner||'.JTF_RS_DBI_MGR_GROUPS '||
           ' MODIFY PARTITION '||l_partition||' REBUILD UNUSABLE LOCAL INDEXES ';

  fnd_stats.gather_table_stats(ownname => l_table_owner, tabname => 'JTF_RS_DBI_MGR_GROUPS',
  percent=>5, degree=>bis_common_parameters.get_degree_of_parallelism ,granularity=>'ALL',cascade=>TRUE);

  -- first time login child groups
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
		  active_grp_rel_only,
		  last_update_date,
		  last_updated_by,
		  usage )
  SELECT /*+ use_hash(d1 n1 usg) PARALLEL(d1) PARALLEL(n1) PARALLEL(usg)*/
         DECODE(d1.active_flag,'Y','-- ','-- [ ') VALUE
         , d1.group_id id,
         TO_NUMBER(-1111) current_id, d1.actual_parent_id parent_id,
         d1.denorm_level , d1.start_date_active start_date,
         d1.end_date_active end_date, n1.user_id ,n1.resource_id ,
         '0-FIRST-TIME-CHILD-GROUPS' debug_column, jtf_rs_dbi_denorm_res_groups_s.nextval
         ,'N' mem_flag , 'A' mem_status
         ,l_sysdate, l_user_id
         ,DECODE(d1.active_flag,'Y','Y','N')
         ,l_sysdate, l_user_id, usg.usage
  FROM   jtf_rs_groups_denorm d1 , jtf_rs_dbi_mgr_groups n1
         , jtf_rs_group_usages usg
  WHERE  n1.group_id = d1.actual_parent_id
  AND    d1.denorm_level = 1
  AND    d1.latest_relationship_flag = 'Y'
  AND    d1.group_id = usg.group_id
  AND    usg.usage = l_usage
  AND    n1.usage  = l_usage
  ;

  l_insert_count := l_insert_count + SQL%ROWCOUNT ;

  COMMIT;

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
		  active_grp_rel_only,
		  last_update_date,
		  last_updated_by,
		  usage )
  SELECT /*+ use_hash(d1 d2 n1 usg) PARALLEL(d1) PARALLEL(d2) PARALLEL(n1) PARALLEL(usg) */
         DECODE (d1.active_flag,'Y','  ','  [ ') VALUE
		 , d1.group_id id, d2.group_id current_id,
         d1.actual_parent_id parent_id,  d1.denorm_level,
         d1.start_date_active start_date, d1.end_date_active end_date,
         n1.user_id, n1.resource_id, 'A-PARENT' debug_column,
         jtf_rs_dbi_denorm_res_groups_s.nextval
         ,'N' mem_flag , 'A' mem_status
         ,l_sysdate, l_user_id
         ,DECODE(d1.active_flag,'Y','Y','N')
         ,l_sysdate, l_user_id, usg.usage
  FROM   jtf_rs_groups_denorm d1 , jtf_rs_groups_denorm d2,
         jtf_rs_dbi_mgr_groups n1
         ,jtf_rs_group_usages usg
  WHERE  n1.group_id = d1.parent_group_id
  AND    d1.group_id = d2.actual_parent_id
  AND    n1.group_id = d2.parent_group_id
  AND    d1.group_id <> d2.group_id
  AND    d1.latest_relationship_flag = 'Y'
  AND    d2.latest_relationship_flag = 'Y'
  AND    d1.group_id = usg.group_id
  AND    usg.usage = l_usage
  AND    n1.usage = l_usage
  ;

  l_insert_count := l_insert_count + SQL%ROWCOUNT ;

  COMMIT;

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
		  active_grp_rel_only,
		  last_update_date,
		  last_updated_by,
		  usage )
  SELECT /*+ use_hash(d1 n1 usg) PARALLEL(d1) PARALLEL(n1) PARALLEL(usg) */
         DECODE(d1.active_flag,'Y','-- ','-- [ ') VALUE
		 , d1.group_id id, d1.group_id current_id,
         d1.actual_parent_id parent_id, d1.denorm_level,
         d1.start_date_active start_date, d1.end_date_active end_date,
         n1.user_id, n1.resource_id, 'C-SELF' debug_column,
         jtf_rs_dbi_denorm_res_groups_s.nextval
         ,'N' mem_flag , 'A' mem_status
         ,l_sysdate, l_user_id
         ,DECODE(d1.active_flag,'Y','Y','N')
         ,l_sysdate, l_user_id, usg.usage
  FROM   jtf_rs_groups_denorm d1, jtf_rs_dbi_mgr_groups n1
         ,jtf_rs_group_usages usg
  WHERE  n1.group_id = d1.parent_group_id
  AND    d1.latest_relationship_flag = 'Y'
  AND    d1.group_id = usg.group_id
  AND    usg.usage = l_usage
  AND    n1.usage  = l_usage
  ;

  l_insert_count := l_insert_count + SQL%ROWCOUNT ;

  COMMIT;

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
		  active_grp_rel_only,
		  last_update_date,
		  last_updated_by,
		  usage )
  SELECT /*+ use_hash(d1 n1 usg) PARALLEL(d1) PARALLEL(n1) PARALLEL(usg) */
         DECODE (d1.active_flag, 'Y','---- ','---- [ ') VALUE
		 ,d1.group_id id,
         d1.actual_parent_id current_id, d1.actual_parent_id parent_id,
         d1.denorm_level, d1.start_date_active start_date,
         d1.end_date_active end_date, n1.user_id, n1.resource_id, 'D-CHILD' debug_column
         , jtf_rs_dbi_denorm_res_groups_s.nextval
         ,'N' mem_flag , 'A' mem_status
         ,l_sysdate, l_user_id
         ,DECODE(d1.active_flag,'Y','Y','N')
         ,l_sysdate, l_user_id, usg.usage
  FROM   jtf_rs_groups_denorm d1, jtf_rs_dbi_mgr_groups n1
         ,jtf_rs_group_usages usg
  WHERE  n1.group_id = d1.parent_group_id
    AND  d1.denorm_level > 0
   AND   d1.latest_relationship_flag = 'Y'
   AND   d1.group_id = usg.group_id
   AND   usg.usage = l_usage
   AND   n1.usage = l_usage
  ;

  l_insert_count := l_insert_count + SQL%ROWCOUNT ;

  COMMIT;


  -- group members -- not for specific user -- just preprocessed records
  -- so that view performs faster and takes less sharable memory. no security applied
  -- not for 1st time login. First time login group members not required since that
  -- part of LOV is never executed.
  -- For group member rows, no data is inserted in Id, user_id and resource_id columns
  -- since they are not for specific user.
  -- modified for ER 3263259 on 11/18/2003 - to just show the persons with member roles
  -- on 01/16/2004, above ER is reverted. Now manager and member roles will be displayed
  -- admin roles will be excluded.
  INSERT /*+ APPEND PARALLEL(a) NOLOGGING  */ INTO jtf_rs_dbi_denorm_res_groups a
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
		  active_grp_rel_only,
		  last_update_date,
		  last_updated_by,
		  usage )
  SELECT  Decode(x.mem_status,'I','----[ ','----')value,
          x.resource_id||'.'||x.group_id id_for_grp_mem, x.group_id current_id,
          x.group_id parent_id, to_number(100) denorm_level,
          'E-SELF-GROUP-MEMBERS' debug_column , jtf_rs_dbi_denorm_res_groups_s.NEXTVAL denorm_id
          ,x.resource_id grp_mem_resource_id, 'Y' mem_flag, x.mem_status
         ,l_sysdate, l_user_id
         ,'Y' active_grp_rel_only
         ,l_sysdate, l_user_id, x.usage
  FROM  (
  -- changed the select statement in order to fetch the member as well as manager role
  -- changed the select statement to get only 1 distinct row. If active role is available
  -- do not fetch the inactive role. If only inactive role is available, show that one.
  -- changed on 01/16/2004 for dbi 7.0
        SELECT /*+ use_hash(gm1 rrl1 rol1 usg1) PARALLEL(gm1) PARALLEL(rrl1) PARALLEL(rol1) PARALLEL(usg1)*/
               DISTINCT  gm1.resource_id, gm1.group_id
              , 'A' mem_status, usg1.usage
        FROM   jtf_rs_group_members gm1, jtf_rs_role_relations rrl1, jtf_rs_roles_b rol1
              ,jtf_rs_group_usages usg1
        WHERE  gm1.group_member_id = rrl1.role_resource_id
        AND    gm1.delete_flag = 'N'
        AND    rrl1.role_resource_type = 'RS_GROUP_MEMBER'
        AND    rrl1.delete_flag = 'N'
        AND    rrl1.role_id = rol1.role_id
        AND    'Y' IN (rol1.member_flag, rol1.manager_flag)
        AND    rrl1.active_flag = 'Y'
        AND    gm1.group_id = usg1.group_id
        AND    usg1.usage = l_usage
        UNION ALL
        SELECT /*+ use_hash(gm2 rrl2 rol2 usg2) PARALLEL(gm2) PARALLEL(rrl2) PARALLEL(rol2) PARALLEL(usg2) */
               DISTINCT gm2.resource_id, gm2.group_id
               , 'I' mem_status, usg2.usage
        FROM   jtf_rs_group_members gm2, jtf_rs_role_relations rrl2, jtf_rs_roles_b rol2
              ,jtf_rs_group_usages usg2
        WHERE  gm2.group_member_id = rrl2.role_resource_id
        AND    gm2.delete_flag = 'N'
        AND    rrl2.role_resource_type = 'RS_GROUP_MEMBER'
        AND    rrl2.delete_flag = 'N'
        AND    rrl2.role_id = rol2.role_id
        AND    'Y' IN (rol2.member_flag, rol2.manager_flag)
        AND    rrl2.active_flag IS NULL
        AND    gm2.group_id = usg2.group_id
        AND    usg2.usage = l_usage
        AND    NOT EXISTS ( -- to check if active role doesn't exist
                   SELECT /*+ use_hash(gm3 rrl3 rol3 usg3) PARALLEL(gm3) PARALLEL(rrl3) PARALLEL(rol3) PARALLEL(usg3)*/
				          '1'
                   FROM   jtf_rs_group_members gm3, jtf_rs_role_relations rrl3
				        , jtf_rs_roles_b rol3
                        , jtf_rs_group_usages usg3
                   WHERE  gm3.group_member_id = rrl3.role_resource_id
                   AND    gm3.delete_flag = 'N'
                   AND    rrl3.role_resource_type = 'RS_GROUP_MEMBER'
                   AND    rrl3.delete_flag = 'N'
                   AND    rrl3.role_id = rol3.role_id
                   AND    'Y' IN (rol3.member_flag, rol3.manager_flag)
                   AND    rrl3.active_flag = 'Y'
                   AND    gm3.resource_id = gm2.resource_id
                   AND    gm3.group_id    = gm2.group_id
                   AND    gm3.group_id    = usg3.group_id
                   AND    usg3.usage      = l_usage
                )
           ) x
   ;

  l_insert_count := l_insert_count + SQL%ROWCOUNT ;

  COMMIT;

  -- Member Login for DBI 7.1. new insert stmt created by nsinghai on 8-Oct-2004
  INSERT /*+ APPEND PARALLEL(a) NOLOGGING  */ INTO jtf_rs_dbi_denorm_res_groups a
         (VALUE,id, id_for_grp_mem , current_id , parent_id , denorm_level ,
		  START_DATE, end_date, resource_id,  user_id, grp_mem_resource_id,
		  debug_column, denorm_id, mem_flag, mem_status, creation_date, created_by,
		  active_grp_rel_only, last_update_date, last_updated_by, usage )
  SELECT  '   * ' VALUE, group_id id, resource_id||'.'||group_id id_for_grp_mem,
          TO_NUMBER(-7777) current_id, group_id parent_id, TO_NUMBER(0) denorm_level,
		  START_DATE , end_date, resource_id, user_id, resource_id grp_mem_resource_id,
		  '1-GROUP-MEMBER-LOGIN' debug_column ,jtf_rs_dbi_denorm_res_groups_s.NEXTVAL,
   	      'N' mem_flag , 'A' mem_status ,l_sysdate, l_user_id, 'Y' active_grp_rel_only
          ,l_sysdate, l_user_id, usage
  FROM (
    SELECT 	/*+ use_hash(gm rrl rol res usg) parallel(gm) parallel(rrl) parallel(rol) parallel(res) parallel(usg)*/
            gm.group_id group_id, res.resource_id resource_id,
 		    res.user_id user_id,
           	MIN(rrl.start_date_active) start_date,
           	MAX(nvl(rrl.end_date_active,TO_DATE('12/31/4712','MM/DD/RRRR'))) end_date,
           	usg.usage
    FROM    jtf_rs_group_members gm
           ,jtf_rs_role_relations rrl
           ,jtf_rs_roles_b rol
           ,jtf_rs_resource_extns_vl res
           ,jtf_rs_group_usages usg
    WHERE  gm.delete_flag = 'N'
    AND    gm.group_member_id = rrl.role_resource_id
    AND    rrl.role_resource_type = 'RS_GROUP_MEMBER'
    AND    rrl.delete_flag = 'N'
    AND    rrl.active_flag = 'Y'
    AND    rrl.role_id  = rol.role_id
    AND    rol.member_flag = 'Y'
    AND    NVL(rol.admin_flag,'N') = 'N'
    AND    NVL(rol.manager_flag,'N') = 'N'
    AND    NVL(rol.active_flag,'Y') = 'Y'
    AND    gm.resource_id = res.resource_id
    AND    res.user_id IS NOT NULL
    AND    gm.group_id = usg.group_id
    AND    usg.usage = l_usage
    GROUP BY usg.usage, gm.group_id, res.resource_id, res.user_id
  )
  ;

  l_insert_count := l_insert_count + SQL%ROWCOUNT ;

  COMMIT;

  EXECUTE IMMEDIATE 'ALTER TABLE '||l_table_owner||'.JTF_RS_DBI_DENORM_RES_GROUPS '||
           ' MODIFY PARTITION '||l_partition||' REBUILD UNUSABLE LOCAL INDEXES ';

   fnd_stats.gather_table_stats(ownname => l_table_owner, tabname => 'JTF_RS_DBI_DENORM_RES_GROUPS',
   percent=>5, degree=>bis_common_parameters.get_degree_of_parallelism, granularity=>'ALL',cascade=>TRUE);

  BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => TRUE ,
   p_count       => l_insert_count,
   p_period_to   => l_bis_date);

--  EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE=FALSE';

 EXCEPTION
   WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
     p_retcode := '2'; -- Error
     p_errbuf  := sqlerrm;
     BIS_COLLECTION_UTILITIES.Debug('Error in Update Group Hierarchy for usage:'||
	                                 p_usage||' : '||p_errbuf);

     BIS_COLLECTION_UTILITIES.wrapup(
       p_status      => FALSE ,
       p_message     => sqlerrm,
       p_count       => l_insert_count,
       p_period_to   => l_bis_date);

     -- dbms_output.put_line('Error : '||sqlcode||':'||sqlerrm);

  END populate_main;

/****************************************************************************
  This function is for providing a common method of fetching the group id
  for first time login pages. Instead of passing '-1111' to Sales Group
  Dimension LOV, product teams will call this function which will return
  them a valid group id. This group id will be used by product teams to
  query the data rather then querying data for dummy group '-1111'.
  Internally this function will query for '-1111' and then return the first
  record. This is for usage : 'SALES'

  Created By      nsinghai      03-Oct-2003
***************************************************************************/

   FUNCTION get_sg_id RETURN VARCHAR2 IS
   BEGIN

	 RETURN get_first_login_group_id('SALES','N');

   EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
  END get_sg_id;

/****************************************************************************
  This function is for providing a common method of fetching the group id
  for first time login pages. Instead of passing '-1111' to Group Hierarchy
  Dimension LOV, product teams will call this function which will return
  them a valid group id. This group id will be used by Field Service team to
  query the data rather then querying data for dummy group '-1111'.
  Internally this function will query for '-1111' and then return the first
  record. This is for Field Service Districts (Usage: 'FLD_SRV_DISTRICT').

  Created By      nsinghai      01-JUL-2004
***************************************************************************/

  FUNCTION get_fsg_id RETURN VARCHAR2 IS
   BEGIN

     RETURN get_first_login_group_id('FLD_SRV_DISTRICT','N');

   EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
  END get_fsg_id;

  /****************************************************************************
      This function is for providing a common method of fetching the group id
      for first time login pages. Instead of passing '-1111' to Sales Group
      Dimension LOV, product teams will call this function which will return
      them a valid group id. This group id will be used by product teams to
      query the data rather then querying data for dummy group '-1111'.
      Internally this function will query for '-1111' and then return the first
      record. This is for usage : 'SALES'

      "get_sg_id" returns first time login id only from managers and admin groups
	  for sales
      "get_sg_id_all_login" returns first time login id only from managers, admin
	  and member groups for sales

     Created By      nsinghai      08-Oct-2004
   ***************************************************************************/

  FUNCTION get_sg_id_all_login RETURN VARCHAR2 IS
   BEGIN

	 RETURN get_first_login_group_id('SALES','Y');

   EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
  END get_sg_id_all_login;

  /****************************************************************************
      This function is for providing a common method of fetching the group id
      for first time login pages. Instead of passing '-1111' to Sales Group
      Dimension LOV, product teams will call this function which will return
      them a valid group id. This group id will be used by product teams to
      query the data rather then querying data for dummy group '-1111'.
      Internally this function will query for '-1111' and then return the first
      record. This is for usage : 'FLD_SRV_DISTRICT'

      "get_fsg_id" returns first time login id only from managers and admin groups
	  for field service
      "get_fsg_id_all_login" returns first time login id only from managers, admin
	  and member groups for field service

     Created By      nsinghai      08-Oct-2004
   ***************************************************************************/

  FUNCTION get_fsg_id_all_login RETURN VARCHAR2 IS
   BEGIN

     RETURN get_first_login_group_id('FLD_SRV_DISTRICT','Y');

   EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
  END get_fsg_id_all_login;

 /***************************************************************************
  This function which will be called for getting first time login
  group from other functions like get_sg_id and get_fsg_id functions.
 ****************************************************************************/

  FUNCTION get_first_login_group_id(p_usage VARCHAR2, p_include_member_groups VARCHAR2)
  RETURN VARCHAR2 IS
    l_sg_id  VARCHAR2(100);
    l_usage  VARCHAR2(100);
    l_include_member_groups VARCHAR2(10);
  BEGIN
     l_usage := p_usage;
     l_include_member_groups := p_include_member_groups;

     IF (l_include_member_groups = 'N') THEN
       SELECT id
       INTO   l_sg_id
       FROM   (
             SELECT id, rank() over (order by value, id  nulls last) rnk
             FROM   jtf_rs_dbi_res_grp_vl
             WHERE  usage        = l_usage
             AND    current_id   = -1111
             AND    denorm_level = 0
            )
       WHERE rnk = 1;
     END IF;

     IF (l_include_member_groups = 'Y') THEN
       SELECT id
       INTO   l_sg_id
       FROM   (
             SELECT id, rank() over (order by current_id desc, value, id  nulls last) rnk
             FROM   jtf_rs_dbi_res_grp_vl
             WHERE  usage        = l_usage
             AND    current_id   IN  (-1111, -7777)
             AND    denorm_level = 0
            )
       WHERE rnk = 1;
     END IF;

     RETURN l_sg_id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_first_login_group_id;

END jtf_rs_dbi_conc_pub ; -- end package body

/
