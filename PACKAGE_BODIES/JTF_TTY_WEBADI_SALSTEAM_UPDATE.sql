--------------------------------------------------------
--  DDL for Package Body JTF_TTY_WEBADI_SALSTEAM_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_WEBADI_SALSTEAM_UPDATE" AS
/* $Header: jtfvstub.pls 120.2 2005/09/22 21:13:13 shli noship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_WEBADI_salsteam_update
--    ---------------------------------------------------

--  PURPOSE
--      upload named account territory resource information into excel
--
--
--  PROCEDURES:
--       (see below for specification)
--
--
--  HISTORY
--    05/17/2003  sbehera          Package Body Created
--    05/29/2003  JRADHAKR         Modularized the code and added more
--                                 validations. Still need to seed message
--    06/03/2003  shli             message seeded.
--    06/09/2003  JRADHAKR         Fixed Bug 2998045,2997557
--    07/18/2003  shli             proxy user implemented.
--    08/13/2003  arpatel          added call to alignment package
--    10/10/2003  sp               Modified validate_resource procedure for alignment
--
--    End of Comments
--


PROCEDURE validate_resource (
       P_RESOURCE_NAME    in varchar2,
       P_GROUP_NAME       in varchar2,
       P_ROLE_NAME        in varchar2,
       P_terr_group_id    in number,
       P_named_account_id in number,
       P_TERR_GRP_ACCT_ID in number,
       p_alignment_id     in varchar2,
       X_RESOURCE_id      out NOCOPY number,
       x_group_id         out NOCOPY number,
       x_role_code        out NOCOPY varchar2,
       x_error_code       out NOCOPY number,
       x_status           out NOCOPY varchar2) is

  counter            NUMBER:=0;
  comb               NUMBER:=0;
  l_select           varchar2(10);
  l_user_id          NUMBER;
  found              NUMBER;
  l_num_valid_rsc_id NUMBER := 0;
  TYPE NUMBER_TABLE_TYPE IS TABLE OF NUMBER;
  l_res_tbl NUMBER_TABLE_TYPE := NUMBER_TABLE_TYPE();

  CURSOR c_get_resource_id ( c_resource_name VARCHAR2 ) IS
  SELECT RESOURCE_id
    FROM jtf_rs_resource_extns_vl
   WHERE upper(resource_name) = upper(c_resource_name)
     AND category = 'EMPLOYEE'
     AND SYSDATE BETWEEN start_date_active AND NVL(end_date_active, SYSDATE+1);

  CURSOR c_get_group_id ( c_group_name VARCHAR2 ) IS
  SELECT group_id
    FROM jtf_rs_groups_vl
   WHERE upper(group_name) = upper(c_group_name)
    AND SYSDATE BETWEEN start_date_active AND NVL(end_date_active, SYSDATE+1);

  CURSOR c_get_role_code ( c_role_name VARCHAR2 ) IS
  SELECT rol.role_code
    FROM jtf_rs_roles_vl rol
   WHERE upper(rol.role_name) = upper(c_role_name)
     AND (     rol.role_type_code = 'SALES'
               OR  rol.role_type_code = 'TELESALES'
               OR  rol.role_type_code = 'FIELDSALES'
         )
     AND active_flag ='Y';


BEGIN
   x_status := 'S';
   l_user_id := fnd_global.user_id;

   IF P_RESOURCE_NAME is not null
      AND P_GROUP_NAME is not null
      AND P_ROLE_NAME is not null
   THEN

       /* validation against LOVs. by terr group's owner resource_id allows a resource not owned by the logged in
          user valid. The validation also blocks any resource outside the terr group.
       */


        -- for both NA and Alignment
        BEGIN -- check group name and role name
            -- check group name

                counter :=0;
                FOR group_rec IN  c_get_group_id( c_group_name => p_group_name )
                LOOP
                  counter := counter +1;
                  x_group_id := group_rec.group_id; -- group_id assigned

                  IF counter=2 THEN
                        x_status := 'E';
                        fnd_message.set_name ('JTF', 'JTF_TTY_NON_UNIQUE_GROUP_NAME');
                        x_error_code := 1;
                        RETURN;
                  END IF;
                END LOOP;

                IF counter=0 THEN
                   RAISE NO_DATA_FOUND;
                END IF;

                -- check role name
                counter :=0;
                FOR role_rec IN  c_get_role_code( c_role_name => p_role_name )
                LOOP
                counter := counter +1;
                  x_role_code := role_rec.role_code; -- role_code assigned
                  IF counter=2 THEN
                        x_status := 'E';
                        fnd_message.set_name ('JTF', 'JTF_TTY_NON_UNIQUE_ROLE_NAME');
                        x_error_code := 1;
                        RETURN;
                  END IF;
                END LOOP;

                IF counter=0 THEN
                   RAISE NO_DATA_FOUND;
                END IF;


                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        x_status := 'E';
                        fnd_message.set_name ('JTF', 'JTF_TTY_SALES_DATA_NOT_VALID');
                        x_error_code := 1;
                        RETURN;

          END; -- of check group name and role name

          --- check resource, group and role combination
          BEGIN
                counter :=0;
                FOR res_rec IN c_get_resource_id( c_resource_name => p_resource_name )
                LOOP
                 l_res_tbl.EXTEND;
                 counter := counter + 1;
                 l_res_tbl(counter) :=  res_rec.resource_id;
                END LOOP;

                IF counter = 0 THEN --no resource by this name
                  RAISE NO_DATA_FOUND;
                ELSE
                 IF p_alignment_id is null THEN /* for NA */
                 BEGIN /* xxx */

                       IF (l_res_tbl IS NOT NULL) AND ( l_res_tbl.COUNT > 0 ) THEN
                            l_num_valid_rsc_id := 0;
                       FOR i IN 1 .. l_res_tbl.COUNT
                       LOOP
                       BEGIN
                              SELECT 'VALID' INTO l_select
                              FROM    jtf_tty_terr_grp_accts tga,
                                      jtf_tty_named_acct_rsc nar
                             WHERE  nar.terr_group_account_id = tga.terr_group_account_id
                               AND  nar.rsc_role_code    = X_ROLE_CODE
                               AND  nar.resource_id      = l_res_tbl(i)
                               AND  nar.rsc_group_id     = X_GROUP_ID
                               AND  tga.named_account_id = P_NAMED_ACCOUNT_ID
                               AND  tga.terr_group_id    <>P_terr_group_id
                               AND  rownum < 2;

                               x_status := 'I';  -- it is in other TG, return with Ignore
                               RETURN;

                               EXCEPTION  -- go on
                               WHEN NO_DATA_FOUND THEN NULL;
                       END;

                       BEGIN
                                SELECT 'VALID'
                                INTO l_select
                                FROM jtf_rs_group_members  mem,
       	               	             jtf_rs_roles_b        rol,
               			             jtf_rs_role_relations rlt
                                WHERE rlt.role_resource_type = 'RS_GROUP_MEMBER'
                                      AND rlt.delete_flag = 'N'
                                      AND sysdate >= rlt.start_date_active
                                      AND ( rlt.end_date_active is null
                                        OR
                                      sysdate <= rlt.end_date_active
                                      )
                                      AND rlt.role_id = rol.role_id
                                      AND rol.role_code = x_role_code
                                      AND rlt.role_resource_id = mem.group_member_id
                                      AND mem.delete_flag = 'N'
                                      AND mem.group_id = x_group_id
                                      AND mem.resource_id = l_res_tbl(i);

                                x_resource_id := l_res_tbl(i);
                                l_num_valid_rsc_id := l_num_valid_rsc_id + 1;

                                EXCEPTION
                                   WHEN NO_DATA_FOUND THEN NULL;
                                   WHEN TOO_MANY_ROWS THEN RAISE TOO_MANY_ROWS; -- not common error.
                                   WHEN OTHERS        THEN
                                        x_status := 'E';
                                        x_error_code := 4;
                                        fnd_message.set_name ('JTF', 'JTF_TTY_UNEXPECTED_ERROR');
                     END;
                     END LOOP;

                     IF l_num_valid_rsc_id  > 1 THEN
                       RAISE TOO_MANY_ROWS; -- duplicate combination, like two Lisa in the same resource group, same role
                     ELSIF l_num_valid_rsc_id =0 THEN
                       RAISE NO_DATA_FOUND; -- the reps(by that name) are valid but not in the resource group with the role
                     END IF;

               END IF; -- l_res_tbl > 0

                 EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   x_status := 'E';
                   fnd_message.set_name ('JTF', 'JTF_TTY_SALES_DATA_NOT_VALID');
                   x_error_code := 1;
                   RETURN;
                 WHEN TOO_MANY_ROWS THEN
                   x_status := 'E';
                   fnd_message.set_name ('JTF', 'JTF_TTY_NON_UNIQUE_SALES_DATA');
                   x_error_code := 1;
                   RETURN;
                 WHEN OTHERS THEN
                   x_status := 'E';
                   x_error_code := 4;
                   fnd_message.set_name ('JTF', 'JTF_TTY_UNEXPECTED_ERROR');
              END; /* of xxx */

          -- check the role code
              BEGIN
                    SELECT 'Y'
                      INTO l_select
                      FROM jtf_tty_terr_grp_roles
                     WHERE terr_group_id=P_terr_group_id
                       AND role_code = X_ROLE_CODE;

                     EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        x_status := 'E';
                        x_error_code := 2;
                        fnd_message.set_name ('JTF', 'JTF_TTY_ROLE_NOT_IN_TG');
                        RETURN;
               END;



       ELSE  -- for alignment
          BEGIN /*yyy*/

               IF (l_res_tbl IS NOT NULL) AND ( l_res_tbl.COUNT > 0 ) THEN
                   l_num_valid_rsc_id := 0;
                FOR i IN 1 .. l_res_tbl.COUNT
                  LOOP
                   BEGIN

                  --   where clauses for alignment is validating resource as a immediate direct of
                  --   territory group owner rather than alignment owner
                      SELECT  'VALID'
                              INTO l_select
                      FROM  JTF_TTY_MY_DIRECTS_V
                      WHERE current_user_id = l_user_id
                        AND resource_id     = l_res_tbl(i)
                        AND group_id        = X_GROUP_ID
                        AND role_code       = X_ROLE_CODE;

                        x_resource_id := l_res_tbl(i);
                        l_num_valid_rsc_id := l_num_valid_rsc_id + 1;

                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN NULL;
                           WHEN TOO_MANY_ROWS THEN RAISE TOO_MANY_ROWS; -- not common error.
                           WHEN OTHERS        THEN
                                x_status := 'E';
                                x_error_code := 4;
                                fnd_message.set_name ('JTF', 'JTF_TTY_UNEXPECTED_ERROR');
                END;
              END LOOP;

              IF l_num_valid_rsc_id  > 1 THEN
                   RAISE TOO_MANY_ROWS; -- duplicate combination, like two Lisa in the same resource group, same role
              ELSIF l_num_valid_rsc_id =0 THEN
                   RAISE NO_DATA_FOUND; -- the reps(by that name) are valid but not in the resource group with the role
              END IF;
            END IF; --l_res_tbl.COUNT > 0

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   x_status := 'E';
                   fnd_message.set_name ('JTF', 'JTF_TTY_SALES_DATA_NOT_VALID');
                   x_error_code := 1;
                   RETURN;
               WHEN TOO_MANY_ROWS THEN
                   x_status := 'E';
                   fnd_message.set_name ('JTF', 'JTF_TTY_NON_UNIQUE_SALES_DATA');
                   x_error_code := 1;
                   RETURN;
               WHEN OTHERS THEN
                   x_status := 'E';
                   x_error_code := 4;
                   fnd_message.set_name ('JTF', 'JTF_TTY_UNEXPECTED_ERROR');

          END; /* of yyy */


         END IF; /* align id */
       END IF; -- count

       EXCEPTION
             WHEN NO_DATA_FOUND THEN
               x_status := 'E';
               fnd_message.set_name ('JTF', 'JTF_TTY_SALES_DATA_NOT_VALID');
               x_error_code := 1;
               RETURN;

    END;

      /* old alignment code
      ELSE -- for alignment
           BEGIN
              --   where clauses for alignment is validating resource as a immediate direct of
              --   territory group owner rather than alignment owner
              SELECT resource_id, group_id, role_code
                     INTO x_RESOURCE_id, x_group_id, x_role_code
               FROM  JTF_TTY_MY_DIRECTS_V
              WHERE current_user_id = l_user_id
                AND upper(resource_name) = upper(P_RESOURCE_NAME)
                AND upper(group_name)    = upper(P_GROUP_NAME)
                AND upper(role_name)     = upper(P_ROLE_NAME)
                AND rownum<2;

               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  x_status := 'E';
                  fnd_message.set_name ('JTF', 'JTF_TTY_SALES_DATA_NOT_VALID');
                  x_error_code := 1;
                  RETURN;
            END;
      END IF; --p_alignment_id is null */


  ELSE
         x_status := 'E';
         x_error_code := 3;
         fnd_message.set_name ('JTF', 'JTF_TTY_SALES_MANDATORY');
         RETURN;
  END IF;

  EXCEPTION
        WHEN OTHERS THEN
            x_status := 'E';
            x_error_code := 4;
            fnd_message.set_name ('JTF', 'JTF_TTY_UNEXPECTED_ERROR');

END validate_resource;


/* Procedure which checks whether the user can add the given
sales person. This is same as 11.5.9 */

PROCEDURE CHECK_VALID_RESOURCE_ADD (
         P_RESOURCE_id    in number
      ,  P_GROUP_ID       IN NUMBER
      ,  P_ROLE_CODE      in varchar2
      ,  P_user_id        in number
      ,  P_TG_ID          in number
      ,  x_error_code     out NOCOPY number
      ,  x_status         out NOCOPY varchar2) is

  l_select varchar2(100);

BEGIN
   x_status := 'S';
      /* check salesperson for the current TG */
   BEGIN
   SELECT 'VALID'
   INTO l_select
   FROM jtf_tty_srch_my_resources_v /*jtf_tty_my_resources_v*/ grv,
        jtf_tty_terr_grp_owners jto
   WHERE EXISTS
       ( SELECT NULL
           FROM JTF_RS_GROUPS_DENORM /*jtf_rs_grp_denorm_vl*/ grpd
          WHERE /* part of Salesgroup hierarchy of Territory Group owner */
                grpd.parent_group_id = JTO.rsc_group_id
                /* groups I (logged-in user) am 'member' of */
            AND grpd.group_id = GRV.group_id
       )
     AND jto.terr_group_id   = P_TG_ID
     AND grv.ROLE_CODE       = P_ROLE_CODE
     AND grv.GROUP_ID        = P_GROUP_ID
     AND grv.resource_id     = P_RESOURCE_ID
     AND grv.CURRENT_USER_ID = P_USER_ID
     AND ROWNUM < 2;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_status := 'E';
        x_error_code := 1;
        fnd_message.set_name ('JTF', 'JTF_TTY_SALES_DATA_NOT_VALID');
        RETURN;

    WHEN OTHERS THEN
       x_status := 'E';
       x_error_code := 4;
       fnd_message.set_name ('JTF', 'JTF_TTY_UNEXPECTED_ERROR');
       RETURN;
    END;


END CHECK_VALID_RESOURCE_ADD;

/* Procedure which checks whether the user can remove the given
sales person. Same as 11.5.9*/


PROCEDURE CHECK_VALID_RESOURCE_REMOVE (
         P_RESOURCE_id    in number
      ,  P_GROUP_ID       IN NUMBER
      ,  P_ROLE_CODE      in varchar2
      ,  P_USER_ID        in number
      ,  P_TG_ID          IN NUMBER
      ,  x_error_code     out NOCOPY number
      ,  x_status         out NOCOPY varchar2) is


  l_select varchar2(100);

begin

   x_status := 'S';

      SELECT 'VALID'
      INTO l_select
      FROM (
            /* Salesperson is a member of one of his mgr's group OR
            ** is a manager of a child group of one of his mgr's groups */
            SELECT dir.resource_id, dir.resource_name, dir.user_id dir_user_id
                 , MY_GRPS.group_id
                 , MY_GRPS.parent_group_id
                 , MY_GRPS.CURRENT_USER_ID
                 , rol.role_code, rol.role_name
                 , MY_GRPS.current_user_role_code
                 , MY_GRPS.current_user_rsc_id
            FROM jtf_rs_roles_vl     rol
              , jtf_rs_role_relations rlt
              , jtf_rs_group_members  grpmemo
              , jtf_rs_resource_extns_vl dir

              , ( /* MY_GRPS INLINE VIEW */
                  /* Groups logged-in user manages/administrates */
                  SELECT /*+ NO_MERGE */
	                dv.group_id
                      , dv.parent_group_id
                      , sgh.resource_id
                      , mrsc.user_id CURRENT_USER_ID
                      , mrsc.resource_id current_user_rsc_id
                      , usg.USAGE
                      , rol.role_code current_user_role_code
                  FROM jtf_rs_group_usages usg
                     , jtf_rs_groups_denorm dv
                     , jtf_rs_rep_managers  sgh
                     , jtf_rs_resource_extns mrsc
                     , jtf_rs_roles_b     rol
                     , jtf_rs_role_relations rlt
                  WHERE usg.usage = 'SALES'
                    AND usg.group_id = dv.group_id
                    AND rlt.role_id = rol.role_id
                    AND rlt.role_relate_id = sgh.par_role_relate_id
                    AND dv.parent_group_id = sgh.group_id
                    AND sgh.resource_id = sgh.parent_resource_id
                    AND ( sgh.hierarchy_type IN ('MGR_TO_MGR')
                          OR rol.role_code = FND_PROFILE.VALUE('JTF_TTY_NA_PROXY_USER_ROLE')
                        )
                    AND mrsc.resource_id = sgh.resource_id ) MY_GRPS
            WHERE ( rol.member_flag = 'Y' OR rol.manager_flag = 'Y' )
              AND rlt.role_id = rol.role_id
              AND rlt.role_resource_type = 'RS_GROUP_MEMBER'
              AND rlt.role_resource_id = grpmemo.group_member_id
              AND grpmemo.resource_id  = dir.resource_id
              AND grpmemo.group_id = MY_GRPS.group_id

            UNION ALL

            /* Base Salesperson logged in, i.e., user is not
            ** a manager of a salesgroup */
            SELECT dir.resource_id
                 , dir.resource_name
                 , dir.user_id dir_user_id
                 , SALES_GRPS.group_id
                 , SALES_GRPS.parent_group_id
                 , dir.user_id CURRENT_USER_ID
                 , rol.role_code, rol.role_name
                 , rol.role_code current_user_role_code
                 , dir.resource_id current_user_rsc_id
            FROM jtf_rs_roles_vl     rol
               , jtf_rs_role_relations rlt
               , jtf_rs_group_members  grpmemo
               , jtf_rs_resource_extns_vl dir
               , ( /* SALES GROUPS INLINE VIEW */
                   SELECT dv.group_id
                        , dv.group_id PARENT_GROUP_ID
                        , NULL PARENT_GROUP_NAME
                   FROM jtf_rs_group_usages usg
                      , jtf_rs_groups_b dv
                   WHERE usg.usage = 'SALES'
                     AND usg.group_id = dv.group_id
                 ) SALES_GRPS
            WHERE rol.member_flag = 'Y'
              AND rlt.role_id = rol.role_id
              AND rlt.role_resource_type = 'RS_GROUP_MEMBER'
              AND rlt.role_resource_id = grpmemo.group_member_id
              AND grpmemo.resource_id  = dir.resource_id
              AND grpmemo.group_id = SALES_GRPS.group_id
              AND NOT EXISTS (
                 /* Rep is not a manager */
                      SELECT NULL
                       FROM jtf_rs_rep_managers mgr
                      WHERE mgr.parent_resource_id = dir.resource_id
                        AND mgr.parent_resource_id = mgr.resource_id
                        AND mgr.group_id = grpmemo.group_id
                        AND mgr.hierarchy_type = 'MGR_TO_MGR'
              )
          ) MY_REPS
        , jtf_tty_terr_grp_owners tgo
        , jtf_tty_terr_grp_roles  tgr
      WHERE EXISTS (
          SELECT NULL
            FROM JTF_RS_GROUPS_DENORM /*jtf_rs_grp_denorm_vl*/ grpd
           WHERE grpd.parent_group_id = TGO.rsc_group_id
             AND grpd.group_id = MY_REPS.group_id )
      AND tgr.role_code           = MY_REPS.role_code
      AND tgr.terr_group_id       = tgo.terr_group_id
      AND tgo.terr_group_id       = P_TG_ID
      AND MY_REPS.CURRENT_USER_ID = P_USER_ID
      AND MY_REPS.role_code       = P_ROLE_CODE
      AND MY_REPS.group_id        = P_GROUP_ID
      AND MY_REPS.resource_id     = P_RESOURCE_ID
      AND ROWNUM < 2;


    exception
     when no_data_found then
        x_status := 'E'; -- no error message necessary;
        RETURN;
        -- x_error_code := 5;
        -- fnd_message.set_name ('JTF', 'JTF_TTY_INVALID_SALES_REC');

    when others then
       x_status := 'E';
       x_error_code := 4;
       fnd_message.set_name ('JTF', 'JTF_TTY_UNEXPECTED_ERROR');

end CHECK_VALID_RESOURCE_REMOVE;



PROCEDURE POPULATE_SALESTEAM_ALIGNMENT (
       P_TERRITORY_GROUP in varchar2,
       P_RESOURCE1_NAME in varchar2,
       P_GROUP1_NAME in varchar2,
       P_ROLE1_NAME in varchar2,
       P_RESOURCE2_NAME in varchar2,
       P_GROUP2_NAME in varchar2,
       P_ROLE2_NAME in varchar2,
       P_RESOURCE3_NAME in varchar2,
       P_GROUP3_NAME in varchar2,
       P_ROLE3_NAME in varchar2,
       P_RESOURCE4_NAME in varchar2,
       P_GROUP4_NAME in varchar2,
       P_ROLE4_NAME in varchar2,
       P_RESOURCE5_NAME in varchar2,
       P_GROUP5_NAME in varchar2,
       P_ROLE5_NAME in varchar2,
       P_RESOURCE6_NAME in varchar2,
       P_GROUP6_NAME in varchar2,
       P_ROLE6_NAME in varchar2,
       P_RESOURCE7_NAME in varchar2,
       P_GROUP7_NAME in varchar2,
       P_ROLE7_NAME in varchar2,
       P_RESOURCE8_NAME in varchar2,
       P_GROUP8_NAME in varchar2,
       P_ROLE8_NAME in varchar2,
       P_RESOURCE9_NAME in varchar2,
       P_GROUP9_NAME in varchar2,
       P_ROLE9_NAME in varchar2,
       P_RESOURCE10_NAME in varchar2,
       P_GROUP10_NAME in varchar2,
       P_ROLE10_NAME in varchar2,
       P_RESOURCE11_NAME in varchar2,
       P_GROUP11_NAME in varchar2,
       P_ROLE11_NAME in varchar2,
       P_RESOURCE12_NAME in varchar2,
       P_GROUP12_NAME in varchar2,
       P_ROLE12_NAME in varchar2,
       P_RESOURCE13_NAME in varchar2,
       P_GROUP13_NAME in varchar2,
       P_ROLE13_NAME in varchar2,
       P_RESOURCE14_NAME in varchar2,
       P_GROUP14_NAME in varchar2,
       P_ROLE14_NAME in varchar2,
       P_RESOURCE15_NAME in varchar2,
       P_GROUP15_NAME in varchar2,
       P_ROLE15_NAME in varchar2,
       P_RESOURCE16_NAME in varchar2,
       P_GROUP16_NAME in varchar2,
       P_ROLE16_NAME in varchar2,
       P_RESOURCE17_NAME in varchar2,
       P_GROUP17_NAME in varchar2,
       P_ROLE17_NAME in varchar2,
       P_RESOURCE18_NAME in varchar2,
       P_GROUP18_NAME in varchar2,
       P_ROLE18_NAME in varchar2,
       P_RESOURCE19_NAME in varchar2,
       P_GROUP19_NAME in varchar2,
       P_ROLE19_NAME in varchar2,
       P_RESOURCE20_NAME in varchar2,
       P_GROUP20_NAME in varchar2,
       P_ROLE20_NAME in varchar2,
       P_RESOURCE21_NAME in varchar2,
       P_GROUP21_NAME in varchar2,
       P_ROLE21_NAME in varchar2,
       P_RESOURCE22_NAME in varchar2,
       P_GROUP22_NAME in varchar2,
       P_ROLE22_NAME in varchar2,
       P_RESOURCE23_NAME in varchar2,
       P_GROUP23_NAME in varchar2,
       P_ROLE23_NAME in varchar2,
       P_RESOURCE24_NAME in varchar2,
       P_GROUP24_NAME in varchar2,
       P_ROLE24_NAME in varchar2,
       P_RESOURCE25_NAME in varchar2,
       P_GROUP25_NAME in varchar2,
       P_ROLE25_NAME in varchar2,
       P_RESOURCE26_NAME in varchar2,
       P_GROUP26_NAME in varchar2,
       P_ROLE26_NAME in varchar2,
       P_RESOURCE27_NAME in varchar2,
       P_GROUP27_NAME in varchar2,
       P_ROLE27_NAME in varchar2,
       P_RESOURCE28_NAME in varchar2,
       P_GROUP28_NAME in varchar2,
       P_ROLE28_NAME in varchar2,
       P_RESOURCE29_NAME in varchar2,
       P_GROUP29_NAME in varchar2,
       P_ROLE29_NAME in varchar2,
       P_RESOURCE30_NAME in varchar2,
       P_GROUP30_NAME in varchar2,
       P_ROLE30_NAME in varchar2,
       P_TERR_GRP_ACCT_ID in varchar2,
       P_ALIGNMENT_FLAG in varchar2,
       P_ALIGNMENT_ID in varchar2) is

  CURSOR c_res_list(l_terr_grp_acct_id number)
  IS select RESOURCE_ID, RSC_GROUP_ID , RSC_ROLE_CODE
       from jtf_tty_named_acct_rsc
      where TERR_GROUP_ACCOUNT_ID = l_terr_grp_acct_id;

  CURSOR c_res_list_for_align(c_terr_grp_acct_id number, c_user_id number)
  IS SELECT narsc.resource_id resource_id,
            narsc.rsc_group_id rsc_group_id,
            narsc.rsc_role_code rsc_role_code
       FROM jtf_tty_named_acct_rsc narsc
      WHERE narsc.terr_group_account_id = c_terr_grp_acct_id
        AND (narsc.resource_id, narsc.rsc_group_id, narsc.rsc_role_code ) IN
              ( select /*+ NO_MERGE */ mydir.resource_id, mydir.group_id, mydir.role_code
             from jtf_tty_srch_my_resources_v mydir
             where mydir.current_user_id = c_user_id );

  CURSOR c_get_user_id (l_align_id number )
  IS SELECT rsc.user_id
       FROM jtf_rs_resource_extns rsc,
            jtf_tty_alignments al
      WHERE rsc.resource_id = al.owner_resource_id
        AND al.owner_resource_type = 'RS_EMPLOYEE'
        AND al.alignment_id = l_align_id;

  CURSOR c_align_res_list(l_terr_grp_acct_id number)
  IS select pt.RESOURCE_ID, pt.RSC_GROUP_ID , pt.RSC_ROLE_CODE
       from jtf_tty_align_pterr pt,
            jtf_tty_pterr_accts pa,
            jtf_tty_align_accts aa
      where pt.align_proposed_terr_id = pa.align_proposed_terr_id
        and pa.align_acct_id = aa.align_acct_id
        and aa.terr_group_account_id = l_terr_grp_acct_id
        and aa.alignment_id = p_alignment_id;

   CURSOR c_check_direct_res( c_resource_id NUMBER, c_group_id NUMBER,
                              c_role_code  VARCHAR2, c_user_id NUMBER )
   IS SELECT 'Y'
        FROM jtf_tty_my_directs_v
      WHERE  current_user_id = c_user_id
        AND  resource_id = c_resource_id
        AND  group_id = c_group_id
        AND  role_code = c_role_code;

   CURSOR c_get_direct_res( c_resource_id NUMBER, c_group_id NUMBER, c_user_id NUMBER )
   IS SELECT mydir.resource_id resource_id,
             mydir.group_id group_id,
             mydir.role_code role_code
        FROM jtf_tty_my_directs_v  mydir
       WHERE mydir.current_user_id = c_user_id
         AND mydir.dir_user_id <>  c_user_id
         AND ( mydir.resource_id, mydir.group_id,  mydir.role_code) IN
                ( SELECT /*+ NO_MERGE */
                         repmgr.parent_resource_id,
                         grpmem.group_id,
                         rol.role_code
                   FROM jtf_rs_rep_managers repmgr,
                        jtf_rs_role_relations rlt,
                        jtf_rs_roles_b rol,
                        jtf_rs_group_members grpmem
                  WHERE repmgr.resource_id = c_resource_id
                    AND repmgr.group_id = c_group_id
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

 x_msg_count number;
 x_msg_data  varchar2(2000);
 x_return_status varchar(3);
 l_index  number:=0;
 l_error_count number:=0;
 l_terr_grp_acct_id number;
 l_terr_group_id number;
 l_resource_name varchar2(360);
 l_resource_id number;
 l_group varchar2(60);
 l_role_code varchar2(20);
 l_group_id number;
 l_role  varchar2(60);
 i integer:=0;
 errbuf varchar2(2000);
 retcode number;
 X_RESOURCE_id  number;
 x_group_id number;
 x_role_code varchar2(30);
 x_error_code varchar2(2);
 x_status varchar2(3);
 l_named_account_id number;
 l_atleast_one_rep boolean := FALSE;
 l_error varchar2(30);
 l_imported_on DATE := null;

 l_added_rscs_tbl       JTF_TTY_NACCT_SALES_PUB.SALESREP_RSC_TBL_TYPE;
 l_add_rscs_tbl         JTF_TTY_NACCT_SALES_PUB.SALESREP_RSC_TBL_TYPE;
 l_directs_tbl          JTF_TTY_NACCT_SALES_PUB.SALESREP_RSC_TBL_TYPE;
 l_removed_rscs_tbl     JTF_TTY_NACCT_SALES_PUB.SALESREP_RSC_TBL_TYPE;

 l_affected_parties_tbl JTF_TTY_NACCT_SALES_PUB.AFFECTED_PARTY_TBL_TYPE;
 l_assign_flag varchar2(1);
 l_whether_exist varchar2(1);
 l_user_id NUMBER;

 l_add_count    NUMBER := 0;
 l_delete_count NUMBER := 0;
 l_found        varchar2(10);
 l_res_found    BOOLEAN := FALSE;

 l_result varchar2(1);
 l_direct_flag VARCHAR2(1);

begin


  l_result :='N';
  l_direct_flag := 'N' ;

  -- delete  from tmp;
  -- insert into tmp values('1. start','');
   l_user_id := fnd_global.user_id;

   --insert into tmp values('ali',p_alignment_id); commit;
   l_error := 'JTF_TTY_ERROR';

   --insert into tmp values('P_ALIGNMENT_ID',P_ALIGNMENT_ID); commit;
   l_terr_grp_acct_id := P_TERR_GRP_ACCT_ID;


   BEGIN
       IF P_ALIGNMENT_ID IS NOT NULL THEN
          SELECT 'VALID' INTO l_found
          FROM JTF_TTY_ALIGNMENTS
          WHERE alignment_id = P_ALIGNMENT_ID
            AND l_user_id    = created_by;
       END IF;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            fnd_message.set_name ('JTF', 'JTF_TTY_DO_NOT_OWN_ALIGN');
       RETURN;

   END;

   begin

     select terr_group_id
       into l_terr_group_id
     from jtf_tty_terr_groups
     where trim(terr_group_name) =P_TERRITORY_GROUP; -- deal with the trailing blank

     /* a change of l_terr_grp_acct_id will be caught here */
     SELECT named_account_id
       INTO l_named_account_id
       FROM jtf_tty_terr_grp_accts
      WHERE terr_group_account_id = l_terr_grp_acct_id;

     exception
      when others then
         fnd_message.set_name ('JTF', 'JTF_TTY_INVALID_TG');
         return;


   end;



   begin

        /* check if the salesperson(by user_id) is able to change the named account(by tgid).
           The query below was modified to consider accounts belonging to inactive reps also*/
        /*
        select narsc.resource_id INTO l_resource_id
        from   jtf_tty_named_acct_rsc narsc,
               jtf_tty_srch_my_resources_v repdn -- jtf_tty_my_resources_v
        where narsc.resource_id           = repdn.resource_id
              and narsc.rsc_group_id          = repdn.group_id
              and repdn.current_user_id       = l_user_id
              and narsc.terr_group_account_id = l_terr_grp_acct_id
              and rownum < 2;
         */
         SELECT narsc.resource_id
           INTO l_resource_id
           FROM jtf_tty_named_acct_rsc narsc
          WHERE narsc.terr_group_account_id = l_terr_grp_acct_id
            AND EXISTS (
                    SELECT 'Y'
                      FROM jtf_rs_group_members grpmemo ,
                           jtf_rs_resource_extns dir ,
                               ( SELECT /*+ NO_MERGE */ dv.group_id ,
                                     mrsc.user_id CURRENT_USER_ID
                                   FROM jtf_rs_group_usages usg ,
                                        jtf_rs_groups_denorm dv ,
                                        jtf_rs_rep_managers sgh ,
                                        jtf_rs_resource_extns mrsc ,
                                        jtf_rs_roles_b rol ,
                                        jtf_rs_role_relations rlt
                                   WHERE usg.usage = 'SALES'
                                     AND usg.group_id = dv.group_id
                                     AND rlt.role_id = rol.role_id
                                     AND rlt.role_relate_id = sgh.par_role_relate_id
                                     AND dv.parent_group_id = sgh.group_id
                                     AND sgh.resource_id = sgh.parent_resource_id
                                     AND (sgh.hierarchy_type IN ('MGR_TO_MGR')
                                      OR rol.role_code = FND_PROFILE.VALUE('JTF_TTY_NA_PROXY_USER_ROLE'))
                                      AND mrsc.resource_id = sgh.resource_id
                                      AND mrsc.user_id = l_user_id
                               ) MY_GRPS
                         WHERE grpmemo.resource_id = dir.resource_id
                           AND grpmemo.group_id = MY_GRPS.group_id
                           AND grpmemo.resource_id = narsc.resource_id
                           AND grpmemo.group_id = narsc.rsc_group_id
                                UNION ALL
                         SELECT 'Y'
                          FROM jtf_rs_group_members grpmemo ,
                               jtf_rs_resource_extns dir ,
                               jtf_rs_group_usages usg
                         WHERE usg.usage = 'SALES'
                          AND grpmemo.resource_id = dir.resource_id
                          AND grpmemo.group_id = usg.group_id
                          AND dir.user_id = l_user_id
                          AND grpmemo.resource_id = narsc.resource_id
                          AND grpmemo.group_id = narsc.rsc_group_id
                      )
              and rownum < 2;



        --dbms_output.put_line('passed initial validation');
        l_added_rscs_tbl := JTF_TTY_NACCT_SALES_PUB.SALESREP_RSC_TBL_TYPE();
        l_affected_parties_tbl := JTF_TTY_NACCT_SALES_PUB.AFFECTED_PARTY_TBL_TYPE();
        l_affected_parties_tbl.extend;
        l_affected_parties_tbl(1).terr_group_account_id := l_terr_grp_acct_id;

       begin
           if P_RESOURCE1_NAME is not null or P_GROUP1_NAME is not null or P_ROLE1_NAME is not null
           then


               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE1_NAME ,
                   P_GROUP_NAME=>P_GROUP1_NAME ,
                   P_ROLE_NAME=>P_ROLE1_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );

               if x_status = 'S' then


                 l_atleast_one_rep := TRUE;

                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '1';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '1'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE2_NAME is not null or P_GROUP2_NAME is not null or P_ROLE2_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE2_NAME ,
                   P_GROUP_NAME=>P_GROUP2_NAME ,
                   P_ROLE_NAME=>P_ROLE2_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );



               if x_status = 'S' then

                   -- insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '2';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '2'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE3_NAME is not null or P_GROUP3_NAME is not null or P_ROLE3_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE3_NAME ,
                   P_GROUP_NAME=>P_GROUP3_NAME ,
                   P_ROLE_NAME=>P_ROLE3_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );



               if x_status = 'S' then

                   -- insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '3';
                elsif x_status = 'I' then NULL;
                else
                  if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '3'); end if;
                  return;
                end if;
           end if;

           if P_RESOURCE4_NAME is not null or P_GROUP4_NAME is not null or P_ROLE4_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE4_NAME ,
                   P_GROUP_NAME=>P_GROUP4_NAME ,
                   P_ROLE_NAME=>P_ROLE4_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );

                   -- insert into sb values('Return Status ' || x_status);

               if x_status = 'S' then

                 -- insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '4';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '4'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE5_NAME is not null or P_GROUP5_NAME is not null or P_ROLE5_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE5_NAME ,
                   P_GROUP_NAME=>P_GROUP5_NAME ,
                   P_ROLE_NAME=>P_ROLE5_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );

                   -- insert into sb values('Return Status ' || x_status);

               if x_status = 'S' then

                   --insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '5';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '5'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE6_NAME is not null or P_GROUP6_NAME is not null or P_ROLE6_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE6_NAME ,
                   P_GROUP_NAME=>P_GROUP6_NAME ,
                   P_ROLE_NAME=>P_ROLE6_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '6';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '6'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE7_NAME is not null or P_GROUP7_NAME is not null or P_ROLE7_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE7_NAME ,
                   P_GROUP_NAME=>P_GROUP7_NAME ,
                   P_ROLE_NAME=>P_ROLE7_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '7';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '7'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE8_NAME is not null or P_GROUP8_NAME is not null or P_ROLE8_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE8_NAME ,
                   P_GROUP_NAME=>P_GROUP8_NAME ,
                   P_ROLE_NAME=>P_ROLE8_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '8';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '8'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE9_NAME is not null or P_GROUP9_NAME is not null or P_ROLE9_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE9_NAME ,
                   P_GROUP_NAME=>P_GROUP9_NAME ,
                   P_ROLE_NAME=>P_ROLE9_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

 --                insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '9';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '9'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE10_NAME is not null or P_GROUP10_NAME is not null or P_ROLE10_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE10_NAME ,
                   P_GROUP_NAME=>P_GROUP10_NAME ,
                   P_ROLE_NAME=>P_ROLE10_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '10';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '10'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE11_NAME is not null or P_GROUP11_NAME is not null or P_ROLE11_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE11_NAME ,
                   P_GROUP_NAME=>P_GROUP11_NAME ,
                   P_ROLE_NAME=>P_ROLE11_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '11';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '11'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE12_NAME is not null or P_GROUP12_NAME is not null or P_ROLE12_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE12_NAME ,
                   P_GROUP_NAME=>P_GROUP12_NAME ,
                   P_ROLE_NAME=>P_ROLE12_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '12';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '12'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE13_NAME is not null or P_GROUP13_NAME is not null or P_ROLE13_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE13_NAME ,
                   P_GROUP_NAME=>P_GROUP13_NAME ,
                   P_ROLE_NAME=>P_ROLE13_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '13';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '13'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE14_NAME is not null or P_GROUP14_NAME is not null or P_ROLE14_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE14_NAME ,
                   P_GROUP_NAME=>P_GROUP14_NAME ,
                   P_ROLE_NAME=>P_ROLE14_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '14';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '14'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE15_NAME is not null or P_GROUP15_NAME is not null or P_ROLE15_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE15_NAME ,
                   P_GROUP_NAME=>P_GROUP15_NAME ,
                   P_ROLE_NAME=>P_ROLE15_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '15';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '15'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE16_NAME is not null or P_GROUP16_NAME is not null or P_ROLE16_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE16_NAME ,
                   P_GROUP_NAME=>P_GROUP16_NAME ,
                   P_ROLE_NAME=>P_ROLE16_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '16';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '16'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE17_NAME is not null or P_GROUP17_NAME is not null or P_ROLE17_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE17_NAME ,
                   P_GROUP_NAME=>P_GROUP17_NAME ,
                   P_ROLE_NAME=>P_ROLE17_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '17';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '17'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE18_NAME is not null or P_GROUP18_NAME is not null or P_ROLE18_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE18_NAME ,
                   P_GROUP_NAME=>P_GROUP18_NAME ,
                   P_ROLE_NAME=>P_ROLE18_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '18';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '18'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE19_NAME is not null or P_GROUP19_NAME is not null or P_ROLE19_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE19_NAME ,
                   P_GROUP_NAME=>P_GROUP19_NAME ,
                   P_ROLE_NAME=>P_ROLE19_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '19';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '19'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE20_NAME is not null or P_GROUP20_NAME is not null or P_ROLE20_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE20_NAME ,
                   P_GROUP_NAME=>P_GROUP20_NAME ,
                   P_ROLE_NAME=>P_ROLE20_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '20';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '20'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE21_NAME is not null or P_GROUP21_NAME is not null or P_ROLE21_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE21_NAME ,
                   P_GROUP_NAME=>P_GROUP21_NAME ,
                   P_ROLE_NAME=>P_ROLE21_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '21';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '21'); end if;
                 return;
                 return;
               end if;
           end if;

           if P_RESOURCE22_NAME is not null or P_GROUP22_NAME is not null or P_ROLE22_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE22_NAME ,
                   P_GROUP_NAME=>P_GROUP22_NAME ,
                   P_ROLE_NAME=>P_ROLE22_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '22';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '22'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE23_NAME is not null or P_GROUP23_NAME is not null or P_ROLE23_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE23_NAME ,
                   P_GROUP_NAME=>P_GROUP23_NAME ,
                   P_ROLE_NAME=>P_ROLE23_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '23';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '23'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE24_NAME is not null or P_GROUP24_NAME is not null or P_ROLE24_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE24_NAME ,
                   P_GROUP_NAME=>P_GROUP24_NAME ,
                   P_ROLE_NAME=>P_ROLE24_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '24';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '24'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE25_NAME is not null or P_GROUP25_NAME is not null or P_ROLE25_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE25_NAME ,
                   P_GROUP_NAME=>P_GROUP25_NAME ,
                   P_ROLE_NAME=>P_ROLE25_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '25';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '25'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE26_NAME is not null or P_GROUP26_NAME is not null or P_ROLE26_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE26_NAME ,
                   P_GROUP_NAME=>P_GROUP26_NAME ,
                   P_ROLE_NAME=>P_ROLE26_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '26';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '26'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE27_NAME is not null or P_GROUP27_NAME is not null or P_ROLE27_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE27_NAME ,
                   P_GROUP_NAME=>P_GROUP27_NAME ,
                   P_ROLE_NAME=>P_ROLE27_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '27';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '27'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE28_NAME is not null or P_GROUP28_NAME is not null or P_ROLE28_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE28_NAME ,
                   P_GROUP_NAME=>P_GROUP28_NAME ,
                   P_ROLE_NAME=>P_ROLE28_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '28';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '28'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE29_NAME is not null or P_GROUP29_NAME is not null or P_ROLE29_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE29_NAME ,
                   P_GROUP_NAME=>P_GROUP29_NAME ,
                   P_ROLE_NAME=>P_ROLE29_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '29';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '29'); end if;
                 return;
               end if;
           end if;

           if P_RESOURCE30_NAME is not null or P_GROUP30_NAME is not null or P_ROLE30_NAME is not null
           then

               validate_resource (
                   P_RESOURCE_NAME=>P_RESOURCE30_NAME ,
                   P_GROUP_NAME=>P_GROUP30_NAME ,
                   P_ROLE_NAME=>P_ROLE30_NAME ,
                   P_terr_group_id=>l_terr_group_id ,
                   P_named_account_id=>l_named_account_id,
                   P_TERR_GRP_ACCT_ID =>P_TERR_GRP_ACCT_ID,
                   p_alignment_id => P_ALIGNMENT_ID,
                   X_RESOURCE_id=>X_RESOURCE_id ,
                   x_group_id=>x_group_id ,
                   x_role_code=>x_role_code ,
                   x_error_code =>x_error_code,
                   x_status=>x_status );


               if x_status = 'S' then

--                 insert into sb values('Inside the success status '|| to_char(i));
                 l_atleast_one_rep := TRUE;
                 l_added_rscs_tbl.extend;

                 i:=i+1;
                 l_added_rscs_tbl(i).resource_id := X_RESOURCE_id;
                 l_added_rscs_tbl(i).group_id := x_group_id;
                 l_added_rscs_tbl(i).role_code := x_role_code;
                 l_added_rscs_tbl(i).attribute1 := 'N';
                 l_added_rscs_tbl(i).attribute2 := '30';
               elsif x_status = 'I' then NULL;
               else
                 if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', '30'); end if;
                 return;
               end if;
           end if;

       end;



      l_add_rscs_tbl := JTF_TTY_NACCT_SALES_PUB.SALESREP_RSC_TBL_TYPE();
      l_removed_rscs_tbl := JTF_TTY_NACCT_SALES_PUB.SALESREP_RSC_TBL_TYPE();

     if p_alignment_id is null
     then
         /* Following code find out all the newly added sales info and
         put it into the l_add_rscs_tbl */
        if l_added_rscs_tbl.FIRST is not null
        then
           for j in l_added_rscs_tbl.FIRST..l_added_rscs_tbl.LAST
           loop
              begin
                select ASSIGNED_FLAG
                  into l_assign_flag
                  from jtf_tty_named_acct_rsc
                 where TERR_GROUP_ACCOUNT_ID = l_terr_grp_acct_id
                   and RESOURCE_ID           = l_added_rscs_tbl(j).Resource_id
                   and RSC_GROUP_ID          = l_added_rscs_tbl(j).group_id
                   and RSC_ROLE_CODE         = l_added_rscs_tbl(j).role_code
                   and RSC_RESOURCE_TYPE     = 'RS_EMPLOYEE';

                   IF l_assign_flag = 'N' THEN
                         l_add_rscs_tbl.extend;
                         l_add_count := l_add_count + 1;
                         l_add_rscs_tbl(l_add_count).resource_id :=  l_added_rscs_tbl(j).Resource_id;
                         l_add_rscs_tbl(l_add_count).group_id    :=  l_added_rscs_tbl(j).group_id;
                         l_add_rscs_tbl(l_add_count).role_code   :=  l_added_rscs_tbl(j).role_code;
                         l_add_rscs_tbl(l_add_count).attribute1  :=  'N';
                   ELSE  --l_assign_flag = 'Y',ignore
                         NULL;
                   END IF;


              exception
                 when no_data_found then
                      CHECK_VALID_RESOURCE_ADD (
                         P_RESOURCE_id   => l_added_rscs_tbl(j).Resource_id
                      ,  P_GROUP_ID      => l_added_rscs_tbl(j).group_id
                      ,  P_ROLE_CODE     => l_added_rscs_tbl(j).role_code
                      ,  P_user_id       => l_user_id
                      ,  P_TG_id         => l_terr_group_id
		              ,  x_error_code    => x_error_code
                      ,  x_status        => x_status );

                      if x_status = 'S' then
                         l_add_rscs_tbl.extend;
                         l_add_count := l_add_count + 1;
                         l_add_rscs_tbl(l_add_count).resource_id :=  l_added_rscs_tbl(j).Resource_id;
                         l_add_rscs_tbl(l_add_count).group_id    :=  l_added_rscs_tbl(j).group_id;
                         l_add_rscs_tbl(l_add_count).role_code   :=  l_added_rscs_tbl(j).role_code;
                         l_add_rscs_tbl(l_add_count).attribute1  :=  'N';
                      else
                         if x_error_code < 4 then FND_MESSAGE.Set_Token ('POSITION', l_added_rscs_tbl(j).attribute2); end if;
                         return;
                      end if;
                 when others then
                      fnd_message.set_name ('JTF', 'JTF_TTY_UNEXPECTED_ERROR');
                      return;
              end;
           end loop;
        end if; -- end of l_added_rscs table not being null

        /* Following code find out all the removed sales info and
         put it into the l_removed_rscs_tbl */
        for c_res in c_res_list(l_terr_grp_acct_id)
        loop
            l_res_found := FALSE;
            if l_added_rscs_tbl.FIRST is not null
            then
              for j in l_added_rscs_tbl.FIRST..l_added_rscs_tbl.LAST
              loop
                if l_added_rscs_tbl(j).Resource_id = c_res.Resource_id
                  and l_added_rscs_tbl(j).group_id = c_res.RSC_GROUP_ID
                  and l_added_rscs_tbl(j).role_code = c_res.RSC_ROLE_CODE
                then
                   l_res_found := TRUE;
                   exit;
                END IF;
              end loop;
            end if;

            if l_res_found = FALSE THEN
            Begin
               CHECK_VALID_RESOURCE_REMOVE (
                     P_RESOURCE_id   => c_res.Resource_id
                  ,  P_GROUP_ID      => c_res.RSC_GROUP_ID
                  ,  P_ROLE_CODE     => c_res.RSC_ROLE_CODE
                  ,  P_user_id       => l_user_id
                  ,  P_TG_id         => l_terr_group_id
                  ,  x_error_code    => x_error_code
                  ,  x_status        => x_status );

               if x_status = 'S' then
                 l_removed_rscs_tbl.extend;
                 l_delete_count :=l_delete_count +1;
                 l_removed_rscs_tbl(l_delete_count).resource_id := c_res.Resource_id;
                 l_removed_rscs_tbl(l_delete_count).group_id    := c_res.RSC_GROUP_ID;
                 l_removed_rscs_tbl(l_delete_count).role_code   := c_res.RSC_ROLE_CODE;
                 l_removed_rscs_tbl(l_delete_count).attribute1  := 'N';
               end if;
            Exception
              when others then
                fnd_message.set_name ('JTF', 'JTF_TTY_UNEXPECTED_ERROR');
                return;
            end;
            end if;  -- if l_res_found = FALSE
        end loop;  -- end of c_res loop
     else  -- p_alignment_id is not null

         /* Following code find out all the newly added sales info and
         put it into the l_add_rscs_tbl */
         if l_added_rscs_tbl.FIRST is not null
         then
            for j in l_added_rscs_tbl.FIRST..l_added_rscs_tbl.LAST
            loop
               begin
                  select 'x'
                    into l_whether_exist
                    from jtf_tty_align_pterr pt,
                         jtf_tty_pterr_accts pa,
                         jtf_tty_align_accts aa
                   where aa.terr_group_account_id = l_terr_grp_acct_id
                     and aa.alignment_id = p_alignment_id
                     and aa.align_acct_id = pa.align_acct_id
                     and pa.align_proposed_terr_id = pt.align_proposed_terr_id
                     and pt.resource_id = l_added_rscs_tbl(j).Resource_id
                     and pt.rsc_group_id = l_added_rscs_tbl(j).group_id
                     and pt.rsc_role_code = l_added_rscs_tbl(j).role_code
                     and pt.resource_type = 'RS_EMPLOYEE';
              exception
                 when no_data_found then
                         l_add_rscs_tbl.extend;
                         l_add_count := l_add_count + 1;
                         l_add_rscs_tbl(l_add_count).resource_id := l_added_rscs_tbl(j).Resource_id;
                         l_add_rscs_tbl(l_add_count).group_id    := l_added_rscs_tbl(j).group_id;
                         l_add_rscs_tbl(l_add_count).role_code   := l_added_rscs_tbl(j).role_code;
                         l_add_rscs_tbl(l_add_count).attribute1  := 'N';
                 when others then
                      fnd_message.set_name ('JTF', 'JTF_TTY_UNEXPECTED_ERROR');
                      return;
              end;
           end loop;
        end if; -- end of l_added_rscs table not being null

        /* Check to see if this is the first time alignment is being uploaded */
        begin
           select imported_on
             into l_imported_on
             from jtf_tty_alignments
            where alignment_id = p_alignment_id;
        exception
           when no_data_found then null;
        end;

        /* Following code find out all the removed sales info and
         put it into the l_removed_rscs_tbl */

        if ( l_imported_on IS NOT NULL )
        then

         for c_res in c_align_res_list(l_terr_grp_acct_id)
         loop
            l_res_found := FALSE;
            if l_added_rscs_tbl.FIRST is not null
            then
              for j in l_added_rscs_tbl.FIRST..l_added_rscs_tbl.LAST
              loop
                if l_added_rscs_tbl(j).Resource_id = c_res.Resource_id
                  and l_added_rscs_tbl(j).group_id = c_res.RSC_GROUP_ID
                  and l_added_rscs_tbl(j).role_code = c_res.RSC_ROLE_CODE
                then
                   l_res_found := TRUE;
                   exit;
                END IF;
              end loop;
            end if;

            if l_res_found = FALSE THEN
                 l_removed_rscs_tbl.extend;
                 l_delete_count :=l_delete_count +1;
                 l_removed_rscs_tbl(l_delete_count).resource_id := c_res.Resource_id;
                 l_removed_rscs_tbl(l_delete_count).group_id    := c_res.RSC_GROUP_ID;
                 l_removed_rscs_tbl(l_delete_count).role_code   := c_res.RSC_ROLE_CODE;
                 l_removed_rscs_tbl(l_delete_count).attribute1  := 'N';


            end if;
         end loop;  -- end of c_res loop
        else -- imported on is NULL
           for c_res in c_res_list_for_align(c_terr_grp_acct_id => l_terr_grp_acct_id,
                                             c_user_id => l_user_id)
           loop
              l_res_found := FALSE;
              if l_added_rscs_tbl.FIRST is not null
              then
                 l_direct_flag := 'N' ;
                 l_directs_tbl := JTF_TTY_NACCT_SALES_PUB.SALESREP_RSC_TBL_TYPE();
                 l_index := 0;
                 OPEN c_check_direct_res(c_resource_id => c_res.resource_id,
                                   c_group_id => c_res.rsc_group_id,
                                   c_role_code => c_res.rsc_role_code,
                                   c_user_id => l_user_id );
                 FETCH c_check_direct_res INTO l_direct_flag;
                 CLOSE c_check_direct_res;
                 IF (l_direct_flag = 'Y' )
                 THEN
                       l_directs_tbl.extend;
                       l_index := l_index +1;
                       l_directs_tbl(l_index).resource_id := c_res.Resource_id;
                       l_directs_tbl(l_index).group_id    := c_res.RSC_GROUP_ID;
                       l_directs_tbl(l_index).role_code   := c_res.RSC_ROLE_CODE;
                       l_directs_tbl(l_index).attribute1  := 'N';
                 ELSE
                       FOR direct_rec IN c_get_direct_res(c_resource_id => c_res.resource_id,
                                                          c_group_id => c_res.rsc_group_id ,
                                                          c_user_id => l_user_id)
                       LOOP
                            l_directs_tbl.extend;
                            l_index := l_index +1;
                            l_directs_tbl(l_index).resource_id := direct_rec.resource_id;
                            l_directs_tbl(l_index).group_id    := direct_rec.group_id;
                            l_directs_tbl(l_index).role_code   := direct_rec.role_code;
                            l_directs_tbl(l_index).attribute1  := 'N';
                       END LOOP;
                 END IF;
                 IF ( l_directs_tbl IS NOT NULL) AND ( l_directs_tbl.COUNT > 0 )
                 THEN
                   For k in l_directs_tbl.FIRST .. l_directs_tbl.LAST
                   LOOP
                    for j in l_added_rscs_tbl.FIRST..l_added_rscs_tbl.LAST
                    loop
                      if l_added_rscs_tbl(j).Resource_id = l_directs_tbl(k).resource_id
                         and l_added_rscs_tbl(j).group_id = l_directs_tbl(k).group_id
                         and l_added_rscs_tbl(j).role_code = l_directs_tbl(k).role_code
                      then
                           l_res_found := TRUE;
                           exit;
                      end if;
                    end loop;  -- for l_added_rscs_tbl

                    if l_res_found = FALSE THEN
                       l_removed_rscs_tbl.extend;
                       l_delete_count :=l_delete_count +1;
                       l_removed_rscs_tbl(l_delete_count).resource_id := l_directs_tbl(k).resource_id;
                       l_removed_rscs_tbl(l_delete_count).group_id    := l_directs_tbl(k).group_id;
                       l_removed_rscs_tbl(l_delete_count).role_code   := l_directs_tbl(k).role_code;
                       l_removed_rscs_tbl(l_delete_count).attribute1  := 'N';
                    end if;
                 END LOOP; -- l_directs_tbl
               END IF; -- l_directs_tbl.FIRST is NOT NULL
              end if; -- l_added_rscs_tbl.FIRST is NOT NULL
           end loop;  -- end of c_res loop
        end if;  -- end if alignment_id is null or imported_on_date is null
     end if; -- end if p_alignment_id is null

      JTF_TTY_NACCT_SALES_PUB.G_ADD_SALESREP_TBL:=l_add_rscs_tbl;
      JTF_TTY_NACCT_SALES_PUB.G_REM_SALESREP_TBL:=l_removed_rscs_tbl;
      JTF_TTY_NACCT_SALES_PUB.G_AFFECT_PARTY_TBL:=l_affected_parties_tbl;

   --insert into tmp2 values('what is p_alignment_id',p_alignment_id); commit;
   if p_alignment_id is null then
     --call named account update API
     --insert into tmp values('what is l_terr_group_id',l_terr_group_id); commit;
      JTF_TTY_NACCT_SALES_PUB.UPDATE_SALES_TEAM(
                   p_api_version_number    => 1,
                   p_init_msg_list         => 'N',
                   p_SQL_Trace             => 'N',
                   p_Debug_Flag            => 'N',
                   x_return_status         => x_return_status,
                   x_msg_count             => x_msg_count,
                   x_msg_data              => x_msg_data,
                   p_user_resource_id      => null,
                   p_terr_group_id         => l_terr_group_id,
                   p_user_attribute1       => fnd_global.user_id,
                   --p_user_attribute1       => 1069,
                   p_user_attribute2       => null,
                   p_added_rscs_tbl        => l_add_rscs_tbl,
                   p_removed_rscs_tbl      => l_removed_rscs_tbl,
                   p_affected_parties_tbl  => l_affected_parties_tbl,
                   ERRBUF                  => errbuf,
                   RETCODE                 => retcode
               );
    else
    --call alignment update API
    --insert into tmp2 values('calling JTF_TTY_ALIGN_WEBADI_INT_PKG.UPDATE_ALIGNMENT_TEAM',p_alignment_id); commit;

    JTF_TTY_ALIGN_WEBADI_INT_PKG.UPDATE_ALIGNMENT_TEAM(
      p_api_version_number    => 1,
      p_init_msg_list         => 'N',
      p_SQL_Trace             => 'N',
      p_Debug_Flag            => 'N',
      p_alignment_id          => p_alignment_id,
      p_user_id               => l_user_id,
      p_user_attribute1       => fnd_global.user_id,
      p_added_rscs_tbl        => l_add_rscs_tbl,
      p_removed_rscs_tbl      => l_removed_rscs_tbl,
      p_affected_parties_tbl  => l_affected_parties_tbl,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data
      );
     end if;
    --
-- insert into tmp values('2','2'); commit;

--   commit;

    exception
      when no_data_found then
         fnd_message.set_name ('JTF', 'JTF_TTY_NA_NOT_ASSIGED');
         return;

      when others then
         --insert into tmp2 values('when others SALTEAM update','when others SALTEAM update'); commit;
         fnd_message.set_name ('JTF', 'JTF_TTY_UNEXPECTED_ERROR');
         return;


    end;

end POPULATE_SALESTEAM_ALIGNMENT;


PROCEDURE POPULATE_ALIGNMENT (
       --P_USER_SEQUENCE in varchar2,
       P_NAMED_ACCOUNT in varchar2,
       P_SITE_TYPE in varchar2,
       P_TRADE_NAME in varchar2,
       P_DUNS in varchar2,
       P_GU_DUNS in varchar2,
       P_GU_NAME in varchar2,
       P_CITY in varchar2,
       P_STATE in varchar2,
       P_PROVINCE in varchar2,
       P_POSTAL_CODE in varchar2,
       P_DNB_ANNUAL_REV in varchar2,
       P_DNB_NUM_OF_EMP in varchar2,
       P_PRIOR_WON      in varchar2,
       P_TERRITORY_GROUP in varchar2,
       P_RESOURCE1_NAME in varchar2,
       P_GROUP1_NAME in varchar2,
       P_ROLE1_NAME in varchar2,
       P_RESOURCE2_NAME in varchar2,
       P_GROUP2_NAME in varchar2,
       P_ROLE2_NAME in varchar2,
       P_RESOURCE3_NAME in varchar2,
       P_GROUP3_NAME in varchar2,
       P_ROLE3_NAME in varchar2,
       P_RESOURCE4_NAME in varchar2,
       P_GROUP4_NAME in varchar2,
       P_ROLE4_NAME in varchar2,
       P_RESOURCE5_NAME in varchar2,
       P_GROUP5_NAME in varchar2,
       P_ROLE5_NAME in varchar2,
       P_RESOURCE6_NAME in varchar2,
       P_GROUP6_NAME in varchar2,
       P_ROLE6_NAME in varchar2,
       P_RESOURCE7_NAME in varchar2,
       P_GROUP7_NAME in varchar2,
       P_ROLE7_NAME in varchar2,
       P_RESOURCE8_NAME in varchar2,
       P_GROUP8_NAME in varchar2,
       P_ROLE8_NAME in varchar2,
       P_RESOURCE9_NAME in varchar2,
       P_GROUP9_NAME in varchar2,
       P_ROLE9_NAME in varchar2,
       P_RESOURCE10_NAME in varchar2,
       P_GROUP10_NAME in varchar2,
       P_ROLE10_NAME in varchar2,
       P_RESOURCE11_NAME in varchar2,
       P_GROUP11_NAME in varchar2,
       P_ROLE11_NAME in varchar2,
       P_RESOURCE12_NAME in varchar2,
       P_GROUP12_NAME in varchar2,
       P_ROLE12_NAME in varchar2,
       P_RESOURCE13_NAME in varchar2,
       P_GROUP13_NAME in varchar2,
       P_ROLE13_NAME in varchar2,
       P_RESOURCE14_NAME in varchar2,
       P_GROUP14_NAME in varchar2,
       P_ROLE14_NAME in varchar2,
       P_RESOURCE15_NAME in varchar2,
       P_GROUP15_NAME in varchar2,
       P_ROLE15_NAME in varchar2,
       P_RESOURCE16_NAME in varchar2,
       P_GROUP16_NAME in varchar2,
       P_ROLE16_NAME in varchar2,
       P_RESOURCE17_NAME in varchar2,
       P_GROUP17_NAME in varchar2,
       P_ROLE17_NAME in varchar2,
       P_RESOURCE18_NAME in varchar2,
       P_GROUP18_NAME in varchar2,
       P_ROLE18_NAME in varchar2,
       P_RESOURCE19_NAME in varchar2,
       P_GROUP19_NAME in varchar2,
       P_ROLE19_NAME in varchar2,
       P_RESOURCE20_NAME in varchar2,
       P_GROUP20_NAME in varchar2,
       P_ROLE20_NAME in varchar2,
       P_RESOURCE21_NAME in varchar2,
       P_GROUP21_NAME in varchar2,
       P_ROLE21_NAME in varchar2,
       P_RESOURCE22_NAME in varchar2,
       P_GROUP22_NAME in varchar2,
       P_ROLE22_NAME in varchar2,
       P_RESOURCE23_NAME in varchar2,
       P_GROUP23_NAME in varchar2,
       P_ROLE23_NAME in varchar2,
       P_RESOURCE24_NAME in varchar2,
       P_GROUP24_NAME in varchar2,
       P_ROLE24_NAME in varchar2,
       P_RESOURCE25_NAME in varchar2,
       P_GROUP25_NAME in varchar2,
       P_ROLE25_NAME in varchar2,
       P_RESOURCE26_NAME in varchar2,
       P_GROUP26_NAME in varchar2,
       P_ROLE26_NAME in varchar2,
       P_RESOURCE27_NAME in varchar2,
       P_GROUP27_NAME in varchar2,
       P_ROLE27_NAME in varchar2,
       P_RESOURCE28_NAME in varchar2,
       P_GROUP28_NAME in varchar2,
       P_ROLE28_NAME in varchar2,
       P_RESOURCE29_NAME in varchar2,
       P_GROUP29_NAME in varchar2,
       P_ROLE29_NAME in varchar2,
       P_RESOURCE30_NAME in varchar2,
       P_GROUP30_NAME in varchar2,
       P_ROLE30_NAME in varchar2,
       P_TERR_GRP_ACCT_ID in varchar2,
       P_ALIGNMENT_ID in varchar2) IS
BEGIN

     POPULATE_SALESTEAM_ALIGNMENT (
       P_TERRITORY_GROUP,
       P_RESOURCE1_NAME,
       P_GROUP1_NAME,
       P_ROLE1_NAME,
       P_RESOURCE2_NAME,
       P_GROUP2_NAME,
       P_ROLE2_NAME,
       P_RESOURCE3_NAME,
       P_GROUP3_NAME,
       P_ROLE3_NAME,
       P_RESOURCE4_NAME,
       P_GROUP4_NAME,
       P_ROLE4_NAME,
       P_RESOURCE5_NAME,
       P_GROUP5_NAME,
       P_ROLE5_NAME,
       P_RESOURCE6_NAME,
       P_GROUP6_NAME,
       P_ROLE6_NAME,
       P_RESOURCE7_NAME,
       P_GROUP7_NAME,
       P_ROLE7_NAME,
       P_RESOURCE8_NAME,
       P_GROUP8_NAME,
       P_ROLE8_NAME,
       P_RESOURCE9_NAME,
       P_GROUP9_NAME,
       P_ROLE9_NAME,
       P_RESOURCE10_NAME,
       P_GROUP10_NAME,
       P_ROLE10_NAME,
       P_RESOURCE11_NAME,
       P_GROUP11_NAME,
       P_ROLE11_NAME,
       P_RESOURCE12_NAME,
       P_GROUP12_NAME,
       P_ROLE12_NAME,
       P_RESOURCE13_NAME,
       P_GROUP13_NAME,
       P_ROLE13_NAME,
       P_RESOURCE14_NAME,
       P_GROUP14_NAME,
       P_ROLE14_NAME,
       P_RESOURCE15_NAME,
       P_GROUP15_NAME,
       P_ROLE15_NAME,
       P_RESOURCE16_NAME,
       P_GROUP16_NAME,
       P_ROLE16_NAME,
       P_RESOURCE17_NAME,
       P_GROUP17_NAME,
       P_ROLE17_NAME,
       P_RESOURCE18_NAME,
       P_GROUP18_NAME,
       P_ROLE18_NAME,
       P_RESOURCE19_NAME,
       P_GROUP19_NAME,
       P_ROLE19_NAME,
       P_RESOURCE20_NAME,
       P_GROUP20_NAME,
       P_ROLE20_NAME,
       P_RESOURCE21_NAME,
       P_GROUP21_NAME,
       P_ROLE21_NAME,
       P_RESOURCE22_NAME,
       P_GROUP22_NAME,
       P_ROLE22_NAME,
       P_RESOURCE23_NAME,
       P_GROUP23_NAME,
       P_ROLE23_NAME,
       P_RESOURCE24_NAME,
       P_GROUP24_NAME,
       P_ROLE24_NAME,
       P_RESOURCE25_NAME,
       P_GROUP25_NAME,
       P_ROLE25_NAME,
       P_RESOURCE26_NAME,
       P_GROUP26_NAME,
       P_ROLE26_NAME,
       P_RESOURCE27_NAME,
       P_GROUP27_NAME,
       P_ROLE27_NAME,
       P_RESOURCE28_NAME,
       P_GROUP28_NAME,
       P_ROLE28_NAME,
       P_RESOURCE29_NAME,
       P_GROUP29_NAME,
       P_ROLE29_NAME,
       P_RESOURCE30_NAME,
       P_GROUP30_NAME,
       P_ROLE30_NAME,
       P_TERR_GRP_ACCT_ID,
       'Y',
       P_ALIGNMENT_ID);

END;

PROCEDURE POPULATE_SALES_TEAM (
       --P_USER_SEQUENCE in varchar2,
       P_NAMED_ACCOUNT in varchar2,
       P_SITE_TYPE in varchar2,
       P_TRADE_NAME in varchar2,
       P_DUNS in varchar2,
       P_GU_DUNS in varchar2,
       P_GU_NAME in varchar2,
       P_CITY in varchar2,
       P_STATE in varchar2,
       P_PROVINCE in varchar2,
       P_POSTAL_CODE in varchar2,
       P_TERRITORY_GROUP in varchar2,
       P_RESOURCE1_NAME in varchar2,
       P_GROUP1_NAME in varchar2,
       P_ROLE1_NAME in varchar2,
       P_RESOURCE2_NAME in varchar2,
       P_GROUP2_NAME in varchar2,
       P_ROLE2_NAME in varchar2,
       P_RESOURCE3_NAME in varchar2,
       P_GROUP3_NAME in varchar2,
       P_ROLE3_NAME in varchar2,
       P_RESOURCE4_NAME in varchar2,
       P_GROUP4_NAME in varchar2,
       P_ROLE4_NAME in varchar2,
       P_RESOURCE5_NAME in varchar2,
       P_GROUP5_NAME in varchar2,
       P_ROLE5_NAME in varchar2,
       P_RESOURCE6_NAME in varchar2,
       P_GROUP6_NAME in varchar2,
       P_ROLE6_NAME in varchar2,
       P_RESOURCE7_NAME in varchar2,
       P_GROUP7_NAME in varchar2,
       P_ROLE7_NAME in varchar2,
       P_RESOURCE8_NAME in varchar2,
       P_GROUP8_NAME in varchar2,
       P_ROLE8_NAME in varchar2,
       P_RESOURCE9_NAME in varchar2,
       P_GROUP9_NAME in varchar2,
       P_ROLE9_NAME in varchar2,
       P_RESOURCE10_NAME in varchar2,
       P_GROUP10_NAME in varchar2,
       P_ROLE10_NAME in varchar2,
       P_RESOURCE11_NAME in varchar2,
       P_GROUP11_NAME in varchar2,
       P_ROLE11_NAME in varchar2,
       P_RESOURCE12_NAME in varchar2,
       P_GROUP12_NAME in varchar2,
       P_ROLE12_NAME in varchar2,
       P_RESOURCE13_NAME in varchar2,
       P_GROUP13_NAME in varchar2,
       P_ROLE13_NAME in varchar2,
       P_RESOURCE14_NAME in varchar2,
       P_GROUP14_NAME in varchar2,
       P_ROLE14_NAME in varchar2,
       P_RESOURCE15_NAME in varchar2,
       P_GROUP15_NAME in varchar2,
       P_ROLE15_NAME in varchar2,
       P_RESOURCE16_NAME in varchar2,
       P_GROUP16_NAME in varchar2,
       P_ROLE16_NAME in varchar2,
       P_RESOURCE17_NAME in varchar2,
       P_GROUP17_NAME in varchar2,
       P_ROLE17_NAME in varchar2,
       P_RESOURCE18_NAME in varchar2,
       P_GROUP18_NAME in varchar2,
       P_ROLE18_NAME in varchar2,
       P_RESOURCE19_NAME in varchar2,
       P_GROUP19_NAME in varchar2,
       P_ROLE19_NAME in varchar2,
       P_RESOURCE20_NAME in varchar2,
       P_GROUP20_NAME in varchar2,
       P_ROLE20_NAME in varchar2,
       P_RESOURCE21_NAME in varchar2,
       P_GROUP21_NAME in varchar2,
       P_ROLE21_NAME in varchar2,
       P_RESOURCE22_NAME in varchar2,
       P_GROUP22_NAME in varchar2,
       P_ROLE22_NAME in varchar2,
       P_RESOURCE23_NAME in varchar2,
       P_GROUP23_NAME in varchar2,
       P_ROLE23_NAME in varchar2,
       P_RESOURCE24_NAME in varchar2,
       P_GROUP24_NAME in varchar2,
       P_ROLE24_NAME in varchar2,
       P_RESOURCE25_NAME in varchar2,
       P_GROUP25_NAME in varchar2,
       P_ROLE25_NAME in varchar2,
       P_RESOURCE26_NAME in varchar2,
       P_GROUP26_NAME in varchar2,
       P_ROLE26_NAME in varchar2,
       P_RESOURCE27_NAME in varchar2,
       P_GROUP27_NAME in varchar2,
       P_ROLE27_NAME in varchar2,
       P_RESOURCE28_NAME in varchar2,
       P_GROUP28_NAME in varchar2,
       P_ROLE28_NAME in varchar2,
       P_RESOURCE29_NAME in varchar2,
       P_GROUP29_NAME in varchar2,
       P_ROLE29_NAME in varchar2,
       P_RESOURCE30_NAME in varchar2,
       P_GROUP30_NAME in varchar2,
       P_ROLE30_NAME in varchar2,
       P_TERR_GRP_ACCT_ID in varchar2
       ) IS
BEGIN

    POPULATE_SALESTEAM_ALIGNMENT (
       P_TERRITORY_GROUP,
       P_RESOURCE1_NAME,
       P_GROUP1_NAME,
       P_ROLE1_NAME,
       P_RESOURCE2_NAME,
       P_GROUP2_NAME ,
       P_ROLE2_NAME ,
       P_RESOURCE3_NAME ,
       P_GROUP3_NAME ,
       P_ROLE3_NAME ,
       P_RESOURCE4_NAME ,
       P_GROUP4_NAME ,
       P_ROLE4_NAME ,
       P_RESOURCE5_NAME ,
       P_GROUP5_NAME ,
       P_ROLE5_NAME ,
       P_RESOURCE6_NAME ,
       P_GROUP6_NAME ,
       P_ROLE6_NAME ,
       P_RESOURCE7_NAME ,
       P_GROUP7_NAME ,
       P_ROLE7_NAME ,
       P_RESOURCE8_NAME ,
       P_GROUP8_NAME ,
       P_ROLE8_NAME ,
       P_RESOURCE9_NAME ,
       P_GROUP9_NAME ,
       P_ROLE9_NAME ,
       P_RESOURCE10_NAME ,
       P_GROUP10_NAME ,
       P_ROLE10_NAME ,
       P_RESOURCE11_NAME ,
       P_GROUP11_NAME ,
       P_ROLE11_NAME ,
       P_RESOURCE12_NAME ,
       P_GROUP12_NAME ,
       P_ROLE12_NAME ,
       P_RESOURCE13_NAME ,
       P_GROUP13_NAME ,
       P_ROLE13_NAME ,
       P_RESOURCE14_NAME ,
       P_GROUP14_NAME ,
       P_ROLE14_NAME ,
       P_RESOURCE15_NAME ,
       P_GROUP15_NAME ,
       P_ROLE15_NAME ,
       P_RESOURCE16_NAME ,
       P_GROUP16_NAME ,
       P_ROLE16_NAME ,
       P_RESOURCE17_NAME ,
       P_GROUP17_NAME ,
       P_ROLE17_NAME ,
       P_RESOURCE18_NAME ,
       P_GROUP18_NAME ,
       P_ROLE18_NAME ,
       P_RESOURCE19_NAME ,
       P_GROUP19_NAME ,
       P_ROLE19_NAME ,
       P_RESOURCE20_NAME ,
       P_GROUP20_NAME ,
       P_ROLE20_NAME ,
       P_RESOURCE21_NAME ,
       P_GROUP21_NAME ,
       P_ROLE21_NAME ,
       P_RESOURCE22_NAME ,
       P_GROUP22_NAME ,
       P_ROLE22_NAME ,
       P_RESOURCE23_NAME ,
       P_GROUP23_NAME ,
       P_ROLE23_NAME ,
       P_RESOURCE24_NAME ,
       P_GROUP24_NAME ,
       P_ROLE24_NAME ,
       P_RESOURCE25_NAME ,
       P_GROUP25_NAME ,
       P_ROLE25_NAME ,
       P_RESOURCE26_NAME ,
       P_GROUP26_NAME ,
       P_ROLE26_NAME ,
       P_RESOURCE27_NAME ,
       P_GROUP27_NAME ,
       P_ROLE27_NAME ,
       P_RESOURCE28_NAME ,
       P_GROUP28_NAME ,
       P_ROLE28_NAME ,
       P_RESOURCE29_NAME ,
       P_GROUP29_NAME ,
       P_ROLE29_NAME ,
       P_RESOURCE30_NAME ,
       P_GROUP30_NAME ,
       P_ROLE30_NAME ,
       P_TERR_GRP_ACCT_ID ,
       'N',  -- P_ALIGNMENT_FLAG ,
       null  --P_ALIGNMENT_ID
       );

END;


END JTF_TTY_WEBADI_salsteam_update;

/
