--------------------------------------------------------
--  DDL for Package Body JTF_RS_RESOURCE_TEAM_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RESOURCE_TEAM_VUHK" AS
-- $Header: cnrstmb.pls 120.1 2005/08/04 15:14:52 mblum noship $

  -- helper procedure for the MOAC session context
  PROCEDURE restore_context(p_acc_mode VARCHAR2,
                            p_org_id   NUMBER) IS
  BEGIN
     IF p_acc_mode IS NOT NULL then
        mo_global.set_policy_context(p_acc_mode, p_org_id);
     END IF;
  END restore_context;


  /* Vertical Industry Procedure for pre processing in case of
	create resource team */

  PROCEDURE  create_resource_team_pre
  (P_TEAM_NAME            IN   JTF_RS_TEAMS_VL.TEAM_NAME%TYPE,
   P_TEAM_DESC            IN   JTF_RS_TEAMS_VL.TEAM_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_TEAMS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_TEAMS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_TEAMS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_TEAMS_VL.END_DATE_ACTIVE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  )IS
  BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
  END create_resource_team_pre;

  /* Vertical Industry Procedure for post processing in case of
	create resource team */

  PROCEDURE  create_resource_team_post
  (P_TEAM_ID              IN   JTF_RS_TEAMS_VL.TEAM_ID%TYPE,
   P_TEAM_NAME            IN   JTF_RS_TEAMS_VL.TEAM_NAME%TYPE,
   P_TEAM_DESC            IN   JTF_RS_TEAMS_VL.TEAM_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_TEAMS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_TEAMS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_TEAMS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_TEAMS_VL.END_DATE_ACTIVE%TYPE,
   X_RETURN_STATUS        OUT  NOCOPY VARCHAR2
  )IS
  BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
  END create_resource_team_post;


  /* Vertical Industry Procedure for pre processing in case of
	update resource team */

  PROCEDURE  update_resource_team_pre
  (P_TEAM_ID              IN   JTF_RS_TEAMS_VL.TEAM_ID%TYPE,
   P_TEAM_NAME            IN   JTF_RS_TEAMS_VL.TEAM_NAME%TYPE,
   P_TEAM_DESC            IN   JTF_RS_TEAMS_VL.TEAM_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_TEAMS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_TEAMS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_TEAMS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_TEAMS_VL.END_DATE_ACTIVE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
  )IS
     l_old_start_date_active DATE ;
     l_old_end_date_active DATE;

     l_team_event_name VARCHAR(60);

     l_date_range_action_tbl   cn_api.date_range_action_tbl_type;

     l_orig_org_id       NUMBER;
     l_orig_acc_mode     VARCHAR2(1);

     CURSOR get_orgs IS
	SELECT org_id FROM cn_repositories_all WHERE status = 'A';

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

	select start_date_active, end_date_active
	  into l_old_start_date_active, l_old_end_date_active
	  from jtf_rs_teams_vl
	  where team_id = P_TEAM_ID;

	cn_api.get_date_range_diff_action
	  (  start_date_new    => P_START_DATE_ACTIVE
	     ,end_date_new     => P_END_DATE_ACTIVE
	     ,start_date_old    => l_old_start_date_active
	     ,end_date_old    => l_old_end_date_active
	     ,x_date_range_action_tbl => l_date_range_action_tbl  );

	FOR i IN 1..l_date_range_action_tbl.COUNT LOOP

	   if l_date_range_action_tbl(i).action_flag = 'I' THEN
	      l_team_event_name := 'CHANGE_TEAM_ADD_REP';
	    else
	      l_team_event_name := 'CHANGE_TEAM_DEL_REP';
	   end if;

	   cn_mark_events_pkg.mark_notify_team
	     (P_TEAM_ID              => P_TEAM_ID,
	      P_TEAM_EVENT_NAME      => l_team_event_name,
	      P_TEAM_NAME            => P_TEAM_NAME,
	      P_START_DATE_ACTIVE    => l_date_range_action_tbl(i).start_date,
	      P_END_DATE_ACTIVE      => l_date_range_action_tbl(i).end_date,
	      P_EVENT_LOG_ID         => NULL,
	      p_org_id               => o.org_id);
	END LOOP;
     END LOOP; -- orgs

     -- restore context
     restore_context(l_orig_acc_mode, l_orig_org_id);

  END update_resource_team_pre;


  /* Vertical Industry Procedure for post processing in case of
	update resource team */

  PROCEDURE  update_resource_team_post
  (P_TEAM_ID              IN   JTF_RS_TEAMS_VL.TEAM_ID%TYPE,
   P_TEAM_NAME            IN   JTF_RS_TEAMS_VL.TEAM_NAME%TYPE,
   P_TEAM_DESC            IN   JTF_RS_TEAMS_VL.TEAM_DESC%TYPE,
   P_EXCLUSIVE_FLAG       IN   JTF_RS_TEAMS_VL.EXCLUSIVE_FLAG%TYPE,
   P_EMAIL_ADDRESS        IN   JTF_RS_TEAMS_VL.EMAIL_ADDRESS%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_TEAMS_VL.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_TEAMS_VL.END_DATE_ACTIVE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  )IS
  BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
  END update_resource_team_post;


END jtf_rs_resource_team_vuhk;





/
