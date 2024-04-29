--------------------------------------------------------
--  DDL for Package Body JTF_TTY_ALIGN_ACTIVATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_ALIGN_ACTIVATE_PKG" AS
/* $Header: jtftralb.pls 120.0 2005/06/02 18:21:25 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_ALIGN_ACTIVATE_PKG
--    ---------------------------------------------------
--    PURPOSE
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      12/31/03    SPAI             Created
--
--      05/28/04    ACHANDA          fix bug # 3656850


g_pkg_name     CONSTANT     VARCHAR2(30) := 'JTF_TTY_ALIGN_ACTIVATE_PKG';

PROCEDURE Activate_Alignment
/*******************************************************************************
** Start of comments
**  Procedure   : Activate_Alignment
**  Description : Create named account assignments for the selected Territory Alignment.


**  Notes :
**
** End of comments
******************************************************************************/
( p_api_version_number IN NUMBER
, p_init_msg_list      IN VARCHAR2
, p_alignment_id       IN NUMBER
, p_user_id            IN NUMBER
, x_return_status     OUT NOCOPY VARCHAR2
, x_msg_count         OUT NOCOPY VARCHAR2
, x_msg_data          OUT NOCOPY VARCHAR2
)
IS
-- Cursor to find all the named accounts associated with this alignment
cursor c_all_accounts IS
select ALAC.TERR_GROUP_ACCOUNT_ID
from JTF_TTY_ALIGN_ACCTS ALAC
where
 ALAC.ALIGNMENT_ID = p_alignment_id;

cursor c_get_invalid_accts( c_alignment_id NUMBER, c_user_id  NUMBER) IS
SELECT 'Y'
  FROM jtf_tty_align_accts aa
WHERE  aa.alignment_id = c_alignment_id
  AND aa.terr_group_account_id NOT IN
       ( SELECT ga.terr_group_account_id
           FROM jtf_tty_terr_grp_accts ga,
                jtf_tty_terr_groups ttygrp,
                jtf_tty_named_acct_rsc narsc,
                jtf_tty_srch_my_resources_v repdn
          WHERE ttygrp.terr_group_id = ga.terr_group_id
            AND ttygrp.active_from_date <= sysdate
            AND ( ttygrp.active_to_date is null
                          or
                  ttygrp.active_to_date >= sysdate
                 )
            AND ga.terr_group_account_id = narsc.terr_group_account_id
            AND narsc.resource_id = repdn.resource_id
            AND narsc.rsc_group_id = repdn.group_id
            AND repdn.current_user_id = c_user_id
       );

cursor c_get_invalid_roles (c_alignment_id NUMBER )
IS
  SELECT 'Y'
   FROM jtf_tty_pterr_accts alpa
      , jtf_tty_align_pterr alpt
      , jtf_tty_align_accts alac
      , jtf_tty_terr_grp_accts tga
   WHERE alpt.align_proposed_terr_id = alpa.align_proposed_terr_id
      AND alpa.align_acct_id = alac.align_acct_id
      AND alac.terr_group_account_id = tga.terr_group_account_id
      AND alac.alignment_id = c_alignment_id
      AND NOT EXISTS ( SELECT 'Y'
                         FROM  jtf_tty_terr_grp_roles TGR
                        WHERE  tgr.role_code = alpt.rsc_role_code
                          AND tgr.terr_group_id = tga.terr_group_id
                    );


account_rsc_table account_rsc_table_type;

l_api_version_number  CONSTANT NUMBER       := 1.0;
l_api_name            CONSTANT VARCHAR2(30) := 'Activate_Alignment';
l_invalid_align_flag   VARCHAR2(1);
l_return_status      VARCHAR2(2);
l_invalid_align        EXCEPTION;
l_login_id           NUMBER ;


BEGIN
   --dbms_output.put_line('begin Activate_Alignment');

    l_invalid_align_flag := 'N';
    l_return_status      := 'S' ;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TTY_ALIGN_ACTIVATE_START');
        FND_MSG_PUB.Add;
    END IF;

    -- API body
    x_return_status := 'S' ;
    l_login_id := FND_GLOBAL.login_id;

    BEGIN
       OPEN  c_get_invalid_accts(c_alignment_id => p_alignment_id,
                                       c_user_id => p_user_id);
       FETCH c_get_invalid_accts INTO l_invalid_align_flag;
       CLOSE c_get_invalid_accts;

       IF ( l_invalid_align_flag = 'Y' )
       THEN
             l_return_status := 'IA';
             raise l_invalid_align;
       END IF;

    END;

    BEGIN
        l_invalid_align_flag := 'N' ;
       OPEN  c_get_invalid_roles(c_alignment_id => p_alignment_id );
       FETCH c_get_invalid_roles INTO l_invalid_align_flag;
       CLOSE c_get_invalid_roles;

       IF ( l_invalid_align_flag = 'Y' )
       THEN
             l_return_status := 'IR';
             raise l_invalid_align;
       END IF;

    END;

   OPEN c_all_accounts;
   FETCH c_all_accounts BULK COLLECT INTO account_rsc_table;
   CLOSE c_all_accounts;

   IF account_rsc_table.COUNT > 0
   THEN
   --dbms_output.put_line('delete from JTF_TTY_NAMED_ACCT_RSC');
   FORALL i IN account_rsc_table.FIRST .. account_rsc_table.LAST
   -- delete old resource assignments owned by the RM for this named account.
    delete from JTF_TTY_NAMED_ACCT_RSC NARS
    WHERE NARS.TERR_GROUP_ACCOUNT_ID = account_rsc_table(i)
      AND  (NARS.resource_id, NARS.rsc_group_id, NARS.rsc_role_code) IN (
                /* Salesperson directly/indirectly reports to user */
            SELECT dir.resource_id
                , grpmemo.group_id
                , rol.role_code
            FROM jtf_rs_roles_b    rol
               , jtf_rs_role_relations rlt
               , jtf_rs_group_members  grpmemo
               , jtf_rs_resource_extns dir
            WHERE ( rol.manager_flag = 'Y' or rol.member_flag = 'Y' )
              AND rlt.role_id = rol.role_id
              AND rlt.role_resource_type = 'RS_GROUP_MEMBER'
              AND rlt.delete_flag = 'N'
            	 AND SYSDATE BETWEEN rlt.start_date_active AND NVL(rlt.end_date_active, SYSDATE+1)
              AND rlt.role_resource_id = grpmemo.group_member_id
              AND grpmemo.delete_flag = 'N'
              AND grpmemo.resource_id  = dir.resource_id
              AND SYSDATE BETWEEN dir.start_date_active AND NVL(dir.end_date_active, SYSDATE+1)
              AND grpmemo.group_id IN ( SELECT  dv.group_id
                   FROM jtf_rs_group_usages usg
                      , jtf_rs_groups_denorm dv
                      , jtf_rs_rep_managers  sgh
                      , jtf_rs_resource_extns mrsc
                   WHERE usg.usage = 'SALES'
                     AND usg.group_id = dv.group_id
                    -- AND dv.immediate_parent_flag = 'Y'
                     AND dv.parent_group_id = sgh.group_id
                     AND SYSDATE BETWEEN NVL(dv.start_date_active, SYSDATE-1)
                                AND NVL(dv.end_date_active, SYSDATE+1)
                     AND SYSDATE BETWEEN sgh.start_date_active AND NVL(sgh.end_date_active, SYSDATE+1)
                     AND sgh.hierarchy_type IN ('MGR_TO_MGR')
                     AND sgh.resource_id = sgh.parent_resource_id
                     AND mrsc.resource_id = sgh.resource_id
                     AND mrsc.user_id = p_user_id  )
              )  ;

     --dbms_output.put_line('insert into jtf_tty_named_acct_rsc');
     FORALL j IN account_rsc_table.FIRST .. account_rsc_table.LAST
      insert into jtf_tty_named_acct_rsc
      (ACCOUNT_RESOURCE_ID,
       OBJECT_VERSION_NUMBER ,
       TERR_GROUP_ACCOUNT_ID,
       RESOURCE_ID ,
       RSC_GROUP_ID,
       RSC_ROLE_CODE,
       ASSIGNED_FLAG,
       RSC_RESOURCE_TYPE,
       CREATED_BY ,
       CREATION_DATE ,
       LAST_UPDATED_BY ,
       LAST_UPDATE_DATE ,
       LAST_UPDATE_LOGIN
      )
      select
       jtf_tty_named_acct_rsc_s.nextval
      , 2
      , ALAC.terr_group_account_id
      , ALPT.RESOURCE_ID
      , ALPT.RSC_GROUP_ID
      , ALPT.RSC_ROLE_CODE
      , 'Y'
      , 'RS_EMPLOYEE'
      , p_user_id
      , sysdate
      , p_user_id
      , sysdate
      , l_login_id
      from
        JTF_TTY_PTERR_ACCTS ALPA
      , JTF_TTY_ALIGN_PTERR ALPT
      , JTF_TTY_ALIGN_ACCTS ALAC
      where
          ALPA.ALIGN_PROPOSED_TERR_ID = ALPT.ALIGN_PROPOSED_TERR_ID
      and ALAC.ALIGN_ACCT_ID = ALPA.ALIGN_ACCT_ID
      and ALAC.TERR_GROUP_ACCOUNT_ID = account_rsc_table(j)
      and ALAC.alignment_id = p_alignment_id
      -- check to ensure inserted resource is still valid
      and (ALPT.resource_id, ALPT.rsc_group_id, ALPT.rsc_role_code) IN
             (  SELECT dir.resource_id
                , grpmemo.group_id
                , rol.role_code
            FROM jtf_rs_roles_b    rol
               , jtf_rs_role_relations rlt
               , jtf_rs_group_members  grpmemo
               , jtf_rs_resource_extns  dir
               , ( SELECT  distinct dv.group_id, dv.immediate_parent_flag child_group_flag
                   FROM jtf_rs_group_usages usg
                      , jtf_rs_groups_denorm dv
                      , jtf_rs_rep_managers  sgh
                      , jtf_rs_resource_extns mrsc
                   WHERE usg.usage = 'SALES'
                     AND usg.group_id = dv.group_id
                     AND ( dv.immediate_parent_flag = 'Y' OR dv.group_id = dv.parent_group_id )
                     AND dv.parent_group_id = sgh.group_id
                     AND SYSDATE BETWEEN NVL(dv.start_date_active, SYSDATE-1)
                                AND NVL(dv.end_date_active, SYSDATE+1)
                     AND SYSDATE BETWEEN sgh.start_date_active AND NVL(sgh.end_date_active, SYSDATE+1)
                     AND sgh.hierarchy_type IN ('MGR_TO_MGR')
                     AND sgh.resource_id = sgh.parent_resource_id
                     AND mrsc.resource_id = sgh.resource_id
                     AND mrsc.user_id = p_user_id ) MY_GRPS
            WHERE
                  rlt.role_id = rol.role_id
              AND rlt.role_resource_type = 'RS_GROUP_MEMBER'
              AND rlt.delete_flag = 'N'
              AND SYSDATE BETWEEN rlt.start_date_active AND NVL(rlt.end_date_active, SYSDATE+1)
              AND rlt.role_resource_id = grpmemo.group_member_id
              AND grpmemo.delete_flag = 'N'
              AND grpmemo.resource_id  = dir.resource_id
              AND SYSDATE BETWEEN dir.start_date_active AND NVL(dir.end_date_active, SYSDATE+1)
              AND grpmemo.group_id = MY_GRPS.group_id
              AND ( rol.manager_flag = 'Y' OR
                 ( rol.member_flag = 'Y' and MY_GRPS.child_group_flag = 'N' ) )
                 ) ;

         FORALL j IN account_rsc_table.FIRST .. account_rsc_table.LAST
              INSERT into jtf_tty_named_acct_changes
              ( NAMED_ACCT_CHANGE_ID
               ,OBJECT_VERSION_NUMBER
               ,OBJECT_TYPE
               ,OBJECT_ID
               ,CHANGE_TYPE
               ,FROM_WHERE
               ,CREATED_BY
               ,CREATION_DATE
               ,LAST_UPDATED_BY
               ,LAST_UPDATE_DATE
               ,LAST_UPDATE_LOGIN
              ) values
              ( jtf_tty_named_acct_changes_s.nextval
               ,1
               ,'TGA'
               ,account_rsc_table(j)
               ,'UPDATE'
               ,'ACTIVATE ALIGNMENT'
               ,p_user_id
               ,sysdate
               ,p_user_id
               ,sysdate
               ,l_login_id );

        --NOTE: Denorm/Summary tables (or their substitutes) need to be updated.
        --dbms_output.put_line('commit changes');

     END IF; --account_rsc_table is not null

   -- set activated_on date for this alignment to sysdate
   UPDATE JTF_TTY_ALIGNMENTS
   SET activated_on     = SYSDATE
      ,alignment_status = 'A'
      ,last_updated_by  =  p_user_id
      ,last_update_date = sysdate
   WHERE alignment_id = p_alignment_id;

   COMMIT;

        -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count,
            p_data            =>      x_msg_data
        );
EXCEPTION
    --   WHEN NO_DATA_FOUND THEN NULL;
      WHEN l_invalid_align THEN
           x_return_status := l_return_status;
      WHEN OTHERS THEN
           x_return_status := 'U';
           x_msg_data := substr(sqlerrm, 1, 200) ;
           IF (c_all_accounts%ISOPEN) THEN
             CLOSE c_all_accounts;
           END IF;
           IF (c_get_invalid_accts%ISOPEN) THEN
             CLOSE c_get_invalid_accts;
           END IF;
           IF (c_get_invalid_roles%ISOPEN) THEN
             CLOSE c_get_invalid_roles;
           END IF;
END Activate_Alignment;

END JTF_TTY_ALIGN_ACTIVATE_PKG;

/
