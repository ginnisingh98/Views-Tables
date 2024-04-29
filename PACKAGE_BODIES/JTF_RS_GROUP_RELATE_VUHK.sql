--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_RELATE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_RELATE_VUHK" AS
/* $Header: cnirsgrb.pls 120.2 2005/08/04 15:12:41 mblum noship $ */

-- variables to pass the values from update_res_group_relate_pre to update_res_group_relate_post
  G_PKG_NAME          VARCHAR2(30) := 'JTF_RS_GROUP_RELATE_VUHK';
  g_event_log_id      NUMBER;
  g_start_date_old    DATE;
  g_end_date_old      DATE;
  g_group_id          NUMBER;

  -- helper procedure for the MOAC session context
  PROCEDURE restore_context(p_acc_mode VARCHAR2,
                            p_org_id   NUMBER) IS
  BEGIN
     IF p_acc_mode IS NOT NULL then
        mo_global.set_policy_context(p_acc_mode, p_org_id);
     END IF;
  END restore_context;


 PROCEDURE  create_res_group_relate_pre
  (P_GROUP_ID             IN   JTF_RS_GROUPS_B.GROUP_ID%TYPE,
   P_RELATED_GROUP_ID     IN   JTF_RS_GRP_RELATIONS.RELATED_GROUP_ID%TYPE,
   P_RELATION_TYPE        IN   JTF_RS_GRP_RELATIONS.RELATION_TYPE%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE   DEFAULT  NULL,
   P_DATA                 OUT  NOCOPY VARCHAR2,
   P_COUNT                OUT  NOCOPY NUMBER,
   P_RETURN_CODE          OUT  NOCOPY VARCHAR2
   ) IS
  BEGIN
     p_return_code := fnd_api.g_ret_sts_success;
  END create_res_group_relate_pre;


  PROCEDURE  update_res_group_relate_pre
  (P_GROUP_RELATE_ID      IN   JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_GRP_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
   P_DATA                   OUT  NOCOPY VARCHAR2,
   P_COUNT            OUT  NOCOPY NUMBER,
   P_RETURN_CODE            OUT  NOCOPY VARCHAR2
   ) IS
      l_start_date        DATE;
      l_end_date          DATE;
      l_group_name        VARCHAR2(60);
      l_action_link_id    NUMBER;
      l_roll_action_link_id    NUMBER;
      l_srp               cn_rollup_pvt.srp_group_rec_type;
      l_srp_tbl           cn_rollup_pvt.srp_group_tbl_type;
      l_return_status     VARCHAR2(30);
      l_msg_count         NUMBER;
      l_msg_data          VARCHAR2(256);
      l_api_name          VARCHAR2(30) := 'update_res_group_relate_pre';
      -- clku, fix max date
      l_max_date        CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');

      l_orig_org_id       NUMBER;
      l_orig_acc_mode     VARCHAR2(1);


      -- cursor to get the usage code of the group identified by p_group_id
      -- Do we need to make sure that the related group is also used by OSC
      CURSOR group_info IS
	 SELECT r.start_date_active, r.end_date_active, r.group_id
	   FROM jtf_rs_group_usages u,
	        jtf_rs_grp_relations r
	   WHERE r.group_relate_id = p_group_relate_id
	     AND u.group_id = r.group_id AND u.usage = 'SALES_COMP';

      -- cursor to get the name of the group identified by p_group_id
      CURSOR group_name IS
	 SELECT name
	   FROM cn_comp_groups
	   WHERE comp_group_id = g_group_id;

      -- cursor to find all periods in the date range for each srp
      CURSOR periods(p_salesrep_id NUMBER, p_start_date DATE, p_end_date DATE) IS
	 SELECT p.period_id,
	        greatest(p_start_date, p.start_date) start_date,
	        Decode(p_end_date, NULL, p.end_date, Least(p_end_date, p.end_date)) end_date
	   FROM cn_srp_intel_periods p
	  WHERE p.salesrep_id = p_salesrep_id
	    AND (p_end_date IS NULL OR p.start_date <= p_end_date)
	    AND (p.end_date >= p_start_date);

        --- get the reps who belong to the group
     CURSOR srp_group_team_csr (p_salesrep_id NUMBER, p_group_id NUMBER, p_start_date DATE, p_end_date DATE)IS
         select distinct ct.name name,
                ct.comp_team_id team_id,
                greatest(p_start_date, cg.start_date_active, ct.start_date_active) start_date,
                least(nvl(ct.end_date_active, l_max_date), nvl(cg.end_date_active, l_max_date), nvl(p_end_date, l_max_date)) end_date
         from cn_srp_comp_teams_v srt, cn_comp_teams ct, cn_srp_comp_groups_v cg
         where (p_salesrep_id IS NULL or srt.salesrep_id = p_salesrep_id)
           and (p_salesrep_id IS NULL or cg.salesrep_id = p_salesrep_id)
           and cg.comp_group_id = p_group_id
           and srt.comp_team_id = ct.comp_team_id
           and (cg.start_date_active <= ct.start_date_active
             or cg.start_date_active between ct.start_date_active and nvl (ct.end_date_active, cg.start_date_active))
           and nvl(cg.end_date_active, ct.start_date_active) >= ct.start_date_active
           and (cg.end_date_active IS NULL OR p_start_date <= cg.end_date_active)
  	       and (p_end_date IS NULL OR p_end_date >= cg.start_date_active);

     CURSOR get_orgs IS
	SELECT org_id FROM cn_repositories_all WHERE status = 'A';
  BEGIN
     p_return_code := fnd_api.g_ret_sts_success;

     IF fnd_profile.value('CN_MARK_EVENTS') <> 'Y' THEN
	RETURN;
     END IF;

     -- store MOAC session info in local variables
     l_orig_org_id   := mo_global.get_current_org_id;
     l_orig_acc_mode := mo_global.get_access_mode;

     -- loop through orgs
     FOR o IN get_orgs LOOP
        mo_global.set_policy_context('S', o.org_id);

	-- reset g_group_id to null before trying to set it to another value.
	g_group_id := NULL;

	OPEN group_info;
	FETCH group_info INTO g_start_date_old, g_end_date_old, g_group_id;
	IF (group_info%notfound) THEN
	   CLOSE group_info;
	 ELSE
	   CLOSE group_info;

	   OPEN group_name;
	   FETCH group_name INTO l_group_name;
	   IF (group_name%notfound) THEN
	      CLOSE group_name;
	    ELSE
	      CLOSE group_name;

	      cn_mark_events_pkg.log_event
		( p_event_name      => 'CHANGE_CP_HIER_DATE',
		  p_object_name     => l_group_name,
		  p_object_id       => g_group_id,
		  p_start_date      => p_start_date_active,
		  p_start_date_old  => g_start_date_old,
		  p_end_date        => p_end_date_active,
		  p_end_date_old    => g_end_date_old,
		  x_event_log_id    => g_event_log_id,
		  p_org_id          => o.org_id);

	      l_srp.group_id := g_group_id;
	      -- delete the period (g_start_date_old, p_start_date_active) which is not active any more
	      IF (p_start_date_active > g_start_date_old) THEN
		 IF (g_end_date_old IS NOT NULL AND g_end_date_old < p_start_date_active) THEN
		    l_end_date := g_end_date_old;
		  ELSE
		    l_end_date := p_start_date_active - 1;
		 END IF;

		 l_srp.start_date := g_start_date_old;
		 l_srp.end_date := l_end_date;

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
		    cn_mark_events_pkg.mark_notify_salesreps
		      ( p_salesrep_id        => NULL,
			p_comp_group_id      => l_srp.group_id,
			p_period_id          => null,
			p_start_date         => l_srp.start_date,
			p_end_date           => l_srp.end_date,
			p_revert_to_state    => 'NCALC',
			p_action             => 'DELETE_ROLL_PULL',
			p_action_link_id     => NULL,
			p_base_salesrep_id   => NULL,
			p_base_comp_group_id => NULL,
			p_event_log_id       => g_event_log_id,
			x_action_link_id     => l_roll_action_link_id,
			p_org_id             => o.org_id);

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
			      p_action_link_id     => l_roll_action_link_id,
			      p_base_salesrep_id   => NULL,
			      p_base_comp_group_id => NULL,
			      p_event_log_id       => g_event_log_id,
			      x_action_link_id     => l_action_link_id,
			      p_org_id             => o.org_id);
		       END LOOP;

		       -- check if this rep belongs to a team
		       FOR srp_gp_tm_rec IN srp_group_team_csr (l_srp_tbl(i).salesrep_id, l_srp_tbl(i).group_id, l_srp_tbl(i).start_date, l_srp_tbl(i).end_date) LOOP

			  if srp_gp_tm_rec.end_date = l_max_date then
			     srp_gp_tm_rec.end_date := NULL;
			  end if;

			  cn_mark_events_pkg.mark_notify_team
			    (P_TEAM_ID              => srp_gp_tm_rec.team_id ,
			     P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_DEL_REP',
			     P_TEAM_NAME            => srp_gp_tm_rec.name,
			     P_START_DATE_ACTIVE    => srp_gp_tm_rec.start_date,
			     P_END_DATE_ACTIVE      => srp_gp_tm_rec.end_date,
			     P_EVENT_LOG_ID         => g_event_log_id,
			     p_org_id               => o.org_id);
		       END LOOP;
		    END LOOP;
		 END IF;
		 l_srp_tbl.DELETE;
	      END IF;

	      -- delete the period (p_end_date_active, g_end_date_old) which is not active any more
	      IF ((g_end_date_old IS NULL AND p_end_date_active IS NOT NULL) OR p_end_date_active < g_end_date_old) THEN
		 IF (p_end_date_active < g_start_date_old) THEN
		    l_start_date := g_start_date_old;
		  ELSE
		    l_start_date := p_end_date_active + 1;
		 END IF;

		 l_srp.start_date := l_start_date;
		 l_srp.end_date := g_end_date_old;

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
		    cn_mark_events_pkg.mark_notify_salesreps
		      ( p_salesrep_id        => NULL,
			p_comp_group_id      => l_srp.group_id,
			p_period_id          => null,
			p_start_date         => l_srp.start_date,
			p_end_date           => l_srp.end_date,
			p_revert_to_state    => 'NCALC',
			p_action             => 'DELETE_ROLL_PULL',
			p_action_link_id     => NULL,
			p_base_salesrep_id   => NULL,
			p_base_comp_group_id => NULL,
			p_event_log_id       => g_event_log_id,
			x_action_link_id     => l_roll_action_link_id,
			p_org_id             => o.org_id);

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
			      p_action_link_id     => l_roll_action_link_id,
			      p_base_salesrep_id   => NULL,
			      p_base_comp_group_id => NULL,
			      p_event_log_id       => g_event_log_id,
			      x_action_link_id     => l_action_link_id,
			      p_org_id             => o.org_id);
		       END LOOP;

		       -- check if this rep belongs to a team
		       FOR srp_gp_tm_rec IN srp_group_team_csr (l_srp_tbl(i).salesrep_id, l_srp_tbl(i).group_id, l_srp_tbl(i).start_date, l_srp_tbl(i).end_date) LOOP

			  if srp_gp_tm_rec.end_date = l_max_date then
			     srp_gp_tm_rec.end_date := NULL;
			  end if;

			  cn_mark_events_pkg.mark_notify_team
			    (P_TEAM_ID              => srp_gp_tm_rec.team_id ,
			     P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_DEL_REP',
			     P_TEAM_NAME            => srp_gp_tm_rec.name,
			     P_START_DATE_ACTIVE    => srp_gp_tm_rec.start_date,
			     P_END_DATE_ACTIVE      => srp_gp_tm_rec.end_date,
			     P_EVENT_LOG_ID         => g_event_log_id,
			     p_org_id               => o.org_id);
		       END LOOP;
		    END LOOP;
		 END IF;
		 l_srp_tbl.DELETE;
	      END IF;

	   END IF; -- group_name found
	END IF; -- group_info found
     END LOOP; -- orgs

      -- restore context
     restore_context(l_orig_acc_mode, l_orig_org_id);

  EXCEPTION
     WHEN OTHERS THEN
	p_return_code := fnd_api.g_ret_sts_unexp_error;
	restore_context(l_orig_acc_mode, l_orig_org_id);
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	END IF;
	FND_MSG_PUB.count_and_get
	  (
	   p_count   =>  p_count ,
	   p_data    =>  p_data  ,
	   p_encoded => FND_API.g_false
	   );

  END update_res_group_relate_pre;

  PROCEDURE  delete_res_group_relate_pre
  (P_GROUP_RELATE_ID      IN   JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_GROUPS_VL.OBJECT_VERSION_NUMBER%TYPE,
   P_DATA                 OUT  NOCOPY VARCHAR2,
   P_COUNT                OUT  NOCOPY NUMBER,
   P_RETURN_CODE          OUT  NOCOPY VARCHAR2
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
      l_group_id          NUMBER;
      l_api_name          VARCHAR2(30) := 'delete_res_group_relate_pre';
      -- clku, fix max date
      l_max_date CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');

      l_orig_org_id       NUMBER;
      l_orig_acc_mode     VARCHAR2(1);

      -- cursor to get the usage code of the group identified by p_group_id
      -- Do we need to make sure that the related group is also used by OSC
      CURSOR group_info IS
	 SELECT r.start_date_active, r.end_date_active, r.group_id
	   FROM jtf_rs_group_usages u,
	        jtf_rs_grp_relations r
	   WHERE r.group_relate_id = p_group_relate_id
	     AND u.group_id = r.group_id AND u.usage = 'SALES_COMP';

      -- cursor to get the name of the group identified by p_group_id
      CURSOR group_name IS
	 SELECT name
	   FROM cn_comp_groups
	   WHERE comp_group_id = l_group_id;

      -- cursor to find all periods in the date range for each srp
      CURSOR periods(p_salesrep_id NUMBER, p_start_date DATE, p_end_date DATE) IS
	 SELECT p.period_id,
	        greatest(p_start_date, p.start_date) start_date,
	        Decode(p_end_date, NULL, p.end_date, Least(p_end_date, p.end_date)) end_date
	   FROM cn_srp_intel_periods p
	  WHERE p.salesrep_id = p_salesrep_id
	    AND (p_end_date IS NULL OR p.start_date <= p_end_date)
	    AND (p.end_date >= p_start_date);

       --- get the reps who belong to the group
     CURSOR srp_group_team_csr (p_salesrep_id NUMBER, p_group_id NUMBER, p_start_date DATE, p_end_date DATE)IS
         select distinct ct.name name,
                ct.comp_team_id team_id,
                greatest(p_start_date, cg.start_date_active, ct.start_date_active) start_date,
                Least(nvl(ct.end_date_active, l_max_date), nvl(cg.end_date_active, l_max_date), nvl(p_end_date, l_max_date)) end_date
         from cn_srp_comp_teams_v srt, cn_comp_teams ct, cn_srp_comp_groups_v cg
         where (p_salesrep_id IS NULL or srt.salesrep_id = p_salesrep_id)
           and (p_salesrep_id IS NULL or cg.salesrep_id = p_salesrep_id)
           and cg.comp_group_id = p_group_id
           and srt.comp_team_id = ct.comp_team_id
           and (cg.start_date_active <= ct.start_date_active
             or cg.start_date_active between ct.start_date_active and nvl (ct.end_date_active, cg.start_date_active))
           and nvl(cg.end_date_active, ct.start_date_active) >= ct.start_date_active
           and (cg.end_date_active IS NULL OR p_start_date <= cg.end_date_active)
  	       and (p_end_date IS NULL OR p_end_date >= cg.start_date_active);

     CURSOR get_orgs is
	SELECT org_id FROM cn_repositories_all WHERE status = 'A';
  BEGIN
     p_return_code := fnd_api.g_ret_sts_success;

     IF fnd_profile.value('CN_MARK_EVENTS') <> 'Y' THEN
	RETURN;
     END IF;

     -- store MOAC session info in local variables
     l_orig_org_id   := mo_global.get_current_org_id;
     l_orig_acc_mode := mo_global.get_access_mode;

      -- loop through orgs
     FOR o IN get_orgs LOOP
        mo_global.set_policy_context('S', o.org_id);

	OPEN group_info;
	FETCH group_info INTO l_start_date, l_end_date, l_group_id;
	IF (group_info%notfound) THEN
	   CLOSE group_info;
	ELSE
	   CLOSE group_info;

	   OPEN group_name;
	   FETCH group_name INTO l_group_name;
	   IF (group_name%notfound) THEN
	      CLOSE group_name;
	    ELSE
	      CLOSE group_name;

	      cn_mark_events_pkg.log_event
		( p_event_name      => 'CHANGE_CP_HIER_DELETE',
		  p_object_name     => l_group_name,
		  p_object_id       => l_group_id,
		  p_start_date      => NULL,
		  p_start_date_old  => l_start_date,
		  p_end_date        => NULL,
		  p_end_date_old    => l_end_date,
		  x_event_log_id    => l_event_log_id,
		  p_org_id          => o.org_id);

	      cn_mark_events_pkg.mark_notify_salesreps
		( p_salesrep_id        => NULL,
		  p_comp_group_id      => l_group_id,
		  p_period_id          => null,
		  p_start_date         => l_start_date,
		  p_end_date           => l_end_date,
		  p_revert_to_state    => 'NCALC',
		  p_action             => 'DELETE_ROLL_PULL',
		  p_action_link_id     => NULL,
		  p_base_salesrep_id   => NULL,
		  p_base_comp_group_id => NULL,
		  p_event_log_id       => l_event_log_id,
		  x_action_link_id     => p_action_link_id,
		  p_org_id             => o.org_id);

	      -- check if this rep belongs to a team
	      FOR srp_gp_tm_rec IN srp_group_team_csr (NULL, l_group_id, l_start_date, l_end_date) LOOP

		 if srp_gp_tm_rec.end_date = l_max_date then
		    srp_gp_tm_rec.end_date := null;
		 end if;

		 cn_mark_events_pkg.mark_notify_team
		   (P_TEAM_ID              => srp_gp_tm_rec.team_id ,
		    P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_DEL_REP',
		    P_TEAM_NAME            => srp_gp_tm_rec.name,
		    P_START_DATE_ACTIVE    => srp_gp_tm_rec.start_date,
		    P_END_DATE_ACTIVE      => srp_gp_tm_rec.end_date,
		    P_EVENT_LOG_ID         => l_event_log_id,
		    p_org_id               => o.org_id);
	      END LOOP;

	      -- find the ancestors of the group identified by p_group_id and call mark_notify for all of them
	      -- not that we use l_start_date and l_end_date since this date range is the super range which covers
	      -- the date effectivity of all the salesreps in this group.
	      l_srp.group_id    := l_group_id;
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
		    FOR srp_gp_tm_rec IN srp_group_team_csr (l_srp_tbl(i).salesrep_id, l_srp_tbl(i).group_id, l_srp_tbl(i).start_date, l_srp_tbl(i).end_date) LOOP

		       if srp_gp_tm_rec.end_date = l_max_date then
			  srp_gp_tm_rec.end_date := null;
		       end if;

		       cn_mark_events_pkg.mark_notify_team
			 (P_TEAM_ID              => srp_gp_tm_rec.team_id ,
			  P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_DEL_REP',
			  P_TEAM_NAME            => srp_gp_tm_rec.name,
			  P_START_DATE_ACTIVE    => srp_gp_tm_rec.start_date,
			  P_END_DATE_ACTIVE      => srp_gp_tm_rec.end_date,
			  P_EVENT_LOG_ID         => l_event_log_id,
			  p_org_id               => o.org_id);
		    END LOOP;
		 END LOOP;
	      END IF;
	      l_srp_tbl.DELETE;
	   END IF; -- group_name found
	END IF; -- group_info found
     END LOOP; -- orgs

     -- restore context
     restore_context(l_orig_acc_mode, l_orig_org_id);

  EXCEPTION
     WHEN OTHERS THEN
	p_return_code := fnd_api.g_ret_sts_unexp_error;
	restore_context(l_orig_acc_mode, l_orig_org_id);
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	END IF;
	FND_MSG_PUB.count_and_get
	  (
	   p_count   =>  p_count ,
	   p_data    =>  p_data  ,
	   p_encoded => FND_API.g_false
	   );
  END delete_res_group_relate_pre;

  PROCEDURE  create_res_group_relate_post
  (P_GROUP_RELATE_ID      IN   JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE,
   P_GROUP_ID             IN   JTF_RS_GROUPS_B.GROUP_ID%TYPE,
   P_RELATED_GROUP_ID     IN   JTF_RS_GRP_RELATIONS.RELATED_GROUP_ID%TYPE,
   P_RELATION_TYPE        IN   JTF_RS_GRP_RELATIONS.RELATION_TYPE%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE   DEFAULT  NULL,
   P_DATA                 OUT  NOCOPY VARCHAR2,
   P_COUNT                OUT  NOCOPY NUMBER,
   P_RETURN_CODE          OUT  NOCOPY VARCHAR2
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
      l_dummy             NUMBER;
      l_api_name          VARCHAR2(30) := 'create_res_group_relate_post';
      -- clku fix max date
      l_max_date CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');

      l_orig_org_id       NUMBER;
      l_orig_acc_mode     VARCHAR2(1);

      -- cursor to get the usage code of the group identified by p_group_id.
      -- Do we need to make sure that the related group is also used by OSC ???
      CURSOR usage IS
	 SELECT 1
	   FROM jtf_rs_group_usages
	   WHERE group_id = p_group_id AND usage = 'SALES_COMP';

      -- cursor to get the name of the group identified by p_group_id
      CURSOR group_name IS
	 SELECT name
	   FROM cn_comp_groups
	  WHERE comp_group_id = p_group_id;

      -- cursor to find all periods in the date range for each srp
      CURSOR periods(p_salesrep_id NUMBER, p_start_date DATE, p_end_date DATE) IS
	 SELECT p.period_id,
	        greatest(p_start_date, p.start_date) start_date,
	        Decode(p_end_date, NULL, p.end_date, Least(p_end_date, p.end_date)) end_date
	   FROM cn_srp_intel_periods p
	  WHERE p.salesrep_id = p_salesrep_id
	    AND (p_end_date IS NULL OR p.start_date <= p_end_date)
	    AND (p.end_date >= p_start_date);

      --- get the reps who belong to the group
     CURSOR srp_group_team_csr (p_salesrep_id NUMBER, p_group_id NUMBER, p_start_date DATE, p_end_date DATE)IS
         select distinct ct.name name,
                ct.comp_team_id team_id,
                greatest(p_start_date, cg.start_date_active, ct.start_date_active) start_date,
                least(nvl(ct.end_date_active, l_max_date), nvl(cg.end_date_active, l_max_date), nvl(p_end_date, l_max_date)) end_date
         from cn_srp_comp_teams_v srt, cn_comp_teams ct, cn_srp_comp_groups_v cg
         where srt.salesrep_id = p_salesrep_id
           and cg.salesrep_id = p_salesrep_id
           and cg.comp_group_id = p_group_id
           and srt.comp_team_id = ct.comp_team_id
           and (cg.start_date_active <= ct.start_date_active
             or cg.start_date_active between ct.start_date_active and nvl (ct.end_date_active, cg.start_date_active))
           and nvl(cg.end_date_active, ct.start_date_active) >= ct.start_date_active
           and (cg.end_date_active IS NULL OR p_start_date <= cg.end_date_active)
  	       and (p_end_date IS NULL OR p_end_date >= cg.start_date_active);

     CURSOR get_orgs is
	SELECT org_id FROM cn_repositories_all WHERE status = 'A';
  BEGIN
     p_return_code := fnd_api.g_ret_sts_success;

     IF fnd_profile.value('CN_MARK_EVENTS') <> 'Y' THEN
	RETURN;
     END IF;

     -- store MOAC session info in local variables
     l_orig_org_id   := mo_global.get_current_org_id;
     l_orig_acc_mode := mo_global.get_access_mode;

     -- loop through orgs
     FOR o IN get_orgs LOOP
        mo_global.set_policy_context('S', o.org_id);

	OPEN usage;
	FETCH usage INTO l_dummy;
	IF (usage%notfound) THEN
	   CLOSE usage;
	 ELSE
	   CLOSE usage;

	   OPEN group_name;
	   FETCH group_name INTO l_group_name;
	   IF (group_name%notfound) THEN
	      CLOSE group_name;
	    ELSE
	      CLOSE group_name;

	      cn_mark_events_pkg.log_event
		( p_event_name      => 'CHANGE_CP_HIER_ADD',
		  p_object_name     => l_group_name,
		  p_object_id       => p_group_id,
		  p_start_date      => p_start_date_active,
		  p_start_date_old  => NULL,
		  p_end_date        => p_end_date_active,
		  p_end_date_old    => NULL,
		  x_event_log_id    => l_event_log_id,
		  p_org_id          => o.org_id);

	      cn_mark_events_pkg.mark_notify_salesreps
		( p_salesrep_id        => NULL,
		  p_comp_group_id      => p_group_id,
		  p_period_id          => null,
		  p_start_date         => p_start_date_active,
		  p_end_date           => p_end_date_active,
		  p_revert_to_state    => 'NCALC',
		  p_action             => 'ROLL_PULL',
		  p_action_link_id     => NULL,
		  p_base_salesrep_id   => NULL,
		  p_base_comp_group_id => NULL,
		  p_event_log_id       => l_event_log_id,
		  x_action_link_id     => p_action_link_id,
		  p_org_id             => o.org_id);

	      -- check if this rep belongs to a team
	      FOR srp_gp_tm_rec IN srp_group_team_csr (NULL, p_group_id, p_start_date_active, p_end_date_active) LOOP

		 if srp_gp_tm_rec.end_date = l_max_date then
		    srp_gp_tm_rec.end_date := null;
		 end if;

		 cn_mark_events_pkg.mark_notify_team
		   (P_TEAM_ID              => srp_gp_tm_rec.team_id ,
		    P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_ADD_REP',
		    P_TEAM_NAME            => srp_gp_tm_rec.name,
		    P_START_DATE_ACTIVE    => srp_gp_tm_rec.start_date,
		    P_END_DATE_ACTIVE      => srp_gp_tm_rec.end_date,
		    P_EVENT_LOG_ID         => l_event_log_id,
		    p_org_id               => o.org_id);
	      END LOOP;


	      -- find the ancestors of the group identifed by p_group_id and call mark_notify for all of them
	      -- not that we use l_start_date and l_end_date since this date range is the super range which covers
	      -- the date effectivity of all the salesreps in this group.
	      l_srp.start_date := p_start_date_active;
	      l_srp.end_date := p_end_date_active;
	      l_srp.group_id := p_group_id;

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
		    FOR srp_gp_tm_rec IN srp_group_team_csr (l_srp_tbl(i).salesrep_id, l_srp_tbl(i).group_id, l_srp_tbl(i).start_date, l_srp_tbl(i).end_date) LOOP

		       if srp_gp_tm_rec.end_date = l_max_date then
			  srp_gp_tm_rec.end_date := null;
		       end if;

		       cn_mark_events_pkg.mark_notify_team
			 (P_TEAM_ID              => srp_gp_tm_rec.team_id ,
			  P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_ADD_REP',
			  P_TEAM_NAME            => srp_gp_tm_rec.name,
			  P_START_DATE_ACTIVE    => srp_gp_tm_rec.start_date,
			  P_END_DATE_ACTIVE      => srp_gp_tm_rec.end_date,
			  P_EVENT_LOG_ID         => l_event_log_id,
			  p_org_id               => o.org_id);
		    END LOOP;
		 END LOOP;
	      END IF;
	      l_srp_tbl.DELETE;
	   END IF; -- group_name found
	END IF; -- usage found
     END LOOP; -- orgs

      -- restore context
     restore_context(l_orig_acc_mode, l_orig_org_id);

  EXCEPTION
     WHEN OTHERS THEN
	p_return_code := fnd_api.g_ret_sts_unexp_error;
	restore_context(l_orig_acc_mode, l_orig_org_id);
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	END IF;
	FND_MSG_PUB.count_and_get
	  (
	   p_count   =>  p_count ,
	   p_data    =>  p_data  ,
	   p_encoded => FND_API.g_false
	   );
  END create_res_group_relate_post;


  PROCEDURE  update_res_group_relate_post
  (P_GROUP_RELATE_ID      IN   JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_GRP_RELATIONS.START_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE      IN   JTF_RS_GRP_RELATIONS.END_DATE_ACTIVE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_GRP_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
   P_DATA                 OUT  NOCOPY VARCHAR2,
   P_COUNT                OUT  NOCOPY NUMBER,
   P_RETURN_CODE          OUT  NOCOPY VARCHAR2
   ) IS
      l_start_date        DATE;
      l_end_date          DATE;
      l_action_link_id    NUMBER;
      p_action_link_id    NUMBER;
      l_srp               cn_rollup_pvt.srp_group_rec_type;
      l_srp_tbl           cn_rollup_pvt.srp_group_tbl_type;
      l_return_status     VARCHAR2(30);
      l_msg_count         NUMBER;
      l_msg_data          VARCHAR2(256);
      l_api_name          VARCHAR2(30) := 'update_res_group_relate_post';
      -- clku , fix max date
      l_max_date    CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');
      l_orig_org_id       NUMBER;
      l_orig_acc_mode     VARCHAR2(1);


      -- cursor to find all periods in the date range for each srp
      CURSOR periods(p_salesrep_id NUMBER, p_start_date DATE, p_end_date DATE) IS
	 SELECT p.period_id,
	        greatest(p_start_date, p.start_date) start_date,
	        Decode(p_end_date, NULL, p.end_date, Least(p_end_date, p.end_date)) end_date
	   FROM cn_srp_intel_periods p
	  WHERE p.salesrep_id = p_salesrep_id
	    AND (p_end_date IS NULL OR p.start_date <= p_end_date)
	    AND (p.end_date >= p_start_date);

      --- get the reps who belong to the group
     CURSOR srp_group_team_csr (p_salesrep_id NUMBER, p_group_id NUMBER, p_start_date DATE, p_end_date DATE)IS
         select distinct ct.name name,
                ct.comp_team_id team_id,
                greatest(p_start_date, cg.start_date_active, ct.start_date_active) start_date,
                Least(nvl(ct.end_date_active, l_max_date), nvl(cg.end_date_active, l_max_date), nvl(p_end_date, l_max_date) ) end_date
         from cn_srp_comp_teams_v srt, cn_comp_teams ct, cn_srp_comp_groups_v cg
         where srt.salesrep_id = p_salesrep_id
           and cg.salesrep_id = p_salesrep_id
           and cg.comp_group_id = p_group_id
           and srt.comp_team_id = ct.comp_team_id
           and (cg.start_date_active <= ct.start_date_active
             or cg.start_date_active between ct.start_date_active and nvl (ct.end_date_active, cg.start_date_active))
           and nvl(cg.end_date_active, ct.start_date_active) >= ct.start_date_active
           and (cg.end_date_active IS NULL OR p_start_date <= cg.end_date_active)
  	       and (p_end_date IS NULL OR p_end_date >= cg.start_date_active);

     CURSOR get_orgs IS
	SELECT org_id FROM cn_repositories_all WHERE status = 'A';
  BEGIN
     p_return_code := fnd_api.g_ret_sts_success;

     IF fnd_profile.value('CN_MARK_EVENTS') <> 'Y' THEN
	RETURN;
     END IF;

     IF (g_group_id IS NULL) THEN
	RETURN;
     END IF;

     -- store MOAC session info in local variables
     l_orig_org_id   := mo_global.get_current_org_id;
     l_orig_acc_mode := mo_global.get_access_mode;

     -- loop through orgs
     FOR o IN get_orgs LOOP
        mo_global.set_policy_context('S', o.org_id);

	cn_mark_events_pkg.mark_notify_salesreps
	  ( p_salesrep_id        => NULL,
	    p_comp_group_id      => g_group_id,
	    p_period_id          => null,
	    p_start_date         => p_start_date_active,
	    p_end_date           => p_end_date_active,
	    p_revert_to_state    => 'NCALC',
	    p_action             => 'ROLL_PULL',
	    p_action_link_id     => NULL,
	    p_base_salesrep_id   => NULL,
	    p_base_comp_group_id => NULL,
	    p_event_log_id       => g_event_log_id,
	    x_action_link_id     => p_action_link_id,
	    p_org_id             => o.org_id);

	l_srp.group_id := g_group_id;
	-- insert the period(p_start_date_active, g_start_date_old) which becomes active
	IF (p_start_date_active < g_start_date_old) THEN
	   IF (p_end_date_active IS NOT NULL AND p_end_date_active < g_start_date_old) THEN
	      l_end_date := p_end_date_active;
	    ELSE
	      l_end_date := g_start_date_old - 1;
	   END IF;

	   l_srp.start_date := p_start_date_active;
	   l_srp.end_date := l_end_date;

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
			p_event_log_id       => g_event_log_id,
			x_action_link_id     => l_action_link_id,
			p_org_id             => o.org_id);
		 END LOOP;

		 -- check if this rep belongs to a team
		 FOR srp_gp_tm_rec IN srp_group_team_csr (l_srp_tbl(i).salesrep_id, l_srp_tbl(i).group_id, l_srp_tbl(i).start_date, l_srp_tbl(i).end_date) LOOP

		    if srp_gp_tm_rec.end_date = l_max_date then
		       srp_gp_tm_rec.end_date := null;
		    end if;

		    cn_mark_events_pkg.mark_notify_team
		      (P_TEAM_ID              => srp_gp_tm_rec.team_id ,
		       P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_ADD_REP',
		       P_TEAM_NAME            => srp_gp_tm_rec.name,
		       P_START_DATE_ACTIVE    => srp_gp_tm_rec.start_date,
		       P_END_DATE_ACTIVE      => srp_gp_tm_rec.end_date,
		       P_EVENT_LOG_ID         => g_event_log_id,
		       p_org_id               => o.org_id);
		 END LOOP;
	      END LOOP;
	   END IF;
	   l_srp_tbl.DELETE;
	END IF;

	-- insert the period (l_end_date_old, p_end_date_active) which becomes active.
	IF ((p_end_date_active IS NULL AND g_end_date_old IS NOT NULL) OR p_end_date_active > g_end_date_old) THEN
	   IF (g_end_date_old < p_start_date_active) THEN
	      l_start_date := p_start_date_active;
	    ELSE
	      l_start_date := g_end_date_old + 1;
	   END IF;

	   l_srp.start_date := l_start_date;
	   l_srp.end_date := p_end_date_active;

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
			p_event_log_id       => g_event_log_id,
			x_action_link_id     => l_action_link_id,
			p_org_id             => o.org_id);
		 END LOOP;

		 -- check if this rep belongs to a team
		 FOR srp_gp_tm_rec IN srp_group_team_csr (l_srp_tbl(i).salesrep_id, l_srp_tbl(i).group_id, l_srp_tbl(i).start_date, l_srp_tbl(i).end_date) LOOP

		    if srp_gp_tm_rec.end_date = l_max_date then
		       srp_gp_tm_rec.end_date := null;
		    end if;

		    cn_mark_events_pkg.mark_notify_team
		      (P_TEAM_ID              => srp_gp_tm_rec.team_id ,
		       P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_ADD_REP',
		       P_TEAM_NAME            => srp_gp_tm_rec.name,
		       P_START_DATE_ACTIVE    => srp_gp_tm_rec.start_date,
		       P_END_DATE_ACTIVE      => srp_gp_tm_rec.end_date,
		       P_EVENT_LOG_ID         => g_event_log_id,
		       p_org_id               => o.org_id);
		 END LOOP;
	      END LOOP;
	   END IF;
	   l_srp_tbl.DELETE;
	END IF;
     END LOOP; -- orgs

     -- restore context
     restore_context(l_orig_acc_mode, l_orig_org_id);

  EXCEPTION
     WHEN OTHERS THEN
	p_return_code := fnd_api.g_ret_sts_unexp_error;
	restore_context(l_orig_acc_mode, l_orig_org_id);
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	END IF;
	FND_MSG_PUB.count_and_get
	  (
	   p_count   =>  p_count ,
	   p_data    =>  p_data  ,
	   p_encoded => FND_API.g_false
	   );
  END update_res_group_relate_post;

  PROCEDURE  delete_res_group_relate_post
  (P_GROUP_RELATE_ID      IN   JTF_RS_GRP_RELATIONS.GROUP_RELATE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN   JTF_RS_GROUPS_VL.OBJECT_VERSION_NUMBER%TYPE,
   P_DATA                 OUT  NOCOPY VARCHAR2,
   P_COUNT                OUT  NOCOPY NUMBER,
   P_RETURN_CODE          OUT  NOCOPY VARCHAR2
   ) IS
  BEGIN
     p_return_code := fnd_api.g_ret_sts_success;
  END delete_res_group_relate_post;


  FUNCTION Ok_To_Generate_Msg
  (P_DATA                   OUT  NOCOPY VARCHAR2,
   P_COUNT            OUT  NOCOPY NUMBER,
   P_RETURN_CODE            OUT  NOCOPY VARCHAR2)
    RETURN BOOLEAN IS
  BEGIN
     p_return_code := fnd_api.g_ret_sts_success;
     RETURN false;
  END ok_to_generate_msg;

END jtf_rs_group_relate_vuhk;

/
