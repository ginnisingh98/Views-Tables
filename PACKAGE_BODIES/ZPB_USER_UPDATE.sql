--------------------------------------------------------
--  DDL for Package Body ZPB_USER_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_USER_UPDATE" AS
/* $Header: zpbusersynch.plb 120.20 2007/12/04 16:20:41 mbhat ship $ */
        procedure synch_users(p_business_area_id NUMBER) as

        b_userexists boolean :=true;
        b_groupexists boolean :=true;
        b_writetolog boolean :=false;
        t_subjecttype bism_subjects.subject_type%type;
        t_subname bism_subjects.subject_name%type;
        t_newguid bism_objects.object_id%type := null;
        t_subid1 bism_subjects.subject_id%type;
        t_subjecttype1 bism_subjects.subject_type%type;
        t_subid2 bism_subjects.subject_id%type;
        t_subjecttype2 bism_subjects.subject_type%type;
        n_status zpb_account_states.account_status%type;
        t_objectid bism_objects.object_id%type :='31';
        n_comboexists number :=0;
        n_namelength number :=64;
        n_epbproductid number :=210;
        n_writepermission number :=20;

        l_subj_user_id   bism_subjects.subject_id%type;
        l_subj_resp_id   bism_subjects.subject_id%type;
        l_user_exists    VARCHAR2(1);

        cursor usernames is
                select /*+ LEADING (c) */ distinct(a.user_name) name, a.user_id
                from fnd_user a, fnd_user_resp_groups b, fnd_responsibility c
                where a.user_id=b.user_id
                   and b.responsibility_id=c.responsibility_id
                   and c.application_id=n_epbproductid;

        cursor groups is
                select responsibility_key role
                from fnd_responsibility
                where application_id = n_epbproductid;

        CURSOR expired_user_resp_csr
        IS
        SELECT z.user_id, z.resp_id
        FROM   zpb_account_states z,
               fnd_user u
        WHERE  z.user_id = u.user_id
        AND    (u.end_date IS NOT NULL AND u.end_date < SYSDATE)
        AND    z.business_area_id = p_business_area_id
        UNION
        SELECT /*+ LEADING (r) */ z.user_id, z.resp_id
        FROM   zpb_account_states z,
               fnd_user_resp_groups_all u,
               fnd_responsibility r
        WHERE  z.user_id = u.user_id
        AND    z.resp_id = u.responsibility_id
        AND    (u.end_date IS NOT NULL AND u.end_date < SYSDATE)
        AND    r.responsibility_id = u.responsibility_id
        AND    r.responsibility_key <> 'ZPB_MANAGER_RESP'
        AND    z.business_area_id = p_business_area_id
        AND    r.application_id = n_epbproductid
        UNION
        SELECT z.user_id, z.resp_id
        FROM   zpb_account_states z,
               fnd_responsibility u
        WHERE  z.resp_id = u.responsibility_id
        AND    (u.end_date IS NOT NULL AND u.end_date < SYSDATE)
        AND    u.responsibility_key <> 'ZPB_MANAGER_RESP'
        AND    z.business_area_id = p_business_area_id
        AND    u.application_id = n_epbproductid;

        CURSOR new_user_resp_csr
        IS
        SELECT z.user_id, z.resp_id
        FROM   zpb_account_states z,
               fnd_user u
        WHERE  z.user_id = u.user_id
        AND    (u.end_date IS NULL OR u.end_date >= SYSDATE)
        AND    z.business_area_id = p_business_area_id
        UNION
        SELECT /*+ LEADING (z) */ z.user_id, z.resp_id
        FROM   zpb_account_states z,
               fnd_user_resp_groups_all u
        WHERE  z.user_id = u.user_id
        AND    (u.end_date IS NULL OR u.end_date >= SYSDATE)
        AND    z.business_area_id = p_business_area_id
        AND    responsibility_application_id = n_epbproductid
        UNION
        SELECT z.user_id, z.resp_id
        FROM   zpb_account_states z,
               fnd_responsibility u
        WHERE  z.resp_id = u.responsibility_id
        AND    (u.end_date IS NULL OR u.end_date >= SYSDATE)
        AND    z.business_area_id = p_business_area_id
        AND    u.application_id = n_epbproductid;

        CURSOR brand_new_user_resp_csr
        IS
        SELECT /*+ LEADING (b) */ a.user_id, a.responsibility_id resp_id
        FROM   fnd_user_resp_groups a, fnd_responsibility b
        WHERE  a.responsibility_id = b.responsibility_id
        AND    b.application_id = n_epbproductid
        MINUS
        SELECT user_id, resp_id
        FROM   zpb_account_states
        WHERE  business_area_id = p_business_area_id;

        cursor grantedroles is
           select /*+ LEADING (c) */
              a.user_name grantee,
              a.user_id,
              c.responsibility_key granted_role,
              c.responsibility_id,
              b.creation_date,
              b1.subject_id user_sub_id,
              b1.subject_type user_sub_type,
              b2.subject_id resp_sub_id,
              b2.subject_type resp_sub_type,
              b2.subject_name resp_sub_name
            from fnd_user a,
              fnd_user_resp_groups b,
              fnd_responsibility c,
              bism_subjects b1,
              bism_subjects b2
            where a.user_id = b.user_id and
              (c.end_date is NULL or c.end_date > SYSDATE) and
                 b.responsibility_id=c.responsibility_id and
                 c.application_id=n_epbproductid and
                 b1.subject_name =  a.user_name and
                 b1.subject_type = 'u' and
                 b2.subject_name = c.responsibility_key and
                 b2.subject_type = 'g' and
                 a.user_id not in (select user_id from zpb_account_states ast
                                   where b1.subject_id = ast.subject_id and
                                   b2.subject_id = ast.group_id and
                                   ast.business_Area_id = p_business_area_id);

        cursor deleted is
                select subject_name from bism_subjects
                where subject_name <> BIBEANS and subject_name <> ZPBUSER
                minus
                   (select /*+ LEADING (c) */ distinct(a.user_name)
                    from fnd_user a,
                    fnd_user_resp_groups b,
                    fnd_responsibility c
                   where a.user_id=b.user_id
                    and (a.end_date is NULL or a.end_date >= SYSDATE)
                    and b.responsibility_id=c.responsibility_id
                    and c.application_id=n_epbproductid
                    union
                    select responsibility_key
                    from fnd_responsibility
                    where application_id = n_epbproductid);
        --
        -- Cursor is LEADING because very few rows in zpb_account_states
        -- should returned at all
        --
        cursor reinstated is
                select /*+LEADING (x) */ y.subject_name
                 from zpb_account_states x,
                   bism_subjects y,
                   fnd_user a,
                   fnd_user_resp_groups b,
                   fnd_responsibility c
                 where x.subject_id = y.subject_id
                   and x.business_area_id = p_business_area_id
                   and x.account_status in (EXP_USER, HIDE_ACCOUNT)
                   and x.user_id = a.user_id
                   and a.user_id=b.user_id
                   and b.responsibility_id=c.responsibility_id
                   and c.application_id=n_epbproductid
                   and (a.end_date is null or a.end_date > SYSDATE)
                   and (b.end_date is NULL or b.end_date > SYSDATE);

        --      replace from bism_groups with from zpb_account_states
--              where user_id = u.subject_id
--                      and group_id = g.subject_id
--                      and user_id <> group_id
        cursor revokedroles is
           select u.subject_name uname, g.subject_name gname
              from zpb_account_states s,
              bism_subjects u,
              bism_subjects g
            where s.account_status <> HIDE_ACCOUNT
              and u.subject_id = s.subject_id
              and g.subject_id = s.group_id
              and s.business_area_id = p_business_area_id
              minus
                (select /*+ LEADING (c) */ a.user_name, c.responsibility_key
                from fnd_user a, fnd_user_resp_groups b, fnd_responsibility c
                where a.user_id = b.user_id
                        and (b.end_date is NULL or b.end_date > SYSDATE)
                        and b.responsibility_id=c.responsibility_id
                        and c.application_id=n_epbproductid);

--    roles resinstated for an active user.
        cursor reinstatedroles is
           select  /*+LEADING (s) */ a.user_name uname, c.responsibility_key gname
              from fnd_user a, fnd_user_resp_groups b, fnd_responsibility c,
              zpb_account_states s, bism_subjects u, bism_subjects g
              where a.user_id = b.user_id
              and (a.end_date is NULL or a.end_date > SYSDATE)
                 and (b.end_date is NULL or b.end_date > SYSDATE)
                    and b.responsibility_id=c.responsibility_id
                    and c.application_id=n_epbproductid
                    and u.subject_id = s.subject_id
                    and g.subject_id = s.group_id
                    and s.business_area_id = p_business_area_id
                    and s.account_status in (EXP_USER, HIDE_ACCOUNT)
                    and a.user_id = s.user_id
                    and c.responsibility_key = g.subject_name;

begin
      -- check logging requirement for this module
   b_writetolog := (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL);
   --FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME);

      -- loop for adding users to the Catalog from the fnd_user table
      for each in usernames loop
         if length(each.name) <= n_namelength then
         begin
            b_userexists := true;
            -- checking user in the Catalog
            select SUBJECT_NAME,SUBJECT_TYPE into t_subname,t_subjecttype from bism_subjects where subject_name = each.name;
            -- the following condition should not happen but putting in an additional check
            if t_subname is null then
               b_userexists := false;
            end if;

         exception
            when no_data_found then
               b_userexists := false;
         end;

         if b_userexists = false then
            t_newguid := bism_utils.get_guid;
            insert into bism_subjects (subject_id, subject_name, subject_type) values (t_newguid,each.name,'u');
            insert into bism_groups (user_id, group_id) values(t_newguid,t_newguid);

            if (b_writetolog) then
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                              'User with name '|| each.name||' has been added successfully');
            end if;
          else
            if t_subjecttype = 'g' then
               if (b_writetolog) then
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                                 'A group already exists with name '|| each.name);
               end if;
             else
               if (b_writetolog) then
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                                 'User '|| each.name ||' already exists');
               end if;
            end if;
         end if;
         end if;
      end loop;

      -- loop for adding groups to the Catalog from the RDBMS

      for eachgroup in groups loop
         if length(eachgroup.role)>n_namelength then
            if (b_writetolog) then
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                              eachgroup.role||' can not be added to the Catalog because it has more than n_namelength chars');
            end if;
          else
            begin
               b_groupexists := true;

               -- checking group in the Catalog
               select SUBJECT_NAME,SUBJECT_TYPE
                  into t_subname,t_subjecttype
                  from bism_subjects
                  where subject_name = eachgroup.role;

               -- the following condition should not happen but putting in an additional check
               if t_subname is null then
                  b_groupexists := false;
               end if;

            exception
               when no_data_found then
                  b_groupexists := false;
            end;

            if b_groupexists = false then
               t_newguid := bism_utils.get_guid;
               insert into bism_subjects (subject_id, subject_name, subject_type) values(t_newguid,eachgroup.role,'g');

               -- give user some default privileges
               insert into bism_permissions(subject_id, object_id, privilege) values(t_newguid, t_objectid, n_writepermission);

               if (b_writetolog) then
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                                 'Group with name '|| eachgroup.role||' has been added successfully');
               end if;
             else
               if t_subjecttype = 'u' then
                  if (b_writetolog) then
                     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                                    'A user already exists with name '|| eachgroup.role);
                  end if;
                else
                  if (b_writetolog) then
                     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                                    'Group '|| eachgroup.role ||' already exists');
                  end if;
               end if;
            end if;
         end if;
      end loop;

      FOR new_user_resp_rec IN new_user_resp_csr LOOP

        UPDATE zpb_account_states
        SET    account_status = 10,
               last_updated_by =  fnd_global.user_id,
               last_update_date = SYSDATE,
               last_update_login = fnd_global.login_id,
               account_status_update_date = SYSDATE
        WHERE  business_area_id = p_business_area_id
        AND    user_id = new_user_resp_rec.user_id
        AND    resp_id = new_user_resp_rec.resp_id
        -- Fix for Bug:5579658
        -- AND    account_status NOT IN (-100,0);
        AND account_status <> 0;

      END LOOP;

      FOR brand_new_user_resp_rec IN brand_new_user_resp_csr LOOP

          SELECT subject_id
          INTO   l_subj_user_id
          FROM   bism_subjects a,
                 fnd_user b
          WHERE  a.subject_name = b.user_name
          AND    b.user_id = brand_new_user_resp_rec.user_id
          AND    a.subject_type = 'u';

          SELECT subject_id
          INTO   l_subj_resp_id
          FROM   bism_subjects a,
                 fnd_responsibility b
          WHERE  a.subject_name = b.responsibility_key
          AND    b.responsibility_id = brand_new_user_resp_rec.resp_id
          AND    a.subject_type = 'g';

          INSERT INTO zpb_account_states
          (subject_id,
           group_id,
           business_area_id,
           user_id,
           resp_id,
           assignee,
           account_status,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           account_status_update_date)
          VALUES
          (l_subj_user_id,
           l_subj_resp_id,
           p_business_area_id,
           brand_new_user_resp_rec.user_id,
           brand_new_user_resp_rec.resp_id,
           null,
           ADD_ROLE,
           fnd_global.user_id,
           SYSDATE,
           fnd_global.user_id,
           SYSDATE,
           fnd_global.login_id,
           SYSDATE);

      END LOOP;

      FOR expired_user_resp_rec IN expired_user_resp_csr LOOP

        UPDATE zpb_account_states
        SET    account_status = -10,
               last_updated_by =  fnd_global.user_id,
               last_update_date = SYSDATE,
               last_update_login = fnd_global.login_id,
               account_status_update_date = SYSDATE
        WHERE  business_area_id = p_business_area_id
        AND    user_id = expired_user_resp_rec.user_id
        AND    resp_id = expired_user_resp_rec.resp_id
        AND    account_status <> -100;

      END LOOP;
/*----------------------------------------------------------------------------------------------
-- Commented out for Bug: 5077013
      -- loop for adding users to groups within the Catalog from the RDBMS
      for eachgrant in grantedroles loop
         begin
               t_subid1:=eachgrant.user_sub_id;
               t_subid2:=eachgrant.resp_sub_id;
               t_subjecttype1:=eachgrant.user_sub_type;
               t_subjecttype2:=eachgrant.resp_sub_type;

               -- only users can belong to groups
               if t_subjecttype1 <> 'u' then
                  if (b_writetolog) then
                     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                                    eachgrant.grantee||' is not a user. It can not be added to a group');
                  end if;
                elsif t_subjecttype2 <> 'g' then
                  if (b_writetolog) then
                     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                                    eachgrant.granted_role||' is not a group. Users can not be added to it');
                  end if;
                else
                  if t_subid1 is not null and t_subid2 is not null then
                     --insert into bism_groups (user_id, group_id) values(t_subid1,t_subid2);

                     -- update user state to indicate a new role has been added
                                         t_subname:=eachgrant.resp_sub_name;


                     -- could be an existing entry
                     update zpb_account_states
                        set account_status = ADD_ROLE,
                        LAST_UPDATED_BY = fnd_global.USER_ID,
                        LAST_UPDATE_DATE = SYSDATE,
                        LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID,
                        ACCOUNT_STATUS_UPDATE_DATE = SYSDATE
                        where subject_id = t_subid1
                        and group_id = t_subid2
                        and business_area_id = p_business_area_id;

                     if SQL%NOTFOUND then
                        -- delete any obsolete entries
                        delete zpb_account_states
                           where user_id = eachgrant.user_id
                           and resp_id = eachgrant.responsibility_id
                           and business_area_id = p_business_area_id;
                        if SQL%NOTFOUND then
                           if (b_writetolog) then
                              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME, 'A new user ' ||eachgrant.grantee||
                                             ' will be added to the group '|| eachgrant.granted_role);
                           end if;
                         else
                           if (b_writetolog) then
                              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME, 'The existing user-group entry '||
                                             eachgrant.grantee||' -  '|| eachgrant.granted_role || ' will be overwritten');
                           end if;
                        end if;

                        insert into zpb_account_states
                           (subject_id,
                            group_id,
                            business_area_id,
                            user_id,
                            resp_id,
                            assignee,
                            account_status,
                            CREATED_BY,
                            CREATION_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATE_LOGIN,
                            ACCOUNT_STATUS_UPDATE_DATE)
                           values(t_subid1,
                                  t_subid2,
                                  p_business_area_id,
                                  eachgrant.user_id,
                                  eachgrant.responsibility_id,
                                  null,
                                  ADD_ROLE,
                                  fnd_global.USER_ID,
                                  SYSDATE,
                                  fnd_global.USER_ID,
                                  SYSDATE,
                                  fnd_global.LOGIN_ID,
                                  SYSDATE);
                     end if;

                     if (b_writetolog) then
                        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                                       'User '||eachgrant.grantee||' has been added to the group '|| eachgrant.granted_role);
                     end if;
                   else
                     if (b_writetolog) then
                        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                                       'Subject ids are null for the relationship between '||eachgrant.grantee||
                                       ' and '||eachgrant.granted_role);
                     end if;
                  end if;
               end if;

         exception
            when no_data_found then
               if (b_writetolog) then
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                                 'Either user '||eachgrant.grantee||' does not exist or group '||
                                 eachgrant.granted_role||' does not exist');
               end if;
         end;

      end loop;

      -- delete users and groups that are no longer in the EPB domain
      for eachdeleted in deleted loop

         select subject_id into t_subid1
            from bism_subjects
            where subject_name = eachdeleted.subject_name;

        --remove the following code to ensure hidden accounts
        --do not get reset to expired, bug 2968955
        -- n_status := EXP_USER;
        -- for user_acc_stat in (select account_status
        --                       from zpb_account_states
        --                       where subject_id = t_subid1
        --                       and business_area_id = p_business_area_id) loop
        --    if user_acc_stat.account_status = HIDE_ACCOUNT then
        --       n_status := HIDE_ACCOUNT;
        --       exit;
        --    end if;
        -- end loop;

         -- Do not turn off read access until the user has been re-assigned or deleted.
         -- mark all existing user accounts as expired
         --if n_status <> HIDE_ACCOUNT then
            update zpb_account_states
               set account_status         = EXP_USER,
               LAST_UPDATED_BY            =  fnd_global.USER_ID,
               LAST_UPDATE_DATE           = SYSDATE,
               LAST_UPDATE_LOGIN          = fnd_global.LOGIN_ID,
               ACCOUNT_STATUS_UPDATE_DATE = SYSDATE
               -- Commented out for Bug: 5007124
               -- HAS_READ_ACCESS            = 0
               where subject_id = t_subid1
               and business_area_id = p_business_area_id
               and account_status <> HIDE_ACCOUNT;
         --end if;

         if (b_writetolog) then
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                           'Deleted '||eachdeleted.subject_name);
         end if;

      end loop;

      -- reset reinstated(unexpired) users
      for eachreinstated in reinstated loop
         select subject_id into t_subid1
            from bism_subjects
            where subject_name = eachreinstated.subject_name;

         -- mark all accounts as new
         update zpb_account_states
            set account_status = NEW_USER,
            assignee           = null,
            LAST_UPDATED_BY    =  fnd_global.USER_ID,
            LAST_UPDATE_DATE   = SYSDATE,
            LAST_UPDATE_LOGIN  = fnd_global.LOGIN_ID,
            ACCOUNT_STATUS_UPDATE_DATE = SYSDATE
            where subject_id = t_subid1
            and account_status <> CURRENT_USER
            and business_area_id = p_business_area_id;

         if (b_writetolog) then
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                           'Reinstated '||eachreinstated.subject_name);
         end if;
      end loop;

      -- remove users from groups whose relationship no longer exists in the EPB domain
      for eachrevoked in revokedroles loop

         select subject_id into t_subid1
            from bism_subjects
            where subject_name = eachrevoked.uname;

         select subject_id into t_subid2
            from bism_subjects
            where subject_name = eachrevoked.gname;

--              delete bism_groups
--                      where user_id = t_subid1
--                      and group_id = t_subid2;

         -- update the user state table to indicate removed role
         update zpb_account_states
            set account_status = RMV_ROLE,
            LAST_UPDATED_BY =  fnd_global.USER_ID,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID,
            ACCOUNT_STATUS_UPDATE_DATE = SYSDATE
            where subject_id = t_subid1
            and group_id = t_subid2
            and business_area_id = p_business_area_id
            and not(account_status = EXP_USER or account_status = HIDE_ACCOUNT);

         if (b_writetolog) then
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                           'Deleted relationship between user '||eachrevoked.uname||' and group '||eachrevoked.gname);
         end if;
      end loop;

      -- reset reinstated(unexpired) roles for active users
      for eachreinstatedrole in reinstatedroles loop
         select subject_id into t_subid1
            from bism_subjects
            where subject_name = eachreinstatedrole.uname;

         select subject_id into t_subid2
            from bism_subjects
            where subject_name = eachreinstatedrole.gname;

         -- mark all accounts as new
         update zpb_account_states
            set account_status = NEW_USER,
            assignee           = null,
            LAST_UPDATED_BY    =  fnd_global.USER_ID,
            LAST_UPDATE_DATE   = SYSDATE,
            LAST_UPDATE_LOGIN  = fnd_global.LOGIN_ID,
            ACCOUNT_STATUS_UPDATE_DATE = SYSDATE
           where subject_id = t_subid1
            and group_id   = t_subid2
            and business_area_id = p_business_area_id;

         if (b_writetolog) then
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, MODULE_NAME,
                           'Reinstated '||eachreinstatedrole.uname||'-'||eachreinstatedrole.gname);
         end if;
      end loop;

      -- set status of new Schema Admininstrator accounts to Current
      update zpb_account_states
      set account_status = CURRENT_USER
      where (account_status = ADD_ROLE
        or account_status = NEW_USER)
      and business_area_id = p_business_area_id
      and resp_id = (
        select unique(responsibility_id)
          from fnd_responsibility
          where responsibility_key = SCHEMA_ADMIN);

----------------------------------------------------------------------------------------------------------------*/
      --remove expired admin accounts from ZPB_BUSAREA_USERS table and then ...
        update_admin_entries(p_business_area_id);
      --
      -- Catch new users who have already been added to BA:
      --
        SYNCH_SECURITY_USERS(p_business_area_id);

end synch_users;

procedure init_user_session (p_user_id          in number,
                             p_resp_id          in number,
                             p_business_area_id in number) is

    l_subject_id bism_subjects.subject_id%type;
    l_group_id   bism_subjects.subject_id%type;

    begin

       savepoint init_user_session;
       --
       -- temp: todo
       --
      select subject_id, group_id
        into l_subject_id, l_group_id
        from zpb_account_states
        where user_id = p_user_id
         and resp_id = p_resp_id
         and business_area_id = p_business_area_id;

      --delete any existing entries for this user
      delete from bism_groups
        where user_id = l_subject_id
         and user_id <> group_id;

      --exception
      --  when no_data_found then
        --do nothing

      insert into bism_groups
        (user_id, group_id)
        values(l_subject_id, l_group_id);

      --exception
      --  when no_data_found then
      --    rollback to init_user_session;

end init_user_session;

--
-- Procedure that will insert rows into ZPB_USERS for any security
-- administrators who have access to a business area.  Called from
-- the business area user's screen
--
procedure synch_security_users (p_business_area_id in number)
is
n_epbproductid number :=210;

CURSOR expired_sec_user_resp_csr
IS
SELECT z.user_id, z.resp_id
FROM   zpb_account_states z,
       fnd_user u
WHERE  z.user_id = u.user_id
AND    (u.end_date IS NOT NULL AND u.end_date < SYSDATE)
AND    z.business_area_id = p_business_area_id
UNION
SELECT /*+ LEADING (r) */ z.user_id, z.resp_id
FROM   zpb_account_states z,
       fnd_user_resp_groups_all u,
       fnd_responsibility r
WHERE  z.user_id = u.user_id
AND    z.resp_id = u.responsibility_id
AND    z.resp_id = r.responsibility_id
AND    (u.end_date IS NOT NULL AND u.end_date < SYSDATE)
AND    r.responsibility_key = 'ZPB_MANAGER_RESP'
AND    z.business_area_id = p_business_area_id
AND    responsibility_application_id = n_epbproductid
UNION
SELECT z.user_id, z.resp_id
FROM   zpb_account_states z,
       fnd_responsibility u
WHERE  z.resp_id = u.responsibility_id
AND    (u.end_date IS NOT NULL AND u.end_date < SYSDATE)
AND    u.responsibility_key = 'ZPB_MANAGER_RESP'
AND    z.business_area_id = p_business_area_id
AND    u.application_id = n_epbproductid;

-- Fix for Bug: 5620740
CURSOR new_sec_user_resp_csr
IS
SELECT a.user_id, a.resp_id
FROM   zpb_account_states a,
       fnd_user b,
       fnd_responsibility c,
       fnd_user_resp_groups d,
       zpb_busarea_users e
WHERE  a.user_id = b.user_id
AND    a.resp_id = c.responsibility_id
AND    a.resp_id = d.responsibility_id
AND    a.user_id = d.user_id
AND    b.user_id = d.user_id
AND    c.responsibility_id = d.responsibility_id
and    a.user_id = e.user_id
and    b.user_id = e.user_id
and    d.user_id = e.user_id
and    a.business_area_id = e.business_area_id
AND    (b.end_date IS NULL OR b.end_date >= SYSDATE)
AND    (c.end_date IS NULL OR c.end_date >= SYSDATE)
AND    (d.end_date IS NULL OR d.end_date >= SYSDATE)
AND    a.business_area_id = p_business_area_id
AND    d.responsibility_application_id = n_epbproductid
AND    c.responsibility_key = 'ZPB_MANAGER_RESP';

begin
   insert into ZPB_USERS
      (BUSINESS_AREA_ID,
       USER_ID,
       LAST_BUSAREA_LOGIN,
       SHADOW_ID,
       PERSONAL_AW,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY)
     select /*+ LEADING (c) */
      p_business_area_id,
      A.USER_ID,
      'N',
      A.USER_ID,
      'ZPB'||A.USER_ID||'A'||p_business_area_id,
      sysdate,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.LOGIN_ID,
      sysdate,
      FND_GLOBAL.USER_ID
     from ZPB_BUSAREA_USERS A,
      FND_USER_RESP_GROUPS B,
      FND_RESPONSIBILITY C
     where A.USER_ID = B.USER_ID
      and B.RESPONSIBILITY_APPLICATION_ID = 210
      and B.RESPONSIBILITY_ID = C.RESPONSIBILITY_ID
      and C.APPLICATION_ID = 210
      and C.RESPONSIBILITY_KEY = 'ZPB_MANAGER_RESP'
      and A.BUSINESS_AREA_ID = p_business_area_id
      and A.USER_ID not in
      (select distinct D.USER_ID
       from ZPB_USERS D
       where D.BUSINESS_AREA_ID = p_business_area_id);

/* ----------------------------------------------------------------------------
   Replaced this update statement with the following for Bug: 5077013.
   This statement blindly updates the account_status to CURRENT_USER (0)
   regardless of whether the responsibility is currently valid or not.
   The replaced statement will set the account_status to CURRENT_USER only if
   the responsibility is valid (i.e not end-dated with end_date < sysdate).

   update ZPB_ACCOUNT_STATES A
      set ACCOUNT_STATUS = CURRENT_USER
      where A.BUSINESS_AREA_ID = p_business_area_id
      and A.USER_ID in
      (select B.USER_ID
       from ZPB_BUSAREA_USERS B
       where B.BUSINESS_AREA_ID = p_business_area_id)
      and A.RESP_ID =
      (select C.RESPONSIBILITY_ID
       from FND_RESPONSIBILITY C
       where C.APPLICATION_ID = 210
       and C.RESPONSIBILITY_KEY = 'ZPB_MANAGER_RESP');

   update ZPB_ACCOUNT_STATES A
   set ACCOUNT_STATUS = CURRENT_USER
   where A.BUSINESS_AREA_ID = p_business_area_id
   and exists (select B.USER_ID
                     from ZPB_BUSAREA_USERS B
                     where B.BUSINESS_AREA_ID = p_business_area_id
                     and b.USER_ID = A.USER_ID)
   and (A.RESP_ID = (select C.RESPONSIBILITY_ID
                    from FND_RESPONSIBILITY C, fnd_user_resp_groups_all d
                    where C.APPLICATION_ID = 210
                    and C.RESPONSIBILITY_KEY = 'ZPB_MANAGER_RESP'
                    and c.responsibility_id = d.responsibility_id
                    and d.user_id = a.user_id
                    and (d.end_date is NULL or d.end_date >= sysdate))
       and exists (select user_id
                        from fnd_user fu
                        where nvl(fu.end_date,sysdate) >= sysdate
                        and A.user_id = fu.user_id));

   -- Added the following update statement for Bug: 5077013
   -- This statement will set the account_status to RMV_ROLE (-10) if the
   -- responsibility is end-dated with end_date < sysdate.

   update ZPB_ACCOUNT_STATES A
   set ACCOUNT_STATUS = RMV_ROLE
   where A.BUSINESS_AREA_ID = p_business_area_id
   and (A.RESP_ID in (select C.RESPONSIBILITY_ID
                    from FND_RESPONSIBILITY C, fnd_user_resp_groups_all d
                    where C.APPLICATION_ID = 210
                    and c.responsibility_id = d.responsibility_id
                    and C.RESPONSIBILITY_KEY = 'ZPB_MANAGER_RESP'
                    and d.user_id = a.user_id
                    and d.end_date is NOT NULL
                    and d.end_date < sysdate)
       or A.USER_ID = (select user_id
                       from fnd_user fu
                       where nvl(fu.end_date,sysdate) < sysdate
                       and A.user_id = fu.user_id));

   update ZPB_ACCOUNT_STATES A
      set A.ACCOUNT_STATUS = ADD_ROLE
      where A.BUSINESS_AREA_ID = p_business_area_id
      and   A.ACCOUNT_STATUS = RMV_ROLE
      and (A.RESP_ID in (select C.RESPONSIBILITY_ID
                        from FND_RESPONSIBILITY C, fnd_user_resp_groups_all d
                        where C.APPLICATION_ID = 210
                        and C.RESPONSIBILITY_KEY = 'ZPB_MANAGER_RESP'
                        and c.responsibility_id = d.responsibility_id
                        and (d.end_date IS NULL or d.end_date >= sysdate))
          and A.USER_ID = (select user_id
                          from fnd_user fu
                          where nvl(fu.end_date, sysdate) >= sysdate
                          and A.user_id = fu.user_id));
----------------------------------------------------------------------------------*/

  FOR new_sec_user_resp_rec IN new_sec_user_resp_csr LOOP
    -- Fix for Bug: 5620740
    UPDATE zpb_account_states
    SET    account_status = 0,
           last_updated_by =  fnd_global.user_id,
           last_update_date = SYSDATE,
           last_update_login = fnd_global.login_id,
           account_status_update_date = SYSDATE
    WHERE  business_area_id = p_business_area_id
    AND    user_id = new_sec_user_resp_rec.user_id
    AND    resp_id = new_sec_user_resp_rec.resp_id
    AND    account_status = 10;

  END LOOP;

  FOR expired_sec_user_resp_rec IN expired_sec_user_resp_csr LOOP

    UPDATE zpb_account_states
    SET    account_status = -10,
           last_updated_by =  fnd_global.user_id,
           last_update_date = SYSDATE,
           last_update_login = fnd_global.login_id,
           account_status_update_date = SYSDATE
    WHERE  business_area_id = p_business_area_id
    AND    user_id = expired_sec_user_resp_rec.user_id
    AND    resp_id = expired_sec_user_resp_rec.resp_id
    AND    account_status <> -100;

  END LOOP;

end synch_security_users;

--
-- Procedure will remove entries in ZPB_BUSAREA_USERS table
-- when the administrator account has been expired.
--
procedure update_admin_entries (p_business_area_id in number)
   is
   begin

     delete from zpb_busarea_users
      where user_id = (
      select user_id
      from zpb_busarea_users
      where business_area_id = p_business_area_id
      intersect
      select /*+ LEADING (c) */ distinct(a.user_id)
        from fnd_user a,fnd_user_resp_groups b,fnd_responsibility c
        where a.user_id=b.user_id
        and b.responsibility_id=c.responsibility_id
        and c.responsibility_key = 'ZPB_MANAGER_RESP'
        and ((a.end_date < SYSDATE) or
                (b.end_date < SYSDATE)))
        and business_area_id = p_business_area_id;

end update_admin_entries;

end ZPB_USER_UPDATE;


/
