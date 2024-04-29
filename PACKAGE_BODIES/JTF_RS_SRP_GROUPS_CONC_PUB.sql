--------------------------------------------------------
--  DDL for Package Body JTF_RS_SRP_GROUPS_CONC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_SRP_GROUPS_CONC_PUB" AS
/* $Header: jtfrsbbb.pls 120.0 2005/05/11 08:19:13 appldev noship $ */

  /****************************************************************************
   This is a concurrent program to populate the data in JTF_RS_SRP_GROUPS_INT
   and JTF_RS_SRP_GROUPS. This program will create primary groups for salesreps
   for date date range from 01/01/1900 to 12/31/4712. For a specific date there
   will be only one primary group for a salesrep.

   CREATED BY    nsinghai   14-AUG-2003
   MODIFIED BY   nsinghai   20-JAN-2004  ER 3378250 : Giving member role higher
                                         priority than manager. Not checking for
                                         Admin and lead roles any more.
                 nsinghai   06-MAY-2004  Bug 3615320 : Fetch only those rows whose
                                         start_date is less than or equal to end
                                         date
                 nsinghai   03-SEP-2004  Bug 3872750 : Added stages and salesrep_id
                                         for better informative error.
                 nsinghai   13-SEP-2004  Bug 3882194 - Change logic to make CP
                                         incremental on JTF_RS_SRP_GROUPS table
                 nsinghai   27-SEP-2004  Added logic to filter out -1 group_id
                                         record from defaulting logic if any other
                                         valid group is present even at lower level.
                 nsinghai   07-JAN-2005  added nvl conditions for org_id, since it is
                                         possible to have org_id as NULL in jtf_rs_salesreps
                                         table (Bug 4109716)
   ***************************************************************************/

PROCEDURE  populate_default_groups
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2)
  IS

  TYPE srp_grp_type IS RECORD
  (p_salesrep_id NUMBER,
   p_org_id NUMBER,
   p_resource_id NUMBER,
   p_user_id NUMBER,
   p_group_id NUMBER,
   p_start_date DATE,
   p_end_date DATE
   );

   TYPE srp_grp_tbl IS TABLE OF srp_grp_type INDEX BY BINARY_INTEGER;

   g_srp_grp_tab srp_grp_tbl;
   temp_srp_grp_tab srp_grp_tbl;

   l_inner_loop VARCHAR2(10) ;

   i INTEGER := 0;
   j INTEGER := 0;
   k INTEGER := 0;
   l INTEGER := 0;
   m INTEGER := 0;
   n INTEGER := 0;
   o INTEGER := 0;
   p INTEGER := 0;
   q INTEGER := 0;

   l_user_id NUMBER ;
   l_sysdate DATE   ;
   l_status                VARCHAR2(30);
   l_index_owner           VARCHAR2(30);
   l_table_owner           VARCHAR2(30);
   l_index_tblspace        VARCHAR2(60);
   l_index_exists          VARCHAR2(10);
   l_prev_start_date       DATE;
   l_prev_end_date         DATE;
   l_skip_row              VARCHAR2(10);
   l_overlap               VARCHAR2(10);
   l_deletion_occured      VARCHAR2(10);
   l_stage                 VARCHAR2(300);

   l_jtfu varchar2(60);
   l_jtfx varchar2(60);
   l_jtft varchar2(60);

  CURSOR c_outer IS
  SELECT salesrep_id, org_id
  FROM   jtf_rs_salesreps
  ;

  CURSOR c1 (ll_salesrep_id NUMBER, ll_org_id NUMBER )IS
  SELECT salesrep_id, org_id, resource_id, user_id, group_id, start_date, end_date
  FROM   jtf_rs_srp_groups_int
  WHERE  salesrep_id = ll_salesrep_id
  AND    nvl(org_id,-99)      = nvl(ll_org_id,-99)
  AND    start_date <= end_date
  ORDER BY denorm_count, role_type_priority, role_priority;

  CURSOR c_product_info IS
    SELECT i.tablespace, i.index_tablespace, u.oracle_username
    FROM   fnd_product_installations i, fnd_application a, fnd_oracle_userid u
    WHERE  a.application_short_name = 'JTF'
    AND    a.application_id = i.application_id
    AND    u.oracle_id = i.oracle_id;

  FUNCTION f_get_degree_of_parallelism RETURN NUMBER IS
    l_parallel NUMBER;
  BEGIN
	l_parallel := null;
    -- EDW : Degree of Parallelism-Source
	l_parallel := null;
	l_parallel := floor(fnd_profile.value('EDW_PARALLEL_SRC')); -- gets value of profile option

	  /* Set by the customer, return this value */

	  IF (l_parallel IS NOT NULL and l_parallel > 0) THEN
 		return l_parallel;
	  END IF;

	  /* Not set by customer, so query v$pq_sysstat */

	  BEGIN
 	    SELECT value INTO l_parallel
	    FROM v$pq_sysstat  WHERE trim(statistic) = 'Servers Idle';
  	  EXCEPTION WHEN no_data_found THEN
		l_parallel := 1;
	  END;

	  IF (l_parallel IS NULL) THEN
		l_parallel:=1;
	  END IF;

	  l_parallel := floor(l_parallel/2);
	  IF (l_parallel = 0) THEN
		l_parallel := 1;
	  END IF;

	  RETURN l_parallel;
  END f_get_degree_of_parallelism;

BEGIN

 -- putting initialization variable here because of GSCC warning File.Sql.35
 -- removed intialization of variables from declaration

 l_stage      := 'Stage=Initialize';

 l_inner_loop := 'N';
 l_user_id    := fnd_global.user_id;
 l_sysdate    := SYSDATE;
 l_skip_row   := 'N' ;
 l_overlap    := 'N' ;
 l_deletion_occured := 'N' ;

 retcode := '0' ;

 l_stage      := 'Stage=FETCH_SCHEMA_DETAILS';

  --EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE=TRUE';
  EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

  --fetch user name for JTF product
  OPEN  c_product_info;
  FETCH c_product_info INTO l_jtft,l_jtfx,l_jtfu;
  CLOSE c_product_info;

  -------- Check owner name for the tables and indexes.
  -- keep index information so that it is easy to create them back
  -- Check owner name for the tables and indexes.
  BEGIN
    SELECT owner, table_owner, tablespace_name
    INTO   l_index_owner, l_table_owner, l_index_tblspace
    FROM   ALL_INDEXES
    WHERE  TABLE_NAME = 'JTF_RS_SRP_GROUPS_INT'
    AND    index_name = 'JTF_RS_SRP_GROUPS_INT_N1'
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

  l_stage      := 'Stage=DROP_INDEX  '||l_index_owner||'.JTF_RS_SRP_GROUPS_INT_N1';

  --------- Drop Index before inserting into intermediate table ----------
  IF (l_index_exists = 'Y') THEN
    EXECUTE IMMEDIATE 'DROP INDEX '||l_index_owner||'.JTF_RS_SRP_GROUPS_INT_N1';
  END IF;

  -------------Insert into intermediate table ---------
  EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_index_owner||'.JTF_RS_SRP_GROUPS_INT';

  COMMIT;

  l_stage      := 'Stage=INSERT_IN_JTF_RS_SRP_GROUPS_INT_TABLE';

  INSERT INTO /*+ APPEND PARALLEL(sg1) NOLOGGING */ jtf_rs_srp_groups_int sg1
       (srp_groups_id, resource_id, salesrep_id, org_id, user_id,
        group_id, role_type_code, role_id, role_type_priority,
        role_priority, start_date, end_date, denorm_count,
        created_by, creation_date, last_updated_by, last_update_date )
  SELECT jtf_rs_srp_groups_stage_s.NEXTVAL srp_groups_id,
       x.resource_id, x.salesrep_id, x.org_id, x.user_id,
       x.group_id,
       x.role_type_code, x.role_id, x.role_type_priority, x.role_priority,
       x.start_date, x.end_date, x.denorm_count,
       l_user_id, sysdate, l_user_id, sysdate
  FROM (
    SELECT /*+ use_hash(rrl mem usg rol den res srp) PARALLEL(rrl)
             PARALLEL(mem) PARALLEL(usg) PARALLEL(rol) PARALLEL(den)
             PARALLEL(res) PARALLEL(srp) */
      mem.resource_id
     ,mem.group_id
     ,srp.salesrep_id
     ,srp.org_id
     ,res.user_id
     ,DECODE(rol.role_type_code,'SALES',1,2) role_type_priority
     --,DECODE('Y',rol.manager_flag,1,rol.admin_flag,2,rol.lead_flag,3,4)role_priority
     ,DECODE('Y',rol.member_flag,1,rol.manager_flag,2)role_priority
     ,rrl.start_date_active start_date
     ,nvl(rrl.end_date_active,TO_DATE('12/31/4712','MM/DD/RRRR')) end_date
     ,rrl.role_id
     ,rol.role_type_code
     ,COUNT(den.group_id) denorm_count
   FROM   jtf_rs_role_relations rrl
        ,jtf_rs_group_members mem
        ,jtf_rs_salesreps srp
        ,jtf_rs_group_usages usg
        ,jtf_rs_roles_b rol
        ,jtf_rs_groups_denorm den
        ,jtf_rs_resource_extns res
   WHERE  rrl.role_resource_type = 'RS_GROUP_MEMBER'
     AND  rrl.delete_flag        = 'N'
     AND  rrl.role_resource_id   = mem.group_member_id
     AND  mem.delete_flag        = 'N'
     AND  mem.group_id           <> -1
     AND  mem.resource_id        = srp.resource_id
     AND  mem.group_id           = usg.group_id
     AND  usg.usage              = 'SALES'
     AND  rrl.role_id            = rol.role_id
     AND  'Y' IN (rol.member_flag, rol.manager_flag)
     AND  mem.resource_id        = res.resource_id
     AND  mem.group_id           = den.group_id
     AND  (	rrl.start_date_active BETWEEN den.start_date_active AND
            nvl(den.end_date_active,TO_DATE('12/31/4712','MM/DD/RRRR'))
       OR
           den.start_date_active BETWEEN rrl.start_date_active AND
           nvl(rrl.end_date_active,TO_DATE('12/31/4712','MM/DD/RRRR'))
         )
   GROUP BY mem.resource_id, srp.salesrep_id, srp.org_id,
           res.user_id, mem.group_id, rrl.start_date_active,
     rrl.end_date_active, DECODE(rol.role_type_code,'SALES',1,2),
--     DECODE('Y',rol.manager_flag,1,rol.admin_flag,2,rol.lead_flag,3,4)
     DECODE('Y',rol.member_flag,1,rol.manager_flag,2)
    ,rrl.role_id, rol.role_type_code
  ) x ;

  COMMIT;

  l_stage      := 'Stage=INSERT_IN_JTF_RS_SRP_GROUPS_INT_TABLE_FOR_UNASSIGNED_GROUPS';

  INSERT INTO /*+ APPEND PARALLEL(sg1) NOLOGGING */ jtf_rs_srp_groups_int sg1
       (srp_groups_id, resource_id, salesrep_id, org_id, user_id,
        group_id, role_type_code, role_id, role_type_priority,
        role_priority, start_date, end_date, denorm_count,
        created_by, creation_date, last_updated_by, last_update_date )
  SELECT jtf_rs_srp_groups_stage_s.NEXTVAL srp_groups_id,
       x.resource_id, x.salesrep_id, x.org_id, x.user_id,
       x.group_id,
       x.role_type_code, x.role_id, x.role_type_priority, x.role_priority,
       x.start_date, x.end_date, x.denorm_count,
       l_user_id, sysdate, l_user_id, sysdate
  FROM (
      SELECT /*+ use_hash(srp res) PARALLEL(srp) PARALLEL(res) */
             srp.resource_id,
             srp.salesrep_id,
             srp.org_id,
             res.user_id,
             -1 group_id,
             'NONE' role_type_code,
             -1 role_id,
             9 role_type_priority,
             9 role_priority,
             TO_DATE('01/01/1900','MM/DD/RRRR') START_DATE,
             TO_DATE('12/31/4712','MM/DD/RRRR') END_DATE,
             99999999 denorm_count
      FROM
             jtf_rs_salesreps srp,
             jtf_rs_resource_extns res
      WHERE  srp.resource_id = res.resource_id
     ) x;

  COMMIT;

  l_stage      := 'Stage=CREATE_INDEX_ON_JTF_RS_SRP_GROUPS_INT_TABLE';

  -------------Create index and Analyze table on Intermediate table -------
  EXECUTE IMMEDIATE 'CREATE INDEX '||l_index_owner
             ||'.JTF_RS_SRP_GROUPS_INT_N1 ON '
             ||l_table_owner||'.JTF_RS_SRP_GROUPS_INT '
             ||' (salesrep_id, org_id, denorm_count, role_type_priority, role_priority) '
             ||' TABLESPACE '||l_index_tblspace
             ||' NOLOGGING PARALLEL (DEGREE '||f_get_degree_of_parallelism||' ) ';

  fnd_stats.gather_table_stats(ownname => l_table_owner, tabname => 'JTF_RS_SRP_GROUPS_INT',
  percent=>5, degree=>f_get_degree_of_parallelism, granularity=>'GLOBAL',cascade=>TRUE);

  -------------Truncate the Main table  ---------
  l_stage      := 'Stage=TRUNCATE_JTF_RS_SRP_GROUPS_STAGE_TABLE';

  EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_index_owner||'.JTF_RS_SRP_GROUPS_STAGE';

  COMMIT;

  ------------ Start the main logic here --------
  l_stage      := 'Stage=START_PLSQL_POPULATION_LOGIC';

  FOR c_get_salesrep_id IN c_outer
  LOOP

    l_stage      := 'Stage=INSIDE_PLSQL_OUTER_LOOP_FOR SALESREP_ID:'||c_get_salesrep_id.salesrep_id
                    ||':ORG_ID:'||c_get_salesrep_id.org_id;

    -- re-initialize i and dates
    i := 0;
    l_prev_start_date := NULL;
    l_prev_end_date   := NULL;
    ---------------------main for loop -----------------
    FOR c_rec IN c1 (c_get_salesrep_id.salesrep_id, c_get_salesrep_id.org_id)
    LOOP

      l_stage      := 'Stage=INSIDE_PLSQL_INNER_LOOP_FOR SALESREP_ID:'||c_get_salesrep_id.salesrep_id
                    ||':ORG_ID:'||c_get_salesrep_id.org_id;

      -- we should procees further only if the date range is different
      -- this will help in eliminating few rows and improve performance
      IF (l_prev_start_date IS NULL) THEN
        l_skip_row := 'N';
        l_prev_start_date := c_rec.START_DATE;
        l_prev_end_date := c_rec.END_DATE;
      ELSIF
        ((c_rec.START_DATE BETWEEN l_prev_start_date AND l_prev_end_date) AND
         (c_rec.END_DATE BETWEEN l_prev_start_date AND l_prev_end_date)) THEN
         l_skip_row := 'Y';
      ELSE
        l_skip_row := 'N';
        l_prev_start_date := c_rec.START_DATE;
        l_prev_end_date := c_rec.END_DATE;
      END IF;

      -------------------If i=0------------------------
      -- proceed only if l_skip_row = N
      IF (l_skip_row = 'N') THEN
        IF (i = 0) THEN
          g_srp_grp_tab(i).p_salesrep_id := c_rec.salesrep_id;
          g_srp_grp_tab(i).p_org_id := c_rec.org_id;
          g_srp_grp_tab(i).p_resource_id := c_rec.resource_id;
          g_srp_grp_tab(i).p_user_id := c_rec.user_id;
          g_srp_grp_tab(i).p_group_id := c_rec.group_id;
          g_srp_grp_tab(i).p_start_date := c_rec.start_date;
          g_srp_grp_tab(i).p_end_date := c_rec.end_date;
          -------------------else of If i=0------------------------
        ELSE
          -- loop through the plsql table to check the dates of each record
          ------------------For outer table looop-----------------------
          l_inner_loop := 'N';
          l_overlap    := 'N';
          l_deletion_occured := 'N' ;
          j := g_srp_grp_tab.FIRST;
          WHILE j IS NOT NULL
          LOOP
            -- if data existed in inner table
            IF (temp_srp_grp_tab.COUNT > 0) THEN
              l_inner_loop := 'Y' ;
              l := temp_srp_grp_tab.FIRST ;
              WHILE l IS NOT NULL
              LOOP
                IF ((temp_srp_grp_tab(l).p_start_date < g_srp_grp_tab(j).p_start_date) AND
                   (temp_srp_grp_tab(l).p_end_date BETWEEN g_srp_grp_tab(j).p_start_date AND g_srp_grp_tab(j).p_end_date))
                   THEN
                   temp_srp_grp_tab(l).p_end_date := g_srp_grp_tab(j).p_start_date -1;
                ELSIF
                   ((temp_srp_grp_tab(l).p_start_date BETWEEN g_srp_grp_tab(j).p_start_date AND g_srp_grp_tab(j).p_end_date)
                     AND
                    (temp_srp_grp_tab(l).p_end_date > g_srp_grp_tab(j).p_end_date)) THEN
                   temp_srp_grp_tab(l).p_start_date := g_srp_grp_tab(j).p_end_date +1;
                ELSIF
                   ((temp_srp_grp_tab(l).p_start_date < g_srp_grp_tab(j).p_start_date) AND
                    (temp_srp_grp_tab(l).p_end_date > g_srp_grp_tab(j).p_end_date)) THEN
                   -- first get temo_srp_grp_tab(l).p_end_date into new record
                   -- and then modify the end date in existing record
                   m := temp_srp_grp_tab.LAST + 1;
                   --insert the 2nd record for this breakup
                   temp_srp_grp_tab(m).p_salesrep_id := temp_srp_grp_tab(l).p_salesrep_id;
                   temp_srp_grp_tab(m).p_org_id := temp_srp_grp_tab(l).p_org_id;
                   temp_srp_grp_tab(m).p_resource_id := temp_srp_grp_tab(l).p_resource_id;
                   temp_srp_grp_tab(m).p_user_id := temp_srp_grp_tab(l).p_user_id;
                   temp_srp_grp_tab(m).p_group_id := temp_srp_grp_tab(l).p_group_id;
                   temp_srp_grp_tab(m).p_start_date := g_srp_grp_tab(j).p_end_date +1;
                   temp_srp_grp_tab(m).p_end_date := temp_srp_grp_tab(l).p_end_date;

                   -- modify existing record
                   temp_srp_grp_tab(l).p_end_date := g_srp_grp_tab(j).p_start_date -1;
                ELSIF
                   ((temp_srp_grp_tab(l).p_start_date BETWEEN g_srp_grp_tab(j).p_start_date AND g_srp_grp_tab(j).p_end_date)
                    AND
                   (temp_srp_grp_tab(l).p_end_date BETWEEN g_srp_grp_tab(j).p_start_date AND g_srp_grp_tab(j).p_end_date))
                  THEN
                  -- delete this row from the inner table
                  temp_srp_grp_tab.DELETE(l);
                  l_deletion_occured := 'Y' ;
                END IF; -- end of inner table date checks

              l := temp_srp_grp_tab.NEXT(l);
             END LOOP;
          ELSE
            l_inner_loop := 'N' ;
          END IF;

         -- do not go further if the inner loop record is deleted and now
         -- we do not have any row inside that inner that inner table
         -- i.e. further comparison is useless and we should not insert that record.
         IF ((temp_srp_grp_tab.COUNT = 0) AND (l_deletion_occured = 'Y')) THEN
           -- falsely set the variable so that it does not go inside at all
           l_inner_loop := 'Y';
           EXIT ;
         END IF;

         -- if no row was there in inner table, continue comparing dates with
         -- cursor dates
         IF  (l_inner_loop = 'N') THEN
           -- check if date overlaps
           IF  ((g_srp_grp_tab(j).p_start_date BETWEEN c_rec.start_date AND c_rec.end_date)
             OR (c_rec.start_date BETWEEN g_srp_grp_tab(j).p_start_date AND g_srp_grp_tab(j).p_end_date))
           THEN
             -- go deep
             --intialize the inner table counter
             l_overlap := 'Y';
             k := 0;
             IF ((c_rec.start_date < g_srp_grp_tab(j).p_start_date) AND
                (c_rec.end_date BETWEEN g_srp_grp_tab(j).p_start_date AND g_srp_grp_tab(j).p_end_date)) THEN
                temp_srp_grp_tab(k).p_salesrep_id := c_rec.salesrep_id;
                temp_srp_grp_tab(k).p_org_id := c_rec.org_id;
                temp_srp_grp_tab(k).p_resource_id := c_rec.resource_id;
                temp_srp_grp_tab(k).p_user_id := c_rec.user_id;
                temp_srp_grp_tab(k).p_group_id := c_rec.group_id;
                temp_srp_grp_tab(k).p_start_date := c_rec.start_date;
                temp_srp_grp_tab(k).p_end_date := g_srp_grp_tab(j).p_start_date -1;
              ELSIF
                ((c_rec.start_date BETWEEN g_srp_grp_tab(j).p_start_date AND g_srp_grp_tab(j).p_end_date) AND
                 (c_rec.end_date > g_srp_grp_tab(j).p_end_date)) THEN
                temp_srp_grp_tab(k).p_salesrep_id := c_rec.salesrep_id;
                temp_srp_grp_tab(k).p_org_id := c_rec.org_id;
                temp_srp_grp_tab(k).p_resource_id := c_rec.resource_id;
                temp_srp_grp_tab(k).p_user_id := c_rec.user_id;
                temp_srp_grp_tab(k).p_group_id := c_rec.group_id;
                temp_srp_grp_tab(k).p_start_date := g_srp_grp_tab(j).p_end_date +1;
                temp_srp_grp_tab(k).p_end_date := c_rec.end_date;
              ELSIF
                ((c_rec.start_date < g_srp_grp_tab(j).p_start_date) AND
                 (c_rec.end_date > g_srp_grp_tab(j).p_end_date)) THEN
                temp_srp_grp_tab(k).p_salesrep_id := c_rec.salesrep_id;
                temp_srp_grp_tab(k).p_org_id := c_rec.org_id;
                temp_srp_grp_tab(k).p_resource_id := c_rec.resource_id;
                temp_srp_grp_tab(k).p_user_id := c_rec.user_id;
                temp_srp_grp_tab(k).p_group_id := c_rec.group_id;
                temp_srp_grp_tab(k).p_start_date := c_rec.start_date;
                temp_srp_grp_tab(k).p_end_date := g_srp_grp_tab(j).p_start_date -1;

                k := k + 1;
                temp_srp_grp_tab(k).p_salesrep_id := c_rec.salesrep_id;
                temp_srp_grp_tab(k).p_org_id := c_rec.org_id;
                temp_srp_grp_tab(k).p_resource_id := c_rec.resource_id;
                temp_srp_grp_tab(k).p_user_id := c_rec.user_id;
                temp_srp_grp_tab(k).p_group_id := c_rec.group_id;
                temp_srp_grp_tab(k).p_start_date := g_srp_grp_tab(j).p_end_date +1;
                temp_srp_grp_tab(k).p_end_date := c_rec.end_date;
              ELSIF
                ((c_rec.start_date BETWEEN g_srp_grp_tab(j).p_start_date AND g_srp_grp_tab(j).p_end_date) AND
                (c_rec.end_date BETWEEN g_srp_grp_tab(j).p_start_date AND g_srp_grp_tab(j).p_end_date)) THEN
                 -- break from loop because we do not want to check further
                 -- for this condition
                 EXIT;
              END IF; -- end of outer table date checks

         ELSE -- doesn't overlap with any one
           l_overlap := 'N';
         END IF;

       END IF; -- l_inner_loop = 'N' check
     -------------------End of outer table loop------------------------
     j := g_srp_grp_tab.NEXT(j);
     END LOOP;

     -- If there was no overlap with any previous group, insert it
     IF (l_overlap = 'N') THEN
        g_srp_grp_tab(i).p_salesrep_id := c_rec.salesrep_id;
        g_srp_grp_tab(i).p_org_id := c_rec.org_id;
        g_srp_grp_tab(i).p_resource_id := c_rec.resource_id;
        g_srp_grp_tab(i).p_user_id := c_rec.user_id;
        g_srp_grp_tab(i).p_group_id := c_rec.group_id;
        g_srp_grp_tab(i).p_start_date := c_rec.start_date;
        g_srp_grp_tab(i).p_end_date := c_rec.end_date;
      END IF;

      -- move data from inner table to outer table and then delete inner table.
      IF (temp_srp_grp_tab.COUNT > 0) THEN
        n := g_srp_grp_tab.LAST;
        p := temp_srp_grp_tab.FIRST;

        WHILE p IS NOT NULL
        LOOP
          -- do only if start_date is before or eqal to end date
          IF (temp_srp_grp_tab(p).p_start_date <= temp_srp_grp_tab(p).p_end_date) THEN
            n := n + 1;
            g_srp_grp_tab(n).p_salesrep_id := temp_srp_grp_tab(p).p_salesrep_id;
            g_srp_grp_tab(n).p_org_id := temp_srp_grp_tab(p).p_org_id;
            g_srp_grp_tab(n).p_resource_id := temp_srp_grp_tab(p).p_resource_id;
            g_srp_grp_tab(n).p_user_id := temp_srp_grp_tab(p).p_user_id;
            g_srp_grp_tab(n).p_group_id := temp_srp_grp_tab(p).p_group_id;
            g_srp_grp_tab(n).p_start_date := temp_srp_grp_tab(p).p_start_date;
            g_srp_grp_tab(n).p_end_date := temp_srp_grp_tab(p).p_end_date;
          END IF;
          p := temp_srp_grp_tab.NEXT(p);
        END LOOP;

        temp_srp_grp_tab.DELETE;
      END IF;
     -------------------If i=0------------------------
     END IF;
    --------------End If l_skip_row = N check---------
    END IF;

    i :=  i + 1;
   ---------------------main for loop -----------------
   END LOOP;

   IF (g_srp_grp_tab.COUNT > 0) THEN

     o := g_srp_grp_tab.FIRST ;

     WHILE o IS NOT NULL
     LOOP
       INSERT INTO /*+ APPEND PARALLEL(sg1) NOLOGGING */ jtf_rs_srp_groups_stage sg1
                (srp_groups_id, resource_id, salesrep_id, org_id, user_id,
                 group_id, start_date, end_date,
                 created_by, creation_date, last_updated_by, last_update_date )
       VALUES (jtf_rs_srp_groups_stage_s.NEXTVAL, g_srp_grp_tab(o).p_resource_id,
                 g_srp_grp_tab(o).p_salesrep_id, g_srp_grp_tab(o).p_org_id,
                 g_srp_grp_tab(o).p_user_id, g_srp_grp_tab(o).p_group_id,
                 g_srp_grp_tab(o).p_start_date, g_srp_grp_tab(o).p_end_date,
                 l_user_id, sysdate, l_user_id, sysdate);

       o := g_srp_grp_tab.NEXT(o);
     END LOOP;

     -- delete the table for next set of salesrep id and org id
     g_srp_grp_tab.DELETE;
   END IF;
   COMMIT;

  END LOOP; -- end of c_outer cursor

  -- analyze Staging table
  l_stage := 'Stage=ANALYZING_JTF_RS_SRP_GROUPS_STAGE_TABLE';

  fnd_stats.gather_table_stats(ownname => l_table_owner, tabname => 'JTF_RS_SRP_GROUPS_STAGE',
  percent=>5, degree=>f_get_degree_of_parallelism, granularity=>'GLOBAL',cascade=>TRUE);

  ----------------------------------------
  -- Added by NSINGHAI on 13-Sep-2004 for Bug # 3882194 - to make CP Incremental

  -- Now compare data in recently refreshed table JTF_RS_SRP_GROUPS_STAGE (new) with
  -- previously populated table JTF_RS_SRP_GROUPS (old) (final incremental table)

  -- If there is some data in JTF_RS_SRP_GROUPS (old data) which does not exist in
  -- recently refreshed table JTF_RS_SRP_GROUPS_STAGE, it means it is STALE data and
  -- has to be DELETED from JTF_RS_SRP_GROUPS (final table)

  l_stage := 'Stage=DELETE_DATA_FROM_JTF_RS_SRP_GROUPS_TABLE';

  DELETE FROM jtf_rs_srp_groups
  WHERE (resource_id, salesrep_id, NVL(org_id,-99), NVL(user_id,-84), group_id, START_DATE, end_date) IN
  (
   SELECT resource_id, salesrep_id, NVL(org_id,-99), NVL(user_id,-84), group_id, START_DATE, end_date
   FROM   jtf_rs_srp_groups
   MINUS
   SELECT resource_id, salesrep_id, NVL(org_id,-99), NVL(user_id,-84), group_id, START_DATE, end_date
   FROM   jtf_rs_srp_groups_stage
  )  ;

  COMMIT;

  -- If there is some data in recently refreshed table JTF_RS_SRP_GROUPS_STAGE
  -- (new data) which does not exist in final table JTF_RS_SRP_GROUPS_STAGE, it
  -- means it is NEW data and has to be INSERTED in JTF_RS_SRP_GROUPS (final table)

  l_stage := 'Stage=INSERT_DATA_IN_JTF_RS_SRP_GROUPS_TABLE';

  INSERT INTO /*+ APPEND PARALLEL(sg1) NOLOGGING */ jtf_rs_srp_groups sg1
        (srp_groups_id, resource_id, salesrep_id, org_id, user_id,
         group_id, start_date, end_date,
         created_by, creation_date, last_updated_by, last_update_date )
  SELECT
      jtf_rs_srp_groups_s.NEXTVAL, resource_id, salesrep_id, org_id, user_id,
      group_id, start_date, end_date,
      l_user_id created_by, SYSDATE creation_date, l_user_id last_updated_by, SYSDATE
  FROM (
         SELECT resource_id, salesrep_id, org_id, user_id, group_id, START_DATE, end_date
         FROM jtf_rs_srp_groups_stage
         MINUS
         SELECT resource_id, salesrep_id, org_id, user_id, group_id, START_DATE, end_date
         FROM jtf_rs_srp_groups
       );

  COMMIT;

  -- analyze Staging table
  l_stage := 'Stage=ANALYZING_JTF_RS_SRP_GROUPS_TABLE';

  fnd_stats.gather_table_stats(ownname => l_table_owner, tabname => 'JTF_RS_SRP_GROUPS',
  percent=>5, degree=>f_get_degree_of_parallelism, granularity=>'GLOBAL',cascade=>TRUE);

  ----------------------------------------

  EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
  --EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE=FALSE';

  l_stage := 'Stage=Completed';
  errbuf := l_stage;

  EXCEPTION WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log, l_stage);
    fnd_file.put_line(fnd_file.log, sqlerrm);
    retcode := '2'; -- Error
    errbuf  := l_stage||' : ERROR : '||sqlerrm;
    --dbms_output.put_line(l_stage||': Error : '||SQLERRM);
  END populate_default_groups; -- end procedure

END jtf_rs_srp_groups_conc_pub; -- end package body

/
