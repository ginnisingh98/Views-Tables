--------------------------------------------------------
--  DDL for Package Body CN_GET_COMM_SUMM_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_GET_COMM_SUMM_DATA" AS
  /*$Header: cnvcommb.pls 115.5 2001/01/23 13:27:46 pkm ship     $*/

-- Main query. This will be a main cursor in the api
-- Each returned record represents a row in the report

--{{{ this is for where a user ID is specified
CURSOR main_cur(p_period_id in number) IS
   -- for sales online users
  SELECT  rep.name                  salesrep_name,
          rep.employee_number       salesrep_no,
          rep.cost_center           home_cc,
          rep.charge_to_cost_center charge_cc,
          rep.currency_code         currency,
          u.user_name               analyst_name,
          role.name                 role_name,
          plan.name                 comp_plan_name,
          assign.srp_plan_assign_id srp_plan_assign_id
     FROM cn_srp_plan_assigns       assign,
          fnd_user                  u,
          cn_salesreps              rep,
          cn_comp_plans             plan,
          cn_roles                  role,
          cn_period_statuses        ps,
          jtf_rs_resource_extns     re
    WHERE re.user_id = fnd_global.user_id
      AND re.resource_id = rep.resource_id
      AND rep.assigned_to_user_id = u.user_id (+)
      AND assign.salesrep_id = rep.salesrep_id
      AND ps.period_id = p_period_id
      AND ps.start_date <= nvl(assign.end_date, ps.start_date)
      AND ps.end_date >= assign.start_date
      AND plan.comp_plan_id = assign.comp_plan_id
      AND assign.role_id = role.role_id
    ORDER BY 1;
--}}}

--{{{ for SFP users selecting a specific analyst ID
CURSOR main_cur2(p_user_id in number, p_period_id in number) IS
  SELECT  rep.name                  salesrep_name,
          rep.employee_number       salesrep_no,
          rep.cost_center           home_cc,
          rep.charge_to_cost_center charge_cc,
          rep.currency_code         currency,
          u.user_name               analyst_name,
          role.name                 role_name,
          plan.name                 comp_plan_name,
          assign.srp_plan_assign_id srp_plan_assign_id
     FROM cn_srp_plan_assigns       assign,
          fnd_user                  u,
          cn_salesreps              rep,
          cn_comp_plans             plan,
          cn_roles                  role,
          cn_period_statuses        ps
    WHERE u.user_id = p_user_id
      AND rep.assigned_to_user_id = u.user_id
      AND assign.salesrep_id = rep.salesrep_id
      AND ps.period_id = p_period_id
      AND ps.start_date <= nvl(assign.end_date, ps.start_date)
      AND ps.end_date >= assign.start_date
      AND plan.comp_plan_id = assign.comp_plan_id
      AND assign.role_id = role.role_id
    ORDER BY 1;
--}}}

--{{{ for SFP users not selecting a specific analyst ID
CURSOR main_cur3(p_period_id in number) IS
  SELECT  rep.name                  salesrep_name,
          rep.employee_number       salesrep_no,
          rep.cost_center           home_cc,
          rep.charge_to_cost_center charge_cc,
          rep.currency_code         currency,
          u.user_name               analyst_name,
          role.name                 role_name,
          plan.name                 comp_plan_name,
          assign.srp_plan_assign_id srp_plan_assign_id
     FROM cn_srp_plan_assigns       assign,
          fnd_user                  u,
          cn_salesreps              rep,
          cn_comp_plans             plan,
          cn_roles                  role,
          cn_period_statuses        ps
    WHERE rep.assigned_to_user_id = u.user_id (+)
      AND assign.salesrep_id = rep.salesrep_id
      AND ps.period_id = p_period_id
      AND ps.start_date <= nvl(assign.end_date, ps.start_date)
      AND ps.end_date >= assign.start_date
      AND plan.comp_plan_id = assign.comp_plan_id
      AND assign.role_id = role.role_id
    ORDER BY 1;
--}}}

--{{{ to populate the record type from the cursor and get balances
FUNCTION query_row(main IN OUT main_cur%rowtype,
                   p_period_id IN NUMBER,
                   p_credit_type_id IN NUMBER) RETURN comm_summ_rec_type IS

   CURSOR get_balances
     (l_srp_plan_assign_id   IN NUMBER) IS
	select nvl(sum((nvl(balance2_bbd, 0) - nvl(balance2_bbc, 0)) +
		       (nvl(balance10_bbd,0) - nvl(balance10_bbc,0)) +
		       (nvl(balance28_bbd,0) - nvl(balance28_bbc,0))),0) begin_balance,
	       nvl(sum((nvl(balance2_dtd, 0) - nvl(balance2_ctd, 0)) +
		       (nvl(balance10_dtd,0) - nvl(balance10_ctd,0))),0) earnminuspay,
	       nvl(sum((nvl(balance28_dtd,0) - nvl(balance28_ctd,0))),0) draw
	  from cn_srp_periods p, cn_srp_plan_assigns spa
	 where spa.srp_plan_assign_id = l_srp_plan_assign_id
	   and p.salesrep_id     = spa.salesrep_id
	   and p.credit_type_id  = p_credit_type_id
	   and p.role_id         = spa.role_id
	   and p.period_id       = p_period_id;

   l_rec comm_summ_rec_type;
BEGIN
   -- general info
   l_rec.name                  := main.salesrep_name;
   l_rec.emp_num               := main.salesrep_no;
   l_rec.cost_center           := main.home_cc;
   l_rec.charge_to_cost_center := main.charge_cc;
   l_rec.analyst_name          := main.analyst_name;
   l_rec.role_name             := main.role_name;
   l_rec.plan_name             := main.comp_plan_name;
   l_rec.srp_plan_assign_id    := main.srp_plan_assign_id;

   -- balances
   for c in get_balances(main.srp_plan_assign_id) loop
      l_rec.begin_balance := c.begin_balance;
      l_rec.draw          := c.draw;
      l_rec.net_due       := c.begin_balance + c.earnminuspay + c.draw;
   end loop;

   RETURN l_rec;
END query_row;
--}}}

--{{{ to populate details of each record
PROCEDURE Get_Pe_Info
  (p_srp_plan_assign_id    IN    NUMBER,
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   x_ytd_pe_info           OUT   pe_info_tbl_type,
   x_ptd_pe_info           OUT   pe_info_tbl_type,
   x_ytd_total_earnings    OUT   NUMBER,
   x_ptd_total_earnings    OUT   NUMBER) IS

   l_count                       NUMBER := 0;

   -- Group Code subquery
   CURSOR group_code_cur IS
   SELECT distinct quota_group_code
     FROM cn_quotas where quota_group_code is not null;

   -- Annual Subquery
   -- To get
   -- 1) Annual Quota Target and percent
   CURSOR annual_quota_cur
     (l_srp_plan_assign_id   IN NUMBER,
      l_quota_group_code     IN VARCHAR) IS
   SELECT nvl(sum(sqa.target),0) target
     from cn_srp_quota_assigns sqa,
          cn_quotas q
    where sqa.srp_plan_assign_id = l_srp_plan_assign_id
      and sqa.quota_id = q.quota_id
      and q.quota_group_code = l_quota_group_code;

   -- YTD Subquery for ytd quota target
   -- To get
   -- 1) YTD Quota Target (ITD Quota Target)
   CURSOR ytd_quota_target_cur
     (l_srp_plan_assign_id   IN NUMBER,
      l_quota_group_code     IN VARCHAR) IS
	select nvl(sum(itd_target),0) itd_target
	  from cn_srp_period_quotas spq, cn_quotas q
	 where srp_plan_assign_id = l_srp_plan_assign_id
	   and period_id          = p_period_id
	   and q.quota_id         = spq.quota_id
	   and q.quota_group_code = l_quota_group_code;

   -- YTD Subquery
   -- To get
   -- 1) YTD Credit (ITD credit)
   -- 2) YTD Earnings (ITD earnings)
   CURSOR ytd_cur(l_quota_group_code     IN VARCHAR,
		  l_srp_plan_assign_id   IN NUMBER) IS
   SELECT sum(nvl(cspq.perf_achieved_itd,0))    ytd_credit,
          sum(nvl(cspq.commission_payed_itd,0)) ytd_earnings
     FROM cn_srp_period_quotas                  cspq,
          cn_quotas                             quota
    WHERE cspq.period_id          = p_period_id
      AND cspq.srp_plan_assign_id = l_srp_plan_assign_id
      AND cspq.quota_id           = quota.quota_id
      AND nvl(quota.quota_group_code, FND_API.G_MISS_CHAR) =
	  nvl(l_quota_group_code    , FND_API.G_MISS_CHAR)
      AND quota.credit_type_id    = p_credit_type_id
 GROUP BY cspq.salesrep_id,
	  cspq.srp_plan_assign_id,
	  cspq.period_id;

   -- PTD Subquery
   -- To get
   -- 1) PTD Target
   -- 2) PTD Credit
   -- 3) PTD Earnings
   CURSOR ptd_cur(l_quota_group_code     IN VARCHAR,
		  l_srp_plan_assign_id   IN NUMBER) IS
   SELECT sum(nvl(cspq.target_amount,0))        ptd_target,
          sum(nvl(cspq.perf_achieved_ptd,0))    ptd_credit,
          sum(nvl(cspq.commission_payed_ptd,0)) ptd_earnings
     FROM cn_quotas                             quota,
          cn_srp_period_quotas                  cspq
    WHERE cspq.period_id                      = p_period_id
      AND cspq.srp_plan_assign_id             = l_srp_plan_assign_id
      AND cspq.quota_id                       = quota.quota_id
      AND quota.quota_group_code              = l_quota_group_code
      AND quota.credit_type_id                = p_credit_type_id
 GROUP BY cspq.salesrep_id,
          cspq.srp_plan_assign_id,
          cspq.period_id;

BEGIN
   -- group_code_cur loop
   x_ytd_total_earnings := 0;
   x_ptd_total_earnings := 0;
   FOR group_code IN group_code_cur LOOP
      x_ytd_pe_info(l_count).quota_group_code := group_code.quota_group_code;
      x_ptd_pe_info(l_count).quota_group_code := group_code.quota_group_code;
      -- ytd_cur loop
      FOR ytd IN ytd_cur(group_code.quota_group_code,
			 p_srp_plan_assign_id) LOOP

	--first the subquery to get the ytd target
        open  ytd_quota_target_cur(p_srp_plan_assign_id,
				   group_code.quota_group_code);
	fetch ytd_quota_target_cur into x_ytd_pe_info(l_count).target;
	close ytd_quota_target_cur;

	x_ytd_pe_info(l_count).credit   := ytd.ytd_credit;
	x_ytd_pe_info(l_count).earnings := ytd.ytd_earnings;
	x_ytd_total_earnings := x_ytd_total_earnings + ytd.ytd_earnings;
      END LOOP; -- end of ytd_cur loop

      -- annual_quota_cur loop
      open  annual_quota_cur(p_srp_plan_assign_id,
			     group_code.quota_group_code);
      fetch annual_quota_cur into x_ytd_pe_info(l_count).annual_quota;
      close annual_quota_cur;

      IF x_ytd_pe_info(l_count).annual_quota = 0 THEN
	 x_ytd_pe_info(l_count).pct_annual_quota := 0;
       ELSE
	 x_ytd_pe_info(l_count).pct_annual_quota :=
	   (x_ytd_pe_info(l_count).credit /
	    x_ytd_pe_info(l_count).annual_quota) * 100;
      END IF;

      -- ptd_cur loop
      FOR ptd IN ptd_cur(group_code.quota_group_code,
			 p_srp_plan_assign_id) LOOP

	x_ptd_pe_info(l_count).target   := ptd.ptd_target;
	x_ptd_pe_info(l_count).credit   := ptd.ptd_credit;
	x_ptd_pe_info(l_count).earnings := ptd.ptd_earnings;
	x_ptd_total_earnings := x_ptd_total_earnings + ptd.ptd_earnings;
      END LOOP; -- end of ptd_cur loop
      l_count := l_count + 1;
   END LOOP; -- end of quota_group_code cur loop
END Get_Pe_Info;
--}}}

--{{{ to get set of all quota group codes
PROCEDURE Get_Group_Codes
  (x_result_tbl            OUT   pe_info_tbl_type) IS

  CURSOR group_codes IS
  select distinct quota_group_code from cn_quotas
    where quota_group_code is not null;
 l_count NUMBER := 0;
BEGIN
   FOR c in group_codes LOOP
      x_result_tbl(l_count).quota_group_code := c.quota_group_code;
      l_count := l_count + 1;
   END LOOP;
END Get_Group_Codes;
--}}}

--{{{ to populate master part of records
PROCEDURE Get_Quota_Summary
  (p_first                 IN    NUMBER,
   p_last                  IN    NUMBER,
   p_period_id             IN    NUMBER,
   p_user_id               IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   x_total_rows            OUT   NUMBER,
   x_result_tbl            OUT   comm_summ_tbl_type) IS

   l_min_period_id         NUMBER;
   l_max_period_id         NUMBER;
   l_count                 NUMBER := 0;
   l_rec                   comm_summ_rec_type;

BEGIN
   -- Get the min and max date of the period year which the
   -- given P_PERIOD_ID is in.
   SELECT min(period_id), max(period_id)
     INTO l_min_period_id, l_max_period_id
     FROM cn_acc_period_statuses_v
    WHERE period_year = mod(floor(p_period_id/1000),10000);

   x_total_rows := 0;

   if (fnd_global.resp_appl_id <> 283) then
      -- we are in oracle sales, use main_cur
      FOR main IN main_cur(p_period_id) LOOP
	 x_total_rows := x_total_rows + 1;
	 if x_total_rows between p_first and p_last then
	    l_rec := query_row(main, p_period_id, p_credit_type_id);
	    x_result_tbl(l_count) := l_rec;
	    l_count := l_count + 1;
	 END IF;
      END LOOP;  -- end of main loop;
    elsif (p_user_id <> -99) then
      -- we specified an analyst ID
      FOR main IN main_cur2(p_user_id, p_period_id) LOOP
	 x_total_rows := x_total_rows + 1;
	 if x_total_rows between p_first and p_last then
	     l_rec := query_row(main, p_period_id, p_credit_type_id);
	     x_result_tbl(l_count) := l_rec;
	     l_count := l_count + 1;
	 END IF;
      END LOOP;  -- end of main LOOP;
    else
      -- unspecified analyst ID
      FOR main IN main_cur3(p_period_id) LOOP
	 x_total_rows := x_total_rows + 1;
	 if x_total_rows between p_first and p_last then
	    l_rec := query_row(main, p_period_id, p_credit_type_id);
	    x_result_tbl(l_count) := l_rec;
	    l_count := l_count + 1;
	 END IF;
      END LOOP;  -- end of main LOOP;
   end if;

END Get_Quota_Summary;
--}}}

END CN_GET_COMM_SUMM_DATA;

/
