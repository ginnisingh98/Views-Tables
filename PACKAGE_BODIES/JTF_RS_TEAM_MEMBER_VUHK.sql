--------------------------------------------------------
--  DDL for Package Body JTF_RS_TEAM_MEMBER_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_TEAM_MEMBER_VUHK" AS
-- $Header: cntmmbrb.pls 120.1 2005/08/03 15:22:26 mblum noship $

  -- helper procedure for the MOAC session context
  PROCEDURE restore_context(p_acc_mode VARCHAR2,
			    p_org_id   NUMBER) IS
  BEGIN
     IF p_acc_mode IS NOT NULL then
	mo_global.set_policy_context(p_acc_mode, p_org_id);
     END IF;
  END restore_context;

  PROCEDURE  create_team_members_post
  (P_TEAM_MEMBER_ID       IN   JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE,
   P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2) IS

   t_team_name         cn_comp_teams.name%type;
   t_start_date_active cn_comp_teams.start_date_active%type;
   t_end_date_active   cn_comp_teams.end_date_active%type;
   l_orig_org_id       NUMBER;
   l_orig_acc_mode     VARCHAR2(1);

   -- identify that the resource is a rep and the team is salescomp
   CURSOR c_team_member IS
    select ct.name, ct.start_date_active, ct.end_date_active
    from cn_srp_comp_teams_v srpt, cn_comp_teams ct
    where srpt.comp_team_id = P_TEAM_ID
    and srpt.team_resource_id = P_TEAM_RESOURCE_ID
    and ct.comp_team_id = P_TEAM_ID;

   CURSOR get_orgs IS
      SELECT org_id
	FROM cn_salesreps
       WHERE resource_id = p_team_resource_id;


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

	OPEN c_team_member;
	FETCH c_team_member INTO t_team_name, t_start_date_active, t_end_date_active;
	IF (c_team_member%notfound) THEN
	   CLOSE c_team_member;
	ELSE
	   CLOSE c_team_member;

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
  END create_team_members_post;

  PROCEDURE  delete_team_members_pre
  (P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2) IS

   l_dummy             NUMBER;
   t_team_name         cn_comp_teams.name%type;
   t_start_date_active cn_comp_teams.start_date_active%type;
   t_end_date_active   cn_comp_teams.end_date_active%type;
   l_orig_org_id       NUMBER;
   l_orig_acc_mode     VARCHAR2(1);

   -- identify that the resoiurce is a rep and the team is salescomp
   CURSOR c_member IS
    select 1
    from cn_srp_comp_teams_v
    where comp_team_id = P_TEAM_ID
    and team_resource_id = P_TEAM_RESOURCE_ID;

      -- get team info
     CURSOR c_team_info IS
      select name, start_date_active, end_date_active
      from cn_comp_teams
	where comp_team_id = P_TEAM_ID;

     CURSOR get_orgs IS
	SELECT org_id
	  FROM cn_salesreps
	 WHERE resource_id = p_team_resource_id;

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

	OPEN c_member;
	FETCH c_member INTO l_dummy;
	IF (c_member%notfound) THEN
	   CLOSE c_member;
	 ELSE
	   CLOSE c_member;

	   cn_mark_events_pkg.mark_notify_team
	     (P_TEAM_ID              => p_team_id,
	      P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_DEL_REP',
	      P_TEAM_NAME            => null,
	      P_START_DATE_ACTIVE    => null,
	      P_END_DATE_ACTIVE      => null,
	      P_EVENT_LOG_ID         => NULL,
	      p_org_id               => o.org_id);
	END IF;
     END LOOP;

     -- restore context
     restore_context(l_orig_acc_mode, l_orig_org_id);
  END delete_team_members_pre;

  PROCEDURE  update_team_members_pre
  (P_TEAM_MEMBER_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2) IS
  BEGIN
       x_return_status := fnd_api.g_ret_sts_success;
  END update_team_members_pre;

  PROCEDURE  update_team_members_post
  (P_TEAM_MEMBER_ID       IN   JTF_RS_TEAM_MEMBERS.TEAM_MEMBER_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2) IS
  BEGIN
       x_return_status := fnd_api.g_ret_sts_success;
  END update_team_members_post;

  PROCEDURE  delete_team_members_post
  (P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2) IS
  BEGIN
       x_return_status := fnd_api.g_ret_sts_success;
  END delete_team_members_post;

  PROCEDURE  create_team_members_pre
  (P_TEAM_ID              IN   JTF_RS_TEAM_MEMBERS.TEAM_ID%TYPE,
   P_TEAM_RESOURCE_ID     IN   JTF_RS_TEAM_MEMBERS.TEAM_RESOURCE_ID%TYPE,
   P_RESOURCE_TYPE        IN   JTF_RS_TEAM_MEMBERS.RESOURCE_TYPE%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2) IS
  BEGIN
       x_return_status := fnd_api.g_ret_sts_success;
  END create_team_members_pre;

END jtf_rs_team_member_vuhk;


/
