--------------------------------------------------------
--  DDL for Package Body CN_SRP_PMT_PLANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PMT_PLANS_PVT" AS
/* $Header: cnvsppab.pls 120.26.12010000.2 2009/05/13 17:43:08 rnagired ship $ */

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_SRP_PMT_PLANS_PVT';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnvsppab.pls';

procedure get_date_range_intersect(a_start_date in date, a_end_date in date,
                                   b_start_date in date, b_end_date in date,
                         x_start_date out nocopy date, x_end_date out nocopy date)
IS
BEGIN
   if ( a_start_date is null or b_start_date is null) then
     x_start_date := null;
     x_end_date := null;
   elsif (a_end_date is not null and a_end_date < b_start_date)
      or ( b_end_date is not null and a_start_date > b_end_date) then
       x_start_date := null;
       x_end_date := null;
   else
     x_start_date := greatest(a_start_date, b_start_date);
     if a_end_date is null then
       x_end_date := b_end_date;
     elsif b_end_date is null then
       x_end_date := a_end_date;
     else
       x_end_date := least(a_end_date, b_end_date);
     end if;
   end if;
END;

procedure get_masgn_date_intersect(
    p_role_pmt_plan_id IN NUMBER,
    p_srp_role_id IN NUMBER,
    x_start_date OUT NOCOPY DATE,
    x_end_date OUT NOCOPY DATE) IS

  l_start_date cn_srp_pmt_plans.start_date%TYPE;
  l_end_date cn_srp_pmt_plans.start_date%TYPE;

  l_res_start_date cn_srp_pmt_plans.start_date%TYPE;
  l_res_end_date cn_srp_pmt_plans.start_date%TYPE;

  l_role_pp_start_date cn_srp_pmt_plans.start_date%TYPE;
  l_role_pp_end_date cn_srp_pmt_plans.start_date%TYPE;

  l_srp_role_start_date cn_srp_pmt_plans.start_date%TYPE;
  l_srp_role_end_date cn_srp_pmt_plans.start_date%TYPE;

  l_pp_start_date cn_srp_pmt_plans.start_date%TYPE;
  l_pp_end_date cn_srp_pmt_plans.start_date%TYPE;

  l_org_id NUMBER;
  l_salesrep_id NUMBER;
  l_pmt_plan_id NUMBER;

BEGIN
  -- get start_date, end_date org_id and pmt_plan_id from role_pmt_plans
  select org_id, pmt_plan_id, start_date, end_date
  into l_org_id, l_pmt_plan_id, l_role_pp_start_date, l_role_pp_end_date
  from cn_role_pmt_plans
  where ROLE_PMT_PLAN_ID = p_role_pmt_plan_id;

  -- get srp role assignment start and end dates
  select start_date, end_date, salesrep_id
  into l_srp_role_start_date, l_srp_role_end_date, l_salesrep_id
  from cn_srp_roles
  where srp_role_id = p_srp_role_id
    and org_id = l_org_id;

  -- get intersection between srp_role and role_payment_plan dates
  get_date_range_intersect(
	 	a_start_date => l_srp_role_start_date,
         	a_end_date   => l_srp_role_end_date,
         	b_start_date => l_role_pp_start_date,
         	b_end_date   => l_role_pp_end_date,
         	x_start_date => x_start_date,
         	x_end_date   => x_end_date);

  l_start_date := x_start_date;
  l_end_date := x_end_date;

  -- get resource start and end dates
  select start_date_active, end_date_active
  into l_res_start_date, l_res_end_date
  from cn_salesreps
  where salesrep_id = l_salesrep_id
    and org_id = l_org_id;

  -- get intersection with resource start and end dates
  get_date_range_intersect(
	 	a_start_date => l_start_date,
         	a_end_date   => l_end_date,
         	b_start_date => l_res_start_date,
         	b_end_date   => l_res_end_date,
         	x_start_date => x_start_date,
         	x_end_date   => x_end_date);

  l_start_date := x_start_date;
  l_end_date := x_end_date;

  -- get payment plan start and end dates
  select start_date, end_date
  into l_pp_start_date, l_pp_end_date
  from cn_pmt_plans
  where pmt_plan_id = l_pmt_plan_id;

  -- get intersection with payment plan start and end dates
  get_date_range_intersect(
	 	a_start_date => l_start_date,
         	a_end_date   => l_end_date,
         	b_start_date => l_pp_start_date,
         	b_end_date   => l_pp_end_date,
         	x_start_date => x_start_date,
         	x_end_date   => x_end_date);

END;



PROCEDURE validate_assignment
  (x_return_status	    OUT NOCOPY VARCHAR2 ,
   x_msg_count		    OUT NOCOPY NUMBER	 ,
   x_msg_data		    OUT NOCOPY VARCHAR2,
   p_salesrep_id	    IN NUMBER,
   p_org_id                 IN NUMBER,
   p_start_date		    IN DATE,
   p_end_date		    IN DATE,
   p_minimum_amount         IN NUMBER,
   p_maximum_amount         IN NUMBER,
   p_pmt_plan_id            IN NUMBER,
   p_srp_pmt_plan_id        IN NUMBER,
   p_loading_status         IN VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2) IS

      l_count		   NUMBER       := 0;
      l_api_name  CONSTANT VARCHAR2(30) := 'Validate_assignment';
      l_dummy              NUMBER;
      l_srp_start_date     DATE;
      l_srp_end_date       DATE;
      l_pp_start_date      DATE;
      l_pp_end_date        DATE;
      l_payment_group_code VARCHAR2(30);

BEGIN

   --
   --  Initialize API return status to success
   --
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status ;

 -- Check if already exist( duplicate assigned,unique key violation check)
   SELECT COUNT(1) INTO l_dummy
     FROM cn_srp_pmt_plans_all
     WHERE salesrep_id = p_salesrep_id
     AND   pmt_plan_id = p_pmt_plan_id
     AND   start_date  = p_start_date
     AND   ( (end_date = p_end_date) OR
	     (end_date IS NULL AND p_end_date IS NULL) )
	       AND   ((p_srp_pmt_plan_id IS NOT NULL AND
		       srp_pmt_plan_id <> p_srp_pmt_plan_id)
		      OR
		      (p_srp_pmt_plan_id IS NULL));

   IF l_dummy > 0 THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.Set_Name('CN', 'CN_SRP_PMT_PLAN_EXIST');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SRP_PMT_PLAN_EXIST';
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
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_SPP_PRDS_NI_SRP_PRDS');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SPP_PRDS_NI_SRP_PRDS';
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

   SELECT start_date, end_date, payment_group_code
     INTO l_pp_start_date, l_pp_end_date, l_payment_group_code
     FROM cn_pmt_plans_all
    WHERE pmt_plan_id = p_pmt_plan_id;
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
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_SPP_PRDS_NI_PMT_PRDS');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SPP_PRDS_NI_PMT_PRDS';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Check Overlap
   --    Ensure pmt plan assignments do not overlap each other in same role
   --    only 1 payment plan is active at each date
   --    Returns an error message and raises an exception if overlap occurs.
   SELECT COUNT(1) INTO l_dummy
     FROM   cn_srp_pmt_plans_all cspp, cn_pmt_plans_all cpp
     WHERE (((cspp.end_date IS NULL)
	     AND (p_end_date IS NULL))
	    OR
	    ((cspp.end_date IS NULL) AND
	     (p_end_date IS NOT NULL) AND
	     ((p_start_date >= cspp.start_date) OR
	      (cspp.start_date BETWEEN p_start_date AND p_end_date))
	     )
	    OR
	    ((cspp.end_date IS NOT NULL) AND
	     (p_end_date IS NULL) AND
	     ((p_start_date <= cspp.start_date) OR
	      (p_start_date BETWEEN cspp.start_date AND cspp.end_date))
	     )
	    OR
	    ((cspp.end_date IS NOT NULL) AND
	     (p_end_date IS NOT NULL) AND
	     ((cspp.start_date BETWEEN p_start_date AND p_end_date) OR
	      (cspp.end_date   BETWEEN p_start_date AND p_end_date) OR
	      (p_start_date BETWEEN cspp.start_date AND cspp.end_date))
	     )
	       )
	       AND ((p_srp_pmt_plan_id IS NOT NULL AND
		     srp_pmt_plan_id <> p_srp_pmt_plan_id)
		    OR
		    (p_srp_pmt_plan_id IS NULL))
		      AND cspp.Salesrep_id  = p_salesrep_id
		      AND cpp.payment_group_code = l_payment_group_code
		      AND cspp.pmt_plan_id = cpp.pmt_plan_id;

   IF l_dummy > 0 then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_SRP_PMT_PLAN_OVERLAPS');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SRP_PMT_PLAN_OVERLAPS';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   /* credit type ID in cn_srp_pmt_plans is Obsolete!

   -- Check the credit types of plan element assigned to this salesrep within this date range
   --  Added by Zack  Sep 12th, 2001
   --  Modified on Oct. 8th, checking for credit type compatibility.
   --  If there's no quotas assigned at this time, or at least one quota having the same credit
   --  type id with the payment plan, we will allow it to be assigned.

   l_dummy := 0;
   l_dummy2 := 0;
   FOR l_quota_rec in get_quota_ids_csr(x_srp_pmt_plans_row.salesrep_id,x_srp_pmt_plans_row.start_date,x_srp_pmt_plans_row.end_date) LOOP
      l_dummy2 := 1;
      IF l_quota_rec.credit_type_id = x_srp_pmt_plans_row.credit_type_id THEN
         l_dummy := 1;
      END IF;
   END LOOP;

   IF l_dummy2 = 1 THEN
      IF l_dummy = 0 THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME ('CN' , 'CN_SRPPP_CT_MISMATCH');
            FND_MSG_PUB.Add;
         END IF;
         x_loading_status := 'CN_SRPPP_CT_MISMATCH';
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
     */

     -- either min amount or max amount needs to be populated
     IF (p_minimum_amount IS NULL AND p_maximum_amount IS NULL) THEN
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   FND_MESSAGE.SET_NAME ('CN' , 'CN_SPP_MIN_MAX_NULL');
	   FND_MSG_PUB.Add;
	END IF;
	x_loading_status := 'CN_SPP_MIN_MAX_NULL';
	RAISE FND_API.G_EXC_ERROR ;
     END IF;

     -- Check Max amount must > Min amount
   IF (p_maximum_amount < p_minimum_amount)
     THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_SPP_MAX_LT_MIN');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SPP_MAX_LT_MIN';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;


END validate_assignment;

PROCEDURE check_payruns
  (p_operation              IN VARCHAR2,
   p_srp_pmt_plan_id        IN NUMBER,
   p_salesrep_id            IN  NUMBER,
   p_start_date		    IN  DATE,
   p_end_date		    IN  DATE,
   x_payrun_tbl             OUT NOCOPY payrun_tbl
   ) IS

      l_fixed_end_date     DATE;
      l_fixed_old_end_date DATE;
      l_old_start_date     DATE;
      l_end_of_time        CONSTANT DATE := To_date('31-12-9999', 'DD-MM-YYYY');
      l_null_amount NUMBER := -9999;

      CURSOR get_del_payruns IS
      SELECT DISTINCT prun.name
	FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,
	     cn_payruns_all prun, cn_srp_pmt_plans_all spp
	WHERE w.salesrep_id = spp.salesrep_id
	AND   w.quota_id is null
	AND   prun.pay_period_id = prd.period_id
	AND   prun.org_id        = prd.org_id
	AND   prun.payrun_id     = w.payrun_id
	AND  spp.srp_pmt_plan_id = p_srp_pmt_plan_id
	AND ( ((spp.end_date IS NOT NULL) AND (prd.end_date IS NOT NULL)
	       AND (prd.start_date <= spp.end_date)
	       AND (prd.end_date >= spp.start_date))
	      OR ((spp.end_date IS NULL) AND (prd.end_date IS NOT NULL)
		  AND (prd.end_date >= spp.start_date))
	      OR ((spp.end_date IS NULL) AND (prd.end_date IS NULL))
	      );

	CURSOR get_paid_del_payruns IS
      SELECT 'ERROR' as estatus
	FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,
	     cn_payruns_all prun, cn_srp_pmt_plans_all spp,cn_pmt_plans_all pp
	WHERE w.salesrep_id = spp.salesrep_id
	AND   w.quota_id is null
	AND   prun.pay_period_id = prd.period_id
	AND   prun.org_id        = prd.org_id
	AND   prun.payrun_id     = w.payrun_id
	AND  spp.srp_pmt_plan_id = p_srp_pmt_plan_id
	AND   spp.pmt_plan_id = pp.pmt_plan_id
	AND   prun.status = 'PAID'
	AND ( ((spp.end_date IS NOT NULL) AND (prd.end_date IS NOT NULL)
	       AND (prd.start_date <= spp.end_date)
	       AND (prd.end_date >= spp.start_date))
	      OR ((spp.end_date IS NULL) AND (prd.end_date IS NOT NULL)
		  AND (prd.end_date >= spp.start_date))
	      OR ((spp.end_date IS NULL) AND (prd.end_date IS NULL))
	      );

    CURSOR get_adj_del_payruns IS
      SELECT 'ERROR' as estatus
	FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,
	     cn_payruns_all prun, cn_srp_pmt_plans_all spp,cn_pmt_plans_all pp
--         cn_payment_transactions pt
	WHERE w.salesrep_id = spp.salesrep_id
	AND   w.quota_id is null
	AND   prun.pay_period_id = prd.period_id
	AND   prun.org_id        = prd.org_id
	AND   prun.payrun_id     = w.payrun_id
	AND  spp.srp_pmt_plan_id = p_srp_pmt_plan_id
	AND   spp.pmt_plan_id = pp.pmt_plan_id
--	AND   pt.payrun_id = prun.payrun_id
--	AND    pt.payee_salesrep_id = w.salesrep_id
--	AND   pt.pay_period_id = prun.pay_period_id
--	AND pt.incentive_type_code = 'PMTPLN'
	AND ( ((spp.end_date IS NOT NULL) AND (prd.end_date IS NOT NULL)
	       AND (prd.start_date <= spp.end_date)
	       AND (prd.end_date >= spp.start_date))
	      OR ((spp.end_date IS NULL) AND (prd.end_date IS NOT NULL)
		  AND (prd.end_date >= spp.start_date))
	      OR ((spp.end_date IS NULL) AND (prd.end_date IS NULL))
	      );


     CURSOR get_upd_payruns IS
     SELECT DISTINCT prun.name
       FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,cn_payruns_all prun
      WHERE w.salesrep_id = p_salesrep_id
        AND prun.pay_period_id = prd.period_id
        AND w.quota_id        is null
	AND   prun.org_id      = prd.org_id
        AND   prun.payrun_id   = w.payrun_id
        AND   l_old_start_date < p_start_date
        AND   prd.start_date   < p_start_date
	AND   prd.end_date     > l_old_start_date
	UNION
     SELECT DISTINCT prun.name
       FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,cn_payruns_all prun
      WHERE w.salesrep_id = p_salesrep_id
	AND   prun.pay_period_id = prd.period_id
	AND   prun.org_id        = prd.org_id
        AND   w.quota_id        is null
        AND   prun.payrun_id     = w.payrun_id
        AND   l_fixed_old_end_date > l_fixed_end_date
        AND   prd.start_date < l_fixed_old_end_date
        AND   prd.end_date   > l_fixed_end_date;

	CURSOR get_paid_upd_payruns IS
     SELECT 'ERROR' as estatus
       FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,cn_payruns_all prun
      WHERE w.salesrep_id = p_salesrep_id
        AND prun.pay_period_id = prd.period_id
        AND w.quota_id        is null
	AND   prun.org_id      = prd.org_id
	AND prun.status = 'PAID'
        AND   prun.payrun_id   = w.payrun_id
        AND   l_old_start_date < p_start_date
        AND   prd.start_date   < p_start_date
	AND   prd.end_date     > l_old_start_date
	UNION
     SELECT 'ERROR' as estatus
       FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,cn_payruns_all prun
      WHERE w.salesrep_id = p_salesrep_id
	AND   prun.pay_period_id = prd.period_id
	AND   prun.org_id        = prd.org_id
	AND prun.status = 'PAID'
        AND   w.quota_id        is null
        AND   prun.payrun_id     = w.payrun_id
        AND   l_fixed_old_end_date > l_fixed_end_date
        AND   prd.start_date < l_fixed_old_end_date
        AND   prd.end_date   > l_fixed_end_date;

	CURSOR get_date_range(param_srp_pmt_plan_id NUMBER) IS
        SELECT start_date, Nvl(end_date, l_end_of_time) as end_date
        FROM cn_srp_pmt_plans_all
        WHERE srp_pmt_plan_id = param_srp_pmt_plan_id;

--Added by Christina------------------------------------------------------------
-- This cursor returns an error status if there are any paid/unpaid worksheets
-- within the current pp assignment's date range but would fall outside
-- the date range that the user is trying to shrink the pp assignment to.

    CURSOR get_adj_upd_payruns IS
    SELECT 'ERROR' as estatus
	FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,
	     cn_payruns_all prun, cn_srp_pmt_plans_all spp
--         cn_payment_transactions pt
	WHERE w.salesrep_id = spp.salesrep_id
	AND   w.quota_id is null
	AND   prun.pay_period_id = prd.period_id
	AND   prun.org_id        = prd.org_id
	AND   prun.payrun_id     = w.payrun_id
	AND  spp.srp_pmt_plan_id = p_srp_pmt_plan_id
	AND   prun.status<>'PAID'
--	AND   pt.payrun_id = prun.payrun_id
--	AND    pt.payee_salesrep_id = w.salesrep_id
--	AND   pt.pay_period_id = prun.pay_period_id
--	AND pt.incentive_type_code = 'PMTPLN'
	AND (((spp.end_date IS NOT NULL) AND (prd.end_date IS NOT NULL)
	       AND (prd.start_date <= spp.end_date)
	       AND (prd.end_date >= spp.start_date))
	      OR ((spp.end_date IS NULL) AND (prd.end_date IS NOT NULL)
		  AND (prd.end_date >= spp.start_date))
	      OR ((spp.end_date IS NULL) AND (prd.end_date IS NULL)))
    AND (NVL(p_end_date, l_end_of_time) < NVL(prd.end_date, l_end_of_time)
    OR p_start_date > prd.start_date);




        l_date_range_rec get_date_range%ROWTYPE;
	    paid_upd_payruns_row get_paid_upd_payruns%rowtype;
        paid_del_payruns_row get_paid_del_payruns%rowtype;
        adj_del_payruns_row get_adj_del_payruns%rowtype;
        adj_upd_payruns_row get_adj_upd_payruns%rowtype;

BEGIN

/*------------------------------------------------------------------------------
 * CHANTHON - 19-Sep-2006
 * As per the latest update received, the behaviour should be as follows,
 * If a resource has been paid or has a working/unpaid worksheet then we should
 * not allow users to delete the payment plan for that period even if no
 * payment plan adjustments are there in the worksheet.
 * Same applies to shrinking. Can happen only till the period end date of the
 * latest paid/unpaid worksheet.
-----------------------------------------------------------------------------*/
    -- Initialize message list
	FND_MSG_PUB.initialize;

   IF p_operation = 'DELETE' THEN
      -- check payruns involved
      OPEN  get_paid_del_payruns;
       FETCH get_paid_del_payruns  INTO paid_del_payruns_row;
       CLOSE get_paid_del_payruns;

    IF paid_del_payruns_row.estatus = 'ERROR' then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	       FND_MESSAGE.Set_Name('CN', 'CN_SRP_PP_NO_DEL');
	       FND_MSG_PUB.Add;
        END IF;
    ELSE
       OPEN  get_adj_del_payruns;
       FETCH get_adj_del_payruns  INTO adj_del_payruns_row;
       CLOSE get_adj_del_payruns;

       IF adj_del_payruns_row.estatus = 'ERROR' then
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	       FND_MESSAGE.Set_Name('CN', 'CN_SRP_PP_NO_DEL_ADJ');
	       FND_MSG_PUB.Add;
         END IF;
/*        ELSE
-- With latest update this should never be called as even if unpaid paysheets
-- with no payment plan adjustments are present, delete cannot happen.
         OPEN  get_del_payruns;
         FETCH get_del_payruns bulk collect INTO x_payrun_tbl;
         CLOSE get_del_payruns; */
       END IF;
     END IF;

    ELSIF p_operation = 'UPDATE' THEN
        open get_date_range(p_srp_pmt_plan_id);
        fetch get_date_range into l_date_range_rec;
        close get_date_range;
        l_old_start_date := l_date_range_rec.start_date;
        l_fixed_old_end_date := l_date_range_rec.end_date;
       l_fixed_end_date     := Nvl(p_end_date,     l_end_of_time);

       OPEN  get_paid_upd_payruns;
       FETCH get_paid_upd_payruns  INTO paid_upd_payruns_row;
       CLOSE get_paid_upd_payruns;

        IF paid_upd_payruns_row.estatus = 'ERROR' then
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	           FND_MESSAGE.Set_Name('CN', 'CN_SRP_PP_NO_UPD');
	           FND_MSG_PUB.Add;
            END IF;
        ELSE
            OPEN  get_adj_upd_payruns;
            FETCH get_adj_upd_payruns  INTO adj_upd_payruns_row;
            CLOSE get_adj_upd_payruns;

            IF adj_upd_payruns_row.estatus = 'ERROR' then
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	            FND_MESSAGE.Set_Name('CN', 'CN_SRP_PP_NO_UPD');
	            FND_MSG_PUB.Add;
                END IF;
      /*  ELSE
-- With latest update this should never be called as even if unpaid paysheets
-- with no payment plan adjustments are present, shrink cannot happen.
        OPEN  get_upd_payruns;
        FETCH get_upd_payruns bulk collect INTO x_payrun_tbl;
        CLOSE get_upd_payruns; */
        END IF;
     END IF;
  END IF;
END check_payruns;


-- ------------------------------------------------------------------------+
--   Procedure   : Check_Operation_Allowed ( Delete / Update )
--   Description : This procedure is used to check if the srp pmt plan can
--		      be updated or deleted.
-- ------------------------------------------------------------------------+
PROCEDURE check_operation_allowed
  (x_return_status	    OUT	NOCOPY VARCHAR2,
   x_msg_count		    OUT	NOCOPY NUMBER ,
   x_msg_data		    OUT	NOCOPY VARCHAR2,
   p_salesrep_id            IN  NUMBER,
   p_old_start_date	    IN  DATE := FND_API.G_MISS_DATE,
   p_old_end_date	    IN  DATE := FND_API.G_MISS_DATE,
   p_start_date		    IN  DATE,
   p_end_date		    IN  DATE,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) IS

      l_api_name  CONSTANT VARCHAR2(30) := 'Check_operation_allowed';
      l_dummy     NUMBER;

BEGIN
   --
   --  Initialize API return status to success
   --
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status ;

   -- Need to check if payment plan already been used in payment worksheet
   -- during the period, if so operation not allowed
   IF p_old_start_date = FND_API.G_MISS_DATE AND
      p_old_end_date   = FND_API.G_MISS_DATE THEN
      -- Called from Delete Srp Payment Plan Assign

      --***********************************************************************
      -- Added By Kumar Sivasankaran
      -- Delete Srp Payment Plan is Not allowed when it is used in the WOrksheet
      -- Date 10/09/01
      --***********************************************************************

      --***********************************************************************
      -- Modified by Sundar Venkat on 22 Aug 2002
      -- Bug fix 2518847
      --***********************************************************************

        SELECT COUNT(1) INTO l_dummy
	  FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,
	       cn_payruns_all prun, cn_payment_transactions_all pmttrans
	  WHERE w.salesrep_id = p_salesrep_id
            AND w.salesrep_id = pmttrans.credited_salesrep_id
            AND pmttrans.incentive_type_code = 'PMTPLN'
	    AND   prun.pay_period_id = prd.period_id
	    AND   prun.org_id        = prd.org_id
            AND   prun.payrun_id     = w.payrun_id
	    AND ( ((p_end_date IS NOT NULL) AND (prd.end_date IS NOT NULL)
		   AND (prd.start_date <= p_end_date)
		   AND (prd.end_date >= p_start_date))
		  OR ((p_end_date IS NULL) AND (prd.end_date IS NOT NULL)
		      AND (prd.end_date >= p_start_date))
		  OR ((p_end_date IS NULL) AND (prd.end_date IS NULL))
		  );

     IF l_dummy > 0 then
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   FND_MESSAGE.SET_NAME ('CN' , 'CN_SRP_PMT_PLAN_USED');
	   FND_MSG_PUB.Add;
	END IF;
	x_loading_status := 'CN_SRP_PMT_PLAN_USED';
	RAISE FND_API.G_EXC_ERROR ;
     END IF;

    ELSE
      -- Called from Update Srp Payment Plan Assign
      -- Check if during the old date range assign, any pmt plan already
      -- been used, if so, cannot change start_date. If not been used, start
      -- date can be extend or shrink.

      --***********************************************************************
      -- Added By Kumar Sivasankaran
      -- Date 09/10/01
      --
      -- Shorten the end_date assignment
      -- Check for the shortened date range, if pmt plan already been paid,
      -- if so, cannot shorten
      --***********************************************************************
      IF ( ((p_old_end_date IS NOT NULL) AND (p_end_date IS NOT NULL) AND
	    (p_old_end_date > p_end_date))
	   OR
	   ((p_old_end_date IS NULL) AND (p_end_date IS NOT NULL)) ) THEN
	 SELECT COUNT(1) INTO l_dummy
	   FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,cn_payruns_all prun
	  WHERE w.salesrep_id = p_salesrep_id
	    AND   prun.pay_period_id = prd.period_id
	    AND   prun.org_id        = prd.org_id
            AND   prun.payrun_id     = w.payrun_id
	   AND ( ((p_old_end_date IS NOT NULL) AND (prd.end_date IS NOT NULL)
		     AND (prd.start_date < p_old_end_date)
		     AND (prd.end_date > p_end_date))
		    OR ((p_old_end_date IS NULL) AND
			((prd.start_date > p_end_date) OR (prd.end_date > p_end_date)))
		 );

	IF l_dummy > 0 THEN
	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.SET_NAME ('CN' , 'CN_SPP_CANNOT_SHORTEN_ED');
	      FND_MSG_PUB.Add;
	   END IF;
	   x_loading_status := 'CN_SPP_CANNOT_SHORTEN_ED';
	   RAISE FND_API.G_EXC_ERROR ;
	END IF;

      END IF ; -- end IF end date change

      -- Check if during the old date range assign, any pmt plan already
      -- been used, if so, cannot change start_date. If not been used, start
      -- date can be extend or shrink.

      IF p_old_start_date <> p_start_date
      THEN
	 SELECT COUNT(1) INTO l_dummy
	   FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,cn_payruns_all prun
	  WHERE w.salesrep_id = p_salesrep_id
	    AND   prun.pay_period_id = prd.period_id
	    AND   prun.org_id        = prd.org_id
            AND   prun.payrun_id     = w.payrun_id
	    AND ( ((p_old_end_date IS NOT NULL) AND (prd.end_date IS NOT NULL)
		   AND (prd.start_date <= p_old_end_date)
		   AND (prd.end_date >= p_old_start_date))
		  OR ((p_old_end_date IS NULL) AND (prd.end_date IS NOT NULL)
		      AND (prd.end_date >= p_old_start_date))
		  );
	 IF l_dummy > 0 THEN
	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	      THEN
	       FND_MESSAGE.SET_NAME ('CN' , 'CN_SPP_UPDATE_NOT_ALLOWED');
	       FND_MSG_PUB.Add;
	    END IF;
	    x_loading_status := 'CN_SPP_UPDATE_NOT_ALLOWED';
	    RAISE FND_API.G_EXC_ERROR ;
	 END IF;
      END IF ; -- end IF start date change
   END IF; -- end if delete/update operation

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;

END check_operation_allowed;

PROCEDURE get_note
  (p_field           IN VARCHAR2,
   p_old_value       IN VARCHAR2,
   p_new_value       IN VARCHAR2,
   x_msg             IN OUT nocopy VARCHAR2) IS

   l_note_msg      VARCHAR2(240);
BEGIN
  fnd_message.set_name('CN', 'CN_SPP_UPD_NOTE');
  fnd_message.set_token('FIELD', cn_api.get_lkup_meaning(p_field, 'CN_NOTE_FIELDS'));
  fnd_message.set_token('OLD',  p_old_value);
  fnd_message.set_token('NEW',  p_new_value);
  l_note_msg := fnd_message.get;

  IF x_msg IS NOT NULL THEN
     x_msg := x_msg || fnd_global.local_chr(10);
  END IF;
  x_msg := x_msg || l_note_msg;
END get_note;

PROCEDURE raise_note
  (p_srp_pmt_plan_id IN NUMBER,
   p_msg             IN VARCHAR2) IS

   x_note_id       NUMBER;
   x_msg_count     NUMBER;
   x_msg_data      VARCHAR2(240);
   x_return_status VARCHAR2(1);

BEGIN
  jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => p_srp_pmt_plan_id,
       p_source_object_code    => 'CN_SRP_PMT_PLANS',
       p_notes                 => p_msg,
       p_notes_detail          => p_msg,
       p_note_type             => 'CN_SYSGEN', -- for system generated
       x_jtf_note_id           => x_note_id -- returned
       );
END raise_note;

PROCEDURE business_event
  (p_operation            IN VARCHAR2,
   p_pmt_plan_assign_rec  IN pmt_plan_assign_rec) IS

   l_key        VARCHAR2(80);
   l_event_name VARCHAR2(80);
   l_list       wf_parameter_list_t;
BEGIN
   -- p_operation = Add, Update, Remove
   l_event_name := 'oracle.apps.cn.resource.PaymentPlanAssign.' || p_operation;

   --Get the item key
   -- for create - event_name || srp_pmt_plan_id
   -- for update - event_name || srp_pmt_plan_id || ovn
   -- for delete - event_name || srp_pmt_plan_id
   l_key := l_event_name || '-' || p_pmt_plan_assign_rec.srp_pmt_plan_id;

   -- build parameter list as appropriate
   IF (p_operation = 'Add') THEN
      wf_event.AddParameterToList('SALESREP_ID',p_pmt_plan_assign_rec.salesrep_id,l_list);
      wf_event.AddParameterToList('PMT_PLAN_ID',p_pmt_plan_assign_rec.pmt_plan_id,l_list);
      wf_event.AddParameterToList('START_DATE',p_pmt_plan_assign_rec.start_date,l_list);
      wf_event.AddParameterToList('END_DATE',p_pmt_plan_assign_rec.end_date,l_list);
      wf_event.AddParameterToList('MINIMUM_AMOUNT',p_pmt_plan_assign_rec.minimum_amount,l_list);
      wf_event.AddParameterToList('MAXIMUM_AMOUNT',p_pmt_plan_assign_rec.maximum_amount,l_list);
      wf_event.AddParameterToList('LOCK_FLAG',p_pmt_plan_assign_rec.lock_flag,l_list);
    ELSIF (p_operation = 'Update') THEN
      l_key := l_key || '-' || p_pmt_plan_assign_rec.object_version_number;
      wf_event.AddParameterToList('SRP_PMT_PLAN_ID',p_pmt_plan_assign_rec.srp_pmt_plan_id,l_list);
      wf_event.AddParameterToList('SALESREP_ID',p_pmt_plan_assign_rec.salesrep_id,l_list);
      wf_event.AddParameterToList('PMT_PLAN_ID',p_pmt_plan_assign_rec.pmt_plan_id,l_list);
      wf_event.AddParameterToList('START_DATE',p_pmt_plan_assign_rec.start_date,l_list);
      wf_event.AddParameterToList('END_DATE',p_pmt_plan_assign_rec.end_date,l_list);
      wf_event.AddParameterToList('MINIMUM_AMOUNT',p_pmt_plan_assign_rec.minimum_amount,l_list);
      wf_event.AddParameterToList('MAXIMUM_AMOUNT',p_pmt_plan_assign_rec.maximum_amount,l_list);
      wf_event.AddParameterToList('LOCK_FLAG',p_pmt_plan_assign_rec.lock_flag,l_list);
    ELSIF (p_operation = 'Remove') THEN
      wf_event.AddParameterToList('SRP_PMT_PLAN_ID',p_pmt_plan_assign_rec.srp_pmt_plan_id,l_list);
   END IF;

   -- Raise Event
   wf_event.raise
     (p_event_name        => l_event_name,
      p_event_key         => l_key,
      p_parameters        => l_list);

   l_list.DELETE;
END business_event;


-- --------------------------------------------------------------------------*
-- Procedure: Create_Srp_Pmt_Plan
-- --------------------------------------------------------------------------*
PROCEDURE Create_Srp_Pmt_Plan
  (  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2,
	p_commit	    	   IN  	VARCHAR2,
	p_validation_level	   IN  	NUMBER,
	x_return_status		   OUT NOCOPY	VARCHAR2		      ,
	x_loading_status           OUT NOCOPY  VARCHAR2 	              ,
	x_msg_count		   OUT NOCOPY	NUMBER			      ,
	x_msg_data		   OUT NOCOPY	VARCHAR2                      ,
        p_pmt_plan_assign_rec      IN OUT NOCOPY pmt_plan_assign_rec) IS

      l_api_name		   CONSTANT VARCHAR2(30) := 'Create_Srp_Pmt_Plan';
      l_api_version           	   CONSTANT NUMBER  := 1.0;
      l_credit_type_id             NUMBER;
      l_name                       cn_pmt_plans.name%TYPE;
      l_role_name                  cn_roles.name%TYPE;
      l_loading_status             VARCHAR2(2000);
      x_note_id                    NUMBER;
      l_note_msg                   VARCHAR2(240);

      CURSOR get_role_name IS
	 select r.name
	   from cn_roles r, cn_role_pmt_plans_all rpp
	  where r.role_id = rpp.role_id
	    and rpp.role_pmt_plan_id = p_pmt_plan_assign_rec.role_pmt_plan_id;

BEGIN
   -- Standard Start of API savepoint

   SAVEPOINT	Create_Srp_Pmt_Plan;

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

   validate_assignment
     (x_return_status	=> x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_salesrep_id	=> p_pmt_plan_assign_rec.salesrep_id,
      p_org_id          => p_pmt_plan_assign_rec.org_id,
      p_start_date      => p_pmt_plan_assign_rec.start_date,
      p_end_date        => p_pmt_plan_assign_rec.end_date,
      p_minimum_amount  => p_pmt_plan_assign_rec.minimum_amount,
      p_maximum_amount  => p_pmt_plan_assign_rec.maximum_amount,
      p_pmt_plan_id     => p_pmt_plan_assign_rec.pmt_plan_id,
      p_srp_pmt_plan_id => NULL,
      p_loading_status  => x_loading_status,
      x_loading_status  => x_loading_status);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   -- inherit credit type of pmt plan
   select credit_type_id, name into l_credit_type_id, l_name
     from cn_pmt_plans_all
    where pmt_plan_id = p_pmt_plan_assign_rec.pmt_plan_id;


   cn_srp_pmt_plans_pkg.insert_row
     ( x_srp_pmt_plan_id       => p_pmt_plan_assign_rec.srp_pmt_plan_id
      ,x_pmt_plan_id           => p_pmt_plan_assign_rec.pmt_plan_id
      ,x_salesrep_id           => p_pmt_plan_assign_rec.salesrep_id
      ,x_org_id                => p_pmt_plan_assign_rec.org_id
      ,x_role_id               => NULL
      ,x_credit_type_id        => l_credit_type_id -- obsolete
      ,x_start_date            => p_pmt_plan_assign_rec.start_date
      ,x_end_date              => p_pmt_plan_assign_rec.end_date
      ,x_minimum_amount        => p_pmt_plan_assign_rec.minimum_amount
      ,x_maximum_amount        => p_pmt_plan_assign_rec.maximum_amount
      ,x_max_recovery_amount   => NULL -- obsolete
      ,x_last_update_date      => sysdate
      ,x_last_updated_by       => fnd_global.user_id
      ,x_creation_date         => sysdate
      ,x_created_by            => fnd_global.user_id
      ,x_last_update_login     => fnd_global.login_id
      ,x_srp_role_id           => p_pmt_plan_assign_rec.srp_role_id
      ,x_role_pmt_plan_id      => p_pmt_plan_assign_rec.role_pmt_plan_id
      ,x_lock_flag             => p_pmt_plan_assign_rec.lock_flag
      );

   -- raise business event
   business_event
     (p_operation              => 'Add',
      p_pmt_plan_assign_rec    => p_pmt_plan_assign_rec);

   -- create note
   OPEN  get_role_name;
   FETCH get_role_name INTO l_role_name;
   CLOSE get_role_name;

   l_note_msg := fnd_message.get_string('CN', 'CN_SPP_CRE_NOTE');
   l_note_msg := l_note_msg || l_name || ', ' || l_role_name || ', ' ||
     p_pmt_plan_assign_rec.start_date || ', ' ||
     p_pmt_plan_assign_rec.end_date   || ', ' ||
     p_pmt_plan_assign_rec.minimum_amount || ', ' ||
     p_pmt_plan_assign_rec.maximum_amount || ', ' ||
     p_pmt_plan_assign_rec.lock_flag;

   jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => p_pmt_plan_assign_rec.salesrep_id,
       p_source_object_code    => 'CN_SALESREPS',
       p_notes                 => l_note_msg,
       p_notes_detail          => l_note_msg,
       p_note_type             => 'CN_SYSGEN', -- for system generated
       x_jtf_note_id           => x_note_id -- returned
       );

   -- populate ovn
   SELECT object_version_number
     INTO p_pmt_plan_assign_rec.object_version_number
     FROM cn_srp_pmt_plans_all
    WHERE srp_pmt_plan_id = p_pmt_plan_assign_rec.srp_pmt_plan_id;

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
      ROLLBACK TO Create_Srp_Pmt_Plan;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    (
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Srp_Pmt_Plan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Srp_Pmt_Plan;
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
END create_srp_pmt_plan;



-- --------------------------------------------------------------------------*
-- Procedure: Update_Srp_Pmt_Plan
-- --------------------------------------------------------------------------*
PROCEDURE Update_Srp_Pmt_Plan
  (  	p_api_version              IN	NUMBER				      ,
     	p_init_msg_list		   IN	VARCHAR2,
  	p_commit	    	   IN  	VARCHAR2,
  	p_validation_level	   IN  	NUMBER,
  	x_return_status		   OUT NOCOPY	VARCHAR2	     	      ,
  	x_loading_status           OUT NOCOPY  VARCHAR2                       ,
  	x_msg_count		   OUT NOCOPY	NUMBER			      ,
  	x_msg_data		   OUT NOCOPY	VARCHAR2                      ,
	p_pmt_plan_assign_rec      IN OUT NOCOPY  pmt_plan_assign_rec	) IS

   l_api_name		   CONSTANT VARCHAR2(30) := 'Update_Srp_Pmt_Plan';
   l_api_version      	   CONSTANT NUMBER  := 1.0;
   l_credit_type_id             NUMBER;

   CURSOR spp_csr( l_srp_pmt_plan_id NUMBER )  IS
    SELECT *
      FROM cn_srp_pmt_plans
      WHERE srp_pmt_plan_id = l_srp_pmt_plan_id;

    l_oldrec  spp_csr%ROWTYPE;
    l_oldname cn_pmt_plans.name%TYPE;
    l_newname cn_pmt_plans.name%TYPE;
    l_notemsg VARCHAR2(2000);


BEGIN
   -- Standard Start of API savepoint

   SAVEPOINT	Update_Srp_Pmt_Plan;

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

   -- check if the object version number is the same
   OPEN  spp_csr(p_pmt_plan_assign_rec.srp_pmt_plan_id) ;
   FETCH spp_csr INTO l_oldrec;
   CLOSE spp_csr;

   IF (l_oldrec.object_version_number <>
       p_pmt_plan_assign_rec.object_version_number) THEN

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_OBJECT_VERSION');
	 fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_OBJECT_VERSION';
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   -- can't change lock flag from Y to N
   IF l_oldrec.lock_flag = 'Y' AND p_pmt_plan_assign_rec.lock_flag = 'N' THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_CANNOT_UPDATE_LOCK');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_CANNOT_UPDATE_LOCK';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- can't change lock from N to Y if it is manual assignment
   IF l_oldrec.lock_flag = 'N' AND p_pmt_plan_assign_rec.lock_flag = 'Y' AND
     p_pmt_plan_assign_rec.role_pmt_plan_id IS NULL THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_CANNOT_UPDATE_LOCK');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_CANNOT_UPDATE_LOCK';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- validate the assignment
   validate_assignment
     (x_return_status	=> x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_salesrep_id	=> p_pmt_plan_assign_rec.salesrep_id,
      p_org_id          => p_pmt_plan_assign_rec.org_id,
      p_start_date      => p_pmt_plan_assign_rec.start_date,
      p_end_date        => p_pmt_plan_assign_rec.end_date,
      p_minimum_amount  => p_pmt_plan_assign_rec.minimum_amount,
      p_maximum_amount  => p_pmt_plan_assign_rec.maximum_amount,
      p_pmt_plan_id     => p_pmt_plan_assign_rec.pmt_plan_id,
      p_srp_pmt_plan_id => p_pmt_plan_assign_rec.srp_pmt_plan_id,
      p_loading_status  => x_loading_status,
      x_loading_status  => x_loading_status);

   -- inherit credit type of pmt plan
   select credit_type_id into l_credit_type_id
     from cn_pmt_plans_all
    where pmt_plan_id = p_pmt_plan_assign_rec.pmt_plan_id;

   -- if the lock_flag is being set, then blow away role_pmt_plan_id
   IF p_pmt_plan_assign_rec.lock_flag = 'Y' THEN
      p_pmt_plan_assign_rec.role_pmt_plan_id := NULL;
      p_pmt_plan_assign_rec.srp_role_id := NULL;
   END IF;

   -- Check if update is allowed
   IF l_oldrec.salesrep_id <> p_pmt_plan_assign_rec.salesrep_id OR
      l_oldrec.pmt_plan_id <> p_pmt_plan_assign_rec.pmt_plan_id THEN
      -- user try to change the assignment
      -- need to delete the old assginment then create the new assignment
      --
      -- Check if delete operation allowed
      --
/*      check_operation_allowed
	( x_return_status  => x_return_status,
	  x_msg_count      => x_msg_count,
	  x_msg_data       => x_msg_data,
	  p_salesrep_id    => l_oldrec.salesrep_id,
	  p_start_date     => l_oldrec.start_date,
	  p_end_date       => l_oldrec.end_date,
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status
	  );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;
  */
      -- Delete record
      cn_srp_pmt_plans_pkg.delete_row
	(x_srp_pmt_plan_id         => l_oldrec.srp_pmt_plan_id);

      -- Insert new record w/ validation
      cn_srp_pmt_plans_pkg.insert_row
	(  x_srp_pmt_plan_id       => p_pmt_plan_assign_rec.srp_pmt_plan_id
	  ,x_pmt_plan_id           => p_pmt_plan_assign_rec.pmt_plan_id
	  ,x_salesrep_id           => p_pmt_plan_assign_rec.salesrep_id
	  ,x_org_id                => p_pmt_plan_assign_rec.org_id
	  ,x_role_id               => NULL
	  ,x_credit_type_id        => l_credit_type_id -- obsolete
	  ,x_start_date            => p_pmt_plan_assign_rec.start_date
	  ,x_end_date              => p_pmt_plan_assign_rec.end_date
	  ,x_minimum_amount        => p_pmt_plan_assign_rec.minimum_amount
	  ,x_maximum_amount        => p_pmt_plan_assign_rec.maximum_amount
	  ,x_max_recovery_amount   => NULL -- obsolete
	  ,x_last_update_date      => sysdate
	  ,x_last_updated_by       => fnd_global.user_id
	  ,x_creation_date         => sysdate
	  ,x_created_by            => fnd_global.user_id
	  ,x_last_update_login     => fnd_global.login_id
	  ,x_srp_role_id           => p_pmt_plan_assign_rec.srp_role_id
	  ,x_role_pmt_plan_id      => p_pmt_plan_assign_rec.role_pmt_plan_id
	  ,x_lock_flag             => p_pmt_plan_assign_rec.lock_flag);

      -- sync ID back
      update cn_srp_pmt_plans_all
	 set srp_pmt_plan_id = l_oldrec.srp_pmt_plan_id
       where srp_pmt_plan_id = p_pmt_plan_assign_rec.srp_pmt_plan_id;

      p_pmt_plan_assign_rec.srp_pmt_plan_id := l_oldrec.srp_pmt_plan_id;

      -- Added the Min and Max or condition
      -- Kumar.
    ELSE
      /*  -- this check has already been performed
      -- just do update instead of delete/create
      IF  l_oldrec.start_date <> p_pmt_plan_assign_rec.start_date OR
	  l_oldrec.end_date   <> p_pmt_plan_assign_rec.end_date
      THEN
	 -- Check if update operation allowed
	 -- try to update start date, end date, need to check if the old_rec
	 -- already been used in worksheet during those delete dates,if so,
	 -- cannot change the date range

	 -- Added more parameters
	 check_operation_allowed
	   ( x_return_status       => x_return_status,
	     x_msg_count           => x_msg_count,
	     x_msg_data            => x_msg_data,
	     p_salesrep_id         => l_oldrec.salesrep_id,
	     p_old_start_date      => l_oldrec.start_date,
	     p_old_end_date        => l_oldrec.end_date,
	     p_start_date          => p_pmt_plan_assign_rec.start_date,
	     p_end_date            => p_pmt_plan_assign_rec.end_date,
	     p_loading_status      => x_loading_status,
	     x_loading_status      => x_loading_status
	     );

	 -- Check opeation fail
	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
	    RAISE FND_API.G_EXC_ERROR ;
	END IF;

      END IF;
	*/
      -- Update pmt plan assignment into cn_srp_pmt_plans
      cn_srp_pmt_plans_pkg.update_row
	( x_srp_pmt_plan_id       => p_pmt_plan_assign_rec.srp_pmt_plan_id
	 ,x_pmt_plan_id           => p_pmt_plan_assign_rec.pmt_plan_id
	 ,x_salesrep_id           => p_pmt_plan_assign_rec.salesrep_id
	 ,x_org_id                => p_pmt_plan_assign_rec.org_id
	 ,x_role_id               => NULL
	 ,x_credit_type_id        => l_credit_type_id -- Obsolete
	 ,x_start_date            => p_pmt_plan_assign_rec.start_date
	 ,x_end_date              => p_pmt_plan_assign_rec.end_date
	 ,x_minimum_amount        => p_pmt_plan_assign_rec.minimum_amount
	 ,x_maximum_amount        => p_pmt_plan_assign_rec.maximum_amount
	 ,x_max_recovery_amount   => NULL -- Obsolete
	 ,x_last_update_date      => sysdate
	 ,x_last_updated_by       => fnd_global.user_id
	 ,x_last_update_login     => fnd_global.login_id
	 ,x_object_version_number => p_pmt_plan_assign_rec.object_version_number
	 ,x_lock_flag             => p_pmt_plan_assign_rec.lock_flag
	  );

      -- if the lock_flag is being set, then blow away role_pmt_plan_id
      IF p_pmt_plan_assign_rec.lock_flag = 'Y' THEN
	 UPDATE cn_srp_pmt_plans_all
	    SET role_pmt_plan_id = NULL,
	        srp_role_id = NULL
	  WHERE srp_pmt_plan_id = p_pmt_plan_assign_rec.srp_pmt_plan_id;
      END IF;

   END IF;

   -- raise business event
   business_event
     (p_operation              => 'Update',
      p_pmt_plan_assign_rec    => p_pmt_plan_assign_rec);


   -- build notes
   l_notemsg := NULL;

   -- raise notes
   IF l_oldrec.pmt_plan_id <> p_pmt_plan_assign_rec.pmt_plan_id THEN
      SELECT name INTO l_oldname FROM cn_pmt_plans_all
	WHERE pmt_plan_id = l_oldrec.pmt_plan_id;
      SELECT name INTO l_newname FROM cn_pmt_plans_all
	WHERE pmt_plan_id = p_pmt_plan_assign_rec.pmt_plan_id;
      get_note('PMT_PLAN', l_oldname, l_newname, l_notemsg);
   END IF;

   IF l_oldrec.start_date <> p_pmt_plan_assign_rec.start_date THEN
      get_note('START_DATE', l_oldrec.start_date, p_pmt_plan_assign_rec.start_date, l_notemsg);
   END IF;

   IF Nvl(l_oldrec.end_date, fnd_api.g_miss_date) <> Nvl(p_pmt_plan_assign_rec.end_date, fnd_api.g_miss_date) THEN
      get_note('END_DATE', l_oldrec.end_date, p_pmt_plan_assign_rec.end_date, l_notemsg);
   END IF;

   IF Nvl(l_oldrec.minimum_amount, -1) <> Nvl(p_pmt_plan_assign_rec.minimum_amount, -1) THEN
      get_note('MIN_AMT', l_oldrec.minimum_amount, p_pmt_plan_assign_rec.minimum_amount, l_notemsg);
   END IF;

   IF Nvl(l_oldrec.maximum_amount, -1) <> Nvl(p_pmt_plan_assign_rec.maximum_amount, -1) THEN
      get_note('MAX_AMT', l_oldrec.maximum_amount, p_pmt_plan_assign_rec.maximum_amount, l_notemsg);
   END IF;

   IF l_oldrec.lock_flag <> p_pmt_plan_assign_rec.lock_flag THEN
      get_note('LOCK_FLAG', l_oldrec.lock_flag, p_pmt_plan_assign_rec.lock_flag, l_notemsg);
   END IF;

   IF (l_notemsg IS NOT NULL) THEN
      raise_note(p_pmt_plan_assign_rec.srp_pmt_plan_id, l_notemsg);
   END IF;

   -- pick up new object version number
   SELECT object_version_number
     INTO p_pmt_plan_assign_rec.object_version_number
     FROM cn_srp_pmt_plans_all
    WHERE srp_pmt_plan_id = p_pmt_plan_assign_rec.srp_pmt_plan_id;
   -- End of API body.

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
      ROLLBACK TO Update_Srp_Pmt_Plan;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    (
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Srp_Pmt_Plan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Srp_Pmt_Plan;
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

END update_srp_pmt_plan;

-- --------------------------------------------------------------------------*
-- Procedure: Valid_Delete_Srp_Pmt_Plan
-- --------------------------------------------------------------------------*
PROCEDURE valid_delete_srp_pmt_plan
  (  	p_srp_pmt_plan_id          IN   NUMBER,
     	p_init_msg_list		   IN	VARCHAR2,
  	x_loading_status	   OUT NOCOPY	VARCHAR2	     	      ,
  	x_return_status		   OUT NOCOPY	VARCHAR2	     	      ,
  	x_msg_count		   OUT NOCOPY	NUMBER			      ,
  	x_msg_data		   OUT NOCOPY	VARCHAR2
	) IS

   l_api_name		   CONSTANT VARCHAR2(30) := 'Valid_Delete_Srp_Pmt_Plan';

   CURSOR spp_csr( l_srp_pmt_plan_id NUMBER )  IS
    SELECT *
      FROM cn_srp_pmt_plans
      WHERE srp_pmt_plan_id = l_srp_pmt_plan_id;

    l_spp_rec spp_csr%ROWTYPE;

BEGIN
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_DELETED';


   --
   -- Check if delete operation allowed
   --
   OPEN  spp_csr(p_srp_pmt_plan_id);
   FETCH spp_csr INTO l_spp_rec;
   CLOSE spp_csr;
/*
   IF (NVL(l_spp_rec.lock_flag, 'N') = 'Y') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.Set_Name('CN', 'CN_SRP_PMT_PLAN_LOCKED');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_SRP_PMT_PLAN_LOCKED';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   check_operation_allowed
     ( x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_salesrep_id    => l_spp_rec.salesrep_id,
       p_start_date     => l_spp_rec.start_date,
       p_end_date       => l_spp_rec.end_date,
       p_loading_status => x_loading_status,
       x_loading_status => x_loading_status
       );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
  */
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


END valid_delete_srp_pmt_plan;

-- --------------------------------------------------------------------------*
-- Procedure: Delete_Srp_Pmt_Plan
-- --------------------------------------------------------------------------*
PROCEDURE Delete_Srp_Pmt_Plan
  (  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2,
	p_commit	    	   IN  	VARCHAR2,
	p_validation_level	   IN  	NUMBER,
	x_return_status		   OUT NOCOPY	VARCHAR2	     	      ,
	x_loading_status           OUT NOCOPY  VARCHAR2 	              ,
	x_msg_count		   OUT NOCOPY	NUMBER		    	      ,
	x_msg_data		   OUT NOCOPY	VARCHAR2               	      ,
        p_srp_pmt_plan_id          IN   NUMBER) IS

      l_api_name		   CONSTANT VARCHAR2(30) := 'Delete_Srp_Pmt_Plan';
      l_api_version           	   CONSTANT NUMBER  := 1.0;
      x_note_id                    NUMBER;
      l_note_msg                   VARCHAR2(240);
      l_pmt_plan_assign_rec        pmt_plan_assign_rec;

      CURSOR spp_info_cur IS
	 select p.name, r.name role_name, spp.start_date, spp.end_date, spp.minimum_amount, spp.maximum_amount, spp.lock_flag, spp.salesrep_id
	   from cn_srp_pmt_plans_all spp, cn_pmt_plans_all p, cn_role_pmt_plans_all rpp, cn_roles r
	   where spp.srp_pmt_plan_id = p_srp_pmt_plan_id
	   and spp.role_pmt_plan_id = rpp.role_pmt_plan_id(+)
	   and spp.pmt_plan_id = p.pmt_plan_id
	   and rpp.role_id = r.role_id(+);

      spp_info spp_info_cur%ROWTYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	delete_srp_pmt_plan;

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
   valid_delete_srp_pmt_plan
     (	p_srp_pmt_plan_id          => p_srp_pmt_plan_id,
	p_init_msg_list            => p_init_msg_list,
  	x_loading_status	   => x_loading_status,
	x_return_status		   => x_return_status,
  	x_msg_count		   => x_msg_count,
  	x_msg_data		   => x_msg_data);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   -- create note
   OPEN  spp_info_cur;
   FETCH spp_info_cur INTO spp_info;
   CLOSE spp_info_cur;

   l_note_msg := fnd_message.get_string('CN', 'CN_SPP_DEL_NOTE');
   l_note_msg := l_note_msg || spp_info.name || ', ' ||
     spp_info.role_name || ', ' ||
     spp_info.start_date || ', ' ||
     spp_info.end_date   || ', ' ||
     spp_info.minimum_amount || ', ' ||
     spp_info.maximum_amount || ', ' ||
     spp_info.lock_flag;

   jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => spp_info.salesrep_id,
       p_source_object_code    => 'CN_SALESREPS',
       p_notes                 => l_note_msg,
       p_notes_detail          => l_note_msg,
       p_note_type             => 'CN_SYSGEN', -- for system generated
       x_jtf_note_id           => x_note_id -- returned
       );

   -- Delete record
   cn_srp_pmt_plans_pkg.delete_row
     (x_srp_pmt_plan_id      => p_srp_pmt_plan_id);

   -- raise business event
   l_pmt_plan_assign_rec.srp_pmt_plan_id := p_srp_pmt_plan_id;
   business_event
     (p_operation              => 'Remove',
      p_pmt_plan_assign_rec    => l_pmt_plan_assign_rec);

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
      ROLLBACK TO Delete_Srp_Pmt_Plan;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    (
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Srp_Pmt_Plan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Srp_Pmt_Plan;
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
END Delete_Srp_Pmt_Plan;

-- --------------------------------------------------------------------------*
-- Procedure: Create_Mass_Asgn_Srp_Pmt_plan
-- --------------------------------------------------------------------------*

PROCEDURE Create_Mass_Asgn_Srp_Pmt_Plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pmt_plan_id   IN    NUMBER,
   x_srp_pmt_plan_id    OUT NOCOPY  NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   ) IS

      l_api_name		   CONSTANT VARCHAR2(30) := 'Create_Mass_Asgn_Srp_Pmt_Plan';
      l_api_version           	   CONSTANT NUMBER  := 1.0;
      l_return_status        VARCHAR2(2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_pmt_plan_id      cn_srp_pmt_plans.srp_pmt_plan_id%TYPE;
      l_loading_status       VARCHAR2(2000);

      newrec                 pmt_plan_assign_rec;
      l_salesrep_id          cn_salesreps.salesrep_id%TYPE;
      l_pmt_plan_id	     cn_pmt_plans.pmt_plan_id%TYPE;
      l_org_id              cn_pmt_plans.org_id%TYPE;
      l_min_amt		     cn_pmt_plans.minimum_amount%TYPE;
      l_max_amt		     cn_pmt_plans.maximum_amount%TYPE;
      l_pp_start_date        cn_pmt_plans.start_date%TYPE;
      l_pp_end_date	     cn_pmt_plans.end_date%TYPE;
      l_srp_start_date       cn_srp_roles.start_date%TYPE;
      l_srp_end_date	     cn_pmt_plans.end_date%TYPE;
      l_start_date           cn_srp_pmt_plans.start_date%TYPE;
      l_end_date             cn_srp_pmt_plans.start_date%TYPE;

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT	Create_Mass_Asgn_Srp_Pmt_Plan;

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
   x_loading_status := 'CN_PP_CREATED';

     select pmt_plan_id, start_date, end_date
     into l_pmt_plan_id, l_pp_start_date, l_pp_end_date
     from cn_role_pmt_plans
     where role_pmt_plan_id = p_role_pmt_plan_id;

     select minimum_amount, maximum_amount, org_id
     into l_min_amt, l_max_amt, l_org_id
     from cn_pmt_plans
     where pmt_plan_id = l_pmt_plan_id;

     select salesrep_id, start_date, end_date
     into l_salesrep_id, l_srp_start_date, l_srp_end_date
     from cn_srp_roles
     where srp_role_id = p_srp_role_id
     and org_id = l_org_id;

     l_start_date := NULL;
     l_end_date   := NULL;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     -- Start: Bug fix 5480386 5480540 CHANTHON
     get_masgn_date_intersect(
         	p_srp_role_id   => p_srp_role_id,
         	p_role_pmt_plan_id   => p_role_pmt_plan_id,
         	x_start_date => l_start_date,
            x_end_date   => l_end_date);


    /*     if cn_api.date_range_overlap(
	a_start_date => l_srp_start_date,
        a_end_date   => l_srp_end_date,
        b_start_date => l_pp_start_date,
        b_end_date   => l_pp_end_date
     )  THEN

     cn_api.get_date_range_intersect(
	 	a_start_date => l_srp_start_date,
         	a_end_date   => l_srp_end_date,
         	b_start_date => l_pp_start_date,
         	b_end_date   => l_pp_end_date,
         	x_start_date => l_start_date,
         	x_end_date   => l_end_date); */
     -- End: Bug fix 5480386 5480540 CHANTHON

     newrec.salesrep_id    := l_salesrep_id;
     newrec.pmt_plan_id    := l_pmt_plan_id;
     newrec.minimum_amount := l_min_amt;
     newrec.maximum_amount := l_max_amt;
     newrec.start_date     := l_start_date;
     newrec.end_date       := l_end_date;
     newrec.srp_role_id      := p_srp_role_id;
     newrec.role_pmt_plan_id := p_role_pmt_plan_id;
     newrec.org_id := l_org_id;
     newrec.lock_flag := 'N';


     create_srp_pmt_plan
       (p_api_version        => p_api_version,
	p_init_msg_list      => p_init_msg_list,
	p_commit             => p_commit,
	p_validation_level   => p_validation_level,
	x_return_status      => l_return_status,
	x_msg_count          => l_msg_count,
	x_msg_data           => l_msg_data,
	p_pmt_plan_assign_rec=> newrec,
	x_loading_status     => l_loading_status);

     /*
     IF l_return_status <> fnd_api.g_ret_sts_success THEN
	RAISE fnd_api.g_exc_error;
     END IF;
     */
     l_return_status:=FND_API.G_RET_STS_SUCCESS;
     x_return_status     := l_return_status;
     x_loading_status    := l_loading_status;

--     END IF;

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
      ROLLBACK TO Create_Mass_Asgn_Srp_Pmt_Plan;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    (
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Mass_Asgn_Srp_Pmt_Plan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Mass_Asgn_Srp_Pmt_Plan;
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

END Create_Mass_Asgn_Srp_Pmt_Plan;

-- --------------------------------------------------------------------------*
-- Procedure: Update_Mass_Asgn_Srp_Pmt_plan
-- --------------------------------------------------------------------------*

PROCEDURE Update_Mass_Asgn_Srp_Pmt_plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pmt_plan_id   IN    NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   ) IS

      l_api_name		   CONSTANT VARCHAR2(30) := 'Update_Mass_Asgn_Srp_Pmt_Plan';
      l_api_version           	   CONSTANT NUMBER  := 1.0;
      l_return_status        VARCHAR2(2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_pmt_plan_id      cn_srp_pmt_plans.srp_pmt_plan_id%TYPE;
      l_loading_status       VARCHAR2(2000);
      l_count               NUMBER;
      l_count_srp_pmt_plan            NUMBER;

      newrec                     pmt_plan_assign_rec;
      l_salesrep_id_old          cn_salesreps.salesrep_id%TYPE;
      l_salesrep_id_new          cn_salesreps.salesrep_id%TYPE;
      l_pmt_plan_id_new	         cn_pmt_plans.pmt_plan_id%TYPE;
      l_org_id                   cn_pmt_plans.org_id%TYPE;
      l_min_amt_new		 cn_pmt_plans.minimum_amount%TYPE;
      l_max_amt_new		 cn_pmt_plans.maximum_amount%TYPE;
      l_pp_start_date_new        cn_pmt_plans.start_date%TYPE;
      l_pp_end_date_new	         cn_pmt_plans.end_date%TYPE;
      l_srp_start_date_new       cn_srp_roles.start_date%TYPE;
      --l_srp_end_date_new	 cn_pmt_plans.end_date%TYPE;
      l_srp_end_date_new	 cn_srp_roles.end_date%TYPE;
      l_start_date_old           cn_srp_pmt_plans.start_date%TYPE;
      l_start_date_new           cn_srp_pmt_plans.start_date%TYPE;
      l_end_date_old             cn_srp_pmt_plans.start_date%TYPE;
      l_end_date_new             cn_srp_pmt_plans.start_date%TYPE;
      l_role_pp_start_date       cn_role_pmt_plans.start_date%TYPE;
      l_role_pp_end_date         cn_role_pmt_plans.end_date%TYPE;

      --Added payment group code for bug 3560026 by Julia Huang on 4/7/2004.
      l_pgc                     cn_pmt_plans.payment_group_code%TYPE;
      l_worksheets NUMBER;
      l_end_of_time        CONSTANT DATE := To_date('31-12-9999', 'DD-MM-YYYY');

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT	Update_Mass_Asgn_Srp_Pmt_plan;

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
   x_loading_status := 'CN_PP_UPDATED';

    select org_id into l_org_id
    from cn_role_pmt_plans
    where role_pmt_plan_id = p_role_pmt_plan_id;

    select salesrep_id
    into l_salesrep_id_old
    from cn_srp_roles
    where srp_role_id = p_srp_role_id
    and org_id = l_org_id;

     --Added to check if the role_pay_group_id is existing in cn_srp_pmt_plans
     select count(*) into l_count  from cn_srp_pmt_plans
       where salesrep_id = l_salesrep_id_old
       AND srp_role_id = p_srp_role_id
     AND role_pmt_plan_id = p_role_pmt_plan_id;

    IF (l_count <> 0)
    THEN
       --Bug 3670276 by Julia Huang on 6/4/04 to avoid the following
       --1.Cartesian join.  Line changed: AND spp.role_pmt_plan_id = crpp.role_pmt_plan_id --p_role_pmt_plan_id
       --2.Full Table Scan.  Added 1 index: create index cn_srp_pmt_plans_n1 ON cn_srp_pmt_plans_all(srp_role_id,org_id)
       select spp.start_date, spp.end_date, spp.salesrep_id,
              crpp.start_date, crpp.end_date, spp.srp_pmt_plan_id
       into   l_start_date_old, l_end_date_old, l_salesrep_id_old,
              l_role_pp_start_date, l_role_pp_end_date, l_srp_pmt_plan_id
       from cn_srp_pmt_plans_all spp, cn_pmt_plans_all cpp, cn_role_pmt_plans_all crpp
       where spp.srp_role_id = p_srp_role_id
       AND spp.role_pmt_plan_id = crpp.role_pmt_plan_id --p_role_pmt_plan_id
       AND crpp.role_pmt_plan_id = p_role_pmt_plan_id
       AND cpp.pmt_plan_id = spp.pmt_plan_id;

    END IF;

     select pmt_plan_id, start_date, end_date
     into l_pmt_plan_id_new, l_pp_start_date_new, l_pp_end_date_new
     from cn_role_pmt_plans
     where role_pmt_plan_id = p_role_pmt_plan_id;

     --Added payment group code for bug 3560026 by Julia Huang on 4/7/2004.
     select minimum_amount, maximum_amount, payment_group_code, org_id
     into l_min_amt_new, l_max_amt_new, l_pgc, l_org_id
     from cn_pmt_plans
     where pmt_plan_id = l_pmt_plan_id_new;

     select salesrep_id, start_date, end_date
     into l_salesrep_id_new, l_srp_start_date_new, l_srp_end_date_new
     from cn_srp_roles
     where srp_role_id = p_srp_role_id
     and org_id = l_org_id;

    --Added to check if the a record exists in cn_srp_pmt_plans for the dates passed for bug 3147026
    /*  Commented out by Julia Huang for bug 3560026 by Julia Huang on 4/7/2004
     select count(*) into l_count_srp_pmt_plan from cn_srp_pmt_plans where salesrep_id=l_salesrep_id_old
      and ((l_pp_start_date_new between start_date and nvl(end_date,l_null_date))
        or (nvl(l_pp_end_date_new,l_null_date) between start_date and nvl(end_date,l_null_date)));
        */
    SELECT COUNT(*) INTO l_count_srp_pmt_plan
    FROM cn_srp_pmt_plans cspp, cn_pmt_plans cpp
    WHERE cspp.salesrep_id = l_salesrep_id_old
    AND ((l_pp_start_date_new BETWEEN cspp.start_date AND NVL(cspp.end_date,l_pp_start_date_new))
        OR (NVL(l_pp_end_date_new,l_pp_start_date_new) BETWEEN cspp.start_date AND NVL(cspp.end_date,l_pp_end_date_new)))
    AND cspp.pmt_plan_id = cpp.pmt_plan_id
    AND cpp.payment_group_code = l_pgc;

     l_start_date_new := NULL;
     l_end_date_new   := NULL;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     if cn_api.date_range_overlap(
	a_start_date => l_srp_start_date_new,
        a_end_date   => l_srp_end_date_new,
        b_start_date => l_pp_start_date_new,
        b_end_date   => l_pp_end_date_new
     )  THEN

	/* Bug No 5525456 */

	get_masgn_date_intersect(
        p_role_pmt_plan_id,
        p_srp_role_id,
        x_start_date => l_start_date_new,
        x_end_date   => l_end_date_new);

     newrec.salesrep_id    := l_salesrep_id_new;
     newrec.srp_pmt_plan_id:= l_srp_pmt_plan_id;
     newrec.pmt_plan_id    := l_pmt_plan_id_new;
     newrec.minimum_amount := l_min_amt_new;
     newrec.maximum_amount := l_max_amt_new;
     newrec.start_date     := l_start_date_new;
     newrec.end_date       := l_end_date_new;
     newrec.lock_flag      := 'N';
     newrec.srp_role_id      := p_srp_role_id;
     newrec.role_pmt_plan_id := p_role_pmt_plan_id;
     newrec.org_id := l_org_id;

     if (l_count>0) then

      SELECT count(*) into l_worksheets
  	  FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,
	     cn_payruns_all prun, cn_srp_pmt_plans_all spp
	  WHERE w.salesrep_id = spp.salesrep_id
	  AND   w.quota_id is null
	  AND   prun.pay_period_id = prd.period_id
	  AND   prun.org_id        = prd.org_id
	  AND   prun.payrun_id     = w.payrun_id
	  AND  spp.srp_pmt_plan_id = l_srp_pmt_plan_id
	  AND (((spp.end_date IS NOT NULL) AND (prd.end_date IS NOT NULL)
	       AND (prd.start_date <= spp.end_date)
	       AND (prd.end_date >= spp.start_date))
	      OR ((spp.end_date IS NULL) AND (prd.end_date IS NOT NULL)
		  AND (prd.end_date >= spp.start_date))
	      OR ((spp.end_date IS NULL) AND (prd.end_date IS NULL)))
     AND (NVL(l_end_date_new, l_end_of_time) < NVL(prd.end_date, l_end_of_time)
     OR l_start_date_new > prd.start_date);

     IF (l_worksheets = 0) THEN

	update_srp_pmt_plan
	  (
	   p_api_version        => p_api_version,
	   p_init_msg_list      => p_init_msg_list,
	   p_commit             => p_commit,
	   p_validation_level   => p_validation_level,
	   x_return_status      => l_return_status,
	   x_msg_count          => l_msg_count,
	   x_msg_data           => l_msg_data,
           p_pmt_plan_assign_rec=> newrec,
	   x_loading_status     => l_loading_status);

     /*
     IF l_return_status <> fnd_api.g_ret_sts_success THEN
	RAISE fnd_api.g_exc_error;
     END IF;
     */
     l_return_status:=FND_API.G_RET_STS_SUCCESS;
     x_return_status     := l_return_status;
     x_loading_status    := l_loading_status;

 	 ELSE
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('CN', 'CN_SPP_UPDATE_NOT_ALLOWED');
         FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
 	 END IF;

	--  Added to create a cn_srp_pmt_plan record if there are no records for the the date range for bug 3147026
     	 ELSIF (l_count_srp_pmt_plan = 0 )
	 THEN

       SELECT count(*)
       INTO l_count_srp_pmt_plan
       FROM cn_srp_pmt_plans
       WHERE salesrep_id = l_salesrep_id_new
       AND org_id = l_org_id
       AND ((l_start_date_new between start_date and nvl(end_date,l_end_of_time))
       OR (nvl(l_end_date_new,l_end_of_time) between
       start_date and nvl(end_date,l_end_of_time)));

       IF (l_count_srp_pmt_plan = 0) THEN
	   Create_Srp_Pmt_Plan
	     (
	      p_api_version        => p_api_version,
	      p_init_msg_list      => p_init_msg_list,
	      p_commit             => p_commit,
	      p_validation_level   => p_validation_level,
	      x_return_status      => l_return_status,
	      x_msg_count          => l_msg_count,
	      x_msg_data           => l_msg_data,
	      p_pmt_plan_assign_rec=> newrec,
	      x_loading_status     => l_loading_status
	      );

	 /*
	 IF l_return_status <> fnd_api.g_ret_sts_success THEN
	 RAISE fnd_api.g_exc_error;
         END IF;
         */
         l_return_status:=FND_API.G_RET_STS_SUCCESS;
	 x_return_status     := l_return_status;
	 x_loading_status    := l_loading_status;
        END IF;
	END IF;

     ELSE

	-- only delete if exists
	IF l_srp_pmt_plan_id IS NOT NULL THEN
	   delete_srp_pmt_plan
	     (p_api_version        => p_api_version,
	      p_init_msg_list      => p_init_msg_list,
	      p_commit             => p_commit,
	      p_validation_level   => p_validation_level,
	      x_return_status      => l_return_status,
	      x_msg_count          => l_msg_count,
	      x_msg_data           => l_msg_data,
	      p_srp_pmt_plan_id    => l_srp_pmt_plan_id,
	      x_loading_status     => l_loading_status);

	   /*
	   IF l_return_status <> fnd_api.g_ret_sts_success THEN
	   RAISE fnd_api.g_exc_error;
	   END IF;
	   */
           l_return_status:=FND_API.G_RET_STS_SUCCESS;
	   x_return_status     := l_return_status;
	   x_loading_status    := l_loading_status;
	END IF;
     END IF;

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
      ROLLBACK TO Update_Mass_Asgn_Srp_Pmt_plan;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    (
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Mass_Asgn_Srp_Pmt_plan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Mass_Asgn_Srp_Pmt_plan;
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

End Update_Mass_Asgn_Srp_Pmt_plan;


-- --------------------------------------------------------------------------*
-- Procedure: Delete_Mass_Asgn_Srp_Pmt_plan
-- --------------------------------------------------------------------------*

PROCEDURE Delete_Mass_Asgn_Srp_Pmt_Plan
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pmt_plan_id   IN    NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   ) IS

      l_api_name		   CONSTANT VARCHAR2(30) := 'Delete_Mass_Asgn_Srp_Pmt_Plan';
      l_api_version           	   CONSTANT NUMBER  := 1.0;
      l_return_status        VARCHAR2(2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_pmt_plan_id      cn_srp_pmt_plans.srp_pmt_plan_id%TYPE;
      l_loading_status       VARCHAR2(2000);

      newrec                 CN_SRP_PMT_PLANS_PUB.srp_pmt_plans_rec_type;
      l_salesrep_id          cn_salesreps.salesrep_id%TYPE;
      l_pmt_plan_id	     cn_pmt_plans.pmt_plan_id%TYPE;
      l_min_amt		     cn_pmt_plans.minimum_amount%TYPE;
      l_max_amt		     cn_pmt_plans.maximum_amount%TYPE;
      l_pp_start_date        cn_pmt_plans.start_date%TYPE;
      l_pp_end_date	     cn_pmt_plans.end_date%TYPE;
      l_srp_start_date       cn_srp_roles.start_date%TYPE;
      l_srp_end_date	     cn_pmt_plans.end_date%TYPE;
      l_start_date           cn_srp_pmt_plans.start_date%TYPE;
      l_end_date             cn_srp_pmt_plans.start_date%TYPE;
      l_role_pp_start_date   cn_role_pmt_plans.start_date%TYPE;
      l_role_pp_end_date     cn_role_pmt_plans.end_date%TYPE;


   CURSOR spp_csr( l_srp_pmt_plan_id NUMBER )  IS
    SELECT *
      FROM cn_srp_pmt_plans
      WHERE srp_pmt_plan_id = l_srp_pmt_plan_id;

    l_spp_rec spp_csr%ROWTYPE;
    l_dummy NUMBER;


BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT	Delete_Mass_Asgn_Srp_Pmt_Plan;

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
   x_loading_status := 'CN_PP_DELETED';

    BEGIN

       --Bug 3670276 by Julia Huang on 6/4/04 to avoid the following
       --1.Cartesian join.  Line changed: AND spp.role_pmt_plan_id = crpp.role_pmt_plan_id --p_role_pmt_plan_id
       --2.Full Table Scan.  Added 1 index: create index cn_srp_pmt_plans_n1 ON cn_srp_pmt_plans_all(srp_role_id,org_id)
       select spp.start_date, spp.end_date, spp.salesrep_id,
              cpp.minimum_amount, cpp.maximum_amount,
              crpp.start_date, crpp.end_date, spp.srp_pmt_plan_id
       into   l_start_date, l_end_date, l_salesrep_id,
              l_min_amt, l_max_amt,
              l_role_pp_start_date, l_role_pp_end_date, l_srp_pmt_plan_id
       from cn_srp_pmt_plans spp, cn_pmt_plans cpp, cn_role_pmt_plans crpp
       where spp.srp_role_id = p_srp_role_id
       AND spp.role_pmt_plan_id = crpp.role_pmt_plan_id --p_role_pmt_plan_id
       AND crpp.role_pmt_plan_id = p_role_pmt_plan_id
       AND cpp.pmt_plan_id = spp.pmt_plan_id;
     EXCEPTION
       WHEN no_data_found THEN
         null;
     END;

     IF ((l_salesrep_id IS NOT NULL)

        AND

        (cn_api.date_range_within(
		a_start_date => l_start_date,
         	a_end_date   => l_end_date,
         	b_start_date => l_role_pp_start_date,
         	b_end_date   => l_role_pp_end_date
	)))


	THEN

     --***********************************************************************
     -- Added by CHANTHON on 21-Aug-2006
     -- Bug 5465072
     -- Moved the code for checking valid delete from check_operation_allowed
     -- procedure to this method. This is to validate the resource's payment
     -- plan when deleting the mass assignment. If the resource has worksheets
     -- then the resource assignment is severed from the role and acts as a
     -- direct assignment. If no worksheets then the payment plan is deleted.
     --***********************************************************************

      OPEN  spp_csr(l_srp_pmt_plan_id);
      FETCH spp_csr INTO l_spp_rec;
      CLOSE spp_csr;


      SELECT COUNT(1) INTO l_dummy
	  FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,
	       cn_payruns_all prun, cn_payment_transactions_all pmttrans
	  WHERE w.salesrep_id = l_spp_rec.salesrep_id
            AND w.salesrep_id = pmttrans.credited_salesrep_id
            AND pmttrans.incentive_type_code = 'PMTPLN'
	    AND   prun.pay_period_id = prd.period_id
	    AND   prun.org_id        = prd.org_id
            AND   prun.payrun_id     = w.payrun_id
	    AND ( ((l_spp_rec.end_date IS NOT NULL) AND (prd.end_date IS NOT NULL)
		   AND (prd.start_date <= l_spp_rec.end_date)
		   AND (prd.end_date >= l_spp_rec.start_date))
		  OR ((l_spp_rec.end_date IS NULL) AND (prd.end_date IS NOT NULL)
		      AND (prd.end_date >= l_spp_rec.start_date))
		  OR ((l_spp_rec.end_date IS NULL) AND (prd.end_date IS NULL))
		  );

     IF l_dummy > 0 then
--	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
--	   FND_MESSAGE.SET_NAME ('CN' , 'CN_SRP_PMT_PLAN_USED');
--	   FND_MSG_PUB.Add;
    update cn_srp_pmt_plans set srp_role_id = null, role_pmt_plan_id = null
    where srp_pmt_plan_id = l_srp_pmt_plan_id;

     ElSIF l_dummy = 0 THEN

	delete_srp_pmt_plan
	  (p_api_version        => p_api_version,
	   p_init_msg_list      => p_init_msg_list,
	   p_commit             => p_commit,
	   p_validation_level   => p_validation_level,
	   x_return_status      => l_return_status,
	   x_msg_count          => l_msg_count,
	   x_msg_data           => l_msg_data,
	   p_srp_pmt_plan_id    => l_srp_pmt_plan_id,
	   x_loading_status     => l_loading_status);
    END IF;

	/*
	IF l_return_status <> fnd_api.g_ret_sts_success THEN
	RAISE fnd_api.g_exc_error;
	END IF;
	*/
	l_return_status:=FND_API.G_RET_STS_SUCCESS;

	x_return_status     := l_return_status;
	x_loading_status    := l_loading_status;

     END IF;

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
      ROLLBACK TO Delete_Mass_Asgn_Srp_Pmt_Plan;
      x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    (
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Mass_Asgn_Srp_Pmt_Plan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Mass_Asgn_Srp_Pmt_Plan;
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

END Delete_Mass_Asgn_Srp_Pmt_Plan;

END cn_srp_pmt_plans_pvt;

/
