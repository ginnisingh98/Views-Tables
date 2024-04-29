--------------------------------------------------------
--  DDL for Package Body JTF_TTY_NACCT_SALES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_NACCT_SALES_PUB" AS
/* $Header: jtfnacsb.pls 120.3 2005/10/22 17:42:26 shli ship $ */
/*===========================================================================+
 |               Copyright (c) 2002 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
+===========================================================================*/
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_NACCT_SALES_PUB
--    ---------------------------------------------------
--    PURPOSE
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--
--    HISTORY
--
--      11/27/2002 EIHSU        (Edward Hsu) Assign Subsidiary cursor fix
--      12/03/2002 EIHSU        Assign Subsidiary cursor fix again - phase 0 added
--      12/25/2002 EIHSU        Simple Search now calling Update Sales Team with user_id
--                              fetching user_resource_id from user_id needed.
--      01/01/2003 EIHSU        Fix bugs 2726632, 2729173
--      01/07/2003 EIHSU        BUG 2729383
--      01/23/2003 EIHSU        BUG 2766624
--      01/28/2003 EIHSU        BUG 2774021
--      02/05/2003 EIHSU        BUG TO SET ASSIGN FLAG PROPERLY
--      02/10/2003 EIHSU        Cursor fix for assign flag
--      02/10/2003 EIHSU        assign flag variable used for insert row
--      02/10/2003 EIHSU        bug 2797295
--      02/14/2003 EIHSU        bug 2803830
--      02/25/2003 EIHSU        bug 2816957, 2816972
--      02/27/2003 EIHSU        bug 2826052
--      02/27/2003 EIHSU        bug 2828011
--      04/17/2003 ARPATEL      bug 2885573 - performance fixes.
--      12/03/2003 ACHANDA      bug 3265188 - performance fixes.

--    End of Comments
--
--*******************************************************
--    Start of Comments
--*******************************************************

--**************************************
-- PROCEDURE UPDATE_SALES_TEAM
--**************************************

--  input:
--      [list of] lp_resource_id, lp_group_id, lp_role_code
--      [list of] lp_party_id
--      FROM CALLING PAGE
--        lp_current_user_resource_id    NOTE THIS PARAMETER NO LONGER USED
--        p_user_attribute1 IS NOW USED INSTEAD, value is USER_ID
--        lp_territory_group_id

PROCEDURE UPDATE_SALES_TEAM(
      p_api_version_number    IN          NUMBER,
      p_init_msg_list         IN         VARCHAR2  := FND_API.G_FALSE,
      p_SQL_Trace             IN         VARCHAR2,
      p_Debug_Flag            IN         VARCHAR2,
      x_return_status         OUT  NOCOPY       VARCHAR2,
      x_msg_count             OUT  NOCOPY       NUMBER,
      x_msg_data              OUT  NOCOPY       VARCHAR2,

      p_user_resource_id      IN          NUMBER,  -- NOTE THIS IS NOT USED, user_attr1 used for user_id instead.
      p_terr_group_id         IN          NUMBER,
      p_user_attribute1       IN          VARCHAR2,
      p_user_attribute2       IN          VARCHAR2,
      p_added_rscs_tbl        IN          SALESREP_RSC_TBL_TYPE,
      p_removed_rscs_tbl      IN          SALESREP_RSC_TBL_TYPE,
      p_affected_parties_tbl  IN          AFFECTED_PARTY_TBL_TYPE,
      ERRBUF                  OUT NOCOPY  VARCHAR2,
      RETCODE                 OUT NOCOPY  VARCHAR2
  )
IS

    l_user_id               NUMBER := p_user_attribute1;
    /*lp_user_resource_id     NUMBER := p_user_resource_id; */
    lp_user_resource_type   VARCHAR2(30) := 'RS_EMPLOYEE';
    lp_terr_group_id        NUMBER := p_terr_group_id;
    l_terr_group_id        NUMBER;
    lp_resource_id          NUMBER;
    lp_group_id             NUMBER;
    lp_role_code            VARCHAR2(300);
    lp_mgr_resource_id          NUMBER;
    lp_mgr_group_id             NUMBER;
    lp_mgr_role_code            VARCHAR2(300);
    lp_resource_type        VARCHAR2(300);
    t_resource_id           NUMBER;
    t_resource_type         VARCHAR2(19);

    lp_named_account_id     NUMBER;

    l_role_code            VARCHAR2(300);
    l_terr_group_account_id NUMBER;
    l_directs_on_account    NUMBER := 0;
    l_assign_flag           VARCHAR2(1);
    l_resource_id_is_leaf   VARCHAR2(1);
    l_assigned_rsc_exists   NUMBER := 0;  -- 0 if no assigned rsc exists, 1 otherwise

    l_find_subs             VARCHAR2(1);        -- are we processing subsidiaries?
    l_master_pty_last       NUMBER;   -- last index of the master parties
    l_sub_pty_index         NUMBER;   -- index where the subsidiaries will be added
    l_acct_rsc_exist_count  NUMBER;   -- verify if existing rsc/group/role exists

    l_change_id             NUMBER;
    l_user                  number;
    l_login_id              number;


    new_seq_acct_rsc_id             NUMBER;
    new_seq_acct_rsc_dn_id          NUMBER;
    new_seq_RESOURCE_ACCT_SUMM_ID   NUMBER;


    -- LIST OF ALL GROUPS A GIVEN RESOURCE OWNS IN THE CONTEXT OF A PARENT GRUOP
    cursor c_rsc_owned_grps(cl_parent_resource_id number, cl_group_id number) is
        SELECT mgr.resource_id, mgr.group_id
        FROM   jtf_rs_rep_managers mgr,
               jtf_rs_groups_denorm gd
        WHERE  mgr.hierarchy_type = 'MGR_TO_MGR'
        AND    mgr.resource_id = mgr.parent_resource_id
        AND    trunc(sysdate) BETWEEN mgr.start_date_active
                              AND NVL(mgr.end_date_active,trunc(sysdate))
        AND    mgr.group_id = gd.group_id
        AND    gd.parent_group_id = cl_group_id
        AND    mgr.resource_id = cl_parent_resource_id
        AND rownum < 2;


    -- LIST OF ALL DIRECTS TO REMOVE WHEN REMOVING A MANAGING RESOURCE
    -- FROM A NAMED ACCOUNT IN THE CONTEXT OF A GROUP
    cursor c_rsc_directs(cl_parent_resource_id number, cl_group_id number) is
        SELECT DISTINCT RESOURCE_ID
        FROM JTF_RS_REP_MANAGERS
        WHERE group_id = cl_group_id
          and resource_id <> cl_parent_resource_id
          and parent_resource_id = cl_parent_resource_id;


    -- ALL SUBSIDIARIES OF cl_party_id that is owned by lp_user_resource_id, p_terr_group_id
    -- QUERY MODIFIED FOR TERR_GROUP_ACCOUNT_ID IN/OUT
    cursor c_subsidiaries(cl_terr_group_account_id number) is
         select distinct gao.terr_group_account_id
         from hz_relationships hzr,
              jtf_tty_named_accts nai,
              jtf_tty_terr_grp_accts gai,
              jtf_tty_named_accts nao,
              jtf_tty_terr_grp_accts gao
         where gao.named_account_id = nao.named_account_id
           and nao.party_id = hzr.object_id  -- these are the subsidiary parties
           and hzr.subject_table_name = 'HZ_PARTIES'
           and hzr.object_table_name = 'HZ_PARTIES'
           and hzr.relationship_code IN ( 'GLOBAL_ULTIMATE_OF',  'HEADQUARTERS_OF',  'DOMESTIC_ULTIMATE_OF', 'PARENT_OF'  )
           and hzr.status = 'A'
           and sysdate between hzr.start_date and nvl( hzr.end_date, sysdate)
           and hzr.subject_id = nai.party_id  -- this is the parent party
           and nai.named_account_id = gai.named_account_id
           and gai.terr_group_account_id = cl_terr_group_account_id
           -- subsidiaries that are owned by user
           and exists( select 'Y'
                        from jtf_tty_named_acct_rsc narsc ,
                             jtf_tty_my_resources_v repdn
                           --  jtf_tty_named_accts na,
                           --  jtf_tty_terr_grp_accts ga
                      where narsc.terr_group_account_id = gao.terr_group_account_id
                         -- and ga.named_account_id = na.named_account_id
                          and narsc.resource_id = repdn.resource_id
                          and narsc.rsc_group_id = repdn.group_id
                          and repdn.current_user_id = l_user_id );



    /* this cursor return the managers details for the logged in person group with respect to the
       effected resource */

 cursor c_groups_manager(cl_current_user_id number, cl_eff_resource_id number
) is
Select  mem.resource_id, mem.group_id, rol.role_code
  from jtf_rs_group_members  mem,
      jtf_rs_role_relations rlt,
      jtf_rs_roles_b rol,
      jtf_rs_group_members cgrpmem,
      jtf_rs_resource_extns crsc,
      jtf_rs_groups_denorm grpden
 where crsc.user_id = cl_current_user_id
  and crsc.resource_id = cgrpmem.resource_id
  and cgrpmem.delete_flag = 'N'
  and cgrpmem.group_id = mem.group_id
  and rlt.role_resource_type = 'RS_GROUP_MEMBER'
  and rlt.delete_flag = 'N'
  and sysdate >= rlt.start_date_active
  and ( rlt.end_date_active is null
            or
        sysdate <= rlt.end_date_active
      )
  and rlt.role_id = rol.role_id
  and rol.manager_flag = 'Y'
  and rlt.role_resource_id = mem.group_member_id
  and mem.delete_flag = 'N'
  and mem.group_id = grpden.parent_group_id
  and grpden.group_id  IN (  select grv1.group_id
                          from  jtf_rs_group_members grv1
                          where  grv1.resource_id =  cl_eff_resource_id );



BEGIN

    /***********************************************************
    ****   PHASE 0: API INTERNAL OPTIMIZATIONS
    ****       Populate G_AFFECT_PARTY_TBL with subsidiaries
    ****       if ASSIGN_SUBSIDIARIES has been selected for any resource
    ************************************************************/


    l_user     := fnd_global.USER_ID;
    l_login_id := fnd_global.LOGIN_ID;

    -- populate the resource_type record type for all salesreps
    -- bug 2726632
    IF G_ADD_SALESREP_TBL is not null THEN
        IF G_ADD_SALESREP_TBL.last > 0 THEN
            FOR d in G_ADD_SALESREP_TBL.first..G_ADD_SALESREP_TBL.last LOOP
                -- t_resource_id := G_ADD_SALESREP_TBL(d).resource_id;
                -- select resource_type into t_resource_type
                -- from jtf_rs_resources_vl
                -- where resource_id = t_resource_id;
                -- G_ADD_SALESREP_TBL(d).resource_type := t_resource_type;
                G_ADD_SALESREP_TBL(d).resource_type := 'RS_EMPLOYEE';

                OPEN c_groups_manager(l_user_id, G_ADD_SALESREP_TBL(d).resource_id);
                FETCH c_groups_manager INTO lp_mgr_resource_id, lp_mgr_group_id, lp_mgr_role_code;
                CLOSE c_groups_manager;

                G_ADD_SALESREP_TBL(d).mgr_resource_id := lp_mgr_resource_id;
                G_ADD_SALESREP_TBL(d).mgr_group_id := lp_mgr_group_id;
                G_ADD_SALESREP_TBL(d).mgr_role_code := lp_mgr_role_code;

            END LOOP;
        END IF;
    END IF;

    IF G_REM_SALESREP_TBL is not null THEN
        IF G_REM_SALESREP_TBL.last > 0 THEN
            FOR d in G_REM_SALESREP_TBL.first..G_REM_SALESREP_TBL.last LOOP
                -- t_resource_id := G_REM_SALESREP_TBL(d).resource_id;
                -- select resource_type into t_resource_type
                -- from jtf_rs_resources_vl
                -- where resource_id = t_resource_id;
                -- G_REM_SALESREP_TBL(d).resource_type := t_resource_type;
                G_REM_SALESREP_TBL(d).resource_type := 'RS_EMPLOYEE';

                OPEN c_groups_manager(l_user_id, G_REM_SALESREP_TBL(d).resource_id);
                FETCH c_groups_manager INTO lp_mgr_resource_id, lp_mgr_group_id, lp_mgr_role_code;
                CLOSE c_groups_manager;

                G_REM_SALESREP_TBL(d).mgr_resource_id := lp_mgr_resource_id;
                G_REM_SALESREP_TBL(d).mgr_group_id := lp_mgr_group_id;
                G_REM_SALESREP_TBL(d).mgr_role_code := lp_mgr_role_code;

            END LOOP;
        END IF;
    END IF;

    -- tag all incoming accounts as non-subsidiary record
    IF (G_AFFECT_PARTY_TBL is not null) THEN
    IF (G_AFFECT_PARTY_TBL.last > 0) THEN
        -- TAG the original inputs for affected parties
        FOR n in G_AFFECT_PARTY_TBL.first.. G_AFFECT_PARTY_TBL.last LOOP
            G_AFFECT_PARTY_TBL(n).attribute1 := 'N';
        END LOOP;
    END IF;
    END IF;

    -- do we need to subsidiary processing?
    l_find_subs := 'N';
    IF ((G_AFFECT_PARTY_TBL is not null) and (G_REM_SALESREP_TBL is not null)) THEN
    IF ((G_AFFECT_PARTY_TBL.last > 0) and (G_REM_SALESREP_TBL.last > 0)) THEN
        FOR m in G_REM_SALESREP_TBL.first.. G_REM_SALESREP_TBL.last LOOP
            IF G_REM_SALESREP_TBL(m).attribute1 = 'Y' THEN
                l_find_subs := 'Y';
                EXIT;
            END IF;
        END LOOP;
    END IF;
    END IF;
    IF ((G_AFFECT_PARTY_TBL is not null) and (G_ADD_SALESREP_TBL is not null)) THEN
    IF ((G_AFFECT_PARTY_TBL.last > 0) and (G_ADD_SALESREP_TBL.last > 0)) THEN
        FOR m in G_ADD_SALESREP_TBL.first.. G_ADD_SALESREP_TBL.last LOOP
            IF G_ADD_SALESREP_TBL(m).attribute1 = 'Y' THEN
                l_find_subs := 'Y';
                EXIT;
            END IF;
        END LOOP;
    END IF;
    END IF;

    -- subsidiary processing: add subsidiaries to G_AFFECT_PARTY_TBL
    IF l_find_subs = 'Y' THEN
        --dbms_output.put_line('l_find_subs = Y');
        -- we start on next index value.
        l_master_pty_last := G_AFFECT_PARTY_TBL.last;
        l_sub_pty_index := G_AFFECT_PARTY_TBL.last + 1;

        FOR p in G_AFFECT_PARTY_TBL.first.. l_master_pty_last LOOP
            FOR c_sub in c_subsidiaries(G_AFFECT_PARTY_TBL(p).terr_group_account_id) LOOP
                G_AFFECT_PARTY_TBL.extend;

                G_AFFECT_PARTY_TBL(l_sub_pty_index).terr_group_account_id := c_sub.terr_group_account_id;
                G_AFFECT_PARTY_TBL(l_sub_pty_index).attribute1 := 'Y';
                l_sub_pty_index := l_sub_pty_index + 1;

            END LOOP;
        END LOOP;

    END IF;  -- l_find_subs = 'Y' ?

    /***********************************************************
    ****   PHASE I: DATAMODEL MODIFICATIONS
    ****       Changes made only to JTF_TTY_NAMED_ACCT_RSC
    ****                            JTF_TTY_ACCT_RSC_DN
    ************************************************************/
    --dbms_output.put_line('PHASE I ');

    ---------------------------------------------
    -- ADDING RESOURCES TO SALES TEAM
    ---------------------------------------------
    IF ((G_AFFECT_PARTY_TBL is not null) and (G_ADD_SALESREP_TBL is not null)) THEN
    IF ((G_AFFECT_PARTY_TBL.last > 0) and (G_ADD_SALESREP_TBL.last > 0)) THEN

        FOR j in G_AFFECT_PARTY_TBL.first.. G_AFFECT_PARTY_TBL.last LOOP
            --dbms_output.put_line('Adding Resources to: G_AFFECT_PARTY_TBL =' || j || G_AFFECT_PARTY_TBL(j).party_id);

            -- each named account exists in context of a territory group for resource
            l_terr_group_account_id      := G_AFFECT_PARTY_TBL(j).terr_group_account_id;

            FOR i in G_ADD_SALESREP_TBL.first.. G_ADD_SALESREP_TBL.last LOOP
                --dbms_output.put_line('Resource being Added: G_ADD_SALESREP_TBL =' || i || G_ADD_SALESREP_TBL(i).resource_id);

                IF ((G_ADD_SALESREP_TBL(i).attribute1 = 'Y') OR
                    (G_ADD_SALESREP_TBL(i).attribute1 = 'N' and G_AFFECT_PARTY_TBL(j).attribute1 = 'N')
                   )
                THEN

                    lp_resource_id   := G_ADD_SALESREP_TBL(i).resource_id;
                    lp_group_id      := G_ADD_SALESREP_TBL(i).group_id;
                    lp_role_code     := G_ADD_SALESREP_TBL(i).role_code;
                    lp_resource_type := G_ADD_SALESREP_TBL(i).resource_type;
                    lp_mgr_resource_id   := G_ADD_SALESREP_TBL(i).mgr_resource_id;

                    -- method of processing depends on whether resource is the user.  Bug: 2816957
                    if lp_mgr_resource_id = lp_resource_id then
                        -- DOES RECORD PROCESSED EXIST?  Bug: 2729383
                        select count(*) into l_acct_rsc_exist_count
                        from (
                                select account_resource_id
                                from jtf_tty_named_acct_rsc
                                where resource_id = lp_resource_id
                                  and rsc_group_id = lp_group_id
                                  and rsc_role_code = lp_role_code
                                  and terr_group_account_id = l_terr_group_account_id
                                  and assigned_flag = 'Y' -- still need a Y assign flag on NA/RSC to abort addition.
                                  and rownum < 2
                          );
                    else
                        -- DOES RECORD PROCESSED EXIST?  Bug: 2729383
                        select count(*) into l_acct_rsc_exist_count
                        from (
                                select account_resource_id
                                from jtf_tty_named_acct_rsc
                                where resource_id = lp_resource_id
                                  and rsc_group_id = lp_group_id
                                  and rsc_role_code = lp_role_code
                                  and terr_group_account_id = l_terr_group_account_id
                                  -- and assigned_flag = 'Y' bug 2803830
                                  and rownum < 2
                          );

                    end if;


                    -- DOES RECORD TO BE PROCESSED EXIST?
                    IF l_acct_rsc_exist_count = 0 THEN

                        --is user resource_id a leaf node in hierarchy?
                        l_resource_id_is_leaf := 'Y';
                        FOR crd IN c_rsc_owned_grps(lp_resource_id, lp_group_id) LOOP
                            l_resource_id_is_leaf := 'N';
                            EXIT;
                        END LOOP; -- c_rsc_directs

                        -- set l_assign_flag for account
                        IF (   (lp_resource_id = lp_mgr_resource_id)
                            OR (l_resource_id_is_leaf = 'Y'))
                        THEN l_assign_flag := 'Y';
                        ELSE l_assign_flag := 'N';
                        END IF;

                        -- test if record already exists for this rsc/grp/role with assign Y


                        -- insert into jtf_tty_named_acct_rsc
                        select jtf_tty_named_acct_rsc_s.nextval into new_seq_acct_rsc_id
                        from dual;

                        --dbms_output.put_line('inserting to jtf_tty_named_acct_rsc ');
                        --dbms_output.put_line(' ' || ' //new_seq_acct_rsc_id=' || new_seq_acct_rsc_id ||
                        --' //l_terr_group_account_id=' || l_terr_group_account_id ||' //lp_resource_id=' ||
                        --      lp_resource_id      ||' //lp_group_id=' ||         lp_group_id
                        --||       l_assign_flag        ||' //lp_resource_type=' ||    lp_resource_type );

                        -- assigned flag Y because user is assigning this individual, may be himself.
                        insert into jtf_tty_named_acct_rsc (
                            account_resource_id,
                            object_version_number,
                            terr_group_account_id,
                            resource_id,
                            rsc_group_id,
                            rsc_role_code,
                            assigned_flag,
                            rsc_resource_type,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date
                          )
                        VALUES (
                            new_seq_acct_rsc_id,     --account_resource_id,
                            2,                       --object_version_number
                            l_terr_group_account_id, --terr_group_account_id
                            lp_resource_id,          --resource_id,
                            lp_group_id,             --rsc_group_id,
                            lp_role_code,            --rsc_role_code,
                            l_assign_flag,           --assigned_flag,
                            lp_resource_type,        --rsc_resource_type
                            1,                        --created_by
                            sysdate,                  --creation_date
                            1,                       --last_updated_by
                            sysdate                  --last_update_date
                        );

                        -- if user exists as an account resource w/assign_flag = N then
                        -- delete user for this account from JTF_TTY_NAMED_ACCT_RSC
                        --dbms_output.put_line('deleting from JTF_TTY_NAMED_ACCT_RSC:' || '//lp_group_id:'
                        --|| lp_group_id ||'//p_role_code:' ||lp_role_code ||'//l_terr_group_account_id:'
                        --||l_terr_group_account_id || '//lp_user_resource_id:' || lp_user_resource_id);
                        -- Bug: 2726632
                        -- Bug: 2732533

                        /* JRADHAKR: Inserting values to jtf_tty_named_acct_changes table for GTP
                           to do an incremental and Total Mode */

                        select jtf_tty_named_acct_changes_s.nextval
                          into l_change_id
                          from sys.dual;

                        insert into jtf_tty_named_acct_changes
                        (   NAMED_ACCT_CHANGE_ID
                          , OBJECT_VERSION_NUMBER
                          , OBJECT_TYPE
                          , OBJECT_ID
                          , CHANGE_TYPE
                          , FROM_WHERE
                          , CREATED_BY
                          , CREATION_DATE
                          , LAST_UPDATED_BY
                          , LAST_UPDATE_DATE
                          , LAST_UPDATE_LOGIN
                        )
                        VALUES (
                          l_change_id
                          , 1
                          , 'TGA'
                          , l_terr_group_account_id
                          , 'UPDATE'
                          , 'UPDATE SALES TEAM'
                          , l_user
                          , sysdate
                          , l_user
                          , sysdate
                          , l_login_id
                        );

                        delete from jtf_tty_named_acct_rsc
                        where 1=1
                          --and rsc_group_id = lp_group_id
                          --and rsc_role_code = lp_role_code
                          and terr_group_account_id = l_terr_group_account_id
                          and resource_id = lp_mgr_resource_id
                          and assigned_flag = 'N';

                     END IF; -- DOES RECORD TO BE PROCESSED EXIST?

                END IF; -- process this? (subsidiary logic)

            END LOOP;  -- G_ADD_SALESREP_TBL

        END LOOP;  -- LOOP G_AFFECT_PARTY_TBL

    END IF; --((G_AFFECT_PARTY_TBL.last > 0) and (G_ADD_SALESREP_TBL.last > 0))
    END IF; --((G_AFFECT_PARTY_TBL is not null) and (G_ADD_SALESREP_TBL is not null))


    ---------------------------------------------
    -- REMOVING RESOURCES IN SALES TEAM
    ---------------------------------------------
    -- Delete resource being removed from account (ALONG WITH ALL HIS DIRECTS)
    IF ((G_AFFECT_PARTY_TBL is not null) and (G_REM_SALESREP_TBL is not null)) THEN
    IF ((G_AFFECT_PARTY_TBL.last > 0) and (G_REM_SALESREP_TBL.last > 0)) THEN

        FOR j in G_AFFECT_PARTY_TBL.first.. G_AFFECT_PARTY_TBL.last LOOP
            --dbms_output.put_line('G_AFFECT_PARTY_TBL ' || j || G_AFFECT_PARTY_TBL(j).party_id);

            -- each named account exists in context of a territory group for resource
            l_terr_group_account_id      := G_AFFECT_PARTY_TBL(j).terr_group_account_id;

            /* JRADHAKR: Inserting values to jtf_tty_named_acct_changes table for GTP
               to do an incremental and Total Mode */

            select jtf_tty_named_acct_changes_s.nextval
              into l_change_id
              from sys.dual;

            insert into jtf_tty_named_acct_changes
            (   NAMED_ACCT_CHANGE_ID
              , OBJECT_VERSION_NUMBER
              , OBJECT_TYPE
              , OBJECT_ID
              , CHANGE_TYPE
              , FROM_WHERE
              , CREATED_BY
              , CREATION_DATE
              , LAST_UPDATED_BY
              , LAST_UPDATE_DATE
              , LAST_UPDATE_LOGIN
            )
            VALUES (
              l_change_id
              , 1
              , 'TGA'
              , l_terr_group_account_id
              , 'UPDATE'
              , 'UPDATE SALES TEAM'
              , l_user
              , sysdate
              , l_user
              , sysdate
              , l_login_id
            );

            FOR i in G_REM_SALESREP_TBL.first.. G_REM_SALESREP_TBL.last LOOP
                --dbms_output.put_line('G_REM_SALESREP_TBL ' || i || G_REM_SALESREP_TBL(i).resource_id);

                IF ((G_REM_SALESREP_TBL(i).attribute1 = 'Y') OR
                    (G_REM_SALESREP_TBL(i).attribute1 = 'N' and G_AFFECT_PARTY_TBL(j).attribute1 = 'N')
                   )
                THEN
                    lp_resource_id   := G_REM_SALESREP_TBL(i).resource_id;
                    lp_group_id      := G_REM_SALESREP_TBL(i).group_id;
                    lp_role_code     := G_REM_SALESREP_TBL(i).role_code;
                    lp_resource_type := G_REM_SALESREP_TBL(i).resource_type;
                    lp_mgr_resource_id   := G_REM_SALESREP_TBL(i).mgr_resource_id;

                    -- delete resource to be removed from sales team
                    --dbms_output.put_line('DELETING FROM jtf_tty_named_acct_rsc ');
                    --dbms_output.put_line(' ' ||
                    --    ' //l_terr_group_account_id=' || l_terr_group_account_id ||
                    --    ' //lp_resource_id=' ||      lp_resource_id      ||
                    --    ' //lp_group_id=' ||         lp_group_id           ||
                    --    ' //lp_role_code=' ||        lp_role_code          || '//');

                    delete from jtf_tty_named_acct_rsc
                    where rsc_group_id = lp_group_id
                      and rsc_role_code = lp_role_code
                      and terr_group_account_id = l_terr_group_account_id
                      and resource_id = lp_resource_id;



                    -- if no one in user's hierarhy is assigned to this account
                    -- after this delete, add user to this account

                    -- if no one in user's hierarhy is assigned to this account
                    -- after this delete, set assigned_to_direct_flag to 'N' for user's NA

                    -- ACHANDA : bug 3265188 : change the IN clause to EXISTS to improve performance


                    select count(*) INTO l_directs_on_account
                    from jtf_tty_named_acct_rsc ar
                    where ar.terr_group_account_id = l_terr_group_account_id
                    and exists (
                                 select 1
                                 from jtf_tty_my_resources_v grv
                                    , jtf_rs_groups_denorm grpd
                                 WHERE ar.resource_id = grv.resource_id
                                 and   grpd.parent_group_id = grv.parent_group_id
                                 and   exists (
                                                select 1
                                                from  jtf_rs_group_members grv1
                                                where  grpd.group_id = grv1.group_id
                                                and    grv1.resource_id = lp_resource_id )
                                 and grv.CURRENT_USER_ID = l_user_id )
                    and rownum < 2;

                    --dbms_output.put_line('l_directs_on_account =  ' || l_directs_on_account);

                    IF l_directs_on_account = 0 THEN
                        select jtf_tty_named_acct_rsc_s.nextval into new_seq_acct_rsc_id
                        from dual;

                        lp_mgr_group_id      := G_REM_SALESREP_TBL(i).mgr_group_id;
                        lp_mgr_role_code     := G_REM_SALESREP_TBL(i).mgr_role_code;

                        -- assigned flag N because user did not assign himself.
                        -- It is an auto assign to user when none of his directs are assigned.
                        insert into jtf_tty_named_acct_rsc (
                            account_resource_id,
                            object_version_number,
                            terr_group_account_id,
                            resource_id,
                            rsc_group_id,
                            rsc_role_code,
                            assigned_flag,
                            rsc_resource_type,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date
                          )
                        VALUES (
                            new_seq_acct_rsc_id,     --account_resource_id,
                            2,                       --object_version_number
                            l_terr_group_account_id, --terr_group_account_id
                            lp_mgr_resource_id,      --resource_id,
                            lp_mgr_group_id,         --rsc_group_id,
                            lp_mgr_role_code,        --rsc_role_code,
                            'N',                     --assigned_flag,
                            lp_user_resource_type,   --rsc_resource_type
                            1,                       --created_by
                            sysdate,                 --creation_date
                            1,                       --last_updated_by
                            sysdate                  --last_update_date
                        );




                    END IF;  --l_directs_on_account = 0?

                    -- LOOP THROUGH ALL SUBORDINATES OF THIS RESOURCE_ID
                    -- remove all directs of this rem_resource_id from account
                    -- this cursor does not include lp_resource_id itself.

                    --bug 2828011: do not remove directs if user removing self.
                    IF lp_mgr_resource_id <> lp_resource_id THEN

                        FOR crd IN c_rsc_directs(lp_resource_id, lp_group_id) LOOP
                            -- delete subordinates from JTF_TTY_NAMED_ACCT_RSC
                            DELETE FROM JTF_TTY_NAMED_ACCT_RSC
                            WHERE rsc_role_code = lp_role_code
                              AND terr_group_account_id = l_terr_group_account_id
                              AND resource_id = crd.resource_id;


                        END LOOP; -- c_rsc_directs

                    END IF;  -- lp_user_resource_id <> lp_resource_id ?

                END IF;  -- process this? (subsidiary logic)

            END LOOP; -- G_REM_SALESREP_TBL

        END LOOP; -- G_AFFECT_PARTY_TBL

    END IF; --  ((G_AFFECT_PARTY_TBL.last > 0) and (G_REM_SALESREP_TBL.last > 0))
    END IF; --  ((G_AFFECT_PARTY_TBL is not null) and (G_REM_SALESREP_TBL is not null))




    /***********************************************************
    ****   PHASE II: PROCESS OTHER TABLES
    ****       Changes made only to JTF_TTY_RSC_ACCT_SUMM
    ****                            JTF_TTY_TERR_GRP_ACCTS
    ************************************************************/
    --dbms_output.put_line('PHASE II ');


    ---------------------------------------------
    -- PROCESS JTF_TTY_RSC_ACCT_SUMM
    ---------------------------------------------
    IF (G_AFFECT_PARTY_TBL is not null) THEN
    IF (G_AFFECT_PARTY_TBL.last > 0) THEN


        ---------------------------------------------
        -- PROCESS JTF_TTY_TERR_GRP_ACCTS
        ---------------------------------------------
        FOR i in G_AFFECT_PARTY_TBL.first.. G_AFFECT_PARTY_TBL.last LOOP
            ----dbms_output.put_line('G_AFFECT_PARTY_TBL ' || i || G_AFFECT_PARTY_TBL(j).party_id);

            -- each named account exists in context of a territory group for resource
            l_terr_group_account_id      := G_AFFECT_PARTY_TBL(i).terr_group_account_id;

            -- set l_assigned_rsc_exists:0 if no assigned rsc exists, 1 otherwise
            select count(*) into l_assigned_rsc_exists
            from jtf_tty_named_acct_rsc
            where terr_group_account_id = l_terr_group_account_id
              and assigned_flag = 'Y'
              and rownum < 2;

            If l_assigned_rsc_exists = 0 then
                l_assign_flag := 'N';
            else
                l_assign_flag := 'Y';
            end if;

            UPDATE JTF_TTY_TERR_GRP_ACCTS
            SET DN_JNR_ASSIGNED_FLAG = l_assign_flag
            WHERE TERR_GROUP_ACCOUNT_ID = l_terr_group_account_id;

        END LOOP; -- G_AFFECT_PARTY_TBL

    END IF; -- (G_AFFECT_PARTY_TBL.last > 0)
    END IF; -- (G_AFFECT_PARTY_TBL is not null)

/* Start update jtf_terr_rsc_all  */

    BEGIN

       FOR i IN G_AFFECT_PARTY_TBL.first.. G_AFFECT_PARTY_TBL.last LOOP

            SELECT terr_group_id INTO l_terr_group_id
            FROM jtf_tty_terr_grp_accts
            WHERE terr_group_account_id = G_AFFECT_PARTY_TBL(i).terr_group_account_id;

                 Jtf_Tty_Gen_Terr_Pvt.update_terr_rscs_for_na
                               (G_AFFECT_PARTY_TBL(i).terr_group_account_id,
                                l_terr_group_id);


       END LOOP;

       EXCEPTION WHEN OTHERS
              THEN NULL;
     END;

END UPDATE_SALES_TEAM;

END JTF_TTY_NACCT_SALES_PUB;

/
