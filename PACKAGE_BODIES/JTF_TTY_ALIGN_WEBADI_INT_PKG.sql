--------------------------------------------------------
--  DDL for Package Body JTF_TTY_ALIGN_WEBADI_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_ALIGN_WEBADI_INT_PKG" AS
/* $Header: jtftyawb.pls 120.0 2005/06/02 18:22:02 appldev ship $ */
-- ===========================================================================+
-- |               Copyright (c) 1999 Oracle Corporation                       |
-- |                  Redwood Shores, California, USA                          |
-- |                       All rights reserved.                                |
-- +===========================================================================
--    Start of Comments
--    ---------------------------------------------------
--    PURPOSE
--
--      This package is used to return a list of column in order of selectivity.
--      And create indices on columns in order of  input
--
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      05/02/2002    SHLI        Created
--      10/10/2003    SP          Modified for bug 3162073
--
--    End of Comments
--
-- *******************************************************
--    Start of Comments
-- *******************************************************



 procedure POPULATE_INTERFACE(         p_userid         in varchar2,
                                       p_align_id       in varchar2,
                                       p_init_flag      in varchar2,
                                       x_seq            out NOCOPY varchar2) IS


RESOURCE_NAME           VARRAY_TYPE:=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                                                 null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
GROUP_NAME              VARRAY_TYPE:=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                                                 null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
ROLE_NAME               VARRAY_TYPE:=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                                                 null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
--RESOURCE_ID             NARRAY_TYPE:=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
--L_GROUP_ID              NARRAY_TYPE:=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
--ROLE_CODE               VARRAY_TYPE:=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
--                                                 null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
COL_SOLT                -- NARRAY_TYPE:=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
                        VARRAY_TYPE:=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                                                 null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
--COL_RSC                 NARRAY_TYPE:=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
COL_USED                NARRAY_TYPE:=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
salesMgr                NUMBER;
SEQ     	            NUMBER;
ID	                    NUMBER;
l_dnb_annual_rev        VARCHAR2(30);
l_dnb_num_of_emp        VARCHAR2(30);
l_prior_won             VARCHAR2(30);
--NAMED_ACCOUNT	        VARCHAR2(360);
L_PARTY_ID                VARCHAR2(30);
SITE_TYPE	            VARCHAR2(80);
l_var1                  VARCHAR2(200);
l_var2                  VARCHAR2(200);
i                       NUMBER;
j                       NUMBER;
k                       NUMBER;
--l_na_sales              VARCHAR2(6000);
--l_al_sales              VARCHAR2(6000);
l_getAlignNamedAccount  VARCHAR2(6000);
--l_na_stats              VARCHAR2(6000);
--l_al_stats              VARCHAR2(6000);
l_align_id              VARCHAR2(30);

--l_rsc_4_na_owned_by_user_dir   VARCHAR2(6000);
--l_rsc_4_na_owned_by_indirect    VARCHAR2(6000);
--foundRsc  BOOLEAN := FALSE;

--TYPE RefCur IS REF CURSOR;  -- define weak REF CURSOR type
--nastat      RefCur;  -- declare cursor variable
--sales       RefCur;  -- declare cursor variable

/*
cursor getStatisticByNA (userid in number) IS
SELECT role_code, MAX(num) num
       FROM (
              SELECT  mydir.role_code role_code,
                      COUNT(role_code) num
              FROM
                 jtf_tty_my_directs_gt mydir,
                (
                    select terr_grp_acct_id
                    from  jtf_tty_webadi_interface
                    where user_id = userid
                ) tgaid_list
              WHERE
                   mydir.current_user_id       = userid
               and mydir.resource_id in (
                      select -- NO_MERGE
                            repmgr.parent_resource_id
                       from jtf_rs_rep_managers repmgr,
                            jtf_tty_named_acct_rsc narsc,
                            jtf_tty_terr_grp_accts ga
                      where narsc.resource_id           = repmgr.resource_id
                        and narsc.rsc_group_id          = repmgr.group_id
                        AND narsc.terr_group_account_id = ga.terr_group_account_id
                        AND ga.terr_group_account_id    = tgaid_list.terr_grp_acct_id
                    )

          GROUP BY tgaid_list.terr_grp_acct_id, role_code
          ORDER BY MAX(role_name)
         )
       GROUP BY role_code;
*/


cursor getStatisticByNA (userid in number) IS
 SELECT role_code, MAX(num) num
 FROM (
        SELECT  mydir.role_code role_code,  COUNT(mydir.role_code) num
          FROM ( select     distinct
                            tmp.terr_grp_acct_id,
                            repmgr.parent_resource_id resource_id,
                            grpmem.group_id group_id,
                            rol.role_code role_code
                      from  jtf_tty_webadi_interface tmp,
                            jtf_tty_named_acct_rsc narsc,
                            jtf_rs_rep_managers repmgr,
                            jtf_rs_role_relations rlt,
                            jtf_rs_roles_b rol,
                            jtf_rs_group_members grpmem,
                            jtf_tty_my_directs_gt dir
                      where narsc.resource_id          = repmgr.resource_id
                        and narsc.rsc_group_id          = repmgr.group_id
                        AND narsc.terr_group_account_id = tmp.terr_grp_acct_id
                        AND repmgr.par_role_relate_id  = rlt.role_relate_id
                        AND SYSDATE BETWEEN repmgr.start_date_active AND NVL(repmgr.end_date_active, SYSDATE+1)
                        AND rlt.role_id = rol.role_id
                        AND rlt.role_resource_type = 'RS_GROUP_MEMBER'
                        AND rlt.delete_flag = 'N'
                        AND SYSDATE BETWEEN rlt.start_date_active AND NVL(rlt.end_date_active, SYSDATE+1)
                        AND rlt.role_resource_id = grpmem.group_member_id
                        AND grpmem.delete_flag = 'N'
                        AND tmp.user_id = userid
                        AND dir.current_user_id  = userid
                        AND dir.dir_user_id  <> userid
                        AND dir.resource_id = repmgr.parent_resource_id
                        AND dir.group_id = grpmem.group_id
                        AND dir.role_code = rol.role_code
                        AND tmp.user_id = dir.current_user_id
                  UNION ALL
                  select
                            tmp.terr_grp_acct_id,
                            narsc.resource_id resource_id,
                            narsc.rsc_group_id group_id,
                            narsc.rsc_role_code role_code
                      from  jtf_tty_webadi_interface tmp,
                            jtf_tty_named_acct_rsc narsc,
                            jtf_tty_my_directs_gt dir
                      where narsc.terr_group_account_id = tmp.terr_grp_acct_id
                        AND dir.current_user_id    = userid
                        AND dir.dir_user_id        = userid
                        AND dir.resource_id = narsc.resource_id
                        AND dir.group_id = narsc.rsc_group_id
                        AND dir.role_code = narsc.rsc_role_code
                        AND tmp.user_id = userid
                        AND tmp.user_id = dir.current_user_id
                    ) mydir
          GROUP BY mydir.terr_grp_acct_id, mydir.role_code
    )
  GROUP BY role_code;



cursor getStatisticByAlign (userid in number, p_align_id in number) IS
  select role_code, MAX(num) num
        from (
        select ap.rsc_role_code role_code, count(ap.rsc_role_code) num
        from JTF_TTY_ALIGN_ACCTS aa,
             JTF_TTY_PTERR_ACCTS pa,
             JTF_TTY_ALIGN_PTERR ap
             -- jtf_rs_roles_vl rol
        where
               aa.alignment_id          = p_align_id
           and aa.align_acct_id         = pa.align_acct_id
           and pa.align_proposed_terr_id= ap.align_proposed_terr_id
           and ap.resource_type         = 'RS_EMPLOYEE'
           -- and rol.role_code            = ap.rsc_role_code
        group by aa.terr_group_account_id, ap.rsc_role_code
        -- ORDER BY MAX(rol.role_name)
        )
     group by role_code  ;


   cursor getNAFromInterface  IS
   SELECT jtf_tty_webadi_int_id, terr_grp_acct_id
   FROM jtf_tty_webadi_interface
   where user_id=p_userid;


 cursor na_sales(userid in number, tgaid in number)  IS
  -- No duplicate salesperson caused by rollup
  -- each dir in the view should appear once
   select   /* search directs */
            mydir.resource_name, --mydir.resource_id,
            mydir.group_name, --mydir.group_id,
            mydir.role_name, mydir.role_code
   FROM     jtf_tty_my_directs_gt /*jtf_tty_my_directs_v*/ mydir
            WHERE mydir.current_user_id     = userid
              and mydir.dir_user_id        <> userid
              and ( mydir.resource_id, mydir.group_id,  mydir.role_code) in
                   ( select /*+ NO_MERGE */
                            repmgr.parent_resource_id,
                            grpmem.group_id,
                            rol.role_code
                     from  jtf_tty_named_acct_rsc narsc,
                           jtf_rs_rep_managers repmgr,
                           jtf_rs_role_relations rlt,
                           jtf_rs_roles_b rol,
                           jtf_rs_group_members grpmem
                     where narsc.resource_id           = repmgr.resource_id
                       and narsc.rsc_group_id          = repmgr.group_id
                       AND narsc.terr_group_account_id = tgaid
                       AND repmgr.par_role_relate_id   = rlt.role_relate_id
                       AND SYSDATE BETWEEN repmgr.start_date_active AND NVL(repmgr.end_date_active, SYSDATE+1)
                       AND rlt.role_id = rol.role_id
                       AND rlt.role_resource_type = 'RS_GROUP_MEMBER'
                       AND rlt.delete_flag = 'N'
                       AND SYSDATE BETWEEN rlt.start_date_active AND NVL(rlt.end_date_active, SYSDATE+1)
                       AND rlt.role_resource_id = grpmem.group_member_id
                       AND grpmem.delete_flag = 'N'
                   )

    UNION  /* the user herself */
    SELECT
            mydir.resource_name ,--mydir.resource_id,
            mydir.group_name, --mydir.group_id,
            mydir.role_name, mydir.role_code
    FROM    jtf_tty_my_directs_gt /*jtf_tty_my_directs_v*/ mydir
            WHERE mydir.current_user_id    = userid
              and mydir.dir_user_id        = userid
              and ( mydir.resource_id, mydir.group_id,  mydir.role_code) in
                   ( select /*+ NO_MERGE */
                           narsc.resource_id, narsc.rsc_group_id, narsc.rsc_role_code
                     from  jtf_tty_named_acct_rsc narsc
                     where narsc.terr_group_account_id = tgaid
                   );


 /***********this squery is very slow, view needs tune *********/
 /* cursor na_sales(userid in number, tgaid in number)  IS
  select DISTINCT
            mydir.resource_name,
            mydir.group_name,
            mydir.role_name, mydir.role_code
   FROM
         jtf_tty_named_acct_rsc narsc,
         jtf_tty_terr_grp_accts ga,
         jtf_rs_rep_managers repmgr,
         jtf_tty_my_directs_v mydir
             WHERE narsc.resource_id           = repmgr.resource_id
               and narsc.rsc_group_id          = repmgr.group_id
               and repmgr.parent_resource_id   = mydir.resource_id
               and mydir.current_user_id       = userid
               AND narsc.terr_group_account_id = ga.terr_group_account_id
               AND ga.terr_group_account_id    = tgaid;
 */

 cursor al_sales(align_id in number, tgaid in number)  IS
     select rsc.resource_name, --ap.resource_id,
            grp.group_name,    --ap.rsc_group_id group_id,
            rol.role_name, ap.rsc_role_code role_code
     from JTF_TTY_ALIGN_ACCTS aa,
          JTF_TTY_PTERR_ACCTS pa,
          JTF_TTY_ALIGN_PTERR ap,
          jtf_rs_resource_extns_vl rsc,
          jtf_rs_groups_vl grp,
          jtf_rs_roles_vl rol
     where aa.terr_group_account_id     = tgaid
           and aa.alignment_id          = align_id
           and aa.align_acct_id         = pa.align_acct_id
           and pa.align_proposed_terr_id= ap.align_proposed_terr_id
           and ap.resource_type         = 'RS_EMPLOYEE'
           and rsc.resource_id          = ap.resource_id
           and grp.group_id             = ap.rsc_group_id
           and rol.role_code            = ap.rsc_role_code
     order by ap.rsc_role_code, rsc.resource_name ;



    BEGIN
 --delete from tmp;
 --insert into tmp values('1 start user_id=' || p_userid, to_char(sysdate,'HH:MI:SS'));commit;
    -- remove existing old data for this userid
    delete from JTF_TTY_WEBADI_INTERFACE
    where user_id = to_number(p_userid);
    -- and sysdate - creation_date >2;

    select jtf_tty_interface_s.nextval into SEQ from dual;

    begin
      select resource_id into salesMgr from jtf_rs_resource_extns
      where user_id = to_number(p_userid);

        exception
           when no_data_found then
            x_seq := '-100';
            return;
    end;


    /* build globle temp table */
       delete from jtf_tty_my_directs_gt;
       INSERT INTO jtf_tty_my_directs_gt
            (
             resource_id,
             resource_name,
             group_id,
             group_name,
             role_code,
             role_name,
             dir_user_id,
             current_user_id,
             parent_group_id,
             current_user_role_code,
             current_user_rsc_id
            )
            select
             resource_id,
             resource_name,
             group_id,
             group_name,
             role_code,
             role_name,
             dir_user_id,
             current_user_id,
             parent_group_id,
             current_user_role_code,
             current_user_rsc_id
             from jtf_tty_my_directs_v
             where CURRENT_USER_ID = to_number(p_userid);

            commit;

 --  insert into tmp values('1.5 '||l_var1, l_var2); commit;

 l_getAlignNamedAccount :=
      ' INSERT into JTF_TTY_WEBADI_INTERFACE  ' ||
      ' ( USER_SEQUENCE,USER_ID,TERR_GRP_ACCT_ID,JTF_TTY_WEBADI_INT_ID,NAMED_ACCOUNT,SITE_TYPE,TRADE_NAME,DUNS, '||
      '   GU_DUNS,GU_NAME,CITY,STATE,POSTAL_CODE,TERRITORY_GROUP, ALIGNMENT_ID, ' ||
      '   CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE ' ||
      '  ) ' ||
      ' SELECT ' ||
                    seq      ||  ' USER_SEQUENCE,'||
                    P_USERID ||  ' USER_ID,'||
      '             ga.terr_group_account_id gaid, '||
      '             na.named_account_id      naid, '||
      '             hzp.party_name    named_account, '||
      '             lkp.meaning       site_type, '||
      '             hzp.known_as      trade_name, '||
      '             hzp.duns_number_c site_duns, '||
      '             GU.GU_DUNS        gu_duns,  ' ||
      '             GU.GU_NAME        gu_name,  ' ||
      '             hzp.city          city, '||
      '             hzp.state         state, '||
      '             hzp.postal_code   postal_code, '||
      '             ttygrp.terr_group_name grpname, '||
                    P_ALIGN_ID || ' ALIGNMENT_ID,' ||
                    P_USERID || ' CREATED_BY,' ||
                    '''' || sysdate|| '''' || ' CREATION_DATE,' ||
                    P_USERID || ' LAST_UPDATED_BY,'
                    || '''' || sysdate || '''' || ' LAST_UPDATE_DATE '||
      '         from hz_parties hzp, '||
      '              jtf_tty_named_accts na, '||
      '              jtf_tty_terr_grp_accts ga, '||
      '              fnd_lookups  lkp, '||
      '              jtf_tty_terr_groups ttygrp '||
       '          , ( /* Global Ultimate */ ' ||
       '            SELECT min(gup.party_name) GU_NAME ' ||
       '                 , min(gup.duns_number_c) GU_DUNS ' ||
       '                 , hzr.object_id GU_OBJECT_ID ' ||
       '            FROM hz_parties  gup ' ||
       '               , hz_relationships hzr ' ||
       '            WHERE hzr.subject_table_name = ''HZ_PARTIES'' ' ||
       '              AND hzr.object_table_name  = ''HZ_PARTIES'' ' ||
       '              AND hzr.relationship_type  = ''GLOBAL_ULTIMATE'' ' ||
       '              AND hzr.relationship_code  = ''GLOBAL_ULTIMATE_OF'' ' ||
       '              AND hzr.status = ''A'' ' ||
       '              AND hzr.subject_id = gup.party_id ' ||
       '              AND gup.status = ''A'' ' ||
       '              group by hzr.object_id ) GU	 ' ||
      '         where hzp.party_id = na.party_id '||
      '               and na.site_type_code = lkp.lookup_code '||
      '               and lkp.lookup_type =   ''JTF_TTY_SITE_TYPE_CODE'' '||
      '               and na.named_account_id = ga.named_account_id '||
      '               and ttygrp.terr_group_id = ga.terr_group_id '||
      '               and ttygrp.active_from_date <= sysdate '||
      '               and ( ttygrp.active_to_date is null '||
      '                    or '||
      '                    ttygrp.active_to_date >= sysdate '||
      '                   ) '||
      '               and ga.terr_group_account_id IN '||
      '               (   select /*+ NO_MERGE */ narsc.terr_group_account_id '||
      '                  from jtf_tty_named_acct_rsc narsc, '||
      '                       jtf_tty_srch_my_resources_v repdn  '||
      '                  where narsc.resource_id = repdn.resource_id '||
      '                       and narsc.rsc_group_id = repdn.group_id  '||
      '                       and repdn.current_user_id = :p_userid '||
      '               )  '||
      '               AND GU.GU_OBJECT_ID (+) = hzp.party_id ';


-- l_na_sales :=
  /* remove duplicate salesperson caused by rollup */
             /* each dir in the view should appear once       */
/* '  select DISTINCT '||
 '           dir.resource_name, dir.resource_id, '||
 '           dir.group_name, dir.group_id, '||
 '           dir.role_name, dir.role_code '||
 '  FROM '||
 '        jtf_tty_named_acct_rsc narsc, '||
 '        jtf_tty_terr_grp_accts ga, '||
 '        jtf_rs_rep_managers repmgr, '||
 '        jtf_tty_my_directs_v mydir '||
 '            WHERE narsc.resource_id           = repmgr.resource_id '||
 '              and narsc.rsc_group_id          = repmgr.group_id '||
 '              and repmgr.parent_resource_id   = mydir.resource_id '||
 '              and mydir.current_user_id       = :0 '||
 '              AND narsc.terr_group_account_id = ga.terr_group_account_id '||
 '              AND ga.terr_group_account_id    = :1; ';
*/



 /* say Jogn's log in, Sheela and JK are assigned to a NA, JK shows in dir query,
   sheela rolls up to JK and JK shows in indir's query. Here we only want to see one JK instead of two.
   so union dir and indir query
 */
/*
l_na_sales :=
 --  l_rsc_4_na_owned_by_user_dir
 '  select '||
 '           dir.resource_name, dir.resource_id, '||
 '           dir.group_name, dir.group_id, '||
 '           dir.role_name, dir.role_code '||
 '    from '||
 '          jtf_tty_my_directs_v dir, '||
 '          jtf_tty_named_acct_rsc narsc, '||
 '          jtf_tty_terr_grp_accts ga '||
 '    where dir.current_user_id = :0 '||
 '      and dir.resource_id = narsc.resource_id '||
 '      and dir.role_code   = narsc.rsc_role_code '||
 '      and dir.group_id = narsc.rsc_group_id '||
 '      and narsc.terr_group_account_id =  ga.terr_group_account_id '||
 '      and narsc.rsc_resource_type = ''RS_EMPLOYEE'' '||
 '      and ga.terr_group_account_id = :1 '||
 '  order by dir.role_code, dir.resource_name ' ||
 ' UNION ' || -- union will remove duplicate.
 --l_rsc_4_na_owned_by_indirect
 '    select'||
 '         dir.resource_name, dir.resource_id,'||
 '         dir.group_name, dir.group_id, '||
 '         dir.role_name, dir.role_code '||
 '    from '||
 '          jtf_tty_my_directs_v dir '||
 '    where dir.current_user_id = :0 '||
 '      and dir.dir_user_id <> :1 '||
 '      and dir.resource_id IN ( select res.parent_resource_id '||
 '                                 from jtf_rs_rep_managers res, '||
 '                                      jtf_tty_named_acct_rsc narsc, '||
 '                                      jtf_tty_terr_grp_accts ga '||
 '                                where res.resource_id = narsc.resource_id '||
 '                                  and res.group_id    = narsc.rsc_group_id '||
 '                                  and res.role_code   = narsc.rsc_role_code '||
 '                                  and narsc.terr_group_account_id =  ga.terr_group_account_id '||
 '                                  and narsc.rsc_resource_type = ''RS_EMPLOYEE'' '||
 '                                  and ga.terr_group_account_id = :2 ) '||
 '  order by dir.role_code, dir.resource_name ';
*/




      /* Named accounts are from named accounts table, no matter what align_id is */
  --  insert into tmp values('2 start querying NA  l_getAlignNamedAccount=' || l_getAlignNamedAccount, to_char(sysdate,'HH:MI:SS'));commit;

       EXECUTE IMMEDIATE l_getAlignNamedAccount USING to_number(p_userid);
    COMMIT;

 --   insert into tmp values('3. start statis', to_char(sysdate,'HH:MI:SS'));commit;

    /* Nas are populated, now start collect sales*/
    /* populate slots */
    if p_init_flag='Y' or p_align_id is null then
        i:=1;
        for stat in getStatisticByNA(to_number(p_userid))
         LOOP
            if i+stat.num-1 <=30 then
              for k in i..i+stat.num-1
                loop
                  COL_SOLT(k) := stat.role_code;
                end loop;
            else  x_seq := '-1';
                  return;
            end if;
            i:=i+stat.num;
        END LOOP;

     else /* by alignment */
        i:=1;
        for stat in getStatisticByAlign(to_number(p_userid), to_number(p_align_id) )
         LOOP
            if i+stat.num-1 <=30 then
              for k in i..i+stat.num-1
                loop
                  COL_SOLT(k) := stat.role_code;
                end loop;
            else  x_seq := '-1';
                  return;
            end if;
            i:=i+stat.num;
        END LOOP;
      end if;

         /* for each NA_ID */
        --- insert into tmp values ( to_char(sysdate,'HH,MI:SS'), '4. finish analysis '); commit;

-- insert into tmp values('4 start update', to_char(sysdate,'HH:MI:SS'));commit;
        FOR m IN getNAFromInterface
        LOOP

         l_dnb_annual_rev:= null;
         l_dnb_num_of_emp:=null;
         l_prior_won:=null;



         begin
         select metric_value  into l_dnb_annual_rev
         from  JTF_TTY_ACCT_METRICS   am
         where m.JTF_TTY_WEBADI_INT_ID      = am.named_account_id
               and  am.metric_lookup_type    = 'JTF_TTY_ALIGN_METRICS'
               and  am.metric_lookup_code    = 'DNB_ANNUAL_REVENUE'
               and  rownum<2;

          exception
          when no_data_found then
               null;
          end;

         begin
         select metric_value into l_dnb_num_of_emp
         from JTF_TTY_ACCT_METRICS   am
         where m.JTF_TTY_WEBADI_INT_ID      = am.named_account_id
          and  am.metric_lookup_type    = 'JTF_TTY_ALIGN_METRICS'
          and  am.metric_lookup_code    = 'DNB_NUM_EMPLOYEES'
          and  rownum<2;
          exception
          when no_data_found then
               null;

         end;

         begin
         select metric_value into l_prior_won
         from JTF_TTY_ACCT_METRICS   am
         where m.JTF_TTY_WEBADI_INT_ID      = am.named_account_id
          and  am.metric_lookup_type    = 'JTF_TTY_ALIGN_METRICS'
          and  am.metric_lookup_code    = 'PRIOR_SALES'
          and  rownum<2;

          exception
          when no_data_found then
               null;

         end;


          /* clear col_used flags */
          COL_USED        :=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
          RESOURCE_NAME   :=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                                        null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
          GROUP_NAME      :=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                                        null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
          ROLE_NAME       :=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                                        null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);

          /* if there are some newly created NA, which is not part of align_account,
             those NA are valid and in the interface table but no rep in the align_account table.
             In this case, the salesrep is from named account resource table */
          /* for removed NA, are those taken care of in upload? */
          begin
          select alignment_id into l_align_id
          from jtf_tty_align_accts
          where terr_group_account_id = m.terr_grp_acct_id
               and alignment_id = p_align_id;

         exception
                when no_data_found then
                l_align_id:=null;
         end;


          /* get all sales for this NA */
        if p_init_flag='Y' or l_align_id is null then
          FOR SALES IN na_sales( to_number(p_userid), m.terr_grp_acct_id )
          LOOP

            --k:=0; -- not yet sloted
            FOR j in 1..30
            LOOP -- look into 30 slots
              if  SALES.role_code = COL_SOLT(j) and COL_USED(j)=0 then
                      COL_USED(j)     :=1;

                      RESOURCE_NAME(j):=SALES.resource_name;
                      GROUP_NAME(j)   :=SALES.group_name;
                      ROLE_NAME(j)    :=SALES.role_name;
                      exit;
              end if;
             END LOOP; -- of slotting
          END LOOP; -- of SALES
        else -- of p_init_flag='Y' or l_align_id is null
          FOR SALES IN al_sales( to_number(p_align_id), m.terr_grp_acct_id )
          LOOP

            --k:=0; -- not yet sloted
            FOR j in 1..30
            LOOP -- look into 30 slots
              if  SALES.role_code = COL_SOLT(j) and COL_USED(j)=0 then
                      COL_USED(j)     :=1;

                      RESOURCE_NAME(j):=SALES.resource_name;
                      GROUP_NAME(j)   :=SALES.group_name;
                      ROLE_NAME(j)    :=SALES.role_name;
                      exit;
              end if;
             END LOOP; -- of slotting
          END LOOP; -- of SALES

       end if; -- of p_init_flag='Y' or l_align_id is null

       --insert into tmp values('4.5 done with one salesrep', to_char(sysdate,'HH:MI:SS'));commit;

        update JTF_TTY_WEBADI_INTERFACE -- /*+ INDEX(JTF_TTY_WEBADI_INTF_N2) */
        set RESOURCE1_NAME=RESOURCE_NAME(1),GROUP1_NAME=GROUP_NAME(1),ROLE1_NAME=ROLE_NAME(1),
            RESOURCE2_NAME=RESOURCE_NAME(2),GROUP2_NAME=GROUP_NAME(2),ROLE2_NAME=ROLE_NAME(2),
            RESOURCE3_NAME=RESOURCE_NAME(3),GROUP3_NAME=GROUP_NAME(3),ROLE3_NAME=ROLE_NAME(3),
            RESOURCE4_NAME=RESOURCE_NAME(4),GROUP4_NAME=GROUP_NAME(4),ROLE4_NAME=ROLE_NAME(4),
            RESOURCE5_NAME=RESOURCE_NAME(5),GROUP5_NAME=GROUP_NAME(5),ROLE5_NAME=ROLE_NAME(5),
            RESOURCE6_NAME=RESOURCE_NAME(6),GROUP6_NAME=GROUP_NAME(6),ROLE6_NAME=ROLE_NAME(6),
            RESOURCE7_NAME=RESOURCE_NAME(7),GROUP7_NAME=GROUP_NAME(7),ROLE7_NAME=ROLE_NAME(7),
            RESOURCE8_NAME=RESOURCE_NAME(8),GROUP8_NAME=GROUP_NAME(8),ROLE8_NAME=ROLE_NAME(8),
            RESOURCE9_NAME=RESOURCE_NAME(9),GROUP9_NAME=GROUP_NAME(9),ROLE9_NAME=ROLE_NAME(9),
            RESOURCE10_NAME=RESOURCE_NAME(10),GROUP10_NAME=GROUP_NAME(10),ROLE10_NAME=ROLE_NAME(10),
            RESOURCE11_NAME=RESOURCE_NAME(11),GROUP11_NAME=GROUP_NAME(11),ROLE11_NAME=ROLE_NAME(11),
            RESOURCE12_NAME=RESOURCE_NAME(12),GROUP12_NAME=GROUP_NAME(12),ROLE12_NAME=ROLE_NAME(12),
            RESOURCE13_NAME=RESOURCE_NAME(13),GROUP13_NAME=GROUP_NAME(13),ROLE13_NAME=ROLE_NAME(13),
            RESOURCE14_NAME=RESOURCE_NAME(14),GROUP14_NAME=GROUP_NAME(14),ROLE14_NAME=ROLE_NAME(14),
            RESOURCE15_NAME=RESOURCE_NAME(15),GROUP15_NAME=GROUP_NAME(15),ROLE15_NAME=ROLE_NAME(15),
            RESOURCE16_NAME=RESOURCE_NAME(16),GROUP16_NAME=GROUP_NAME(16),ROLE16_NAME=ROLE_NAME(16),
            RESOURCE17_NAME=RESOURCE_NAME(17),GROUP17_NAME=GROUP_NAME(17),ROLE17_NAME=ROLE_NAME(17),
            RESOURCE18_NAME=RESOURCE_NAME(18),GROUP18_NAME=GROUP_NAME(18),ROLE18_NAME=ROLE_NAME(18),
            RESOURCE19_NAME=RESOURCE_NAME(19),GROUP19_NAME=GROUP_NAME(19),ROLE19_NAME=ROLE_NAME(19),
            RESOURCE20_NAME=RESOURCE_NAME(20),GROUP20_NAME=GROUP_NAME(20),ROLE20_NAME=ROLE_NAME(20),
            RESOURCE21_NAME=RESOURCE_NAME(21),GROUP21_NAME=GROUP_NAME(21),ROLE21_NAME=ROLE_NAME(21),
            RESOURCE22_NAME=RESOURCE_NAME(22),GROUP22_NAME=GROUP_NAME(22),ROLE22_NAME=ROLE_NAME(22),
            RESOURCE23_NAME=RESOURCE_NAME(23),GROUP23_NAME=GROUP_NAME(23),ROLE23_NAME=ROLE_NAME(23),
            RESOURCE24_NAME=RESOURCE_NAME(24),GROUP24_NAME=GROUP_NAME(24),ROLE24_NAME=ROLE_NAME(24),
            RESOURCE25_NAME=RESOURCE_NAME(25),GROUP25_NAME=GROUP_NAME(25),ROLE25_NAME=ROLE_NAME(25),
            RESOURCE26_NAME=RESOURCE_NAME(26),GROUP26_NAME=GROUP_NAME(26),ROLE26_NAME=ROLE_NAME(26),
            RESOURCE27_NAME=RESOURCE_NAME(27),GROUP27_NAME=GROUP_NAME(27),ROLE27_NAME=ROLE_NAME(27),
            RESOURCE28_NAME=RESOURCE_NAME(28),GROUP28_NAME=GROUP_NAME(28),ROLE28_NAME=ROLE_NAME(28),
            RESOURCE29_NAME=RESOURCE_NAME(29),GROUP29_NAME=GROUP_NAME(29),ROLE29_NAME=ROLE_NAME(29),
            RESOURCE30_NAME=RESOURCE_NAME(30),GROUP30_NAME=GROUP_NAME(30),ROLE30_NAME=ROLE_NAME(30),
            dnb_annual_rev=l_dnb_annual_rev,dnb_num_of_em=l_dnb_num_of_emp,prior_won=l_prior_won
          where user_id = p_userid
                 and TERR_GRP_ACCT_ID =m.TERR_GRP_ACCT_ID;

        END LOOP;
-- insert into tmp values('5 done', to_char(sysdate,'HH:MI:SS'));commit;
    commit;
    x_seq := to_char(seq);

 END;



/************************************************************************/
/*               UPLOAD                                             *****/
/************************************************************************/
PROCEDURE CALCULATE_ALIGN_METRICS(
      p_alignment_id          IN          NUMBER,
      p_user_id               IN          NUMBER,
      p_pterr_tbl             IN          NUMBER_TABLE_TYPE,
      p_all_pterr_flag        IN          VARCHAR2
  )
IS

CURSOR c_all_pterrs
IS
  SELECT AA.align_proposed_terr_id
    FROM JTF_TTY_ALIGN_PTERR AA
   WHERE AA.ALIGNMENT_ID = p_alignment_id;

l_align_pterrs_tbl Number_table_type := Number_table_type();
l_sysdate DATE;
l_alignment_id  NUMBER := 0;
l_user_id  NUMBER;

begin

   l_sysdate := SYSDATE;
   l_user_id := p_user_id;
   l_alignment_id := p_alignment_id;
   IF p_all_pterr_flag = 'Y'
   THEN
       OPEN c_all_pterrs;
       FETCH c_all_pterrs BULK COLLECT INTO l_align_pterrs_tbl;
       CLOSE c_all_pterrs;
   ELSE
       l_align_pterrs_tbl := p_pterr_tbl;
   END IF;

   FORALL y IN l_align_pterrs_tbl.FIRST .. l_align_pterrs_tbl.LAST
   delete from jtf_tty_pterr_metrics
    where align_proposed_terr_id = l_align_pterrs_tbl(y);

    --processing to insert into the JTF_TTY_PTERR_METRICS table: summ up metric values for the accounts owned by this rep
    FORALL j IN l_align_pterrs_tbl.FIRST .. l_align_pterrs_tbl.LAST
    insert into jtf_tty_pterr_metrics
    ( align_pterr_metric_id
     ,object_version_number
     ,align_proposed_terr_id
     ,metric_lookup_type
     ,metric_lookup_code
     ,metric_value
     ,metric_value_percent
     ,created_by
     ,creation_date
     ,last_updated_by
     ,last_update_date
     ,last_update_login
    )
    select
          jtf_tty_pterr_metrics_s.nextval
        , 1
        , l_align_pterrs_tbl(j)
        , 'JTF_TTY_ALIGN_METRICS'
        , 'DNB_ANNUAL_REVENUE'
        , pterr_list.metric_value
        , pterr_list.metric_pct
        , l_user_id
        , l_sysdate
        , l_user_id
        , l_sysdate
        , 1
      from ( select pa.align_proposed_terr_id pterr_id
                   ,sum(am.metric_value) metric_value
                   ,round( (sum(am.metric_value)/ alm.align_metric_val )* 100, 2 ) metric_pct
              from JTF_TTY_ACCT_METRICS AM,
                   jtf_tty_align_accts ac,
                   JTF_TTY_PTERR_ACCTS pa,
                   jtf_tty_terr_grp_accts ga,
                   jtf_tty_align_pterr ap,
                    ( select sum(ams.metric_value) align_metric_val
                        from  jtf_tty_acct_metrics ams
                             ,jtf_tty_terr_grp_accts tga
                             ,jtf_tty_align_accts  ala
                       where ala.alignment_id = l_alignment_id
                         and ala.terr_group_account_id = tga.terr_group_account_id
                         and tga.named_account_id = ams.named_account_id
                         and ams.metric_lookup_type = 'JTF_TTY_ALIGN_METRICS'
                         and ams.metric_lookup_code = 'DNB_ANNUAL_REVENUE'
                     ) alm
       where
             pa.align_proposed_terr_id = ap.align_proposed_terr_id
         and ap.alignment_id = l_alignment_id
         and pa.align_acct_id = ac.align_acct_id
         and ac.terr_group_account_id = ga.terr_group_account_id
         and ga.named_account_id = am.named_account_id
         and am.metric_lookup_type = 'JTF_TTY_ALIGN_METRICS'
         and am.metric_lookup_code = 'DNB_ANNUAL_REVENUE'
         and pa.align_proposed_terr_id = l_align_pterrs_tbl(j)
         and alm.align_metric_val > 0
         group by alm.align_metric_val, pa.align_proposed_terr_id
           )  pterr_list;

    FORALL j IN l_align_pterrs_tbl.FIRST .. l_align_pterrs_tbl.LAST
    insert into jtf_tty_pterr_metrics
    ( align_pterr_metric_id
     ,object_version_number
     ,align_proposed_terr_id
     ,metric_lookup_type
     ,metric_lookup_code
     ,metric_value
     ,metric_value_percent
     ,created_by
     ,creation_date
     ,last_updated_by
     ,last_update_date
     ,last_update_login
    )
    select
          jtf_tty_pterr_metrics_s.nextval
        , 1
        , l_align_pterrs_tbl(j)
        , 'JTF_TTY_ALIGN_METRICS'
        , 'DNB_NUM_EMPLOYEES'
        , pterr_list.metric_value
        , pterr_list.metric_pct
        , l_user_id
        , l_sysdate
        , l_user_id
        , l_sysdate
        , 1
      from ( select pa.align_proposed_terr_id pterr_id
                   ,sum(am.metric_value) metric_value
                   ,round( (sum(am.metric_value)/ alm.align_metric_val )* 100, 2 ) metric_pct
              from JTF_TTY_ACCT_METRICS AM,
                   jtf_tty_align_accts ac,
                   JTF_TTY_PTERR_ACCTS pa,
                   jtf_tty_terr_grp_accts ga,
                   jtf_tty_align_pterr ap,
                    ( select sum(ams.metric_value) align_metric_val
                        from  jtf_tty_acct_metrics ams
                             ,jtf_tty_terr_grp_accts tga
                             ,jtf_tty_align_accts  ala
                       where ala.alignment_id = l_alignment_id
                         and ala.terr_group_account_id = tga.terr_group_account_id
                         and tga.named_account_id = ams.named_account_id
                         and ams.metric_lookup_type = 'JTF_TTY_ALIGN_METRICS'
                         and ams.metric_lookup_code = 'DNB_NUM_EMPLOYEES'
                     ) alm
       where
             pa.align_proposed_terr_id = ap.align_proposed_terr_id
         and ap.alignment_id = l_alignment_id
         and pa.align_acct_id = ac.align_acct_id
         and ac.terr_group_account_id = ga.terr_group_account_id
         and ga.named_account_id = am.named_account_id
         and am.metric_lookup_type = 'JTF_TTY_ALIGN_METRICS'
         and am.metric_lookup_code = 'DNB_NUM_EMPLOYEES'
         and pa.align_proposed_terr_id = l_align_pterrs_tbl(j)
         and alm.align_metric_val > 0
         group by alm.align_metric_val, pa.align_proposed_terr_id
           )  pterr_list;

    FORALL j IN l_align_pterrs_tbl.FIRST .. l_align_pterrs_tbl.LAST
    insert into jtf_tty_pterr_metrics
    ( align_pterr_metric_id
     ,object_version_number
     ,align_proposed_terr_id
     ,metric_lookup_type
     ,metric_lookup_code
     ,metric_value
     ,metric_value_percent
     ,created_by
     ,creation_date
     ,last_updated_by
     ,last_update_date
     ,last_update_login
    )
    select
          jtf_tty_pterr_metrics_s.nextval
        , 1
        , l_align_pterrs_tbl(j)
        , 'JTF_TTY_ALIGN_METRICS'
        , 'NUM_ACCOUNTS'
        , pterr_list.metric_value
        , pterr_list.metric_pct
        , l_user_id
        , l_sysdate
        , l_user_id
        , l_sysdate
        , 1
      from (select pa.align_proposed_terr_id pterr_id
                   ,count(pa.align_acct_id) metric_value
                   ,round( (count(pa.align_acct_id)/ alm.tot_align_metric_val )* 100, 2 ) metric_pct
              from
                   JTF_TTY_PTERR_ACCTS pa,
                   jtf_tty_align_pterr ap,
                    ( select count(ala.terr_group_account_id) tot_align_metric_val
                        from  jtf_tty_align_accts  ala
                       where ala.alignment_id = l_alignment_id
                     ) alm
              where
                   pa.align_proposed_terr_id = ap.align_proposed_terr_id
               and ap.alignment_id = l_alignment_id
               and pa.align_proposed_terr_id = l_align_pterrs_tbl(j)
               and alm.tot_align_metric_val > 0
         group by alm.tot_align_metric_val, pa.align_proposed_terr_id
           ) pterr_list;

    FORALL j IN l_align_pterrs_tbl.FIRST .. l_align_pterrs_tbl.LAST
    insert into jtf_tty_pterr_metrics
    ( align_pterr_metric_id
     ,object_version_number
     ,align_proposed_terr_id
     ,metric_lookup_type
     ,metric_lookup_code
     ,metric_value
     ,metric_value_percent
     ,created_by
     ,creation_date
     ,last_updated_by
     ,last_update_date
     ,last_update_login
    )
    select
          jtf_tty_pterr_metrics_s.nextval
        , 1
        , l_align_pterrs_tbl(j)
        , 'JTF_TTY_ALIGN_METRICS'
        , 'PRIOR_SALES'
        , pterr_list.metric_value
        , pterr_list.metric_pct
        , l_user_id
        , l_sysdate
        , l_user_id
        , l_sysdate
        , 1
      from ( select pa.align_proposed_terr_id pterr_id
                   ,sum(am.metric_value) metric_value
                   ,round( (sum(am.metric_value)/ alm.align_metric_val )* 100, 2 ) metric_pct
              from JTF_TTY_ACCT_METRICS AM,
                   jtf_tty_align_accts ac,
                   JTF_TTY_PTERR_ACCTS pa,
                   jtf_tty_terr_grp_accts ga,
                   jtf_tty_align_pterr ap,
                    ( select sum(ams.metric_value) align_metric_val
                        from  jtf_tty_acct_metrics ams
                             ,jtf_tty_terr_grp_accts tga
                             ,jtf_tty_align_accts  ala
                       where ala.alignment_id = l_alignment_id
                         and ala.terr_group_account_id = tga.terr_group_account_id
                         and tga.named_account_id = ams.named_account_id
                         and ams.metric_lookup_type = 'JTF_TTY_ALIGN_METRICS'
                         and ams.metric_lookup_code = 'PRIOR_SALES'
                     ) alm
       where
             pa.align_proposed_terr_id = ap.align_proposed_terr_id
         and ap.alignment_id = l_alignment_id
         and pa.align_acct_id = ac.align_acct_id
         and ac.terr_group_account_id = ga.terr_group_account_id
         and ga.named_account_id = am.named_account_id
         and am.metric_lookup_type = 'JTF_TTY_ALIGN_METRICS'
         and am.metric_lookup_code = 'PRIOR_SALES'
         and pa.align_proposed_terr_id = l_align_pterrs_tbl(j)
         and alm.align_metric_val > 0
         group by alm.align_metric_val, pa.align_proposed_terr_id
           )  pterr_list;
end;


PROCEDURE UPDATE_ALIGNMENT_TEAM(
      p_api_version_number    IN          NUMBER,
      p_init_msg_list         IN         VARCHAR2,
      p_SQL_Trace             IN         VARCHAR2,
      p_Debug_Flag            IN         VARCHAR2,
      p_alignment_id          IN          NUMBER,
      p_user_id               IN          NUMBER,
      p_user_attribute1       IN          VARCHAR2,
      p_added_rscs_tbl        IN          JTF_TTY_NACCT_SALES_PUB.SALESREP_RSC_TBL_TYPE,
      p_removed_rscs_tbl      IN          JTF_TTY_NACCT_SALES_PUB.SALESREP_RSC_TBL_TYPE,
      p_affected_parties_tbl  IN          JTF_TTY_NACCT_SALES_PUB.AFFECTED_PARTY_TBL_TYPE,
      x_return_status         OUT  NOCOPY       VARCHAR2,
      x_msg_count             OUT  NOCOPY       NUMBER,
      x_msg_data              OUT  NOCOPY       VARCHAR2
  )
IS
l_align_acct_id NUMBER;
l_align_pterr_id NUMBER;
l_alignment_id NUMBER;
l_sysdate DATE;
l_imported_on DATE;
l_api_name  CONSTANT VARCHAR2(30) := 'UPDATE_ALIGNMENT_TEAM';
l_pterr_accts_num NUMBER;
l_count INTEGER := 0;
l_index INTEGER := 0;
l_found BOOLEAN := FALSE;
l_pterr_tbl_count INTEGER := 0;
l_user_id  NUMBER;

align_pterrs_tbl Number_table_type := Number_table_type();
all_tg_accts_tbl Number_table_type := Number_table_type();
all_align_accts_tbl Number_table_type := Number_table_type();
pterrs_changed_tbl  Number_table_type := Number_table_type();

cursor c_all_pterrs (c_align_acct_id NUMBER, c_alignment_id NUMBER ) IS
select AA.align_proposed_terr_id
  from JTF_TTY_ALIGN_PTERR AA,
       JTF_TTY_PTERR_ACCTS PA
 where AA.ALIGNMENT_ID = c_alignment_id
   and AA.ALIGN_PROPOSED_TERR_ID = PA.ALIGN_PROPOSED_TERR_ID
   and PA.ALIGN_ACCT_ID = c_align_acct_id ;

 cursor c_align_acct(c_terr_group_account_id NUMBER, c_alignment_id NUMBER ) IS
            select align_acct_id
              from JTF_TTY_ALIGN_ACCTS
             where terr_group_account_id = c_terr_group_account_id
               and alignment_id = c_alignment_id;

 cursor c_all_align_accts ( c_alignment_id NUMBER ) IS
         select align_acct_id, terr_group_account_id
           from JTF_TTY_ALIGN_ACCTS
          where alignment_id = c_alignment_id;

 cursor c_align_pterr(c_resource_id NUMBER, c_group_id NUMBER, c_role_code VARCHAR2,
                       c_alignment_id NUMBER ) IS
 select align_proposed_terr_id
   from JTF_TTY_ALIGN_PTERR
  where alignment_id = c_alignment_id
    and resource_id = c_resource_id
    and rsc_group_id = c_group_id
    and rsc_role_code = c_role_code;

 CURSOR c_all_tg_accounts( c_user_id NUMBER ) IS
 select ga.terr_group_account_id gaid
  from  jtf_tty_terr_grp_accts ga,
        jtf_tty_terr_groups ttygrp
  where ttygrp.terr_group_id = ga.terr_group_id
    and ttygrp.active_from_date <= sysdate
    and ( ttygrp.active_to_date is null
                  or
          ttygrp.active_to_date >= sysdate
         )
    and ga.terr_group_account_id IN
       (   select /*+ NO_MERGE */
                  narsc.terr_group_account_id
            from jtf_tty_named_acct_rsc narsc,
                 jtf_tty_srch_my_resources_v repdn
           where narsc.resource_id = repdn.resource_id
             and narsc.rsc_group_id = repdn.group_id
             and repdn.current_user_id = c_user_id
        );

 CURSOR c_res_for_tg_account(c_tg_acct_id VARCHAR2, c_user_id NUMBER ) IS
 select  narsc.resource_id resource_id,
         narsc.rsc_group_id group_id,
         narsc.rsc_role_code role_code
    from  jtf_tty_named_acct_rsc narsc
    where narsc.terr_group_account_id =  c_tg_acct_id
      and narsc.rsc_resource_type = 'RS_EMPLOYEE'
      and (narsc.resource_id, narsc.rsc_group_id, narsc.rsc_role_code ) IN
      ( select /*+ NO_MERGE */ mydir.resource_id, mydir.group_id, mydir.role_code
             from jtf_tty_srch_my_resources_v mydir
             where mydir.current_user_id = c_user_id );


  CURSOR c_direct_for_tg_account(c_tg_acct_id VARCHAR2, c_user_id  NUMBER) IS
   select mydir.resource_id resource_id,
          mydir.group_id group_id,
          mydir.role_code role_code
   from   jtf_tty_my_directs_v  mydir
   where  mydir.current_user_id = c_user_id
     and  mydir.dir_user_id <>  c_user_id
     and ( mydir.resource_id, mydir.group_id,  mydir.role_code) in
             ( select /*+ NO_MERGE */
                      repmgr.parent_resource_id,
                      grpmem.group_id,
                      rol.role_code
               from  jtf_tty_named_acct_rsc narsc,
                     jtf_rs_rep_managers repmgr,
                     jtf_rs_role_relations rlt,
                     jtf_rs_roles_b rol,
                     jtf_rs_group_members grpmem
               where narsc.resource_id           = repmgr.resource_id
                 AND narsc.rsc_group_id          = repmgr.group_id
                 AND narsc.terr_group_account_id = c_tg_acct_id
                 AND repmgr.par_role_relate_id   = rlt.role_relate_id
                 AND SYSDATE BETWEEN repmgr.start_date_active
                            AND NVL(repmgr.end_date_active, SYSDATE+1)
                 AND rlt.role_id = rol.role_id
                 AND rlt.role_resource_type = 'RS_GROUP_MEMBER'
                 AND rlt.delete_flag = 'N'
                 AND SYSDATE BETWEEN rlt.start_date_active
                            AND NVL(rlt.end_date_active, SYSDATE+1)
                 AND rlt.role_resource_id = grpmem.group_member_id
                 AND grpmem.delete_flag = 'N'
              );

begin

    l_alignment_id := p_alignment_id;
    l_sysdate := SYSDATE;

    --insert into tmp2 values('0.Start of UPDATE_ALIGNMENT_TEAM','Start of UPDATE_ALIGNMENT_TEAM'); commit;
    l_user_id := p_user_id;

    select imported_on
      into l_imported_on
      from jtf_tty_alignments
     where alignment_id = l_alignment_id;

     --Initial population of alignment datamodel if this is the first upload
     if l_imported_on is null then

       --populate JTF_TTY_ALIGN_ACCTS
       OPEN c_all_tg_accounts( c_user_id => l_user_id );
       FETCH c_all_tg_accounts BULK COLLECT INTO all_tg_accts_tbl;
       CLOSE c_all_tg_accounts;

       FORALL k IN all_tg_accts_tbl.FIRST .. all_tg_accts_tbl.LAST
       insert into JTF_TTY_ALIGN_ACCTS
               ( align_acct_id
                ,object_version_number
                ,alignment_id
                ,terr_group_account_id
                ,created_by
                ,creation_date
                ,last_updated_by
                ,last_update_date
                ,last_update_login
               ) values
               ( JTF_TTY_ALIGN_ACCTS_S.nextval
                ,1
                ,l_alignment_id
                ,all_tg_accts_tbl(k)
                ,G_USER
                ,l_sysdate
                ,G_USER
                ,l_sysdate
                ,G_LOGIN
                );

       all_tg_accts_tbl := null;
       OPEN c_all_align_accts(c_alignment_id => l_alignment_id );
       FETCH c_all_align_accts BULK COLLECT INTO all_align_accts_tbl, all_tg_accts_tbl;
       CLOSE c_all_align_accts;

       --insert into tmp2 values('10. b4 all_align_accts_tbl loop','b4 all_align_accts_tbl loop'); commit;
       FOR j in all_align_accts_tbl.FIRST .. all_align_accts_tbl.LAST
       LOOP
         --insert into tmp2 values('20. all_align_accts_tbl(j)', all_align_accts_tbl(j)); commit;
         --find the resources for this terr_group_account
         FOR res_rec in c_res_for_tg_account( c_tg_acct_id => all_tg_accts_tbl(j),
                                              c_user_id => l_user_id )
         LOOP
           --insert into tmp2 values('30. res_rec.resource_id, res_rec.group_id, res_rec.role_code', res_rec.resource_id || ' ' || res_rec.group_id || ' ' || res_rec.role_code); commit;
           --find the pterr associated with this resource
           l_found := FALSE;
           FOR align_rec in c_align_pterr(  c_resource_id => res_rec.resource_id
                                             , c_group_id => res_rec.group_id
                                            , c_role_code => res_rec.role_code
                                            , c_alignment_id => l_alignment_id)
           LOOP
           --insert into tmp2 values('40. insert into JTF_TTY_PTERR_ACCTS, align_rec.align_proposed_terr_id', align_rec.align_proposed_terr_id); commit;
           --populate JTF_TTY_PTERR_ACCTS
           insert into JTF_TTY_PTERR_ACCTS
              ( align_pterr_acct_id
               ,object_version_number
               ,align_proposed_terr_id
               ,align_acct_id
               ,created_by
               ,creation_date
               ,last_updated_by
               ,last_update_date
               ,last_update_login
              ) values
              ( JTF_TTY_PTERR_ACCTS_S.nextval
               ,1
               ,align_rec.align_proposed_terr_id
               ,all_align_accts_tbl(j)
               ,G_USER
               ,l_sysdate
               ,G_USER
               ,l_sysdate
               ,G_LOGIN
               );
               l_found := TRUE;
           --insert into tmp2 values('50. END OF: insert into JTF_TTY_PTERR_ACCTS, align_rec.align_proposed_terr_id', align_rec.align_proposed_terr_id); commit;
           END LOOP;
           IF ( NOT l_found )
           THEN
              /* Get all user's directs which have the resource in their hierarchy */
                FOR direct_rec IN c_direct_for_tg_account( c_tg_acct_id => all_tg_accts_tbl(j),
                                                           c_user_id => l_user_id  )
                LOOP
                     FOR align_pterr_rec in c_align_pterr(  c_resource_id => direct_rec.resource_id
                                             , c_group_id => direct_rec.group_id
                                            , c_role_code => direct_rec.role_code
                                            , c_alignment_id => l_alignment_id )
                     LOOP
                      --insert into tmp2 values('40. insert into JTF_TTY_PTERR_ACCTS, align_rec.align_proposed_terr_id', align_rec.align_proposed_terr_id); commit;
                      --populate JTF_TTY_PTERR_ACCTS

                         l_pterr_accts_num := 0;

                          select count(*)
                           into l_pterr_accts_num
                           from jtf_tty_pterr_accts
                           where align_proposed_terr_id = align_pterr_rec.align_proposed_terr_id
                             and align_acct_id = all_align_accts_tbl(j);

                          IF l_pterr_accts_num < 1
                          THEN
                              insert into JTF_TTY_PTERR_ACCTS
                              ( align_pterr_acct_id
                               ,object_version_number
                               ,align_proposed_terr_id
                               ,align_acct_id
                               ,created_by
                               ,creation_date
                               ,last_updated_by
                               ,last_update_date
                               ,last_update_login
                              ) values
                              ( JTF_TTY_PTERR_ACCTS_S.nextval
                                ,1
                                ,align_pterr_rec.align_proposed_terr_id
                                ,all_align_accts_tbl(j)
                                ,G_USER
                                ,l_sysdate
                                ,G_USER
                                ,l_sysdate
                                ,G_LOGIN
                               );
                          END IF;
           --insert into tmp2 values('50. END OF: insert into JTF_TTY_PTERR_ACCTS, align_rec.align_proposed_terr_id', align_rec.align_proposed_terr_id); commit;
                   END LOOP; -- end align_rec
                END LOOP;  -- end direct_rec
           END IF;  -- end not found
        END LOOP;  -- end res_rec
      END LOOP; -- end j

      calculate_align_metrics( l_alignment_id, l_user_id, align_pterrs_tbl, 'Y' );

     end if; --imported_on is null

    --update imported_on date for this alignment
    update jtf_tty_alignments
       set imported_on = l_sysdate
     where alignment_id = l_alignment_id;

    ---------------------------------------------
    -- ADDING RESOURCES TO ALIGN TEAM
    ---------------------------------------------


    IF ((p_affected_parties_tbl is not null) and (p_added_rscs_tbl is not null) and
        (p_affected_parties_tbl.last > 0) and (p_added_rscs_tbl.last > 0)) THEN

        FOR j in p_affected_parties_tbl.first .. p_affected_parties_tbl.last LOOP
            --dbms_output.put_line('Adding Resources to: G_AFFECT_PARTY_TBL =' || j || G_AFFECT_PARTY_TBL(j).party_id);
             --insert into tmp2 values('1.p_affected_parties_tbl.loop: TGA_ID =', p_affected_parties_tbl(j).terr_group_account_id); commit;

            OPEN c_align_acct(c_terr_group_account_id => p_affected_parties_tbl(j).terr_group_account_id,
                              c_alignment_id => l_alignment_id);
            FETCH c_align_acct into l_align_acct_id;

             --check to see if alignment account exists
             if c_align_acct%notfound then
             --
               --create a new alignment account record
               select JTF_TTY_ALIGN_ACCTS_S.nextval
                 into l_align_acct_id
                 from dual;

               --insert into tmp values('2. Create Align Account', l_align_acct_id); commit;
               insert into JTF_TTY_ALIGN_ACCTS
               ( align_acct_id
                ,object_version_number
                ,alignment_id
                ,terr_group_account_id
                ,created_by
                ,creation_date
                ,last_updated_by
                ,last_update_date
                ,last_update_login
               ) values
               ( l_align_acct_id
                ,1
                ,l_alignment_id
                ,p_affected_parties_tbl(j).terr_group_account_id
                ,G_USER
                ,l_sysdate
                ,G_USER
                ,l_sysdate
                ,G_LOGIN
                );
              --insert into tmp values('3. End of Create Align Account', l_align_acct_id); commit;
             end if;

             CLOSE c_align_acct;

            FOR i in p_added_rscs_tbl.first .. p_added_rscs_tbl.last LOOP
            --create new association between resource (pterr) and alignment account

            OPEN c_align_pterr(c_resource_id => p_added_rscs_tbl(i).resource_id
                                , c_group_id => p_added_rscs_tbl(i).group_id
                                , c_role_code => p_added_rscs_tbl(i).role_code
                                , c_alignment_id => l_alignment_id );

            FETCH c_align_pterr into l_align_pterr_id;

            --insert into tmp2 values('2. b4 create pterr. l_align_pterr_id =', l_align_pterr_id); commit;
            if c_align_pterr%notfound then
              --insert into tmp2 values('1.77775. b4 c_align_pterr. p_added_rscs_tbl(i).resource_id =', p_added_rscs_tbl(i).resource_id || ' ' || p_added_rscs_tbl(i).group_id || p_added_rscs_tbl(i).role_code); commit;
              -- create a proposed territory for this resource
              select JTF_TTY_ALIGN_PTERR_S.nextval
              into l_align_pterr_id
              from dual;

              insert into JTF_TTY_ALIGN_PTERR
              ( align_proposed_terr_id
               ,object_version_number
               ,alignment_id
               ,resource_id
               ,rsc_group_id
               ,rsc_role_code
               ,resource_type
               ,proposed_quota
               ,created_by
               ,creation_date
               ,last_updated_by
               ,last_update_date
               ,last_update_login
              ) values
              ( l_align_pterr_id
               ,1
               ,l_alignment_id
               ,p_added_rscs_tbl(i).resource_id
               ,p_added_rscs_tbl(i).group_id
               ,p_added_rscs_tbl(i).role_code
               ,'RS_EMPLOYEE'
               ,0
               ,G_USER
               ,l_sysdate
               ,G_USER
               ,l_sysdate
               ,G_LOGIN
               );
           end if;
           CLOSE c_align_pterr;

            --check if existing pterr is already associated with this account
            l_pterr_accts_num := 0;

            select count(*)
              into l_pterr_accts_num
              from jtf_tty_pterr_accts
             where align_proposed_terr_id = l_align_pterr_id
               and align_acct_id = l_align_acct_id
               and rownum < 2;

           if l_pterr_accts_num < 1
           then
            --insert into tmp2 values('3. b4 create pterr accts. l_align_pterr_id, l_align_acct_id =', l_align_pterr_id||' '||l_align_acct_id); commit;

            insert into JTF_TTY_PTERR_ACCTS
            ( align_pterr_acct_id
             ,object_version_number
             ,align_proposed_terr_id
             ,align_acct_id
             ,created_by
             ,creation_date
             ,last_updated_by
             ,last_update_date
             ,last_update_login
            ) values
            ( JTF_TTY_PTERR_ACCTS_S.nextval
             ,1
             ,l_align_pterr_id
             ,l_align_acct_id
             ,G_USER
             ,l_sysdate
             ,G_USER
             ,l_sysdate
             ,G_LOGIN
             );

            IF ( l_count = 0 )
            THEN
                l_count := l_count + 1;
                align_pterrs_tbl.EXTEND;
                align_pterrs_tbl(l_count) := l_align_pterr_id ;
            ELSE
               l_found := FALSE;

               FOR k IN align_pterrs_tbl.FIRST .. align_pterrs_tbl.LAST
               LOOP
                   IF align_pterrs_tbl(k) = l_align_pterr_id
                   THEN
                       l_found := TRUE;
                       exit;
                   END IF;
               END LOOP;
               IF ( NOT l_found )
               THEN
                   l_count := l_count + 1;
                   align_pterrs_tbl.EXTEND;
                   align_pterrs_tbl(l_count) := l_align_pterr_id ;
               END IF;
            END IF;  -- align_pterrs_tbl IS NULL
           end if;  -- if pterr_accts_num < 0
            END LOOP; --end of p_added_rscs_tbl
        END LOOP; --end p_affected_parties_tbl
    END IF; -- Adding resources


    ---------------------------------------------
    -- REMOVING RESOURCES IN SALES TEAM
    ---------------------------------------------
    IF ((p_affected_parties_tbl is not null) and (p_removed_rscs_tbl is not null) and
        (p_affected_parties_tbl.last > 0) and (p_removed_rscs_tbl.last > 0)) THEN

        FOR j in p_affected_parties_tbl.first .. p_affected_parties_tbl.last LOOP

            OPEN c_align_acct(c_terr_group_account_id => p_affected_parties_tbl(j).terr_group_account_id
                             , c_alignment_id => l_alignment_id );
            FETCH c_align_acct into l_align_acct_id;
            CLOSE c_align_acct;

              if l_align_acct_id is null then
                exit;
              end if;

           FOR i in p_removed_rscs_tbl.first .. p_removed_rscs_tbl.last LOOP

             OPEN c_align_pterr(c_resource_id => p_removed_rscs_tbl(i).resource_id
                                , c_group_id => p_removed_rscs_tbl(i).group_id
                                , c_role_code => p_removed_rscs_tbl(i).role_code
                                , c_alignment_id => l_alignment_id );

             l_align_pterr_id := null;
             FETCH c_align_pterr into l_align_pterr_id;
             CLOSE c_align_pterr;

               if l_align_pterr_id is null then
                exit;
               end if;

              delete from JTF_TTY_PTERR_ACCTS
               where align_proposed_terr_id = l_align_pterr_id
                 and align_acct_id = l_align_acct_id;

              IF SQL%ROWCOUNT > 0
              THEN
                  IF ( l_count = 0 )
                  THEN
                      l_count := l_count + 1;
                      align_pterrs_tbl.EXTEND;
                      align_pterrs_tbl(l_count) := l_align_pterr_id ;
                  ELSE
                      l_found := FALSE;
                      FOR k IN align_pterrs_tbl.FIRST .. align_pterrs_tbl.LAST
                      LOOP
                          IF align_pterrs_tbl(k) = l_align_pterr_id
                          THEN
                             l_found := TRUE;
                             exit;
                          END IF;
                      END LOOP;
                      IF ( NOT l_found )
                      THEN
                         l_count := l_count + 1;
                         align_pterrs_tbl.EXTEND;
                         align_pterrs_tbl(l_count) := l_align_pterr_id ;
                      END IF;
                  END IF;  -- align_pterrs_tbl IS NULL
              END IF;  -- SQL%ROWCOUNT > 0

           END LOOP; --end of p_removed_rscs_tbl

        END LOOP; -- end of p_affected_parties_tbl

    END IF; -- removing resources

  /*-----------------------------------------------
   -- BUG 3162073: REMOVING ANY ACCOUNTS IN ALIGNMENT THAT ARE NO LONGER OWNED BY USER.
   -- The previous remove will remove salespersons only for changed rows in excel.
   -- Since the accounts no longer owned by user do not show up in excel, we have
   -- to process them seperately
   -----------------------------------------------*/
   delete from jtf_tty_align_accts
    where alignment_id = l_alignment_id
      and terr_group_account_id NOT IN
          ( select ga.terr_group_account_id
              from jtf_tty_terr_grp_accts ga,
                   jtf_tty_terr_groups ttygrp
               where ttygrp.terr_group_id = ga.terr_group_id
                 and ttygrp.active_from_date <= sysdate
                 and ( ttygrp.active_to_date is null
                          or
                          ttygrp.active_to_date >= sysdate
                     )
                 and ga.terr_group_account_id IN
                   (   select /*+ NO_MERGE */ narsc.terr_group_account_id
                         from jtf_tty_named_acct_rsc narsc,
                              jtf_tty_srch_my_resources_v repdn
                        where narsc.resource_id = repdn.resource_id
                          and narsc.rsc_group_id = repdn.group_id
                          and repdn.current_user_id = l_user_id
                    )
              );

       delete from jtf_tty_pterr_accts
        where align_proposed_terr_id IN
                   ( select align_proposed_terr_id
                       from jtf_tty_align_pterr
                      where alignment_id = l_alignment_id )
          and align_acct_id NOT IN
                   ( select align_acct_id
                       from jtf_tty_align_accts
                       where alignment_id = l_alignment_id )
     returning align_proposed_terr_id BULK COLLECT INTO pterrs_changed_tbl;

     IF ( pterrs_changed_tbl IS NOT NULL ) AND ( pterrs_changed_tbl.COUNT > 0 )
     THEN
         FOR i IN pterrs_changed_tbl.FIRST .. pterrs_changed_tbl.LAST
         LOOP
             IF ( l_count = 0 )
             THEN
                l_count := l_count + 1;
                align_pterrs_tbl.EXTEND;
                align_pterrs_tbl(l_count) := pterrs_changed_tbl(i);
             ELSE
                 l_found := FALSE;
                 FOR k IN align_pterrs_tbl.FIRST .. align_pterrs_tbl.LAST
                 LOOP
                     IF ( align_pterrs_tbl(k) = pterrs_changed_tbl(i) )
                     THEN
                         l_found := TRUE;
                         exit;
                     END IF;
                 END LOOP;
                 IF ( NOT l_found )
                 THEN
                      l_count := l_count + 1;
                      align_pterrs_tbl.EXTEND;
                      align_pterrs_tbl(l_count) := l_align_pterr_id ;
                 END IF;
             END IF;  -- align_pterrs_tbl IS NULL
        END LOOP; -- end pterrs_changed_tbl LOOP
     END IF; -- pterrs_changed_tbl IS NULL

    ---------------------------------------------
    -- RE-CALCULATING PTERR METRICS FOR CHANGED PTERRS IN THE ALIGNMENT
    ---------------------------------------------

   IF ( align_pterrs_tbl IS NOT NULL ) AND ( align_pterrs_tbl.COUNT > 0 )
   THEN
        calculate_align_metrics( l_alignment_id, l_user_id, align_pterrs_tbl, 'N' );
   END IF;


    --commit processing
    --insert into tmp2 values('END B4 COMMIT', 'END B4 COMMIT'); commit;
 ----   COMMIT; ---- for bne.c


    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
           --insert into tmp2 values('WHEN NO_DATA_FOUND THEN NULL', 'WHEN NO_DATA_FOUND THEN NULL'); commit;
      WHEN OTHERS THEN
           --insert into tmp2 values('WHEN OTHERS THEN', 'WHEN OTHERS THEN'); commit;
           fnd_message.set_name ('JTF', 'JTF_TTY_ALIGN_UNEXPECTED_ERROR');
           x_msg_data := fnd_message.get();
           fnd_message.set_name ('JTF', x_msg_data);

end;


END JTF_TTY_ALIGN_WEBADI_INT_PKG;


/
