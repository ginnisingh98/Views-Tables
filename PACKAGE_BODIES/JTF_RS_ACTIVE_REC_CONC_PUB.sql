--------------------------------------------------------
--  DDL for Package Body JTF_RS_ACTIVE_REC_CONC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_ACTIVE_REC_CONC_PUB" AS
/* $Header: jtfrsbab.pls 120.2.12010000.7 2009/02/06 11:50:08 rgokavar ship $ */

  /****************************************************************************
   This is a concurrent program to populate ACTIVE_FLAG and LATEST_RELATIONSSHIP_FLAG
   column in JTF_RS_GROUPS_DENORM and  ACTIVE_FLAG in JTF_RS_ROLE_RELATIONS table.
   This program will be used from concurrrent program "Maintain Current Groups and Roles".

   Create By       NSINGHAI   06-MAY-2003
   Modified By     NSINGHAI   19-DEC-2003  Added Latest_relationship_flag update
                                           statements for ER # 3013916
                   NSINGHAI   22-MAR-2004  Added new insert statement for self relationships
                                           for bug # 3522542
                   NSINGHAI   08-JUL-2004  Removed Histogram creation statements from
                                           this file and created seperate file jtfrsc29.sql
                                           for histogram creation (Perf Bug 3742472)
                   NSINGHAI   07-DEC-2004  Removed hints from 2 subqueries of Insert stmt (2nd)
                                           for performance reasons (Bug 3951752)
                   NSINGHAI   14-JAN-2005  Modifying hints after review of perf team(Bug 3951752)
                   NSINGHAI   20-JAN-2005  Modified exception handling to return ERROR (retcode=2)
                                           instead of WARNING (retcode=1) (Bug 4099782)
                   NSINGHAI   29-SEP-2005  Bug 4642145: removing APPEND from 2nd INSERT stmt of
                                           JTF_RS_GRP_DEN_LTST_REL_2_TMP table because
                                           of ORA-08176 error in GSI env. Doing it after
                                           confirming with APPS PERF team (29-SEP-2005)
                   RGOKAVAR   13-AUG-2008  Bug 6800249: Changing Insert statement into
                                           jtf_rs_grp_den_ltst_rel_1_tmp Table to Improve
                                           Performance.
                   RGOKAVAR   06-FEB-2009  Bug 8220580: Revert the changes in
                                           FND_STATS.GATHER_COLUMN_STATS, which are added
                                           in Bug7587760.


    Usage Note:  For table JTF_RS_GROUPS_DENORM, there are 2 columns populated
                 by this concurrent prog. If teams require only active relationships,
                 they should, go against ACTIVE_FLAG = 'Y' check. If teams wants
		 active groups as well as the last active relationship, they should
		 go against LATEST_RELATIONSHIP_FLAG = 'Y'
   ***************************************************************************/


-- stubbed out procedure because of Bug # 3074562
-- new procedure populate_active_flags will do exactly what this was doing
PROCEDURE  populate_active_flag
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2)
  IS
BEGIN
  NULL;
END;

-- created on 29-July-2003
-- new procedure to do exactly what populate_active_flag was doing
-- the concurrant program is JTFRSBAF and the executable is JTFRSBAF
PROCEDURE  populate_active_flags
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2)
  IS

   l_sysdate date ;
   l_update_count number;
   l_den_update_count number;
   l_role_update_count number;

   l_jtfu varchar2(60);
   l_jtfx varchar2(60);
   l_jtft varchar2(60);

   l_data_to_update VARCHAR2(10);

  CURSOR c_product_info IS
    SELECT i.tablespace, i.index_tablespace, u.oracle_username
    FROM   fnd_product_installations i, fnd_application a, fnd_oracle_userid u
    WHERE  a.application_short_name = 'JTF'
    AND    a.application_id = i.application_id
    AND    u.oracle_id = i.oracle_id;

BEGIN
   -- EXECUTE IMMEDIATE 'alter session set sql_trace=true';

   l_sysdate      := trunc(sysdate);
   l_update_count := 0;
   l_den_update_count := 0;
   l_role_update_count := 0;

   retcode := 0;

   --fetch user name for JTF product
   OPEN  c_product_info;
   FETCH c_product_info INTO l_jtft,l_jtfx,l_jtfu;
   CLOSE c_product_info;

    -- Following updates are on JTF_RS_GROUPS_DENORM table

    -- Update latest relationship flag to 'Y' in groups denorm
    -- for all rows which has active_flag = 'Y'
    -- needed for backward compatibility
    UPDATE /*+ PARALLEL(gd) */ jtf_rs_groups_denorm gd
    SET    gd.latest_relationship_flag = 'Y'
    WHERE  gd.active_flag = 'Y'
    AND    gd.latest_relationship_flag IS NULL
    ;

    l_den_update_count := SQL%ROWCOUNT ;

    COMMIT;

    -- Update active_flag for new grp relationships in groups denorm
    -- if a group is active, latest_relationship_flag is active
    UPDATE /*+ PARALLEL(gd) */ jtf_rs_groups_denorm gd
    SET    gd.active_flag = 'Y'
           ,gd.latest_relationship_flag = 'Y'
    WHERE  l_sysdate BETWEEN gd.start_date_active
           AND NVL(gd.end_date_active, l_sysdate + 1)
    AND    gd.active_flag IS NULL
    ;

    l_update_count := SQL%ROWCOUNT ;
    l_den_update_count := l_den_update_count + SQL%ROWCOUNT ;

    COMMIT;

    -- update inactive group relations to null. Also update latest relationsip
    -- to null. We will make them 'Y' for appropriate groups in next update stmt
    UPDATE /*+ PARALLEL(gd) */ jtf_rs_groups_denorm gd
    SET    gd.active_flag = NULL
           ,gd.latest_relationship_flag = NULL
    WHERE  l_sysdate NOT BETWEEN gd.start_date_active
           AND NVL(gd.end_date_active, l_sysdate + 1)
    AND    gd.active_flag = 'Y'
    ;

    l_den_update_count := l_den_update_count + SQL%ROWCOUNT ;

    fnd_message.set_name('JTF', 'JTF_RS_ACTIVE_TO_INACT_COUNT');
    fnd_message.set_token('P_TABLE_NAME', 'JTF_RS_GROUPS_DENORM');
    fnd_message.set_token('P_ROWCOUNT', TO_CHAR(SQL%ROWCOUNT));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log,1);

    COMMIT;

    -- now update the latest relationship flag for group relations which are inactive
    -- and do not have any parent group attached to it but in past were a part of
    -- some group hierarchy.

    -- this query gives all those groups (and their last parent group)
    -- who do not have active parent groups now. But had it in past.

    -- before that truncate the table since it has unique index
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_jtfu||'.JTF_RS_GRP_DEN_LTST_REL_1_TMP';
    --DELETE FROM JTF_RS_GRP_DEN_LTST_REL_1_TMP;

    -- Insert data into 1st temporary table (session based)
    INSERT /*+ APPEND PARALLEL(a) NOLOGGING  */ INTO jtf_rs_grp_den_ltst_rel_1_tmp a
         (child_group_id, parent_group_id, start_date_active, end_date_active)
     select  child_group_id, parent_group_id, start_date_active,  end_date_active from (
     SELECT /*+ parallel(grp1) */
            grp1.group_id child_group_id, grp1.related_group_id parent_group_id,
            grp1.start_date_active start_date_active, grp1.end_date_active end_date_active,
            MAX(end_date_active) OVER (partition by GROUP_ID,DELETE_FLAG) max_end_date
     FROM   jtf_rs_grp_relations grp1
     WHERE  grp1.end_date_active <= l_sysdate -- if it is null it is OK
     AND    grp1.delete_flag = 'N'
     and     grp1.group_id NOT IN (
             -- check if they have any other parent
             SELECT /*+ hash_aj parallel(grp2) */ grp2.group_id
             FROM   jtf_rs_grp_relations grp2
             WHERE  NVL(grp2.end_date_active, l_sysdate) >= l_sysdate
             AND    grp2.delete_flag = 'N'
             )
)
where end_date_active = max_end_date ;

     COMMIT;

     -- Insert data into 2nd temporary table (session based)
     -- these are groups which are hanging by themself without any parent.
     -- so it becomes difficult to rollup their cost. So we need to find
     -- the last group to which they reported.

     -- before that truncate the table since it has unique index
     EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_jtfu||'.JTF_RS_GRP_DEN_LTST_REL_2_TMP';
     -- DELETE FROM JTF_RS_GRP_DEN_LTST_REL_2_TMP;

     INSERT /*+ APPEND PARALLEL(a) NOLOGGING  */ INTO jtf_rs_grp_den_ltst_rel_2_tmp a
         (denorm_grp_id)
       SELECT /*+  use_hash(x den2 den3) PARALLEL(x) PARALLEL(den2) PARALLEL(den3)*/
              distinct den3.denorm_grp_id
       FROM
              jtf_rs_grp_den_ltst_rel_1_tmp x
             ,jtf_rs_groups_denorm den2 -- fetch all children of x.child_group_id
             ,jtf_rs_groups_denorm den3 -- fetch all parent of den2.group_id
       WHERE  den2.parent_group_id = x.child_group_id
       AND   (
                x.start_date_active BETWEEN den2.start_date_active
                AND NVL(den2.end_date_active,TO_DATE('12/31/4712','MM/DD/RRRR'))
            OR
	        den2.start_date_active  BETWEEN x.start_date_active AND x.end_date_active
              )
       AND    den3.group_id = den2.group_id
       AND    (
                 x.start_date_active BETWEEN den3.start_date_active
                 AND NVL(den3.end_date_active,TO_DATE('12/31/4712','MM/DD/RRRR'))
             OR
	         den3.start_date_active  BETWEEN x.start_date_active AND x.end_date_active
              )
       AND    den3.latest_relationship_flag IS NULL
       AND    NOT EXISTS ( -- check if child groups have any other active parent
                           -- apart from existing active parent in hierarchy in consideration
                          SELECT /*+ use_hash(grp1) PARALLEL(grp1) */ '1'
                          FROM   jtf_rs_grp_relations grp1
                          WHERE  grp1.start_date_active <= l_sysdate
                          AND    NVL(grp1.end_date_active, TO_DATE('12/31/4712','MM/DD/RRRR')) >  x.end_date_active
                          AND    grp1.delete_flag = 'N'
                          AND    grp1.group_id = den3.group_id
                          AND    grp1.related_group_id <> den3.actual_parent_id
                         )
       AND NOT EXISTS ( -- if anywhere on top, same parent is appearing twice, we want only the
                        -- latest path to have latest relationship_flag = 'Y'
                        -- for ex. A->B->C->D, for later date range, if the hierarchy is
                        -- A->B->D, we should not fetch rows A-D for old relation.
	                   SELECT /*+ full(den4) parallel(den4) */ '1'
			   FROM   jtf_rs_groups_denorm den4
                           WHERE  den4.group_id = den3.group_id
                           AND    den4.parent_group_id = den3.parent_group_id
                           AND    den4.START_DATE_active > den3.start_date_active
                      )
       AND  NOT EXISTS (-- only 1 value should be valid for each denorm level
                      SELECT  /*+ full(den5) parallel(den5) */ '1'
                      FROM    jtf_rs_groups_denorm den5
                      WHERE   den5.group_id = den3.group_id
                      AND     den5.denorm_level = den3.denorm_level
                      AND     den5.denorm_grp_id <> den3.denorm_grp_id
                      AND     den5.start_date_active > den3.start_date_active
                     )
      ;

    COMMIT;

    -- for self groups, we need to keep latest relationship flag = 'Y', even
    -- for end dated groups. It is because a group will always have latest relationship
    -- with itself. This is for bug 3522542. Added by nsinghai on 03/22/2004.
    -- there is alternate way of directly updating groups denorm table, but performance wise
    -- it seems doing 1 insert and 1 update is faster than doing 2 updates.

    -- Bug 4642145: removing APPEND from INSERT stmt because of ORA-08176 error in GSI env.
    -- doing it after confirming with APPS PERF team (29-SEP-2005)

    INSERT /*+ PARALLEL(a) NOLOGGING  */ INTO jtf_rs_grp_den_ltst_rel_2_tmp a
           (a.denorm_grp_id)
    SELECT /*+ PARALLEL(den) */
           den.denorm_grp_id
    FROM   jtf_rs_groups_denorm den
    WHERE  den.denorm_level = 0
    AND    den.latest_relationship_flag IS NULL
    AND    NOT EXISTS (SELECT 1 FROM jtf_rs_grp_den_ltst_rel_2_tmp tmp
                       WHERE tmp.denorm_grp_id = den.denorm_grp_id)
    ;

    COMMIT;

    -- check if there is any data to be updated
    BEGIN
      SELECT 'Y'
      INTO   l_data_to_update
      FROM   jtf_rs_grp_den_ltst_rel_2_tmp
      WHERE  ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN NULL;
    END;

    -- commenting out code on 02/18/2004 because 8i does not support gathering stats
    -- on Temporary Tables.
    --FND_STATS.GATHER_TABLE_STATS(ownname=>'JTF'
    --                           ,tabname=>'JTF_RS_GRP_DEN_LTST_REL_2_TMP'
    --                           );

    -- do the real update of table if anything is there to be updated
    -- have put this check to avoid unnecessary update operation improve performance.
    IF (l_data_to_update IS NOT NULL) THEN

      UPDATE ( SELECT /*+ PARALLEL(gd) PARALLEL(x) */ gd.latest_relationship_flag
               FROM  jtf_rs_groups_denorm gd, jtf_rs_grp_den_ltst_rel_2_tmp x
               WHERE x.denorm_grp_id = gd.denorm_grp_id
             )
      SET    latest_relationship_flag = 'Y'
      ;

      l_update_count := l_update_count + SQL%ROWCOUNT ;
      l_den_update_count := l_den_update_count + SQL%ROWCOUNT ;

    END IF;

    fnd_message.set_name('JTF', 'JTF_RS_INACT_TO_ACTIVE_COUNT');
    fnd_message.set_token('P_TABLE_NAME', 'JTF_RS_GROUPS_DENORM');
    fnd_message.set_token('P_ROWCOUNT', TO_CHAR(l_update_count));
    fnd_file.put_line(fnd_file.LOG, fnd_message.get);
    fnd_file.new_line(fnd_file.LOG,1);

    COMMIT;

    ---------------------------------------------------------
    -- from here it is active_flag update for role_relations.
    UPDATE jtf_rs_role_relations
    SET    active_flag = NULL
    WHERE  delete_flag = 'Y'
    AND    active_flag = 'Y'
    ;

    -- l_update_count is reinitialized here with another value
    l_update_count := SQL%ROWCOUNT ;
    l_role_update_count := SQL%ROWCOUNT ;

    COMMIT;

    UPDATE jtf_rs_role_relations
    SET    active_flag = NULL
    WHERE  l_sysdate NOT BETWEEN start_date_active
           AND NVL(end_date_active, l_sysdate + 1)
    AND    delete_flag = 'N'
    AND    active_flag = 'Y'
    ;

    l_update_count := l_update_count + SQL%ROWCOUNT ;
    l_role_update_count := l_role_update_count + SQL%ROWCOUNT ;

    fnd_message.set_name('JTF', 'JTF_RS_ACTIVE_TO_INACT_COUNT');
    fnd_message.set_token('P_TABLE_NAME', 'JTF_RS_ROLE_RELATIONS');
    fnd_message.set_token('P_ROWCOUNT', to_char(l_update_count));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log,1);

    COMMIT;

    UPDATE jtf_rs_role_relations
    SET    active_flag = 'Y'
    WHERE  l_sysdate BETWEEN start_date_active
           AND NVL(end_date_active, l_sysdate + 1)
    AND    delete_flag = 'N'
    AND    active_flag IS NULL
    ;

    l_role_update_count := l_role_update_count + SQL%ROWCOUNT ;

    fnd_message.set_name('JTF', 'JTF_RS_INACT_TO_ACTIVE_COUNT');
    fnd_message.set_token('P_TABLE_NAME', 'JTF_RS_ROLE_RELATIONS');
    fnd_message.set_token('P_ROWCOUNT', to_char(SQL%ROWCOUNT));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log,1);

    COMMIT;

   /* Following lines are add for the performance bug # 3119586 */
   /* This is for Histogram stats updation */

   /* Commented out stats gathering on TABLE on 28-MAR-2005 for Bug # 4253821
      Instead of gathering stats on tables, will do it directly for column,
      so that it performs faster, that too only if columns are updated.
	  As per perf team guidelines "percent" should be 10% */

   --FND_STATS.GATHER_TABLE_STATS(ownname=> l_jtfu
   --                            ,tabname=>'JTF_RS_GROUPS_DENORM'
   --                            );

   --FND_STATS.GATHER_TABLE_STATS(ownname=> l_jtfu
   --                            ,tabname=>'JTF_RS_ROLE_RELATIONS'
   --                            );

   IF (l_den_update_count > 0) THEN

/*     FND_STATS.GATHER_COLUMN_STATS(ownname => l_jtfu,
                                 tabname   => 'JTF_RS_GROUPS_DENORM',
                                 colname   => 'LATEST_RELATIONSHIP_FLAG',
                                 percent   => 10,
                                 degree => null,
                                 hsize => null,
                                 backup_flag => null,
                                 partname => null,
                                 hmode => 'FULL'
                                 );
*/
       FND_STATS.GATHER_COLUMN_STATS(ownname => l_jtfu,
                                 tabname   => 'JTF_RS_GROUPS_DENORM',
                                 colname   => 'LATEST_RELATIONSHIP_FLAG',
                                 percent   => 10
                                 );
 END IF;

   IF (l_role_update_count > 0) THEN
/*    FND_STATS.GATHER_COLUMN_STATS(ownname => l_jtfu,
                                 tabname   => 'JTF_RS_ROLE_RELATIONS',
                                 colname   => 'ACTIVE_FLAG',
                                 percent   => 10,
                                 degree => null,
                                 hsize => null,
                                 backup_flag => null,
                                 partname => null,
                                 hmode => 'FULL'
                                 );
*/
       FND_STATS.GATHER_COLUMN_STATS(ownname => l_jtfu,
                                 tabname   => 'JTF_RS_ROLE_RELATIONS',
                                 colname   => 'ACTIVE_FLAG',
                                 percent   => 10
                                 );
   END IF;

   --EXECUTE IMMEDIATE 'alter session set sql_trace=false';

 EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK;
     fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
     -- Even though Error return warning using retcode = 1
     -- because we want other programs in request set to continue.
     --retcode := 1;
     -- Changed on 20-Jan-2005 for Bug 4099782 to return Error instead of Warning
     retcode := 2;
     errbuf  := sqlerrm;
     --dbms_output.put_line('Error : '||sqlcode||':'||sqlerrm);

  END populate_active_flags;
END jtf_rs_active_rec_conc_pub ; -- end package body

/
