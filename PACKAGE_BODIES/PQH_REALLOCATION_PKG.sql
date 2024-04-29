--------------------------------------------------------
--  DDL for Package Body PQH_REALLOCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_REALLOCATION_PKG" as
/* $Header: pqrealoc.pkb 115.11 2004/04/20 09:53:40 hsajja noship $ */
--
-- Function to calculate the reallocation amt for the given position and dates
--

function get_reallocation(p_position_id 	in number default null
			 ,p_job_id      	in number default null
			 ,p_grade_id    	in number default null
			 ,p_organization_id 	in number default null
			 ,p_budget_entity       in varchar2 default 'POSITION'
			 ,p_start_date          in date default sysdate
			 ,p_end_date            in date default sysdate
			 ,p_effective_date      in date default sysdate
			 ,p_system_budget_unit  in varchar2
			 ,p_business_group_id   in number
                          ) return number is
--
-- Cursor to fetch the reallocation_amt, budget dates and period_set_name
-- of the budget for the given position/job/grade/organization, system budget unit
-- and for the given start_date and end_date
--
/* Re-writing the cursor inline with the revised reallocation functionality
*************************************************************************kgowirpe
cursor c_reallocation is
Select
    bud.period_set_name,
    bud.budget_start_date,
    bud.budget_end_date,
    bpr.reallocation_amt,
    decode(p_system_budget_unit,
           PQH_PSF_BUS.GET_SYSTEM_SHARED_TYPE(budget_unit1_id), budget_unit1_aggregate,
           PQH_PSF_BUS.GET_SYSTEM_SHARED_TYPE(budget_unit2_id), budget_unit2_aggregate,
           PQH_PSF_BUS.GET_SYSTEM_SHARED_TYPE(budget_unit3_id), budget_unit3_aggregate) budget_unit_aggregate
from
    pqh_bdgt_pool_realloctions bpr,
    pqh_budget_pools bpl,
    pqh_budgets bud,
    pqh_budget_versions bvr
where
    bpl.pool_id = bpr.pool_id
    and trunc(p_effective_date) between trunc(bud.budget_start_date) and trunc(bud.budget_end_date)
    and bud.budget_id = bvr.budget_id
    and trunc(p_effective_date) between trunc(bvr.date_from) and trunc(bvr.date_to)
    and bvr.budget_version_id = bpl.budget_version_id
    and nvl(bud.position_control_flag,'X') = 'Y'
    and bud.budgeted_entity_cd = p_budget_entity
    and nvl(p_position_id,     nvl(bpr.position_id,      -1)) =
			       nvl(bpr.position_id,      -1)
--
-- Commented because no reallocation is possible for entities - job, grade and organization.
--
--    and nvl(p_organization_id, nvl(bpr.organization_id,  -1)) =
--                               nvl(bpr.organization_id,  -1)
--    and nvl(p_job_id,          nvl(bpr.job_id,   -1)) =
--		               nvl(bpr.job_id,   -1)
--    and nvl(p_grade_id,        nvl(bpr.grade_id,         -1)) =
--			       nvl(bpr.grade_id,         -1)
    and PQH_PSF_BUS.GET_SYSTEM_SHARED_TYPE(bpl.budget_unit_id) = p_system_budget_unit
    and	(p_effective_date between bvr.date_from and bvr.date_to)
    and	bud.business_group_id = p_business_group_id
    and	((p_start_date <= budget_start_date
          and p_end_date >= budget_end_date
         ) or
        (p_start_date between budget_start_date and budget_end_date) or
        (p_end_date between budget_start_date and budget_end_date)
       )
     and (
          hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id) = p_system_budget_unit
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = p_system_budget_unit
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = p_system_budget_unit
      );
************************************************************************************kgowripe
*/
cursor c_reallocation is
Select
    bud.period_set_name,
    bud.budget_start_date,
    bud.budget_end_date,
    decode(rec_amt.transaction_type,'DD',-1*rec_amt.reallocation_amt,'RD',rec_amt.reallocation_amt) reallocation_amt,
    decode(p_system_budget_unit,
           PQH_PSF_BUS.GET_SYSTEM_SHARED_TYPE(budget_unit1_id), budget_unit1_aggregate,
           PQH_PSF_BUS.GET_SYSTEM_SHARED_TYPE(budget_unit2_id), budget_unit2_aggregate,
           PQH_PSF_BUS.GET_SYSTEM_SHARED_TYPE(budget_unit3_id), budget_unit3_aggregate) budget_unit_aggregate
from pqh_budget_pools fld,
     pqh_budget_pools trnx,
     pqh_bdgt_pool_realloctions trnx_dtl,
     pqh_bdgt_pool_realloctions rec_amt,
     pqh_budgets bud,
     pqh_budget_versions bvr
where   trunc(p_effective_date) between trunc(bud.budget_start_date) and trunc(bud.budget_end_date)
    and nvl(bud.position_control_flag,'X') = 'Y'
    and bud.budgeted_entity_cd = p_budget_entity
    and	bud.business_group_id = p_business_group_id
    and	((p_start_date <= budget_start_date
          and p_end_date >= budget_end_date
         ) or
        (p_start_date between budget_start_date and budget_end_date) or
        (p_end_date between budget_start_date and budget_end_date)
       )
     and (
          hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id) = p_system_budget_unit
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = p_system_budget_unit
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = p_system_budget_unit
      )
    and bud.budget_id = bvr.budget_id
    and trunc(p_effective_date) between trunc(bvr.date_from) and trunc(bvr.date_to)
    and bvr.budget_version_id = fld.budget_version_id
    and PQH_PSF_BUS.GET_SYSTEM_SHARED_TYPE(fld.budget_unit_id) = p_system_budget_unit
    and fld.pool_id           = trnx.parent_pool_id
    and trnx.pool_id          = trnx_dtl.pool_id
    and trnx_dtl.reallocation_id = rec_amt.txn_detail_id
    and nvl(p_position_id,     nvl(rec_amt.entity_id,      -1)) =
			       nvl(rec_amt.entity_id,      -1)
    and nvl(p_organization_id, nvl(rec_amt.entity_id,  -1)) =
                               nvl(rec_amt.entity_id,  -1)
    and nvl(p_job_id,          nvl(rec_amt.entity_id,   -1)) =
		               nvl(rec_amt.entity_id,   -1)
    and nvl(p_grade_id,        nvl(rec_amt.entity_id,         -1)) =
			       nvl(rec_amt.entity_id,         -1);
--
-- Local Variables
--
l_total_realloc     number;
l_prorate_ratio     number := 1;
calc_start_date     date;
calc_end_date       date;
--
begin
--
for l_reallocation in c_reallocation
loop
   if (p_system_budget_unit = 'MONEY' or p_system_budget_unit = 'HOURS'
       or l_reallocation.budget_unit_aggregate = 'ACCUMULATE') then
    --
    calc_start_date := greatest(l_reallocation.budget_start_date, p_start_date);
    calc_end_date   := least(l_reallocation.budget_end_date, p_end_date);
    --
    -- Calculate the prorate ratio
    --
    l_prorate_ratio := pqh_budgeted_salary_pkg.get_prorate_ratio
    -- Hima, greates/least functions for p_start_date and p_end_date
                                ( calc_start_date
                                , calc_end_date
                                , l_reallocation.period_set_name
                                , l_reallocation.budget_start_date
                                , l_reallocation.budget_end_date
                                );
    --
    -- Calculate the prorated reallocation amount for the current budget and add to the l_total_realloc
    --
    l_total_realloc := nvl(l_total_realloc,0) + l_reallocation.reallocation_amt * l_prorate_ratio;
  else
    l_total_realloc := nvl(l_total_realloc,0) + l_reallocation.reallocation_amt;
    --
  end if;
end loop;
--
-- Return the calculated total reallocation amount
--
if l_total_realloc is null then
  return null;
else
  Return(trunc(nvl(l_total_realloc,0),2));
end if;
--
end;
--
function get_reallocated_money(p_position_id	     in number
                               ,p_business_group_id  in number
                               ,p_type               in varchar2 default 'DNTD'
			       ,p_start_date         in date default sysdate
			       ,p_end_date           in date default sysdate
			       ,p_effective_date     in date default sysdate) return number is
l_txn_type varchar2(30);
cursor c_reallocation is
Select bud.period_set_name,
       bud.budget_start_date,
       bud.budget_end_date,
       rec_amt.reallocation_amt,
       rec_amt.reserved_amt
from pqh_budget_pools fld,
     pqh_budget_pools trnx,
     pqh_bdgt_pool_realloctions trnx_dtl,
     pqh_bdgt_pool_realloctions rec_amt,
     pqh_budgets bud,
     pqh_budget_versions bvr
where trunc(p_effective_date) between bud.budget_start_date and bud.budget_end_date
    and bud.position_control_flag = 'Y'
    and bud.budgeted_entity_cd = 'POSITION'
    and rec_amt.transaction_type = l_txn_type
    and	bud.business_group_id = p_business_group_id
    and	((p_start_date <= budget_start_date
          and p_end_date >= budget_end_date
         ) or
        (p_start_date between budget_start_date and budget_end_date) or
        (p_end_date between budget_start_date and budget_end_date)
       )
     and ( hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = 'MONEY')
    and bud.budget_id = bvr.budget_id
    and trunc(p_effective_date) between bvr.date_from and bvr.date_to
    and bvr.budget_version_id = fld.budget_version_id
    and PQH_PSF_BUS.GET_SYSTEM_SHARED_TYPE(fld.budget_unit_id) = 'MONEY'
    and fld.pool_id           = trnx.parent_pool_id
    and trnx.pool_id          = trnx_dtl.pool_id
    and trnx_dtl.reallocation_id = rec_amt.txn_detail_id
    and rec_amt.entity_id        = p_position_id;

l_total_realloc     number := 0;
l_total_reserve     number := 0;
l_prorate_ratio     number := 1;
calc_start_date     date;
calc_end_date       date;
--
begin
--
hr_utility.set_location('mode passed'||p_type,10);
if p_type = 'RCVD' then
   l_txn_type := 'RD';
elsif p_type in ('DNTD','RSRVD') then
   l_txn_type := 'DD';
else
   hr_utility.set_location('wrong mode passed'||p_type,10);
end if;
for l_reallocation in c_reallocation loop
    calc_start_date := greatest(l_reallocation.budget_start_date, p_start_date);
    calc_end_date   := least(l_reallocation.budget_end_date, p_end_date);
    --
    -- Calculate the prorate ratio
    --
    hr_utility.set_location('period set name '||l_reallocation.period_set_name,20);
    l_prorate_ratio := pqh_budgeted_salary_pkg.get_prorate_ratio
                                ( calc_start_date
                                , calc_end_date
                                , l_reallocation.period_set_name
                                , l_reallocation.budget_start_date
                                , l_reallocation.budget_end_date
                                );
    hr_utility.set_location('prorate ratio is'||to_char(l_prorate_ratio),20);
    if p_type in ('RCVD','DNTD') then
       l_total_realloc := l_total_realloc + (nvl(l_reallocation.reallocation_amt,0) * l_prorate_ratio);
       hr_utility.set_location('realoc amt is'||to_char(l_reallocation.reallocation_amt),20);
       hr_utility.set_location('total realloc amt is'||to_char(l_total_realloc),20);
    elsif p_type = 'RSRVD' then
       l_total_reserve := l_total_reserve + (nvl(l_reallocation.reserved_amt,0) * l_prorate_ratio);
       hr_utility.set_location('reserve amt is'||to_char(l_reallocation.reserved_amt),20);
       hr_utility.set_location('total reserve amt is'||to_char(l_total_reserve),20);
    end if;
end loop;

if p_type in ('RCVD','DNTD') then
   return(trunc(l_total_realloc,2));
elsif p_type = 'RSRVD' then
   return(trunc(l_total_reserve,2));
end if;
--
end;
--
end;

/
