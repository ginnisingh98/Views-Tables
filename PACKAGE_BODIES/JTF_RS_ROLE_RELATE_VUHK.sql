--------------------------------------------------------
--  DDL for Package Body JTF_RS_ROLE_RELATE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_ROLE_RELATE_VUHK" AS
-- $Header: cnisrrlb.pls 120.9.12010000.2 2008/10/13 09:56:33 vakulkar ship $

  /***********************************************************************
   This is a user hook  API for the jtf_rs_role_relate_pvt package
  ************************************************************************/

-- declare global variables...
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'jtf_rs_role_relate_vuhk';
G_PAYEE_ROLE                CONSTANT NUMBER       := 54;

-- global variables to pass values from update_res_role_relate_pre to
-- update_res_role_relate_post
-- NOTE: this IS OKAY in the jsp environment since they are only referenced
-- in the pre and post procedures, where they are called one after another
-- with the SAME connection object
g_group_id                  NUMBER;
g_start_date_old            DATE;
g_end_date_old              DATE;
g_manager_flag              VARCHAR2(1);
g_event_log_id              NUMBER;
g_resource_id               NUMBER;

-- clku: TEAM ROLE enhancement
-- Global variable for connecting pre and post update hooks
g_tm_start_date_old         DATE;
g_tm_end_date_old           DATE;
g_team_id                   NUMBER;
g_team_name                 VARCHAR2(30);

-- should we display the debug messages?  comment out this line if not.
PROCEDURE debugmsg (msg VARCHAR2) IS
BEGIN
--   dbms_output.put_line(msg);   -- comment me out before checking in file :-)
   null;
END debugmsg;

-- these procedures copied straight out of cn_srp_roles_pub API

-- ==========================================================================
-- Procedure: srp_plan_assignment_for_insert
--            already in single-org context
-- ==========================================================================
PROCEDURE srp_plan_assignment_for_insert
  (p_role_id        IN cn_roles.role_id%TYPE,
   p_srp_role_id    IN cn_srp_roles.srp_role_id%TYPE,
   x_return_status  OUT NOCOPY VARCHAR2,
   p_loading_status IN  VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2 ) IS

     CURSOR l_cur IS
     SELECT role_plan_id, create_module
       FROM cn_role_plans
      WHERE role_id = p_role_id;

      l_rec l_cur%ROWTYPE;

      l_return_status        VARCHAR2(200);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_plan_assign_id   cn_srp_plan_assigns.srp_plan_assign_id%TYPE;
      l_loading_status       VARCHAR2(2000);

BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   FOR l_rec IN l_cur LOOP
      debugmsg('insert into cn_srp_plan_assigns...');
      debugmsg('p_srp_role_id = ' || p_srp_role_id);
      debugmsg('l_rec.role_plan_id = ' || l_rec.role_plan_id);

      cn_srp_plan_assigns_pvt.create_srp_plan_assigns
	(p_api_version        => 1.0,
	 x_return_status      => l_return_status,
	 x_msg_count          => l_msg_count,
	 x_msg_data           => l_msg_data,
	 p_srp_role_id        => p_srp_role_id,
	 p_role_plan_id       => l_rec.role_plan_id,
	 x_srp_plan_assign_id => l_srp_plan_assign_id,
	 x_loading_status     => l_loading_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 x_return_status     := l_return_status;
	 x_loading_status    := l_loading_status;
	 EXIT;
      END IF;

   END LOOP;
END srp_plan_assignment_for_insert;

-- ==========================================================================
-- Procedure: srp_pmt_plan_asgn_for_insert
--            already in single-org context
-- ==========================================================================
PROCEDURE srp_pmt_plan_asgn_for_insert
  (p_role_id        IN cn_roles.role_id%TYPE,
   p_srp_role_id    IN cn_srp_roles.srp_role_id%TYPE,
   x_return_status  OUT NOCOPY VARCHAR2,
   p_loading_status IN  VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2 ) IS

     CURSOR l_cur IS
     SELECT role_pmt_plan_id
       FROM cn_role_pmt_plans
      WHERE role_id = p_role_id;

      l_rec l_cur%ROWTYPE;

      l_return_status        VARCHAR2(200);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_pmt_plan_id      cn_srp_pmt_plans.srp_pmt_plan_id%TYPE;
      l_loading_status       VARCHAR2(2000);

BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   FOR l_rec IN l_cur LOOP
      debugmsg('insert into cn_srp_pmt_plans...');
      debugmsg('p_srp_role_id = ' || p_srp_role_id);
      debugmsg('l_rec.role_pmt_plan_id = ' || l_rec.role_pmt_plan_id);

      cn_srp_pmt_plans_pvt.create_mass_asgn_srp_pmt_plan
	(p_api_version        => 1.0,
	 x_return_status      => l_return_status,
	 x_msg_count          => l_msg_count,
	 x_msg_data           => l_msg_data,
	 p_srp_role_id        => p_srp_role_id,
	 p_role_pmt_plan_id   => l_rec.role_pmt_plan_id,
	 x_srp_pmt_plan_id    => l_srp_pmt_plan_id,
	 x_loading_status     => l_loading_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 x_return_status     := l_return_status;
         x_loading_status    := l_loading_status;
         EXIT;
      END IF;

   END LOOP;
END srp_pmt_plan_asgn_for_insert;

-- ==========================================================================
-- Procedure: srp_pay_groups_asgn_for_insert
--            already in single-org context
-- ==========================================================================
PROCEDURE srp_pay_groups_asgn_for_insert
  (p_role_id        IN cn_roles.role_id%TYPE,
   p_srp_role_id    IN cn_srp_roles.srp_role_id%TYPE,
   x_return_status  OUT NOCOPY VARCHAR2,
   p_loading_status IN  VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2 ) IS

     CURSOR l_cur IS
     SELECT role_pay_group_id
       FROM cn_role_pay_groups
      WHERE role_id = p_role_id;

      l_rec l_cur%ROWTYPE;

      l_return_status        VARCHAR2(200);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_pay_group_id      cn_srp_pay_groups.srp_pay_group_id%TYPE;
      l_loading_status       VARCHAR2(2000);

BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   FOR l_rec IN l_cur LOOP
      debugmsg('insert into cn_srp_pay_groups...');
      debugmsg('p_srp_role_id = ' || p_srp_role_id);
      debugmsg('l_rec.role_pay_group_id = ' || l_rec.role_pay_group_id);

      -- strange to call PUB here, but there for historical reason
      cn_srp_paygroup_pub.create_mass_asgn_srp_pay
	(p_api_version        => 1.0,
	 x_return_status      => l_return_status,
	 x_msg_count          => l_msg_count,
	 x_msg_data           => l_msg_data,
	 p_srp_role_id        => p_srp_role_id,
	 p_role_pay_group_id  => l_rec.role_pay_group_id,
	 x_srp_pay_group_id   => l_srp_pay_group_id,
	 x_loading_status     => l_loading_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 x_return_status     := l_return_status;
	 x_loading_status    := l_loading_status;
	 EXIT;
      END IF;

   END LOOP;
END srp_pay_groups_asgn_for_insert;

-- ==========================================================================
-- Procedure: ins_srp_intel_prd
--            already in single-org context
-- ==========================================================================
PROCEDURE  ins_srp_intel_prd
  (p_salesrep_id    IN cn_srp_roles.salesrep_id%TYPE,
   p_start_date     IN cn_srp_roles.start_date%TYPE,
   p_end_date       IN cn_srp_roles.end_date%TYPE,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   p_loading_status IN  VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2) IS

      CURSOR l_cur(l_srp_id IN NUMBER,
		   l_s_prd_id IN NUMBER,
		   l_e_prd_id IN NUMBER) IS
     SELECT a1.period_id, a1.start_date, a1.end_date
       FROM cn_period_statuses a1, cn_repositories r
      WHERE (a1.period_id BETWEEN l_s_prd_id AND l_e_prd_id)
        AND a1.period_status in ('O', 'F')
        AND a1.period_set_id = r.period_set_id
        AND a1.period_type_id = r.period_type_id
        AND a1.org_id = r.org_id
        AND NOT exists ( SELECT * FROM cn_srp_intel_periods a2
		    WHERE a2.salesrep_id = l_srp_id AND
			  a2.period_id = a1.period_id AND
			  a2.org_id    = a1.org_id);

      l_rec l_cur%ROWTYPE;
      l_start_period_id      NUMBER;
      l_end_period_id        NUMBER;
      l_api_name             CONSTANT VARCHAR2(30) := 'ins_srp_intel_prd';
      l_org_id               NUMBER;

BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   -- get org id
   l_org_id := mo_global.get_current_org_id;

   -- bug 1942390 hlchen
   --l_start_period_id := cn_api.get_acc_period_id(p_start_date);
   l_start_period_id := cn_api.get_acc_period_id_fo(p_start_date, l_org_id);
   l_end_period_id   := cn_api.get_acc_period_id(p_end_date, l_org_id);

   debugmsg(' p_start_date = ' || p_start_date ||
	    ' p_end_date = ' || p_end_date ||
	    ' l_start_period_id = ' || l_start_period_id ||
	    ' l_end_period_id = ' || l_end_period_id);

   FOR l_rec IN l_cur(p_salesrep_id, l_start_period_id, l_end_period_id)  LOOP
      debugmsg(' salesrep_id = ' || p_salesrep_id ||
	       ' l_rec.period_id = ' || l_rec.period_id);

      cn_intel_calc_pkg.insert_row
	(x_srp_intel_period_id    => '',
	 x_salesrep_id            => p_salesrep_id,
	 x_org_id                 => l_org_id,
	 x_period_id              => l_rec.period_id,
	 x_start_date             => l_rec.start_date,
	 x_end_date               => l_rec.end_date,
	 x_processing_status_code => 'CLEAN',
	 x_process_all_flag       => 'Y',
	 x_attribute_category     => '',
	 x_attribute1             => '',
	 x_attribute2             => '',
	 x_attribute3             => '',
	 x_attribute4             => '',
	 x_attribute5             => '',
	 x_attribute6             => '',
	 x_attribute7             => '',
	 x_attribute8             => '',
	 x_attribute9             => '',
	 x_attribute10            => '',
	 x_attribute11            => '',
	 x_attribute12            => '',
	 x_attribute13            => '',
	 x_attribute14            => '',
	 x_attribute15            => '',
	 x_created_by             => fnd_global.user_id,
	 x_creation_date          => sysdate,
	 x_last_update_login      => fnd_global.login_id,
	 x_last_update_date       => sysdate,
 	 x_last_updated_by        => fnd_global.user_id);
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
        (p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE);
END ins_srp_intel_prd;

-- ==========================================================================
-- Procedure: srp_plan_assignment_for_update
--            already in single-org context
-- ==========================================================================
PROCEDURE srp_plan_assignment_for_update
  (p_role_id          IN  cn_roles.role_id%TYPE,
   p_srp_role_id      IN  cn_srp_roles.srp_role_id%TYPE,
   p_date_update_only IN  VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2,
   p_loading_status   IN  VARCHAR2,
   x_loading_status   OUT NOCOPY VARCHAR2 ) IS


      CURSOR l_cur IS
      SELECT role_plan_id, create_module
        FROM cn_role_plans
       WHERE role_id = p_role_id;

      l_rec l_cur%ROWTYPE;
      l_return_status        VARCHAR2(2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_plan_assign_id   cn_srp_plan_assigns.srp_plan_assign_id%TYPE;
      l_loading_status       VARCHAR2(2000);

BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   IF (p_date_update_only = FND_API.G_TRUE) THEN
      FOR l_rec IN l_cur LOOP
	 debugmsg('update cn_srp_plan_assigns.......');
	 debugmsg('p_srp_role_id = ' || p_srp_role_id);
	 debugmsg('l_rec.role_plan_id = ' || l_rec.role_plan_id);

	 cn_srp_plan_assigns_pvt.update_srp_plan_assigns
	   (p_api_version        => 1.0,
	    x_return_status      => l_return_status,
	    x_msg_count          => l_msg_count,
	    x_msg_data           => l_msg_data,
	    p_srp_role_id        => p_srp_role_id,
	    p_role_plan_id       => l_rec.role_plan_id,
	    x_loading_status     => l_loading_status);

	 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    x_return_status     := l_return_status;
	    x_loading_status    := l_loading_status;
	    EXIT;
	 END IF;
      END LOOP;

    ELSE -- updating whole assignment

      FOR l_rec IN l_cur LOOP
	 cn_srp_plan_assigns_pvt.delete_srp_plan_assigns
	   (p_api_version        => 1.0,
	    x_return_status      => l_return_status,
	    x_msg_count          => l_msg_count,
	    x_msg_data           => l_msg_data,
	    p_srp_role_id        => p_srp_role_id,
	    p_role_plan_id       => l_rec.role_plan_id,
	    x_loading_status     => l_loading_status);

	 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    x_return_status     := l_return_status;
	    x_loading_status    := l_loading_status;
	    EXIT;
	 END IF;

	 cn_srp_plan_assigns_pvt.create_srp_plan_assigns
	   (p_api_version        => 1.0,
	    x_return_status      => l_return_status,
	    x_msg_count          => l_msg_count,
	    x_msg_data           => l_msg_data,
	    p_srp_role_id        => p_srp_role_id,
	    p_role_plan_id       => l_rec.role_plan_id,
	    x_srp_plan_assign_id => l_srp_plan_assign_id,
	    x_loading_status     => l_loading_status);

	 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    x_return_status     := l_return_status;
	    x_loading_status    := l_loading_status;
	    EXIT;
	 END IF;

      END LOOP;
   END IF;

END srp_plan_assignment_for_update;

-- ==========================================================================
-- Procedure: srp_pmt_plan_asgn_for_update
--            already in single-org context
-- ==========================================================================
PROCEDURE srp_pmt_plan_asgn_for_update
  (p_role_id          IN  cn_roles.role_id%TYPE,
   p_srp_role_id      IN  cn_srp_roles.srp_role_id%TYPE,
   p_date_update_only IN  VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2,
   p_loading_status   IN  VARCHAR2,
   x_loading_status   OUT NOCOPY VARCHAR2 ) IS


      CURSOR l_cur IS
      SELECT role_pmt_plan_id
        FROM cn_role_pmt_plans
       WHERE role_id = p_role_id;

      l_rec l_cur%ROWTYPE;
      l_return_status        VARCHAR2(2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_pmt_plan_id      cn_srp_pmt_plans.srp_pmt_plan_id%TYPE;
      l_loading_status       VARCHAR2(2000);
      created_in_osc         BOOLEAN;

BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   FOR l_rec IN l_cur LOOP

      debugmsg('update cn_srp_pmt_plans.......');
      debugmsg('p_srp_role_id = ' || p_srp_role_id);
      debugmsg('l_rec.role_pmt_plan_id = ' || l_rec.role_pmt_plan_id);

      cn_srp_pmt_plans_pvt.update_mass_asgn_srp_pmt_plan
        (p_api_version        => 1.0,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data           => l_msg_data,
         p_srp_role_id        => p_srp_role_id,
         p_role_pmt_plan_id   => l_rec.role_pmt_plan_id,
         x_loading_status     => l_loading_status);

      debugmsg('l_return_status = ' || l_return_status);
      debugmsg('l_msg_data = ' || l_msg_data);
      debugmsg('l_msg_count = ' || l_msg_count);
      debugmsg('l_loading_status = ' || l_loading_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status     := l_return_status;
         x_loading_status    := l_loading_status;
         EXIT;
      END IF;
    END LOOP;

END srp_pmt_plan_asgn_for_update;

-- ==========================================================================
-- Procedure: srp_pay_group_asgn_for_update
--            already in single-org context
-- ==========================================================================
PROCEDURE srp_pay_group_asgn_for_update
  (p_role_id          IN  cn_roles.role_id%TYPE,
   p_srp_role_id      IN  cn_srp_roles.srp_role_id%TYPE,
   p_date_update_only IN  VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2,
   p_loading_status   IN  VARCHAR2,
   x_loading_status   OUT NOCOPY VARCHAR2 ) IS


      CURSOR l_cur IS
      SELECT role_pay_group_id
        FROM cn_role_pay_groups
       WHERE role_id = p_role_id;

      l_rec l_cur%ROWTYPE;
      l_return_status        VARCHAR2(2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_pay_group_id     cn_srp_pay_groups.srp_pay_group_id%TYPE;
      l_loading_status       VARCHAR2(2000);

BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   FOR l_rec IN l_cur LOOP

      debugmsg('update cn_srp_pay_groups.......');
      debugmsg('p_srp_role_id = ' || p_srp_role_id);
      debugmsg('l_rec.role_pay_group_id = ' || l_rec.role_pay_group_id);

      -- strange to call PUB here, but there for historical reason
      cn_srp_paygroup_pub.update_mass_asgn_srp_pay
	(p_api_version        => 1.0,
	 x_return_status      => l_return_status,
	 x_msg_count          => l_msg_count,
	 x_msg_data           => l_msg_data,
	 p_srp_role_id        => p_srp_role_id,
	 p_role_pay_group_id  => l_rec.role_pay_group_id,
	 x_srp_pay_group_id   => l_srp_pay_group_id,
	 x_loading_status     => l_loading_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status     := l_return_status;
         x_loading_status    := l_loading_status;
         EXIT;
      END IF;
   END LOOP;

END srp_pay_group_asgn_for_update;

-- ==========================================================================
-- Procedure: srp_plan_assignment_for_delete
--            already in single-org context
-- ==========================================================================
PROCEDURE srp_plan_assignment_for_delete
  (p_role_id        IN cn_roles.role_id%TYPE,
   p_srp_role_id    IN cn_srp_roles.srp_role_id%TYPE,
   x_return_status  OUT NOCOPY VARCHAR2,
   p_loading_status IN  VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2 ) IS

   CURSOR l_cur IS
   SELECT role_plan_id
     FROM cn_role_plans
    WHERE role_id = p_role_id;

   l_rec l_cur%ROWTYPE;
   l_return_status        VARCHAR2(2000);
   l_msg_count            NUMBER;
   l_msg_data             VARCHAR2(2000);
   l_srp_plan_assign_id   cn_srp_plan_assigns.srp_plan_assign_id%TYPE;
   l_loading_status       VARCHAR2(2000);

BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   FOR l_rec IN l_cur LOOP
      cn_srp_plan_assigns_pvt.delete_srp_plan_assigns
	(p_api_version        => 1.0,
	 p_init_msg_list      => fnd_api.g_false,
	 p_commit             => fnd_api.g_false,
	 p_validation_level   => fnd_api.g_valid_level_full,
	 x_return_status      => l_return_status,
	 x_msg_count          => l_msg_count,
	 x_msg_data           => l_msg_data,
	 p_srp_role_id        => p_srp_role_id,
	 p_role_plan_id       => l_rec.role_plan_id,
	 x_loading_status     => l_loading_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 x_return_status     := l_return_status;
	 x_loading_status    := l_loading_status;
	 EXIT;
      END IF;
   END LOOP;
END srp_plan_assignment_for_delete;

-- ==========================================================================
-- Procedure: srp_pmt_plan_asgn_for_delete
--            already in single-org context
-- ==========================================================================
PROCEDURE srp_pmt_plan_asgn_for_delete
  (p_role_id        IN cn_roles.role_id%TYPE,
   p_srp_role_id    IN cn_srp_roles.srp_role_id%TYPE,
   x_return_status  OUT NOCOPY VARCHAR2,
   p_loading_status IN  VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2 ) IS

   CURSOR l_cur IS
   SELECT role_pmt_plan_id
     FROM cn_role_pmt_plans
    WHERE role_id = p_role_id;

   l_rec l_cur%ROWTYPE;
   l_return_status        VARCHAR2(2000);
   l_msg_count            NUMBER;
   l_msg_data             VARCHAR2(2000);
   l_srp_pmt_plan_id      cn_srp_pmt_plans.srp_pmt_plan_id%TYPE;
   l_loading_status       VARCHAR2(2000);

BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   FOR l_rec IN l_cur LOOP
      cn_srp_pmt_plans_pvt.delete_mass_asgn_srp_pmt_plan
	(p_api_version        => 1.0,
	 p_init_msg_list      => fnd_api.g_false,
	 p_commit             => fnd_api.g_false,
	 p_validation_level   => fnd_api.g_valid_level_full,
	 x_return_status      => l_return_status,
	 x_msg_count          => l_msg_count,
	 x_msg_data           => l_msg_data,
	 p_srp_role_id        => p_srp_role_id,
	 p_role_pmt_plan_id   => l_rec.role_pmt_plan_id,
	 x_loading_status     => l_loading_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 x_return_status     := l_return_status;
	 x_loading_status    := l_loading_status;
	 EXIT;
      END IF;
   END LOOP;
END srp_pmt_plan_asgn_for_delete;

-- ==========================================================================
-- Procedure: val_srp_pg_asgn_for_del
--            Validate if resource has worksheet
-- ==========================================================================
procedure val_srp_pg_asgn_for_del
(p_srp_role_id NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2
) IS
l_null_date           CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');
l_count                number;

l_srp_start_period_id NUMBER;
l_pay_run_period_id NUMBER;

l_salesrep_id NUMBER;
l_max_pay_date DATE;
l_count_pay NUMBER;

cursor get_srp_roles IS
  SELECT srp_role_id, org_id, start_date, salesrep_id
    FROM cn_srp_roles
    WHERE srp_role_id = p_srp_role_id;

BEGIN
   FOR srp_role IN get_srp_roles LOOP
     SELECT count(*)
       INTO l_count
       FROM cn_srp_roles srp, cn_srp_plan_assigns plan
       WHERE srp.srp_role_id = srp_role.srp_role_id
       AND srp.org_id = srp_role.org_id
       AND srp.org_id = plan.org_id
       AND srp.salesrep_id = plan.salesrep_id
       AND ( srp.start_date > plan.end_date OR nvl(srp.end_date, l_null_date) < plan.start_date);

     IF l_count = 0 THEN
        -- There is comp plan for the resource. Need to check if there is a worksheet. If there is a worksheet
        -- then throw exception
	l_srp_start_period_id := cn_api.get_acc_period_id(srp_role.start_date, srp_role.org_id);
	l_salesrep_id := srp_role.salesrep_id;



          -- get count of worksheets
        SELECT count(*) into l_count_pay
	  FROM cn_payment_worksheets W, cn_period_statuses prd, cn_payruns prun
	  WHERE w.salesrep_id = l_salesrep_id
	  AND w.org_id = srp_role.org_id
	  AND w.org_id = prd.org_id
	  AND prd.org_id = prun.org_id
          AND   prun.pay_period_id = prd.period_id
          AND   prun.payrun_id     = w.payrun_id;

        IF l_count_pay > 0 THEN
          select max(pay_date) into l_max_pay_date
	    from cn_payment_worksheets W, cn_payruns prun
	   WHERE w.salesrep_id = l_salesrep_id
	    AND   prun.payrun_id     = w.payrun_id
	    AND prun.org_id = w.org_id
	    AND w.org_id = srp_role.org_id;

            -- get the period's end date of max(pay_date) payruns
	  SELECT cn_api.get_acc_period_id(prd.end_date, srp_role.org_id)
	    into l_pay_run_period_id
              FROM cn_payment_worksheets W, cn_period_statuses prd, cn_payruns prun
	      WHERE w.salesrep_id = l_salesrep_id
	      AND w.org_id = srp_role.org_id
	      AND w.org_id = prun.org_id
	      AND prun.org_id = prd.org_id
              AND   prun.pay_period_id = prd.period_id
              AND   prun.payrun_id     = w.payrun_id
	      AND   prun.pay_date = l_max_pay_date
	      AND   ROWNUM = 1; -- this check is for offcycle payruns created with the same pay dates.

	    IF l_srp_start_period_id <= l_pay_run_period_id THEN
  -- Modified by chanthon for bug 5525795 - User friendly error message requested
  -- before throwing the vertical hook error.
          x_return_status := FND_API.G_RET_STS_ERROR;
--	      RAISE FND_API.G_EXC_ERROR;
	    END IF;
         END IF; -- l_count_pay check
     END IF; -- l_count check
   END LOOP;

END; --VALIDATE_SRP_PAY_GROUP_ASGN_FOR_DEL

-- ==========================================================================
-- Procedure: srp_pay_group_asgn_for_delete
--            already in single-org context
-- ==========================================================================
PROCEDURE srp_pay_group_asgn_for_delete
  (p_role_id        IN cn_roles.role_id%TYPE,
   p_srp_role_id    IN cn_srp_roles.srp_role_id%TYPE,
   x_return_status  OUT NOCOPY VARCHAR2,
   p_loading_status IN  VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2 ) IS

   CURSOR l_cur IS
   SELECT role_pay_group_id
     FROM cn_role_pay_groups
    WHERE role_id = p_role_id;

   l_rec l_cur%ROWTYPE;
   l_return_status        VARCHAR2(2000);
   l_msg_count            NUMBER;
   l_msg_data             VARCHAR2(2000);
   l_srp_pmt_plan_id      cn_srp_pmt_plans.srp_pmt_plan_id%TYPE;
   l_loading_status       VARCHAR2(2000);

BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;
-- Removing this validation for bug 5557049
/*   --Prevent delete if wrksheet exist - vensrini
   val_srp_pg_asgn_for_del(p_srp_role_id        => p_srp_role_id,
   	 x_return_status      => x_return_status);
   --Prevent delete if wrksheet exist - vensrini

  -- Added by chanthon for bug 5525795 - User friendly error message requested
  -- before throwing the vertical hook error.
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
    THEN
       fnd_message.set_name ('CN', 'CN_SRP_PG_WS');
       FND_MSG_PUB.add;
    END IF;
    x_loading_status := 'CN_SRP_PG_WS';
  ElSE */
  -- End: Added by chanthon --
-- End: Removed this validation for bug 5557049
   FOR l_rec IN l_cur LOOP
      cn_srp_paygroup_pvt.delete_mass_asgn_srp_pay
	(p_api_version        => 1.0,
	 p_init_msg_list      => fnd_api.g_false,
	 p_commit             => fnd_api.g_false,
	 p_validation_level   => fnd_api.g_valid_level_full,
	 x_return_status      => l_return_status,
	 x_msg_count          => l_msg_count,
	 x_msg_data           => l_msg_data,
	 p_srp_role_id        => p_srp_role_id,
	 p_role_pay_group_id  => l_rec.role_pay_group_id,
	 x_loading_status     => l_loading_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 x_return_status     := l_return_status;
	 x_loading_status    := l_loading_status;
	 EXIT;
      END IF;
   END LOOP;
--   END IF;
END srp_pay_group_asgn_for_delete;

-- ==========================================================================
-- Procedure: mark_notify
--            already in single-org context
-- ==========================================================================
PROCEDURE mark_notify
  (p_salesrep_id          NUMBER,
   p_role_id              NUMBER DEFAULT NULL,
   p_group_id             NUMBER,
   p_operation            VARCHAR2,
   p_start_date           DATE,
   p_end_date             DATE,
   p_manager_flag         VARCHAR2,
   p_event_log_id         NUMBER)
  IS
     l_srp                cn_rollup_pvt.srp_group_rec_type;
     l_srp_tbl            cn_rollup_pvt.srp_group_tbl_type;
     l_return_status      VARCHAR2(30);
     l_msg_count          NUMBER;
     l_msg_data           VARCHAR2(256);
     p_action_link_id     NUMBER;
     l_action_link_id     NUMBER;
     l_revert_to_state    VARCHAR2(30);
     l_action             VARCHAR2(30);
     l_start_date         DATE;
     l_end_date           DATE;
     l_org_id             NUMBER;

     -- cursor to find all periods in the date range for each srp
     -- Assume: 1. p_start_date is not null
     --         2. p.start_date and p.end_date are not null
     -- cursor to find all periods in the date range for each srp
    CURSOR periods(p_salesrep_id NUMBER, p_start_date DATE, p_end_date DATE) IS
    SELECT p.period_id,
     greatest(p_start_date, p.start_date) start_date,
     Decode(p_end_date, NULL, p.end_date,
      Least(p_end_date, p.end_date)) end_date
      FROM cn_srp_intel_periods p
     WHERE p.salesrep_id = p_salesrep_id
       AND p.org_id      = l_org_id
       AND (p_end_date IS NULL OR p.start_date <= p_end_date)
       AND (p.end_date >= p_start_date);

BEGIN
   -- get org id
   l_org_id := mo_global.get_current_org_id;

   IF (p_operation = 'I') THEN
      l_revert_to_state := 'NCALC';
      l_action := 'XROLL';
    ELSIF (p_operation = 'D') THEN
      l_revert_to_state := 'NCALC';
      l_action := 'SOURCE_CLS';
   END IF;

   cn_mark_events_pkg.mark_notify_salesreps
     (p_salesrep_id        => p_salesrep_id,
      p_org_id             => l_org_id,
      p_comp_group_id      => p_group_id,
      p_period_id          => null,
      p_start_date         => p_start_date,
      p_end_date           => p_end_date,
      p_revert_to_state    => l_revert_to_state,
      p_action             => l_action,
      p_action_link_id     => NULL,
      p_base_salesrep_id   => NULL,
      p_base_comp_group_id => NULL,
      p_event_log_id       => p_event_log_id,
      x_action_link_id     => p_action_link_id);

   IF (p_operation = 'I') THEN
      IF (p_manager_flag = 'N') THEN
	 l_revert_to_state := 'ROLL';
	 l_action          := 'PULL_BELOW';
       ELSE
	 l_revert_to_state := 'ROLL';
	 l_action := 'PULL';
      END IF;
    ELSE
      l_revert_to_state := 'CALC';
      l_action := 'DELETE_DEST';
   END IF;

   -- for each period active for this salesrep, call mark_notify_salesrep
   FOR prd IN periods(p_salesrep_id, p_start_date, p_end_date) LOOP
      cn_mark_events_pkg.mark_notify_salesreps
	(p_salesrep_id        => p_salesrep_id,
	 p_org_id             => l_org_id,
	 p_comp_group_id      => p_group_id,
	 p_period_id          => prd.period_id,
	 p_start_date         => prd.start_date,
	 p_end_date           => prd.end_date,
	 p_revert_to_state    => l_revert_to_state,
	 p_action             => l_action,
	 p_action_link_id     => p_action_link_id,
	 p_base_salesrep_id   => NULL,
	 p_base_comp_group_id => NULL,
	 p_role_id            => p_role_id,
	 p_event_log_id       => p_event_log_id,
	 x_action_link_id     => l_action_link_id);
   END LOOP;

   -- find the ancestors of l_salesrep and call mark_notify for all of them.
   l_srp.salesrep_id := p_salesrep_id;
   l_srp.group_id    := p_group_id;
   l_srp.start_date  := p_start_date;
   l_srp.end_date    := p_end_date;

   cn_rollup_pvt.get_ancestor_salesrep
     (p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_false,
      p_commit              => FND_API.G_false,
      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      p_srp                 => l_srp,
      p_org_id              => l_org_id,
      x_srp                 => l_srp_tbl);

   IF (l_srp_tbl.COUNT > 0) THEN
      FOR i IN l_srp_tbl.first..l_srp_tbl.last LOOP
	 FOR prd IN periods(l_srp_tbl(i).salesrep_id,
			    l_srp_tbl(i).start_date,
			    l_srp_tbl(i).end_date) LOOP
      cn_mark_events_pkg.mark_notify_salesreps
        (p_salesrep_id        => l_srp_tbl(i).salesrep_id,
	 p_org_id             => l_org_id,
         p_comp_group_id      => l_srp_tbl(i).group_id,
         p_period_id          => prd.period_id,
         p_start_date         => prd.start_date,
         p_end_date           => prd.end_date,
         p_revert_to_state    => 'CALC',
         p_action             => NULL,
         p_action_link_id     => p_action_link_id,
         p_base_salesrep_id   => NULL,
         p_base_comp_group_id => NULL,
         p_event_log_id       => p_event_log_id,
         x_action_link_id     => l_action_link_id);
          END LOOP;
      END LOOP;
   END IF;

   l_srp_tbl.DELETE;
END mark_notify;

-- helper procedure for the MOAC session context
PROCEDURE restore_context(p_acc_mode VARCHAR2,
			  p_org_id   NUMBER) IS
BEGIN
   IF p_acc_mode IS NOT NULL then
      mo_global.set_policy_context(p_acc_mode, p_org_id);
   END IF;
END restore_context;

-- ====================================================================
-- Here are the actual user hook procedures.  They include           ==
--     create, insert, and update for resourece roles                ==
-- We call the "post" hooks on insert and update since these are     ==
--     executed after the DML operations to resource roles, but we   ==
--     call the "pre" hook on the delete                             ==
-- ====================================================================


/*for create resource role relate */

PROCEDURE create_res_role_relate_post
  (P_ROLE_RELATE_ID       IN   JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
   P_ROLE_RESOURCE_TYPE   IN   JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_TYPE%TYPE,
   P_ROLE_RESOURCE_ID     IN   JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE,
   P_ROLE_ID              IN   JTF_RS_ROLE_RELATIONS.ROLE_ID%TYPE,
   P_START_DATE_ACTIVE    IN   JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE      IN   JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE
                               DEFAULT  NULL,
   P_DATA                 OUT  NOCOPY VARCHAR2,
   P_COUNT                OUT  NOCOPY   NUMBER,
   P_RETURN_CODE          OUT  NOCOPY VARCHAR2) IS

  l_srp_plan_assign_id      cn_srp_plan_assigns.srp_plan_assign_id%TYPE;
  x_loading_status          VARCHAR2(30);
  l_salesrep_id             NUMBER;
  l_org_id                  NUMBER;
  l_orig_acc_mode           VARCHAR2(1);
  l_orig_org_id             NUMBER;
  l_usage                   VARCHAR2(30);
  l_start_date              DATE;
  l_end_date                DATE;
  l_count                   NUMBER;
  l_api_name                VARCHAR2(30) := 'create_res_role_relate_post';

  -- get the salesrep ID's, org ID's
  CURSOR get_srp_org_info IS
     select salesrep_id, org_id
       from jtf_rs_salesreps
      where resource_id = p_role_resource_id
        AND p_role_resource_type = 'RS_INDIVIDUAL'
       UNION ALL
     select salesrep_id, org_id
       from jtf_rs_group_members gm, jtf_rs_salesreps s
      where gm.group_member_id = p_role_resource_id
        and gm.resource_id = s.resource_id
        and delete_flag = 'N'
        AND p_role_resource_type = 'RS_GROUP_MEMBER'
       UNION ALL
     select salesrep_id, org_id
       from jtf_rs_team_members tm, jtf_rs_salesreps s
      where tm.team_member_id = p_role_resource_id
        and tm.team_resource_id = s.resource_id
        and resource_type = 'INDIVIDUAL'
        and delete_flag = 'N'
        AND p_role_resource_type = 'RS_TEAM_MEMBER';

  -- the check for valid insert and the actual insert row to role relations
  -- is done by the public API... this hook calls the srp_plan assignment,
  -- linking salesreps to comp plans, and it inserts into
  -- cn_srp_intel_periods for intelligent calculation.

  -- for mark events
  l_manager_flag     VARCHAR2(1);
  l_group_id         NUMBER;
  l_event_log_id     NUMBER;
  l_event_name       VARCHAR2(30);

  l_max_date CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');

  --clku, team member rs role mark event

  l_tm_start_date_old DATE;
  l_tm_end_date_old DATE;
  l_team_id NUMBER;
  l_team_name VARCHAR2(30);
  l_team_event_name VARCHAR(60);
  l_role_id NUMBER;
  l_date_range_action_tbl   cn_api.date_range_action_tbl_type;
  l_role_resource_type jtf_rs_role_relations.role_resource_type%TYPE;

  -- clku, bug 3718575
  l_resource_category VARCHAR2(30);

  -- run in single-org context
   CURSOR team_member_role_relate IS
   SELECT t.start_date_active, t.end_date_active, rr.role_id,
          sr.salesrep_id, tm.team_id, t.team_name
   from   jtf_rs_team_members tm,
          jtf_rs_salesreps sr,
          jtf_rs_team_usages tu,
          jtf_rs_role_relations rr,
          jtf_rs_roles_b rb,
          jtf_rs_teams_vl t
   where rr.role_relate_id = p_role_relate_id
   and rr.role_resource_type(+) = 'RS_TEAM_MEMBER'
   and tm.resource_type = 'INDIVIDUAL'
   and tm.delete_flag = 'N'
   and tu.team_id = tm.team_id
   and tu.usage = 'SALES_COMP'
   and sr.resource_id = tm.team_resource_id
   and (sr.org_id is null or sr.org_id = (select org_id from cn_repositories))
   and rr.role_resource_id(+) = tm.team_member_id
   and rr.delete_flag(+) = 'N'
   and rb.role_id(+) = rr.role_id
   and rb.role_type_code(+) = 'SALES_COMP'
   and t.team_id = tm.team_id;

  -- cursor to get the information about this role relation (single-org)
  CURSOR role_relate_info IS
  SELECT r.manager_flag, r.group_id, s.salesrep_id
    FROM jtf_rs_group_usages u,
         jtf_rs_group_mbr_role_vl r,
         cn_rs_salesreps s,
         jtf_rs_roles_b ro
   WHERE r.role_relate_id = p_role_relate_id
     AND u.group_id = r.group_id
     AND u.usage = 'SALES_COMP'
     AND ro.role_id = r.role_id
     AND ro.role_type_code = 'SALES_COMP'
     AND s.resource_id = r.resource_id;

  -- get the team info associated with the reps who are in turn
  -- associated with the role (single-org)
  CURSOR srp_team_relate_info (p_salesrep_id    NUMBER,
			       p_role_relate_id NUMBER) IS
  SELECT ct.name name,
         ct.comp_team_id team_id,
         greatest(r.start_date_active, ct.start_date_active) start_date,
         least(nvl(ct.end_date_active, l_max_date),
	       nvl(r.end_date_active,  l_max_date)) end_date
    FROM jtf_rs_group_usages u,
         jtf_rs_group_mbr_role_vl r,
         cn_rs_salesreps s,  -- single-org view
         jtf_rs_roles_b ro,
         cn_srp_comp_teams_v srt,
         cn_comp_teams ct
   WHERE r.role_relate_id = p_role_relate_id
     AND s.salesrep_id    = p_salesrep_id  -- safe since single-org context
     AND u.group_id = r.group_id
     AND u.usage = 'SALES_COMP'
     AND ro.role_id = r.role_id
     AND ro.role_type_code = 'SALES_COMP'
     AND s.resource_id = r.resource_id
     AND s.salesrep_id = srt.salesrep_id
     AND srt.comp_team_id = ct.comp_team_id
     AND (r.start_date_active <= ct.start_date_active
	  or r.start_date_active between ct.start_date_active
	  and nvl (ct.end_date_active, r.start_date_active))
     AND nvl(r.end_date_active, ct.start_date_active) >= ct.start_date_active;

    -- clku, bug 3718575 get the resource category information
     CURSOR resource_category_info IS
     SELECT category
     FROM jtf_rs_resource_extns
     where resource_id = P_ROLE_RESOURCE_ID;

BEGIN
   --  Initialize API return status to success
   p_return_code := fnd_api.g_ret_sts_success;

   -- get usage for the role  (can't fail)
   select role_type_code into l_usage
     from jtf_rs_roles_b
    where role_id = P_ROLE_ID;

   -- only proceed if usage is SALES_COMP or SALES_COMP_PAYMENT_ANALIST
   IF l_usage <> 'SALES_COMP' AND l_usage <> 'SALES_COMP_PAYMENT_ANALIST' THEN
      RETURN;
   END IF;

   -- see if salesrep tied to resource
   l_salesrep_id := NULL;
   l_org_id      := NULL;
   OPEN  get_srp_org_info;
   FETCH get_srp_org_info INTO l_salesrep_id, l_org_id;
   CLOSE get_srp_org_info;

   -- if trying to assign a SALES_COMP role to a non-salesrep, then error
   IF l_salesrep_id IS NULL AND p_role_resource_type = 'RS_INDIVIDUAL' AND
      l_usage = 'SALES_COMP' THEN
      FND_MESSAGE.SET_NAME('CN', 'CN_RES_MUST_BE_SRP');
      -- A sales compensation role cannot be assigned to a resource
      -- that is not a salesperson.
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   IF p_role_resource_type = 'RS_INDIVIDUAL' THEN
      -- looks like spelling error but this is correct...
      IF l_usage = 'SALES_COMP_PAYMENT_ANALIST' THEN
	  select count(1) into l_count
	    from jtf_rs_role_relations rr, jtf_rs_roles_b r
	   where rr.role_resource_id = P_ROLE_RESOURCE_ID
	     and rr.role_resource_type = 'RS_INDIVIDUAL'
	     and rr.delete_flag = 'N'
	     and r.role_id = rr.role_id
	     and r.role_type_code = 'SALES_COMP'
	     -- Bug 4083951 by mnativ
	     -- AND NVL(e1,s2) >= s2 AND s1 <= NVL(e2,s1)
	     -- s1,e1 = IN params, s2,e2 = existing role assignment
	     AND NVL(TRUNC(P_END_DATE_ACTIVE),TRUNC(rr.start_date_active))
            >= TRUNC(rr.start_date_active)
	     AND TRUNC(P_START_DATE_ACTIVE)
            <= NVL(TRUNC(rr.end_date_active),TRUNC(P_START_DATE_ACTIVE));

	  if l_count <> 0 then
	     FND_MESSAGE.SET_NAME('CN', 'CN_SRP_CANNOT_HAVE_ANAL_ROLE');
	     -- A salesperson cannot be assigned a payment analyst role.
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
	  end if;
      end if; -- l_usage = 'SALES_COMP_PAYMENT_ANALIST'

     IF l_usage = 'SALES_COMP' THEN
	  select count(1) into l_count
	    from jtf_rs_role_relations rr, jtf_rs_roles_b r
	   where rr.role_resource_id = P_ROLE_RESOURCE_ID
	     and rr.role_resource_type = 'RS_INDIVIDUAL'
	     and rr.delete_flag = 'N'
	     and r.role_id = rr.role_id
	     and r.role_type_code = 'SALES_COMP_PAYMENT_ANALIST'
	     -- Bug 4083951 by mnativ
	     -- AND NVL(e1,s2) >= s2 AND s1 <= NVL(e2,s1)
	     -- s1,e1 = IN params, s2,e2 = existing role assignment
	     AND NVL(TRUNC(P_END_DATE_ACTIVE),TRUNC(rr.start_date_active))
            >= TRUNC(rr.start_date_active)
	     AND TRUNC(P_START_DATE_ACTIVE)
            <= NVL(TRUNC(rr.end_date_active),TRUNC(P_START_DATE_ACTIVE));

	  if l_count <> 0 then
	     FND_MESSAGE.SET_NAME('CN', 'CN_SRP_CANNOT_HAVE_ANAL_ROLE');
	     -- A salesperson cannot be assigned a payment analyst role.
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
	  end if;

	  -- check PAYEE role
	  IF p_role_id = G_PAYEE_ROLE then
	     -- payee cannot have any other sales comp role
	     select count(1) into l_count
	       from jtf_rs_role_relations rr, jtf_rs_roles_b r
	      where rr.role_resource_id = P_ROLE_RESOURCE_ID
	        and rr.role_resource_type = 'RS_INDIVIDUAL'
	        and rr.delete_flag = 'N'
	        and r.role_id = rr.role_id
	        and r.role_id <> G_PAYEE_ROLE
	        and r.role_type_code = 'SALES_COMP';

	     if l_count <> 0 then
		FND_MESSAGE.SET_NAME('CN', 'CN_PAYEE_CANNOT_HAVE_SC_ROLE');
		-- A salesperson cannot be assigned both the Payee role
		-- and another sales compensation role.
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	     end if;
	   ELSE -- p_role_id <> G_PAYEE_ROLE
	     -- NON-payee cannot have payee role
	     select count(1) into l_count
	       from jtf_rs_role_relations rr
	      where rr.role_resource_id = P_ROLE_RESOURCE_ID
	        and rr.role_resource_type = 'RS_INDIVIDUAL'
	        and rr.delete_flag = 'N'
	        and rr.role_id = G_PAYEE_ROLE;

	     if l_count <> 0 then
		FND_MESSAGE.SET_NAME('CN', 'CN_PAYEE_CANNOT_HAVE_SC_ROLE');
		-- A salesperson cannot be assigned both the Payee role
		-- and another sales compensation role.
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	     end if; -- l_count <> 0
	  end if; -- payee role ck
     end if; -- l_usage = 'SALES_COMP' ok
   END IF; -- if salesrep_id is not null

   -- done with validation - now process data
   -- store MOAC session info in local variables
   l_orig_org_id   := mo_global.get_current_org_id;
   l_orig_acc_mode := mo_global.get_access_mode;

   -- loop through orgs
   FOR r IN get_srp_org_info LOOP
      mo_global.set_policy_context('S', r.org_id);

      -- do mark event processing
      -- only return rows for SALES_COMP roles of RS_GROUP_MEMBER type
      IF fnd_profile.value('CN_MARK_EVENTS') = 'Y' THEN
	 -- Team Member Role section
	 IF P_ROLE_RESOURCE_TYPE = 'RS_TEAM_MEMBER' THEN
	    OPEN  team_member_role_relate;
	    FETCH team_member_role_relate INTO
	      l_tm_start_date_old, l_tm_end_date_old, l_role_id,
	      l_salesrep_id, l_team_id, l_team_name;
	    IF (team_member_role_relate%notfound) THEN
	       CLOSE team_member_role_relate;
	     ELSE
	       CLOSE team_member_role_relate;

	       cn_api.get_date_range_diff_action
		 (  start_date_new    => P_START_DATE_ACTIVE
		    ,end_date_new     => P_END_DATE_ACTIVE
		    ,start_date_old   => l_tm_start_date_old
		    ,end_date_old     => l_tm_end_date_old
		    ,x_date_range_action_tbl => l_date_range_action_tbl  );

	       FOR i IN 1..l_date_range_action_tbl.COUNT LOOP

		  if l_date_range_action_tbl(i).action_flag = 'I' THEN

		     l_team_event_name := 'CHANGE_TEAM_ADD_REP';
		   else
		     l_team_event_name := 'CHANGE_TEAM_DEL_REP';
		  end if;

	      cn_mark_events_pkg.mark_notify_team
		(P_TEAM_ID              => l_team_id,
		 P_TEAM_EVENT_NAME      => l_team_event_name,
		 P_TEAM_NAME            => l_team_name,
		 P_START_DATE_ACTIVE    => l_date_range_action_tbl(i).start_date,
		 P_END_DATE_ACTIVE      => l_date_range_action_tbl(i).end_date,
		 P_EVENT_LOG_ID         => NULL,
		 p_org_id               => r.org_id);

	       END LOOP;
	    END IF;
	 END IF; -- RS_TEAM_MEMBER
	 -- end Team Member Role section

	 IF P_ROLE_RESOURCE_TYPE = 'RS_GROUP_MEMBER' THEN
	    OPEN  role_relate_info;
	    FETCH role_relate_info
	     INTO l_manager_flag, l_group_id,l_salesrep_id;

	    IF (role_relate_info%notfound) THEN
	       CLOSE role_relate_info;
	     ELSE
	       CLOSE role_relate_info;

	       IF (l_manager_flag = 'N') THEN
		  l_event_name := 'CHANGE_CP_ADD_SRP';
		ELSE
		  l_event_name := 'CHANGE_CP_ADD_MGR';
	       END IF;

	       cn_mark_events_pkg.log_event
		 (p_event_name      => l_event_name,
		  p_object_name     => NULL,
		  p_object_id       => p_role_relate_id,
		  p_start_date      => p_start_date_active,
		  p_start_date_old  => NULL,
		  p_end_date        => p_end_date_active,
		  p_end_date_old    => NULL,
		  x_event_log_id    => l_event_log_id,
		  p_org_id          => r.org_id);
	       mark_notify
		 (p_salesrep_id     => l_salesrep_id,
		  p_group_id        => l_group_id,
		  p_operation       => 'I',
		  p_start_date      => p_start_date_active,
		  p_end_date        => p_end_date_active,
		  p_manager_flag    => l_manager_flag,
		  p_event_log_id    => l_event_log_id);
	    END IF; -- if cursor%notfound

	    -- mark team related changes
	    -- clku swap input para
	    FOR srp_tm_rec IN srp_team_relate_info
	      (l_salesrep_id, P_ROLE_RELATE_ID) LOOP
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
		    p_org_id               => r.org_id);
	      END LOOP;
	 END IF; -- RS_GROUP_MEMBER
      end if; -- mark events on

      -- =====================================================================
      -- only process rest of hook for RS_INDIVIDUAL type
      -- =====================================================================
      IF p_role_resource_type = 'RS_INDIVIDUAL' then
	 -- we're all set to go - assign role
	 x_loading_status := 'CN_INSERTED';

	 -- insert into the sales comp tables
	 -- we're already in a loop to cycle through all the applicable orgs
	 -- associated with the salesreps assigned to the given resource
	 srp_plan_assignment_for_insert
	   (p_role_id        => P_ROLE_ID,
	    p_srp_role_id    => P_ROLE_RELATE_ID,
	    x_return_status  => P_RETURN_CODE,
	    p_loading_status => x_loading_status,
	    x_loading_status => x_loading_status);

	 IF (P_RETURN_CODE <> FND_API.G_RET_STS_SUCCESS ) THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;

	 srp_pmt_plan_asgn_for_insert
	   (p_role_id        => P_ROLE_ID,
	    p_srp_role_id    => P_ROLE_RELATE_ID,
	    x_return_status  => P_RETURN_CODE,
	    p_loading_status => x_loading_status,
	    x_loading_status => x_loading_status);

	 IF (P_RETURN_CODE <> FND_API.G_RET_STS_SUCCESS ) THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;

	 -- clku 3718575
	 open  resource_category_info;
	 fetch resource_category_info into l_resource_category;
	 close resource_category_info;

	 IF l_resource_category is not null then
	    IF l_resource_category <> 'TBH' then

	       srp_pay_groups_asgn_for_insert
		 (p_role_id        => P_ROLE_ID,
		  p_srp_role_id    => P_ROLE_RELATE_ID,
		  x_return_status  => P_RETURN_CODE,
		  p_loading_status => x_loading_status,
		  x_loading_status => x_loading_status);

	       IF (P_RETURN_CODE <> FND_API.G_RET_STS_SUCCESS ) THEN
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;

	    END IF; -- clku, not TBH
	 END IF; -- clku not null

	 -- Insert into cn_srp_intel_periods for intelligent calculation
	 ins_srp_intel_prd
	   (p_salesrep_id    => r.salesrep_id,
	    p_start_date     => p_start_date_active,
	    p_end_date       => p_end_date_active,
	    x_msg_count      => P_COUNT,
	    x_msg_data       => P_DATA,
	    x_return_status  => P_RETURN_CODE,
	    p_loading_status => x_loading_status,
	    x_loading_status => x_loading_status);

	 IF (P_RETURN_CODE <> FND_API.G_RET_STS_SUCCESS ) THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF; -- RS_INDIVIDUAL
   END LOOP; -- orgs loop

   -- restore context
   restore_context(l_orig_acc_mode, l_orig_org_id);
   -- end of API body

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      P_RETURN_CODE := FND_API.G_RET_STS_ERROR ;
      restore_context(l_orig_acc_mode, l_orig_org_id);
      FND_MSG_PUB.Count_And_Get
	(p_count                  =>      p_count             ,
	 p_data                   =>      p_data              ,
	 p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      p_return_code := fnd_api.g_ret_sts_unexp_error;
      restore_context(l_orig_acc_mode, l_orig_org_id);
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count   => p_count ,
	 p_data    => p_data  ,
	 p_encoded => FND_API.g_false);
END create_res_role_relate_post;

PROCEDURE  update_res_role_relate_post
  (P_ROLE_RELATE_ID       IN  JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
   P_START_DATE_ACTIVE    IN  JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE
                              DEFAULT  FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE      IN  JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE
                              DEFAULT  FND_API.G_MISS_DATE,
   P_OBJECT_VERSION_NUM   IN  JTF_RS_ROLE_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
   P_DATA                 OUT NOCOPY VARCHAR2,
   P_COUNT                OUT NOCOPY NUMBER,
   P_RETURN_CODE          OUT NOCOPY VARCHAR2) IS

  l_role_id               NUMBER := NULL;
  l_salesrep_id           NUMBER;
  x_loading_status        VARCHAR2(2000);
  l_api_name              VARCHAR2(30) := 'update_res_role_relate_post';

  l_start_date            DATE;
  l_end_date              DATE;
  l_count                 NUMBER;
  l_max_date     CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');
  -- clku, team role enhancement
  l_team_event_name VARCHAR(60);
  l_date_range_action_tbl   cn_api.date_range_action_tbl_type;
  l_role_resource_type      jtf_rs_role_relations.role_resource_type%TYPE;
  l_role_resource_id        jtf_rs_role_relations.role_resource_id%TYPE;

  -- Bug 4083951 by mnativ
  l_usage                   VARCHAR2(30);
  -- clku, bug 3718575
  l_resource_category       VARCHAR2(30);

  l_orig_org_id             NUMBER;
  l_orig_acc_mode           VARCHAR2(1);

 CURSOR get_srp_org_info IS
     select salesrep_id, org_id
       from jtf_rs_salesreps
      where resource_id = l_role_resource_id
        AND l_role_resource_type = 'RS_INDIVIDUAL'
       UNION ALL
     select salesrep_id, org_id
       from jtf_rs_group_members gm, jtf_rs_salesreps s
      where gm.group_member_id = l_role_resource_id
        and gm.resource_id = s.resource_id
        and delete_flag = 'N'
        AND l_role_resource_type = 'RS_GROUP_MEMBER'
       UNION ALL
     select salesrep_id, org_id
       from jtf_rs_team_members tm, jtf_rs_salesreps s
      where tm.team_member_id = l_role_resource_id
        and tm.team_resource_id = s.resource_id
        and resource_type = 'INDIVIDUAL'
        and delete_flag = 'N'
        AND l_role_resource_type = 'RS_TEAM_MEMBER';

 -- get the team info associated with the reps who are inturn
 -- associated with the role (single-org)
 CURSOR srp_team_relate_info (p_salesrep_id NUMBER,
			      p_role_relate_id NUMBER,
			      l_start_date DATE,
			      l_end_date DATE) IS
  SELECT ct.name name,
         ct.comp_team_id team_id,
         greatest(l_start_date, ct.start_date_active) start_date,
         least(nvl(ct.end_date_active, l_max_date),
	       nvl(l_end_date, l_max_date)) end_date
    FROM jtf_rs_group_usages u,
         jtf_rs_group_mbr_role_vl r,
         cn_rs_salesreps s,
         jtf_rs_roles_b ro,
         cn_srp_comp_teams_v srt,
         cn_comp_teams ct
   WHERE r.role_relate_id = p_role_relate_id
     AND s.salesrep_id = p_salesrep_id
     AND u.group_id = r.group_id
     AND u.usage = 'SALES_COMP'
     AND ro.role_id = r.role_id
     AND s.resource_id = r.resource_id
     AND s.salesrep_id = srt.salesrep_id
     AND srt.comp_team_id = ct.comp_team_id
     AND (l_start_date <= ct.start_date_active
	  or l_start_date between ct.start_date_active
	  and nvl (ct.end_date_active, l_start_date));

 -- clku, bug 3718575 get the resource category information
 CURSOR resource_category_info IS
    select category
      from jtf_rs_resource_extns re, jtf_rs_role_relations rr
     where re.resource_id = rr.role_resource_id
       and rr.role_relate_id = P_ROLE_RELATE_ID;

BEGIN
   debugmsg('Inside vertical hook update_role_relate_post');
   p_return_code := fnd_api.g_ret_sts_success;

  -- get usage for the role  (can't fail)
   select rr.role_resource_type, r.role_type_code, r.role_id, rr.role_resource_id
     INTO l_role_resource_type, l_usage, l_role_id, l_role_resource_id
     from jtf_rs_role_relations rr, jtf_rs_roles_b r
    where rr.role_relate_id = p_role_relate_id
      and rr.role_id = r.role_id;

   -- only proceed if usage is SALES_COMP or SALES_COMP_PAYMENT_ANALIST
   IF l_usage <> 'SALES_COMP' AND l_usage <> 'SALES_COMP_PAYMENT_ANALIST' THEN
      RETURN;
   END IF;

   -- Sales Comp role assignment may NOT overlap with Pmt Analyst role assignment
   IF l_role_resource_type = 'RS_INDIVIDUAL' THEN
      IF l_usage = 'SALES_COMP' THEN
	 SELECT COUNT(1) INTO l_count
	   FROM jtf_rs_role_relations rrr
	   WHERE role_relate_id = P_ROLE_RELATE_ID
	   AND EXISTS
	   (
	    SELECT NULL
	    FROM jtf_rs_role_relations rr,
                 jtf_rs_roles_b r
	    WHERE rrr.role_resource_id = rr.role_resource_id
	    AND   rrr.role_relate_id <> rr.role_relate_id
	    AND   rr.role_resource_type = 'RS_INDIVIDUAL'
	    AND   rr.delete_flag = 'N'
	    AND   r.role_id = rr.role_id
	    AND   r.role_type_code = 'SALES_COMP_PAYMENT_ANALIST'
	    -- AND NVL(e1,s2) >= s2 AND s1 <= NVL(e2,s1)
	    -- s1,e1 = IN params, s2,e2 = existing role assignment
	    AND NVL(TRUNC(P_END_DATE_ACTIVE),TRUNC(rr.start_date_active))
	    >= TRUNC(rr.start_date_active)
	    AND TRUNC(P_START_DATE_ACTIVE)
	    <= NVL(TRUNC(rr.end_date_active),TRUNC(P_START_DATE_ACTIVE)));

	 if l_count <> 0 then
	    FND_MESSAGE.SET_NAME('CN', 'CN_SRP_CANNOT_HAVE_ANAL_ROLE');
	    -- A salesperson cannot be assigned a payment analyst role.
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 end if;
       ELSIF l_usage = 'SALES_COMP_PAYMENT_ANALIST' THEN
	 -- Pmt Analyst role assignment may NOT everlap with Sales Comp role assignment
	 SELECT COUNT(1) INTO l_count
	   FROM jtf_rs_role_relations rrr
	   WHERE role_relate_id = P_ROLE_RELATE_ID
	   AND EXISTS
	   (
	    SELECT NULL
	    FROM jtf_rs_role_relations rr,
	         jtf_rs_roles_b r
	    WHERE rrr.role_resource_id = rr.role_resource_id
	    AND   rrr.role_relate_id <> rr.role_relate_id
	    AND   rr.role_resource_type = 'RS_INDIVIDUAL'
	    AND   rr.delete_flag = 'N'
	    AND   r.role_id = rr.role_id
	    AND   r.role_type_code = 'SALES_COMP'
	    -- AND NVL(e1,s2) >= s2 AND s1 <= NVL(e2,s1)
	    -- s1,e1 = IN params, s2,e2 = existing role assignment
	    AND NVL(TRUNC(P_END_DATE_ACTIVE),TRUNC(rr.start_date_active))
            >= TRUNC(rr.start_date_active)
	    AND TRUNC(P_START_DATE_ACTIVE)
            <= NVL(TRUNC(rr.end_date_active),TRUNC(P_START_DATE_ACTIVE))
	    );

	 if l_count <> 0 then
	    FND_MESSAGE.SET_NAME('CN', 'CN_SRP_CANNOT_HAVE_ANAL_ROLE');
	    -- A salesperson cannot be assigned a payment analyst role.
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 end if;
      END IF; -- l_usage = 'SALES_COMP_PAYMENT_ANALIST'
   END IF; -- RS_INDIVIDUAL
   -- End Bug 4083951

   -- done with validation - now process data
   -- store MOAC session info in local variables
   l_orig_org_id   := mo_global.get_current_org_id;
   l_orig_acc_mode := mo_global.get_access_mode;

   -- loop through orgs
   FOR r IN get_srp_org_info LOOP
     mo_global.set_policy_context('S', r.org_id);

     IF l_role_resource_type = 'RS_INDIVIDUAL' THEN
      -- update the sales comp tables
      -- we're already in a loop to cycle through all the applicable orgs
      -- associated with the salesreps assigned to the given resource
      srp_plan_assignment_for_update
	(p_role_id          => l_role_id,
	 p_srp_role_id      => P_ROLE_RELATE_ID,
	 p_date_update_only => fnd_api.g_true,
	 x_return_status    => P_RETURN_CODE,
	 p_loading_status   => x_loading_status,
	 x_loading_status   => x_loading_status);

      IF (P_RETURN_CODE <> FND_API.G_RET_STS_SUCCESS ) THEN
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      srp_pmt_plan_asgn_for_update
	(p_role_id          => l_role_id,
	 p_srp_role_id      => P_ROLE_RELATE_ID,
	 p_date_update_only => fnd_api.g_true,
	 x_return_status    => P_RETURN_CODE,
	 p_loading_status   => x_loading_status,
	 x_loading_status   => x_loading_status);

      IF (P_RETURN_CODE <> FND_API.G_RET_STS_SUCCESS ) THEN
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

       -- clku 3718575
      open  resource_category_info;
      fetch resource_category_info into l_resource_category;
      close resource_category_info;

      IF l_resource_category is not null then
	 IF l_resource_category <> 'TBH' then

	    srp_pay_group_asgn_for_update
	      (p_role_id          => l_role_id,
	       p_srp_role_id      => P_ROLE_RELATE_ID,
	       p_date_update_only => fnd_api.g_true,
	       x_return_status    => P_RETURN_CODE,
	       p_loading_status   => x_loading_status,
	       x_loading_status   => x_loading_status);

	 END IF; -- clku, not TBH
      END IF; -- clku not null

      IF (P_RETURN_CODE <> FND_API.G_RET_STS_SUCCESS ) THEN
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Insert into cn_srp_intel_periods for intelligent calculation
      ins_srp_intel_prd
	(p_salesrep_id     => r.salesrep_id,
	 p_start_date      => p_start_date_active,
	 p_end_date        => p_end_date_active,
	 x_msg_count       => P_COUNT,
	 x_msg_data        => P_DATA,
	 x_return_status   => P_RETURN_CODE,
	 p_loading_status  => x_loading_status,
	 x_loading_status  => x_loading_status);

      IF (P_RETURN_CODE <> FND_API.G_RET_STS_SUCCESS ) THEN
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

     END IF; -- RS_INDIVIDUAL

     -- check mark events
     IF fnd_profile.value('CN_MARK_EVENTS') = 'Y' THEN
	 -- Team Member Role section
	 IF l_role_resource_type = 'RS_TEAM_MEMBER' THEN
	    IF g_team_id is not null then
	       cn_api.get_date_range_diff_action
		 (  start_date_new    => P_START_DATE_ACTIVE
		    ,end_date_new     => P_END_DATE_ACTIVE
		    ,start_date_old   => g_tm_start_date_old
		    ,end_date_old     => g_tm_end_date_old
		    ,x_date_range_action_tbl => l_date_range_action_tbl  );

	       FOR i IN 1..l_date_range_action_tbl.COUNT LOOP

		  if l_date_range_action_tbl(i).action_flag = 'I' THEN

		     l_team_event_name := 'CHANGE_TEAM_ADD_REP';

		     cn_mark_events_pkg.mark_notify_team
		       (P_TEAM_ID              => g_team_id,
			P_TEAM_EVENT_NAME      => l_team_event_name,
			P_TEAM_NAME            => g_team_name,
			P_START_DATE_ACTIVE    => l_date_range_action_tbl(i).start_date,
			P_END_DATE_ACTIVE      => l_date_range_action_tbl(i).end_date,
			P_EVENT_LOG_ID         => NULL,
			p_org_id               => r.org_id);
		  end if;
	       END LOOP;
	    END IF; -- if team not null
	 END IF; -- RS_TEAM_MEMBER
	 -- end Team Member Role section

	 IF l_role_resource_type = 'RS_GROUP_MEMBER' AND
	   g_resource_id IS NOT NULL THEN
	    -- g_resource_id should point to the resource corresponding
	    -- to the group member resource in p_role_resource_id

	    -- insert the period (p_start_date_active, g_start_date_old)
	    -- which becomes active.
	    IF (p_start_date_active < g_start_date_old) THEN
	       IF (p_end_date_active IS NOT NULL
		   AND p_end_date_active < g_start_date_old) THEN
		  l_end_date := p_end_date_active;
		ELSE
		  l_end_date := g_start_date_old - 1;
	       END IF;
	       mark_notify
		 (p_salesrep_id    => r.salesrep_id,
		  p_group_id       => g_group_id,
		  p_operation      => 'I',
		  p_start_date     => p_start_date_active,
		  p_end_date       => l_end_date,
		  p_manager_flag   => g_manager_flag,
		  p_event_log_id   => g_event_log_id);

	       -- mark team related changes
	       FOR srp_tm_rec IN srp_team_relate_info ( r.salesrep_id,
							P_ROLE_RELATE_ID,
							p_start_date_active,
							l_end_date) LOOP
	         if srp_tm_rec.end_date = l_max_date then
		    srp_tm_rec.end_date := null;
		 end if;

		 cn_mark_events_pkg.mark_notify_team
		   (P_TEAM_ID              => srp_tm_rec.team_id ,
		    P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_ADD_REP',
		    P_TEAM_NAME            => srp_tm_rec.name,
		    P_START_DATE_ACTIVE    => srp_tm_rec.start_date,
		    P_END_DATE_ACTIVE      => srp_tm_rec.end_date,
		    P_EVENT_LOG_ID         => g_event_log_id,
		    p_org_id               => r.org_id);
  	       END LOOP;
	    END IF;

	    -- insert the period (g_end_date_old, p_end_date_active)
	    -- which becomes active.
	    IF ((p_end_date_active IS NULL AND g_end_date_old IS NOT NULL) OR p_end_date_active > g_end_date_old) THEN
	       IF (g_end_date_old < p_start_date_active) THEN
		  l_start_date := p_start_date_active;
		ELSE
		  l_start_date := g_end_date_old + 1;
	       END IF;
	       mark_notify
		 (p_salesrep_id    => r.salesrep_id,
		  p_group_id       => g_group_id,
		  p_operation      => 'I',
		  p_start_date     => l_start_date,
		  p_end_date       => p_end_date_active,
		  p_manager_flag   => g_manager_flag,
		  p_event_log_id   => g_event_log_id);

	       -- mark team related changes
	       FOR srp_tm_rec IN srp_team_relate_info (r.salesrep_id,
						       P_ROLE_RELATE_ID,
						       l_start_date,
						       p_end_date_active) LOOP
	         if srp_tm_rec.end_date = l_max_date then
		    srp_tm_rec.end_date := null;
		 end if;

		 cn_mark_events_pkg.mark_notify_team
		   (P_TEAM_ID              => srp_tm_rec.team_id ,
		    P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_ADD_REP',
		    P_TEAM_NAME            => srp_tm_rec.name,
		    P_START_DATE_ACTIVE    => srp_tm_rec.start_date,
		    P_END_DATE_ACTIVE      => srp_tm_rec.end_date,
		    P_EVENT_LOG_ID         => g_event_log_id,
		    p_org_id               => r.org_id);
	       END LOOP;
	    END IF;
	 END IF; -- RS_GROUP_MEMBER
     END IF;  -- if mark events turned on
   END LOOP;  -- orgs loop

   -- restore context
   restore_context(l_orig_acc_mode, l_orig_org_id);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      P_RETURN_CODE := FND_API.G_RET_STS_ERROR ;
      restore_context(l_orig_acc_mode, l_orig_org_id);
      FND_MSG_PUB.Count_And_Get
	(p_count                  =>      p_count             ,
	 p_data                   =>      p_data              ,
	 p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      p_return_code := fnd_api.g_ret_sts_unexp_error;
      restore_context(l_orig_acc_mode, l_orig_org_id);
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count   => p_count ,
	 p_data    => p_data  ,
	 p_encoded => FND_API.g_false);
END update_res_role_relate_post;

PROCEDURE  delete_res_role_relate_pre
  (P_ROLE_RELATE_ID       IN  JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN  JTF_RS_ROLE_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
   P_DATA                 OUT NOCOPY VARCHAR2,
   P_COUNT                OUT NOCOPY NUMBER,
   P_RETURN_CODE          OUT NOCOPY VARCHAR2) IS

   cursor get_role_id is
   select rr.role_id
     from jtf_rs_role_relations   rr,
          jtf_rs_roles_b          r
    where rr.role_relate_id       = p_role_relate_id
      AND rr.role_id              = r.role_id
      AND r.role_type_code        = 'SALES_COMP'
      AND rr.role_resource_type   = 'RS_INDIVIDUAL'
      AND nvl(rr.delete_flag,'N') = 'N';

   l_role_id              NUMBER := NULL;
   x_loading_status       VARCHAR2(2000);
   l_api_name             VARCHAR2(30) := 'delete_res_role_relate_pre';
   -- for mark events
   l_manager_flag         VARCHAR2(1);
   l_group_id             NUMBER;
   l_event_log_id         NUMBER;
   l_salesrep_id          NUMBER;
   p_start_date_active    DATE;
   p_end_date_active      DATE;
   l_event_name           VARCHAR2(30);
   l_count                NUMBER;
   l_usage                VARCHAR2(30);
   l_return_status        VARCHAR2(200);
   l_msg_count            NUMBER;
   l_msg_data             VARCHAR2(2000);
   l_max_date             CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');

    --clku, team member rs role mark event

   l_tm_start_date DATE;
   l_tm_end_date DATE;
   l_rr_start_date DATE;
   l_rr_end_date DATE;
   l_team_id NUMBER;
   l_team_name VARCHAR2(30);
   l_team_event_name VARCHAR(60);
   l_date_range_action_tbl   cn_api.date_range_action_tbl_type;
   l_role_resource_id        jtf_rs_role_relations.role_resource_id%TYPE;
   l_role_resource_type      jtf_rs_role_relations.role_resource_type%TYPE;

   l_orig_org_id             NUMBER;
   l_orig_acc_mode           VARCHAR(1);

    -- clku, bug 3718575
   l_resource_category VARCHAR2(30);

     CURSOR get_srp_org_info IS
     select salesrep_id, org_id
       from jtf_rs_salesreps
      where resource_id = l_role_resource_id
        AND l_role_resource_type = 'RS_INDIVIDUAL'
       UNION ALL
     select salesrep_id, org_id
       from jtf_rs_group_members gm, jtf_rs_salesreps s
      where gm.group_member_id = l_role_resource_id
        and gm.resource_id = s.resource_id
        and delete_flag = 'N'
        AND l_role_resource_type = 'RS_GROUP_MEMBER'
       UNION ALL
     select salesrep_id, org_id
       from jtf_rs_team_members tm, jtf_rs_salesreps s
      where tm.team_member_id = l_role_resource_id
        and tm.team_resource_id = s.resource_id
        and resource_type = 'INDIVIDUAL'
        and delete_flag = 'N'
        AND l_role_resource_type = 'RS_TEAM_MEMBER';

     -- run in single-org context
   CURSOR team_member_role_relate IS
   SELECT t.start_date_active, t.end_date_active, rr.role_id,
          sr.salesrep_id, tm.team_id, t.team_name
   from   jtf_rs_team_members tm,
          jtf_rs_salesreps sr,
          jtf_rs_team_usages tu,
          jtf_rs_role_relations rr,
          jtf_rs_roles_b rb,
          jtf_rs_teams_vl t
   where rr.role_relate_id = p_role_relate_id
   and rr.role_resource_type(+) = 'RS_TEAM_MEMBER'
   and tm.resource_type = 'INDIVIDUAL'
   and tm.delete_flag = 'N'
   and tu.team_id = tm.team_id
   and tu.usage = 'SALES_COMP'
   and sr.resource_id = tm.team_resource_id
   and (sr.org_id is null or sr.org_id = (select org_id from cn_repositories))
   and rr.role_resource_id(+) = tm.team_member_id
   and rr.delete_flag(+) = 'N'
   and rb.role_id(+) = rr.role_id
   and rb.role_type_code(+) = 'SALES_COMP'
   and t.team_id = tm.team_id;

   -- cursor to get the information about this role relation (single-org)
   CURSOR role_relate_info IS
   SELECT r.manager_flag, r.group_id, s.salesrep_id,
          r.start_date_active, r.end_date_active
     FROM jtf_rs_group_usages u,
          jtf_rs_group_mbr_role_vl r,
          cn_rs_salesreps s
    WHERE r.role_relate_id = p_role_relate_id
      AND u.group_id = r.group_id
      AND u.usage = 'SALES_COMP'
      AND s.resource_id = r.resource_id;

   -- get the team info associated with the reps who are inturn
   -- associated with the role (single-org)
   CURSOR srp_team_relate_info (p_salesrep_id NUMBER, p_role_relate_id NUMBER) IS
  SELECT ct.name name,
         ct.comp_team_id team_id,
         greatest(r.start_date_active, ct.start_date_active) start_date,
         Least(nvl(ct.end_date_active, l_max_date), nvl(r.end_date_active, l_max_date)) end_date
    FROM jtf_rs_group_usages u,
         jtf_rs_group_mbr_role_vl r,
         cn_rs_salesreps s,
         jtf_rs_roles_b ro,
         cn_srp_comp_teams_v srt,
         cn_comp_teams ct
   WHERE r.role_relate_id = p_role_relate_id
     AND s.salesrep_id = p_salesrep_id
     AND u.group_id = r.group_id
     AND u.usage = 'SALES_COMP'
     AND ro.role_id = r.role_id
     AND ro.role_type_code = 'SALES_COMP'
     AND s.resource_id = r.resource_id
     AND s.salesrep_id = srt.salesrep_id
     AND srt.comp_team_id = ct.comp_team_id
     AND (r.start_date_active <= ct.start_date_active
	  or r.start_date_active between ct.start_date_active and nvl (ct.end_date_active, r.start_date_active))
     AND nvl(r.end_date_active, ct.start_date_active) >= ct.start_date_active;

     -- clku, bug 3718575 get the resource category information
   CURSOR resource_category_info IS
      select category
	from jtf_rs_resource_extns re, jtf_rs_role_relations rr
       where re.resource_id = rr.role_resource_id
	 and rr.role_relate_id = P_ROLE_RELATE_ID;

BEGIN
   p_return_code := fnd_api.g_ret_sts_success;

   -- get usage for the role  (can't fail)
   select rr.role_resource_type, r.role_type_code, r.role_id,
          rr.role_resource_id, start_date_active, end_date_active
     INTO l_role_resource_type, l_usage, l_role_id,
          l_role_resource_id, l_rr_start_date, l_rr_end_date
     from jtf_rs_role_relations rr, jtf_rs_roles_b r
    where rr.role_relate_id = p_role_relate_id
      and rr.role_id = r.role_id;

   -- only proceed if usage is SALES_COMP or SALES_COMP_PAYMENT_ANALIST
   IF l_usage <> 'SALES_COMP' AND l_usage <> 'SALES_COMP_PAYMENT_ANALIST' THEN
      RETURN;
   END IF;

   -- done with validation - now process data
   -- store MOAC session info in local variables
   l_orig_org_id   := mo_global.get_current_org_id;
   l_orig_acc_mode := mo_global.get_access_mode;

   -- loop through orgs
   FOR r IN get_srp_org_info LOOP
      mo_global.set_policy_context('S', r.org_id);

      IF l_role_resource_type = 'RS_INDIVIDUAL' THEN
	 -- if deleting a payee role, make sure no payee assigned over that period
	 if l_role_id = G_PAYEE_ROLE then
	    select count(1) into l_count
	      from cn_srp_roles sr, cn_srp_payee_assigns spa
	     where sr.srp_role_id = p_role_relate_id
	       and spa.payee_id = sr.salesrep_id
	       and sr.start_date  <= nvl(spa.end_date, sr.start_date)
	       and spa.start_date <= nvl(sr.end_date, spa.start_date);

	    if l_count <> 0 then
	       FND_MESSAGE.SET_NAME('CN', 'CN_PA_ASGN_DATE');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
	    end if;
	 end if;

	 -- update the sales comp tables
	 -- we're already in a loop to cycle through all the applicable orgs
	 -- associated with the salesreps assigned to the given resource

	 -- clku 3718575
	 open  resource_category_info;
	 fetch resource_category_info into l_resource_category;
	 close resource_category_info;

	 IF l_resource_category is not null then
	    IF l_resource_category <> 'TBH' then

	       srp_pay_group_asgn_for_delete
		 (p_role_id        => l_role_id,
		  p_srp_role_id    => P_ROLE_RELATE_ID,
		  x_return_status  => P_RETURN_CODE,
		  p_loading_status => x_loading_status,
		  x_loading_status => x_loading_status);

	    END IF; -- clku, not TBH
	 END IF; -- clku not null

	 IF (p_return_code <> fnd_api.g_ret_sts_success) THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;

	 srp_plan_assignment_for_delete
	   (p_role_id        => l_role_id,
	    p_srp_role_id    => P_ROLE_RELATE_ID,
	    x_return_status  => P_RETURN_CODE,
	    p_loading_status => x_loading_status,
	    x_loading_status => x_loading_status);

	 IF (p_return_code <> fnd_api.g_ret_sts_success) THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;

	 srp_pmt_plan_asgn_for_delete
	   (p_role_id        => l_role_id,
	    p_srp_role_id    => P_ROLE_RELATE_ID,
	    x_return_status  => P_RETURN_CODE,
	    p_loading_status => x_loading_status,
	    x_loading_status => x_loading_status);

	 IF (p_return_code <> fnd_api.g_ret_sts_success) THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;  -- RS_INDIVIDUAL

      -- handle mark events
      IF fnd_profile.value('CN_MARK_EVENTS') = 'Y' THEN
	 -- Team Member Role section
	 IF l_role_resource_type = 'RS_TEAM_MEMBER' THEN
	    OPEN team_member_role_relate;
	    FETCH team_member_role_relate INTO
	      l_tm_start_date, l_tm_end_date, l_role_id,
	      l_salesrep_id, l_team_id, l_team_name;
	    IF (team_member_role_relate%notfound) THEN
	       CLOSE team_member_role_relate;
	     ELSE
	       CLOSE team_member_role_relate;

	       cn_api.get_date_range_diff_action
		 (  start_date_new    => l_tm_start_date
		    ,end_date_new     => l_tm_end_date
		    ,start_date_old   => l_rr_start_date
		    ,end_date_old     => l_rr_end_date
		    ,x_date_range_action_tbl => l_date_range_action_tbl  );

	       FOR i IN 1..l_date_range_action_tbl.COUNT LOOP
		  if l_date_range_action_tbl(i).action_flag = 'I' THEN
		     l_team_event_name := 'CHANGE_TEAM_ADD_REP';
		   else
		     l_team_event_name := 'CHANGE_TEAM_DEL_REP';
		  end if;

		  cn_mark_events_pkg.mark_notify_team
		    (P_TEAM_ID              => l_team_id,
		     P_TEAM_EVENT_NAME      => l_team_event_name,
		     P_TEAM_NAME            => l_team_name,
		     P_START_DATE_ACTIVE    => l_date_range_action_tbl(i).start_date,
		     P_END_DATE_ACTIVE      => l_date_range_action_tbl(i).end_date,
		     P_EVENT_LOG_ID         => NULL,
		     p_org_id               => r.org_id);
	       END LOOP;
	    END IF;
	 END IF; -- RS_TEAM_MEMBER
	 -- end Team Member Role section

	 IF l_role_resource_type = 'RS_GROUP_MEMBER' THEN
	    OPEN role_relate_info;
	    FETCH role_relate_info
	      INTO l_manager_flag, l_group_id, l_salesrep_id,
	      p_start_date_active, p_end_date_active;
	    IF (role_relate_info%notfound) THEN
	       CLOSE role_relate_info;
	     ELSE
	       CLOSE role_relate_info;

	       -- the cursor will only retrieve rows for SALES_COMP roles of type
	       -- RS_GROUP_MEMBER
	       IF (l_manager_flag = 'N') THEN
		  l_event_name := 'CHANGE_CP_DELETE_SRP';
		ELSE
		  l_event_name := 'CHANGE_CP_DELETE_MGR';
	       END IF;

	       cn_mark_events_pkg.log_event
		 (p_event_name      => l_event_name,
		  p_object_name     => NULL,
		  p_object_id       => p_role_relate_id,
		  p_start_date      => NULL,
		  p_start_date_old  => p_start_date_active,
		  p_end_date        => NULL,
		  p_end_date_old    => p_end_date_active,
		  x_event_log_id    => l_event_log_id,
		  p_org_id          => r.org_id);

	       mark_notify
		 (p_salesrep_id     => l_salesrep_id,
		  p_role_id         => l_role_id,
		  p_group_id        => l_group_id,
		  p_operation       => 'D',
		  p_start_date      => p_start_date_active,
		  p_end_date        => p_end_date_active,
		  p_manager_flag    => l_manager_flag,
		  p_event_log_id    => l_event_log_id );

	       -- mark team related changes
	       -- clku swap input para
	       FOR srp_tm_rec IN srp_team_relate_info
		 (l_salesrep_id, P_ROLE_RELATE_ID) LOOP
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
		     p_org_id               => r.org_id);
	       END LOOP;
	    END IF;
	 END IF; -- RS_GROUP_MEMBER
      END IF; -- mark events
   END LOOP; -- orgs

   -- restore context
   restore_context(l_orig_acc_mode, l_orig_org_id);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      P_RETURN_CODE := FND_API.G_RET_STS_ERROR ;
      restore_context(l_orig_acc_mode, l_orig_org_id);
      FND_MSG_PUB.Count_And_Get
	(p_count                  =>      p_count             ,
	 p_data                   =>      p_data              ,
	 p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      p_return_code := fnd_api.g_ret_sts_unexp_error;
      restore_context(l_orig_acc_mode, l_orig_org_id);
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count   => p_count ,
	 p_data    => p_data  ,
	 p_encoded => FND_API.g_false);
END;

PROCEDURE  update_res_role_relate_pre
  (P_ROLE_RELATE_ID       IN  JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
   P_START_DATE_ACTIVE    IN  JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE
                              DEFAULT  FND_API.G_MISS_DATE,
   P_END_DATE_ACTIVE      IN  JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE
                              DEFAULT  FND_API.G_MISS_DATE,
   P_OBJECT_VERSION_NUM   IN  JTF_RS_ROLE_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
   P_DATA                 OUT NOCOPY VARCHAR2,
   P_COUNT                OUT NOCOPY NUMBER,
   P_RETURN_CODE          OUT NOCOPY VARCHAR2) IS

   l_api_name         VARCHAR2(30) := 'update_res_role_relate_pre';
   l_start_date       DATE;
   l_end_date         DATE;
   l_event_name       VARCHAR2(30);
   l_role_id          NUMBER;
   l_salesrep_id      NUMBER;
   l_usage            VARCHAR2(30);

   l_orig_org_id      NUMBER;
   l_orig_acc_mode    VARCHAR2(1);
   --variable added for bug 6914823
   l_res_start_date   DATE;

   CURSOR payee_assign_date_curs(l_payee_id NUMBER) IS
      select salesrep_id, start_date, end_date from cn_srp_payee_assigns
       where payee_id = l_payee_id;

   l_max_date   CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');
    --clku, team member rs role mark event

   l_team_event_name VARCHAR(60);
   l_date_range_action_tbl   cn_api.date_range_action_tbl_type;
   l_role_resource_type      jtf_rs_role_relations.role_resource_type%TYPE;
   l_role_resource_id        jtf_rs_role_relations.role_resource_id%TYPE;

  -- get the salesrep ID's, org ID's
  CURSOR get_srp_org_info IS
     select salesrep_id, org_id
       from jtf_rs_salesreps
      where resource_id = l_role_resource_id
        AND l_role_resource_type = 'RS_INDIVIDUAL'
       UNION ALL
     select salesrep_id, org_id
       from jtf_rs_group_members gm, jtf_rs_salesreps s
      where gm.group_member_id = l_role_resource_id
        and gm.resource_id = s.resource_id
        and delete_flag = 'N'
        AND l_role_resource_type = 'RS_GROUP_MEMBER'
       UNION ALL
     select salesrep_id, org_id
       from jtf_rs_team_members tm, jtf_rs_salesreps s
      where tm.team_member_id = l_role_resource_id
        and tm.team_resource_id = s.resource_id
        and resource_type = 'INDIVIDUAL'
        and delete_flag = 'N'
        AND l_role_resource_type = 'RS_TEAM_MEMBER';

   -- run in single-org context
   CURSOR team_member_role_relate IS
   SELECT rr.start_date_active, rr.end_date_active, tm.team_id, t.team_name
   from   jtf_rs_team_members tm,
          jtf_rs_salesreps sr,
          jtf_rs_team_usages tu,
          jtf_rs_role_relations rr,
          jtf_rs_roles_b rb,
          jtf_rs_teams_vl t
   where rr.role_relate_id = p_role_relate_id
   and rr.role_resource_type(+) = 'RS_TEAM_MEMBER'
   and tm.resource_type = 'INDIVIDUAL'
   and tm.delete_flag = 'N'
   and tu.team_id = tm.team_id
   and tu.usage = 'SALES_COMP'
   and sr.resource_id = tm.team_resource_id
   and (sr.org_id is null or sr.org_id = (select org_id from cn_repositories))
   and rr.role_resource_id(+) = tm.team_member_id
   and rr.delete_flag(+) = 'N'
   and rb.role_id(+) = rr.role_id
   and rb.role_type_code(+) = 'SALES_COMP'
   and t.team_id = tm.team_id;

   -- clku

   -- cursor to get the information about this role relation
   CURSOR role_relate_info IS
   SELECT r.manager_flag, r.group_id, s.salesrep_id, s.resource_id,
          r.start_date_active, r.end_date_active, r.role_id
     FROM jtf_rs_group_usages u,
          jtf_rs_group_mbr_role_vl r,
          cn_rs_salesreps s
    WHERE r.role_relate_id = p_role_relate_id
      AND u.group_id = r.group_id
      AND u.usage = 'SALES_COMP'
      AND s.resource_id = r.resource_id;

    -- get the team info associated with the reps who are inturn associated with the role
   CURSOR srp_team_relate_info (p_salesrep_id NUMBER,
				p_role_relate_id NUMBER,
				l_start_date DATE,
				l_end_date DATE) IS
     SELECT ct.name name,
         ct.comp_team_id team_id,
         greatest(l_start_date, ct.start_date_active) start_date,
         Least(nvl(ct.end_date_active, l_max_date), nvl(l_end_date, l_max_date)) end_date
    FROM jtf_rs_group_usages u,
         jtf_rs_group_mbr_role_vl r,
         cn_rs_salesreps s,
         jtf_rs_roles_b ro,
         cn_srp_comp_teams_v srt,
         cn_comp_teams ct
   WHERE r.role_relate_id = p_role_relate_id
     AND s.salesrep_id = p_salesrep_id
     AND u.group_id = r.group_id
     AND u.usage = 'SALES_COMP'
     AND ro.role_id = r.role_id
     AND s.resource_id = r.resource_id
     AND s.salesrep_id = srt.salesrep_id
     AND srt.comp_team_id = ct.comp_team_id
     AND (l_start_date <= ct.start_date_active
            or l_start_date between ct.start_date_active and nvl (ct.end_date_active, l_start_date));

   CURSOR payee_role_info IS
   SELECT salesrep_id, start_date, end_date, role_id
     FROM cn_srp_roles
    WHERE srp_role_id = p_role_relate_id;

BEGIN
   debugmsg('Inside vertical hook update_role_relate_pre');
   p_return_code := fnd_api.g_ret_sts_success;

  -- get usage for the role  (can't fail)
   select rr.role_resource_type, r.role_type_code, r.role_id, rr.role_resource_id
     INTO l_role_resource_type, l_usage, l_role_id, l_role_resource_id
     from jtf_rs_role_relations rr, jtf_rs_roles_b r
    where rr.role_relate_id = p_role_relate_id
      and rr.role_id = r.role_id;

   -- only proceed if usage is SALES_COMP or SALES_COMP_PAYMENT_ANALIST
   IF l_usage <> 'SALES_COMP' AND l_usage <> 'SALES_COMP_PAYMENT_ANALIST' THEN
      RETURN;
   END IF;

   -- done with validation - now process data
   -- store MOAC session info in local variables
   l_orig_org_id   := mo_global.get_current_org_id;
   l_orig_acc_mode := mo_global.get_access_mode;

   -- loop through orgs
   FOR r IN get_srp_org_info LOOP
      mo_global.set_policy_context('S', r.org_id);

      -- make sure we are not deleting a payee role interval during a payee
      -- assignment to a salesrep
      -- only applies to RS_INDIVIDUAL
      IF l_role_resource_type = 'RS_INDIVIDUAL' AND l_role_id = G_PAYEE_ROLE then
	 open  payee_role_info;
	 FETCH payee_role_info
	   INTO l_salesrep_id, g_start_date_old, g_end_date_old, l_role_id;
	 IF (payee_role_info%notfound) THEN
	    CLOSE payee_role_info;
	  ELSE
	    CLOSE payee_role_info;

	    g_resource_id := l_role_resource_id; -- for RS_INDIVIDUAL

	    cn_api.get_date_range_diff_action
	      (start_date_new   => P_START_DATE_ACTIVE,
	       end_date_new     => P_END_DATE_ACTIVE,
	       start_date_old   => g_start_date_old,
	       end_date_old     => g_end_date_old,
	       x_date_range_action_tbl => l_date_range_action_tbl);

	    FOR i IN 1..l_date_range_action_tbl.COUNT LOOP
	       if l_date_range_action_tbl(i).action_flag = 'D' THEN
		  -- check if there is any salesrep having this payee assigned within
		  -- the deleting paygroup date range
		  For l_payee_assign_date_rec IN payee_assign_date_curs(l_salesrep_id) LOOP
		     -- check if there is any date range over between
		     -- srp paygroup date and payee assign date
		     IF CN_API.date_range_overlap
		       (l_date_range_action_tbl(i).start_date,
			l_date_range_action_tbl(i).end_date,
			l_payee_assign_date_rec.start_date,
			l_payee_assign_date_rec.end_date) = true THEN

			-- Raise Error
			IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
			  THEN
			   fnd_message.set_name('CN', 'CN_PA_ASGN_DATE');
			   fnd_msg_pub.add;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		     END IF;
		  END LOOP;
	       END IF; --if l_date_range_action_tbl(i).action_flag = 'D'
	    END LOOP;  -- FOR i IN 1..l_date_range_action_tbl.COUNT LOOP
	 END IF; -- if cursor found
      END IF; -- payee role

      IF fnd_profile.value('CN_MARK_EVENTS') = 'Y' THEN

       IF l_role_resource_type = 'RS_TEAM_MEMBER' THEN
	 -- reset global variables
	 g_tm_start_date_old := null;
	 g_tm_end_date_old := null;
	 g_team_id := null;
	 g_team_name := null;

	 OPEN team_member_role_relate;
	 FETCH team_member_role_relate INTO
	   g_tm_start_date_old, g_tm_end_date_old, g_team_id, g_team_name;
	 IF (team_member_role_relate%notfound) THEN
	    CLOSE team_member_role_relate;
	  ELSE
	    CLOSE team_member_role_relate;

	    cn_api.get_date_range_diff_action
	      (  start_date_new    => P_START_DATE_ACTIVE
		 ,end_date_new     => P_END_DATE_ACTIVE
		 ,start_date_old   => g_tm_start_date_old
		 ,end_date_old     => g_tm_end_date_old
		 ,x_date_range_action_tbl => l_date_range_action_tbl  );

	    FOR i IN 1..l_date_range_action_tbl.COUNT LOOP

	       if l_date_range_action_tbl(i).action_flag = 'D' THEN

		  l_team_event_name := 'CHANGE_TEAM_DEL_REP';

		  cn_mark_events_pkg.mark_notify_team
		    (P_TEAM_ID              => g_team_id,
		     P_TEAM_EVENT_NAME      => l_team_event_name,
		     P_TEAM_NAME            => g_team_name,
		     P_START_DATE_ACTIVE    => l_date_range_action_tbl(i).start_date,
		     P_END_DATE_ACTIVE      => l_date_range_action_tbl(i).end_date,
		     P_EVENT_LOG_ID         => NULL,
		     p_org_id               => r.org_id);
	       end if; -- action_flag
	    END LOOP; -- date range action tbl
	 END IF; -- team member not found
       END IF; -- team member
       -- Team Member Role section
       -- ENHANCEMENT END

       -- reset g_salesrep_id to null before trying to set it to another value
       g_resource_id := NULL;

       IF l_role_resource_type = 'RS_GROUP_MEMBER' then
	 OPEN  role_relate_info;
	 FETCH role_relate_info
	  INTO g_manager_flag, g_group_id, l_salesrep_id, g_resource_id,
	       g_start_date_old, g_end_date_old, l_role_id;
	 IF (role_relate_info%notfound) THEN
	    CLOSE role_relate_info;
	  ELSE
	    CLOSE role_relate_info;

	    IF (g_manager_flag = 'Y') THEN
	       l_event_name := 'CHANGE_CP_SRP_DATE';
	     ELSIF (g_manager_flag = 'N') THEN
	       l_event_name := 'CHANGE_CP_MGR_DATE';
	    END IF;
		--code added for bug 6914823
	    if (p_start_date_active = fnd_api.g_miss_date)
		    OR
		   (p_start_date_active > p_end_date_active)
		    OR
			(p_start_date_active is NULL)
        then
           l_res_start_date:= g_start_date_old;
        else
           l_res_start_date := p_start_date_active;
        end if;
	    -- end of code addition
	    cn_mark_events_pkg.log_event
	      (p_event_name      => l_event_name,
	       p_object_name     => NULL,
	       p_object_id       => p_role_relate_id,
	       p_start_date      => l_res_start_date,--parameter changed for bug 6914823
	       p_start_date_old  => g_start_date_old,
	       p_end_date        => p_end_date_active,
	       p_end_date_old    => g_end_date_old,
	       x_event_log_id    => g_event_log_id,
	       p_org_id          => r.org_id);

	    -- delete the period (g_start_date_old, p_start_date_active)
	    -- which is not active any more
	    IF (p_start_date_active > g_start_date_old) THEN
	       IF (g_end_date_old IS NOT NULL AND g_end_date_old < p_start_date_active) THEN
		  l_end_date := g_end_date_old;
		ELSE
		  l_end_date := p_start_date_active - 1;
	       END IF;

	       mark_notify
		 (p_salesrep_id    => l_salesrep_id,
		  p_role_id        => l_role_id,
		  p_group_id       => g_group_id,
		  p_operation      => 'D',
		  p_start_date     => g_start_date_old,
		  p_end_date       => l_end_date,
		  p_manager_flag   => g_manager_flag,
		  p_event_log_id   => g_event_log_id );

	       -- mark team related changes
	       FOR srp_tm_rec IN srp_team_relate_info ( l_salesrep_id,
							P_ROLE_RELATE_ID,
							g_start_date_old,
							l_end_date) LOOP
	          if srp_tm_rec.end_date = l_max_date then
		     srp_tm_rec.end_date := null;
		  end if;

		  cn_mark_events_pkg.mark_notify_team
		    (P_TEAM_ID              => srp_tm_rec.team_id ,
		     P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_DEL_REP',
		     P_TEAM_NAME            => srp_tm_rec.name,
		     P_START_DATE_ACTIVE    => srp_tm_rec.start_date,
		     P_END_DATE_ACTIVE      => srp_tm_rec.end_date,
		     P_EVENT_LOG_ID         => g_event_log_id,
		     p_org_id               => r.org_id);
	        END LOOP;
	    END IF;
	 END IF;

	 -- delete the period (p_end_date_active, g_end_date_old)
	 -- which is not active any more
	 IF ((g_end_date_old IS NULL AND p_end_date_active IS NOT NULL)
	     OR p_end_date_active < g_end_date_old) THEN
	    IF (p_end_date_active < g_start_date_old) THEN
	       l_start_date := g_start_date_old;
	     ELSE
	       l_start_date := p_end_date_active + 1;
	    END IF;

	    mark_notify
	      (p_salesrep_id    => l_salesrep_id,
	       p_role_id        => l_role_id,
	       p_group_id       => g_group_id,
	       p_operation      => 'D',
	       p_start_date     => l_start_date,
	       p_end_date       => g_end_date_old,
	       p_manager_flag   => g_manager_flag,
	       p_event_log_id   => g_event_log_id );

	    -- mark team related changes
	    FOR srp_tm_rec IN srp_team_relate_info ( l_salesrep_id,
						     P_ROLE_RELATE_ID,
						     l_start_date,
						     g_end_date_old) LOOP

	       if srp_tm_rec.end_date = l_max_date then
		  srp_tm_rec.end_date := null;
	       end if;

	       cn_mark_events_pkg.mark_notify_team
		 (P_TEAM_ID              => srp_tm_rec.team_id ,
		  P_TEAM_EVENT_NAME      => 'CHANGE_TEAM_DEL_REP',
		  P_TEAM_NAME            => srp_tm_rec.name,
		  P_START_DATE_ACTIVE    => srp_tm_rec.start_date,
		  P_END_DATE_ACTIVE      => srp_tm_rec.end_date,
		  P_EVENT_LOG_ID         => g_event_log_id,
		  p_org_id               => r.org_id);
	     END LOOP;
	 END IF;
       END IF;  -- group member
      END IF;  -- mark events
   END LOOP;  -- orgs

   -- restore context
   restore_context(l_orig_acc_mode, l_orig_org_id);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      P_RETURN_CODE := FND_API.G_RET_STS_ERROR ;
      restore_context(l_orig_acc_mode, l_orig_org_id);
      FND_MSG_PUB.Count_And_Get
	(p_count                  =>      p_count             ,
	 p_data                   =>      p_data              ,
	 p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      p_return_code := fnd_api.g_ret_sts_unexp_error;
      restore_context(l_orig_acc_mode, l_orig_org_id);
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count   => p_count ,
	 p_data    => p_data  ,
	 p_encoded => FND_API.g_false);
END update_res_role_relate_pre;

-- ===================================================================
-- these are the procedures that aren't used in the body, but since ==
-- they are declared in the spec, they need to be declared here     ==
-- with null bodies.                                                ==
-- ===================================================================

/*for create resource role relate */

PROCEDURE  create_res_role_relate_pre
  (P_ROLE_RESOURCE_TYPE     JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_TYPE%TYPE,
   P_ROLE_RESOURCE_ID       JTF_RS_ROLE_RELATIONS.ROLE_RESOURCE_ID%TYPE,
   P_ROLE_ID                JTF_RS_ROLE_RELATIONS.ROLE_ID%TYPE,
   P_START_DATE_ACTIVE      JTF_RS_ROLE_RELATIONS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE        JTF_RS_ROLE_RELATIONS.END_DATE_ACTIVE%TYPE ,
   P_DATA                   OUT NOCOPY VARCHAR2,
   P_COUNT                  OUT NOCOPY NUMBER,
   P_RETURN_CODE            OUT NOCOPY VARCHAR2) IS
BEGIN
   p_return_code := fnd_api.g_ret_sts_success ;
END create_res_role_relate_pre;

PROCEDURE  delete_res_role_relate_post
  (P_ROLE_RELATE_ID       IN  JTF_RS_ROLE_RELATIONS.ROLE_RELATE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN  JTF_RS_ROLE_RELATIONS.OBJECT_VERSION_NUMBER%TYPE,
   P_DATA                 OUT NOCOPY VARCHAR2,
   P_COUNT                OUT NOCOPY NUMBER,
   P_RETURN_CODE          OUT NOCOPY VARCHAR2) IS
BEGIN
   p_return_code := fnd_api.g_ret_sts_success;
END delete_res_role_relate_post;

FUNCTION Ok_To_Generate_Msg
  (P_DATA                 OUT NOCOPY VARCHAR2,
   P_COUNT                OUT NOCOPY NUMBER,
   P_RETURN_CODE          OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
BEGIN
   p_return_code := fnd_api.g_ret_sts_success;
   return false;
END Ok_To_Generate_Msg;

END jtf_rs_role_relate_vuhk;

/
