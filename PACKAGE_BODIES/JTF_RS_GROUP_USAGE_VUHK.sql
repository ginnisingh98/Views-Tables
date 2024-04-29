--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_USAGE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_USAGE_VUHK" AS
/* $Header: cnirsgub.pls 120.1 2005/08/04 15:14:08 mblum noship $ */

  G_PKG_NAME          VARCHAR2(30) := 'JTF_RS_GROUP_USAGE_VUHK';

  -- helper procedure for the MOAC session context
  PROCEDURE restore_context(p_acc_mode VARCHAR2,
                            p_org_id   NUMBER) IS
  BEGIN
     IF p_acc_mode IS NOT NULL then
        mo_global.set_policy_context(p_acc_mode, p_org_id);
     END IF;
  END restore_context;

 /* Vertcal Industry Procedure for pre processing in case of create resource group usage */
  PROCEDURE  create_group_usage_pre
  (P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
   ) IS
  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;
  END create_group_usage_pre;

    /* Vertcal Industry Procedure for post processing in case of create resource group usage */
  PROCEDURE  create_group_usage_post
  (P_GROUP_USAGE_ID       IN   NUMBER,
   P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
   ) IS

      l_event_log_id      NUMBER;
      l_start_date        DATE;
      l_end_date          DATE;
      l_group_name        VARCHAR2(60);
      l_action_link_id    NUMBER;
      p_action_link_id    NUMBER;
      l_srp               cn_rollup_pvt.srp_group_rec_type;
      l_srp_tbl           cn_rollup_pvt.srp_group_tbl_type;
      l_return_status     VARCHAR2(30);
      l_msg_count         NUMBER;
      l_msg_data          VARCHAR2(256);
      i                   NUMBER;
      l_api_name          VARCHAR2(30) := 'create_group_usage_post';
      --clku , fix max date year to 9999
      l_max_date          CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');

      l_orig_org_id       NUMBER;
      l_orig_acc_mode     VARCHAR2(1);

      -- cursor to get the start_date and end_date of the new group
      CURSOR dates IS
	 SELECT start_date_active, end_date_active, name
	   FROM cn_comp_groups
	   WHERE comp_group_id = p_group_id;

      -- cursor to find all srps in the new group
      CURSOR srp_periods IS
	 SELECT cscg.salesrep_id,
	        cscg.comp_group_id,
	        intel.period_id,
	        greatest(cscg.start_date_active, intel.start_date) start_date,
	        decode(cscg.end_date_active, null, intel.end_date,
		       Least(cscg.end_date_active, intel.end_date)) end_date
	   FROM cn_srp_comp_groups_v cscg,
	        cn_srp_intel_periods intel
	  WHERE cscg.comp_group_id = p_group_id
	    and intel.salesrep_id = cscg.salesrep_id
	    and cscg.start_date_active <= intel.end_date
	    and (cscg.end_date_active is null or cscg.end_date_active >= intel.start_date);

      -- cursor to find all periods in the date range for each srp
      CURSOR periods(p_salesrep_id NUMBER, p_start_date DATE, p_end_date DATE) IS
	 SELECT p.period_id,
	        greatest(p_start_date, p.start_date) start_date,
	        Decode(p_end_date, NULL, p.end_date, Least(p_end_date, p.end_date)) end_date
	   FROM cn_srp_intel_periods p
	  WHERE p.salesrep_id = p_salesrep_id
	    AND (p_end_date IS NULL OR p.start_date <= p_end_date)
	    AND (p.end_date >= p_start_date);

      -- check if the member is part of a team
      CURSOR srp_team(p_salesrep_id NUMBER, p_group_id NUMBER)IS
         select ct.name name,
                ct.comp_team_id team_id,
                greatest(cg.start_date_active, ct.start_date_active) start_date,
                 Least(nvl(ct.end_date_active, l_max_date), nvl(cg.end_date_active, l_max_date)) end_date
                from cn_srp_comp_teams_v srt, cn_comp_teams ct, cn_comp_groups cg
                where srt.salesrep_id = p_salesrep_id
                and srt.comp_team_id = ct.comp_team_id
                and cg.comp_group_id = p_group_id
                and (cg.start_date_active <= ct.start_date_active
                  or cg.start_date_active between ct.start_date_active and nvl (ct.end_date_active, cg.start_date_active))
                and nvl(cg.end_date_active, ct.start_date_active) >= ct.start_date_active;

      CURSOR get_orgs IS
	 SELECT org_id FROM cn_repositories_all WHERE status = 'A';

  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;

     IF fnd_profile.value('CN_MARK_EVENTS') <> 'Y' THEN
	RETURN;
     END IF;

     -- store MOAC session info in local variables
     l_orig_org_id   := mo_global.get_current_org_id;
     l_orig_acc_mode := mo_global.get_access_mode;

     -- loop through orgs
     FOR o IN get_orgs LOOP
        mo_global.set_policy_context('S', o.org_id);

	-- if the usage is SALES_COMP, then find all srps in this group and their ancestors in the comp group hierarchy.
	-- call mark_notify_salesreps for each of them
	IF (p_usage = 'SALES_COMP') THEN
	   -- get the start_date and end_date of the new group
	   OPEN dates;
	   FETCH dates INTO l_start_date, l_end_date, l_group_name;
	   IF (dates%notfound) THEN
	      CLOSE dates;
	    ELSE
	      CLOSE dates;

	      cn_mark_events_pkg.log_event
		( p_event_name      => 'CHANGE_CP_HIER_ADD',
		  p_object_name     => l_group_name,
		  p_object_id       => p_group_id,
		  p_start_date      => l_start_date,
		  p_start_date_old  => NULL,
		  p_end_date        => l_end_date,
		  p_end_date_old    => NULL,
		  x_event_log_id    => l_event_log_id,
		  p_org_id          => o.org_id);
	      cn_mark_events_pkg.mark_notify_salesreps
		( p_salesrep_id        => NULL,
		  p_comp_group_id      => p_group_id,
		  p_period_id          => null,
		  p_start_date         => l_start_date,
		  p_end_date           => l_end_date,
		  p_revert_to_state    => 'NCALC',
		  p_action             => 'XROLL',
		  p_action_link_id     => NULL,
		  p_base_salesrep_id   => NULL,
		  p_base_comp_group_id => NULL,
		  p_event_log_id       => l_event_log_id,
		  x_action_link_id     => p_action_link_id,
		  p_org_id             => o.org_id);

	      i := 0;
	      FOR srp_period IN srp_periods LOOP
		 -- get the info about the first salesrep to be used to get all the ancestors.
		 -- if the salesrep is not a manager and the ancestors will include managers in the same group, then
		 -- we can get the info of a manager in this group and use it to find ancestors.
		 IF (i = 0) THEN
		    l_srp.salesrep_id := srp_period.salesrep_id;
		    l_srp.group_id := srp_period.comp_group_id;
		    i := i + 1;
		 END IF;
		 cn_mark_events_pkg.mark_notify_salesreps
		   ( p_salesrep_id        => srp_period.salesrep_id,
		     p_comp_group_id      => srp_period.comp_group_id,
		     p_period_id          => srp_period.period_id,
		     p_start_date         => srp_period.start_date,
		     p_end_date           => srp_period.end_date,
		     p_revert_to_state    => 'CALC',
		     p_action             => 'PULL',
		     p_action_link_id     => p_action_link_id,
		     p_base_salesrep_id   => NULL,
		     p_base_comp_group_id => NULL,
		     p_event_log_id       => l_event_log_id,
		     x_action_link_id     => l_action_link_id,
		     p_org_id             => o.org_id);

		 -- check if this rep belongs to a team
		 FOR srp_tm_rec IN srp_team (srp_period.salesrep_id, p_group_id) LOOP

		    if srp_tm_rec.end_date = l_max_date then
		       srp_tm_rec.end_date := null;
		    end if;

		    cn_mark_events_pkg.mark_notify_team
		      (P_TEAM_ID              => srp_tm_rec.team_id ,
		       P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_ADD_REP',
		       P_TEAM_NAME            => srp_tm_rec.name,
		       P_START_DATE_ACTIVE    => srp_tm_rec.start_date,
		       P_END_DATE_ACTIVE      => srp_tm_rec.end_date,
		       P_EVENT_LOG_ID         => l_event_log_id,
		       p_org_id               => o.org_id);
		 END LOOP;
	      END LOOP;

	      -- find the ancestors of this salesrep and call mark_notify for all of them
	      -- not that we use l_start_date and l_end_date since this date range is the super range which covers
	      -- the date effectivity of all the salesreps in this group.
	      l_srp.start_date  := l_start_date;
	      l_srp.end_date    := l_end_date;
	      cn_rollup_pvt.get_ancestor_salesrep
		( p_api_version         => 1.0,
		  p_init_msg_list       => FND_API.G_false,
		  p_commit              => FND_API.G_false,
		  p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
		  x_return_status       => l_return_status,
		  x_msg_count           => l_msg_count,
		  x_msg_data            => l_msg_data,
		  p_srp                 => l_srp,
		  p_org_id              => o.org_id,
		  x_srp                 => l_srp_tbl);

	      IF (l_srp_tbl.COUNT > 0) THEN
		 FOR i IN l_srp_tbl.first..l_srp_tbl.last LOOP
		    FOR prd IN periods(l_srp_tbl(i).salesrep_id, l_srp_tbl(i).start_date, l_srp_tbl(i).end_date) LOOP
		       cn_mark_events_pkg.mark_notify_salesreps
			 ( p_salesrep_id        => l_srp_tbl(i).salesrep_id,
			   p_comp_group_id      => l_srp_tbl(i).group_id,
			   p_period_id          => prd.period_id,
			   p_start_date         => prd.start_date,
			   p_end_date           => prd.end_date,
			   p_revert_to_state    => 'CALC',
			   p_action             => NULL,
			   p_action_link_id     => p_action_link_id,
			   p_base_salesrep_id   => NULL,
			   p_base_comp_group_id => NULL,
			   p_event_log_id       => l_event_log_id,
			   x_action_link_id     => l_action_link_id,
			   p_org_id             => o.org_id);
		    END LOOP;

		    -- check if this rep belongs to a team
		    FOR srp_tm_rec IN srp_team (l_srp_tbl(i).salesrep_id, l_srp_tbl(i).group_id) LOOP
		       if srp_tm_rec.end_date = l_max_date then
			  srp_tm_rec.end_date := null;
		       end if;

		       cn_mark_events_pkg.mark_notify_team
			 (P_TEAM_ID              => srp_tm_rec.team_id ,
			  P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_ADD_REP',
			  P_TEAM_NAME            => srp_tm_rec.name,
			  P_START_DATE_ACTIVE    => srp_tm_rec.start_date,
			  P_END_DATE_ACTIVE      => srp_tm_rec.end_date,
			  P_EVENT_LOG_ID         => l_event_log_id,
			  p_org_id               => o.org_id);
		    END LOOP;
		 END LOOP;
	      END IF;

	      l_srp_tbl.DELETE;
	   END IF;
	END IF; -- dates found
     END LOOP; -- orgs

     -- restore context
     restore_context(l_orig_acc_mode, l_orig_org_id);

  EXCEPTION
     WHEN OTHERS THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	restore_context(l_orig_acc_mode, l_orig_org_id);
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	END IF;
	FND_MSG_PUB.count_and_get
	  (
	   p_count   =>  l_msg_count ,
	   p_data    =>  l_msg_data  ,
	   p_encoded => FND_API.g_false
	   );
  END create_group_usage_post;

  /* Vertcal Industry Procedure for pre processing in case of delete resource group usage */
  PROCEDURE  delete_group_usage_pre
  (P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
   ) IS

      l_event_log_id      NUMBER;
      l_start_date        DATE;
      l_end_date          DATE;
      l_group_name        VARCHAR2(60);
      l_action_link_id    NUMBER;
      l_srp               cn_rollup_pvt.srp_group_rec_type;
      l_srp_tbl           cn_rollup_pvt.srp_group_tbl_type;
      l_return_status     VARCHAR2(30);
      l_msg_count         NUMBER;
      l_msg_data          VARCHAR2(256);
      i                   NUMBER;
      l_api_name          VARCHAR2(30) := 'delete_group_usage_pre';
      --clku , fix max date year to 9999
      l_max_date          CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');

      l_orig_org_id       NUMBER;
      l_orig_acc_mode     VARCHAR2(1);

      -- cursor to get the start_date and end_date of the new group
      CURSOR dates IS
	 SELECT start_date_active, end_date_active, name
	   FROM cn_comp_groups
	   WHERE comp_group_id = p_group_id;

      -- cursor to find all srps in the new group
      CURSOR srp_periods IS
	 SELECT cscg.salesrep_id,
	        cscg.comp_group_id,
	        intel.period_id,
	        greatest(cscg.start_date_active, intel.start_date) start_date,
	        decode(cscg.end_date_active, null, intel.end_date,
		       Least(cscg.end_date_active, intel.end_date)) end_date
	   FROM cn_srp_comp_groups_v cscg,
	        cn_srp_intel_periods intel
	  WHERE cscg.comp_group_id = p_group_id
	    and intel.salesrep_id = cscg.salesrep_id
	    and cscg.start_date_active <= intel.end_date
	    and (cscg.end_date_active is null or cscg.end_date_active >= intel.start_date);

      -- cursor to find all periods in the date range for each srp
      CURSOR periods(p_salesrep_id NUMBER, p_start_date DATE, p_end_date DATE) IS
	 SELECT p.period_id,
	        greatest(p_start_date, p.start_date) start_date,
	        Decode(p_end_date, NULL, p.end_date, Least(p_end_date, p.end_date)) end_date
	   FROM cn_srp_intel_periods p
	  WHERE p.salesrep_id = p_salesrep_id
	    AND (p_end_date IS NULL OR p.start_date <= p_end_date)
	    AND (p.end_date >= p_start_date);

      -- check if the member is part of a team
      CURSOR srp_team(p_salesrep_id NUMBER, p_group_id NUMBER)IS
         select ct.name name,
                ct.comp_team_id team_id,
                greatest(cg.start_date_active, ct.start_date_active) start_date,
                Least(nvl(ct.end_date_active, l_max_date), nvl(cg.end_date_active, l_max_date)) end_date
                from cn_srp_comp_teams_v srt, cn_comp_teams ct, cn_comp_groups cg
                where srt.salesrep_id = p_salesrep_id
                and srt.comp_team_id = ct.comp_team_id
                and cg.comp_group_id = p_group_id
                and (cg.start_date_active <= ct.start_date_active
                  or cg.start_date_active between ct.start_date_active and nvl (ct.end_date_active, cg.start_date_active))
                and nvl(cg.end_date_active, ct.start_date_active) >= ct.start_date_active;

      CURSOR get_orgs IS
	 SELECT org_id FROM cn_repositories_all WHERE status = 'A';

  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;

     IF fnd_profile.value('CN_MARK_EVENTS') <> 'Y' THEN
	RETURN;
     END IF;

     -- store MOAC session info in local variables
     l_orig_org_id   := mo_global.get_current_org_id;
     l_orig_acc_mode := mo_global.get_access_mode;

     -- loop through orgs
     FOR o IN get_orgs LOOP
        mo_global.set_policy_context('S', o.org_id);

	-- if the usage is SALES_COMP, then find all srps in this group and their ancestors in the comp group hierarchy.
	-- call mark_notify_salesreps for each of them
	IF (p_usage = 'SALES_COMP') THEN
	   -- get the start_date and end_date of the new group
	   OPEN dates;
	   FETCH dates INTO l_start_date, l_end_date, l_group_name;
	   IF (dates%notfound) THEN
	      CLOSE dates;
	    ELSE
	      CLOSE dates;

	      cn_mark_events_pkg.log_event
		( p_event_name      => 'CHANGE_CP_HIER_DELETE',
		  p_object_name     => l_group_name,
		  p_object_id       => p_group_id,
		  p_start_date      => l_start_date,
		  p_start_date_old  => NULL,
		  p_end_date        => l_end_date,
		  p_end_date_old    => NULL,
		  x_event_log_id    => l_event_log_id,
		  p_org_id          => o.org_id);

	      i := 0;
	      FOR srp_period IN srp_periods LOOP
		 -- get the info about the first salesrep to be used to get all the ancestors.
		 -- if the salesrep is not a manager and the ancestors will include managers in the same group, then
		 -- we can get the info of a manager in this group and use it to find ancestors.
		 IF (i = 0) THEN
		    l_srp.salesrep_id := srp_period.salesrep_id;
		    l_srp.group_id := srp_period.comp_group_id;
		    i := i + 1;
		 END IF;

		 cn_mark_events_pkg.mark_notify_salesreps
		   ( p_salesrep_id        => srp_period.salesrep_id,
		     p_comp_group_id      => srp_period.comp_group_id,
		     p_period_id          => srp_period.period_id,
		     p_start_date         => srp_period.start_date,
		     p_end_date           => srp_period.end_date,
		     p_revert_to_state    => 'CALC',
		     p_action             => 'DELETE_DEST_XROLL',
		     p_action_link_id     => NULL,
		     p_base_salesrep_id   => NULL,
		     p_base_comp_group_id => NULL,
		     p_event_log_id       => l_event_log_id,
		     x_action_link_id     => l_action_link_id,
		     p_org_id             => o.org_id);

		 -- check if this rep belongs to a team
		 FOR srp_tm_rec IN srp_team (srp_period.salesrep_id, p_group_id) LOOP

		    if srp_tm_rec.end_date = l_max_date then
		       srp_tm_rec.end_date := null;
		    end if;

		    cn_mark_events_pkg.mark_notify_team
		      (P_TEAM_ID              => srp_tm_rec.team_id ,
		       P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_DEL_REP',
		       P_TEAM_NAME            => srp_tm_rec.name,
		       P_START_DATE_ACTIVE    => srp_tm_rec.start_date,
		       P_END_DATE_ACTIVE      => srp_tm_rec.end_date,
		       P_EVENT_LOG_ID         => l_event_log_id,
		       p_org_id               => o.org_id);
		 END LOOP;
	      END LOOP;

	      -- find the ancestors of this salesrep and call mark_notify for all of them
	      -- not that we use l_start_date and l_end_date since this date range is the super range which covers
	      -- the date effectivity of all the salesreps in this group.
	      l_srp.start_date  := l_start_date;
	      l_srp.end_date    := l_end_date;
	      cn_rollup_pvt.get_ancestor_salesrep
		( p_api_version         => 1.0,
		  p_init_msg_list       => FND_API.G_false,
		  p_commit              => FND_API.G_false,
		  p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
		  x_return_status       => l_return_status,
		  x_msg_count           => l_msg_count,
		  x_msg_data            => l_msg_data,
		  p_srp                 => l_srp,
		  p_org_id              => o.org_id,
		  x_srp                 => l_srp_tbl);

	      IF (l_srp_tbl.COUNT > 0) THEN
		 FOR i IN l_srp_tbl.first..l_srp_tbl.last LOOP
		    FOR prd IN periods(l_srp_tbl(i).salesrep_id, l_srp_tbl(i).start_date, l_srp_tbl(i).end_date) LOOP
		       cn_mark_events_pkg.mark_notify_salesreps
			 ( p_salesrep_id        => l_srp_tbl(i).salesrep_id,
			   p_comp_group_id      => l_srp_tbl(i).group_id,
			   p_period_id          => prd.period_id,
			   p_start_date         => prd.start_date,
			   p_end_date           => prd.end_date,
			   p_revert_to_state    => 'CALC',
			   p_action             => 'DELETE_SOURCE',
			   p_action_link_id     => NULL,
			   p_base_salesrep_id   => NULL,
			   p_base_comp_group_id => p_group_id,
			   p_event_log_id       => l_event_log_id,
			   x_action_link_id     => l_action_link_id,
			   p_org_id             => o.org_id);
		    END LOOP;

		    -- check if this rep belongs to a team
		    FOR srp_tm_rec IN srp_team (l_srp_tbl(i).salesrep_id,  l_srp_tbl(i).group_id) LOOP

		       if srp_tm_rec.end_date = l_max_date then
			  srp_tm_rec.end_date := null;
		       end if;

		       cn_mark_events_pkg.mark_notify_team
			 (P_TEAM_ID              => srp_tm_rec.team_id ,
			  P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_DEL_REP',
			  P_TEAM_NAME            => srp_tm_rec.name,
			  P_START_DATE_ACTIVE    => srp_tm_rec.start_date,
			  P_END_DATE_ACTIVE      => srp_tm_rec.end_date,
			  P_EVENT_LOG_ID         => l_event_log_id,
			  p_org_id               => o.org_id);
		    END LOOP;
		 END LOOP;
	      END IF;

	      l_srp_tbl.DELETE;
	   END IF;
	END IF; -- dates found
     END LOOP; -- orgs

     -- restore context
     restore_context(l_orig_acc_mode, l_orig_org_id);

  EXCEPTION
     WHEN OTHERS THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	restore_context(l_orig_acc_mode, l_orig_org_id);
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	END IF;
	FND_MSG_PUB.count_and_get
	  (
	   p_count   =>  l_msg_count ,
	   p_data    =>  l_msg_data  ,
	   p_encoded => FND_API.g_false
	   );
  END delete_group_usage_pre;


  /* Vertcal Industry Procedure for post processing in case of delete resource group usage */
  PROCEDURE  delete_group_usage_post
  (P_GROUP_ID             IN   NUMBER,
   P_USAGE                IN   VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
   ) IS
  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;
  END delete_group_usage_post;

END jtf_rs_group_usage_vuhk;

/
