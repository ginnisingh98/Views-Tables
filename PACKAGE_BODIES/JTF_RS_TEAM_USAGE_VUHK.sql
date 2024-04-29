--------------------------------------------------------
--  DDL for Package Body JTF_RS_TEAM_USAGE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_TEAM_USAGE_VUHK" AS
-- $Header: cntmusgb.pls 120.1 2005/08/03 15:21:58 mblum noship $

-- helper procedure for the MOAC session context
PROCEDURE restore_context(p_acc_mode VARCHAR2,
			  p_org_id   NUMBER) IS
BEGIN
   IF p_acc_mode IS NOT NULL then
      mo_global.set_policy_context(p_acc_mode, p_org_id);
   END IF;
END restore_context;

PROCEDURE  create_team_usage_post
  (P_TEAM_USAGE_ID        IN   NUMBER,
   P_TEAM_ID              IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT  NOCOPY VARCHAR2) IS

    t_team_name         cn_comp_teams.name%type;
    t_start_date_active cn_comp_teams.start_date_active%type;
    t_end_date_active   cn_comp_teams.end_date_active%type;
    l_event_log_id      number;
    l_orig_org_id       NUMBER;
    l_orig_acc_mode     VARCHAR2(1);

     -- get team info
     CURSOR c_team_info IS
      select name, start_date_active, end_date_active
      from cn_comp_teams
      where comp_team_id = P_TEAM_ID;

     -- get orgs
     CURSOR get_orgs IS
       SELECT org_id
         FROM cn_repositories_all
        WHERE status = 'A';

BEGIN
    X_RETURN_STATUS := fnd_api.g_ret_sts_success;

    IF fnd_profile.value('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    -- store MOAC session info in local variables
    l_orig_org_id   := mo_global.get_current_org_id;
    l_orig_acc_mode := mo_global.get_access_mode;

    -- loop through orgs
    FOR o IN get_orgs LOOP
       mo_global.set_policy_context('S', o.org_id);

       -- if this is not a sales_comp team, dont have to process it
       OPEN c_team_info;
       FETCH c_team_info INTO t_team_name, t_start_date_active, t_end_date_active;
       IF (c_team_info%notfound) THEN
	  CLOSE c_team_info;
	ELSE
	  CLOSE c_team_info;

	  cn_mark_events_pkg.mark_notify_team
	    (P_TEAM_ID              => p_team_id,
	     P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_ADD_REP',
	     P_TEAM_NAME            => t_team_name,
	     P_START_DATE_ACTIVE    => t_start_date_active,
	     P_END_DATE_ACTIVE      => t_end_date_active,
	     P_EVENT_LOG_ID         => NULL,
	     p_org_id               => o.org_id);
       END IF;
    END LOOP;

    -- restore context
    restore_context(l_orig_acc_mode, l_orig_org_id);
  END create_team_usage_post;

  PROCEDURE  delete_team_usage_pre
  (P_TEAM_ID              IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT  NOCOPY VARCHAR2) IS

   t_team_name         cn_comp_teams.name%type;
   t_start_date_active cn_comp_teams.start_date_active%type;
   t_end_date_active   cn_comp_teams.end_date_active%type;
   l_event_log_id      number;
   l_orig_org_id       NUMBER;
   l_orig_acc_mode     VARCHAR2(1);

     -- get team info
     CURSOR c_team_info IS
      select name, start_date_active, end_date_active
      from cn_comp_teams
      where comp_team_id = P_TEAM_ID;

     CURSOR get_orgs IS
       SELECT org_id
         FROM cn_repositories_all
        WHERE status = 'A';

  BEGIN
    X_RETURN_STATUS := fnd_api.g_ret_sts_success;

    IF fnd_profile.value('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    -- store MOAC session info in local variables
    l_orig_org_id   := mo_global.get_current_org_id;
    l_orig_acc_mode := mo_global.get_access_mode;

    -- loop through orgs
    FOR o IN get_orgs LOOP
       mo_global.set_policy_context('S', o.org_id);

       OPEN c_team_info;
       FETCH c_team_info INTO t_team_name, t_start_date_active, t_end_date_active;
       IF (c_team_info%notfound) THEN
	  CLOSE c_team_info;
	ELSE
	  CLOSE c_team_info;

	  cn_mark_events_pkg.mark_notify_team
	    (P_TEAM_ID              => p_team_id,
	     P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_DEL_REP',
	     P_TEAM_NAME            => t_team_name,
	     P_START_DATE_ACTIVE    => t_start_date_active,
	     P_END_DATE_ACTIVE      => t_end_date_active,
	     P_EVENT_LOG_ID         => NULL,
	     p_org_id               => o.org_id);
       END IF;
    END LOOP;

    -- restore context
    restore_context(l_orig_acc_mode, l_orig_org_id);
  END delete_team_usage_pre;

  PROCEDURE  create_team_usage_pre
  (P_TEAM_ID              IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2) IS
  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;
  END create_team_usage_pre;

  PROCEDURE  delete_team_usage_post
  (P_TEAM_ID              IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2) IS
  BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
  END delete_team_usage_post;

END jtf_rs_team_usage_vuhk;


/
