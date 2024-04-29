--------------------------------------------------------
--  DDL for Package Body CN_SRP_PAYGROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PAYGROUP_PVT" as
-- $Header: cnvsdpgb.pls 120.16 2006/09/28 07:03:35 chanthon noship $

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_Srp_PayGroup_PVT';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnvsdgpb.pls';

---------------------------------------------------------------------+
-- Procedure   : Validate_Assignment
-- Description : Procedure to validate the date range for assignment of
--               a salesperson to a paygroup
---------------------------------------------------------------------+

PROCEDURE Validate_Assignment
  (
   x_return_status	    OUT NOCOPY VARCHAR2 ,
   x_msg_count		    OUT NOCOPY NUMBER	 ,
   x_msg_data		    OUT NOCOPY VARCHAR2,
   p_salesrep_id	    IN NUMBER,
   p_org_id                 IN NUMBER,
   p_start_date		    IN DATE,
   p_end_date		    IN DATE,
   p_pay_group_id           IN NUMBER,
   p_srp_pay_group_id       IN NUMBER,
   p_loading_status         IN VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2,
   x_status		    OUT NOCOPY VARCHAR2
   ) IS

      l_count		   NUMBER       := 0;
      l_api_name  CONSTANT VARCHAR2(30) := 'Validate_assignment';
      l_dummy              NUMBER;
      l_srp_start_date     DATE;
      l_srp_end_date       DATE;
      l_pp_start_date      DATE;
      l_pp_end_date        DATE;
      l_null_date          CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');

BEGIN

   --
   --  Initialize API return status to success
   --
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status ;

   -- Check if already exist( duplicate assigned,unique key violation check)
   SELECT COUNT(1) INTO l_dummy
     FROM cn_srp_pay_groups_all
     WHERE salesrep_id = p_salesrep_id
     AND   pay_group_id =  p_pay_group_id
     AND   start_date  = p_start_date
     AND   ( (end_date = p_end_date) OR
	     (end_date IS NULL AND p_end_date IS NULL) )
	       AND   ((p_srp_pay_group_id IS NOT NULL AND
		       srp_pay_group_id<> p_srp_pay_group_id)
		      OR
		      (p_srp_pay_group_id IS NULL));

   IF l_dummy > 0 THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.Set_Name('CN', 'CN_SRP_PAY_GRP_EXIST');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SRP_PAY_GRP_EXIST';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;


    -- Check if Salesrep active
   -- Cannot assign a pmt plan to an inactive rep because we need the
   -- cn_srp_periods in order to  create cn_srp_period_quotas. It's also a
   -- reasonable business requirement
   SELECT start_date_active, end_date_active
     INTO l_srp_start_date, l_srp_end_date
     FROM cn_salesreps
    WHERE salesrep_id = p_salesrep_id
      AND org_id = p_org_id;

   IF l_srp_start_date IS NULL THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME('CN','SRP_MUST_ACTIVATE_REP');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'SRP_MUST_ACTIVATE_REP';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;


   -- Check if date range invalid
   -- will check : if start_date is null
   --              if start_date/end_date is missing
   --              if start_date > end_date
    IF ( (cn_api.invalid_date_range
	  (p_start_date => p_start_date,
	   p_end_date   => p_end_date,
	   p_end_date_nullable => FND_API.G_TRUE,
	   p_loading_status => x_loading_status,
	   x_loading_status => x_loading_status)) = FND_API.G_TRUE ) THEN
       RAISE FND_API.G_EXC_ERROR ;
   END IF;


      --
      --
      -- Validate Rule :Start  or end date is outside of the processing
      -- period range define in rep detail
      --
      -- Oct 26 1999 ACHUNG
      -- Change: srp_pmt_plan.end_date not forced.
      -- if srp_pmt_plan.end_date is null, no need to check between srp and pmt
      -- start date/end date range
      --
     	 IF (   (
   	            ( l_srp_start_date IS NOT NULL) AND ( l_srp_end_date IS NOT NULL)
   	              AND(
   	              ( (p_start_date NOT BETWEEN l_srp_start_date AND l_srp_end_date)AND ((p_end_date IS  NULL) OR (p_end_date > l_srp_end_date)))
   	              OR (p_start_date NOT BETWEEN l_srp_start_date AND l_srp_end_date)
   	              OR  ((p_end_date IS  NULL) OR (p_end_date > l_srp_end_date))
   	               )
   	           )--End of first condition in IF

   	      OR  (
   	           ( l_srp_start_date IS NOT NULL) AND ( l_srp_end_date IS NULL) AND
   	           (p_start_date < l_srp_start_date )
   	           ) --ENd of 2nd condition in IF

       ) --  end of IF

         THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
   	 FND_MESSAGE.SET_NAME ('CN' , 'CN_SPP_PG_PRDS_NI_SRP_PRDS');
   	 FND_MSG_PUB.Add;
         END IF;
         x_loading_status := 'CN_SPP_PG_PRDS_NI_SRP_PRDS';
         RAISE FND_API.G_EXC_ERROR ;
      END IF;


   --
      -- Validate Rule :Start  or end date is outside of the processing
      -- period range define in payment plan definition
      --
      -- Oct 26 1999 ACHUNG
      -- Change: srp_pmt_plan.end_date not forced.
      -- if srp_pmt_plan.end_date is null, no need to check between srp and pmt
      -- start date/end date range
      --

      SELECT start_date, end_date
        INTO l_pp_start_date, l_pp_end_date
        FROM cn_pay_groups_all
       WHERE pay_group_id = p_pay_group_id;
      IF (   (
              ( l_pp_start_date IS NOT NULL) AND ( l_pp_end_date IS NOT NULL)
                AND(
                ( (p_start_date NOT BETWEEN l_pp_start_date AND l_pp_end_date)AND ((p_end_date  IS NULL)OR (p_end_date > l_pp_end_date)))
                OR (p_start_date NOT BETWEEN l_pp_start_date AND l_pp_end_date)
                OR  ((p_end_date IS NULL) OR (p_end_date > l_pp_end_date))
                 )
             )--End of first condition in IF

        OR  (
             ( l_pp_start_date IS NOT NULL) AND ( l_pp_end_date IS NULL) AND
             (p_start_date < l_pp_start_date)
             ) --ENd of 2nd condition in IF

       ) --  end of IF


        THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
   	 FND_MESSAGE.SET_NAME ('CN' , 'CN_SPP_PRDS_NI_PAY_GRP_PRDS');
   	 FND_MSG_PUB.Add;
         END IF;
         x_loading_status := 'CN_SPP_PRDS_NI_PAY_GRP_PRDS';
         RAISE FND_API.G_EXC_ERROR ;
   END IF;

   --
   -- Check if the current assignment dates do not fit within the effectivity of the
   -- pay group.
   --
   SELECT COUNT(1)
     INTO l_count
     FROM cn_pay_groups_all
     WHERE (( p_start_date NOT BETWEEN start_date AND end_date )
	    OR  (p_end_date NOT BETWEEN start_date AND end_date))
     AND pay_group_id = p_pay_group_id;

   IF l_count <> 0
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN
         fnd_message.set_name('CN', 'CN_INVALID_SRP_PGRP_ASGN_DT');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_SRP_PGRP_ASGN_DT';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --
   -- Check for overlapping assignments
   --
   SELECT count(1)
     INTO l_count
     FROM cn_srp_pay_groups_all
     WHERE p_start_date between start_date AND Nvl(end_date, p_start_date)
     AND salesrep_id = p_salesrep_id
     AND org_id      = p_org_id
     AND srp_pay_group_id <> p_srp_pay_group_id;

   IF l_count <> 0
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN
         fnd_message.set_name('CN', 'CN_OVERLAP_SRP_PGRP_ASGN');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_OVERLAP_SRP_PGRP_ASGN';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   SELECT count(1)
     INTO l_count
     FROM cn_srp_pay_groups_all
     WHERE Nvl(p_end_date, l_null_date) between start_date
     AND Nvl(end_date, Nvl(p_end_date, l_null_date))
     AND salesrep_id = p_salesrep_id
     AND org_id      = p_org_id
     AND srp_pay_group_id <> p_srp_pay_group_id;


   IF l_count <> 0
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
         fnd_message.set_name('CN', 'CN_OVERLAP_SRP_PGRP_ASGN');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_OVERLAP_SRP_PGRP_ASGN';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   SELECT count(1)
     INTO l_count
     FROM cn_srp_pay_groups_all
     WHERE salesrep_id = p_salesrep_id
     AND org_id        = p_org_id
     AND p_start_date <= start_date
     AND Nvl(p_end_date, l_null_date) >= Nvl(end_date, l_null_date)
     AND srp_pay_group_id <> p_srp_pay_group_id;


   IF l_count <> 0
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN
         fnd_message.set_name('CN', 'CN_OVERLAP_SRP_PGRP_ASGN');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_OVERLAP_SRP_PGRP_ASGN';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- End of Validate Assignment
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;

END Validate_Assignment;


-----------------------------------------------------------------------+
-- Procedure   : Validate_end_date
-- Description : Procedure to validate that the end date coincides with
--               the end date of a pay period
-----------------------------------------------------------------------+

PROCEDURE Validate_end_date
  (
   x_return_status	    OUT NOCOPY VARCHAR2 ,
   x_msg_count		    OUT NOCOPY NUMBER	 ,
   x_msg_data		    OUT NOCOPY VARCHAR2,
   p_salesrep_id            IN NUMBER,
   p_org_id                 IN NUMBER,
   p_assign_end_date	    IN DATE,
   p_loading_status         IN VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2,
   x_status		    OUT NOCOPY VARCHAR2
   ) IS

      l_count		   NUMBER       := 0;
      l_count2             NUMBER       := 0;
      l_api_name  CONSTANT VARCHAR2(30) := 'Validate_end_date';



BEGIN

   --
   --  Initialize API return status to success
   --
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status ;


   /* cn_posting_details is obsolete - we now validate against pmt worksheets

   -- Added new checking logic below
   -- Check if any of the periods after this new assignment end date has been used
   -- in cn_posting_details, if so error.
   BEGIN
     select 1 into l_count from dual where not exists
       (select 1 from cn_srp_periods_all csp, cn_posting_details_sum_all cpd
	 where cpd.credited_salesrep_id = p_salesrep_id
	   AND cpd.org_id               = p_org_id
	   AND cpd.pay_period_id = csp.period_id
   	   AND csp.salesrep_id = cpd.credited_salesrep_id
	   AND csp.end_date > p_assign_end_date);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
           FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_PGRP_ASGN_END_DT');
           FND_MSG_PUB.Add;
         END IF;
       x_loading_status := 'CN_INVALID_PGRP_ASGN_END_DT';
       RAISE FND_API.G_EXC_ERROR ;
     END;
     */


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;

END Validate_end_date;



-- --------------------------------------------------------------------------*
-- Procedure: srp_plan_assignment_for_delete
-- --------------------------------------------------------------------------*
PROCEDURE srp_plan_assignment_for_delete
  (p_role_id        IN cn_roles.role_id%TYPE,
   p_role_plan_id   IN cn_role_plans.role_plan_id%TYPE,
   p_salesrep_id    IN cn_salesreps.salesrep_id%TYPE,
   p_org_id         IN cn_salesreps.org_id%TYPE,
   x_return_status  OUT NOCOPY VARCHAR2,
   p_loading_status IN  VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2 ) IS

      CURSOR l_cur IS
	 SELECT srp_role_id
	   FROM cn_srp_roles
	   WHERE role_id = p_role_id
	   and salesrep_id =p_salesrep_id
	   AND org_id = p_org_id;


      l_rec l_cur%ROWTYPE;

      l_return_status      VARCHAR2(2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_plan_assign_id   cn_srp_plan_assigns.srp_plan_assign_id%TYPE;
      l_loading_status       VARCHAR2(2000);

BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   FOR l_rec IN l_cur
     LOOP

	cn_srp_plan_assigns_pvt.delete_srp_plan_assigns
	  (
	   p_api_version        => 1.0,
	   x_return_status      => l_return_status,
	   x_msg_count          => l_msg_count,
	   x_msg_data           => l_msg_data,
	   p_srp_role_id        => l_rec.srp_role_id,
	   p_role_plan_id       => p_role_plan_id,
	   x_loading_status     => l_loading_status);

	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	   x_return_status     := l_return_status;
	   x_loading_status    := l_loading_status;
	   EXIT;
	END IF;

     END LOOP;
END srp_plan_assignment_for_delete;


PROCEDURE business_event
  (p_operation            IN VARCHAR2,
   p_paygroup_assign_rec  IN paygroup_assign_rec) IS

   l_key        VARCHAR2(80);
   l_event_name VARCHAR2(80);
   l_list       wf_parameter_list_t;
BEGIN
   -- p_operation = Add, Update, Remove
   l_event_name := 'oracle.apps.cn.resource.PayGroupAssign.' || p_operation;

   --Get the item key
   -- for create - event_name || srp_paygroup_id
   -- for update - event_name || srp_paygroup_id || ovn
   -- for delete - event_name || srp_paygroup_id
   l_key := l_event_name || '-' || p_paygroup_assign_rec.srp_pay_group_id;

   -- build parameter list as appropriate
   IF (p_operation = 'Add') THEN
      wf_event.AddParameterToList('SALESREP_ID',p_paygroup_assign_rec.salesrep_id,l_list);
      wf_event.AddParameterToList('PAY_GROUP_ID',p_paygroup_assign_rec.pay_group_id,l_list);
      wf_event.AddParameterToList('START_DATE',p_paygroup_assign_rec.assignment_start_date,l_list);
      wf_event.AddParameterToList('END_DATE',p_paygroup_assign_rec.assignment_end_date,l_list);
      wf_event.AddParameterToList('LOCK_FLAG',p_paygroup_assign_rec.lock_flag,l_list);
    ELSIF (p_operation = 'Update') THEN
      l_key := l_key || '-' || p_paygroup_assign_rec.object_version_number;
      wf_event.AddParameterToList('SRP_PAY_GROUP_ID',p_paygroup_assign_rec.srp_pay_group_id,l_list);
      wf_event.AddParameterToList('SALESREP_ID',p_paygroup_assign_rec.salesrep_id,l_list);
      wf_event.AddParameterToList('PAY_GROUP_ID',p_paygroup_assign_rec.pay_group_id,l_list);
      wf_event.AddParameterToList('START_DATE',p_paygroup_assign_rec.assignment_start_date,l_list);
      wf_event.AddParameterToList('END_DATE',p_paygroup_assign_rec.assignment_end_date,l_list);
      wf_event.AddParameterToList('LOCK_FLAG',p_paygroup_assign_rec.lock_flag,l_list);
    ELSIF (p_operation = 'Remove') THEN
      wf_event.AddParameterToList('SRP_PAY_GROUP_ID',p_paygroup_assign_rec.srp_pay_group_id,l_list);
   END IF;

   -- Raise Event
   wf_event.raise
     (p_event_name        => l_event_name,
      p_event_key         => l_key,
      p_parameters        => l_list);

   l_list.DELETE;
END business_event;


-- --------------------------------------------------------------------------*
-- Procedure: Create_Srp_Pay_Group
-- --------------------------------------------------------------------------*
PROCEDURE Create_Srp_Pay_Group
  (  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2,
	p_commit	    	   IN  	VARCHAR2,
	p_validation_level	   IN  	NUMBER,
	x_return_status		   OUT NOCOPY	VARCHAR2		      ,
	x_loading_status           OUT NOCOPY  VARCHAR2 	              ,
	x_msg_count		   OUT NOCOPY	NUMBER			      ,
	x_msg_data		   OUT NOCOPY	VARCHAR2                      ,
        p_paygroup_assign_rec      IN OUT NOCOPY PayGroup_assign_rec
 	) IS

      l_api_name		   CONSTANT VARCHAR2(30) := 'Create_Srp_Pay_Group';
      l_api_version           	   CONSTANT NUMBER  := 1.0;
      l_srp_pay_group_id        cn_srp_pay_groups.srp_pay_group_id%TYPE;
      l_role_id                 cn_roles.role_id%TYPE;
      l_loading_status VARCHAR2(2000);
      l_null_date          CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');
      l_status             VARCHAR2(30);
      l_employee_number    cn_salesreps.employee_number%TYPE;
      l_employee_name      cn_salesreps.name%TYPE;
      l_pay_group_name     cn_pay_groups.name%TYPE;

      CURSOR get_roles (p_salesrep_id NUMBER) IS
      SELECT role_id, srp_role_id,start_date, nvl(end_date,l_null_date) end_date
	FROM cn_srp_roles
	WHERE salesrep_id = p_salesrep_id
	  AND org_id      = p_paygroup_assign_rec.org_id;

   CURSOR get_role_plans(p_role_id NUMBER) IS
      SELECT role_plan_id
        FROM cn_role_plans
        WHERE role_id = p_role_id
	  AND org_id = p_paygroup_assign_rec.org_id;

   CURSOR get_plan_assigns
     (p_role_id NUMBER,
      p_salesrep_id NUMBER) IS
	 SELECT comp_plan_id,
	   start_date,
	   end_date
	   FROM cn_srp_plan_assigns_all
	   WHERE role_id = p_role_id
	   AND salesrep_id = p_salesrep_id
	   AND org_id = p_paygroup_assign_rec.org_id;

BEGIN
   -- Standard Start of API savepoint

   SAVEPOINT	Create_Srp_Pay_Group;

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_CREATED';

   SELECT cn_srp_pay_groups_s.NEXTVAL
     INTO l_srp_pay_group_id
     FROM dual;

   Validate_assignment
     (x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_salesrep_id     => p_paygroup_assign_rec.salesrep_id,
      p_org_id          => p_paygroup_assign_rec.org_id,
      p_start_date      => p_paygroup_assign_rec.assignment_start_date,
      p_end_date        => p_paygroup_assign_rec.assignment_end_date,
      p_pay_group_id    => p_paygroup_assign_rec.pay_group_id,
      p_srp_pay_group_id=> l_srp_pay_group_id,
      p_loading_status  => x_loading_status,
      x_loading_status  => x_loading_status,
      x_status          => l_status );

   SELECT name, employee_number
     INTO l_employee_name, l_employee_number
     FROM cn_salesreps
    WHERE salesrep_id = p_paygroup_assign_rec.salesrep_id
      AND org_id      = p_paygroup_assign_rec.org_id;

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF x_loading_status = 'CN_INVALID_SRP_PGRP_ASGN_DT'
      THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_SRP_PGRP_ASGN_DT');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_SRP_PGRP_ASGN_DT';
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_loading_status = 'CN_OVERLAP_SRP_PGRP_ASGN'
      THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_OVERLAP_SRP_PGRP_ASGN');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_OVERLAP_SRP_PGRP_ASGN';
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( x_return_status = FND_API.G_RET_STS_SUCCESS )
      THEN

      Validate_end_date
	(x_return_status   => x_return_status,
	 x_msg_count       => x_msg_count,
	 x_msg_data        => x_msg_data,
	 p_salesrep_id     => p_paygroup_assign_rec.salesrep_id,
	 p_org_id          => p_paygroup_assign_rec.org_id,
	 p_assign_end_date => p_paygroup_assign_rec.assignment_end_date,
	 p_loading_status  => x_loading_status,
	 x_loading_status  => x_loading_status,
	 x_status          => l_status );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
         THEN
         RAISE FND_API.G_EXC_ERROR ;
      END IF;

      -- ready to insert
      CN_SRP_Pay_Groups_Pkg.Begin_Record(
        x_operation         => 'INSERT',
	x_srp_pay_group_id  => l_srp_pay_group_id,
	x_salesrep_id       => p_paygroup_assign_rec.salesrep_id,
	x_pay_group_id      => p_paygroup_assign_rec.pay_group_id,
	x_start_date        => p_paygroup_assign_rec.assignment_start_date,
	x_end_date          => p_paygroup_assign_rec.assignment_end_date,
	x_lock_flag         => p_paygroup_assign_rec.lock_flag,
        x_role_pay_group_id => p_paygroup_assign_rec.role_pay_group_id,
	x_org_id            => p_paygroup_assign_rec.org_id,
	x_attribute_category=> p_paygroup_assign_rec.attribute_category,
	x_attribute1        => p_paygroup_assign_rec.attribute1,
	x_attribute2        => p_paygroup_assign_rec.attribute2,
	x_attribute3        => p_paygroup_assign_rec.attribute3,
	x_attribute4        => p_paygroup_assign_rec.attribute4,
	x_attribute5        => p_paygroup_assign_rec.attribute5,
	x_attribute6        => p_paygroup_assign_rec.attribute6,
	x_attribute7        => p_paygroup_assign_rec.attribute7,
	x_attribute8        => p_paygroup_assign_rec.attribute8,
	x_attribute9        => p_paygroup_assign_rec.attribute9,
	x_attribute10       => p_paygroup_assign_rec.attribute10,
	x_attribute11       => p_paygroup_assign_rec.attribute10,
	x_attribute12       => p_paygroup_assign_rec.attribute12,
	x_attribute13       => p_paygroup_assign_rec.attribute13,
	x_attribute14       => p_paygroup_assign_rec.attribute14,
	x_attribute15       => p_paygroup_assign_rec.attribute15,
	x_last_update_date  => Sysdate,
	x_last_updated_by   => fnd_global.user_id,
	x_creation_date     => Sysdate,
	x_created_by        => fnd_global.user_id,
	x_last_update_login => fnd_global.login_id,
    x_object_version_number => p_paygroup_assign_rec.object_version_number);

      p_paygroup_assign_rec.srp_pay_group_id := l_srp_pay_group_id;

      -- raise business event
      business_event
	(p_operation              => 'Add',
	 p_paygroup_assign_rec    => p_paygroup_assign_rec);


    else
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_SRP_PAY_GROUPS_EXIST');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SRP_PAY_GROUPS_EXIST';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;


   -- Call cn_srp_periods_pvt api to affect the records in cn_srp_periods
   FOR roles  IN get_roles(p_paygroup_assign_rec.salesrep_id)
     LOOP
	--Added by Zack  1/15/02 to populate cn_srp_plan_assigns
	IF ((roles.start_date <= p_paygroup_assign_rec.assignment_start_date
          AND nvl(roles.end_date,l_null_date) >= p_paygroup_assign_rec.assignment_start_date)
        OR (roles.start_date <= nvl(p_paygroup_assign_rec.assignment_end_date,l_null_date)
          AND nvl(roles.end_date,l_null_date) >= nvl(p_paygroup_assign_rec.assignment_end_date,l_null_date))
        OR (p_paygroup_assign_rec.assignment_start_date <= nvl(roles.end_date, l_null_date)
          AND nvl(p_paygroup_assign_rec.assignment_end_date,l_null_date) >= nvl(roles.end_date, l_null_date))
        OR (p_paygroup_assign_rec.assignment_start_date <= roles.start_date
          AND nvl(p_paygroup_assign_rec.assignment_end_date,l_null_date) >= roles.start_date)
     ) THEN

	   FOR role_plans IN get_role_plans(roles.role_id) LOOP
	      cn_srp_plan_assigns_pvt.Update_Srp_Plan_Assigns
		(p_api_version   => 1.0,
		 x_return_status => x_return_status,
		 x_msg_count	 => x_msg_count,
		 x_msg_data	 => x_msg_data,
		 p_srp_role_id   => roles.srp_role_id,
		 p_role_plan_id  => role_plans.role_plan_id,
		 x_loading_status => x_loading_status );

	      IF ( x_return_status = FND_API.G_RET_STS_ERROR) THEN
		 RAISE FND_API.G_EXC_ERROR;
	       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	      END IF;

	      -- clku bug 2758073
	      -- mark event for intel calc, when new plan assignement is populated
	      -- after paygroup is assigned

	      select name
		into l_pay_group_name
		from cn_pay_groups_all
		where pay_group_id = p_paygroup_assign_rec.pay_group_id;

	      cn_mark_events_pkg.mark_event_srp_pay_group
		('CHANGE_SRP_PAY_GROUP', -- event name
		 l_pay_group_name,            -- object name
		 p_paygroup_assign_rec.pay_group_id,           -- object id
		 p_paygroup_assign_rec.salesrep_id,          -- srp_object_id
		 null,                   -- start date
		 p_paygroup_assign_rec.assignment_start_date,        -- start date old
		 null,                   -- end date
		 p_paygroup_assign_rec.assignment_end_date,
		 p_paygroup_assign_rec.org_id);         -- org ID
	   END LOOP;
	END IF;

	FOR plans IN get_plan_assigns(roles.role_id, p_paygroup_assign_rec.salesrep_id)
	  LOOP
	     -- Added by Zack, check the start_date and end_date of plan assignment, populate the intersection
	     -- part with the pay group assignment date.

	     IF nvl(plans.end_date,l_null_date) > nvl(p_paygroup_assign_rec.assignment_end_date,l_null_date) THEN
		plans.end_date := p_paygroup_assign_rec.assignment_end_date;
	     END IF;

	     IF plans.start_date < p_paygroup_assign_rec.assignment_start_date THEN
		plans.start_date := p_paygroup_assign_rec.assignment_start_date;
	     END IF;

	     IF nvl(plans.end_date, l_null_date) > plans.start_date THEN

		cn_srp_periods_pvt.create_srp_periods
		  ( p_api_version     => p_api_version,
		    x_return_status   => x_return_status,
		    x_msg_count       => x_msg_count,
		    x_msg_data        => x_msg_data,
		    p_salesrep_id     => p_paygroup_assign_rec.salesrep_id,
		    p_role_id         => roles.role_id,
		    p_comp_plan_id    => plans.comp_plan_id,
		    p_start_date      => plans.start_date,
		    p_end_date        => plans.end_date,
		    x_loading_status  => x_loading_status);
		IF ( x_return_status = FND_API.G_RET_STS_ERROR )
		  THEN
		   RAISE FND_API.G_EXC_ERROR;
		 ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
		   THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

	     END IF;
	  END LOOP;
     END LOOP;

     -- End of API body

     -- Standard check of p_commit.

     IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info
     FND_MSG_PUB.Count_And_Get
       (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Srp_Pay_Group;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    (
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Srp_Pay_Group;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Srp_Pay_Group;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END create_srp_pay_group;


-- --------------------------------------------------------------------------*
-- Procedure: Update_Srp_Pay_Group
-- --------------------------------------------------------------------------*
PROCEDURE Update_Srp_Pay_Group
  (  	p_api_version              IN	NUMBER				      ,
     	p_init_msg_list		   IN	VARCHAR2,
  	p_commit	    	   IN  	VARCHAR2,
  	p_validation_level	   IN  	NUMBER,
  	x_return_status		   OUT NOCOPY	VARCHAR2	     	      ,
  	x_loading_status           OUT NOCOPY  VARCHAR2                       ,
  	x_msg_count		   OUT NOCOPY	NUMBER			      ,
  	x_msg_data		   OUT NOCOPY	VARCHAR2                      ,
	p_paygroup_assign_rec      IN OUT NOCOPY  PayGroup_assign_rec
  	) IS

   l_api_name		   CONSTANT VARCHAR2(30) := 'Update_Srp_Pay_Group';
   l_api_version      	   CONSTANT NUMBER  := 1.0;
   l_null_date             CONSTANT DATE := to_date('31-12-9999','DD-MM-YYYY');

   CURSOR get_roles (p_salesrep_id NUMBER) IS
      SELECT role_id,srp_role_id,start_date, nvl(end_date,l_null_date) end_date
	FROM cn_srp_roles
	WHERE salesrep_id = p_salesrep_id
	  AND org_id      = p_paygroup_assign_rec.org_id;

   CURSOR get_role_plans(p_role_id NUMBER) IS
      SELECT role_plan_id
        FROM cn_role_plans_all
       WHERE role_id = p_role_id
	 AND org_id = p_paygroup_assign_rec.org_id;

   CURSOR get_plan_assigns
     (p_role_id NUMBER,
      p_salesrep_id NUMBER) IS
	 SELECT comp_plan_id,
	   start_date,
	   end_date
	   FROM cn_srp_plan_assigns_all
	   WHERE role_id = p_role_id
	   AND salesrep_id = p_salesrep_id
	   AND org_id = p_paygroup_assign_rec.org_id;

   -- clku
   CURSOR payee_check_curs(l_salesrep_id NUMBER) IS
      select srp_role_id from cn_srp_roles where
	salesrep_id = l_salesrep_id
	and role_id = 54
	AND org_id = p_paygroup_assign_rec.org_id;

   CURSOR payee_assign_date_curs(l_payee_id NUMBER) IS
      select salesrep_id, start_date, end_date
	from cn_srp_payee_assigns_all
	where payee_id = l_payee_id
	AND org_id = p_paygroup_assign_rec.org_id;

   l_payee_assign_date_rec    payee_assign_date_curs%ROWTYPE;
   l_ws_count NUMBER;

   l_date_range_action_tbl     cn_api.date_range_action_tbl_type;
   l_ovn_old                   NUMBER;
   l_old_assignment_start_date DATE;
   l_old_assignment_end_date   DATE;
   l_old_salesrep_id           NUMBER;
   l_old_lock_flag             VARCHAR2(1);
   l_status                    VARCHAR2(30);
   l_employee_number           cn_salesreps.employee_number%TYPE;
   l_employee_name             cn_salesreps.name%TYPE;
   l_pay_group_name            cn_pay_groups.name%TYPE;
   l_dummy                     NUMBER;
   l_srp_role_id               NUMBER;



BEGIN
   -- Standard Start of API savepoint

   SAVEPOINT	Update_Srp_Pay_Group;

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';


   -- get the current object version number
   select object_version_number, salesrep_id, start_date, end_date, lock_flag
     into l_ovn_old, l_old_salesrep_id,
          l_old_assignment_start_date, l_old_assignment_end_date, l_old_lock_flag
     from cn_srp_pay_groups_all
     where srp_pay_group_id = p_paygroup_assign_rec.srp_pay_group_id;

   IF l_ovn_old <> p_paygroup_assign_rec.object_version_number THEN
      --
      --Raise an error if the object_version numbers don't match
      --
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CL_INVALID_OVN');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CL_INVALID_OVN';
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_paygroup_assign_rec.salesrep_id <> l_old_salesrep_id
      THEN
       --
       --Raise an error since the salesrep should not be updated
       --Instead, the assignment dates should be changed to reflect this.
       --
       IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	 THEN
	 fnd_message.set_name('CN', 'CN_INVALID_UPD_SRP_PGRP');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_UPD_SRP_PGRP';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- can't change lock flag from Y to N
   IF l_old_lock_flag = 'Y' AND p_paygroup_assign_rec.lock_flag = 'N' THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_CANNOT_UPDATE_LOCK');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_CANNOT_UPDATE_LOCK';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- can't change lock from N to Y if it is manual assignment
   IF l_old_lock_flag = 'N' AND p_paygroup_assign_rec.lock_flag = 'Y' AND
     p_paygroup_assign_rec.role_pay_group_id IS NULL THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_CANNOT_UPDATE_LOCK');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_CANNOT_UPDATE_LOCK';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   Validate_assignment
     (x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_salesrep_id     => p_paygroup_assign_rec.salesrep_id,
      p_org_id          => p_paygroup_assign_rec.org_id,
      p_start_date      => p_paygroup_assign_rec.assignment_start_date,
      p_end_date        => p_paygroup_assign_rec.assignment_end_date,
      p_pay_group_id    => p_paygroup_assign_rec.pay_group_id,
      p_srp_pay_group_id => p_paygroup_assign_rec.srp_pay_group_id,
      p_loading_status  => x_loading_status,
      x_loading_status  => x_loading_status,
      x_status          => l_status );

   SELECT name, employee_number
     INTO l_employee_name, l_employee_number
     FROM cn_salesreps
    WHERE salesrep_id = p_paygroup_assign_rec.salesrep_id
      AND org_id      = p_paygroup_assign_rec.org_id;

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF x_loading_status = 'CN_INVALID_SRP_PGRP_ASGN_DT'
      THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_SRP_PGRP_ASGN_DT');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_SRP_PGRP_ASGN_DT';
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_loading_status = 'CN_OVERLAP_SRP_PGRP_ASGN'
      THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_OVERLAP_SRP_PGRP_ASGN');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_OVERLAP_SRP_PGRP_ASGN';
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( x_return_status = FND_API.G_RET_STS_SUCCESS )
      THEN

      Validate_end_date
	(x_return_status   => x_return_status,
	 x_msg_count       => x_msg_count,
	 x_msg_data        => x_msg_data,
	 p_salesrep_id     => p_paygroup_assign_rec.salesrep_id,
	 p_org_id          => p_paygroup_assign_rec.org_id,
	 p_assign_end_date => p_paygroup_assign_rec.assignment_end_date,
	 p_loading_status  => x_loading_status,
	 x_loading_status  => x_loading_status,
	 x_status          => l_status );


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
         RAISE FND_API.G_EXC_ERROR ;
      END IF;

      --clku, payee check enhancement
      OPEN payee_check_curs(p_paygroup_assign_rec.salesrep_id);
      Fetch payee_check_curs into l_srp_role_id;
      IF payee_check_curs%FOUND THEN
	 cn_api.get_date_range_diff_action
	   (  start_date_new    => p_paygroup_assign_rec.assignment_start_date
	      ,end_date_new     => p_paygroup_assign_rec.assignment_end_date
	      ,start_date_old   => l_old_assignment_start_date
	      ,end_date_old     => l_old_assignment_end_date
	      ,x_date_range_action_tbl => l_date_range_action_tbl  );

	 FOR i IN 1..l_date_range_action_tbl.COUNT LOOP
	    if l_date_range_action_tbl(i).action_flag = 'D' THEN

	       -- check if there is any salesrep having this payee assigned within
	       -- the deleting paygroup date range
	       For l_payee_assign_date_rec IN payee_assign_date_curs
		 (p_paygroup_assign_rec.salesrep_id) LOOP
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

		     x_loading_status := 'CN_PA_ASGN_DATE';
		     RAISE FND_API.G_EXC_ERROR;


		  END IF;
	       END LOOP;

	       -- check if the payee has any worksheet
	       SELECT count(*)
		 into l_ws_count
		 FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,
		      cn_payruns_all prun
		 WHERE w.salesrep_id      = p_paygroup_assign_rec.salesrep_id
		 AND   w.org_id           = p_paygroup_assign_rec.org_id
		 AND   prun.pay_period_id = prd.period_id
		 AND   prun.payrun_id     = w.payrun_id
		 AND   prd.org_id         = p_paygroup_assign_rec.org_id
		 AND   prun.pay_group_id  = p_paygroup_assign_rec.pay_group_id
		 AND   w.quota_id is null
		   AND (
			(prd.start_date BETWEEN l_date_range_action_tbl(i).start_date
			 AND nvl(l_date_range_action_tbl(i).end_date,l_null_date))
			OR
			(prd.end_date between l_date_range_action_tbl(i).start_date
			 AND nvl(l_date_range_action_tbl(i).end_date,l_null_date))
			);

		 IF l_ws_count > 0 THEN
		    -- Raise Error
		    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                      THEN
		       fnd_message.set_name('CN', 'CN_SRP_PG_WS');
		       fnd_msg_pub.add;
		    END IF;

		    x_loading_status := 'CN_SRP_PG_WS';
		    RAISE FND_API.G_EXC_ERROR;
		 END IF;

	    END IF; --if l_date_range_action_tbl(i).action_flag = 'D'
	 END LOOP;  -- FOR i IN 1..l_date_range_action_tbl.COUNT LOOP
      END IF; -- if salesrep is payee

      Close payee_check_curs;


      --***********************************************************************
      -- Added By Zack Li, fixed by Matt Blum
      -- Date 02/14/06
      --
      -- Shorten the end_date assignment
      -- Check for the shortened date range, if worksheet already been used,
      -- if so, cannot shorten
      --***********************************************************************

      IF ( ((l_old_assignment_end_date IS NOT NULL) AND
	    (p_paygroup_assign_rec.assignment_end_date IS NOT NULL) AND
            (l_old_assignment_end_date > p_paygroup_assign_rec.assignment_end_date))
           OR
           ((l_old_assignment_end_date IS NULL) AND
	    (p_paygroup_assign_rec.assignment_end_date IS NOT NULL)) ) THEN
         SELECT count(1) INTO l_dummy
            FROM  cn_payment_worksheets W, cn_period_statuses prd, cn_payruns prun
            WHERE w.salesrep_id      = p_paygroup_assign_rec.salesrep_id
	    AND   w.org_id           = p_paygroup_assign_rec.org_id
	    AND   prun.pay_period_id = prd.period_id
	    AND   prd.org_id         = p_paygroup_assign_rec.org_id
            AND   prun.payrun_id     = w.payrun_id
            AND  greatest(prd.start_date, p_paygroup_assign_rec.assignment_end_date) <
                 least(prd.end_date, nvl(l_old_assignment_end_date, prd.end_date));

          if l_dummy > 0 then
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.SET_NAME ('CN' , 'CN_SPG_CANNOT_SHORTEN_ED');
                 FND_MSG_PUB.Add;
              END IF;
              x_loading_status := 'CN_SPG_CANNOT_SHORTEN_ED';
              RAISE FND_API.G_EXC_ERROR ;
          end if;

       END IF ; -- end IF end date change

      -- Check if during the old date range assign, any worksheet already
      -- been used, if so, cannot shrink start_date. If not been used, start
      -- date can be extend or shrink.

      IF l_old_assignment_start_date < p_paygroup_assign_rec.assignment_start_date THEN
         SELECT count(1) INTO l_dummy
           FROM cn_payment_worksheets W, cn_period_statuses prd, cn_payruns prun
            WHERE w.salesrep_id      = p_paygroup_assign_rec.salesrep_id
	    AND   w.org_id           = p_paygroup_assign_rec.org_id
	    AND   prun.pay_period_id = prd.period_id
	    AND   prd.org_id         = p_paygroup_assign_rec.org_id
            AND   prun.payrun_id     = w.payrun_id
            AND  greatest(prd.start_date, l_old_assignment_start_date) <
                 least(prd.end_date, p_paygroup_assign_rec.assignment_start_date);

          if l_dummy > 0 then
               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN
                  FND_MESSAGE.SET_NAME ('CN' , 'CN_SPG_UPDATE_NOT_ALLOWED');
                  FND_MSG_PUB.Add;
               END IF;
               x_loading_status := 'CN_SPG_UPDATE_NOT_ALLOWED';
               RAISE FND_API.G_EXC_ERROR ;
         END if;

      END IF ; -- end IF start date change

      -- if the lock_flag is being set, then blow away role_pay_group_id
      IF p_paygroup_assign_rec.lock_flag = 'Y' THEN
	 p_paygroup_assign_rec.role_pay_group_id := NULL;
      END IF;

      CN_SRP_Pay_Groups_Pkg.Begin_Record(
	x_operation         => 'UPDATE',
	x_srp_pay_group_id  => p_paygroup_assign_rec.srp_pay_group_id,
	x_salesrep_id       => p_paygroup_assign_rec.salesrep_id,
	x_pay_group_id      => p_paygroup_assign_rec.pay_group_id,
	x_start_date        => p_paygroup_assign_rec.assignment_start_date,
	x_end_date          => p_paygroup_assign_rec.assignment_end_date,
	x_lock_flag         => p_paygroup_assign_rec.lock_flag,
        x_role_pay_group_id => p_paygroup_assign_rec.role_pay_group_id,
	x_org_id            => p_paygroup_assign_rec.org_id,
	x_attribute_category=> p_paygroup_assign_rec.attribute_category,
	x_attribute1        => p_paygroup_assign_rec.attribute1,
	x_attribute2        => p_paygroup_assign_rec.attribute2,
	x_attribute3        => p_paygroup_assign_rec.attribute3,
	x_attribute4        => p_paygroup_assign_rec.attribute4,
	x_attribute5        => p_paygroup_assign_rec.attribute5,
	x_attribute6        => p_paygroup_assign_rec.attribute6,
	x_attribute7        => p_paygroup_assign_rec.attribute7,
	x_attribute8        => p_paygroup_assign_rec.attribute8,
	x_attribute9        => p_paygroup_assign_rec.attribute9,
	x_attribute10       => p_paygroup_assign_rec.attribute10,
	x_attribute11       => p_paygroup_assign_rec.attribute10,
	x_attribute12       => p_paygroup_assign_rec.attribute12,
	x_attribute13       => p_paygroup_assign_rec.attribute13,
	x_attribute14       => p_paygroup_assign_rec.attribute14,
	x_attribute15       => p_paygroup_assign_rec.attribute15,
	x_last_update_date  => Sysdate,
	x_last_updated_by   => fnd_global.user_id,
	x_creation_date     => Sysdate,
	x_created_by        => fnd_global.user_id,
	x_last_update_login => fnd_global.login_id,
    x_object_version_number => p_paygroup_assign_rec.object_version_number);

      -- raise business event
      business_event
	(p_operation              => 'Update',
	 p_paygroup_assign_rec    => p_paygroup_assign_rec);

   END IF; -- if validate success

   -- Call cn_srp_periods_pvt api to affect the records in cn_srp_periods
   FOR roles  IN get_roles(p_paygroup_assign_rec.salesrep_id)
     LOOP

	-- Added by Zack 01/15/02, update cn_srp_plan_assign if necessary.
	-- clku, bug 2772005, nvl the end dates here
	IF(
	    (p_paygroup_assign_rec.assignment_start_date <> l_old_assignment_start_date )
	    AND
	    ( (roles.start_date <= least(p_paygroup_assign_rec.assignment_start_date, l_old_assignment_start_date)
	       AND roles.end_date >= least(p_paygroup_assign_rec.assignment_start_date, l_old_assignment_start_date) )
	      OR
	      (roles.start_date <= greatest(p_paygroup_assign_rec.assignment_start_date, l_old_assignment_start_date)
	       AND roles.end_date >= greatest(p_paygroup_assign_rec.assignment_start_date, l_old_assignment_start_date) ) )
            OR
	    (nvl(p_paygroup_assign_rec.assignment_end_date, l_null_date) <> nvl(l_old_assignment_end_date, l_null_date) )
	    AND
	    ( (roles.start_date <= least(nvl(p_paygroup_assign_rec.assignment_end_date, l_null_date), nvl(l_old_assignment_end_date, l_null_date))
	       AND roles.end_date >= least(nvl(p_paygroup_assign_rec.assignment_end_date, l_null_date), nvl(l_old_assignment_end_date, l_null_date)) )
	      OR
	      (roles.start_date <= greatest(nvl(p_paygroup_assign_rec.assignment_end_date, l_null_date), nvl(l_old_assignment_end_date, l_null_date))
	       AND roles.end_date >= greatest(nvl(p_paygroup_assign_rec.assignment_end_date, l_null_date), nvl(l_old_assignment_end_date, l_null_date)) ) )
	  ) THEN
	   FOR role_plans IN get_role_plans(roles.role_id) LOOP
	      cn_srp_plan_assigns_pvt.Update_Srp_Plan_Assigns
                (
                 p_api_version    => 1.0,
                 x_return_status => x_return_status,
                 x_msg_count	 => x_msg_count,
                 x_msg_data	 => x_msg_data,
                 p_srp_role_id   => roles.srp_role_id,
                 p_role_plan_id  => role_plans.role_plan_id,
                 x_loading_status  => x_loading_status );

	      IF ( x_return_status = FND_API.G_RET_STS_ERROR) THEN
		 RAISE FND_API.G_EXC_ERROR;
	       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	      END IF;

	      -- clku bug 2758073
	      -- mark event for intel calc, when plan assignement's date
	      -- range change as a result of the paygroup daterange change

	      select name
		into l_pay_group_name
		from cn_pay_groups_all
		where pay_group_id = p_paygroup_assign_rec.pay_group_id;

	      cn_mark_events_pkg.mark_event_srp_pay_group
		('CHANGE_SRP_PAY_GROUP_DATE', -- event name
		 l_pay_group_name,            -- object name
		 p_paygroup_assign_rec.pay_group_id,           -- object id
                 p_paygroup_assign_rec.salesrep_id,            -- srp_object_id
		 p_paygroup_assign_rec.assignment_start_date,  -- start date
		 l_old_assignment_start_date,        -- start date old
		 p_paygroup_assign_rec.assignment_end_date,    -- end date
		 l_old_assignment_end_date,         -- end date old
		 p_paygroup_assign_rec.org_id);         -- org ID
	   END LOOP;
	END IF;

	FOR plans IN get_plan_assigns(roles.role_id, p_paygroup_assign_rec.salesrep_id)
	  LOOP
	     -- Added by Zack, check the start_date and end_date of plan assignment, populate the intersection
	     -- part with the pay group assignment date.

	     IF nvl(plans.end_date,l_null_date) > nvl(p_paygroup_assign_rec.assignment_end_date,l_null_date) THEN
		plans.end_date := p_paygroup_assign_rec.assignment_end_date;
	     END IF;

	     IF plans.start_date < p_paygroup_assign_rec.assignment_start_date THEN
		plans.start_date := p_paygroup_assign_rec.assignment_start_date;
	     END IF;

	     IF nvl(plans.end_date, l_null_date) > plans.start_date THEN
		cn_srp_periods_pvt.create_srp_periods
		  ( p_api_version      => p_api_version,
		    x_return_status    => x_return_status,
		    x_msg_count        => x_msg_count,
		    x_msg_data         => x_msg_data,
		    p_salesrep_id      => p_paygroup_assign_rec.salesrep_id,
		    p_role_id          => roles.role_id,
		    p_comp_plan_id     => plans.comp_plan_id,
		    p_start_date       => plans.start_date,
		    p_end_date         => plans.end_date,
		    x_loading_status   => x_loading_status);
		IF ( x_return_status = FND_API.G_RET_STS_ERROR )
		  THEN
		   RAISE FND_API.G_EXC_ERROR;
		 ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
		   THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	     END IF;
	  END LOOP;
     END LOOP;

     -- End of API body

     -- Standard check of p_commit.

     IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info
     FND_MSG_PUB.Count_And_Get
       (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Srp_Pay_Group;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    (
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Srp_Pay_Group;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Srp_Pay_Group;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

END update_srp_pay_group;

-- --------------------------------------------------------------------------*
-- Procedure: Valid_Delete_Srp_Pay_Group
-- --------------------------------------------------------------------------*
PROCEDURE valid_delete_srp_pay_group
  (  	p_paygroup_assign_rec      IN paygroup_assign_rec                     ,
     	p_init_msg_list		   IN	VARCHAR2,
  	x_loading_status	   OUT NOCOPY	VARCHAR2	     	      ,
  	x_return_status		   OUT NOCOPY	VARCHAR2	     	      ,
  	x_msg_count		   OUT NOCOPY	NUMBER			      ,
  	x_msg_data		   OUT NOCOPY	VARCHAR2
	) IS


   l_api_name		   CONSTANT VARCHAR2(30) := 'Valid_Delete_Srp_Pay_Group';
   l_srp_role_id NUMBER;
   l_ws_count NUMBER;
   l_null_date          CONSTANT DATE := to_date('12/31/9999','MM/DD/YYYY');
   l_count NUMBER;
   l_srp_pay_group_id   cn_srp_pay_groups.srp_pay_group_id%TYPE;

   -- clku
   CURSOR payee_check_curs(l_salesrep_id NUMBER) IS
      select srp_role_id from cn_srp_roles where
	salesrep_id = l_salesrep_id
	and role_id = 54
	AND org_id  = p_paygroup_assign_rec.org_id;

      CURSOR payee_assign_date_curs(l_payee_id NUMBER) IS
	 select salesrep_id, start_date, end_date
	   from cn_srp_payee_assigns_all
	   where payee_id = l_payee_id
	     AND org_id   = p_paygroup_assign_rec.org_id;

      l_payee_assign_date_rec    payee_assign_date_curs%ROWTYPE;



BEGIN
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_DELETED';

   --clku, payee check enhancement
   OPEN  payee_check_curs(p_paygroup_assign_rec.salesrep_id);
   Fetch payee_check_curs into l_srp_role_id;
   IF payee_check_curs%FOUND THEN
      -- check if there is any salesrep having this payee assigned within
      -- the deleting paygroup date range
      For l_payee_assign_date_rec IN payee_assign_date_curs
	(p_paygroup_assign_rec.salesrep_id) LOOP
	   -- check if there is any date range over between
	   -- srp paygroup date and payee assign date
	   IF CN_API.date_range_overlap
	     (p_paygroup_assign_rec.assignment_start_date,
	      p_paygroup_assign_rec.assignment_end_date,
	      l_payee_assign_date_rec.start_date,
	      l_payee_assign_date_rec.end_date) = true THEN

	      -- Raise Error
	      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
		THEN
		 fnd_message.set_name('CN', 'CN_PA_ASGN_DATE');
		 fnd_msg_pub.add;
	      END IF;

	      x_loading_status := 'CN_PA_ASGN_DATE';
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
	END LOOP;

	-- check if the payee has any worksheet
	SELECT count(*)
	  into l_ws_count
	  FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,
	  cn_payruns_all prun
	  WHERE w.salesrep_id = p_paygroup_assign_rec.salesrep_id
	  AND   w.org_id      = p_paygroup_assign_rec.org_id
	  AND   prun.pay_period_id = prd.period_id
	  AND   prun.payrun_id     = w.payrun_id
	  AND   prd.org_id         = p_paygroup_assign_rec.org_id
	  AND   prun.pay_group_id  = p_paygroup_assign_rec.pay_group_id
	  AND   w.quota_id is null
	    AND (
		 (prd.start_date BETWEEN p_paygroup_assign_rec.assignment_start_date
		  AND nvl(p_paygroup_assign_rec.assignment_end_date,l_null_date))
		 OR
		 (prd.end_date between p_paygroup_assign_rec.assignment_start_date
		  AND nvl(p_paygroup_assign_rec.assignment_end_date,l_null_date))
		 );

	  IF l_ws_count > 0 THEN
	     -- Raise Error
	     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	       THEN
		fnd_message.set_name('CN', 'CN_SRP_PG_WS');
		fnd_msg_pub.add;
	     END IF;

	     x_loading_status := 'CN_SRP_PG_WS';
	     RAISE FND_API.G_EXC_ERROR;
	  END IF;

   END IF;

   Close payee_check_curs;

   SELECT SRP_PAY_GROUP_ID
     INTO l_srp_pay_group_id
     FROM cn_srp_pay_groups_all
    WHERE pay_group_id = p_paygroup_assign_rec.pay_group_id
      AND start_date=p_paygroup_assign_rec.assignment_start_date
      AND (end_date =p_paygroup_assign_rec.assignment_end_date OR
	   end_date IS NULL)
      AND salesrep_id =p_paygroup_assign_rec.salesrep_id;

   SELECT COUNT(1) INTO l_count from cn_srp_pay_groups_all
    WHERE srp_pay_group_id = l_srp_pay_group_id
     AND salesrep_id = p_paygroup_assign_rec.salesrep_id
     AND pay_group_id= p_paygroup_assign_rec.pay_group_id
     AND org_id      = p_paygroup_assign_rec.org_id
     -- AND (lock_flag='N'OR lock_flag IS NULL)
       AND (start_date between p_paygroup_assign_rec.assignment_start_date AND
	    nvl(p_paygroup_assign_rec.assignment_end_date,l_null_date))
       AND (nvl(end_date,l_null_date) between
	    p_paygroup_assign_rec.assignment_start_date AND
	    nvl(p_paygroup_assign_rec.assignment_end_date,l_null_date))
       AND NOT EXISTS
       (SELECT 1 FROM cn_payment_worksheets_all W,
	cn_period_statuses_all prd, cn_payruns_all prun
	WHERE w.salesrep_id = p_paygroup_assign_rec.salesrep_id
	AND   w.org_id      = p_paygroup_assign_rec.org_id
	AND   prun.pay_period_id = prd.period_id
	AND   prun.payrun_id     = w.payrun_id
	AND   prun.pay_group_id  = p_paygroup_assign_rec.pay_group_id
	AND   prd.org_id         = p_paygroup_assign_rec.org_id
	AND ((prd.start_date BETWEEN
	      p_paygroup_assign_rec.assignment_start_date AND
	      nvl(p_paygroup_assign_rec.assignment_end_date,l_null_date))
	     OR (prd.end_date between
		 p_paygroup_assign_rec.assignment_start_date AND
		 nvl(p_paygroup_assign_rec.assignment_end_date,l_null_date))));

     IF l_count = 0 THEN
	--Error condition
	IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	  THEN
	   fnd_message.set_name('CN', 'CN_SRP_PG_WS');
	   fnd_msg_pub.add;
	END IF;

	x_loading_status := 'CN_SRP_PG_WS';
	RAISE FND_API.G_EXC_ERROR;

     END IF;
     EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get


    (
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );


END valid_delete_srp_pay_group;

-- --------------------------------------------------------------------------*
-- Procedure: Delete_Srp_Pay_Group
-- --------------------------------------------------------------------------*
PROCEDURE Delete_Srp_Pay_Group
(  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2,
	p_commit	    	   IN  	VARCHAR2,
	p_validation_level	   IN  	NUMBER,
	x_return_status		   OUT NOCOPY	VARCHAR2	     	      ,
	x_loading_status           OUT NOCOPY  VARCHAR2 	              ,
	x_msg_count		   OUT NOCOPY	NUMBER		    	      ,
	x_msg_data		   OUT NOCOPY	VARCHAR2               	      ,
        p_paygroup_assign_rec            IN  PayGroup_assign_rec
 	) IS

      l_api_name		   CONSTANT VARCHAR2(30) := 'Delete_Srp_Pay_Group';
      l_api_version           	   CONSTANT NUMBER  := 1.0;
      l_role_id                    cn_roles.role_id%TYPE;
      l_loading_status             VARCHAR2(2000);
      l_null_date          CONSTANT DATE := to_date('12/31/9999','MM/DD/YYYY');
      -- Declaration for user hooks

      l_count                NUMBER(15);
      l_start_date           DATE;
      l_end_date             DATE;
      l_srp_pay_group_id     cn_srp_pay_groups.srp_pay_group_id%TYPE;
      l_paygroup_assign_rec  paygroup_assign_rec;

      CURSOR get_role_plans(l_role_id cn_roles.role_id%TYPE) IS
	 SELECT role_plan_id,role_id
	   FROM cn_role_plans_all
	  WHERE role_id = l_role_id
	    AND org_id  = p_paygroup_assign_rec.org_id;

      CURSOR get_salesreps(l_role_id NUMBER) IS
	 SELECT srp_role_id,salesrep_id
	   FROM cn_srp_roles
	  WHERE role_id = l_role_id
	    AND org_id  = p_paygroup_assign_rec.org_id;

      CURSOR get_roles (p_salesrep_id cn_salesreps.salesrep_id%TYPE) IS
	 SELECT role_id, srp_role_id,start_date, nvl(end_date,l_null_date) end_date
	   FROM cn_srp_roles
	  WHERE salesrep_id = p_salesrep_id
	    AND org_id = p_paygroup_assign_rec.org_id;

      CURSOR get_plan_assigns
	(p_role_id NUMBER,
	 p_salesrep_id NUMBER) IS
	    SELECT comp_plan_id,
	      start_date,
	      end_date
	      FROM cn_srp_plan_assigns_all
	      WHERE role_id   = p_role_id
	      AND salesrep_id = p_salesrep_id
	      AND org_id      = p_paygroup_assign_rec.org_id;

      CURSOR get_srp_pg(l_salesrep_id NUMBER) IS
         select pay_group_id,start_date,end_date
	   from cn_srp_pay_groups_all
	   where salesrep_id = l_salesrep_id
	     AND org_id      = p_paygroup_assign_rec.org_id;



BEGIN
   -- Standard Start of API savepoint

   SAVEPOINT	Delete_Srp_Pay_Group;

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_DELETED';

   -- validate delete
   valid_delete_srp_pay_group
     (	p_paygroup_assign_rec      => p_paygroup_assign_rec,
	p_init_msg_list            => p_init_msg_list,
  	x_loading_status	   => x_loading_status,
	x_return_status		   => x_return_status,
  	x_msg_count		   => x_msg_count,
  	x_msg_data		   => x_msg_data);

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
     RAISE fnd_api.g_exc_error;
  END IF;

   -- if made it here, then OK to delete
   SELECT SRP_PAY_GROUP_ID
     INTO l_srp_pay_group_id
     FROM cn_srp_pay_groups_all
    WHERE pay_group_id = p_paygroup_assign_rec.pay_group_id
      AND start_date=p_paygroup_assign_rec.assignment_start_date
      AND (end_date =p_paygroup_assign_rec.assignment_end_date OR
	   end_date IS NULL)
      AND salesrep_id =p_paygroup_assign_rec.salesrep_id;

   DELETE FROM cn_srp_pay_groups_all
    WHERE srp_pay_group_id = l_srp_pay_group_id;

   -- raise business event
   l_paygroup_assign_rec.srp_pay_group_id := l_srp_pay_group_id;
   business_event
     (p_operation              => 'Remove',
      p_paygroup_assign_rec    => l_paygroup_assign_rec);

   SELECT count (*), min(start_date),nvl(max(end_date),l_null_date) end_date
     INTO l_count,l_start_date,l_end_date
     FROM cn_srp_pay_groups_all
    WHERE salesrep_id = p_paygroup_assign_rec.salesrep_id
      AND org_id      = p_paygroup_assign_rec.org_id;

   --Modified for bug fix 3137894.

   IF l_count = 0 THEN
    FOR roles IN get_roles(p_paygroup_assign_rec.salesrep_id)
     LOOP
       FOR role_plans IN get_role_plans(roles.role_id)
	 LOOP
	    srp_plan_assignment_for_delete
	      (p_role_id        => role_plans.role_id,
	       p_role_plan_id   => role_plans.role_plan_id,
	       p_salesrep_id    => p_paygroup_assign_rec.salesrep_id,
	       p_org_id         => p_paygroup_assign_rec.org_id,
	       x_return_status  => x_return_status,
	       p_loading_status => l_loading_status,
	       x_loading_status => x_loading_status);

	    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
	 END LOOP ;
     END LOOP;
   END IF;

   IF l_count > 0 THEN
      FOR paygroups in get_srp_pg(p_paygroup_assign_rec.salesrep_id)
        LOOP
	   FOR roles IN get_roles(p_paygroup_assign_rec.salesrep_id)
	     LOOP
		IF ((roles.start_date <= paygroups.start_date AND roles.end_date >=
		     paygroups.start_date) OR
		    (roles.start_date <= paygroups.end_date AND roles.end_date >=
		     paygroups.end_date ) )  THEN

		   FOR role_plans IN get_role_plans(roles.role_id)
		     LOOP
			cn_srp_plan_assigns_pvt.Update_Srp_Plan_Assigns
			  ( p_api_version     =>    1.0,
			    x_return_status   => x_return_status,
			    x_msg_count	      => x_msg_count,
			    x_msg_data	      => x_msg_data,
			    p_srp_role_id     => roles.srp_role_id,
			    p_role_plan_id    => role_plans.role_plan_id,
			    x_loading_status  => x_loading_status );
			IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
			   RAISE FND_API.G_EXC_ERROR;
			END IF;
		     END LOOP;
		END if;
		FOR plans IN get_plan_assigns
		  (roles.role_id,p_paygroup_assign_rec.salesrep_id)
		  LOOP
		     -- Added to check the start_date and end_date of plan assignment, populate the intersection
		     -- part with the pay group assignment date.

		     IF nvl(plans.end_date,l_null_date) > nvl(paygroups.end_date,l_null_date) THEN
			plans.end_date := l_end_date;
		     END IF;
		     IF plans.start_date < paygroups.start_date THEN
			plans.start_date := l_start_date;
		     END IF;

		     IF nvl(plans.end_date, l_null_date) > plans.start_date THEN
			cn_srp_periods_pvt.create_srp_periods
			  ( p_api_version    => p_api_version,
			    x_return_status  => x_return_status,
			    x_msg_count      => x_msg_count,
			    x_msg_data       => x_msg_data,
			    p_salesrep_id    => p_paygroup_assign_rec.salesrep_id,
			    p_role_id        => roles.role_id,
			    p_comp_plan_id   => plans.comp_plan_id,
			    p_start_date     => plans.start_date,
			    p_end_date       => plans.end_date,
			    x_loading_status => x_loading_status);
			IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
			   RAISE FND_API.G_EXC_ERROR;
			END IF;
		     END IF;
		  END LOOP;
	     END LOOP;
	END LOOP;
   END IF;


   -- End of API body

  -- Standard check of p_commit.


    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;


     -- Standard call to get message count and if count is 1, get message info.

     FND_MSG_PUB.Count_And_Get
   (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Srp_Pay_Group;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get


    (
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Srp_Pay_Group;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Srp_Pay_Group;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END Delete_Srp_Pay_Group;

-- --------------------------------------------------------------------------*
-- Procedure: Delete_Mass_Asgn_Srp_Pay_Groups
-- --------------------------------------------------------------------------*

PROCEDURE Delete_Mass_Asgn_Srp_Pay
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2,
   p_commit	        IN    VARCHAR2,
   p_validation_level   IN    NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pay_group_id  IN    NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   ) IS

      l_return_status        VARCHAR2(2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_pay_group_id     cn_srp_pay_groups.srp_pay_group_id%TYPE;
      l_loading_status       VARCHAR2(2000);

      newrec                 CN_Srp_PayGroup_PVT.PayGroup_assign_rec;
      l_salesrep_id          cn_salesreps.salesrep_id%TYPE;
      l_pay_group_id	     cn_pay_groups.pay_group_id%TYPE;
      l_pg_start_date        cn_pay_groups.start_date%TYPE;
      l_pg_end_date	     cn_pay_groups.end_date%TYPE;
      l_srp_start_date       cn_srp_roles.start_date%TYPE;
      l_srp_end_date	     cn_pmt_plans.end_date%TYPE;
      l_start_date           cn_srp_pay_groups.start_date%TYPE;
      l_end_date             cn_srp_pay_groups.start_date%TYPE;
      l_org_id               cn_srp_pay_groups.org_id%TYPE;
      l_lock_flag            cn_srp_pay_groups.lock_flag%TYPE;
      l_count                NUMBER;
      l_null_date            CONSTANT DATE := to_date('12/31/9999','MM/DD/YYYY');

BEGIN
   -- vensrini. Fix to delete role assignments when resource is in two orgs.
   SELECT org_id
     INTO l_org_id
     FROM cn_role_pay_groups
     WHERE role_pay_group_id = p_role_pay_group_id;

     select salesrep_id, start_date, end_date
       into l_salesrep_id, l_srp_start_date, l_srp_end_date
       from cn_srp_roles
       where srp_role_id = p_srp_role_id
       AND org_id = l_org_id; -- vensrini

     -- make sure dates overlap
     SELECT COUNT(1) INTO l_count
       FROM cn_role_pay_groups
      WHERE role_pay_group_id = p_role_pay_group_id
        AND Greatest(l_srp_start_date, start_date) <=
            Least(Nvl(l_srp_end_date, l_null_date),
		  Nvl(end_date,       l_null_date));

     IF l_count = 0 THEN
	-- nothing to do... return
	RETURN;
     END IF;

     BEGIN

     select spp.start_date, spp.end_date, spp.salesrep_id,
	    spp.lock_flag,cpp.pay_group_id, spp.org_id
       into l_start_date, l_end_date, l_salesrep_id,
            l_lock_flag,l_pay_group_id, l_org_id
       from cn_srp_pay_groups_all spp, cn_pay_groups_all cpp
      where spp.role_pay_group_id = p_role_pay_group_id
        AND spp.salesrep_id = l_salesrep_id
       AND cpp.pay_group_id = spp.pay_group_id
       AND Greatest(spp.start_date, l_srp_start_date) <=
            Least(Nvl(spp.end_date,l_null_date),
		  Nvl(l_srp_end_date,l_null_date));
    EXCEPTION
	WHEN no_data_found THEN
       RAISE FND_API.G_EXC_ERROR;

    END;

    IF l_lock_flag = 'Y'
      THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    SELECT count(*)
      into l_count
      FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,
           cn_payruns_all prun
      WHERE w.salesrep_id      = l_salesrep_id
      AND   w.org_id           = l_org_id
      AND   prun.pay_period_id = prd.period_id
      AND   prun.payrun_id     = w.payrun_id
      AND   prun.pay_group_id  = l_pay_group_id
      AND   prd.org_id         = l_org_id
      AND ((prd.start_date BETWEEN l_start_date AND nvl(l_end_date,l_null_date)) OR
	   (prd.end_date between l_start_date AND nvl(l_end_date,l_null_date)) );

    IF l_count > 0
      THEN
-- Making it a direct assignment if paysheets exist - for Bug 5557049.
        Update cn_srp_pay_groups_all
		set role_pay_group_id = null
		where role_pay_group_id = p_role_pay_group_id
        and salesrep_id = l_salesrep_id
        and org_id = l_org_id;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    newrec.assignment_start_date     := l_start_date;
    newrec.assignment_end_date       := l_end_date;
    newrec.salesrep_id               := l_salesrep_id;
    newrec.org_id                    := l_org_id;
    newrec.pay_group_id              := l_pay_group_id;

    delete_srp_pay_group
      (
       p_api_version        => 1.0,
       x_return_status      => l_return_status,
       x_loading_status     => l_loading_status,
       x_msg_count          => l_msg_count,
       x_msg_data           => l_msg_data,
       p_paygroup_assign_rec=> newrec);

    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
       RAISE fnd_api.g_exc_error;
    END IF;

    x_return_status     := l_return_status;
    x_loading_status    := l_loading_status;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      NULL;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      NULL;
   WHEN OTHERS THEN
      NULL;


END Delete_Mass_Asgn_Srp_Pay;

END CN_Srp_PayGroup_PVT ;

/
