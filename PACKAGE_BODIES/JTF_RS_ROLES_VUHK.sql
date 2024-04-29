--------------------------------------------------------
--  DDL for Package Body JTF_RS_ROLES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_ROLES_VUHK" AS
/* $Header: cnirsrob.pls 120.3 2005/07/29 11:13:16 mblum noship $ */
G_PKG_NAME          VARCHAR2(30) := 'JTF_RS_ROLES_VUHK';

-- helper procedure for the MOAC session context
PROCEDURE restore_context(p_acc_mode VARCHAR2,
			  p_org_id   NUMBER) IS
BEGIN
   IF p_acc_mode IS NOT NULL then
      mo_global.set_policy_context(p_acc_mode, p_org_id);
   END IF;
END restore_context;

-- Vertical Industry Procedure for pre processing in case of create
-- resource roles

PROCEDURE  create_rs_resource_roles_pre
  (P_ROLE_TYPE_CODE          IN      JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE,
   P_ROLE_CODE               IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
   P_ROLE_NAME               IN      JTF_RS_ROLES_TL.ROLE_NAME%TYPE,
   P_ROLE_DESC               IN      JTF_RS_ROLES_TL.ROLE_DESC%TYPE,
   P_ACTIVE_FLAG             IN      JTF_RS_ROLES_B.ACTIVE_FLAG%TYPE,
   P_SEEDED_FLAG             IN      JTF_RS_ROLES_B.SEEDED_FLAG%TYPE,
   P_MEMBER_FLAG             IN      JTF_RS_ROLES_B.MEMBER_FLAG%TYPE,
   P_ADMIN_FLAG              IN      JTF_RS_ROLES_B.ADMIN_FLAG%TYPE,
   P_LEAD_FLAG               IN      JTF_RS_ROLES_B.LEAD_FLAG%TYPE,
   P_MANAGER_FLAG            IN      JTF_RS_ROLES_B.MANAGER_FLAG%TYPE,
   X_RETURN_STATUS	     OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT               OUT     NOCOPY NUMBER,
   X_MSG_DATA                OUT     NOCOPY VARCHAR2) IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
END create_rs_resource_roles_pre;

-- Vertical Industry Procedure for post processing in case of create
-- resource roles

PROCEDURE  create_rs_resource_roles_post
  (P_ROLE_TYPE_CODE          IN      JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE,
   P_ROLE_CODE               IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
   P_ROLE_NAME               IN      JTF_RS_ROLES_TL.ROLE_NAME%TYPE,
   P_ROLE_DESC               IN      JTF_RS_ROLES_TL.ROLE_DESC%TYPE,
   P_ACTIVE_FLAG             IN      JTF_RS_ROLES_B.ACTIVE_FLAG%TYPE,
   P_SEEDED_FLAG             IN      JTF_RS_ROLES_B.SEEDED_FLAG%TYPE,
   P_MEMBER_FLAG             IN      JTF_RS_ROLES_B.MEMBER_FLAG%TYPE,
   P_ADMIN_FLAG              IN      JTF_RS_ROLES_B.ADMIN_FLAG%TYPE,
   P_LEAD_FLAG               IN      JTF_RS_ROLES_B.LEAD_FLAG%TYPE,
   P_MANAGER_FLAG            IN      JTF_RS_ROLES_B.MANAGER_FLAG%TYPE,
   P_ROLE_ID                 IN      JTF_RS_ROLES_B.ROLE_ID%TYPE,
   X_RETURN_STATUS           OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT      	     OUT     NOCOPY NUMBER,
   X_MSG_DATA                OUT     NOCOPY VARCHAR2) IS

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
END create_rs_resource_roles_post;

-- Vertical Industry Procedure for pre processing in case of update
-- resource roles
PROCEDURE  update_rs_resource_roles_pre
  (P_ROLE_ID          	     IN      JTF_RS_ROLES_B.ROLE_ID%TYPE,
   P_ROLE_TYPE_CODE          IN      JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE,
   P_ROLE_CODE               IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
   P_ROLE_NAME               IN      JTF_RS_ROLES_TL.ROLE_NAME%TYPE,
   P_ROLE_DESC               IN      JTF_RS_ROLES_TL.ROLE_DESC%TYPE,
   P_ACTIVE_FLAG             IN      JTF_RS_ROLES_B.ACTIVE_FLAG%TYPE,
   P_SEEDED_FLAG             IN      JTF_RS_ROLES_B.SEEDED_FLAG%TYPE,
   P_MEMBER_FLAG             IN      JTF_RS_ROLES_B.MEMBER_FLAG%TYPE,
   P_ADMIN_FLAG              IN      JTF_RS_ROLES_B.ADMIN_FLAG%TYPE,
   P_LEAD_FLAG               IN      JTF_RS_ROLES_B.LEAD_FLAG%TYPE,
   P_MANAGER_FLAG            IN      JTF_RS_ROLES_B.MANAGER_FLAG%TYPE,
   X_RETURN_STATUS           OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT               OUT     NOCOPY NUMBER,
   X_MSG_DATA                OUT     NOCOPY VARCHAR2) IS

   l_manager_flag           jtf_rs_roles_b.manager_flag%TYPE;
   l_member_flag            jtf_rs_roles_b.member_flag%TYPE;

   l_action_link_id         NUMBER;
   l_event_log_id           NUMBER;
   l_api_name               VARCHAR2(30) := 'update_rs_resource_roles_pre';
   l_return_status          VARCHAR2(1);
   l_loading_status         VARCHAR2(30);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_temp_count             NUMBER;
   l_team_event             VARCHAR2(50);
   -- clku, fix max date year to 9999
   l_max_date               CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');

   l_orig_org_id            NUMBER;
   l_orig_acc_mode          VARCHAR2(1);

   -- cursor to get the old manager_flag
   CURSOR mem_mgr_flag IS
   SELECT manager_flag, member_flag
     FROM jtf_rs_roles_b
    WHERE role_id = p_role_id
      AND role_type_code = 'SALES_COMP';

   CURSOR srp_periods IS
   SELECT cscg.salesrep_id,
          cscg.comp_group_id,
          intel.period_id,
          greatest(cscg.start_date_active, intel.start_date) start_date,
          decode(cscg.end_date_active, null, intel.end_date,
		 Least(cscg.end_date_active, intel.end_date)) end_date
     FROM cn_srp_comp_groups_v cscg,
          cn_srp_intel_periods intel
    WHERE cscg.role_id = p_role_id
      and intel.salesrep_id = cscg.salesrep_id
      and cscg.start_date_active <= intel.end_date
      and (cscg.end_date_active is null or
	   cscg.end_date_active >= intel.start_date);

    -- get the team info associated with the reps who are inturn associated with the role
    CURSOR srp_team(p_role_id NUMBER)IS
        select distinct ct.name name,
               ct.comp_team_id team_id,
               greatest(scg.start_date_active, ct.start_date_active) start_date,
               Least(nvl(ct.end_date_active, l_max_date) , nvl(scg.end_date_active, l_max_date)) end_date
        from cn_srp_comp_teams_v srt, cn_comp_teams ct, cn_srp_comp_groups_v scg
        where scg.role_id = p_role_id
          and srt.salesrep_id = scg.salesrep_id
          and srt.comp_team_id = ct.comp_team_id
          and (scg.start_date_active <= ct.start_date_active
            or scg.start_date_active between ct.start_date_active and nvl (ct.end_date_active, scg.start_date_active))
          and nvl(scg.end_date_active, ct.start_date_active) >= ct.start_date_active;

    CURSOR get_orgs IS
       SELECT org_id
	 FROM cn_repositories_all
	WHERE status = 'A';

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   -- handle mark events
   IF fnd_profile.value('CN_MARK_EVENTS') = 'Y' THEN

      l_manager_flag := 'X';
      l_member_flag  := 'X';

      -- get the old value of manager_flag and  member_flag
      OPEN  mem_mgr_flag;
      FETCH mem_mgr_flag INTO l_manager_flag, l_member_flag;
      CLOSE mem_mgr_flag;

      if l_manager_flag = 'X' and l_member_flag = 'X' then
       return;
      end if;

      -- store MOAC session info in local variables
      l_orig_org_id   := mo_global.get_current_org_id;
      l_orig_acc_mode := mo_global.get_access_mode;

      -- loop through orgs
      FOR o IN get_orgs LOOP
	 mo_global.set_policy_context('S', o.org_id);

	 IF (p_member_flag = 'Y' AND l_member_flag = 'N') THEN
	    cn_mark_events_pkg.log_event
	      (p_event_name      => 'CHANGE_CP_ADD_SRP',
	       p_object_name     => p_role_name,
	       p_object_id       => p_role_id,
	       p_start_date      => NULL,
	       p_start_date_old  => NULL,
	       p_end_date        => NULL,
	       p_end_date_old    => NULL,
	       x_event_log_id    => l_event_log_id,
	       p_org_id          => o.org_id);

	    FOR srp_period IN srp_periods LOOP
	       cn_mark_events_pkg.mark_notify_salesreps
		 (p_salesrep_id        => srp_period.salesrep_id,
		  p_comp_group_id      => srp_period.comp_group_id,
		  p_period_id          => srp_period.period_id,
		  p_start_date         => srp_period.start_date,
		  p_end_date           => srp_period.end_date,
		  p_revert_to_state    => 'ROLL',
		  p_action             => 'PULL_WITHIN',
		  p_action_link_id     => NULL,
		  p_base_salesrep_id   => NULL,
		  p_base_comp_group_id => NULL,
		  p_event_log_id       => l_event_log_id,
		  x_action_link_id     => l_action_link_id,
		  p_org_id             => o.org_id);
	    END LOOP;
	 END IF;

	 -- manager flag changes from Y --> N
	 IF (p_manager_flag = 'N' AND l_manager_flag = 'Y') THEN
	    -- log event for the update of the manager_flag
	    cn_mark_events_pkg.log_event
	      (p_event_name      => 'CHANGE_CP_DELETE_MGR',
	       p_object_name     => p_role_name,
	       p_object_id       => p_role_id,
	       p_start_date      => NULL,
	       p_start_date_old  => NULL,
	       p_end_date        => NULL,
	       p_end_date_old    => NULL,
	       x_event_log_id    => l_event_log_id,
	       p_org_id          => o.org_id);

	    FOR srp_period IN srp_periods LOOP
	       cn_mark_events_pkg.mark_notify_salesreps
		 (p_salesrep_id        => srp_period.salesrep_id,
		  p_comp_group_id      => srp_period.comp_group_id,
		  p_period_id          => srp_period.period_id,
		  p_start_date         => srp_period.start_date,
		  p_end_date           => srp_period.end_date,
		  p_revert_to_state    => 'CALC',
		  p_action             => 'DELETE_DEST_WITHIN',
		  p_action_link_id     => NULL,
		  p_base_salesrep_id   => NULL,
		  p_base_comp_group_id => NULL,
		  p_role_id            => p_role_id,
		  p_event_log_id       => l_event_log_id,
		  x_action_link_id     => l_action_link_id,
		  p_org_id             => o.org_id);
	    END LOOP;
	    -- manager flag changes from N -> Y
	  ELSIF (p_manager_flag = 'Y' AND l_manager_flag = 'N') THEN
	    -- log event for the update of the manager_flag
	    cn_mark_events_pkg.log_event
	      (p_event_name      => 'CHANGE_CP_ADD_MGR',
	       p_object_name     => p_role_name,
	       p_object_id       => p_role_id,
	       p_start_date      => NULL,
	       p_start_date_old  => NULL,
	       p_end_date        => NULL,
	       p_end_date_old    => NULL,
	       x_event_log_id    => l_event_log_id,
	       p_org_id          => o.org_id);

	    FOR srp_period IN srp_periods LOOP
	       cn_mark_events_pkg.mark_notify_salesreps
		 (p_salesrep_id        => srp_period.salesrep_id,
		  p_comp_group_id      => srp_period.comp_group_id,
		  p_period_id          => srp_period.period_id,
		  p_start_date         => srp_period.start_date,
		  p_end_date           => srp_period.end_date,
		  p_revert_to_state    => 'ROLL',
		  p_action             => 'PULL_WITHIN',
		  p_action_link_id     => NULL,
		  p_base_salesrep_id   => NULL,
		  p_base_comp_group_id => NULL,
		  p_event_log_id       => l_event_log_id,
		  x_action_link_id     => l_action_link_id,
		  p_org_id             => o.org_id);
	    END LOOP;
	 END IF;  -- if mgr flag moved from Y to N

	 -- Team related events
	 IF ((l_manager_flag = 'Y' AND p_manager_flag = 'N') OR (l_member_flag = 'Y' and p_member_flag = 'N')) THEN
	    l_team_event := 'CHANGE_TEAM_DEL_REP';
	  ELSIF ((l_manager_flag = 'N' AND p_manager_flag = 'Y') OR (l_member_flag = 'N' and p_member_flag = 'Y')) THEN
	    l_team_event := 'CHANGE_TEAM_ADD_REP';
	  ELSIF (p_manager_flag = 'Y' OR p_member_flag = 'Y') THEN
	    l_team_event := 'CHANGE_TEAM_ADD_REP';
	  ELSIF (p_manager_flag = 'N' OR p_member_flag = 'N') THEN
	    l_team_event := 'CHANGE_TEAM_DEL_REP';
	 END IF;

	 FOR srp_tm_rec IN srp_team (p_role_id) LOOP

	    if srp_tm_rec.end_date = l_max_date then
	       srp_tm_rec.end_date := null;
	    end if;

	    cn_mark_events_pkg.mark_notify_team
	      (P_TEAM_ID              => srp_tm_rec.team_id ,
	       P_TEAM_EVENT_NAME      => l_team_event,
	       P_TEAM_NAME            => srp_tm_rec.name,
	       P_START_DATE_ACTIVE    => srp_tm_rec.start_date,
	       P_END_DATE_ACTIVE      => srp_tm_rec.end_date,
	       P_EVENT_LOG_ID         => l_event_log_id,
	       p_org_id               => o.org_id);
	 END LOOP;
      END LOOP; -- orgs

      -- restore context
      restore_context(l_orig_acc_mode, l_orig_org_id);
   END IF;  -- if mark events set to Y

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      restore_context(l_orig_acc_mode, l_orig_org_id);
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count   => x_msg_count ,
	 p_data    => x_msg_data  ,
	 p_encoded => FND_API.g_false);
END update_rs_resource_roles_pre;


-- Vertical Industry Procedure for post processing in case of update
-- resource roles

PROCEDURE  update_rs_resource_roles_post
  (P_ROLE_ID                 IN      JTF_RS_ROLES_B.ROLE_ID%TYPE,
   P_ROLE_TYPE_CODE          IN      JTF_RS_ROLES_B.ROLE_TYPE_CODE%TYPE,
   P_ROLE_CODE               IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
   P_ROLE_NAME               IN      JTF_RS_ROLES_TL.ROLE_NAME%TYPE,
   P_ROLE_DESC               IN      JTF_RS_ROLES_TL.ROLE_DESC%TYPE,
   P_ACTIVE_FLAG             IN      JTF_RS_ROLES_B.ACTIVE_FLAG%TYPE,
   P_SEEDED_FLAG             IN      JTF_RS_ROLES_B.SEEDED_FLAG%TYPE,
   P_MEMBER_FLAG             IN      JTF_RS_ROLES_B.MEMBER_FLAG%TYPE,
   P_ADMIN_FLAG              IN      JTF_RS_ROLES_B.ADMIN_FLAG%TYPE,
   P_LEAD_FLAG               IN      JTF_RS_ROLES_B.LEAD_FLAG%TYPE,
   P_MANAGER_FLAG            IN      JTF_RS_ROLES_B.MANAGER_FLAG%TYPE,
   X_RETURN_STATUS           OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT               OUT     NOCOPY NUMBER,
   X_MSG_DATA                OUT     NOCOPY VARCHAR2) IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
END update_rs_resource_roles_post;

-- Vertical Industry Procedure for pre processing in case of delete
-- resource roles

PROCEDURE  delete_rs_resource_roles_pre
  (P_ROLE_ID                 IN      JTF_RS_ROLES_B.ROLE_ID%TYPE,
   P_ROLE_CODE               IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
   X_RETURN_STATUS           OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT               OUT     NOCOPY NUMBER,
   X_MSG_DATA                OUT     NOCOPY VARCHAR2) IS

   -- for API call to CN role details
   l_return_status              VARCHAR2(1);
   l_loading_status             VARCHAR2(30);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
END delete_rs_resource_roles_pre;

-- Vertical Industry Procedure for post processing in case of delete
-- resource roles

PROCEDURE  delete_rs_resource_roles_post
  (P_ROLE_ID                 IN      JTF_RS_ROLES_B.ROLE_ID%TYPE,
   P_ROLE_CODE               IN      JTF_RS_ROLES_B.ROLE_CODE%TYPE,
   X_RETURN_STATUS           OUT     NOCOPY VARCHAR2,
   X_MSG_COUNT               OUT     NOCOPY NUMBER,
   X_MSG_DATA                OUT     NOCOPY VARCHAR2) IS
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
END delete_rs_resource_roles_post;


END jtf_rs_roles_vuhk;

/
