--------------------------------------------------------
--  DDL for Package Body CN_GET_COMM_SUMM_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_GET_COMM_SUMM_DATA_PVT" AS
  /*$Header: cnvcommb.pls 120.9 2007/12/05 11:09:20 kmnagara ship $*/

-- gets all salesreps under given analyst
PROCEDURE Get_Salesrep_List
  (p_first                 IN    NUMBER,
   p_last                  IN    NUMBER,
   p_period_id             IN    NUMBER,
   p_analyst_id            IN    NUMBER,
   p_org_id                IN    NUMBER,
   x_total_rows            OUT NOCOPY   NUMBER,
   x_salesrep_tbl          OUT NOCOPY   salesrep_tbl_type) IS

   -- Main query. This will be a main cursor in the api
   -- Each returned record represents a row in the report
   TYPE rc IS ref cursor;
   main_cursor rc;
   l_count                 NUMBER := 0;
   l_user_id               NUMBER;
   l_salesrep_id           NUMBER;
   l_curr_salesrep_id      NUMBER;
   l_name                  VARCHAR2(240);
   l_year                  NUMBER;
   l_year_start_date       DATE;
   l_period_end_date       DATE;
   l_resp_key		   VARCHAR2(30);
   l_resource_id 		NUMBER;
   l_groupquery_result number;
   l_rolequery_result number;

   l_query varchar2(4000) :=
  'SELECT distinct s.name, s.salesrep_id FROM jtf_rs_resource_extns re,
   cn_salesreps  s,cn_srp_plan_assigns assign WHERE re.resource_id = s.resource_id
   and s.org_id = assign.org_id and re.category <> ''TBH''
   and s.salesrep_id > 0 and s.salesrep_id = assign.salesrep_id
   and :b1 <= nvl(assign.end_date, :b2)
   and :b3 >= assign.start_date and s.org_id = :b4';

    cursor get_year is
    select period_year from cn_period_statuses
    where period_id = p_period_id and org_id=p_org_id;

    cursor get_salesrep (a_user_id number,a_org_id number) is
    select s.salesrep_id
    from cn_rs_salesreps s, jtf_rs_resource_extns re
    where re.user_id = a_user_id and s.resource_id = re.resource_id
    and s.org_id = a_org_id;

BEGIN
   x_total_rows := 0;

   -- 3 scenarios:
   -- 1) from OSO - only get info for logged in rep
   -- 2) from OSC, analyst specified - get reps under that analyst only
   --    *** OPEN ISSUE - do we recurse hierarchically or do we just get
   --                     the reps assigned directly to the analyst? ***
   -- 3) from OSC, unspecified analyst - get all reps
   -- 4) from OSC, and salesrep - only get info for logged in rep

   l_user_id := FND_GLOBAL.USER_ID;
   l_curr_salesrep_id := NULL;
   OPEN get_salesrep(l_user_id,p_org_id);
   FETCH get_salesrep INTO l_curr_salesrep_id;
   CLOSE get_salesrep;

   select je.resource_id into l_resource_id from jtf_rs_resource_extns je where je.user_id =l_user_id;

     SELECT count(1) into l_groupquery_result FROM JTF_RS_GROUP_MBR_ROLE_VL GPM, JTF_RS_GROUP_USAGES GPU
	WHERE GPM.GROUP_ID=GPU.GROUP_ID and GPU.usage='COMP_PAYMENT'
	AND NVL(GPM.END_DATE_ACTIVE,TO_DATE('01/01/9999','DD/MM/RRRR')) >= SYSDATE
	AND GPM.RESOURCE_ID = l_resource_id;

	select count(1) into l_rolequery_result from JTF_RS_ROLES_B ROLEB , JTF_RS_ROLE_RELATIONS ROLER
	WHERE ROLER.DELETE_FLAG ='N'  AND nvl(ROLER.END_DATE_ACTIVE,TO_DATE('01/01/9999','DD/MM/RRRR')) >= SYSDATE
	AND ROLER.ROLE_ID= ROLEB.ROLE_ID AND ROLEB.ROLE_TYPE_CODE='SALES_COMP_PAYMENT_ANALIST'
	AND ROLER.ROLE_RESOURCE_ID = l_resource_id;

	if(p_analyst_id <> -99)
	then
		l_query := l_query || ' AND s.assigned_to_user_id = :b5 ' ;
      	l_user_id := p_analyst_id;
	elsif
	( (l_curr_salesrep_id IS NULL) OR(l_groupquery_result >0) OR (l_rolequery_result >0))
	then
		l_query := l_query || ' AND :b5 = 1';
		l_user_id :=1;
	else
		l_query := l_query || ' AND re.user_id = :b5 ' ;
      	l_user_id := fnd_global.user_id;
    end if;


/*
   -- Added new or condition for enh#2648479
   if (fnd_global.resp_appl_id <> 283) or (l_curr_salesrep_id IS NOT NULL)  then
      -- for OSO, only select user's salesrep
      l_query := l_query || ' AND re.user_id = :b4 ' ;
      l_user_id := fnd_global.user_id;
    elsif (p_analyst_id <> -99) then
      -- we specified an analyst ID
      l_query := l_query || ' AND s.assigned_to_user_id = :b4 ' ;
      l_user_id := p_analyst_id;
    else
      -- unspecified analyst ID, give default condition that is always true
      l_query := l_query || ' AND :b4 = 1 ' ;
      l_user_id := 1;
   end if;
*/

   -- get fiscal year
   open  get_year;
   fetch get_year into l_year;
   close get_year;

   -- get start date of year and end date of period
   /**
     * Fix made for bug 4368747
     */

     /*
      select start_date into l_year_start_date from cn_period_statuses
      where period_id = p_period_id - mod(p_period_id, 1000) + 1;
     */

      select min(start_date) into l_year_start_date from cn_period_statuses cps,cn_repositories cr
      where cps.period_year=l_year and cr.period_set_id=cps.period_set_id
      and cr.period_type_id=cps.period_type_id and cr.org_id=cps.org_id
      and cr.org_id=p_org_id;
    /**
      * End of Fix made for bug 4368747
      */
   select end_date   into l_period_end_date from cn_period_statuses
    where period_id = p_period_id and org_id=p_org_id;

   open main_cursor for l_query using l_year_start_date, l_year_start_date,
                                      l_period_end_date, p_org_id, l_user_id;
   loop
      fetch main_cursor into l_name, l_salesrep_id;
      exit when main_cursor%notfound;

      x_total_rows := x_total_rows + 1;
      if x_total_rows between p_first and p_last then
         x_salesrep_tbl(l_count) := l_salesrep_id;
         l_count := l_count + 1;
      end if;
   end loop;
   close main_cursor;
END Get_Salesrep_List;

-- gets salesrep info
PROCEDURE Get_Salesrep_Info
  (p_salesrep_id           IN    NUMBER,
   p_org_id                IN    NUMBER,
   x_name                  OUT NOCOPY   VARCHAR2,
   x_emp_num               OUT NOCOPY   VARCHAR2,
   x_cost_center           OUT NOCOPY   VARCHAR2,
   x_charge_to_cost_center OUT NOCOPY   VARCHAR2,
   x_analyst_name          OUT NOCOPY   VARCHAR2) IS

   cursor get_info is
      select name, employee_number, cost_center,
	     charge_to_cost_center, assigned_to_user_name
	from cn_salesreps
       where salesrep_id = p_salesrep_id and org_id=p_org_id;

BEGIN
   open  get_info;
   fetch get_info into x_name, x_emp_num, x_cost_center,
                       x_charge_to_cost_center, x_analyst_name;
   close get_info;
END;

PROCEDURE Get_Salesrep_Details
(p_salesrep_id in number,
p_org_id in number,
x_result_tbl out NOCOPY salesrep_info_tbl_type) IS
x_name                  VARCHAR2(360);
x_emp_num               VARCHAR2(30);
x_cost_center           VARCHAR2(30);
x_charge_to_cost_center VARCHAR2(30);
x_analyst_name          VARCHAR2(100);
begin
get_salesrep_info(p_salesrep_id,p_org_id,x_name,x_emp_num,
x_cost_center,x_charge_to_cost_center,x_analyst_name);
x_result_tbl(1).x_name := x_name;
x_result_tbl(1).x_emp_num := x_emp_num;
x_result_tbl(1).x_cost_center := x_cost_center;
x_result_tbl(1).x_charge_to_cost_center := x_charge_to_cost_center;
x_result_tbl(1).x_analyst_name := x_analyst_name;
x_result_tbl(1).x_salesrep_id := p_salesrep_id;
end Get_Salesrep_Details;


PROCEDURE Get_Manager_Details
(p_org_id in NUMBER,
x_result_tbl out NOCOPY salesrep_info_tbl_type) IS
x_name                  VARCHAR2(360);
x_emp_num               VARCHAR2(30);
x_cost_center           VARCHAR2(30);
x_charge_to_cost_center VARCHAR2(30);
x_analyst_name          VARCHAR2(100);
l_count NUMBER :=0;
cursor cur_salesreps
is
SELECT DISTINCT S.SALESREP_ID,S.ORG_ID
        FROM JTF_RS_REP_MANAGERS RM,JTF_RS_GROUP_USAGES U, CN_SALESREPS S WHERE
        RM.PARENT_RESOURCE_ID=(SELECT R.RESOURCE_ID
        FROM JTF_RS_RESOURCE_EXTNS R WHERE R.USER_ID = FND_GLOBAL.USER_ID)
        AND RM.RESOURCE_ID=S.RESOURCE_ID
        AND RM.HIERARCHY_TYPE IN ('MGR_TO_REP', 'REP_TO_REP', 'MGR_TO_MGR')
        AND U.USAGE=CN_SYSTEM_PARAMETERS.VALUE('CN_REPORTING_HIERARCHY',p_org_id)
        AND RM.GROUP_ID = U.GROUP_ID AND SYSDATE >= RM.START_DATE_ACTIVE
        AND (RM.END_DATE_ACTIVE IS NULL OR (RM.END_DATE_ACTIVE >= SYSDATE))
        AND DENORM_LEVEL IS NOT NULL AND S.org_id =p_org_id;

begin
    for s in cur_salesreps
    loop
    get_salesrep_info(s.salesrep_id,s.org_id,x_name,x_emp_num,
    x_cost_center,x_charge_to_cost_center,x_analyst_name);
    l_count := l_count + 1;
    x_result_tbl(l_count).x_name := x_name;
    x_result_tbl(l_count).x_emp_num := x_emp_num;
    x_result_tbl(l_count).x_cost_center := x_cost_center;
    x_result_tbl(l_count).x_charge_to_cost_center := x_charge_to_cost_center;
    x_result_tbl(l_count).x_analyst_name := x_analyst_name;
    x_result_tbl(l_count).x_salesrep_id := s.salesrep_id;
    end loop;
end Get_Manager_Details;

PROCEDURE Get_Analyst_Details
(
p_org_id in number,
p_analyst_id in number,
x_result_tbl out nocopy salesrep_info_tbl_type) IS

l_count NUMBER :=0;

cursor cur_salesreps1(c_org_id     in number,
                     c_analyst_id in number) is
select salesrep_id,
	   org_id,
       name,
	   employee_number,
	   cost_center,
	   charge_to_cost_center,
	   assigned_to_user_name
from  cn_salesreps
where org_id = c_org_id
AND   assigned_to_user_id = c_analyst_id;

cursor cur_salesreps2(c_org_id in number) is
select salesrep_id,
	   org_id,
       name,
	   employee_number,
	   cost_center,
	   charge_to_cost_center,
	   assigned_to_user_name
from  cn_salesreps
where org_id = c_org_id;

TYPE cur_salesreps1_type IS TABLE OF cur_salesreps1%ROWTYPE;
cur_salesreps1_tbl cur_salesreps1_type;
TYPE cur_salesreps2_type IS TABLE OF cur_salesreps2%ROWTYPE;
cur_salesreps2_tbl cur_salesreps2_type;

begin
  if(p_analyst_id <> -99) then
    open cur_salesreps1(p_org_id, p_analyst_id);
    fetch cur_salesreps1 bulk collect into cur_salesreps1_tbl;
    close cur_salesreps1;

    if (cur_salesreps1_tbl.COUNT > 0) then
      for i in cur_salesreps1_tbl.FIRST .. cur_salesreps1_tbl.LAST loop
        l_count                                       := l_count + 1;
        x_result_tbl(l_count).x_name                  := cur_salesreps1_tbl(i).name;
        x_result_tbl(l_count).x_emp_num               := cur_salesreps1_tbl(i).employee_number;
        x_result_tbl(l_count).x_cost_center           := cur_salesreps1_tbl(i).cost_center;
        x_result_tbl(l_count).x_charge_to_cost_center := cur_salesreps1_tbl(i).charge_to_cost_center;
        x_result_tbl(l_count).x_analyst_name          := cur_salesreps1_tbl(i).assigned_to_user_name;
        x_result_tbl(l_count).x_salesrep_id           := cur_salesreps1_tbl(i).salesrep_id;
      end loop;
    end if; /* end if (cur_salesreps1_tbl.COUNT > 0) */

  else
    open cur_salesreps2(p_org_id);
    fetch cur_salesreps2 bulk collect into cur_salesreps2_tbl;
    close cur_salesreps2;

    if (cur_salesreps2_tbl.COUNT > 0) then
      for i in cur_salesreps2_tbl.FIRST .. cur_salesreps2_tbl.LAST loop
        l_count                                       := l_count + 1;
        x_result_tbl(l_count).x_name                  := cur_salesreps2_tbl(i).name;
        x_result_tbl(l_count).x_emp_num               := cur_salesreps2_tbl(i).employee_number;
        x_result_tbl(l_count).x_cost_center           := cur_salesreps2_tbl(i).cost_center;
        x_result_tbl(l_count).x_charge_to_cost_center := cur_salesreps2_tbl(i).charge_to_cost_center;
        x_result_tbl(l_count).x_analyst_name          := cur_salesreps2_tbl(i).assigned_to_user_name;
        x_result_tbl(l_count).x_salesrep_id           := cur_salesreps2_tbl(i).salesrep_id;
      end loop;
    end if; /* end if (cur_salesreps2_tbl.COUNT > 0) */

  end if; /* end if(p_analyst_id <> -99) */

end Get_Analyst_Details;

-- gets comm summ report for given rep - one rec for each plan assigned
PROCEDURE Get_Quota_Summary
  (p_salesrep_id           IN    NUMBER,
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   p_org_id                IN    NUMBER,
   x_result_tbl            OUT NOCOPY   comm_summ_tbl_type) IS

   l_year_start_date       DATE;
   l_year_start_period     NUMBER;
   l_period_end_date       DATE;
   l_count                 NUMBER := 0;

   cursor get_plans is
   SELECT assign.srp_plan_assign_id  srp_plan_assign_id,
          r.name                     role_name,
          cp.name                    plan_name,
          assign.start_date          start_date,
          assign.end_date            end_date
     FROM cn_srp_plan_assigns        assign,
          cn_roles                   r,
          cn_comp_plans              cp
    WHERE l_year_start_date       <= nvl(assign.end_date, l_year_start_date)
      AND l_period_end_date       >= assign.start_date
      AND assign.role_id           = r.role_id
      AND assign.comp_plan_id      = cp.comp_plan_id
      AND assign.org_id            = cp.org_id
      AND assign.salesrep_id       = p_salesrep_id
      AND assign.org_id            = p_org_id
    ORDER BY assign.start_date;

   CURSOR get_int_earn(l_srp_plan_assign_id NUMBER,
                       l_start_pd           NUMBER,
                       l_end_pd             NUMBER,
                       l_org_id             NUMBER) IS
   select nvl(sum(balance2_dtd),0)
     from cn_srp_periods sp, cn_srp_plan_assigns spa, cn_quotas_all q
    where spa.srp_plan_assign_id = l_srp_plan_assign_id
      and sp.srp_plan_assign_id = spa.srp_plan_assign_id
      and sp.salesrep_id = spa.salesrep_id
      and sp.quota_id = q.quota_id
      and q.quota_group_code is not null
      and sp.credit_type_id = p_credit_type_id
      and sp.org_id = spa.org_id
      and sp.org_id = q.org_id
      and sp.org_id = l_org_id
      and period_id between l_start_pd and l_end_pd;

BEGIN
   -- get start date of year and end date of period
   select min(p2.start_date), min(p2.period_id)
     into l_year_start_date, l_year_start_period
     from cn_period_statuses p1, cn_period_statuses p2
    where p1.period_id      = p_period_id
      and p1.period_year    = p2.period_year
      and p1.period_set_id  = p2.period_set_id
      and p1.period_type_id = p2.period_type_id
      and p1.org_id = p2.org_id and p1.org_id = p_org_id;

   select end_date   into l_period_end_date from cn_period_statuses
    where period_id = p_period_id and org_id=p_org_id;

   for p in get_plans loop
      l_count := l_count + 1;
      x_result_tbl(l_count).srp_plan_assign_id := p.srp_plan_assign_id;
      x_result_tbl(l_count).role_name          := p.role_name;
      x_result_tbl(l_count).plan_name          := p.plan_name;
      x_result_tbl(l_count).start_date         := p.start_date;
      x_result_tbl(l_count).end_date           := p.end_date;
      x_result_tbl(l_count).salesrep_id           := p_salesrep_id;
      -- get ytd_total_earnings and ptd_total_earnings
      open  get_int_earn(p.srp_plan_assign_id, l_year_start_period, p_period_id,p_org_Id);
      fetch get_int_earn into x_result_tbl(l_count).ytd_total_earnings;
      close get_int_earn;
      open  get_int_earn(p.srp_plan_assign_id, p_period_id, p_period_id,p_org_id);
      fetch get_int_earn into x_result_tbl(l_count).ptd_total_earnings;
      close get_int_earn;
   end loop;
END Get_Quota_Summary;

-- gets info for each plan assign and quota group
PROCEDURE Get_Pe_Info
  (p_srp_plan_assign_id    IN    NUMBER,
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   p_quota_group_code      IN    VARCHAR2,
   p_quota_id              IN    NUMBER := NULL ,
   p_org_id                IN    NUMBER,
   x_annual_quota          OUT NOCOPY   NUMBER,
   x_pct_annual_quota      OUT NOCOPY   NUMBER,
   x_ytd_target            OUT NOCOPY   NUMBER,
   x_ytd_credit            OUT NOCOPY   NUMBER,
   x_ytd_earnings          OUT NOCOPY   NUMBER,
   x_ptd_target            OUT NOCOPY   NUMBER,
   x_ptd_credit            OUT NOCOPY   NUMBER,
   x_ptd_earnings          OUT NOCOPY   NUMBER,
   x_itd_unachieved_quota  OUT NOCOPY   NUMBER,
   x_itd_tot_target        OUT NOCOPY   NUMBER) IS

   l_count                       NUMBER := 0;
   l_rollover                    NUMBER := 0;
   l_total_rollover              NUMBER := 0;
   l_itd_target                  NUMBER := 0;
   l_period_year                 NUMBER := 0;

   -- YTD periods subquery
   CURSOR ytd_periods IS
   select ps.period_id    period_id,
          nvl(inv.credit,0)     credit,
          nvl(inv.earnings,0)   earnings,
          nvl(inv.target,0)     target,
          nvl(inv.itd_target,0) itd_target
   from cn_period_statuses ps, cn_repositories r, cn_period_statuses ps2,
     (SELECT ps.period_id                          period_id,
             nvl(sum(cspq.perf_achieved_ptd),0)    credit,
             nvl(sum(cspq.commission_payed_ptd),0) earnings,
             nvl(sum(cspq.target_amount),0)        target,
             nvl(sum(cspq.itd_target),0)           itd_target
      FROM cn_srp_period_quotas cspq,
           cn_quotas_all        quota,
           cn_period_statuses   ps,
           cn_repositories      r,
           cn_period_statuses   ps2
      WHERE cspq.srp_plan_assign_id  = p_srp_plan_assign_id
      AND cspq.quota_id            = quota.quota_id
      AND quota.credit_type_id     = p_credit_type_id
      AND quota.quota_group_code   = p_quota_group_code
      and quota.org_id             = cspq.org_id
      and quota.org_id             = p_org_id
      AND quota.quota_id           > 0
      and ((p_quota_id is not null and quota.quota_id = p_quota_id)
            OR (QUOTA.QUOTA_ID = QUOTA.QUOTA_ID AND p_quota_id is null))
      and ps.period_year    = ps2.period_year
      and ps.period_id     <= p_period_id
      and ps2.period_id     = p_period_id
      and ps.period_set_id  = r.period_set_id
      and ps.period_type_id = r.period_type_id
      and ps2.org_id        = p_org_id
      and ps.org_id         = p_org_id
      and r.org_id          = p_org_id
      and ps.period_id      = cspq.period_id
      GROUP BY ps.period_id) inv
   where ps.period_id    = inv.period_id(+)
   and ps.period_year    = ps2.period_year
   and ps.period_id     <= p_period_id
   and ps2.period_id     = p_period_id
   and ps.period_set_id  = r.period_set_id
   and ps.period_type_id = r.period_type_id
   and ps.org_id        = ps2.org_id
   and ps.org_id        = r.org_id
   and r.org_id         = p_org_id;



   -- Annual Subquery
   -- To get Annual Quota Target and percent
   CURSOR annual_quota_cur(a_period_year number) IS
   SELECT nvl(sum(nvl(sqa.target * it.ct,0)),0) target
     from cn_srp_quota_assigns sqa,
          cn_quotas            q,
          (select count(distinct interval_number) ct, it.interval_type_id
	     from cn_cal_per_int_types it, cn_period_statuses ps
            where it.cal_period_id = ps.period_id
            and it.org_id = ps.org_id
            and ps.period_year = a_period_year
            and ps.org_id = p_org_id
            group by it.interval_type_id) it
    where sqa.srp_plan_assign_id = p_srp_plan_assign_id
      and sqa.quota_id           = q.quota_id
      and q.quota_group_code     = p_quota_group_code
      and q.credit_type_id       = p_credit_type_id
      and q.interval_type_id     = it.interval_type_id
      and q.org_id           = p_org_id --and sqa.org_id           = q.org_id
      and sqa.org_id           = p_org_id
      and ((p_quota_id is not null and q.quota_id = p_quota_id)
                 	OR (q.QUOTA_ID = q.QUOTA_ID AND p_quota_id is null));
          --and nvl(p_quota_id, q.quota_id) = q.quota_id;

   CURSOR rolling_quota_cur IS
   SELECT nvl(cspq.rollover,0),
          nvl(cspq.total_rollover,0)
     FROM cn_srp_period_quotas                  cspq,
          cn_quotas                             quota
    WHERE cspq.period_id          = p_period_id
      AND cspq.srp_plan_assign_id = p_srp_plan_assign_id
      AND cspq.quota_id           = quota.quota_id
      AND cspq.org_id           = quota.org_id
      AND quota.credit_type_id    = p_credit_type_id
      AND quota.quota_group_code  = p_quota_group_code
      AND cspq.org_id             = p_org_id
      and ((p_quota_id is not null and quota.quota_id = p_quota_id)
          	OR (QUOTA.QUOTA_ID = QUOTA.QUOTA_ID AND p_quota_id is null));
          --AND nvl(p_quota_id, quota.quota_id) = quota.quota_id;

BEGIN
   -- initialize ytd fields
   x_ytd_target   := 0;
   x_ytd_credit   := 0;
   x_ytd_earnings := 0;
   x_ptd_target   := 0;
   x_ptd_credit   := 0;
   x_ptd_earnings := 0;
   x_itd_unachieved_quota := 0;
   x_itd_tot_target := 0;
   l_itd_target := 0;

   -- ytd_ptd_cur loop
   FOR period IN ytd_periods LOOP
      x_ytd_target   := x_ytd_target   + period.target;
      x_ytd_credit   := x_ytd_credit   + period.credit;
      x_ytd_earnings := x_ytd_earnings + period.earnings;

      -- get ptd info when we are on the right period
      if period.period_id = p_period_id then
	    x_ptd_target   := period.target;
	    x_ptd_credit   := period.credit;
	    x_ptd_earnings := period.earnings;
	    l_itd_target   := period.itd_target;
      end if;

   END LOOP; -- end of period loop

   -- clku, get itd_unachieved_quota and itd_tot_target
   l_rollover := 0;
   l_total_rollover := 0;

   open  rolling_quota_cur;
   loop
      exit when rolling_quota_cur%notfound;
      fetch rolling_quota_cur into l_rollover, l_total_rollover;
   END LOOP;
   close rolling_quota_cur;

   x_itd_unachieved_quota  := l_rollover;
   x_itd_tot_target  := l_itd_target + l_total_rollover;

   SELECT period_year into l_period_year FROM cn_period_statuses p
                    WHERE  p.period_id=p_period_id and p.org_id = p_org_id;
   -- annual_quota
   open  annual_quota_cur(l_period_year);
   fetch annual_quota_cur into x_annual_quota;
   close annual_quota_cur;

   IF x_annual_quota = 0 THEN
      x_pct_annual_quota := 0;
    ELSE
      x_pct_annual_quota :=
	(x_ytd_credit / x_annual_quota) * 100;
   END IF;
END Get_Pe_Info;

-- get list of all quota groups
PROCEDURE Get_Group_Codes
  (p_org_id               IN NUMBER,
  x_result_tbl            OUT NOCOPY   group_code_tbl_type) IS

  CURSOR group_codes IS
  select distinct quota_group_code from cn_quotas_all
   where quota_group_code is not null
     and quota_id > 0 and org_id=p_org_id;
 l_count NUMBER := 1;

BEGIN
   FOR c in group_codes LOOP
      x_result_tbl(l_count) := c.quota_group_code;
      l_count := l_count + 1;
   END LOOP;
END Get_Group_Codes;


PROCEDURE Get_Quota_Manager_Summary
  (
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   p_org_id                In    NUMBER,
   x_result_tbl            OUT NOCOPY   comm_summ_tbl_type) IS

   l_year_start_date       DATE;
   l_year_start_period     NUMBER;
   l_period_end_date       DATE;
   l_count                 NUMBER := 0;

CURSOR get_all_plans (c_year_start_date   DATE,
                         c_period_end_date    DATE,
                         c_org_id             NUMBER,
                         c_period_start_pd    NUMBER,
                         c_end_pd             NUMBER,
                         c_year_start_pd      NUMBER,
                         c_credit_type_id     NUMBER) IS
   	SELECT assign.srp_plan_assign_id  srp_plan_assign_id,
	       r.name                     role_name,
	       cp.name                    plan_name,
	       assign.start_date          start_date,
	       assign.end_date            end_date,
	       assign.salesrep_id         salesrep_id,
               nvl(inv_ptd.earnings,0)           ptd_earnings,
               nvl(inv_ytd.earnings,0)           ytd_earnings
	FROM cn_srp_plan_assigns        assign,
	     cn_roles                   r,
	     cn_comp_plans              cp,
         (select spa.srp_plan_assign_id   srp_plan_assign_id,
                 nvl(sum(balance2_dtd),0) earnings
          from cn_srp_periods sp, cn_srp_plan_assigns spa, cn_quotas_all q
          where sp.srp_plan_assign_id = spa.srp_plan_assign_id
          and sp.salesrep_id          = spa.salesrep_id
          and sp.org_id = spa.org_id
          and sp.org_id = q.org_id
          and sp.quota_id             = q.quota_id
          and q.quota_group_code is not null
          and sp.credit_type_id       = c_credit_type_id
          and sp.org_id = c_org_id
          and period_id between c_period_start_pd and c_end_pd
          group by spa.srp_plan_assign_id) inv_ptd ,
         (select spa.srp_plan_assign_id   srp_plan_assign_id,
                 nvl(sum(balance2_dtd),0) earnings
          from cn_srp_periods sp, cn_srp_plan_assigns spa, cn_quotas_all q
          where sp.srp_plan_assign_id = spa.srp_plan_assign_id
          and sp.salesrep_id          = spa.salesrep_id
          and sp.org_id = spa.org_id
          and sp.org_id = q.org_id
          and sp.quota_id             = q.quota_id
          and q.quota_group_code is not null
          and sp.credit_type_id       = c_credit_type_id
          and sp.org_id = c_org_id
          and period_id between c_year_start_pd and c_end_pd
          group by spa.srp_plan_assign_id) inv_ytd
	WHERE --:b1       <= nvl(assign.end_date, :b2)
	      ((assign.end_date IS not null AND assign.end_date >= c_year_start_date) OR assign.end_date IS null )
	AND c_period_end_date         >= assign.start_date
    	AND assign.srp_plan_assign_id = inv_ytd.srp_plan_assign_id(+)
    	AND assign.srp_plan_assign_id = inv_ptd.srp_plan_assign_id (+)
	AND assign.role_id           = r.role_id
	AND assign.comp_plan_id      = cp.comp_plan_id
	AND assign.org_id            = cp.org_id
	and assign.org_id            = c_org_id
	AND assign.salesrep_id in
        (SELECT DISTINCT S.SALESREP_ID
        FROM JTF_RS_REP_MANAGERS RM,JTF_RS_GROUP_USAGES U, CN_SALESREPS S WHERE
        RM.PARENT_RESOURCE_ID=(SELECT R.RESOURCE_ID
        FROM JTF_RS_RESOURCE_EXTNS R WHERE R.USER_ID = FND_GLOBAL.USER_ID)
        AND RM.RESOURCE_ID=S.RESOURCE_ID
        AND RM.HIERARCHY_TYPE IN ('MGR_TO_REP', 'REP_TO_REP', 'MGR_TO_MGR')
        AND U.USAGE=CN_SYSTEM_PARAMETERS.VALUE('CN_REPORTING_HIERARCHY',c_org_id)
        AND RM.GROUP_ID = U.GROUP_ID AND SYSDATE >= RM.START_DATE_ACTIVE
        AND (RM.END_DATE_ACTIVE IS NULL OR (RM.END_DATE_ACTIVE >= SYSDATE))
        AND DENORM_LEVEL IS NOT NULL AND S.ORG_ID =c_org_id)
    ORDER BY assign.start_date ;

  TYPE get_all_plans_type IS TABLE OF get_all_plans%ROWTYPE;
  get_all_plans_tbl get_all_plans_type;

BEGIN
   -- get start date of year and end date of period
   select min(p2.start_date), min(p2.period_id)
     into l_year_start_date, l_year_start_period
     from cn_period_statuses p1, cn_period_statuses p2
    where p1.period_id      = p_period_id
      and p1.period_year    = p2.period_year
      and p1.period_set_id  = p2.period_set_id
      and p1.period_type_id = p2.period_type_id
      and p1.org_id = p2.org_id and p1.org_id =p_org_id;

   select end_date   into l_period_end_date from cn_period_statuses
    where period_id = p_period_id and org_id =p_org_id;

   open  get_all_plans(l_year_start_date, l_period_end_date,p_org_id, p_period_id, p_period_id,l_year_start_period, p_credit_type_id);
   fetch get_all_plans bulk collect into get_all_plans_tbl;
   close get_all_plans;

    if (get_all_plans_tbl.COUNT > 0) then
     for i in get_all_plans_tbl.FIRST .. get_all_plans_tbl.LAST loop
      l_count := l_count + 1;
      x_result_tbl(l_count).srp_plan_assign_id := get_all_plans_tbl(i).srp_plan_assign_id;
      x_result_tbl(l_count).role_name          := get_all_plans_tbl(i).role_name;
      x_result_tbl(l_count).plan_name          := get_all_plans_tbl(i).plan_name;
      x_result_tbl(l_count).start_date         := get_all_plans_tbl(i).start_date;
      x_result_tbl(l_count).end_date           := get_all_plans_tbl(i).end_date;
      x_result_tbl(l_count).salesrep_id        := get_all_plans_tbl(i).salesrep_id;
      x_result_tbl(l_count).ytd_total_earnings := get_all_plans_tbl(i).ytd_earnings;
      x_result_tbl(l_count).ptd_total_earnings := get_all_plans_tbl(i).ptd_earnings;
    end loop;
   end if;

end Get_Quota_Manager_Summary;

PROCEDURE Get_Quota_Analyst_Summary
  (
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   p_org_id                IN    NUMBER,
   p_analyst_id            IN    NUMBER,
   x_result_tbl            OUT NOCOPY   comm_summ_tbl_type) IS

   l_year_start_date       DATE;
   l_year_start_period     NUMBER;
   l_period_end_date       DATE;
   l_count                 NUMBER := 0;

   CURSOR get_all_plans (c_year_start_date   DATE,
                         c_period_end_date    DATE,
                         c_org_id             NUMBER,
                         c_start_pd           NUMBER,
                         c_end_pd             NUMBER,
                         c_credit_type_id     NUMBER,
                         c_analyst_id         NUMBER) IS
   	SELECT assign.srp_plan_assign_id  srp_plan_assign_id,
	       r.name                     role_name,
	       cp.name                    plan_name,
	       assign.start_date          start_date,
	       assign.end_date            end_date,
	       assign.salesrep_id         salesrep_id,
           nvl(inv.earnings,0)               earnings
	FROM cn_srp_plan_assigns        assign,
	     cn_roles                   r,
	     cn_comp_plans              cp,
         (select spa.srp_plan_assign_id   srp_plan_assign_id,
                 nvl(sum(balance2_dtd),0) earnings
          from cn_srp_periods sp, cn_srp_plan_assigns spa, cn_quotas_all q
          where sp.srp_plan_assign_id = spa.srp_plan_assign_id
          and sp.salesrep_id          = spa.salesrep_id
          and spa.org_id              = p_org_id--and sp.org_id = spa.org_id
          and q.org_id                = p_org_id --and sp.org_id = q.org_id
          and sp.quota_id             = q.quota_id
          and q.quota_group_code is not null
          and sp.credit_type_id       = c_credit_type_id
          and sp.org_id = c_org_id
          and period_id between c_start_pd and c_end_pd
          group by spa.srp_plan_assign_id) inv
	WHERE --:b1       <= nvl(assign.end_date, :b2)
	      ((assign.end_date IS not null AND assign.end_date >= c_year_start_date) OR assign.end_date IS null )
	AND c_period_end_date         >= assign.start_date
    AND assign.srp_plan_assign_id = inv.srp_plan_assign_id(+)
	AND assign.role_id           = r.role_id
	AND assign.comp_plan_id      = cp.comp_plan_id
	AND assign.org_id            = cp.org_id
	and assign.org_id            = c_org_id
	AND assign.salesrep_id in
        (SELECT SALESREP_ID FROM CN_SALESREPS where org_id = c_org_id
  	     AND ((c_analyst_id <> -99 AND assigned_to_user_id = c_analyst_id) OR c_analyst_id = -99))
    ORDER BY assign.start_date ;

  TYPE get_all_plans_type IS TABLE OF get_all_plans%ROWTYPE;
  get_all_plans_tbl get_all_plans_type;

BEGIN
   -- get start date of year and end date of period
   select min(p2.start_date), min(p2.period_id)
     into l_year_start_date, l_year_start_period
     from cn_period_statuses p1, cn_period_statuses p2
    where p1.period_id      = p_period_id
      and p1.period_year    = p2.period_year
      and p1.period_set_id  = p2.period_set_id
      and p1.period_type_id = p2.period_type_id
      and p1.org_id = p2.org_id and p1.org_id=p_org_id;

   select end_date   into l_period_end_date from cn_period_statuses
    where period_id = p_period_id and org_id =p_org_id;

   open  get_all_plans(l_year_start_date, l_period_end_date,p_org_id, p_period_id, p_period_id, p_credit_type_id, p_analyst_id);
   fetch get_all_plans bulk collect into get_all_plans_tbl;
   close get_all_plans;

   if (get_all_plans_tbl.COUNT > 0) then
     for i in get_all_plans_tbl.FIRST .. get_all_plans_tbl.LAST loop
       l_count := l_count + 1;
       x_result_tbl(l_count).srp_plan_assign_id := get_all_plans_tbl(i).srp_plan_assign_id;
       x_result_tbl(l_count).role_name          := get_all_plans_tbl(i).role_name;
       x_result_tbl(l_count).plan_name          := get_all_plans_tbl(i).plan_name;
       x_result_tbl(l_count).start_date         := get_all_plans_tbl(i).start_date;
       x_result_tbl(l_count).end_date           := get_all_plans_tbl(i).end_date;
       x_result_tbl(l_count).salesrep_id        := get_all_plans_tbl(i).salesrep_id;
       x_result_tbl(l_count).ytd_total_earnings	:= get_all_plans_tbl(i).earnings;
       x_result_tbl(l_count).ptd_total_earnings	:= get_all_plans_tbl(i).earnings;
     end loop;
   end if;

end Get_Quota_Analyst_Summary;

PROCEDURE Get_Salesrep_Pe_Info
(
   p_salesrep_id in number,
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   p_org_id                IN NUMBER,
   x_result_tbl OUT NOCOPY pe_info_tbl_type) IS
   l_year_start_date       DATE;
   l_year_start_period     NUMBER;
   l_period_end_date       DATE;

    x_annual_quota           NUMBER := 0;
    x_pct_annual_quota       NUMBER := 0;
    x_ytd_target            NUMBER := 0;
    x_ytd_credit            NUMBER := 0;
    x_ytd_earnings          NUMBER := 0;
    x_ptd_target            NUMBER := 0;
    x_ptd_credit            NUMBER := 0;
    x_ptd_earnings          NUMBER := 0;
    x_itd_unachieved_quota  NUMBER := 0;
    x_itd_tot_target        NUMBER := 0;
    l_count                 NUMBER := 0;
    x_quota_id number := null;
cursor cur_srp_plan_assign_id
is
SELECT assign.srp_plan_assign_id
     FROM cn_srp_plan_assigns        assign,
          cn_roles                   r,
          cn_comp_plans              cp
    WHERE l_year_start_date       <= nvl(assign.end_date, l_year_start_date)
      AND l_period_end_date       >= assign.start_date
      AND assign.role_id           = r.role_id
      AND assign.comp_plan_id      = cp.comp_plan_id
      AND assign.org_id            = cp.org_id
      AND assign.salesrep_id       = p_salesrep_id
      and assign.org_id            = p_org_id
    ORDER BY assign.start_date;

cursor cur_quota_groups
is
select distinct quota_group_code from cn_quotas_all where quota_group_code is not null
and quota_id > 0 and org_id=p_org_id;
begin
   select min(p2.start_date), min(p2.period_id)
     into l_year_start_date, l_year_start_period
     from cn_period_statuses p1, cn_period_statuses p2
    where p1.period_id      = p_period_id
      and p1.period_year    = p2.period_year
      and p1.period_set_id  = p2.period_set_id
      and p1.period_type_id = p2.period_type_id
      and p1.org_id = p2.org_id
      and p1.org_id = p_org_id;

    select end_date   into l_period_end_date from cn_period_statuses
    where period_id = p_period_id and org_id = p_org_id;

    for s in cur_srp_plan_assign_id
        loop
        for q in cur_quota_groups
            loop

            get_pe_info(
            s.srp_plan_assign_id,
            p_period_id,
            p_credit_type_id,
            q.quota_group_code,
            x_quota_id,
            p_org_id,
            x_annual_quota ,
            x_pct_annual_quota,
            x_ytd_target,
            x_ytd_credit,
            x_ytd_earnings,
            x_ptd_target,
            x_ptd_credit,
            x_ptd_earnings,
            x_itd_unachieved_quota,
            x_itd_tot_target);
            l_count := l_count + 1;
            x_result_tbl(l_count).srp_plan_assign_id := s.srp_plan_assign_id;
            x_result_tbl(l_count).quota_group_code := q.quota_group_code;
            x_result_tbl(l_count).x_annual_quota := x_annual_quota;
            x_result_tbl(l_count).x_pct_annual_quota := x_pct_annual_quota;
            x_result_tbl(l_count).x_ytd_target := x_ytd_target;
            x_result_tbl(l_count).x_ytd_credit := x_ytd_credit;
            x_result_tbl(l_count).x_ytd_earnings := x_ytd_earnings;
            x_result_tbl(l_count).x_ptd_target := x_ptd_target;
            x_result_tbl(l_count).x_ptd_credit := x_ptd_credit;
            x_result_tbl(l_count).x_ptd_earnings := x_ptd_earnings;
            x_result_tbl(l_count).x_itd_unachieved_quota := x_itd_unachieved_quota;
            x_result_tbl(l_count).x_itd_tot_target := x_itd_tot_target;
            end loop;
        end loop;
end Get_Salesrep_Pe_Info;

PROCEDURE Get_Manager_Pe_Info
(
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   p_org_id                IN NUMBER,
   x_result_tbl OUT NOCOPY pe_info_tbl_type) IS
   l_year_start_date       DATE;
   l_year_start_period     NUMBER;
   l_period_end_date       DATE;

    x_annual_quota           NUMBER := 0;
    x_pct_annual_quota       NUMBER := 0;
    x_ytd_target            NUMBER := 0;
    x_ytd_credit            NUMBER := 0;
    x_ytd_earnings          NUMBER := 0;
    x_ptd_target            NUMBER := 0;
    x_ptd_credit            NUMBER := 0;
    x_ptd_earnings          NUMBER := 0;
    x_itd_unachieved_quota  NUMBER := 0;
    x_itd_tot_target        NUMBER := 0;
    l_count                 NUMBER := 0;
    x_quota_id number := null;
cursor srp_plan_assigns(c_year_start_date DATE,
                          c_period_end_date DATE,
                          c_org_id          NUMBER)
is
SELECT assign.srp_plan_assign_id
     FROM cn_srp_plan_assigns        assign,
          cn_roles                   r,
          cn_comp_plans              cp
    WHERE c_year_start_date       <= nvl(assign.end_date, c_year_start_date)
      AND c_period_end_date       >= assign.start_date
      AND assign.role_id           = r.role_id
      AND assign.comp_plan_id      = cp.comp_plan_id
      AND assign.org_id      = cp.org_id
      and assign.org_id      = c_org_id
      AND assign.salesrep_id  in (SELECT DISTINCT S.SALESREP_ID
        FROM JTF_RS_REP_MANAGERS RM,JTF_RS_GROUP_USAGES U, CN_SALESREPS S WHERE
        RM.PARENT_RESOURCE_ID=(SELECT R.RESOURCE_ID
        FROM JTF_RS_RESOURCE_EXTNS R WHERE R.USER_ID = FND_GLOBAL.USER_ID)
        AND RM.RESOURCE_ID=S.RESOURCE_ID
        AND RM.HIERARCHY_TYPE IN ('MGR_TO_REP', 'REP_TO_REP', 'MGR_TO_MGR')
        AND U.USAGE=CN_SYSTEM_PARAMETERS.VALUE('CN_REPORTING_HIERARCHY',c_org_id)
        AND RM.GROUP_ID = U.GROUP_ID AND SYSDATE >= RM.START_DATE_ACTIVE
        AND (RM.END_DATE_ACTIVE IS NULL OR (RM.END_DATE_ACTIVE >= SYSDATE))
        AND DENORM_LEVEL IS NOT NULL AND S.ORG_ID = c_org_id
        )
    ORDER BY assign.start_date;

cursor quota_groups(c_org_id NUMBER)
is
select
	distinct quota_group_code
from cn_quotas_all
where quota_group_code is not null and quota_id > 0 and org_id=p_org_id;

  TYPE srp_plan_assigns_type IS TABLE OF srp_plan_assigns%ROWTYPE;
  srp_plan_assigns_tbl srp_plan_assigns_type;

  TYPE quota_groups_type IS TABLE OF quota_groups%ROWTYPE;
  quota_groups_tbl quota_groups_type;

begin
   select min(p2.start_date), min(p2.period_id)
     into l_year_start_date, l_year_start_period
     from cn_period_statuses p1, cn_period_statuses p2
    where p1.period_id      = p_period_id
      and p1.period_year    = p2.period_year
      and p1.period_set_id  = p2.period_set_id
      and p1.period_type_id = p2.period_type_id
      and p1.org_id = p2.org_id and p1.org_id=p_org_id;

    select end_date   into l_period_end_date from cn_period_statuses
    where period_id = p_period_id and org_id = p_org_id;

    open  quota_groups(p_org_id);
    fetch quota_groups bulk collect into quota_groups_tbl;
    close quota_groups;

    open  srp_plan_assigns(l_year_start_date,l_period_end_date,p_org_id);
    fetch srp_plan_assigns bulk collect into srp_plan_assigns_tbl;
    close srp_plan_assigns;

    if ((srp_plan_assigns_tbl.COUNT > 0) AND (quota_groups_tbl.COUNT > 0)) then
       for i in srp_plan_assigns_tbl.FIRST .. srp_plan_assigns_tbl.LAST loop
       for j in quota_groups_tbl.FIRST .. quota_groups_tbl.LAST loop
       get_pe_info(
                   srp_plan_assigns_tbl(i).srp_plan_assign_id,
                   p_period_id,
                   p_credit_type_id,
                   quota_groups_tbl(j).quota_group_code,
                   x_quota_id,
                   p_org_id,
                   x_annual_quota ,
                   x_pct_annual_quota,
                   x_ytd_target,
                   x_ytd_credit,
                   x_ytd_earnings,
                   x_ptd_target,
                   x_ptd_credit,
                   x_ptd_earnings,
                   x_itd_unachieved_quota,
                   x_itd_tot_target);
            l_count := l_count + 1;
            x_result_tbl(l_count).srp_plan_assign_id := srp_plan_assigns_tbl(i).srp_plan_assign_id;
            x_result_tbl(l_count).quota_group_code := quota_groups_tbl(j).quota_group_code;
            x_result_tbl(l_count).x_annual_quota := x_annual_quota;
            x_result_tbl(l_count).x_pct_annual_quota := x_pct_annual_quota;
            x_result_tbl(l_count).x_ytd_target := x_ytd_target;
            x_result_tbl(l_count).x_ytd_credit := x_ytd_credit;
            x_result_tbl(l_count).x_ytd_earnings := x_ytd_earnings;
            x_result_tbl(l_count).x_ptd_target := x_ptd_target;
            x_result_tbl(l_count).x_ptd_credit := x_ptd_credit;
            x_result_tbl(l_count).x_ptd_earnings := x_ptd_earnings;
            x_result_tbl(l_count).x_itd_unachieved_quota := x_itd_unachieved_quota;
            x_result_tbl(l_count).x_itd_tot_target := x_itd_tot_target;
       end loop;
       end loop;
    end if;


end Get_Manager_Pe_Info;

PROCEDURE Get_Analyst_Pe_Info
(
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   p_org_id                IN    NUMBER,
   p_analyst_id            IN    NUMBER,
   x_result_tbl OUT NOCOPY pe_info_tbl_type) IS

   l_year_start_date       DATE;
   l_year_start_period     NUMBER;
   l_period_end_date       DATE;

    x_annual_quota           NUMBER := 0;
    x_pct_annual_quota       NUMBER := 0;
    x_ytd_target            NUMBER := 0;
    x_ytd_credit            NUMBER := 0;
    x_ytd_earnings          NUMBER := 0;
    x_ptd_target            NUMBER := 0;
    x_ptd_credit            NUMBER := 0;
    x_ptd_earnings          NUMBER := 0;
    x_itd_unachieved_quota  NUMBER := 0;
    x_itd_tot_target        NUMBER := 0;
    l_count                 NUMBER := 0;
    x_quota_id number := null;
    l_srp_plan_assign_id number;

  cursor srp_plan_assigns(c_year_start_date DATE,
                          c_period_end_date DATE,
                          c_org_id          NUMBER,
                          c_analyst_id      NUMBER)
  is
  SELECT assign.srp_plan_assign_id
  FROM cn_srp_plan_assigns        assign,
       cn_roles                   r,
       cn_comp_plans              cp
  WHERE c_year_start_date <= nvl(assign.end_date, c_year_start_date)
  AND c_period_end_date   >= assign.start_date
  AND assign.role_id      = r.role_id
  AND assign.comp_plan_id = cp.comp_plan_id
  AND assign.org_id       = cp.org_id
  and assign.org_id       = c_org_id
  AND assign.salesrep_id  in
         (SELECT SALESREP_ID FROM CN_SALESREPS where org_id = c_org_id
  	      AND ((c_analyst_id <> -99 AND assigned_to_user_id = c_analyst_id) OR c_analyst_id = -99))
  ORDER BY assign.start_date;

  cursor quota_groups(c_org_id NUMBER)
  is
  select distinct quota_group_code
  from cn_quotas_all
  where quota_group_code is not null
  and quota_id > 0
  and org_id = c_org_id;

  TYPE srp_plan_assigns_type IS TABLE OF srp_plan_assigns%ROWTYPE;
  srp_plan_assigns_tbl srp_plan_assigns_type;

  TYPE quota_groups_type IS TABLE OF quota_groups%ROWTYPE;
  quota_groups_tbl quota_groups_type;

begin
   select min(p2.start_date), min(p2.period_id)
     into l_year_start_date, l_year_start_period
     from cn_period_statuses p1, cn_period_statuses p2
    where p1.period_id      = p_period_id
      and p1.period_year    = p2.period_year
      and p1.period_set_id  = p2.period_set_id
      and p1.period_type_id = p2.period_type_id
      and p1.org_id = p2.org_id and p1.org_id=p_org_id;

    select end_date   into l_period_end_date from cn_period_statuses
    where period_id = p_period_id and org_id = p_org_id;

    open  quota_groups(p_org_id);
    fetch quota_groups bulk collect into quota_groups_tbl;
    close quota_groups;

    open  srp_plan_assigns(l_year_start_date,l_period_end_date,p_org_id,p_analyst_id);
    fetch srp_plan_assigns bulk collect into srp_plan_assigns_tbl;
    close srp_plan_assigns;

    if ((srp_plan_assigns_tbl.COUNT > 0) AND (quota_groups_tbl.COUNT > 0)) then
      for i in srp_plan_assigns_tbl.FIRST .. srp_plan_assigns_tbl.LAST loop
        for j in quota_groups_tbl.FIRST .. quota_groups_tbl.LAST loop
            get_pe_info(
            srp_plan_assigns_tbl(i).srp_plan_assign_id,
            p_period_id,
            p_credit_type_id,
            quota_groups_tbl(j).quota_group_code,
            x_quota_id,
            p_org_id,
            x_annual_quota ,
            x_pct_annual_quota,
            x_ytd_target,
            x_ytd_credit,
            x_ytd_earnings,
            x_ptd_target,
            x_ptd_credit,
            x_ptd_earnings,
            x_itd_unachieved_quota,
            x_itd_tot_target);
            l_count := l_count + 1;
            x_result_tbl(l_count).srp_plan_assign_id := srp_plan_assigns_tbl(i).srp_plan_assign_id;
            x_result_tbl(l_count).quota_group_code := quota_groups_tbl(j).quota_group_code;
            x_result_tbl(l_count).x_annual_quota := x_annual_quota;
            x_result_tbl(l_count).x_pct_annual_quota := x_pct_annual_quota;
            x_result_tbl(l_count).x_ytd_target := x_ytd_target;
            x_result_tbl(l_count).x_ytd_credit := x_ytd_credit;
            x_result_tbl(l_count).x_ytd_earnings := x_ytd_earnings;
            x_result_tbl(l_count).x_ptd_target := x_ptd_target;
            x_result_tbl(l_count).x_ptd_credit := x_ptd_credit;
            x_result_tbl(l_count).x_ptd_earnings := x_ptd_earnings;
            x_result_tbl(l_count).x_itd_unachieved_quota := x_itd_unachieved_quota;
            x_result_tbl(l_count).x_itd_tot_target := x_itd_tot_target;
        end loop;
      end loop;
    end if;

end Get_Analyst_Pe_Info;

PROCEDURE Get_Ptd_Credit
(p_salesrep_id      IN NUMBER,
 p_payrun_id         IN NUMBER,
 p_org_id in NUMBER,
 x_result_tbl IN OUT NOCOPY pe_ptd_credit_tbl_type
) IS
   x_period_id             NUMBER:= 0;
   l_annual_quota          NUMBER:= 0;
   l_pct_annual_quota      NUMBER:= 0;
   l_ytd_target            NUMBER:= 0;
   l_ytd_credit            NUMBER:= 0;
   l_ytd_earnings          NUMBER:= 0;
   l_ptd_target            NUMBER:= 0;
   l_ptd_credit            NUMBER:= 0;
   l_ptd_earnings          NUMBER:= 0;
   l_ytd_attain		       NUMBER:= 0;
   l_ptd_attain		       NUMBER:= 0;
   l_itd_unachieved_quota  NUMBER:= 0;
   l_itd_tot_target        NUMBER:= 0;
   l_count                 NUMBER:= 0;
   CURSOR get_plans ( l_period_id NUMBER,
                      l_payrun_id NUMBER,
                      l_salesrep_id IN NUMBER,
                      l_org_id IN NUMBER) IS
      SELECT DISTINCT
      srp.srp_plan_assign_id     srp_plan_assign_id,
	  q.quota_id		     quota_id,
	  r.role_id		     role_id,
	  cp.comp_plan_id	     comp_plan_id,
          assign.start_date          start_date,
          assign.end_date            end_date,
	  q.quota_group_code	     quota_group_code
     FROM cn_srp_periods             srp,
          cn_srp_plan_assigns	     assign,
          cn_roles                   r,
          cn_comp_plans              cp,
	  cn_payment_worksheets      w,
	  cn_quotas_all		     q
    WHERE assign.srp_plan_assign_id(+) = srp.srp_plan_assign_id
      AND srp.period_id	            = l_period_id
      AND assign.role_id            = r.role_id(+)
      AND assign.comp_plan_id       = cp.comp_plan_id(+)
      AND assign.org_id             = cp.org_id(+)
      AND q.quota_id	    	    = w.quota_id
      AND q.org_id	    	    = w.org_id
      AND w.payrun_Id		    = l_payrun_id
      AND w.salesrep_id 	    = l_salesrep_id
      AND q.quota_id		    = srp.quota_id
       AND q.org_id		        = srp.org_id
      AND srp.salesrep_id	    = l_salesrep_id
      AND srp.org_id	    = p_org_id
      AND srp.credit_type_id = -1000
      AND w.quota_id  <> -1000
    ORDER BY assign.start_date;
begin
select pay_period_id into x_period_id from cn_payruns where payrun_id=p_payrun_id;
for p in get_plans(x_period_id,
		          p_payrun_id,
		          p_salesrep_id,
                  p_org_id)  loop

      cn_get_comm_summ_data_pvt.Get_Pe_Info
           (p_srp_plan_assign_id    => p.srp_plan_assign_id,
            p_period_id             => x_period_id,
            p_credit_type_id        => -1000,
            p_quota_group_code      => p.quota_group_code,
            p_quota_id		        =>   p.quota_id,
            p_org_id                => p_org_id,
            x_annual_quota          => l_annual_quota,
            x_pct_annual_quota      => l_pct_annual_quota,
            x_ytd_target            => l_ytd_target,
            x_ytd_credit            => l_ytd_credit,
            x_ytd_earnings          => l_ytd_earnings,
            x_ptd_target            => l_ptd_target,
            x_ptd_credit            => l_ptd_credit,
            x_ptd_earnings          => l_ptd_earnings,
	    x_itd_unachieved_quota  => l_itd_unachieved_quota,
	    x_itd_tot_target        => l_itd_tot_target);

	    l_count := l_count + 1;
         x_result_tbl(l_count).quota_id := p.quota_id;
         x_result_tbl(l_count).x_ptd_credit := l_ptd_credit;
end loop;
end Get_Ptd_Credit;

FUNCTION get_conversion_type(p_org_id IN NUMBER)
RETURN VARCHAR2 IS
l_profile_value VARCHAR2(100);
cursor prof_cursor(a_org_id NUMBER) is
SELECT CN_CONVERSION_TYPE FROM CN_REPOSITORIES WHERE ORG_ID=a_org_id;
d prof_cursor%rowtype;
BEGIN
      open  prof_cursor(p_org_id);
      fetch prof_cursor into d;
      l_profile_value := d.cn_conversion_type;
      close prof_cursor;
return l_profile_value;
EXCEPTION
WHEN OTHERS THEN
FND_MESSAGE.SET_NAME('CN','CN_INVALID_PROFILE_CODE');
APP_EXCEPTION.RAISE_EXCEPTION;
END GET_CONVERSION_TYPE;

END CN_GET_COMM_SUMM_DATA_PVT;

/
