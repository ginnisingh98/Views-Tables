--------------------------------------------------------
--  DDL for Package Body JTF_RS_CONC_WF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_CONC_WF_PUB" AS
  /*$Header: jtfrsbwb.pls 120.4 2005/07/27 04:43:30 repuri noship $ */

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_CONC_WF_PUB';

  PROCEDURE  synchronize_wf_roles
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2,
   P_SYNC_COMP               IN  VARCHAR2
  )

  IS

    l_grp_orig_system   VARCHAR2(10)   := 'JRES_GRP';
    l_ind_orig_system   VARCHAR2(10)   := 'JRES_IND';
    l_team_orig_system  VARCHAR2(10)   := 'JRES_TEAM';
    l_hz_orig_system    VARCHAR2(10)   := 'HZ_PARTY';

    l_sysdate           DATE           := TRUNC (SYSDATE);
    m_sysdate           DATE           := TRUNC (SYSDATE-1);
    l_inactive          VARCHAR2(10)   := 'INACTIVE';
    l_active            VARCHAR2(10)   := 'ACTIVE';
    l_no_email          VARCHAR2(15)   := '*NOEMAIL1234*';
    l_false             BOOLEAN        := FALSE;

    error_name          VARCHAR2(30);
    error_message       VARCHAR2(2000);
    error_stack         VARCHAR2(32000);

    l_list              WF_PARAMETER_LIST_T;
    l_fnd_date   DATE   := to_date ('31-12-4712', 'DD-MM-RRRR');

  PROCEDURE call_exception IS
    error_name          VARCHAR2(30);
    error_message       VARCHAR2(2000);
    error_stack         VARCHAR2(32000);
  BEGIN
    wf_core.get_error(error_name, error_message, error_stack);
    fnd_file.put_line (fnd_file.log,error_message);
    fnd_file.new_line (fnd_file.log,1);
    fnd_file.put_line (fnd_file.log,error_stack);
    fnd_file.new_line (fnd_file.log,1);
    wf_core.clear;
  END call_exception;

  PROCEDURE synchronize_teams_wf AS

    -- Select all inactive records from resource teams table whose
    -- corresponding (Self and Member) records in the workflow local
    -- user roles table (wf_local_user_roles) are still active.
    -- These workflow local user role records have to be inactivated.

    CURSOR c_team_wf_ur_del IS
      SELECT team.team_id, team.start_date_active, team.end_date_active
      FROM   jtf_rs_teams_b team, wf_local_user_roles wlur
      WHERE  NVL(TRUNC(team.end_date_active),l_sysdate) < l_sysdate
      AND    wlur.role_orig_system_id = team.team_id
      AND    wlur.role_orig_system    = l_team_orig_system
      AND    wlur.role_name           = l_team_orig_system||':'||to_char(team.team_id)
      AND    NVL(TRUNC(wlur.expiration_date),l_sysdate) >= l_sysdate;

    -- Select all inactive records from resource teams table
    -- whose corresponding records in the workflow local roles
    -- table (wf_local_roles) are still active.
    -- These workflow local role records have to be inactivated.

    CURSOR c_team_wf_del IS
      SELECT team.team_id, team.team_name, team.email_address
            ,team.start_date_active, team.end_date_active
      FROM   jtf_rs_teams_vl team, wf_local_roles wlr
      WHERE  NVL(TRUNC(team.end_date_active),l_sysdate) < l_sysdate
      AND    wlr.orig_system_id = team.team_id
      AND    wlr.orig_system    = l_team_orig_system
      AND    wlr.name           = l_team_orig_system||':'||to_char(team.team_id)
      AND    (wlr.status  = l_active
              OR NVL(TRUNC(wlr.expiration_date),l_sysdate) >= l_sysdate);

    -- Select all active team records from resource teams table where one
    -- of the matching columns to the corresponding records in workflow
    -- local roles table (wf_local_roles) has been modified (not in sync).
    -- These workflow role records have to be updated with new values.

    CURSOR c_team_wf_upd IS
      SELECT team.team_id, team.team_name, team.email_address
            ,team.end_date_active, team.start_date_active
            ,wlr.start_date wlr_start_date, wlr.expiration_date wlr_exp_date
      FROM   jtf_rs_teams_vl team, wf_local_roles wlr
      WHERE  NVL(TRUNC(team.end_date_active),l_sysdate) >= l_sysdate
      AND    wlr.orig_system_id = team.team_id
      AND    wlr.orig_system    = l_team_orig_system
      AND    wlr.name           = l_team_orig_system||':'||to_char(team.team_id)
      AND    (wlr.display_name <> team.team_name      OR
              NVL(wlr.email_address, l_no_email)
              <> NVL(team.email_address, l_no_email)  OR
              wlr.start_date IS NULL OR wlr.start_date <> team.start_date_active OR
              (wlr.expiration_date IS NULL AND team.end_date_active IS NOT NULL)   OR
              (wlr.expiration_date IS NOT NULL AND team.end_date_active IS NULL)   OR
              wlr.expiration_date <> team.end_date_active);

    -- Select all active team records from resource teams table where one of
    -- the date columns of the corresponding records (Self or Member Records) in workflow
    -- local user roles table (wf_local_user_roles) has been modified (not in sync).
    -- These workflow user role records have to be updated with new values.

    CURSOR c_team_wf_ur_upd IS
      SELECT team.team_id, team.start_date_active, team.end_date_active
      FROM   jtf_rs_teams_b team, wf_local_user_roles wlur
      WHERE  NVL(TRUNC(team.end_date_active),l_sysdate) >= l_sysdate
      AND    wlur.role_orig_system_id =  team.team_id
      AND    wlur.role_orig_system    = l_team_orig_system
      AND    wlur.role_name           = l_team_orig_system||':'||to_char(team.team_id)
      AND    (wlur.start_date IS NULL OR wlur.start_date <> team.start_date_active OR
              (wlur.expiration_date IS NULL AND team.end_date_active IS NOT NULL)   OR
              (wlur.expiration_date IS NOT NULL AND team.end_date_active IS NULL)   OR
              wlur.expiration_date <> team.end_date_active);

    -- Select all the team records from the resource teams table
    -- that are still not defined in workflow roles table (wf_local_roles).
    -- A new record to be created in Workflow roles table, for each team record.

    CURSOR c_team_wf_crt IS
      SELECT team.team_id, team.team_name, team.email_address
            ,team.end_date_active, team.start_date_active
      FROM   jtf_rs_teams_vl team
      WHERE  NVL(TRUNC(team.end_date_active),l_sysdate) >= l_sysdate
      AND NOT EXISTS (SELECT 1 FROM wf_local_roles wlr
                        WHERE wlr.orig_system_id = team.team_id
                        AND   wlr.orig_system    = l_team_orig_system
                        AND   wlr.name           = l_team_orig_system||':'||to_char(team.team_id));

    log_msg_hdr4      fnd_new_messages.message_text%type := NULL;
    log_message12     fnd_new_messages.message_text%type := NULL;
    log_message13     fnd_new_messages.message_text%type := NULL;
    log_message14     fnd_new_messages.message_text%type := NULL;
    log_message36     fnd_new_messages.message_text%type := NULL;
    log_message37     fnd_new_messages.message_text%type := NULL;

  BEGIN

    log_msg_hdr4  := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_HDR4');
    log_message12 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG12');
    log_message13 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG13');
    log_message14 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG14');
    log_message36 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG36');
    log_message37 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG37');

    fnd_file.new_line (fnd_file.log,1);
    fnd_file.put_line (fnd_file.log,log_msg_hdr4);
  --fnd_file.put_line (fnd_file.log,'Beginning of Resource Workflow Synchronization for Resource Teams');
    fnd_file.put_line (fnd_file.log,'-----------------------------------------------------------------');
    fnd_file.new_line (fnd_file.log,1);

    wf_core.clear;

    -- Inactivate Workflow User Roles (Self and Member) for corresponding Inactive Resource Teams
    FOR i IN c_team_wf_ur_del LOOP
        BEGIN
          Wf_local_synch.propagate_user_role(
            p_user_orig_system      => l_team_orig_system,
            p_user_orig_system_id   => i.team_id,
            p_role_orig_system      => l_team_orig_system,
            p_role_orig_system_id   => i.team_id,
            p_raiseerrors           => TRUE,
            p_start_date            => i.start_date_active,
            p_expiration_date       => i.end_date_active,
            p_overwrite             => TRUE);

        EXCEPTION
          WHEN OTHERS THEN
            wf_core.get_error(error_name, error_message, error_stack);
            fnd_file.put_line (fnd_file.log,error_message);
            fnd_file.new_line (fnd_file.log,1);
            fnd_file.put_line (fnd_file.log,error_stack);
            fnd_file.new_line (fnd_file.log,1);
            wf_core.clear;
        END;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message36);
    --fnd_file.put_line (fnd_file.log,'Successfully inactivated self and member records in Workflow User Roles table,
    --for all the corresponding records in Resource Teams table that have been inactivated');
    fnd_file.new_line (fnd_file.log,1);

    -- Inactivate Workflow Roles for corresponding Inactive Resource Teams
    FOR i IN c_team_wf_del LOOP
      BEGIN
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('USER_NAME',l_team_orig_system||':'||to_char(i.team_id),l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('DISPLAYNAME',i.team_name,l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('MAIL',i.email_address,l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('ORCLISENABLED',l_inactive,l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('WFSYNCH_OVERWRITE','TRUE',l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('RAISEERRORS','TRUE',l_list);

        Wf_local_synch.propagate_role(
          p_orig_system           => l_team_orig_system,
          p_orig_system_id        => i.team_id,
          p_attributes            => l_list,
          p_start_date            => i.start_date_active,
          p_expiration_date       => i.end_date_active);

        l_list.DELETE;

      EXCEPTION
        WHEN OTHERS THEN
          l_list.DELETE;
          wf_core.get_error(error_name, error_message, error_stack);
          fnd_file.put_line (fnd_file.log,error_message);
          fnd_file.new_line (fnd_file.log,1);
          fnd_file.put_line (fnd_file.log,error_stack);
          fnd_file.new_line (fnd_file.log,1);
          wf_core.clear;
      END;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message12);
    --fnd_file.put_line (fnd_file.log,'Successfully inactivated records in Workflow Roles table,
    --for all the records in Resource Teams table that have been inactivated');
    fnd_file.new_line (fnd_file.log,1);

    -- Update Workflow Roles for corresponding Updated and Active Resource Teams
    FOR i IN c_team_wf_upd LOOP
      BEGIN
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('USER_NAME',l_team_orig_system||':'||to_char(i.team_id),l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('DISPLAYNAME',i.team_name,l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('MAIL',i.email_address,l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('WFSYNCH_OVERWRITE','TRUE',l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('RAISEERRORS','TRUE',l_list);

        -- Passing the parameter for 'Status' as 'ACTIVE' always, for Update.
        -- The status will be set to 'INACTIVE' if dates are inactive by WF APIs.
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('ORCLISENABLED',l_active,l_list);

        Wf_local_synch.propagate_role(
          p_orig_system           => l_team_orig_system,
          p_orig_system_id        => i.team_id,
          p_attributes            => l_list,
          p_start_date            => i.start_date_active,
          p_expiration_date       => i.end_date_active);

       l_list.DELETE;

      EXCEPTION
        WHEN OTHERS THEN
          l_list.DELETE;
          wf_core.get_error(error_name, error_message, error_stack);
          fnd_file.put_line (fnd_file.log,error_message);
          fnd_file.new_line (fnd_file.log,1);
          fnd_file.put_line (fnd_file.log,error_stack);
          fnd_file.new_line (fnd_file.log,1);
          wf_core.clear;
      END;

      IF (i.wlr_start_date IS NULL OR
          i.start_date_active <> i.wlr_start_date OR
          (i.end_date_active IS NULL AND i.wlr_exp_date IS NOT NULL) OR
          (i.end_date_active IS NOT NULL AND i.wlr_exp_date IS NULL) OR
           i.end_date_active <> i.wlr_exp_date) THEN

        BEGIN
          Wf_local_synch.propagate_user_role(
            p_user_orig_system      => l_team_orig_system,
            p_user_orig_system_id   => i.team_id,
            p_role_orig_system      => l_team_orig_system,
            p_role_orig_system_id   => i.team_id,
            p_raiseerrors           => TRUE,
            p_start_date            => i.start_date_active,
            p_expiration_date       => i.end_date_active,
            p_overwrite             => TRUE);

        EXCEPTION
          WHEN OTHERS THEN
            wf_core.get_error(error_name, error_message, error_stack);
            fnd_file.put_line (fnd_file.log,error_message);
            fnd_file.new_line (fnd_file.log,1);
            fnd_file.put_line (fnd_file.log,error_stack);
            fnd_file.new_line (fnd_file.log,1);
            wf_core.clear;
        END;
      END IF;

    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message13);
    --fnd_file.put_line (fnd_file.log,'Successfully updated records in Workflow Roles and User Roles tables,
    --whose corresponding records in Resource Teams table have been updated');
    fnd_file.new_line (fnd_file.log,1);

    -- Update Workflow User Roles (Self and Member Records) for corresponding Updated/Active Resource Teams
    FOR i IN c_team_wf_ur_upd LOOP
      BEGIN
        Wf_local_synch.propagate_user_role(
          p_user_orig_system      => l_team_orig_system,
          p_user_orig_system_id   => i.team_id,
          p_role_orig_system      => l_team_orig_system,
          p_role_orig_system_id   => i.team_id,
          p_raiseerrors           => TRUE,
          p_start_date            => i.start_date_active,
          p_expiration_date       => i.end_date_active,
          p_overwrite             => TRUE);

      EXCEPTION
        WHEN OTHERS THEN
          wf_core.get_error(error_name, error_message, error_stack);
          fnd_file.put_line (fnd_file.log,error_message);
          fnd_file.new_line (fnd_file.log,1);
          fnd_file.put_line (fnd_file.log,error_stack);
          fnd_file.new_line (fnd_file.log,1);
          wf_core.clear;
      END;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message37);
    --fnd_file.put_line (fnd_file.log,'Successfully updated dates for records in Workflow User Roles table,
    --whose corresponding records in Resource Teams table have different dates');
    fnd_file.new_line (fnd_file.log,1);

    -- Create Workflow Roles for Active Resource Teams, if they don't exist
    FOR i IN c_team_wf_crt LOOP
      BEGIN
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('USER_NAME',l_team_orig_system||':'||to_char(i.team_id),l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('DISPLAYNAME',i.team_name,l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('MAIL',i.email_address,l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('RAISEERRORS','TRUE',l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('ORCLISENABLED',l_active,l_list);

        Wf_local_synch.propagate_role(
          p_orig_system           => l_team_orig_system,
          p_orig_system_id        => i.team_id,
          p_attributes            => l_list,
          p_start_date            => i.start_date_active,
          p_expiration_date       => i.end_date_active);

       l_list.DELETE;

      EXCEPTION
        WHEN OTHERS THEN
          l_list.DELETE;
          wf_core.get_error(error_name, error_message, error_stack);
          fnd_file.put_line (fnd_file.log,error_message);
          fnd_file.new_line (fnd_file.log,1);
          fnd_file.put_line (fnd_file.log,error_stack);
          fnd_file.new_line (fnd_file.log,1);
          wf_core.clear;
      END;

      -- Create Self-Record in wf_local_user_roles for the above record
      BEGIN
        Wf_local_synch.propagate_user_role(
          p_user_orig_system      => l_team_orig_system,
          p_user_orig_system_id   => i.team_id,
          p_role_orig_system      => l_team_orig_system,
          p_role_orig_system_id   => i.team_id,
          p_raiseerrors           => TRUE,
          p_start_date            => i.start_date_active,
          p_expiration_date       => i.end_date_active);

      EXCEPTION
        WHEN OTHERS THEN
          wf_core.get_error(error_name, error_message, error_stack);
          fnd_file.put_line (fnd_file.log,error_message);
          fnd_file.new_line (fnd_file.log,1);
          fnd_file.put_line (fnd_file.log,error_stack);
          fnd_file.new_line (fnd_file.log,1);
          wf_core.clear;
      END;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message14);
    --fnd_file.put_line (fnd_file.log,'Successfully created records in Workflow Roles table, for all the records in
    --Resource Teams table that dont exist as roles. Corresponding self records also created in Workflow User Roles');
    fnd_file.new_line (fnd_file.log,1);

  EXCEPTION
    WHEN OTHERS THEN
      wf_core.get_error(error_name, error_message, error_stack);
      fnd_file.put_line (fnd_file.log,error_message);
      fnd_file.new_line (fnd_file.log,1);
      fnd_file.put_line (fnd_file.log,error_stack);
      fnd_file.new_line (fnd_file.log,1);
      wf_core.clear;

  END synchronize_teams_wf;


  PROCEDURE synchronize_groups_wf AS

    -- Select all inactive records from resource groups table
    -- whose corresponding (self and member) records in the workflow
    -- local user roles table (wf_local_user_roles) are still active.
    -- These workflow local user role records have to be inactivated.

    CURSOR c_grp_wf_ur_del IS
      SELECT grp.group_id, grp.start_date_active, grp.end_date_active
      FROM   jtf_rs_groups_b grp, wf_local_user_roles wlur
      WHERE  NVL(TRUNC(grp.end_date_active),l_sysdate) < l_sysdate
      AND    ((wlur.role_orig_system_id  =  grp.group_id
               AND wlur.role_orig_system = l_grp_orig_system
               AND wlur.role_name        = l_grp_orig_system||':'||to_char(grp.group_id))
              OR
              (wlur.user_orig_system_id  =  grp.group_id
               AND wlur.user_orig_system = l_grp_orig_system
               AND wlur.user_name        = l_grp_orig_system||':'||to_char(grp.group_id)))
      AND    NVL(TRUNC(wlur.expiration_date),l_sysdate) >= l_sysdate;

    -- Select all inactive records from resource groups table
    -- whose corresponding records in the workflow local roles
    -- table (wf_local_roles) are still active.
    -- These workflow local role records have to be inactivated.

    CURSOR c_grp_wf_del IS
      -- Hints provided based on Perf. Team's recommendations (Jaikumar Bathija).
      SELECT /*+ use_hash(grp.t) use_hash(grp.b) use_hash(wlr) parallel(grp) parallel(wlr) */
             grp.group_id, grp.group_name, grp.email_address
            ,grp.start_date_active, grp.end_date_active
      FROM   jtf_rs_groups_vl grp, wf_local_roles wlr
      WHERE  NVL(TRUNC(grp.end_date_active),l_sysdate) < l_sysdate
      AND    wlr.orig_system_id = grp.group_id
      AND    wlr.orig_system    = l_grp_orig_system
      AND    wlr.name           = l_grp_orig_system||':'||to_char(grp.group_id)
      AND    (wlr.status        = l_active
              OR NVL(TRUNC(wlr.expiration_date),l_sysdate) >= l_sysdate);

    -- Select all active group records from resource groups table
    -- where one of the matching columns to the corresponding records
    -- in workflow table (wf_local_users) have been modified (not in sync).
    -- These workflow records have to be updated with new values.

    CURSOR c_grp_wf_upd IS
      -- Hints provided based on Perf. Team's recommendations (Jaikumar Bathija).
      SELECT /*+ use_hash(grp.t) use_hash(grp.b) use_hash(wlr) parallel(grp) parallel(wlr) */
             grp.group_id, grp.group_name, grp.email_address
            ,grp.end_date_active, grp.start_date_active
            ,wlr.start_date wlr_start_date, wlr.expiration_date wlr_exp_date
      FROM   jtf_rs_groups_vl grp, wf_local_roles wlr
      WHERE  NVL(TRUNC(grp.end_date_active),l_sysdate) >= l_sysdate
      AND    wlr.orig_system_id = grp.group_id
      AND    wlr.orig_system    = l_grp_orig_system
      AND    wlr.name           = l_grp_orig_system||':'||to_char(grp.group_id)
      AND    (wlr.display_name <> grp.group_name      OR
              NVL(wlr.email_address, l_no_email)
              <> NVL(grp.email_address, l_no_email)   OR
              (wlr.start_date IS NULL OR wlr.start_date <> grp.start_date_active) OR
              (wlr.expiration_date is null AND grp.end_date_active is not null) OR
              (wlr.expiration_date is not null AND grp.end_date_active is null) OR
              wlr.expiration_date <> grp.end_date_active);

    -- Select all active group records from resource groups table where one of
    -- the date columns of the corresponding (self and member) records in workflow
    -- local user roles table (wf_local_user_roles) has been modified (not in sync).
    -- These workflow user role records have to be updated with new values.

    CURSOR c_grp_wf_ur_upd IS
      SELECT grp.group_id, grp.start_date_active, grp.end_date_active
      FROM   jtf_rs_groups_b grp, wf_local_user_roles wlur
      WHERE  NVL(TRUNC(grp.end_date_active),l_sysdate) >= l_sysdate
      AND    ((wlur.role_orig_system_id  = grp.group_id
               AND wlur.role_orig_system = l_grp_orig_system
               AND wlur.role_name        = l_grp_orig_system||':'||to_char(grp.group_id))
              OR
              (wlur.user_orig_system_id  = grp.group_id
               AND wlur.user_orig_system = l_grp_orig_system
               AND wlur.user_name        = l_grp_orig_system||':'||to_char(grp.group_id)))
      AND    (wlur.start_date IS NULL OR wlur.start_date <> grp.start_date_active OR
              (wlur.expiration_date IS NULL AND grp.end_date_active IS NOT NULL)   OR
              (wlur.expiration_date IS NOT NULL AND grp.end_date_active IS NULL)   OR
              wlur.expiration_date <> grp.end_date_active);

    -- Select all the group records from the resource groups table
    -- that are still not defined in workflow roles table (wf_local_roles).
    -- A new record to be created in Workflow roles table, for each group record.

    CURSOR c_grp_wf_crt IS
      -- Hints provided based on Perf. Team's recommendations (Jaikumar Bathija).
      SELECT /*+ use_hash(grp.t) use_hash(grp.b) parallel(grp) */
             grp.group_id, grp.group_name, grp.email_address
            ,grp.end_date_active, grp.start_date_active
      FROM   jtf_rs_groups_vl grp
      WHERE  NVL(TRUNC(grp.end_date_active),l_sysdate) >= l_sysdate
      AND NOT EXISTS (SELECT 1 FROM wf_local_roles wlr
                        WHERE wlr.orig_system    = l_grp_orig_system
                        AND   wlr.orig_system_id = grp.group_id
                        AND   wlr.name           = l_grp_orig_system||':'||to_char(group_id));

    log_msg_hdr1      fnd_new_messages.message_text%type := NULL;
    log_message1      fnd_new_messages.message_text%type := NULL;
    log_message2      fnd_new_messages.message_text%type := NULL;
    log_message3      fnd_new_messages.message_text%type := NULL;
    log_message38     fnd_new_messages.message_text%type := NULL;
    log_message39     fnd_new_messages.message_text%type := NULL;

  BEGIN

    log_msg_hdr1 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_HDR1');
    log_message1 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG1');
    log_message2 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG2');
    log_message3 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG3');
    log_message38:= fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG38');
    log_message39:= fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG39');

    fnd_file.new_line (fnd_file.log,1);
    fnd_file.put_line (fnd_file.log,log_msg_hdr1);
  --fnd_file.put_line (fnd_file.log,'Beginning of Resource Workflow Synchronization for Resource Groups');
    fnd_file.put_line (fnd_file.log,'------------------------------------------------------------------');
    fnd_file.new_line (fnd_file.log,1);

    wf_core.clear;

    -- Inactivate Workflow User Roles (Self-Records) for corresponding Inactive Resource Groups
    FOR i IN c_grp_wf_ur_del LOOP
        BEGIN
          Wf_local_synch.propagate_user_role(
            p_user_orig_system      => l_grp_orig_system,
            p_user_orig_system_id   => i.group_id,
            p_role_orig_system      => l_grp_orig_system,
            p_role_orig_system_id   => i.group_id,
            p_raiseerrors           => TRUE,
            p_start_date            => i.start_date_active,
            p_expiration_date       => i.end_date_active,
            p_overwrite             => TRUE);

        EXCEPTION
          WHEN OTHERS THEN
            wf_core.get_error(error_name, error_message, error_stack);
            fnd_file.put_line (fnd_file.log,error_message);
            fnd_file.new_line (fnd_file.log,1);
            fnd_file.put_line (fnd_file.log,error_stack);
            fnd_file.new_line (fnd_file.log,1);
            wf_core.clear;
        END;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message38);
    --fnd_file.put_line (fnd_file.log,'Successfully inactivated records in Workflow User Roles table, for both self and
    --group member records, whose corresponding records in Resource Groups table that have been inactivated');
    fnd_file.new_line (fnd_file.log,1);

    -- Inactivate Workflow Roles for corresponding Inactive Resource Groups
    FOR i IN c_grp_wf_del LOOP
        BEGIN
          JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('USER_NAME',l_grp_orig_system||':'||to_char(i.group_id),l_list);
          JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('DISPLAYNAME',i.group_name,l_list);
          JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('MAIL',i.email_address,l_list);
          JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('ORCLISENABLED',l_inactive,l_list);
          JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('WFSYNCH_OVERWRITE','TRUE',l_list);
          JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('RAISEERRORS','TRUE',l_list);

          Wf_local_synch.propagate_role(
            p_orig_system           => l_grp_orig_system,
            p_orig_system_id        => i.group_id,
            p_attributes            => l_list,
            p_start_date            => i.start_date_active,
            p_expiration_date       => i.end_date_active);

         l_list.DELETE;

        EXCEPTION
          WHEN OTHERS THEN
            l_list.DELETE;
            wf_core.get_error(error_name, error_message, error_stack);
            fnd_file.put_line (fnd_file.log,error_message);
            fnd_file.new_line (fnd_file.log,1);
            fnd_file.put_line (fnd_file.log,error_stack);
            fnd_file.new_line (fnd_file.log,1);
            wf_core.clear;
        END;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message1);
    --fnd_file.put_line (fnd_file.log,'Successfully inactivated records in Workflow Roles table,
    --for all the records in Resource Groups table that have been inactivated');
    fnd_file.new_line (fnd_file.log,1);

    -- Update Workflow Roles for corresponding Updated and Active Resource Groups
    FOR i IN c_grp_wf_upd LOOP
      BEGIN
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('USER_NAME',l_grp_orig_system||':'||to_char(i.group_id),l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('DISPLAYNAME',i.group_name,l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('MAIL',i.email_address,l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('WFSYNCH_OVERWRITE','TRUE',l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('RAISEERRORS','TRUE',l_list);

        -- Passing the parameter for 'Status' as 'ACITVE' always, for Update.
        -- The status will be set to 'INACTIVE' if dates are inactive by WF APIs.
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('ORCLISENABLED',l_active,l_list);

        Wf_local_synch.propagate_role(
          p_orig_system           => l_grp_orig_system,
          p_orig_system_id        => i.group_id,
          p_attributes            => l_list,
          p_start_date            => i.start_date_active,
          p_expiration_date       => i.end_date_active);

       l_list.DELETE;

      EXCEPTION
        WHEN OTHERS THEN
          l_list.DELETE;
          wf_core.get_error(error_name, error_message, error_stack);
          fnd_file.put_line (fnd_file.log,error_message);
          fnd_file.new_line (fnd_file.log,1);
          fnd_file.put_line (fnd_file.log,error_stack);
          fnd_file.new_line (fnd_file.log,1);
          wf_core.clear;
      END;

      IF (i.wlr_start_date IS NULL OR
          i.start_date_active <> i.wlr_start_date OR
          (i.end_date_active IS NULL AND i.wlr_exp_date IS NOT NULL) OR
          (i.end_date_active IS NOT NULL AND i.wlr_exp_date IS NULL) OR
           i.end_date_active <> i.wlr_exp_date) THEN

        BEGIN
          Wf_local_synch.propagate_user_role(
            p_user_orig_system      => l_grp_orig_system,
            p_user_orig_system_id   => i.group_id,
            p_role_orig_system      => l_grp_orig_system,
            p_role_orig_system_id   => i.group_id,
            p_raiseerrors           => TRUE,
            p_start_date            => i.start_date_active,
            p_expiration_date       => i.end_date_active,
            p_overwrite             => TRUE);

        EXCEPTION
          WHEN OTHERS THEN
            wf_core.get_error(error_name, error_message, error_stack);
            fnd_file.put_line (fnd_file.log,error_message);
            fnd_file.new_line (fnd_file.log,1);
            fnd_file.put_line (fnd_file.log,error_stack);
            fnd_file.new_line (fnd_file.log,1);
            wf_core.clear;
        END;
      END IF;

    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message2);
    --fnd_file.put_line (fnd_file.log,'Successfully updated records in Workflow Roles and User Roles table,
    --whose corresponding records in Resource Groups table have been updated');
    fnd_file.new_line (fnd_file.log,1);

    -- Update Workflow User Roles (Self and Member Records) for correspoding Updated/Active Resource Groups
    FOR i IN c_grp_wf_ur_upd LOOP
      BEGIN
         Wf_local_synch.propagate_user_role(
           p_user_orig_system      => l_grp_orig_system,
           p_user_orig_system_id   => i.group_id,
           p_role_orig_system      => l_grp_orig_system,
           p_role_orig_system_id   => i.group_id,
           p_raiseerrors           => TRUE,
           p_start_date            => i.start_date_active,
           p_expiration_date       => i.end_date_active,
           p_overwrite             => TRUE);

      EXCEPTION
        WHEN OTHERS THEN
          wf_core.get_error(error_name, error_message, error_stack);
          fnd_file.put_line (fnd_file.log,error_message);
          fnd_file.new_line (fnd_file.log,1);
          fnd_file.put_line (fnd_file.log,error_stack);
          fnd_file.new_line (fnd_file.log,1);
          wf_core.clear;
      END;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message39);
    --fnd_file.put_line (fnd_file.log,'Successfully updated dates for all self and member records in Workflow
    --User Roles table, whose corresponding records in Resource Groups table have been updated');
    fnd_file.new_line (fnd_file.log,1);

    -- Create Workflow Roles for Active Resource Groups, if they don't exist
    FOR i IN c_grp_wf_crt LOOP
      BEGIN
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('USER_NAME',l_grp_orig_system||':'||to_char(i.group_id),l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('DISPLAYNAME',i.group_name,l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('MAIL',i.email_address,l_list);
        JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('RAISEERRORS','TRUE',l_list);

        Wf_local_synch.propagate_role(
          p_orig_system           => l_grp_orig_system,
          p_orig_system_id        => i.group_id,
          p_attributes            => l_list,
          p_start_date            => i.start_date_active,
          p_expiration_date       => i.end_date_active);

       l_list.DELETE;

      EXCEPTION
        WHEN OTHERS THEN
          l_list.DELETE;
          wf_core.get_error(error_name, error_message, error_stack);
          fnd_file.put_line (fnd_file.log,error_message);
          fnd_file.new_line (fnd_file.log,1);
          fnd_file.put_line (fnd_file.log,error_stack);
          fnd_file.new_line (fnd_file.log,1);
          wf_core.clear;
      END;

      -- Create Self-Record in wf_local_user_roles for the above record
      BEGIN
        Wf_local_synch.propagate_user_role(
          p_user_orig_system      => l_grp_orig_system,
          p_user_orig_system_id   => i.group_id,
          p_role_orig_system      => l_grp_orig_system,
          p_role_orig_system_id   => i.group_id,
          p_raiseerrors           => TRUE,
          p_start_date            => i.start_date_active,
          p_expiration_date       => i.end_date_active);
      EXCEPTION
        WHEN OTHERS THEN
          wf_core.get_error(error_name, error_message, error_stack);
          fnd_file.put_line (fnd_file.log,error_message);
          fnd_file.new_line (fnd_file.log,1);
          fnd_file.put_line (fnd_file.log,error_stack);
          fnd_file.new_line (fnd_file.log,1);
          wf_core.clear;
      END;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message3);
    --fnd_file.put_line (fnd_file.log,'Successfully created records in Workflow Roles table, for all the records in
    --Resource Groups table that dont exist as roles. Corresponding records also created in Workflow User Roles');
    fnd_file.new_line (fnd_file.log,1);

  EXCEPTION
    WHEN OTHERS THEN
      wf_core.get_error(error_name, error_message, error_stack);
      fnd_file.put_line (fnd_file.log,error_message);
      fnd_file.new_line (fnd_file.log,1);
      fnd_file.put_line (fnd_file.log,error_stack);
      fnd_file.new_line (fnd_file.log,1);
      wf_core.clear;

  END synchronize_groups_wf;


  PROCEDURE synchronize_resources_wf AS

    CURSOR c_res_details IS
      SELECT resource_id, category, start_date_active, end_date_active
            ,source_id, source_email, resource_name
      FROM jtf_rs_resource_extns_vl;

    CURSOR c_wf_ur_details (l_user_orig_system_id NUMBER, l_user_orig_system VARCHAR2, l_user_name VARCHAR2) IS
      SELECT role_orig_system_id, role_orig_system, role_name
            ,start_date, expiration_date
      FROM   wf_local_user_roles
      WHERE  user_orig_system_id = l_user_orig_system_id
      AND    user_orig_system    = l_user_orig_system
      AND    user_name           = l_user_name
      AND    NVL (expiration_date, l_sysdate) >= l_sysdate;

    CURSOR c_wf_ur_mem_details (l_user_orig_system_id NUMBER, l_user_orig_system VARCHAR2, l_user_name VARCHAR2) IS
      SELECT role_orig_system_id, role_orig_system, role_name
            ,start_date, expiration_date
      FROM   wf_local_user_roles
      WHERE  user_orig_system_id = l_user_orig_system_id
      AND    user_orig_system    = l_user_orig_system
      AND    user_name           = l_user_name
      AND    role_orig_system IN ('JRES_IND','JRES_GRP','JRES_TEAM')
      AND    NVL (expiration_date, l_sysdate) >= l_sysdate;

    CURSOR c_wf_role_details (l_orig_system_id NUMBER, l_orig_system VARCHAR2, l_name VARCHAR2) IS
      SELECT display_name, email_address, start_date, expiration_date
      FROM  wf_local_roles
      WHERE orig_system_id = l_orig_system_id
      AND   orig_system    = l_orig_system
      AND   name           = l_name
      AND   NVL (expiration_date, l_sysdate) >= l_sysdate;

    l_user_name            wf_local_roles.name%TYPE;
    l_ind_user_name        wf_local_roles.name%TYPE;
    l_user_orig_system     wf_local_roles.orig_system%TYPE;
    l_user_orig_system_id  wf_local_roles.orig_system_id%TYPE;

    l_start_date           DATE;
    l_end_date             DATE;

    l_display_name         wf_local_roles.display_name%TYPE;
    l_email_address        wf_local_roles.email_address%TYPE;
    l_expiration_date      wf_local_roles.expiration_date%TYPE;

    log_msg_hdr2      fnd_new_messages.message_text%type := NULL;
    log_message40     fnd_new_messages.message_text%type := NULL;

  BEGIN

    log_msg_hdr2  := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_HDR2');
    log_message40 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG40');

    fnd_file.put_line (fnd_file.log,log_msg_hdr2);
  --fnd_file.put_line (fnd_file.log,'Beginning of Resource Workflow Synchronization for Resources');
    fnd_file.put_line (fnd_file.log,'------------------------------------------------------------');
    fnd_file.new_line (fnd_file.log,1);

    FOR i IN c_res_details LOOP
      l_ind_user_name := l_ind_orig_system ||':'|| TO_CHAR (i.resource_id);
      IF (i.category IN ('EMPLOYEE','PARTY','PARTNER','SUPPLIER_CONTACT')) THEN
        FOR j IN c_wf_ur_details (i.resource_id, l_ind_orig_system, l_ind_user_name) LOOP
          -- Inactivate the wf user roles
          BEGIN
            Wf_local_synch.propagate_user_role(
              p_user_orig_system      => l_ind_orig_system,
              p_user_orig_system_id   => i.resource_id,
              p_role_orig_system      => l_ind_orig_system,
              p_role_orig_system_id   => i.resource_id,
              p_raiseerrors           => TRUE,
              p_start_date            => l_sysdate-2,
              p_expiration_date       => l_sysdate-1,
              p_overwrite             => TRUE);
          EXCEPTION
            WHEN OTHERS THEN
              wf_core.get_error(error_name, error_message, error_stack);
              fnd_file.put_line (fnd_file.log,error_message);
              fnd_file.new_line (fnd_file.log,1);
              fnd_file.put_line (fnd_file.log,error_stack);
              fnd_file.new_line (fnd_file.log,1);
              wf_core.clear;
          END;
        END LOOP;
        -- Get all wf roles still defined as JRES_IND and Active.
        FOR n in c_wf_role_details (i.resource_id, l_ind_orig_system, l_ind_user_name) LOOP
          IF i.resource_name IS NOT NULL THEN
            -- Inactivate wf roles with expiration date as sysdate-2
            BEGIN
              JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('USER_NAME',l_ind_orig_system||':'||to_char(i.resource_id),l_list);
              --JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('DISPLAYNAME',i.resource_name,l_list);
              --JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('MAIL',i.source_email,l_list);
              JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('ORCLISENABLED',l_inactive,l_list);
              JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('WFSYNCH_OVERWRITE','TRUE',l_list);
              JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('RAISEERRORS','TRUE',l_list);

              Wf_local_synch.propagate_role(
                p_orig_system           => l_ind_orig_system,
                p_orig_system_id        => i.resource_id,
                p_attributes            => l_list,
                p_start_date            => l_sysdate-2,
                p_expiration_date       => l_sysdate-1);
              l_list.DELETE;
            EXCEPTION
              WHEN OTHERS THEN
                l_list.DELETE;
                wf_core.get_error(error_name, error_message, error_stack);
                fnd_file.put_line (fnd_file.log,error_message);
                fnd_file.new_line (fnd_file.log,1);
                fnd_file.put_line (fnd_file.log,error_stack);
                fnd_file.new_line (fnd_file.log,1);
                wf_core.clear;
            END;
          END IF;
        END LOOP;
      -- Check if the Resources of category OTHER and TBH are inactive
      ELSIF (i.category IN ('OTHER','TBH') AND NVL (i.end_date_active, l_sysdate) < l_sysdate) THEN
        -- Inactivate corresponding wf user roles with resource dates
        FOR  k IN c_wf_ur_details (i.resource_id, l_ind_orig_system, l_ind_user_name) LOOP
          BEGIN
            Wf_local_synch.propagate_user_role(
              p_user_orig_system      => l_ind_orig_system,
              p_user_orig_system_id   => i.resource_id,
              p_role_orig_system      => l_ind_orig_system,
              p_role_orig_system_id   => i.resource_id,
              p_raiseerrors           => TRUE,
              p_start_date            => i.start_date_active,
              p_expiration_date       => i.end_date_active,
              p_overwrite             => TRUE);

          EXCEPTION
            WHEN OTHERS THEN
              wf_core.get_error(error_name, error_message, error_stack);
              fnd_file.put_line (fnd_file.log,error_message);
              fnd_file.new_line (fnd_file.log,1);
              fnd_file.put_line (fnd_file.log,error_stack);
              fnd_file.new_line (fnd_file.log,1);
              wf_core.clear;
          END;
        END LOOP;
        -- Inactivate corresponding wf roles with resource dates
        FOR p in c_wf_role_details (i.resource_id, l_ind_orig_system , l_ind_user_name) LOOP
          IF i.resource_name IS NOT NULL THEN
            BEGIN
              JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('USER_NAME',l_ind_orig_system||':'||to_char(i.resource_id),l_list);
              --JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('DISPLAYNAME',i.resource_name,l_list);
              --JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('MAIL',i.source_email,l_list);
              JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('ORCLISENABLED',l_inactive,l_list);
              JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('WFSYNCH_OVERWRITE','TRUE',l_list);
              JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('RAISEERRORS','TRUE',l_list);

              Wf_local_synch.propagate_role(
                p_orig_system           => l_ind_orig_system,
                p_orig_system_id        => i.resource_id,
                p_attributes            => l_list,
                p_start_date            => i.start_date_active,
                p_expiration_date       => i.end_date_active);
              l_list.DELETE;
            EXCEPTION
              WHEN OTHERS THEN
                l_list.DELETE;
                wf_core.get_error(error_name, error_message, error_stack);
                fnd_file.put_line (fnd_file.log,error_message);
                fnd_file.new_line (fnd_file.log,1);
                fnd_file.put_line (fnd_file.log,error_stack);
                fnd_file.new_line (fnd_file.log,1);
                wf_core.clear;
            END;
          END IF;
        END LOOP;
      END IF;
      --Check for active resource
      IF (NVL (i.end_date_active, l_sysdate) >= l_sysdate) THEN
        --Get wf role information for the resouce
        jtf_rs_wf_integration_pub.get_wf_role (
           p_resource_id    => i.resource_id
          ,x_role_name      => l_user_name
          ,x_orig_system    => l_user_orig_system
          ,x_orig_system_id => l_user_orig_system_id
        );
        -- Get corresponding active wf user roles
        FOR c in c_wf_ur_mem_details (l_user_orig_system_id, l_user_orig_system, l_user_name) LOOP
          --Check if any dates have been modified for any active resource of any category
          IF (c.start_date IS NULL OR c.start_date <> i.start_date_active) OR
             (c.expiration_date IS NULL AND i.end_date_active IS NOT NULL) OR
             (c.expiration_date IS NOT NULL AND i.end_date_active IS NULL) OR
             (c.expiration_date <> i.end_date_active) THEN
            --Check for Self or Member record
            IF (l_user_orig_system = c.role_orig_system AND l_user_orig_system_id = c.role_orig_system_id
                AND l_user_name = c.role_name) THEN
              --Its a self record. Update with Resource Dates
              l_start_date := i.start_date_active;
              l_end_date   := i.end_date_active;
            ELSE -- Its a member record. Update with the correct greatest and least dates.
              l_start_date := greatest (i.start_date_active, NVL (c.start_date, i.start_date_active));
              l_end_date   := least (NVL (i.end_date_active, l_fnd_date), NVL (c.expiration_date, l_fnd_date));
              --Update user roles with correct dates.
              IF l_end_date = l_fnd_date THEN
                l_end_date := NULL;
              END IF;
              BEGIN
                Wf_local_synch.propagate_user_role(
                  p_user_orig_system      => l_user_orig_system,
                  p_user_orig_system_id   => l_user_orig_system_id,
                  p_role_orig_system      => c.role_orig_system,
                  p_role_orig_system_id   => c.role_orig_system_id,
                  p_raiseerrors           => TRUE,
                  p_start_date            => l_start_date,
                  p_expiration_date       => l_end_date,
                  p_overwrite             => TRUE);
              EXCEPTION
                WHEN OTHERS THEN
                  wf_core.get_error(error_name, error_message, error_stack);
                  fnd_file.put_line (fnd_file.log,error_message);
                  fnd_file.new_line (fnd_file.log,1);
                  fnd_file.put_line (fnd_file.log,error_stack);
                  fnd_file.new_line (fnd_file.log,1);
                  wf_core.clear;
              END;
            END IF;
          END IF;
        END LOOP;
      END IF;
      -- Active Resources of category OTHER and TBH
      IF (i.category IN ('OTHER','TBH') AND NVL (i.end_date_active, l_sysdate) >= l_sysdate) THEN
        --Get corresponding wf roles
        OPEN c_wf_role_details (i.resource_id, l_ind_orig_system, l_ind_user_name);
        FETCH c_wf_role_details INTO l_display_name, l_email_address, l_start_date, l_expiration_date;
        IF c_wf_role_details%FOUND THEN
          --Check for Updates
          IF (l_display_name <> NVL (i.resource_name, l_display_name)
             OR NVL (l_email_address, l_no_email) <> NVL (i.source_email, l_no_email)
             OR (l_start_date IS NULL OR l_start_date <> i.start_date_active)
             OR (l_expiration_date IS NULL AND i.end_date_active IS NOT NULL)
             OR (l_expiration_date IS NOT NULL AND i.end_date_active IS NULL)
             OR l_expiration_date <> i.end_date_active) THEN
            --Update wf roles for corresponding changes in resource details for OTHER and TBH.
            IF i.resource_name IS NOT NULL THEN
              BEGIN
                JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('USER_NAME',l_ind_orig_system||':'||to_char(i.resource_id),l_list);
                JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('DISPLAYNAME',i.resource_name,l_list);
                JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('MAIL',i.source_email,l_list);
                JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('WFSYNCH_OVERWRITE','TRUE',l_list);
                JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('RAISEERRORS','TRUE',l_list);
                -- Passing the parameter for 'Status' as 'ACTIVE' always, for Update.
                -- The status will be set to 'INACTIVE' if dates are inactive by WF APIs.
                JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('ORCLISENABLED',l_active,l_list);

                Wf_local_synch.propagate_role(
                  p_orig_system           => l_ind_orig_system,
                  p_orig_system_id        => i.resource_id,
                  p_attributes            => l_list,
                  p_start_date            => i.start_date_active,
                  p_expiration_date       => i.end_date_active);
                l_list.DELETE;
              EXCEPTION
                WHEN OTHERS THEN
                  IF c_wf_role_details%ISOPEN THEN
                    CLOSE c_wf_role_details;
                  END IF;
                  l_list.DELETE;
                  wf_core.get_error(error_name, error_message, error_stack);
                  fnd_file.put_line (fnd_file.log,error_message);
                  fnd_file.new_line (fnd_file.log,1);
                  fnd_file.put_line (fnd_file.log,error_stack);
                  fnd_file.new_line (fnd_file.log,1);
                  wf_core.clear;
              END;
            END IF;
          END IF;
        ELSE
          --Create new wf roles
          IF i.resource_name IS NOT NULL THEN
            BEGIN
              JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('USER_NAME',l_ind_orig_system||':'||to_char(i.resource_id),l_list);
              JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('DISPLAYNAME',i.resource_name,l_list);
              JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('MAIL',i.source_email,l_list);
              JTF_RS_WF_INTEGRATION_PUB.AddParameterToList('RAISEERRORS','TRUE',l_list);

              Wf_local_synch.propagate_role(
                p_orig_system           => l_ind_orig_system,
                p_orig_system_id        => i.resource_id,
                p_attributes            => l_list,
                p_start_date            => i.start_date_active,
                p_expiration_date       => i.end_date_active);
              l_list.DELETE;
            EXCEPTION
              WHEN OTHERS THEN
                l_list.DELETE;
                wf_core.get_error(error_name, error_message, error_stack);
                fnd_file.put_line (fnd_file.log,error_message);
                fnd_file.new_line (fnd_file.log,1);
                fnd_file.put_line (fnd_file.log,error_stack);
                fnd_file.new_line (fnd_file.log,1);
                wf_core.clear;
            END;
            -- Create Self-Record in wf_local_user_roles for the above record
            BEGIN
              Wf_local_synch.propagate_user_role(
                p_user_orig_system      => l_ind_orig_system,
                p_user_orig_system_id   => i.resource_id,
                p_role_orig_system      => l_ind_orig_system,
                p_role_orig_system_id   => i.resource_id,
                p_raiseerrors           => TRUE,
                p_start_date            => i.start_date_active,
                p_expiration_date       => i.end_date_active);
            EXCEPTION
              WHEN OTHERS THEN
                wf_core.get_error(error_name, error_message, error_stack);
                fnd_file.put_line (fnd_file.log,error_message);
                fnd_file.new_line (fnd_file.log,1);
                fnd_file.put_line (fnd_file.log,error_stack);
                fnd_file.new_line (fnd_file.log,1);
                wf_core.clear;
            END;
          END IF;
        END IF;
        CLOSE c_wf_role_details;
      END IF;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message40);
    --fnd_file.put_line (fnd_file.log,'Successfully synchronized Workflow Roles and User Role tables, for all its
    --corresponding records in Resources Table. This includes inactivation, updating and creation');
    fnd_file.new_line (fnd_file.log,1);

  END synchronize_resources_wf;


  PROCEDURE synchronize_group_members_wf AS

    -- Cursor to get all active wf user role records whose corresponding
    -- resource group member records have been deleted (delete_flag Y).

    CURSOR c_wlur_grp_mem_del IS
      SELECT wlur.user_orig_system, wlur.user_orig_system_id, mem.group_id
      FROM   wf_local_user_roles wlur, jtf_rs_group_members mem
      WHERE  NVL (mem.delete_flag,'N') = 'Y'
      AND    wlur.role_orig_system     =  l_grp_orig_system
      AND    wlur.role_orig_system_id  =  mem.group_id
      AND    wlur.role_name            =  l_grp_orig_system ||':'|| mem.group_id
      AND    wlur.user_orig_system     <> l_grp_orig_system
      AND    NVL(wlur.expiration_date, l_sysdate) >= l_sysdate;

    -- Cursor to select all active records from resource group members table
    -- (jtf_rs_group_members) that are still not defined in workflow
    -- user role table (wf_local_user_roles). This is for category OTHER and TBH.
    -- These records have to be created in workflow user roles table.

    CURSOR c_grp_mem_wf_crt IS
      -- Hints provided based on Perf. Team's recommendations (Jaikumar Bathija).
      SELECT /*+ use_hash(ext) use_hash(mem) use_hash(grp) parallel(ext)
                 parallel(mem) parallel(grp) */
             mem.resource_id, mem.group_id
            ,greatest (ext.start_date_active, grp.start_date_active) m_start_date_active
            ,least (NVL (grp.end_date_active, l_fnd_date) ,
                    NVL (ext.end_date_active, l_fnd_date)) m_end_date_active
      FROM   jtf_rs_resource_extns_vl ext, jtf_rs_group_members mem, jtf_rs_groups_b grp
      WHERE  mem.resource_id = ext.resource_id
      AND    mem.group_id    = grp.group_id
      AND    ext.category IN ('OTHER','TBH')
      AND    ext.resource_name IS NOT NULL
      AND    NVL (mem.delete_flag,'N') <> 'Y'
      AND    NVL(TRUNC(ext.end_date_active),l_sysdate) >= l_sysdate
      AND    NVL(TRUNC(grp.end_date_active),l_sysdate) >= l_sysdate
      AND NOT EXISTS (SELECT 1 FROM wf_local_user_roles wlur
                      WHERE wlur.user_orig_system_id = mem.resource_id
                      AND   wlur.role_orig_system_id = mem.group_id
                      AND   wlur.user_orig_system    = l_ind_orig_system
                      AND   wlur.role_orig_system    = l_grp_orig_system);

    -- Select all active records from resource group members table
    -- (jtf_rs_group_members) that are still not defined in workflow
    -- user role table (wf_local_user_roles). This is for category
    -- EMPLOYEE, PARTY, PARTNER and SUPPLIER_CONTACT
    -- These records have to be created in workflow user roles table.

    CURSOR c_grp_mem_wf_epps_crt IS
      -- Hints provided based on Perf. Team's recommendations (Jaikumar Bathija).
      SELECT /*+ use_hash(ext) use_hash(mem) use_hash(grp) parallel(ext)
                 parallel(mem) parallel(grp) */
             mem.resource_id, mem.group_id, ext.category, ext.resource_name
            ,greatest (ext.start_date_active, grp.start_date_active) m_start_date_active
            ,least (NVL (grp.end_date_active, l_fnd_date) ,
                    NVL (ext.end_date_active, l_fnd_date)) m_end_date_active
      FROM   jtf_rs_resource_extns_vl ext, jtf_rs_group_members mem, jtf_rs_groups_b grp
      WHERE  mem.resource_id = ext.resource_id
      AND    mem.group_id    = grp.group_id
      AND    ext.category IN ('EMPLOYEE','PARTY','PARTNER','SUPPLIER_CONTACT')
      AND    NVL (mem.delete_flag,'N') <> 'Y'
      AND    ext.resource_name IS NOT NULL
      AND    NVL(TRUNC(ext.end_date_active),l_sysdate) >= l_sysdate
      AND    NVL(TRUNC(grp.end_date_active),l_sysdate) >= l_sysdate
      AND NOT EXISTS (SELECT 1 FROM wf_local_user_roles wlur
                      WHERE wlur.role_orig_system_id = mem.group_id
                      AND   wlur.user_orig_system    = l_hz_orig_system
                      AND   wlur.role_orig_system    = l_grp_orig_system);


    log_msg_hdr3      fnd_new_messages.message_text%type := NULL;
    log_message8      fnd_new_messages.message_text%type := NULL;
    log_message9      fnd_new_messages.message_text%type := NULL;
    log_message10     fnd_new_messages.message_text%type := NULL;
    log_message11     fnd_new_messages.message_text%type := NULL;

    log_message19     fnd_new_messages.message_text%type := NULL;
    log_message20     fnd_new_messages.message_text%type := NULL;
    log_message21     fnd_new_messages.message_text%type := NULL;

    log_message30     fnd_new_messages.message_text%type := NULL;
    log_message31     fnd_new_messages.message_text%type := NULL;

    l_end_date_active      DATE;
    m_end_date_active      DATE;
    m_start_date_active    DATE;
    m_role_name            wf_local_roles.name%TYPE;
    l_user_name            wf_local_roles.name%TYPE;
    m_user_orig_system     wf_local_roles.orig_system%TYPE;
    l_user_orig_system     wf_local_roles.orig_system%TYPE;
    m_user_orig_system_id  wf_local_roles.orig_system_id%TYPE;
    l_user_orig_system_id  wf_local_roles.orig_system_id%TYPE;

  BEGIN

    log_msg_hdr3  := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_HDR3');
    log_message8  := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG8');
    log_message9  := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG9');
    log_message10 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG10');
    log_message11 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG11');

    log_message19 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG19');
    log_message20 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG20');
    log_message21 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG21');

    log_message30 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG30');
    log_message31 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG31');

    fnd_file.put_line (fnd_file.log,log_msg_hdr3);
  --fnd_file.put_line (fnd_file.log,'Beginning of Resource Workflow Synchronization for Group Members');
    fnd_file.put_line (fnd_file.log,'----------------------------------------------------------------');
    fnd_file.new_line (fnd_file.log,1);

    --Inactivate all wf user roles which are still active and whose corresponding records
    -- in resource group members table have been deleted (delete_flag Y).
    FOR i IN c_wlur_grp_mem_del LOOP
      BEGIN
        Wf_local_synch.propagate_user_role (
          p_user_orig_system      => i.user_orig_system,
          p_user_orig_system_id   => i.user_orig_system_id,
          p_role_orig_system      => l_grp_orig_system,
          p_role_orig_system_id   => i.group_id,
          p_raiseerrors           => TRUE,
          p_start_date            => sysdate-2,
          p_expiration_date       => sysdate-1,
          p_overwrite             => TRUE);
      EXCEPTION
        WHEN OTHERS THEN
          wf_core.get_error(error_name, error_message, error_stack);
          fnd_file.put_line (fnd_file.log,error_message);
          fnd_file.new_line (fnd_file.log,1);
          fnd_file.put_line (fnd_file.log,error_stack);
          fnd_file.new_line (fnd_file.log,1);
          wf_core.clear;
      END;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message8);
    --fnd_file.put_line (fnd_file.log,'Successfully inactivated all records in Workflow User Roles table,
    --whose corresponding records in Resource Group Members table have been deleted.
    fnd_file.new_line (fnd_file.log,1);


    -- Create Workflow User Role for Active Resource Group Members
    -- whose Resource Category is OTHER or TBH
    FOR i IN c_grp_mem_wf_crt LOOP
      BEGIN
        IF i.m_end_date_active = l_fnd_date THEN
          l_end_date_active := NULL;
        ELSE
          l_end_date_active := i.m_end_date_active;
        END IF;
        Wf_local_synch.propagate_user_role (
          p_user_orig_system      => l_ind_orig_system,
          p_user_orig_system_id   => i.resource_id,
          p_role_orig_system      => l_grp_orig_system,
          p_role_orig_system_id   => i.group_id,
          p_raiseerrors           => TRUE,
          p_start_date            => i.m_start_date_active,
          p_expiration_date       => l_end_date_active);
      EXCEPTION
        WHEN OTHERS THEN
          wf_core.get_error(error_name, error_message, error_stack);
          fnd_file.put_line (fnd_file.log,error_message);
          fnd_file.new_line (fnd_file.log,1);
          fnd_file.put_line (fnd_file.log,error_stack);
          fnd_file.new_line (fnd_file.log,1);
          wf_core.clear;
      END;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message30);
    --fnd_file.put_line (fnd_file.log,'Successfully created Workflow User Role Records, for its corresponding records in
    --Groups Members Table. This is for Resources whose category is Other or To be hired.');
    fnd_file.new_line (fnd_file.log,1);


    -- Create Workflow User Role for Active Resource Group Members
    -- whose Resource Cateogry is EMPLOYEE, PARTY, PARTNER or SUPPLIER_CONTACT
    FOR i IN c_grp_mem_wf_epps_crt LOOP
      IF i.m_end_date_active = l_fnd_date THEN
        l_end_date_active := NULL;
      ELSE
        l_end_date_active := i.m_end_date_active;
      END IF;
      JTF_RS_WF_INTEGRATION_PUB.get_wf_role (
          p_resource_id    => i.resource_id
         ,x_role_name      => l_user_name
         ,x_orig_system    => l_user_orig_system
         ,x_orig_system_id => l_user_orig_system_id
      );
      IF (l_user_orig_system IS NULL OR l_user_orig_system_id IS NULL) THEN
        fnd_file.put_line (fnd_file.log,'Not creating Workflow User Roles for corresponding Resource Group Members whose Member
                           Resource is Resource ID - '||i.resource_id||', Resource Name - '||i.resource_name||' and Resource
                           Category - '||i.category||', because there was no corresponding User defined in wf_local_roles table');
      ELSE
        BEGIN
          Wf_local_synch.propagate_user_role (
            p_user_orig_system      => l_user_orig_system,
            p_user_orig_system_id   => l_user_orig_system_id,
            p_role_orig_system      => l_grp_orig_system,
            p_role_orig_system_id   => i.group_id,
            p_raiseerrors           => TRUE,
            p_start_date            => i.m_start_date_active,
            p_expiration_date       => l_end_date_active);
        EXCEPTION
          WHEN OTHERS THEN
            wf_core.get_error(error_name, error_message, error_stack);
            fnd_file.put_line (fnd_file.log,error_message);
            fnd_file.new_line (fnd_file.log,1);
            fnd_file.put_line (fnd_file.log,error_stack);
            fnd_file.new_line (fnd_file.log,1);
            wf_core.clear;
        END;
      END IF;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message31);
    --fnd_file.put_line (fnd_file.log,'Successfully created Workflow User Role Records, for its corresponding records in
    --Resource Group Members tables. This is for Resources who category is Employee, Party, Partner or Supplier Contact.');
     fnd_file.new_line (fnd_file.log,1);


  EXCEPTION
    WHEN OTHERS THEN
      wf_core.get_error(error_name, error_message, error_stack);
      fnd_file.put_line (fnd_file.log,error_message);
      fnd_file.new_line (fnd_file.log,1);
      fnd_file.put_line (fnd_file.log,error_stack);
      fnd_file.new_line (fnd_file.log,1);
      wf_core.clear;

  END synchronize_group_members_wf;


  PROCEDURE synchronize_team_members_wf AS

    -- Cursor to get all active wf user role records whose corresponding
    -- resource team member records have been deleted (delete_flag Y).

    CURSOR c_wlur_team_mem_del IS
      SELECT wlur.user_orig_system, wlur.user_orig_system_id, mem.team_id
      FROM   wf_local_user_roles wlur, jtf_rs_team_members mem
      WHERE  NVL (mem.delete_flag,'N') = 'Y'
      AND    wlur.role_orig_system     =  l_team_orig_system
      AND    wlur.role_orig_system_id  =  mem.team_id
      AND    wlur.role_name            =  l_team_orig_system ||':'|| mem.team_id
      AND    wlur.user_orig_system     <> l_team_orig_system
      AND    NVL(wlur.expiration_date, l_sysdate) >= l_sysdate;


    -- Select all active records from resource team members table
    -- (jtf_rs_team_members) that are still not defined in workflow
    -- user role table (wf_local_user_roles). This is for 'INDIVIDUAL'
    -- resource team members whose category is OTHER or TBH.
    -- These records have to be created in workflow user roles table.

    CURSOR c_team_mem_wf_crt IS
      SELECT mem.team_resource_id resource_id, mem.team_id
            ,greatest (team.start_date_active, ext.start_date_active) m_start_date_active
            ,least (NVL (team.end_date_active, l_fnd_date) ,
                    NVL (ext.end_date_active, l_fnd_date)) m_end_date_active
      FROM   jtf_rs_resource_extns_vl ext, jtf_rs_team_members mem, jtf_rs_teams_b team
      WHERE  NVL (mem.delete_flag,'N') <> 'Y'
      AND    mem.team_resource_id = ext.resource_id
      AND    mem.resource_type    = 'INDIVIDUAL'
      AND    mem.team_id          = team.team_id
      AND    ext.category IN ('OTHER','TBH')
      AND    ext.resource_name IS NOT NULL
      AND  NVL (TRUNC (ext.end_date_active),l_sysdate)  >= l_sysdate
      AND  NVL (TRUNC (team.end_date_active),l_sysdate) >= l_sysdate
      AND NOT EXISTS (SELECT 1 FROM wf_local_user_roles wlur
                      WHERE mem.resource_type        = 'INDIVIDUAL'
                      AND wlur.user_orig_system_id   = mem.team_resource_id
                      AND   wlur.user_orig_system    = l_ind_orig_system
                      AND   wlur.role_orig_system_id = mem.team_id
                      AND   wlur.role_orig_system    = l_team_orig_system);


    -- Select all active records from resource team members table
    -- (jtf_rs_team_members) that are still not defined in workflow user role
    -- table (wf_local_user_roles). This is for 'INDIVIDUAL' resource team
    -- members whose category is EMPLOYEE, PARTY, PARTNER or SUPPLIER_CONTACT
    -- These records have to be created in workflow user roles table.

    CURSOR c_team_mem_wf_epps_crt IS
      SELECT mem.team_resource_id resource_id, mem.team_id, ext.category, ext.resource_name
            ,greatest (team.start_date_active, ext.start_date_active) m_start_date_active
            ,least (NVL (team.end_date_active, l_fnd_date) ,
                    NVL (ext.end_date_active, l_fnd_date)) m_end_date_active
      FROM   jtf_rs_resource_extns_vl ext, jtf_rs_team_members mem, jtf_rs_teams_b team
      WHERE  NVL (mem.delete_flag,'N') <> 'Y'
      AND    mem.team_resource_id = ext.resource_id
      AND    mem.resource_type    = 'INDIVIDUAL'
      AND    mem.team_id          = team.team_id
      AND    ext.resource_name IS NOT NULL
      AND    ext.category IN ('EMPLOYEE','PARTY','PARTNER','SUPPLIER_CONTACT')
      AND  NVL (TRUNC (ext.end_date_active),l_sysdate)  >= l_sysdate
      AND  NVL (TRUNC (team.end_date_active),l_sysdate) >= l_sysdate
      AND NOT EXISTS (SELECT 1 FROM wf_local_user_roles wlur
                      WHERE mem.resource_type        = 'INDIVIDUAL'
                      AND   wlur.role_orig_system_id = mem.team_id
                      AND   wlur.role_orig_system    = l_team_orig_system
                      AND   wlur.user_orig_system    = l_hz_orig_system);

    -- Select all active records from resource team members table
    -- (jtf_rs_team_members) that are still not defined in workflow
    -- user role table (wf_local_user_roles). This is for 'GROUP'
    -- resource team members.
    -- These records have to be created in workflow user roles table.

    CURSOR c_team_mem_grp_wf_crt IS
      SELECT mem.team_resource_id group_id, mem.team_id
            ,greatest (team.start_date_active, grp.start_date_active) m_start_date_active
            ,least (NVL (team.end_date_active, l_fnd_date) ,
                    NVL (grp.end_date_active, l_fnd_date)) m_end_date_active
      FROM   jtf_rs_groups_b grp, jtf_rs_team_members mem, jtf_rs_teams_b team
      WHERE  NVL (mem.delete_flag,'N') <> 'Y'
      AND    mem.team_resource_id = grp.group_id
      AND    mem.resource_type    = 'GROUP'
      AND    mem.team_id          = team.team_id
      AND  NVL (TRUNC (grp.end_date_active),l_sysdate)  >= l_sysdate
      AND  NVL (TRUNC (team.end_date_active),l_sysdate) >= l_sysdate
      AND NOT EXISTS (SELECT 1 FROM wf_local_user_roles wlur
                      WHERE mem.resource_type        = 'GROUP'
                      AND   wlur.user_orig_system_id = mem.team_resource_id
                      AND   wlur.user_orig_system    = l_grp_orig_system
                      AND   wlur.role_orig_system_id = mem.team_id
                      AND   wlur.role_orig_system    = l_team_orig_system);


    log_msg_hdr5      fnd_new_messages.message_text%type := NULL;
    log_message15     fnd_new_messages.message_text%type := NULL;
    log_message16     fnd_new_messages.message_text%type := NULL;
    log_message17     fnd_new_messages.message_text%type := NULL;
    log_message18     fnd_new_messages.message_text%type := NULL;

    log_message22     fnd_new_messages.message_text%type := NULL;
    log_message23     fnd_new_messages.message_text%type := NULL;
    log_message24     fnd_new_messages.message_text%type := NULL;
    log_message25     fnd_new_messages.message_text%type := NULL;

    log_message32     fnd_new_messages.message_text%type := NULL;
    log_message33     fnd_new_messages.message_text%type := NULL;
    log_message34     fnd_new_messages.message_text%type := NULL;
    log_message35     fnd_new_messages.message_text%type := NULL;

    l_end_date_active      DATE;
    m_end_date_active      DATE;
    m_start_date_active    DATE;
    l_user_name            wf_local_roles.name%TYPE;
    l_user_orig_system     wf_local_roles.orig_system%TYPE;
    l_user_orig_system_id  wf_local_roles.orig_system_id%TYPE;

  BEGIN

    log_msg_hdr5  := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_HDR5');
    log_message15 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG15');
    log_message16 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG16');
    log_message17 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG17');
    log_message18 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG18');

    log_message22 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG22');
    log_message23 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG23');
    log_message24 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG24');
    log_message25 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG25');

    log_message32 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG32');
    log_message33 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG33');
    log_message34 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG34');
    log_message35 := fnd_message.get_string ('JTF','JTF_RS_WF_ROLE_SYNC_LOG_MSG35');

    fnd_file.put_line (fnd_file.log,log_msg_hdr5);
  --fnd_file.put_line (fnd_file.log,'Beginning of Resource Workflow Synchronization for Team Members');
    fnd_file.put_line (fnd_file.log,'---------------------------------------------------------------');
    fnd_file.new_line (fnd_file.log,1);

    --Inactivate all wf user roles which are still active and whose corresponding records
    -- in resource team members table have been deleted (delete_flag Y).
    FOR i IN c_wlur_team_mem_del LOOP
      BEGIN
        Wf_local_synch.propagate_user_role (
          p_user_orig_system      => i.user_orig_system,
          p_user_orig_system_id   => i.user_orig_system_id,
          p_role_orig_system      => l_team_orig_system,
          p_role_orig_system_id   => i.team_id,
          p_raiseerrors           => TRUE,
          p_start_date            => sysdate-2,
          p_expiration_date       => sysdate-1,
          p_overwrite             => TRUE);
      EXCEPTION
        WHEN OTHERS THEN
          wf_core.get_error(error_name, error_message, error_stack);
          fnd_file.put_line (fnd_file.log,error_message);
          fnd_file.new_line (fnd_file.log,1);
          fnd_file.put_line (fnd_file.log,error_stack);
          fnd_file.new_line (fnd_file.log,1);
          wf_core.clear;
      END;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message32);
    --fnd_file.put_line (fnd_file.log,'Successfully inactivated all records in Workflow User Roles table, whose
    --corresponding records in Resource Team Members table have been deleted.');
    fnd_file.new_line (fnd_file.log,1);


    -- Create Workflow User Role for Active Resource Team Members whose
    -- resource_type is INDIVIDUAL and resource category is OTHER or TBH
    FOR i IN c_team_mem_wf_crt LOOP
      IF i.m_end_date_active = l_fnd_date THEN
        l_end_date_active := NULL;
      ELSE
        l_end_date_active :=  i.m_end_date_active;
      END IF;
      BEGIN
        Wf_local_synch.propagate_user_role(
          p_user_orig_system      => l_ind_orig_system,
          p_user_orig_system_id   => i.resource_id,
          p_role_orig_system      => l_team_orig_system,
          p_role_orig_system_id   => i.team_id,
          p_raiseerrors           => TRUE,
          p_start_date            => i.m_start_date_active,
          p_expiration_date       => l_end_date_active);
      EXCEPTION
        WHEN OTHERS THEN
          wf_core.get_error(error_name, error_message, error_stack);
          fnd_file.put_line (fnd_file.log,error_message);
          fnd_file.new_line (fnd_file.log,1);
          fnd_file.put_line (fnd_file.log,error_stack);
          fnd_file.new_line (fnd_file.log,1);
          wf_core.clear;
      END;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message33);
    --fnd_file.put_line (fnd_file.log,'Successfully created Workflow User Role Records, for its corresponding records in
      --Resource Team Members table of Resource Type Individual. This is for Resources who category is Other or To be hired.');
     fnd_file.new_line (fnd_file.log,1);

    -- Create Workflow User Role for Active Resource Team Members whose resource_type is
    -- INDIVIDUAL and resource category is EMPLOYEE, PARTY, PARTNER or SUPPLIER_CONTACT
    FOR i IN c_team_mem_wf_epps_crt LOOP
      IF i.m_end_date_active = l_fnd_date THEN
        l_end_date_active := NULL;
      ELSE
        l_end_date_active :=  i.m_end_date_active;
      END IF;
      -- Get wf user_orig_system and user_orig_system_id for the given resource_id
      jtf_rs_wf_integration_pub.get_wf_role (
         p_resource_id    => i.resource_id
        ,x_role_name      => l_user_name
        ,x_orig_system    => l_user_orig_system
        ,x_orig_system_id => l_user_orig_system_id
      );
      IF (l_user_orig_system IS NULL OR l_user_orig_system_id IS NULL) THEN
        fnd_file.put_line (fnd_file.log,'Not creating Workflow User Roles for corresponding Resource Team Members whose Member
                           Resource is Resource ID - '||i.resource_id||', Resource Name - '||i.resource_name||' and Resource
                           Category - '||i.category||', because there was no corresponding User defined wf_local_roles table');
      ELSE
        BEGIN
          Wf_local_synch.propagate_user_role(
            p_user_orig_system      => l_user_orig_system,
            p_user_orig_system_id   => l_user_orig_system_id,
            p_role_orig_system      => l_team_orig_system,
            p_role_orig_system_id   => i.team_id,
            p_raiseerrors           => TRUE,
            p_start_date            => i.m_start_date_active,
            p_expiration_date       => l_end_date_active);
        EXCEPTION
          WHEN OTHERS THEN
            wf_core.get_error(error_name, error_message, error_stack);
            fnd_file.put_line (fnd_file.log,error_message);
            fnd_file.new_line (fnd_file.log,1);
            fnd_file.put_line (fnd_file.log,error_stack);
            fnd_file.new_line (fnd_file.log,1);
            wf_core.clear;
        END;
      END IF;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message34);
    --fnd_file.put_line (fnd_file.log,'Successfully created Workflow User Role Records, for its corresponding records in
    --Resource Team Members tables of Resource Type Individual. This is for Resources who category is Employee, Party,
    --Partner or Supplier Contact.');
    fnd_file.new_line (fnd_file.log,1);

    -- Create Workflow User Role for Active Resource Team Members ('GROUP' Members)
    FOR i IN c_team_mem_grp_wf_crt LOOP
      IF i.m_end_date_active = l_fnd_date THEN
        l_end_date_active := NULL;
      ELSE
        l_end_date_active :=  i.m_end_date_active;
      END IF;
      BEGIN
        Wf_local_synch.propagate_user_role(
          p_user_orig_system      => l_grp_orig_system,
          p_user_orig_system_id   => i.group_id,
          p_role_orig_system      => l_team_orig_system,
          p_role_orig_system_id   => i.team_id,
          p_raiseerrors           => TRUE,
          p_start_date            => i.m_start_date_active,
          p_expiration_date       => l_end_date_active);
      EXCEPTION
        WHEN OTHERS THEN
          wf_core.get_error(error_name, error_message, error_stack);
          fnd_file.put_line (fnd_file.log,error_message);
          fnd_file.new_line (fnd_file.log,1);
          fnd_file.put_line (fnd_file.log,error_stack);
          fnd_file.new_line (fnd_file.log,1);
          wf_core.clear;
      END;
    END LOOP;

    fnd_file.put_line (fnd_file.log,log_message35);
    --fnd_file.put_line (fnd_file.log,'Successfully created Workflow User Role Records, for its corresponding
    --records in Resource Team Members table of Resource Type Group');
     fnd_file.new_line (fnd_file.log,1);

  EXCEPTION
    WHEN OTHERS THEN
      wf_core.get_error(error_name, error_message, error_stack);
      fnd_file.put_line (fnd_file.log,error_message);
      fnd_file.new_line (fnd_file.log,1);
      fnd_file.put_line (fnd_file.log,error_stack);
      fnd_file.new_line (fnd_file.log,1);
      wf_core.clear;

  END synchronize_team_members_wf;

  BEGIN

    IF (P_SYNC_COMP = 'Team') THEN
      synchronize_teams_wf;
      synchronize_groups_wf;
      synchronize_resources_wf;
      synchronize_team_members_wf;
    ELSIF (P_SYNC_COMP = 'Group') THEN
      synchronize_groups_wf;
      synchronize_resources_wf;
      synchronize_group_members_wf;
    ELSIF (P_SYNC_COMP = 'All') THEN
      synchronize_groups_wf;
      synchronize_teams_wf;
      synchronize_resources_wf;
      synchronize_group_members_wf;
      synchronize_team_members_wf;
    END IF;

  END synchronize_wf_roles;

END jtf_rs_conc_wf_pub;

/
