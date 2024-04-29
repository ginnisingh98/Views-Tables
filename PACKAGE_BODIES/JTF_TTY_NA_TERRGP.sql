--------------------------------------------------------
--  DDL for Package Body JTF_TTY_NA_TERRGP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_NA_TERRGP" AS
/* $Header: jtfttgpb.pls 120.6 2006/07/07 20:55:51 mhtran ship $ */
--    Start of Comments
--    PURPOSE
--      Custom Assignment API
--
--    NOTES
--      ORACLE INTERNAL USE ONLY: NOT for customer use
--
--    HISTORY
--      03/18/02    SGKUMAR  Created
--      03/20/02    SGKUMAR  Created procedure insert_qualifiers
--      03/20/02    SGKUMAR  Created procedure set_winners
--      12/30/02    sbehera  set the assignment_flag='N' at the create time
--      01/06/03    JDOCHERT FIX FOR BUG#2735965
--      01/06/03    JDOCHERT FIX FOR BUG#2736765
--      01/08/03    JDOCHERT FIX FOR BUG#2741455
--      01/23/03    SGKUMAR FIX FOR BUG#2764268 (create_tgp_account modified)
--      02/27/03    SGKUMAR for new tg named account, setting assigned_to_direct_flag 'N"
--      04/01/03    SGKUMAR FIX FOR BUG#2872451 (assign_account modified)
--                          checking for terr gp acct for the owner
--      04/02/03    SGKUMAR FIX FOR BUG#2870683 (create_tgp_named_acct modified)
--                          Performance Fix. (count(*) removed)
--      04/07/03    SGKUMAR FIX FOR BUG#2821900 (check_hierachy added)
--      07/08/03    SGKUMAR Create procedure log_event
--                          for auditing.Modified delete_terrgp to invoke it
--      07/14/03    SGKUMAR modified sum_rm_bin procedure to not use
--                          the denorm table. Also removed code from other proce
--                          dures not to summarize acct sum table and touch deno
--                          rm table.
--      10/21/03    SGKUMAR Modified sum_rm_bin procedure to count the number
--                          of accounts by group also (added narsc.rsc_group_id
 --                          = repdn.group_id) and also to get sales hierarchy
--                         by group not just by resource.
--      01/15/04    SGKUMAR Modified sum_rm_bin procedure to count the number
--                          of accounts for a resource who is a manager and a
--                          rep of the same group or manager of a group and a
--                          member in the parent group
--    End of Comments
--    End of Comments
----


FUNCTION get_site_type_code( p_party_id NUMBER ) RETURN VARCHAR2
IS
   l_site_type_code  VARCHAR2(30);
   l_chk_done        VARCHAR2(1) := 'N' ;

BEGIN

    hz_common_pub.disable_cont_source_security;

   -- check for global ultimate

    BEGIN

      SELECT 'Y'
        INTO l_chk_done
        FROM DUAL
       WHERE EXISTS ( SELECT 'Y'
                     FROM hz_relationships hzr
                    WHERE hzr.subject_table_name = 'HZ_PARTIES'
                      AND hzr.object_table_name = 'HZ_PARTIES'
                      AND hzr.relationship_type = 'GLOBAL_ULTIMATE'
                      AND hzr.relationship_code = 'GLOBAL_ULTIMATE_OF'
                      AND hzr.status = 'A'
                      AND SYSDATE BETWEEN hzr.start_date AND NVL(hzr.end_date, SYSDATE)
                      AND hzr.subject_id = p_party_id );
    EXCEPTION
           WHEN NO_DATA_FOUND  THEN NULL;
    END;

    IF l_chk_done = 'Y'
    THEN
        l_site_type_code := 'GU' ;
        RETURN l_site_type_code;
    END IF;

    -- check for domestic ultimate

    BEGIN
        SELECT 'Y'
          INTO l_chk_done
          FROM DUAL
         WHERE EXISTS ( SELECT 'Y'
                     FROM hz_relationships hzr
                    WHERE hzr.subject_table_name = 'HZ_PARTIES'
                      AND hzr.object_table_name = 'HZ_PARTIES'
                      AND hzr.relationship_type = 'DOMESTIC_ULTIMATE'
                      AND hzr.relationship_code = 'DOMESTIC_ULTIMATE_OF'
                      AND hzr.status = 'A'
                      AND SYSDATE BETWEEN hzr.start_date AND NVL(hzr.end_date, SYSDATE)
                      AND hzr.subject_id = p_party_id );
    EXCEPTION
           WHEN NO_DATA_FOUND  THEN NULL;
    END;

    IF l_chk_done = 'Y'
    THEN
        l_site_type_code := 'DU' ;
        RETURN l_site_type_code;
    END IF;

    BEGIN

      SELECT lkp.lookup_code
        INTO l_site_type_code
        FROM fnd_lookups lkp,
             hz_parties hzp
       WHERE lkp.lookup_type = 'JTF_TTY_SITE_TYPE_CODE'
         AND hzp.hq_branch_ind = lkp.lookup_code
         AND hzp.party_id = p_party_id;


     EXCEPTION
         WHEN NO_DATA_FOUND THEN
              l_site_type_code := 'UN';

     END;

     RETURN( l_site_type_code);

EXCEPTION

   WHEN OTHERS THEN
        NULL;
        --dbms_output.put_line( substr(sqlerrm, 1, 200) );

END get_site_type_code;

PROCEDURE get_site_type(p_party_id IN NUMBER,
                             x_party_type OUT NOCOPY VARCHAR2)
AS
 site_type_code VARCHAR2(30);
BEGIN

  site_type_code := get_site_type_code(p_party_id);

  SELECT lkp.meaning
  INTO   x_party_type
  FROM   fnd_lookups lkp
  WHERE  lkp.lookup_type = 'JTF_TTY_SITE_TYPE_CODE'
  AND    lkp.lookup_code = site_type_code;

--
-- 01/06/03: JDOCHERT: FIX FOR BUG#2735965
--
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;

END get_site_type;


/* This procedure accepts a string of Ids and populates a pl/sql table with the Ids.
*/
PROCEDURE buildTable(p_id_str    IN VARCHAR2,
                     x_id_table OUT NOCOPY jtf_terr_number_list)
IS
  l_start integer;
  idx     integer;
  foundStrPos  integer;
  l_err_msg VARCHAR2(2000);
BEGIN
    l_start:=1;
    foundStrPos:=1;
    idx:=1;

    x_id_table := jtf_terr_number_list();
    WHILE (foundStrPos>0)
    LOOP
       foundStrPos := INSTR(p_id_str,',', l_start);
       IF foundStrPos >0 THEN
          x_id_table.extend();
          x_id_table(idx) := to_number(substr(p_id_str, l_start, (foundStrPos-l_start)));
          idx := idx + 1;
          l_start :=foundStrPos+1;
       END IF;
    END LOOP;
   x_id_table.extend();
   x_id_table(idx) := to_number(substr(p_id_str, l_start));

EXCEPTION
  WHEN OTHERS THEN
       l_err_msg := SQLCODE || ' : ' || substr(SQLERRM, 1, 1950);
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                   'jtf.plsql.JTF_TTY_NA_TERRGP.buildTable',
                    l_err_msg);
    END IF;
    RAISE;
END buildTable;


PROCEDURE delete_bulk_TGA(p_tga_id_str     IN VARCHAR2,
                          p_terr_gp_id_str IN VARCHAR2,
                          p_named_acct_id_str IN VARCHAR2,
                          p_change_type    IN VARCHAR2,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2)
IS
  head Number ;
  tail Number ;
  i    Number ;
  idx  Number ;

  l_terrGrpId_tbl jtf_terr_number_list;
  l_grpAcctId_tbl jtf_terr_number_list;
  l_acctId_tbl    jtf_terr_number_list;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTF_TTY_NA_TERRGP.delete_bulk_TGA',
                   'Start of the procedure JTF_TTY_NA_TERRGP.delete_bulk_TGA');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_terrGrpId_tbl := jtf_terr_number_list();
  l_grpAcctId_tbl := jtf_terr_number_list();
  l_acctId_tbl   := jtf_terr_number_list();


  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTF_TTY_NA_TERRGP.delete_bulk_TGA',
                   'Building PL/SQL tables from Input Strings');
  END IF;

  buildTable(p_tga_id_str, l_grpAcctId_tbl);
  buildTable(p_terr_gp_id_str, l_terrGrpId_tbl);
  buildTable(p_named_acct_id_str, l_acctId_tbl);

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTF_TTY_NA_TERRGP.delete_bulk_TGA',
                   'Deleting from JTF_TTY... tables');
  END IF;

   -- Delete Named Account Resources
   FORALL idx in l_grpAcctId_tbl.FIRST .. l_grpAcctId_tbl.LAST
     DELETE from jtf_tty_named_acct_rsc j WHERE j.TERR_GROUP_ACCOUNT_ID = l_grpAcctId_tbl(idx);

   -- Delete Terr Group Accounts
   FORALL idx in l_grpAcctId_tbl.FIRST .. l_grpAcctId_tbl.LAST
     DELETE from JTF_TTY_TERR_GRP_ACCTS j WHERE j.TERR_GROUP_ACCOUNT_ID = l_grpAcctId_tbl(idx);

   -- Delete Named Accounts
  FORALL idx in l_acctId_tbl.FIRST .. l_acctId_tbl.LAST
     DELETE from JTF_TTY_NAMED_ACCTS A
     WHERE  A.named_account_id = l_acctId_tbl(idx)
       AND  NOT EXISTS
                 (SELECT 'Y'
                    FROM JTF_TTY_TERR_GRP_ACCTS tga
                   WHERE tga.named_account_id = A.named_account_id);

   -- Delete Named Account Qual Maps
   FORALL idx in l_acctId_tbl.FIRST .. l_acctId_tbl.LAST
   DELETE from JTF_TTY_ACCT_QUAL_MAPS AQM
    WHERE  AQM.NAMED_ACCOUNT_ID =  l_acctId_tbl(idx)
      AND  NOT EXISTS ( SELECT 'x'
                          FROM JTF_TTY_NAMED_ACCTS a
                         WHERE a.named_account_id = AQM.named_account_id);


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTF_TTY_NA_TERRGP.delete_bulk_TGA',
                   'Calling procedure JTF_TTY_GEN_TERR_PVT.delete_bulk_TGA');
  END IF;

   -- Deleting Territories data from the JTF_TERR.. tables
    JTF_TTY_GEN_TERR_PVT.delete_bulk_TGA(l_terrGrpId_tbl,
                                              l_grpAcctId_tbl,
                                              p_change_type,
                                              x_return_status,
                                              x_msg_count,
                                              x_msg_data );


  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    -- debug message
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTF_TTY_NA_TERRGP.delete_bulk_TGA',
                     'JTF_TTY_GEN_TERR_PVT.delete_bulk_TGA API has failed');
    END IF;

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTF_TTY_NA_TERRGP.delete_bulk_TGA',
                   'Returning from JTF_TTY_GEN_TERR_PVT.delete_bulk_TGA');
  END IF;

  COMMIT;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTF_TTY_NA_TERRGP.delete_bulk_TGA',
                   'End of the procedure JTF_TTY_NA_TERRGP.delete_bulk_TGA');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     NULL;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTF_TTY_NA_TERRGP.delete_bulk_TGA.OTHERS',
                     substr(x_msg_data, 1, 4000));
    END IF;

END delete_bulk_TGA;

PROCEDURE delete_terrgp(p_terr_gp_id IN NUMBER)
AS
 p_user_id NUMBER;
BEGIN

   p_user_id := fnd_global.user_id;
   /* delete from the named acct sum only for affect resources */
   /*
   DELETE from jtf_tty_rsc_acct_summ j
   WHERE j.RESOURCE_ID in (SELECT RESOURCE_ID
              from jtf_tty_acct_rsc_dn j, jtf_tty_terr_grp_accts tga1
              WHERE j.TERR_GROUP_ACCOUNT_ID = tga1.TERR_GROUP_ACCOUNT_ID
              AND   tga1.TERR_GROUP_ID = p_terr_gp_id)
   AND j.RSC_GROUP_ID in (SELECT RSC_GROUP_ID
              from jtf_tty_acct_rsc_dn j, jtf_tty_terr_grp_accts tga2
              WHERE j.TERR_GROUP_ACCOUNT_ID = tga2.TERR_GROUP_ACCOUNT_ID
              AND   tga2.TERR_GROUP_ID = p_terr_gp_id);
  */
  /* sum the rsc acct sum table for the deletes resources only */
  /* and for na's for different terr gp from the deleted one */
  /*
  insert into jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
   (select jtf_tty_rsc_acct_summ_s.nextval,
           1,
           ilv.RESOURCE_ID,
           ilv.RSC_GROUP_ID,
           'RS_EMPLOYEE',
           ilv.site_type_code,
           ilv.num_accts,
           p_user_id,
           sysdate,
           p_user_id,
           sysdate
      FROM
           (select narsc.RESOURCE_ID,
                   narsc.RSC_GROUP_ID,
                   'RS_EMPLOYEE',
                    na.site_type_code,
                    count(na.NAMED_ACCOUNT_ID) num_accts
            from    jtf_tty_named_accts na, jtf_tty_acct_rsc_dn narsc,
                    jtf_tty_terr_grp_accts tga
            where   na.named_account_id = tga.named_account_id
            and     narsc.resource_id in
                   (SELECT RESOURCE_ID
                    from jtf_tty_acct_rsc_dn j, jtf_tty_terr_grp_accts tga1
                    WHERE j.TERR_GROUP_ACCOUNT_ID = tga1.TERR_GROUP_ACCOUNT_ID
                    AND   tga1.TERR_GROUP_ID = p_terr_gp_id)
            and     narsc.rsc_group_id in
                   (SELECT rsc_group_id
                    from jtf_tty_acct_rsc_dn j, jtf_tty_terr_grp_accts tga2
                    WHERE j.TERR_GROUP_ACCOUNT_ID = tga2.TERR_GROUP_ACCOUNT_ID
                    AND   tga2.TERR_GROUP_ID = p_terr_gp_id)
            and     tga.terr_group_id <> p_terr_gp_id
            and     narsc.TERR_GROUP_ACCOUNT_ID = tga.TERR_GROUP_ACCOUNT_ID
            group by narsc.RESOURCE_ID, narsc.RSC_GROUP_ID, na.site_type_code)ilv);
  */
  /* delete the existing assignments */

  DELETE FROM jtf_tty_named_acct_rsc j
  WHERE j.TERR_GROUP_ACCOUNT_ID IN
    (SELECT TERR_GROUP_ACCOUNT_ID
     FROM   JTF_TTY_TERR_GRP_ACCTS
     WHERE TERR_GROUP_ID = p_terr_gp_id);
  /*
  DELETE from jtf_tty_acct_rsc_dn j
  WHERE j.TERR_GROUP_ACCOUNT_ID in
    (SELECT TERR_GROUP_ACCOUNT_ID
     FROM   JTF_TTY_TERR_GRP_ACCTS
     WHERE TERR_GROUP_ID = p_terr_gp_id);
  */

  DELETE FROM JTF_TTY_TERR_GRP_ACCTS
  WHERE TERR_GROUP_ID = p_terr_gp_id;

  DELETE FROM JTF_TTY_NAMED_ACCTS na
  WHERE  na.NAMED_ACCOUNT_ID NOT IN
       (SELECT named_account_id FROM JTF_TTY_TERR_GRP_ACCTS);
 /* delete the na mappings if a na is deleted or no reference to it exists */

  DELETE FROM JTF_TTY_ACCT_QUAL_MAPS nam
  WHERE  nam.NAMED_ACCOUNT_ID NOT IN
       (SELECT named_account_id FROM JTF_TTY_NAMED_ACCTS);

 /* delete all the terr gp owners, access and product */
  DELETE FROM jtf_tty_terr_grp_owners
  WHERE terr_group_id = p_terr_gp_id;

  DELETE FROM jtf_tty_role_prod_int
  WHERE terr_group_role_id IN
      (SELECT terr_group_role_id FROM jtf_tty_terr_grp_roles
       WHERE terr_group_id = p_terr_gp_id);


  DELETE FROM jtf_tty_role_access
  WHERE terr_group_role_id IN
      (SELECT terr_group_role_id FROM jtf_tty_terr_grp_roles
       WHERE terr_group_id = p_terr_gp_id);

  DELETE FROM jtf_tty_terr_grp_roles
  WHERE terr_group_id = p_terr_gp_id;

  /* finally delete the terr gp itself */

  DELETE FROM jtf_tty_terr_groups
  WHERE terr_group_id = p_terr_gp_id;

  /* GSST decom. by SHLI */
  -- log_event(p_terr_gp_id, 'DELETE', 'Delete Territory Group', 'TG', fnd_global.user_id);
  COMMIT;
END delete_terrgp;

PROCEDURE check_hierarchy(x_hierarchy_status OUT NOCOPY VARCHAR2,
                                p_group_id1   IN VARCHAR2,
                                p_group_id2    IN VARCHAR2)
AS
 hierarchy_flag VARCHAR2(25);
BEGIN
 SELECT 'SAME'
 INTO x_hierarchy_status
 FROM dual
 WHERE (p_group_id1 IN
       (SELECT parent_group_id FROM jtf_rs_groups_denorm
        WHERE  group_id = p_group_id2)
 OR p_group_id1 IN
       (SELECT group_id FROM jtf_rs_groups_denorm
        WHERE  parent_group_id = p_group_id2))
 AND ROWNUM < 2;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     x_hierarchy_status := 'DIFFERENT';
END check_hierarchy;



PROCEDURE process_assign_accts(p_terr_gp_id IN NUMBER,
                               p_DownerRsc  IN VARCHAR2,
                               p_NownerRsc  IN VARCHAR2,
                               p_DownerGrp  IN VARCHAR2,
                               p_NownerGrp  IN VARCHAR2,
                               p_DownerRole IN VARCHAR2,
                               p_NownerRole IN VARCHAR2
                              )
AS
managed_group_id NUMBER;
i                NUMBER;
p_user_id        NUMBER;
x_group_id       NUMBER;
child_group_id   NUMBER;
result           VARCHAR2(30);
idx              NUMBER;
new_idx          NUMBER;
del_idx          NUMBER;
replace_idx      NUMBER;
indx             NUMBER;
FOUND            NUMBER;
l_resource_id    NUMBER;
l_group_id       NUMBER;
match_found_flag VARCHAR2(1);

  NewOwnerRsc   mytabletype;
  NewOwnerGrp   mytabletype;
  NewOwnerRole  mytabletypev;

  DelOwnerRsc   mytabletype;
  DelOwnerGrp   mytabletype;
  DelOwnerRole  mytabletypev;

  DelCandidateRsc  mytabletype;
  DelCandidateGrp  mytabletype;
  DelCandidateRole mytabletypev;

  NewCandidateRsc  mytabletype;
  NewCandidateGrp  mytabletype;
  NewCandidateRole mytabletypev;

  RplOwnerFromRsc mytabletype;
  RplOwnerFromGrp mytabletype;
  RplOwnerToRsc   mytabletype;
  RplOwnerToGrp   mytabletype;
  RplOwnerToRole  mytabletypev;

  terr_grp_id     mytabletype;
  terrgrpid_nodup mytabletype;
 /* CURSOR NAHasOwnerAsParent
 IS
 SELECT tga.terr_group_account_id tga_id,
        NAR.assigned_flag         aflag,
        tgo.rsc_group_id          parentgrpid
   FROM JTF_TTY_NAMED_ACCT_RSC  NAR,
        JTF_TTY_TERR_GRP_ACCTS  TGA,
        jtf_tty_terr_grp_owners tgo,
        jtf_rs_groups_denorm    gd
  WHERE NAR.terr_group_account_id = TGA.terr_group_account_id
    AND TGA.TERR_GROUP_ID         = p_terr_gp_id
    AND NAR.rsc_resource_type     = 'RS_EMPLOYEE'
    AND gd.group_id               = NAR.RSC_GROUP_ID
    AND gd.parent_group_id        = tgo.rsc_group_id
    AND tgo.rsc_resource_type     = 'RS_EMPLOYEE'
    AND tgo.TERR_GROUP_ID         = p_terr_gp_id
    AND sysdate BETWEEN gd.start_date_active AND nvl(gd.end_date_active, sysdate);
*/
    /* For each assignment */
    /* check if a TG owner's rsc group a parent of the rep's rsc group*/
    /* only one valid parentgrpid for each assignment ?*/

/*
 CURSOR NAHasNoOwnerAsParent
 IS
 SELECT tga.terr_group_account_id tga_id,
        NAR.rsc_group_id          currentgrpid
   FROM JTF_TTY_NAMED_ACCT_RSC  NAR,
        JTF_TTY_TERR_GRP_ACCTS  TGA
  WHERE NAR.terr_group_account_id = TGA.terr_group_account_id
    AND TGA.TERR_GROUP_ID         = p_terr_gp_id
    AND NAR.rsc_resource_type     = 'RS_EMPLOYEE'
    AND NOT EXISTS
     (
         SELECT NULL
          FROM jtf_tty_terr_grp_owners tgo,
               jtf_rs_groups_denorm gd
         WHERE gd.group_id           = NAR.RSC_GROUP_ID
           AND gd.parent_group_id    = tgo.rsc_group_id
           AND tgo.rsc_resource_type = 'RS_EMPLOYEE'
           AND tgo.TERR_GROUP_ID     = p_terr_gp_id
           AND sysdate BETWEEN gd.start_date_active AND nvl(gd.end_date_active, sysdate)
     );

 CURSOR TGOwner
  IS
  SELECT rsc_group_id,
         resource_id,
         rsc_role_code
   FROM  jtf_tty_terr_grp_owners tgo
   WHERE terr_group_id = p_terr_gp_id
     AND rsc_resource_type = 'RS_EMPLOYEE';
*/

BEGIN

    p_user_id := Fnd_Global.user_id;

    NewOwnerRsc  := mytabletype();
    NewOwnerGrp  := mytabletype();
    NewOwnerRole := mytabletypev();

    DelOwnerRsc  := mytabletype();
    DelOwnerGrp  := mytabletype();
    DelOwnerRole := mytabletypev();

    DelCandidateRsc  := mytabletype();
    DelCandidateGrp  := mytabletype();
    DelCandidateRole := mytabletypev();

    NewCandidateRsc  := mytabletype();
    NewCandidateGrp  := mytabletype();
    NewCandidateRole := mytabletypev();

    RplOwnerFromRsc := mytabletype();
    RplOwnerFromGrp := mytabletype();
    RplOwnerToRsc   := mytabletype();
    RplOwnerToGrp   := mytabletype();
    RplOwnerToRole  := mytabletypev();

    /* Build Candidate table*/


    IF p_DownerRsc  IS NOT NULL THEN generateNumList(p_DownerRsc,   DelCandidateRsc);  END IF;
    IF p_DownerGrp  IS NOT NULL THEN generateNumList(p_DownerGrp,   DelCandidateGrp);  END IF;
    IF p_DownerRole IS NOT NULL THEN generateStrList(p_DownerRole,  DelCandidateRole); END IF;

    IF p_NownerRsc  IS NOT NULL THEN generateNumList(p_NownerRsc,  NewCandidateRsc);   END IF;
    IF p_NownerGrp  IS NOT NULL THEN generateNumList(p_NownerGrp,  NewCandidateGrp);   END IF;
    IF p_NownerRole IS NOT NULL THEN generateStrList(p_NownerRole, NewCandidateRole);  END IF;


    /* Build Del, replace table */

    replace_idx :=0;
    del_idx :=0;
    FOUND :=0;

    FOR idx IN DelCandidateGrp.FIRST .. DelCandidateGrp.LAST
    LOOP
         indx := 1; -- 1 .. NewCandidateGrp.count;
          i := NewCandidateGrp.COUNT;
         WHILE (FOUND=0 AND indx<= NewCandidateGrp.COUNT)
         LOOP

           BEGIN
             /* if the new and old owner are in a same group */

             IF DelCandidateGrp(idx) = NewCandidateGrp(indx) THEN
                  RplOwnerFromRsc.extend();
                  RplOwnerFromGrp.extend();
                  RplOwnerToRsc.extend();
                  RplOwnerToGrp.extend();
                  RplOwnerToRole.extend();

                  replace_idx := replace_idx+1;

                  RplOwnerFromRsc(replace_idx) :=DelCandidateRsc(idx);
                  RplOwnerFromGrp(replace_idx) :=DelCandidateGrp(idx);
                  RplOwnerToRsc(replace_idx)   :=NewCandidateRsc(indx);
                  RplOwnerToGrp(replace_idx)   :=NewCandidateGrp(indx);
                  RplOwnerToRole(replace_idx)  :=NewCandidateRole(indx);

                  FOUND := 1;
              ELSE /* child or parent */
                   result := NULL;

                   -- JRADHAKR: Removed the active_flag clause because
                   -- in 11.5.6 env there is no active_flag column
                   -- Fix for bug 4313953

                   SELECT 'PARENT_CHILD' INTO result
                   FROM  jtf_rs_groups_denorm
                   WHERE SYSDATE BETWEEN start_date_active AND NVL(end_date_active, SYSDATE)
                         AND
                        (     group_id        = DelCandidateGrp(idx)
                          AND parent_group_id = NewCandidateGrp(indx)
                        )
                         OR
                        (     parent_group_id  = DelCandidateGrp(idx)
                          AND group_id         = NewCandidateGrp(indx)
                        );

                   IF result IS NOT NULL THEN
                       RplOwnerFromRsc.extend();
                       RplOwnerFromGrp.extend();
                       RplOwnerToRsc.extend();
                       RplOwnerToGrp.extend();
                       RplOwnerToRole.extend();

                       replace_idx := replace_idx+1;

                       RplOwnerFromRsc(replace_idx) :=DelCandidateRsc(idx);
                       RplOwnerFromGrp(replace_idx) :=DelCandidateGrp(idx);
                       RplOwnerToRsc(replace_idx)   :=NewCandidateRsc(indx);
                       RplOwnerToGrp(replace_idx)   :=NewCandidateGrp(indx);
                       RplOwnerToRole(replace_idx)  :=NewCandidateRole(indx);

                       FOUND := 1; -- done with new owner loop
                   END IF;

                END IF; --of DelCandidateGrp(idx) = NewCandidateGrp(indx)

                indx := indx +1;

                EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      -- NO parent or child relation found
                      indx := indx +1;

             END; -- of BEGIN
            END LOOP; -- of while new owner candidate


          IF FOUND=0 THEN -- not equal, parent or child found

             indx :=1;
             WHILE (FOUND=0 AND indx<= NewCandidateGrp.COUNT)
             LOOP
                BEGIN
                    SELECT 'Y' INTO result
                    FROM jtf_tty_named_acct_rsc narsc,
                         jtf_tty_terr_grp_accts tga,
                         jtf_rs_role_relations rlt ,
                         jtf_rs_group_members grpmem ,
                         jtf_rs_groups_denorm grpdn
                    WHERE narsc.terr_group_account_id = tga.terr_group_account_id
                      AND tga.terr_group_id = DelCandidateGrp(idx)
                      AND narsc.resource_id = grpmem.resource_id
                      AND narsc.rsc_group_id = grpmem.group_id
                      AND grpmem.group_member_id = rlt.role_resource_id
                      AND rlt.role_resource_type = 'RS_GROUP_MEMBER'
                      AND rlt.delete_flag = 'N'
                      AND SYSDATE BETWEEN rlt.start_date_active AND NVL(rlt.end_date_active,SYSDATE+1)
                      AND grpmem.delete_flag = 'N'
                      AND grpmem.group_id = grpdn.group_id
                      AND SYSDATE BETWEEN grpdn.start_date_active AND NVL(grpdn.end_date_active, SYSDATE+1)
                      AND grpdn.parent_group_id = NewCandidateGrp(indx)
                      AND EXISTS ( SELECT 'Y'
                                    FROM  jtf_rs_groups_denorm grpdn1
                                    WHERE narsc.rsc_group_id   = grpdn1.group_id
                                    AND grpdn1.parent_group_id = DelCandidateGrp(idx)
                                 )
                      AND ROWNUM < 2;

                      IF result IS NOT NULL THEN

                         RplOwnerFromRsc.extend();
                         RplOwnerFromGrp.extend();
                         RplOwnerToRsc.extend();
                         RplOwnerToGrp.extend();
                         RplOwnerToRole.extend();

                         replace_idx := replace_idx+1;

                         RplOwnerFromRsc(replace_idx) :=DelCandidateRsc(idx);
                         RplOwnerFromGrp(replace_idx) :=DelCandidateGrp(idx);
                         RplOwnerToRsc(replace_idx)   :=NewCandidateRsc(indx);
                         RplOwnerToGrp(replace_idx)   :=NewCandidateGrp(indx);
                         RplOwnerToRole(replace_idx)  :=NewCandidateRole(indx);

                         FOUND := 1; -- done with new owner loop
                      ELSE indx :=indx +1;

                      END IF;

                      EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                           indx :=indx +1;

                END;
             END LOOP;

             IF FOUND=0 THEN

                DelOwnerRsc.extend();
                DelOwnerGrp.extend();
                DelOwnerRole.extend();

                del_idx := del_idx+1;

                DelOwnerRsc(del_idx)  := DelCandidateRsc(idx);
                DelOwnerGrp(del_idx)  := DelCandidateGRP(idx);
                DelOwnerRole(del_idx) := DelCandidateRole(idx);
             END IF;
          END IF; --found=0 ;

    END LOOP; -- delete owner candidate


    /* Build new owner table */
    new_idx :=0;
    IF NewCandidateGrp.COUNT>0 THEN
      FOR idx IN NewCandidateGrp.FIRST .. NewCandidateGrp.LAST
      LOOP
        indx :=1;
        FOUND :=0;

        WHILE (FOUND=0 AND indx<= RplOwnerToGrp.COUNT)
        LOOP
           IF NewCandidateGrp(idx) = RplOwnerToGrp(indx) AND
              NewCandidateRsc(idx) = RplOwnerToRsc(indx) THEN
              FOUND :=1;
           ELSE indx :=  indx+1;
           END IF;
        END LOOP;

        IF FOUND = 0 THEN
                NewOwnerRsc.extend();
                NewOwnerGrp.extend();
                NewOwnerRole.extend();

                new_idx := new_idx+1;

                NewOwnerRsc(new_idx)  := NewCandidateRsc(idx);
                NewOwnerGrp(new_idx)  := NewCandidateGRP(idx);
                NewOwnerRole(new_idx) := NewCandidateRole(idx);

        END IF;

      END LOOP; --FOR idx in NewCandidateGrp
    END IF; -- NewCandidateGrp.count>0



    /*-------------------------------------------------------------------------*/
    /*--------------- Process delete, new and replace owners ------------------*/
    /*-------------------------------------------------------------------------*/

    /* New owners: assign all accounts to new owners*/
    IF NewOwnerRsc.COUNT>0 THEN
        FOR idx IN NewOwnerRsc.FIRST .. NewOwnerRsc.LAST
        LOOP
            assign_accts( p_terr_gp_id,
                          NewOwnerRsc(idx),
                          NewOwnerGrp(idx),
                          NewOwnerRole(idx),
                          'NO', -- not in use
                          p_user_id);
        END LOOP;
    END IF;


    /* deleted owners: delete all account assignments from deleted owner's hierarchy*/
    IF DelOwnerRsc.COUNT>0 THEN

        FOR idx IN DelOwnerRsc.FIRST .. DelOwnerRsc.LAST
        LOOP
            delete_assign_accts(p_terr_gp_id,
                            DelOwnerRsc(idx),
                            DelOwnerGrp(idx),
                            DelOwnerRole(idx));
        END LOOP;
    END IF;

    /* replaced owners */
    IF RplOwnerFromRsc.COUNT>0 THEN

       FOR idx IN RplOwnerFromRsc.FIRST .. RplOwnerFromRsc.LAST
       LOOP
        /*update all account assignments that are owned by deleted manager
        id ( by resource_id and group_id )  and assigned_flag = 'N'
        with replaced owner */

        UPDATE jtf_tty_named_acct_rsc narsc
           SET resource_id   = RplOwnerToRsc(idx),
               rsc_group_id  = RplOwnerToGrp(idx),
               rsc_role_code = RplOwnerToRole(idx)
           WHERE narsc.resource_id   = RplOwnerFromRsc(idx)
             AND narsc.rsc_group_id  = RplOwnerFromGrp(idx)
             AND narsc.assigned_flag = 'N';



        /* delete all the account assignments that roll-up to deleted owner
           but not the new owner return terr_group_account_id
           and Assign all the terr_group_account_id to new owner */


        terr_grp_id := mytabletype();
        terrgrpid_nodup := mytabletype();

        -- SOLIN, bug4943336, performance tuning
        DELETE FROM  jtf_tty_named_acct_rsc narsc
        WHERE narsc.terr_group_account_id
              IN ( SELECT terr_group_account_id
                    FROM jtf_tty_terr_grp_accts,
                         jtf_rs_role_relations rlt ,
                         jtf_rs_group_members grpmem ,
                         jtf_rs_groups_denorm grpdn
                   WHERE terr_group_id = p_terr_gp_id
                     AND grpmem.resource_id = narsc.resource_id
                     AND grpmem.group_id = narsc.rsc_group_id
                     AND grpmem.group_member_id = rlt.role_resource_id
                     AND rlt.role_resource_type = 'RS_GROUP_MEMBER'
                     AND grpmem.group_id = grpdn.group_id
                     AND grpdn.parent_group_id = rplownerfromgrp(idx)
                     AND NOT EXISTS
                        ( select 'Y'
                          from  jtf_rs_groups_denorm grpdn1
                          where grpmem.group_id = grpdn1.group_id
                            and grpdn1.parent_group_id =  rplownertogrp(idx)
                            and sysdate between grpdn1.start_date_active
                            and nvl(grpdn1.end_date_active,sysdate+1)
                        )
                 )
        RETURNING terr_group_account_id BULK COLLECT INTO terr_grp_id;


                  IF terr_grp_id.COUNT>0 THEN

                    FOR idx IN terr_grp_id.FIRST .. terr_grp_id.LAST
                    LOOP
                      indx := idx+1;
                      WHILE indx <=terr_grp_id.COUNT
                      LOOP
                         IF terr_grp_id(idx) IS NOT NULL AND terr_grp_id(indx) IS NOT NULL
                            AND terr_grp_id(idx) = terr_grp_id(indx) THEN
                            terr_grp_id(indx) := NULL;
                         END IF;

                         indx :=indx +1;
                      END LOOP;
                    END LOOP;


                    indx :=0;
                    FOR idx IN terr_grp_id.FIRST .. terr_grp_id.LAST
                    LOOP
                       IF terr_grp_id(idx) IS NOT NULL THEN
                           terrgrpid_nodup.extend();
                           indx := indx+1;
                           terrgrpid_nodup(indx) := terr_grp_id(idx);
                       END IF;
                    END LOOP;
                  END IF;

                  IF terrgrpid_nodup.COUNT>0 THEN
                     FORALL i IN terrgrpid_nodup.FIRST .. terrgrpid_nodup.LAST
                       INSERT INTO jtf_tty_named_acct_rsc(
                         ACCOUNT_RESOURCE_ID,
                         OBJECT_VERSION_NUMBER,
                         TERR_GROUP_ACCOUNT_ID,
                         RESOURCE_ID,
                         RSC_GROUP_ID,
                         RSC_ROLE_CODE,
                         ASSIGNED_FLAG,
                         RSC_RESOURCE_TYPE,
                         CREATED_BY,
                         CREATION_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_DATE)
                        ( SELECT jtf_tty_named_acct_rsc_s.NEXTVAL,
                             1,
                             terrgrpid_nodup(i),
                             RplOwnerToRsc(idx),
                             RplOwnerToGrp(idx),
                             RplOwnerToRole(idx),
                             'N',
                             'RS_EMPLOYEE',
                             p_user_id,
                             SYSDATE,
                             p_user_id,
                             SYSDATE
                         FROM dual
                        );
                   END IF;


       END LOOP;
     END IF; -- RplOwnerFromRsc>0

   /**************************************************/
   /* For each assigment rolling up to the new owner */
   /**************************************************/


   /* for each assignment hasing a TG owner as a parent of its rep */
   /*FOR tgaHasParent IN NAHasOwnerAsParent
   LOOP

      -- If the assign_flag='Y' check validation, if 'N', this NA should be assigned to new TG owner who is qualified as a parent       IF tgaHasParent.aflag='N' THEN


         DELETE from jtf_tty_named_acct_rsc j
         WHERE j.TERR_GROUP_ACCOUNT_ID = tgaHasParent.tga_id;
         --and ...;

         FOR owner IN TGOwner
         LOOP

           --create assignment
           INSERT INTO jtf_tty_named_acct_rsc(
             ACCOUNT_RESOURCE_ID,
             OBJECT_VERSION_NUMBER,
             TERR_GROUP_ACCOUNT_ID,
             RESOURCE_ID,
             RSC_GROUP_ID,
             RSC_ROLE_CODE,
             ASSIGNED_FLAG,
             RSC_RESOURCE_TYPE,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE)
            ( SELECT jtf_tty_named_acct_rsc_s.nextval,
                     1,
                     tgaHasParent.tga_id,
                     owner.resource_id,
                     owner.rsc_group_id,
                     owner.rsc_role_code,
                     'N',
                     'RS_EMPLOYEE',
                     p_user_id,
                     sysdate,
                     p_user_id,
                     sysdate
             FROM dual
             WHERE  NOT EXISTS
             ( SELECT NULL
               FROM  jtf_tty_named_acct_rsc r
               WHERE r.TERR_GROUP_ACCOUNT_ID = tgaHasParent.tga_id
               AND   r.RESOURCE_ID           = owner.resource_id
               AND   r.RSC_ROLE_CODE         = owner.rsc_role_code
               AND   r.RSC_GROUP_ID          = owner.rsc_group_id
               AND   r.RSC_RESOURCE_TYPE     = 'RS_EMPLOYEE'
               AND   r.RSC_GROUP_ID          = tgaHasParent.parentgrpid
             )
           );

       END LOOP;

       --ELSE  check resource and group menber role
       --    SELECT NULL INTO
       --    FROM


      END IF; -- flag ='N'

     END LOOP; --for each assignment hasing a TG owner as a parent of its rep


   -- for each NA without hasing a TG owner as a parent of its rep
   FOR tgaNoParent IN NAHasNoOwnerAsParent
     LOOP
       FOR owner IN TGOwner
         LOOP

           -- create assignment
           INSERT INTO jtf_tty_named_acct_rsc(
             ACCOUNT_RESOURCE_ID,
             OBJECT_VERSION_NUMBER,
             TERR_GROUP_ACCOUNT_ID,
             RESOURCE_ID,
             RSC_GROUP_ID,
             RSC_ROLE_CODE,
             ASSIGNED_FLAG,
             RSC_RESOURCE_TYPE,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE)
            ( SELECT jtf_tty_named_acct_rsc_s.nextval,
                     1,
                     tgaNoParent.tga_id,
                     owner.resource_id,
                     owner.rsc_group_id,
                     owner.rsc_role_code,
                     'N',
                     'RS_EMPLOYEE',
                     p_user_id,
                     sysdate,
                     p_user_id,
                     sysdate
             FROM dual
             WHERE  NOT EXISTS
             ( SELECT NULL
               FROM  jtf_tty_named_acct_rsc r
               WHERE r.TERR_GROUP_ACCOUNT_ID = tgaNoParent.tga_id
               AND   r.RESOURCE_ID           = owner.resource_id
               AND   r.RSC_ROLE_CODE         = owner.rsc_role_code
               AND   r.RSC_GROUP_ID          = owner.rsc_group_id
               AND   r.RSC_RESOURCE_TYPE     = 'RS_EMPLOYEE'

             )
              AND EXISTS
              (
                SELECT NULL
                FROM jtf_rs_groups_denorm   gd
                WHERE owner.rsc_group_id  = gd.parent_group_id
                  AND gd.group_id         = tgaNoParent.currentgrpid
              )
            );

       END LOOP;

     END LOOP;

   */

   COMMIT;

END process_assign_accts;


PROCEDURE generateNumList(
                           SourceStr  IN VARCHAR2,
                           TargetTab  OUT NOCOPY  mytabletype
                         ) IS
  head NUMBER ;
  i    NUMBER ;
  idx  NUMBER ;
  s VARCHAR2(100);
  TargetArray mytabletype;

BEGIN
    head:=1;
    i:=1;
    idx:=1;
    TargetArray := mytabletype();

    WHILE (i>0)
    LOOP
      i := INSTR(SourceStr, ',', head);

      IF i>0 THEN
         TargetArray.extend();
         TargetArray(idx) := TO_NUMBER(SUBSTR(SourceStr, head, i-head));

         idx := idx + 1;
         head :=i+1;
      END IF;

    END LOOP;


    TargetArray.extend();
    TargetArray(idx) := TO_NUMBER(SUBSTR(SourceStr, head ));

    TargetTab := TargetArray;
    /*
    FOR i IN TargetArray.FIRST .. TargetArray.last
    LOOP
        TargetTab.extend();
        TargetTab(i) := TargetArray(i);
    END LOOP;
    */
 END;

PROCEDURE generateStrList(
                         SourceStr IN VARCHAR2,
                         TargetTab OUT NOCOPY mytabletypev
                       ) IS
  head NUMBER ;
  i    NUMBER ;
  idx  NUMBER ;
  s VARCHAR2(100);
  TargetArray mytabletypev;

BEGIN
    head:=1;
    i:=1;
    idx:=1;
    TargetArray := mytabletypev();

    WHILE (i>0)
    LOOP
      i := INSTR(SourceStr, ',', head);

      IF i>0 THEN
         TargetArray.extend();
         TargetArray(idx) := SUBSTR(SourceStr, head, i-head);

         idx := idx + 1;
         head :=i+1;
      END IF;

    END LOOP;


    TargetArray.extend();
    TargetArray(idx) := SUBSTR(SourceStr, head);

    TargetTab := TargetArray;

 END;


 /* old code for process_assign_accts below*/
 /* no need of denorm tables */
 /* and summarizing moving to concurrent program */
  /*
  DELETE from jtf_tty_acct_rsc_dn j
  WHERE j.TERR_GROUP_ACCOUNT_ID in
    (SELECT TERR_GROUP_ACCOUNT_ID
     FROM   JTF_TTY_TERR_GRP_ACCTS
     WHERE TERR_GROUP_ID = p_terr_gp_id)
  AND j.RESOURCE_ID = p_resource_id
  AND j.RSC_GROUP_ID = p_group_id
  AND j.RSC_ROLE_CODE = p_role_code;
 */
   /* delete from the named acct sum */
  /*
   DELETE from jtf_tty_rsc_acct_summ j
   WHERE j.RESOURCE_ID = p_resource_id
   AND   j.RSC_GROUP_ID = p_group_id
   AND   j.RSC_RESOURCE_TYPE = 'RS_EMPLOYEE';
   sum_res_gp_accts(p_user_id, p_resource_id, p_group_id);
 */

 /* commented out by shli
 for group_data in groups_managed_c loop
  managed_group_id := group_data.group_id;
  DELETE from jtf_tty_named_acct_rsc j
  WHERE j.TERR_GROUP_ACCOUNT_ID in
    (SELECT TERR_GROUP_ACCOUNT_ID
     FROM   JTF_TTY_TERR_GRP_ACCTS
     WHERE TERR_GROUP_ID = p_terr_gp_id)
  AND j.RESOURCE_ID IN (
        select  resource_id
        from jtf_rs_group_members
        where group_id = managed_group_id);
  */
  /*
  DELETE from jtf_tty_acct_rsc_dn j
  WHERE j.TERR_GROUP_ACCOUNT_ID in
    (SELECT TERR_GROUP_ACCOUNT_ID
     FROM   JTF_TTY_TERR_GRP_ACCTS
     WHERE TERR_GROUP_ID = p_terr_gp_id)
  AND j.RESOURCE_ID IN (
        select  resource_id
        from jtf_rs_group_members
        where group_id = managed_group_id);
  */
  /* delete from the named acct sum */
  /*
   DELETE from jtf_tty_rsc_acct_summ j
   WHERE j.RESOURCE_ID IN (
        select  resource_id
        from jtf_rs_group_members
        where group_id = managed_group_id);
   */
   /* re-summarize */
   /*
    insert into jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
   (select jtf_tty_rsc_acct_summ_s.nextval,
           1,
           ilv.RESOURCE_ID,
           ilv.RSC_GROUP_ID,
           'RS_EMPLOYEE',
           ilv.site_type_code,
           ilv.num_accts,
           p_user_id,
           sysdate,
           p_user_id,
           sysdate
      FROM
           (select narsc.RESOURCE_ID,
                   narsc.RSC_GROUP_ID,
                   'RS_EMPLOYEE',
                    na.site_type_code,
                    count(na.NAMED_ACCOUNT_ID) num_accts
            from    jtf_tty_named_accts na, jtf_tty_acct_rsc_dn narsc,
                    jtf_tty_terr_grp_accts tga
            where   na.named_account_id = tga.named_account_id
            and     narsc.TERR_GROUP_ACCOUNT_ID = tga.TERR_GROUP_ACCOUNT_ID
            and     narsc.RESOURCE_ID IN (
                    select  resource_id
                    from jtf_rs_group_members
                    where group_id = managed_group_id)
          group by narsc.RESOURCE_ID, narsc.RSC_GROUP_ID, na.site_type_code)ilv);
  */
  /* commented out by shli
  for child_gp_data in child_groups_c loop
     child_group_id := child_gp_data.group_id;
     DELETE from jtf_tty_named_acct_rsc j
     WHERE j.TERR_GROUP_ACCOUNT_ID in
      (SELECT TERR_GROUP_ACCOUNT_ID
       FROM   JTF_TTY_TERR_GRP_ACCTS
       WHERE TERR_GROUP_ID = p_terr_gp_id)
      AND j.RESOURCE_ID IN (
        select  resource_id
        from jtf_rs_group_members
        where group_id = child_group_id);
     */
     /*
     DELETE from jtf_tty_acct_rsc_dn j
     WHERE j.TERR_GROUP_ACCOUNT_ID in
      (SELECT TERR_GROUP_ACCOUNT_ID
       FROM   JTF_TTY_TERR_GRP_ACCTS
       WHERE TERR_GROUP_ID = p_terr_gp_id)
      AND j.RESOURCE_ID IN (
        select  resource_id
        from jtf_rs_group_members
        where group_id = child_group_id);
   */
  /* delete from the named acct sum */
  /*
   DELETE from jtf_tty_rsc_acct_summ j
   WHERE j.RESOURCE_ID IN (
        select  resource_id
        from jtf_rs_group_members
        where group_id = child_group_id);
   */
   /* re-summarize */
   /*
    insert into jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
   (select jtf_tty_rsc_acct_summ_s.nextval,
           1,
           ilv.RESOURCE_ID,
           ilv.RSC_GROUP_ID,
           'RS_EMPLOYEE',
           ilv.site_type_code,
           ilv.num_accts,
           p_user_id,
           sysdate,
           p_user_id,
           sysdate
      FROM
           (select narsc.RESOURCE_ID,
                   narsc.RSC_GROUP_ID,
                   'RS_EMPLOYEE',
                    na.site_type_code,
                    count(na.NAMED_ACCOUNT_ID) num_accts
            from    jtf_tty_named_accts na, jtf_tty_acct_rsc_dn narsc,
                    jtf_tty_terr_grp_accts tga
            where   na.named_account_id = tga.named_account_id
            and     narsc.TERR_GROUP_ACCOUNT_ID = tga.TERR_GROUP_ACCOUNT_ID
            and   narsc.RESOURCE_ID IN (
                    select  resource_id
                    from jtf_rs_group_members
                    where group_id = child_group_id)
          group by narsc.RESOURCE_ID, narsc.RSC_GROUP_ID, na.site_type_code)ilv);
    */




PROCEDURE assign_acct(p_terr_gp_id IN NUMBER,
                               p_terr_gp_acct_id IN NUMBER,
                               p_resource_id IN NUMBER,
                               p_group_id IN NUMBER,
                               p_role_code IN VARCHAR2,
                               p_action_type IN VARCHAR2,
                               p_user_id   IN NUMBER)
AS
BEGIN


 INSERT INTO jtf_tty_named_acct_rsc(
             ACCOUNT_RESOURCE_ID,
             OBJECT_VERSION_NUMBER,
             TERR_GROUP_ACCOUNT_ID,
             RESOURCE_ID,
             RSC_GROUP_ID,
             RSC_ROLE_CODE,
             ASSIGNED_FLAG,
             RSC_RESOURCE_TYPE,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE)
 (SELECT jtf_tty_named_acct_rsc_s.NEXTVAL,
               1,
               p_terr_gp_acct_id,
               p_resource_id,
               p_group_id,
               p_role_code,
               'N',
               'RS_EMPLOYEE',
               p_user_id,
               SYSDATE,
               p_user_id,
              SYSDATE
   FROM dual
       WHERE  NOT EXISTS
          ( SELECT NULL FROM jtf_tty_named_acct_rsc r
            WHERE r.TERR_GROUP_ACCOUNT_ID = p_terr_gp_acct_id
            AND   r.RESOURCE_ID = p_resource_id
            AND   r.RSC_ROLE_CODE = p_role_code
            AND   r.RSC_GROUP_ID = p_group_id
            AND   r.RSC_RESOURCE_TYPE = 'RS_EMPLOYEE')
       );


 /* now assign the appropriate user to the accounts
 ** in the DENORM table */
  --
 --
 /*
 INSERT into jtf_tty_acct_rsc_dn(
             ACCOUNT_RESOURCE_DN_ID,
             OBJECT_VERSION_NUMBER,
             TERR_GROUP_ACCOUNT_ID,
             RESOURCE_ID,
             RSC_GROUP_ID,
             RSC_ROLE_CODE,
             RSC_RESOURCE_TYPE,
             ASSIGNED_TO_DIRECT_FLAG,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE)
 (select jtf_tty_acct_rsc_dn_s.nextval,
               1,
               p_terr_gp_acct_id,
               p_resource_id,
               p_group_id,
               p_role_code,
               'RS_EMPLOYEE',
               'N',
               p_user_id,
               sysdate,
               p_user_id,
              sysdate
       from dual
       WHERE NOT EXISTS
          ( SELECT NULL FROM jtf_tty_acct_rsc_dn r
            WHERE r.TERR_GROUP_ACCOUNT_ID = p_terr_gp_acct_id
            AND   r.RESOURCE_ID = p_resource_id
            AND   r.RSC_ROLE_CODE = p_role_code
            AND   r.RSC_GROUP_ID = p_group_id
            AND   r.RSC_RESOURCE_TYPE = 'RS_EMPLOYEE')
       );
 */
COMMIT;

END assign_acct;

PROCEDURE assign_accts(p_terr_gp_id IN NUMBER,
                       p_resource_id IN NUMBER,
                       p_group_id IN NUMBER,
                       p_role_code IN VARCHAR2,
                       p_action_type IN VARCHAR2,
                       p_user_id   IN NUMBER)
AS
BEGIN

 /* sbehera 12/30/02 changed assigned_flag from 'Y' to 'N' */
 /* now assign the appropriate user to the accounts */
 --
 -- 01/07/03: JDOCHERT: FIX FOR BUG#2736765
 -- Added check (NOT EXISTS) to only INSERT a record
 -- if it is a new NA that does not already belong
 -- to the TG.
 -- 01/15/03: SGKUMAR: Also added if account does not
 -- belong to TG and additionally the same owner because a tga
 -- can belong to multiple owners

 INSERT INTO jtf_tty_named_acct_rsc(
             ACCOUNT_RESOURCE_ID,
             OBJECT_VERSION_NUMBER,
             TERR_GROUP_ACCOUNT_ID,
             RESOURCE_ID,
             RSC_GROUP_ID,
             RSC_ROLE_CODE,
             ASSIGNED_FLAG,
             RSC_RESOURCE_TYPE,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE)
 (SELECT jtf_tty_named_acct_rsc_s.NEXTVAL,
               1,
               a.TERR_GROUP_ACCOUNT_ID,
               p_resource_id,
               p_group_id,
               p_role_code,
               'N',
               'RS_EMPLOYEE',
               p_user_id,
               SYSDATE,
               p_user_id,
              SYSDATE
       FROM jtf_tty_terr_grp_accts a, dual
       WHERE terr_group_id = p_terr_gp_id
       AND NOT EXISTS
          ( SELECT NULL FROM jtf_tty_named_acct_rsc r
            WHERE r.TERR_GROUP_ACCOUNT_ID = a.TERR_GROUP_ACCOUNT_ID
            AND   r.RESOURCE_ID = p_resource_id
            AND   r.RSC_ROLE_CODE = p_role_code
            AND   r.RSC_GROUP_ID = p_group_id
            AND   r.RSC_RESOURCE_TYPE = 'RS_EMPLOYEE')
       );


 /* now assign the appropriate user to the accounts
 ** in the DENORM table */
  --
 -- 01/06/03: JDOCHERT: FIX FOR BUG#2736765
 -- Added check (NOT EXISTS) to only INSERT a record
 -- if it is a new NA that does not already belong
 -- to the TG.
 -- 01/08/03: JDOCHERT: FIX FOR BUG#2741455
 -- Changed table in NOT EXISTS from jtf_tty_named_acct_rsc
 -- to jtf_tty_acct_rsc_dn
 --
  /*
 INSERT into jtf_tty_acct_rsc_dn(
             ACCOUNT_RESOURCE_DN_ID,
             OBJECT_VERSION_NUMBER,
             TERR_GROUP_ACCOUNT_ID,
             RESOURCE_ID,
             RSC_GROUP_ID,
             RSC_ROLE_CODE,
             RSC_RESOURCE_TYPE,
             ASSIGNED_TO_DIRECT_FLAG,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE)
 (select jtf_tty_acct_rsc_dn_s.nextval,
               1,
               a.TERR_GROUP_ACCOUNT_ID,
               p_resource_id,
               p_group_id,
               p_role_code,
               'RS_EMPLOYEE',
               'N',
               p_user_id,
               sysdate,
               p_user_id,
              sysdate
       from jtf_tty_terr_grp_accts a, dual
       where terr_group_id = p_terr_gp_id
       AND NOT EXISTS
          ( SELECT NULL FROM jtf_tty_acct_rsc_dn r
            WHERE r.TERR_GROUP_ACCOUNT_ID = a.TERR_GROUP_ACCOUNT_ID
            AND   r.RESOURCE_ID = p_resource_id
            AND   r.RSC_ROLE_CODE = p_role_code
            AND   r.RSC_GROUP_ID = p_group_id
            AND   r.RSC_RESOURCE_TYPE = 'RS_EMPLOYEE')
       );
  */

COMMIT;

END assign_accts;

PROCEDURE sum_owner_accts(p_user_id IN NUMBER,
                    p_terr_gp_id IN NUMBER,
                    p_action_type IN VARCHAR2)
AS
BEGIN
   /*
   delete from jtf_tty_rsc_acct_summ
   where  resource_id in(
          select resource_id
          from jtf_tty_terr_grp_owners
          where terr_group_id = p_terr_gp_id)
   and    rsc_group_id in(
          select rsc_group_id
          from jtf_tty_terr_grp_owners
          where terr_group_id = p_terr_gp_id);


   insert into jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
   (select jtf_tty_rsc_acct_summ_s.nextval,
           1,
           ilv.RESOURCE_ID,
           ilv.RSC_GROUP_ID,
           'RS_EMPLOYEE',
           ilv.site_type_code,
           ilv.num_accts,
           p_user_id,
           sysdate,
           p_user_id,
           sysdate
      FROM
           (select narsc.RESOURCE_ID,
                   narsc.RSC_GROUP_ID,
                   'RS_EMPLOYEE',
                    na.site_type_code,
                    count(na.NAMED_ACCOUNT_ID) num_accts
            from    jtf_tty_named_accts na, jtf_tty_acct_rsc_dn narsc,
                    jtf_tty_terr_grp_accts tga, jtf_tty_terr_grp_owners tgo
            where   na.named_account_id = tga.named_account_id
            and     narsc.TERR_GROUP_ACCOUNT_ID = tga.TERR_GROUP_ACCOUNT_ID
            and     narsc.RESOURCE_ID = tgo.RESOURCE_ID
            and     narsc.RSC_GROUP_ID = tgo.RSC_GROUP_ID
            and     tgo.TERR_GROUP_ID = p_terr_gp_id
            group by narsc.RESOURCE_ID, narsc.RSC_GROUP_ID, na.site_type_code)ilv);
  */
COMMIT;
END sum_owner_accts;

PROCEDURE sum_res_gp_accts(p_user_id IN NUMBER,
                           p_resource_id IN NUMBER,
                           p_rsc_group_id IN NUMBER)
AS
BEGIN
   /*
   delete from jtf_tty_rsc_acct_summ
   where  RESOURCE_ID = p_resource_id
   and    RSC_GROUP_ID = p_rsc_group_id;
   insert into jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
   (select jtf_tty_rsc_acct_summ_s.nextval,
           1,
           ilv.RESOURCE_ID,
           ilv.RSC_GROUP_ID,
           'RS_EMPLOYEE',
           ilv.site_type_code,
           ilv.num_accts,
           p_user_id,
           sysdate,
           p_user_id,
           sysdate
      FROM
           (select narsc.RESOURCE_ID,
                   narsc.RSC_GROUP_ID,
                   'RS_EMPLOYEE',
                    na.site_type_code,
                    count(na.NAMED_ACCOUNT_ID) num_accts
            from    jtf_tty_named_accts na, jtf_tty_acct_rsc_dn narsc,
                    jtf_tty_terr_grp_accts tga
            where   na.named_account_id = tga.named_account_id
            and     narsc.TERR_GROUP_ACCOUNT_ID = tga.TERR_GROUP_ACCOUNT_ID
            and     narsc.RESOURCE_ID = p_resource_id
            and     narsc.RSC_GROUP_ID = p_rsc_group_id
            group by narsc.RESOURCE_ID, narsc.RSC_GROUP_ID, na.site_type_code)ilv);
  */

COMMIT;
END sum_res_gp_accts;

PROCEDURE sum_rm_bin(
  x_return_status                               OUT NOCOPY  VARCHAR2
, x_error_message                               OUT NOCOPY  VARCHAR2
)
IS
 L_USER_ID             NUMBER := Fnd_Global.USER_ID();
 L_SYSDATE             DATE   := SYSDATE;
  p_user_id NUMBER;
  p_overlapping_account_flag NUMBER;
  p_owner_user_id NUMBER;
  p_owner_group_id NUMBER;
  p_resource_id NUMBER;
  p_num_accts NUMBER;
  p_site_type_code VARCHAR2(30);
  p_group_id NUMBER;
  p_count NUMBER;
  p_manager_id NUMBER;
  p_num_geos NUMBER;

 CURSOR ALL_OWNER_USERS_C
 IS      SELECT DISTINCT rs.user_id, tgo.rsc_group_id
 FROM    JTF_TTY_TERR_GRP_OWNERS tgo,
         JTF_RS_RESOURCE_EXTNS rs
 WHERE   rs.resource_id = tgo.resource_id;

 CURSOR all_managers_c
 IS   SELECT mdv.resource_id,
             mdv.group_id,
             mdv.dir_user_id
 FROM  jtf_tty_my_resources_v mdv,
       jtf_rs_group_members  mem,
       jtf_rs_roles_b        rol,
       jtf_rs_role_relations rlt
 WHERE rlt.role_resource_type = 'RS_GROUP_MEMBER'
   AND NVL(rlt.delete_flag, 'N') <> 'Y'
   AND SYSDATE BETWEEN rlt.start_date_active AND NVL(rlt.end_date_active, SYSDATE)
   AND rlt.role_id = rol.role_id
   AND rol.manager_flag = 'Y'
   AND rlt.role_resource_id = mem.group_member_id
   AND NVL( mem.delete_flag, 'N') <> 'Y'
   AND mem.resource_id = mdv.resource_id
   AND rol.role_code = mdv.role_code
   AND mem.group_id = mdv.group_id
   AND mdv.parent_group_id = p_owner_group_id
   AND mdv.current_user_id = p_owner_user_id;

 CURSOR all_salesreps_c
 IS   SELECT DISTINCT sdv.resource_id,
             sdv.group_id,
             sdv.dir_user_id
 FROM  jtf_tty_my_resources_v sdv,
       jtf_rs_group_members  mem,
       jtf_rs_roles_b        rol,
       jtf_rs_role_relations rlt
 WHERE rlt.role_resource_type = 'RS_GROUP_MEMBER'
   AND NVL(rlt.delete_flag, 'N') <> 'Y'
   AND SYSDATE BETWEEN rlt.start_date_active AND NVL(rlt.end_date_active, SYSDATE)
   AND rlt.role_id = rol.role_id
   AND rol.member_flag = 'Y'
   AND rlt.role_resource_id = mem.group_member_id
   AND NVL( mem.delete_flag, 'N') <> 'Y'
   AND mem.resource_id = sdv.resource_id
   AND mem.group_id = sdv.group_id
   AND sdv.role_code = rol.role_code
   AND sdv.parent_group_id = p_owner_group_id
   AND sdv.current_user_id = p_owner_user_id;
   /*
   and not exists (select mem1.resource_id from
       jtf_rs_group_members  mem1,
       jtf_rs_roles_b        rol1,
       jtf_rs_role_relations rlt1
       where rlt1.role_resource_type = 'RS_GROUP_MEMBER'
       and nvl(rlt1.delete_flag, 'N') <> 'Y'
       and sysdate between rlt1.start_date_active
                   and nvl(rlt1.end_date_active, sysdate)
   and rlt1.role_id = rol1.role_id
   and rol1.manager_flag = 'Y'
   and rlt1.role_resource_id = mem1.group_member_id
   and nvl( mem1.delete_flag, 'N') <> 'Y'
   and mem1.resource_id = sdv.resource_id);
  */

 CURSOR named_accounts_c IS
  SELECT COUNT(DISTINCT na.named_account_id) num_accounts
  FROM
           jtf_tty_named_accts na,
           jtf_tty_terr_grp_accts ga,
           jtf_tty_my_resources_v repdn,
           jtf_tty_named_acct_rsc narsc,
           jtf_rs_resource_extns rs,
           jtf_rs_group_members mem,
           jtf_tty_terr_groups ttygrp
       WHERE na.named_account_id = ga.named_account_id
       AND ga.terr_group_account_id = narsc.terr_group_account_id
       AND narsc.resource_id = repdn.resource_id
       AND narsc.rsc_group_id = repdn.group_id
       AND repdn.parent_group_id = p_group_id
       AND repdn.current_user_id = p_user_id
       AND rs.user_id = repdn.current_user_id
       AND rs.resource_id = mem.resource_id
       AND ttygrp.terr_group_id  = ga.terr_group_id
       AND (ttygrp.active_from_date <= SYSDATE OR ttygrp.active_to_date IS NULL)
       AND (ttygrp.active_to_date >= SYSDATE OR ttygrp.active_to_date IS NULL)
       AND  na.site_type_code = p_site_type_code;


  CURSOR named_accounts_all_c IS
  SELECT COUNT(DISTINCT na.named_account_id) num_accounts
  FROM
           jtf_tty_named_accts na,
           jtf_tty_terr_grp_accts ga,
           jtf_tty_my_resources_v repdn,
           jtf_tty_named_acct_rsc narsc,
           jtf_rs_resource_extns rs,
           jtf_rs_group_members mem,
           jtf_tty_terr_groups ttygrp
       WHERE na.named_account_id = ga.named_account_id
       AND ga.terr_group_account_id = narsc.terr_group_account_id
       AND narsc.resource_id = repdn.resource_id
       AND narsc.rsc_group_id = repdn.group_id
       AND repdn.parent_group_id = p_group_id
       AND repdn.current_user_id = p_user_id
       AND rs.user_id = repdn.current_user_id
       AND rs.resource_id = mem.resource_id
       AND ttygrp.terr_group_id  = ga.terr_group_id
       AND (ttygrp.active_from_date <= SYSDATE OR ttygrp.active_to_date IS NULL)
       AND (ttygrp.active_to_date >= SYSDATE OR ttygrp.active_to_date IS NULL);

   CURSOR resource_managers_c IS
   SELECT DISTINCT a.parent_resource_id manager_id
   FROM jtf_rs_rep_managers A
   WHERE a.hierarchy_type <> 'MGR_TO_ADMIN'
   AND a.reports_to_flag = 'Y'
   AND a.parent_resource_id <> a.resource_id
   AND SYSDATE BETWEEN a.start_date_active AND NVL(end_date_active, SYSDATE+1)
   AND a.resource_id = p_resource_id
   AND a.group_id = p_group_id;

   CURSOR num_geos_c IS
   SELECT COUNT(gt.geo_territory_id) geo
   FROM jtf_tty_geo_terr_rsc gt, jtf_tty_geo_terr gterr, jtf_tty_terr_groups tg
   WHERE gt.geo_territory_id = gterr.geo_territory_id
   AND   tg.terr_group_id    = gterr.terr_group_id
   AND  TRUNC(tg.active_from_date) <= TRUNC(SYSDATE)
   AND  (tg.active_to_date IS NULL OR TRUNC(tg.active_to_date) >= TRUNC(SYSDATE))
   AND   gt.resource_id = p_resource_id
   AND   gt.rsc_group_id = p_group_id ;

  CURSOR site_codes_c IS
  SELECT lookup_code site_type_code
  FROM   fnd_lookups l
  WHERE  lookup_type = 'JTF_TTY_SITE_TYPE_CODE';

  CURSOR salesrep_named_accounts_c
  IS SELECT  COUNT(na.NAMED_ACCOUNT_ID) num_accounts
            FROM    jtf_tty_named_accts na, jtf_tty_named_acct_rsc narsc,
                    jtf_tty_terr_grp_accts tga, jtf_tty_terr_groups tg
            WHERE   na.named_account_id = tga.named_account_id
            AND     tga.terr_group_id = tg.terr_group_id
           AND     (tg.active_from_date <= SYSDATE OR tg.active_from_date IS NULL)
            AND     (tg.active_to_date >= SYSDATE OR tg.active_to_date IS NULL)
            AND     narsc.TERR_GROUP_ACCOUNT_ID = tga.TERR_GROUP_ACCOUNT_ID
            AND     narsc.resource_id = p_resource_id
            AND     narsc.RSC_GROUP_ID = p_group_id
            AND    narsc.rsc_resource_type = 'RS_EMPLOYEE'
            AND  na.site_type_code = p_site_type_code;

  CURSOR salesrep_named_accounts_all_c
  IS SELECT  COUNT(na.NAMED_ACCOUNT_ID) num_accounts
            FROM    jtf_tty_named_accts na, jtf_tty_named_acct_rsc narsc,
                    jtf_tty_terr_grp_accts tga, jtf_tty_terr_groups tg
            WHERE   na.named_account_id = tga.named_account_id
            AND     tga.terr_group_id = tg.terr_group_id
           AND     (tg.active_from_date <= SYSDATE OR tg.active_from_date IS NULL)
            AND     (tg.active_to_date >= SYSDATE OR tg.active_to_date IS NULL)
            AND     narsc.TERR_GROUP_ACCOUNT_ID = tga.TERR_GROUP_ACCOUNT_ID
            AND     narsc.resource_id = p_resource_id
            AND     narsc.RSC_GROUP_ID = p_group_id
            AND    narsc.rsc_resource_type = 'RS_EMPLOYEE';
            --and  na.site_type_code = p_site_type_code;

BEGIN
  jtf_tty_workflow_pop_bin_pvt.print_log('In sum rm bin Procedure ');
  DELETE jtf_tty_rsc_acct_summ;

  FOR owner_users IN all_owner_users_c LOOP
   p_owner_user_id := owner_users.user_id;
   p_owner_group_id := owner_users.rsc_group_id;
   FOR managers IN all_managers_c LOOP
       p_user_id := managers.dir_user_id;
       p_resource_id := managers.resource_id;
       p_group_id := managers.group_id;
       SELECT COUNT(RESOURCE_ACCT_SUMM_ID)
       INTO p_count
       FROM jtf_tty_rsc_acct_summ
       WHERE RESOURCE_ID = p_resource_id
       AND   RSC_GROUP_ID = p_group_id;

       IF (p_count < 1) THEN
        FOR numbergeos IN num_geos_c LOOP
            p_num_geos := numbergeos.geo;
        END LOOP;
        FOR sites IN site_codes_c LOOP
            p_site_type_code := sites.site_type_code;
            IF (p_site_type_code = 'ALL') THEN
             FOR namedaccounts IN named_accounts_all_c LOOP
              p_num_accts      := namedaccounts.num_accounts;
             END LOOP;
              INSERT INTO jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                NUMBER_GEOS,
                MANAGER_ID,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
              VALUES(jtf_tty_rsc_acct_summ_s.NEXTVAL,
                1,
                p_resource_id,
                p_group_id,
                'RS_EMPLOYEE',
                p_site_type_code,
                p_num_accts,
                p_num_geos,
                -999,
                l_user_id,
                l_sysdate,
                l_user_id,
                l_sysdate);
             FOR res_managers IN resource_managers_c LOOP
             p_manager_id := res_managers.manager_id;
             INSERT INTO jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                NUMBER_GEOS,
                MANAGER_ID,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
             VALUES(jtf_tty_rsc_acct_summ_s.NEXTVAL,
                1,
                p_resource_id,
                p_group_id,
                'RS_EMPLOYEE',
                p_site_type_code,
                p_num_accts,
                p_num_geos,
                p_manager_id,
                l_user_id,
                l_sysdate,
                l_user_id,
                l_sysdate);
              END LOOP;
          ELSE
            FOR namedaccounts IN named_accounts_c LOOP
              p_num_accts      := namedaccounts.num_accounts;
            END LOOP;
              INSERT INTO jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                NUMBER_GEOS,
                MANAGER_ID,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
              VALUES(jtf_tty_rsc_acct_summ_s.NEXTVAL,
                1,
                p_resource_id,
                p_group_id,
                'RS_EMPLOYEE',
                p_site_type_code,
                p_num_accts,
                p_num_geos,
                -999,
                l_user_id,
                l_sysdate,
                l_user_id,
                l_sysdate);
            FOR res_managers IN resource_managers_c LOOP
             p_manager_id := res_managers.manager_id;
             INSERT INTO jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                NUMBER_GEOS,
                MANAGER_ID,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
             VALUES(jtf_tty_rsc_acct_summ_s.NEXTVAL,
                1,
                p_resource_id,
                p_group_id,
                'RS_EMPLOYEE',
                p_site_type_code,
                p_num_accts,
                p_num_geos,
                p_manager_id,
                l_user_id,
                l_sysdate,
                l_user_id,
                l_sysdate);
              END LOOP;
        END IF;
        END LOOP;
       END IF;
     END LOOP;
   FOR salesreps IN all_salesreps_c LOOP
       p_user_id := salesreps.dir_user_id;
       p_resource_id := salesreps.resource_id;
       p_group_id := salesreps.group_id;
       SELECT COUNT(RESOURCE_ACCT_SUMM_ID)
       INTO p_count
       FROM jtf_tty_rsc_acct_summ
       WHERE RESOURCE_ID = p_resource_id
       AND   RSC_GROUP_ID = p_group_id;
       IF (p_count < 1) THEN
        FOR numbergeos IN num_geos_c LOOP
            p_num_geos := numbergeos.geo;
        END LOOP;
        FOR sites IN site_codes_c LOOP
            p_site_type_code := sites.site_type_code;
            IF (p_site_type_code = 'ALL') THEN
              FOR namedaccounts IN salesrep_named_accounts_all_c LOOP
                  p_num_accts      := namedaccounts.num_accounts;
              END LOOP;
              INSERT INTO jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                NUMBER_GEOS,
                MANAGER_ID,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
              VALUES(jtf_tty_rsc_acct_summ_s.NEXTVAL,
                1,
                p_resource_id,
                p_group_id,
                'RS_EMPLOYEE',
                p_site_type_code,
                p_num_accts,
                p_num_geos,
                -999,
                l_user_id,
                l_sysdate,
                l_user_id,
                l_sysdate);
             FOR res_managers IN resource_managers_c LOOP
               p_manager_id := res_managers.manager_id;
               INSERT INTO jtf_tty_rsc_acct_summ(
                    RESOURCE_ACCT_SUMM_ID,
                    OBJECT_VERSION_NUMBER,
                    RESOURCE_ID,
                    RSC_GROUP_ID,
                    RSC_RESOURCE_TYPE,
                    SITE_TYPE_CODE,
                    NUMBER_ACCOUNTS,
                    NUMBER_GEOS,
                    MANAGER_ID,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE)
              VALUES(jtf_tty_rsc_acct_summ_s.NEXTVAL,
                    1,
                    p_resource_id,
                    p_group_id,
                    'RS_EMPLOYEE',
                    p_site_type_code,
                    p_num_accts,
                    p_num_geos,
                    p_manager_id,
                    l_user_id,
                    l_sysdate,
                    l_user_id,
                    l_sysdate);
              END LOOP;
           ELSE
            FOR namedaccounts IN salesrep_named_accounts_c LOOP
              p_num_accts      := namedaccounts.num_accounts;
            END LOOP;
              INSERT INTO jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                NUMBER_GEOS,
                MANAGER_ID,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
              VALUES(jtf_tty_rsc_acct_summ_s.NEXTVAL,
                1,
                p_resource_id,
                p_group_id,
                'RS_EMPLOYEE',
                p_site_type_code,
                p_num_accts,
                p_num_geos,
                -999,
                l_user_id,
                l_sysdate,
                l_user_id,
                l_sysdate);
            FOR res_managers IN resource_managers_c LOOP
             p_manager_id := res_managers.manager_id;
             INSERT INTO jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                NUMBER_GEOS,
                MANAGER_ID,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
             VALUES(jtf_tty_rsc_acct_summ_s.NEXTVAL,
                1,
                p_resource_id,
                p_group_id,
                'RS_EMPLOYEE',
                p_site_type_code,
                p_num_accts,
                p_num_geos,
                p_manager_id,
                l_user_id,
                l_sysdate,
                l_user_id,
                l_sysdate);
              END LOOP;
        END IF;
      END LOOP;
     END IF;
   END LOOP;
  END LOOP;
  /*

                FROM
            (select narsc.RESOURCE_ID,
                   narsc.RSC_GROUP_ID,
                   'RS_EMPLOYEE',
                    na.site_type_code,
                    count(na.NAMED_ACCOUNT_ID) num_accts
            from    jtf_tty_named_accts na, jtf_tty_named_acct_rsc narsc,
                    jtf_tty_terr_grp_accts tga, jtf_tty_terr_groups tg
            where   na.named_account_id = tga.named_account_id
            and     tga.terr_group_id = tg.terr_group_id
           and     (tg.active_from_date <= sysdate or tg.active_from_date is null)
            and     (tg.active_to_date >= sysdate or tg.active_to_date is null)
            and     narsc.TERR_GROUP_ACCOUNT_ID = tga.TERR_GROUP_ACCOUNT_ID
            and     narsc.resource_id = p_resource_id
            and     narsc.RSC_GROUP_ID = p_group_id
            group by narsc.RESOURCE_ID, narsc.RSC_GROUP_ID, na.site_type_code)ilv);
      END LOOP;
    END IF;
   END LOOP;
  END LOOP;
  */

COMMIT;
   jtf_tty_workflow_pop_bin_pvt.print_log('Summarized the RM bin');
EXCEPTION
   WHEN OTHERS THEN
      jtf_tty_workflow_pop_bin_pvt.print_log('Exception others in sum_rm_bin '||SQLERRM);
END sum_rm_bin;



PROCEDURE sum_accts(p_user_id IN NUMBER)
AS
 return_status VARCHAR2(30);
 error_message  VARCHAR2(45);

BEGIN
   jtf_tty_na_terrgp.sum_rm_bin(return_status, error_message);
   /*
   delete jtf_tty_rsc_acct_summ;

   insert into jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
   (select jtf_tty_rsc_acct_summ_s.nextval,
           1,
           ilv.RESOURCE_ID,
           ilv.RSC_GROUP_ID,
           'RS_EMPLOYEE',
           ilv.site_type_code,
           ilv.num_accts,
           p_user_id,
           sysdate,
           p_user_id,
           sysdate
      FROM
           (select narsc.RESOURCE_ID,
                   narsc.RSC_GROUP_ID,
                   'RS_EMPLOYEE',
                    na.site_type_code,
                    count(na.NAMED_ACCOUNT_ID) num_accts
            from    jtf_tty_named_accts na, jtf_tty_acct_rsc_dn narsc,
                    jtf_tty_terr_grp_accts tga, jtf_tty_terr_groups tg
            where   na.named_account_id = tga.named_account_id
            and     narsc.TERR_GROUP_ACCOUNT_ID = tga.TERR_GROUP_ACCOUNT_ID
            and     tga.terr_group_id = tg.terr_group_id
            and     (tg.active_from_date <= sysdate or tg.active_from_date is null)
            and     (tg.active_to_date >= sysdate or tg.active_to_date is null)
            group by narsc.RESOURCE_ID, narsc.RSC_GROUP_ID, na.site_type_code)ilv);

commit;
  */
END sum_accts;


PROCEDURE delete_terrgp_owners_roles(p_terr_gp_id IN NUMBER)
AS


BEGIN

  /* delete all the territory group owners */
  DELETE FROM jtf_tty_terr_grp_owners
  WHERE  terr_group_id = p_terr_gp_id;

 /* delete all the roles, first the product interests, access and finally the roles */
  DELETE FROM jtf_tty_role_prod_int
  WHERE  terr_group_role_id IN (
         SELECT terr_group_role_id
         FROM jtf_tty_terr_grp_roles
         WHERE terr_group_id = p_terr_gp_id);

  DELETE FROM jtf_tty_role_access
  WHERE  terr_group_role_id IN (
         SELECT terr_group_role_id
         FROM jtf_tty_terr_grp_roles
         WHERE terr_group_id = p_terr_gp_id);

  DELETE FROM jtf_tty_terr_grp_roles
  WHERE  terr_group_id = p_terr_gp_id;

  COMMIT;
END delete_terrgp_owners_roles;

PROCEDURE enter_terrgp_details(p_terr_gp_id IN NUMBER,
                             p_terr_gp_name IN VARCHAR2,
                             p_description  IN VARCHAR2,
                             p_rank IN NUMBER,
                             p_from_date IN DATE,
                             p_end_date IN DATE,
                             p_terr_id IN NUMBER,
                             p_user_id IN NUMBER,
                             p_matching_rule_code IN VARCHAR2 DEFAULT '1',
                             p_workflow_item_type IN VARCHAR2 DEFAULT NULL,
                             p_action_type IN VARCHAR2 DEFAULT 'INSERT',
                             p_catch_all_user_id IN NUMBER,
                             p_num_winners IN NUMBER,
                             p_generate_na_flag IN VARCHAR2,
                             p_group_type IN VARCHAR2 DEFAULT 'NAMED_ACCOUNT')
AS
 p_workflow_process_name VARCHAR2(30) DEFAULT NULL;
 p_workflow_count NUMBER := 0;
 p_active_from_date DATE;
 p_active_to_date DATE;

BEGIN
 p_active_from_date := p_from_date;
 p_active_to_date   := p_end_date;
 IF (p_from_date IS NOT NULL) THEN
    p_active_from_date := TRUNC(p_from_date);
 END IF;
 IF (p_end_date IS NOT NULL) THEN
    p_active_to_date := TRUNC(p_end_date + 1) - 1/(24 * 60 * 60);
 END IF;

 IF (p_workflow_item_type IS NOT NULL) THEN
   SELECT COUNT(name)
   INTO  p_workflow_count
   FROM  wf_activities_vl
   WHERE item_type = p_workflow_item_type
   AND   TYPE = 'PROCESS'
   AND    TRUNC(NVL(end_date,SYSDATE)) >= TRUNC(SYSDATE);
   IF (p_workflow_count > 0) THEN
    SELECT name
    INTO  p_workflow_process_name
    FROM  wf_activities_vl
    WHERE item_type = p_workflow_item_type
    AND   TYPE = 'PROCESS'
    AND    TRUNC(NVL(end_date,SYSDATE)) >= TRUNC(SYSDATE)
    AND  ROWNUM < 2 ;
  END IF;
 END IF;
 IF (p_action_type = 'INSERT') THEN
  INSERT INTO JTF_TTY_TERR_GROUPS(
        TERR_GROUP_ID,
        OBJECT_VERSION_NUMBER,
        TERR_GROUP_NAME,
        DESCRIPTION,
        RANK,
        ACTIVE_FROM_DATE,
        ACTIVE_TO_DATE,
        PARENT_TERR_ID,
        MATCHING_RULE_CODE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        WORKFLOW_ITEM_TYPE,
        WORKFLOW_PROCESS_NAME,
        CATCH_ALL_RESOURCE_ID,
        CATCH_ALL_RESOURCE_TYPE,
        NUM_WINNERS,
        GENERATE_CATCHALL_FLAG,
        SELF_SERVICE_TYPE)
  VALUES(
        p_terr_gp_id,
        1,
        p_terr_gp_name,
        p_description,
        p_rank,
        p_active_from_date,
        p_active_to_date,
        p_terr_id,
        p_matching_rule_code,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        p_user_id,
        p_workflow_item_type,
        p_workflow_process_name,
        p_catch_all_user_id,
        'RS_EMPLOYEE',
        p_num_winners,
        p_generate_na_flag,
        p_group_type);
 ELSE

  UPDATE JTF_TTY_TERR_GROUPS
  SET TERR_GROUP_NAME = p_terr_gp_name,
      DESCRIPTION = p_description,
      RANK = p_rank,
      ACTIVE_FROM_DATE = p_active_from_date,
      ACTIVE_TO_DATE = p_active_to_date,
      PARENT_TERR_ID = p_terr_id,
      MATCHING_RULE_CODE = p_matching_rule_code,
      WORKFLOW_ITEM_TYPE = p_workflow_item_type,
      WORKFLOW_PROCESS_NAME = p_workflow_process_name,
      CATCH_ALL_RESOURCE_ID = p_catch_all_user_id,
      CATCH_ALL_RESOURCE_TYPE = 'RS_EMPLOYEE',
      LAST_UPDATED_BY = p_user_id,
      LAST_UPDATE_DATE = SYSDATE,
      NUM_WINNERS      = p_num_winners,
      GENERATE_CATCHALL_FLAG = p_generate_na_flag
  WHERE TERR_GROUP_ID = p_terr_gp_id;
  IF (p_group_type = 'GEOGRAPHY') THEN
      UPDATE JTF_TTY_GEO_TERR
      SET GEO_TERR_NAME = p_terr_gp_name
      WHERE TERR_GROUP_ID = p_terr_gp_id
      AND   OWNER_RESOURCE_ID = -999
      AND   GEO_TERRITORY_ID = - PARENT_GEO_TERR_ID;
  END IF;

 END IF;

COMMIT;

END enter_terrgp_details;

PROCEDURE terrgp_define_role(p_terr_gp_id IN NUMBER,
                             p_terr_gp_role_id IN NUMBER,
                             p_user_id IN NUMBER,
                             p_role_code IN VARCHAR2)
AS
BEGIN

 /* create a role */
 INSERT INTO JTF_TTY_TERR_GRP_ROLES(
        TERR_GROUP_ROLE_ID,
        OBJECT_VERSION_NUMBER,
        TERR_GROUP_ID,
        ROLE_CODE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
 VALUES(
        p_terr_gp_role_id,
        1,
        p_terr_gp_id,
        p_role_code,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        p_user_id);

COMMIT;

END terrgp_define_role;


PROCEDURE delete_assign_accts(p_terr_gp_id IN NUMBER,
                               p_resource_id IN NUMBER,
                               p_group_id IN NUMBER,
                               p_role_code IN VARCHAR2)
AS
managed_group_id NUMBER;
p_user_id NUMBER;
x_group_id NUMBER;
child_group_id   NUMBER;
CURSOR groups_managed_c
IS
SELECT mem.group_id
  FROM jtf_rs_group_members  mem,
       jtf_rs_roles_b        rol,
       jtf_rs_role_relations rlt
 WHERE rlt.role_resource_type = 'RS_GROUP_MEMBER'
   AND NVL(rlt.delete_flag, 'N') <> 'Y'
   AND SYSDATE BETWEEN rlt.start_date_active AND NVL(rlt.end_date_active, SYSDATE)
   AND rlt.role_id = rol.role_id
   AND rol.manager_flag = 'Y'
   AND rlt.role_resource_id = mem.group_member_id
   AND NVL( mem.delete_flag, 'N') <> 'Y'
   AND mem.resource_id = p_resource_id;

CURSOR child_groups_c
IS
SELECT group_id
FROM jtf_rs_groups_denorm
WHERE PARENT_GROUP_ID = managed_group_id;

CURSOR directs_c
IS
SELECT  resource_id
FROM jtf_rs_group_members
WHERE group_id = x_group_id;

BEGIN
   p_user_id := Fnd_Global.user_id;

  /* delete the existing assignments */
  DELETE FROM jtf_tty_named_acct_rsc j
  WHERE j.TERR_GROUP_ACCOUNT_ID IN
    (SELECT TERR_GROUP_ACCOUNT_ID
     FROM   JTF_TTY_TERR_GRP_ACCTS
     WHERE TERR_GROUP_ID = p_terr_gp_id)
  AND j.RESOURCE_ID = p_resource_id
  AND j.RSC_GROUP_ID = p_group_id
  AND j.RSC_ROLE_CODE = p_role_code;

 /* no need of denorm tables */
 /* and summarizing moving to concurrent program */
  /*
  DELETE from jtf_tty_acct_rsc_dn j
  WHERE j.TERR_GROUP_ACCOUNT_ID in
    (SELECT TERR_GROUP_ACCOUNT_ID
     FROM   JTF_TTY_TERR_GRP_ACCTS
     WHERE TERR_GROUP_ID = p_terr_gp_id)
  AND j.RESOURCE_ID = p_resource_id
  AND j.RSC_GROUP_ID = p_group_id
  AND j.RSC_ROLE_CODE = p_role_code;
 */
   /* delete from the named acct sum */
  /*
   DELETE from jtf_tty_rsc_acct_summ j
   WHERE j.RESOURCE_ID = p_resource_id
   AND   j.RSC_GROUP_ID = p_group_id
   AND   j.RSC_RESOURCE_TYPE = 'RS_EMPLOYEE';
   sum_res_gp_accts(p_user_id, p_resource_id, p_group_id);
 */
 FOR group_data IN groups_managed_c LOOP
  managed_group_id := group_data.group_id;
  DELETE FROM jtf_tty_named_acct_rsc j
  WHERE j.TERR_GROUP_ACCOUNT_ID IN
    (SELECT TERR_GROUP_ACCOUNT_ID
     FROM   JTF_TTY_TERR_GRP_ACCTS
     WHERE TERR_GROUP_ID = p_terr_gp_id)
  AND j.RESOURCE_ID IN (
        SELECT  resource_id
        FROM jtf_rs_group_members
        WHERE group_id = managed_group_id);
  /*
  DELETE from jtf_tty_acct_rsc_dn j
  WHERE j.TERR_GROUP_ACCOUNT_ID in
    (SELECT TERR_GROUP_ACCOUNT_ID
     FROM   JTF_TTY_TERR_GRP_ACCTS
     WHERE TERR_GROUP_ID = p_terr_gp_id)
  AND j.RESOURCE_ID IN (
        select  resource_id
        from jtf_rs_group_members
        where group_id = managed_group_id);
  */
  /* delete from the named acct sum */
  /*
   DELETE from jtf_tty_rsc_acct_summ j
   WHERE j.RESOURCE_ID IN (
        select  resource_id
        from jtf_rs_group_members
        where group_id = managed_group_id);
   */
   /* re-summarize */
   /*
    insert into jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
   (select jtf_tty_rsc_acct_summ_s.nextval,
           1,
           ilv.RESOURCE_ID,
           ilv.RSC_GROUP_ID,
           'RS_EMPLOYEE',
           ilv.site_type_code,
           ilv.num_accts,
           p_user_id,
           sysdate,
           p_user_id,
           sysdate
      FROM
           (select narsc.RESOURCE_ID,
                   narsc.RSC_GROUP_ID,
                   'RS_EMPLOYEE',
                    na.site_type_code,
                    count(na.NAMED_ACCOUNT_ID) num_accts
            from    jtf_tty_named_accts na, jtf_tty_acct_rsc_dn narsc,
                    jtf_tty_terr_grp_accts tga
            where   na.named_account_id = tga.named_account_id
            and     narsc.TERR_GROUP_ACCOUNT_ID = tga.TERR_GROUP_ACCOUNT_ID
            and     narsc.RESOURCE_ID IN (
                    select  resource_id
                    from jtf_rs_group_members
                    where group_id = managed_group_id)
          group by narsc.RESOURCE_ID, narsc.RSC_GROUP_ID, na.site_type_code)ilv);
  */
  FOR child_gp_data IN child_groups_c LOOP
     child_group_id := child_gp_data.group_id;
     DELETE FROM jtf_tty_named_acct_rsc j
     WHERE j.TERR_GROUP_ACCOUNT_ID IN
      (SELECT TERR_GROUP_ACCOUNT_ID
       FROM   JTF_TTY_TERR_GRP_ACCTS
       WHERE TERR_GROUP_ID = p_terr_gp_id)
      AND j.RESOURCE_ID IN (
        SELECT  resource_id
        FROM jtf_rs_group_members
        WHERE group_id = child_group_id);
     /*
     DELETE from jtf_tty_acct_rsc_dn j
     WHERE j.TERR_GROUP_ACCOUNT_ID in
      (SELECT TERR_GROUP_ACCOUNT_ID
       FROM   JTF_TTY_TERR_GRP_ACCTS
       WHERE TERR_GROUP_ID = p_terr_gp_id)
      AND j.RESOURCE_ID IN (
        select  resource_id
        from jtf_rs_group_members
        where group_id = child_group_id);
   */
  /* delete from the named acct sum */
  /*
   DELETE from jtf_tty_rsc_acct_summ j
   WHERE j.RESOURCE_ID IN (
        select  resource_id
        from jtf_rs_group_members
        where group_id = child_group_id);
   */
   /* re-summarize */
   /*
    insert into jtf_tty_rsc_acct_summ(
                RESOURCE_ACCT_SUMM_ID,
                OBJECT_VERSION_NUMBER,
                RESOURCE_ID,
                RSC_GROUP_ID,
                RSC_RESOURCE_TYPE,
                SITE_TYPE_CODE,
                NUMBER_ACCOUNTS,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE)
   (select jtf_tty_rsc_acct_summ_s.nextval,
           1,
           ilv.RESOURCE_ID,
           ilv.RSC_GROUP_ID,
           'RS_EMPLOYEE',
           ilv.site_type_code,
           ilv.num_accts,
           p_user_id,
           sysdate,
           p_user_id,
           sysdate
      FROM
           (select narsc.RESOURCE_ID,
                   narsc.RSC_GROUP_ID,
                   'RS_EMPLOYEE',
                    na.site_type_code,
                    count(na.NAMED_ACCOUNT_ID) num_accts
            from    jtf_tty_named_accts na, jtf_tty_acct_rsc_dn narsc,
                    jtf_tty_terr_grp_accts tga
            where   na.named_account_id = tga.named_account_id
            and     narsc.TERR_GROUP_ACCOUNT_ID = tga.TERR_GROUP_ACCOUNT_ID
            and   narsc.RESOURCE_ID IN (
                    select  resource_id
                    from jtf_rs_group_members
                    where group_id = child_group_id)
          group by narsc.RESOURCE_ID, narsc.RSC_GROUP_ID, na.site_type_code)ilv);
    */
   END LOOP;
 END LOOP;
COMMIT;

END delete_assign_accts;


PROCEDURE terrgp_create_access(p_terr_gp_id IN NUMBER,
                             p_terr_gp_role_id IN NUMBER,
                             p_access_type IN VARCHAR2,
                             p_access_code IN VARCHAR2,
                             p_user_id IN NUMBER)
AS

BEGIN

 /* create role accesses for the role */
 INSERT INTO JTF_TTY_ROLE_ACCESS(
        TERR_GROUP_ROLE_ACCESS_ID,
        OBJECT_VERSION_NUMBER,
        TERR_GROUP_ROLE_ID   ,
        ACCESS_TYPE          ,
        TRANS_ACCESS_CODE,
        CREATED_BY           ,
        CREATION_DATE      ,
        LAST_UPDATED_BY   ,
        LAST_UPDATE_DATE ,
        LAST_UPDATE_LOGIN)
 VALUES(
        JTF_TTY_ROLE_ACCESS_S.NEXTVAL,
        1,
        p_terr_gp_role_id,
        p_access_type,
        p_access_code,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        p_user_id);

COMMIT;

END terrgp_create_access;

PROCEDURE terrgp_define_interest(p_terr_gp_role_id IN NUMBER,
                             p_interest_type_id IN NUMBER,
                             p_cat_set_id IN NUMBER,
                             p_cat_enabled_flag IN VARCHAR2,
                             p_user_id IN NUMBER)
AS
BEGIN
 /* create product interests for the role */
 IF (p_cat_enabled_flag = 'N')  THEN
  INSERT INTO JTF_TTY_ROLE_PROD_INT(
        TERR_GROUP_ROLE_PROD_INT_ID,
        OBJECT_VERSION_NUMBER    ,
        TERR_GROUP_ROLE_ID       ,
        INTEREST_TYPE_ID,
        CREATED_BY            ,
        CREATION_DATE      ,
        LAST_UPDATED_BY   ,
        LAST_UPDATE_DATE ,
        LAST_UPDATE_LOGIN)
  VALUES(
        JTF_TTY_ROLE_PROD_INT_S.NEXTVAL,
        1,
        p_terr_gp_role_id,
        p_interest_type_id,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        p_user_id);
 ELSE
  INSERT INTO JTF_TTY_ROLE_PROD_INT(
        TERR_GROUP_ROLE_PROD_INT_ID,
        OBJECT_VERSION_NUMBER    ,
        TERR_GROUP_ROLE_ID       ,
        INTEREST_TYPE_ID,
        PRODUCT_CATEGORY_ID ,
        PRODUCT_CATEGORY_SET_ID ,
        CREATED_BY            ,
        CREATION_DATE      ,
        LAST_UPDATED_BY   ,
        LAST_UPDATE_DATE ,
        LAST_UPDATE_LOGIN)
 VALUES(
        JTF_TTY_ROLE_PROD_INT_S.NEXTVAL,
        1,
        p_terr_gp_role_id,
        -999,
        p_interest_type_id,
        p_cat_set_id,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        p_user_id);
 END IF;
 COMMIT;

END terrgp_define_interest;

PROCEDURE terrgp_define_access(p_terr_gp_id IN NUMBER,
                             p_terr_gp_role_id IN NUMBER,
                             p_role_code IN VARCHAR2,
                             p_access_type IN VARCHAR2,
                             p_user_id IN NUMBER,
                             p_interest_type_id IN NUMBER DEFAULT NULL)
AS

BEGIN
 /* create a role, assign accesses to role and assign prod interests to role */

 /* create a role */
 INSERT INTO JTF_TTY_TERR_GRP_ROLES(
        TERR_GROUP_ROLE_ID,
        OBJECT_VERSION_NUMBER,
        TERR_GROUP_ID,
        ROLE_CODE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
 VALUES(
        p_terr_gp_role_id,
        1,
        p_terr_gp_id,
        p_role_code,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        p_user_id);

 /* create role accesses for the role */
 INSERT INTO JTF_TTY_ROLE_ACCESS(
        TERR_GROUP_ROLE_ACCESS_ID,
        OBJECT_VERSION_NUMBER,
        TERR_GROUP_ROLE_ID   ,
        ACCESS_TYPE          ,
        CREATED_BY           ,
        CREATION_DATE      ,
        LAST_UPDATED_BY   ,
        LAST_UPDATE_DATE ,
        LAST_UPDATE_LOGIN)
 VALUES(
        JTF_TTY_ROLE_ACCESS_S.NEXTVAL,
        1,
        p_terr_gp_role_id,
        p_access_type,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        p_user_id);

 /* create product interests for the role */
 INSERT INTO JTF_TTY_ROLE_PROD_INT(
        TERR_GROUP_ROLE_PROD_INT_ID,
        OBJECT_VERSION_NUMBER    ,
        TERR_GROUP_ROLE_ID       ,
        INTEREST_TYPE_ID,
        CREATED_BY            ,
        CREATION_DATE      ,
        LAST_UPDATED_BY   ,
        LAST_UPDATE_DATE ,
        LAST_UPDATE_LOGIN)
 VALUES(
        JTF_TTY_ROLE_PROD_INT_S.NEXTVAL,
        1,
        p_terr_gp_role_id,
        p_interest_type_id,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        p_user_id);

 COMMIT;

END terrgp_define_access;

PROCEDURE delete_tgp_named_account(p_terr_gp_id IN NUMBER,
                                p_party_id   IN NUMBER,
                                p_tga_id    IN NUMBER)
AS

BEGIN

-- delete assignment for the grp account
  DELETE FROM jtf_tty_named_acct_rsc j
  WHERE j.TERR_GROUP_ACCOUNT_ID = p_tga_id;

-- delete grp account
DELETE FROM JTF_TTY_TERR_GRP_ACCTS
WHERE  terr_group_account_id = p_tga_id;

-- delete named account if no references to it exist
DELETE FROM JTF_TTY_NAMED_ACCTS
WHERE  party_id = p_party_id
AND    party_id NOT IN
      (SELECT party_id FROM JTF_TTY_NAMED_ACCTS na, JTF_TTY_TERR_GRP_ACCTS tga
       WHERE  tga.named_account_id = na.named_account_id);

COMMIT;

END delete_tgp_named_account;


PROCEDURE create_acct_mappings(p_acct_id IN NUMBER,
                                p_party_id   IN NUMBER,
                                p_user_id   IN NUMBER)
AS
 p_business_name VARCHAR2(360) DEFAULT NULL;
 p_trade_name    VARCHAR2(240) DEFAULT NULL;
 p_postal_code   VARCHAR2(60) DEFAULT NULL;
 p_party_count NUMBER;


BEGIN
 BEGIN

      SELECT H3.party_name,
             H3.known_as,
             H1.postal_code
      INTO   p_business_name,
             p_trade_name,
             p_postal_code
      FROM   HZ_PARTIES             H3,
             HZ_LOCATIONS           H1,
             HZ_PARTY_SITES         H2
      WHERE  h3.party_id = h2.party_id
      AND    h2.location_id = h1.location_id
      AND    h3.party_id = p_party_id
      AND    h2.identifying_address_flag = 'Y';

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        NULL;
  END;
 IF (p_business_name IS NOT NULL) THEN
 /* key name for business name */
 INSERT INTO jtf_tty_acct_qual_maps
             (ACCOUNT_QUAL_MAP_ID,
              OBJECT_VERSION_NUMBER,
              NAMED_ACCOUNT_ID,
              QUAL_USG_ID,
              COMPARISON_OPERATOR,
              VALUE1_CHAR,
              VALUE2_CHAR,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE)
        (
        SELECT jtf_tty_acct_qual_maps_s.NEXTVAL,
             1,
             p_acct_id,
             -1012,
             '=',
             UPPER(p_business_name),
             NULL,
             p_user_id,
             SYSDATE,
             p_user_id,
             SYSDATE FROM dual);
 END IF;
 /* key name for trade name */
 IF (p_trade_name IS NOT NULL) THEN
 INSERT INTO jtf_tty_acct_qual_maps
             (ACCOUNT_QUAL_MAP_ID,
              OBJECT_VERSION_NUMBER,
              NAMED_ACCOUNT_ID,
              QUAL_USG_ID,
              COMPARISON_OPERATOR,
              VALUE1_CHAR,
              VALUE2_CHAR,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE)
         (SELECT  jtf_tty_acct_qual_maps_s.NEXTVAL,
             1,
             p_acct_id,
             -1012,
             '=',
             UPPER(p_trade_name),
             NULL,
             p_user_id,
             SYSDATE,
             p_user_id,
             SYSDATE FROM dual);
 END IF;

 /* key name for postal code */
 IF (p_postal_code IS NOT NULL) THEN
 INSERT INTO jtf_tty_acct_qual_maps
             (ACCOUNT_QUAL_MAP_ID,
              OBJECT_VERSION_NUMBER,
              NAMED_ACCOUNT_ID,
              QUAL_USG_ID,
              COMPARISON_OPERATOR,
              VALUE1_CHAR,
              VALUE2_CHAR,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE)
        (SELECT jtf_tty_acct_qual_maps_s.NEXTVAL,
             1,
             p_acct_id,
             -1007,
             '=',
             p_postal_code,
             NULL,
             p_user_id,
             SYSDATE,
             p_user_id,
             SYSDATE FROM dual);
  END IF;
END create_acct_mappings;

PROCEDURE create_tgp_named_account(p_terr_gp_id IN NUMBER,
                                p_party_id   IN NUMBER,
                                p_user_id    IN NUMBER,
                                x_gp_acct_id OUT NOCOPY NUMBER)
AS
 p_site_type_code VARCHAR2(30);
 p_mapping_flag VARCHAR2(1);
 p_account_count NUMBER(30);
 p_grp_acct_count NUMBER(30);
 p_account_id NUMBER(30);
 p_terr_gp_acct_id NUMBER(30);

BEGIN
 BEGIN
  SELECT 1
  INTO p_account_count
  FROM jtf_tty_named_accts
  WHERE party_id = p_party_id
  AND   ROWNUM < 2;
 EXCEPTION
     WHEN NO_DATA_FOUND THEN
        p_account_count := 0;
 END;


p_site_type_code := get_site_type_code(p_party_id);

-- create a new named account for the party, if one does not exist
-- create postal code and customer key names for a new account 2780737
 IF (p_account_count < 1) THEN

    SELECT JTF_TTY_NAMED_ACCTS_S.NEXTVAL
    INTO   p_account_id
    FROM dual;
    INSERT INTO jtf_tty_named_accts
   (NAMED_ACCOUNT_ID,
    OBJECT_VERSION_NUMBER ,
    PARTY_ID       ,
    MAPPING_COMPLETE_FLAG,
    SITE_TYPE_CODE,
    CREATED_BY ,
    CREATION_DATE ,
    LAST_UPDATED_BY ,
    LAST_UPDATE_DATE ,
    LAST_UPDATE_LOGIN
    )
    VALUES(p_account_id,
       2,
       p_party_id,
       'N',
       p_site_type_code,
       p_user_id,
       SYSDATE,
       p_user_id,
       SYSDATE,
       p_user_id
    );
   p_mapping_flag := 'N';
   create_acct_mappings(p_account_id, p_party_id, p_user_id);
ELSE

 SELECT named_account_id,  mapping_complete_flag
 INTO p_account_id, p_mapping_flag
 FROM jtf_tty_named_accts
 WHERE party_id = p_party_id;

END IF;

-- check if any terr gp account exists
 BEGIN
  SELECT 1
  INTO p_grp_acct_count
  FROM JTF_TTY_TERR_GRP_ACCTS tga, JTF_TTY_NAMED_ACCTS tna
  WHERE tga.named_account_id = tna.named_account_id
  AND   tga.terr_group_id = p_terr_gp_id
  AND   tna.party_id = p_party_id
  AND   ROWNUM < 2;
 EXCEPTION
     WHEN NO_DATA_FOUND THEN
      p_grp_acct_count := 0;
 END;


 IF (p_grp_acct_count = 1) THEN
   SELECT tga.terr_group_account_id
   INTO p_terr_gp_acct_id
   FROM JTF_TTY_TERR_GRP_ACCTS tga, JTF_TTY_NAMED_ACCTS tna
   WHERE tga.named_account_id = tna.named_account_id
   AND   tga.terr_group_id = p_terr_gp_id
   AND   tna.party_id = p_party_id;
   x_gp_acct_id := p_terr_gp_acct_id;
 END IF;

 SELECT JTF_TTY_TERR_GRP_ACCTS_S.NEXTVAL
 INTO   p_terr_gp_acct_id
 FROM dual;

-- assign a named account for the party to terr gp, if one does not exist
IF (p_grp_acct_count < 1) THEN
    x_gp_acct_id := p_terr_gp_acct_id;
    INSERT INTO JTF_TTY_TERR_GRP_ACCTS
    (TERR_GROUP_ACCOUNT_ID,
     OBJECT_VERSION_NUMBER ,
     TERR_GROUP_ID ,
     NAMED_ACCOUNT_ID,
     DN_JNA_MAPPING_COMPLETE_FLAG,
     DN_JNA_SITE_TYPE_CODE,
     DN_JNR_ASSIGNED_FLAG       ,
     CREATED_BY ,
     CREATION_DATE ,
     LAST_UPDATED_BY ,
     LAST_UPDATE_DATE ,
     LAST_UPDATE_LOGIN
    )
    VALUES(p_terr_gp_acct_id,
           2,
           p_terr_gp_id,
           p_account_id,
           p_mapping_flag,
           p_site_type_code,
           'N',
           p_user_id,
           SYSDATE,
           p_user_id,
           SYSDATE,
           p_user_id
    );

END IF;

COMMIT;

END create_tgp_named_account;

PROCEDURE add_orgs_to_terrgp(p_terr_gp_id IN NUMBER,
                             p_party_id IN NUMBER,
                             p_resource_id IN NUMBER,
                             p_role_id IN NUMBER,
                             p_user_id IN NUMBER,
                             p_rsc_group_id IN NUMBER)
AS
 p_site_type_code VARCHAR2(30);
 p_account_count NUMBER(30);
 p_rsc_acct_count NUMBER(30);
 p_account_id NUMBER(30);
 p_terr_gp_acct_id NUMBER(30);
 p_terr_gp_acct_rsc_id NUMBER(30);
 p_terr_gp_acct_rsc_dn_id NUMBER(30) := 0;

BEGIN

 SELECT COUNT(*)
 INTO p_account_count
 FROM jtf_tty_named_accts

 WHERE party_id = p_party_id;
-- create a new named account for the party, if one does not exist
 SELECT JTF_TTY_NAMED_ACCTS_S.NEXTVAL
 INTO   p_account_id
 FROM dual;

p_site_type_code := get_site_type_code(p_party_id);

IF (p_account_count < 1) THEN

INSERT INTO jtf_tty_named_accts
(NAMED_ACCOUNT_ID,
 OBJECT_VERSION_NUMBER ,
 PARTY_ID       ,
 MAPPING_COMPLETE_FLAG,
 SITE_TYPE_CODE,
 CREATED_BY ,
 CREATION_DATE ,
LAST_UPDATED_BY ,
LAST_UPDATE_DATE ,
LAST_UPDATE_LOGIN
)
VALUES(p_account_id,
       2,
       p_party_id,
       'N',
       p_site_type_code,
       p_user_id,
       SYSDATE,
       p_user_id,
       SYSDATE,
       p_user_id
);
END IF;

-- check if any terr gp account exists

 SELECT COUNT(tga.terr_group_account_id)
 INTO p_account_count
 FROM JTF_TTY_TERR_GRP_ACCTS tga, JTF_TTY_NAMED_ACCTS tna
 WHERE tga.named_account_id = tna.named_account_id
 AND   tna.party_id = p_party_id;

 SELECT JTF_TTY_TERR_GRP_ACCTS_S.NEXTVAL
 INTO   p_terr_gp_acct_id
 FROM dual;
-- assign a named account for the party to terr gp, if one does not exist

p_site_type_code := get_site_type_code(p_party_id);

IF (p_account_count < 1) THEN

INSERT INTO JTF_TTY_TERR_GRP_ACCTS
(TERR_GROUP_ACCOUNT_ID,
 OBJECT_VERSION_NUMBER ,
 TERR_GROUP_ID ,
 NAMED_ACCOUNT_ID,
 DN_JNA_SITE_TYPE_CODE,
 DN_JNR_ASSIGNED_FLAG       ,
 CREATED_BY ,
 CREATION_DATE ,
 LAST_UPDATED_BY ,
 LAST_UPDATE_DATE ,
 LAST_UPDATE_LOGIN
)
VALUES(p_terr_gp_acct_id,
       2,
       p_terr_gp_id,
       p_account_id,
       p_site_type_code,
       'N',
       p_user_id,
       SYSDATE,
       p_user_id,
       SYSDATE,
       p_user_id
);
END IF;
-- assign resource to the named account

 SELECT jtf_tty_named_acct_rsc_s.NEXTVAL
 INTO   p_terr_gp_acct_rsc_id
 FROM dual;

INSERT INTO jtf_tty_named_acct_rsc
(ACCOUNT_RESOURCE_ID,
 OBJECT_VERSION_NUMBER ,
 TERR_GROUP_ACCOUNT_ID,
 RESOURCE_ID ,
 RSC_GROUP_ID,
 RSC_ROLE_CODE,
 ASSIGNED_FLAG       ,
 RSC_RESOURCE_TYPE,
 CREATED_BY ,
 CREATION_DATE ,
 LAST_UPDATED_BY ,
 LAST_UPDATE_DATE ,
 LAST_UPDATE_LOGIN
)
VALUES(p_terr_gp_acct_rsc_id,
       2,
       p_terr_gp_acct_id,
       p_resource_id,
       p_rsc_group_id,
       p_role_id,
       'N',
       'RS_EMPLOYEE',
       p_user_id,
       SYSDATE,
       p_user_id,
       SYSDATE,
       p_user_id
);
/* commenting for now */
/*
select jtf_tty_acct_rsc_dn_s.nextval
into p_terr_gp_acct_rsc_dn_id
from dual;
insert into jtf_tty_acct_rsc_dn
(ACCOUNT_RESOURCE_DN_ID,
 OBJECT_VERSION_NUMBER ,
 TERR_GROUP_ACCOUNT_ID,
 RESOURCE_ID ,
 RSC_GROUP_ID,
 RSC_ROLE_CODE,
 RSC_RESOURCE_TYPE,
 CREATED_BY ,
 CREATION_DATE ,
 LAST_UPDATED_BY ,
 LAST_UPDATE_DATE ,
 LAST_UPDATE_LOGIN
)
VALUES(p_terr_gp_acct_rsc_dn_id,
       2,
       p_terr_gp_acct_id,
       p_resource_id,
       p_rsc_group_id,
       p_role_id,
       'RS_EMPLOYEE',
       p_user_id,
       sysdate,
       p_user_id,
       sysdate,
       p_user_id
);
commit;
*/
/*
select count(*)
into p_rsc_acct_count
from jtf_tty_rsc_acct_summ
where resource_id = p_resource_id
and   (rsc_group_id = p_rsc_group_id or p_rsc_group_id is null)
and   rsc_resource_type = 'RS_EMPLOYEE'
and   site_type_code =  p_site_type_code;
*/
-- if does not exist, create a new entry, else update the count for
-- correct row
/*
if (p_rsc_acct_count = 0) then
insert into jtf_tty_rsc_acct_summ
(RESOURCE_ACCT_SUMM_ID,
 OBJECT_VERSION_NUMBER ,
 RESOURCE_ID ,
 RSC_GROUP_ID,
 RSC_RESOURCE_TYPE,
 SITE_TYPE_CODE,
 NUMBER_ACCOUNTS,
 CREATED_BY ,
 CREATION_DATE ,
 LAST_UPDATED_BY ,
 LAST_UPDATE_DATE ,
 LAST_UPDATE_LOGIN
)
VALUES(p_terr_gp_acct_rsc_dn_id,
       2,
       p_resource_id,
       p_rsc_group_id,
       'RS_EMPLOYEE',
       p_site_type_code,
       0,
       p_user_id,
       sysdate,
       p_user_id,
       sysdate,
       p_user_id);

else

update jtf_tty_rsc_acct_summ
set NUMBER_ACCOUNTS = NUMBER_ACCOUNTS + 1
where resource_id = p_resource_id
and   rsc_resource_type = 'RS_EMPLOYEE'
and   site_type_code = p_site_type_code
and   (rsc_group_id = p_rsc_group_id or p_rsc_group_id is null);
end if;

commit;
*/
END add_orgs_to_terrgp;

PROCEDURE terrgp_assign_owners(p_terr_gp_id IN NUMBER,
                             p_rsc_gp_id IN NUMBER,
                             p_resource_id IN NUMBER,
                             p_role_code IN VARCHAR2,
                             p_user_id IN NUMBER,
                             p_resource_type IN VARCHAR2 DEFAULT 'RS_EMPLOYEE')
AS

BEGIN
INSERT INTO jtf_tty_terr_grp_owners(
        TERR_GROUP_OWNER_ID,
        OBJECT_VERSION_NUMBER,
        TERR_GROUP_ID,
        RSC_GROUP_ID,
        RESOURCE_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        RSC_ROLE_CODE ,
        RSC_RESOURCE_TYPE
       )
VALUES(jtf_tty_terr_grp_owners_s.NEXTVAL,
       1,
       p_terr_gp_id,
       p_rsc_gp_id,
       p_resource_id,
       p_user_id,
       SYSDATE,
       p_user_id,
       SYSDATE,
       p_user_id,
       p_role_code,
       'RS_EMPLOYEE');

COMMIT;
END terrgp_assign_owners;


/* SHLI GSST decom. */
PROCEDURE log_event(p_object_id IN NUMBER,
                    p_action_type IN VARCHAR2,
                    p_from_where IN VARCHAR2,
                    p_object_type IN VARCHAR2,
                    p_user_id IN NUMBER)
IS
BEGIN
  INSERT INTO JTF_TTY_NAMED_ACCT_CHANGES(
              NAMED_ACCT_CHANGE_ID,
              OBJECT_VERSION_NUMBER,
              OBJECT_TYPE,
              OBJECT_ID,
              CHANGE_TYPE,
              FROM_WHERE,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE
   )
  VALUES(JTF_TTY_NAMED_ACCT_CHANGES_S.NEXTVAL,
         1,
         p_object_type,
         p_object_id,
         p_action_type,
         p_from_where,
         p_user_id,
         SYSDATE,
         p_user_id,
         SYSDATE);

  COMMIT;
END log_event;

end JTF_TTY_NA_TERRGP;

/
